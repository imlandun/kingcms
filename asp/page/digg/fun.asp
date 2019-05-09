<%
class diggclass
private r_doc,r_path,r_time,r_thisver

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()
	dim rs

	r_thisver=1.1
	
	r_path = "digg"

	r_time = 86400 '两次DIGG的时间 单位(秒)

	if king.checkcolumn("kingdigg")=false then
		install:update
	else
		on error resume next
		set rs=conn.execute("select kversion from kingdigg_config where systemname='KingCMS'")
			if not rs.eof and not rs.bof then
				dbver=rs(0)
			end if
			rs.close
		set rs=nothing
		if r_thisver>dbver then update
		if err.number<>0 then update
	end if

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function lang(l1)
	on error resume next
	if isobject(r_doc)=false then
		set r_doc=Server.CreateObject(king_xmldom)
		r_doc.async=false
		'判断是否存在所设置的语言包,如果没有就调用默认设置的语言包
		if king.isexist(king_system&r_path&"/language/"&king.language&".xml") then
			r_doc.load(server.mappath(king_system&r_path&"/language/"&king.language&".xml"))
		else
			r_doc.load(server.mappath(king_system&r_path&"/language/"&king_language&".xml"))
		end if
	end if
	lang=r_doc.documentElement.SelectSingleNode("//kingcms/"&l1).text
	if err.number<>0 then
		lang="["&l1&"]"
		err.clear
	end if
end function
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get path
	path=r_path
end property
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get time
	time=r_time
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get ip
	dim I1,I2,i
	I1=split(king.ip,".")
	for i=0 to ubound(I1)-1
		I2=I2&right("00"&cstr(I1(i)),3)
	next
	ip=I2
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub log(l1,l2)'日志
	'if king_dbtype=1 then conn.execute("set IDENTITY_INSERT kingdigg_log on") 
	if conn.execute("select count(*) from kingdigg_log  where ip="&kc.ip&" and  kplugin='"&safe(l1)&"' and kid="&l2&";")(0)>0 then
		conn.execute "update kingdigg_log set kdate='"&tnow&"',kplugin='"&safe(l1)&"',kid="&safe(l2)&"  where ip="&kc.ip&" and  kplugin='"&safe(l1)&"' and kid="&l2&";"
	else
		conn.execute "insert into kingdigg_log (ip,kplugin,kid,kdate) values ("&kc.ip&",'"&safe(l1)&"',"&safe(l2)&",'"&tnow&"')"
	end if
	'if king_dbtype=1 then conn.execute("set IDENTITY_INSERT kingdigg_log off") 
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function judge(l1,l2)'判断发帖时间，现在重复发帖
	dim rs,data

	set rs=conn.execute("select kdate,kid,kplugin from kingdigg_log  where ip="&kc.ip&" and  kplugin='"&safe(l1)&"' and kid="&l2&";")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			
			if datediff("s",data(0,0),tnow)>r_time then
				judge=true
			else
					'if cstr(l2)=cstr(data(1,0))  and cstr(l1)=cstr(data(2,0)) then
						judge=false
					'else
						'judge=true
					'end if
			end if
		else
			judge=true
		end if
		rs.close
	set rs=nothing

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install()
	dim sql
	'kingdigg_log
	sql="id int not null identity primary key,"
	sql=sql&"ip int not null,"'IP地址
	sql=sql&"kplugin nvarchar(50),"'模块名称
	sql=sql&"kid int not null default 0,"'对应模块的id
	sql=sql&"kdate datetime"'最后一次添加时间
	conn.execute "create table kingdigg_log ("&sql&")"
	'kingdigg
	sql="id int not null identity primary key,"
	sql=sql&"kplugin nvarchar(50),"'模块名称
	sql=sql&"kid int not null default 0,"'对应模块的id
	sql=sql&"digg0 int not null default 0,"
	sql=sql&"digg1 int not null default 0,"
	sql=sql&"digg2 int not null default 0,"
	sql=sql&"digg3 int not null default 0,"
	sql=sql&"digg4 int not null default 0"
	conn.execute "create table kingdigg ("&sql&")"
	'kingdigg_config
	sql="systemname nvarchar(10),"
	sql=sql&"kversion real not null default 1"
	conn.execute "create table kingdigg_config ("&sql&")"
	conn.execute "insert into kingdigg_config (systemname) values ('KingCMS');"
end sub
'update  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub update()
	dim sql
	on error resume next

	if king.checkcolumn("kingdigg_config")=false then
		conn.execute "create table kingdigg_config (systemname nvarchar(10),kversion real not null default 1)"
		conn.execute "insert into kingdigg_config (systemname) values ('KingCMS');"
		conn.execute "drop table kingdigg_log;"
		'kingdigg_log
		sql="id int not null identity primary key,"
		sql=sql&"ip int not null,"'IP地址
		sql=sql&"kplugin nvarchar(50),"'模块名称
		sql=sql&"kid int not null default 0,"'对应模块的id
		sql=sql&"kdate datetime"'最后一次添加时间
		conn.execute "create table kingdigg_log ("&sql&")"
	end if

	conn.execute "update kingdigg_config set kversion="&r_thisver&" where systemname='KingCMS';"
end sub

end class

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_digg(tag,invalue)

	on error resume next

	dim commentid,jsitem
	dim I1,I2,i

	commentid=king.getvalue(invalue,"commentid")
	jsitem=king.getlabel(tag,"item")


	if validate(commentid,"^[A-Za-z0-9\_\-]*\|\d+$") and len(jsitem)>0 then
		I1="<div id=""k_digg"">"
		I2=split(jsitem,"|")
		for i=0 to ubound(I2)
			I1=I1&"<span><a id=""k_digg"&i&""" href=""javascript:;"" onclick=""posthtm('"&king.page&"digg/index.asp','k_digg"&i&"','n="&ubound(I2)&"&c="&server.urlencode(commentid)&"&i="&i&"',0)"">"&I2(i)&"</a></span>"
		next
		I1=I1&"</div>"

		if ubound(I2)>4 then
			king_tag_digg=king.errtag(tag)
			exit function
		end if
	end if

	if len(I1)=0 or err.number<>0 then
		king_tag_digg=king.errtag(tag)
	else
		king_tag_digg=I1
	end if
end function
%>