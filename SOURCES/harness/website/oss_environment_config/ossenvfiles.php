<?php
#
# script to display OSS Environment files
#
#	Dec 2012 eeidle
$document_root= $_SERVER['DOCUMENT_ROOT'];

include_once "../inc/git_functions.php";
include_once "../inc/chtmlform.inc";
include_once "../inc/globals.inc";
include_once "../inc/error.inc";
include_once "../inc/cdatabase.inc";
$db = &new cDatabase;
include "header.php";
?>
<script language="Javascript">
<!--

var file_path="";
/*    Function changeFilePath sets/changes the directory path of the $file_name.
	  hub migration requires that all code is in the one repo. This function will only be 
	  required until the contents of the cominf_build repo 
	  move to the cominf_test repo.
*/
function changeFilePath(oenv_file_path) {
	file_path = oenv_file_path.value;
	alert("changing directory and repo to: " + file_path);
	window.location.assign("ossenvfiles.php?dir_name=" + file_path );

}


function getRadioResults() {
	//gets the selected value from the "select_area" radio button group, where name="select_area".
    var radios = document.getElementsByName("select_area");

    for (var i = 0; i < radios.length; i++) {       
        if (radios[i].checked) {
            return (radios[i].value);
            break;
        }
    }
}
function OnNewButton(repo)
{
	file_path = getRadioResults();
	//alert(" file_path : " + file_path);
	document.envfileform.action = "ossCreateEnvironmentFile.html?mode=new&env_file_path=" + file_path;
	document.envfileform.submit();             // Submit the page
	return true;
}

function OnViewButton()
{
	if ( document.envfileform.file_name.value == "" ) {
		alert("Please select an envfile");
		return false;
	}
	file_path = getRadioResults();
	//alert(" file : " + file_path + document.envfileform.file_name.value);

	document.envfileform.action = "ossenvfile.php?mode=view&env_file_path=" + file_path + "&file_name=" +  document.envfileform.file_name.value;
	//document.write(document.envfileform.file_name);
	document.envfileform.submit();             // Submit the page
	return true;
}

function OnEditButton()
{

	if ( document.envfileform.file_name.value == "" ) {
		alert("Please select an envfile");
		return false;
	}
	file_path = getRadioResults();
	//alert(" file : " + file_path + document.envfileform.file_name.value);
	//document.envfileform.action = "phpFileManager-0.9.7/index.php?mode=edit";
	document.envfileform.action = "ossEditEnvironmentFile.html?mode=edit&env_file_path=" + file_path + "&env_file_name=" + document.envfileform.file_name.value;
	document.envfileform.submit();             // Submit the page

	return true;
}

function OnDeleteButton()
{
	if ( document.envfileform.file_id.value == 0 ) {
		alert("Please select an envfile");
		return false;
	}
	file_path = getRadioResults();
		alert(" file : " + file_path + document.envfileform.file_name.value);

	if (confirm("Are you sure you want to delete the envfile?" )) { 
		document.envfileform.action = "envfile_delete.php?file_id=" +  document.envfileform.file_id.value;
		document.envfileform.submit();             // Submit the page
	} else {
		return false
	}
	return true;
}

-->
</script>
<noscript>You need Javascript enabled for this to work</noscript>
<?php

  function getDirectoryList ($directory)  {

    // create an array to hold directory list
    $results = array();

    // create a handler for the directory
    $handler = opendir($directory);

    // open directory and walk through the filenames
    while ($file = readdir($handler)) {

      // if file isn't this directory or its parent, add it to the results
      if ($file != "." && $file != "..") {
        $results[] = $file;
      }

    }

    // tidy up: close the handler
    closedir($handler);

    // done!
    return $results;

  }
  
	// not using showDir at the moment.
	/* FUNCTION: showDir
	 * DESCRIPTION: Creates a list options from all files, folders, and recursivly
	 *     found files and subfolders. Echos all the options as they are retrieved
	 * EXAMPLE: showDir(".") */
	function showDir( $dir , $subdir = 0 ) {
		if ( !is_dir( $dir ) ) { return false; }

		$scan = scandir( $dir );

		foreach( $scan as $key => $val ) {
			if ( $val[0] == "." ) { continue; }

			if ( is_dir( $dir . "/" . $val ) ) {
				echo "<option>" . str_repeat( "--", $subdir ) . $val . "</option>\n";

				if ( $val[0] !="." ) {
					showDir( $dir . "/" . $val , $subdir + 1 );
				}
			}
		}

		return true;
	}

/*
	* MAIN
*/

	echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Home</a>&gt;"; 
	echo "<a href='../harness.php'>Harness&gt;</a>OSS Environment Files\n";
	if ( ! isset($_GET['dir_name']) ) {
		//set default $file_path;
		//debug:echo $_SERVER['SERVER_NAME'];
		//$file_path="/var/lib/jenkins/cominf_build/build_scripts/nfd/etc/";
		$file_path= $WEBSITE['REPO_PATH'] . "/SOURCES/build_scripts/nfd/etc/";
		
	}
	else {
		$file_path=$_GET['dir_name'];
		//print "<br>Dir $file_path selected. <br>";
		//print "<br>NOTICE: Only select the cominf_test radio button if you are migrating Jenkins server to the hub.<br>";
	}
	if ( ! git_pull($file_path)) {
	exit ("ERROR:Unsuccessful git_pull function. Returned FALSE. " );
	}
	//create html form using include_once "inc/chtmlform.inc";
	$form = new HtmlForm("envfileform", '', "", "maxw");


	//create radio buttons to choose which repo to store files in. not needed any more  since we are just using cominf_test repo.
	#$repo_radio = array();
	// deprecated use of cominf_build repo 
	//$repo_radio['cominf_build'] = "/var/lib/jenkins/cominf_build/build_scripts/nfd/etc/";
	#$repo_radio['cominf_test'] = $WEBSITE['REPO_PATH'] .  "/SOURCES/build_scripts/nfd/etc/";
	$area_radio = array();
	#$area_radio['cominf'] = $WEBSITE['REPO_PATH'] .  "/SOURCES/build_scripts/cominf/etc/";
	#$area_radio['infrastructure'] = $WEBSITE['REPO_PATH'] .  "/SOURCES/build_scripts/infrastructure/etc/";
	$area_radio['nfd'] = $WEBSITE['REPO_PATH'] .  "/SOURCES/build_scripts/nfd/etc/";

	#$fld = new OptionList('radio', 'select_repo', 'select repo', $repo_radio, array($file_path), $errmsg='', $note='','onClick=changeFilePath(this)' );
	#$form->AddField($fld);
	$fld = new OptionList('radio', 'select_area', 'select area', $area_radio, array($file_path), $errmsg='', $note='','onClick=changeFilePath(this)' );
	$form->AddField($fld);
	//Create a selection list which contains all files in $file_path.
	$file_id=0;
	$file_names=array();
	$file_ids=array();
	$dir_ids=array();
	$dir_names=array();
	$file_names = getDirectoryList($file_path);   //list of file names.

	sort($file_names);
	foreach ($file_names as $id) {
					array_push($file_ids, $id);
	}
	$fld_name = "Select File (". count($file_names) . ")  ";  // used to also display the number of files in brackets in the label. 
	$fld = new SelectList(&$db, $fld_name, 'file_name', array($file_id), '', "", 30, 0, "", "", "style=\"width:50%; height:100%\"", "OnEditButton()");
	$fld->AddOptions($file_names, $file_ids);
	$form->AddField($fld);

	$fld = new Button('new', 'New', 'submit', '', 'return OnNewButton(document.envfileform.select_area);');
	$form->AddButton($fld);
	$fld = new Button('view', 'View','submit', '', 'return OnViewButton();');
	$form->AddButton($fld);
	$fld = new Button('edit', 'Edit','submit', '', 'return OnEditButton();');
	$form->AddButton($fld);
	/*$fld = new Button('delete', 'Delete','submit', '', 'return OnDeleteButton();');
	$form->AddButton($fld);
	*/
	$form->Draw();


	include "../harness_footer.php"
?>
