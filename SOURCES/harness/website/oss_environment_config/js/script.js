// create global variables
var xmlhttp;
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
window.onload = init;