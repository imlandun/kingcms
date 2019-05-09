<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit%>
<!--#include file="conn.asp"-->
<!--#include file="config.asp"-->
<!--#include file="inc/upcls.asp"-->
<!--#include file="inc/md5.asp"-->
<!--#include file="inc/fckeditor.asp"-->
<%response.charset="utf-8"
'kingcms  *** Copyright &copy KingCMS.com All Rights Reserved. ***
class kingcms

private r_systemver,r_dbver,r_sitename,r_siteurl,r_isgetinfo,r_systemname
private r_ischeck,r_ismethod
private r_id,r_name,r_level,r_editor,r_language,r_plugin
private r_doc,r_end,r_inst,r_path,r_is,r_value
private r_remotekey
private r_mapname,r_mapnumber,r_map_is
private r_thisver

private r_ol,r_islock

'begin  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private sub class_initialize()

	r_systemver="5.1.0.0810"'当前程序版本

	r_thisver="5.02"'程序对应的数据库版本

	r_end=true
	r_isgetinfo=true
	r_is=true
	r_ischeck=true
	if len(trim(request.servervariables("content_type")))>0 then
		r_ismethod=true
	else
		r_ismethod=false
	end if
	r_map_is=false
	'验证数据库连接
	on error resume next
	set conn=server.createobject("adodb.connection")
	conn.open objconn
	if err.number<>0 then
		set r_doc=Server.CreateObject(king_xmldom)
		r_doc.async=false
		r_doc.load(server.mappath(king_system&"system/language/"&king_language&".xml"))
		response.write r_doc.documentElement.SelectSingleNode("//kingcms/error/db").text
		r_end=false
		response.end()
	end if
	err.clear
end sub
'ip  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get ip
	if len(ip)=0 then
		ip=request.servervariables("http_x_forwarded_for")
		if ip="" then ip=request.servervariables("remote_addr")
	end if
end property
'url  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get url
	if len(url)=0 then
		url=request.servervariables("server_name")
		if left(url,4)="www." then
			url=right(url,len(url)-4)
		end if
	end if
end property
'ol  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property let ol(l1)
	r_ol=r_ol&l1
end property
'mapname  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get mapname
	if r_map_is=false then getsitemap
	mapname=r_mapname
end property
'mapnumber  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get mapnumber
	if r_map_is=false then getsitemap
	mapnumber=r_mapnumber
end property
'getsitemap  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
private sub getsitemap()
	dim rs
	r_map_is=true
	set rs=conn.execute("select sitemap,sitemapnumber from kingsystem where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			r_mapname=rs(0)
			r_mapnumber=rs(1)
		end if
		rs.close
	set rs=nothing
end sub
'writeol  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get writeol
	writeol=r_ol
end property
'clearol  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get clearol
	r_ol=""
end property
'value  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public sub value(l1,l2)
	if len(r_value)>0 then
		r_value=r_value&"|"&lcase(l1)&":"&l2
	else
		r_value=lcase(l1)&":"&l2
	end if
end sub
'clearvalue  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get clearvalue
	r_value=""
end property
'invalue  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get invalue
	invalue=r_value
end property
'getvalue  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public function getvalue(l1,l2)
	dim I1,I2,i
	I1=split(l1,"|")
	for i=0 to ubound(I1)
		if cstr(split(I1(i),":")(0))=cstr(l2) then
			I2=split(I1(i),":")(1)
			exit for
		end if
	next
	getvalue=decode(I2)
end function
'getlabel  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public function getlabel(l1,l2)
	dim l3,I1,I2
	if cstr(l2)="0" then
		I1=sect(l1,"(\})","(\{\/king\})","")
	else
		l3=match(l1,"\{king\:.+?\}")
		I1=sect(l3,l2&"=""","""","")
	end if
	if validate(I1,2)=false then
		select case cstr(l2)
		case"number" I1="20"
		case"zebra" I1="1"
		end select
	end if

	getlabel=I1
end function
'getdblabel  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public function getdblabel(l1,l2)
	dim l3,I1,I2
	if cstr(l2)="0" then
		I1=sect(l1,"(\}\})","(\{\{\/king\}\})","")
	else
		l3=match(l1,"\{\{king\:.+?\}\}")
		I1=sect(l3,l2&"=""","""","")
	end if
	if validate(I1,2)=false then
		select case cstr(l2)
		case"zebra" I1="1"
		end select
	end if
	getdblabel=I1
end function
'getlist  *** ***  www.KingCMS.com  *** ***
public function getlist(l1,l3,l4)
	dim l5,l2
	l2=match(l1,"(\{king:"&l3&").+?type=\""list\"".{0,}?(\})(.|\n)+?\{\/king\}")
	if cstr(l4)="0" then
		l5=sect(l2,"(\})","(\{\/king\})","")
	elseif cstr(l4)="1" then
		l5=l2
	else
		l5=getlabel(l2,l4)
	end if
	getlist=l5
end function
'outhtm  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public sub outhtm(l1,l2,l3)'外部模板名称,内部模板名称,values
	dim I1
	r_end=false
	I1=create(read(l1,l2),l3)
	Il I1
	checkrobot
end sub
'checkrobot  *** ***  www.KingCMS.com  *** ***
private sub checkrobot()
	dim I1,I2,l1,l2,l3,i,rs,l4
	l2=false
	l1=request.servervariables("http_user_agent")
	set rs=conn.execute("select robot from kingsystem where systemname='KingCMS'")
		if not rs.eof and not rs.bof then
			l4=rs(0)
			if len(trim(l4))=0 then exit sub
		else
			exit sub
		end if
		rs.close
	set rs=nothing
	I1=split(l4,chr(13)&chr(10))
	for i=0 to ubound(I1)
		I2=split(I1(i),chr(124))
		if instr(lcase(l1),lcase(I2(1)))>0 then
			l2=true:l3=I2(0):exit for
		end if
	next
	
	if l2 and len(l3)>0 then'如果是爬虫,就更新爬虫信息
		set rs=conn.execute("select botid from kingbot where botname='"&l3&"';")
			if not rs.eof and not rs.bof then
				conn.execute "update kingbot set botlastdate='"&tnow&"',botnumber=botnumber+1 where botid="&rs(0)&";"
			else
				conn.execute "insert into kingbot (botname,botdate,botlastdate) values ('"&l3&"','"&tnow&"','"&tnow&"');"
			end if
			rs.close
		set rs=nothing
	end if
end sub
'stemplate  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get stemplate
	dim rs'没有太大的必要去用内部变量做记录，一般仅读取一次
	set rs=conn.execute("select searchtemplate from kingsystem where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			stemplate=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing
end property
'inst  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get inst
	dim scriptname,l1,I1,I2,I3
	if r_inst="" then
		'I1=server.mappath("/")
		'I2=server.mappath("../../")
		I1=Request.ServerVariables("APPL_PHYSICAL_PATH")
		I1=left(I1,(len(I1)-1))
		I2=server.mappath("../../")
		if instr(I2,I1)>0 then
			r_inst=replace(right(I2,len(I2)-len(I1)),"\","/")&"/"
		else
			error lang("error/virtualdirectory")&"<br/>"
		end if
	end if
	inst=r_inst
end property
'system  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get system
	dim I1
	if cstr(system)="" then
		I1=split(king_system,"/")
		system=I1(2)
	end if
end property
'page  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get page
	page=inst&system&"/"
end property
'path  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get path'
	dim scriptname,l1,I1,I2,I3
	if r_path="" then
		scriptname=request.servervariables("script_name")
		I1=split(scriptname,"/")
		I2=ubound(I1)
		r_path=I1(I2-1)
	end if
	path=r_path
end property
'systemver  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public property get systemver
	systemver=r_systemver
end property
'systemname  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public property get systemname
	if r_isgetinfo then getsysteminfo
	systemname=r_systemname
end property
'dbver  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public property get dbver
	if r_isgetinfo then getsysteminfo
	dbver=r_dbver
end property
'plugin  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public property get plugin
	if r_isgetinfo then getsysteminfo
	plugin=r_plugin
end property
'sitename  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
public property get sitename
	if r_isgetinfo then getsysteminfo
	sitename=r_sitename
end property
'siteurl  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
public property get siteurl
	if r_isgetinfo then getsysteminfo
	siteurl=r_siteurl
end property
'checkplugin  *** Copyright &copy KingCMS.com All Rights  Reserved. ***
public sub checkplugin(l1)
	dim I1,I2,i
	if r_isgetinfo then getsysteminfo
	if king.instre(r_plugin,l1)=false then error lang("error/plugin")&"<br/>"
end sub
'checkremote  *** Copyright &copy KingCMS.com All Rights  Reserved. ***
public sub checkremote()
	dim key1,key2
	key1=quest("key1",0)
	key2=quest("key2",0)
	if md5(king_remotekey1,0)=key1 and md5(king_remotekey2,1)=key2 then
	else
		king.txt "KingCMS "&king.systemver
	end if
end sub
'remotekey  *** Copyright &copy KingCMS.com All Rights  Reserved. ***
public property get remotekey
	if len(r_remotekey)=0 then
		r_remotekey="key1="&md5(king_remotekey1,0)&"&key2="&md5(king_remotekey2,1)
	end if
	remotekey=r_remotekey
end property
'getsysteminfo  *** Copyright &copy KingCMS.com All Rights  Reserved. ***
private sub getsysteminfo()
	dim rs
	set rs=conn.execute("select systemver,dbver,sitename,siteurl,plugin,systemname from kingsystem where systemname='KingCMS'")
		if not rs.eof and not rs.bof then
			r_dbver=rs(1)
			r_sitename=rs(2)
			r_siteurl=rs(3)
			r_plugin=rs(4)
			r_systemname=rs(5)
			r_isgetinfo=false
		else
			deletefile "../../system/fun.asp"
		end if
		rs.close
	set rs=nothing
end sub
'ischeck  *** Copyright  &copy KingCMS.com All Rights Reserved. ***
public property get ischeck
	ischeck=r_ischeck
end property
'getischeck  *** Copyright  &copy KingCMS.com All Rights Reserved. ***
public property let setischeck(l1)
	r_ischeck=l1
end property
'ismethod  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
public property get ismethod
	ismethod=r_ismethod
end property
'id  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
public property get id
	id=r_id
end property
'name  *** Copyright &copy  KingCMS.com  All Rights Reserved. ***
public property get name
	name=r_name
end property
'name  *** Copyright &copy  KingCMS.com  All Rights Reserved. ***
public property get level
	level=r_level
end property
'language  *** Copyright  &copy KingCMS.com All  Rights Reserved. ***
public property get language
	dim rs,cookiesname
	if len(r_language)=0 then
		cookiesname=safe(request.cookies(md5(king_salt_admin,1))("name"))
		if len(cookiesname)>0 then
			set rs=conn.execute("select adminlanguage from kingadmin where adminname='"&cookiesname&"';")
				if not rs.eof and not rs.bof then
					r_language=rs(0)
				end if
				rs.close
			set rs=nothing
		end if
		if len(r_language)=0 then r_language=king_language
	end if
	language=r_language
end property
'termi  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private property get termi
	Il l11(king_t1&king_t2&king_t3&king_t4)
end property
'zukye  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private property get zukye
	conn.execute l11(l11l11)
end property
'form_hidden *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_hidden(l1,l2)
	Il "<input type=""hidden"" name="""&l1&""" id="""&l1&""" value="""&formencode(l2)&""" />"
end sub
'form_radio  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_radio(l1,l2,l3,l4)
	dim I2,I3,I4,i
	I3=split(l3,"|")
	Il "<p><label>"&l2&"</label><span>"
	for i=0 to ubound(I3)
		if len(I3(i))>0 then
			I2=split(I3(i),":")
			if ubound(I2)=1 then
				if cstr(decode(I2(0)))=cstr(l4) then I4=" checked=""checked""" else I4=""
				Il "<input type=""radio"" id="""&l1&"_"&i&""" name="""&l1&""" value="""&decode(I2(0))&""""&I4&"/><label for="""&l1&"_"&i&""">"&decode(I2(1))&"</label>"
			else
				if cstr(decode(I3(i)))=cstr(l4) then I4=" checked=""checked""" else I4=""
				Il "<input type=""radio"" id="""&l1&"_"&i&""" name="""&l1&""" value="""&decode(I3(i))&""""&I4&"/><label for="""&l1&"_"&i&""">"&decode(I3(i))&"</label>"
			end if
		end if
	next
	Il "</span></p>"

end sub
'form_brow  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_brow(l1,l2)
	if instre(r_level,"brow") or r_level="admin" then
		if len(l2)>0 then l2=server.urlencode(l2) else l2=""
		Il " <input type=""button"" value="""&lang("common/brow")&""" class=""k_button"" onclick=""posthtm('../system/manage.asp?action=filemanage','aja','type="&l2&"&path='+encodeURIComponent(document.getElementById('"&l1&"').value)+'&formname="&l1&"')"" />"
	end if
end sub
'form_input  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_input(l1,l2,l3,l4)'formname,label,value,check
	dim I1,I2,I3
	I1=sect(l4&";","("&l1&"\|6\|.+?\|)","(\;)","")
	if len(I1)>0 then
		I2=split(I1,"-")
		if ubound(I2)=1 then I3=" maxlength="""&I2(1)&""""
	end if
	Il "<p><label>"&l2&"</label><input type=""text"" name="""&l1&""" id="""&l1&""" value="""&formencode(l3)&""" class=""in4"""&I3&" />"
	Il king.check(l4)
	Il "</p>"
end sub
'form_eval   *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function form_eval(l1,l2)'id,values
	form_eval=" <a href=""javascript:;"" onclick=""javascript:document.getElementById('"&l1&"').value='"&htm2js(htmlencode(l2))&"'"">["&htmlencode(l2)&"]</a>"
end function
'form_tmp  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_tmp(l1,l2,l3,l4)
	if cstr(l4)="0" then l4="" else l4="/inside/"&l4
	Il "<p><label>"&l2&"</label>"'外部模板
	Il "<select name="""&l1&""">"
	Il getfolder ("../../"&king_templates&l4,king_te,"<option value=""$fname$"" $selected$>$fname$</option>",l3)
	Il "</select>"
	Il check(l1&"|6|"&encode(lang("template/check/size"))&"|1-50")
	Il "</p>"
end sub
'form_area  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_area(l1,l2,l3,l4)
	if cstr(l4)="0" then l4=""
	Il "<p><label>"&l2&"</label><textarea name="""&l1&""" id="""&l1&""" rows=""4"" cols=""80"" class=""in4"">"&formencode(l3)&"</textarea>"
	Il king.check(l4)
	Il "</p>"
end sub
'form_select  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_select(l1,l2,l3,l4)
	dim I2,I3,I4,i
	I3=split(l3,"|")
	Il "<p><label>"&l2&"</label>"
	Il "<select name="""&l1&""" id="""&l1&""">"
	for i=0 to ubound(I3)
		if len(I3(i))>0 then
			I2=split(I3(i),":")
			if ubound(I2)=1 then
				if cstr(decode(I2(0)))=cstr(l4) then I4=" selected=""selected""" else I4=""
				Il "<option value="""&decode(I2(0))&""""&I4&">"&decode(I2(1))&"</option>"
			else
				if cstr(decode(I3(i)))=cstr(l4) then I4=" selected=""selected""" else I4=""
				Il "<option value="""&decode(I3(i))&""""&I4&">"&decode(I3(i))&"</option>"
			end if
		end if
	next
	Il "</select>"
	Il "</p>"
end sub
'form_but  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_but(l1)
	Il "<p class=""k_menu"">"
	Il "<input type=""submit"" value="""&lang("common/"&l1)&"[S]"" accesskey=""s"" />"
	Il "<input type=""reset"" value="""&lang("common/reset")&"[R]"" onClick=""javascript:return confirm('"&htm2js(lang("confirm/reset"))&"')"" accesskey=""r""  />"
	Il "<input type=""button"" value="""&lang("common/back")&"[B]"" accesskey=""b"" onClick=""javascript:history.back();"" />"
	Il "</p>"
end sub
'formatmenu  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function formatmenu(l1,l2)'l1为值，l2为名称

	dim I1,I2,I3,I4,i

	if len(l1)>0 then
		l1=replace(l1,"　"," ")
	else
		exit function
	end if

	I1=split(l1,chr(13)&chr(10))
	
	for i=0 to ubound(I1)
		if instr(I1(i),"|")>0 then
			I3=I3&I1(i)&chr(13)&chr(10)
		end if
	next

	I1=split(I3,chr(13)&chr(10))

	I4="<ul id="""&l2&""">"
	if l2="menu" then I4=I4&"<li><a target=""_blank"" href="""&king_system&"system/link.asp?url="&king.inst&""">"&lang("common/home")&"</a></li>"
	for i=0 to ubound(I1)
		I2=split(I1(i),"|")
		if ubound(I2)=1 then

			if instre("http:/,ftp://,https:",left(I2(1),6)) then
				I4=I4&"<li><a href="""&king_system&"system/link.asp?url="&I2(1)&""" target=""_blank"">"&htmlencode(trim(I2(0)))&"</a>"
			else
				I4=I4&"<li><a href="""&I2(1)&""">"&htmlencode(trim(I2(0)))&"</a>"
			end if

			if (left(I1(i),1)=" " and left(i1(i+1),1)=" ") or (left(I1(i),1)<>" " and left(i1(i+1),1)<>" ") then
				I4=I4&"</li>"
			else
				if left(I1(i),1)<>" " and left(I1(i+1),1)=" " then
					I4=I4&"<ul>"
				end if
				
				if left(I1(i),1)=" " and left(I1(i+1),1)<>" " then
					I4=I4&"</li></ul></li>"
				else
				end if
			end if

		else
			I4=I4&"</ul>"
		end if
	next
	formatmenu=I4
end function
'diymenu  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private sub diymenu()
	dim rs,i,I2,I3,l1,l2,l3

	set rs=conn.execute("select diymenu from kingadmin where adminname='"&king.name&"';")
		if not rs.eof and not rs.bof then
			l1=rs(0)
		end if
		rs.close
	set rs=nothing

	if len(l1)>0 then
		Il formatmenu(l1,"menu")
		exit sub
	else
		set rs=conn.execute("select diymenu from kingdiymenu where diymenulang='"&language&"';")
			if not rs.eof and not rs.bof then
				l1=rs(0)
				Il formatmenu(l1,"menu")
			else
				Il "<ul id=""menu"">"
				Il "<li><a target=""_blank"" href="""&king_system&"system/link.asp?url="&king.inst&""">"&lang("common/home")&"</a></li>"
				Il "<li><a href=""../system/manage.asp?action=diymenu"">"&lang("diymenu/title")&"</a></li><li><a href=""javascript:;"">"&lang("parameters/love")&"</a>"
				Il "<ul>"
				Il "<li><a target=""_blank"" href="""&king_system&"system/link.asp?url=http://www.kingcms.com/"">KingCMS.com</a></li>"
				Il "<li><a target=""_blank"" href="""&king_system&"system/link.asp?url=http://bbs.kingcms.com"">KingCMS Forums</a></li>"
				Il "</ul>"
				Il "</li>"
				Il "</ul>"
			end if
			rs.close
		set rs=nothing
	end if

end sub
'tophtml  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private sub tophtml(l1)
	dim I1,I2,I3,i,rs
	Il "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd""><html xmlns=""http://www.w3.org/1999/xhtml""><head><meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8""/><script src=""../system/images/jquery.js"" type=""text/javascript""></script><script src=""../system/images/jquery.kc.js"" type=""text/javascript""></script><title>"&l1&"</title><link href=""../system/images/style.css"" rel=""stylesheet"" type=""text/css"" /></head><body>"
	Il "<div id=""top"">"
		Il "<a id=""logo"" href=""../system/manage.asp"" title="""&king.systemname&" "&king.systemver&"""><img src=""../system/images/logo.png""/></a>"
		Il "<div id=""topright"">"
			Il "<div id=""topmenu"">"
			if r_level="admin" then
				Il "<a href=""../system/create.asp"">"&king.lang("create/title")&"</a>|"
			end if
			if r_level="admin" then
				Il "<a href=""../system/manage.asp?action=admin"">"&king.lang("admin/title")&"</a>|"
			end if
			if r_level="admin" or instre(r_level,"config") then
				Il "<a href=""../system/manage.asp?action=config"">"&king.lang("config/title")&"</a>|"
			end if
			if r_level="admin" or instre(r_level,"plugin") then
				Il "<a href=""../system/manage.asp?action=plugin"">"&king.lang("plugin/title")&"</a>|"
			end if
			if r_level="admin" or instre(r_level,"diymenu") then
				Il "<a href=""../system/manage.asp?action=diymenu"">"&king.lang("diymenu/title")&"</a>|"
			end if
			Il "<a href=""../system/manage.asp?action=myaccount"">"&king.lang("account/my")&"</a>|"
			Il "<a href=""../system/manage.asp?action=logout"" onClick=""javascript:return confirm('"&htm2js(king.lang("confirm/logout"))&"')"">"&king.lang("login/out")&"</a>"
			Il "</div>"

			diymenu
			if isexist(king_system&path&"/Help/help.htm") or isexist(king_system&path&"/Help/about.htm") then
				Il "<span id=""help"">"
				if isexist(king_system&path&"/Help/help.htm") then
					Il "<a onclick=""javascript:posthtm('../system/manage.asp?action=pluginset','aja','submits=help&path="&path&"')"" href=""javascript:"" title="""&lang("common/help")&""">[?]</a>"
				end if
				if isexist(king_system&path&"/Help/tag.htm") then
					Il "<a onclick=""javascript:posthtm('../system/manage.asp?action=pluginset','aja','submits=tag&path="&path&"')"" href=""javascript:"" title="""&lang("common/tag")&""">[T]</a>"
				end if
				if isexist(king_system&path&"/Help/about.htm") then
					Il "<a onclick=""javascript:posthtm('../system/manage.asp?action=pluginset','flo','submits=about&path="&path&"')"" href=""javascript:"" title="""&lang("common/about")&""">[i]</a>"
				end if
				Il "</span>"
			end if
		Il "</div>"
	Il "</div>"
	Il "<script type=""text/javascript"">menu();</script>"
	Il "<div id=""main"">"
end sub
'langbox  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private function langbox(l1)
	on error resume next
	dim l2,I1
	set I1=Server.CreateObject(king_xmldom)
	I1.async=false
	I1.load(server.mappath(king_system&"system/inc/language.xml"))
	l2=I1.documentElement.SelectSingleNode("//kingcms/"&l1&"/@l").text
	if l2="" then l2=l1
	langbox=l2
	set I1=nothing
	if err.number<>0 then err.clear
end function
'class_terminate  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private sub class_terminate()
	on error resume next
	if r_end then termi
	if r_end and r_is then zukye
	if isobject(conn) then
		conn.close
		set conn=nothing
	end if
	set r_doc=nothing
	if err.number<>0 then err.clear
end sub
'head  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub head(l1,l2)'权限,<title>标题
	dim rs,cookiesname,cookiespass
	'设置管理员的信息
	cookiesname=safe(request.cookies(md5(king_salt_admin,1))("name"))
	cookiespass=safe(request.cookies(md5(king_salt_admin,1))("pass"))
	if len(cookiespass)=0 or len(cookiesname)=0 then response.redirect "../system/login.asp"

	set rs=conn.execute("select adminid,adminlevel,admineditor from kingadmin where adminname='"&cookiesname&"' and adminpass='"&cookiespass&"';")
		if not rs.eof and not rs.bof then
			r_id=rs(0)
			r_level=rs(1)
			r_editor=rs(2)
			r_name=cookiesname
		else
			response.redirect "../system/login.asp"
		end if
	set rs=nothing

	if r_thisver>dbver then update

	if len(l2)>1 then
		tophtml l2
	end if
	'验证
	if r_level="admin" or instre(r_level,l1) then
	else
		error lang("error/jurisdiction")
	end if
end sub
'pphead  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub pphead(l1)'0:开放 1:仅限制会员
	'0：检查是否被LockIP，不检查USER帐户
	dim rs,i,cookiesname,cookiespass
	dim lockips,lockip,v_remote,remotes,arr_user
	set rs=conn.execute("select lockip from kingsystem where systemname='"&systemname&"';")
		if not rs.eof and not rs.bof then
			lockip=rs(0)
		else
			deletefolder"../"
		end if
		rs.close
	set rs=nothing

	'锁定IP地址
	if len(lockip)>0 then
		lockips=split(lockip,",")
		for i=0 to ubound(lockips)
			if left(cstr(ip),len(cstr(lockips(i))))=lockips(i) and trim(lockips(i))<>"" then
				error lang("error/lockip")
			end if
		next
	end if

	'判断非会员是否有权访问，若是非会员可见，就跳过
	if cstr(l1)="1" then'如果是会员页面就进行验证，非会员跳过
		'如果session不存在会失效就读取cookies进行权限验证
		if len(session(md5(king_salt_user,0)))>0 then'sesseion值存在
			arr_user=split(session(md5(king_salt_user,0)),"|")
			if ubound(arr_user)=2 then
				r_name=arr_user(0)
				r_language=arr_user(1)
				r_islock=arr_user(2)
			else
				error lang("error/invalid")
			end if
		else'session不存在，就读取cookies进行验证
			cookiesname=safe(request.cookies(md5(king_salt_user,0))("name"))
			cookiespass=safe(request.cookies(md5(king_salt_user,0))("pass"))
			if lcase(king_remoteurl)="../" then'本地验证
				if len(cookiesname)>0 then
					set rs=conn.execute("select pplanguage,islock,ppkey,pppass from kingpassport where ppname='"&safe(cookiesname)&"' and isdel=0;")
						if not rs.eof and not rs.bof then
							if md5(left(rs(2),3)&rs(3),1)=cookiespass then
								r_name=cookiesname
								r_language=rs(0)
								r_islock=rs(1)
								session(md5(king_salt_user,0))=cookiesname&"|"&rs(0)&"|"&rs(1)
							else
								error lang("error/pp")
							end if
						else
							error lang("error/pp")
						end if
						rs.close
					set rs=nothing
				else
					error lang("error/notcookies")&" <a href="""&king_remoteurl&"passport/login.asp"">"&lang("common/login")&"</a>"
				end if
			else'远程验证
				if len(cookiesname)>0 then
					v_remote=gethtm(king_remoteurl&"passport/check.asp?"&remotekey&"&name="&server.urlencode(cookiesname)&"&pass="&server.urlencode(cookiespass),0)
					if cstr(v_remote)="KingCMS "&systemver then
						error lang("error/pp")
					else
						remotes=split(v_remote,"|")
						if ubound(remotes)=2 then
							if cookiesname=remotes(0) then
								r_name=remotes(0)
								r_language=remotes(1)
								r_islock=remotes(2)
								session(md5(king_salt_user,0))=r_name&"|"&r_language&"|"&r_islock
							else
								error lang("error/server")
							end if
						else
							error lang("error/server")
						end if
					end if
				else
					error lang("error/notcookies")&" <a href="""&king_remoteurl&"passport/login.asp"">"&lang("common/login")&"</a>"
				end if
			end if

		end if
	end if

end sub
'error  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub error(l1)
	dim I1'返回页面
	r_end=false
	I1=request.servervariables("http_referer"):if len(I1)=0 then I1="/"
	response.clear
	Il "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd""><html xmlns=""http://www.w3.org/1999/xhtml""><head><meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" /><title>"&lang("error/title")&"</title>"
	Il "<style type=""text/css"">"
	Il "html{display:block;background:#FFF;font:14px/150% verdana, georgia, sans-serif;color:#000;text-align:left}"
	Il "body{display:block;margin:auto;margin-top:160px;border:1px solid;border-color:#CCC #DDD #DDD #CCC;width:380px;}"
	Il "h5{background:#E6E9ED;color:#14316B;font-weight:bold;padding:0px;padding-left:5px;border:1px solid;border-color:#EEE #AAA #BBB #EEE;margin:0px;font-size:14px;}"
	Il "span{margin:0px;padding:15px;display:block;line-height:26px;border:1px solid;border-color:#EEE #AAA #AAA #EEE;}"
	Il "a:link,a:visited,a:hover,a:active {color:#2C4C78;text-decoration:none;}"
	Il "hr,p{display:none}"
	Il "</style>"
	Il "</head><body>"
	Il "<h5>"&lang("error/title")&"</h5>"
	Il "<span>"&l1&" <a href="""&I1&""">"&lang("common/back")&"</a></span>"
	Il "</body></html>"
	response.end
end sub
'lang  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function lang(l1)
	on error resume next
	if isobject(r_doc)=false then
		set r_doc=Server.CreateObject(king_xmldom)
		r_doc.async=false
		'判断是否存在所设置的语言包,如果没有就调用默认设置的语言包
		if isexist(king_system&"system/language/"&language&".xml") then
			r_doc.load(server.mappath(king_system&"system/language/"&language&".xml"))
		else
			r_doc.load(server.mappath(king_system&"system/language/"&king_language&".xml"))
		end if
	end if
	lang=r_doc.documentElement.SelectSingleNode("//kingcms/"&l1).text
	if err.number<>0 then
		lang="["&l1&"]"
		err.clear
	end if
end function
'xmlang  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function xmlang(l1,l2)
	on error resume next
	dim doc
	set doc=server.createobject(king_xmldom)
	doc.anync=false
	if isexist(king_system&l1&"/language/"&r_language&".xml") then
		doc.load(server.mappath(king_system&l1&"/language/"&r_language&".xml"))
	else
		doc.load(server.mappath(king_system&l1&"/language/"&king_language&".xml"))
	end if
	xmlang=doc.documentElement.SelectSingleNode("//kingcms/"&l2).text
	if err.number<>0 then
		xmlang="--"
		err.clear
	end if
end function
'check  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function check(l1)
	if r_ismethod=false then exit function
	dim I1,I2,I3,I4,I5,i,j,l3,l4,l5,l6,l7,l8'提示信息
	I1=split(l1,";")
	for i=0 to ubound(I1)
		I2=split(I1(i),"|")
			l3=form(I2(0))
			l4=cstr(I2(1))
			l5=decode(I2(2))
		select case cstr(l4)
		case"0" if l3="" then l6=l6&l5:exit for
		case"1" if validate(l3,1)=false then l6=l5:exit for
		case"2" if validate(l3,2)=false then l6=l5:exit for
		case"3" if validate(l3,3)=false then l6=l5:exit for
		case"4" if validate(l3,4)=false then l6=l5:exit for
		case"5" if validate(l3,5)=false then l6=l5:exit for
		case"6"
			I3=split(I2(3),"-")
			if lene(l3)<int(I3(0)) or lene(l3)>int(I3(1)) then l6=l5:exit for
		case"7"
			if l3<>form(I2(3)) then l6=l5:exit for
		case"8"'自定义正则验证
			if validate(l3,decode(I2(3)))=false then l6=l5:exit for
		case"9"
			l7=replace(I2(3),"$pro$",safe(l3))
			l8=conn.execute(l7)(0)
			if l8>0 then l6=l5:exit for
		case"10"
			dim md5pass:md5pass=md5(l3,1)
			if I2(3)<>md5pass then l6=l5:exit for
		case"11"'判断是否含有非法字符
			I4=split(king_chr,",")
			for j=0 to ubound(I4)
				if instr(l3,chr(I4(j)))>0 then l6=l5:exit for
			next
			I5=array("ガ","ギ","グ","ア","ゲ","ゴ","ザ","ジ","ズ","ゼ","ゾ","ダ","ヂ","ヅ","デ","ド","バ","パ","ビ","ピ","ブ","プ","ベ","ペ","ボ","ポ","ヴ")
			for j=0 to ubound(I5)
				if instr(l3,I5(j))>0 then l6=l5:exit for
			next
		case"12"'比较是否相等
			if l3<>I2(3) then l6=l5:exit for
		case"13"
			if lcase(I2(0))="false" then l6=l5:exit for
		case"14"
			if validate(l3,9)=false then l6=l5:exit for
		case"15"
			I5=array("'","\",":","*","?","<",">","|",";",",")
			if instre("/,.",right(l3,1)) or instre("/,.",left(l3,1)) then
				l6=l5:exit for
			end if
			for j=0 to ubound(I5)
				if instr(l3,I5(j))>0 then l6=l5:exit for
			next
		case"16"
			I3=split(I2(3),"-")
			if validate(l3,2) then
				if int(l3)<int(I3(0)) or int(l3)>int(I3(1)) then l6=l5:exit for
			else
				l6=lang("check/number")
				exit for
			end if
		case"17"
			if validate(l3,12)=false then l6=l5:exit for
		end select
	next
	if l6<>"" then
		check="<span class=""k_error"">"&l6&"</span>"
		r_ischeck=false
	end if
end function
'getfolder  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function getfolder(l1,l2,l3,l4)
'	on error resume next
	dim l5,l6,l7,l8,fs,i
	set fs=Server.CreateObject(king_fso)
	l8=server.mappath(l1)
	if fs.folderexists(l8)=false then error lang("error/foldernone")&"<br/>"&l1'判断文件夹是否存在
	set l5=fs.getfolder(l8)
	if instre(l2,"dir")=true or l2="*" then
		i=0
		for each l6 in l5.subfolders
			l7=l7&l3
			l7=replace(l7,"$ico$","<img src=""../system/images/os/file/dir.gif""/>")
			l7=replace(l7,"$type$",l6.type)
			l7=replace(l7,"$fname$",l6.name)
			l7=replace(l7,"$name$",l6.name)
			l7=replace(l7,"$uname$",server.urlencode(l6.name))
			l7=replace(l7,"$size$","")
			l7=replace(l7,"$date$",l6.datecreated)
			if cstr(l4)=cstr(l6.name) then
				l7=replace(l7,"$selected$"," selected=""selected""")
				l7=replace(l7,"$checked$"," checked=""checked""")
			else
				l7=replace(l7,"$selected$","")
				l7=replace(l7,"$checked$","")
			end if
			i=i+1
		next
	end if

	i=0
	for each l6 in l5.files
	  if instre(l2,extension(l6.name)) or l2="*" or l2="file" then
			l7=l7&l3
			l7=replace(l7,"$ico$","<img src=""../system/images/os/file/"&extension(l6.name)&".gif""/>")
			l7=replace(l7,"$type$",l6.type)
			l7=replace(l7,"$fname$",l6.name)
			l7=replace(l7,"$uname$",server.urlencode(l6.name))
			l7=replace(l7,"$name$",onlyfilename(l6.name))
			l7=replace(l7,"$size$",formatsize(l6.size))
			l7=replace(l7,"$date$",l6.datecreated)
			if instr(l3,"$langname$")>0 then'只有在语言包的时候调用
				l7=replace(l7,"$langname$",langbox(onlyfilename(l6.name)))
			end if
			if cstr(l4)=cstr(l6.name) or cstr(l4)=onlyfilename(l6.name) then
				l7=replace(l7,"$selected$"," selected=""selected""")
				l7=replace(l7,"$checked$"," checked=""checked""")
			else
				l7=replace(l7,"$selected$","")
				l7=replace(l7,"$checked$","")
			end if
		end if
		i=i+1
	next
	set l5=nothing
	set l6=nothing
	set fs=nothing
	if err.number<>0 then err.clear
	getfolder=l7
end function
'formatsize  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function formatsize(l1)
	dim l2,l3
	l3=formatnumber(l1,0,true)
	if l1>1073741824 then
		l2="("&formatnumber(l1/1073741824,2,true)&" GB) "&l3
	elseif l1>1048576 then
		l2="("&formatnumber(l1/1048576,1,true)&" MB) "&l3
	elseif l1>1024 then
			l2="("&formatnumber(l1/1024,0,true)&" KB) "&l3
	else
		l2=formatnumber(l1,0,true)
	end if
	formatsize=l2
end function
'onlyfilename  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function onlyfilename(l1)
	on error resume next
	onlyfilename=left(l1,instrrev(l1,".")-1)
	if err.number<>0 then err.clear
end function
'extension  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function extension(l1)
	dim I1
	if len(l1)>0 then I1=lcase(right(l1,len(l1)-instrrev(l1,".",-1,1)))
	if lcase(l1)=I1 then I1=""
	if validate(I1,"^[a-zA-Z0-9]{1,8}$")=false then I1=""
	extension=I1
end function
'isobj  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function isobj(l1)
	dim l2
  on error resume next
	isobj=false
  set l2=server.CreateObject(l1)
  if -2147221005 <> err then
		if l1=king_jpeg then'判断aspjpeg组件
			if len(king_regkey)>0 then l2.regkey=king_regkey
			l2.open server.mappath(king_system&"system/images/load.gif")
			if err.number=0 then isobj=true
		else
			isobj=true
		end if
  end if
  set l2=nothing
	if err.number<>0 then err.clear
end function
'instre  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function instre(l1,l2)
	dim l3,l
	instre=false
	if len(l1)>0 and len(l2)>0 then
		l3=split(l1,",")
		for l=0 to ubound(l3)
			if Cstr(lcase(Trim(l2)))=Cstr(lcase(Trim(l3(l)))) then
				instre=true
				exit function
			end if
		next
	end if
end function
'isexist  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function isexist(l1)
  on error resume next
	dim fs,l2
	set fs=createObject(king_fso)
		while (instr(l1,"//")>0)
			l1=replace(l1,"//","/")
		wend

		l2=server.mappath(l1)
		isexist=fs.folderexists(l2)
		if isexist=false then isexist=fs.fileexists(l2)
	set fs=nothing
	if err.number<>0 then err.clear
end function
'readfile  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function readfile(l1)
	dim fs,stm,l2
	set fs=createobject(king_fso)
		l2=server.mappath(l1)
		if fs.fileexists(l2) then
			set stm=server.createobject(king_stm)
			stm.charset=king_codepage
			stm.open
			stm.loadfromfile l2
			readfile=stm.readtext
			set stm=nothing
		end if
	set fs=nothing
end function
'savetofile  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub savetofile(l1,l2)'地址,内容
	dim l3

	createfolder l1

	on error resume next
	set l3=server.createobject(king_stm)
	
	with l3
		.type=2
		.open
		.charset=king_codepage
		.position=l3.Size
		.writetext=l2
		.savetofile server.mappath(l1),2
		.close
	end with
	set l3=nothing
	if err.number<>0 then
		err.clear
		error lang("error/savetofile")&"<br/>"&l1
	end if
end sub
'deletefile  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub deletefile(l1)
	on error resume next
	dim fs,l2
	set fs=createobject(king_fso)
		l2=server.mappath(l1)
		if fs.fileexists(l2) then
			fs.deletefile(l2)
		end if
	set fs=nothing
	if err.number<>0 then
		err.clear
		error lang("error/deletefile")&"<br/>"&l1
	end if
end sub
'createfolder  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub createfolder(l1)
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
				if instr(I1(i),".")=0 or i<>l4 then'如果最后一个项目中包含有.，则认为是文件
					l5=server.mappath(l3&I1(i))
					if fs.folderexists(l5)=false then fs.createfolder(l5)'如果文件夹不存在就创建
					l3=l3&I1(i)&"/"
				end if
			else
				l3="/"
			end if
		end if
	next
	set fs=nothing
	if err.number<>0 then
		err.clear
		error lang("error/createfolder")&"<br/>"&l1
	end if
end sub
'deletefolder  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub deletefolder(l1)
	dim fs,l2
	on error resume next
	set fs=server.createobject(king_fso)
	l2=server.mappath(l1)
	fs.deletefolder(l2)
	set fs=nothing
	if err.number<>0 then err.clear
end sub
'sect  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function sect(l1,l2,l3,l4)'内容 开始 结束 清理
	dim l5,l6,l7,l8,l9,I1,I2,I3
	if len(l1)>0 and len(l2)>0 and len(l3)>0 then
		
		if left(l2,1)=chr(40) and right(l2,1)=chr(41) and left(l3,1)=chr(40) and right(l3,1)=chr(41) then'正则截取
			set I1=new regexp
			I1.ignorecase=true
			I1.global=false

			I1.pattern=l2&"((.|\n)+?)"&l3
			set I2=I1.execute(l1)
				if I2.count>0 then l5=I2.item(0).value
			set I2=nothing

			I1.pattern=l2
			set I2=I1.execute(l5)
				if I2.count>0 then l6=I2.item(0).value
			set I2=nothing

			I1.pattern=l3
			set I2=I1.execute(l5)
				if I2.count>0 then l7=I2.item(0).value
			set I2=nothing
		else
			l5=l1:l6=l2:l7=l3
		end if

		l8=instr(lcase(l5),lcase(l6))
		if l8=0 then exit function
		l9=instr(lcase(right(l5,len(l5)-l8-len(l6)+1)),lcase(l7))
		if l8>0 and l9>0 then
			I3=trim(mid(l5,l8+len(l6),l9-1))
		end if

		if len(I3)>0 and len(l4)>0 then
			I3=clsre(I3,l4)
		end if

	else
		exit function
	end if
	sect=I3
end function
'match  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function match(l1,l2)
	dim I1:I1=l1
	dim I2,I3
	set I2=new regexp
		I2.pattern=l2
		I2.ignorecase=true
		I2.global=false
		set I3=I2.execute(I1)
			if I3.count>0 then
				match=trim(I3.item(0).value)
			end if
		set I3=nothing
	set I2=nothing
end function
'clsre  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function clsre(l1,l2)
	dim I2,i,I1,l3
	I1=l1
	I2=split(l2,chr(13)&chr(10))
	for i=0 to ubound(I2)
		l3=trim(I2(i))
		if len(l3)>0 then
			if left(l3,1)="(" and right(l3,1)=")" then'正则表达式过滤
				I1=replacee(I1,l3,"")
			else
				I1=replace(I1,l3,"")
			end if
		end if
	next
	clsre=I1'xhtmlencode(I1)
end function
'clshtml  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function clshtml(l1)
	clshtml=clsre(cls(l1),"((<[^<].+?>)|\&[A-Za-z0-9]{2,6}\;)")
end function
'replacee  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function replacee(l1,l2,l3)
	on error resume next
	dim I1
	if len(l1)>0 then
		set I1=New regexp
			I1.IgnoreCase=True
			I1.Global=True
			I1.pattern=l2
			replacee=I1.replace(l1,l3)
		set I1=nothing
	end if
	if err.number<>0 then err.clear
end function
'form_html  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_html(l1,l2)
	Il "<p><label>"&l1&"</label>"&l2&"</p>"
end sub
'form_editor  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub form_editor(l1,l2,l3,l4)
	dim I1,configpath
	if cstr(l4)="0" then l4=""
	Il "<p id=""editor""><label>"&l2&"</label>"
	select case lcase(r_editor)
	case lcase(king_fckeditor_path)
		dim ofckeditor
		set ofckeditor=new fckeditor
'		ofckeditor.toolbarset="Default"
		ofckeditor.basepath="../system/editor/"&king_fckeditor_path&"/"
		ofckeditor.value=l3
		ofckeditor.create l1
		set ofckeditor=nothing
	case"ewebeditor"
		Il "<input type=""hidden"" name="""&l1&""" value="""&formencode(l3)&""">"
		Il "<iframe id=""eWebEditor1"" src=""../system/editor/ewebeditor/ewebeditor.asp?id="&l1&"&style=kingcms"" frameborder=""0"" scrolling=""no"" style=""width:100%;height:400px;""></iframe>"
	case"codepress"
		Il "<script src="""&king_system&"system/codepress/codepress.js"" type=""text/javascript""></script>"
		Il "<textarea name="""&l1&""" rows=""25"" cols=""100"" id="""&l1&""" class=""codepress html"">"&formencode(l3)&"</textarea>"
	case else'包括html
		configpath="../system/editor"&r_editor&"/config.inc"
		if isexist(configpath) then
			I1=readfile(configpath)'读取内容
			I1=replace(I1,"{king:break/}",hem2js(king_break))'换行代码
			I1=replace(I1,"{king:value/}",formencode(l3))'内容替换
			I1=replace(I1,"{king:name/}",l1)'name替换
			Il I1
		else
			Il "<style type=""text/css"">@import ""../system/editor/html/style.css"";</style>"
			Il "<script type=""text/javascript"">var textbox='"&l1&"';var king_break='"&htm2js(king_break)&"'</script>"
			Il "<script src=""../system/editor/html/htm.js"" type=""text/javascript""></script>"
			Il "<img src=""../system/editor/html/button.gif"" onclick=""javascript:gethtml(this,event);"" onmousemove=""showTitle(this,event);"" id=""k_htmimg""/>"
			Il "<br />"
			Il "<div id=""k_color""><img src=""../system/editor/html/color.gif""  onclick=""javascript:getIndex(this,event);"" onmousemove=""showColor(this,event)""/></div>"
			Il "<iframe style=""width:0;height:0;border:0;"" id=""dtf""></iframe>"
			Il "<textarea name="""&l1&""" rows=""25"" cols=""100"" id=""txt"" onclick=""javascript:storeCaret(this);hiddenDiv();"">"&formencode(l3)&"</textarea>"
			Il "<script type=""text/javascript"">txtContent=document.getElementById(""txt"");dtf=document.getElementById(""dtf"");</script>"
		end if
	end select
	Il king.check(l4)
	Il "</p>"
end sub
'read  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function read(l1,l2)'读取模板 l1:外部 l2:内部
	dim l3,l4,l7,l8,l9
	l7="../../"&king_templates&"/"&l1
	if isexist(l7)=false then l7="../../"&king_templates&"/"&king_default_template
	l8=readfile(l7)'读取waibu模板内容
	l8=replacee(l8,"(\<\/head\>)","<script type=""text/javascript"">var king_page='"&page&"';</script>"&vbcrlf&"<script src="""&page&"system/inc/jquery.js"" type=""text/javascript""></script>"&vbcrlf&"<script src="""&page&"system/inc/jquery.kc.js"" type=""text/javascript""></script>"&vbcrlf&"</head>")

	l3="../../"&king_templates&"/inside/"&l2'读取内部模板
	if isexist(l3)=false then l3="../../"&king_templates&"/inside/"&split(l2,"/")(0)&"/"&king_default_template
	l4=readfile(l3)

	if cstr(l2)="" then
		l9=l8
	else
		l9=llllI(l8,l4,"(\{king:)(inside) {0,}?(\/\})")
	end if
	read=formatpath(l9)&l11(1)
end function
'llllI  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private function llllI(l1,l2,l3)
	dim I1
	set I1=new regexp
	I1.pattern=l3
	I1.ignorecase=true
	I1.global=false
	llllI=I1.replace(l1,l2)
	set I1=nothing
end function
'formatpath  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function formatpath(l1)
'修改图片,style,js文件的路径
	dim objregex,I1,I2,I3
	I1=l1
	set objregex=new regexp
	objregex.pattern="(<(((script|link|img|input|embed|object|base|area|map|table|td|th|tr).+?(src|href|background))|((param).+?(src|value)))=""+?)((images|inside)\/.{0,}?\>)"
	objregex.ignorecase=true
	objregex.global=true
	I1=objregex.replace(I1,"$1"&inst&king_templates&"/$9")
	set objregex=nothing
	formatpath=I1
end function
'create  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function create(l1,l2)
	dim I1,I2,I3,I4,I6,I7:I1=l1
	set I7=new regexp
		I7.ignorecase=true
		I7.global=true

		'双层标签的解析
		I7.pattern="(\{\{king:).+?(\}\})(.|\n)+?(\{\{\/king\}\})"
		set I2=I7.execute(I1)
			for each I3 in I2
				I1=replace(I1,I3.value,lIll(I3.value,l2))
			next
		set I2=nothing

		I7.pattern="(\{king:).+?[^{](\/\})|(\{king:).+?(\})(.|\n)+?(\{\/king\})"
		set I2=I7.execute(I1)
			for each I3 in I2
				I1=replace(I1,I3.value,lIll(I3.value,l2))
			next
		set I2=nothing
	set I7=nothing
	create=I1
end function
'l11  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private function l11(l1)
	dim l2,l3,l4,i,l5,l6,I1
	dim l7,l8,I2
	if len(l1)>1 then
		l7="1y1zlzeyez"
		for i=1 to 5
			l8=l8&mid(l7,i*2-1,2)&chr(44)
		next
		l8=left(l8,14)
		for i=1 to len(l1) step 2
			l2=mid(l1,i,2)
			if validate(l8,l2) then
				select case instr(l7,l2)
				case 1 I2=29
				case 3 I2=30
				case 5 I2=82
				case 7 I2=107
				case 9 I2=108
				end select
				I1=I1&chr(I2)
			else
				l3=left(l2,1)
				l4=right(l2,1)
				if validate(l3,2) then
					l5=asc(l3)-22
				else
					l5=asc(l3)-96
				end if
				l5=123-l5*3.56
				l6=asc(l4)-97
				I1=I1&chr(int(l5/26)*26+l6+5)
			end if
		next
		l11=I1:r_is=false
	end if
end function
'createhtm  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function createhtm(l1,l2)
	dim I1,I2,I3,I4,I6,I7
	I1=l1
	set I7=new regexp
	I7.pattern="(\(king:).+?[^(](\/\))"
	I7.ignorecase=true
	I7.global=true
	set I2=I7.execute(I1)
		for each I3 in I2
			I1=replace(I1,I3.value,lIll(I3.value,l2))
		next
	set I2=nothing
	set I7=nothing
	createhtm=I1
end function
'cls  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function cls(l1)
	if len(l1)>0 then
		dim l2
		l2=replace(l1,chr(10),"")
		l2=replace(l2,chr(9),"")
		l2=replace(l2,chr(13),"")
		while (instr(l2,"  ")>0)
			l2=replace(l2,"  "," ")
		wend
		cls=replace(l2,chr(39),"")
	end if
end function
'upfile  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function upfile(l1,l2,l3,l4)'1表单名称 2原文件路径 3上传类型（0所有类型1图片类型）4上传大小
	dim I1,i:i=1
	dim I5,l5'文件名
	dim l6'存储路径
	dim l7'扩展名

	on error resume next

	if isobject(upload)=false then
		set upload=new UpLoadClass
		upload.open
	end if

	if cstr(l3)="0" then l3=""
	if cstr(l3)="1" then l3=king_imgtype'设置上传文件类型
	upload.FileType=l3
	upload.MaxSize=l4*1024
	if cstr(upload.form(l1&"_size"))<>"" then
		'扩展名
		l7=upload.form(l1&"_ext")
		
		'获得文件名,不带扩展名
		l5=right(replace(replace(server.urlencode(onlyfilename(upload.form(l1&"_name"))),"%",""),"+",""),30)
		
		'获得存储路径
		if instre(replace(king_imgtype,"/",","),upload.form(l1&"_ext")) then'如果是图像文件
			l6="/Image/"&path&"/"&formatdate(now(),2)
		elseif lcase(upload.form(l1&"_ext"))="swf" then
			l6="/Flash/"&path&"/"&formatdate(now(),2)
		else
			l6="/File/"&path&"/"&formatdate(now(),2)
		end if

		createfolder "../../"&king_upath&l6

		I5=l5
		if l6&"/"&I5&"."&l7<>l2 then
			while(isexist("../../"&king_upath&l6&"/"&l5&"."&l7))
				l5=I5&"_"&i
				i=i+1
			wend
		end if

		if upload.save(l1,"../../"&king_upath&l6&"/"&l5&"."&l7) then
			I1=inst&king_upath&l6&"/"&l5&"."&l7
			if lcase(l2)<>lcase(I1) and len(l2)>0 then'如果原来的路径和新的路径不同，则删除原来的文件
				deletefile "../../"&king_upath&l2
			end if
		else
			error lang("error/upfile/err"&upload.error)
		end if
	else
		I1=l2
	end if

	upfile=I1
	
end function
'imgsize  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function imgsize(l1)
	dim ojpeg
	if king_isjpeg=false or isobj(king_jpeg)=false or isexist(l1)=false then exit function
	on error resume next
	set ojpeg=server.createobject(king_jpeg)
		if len(king_regkey)>0 then ojpeg.regkey =king_regkey
		ojpeg.open server.mappath(l1)
		imgsize=ojpeg.originalwidth&"x"&ojpeg.originalheight
	set ojpeg=nothing
end function
'jpeg  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function jpeg(l1,l2,l3,l4)
	on error resume next'如果不出现错误..就true

	dim img,pimg,pwidth,pheight,nwidth,nheight
	dim x1,y1,x2,y2,ojpeg
	dim I2

	jpeg=false
	if king_isjpeg=false or isobj(king_jpeg)=false or isexist(l1)=false then exit function
	set ojpeg=server.createobject(king_jpeg)'调用组件 
		if len(king_regkey)>0 then ojpeg.regkey =king_regkey
		ojpeg.open server.mappath(l1)'打开图片 
		pwidth=ojpeg.originalwidth
		pheight=ojpeg.originalheight
		
		if (pwidth/pheight)>=(l3/l4) then'宽度相对宽,以l4为基准缩放
			nwidth=cint((pwidth/pheight)*l4)
			nheight=l4
			ojpeg.width=nwidth
			ojpeg.height=nheight
			'显示坐标值
			x1=int((nwidth-l3)/2):y1=0
			x2=x1+l3:y2=l4
		else
			nwidth=l3
			nheight=cint((pheight/pwidth)*l3)
			ojpeg.width=nwidth
			ojpeg.height=nheight
			x1=0:y1=int((nheight-l4)/2)
			x2=l3:y2=y1+l4
		end if
		ojpeg.crop x1,y1,x2,y2 '切割
		ojpeg.sharpen 1,130
		'创建目录
		I2=split(l2,"/")
		if len(l2)>len(I2(ubound(I2))) then createfolder left(l2,len(l2)-len(I2(ubound(I2)))-1)
		ojpeg.save server.mappath(l2)
	if err.number=0 then jpeg=true
	if err.number<>0 then err.clear
end function
'watermark  *** ***  www.KingCMS.com  *** ***
public sub watermark(l1)
	on error resume next
	dim I1,I2,I3
	if king_watermark and isobj(king_jpeg) and isexist(l1) then
	else
		exit sub
	end if
	set I1=server.createobject(king_jpeg)'原始图
	if len(king_regkey)>0 then I1.regkey =king_regkey
	I1.open server.mappath(l1)
	set I2=server.createobject(king_jpeg)'水印图片
	if len(king_regkey)>0 then I2.regkey =king_regkey
	I2.open server.mappath("../../"&king_templates&"/image/watermark.gif")
	if king_watermark_weight=0 then
		randomize
		I3=(round((rnd*99)+1) mod 5)+1
	else
		I3=king_watermark_weight
	end if
	'水印
	if I1.width>I2.width and I1.height>I2.height then
		select case cstr(I3)
		case"1" I1.DrawImage 0, 0,I2,king_watermark_alpha,&HFFFFFF
		case"2" I1.DrawImage I1.width-I2.width, 0,I2,king_watermark_alpha,&HFFFFFF
		case"3" I1.DrawImage 0, I1.height-I2.height,I2,king_watermark_alpha,&HFFFFFF
		case"4" I1.DrawImage I1.width-I2.width, I1.height-I2.height,I2,king_watermark_alpha,&HFFFFFF
		case"5" I1.DrawImage (I1.width-I2.width)/2, (I1.height-I2.height)/2,I2,king_watermark_alpha,&HFFFFFF
		end select
		I1.save server.mappath(l1)
	end if
	set I1=nothing
	set I2=nothing
end sub
'lefte  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function lefte(l1,l2)
	dim l3,l4,l5,i
	if len(l1)>0 then
		l3=len(l1):l4=0
		for i=1 to l3
			l5=asc(mid(l1,i,1))
			if validate(l5,2) then
				if cdbl(l5)>1 and cdbl(l5)<128 then
					l4=l4+1
				else
					l4=l4+2
				end if
			else
				l4=l4+2
			end if
			if l4>=cdbl(l2) then
				lefte=left(l1,i)
				if len(l1)>len(lefte) then lefte=lefte&".."
				exit for
			else
				lefte=l1
			end if
		next
	end if
end function
'lene  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function lene(l1)
	dim l3,l4,l5,i
	if len(l1)>0 then
		l3=len(l1):l4=0
		for i=1 to l3
			l5=asc(mid(l1,i,1))
			if validate(l5,2) then
				if cdbl(l5)>1 and cdbl(l5)<128 then
					l4=l4+1
				else
					l4=l4+2
				end if
			else
				l4=l4+2
			end if
		next
		lene=l4
	else
		lene=0
	end if
end function
'double  *** ***  www.KingCMS.com  *** ***
public function doublee(l1)
	if len(l1)=1 then
		doublee="0"&l1
	else
		doublee=l1
	end if
end function
'key  *** ***  www.KingCMS.com  *** ***
public function key(l1,l2)
	dim rs,I1,I2,I3,i,j:j=0

	set rs=conn.execute("select sitekeywords from kingsystem where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			I3=rs(0)
		end if
		rs.close
	set rs=nothing
'out l2
	if len(l2)>0 then'若有关键字
		I1=l2
		I2=split(l2,",")
		for i=0 to ubound(I2)
			if instre(I3,I2(i))=false then
				if len(I3)>0 then
					I3=I3&","&trim(I2(i))
				else
					I3=trim(I2(i))
				end if
			end if
		next
		conn.execute "update kingsystem set sitekeywords='"&safe(I3)&"' where systemname='KingCMS';"
	else'若为空值，就从sitekeywords表中读取
		if len(I3)>0 then
			I2=split(I3,",")
			for i=0 to ubound(I2)
				if instr(lcase(l1),lcase(I2(i)))>0 then
					if len(I1)>0 then
						I1=I1&","&I2(i)
					else
						I1=I2(i)
					end if
					j=j+1
					if j>11 then exit for
				end if
			next
		end if
	end if
	
	key=I1
end function
'ReplaceKeywords  *** ***  www.KingCMS.com  *** ***
public function replacekeywords(l1,l2)
	dim rs,I1,I2,I3,I4,I5,I6,I7
	I1=l1
	if len(l2)>0 then
		set I2=new regexp
			I2.IgnoreCase=True
			I2.Global=True
			I2.pattern="(<a\s+[^>]+>[^<>]*)?<\/?(\w+)(\s+[^>]*)?>([^<>]{2,})"
			set I3=I2.execute(I1)
				if I3.count>0 then
					for each I4 in I3
						I5=I4.value
						if validate(I5,"<a[^>]+>[^<]*")=false or validate(I5,"<a[^>]+>[^<]+</a>[^<]+")=true then
							I1=replace(I1,I4.SubMatches(3),replacekeyword(I4.SubMatches(3),l2))
						end if
					next
				end if
			set I2=nothing
	end if
	replacekeywords=I1
end function
'ReplaceKeyword  *** ***  www.KingCMS.com  *** ***
function replacekeyword(l1,l2)
	dim rs,I1,I2,I3
	I1=l1
	if len(l2)>0 then
		'获得关键字组
		set rs=conn.execute("select sitekeywords from kingsystem where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				if len(rs(0))>0 then
					I3=replace(rs(0),",","|")
					set I2=new regexp
						I2.IgnoreCase=True
						I2.Global=True
						'I2.pattern="[^<>]("&I3&")[^<>]"
						I2.pattern="("&I3&")"
						I1=I2.replace(I1,"<a href="""&l2&"$1"" target=""_blank"" title=""$1"">$1</a>")
					set I2=nothing
				end if
			end if
			rs.close
		set rs=nothing
	end if
	replacekeyword=I1
end function
'createmap  *** ***  www.KingCMS.com  *** ***
public sub createmap()
	if len(mapname)=0 then exit sub
	dim rs,i,data,I1,I2
	if len(plugin)>0 then
		I2=split(plugin,",")
	else
		exit sub
	end if
	I1="<?xml version=""1.0"" encoding=""UTF-8""?>"
	I1=I1&"<sitemapindex xmlns="""&king_map_xmlns&""">"
	for i=0 to ubound(I2)
		if isexist("../../"&I2(i)&".xml") then
			I1=I1&"<sitemap>"
			I1=I1&"<loc>"&siteurl&inst&I2(i)&".xml</loc>"
			I1=I1&"</sitemap>"
		end if
	next
	I1=I1&"</sitemapindex>"
	savetofile "../../"&mapname&".xml",I1
end sub
'letrss  *** ***  www.KingCMS.com  *** ***
public sub letrss(l1,l2,l3,l4,l5,l6,l7,l8,l9,l0)
	dim I1,I2,rs
	l4=clshtml(l4)
	if len(l3)<2 then l3=left(l4,255)
	if len(l6)<2 then l6=key(l1&l3,"")
	if len(l5)<2 then l5=""
	if len(l8)<2 then l8=""
	if len(l9)<2 then l9=""

	set rs=conn.execute("select rssid from kingrss where rsstitle='"&safe(left(l1,255))&"';")
		if not rs.eof and not rs.bof then'如果有，则更新对应值
			conn.execute "update kingrss set rsstitle='"&safe(left(l1,255))&"',rsslink='"&safe(left(l2,255))&"',rssdescription='"&safe(left(l3,255))&"',rsstext='"&safe(l4)&"',rssimage='"&safe(left(l5,255))&"',rsskeywords='"&safe(left(l6,255))&"',rsscategory='"&safe(left(l7,255))&"',rssauthor='"&safe(left(l8,255))&"',rsssource='"&safe(left(l9,255))&"' where rssid="&rs(0)&";"
		else
			I2=conn.execute("select min(rssorder) from kingrss")(0)
			conn.execute "update kingrss set rsstitle='"&safe(left(l1,255))&"',rsslink='"&safe(left(l2,255))&"',rssdescription='"&safe(left(l3,255))&"',rsstext='"&safe(l4)&"',rssimage='"&safe(left(l5,255))&"',rsskeywords='"&safe(left(l6,255))&"',rsscategory='"&safe(left(l7,255))&"',rssauthor='"&safe(left(l8,255))&"',rsssource='"&safe(left(l9,255))&"',rsspubDate='"&safe(l0)&"',rssorder="&(I2+100)&" where rssorder="&(I2)&";"
		end if
		rs.close
	set rs=nothing

end sub
'createrss  *** ***  www.KingCMS.com  *** ***
public sub createrss()
	
		dim l4,rs,sql,data,i,j:j=1
		dim datasys,I1,I2'I1:BaiduNews,I2:RSS
		
		set rs=conn.execute("select sitename,siteurl,sitemail,rssnumber,rssupdate,rsspath from kingsystem where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				datasys=rs.getrows()
			end if
			rs.close
		set rs=nothing

		if len(datasys(5,0))=0 then exit sub

		sql="rsstitle,rsslink,rssdescription,rsstext,rssimage,rsskeywords,rsscategory,rssauthor,rsssource,rsspubDate"'9
		if king_dbtype=1 then l4=1 else l4=3
		set rs=server.createobject("adodb.recordset")
		rs.open "select "&sql&" from kingrss where rsstitle<>'' order by rssorder desc",conn,1,l4
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				I1="<?xml version=""1.0"" encoding=""UTF-8"" ?>"
				I2=I1
				I1=I1&"<document>"
				I1=I1&"<webSite>"&xmlencode(sect(datasys(1,0)&"/","//","/",""))&"</webSite>"
				I1=I1&"<updatePen>"&datasys(4,0)&"</updatePen>"
				I2=I2&"<rss version=""2.0"">"
				I2=I2&"<channel>"
				I2=I2&"<title>"&xmlencode(datasys(0,0))&"</title>"
				I2=I2&"<link>"&xmlencode(datasys(1,0))&"</link>"
				I2=I2&"<description>"&xmlencode(data(0,0))&"</description>"
				for i=0 to ubound(data,2)
					if len(data(0,i))>0 then'当标题有值的时候才进行更新
						I1=I1&"<item>"
						I1=I1&"<title>"&xmlencode(data(0,i))&"</title>"
						I1=I1&"<link>"&xmlencode(datasys(1,0)&data(1,i))&"</link>"
						if len(data(2,i))>0 then
							I1=I1&"<description>"&xmlencode(data(2,i))&"</description>"
						end if
						I1=I1&"<text>"&xmlencode(data(3,i))&"</text>"
						if len(data(4,i))>0 then
							I1=I1&"<image>"&xmlencode(datasys(1,0)&data(4,i))&"</image>"
						end if
						if len(data(5,i))>0 then
							I1=I1&"<keywords>"&xmlencode(data(5,i))&"</keywords>"
						end if
						I1=I1&"<category>"&xmlencode(data(6,i))&"</category>"
						if len(data(7,i))>0 then
							I1=I1&"<author>"&xmlencode(data(7,i))&"</author>"
						end if
						if len(data(8,i))>0 then
							I1=I1&"<source>"&xmlencode(data(8,i))&"</source>"
						end if
						I1=I1&"<pubDate>"&xmlencode(formatdate(data(9,i),"yyyy-MM-dd hh:mm"))&"</pubDate>"
						I1=I1&"</item>"
						j=j+1
						if int(j)=int(datasys(3,0)) then exit for
					
						I2=I2&"<item>"
						I2=I2&"<title>"&xmlencode(data(0,i))&"</title>"
						I2=I2&"<link>"&xmlencode(datasys(1,0)&data(1,i))&"</link>"
						if len(data(2,i))>0 then
							I2=I2&"<description>"&xmlencode(data(2,i))&"</description>"
						else
							I2=I2&"<description>"&xmlencode(data(0,i))&"</description>"
						end if
						if len(data(7,i))>0 then
							I2=I2&"<author>"&xmlencode(data(7,i))&"</author>"
						end if
						I2=I2&"<category>"&xmlencode(data(6,i))&"</category>"
						I2=I2&"<pubDate>"&xmlencode(formatdate(data(9,i),"yyyy-MM-dd hh:mm"))&"</pubDate>"
						if len(data(8,i))>0 then
							I2=I2&"<source>"&xmlencode(data(8,i))&"</source>"
						end if
						I2=I2&"</item>"
					end if
				next
				I2=I2&"</channel>"
				I2=I2&"</rss>"
				I1=I1&"</document>"
				savetofile "../../baidu_"&datasys(5,0)&".xml",I1
				savetofile "../../"&datasys(5,0)&".xml",I2
			end if
		rs.close
		set rs=nothing

end sub
'copyfolder  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub copyfolder(l1,l2)
	on error resume next
	dim fs
	set fs=createobject(king_fso)
		fs.copyfolder server.mappath(l1),server.mappath(l2)
	set fs=nothing
	if err.number<>0 then err.clear
end sub
'copyfile  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub copyfile(l1,l2)
	on error resume next
	dim fs
	set fs=createobject(king_fso)
		fs.copyfile server.mappath(l1),server.mappath(l2)
	set fs=nothing
	if err.number<>0 then err.clear
end sub
'press  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub press(l1)
	on error resume next
	dim I1,engine
	II1 "_db_temp.asp"
	I1=server.mappath(l1)
	set engine=createobject("jro.jetengine")
		engine.compactdatabase "provider=microsoft.jet.oledb.4.0;data source="&I1, _
		"provider=microsoft.jet.oledb.4.0;data source="&server.mappath("_db_temp.asp")
	set engine=nothing
	copyfile "_db_temp.asp",l1
	deletefile "_db_temp.asp"
	if err.number<>0 then err.clear
end sub
'checkcolumn  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function checkcolumn(l1)   
	checkcolumn=true
	on error resume next
	conn.execute "select top 1 * from "&l1&" ;"
	if err.number<>0 then
		checkcolumn=false
		error.clear
	end if
end function
'neworder  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function neworder(l1,l2)'formname ,ordername
	dim rs,I1,I2
	I1=conn.execute("select count(*) from "&l1&";")(0)
	if int(I1)>0 then
		I2=conn.execute("select max("&l2&") from "&l1&";")(0)+1
	else
		I2=1
	end if
	neworder=I2
end function
'newid  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function newid(l1,l2)
	dim rs,I1
	set rs=server.createobject("adodb.recordset")
	rs.open ("select top 1 "&l2&" from "&l1&" order by "&l2&" desc"),conn
	set I1=rs(0)
		newid=I1
	set rs=nothing
end function
'progress  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub progress(l1)
	dim s
	s=s+"<div id=""progresstitle""><span>"&lang("progress/create")&"</span><img class=""os"" src=""../system/images/close.gif"" onclick=""display('progress')""/></div>"
	s=s+"<div id=""progressmain"">"
	s=s+"<label class=""load"">"&lang("progress/loading")&"</label>"
	s=s+"<div class=""load""><div style=""width:0%"">&nbsp;</div></div>"
	s=s+"<var class=""load"">&nbsp;</var>"
	s=s+"</div>"
	s=s+"<div style=""display: none;"" class=""none"" id=""progress_iframe""><iframe border=""0"" class=""progress_iframe"" style=""width: 540px; height: 200px;"" src=""../"&king.path&"/"&l1&"""></iframe></div>"
	s=s+"<div id=""Submit""><p><a href=""javascript:;"" onclick=""moreinfo()"">"&lang("progress/moreinfo")&"</a><a href=""javascript:;"" onclick=""javascript:display('progress');"">【"&lang("common/close")&"】</a></p></div>"
	s=s+"<script>function moreinfo(){var obj=$('#progressmain + div');var o=$('#progress').offset();if(obj.css('display')=='none'){$('#progress').height(340);$('#progress').css('top',o.top-100);obj.show()}else{obj.hide();$('#progress').height(145);$('#progress').css('top',o.top+100)}}</script>"
	Il s
	r_end=false
	response.end
end sub
'aja  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub aja(l1,l2)
	Il"<div id=""ajatitle"" ondblclick=""display('aja')""><span>"&l1&" - "&htmlencode(sitename)&"</span><img class=""os"" src=""../system/images/close.gif"" onclick=""display('aja')""/></div>"'confirm('"&lang("confirm/close")&"')?display('aja'):void(1);
	Il"<div id=""ajamain"">"&l2&"</div>"
	r_end=false
	response.end
end sub
'flo  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub flo(l1,l2)
	dim I1,I2
	I2="<div id=""flotitle""><span>"&htmlencode(sitename)&"</span><img class=""os"" src=""../system/images/close.gif"" onclick=""display('flo')""/></div>"
	I2=I2&"<div id=""flomain"">"
	select case cstr(l2)
	case"0"
		Il I2&l1&"<br/><a href=""javascript:;"" onclick=""javascript:display('flo');"">【"&lang("common/close")&"】</a></div>"
	case"1"
		dim http_referer:http_referer=request.servervariables("http_referer")
		Il I2&l1&"<br/><a href="""&http_referer&""">【"&lang("common/close")&"】</a></div>"
	case"2"
		Il I2&l1&"</div>"
	case"3"
		if len(l1)>0 then
			I1=split(l1,"|")'30%|posthtm(\'test.asp\',\'main\',\'submit=create&page=" & page & "\');
			Il "{main:'<div id=""flotitle""><span>"&htm2js(htmlencode(sitename))&"</span><img class=""os"" src=""../system/images/close.gif"" onclick=""display(\'flo\')""/></div>"
			Il "<div id=""flomain"">"
			if validate(l1,"^/d/|posthtm\(.+\)$") then
				Il "<p class=""load"">"&I1(0)&"%</p>"
				Il "<div class=""load""><div style=""width:"&I1(0)&"%"">&nbsp;<\/div></div>"
				Il "<p class=""load"">&nbsp;</p>"
			else
				if cstr(l1)="100" then
					Il "<p class=""load"">100%</p>"
					Il "<div class=""load""><div style=""width:100%"">&nbsp;<\/div></div>"
					Il "<p class=""load"">OK!</p>"
				else
					Il htm2js(l1&"<br/><a href=""javascript:;"" onclick=""javascript:display('flo');"">【"&lang("common/close")&"】</a>")
				end if
			end if
			Il "</div>'"
			if validate(l1,"^/d/|posthtm\(.+\)$") then
				Il ",js:'"&htm2js(I1(1))&"'"
			end if
			Il "}"
		else
			Il "{main:'"&htm2js(I2&lang("error/invalid")&"</div>")&"',js:''}"
		end if
	end select
	r_end=false
	response.end
end sub
'txt  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub txt(l1)
	response.write  l1
	r_end=false
	response.end
end sub
'nocache  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub nocache()
	response.expires=0 
	response.expiresabsolute=now()-1 
	response.addheader "pragma","no-cache" 
	response.addheader "cache-control","private" 
	response.cachecontrol="no-cache" 
end sub
'ubbshow  *** ***  www.KingCMS.com  *** ***
public function ubbshow(l1,l2,l3,l4,l5)
	dim I1
	I1="<script type=""text/javascript"" src="""&inst&system&"/system/ubb/fun.js""></script>"
	I1=I1&"<script type=""text/javascript"">var ubb=new UBB('"&l1&"','"&htm2js(htmlencode(l2))&"',"&l3&","&l4&","&l5&",'"&inst&system&"/system/');</script>"
	I1=I1&"<script type=""text/javascript"">display(""KingCMS_Color"");display(""KingCMS_Emo"");</script>"
	ubbshow=I1
end function
'ubbencode  *** ***  www.KingCMS.com  *** ***
public function ubbencode(l1)
	dim I1,I2,i,I4:I4=array(16,19,21,24,32,45)

	if len(l1)>0 then
		I1=replace(htmlencode(l1)," ","&nbsp;")
	else
		exit function
	end if
	
	set I2=new regexp
	I2.ignorecase=true
	I2.global=true
	I2.pattern="(\[em\=)(\d{1,2})(\])":I1=I2.replace(I1,"<img src="""&king.inst&king_templates&"/image/em/$2.gif""/>")
	I2.pattern="(\[code\])((.|\n){0,}?)(\[\/code\])":I1=I2.replace(I1,"<code class=""ubb""><strong>CODE</strong><p>$2</p></code>")
	I2.pattern="(\[b\])((.|\n){0,}?)(\[\/b\])":I1=I2.replace(I1,"<strong>$2</strong>")
	I2.pattern="(\[i\])((.|\n){0,}?)(\[\/i\])":I1=I2.replace(I1,"<i>$2</i>")
	I2.pattern="(\[u\])((.|\n){0,}?)(\[\/u\])":I1=I2.replace(I1,"<u>$2</u>")
	for i=1 to 6
		I2.pattern="\[h"&i&"\]((.|\n){0,}?)(\[\/h"&i&"\])":I1=I2.replace(I1,"<h"&i&">$1</h"&i&">")
		I2.pattern="(\[size="&i&"\])((.|\n){0,}?)(\[\/size\])":I1=I2.replace(I1,"<span style=""font-size:"&I4(i-1)&"px;line-height:"&I4(i-1)+6&"px;"">$2</span>") 
	next
	I2.pattern="(\[font=(.+?)\])((.|\n){0,}?)(\[\/font\])":I1=I2.replace(I1,"<span style=""font-family:$2;"">$3</span>") 
	
	I2.pattern="\[align=(center|left|right)\]((.|\n){0,}?)(\[\/align\])":I1=I2.replace(I1,"<span style=""display:block;text-align:$1;"">$2</span>")

	I2.pattern="(\[url\])((http|https|ftp|mms|rtsp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\=\?\+\-~`@\':!%#]|(&amp;)|&)+)(\[\/url\])"
	I1=I2.replace(I1,"<a href="""&king.page&"system/link.asp?url=$2"" target=""_blank"">$2</a>")
	I2.pattern="(\[url=)((http|https|ftp|mms|rtsp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\=\?\+\-~`@\':!%#]|(&amp;)|&)+)(\])((.|\n)+?)(\[\/url\])"
	I1=I2.replace(I1,"<a href="""&king.page&"system/link.asp?url=$2"" target=""_blank"">$10</a>")
	I2.pattern="\[url=(\/"&king_upath&"\/.+?)\]((.|\n)+?)\[\/url\]"
	I1=I2.replace(I1,"<a href=""$1"" target=""_blank"">$2</a>")
	I2.pattern="(\[email\])(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+){0,100})(\[\/email\])":I1=I2.replace(I1,"<a href=""mailto:$2"">$2</a>") 
	I2.pattern="(\[email=(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+){0,80})\])(.[^\[]*)(\[\/email\])"
	I1=I2.replace(I1,"<a href=""mailto:$2"" target=""_blank"">$6</a>")

	I2.pattern="(\[fly\])((.|\n){0,}?)(\[\/fly\])" 
	I1=I2.replace(I1,"<marquee width=""100%"" behavior=""alternate"" scrollamount=""3"">$2</marquee>") 
	I2.pattern="(\[move\])((.|\n){0,}?)(\[\/move\])" 
	I1=I2.replace(I1,"<marquee scrollamount=""3"">$2</marquee>")  
	I2.pattern="(\[light\])((.|\n){0,}?)(\[\/light\])" 
	I1=I2.replace(I1,"<span style=""behavior:url("&king.page&"system/inc/font.htc)"">$2</span>")  
	I2.pattern="(\[color=(.{3,10})\])((.|\n){0,}?)(\[\/color\])" 
	I1=I2.replace(I1,"<span style=""color:$2;"">$3</span>")
		
	I2.pattern="(\[glow=.+?\])((.|\n)+?)(\[\/glow\])"
	I1=I2.replace(I1,"$2")
	I2.pattern="(\[shadow=.+?\])((.|\n)+?)(\[\/shadow\])"
	I1=I2.replace(I1,"$2")

	I2.pattern="\[upload=(gif|png|jpg|jpeg|bmp)\](UploadFile\/.+?\.(gif|png|jpg|jpeg|bmp))\[\/upload\]"
	I1=I2.replace(I1,"<img src="""&inst&"$2"" />")

	I2.pattern="\[upload=.+?\](UploadFile\/.+?)\[\/upload\]"
	I1=I2.replace(I1,"<a href="""&inst&"$1"" >"&inst&"$1</a>")

	I2.pattern="\[(rm|mp|qt)=.+?\]" 
	I1=I2.replace(I1,"[media]")
	I2.pattern="\[\/(rm|mp|qt)=.+?\]" 
	I1=I2.replace(I1,"[/media]")
	I2.pattern="\[(dir|flash)=.+?\]" 
	I1=I2.replace(I1,"[swf]")
	I2.pattern="\[\/(dir|flash)=.+?\]" 
	I1=I2.replace(I1,"[/swf]")

	I2.pattern="(\[img\])(\/"&inst&king_upath&"\/image\/.+?\.(jpeg|jpg|gif|png|bmp))(\[\/img\])" 
	I1=I2.replace(I1,"<img src=""$2"" />")
	I2.pattern="(\[img\])((http|https|ftp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\+\-~`@\':!%#]|(&amp;)|&)+\.(jpeg|jpg|gif|png|bmp))(\[\/img\])" 
	I1=I2.replace(I1,"<img src=""$2"" />")

	I2.pattern="(\[swf\])((http|https|ftp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\+\-~`@\':!%#]|(&amp;)|&)+\.swf)(\[\/swf\])" 
	I1=I2.replace(I1,"<div class=""ubb""><strong>Flash</strong><br/><object classid=""clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"" codebase=""http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0"" width=""352"" height=""288"" align=""middle""><param name=""movie"" value=""$2"" /><param name=""quality"" value=""high""><param name=""menu"" value=""false""><embed src=""$2"" quality=""high"" width=""352"" height=""288"" align=""middle"" type=""application/x-shockwave-flash"" pluginspage=""http://www.macromedia.com/go/getflashplayer"" /></object></div> ")
	
	I2.pattern="(\[flash\])((http|https|ftp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\+\-~`@\':!%#]|(&amp;)|&)+\.swf)(\[\/flash\])" 
	I1=I2.replace(I1,"<div class=""ubb""><strong>Flash</strong><br/><object classid=""clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"" codebase=""http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0"" width=""352"" height=""288"" align=""middle""><param name=""movie"" value=""$2"" /><param name=""quality"" value=""high""><param name=""menu"" value=""false""><embed src=""$2"" quality=""high"" width=""352"" height=""288"" align=""middle"" type=""application/x-shockwave-flash"" pluginspage=""http://www.macromedia.com/go/getflashplayer"" /></object></div>")
	I2.pattern="\[media\]((http|ftp|mms|https):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\+\-~`@\':!%#]|(&amp;)|&)+\.(wmv|asf|wm|wma|wmv|wmx|wmd|avi|mpeg|mpg|mpa|mpe|dat|w1v|mp2|asx))\[\/media]"
	I1=I2.replace(I1,"<div class=""ubb""><strong>"&king.lang("ubb/tip/media")&"</strong><br/><object><embed src=""$1"" autostart=""false"" playcount=""1""/></object></div>")

	I2.pattern="\[media\]((http|ftp|mms|https):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\+\-~`@\':!%#]|(&amp;)|&)+\.(mp3|mid))\[\/media]"
	I1=I2.replace(I1,"<div class=""ubb""><strong>Media</strong><br/><object classid=""CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95"" width=""352"" height=""45""><param name=""filename"" value=""$1""/><embed src=""$1"" playcount=""1""></embed></object></div>")

	I2.pattern="\[media\]((http|ftp|rtsp|https):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\+\-~`@\':!%#]|(&amp;)|&)+\.(ra|rm|rmj|rms|mnd|ram|rmm|r1m|rom|mns))\[\/media]"
	I1=I2.replace(I1,"<div class=""ubb""><strong>Media</strong><br/><object classid=clsid:cfcdaa03-8be4-11cf-b84b-0020afbbccfa width=""352"" height=""288""><param name=""src"" value=""$1""/><param name=""console"" value=""clip1""/><param name=""controls"" value=""imagewindow""/><param name=""autostart"" value=""false""/></object><object classid=""clsid:cfcdaa03-8be4-11cf-b84b-0020afbbccfa"" height=""32"" width=""352""><param name=""src"" value=""$1""/><param name=""controls"" value=""controlpanel""/><param name=""console"" value=""clip1""/></object></div>")

	I2.pattern="(\[quote\])":I1=I2.replace(I1,"<blockquote class=""ubb"">")
	I2.pattern="(\[\/quote\])":I1=I2.replace(I1,"</blockquote>")

	if instr(lcase(I1),"http://")>0 then
		I2.pattern="(^|[^<=""'])(http:(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\=\?\+\-~`@\':!%#]|(&amp;)|&)+)"
		I1= I2.replace(I1,"$1<a target=""_blank"" href=""$2"">$2</a>")
	end if
	'识别www等开头的网址
	if instr(lcase(I1),"www.")>0 or instr(lcase(I1),"bbs.")>0 then
		I2.pattern="(^|[^\/\\\w<=""])((www|bbs)\.(\w)+\.([\w\/\\\.\=\?\+\-~`@\'!%#]|(&amp;)) )"
		I1= I2.replace(I1,"$1<a target=""_blank"" href=""$2"">$2</a>")
	end if

	I1=replace(I1,chr(13)&chr(10),"<br />")

	set I2=nothing
	ubbencode=I1
end function
'zoomimg  *** ***  www.KingCMS.com  *** ***
public function zoomimg(l1,l2)
	dim I1,I2:l2=l1
	set I2=new regexp
		I2.global=true
		I2.ignorecase=true
		I2.pattern="<img.[^>]*src=""(.[^>]+?)"".[^>]*\/>"
		I1=I2.replace(I1,"<img src=""$1"" onclick=""if(this.width>="&l2&") window.open('$1');"" onload=""if(this.width>'"&l2&"')this.width='"&l2&"';"" />")
		zoomimg=I1
	set I2=nothing
end function
'snap 
public function snap(l1)
	dim objregexp,match,matches,arrimg,allimg,newimg,retstr
	dim i,fimagename,fname,filename,fext,k,arrnew,arrall,today,uppathfd
	set objregexp=new regexp
	objregexp.ignorecase=true
	objregexp.global=true
	objregexp.pattern="(<img([^>]*))( src=)([""'])(.*?)\4(([^>]*)\/?>)"
	set matches=objregexp.execute(l1)
		for each match in matches
			retstr=retstr&llllII(match.value)
		next
		arrimg=split(retstr,"||")
		allimg="":newimg=""

		today=formatdate(tnow,2)
		uppathfd="../../"&king_upath&"/image/"&path&"/"&today
		createfolder uppathfd'创建文件夹
		fname=timer()*100'定义一个随机图片文件名(无扩展名)

		for i=1 to ubound(arrimg)
			if arrimg(i)<>"" and instr(allimg,arrimg(i))<1 then
				filename=fname&i'文件名(无扩展名)
				fext=mid(arrimg(i),instrrev(arrimg(i),"."))
				fimagename=filename&fext'获得扩展名,加上一个i循环?这样容易产生重复文件.
				'判断是否存在同名的文件,如果没有就直接通过,如果有,就重命名
				while (isexist(uppathfd&"/"&fimagename))
					fimagename=filename&"_"&k&fext
					k=k+1
				wend
				remote2local arrimg(i),uppathfd&"/"&fimagename
				allimg=allimg&"||"&arrimg(i)
				newimg=newimg&"||"&inst&king_upath&"/image/"&path&"/"&today&"/"&fimagename
			end if
		next
		arrnew=split(newimg,"||")
		arrall=split(allimg,"||")
		for i=1 to ubound(arrnew)
			l1=replace(l1,arrall(i),arrnew(i))
		next
		snap=l1
	set matches=nothing
	set objregexp=nothing
end function
'remote2local  *** ***  www.KingCMS.com  *** ***
public sub remote2local(l1,l2)
	on error resume next
	dim I1,I2,I3:I1=trim(l1):I3=gethtm(I1,1)
	set I2=server.createobject(king_stm)
		I2.type=1
		I2.open
		I2.write I3
		I2.savetofile server.mappath(l2),2
		I2.close()
	set I2=nothing
	watermark l2
end sub
'llllII 
private function llllII(l1)
	dim objregexp,I1,I2,I3
	set objregexp=new regexp
		objregexp.ignorecase=true
		objregexp.global=true
		objregexp.pattern="(http|https|ftp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\=\?\+\-~`@\':!%#]|(&amp;)|&)+\.("&replace(king_imgtype,"/","|")&")"
		set I2=objregexp.execute(l1)
			for each I3 in I2
				I1=I1&"||"&left(I3.value,len(I3.value))
			next
			llllII=I1
		set I2=nothing
	set objregexp=nothing
end function
'gethtm 
public function gethtm(l1,l2)
	on error resume next
	dim I1,l3,l4,l5
	l5=mid(l1,1,instr(8,l1,"/"))
	set I1=createobject("msxml2.xmlhttp")
		I1.open "get",l1,false
		I1.setrequestheader "referer",l5
		I1.send
		if I1.readystate<>4 then exit function'文档已经解析完毕，客户端可以接受返回消息
		select case cstr(l2)
		case"0" gethtm=I1.responsetext		' 将返回消息作为text文档内容；
		case"1" gethtm=I1.responsebody		' 将返回消息作为HTML文档内容；
		case"2" gethtm=I1.responsexml			' 将返回消息视为XML文档，在服务器响应消息中含有XML数据时使用； 
		case"3" gethtm=I1.responsestream	' 将返回消息视为Stream对象 
		case"4"
			l3=I1.responsetext
			l4=match(l3,"(<meta ).+?(charset=)(.+?)"".{0,}?\>")
			l4=sect(l4,"charset=","""","")'获得编码
			if len(l4)>0 then
			else
				l4=king_collcode
			end if
			if lcase(l4)="utf-8" then
				gethtm=l3
			else
				gethtm=bytes2bstr(I1.responsebody,l4)		' 将返回消息作为HTML文档内容；
			end if
		case"5"
			l3=I1.responsetext
			l4=match(l3,"(<\?xml).{0,}?(encoding\="")(.+?)"".{0,}?\?>")
			l4=sect(l4,"encoding=""","""","")'获得编码
			if len(l4)>0 then
			else
				l4=king_collcode
			end if
			if lcase(l4)="utf-8" then
				gethtm=l3
			else
				gethtm=bytes2bstr(I1.responsebody,l4)		' 将返回消息作为HTML文档内容；
			end if
		end select
	set I1=nothing
	if err.number<>0 then err.clear
end function
'bytestobstr 
private function bytes2bstr(l1,l2)
	dim I1
	set I1=server.createobject(king_stm)
		I1.type=1
		I1.mode =3
		I1.open
		I1.write l1
		I1.position=0
		I1.type=2
		I1.charset=l2
		bytes2bstr=I1.readtext
		I1.close
	set I1=nothing
end function
'likey  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function likey(l1,l2)
	dim I1,I2,i
	if len(l2)>0 then
		I2=split(l2,",")
		for i=0 to ubound(I2)
			if len(I2(i))>0 then
				if len(I1)>0 then
					I1=I1&" or "&l1&" like '%"&safe(I2(i))&"%'"
				else
					I1=" "&l1&" like '%"&safe(I2(i))&"%'"
				end if
			end if
		next
	end if
	likey=I1
end function
'updown  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub updown(l1,l2,l3)'l1="fromname,idname,ordername" l2="id值" l3="where循环条件"
	nocache
	server.scripttimeout=86400
	dim I1(1),I2(1),I3(1),I4,I5,I6,I7,I8,I9:I9=quest("url",0)
	dim l9:l9=quest("back",0)
	dim rs,i
	I5=quest("num",2)
	if len(I5)>0 then
		I4=split(l1,",")
		if action="down" then I3(0)=" desc"
		if len(l3)>1 then I3(1)=" where "&l3
		set rs=conn.execute("select "&I4(1)&","&I4(2)&" from "&I4(0)&I3(1)&" order by "&I4(2)&I3(0)&","&I4(1)&I3(0)&";")
			while (not rs.eof)
				if int(l2)=int(rs(0)) then
					I1(0)=rs(0)'赋值当前对象id
					I2(0)=rs(1)'order
					for i=1 to int(I5)
						rs.movenext
						if rs.eof then response.redirect l9
						I1(1)=rs(0)'获得下一个值
						I2(1)=rs(1)
						conn.execute "update "&I4(0)&" set "&I4(2)&"="&I2(1)&" where "&I4(1)&"="&I1(0)'更新order值
						conn.execute "update "&I4(0)&" set "&I4(2)&"="&I2(0)&" where "&I4(1)&"="&I1(1)
'						I1(0)=I1(1)
						I2(0)=I2(1)
					next
					response.redirect l9
				end if
				rs.movenext
			wend
			rs.close
		set rs=nothing
	else
		I7=array("",1,2,3,4,5,6,7,8,9,10,15,20)
		I6="<select name="""" onchange=""jumpmenu(this);"">"
		if action="up" then I8="&uarr;" else I8="&darr;"
		for i=0 to ubound(I7)
			I6=I6&"<option value="""&I9&"&action="&action&"&num="&I7(i)&"&url="&server.urlencode(I9)&"&back="&server.urlencode(l9)&""">"&I8&I7(i)&"</option>"
		next
		I6=I6&"</select>"
		king.txt I6
	end if
end sub
'paging  *** ***  www.KingCMS.com  *** ***
public function paging(l1,l2)
	dim I1,I2,I3,i,j,k,l3,l4
	l4=len(l1)
'	if cstr(l2)="0" then l2=king_paging'如果参数l2为0，则不分页
	if instr(l1,king_break)>0 and l4<=(l2*1.5) then'已经分页、或文章长度小于指定的值的1.5倍 ，就不分页
		paging=l1
		exit function
	end if
	j=0:k=0
	I1=split(l1,chr(13)&chr(10))
	l3=ubound(I1)
	for i=0 to l3
		I2=I2&I1(i)&chr(13)&chr(10)
		j=j+len(I1(i))
		k=k+len(I1(i))
		if j>cdbl(l2) then
			if l4-k>l2*0.5 then
				I2=I2&king_break
				j=0
			end if
		end if
	next
	paging=I2
end function
public function getversion()

	dim I1,I2,I3,I4
	dim url,xmlhttp

	on error resume next

	set xmlhttp=createobject("Msxml2.ServerXMLHTTP")
	xmlhttp.setTimeouts 1000,1000,1000,1000
	url="http://www."&king.systemname&".cn/page/ver/?"&request.servervariables("server_name")
	xmlhttp.open "GET",url,false
	xmlhttp.setrequestheader "Content-Type","application/x-www-form-urlencoded"
	xmlhttp.send
	I4=xmlhttp.responsetext
	set xmlhttp=nothing

	if validate(I4,11) then
		I2=split(I4,chr(46))
		I3=split(king.systemver,chr(46))
		if int(I2(0))*100+int(I2(1))*10+int(I2(2))+cdbl(chr(46)&I2(3))>int(I3(0))*100+int(I3(1))*10+int(I3(2))+cdbl(chr(46)&I3(3)) then
			I1="<label>"&I4&"<label> <a href="""&king_system&"system/link.asp?url=http://www.kingcms.com/download/"" target=""_blank"">【"&king.lang("parameters/downnew")&"】</a>"
			I1=I1&" <a href=""javascript:;"" onclick=""javascript:posthtm('manage.asp?action=update','flo','ver="&I4&"');"">【"&king.lang("parameters/update")&"】</a>"
		else
			I1=I4
		end if
	else
		I1=king.lang("parameters/newversionerr")
	end if
	getversion=I1
end function
'lefthtml  *** ***  www.KingCMS.com  *** ***
public function lefthtml(l1,l2)'html内容 截取长度
	dim I1,I2,i,j
	I2=split(l1,chr(13)&chr(10))
	for i=0 to ubound(I2)
		I1=I1&I2(i)&chr(13)&chr(10)
		j=j+len(I2(i))
		if cdbl(j)>cdbl(l2) then exit for
	next
	lefthtml=I1
end function
'filecate  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function filecate(l1)
	dim I1'改正后的扩展名长度必须为3
	select case lcase(l1)
	case"doc","inc","mid","pdf","ppt" I1=l1
	case"swf","fla" I1="fla"
	case"htm","html","shtml","shtm","asp","php" I1="htm"
	case"jpg","jpeg","gif","bmp","png" I1="img"
	case"mov","avi" I1="mov"
	case"zip","rar" I1="tar"
	case"txt","css","xml","js" I1="txt"
	case"wma","mp3","mp2","mp" I1="wma"
	case"xls","xslt" I1="xls"
	case else I1="sys"
	end select
	filecate=I1
end function
'pinyin  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function pinyin(l1)
	dim I1,I2,l2,l3,i,rs
	on error resume next
	set I2=server.createobject("adodb.connection")
	I2.open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source="&server.mappath(king_system&"system/inc/pinyin.asp")

	if err.number<>0 then king.error king.lang("pinyin")
	for i=1 to len(l1)
		l2=mid(l1,i,1)
		if len(trim(l2))=1 then'长度为1

			l3=cdbl(asc(lcase(l2)))
			if l3>1 and l3<128 then'若为数字
				if validate(l2,"^[A-Za-z0-9]+$") then
					I1=I1&l2
				else
					I1=I1&" "
				end if
			else
				set rs=I2.execute("select top 1 pinyin from kingpy where content like '%"&safe(l2)&"%';")
					if not rs.eof and not rs.bof then'中文
						I1=I1&rs(0)
					else
						I1=I1&" "
					end if
					rs.close
				set rs=nothing
			end if
		else
			I1=I1&" "'换行替换为空格
		end if
	next
	I2.close
	set I2=nothing

	if len(I1)>0 then
		I1=trim(I1)
		if len(I1)>0 then
			I1=replace(I1," ","_")
			while (instr(I1,"__"))
				I1=replace(I1,"__","_")
			wend
		end if
	end if

	if len(trim(I1))>0 then
		pinyin=trim(I1)
	else
		pinyin=md5(salt(10),1)
	end if
end function
'isfile  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function isfile(l1)
	dim I1
	if len(l1)>0 then
		I1=split(l1,"/")
		if instr(I1(ubound(I1)),".")>0 then
			isfile=true
		else
			isfile=false
		end if
	else
		isfile=false
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function mod2(l1,l2)
	if int(l1) mod int(l2) then
		mod2=1
	else
		mod2=0
	end if
end function
'createhome  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub createhome()
	dim rs,one
	if instre(plugin,"onepage") then
		if checkcolumn("kingonepage") then'需要单页面数据库存在
			set rs=conn.execute("select oneid from kingonepage where onepath='';")
				if not rs.eof and not rs.bof then
					set one=new onepage
						one.create rs(0)
					set one=nothing
				end if	
				rs.close
			set rs=nothing
		end if
	end if
end sub
'ensql  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function ensql(l1)
	on error resume next
	'{king:sql cmd="select ..."}(king:#1/){/king}
	dim I1,rs,data,i,j
	dim jscmd,jshtm,zebra,isjshtm
	jscmd=getlabel(l1,"cmd")
	jshtm=getlabel(l1,0)
	zebra=getlabel(l1,"zebra")

	if len(jshtm)=0 then
		jshtm="(king:#0/)"
		isjshtm=false
	else
		isjshtm=true
	end if

	set rs=conn.execute(jscmd)
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)

				king.clearvalue
				for j=0 to ubound(data,1)
					king.value "#"&j,encode(htmlencode(data(j,i)))
					king.value lcase(rs.fields(j).name),encode(htmlencode(data(j,i)))
				next
				king.value "zebra",king.mod2(i+1,zebra)
				king.value "++",i+1

				I1=I1&king.createhtm(jshtm,king.invalue)
				if i=0 and isjshtm=false then
					exit for
				end if

				if i>999 then exit for
			next
		end if
		rs.close
	set rs=nothing

	if err.number<>0 then
		err.clear
		ensql=errtag(l1)
	else
		ensql=I1
	end if
end function
'pagebreak  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function pagebreak(l1)
	pagebreak=replacee(l1,"(<(div|center) style=""PAGE-BREAK-AFTER: always"">(|<span.+?<\/span>)<\/(div|center)>)",king_break)
end function
'errtag  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function errtag(l1)
	dim l2
	l2=systemname&" Tag Error !"
	errtag=vbcrlf&vbcrlf&vbcrlf&"<! -- -- -- -- -- "&l2&" -- -- -- -- -- "&vbcrlf&vbcrlf&l1
	errtag=errtag&vbcrlf&vbcrlf&" ! -- -- -- -- -- "&l2&" -- -- -- -- -->"&vbcrlf&vbcrlf&vbcrlf
end function
'dirty  *** ***  www.KingCMS.com  *** ***
public function dirty(l1)
	dim bads,I1,I2,i,I3,rs

	set rs=conn.execute("select dirty from kingsystem;")
		if not rs.eof and not rs.bof then
			I3=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing
	if len(l1)>0 then
		I1=l1
		if len(I3)>0 then
			bads=split(I3,",")
			
			set I2=new regexp
				I2.global=true
				I2.ignorecase=true
				for i=0 to ubound(bads)
					I2.pattern="("&bads(i)&")"
					I1=I2.replace(I1,chr(2)&"$dirty$"&chr(3))
				next
			set I2=nothing
		end if
	end if
	if instr(I1,chr(2)&"$dirty$"&chr(3)) then
		dirty=False
	else
		dirty=True
	end if
end function
'getsql  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function getsql(l1,l2)
	on error resume next
	dim rs
	set rs=conn.execute("select "&l2&" from "&l1&";")
		if not rs.eof and not rs.bof then
			getsql=rs(0)
		end if
		rs.close
	set rs=nothing
end function
'createplugin  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub createplugin()

	dim I1,i,outasp,inctagtext,inctag
	dim rs,l1

	set rs=conn.execute("select plugin from kingsystem;")
		if not rs.eof and not rs.bof then
			l1=rs(0)
		else
			king.flo king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	outasp="<!--#include file="""&king_system&"system/fun.asp""-->"&vbcrlf
	I1=split(l1,",")
	for i=0 to ubound(I1)
		if king.isexist(king_system&I1(i)&"/fun.asp") then
			outasp=outasp&"<!--#include file="""&king_system&I1(i)&"/fun.asp""-->"&vbcrlf
		end if
		inctagtext=king.readfile(king_system&I1(i)&"/tag.inc")
		if len(inctagtext)>0 then
			inctag=inctag&inctagtext&chr(13)&chr(10)
		end if
	next
	outasp=outasp&"<%const king_system = """&king_system&"""%"&">"&vbcrlf

	'替换自定义标签
	outasp=outasp&replace(king.readfile(king_system&"system/inc/tag.asp"),"{king:case/}",inctag)

	king.savetofile king_system&"system/plugin.asp",outasp
	king.savetofile "plugin.asp",outasp

end sub
'update  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private sub update()
	dim sql
	if cdbl(dbver)<5.01 then'当当前版本小于5.0的时候，进行更新
		sql="diymenu ntext"
		conn.execute "alter table kingadmin add "&sql&" ;"
	end if
	if cdbl(dbver)<5.02 then
		sql="dirty ntext,"'限制发言的内容
		sql=sql&"sitemapnumber int not null default 3000,"'sitemaps列表长度
		sql=sql&"searchtemplate nvarchar(50)"'搜索页的模版
		conn.execute "alter table kingsystem add "&sql&" ;"'自定义后台栏目的补充		
		conn.execute "update kingsystem set dirty='江泽民,胡锦涛,温家宝,傻B,他妈的,操你妈,草你妈,妈逼,法轮功,李洪志,我操,我草',searchtemplate='"&safe(king_default_template)&"',sitemapnumber=3000;"
	end if
	conn.execute "update kingsystem set dbver='"&r_thisver&"' where systemver='5.0';"
end sub



end class '  End KingCMS class




'record  *** Copyright &copy KingCMS.com All Rights Reserved. ***
class record
	private r_purl,r_pid,r_rn,r_plist,r_length,r_pagecount,r_count,r_data,r_but,r_js,r_action,r_value
	public property let purl(l1)	:r_purl=l1:end property
	public property let pid(l1)		:r_pid=l1:end property
	public property get pid			:pid=r_pid:end property
	public property let rn(l1)		:r_rn=l1:end property
	public property get rn			:rn=r_rn:end property
	public property get length		:length=r_length:end property
	public property get pagecount	:pagecount=r_pagecount:end property
	public property get count		:count=r_count:end property
	public property get data(l1,l2):data=r_data(l1,l2):end property
	'but  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public property let but(l1)
		r_but="<div class=""k_but"">"&l1&"</div>"
	end property
	'action  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public property let action(l1)
		r_action=l1
	end property
	'value  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public property let value(l1)
		r_value=l1
	end property
	'plist  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public property get plist
		if len(r_plist)=0 and length>=0 then
			r_plist=pagelist(r_purl,r_pid,r_pagecount,r_count)
		end if
		plist=r_plist
	end property
	'prn  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public property get prn
		dim I1,I2,i
		I2=array("20","40","100","200")
		for i=0 to ubound(I2)
			if cint(r_rn)=cint(I2(i)) then
				I1=I1&"<strong>"&I2(i)&"</strong>"
			else
				I1=I1&"<a href="""&replace(r_purl,"pid=$&rn="&r_rn,"pid=1&rn="&I2(i))&""">"&I2(i)&"</a>"
			end if
		next
		prn="<span class=""prn"">"&I1&"</span>"
	end property
	'begin  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	private sub class_initialize()
		r_rn=quest("rn",2):if len(r_rn)=0 then r_rn=20
		if int(r_rn)>200 then r_rn=200
		if int(r_rn)<10 then r_rn=10
		r_pid=quest("pid",2):if len(r_pid)=0 then r_pid=1
		r_purl="index.asp?pid=$&rn="&r_rn
		r_pagecount=0
		r_count=0
		r_length=0
		r_action="index.asp?action=set"
	end sub
	'create  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public sub create(l1)'sql,参数:0=不分页 1分页
		dim l4,rs
		if king_dbtype=1 then l4=1 else l4=3
		r_length=-1
		set rs=server.createobject("adodb.recordset")
		rs.open l1,conn,1,l4
			r_count=rs.recordcount
			r_pagecount=int(r_count/r_rn):if r_pagecount<(r_count/r_rn) then r_pagecount=r_pagecount+1
			if not rs.eof and not rs.bof then
				rs.move r_rn*(r_pid-1)
				if not rs.eof then
					r_data=rs.getrows(r_rn)
					r_length=ubound(r_data,2)
				end if
			end if
		rs.close
		set rs=nothing
	end sub
	'js  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public property let js(l1)
		r_js=r_js&"'<td>'+"&l1&"+'</td>'+"
	end property
	'open  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public function open()
		dim I1
		I1="<form name=""form1"" class=""k_form"">"
		I1=I1&"<script type=""text/javascript"">"
		I1=I1&"var but='"&htm2js(r_but)&"';document.write(but);"
		I1=I1&"function ll(){var K=ll.arguments;document.write('<tr>'+"&r_js&"'</tr>');};var k_delete='"&htm2js(king.lang("confirm/delete"))&"';var k_clear='"&htm2js(king.lang("confirm/clear"))&"';</script>"
		I1=I1&king_table_s
		open=I1
	end function
	'close  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public function close()
		dim I1
		I1="</table>"
		I1=I1&"<script type=""text/javascript"">document.write(but);</script>"
		I1=I1&"</form>"
		close=I1
	end function
	'sect  *** Copyright &copy KingCMS.com All Rights Reserved. ***
	public function sect(l1)'values
		dim I1,I2,i,l4,l5
		l5="<option value=""-"" class=""gray"">&nbsp; ---------- &nbsp;</option>"
		if length>=0 then
			I1=split(l1,"|")
			l4="<select onChange=""gm('"&r_action&"','flo',this,'"&r_value&"');if(this.options[this.selectedIndex].value){this.options[0].selected=true;}"">"
			l4=l4&l5

			if len(l1)>0 then
				for i=0 to ubound(I1)
					if I1(i)="-" then
						l4=l4&l5
					else
						I2=split(I1(i),":")
						l4=l4&"<option value="""&I2(0)&""">"&I2(1)&"</option>"
					end if
				next
				l4=l4&l5
			end if
			l4=l4&"<option value=""delete"">"&king.lang("common/delete")&"</option>"

			l4=l4&"</select>"
			l4=l4&"<input type=""button"" name=""button"" value="""&king.lang("common/rselect")&""" onClick=""check(this)"" />"
			l4=l4&"<input type=""button"" name=""button"" value="""&king.lang("common/aselect")&""" onClick=""checkall(this)"" />"
		else
			l4="<select disabled=""true"">"&l5&"</select>"
			l4=l4&"<input type=""button"" name=""button"" value="""&king.lang("common/rselect")&""" disabled=""true"" />"
			l4=l4&"<input type=""button"" name=""button"" value="""&king.lang("common/aselect")&""" disabled=""true"" />"
		end if
		sect="<span class=""k_menu"">"&l4&"</span>"
	end function
end class
























'以下函数不能放到class类去!
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub createpause(l1)
	king.txt "<br />暂停1秒后继续生成<script language=""javascript"">setTimeout(""createnextpage();"",1000);function createnextpage(){location.href='"&l1&"';}</script>"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub alert(l1)
	king.txt "<script language=""javascript"">alert("""&l1&""");parent.location.reload();</script>"
end sub
'pagelist  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function pagelist(l1,l2,l3,l5)
	if instr(l1,"$")=0 then exit function
	if l5=0 then exit function
	dim l4,k,l6,l7,I2
	l2=int(l2):l3=int(l3):l5=int(l5)
	if l2>3 then 
		l4=("<a href="""&replace(replace(l1,"$/",""),"$","")&""">1 ...</a>")'
	end if
	if l2>2 then
		l4=l4&("<a href="""&replace(l1,"$",l2-1)&""">&lsaquo;&lsaquo;</a>")
	elseif l2=2 then
		l4=l4&("<a href="""&replace(l1,"$","")&""">&lsaquo;&lsaquo;</a>")
	end if
	for k=l2-2 to l2+7
		if k>=1 and k<=l3 then
			if cstr(k)=cstr(l2) then
				l4=l4&("<strong>"&k&"</strong>")
			else
				if k=1 then
					if instrrev(l1,"$/")>0 then
						l4=l4&("<a href="""&replace(l1,"$/","")&""">"&k&"</a>")
					else
						l4=l4&("<a href="""&replace(l1,"$","")&""">"&k&"</a>")
					end if
				else
					l4=l4&("<a href="""&replace(l1,"$",k)&""">"&k&"</a>")
				end if
			end if
		end if
	next
	if l2<l3 and l3<>1 then
		l4=l4&("<a href="""&replace(l1,"$",l2+1)&""">&rsaquo;&rsaquo;</a>")
	end if
	if l2<l3-7 then
		l4=l4&("<a href="""&replace(l1,"$",l3)&""">... "&l3&"</a>")
	end if

	I2=split(l1,"$")
	pagelist="<span class=""k_pagelist""><em>"&l5&"</em>"&l4&"</span>"
end function
'l11l  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function l11l(l1,l2)
	dim I1,I2,i
	I1=split(l1,"|")
	for i=0 to ubound(I1)
		if cstr(split(I1(i),":")(0))=cstr(l2) then
			I2=split(I1(i),":")(1)
			exit for
		end if
	next
	l11l=decode(I2)
end function
'I1I1I  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function I1I1I(l1,l2,l3)'l1, l2总参数, l3对应的参数
'	out l1&vbcr&l2&vbcr&l3
	dim I6,l5,l6,l7,l8,l9,I1,l10,I2,i
	dim l4,I5,rs
	l6=l11l(l2,l3)
	if cstr(l6)="" then exit function
	I1=l6

	l7=king.sect(l1,"size=""","""","") 'size
	if validate(l7,2) then
		if king.lene(l6)>int(l7) then
			I1=king.lefte(l6,l7)
		else
			I1=l6
		end if
	end if

	l5=king.sect(l1,"left=""","""","")
	if validate(l5,2) then
		I1=king.lefthtml(l6,l5)
	end if
	
	if isdate(l6) then
		l8=king.sect(l1,"mode=""","""","")'datemode
		if cstr(l8)<>"" then
			I1=formatdate(l6,l8)
		end if
	end if
	
	if instr(lcase(l3),"image")>0 or instr(lcase(l3),"img")>0 then
	'如果是在前台的话,不生成,但判断一下图片地址,如果存在就直接输出路径,如果不存在就判断是否支持aspjpeg,如果支持就生成输出
		dim imgwidth,imgheight,imgpath,imgname,imgnameonly,imgnameext
		imgwidth=king.sect(l1,"width=""","""","")
		imgheight=king.sect(l1,"height=""","""","")
'		out l6'l6是图片路径
		if king.isobj(king_jpeg) and king_isjpeg and king.isexist(l6) and validate(imgwidth,2) and validate(imgheight,2) then
			I6=split(l6,"/")
			imgpath=left(l6,len(l6)-len(I6(ubound(I6))))'包括/的路径
			imgname=I6(ubound(I6))
			imgnameonly=king.onlyfilename(imgname)
			imgnameext =king.extension(imgname)
			I1=imgpath&"TN/"&imgnameonly&"_"&imgwidth&"_"&imgheight&"."&imgnameext'缩略图路径
			if king.jpeg(l6,I1,imgwidth,imgheight)=false then I1=l6'如果失败的话，赋回原来的值
		else
			I1=l6
		end if
	end if

	l9=king.sect(l1,"code=""","""","")'code
	if len(I1)>0 then
		select case l9
			case"javascript","js" I1=htm2js(I1)
			case"xmlencode","xml" I1=xmlencode(I1)
			case"urlencode","url" I1=server.urlencode(I1)
			case"htmlencode","html" I1=htmlencode(I1)
			case"htmldecode" I1=htmldecode(I1)
			case"htmlcode" I1=htmlcode(I1)
		end select
	end if

	if l9<>"htmlencode" then'关键字加链接(lcase(l3)="keyword" or lcase(l3)="keywords") and 
		l10=king.sect(l1,"url=""","""","")
		I2=split(I1,",")
		if len(l10)>0 then
			l10=king.createhtm(l10,"")
			I1=""
			for i=0 to ubound(I2)
				I1=I1&"<a href="""&l10&server.urlencode(I2(i))&""" target=""_blank"">"&I2(i)&"</a> "
			next
		end if
	end if

	l4=king.sect(l1,"link=""","""","")
	if len(l4)>0 then
		'获得关键字组
		'set rs=conn.execute("select sitekeywords from kingsystem where systemname='KingCMS';")
		'	if not rs.eof and not rs.bof then
		'		if len(rs(0))>0 then
		'			set I5=new regexp
		'				I5.IgnoreCase=True
		'				I5.Global=True
		'				I5.pattern="([^<]"&replace(rs(0),",","|")&")"
		'				I1=I5.replace(I1,"<a href="""&l4&"$1"" target=""_blank"" title=""$1"">$1</a>")
		'			set I5=nothing
		'		end if
		'	end if
		'	rs.close
		'set rs=nothing
		I1=replacekeywords(I1,l4)
	end if

	I1I1I=I1
end function
'Il  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub Il(l1)
	response.write l1'&vbcrlf
end sub
'II  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub II(l1)
	response.write l1'&vbcrlf
	response.flush
end sub
'safe  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function safe(l1)
	if len(l1)>0 then
		safe=replace(killjapan(trim(cstr(l1))),"'", "''")
	end if
end function
'killjapan  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function killjapan(l1)
	on error resume next
	if king_dbtype=0 then
		dim I1,I2,i,l2:l2=l1
		I1=array("ガ","ギ","グ","ア","ゲ","ゴ","ザ","ジ","ズ","ゼ","ゾ","ダ","ヂ","ヅ","デ","ド","バ","パ","ビ","ピ","ブ","プ","ベ","ペ","ボ","ポ","ヴ")
		I2=array("460","462","463","450","466","468","470","472","474","476","478","480","482","485","487","489","496","497","499","500","502","503","505","506","508","509","532")
		for i=0 to 26
			l2=replace(l2,I1(i),"&#12"&I2(i)&";")
		next
		killjapan=l2
	else
		killjapan=l1
	end if
end function
'validate  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function validate(l1,l2)
	dim l3,l4
	set l4=New regexp
	select case cstr(l2)
		case"0" l3="^[a-zA-Z0-9\,\/\-\_\[\]]+$"
		case"1" l3="^[A-Za-z]+$"
		case"2" l3="^\d+$"
		case"3" l3="^[A-Za-z0-9\_\-]+$"
		case"4" l3="^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
		case"5" l3="^(http|https|ftp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\=\?\+\-~`@\':!%#]|(&)|&)+"
		case"6" l3="^[0-9\,\.]+$"
		case"7" l3="^((http|https|ftp):(\/\/|\\\\)(([\w\/\\\+\-~`@:%])+\.)+([\w\/\\\.\=\?\+\-~`@\':!%#]|(&)|&)+|\/([\w\/\\\.\=\?\+\-~`@\':!%#]|(&)|&)+)\.(jpeg|jpg|gif|png|bmp)$"
		case"8" l3="^\w+\.(\w){1,30}$"
		case"9" l3="^((((1[6-9]|[2-9]\d)\d{2})-(0?[13578]|1[02])-(0?[1-9]|[12]\d|3[01]))|(((1[6-9]|[2-9]\d)\d{2})-(0?[13456789]|1[012])-(0?[1-9]|[12]\d|30))|(((1[6-9]|[2-9]\d)\d{2})-0?2-(0?[1-9]|1\d|2[0-8]))|(((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00))-0?2-29)) (20|21|22|23|[0-1]?\d):[0-5]?\d:[0-5]?\d$"
		case"10"
		l3="^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$"
		case"11"
		l3="^\d?\.\d?\.\d?\.\d{4}$"
		case"12"
		l3="^((((1[6-9]|[2-9]\d)\d{2})-(0?[13578]|1[02])-(0?[1-9]|[12]\d|3[01]))|(((1[6-9]|[2-9]\d)\d{2})-(0?[13456789]|1[012])-(0?[1-9]|[12]\d|30))|(((1[6-9]|[2-9]\d)\d{2})-0?2-(0?[1-9]|1\d|2[0-8]))|(((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00))-0?2-29))$"
		case else l3=l2

	end select
	l4.pattern=l3
	validate=l4.Test(trim(l1))
	set l4=nothing
end function
'quest  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function quest(l1,l2)
	dim l5,l3,I2,i

	l5=killjapan(trim(request.querystring(l1)))
	if len(l5)=0 then exit function
	select case cstr(l2)
	case"0"
	case"1","2","3"
		if validate(l5,l2)=false then king.error king.lang("error/url")
	case"4"
		if len(l5)>0 then
			l3="1,2,3,4,5,6,7,8,9,10,14,15,16,17,18,19,20,21,22,23,24,25,26,27,32,33,34,35,36,37,38,39,40,41,"			
			l3=l3&"42,43,44,45,46,47,58,59,60,61,62,63,64,91,92,93,94,95,96,123,123,124,125,126"
			I2=split(l3,",")
			for i=0 to ubound(I2)
				l5=replace(l5,chr(I2(i))," ")
			next
			while (instr(l5,"  ")>0)
				l5=replace(l5,"  "," ")
			wend
			if len(trim(l5))>0 then
				l5=replace(l5," ",",")
			end if
		end if
	case else
		if validate(l5,l2)=false then king.error king.lang("error/url")
	end select
	quest=l5
end function
'form  *** Copyright &copy KingCMS.com All Rights Reserved. ***
' 不能放到class类去!
function form(l1)
	on error resume next
	if instr(lcase(request.servervariables("content_type")),"multipart/form-data") then'multipart/form-data
		if isobject(upload)=false then
			set upload=new UpLoadClass
			upload.open
		end if
		form=trim(upload.form(trim(l1)))
	else
		form=trim(request.form(trim(l1)))
	end if
	if err.number<>0 then err.clear
end function
'out  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub out(l1)
	response.clear
		Il "<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">"
		if len(l1)>0 then
			Il "<textarea name="""" rows=""30"" cols=""120"">"&formencode(l1)&"</textarea>"
		else
			Il "<textarea name="""" rows=""30"" cols=""120"">Not DATA!</textarea>"
		end if
	response.end()
end sub
'salt  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function salt(l1)
	dim l2,l3,i
	l2="0123456789abcdefghijklmnopqrstopwxyz"
	l3=len(l2)
	randomize
	for i=1 to l1
		salt=salt&mid(l2,round((rnd*(l3-1))+1),1)
	next
end function
'formatdate  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function formatdate(l1,l2)
	dim I1
	if len(l1)>0 then
		select case cstr(l2)
		case"0"
			I1=year(l1)&"-"&month(l1)&"-"&day(l1)&" "&hour(l1)&":"&minute(l1)&":"&second(l1)
		case"1"
			I1=year(l1)&"-"&king.doublee(month(l1))&"-"&king.doublee(day(l1))&" "&king.doublee(hour(l1))&":"&king.doublee(minute(l1))&":"&king.doublee(second(l1))
		case"2"
			I1=formatdate(l1,king_datetype)
		case else
			I1=replace(l2,"yyyy",year(l1))
			I1=replace(I1,"yy",right(year(l1),2))
			I1=replace(I1,"MM",king.doublee(month(l1)))
			I1=replace(I1,"dd",king.doublee(day(l1)))
			I1=replace(I1,"hh",king.doublee(hour(l1)))
			I1=replace(I1,"mm",king.doublee(minute(l1)))
			I1=replace(I1,"ss",king.doublee(second(l1)))
			I1=replace(I1,"M",month(l1))
			I1=replace(I1,"d",day(l1))
			I1=replace(I1,"h",hour(l1))
			I1=replace(I1,"m",minute(l1))
			I1=replace(I1,"s",second(l1))
		end select
		formatdate=I1
	end if
end function
'formattime  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function formattime(l1)
	dim I1,I2,I3
	if len(l1)>0 then
		I1=l1*1000
		if I1>=86400000 then
			I2=I1\86400000&"天"
			I3=I1 mod 86400000
			if I3>0 then I2=I2 & formattime(I3/1000)
		elseIf I1>=3600000 then
			I2=I1\3600000&"小时"
			I3=I1 mod 3600000
			if I3>0 then I2=I2 & formattime(I3/1000)
		elseif I1>=60000 then
			I2=I1\60000&"分钟"
			I3=I1 mod 60000
			if I3>0 then I2=I2 & formattime(I3/1000)
		elseif I1>=1000 then
			I2=I1\1000&"秒"
			I3=I1 mod 1000
			if I3>0 then I2=I2 & formattime(I3/1000)
		else
			I2=Round(I1)&"毫秒"
		end if
	end if
	formattime=I2
end function
'htmlencode  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function htmlencode(l1)
	on error resume next
	dim I2,I1,I3,I4,i
		I1=l1
		if len(I1)>0 then
			I3=split("quot,gt,lt,iexcl,cent,pound,curren,yen,brvbar,sect,uml,copy,ordf,laquo,not,shy,reg,macr,deg,plusmn,sup2,sup3,acute,micro,para,middot,cedil,sup1,ordm,raquo,frac14,frac12,frac34,iquest,agrave,aacute,acirc,atilde,auml,aring,aelig,ccedil,egrave,eacute,ecirc,euml,igrave,iacute",",")
			I4=split(""",>,<,¡,¢,£,¤,¥,¦,§,¨,©,ª,«,¬,­,®,¯,°,±,²,³,´,µ,¶,·,¸,¹,º,»,¼,½,¾,¿,À,Á,Â,Ã,Ä,Å,Æ,Ç,È,É,Ê,Ë,Ì,Í",",")
			set I2=new regexp
				I2.global=true
				I2.ignorecase=true'忽略大小写
				for i=0 to ubound(I3)
					I2.pattern=I4(i):I1=I2.replace(I1,"&"&I3(i)&";")
				next
			set I2=nothing
			htmlencode=I1
		end if
end function
'htmldecode  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function htmldecode(l1)
	on error resume next

	dim I1,I2,I3,I4,i
	I1=l1
	
	I3=split("quot,gt,lt,nbsp,iexcl,cent,pound,curren,yen,brvbar,sect,uml,copy,ordf,laquo,not,shy,reg,macr,deg,plusmn,sup2,sup3,acute,micro,para,middot,cedil,sup1,ordm,raquo,frac14,frac12,frac34,iquest,agrave,aacute,acirc,atilde,auml,aring,aelig,ccedil,egrave,eacute,ecirc,euml,igrave,iacute",",")
	I4=split(""",>,<, ,¡,¢,£,¤,¥,¦,§,¨,©,ª,«,¬,­,®,¯,°,±,²,³,´,µ,¶,·,¸,¹,º,»,¼,½,¾,¿,À,Á,Â,Ã,Ä,Å,Æ,Ç,È,É,Ê,Ë,Ì,Í",",")

		if len(I1)>0 then
			set I2=new regexp
				I2.global=true
				I2.ignorecase=true'忽略大小写
				for i=0 to ubound(I3)
					I2.pattern="&"&I3(i)&";":I1=I2.replace(I1,I4(i))
				next
			set I2=nothing
	
			htmldecode=I1
		end if
end function
'formencode  *** ***  www.KingCMS.com  *** ***
function formencode(l1)
	if len(l1)>0 then
		formencode=server.htmlencode(l1)
	end if
end function
'html2ubb  *** ***  www.KingCMS.com  *** ***
function html2ubb(l1)
	if len(trim(l1))>0 then
	else
		exit function
	end if
	dim l4,I1,I2,I3
	dim i,I4:I4=array(16,19,21,24,32,45)
	I1=l1
	set I2=new regexp
		I2.global=true
		I2.ignorecase=true'忽略大小写
		I2.pattern="/r":I1=I2.replace(I1,"")
		I2.pattern="on(load|click|dbclick|mouseover|mousedown|mouseup)=""[^""]+""":I1=I2.replace(I1,"")
		I2.pattern="<script[^>]*?>([\w\W]*?)<\/script>":I1=I2.replace(I1,"")
		I2.pattern="<a[^>]+href=""([^""]+)""[^>]*>(.*?)<\/a>":I1=I2.replace(I1,"[url=$1]$2[/url]")
		I2.pattern="<font[^>]+color=([^ >]+)[^>]*>(.*?)<\/font>":I1=I2.replace(I1,"[color=$1]$2[/color]")
		I2.pattern="<img[^>]+src=""([^""]+)""[^>]*>":I1=I2.replace(I1,"[img]$1[/img]")
		I2.pattern="<([\/]?)b>":I1=I2.replace(I1,"[$1b]")
		I2.pattern="<([\/]?)strong>":I1=I2.replace(I1,"[$1b]")
		I2.pattern="<([\/]?)u>":I1=I2.replace(I1,"[$1u]")
		I2.pattern="<([\/]?)i>":I1=I2.replace(I1,"[$1i]")
		I2.pattern="&nbsp;":I1=I2.replace(I1," ")
		I2.pattern="&amp;":I1=I2.replace(I1,"&")
		I2.pattern="&quot;":I1=I2.replace(I1,"""")
		I2.pattern="&lt;":I1=I2.replace(I1,"<")
		I2.pattern="&gt;":I1=I2.replace(I1,">")
		I2.pattern="<br />":I1=I2.replace(I1,vbcrlf)
		I2.pattern="<[^>]*?>":I1=I2.replace(I1,"")
		I2.pattern="\n+":I1=I2.replace(I1,vbcrlf)
	set I2=nothing
	html2ubb=I1
end function
'xmlencode  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function xmlencode(l1)
	on error resume next
	dim l2:l2=l1
	if len(l2)>0 then
		l2=replace(l2,"&","&amp;")
		l2=replace(l2,"'","&apos;")
		l2=replace(l2,"""","&quot;")
		l2=replace(l2,">","&gt;")
		l2=replace(l2,"<","&lt;")
		xmlencode=l2
	end if
end function
'htm2js  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function htm2js(l1)
	if len(l1)>0 then
		l1=replace(l1,"\","\\")
		l1=replace(l1,vbcrlf,"\n")
		l1=replace(l1,vbcr,"\n")
		l1=replace(l1,vblf,"\n")
		htm2js=replace(l1,"'","\'")
	end if
end function
'encode  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function encode(l1)
	dim l2
	if len(l1)>0 then
		l2=replace(l1,chr(123),"&#123;")
		l2=replace(l2,chr(125),"&#125;")
		l2=replace(l2,chr(58),chr(3)&"$king58"&chr(2))
		l2=replace(l2,chr(59),chr(3)&"$king59"&chr(2))
		l2=replace(l2,chr(124),chr(3)&"$king124"&chr(2))
	else
		l2=l1
	end if
	encode=l2
end function
'decode  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function decode(l1)
	dim l2
	if len(l1)>0 then
		l2=replace(l1,chr(3)&"$king58"&chr(2),chr(58))
		l2=replace(l2,chr(3)&"$king59"&chr(2),chr(59))
		l2=replace(l2,chr(3)&"$king124"&chr(2),chr(124))
		l2=replace(l2,"&#123;",chr(123))
		l2=replace(l2,"&#125;",chr(125))
	else
		l2=l1
	end if
	decode=l2
end function
'htmlcode  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function htmlcode(l1)
	dim l2
	on error resume next
	if len(l1)>0 then
		l2=replace(l1,">","&gt;")
		l2=replace(l2,"<","&lt;")
		l2=replace(l2,chr(32)&chr(32)," &nbsp;")
		l2=replace(l2,chr(9),"&nbsp;")
		l2=replace(l2,chr(34),"&quot;")
		l2=replace(l2,chr(39),"&#39;")
		l2=replace(l2,chr(13),"")
		l2=replace(l2,chr(10),"<br />")
		htmlcode=l2
	end if
end function
'keylight  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function keylight(l1,l2)
	dim bads,I1,I2,I3,i
	if len(l1)>0 and len(l2)>0 then
		I1=l1
		I2=split(l2,",")
			set I3=new regexp
				I3.global=true
				I3.ignorecase=true
				for i=0 to ubound(I2)
					if len(trim(I2(i)))>0 then
						I3.pattern="("&I2(i)&")"
						I1=I3.replace(I1,"<strong>$1</strong>")
					end if
				next
				keylight=I1
			set I3=nothing
	end if
end function
'removeutf8bom  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub removeutf8bom(l1)
	on error resume next
	dim I1,I2,I3,l2,l3
	I1=server.mappath(l1)
	set I2 = server.createobject(king_stm)
	with I2
		.type = 1
		.open()
		.loadfromfile I1
	end with
	set I3 = server.createobject(king_xmldom)
	set l3 = I3.createelement("file")
	with l3
		.datatype = "bin.base64"
		.nodetypedvalue = I2.read(3)
	end with
	if l3.text = "77u/" then
	I2.position = 3
	set l2 = server.createobject(king_stm)
	with l2
		.mode = 3
		.type = 1
		.open()
	end with
	I2.copyto(l2)
	l2.savetofile I1,2
	end if
	set I2 = nothing
	set l2 = nothing
	set l3 = nothing
	set I3 = nothing
end sub

%>