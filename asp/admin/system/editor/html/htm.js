function getSelectedText(){var post=document.form1(textbox);var selected='';
if(post.isTextEdit){post.focus();var sel= document.selection;var rng= sel.createRange();rng.colapse;
if((sel.type =="Text" || sel.type=="None") && rng !=null){
if(rng.text.length > 0) selected=rng.text;}}return selected;}

function AddText(NewCode) {document.all ? insertAtCaret(document.form1(textbox), NewCode) : document.form1(textbox).value += NewCode;setfocus();}

function insertAtCaret(textEl,text){if (textEl.createTextRange && textEl.caretPos){
var caretPos=textEl.caretPos;caretPos.text += caretPos.text.charAt(caretPos.text.length-2) == ' ' ? text+' ' : text;}
else if(textEl){textEl.value += text;}else {textEl.value=text;}}

function storeCaret(textEl){if(textEl.createTextRange){textEl.caretPos=document.selection.createRange().duplicate();}}

function setfocus() {document.form1(textbox).focus();}

function bold(){if (getSelectedText()) {var range=document.selection.createRange();range.text="<strong>"+range.text+"</strong>";}
else {AddTxt="\n<strong> #### TEXT #### </strong>";AddText(AddTxt);}}

function italicize() {if (getSelectedText()) {var range=document.selection.createRange();range.text="<i>"+range.text+"</i>";}
else {AddTxt="\n<i> #### TEXT #### </i>";AddText(AddTxt);}}

function underline(){if (getSelectedText()){var range=document.selection.createRange();range.text="<u>"+range.text+"</u>";}
else{AddTxt="\n<u> #### TEXT #### </u>";AddText(AddTxt);}}

function ol(){AddTxt="\n<ol>\n\t<li></li>\n\t<li></li>\n\t<li></li>\n</ol>\n";AddText(AddTxt);}

function ul(){AddTxt="\n<ul>\n\t<li></li>\n\t<li></li>\n\t<li></li>\n</ul>\n";AddText(AddTxt);}

function align(str){if(getSelectedText()){var range=document.selection.createRange();range.text="\n<p style=\"text-align:"+str+";\">" + range.text + "</p>\n";}
else {AddTxt="\n<p style=\"text-align:"+str+";\"> </p>\n";AddText(AddTxt);}}

function email(){if (getSelectedText()){var range=document.selection.createRange();range.text="<a href=\"mainto:mailto: ####YOUR E-MAIL #### \">" + range.text + "</a>";}
else{AddTxt="\n<a href=\"mailto: ####YOUR E-MAIL #### \"></a>";AddText(AddTxt);}}

function hyperlink(){if (getSelectedText()){var range=document.selection.createRange();range.text="<a href=\"http://#### URL #### \">" + range.text + "</a>";}
else{AddTxt="\n<a href=\"http://#### URL #### \"></a>";AddText(AddTxt);}}

function image(){AddTxt="\n<img src=\"http://#### URL #### \" alt=\"alt\" />\n";AddText(AddTxt);}
function flash(){AddTxt="\n<object classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" codebase=\"http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0\" width=\"400\" height=\"300\" align=\"middle\">\n<param name=\"quality\" value=\"high\">\n<param name=\"menu\" value=\"false\">\n<embed src=\"http://#### FLASH FILE PATH #### \" quality=\"high\" width=\"400\" height=\"300\" align=\"middle\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" />\n</object>\n";AddText(AddTxt);}

function oTag(l1){if (getSelectedText()) {var range=document.selection.createRange();range.text="\n<"+l1+">"+range.text+"</"+l1+">\n";}
else {AddTxt="\n<"+l1+">\n #### TEXT #### \n</"+l1+">";AddText(AddTxt);}}

function pagebreak(){AddTxt="\n\n"+king_break+"\n\n";AddText(AddTxt);}

function color(){document.getElementById('k_color').style.visibility='visible';}

var color_shortcut="000 CFF CFC CF9 CF6 CF3 CF0 6F0 6F3 6F6 6F9 6FC 6FF 0FF 0FC 0F9 0F6 0F3 0F0";
color_shortcut+=  " 333 CCF CCC CC9 CC6 CC3 CC0 6C0 6C3 6C6 6C9 6CC 6CF 0CF 0CC 0C9 0C6 0C3 0C0"
color_shortcut+=  " 666 C9F C9C C99 C96 C93 C90 690 693 696 699 69C 69F 09F 09C 099 096 093 090"
color_shortcut+=  " 999 C6F C6C C69 C66 C63 C60 660 663 666 669 66C 66F 06F 06C 069 066 063 060"
color_shortcut+=  " CCC C3F C3C C39 C36 C33 C30 630 633 636 639 63C 63F 03F 03C 039 036 033 030"
color_shortcut+=  " FFF C0F C0C C09 C06 C03 C00 600 603 606 609 60C 60F 00F 00C 009 006 003 000"
color_shortcut+=  " F00 F0F F0C F09 F06 F03 F00 900 903 906 909 90C 90F 30F 30C 309 306 303 300"
color_shortcut+=  " 0F0 F3F F3C F39 F36 F33 F30 930 933 936 939 93C 93F 33F 33C 339 336 333 330"
color_shortcut+=  " 00F F6F F6C F69 F66 F63 F60 960 963 966 969 96C 96F 36F 36C 369 366 363 360"
color_shortcut+=  " FF0 F9F F9C F99 F96 F93 F90 990 993 996 999 99C 99F 39F 39C 399 396 393 390"
color_shortcut+=  " 0FF FCF FCC FC9 FC6 FC3 FC0 9C0 9C3 9C6 9C9 9CC 9CF 3CF 3CC 3C9 3C6 3C3 3C0"
color_shortcut+=  " F0F FFF FFC FF9 FF6 FF3 FF0 9F0 9F3 9F6 9F9 9FC 9FF 3FF 3FC 3F9 3F6 3F3 3F0"

function getIndex(o,e) {
if (e) {
var emoarr=color_shortcut.split(" ");
var c=getColor(o,e);
if (getSelectedText()){var range=document.selection.createRange();range.text="<font style=\"color:#"+emoarr[c]+";\">" + range.text + "</font>";}
else{AddTxt="\n<font style=\"color:#"+emoarr[c]+";\"> #### TEXT #### </font>";AddText(AddTxt);}

document.getElementById('k_color').style.visibility='hidden';}}

function showColor(o,e) {
var myArray =color_shortcut.split(" ");
o.title = "#"+myArray[getColor(o,e)]}

function getColor(o,e){
if(e){
var cols=19;
var rows=12;
var emoarr=color_shortcut.split(" ");
var unitwidth=Math.round(o.offsetWidth/cols);
var unitheight=Math.round(o.offsetHeight/rows);
var xinimg=document.documentElement.scrollLeft+e.clientX-getPos(o,"Left");
var yinimg=document.documentElement.scrollTop+e.clientY-getPos(o,"Top");
var r=Math.floor(yinimg/unitheight);
var c=Math.floor(xinimg/unitwidth)+r*cols;
return c;}}

function chcolor(color){if (getSelectedText()){var range=document.selection.createRange();range.text="[color=" + color + "]" + range.text + "[/color]";} 
else{AddTxt="[color="+color+"][/color]";AddText(AddTxt);}}

function chsize(size){if (getSelectedText()){var range=document.selection.createRange();range.text="[size=" + size + "]" + range.text + "[/size]";}
else {AddTxt="[size="+size+"] [/size]";AddText(AddTxt);}}

function chfont(font){if (getSelectedText()){var range=document.selection.createRange();range.text="[font=" + font + "]" + range.text + "[/font]";}
else {AddTxt="[font="+font+"] [/font]";AddText(AddTxt);}}

function html_Paste(str){
str=str.replace(/\r/g,"");str=str.replace(/on(load|click|dbclick|mouseover|mousedown|mouseup)="[^"]+"/ig,"");
str=str.replace(/<script[^>]*?>([\w\W]*?)<\/script>/ig,"");str=str.replace(/<a[^>]+href="([^"]+)"[^>]*>(.*?)<\/a>/ig,"[url=$1]$2[/url]");
str=str.replace(/<font[^>]+color=([^ >]+)[^>]*>(.*?)<\/font>/ig,"[color=$1]$2[/color]");
str=str.replace(/<img[^>]+src="([^"]+)"[^>]*>/ig,"[img]$1[/img]");
str=str.replace(/<([\/]?)b>/ig,"[$1b]");str=str.replace(/<([\/]?)strong>/ig,"[$1b]");
str=str.replace(/<([\/]?)u>/ig,"[$1u]");str=str.replace(/<([\/]?)i>/ig,"[$1i]");
str=str.replace(/ /g," ");str=str.replace(/&/g,"&");str=str.replace(/"/g,"\"");str=str.replace(/&lt;/g,"<");
str=str.replace(/&gt;/g,">");str=str.replace(/<br>/ig,"\n");str=str.replace(/<[^>]*?>/g,"");
str=str.replace(/\[url=([^\]]+)\](\[img\]\1\[\/img\])\[\/url\]/g,"$2");return str;}

function Paste(){var str=window.clipboardData.getData("Text");if(str!=null){
str=html_Paste(str);if (getSelectedText()){var range=document.selection.createRange();range.text=str;}else{AddText(str);};}}

function getPos(el,sProp){var iPos=0;while (el!=null) {iPos+=el["offset"+sProp];el=el.offsetParent;}return iPos;}

function gethtml(o,e){
var c=getGuide(o,e)
switch(c){
case 0:chkPaste();break;
case 1:bold();break;
case 2:italicize();break;
case 3:underline();break;
case 4:ol();break;
case 5:ul();break;

case 6:align("left");break;
case 7:align("center");break;
case 8:align("right");break;

case 9:hyperlink();break;
case 10:email();break;
case 11:image();break;
case 12:flash();break;
case 13:AddText("\n<hr />\n");break;

case 14:oTag("h1");break;
case 15:oTag("h2");break;
case 16:oTag("h3");break;
case 17:oTag("h4");break;
case 18:oTag("h5");break;
case 19:oTag("h6");break;
case 20:oTag("div");break;
case 21:oTag("p");break;

case 22:AddText("\n<br />\n");break;
case 23:oTag("pre");break;

case 24:AddText("&nbsp;");break;

case 25:AddText("\t");break;
case 26:color();break;
case 27:pagebreak();break;
}
if (c!=26){hiddenDiv();}
}


function getGuide(o,e){
if(e){var cols=28;var unitwidth=Math.round(o.offsetWidth/cols);var inimg=document.body.scrollLeft+e.clientX-getPos(o,"Left");
var c=Math.floor(inimg/unitwidth);return c;}}

function showTitle(o,e) {
var myArray = new Array("Paste","B","I","U","OL","UL","Align Left","Align Center","Align Right","A","Mail","IMG","Flash","HR","H1","H2","H3","H4","H5","H6","DIV","P","BR","PRE","&nbsp;","Tab","COLOR","Page Break");//
o.title = myArray[getGuide(o,e)]}

function hiddenDiv(){document.getElementById('k_color').style.visibility='hidden';}


txtContent=document.getElementById("txt");

function xhtmlencode(strHTML){
	var re=htmlDecode(strHTML);
	re=re.replace(/height *>/ig,"");
	re=re.replace(/width *>/ig,"");
	re=re.replace(/<(\/?)strong>/ig,"<$1strong>");
	re=re.replace(/<center>/ig,"\n<p style=\"text-align:center;\">\n");
	re=re.replace(/<\/center>/ig,"\n</p>\n");
	re=re.replace(/<(\/?)b>/ig,"<$1strong>");
	re=re.replace(/<(\/?)i>/ig,"<$1i>");
	re=re.replace(/< *(\/?) *div[\w\W]*?>/ig,"\n<br />\n");
	re=re.replace(/< *img +[\w\W]*?src=["]?([^">\r\n]+)[\w\W]*?>/ig,"<img alt=\"$1\" src=\"$1\"/>");
	re=re.replace(/< *a +[\w\W]*?href=["]?([^">\r\n]+)[\w\W]*?>([\w\W]*?)< *\/ *a *>/ig,"<a href=\"$1\">$2</a>");
	re=re.replace(/<script[\w\W]+?<\/script>/ig,"");
	re=re.replace(/(\r\n){2,}/g,"\n<br />\n");
	return(re);}

function htmlEncode(strS){return(strS.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/ /g,"&nbsp;").replace(/\r\n/g,"<br\/>"));}
function htmlDecode(strS){return(strS.replace(/<br\/?>/ig,"\r\n").replace(/&nbsp;/ig," ").replace(/&gt;/ig,">").replace(/&lt;/ig,"<").replace(/&amp;/ig,"&"));}
function chkPaste(){txtContent.focus();
	tR=document.selection.createRange();
	dtf.document.body.innerHTML="";
	dtf.document.body.contentEditable=true;
	dtf.document.body.focus();
	dtf.document.execCommand("paste");
	tR.text=xhtmlencode(dtf.document.body.innerHTML);
	tR.select();}

