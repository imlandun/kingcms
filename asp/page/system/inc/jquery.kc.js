document.write('<div id="flo"></div><div id="aja"></div>');
function cklist(l1) {
    var I1 = '<input name="list" id="list_' + l1 + '" type="checkbox" value="' + l1 + '"/>';
    return I1;
};
function menu() {
    var sfEls = $("#menu li");
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
function gm(url, id, obj) {
    if (obj.options[obj.selectedIndex].value != "" || obj.options[obj.selectedIndex].value != "-") {
        var I1 = escape(obj.options[obj.selectedIndex].value);
        var isconfirm;
        if (I1 == 'delete') {
            isconfirm = confirm(k_delete);
        } else {
            isconfirm = true
        };
        if (I1 != '-') {
            var verbs = "submits=" + I1 + "&list=" + escape(getchecked()); //选择框提交命令
            if (isconfirm) {
                posthtm(url, id, verbs);
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
    return strcheck;
}
//load  *** Copyright &copy KingCMS.com All Rights Reserved ***
function load(id) {
    var doc = $("#"+id);
    if (id == 'aja' || id == 'flo') {
        if (id == 'aja') { //document.body.scrollTop
            var widthaja = (document.documentElement.scrollWidth - 680 - 30) / 2;
            doc.css("left",widthaja + 'px');
            doc.css("top",(document.documentElement.scrollTop + 90) + 'px');
            doc.html('<div id="ajatitle"><span>Loading...</span><img src="' + king_page + 'system/images/close.gif" class="os" onclick="display(\'aja\')"/></div><div id="load"><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>Loading...</div>');
        }
        else {
            var widthflo = (document.documentElement.scrollWidth - 360 - 30) / 2;
            doc.css("left",widthflo + 'px');
            doc.css("top",(document.documentElement.scrollTop + 190) + 'px');
            if (is != 0) {
                doc.html('<div id="flotitle"><span>Loading...</span><img src="' + king_page + 'system/images/close.gif" class="os" onclick="display(\'aja\')"/></div><div id="flomain">Loading...</div>');
            }
        }
    } else {
            doc.html('<img class=""os"" src="' + king_page + 'system/images/load.gif"/>');
    }
}
//posthtm  *** Copyright &copy KingCMS.com All Rights Reserved ***
function posthtm(url, id, verbs, is) { //is null or 1
    var doc = $("#"+id);
    load(id);
    //	doc.innerHTML='<span><img src="image/load.gif"/>Loading...</span>';
    var xmlhttp = false;
    if (doc != null) {
        doc.css("visibility","visible");
        if (doc.css("visibility") == "visible") {
			$.ajax({
				type:'POST',
				data:verbs,
				url:url,
				dataType:'html',
				//ifModified:true,
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
        doc.css("visibility","visible");
        if (doc.css("visibility") == "visible") {
			$.ajax({
				type:'GET',
				url:url,
				dataType:'html',
				//ifModified:true,
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
//ajax_driv  *** Copyright &copy KingCMS.com All Rights Reserved ***
function ajax_driv() {
    var xmlhttp;
    if (window.ActiveXObject) {
        /* 不要删除以下注释，这部分不是注释 */
        /*@cc_on @*/
        /*@if (@_jscript_version >= 5)
		try {
		  xmlhttp = new ActiveXObject("Msxml2.xmlhttp");
		} catch (e) {
		  try {
			xmlhttp = new ActiveXObject("Microsoft.xmlhttp");
		  } catch (e) {
			xmlhttp = false;
		  }
		}
		@end @*/
    } else {
        xmlhttp = new XMLHttpRequest();
    }
    if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
        xmlhttp = new XMLHttpRequest();
    }
    return xmlhttp;
}
//readCookie  *** Copyright &copy KingCMS.com All Rights Reserved ***
function readCookie(l1) { //一维数组直接写值即可，二维数组用垂直线分开
    var I1 = "";
    if (l1.indexOf("|") != -1) { //包含垂直线，是二维cookie
        var I2 = l1.split("|");
        var I3 = i_readCookie(I2[0], document.cookie);
        I1 = i_readCookie(I2[1], I3);
    }
    else { //一维数组
        if (document.cookie.length > 0) {
            I1 = i_readCookie(l1, document.cookie)
        }

    }
    return I1;

}
//i_readCookie  *** Copyright &copy KingCMS.com All Rights Reserved ***
function i_readCookie(l1, l2) {
    var cookieValue = "";
    var search = l1 + "=";
    if (l2.length > 0) {
        offset = l2.indexOf(search);
        if (offset != -1) {
            offset += search.length;
            end = l2.indexOf(";", offset);
            if (end == -1) end = l2.length;
            cookieValue = unescape(l2.substring(offset, end))
        }
    }
    return cookieValue;
}