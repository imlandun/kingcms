<!--#include file="../system/plugin.asp"-->
<%
dim fb
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set fb=new feedback
	select case action
	case"" king_def
	case"edt" king_edt
	case"set" king_set
	case"create" king_create
	case"up","down" king_updown
	case"view" king_view
	case"reply" king_reply
	case"template" king_fbtemplate
	case"fbshow" king_fbshow
	end select
set fb=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_fbtemplate()
	king.nocache
	king.head king.path,0
	dim l3
	l3=conn.execute("select fbtemplate from king"&fb.path&"_config;")(0)
	king.ol="<div class=""k_form"">"
	king.ol="<p><label>"&fb.lang("label/template")&"</label>"
	king.ol="<select id=""k_template"">"
	king.ol=king.getfolder ("../../"&king_templates,king_te,"<option value=""$fname$"" $selected$>$fname$</option>",htmlencode(l3))
	king.ol="</select></p>"
	king.ol="<div><input type=""button"" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=template&template='+document.getElementById('k_template').options[document.getElementById('k_template').selectedIndex].value);"" value="""&king.lang("common/up")&""" /></div>"
	king.ol="</div>"
	king.flo king.writeol,2
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_fbshow()
	king.nocache
	king.head king.path,0
	dim l3,kfbshow0,kfbshow1
	l3=conn.execute("select fbshow from king"&fb.path&"_config;")(0)
	if l3=0 then : kfbshow0=" selected=""selected""" : else kfbshow0="" :end if
	if l3=1 then : kfbshow1=" selected=""selected""" : else kfbshow1="" :end if
	king.ol="<div class=""k_form"">"
	king.ol="<p><label>"&fb.lang("label/isview")&"</label>"
	king.ol="<select id=""kfbshow"">"
	king.ol="<option value=0 "&kfbshow0&">"&encode(fb.lang("label/v0"))&"</option>"
	king.ol="<option value=1 "&kfbshow1&">"&encode(fb.lang("label/v1"))&"</option>"
	king.ol="</select></p>"
	king.ol="<div><input type=""button"" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=fbshow1&fbshow='+document.getElementById('kfbshow').value);"" value="""&king.lang("common/up")&""" /></div>"
	king.ol="</div>"
	king.flo king.writeol,2
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,fb.lang("common/title")
	dim rs,data,i,dp'lpath:linkpath
	dim but,sql,insql

	if cstr(quest("tag",2))="1" then insql=" where istag=1 "

	fb.list

	sql="select fbid,isview,istag,fbtitle,fbip,fbdate,fbname,fbmail,fbshow from king"&fb.path&insql&" order by fbid desc;"

	set dp=new record
		dp.create sql
		dp.but=dp.sect("tag1:"&encode(fb.lang("common/tag1"))&"|tag0:"&encode(fb.lang("common/tag0")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+setag('index.asp?action=set',K[0],K[2])+' <span '+isview(K[1])+'><a href=""javascript:;"" onclick=""posthtm(\'index.asp?action=view\',\'aja\',\'fbid='+K[0]+'\')"">'+K[3]+'</a></span>'"
		dp.js="K[6]"
		dp.js="K[7]"
		dp.js="setag('index.asp?action=set',K[0],K[8],'fbshow')"
		dp.js="K[4]"
		dp.js="K[5]"

		Il dp.open

		Il "<tr><th>"&fb.lang("list/title")&"</th><th>"&fb.lang("list/name")&"</th><th>"&fb.lang("list/mail")&"</th><th>"&fb.lang("label/fbshow")&"</th><th>"&fb.lang("list/ip")&"</th><th>"&fb.lang("list/date")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			
			Il "ll("&dp.data(0,i)&","&dp.data(1,i)&","&dp.data(2,i)&",'"&htm2js(dp.data(3,i))&"','"&htm2js(dp.data(4,i))&"','"&htm2js(dp.data(5,i))&"','"&htm2js(dp.data(6,i))&"','"&htm2js(dp.data(7,i))&"',"&dp.data(8,i)&");"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_view()
	king.nocache
	king.head king.path,0
	dim fbid,rs,data
	fbid=form("fbid")
	if validate(fbid,2)=false then exit sub
	
	king.aja fb.lang("common/title")&" - "&fb.lang("common/view"),"<iframe src=""index.asp?action=reply&fbid="&fbid&""" width=""99%"" height=""99%""></iframe>"
			
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_reply()
	king.nocache
	king.head king.path,0
	dim fbid,rs,data,dataform,sql,i
	sql="fbid,fbtitle,fbname,fbmail,fbtel,fbphone,fbcontent,fbip,fbdate,fbreplycontent"'9
	fbid=quest("fbid",2)
	if len(fbid)=0 then:fbid=form("fbid")
	if len(fbid)>0 then'若有值的情况下
		if validate(fbid,2)=false then king.error king.lang("error/invalid")
	end if
	
	if king.ismethod then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from king"&fb.path&" where fbid="&fbid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if
	king.ol="<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd""><html xmlns=""http://www.w3.org/1999/xhtml""><head><meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8""/><script src=""../system/images/jquery.js"" type=""text/javascript""></script><script src=""../system/images/jquery.kc.js"" type=""text/javascript""></script><title>"&fb.lang("common/title")&" - "&fb.lang("common/view")&"</title><link href=""../system/images/style.css"" rel=""stylesheet"" type=""text/css"" /></head><body>"
	king.ol="<div  style=""width:100%;margin-top:5px;background-color:#FFF;text-align:left;display:table;border:1px solid #c6c6c6;"">"
	king.ol="<form name=""form1"" method=""post"" action=""index.asp?action=reply"" class=""k_form"">"
	king.ol="<div class=""k_title"" style=""width:98%;height:25px;margin:3px 3px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span style=""float:left;width:25%;text-align:center;display:block;"">"&fb.lang("list/title")&":</span><span style=""width:75%;display:block;"">"&htmlencode(data(1,0))&"</span></div>"
	king.ol="<div class=""k_authorinfo"" style=""width:98%;height:25px;margin:3px 3px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span style=""float:left;width:25%;text-align:center;display:block;"">[NO."&htmlencode(data(0,0))&"]</span><span style=""width:75%;display:block;"">发表于 "&htmlencode(data(8,0))&"</span></div>"
	king.ol="<div class=""k_author"" style=""width:98%;height:25px;margin:3px 3px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span style=""float:left;width:25%;text-align:center;display:block;"">"&fb.lang("list/name")&":</span><span style=""width:75%;display:block;"">"&htmlencode(data(2,0))&"</span></div>"
	king.ol="<div class=""k_mail"" style=""width:98%;height:25px;margin:3px 3px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span style=""float:left;width:25%;text-align:center;display:block;"">"&fb.lang("list/mail")&":</span><span style=""width:75%;display:block;"">"&htmlencode(data(3,0))&"</span></div>"
	king.ol="<div class=""k_tel"" style=""width:98%;height:25px;margin:3px 3px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span style=""float:left;width:25%;text-align:center;display:block;"">"&fb.lang("list/tel")&":</span><span style=""width:75%;display:block;"">"&htmlencode(data(4,0))&"</span></div>"
	king.ol="<div class=""k_phone"" style=""width:98%;height:25px;margin:3px 3px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span style=""float:left;width:25%;text-align:center;display:block;"">"&fb.lang("list/phone")&":</span><span style=""width:75%;display:block;"">"&htmlencode(data(5,0))&"</span></div>"
	king.ol="<div class=""k_ip"" style=""width:98%;height:25px;margin:3px 3px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><span style=""float:left;width:25%;text-align:center;display:block;"">"&fb.lang("list/ip")&":</span><span style=""width:75%;display:block;"">"&htmlencode(data(7,0))&"</span></div>"
	king.ol="<div class=""k_content"" style=""width:98%;height:125px;margin:0px 5px;text-align:left;display:table;border-bottom:1px solid #c6c6c6;""><label>"&fb.lang("list/content")&"</label><p>"&king.ubbencode(data(6,0))&"</p></div>"
	king.ol="<div class=""k_replycontent"" style=""width:98%;margin:0px 5px;text-align:left;display:table;""><label>"&fb.lang("list/content")&":</label>"
	king.ol=king.ubbshow("fbreplycontent",htmlencode(data(9,0)),60,10,0)&"</div>"
	king.ol="<div style=""width:98%;margin:0px 5px;text-align:center;display:table;"">"
	king.ol="<input type=""submit"" value="""&king.lang("common/submit")&""" /> "
	king.ol="<input type=""button"" onclick=""javascript:window.parent.display('aja');"" value="""&king.lang("common/close")&""" />"
	king.ol="<input type=""hidden"" name=""fbid"" id=""fbid"" value="""&fbid&""" />"
	king.ol="</div>"
	king.ol="</form>"
	king.ol="</div></body></html>"
	if king.ismethod=false then conn.execute "update king"&fb.path&" set isview=1 where fbid="&fbid&";"
	if king.ismethod and king.ischeck then
		conn.execute "update king"&fb.path&" set fbreplyname='"&safe(king.name)&"',fbreplycontent='"&safe(data(9,0))&"',fbreplydate='"&safe(tnow)&"' where fbid="&fbid&";"
		king.clearol
		king.ol="<script language=""javascript"">location=document.referrer;</script>"
	end if
	king.txt king.writeol
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.head king.path,0
	dim list,rs,data,i,id,url,tag
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	select case form("submits")
	case"tag0","tag1"
		if len(list)>0 then
			if form("submits")="tag0" then
				conn.execute "update king"&fb.path&" set istag=0 where fbid in ("&list&");"
			else
				conn.execute "update king"&fb.path&" set istag=1 where fbid in ("&list&");"
			end if
			king.flo fb.lang("flo/tagok"),1
		else
			king.flo fb.lang("flo/select"),0
		end if
	case"tag"
		id=safe(form("id"))
		url=form("url")
		tag=form("tag"):if cstr(tag)="1" then tag=0 else tag=1
		conn.execute "update king"&fb.path&" set istag="&tag&" where fbid="&id&";"
		king.txt "<img onclick=""javascript:posthtm('"&url&"','tag_"&id&"','submits=tag&url="&server.urlencode(url)&"&id="&id&"&tag="&tag&"');"" src=""../system/images/os/tag"&tag&".gif""/>"
	case"fbshow"
		id=safe(form("id"))
		url=form("url")
		tag=form("tag"):if cstr(tag)="1" then tag=0 else tag=1
		conn.execute "update king"&fb.path&" set fbshow="&tag&" where fbid="&id&";"
		king.txt "<img onclick=""javascript:posthtm('"&url&"','tag_fbshow"&id&"','submits=fbshow&url="&server.urlencode(url)&"&id="&id&"&tag="&tag&"');"" src=""../system/images/os/tag"&tag&".gif""/>"
	case"delete"
		if len(list)>0 then
			conn.execute "delete from king"&fb.path&" where fbid in ("&list&") and istag=0;"
			king.flo fb.lang("flo/deleteok"),1
		else
			king.flo fb.lang("flo/select"),0
		end if
	case"template"
		if len(form("template"))>0 and king.isexist("../../"&king_templates&"/"&form("template")) then
			conn.execute "update king"&fb.path&"_config set fbtemplate='"&safe(form("template"))&"';"
			king.flo fb.lang("flo/template"),0
		else
			king.flo king.lang("error/invalid"),0
		end if
	case"fbshow1"
		if len(form("fbshow"))>0 then
			conn.execute "update king"&fb.path&"_config set fbshow='"&safe(form("fbshow"))&"';"
			king.flo fb.lang("flo/fbshow"),0
		else
			king.flo king.lang("error/invalid"),0
		end if
	end select
end sub

%>