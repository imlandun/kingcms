<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set kc=new comment
	select case action
	case"" king_def
	case"list" king_list
	case"set" king_set
	case"config" king_config
	end select
set kc=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,kc.lang("title")
	dim rs,data,i,I2

	kc.list


	set rs=conn.execute("select kplugin from kingcomment;")
		if not rs.eof and not rs.bof then
			if len(rs(0))>0 then
				Il king_table_s
				Il "<tr><th>"&kc.lang("list/pluginname")&"</th><th>"&kc.lang("list/n0")&"</th><th>"&kc.lang("list/n1")&"</th></tr>"
				I2=split(rs(0),",")
				for i=0 to ubound(I2)
					if king.checkcolumn("king__"&trim(I2(i))&"_comment")=false then kc.install I2(i)
					Il "<tr><td><a href=""index.asp?action=list&p="&trim(I2(i))&""">"&king.xmlang(trim(I2(i)),"title")&"</a></td>"
					Il "<td class=""c"">"&conn.execute("select count(*) from king__"&trim(I2(i))&"_comment;")(0)&"</td>"
					Il "<td class=""c"">"&conn.execute("select count(*) from king__"&trim(I2(i))&"_comment where kisview=0;")(0)&"</td></tr>"
				next
				Il "</table>"
			else
				response.redirect "index.asp?action=config"
			end if
		end if
		rs.close
	set rs=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_config()
	king.head king.path,kc.lang("title")
	dim rs,data,dataform,i,I2,sql
	dim plugins,checked

	sql="kplugin,ktemplate1,ksize,ktime,rtime,kisuser,kisview,ktemplate2"

	if king.ismethod then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from kingcomment;")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	kc.list

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=config"">"
	'kplugin
	Il "<p><label>"&kc.lang("label/plugin")&"</label>"
	if len(king.plugin)>0 then
		plugins=split(king.plugin,",")
		Il "<span>"
		for i=0 to ubound(plugins)
			if king.instre(king.path&",system,[MODEL],webftp,passport,ad",plugins(i))=false then
				if king.instre(data(0,0),plugins(i)) then checked=" checked=""checked""" else checked=""
				Il "<input type=""checkbox"" name=""kplugin"" id=""p_"&plugins(i)&""" value="""&plugins(i)&""""&checked&" /><label for=""p_"&plugins(i)&""">"&king.xmlang(plugins(i),"title")&"</label><br/>"
			end if
		next
		Il "</span>"
	end if
	Il "</p>"
	'ktemplate1
	king.form_tmp "ktemplate1",kc.lang("label/template"),data(1,0),0
	'ktemplate2
	king.form_area "ktemplate2",kc.lang("label/template2"),data(7,0),"ktemplate2|0|"&encode(kc.lang("check/template2"))
	'ksize
	Il "<p><label>"&kc.lang("label/size")&"</label>"
	Il "<input type=""text"" name=""ksize"" value="""&data(2,0)&""" class=""in1"" maxlength=""5"" />"
	Il king.check("ksize|2|"&encode(kc.lang("check/size1"))&";ksize|0|"&encode(kc.lang("check/size2")))
	Il "</p>"
	'ktime
	Il "<p><label>"&kc.lang("label/ktime")&"</label>"
	Il "<input type=""text"" name=""ktime"" value="""&data(3,0)&""" class=""in1"" maxlength=""5"" />"
	Il king.check("ktime|2|"&encode(kc.lang("check/ktime1"))&";ktime|0|"&encode(kc.lang("check/ktime2")))
	Il "</p>"
	'ktime
	Il "<p><label>"&kc.lang("label/rtime")&"</label>"
	Il "<input type=""text"" name=""rtime"" value="""&data(4,0)&""" class=""in1"" maxlength=""5"" />"
	Il king.check("rtime|2|"&encode(kc.lang("check/rtime1"))&";rtime|0|"&encode(kc.lang("check/rtime2")))
	Il "</p>"
	'kisuser 0开放评论 1只限制会员评论 -1关闭评论
	king.form_radio "kisuser",kc.lang("label/isuser"),"0:"&encode(kc.lang("label/i0"))&"|1:"&encode(kc.lang("label/i1"))&"|-1:"&encode(kc.lang("label/i_1")),data(5,0)
	'kisview
	king.form_radio "kisview",kc.lang("label/isview"),"0:"&encode(kc.lang("label/v0"))&"|1:"&encode(kc.lang("label/v1")),data(6,0)

	king.form_but "save"
	Il "</form>"
	if king.ischeck and king.ismethod then
'		sql="kplugin,ktemplate1,ksize,ktime,rtime,kisuser,kisview,ktemplate2"
		conn.execute "update kingcomment set kplugin='"&safe(data(0,0))&"',ktemplate1='"&safe(data(1,0))&"',ktemplate2='"&safe(data(7,0))&"',ksize="&data(2,0)&",ktime="&data(3,0)&",rtime="&data(4,0)&",kisuser="&data(5,0)&",kisview="&data(6,0)&";"
		Il "<script>alert('"&htm2js(kc.lang("alert/upok"))&"')</script>"

	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_list()
	king.head king.path,kc.lang("title")

	dim rs,data,i,dp'lpath:linkpath
	dim but,sql,p,v,insql,kid,ip,uname

	p=quest("p",0)
	v=quest("v",2)
	kid=quest("kid",2)
	ip=quest("ip",0)

	if king.instre(kc.plugin,p)=false then king.error king.lang("error/invalid")

	select case cstr(v)
	case"0",""
		if king_dbtype=0 then'ACCESS
			insql="now()-kdate<1"
		else
			insql="getdate()-kdate<1"
		end if
	case"1"
		if king_dbtype=0 then'ACCESS
			insql="now()-kdate<3"
		else
			insql="getdate()-kdate<3"
		end if
	case"2"
		insql="kisview=0"
	case"3"
		insql="kisview=1"
	end select

	if validate(ip,12) then insql="kuserip='"&safe(ip)&"'"
	if len(kid)>0 then insql="kid="&kid

	sql="select cmid,kcontent,kusername,kuserip,kgood,kbad,kdate,kid from king__"&safe(p)&"_comment where "&insql&" order by cmid desc;"

	kc.list

	set dp=new record
		dp.purl="index.asp?pid=$&rn="&dp.rn&"&action=list&p="&p&"&v="&v&"&kid="&kid&"&ip="&ip
		dp.value="p="&p
		dp.create sql
		dp.but=dp.sect("create:"&encode(king.lang("common/create"))&"|-|view1:"&encode(kc.lang("common/v1"))&"|view0:"&encode(kc.lang("common/v0")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'[<a href=""index.asp?action=list&p="&p&"&v="&v&"&kid='+K[7]+'"">"&p&"ID:'+K[7]+'</a>] <strong>'+K[2]+'</strong> <a href=""index.asp?action=list&p="&p&"&ip='+K[3]+'"">'+K[3]+'</a><a href=""http://www.kingcms.cn/ip.asp?ip='+K[3]+'"" target=""_blank"">["&kc.lang("common/soip")&"]</a> "&kc.lang("common/good")&"('+K[4]+') "&kc.lang("common/bad")&"('+K[5]+') @ '+K[6]+'<blockquote>'+K[1]+'</blockquote>'"

		Il dp.open

		Il "<tr><th>"&kc.lang("list/name")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			if len(dp.data(2,i))>0 then uname=dp.data(2,i) else uname=kc.lang("common/guest")
			Il "ll("&dp.data(0,i)&",'"&htm2js(king.ubbencode(dp.data(1,i)))&"','"&htm2js(uname)&"','"&htm2js(dp.data(3,i))&"',"&dp.data(4,i)&","&dp.data(5,i)&",'"&htm2js(dp.data(6,i))&"',"&dp.data(7,i)&");"
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
	dim p,kid,kids
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if
	p=form("p")
	if king.instre(kc.plugin,p)=false then king.flo king.lang("error/invalid")

	select case form("submits")
	case"create" 
		if len(list)>0 then
			kc.create list
			set rs=conn.execute("select kid from king__"&safe(p)&"_comment where cmid in ("&list&");")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						if king.instre(kid,data(0,i))=false then
							kid=kid&","&data(0,i)
							kc.create p&"|"&data(0,i)
						end if
					next
				end if
				rs.close
			set rs=nothing
			king.flo kc.lang("flo/createok"),1
		else
			king.flo kc.lang("flo/select"),0
		end if

	case"delete"
		if len(list)>0 then
			set rs=conn.execute("select cmid,kid from king__"&safe(p)&"_comment where cmid in ("&list&");")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						kid=kid&","&data(1,i)
					next
					conn.execute "delete from king__"&safe(p)&"_comment where cmid in ("&list&");"
					if len(kid)>0 then
						kids=split(kid,",")
						for i=1 to ubound(kids)
							kc.create p&"|"&kids(i)
						next
					end if
				else
					king.flo kc.lang("flo/invalid"),1
				end if
				rs.close
			set rs=nothing
			king.flo kc.lang("flo/deleteok"),1
		else
			king.flo kc.lang("flo/select"),0
		end if
	case"view0","view1"
		if len(list)>0 then
			set rs=conn.execute("select cmid,kid from king__"&safe(p)&"_comment where cmid in ("&list&");")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						kid=kid&","&data(1,i)
					next
					conn.execute "update king__"&safe(p)&"_comment set kisview="&right(form("submits"),1)&" where cmid in ("&list&");"
					if len(kid)>0 then
						kids=split(kid,",")
						for i=1 to ubound(kids)
							kc.create p&"|"&kids(i)
						next
					end if
				else
					king.flo kc.lang("flo/invalid"),1
				end if
				rs.close
			set rs=nothing
			king.flo kc.lang("flo/"&form("submits")),1
			
		else
			king.flo kc.lang("flo/select"),0
		end if
	end select
end sub
%>