<!--#include file="config.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>King Content Management System - Version 5.0</title>
<link rel="stylesheet" type="text/css" href="/template/skin/style/sys_base.css"/>
<style type="text/css">
body { background:#0b3768; }
.sys_login { position:absolute; left:50%; top:50%; margin:-143px 0 0 -243px; width:486px; height:286px; background:url(/template/skin/images/login_bg.png) no-repeat;  }
.sys_login_form { width:291px; height:160px; position:absolute; left:92px; top:50px; padding:30px 0 0 15px; }
.sys_login_form p { height:30px; line-height:30px; color:#104670; padding:0 0 10px 0; }
.sys_login_form label { display:block; width:70px; height:22px; line-height:22px; text-align:right; float:left; overflow:hidden; }
.sys_login_form input { background:#fff; padding:0 3px; width:160px; border:#5c7e9a solid 1px; height:22px; line-height:22px\9; }
.sys_login_form input.login_btn { width:74px; height:29px; border:none; background:url(/template/skin/images/login_btn.png) no-repeat; cursor:pointer; }
.sys_login_form input.reset { background-position:0 0; margin:0 10px 0 82px; }
.sys_login_form input.submit { background-position:-77px 0; }
.sys_error { position:absolute; left:0; top:0; background:#FC6; border:#F90 solid 1px; width:100%; padding:3px 0; text-align:center; }
.sys_copyright { position:absolute; left:0; bottom:10px; width:100%; text-align:center; line-height:30px; color:#fff; }
.sys_copyright a { color:#fff; text-decoration:none; }
.sys_copyright a:hover { text-decoration:none; }
</style>
</head>
<body>
<div class="sys_login">
	<div class="sys_login_form">
    <%
	dim adminname,adminpass,adminsalt,rs,doc,ip,logcount,sql
	adminname=left(form("adminname"),12)
	if len(adminname)>0 and len(form("adminpass"))>0 then
		adminpass=md5(form("adminpass"),1)
	
		on error resume next
	
		set conn=server.createobject("adodb.connection")
		conn.open objconn
	
		if err.number<>0 then
			set doc=Server.CreateObject(king_xmldom)
			doc.async=false
			doc.load(server.mappath(king_system&"system/language/"&king_language&".xml"))
			response.clear
			response.write doc.documentElement.SelectSingleNode("//kingcms/error/db").text
			response.end()
		end if
		err.clear
	
		ip=request.servervariables("http_x_forwarded_for")
		if ip="" then ip=request.servervariables("remote_addr")
	
		if king_dbtype=1 then
			sql="select count(logid) from kinglog where ip='"&safe(ip)&"' and lognum=2 and getdate()-logdate<0.25;"
		else
			sql="select count(logid) from kinglog where ip='"&safe(ip)&"' and lognum=2 and now()-logdate<0.25;"
		end if
		logcount=conn.execute(sql)(0)
		if logcount>=king_loginnum then
			response.write "<div class=""sys_error"">您尝试登录次数过多，已被系统锁定</div>"
		else
			set rs=conn.execute("select adminid from kingadmin where adminname='"&safe(adminname)&"' and adminpass='"&safe(adminpass)&"';")
				if not rs.eof and not rs.bof then
					conn.execute "update kingadmin set admindate='"&tnow&"',admincount=admincount+1 where adminname='"&safe(adminname)&"';"
					conn.execute "insert into kinglog (adminname,lognum,ip,logdate) values ('"&safe(adminname)&"',1,'"&safe(ip)&"','"&tnow&"')"
					response.cookies(md5(king_salt_admin,1))("name")=adminname
					response.cookies(md5(king_salt_admin,1))("pass")=adminpass'newpass
					response.cookies(md5(king_salt_admin,1)).path = "/"
					response.redirect "manage.asp"
				else
					conn.execute "insert into kinglog (adminname,lognum,ip,logdate) values ('"&safe(adminname)&"',2,'"&safe(ip)&"','"&tnow&"')"
					if king_loginnum-logcount=1 then
						response.write "<div class=""sys_error"">您尝试登录次数过多，已被系统锁定</div>"
					else
						response.write "<div class=""sys_error"">您的帐号或密码有误 !还有"&(king_loginnum-logcount-1)&"次登录的机会。</div>"
					end if
				end if
				rs.close
			set rs=nothing
		end if
	end if
	%>
	<form name="form1" method="post" action="login.asp">
        <p><label>用户名：</label><input size="14" type="text" name="adminname" maxlength="12" /></p>
    	<p><label>密&nbsp;&nbsp;&nbsp;&nbsp;码：</label><input size="14" type="password" name="adminpass" maxlength="30" /></p>
        <p><input type="reset" value="" class="login_btn reset" /><input type="submit" value="" class="login_btn submit" />
	</form>
    </div>
</div>
<div class="sys_copyright"><a href="http://www.kingcms.com" target="_blank">Copyright &copy  KingCMS.com All Rights Reserved.</a></div>
<script type="text/javascript">var admin=document.form1.adminname;admin.focus();</script>
<script type="application/javascript" src="/template/skin/js/jquery.min.js"></script>
<script type="application/javascript" src="/template/skin/js/utils.js"></script>
<script type="application/javascript" src="/template/skin/js/common.js"></script>
</body>
</html>