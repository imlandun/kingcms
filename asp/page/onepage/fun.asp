<%
class onepage
private r_doc,r_path,r_uptime

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()

	r_path="onepage"

	r_uptime=3'更新首页的时间

	if king.checkcolumn("kingonepage")=false then install
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
	dim query:query=quest("query",0)
	Il "<h2>"&one.lang("title")
	Il "<span class=""listmenu"">"
	Il "<a href=""index.asp"">["&king.lang("common/list")&"]</a>"
	Il "<a href=""index.asp?action=edt"">["&one.lang("common/add")&"]</a>"
	if len(query)>0 then
		Il "<kbd id=""search"">"
		Il "<input type=""text"" value="""&formencode(query)&""" onkeydown=""if(event.keyCode==13) {window.location='index.asp?query='+encodeURI(this.value); return false;}"" />"
		Il "</kbd>"
	else
		Il "<kbd id=""search""><a href=""javascript:;"" onclick=""gethtm('index.asp?action=insearch','search')"">["&king.lang("common/search")&"]</a></kbd>"
	end if
	Il "</span>"
	Il "</h2>"


end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createmap()
	if len(king.mapname)=0 then exit sub

	dim rs,i,data,outmap
	set rs=conn.execute("select onepath from kingonepage order by oneid desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			outmap="<?xml version=""1.0"" encoding=""UTF-8""?>"
			outmap=outmap&"<urlset xmlns="""&king_map_xmlns&""">"
			for i=0 to ubound(data,2)
				outmap=outmap&"<url>"
				outmap=outmap&"<loc>"&king.siteurl&king.inst&data(0,i)&"</loc>"
				outmap=outmap&"<priority>0.5</priority>"
				outmap=outmap&"</url>"
			next
			outmap=outmap&"</urlset>"
			king.savetofile "../../"&r_path&".xml",outmap
		end if
		rs.close
	set rs=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub create(l1)
	dim tmphtm,outhtm,i,sql,menupath,metainfo,rs,data,paths,path
	sql="onename,onetitle,onepath,onekeyword,onedescription,onecontent,onetemplate1,onetemplate2,oneid"'8

	set rs=conn.execute("select "&sql&" from kingonepage where oneid in ("&l1&");")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			redim data(7,-1)
		end if
		rs.close
	set rs=nothing

	for i=0 to ubound(data,2)
		tmphtm=king.read(data(6,i),r_path&"/"&data(7,i))

		king.clearvalue
		king.value "id",data(8,i)
		king.value "title",encode(htmlencode(data(1,i)))
		king.value "name",encode(htmlencode(data(0,i)))
		king.value "keywords",encode(htmlencode(data(3,i)))
		king.value "description",encode(htmlencode(data(4,i)))
		king.value "content",encode(data(5,i))
		king.value "path",encode(king.inst&data(2,i))
		king.value "guide",encode(htmlencode(data(0,i)))
		king.value "commentid",encode(r_path&"|"&data(8,i))'传递评论参数
		outhtm=king.create(tmphtm,king.invalue)


		if len(data(2,i))>0 then
			'判断是否为文件名，如果是文件名，则建立目录到上一级
			paths=split(data(2,i),"/")
			if instr(paths(ubound(paths)),".")>0 then'文件
				if instr(data(2,i),"/")>0 then
					path=left(data(2,i),(len(data(2,i))-len(paths(ubound(paths))))-1)
					king.createfolder "../../"&path
				end if
				king.savetofile "../../"&data(2,i),outhtm'创建文件
			else'目录
				king.createfolder "../../"&data(2,i)
				king.savetofile "../../"&data(2,i)&"/"&king_ext,outhtm'创建文件
			end if
		else'写首页
			king.savetofile "../../"&king_ext,outhtm
		end if
	next
	
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub install()
	king.head "admin",0
	dim sql
	'kingonepage 
	sql="oneid int not null identity primary key,"'id
	sql=sql&"oneorder int not null default 0,"'排序
	sql=sql&"onetitle nvarchar(100),"'标题
	sql=sql&"onepath nvarchar(100),"'路径
	sql=sql&"onename nvarchar(50),"'名称
	sql=sql&"onekeyword nvarchar(50),"'关键字
	sql=sql&"onedescription nvarchar(250),"'介绍
	sql=sql&"onecontent ntext,"'内容
	sql=sql&"onetemplate1 nvarchar(50),"'外部模板
	sql=sql&"onetemplate2 nvarchar(50)"'内部模板
	conn.execute "create table kingonepage ("&sql&")"
	'插入sitemap
	conn.execute "insert into kingsitemap (maploc,maplastmod) values ('"&r_path&"','"&tnow&"')"
	king.createmap
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function updatejs(l1,l2)
	dim I1
	I1="var datediff=getdom('"&king.page&"system/now.asp?datetime="&server.urlencode(tnow)&"');"
	if validate(l2,2) then
		I1=I1&"if(datediff>"&l2&"){getdom('"&king.page&"onepage/create.asp?listid="&server.urlencode(l1)&"&time="&l2&"');};"
	else
		I1=I1&"if(datediff>"&r_uptime&"){getdom('"&king.page&"onepage/create.asp?listid="&server.urlencode(l1)&"');};"
	end if
	updatejs=I1
end function

end class

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_onepage(tag,invalue)
	on error resume next
	dim rs,i,data,listid,insql_id1
	dim tmplist,jshtm,jslistid,zebra

	listid=king.getvalue(invalue,"listid")
	jshtm=king.getlabel(tag,0)
	jslistid=king.getlabel(tag,"listid")
	zebra=king.getlabel(tag,"zebra")

	if validate(jslistid,6) then
		insql_id1=" oneid in ("&jslistid&")"
	end if

	set rs=conn.execute("select onename,onetitle,onepath,onekeyword,onedescription,onecontent,oneid from kingonepage where"&insql_id1&" order by oneorder desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				king.clearvalue
				king.value "id",data(6,i)
				king.value "title",encode(htmlencode(data(1,i)))
				king.value "name",encode(htmlencode(data(0,i)))
				king.value "keywords",encode(htmlencode(data(3,i)))
				king.value "description",encode(htmlencode(data(4,i)))
				king.value "content",encode(data(5,i))
				king.value "path",encode(king.inst&data(2,i))
				king.value "zebra",king.mod2(i+1,zebra)

				tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量

			next
		end if
		rs.close
	set rs=nothing

	if err.number<>0 then
		err.clear
		tmplist=king.errtag(tag)
	end if

	king_tag_onepage=tmplist
	
end function

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_onepage_update(tag)
	dim t_class,listid,jstime
	listid=king.getlabel(tag,"listid")
	jstime=king.getlabel(tag,"time")
	king_tag_onepage_update="<script src="""&king.page&"onepage/update.js""></script>"
	set t_class=new onepage
		king.savetofile king.page&"onepage/update.js",t_class.updatejs(listid,jstime)'创建日期文件
	set t_class=nothing
end function

%>