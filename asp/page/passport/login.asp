<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'     登录/找回密码
'***  ***  ***  ***  ***

dim pp
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set pp=new passport
	select case action
	case"" king_def
	case"getpass" king_getpass
	end select
set pp=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()

	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/login.asp"

	dim ispwd,checked,sql,rs,re,loginok
	dim ppname,pppass,md5pass,ppkey,logcount,errtext
	
	king.pphead 0

	ispwd=true:loginok=false
	ppname=form("ppname"):pppass=form("pppass")

	re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="/"

	if len(ppname)>0 and len(pppass)>=6 then
		if king_dbtype=1 then
			sql="select count(logid) from kingpassport_log where ip='"&safe(king.ip)&"' and lognum=2 and getdate()-logdate<0.25;"
		else
			sql="select count(logid) from kingpassport_log where ip='"&safe(king.ip)&"' and lognum=2 and now()-logdate<0.25;"
		end if
		logcount=conn.execute(sql)(0)

		if logcount>=pp.loginnum then
			errtext="<p class=""k_error"">"&pp.lang("tip/lock")&"</p>"
		else
			set rs=conn.execute("select ppkey,pppass,pplanguage,islock from kingpassport where ppname='"&safe(ppname)&"' and isdel=0;")
				if not rs.eof and not rs.bof then
					md5pass=md5(pppass&rs(0),1)
					if cstr(rs(1))=cstr(md5pass) then
						conn.execute "insert into kingpassport_log (ppname,lognum,ip,logdate) values ('"&safe(ppname)&"',1,'"&safe(king.ip)&"','"&tnow&"')"
						'写cookies
						response.cookies(md5(king_salt_user,0))("name")=ppname
						response.cookies(md5(king_salt_user,0))("pass")=md5(left(rs(0),3)&md5pass,1)
						if king_remoteurl="../" then
							response.cookies(md5(king_salt_user,0)).domain=king.url
						else
							response.cookies(md5(king_salt_user,0)).domain=king_domain
						end if
						session(md5(king_salt_user,0))=ppname&"|"&rs(2)&"|"&rs(3)
						if cstr(form("validity"))="0" then
							response.cookies(md5(king_salt_user,0)).expires=now+365
						end if
						'登录成功后的提示
						king.ol="<div class=""k_form"">"
						king.ol="<ol>"
						king.ol="<li><a href=""index.asp"">"&pp.lang("list/center")&"</a></li>"
						king.ol="<li><a href=""/"">"&pp.lang("list/home")&"</a></li>"
						king.ol="<li><a href="""&re&""">"&re&"</a></li>"
						king.ol="<li><a href=""logout.asp"" onClick=""javascript:return confirm('"&htm2js(king.lang("confirm/logout"))&"')"">"&pp.lang("common/logout")&"</a></li>"
						king.ol="</ol>"
						king.ol="</div>"
						loginok=true
					else
						conn.execute "insert into kingpassport_log (ppname,lognum,ip,logdate) values ('"&safe(ppname)&"',2,'"&safe(king.ip)&"','"&tnow&"')"
						ispwd=false
					end if
				else
					conn.execute "insert into kingpassport_log (ppname,lognum,ip,logdate) values ('"&safe(ppname)&"',2,'"&safe(king.ip)&"','"&tnow&"')"
					if pp.loginnum-logcount=1 then
						errtext="<p class=""k_error"">"&pp.lang("tip/lock")&"</p>"
					else
						ispwd=false'response.write "<p class=""red"">您的帐号或密码有误 !还有"&(king_loginnum-logcount-1)&"次登录的机会。</p>"
					end if
				end if
				rs.close
			set rs=nothing
		end if
		
	end if
	
	if loginok=false then

		king.ol="<form name=""form1"" method=""post"" action=""login.asp"" class=""k_form"">"

		if len(errtext)>0 then
			king.ol=errtext
		else

			king.ol="<p><label>"&pp.lang("label/name")&"</label>"
			king.ol="<input class=""k_in2"" type=""text"" name=""ppname"" value="""&formencode(ppname)&""" maxlength="""&pp.name_max&""" />"
			king.ol=" <a href="""&king_remoteurl&"passport/reg.asp"">["&pp.lang("common/regpp")&"]</a>"
			king.ol=king.check("ppname|6|"&encode(pp.lang("check/name"))&"|"&pp.name_min&"-"&pp.name_max&";ppname|11|"&encode(pp.lang("check/name1"))&";ppname|9|"&encode(pp.lang("check/name3"))&"|select count(ppid) from kingpassport where ppname='$pro$' and isdel=1;"&ispwd&"|13|"&encode(pp.lang("check/pwderr")))&"</p>"

			king.ol="<p><label>"&pp.lang("label/pass1")&"</label>"
			king.ol="<input type=""password"" class=""k_in2"" name=""pppass"" maxlength=""30"" />"
			king.ol=" <a href="""&king_remoteurl&"passport/login.asp?action=getpass"">["&pp.lang("common/getpass")&"]</a>"
			king.ol=king.check("pppass|6|"&encode(pp.lang("check/pwdsize"))&"|6-30")
			king.ol="</p>"


			king.ol="<p>"
			if cstr(form("validity"))="0" then checked=" checked=""checked""" else checked=""
			king.ol="<input type=""checkbox"" id=""validity"" name=""validity"" value=""0"""&checked&" />"
			king.ol="<span><label for=""validity"">"&pp.lang("label/validity")&"</label></span>"
			king.ol="</p>"

			king.ol="<div>"
			king.ol="<input type=""submit"" value="""&pp.lang("common/login")&""" /> "
			king.ol="<input name=""re"" type=""hidden"" value="""&formencode(re)&""" />"
			king.ol="</div>"&vbcr

'			if king_remoteurl<>"../" then'跨站验证
'				king.ol="<iframe src="""&king_remoteurl&"passport/login.asp?action=remote""></iframe>"
'				king.ol="<div id=""kkkk""></div><script type=""text/javascript"">gethtm('"&king_remoteurl&"passport/login.asp?action=remote""','kkkk')</script>"
'				king.ol=king.gethtm(king_remoteurl&"passport/login.asp?action=remote",2)
'				king.ol="<script type=""text/javascript"">var k_pp=new Array();</script>"&vbcr
'				king.ol="<script src="""&king_remoteurl&"passport/login.asp?action=remote"" type=""text/javascript""></script>"&vbcr
'				king.ol="<script type=""text/javascript"">var k_islogin=0;"&vbcr'登录状态，action=cookie返回这个状态值
''				king.ol="alert(document.cookie);"
'				king.ol="if(k_pp[0].length>0){document.write('<script type=""text/javascript"" src=""login.asp?action=cookie&name='+k_pp[0]+'&pass='+k_pp[1]+'""><\/script>');};"&vbcr'提交给login.asp?cookie远程帐号和密码来进行验证
'				king.ol="</script>"&vbcr'cookie用asp来读取remoteurl地址进行再次验证，如果通过就在本地写cookies
'				
'
'				'如果返回的islogin值为1，则跳转到成功登录提示页面，为0无提示
'				king.ol="<script type=""text/javascript"">if(k_islogin==1){eval('parent.location=\'login.asp?action=loginok\'');};</script>"
'			end if

		end if
		
		king.ol="</form>"

	end if


	king.value "title",encode(pp.lang("common/login"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_getpass()
	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/login.asp?action=getpass"

	king.pphead 0

	dim rs,ppquestion,data,ppkey,pppass,md5pass
	dim is1,is2
	is1=true:is2=true

	'提交用户名
	king.ol="<form name=""form1"" method=""post"" action=""login.asp?action=getpass"" class=""k_form"">"

	king.ol="<p><label>"&pp.lang("list/name")&"</label><input class=""k_in2"" type=""text"" name=""ppname"" value="""&formencode(form("ppname"))&""" maxlength="""&pp.name_max&""" />"
	king.ol=king.check("ppname|6|"&encode(pp.lang("check/name"))&"|"&pp.name_min&"-"&pp.name_max&";ppname|11|"&encode(pp.lang("check/name1"))&";ppname|9|"&encode(pp.lang("check/name4"))&"|select count(*) from kingpassport where ppname='$pro$' and isdel=1")
	king.ol="</p>"

	if king.ismethod then'当没有其他错误的时候，验证帐号和邮箱是否一致
		if conn.execute("select count(*) from kingpassport where ppname='"&safe(form("ppname"))&"' and ppmail='"&safe(form("ppmail"))&"' and isdel=0;")(0)=0 then
			is1=false
		end if
	end if
	king.ol="<p><label>"&pp.lang("list/mail")&"</label><input class=""k_in2"" type=""text"" name=""ppmail"" value="""&formencode(form("ppmail"))&""" maxlength=""100"" />"
	king.ol=king.check("ppmail|6|"&encode(pp.lang("check/mail"))&"|1-100;ppmail|4|"&encode("check/mail1")&";"&is1&"|13|"&encode(pp.lang("check/is1")))
	king.ol="</p>"

	king.ol="<div>"
	king.ol="<input type=""submit"" value="""&king.lang("common/submit")&""" /> "
	king.ol="</div>"
	king.ol="</form>"

	'检查预置的问题和答案是否一致
	if king.ismethod and king.ischeck then
		king.clearol
		king.ol="<form name=""form1"" method=""post"" action=""login.asp?action=getpass"" class=""k_form"">"
		
		set rs=conn.execute("select ppquestion,ppanswer from kingpassport where ppname='"&safe(form("ppname"))&"';")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				if data(1,0)<>form("ppanswer") then is2=false'提交的和预置的答案要一致
			end if
			rs.close
		set rs=nothing

		king.ol="<p><label>"&pp.lang("list/name")&"</label><input class=""k_in2"" type=""text"" disabled=""true"" value="""&formencode(form("ppname"))&""" /></p>"

		king.ol="<p><label>"&data(0,0)&"</label><input class=""k_in3"" type=""text"" name=""ppanswer"" value="""&formencode(form("ppanswer"))&""" maxlength=""50"" />"
		if len(form("ppanswer"))>0 then'如果ppanser值不为空，就进行验证
			king.ol=king.check("ppanswer|6|"&encode(pp.lang("check/answer"))&"|1-50;"&is2&"|13|"&encode(pp.lang("check/is2")))
		else'若为空，设置ischeck为false，以防止进入下一步
			king.setischeck=false
		end if
		king.ol="</p>"
		
		king.ol="<div>"
		king.ol="<input type=""submit"" value="""&king.lang("common/submit")&""" /> "
		king.ol="<input type=""hidden"" name=""ppname"" value="""&formencode(form("ppname"))&""" />"
		king.ol="<input type=""hidden"" name=""ppmail"" value="""&formencode(form("ppmail"))&""" />"
		king.ol="</div>"
		king.ol="</form>"

		if king.ischeck then
			king.clearol
			'更新密码
			king.ol="<form name=""form1"" method=""post"" action=""login.asp?action=getpass"" class=""k_form"">"
			
			'设置新密码
			king.ol="<p><label>"&pp.lang("common/newpass1")&"</label><input class=""k_in2"" type=""password"" name=""pass1"" maxlength=""30"" />"
			if len(form("pass1"))>0 then
				king.ol=king.check("pass1|7|"&encode(pp.lang("check/pass1"))&"|pass2;pass1|6|"&encode(pp.lang("check/pwdsize"))&"|6-30")
			else
				king.setischeck=false
			end if
			king.ol="</p>"

			king.ol="<p><label>"&pp.lang("common/newpass2")&"</label><input class=""k_in2"" type=""password"" name=""pass2"" maxlength=""30"" /></p>"
			
			king.ol="<div>"
			king.ol="<input type=""submit"" value="""&king.lang("common/submit")&""" /> "
			king.ol="<input type=""hidden"" name=""ppname"" value="""&formencode(form("ppname"))&""" />"
			king.ol="<input type=""hidden"" name=""ppmail"" value="""&formencode(form("ppmail"))&""" />"
			king.ol="<input type=""hidden"" name=""ppanswer"" value="""&formencode(form("ppanswer"))&""" />"
			king.ol="</div>"
			king.ol="</form>"
			if king.ischeck then
				ppkey=salt(6):pppass=form("pass1")
				pppass=md5(pppass&ppkey,1)
				conn.execute "update kingpassport set ppkey='"&safe(ppkey)&"',pppass='"&safe(pppass)&"' where ppname='"&safe(form("ppname"))&"';"'重新写新的密码

				response.cookies(md5(king_salt_user,0))("name")=form("ppname")
				response.cookies(md5(king_salt_user,0))("pass")=md5(left(ppkey,3)&pppass,1)
				if king_remoteurl="../" then
					response.cookies(md5(king_salt_user,0)).domain=king.url
				else
					response.cookies(md5(king_salt_user,0)).domain=king_domain
				end if
				session(md5(king_salt_user,0))=form("ppname")&"|"&king_language&"|0"

				'输出提示，并结束过程
				king.clearol
				king.ol="<div class=""k_form"">"
				king.ol="<ol>"
				king.ol="<li>"&pp.lang("tip/getpass")&"</li>"
				king.ol="<li><a href=""index.asp"">"&pp.lang("list/center")&"</a></li>"
				king.ol="<li><a href=""/"">"&pp.lang("list/home")&"</a></li>"
				king.ol="<li><a href=""logout.asp"" onClick=""javascript:return confirm('"&htm2js(king.lang("confirm/logout"))&"')"">"&pp.lang("common/logout")&"</a></li>"
				king.ol="</ol>"
				king.ol="</div>"
			end if
		end if
	end if
	
	king.value "title",encode(pp.lang("common/getpasstitle"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue
end sub



%>