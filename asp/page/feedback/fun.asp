<%
class feedback
private r_doc,r_path,r_template,r_count,r_thisver,r_fbshow

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()
	dim dbver,rs
	r_thisver = 1.01

	r_path = "feedback"'如果多个feedback共存，则需要修改这个参数和目录，以及admin和page目录下面的feedback改为r_path值。

	r_count = 3'一个IP留言次数不能超过设定值，以防暴库。

	if king.checkcolumn("king"&r_path)=false then
		install:update
	else
		on error resume next
		set rs=conn.execute("select kversion from king"&r_path&"_config where systemname='KingCMS'")
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
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get count
	count=r_count
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get path
	path=r_path
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get template
	if len(r_template)=0 then
		r_template=conn.execute("select fbtemplate from king"&r_path&"_config")(0)
	end if
	template=r_template
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get fbshow
	if len(r_fbshow)=0 then
		r_fbshow=conn.execute("select fbshow from king"&r_path&"_config")(0)
	end if
	fbshow=r_fbshow
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub list()
	Il "<h2>"
	Il lang("title")

	Il "<span class=""listmenu"">"
	Il "[<a href=""index.asp"">"&lang("common/list")&"</a>"
	Il "<a href=""index.asp?tag=1"">"&lang("common/tag")&"</a>]"
	Il "<a href=""javascript:;"" onclick=""gethtm('index.asp?action=template','flo')"">["&lang("common/template")&"]</a>"
	Il "<a href=""javascript:;"" onclick=""gethtm('index.asp?action=fbshow','flo')"">["&lang("label/isview")&"]</a>"
	Il "</span>"

	Il "</span>"
	Il "</h2>"

'	if king.checkcolumn("king"&r_path)=false then install

end sub
'install  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install()
	king.head "admin",0
	dim sql
	'kingfeedback
		sql="fbid int not null identity primary key,"
		sql=sql&"isview int not null default 0,"'是否阅读
		sql=sql&"istag int not null default 0,"'标记，做标记的不能删除，必须先去掉后才能删除。
		sql=sql&"fbtitle nvarchar(50),"'标题
		sql=sql&"fbname nvarchar(30),"
		sql=sql&"fbmail nvarchar(100),"
		sql=sql&"fbtel nvarchar(30),"
		sql=sql&"fbphone nvarchar(30),"
		sql=sql&"fbcontent ntext,"
		sql=sql&"fbip nvarchar(20),"
		sql=sql&"fbdate datetime"'添加时间
		conn.execute "create table king"&r_path&" ("&sql&");"
	'kingfeedback_config
		conn.execute "create table king"&r_path&"_config (fbtemplate nvarchar(50));"
		conn.execute "insert into king"&r_path&"_config (fbtemplate) values ('"&king_default_template&"')"
end sub
'update  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub update()
	dim sql
	on error resume next
	conn.execute "alter table king"&r_path&"_config add systemname nvarchar(10),kversion real not null default 1 , fbshow int not null default 0 ;"
	conn.execute "update king"&r_path&"_config set systemname='KingCMS',kversion=1,fbshow=0;"
	conn.execute "alter table king"&r_path&" add fbshow int not null default 0,fbreplyname nvarchar(30),fbreplycontent ntext,fbreplydate datetime;"
	conn.execute "update king"&r_path&" set fbshow=0;"
	conn.execute "update king"&r_path&"_config set kversion="&r_thisver&" where systemname='KingCMS';"
end sub

end class

%>