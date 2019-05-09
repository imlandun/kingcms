<%
class article
private r_path,r_doc,r_time,r_thisver

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()
	dim dbver,rs

	r_path = "Article"

	r_thisver = 1.1

	r_time = 630 '毫秒 文章生成时间差设置，数字越大生成效率越低CPU占用率也低

	if king.checkcolumn("kingart")=false then
		install:update
	else
		on error resume next
		set rs=conn.execute("select kversion from kingart_config where systemname='KingCMS'")
			if not rs.eof and not rs.bof then
				dbver=rs(0)
			end if
			rs.close
		set rs=nothing
		if r_thisver>dbver then update
		if err.number<>0 then update
	end if

end sub
'  *** Copyr ight &copy KingCMS.com All Rights Reserved ***
public property get path :path=r_path:end property
public property get time :time=r_time:end Property
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
	dim listid,listname,rs,selected

	listid=quest("listid",2)
	if len(listid)=0 then listid=form("listid")

	if len(listid)=0 then
		listid=quest("listid1",2)
		if len(listid)=0 then listid=form("listid1")
	end if

	if len(form("listid"))>0 then
		if validate(listid,2)=false then king.error king.lang("error/invalid")
	end if
'	out listid

	Il "<h2>"
	Il lang("title")

	Il "<span class=""listmenu"">"
	Il "["
	if len(listid)>0 and cstr(listid)<>"0" then
		Il "<a href=""index.asp?action=edt&listid="&listid&""">"&lang("common/addart")&"</a>"
	end if
	Il "<a href=""javascript:;"" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=search');"">"&lang("common/search")&"</a>"
	Il "]"
	if len(listid)>0 and cstr(listid)<>"0" then
		Il "["
		Il "<a href=""index.asp?action=art&listid="&listid&""">"&lang("common/listart")&"</a>"
		if conn.execute("select count(listid) from kingart_list where listid1="&listid&";")(0)>0 then
			Il "<a href=""index.asp?listid="&listid&""">"&lang("common/listdir")&"</a>"
		end if
		Il "<a href=""index.asp?action=edtlist&listid="&listid&""">"&lang("common/attrib")&"</a>"
		Il "]"
	end if
	Il "[<a href=""index.asp"">"&lang("common/home")&"</a>"
	Il "<a href=""index.asp?action=tree&listid="&listid&""">"&lang("common/tree")&"</a>"
	Il "<a href=""index.asp?action=edtlist&listid1="&listid&""">"&lang("common/addlist")&"</a>]"

	if king.instre(king.plugin,"passport") then
		Il "[<a href=""index.asp?action=group&listid="&listid&""">"&lang("common/grade")&"</a>"
		if instr(action,"group")>0 then
			Il "<a href=""index.asp?action=edtgroup&listid="&listid&""">"&lang("common/gradeadd")&"</a>"
		end if
		Il "]"
	end if

	Il "</span>"

	Il "</h2>"

	if cstr(listid)<>"0" and len(listid)>0 and (action="" or action="art") then
		Il "<p><a href=""index.asp"">"&lang("common/root")&"</a> :/"
		Il list_guide(listid)
		Il "</p>"
	end if

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function list_guide(l1)
	if cstr(l1)="0" then exit function
	dim rs,i,data,I1,listid
	listid=quest("listid",2)
	if len(listid)=0 then listid=form("listid")
	if len(form("listid"))>0 then
		if validate(listid,2)=false then king.error king.lang("error/invalid")
	end if

	set rs=conn.execute("select listid1,listname from kingart_list where listid="&l1&";")
		if not rs.eof and not rs.bof then
			if cstr(listid)=cstr(l1) then
				I1=" "&htmlencode(rs(1))
			else
				I1=" <a href=""index.asp?listid="&l1&""">"&htmlencode(rs(1))&"</a> /"
			end if
			if cstr(rs(0))<>"0" then I1=list_guide(rs(0))&I1
		end if
		rs.close
	set rs=nothing
	list_guide=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function guide(l1)
	dim rs,i,data,I1
	if cstr(l1)="0" then exit function
	
	set rs=conn.execute("select listid1,listname,listpath from kingart_list where listid="&l1&";")
		if not rs.eof and not rs.bof Then
			I1="<a href="""&king.inst&htmlencode(rs(2))&"/"">"&htmlencode(rs(1))&"</a>"
			if cstr(rs(0))<>"0" then I1=guide(rs(0))&" &gt;&gt; "&I1
		end if
		rs.close
	set rs=nothing

	guide=I1

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createpage(l1)
	dim tmphtm,outhtm,i,j,sql,rs,data
	dim listid,datalist,contents,artfrom,artpath
	sql="artid,listid,arttitle,artcontent,artfrom,artkeywords,artdescription,artdate,artauthor,artpath,artimg,artorder,artgrade"'12
	
	if len(l1)=0 then exit sub

	set rs=conn.execute("select "&sql&" from kingart where artid in ("&l1&");")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			redim data(0,-1)
		end if
		rs.close
	set rs=nothing

	for i=0 to ubound(data,2)
		if cstr(data(1,i))<>cstr(listid) then
			set rs=conn.execute("select listname,listpath,pagetemplate1,pagetemplate2,listcontent from kingart_list where listid="&data(1,i)&";")
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
			king.value "listname",encode(htmlencode(datalist(0,0)))
			king.value "listcontent",encode(htmlencode(datalist(4,0)))
			king.value "listpath",encode(king.inst&datalist(1,0)&"/")
			king.value "title",encode(htmlencode(data(2,i)))
			king.value "content",encode(contents(j))
			king.value "from",encode(formatfrom(data(4,i)))
			king.value "keywords",encode(htmlencode(data(5,i)))
			king.value "description",encode(htmlencode(data(6,i)))
			king.value "date",encode(htmlencode(data(7,i)))
			king.value "author",encode(htmlencode(data(8,i)))
			king.value "image",encode(htmlencode(data(10,i)))
			king.value "guide",encode(guide(listid)&" &gt;&gt; "&htmlencode(data(2,i)))
			king.value "nextpage",encode(nextpage(data(0,i),data(11,i),data(1,i),datalist(1,0),tmphtm))'下一页
			king.value "lastpage",encode(lastpage(data(0,i),data(11,i),data(1,i),datalist(1,0),tmphtm,datalist(0,0)))'上一页
			king.value "hit","<span id=""k_hit""><script type=""text/javascript"">posthtm('"&king.page&"article/page.asp?action=hit','k_hit','artid="&data(0,i)&"');</script></span>"
			king.value "path",encode(getpath(data(0,i),data(12,i),king.inst&datalist(1,0)&"/"&data(9,i)))
			king.value "pagelist",encode(pageslist(king.inst&datalist(1,0)&"/"&data(9,i),j,ubound(contents),data(12,i),data(0,i)))
			king.value "commentid",encode(r_path&"|"&data(0,i))'传递评论参数

			outhtm=king.create(tmphtm,king.invalue)
			
			'生成文件
			artpath=pagepath("../../"&datalist(1,0)&"/"&data(9,i),j)
			'非文件
			if king.isfile(data(9,i))=false then artpath=artpath&king_ext
			king.savetofile artpath,outhtm

		next
	next
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createlist(l1)
	dim tmphtm,outhtm
	dim tmphtmlist,tmplist
	dim jshtm,jsnumber,zebra
	dim rs,irs,i,j,data,datalist,pid,plist,pidcount,length'pidcount 总页数
	dim sql,suij,suijpagelist
	dim jsorder,listid,listpath,listname

	if len(l1)=0 then exit sub

	sql="listid,listname,listpath,listtemplate1,listtemplate2,listtitle,listkeyword,listdescription,listcontent"'7 datalist
	set rs=conn.execute("select "&sql&" from kingart_list where listid in ("&l1&");")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing

	sql="artid,listid,arttitle,artfrom,artdescription,artdate,artkeywords,artauthor,artpath,artimg,artgrade"'10 data
	for j=0 to ubound(datalist,2)

		'分析模板及标签，并获得值
		tmphtm=king.read(datalist(3,j),r_path&"[list]/"&datalist(4,j))'内外部模板结合后的htm代码
		tmphtmlist=king.getlist(tmphtm,"article",1)'type="list"部分的tag，包括{king:/}
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
		king.value "title",encode(htmlencode(datalist(5,j)))
		king.value "listname",encode(htmlencode(datalist(1,j)))
		king.value "listcontent",encode(htmlencode(datalist(8,j)))
		king.value "listpath",encode(king.inst&datalist(2,j))
		king.value "keywords",encode(htmlencode(datalist(6,j)))
		king.value "description",encode(htmlencode(datalist(7,j)))
		king.value "path",encode(king.inst&datalist(2,j))
		king.value "pagelist",encode(suijpagelist)
		king.value "listid",datalist(0,j)
		king.value "guide",encode(guide(datalist(0,j)))  '增加,可选的
		tmphtm=king.create(tmphtm,king.invalue)

		set rs=conn.execute("select "&sql&" from kingart where artshow=1 and listid="&datalist(0,j)&" or listids like '%,"&datalist(0,j)&",%' order by artup desc,artorder "&jsorder&",artid "&jsorder&";")
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
					king.value "listcontent",encode(htmlencode(datalist(8,j)))
					king.value "listpath",encode(king.inst&datalist(2,j))
					king.value "title",encode(htmlencode(data(2,i)))
					king.value "from",encode(formatfrom(data(3,i)))
					king.value "description",encode(htmlencode(data(4,i)))
					king.value "date",encode(htmlencode(data(5,i)))
					king.value "keywords",encode(htmlencode(data(6,i)))
					king.value "author",encode(htmlencode(data(7,i)))
					king.value "image",encode(data(9,i))
					king.value "path",encode(getpath(data(0,i),data(10,i),king.inst&listpath&"/"&data(8,i)))
					king.value "zebra",king.mod2(i+1,zebra)
					king.value "commentid",encode(r_path&"|"&data(0,i))'传递评论参数


					tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量

					if ((i+1) mod jsnumber)=0 or i=length then '当整除于number参数或到最后一个记录的时候进入生成过程
'						if i=length then pid=pid+1
						plist=pagelist(king.inst&datalist(2,j)&"/$/",pid+1,pidcount,length+1)

						outhtm=replace(tmphtm,suij,tmplist)
						outhtm=replace(outhtm,suijpagelist,plist)

						king.createfolder "../../"&datalist(2,j)
						if pid=0 then'列表第一页
							king.savetofile "../../"&datalist(2,j)&"/"&king_ext,outhtm
						else
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
	dim rs,irs,i,j,dp,data,datalist,pid,plist,pidcount,count,length'pidcount 总页数
	dim sql,suij,suijpagelist
	dim jsorder,listid,listpath,listname

	if len(l1)=0 then exit sub

	sql="listid,listname,listpath,listtemplate1,listtemplate2,listtitle,listkeyword,listdescription,listcontent"'7 datalist
	set rs=conn.execute("select "&sql&" from kingart_list where listid="&l1&";")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing

	sql="artid,listid,arttitle,artfrom,artdescription,artdate,artkeywords,artauthor,artpath,artimg,artgrade"'10 data

	'分析模板及标签，并获得值
	tmphtm=king.read(datalist(3,0),r_path&"[list]/"&datalist(4,0))'内外部模板结合后的htm代码
	tmphtmlist=king.getlist(tmphtm,"article",1)'type="list"部分的tag，包括{king:/}
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
	king.value "title",encode(htmlencode(datalist(5,0)))
	king.value "listname",encode(htmlencode(datalist(1,0)))
	king.value "listcontent",encode(htmlencode(datalist(8,0)))
	king.value "listpath",encode(king.inst&datalist(2,0))
	king.value "keywords",encode(htmlencode(datalist(6,0)))
	king.value "description",encode(htmlencode(datalist(7,0)))
	king.value "path",encode(king.inst&datalist(2,0))
	king.value "pagelist",encode(suijpagelist)
	king.value "listid",datalist(0,0)
	king.value "guide",encode(guide(datalist(0,0)))  '增加,可选的
	tmphtm=king.create(tmphtm,king.invalue)

	set dp=new record
		dp.pid=l2
		dp.rn=jsnumber
		dp.create "select "&sql&" from kingart where artshow=1 and listid="&datalist(0,0)&" or listids like '%,"&datalist(0,0)&",%' order by artup desc,artorder "&jsorder&",artid "&jsorder&";"
				
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
				king.value "listcontent",encode(htmlencode(datalist(8,0)))
				king.value "listpath",encode(king.inst&datalist(2,0))
				king.value "title",encode(htmlencode(dp.data(2,i)))
				king.value "from",encode(formatfrom(dp.data(3,i)))
				king.value "description",encode(htmlencode(dp.data(4,i)))
				king.value "date",encode(htmlencode(dp.data(5,i)))
				king.value "keywords",encode(htmlencode(dp.data(6,i)))
				king.value "author",encode(htmlencode(dp.data(7,i)))
				king.value "image",encode(dp.data(9,i))
				king.value "path",encode(getpath(dp.data(0,i),dp.data(10,i),king.inst&datalist(2,0)&"/"&dp.data(8,i)))
				king.value "zebra",king.mod2(i+1,zebra)
				king.value "commentid",encode(r_path&"|"&dp.data(0,i))'传递评论参数

				tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量
			next

			plist=pagelist(king.inst&datalist(2,0)&"/$/",pid,pidcount,count)

			outhtm=replace(tmphtm,suij,tmplist)
			outhtm=replace(outhtm,suijpagelist,plist)

			king.createfolder "../../"&datalist(2,0)
			if pid=1 then'列表第一页
				king.savetofile "../../"&datalist(2,0)&"/"&king_ext,outhtm
			else
				king.savetofile "../../"&datalist(2,0)&"/"&pid&"/"&king_ext,outhtm
			end if
		else
			outhtm=replace(tmphtm,suij,king.lang("error/rsnot"))
			outhtm=replace(outhtm,suijpagelist,"")
			king.savetofile "../../"&datalist(2,0)&"/"&king_ext,outhtm
		end if
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function artpage(l1,j)
	dim tmphtm,outhtm,i,sql,rs,data
	dim listid,datalist,contents,artfrom,artpath
	sql="artid,listid,arttitle,artcontent,artfrom,artkeywords,artdescription,artdate,artauthor,artpath,artimg,artorder,artgrade"'12
	
	if len(l1)=0 then exit function

	set rs=conn.execute("select "&sql&" from kingart where artid ="&l1&";")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			redim data(0,-1)
		end if
		rs.close
	set rs=nothing

		if cstr(data(1,0))<>cstr(listid) then
			set rs=conn.execute("select listname,listpath,pagetemplate1,pagetemplate2,listcontent from kingart_list where listid="&data(1,0)&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
					listid=data(1,0)
					tmphtm=king.read(datalist(2,0),r_path&"[page]/"&datalist(3,0))
				end if
				rs.close
			set rs=nothing
		end if

		contents=split(king.pagebreak(data(3,i)),king_break)
		
		if j="" then j=0
		if cstr(j)>cstr(ubound(contents)) then j=ubound(contents)

			king.clearvalue
			king.value "artid",data(0,i)
			king.value "listid",data(1,i)
			king.value "listname",encode(htmlencode(datalist(1,0)))
			king.value "listcontent",encode(htmlencode(datalist(4,0)))
			king.value "listpath",encode(king.inst&"artlist/"&datalist(0,0)&"/")
			king.value "title",encode(htmlencode(data(2,i)))
			king.value "content",encode(contents(j))
			king.value "from",encode(formatfrom(data(4,i)))
			king.value "keywords",encode(htmlencode(data(5,i)))
			king.value "description",encode(htmlencode(data(6,i)))
			king.value "date",encode(htmlencode(data(7,i)))
			king.value "author",encode(htmlencode(data(8,i)))
			king.value "image",encode(htmlencode(data(10,i)))
			king.value "guide",encode(guide(listid)&" &gt;&gt; "&htmlencode(data(2,i)))
			king.value "nextpage",encode(nextpage(data(0,i),data(11,i),data(1,i),datalist(1,0),tmphtm))'下一页
			king.value "lastpage",encode(lastpage(data(0,i),data(11,i),data(1,i),datalist(1,0),tmphtm,datalist(0,0)))'上一页
			king.value "hit","<span id=""k_hit""><script type=""text/javascript"">posthtm('"&king.page&"article/artpage.asp?action=hit','k_hit','artid="&data(0,i)&"');</script></span>"
			king.value "path",encode(getpath(data(0,i),data(12,i),king.inst&"article"&"/"&formatdate(data(7,i),"yyyyMMdd")&"/"&data(0,i)))
			king.value "pagelist",encode(pageslist(king.inst&"article"&"/"&formatdate(data(7,i),"yyyyMMdd")&"/"&data(0,i),j,ubound(contents),data(12,i),data(0,i)))
			king.value "commentid",encode(r_path&"|"&data(0,i))'传递评论参数

			outhtm=king.create(tmphtm,king.invalue)
			artpage=outhtm

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function artlist(l1)
	dim tmphtm,outhtm
	dim tmphtmlist,tmplist
	dim jshtm,jsnumber,zebra
	dim rs,irs,i,j,dp,data,datalist,pid,plist,pidcount,count,length'pidcount 总页数
	dim sql,suij,suijpagelist
	dim jsorder,listid,listpath,listname

	if len(l1)=0 then exit function

	sql="listid,listname,listpath,listtemplate1,listtemplate2,listtitle,listkeyword,listdescription,listcontent"'7 datalist
	set rs=conn.execute("select "&sql&" from kingart_list where listid="&l1&";")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing

	sql="artid,listid,arttitle,artfrom,artdescription,artdate,artkeywords,artauthor,artpath,artimg,artgrade"'10 data

	'分析模板及标签，并获得值
	tmphtm=king.read(datalist(3,0),r_path&"[list]/"&datalist(4,0))'内外部模板结合后的htm代码
	tmphtmlist=king.getlist(tmphtm,"article",1)'type="list"部分的tag，包括{king:/}
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
	king.value "title",encode(htmlencode(datalist(5,0)))
	king.value "listname",encode(htmlencode(datalist(1,0)))
	king.value "listcontent",encode(htmlencode(datalist(8,0)))
	king.value "listpath",encode(king.inst&"artlist/"&datalist(0,0))
	king.value "keywords",encode(htmlencode(datalist(6,0)))
	king.value "description",encode(htmlencode(datalist(7,0)))
	king.value "path",encode(king.inst&"artlist/"&datalist(0,0))
	king.value "pagelist",encode(suijpagelist)
	king.value "listid",datalist(0,0)
	king.value "guide",encode(guide(datalist(0,0)))  '增加,可选的
	tmphtm=king.create(tmphtm,king.invalue)

	set dp=new record
		dp.rn=jsnumber
		dp.create "select "&sql&" from kingart where artshow=1 and listid="&datalist(0,0)&" or listids like '%,"&datalist(0,0)&",%' order by artup desc,artorder "&jsorder&",artid "&jsorder&";"
		
		if dp.length>-1 then
			'初始化变量值
			pid=dp.pid
			count=dp.count'总记录数
			pidcount=dp.pagecount'总页数
			length=dp.length'页记录数

			for i=0 to length'开始循环列表

				king.clearvalue
				king.value "artid",dp.data(0,i)
				king.value "listid",dp.data(1,i)
				king.value "listname",encode(htmlencode(datalist(1,0)))
				king.value "listcontent",encode(htmlencode(datalist(8,0)))
				king.value "listpath",encode(king.inst&"artlist/"&datalist(0,0))
				king.value "title",encode(htmlencode(dp.data(2,i)))
				king.value "from",encode(formatfrom(dp.data(3,i)))
				king.value "description",encode(htmlencode(dp.data(4,i)))
				king.value "date",encode(htmlencode(dp.data(5,i)))
				king.value "keywords",encode(htmlencode(dp.data(6,i)))
				king.value "author",encode(htmlencode(dp.data(7,i)))
				king.value "image",encode(dp.data(9,i))
				king.value "path",encode(getpath(dp.data(0,i),dp.data(10,i),king.inst&"article"&"/"&formatdate(dp.data(5,i),"yyyyMMdd")&"/"&dp.data(0,i)))
				king.value "zebra",king.mod2(i+1,zebra)
				king.value "commentid",encode(r_path&"|"&dp.data(0,i))'传递评论参数

				tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量
			next

			plist=pagelist(king.inst&"artlist/"&datalist(0,0)&"/$/",pid,pidcount,count)

			outhtm=replace(tmphtm,suij,tmplist)
			outhtm=replace(outhtm,suijpagelist,plist)
		else
			outhtm=replace(tmphtm,suij,king.lang("error/rsnot"))
			outhtm=replace(outhtm,suijpagelist,"")
		end if
	set dp=nothing
	artlist=outhtm
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function pageslist(l1,l2,l3,l4,l5)'url，当前，总页,artgrade,artid
	if l3=0 then exit function
	dim i,I1
	
	if cstr(l4)="0" then
		for i=0 to l3
			if cstr(i)=cstr(l2) then
				I1=I1&"<strong>"&i+1&"</strong>"
			else
				if cstr(i)="0" then
					I1=I1&"<a href="""&l1&""">1</a>"
				else
					I1=I1&"<a href="""&pagepath(l1,i)&""">"&i+1&"</a>"
				end if
			end if
		next
	else
		for i=1 to l3
			if cstr(i)=cstr(l2) then
				I1=I1&"<strong>"&i&"</strong>"
			else
				if cstr(i)="0" then
					I1=I1&"<a href="""&king.page&"article/artpage.asp?artid="&l5&""">1</a>"
				else
					I1=I1&"<a href="""&king.page&"article/artpage.asp?artid="&l5&"&pid="&i&""">"&i&"</a>"
				end if
			end if
		next
	end if
	pageslist="<span class=""k_pagelist"">"&I1&"</span>"
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createmap()
	dim rs,i,data,irs,outmap,listid,listpath
	if len(king.mapname)=0 then exit sub
	set rs=conn.execute("select top "&king.mapnumber&" artdate,artpath,artid,listid,artcommend,arthead from kingart where artshow=1 and artgrade=0 order by artid desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			outmap="<?xml version=""1.0"" encoding=""UTF-8""?>"
			outmap=outmap&"<urlset xmlns="""&king_map_xmlns&""">"
			for i=0 to ubound(data,2)
				if cstr(listid)<>cstr(data(3,i)) then
					listid=data(3,i)
					set irs=conn.execute("select listpath from kingart_list where listid="&listid&";")
						if not irs.eof and not irs.bof then
							listpath=irs(0)
						end if
						irs.close
					set irs=nothing
				end if
				outmap=outmap&"<url>"
				outmap=outmap&"<loc>"&getpath(data(2,i),0,king.siteurl&king.inst&listpath&"/"&data(1,i))&"</loc>"
				outmap=outmap&"<lastmod>"&formatdate(data(0,i),"yyyy-MM-ddThh:mm:ss+08:00")&"</lastmod>"
				outmap=outmap&"<priority>"&formatnumber((data(4,i)+data(5,i)+2)/4,1,true)&"</priority>"
				outmap=outmap&"</url>"
			next
			outmap=outmap&"</urlset>"
			king.savetofile "../../"&r_path&".xml",outmap
		end if
		rs.close
	set rs=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function getpath(l1,l2,l3)'artid,grade,path
	if cstr(l2)="0" then
		if king.isfile(l3) then'file
			getpath=l3
		else
			getpath=l3&"/"
		end if
	else
		getpath=king.page&"article/artpage.asp?artid="&l1
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function lastpage(l1,l2,l3,l4,l5,l6)'上一页
	if instr(lcase(l5),"{king:lastpage")>0 then
		dim rs,I1
		set rs=conn.execute("select top 1 arttitle,artgrade,artpath,artid,artdate from kingart where artshow=1 and listid="&l3&" and artorder<"&l2&" order by artorder desc,artid desc;")
			if not rs.eof and not rs.bof Then
				I1="<a href="""&getpath(rs(3),rs(1),king.inst&l4&"/"&rs(2))&""">"&htmlencode(rs(0))&"</a>"
			else'如果不存在，则输出js加载来验证
				'I1=art.lang("common/notart")&"<a href="""&king.inst&l4&"/"">["&art.lang("common/back")&"]</a>"
				I1="<a href="""&king.inst&l4&"/"">["&htmlencode(l6)&"]</a>"
			end if
			rs.close
		set rs=nothing
		lastpage="<span id=""k_lastpage"">"&I1&"</span>"
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function nextpage(l1,l2,l3,l4,l5)'artid,artorder,listid,listpath,tmphtm //下一页
	if instr(lcase(l5),"{king:nextpage")>0 then
		dim rs,I1
		set rs=conn.execute("select top 1 arttitle,artgrade,artpath,artid,artdate from kingart where artshow=1 and listid="&l3&" and artorder>"&l2&" order by artorder asc,artid asc;")
			if not rs.eof and not rs.bof then
					I1="<a href="""&getpath(rs(3),rs(1),king.inst&l4&"/"&rs(2))&""">"&htmlencode(rs(0))&"</a>"
'			out I1
			else'如果不存在，则输出js加载来验证
				I1="<script type=""text/javascript"">posthtm('"&king.page&"article/page.asp?action=nextpage','k_nextpage','artid="&l1&"');</script>"
			end if
			rs.close
		set rs=nothing
		nextpage="<span id=""k_nextpage"">"&I1&"</span>"
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function formatfrom(l1)
	dim I1
	if instr(l1,"|")>0 then
		I1=split(l1,"|")
		formatfrom="<a href="""&I1(1)&""" target=""_blank"" title="""&htmlencode(I1(0))&""">"&htmlencode(I1(0))&"</a>"
	else
		formatfrom=l1
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function pagepath(l1,l2)
	'l1 路径 l2 第几页
	dim I1,I2(1)
	if king.instre("0",l2) or len(l2)=0 then
		if king.isfile(l1) then'file
			pagepath=l1
		else
			pagepath=l1&"/"
		end if
		exit function
	end if
	if king.isfile(l1) then'文件
		I1=split(l1,".")
		I2(0)="."&I1(ubound(I1))'right
		I2(1)=left(l1,len(l1)-len(I2(0)))'left
		pagepath=I2(1)&"/"&l2&I2(0)
	else
		pagepath=l1&"/"&l2&"/"
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function getgrade(l1,l2)'返回会员组名称  l1 groupnum l2
	dim I1,rs
	select case cstr(l1)
	case"0","1" I1=art.lang("list/grade"&l1)
	case else
		set rs=conn.execute("select groupname from kingart_group where groupnum="&l1&";")
			if not rs.eof and not rs.bof then
				I1=htmlencode(rs(0))
			else
				I1=art.lang("list/grade1")
				conn.execute "update kingart set artgrade=1 where artid="&l2&";"
			end if
			rs.close
		set rs=nothing
	end select
	getgrade=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub head(l1)'会员访问权限验证 1:groupnum
	dim rs
	select case cstr(l1)
	case"0"
	case"1"
		king.pphead 1
	case else
		king.pphead 1
		set rs=conn.execute("select groupuser from kingart_group where groupnum="&l1&";")
			if not rs.eof and not rs.bof then
				if king.instre(rs(0),king.name)=false then'如果不属于用户组，就提示错误
					king.error art.lang("error/nogroup")
				end if
			else
				conn.execute "update kingart set artgrade=1 where artgrade="&l1&";"
			end if
			rs.close
		set rs=nothing
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub install()
	king.head "admin",0
	dim sql
' kingart 
	sql="artid int not null identity primary key,"
	sql=sql&"listid int not null default 0,"'所属
	sql=sql&"artorder int not null default 0,"'排序

	sql=sql&"artup int not null default 0,"'置顶
	sql=sql&"artshow int not null default 0,"'默认草稿
	sql=sql&"artcommend int not null default 0,"'推荐
	sql=sql&"arthead int not null default 0,"'头条,头条必须要上传图片
	sql=sql&"artgrade int not null default 0,"'默认级别 0直接生成html 1:限会员访问 4:限vip访问 

	sql=sql&"arthit int not null default 0,"'点击率,查看情况

	sql=sql&"arttitle nvarchar(100),"'标题
	sql=sql&"artauthor nvarchar(100),"'作者
	sql=sql&"artfrom nvarchar(255),"'来自 用垂直线分开支持链接
	sql=sql&"artcontent ntext,"'文本

	sql=sql&"artinput nvarchar(30),"'录入
	sql=sql&"artkeywords nvarchar(120),"'关键字，不给显示但需要记录
	sql=sql&"artdescription nvarchar(255),"'简述，也不给显示
	sql=sql&"artpath nvarchar(255),"'文件名称

	sql=sql&"artimg nvarchar(255),"'缩略图
	sql=sql&"listids ntext,"
	sql=sql&"artdate datetime"'添加时间
	conn.execute "create table kingart ("&sql&")"
' kingart_list
	sql="listid int not null identity primary key,"
	sql=sql&"listid1 int not null default 0,"'
	sql=sql&"listorder int not null default 0,"'排序

	sql=sql&"listname nvarchar(30),"
	sql=sql&"listtitle nvarchar(100),"'栏目标题
	sql=sql&"listkeyword nvarchar(120),"'栏目关键字
	sql=sql&"listdescription nvarchar(250),"'description

	sql=sql&"listpath nvarchar(100),"'路径
	sql=sql&"artfrom nvarchar(255),"'自动存储的来源
	sql=sql&"artauthor nvarchar(100),"
	sql=sql&"lastdate datetime,"'最后一次添加时间

	sql=sql&"listtemplate1 nvarchar(50),"
	sql=sql&"listtemplate2 nvarchar(50),"
	sql=sql&"pagetemplate1 nvarchar(50),"
	sql=sql&"pagetemplate2 nvarchar(50)"
	conn.execute "create table kingart_list ("&sql&")"
' kingart_group
	sql="groupid int not null identity primary key,"
	sql=sql&"groupnum int not null default 0,"'代号
	sql=sql&"groupname nvarchar(50),"
	sql=sql&"groupuser ntext"'成员列表
	conn.execute "create table kingart_group ("&sql&")"
	king.createmap
end sub
'update  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub update()
	dim sql
	on error resume next
	conn.execute "create table kingart_config (systemname nvarchar(10),kversion real not null default 1)"
	conn.execute "insert into kingart_config (systemname) values ('KingCMS');"
	conn.execute "alter table kingart_list add listcontent ntext "

	conn.execute "update kingart_config set kversion="&r_thisver&" where systemname='KingCMS';"
end sub


end class

































'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_article_list(tag,invalue)
	on error resume next
	dim rs,i,data,listid,insql_id1
	dim tmplist,jshtm,jslistid,zebra

	listid=king.getvalue(invalue,"listid")
	jshtm=king.getlabel(tag,0)
	jslistid=king.getlabel(tag,"listid")
	zebra=king.getlabel(tag,"zebra")

	insql_id1=" listid1=0"
	select case lcase(jslistid)
	case"sub"
		if validate(listid,2) then
			insql_id1=" listid1="&listid
		end if
	case"current"
		if validate(listid,2) then
			set rs=conn.execute("select listid1 from kingart_list where listid="&listid&" order by listorder desc,listid desc;")
				if not rs.eof and not rs.bof then
					insql_id1=" listid1="&rs(0)
				end if
				rs.close
			set rs=nothing
		end if
	case else
		if validate(jslistid,6) then
			insql_id1=" listid1 in ("&jslistid&")"
		end if
	end select

	set rs=conn.execute("select listid,listname,listpath,listdescription,listcontent from kingart_list where "&insql_id1&" order by listorder desc,listid desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				king.clearvalue
				king.value "listid",data(0,i)
				king.value "listname",htmlencode(data(1,i))
				king.value "listdescription",htmlencode(king.inst&data(3,i))
				king.value "listcontent",encode(htmlencode(data(4,j)))
				king.value "listpath",king.inst&data(2,i)&"/"
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

	king_tag_article_list=tmplist

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_article_double(tag,invalue)
	on error resume next
	'需要获得
	dim jslistid,jshtm
	dim rs,data,i,sql
	dim insql_id,listid,jslistname
	dim tmplist

	jshtm=king.getdblabel(tag,0)
	jslistid=king.getdblabel(tag,"listid")
	if len(jslistid)=0 then jslistid=0

	if validate(jslistid,6) or king.instre("sub",jslistid) then
		select case lcase(jslistid)
		case"0"
			insql_id=" listid1=0"
		case"sub"
			listid=king.getvalue(invalue,"listid")
			insql_id=king_tag_article_getsublist(listid)
		case else
			insql_id=" listid in ("&jslistid&")"
		end select
	else
		jslistname=king.getlabel(tag,"listname")
		if len(jslistname)>0 then
			set rs=conn.execute("select listid from kingart_list where "&king.likey("listname",jslistname)&" order by listorder desc,listid desc;")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						if len(insql_id)>0 then
							insql_id=insql_id&","&data(0,i)
						else
							insql_id=data(0,i)
						end if
					next
					if len(insql_id)>0 then
						insql_id=" listid in ("&insql_id&")"
					end if
				end if
				rs.close
			set rs=nothing
		end if
	end if

	if len(insql_id)=0 then exit function

	sql="listid,listname,listpath,listdescription,listcontent"'2
	set rs=conn.execute("select "&sql&" from kingart_list where "&insql_id&" order by listorder desc,listid desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			redim data(0,-1)
		end if
		rs.close
	set rs=nothing

	for i=0 to ubound(data,2)
		king.clearvalue
		king.value "listid",data(0,i)
		king.value "listname",encode(htmlencode(data(1,i)))
		king.value "listdescription",htmlencode(king.inst&data(3,i))
		king.value "listcontent",encode(htmlencode(data(4,j)))
		king.value "listpath",encode(king.inst&data(2,i))		
		tmplist=tmplist&king.create(jshtm,king.invalue)
	next

	if err.number<>0 then
		err.clear
		tmplist=king.errtag(tag)
	end if

	king_tag_article_double=tmplist

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_article(tag,invalue)
	on error resume next'这个必须要开启

	if left(tag,2)="{{" then
		king_tag_article=king_tag_article_double(tag,invalue)
		exit function
	end if

	dim ttype,tnumber,tkey,tlikey,jshtm,zebra
	dim rs,i,data,sql,insql,tmplist,listid
	dim t_art,datalist,artfrom,artid
	dim jslistid,jslistname,insql_id
	dim jssql,jskeywords,insql_key
	dim jsimg,insql_img
	dim jsnext ' 1220

	ttype=king.getlabel(tag,"type")
	tnumber=king.getlabel(tag,"number")
	zebra=king.getlabel(tag,"zebra")
	jshtm=king.getlabel(tag,0)
	jssql=king.getlabel(tag,"sql")
	jsnext=king.getlabel(tag,"next") ' 1220
	if validate(jsnext,2)=false then jsnext=0 ' 1220
	tnumber=tnumber+int(jsnext) ' 1220

if len(king.match(jshtm,"\(king:image.{0,}?\/\)"))>0 then
		insql_img=" and (artimg like '%.gif' or artimg like '%.jpeg' or artimg like '%.jpg' or artimg like '%.png' or artimg like '%.bmp') "
	end if

	jskeywords=king.getlabel(tag,"keywords")
	if len(jskeywords)>0 then
		insql_key=king.likey("artkeywords",jskeywords)
		if len(insql_key)>0 then
			insql_key=" and ("&insql_key&")"
		end if
	end if

	jslistid=king.getlabel(tag,"listid")

	if validate(jslistid,6) or king.instre("sub,current",jslistid) then
		select case lcase(jslistid)
		case"sub"'只调用当前栏目下面的，并不是所有的，若加入所有，需要递归，麻烦
			listid=king.getvalue(invalue,"listid")
			insql_id=" and " & king_tag_article_getsublist(listid)
		case"current" 
			listid=king.getvalue(invalue,"listid")
			if validate(listid,2) then
				insql_id=" and listid="&listid
			end if
		case else insql_id=" and listid in ("&jslistid&")"
		end select
	else
		jslistname=king.getlabel(tag,"listname")
		if len(jslistname)>0 then
			set rs=conn.execute("select listid from kingart_list where "&king.likey("listname",jslistname)&";")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						if len(insql_id)>0 then
							insql_id=insql_id&","&data(0,i)
						else
							insql_id=data(0,i)
						end if
					next
					if len(insql_id)>0 then
						insql_id=" and listid in ("&insql_id&")"
					end if
				end if
				rs.close
			set rs=nothing
		end if
	end if

	sql=" artid,listid,arttitle,artfrom,artdescription,artdate,artkeywords,artauthor,artpath,artimg,artgrade,artup,artcommend,arthead"'13 data

	set t_art=new article
	Randomize
	select case lcase(ttype)
	case"related"'相关文章
		tkey=king.getvalue(invalue,"keywords")
		artid=king.getvalue(invalue,"artid")
		tlikey=king.likey("artkeywords",tkey)
		if len(tlikey)>0 then tlikey=" and ("&tlikey&")"
		if len(tlikey)>0 then
			if validate(artid,2) then
				insql="select top "&tnumber&sql&" from kingart where artshow=1 "&tlikey&insql_id&insql_key&" and artid<>"&artid&" order by artorder desc,artid desc;"
			else
				insql="select top "&tnumber&sql&" from kingart where artshow=1 "&tlikey&insql_id&insql_key&" order by artorder desc,artid desc;"
			end if
		else
			exit function
		end if
	case"hot"'热门
		insql="select top "&tnumber&sql&" from kingart where artshow=1 "&insql_id&insql_key&insql_img&" order by arthit desc,artid desc;"
	case"chill","cold"'冷门
		insql="select top "&tnumber&sql&" from kingart where artshow=1 "&insql_id&insql_key&insql_img&" order by arthit asc,artid asc;"
	case"head"'头条
		insql="select top "&tnumber&sql&" from kingart where artshow=1 "&insql_id&insql_key&insql_img&" and arthead=1 order by artorder desc,artid desc;"
	case"commend"'推荐
		insql="select top "&tnumber&sql&" from kingart where artshow=1 "&insql_id&insql_key&insql_img&" and artcommend=1 order by artorder desc,artid desc;"
	case"rnds"'随机
		insql="select top "&tnumber&sql&" from kingart where artshow=1 "&insql_id&insql_key&insql_img&" order by rnd(-(artid+"&rnd()&"));"
	case"sql"'自定义的
		insql="select top "&tnumber&sql&" from kingart "&jssql
	case else '最新文章
		insql="select top "&tnumber&sql&" from kingart where artshow=1 "&insql_id&insql_key&insql_img&" order by artorder desc,artid desc;"
	end select
'	out insql
	set rs=conn.execute(insql)
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			exit function
		end if
		rs.close
	set rs=nothing

	listid=0'初始化listid，因为上面用过
	for i=int(jsnext) to ubound(data,2) ' 1220

		if cstr(listid)<>cstr(data(1,i)) then
			listid=data(1,i)
			set rs=conn.execute("select listname,listpath,listid from kingart_list where listid="&listid&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
				else
					exit function
				end if
				rs.close
			set rs=nothing
		end if
		
		'sql="artid,listid,arttitle,artfrom,artdescription,artdate,artkeywords,artauthor,artpath,artimg,artgrade"'10 data

		king.clearvalue
		king.value "artid",data(0,i)
		king.value "listid",data(1,i)
		king.value "listname",encode(htmlencode(datalist(0,0)))
		king.value "listpath",encode(king.inst&datalist(1,0))
		king.value "title",encode(htmlencode(data(2,i)))
		king.value "from",encode(t_art.formatfrom(data(3,i)))
		king.value "description",encode(htmlencode(data(4,i)))
		king.value "date",encode(htmlencode(data(5,i)))
		king.value "keywords",encode(htmlencode(data(6,i)))
		king.value "author",encode(htmlencode(data(7,i)))
		king.value "image",encode(data(9,i))
		king.value "path",encode(t_art.getpath(data(0,i),data(10,i),king.inst&datalist(1,0)&"/"&data(8,i)))
		king.value "zebra",king.mod2(i+1,zebra)
		king.value "commentid",encode("article|"&data(0,i))
		king.value "up",data(11,i)
		king.value "commend",data(12,i)
		king.value "head",data(13,i)
		king.value "++",i+1

		tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量
	next

	set t_art=nothing

	if err.number<>0 then
		err.clear
		tmplist=king.errtag(tag)
	end if

	king_tag_article=tmplist
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_article_getsublist(l1)
	dim rs,data,i,I1
	if validate(l1,2) then
		set rs=conn.execute("select listid from kingart_list where listid1="&l1&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				for i=0 to ubound(data,2)
					if len(I1)>0 then
						I1=I1&","&data(0,i)
					else
						I1=data(0,i)
					end if
				next
				I1=" listid in ("&I1&")"
			else
				I1=" listid=0"
			end if
			rs.close
		set rs=nothing
	end if
	king_tag_article_getsublist=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_article_getsublist(l1)
	dim rs,data,i,I1
	if validate(l1,2) then
		set rs=conn.execute("select listid from kingart_list where listid1="&l1&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				for i=0 to ubound(data,2)
					if len(I1)>0 then
						I1=I1&","&king_article_getsublist(data(0,i))
					else
						I1=king_article_getsublist(data(0,i))
					end if
				next
				I1=l1&","&I1
			else
				I1=l1
			end if
			rs.close
		set rs=nothing
	end if
	king_article_getsublist=I1
end function

%>