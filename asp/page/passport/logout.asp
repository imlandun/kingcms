<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'       会员退出
'***  ***  ***  ***  ***

dim pp
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set pp=new passport
	select case action
	case"" king_def
	end select
set pp=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/logout.asp"
	dim cookiesname:cookiesname=request.cookies(md5(king_salt_user,1))("name")
	response.cookies(md5(king_salt_user,0)).expires=now()-365
	Session.abandon()
	conn.execute "insert into kingpassport_log (ppname,lognum,ip,logdate) values ('"&safe(cookiesname)&"',3,'"&safe(king.ip)&"','"&tnow&"')"
	response.redirect "login.asp"
end sub

%>