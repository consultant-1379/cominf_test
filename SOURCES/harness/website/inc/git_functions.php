<?php 
	//global variable definitions.
	$git = "/usr/bin/git"; 
	$gitlog = "/var/log/gitlog";
	//function definions
	/* 	Perform git pull on the $cloned_repo_path
		Function returns a boolean result. Calling script must check for and deal with
		a FALSE(ERROR)	return value.
	*/
	function git_pull($cloned_repo_path){
		global $git;
		global $gitlog;
		$transaction_error = 0;
		$transaction_errmsg="";
		// Exit if GIT is not installed
		if ( ! is_executable ($git) ) {
				FatalError(105,'git is not installed or executable on server', __file__, __line__);
				return FALSE;
		}
		// git pull
		$cmd="cd $cloned_repo_path; { date; time $git pull; } >> $gitlog  2>&1";
		system($cmd, $retcode);
		//some debugging
		if ( $retcode != 0 ) {
			$transaction_error=1;
			$transaction_errmsg="Failed to git pull in $cloned_repo_path";
			print "<hr>";
			print "ERROR:$cmd ;return code = $retcode : $transaction_error : $transaction_errmsg:<br>" ;
			return FALSE;
		} else {
			return TRUE;
		}
		
	}
	/* commit an push updates to the git master repository. This should be done after 
		any files are edited to ensure all users are working off the latest file.
		Function returns a boolean result. Calling script must check for and deal with
		a FALSE(ERROR)	return value.
		Note: should really split this into two functions git_commit and git_push.
	*/	
	function git_commit ($cloned_repo_path,$filename) {
		global $git;
		global $gitlog;
		$transaction_error = 0;
		$transaction_errmsg="";
		$cmd = "cd $cloned_repo_path; $git add $filename "; //.
		system($cmd, $retcode);
			if ( $retcode != 0 ) {
				$transaction_error=1;
				$transaction_errmsg="Failed to git add $filename";
				exit ("ERROR:" .  addslashes($cmd) . "; return code = $retcode : $transaction_errmsg:<br>");
				system(id);
				return FALSE;
			}
		//needs to be changed to select author from mysql and commit with author id.
		// build cmd variable for git commit.
		$cmd = "cd $cloned_repo_path; { date; time $git commit -m \"saved $filename \"; } "; //.
		system($cmd, $retcode);
		if ( $retcode != 0 ) {
			$transaction_error=1;
			$transaction_errmsg="Failed to git commit $filename";
			exit ("ERROR:" .  addslashes($cmd) . "; return code = $retcode : $transaction_errmsg:<br>");
			system(id);
			return FALSE;
		} else {
			#git push
			$cmd="cd $cloned_repo_path; { date; time $git push; } >> $gitlog 2>&1";
			system($cmd, $retcode);
			if ( $retcode != 0 ) {
				$transaction_error=1;
				$transaction_errmsg="Failed to git push in workspace";
				exit ("ERROR:$cmd ;return code = $retcode : $transaction_error : $transaction_errmsg:<br>") ;
				return FALSE;
			} else {
				return TRUE;
			}
		}
	}
?>
