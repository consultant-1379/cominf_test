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

	echo "<p>";
	$errmsg  = "Error Number: $errnum<br>\n";
	$errmsg .= "Description: $errmsgs[$errnum]<br>\n";
	$errmsg .= "Additional Info: $msg<br>\n";
	$errmsg .= "Module: $module at line $line</p>";
	echo $errmsg;
	echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Back home</a>\n";
	exit;
}

function Warning($message) {

  echo "<table border=0 cellspacing=0 cellpadding=10>\n";
  echo "<tr>\n";
  echo "<td>(WARN)<td><strong>$message</strong>\n";
  echo "</tr>\n";
  echo "</table>\n";

}

