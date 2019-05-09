<!--#include file="config.asp" -->
<%

dim dbpath,page,scriptname
const king_systemver = 5.0
const king_dbver = 5.0
dbpath=server.MapPath("../db/King#Content#Management#System.asp")


select case request("action")
case"" king_def
case"install" king_install
case"repass" king_repass
case"del" king_del
end select

sub king_def()

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>KingCMS Installation <%=king_systemver%></title>
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

<div id="main">

<h2>安装(Install)</h1>

<ol class="text">

<%
		if isexistfile(king_db)=false or king_dbtype=1 then
Il "<li><a href=""install.asp?action=install"">安装数据库 (创建数据库及表结构,并设置默认管理帐号)</a></li>"
		end if
%>

<li><a href="login.asp" target="_blank">登录管理</a>
	<ul class="text">
		<li>默认登录帐号为 admin ,密码是 admin888 </li>
		<li><a href="install.asp?action=repass">忘了密码? 修复默认帐号(若不存在则创建,帐号:admin 密码:admin888)</a></li>
	</ul>
</li>

<li class="red"><a href="install.asp?action=del">删除此文件(数据库安装成功后,必须要删除,存在安全隐患)</a></li>
</ol>


<ul class="text">
	<li>数据库连接: 点击安装数据库前,请先设置page/system/conn.asp中的数据库类型及参数,默认为ACCESS数据库</li>
	<li>参数设置: page/system/config.asp里可以指定一些参数</li>
	<li>修改前台系统目录: admin/system/config.asp里修改king_system值和include中的路径</li>
	<li class="red">感谢您对KingCMS的关注及支持!</li>
</ul>

<ul class="text">
	<li><a href="../../KingCMS 5.0 许可协议.doc" target="_blank">KingCMS 5.0 许可协议(较宽松使用开发许可协议)</a></li>
	<li><a href="../../KingCMS 5.0 插件开发规则.doc" target="_blank">KingCMS 5.0 插件开发规则</a></li>
	<li><a href="../../KingCMS 5.0 函数解析.xml" target="_blank">KingCMS 5.0 函数解析</a></li>
</ul>

</div>
<hr/>
<p><a href="http://www.kingcms.com" target="_blank">Copyright &copy KingCMS.com  All Rights Reserved.</a></p>
</body>
</html>

<%
end sub


'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_del()
	deletefile "install.asp"
	response.redirect "login.asp"
end sub


'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_repass()
	dim rs
	set conn=server.createobject("adodb.connection")
	conn.open objconn
	set rs=conn.execute("select adminname from kingadmin where adminname='admin';")
		if not rs.eof and not rs.bof then
			conn.execute "update kingadmin set adminpass='"&md5("admin888",1)&"' where adminname='admin';"
		else
			conn.execute "insert into kingadmin (adminname,adminpass,adminlevel,adminlanguage,admineditor,admindate) values ('admin','"&md5("admin888",1)&"','admin','zh-cn','fckeditor','"&now()&"')"
		end if
		rs.close
	set rs=nothing
	response.redirect request.servervariables("http_referer")
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_install()

	dim adox,sNotdown,sql,i

	if king_dbtype=0 then'ACCESS数据库

		createfolder "../../db"
		if isexistfile(king_db) then
			response.write "数据库已经存在,请先删除!"
			response.end
		end if
		Set adox = Server.CreateObject("ADOX.Catalog") 
		call adox.Create("Provider=Microsoft.Jet.OLEDB.4.0;Data Source="&server.mappath(king_db))
		Set adox = nothing 
	end if

'	objconn="Provider=Microsoft.Jet.OLEDB.4.0;Data Source="&dbpath
	set conn=server.createobject("adodb.connection")
	conn.open objconn

	'  *** Copyright &copy KingCMS.com All Rights Reserved ***
	sql="systemname nvarchar(20),"'系统名称
	sql=sql&"systemver nvarchar(10),"'程序版本
	sql=sql&"dbver nvarchar(10),"'数据库版本
	sql=sql&"sitename nvarchar(50),"'网站名称
	sql=sql&"siteurl nvarchar(50),"'网站地址
	sql=sql&"sitemail nvarchar(100),"'mail
	sql=sql&"sitekeywords ntext,"'网站关键字组
	sql=sql&"plugin ntext,"'插件
	sql=sql&"lockip ntext,"'锁定IP
	sql=sql&"sitemap nvarchar(30),"'sitemaps文件名
	sql=sql&"rssnumber int not null default 50,"
	sql=sql&"rsspath nvarchar(30),"
	sql=sql&"rssupdate int not null default 1440,"'rss新闻更新周期
	sql=sql&"robot ntext,"'爬虫
	sql=sql&"instdate datetime"'安装日期
	conn.execute "create table kingsystem ("&sql&")"
	conn.execute "insert into kingsystem (systemname,systemver,dbver,sitename,siteurl,sitekeywords,instdate,sitemap,rsspath,robot) values ('KingCMS','"&formatnumber(king_systemver,1)&"','"&formatnumber(king_dbver,1)&"','KingCMS','http://www.kingcms.com','KingCMS,内容管理系统','"&tnow&"','sitemaps','news','Baidu|Baiduspider+"&vbcrlf&"Google|Googlebot"&vbcrlf&"Alexa|ia_archiver"&vbcrlf&"Alexa|IAArchiver"&vbcrlf&"ASPSeek|ASPSeek"&vbcrlf&"Yahoo|YahooSeeker"&vbcrlf&"Sohu|sohu-search"&vbcrlf&"Yahoo|help.yahoo.com/help/us/ysearch/slurp"&vbcrlf&"SOHU|sohu-search"&vbcrlf&"MSN|MSN"&vbcrlf&"AOL|Sqworm/2.9.81-BETA (beta_release; 20011102-760; i686-pc-linux-gnu)')"

	'  *** Copyright &copy KingCMS.com All Rights Reserved ***
	sql="adminid int not null identity primary key,"
	sql=sql&"adminname nvarchar(12),"'name
	sql=sql&"adminpass nvarchar(32),"'pass
	sql=sql&"adminlevel ntext,"'级别
	sql=sql&"adminlanguage nvarchar(30),"'语言
	sql=sql&"admineditor nvarchar(30),"'编辑器
	sql=sql&"admincount int not null default 0,"'登陆次数
	sql=sql&"admindate datetime"'最后一次登录
	conn.execute"create table kingadmin ("&sql&");"
	conn.execute "insert into kingadmin (adminname,adminpass,adminlevel,adminlanguage,admineditor,admindate) values ('admin','"&md5("admin888",1)&"','admin','zh-cn','fckeditor','"&now()&"')"

	'  *** Copyright &copy KingCMS.com All Rights Reserved ***
	sql="diymenuid int not null identity primary key,"
	sql=sql&"diymenulang nvarchar(10),"
	sql=sql&"diymenu ntext"
	conn.execute"create table kingdiymenu ("&sql&");"

	'  *** Copyright &copy KingCMS.com All Rights Reserved ***
	sql="logid int not null identity primary key,"
	sql=sql&"adminname nvarchar(12),"
	sql=sql&"ip nvarchar(15),"
	sql=sql&"lognum int not null default 0,"
	sql=sql&"logdate datetime"
	conn.execute"create table kinglog ("&sql&");"

	'  *** Copyright &copy KingCMS.com All Rights Reserved ***
	sql="mapid int not null identity primary key,"
	sql=sql&"maploc nvarchar(255),"
	sql=sql&"maplastmod datetime"'文档自动归类，每个类下面有3000条sitemaps链接
	conn.execute"create table kingsitemap ("&sql&");"

	'  *** Copyright &copy KingCMS.com All Rights Reserved ***
	sql="rssid int not null identity primary key,"
	sql=sql&"rsstitle nvarchar(255),"
	sql=sql&"rsslink nvarchar(255),"
	sql=sql&"rssdescription nvarchar(255),"
	sql=sql&"rsstext ntext,"
	sql=sql&"rssimage nvarchar(255),"
	sql=sql&"rsskeywords nvarchar(255),"
	sql=sql&"rsscategory nvarchar(255),"
	sql=sql&"rssauthor nvarchar(255),"
	sql=sql&"rsssource nvarchar(255),"
	sql=sql&"rssorder int not null default 0,"
	sql=sql&"rsspubDate datetime"
	conn.execute"create table kingrss ("&sql&");"
	for i=1 to 100
		conn.execute "insert into kingrss (rssorder) values ("&i&")"
	next

	'  *** Copyright &copy KingCMS.com All Rights Reserved ***
	sql="botid int not null identity primary key,"
	sql=sql&"botname nvarchar(255),"
	sql=sql&"botnumber int not null default 1,"
	sql=sql&"botlastdate datetime,"'最后一次访问
	sql=sql&"botdate datetime"
	conn.execute"create table kingbot ("&sql&");"

	


	if king_dbtype=0 then
		conn.execute "create table notdown (notdown image)"
		sNotdown="<%response.redirect(""http://www.kingcms.com/"")%"&">"
		conn.execute "insert into notdown (notdown) values ('"&I1I(sNotdown)&"')" 
	end if

	conn.close
	set conn=nothing


	response.redirect request.servervariables("http_referer")
end sub




'I1I 
function I1I(l1)
	dim l2,l3,i
	for i=1 to len(l1)
		l3=cstr(hex(asc(mid(l1,i,1))))
		if len(l3)=2 then
			l2=l2&chrb(clng("&"&chr(72)&trim(l3)))
		else
			l2=l2&chrb(clng("&"&chr(72))&mid(trim(l3),1,2))
			l2=l2&chrb(clng("&"&chr(72))&mid(trim(l3),3,2))
		end if
	next
	I1I=l2
end function
'createfolder 
sub createfolder(l1)
	on error resume next
	dim fs,l2,l3,l4,l5,I1,i
	set fs=Server.CreateObject(king_fso)
	I1=split(l1,"/")
	l4=ubound(I1)
	for i=0 to l4
		if I1(i)=".." then
			l3=l3&"../"
		else
			if l3&I1(i)<>"" then
				l5=server.mappath(l3&I1(i))
				if fs.folderexists(l5)=false then fs.createfolder(l5)'如果文件夹不存在就创建
				l3=l3&I1(i)&"/"
			else
				l3="/"
			end if
		end if
	next
	set fs=nothing
	if err.number<>0 then err.clear
end sub
'deletefile 
sub deletefile(l1)
	on error resume next
	dim fs,l2
	set fs=createobject(king_fso)
		l2=server.mappath(l1)
		if fs.fileexists(l2) then
			fs.deletefile(l2)
		end if
	set fs=nothing
	if err.number<>0 then err.clear
end sub
'isexist 
function isexistfile(l1)
  on error resume next
	dim fs,l2
	set fs=createObject(king_fso)
		l2=server.mappath(l1)
		isexistfile=fs.fileexists(l2)
	set fs=nothing
	if err.number<>0 then err.clear
end function

%>