<%
class easyarticle
private r_path,r_doc,r_initially

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()

	r_path = "EasyArticle"

	r_initially = "t"

	if king.checkcolumn("kingeasyart")=false then install
end sub
'  *** Copyr ight &copy KingCMS.com All Rights Reserved ***
public property get initially :initially=r_initially:end property
'  *** Copyr ight &copy KingCMS.com All Rights Reserved ***
public property get path :path=r_path:end property
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
public sub createpage(l1)
	dim tmphtm,outhtm,i,j,sql,rs,data
	dim listid,datalist,contents,artfrom
	sql="artid,listid,arttitle,artcontent,artfrom,artkeywords,artdescription,artdate"'7
	
	set rs=conn.execute("select "&sql&" from kingeasyart where artid in ("&l1&");")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			redim data(7,-1)
		end if
		rs.close
	set rs=nothing

	for i=0 to ubound(data,2)
		if cstr(data(1,i))<>cstr(listid) then
			set rs=conn.execute("select listname,listpath,pagetemplate1,pagetemplate2 from kingeasyart_list where listid="&data(1,i)&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
					listid=data(1,i)
					tmphtm=king.read(datalist(2,0),r_path&"[page]/"&datalist(3,0))
				end if
				rs.close
			set rs=nothing
		end if

		contents=split(king.pagebreak(data(3,i)),king_break)

		for j=0 to ubound(contents)
		
			king.clearvalue
			king.value "artid",data(0,i)
			king.value "listid",data(1,i)
			king.value "title",encode(htmlencode(data(2,i)))
			king.value "content",encode(contents(j))
			if instr(data(4,i),"|")>0 then
				artfrom=split(data(4,i),"|")
				king.value "from",encode("<a href="""&artfrom(1)&""">"&htmlencode(artfrom(0))&"</a>")
			else
				king.value "from",encode(htmlencode(data(4,i)))
			end if
			king.value "keywords",encode(htmlencode(data(5,i)))
			king.value "description",encode(htmlencode(data(6,i)))
			king.value "date",encode(htmlencode(data(7,i)))
			king.value "path",encode(king.inst&datalist(1,0)&"/"&initially&data(0,i))
			king.value "pagelist",encode(pageslist(king.inst&datalist(1,0)&"/"&initially&data(0,i),j+1,ubound(contents)+1))
			king.value "guide",encode("<a href="""&king.inst&datalist(1,0)&""">"&htmlencode(datalist(0,0))&"</a> &gt;&gt; "&htmlencode(data(2,i)))

			outhtm=king.create(tmphtm,king.invalue)

			if j=0 then
				king.createfolder "../../"&datalist(1,0)&"/"&art.initially&data(0,i)
				king.savetofile "../../"&datalist(1,0)&"/"&art.initially&data(0,i)&"/"&king_ext,outhtm'创建文件
			else
				king.createfolder "../../"&datalist(1,0)&"/"&art.initially&data(0,i)&"/"&(j+1)
				king.savetofile "../../"&datalist(1,0)&"/"&art.initially&data(0,i)&"/"&(j+1)&"/"&king_ext,outhtm'创建文件
			end if
		next
	next

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createlist(l1)
	dim tmphtm,outhtm
	dim tmphtmlist,tmplist
	dim jshtm,jsnumber,zebra
	dim rs,i,j,data,datalist,pid,plist,pidcount,length'pidcount 总页数
	dim sql,suij,suijpagelist
	dim artfrom
	dim jsorder

	sql="listid,listname,listpath,listtemplate1,listtemplate2"'4 datalist
	set rs=conn.execute("select "&sql&" from kingeasyart_list where listid in ("&l1&");")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing

	sql="artid,listid,arttitle,artfrom,artdescription,artdate"'5 data
	for j=0 to ubound(datalist,2)

		'分析模板及标签，并获得值
		tmphtm=king.read(datalist(3,j),r_path&"[list]/"&datalist(4,j))'内外部模板结合后的htm代码
		tmphtmlist=king.getlist(tmphtm,"easyarticle",1)'type="list"部分的tag，包括{king:/}
		jshtm=king.getlabel(tmphtmlist,0)
		jsorder=king.getlabel(tmphtmlist,"order")
		if lcase(jsorder)="asc" then jsorder="asc" else jsorder="desc"
		jsnumber=fix(king.getlabel(tmphtmlist,"number"))
		zebra=king.getlabel(tmphtmlist,"zebra")
		suij=chr(3)&salt(20)&chr(2)'随机出来的替换参数
		suijpagelist=chr(3)&salt(16)&chr(2)

		'把tmphtm中的{king:...type=list/}标签替换为一个随机的标签；pagelist设置为一个随机标签
		tmphtm=replace(tmphtm,tmphtmlist,suij)

		'替换模板中的标签
		king.clearvalue
		king.value "title",datalist(1,j)
		king.value "path",datalist(2,j)
		king.value "pagelist",encode(suijpagelist)
		tmphtm=king.create(tmphtm,king.invalue)


		set rs=conn.execute("select "&sql&" from kingeasyart where listid="&datalist(0,j)&" order by artorder "&jsorder&",artid "&jsorder&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				
				'初始化变量值
				pid=0
				pidcount=(ubound(data,2)+1)/jsnumber:if pidcount>int(pidcount) then pidcount=int(pidcount)+1'总页数
				length=ubound(data,2)'总记录数-1

				for i=0 to length'开始循环列表
				
					king.clearvalue
					king.value "artid",data(0,i)
					king.value "listid",data(1,i)
					king.value "listname",encode(htmlencode(datalist(1,j)))
					king.value "listpath",encode(king.inst&datalist(2,j))
					king.value "path",encode(king.inst&datalist(2,j)&"/"&initially&data(0,i))
					king.value "title",encode(htmlencode(data(2,i)))
					if instr(data(3,i),"|")>0 then
						artfrom=split(data(3,i),"|")
						king.value "from",encode(htmlencode(artfrom(0)))
					else
						king.value "from",encode(htmlencode(data(3,i)))
					end if
					king.value "description",encode(htmlencode(data(4,i)))
					king.value "date",encode(htmlencode(data(5,i)))
					if i+1 mod zebra then
						king.value "zebra",1
					else
						king.value "zebra",0
					end if

					tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量

					if ((i+1) mod jsnumber)=0 or i=length then '当整除于number参数或到最后一个记录的时候进入生成过程
'						if i=length then pid=pid+1
						plist=pagelist(king.inst&datalist(2,j)&"/$",pid+1,pidcount,length+1)

						outhtm=replace(tmphtm,suij,tmplist)
						outhtm=replace(outhtm,suijpagelist,plist)

						king.createfolder "../../"&datalist(2,j)
						if pid=0 then'列表第一页
							king.savetofile "../../"&datalist(2,j)&"/"&king_ext,outhtm
						else
							king.createfolder "../../"&datalist(2,j)&"/"&(pid+1)
							king.savetofile "../../"&datalist(2,j)&"/"&(pid+1)&"/"&king_ext,outhtm
						end if

						'初始化循环变量
						tmplist=""
						
						pid=pid+1
					end if

				next
			else
				outhtm=replace(tmphtm,suij,king.lang("error/rsnot"))
				outhtm=replace(outhtm,suijpagelist,"")
				king.createfolder "../../"&datalist(2,j)
				king.savetofile "../../"&datalist(2,j)&"/"&king_ext,outhtm
			end if
			rs.close
		set rs=nothing
	next
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createlist1(l1,l2)
	dim tmphtm,outhtm
	dim tmphtmlist,tmplist
	dim jshtm,jsnumber,zebra
	dim rs,i,j,dp,data,datalist,pid,plist,pidcount,count,length'pidcount 总页数
	dim sql,suij,suijpagelist
	dim artfrom
	dim jsorder

	sql="listid,listname,listpath,listtemplate1,listtemplate2"'4 datalist
	set rs=conn.execute("select "&sql&" from kingeasyart_list where listid="&l1&";")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing

	sql="artid,listid,arttitle,artfrom,artdescription,artdate"'5 data

	'分析模板及标签，并获得值
	tmphtm=king.read(datalist(3,0),r_path&"[list]/"&datalist(4,0))'内外部模板结合后的htm代码
	tmphtmlist=king.getlist(tmphtm,"easyarticle",1)'type="list"部分的tag，包括{king:/}
	jshtm=king.getlabel(tmphtmlist,0)
	jsorder=king.getlabel(tmphtmlist,"order")
	if lcase(jsorder)="asc" then jsorder="asc" else jsorder="desc"
	jsnumber=fix(king.getlabel(tmphtmlist,"number"))
	zebra=king.getlabel(tmphtmlist,"zebra")
	suij=chr(3)&salt(20)&chr(2)'随机出来的替换参数
	suijpagelist=chr(3)&salt(16)&chr(2)

	'把tmphtm中的{king:...type=list/}标签替换为一个随机的标签；pagelist设置为一个随机标签
	tmphtm=replace(tmphtm,tmphtmlist,suij)

	'替换模板中的标签
	king.clearvalue
	king.value "title",datalist(1,0)
	king.value "path",datalist(2,0)
	king.value "pagelist",encode(suijpagelist)
	tmphtm=king.create(tmphtm,king.invalue)

	set dp=new record
		dp.pid=l2
		dp.rn=jsnumber
		dp.create "select "&sql&" from kingeasyart where listid="&datalist(0,0)&" order by artorder "&jsorder&",artid "&jsorder&";"
				
		if dp.length>-1 then
			'初始化变量值
			pid=l2
			count=dp.count'总记录数
			pidcount=dp.pagecount'总页数
			length=dp.length'页记录数

			for i=0 to length'开始循环列表
			
				king.clearvalue
				king.value "artid",dp.data(0,i)
				king.value "listid",dp.data(1,i)
				king.value "listname",encode(htmlencode(datalist(1,0)))
				king.value "listpath",encode(king.inst&datalist(2,0))
				king.value "path",encode(king.inst&datalist(2,0)&"/"&initially&dp.data(0,i))
				king.value "title",encode(htmlencode(dp.data(2,i)))
				if instr(dp.data(3,i),"|")>0 then
					artfrom=split(dp.data(3,i),"|")
					king.value "from",encode(htmlencode(artfrom(0)))
				else
					king.value "from",encode(htmlencode(dp.data(3,i)))
				end if
				king.value "description",encode(htmlencode(dp.data(4,i)))
				king.value "date",encode(htmlencode(dp.data(5,i)))
				if i+1 mod zebra then
					king.value "zebra",1
				else
					king.value "zebra",0
				end if

				tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量
			next

			plist=pagelist(king.inst&datalist(2,0)&"/$/",pid,pidcount,count)

			outhtm=replace(tmphtm,suij,tmplist)
			outhtm=replace(outhtm,suijpagelist,plist)

			king.createfolder "../../"&datalist(2,0)
			if pid=1 then'列表第一页
				king.savetofile "../../"&datalist(2,0)&"/"&king_ext,outhtm
			else
				king.createfolder "../../"&datalist(2,0)&"/"&(pid)
				king.savetofile "../../"&datalist(2,0)&"/"&pid&"/"&king_ext,outhtm
			end if

		else
			outhtm=replace(tmphtm,suij,king.lang("error/rsnot"))
			outhtm=replace(outhtm,suijpagelist,"")
			king.createfolder "../../"&datalist(2,0)
			king.savetofile "../../"&datalist(2,0)&"/"&king_ext,outhtm
		end if
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function pageslist(l1,l2,l3)'url，当前，总页
	if l3=1 then exit function
	dim i,I1

	for i=1 to l3
		if cstr(i)=cstr(l2) then
			I1=I1&"<strong>"&i&"</strong>"
		else
			if cstr(i)="1" then
				I1=I1&"<a href="""&l1&""">1</a>"
			else
				I1=I1&"<a href="""&l1&"/"&i&""">"&i&"</a>"
			end if
		end if
	next
	pageslist="<span class=""k_pagelist"">"&I1&"</span>"
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub list()
	dim listid,listname,rs

	listid=quest("listid",2)
	if len(listid)=0 then listid=form("listid")
	if len(form("listid"))>0 then
		if validate(listid,2)=false then king.error king.lang("error/invalid")
	end if

	Il "<h2>"
	Il lang("title")

	Il "<span class=""listmenu"">"
	Il "["
	if len(listid)>0 then
		set rs=conn.execute("select listname from kingeasyart_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				Il "<a href=""index.asp?action=art&listid="&listid&""">"&htmlencode(rs(0))&"</a>"
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if
	Il "<a href=""index.asp?action=edt&listid="&listid&""">"&lang("common/addart")&"</a>"
	Il "]"
	Il "[<a href=""index.asp"">"&lang("common/list")&"</a>"
	Il "<a href=""index.asp?action=edtlist"">"&lang("common/addlist")&"</a>]"
	Il "</span>"

	Il "</span>"
	Il "</h2>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createmap()
	dim rs,i,data,irs,outmap,listid,listpath
	if len(king.mapname)=0 then exit sub
	set rs=conn.execute("select top "&king.mapnumber&" artid,artdate,listid from kingeasyart order by artid desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			outmap="<?xml version=""1.0"" encoding=""UTF-8""?>"
			outmap=outmap&"<urlset xmlns="""&king_map_xmlns&""">"
			for i=0 to ubound(data,2)
				if cstr(listid)<>cstr(data(2,i)) then
					listid=data(2,i)
					set irs=conn.execute("select listpath from kingeasyart_list where listid="&listid&";")
						if not irs.eof and not irs.bof then
							listpath=irs(0)
						end if
						irs.close
					set irs=nothing
				end if
				outmap=outmap&"<url>"
				outmap=outmap&"<loc>"&king.siteurl&king.inst&listpath&"/"&initially&data(0,i)&"/</loc>"
				outmap=outmap&"<lastmod>"&formatdate(data(1,i),"yyyy-MM-ddThh:mm:ss+08:00")&"</lastmod>"
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
public sub install()
	king.head "admin",0
	dim sql
' kingeasyart 
	sql="artid int not null identity primary key,"
	sql=sql&"listid int not null default 0,"'所属
	sql=sql&"artorder int not null default 0,"'排序
	sql=sql&"arttitle nvarchar(100),"'标题
	sql=sql&"artcontent ntext,"'文本
	sql=sql&"artfrom nvarchar(100),"'来自
	sql=sql&"artkeywords nvarchar(100),"'关键字，不给显示但需要记录
	sql=sql&"artdescription nvarchar(255),"'简述，也不给显示
	sql=sql&"artdate datetime"'添加时间
	conn.execute "create table kingeasyart ("&sql&")"
' kingeasyart_list
	sql="listid int not null identity primary key,"
	sql=sql&"listname nvarchar(30),"
	sql=sql&"listorder int not null default 0,"'排序
	sql=sql&"listpath nvarchar(100),"'路径
	sql=sql&"artfrom nvarchar(100),"'自动存储的来源
	sql=sql&"lastdate datetime,"'最后一次添加时间
	sql=sql&"listtemplate1 nvarchar(50),"
	sql=sql&"listtemplate2 nvarchar(50),"
	sql=sql&"pagetemplate1 nvarchar(50),"
	sql=sql&"pagetemplate2 nvarchar(50)"
	conn.execute "create table kingeasyart_list ("&sql&")"
	'插入sitemap
	conn.execute "insert into kingsitemap (maploc,maplastmod) values ('"&r_path&"','"&tnow&"')"
	king.createmap
end sub


end class

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_easyarticle(tag,invalue)
'	on error resume next
	dim ttype,tnumber,tkey,tlikey,jshtm,zebra
	dim rs,i,data,sql,insql,tmplist,listid
	dim t_art,datalist,artfrom,artid
	dim jslistid,jslistname,insql_id

	ttype=king.getlabel(tag,"type")
	tnumber=king.getlabel(tag,"number")
	zebra=king.getlabel(tag,"zebra")
	jshtm=king.getlabel(tag,0)
	jslistid=king.getlabel(tag,"listid")
	if validate(jslistid,6) then
		insql_id=" listid in ("&jslistid&")"
	else
		jslistname=king.getlabel(tag,"listname")
		if len(jslistname)>0 then
			set rs=conn.execute("select listid from kingeasyart_list where "&king.likey("listname",jslistname)&";")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						if len(insql_id)>0 then
							insql_id=data(0,i)
						else
							insql_id=insql_id&","&data(0,i)
						end if
						if len(insql_id)>0 then
							insql_id=" listid in ("&insql_id&")"
						end if
					next
				end if
				rs.close
			set rs=nothing
		end if
	end if
	sql=" artid,listid,arttitle,artfrom,artdescription,artdate,artcontent"'不要删除前面的空格

	set t_art=new easyarticle

	select case lcase(ttype)
	case"related"'相关文章
		tkey=king.getvalue(invalue,"keywords")
		artid=king.getvalue(invalue,"artid")
		tlikey=king.likey("artkeywords",tkey)
		if len(insql_id)>0 then isnql_id=" and "&insql_id
		if len(tlikey)>0 then
			if validate(artid,2) then
				insql="select top "&tnumber&sql&" from kingeasyart where artid <>"&artid&" and ("&tlikey&") "&insql_id&" order by artorder desc,artid desc;"
			else
				insql="select top "&tnumber&sql&" from kingeasyart where "&tlikey&" "&insql_id&" order by artorder desc,artid desc;"
			end if
		else
			exit function
		end if
	case else '最新文章
		if len(insql_id)>0 then insql_id=" where "&insql_id
		insql="select top "&tnumber&sql&" from kingeasyart "&insql_id&" order by artorder desc,artid desc;"
	end select
	
	set rs=conn.execute(insql)
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			exit function
		end if
		rs.close
	set rs=nothing

	for i=0 to ubound(data,2)

		if cstr(listid)<>cstr(data(1,i)) then
			listid=data(1,i)
			set rs=conn.execute("select listname,listpath from kingeasyart_list where listid="&listid&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
				else
					exit function
				end if
				rs.close
			set rs=nothing
		end if
		
		king.clearvalue

		king.value "artid",data(0,i)
		king.value "listid",data(1,i)
		king.value "listname",encode(htmlencode(datalist(0,0)))
		king.value "listpath",encode(king.inst&datalist(1,0))
		king.value "path",encode(king.inst&datalist(1,0)&"/"&t_art.initially&data(0,i))
		king.value "title",encode(htmlencode(data(2,i)))
		if instr(data(3,i),"|")>0 then
			artfrom=split(data(3,i),"|")
			king.value "from",encode(htmlencode(artfrom(0)))
		else
			king.value "from",encode(htmlencode(data(3,i)))
		end if
		king.value "description",encode(htmlencode(data(4,i)))
		king.value "date",encode(htmlencode(data(5,i)))
		if instr(king.pagebreak(data(6,i)),king_break)>0 then
			king.value "content",encode(split(king.pagebreak(data(6,i)),king_break)(0))
		else
			king.value "content",encode(data(6,i))
		end if
		if i+1 mod zebra then
			king.value "zebra",1
		else
			king.value "zebra",0
		end if

		tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量
	next

	set t_art=nothing

	king_tag_easyarticle=tmplist
end function

%>