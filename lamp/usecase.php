<?php
#
# script to display and process usecase form
#
#	Apr 2012 edavmax
include "header.php";
include "inc/chtmlform.inc";

$submitbtntxt="Save";
$uc_name_err="";
$slogan_err="";
$steps_err="";
$fa_id_err=0;



if ( ! isset($_GET['mode']) ) 
	$mode="new";
else
	$mode=$_GET['mode'];


if ( $mode == "new" ) {
	$fa_id=1;
	$uc_id=0;
	$uc_name="";
	$slogan="";
	$steps="";

} else {

	if ( ! isset ($_POST['submitusecase']) ) {
		# we are in view|edit mode and not submitting form
		if ( ! isset ($_GET['uc_id']) ) 
			FatalError(105,'usecase id not found', __file__, __line__); 
		$uc_id=$_GET['uc_id'];
		$sql = "SELECT funcarea.name AS fa_name, funcarea.id as fa_id, usecase.name AS uc_name, usecase.id AS uc_id, slogan, steps FROM funcarea, usecase WHERE funcarea.id=usecase.fa_id AND usecase.id = " . $uc_id;
		$result = &$db->doQuery($sql);
		if( mysql_num_rows($result) == 0)
			FatalError(105,'usecase record not found', __file__, __line__);
		$row = mysql_fetch_object($result);
		$fa_name = $row->fa_name;
		$fa_id = $row->fa_id;
		$uc_name = $row->uc_name;
		$slogan = $row->slogan;
		$steps = $row->steps;
	}
		

}

echo "<h1>" . $mode . " usecase</h1>\n";

	

if ( $mode == "view" ) {
	echo "<dl>\n";
	echo "<dt>Functional Area\n";
	echo "<dd>" . $row->fa_name . "\n";
	echo "<dt>Name\n";
	echo "<dd>" . $row->uc_name . "\n";
	echo "<dt>Slogan\n";
	echo "<dd>" . $row->slogan . "\n";
	echo "<dt>Steps\n";
	echo "<dd>" . nl2br($row->steps) . "\n";
	echo "</dl>\n";

	echo "<p><a href=./" . $_SERVER['PHP_SELF'] . "?mode=edit&uc_id=" . $uc_id . ">Edit this usecase</a>\n";



} else {

	$formerrors=0;
	
	if ( isset ($_POST['submitusecase']) &&  $_POST['submitusecase'] == "$submitbtntxt" ) {
		# process the form
    		$uc_id = $_POST['uc_id'];
    		$fa_id = $_POST['fa_id'];
		$uc_name = htmlspecialchars($_POST['uc_name']);
		$slogan = htmlspecialchars($_POST['slogan']);
		$steps = htmlspecialchars($_POST['steps']);
	
		if ( $uc_name == '' ) {
			$formerrors++;
			$uc_name_err = "Please enter a name.";
		}
		if ( $slogan == '' ) {
			$formerrors++;
			$slogan_err = "Please enter a slogan.";
		}
		if ( $steps == '' ) {
			$formerrors++;
			$steps_err = "Please enter a some steps.";
		}
	
		if ( $formerrors > 0 ) {
			echo "<p>NOTE: There are problems with the information provided as indicated in red below. Please correct the problems and click <strong>" . $submitbtntxt . "</strong>\n";
	
		} else {
			# update the DB
			if ( $mode == "new" ) {
				$sql = "INSERT INTO usecase (fa_id, name, slogan, steps) VALUES (" . $fa_id . ",\"" . $uc_name . "\",\"" . $slogan . "\",\"" . $steps . "\")";

					
			} else {
				$sql = "UPDATE usecase SET fa_id=" . $fa_id . ", name=\"" . $uc_name . "\", slogan=\"" . $slogan . "\", steps=\"" . $steps . "\" WHERE id=" . $uc_id;
			}
echo $sql;
			if (!($result = mysql_query($sql))) {
				FatalError(101, 'Failed to add/edit usecase', __file__, __line__);
			}
			echo "<p>Usecase added/edited successfully";
		}

	}

	if ( ! isset ($_POST['submitusecase']) || $formerrors > 0 ) {
	
		$actionurl = $_SERVER['PHP_SELF'] . "?mode=$mode";
		$form = new HtmlForm("usecaseform", '', $actionurl, 500);
	
		$fld = new SelectList(&$db, '* Functional Area :', 'fa_id', array($fa_id), '', $fa_id_err, 0, 0, "");
		$fld->SetDBOptions('funcarea', 'id', 'name', '', 'name', array('', 'Select'));
		$form->AddField($fld);
		
	
		$fld = new TextField('* Name:', 'uc_name', 'text', $uc_name, 'e.g. LDAP_ADD_USER', 30, 64, $uc_name_err) ;
		$form->AddField($fld);
	
		$fld = new TextField('* Slogan:', 'slogan', 'text', $slogan, 'e.g. Add a user to LDAP', 60, 100, $slogan_err) ;
		$form->AddField($fld);
	
		$fld = new TextArea('* Steps:', 'steps', $steps, '', 20, 64, $steps_err);
		$form->AddField($fld);

		$fld = new Hidden('uc_id', $uc_id);
		$form->AddHidden($fld);

	
	
		$fld = new Button('submitusecase', $submitbtntxt,'submit');
		$form->AddButton($fld);
	
		$form->Draw();
	}

}


if ( $mode != "new" )
	echo "<p><a href=./" . $_SERVER['PHP_SELF'] . "?mode=new>Create new usecase</a>\n";

echo "<p><a href=./usecases.php>All usecases</a>\n";



include "harness_footer.php"
?>







