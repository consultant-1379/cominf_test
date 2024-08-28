<?
#
#
# general utils functions
#
# Dave Maxwell Medmedia 2007
#
#

include_once "cemployer.inc";
include_once "cvacancy.inc";

function getSectors(&$db) {
  $seclist = array();

  $sql = "SELECT id,name FROM employer_sectors";
  $res = &$db->doQuery($sql);
  while( $row =  mysql_fetch_object($res) ) {
    $seclist[$row->id] = $row->category;
  }

  asort($seclist);

  return $seclist;
}


function getCats(&$db) {
  $catlist = array();

  $sql = "SELECT id,category FROM categories";
  $res = &$db->doQuery($sql);
  while( $row =  mysql_fetch_object($res) ) {
    $catlist[$row->id] = $row->category;
  }

  asort($catlist);
  
  return $catlist;
}

#
# function to return number of vacancies in given category
#

function NumVacanciesInCat(&$db,$catid) {
  
  $sql = "SELECT COUNT(vacid) as numvacancies FROM category_lookup, vacancy_payments ";
  $sql .= "WHERE catid = $catid AND vacid = vacancy_payments.vacancyid";

  $res = &$db->doQuery($sql);
  $row =  mysql_fetch_object($res);
  $numvacancies = $row->numvacancies;
  return $numvacancies;

}

#
# function to get list of employers and ids
#

function getEmployers(&$db) {
  $emplist = array();
  $sql = "SELECT id,companyname FROM employer";
  $res = &$db->doQuery($sql);
  while( $row =  mysql_fetch_object($res) ) {
    $emplist[$row->id] = $row->companyname;
  }
  asort($emplist);
  return $emplist;
}

function NumVacanciesForEmployer(&$db,$empid) {
  $employer = new cEmployer(&$db);
  $employer->GetInfo($empid);
  $employer->LoadVacancies($empid);
  return $employer->NumOpenVacancies();
}

#
# function to get list of counties and ids
#

function getCounties(&$db) {
  $loclist = array();

  $sql = "SELECT id,name FROM counties";

  $res = &$db->doQuery($sql);
  while( $row =  mysql_fetch_object($res) ) {
    $loclist[$row->id] = $row->name;
  }

  asort($loclist);

  return $loclist;
}

function getCountyByID(&$db, $countyid) {
  $sql = "SELECT name FROM counties WHERE ID=$countyid";
  $res = &$db->doQuery($sql);
  $row =  mysql_fetch_object($res);
  return $row->name;
}

#
# function to get list of counties and ids
#

function getCountries(&$db) {
  $loclist = array();

  $sql = "SELECT id,name FROM countries";
  $res = &$db->doQuery($sql);
  while( $row =  mysql_fetch_object($res) ) {
    $loclist[$row->id] = $row->name;
  }

  asort($loclist);

  return $loclist;
}

function getCountryByID(&$db, $countryid) {
  $sql = "SELECT name FROM countries WHERE ID=$countryid";
  $res = &$db->doQuery($sql);
  $row =  mysql_fetch_object($res);
  return $row->name;
}

function NumVacanciesInLocation(&$db,$locid) {

  $sql = "SELECT COUNT(employerid) as numvacancies FROM vacancies,vacancy_payments ";
  $sql .= "WHERE locationid=$locid AND status='open' AND vacancies.id = vacancy_payments.vacancyid";

  $res = &$db->doQuery($sql);
  $row =  mysql_fetch_object($res);
  $numvacancies = $row->numvacancies;
  return $numvacancies;

}

function DisplayNice($text) {
  // Strip out carriage returns
  $newtext = htmlspecialchars($text);
  $newtext = ereg_replace("\r","",$text);
  // Handle paragraphs
  $newtext = ereg_replace("\n\n","<P>",$newtext);
  // Handle line breaks
  $newtext = ereg_replace("\n","<BR>",$newtext);
  
  return stripslashes($newtext);


}

function GetAdTypes(&$db) {
  $adinfo=array();
  $sql = "SELECT * from ad_types";

  $res = &$db->doQuery($sql);
  while( $row =  mysql_fetch_object($res) ) {
    $sub_array = array();
    $sub_array['id'] = $row->id;
    $sub_array['name'] = $row->name;
    $sub_array['duration'] = $row->duration;
    $sub_array['price'] = $row->price;
    $adinfo[] = $sub_array;
  }
  return $adinfo;
}

# form to pay for vacancy advert
#
function PrintPaymentForm(&$db, $vacid) {
  global $WEBSITE;
  if ( $WEBSITE['DEBUG'] == 1 )
      $text = "sandbox.";
  else
      $text="";
  $products = GetProductInfo(&$db);
  $vacobj = new cVacancy(&$db);
  $vacobj->GetInfo($vacid);
  $empid = $vacobj->employerid;
  echo "<p><strong>Display this vacancy for: </strong>\n";
  echo "<p><table border=0 cellspacing=0 cellpadding=10>\n";
  foreach( $products as $product ) {
    echo "<tr>\n";
    $numweeks  = $product['duration'] / 7;
    $str = $numweeks == 1 ? "week" : "weeks"  ;

    echo "<td valign=top>$numweeks $str\n";
    echo "<td valign=top>&euro;" . $product['price'] . "\n";
    $paypal_html = "<form action=\"https://www." . $text . "paypal.com/cgi-bin/webscr\" method=\"post\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"cmd\" value=\"_xclick\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"business\" value=\"" . $WEBSITE['payments_email'] . "\"\n";
    $paypal_html .= "<input type=\"hidden\" name=\"item_name\" value=\"" . $product['name'] . "\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"item_number\" value=\"" . $product['id'] . "\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"amount\" value=\"" . $product['price'] . "\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"no_shipping\" value=\"2\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"no_note\" value=\"1\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"currency_code\" value=\"EUR\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"lc\" value=\"IE\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"on0\" value=\"empid\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"os0\" value=\"$empid\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"on1\" value=\"vacid\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"os1\" value=\"$vacid\">\n";
    $paypal_html .= "<input type=\"hidden\" name=\"bn\" value=\"PP-BuyNowBF\">\n";
    $paypal_html .= "<input type=\"image\" src=\"https://www." . $text . "paypal.com/en_US/i/btn/x-click-but23.gif\" border=\"0\" name=\"submit\" alt=\"Make payments with PayPal - it's fast, free and secure!\">\n";
    $paypal_html .= "<img alt=\"\" border=\"0\" src=\"https://www." . $text . "paypal.com/en_US/i/scr/pixel.gif\" width=\"1\" height=\"1\">\n";
    $paypal_html .= "</form>\n";
   
    echo "<td valign=top>$paypal_html\n";
    echo "</tr>\n";
  }
  echo "<tr><td colspan=3 height=30 align=center><strong>=== or ===</strong></tr>\n";
  echo "<form name=\"payment\" method=post action=arrange_payment.php>\n";
  echo "<tr>\n";
  echo "<td colspan=2><input type=checkbox name=cscontact value=0>I wish to be contacted by <br> customer services to arrange payment.\n";
  echo "<td><input type=submit name=submit value='Continue>>'>\n";
  echo "</form>\n";
  echo "</tr>\n";
  echo "<tr><td colspan=3><br><br><strong>Note: </strong> Prices quoted are subject to VAT.</tr>\n";
  echo "</table>\n";
}

function UpdateVacancyPayments(&$db, $tx_id, $empid, $adid, $date_received)  {
  $sql = "INSERT INTO payments_received ";
  $sql .= "(transactionid, employerid, adid, date_received) ";
  $sql .= "VALUES('$tx_id', $empid, $adid, NOW())";
echo "<p>$sql\n";
  $res = &$db->doQuery($sql,0);
  $newid = mysql_insert_id();
  
  if ( $newid1 == -1  )
    return FALSE;
  else {
    #$sql = "UPDATE ads SET admin_enabled=1 WHERE id=$adid";
    #$res = &$db->doQuery($sql,0);
    return TRUE;
  }

}

function AddEllipses($string, $maxlen) {
  $string = trim($string);

  if ($maxlen <= 4) {
    return '';
  }

  // Guard against the first word + ... being longer then maxlen
  if (strpos($string, ' ') >= ($maxlen - 3)) {
    return substr($string, 0, $maxlen - 3) . '...';
  }

  $string = substr($string, 0, $maxlen);
  while (strlen($string) > ($maxlen - 3)) {
    $string = substr($string, 0, strrpos($string, ' '));
  }

  return $string . '...';

}

function generatePassword ($length = 8)
{

  // start with a blank password
  $password = "";

  // define possible characters
  $possible = "0123456789bcdfghjkmnpqrstvwxyz"; 
    
  // set up a counter
  $i = 0; 
    
  // add random characters to $password until $length is reached
  while ($i < $length) { 

    // pick a random character from the possible ones
    $char = substr($possible, mt_rand(0, strlen($possible)-1), 1);
        
    // we don't want this character if it's already in the password
    if (!strstr($password, $char)) { 
      $password .= $char;
      $i++;
    }

  }

  // done!
  return $password;

}

# get employer info for featured
# employers box
function getEmployerInfo(&$db,$num) {

  $sql = "SELECT id FROM employer ORDER BY RAND() LIMIT $num";
  $res = &$db->doQuery($sql,0);
  $emp_info=array();
  while( $row =  mysql_fetch_object($res) ) {
    $sub_info = array();
    $emp = new cEmployer(&$db);

    $emp->GetInfo($row->id);
    $emp->LoadAds();
    if ( $emp->company_logo_file != '' && $emp->NumCurrentAds() > 0 ) {
      $sub_info['empid'] = $emp->id;
      $sub_info['companyname'] = $emp->companyname;
      $sub_info['logofile'] = $emp->company_logo_file;
      $sub_info['profurl'] = "display_company_profile.php?employerid=$row->id";
      $emp_info[] = $sub_info;
    }
  }

  return $emp_info;
  
}

function PrintFeaturedEmployers(&$db) {
  global $WEBSITE;
  $NUMLOGOS=6;

  $emp_info = getEmployerInfo(&$db, $NUMLOGOS);
  echo "<div id=\"featured_employers\">\n";
  echo "<table width=165 border=0 cellspacing=0 cellpadding=0>\n";
  echo "<tr>\n";
  echo "<td background=\"images/feat_employ_top.gif\" style=\"font-weight:bold;color:#bd2025; padding:10px 0 10px 50px\">\n";
  echo "FEATURED<br>\n";
  echo "EMPLOYERS<br>\n";
  echo "</td>\n";
  echo "</tr>\n";
  echo "<tr>\n";
  echo "<td background=\"images/feat_employ_mid.gif\" style=\"font-weight:bold;color:#bd2025; padding:0 0 0 20px\">";
  echo "<table width=130 border=0 cellspacing=0 cellpadding=0>\n";
  $num_logos = count($emp_info);

#echo "<p>++$num_logos";
  $count=0;
  for ($i = 0; $i < $NUMLOGOS; $i++ ) {
    $info = $emp_info[$i];
    echo "<tr>\n";
    if ( $i > $num_logos - 1 )
      echo "<td align=center height=50 bgcolor=#003399 style=\"color:#FFFFFF\">LOGO\n";
    else
      echo "<td align=center><a href=\"view_ads_employer.php?empid=" . $info['empid'] ."\"><img width=130 height=50 border=0 alt=\""  . $info['companyname'] . "\" src=\"" . $WEBSITE['LOGODIRNAME'] . "/" . $info[logofile] . "\"></a>\n";
    echo "</tr>\n";
    echo "<tr><td><img height=10 src=\"images/spacer.gif\"></tr>\n";
  }
  echo "</table>\n";
  echo "</td>\n";
  echo "</tr>\n";
  echo "<tr>\n";
  echo "<td><img src=\"images/feat_employ_base.gif\" height=\"50\" width=\"165\">\n";
  echo "</tr>\n";
  echo "</table>\n";
  echo "</div>\n";
}

function DisplayMessage($mode,$html) {
  
  if ( $mode == "Fail" )
    $imgsrc="./images/fail.gif";
  else
    $imgsrc="./images/success.gif";

  echo "<table>\n";
  echo "<tr>\n";
  echo "<td><img src=\"$imgsrc\"></td>\n";
  echo "<td><strong>$html</strong></td>\n";
  echo "</tr>\n";
  echo "</table>\n";



}

function getAreaCodes(&$db, $type) {

  $sql = "SELECT * from area_codes WHERE type='$type' ORDER BY code";
  $res = &$db->doQuery($sql);
  $codes=array();
  $codes[0] = " ";
  while( $row =  mysql_fetch_object($res) ) {

    $codes[] = str_pad( $row->code, strlen($row->code)+1,0,STR_PAD_LEFT);
  }



  return $codes;

}


function resizeImage($width, $height, $maxdim) {
  if ( $width == 0 || $height == 0 ) return false;
  $newwidth=140;
  if ( $width <= $newidth )
    return array($width, $height);
  $newheight = floor($newwidth * ( $height / $width ));
  /*if ( $width > $height ) {
    $ratio = $height / $width;
    $newwidth = $maxdim;
    $newheight = floor($maxdim * $ratio);
  } else {
    $ratio = $width / $height;
    $newheight = $maxdim;
    $newwidth = floor($maxdim * $ratio);

  }*/
  return array($newwidth, $newheight);
}

 function DisplayLogo($logofile) {
    global $WEBSITE, $DOCUMENT_ROOT;
    $imgdirfile = $DOCUMENT_ROOT . "/" . $WEBSITE['LOGODIRNAME'] . "/" . $logofile;
    if ( ! file_exists($imgdirfile) )
      return "";
    list($width, $height, $type, $attr) = getimagesize("$imgdirfile");
    $newdims = resizeImage($width, $height, 100);
#echo "<p>" . $newdims[0] . "--" . $newdims[1];
    return "<img src=\"" . $WEBSITE['LOGODIRNAME'] . "/" . $logofile . "\" width=" . $newdims[0] . " height=" . $newdims[1] . " alt=\"\" border=0>\n";
  }

function mySQLToHumanDate($mysqldate) {
  # convert mysql date in form y-m-d h:m:s to d/m/y h:m:s
  if ( $mysqldate == '' ) return '';
  $toks = explode(" ", $mysqldate);
  $date = $toks[0];
  $time = $toks[1];

  $toks2 = explode("-", $date);
  $year = $toks2[0];
  $month = $toks2[1];
  $day = $toks2[2];

  $retstr = "$day-$month-$year";
  if ( $time != '' )
    $retstr .= " $time";

  return $retstr;


}


function humanToMysqlDate($humandate) {
  # convert mysql date in form d-m-y h:m:s to y-m-d h:m:s
  if ( $humandate == '' ) return '';
  $toks = explode(" ", $humandate);
  $date = $toks[0];
  $time = $toks[1];

  $toks2 = explode("-", $date);
  $day = $toks2[0];
  $month = $toks2[1];
  $year = $toks2[2];

  $retstr = "$year-$month-$day";
  if ( $time != '' )
    $retstr .= " $time";

  return $retstr;



}


?>
