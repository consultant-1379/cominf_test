<?php
#
# script to display usecases
#
#	Apr 2012 edavmax
include "header.php";

echo "<h1>Usecases</h1>\n";

echo "<p><a href=usecase.php?mode=new>Create new usecase</a>\n";

echo "<p>Click on a usecase to view associated testcases.\n";

$sql = "SELECT funcarea.name AS fa_name,usecase.name AS uc_name, usecase.id AS uc_id FROM funcarea, usecase WHERE funcarea.id=usecase.fa_id ORDER BY fa_name, uc_name";
$result = &$db->doQuery($sql);

if (mysql_num_rows($result) > 0 ) {
	$new_list=TRUE;
	$last_fa_name="";
	while ( ($row =  mysql_fetch_object($result)) ) {
		$fa_name=$row->fa_name;
		$uc_id = $row->uc_id;
		$uc_name=$row->uc_name;
		if ( $fa_name != $last_fa_name ) {
			if ( $last_fa_name != "" )
				echo "</ul>\n";
			echo "<h3>" . $fa_name . "</h3>\n";
			echo "<ul>\n";
		}
		echo "<li><a href=testcases.php?uc_id=" . $uc_id . ">" . $uc_name . "</a>\n";
		echo "&nbsp&nbsp&nbsp<a href=usecase.php?mode=view&uc_id=" . $uc_id . ">View</a>\n"; 
		echo "| <a href=usecase.php?mode=edit&uc_id=" . $uc_id . ">Edit</a>\n"; 
		echo "| <a href=usecase.php?mode=delete&uc_id=" . $uc_id . ">Delete</a>\n"; 
		$last_fa_name=$fa_name;
	}
	echo "</ul>\n";
} else {
	echo "<p>No usecases found";

}

include "harness_footer.php"
?>
