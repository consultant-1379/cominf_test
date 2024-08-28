<?php
include_once "inc/globals.inc";
include_once "inc/error.inc";
include_once "inc/cdatabase.inc";
$db = &new cDatabase;
echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">";
echo "<html xmlns=\"http://www.w3.org/1999/xhtml\">";

echo "<head>\n";
echo "<title>" . $WEBSITE['Name'] . "</title>\n";
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/harness.css\">\n";
echo "</head>\n";
echo "<body>\n";
