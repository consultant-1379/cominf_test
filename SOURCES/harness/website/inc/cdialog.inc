<?php
#
#
#
#

class cDialogBox {
  var $type;
  var $message;
  var $buttonList=array();
  var $urlList=array();

  function cDialogBox($type, $message, $buttonList, $urlList) {
    $this->type = $type;
    $this->message = $message;
    $this->buttonList = $buttonList;
    $this->urlList = $urlList;
    $this->Draw();
  }

  function Draw() {
    $imageurl="images/question-icon1.gif";
    $numbuttons = count($this->buttonList);
    echo "<br>\n";
    echo "<br>\n";
    echo "<br>\n";
    echo "<br>\n";
    echo "<center>\n";
    echo "<table border=0 cellspacing=0 cellpadding=0>\n";
    echo "<tr>\n";
    #echo "<td><img src=$imageurl>\n";
    echo "<td>$this->message\n";
    echo "<tr>\n";
    echo "<tr><td>&nbsp;</tr>\n";
    echo "<td align=center>\n";
    echo "<form>\n";
    $count=0;
    foreach( $this->buttonList as $button ) {
      $url = $this->urlList[$count]; 
      echo "<input type=button name=\"$button\" value=\"$button\" onClick=\"parent.location='$url'\">\n";
      $count++;
    }
    echo "</form>\n";
    echo "</tr>\n";
    echo "</table>\n";
    echo "</center>\n";
  }
}




?>

