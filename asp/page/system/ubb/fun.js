function UBB(id,content,cols,rows,type,path){
	
	document.write('<link href="'+path+'ubb/style.css" rel="stylesheet" type="text/css" />');
	document.write('<div id="kingubb">');
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'b\');"><img src="'+path+'ubb/B.gif"/></a></span>');
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'i\');"><img src="'+path+'ubb/I.gif"/></a></span>');
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'u\');"><img src="'+path+'ubb/U.gif"/></a></span>');
	if(type){
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'align\',\'left\');"><img src="'+path+'ubb/left.gif"/></a></span>');
	}
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'align\',\'center\');"><img src="'+path+'ubb/center.gif"/></a></span>');
	if(type){
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'align\',\'right\');"><img src="'+path+'ubb/right.gif"/></a></span>');
	}
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'url\');"><img src="'+path+'ubb/HyperLink.gif"/></a></span>');
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'email\');"><img src="'+path+'ubb/Email.gif"/></a></span>');
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.Color();"><img src="'+path+'ubb/Color.gif"/></a><em id="KingCMS_Color"></em></span>');
	document.write('<span><a href="javascript:;" onclick="javascript:ubb.Emo();"><img src="'+path+'ubb/Emo.gif"/></a><em id="KingCMS_Emo"></em></span>');
	if(type){
		document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'image\');"><img src="'+path+'ubb/Image.gif"/></a></span>');
		document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'code\');"><img src="'+path+'ubb/Code.gif"/></a></span>');
		document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'quote\');"><img src="'+path+'ubb/Quote.gif"/></a></span>');
		document.write('<span><a href="javascript:;" onclick="javascript:ubb.addtag(\'media\');"><img src="'+path+'ubb/Media.gif"/></a></span>');
		if (navigator.userAgent.indexOf("Firefox")==-1)
		{
		document.write('<span><a href="javascript:;" onclick="javascript:ubb.Paste();"><img src="'+path+'ubb/Paste.gif"/></a></span>');
		document.write('<span><a href="javascript:;" onclick="javascript:ubb.chkPaste();"><img src="'+path+'/ubb/chkPaste.gif"/></a></span>');
		}
	}
	document.write('</div>');
	document.write('<iframe style="width:0;height:0;border:0;" id="dtf"></iframe>');
	document.write('<textarea style="clear:both;display:block;" name="'+id+'" id="'+id+'" cols="'+cols+'" rows="'+rows+'" onclick="javascript:ubb.storeCaret(this);">'+content+'</textarea>');


	this.id=document.getElementById(id);

	this.addtag=function(tag,val){this.id=document.getElementById(id);
		var temp;if(tag!='em'){temp='[/'+tag+']'}else{temp='';}

		if(val){(val.length>0)?val='='+val:val=''}else{val=''}

		if(typeof(this.id.selectionStart) == "number") {
			var opn = this.id.selectionStart + 0;
			this.id.value = this.id.value.substr(0, this.id.selectionStart) + '['+tag+val+']' + this.getSelectedText() + temp + this.id.value.substr(this.id.selectionEnd);}
		else{
			if(this.getSelectedText()==''){
				(tag=='code'||tag=='quote') ? AddTxt='\n['+tag+']\n\n[/'+tag+']' : AddTxt='['+tag+val+']'+temp;
				this.AddText(AddTxt);
				return true;
			}
			var range=document.selection.createRange();range.text='['+tag+val+']'+range.text+temp;
		}
	}

	this.getSelectedText=function(){this.id=document.getElementById(id);var selected='';
		if(typeof(this.id.selectionStart) == "number") {
			return this.id.value.substr(this.id.selectionStart, this.id.selectionEnd - this.id.selectionStart);
		} else if(document.selection && document.selection.createRange) {
			return document.selection.createRange().text;
		} else if(window.getSelection) {
			return window.getSelection() + '';
		} else {return false;}}

	this.AddText=function(NewCode){this.id=document.getElementById(id);document.all ? this.insertAtCaret(this.id, NewCode) : this.id.value += NewCode;this.setfocus();}

	this.insertAtCaret=function(textEl,text){if (textEl.createTextRange && textEl.caretPos){
	var caretPos=textEl.caretPos;caretPos.text += caretPos.text.charAt(caretPos.text.length-2) == ' ' ? text+' ' : text;}
	else if(textEl){textEl.value += text;}else {textEl.value=text;}}//selectionStart 
	
	this.storeCaret=function(textEl){if(textEl.createTextRange){textEl.caretPos=document.selection.createRange().duplicate();}}
	this.setfocus=function() {this.id.focus();}

	this.Emo=function(){document.getElementById("KingCMS_Emo").style.visibility=="hidden"?gethtm(path+'emo.asp','KingCMS_Emo'):display('KingCMS_Emo')}
	this.EmoShow=function(emo){this.addtag('em',emo);display('KingCMS_Emo');}

	this.Color=function(){document.getElementById("KingCMS_Color").style.visibility=="hidden"?gethtm(path+'ubb/color.htm','KingCMS_Color'):display('KingCMS_Color')}
	this.Chcolor=function(color){this.addtag('color',color);display("KingCMS_Color");}

	this.html_Paste=function(str){
	str=str.replace(/\r/g,"");str=str.replace(/on(load|click|dbclick|mouseover|mousedown|mouseup)="[^"]+"/ig,"");
	str=str.replace(/<script[^>]*?>([\w\W]*?)<\/script>/ig,"");str=str.replace(/<a[^>]+href="([^"]+)"[^>]*>(.*?)<\/a>/ig,"[url=$1]$2[/url]");
	str=str.replace(/<font[^>]+color=([^ >]+)[^>]*>(.*?)<\/font>/ig,"[color=$1]$2[/color]");
	str=str.replace(/<img[^>]+src="([^"]+)"[^>]*>/ig,"[img]$1[/img]");
	str=str.replace(/<([\/]?)b>/ig,"[$1b]");str=str.replace(/<([\/]?)strong>/ig,"[$1b]");
	str=str.replace(/<([\/]?)u>/ig,"[$1u]");str=str.replace(/<([\/]?)i>/ig,"[$1i]");
	str=str.replace(/ /g," ");str=str.replace(/&/g,"&");str=str.replace(/"/g,"\"");str=str.replace(/&lt;/g,"<");
	str=str.replace(/&gt;/g,">");str=str.replace(/<br>/ig,"\n");str=str.replace(/<[^>]*?>/g,"");
	str=str.replace(/\[url=([^\]]+)\](\[img\]\1\[\/img\])\[\/url\]/g,"$2");return str;}
	this.Paste=function(){var str=window.clipboardData.getData("Text");if(str!=null){
	str=this.html_Paste(str);if (this.getSelectedText()){var range=document.selection.createRange();range.text=str;}else{this.AddText(str);};}}
	this.HTML2UBB=function(strHTML){
		var re=this.htmlDecode(strHTML);
		re=re.replace(/height *>/ig,"");
		re=re.replace(/width *>/ig,"");
		re=re.replace(/<(\/?)strong>/ig,"[$1b]");
		re=re.replace(/<(\/?)strong>/ig,"[$1b]");
		re=re.replace(/<center>/ig,"[align=center]");
		re=re.replace(/<\/center>/ig,"[\/align]");
		re=re.replace(/<(\/?)b>/ig,"[$1b]");
		re=re.replace(/<(\/?)em>/ig,"[$1i]");
		re=re.replace(/<(\/?)i>/ig,"[$1i]");
		re=re.replace(/< *(\/?) *div[\w\W]*?>/ig,"\r\n");
		re=re.replace(/< *img +[\w\W]*?src=["]?([^">\r\n]+)[\w\W]*?>/ig,"[img]$1[/img]");
		re=re.replace(/< *a +[\w\W]*?href=["]?([^">\r\n]+)[\w\W]*?>([\w\W]*?)< *\/ *a *>/ig,"[url=$1]$2[/url]");
		re=re.replace(/<script[\w\W]+?<\/script>/ig,"");
		re=re.replace(/<[\w\W]*?>/ig,"");
		re=re.replace(/(\r\n){2,}/g,"\r\n");
		return(re);}


	this.chkPaste1=function(){this.id.focus();
		tR=document.selection.createRange();
		var dtf=document.getElementById("dtf");
		alert(dtf.value);
		dtf.document.body.innerHTML="";
		dtf.document.body.contentEditable=true;
		dtf.document.body.focus();
		dtf.document.execCommand("paste");
		tR.text=this.HTML2UBB(dtf.document.body.innerHTML);
		tR.select();}

	this.chkPaste=function(){
		dtf=document.getElementById("dtf");
		dtf.document.body.innerHTML="";
		dtf.document.body.contentEditable=true;
		dtf.document.body.focus();
		dtf.document.execCommand("paste");
		AddTxt=this.HTML2UBB(dtf.document.body.innerHTML);
		this.AddText(AddTxt);
	}



	this.htmlEncode=function(strS){return(strS.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/ /g,"&nbsp;").replace(/\r\n/g,"<br\/>"));}
	this.htmlDecode=function(strS){return(strS.replace(/<br\/?>/ig,"\r\n").replace(/&nbsp;/ig," ").replace(/&gt;/ig,">").replace(/&lt;/ig,"<").replace(/&amp;/ig,"&"));}

}