<!--#include file="../system/plugin.asp"-->
<%
dim oo
set king=new kingcms
king.checkplugin king.path '检查插件安装状态

set oo=new ooclass
	select case action
	case"" king_def
	case"edt" king_edt
	case"ooedt" king_ooedt
	case"set" king_set
	case"create" king_create
	case"up","down" king_updown
	case"field" king_field
	case"fieldedt" king_fieldedt
	case"fieldset" king_fieldset
	end select
set oo=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,oo.lang("title")
	dim rs,data,i,dp'lpath:linkpath
	dim but,sql

	oo.list

	sql="select ooid,ooname,oocolumn,ooversion from kingoo order by ooorder desc,ooid desc;"

	set dp=new record
		dp.create sql
		dp.but=dp.sect("create:"&encode(king.lang("common/create")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=field&ooid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a>'"
		dp.js="'<a href=""../'+K[2]+'"" target=""_blank"">'+K[2]+'</a>'"
		dp.js="'king__'+K[2]+'_page'"
		dp.js="K[3]"
		dp.js="edit('index.asp?action=ooedt&ooid='+K[0])+updown('index.asp?ooid='+K[0])"

		Il dp.open

		Il "<tr><th>"&oo.lang("list/id")&") "&oo.lang("list/name")&"</th><th>"&oo.lang("list/folder")&"</th><th>"&oo.lang("list/column")&"</th><th>"&oo.lang("list/version")&"</th><th class=""w2"">"&oo.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			
			Il "ll("&dp.data(0,i)&",'"&htm2js(htmlencode(dp.data(1,i)))&"','"&htm2js(htmlencode(dp.data(2,i)))&"','"&dp.data(3,i)&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.head king.path,0
	dim list,rs,data,i
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	select case form("submits")
	case"create" 
		if len(list)>0 then
			king_createoo list
			king.flo oo.lang("flo/createok"),0
		else
			king.flo oo.lang("flo/select"),0
		end if

	case"delete"
		if len(list)>0 then
			conn.execute "delete from kingoo where ooid in ("&list&");"
			conn.execute "delete from kingoo_field where ooid in ("&list&");"
			king.flo oo.lang("flo/deleteok"),1
		else
			king.flo oo.lang("flo/select"),0
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_fieldset()
	king.nocache
	king.head king.path,0
	dim list,rs,data,i,ooid
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	select case form("submits")
	case"delete"
		if len(list)>0 then
			set rs=conn.execute("select ooid from kingoo_field where fid in ("&list&");")
				if not rs.eof and not rs.bof then
					ooid=rs(0)
				else
					king.flo king.lang("error/invalid"),0
				end if
				rs.close
			set rs=nothing
			conn.execute "delete from kingoo_field where fid in ("&list&");"
			conn.execute "update kingoo set ooversion=ooversion+0.0001 where ooid="&ooid&";"'更新版本
			king.flo oo.lang("flo/deleteok"),1
		else
			king.flo oo.lang("flo/select"),0
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_create()
	king.nocache
	king.head king.path,0
	dim I1,ooid,rs
	ooid=quest("ooid",2)
	set rs=conn.execute("select ooid from kingoo where ooid="&ooid)
		if not rs.eof and not rs.bof then
			I1="<a href="""&king_system&"system/link.asp?url="&server.urlencode(king.inst&"/"&rs(0))&""" target=""_blank""><img src=""../system/images/os/brow.gif"" class=""os"" /></a>"
		else
			I1="<img src=""../system/images/os/error.gif"" class=""os""/>"
		end if
		rs.close
	set rs=nothing
	oo.create ooid
	king.txt I1
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_field()
	king.head king.path,oo.lang("common/field")
	dim rs,data,i,dp,ooid,oocolumn
	dim but,sql

	ooid=quest("ooid",2)

	oo.list

	sql="select fid,fname,ftitle,istype,ooid from kingoo_field where ooid="&ooid&" order by forder desc,fid desc;"

	set rs=conn.execute("select oocolumn from kingoo where ooid="&ooid&";")
		if not rs.eof and not rs.bof then
			oocolumn=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	set dp=new record
		dp.action="index.asp?action=fieldset"
		dp.purl="index.asp?action=field&pid=$&rn="&dp.rn&"&ooid="&ooid
		dp.create sql
		dp.but=dp.sect("")&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=fieldedt&istype='+K[3]+'&ooid='+K[4]+'&fid='+K[0]+'"" >'+K[0]+') '+K[2]+'</a>'"
		dp.js="'king__"&oocolumn&"_page'"
		dp.js="'kc_'+K[1]"
		dp.js="K[5]"
		dp.js="edit('index.asp?action=fieldedt&istype='+K[3]+'&ooid='+K[4]+'&fid='+K[0])+updown('index.asp?ooid="&ooid&"&fid='+K[0],'index.asp?action=field&ooid="&ooid&"')"

		Il dp.open

		Il "<tr><th>"&oo.lang("list/id")&") "&oo.lang("list/ftitle")&"</th><th>"&oo.lang("list/column")&"</th><th>"&oo.lang("list/fname")&"</th><th >"&oo.lang("list/istype")&"</th><th class=""w"">"&oo.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			Il "ll("&dp.data(0,i)&",'"&htm2js(htmlencode(dp.data(1,i)))&"','"&htm2js(htmlencode(dp.data(2,i)))&"',"&dp.data(3,i)&","&dp.data(4,i)&",'"&htm2js(oo.lang("form/obj"&dp.data(3,i)))&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_ooedt()
	king.head king.path,oo.lang("title")

	dim rs,data,dataform,sql,i,ooid
	dim checkcolumn,blname

	sql="ooname,oocolumn,ooabout,oohelp,iskeywords,isdescription,ispath"'6
	ooid=quest("ooid",2)
	if len(ooid)=0 then:ooid=form("ooid")
	if len(ooid)>0 then'若有值的情况下
		if validate(ooid,2)=false then king.error king.lang("error/invalid")
	end if
	
	if king.ismethod or len(ooid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if len(ooid)=0 and king.ismethod=false then
			data(4,0)=1:data(5,0)=1:data(6,0)=1
		end if
	else
		set rs=conn.execute("select "&sql&" from kingoo where ooid="&ooid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	oo.list
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=ooedt"">"

	king.form_input "ooname",oo.lang("label/name"),data(0,0),"ooname|6|"&encode(oo.lang("check/name"))&"|1-50"'ooname
	if len(ooid)>0 then
		checkcolumn=";oocolumn|9|"&encode(oo.lang("check/column2"))&"|select count(ooid) from kingoo where oocolumn='$pro$' and ooid<>"&ooid
	else
		checkcolumn=";oocolumn|9|"&encode(oo.lang("check/column2"))&"|select count(ooid) from kingoo where oocolumn='$pro$'"
	end if

	blname="edt,openlist,set,setlist,create,up,down,group,edtgroup,setgroup,tree,serch,aja,system,[model],title,listid,listname,sitename,url,cms,now,keywords,keyword,description,inst,page,rnd,rnd4,rnd8,guide,ad,king,kingcms,tnow,image,content,date"
	king.form_input "oocolumn",oo.lang("label/column"),data(1,0),(not king.instre(blname,data(1,0)))&"|13|"&encode(oo.lang("check/column3"))&";oocolumn|6|"&encode(oo.lang("check/column"))&"|1-50;oocolumn|3|"&encode(oo.lang("check/column1"))
	'iskeywords,isdescription,ispath
	king.form_radio "iskeywords",oo.lang("label/iskeywords"),"1:"&encode(oo.lang("common/show1"))&"|0:"&encode(oo.lang("common/show0")),data(4,0)
	king.form_radio "isdescription",oo.lang("label/isdescription"),"1:"&encode(oo.lang("common/show1"))&"|0:"&encode(oo.lang("common/show0")),data(5,0)
	king.form_radio "ispath",oo.lang("label/ispath"),"1:"&encode(oo.lang("common/show1"))&"|0:"&encode(oo.lang("common/show0")),data(6,0)
	'关于
	king.form_area "ooabout",oo.lang("label/about"),data(2,0),"ooabout|6|"&encode(oo.lang("check/about"))&"|0-250"&checkcolumn

	Il "<p><label>"&oo.lang("label/help")&"</label>"
	Il king.ubbshow("oohelp",data(3,0),80,18,1)
	Il "</p>"

	king.form_but "save"
	king.form_hidden "ooid",ooid

	Il "</form>"

'	sql="ooname,oocolumn,ooabout,oohelp"

	if king.ischeck and king.ismethod then
		if len(ooid)>0 then
			conn.execute "update kingoo set ooname='"&safe(data(0,0))&"',oocolumn='"&safe(data(1,0))&"',ooabout='"&safe(data(2,0))&"',oohelp='"&safe(data(3,0))&"',iskeywords="&safe(data(4,0))&",isdescription="&safe(data(5,0))&",ispath="&safe(data(6,0))&" where ooid="&ooid&";"
		else
			conn.execute "insert into kingoo ("&sql&",ooorder) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"',"&safe(data(4,0))&","&safe(data(5,0))&","&safe(data(6,0))&","&king.neworder("kingoo","ooorder")&")"
			ooid=king.newid("kingoo","ooid")
		end if
		Il "<script>confirm('"&htm2js(oo.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=fieldedt&ooid="&ooid&"'""):eval(""parent.location='index.asp'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_fieldedt()
	king.head king.path,oo.lang("common/field")

	dim rs,data,dataform,sql,i,ooid,oocolumn,fid
	dim selected,checked
	dim istype
	dim fnamecheck,blname'保留字

	set rs=conn.execute("select plugin from kingsystem where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			blname=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing
	if len(blname)>0 then
		blname=blname&","
	end if
	blname=blname&"title,listid,listname,sitename,url,cms,now,keywords,keyword,description,inst,page,rnd,rnd4,rnd8,guide,king,kingcms,tnow,date"

	fid=quest("fid",2)
	if len(fid)=0 then:fid=form("fid")
	if len(fid)>0 then'若有值的情况下
		if validate(fid,2)=false then king.error king.lang("error/invalid")
	end if
	istype=quest("istype",2)
	if len(istype)=0 then:istype=form("istype")
	if validate(istype,2)=false then istype=1
	ooid=quest("ooid",2)
	if len(ooid)=0 then:ooid=form("ooid")
	if len(ooid)>0 then'若有值的情况下
		if validate(ooid,2)=false then king.error king.lang("error/invalid")
	end if
	
	sql="istype,fname,ftitle,fcheck,foption,fdefault,fsize,fwidth,fheight,fuptype,issearch"'10

	if king.ismethod or len(fid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if len(fid)=0 and king.ismethod=false then
			data(9,0)=king_imgtype
		end if
	else
		set rs=conn.execute("select "&sql&" from kingoo_field where fid="&fid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	oo.list
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=fieldedt"">"

	'istype begin
	Il "<p><label>"&oo.lang("label/istype")&"</label>"
	if len(fid)=0 then
		Il "<select name=""set_istype"" id=""set_istype"" onChange=""jumpmenu(this);"">"
		for i=1 to 9
			if cstr(istype)=cstr(i) then selected=" selected=""selected""" else selected=""
			Il "<option value=""index.asp?action=fieldedt&ooid="&ooid&"&istype="&i&""""&selected&">"&oo.lang("form/obj"&i)&"</option>"
		next
	else
		Il "<select disabled=""true"">"
		Il "<option>"&oo.lang("form/obj"&istype)&"</option>"
	end if
	Il "</select>"
	Il "</p>"
	king.form_hidden "istype",istype
	'istype end

	if len(fid)>0 then
		Il "<p><label>"&oo.lang("label/fname")&"</label>"
		Il "<input type=""text"" name=""fname"" value="""&data(1,0)&""" class=""in4"" disabled=""true"" />"
		Il "</p>"
	else
		fnamecheck="fname|9|"&encode(oo.lang("check/fname2"))&"|select count(fid) from kingoo_field where ooid="&ooid&" and fname='$pro$'"
		king.form_input "fname",oo.lang("label/fname"),data(1,0),"fname|6|"&encode(oo.lang("check/fname"))&"|1-50;fname|8|"&encode(oo.lang("check/fname3"))&"|^[A-Za-z0-9\_]+$;"&(not king.instre(blname,data(1,0)))&"|13|"&encode(oo.lang("check/fname1"))&";"&fnamecheck'name
	end if

	king.form_input "ftitle",oo.lang("label/ftitle"),data(2,0),"ftitle|6|"&encode(oo.lang("check/ftitle"))&"|1-100"'title

	king.form_area "fcheck",oo.lang("label/fcheck"),data(3,0),""
	
'不同字段操作变动部分 开始

	if king.instre("4,5,6,7",istype) then
		king.form_area "foption",oo.lang("label/foption"),data(4,0),"foption|0|"&encode(oo.lang("check/foption"))
	end if

	if king.instre("1",istype) then
		king.form_input "fdefault",oo.lang("label/fdefault"),data(5,0),""
	end if
	if king.instre("4,5",istype) then
		king.form_input "fdefault",oo.lang("label/fdefault1"),data(5,0),"fdefault|0|"&encode(oo.lang("check/fdefault1"))
	end if
	if king.instre("6,7",istype) then
		king.form_input "fdefault",oo.lang("label/fdefault2"),data(5,0),"fdefault|0|"&encode(oo.lang("check/fdefault1"))
	end if

	if king.instre("1,9",istype) then
		king.form_select "fsize",oo.lang("label/fsize"),"1:50px|2:100px|3:200px|4:400px|5:600px",data(6,0)
	else
		king.form_hidden "fsize",0
	end if

	if king.instre("2,6",istype) then
		Il "<p><label>"&oo.lang("label/fwidth")&"</label>"
		Il "<input type=""text"" name=""fwidth"" value="""&data(7,0)&""" maxlength=""4"" class=""in1"" /> x "
		Il "<input type=""text"" name=""fheight"" value="""&data(8,0)&""" maxlength=""4"" class=""in1"" />"
		Il king.check("fwidth|2|"&encode(oo.lang("check/fwidth"))&";fheight|2|"&encode(oo.lang("check/fheight")))
		Il "</p>"
	else
		king.form_hidden "fwidth",0
		king.form_hidden "fheight",0
	end if

	if king.instre("8",istype) then
		king.form_input "fuptype",oo.lang("label/fuptype"),data(9,0),"fuptype|6|"&encode(oo.lang("check/ftitle"))&"|1-250"
	end if

	if king.instre("1,2",istype) then
		Il "<p>"
		Il "<label>"&oo.lang("label/attrib")&"</label><span>"
		if cstr(data(10,0))="1" then checked=" checked=""checked""" else checked=""
		Il "<input type=""checkbox"" value=""1"" name=""issearch"" id=""issearch"""&checked&"><label for=""issearch"">"&oo.lang("label/search")&"</label> "
		Il "</span></p>"
	else
		king.form_hidden "issearch",0
	end if

'不同字段操作变动部分 结束
	king.form_but "save"
	king.form_hidden "ooid",ooid
	king.form_hidden "fid",fid

	Il "</form>"

	if king.ischeck and king.ismethod then
		if cstr(data(10,0))="" then data(10,0)=0
		if len(fid)>0 then
			conn.execute "update kingoo_field set ftitle='"&safe(data(2,0))&"',fcheck='"&safe(data(3,0))&"',foption='"&safe(data(4,0))&"',fdefault='"&safe(data(5,0))&"',fsize="&safe(data(6,0))&",fwidth="&safe(data(7,0))&",fheight="&safe(data(8,0))&",fuptype='"&safe(data(9,0))&"',issearch="&safe(data(10,0))&" where fid="&fid&";"
		else
			conn.execute "insert into kingoo_field ("&sql&",ooid,forder) values ("&safe(data(0,0))&",'"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&safe(data(5,0))&"',"&safe(data(6,0))&","&safe(data(7,0))&","&safe(data(8,0))&",'"&safe(data(9,0))&"',"&safe(data(10,0))&","&ooid&","&king.neworder("kingoo_field","forder")&")"

			conn.execute "update kingoo set ooversion=ooversion+0.0001 where ooid="&ooid&";"'更新版本
		end if
		Il "<script>confirm('"&htm2js(oo.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=fieldedt&ooid="&ooid&"'""):eval(""parent.location='index.asp?action=field&ooid="&ooid&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_updown()
	king.head king.path,0

	dim ooid,fid
	ooid=quest("ooid",2)
	fid=quest("fid",2)

	if len(fid)>0 then
		king.updown "kingoo_field,fid,forder",fid,"ooid="&ooid
	else
		king.updown "kingoo,ooid,ooorder",ooid,0
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_createoo(l1)
	dim rs,dataoo,data,i,irs,idata,j,k,sql
	dim ooid,fid
	dim I1,I2,I3
	dim langfile,langlabel,langcheck
	dim sitemail
	dim I4,I5
	dim uptxt
	dim field,snapimg,is3
	dim tmphtm,snapcontent
	dim snapfield
	dim searchfield
	dim fieldhtml
	dim fdefault

	sql="ooid,ooname,oocolumn,ooabout,oohelp,ooversion,iskeywords,isdescription,ispath"'8

	set rs=conn.execute("select "&sql&" from kingoo where ooid in ("&l1&");")
		if not rs.eof and not rs.bof then
			dataoo=rs.getrows()
		else
			exit sub
		end if
		rs.close
	set rs=nothing

	sql="istype,fname,ftitle,fcheck,issearch,foption,fdefault,fsize,fwidth,fheight,fuptype"'10

	for j=0 to ubound(dataoo,2)
	'初始化数据
		ooid=dataoo(0,j)

		set rs=conn.execute("select "&sql&" from kingoo_field where ooid="&ooid&" order by forder desc;")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				redim data(0,-1)
			end if
			rs.close
		set rs=nothing

	'创建模块目录
		king.createfolder "../"&dataoo(2,j)
		king.createfolder king_system&dataoo(2,j)

	'创建模块asp文件 开始
		uptxt=""
		for i=0 to ubound(data,2)
			if king.instre("2,3",data(0,i)) then
				uptxt=uptxt&"	conn.execute ""alter table king__"&dataoo(2,j)&"_page add kc_"&data(1,i)&" ntext """&vbcrlf
			else
				uptxt=uptxt&"	conn.execute ""alter table king__"&dataoo(2,j)&"_page add kc_"&data(1,i)&" nvarchar(255) """&vbcrlf
			end if
		next

		'admin目录
		I2=array("index.asp")

		field="":is3=false:snapcontent="":snapfield="":fieldhtml=""
		king.clearol

		for i=0 to ubound(data,2)

			'项目列表
			if len(field)>0 then
				field=field&",kc_"&data(1,i)
			else
				field="kc_"&data(1,i)
			end if

			'判断是否有html编辑器
			if cstr(data(0,i))="3" then is3=true

			'项目显示
			king.ol="	'"&data(1,i)&vbcrlf
			select case cstr(data(0,i))
			case"1"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label><input maxlength="""""&oo.maxlength(data(3,i))&""""" type=""""text"""" name=""""kc_"&data(1,i)&""""" id=""""kc_"&data(1,i)&""""" value=""""""&formencode(data("&(i+10)&",0))&"""""" class=""""in"&data(7,i)&""""" />"""&vbcrlf
				king.ol=oo.eval(data(1,i),data(6,i))
				king.ol=oo.check(data(1,i),data(3,i),0)
				king.ol="	Il ""</p>"""&vbcrlf
			case"2"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label><textarea name=""""kc_"&data(1,i)&""""" id=""""kc_"&data(1,i)&""""" style=""""width:"&data(8,i)&"px;height:"&data(9,i)&"px;"""">""&formencode(data("&(i+10)&",0))&""</textarea>"""&vbcrlf
				king.ol=oo.check(data(1,i),data(3,i),0)
				king.ol="	Il ""</p>"""&vbcrlf
			case"3"
				king.ol="	Il king.form_editor(""kc_"&data(1,i)&""",kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i>"",data("&(i+10)&",0),"&oo.check(data(1,i),data(3,i),1)&")"&vbcrlf
				snapcontent=snapcontent&"		if cstr(form(""snapimg""))=""1"" or cstr(form(""snapimg""))="""" then data("&i+10&",0)=king.snap(data("&i+10&",0))"&vbcrlf
				if len(fieldhtml)>0 then
					fieldhtml=fieldhtml&",kc_"&data(1,i)
				else
					fieldhtml="kc_"&data(1,i)
				end if
			case"4"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label>"""&vbcrlf
				king.ol="	Il ""<select name=""""kc_"&data(1,i)&""""" id=""""kc_"&data(1,i)&""""">"""&vbcrlf
				king.ol=oo.options(data(5,i),i+10)
				king.ol="	Il ""</select>"""&vbcrlf
				king.ol=oo.check(data(1,i),data(3,i),0)
				king.ol="	Il ""</p>"""&vbcrlf
				fdefault=fdefault&"			data("&i+10&",0)="""&data(6,i)&""""&vbcrlf
			case"5"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label>"""&vbcrlf
				king.ol=oo.radiocheck("kc_"&data(1,i),data(5,i),i+10,data(6,i),"radio")
				king.ol=oo.check(data(1,i),data(3,i),0)
				king.ol="	Il ""</p>"""&vbcrlf
				fdefault=fdefault&"			data("&i+10&",0)="""&data(6,i)&""""&vbcrlf
			case"6"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label>"""&vbcrlf
				king.ol="	Il ""<select name=""""kc_"&data(1,i)&""""" id=""""kc_"&data(1,i)&""""" multiple=""""multiple"""" style=""""width:"&data(8,i)&"px;height:"&data(9,i)&";"""">"""&vbcrlf
				king.ol=oo.options(data(5,i),i+10)
				king.ol="	Il ""</select>"""&vbcrlf
				king.ol=oo.check(data(1,i),data(3,i),0)
				king.ol="	Il ""</p>"""&vbcrlf
				fdefault=fdefault&"			data("&i+10&",0)="""&data(6,i)&""""&vbcrlf
			case"7"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label>"""&vbcrlf
				king.ol=oo.radiocheck("kc_"&data(1,i),data(5,i),i+10,data(6,i),"checkbox")
				king.ol=oo.check(data(1,i),data(3,i),0)
				king.ol="	Il ""</p>"""&vbcrlf
				fdefault=fdefault&"			data("&i+10&",0)="""&data(6,i)&""""&vbcrlf
			case"8"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label><input maxlength="""""&oo.maxlength(data(3,i))&""""" type=""""text"""" name=""""kc_"&data(1,i)&""""" id=""""kc_"&data(1,i)&""""" value=""""""&formencode(data("&(i+10)&",0))&"""""" class=""""in4"""" />"""&vbcrlf
				king.ol="	king.form_brow ""kc_"&data(1,i)&""","""&data(10,i)&""""&vbcrlf
				king.ol=oo.check(data(1,i),data(3,i),0)
				king.ol="	Il ""</p>"""&vbcrlf
				if len(snapfield)>0 then
					snapfield=snapfield&","&(i+10)
				else
					snapfield=snapfield&(i+10)
				end if
			case"9"
				king.ol="	Il ""<p><label>""&kc.lang(""label/"&data(1,i)&""")&""<i>{king:"&data(1,i)&"/}</i></label><input maxlength="""""&oo.maxlength(data(3,i))&""""" type=""""text"""" name=""""kc_"&data(1,i)&""""" id=""""kc_"&data(1,i)&""""" value=""""""&formencode(data("&(i+10)&",0))&"""""" class=""""in"&data(7,i)&""""" />"""&vbcrlf
				king.ol=oo.check(data(1,i),data(3,i),0)&vbcrlf
				king.ol="	Il king.form_eval(""kc_"&data(1,i)&""",now())"&vbcrlf
				king.ol="	Il ""</p>"""&vbcrlf
			end select


		next

		if is3 then
			snapimg="if cstr(form(""snapimg""))=""1"" then checked="" checked=""""checked"""""" else checked="""""&vbcrlf&chr(9)&"Il ""<input type=""""checkbox"""" value=""""1"""" name=""""snapimg"""" id=""""snapimg""""""&checked&""><label for=""""snapimg"""">""&kc.lang(""label/snapimg"")&""</label> """&vbcrlf
		else
			snapimg=""
		end if

		redim I1(ubound(I2))
		for i=0 to ubound(I2)
			I1(i)=king.readfile("code/admin/"&I2(i))'分别读取值保存到I1数组中
			I1(i)=replace(I1(i),"{OO}",dataoo(2,j))
			
			I1(i)=replace(I1(i),"{FIELD}",field)
			I1(i)=replace(I1(i),"{SNAPIMG}",snapimg)
			I1(i)=replace(I1(i),"{SNAPFIELD}",snapfield)
			if king.instre("index.asp",I2(i)) then
				I1(i)=replace(I1(i),"{FORM}",king.writeol)
				I1(i)=replace(I1(i),"{SNAPCONTENT}",snapcontent)
				I1(i)=replace(I1(i),"{FDEFAULT}",fdefault)
				I1(i)=replace(I1(i),"{FIS}",dataoo(6,j)&","&dataoo(7,j)&","&dataoo(8,j))
			end if

			king.savetofile "../"&dataoo(2,j)&"/"&I2(i),I1(i)
		next

		'page目录
		I3=array("fun.asp","page.asp","search.asp","tag.inc")

		searchfield="ktitle,kdescription"
		'搜索选项
		set irs=conn.execute("select fname from kingoo_field where issearch=1 and ooid="&ooid&" order by forder desc;")
			if not irs.eof and not irs.bof then
				idata=irs.getrows()
				for i=0 to ubound(idata,2)
					searchfield=searchfield&","&idata(0,i)
				next
			end if
			irs.close
		set irs=nothing

		redim I1(ubound(I3))
		for i=0 to ubound(I3)
			I1(i)=king.readfile("code/page/"&I3(i))'分别读取值保存到I1数组中
			I1(i)=replace(I1(i),"{OO}",dataoo(2,j))
			I1(i)=replace(I1(i),"{SEARCHFIELD}",searchfield)
			I1(i)=replace(I1(i),"{UPDATE}",uptxt)
			I1(i)=replace(I1(i),"{VER}",dataoo(5,j))
			I1(i)=replace(I1(i),"{FIELD}",field)
			I1(i)=replace(I1(i),"{FIELDHTML}",fieldhtml)
			king.savetofile king_system&dataoo(2,j)&"/"&I3(i),I1(i)
		next

	'创建模块asp文件 结束


	'创建模块xml语言包文件
		if king.isexist("code/page/language/"&king.language&".xml") then
			langfile=king.readfile("code/page/language/"&king.language&".xml")
		else
			langfile=king.readfile("code/page/language/"&king_language&".xml")
		end if

		sitemail=conn.execute("select sitemail from kingsystem where systemname='KingCMS';")(0)
		if len(sitemail)>0 then sitemail="<mail>"&xmlencode(sitemail)&"</mail>" else sitemail=""

		langlabel="":langcheck=""
		for i=0 to ubound(data,2)
			'设置langlabel
			langlabel=langlabel&"<"&data(1,i)&">"&xmlencode(data(2,i))&"</"&data(1,i)&">"&vbcrlf&chr(9)&chr(9)
			'设置langcheck
			I4=split(oo.formatvbcr(data(3,i)),chr(13)&chr(10))'先格式化fcheck
			if ubound(I4)>=0 then
				for k=0 to ubound(I4)
					I5=split(I4(k),"|")
					if king.instre("1,2",ubound(I5)) then
						langcheck=langcheck&"<"&data(1,i)&(k+1)&">"&xmlencode(I5(1))&"</"&data(1,i)&(k+1)&">"
						langcheck=langcheck&vbcrlf&chr(9)&chr(9)
					end if
				next
			end if
		next

		langfile=replace(langfile,"<title/>","<title>"&xmlencode(dataoo(1,j))&"</title>")
		langfile=replace(langfile,"<author/>","<author>"&xmlencode(king.name)&"</author>")
		langfile=replace(langfile,"<source/>","<source>"&xmlencode(king.siteurl)&"</source>")
		langfile=replace(langfile,"<mail/>",sitemail)
		langfile=replace(langfile,"<version/>","<version>"&dataoo(5,j)&"</version>")
		langfile=replace(langfile,"<label/>",langlabel)
		langfile=replace(langfile,"<check/>",langcheck)

		king.savetofile king_system&dataoo(2,j)&"/language/"&king.language&".xml",langfile

	'拷贝模块inside内部模板,这里需要增加判断，若有对应的目录，则无需拷贝，以免覆盖
		if king.isexist("../../"&king_templates&"/inside/"&dataoo(2,j)&"[page]/"&king_default_template)=false then
			king.createfolder "../../"&king_templates&"/inside/"&dataoo(2,j)&"[page]"
			king.copyfile "inside/page.htm","../../"&king_templates&"/inside/"&dataoo(2,j)&"[page]/"&king_default_template

			tmphtm=king.readfile("inside/list.htm"):tmphtm=replace(tmphtm,"COLUMN",dataoo(2,j))
			king.savetofile "../../"&king_templates&"/inside/"&dataoo(2,j)&"[list]/"&king_default_template,tmphtm
		end if

	'创建帮助和关于
		if len(dataoo(3,j))>0 then 'about
			king.savetofile king_system&dataoo(2,j)&"/Help/about.htm",dataoo(3,j)
		end if

		if len(dataoo(4,j))>0 then 'help

			king.savetofile king_system&dataoo(2,j)&"/Help/help.htm",dataoo(4,j)
		end if


	next


end sub

%>