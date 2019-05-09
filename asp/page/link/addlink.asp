<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set kc=new linkclass
	select case action
	case"" king_def
	end select
set kc=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
'def  *** ***  www.KingCMS.com  *** ***
sub king_def()'需要加入标题,访问级别	dim slip,sql,linkid,dataform,data,i,rs,sliptitle,checked,upfname
	dim i,sql,data,dataform,re
	sql="ktitle,kdescription,kc_urlpath,kc_image"'3
	re=request.ServerVariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="/"

	dataform=split(sql,",")
	redim data(ubound(dataform),0)
	for i=0 to ubound(dataform)
		data(i,0)=llll(dataform(i))
	next

	ol=ol&"<form name=""form1"" enctype=""multipart/form-data"" method=""post"" class=""k_form"" action="""&king.page&""">"
	ol=ol&"<h6>"&kingtitle&"</h6>"
	ol=ol&"<table cellspacing=""1"">"
	ol=ol&"<tr><th class=""k_th"">"&king.lang("link/name")&"</th><td>"
	ol=ol&"<input class=""k_input_max"" type=""text"" name=""linkname"" value="""&data(0,0)&""" maxlength=""30"" />"
	ol=ol&king.check("linkname|6|link/tip/linkname|1-30;linkname|9|link/tip/rname|select count(linkid) from kinglink where linkname='$pro$'")
	ol=ol&"</td></tr>"
	
	ol=ol&"<tr><th>"&king.lang("link/url")&"</th>"'网址
	ol=ol&"<td><input type=""text"" class=""k_input_max"" name=""linkurl"" value="""&data(2,0)&""" maxlength=""250"" />"
	ol=ol& king.check("linkurl|6|link/tip/linkurl|10-250;linkurl|5|link/tip/linkurl;linkurl|9|link/tip/rurl|select count(linkid) from kinglink where linkurl='$pro$'")
	ol=ol&"</td></tr>"
	ol=ol&"<tr><th>"&king.lang("link/logo")&"</th><td><input type=""text"" class=""k_input_max"" name=""linkimg"" value="""&data(3,0)&""" maxlength=""250"" />"'Logo图片
	ol=ol&king.check("linkimg|6|link/tip/linkimg|0-250;linkimg|5|link/tip/linkimg")
	ol=ol&"</td></tr>"
	ol=ol&"<tr><th>"&king.lang("link/desc")&"</th>"'网站简介
	ol=ol&"<td><textarea name=""linkdesc"" rows=""4"" cols=""50"" class=""k_text_mid"">"&htmlencode(data(1,0))&"</textarea>"
	ol=ol& king.check("linkdesc|6|link/tip/linkdesc|1-50")
	ol=ol&"</td></tr>"

	ol=ol&"</table>"

	ol=ol&"<div id=""k_active"">"
	ol=ol&"<input type=""hidden"" name=""king"" value=""kingcms"" />"
	ol=ol&"<input type=""hidden"" name=""re"" value="""&re&""" />"
	ol=ol&"<input class=""submit"" type=""submit"" name=""submits"" value="""&king.lang("common/add")&""" /> "
	ol=ol&"<input type=""button"" name=""submits"" value="""&king.lang("common/back")&""" onClick=""javascript:history.back();"" />"
	ol=ol&"</div></form>"

	if king.checkerr and llll(l1l(left(ll11l("111"),16)))=l1l(ll11l("111")) then
		for i=1 to ubound(dataform)
			data(i,0)=lll(dataform(i))
		next
		conn.execute "insert into kinglink (linkname,linkdesc,linkurl,linkimg,linkshow,linkdate,sysdate) values ('"&data(0,0)&"','"&data(1,0)&"','"&data(2,0)&"','"&data(3,0)&"',0,'"&tnow&"','"&tnow&"')"

		ol="<div class=""k_form""><h6>"&king.lang("common/submitok")&"</h6>"
		ol=ol&"<p>"&king.lang("link/tip/ok")&"</p>"
		ol=ol&"<p><a href=""/"">1. "&king.lang("back/home")&"</a></p>"
		ol=ol&"<p><a href="""&re&""">2. "&re&"。</a></p>"
		ol=ol&"</div>"
	end if
	king.value "title",encode(fb.lang("common/title"))
	king.value "inside",encode(king.writeol)

end sub
'outhtm  *** ***  www.KingCMS.com  *** ***
sub king_outhtm()
%>{king:addlink/}<%end sub%>