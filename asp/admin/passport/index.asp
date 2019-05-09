<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'       管理页面
'***  ***  ***  ***  ***
dim pp
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set pp=new passport
	select case action
	case"","lock" king_def
	case"edt" king_edt
	case"config" king_config
	case"protocal" king_protocal
	case"set" king_set
	case"search" king_search
	case"insearch" king_insearch
	case"log" king_log
	case"logset" king_logset
	case"msg","mesg" king_msg
	case"ppmsg" king_ppmsg
	case"viewmsg","closeviewmsg" king_viewmsg
	case"msgset" king_msgset
	end select
set pp=nothing
set king=nothing
'msgset  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_msgset()
	king.nocache
	king.head king.path,0

	dim list

	list=form("list")
	'需要选择才可以继续
'	if len(list)>0 then
		if validate(list,6)=false then king.flo pp.lang("flo/selectmsg"),0
'	end if

	select case form("submits")
	case"delete"
		conn.execute "delete from kingpassport_msg where msgid in ("&list&") and username='[SYSTEM]';"
		king.flo pp.lang("flo/delokmsg"),1
	case"view"
		conn.execute "update kingpassport_msg set isview=1 where msgid in ("&list&") and username='[SYSTEM]';"
		king.flo pp.lang("flo/viewok"),1
	case"noview"
		conn.execute "update kingpassport_msg set isview=0 where msgid in ("&list&") and username='[SYSTEM]';"
		king.flo pp.lang("flo/noviewok"),1
	end select
end sub
'viewmsg  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_viewmsg()
	king.nocache

	king.head king.path,0

	dim msgid,rs,sql
	msgid=quest("msgid",2)

	if action="viewmsg" then sql="msgcontent,letuser,msgtitle" else sql="msgtitle"

	set rs=conn.execute("select "&sql&" from kingpassport_msg where msgid="&msgid&" and username='[SYSTEM]';")
		if not rs.eof and not rs.bof then
			if action="viewmsg" then
				conn.execute "update kingpassport_msg set isview=1 where msgid="&msgid&";"
				king.txt "<a href=""javascript:;"" onclick=""javascript:gethtm('index.asp?action=closeviewmsg&msgid="&msgid&"','msg_"&msgid&"')"">"&htmlencode(rs(2))&"</a><blockquote>"&htmlcode(rs(0))&"<p><a href=""index.asp?action=msg&msgid="&msgid&""">["&htm2js(pp.lang("common/remsg"))&"]</a> <a href=""javascript:;"" onclick=""javascript:gethtm('index.asp?action=closeviewmsg&msgid="&msgid&"','msg_"&msgid&"')"">["&htm2js(pp.lang("common/closemsg"))&"]</a></p></blockquote>"
			else
				king.txt "<a href=""javascript:;"" onclick=""javascript:gethtm('index.asp?action=viewmsg&msgid="&msgid&"','msg_"&msgid&"')"">"&htmlencode(rs(0))&"</a>"
			end if
		else
			king.txt "<p>"&king.lang("error/invalid")&"</p>"
		end if
		rs.close
	set rs=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_ppmsg()
	if king_remoteurl<>"../" then response.redirect "index.asp?action=config"

	king.head king.path,pp.lang("common/ppmsg")
	dim dp,sql,i


	sql="select msgid,msgtitle,letuser,msgdate,isview from kingpassport_msg where username='[SYSTEM]' order by msgid desc;"

	pp.list

	set dp=new record
		dp.create sql
		dp.action="index.asp?action=msgset"
		dp.but=dp.sect("view:"&encode(pp.lang("list/view"))&"|noview:"&encode(pp.lang("list/noview"))) & dp.plist
'		dp.js="cklist(K[0])+'<a '+isview(K[4])+' id=""msgtitle_'+K[0]+'"" href=""javascript:;"" onclick=""javascript:gethtm(\'index.asp?action=viewmsg&msgid='+K[0]+'\',\'msg_'+K[0]+'\');document.getElementById(\'msgtitle_'+K[0]+'\').style.fontWeight=\'normal\' ;"">'+K[1]+'</a><span id=""msg_'+K[0]+'""></span>'"
'		dp.js="K[2]"
		dp.js="cklist(K[0])+'<span id=""msg_'+K[0]+'""><a '+isview(K[4])+' href=""javascript:;"" onclick=""javascript:gethtm(\'index.asp?action=viewmsg&msgid='+K[0]+'\',\'msg_'+K[0]+'\');"">'+K[1]+'</a></span>'"
		dp.js="'<a href=""index.asp?action=msg&msgid='+K[0]+'"">'+K[2]+'</a>'"

		dp.js="K[3]"


		Il dp.open

		Il "<tr><th>"&pp.lang("list/msgtitle")&"</th><th>"&pp.lang("list/letuser")&"</th><th>"&pp.lang("list/date")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length		
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(dp.data(2,i))&"','"&htm2js(dp.data(3,i))&"','"&htm2js(dp.data(4,i))&"');"&vbcrlf
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_msg()
	if king_remoteurl<>"../" then response.redirect "index.asp?action=config"

	server.scripttimeout=86400
	king.head king.path,pp.lang("common/pubmsg")
	dim dp,data,dataform,sql,i,rs,username,users,msgid

	sql="username,msgtitle,msgcontent"

	dataform=split(sql,",")
	redim data(ubound(dataform),0)
	if king.ismethod then
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		msgid=quest("msgid",2)
		if len(msgid)>0 then
			set rs=conn.execute("select msgtitle,letuser from kingpassport_msg where msgid="&msgid&";")
				if not rs.eof and not rs.bof then
					data(0,0)=rs(1)
					data(1,0)="Re:"&rs(0)
				else
					king.error king.lang("error/invalid")
				end if
				rs.close
			set rs=nothing
		else
			data(0,0)="*"
		end if
	end if

	pp.list

	if action="mesg" then
		Il "<p class=""red"">"&pp.lang("common/msgok")&"</p>"
	end if

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=msg"">"

	king.form_input "username",pp.lang("list/username"),data(0,0),"username|0|"&encode(pp.lang("check/username"))'username
	king.form_input "msgtitle",pp.lang("list/msgtitle"),data(1,0),"msgtitle|6|"&encode(pp.lang("check/msgtitle"))&"|1-50"'msgtitle

	Il "<p><label>"&pp.lang("list/msgcontent1")&"</label><textarea name=""msgcontent"" rows=""15"" cols=""70"" class=""in5"">"&formencode(data(2,0))&"</textarea>"
	Il king.check("msgcontent|0|"&encode(pp.lang("check/msgcontent1")))&"</p>"

	king.form_but "post"

	Il "</form>"

	if king.ismethod and king.ischeck then
		if data(0,0)="*" then
			set rs=conn.execute("select ppname from kingpassport where isdel=0;")
				if not rs.eof and not rs.bof then
					do while not rs.EOF
						if len(username)>0 then
							username=username&","&rs(0)
						else
							username=rs(0)
						end if
						rs.MoveNext
					loop
				end if
				rs.close
			set rs=nothing
		else
			users=split(data(0,0),",")
			for i=0 to ubound(users)
				if conn.execute("select count(*) from kingpassport where ppname='"&safe(users(i))&"' and isdel=0;")(0)=1 then'验证用户是否存在
					if len(username)>0 then
						username=username&","&users(i)
					else
						username=users(i)
					end if
				end if
			next
		end if
		
		users=split(username,",")
		for i=0 to ubound(users)
			conn.execute "insert into kingpassport_msg (letuser,username,msgtitle,msgcontent,msgdate) values ('[SYSTEM]','"&safe(users(i))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&tnow&"')"
		next
		response.redirect "index.asp?action=mesg"
	end if

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	if king_remoteurl<>"../" then response.redirect "index.asp?action=config"

	king.head king.path,pp.lang("title")
	dim dp,i,sql,sect
	
	pp.list
	
	if action="" then
		sql="select ppid,ppname,ppmail from kingpassport where islock=0 and isdel=0 order by ppid desc;"
		sect="lock:"&encode(pp.lang("common/lock"))
	else
		sql="select ppid,ppname,ppmail from kingpassport where islock=1 and isdel=0 order by ppid desc;"
		sect="unlock:"&encode(pp.lang("common/unlock"))
	end if
	
	set dp=new record
		dp.create sql
		dp.but=dp.sect(sect)&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&ppid='+K[0]+'"">'+K[0]+') '+K[1]"
		dp.js="K[2]"

		Il dp.open

		Il "<tr><th>"&pp.lang("list/id")&") "&pp.lang("list/name")&"</th><th>"&pp.lang("list/mail")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length		
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(dp.data(2,i))&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	if king_remoteurl<>"../" then response.redirect "index.asp?action=config"

	king.head king.path,pp.lang("title")
	
	dim ppid,data
	dim rs,ppkey,pppass,errtext

	pp.list
	
	ppid=quest("ppid",2):if len(ppid)=0 then ppid=form("ppid")
	if len(ppid)>0 then'若有值的情况下
		if validate(ppid,2)=false then king.error king.lang("error/invalid")
	end if

	set rs=conn.execute("select ppname,ppmail from kingpassport where ppid="&ppid&";")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	errtext=king.check("pass1|7|"&encode(pp.lang("check/pwdcontrast"))&"|pass2;pass1|6|"&encode(pp.lang("check/pwdsize"))&"|6-30")
	if king.ischeck and king.ismethod then
		ppkey=salt(6):pppass=form("pass1")
		pppass=md5(pppass&ppkey,1)

		conn.execute "update kingpassport set pppass='"&safe(pppass)&"',ppkey='"&safe(ppkey)&"' where ppid="&ppid&";"
		Il "<p class=""red"">"&pp.lang("common/ppok")&"</p>"
	end if


	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"

	Il "<p><label>"&pp.lang("label/aname")&"</label><input class=""in3"" disabled=""true"" type=""text"" value="""&formencode(data(0,0))&"""/></p>"
	Il "<p><label>"&pp.lang("label/amail")&"</label><input class=""in3"" disabled=""true"" type=""text"" value="""&formencode(data(1,0))&"""/></p>"

	Il "<p><label>"&pp.lang("label/apass1")&" (6-30)</label>"
	Il "<input class=""in3"" type=""password"" name=""pass1"" maxlength=""30"" />"
	Il errtext&"</p>"

	Il "<p><label>"&pp.lang("label/apass2")&" (6-30)</label>"
	Il "<input class=""in3"" type=""password"" name=""pass2"" maxlength=""30"" /></p>"

	king.form_hidden "ppid",ppid
	king.form_but"save"

	Il "</form>"

	
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_search()
	if king_remoteurl<>"../" then response.redirect "index.asp?action=config"

	king.head king.path,pp.lang("title")
	dim dp,i,sql,query
	
	pp.list

	query=quest("query",0)
	sql="select ppid,ppname,ppmail,islock from kingpassport where (ppname like '%"&safe(query)&"%' or ppmail like '%"&safe(query)&"%') and isdel=0 order by ppid desc;"
	
	set dp=new record
		dp.create sql
		dp.but=dp.sect("lock:"&encode(pp.lang("common/lock")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&ppid='+K[0]+'"">'+K[0]+') '+K[1]"
		dp.js="K[2]"
		dp.js="pplock(K[3])"

		Il dp.open

		Il "<tr><th>"&pp.lang("list/id")&") "&pp.lang("list/name")&"</th><th>"&pp.lang("list/mail")&"</th><th>"&pp.lang("list/islock")&"</th></tr>"
		Il "<script>"
		Il "function pplock(l1){var I1;l1==1?I1='"&htm2js(pp.lang("common/lock"))&"':I1='"&htm2js(pp.lang("common/normal"))&"';return I1;}"
		for i=0 to dp.length		
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(dp.data(2,i))&"',"&dp.data(3,i)&");"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_insearch()
	king.nocache
	king.head king.path,0
	king.txt "<input type=""text"" onkeydown=""if(event.keyCode==13) {window.location='index.asp?action=search&query='+encodeURI(this.value); return false;}"" />"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.head king.path,0
	dim list,rs,data,i
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	select case form("submits")
	case"lock" 
		if len(list)>0 then
			conn.execute "update kingpassport set islock=1 where ppid in ("&list&")"
			king.flo pp.lang("flo/lockok"),1
		else
			king.flo pp.lang("flo/select"),0
		end if
	case"unlock" 
		if len(list)>0 then
			conn.execute "update kingpassport set islock=0 where ppid in ("&list&")"
			king.flo pp.lang("flo/unlockok"),1
		else
			king.flo pp.lang("flo/select"),0
		end if
	case"delete"
		if len(list)>0 then
			conn.execute "update kingpassport set isdel=1 where ppid in ("&list&")"
			king.flo pp.lang("flo/delok"),1
		else
			king.flo pp.lang("flo/select"),0
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_log()
	if king_remoteurl<>"../" then response.redirect "index.asp?action=config"

	king.head king.path,pp.lang("common/log")
	dim dp,i

	pp.list

	set dp=new record
		dp.create"select logid,ppname,lognum,ip,logdate from kingpassport_log order by logid desc;"
		dp.purl="index.asp?action=log&pid=$&rn="&dp.rn
		dp.action="index.asp?action=logset"
		dp.but=dp.sect("logdelete:"&encode(king.lang("log/delete"))&"|clear:"&encode(pp.lang("common/delall")))&dp.prn & dp.plist
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
			conn.execute "delete from kingpassport_log where logid in ("&list&");"
			king.flo king.lang("log/flo/deleteok"),1
		else
			king.flo king.lang("log/flo/select"),0
		end if
	case"logdelete"'删除过期日志 一个月
		if king_dbtype=1 then
			sql="delete from kingpassport_log where getdate()-logdate>30;"
		else
			sql="delete from kingpassport_log where now()-logdate>30;"
		end if
		conn.execute sql
		king.flo king.lang("log/flo/logdeleteok"),1
	case"clear"'删除全部日志
		conn.execute "delete from kingpassport_log;"
		king.flo pp.lang("flo/delall"),1
	end select

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_config()
	king.head king.path,pp.lang("common/config")
	dim rs,data,dataform,sql,i
	sql="pptemplate,reservename,navigationlogout,navigationlogin,navigationuser"

	pp.list

	if king.ismethod then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		conn.execute "update kingpassport_config set pptemplate='"&safe(data(0,0))&"',reservename='"&safe(data(1,0))&"',navigationlogout='"&safe(data(2,0))&"',navigationlogin='"&safe(data(3,0))&"',navigationuser='"&safe(data(4,0))&"' where systemname='KingCMS';"
		Il "<p class=""red"">"&pp.lang("common/configupok")&"</p>"
	else
		set rs=conn.execute("select "&sql&" from kingpassport_config where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=config"">"
	king.form_tmp "pptemplate",pp.lang("label/template"),data(0,0),0
	if king_remoteurl="../" then
		Il "<p><label>"&pp.lang("label/reservename")&"</label><textarea name=""reservename"" rows=""8"" cols=""80"" class=""in5"">"&formencode(data(1,0))&"</textarea></p>"
	else
		king.form_hidden "reservename",data(1,0)
	end if
	Il "<p><label>"&pp.lang("label/navigation/logout")&"</label><textarea name=""navigationlogout"" rows=""10"" cols=""80"" class=""in5"">"&formencode(data(2,0))&"</textarea></p>"
	Il "<p><label>"&pp.lang("label/navigation/login")&"</label><textarea name=""navigationlogin"" rows=""10"" cols=""80"" class=""in5"">"&formencode(data(3,0))&"</textarea></p>"
	Il "<p><label>"&pp.lang("label/navigation/user")&"</label><textarea name=""navigationuser"" rows=""10"" cols=""80"" class=""in5"">"&formencode(data(4,0))&"</textarea>"
	Il "<pre>"&pp.lang("label/navigation/memo")&"</pre>"
	Il "</p>"
	king.form_but "save"
	Il "</form>"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_protocal()
	if king_remoteurl<>"../" then response.redirect "index.asp?action=config"

	king.head king.path,pp.lang("common/protocal")
	dim rs,data,dataform,sql,i
	sql="protocal"

	pp.list

	if king.ismethod then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		conn.execute "update kingpassport_config set protocal='"&safe(data(0,0))&"' where systemname='KingCMS';"
		Il "<p class=""red"">"&pp.lang("common/protocalok")&"</p>"
	else
		set rs=conn.execute("select "&sql&" from kingpassport_config where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=protocal"">"
	king.form_editor "protocal",pp.lang("label/protocal"),data(0,0),0'content
	king.form_but "save"
	Il "</form>"
end sub
%>