<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'     用户中心首页
'***  ***  ***  ***  ***

dim pp
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set pp=new passport
	select case action
	case"" king_def
	case"view","closeview" king_view
	case"set" king_set
	case"usernavlogin","usernavlogout" king_usernav
	case"config" king_config
	case"uppass" king_uppass
	end select
set pp=nothing
set king=nothing
'def  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()
	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/index.asp"

	dim dp,sql,i

	king.pphead 1

	sql="select msgid,msgtitle,letuser,msgdate,isview from kingpassport_msg where username='"&safe(king.name)&"' order by msgid desc;"
	
	king.ol=pp.navigationuser
	king.ol="<div id=""k_usermain"">"

	set dp=new record
		dp.create sql
		dp.but=dp.sect("view:"&encode(pp.lang("list/view"))&"|noview:"&encode(pp.lang("list/noview"))) & dp.plist
		dp.js="cklist(K[0])+'<span id=""msg_'+K[0]+'""><a '+isview(K[4])+' href=""javascript:;"" onclick=""javascript:gethtm(\'index.asp?action=view&msgid='+K[0]+'\',\'msg_'+K[0]+'\');"">'+K[1]+'</a></span>'"
		dp.js="'<a href=""javascript:;"" onclick=""javascript:posthtm(\'friend.asp?action=set\',\'flo\',\'submits=msg&username='+K[2]+'\')"">'+K[2]+'</a>'"
		dp.js="K[3]"

		king.ol=dp.open

		king.ol="<tr><th>"&pp.lang("list/msgtitle")&"</th><th>"&pp.lang("list/letuser")&"</th><th>"&pp.lang("list/date")&"</th></tr>"
		king.ol="<script type=""text/javascript"">"
		king.ol="function isview(l1){var I1;(l1==0)?I1=' style=""font-weight:bold;""':I1='';return I1;};"
		for i=0 to dp.length
			king.ol="ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(dp.data(2,i))&"','"&htm2js(dp.data(3,i))&"','"&htm2js(dp.data(4,i))&"');"&vbcrlf
		next
		king.ol="</script>"
		king.ol=dp.close
	set dp=nothing

	king.ol="</div>"

	king.value "title",encode(pp.lang("common/center"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue
end sub
'view  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_view()
	king.nocache
	king.pphead 1
	dim msgid,rs,sql
	msgid=quest("msgid",2)
	if action="view" then sql="msgcontent,letuser,msgtitle" else sql="msgtitle"

	set rs=conn.execute("select "&sql&" from kingpassport_msg where msgid="&msgid&" and username='"&safe(king.name)&"';")
		if not rs.eof and not rs.bof then
			if action="view" then
				conn.execute "update kingpassport_msg set isview=1 where msgid="&msgid&";"
				king.txt "<a href=""javascript:;"" onclick=""javascript:gethtm('index.asp?action=closeview&msgid="&msgid&"','msg_"&msgid&"')"">"&htmlencode(rs(2))&"</a><blockquote>"&htmlcode(rs(0))&"<p><a href=""javascript:;"" onclick=""javascript:posthtm('friend.asp?action=set','flo','submits=msg&username="&htm2js(rs(1))&"&msgcontent='+encodeURI('Re:"&htm2js(rs(2))&"'))"">["&htm2js(pp.lang("common/remsg"))&"]</a> <a href=""javascript:;"" onclick=""javascript:gethtm('index.asp?action=closeview&msgid="&msgid&"','msg_"&msgid&"');"">["&htm2js(pp.lang("common/closemsg"))&"]</a></p></blockquote>"
			else
				king.txt "<a href=""javascript:;"" onclick=""javascript:gethtm('index.asp?action=view&msgid="&msgid&"','msg_"&msgid&"')"">"&htmlencode(rs(0))&"</a>"
			end if
		else
			king.txt "<p>"&king.lang("error/invalid")&"</p>"
		end if
		rs.close
	set rs=nothing

end sub
'config  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_config()
	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/index.asp?action=config"

	king.pphead 1
	dim rs,checked,data,dataform,sql,i
	sql="ppquestion,ppanswer,ppmailis,ppmail"


	king.ol=pp.navigationuser
	king.ol="<div id=""k_usermain"">"
	king.ol="<form name=""form1"" method=""post"" action=""index.asp?action=config"" class=""k_form"">"
	if king.ismethod then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from kingpassport where ppname='"&king.name&"';")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if
	'邮箱参数
	king.ol="<p><label>"&pp.lang("label/mail1")&"</label><input class=""k_in3"" type=""text"" disabled=""true"" value="""&formencode(data(3,0))&""" />"
	if cstr(data(2,0))="0" then checked=" checked=""checked""" else checked=""
	king.ol="<input type=""checkbox"" id=""ppmailis"" name=""ppmailis"" value=""0"""&checked&" />"
	king.ol="<span><label for=""ppmailis"">"&pp.lang("label/mailis")&"</label></span>"
	king.ol="<input type=""hidden"" name=""ppmail"" value="""&formencode(data(3,0))&""" />"
	king.ol="</p>"
	'问题
	king.ol="<p><label>"&pp.lang("label/question")&"</label><input class=""k_in4"" type=""text"" name=""ppquestion"" maxlength=""50"" value="""&formencode(data(0,0))&""" />"
	king.ol=king.check("ppquestion|6|"&encode(pp.lang("check/question"))&"|1-50")
	king.ol="</p>"
	'答案
	king.ol="<p><label>"&pp.lang("label/answer")&"</label><input class=""k_in4"" type=""text"" name=""ppanswer"" maxlength=""50"" value="""&formencode(data(1,0))&""" />"
	king.ol=king.check("ppanswer|6|"&encode(pp.lang("check/answer"))&"|1-50")
	king.ol="</p>"
	
	king.ol="<div>"
	king.ol="<input type=""submit"" value="""&king.lang("common/up")&""" /> "
	king.ol="</div>"
	king.ol="</form>"
	king.ol="</div>"

	if king.ismethod and king.ischeck then
		if cstr(data(2,0))="0" then data(2,0)=0 else data(2,0)=1
		conn.execute "update kingpassport set ppquestion='"&safe(data(0,0))&"',ppanswer='"&safe(data(1,0))&"',ppmailis="&data(2,0)&" where ppname='"&safe(king.name)&"';"
		'输出提示
		king.clearol
		king.ol=pp.navigationuser
		king.ol="<div id=""k_usermain"">"
		king.ol="<div class=""k_form"">"
		king.ol="<ol>"
		king.ol="<li>"&pp.lang("tip/upconfig")&"</li>"
		king.ol="<li><a href=""index.asp?action=config"">"&pp.lang("tip/reconfig")&"</a></li>"
		king.ol="<li><a href=""/"">"&pp.lang("list/home")&"</a></li>"
		king.ol="<li><a href=""logout.asp"" onClick=""javascript:return confirm('"&htm2js(king.lang("confirm/logout"))&"')"">"&pp.lang("common/logout")&"</a></li>"
		king.ol="</ol>"
		king.ol="</div>"
		king.ol="</div>"

	end if

	king.value "title",encode(pp.lang("common/config"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue
end sub
'uppass  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_uppass()
	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/index.asp?action=uppass"

	king.pphead 1

	dim rs,oldpass,ppkey,ispass,pppass,pplanguage

	pppass=form("oldpass")
	king.ol=pp.navigationuser
	king.ol="<div id=""k_usermain"">"

	'提交用户名
	king.ol="<form name=""form1"" method=""post"" action=""index.asp?action=uppass"" class=""k_form"">"
	if king.ismethod then
		set rs=conn.execute("select ppkey,pppass,pplanguage from kingpassport where ppname='"&safe(king.name)&"' and isdel=0;")
			if not rs.eof and not rs.bof then
				ppkey=rs(0)
				oldpass=rs(1)
				pppass=md5(pppass&ppkey,1)
				if pppass=oldpass then ispass=true else ispass=false
				pplanguage=rs(2)
			else
				out king.name
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	else
		ispass=false
	end if
	'oldpass
	king.ol="<p><label>"&pp.lang("common/oldpass")&"</label><input class=""k_in2"" type=""password"" name=""oldpass"" maxlength=""30"" />"
	king.ol=king.check("oldpass|6|"&encode(pp.lang("check/pwdsize"))&"|6-30;"&ispass&"|13|"&encode(pp.lang("check/oldpass")))
	king.ol="</p>"
	'newpass1
	king.ol="<p><label>"&pp.lang("common/newpass1")&"</label><input class=""k_in2"" type=""password"" name=""pass1"" maxlength=""30"" />"
	king.ol=king.check("pass1|7|"&encode(pp.lang("check/pass1"))&"|pass2;pass1|6|"&encode(pp.lang("check/pwdsize"))&"|6-30")
	king.ol="</p>"
	king.ol="<p><label>"&pp.lang("common/newpass2")&"</label><input class=""k_in2"" type=""password"" name=""pass2"" maxlength=""30"" /></p>"
	'newpass2
	king.ol="<div>"
	king.ol="<input type=""submit"" value="""&king.lang("common/up")&""" /> "
	king.ol="</div>"
	king.ol="</form>"
	king.ol="</div>"

	if king.ismethod and king.ischeck then
		ppkey=salt(6):pppass=form("pass1")
		pppass=md5(pppass&ppkey,1)
		'重写密码及cookies
		conn.execute "update kingpassport set ppkey='"&safe(ppkey)&"',pppass='"&safe(pppass)&"' where ppname='"&safe(king.name)&"';"'重新写新的密码
		response.cookies(md5(king_salt_user,0))("name")=king.name
		response.cookies(md5(king_salt_user,0))("pass")=md5(left(ppkey,3)&pppass,1)
		if king_remoteurl="../" then
			response.cookies(md5(king_salt_user,0)).domain=king.url
		else
			response.cookies(md5(king_salt_user,0)).domain=king_domain
		end if
		session(md5(king_salt_user,0))=king.name&"|"&pplanguage&"|0"
		'输出提示
		king.clearol
		king.ol=pp.navigationuser
		king.ol="<div id=""k_usermain"">"
		king.ol="<div class=""k_form"">"
		king.ol="<ol>"
		king.ol="<li>"&pp.lang("tip/uppass")&"</li>"
		king.ol="<li><a href=""index.asp?action=uppass"">"&pp.lang("tip/reuppass")&"</a></li>"
		king.ol="<li><a href=""/"">"&pp.lang("list/home")&"</a></li>"
		king.ol="<li><a href=""logout.asp"" onClick=""javascript:return confirm('"&htm2js(king.lang("confirm/logout"))&"')"">"&pp.lang("common/logout")&"</a></li>"
		king.ol="</ol>"
		king.ol="</div>"
		king.ol="</div>"

	end if

	king.value "title",encode(pp.lang("common/uppass"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.pphead 1

	dim list

	list=form("list")
	'需要选择才可以继续
'	if len(list)>0 then
		if validate(list,6)=false then king.flo pp.lang("flo/selectmsg"),0
'	end if

	select case form("submits")
	case"delete"
		conn.execute "delete from kingpassport_msg where msgid in ("&list&") and username='"&safe(king.name)&"';"
		king.flo pp.lang("flo/delokmsg"),1
	case"view"
		conn.execute "update kingpassport_msg set isview=1 where msgid in ("&list&") and username='"&safe(king.name)&"';"
		king.flo pp.lang("flo/viewok"),1
	case"noview"
		conn.execute "update kingpassport_msg set isview=0 where msgid in ("&list&") and username='"&safe(king.name)&"';"
		king.flo pp.lang("flo/noviewok"),1
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_usernav()
	on error resume next
	dim rs,i,insql,I1,I2,I3,I4,I5
	king.pphead 0
	if action="usernavlogin" then
		insql="navigationlogin"
	else
		insql="navigationlogout"
	end if

	set rs=conn.execute("select "&insql&" from kingpassport_config where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			I2=rs(0)
		end if
		rs.close
	set rs=nothing

	if len(I2)>0 then
		I3=king.sect(I2,"(\{language\="&king.language&")","(\})","")
		if king_remoteurl = "../" then 
			I3=king.replacee(I3,"\(king\:page\/\)",king.page)
		else
			I3=king.replacee(I3,"\(king\:page\/\)",king_remoteurl)
		end if
		I4=split(I3,chr(13)&chr(10))
		for i=0 to ubound(I4)
			if len(trim(I4(i)))>0 then
				if instr(I4(i),"|") then
					I5=split(I4(i),"|")
					if right(lcase(I5(1)),10)="logout.asp" then
						I1=I1&"<a href="""&htmlencode(I5(1))&""" onClick=""javascript:return confirm('"&htm2js(king.lang("confirm/logout"))&"')"">"&htmlencode(I5(0))&"</a>"
					else
						I1=I1&"<a href="""&htmlencode(I5(1))&""">"&htmlencode(I5(0))&"</a>"
					end if
				end if
			end if
		next
	end if

	king.txt I1
	
end sub
%>