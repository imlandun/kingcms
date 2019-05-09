<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'       发帖页面
'***  ***  ***  ***  ***

dim fb
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set fb=new feedback
	king_def
set fb=nothing
set king=nothing
'def  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()

	dim sql,data,dataform,i,re,count
	sql="fbtitle,fbcontent,fbname,fbmail,fbtel,fbphone"

	re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="/"

	if king_dbtype=1 then
		count=conn.execute("select count(*) from king"&fb.path&" where fbip='"&safe(king.ip)&"' and getdate()-fbdate<0.25;")(0)
	else
		count=conn.execute("select count(*) from king"&fb.path&" where fbip='"&safe(king.ip)&"' and now()-fbdate<0.25;")(0)
	end if

	if cdbl(count)<fb.count then'提交的次数小于预设的上限


		dataform=split(sql,",")
		redim data(ubound(dataform))
		if king.ismethod then
			for i=0 to ubound(dataform)
				data(i)=form(dataform(i))
			next
		end if

		king.ol="<form name=""form1"" method=""post"" action=""index.asp"" class=""k_form"">"

		king.ol="<p><label>"&fb.lang("label/title")&"</label>"
		king.ol="<input class=""k_in4"" type=""text"" name=""fbtitle"" value="""&data(0)&""" maxlength=""50"" />"
		king.ol=king.check("fbtitle|6|"&encode(fb.lang("check/title"))&"|4-50")&"</p>"

		king.ol="<p><label>"&fb.lang("label/content")&"</label>"
		king.ol=king.ubbshow("fbcontent",htmlencode(data(1)),60,10,0)
		king.ol=king.check("fbcontent|6|"&encode(fb.lang("check/content"))&"|10-1000")&"</p>"

		king.ol="<p><label>"&fb.lang("label/name")&"</label>"
		king.ol="<input class=""k_in3"" type=""text"" name=""fbname"" value="""&data(2)&""" maxlength=""30"" />"
		king.ol=king.check("fbname|6|"&encode(fb.lang("check/name"))&"|2-30")&"</p>"

		king.ol="<p><label>"&fb.lang("label/mail")&"</label>"
		king.ol="<input class=""k_in3"" type=""text"" name=""fbmail"" value="""&data(3)&""" maxlength=""100"" />"
		king.ol=king.check("fbmail|6|"&encode(fb.lang("check/mail"))&"|6-100;fbmail|4|"&encode(fb.lang("check/mail")))&"</p>"

		king.ol="<p><label>"&fb.lang("label/tel")&"</label>"
		king.ol="<input class=""k_in3"" type=""text"" name=""fbtel"" value="""&data(4)&""" maxlength=""30"" />"
		king.ol=king.check("fbtel|6|"&encode(fb.lang("check/tel"))&"|0-30")&"</p>"

		king.ol="<p><label>"&fb.lang("label/phone")&"</label>"
		king.ol="<input class=""k_in3"" type=""text"" name=""fbphone"" value="""&data(5)&""" maxlength=""30"" />"
		king.ol=king.check("fbphone|6|"&encode(fb.lang("check/phone"))&"|0-30")&"</p>"

		king.ol="<div>"
		king.ol="<input type=""submit"" value="""&king.lang("common/submit")&""" /> "
		king.ol="<input name=""re"" type=""hidden"" value="""&formencode(re)&""" />"
		king.ol="</div>"

		king.ol="</form>"

		if king.ismethod and king.ischeck then
			conn.execute "insert into king"&fb.path&" ("&sql&",fbip,fbdate) values ('"&safe(data(0))&"','"&safe(data(1))&"','"&safe(data(2))&"','"&safe(data(3))&"','"&safe(data(4))&"','"&safe(data(5))&"','"&safe(king.ip)&"','"&safe(tnow)&"');"
			king.clearol
			king.ol="<div class=""k_form"">"
			king.ol="<ol>"
			king.ol="<li>"&fb.lang("list/ok")&"</li>"
			king.ol="<li><a href=""/"">"&fb.lang("list/home")&"</a></li>"
			king.ol="<li><a href="""&re&""">"&re&"</a></li>"
			king.ol="</ol>"
			king.ol="</div>"
		end if
	else
		king.ol="<div class=""k_form"">"
		king.ol="<ol>"
		king.ol="<li>"&fb.lang("list/iplock")&"</li>"
		king.ol="<li><a href=""/"">"&fb.lang("list/home")&"</a></li>"
		king.ol="<li><a href="""&re&""">"&re&"</a></li>"
		king.ol="</ol>"
		king.ol="</div>"
		
	end if

	king.value "title",encode(fb.lang("common/title"))
	king.value "inside",encode(king.writeol)
	king.outhtm fb.template,"",king.invalue

	
end sub
%>