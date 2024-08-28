<?php

class TextField {

	var $type = 'TextField';
	var $label = '';
	var $name = '';
	var $value = '';
	var $note = '';
	var $len = 10;
	var $maxlen = 0;
	var $errmsg = '';
	var $password = false;

	function TextField($label, $name, $type, $value = '' , $note = '', $len = 10, $maxlen = 0, $errmsg = '', $helpurl='') {

		$this->label = $label;
		$this->name = $name;
		$this->value = $value;
		$this->note = $note;
		$this->len = $len;
		$this->maxlen = $maxlen;
		$this->errmsg = $errmsg;
		$this->type = $type;
    $this->helpurl = $helpurl;

	}

	function Draw() {

		echo "<tr style=\"height: 20px\">\n";
		$lbl = htmlentities($this->label);
		$lbl = str_replace("\n", "<br>", $lbl);
		echo "<td nowrap class=\"formlabel\">$lbl";
    if ($this->helpurl != '') {
      echo "<span class=\"helptext\">\n";
      echo "<a href=\"Javascript:void windowOpener('$this->helpurl', 'mywindow','width=600,height=500,resizable=1,scrollbars=1')\">(More info)</a>\n";
      echo "</span>\n";
    }
    echo "</td>\n";
		echo "<td class=\"formfield\">\n";
		echo "<input class=\"textfield\" type=\"$this->type\" name=\"$this->name\" size=\"$this->len\" ";
		if ($this->maxlen > 0) {
			echo "maxlength=\"$this->maxlen\" ";
		}
		echo "value=\"" . htmlentities($this->value) . "\">\n";
		if ($this->note != '') {
			echo "<br><span class=\"fieldnote\">" . $this->note . "</span>\n";
		}
		if ($this->errmsg != '') {
			echo "<br><span class=\"fielderror\">" . $this->errmsg . "</span>\n";
		}
		echo "</td>\n";
		echo "</tr>\n";

	}

}

class TextFieldWithButton extends TextField {
  var $button;
  function TextFieldWithButton($label, $name, $value = '' , $note = '', $len = 10, $maxlen = 0, $errmsg = '', $buttonname, $buttonvalue, $imageurl='', $onclick='' ) {
     parent::TextField($label, $name, $value, $note, $len, $maxlen, $errmsg);
     $this->button = new Button($buttonname, $buttonvalue, 'button', $imageurl, $onclick); 
  }
  function Draw() {
    echo "<tr style=\"height: 20px\">\n";
    $lbl = htmlentities($this->label);
    $lbl = str_replace("\n", "<br>", $lbl);
    echo "<td class=\"formlabel\">$lbl</td>\n";
    echo "<td class=\"formfield\">";
    echo "<input class=\"textfield\" type=\"text\" name=\"$this->name\" size=\"$this->len\" ";
    if ($this->maxlen > 0) {
	echo "maxlength=\"$this->maxlen\" ";
    }
    echo "value=\"" . htmlentities($this->value) . "\">";
    $this->button->Draw();
    if ($this->note != '') {
      echo "<br><span class=\"fieldnote\">" . htmlentities($this->note) . "</span>";
    }
    if ($this->errmsg != '') {
      echo "<br><span class=\"fielderror\">" . $this->errmsg . "</span>";
    }
    echo "</td>\n";
    echo "</tr>\n";
  }
}

class SelectList {

	var $type = 'SelectList';
  var $size=0;  // size = 0 implies dropdown 
  var $multiple=0;
	var $label = '';
	var $name = '';
	var $sel_values = array();
	var $note = '';
	var $errmsg = '';
	var $values = array();    // Parallel Associated w/ $options
	var $options = array();
  	var $db;
  	var $onchange='';
	var $select_styleinfo='';
	var $row_styleinfo='';	
	var $ondbclick='';

	function SelectList(&$db, $label, $name, $sel_values, $note = '', $errmsg = '', $size=0, $multiple=0, $onchange='', $row_styleinfo='', $select_styleinfo='', $ondbclick='') {

		$this->label = $label;
		$this->name = $name;
    		if ( count($sel_values) > 0 )
		  $this->sel_values = $sel_values;
		$this->note = $note;
		$this->errmsg = $errmsg;
                $this->size = $size;
                $this->multiple = $multiple;
                $this->db = &$db;
    		$this->onchange = $onchange;
    		$this->ondbclick = $ondbclick;
    		$this->row_styleinfo = $row_styleinfo;
    		$this->select_styleinfo = $select_styleinfo;

	}

	function AddOptions($options, $values) {

		$this->options = $options;
		$this->values = $values;

	}


	function SetDBOptions($table, $valuefield, $optionfield, $whereclause = '', $orderclause = '', $firstitem = '') {

		$sql  = "select $valuefield as val, $optionfield as opt from $table ";
		if ($whereclause != '') {
			$sql .= "where $whereclause ";
		}
		if ($orderclause != '') {
			$sql .= "order by $orderclause";
		}
    		$result = &$this->db->doQuery($sql);
		$index = 0;
		if (is_array($firstitem) and sizeof($firstitem) >= 2) {
			$this->values[$index] = $firstitem[0];
			$this->options[$index] = $firstitem[1];
			$index++;
		}
		while ($row = mysql_fetch_object($result)) {
			$this->values[$index] = $row->val;
			$this->options[$index] = $row->opt;
			$index++;
		}

	}
	

	function Draw() {

		echo "<tr $this->row_styleinfo>\n";
		$lbl = htmlentities($this->label);
		$lbl = str_replace("\n", "<br>", $lbl);
		echo "<td class=\"formlabel\">$lbl"; 
    echo "</td>\n";
		echo "<td class=\"formfield\">\n";
                if ( $this->size > 0 )
                  $sizestr = "SIZE=$this->size";
                else
                  $sizestr='';
                if ( $this->multiple == 1 )
                  $multstr = "multiple";
                else
                  $multstr = '';
		echo "<select name=\"$this->name\" $sizestr $multstr onChange=\"$this->onchange\" ondblclick=\"$this->ondbclick\" $this->select_styleinfo>\n";
		$max = sizeof($this->values);
		for ($i = 0; $i < $max; $i++) {
                        $idx2=array_search($this->values[$i], $this->sel_values);
                        if ( strcmp($idx2,'') == 0 ) {
                          $selected = "";
                        }
                        else
                          $selected = " selected";

			echo "<option value=\"" . htmlentities($this->values[$i]) . "\"$selected>";
			echo $this->options[$i];
			echo "</option>\n";
		}
		echo "</select>\n";
		if ($this->note != '') {
			echo "<br><span class=\"fieldnote\">" . htmlentities($this->note) . "</span>";
		}
		if ($this->errmsg != '') {
			echo "<br><span class=\"fielderror\">" . htmlentities($this->errmsg) . "</span>";
		}
		echo "</td>\n";
		echo "</tr>\n";

	}
	function sprintf_nbsp() {
		$args = func_get_args();
		return str_replace(' ', '&nbsp;', vsprintf(array_shift($args), array_values($args)));
	}


}


class Button {

        var $name;
        var $value;
	var $imageurl = '';
	var $onclick = '';
	var $type = 'button';

	function Button($name, $value, $type='button', $imageurl='', $onclick='') {

		$this->name = $name;
		$this->value = $value;
		$this->imageurl = $imageurl;
		$this->onclick = $onclick;
		$this->type = $type;
	}

	function Draw() {

                if ( $this->imageurl == '' )
		  echo "<input type=\"$this->type\" name=\"$this->name\" value=\"$this->value\" onclick=\"$this->onclick\">\n";
                else
		  echo "&nbsp;&nbsp;<img src=\"$this->imageurl\" style=\"cursor: pointer\" onclick=\"$this->onclick\" alt=\"$this->name\">\n";
 

	}

}

class CheckBox {
  var $name;
  var $label;
  var $errmsg;
  var $value;
  var $sel_value;
  var $value_checked;
  var $disabled=FALSE;
  var $note;
  var $javascript;

  function Checkbox( $name, $label, $value, $sel_value, $errmsg, $note='', $javascript='' ) {
    $this->name = $name;
    $this->value = $value;
    $this->sel_value = $sel_value;
    $this->errmsg = $errmsg;
    $this->label = $label;
    $this->note=$note;
    $this->javascript=$javascript;
  }

  function Draw() {
    if ( $this->value == $this->sel_value )
      $checked = "checked";
    else
      $checked = "";
    echo "<tr>\n";
    echo "<td colspan=2 class=\"formfield\"><input type=\"checkbox\" name=\"$this->name\" value=\"$this->value\" $checked $this->javascript style=\"border:0; background: transparent;\">$this->label\n";
    if ( $this->errmsg != '' )
      echo "<br><span class=\"fielderror\">$this->errmsg</span>\n";
    if ($this->note != '') {
			echo "<br><span class=\"fieldnote\">" . htmlentities($this->note) . "</span>";
		}
    echo "</td>\n";
    echo "</tr>\n";
    
  }


}

class OptionList {

	var $type = 'checkbox';
        var $name;
        var $label;
        var $rows=1;
        var $options = array() ;
        var $checked_values = array();
        var $texts = array() ;
	var $errmsg = '';
	var $note = '';
	  var $javascript;

        # types: checkbox, radio

        function OptionList($type, $name, $label, $options_arr, $checked_values, $errmsg='', $note='',$javascript='') {

          $this->type = $type;
          $this->name = $name;
          $this->options = $options_arr;
          if ( count($checked_values) > 0 )
            $this->checked_values = $checked_values;
          $this->errmsg = $errmsg;
          $this->note = $note;
          $this->label = $label;
		      $this->javascript=$javascript;
        }


        function Draw() {
		global $WEBSITE;
    		echo "<tr>\n";
		echo "<td class=\"formlabel\">$this->label";
		echo "<td class=\"formfield\">\n";
		foreach ($this->options as $text => $value) {
			$text = htmlentities($text);
			$idx2=array_search($value, $this->checked_values);
			if ( strcmp($idx2,'') == 0 ) {
				$checked = "";
			} else {
				$checked = "checked";
			}
			echo "<input type=\"$this->type\" name=\"$this->name\" value=\"$value\" $checked $this->javascript style=\"border:0; background: transparent;\">$text\n";

                }
		if ( $this->errmsg != '' )
			echo "<br><span class=\"fielderror\">$this->errmsg</span>\n";
		if ($this->note != '') 
			echo "<br><span class=\"fieldnote\">" . htmlentities($this->note) . "</span>";
		echo "</tr>\n";
        }

}

class TextArea {
  var $label;
  var $name;
  var $value;
  var $note;
  var $rows;
  var $cols;
  var $errormsg;

  function TextArea($label, $name, $value, $note, $rows, $cols, $errmsg) {
    $this->label = $label;
    $this->name = $name;
    $this->value = $value;
    $this->note = $note;
    $this->rows = $rows;
    $this->cols = $cols;
    $this->errormsg = $errmsg;
  }

  function Draw() {
    echo "<tr>\n";
    echo "<td class=formlabel>$this->label\n";
    echo "<td class=formfield><textarea id=\"$this->name\" rows=$this->rows cols=$this->cols name=$this->name>$this->value</textarea>\n";
    if ( $this->note != '' ) {
      echo "<br><span class=\"fieldnote\">$this->note</span>\n";
    }
    if ( $this->errormsg != '' ) {
      echo "<br><span class=\"fielderror\">$this->errormsg</span>\n";
    }
    echo "</tr>\n";
  }
}

class Hidden {

	var $name = '';
	var $value = '';

	function Hidden($name, $value) {
		$this->name = $name;
		$this->value = $value;
	}

	function Draw() {
		echo "<input type=\"hidden\" name=\"" . htmlentities($this->name) . "\" value=\"" . htmlentities($this->value) . "\">\n";
	}

}

# insert HTML into form table;
class NonEditableField {
  var $html;
  
  function NonEditableField($html) {
    $this->html = $html;
  }

  function Draw() {
     echo "<tr><td colspan=2 class=\"formfield\">$this->html</tr>\n";

   
  }


}

# insert custom HTML into form table;
class CustomHTML {
  var $html;

  function CustomHTML($html) {
    $this->html = $html;
  }

  function Draw() {
     echo "<tr><td colspan=2 class=\"formfield\">$this->html</tr>\n";
  }

}


class Divider {

  function Draw() {

    echo "<tr><td colspan=2><hr></tr>\n";

  }


}
   

class HtmlForm {

	var $name = '';
	var $method = 'POST';
	var $action = '';
	var $width = 400;
        var $enctype = '';
	var $onsubmit = '';

	var $fields = array();
	var $buttons = array();
	var $hiddens = array();

	function HtmlForm($name, $enctype, $action = '', $width = 400, $onsubmit = '') {

		$this->name = $name;
		$this->enctype = $enctype;
		$this->action = $action;
		$this->width = $width;
		$this->onsubmit = $onsubmit;

	}

	function AddField($object) {

		$this->fields[] = $object;

	}

	function AddButton($object) {

		$this->buttons[] = $object;

	}

	function AddHidden($object) {

		$this->hiddens[] = $object;

	}

	function Draw() {

		echo "<form name=\"$this->name\" enctype=\"$this->enctype\" method=\"$this->method\" action=\"$this->action\" $this->onsubmit>\n";
		
		if ($this->width == "maxw" ) {
			echo "<table border=\"0\" id=\"maxw\" >\n";
		} else if ( $this->width="maxwh" ) {
			echo "<table border=\"0\" id=\"maxwh\" >\n";
		} else {
			echo "<table border=\"0\" width=\"$this->width\" >\n";
		}
		$max = sizeof($this->hiddens);
		if ($max > 0) {
			for ($i = 0; $i < $max; $i++) {
				$this->hiddens[$i]->Draw();
			}
		}
		$max = sizeof($this->fields);
		for ($i = 0; $i < $max; $i++) {
			$this->fields[$i]->Draw();
		}

		$max = sizeof($this->buttons);
		if ($max > 0) {
			echo "<tr style=\"height: 50px\">\n";
			echo "<td align=\"center\" colspan=\"2\">\n";
			for ($i = 0; $i < $max; $i++) {
				$this->buttons[$i]->Draw();
			}
			echo "</td>\n";
			echo "</tr>\n";
		}
		echo "</table>\n";
		echo "</form>\n";
	}

}

?>
