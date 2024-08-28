<html> <head> <title>OSS Environment Configuration</title>
	<?php
		include_once "../inc/globals.inc";
		include 'header.php'; 
		include_once "../inc/git_functions.php";
	?>

	<script language="Javascript">
<!--
function confirmEdit() {
	input_box=confirm("confirm that you wish to Continue.");
	if ( input_box == true) {
		return true;
	}
	else {
		alert("Cancelled edit");
		return false;
	}
}
function onEditButton() {
	oenv_file_path = document.getElementById("ENV_FILE_PATH");
	oenv_file_name = document.getElementById("ENV_FILE_NAME");
	document.form_env_exists.action = "ossEditEnvironmentFile.html?mode=edit&env_file_path=" + oenv_file_path.value + "&env_file_name=" + oenv_file_name.value;
	document.form_env_exists.submit();             // Submit the page

	return true;
}
-->
</script>
</head>
<body>
<?php
	echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Home</a>&gt;<a href='../harness.php'>Harness&gt;</a><a href='ossenvfiles.php'\">Select Environment File&gt;</a>\n";
	echo "<hr>";
	$transaction_error = 0;
	$ENV_FILE_PATH=$WEBSITE['REPO_PATH'] . "/SOURCES/build_scripts/nfd/etc/";
	if(isset($_POST['ENV_FILE_PATH'])){ $ENV_FILE_PATH = $_POST['ENV_FILE_PATH']; }
	$ENV_FILE_PATH = $_POST['ENV_FILE_PATH'];
	$ENV_FILE_NAME = $ENV_FILE_PATH . $_POST['ENV_FILE_NAME'];
	//$ENV_FILE_PATH="/var/lib/jenkins/cominf_build/workspace/cominf_test/SOURCES/build_scripts/nfd/etc/";
	//print "ENV_FILE_NAME:=$ENV_FILE_NAME<br>";	
	if (file_exists($ENV_FILE_NAME)) {
		$ENV_FILE_NAME = $_POST['ENV_FILE_NAME'];
		//action="ossEditEnvironmentFile.html?mode=edit&env_file_path="' . $ENV_FILE_PATH . '"&env_file_name="' . $ENV_FILE_NAME "
		echo '
			<form name="form_env_exists" method="post" onSubmit="return confirmEdit()">
				<fieldset>
					<legend>Environment File</legend>
					<p><label>Specify path to environment file : <input type="text" name="ENV_FILE_PATH" id="ENV_FILE_PATH" value="' . $ENV_FILE_PATH . '"  size="100" required/></label></p>
					<p><label>Specify environment file name: <input type="text" name="ENV_FILE_NAME" id="ENV_FILE_NAME" value="' . $ENV_FILE_NAME . '" size="35" required/></label></p>
					<b>Warning: File "' . $ENV_FILE_PATH . $ENV_FILE_NAME . '" already exists. Edit or exit? </b><br>
					<input type="button" name="edit_existing_file" value="Overwrite Existing File" onclick=\'alert("function OverwriteEnvFile() not defined yet")\'>
					<input type="button" name="Save_As" value="Save As" onclick=\'alert("function saveAsNewEnvFile() not defined yet")\'>
					<input type="button" name="edit_existing_file" value="Edit Existing File" onclick="onEditButton()">			
					<input type="button" name="Cancel" value="Cancel " onclick=\'alert("function Cancel___() not defined yet")\'>		
				</fieldset>		
			</form>
		';
		
	}
	else {   //set variables
		$ENV_FILE_NAME = $ENV_FILE_PATH . $_POST['ENV_FILE_NAME'];
		$G_REMOTE_TEST_HARNESS_DIR = "/var/tmp/platform_taf";
		$CI_PLATFORM = $_POST['CI_PLATFORM'];
		$CI_ADMIN1_IPV4_ADDRESS = $_POST['CI_ADMIN1_IPV4_ADDRESS'];
		$CI_ADMIN1_HOSTNAME = $_POST['CI_ADMIN1_HOSTNAME'];
		$CI_ADMIN1_ROOTPW = $_POST['CI_ADMIN1_ROOTPW'];
		$CI_ADMIN1_ILO_NAME = $_POST['CI_ADMIN1_ILO_NAME'];
		$CI_ADMIN1_ILO_ROOTPW = $_POST['CI_ADMIN1_ILO_ROOTPW'];
		$CI_ADMIN2_HOSTNAME = ""; // setting variable so as not to generate undefined var for SPARC
		if ( $CI_PLATFORM == "i386" ) {
			$CI_ADMIN2_IPV4_ADDRESS = $_POST['CI_ADMIN2_IPV4_ADDRESS'];
			$CI_ADMIN2_HOSTNAME = $_POST['CI_ADMIN2_HOSTNAME'];
			$CI_ADMIN2_ROOTPW = $_POST['CI_ADMIN2_ROOTPW'];
			$CI_ADMIN2_ILO_NAME = $_POST['CI_ADMIN2_ILO_NAME'];
			$CI_ADMIN2_ILO_ROOTPW = $_POST['CI_ADMIN2_ILO_ROOTPW'];
		}
		$CI_RELEASE = $_POST['CI_RELEASE'];
		$CI_SHIPMENT = $_POST['CI_SHIPMENT'];
		$CI_TYPE = $_POST['CI_TYPE'];
		$CI_ENVIRONMENT = $_POST['CI_ENVIRONMENT'];	
		$CI_BUILD_TYPE = $_POST['CI_BUILD_TYPE'];
		$CI_OSS_PROD_NUM = $_POST['CI_OSS_PROD_NUM'];	
		$CI_OSS_PROD_REV = $_POST['CI_OSS_PROD_REV'];	
		$G_HARNESS_HOST = $_POST['harnesshost'];

		$harnessparam = $_POST['harnessparam'];
		$testselection = $_POST['testselection'];
		if ( $harnessparam != null )
		{
			switch($harnessparam)
			{
				case "testcases" :  $harnesshostarg="-i";break;
				case "testsuites" : $harnesshostarg="-s";break;
				case "usecases" : $harnesshostarg="-u";break;
				default :
			}
		}
		else { echo ("Invalid Entry for harnesshostarg."); }


		if ( $G_HARNESS_HOST == "localhost" ) {
			echo "Test harness will be installed and run on jenkins slave:$harnessparam :($testselection) has been selected to execute on $CI_ADMIN1_HOSTNAME";
		}
		else {
			echo "Test harness will be installed and run on OSS $CI_ADMIN1_HOSTNAME :$harnessparam :($testselection) has been selected to execute on $CI_ADMIN1_HOSTNAME";
		}
		if ( $testselection !=null )
		{
			$harnesshostarg = $harnesshostarg . ' \'' . $testselection . '\' ';
		}
		else  { exit ("Invalid Entry for testselection i.e. no $harnessparam specified.<br>");  }
		if ( $G_HARNESS_HOST != null )
		{
			// this switch is now redundant and can be replaced by a one liner since we now build the path to the atharness.bsh in ci_job.bsh
			switch($G_HARNESS_HOST)   
			{
				case "targetserver" : 
					$harnesscommand="G_TEST_HARNESS_COMMAND=\"harness/bin/atharness.bsh $harnesshostarg -j \${G_BUILD_NUMBER} -S \"";
					break;
				case "localhost" :  
					$harnesscommand="G_TEST_HARNESS_COMMAND=\"harness/bin/atharness.bsh $harnesshostarg -j \${G_BUILD_NUMBER} -S\"";
					break;
			}
			echo ("Running harness on $G_HARNESS_HOST <br>");
		}
		else { echo ("Invalid Entry for G_HARNESS_HOST.<br>"); }
		if ( $CI_ADMIN1_IPV4_ADDRESS == null)
			{ echo ("Invalid Entry for CI_ADMIN1_IPV4_ADDRESS.<br>");  }
		$fh = fopen($ENV_FILE_NAME, 'w') or die("can't open file");
		$stringData = "#!/bin/bash\n";
		fwrite($fh, $stringData);
		fclose($fh);
		$fh = fopen($ENV_FILE_NAME, 'a') or die("can't open file");
		$stringData = "G_HARNESS_HOST=$G_HARNESS_HOST\n";
		fwrite($fh, $stringData);	
		$stringData = "$harnesscommand\n";
		fwrite($fh, $stringData);
		$stringData = "CI_PLATFORM=$CI_PLATFORM\n";
		fwrite($fh, $stringData);
		$stringData = "CI_ENVIRONMENT=$CI_ENVIRONMENT\n";
		fwrite($fh, $stringData);		
		$stringData = "CI_ADMIN1_IPV4_ADDRESS=$CI_ADMIN1_IPV4_ADDRESS\n";
		fwrite($fh, $stringData);
		if ( $CI_PLATFORM == "i386" ) {
			$stringData = "CI_ADMIN2_IPV4_ADDRESS=$CI_ADMIN2_IPV4_ADDRESS\n";
			fwrite($fh, $stringData);
		}
		$stringData = "CI_ADMIN1_HOSTNAME=$CI_ADMIN1_HOSTNAME\n";
		fwrite($fh, $stringData);
		if ( $CI_PLATFORM == "i386" ) {
			$stringData = "CI_ADMIN2_HOSTNAME=$CI_ADMIN2_HOSTNAME\n";
			fwrite($fh, $stringData);
		}
		$stringData = "CI_ADMIN1_ROOTPW=$CI_ADMIN1_ROOTPW\n";
		fwrite($fh, $stringData);
		if ( $CI_PLATFORM == "i386" ) {
			$stringData = "CI_ADMIN2_ROOTPW=$CI_ADMIN2_ROOTPW\n";
			fwrite($fh, $stringData);
		}
		$stringData = "CI_ADMIN1_ILO_NAME=$CI_ADMIN1_ILO_NAME\n";
		fwrite($fh, $stringData);
		if ( $CI_PLATFORM == "i386" ) {
			$stringData = "CI_ADMIN2_ILO_NAME=$CI_ADMIN2_ILO_NAME\n";
			fwrite($fh, $stringData);
		}
		$stringData = "CI_ADMIN1_ILO_ROOTPW=$CI_ADMIN1_ILO_ROOTPW\n";	
		fwrite($fh, $stringData);
		if ( $CI_PLATFORM == "i386" ) {
			$stringData = "CI_ADMIN2_ILO_ROOTPW=$CI_ADMIN2_ILO_ROOTPW\n";	
			fwrite($fh, $stringData);
		}
		$stringData = "CI_RELEASE=$CI_RELEASE\n";	
		fwrite($fh, $stringData);
		$stringData = "CI_SHIPMENT=$CI_SHIPMENT\n";	
		fwrite($fh, $stringData);
		$stringData = "CI_BUILD_TYPE=$CI_BUILD_TYPE\n";
		fwrite($fh, $stringData);		
		$stringData = "CI_TYPE=$CI_TYPE\n";	
		fwrite($fh, $stringData);		
		$stringData = "CI_OSS_PROD_NUM=$CI_OSS_PROD_NUM\n";	
		fwrite($fh, $stringData);
		$stringData = "CI_OSS_PROD_REV=$CI_OSS_PROD_REV\n";	
		fwrite($fh, $stringData);
		$stringData = "CI_MWS_JUMP=YES\n";  				// always YES when calling master_wrapper from here
		fwrite($fh, $stringData);		
		$stringData = "CI_PRE_INI=YES\n"; 					// always YES when calling master_wrapper from here
		fwrite($fh, $stringData);		
		$stringData = "CI_DMR=NO\n"; 						// always NO when calling master_wrapper from here, Separate test case configures DMR
		fwrite($fh, $stringData);
		if ( "$CI_ADMIN2_HOSTNAME" != null) {
			$stringData = "G_WRAPPER_ARGS=\"-r \${CI_RELEASE} -s \${CI_SHIPMENT} -t \${CI_TYPE} -p \${CI_PLATFORM} -m \${CI_ADMIN1_HOSTNAME} -d \${CI_DMR} -e \${CI_ENVIRONMENT} -l \${CI_BUILD_TYPE} -k \${CI_MWS_JUMP} -i \${CI_PRE_INI} -x NO -q \${CI_ADMIN2_HOSTNAME}\"\n";
		} else {
			$stringData = "G_WRAPPER_ARGS=\"-r \${CI_RELEASE} -s \${CI_SHIPMENT} -t \${CI_TYPE} -p \${CI_PLATFORM} -m \${CI_ADMIN1_HOSTNAME} -d \${CI_DMR} -e \${CI_ENVIRONMENT} -l \${CI_BUILD_TYPE} -k \${CI_MWS_JUMP} -i \${CI_PRE_INI} -x NO \"\n";
		}
		fwrite($fh, $stringData);
		$stringData = "### Below variable names are now deprecated. Do not use them in test cases. ###\n";
		fwrite($fh, $stringData);
		$stringData = "CI_MACHINE=\${CI_ADMIN1_HOSTNAME}\n";	//refactor required to replace this variable
		fwrite($fh, $stringData);
		$stringData = "CI_MACHINE2=\${CI_ADMIN2_HOSTNAME}\n";	//refactor required to replace this variable
		fwrite($fh, $stringData);
		$stringData = "CI_ADMIN2=\${CI_ADMIN2_HOSTNAME}\n";	//refactor required to replace this variable		
		fwrite($fh, $stringData);
		$stringData = "CI_SERVER2_ROOTPW=\${CI_ADMIN2_ROOTPW}\n";	//refactor required to replace this variable
		fwrite($fh, $stringData);
		$stringData = "CI_MACHINE2_ILO=\${CI_ADMIN2_ILO_NAME}\n";	//refactor required to replace this variable
		fwrite($fh, $stringData);
		$stringData = "CI_ILO2_ROOTPW=\${CI_ADMIN2_ILO_ROOTPW}\n";	//refactor required to replace this variable
		fwrite($fh, $stringData);
		$stringData = "CI_SERVER_HOSTNAME[0]=\${CI_MACHINE}\n";
		fwrite($fh, $stringData);	
		$stringData = "CI_SERVER_IP[0]=\${CI_ADMIN1_IPV4_ADDRESS}\n"; //refactor required... might need to remove leading \
		fwrite($fh, $stringData);	
		$stringData = "CI_SERVER_INST_TYPE[0]=system\n";    //refactor required to replace this variable
		fwrite($fh, $stringData);	
		$stringData = "CI_SERVER_CONFIG[0]=system\n"; 		//refactor required to replace this variable
		fwrite($fh, $stringData);	
		$stringData = "CI_SERVER_ROOTPW[0]=shroot\n";		//refactor required to replace this variable
		fwrite($fh, $stringData);	
		$stringData = "\n";
		fwrite($fh, $stringData);	

		
		fclose($fh);
		$fh = fopen($ENV_FILE_NAME, 'r'); // read current file
			while ($line = fgets($fh)) {
				print "$line <br>"  ; 
		}
		fclose($fh);
		$cominf_test_repo_clone=$WEBSITE['REPO_PATH'];
		//$cominf_build_repo_clone="/var/lib/jenkins/cominf_build/";
		$cloned_repo_sourcedir=$cominf_test_repo_clone . "/SOURCES";
		echo "<br><hr>";
		$gitresult="git command failed";
		if ( ! git_pull($ENV_FILE_PATH)) {
			exit ("ERROR:Unsuccessful git_pull.  Function returned with a failure.<br> " );
		}
		print "git pull successful<br>";
		if ( ! git_commit($ENV_FILE_PATH,$ENV_FILE_NAME)) {
			exit ("ERROR:Unsuccessful git add/commit/pull. Function returned with a failure. <br>" );
		} else {
				$gitresult="git push successful!";
				print "<br>git push successful<br>";
		}
		
	}
	?>
		<script language="Javascript">
<!--
			alert("<?php echo $gitresult ?>");
-->			
		</script>
			


	<!--	
		/*
		old git just keeping incase have to backout functions.
		$git="/usr/bin/git";
		$gitlog="/var/log/gitlog";
		$transaction_errmsg="";

		if ( ! is_executable ($git) ) {
				FatalError(105,'git is not installed or executable on server', __file__, __line__);
		}
		if ( $transaction_error == 0 ) {
				# git pull
				$cmd="cd $cominf_test_repo_clone; $git pull >> $gitlog  2>&1";
				system($cmd, $retcode);
				//print "$cmd $retcode : $transaction_error : $transaction_errmsg:<br>" ;
				if ( $retcode != 0 ) {
						$transaction_error=1;
						$transaction_errmsg="Failed to git pull in workspace";
						//print "$cmd $retcode : $transaction_error : $transaction_errmsg:<br>" ;
				} else {
						#git add
						$cmd = "cd $cominf_test_repo_clone; $git add $ENV_FILE_NAME >> $gitlog 2>&1";
						system($cmd, $retcode);
						if ( $retcode != 0 ) {
								$transaction_error=1;
								$transaction_errmsg="Failed to git add ENV file $ENV_FILE_NAME";
											print "$cmd $retcode : $transaction_error : $transaction_errmsg:<br>" ;
						} else {
								#git commit
								//$auth_info=getAuthInfo(&$db, $auth_id);
								$cmd = "cd $cominf_test_repo_clone; $git commit -m \"created new ENV file $ENV_FILE_NAME, author= eeidle\""; //.
										//$auth_info['fname'] . " " . $auth_info['lname'] . " (" . $auth_info['signum'] . ")\" >> $gitlog 2>&1";
								system($cmd, $retcode);
								//print "$cmd $retcode : $transaction_error : $transaction_errmsg:<br>" ;
								if ( $retcode != 0 ) {
										$transaction_error=1;
										$transaction_errmsg="Failed to commit TS files";
								} else {
										#git push
										$cmd="cd $cominf_test_repo_clone; $git push >> $gitlog 2>&1";
										system($cmd, $retcode);
										if ( $retcode != 0 ) {
												$transaction_error=1;
												$transaction_errmsg="Failed to git push in workspace";
										}
								}

						}
				}
		}
		//some debugging
		print "<hr>";
		print "$cmd $retcode : $transaction_error : $transaction_errmsg:<br>" ;
		*/
		-->
	
		

</body></html>
