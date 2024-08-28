<?php
include_once "error.inc";
class cDatabase {
	var $hostname = "localhost";   // Hostname
	var $database = "platform_test_harness_ddc";          // Overall site content database
	var $username = "cominfci";     // User name for database access purposes
	var $password = "P7Tkm85M";   
	var $mode = "";                // Operating mode
	function cDatabase() {

                global $HTTP_USER_AGENT, $REQUEST_URI, $WEBROOT, $login_required;

                if (!mysql_pconnect($this->hostname, $this->username, $this->password)) {
                        die("Unable to find/connect to the database server.");
                }

                if (!mysql_select_db($this->database)) {
                        die("Platform test harness db is not available.");
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
	
class cDatabasei  {

	var $hostname = "localhost";   // Hostname
	var $database = "platform_test_harness_ddc";          // Overall site content database
	var $username = "cominfci";     // User name for database access purposes
	var $password = "P7Tkm85M";   
	var $mode = "";                // Operating mode
	var $mysqli_link="";

	function cDatabasei() {

		global $HTTP_USER_AGENT, $REQUEST_URI, $WEBROOT, $login_required;
		$mysqli_link = new mysqli($this->hostname, $this->username, $this->password, $this->database);
		if ($mysqli_link->connect_errno) {
    			echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
		}
		$this->mysqli_link=$mysqli_link;


		#if (!mysql_pconnect($this->hostname, $this->username, $this->password)) {
			#die("Unable to find/connect to the database server.");
		#}
                #echo "<p>Successfully connected to database";

       }
       function doQuery( $sql, $quitonfail=1 ) {
         if (!$result = mysqli_query($this->mysqli_link, $sql)) {
           if ( $quitonfail == 1 ) {
             echo "<p>Query: $sql</p>\n";
             FatalError(101, mysql_error(), __FILE__, __LINE__);
           } else
             return FALSE;
         }
         return $result;
       }

	function getLink(){
		return $this->mysqli_link;
	}

}

?>
