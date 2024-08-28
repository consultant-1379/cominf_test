<?php
#
# script to regenerate TC spec files in GIT from the MySQL db
#
#	Apr 2012 edavmax

include_once "inc/chtmlform.inc";
include_once "inc/globals.inc";
include_once "inc/error.inc";
include_once "inc/cdatabase.inc";
$db = &new cDatabase;
$dbi = &new cDatabasei;
$mysqli=$dbi->getLink();

if ( ! isset($_GET['mode']) ) 
	$mode="new";
else
	$mode=$_GET['mode'];

$java_onloadfunc="onload=\"toggleFields('" . $mode . "')\"";

function getFunctionalAreaFromUsecase(&$db, $uc_id) {
        if ( $uc_id == 0 ) {
                return "*unknown*";
        }
        $sql = "SELECT funcarea.name AS fa_name FROM funcarea, usecase WHERE usecase.id=$uc_id AND funcarea.id=usecase.fa_id";
        if (!($result = &$db->doQuery($sql)) || mysql_num_rows($result) == 0 ) {
                FatalError(101, "Failed to get functional area for uc=$uc_id", __file__, __line__);
        }
        $row = mysql_fetch_object($result);
        return $row->fa_name;

}

# function to return usecase name from given uc id
function getUCInfo(&$db, $uc_id) {
        # get usecase name
        $sql = "SELECT usecase.name AS uc_name, usecase.id AS uc_id FROM usecase WHERE usecase.id=" . $uc_id;
        if (!($result = &$db->doQuery($sql)) || mysql_num_rows($result) == 0 ) {
                FatalError(101, "Failed to get usecase name for uc id=$uc_id", __file__, __line__);
        }
        $row = mysql_fetch_object($result);
        return array("uc_id" => $row->uc_id, "uc_name" => $row->uc_name);

}

# function to return author info from given auth id
function getAuthInfo(&$db, $auth_id) {
        if ( $auth_id == 0 )
                return FALSE;
        $auth_info = array();
        # get usecase name
        $sql = "SELECT id, firstname, lastname, signum FROM author WHERE id=" . $auth_id;
        if (!($result = &$db->doQuery($sql)) || mysql_num_rows($result) == 0 ) {
                FatalError(101, "Failed to get author details for auth id=$auth_id", __file__, __line__);
        }
        $row = mysql_fetch_object($result);
        return array("id" => $row->id, "fname" => $row->firstname, "lname" => $row->lastname, "signum" => $row->signum);
}


function getTCDirPath(&$db, $uc_id, $tc_id) {
	global $cloned_repo_sourcedir;
	$uc_info = array();
	if ( ! isset( $uc_id) || ! isset( $tc_id ) ) {
		return '*unknown*'; 
	}

	$uc_info = getUCInfo(&$db, $uc_id);
	$uc_name = $uc_info['uc_name'];
	$fa_name = getFunctionalAreaFromUsecase(&$db, $uc_id);

	$tcpath="$cloned_repo_sourcedir/FA/$fa_name/$uc_name/$tc_id";
        return $tcpath;
}

function getTCSpecPath($tcpath, $tc_id) {
	if ( ! isset( $tcpath ) || ! isset( $tc_id ) || $tcpath == '' ) {
		return '*unknown*';
	}
	return $tcpath . "/" . $tc_id . "_spec.bsh";
}

function getTCPath($tcpath, $tc_id) {
	if ( ! isset( $tcpath ) || ! isset( $tc_id ) || $tcpath == '' ) {
		return '*unknown*';
	}
	return $tcpath . "/" . $tc_id . "_callbacks.lib";
}

function generateTCSpecFile(&$db, $tmpspecfilepath, $uc_id, $tc_id, $slogan, $type, $polarity, $priority, $automated, $dependent, $timeout,
				 $passcode, $auth_id, $cont_id, $preconditions, $manual_steps, $postconditions, $disabled ) {
	if ( ! ($tmpfname = tempnam($tmpspecfilepath, "FOO") ) ) {
		return FALSE;
	}
	if ( ! ($fh = fopen($tmpfname, 'w') ) ) {
		return FALSE;
	}
	$fa_name = getFunctionalAreaFromUsecase(&$db, $uc_id);
	$uc_info = getUCInfo(&$db, $uc_id);
	$uc_name = $uc_info['uc_name'];
	$auth_info = getAuthInfo(&$db, $auth_id);
	$auth_signum = $auth_info['signum'];
	$cont_info = getAuthInfo(&$db, $cont_id);
	$cont_signum = $cont_info['signum'];
	$preconditions=str_replace("\r", "", $preconditions);
	$manual_steps=str_replace("\r", "", $manual_steps);
	$postconditions=str_replace("\r", "", $postconditions);
	$preconditions="#" . str_replace("\n", "\n#", $preconditions);
	$manual_steps="#" . str_replace("\n", "\n#", $manual_steps );
	$postconditions="#" . str_replace("\n", "\n#", $postconditions);
	date_default_timezone_set('Europe/Dublin');
	$date=date('l jS \of F Y G:i:s');
	$slogan = addslashes($slogan);

	$contents = <<<EOC
#!/bin/bash

# TEST CASE SPEC FILE
# This file is generated/updated using the test framework web interface.
# Manual updates on test servers are lost when the test package is re-installed.
#
# Last modified: $date
#

# These settings must be in BASH script format, they are sourced by other scripts.
SPEC_FA_NAME="$fa_name"
SPEC_UC_NAME="$uc_name"
SPEC_TC_ID=$tc_id
SPEC_TC_SLOGAN="$slogan"
SPEC_TC_TYPE="$type"
SPEC_TC_POLARITY="$polarity"
SPEC_TC_PRIORITY="$priority"
SPEC_TC_AUTOMATED=$automated
SPEC_TC_DEPENDENT_ONLY=$dependent
SPEC_TC_TIMEOUT=$timeout
SPEC_TC_TEST_PASSCODE=$passcode
SPEC_TC_AUTHOR="$auth_signum"
SPEC_TC_AUTOMATOR="$cont_signum"
# this parameter is not interpreted by harness
SPEC_TC_DISABLED=$disabled

# Please do not remove the comment lines below.
# They are used as section locators by the test harness.

# BEGIN_PRE_CONDITIONS
$preconditions
# END_PRE_CONDITIONS


# BEGIN_MANUAL_STEPS
$manual_steps
# END_MANUAL_STEPS

# BEGIN_POST_CONDITIONS
$postconditions
# END_POST_CONDITIONS

EOC;
	fwrite($fh, $contents);
	fclose( $fh );
	return $tmpfname;

}


$submitbtntxt="Save";
$uc_name_err="";
$slogan_err="";
$steps_err="";
$fa_id_err="";
$auth_id_err="";
$cont_id_err="";
$uc_id_err="";
$type_err="";
$priority_err=0;
$polarity_err=0;
$timeout_err='';
$passcode_err='';
$automated_err='';
$dependent_err='';
$expect_plugin_err='';
$preconditions_err='';
$postconditions_err='';
$manual_steps_err='';
$disabled_err='';

$uc_id_def=0;
$auth_id_def=0;
$cont_id_def=0;
$timeout_def=300;
$passcode_def=0;
$expect_plugin_def=0;
$tc_id_def=0;
$fa_name_def="*new*";
$slogan_def='';
$preconditions_def='';
$manual_steps_def='';
$postconditions_def='';
$polarity_def="positive";
$priority_def="high";
$type_def="FT";
$automated_def=0;
$dependent_def=0;
$disabled_def=0;
$specfilepath_def = "*unknown*";
$tcfilepath_def = "*unknown*";
$formerrors=0;
$gitmove=0;
$tmpspecfileloc="/tmp";
$transaction_error=0;
$transaction_errmsg="";
$cloned_repo_path=$WEBSITE['REPO_PATH'];
$cloned_repo_sourcedir=$cloned_repo_path . "/SOURCES";
$tc_script_template=$cloned_repo_sourcedir . "/harness/etc/test_callbacks.lib.template";
$git="/usr/bin/git";
$gitlog="/home/cominfci/log/gitlog";
$harness_tgtdir="/opt/ericsson/cominf_test";

# we have big problem
if ( ! is_executable ($git) ) { 
	FatalError(105,'git is not installed or executable on server', __file__, __line__); 
}

include "header.php";
echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Home</a>&gt;<a href=harness.php>Harness</a>&gt; Re-gen spec files\n";

if ( isset ($_POST['submitregen']) &&  $_POST['submitregen'] == "Regenerate Spec Files" ) {
	$sql = "SELECT usecase.name AS uc_name, author.signum AS auth_signum, contact.signum AS cont_signum, testcase.id, testcase.uc_id, testcase.auth_id, testcase.cont_id, testcase.slogan, polarity, priority, passcode, type, automated, dependent, timeout, expect_plugin, preconditions, manual_steps, postconditions, approved, disabled FROM testcase,usecase, author, author AS contact WHERE usecase.id=testcase.uc_id AND author.id=testcase.auth_id AND contact.id=testcase.cont_id ";
	$result = &$db->doQuery($sql);
	if( mysql_num_rows($result) == 0)
		FatalError(105,'testcase records not found', __file__, __line__);
	while ( ($row =  mysql_fetch_object($result)) ) {
		$tc_id=$row->id;
		$uc_id=$row->uc_id;
		$uc_name=$row->uc_name;
		$auth_id=$row->auth_id;
		$cont_id=$row->cont_id;
		$auth_signum=$row->auth_signum;
		$cont_signum=$row->cont_signum;
		$slogan=$row->slogan;
		$polarity=$row->polarity;
		$priority=$row->priority;
		$passcode=$row->passcode;
		$type=$row->type;
		$automated=$row->automated;
		$dependent=$row->dependent;
		$timeout=$row->timeout;
		$preconditions=$row->preconditions;
		$manual_steps=$row->manual_steps;
		$postconditions=$row->postconditions;
		$disabled=$row->disabled;
		$approved=$row->approved;
		$expect_plugin=$row->expect_plugin;

		# get TC paths
		if ( isset($uc_id) && $uc_id > 0 && isset($tc_id) && $tc_id > 0 ) {  
			$tcpath = getTCDirPath( &$db, $uc_id, $tc_id );
			$specfilepath = getTCSpecPath( $tcpath, $tc_id );
			$tcfilepath = getTCPath( $tcpath, $tc_id );
		}
		if ( file_exists($specfilepath) ) {
			$tmp_specfile = generateTCSpecFile(&$db, $tmpspecfileloc, $uc_id, $tc_id, $slogan, $type, $polarity, $priority, $automated, $dependent, $timeout, $passcode, $auth_id, $cont_id, $preconditions, $manual_steps, $postconditions, $disabled);   
			if ( ! copy( $tmp_specfile, $specfilepath ) ) 
				FatalError(105,'failed to copy new specfile', __file__, __line__);
	
			# remove temp specfile
			if ( file_exists($tmp_specfile) ) {
				unlink( $tmp_specfile );
			}
		}
	}
	# switch to correct git branch
	$cmd="cd $cloned_repo_path; $git checkout " . $WEBSITE['GIT_BRANCH'] . " >> $gitlog 2>&1";
	system($cmd, $retcode);
	if ($retcode != 0) {
		FatalError(105,"Unable to checkout git branch " . $WEBSITE['GIT_BRANCH'], __file__, __line__); 
	}
	$cmd="cd $cloned_repo_path; $git pull >> $gitlog  2>&1";
	system($cmd, $retcode);
	if ( $retcode != 0 ) 
		FatalError(105,"$cmd failed", __file__, __line__);
	$cmd = "cd $cloned_repo_path; $git add * >> $gitlog 2>&1";
	system($cmd, $retcode);
	if ( $retcode != 0 ) 
		FatalError(105,"$cmd failed", __file__, __line__);

	$cmd = "cd $cloned_repo_path; $git commit -m \"re-synced spec file from database\"  >> $gitlog 2>&1"; 
	system($cmd, $retcode);
	if ( $retcode != 0 ) 
		FatalError(105,"$cmd failed", __file__, __line__);

	$cmd="cd $cloned_repo_path; $git push origin " . $WEBSITE['GIT_BRANCH'] . " >> $gitlog 2>&1";
 	system($cmd, $retcode);
	if ( $retcode != 0 ) 
		FatalError(105,"$cmd failed", __file__, __line__);
	echo "<p>Spec files refreshed OK!\n";


} else { 
	$actionurl = $_SERVER['PHP_SELF'];

echo "<form name=\"testcaseform\" enctype=\"\" method=\"POST\" action=\"$actionurl\"\n";
echo "<table border=0>\n";
echo "<tr style=\"height: 50px\">\n";
echo "<td align=\"center\" colspan=\"2\">\n";
echo "<input type=\"submit\" name=\"submitregen\" value=\"Regenerate Spec Files\" onclick=\"\">\n";
echo "</td>\n";
echo "</tr>\n";
echo "</table>\n";
echo "</form>\n";




}
include "harness_footer.php";
?>


