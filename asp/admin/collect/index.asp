<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set kc=new collectclass
	select case action
	case"" king_def
	case"edt" king_edt
	case"set" king_set
	case"create" king_create
	case"up","down" king_updown
	case"rule" king_rule
	end select
set kc=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,kc.lang("title")
	dim rs,data,i,dp'lpath:linkpath
	dim but,sql,ispath,lpath

	kc.list

	sql="select listid,kname,kplugin,kurlstart from kingcollect_list order by listid desc;"'3

	set dp=new record
		dp.create sql
		dp.but=dp.sect("@collect:"&encode(kc.lang("common/collect"))&"|-|deleteurl:"&encode(kc.lang("common/deleteurl"))&"|deleteurl1:"&encode(kc.lang("common/deleteurl1")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=rule&listid='+K[0]+'"" title=""'+K[5]+'"">'+K[0]+') '+K[1]+'</a>'"
		dp.js="K[2]"
		dp.js="K[3]"
		dp.js="edit('index.asp?action=edt&listid='+K[0])"

		Il dp.open

		Il "<tr><th>"&kc.lang("list/id")&") "&kc.lang("list/name")&"</th><th>"&kc.lang("list/plugin")&"</th><th>"&kc.lang("list/urlstart")&"</th><th>"&king.lang("common/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length

			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&htm2js(dp.data(2,i))&"','"&htm2js(dp.data(3,i))&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing


end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_rule()
	king.head king.path,kc.lang("title")
	dim rs,data,i,listid
	dim but,sql,ispath,lpath
	dim colist'要采集的列表
	dim colists,I2

	listid=quest("listid",2)
	colist=kc.colist(listid)

	kc.list

	if len(colist)>0 then
		colists=split(colist,"|")
	else
		redim colists(-1)
	end if

	Il king_table_s
	Il "<tr><th>"&kc.lang("list/listname")&"</th><th class=""w2 c"">"&kc.lang("list/ishave")&"</th><th class=""w2 c"">"&kc.lang("list/isok")&"</th></tr>"
	for i=0 to ubound(colists)
		I2=split(colists(i),":")
		Il "<tr><td id=""k__"&I2(0)&""">"&i+1&") "
		set rs=conn.execute("select kid,isok,ishave from kingcollect_rule where listid="&listid&" and klistname='"&safe(I2(0))&"';")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				Il "<a href=""javascript:;"" onclick=""posthtm('index.asp?action=set','k__"&I2(0)&"','submits=edt&knum="&i+1&"&kname="&server.urlencode(I2(1))&"&kid="&data(0,0)&"')"">"&decode(I2(1))&"</a>"'编辑
				Il "</td><td class=""w2 c"">"
				Il king_rule_isok(data(2,0))
				Il "</td><td class=""w2 c"">"
				Il king_rule_isok(data(1,0))
			else
				Il "<a href=""javascript:"" onclick=""posthtm('index.asp?action=set','k__"&I2(0)&"','submits=add&knum="&i+1&"&kname="&server.urlencode(I2(1))&"&klistname="&I2(0)&"&listid="&listid&"')"">"&decode(I2(1))&"</a>"'新添
				Il "</td><td class=""w2 c"">"
				Il king_rule_isok(0)
				Il "</td><td class=""w2 c"">"
				Il king_rule_isok(0)
			end if
			rs.close
		set rs=nothing
		Il "</td></tr>"&vbcrlf
	next
	Il "</table>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_rule_isok(l1)
	if cstr(l1)="1" then
		king_rule_isok="<img src=""../system/images/os/sel.gif""/>"
	else
		king_rule_isok="&nbsp;"
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.head king.path,0
	dim list,rs,data,i,dataform,sql
	dim kid,kname,knum,submit,checked,listid
	dim kurltest,gethtm,kplugin
	dim I1,writejs

	dim lists

	dim count_all,count_0,count_1,count_2
	dim this_url,id_url

	kid=form("kid")
	kname=form("kname")
	knum=form("knum")
	submit=form("submits")
	listid=form("listid")

	list=form("list")


	sql="klistname,listid,kstart,kend,kdefault,kclear,kreplace,kclshtml,isloop,ishave,isxhtml,isreturn,isok,kguide,istt,isimg,ksize"'16
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if
	if len(listid)>0 then
		if validate(listid,2)=false then king.error king.lang("error/invalid")
	end if
	if len(kid)>0 then
		if validate(kid,2)=false then king.error king.lang("error/invalid")
	end if

	select case submit
	case"deleteurl","deleteurl1"
		if len(list)>0 then
			if validate(list,6)=false then king.flo king.lang("error/invalid"),0
		else
			king.flo kc.lang("flo/select"),0
		end if
		if submit="deleteurl" then
			conn.execute "delete from kingcollect_url_"&list&";"
		else
			conn.execute "delete from kingcollect_url_"&list&" where isok=1;"
		end if
		king.flo kc.lang("flo/deleteurl"),0
	case"@collect"

		if len(list)>0 then
			if validate(list,6)=false then king.flo king.lang("error/invalid"),3
		end if

		if len(list)>0 then
			if validate(list,2)=false then king.flo kc.lang("flo/select1"),3
		else
			king.flo kc.lang("flo/select"),3
		end if

		kc.instart list '如果没有url地址，则填写开始url地址到URL数据库里。

		count_all=conn.execute("select count(id) from kingcollect_url_"&list&";")(0)
		count_0=conn.execute("select count(id) from kingcollect_url_"&list&" where isok=0;")(0)'待采集的
		count_1=conn.execute("select count(id) from kingcollect_url_"&list&" where isok=1;")(0)'成功的
		count_2=conn.execute("select count(id) from kingcollect_url_"&list&" where isok=2;")(0)'失败的

		if count_0=0 then
			king.ol="<div id=""flotitle""><span>"&htm2js(kc.lang("common/exit"))&"</span><img class=""os"" src=""../system/images/close.gif"" onclick=""display(\'flo\')""/></div>"
			king.ol="<div id=""flomain"">"
			king.ol="<p class=""load"">"&htm2js(kc.lang("common/exit"))&"</p>"
			king.ol="<div class=""load""><div style=""width:100%"">&nbsp;<\/div></div>"
			king.ol="<p class=""load"">共采集"&count_all&",成功采集"&count_1&",成功率:"&formatnumber((count_1/count_all)*100,1,true)&"%</p>"
		else
			
			set rs=conn.execute("select top 1 id,urlpath from kingcollect_url_"&list&" where isok=0 order by id asc;")
				if not rs.eof and not rs.bof then
					this_url=rs(1)
					id_url=rs(0)
				end if
				rs.close
			set rs=nothing


			king.ol="<div id=""flotitle""><span>"&htm2js(kc.lang("common/inof"))&"</span><img class=""os"" src=""../system/images/close.gif"" onclick=""eval(\'parent.location=\\\'index.asp\\\'\');""/></div>"
			king.ol="<div id=""flomain"">"
			king.ol="<p class=""load"">总共"&count_all&",已完成"&(count_1+count_2)&",剩余"&count_0&",成功"&count_1&",成功率:"
			if (count_1+count_2)>0 then
				king.ol=formatnumber((count_1/(count_1+count_2))*100,1,true)
			else
				king.ol="0"
			end if
			king.ol="%</p>"
			king.ol="<div class=""load""><div style=""width:"&formatnumber((count_1/count_all)*100,0,true)&"%"">&nbsp;</div></div>"
			king.ol="<p class=""load"">正在采集: <a style=""font-size:9px;"" href="""&king_system&"system/link.asp?url="&this_url&""" target=""_blank"">"
			if len(this_url)>45 then
				king.ol=left(this_url,28)&"....."&right(this_url,12)
			else
				king.ol=this_url
			end if

			king.ol="</a></p>"

			conn.execute "update kingcollect_url_"&list&" set isok="&kc.getcontent(this_url,kc.datalist(0),list)&" where id="&id_url&";"

			writejs="setTimeout(""posthtm('index.asp?action=set','flo','list="&list&"&submits=@collect',0)"","&kc.datalist(10)&")"
		end if

		king.ol="</div>"


		king.txt"{main:'"&king.writeol&"',js:'"&htm2js(writejs)&"'}"

	case"back"
		king.txt knum&") <a href=""javascript:"" onclick=""posthtm('index.asp?action=set','k__"&form("klistname")&"','submits="&form("submit")&"&kid="&kid&"&knum="&knum&"&kname="&server.urlencode(kname)&"&klistname="&form("klistname")&"&listid="&form("listid")&"')"">"&kname&"</a>"

	case"edt","add"
		if len(kid)>0 and form("up")="" then'编辑
			if validate(kid,2)=false then king.txt king.lang("error/invalid"),0
			set rs=conn.execute("select "&sql&" from kingcollect_rule where kid="&kid&";")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
				end if
				rs.close
			set rs=nothing
		else'新添
			dataform=split(sql,",")
			redim data(ubound(dataform),0)
			for i=0 to ubound(dataform)
				data(i,0)=form(dataform(i))
			next
			if submit="add" then'初始化
				data(7,0)="*"
				data(16,0)=0
			end if
		end if
		king.ol=knum&") <a href=""javascript:"" onclick=""posthtm('index.asp?action=set','k__"&data(0,0)&"','submits=back&submit="&submit&"&kid="&kid&"&listid="&data(1,0)&"&klistname="&data(0,0)&"&kname="&server.urlencode(kname)&"&knum="&knum&"')"">"&kname&"</a>"
		king.ol="<div class=""k_form"">"
		'kstart
		king.ol="<p><label>"&kc.lang("label/kstart")&"</label>"
		king.ol="<textarea name=""kstart"" id=""k_kstart_"&knum&""" rows=""5"" cols=""20"" class=""in4"">"&formencode(data(2,0))&"</textarea>"
		if form("up")="ok" then
			king.ol=king.check("kstart|0|"&encode(kc.lang("check/kstart")))
		end if
		king.ol="</p>"
		'kend
		king.ol="<p><label>"&kc.lang("label/kend")&"</label>"
		king.ol="<textarea name=""kend"" id=""k_kend_"&knum&""" rows=""5"" cols=""20"" class=""in4"">"&formencode(data(3,0))&"</textarea>"
		if form("up")="ok" then
			king.ol=king.check("kend|0|"&encode(kc.lang("check/kend")))
		end if
		king.ol="</p>"
		'是否为缩略图
		if instr(lcase(data(0,0)),"img") or instr(lcase(data(0,0)),"image") then
			if king.instre("1,true",cstr(data(15,0))) then checked=" checked=""checked""" else checked=""
			king.ol="<p><label>"&kc.lang("label/isimgr")&"</label>"
			king.ol="<input type=""checkbox"" id=""k_isimg_"&knum&""" value=""1"""&checked&" />"
			king.ol="<span><label for=""k_isimg_"&knum&""">"&kc.lang("label/isimgru")&"</label></span>"
			king.ol="</p>"
		else
			king.ol="<input type=""hidden"" id=""k_isimg_"&knum&""" value=""0"" />"
		end if
		if king.instre("guide",data(0,0)) then
			'kguide
			king.ol="<p><label>"&kc.lang("label/kguide")&"</label>"
			king.ol="<textarea id=""k_kguide_"&knum&""" rows=""5"" cols=""20"" class=""in4"">"&formencode(data(13,0))&"</textarea>"
			king.ol="<br/>"
			'istt
			if king.instre("1,true",cstr(data(14,0))) then checked=" checked=""checked""" else checked=""
			king.ol="<input type=""checkbox"" id=""k_istt_"&knum&""" value=""1"""&checked&" />"
			king.ol="<span><label for=""k_istt_"&knum&""">"&kc.lang("label/istt")&"</label></span>"
			king.ol="</p>"
		else
			king.ol="<input type=""hidden"" id=""k_istt_"&knum&""" value=""0"" />"
			king.ol="<input type=""hidden"" id=""k_kguide_"&knum&""" value=""0"" />"
		end if
		'kdefault
		if king.instre("ktitle,arttitle",data(0,0))=false then
			king.ol="<p><label>"&kc.lang("label/kdefault")&"</label>"
			king.ol="<input type=""text"" name=""kdefault"" id=""k_kdefault_"&knum&""" class=""in4"" value="""&formencode(data(4,0))&""" maxlength=""30"" />"
			if king.instre("artdate",data(0,0)) then
				king.ol=king.form_eval("k_kdefault_"&knum,"NOW")
			end if
			king.ol="</p>"
		else
			king.ol="<input type=""hidden"" id=""k_kdefault_"&knum&""" value="""" />"
		end if
		'ksize
		king.ol="<p><label>"&kc.lang("label/ksize")&"</label>"
		king.ol="<input type=""text"" name=""ksize"" id=""k_ksize_"&knum&""" class=""in1"" value="""&formencode(data(16,0))&""" maxlength=""8"" />"
		if form("up")="ok" then
			king.ol=king.check("ksize|2|"&encode(kc.lang("check/ksize")))
		end if
		king.ol="</p>"
		'kclear
		king.ol="<p><label>"&kc.lang("label/kclear")&"</label>"
		king.ol="<textarea name=""kclear"" id=""k_kclear_"&knum&""" rows=""5"" cols=""20"" class=""in4"">"&formencode(data(5,0))&"</textarea>"
		king.ol="</p>"
		'kreplace
		king.ol="<p><label>"&kc.lang("label/kreplace")&"</label>"
		king.ol="<textarea name=""kreplace"" id=""k_kreplace_"&knum&""" rows=""5"" cols=""20"" class=""in4"">"&formencode(data(6,0))&"</textarea>"
		king.ol="</p>"
		'kclshtml

'		if king.instre("guide",data(0,0)) then
'			king.ol="<input type=""hidden"" id=""k_kclshtml_"&knum&""" value="""" />"
'		else
			king.ol="<p><label>"&kc.lang("label/kclshtml")&"</label>"
			king.ol="<input type=""text"" name=""kclshtml"" id=""k_kclshtml_"&knum&""" class=""in4"" value="""&formencode(data(7,0))&""" maxlength=""255"" />"
			king.ol="</p>"
'		end if

		king.ol="<p><label>"&kc.lang("label/attrib")&"</label><span>"
		'ishave
		if king.instre("arttitle,artcontent,ktitle",data(0,0)) then
			king.ol="<input type=""checkbox"" disabled=""true"" checked=""checked"" value=""1"" id=""k_ishave_"&knum&""" />"
		else
			if king.instre("1,true",cstr(data(9,0))) then checked=" checked=""checked""" else checked=""
			king.ol="<input type=""checkbox"" name=""ishave"" id=""k_ishave_"&knum&""" value=""1"""&checked&" />"
		end if
		king.ol="<label for=""k_ishave_"&knum&""">"&kc.lang("label/ishave")&"</label> "
		'isloop
		if king.instre("1,true",cstr(data(8,0))) then checked=" checked=""checked""" else checked=""
		king.ol="<input type=""checkbox"" name=""isloop"" id=""k_isloop_"&knum&""" value=""1"""&checked&" />"
		king.ol="<label for=""k_isloop_"&knum&""">"&kc.lang("label/isloop")&"</label> "
		'isxhtml
		if king.instre("arttitle,ktitle",data(0,0)) then
			king.ol="<input type=""checkbox"" value=""0"" disabled=""true"" id=""k_isxhtml_"&knum&""" />"
		else
			if king.instre("1,true",cstr(data(10,0))) then checked=" checked=""checked""" else checked=""
			king.ol="<input type=""checkbox"" name=""isxhtml"" id=""k_isxhtml_"&knum&""" value=""1"""&checked&" />"
		end if
		king.ol="<label for=""k_isxhtml_"&knum&""">"&kc.lang("label/isxhtml")&"</label> "
		'isreturn
		if king.instre("1,true",cstr(data(11,0))) then checked=" checked=""checked""" else checked=""
		king.ol="<input type=""checkbox"" name=""isreturn"" id=""k_isreturn_"&knum&""" value=""1"""&checked&" />"
		king.ol="<label for=""k_isreturn_"&knum&""">"&kc.lang("label/isreturn")&"</label> "
		king.ol="</span>"
		'isok
		if king.instre("1,true",cstr(data(12,0))) then checked=" checked=""checked""" else checked=""
		king.ol="<br/><input type=""checkbox"" name=""isok"" id=""k_isok_"&knum&""" value=""1"""&checked&" /><span><label for=""k_isok_"&knum&""">"&kc.lang("label/isok")&"</label></span>"'isloop
		Il "</p>"

		king.ol="<p class=""k_menu"">"
		'save
		I1="&knum="&knum&"&kname="&server.urlencode(kname)&"&klistname="&server.urlencode(data(0,0))&"&listid="&data(1,0)&"&kid="&kid
		I1=I1&"&kstart='+encodeURIComponent(document.getElementById('k_kstart_"&knum&"').value)"
		I1=I1&"+'&kend='+encodeURIComponent(document.getElementById('k_kend_"&knum&"').value)"
		I1=I1&"+'&kdefault='+encodeURIComponent(document.getElementById('k_kdefault_"&knum&"').value)"
		I1=I1&"+'&kclear='+encodeURIComponent(document.getElementById('k_kclear_"&knum&"').value)"
		I1=I1&"+'&kreplace='+encodeURIComponent(document.getElementById('k_kreplace_"&knum&"').value)"
		I1=I1&"+'&kclshtml='+encodeURIComponent(document.getElementById('k_kclshtml_"&knum&"').value)"
		I1=I1&"+'&ksize='+encodeURIComponent(document.getElementById('k_ksize_"&knum&"').value)"
		I1=I1&"+'&isloop='+encodeURIComponent(document.getElementById('k_isloop_"&knum&"').checked)"
		I1=I1&"+'&ishave='+encodeURIComponent(document.getElementById('k_ishave_"&knum&"').checked)"
		I1=I1&"+'&isxhtml='+encodeURIComponent(document.getElementById('k_isxhtml_"&knum&"').checked)"
		I1=I1&"+'&isreturn='+encodeURIComponent(document.getElementById('k_isreturn_"&knum&"').checked)"
		I1=I1&"+'&isok='+encodeURIComponent(document.getElementById('k_isok_"&knum&"').checked)"
		I1=I1&"+'&isimg='+encodeURIComponent(document.getElementById('k_isimg_"&knum&"').checked)"
		I1=I1&"+'&kguide='+encodeURIComponent(document.getElementById('k_kguide_"&knum&"').value)"
		I1=I1&"+'&istt='+encodeURIComponent(document.getElementById('k_istt_"&knum&"').checked)"

		king.ol="<input type=""button"" value="""&king.lang("common/save")&""" onclick=""posthtm('index.asp?action=set','k__"&data(0,0)&"','submits=edt&up=ok"&I1&")"" />"
		king.ol="<input type=""button"" value="""&kc.lang("common/view")&""" onclick=""posthtm('index.asp?action=set','aja','submits=view"&I1&")"" />"
		'back
		king.ol="<input type=""button"" value="""&king.lang("common/close")&""" onclick=""posthtm('index.asp?action=set','k__"&data(0,0)&"','submits=back&submit="&submit&"&listid="&data(1,0)&"&klistname="&data(0,0)&"&kid="&kid&"&kname="&server.urlencode(kname)&"&knum="&knum&"')"" /></p>"

		king.ol="</div>"
'		sql="klistname,listid,kstart,kend,kdefault,kclear,kreplace,kclshtml,isloop,ishave,isxhtml,isreturn,isok,kguide,istt,isimg,ksize"'16

		if king.ischeck and form("up")="ok" then
			if king.instre("true",data(8,0)) then data(8,0)=1 else data(8,0)=0
			if king.instre("true",data(9,0)) then data(9,0)=1 else data(9,0)=0
			if king.instre("true",data(10,0)) then data(10,0)=1 else data(10,0)=0
			if king.instre("true",data(11,0)) then data(11,0)=1 else data(11,0)=0
			if king.instre("true",data(12,0)) then data(12,0)=1 else data(12,0)=0
			if king.instre("true",data(14,0)) then data(14,0)=1 else data(14,0)=0
			if king.instre("true",data(15,0)) then data(15,0)=1 else data(15,0)=0
			if len(kid)>0 then'update
				conn.execute "update kingcollect_rule set kstart='"&safe(data(2,0))&"',kend='"&safe(data(3,0))&"',kdefault='"&safe(data(4,0))&"',kclear='"&safe(data(5,0))&"',kreplace='"&safe(data(6,0))&"',kclshtml='"&safe(data(7,0))&"',isloop="&data(8,0)&",ishave="&data(9,0)&",isxhtml="&data(10,0)&",isreturn="&data(11,0)&",isok="&data(12,0)&",kguide='"&safe(data(13,0))&"',istt="&data(14,0)&",isimg="&data(15,0)&",ksize="&data(16,0)&" where kid="&kid
			else
				conn.execute "insert into kingcollect_rule ("&sql&") values ('"&safe(data(0,0))&"',"&data(1,0)&",'"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&safe(data(5,0))&"','"&safe(data(6,0))&"','"&safe(data(7,0))&"',"&data(8,0)&","&data(9,0)&","&data(10,0)&","&data(11,0)&","&data(12,0)&",'"&safe(data(13,0))&"',"&data(14,0)&","&data(15,0)&","&data(16,0)&");"
				kid=king.newid("kingcollect_rule","kid")
			end if
			king.clearol
			king.ol=knum&") <a href=""javascript:"" onclick=""posthtm('index.asp?action=set','k__"&data(0,0)&"','submits=edt&knum="&knum&"&kname="&server.urlencode(kname)&"&kid="&kid&"')"">"&kname&"</a>"
			if isarray(session("collect_rule_"&data(1,0)&"_"&data(0,0)))>0 then
				Session.Contents.Remove("collect_rule_"&data(1,0)&"_"&data(0,0))
			end if
		end if

		king.txt king.writeol

	case"view"
		set rs=conn.execute("select kurltest,kplugin from kingcollect_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				kurltest=rs(0)
				kplugin=rs(1)
			else
				king.ol=king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing

		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next

		gethtm=king.gethtm(kurltest,4)

		king.ol="<div class=""k_form"">"
		king.ol="<p><label>"&kc.lang("list/kurltest")&"</label><a href="""&king_system&"system/link.asp?url="&server.urlencode(kurltest)&""" target=""_blank"">"&kurltest&"</a></p>"
		king.ol="<p><label>"&kc.lang("common/sect")&"</label>"
		king.ol="<textarea rows=""19"" cols=""21"" class=""in5"">"&formencode(kc.gethtm(gethtm,data,kplugin,kurltest))&"</textarea>"
		king.ol="</p>"
		king.ol="<p class=""k_menu""><input type=""button"" onclick=""display('aja')"" value="""&king.lang("common/close")&"""/></p>"
		king.ol="</div>"
		king.aja kc.lang("common/view"),king.writeol



	case"delete"
		if len(list)>0 then
			conn.execute "delete from kingcollect_list where listid in ("&list&");"
			conn.execute "delete from kingcollect_rule where listid in ("&list&");"
			
			lists=split(list,",")
			for i=0 to ubound(lists)
				conn.execute "drop table kingcollect_title_"&lists(i)&";"
				conn.execute "drop table kingcollect_url_"&lists(i)&";"
			next
			king.flo kc.lang("flo/deleteok"),1
		else
			king.flo kc.lang("flo/select"),0
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	king.head king.path,kc.lang("title")

	dim rs,data,dataform,sql,i,listid
	dim pct
	pct="100:1%|50:2%|25:4%|20:5%|10:10%|5:20%"
	sql="kname,kplugin,kcommend,khead,kshow,ishit,iscrtlist,kpath,kurlstart,kurlinc,kurlincpage,kurltest,isimg,ntime"'13
	listid=quest("listid",2)
	if len(listid)=0 then:listid=form("listid")
	if len(listid)>0 then'若有值的情况下
		if validate(listid,2)=false then king.error king.lang("error/invalid")
	end if
	
	if king.ismethod or len(listid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if king.ismethod=false then'初始化
			data(4,0)=1:data(5,0)=1:data(6,0)=1:data(7,0)=1
			data(8,0)="http://"
			data(11,0)="http://"
			data(12,0)=1
		end if
	else
		set rs=conn.execute("select "&sql&" from kingcollect_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	kc.list
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"
	'kname
	king.form_input "kname",kc.lang("label/kname"),data(0,0),"kname|6|"&encode(kc.lang("check/kname"))&"|1-50"
	'kplugin
	if len(listid)>0 then
		Il "<p><label>"&kc.lang("label/kplugin")&"</label><select disabled=""true""><option>"&data(1,0)&"</option></select></p>"
		king.form_hidden "kplugin",data(1,0)
	else
		king.form_select "kplugin",kc.lang("label/kplugin"),king__plugin(),data(1,0)
	end if
	'kcommend
	king.form_select "kcommend",kc.lang("label/commend"),pct,data(2,0)
	'khead
	king.form_select "khead",kc.lang("label/head"),pct,data(3,0)
	'kshow
	king.form_radio "kshow",kc.lang("label/show"),"1:"&encode(kc.lang("label/show1"))&"|0:"&encode(kc.lang("label/show0")),data(4,0)
	'ishit
	king.form_radio "ishit",kc.lang("label/hit"),"1:"&encode(kc.lang("label/hit1"))&"|0:"&encode(kc.lang("label/hit0")),data(5,0)
	'iscrtlist
	king.form_radio "iscrtlist",kc.lang("label/crtlist"),"0:"&encode(kc.lang("label/crtlist0"))&"|1:"&encode(kc.lang("label/crtlist1"))&"|2:"&encode(kc.lang("label/crtlist2")),data(6,0)
	'kpath
	king.form_radio "kpath",kc.lang("label/kpath"),"0:"&encode(kc.lang("label/kpath0"))&"|1:"&encode(kc.lang("label/kpath1"))&"|2:"&encode(kc.lang("label/kpath2")),data(7,0)
	'isimg
	king.form_radio "isimg",kc.lang("label/isimg"),"1:"&encode(kc.lang("label/isimg1"))&"|0:"&encode(kc.lang("label/isimg0")),data(12,0)
	'kurlstart
	king.form_input "kurlstart",kc.lang("label/kurlstart"),data(8,0),"kurlstart|6|"&encode(kc.lang("check/kurlstart"))&"|1-255;kurlstart|5|"&encode(kc.lang("check/kurlstart"))
	'kurlinc
	king.form_input "kurlinc",kc.lang("label/kurlinc"),data(9,0),"kurlinc|6|"&encode(kc.lang("check/kurlinc"))&"|1-255"
	'kurlincpage
	king.form_input "kurlincpage",kc.lang("label/kurlincpage"),data(10,0),"kurlincpage|6|"&encode(kc.lang("check/kurlincpage"))&"|1-255"
	'kurltest
	king.form_input "kurltest",kc.lang("label/kurltest"),data(11,0),"kurltest|6|"&encode("check/kurltest")&"|1-255;kurltest|5|"&encode(kc.lang("check/kurltest"))
	'ntime
	king.form_select "ntime",kc.lang("label/ntime"),"0:0sec|1000:1sec|2000:2sec|3000:3sec|5000:5sec|10000:10sec|100:100ms|200:200ms|500:500ms",data(13,0)

	king.form_but "save"
	king.form_hidden "listid",listid

	Il "</form>"

'	sql="kname,kplugin,kcommend,khead,kshow,ishit,iscrtlist,kpath,kurlstart,kurlinc,kurlincpage,kurltest,isimg,ntime"'13
	if king.ischeck and king.ismethod then
		if len(listid)>0 then
			conn.execute "update kingcollect_list set kname='"&safe(data(0,0))&"',kplugin='"&safe(data(1,0))&"',kcommend="&data(2,0)&",khead="&data(3,0)&",kshow="&data(4,0)&",ishit="&data(5,0)&",iscrtlist="&data(6,0)&",kpath="&data(7,0)&",kurlstart='"&safe(data(8,0))&"',kurlinc='"&safe(data(9,0))&"',kurlincpage='"&safe(data(10,0))&"',kurltest='"&safe(data(11,0))&"',isimg="&data(12,0)&",ntime="&data(13,0)&" where listid="&listid&";"
			if isarray(session("collect_list_"&listid)) then
				Session.Contents.Remove("collect_list_"&listid)
			end if
		else
			conn.execute "insert into kingcollect_list ("&sql&") values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"',"&data(2,0)&","&data(3,0)&","&data(4,0)&","&data(5,0)&","&data(6,0)&","&data(7,0)&",'"&safe(data(8,0))&"','"&safe(data(9,0))&"','"&safe(data(10,0))&"','"&safe(data(11,0))&"',"&data(12,0)&","&data(13,0)&")"
			'创建URL数据表
			kc.install_url king.newid("kingcollect_list","listid")
		end if
		Il "<script>confirm('"&htm2js(kc.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=edt'""):eval(""parent.location='index.asp'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king__plugin()
	dim data,i,rs,I1,I2,I3
	I2=array("article","download","movie")'"easyarticle",
	for i=0 to ubound(I2)
		if king.instre(king.plugin,I2(i)) then
			if len(I1)>0 then
				I1=I1&"|"&I2(i)&":"&encode(king.xmlang(I2(i),"title")&"|"&I2(i))
			else
				I1=I2(i)&":"&encode(king.xmlang(I2(i),"title")&"|"&I2(i))
			end if
			if lcase(I2(i))=lcase("download") or lcase(I2(i))=lcase("movie") then I2(i)=I2(i)&"class"
			execute "set I3=new "&I2(i):set I3=nothing
		end if
	next
	if king.instre(king.plugin,"oo_public") and king.checkcolumn("kingoo") then
	set rs=conn.execute("select oocolumn from kingoo;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				if len(I1)>0 then
					I1=I1&"|"&data(0,i)&":"&encode(king.xmlang(data(0,i),"title")&"|"&data(0,i))
				else
					I1=data(0,i)&":"&encode(king.xmlang(data(0,i),"title")&"|"&data(0,i))
				end if
			execute "set I3=new "&data(0,i)&"class":set I3=nothing
			next
		end if
		rs.close
	set rs=nothing
	end if
	king__plugin=I1
end function

%>