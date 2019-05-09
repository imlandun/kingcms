<%
class comment
private r_doc,r_path,r_template,r_isuser,r_isview,r_isgetinfo,r_thisver,r_plugin

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()
	dim rs

	r_thisver = 1.11

	r_path = "comment"

	r_isgetinfo=true

	if king.checkcolumn("kingcomment")=false then
		install_config:update
	else
		on error resume next
		set rs=conn.execute("select kversion from kingcomment where systemname='KingCMS'")
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
public property get plugin
	dim rs
	if len(r_plugin)=0 then
		set rs=conn.execute("select kplugin from kingcomment;")
			if not rs.eof and not rs.bof then
				r_plugin=rs(0)
			end if
			rs.close
		set rs=nothing
	end if
	plugin=r_plugin
end property
'  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
private sub getsysteminfo()
	dim rs
	set rs=conn.execute("select ktemplate1,kisuser,kisview from kingcomment;")
		if not rs.eof and not rs.bof then
			r_template=rs(0)
			r_isuser=rs(1)
			r_isview=rs(2)
			r_isgetinfo=false
		end if
		rs.close
	set rs=nothing
end sub
'  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
public property get template
	if r_isgetinfo then getsysteminfo
	template=r_template
end property
'  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
public property get isveiw
	if r_isgetinfo then getsysteminfo
	isveiw=r_isveiw
end property
'  *** Copyright &copy  KingCMS.com All Rights Reserved. ***
public property get isuser
	if r_isgetinfo then getsysteminfo
	isuser=r_isuser
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub list()
	dim rs,i,I2,p
	p=quest("p",0)
	Il "<h2>"
	Il lang("title")

	Il "<span class=""listmenu"">"
	Il "[<a href=""index.asp"">"&lang("common/home")&"</a>"
	Il "<a href=""index.asp?action=config"">"&lang("common/config")&"</a>]"

	set rs=conn.execute("select kplugin from kingcomment;")
		if not rs.eof and not rs.bof then
			if len(rs(0))>0 then
				I2=split(rs(0),",")
				Il "["
				for i=0 to ubound(I2)
					if king.instre(p,I2(i)) then
						Il "<strong>"&king.xmlang(trim(I2(i)),"title")&"</strong>"
					else
						Il "<a href=""index.asp?action=list&p="&trim(I2(i))&""">"&king.xmlang(trim(I2(i)),"title")&"</a>"
					end if
				next
				Il "]"
			end if
		end if
		rs.close
	set rs=nothing

	if king.instre(plugin,p) then
		Il "["
		Il "<a href=""index.asp?action=list&p="&p&"&v=0"">"&kc.lang("common/today")&"</a>"
		Il "<a href=""index.asp?action=list&p="&p&"&v=1"">"&kc.lang("common/t3")&"</a>"
		Il "<a href=""index.asp?action=list&p="&p&"&v=2"">"&kc.lang("common/view0")&"</a>"
		Il "<a href=""index.asp?action=list&p="&p&"&v=3"">"&kc.lang("common/view1")&"</a>"
		Il "]"
	end if

	Il "</span>"
	Il "</h2>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub create(l1)
	dim rs,i,data,I2
	dim sql,jshtm,jsnumber,zebra,tmplist,length
	dim pid,pidcount,plist,ktemplate2

	sql="cmid,kcontent,kusername,kuserip,kgood,kbad,kfloor,kdate"'7

	if validate(l1,"^[A-Za-z0-9\_\-]*\|\d+$") then
		I2=split(l1,"|")
	else
		exit sub
	end if

	set rs=conn.execute("select ktemplate2 from kingcomment;")
		if not rs.eof and not rs.bof then
			ktemplate2=rs(0)
		else
			exit sub
		end if
		rs.close
	set rs=nothing

	jshtm=king.getlabel(ktemplate2,0)
	zebra=king.getlabel(ktemplate2,"zebra")
	jsnumber=king.getlabel(ktemplate2,"number")


	if king.checkcolumn("king__"&I2(0)&"_comment")=false then install I2(0)

	set rs=conn.execute("select "&sql&" from king__"&I2(0)&"_comment where kid="&I2(1)&" and kisview=1 order by kfloor desc,cmid desc;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()

			'初始化变量值
			pid=0
			pidcount=(ubound(data,2)+1)/int(jsnumber):if pidcount>int(pidcount) then pidcount=int(pidcount)+1'总页数
			length=ubound(data,2)

			for i=0 to length
				king.clearvalue
				king.value "id",data(0,i)
				king.value "content",encode(king.ubbencode(data(1,i)))
				if len(data(2,i))>0 then
					king.value "username",encode(htmlencode(data(2,i)))
				else
					king.value "username",encode(kc.lang("common/guest"))
				end if
				king.value "userip",encode(htmlencode(data(3,i)))
				king.value "good",encode("<a href=""javascript:;"" onclick=""posthtm('"&king.page&kc.path&"/index.asp?action=good','k_cg_"&data(0,i)&"','n="&data(4,i)&"&post="&l1&"&cmid="&data(0,i)&"')"">"&kc.lang("common/good")&"</a>(<span id=""k_cg_"&data(0,i)&""">"&data(4,i)&"</span>)")
				king.value "bad",encode("<a href=""javascript:;"" onclick=""posthtm('"&king.page&kc.path&"/index.asp?action=bad','k_cb_"&data(0,i)&"','n="&data(5,i)&"&post="&l1&"&cmid="&data(0,i)&"')"">"&kc.lang("common/bad")&"</a>(<span id=""k_cb_"&data(0,i)&""">"&data(5,i)&"</span>)")
				king.value "floor",data(6,i)
				king.value "date",encode(data(7,i))
				king.value "quote",encode("<a href=""#k_comment_post"" onclick=""javascript:posthtm('"&king.page&kc.path&"/index.asp?action=post','k_comment_post','post="&l1&"&quoteid="&data(0,i)&"')"">"&kc.lang("common/quote")&"</a>")
'				king.value "manage",encode("<a href=""javascript:;"" onclick=""javascript:posthtm('"&king.page&kc.path&"/index.asp?action=manage','flo','post="&l1&"&cmid="&data(0,i)&"')"">"&kc.lang("common/manage")&"</a>")
				king.value "zebra",king.mod2(i+1,zebra)

				tmplist=tmplist&king.createhtm(jshtm,king.invalue)'循环累加值到tmplist变量

				if ((i+1) mod jsnumber)=0 or i=length then '当整除于number参数或到最后一个记录的时候进入生成过程

					plist=kpagelist("javascript:;"" onclick=""gethtm('"&king.inst&r_path&"/"&I2(0)&"/"&I2(1)&"/$"&"','k_comment')",pid+1,pidcount,length+1)

					if pid=0 then'列表第一页
						king.savetofile "../../"&r_path&"/"&I2(0)&"/"&I2(1)&"/"&king_ext,plist&tmplist&plist
					else
						king.savetofile "../../"&r_path&"/"&I2(0)&"/"&I2(1)&"/"&(pid+1)&"/"&king_ext,plist&tmplist&plist
					end if

					'初始化循环变量
					tmplist=""
					
					pid=pid+1
				end if

			next
		else
			king.savetofile "../../"&r_path&"/"&I2(0)&"/"&I2(1)&"/"&king_ext,"<p>"&lang("common/notcomment")&"</p>"
		end if
		rs.close
	set rs=nothing
end sub
'pagelist  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function kpagelist(l1,l2,l3,l5)
	if instr(l1,"$")=0 then exit function
	if l5=0 then exit function
	dim l4,k,l6,l7,I2
	l2=int(l2):l3=int(l3):l5=int(l5)
	if l2>3 then 
		l4=("<a href="""&replace(l1,"$","")&""">1 ...</a>")'
	end if
	if l2>2 then
		l4=l4&("<a href="""&replace(l1,"$",l2-1)&""">&lsaquo;&lsaquo;</a>")
	elseif l2=2 then
		l4=l4&("<a href="""&replace(l1,"$","")&""">&lsaquo;&lsaquo;</a>")
	end if
	for k=l2-2 to l2+7
		if k>=1 and k<=l3 then
			if cstr(k)=cstr(l2) then
				l4=l4&("<strong>"&k&"</strong>")
			else
				if k=1 then
					l4=l4&("<a href="""&replace(l1,"$","")&""">"&k&"</a>")
				else
					l4=l4&("<a href="""&replace(l1,"$",k)&""">"&k&"</a>")
				end if
			end if
		end if
	next
	if l2<l3 and l3<>1 then
		l4=l4&("<a href="""&replace(l1,"$",l2+1)&""">&rsaquo;&rsaquo;</a>")
	end if
	if l2<l3-7 then
		l4=l4&("<a href="""&replace(l1,"$",l3)&""">... "&l3&"</a>")
	end if

	I2=split(l1,"$")
	kpagelist="<span class=""k_pagelist"">"&l4&"</span>"
end function
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
public sub log(l1,l2,l3)'评论日志
	'if king_dbtype=1 then  conn.execute("set IDENTITY_INSERT kingcomment_log on")
	if len(l1)>0 then
		if conn.execute("select count(*) from kingcomment_log  where ip="&kc.ip&" and  kplugin='"&safe(l2)&"' and kid="&l3&";")(0)>0 then
			conn.execute "update kingcomment_log set kcontent='"&safe(left(l1,50))&"',kplugin='"&safe(l2)&"',kid="&safe(l3)&",kdate='"&tnow&"'  where ip="&kc.ip&" and  kplugin='"&safe(l2)&"' and kid="&l3&";"
		else
			conn.execute "insert into kingcomment_log (ip,kcontent,kplugin,kid,kdate) values ("&kc.ip&",'"&safe(left(l1,50))&"','"&safe(l2)&"',"&safe(l3)&",'"&tnow&"')"
		end if
	else
		if conn.execute("select count(*) from kingcomment_log  where ip="&kc.ip&" and  kplugin='"&safe(l2)&"' and kid="&l3&";")(0)>0 then
			conn.execute "update kingcomment_log set kdate='"&tnow&"',kplugin='"&safe(l2)&"',kid="&safe(l3)&"  where ip="&kc.ip&" and  kplugin='"&safe(l2)&"' and kid="&l3&";"
		else
			conn.execute "insert into kingcomment_log (ip,kplugin,kid,kdate) values ("&kc.ip&",'"&safe(l2)&"',"&safe(l3)&",'"&tnow&"')"
		end if
	end if
	'if king_dbtype=1 then conn.execute("set IDENTITY_INSERT kingcomment_log off")
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function judge(l1,l2,l3)'判断发帖时间，现在重复发帖
	dim rs,data,ktime,rtime

	set rs=conn.execute("select ktime,rtime from kingcomment;")
		ktime=rs(0)
		rtime=rs(1)
		rs.close
	set rs=nothing

	set rs=conn.execute("select kcontent,kdate,kid,kplugin from kingcomment_log  where ip="&kc.ip&" and  kplugin='"&safe(l2)&"' and kid="&l3&";")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			
			if left(l1,50)=data(0,0) then'如果内容一样就加倍等待
				if datediff("s",data(1,0),tnow)>rtime then
					judge=true
				else
					'if cstr(l3)=cstr(data(2,0))  and cstr(l2)=cstr(data(3,0)) then
						judge=false
					'else
						'judge=true
					'end if
				end if
			else
				if datediff("s",data(1,0),tnow)>ktime then
					judge=true
				else
					'if cstr(l3)=cstr(data(2,0))  and cstr(l2)=cstr(data(3,0)) then
						judge=false
					'else
						'judge=true
					'end if
				end if
			end if
		else
			judge=true
		end if
		rs.close
	set rs=nothing
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install(l1)
'	king.head 0,0
	dim sql
	'king__OO_comment 
	sql="cmid int not null identity primary key,"
	sql=sql&"kid int not null default 0,"'文章等的id
	sql=sql&"kcontent ntext,"
	sql=sql&"kusername nvarchar(30),"
	sql=sql&"kisview int not null default 0,"'1显示
	sql=sql&"kuserip nvarchar(30),"'userip
	sql=sql&"kgood int not null default 0,"'好 如果kgood和kbad比大于5，则输出1，否则输出0，前提是kbad大于2
	sql=sql&"kbad int not null default 0,"'不好
	sql=sql&"kfloor int not null default 1,"'第几楼
	sql=sql&"kdate datetime"'添加时间
	conn.execute "create table king__"&trim(l1)&"_comment ("&sql&")"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install_config()
	king.head "admin",0
	dim sql
	'kingcomment
	sql="kversion real not null default 1,"'版本
	sql=sql&"kplugin ntext,"'支持评论的模块
	sql=sql&"ktemplate1 nvarchar(50),"'评论外部模版,需要指定
	sql=sql&"ktemplate2 ntext,"'需要写
	sql=sql&"ksize int not null default 2000,"'允许评论的长度
	sql=sql&"ktime int not null default 30,"'发帖时间间隔
	sql=sql&"rtime int not null default 300,"'重复发帖时间间隔
	sql=sql&"kisuser int not null default -1,"'0开放评论 1只限制会员评论 -1关闭评论
	sql=sql&"kisview int not null default 1"'1默认进行直接显示
	conn.execute "create table kingcomment ("&sql&")"
	conn.execute "insert into kingcomment (ktemplate1,ktemplate2) values ('"&safe(king_default_template)&"','{king:comment number=""10""}"&vbcrlf&"  <div><strong>#(king:floor/)</strong>(king:good/)(king:bad/) (king:username/)@(king:date mode=""MM-dd hh:mm""/)(king:quote/)</div>"&vbcrlf&"  <p>(king:content/)</p>"&vbcrlf&"{/king}')"
	'kingcomment_log
	sql="id int not null identity primary key,"
	sql=sql&"ip int not null,"'IP地址
	sql=sql&"kcontent nvarchar(50),"'发表的内容，防止重复发帖
	sql=sql&"kplugin nvarchar(50),"'模块名称
	sql=sql&"kid int not null default 0,"'对应模块的id
	sql=sql&"kdate datetime"'最后一次添加时间
	conn.execute "create table kingcomment_log ("&sql&")"
end sub
public sub update()
	dim rs,sql,dbver
	on error resume next

	conn.execute "select top 1 id,kcontent from kingcomment_log;"
	if err.number<>0 then
		conn.execute "drop table kingcomment_log;"
		'kingdigg_log
		sql="id int not null identity primary key,"
		sql=sql&"kcontent nvarchar(50),"'发表的内容，防止重复发帖
		sql=sql&"ip int not null,"'IP地址
		sql=sql&"kplugin nvarchar(50),"'模块名称
		sql=sql&"kid int not null default 0,"'对应模块的id
		sql=sql&"kdate datetime"'最后一次添加时间
		conn.execute "create table kingcomment_log ("&sql&")"
		error.clear
	end if
	
	conn.execute "update kingcomment set kversion="&r_thisver&" where systemname='KingCMS';"
end sub


end class

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_comment(tag,invalue)

	on error resume next

	dim jscommentid,jsnumber
	dim I1,I2,I3,t_kc

	jsnumber=king.getlabel(tag,"number")
	jscommentid=king.getvalue(invalue,"commentid")


	if validate(jscommentid,"^[A-Za-z0-9\_\-]*\|\d+$") then
		I2=split(jscommentid,"|")
		set t_kc=new comment
			I3=t_kc.path&"/"&I2(0)&"/"&I2(1)&"/"&king_ext
			if king.isexist("../../"&I3)=false then'如果不存在，则进行生成操作
					t_kc.create(jscommentid)
			end if
			I1="<div id=""k_comment""></div><script type=""text/javascript"" charset=""utf-8"">gethtm('"&king.inst&I3&"','k_comment')</script>"
		set t_kc=nothing
	end if

	if len(I1)=0 or err.number<>0 then
		king_tag_comment=king.errtag(tag)
	else
		king_tag_comment=I1
	end if
end function
'  *** Copyright &copy; KingCMS.com All Rights Reserved ***
function king_tag_comment_post(tag,invalue)
	dim t_kc,I1,jscommentid
	jscommentid=king.getvalue(invalue,"commentid")

	set t_kc=new comment
		I1="<div id=""k_comment_post""><a href=""javascript:;"" onclick=""javascript:posthtm('"&king.page&t_kc.path&"/index.asp?action=post','k_comment_post','post="&jscommentid&"')"">"&t_kc.lang("common/post")&"</a></div>"
		king_tag_comment_post=I1
	set t_kc=nothing
end function
%>