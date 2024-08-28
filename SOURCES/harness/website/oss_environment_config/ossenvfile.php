<?php
#
# script to display and process env file form
#
#	Dec 2012 eeidle
$document_root= $_SERVER['DOCUMENT_ROOT'];
include_once "../inc/git_functions.php";
include_once "../inc/chtmlform.inc";
include_once "../inc/globals.inc";
include_once "../inc/error.inc";
//include_once "../inc/cdatabase.inc";
include 'header.php'; 



if ( ! isset($_GET['mode']) ) 
	exit("Error: mode variable not set.  should be eg. view, new, edit or delete.<br> Todo, should really redirect back to calling page."); 
else
	if ( ! isset($_GET['env_file_path']) ) 
		exit("Error: file_path variable not set.  should be eg. view, new, edit or delete.<br> Todo, should really redirect back to calling page."); 
	if ( ! isset($_GET['file_name']) ) 
		exit("Error: file_path variable not set.  should be eg. view, new, edit or delete.<br> Todo, should really redirect back to calling page."); 
	$mode=$_GET['mode'];
	$file_path=$_GET['env_file_path'];
	$file_name=$_GET['file_name'];
	echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Home</a>&gt;"; 
	echo "<a href='../harness.php'>Harness&gt;";
	echo "<a href='../oss_environment_config/ossenvfiles.php'>OSS Environment Files&gt;</a>View Environment File\n<br>";

	print "<hr><b>In $mode mode:</b> Viewing $file_path$file_name<br><hr>";
	if ( ! git_pull($file_path)) {
		exit ("ERROR:Unsuccessful git_pull function. Returned FALSE. " );
	}
/*	
	if ( ! isset ($_POST['submitfile']) ) {
		# we are in view|edit mode and not submitting form
		if ( ! isset ($_GET['file_name']) ) 
			FatalError(105,'file name not found', __file__, __line__); 
		if ( is_file($file_name) )
			print "File $file_name selected. <br>";
		else {	
			//needs some work to be able to traverse directories.
			if ( is_dir($file_name) ) {
				$dir_name=$file_name;
				print "Directory $file_name selected. <br>";
					$_SESSION['dir_name'] = $dir_name;
					//opendir($dir_name);
					   header( "Location: http://atclvm243.athtem.eei.ericsson.se/ossenvfiles.php?dir_name=$dir_name" ) ;
					//exec ('/usr/local/bin/php -f /var/www/html/ossenvfiles.php?dir_name=$dir_name') ;
					return;
			}
			print " $file_name shouldn't be here.. <br>";
		}
	}
	*/
	if ( $mode == "view" ) {	
		$file = fopen($file_path . $file_name, 'r'); // read current file
		while ($line = fgets($file)) {
			print "$line <br>"  ; 
		}
		fclose($file);
	}
	
include "../harness_footer.php"
?>



