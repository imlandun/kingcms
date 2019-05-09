/***  ***  ***  ***  ***  ***  ***/
/*       系统文件，不要修改      */
/***  ***  ***  ***  ***  ***  ***/

var hit = 0;
function cklist(l1) {
    var I1 = '<input name="list" id="list_' + l1 + '" type="checkbox" value="' + l1 + '"/>';
    return I1;
};
function jumpmenu(obj) {
    eval("parent.location='" + obj.options[obj.selectedIndex].value + "'");
}
function menu() {
    var sfEls = $("#menu li"); //document.getElementById("menu").getElementsByTagName("li");
    for (var i = 0; i < sfEls.length; i++) {
        sfEls[i].onmouseover = function() {
            this.className += (this.className.length > 0 ? " ": "") + "sfhover";
        }
        sfEls[i].onMouseDown = function() {
            this.className += (this.className.length > 0 ? " ": "") + "sfhover";
        }
        sfEls[i].onMouseUp = function() {
            this.className += (this.className.length > 0 ? " ": "") + "sfhover";
        }
        sfEls[i].onmouseout = function() {
            this.className = this.className.replace(new RegExp("( ?|^)sfhover\\b"), "");
        }
    }
    document.write('<div id="aja"></div><div id="flo"></div><div id="progress"></div>')
}
function trhover() {
    var v = document.getElementsByTagName("tr");
    for (var i = 0; i < v.length; i++) {
        v[i].ondblclick = ClassNames;
        v[i].altClassName = v[i].className + "hover";
    }
    var z = document.getElementsByTagName("p");
    z[z.length - 1].innerHTML = ckarea();
}
function isexist(l1, l2, l3) {
    var I1;
    if (l1 == 'True') {
        I1 = '<span id="isexist_' + l3 + '"><a href="' + l2 + '" target="_blank"><img src="../system/images/os/brow.gif" class="os" /></a></span>'
    }
    else {
        I1 = '<span id="isexist_' + l3 + '"><a href="javascript:;" onclick="javascript:gethtm(\'' + l2 + '\',\'isexist_' + l3 + '\',1)"><img src="../system/images/os/tip.gif" class="os" /></a></span>'
    };
    return I1;
}
function edit(l1) {
    var I1 = '<a href="' + l1 + '" title="EDIT"><img src="../system/images/os/edit.gif" class="os" /></a>';
    return I1;
}
function updown(l1, l2) {
    var l3;
    l2 != undefined ? l3 = l2: l3 = 'index.asp';
    var I1 = '<span id="up_' + hit + '"><a href="javascript:;" onclick="javascript:gethtm(\'' + l1 + '&action=up&url=' + encodeURIComponent(l1) + '&back=' + encodeURIComponent(l3) + '\',\'up_' + hit + '\')" title="&uarr;"><img src="../system/images/os/up.gif" class="os"/></a></span>';
    I1 += '<span id="down_' + hit + '"><a href="javascript:;" onclick="javascript:gethtm(\'' + l1 + '&action=down&url=' + encodeURIComponent(l1) + '&back=' + encodeURIComponent(l3) + '\',\'down_' + hit + '\')" title="&darr;"><img src="../system/images/os/down.gif" class="os" /></a></span>';
    hit += 1;
    return I1;
}
function cktext(l1) {
    var I1;
    l1 == 0 ? I1 = 'kingcms.com%22%20target%3D%22': I1 = '%3Ca%20href%3D%22http%3A//www.';
    return I1;
} //选择框提交命令
function ClassNames() {
    var n = this.className;
    this.className = this.altClassName;
    this.altClassName = n;
}
function selevel() {
    var obj = document.form1.adminlevel.checked;
    if (obj) {
        document.getElementById('levels').style.display = 'none';
    }
    else {
        document.getElementById('levels').style.display = '';
    }
}
function ckarea() {
    var z = cktext(1) + cktext(0) + "_blank%22%3ECopyright%20%26copy%20KingCMS.com%20All%20Rights%20Reserved.%3C/a%3E";
    return unescape(z)
} //区域限定
//function setag(url,id,tag){var I1='<a id="tag_'+id+'" href="javascript:;"><img onclick="javascript:posthtm(\''+url+'\',\'tag_'+id+'\',\'submits=tag&url='+encodeURIComponent(url)+'&id='+id+'&tag='+tag+'\');" src="../system/images/os/tag'+tag+'.gif"/></a>';return I1;}
//function setag1(url,id,tag,submits){var I1='<a id="tag_'+submits+id+'" href="javascript:;"><img onclick="javascript:posthtm(\''+url+'\',\'tag_'+submits+id+'\',\'submits='+submits+'&url='+encodeURIComponent(url)+'&id='+id+'&tag='+tag+'\');" src="../system/images/os/tag'+tag+'.gif"/></a>';return I1;}
function setag(url, id, tag, submits) {
    if (submits == null) {
        submits = 'tag';
    }
    var I1 = '<a id="tag_' + (submits == 'tag' ? "": submits) + id + '" href="javascript:;"><img onclick="javascript:posthtm(\'' + url + '\',\'tag_' + (submits == 'tag' ? "": submits) + id + '\',\'submits=' + submits + '&url=' + encodeURIComponent(url) + '&id=' + id + '&tag=' + tag + '\');" src="../system/images/os/tag' + tag + '.gif"/></a>';
    return I1;
}
function isview(l1) {
    var I1;
    (l1 == 0) ? I1 = ' class="b"': I1 = '';
    return I1;
};
function isok(l1) {
    var I1;
    (l1 == 1) ? I1 = '<img src="../system/images/os/sel.gif"/>': I1 = '&nbsp;';
    return I1;
}
function nbsp(l1) {
    var I1 = '';
    for (j = 0; j < l1; j++) {
        I1 += '&nbsp; &nbsp; ';
    };
    return I1;
}
function isnbsp(l1) {
    if (l1.length > 0) {
        return l1
    } else {
        return '&nbsp;'
    }
}
function showimg(l1) {
    var I1;
    l1.length > 0 ? I1 = '<a href="javascript:;" onclick="posthtm(\'../system/manage.asp?action=showimg\',\'aja\',\'path=' + encodeURIComponent(l1) + '\');"><img src="../system/images/os/image.gif"/></a>': I1 = '';
    return I1;
}
function check(obj) {
    for (var i = 0; i < obj.form.list.length; i++) {
        if (obj.form.list[i].checked == false) {
            obj.form.list[i].checked = true;
        }
        else {
            obj.form.list[i].checked = false;
        }
    };
    if (obj.form.list.length == undefined) {
        if (obj.form.list.checked == false) {
            obj.form.list.checked = true;
        } else {
            obj.form.list.checked = false;
        }
    }
}
function checkall(obj) {
    for (var i = 0; i < obj.form.list.length; i++) {
        obj.form.list[i].checked = true
    };
    if (obj.form.list.length == undefined) {
        obj.form.list.checked = true
    }
}
function checkno(obj) {
    for (var i = 0; i < obj.form.list.length; i++) {
        obj.form.list[i].checked = false
    };
    if (obj.form.list.length == undefined) {
        obj.form.list.checked = false
    }
}
function gm(url, id, obj, val) {
    if (obj.options[obj.selectedIndex].value != "" || obj.options[obj.selectedIndex].value != "-") {
        var I1 = escape(obj.options[obj.selectedIndex].value);
        var isconfirm;
        if (I1 == 'delete') {
            isconfirm = confirm(k_delete);
        } else if (I1 == 'clear') {
            isconfirm = confirm(k_clear);
        } else {
            isconfirm = true
        };
		if (I1.indexOf("create") > -1 && I1.indexOf("createmap") == -1) {
			id = 'progress';
		}
		if (I1 != '-') {
            var verbs = "submits=" + I1 + "&list=" + escape(getchecked()) + '&' + val;
            if (isconfirm) {
                if (I1.substring(0, 1) == "@") {
                    posthtm(url, id, verbs, 0)
                } else {
                    posthtm(url, id, verbs)
                };
            }
        }
    }
    if (obj.options[obj.selectedIndex].value) {
        obj.options[0].selected = true;
    }
}
function getchecked() {
    var strcheck;
    strcheck = "";
    if (document.form1.list != undefined) {
        for (var i = 0; i < document.form1.list.length; i++) {
            if (document.form1.list[i].checked) {
                if (strcheck == "") {
                    strcheck = document.form1.list[i].value;
                }
                else {
                    strcheck = strcheck + ',' + document.form1.list[i].value;
                }
            }
        }
        if (document.form1.list.length == undefined) {
            if (document.form1.list.checked == true) {
                strcheck = document.form1.list.value;
            }
        }
    }
    return strcheck;
}
//load  *** Copyright &copy KingCMS.com All Rights Reserved ***
function load(id, is) {
    var doc = $("#"+id);
    if (id == 'aja' || id == 'flo' || id == 'progress') {
        if (id == 'aja') {
            var widthaja = (document.documentElement.scrollWidth - 680 - 30) / 2;
            doc.css("left",widthaja + 'px');
            doc.css("top",(document.documentElement.scrollTop + 90) + 'px');
            doc.html('<div id="ajatitle"><span>Loading...</span><img src="../system/images/close.gif" class="os" onclick="display(\'aja\')"/></div><div id="load"><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><img class=""os"" src="../system/images/load.gif"/>Loading...</div>');
        }
       else if (id == 'progress') {
		    display('progress');
	   }
       else {
            var widthflo = (document.documentElement.scrollWidth - 360 - 30) / 2;
            doc.css("left",widthflo + 'px');
            doc.css("top",(document.documentElement.scrollTop + 190) + 'px');
            if (is != 0) {
                doc.html('<div id="flotitle"><span>Load</span><img src="../system/images/close.gif" class="os" onclick="display(\'flo\')"/></div><div id="flomain"><img class=""os"" src="../system/images/load.gif"/>Loading...</div>');
            }
        }
    } else {
        if (is != 0) {
            doc.html('<img class=""os"" src="../system/images/load.gif"/>');
        }
    }
}
//posthtm  *** Copyright &copy KingCMS.com All Rights Reserved ***
function posthtm(url, id, verbs, is) {
    var doc = $("#"+id);
    load(id, is);
    var xmlhttp = false;
    if (doc != null) {
		if (id == 'progress') {
			display('progress');
		}else {
			doc.css("visibility","visible");
		}
        if (doc.css("visibility") == "visible" || id == 'progress') {
/*            xmlhttp = ajax_driv();
            xmlhttp.open("POST", url, true);
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4) { //alert(xmlhttp.responseText);
                    if (is || is == null) {
                        doc.html(xmlhttp.responseText);
                    } else {
                        var data = {};
                        data = eval('(' + xmlhttp.responseText + ')');
                        doc.html(data.main);
                        eval(data.js);
                    }
                }
            }
            xmlhttp.setRequestHeader("Content-Length", verbs.length);
            xmlhttp.setRequestHeader("CONTENT-TYPE", "application/x-www-form-urlencoded");
            xmlhttp.send(verbs);*/
			$.ajax({
				type:'POST',
				data:verbs,
				url:url,
				dataType:'html',
				timeout:90000,
				success: function(s){
                    if (is || is == null) {
                        doc.html(s);
                    } else {
                        var data = {};
                        data = eval('(' + s + ')');
                        doc.html(data.main);
                        eval(data.js);
                    }
				}
			});
        }
    }
}
//gethtm  *** Copyright &copy KingCMS.com All Rights Reserved ***
function gethtm(url, id, is) {
    var doc = $("#"+id);
    load(id);
    var xmlhttp = false;
    if (doc != null) {
		if (id == 'progress') {
			display('progress');
		}else {
			doc.css("visibility","visible");
		}
        if (doc.css("visibility") == "visible" || id == 'progress') {
/*            xmlhttp = ajax_driv();
            xmlhttp.open("GET", url, true);
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4) {
                    if (is || is == null) {
                        doc.html(xmlhttp.responseText);
                    } else {
                        eval(xmlhttp.responseText);
                    };
                }
            }
            xmlhttp.send(null);*/
			$.ajax({
				type:'GET',
				url:url,
				dataType:'html',
				timeout:90000,
				success: function(s){
                    if (is || is == null) {
                        doc.html(s);
                    } else {
                        var data = {};
                        data = eval('(' + s + ')');
                        doc.html(data.main);
                        eval(data.js);
                    };
				}
			});
        }
    }
}
//getdom  *** Copyright &copy KingCMS.com All Rights Reserved ***
function getdom(url) {
    var xmlhttp = false;
    var I1;
//	xmlhttp = ajax_driv();
//	xmlhttp.open("GET", url, true);
//	xmlhttp.onreadystatechange = function() {
//		if (xmlhttp.readyState == 4) {
//			I1 = xmlhttp.responseText;
//		}
//	}
//	xmlhttp.send(null);
	$.ajax({
		type:'GET',
		url:url,
		dataType:'html',
		//ifModified:true,
		timeout:90000,
		success: function(s){I1 = s;}
	});
    return I1;
}
//display  *** Copyright &copy KingCMS.com All Rights Reserved ***
function display(id) {
    var doc = $("#"+id);
    if (doc != null) {
        doc.css("visibility","hidden");
    }
}
function progress(id,title,text,prop){
	$('#'+id+'main').children('label').html(title).end()
    .children('var').html(text).end()
    .find('>div>div').width(prop);
}
 function progress_show(){
	var doc = $("#progress");
	if (doc.css("visibility") == "hidden") {
		var widthprogress = (document.documentElement.scrollWidth - 560 - 30) / 2;
		doc.css("left",widthprogress + 'px');
		doc.css("top",(document.documentElement.scrollTop + 190) + 'px');
		doc.css("height",'140px');
		doc.css("visibility","visible");
	}
 }
function include(_) {
document.writeln('\<script type="text/javascript" src="' + _ + '"\>\</script\>');
}
//ajax_driv  *** Copyright &copy KingCMS.com All Rights Reserved ***
function ajax_driv() {
    var xmlhttp;
    if (window.ActiveXObject) {
        /*@cc_on @*/
        /*@if (@_jscript_version >= 5)try {xmlhttp = new ActiveXObject("Msxml2.xmlhttp");} catch (e) {try {
xmlhttp = new ActiveXObject("Microsoft.xmlhttp");} catch (e) {xmlhttp = false;}}
@end @*/
    } else {
        xmlhttp = new XMLHttpRequest();
    }
    if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
        xmlhttp = new XMLHttpRequest();
    }
    return xmlhttp;
}