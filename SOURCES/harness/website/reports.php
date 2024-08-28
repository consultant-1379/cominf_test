<?php
include_once "inc/chtmlform.inc";
include_once "inc/globals.inc";
include_once "inc/error.inc";
include_once "inc/cdatabase.inc";
$db = &new cDatabase;
include "header.php";
echo "<p><a href=http://" . $WEBSITE['HOMEURL'] . ">Home</a>&gt;<a href=harness.php>Harness</a>&gt;Reports\n";
?>



<p><a href="generate_testspec.php">Generate Test Spec</a>

<?php
include "footer.php"
?>
