function postdom(url,verbs){
var xmlhttp = false;
xmlhttp=ajax_driv();
xmlhttp.open("POST", url,true);
xmlhttp.setRequestHeader("If-Modified-Since","0");
xmlhttp.onreadystatechange=function(){
if (xmlhttp.readyState==4){
xmlhttp.responseText;
}}
xmlhttp.setRequestHeader("Content-Length",verbs.length);
xmlhttp.setRequestHeader("CONTENT-TYPE","application/x-www-form-urlencoded");
xmlhttp.send(verbs);
}
var datediff=getdom('/page/system/now.asp?datetime=2008%2D5%2D7+14%3A59%3A27');if(datediff>1){postdom('/page/collect/create.asp','time=1&list=1');};