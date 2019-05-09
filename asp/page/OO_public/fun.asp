<%
class ooclass
private r_doc,r_path,r_thisver

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()
	dim rs,kversion

	r_path = "OO_public"

	r_thisver = 1.01

	if king.checkcolumn("kingoo")=false then install

	kversion=king.getsql("kingoo_config","kversion")
	if len(kversion)>0 then
		if r_thisver>kversion then update
	else
		update
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
public sub list()
	dim ooid,rs,ooname

	ooid=quest("ooid",2)
	if len(ooid)=0 then:ooid=form("ooid")

	Il "<h2>"
	Il lang("title")

	Il "<span class=""listmenu"">"

	if len(ooid)>0 then
		set rs=conn.execute("select ooname from kingoo where ooid="&ooid&";")
			if not rs.eof and not rs.bof then
				ooname=rs(0)
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
		Il "[<a href=""index.asp?action=field&ooid="&ooid&""">"&htmlencode(ooname)&"</a>"
		Il "<a href=""index.asp?action=ooedt&ooid="&ooid&""">"&lang("common/ooedt")&"</a>"
		Il "<a href=""index.asp?action=fieldedt&ooid="&ooid&""">"&lang("common/fieldedt")&"</a>]"
	end if

	Il "[<a href=""index.asp"">"&lang("common/list")&"</a>"
	Il "<a href=""index.asp?action=ooedt"">"&lang("common/add")&"</a>]"
	
	Il "</span>"

	Il "</span>"
	Il "</h2>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub update()
	king.head "admin",0
	dim sql
	if len(king.getsql("kingoo_config","kversion"))=0 then
		'kingoo_config
		sql="systemname nvarchar(10),"
		sql=sql&"kversion real not null default 1.01"
		conn.execute "create table kingoo_config ("&sql&")"
		conn.execute "insert into kingoo_config (systemname) values ('KingCMS')"
		'kingoo
		sql="iskeywords int not null default 1,"
		sql=sql&"isdescription int not null default 1,"
		sql=sql&"ispath int not null default 1"
		conn.execute "alter table kingoo add "&sql&" ;"
		conn.execute "update kingoo set iskeywords=1,isdescription=1,ispath=1;"
	end if

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub install()
	king.head "admin",0
	dim sql
	'kingoo 
		sql="ooid int not null identity primary key,"
		sql=sql&"ooorder int not null default 0,"'排序
		sql=sql&"ooname nvarchar(50),"'名称
		sql=sql&"oocolumn nvarchar(50),"'表名
		sql=sql&"ooabout nvarchar(250),"'功能描述
		sql=sql&"oohelp ntext,"'帮助
		sql=sql&"ooversion real not null default 1"'版本 每更新一次字段自动增加.0001
		conn.execute "create table kingoo ("&sql&")"

	'kingoo_field
		sql="fid int not null identity primary key,"
		sql=sql&"ooid int not null default 0,"
		sql=sql&"forder int not null default 0,"'排序

		sql=sql&"fname nvarchar(50),"'字段名称
		sql=sql&"ftitle nvarchar(100),"'字段标题

		sql=sql&"istype int not null default 0,"'字段类型
		sql=sql&"issearch int not null default 0,"'是否支持搜索
		sql=sql&"fcheck ntext,"'字段长度限定 1;6|0-1;4

		sql=sql&"foption ntext,"'分行键入选项
		sql=sql&"fdefault nvarchar(100),"'预设值 逗号分开

		sql=sql&"fsize int not null default 0,"'文本框样式 1 2 3 4
		sql=sql&"fwidth int not null default 0,"'长度
		sql=sql&"fheight int not null default 0,"

		sql=sql&"fuptype nvarchar(250)"'上传文件类型

		conn.execute "create table kingoo_field ("&sql&")"
end sub
'formatvbcr  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function formatvbcr(l1)
	if len(l1)=0 then exit function

	dim I1,I2,i
	I1=split(l1,chr(13)&chr(10))
	for i=0 to ubound(I1)
		if instr(I1(i),"|")>0 then
			if len(I2)>0 then
				I2=I2&chr(13)&chr(10)&I1(i)
			else
				I2=I1(i)
			end if
		end if
	next
	formatvbcr=I2
end function
'eval  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function eval(l1,l2)
	dim I1,I2,k
	if len(l2)>0 then
		I2=split(l2,",")
		for k=0 to ubound(I2)
			I1=I1&"	Il king.form_eval(""kc_"&l1&""","""&I2(k)&""")"&vbcrlf
		next
	end if
	eval=I1
end function
'check  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function check(l1,l2,l3)'formname,checkvalue,is(0:full 1:content)
	dim I1,I2,I5,i,I3
	I3=true
	if len(l2)>0 then
		I2=split(l2,chr(13)&chr(10))
		I1=""""
		for i=0 to ubound(I2)
			if len(I2(i))>0 then
				I5=split(I2(i),"|")
				if king.instre("1,2",ubound(I5)) then
					if len(I1)>2 then
						I1=I1&"&"";kc_"&l1&"|"&I5(0)&"|""&encode(kc.lang(""check/"&l1&(i+1)&"""))"
					else
						I1=I1&"kc_"&l1&"|"&I5(0)&"|""&encode(kc.lang(""check/"&l1&(i+1)&"""))"
					end if
					if cstr(ubound(I5))="2" then I1=I1&"&""|"&I5(2)&""""
					if king.instre("0,6",I5(0)) then I3=false
				end if
			end if
		next
		if len(I1)<3 then I1=""""""
	else
		I1=""""""
	end if
	if l3=0 then
		if I3 then'如果没有长度限定或不能为空的限制
			I1="if len(form(""kc_"&l1&"""))>0 then"&vbcrlf&"	Il king.check("&I1&")"&vbcrlf&"end if"&vbcrlf
		else
			I1="	Il king.check("&I1&")"&vbcrlf
		end if
	end if
	check=I1
end function
'option  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function options(l1,l2)'values i+10
	dim I1,I2,I3,i
	if len(l1)>0 then
		I1=split(l1,chr(13)&chr(10))
		for i=0 to ubound(I1)
			if len(I1(i))>0 then
				I2=split(I1(i),"|")
				if ubound(I2)=0 then
					I3=I3&"	if king.instre(data("&l2&",0),"""&I2(0)&""") then selected="" selected=""""selected"""""" else selected="""""&vbcrlf
					I3=I3&"	Il ""<option value="""""&I2(0)&"""""""&selected&"">"&I2(0)&"</option>"""&vbcrlf
				end if
				if ubound(I2)=1 then
					I3=I3&"	if king.instre(data("&l2&",0),"""&I2(0)&""") then selected="" selected=""""selected"""""" else selected="""""&vbcrlf
					I3=I3&"	Il ""<option value="""""&I2(0)&"""""""&selected&"">"&I2(1)&"</option>"""&vbcrlf
				end if
			end if
		next
	end if
	options=I3
end function
'radiocheck  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function radiocheck(l3,l1,l2,l4,l5)'formname values i+10 defaultvalue radio?check
	dim I1,I2,I3,i
	if len(l1)>0 then
		I1=split(l1,chr(13)&chr(10))
		for i=0 to ubound(I1)
			if len(I1(i))>0 then
				I2=split(I1(i),"|")
'				I3=I3&"	if len(kid)=0 then data("&l2&",0)="""&l4&""""&vbcrlf
				if ubound(I2)=0 then
					I3=I3&"	if king.instre(data("&l2&",0),"""&I2(0)&""") then checked="" checked=""""checked"""""" else checked="""""&vbcrlf
					I3=I3&"	Il ""<input type="""""&l5&""""" value="""""&I2(0)&""""" id="""""&l3&"_"&i&""""" name="""""&l3&"""""""&checked&"" /><span><label for="""""&l3&"_"&i&""""">"&I2(0)&"</label></span>"""&vbcrlf
				end if
				if ubound(I2)=1 then
					I3=I3&"	if king.instre(data("&l2&",0),"""&I2(0)&""") then checked="" checked=""""checked"""""" else checked="""""&vbcrlf
					I3=I3&"	Il ""<input type="""""&l5&""""" value="""""&I2(0)&""""" id="""""&l3&"_"&i&""""" name="""""&l3&"""""""&checked&"" /><span><label for="""""&l3&"_"&i&""""">"&I2(1)&"</label></span>"""&vbcrlf
				end if
			end if
		next
	end if
	radiocheck=I3
end function
'maxlength  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function maxlength(l1)
	dim I1,I2,i
	if len(l1)>0 then
		I1=king.match(l1,"6\|.+?\|\d+\-\d+")
		if len(I1)>0 then
			I2=split(I1,"|")(2)
			maxlength=split(I2,"-")(1)
		end if
	end if
end function


end class

%>