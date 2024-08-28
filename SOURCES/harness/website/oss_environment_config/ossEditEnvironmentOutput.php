<?php
	include_once "../inc/globals.inc";
	include 'header.php'; 
	include_once "../inc/git_functions.php";
	echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Home</a>&gt;<a href=../harness.php>Harness&gt;</a><a href=\"ossenvfiles.php\">Select Environment File&gt;</a><br><hr>";

			/* 	precondition: all input type now contain correct values. therefore array contains all 
				1 read all the elements in the array
			*/
	$CI_ADMIN2_HOSTNAME = ""; // setting variable so as not to generate undefined var for SPARC
	function submitForm($cloned_repo_path, $filename, $envarray) {
	global $ENV_FILE_PATH; //remove me
		$fh = fopen($ENV_FILE_PATH . $filename, 'w') or die("can't open file");
		//debug:$stringData = "#########\n";
		foreach ($envarray as $key => $value) {
			$stringData = "$key=$value";
			fwrite($fh, $stringData);
		}
		fclose($fh);
		$gitCmdResult = git_pull($cloned_repo_path);
		if ( $gitCmdResult == FALSE ) {
			print "<h1>ERROR: git pull failed on repo $cloned_repo_path. Updates to $filename aborted!</h1><br>";
			
		} else if ( $gitCmdResult == TRUE ) {	
			$gitCmdResult=git_commit($cloned_repo_path,$filename);
			if ( $gitCmdResult == FALSE ) {
				print "<h1>ERROR: git commit or push failed on repo $cloned_repo_path. Updates to $filename aborted!</h1><br>";
			} else if ( $gitCmdResult == TRUE ) {
				print "<h1>Success: git push from repo $cloned_repo_path is successful. Updates to $filename complete!</h1><br>";
			}
		}
	}
	/* MAIN
	*
	*
	*/
		$ENV_FILE_PATH=$_POST['ENV_FILE_PATH'];
		$ENV_FILE_NAME=$_POST['ENV_FILE_NAME'];
		print "<em><b>File name is :</b> $ENV_FILE_NAME</em><br>";
		print "<em><b>File path is :</b> $ENV_FILE_PATH</em><br>";
		echo "<br><hr>";

		//need to unserialize and decode the hidden array containing unsupported variables.
		$unsupported_variables=unserialize(base64_decode($_POST['unsupported_variables']));
		$fh = fopen($ENV_FILE_PATH . $ENV_FILE_NAME, 'w') or die("can't open file");
		$stringData = "#!/bin/bash\n";
		fwrite($fh, $stringData);
		foreach ($_POST as $key => $value) {
			$stringData = "$key=$value\n";
			if (  ( $key != "unsupported_variables" ) && ( $key != "ENV_FILE_PATH" ) && ( $key != "ENV_FILE_NAME" )) {
				fwrite($fh, $stringData);
			}
		}
		//below are variables not covered by the web page and must be handled separately
		$stringData = "CI_MWS_JUMP=YES\n";  				// always YES when calling master_wrapper from here
		fwrite($fh, $stringData);		
		$stringData = "CI_PRE_INI=YES\n"; 					// always YES when calling master_wrapper from here
		fwrite($fh, $stringData);		
		$stringData = "CI_DMR=NO\n"; 						// always NO when calling master_wrapper from here, Separate test case configures DMR
		fwrite($fh, $stringData);
		if ( $CI_ADMIN2_HOSTNAME != null) {
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
		$stringData = "CI_SERVER_IP[0]=\${CI_ADMIN1_IPV4_ADDRESS}\n";
		fwrite($fh, $stringData);	
		$stringData = "CI_SERVER_INST_TYPE[0]=system\n";    //refactor required to replace this variable
		fwrite($fh, $stringData);	
		$stringData = "CI_SERVER_CONFIG[0]=system\n"; 		//refactor required to replace this variable
		fwrite($fh, $stringData);	
		$stringData = "CI_SERVER_ROOTPW[0]=shroot\n";		//refactor required to replace this variable
		fwrite($fh, $stringData);	
		$stringData = "\n";
		fwrite($fh, $stringData);	
				
		$stringData = "#Unsupported Variables\n";
		fwrite($fh, $stringData);
		foreach ($unsupported_variables as $key => $value ) {
			$stringData = "$key=$value\n";
			fwrite($fh, $stringData);
		}
		fclose($fh);

		$fh = fopen($ENV_FILE_PATH . $ENV_FILE_NAME, 'r'); // read current file
			while ($line = fgets($fh)) {
				print "$line <br>"  ; 
		}
		fclose($fh);
		echo "<br><hr>";

		if ( ! git_pull($ENV_FILE_PATH)) {
			exit ("ERROR:Unsuccessful git_pull.  Function returned with a failure.<br> " );
		}
		print "git pull successful<br>";
		if ( ! git_commit($ENV_FILE_PATH,$ENV_FILE_NAME)) {
			exit ("ERROR:Unsuccessful git add/commit/pull. Function returned with a failure. <br>" );
		}
		print "git push successful<br>";
		echo "<br><hr>";
		/*echo "<br>debug<br>";
		var_dump($_POST);
		*/
?>