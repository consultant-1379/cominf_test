<?php
#
# script to display cominf test spec
#
#	Apr 2012 edavmax
include_once "inc/globals.inc";
include_once "inc/error.inc";
include_once "inc/cdatabase.inc";
include_once "inc/chtmlform.inc";
$db = &new cDatabase;

include "header.php";

#
# function to get FA name from passed fa_id
#

function getFANameFromID( &$db,  $fa_id ) {
        if ( $fa_id == 0 )
                return "*unknown*";
        $sql = "SELECT name FROM funcarea WHERE ID=$fa_id";
        $result = &$db->doQuery($sql);
        if (mysql_num_rows($result) > 0 ) {
                $row =  mysql_fetch_object($result);
                return $row->name;
        }
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

?>

<script language="Javascript">
<!--

function OnFASelect()
{
        document.gentestspecform.action = "generate_testspec.php?refresh=uc_tc";
        document.gentestspecform.submit();             // Submit the page
        return true;
}


-->
</script>
<noscript>You need Javascript enabled for this to work</noscript>
<?php


echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Home</a>&gt;<a href=harness.php>Harness</a>&gt;<a href=reports.php>Reports</a>&gt;Generate Test Spec\n";

if ( isset( $_POST['fa_id'] ) ) {
       	$fa_id=$_POST['fa_id'];
} else if ( isset ($_GET['fa_id'])  ) {
       	$fa_id=$_GET['fa_id'];
} else {
       	$fa_id=0;
}

if ( isset( $_GET['refresh'] ) ) {
        $refresh=$_GET['refresh'];
} else {
        $refresh="uc";

}

if ( isset( $_POST['uc_ids'] ) ) {
       	$uc_ids=implode(",", $_POST['uc_ids']);
} else if ( isset ($_GET['uc_ids'])  ) {
       	$uc_ids=$_GET['uc_ids'];
} else {
       	$uc_ids=0;
}

if ( isset( $_POST['tc_ids'] ) ) {
       	$tc_ids=$_POST['tc_ids'];
} else if ( isset ($_GET['tc_ids'])  ) {
       	$tc_ids=$_GET['tc_ids'];
} else {
       	$tc_ids=0;
}
	
	

if ( isset ($_POST['genspec']) || isset ($_GET['genspec']) ) {

	
	if ( $fa_id !=0 ) {
		$fa_name=getFANameFromID($db, $fa_id);
	} else {
		$fa_name="N/A";
	
	}
	
	#echo "<h3>Selected Functional Areas: $fa_names</h3>\n";
	
	#echo "<h3>Selected Usecases: $uc_names</h3>\n";
	
	$sql="select funcarea.name as fa_name,usecase.name as uc_name,testcase.slogan, testcase.id as tc_id, testcase.slogan as tc_slogan, testcase.polarity, testcase.type, testcase.automated, testcase.preconditions, testcase.manual_steps, testcase.postconditions from funcarea,usecase,testcase where funcarea.id=usecase.fa_id and testcase.uc_id=usecase.id";
	if ( $fa_id !=0 ) {
		$sql .= " and funcarea.id = $fa_id "; 
	}
	if ( $uc_ids !=0 ) {
		$sql .= " and usecase.id in ($uc_ids) "; 
	}
	if ( $tc_ids !=0 ) {
		$sql .= " and testcase.id in ($tc_ids) "; 
	}
	$sql .= " order by funcarea.name, usecase.name";
	$result = &$db->doQuery($sql);
	$exist_fa="";
	$exist_uc="";
	echo "<h3>Number of matching test cases: " . mysql_num_rows($result) .  "</h3>\n";
	if (mysql_num_rows($result) > 0 ) {
		while ( ($row =  mysql_fetch_object($result)) ) {
			if ( $exist_fa != $row->fa_name ) {
				echo "<h1>$row->fa_name</h1>\n";
				$exist_fa=$row->fa_name;
			}
			if ( $exist_uc != $row->uc_name ) {
				echo "<h2>$row->uc_name</h2>\n";
				$exist_uc=$row->uc_name;
			}
			echo "<p><strong>TC Slogan: </strong>$row->tc_slogan</strong></p>\n";
			echo "<p><strong>TC ID: </strong>$row->tc_id</strong></p>\n";
			echo "<p><strong>TC Polarity: </strong>$row->polarity</strong></p>\n";
			echo "<p><strong>TC Type: </strong>$row->type</strong></p>\n";
			if ( $row->automated == 0 ) {
				$auto_text="no";
			} else { 
				$auto_text="yes";
			}
			echo "<p><strong>TC Automated: </strong>$auto_text</strong></p>\n";
			echo "<p><strong>Pre conditions:</strong>\n";
			echo "<p><pre>$row->preconditions</pre>\n";
			echo "<p><strong>Manual Steps:</strong>\n";
			echo "<p><pre>$row->manual_steps</pre>\n";
			echo "<p><strong>Post conditions:</strong>\n";
			echo "<p><pre>$row->postconditions</pre>\n";
			echo "<hr>\n";
			
		}
	}
} else {

$form = new HtmlForm("gentestspecform", '', $_SERVER['PHP_SELF'], "maxw");
$fld = new SelectList(&$db, 'Functional Area :', 'fa_id', array($fa_id), '', 0, 0, "", "OnFASelect()");
$fld->SetDBOptions('funcarea', 'id', 'name', '', 'name', array(0, 'All'));
$form->AddField($fld);

# get usecases for selected FA
$usecase_names=array();
$usecase_ids=array();

$sql = "SELECT name, id FROM usecase";
if ( $fa_id != 0 )
        $sql .= " WHERE fa_id=" . $fa_id;
$sql .= " ORDER BY name";
$result = &$db->doQuery($sql);
if (mysql_num_rows($result) > 0 ) {
        while ( ($row =  mysql_fetch_object($result)) ) {
                $id = $row->id;
                $name=$row->name;
                array_push($usecase_ids, $id);
                array_push($usecase_names, $name);
        }
        # only set the usecase  if user changes functional area 
        if ( $refresh == "uc" )
                $uc_id=$usecase_ids[0];
}


$fld = new SelectList(&$db, 'Usecases :', 'uc_ids[]', array($uc_id), '', 0, 20, 1, "");
$fld->AddOptions($usecase_names, $usecase_ids);
$form->AddField($fld);
$fld = new Button('genspec', 'Generate Spec','submit', '', "");
$form->AddButton($fld);


$form->Draw();

}


include "harness_footer.php"
?>







