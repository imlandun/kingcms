<%
class advertising
private r_doc,r_path,r_filepath,r_uptime,r_fileext

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()

	r_path = "ad"

	r_filepath = "adfile" '广告文件存储目录名称

	r_fileext = ".htm"

	r_uptime = 12 '每12个小时自动更新,用js读取修改时间，然后激活生成

	if king.checkcolumn("kingad")=false then install
end sub
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get ext
	ext=r_fileext
end property
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get path
	path=r_filepath
end property
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
	Il "<h2>"&lang("title")


	Il "<span class=""listmenu"">"
	Il "<a href=""index.asp"">["&lang("common/list")&"]</a>"
	Il "<span id=""ad_add""><a href=""index.asp?action=edt"">["&lang("common/add")&"]</a></span>"

	Il "</span>"
	Il "</h2>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub create(l1)
	dim rs,i,data,sql
	dim outhtm,outjs
	sql="adname,adtext"

	if cstr(l1)="*" then
		sql="select "&sql&" from kingad where istag=1;"
	else
		sql="select "&sql&" from kingad where adid in ("&l1&");"
	end if

	set rs=conn.execute(sql)
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			redim data(1,-1)
		end if
		rs.close
	set rs=nothing

	for i=0 to ubound(data,2)
		outhtm=king.create(king.formatpath(data(1,i)),"")
		outjs=html2js(outhtm)
		king.createfolder "../../"&r_filepath
		king.savetofile "../../"&r_filepath&"/"&data(0,i)&r_fileext,outhtm'创建文件
		king.savetofile "../../"&r_filepath&"/"&data(0,i)&".js",outjs'创建文件
		removeutf8bom "../../"&r_filepath&"/"&data(0,i)&r_fileext'清理BOM
		removeutf8bom "../../"&r_filepath&"/"&data(0,i)&".js"'清理BOM
	next

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install()
	king.head "admin",0
	dim sql
	'kingad 
		sql="adid int not null identity primary key,"
		sql=sql&"adorder int not null default 0,"'广告排序
		sql=sql&"adname nvarchar(50),"'广告名称,或标志
		sql=sql&"adtitle nvarchar(250),"'广告说明
		sql=sql&"adtext ntext,"'广告内容
		sql=sql&"istag int not null default 0,"'1支持标签
		sql=sql&"adwidth int not null default 0,"'宽度
		sql=sql&"adheight int not null default 0,"'高度
		sql=sql&"addate datetime"'添加时间
		conn.execute "create table kingad ("&sql&")"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function updatejs(l1)
	dim I1
	I1="var datediff=getdom('"&king.page&"system/now.asp?datetime="&server.urlencode(tnow)&"');"
	if validate(l1,2) then
		I1=I1&"if(datediff>"&l1&"){getdom('"&king.page&r_path&"/create.asp?time="&l1&"');};"
	else
		I1=I1&"if(datediff>"&r_uptime&"){getdom('"&king.page&r_path&"/create.asp');};"
	end if
	updatejs=I1
end function


end class







'html2js
function html2js(htmls)
	Dim tmpstr,tmpstr1,i
	tmpstr=Replace(htmls,"\","\\")
	tmpstr=Replace(tmpstr,"/","\/")
	tmpstr=Replace(tmpstr,"'","\'")
	tmpstr=Replace(tmpstr,"""","\""")
	tmpstr=Split(tmpstr,vbcrlf)
	For i=0 To UBound(tmpstr)
		If i<>UBound(tmpstr) then
			tmpstr1=tmpstr1&tmpstr(i)&""");"&vbcrlf&"document.writeln("""
		Else
			tmpstr1=tmpstr1&tmpstr(i)
		End if
	Next
	html2js="document.writeln("""&tmpstr1&""")"
End Function

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_ad(tag,invlaue)
	on error resume next
	dim adname,adtype,I1,rs,t_ad,errtext
	adname=king.getlabel(tag,"name")
	adtype=king.getlabel(tag,"type")
	errtext=king.errtag(tag)
	if validate(adname,3)=false then
		king_tag_ad=errtext
		exit function'验证name值必须为英文字母和数字构成
	end if

	set t_ad=new advertising

	set rs=conn.execute("select adwidth,adheight,adtext,adid from kingad where adname='"&safe(adname)&"';")
		if not rs.eof and not rs.bof then

			if king.isexist("../../"&t_ad.path&"/"&adname&t_ad.ext)=false then'若文件不存在，则需要生成。
				t_ad.create rs(3)
			end if

			select case lcase(adtype)
			case"js"
				I1="<span id=""k_ad_"&adname&"""></span><script type=""text/javascript"">gethtm('"&king.inst&t_ad.path&"/"&adname&t_ad.ext&"','k_ad_"&adname&"');</script>"
			case"jscode"
				I1="<script type=""text/javascript"" src="""&king.inst&t_ad.path&"/"&adname&".js"&"""></script>"
			case"ssi"
				I1="<!-- #include virtual="""&king.inst&t_ad.path&"/"&adname&t_ad.ext&""" -->"
			case"iframe"
				I1="<iframe frameborder=""0"" id=""k_ad_"&adname&""" scrolling=""no"" width="""&rs(0)&""" height="""&rs(1)&""" src="""&king.inst&t_ad.path&"/"&adname&t_ad.ext&"""></iframe>"
			case else
				if instr(lcase(rs(2)),"{king:")>0 then
					I1=king.create(king.formatpath(rs(2)),"")
				else
					I1=rs(2)
				end if
			end select
		else
			I1="广告位招租，广告代号："&adname
		end if
		rs.close
	set rs=nothing

	set t_ad=nothing

	king_tag_ad=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_ad_update(tag)
	dim t_ad,jstime
	jstime=king.getlabel(tag,"time")
	set t_ad=new advertising
		king_tag_ad_update="<script src="""&king.inst&t_ad.path&"/update.js""></script>"
		king.savetofile "../../"&t_ad.path&"/update.js",t_ad.updatejs(jstime)'创建日期文件
	set t_ad=nothing
end function

%>