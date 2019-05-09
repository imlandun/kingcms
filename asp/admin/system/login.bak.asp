<!--#include file="config.asp" -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>King Content Management System - Version 5.0</title>
<link href="images/style.css" rel="stylesheet" type="text/css" />
</head>
<body>


<div id="top">
	<a id="logo" href="http://www.kingcms.com" target="_blank"><img src="images/logo.png"/></a>
	<div id="topright">
		<div id="topmenu">
		<a href="http://www.kingcms.com/" target="_blank">[KingCMS官网]</a>
		</div>
	</div>
</div>

<div id="login">
	<form name="form1" method="post" action="login.asp">

		<%'   这部分代码你可以删掉 开始   %>
		<h3><strong>King</strong> <strong>C</strong>ontent <strong>M</strong>anagement <strong>S</strong>ystem! 5</h3>
		<p>新一代 KingCMS 为您提供了：<br/>更好的界面、更多的开发余地、更强大的扩展能力!</p>
		<%'   结束   %>

		<div>
			<table cellspacing="0">
				<tr>
					<td>
						<p style="line-height:30px;"><label>帐号:</label><input class="in2" size="14" type="text" name="adminname" maxlength="12" /></p>
						<p style="line-height:26px;"><label>密码:</label><input class="in2" size="14" type="password" name="adminpass" maxlength="30" /></p>
					</td>
					<th>
						<p class="k_menu"><input type="submit" value="登录" style="padding:14px 6px;margin-left:10px;" /></p>
					</th>
				</tr>	
			</table>
		</div>

		<%'   这部分代码你可以删掉 开始   %>
		<p>使用前，请先阅读 <a href="http://www.kingcms.com/KingCMS 5.0 许可协议.doc" target="_blank">KingCMS 5.0 许可协议</a></p>
		<p>官方网站：KingCMS.com</p>
		<p>电子邮件：KingCMS@Gmail.com</p>
		<p>官方论坛：bbs.KingCMS.com</p>
		<%'   结束   %>
	</form>

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
		response.write "<p class=""red"">您尝试登录次数过多，已被系统锁定</p>"
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
					response.write "<p class=""red"">您尝试登录次数过多，已被系统锁定</p>"
				else
					response.write "<p class=""red"">您的帐号或密码有误 !还有"&(king_loginnum-logcount-1)&"次登录的机会。</p>"
				end if
			end if
			rs.close
		set rs=nothing
	end if
	


end if

%>

</div>
<hr/>
<p><a href="http://www.kingcms.com" target="_blank">Copyright &copy  KingCMS.com All Rights Reserved.</a></p>
<script type="text/javascript">var admin=document.form1.adminname;admin.focus();</script>
</body>
</html>