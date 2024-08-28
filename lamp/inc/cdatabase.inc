<?php
include_once "error.inc";
class cDatabase  {

	var $hostname = "localhost";   // Hostname
	var $database = "cominf_test_harness";          // Overall site content database
	var $username = "jenkins";     // User name for database access purposes
	var $password = "shroot";     // Password for database access purposes
	var $mode = "";                // Operating mode

	function cDatabase() {

		global $HTTP_USER_AGENT, $REQUEST_URI, $WEBROOT, $login_required;

		if (!mysql_pconnect($this->hostname, $this->username, $this->password)) {
			die("Unable to find/connect to the database server.");
		}

		if (!mysql_select_db($this->database)) {
			die("The irishhealth jobsite database is not available.");
		}
                #echo "<p>Successfully connected to database";

       }

       function doQuery( $sql, $quitonfail=1 ) {
         if (!$result = mysql_query($sql)) {
           if ( $quitonfail == 1 ) {
             echo "<p>Query: $sql</p>\n";
             FatalError(101, mysql_error(), __FILE__, __LINE__);
           } else
             return FALSE;
         }
         return $result;
       }

}

?>
