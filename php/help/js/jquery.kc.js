$(document).ready(function(){

	$('span').prepend('<strong>Note :</strong>');
	$('code.example').prepend('<strong>Example :</strong>').each(function(){
	
		var htm=$(this).html();

		htm=htm.replace(/(\/\*((.|\n)+?)\*\/)/g,"<var>&lt;!-- $2 --&gt;</var>");
		htm=htm.replace(/(\{[\/\?]?\w+):([\w.]+)\s?([^}]*?)(\/?\})/g,"<kbd>$1:<i rel=\"F00\">$2</i><i rel=\"F0F\">$3</i>$4</kbd>");
		htm=htm.replace(/\[([^\[]+?)\]/g,'<abbr>&lt;$1&gt;</abbr>');
		htm=htm.replace(/____/g,"&nbsp; &nbsp; &nbsp; &nbsp; ");
		htm=htm.replace(/(\$\w+)/g,'<i rel=\"F30\">$1</i>');

		$(this).html(htm);

	});

	$('code.php').each(function(){
	
		var htm=$(this).html()+'<br/><br/><i rel="00F">?&gt</i>';

		htm=htm.replace(/(\/\*(|\n).+?\*\/)/g,"<i rel=\"808000\">$1</i><br/>");//注释
		htm=htm.replace(/function (\w+\(\))/g,"<i rel=\"00F\">function</i> <i rel=\"F00\">$1</i>");
		htm=htm.replace(/((echo|global) )/g,"<i rel=\"00F\">$1</i> ");
		htm=htm.replace(/(\[[\w\'\"]+\])/g,"<i rel=\"800000\">$1</i>");
		htm=htm.replace(/\$(\w+)/g,"<i rel=\"0000FF\">\$</i><i rel=\"008080\">$1</i>");
		htm=htm.replace(/( (\$king))/g,"<i rel=\"F00\">$1</i> ");
		htm=htm.replace(/(king_\w+)/g,"<i rel=\"800000\">$1</i> ");

		htm=htm.replace(/____/g,"&nbsp; &nbsp; &nbsp; &nbsp; ");

		var head='<strong>Example : </strong><i rel=\"666\">'+$(this).attr('file')+'</i>';
		head+='<i rel="00F">&lt;?php</i><br/><i rel=\"F00\">require_once</i> <i rel=\"F0F\">\'../global.php\'</i>;<i rel=\"808000\">/*必须的*/</i><br/><br/>';

		htm=head+htm;

		$(this).html(htm);

	});

	$('code.sql').each(function(){

		var rel=$(this).attr('rel');
		var R=rel.split(',');

		var htm='create table IF NOT EXISTS '+R[0].replace('%s','king');
		htm+=' (<br/>'+R[1]+' int not null AUTO_INCREMENT primary key,/*自动递增*/'+$(this).html();
		htm+=') ENGINE=MyISAM  CHARSET=utf8;';

		htm=htm.replace(/(\/\*(|\n).+?\*\/)/g,"<i rel=\"808000\">$1</i><br/>");//注释
		htm=htm.replace(/( (not null|null))/ig,"<i rel=\"900\">$1</i>");
		htm=htm.replace(/ (default) ([\'0-9a-z]+)/ig," <i rel=\"00F\">$1</i> <i rel=\"F0F\">$2</i>");
		htm=htm.replace(/( (unique|AUTO_INCREMENT|IF NOT EXISTS|CHARSET|ENGINE))/g,"<i rel=\"F00\">$1</i>");
		htm=htm.replace(/(index)(\()(\w+)(\))/ig,"<i rel=\"00F\">$1</i><i rel=\"F0F\">$2</i><i rel=\"008088\">$3</i><i rel=\"F0F\">$4</i>");
		htm=htm.replace(/( (smallint|tinyint|varchar|char|text|int))/g," <i rel=\"F90\">$1</i>");
		htm=htm.replace(/(\()(\d+)(\))/ig,"<i rel=\"F0F\">$1</i><i rel=\"008088\">$2</i><i rel=\"F0F\">$3</i>");
		
		$(this).html(htm).prepend('<strong>SQL : '+R[0]+'</strong>');

	});

	//颜色渲染
	$('code i').each(function(){
		$(this).css('color','#'+$(this).attr('rel'));
	});

	$('body').prepend('<h6><strong><a href="../index.html">KingCMS 用户指南(UserGuide) - Version 1.0</a></strong><a href="../index.html">返回首页</a><a href="http://bbs.kingcms.com/" target="_blank">技术论坛</a><a href="http://www.kingcms.com/" target="_blank">官方网站</a></h6>');

	$('body').append('<div><a href="#top">↖Top</a> - <img src="../images/house.png" class="os"/><a href="../index.html">Home</a></div>');

	$('a').attr('title','china').each(function(){
		var tit=$(this).text();
		$(this).attr('title',tit);
	});

	$('.table2 tr td').attr('width','49%');
	$('.table2 tr th').attr('width','2%');

	$('table').attr('cellspacing',0);

	$('p').each(function(){
		var htm=$(this).html();
		htm=htm.replace(/((http|https):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\.\=\?\+\-~`@\:!%#]|(&)|&)+)/ig,'<img class="os" src="../images/link.png"/><a href="$1" target="_blank">$1</a>');
		$(this).html(htm);
	});


	$('table tr:even').addClass('zebra');


	//加亮锚点对象
	if(location.href.indexOf("#")!=-1){
		var id=location.href.substring(location.href.indexOf("#"));
		$(id).addClass('light');
	}




});

//设置样式
var s='<style type="text/css">';
s+='.l{text-align:left}\n';//居左
s+='.r{text-align:right}\n';//居右
s+='.c{text-align:center}\n';//居中
s+='.fl{float:left;}\n';//偏左
s+='.fr{float:right;}\n';//偏右
s+='.block{display:block;}\n';//打块
s+='.none{display:none;}\n';//空
s+='.w0 {width:100%}\n';//全宽
for(var i=0;i<17;i++){
	for(var j=1;j<=9;j++){
		s+='.w'+((i+1)*50)+'{width:'+((i+1)*50)+'px}\n';//.w50-w800的样式

	}
}
for(i=1;i<20;i++){
	s+='.w'+i+'{width:'+(i*5)+'%}\n';
}
s+='</style>';

document.write(s);

