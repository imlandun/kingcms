<!--#include file="../system/plugin.asp"-->
<%

'***  ***  ***  ***  ***
' 通行证/会员 注册页面
'***  ***  ***  ***  ***

dim pp
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set pp=new passport
	select case action
	case"" king_def
	end select
set pp=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/reg.asp"

	dim data,dataform,sql,logsql,i,checked,invalue,re
	dim rs,reservenames,reservename:reservename=true
	dim ppkey,pppass

	re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="/"

	sql="ppname,ppmail,ppmailis,ppquestion,ppanswer"'5
	
	dataform=split(sql,",")
	redim data(ubound(dataform),0)
	if king.ismethod then
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		'检查保留用户名
		set rs=conn.execute("select reservename from kingpassport_config where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				if len(data(0,0))>0 and len(rs(0)) then
					reservenames=split(rs(0),",")
					for i=0 to ubound(reservenames)
						if len(trim(reservenames(i)))>0 then
							if instr(lcase(data(0,0)),lcase(reservenames(i)))>0 then
								reservename=false
							end if
						end if
					next
				end if
			end if
		set rs=nothing	
	end if

	'限制一个IP重复注册帐号
	if king_dbtype=1 then
		logsql="select count(logid) from kingpassport_log where ip='"&safe(king.ip)&"' and lognum=4 and getdate()-logdate<1;"
	else
		logsql="select count(logid) from kingpassport_log where ip='"&safe(king.ip)&"' and lognum=4 and now()-logdate<1;"
	end if

	if conn.execute(logsql)(0)>=1 then
		king.ol="<div class=""k_form"">"
		king.ol="<ol>"
		king.ol="<li class=""error"">"&pp.lang("tip/registration")&"</li>"
		king.ol="<li><a href=""/"">"&pp.lang("list/home")&"</a></li>"
		king.ol="<li><a href="""&re&""">"&re&"</a></li>"
		king.ol="</ol>"
		king.ol="</div>"
	else
		king.ol="<form name=""form1"" method=""post"" action=""reg.asp"" class=""k_form"">"

		king.ol="<p><label>"&pp.lang("label/name")&" ("&pp.name_min&"-"&pp.name_max&")</label>"
		king.ol="<input class=""k_in2"" type=""text"" name=""ppname"" value="""&formencode(data(0,0))&""" maxlength="""&pp.name_max&""" />"
		king.ol=king.check("ppname|6|"&encode(pp.lang("check/name"))&"|"&pp.name_min&"-"&pp.name_max&";ppname|11|"&encode(pp.lang("check/name1"))&";ppname|9|"&encode(pp.lang("check/name2"))&"|select count(*) from kingpassport where ppname='$pro$';"&reservename&"|13|"&encode(pp.lang("check/name2")))&"</p>"

		king.ol="<p><label>"&pp.lang("label/pass1")&" (6-30)</label>"
		king.ol="<input class=""k_in2"" type=""password"" name=""pass1"" maxlength=""30"" />"
		king.ol=king.check("pass1|7|"&encode(pp.lang("check/pwdcontrast"))&"|pass2;pass1|6|"&encode(pp.lang("check/pwdsize"))&"|6-30")&"</p>"

		king.ol="<p><label>"&pp.lang("label/pass2")&" (6-30)</label>"
		king.ol="<input class=""k_in2"" type=""password"" name=""pass2"" maxlength=""30"" /></p>"

		king.ol="<p><label>"&pp.lang("label/mail")&" ("&pp.name_min&"-"&pp.name_max&")</label>"
		king.ol="<input class=""k_in3"" type=""text"" name=""ppmail"" value="""&formencode(data(1,0))&""" maxlength=""100"" />"
		if cstr(data(2,0))="0" then checked=" checked=""checked""" else checked=""
		king.ol="<input type=""checkbox"" id=""ppmailis"" name=""ppmailis"" value=""0"""&checked&" />"
		king.ol="<span><label for=""ppmailis"">"&pp.lang("label/mailis")&"</label></span>"
		king.ol=king.check("ppmail|6|"&encode(pp.lang("check/mail"))&"|1-100;ppmail|4|"&encode(pp.lang("check/mail1"))&";ppmail|9|"&encode(pp.lang("check/mail2"))&"|select count(*) from kingpassport where ppmail='$pro$'")&"</p>"

		king.ol="<p><label>"&pp.lang("label/question")&" (1-50)</label>"
		king.ol="<input class=""k_in4"" type=""text"" name=""ppquestion"" value="""&formencode(data(3,0))&""" maxlength=""50"" />"
		king.ol=king.check("ppquestion|6|"&encode(pp.lang("check/question"))&"|1-50")&"</p>"

		king.ol="<p><label>"&pp.lang("label/answer")&" (1-50)</label>"
		king.ol="<input class=""k_in4"" type=""text"" name=""ppanswer"" value="""&formencode(data(4,0))&""" maxlength=""50"" />"
		king.ol=king.check("ppanswer|6|"&encode(pp.lang("check/answer"))&"|1-50")&"</p>"

		king.ol="<div>"
		king.ol="<input type=""submit"" value="""&pp.lang("common/reg")&""" /> "
		king.ol="<input name=""re"" type=""hidden"" value="""&formencode(re)&""" />"
		king.ol="<a target=""_blank"" href=""protocal.asp"">"&pp.lang("label/protocal")&"</a>"
		king.ol="</div>"
		king.ol="</form>"
	end if


	if king.ischeck and king.ismethod then
		'参数设置
		if cstr(data(2,0))="0" then data(2,0)=0 else data(2,0)=1
		ppkey=salt(6):pppass=form("pass1")
		pppass=md5(pppass&ppkey,1)
		'提交数据
		conn.execute "insert into kingpassport ("&sql&",pppass,ppkey,pplanguage) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"',"&safe(data(2,0))&",'"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&safe(pppass)&"','"&safe(ppkey)&"','"&safe(king_language)&"')"
		conn.execute "insert into kingpassport_log (ppname,ip,lognum,logdate) values ('"&safe(data(0,0))&"','"&safe(king.ip)&"',4,'"&safe(tnow)&"')"
		'写cookies
		response.cookies(md5(king_salt_user,0))("name")=data(0,0)
		response.cookies(md5(king_salt_user,0))("pass")=md5(left(ppkey,3)&pppass,1)
		if king_remoteurl="../" then
			response.cookies(md5(king_salt_user,0)).domain=king.url
		else
			response.cookies(md5(king_salt_user,0)).domain=king_domain
		end if
		session(md5(king_salt_user,0))=data(0,0)&"|"&king_language&"|0"

		'输出提示
		king.clearol
		king.ol="<div class=""k_form"">"
		king.ol="<ol>"
		king.ol="<li><a href=""index.asp"">"&pp.lang("list/center")&"</a></li>"
		king.ol="<li><a href=""/"">"&pp.lang("list/home")&"</a></li>"
		king.ol="<li><a href="""&re&""">"&re&"</a></li>"
		king.ol="<li><a href=""logout.asp"" onClick=""javascript:return confirm('"&htm2js(king.lang("confirm/logout"))&"')"">"&pp.lang("common/logout")&"</a></li>"
		king.ol="</ol>"
		king.ol="</div>"
	end if

	king.value "title",encode(pp.lang("common/regpp"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue

end sub


%>