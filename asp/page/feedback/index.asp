<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'       发帖页面
'***  ***  ***  ***  ***

dim fb
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set fb=new feedback
	select case action
	case "" king_def
	case "post" king_post
	end select
set fb=nothing
set king=nothing
'write  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()

	dim sql,rs,data,dp,i,rn,pid,I1
	pid=quest("pid",0):if len(pid)=0 then pid=1
	rn=quest("rn",0):if len(rn)=0 then rn=50
	sql="fbid,fbtitle,fbcontent,fbname,fbmail,fbtel,fbphone,fbip,fbdate,fbreplyname,fbreplycontent,fbreplydate"

	king.ol="<div id=""k_feedback"">"
	king.ol="<a href=index.asp?action=post title=""发表留言"">发表留言</a> &nbsp;&nbsp;&nbsp;&nbsp;  <a href=index.asp title=""浏览留言"">浏览留言</a>"

	king.ol="<div class=""k_form"">"
	set dp=new record
		dp.create "select "&sql&" from king"&fb.path&" where fbshow=1 order by fbid desc;"
		king.ol=dp.plist
		for i=0 to dp.length
			king.ol="<div class=""k_info"" style=""width:100%;height:190px;margin:5px 0px;text-align:left;display:table;border:1px solid #c6c6c6;"">"
			king.ol="<div class=""k_title"" style=""width:98%;height:25px;margin:0px 2px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span>"&fb.lang("list/title")&":"&htmlencode(dp.data(1,i))&"</span></div>"
			king.ol="<div class=""k_info_left"" style=""float:left;width:25%;height:170px;text-align:left;display:table;"">"
			king.ol="<div class=""k_author"" style=""width:95%;height:25px;margin:3px 3px;text-align:left;display:table;""><span>"&fb.lang("list/name")&":"&htmlencode(dp.data(3,i))&"</span></div>"
			king.ol="<div class=""k_mail"" style=""width:95%;height:25px;margin:3px 3px;text-align:left;display:table;""><span>"&fb.lang("list/mail")&":"&htmlencode(dp.data(4,i))&"</span></div>"
			if len(dp.data(5,i))>0 then
				king.ol="<div class=""k_tel"" style=""width:95%;height:25px;margin:3px 3px;text-align:left;display:table;""><span>"&fb.lang("list/tel")&":"&htmlencode(dp.data(5,i))&"</span></div>"
			end if
			if len(dp.data(6,i))>0 then
				king.ol="<div class=""k_phone"" style=""width:95%;height:25px;margin:3px 3px;text-align:left;display:table;""><span>"&fb.lang("list/phone")&":"&htmlencode(dp.data(6,i))&"</span></div>"
			end if
			king.ol="<div class=""k_ip"" style=""width:95%;height:25px;margin:3px 3px;text-align:left;display:table;""><span>"&fb.lang("list/ip")&":"&htmlencode(dp.data(7,i))&"</span></div>"
			king.ol="</div>"
			king.ol="<div class=""k_info_right"" style=""float:left;width:74%;height:170px;text-align:left;display:table;border-left:1px solid #c6c6c6;"">"
			king.ol="<div class=""k_authorinfo"" style=""width:98%;height:25px;margin:0px 5px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span>[NO."&htmlencode(dp.data(0,i))&"]发表于 "&htmlencode(dp.data(8,i))&"</span></div>"
			king.ol="<div class=""k_content"" style=""width:98%;height:125px;margin:0px 5px;text-align:left;display:table;"">"&king.ubbencode(dp.data(2,i))
			if len(dp.data(10,i))>0 then
				king.ol="<div class=""k_reply"" style=""float:right;width:74%;height:70px;margin:5px 5px;text-align:left;border:1px solid #c6c6c6;bottom:5px;"">"
				king.ol="<div class=""k_admin"" style=""width:98%;height:25px;margin:0px 5px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span>"&htmlencode(dp.data(9,i))&"回复于 "&htmlencode(dp.data(11,i))&"</span></div>"
				king.ol="<div class=""k_replycontent"">"&king.ubbencode(dp.data(10,i))&"</div>"
				king.ol="</div>"
			end if
			king.ol="</div>"
			king.ol="</div>"
			king.ol="</div>"
		next
		king.ol=dp.plist
	set dp=nothing
	king.ol="</div>"

	king.ol="</div>"

	king.value "title",encode(fb.lang("common/title"))
	king.value "inside",encode(king.writeol)
	king.outhtm fb.template,"",king.invalue

	
end sub
'write  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_post()

	dim sql,data,dataform,i,re,count
	sql="fbtitle,fbcontent,fbname,fbmail,fbtel,fbphone,fbshow"

	re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="/"

	if king_dbtype=1 then
		count=conn.execute("select count(*) from king"&fb.path&" where fbip='"&safe(king.ip)&"' and getdate()-fbdate<0.25;")(0)
	else
		count=conn.execute("select count(*) from king"&fb.path&" where fbip='"&safe(king.ip)&"' and now()-fbdate<0.25;")(0)
	end if

	king.ol="<div id=""k_feedback"">"
	king.ol="<a href=index.asp?action=post title=""发表留言"">发表留言</a> &nbsp;&nbsp;&nbsp;&nbsp;  <a href=index.asp title=""浏览留言"">浏览留言</a>"

	if cdbl(count)<fb.count then'提交的次数小于预设的上限


		dataform=split(sql,",")
		redim data(ubound(dataform))
		if king.ismethod then
			for i=0 to ubound(dataform)
				data(i)=form(dataform(i))
			next
		end if

		king.ol="<div class=""k_form"">"
		king.ol="<form name=""form1"" method=""post"" action=""index.asp?action=post"" class=""k_form"">"

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
		king.ol="</div>"

		if king.ismethod and king.ischeck then
			conn.execute "insert into king"&fb.path&" ("&sql&",fbip,fbdate) values ('"&safe(data(0))&"','"&safe(data(1))&"','"&safe(data(2))&"','"&safe(data(3))&"','"&safe(data(4))&"','"&safe(data(5))&"','"&safe(fb.fbshow)&"','"&safe(king.ip)&"','"&safe(tnow)&"');"
			king.clearol
			king.ol="<div id=""k_feedback"">"
			king.ol="<a href=index.asp?action=post title=""发表留言"">发表留言</a> &nbsp;&nbsp;&nbsp;&nbsp;  <a href=index.asp title=""浏览留言"">浏览留言</a>"
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
	king.ol="</div>"

	king.value "title",encode(fb.lang("common/title"))
	king.value "inside",encode(king.writeol)
	king.outhtm fb.template,"",king.invalue

	
end sub
%>