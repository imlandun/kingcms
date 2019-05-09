<!--#include file="config.asp" -->
<%
set king=new kingcms
select case action
case"" king_def
case"diymenu","diymnu" king_diymenu
case"logout" king_logout
case"config" king_config
case"myaccount","myacccount" king_myaccount
case"plugin" king_plugin
case"pluginset" king_pluginset
case"log" king_log
case"logset" king_logset
case"admin" king_admin
case"adminedt" king_adminedt
case"adminset" king_adminset
case"newversion" king_newversion
case"rss" king_rss
case"rssset" king_rssset
case"bot" king_bot
case"botset" king_botset
case"set" king_set
case"filemanage","filemanage_createfolder","filemanage_upfile","upfile","filemanage_delete","filemanage_deletefolder" king_filemanage
case"showimg" king_showimg
case"update" king_olupdate
end select
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_olupdate()
	Server.ScriptTimeOut=86400
	king.nocache
	king.head 0,0
	dim I4,I1
	dim ver,xml,item,i
	dim filepath,filetext

	ver=form("ver")
	I4=king.gethtm("http://www."&king.systemname&".cn/KingCMS_Update_"&ver&".xml",5)
	if len(I4)>0 then'如果有资料
		if left(I4,5)="<?xml" then
'	out I4
			set xml=server.createobject(king_xmldom)
			xml.async=false
			xml.loadxml(I4)
			if xml.readystate>2 then
				set item=xml.getelementsbytagname("item")
				for i=0 to (item.length-1)
					set filepath=item.item(i).getelementsbytagname("file")
					set filetext=item.item(i).getelementsbytagname("text")
					if lcase(king.extension(filepath.item(0).text))="xml" then
						king.savetofile replace(filepath.item(0).text,"[king_system]",king_system),replace(filetext.item(0).text,"]]!>","]]"&chr(62))
					else
						king.savetofile replace(filepath.item(0).text,"[king_system]",king_system),filetext.item(0).text
					end if
				next
			end if
			I1=king.lang("parameters/upok")
		else
			I1=king.lang("parameters/notup")
		end if
	else
		I1=king.lang("parameters/notup")
	end if
	king.flo I1,1
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_showimg()
	king.head 0,0
	dim path
	path=form("path")
	king.aja king.lang("common/brow"),"<div class=""k_form""><p><a href=""javascript:;"" onclick=""javascript:display('aja');"">["&king.lang("common/close")&"]</a></p><p><img src="""&path&"""/></p></div>"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_filemanage()
	king.nocache
	king.head "brow",0

	dim path,paths,formname,ftype
	dim fs,item,filecate,back,imgsize

	formname=form("formname")
	ftype=form("type")
	path=form("path")

	if len(path)=0 or king.isexist(path)=false then
		path=king.inst&king_upath&"/"
		king.createfolder path
	end if
	paths=split(path,"/")

	king.ol="<div class=""k_form"">"

	select case action
	case"filemanage_createfolder"
		if len(form("fdname"))>0 then
			if right(path,1)<>"/" then path=path&"/"
			king.createfolder path&form("fdname")
		else
			if len(form("is"))=0 then
				king.ol="<p><label>"&king.lang("brow/fdname")&"</label><input type=""text"" id=""fdname"" class=""in3"" /></p>"
				king.ol="<div class=""k_but""><input type=""button"" value="""&king.lang("common/submit")&""" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage_createfolder','aja','is=KingCMS&formname="&formname&"&path="&server.urlencode(path)&"&type="&server.urlencode(ftype)&"&fdname='+encodeURIComponent(document.getElementById('fdname').value));display('flo');"" /></div>"
				king.ol="</div>"
				king.flo king.writeol,2
			end if
		end if
	case"filemanage_delete"
		king.deletefile path&form("fname")
	case"filemanage_deletefolder"
'		king.ol=path&form("fname")
		king.deletefolder path&form("fname")
	case"filemanage_upfile"
		king.ol="<iframe src=""../system/manage.asp?action=upfile&path="&server.urlencode(path)&"&type="&ftype&"&formname="&formname&""" frameborder=""0"" scrolling=""none"" marginwidth=""0"" marginheight=""0"" width=""300"" height=""50""></iframe>"
		king.ol="</div>"
		king.flo king.writeol,2
	case"upfile"
		king.clearol
		king.ol="<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />"
		king.ol="<style type=""text/css"">*{margin:0px;padding:0px;}</style>"
		if instr(lcase(request.servervariables("content_type")),"multipart/form-data") then
			upload.FileType=ftype
			upload.SavePath=""
			if right(path,1)<>"/" then path=path&"/"
			if upload.save("upfile",path&upload.form("upfile_name")) then'成功上传
				king.txt "<script>window.parent.posthtm('../system/manage.asp?action=filemanage','aja','path="&server.urlencode(path&upload.form("upfile_name"))&"&type="&ftype&"&formname="&formname&"');window.parent.display('flo');</script>"'king.lang("'上传成功'")
			else
				back="../system/manage.asp?action=upfile&path="&server.urlencode(path)&"&type="&ftype&"&formname="&formname&""
				king.txt"<p style=""font-size:12px;line-height:22px;"">"&king.lang("error/upfile/err"&upload.error)&"<br/><a style=""color:#000;"" href="""&back&""">"&king.lang("common/back")&"</a></p>"
			end if
		else
			king.ol="<form name=""form1"" enctype=""multipart/form-data"" method=""post"" action=""../system/manage.asp?action=upfile"">"
			king.ol="<p><input style=""width:250px;border:1px solid;border-color:#333 #CCC #CCC #333;"" name=""upfile"" type=""file"" /></p>"
			king.ol="<p><input type=""submit"" value="""&king.lang("common/upfile")&""" style=""border:1px solid;border-color:#CCC #777 #777 #CCC;padding:2px;margin:0px;font-size:12px;margin-right:4px;background-color:#D4D0C8;"" />"
			king.ol="<input type=""hidden"" name=""type"" value="""&quest("type",0)&"""/>"
			king.ol="<input type=""hidden"" name=""path"" value="""&quest("path",0)&"""/>"
			king.ol="<input type=""hidden"" name=""formname"" value="""&quest("formname",0)&"""/></p>"
			king.ol="</form>"
			king.txt king.writeol
		end if
	end select

	'导航
	king.ol="<p>"
	if instr(paths(ubound(paths)),".")=0 then'如果是文件名，则需要进行判断
		king.ol="<span class=""file"">"

		if path<>"/" then
			king.ol="<a href=""javascript:;"" onclick=""javascript:confirm('"&king.lang("confirm/delete")&"')?posthtm('../system/manage.asp?action=filemanage_deletefolder','aja','formname="&formname&"&path="&server.urlencode(left(path,len(path)-len(paths(ubound(paths)))))&"&type="&server.urlencode(ftype)&"&fname="&server.urlencode(paths(ubound(paths)))&"'):void(1);"">"
			king.ol="<img src=""../system/images/os/del.gif"" alt="""&king.lang("common/delete")&"""/></a>"
		end if

		king.ol="<a href=""javascript:;"""
		king.ol=" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage_createfolder','flo','formname="&formname&"&path="&server.urlencode(path)&"&type="&server.urlencode(ftype)&"');"">"
		king.ol="<img src=""../system/images/os/file/crtdir.gif"" alt="""&king.lang("common/createfolder")&"""/></a>"
		king.ol="<a href=""javascript:;"""
		king.ol=" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage_upfile','flo','formname="&formname&"&path="&server.urlencode(path)&"&type="&server.urlencode(ftype)&"');""><img src=""../system/images/os/file/up.gif"" alt="""&king.lang("common/upfile")&"""/></a></span>"
	end if
	king.ol="<img src=""../system/images/os/dir2.gif""/> <a href=""javascript:;"" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage','aja','formname="&formname&"&path=%2F&type="&server.urlencode(ftype)&"');"">Root</a>: "
	king.ol=king_filemanage_list(path,formname,server.urlencode(ftype))

	king.ol="</p>"

	if instr(paths(ubound(paths)),".")>0 then'如果是文件名，则需要进行判断
		set fs=server.createobject(king_fso)
		if fs.fileexists(server.mappath(path)) then
			
			king.ol="<p><a href=""javascript:;"" onclick=""javascript:document.getElementById('"&formname&"').value='"&htm2js(path)&"';display('aja');"">["&king.lang("common/insert")&"]</a>"
			king.ol="<a href=""javascript:;"" onclick=""javascript:confirm('"&king.lang("confirm/delete")&"')?posthtm('../system/manage.asp?action=filemanage_delete','aja','formname="&formname&"&path="&server.urlencode(left(path,len(path)-len(paths(ubound(paths)))))&"&type="&server.urlencode(ftype)&"&fname="&server.urlencode(paths(ubound(paths)))&"'):void(1);"">["&king.lang("common/delete")&"]</a><a href=""javascript:;"" onclick=""javascript:display('aja');"">["&king.lang("common/close")&"]</a></p>"
			filecate=king.filecate(king.extension(paths(ubound(paths))))
			if filecate="img" then'图片
				king.ol="<p><a href="""&path&""" target=""_blank""><img style=""border:1px solid #666;padding:3px;"" src="""&path&"""/></a></p>"

			else
				king.ol="<p><img src=""../system/images/os/file/"&filecate&".gif""/>"&path&"</p>"
			end if

			set item=fs.getfile(server.mappath(path))

			king.ol="<p><label>"&king.lang("brow/name")&" : "&item.name&"</label></p>"
			king.ol="<p><label>"&king.lang("brow/type")&" : "&item.type&"</label></p>"
			king.ol="<p><label>"&king.lang("brow/size")&" : "&king.formatsize(item.size)&"</label></p>"
			if filecate="img" then
				imgsize=king.imgsize(path)
				if len(imgsize)>0 then
					king.ol="<p><label>"&king.lang("brow/imgsize")&" : "&imgsize&" pixels</label></p>"
				end if
			end if
			king.ol="<p><label>"&king.lang("brow/datecreated")&" : "&item.datecreated&"</label></p>"
			king.ol="<p><label>"&king.lang("brow/date")&" : "&item.datelastmodified&"</label></p>"
			set item=nothing
		else
			king.ol="<p class=""k_error"">"&king.lang("error/brow")&"</p>"
		end if
		set fs=nothing

		king.aja king.lang("brow/title"),king.writeol
	end if


	'main
	king.ol=king_filemanage_main(path,formname,ftype)
	king.ol="</div>"

	king.aja king.lang("brow/title"),king.writeol
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_filemanage_main(l1,l2,l3)
	
	dim l5,l6,l8,fs,I1,I2,paths,i,ext

	paths=split(l1,"/")

	if instr(paths(ubound(paths)),".")=0 then
		if right(l1,1)<>"/" then
			l1=l1&"/"
			paths=split(l1,"/")
		end if
	end if

	for i=1 to ubound(paths)-1
		I2=I2&"/"&paths(i)
	next
	I2=I2&"/"
	
	set fs=Server.CreateObject(king_fso)
	l8=server.mappath(l1)
	set l5=fs.getfolder(l8)
		I1="<p class=""file"">"
		for each l6 in l5.subfolders
			I1=I1&"<a href=""javascript:;"" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage','aja','type="&l3&"&formname="&l2&"&path="&server.urlencode(I2&l6.name)&"');"">"
			I1=I1&"<img src=""../system/images/os/file/dir.gif""/>"&htmlencode(l6.name)
			I1=I1&"</a>"
		next

		I1=I1&"</p><hr/><p class=""file"">"

		for each l6 in l5.files
			if len(l3)>0 then
				ext=king.extension(l6.name)
				if king.instre(replace(l3,"/",","),ext) then
					I1=I1&"<a href=""javascript:;"""
					I1=I1&" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage','aja','type="&server.urlencode(l3)&"&formname="&l2&"&path="&server.urlencode(I2&l6.name)&"');"">"
					I1=I1&"<img src=""../system/images/os/file/"&king.filecate(ext)&".gif""/>"&htmlencode(l6.name)
					I1=I1&"</a>"
				end if
			end if
		next
		I1=I1&"</p>"
	set l5=nothing
	set l6=nothing
	set fs=nothing
	if err.number<>0 then err.clear
	king_filemanage_main=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_filemanage_list(l1,l2,l3)
	dim I1,paths,i,I2,fname
		
	paths=split(l1,"/")

	if instr(paths(ubound(paths)),".")=0 then
		if right(l1,1)<>"/" then
			l1=l1&"/"
			paths=split(l1,"/")
		end if
	else
		fname="/<strong>"&paths(ubound(paths))&"</strong>"
	end if

	for i=1 to ubound(paths)-2
		I2=I2&"/"&paths(i)
		I1=I1&"/<a href=""javascript:;"" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage','aja','type="&l3&"&formname="&l2&"&path="&server.urlencode(I2)&"')"">"&paths(i)&"</a>"
	next
	
	if len(fname)>0 then
		if ubound(paths)>1 then
			I1=I1&"/<a href=""javascript:;"" onclick=""javascript:posthtm('../system/manage.asp?action=filemanage','aja','type="&l3&"&formname="&l2&"&path="&server.urlencode(I2&"/"&paths(i))&"')"">"&paths(i)&"</a>"&fname
		else
			I1=I1&fname
		end if
	else
		I1=I1&"/<strong>"&paths(i)&"</strong>"
	end if

	if len(I2)>0 then
		king.createfolder I2&"/"&paths(i)
	end if
	king_filemanage_list=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()

	king.head "0",king.lang("manage/title")

	if managedir="admin" then Il "<script>alert('您的后台目录名为admin，具有很大安全隐患，请尽快更改后台目录名以保证安全!\n\n建议：目录名设为6位以上、尽量复杂一些！');</script>"

	dim rs,dp,i

	Il "<h2>"&king.lang("manage/title")&"</h2>"

	set rs=conn.execute("select systemver,dbver,systemname,instdate from kingsystem where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			Il "<table class=""k_table"" cellspacing=""0"">"
			Il "<tr><th class=""w0"">"&king.lang("parameters/system")&"</th><th>"&king.lang("parameters/server")&"</th></tr>"
			Il "<tr><td>"&king.lang("parameters/systemname")&" -&rsaquo; "&rs(2)&"</td><td>FSO -&rsaquo; "&king.isobj(king_fso)&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/systemver")&" -&rsaquo; "&king.systemver&"</td><td>ASPJPEG/1.5 -&rsaquo; "&king.isobj("Persits.Jpeg")&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/newversion")&" -&rsaquo; <span id=""newversion""></span></td><td>ADODB.STREAM -&rsaquo; "&king.isobj(king_stm)&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/dbver")&" -&rsaquo; "&rs(1)&"</td>"
				Il "<td>XMLHTTP -&rsaquo; "&king.isobj("Microsoft.XMLHTTP")&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/dbtype/title")&" -&rsaquo; "&king.lang("parameters/dbtype/type"&king_dbtype)&"</td>"
				Il "<td>IIS -&rsaquo; "&Request.ServerVariables("SERVER_SOFTWARE")&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/inst")&" -&rsaquo; "&king.inst&"</td><td>ScriptEngine -&rsaquo; "&ScriptEngineMajorVersion&"."&ScriptEngineMinorVersion&"."& ScriptEngineBuildVersion&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/instdate")&" -&rsaquo; "&rs(3)&"</td><td>ScriptTimeout -&rsaquo; "&Server.ScriptTimeout&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/osite")&" -&rsaquo; <a href=""http://www.kingcms.com"" target=""_blank"">www.KingCMS.com</a></td><td>ServerTime -&rsaquo; "&tnow&"</td></tr>"
			Il "<tr><td>"&king.lang("parameters/mailto")&" -&rsaquo; KingCMS@Gmail.com</td><td>IP -&rsaquo; "&king.ip&"</td></tr>"
			Il "</table>"
		else
			king.deletefile king_system&"system/fun.asp"
		end if
		rs.close
	set rs=nothing

	if king.level="admin" or king.instre(king.level,"log") then
		Il "<h2>"&king.lang("log/title")&"</h2>"
		set dp=new record
			dp.create"select logid,adminname,lognum,ip,logdate from kinglog order by logid desc;"
			dp.purl="manage.asp?action=log&pid=$&rn="&dp.rn
			dp.action="manage.asp?action=logset"
			dp.but=dp.sect("logdelete:"&encode(king.lang("log/delete")))&dp.prn & dp.plist
			dp.js="cklist(K[0])+K[0]+') '+K[1]"
			dp.js="K[2]"
			dp.js="K[3]"
			dp.js="K[4]"

			Il dp.open

			Il "<tr><th>"&king.lang("log/list/id")&") "&king.lang("log/list/name")&"</th>"
			Il "<th>"&king.lang("log/list/num")&"</th><th>"&king.lang("log/list/ip")&"</th><th>"&king.lang("log/list/date")&"</th></tr>"
			Il "<script>"
			for i=0 to dp.length
				
				Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(king.lang("log/l"&dp.data(2,i)))&"','"&dp.data(3,i)&"','"&dp.data(4,i)&"');"
			next
			Il "gethtm('manage.asp?action=newversion','newversion',1);</script>"
			Il dp.close
		set dp=nothing
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function managedir()
	dim dir
    dir = request.servervariables("PATH_INFO")
	dir=left(dir,instrrev(dir,"/system/")-1)
	dir=mid(dir,instrrev(dir,"/")+1)
	managedir=dir
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_newversion()
	king.head 0,0
	king.txt king.getversion()

	if err.number<>0 then
		king.txt king.lang("parameters/newversionerr")
		err.clear
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_logset()
	king.nocache
	king.head"log",0
	dim list,sql

	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if
	select case form("submits")
	case"delete"
		if len(list)>0 then
			conn.execute "delete from kinglog where logid in ("&list&");"
			king.flo king.lang("log/flo/deleteok"),1
		else
			king.flo king.lang("log/flo/select"),0
		end if
	case"logdelete"'删除过期日志 一个月
		if king_dbtype=1 then
			sql="delete from kinglog where getdate()-logdate>30;"
		else
			sql="delete from kinglog where now()-logdate>30;"
		end if
		conn.execute sql
		king.flo king.lang("log/flo/logdeleteok"),1
	end select

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_log()
	king.head "log",king.lang("log/title")
	dim dp,i
	Il "<h2>"&king.lang("log/title")&"</h2>"
	set dp=new record
		dp.create"select logid,adminname,lognum,ip,logdate from kinglog order by logid desc;"
		dp.purl="manage.asp?action=log&pid=$&rn="&dp.rn
		dp.action="manage.asp?action=logset"
		dp.but=dp.sect("logdelete:"&encode(king.lang("log/delete")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+K[0]+') '+K[1]"
		dp.js="K[2]"
		dp.js="K[3]"
		dp.js="K[4]"

		Il dp.open

		Il "<tr><th>"&king.lang("log/list/id")&") "&king.lang("log/list/name")&"</th>"
		Il "<th>"&king.lang("log/list/num")&"</th><th>"&king.lang("log/list/ip")&"</th><th>"&king.lang("log/list/date")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(king.lang("log/l"&dp.data(2,i)))&"','"&dp.data(3,i)&"','"&dp.data(4,i)&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_bot()
	king.head "bot",king.lang("bot/title")
	dim dp,i
	Il "<h2>"&king.lang("bot/title")&"</h2>"
	set dp=new record
		dp.create"select botid,botname,botnumber,botdate,botlastdate from kingbot order by botnumber desc,botid;"
		dp.purl="manage.asp?action=bot&pid=$&rn="&dp.rn
		dp.action="manage.asp?action=botset"
		dp.but=dp.sect("")&dp.prn & dp.plist
		dp.js="cklist(K[0])+K[0]+') '+K[1]"
		dp.js="K[2]"
		dp.js="K[3]"
		dp.js="K[4]"

		Il dp.open

		Il "<tr><th>"&king.lang("bot/list/id")&") "&king.lang("bot/list/name")&"</th>"
		Il "<th>"&king.lang("bot/list/number")&"</th><th>"&king.lang("bot/list/date")&"</th><th>"&king.lang("bot/list/lastdate")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&dp.data(2,i)&"','"&dp.data(3,i)&"','"&dp.data(4,i)&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_botset()
	king.nocache
	king.head"bot",0
	dim list,sql

	list=form("list")
	if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	select case form("submits")
	case"delete"
		conn.execute "delete from kingbot where botid in ("&list&");"
		king.flo king.lang("bot/flo/delete"),1
	end select

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_rss()
	king.head "rss",king.lang("rss/title")
	dim dp,i
	Il "<h2>"&king.lang("rss/title")&"</h2>"
	set dp=new record
		dp.create"select rssid,rsstitle,rsslink,rsspubDate from kingrss where rsstitle<>'' order by rssorder desc;"
		dp.purl="manage.asp?action=rss&pid=$&rn="&dp.rn
		dp.action="manage.asp?action=rssset"
		dp.but=dp.sect("create:"&encode(king.lang("common/create")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+K[4]+') '+K[1]"
		dp.js="'<a href="""&king_system&"system/link.asp?url='+K[2]+'"" target=""_blank"">'+K[2]+'</a>'"
		dp.js="K[3]"

		Il dp.open

		Il "<tr><th>"&king.lang("rss/list/order")&") "&king.lang("rss/list/title")&"</th>"
		Il "<th>"&king.lang("rss/list/link")&"</th><th>"&king.lang("rss/list/date")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(dp.data(2,i))&"','"&dp.data(3,i)&"',"&((dp.pid-1)*dp.rn)+i+1&");"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_rssset()
	king.nocache
	king.head"rss",0
	dim list,sql,rsspath,rsspathbaidu

	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if
	select case form("submits")
	case"delete"
		if len(list)>0 then
			conn.execute "update kingrss set rsstitle='' where rssid in ("&list&");"
			king.createrss
			king.flo king.lang("rss/flo/delete"),1
		else
			king.flo king.lang("rss/flo/select"),0
		end if
	case"create"
		king.createrss
		rsspath=conn.execute("select rsspath from kingsystem")(0)
		rsspathbaidu=king.inst&"baidu_"&rsspath&".xml"
		rsspath=king.inst&rsspath&".xml"

		king.flo king.lang("rss/flo/createok")&"<br/><a href="""&rsspath&""" target=""_blank"">"&king.siteurl&rsspath&"</a><br/><a href="""&rsspathbaidu&""" target=""_blank"">"&king.siteurl&rsspathbaidu&"</a>",1
	end select

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.head 0,0
	dim list,sql,map

	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if
	select case form("submits")
	case"createmap"
		king.createmap
		map=conn.execute("select sitemap from kingsystem")(0)
		map=king.siteurl&king.inst&map&".xml"
		king.flo "<a href="""&map&""" target=""_blank"">"&map&"</a>",0
	end select

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_adminset()
	king.nocache
	king.head "admin",0
	dim list,rs,data,i
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	select case form("submits")
	case"delete"
		if len(list)>0 then
			if cstr(trim(list))=cstr(king.id) then
				king.flo king.lang("admin/flo/deletefail"),0
			else
				conn.execute "delete from kingadmin where adminid in ("&list&") and adminname<>'"&king.name&"';"
				king.flo king.lang("admin/flo/deleteok"),1
			end if
		else
			king.flo king.lang("admin/flo/select"),0
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_admin()
	king.head "admin",king.lang("admin/title")
	dim i,dp,adminlevel

	Il "<h2>"&king.lang("admin/title")
	Il "<span class=""listmenu"">"
	Il "<a href=""manage.asp?action=admin"">["&king.lang("common/list")&"]</a>"
	Il "<a href=""manage.asp?action=adminedt"">["&king.lang("admin/add")&"]</a>"
	Il "</span>"
	Il "</h2>"

	set dp=new record
		dp.create "select adminid,adminname,adminlevel,admindate,admincount from kingadmin;"
		dp.action="manage.asp?action=adminset"
		dp.purl="manage.asp?action=admin&pid=$&rn="&dp.rn

		dp.but=dp.sect("")&dp.prn & dp.plist

		dp.js="cklist(K[0])+'<a href=""manage.asp?action=adminedt&adminid='+K[0]+'"">'+K[0]+') '+K[1]+'</a>'"
		dp.js="K[2]"
		dp.js="K[4]"
		dp.js="K[3]"'+updown('index.asp?oneid='+l1)

		Il dp.open

		Il "<tr><th>"&king.lang("admin/list/name")&"</th><th>"&king.lang("admin/list/level")&"</th><th>"&king.lang("admin/list/count")&"</th><th class=""w4"">"&king.lang("admin/list/date")&"</th></tr>"

		Il "<script>"
		for i=0 to dp.length
			if dp.data(2,i)="admin" then
				adminlevel=king.lang("admin/level/super")
			else
				adminlevel=king.lang("admin/level/editor")
			end if
			Il "ll("&dp.data(0,i)&",'"&dp.data(1,i)&"','"&adminlevel&"','"&dp.data(3,i)&"','"&dp.data(4,i)&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_adminedt()
	king.head "admin",king.lang("admin/title")
	dim sql,adminid,i,data,dataform
	dim rs,plugin,checked,levels
	dim adminpass

	adminid=quest("adminid",2):if len(adminid)=0 then adminid=form("adminid")
	if len(adminid)>0 then'若有值的情况下
		if validate(adminid,2)=false then king.error king.lang("error/invalid")
	end if
	sql="adminname,adminlevel,adminlanguage,admineditor,diymenu"

	if king.ismethod or len(adminid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from kingadmin where adminid="&adminid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				'外部表单提交也就是只有超级管理员能操作，仅限制一下打开过程即可
				if data(0,0)=king.name then response.redirect "manage.asp?action=myaccount"
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	Il "<h2>"&king.lang("admin/title")
	Il "<span class=""listmenu"">"
	Il "<a href=""manage.asp?action=admin"">["&king.lang("common/list")&"]</a>"
	Il "<a href=""manage.asp?action=adminedt"">["&king.lang("admin/add")&"]</a>"
	Il "</span>"
	Il "</h2>"

	Il "<form name=""form1"" class=""k_form"" method=""post"" action=""manage.asp?action=adminedt"">"
	if len(adminid)=0 then'新添加管理员的时候才显示
		Il "<p><label>"&king.lang("admin/label/name")&"</label><input type=""text"" id=""adminname"" name=""adminname"" value="""&data(0,0)&""" class=""in3"" maxlength=""12"" />"
		Il king.check("adminname|6|"&encode(king.lang("admin/check/name"))&"|2-12;adminname|9|"&encode(king.lang("admin/check/name1"))&"|select count(adminid) from kingadmin where adminname='$pro$'")
		Il "</p>"
	end if

	Il "<p><label>"&king.lang("admin/label/pass") &"</label><input type=""password"" name=""adminpass"" value="""" class=""in3"" maxlength=""30"" />"
	if len(form("adminpass"))>0 or len(form("adminpass1"))>0 or len(adminid)=0 then'密码为空的时候不用验证，也不更新密码
		Il king.check("adminpass|7|"&encode(king.lang("admin/check/contrast"))&"|adminpass1;adminpass|6|"&encode(king.lang("account/check/pwdsize"))&"|6-30")&"</p>"
	end if

	Il "<p><label>"&king.lang("admin/label/pass1")&"</label><input type=""password"" name=""adminpass1"" value="""" class=""in3"" maxlength=""30"" /></p>"

	Il "<p><label>"&king.lang("admin/label/language")&"</label>"
	Il "<select name=""adminlanguage"">"
	Il king.getfolder (king_system&"system/language","xml","<option value=""$name$"" $selected$>$langname$</option>",data(2,0))
	Il "</select></p>"

	Il "<p><label>"&king.lang("admin/label/editor")&"</label>"
	Il "<select name=""admineditor"">"
	Il king.getfolder ("editor","dir","<option value=""$name$"" $selected$>$name$</option>",data(3,0))
	Il "</select></p>"


	'读取plugin
	set rs=conn.execute("select plugin from kingsystem where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			if len(rs(0))>0 then
				plugin=split(rs(0),",")
			else
				redim plugin(0)
			end if
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing
	Il "<div class=""k_checkbox""><label>"&king.lang("admin/label/level")&"</label>"'管理员设置
		if cstr(data(1,0))="admin" then checked=" checked=""checked""" else checked=""
		Il "<span><input type=""checkbox"" id=""adminlevel"" name=""adminlevel"" value=""1"" onclick=""javascript:selevel()"""&checked&" />"'超级管理员
		Il "<label for=""adminlevel"">"&king.lang("admin/level/super")&"</label></span>"

		Il "<span id=""levels"">"'普通管理员设置
		levels=array("plugin","diymenu","config","log","rss","bot","brow")
		for i=0 to ubound(levels)
			if king.instre(data(1,0),levels(i)) then checked=" checked=""checked""" else checked=""
			Il "<input type=""checkbox"" name=""level"" id=""p_"&levels(i)&""" value="""&levels(i)&""""&checked&" /><label for=""p_"&levels(i)&""">"&king.lang(levels(i)&"/title")&"</label> "
		next
		Il "<br/><script>selevel();</script>"
		for i=0 to ubound(plugin)
			if len(plugin(i))>0 then
				if king.instre(data(1,0),plugin(i)) then checked=" checked=""checked""" else checked=""
				Il "<input type=""checkbox"" name=""level"" id=""p_"&plugin(i)&""" value="""&plugin(i)&""""&checked&" /><label for=""p_"&plugin(i)&""">"&king.xmlang(plugin(i),"title")&"</label> "
			end if
		next
		Il "</span>"
	Il "</div>"

	Il "<p><label>"&king.lang("account/diymenu")&"</label>"
	Il "<textarea name=""diymenu"" class=""in5"" rows=""15"" cols=""70"">"&formencode(data(4,0))&"</textarea>"
	Il "</p>"
	
	king.form_hidden "adminid",adminid
	king.form_but"save"
	Il "</form>"

	if king.ischeck and king.ismethod then
		if data(1,0)="1" then
			data(1,0)="admin"
		else
			if len(form("level"))>0 then
				data(1,0)="0,"&form("level")'这里存在安全隐患？因前面有管理员验证过程，所以不用担心外部表单形式来提交，就算提交也只有超级管理员才有权限到这里执行
			else
				data(1,0)="0"
			end if
		end if
		if len(form("adminpass"))>0 then
			adminpass=md5(form("adminpass"),1)
		end if
		if len(adminid)>0 then'update
			conn.execute "update kingadmin set adminlevel='"&safe(data(1,0))&"',adminlanguage='"&safe(data(2,0))&"',admineditor='"&safe(data(3,0))&"',diymenu='"&safe(data(4,0))&"' where adminid="&adminid
			if len(form("adminpass"))>0 then
				conn.execute "update kingadmin set adminpass='"&adminpass&"' where adminid="&adminid
			end if
		else'insert
			conn.execute "insert into kingadmin ("&sql&",adminpass,admindate) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&adminpass&"','"&tnow&"')"
		end if
		response.redirect "manage.asp?action=admin"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_config()
	dim rs,sql,data,dataform,i
	sql="sitename,siteurl,sitekeywords,lockip,sitemap,rssnumber,rsspath,robot,sitemail,rssupdate,dirty,searchtemplate,sitemapnumber"'12
	king.head "config",king.lang("config/title")

	if king.ismethod then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from kingsystem where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.deletefolder king_system
			end if
			rs.close
		set rs=nothing
	end if

	Il "<form name=""form1"" class=""k_form"" method=""post"" action=""manage.asp?action=config"">"
	Il "<h2>"&king.lang("config/title")&"</h2>"
	Il "<p><label>"&king.lang("manage/sitename")&"</label><input class=""in4"" type=""text"" name=""sitename"" value="""&formencode(data(0,0))&""" maxlength=""50"" /></p>"
	Il "<p><label>"&king.lang("manage/siteurl")&"</label><input class=""in4"" type=""text"" name=""siteurl"" value="""&formencode(data(1,0))&""" maxlength=""50"" /></p>"
	Il "<p><label>"&king.lang("manage/sitemail")&"</label><input class=""in4"" type=""text"" name=""sitemail"" value="""&formencode(data(8,0))&""" maxlength=""100"" /></p>"

	Il "<p><label>"&king.lang("manage/keywords")&"</label><textarea name=""sitekeywords"" rows=""15"" cols=""70"">"&formencode(data(2,0))&"</textarea></p>"

	Il "<h2>"&king.lang("config/setxml")&"</h2>"
	Il "<p><label>"&king.lang("manage/sitemap")&"</label><input class=""in3"" type=""text"" name=""sitemap"" value="""&formencode(data(4,0))&""" maxlength=""30"" />.xml "
	if len(king.mapname)>0 then
		Il "<a onclick=""javascript:posthtm('manage.asp?action=set','flo','submits=createmap');"" href=""javascript:;"">["&king.lang("common/create")&"]</a>"
	end if
	Il "</p>"
	Il "<p><label>"&king.lang("manage/mapnumber")&"</label><input class=""in1"" type=""text"" name=""sitemapnumber"" value="""&formencode(data(12,0))&""" maxlength=""5"" />"
	Il king.check("sitemapnumber|16|"&encode(king.lang("config/check/sitemapnumber"))&"|1-50000")
	Il "</p>"

	Il "<p><label>"&king.lang("manage/rsspath")&"</label><input class=""in3"" type=""text"" name=""rsspath"" value="""&formencode(data(6,0))&""" maxlength=""30"" />.xml <a href=""manage.asp?action=rss"">["&king.lang("common/manage")&"]</a></p>"
	Il "<p><label>"&king.lang("manage/rssnumber")&"</label><input class=""in1"" type=""text"" name=""rssnumber"" value="""&formencode(data(5,0))&""" maxlength=""3"" />"
	Il king.check("rssnumber|2|"&encode(king.lang("config/check/rssnumber")))
	Il "</p>"
	Il "<p><label>"&king.lang("manage/rssupdate")&"</label><input class=""in1"" type=""text"" name=""rssupdate"" value="""&formencode(data(9,0))&""" maxlength=""5"" />"
	Il king.check("rssupdate|2|"&encode(king.lang("config/check/rssupdate")))
	Il "</p>"

	Il "<h2>"&king.lang("config/rest")&"</h2>"
	Il "<p><label>"&king.lang("manage/robot")&" <a href=""manage.asp?action=bot"">["&king.lang("common/manage")&"]</a></label><textarea name=""robot"" rows=""10"" cols=""70"">"&formencode(data(7,0))&"</textarea></p>"
	Il "<p><label>"&king.lang("manage/lockip")&"</label><textarea name=""lockip"" rows=""10"" cols=""70"">"&formencode(data(3,0))&"</textarea></p>"
	Il "<p><label>"&king.lang("manage/dirty")&"</label><textarea name=""dirty"" rows=""10"" cols=""70"">"&formencode(data(10,0))&"</textarea></p>"
	'搜索页模版
	king.form_tmp "searchtemplate",king.lang("template/searchtemplate"),data(11,0),0

	king.form_but "save"
	Il "</form>"

	if king.ismethod and king.ischeck then
		conn.execute "update kingsystem set sitename='"&safe(form("sitename"))&"',siteurl='"&safe(form("siteurl"))&"',sitekeywords='"&safe(form("sitekeywords"))&"',lockip='"&safe(form("lockip"))&"',sitemap='"&safe(form("sitemap"))&"',rssnumber="&safe(form("rssnumber"))&",rsspath='"&safe(form("rsspath"))&"',robot='"&safe(form("robot"))&"',sitemail='"&safe(form("sitemail"))&"',rssupdate="&form("rssupdate")&",dirty='"&safe(form("dirty"))&"',searchtemplate='"&safe(form("searchtemplate"))&"',sitemapnumber="&safe(data(12,0))&" where systemname='KingCMS';"
		Il "<script>alert('"&htm2js(king.lang("common/upok"))&"');</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_diymenu()
	dim rs,diymenu
	king.head "diymenu",king.lang("diymenu/title")

	Il "<h2>"&king.lang("diymenu/title")&"</h2>"

	if  king.ismethod then
		diymenu=form("diymenu")
		set rs=conn.execute("select diymenuid from kingdiymenu where diymenulang='"&safe(king.language)&"';")
			if not rs.eof and not rs.bof then
				conn.execute "update kingdiymenu set diymenu='"&safe(diymenu)&"' where diymenuid="&rs(0)&";"
			else
				conn.execute "insert into kingdiymenu (diymenulang,diymenu) values ('"&safe(king.language)&"','"&safe(diymenu)&"')"
			end if
			rs.close
		set rs=nothing
		response.redirect "manage.asp?action=diymnu"
	else
		set rs=conn.execute("select diymenu from kingdiymenu where diymenulang='"&safe(king.language)&"';")
			if not rs.eof and not rs.bof then
				diymenu=rs(0)
			else
				diymenu=king.lang("diymenu/title")&"|../system/manage.asp?action=diymenu"&vbcrlf
				diymenu=diymenu&king.lang("parameters/love")&"|javascript:;"&vbcrlf
				diymenu=diymenu&"  KingCMS.com|http://www.kingcms.com/"&vbcrlf
				diymenu=diymenu&"  KingCMS Forums|http://bbs.kingcms.com/"&vbcrlf
			end if
			rs.close
		set rs=nothing
	end if
	if action="diymnu" then
		Il "<p class=""red"">"&king.lang("common/upok")&"</p>"
	end if


	Il "<form name=""form1"" class=""k_form"" method=""post"" action=""manage.asp?action=diymenu"">"
	Il "<p><label>"&king.lang("diymenu/title")&"</label><textarea name=""diymenu"" class=""in5"" rows=""25"" cols=""70"">"&formencode(diymenu)&"</textarea>"
	Il "<pre>"&king.lang("diymenu/memo")&"</pre>"
	Il "</p>"
	king.form_but "save"
	Il "</form>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_myaccount()
	dim rs,adminpass,adminlanguage,admineditor,diymenu
	king.head 0,king.lang("account/my")
	Il "<h2>"&king.lang("account/my")&"</h2>"
	if action="myacccount" then
		Il "<p class=""red"">"&king.lang("common/upok")&"</p>"
	end if
	set rs=conn.execute("select adminpass,adminlanguage,admineditor,diymenu from kingadmin where adminname='"&king.name&"';")
		if not rs.eof and not rs.bof then
			adminpass=rs(0)
			adminlanguage=rs(1)
			admineditor=rs(2)
			diymenu=rs(3)
			if king.ismethod then
				adminlanguage=form("adminlanguage")
				admineditor=form("admineditor")
				diymenu=form("diymenu")
			end if
		else
			response.redirect "login.asp"
		end if
		rs.close
	set rs=nothing

	Il "<form name=""form1"" class=""k_form"" method=""post"" action=""manage.asp?action=myaccount"">"

	Il "<p><label>"&king.lang("account/oldpass")&" (6-30)</label><input class=""in3"" type=""password"" name=""oldpass"" maxlength=""30"" />"
	Il king.check("oldpass|6|"&king.lang("account/check/pwdsize")&"|6-30;oldpass|10|"&king.lang("account/check/pwderror")&"|"&adminpass)&"</p>"

	Il "<p><label>"&king.lang("account/newpass")&" (6-30)</label><input class=""in3"" type=""password"" name=""newpass"" maxlength=""30"" />"
	if len(form("newass"))>0 or len(form("confirmedpass"))>0 then
		Il king.check("newpass|7|"&king.lang("account/check/contrast")&"|confirmedpass;newpass|6|"&king.lang("account/check/pwdsize")&"|6-30")&"</p>"
	end if

	Il "<p><label>"&king.lang("account/confirmedpass")&"</label><input class=""in3"" type=""password"" name=""confirmedpass"" maxlength=""30"" /></p>"

	Il "<p><label>"&king.lang("language")&"</label>"
	Il "<select name=""adminlanguage"">"
	Il king.getfolder (king_system&"system/language","xml","<option value=""$name$"" $selected$>$langname$</option>",adminlanguage)
	Il "</select></p>"

	Il "<p><label>"&king.lang("editor")&"</label>"
	Il "<select name=""admineditor"">"
	Il king.getfolder ("editor","dir","<option value=""$name$"" $selected$>$name$</option>",admineditor)
	Il "</select></p>"

	Il "<p><label>"&king.lang("account/diymenu")&"</label>"
	Il "<textarea name=""diymenu"" class=""in5"" rows=""15"" cols=""70"">"&formencode(diymenu)&"</textarea>"
	Il "</p>"

	king.form_but "up"
	Il "</form>"
	
	if king.ischeck and king.ismethod then
		if len(form("newpass"))>0 then
			adminpass=md5(form("newpass"),1)
			conn.execute "update kingadmin set adminpass='"&safe(adminpass)&"',adminlanguage='"&safe(adminlanguage)&"',admineditor='"&safe(admineditor)&"',diymenu='"&safe(diymenu)&"' where adminname='"&king.name&"';"
			response.cookies(md5(king_salt_admin,1))("name")=king.name
			response.cookies(md5(king_salt_admin,1))("pass")=adminpass
		else
			conn.execute "update kingadmin set adminlanguage='"&safe(adminlanguage)&"',admineditor='"&safe(admineditor)&"',diymenu='"&safe(diymenu)&"' where adminname='"&king.name&"';"
		end if
		response.redirect "manage.asp?action=myacccount"
	end if

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_plugin()
	king.nocache
	dim rs,dp,plugin,plugins,i,errortext,errorsystem,errorrepeat,plugintext
	dim incfun,inctag,inctagtext,scriptname,arrayscriptname',systempath
	errortext=true:errorsystem=true:errorrepeat=true

	king.head "plugin",king.lang("plugin/title")
	Il "<h2>"&king.lang("plugin/title")&"</h2>"

	set dp=new record
		dp.action="manage.asp?action=pluginset"
		dp.but=dp.sect("install:"&encode(king.lang("common/install"))&"|-|dict:"&encode(king.lang("common/dict")))
		dp.js="'<input name=""list"" id=""list_'+K[0]+'"" type=""checkbox"" value=""'+K[1]+'""/>'+isplugin(K[2],K[1],K[7])"
		dp.js="K[1]"
		dp.js="K[3]"
		dp.js="K[4]"
		dp.js="K[5]"
		dp.js="K[6]"
		dp.js="isAbout(K[8],K[9],K[10],K[1])"
		Il dp.open

'		Il "<div class=""k_form"">"
'		
'		Il king_table_s'table
		Il "<tr><th>"&king.lang("plugin/list/name")&"</th><th>"&king.lang("plugin/list/folder")&"</th><th>"&king.lang("plugin/list/version")&"</th><th>"&king.lang("plugin/list/author")&"</th><th>"&king.lang("plugin/list/source")&"</th><th>"&king.lang("plugin/list/mail")&"</th><th>"&king.lang("plugin/list/about")&"</th></tr>"
'
		Il "<script>"
		Il "k_clear='"&htm2js(king.lang("plugin/clear"))&"';"
		Il "function isplugin(l1,l2,l3){if(l3!='True'){return ('<span class=""red"">'+l1+'</span>');}else{return ('<a href=""../'+l2+'"">'+l1+'</a>');}};"&vbcrlf
		Il "function isAbout(k1,l2,l3,l4){var I1='';if(k1=='True'){I1+='<a href=""javascript:;"" onclick=""javascript:posthtm(\'manage.asp?action=pluginset\',\'aja\',\'submits=help&path='+l4+'\')"">["&king.lang("common/help")&"]</a>'};if(l2=='True'){I1+='<a href=""javascript:;"" onclick=""javascript:posthtm(\'manage.asp?action=pluginset\',\'aja\',\'submits=tag&path='+l4+'\')"">["&king.lang("common/tag")&"]</a>'};if(l3=='True'){I1+='<a href=""javascript:;"" onclick=""javascript:posthtm(\'manage.asp?action=pluginset\',\'flo\',\'submits=about&path='+l4+'\')"">["&king.lang("common/about")&"]</a>'};if(I1.length>0){return I1}else{return '&nbsp;'};};"
		king_plugin_list
		Il "</script>"

		Il dp.close

	set dp=nothing

	Il "</table>"

	Il "</div>"
	
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_pluginset()
	king.nocache

	dim rs,pname,i,incfun,inctagtext,inctag
	dim readfile
	dim list,lists
	dim plugins,newp

	list=form("list")


	select case form("submits")
	case"delete","dict"
		if len(list)>0 then

			if len(king.plugin)>0 then
				plugins=split(king.plugin,",")
				for i=0 to ubound(plugins)
					if king.instre(list,plugins(i))=false then'没有在
						if len(newp)>0 then
							newp=newp&","&plugins(i)
						else
							newp=plugins(i)
						end if
					end if
				next

				conn.execute "update kingsystem set plugin='"&safe(newp)&"';"
			end if

			if form("submits")="delete" then'删除目录
				lists=split(list,",")
				for i=0 to ubound(lists)
					king.deletefolder "../"&trim(lists(i))
					king.deletefolder king_system&trim(lists(i))
				next
			end if

			'重新生成plugin.asp文件
			king.createplugin
			king.flo king.lang("plugin/flo/"&form("submits")),1
		else
			king.flo king.lang("plugin/flo/select"),0
		end if
	case"install"
		if len(list)>0 then
			newp=king.plugin
			lists=split(list,",")
			for i=0 to ubound(lists)
				if king.instre(newp,lists(i))=false then
					if len(newp)>0 then
						newp=newp&","&lists(i)
					else
						newp=lists(i)
					end if
				end if
			next
			conn.execute "update kingsystem set plugin='"&safe(newp)&"';"
			king.createplugin
			king.flo king.lang("plugin/flo/install"),1
		else
			king.flo king.lang("plugin/flo/select"),0
		end if
	case"help","tag"
		readfile="<div class=""k_form"">"&king.ubbencode(king.readfile(king_system&form("path")&"/help/"&form("submits")&".htm"))&"</div>"
		king.aja king.lang("common/"&form("submits"))&" - "&king.xmlang(form("path"),"title"),readfile
	case"about"
		readfile=king.ubbencode(king.readfile(king_system&form("path")&"/help/"&form("submits")&".htm"))
		king.flo readfile,2

	case else king.flo king.lang("error/invalid"),0
	end select
	
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_plugin_list()
	king.nocache
	dim fs,l8,l5,l6,l3,rs,j:j=1
	dim I1,ver

	set rs=conn.execute("select plugin from kingsystem where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			I1=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	set fs=Server.CreateObject(king_fso)
	l8=server.mappath(king_system)
	if fs.folderexists(l8)=false then error lang("error/foldernone")&"<br/>"&king_system'判断文件夹是否存在
	set l5=fs.getfolder(l8)
	for each l6 in l5.subfolders

		if king.instre("system,[MODEL]",l6.name)=false then

'			Il "<tr>"
			ver=king.xmlang(l6.name,"version")
			if ver="--" then ver="1.0"
			Il "ll("&j&",'"&htm2js(l6.name)&"','"&king.xmlang(l6.name,"title")&"','"&ver&"','"&htm2js(king.xmlang(l6.name,"author"))&"','"&htm2js(king.xmlang(l6.name,"source"))&"','"&htm2js(king.xmlang(l6.name,"mail"))&"','"&king.instre(I1,l6.name)&"','"&king.isexist(king_system&l6.name&"/help/help.htm")&"','"&king.isexist(king_system&l6.name&"/help/tag.htm")&"','"&king.isexist(king_system&l6.name&"/help/about.htm")&"');"
			j=j+1
		end if
	next
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_logout()
	dim cookiesname:cookiesname=request.cookies(md5(king_salt_admin,1))("name")
	response.cookies(md5(king_salt_admin,1))("name")=""
	response.cookies(md5(king_salt_admin,1))("pass")=""
	response.cookies(md5(king_salt_admin,1)).expires=date-100
	if len(cookiesname)>0 then
		conn.execute "insert into kinglog (adminname,lognum,ip,logdate) values ('"&safe(cookiesname)&"',3,'"&safe(king.ip)&"','"&tnow&"')"
	end if
	response.redirect "../system/login.asp"
end sub

%>