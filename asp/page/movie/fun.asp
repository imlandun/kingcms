<%
class movieclass
private r_path,r_doc,r_thisver,r_cpid,r_introduction,r_uptime

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()
	dim dbver,rs

	r_path = "movie"

	r_uptime = 6

	r_thisver = 1.1

	if king.checkcolumn("king__movie_page")=false then
		install:update
	else
		set rs=conn.execute("select kversion from king__movie_config where systemname='KingCMS'")
			if not rs.eof and not rs.bof then
				dbver=rs(0)
			end if
			rs.close
		set rs=nothing


		if r_thisver>dbver then update
	end if

	set rs=conn.execute("select cpid,introduction from king__movie_config where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			r_cpid=rs(0)
			r_introduction=rs(1)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

end sub
'  *** Copyr ight &copy KingCMS.com All Rights Reserved ***
public property get path :path=r_path:end property
'  *** Copyr ight &copy KingCMS.com All Rights Reserved ***
public property get cpid :cpid=r_cpid:end property
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

	if king.instre("group,edtgroup",action) then
		Il "[<a href=""index.asp?action=group&listid="&listid&""">"&lang("common/grade")&"</a>"
		if instr(action,"group")>0 then
			Il "<a href=""index.asp?action=edtgroup&listid="&listid&""">"&lang("common/gradeadd")&"</a>"
		end if
	Il "]"
	else
		Il "["
		if len(listid)>0 and cstr(listid)<>"0" then
			Il "<a href=""index.asp?action=edt&listid="&listid&""">"&lang("common/add")&"</a>"
		end if
		Il "<a href=""javascript:;"" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=search');"">"&lang("common/search")&"</a>"
		Il "]"
		if len(listid)>0 and cstr(listid)<>"0" then
			Il "["
			Il "<a href=""index.asp?action=field&listid="&listid&""">"&lang("common/listk")&"</a>"
			if conn.execute("select count(listid) from king__movie_list where listid1="&listid&";")(0)>0 then
				Il "<a href=""index.asp?listid="&listid&""">"&lang("common/listdir")&"</a>"
			end if
			Il "<a href=""index.asp?action=edtlist&listid="&listid&""">"&lang("common/attrib")&"</a>"
			Il "]"
		end if
		Il "[<a href=""index.asp"">"&lang("common/home")&"</a>"
		Il "<a href=""index.asp?action=tree&listid="&listid&""">"&lang("common/tree")&"</a>"
		Il "<a href=""index.asp?action=edtlist&listid1="&listid&""">"&lang("common/addlist")&"</a>]"
	end if

	Il "["
	if r_cpid=18846 then
		Il "<a href="""&king.page&"system/link.asp?url=http%3A%2F%2Funion%2Exunlei%2Ecom%2F"" target=""_blank"">"&lang("common/u")&"</a>"
	end if
	Il "<a href=""javascript:posthtm('index.asp?action=set','flo','submits=cpid');"">"&lang("common/cpid")&"</a>"
	Il "]"

	if r_introduction=1 then
	Il "["
	Il "<a href=""javascript:;"" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=introduction');"">"&lang("common/introduction")&"</a>"
	Il "<a href=""javascript:;"" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=close');"">"&lang("common/close")&"</a>"
	Il "]"
	end if

	Il "["
	Il "<a href=""javascript:;"" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=today')"">"&lang("common/today")&"</a>"
	Il "]"

	Il "</span>"

	Il "</h2>"

	if cstr(listid)<>"0" and len(listid)>0 and (action="" or action="k") then
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

	set rs=conn.execute("select listid1,listname from king__movie_list where listid="&l1&";")
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
	
	set rs=conn.execute("select listid1,listname,listpath from king__movie_list where listid="&l1&";")
		if not rs.eof and not rs.bof then
			I1="<a href="""&king.inst&htmlencode(rs(2))&"/"">"&htmlencode(rs(1))&"</a>"
			if cstr(rs(0))<>"0" then I1=guide(rs(0))&" &gt;&gt; "&I1
		end if
		rs.close
	set rs=nothing

	guide=I1

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createpage(l1)
	dim tmphtm,outhtm,i,j,k,sql,rs,data,sql_field,fields,sql_fieldhtml
	dim listid,datalist,kfrom,kpath

	sql="kid,listid,ktitle,kkeywords,kdescription,kpath,kdate,kgrade,korder,khit,kup,kcommend,khead,kc_params"'13
	sql_field="kc_actor,kc_director,kc_image,kc_content,kc_lastdate"
	if len(sql_field)>0 then sql=sql&","&sql_field

	sql_fieldhtml="kc_content"


	if len(l1)=0 then exit sub

	set rs=conn.execute("select "&sql&" from king__movie_page where kid in ("&l1&");")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
		else
			redim data(0,-1)
		end if
		rs.close
	set rs=nothing

	for i=0 to ubound(data,2)
		if cstr(data(1,i))<>cstr(listid) then
			set rs=conn.execute("select listname,listpath,pagetemplate1,pagetemplate2,listcontent from king__movie_list where listid="&data(1,i)&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
					listid=data(1,i)
					tmphtm=king.read(datalist(2,0),r_path&"[page]/"&datalist(3,0))
				end if
				rs.close
			set rs=nothing
		end if

		king.clearvalue
		king.value "id",data(0,i)
		king.value "listid",data(1,i)
		king.value "listname",encode(htmlencode(datalist(0,0)))
		king.value "listcontent",encode(htmlencode(datalist(4,0)))
		king.value "listpath",encode(king.inst&datalist(1,0)&"/")
		king.value "title",encode(htmlencode(data(2,i)))
		king.value "keywords",encode(htmlencode(data(3,i)))
		king.value "description",encode(htmlencode(data(4,i)))
		king.value "path",encode(getpath(data(0,i),data(7,i),king.inst&datalist(1,0)&"/"&data(5,i)))
		king.value "date",encode(htmlencode(data(6,i)))
		king.value "guide",encode(guide(listid)&" &gt;&gt; "&htmlencode(data(2,i)))
		king.value "nextpage",encode(nextpage(data(0,i),data(8,i),data(1,i),datalist(1,0),tmphtm))'下一页
		king.value "lastpage",encode(lastpage(data(0,i),data(8,i),data(1,i),datalist(1,0),tmphtm,datalist(0,0)))'上一页
		king.value "up",data(10,i)
		king.value "commend",data(11,i)
		king.value "head",data(12,i)
		king.value "hit","<span id=""k_hit""><script type=""text/javascript"">posthtm('"&king.page&r_path&"/page.asp?action=hit','k_hit','kid="&data(0,i)&"');</script></span>"
		king.value "commentid",encode(r_path&"|"&data(0,i))'传递评论参数
		king.value "params",encode(paramhtm(data(0,i),datalist(1,0),data(13,i)))
		if len(sql_field)>0 then
			fields=split(sql_field,",")
			for j=0 to ubound(fields)
				if king.instre(sql_fieldhtml,fields(j)) then
					king.value kctag(fields(j)),encode(data(j+14,i))
				else
					king.value kctag(fields(j)),encode(htmlencode(data(j+14,i)))
				end if
			next
		end if

		outhtm=king.create(tmphtm,king.invalue)

		'生成文件
		kpath="../../"&datalist(1,0)&"/"&data(5,i)
		'非文件
		if king.isfile(data(5,i))=false then kpath=kpath&"/"&king_ext
		king.savetofile kpath,outhtm

	next

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function paramhtm(l1,l2,l3)'kid,listpath,param
	dim k,params,param2,outparam

	params=split(l3,chr(13)&chr(10))
	paramhtm=""
	for k=0 to ubound(params)

		if instr(params(k),"|")>0 then

			if len(paramhtm)=0 then
				king.value "param",encode(king.inst&l2&"/movie/"&l1&"_"&k&".htm")
			end if

			param2=split(params(k),"|")

			select case cstr(ubound(param2))
			case"1"
				if len(paramhtm)=0 then
					king.value "param",encode(king.inst&l2&"/movie/"&l1&"_"&k&".htm")
				end if

				paramhtm=paramhtm&"<a href=""javascript:;"" onclick=""javascript:KCOpenPlayer('"&king.inst&l2&"/movie/"&l1&"_"&k&".htm');"">"&param2(0)&"</a>"

				king.savetofile king.inst&l2&"/movie/"&l1&"_"&k&".htm","<html><body><style>*{margin:0px;padding:0px;}</style><script src=""http://play.kankan.xunlei.com/u/UPlayer/KKPlayer.js"" charset=""gbk""></script><div id=""KKPlayerContainer"" width=""542"" height=""481"" autoplay=""1"" unid="""&r_cpid&""" source="""&param2(1)&"""></body></html>"
				
			case"2"
				paramhtm=paramhtm&"<a href=""javascript:;"" onclick=""javascript:KCOpenPlayer('"&king.inst&l2&"/movie/"&l1&"_"&k&".htm');"">"&param2(0)&"</a>"

				outparam="<html><body><style>*{margin:0px;padding:0px;}</style><div id=""KKPlayerContainer""></div></body></html>"&vbcrlf
				outparam=outparam&"<SCRIPT type=""text/javascript"" charset=""GB2312"">"&vbcrlf
				outparam=outparam&"var params = new Object;"&vbcrlf
				outparam=outparam&"params.coid = "&r_cpid&";"&vbcrlf

				outparam=outparam&"params.serverId = "&param2(1)&";"&vbcrlf
				outparam=outparam&"params.filePath = """&param2(2)&""";"&vbcrlf

'				params.source="serverid|filePath"
'				params.source="mid=xxx&sid=xxx"

				outparam=outparam&"params.width = 538;"&vbcrlf
				outparam=outparam&"params.height = 476;"&vbcrlf
				outparam=outparam&"params.autoPlay = 1;"&vbcrlf
				outparam=outparam&"window.onload = function(){KKPlayer.play(params);}"&vbcrlf
				outparam=outparam&"</SCRIPT>"&vbcrlf
				outparam=outparam&"<SCRIPT src=""http://play.kankan.xunlei.com/u/KKPlayer/KKPlayer.js"" type=""text/javascript"" charset=""GB2312""></SCRIPT>"
				king.savetofile king.inst&l2&"/movie/"&l1&"_"&k&".htm",outparam
			case"3"
				'扩展？
			end select

		end if
	next
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub createlist(l1)
	dim tmphtm,outhtm
	dim tmphtmlist,tmplist
	dim jshtm,jsnumber,zebra
	dim rs,irs,i,j,k,data,datalist,pid,plist,pidcount,length'pidcount 总页数
	dim sql,suij,suijpagelist
	dim jsorder,listid,listpath,listname
	dim sql_field,fields,sql_fieldhtml

	if len(l1)=0 then exit sub

	sql="listid,listname,listpath,listtemplate1,listtemplate2,listtitle,listkeyword,listdescription,listcontent"'5 datalist
	set rs=conn.execute("select "&sql&" from king__movie_list where listid in ("&l1&");")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing

	sql_field="kc_actor,kc_director,kc_image,kc_content,kc_lastdate"
	sql_fieldhtml="kc_content"
'	sql="kid,listid,ktitle,kfrom,kdescription,kdate,kkeywords,kauthor,kpath,kimg,kgrade"'10 data
	sql="kid,listid,ktitle,kkeywords,kdescription,kpath,kdate,kgrade,korder,khit,kup,kcommend,khead,kc_params"'13
	if len(sql_field)>0 then sql=sql&","&sql_field

	for j=0 to ubound(datalist,2)

		'分析模板及标签，并获得值
		tmphtm=king.read(datalist(3,j),r_path&"[list]/"&datalist(4,j))'内外部模板结合后的htm代码
		tmphtmlist=king.getlist(tmphtm,r_path,1)'type="list"部分的tag，包括{king:/}
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
		king.value "listpath",encode(king.inst&datalist(2,j))
		king.value "keywords",encode(htmlencode(datalist(6,j)))
		king.value "description",encode(htmlencode(datalist(7,j)))
		king.value "listcontent",encode(htmlencode(datalist(8,j)))
		king.value "path",encode(king.inst&datalist(2,j))
		king.value "pagelist",encode(suijpagelist)
		king.value "listid",datalist(0,j)      '增加BY  RichWong 
		king.value "guide",encode(guide(datalist(0,j)))  '增加,可选的
		tmphtm=king.create(tmphtm,king.invalue)

		set rs=conn.execute("select "&sql&" from king__movie_page  where kshow=1 and listid="&datalist(0,j)&" or listids like '%,"&datalist(0,j)&",%' order by kup desc,korder "&jsorder&",kid "&jsorder&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				
				'初始化变量值
				pid=0
				pidcount=(ubound(data,2)+1)/jsnumber:if pidcount>int(pidcount) then pidcount=int(pidcount)+1'总页数
				length=ubound(data,2)'总记录数-1

				for i=0 to length'开始循环列表
				
					king.clearvalue
					king.value "id",data(0,i)
					king.value "listid",data(1,i)
					king.value "listname",encode(htmlencode(datalist(1,j)))
					king.value "listcontent",encode(htmlencode(datalist(8,j)))
					king.value "listpath",encode(king.inst&datalist(2,j))
					king.value "title",encode(htmlencode(data(2,i)))
					king.value "keywords",encode(htmlencode(data(3,i)))
					king.value "description",encode(htmlencode(data(4,i)))
					king.value "path",encode(getpath(data(0,i),data(7,i),king.inst&listpath&"/"&data(5,i)))
					king.value "date",encode(htmlencode(data(6,i)))
					king.value "hit",data(9,i)
					king.value "up",data(10,i)
					king.value "commend",data(11,i)
					king.value "head",data(12,i)
					king.value "zebra",king.mod2(i+1,zebra)
					king.value "commentid",encode(r_path&"|"&data(0,i))'传递评论参数
					king.value "params",encode(paramhtm(data(0,i),listpath,data(13,i)))
					if len(sql_field)>0 then
						fields=split(sql_field,",")
						for k=0 to ubound(fields)
							if king.instre(sql_fieldhtml,fields(k)) then
								king.value kctag(fields(k)),encode(data(k+14,i))
							else
								king.value kctag(fields(k)),encode(htmlencode(data(k+14,i)))
							end if
						next
					end if

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
	dim rs,irs,i,j,k,dp,data,datalist,pid,plist,pidcount,count,length'pidcount 总页数
	dim sql,suij,suijpagelist
	dim jsorder,listid,listpath,listname
	dim sql_field,fields,sql_fieldhtml

	if len(l1)=0 then exit sub

	sql="listid,listname,listpath,listtemplate1,listtemplate2,listtitle,listkeyword,listdescription,listcontent"'5 datalist
	set rs=conn.execute("select "&sql&" from king__movie_list where listid="&l1&";")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing

	sql_field="kc_actor,kc_director,kc_image,kc_content,kc_lastdate"
	sql_fieldhtml="kc_content"
'	sql="kid,listid,ktitle,kfrom,kdescription,kdate,kkeywords,kauthor,kpath,kimg,kgrade"'10 data
	sql="kid,listid,ktitle,kkeywords,kdescription,kpath,kdate,kgrade,korder,khit,kup,kcommend,khead,kc_params"'13
	if len(sql_field)>0 then sql=sql&","&sql_field

		'分析模板及标签，并获得值
		tmphtm=king.read(datalist(3,0),r_path&"[list]/"&datalist(4,0))'内外部模板结合后的htm代码
		tmphtmlist=king.getlist(tmphtm,r_path,1)'type="list"部分的tag，包括{king:/}
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
		king.value "listpath",encode(king.inst&datalist(2,0))
		king.value "keywords",encode(htmlencode(datalist(6,0)))
		king.value "description",encode(htmlencode(datalist(7,0)))
		king.value "listcontent",encode(htmlencode(datalist(8,0)))
		king.value "path",encode(king.inst&datalist(2,0))
		king.value "pagelist",encode(suijpagelist)
		king.value "listid",datalist(0,0)      '增加BY  RichWong 
		king.value "guide",encode(guide(datalist(0,0)))  '增加,可选的
		tmphtm=king.create(tmphtm,king.invalue)

	set dp=new record
		dp.pid=l2
		dp.rn=jsnumber
		dp.create "select "&sql&" from king__movie_page where kshow=1 and listid="&datalist(0,0)&" or listids like '%,"&datalist(0,0)&",%' order by kup desc,korder "&jsorder&",kid "&jsorder&";"

		if dp.length>-1 then
			'初始化变量值
			pid=l2
			count=dp.count'总记录数
			pidcount=dp.pagecount'总页数
			length=dp.length'页记录数

			for i=0 to length'开始循环列表
			
				king.clearvalue
				king.value "id",dp.data(0,i)
				king.value "listid",dp.data(1,i)
				king.value "listname",encode(htmlencode(datalist(1,0)))
				king.value "listcontent",encode(htmlencode(datalist(8,0)))
				king.value "listpath",encode(king.inst&datalist(2,0))
				king.value "title",encode(htmlencode(dp.data(2,i)))
				king.value "keywords",encode(htmlencode(dp.data(3,i)))
				king.value "description",encode(htmlencode(dp.data(4,i)))
				king.value "path",encode(getpath(dp.data(0,i),dp.data(7,i),king.inst&listpath&"/"&dp.data(5,i)))
				king.value "date",encode(htmlencode(dp.data(6,i)))
				king.value "hit",dp.data(9,i)
				king.value "up",dp.data(10,i)
				king.value "commend",dp.data(11,i)
				king.value "head",dp.data(12,i)
				king.value "zebra",king.mod2(i+1,zebra)
				king.value "commentid",encode(r_path&"|"&dp.data(0,i))'传递评论参数
				king.value "params",encode(paramhtm(dp.data(0,i),listpath,dp.data(13,i)))
				if len(sql_field)>0 then
					fields=split(sql_field,",")
					for k=0 to ubound(fields)
						if king.instre(sql_fieldhtml,fields(k)) then
							king.value kctag(fields(k)),encode(dp.data(k+14,i))
						else
							king.value kctag(fields(k)),encode(htmlencode(dp.data(k+14,i)))
						end if
					next
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
				king.savetofile "../../"&datalist(2,0)&"/"&pid&"/"&king_ext,outhtm
			end if

		else
			outhtm=replace(tmphtm,suij,king.lang("error/rsnot"))
			outhtm=replace(outhtm,suijpagelist,"")
			king.savetofile "../../"&datalist(2,0)&"/"&king_ext,outhtm
		end if
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function pageslist(l1,l2,l3,l4,l5)'url，当前，总页,kgrade,kid
	if l3=1 then exit function
	dim i,I1
	
	if cstr(l4)="0" then
		for i=1 to l3
			if cstr(i)=cstr(l2) then
				I1=I1&"<strong>"&i&"</strong>"
			else
				if cstr(i)="1" then
					I1=I1&"<a href="""&l1&""">1</a>"
				else
					I1=I1&"<a href="""&pagepath(l1,i)&""">"&i&"</a>"
				end if
			end if
		next
	else
		for i=1 to l3
			if cstr(i)=cstr(l2) then
				I1=I1&"<strong>"&i&"</strong>"
			else
				if cstr(i)="1" then
					I1=I1&"<a href="""&king.page&r_path&"/page.asp?kid="&l5&""">1</a>"
				else
					I1=I1&"<a href="""&king.page&r_path&"/page.asp?kid="&l5&"&pid="&i&""">"&i&"</a>"
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
	set rs=conn.execute("select top "&king.mapnumber&" kdate,kpath,kid,listid,kcommend,khead from king__movie_page where kshow=1 and kgrade=0 order by kid desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			outmap="<?xml version=""1.0"" encoding=""UTF-8""?>"
			outmap=outmap&"<urlset xmlns="""&king_map_xmlns&""">"
			for i=0 to ubound(data,2)
				if cstr(listid)<>cstr(data(3,i)) then
					listid=data(3,i)
					set irs=conn.execute("select listpath from kingk_list where listid="&listid&";")
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
			king.savetofile "../../"&kc.path&".xml",outmap
		end if
		rs.close
	set rs=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function kctag(l1)
	if len(l1)>3 then
		kctag=right(l1,len(l1)-3)
	else
		king.error king.lang("error/invalid")
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function getpath(l1,l2,l3)'kid,grade,path
	if cstr(l2)="0" then
		if king.isfile(l3) then'file
			getpath=l3
		else
			getpath=l3&"/"
		end if
	else
		getpath=king.page&r_path&"/page.asp?kid="&l1
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function lastpage(l1,l2,l3,l4,l5,l6)'上一页
	if instr(lcase(l5),"{king:lastpage")>0 then
		dim rs,I1
		set rs=conn.execute("select top 1 ktitle,kgrade,kpath,kid from king__movie_page where kshow=1 and listid="&l3&" and korder<"&l2&" order by korder desc,kid desc;")
			if not rs.eof and not rs.bof then
				I1="<a href="""&getpath(rs(3),rs(1),king.inst&l4&"/"&rs(2))&""">"&htmlencode(rs(0))&"</a>"
			else'如果不存在，则输出js加载来验证
				I1="<a href="""&king.inst&l4&"/"">["&htmlencode(l6)&"]</a>"
			end if
			rs.close
		set rs=nothing
		lastpage="<span id=""k_lastpage"">"&I1&"</span>"
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function nextpage(l1,l2,l3,l4,l5)'kid,korder,listid,listpath,tmphtm //下一页
	if instr(lcase(l5),"{king:nextpage")>0 then
		dim rs,I1
		set rs=conn.execute("select top 1 ktitle,kgrade,kpath,kid from king__movie_page where kshow=1 and listid="&l3&" and korder>"&l2&" order by korder asc,kid asc;")
			if not rs.eof and not rs.bof then
				I1="<a href="""&getpath(rs(3),rs(1),king.inst&l4&"/"&rs(2))&""">"&htmlencode(rs(0))&"</a>"
'			out I1
			else'如果不存在，则输出js加载来验证
				I1="<script type=""text/javascript"">posthtm('"&king.page&r_path&"/page.asp?action=nextpage','k_nextpage','kid="&l1&"');</script>"
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
	if king.instre("0,1",l2) or len(l2)=0 then
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
		pagepath=I2(1)&"_"&l2&I2(0)
	else
		pagepath=l1&"/"&l2&"/"
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function getgrade(l1,l2)'返回会员组名称  l1 groupnum l2
	dim I1,rs
	select case cstr(l1)
	case"0","1" I1=kc.lang("list/grade"&l1)
	case else
		set rs=conn.execute("select groupname from king__movie_group where groupnum="&l1&";")
			if not rs.eof and not rs.bof then
				I1=htmlencode(rs(0))
			else
				I1=kc.lang("list/grade1")
				conn.execute "update king__movie_page set kgrade=1 where kid="&l2&";"
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
		set rs=conn.execute("select groupuser from king__movie_group where groupnum="&l1&";")
			if not rs.eof and not rs.bof then
				if king.instre(rs(0),king.name)=false then'如果不属于用户组，就提示错误
					king.error kc.lang("error/nogroup")
				end if
			else
				conn.execute "update king__movie_page set kgrade=1 where kgrade="&l1&";"
			end if
			rs.close
		set rs=nothing
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub xlinsert(sub_type,xlname,xlactor,xldirector,xlcontent,xlimage,xlfile,xlparams)
	dim rs,listid,kc_image
	set rs=conn.execute("select listid from king__movie_list where listname='"&safe(sub_type)&"';")
		if not rs.eof and not rs.bof then
			listid=rs(0)
		else'如果没有这个list，则需要新添加一个
			conn.execute "insert into king__movie_list (listname,listpath,listtemplate1,listtemplate2,pagetemplate1,pagetemplate2,listid1,listkeyword,listdescription,listtitle,listorder) values ('"&safe(sub_type)&"','"&safe(king.pinyin(sub_type))&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"',0,'"&safe(sub_type)&"','"&safe(sub_type)&"','"&safe(sub_type)&"',"&king.neworder("king__movie_list","listorder")&")"
			listid=king.newid("king__movie_list","listid")
		end if
		rs.close
	set rs=nothing

	set rs=conn.execute("select kid from king__movie_page where ktitle='"&safe(xlname)&"';")
		if not rs.eof and not rs.bof then
		else
			'抓图

			if validate(xlimage,5) then
				kc_image=king.inst&king_upath&"/image/"&kc.path&"/"&formatdate(date(),2)&"/"&int(timer()*100)&"."&king.extension(xlimage)
				king.createfolder kc_image
				king.remote2local xlimage,kc_image
			end if

			if len(xlactor)>0 then
				xlactor=replace(xlactor,"|",",")
			end if

			conn.execute "insert into king__movie_page (ktitle,kkeywords,kdescription,kpath,kc_actor,kc_director,kc_image,kc_params,kc_content,kc_lastdate,kdate,korder,listid,kshow) values ('"&safe(xlname)&"','"&safe(king.key(xlname,""))&"','"&safe(king.lefte(king.clshtml(xlcontent),250))&"','"&safe(king.pinyin(xlname)&salt(3))&"','"&safe(xlactor)&"','"&safe(xldirector)&"','"&safe(kc_image)&"','"&safe(xlparams)&"','"&safe(xlcontent)&"','"&tnow&"','"&tnow&"',"&king.neworder("king__movie_page","korder")&","&listid&",1)"
		end if
		rs.close
	set rs=nothing
end sub 
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function file_list(l1)
	dim file,item,i,filename,fileparams,I1
	set file=server.createobject(king_xmldom)
	file.async=false
	file.loadxml(l1)'## file
	if file.readystate>2 then
		set item=file.getelementsbytagname("file")
		for i=0 to (item.length-1)
			set filename=item.item(i).getelementsbytagname("name")
			set fileparams=item.item(i).getelementsbytagname("params")
			I1=I1&filename.item(0).text&"|"&fileparams.item(0).text&chr(13)&chr(10)
		next
	end if
	set file=nothing
	file_list=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function xlintroduction(l1)
	dim I1,I2,xml,item,i,xlparams
	dim xlname,xlactor,xldirector,xlcontent,xlimage,xldate,xlfile
	dim sub_type
	dim filename,fileparams

	l1=king.gethtm(l1,5)'

	I1=false

	if len(l1)>0 then'如果有资料
		if left(l1,5)="<?xml" then
			set xml=server.createobject(king_xmldom)
			xml.async=false
			xml.loadxml(l1)'## xml <==> movie_list
			if xml.readystate>2 then

				set item=xml.getelementsbytagname("movie")'## item <==> movie
				for i=0 to (item.length-1)
					sub_type=king.sect(item(i).xml,"sub_type=""","""","")
					set xlname=item.item(i).getelementsbytagname("name")
					set xlactor=item.item(i).getelementsbytagname("actor")
					set xldirector=item.item(i).getelementsbytagname("director")
					set xlcontent=item.item(i).getelementsbytagname("description")
					set xlimage=item.item(i).getelementsbytagname("big_pic")
					set xlfile=item.item(i).getelementsbytagname("file_list")

					xlparams=kc.file_list(xlfile.item(0).xml)

					kc.xlinsert sub_type,xlname.item(0).text,xlactor.item(0).text,xldirector.item(0).text,htmldecode(xlcontent.item(0).text),xlimage.item(0).text,xlfile.item(0).text,xlparams
				next
			end if
			I1=true
		end if
	end if
	xlintroduction=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public sub uptoday()
	king.nocache
	Server.ScriptTimeOut=86400
	'获取当前最大的kid
	dim maxid,rs,data,i,listid
	dim one,jstime

	jstime=quest("time",0)

	listid=""

	maxid=conn.execute("select max(kid) from king__movie_page;")(0)
	if len(maxid)>0 then
	else
		maxid=0
	end if

	if kc.xlintroduction("http://u.xunlei.com/xml/"&formatdate(dateadd("d",-1,tnow),"yyyyMMdd")&".xml") then'20071101
		king.savetofile "update.js",kc.updatejs(jstime)'创建日期文件 //及时生成js文件，以免再次被激活。
		'读取大于上面的kid的值，并生成，同时获得对应的栏目列表
		listid=createmovie(maxid)
		'并且生成栏目列表
		if len(listid)>0 then
			kc.createlist listid
		end if
		'判断是否有onepage首页，并生成对应的首页。
		if king.instre(king.plugin,"onepage") then
			if king.checkcolumn("kingonepage") then'需要单页面数据库存在
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
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
private function createmovie(l1)
	Server.ScriptTimeOut=86400
	dim rs,data,i,listid
		set rs=conn.execute("select kid,listid from king__movie_page where kid>"&l1&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				for i=0 to ubound(data,2)
					kc.createpage data(0,i)
					if king.instre(listid,data(1,i))=false then
						if len(listid)>0 then
							listid=listid&","&data(1,i)
						else
							listid=data(1,i)
						end if
					end if
				next
			end if
			rs.close
		set rs=nothing
	createmovie=listid
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install()
	king.head "admin",0
	dim sql
' king__movie_page 
	sql="kid int not null identity primary key,"
	sql=sql&"korder int not null default 0,"'排序

	sql=sql&"kup int not null default 0,"'置顶
	sql=sql&"kshow int not null default 0,"'默认草稿
	sql=sql&"kcommend int not null default 0,"'推荐
	sql=sql&"khead int not null default 0,"'头条,头条必须要上传图片
	sql=sql&"kgrade int not null default 0,"'默认级别 0直接生成html 1:限会员访问 4:限vip访问

	sql=sql&"khit int not null default 0,"'点击率,播放次数

	sql=sql&"kinput nvarchar(30),"'录入
	sql=sql&"kkeywords nvarchar(120),"'关键字，不给显示但需要记录
	sql=sql&"kdescription nvarchar(255),"'简述，也不给显示
	sql=sql&"kpath nvarchar(255) not null,"'文件名称

	sql=sql&"listid int not null default 0,"'主栏目
	sql=sql&"listids ntext,"

	sql=sql&"kdate datetime,"'添加时间

	sql=sql&"ktitle nvarchar(50) not null"'名称
	conn.execute "create table king__movie_page ("&sql&")"

'king__movie_list
	sql="listid int not null identity primary key,"
	sql=sql&"listid1 int not null default 0,"'
	sql=sql&"listorder int not null default 0,"'排序

	sql=sql&"listname nvarchar(30),"
	sql=sql&"listtitle nvarchar(100),"'栏目标题
	sql=sql&"listkeyword nvarchar(120),"'栏目关键字
	sql=sql&"listdescription nvarchar(250),"'description

	sql=sql&"listpath nvarchar(100),"'路径

	sql=sql&"lastdate datetime,"'最后一次添加时间

	sql=sql&"listtemplate1 nvarchar(50),"
	sql=sql&"listtemplate2 nvarchar(50),"
	sql=sql&"pagetemplate1 nvarchar(50),"
	sql=sql&"pagetemplate2 nvarchar(50)"
	conn.execute "create table king__movie_list ("&sql&")"

' king__movie_group
	sql="groupid int not null identity primary key,"
	sql=sql&"groupnum int not null default 0,"'代号
	sql=sql&"groupname nvarchar(50),"
	sql=sql&"groupuser ntext"'成员列表
	conn.execute "create table king__movie_group ("&sql&")"
' king__movie_config
	sql="systemname nvarchar(10),"
	sql=sql&"cpid int not null default 18846,"'迅雷联盟id
	sql=sql&"introduction int not null default 1,"'导入迅雷片源
	sql=sql&"kversion real not null default 1"
	conn.execute "create table king__movie_config ("&sql&")"

	conn.execute "insert into king__movie_config (systemname) values ('KingCMS');"
	'插入sitemap
'	conn.execute "insert into kingsitemap (maploc,maplastmod) values ('"&r_path&"','"&tnow&"')"
	king.createmap
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub update()
	dim sql
	on error resume next
	conn.execute "alter table king__movie_page add kc_actor nvarchar(255) "
	conn.execute "alter table king__movie_page add kc_director nvarchar(255) "
	conn.execute "alter table king__movie_page add kc_image nvarchar(255) "
	conn.execute "alter table king__movie_page add kc_player nvarchar(255) "
	conn.execute "alter table king__movie_page add kc_params ntext "
	conn.execute "alter table king__movie_page add kc_content ntext "
	conn.execute "alter table king__movie_page add kc_lastdate nvarchar(255) "
	conn.execute "alter table king__movie_config add kc_update datetime "'1.0009
	conn.execute "alter table king__movie_list add listcontent ntext "

'	conn.execute "update king__movie_config set kc_update='"&formatdate(dateadd("d",-2,tnow),"yyyy-MM-dd 0:0:0")&"' where systemname='KingCMS'"

	conn.execute "update  set kversion="&r_thisver&" where systemname='KingCMS';"


end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function updatejs(l1)
	dim I1
	I1="var datediff=getdom('"&king.page&"system/now.asp?datetime="&server.urlencode(tnow)&"');"
	if validate(l1,2) then
		I1=I1&"if(datediff>"&l1&"){getdom('"&king.page&"movie/create.asp?time="&l1&"');};"
	else
		I1=I1&"if(datediff>"&r_uptime&"){getdom('"&king.page&"movie/create.asp');};"
	end if
	updatejs=I1
'	if cdbl(hour(tnow))>12 then'如果是10点以后，则输出今日日期
'		I1="var datediff=getdom('"&king.page&"system/now.asp?datetime="&server.urlencode(formatdate(tnow,"yyyy-M-d 0:0:0"))&"');"
'	else
'		I1="var datediff=getdom('"&king.page&"system/now.asp?datetime="&server.urlencode(formatdate(dateadd("d",-1,tnow),"yyyy-M-d 0:0:0"))&"');"
'	end if
'	I1=I1&"if(datediff>36){getdom('"&king.page&"movie/create.asp');};"
	updatejs=I1
end function


end class

































'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_movie_list(tag,invalue)
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
			set rs=conn.execute("select listid1 from king__movie_list where listid="&listid&" order by listorder desc,listid desc;")
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

	set rs=conn.execute("select listid,listname,listpath,listdescription,listcontent from king__movie_list where "&insql_id1&" order by listorder desc,listid desc;")
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

	king_tag_movie_list=tmplist

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_movie_double(tag,invalue)
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
			insql_id=king_tag_movie_getsublist(listid)
		case else
			insql_id=" listid in ("&jslistid&")"
		end select
	else
		jslistname=king.getlabel(tag,"listname")
		if len(jslistname)>0 then
			set rs=conn.execute("select listid from king__movie_list where "&king.likey("listname",jslistname)&" order by listorder desc,listid desc;")
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
	set rs=conn.execute("select "&sql&" from king__movie_list where "&insql_id&" order by listorder desc,listid desc;")
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

	king_tag_movie_double=tmplist
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_movie(tag,invalue)
	on error resume next'这个必须要开启

	if left(tag,2)="{{" then
		king_tag_movie=king_tag_movie_double(tag,invalue)
		exit function
	end if

	dim ttype,tnumber,tkey,tlikey,jshtm,zebra
	dim rs,i,k,data,sql,insql,tmplist,listid
	dim t_class,datalist,kfrom,kid
	dim jslistid,jslistname,insql_id
	dim jssql,jskeywords,insql_key
	dim jsimg,insql_img
	dim sql_field,fields,sql_fieldhtml
	dim jsnext ' 1220

'	sql=" kid,listid,ktitle,kfrom,kdescription,kdate,kkeywords,kauthor,kpath,kimg,kgrade"'10 data
	sql=" kid,listid,ktitle,kkeywords,kdescription,kpath,kdate,kgrade,korder,khit,kup,kcommend,khead,kc_params"'13
	sql_field="kc_actor,kc_director,kc_image,kc_content,kc_lastdate"
	sql_fieldhtml="kc_content"
	if len(sql_field)>0 then sql=sql&","&sql_field

	ttype=king.getlabel(tag,"type")
	tnumber=king.getlabel(tag,"number")
	zebra=king.getlabel(tag,"zebra")
	jshtm=king.getlabel(tag,0)
	jssql=king.getlabel(tag,"sql")
	jsnext=king.getlabel(tag,"next") ' 1220
	if validate(jsnext,2)=false then jsnext=0 ' 1220
	tnumber=tnumber+int(jsnext) ' 1220


	if king.instre(sql_field,"kc_image") then
		if len(king.match(jshtm,"\(king:image.{0,}?\/\)"))>0 then
			insql_img=" and (kc_image like '%.gif' or kc_image like '%.jpeg' or kc_image like '%.jpg' or kc_image like '%.png' or kc_image like '%.bmp') "
		end if
	end if

	jskeywords=king.getlabel(tag,"keywords")
	if len(jskeywords)>0 then
		insql_key=king.likey("kkeywords",jskeywords)
		if len(insql_key)>0 then
			insql_key=" and ("&insql_key&")"
		end if
	end if

	jslistid=king.getlabel(tag,"listid")
	if validate(jslistid,6) or king.instre("sub,current",jslistid) then
		select case lcase(jslistid)
		case"sub"'只调用当前栏目下面的，并不是所有的，若加入所有，需要递归，麻烦
			listid=king.getvalue(invalue,"listid")
			insql_id=" and "&king_tag_movie_getsublist(listid)
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
			set rs=conn.execute("select listid from king__movie_list where "&king.likey("listname",jslistname)&";")
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

	set t_class=new movieclass
	Randomize
	select case lcase(ttype)
	case"related"'相关文章
		tkey=king.getvalue(invalue,"keywords")
		kid=king.getvalue(invalue,"kid")
		tlikey=king.likey("keywords",tkey)
		if len(tlikey)>0 then tlikey=" and ("&tlikey&")"
		if len(tlikey)>0 then
			if validate(kid,2) then
				insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&tlikey&insql_id&insql_key&" and kid<>"&kid&" order by korder desc,kid desc;"
			else
				insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&tlikey&insql_id&insql_key&" order by korder desc,kid desc;"
			end if
		else
			exit function
		end if
	case"hot"'热门
		insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&insql_id&insql_key&insql_img&" order by khit desc,kid desc;"
	case"chill","cold"'冷门
		insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&insql_id&insql_key&insql_img&" order by khit asc,kid asc;"
	case"head"'头条
		insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&insql_id&insql_key&insql_img&" and khead=1 order by korder desc,kid desc;"
	case"commend"'推荐
		insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&insql_id&insql_key&insql_img&" and kcommend=1 order by korder desc,kid desc;"
	case"rnds"'随机
		insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&insql_id&insql_key&insql_img&" order by rnd(-(kid+"&rnd()&"));"
	case"sql"'自定义的
		insql="select top "&tnumber&sql&" from king__movie_page "&jssql
	case else '最新文章
		insql="select top "&tnumber&sql&" from king__movie_page where kshow=1 "&insql_id&insql_key&insql_img&" order by korder desc,kid desc;"
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
	for i=int(jsnext) to ubound(data,2)
		if cstr(listid)<>cstr(data(1,i)) then
			listid=data(1,i)
			set rs=conn.execute("select listname,listpath from king__movie_list where listid="&listid&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
				else
					exit function
				end if
				rs.close
			set rs=nothing
		end if

'		sql="kid,listid,ktitle,kkeywords,kdescription,kpath,kdate,kgrade,korder,khit,kup,kcommend,khead"'12

		king.clearvalue
		king.value "id",data(0,i)
		king.value "listid",data(1,i)
		king.value "listname",encode(htmlencode(datalist(0,0)))
		king.value "listpath",encode(king.inst&datalist(1,0))
		king.value "title",encode(htmlencode(data(2,i)))
		king.value "keywords",encode(htmlencode(data(3,i)))
		king.value "description",encode(htmlencode(data(4,i)))
		king.value "path",encode(t_class.getpath(data(0,i),data(7,i),king.inst&datalist(1,0)&"/"&data(5,i)))
		king.value "date",encode(htmlencode(data(6,i)))
		king.value "hit",data(9,i)
		king.value "up",data(10,i)
		king.value "commend",data(11,i)
		king.value "head",data(12,i)
		king.value "zebra",king.mod2(i+1,zebra)
		king.value "commentid",encode(t_class.path&"|"&data(0,i))
		king.value "params",encode(t_class.paramhtm(data(0,i),datalist(1,0),data(13,i)))
		if len(sql_field)>0 then
			fields=split(sql_field,",")
			for k=0 to ubound(fields)
				if king.instre(sql_fieldhtml,fields(k)) then
					king.value t_class.kctag(fields(k)),encode(data(k+14,i))
				else
					king.value t_class.kctag(fields(k)),encode(htmlencode(data(k+14,i)))
				end if
			next
		end if
		king.value "++",i+1


		tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量
	next

	set t_class=nothing

	if err.number<>0 then
		err.clear
		tmplist=king.errtag(tag)
	end if

	king_tag_movie=tmplist
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_movie_getsublist(l1)
	dim rs,data,i,I1
	if validate(l1,2) then
		set rs=conn.execute("select listid from king__movie_list where listid1="&l1&";")
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
			end if
			rs.close
		set rs=nothing
	end if
	king_tag_movie_getsublist=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_movie_update(tag)
	on error resume next
	dim t_class,jstime
	jstime=king.getlabel(tag,"time")
	set t_class=new movieclass
		king.savetofile king.page&"movie/update.js",t_class.updatejs(jstime)'创建日期文件
	set t_class=nothing

	if err.number<>0 then
		err.clear
		king_tag_movie_update=king.errtag(tag)
	else
		king_tag_movie_update="<script src="""&king.page&"movie/update.js""></script>"
	end if


end function

%>