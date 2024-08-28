<?php

function FatalError($errnum, $msg, $module, $line) {
        global $WEBSITE;

	$errmsgs[100] = "Unable to make a connection to the database server.";
	$errmsgs[101] = "SQL select failed.";
	$errmsgs[102] = "SQL insert or update failed.";
	$errmsgs[103] = "SQL delete failed.";
	$errmsgs[104] = "File could not be opened.";
	$errmsgs[105] = "See additional info.";
	$errmsgs[106] = "Unable to select database.";
	$errmsgs[107] = "Unable to send email.";

	echo "<p>An error has occured and your request has been terminated. ";
	echo "Please try again later. If this condition persists please ";
	echo "let us know by clicking <a href=\"mailto:" . $WEBSITE['ADMIN'] . "\">here</a>\n"; 

	echo "<p>";
	$errmsg  = "Error Number: $errnum<br>\n";
	$errmsg .= "Description: $errmsgs[$errnum]<br>\n";
	$errmsg .= "Additional Info: $msg<br>\n";
	$errmsg .= "Module: $module at line $line</p>";
	echo $errmsg;
	if (!$fd = @fopen("/var/log/site-error_log", "a")) {
		exit;
	}
	$logmsg = "$msg\t$module\t$line\t";
	$date = date("Y-m-d H:i:s");
	$logmsg .= "$date\n";
	@fwrite($fd, $logmsg);
	@fclose($fd);
	exit;
}

function Warning($message) {

  echo "<table border=0 cellspacing=0 cellpadding=10>\n";
  echo "<tr>\n";
  echo "<td>(WARN)<td><strong>$message</strong>\n";
  echo "</tr>\n";
  echo "</table>\n";

}

