// create global variables
var xmlhttp;
var ValidIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
var ValidHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";;
var i386;
var SPARC;
var message;

// init function runs when page has fully loaded
function init() {
	console.log(window); // log a message to the JavaScript console
	document.getElementById("i386").checked=false
	document.getElementById("SPARC").checked=false
}
//display x86 Specific form elements: requires file called displayX86.txt 
function displayX86() {
	i386 = document.getElementById("i386");
	message = document.getElementById("message");
	var architecture = "X86";
	loadFile(architecture);
}
//display SPARC Specific form elements: requires file called displaySPARC.txt
function displaySPARC() {
	SPARC = document.getElementById("SPARC");
	message = document.getElementById("message");
	var architecture = "SPARC";
	loadFile(architecture);
}
/*not used yet.
function getEnvFileName(envFilePathObj,envFileNameObj) {
	console.log(window);
	echo envFilePathObj.value;
	echo "envFileNameObj.value";
}
*/
// initialize variables and add event listening functions
function temp_init() {
	i386 = document.getElementById("i386");
	//SPARC = document.getElementById("SPARC");
	message = document.getElementById("message");
	i386.onclick = displayX86;
	SPARC.onclick = displaySPARC;checkButtons();
	loadFile();
}
// load message files using Ajax
function loadFile(architecture) {
	var file = "display" + architecture + ".txt";
	xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = responseReady;
	xmlhttp.open("GET",file,false);
	xmlhttp.send();
}
// add Ajax loaded content to paragraph on the page
function responseReady() {
	message.innerHTML=xmlhttp.responseText;
}
/*	Take in the input field for the IP address along with a help text and validate the IP Address
	if the IP Address is invalid then echo this information to the user
*/
function readX86Variables() {
				
				/*//message2 = document.getElementById("restOfEditValues");
				//xmlhttp = new XMLHttpRequest();
				//xmlhttp.onreadystatechange = responseReady;
				document.getElementById("ci_admin1_ipv4_address").value = <?php echo $env_current_array['CI_ADMIN1_IPV4_ADDRESS']; ?>;
				document.getElementById("ci_admin2_ipv4_address").value = "<?php echo $env_current_array['CI_ADMIN2_IPV4_ADDRESS']; ?>";
				*/
}
function validateIpAddress(IPAddressObj,helpText){  
    var ValidIP = false;   

    ipParts = IPAddressObj.value.split(".");  
    if (ipParts.length==4){  
		for (i=0;i<4;i++){  
          
			TheNum = parseInt(ipParts[i]);  
			if (TheNum >= 0 && TheNum <= 255){}  
			else {
				helpText.innerHTML = "Please Enter a Valid IP Address";
				break;
			}    
		}  
		if (i==4) {
			ValidIP=true;  
			helpText.innerHTML = "";
		
		}  
		if (ValidIP != true) {
			//alert(ValidIP);  
		}
	}
	else {
		helpText.innerHTML = "Please Enter a Valid IP Address";
	} 
}
	//Function to simulate the onclick event. Courtesy of Stackoverflow
	/*You can use it like this:

		simulate(document.getElementById("btn"), "click");

		Note that as a third parameter you can pass in 'options'. The options you don't specify are taken from the defaultOptions (see bottom of the script).
		So if you for example want to specify mouse coordinates you can do something like:

		simulate(document.getElementById("btn"), "click", { pointerX: 123, pointerY: 321 })

		You can use a similar approach to override other default options.

		Credits should go to kangax.
	*/
    function simulate(element, eventName)
    {
        var options = extend(defaultOptions, arguments[2] || {});
        var oEvent, eventType = null;

        for (var name in eventMatchers)
        {
            if (eventMatchers[name].test(eventName)) { eventType = name; break; }
        }

        if (!eventType)
            throw new SyntaxError('Only HTMLEvents and MouseEvents interfaces are supported');

        if (document.createEvent)
        {
            oEvent = document.createEvent(eventType);
            if (eventType == 'HTMLEvents')
            {
                oEvent.initEvent(eventName, options.bubbles, options.cancelable);
            }
            else
            {
                oEvent.initMouseEvent(eventName, options.bubbles, options.cancelable, document.defaultView,
          options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY,
          options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, element);
            }
            element.dispatchEvent(oEvent);
        }
        else
        {
            options.clientX = options.pointerX;
            options.clientY = options.pointerY;
            var evt = document.createEventObject();
            oEvent = extend(evt, options);
            element.fireEvent('on' + eventName, oEvent);
        }
        return element;
    }
	//used by function simulate(element, eventName)
    function extend(destination, source) {
        for (var property in source)
          destination[property] = source[property];
        return destination;
    }
	//used by function simulate(element, eventName)
	var eventMatchers = {
		'HTMLEvents': /^(?:load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll)$/,
		'MouseEvents': /^(?:click|dblclick|mouse(?:down|up|over|move|out))$/
	}
	//used by function simulate(element, eventName)
	var defaultOptions = {
		pointerX: 0,
		pointerY: 0,
		button: 0,
		ctrlKey: false,
		altKey: false,
		shiftKey: false,
		metaKey: false,
		bubbles: true,
		cancelable: true
	}
//window.onload = init;  //not a good idea to do this in a library, move to appropriate html file.