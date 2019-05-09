<%
'***  ***  ***  ***  ***
'   插件类及标签解析
'***  ***  ***  ***  ***
class passport
private r_doc,r_path,r_name_min,r_name_max,r_template,r_loginnum,r_ver,r_msgnum


'默认参数设置  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()

	r_name_min = 2 '用户名最小长度

	r_name_max = 12 '用户名最大长度 不能超过30

	r_loginnum = 6 '尝试登录次数

	r_msgnum = 20 '每日可发布的短信息次数，每次限制发布给5个人

	r_path = "passport" '系统路径

	r_ver = "1.0" '版本


	if king.checkcolumn("kingpassport")=false then install

end sub





'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get name_min
	name_min=r_name_min
end property
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get name_max
	name_max=r_name_max
end property
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get msgnum
	msgnum=r_msgnum
end property
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get loginnum
	loginnum=r_loginnum
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get name
	dim rs,cookiesname,cookiespass
	if len(name)=0 then
		set rs=conn.execute("select * from kingpassport where name=")
			rs.close
		set rs=nothing
	end if
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get template
	dim rs
	if len(template)=0 then
		set rs=conn.execute("select pptemplate from kingpassport_config where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				template=rs(0)
			end if
			rs.close
		set rs=nothing
	end if
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub head(l1)'权限
	dim rs,cookiesname,cookiespass
	'设置管理员的信息
	cookiesname=safe(request.cookies(md5(king_salt_user,0))("name"))
	cookiespass=safe(request.cookies(md5(king_salt_user,0))("pass"))
	if validate(cookiespass,3)=false and validate(cookiesname,3)=false then response.redirect "../system/login.asp"

	set rs=conn.execute("select adminid,adminlevel,adminlanguage,admineditor from kingadmin where adminname='"&cookiesname&"' and adminpass='"&cookiespass&"';")
		if not rs.eof and not rs.bof then
			r_id=rs(0)
			r_level=rs(1)
			r_language=rs(2)
			r_editor=rs(3)
			r_name=cookiesname
		else
			response.redirect "../system/login.asp"
		end if
	set rs=nothing

	if len(l2)>1 then
		tophtml l2
	end if
	'验证
	if r_level="admin" or instre(r_level,l1) then
	else
		error lang("error/jurisdiction")
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function lang(l1)
	on error resume next
	if isobject(r_doc)=false then
		set r_doc=Server.CreateObject(king_xmldom)
		r_doc.async=false
		'判断是否存在所设置的语言包,如果没有就调用默认设置的语言包
		if king.isexist(king_system&"passport/language/"&king.language&".xml") then
			r_doc.load(server.mappath(king_system&"passport/language/"&king.language&".xml"))
		else
			r_doc.load(server.mappath(king_system&"passport/language/"&king_language&".xml"))
		end if
	end if
	lang=r_doc.documentElement.SelectSingleNode("//kingcms/"&l1).text
	if err.number<>0 then
		lang="["&l1&"]"
		err.clear
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function navigationuser()
	dim rs,I1,I2,I3,I4,I5,i
	set rs=conn.execute("select navigationuser from kingpassport_config where systemname='KingCMS';")
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
		I1="<div id=""k_usermenu"">"
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
		I1=I1&"</div>"
	end if
	navigationuser=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub list()
	dim msgcount,query:query=quest("query",0)
	Il "<h2>"&lang("title")
	if king_remoteurl="../" then

		Il "<span class=""listmenu"">"
		Il "<a href=""index.asp"">["&king.lang("common/list")&"]</a>"
		Il "<a href=""index.asp?action=lock"">["&lang("common/lockuser")&"]</a>"
		Il "<a href=""index.asp?action=log"">["&lang("common/log")&"]</a>"
		Il "[<a href=""index.asp?action=msg"">"&lang("common/pubmsg")&"</a>"
		msgcount=conn.execute("select count(*) from kingpassport_msg where isview=0 and username='[SYSTEM]';")(0)
		Il "<a href=""index.asp?action=ppmsg"">"&lang("common/ppmsg")
		if msgcount>0 then
			Il "("&msgcount&")"
		end if
		Il "</a>]"
		Il "[<a href=""index.asp?action=config"">"&lang("common/config")&"</a>"
		Il "<a href=""index.asp?action=protocal"">"&lang("common/protocal")&"</a>]"
		if len(query)>0 then
			Il "<kbd id=""search"">"
			Il "<input type=""text"" value="""&formencode(query)&""" onkeydown=""if(event.keyCode==13) {window.location='index.asp?action=search&query='+encodeURI(this.value); return false;}"" />"
			Il "</kbd>"
		else
			Il "<kbd id=""search""><a href=""javascript:;"" onclick=""gethtm('index.asp?action=insearch','search')"">["&king.lang("common/search")&"]</a></kbd>"
		end if
		Il "</span>"
	end if
	Il "</h2>"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub install()
	king.head "admin",0
	dim sql,nlogin,nlogout,nuser
	'kingpassport 
	sql="ppid int not null identity primary key,"'id
	sql=sql&"ppname nvarchar(30),"'帐号
	sql=sql&"pppass nvarchar(32),"'密码
	sql=sql&"ppkey nvarchar(6),"'密码塞子
	sql=sql&"isdel int not null default 0,"'删除
	sql=sql&"islock int not null default 0,"'锁定
	sql=sql&"ppmail nvarchar(100),"'邮箱
	sql=sql&"ppmailis int not null default 0,"'是否公开mail，默认不公开
	sql=sql&"pplanguage nvarchar(10),"'语言
	sql=sql&"ppquestion nvarchar(50),"'安全提问
	sql=sql&"ppanswer nvarchar(50)"'答案
	conn.execute "create table kingpassport ("&sql&")"
	'kingpassport_config
	sql="systemname nvarchar(20),"
	sql=sql&"systemver nvarchar(10),"'系统版本
	sql=sql&"pptemplate nvarchar(50),"'pp系统模板
	sql=sql&"isclose int not null default 0,"'是否关闭注册 1关闭
	sql=sql&"protocal ntext,"'用户注册协议
	sql=sql&"navigationlogout ntext,"'用户导航 未登录
	sql=sql&"navigationlogin ntext,"'用户导航 已登录
	sql=sql&"navigationuser ntext,"'登入后的用户菜单
	sql=sql&"reservename ntext"'限制注册的会员名
	conn.execute "create table kingpassport_config ("&sql&")"
	nlogin="{language=zh-cn"&chr(13)&chr(10)
	nlogin=nlogin&"注册|(king:page/)"&king.path&"/reg.asp"&chr(13)&chr(10)
	nlogin=nlogin&"登录|(king:page/)"&king.path&"/login.asp"&chr(13)&chr(10)
	nlogin=nlogin&"}"
	nlogout="{language=zh-cn"&chr(13)&chr(10)
	nlogout=nlogout&"用户中心|(king:page/)"&king.path&chr(13)&chr(10)
	nlogout=nlogout&"退出|(king:page/)"&king.path&"/logout.asp"&chr(13)&chr(10)
	nlogout=nlogout&"}"
	nuser="{language=zh-cn"&chr(13)&chr(10)
	nuser=nuser&"用户中心|(king:page/)"&king.path&chr(13)&chr(10)
	nuser=nuser&"我的好友|(king:page/)"&king.path&"/friend.asp"&chr(13)&chr(10)
	nuser=nuser&"更新密码|(king:page/)"&king.path&"/index.asp?action=UpPass"&chr(13)&chr(10)
	nuser=nuser&"参数设置|(king:page/)"&king.path&"/index.asp?action=config"&chr(13)&chr(10)
	nuser=nuser&"}"
	conn.execute "insert into kingpassport_config (systemname,pptemplate,protocal,reservename,navigationlogout,navigationlogin,navigationuser,systemver) values ('"&king.systemname&"','"&king_default_template&"','"&protocal&"','fuck,江泽民,系统,管理员,法轮,kingcms,kcms','"&safe(nlogin)&"','"&safe(nlogout)&"','"&safe(nuser)&"','"&r_ver&"')"
	'kingpassport_log
	sql="logid int not null identity primary key,"
	sql=sql&"ppname nvarchar(12),"
	sql=sql&"ip nvarchar(15),"
	sql=sql&"lognum int not null default 0,"
	sql=sql&"logdate datetime"
	conn.execute"create table kingpassport_log ("&sql&");"
	'kingpassport_msg 
	sql="msgid int not null identity primary key,"
	sql=sql&"isview int not null default 0,"'1已经阅读
	sql=sql&"letuser nvarchar(30),"'发送人
	sql=sql&"username nvarchar(30),"'接收人
	sql=sql&"msgtitle nvarchar(50),"'短信标题
	sql=sql&"msgcontent ntext,"'短信内容
	sql=sql&"msgdate datetime"'发送时间
	conn.execute "create table kingpassport_msg ("&sql&")"
	'kingpassport_friend
	sql="friendid int not null identity primary key,"
	sql=sql&"friendname nvarchar(30),"'好友名称
	sql=sql&"username nvarchar(30)"'所属
	conn.execute "create table kingpassport_friend ("&sql&")"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private property get protocal
	dim l1
	l1="<p>1) 遵守所有使用网站服务的网络协议、规定、程序和惯例。</p>"
	l1=l1&"<p>2) 不在论坛BBS或留言簿发表任何与政治相关的信息。</p>"
	l1=l1&"<p>3) 从中国境内向外传输技术性资料时必须符合中国有关法规。</p>"
	l1=l1&"<p>4) 使用网站服务不作非法用途。</p>"
	l1=l1&"<p>5) 不干扰或混乱网络服务。</p>"
	l1=l1&"<p>6) 不得利用本站危害国家安全、泄露国家秘密，不得侵犯国家社会集体的和公民的合法权益。</p>"
	l1=l1&"<p>7) 不得利用本站制作、复制和传播下列信息：</p>"
	l1=l1&"<p>&nbsp; &nbsp; 1、煽动抗拒、破坏宪法和法律、行政法规实施的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 2、煽动颠覆国家政权，推翻社会主义制度的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 3、煽动分裂国家、破坏国家统一的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 4、煽动民族仇恨、民族歧视，破坏民族团结的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 5、捏造或者歪曲事实，散布谣言，扰乱社会秩序的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 6、宣扬封建迷信、淫秽、色情、赌博、暴力、凶杀、恐怖、教唆犯罪的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 7、公然侮辱他人或者捏造事实诽谤他人的，或者进行其他恶意攻击的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 8、损害国家机关信誉的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 9、其他违反宪法和法律行政法规的；</p>"
	l1=l1&"<p>&nbsp; &nbsp; 10、进行商业广告行为的。</p>"
	l1=l1&"<p><strong>附录：</strong></p>"
	l1=l1&"<p>&nbsp; &nbsp; <a target=""_blank"" href=""http://www.cnnic.net.cn/html/Dir/2000/10/08/0653.htm"">互联网电子公告服务管理规定</a></p>"
	l1=l1&"<p>&nbsp; &nbsp; <a target=""_blank"" href=""http://www.cnnic.net.cn/html/Dir/1997/05/20/0646.htm"">中华人民共和国计算机信息网络国际联网管理暂行规定</a></p>"
	l1=l1&"<p>&nbsp; &nbsp; <a target=""_blank"" href=""http://www.cnnic.net.cn/html/Dir/1994/02/18/0644.htm"">中华人民共和国计算机信息系统安全保护条例</a></p>"
	l1=l1&"<p>&nbsp; &nbsp; <a target=""_blank"" href=""http://www.cnnic.net.cn/html/Dir/1997/12/11/0650.htm"">计算机信息网络国际联网安全保护管理办法</a></p>"
	protocal=l1
end property

end class


'***  ***  ***  ***  ***
'        标签解析
'***  ***  ***  ***  ***

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_passport_newuser()
	on error resume next
	dim I1,rs
	if king_remoteurl="../" then
		set rs=conn.execute("select ppname from kingpassport where isdel=0 order by ppid desc;")
			if not rs.eof and not rs.bof then
				I1=rs(0)
			else
				I1="--"
			end if
			rs.close
		set rs=nothing
	else'远程获得最新注册会员
		I1=king.gethtm(king_remoteurl&"passport/check.asp?action=newuser&"&king.remotekey,0)
	end if
	king_tag_passport_newuser=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_passport_usernav()
	on error resume next
	'默认输出非登录状态
	'js检查cookies，如果cookies存在，就innerHTML登入后界面
	dim I1
	I1="<span id=""k_usernav""></span><script type=""text/javascript"">"
	I1=I1&"if(readCookie('"&md5(king_salt_user,0)&"|name').length>0){gethtm('"&king.page&"passport/index.asp?action=usernavlogin','k_usernav')}else{gethtm('"&king.page&"passport/index.asp?action=usernavlogout','k_usernav')};"
	I1=I1&"</script>"
	king_tag_passport_usernav=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_passport_countuser()
	on error resume next
	dim I1
	if king_remoteurl="../" then
		I1=conn.execute("select count(*) from kingpassport;")(0)
	else
		I1=king.gethtm(king_remoteurl&"passport/check.asp?action=countuser&"&king.remotekey,0)
	end if
	king_tag_passport_countuser=I1
end function
%>