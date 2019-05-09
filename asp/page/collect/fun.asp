<%
class collectclass
private r_doc,r_path,r_filepath,r_uptime,r_fileext,r_version,r_listpath

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()

	r_path = "collect"

	r_listpath = "html/list_" '列表目录前缀

	r_uptime = 1 '每1个小时自动更新,用js读取修改时间，然后激活生成

	r_version = 1.00

	if king.checkcolumn("kingcollect_config")=false then install
end sub
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get uptime
	uptime=r_uptime
end property
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get path
	path=r_path
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
public function colistname()
	
	dim I1,I2,listid
	dim rs,data,i

	listid=form("list")

	if validate(listid,2)=false then king.flo king.lang("error/invalid")&"colistname1",3

	if len(session("colistname_"&listid))>0 then
		colistname=session("colistname_"&listid)
	else
		set rs=conn.execute("select kplugin from kingcollect_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				I1=rs(0)
			else
				king.flo king.lang("error/invalid")&"colistname2",3
			end if
			rs.close
		set rs=nothing

		if king.instre("article",I1) then
			I2="arttitle,artauthor,artfrom,artcontent,artkeywords,artdescription,artimg,artdate"
		else
			I2="ktitle"
			set rs=conn.execute("select fname from kingoo_field where ooid in (select ooid from kingoo where oocolumn='"&I1&"')")
				data=rs.getrows()
				for i=0 to ubound(data,2)
					I2=I2&","&data(0,i)
				next
				rs.close
			set rs=nothing
		end if

		colistname="guide,"&I2

		session("colistname_"&listid)=colistname
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function colist(l1)
	dim I1,I2
	dim rs,data,i
	set rs=conn.execute("select kplugin from kingcollect_list where listid="&l1&";")
		if not rs.eof and not rs.bof then
			I1=rs(0)
		else
			king.error king.lang("error/invalid")&"colist"
		end if
		rs.close
	set rs=nothing

	if king.instre("article",I1) then
		I2="arttitle:"&encode(lang("kc/title"))&"|artauthor:"&encode(lang("kc/author"))&"|artfrom:"&encode(lang("kc/from"))&"|artcontent:"&encode(lang("kc/content"))&"|artkeywords:"&encode(lang("kc/keywords"))&"|artdescription:"&encode(lang("kc/description"))&"|artimg:"&encode(lang("kc/img"))&"|artdate:"&encode(lang("kc/date"))
	else
		I2="ktitle:"&encode(kc.lang("common/title"))
		set rs=conn.execute("select fname,ftitle from kingoo_field where ooid in (select ooid from kingoo where oocolumn='"&I1&"')")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				for i=0 to ubound(data,2)
					I2=I2&"|"&data(0,i)&":"&encode(king.clsre(data(1,i),"(\(.+?\))"))
				next
			end if
			rs.close
		set rs=nothing
	end if

	colist="guide:"&encode(kc.lang("kc/guide"))&"|"&I2
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub list()
	Il "<h2>"&lang("title")


	Il "<span class=""listmenu"">["
	Il "<a href=""index.asp"">"&lang("common/list")&"</a>"
	Il "<a href=""index.asp?action=edt"">"&lang("common/add")&"</a>"

	Il "]</span>"
	Il "</h2>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install_url(l1)
	dim sql
	on error resume next
	if king.checkcolumn("kingcollect_url_"&l1)=false then
		'url
		sql="id int not null identity primary key,"
		sql=sql&"isok int not null default 0,"'0 NULL;1 OK;2 失败
		sql=sql&"urlpath nvarchar(255) UNIQUE"
		conn.execute "create table kingcollect_url_"&l1&" ("&sql&")"
		'title
		sql="id int not null identity primary key,"
		sql=sql&"ktitle nvarchar(255) UNIQUE"
		conn.execute "create table kingcollect_title_"&l1&" ("&sql&")"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub install()
	king.head "admin",0
	dim sql
	'kingcollect_list
		sql="listid int not null identity primary key,"
		sql=sql&"kname nvarchar(50),"'项目名称
		sql=sql&"kplugin nvarchar(50),"'对应模块 直接记录模块的目录名称,不能做修改
		sql=sql&"kcommend int not null default 1000,"'1/推荐率 不能为0
		sql=sql&"khead int not null default 1000,"'1/头条率 不能为0
		sql=sql&"kshow int not null default 1,"'是否直接显示 若设置为显示，则直接生成对应的项目及列表
		sql=sql&"ishit int not null default 0,"'点击率 是否设置为随机数
		sql=sql&"iscrtlist int not null default 1,"'是否自动创建列表
		sql=sql&"kpath int not null default 1,"'路径命名 0拼音 1数字 2日期＋数字
		sql=sql&"kurlstart nvarchar(255),"'开始采集地址
		sql=sql&"kurlinc nvarchar(255),"'被搜集网址包含的url 支持正则
		sql=sql&"kurltest nvarchar(255),"'测试url地址
		sql=sql&"isimg int not null default 0,"'是否下载图片 1下载
		sql=sql&"ntime int not null default 0,"'采集间隔设置 单位：毫秒
		sql=sql&"kurlincpage nvarchar(255)"'采集数据的页面url，支持正则
		conn.execute "create table kingcollect_list ("&sql&")"
	'kingcollect_rule 
		sql="kid int not null identity primary key,"
		sql=sql&"klistname nvarchar(50),"'字段名称
		sql=sql&"listid int not null default 0,"'所属列表
		sql=sql&"kstart ntext,"'开始截取
		sql=sql&"kend ntext,"'结束截取
		sql=sql&"kdefault nvarchar(100),"'默认值
		sql=sql&"kclear ntext,"'过滤的内容，多个内容之间是用换行分开
		sql=sql&"kreplace ntext,"'替换的内容，多个内容之间用换行分开，AAA=>BBB
		sql=sql&"kclshtml nvarchar(255),"'清理html，*为所有，或指定清理，如：div,p,img
		sql=sql&"isloop int not null default 0,"'是否循环截取，1是 0否
		sql=sql&"ishave int not null default 0,"'是否为必须的项目，没有这个项目就不会截取
		sql=sql&"isxhtml int not null default 0,"'是否转换为xhtml格式
		sql=sql&"isreturn int not null default 0,"'是否清理换行符
		sql=sql&"isok int not null default 0,"'设置是否ok？
		sql=sql&"kguide ntext,"'导航分隔符
		sql=sql&"istt int not null default 0,"'最后一个块是否为标题 1标题 0列表
		sql=sql&"ksize int not null default 0,"'长度限定
		sql=sql&"isimg int not null default 0"'是否截取缩略图
		conn.execute "create table kingcollect_rule ("&sql&")"
	'kingcollect_config
		sql="kid int not null identity primary key,"
		sql=sql&"kversion real not null default 1.00"
		conn.execute "create table kingcollect_config ("&sql&")"
		conn.execute "insert into kingcollect_config (kversion) values (1.0)"


end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub instart(l1)
	if conn.execute("select count(id) from kingcollect_url_"&l1&";")(0)=0 then
		conn.execute "insert into kingcollect_url_"&l1&" (urlpath) values ('"&safe(datalist(7))&"');"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function datalist(l1)'缓冲数据并获得数据 buff(NUM)
	dim listid,rs,data,sql
	sql="kplugin,kcommend,khead,kshow,ishit,iscrtlist,kpath,kurlstart,kurlinc,isimg,ntime,kurlincpage"'11

	listid=form("list")

	if validate(listid,2)=false then king.flo king.lang("error/invalid")&"datalist",3

	data=session("collect_list_"&listid)

	if isarray(data)=false then
		set rs=conn.execute("select "&sql&" from kingcollect_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				session("collect_list_"&listid)=rs.getrows()
				data=session("collect_list_"&listid)
			end if
			rs.close
		set rs=nothing
	end if

	datalist=data(l1,0)
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function datarule(l1)'缓冲数据并获得数据 buff(NUM1,NUM2) l1:klistname
	dim listid,rs,data,sql
	sql="klistname,listid,kstart,kend,kdefault,kclear,kreplace,kclshtml,isloop,ishave,isxhtml,isreturn,isok,kguide,istt,isimg,ksize"'16

	listid=form("list")

	if validate(listid,2)=false then king.flo king.lang("error/invalid")&"datarule",3

	data=session("collect_rule_"&listid&"_"&l1)

	if isarray(data)=false then

		set rs=conn.execute("select "&sql&" from kingcollect_rule where listid="&listid&" and klistname='"&safe(l1)&"';")
			if not rs.eof and not rs.bof then
				session("collect_rule_"&listid&"_"&l1)=rs.getrows()
				data=session("collect_rule_"&listid&"_"&l1)
			else
				king.flo kc.lang("flo/setcollect")&":"&l1,3
			end if
			rs.close
		set rs=nothing

	end if

	datarule=data


end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function rndn()
	if cstr(datalist(4))="1" then
		randomize
		rndn=round((rnd*987654)+1) mod 1000
	else
		rndn=0
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function rndp(num)'rnd percent
	dim I1
	randomize

	I1=round((rnd*987654)+1) mod num
	if I1=1 then
		rndp=1
	else
		rndp=0
	end if

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function isurlincpage(url,id)
	if left(datalist(id),1)="(" and right(datalist(id),1)=")" then
		if validate(url,datalist(id)) then
			isurlincpage=true
		else
			isurlincpage=false
		end if
	else
		if instr(lcase(url),lcase(datalist(id)))>0 then
			isurlincpage=true
		else
			isurlincpage=false
		end if
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function getpath(l1,neworder)
	select case cstr(datalist(6))
	case"0"
		getpath=king.pinyin(l1)
	case"1"
		getpath=neworder
	case"2"
		getpath=formatdate(now(),"yyyy/MM/dd/")&neworder
	end select
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function intitle(l1,colistid)
	intitle=true
	on error resume next
	conn.execute "insert into kingcollect_title_"&colistid&" (ktitle) values ('"&safe(l1)&"')"
	if err.number<>0 then
		err.clear
		intile=false
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function getcontent(url,kplugin,colistid)'获取内容到数据库
	on error resume next
	dim I1,I2,I3,i,neworder
	dim data,rule'Array
	dim kid,clsname,exec
	dim sql,oosql,oodata

	dim html3'文本类型HTML

	I1=1'默认设置为1,即成功

	I2=king.gethtm(url,4)

	sql=colistname()

	I3=split(sql,",")


	if isurlincpage(url,11) then
		redim data(ubound(I3),0)
		for i=0 to ubound(I3)
			rule=datarule(I3(i))

			data(i,0)=gethtm(I2,rule,kplugin,url)

			if cstr(rule(9,0))="1" and len(data(i,0))=0 then
				I1=2
'				king.flo I3(i)&"<textarea>"&data(i,0)&url&"</textarea>",3
			end if

		next
	else
		I1=2
	end if

	if intitle(data(1,0),colistid)=false then I1=2

'king.flo I1,3

	if I1=1 then'数据全了才可以加入
'king.flo "全",3
		if king.instre("article",kplugin) then
			'sql="kplugin,kcommend,khead,kshow,ishit,iscrtlist,kpath,kurlstart,kurlinc,isimg,ntime,kurlincpage"'11
			'路径命名 0拼音 1数字 2日期＋数字
			'guide,arttitle,artauthor,artfrom,artcontent,artkeywords,artdescription,artimg,artdate'8
			'rule
			'sql="klistname,listid,kstart,kend,kdefault,kclear,kreplace,kclshtml,isloop,ishave,isxhtml,isreturn,isok,kguide,istt,isimg,ksize"'16
			'格式化路径及抓图
			if cstr(datalist(9))="1" then
				data(4,0)=king.snap(formaturl(data(4,0),url))
			else
				data(4,0)=formaturl(data(4,0),url)
			end if

			neworder=king.neworder("kingart","artorder")
'			king.flo "<textarea cols=""100"" rows=""30"">"&"insert into kingart (listid,arttitle,artauthor,artfrom,artcontent,artkeywords,artdescription,artimg,artdate,artshow,artcommend,arthead,artpath,artorder) values ("&safe(data(0,0))&",'"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&safe(data(5,0))&"','"&safe(data(6,0))&"','"&safe(data(7,0))&"','"&safe(data(8,0))&"',"&datalist(3)&","&rndp(datalist(1))&","&rndp(datalist(2))&",'"&safe(getpath(data(1,0),neworder))&"',"&neworder&");"&"</textarea>",3
			conn.execute "insert into kingart (listid,arttitle,artauthor,artfrom,artcontent,artkeywords,artdescription,artimg,artdate,artshow,artcommend,arthead,artpath,artorder,arthit) values ("&safe(data(0,0))&",'"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&safe(data(5,0))&"','"&safe(data(6,0))&"','"&safe(data(7,0))&"','"&safe(data(8,0))&"',"&datalist(3)&","&rndp(datalist(1))&","&rndp(datalist(2))&",'"&safe(getpath(data(1,0),neworder))&"',"&neworder&","&rndn()&");"
			kid=king.newid("kingart","artid")
			clsname="article"
		else
'king.flo "内容",3
'king.flo colistname(),3

			'获得html类型
			html3=get3(kplugin)
			'格式化路径及抓图
			'guide,ktitle,kc_size,content,downloadpath,image,author,downloadversion,demopath
			for i=2 to ubound(I3)'获得数据
				if king.instre(html3,I3(i)) then'如果是html框
					if cstr(datalist(9))="1" then'抓图
						data(i,0)=king.snap(formaturl(data(i,0),url))
					else'不抓图
						data(i,0)=formaturl(data(i,0),url)
					end if
				end if
				oodata=oodata&",'"&safe(data(i,0))&"'"
				oosql=oosql&",kc_"&I3(i)
			next

			neworder=king.neworder("king__"&kplugin&"_page","korder")
'     		king.flo "insert into king__"&kplugin&"_page (listid,ktitle"&oosql&",kdate,korder,khit) values ("&data(0,0)&",'"&safe(data(1,0))&"'"&oodata&",'"&tnow&"',"&neworder&","&rndn()&")",3
			conn.execute "insert into king__"&kplugin&"_page (listid,ktitle,kpath"&oosql&",kdate,korder,khit) values ("&data(0,0)&",'"&safe(data(1,0))&"','"&safe(getpath(data(1,0),neworder))&"'"&oodata&",'"&tnow&"',"&neworder&","&rndn()&")"
'		king.flo err.Description &"|"&err.number&"|"&I1&"|"&kid&"|"&clsname&"|"&rndn()&"|"&url,3
			kid=king.newid("king__"&kplugin&"_page","kid")
			clsname=kplugin&"class"
		end if

	end if
	
'king.flo "退出",3

	if I1=1 and king.instre("0,1",datalist(5)) then

		exec=     "dim t_kc"&vbcrlf
		exec=exec&"set t_kc=new "&clsname&vbcrlf
		exec=exec&"t_kc.createpage "&kid&vbcrlf
		if king.instre("0",datalist(5)) then
			exec=exec&"t_kc.createlist "&data(0,0)&vbcrlf
		end if
		exec=exec&"set t_kc=nothing"&vbcrlf

		execute exec
	end if	


	if err.number<>0 then
'		king.flo err.Description &"|"&err.number&"|"&I1&"|"&kid&"|"&clsname&"|"&rndn()&"|"&url,3
		err.clear
		I1=2
	end if


	if cstr(I1)="2" then upurl I2,url

	getcontent=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
'获得content类别
private function get3(kplugin)
	dim I1,rs,data,i
	set rs=conn.execute("select fname from kingoo_field where ooid in (select ooid from kingoo where oocolumn='"&kplugin&"') and istype=3")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				if len(I1)>0 then
					I1=I1&","&data(0,i)
				else
					I1=data(0,i)
				end if
			next
		else
			king.flo king.lang("error/invalid")&"get3(kplugin)",3
		end if
		rs.close
	set rs=nothing
	get3=I1
end function

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub upurl(l1,l2)'内容 url
	dim objregex,l4,i,l5,l7
	dim I1,I2,I3,I4
	dim listid
	I1=replace(l1,chr(13),"")
	I1=replace(I1,chr(10),"")
	I1=replace(I1,chr(9),"")
	I1=formaturl(I1,l2)

	listid=form("list")

	if validate(listid,2)=false then king.flo king.lang("error/invalid")&"king_upurl",3
	
	on error resume next

	if len(I1)>0 then
		set objregex=new regexp
			objregex.ignorecase=true
			objregex.global=true
			objregex.pattern="<a [^<]*href=['""]?((.[^>""' ]*)['""]?[^<>]*>)"
			set I2=objregex.execute(I1)
				for each I3 in I2
					l5=king.match(I3.value,"(http|https|ftp):\/\/(([\w\/\\\+\-~`@:%])+\.)+([\w\/\.\=\?\+\-~`@\:!%#]|(&amp;)|&)+")
'king.flo l5,3
					if instr(l5,"#")>0 then l5=left(l5,instr(l5,"#")-1)

					if isurlincpage(l5,8) then
						conn.execute "insert into kingcollect_url_"&listid&" (urlpath) values ('"&safe(l5)&"')"
					end if
				next
			set I2=nothing
		set objregex=nothing
	end if
	if err.number<>0 then
		err.clear
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function formaturl(l1,l2)
	dim objregex
	dim I1,I2,I3
	I1=l1
	if len(I1)>0 then
		set objregex=new regexp
			objregex.ignorecase=true
			objregex.global=true
			objregex.pattern="(<(a|img) [^<]*(src|href)=['""]?((.[^>""' ]*)['""]?[^<>]*>))"'"(<img[^>]+src=""([^""]+)""[^>]*>)|<img[^>]+src='([^']+)'[^>]*>)|(<a[^>]+href=""([^""]+)""[^>]*>)|(<a[^>]+href='([^']+)'[^>]*>)"'
			set I2=objregex.execute(I1)
				for each I3 in I2
					I1=replace(I1,I3.value,lIIIIl(I3.value,l2))
				next
			set I2=nothing
		set objregex=nothing
	end if
	formaturl=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function lIIIIl(l1,l2)
	dim I1,I2,I3
	dim l3,l4'域名url,绝对路径
	dim objregex
	set objregex=new regexp
		objregex.pattern="(<(a|img) [^<]*(src|href)=['""]?((.[^>""' ]*)['""]?[^<>]*>))"
		objregex.ignorecase=true
		objregex.global=false
		I2=objregex.replace(l1,"$5")'获得连接或路径
	set objregex=nothing

	if len(I2)>0 then
		I1=I2
	else
		lIIIIl=l1
		exit function
	end if
	'路径分析
	'l2="http://www.kingcms.com/ww/efsf/wefsf/w/kingcms.htm?www.kingcms."
	I3=split(replace(l2,"\","/"),"/")
	if ubound(I3)<2 then
		lIIIIl=l1
		exit function
	end if
	l3=I3(0)&"//"&I3(2)'http://www.kingcms.com
	l4=right(l2,len(l2)-len(l3))
	if instr(l4,"?")>0 then
		l4=left(l4,instr(l4,"?")-1)
	end if
	l4=left(l4,instrrev(l4,"/")-1)'/ww/efsf/wefsf/w
	'判断类型
'out I1
	if validate(lcase(I1),5) then'http开头的url类型要跳过
	elseif left(I1,1)="/" then'绝对路径
		I1=l3&I1
	elseif left(I1,3)="../" then'相对路径
	'I1= ../../../kingcms.gif
	'l4= /ww/efsf/wefsf/w
		while (left(I1,3)="../")
			I1=right(I1,len(I1)-3)
			if len(l4)>0 then
				l4=left(l4,instrrev(l4,"/")-1)
			end if
		wend
		I1=l3&l4&"/"&I1
	elseif left(I1,2)="./" then
		I1=l3&l4&right(I1,len(I1)-1)
	elseif lcase(left(I1,7))="mailto:" or lcase(left(I1,11))="javascript:" then
		lIIIIl=l1
		exit function
	else
		I1=l3&l4&"/"&I1
	end if
'king.flo l1,3
	lIIIIl=replace(l1,I2,I1)
end function'  *** Copyright &copy KingCMS.com All Rights Reserved ***
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function gethtm(htm,data,kplugin,url)'内容/规则，数组化？,目标模块名称
	dim I1,I2,objlist
	dim l1,l2
	dim filename
'	sql="klistname,listid,kstart,kend,kdefault,kclear,kreplace,kclshtml,isloop,ishave,isxhtml,isreturn,isok,kguide,istt,isimg,ksize"'16
	if king.instre("1,true",cstr(data(8,0))) then'循环截取,但不先清理代码
		l1=htm
		l2=king.sect(l1,data(2,0),data(3,0),"")
		while (len(l2)>0)
			I1=I1&"<p class=""k_loop"">"&l2&"</p>"&vbcrlf'做记号
			l1=replace(l1,sect(l1,data(2,0),data(3,0)),"")'删掉已经获得的数据。

			l2=king.sect(l1,data(2,0),data(3,0),data(5,0))
		wend
	else
		I1=king.sect(htm,data(2,0),data(3,0),"")
	end if

	if len(I1)>0 then'I1得有值才能替换
		I1=replacee(I1,data(6,0))'替换操作
		I1=king.clsre(I1,data(5,0))'清理操作
		if king.instre("1,true",data(10,0)) then I1=xhtmlencode(I1)'xhtmlencode
		if king.instre("1,true",data(11,0)) then I1=king.cls(I1)'isreturn 清理换行

		'要清理的HTML标签
		if data(7,0)="*" then
			I1=king.replacee(I1,"(<[^<]+?>)","")
		else 
			if len(data(7,0))>0 then
				I1=king.clsre(I1,"(</?("&data(7,0)&")( [^<]*>| */?>))")
			end if
		end if

		'导航分割
		if data(0,0)="guide" then
'king.aja "title","<textarea name="""" rows=""10"" cols=""60"">"&I1&"</textarea>"
			if king.instre("true,1",data(14,0)) then data(14,0)=1 else data(14,0)=0
			I1=setlist(I1,data(13,0),kplugin,data(14,0))
		end if



		'判断是否为文章日期
		if data(0,0)="artdate" then
			if data(4,0)="NOW" then
				I1=tnow
			else
				I1=formatdate(I1,0)
			end if
		end if

		'是否为缩略图
		if (instr(lcase(data(0,0)),"img") or instr(lcase(data(0,0)),"image")) and king.instre("1,true",data(15,0)) then


			I1=king.replacee(formaturl(I1,url),"^(.|\n)*?(<img [^<]*src=[""']?(([^>""' ]*)\.(gif|jpg|jpeg|png))[""']?[^<>]*>)(.|\n)*$","$3")

'king.flo "<textarea cols=""15"" class=""in4"">"&formaturl(I1,url)&"</textarea>",3

			if len(I1)>0 then
				filename=king_upath&"/image/"&kplugin&"/"&formatdate(tnow,2)&"/"&(timer()*100)&"."&king.extension(I1)

				if len(king.extension(I1))>0 then
					king.createfolder "../../"&king_upath&"/image/"&kplugin&"/"&formatdate(tnow,2)'创建目录
					king.remote2local I1,"../../"&filename
					I1=king.inst&filename
				else
					I1=""
				end if
			end if

		end if

	end if

	if len(I1)=0 and len(data(4,0))>0 then
		I1=data(4,0)
	end if
	
	if cstr(data(16,0))="0" then
		gethtm=I1
	else
		gethtm=king.lefte(I1,data(16,0))
	end if

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function setlist(l1,l2,l3,l4)'完整路径，分割代码，类型 , 是否为标题
'(I1,data(13,0),kplugin,cint(cbool(data(14,0))))
	dim I1,I2,I3,i,rs,data,sql,listid

	listid=0

	if len(l1)>0 then
		I2=split(l1,l2)
		for i=0 to ubound(I2)
			if len(trim(I2(i)))>0 then
				if len(I3)>0 then
					I3=I3&l2&trim(I2(i))
				else
					I3=I2(i)
				end if
			end if
		next
		I2=split(I3,l2)
	else
		exit function
	end if

	for i=0 to ubound(I2)-fix(l4)
		'设置列表
		if king.instre("article",l3) then
			sql="select listid from kingart_list where listid1="&listid&" and listname='"&safe(I2(i))&"';"
		else
			sql="select listid from king__"&l3&"_list where listid1="&listid&" and listname='"&safe(I2(i))&"';"
		end if

		set rs=conn.execute(sql)
			if not rs.eof and not rs.bof then
				listid=rs(0)
			else
				listid=setlist_uplist(I2(i),listid,l3)
			end if
			rs.close
		set rs=nothing
	next
	setlist=listid
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function setlist_uplist(l1,l2,l3)'栏目名称，上一级id/即listid1 , 类型
	dim neworder
	on error resume next
	l1=king.lefte(l1,100)
	if king.instre("article",l3) then
		neworder=king.neworder("kingart_list","listorder")
		conn.execute "insert into kingart_list (listname,listpath,listtemplate1,listtemplate2,pagetemplate1,pagetemplate2,listid1,listkeyword,listdescription,listtitle,listorder) values ('"&safe(l1)&"','"&safe(r_listpath&neworder)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"',"&safe(l2)&",'"&safe(l1)&"','"&safe(l1)&"','"&safe(l1)&"',"&neworder&")"
		setlist_uplist=king.newid("kingart_list","listid")
	else
		neworder=king.neworder("king__"&l3&"_list","listorder")
		conn.execute "insert into king__"&l3&"_list (listname,listpath,listtemplate1,listtemplate2,pagetemplate1,pagetemplate2,listid1,listkeyword,listdescription,listtitle,listorder) values ('"&safe(l1)&"','"&safe(r_listpath&neworder)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"',"&safe(l2)&",'"&safe(l1)&"','"&safe(l1)&"','"&safe(l1)&"',"&neworder&")"
		setlist_uplist=king.newid("king__"&l3&"_list","listid")
	end if

'	if err.number<>0 then
'		king.flo "<textarea name="""" rows=""5"" cols=""100"">"&err.Description &"|"&err.number&"|"&"insert into king__"&l3&"_list (listname,listpath,listtemplate1,listtemplate2,pagetemplate1,pagetemplate2,listid1,listkeyword,listdescription,listtitle,listorder) values ('"&safe(l1)&"','"&safe(neworder)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"','"&safe(king_default_template)&"',"&safe(l2)&",'"&safe(l1)&"','"&safe(l1)&"','"&safe(l1)&"',"&neworder&")"&"</textarea>",2
'		err.clear
'	end if

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function sect(l1,l2,l3)'内容 开始 结束
	dim l5,l6,l7,l8,l9,I1,I2,I3
	if len(l1)>0 and len(l2)>0 and len(l3)>0 then
		
		if left(l2,1)=chr(40) and right(l2,1)=chr(41) and left(l3,1)=chr(40) and right(l3,1)=chr(41) then'正则截取
			set I1=new regexp
			I1.ignorecase=true
			I1.global=false

			I1.pattern=l2&"((.|\n)+?)"&l3
			set I2=I1.execute(l1)
				if I2.count>0 then I3=I2.item(0).value
			set I2=nothing

		else

			l6=l2:l7=l3
			l8=instr(lcase(l1),lcase(l6))
			if l8=0 then exit function
			l9=instr(lcase(right(l1,len(l1)-l8-len(l6)+1)),lcase(l7))
			if l8>0 and l9>0 then
				I3=trim(mid(l1,l8,len(l6)+len(l7)+l9-1))
			end if
		end if

	else
		exit function
	end if
	sect=I3
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private function xhtmlencode(l1)
	dim I1,I2,i
	if len(l1)>0 then
	else
		exit function
	end if

	I1=king.replacee(l1,"((\s|　|&nbsp;){1,})"," ")

	I1=king.replacee(I1,"(<(/?p[^<]*|br */?)>)",vbcr)'br和p换成vbcr符号
'xhtmlencode=I1
'exit function
	I2=split(I1,vbcr)
	I1=""
	for i=0 to ubound(I2)
		if len(trim(I2(i)))>0 then
			I1=I1&"<p>"&I2(i)&"</p>"
		end if
	next
	I1=king.replacee(I1,"(<img [^<]*src=([""']?((.[^>""' ]*)\.(gif|jpg|jpeg|png))['""]?)[^<>]*>)","<img src=""$3"" />")
	I1=king.replacee(I1,"(<(hr|br)[/ ]*>)","<$2 />")

	xhtmlencode=I1
end function
'replacee  *** Copyright &copy KingCMS.com All Rights Reserved. ***
public function replacee(l1,l2)'要替换的内容，l2是AAA=>BBB结构的内容，即为把AAA替换为BBB
	dim I1,I2,i,I3
	I1=l1
	if len(I1)>0 and len(l2) then
		I2=split(l2,chr(13)&chr(10))
		for i=0 to ubound(I2)
			if len(I2(i))>0 then
				I3=split(I2(i),"=>")
				if ubound(I3)=1 then'若为AAA=>BBB格式
					if len(I3(0))>0 then'首先得保证这个AAA有值
						if left(I3(0),1)="(" and right(I3(0),1)=")" then'正则替换
							I1=king.replacee(I1,I3(0),I3(1))
						else
							I1=replace(I1,I3(0),I3(1))
						end if
					end if
				end if
			end if
		next
	end if
	replacee=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function updatejs(l1,listid)
	dim I1,jstime,jslistid
	I1=updatejs_code()&"var datediff=getdom('"&king.page&"system/now.asp?datetime="&server.urlencode(tnow)&"');"
	if validate(listid,2) then
		if validate(l1,2)=false then l1=r_uptime
		I1=I1&"if(datediff>"&l1&"){postdom('"&king.page&r_path&"/create.asp','time="&l1&"&list="&listid&"');};"
	end if
	updatejs=I1
end function

private function updatejs_code()
	dim I1
	I1="function postdom(url,verbs){"&vbcrlf
	I1=I1&"var xmlhttp = false;"&vbcrlf
	I1=I1&"xmlhttp=ajax_driv();"&vbcrlf
	I1=I1&"xmlhttp.open(""POST"", url,true);"&vbcrlf
	I1=I1&"xmlhttp.setRequestHeader(""If-Modified-Since"",""0"");"&vbcrlf
	I1=I1&"xmlhttp.onreadystatechange=function(){"&vbcrlf
	I1=I1&"if (xmlhttp.readyState==4){"&vbcrlf
	I1=I1&"xmlhttp.responseText;"&vbcrlf
	I1=I1&"}}"&vbcrlf

	I1=I1&"xmlhttp.setRequestHeader(""Content-Length"",verbs.length);"&vbcrlf
	I1=I1&"xmlhttp.setRequestHeader(""CONTENT-TYPE"",""application/x-www-form-urlencoded"");"&vbcrlf
	I1=I1&"xmlhttp.send(verbs);"&vbcrlf
	I1=I1&"}"&vbcrlf
	updatejs_code=I1
end function




end class






'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_collect(tag)
	dim kc,jstime,jslistid
	jstime=king.getlabel(tag,"time")
	jslistid=king.getlabel(tag,"listid")
	set kc=new collectclass
		king_tag_collect="<script src="""&king.page&kc.path&"/update.js""></script>"
		king.savetofile king.page&kc.path&"/update.js",kc.updatejs(jstime,jslistid)'创建日期文件
	set kc=nothing
end function

%>
