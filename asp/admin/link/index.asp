<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set kc=new linkclass
	select case action
	case"" king_def
	case"field" king_field
	case"edt" king_edt
	case"openlist" king_openlist
	case"edtlist" king_edtlist
	case"set","setlist" king_set
	case"create" king_create
	case"up","down" king_updown
	case"group" king_group
	case"edtgroup" king_edtgroup
	case"setgroup" king_setgroup
	case"tree" Il king_tree(0,0)
	case"search" king_search
	case"aja" king_aja
	end select
set kc=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_search()
	king.head king.path,kc.lang("common/search")
	dim rs,data,i,dp,listid'lpath:linkpath
	dim but,sql,ispath,lpath,listpath
	dim lists,insql
	dim query,tquery,space,selected

	tquery=quest("query",4)

	space=quest("space",2)
	if len(space)=0 then space=0
	select case cstr(space)
	case"1"
		query=king.likey("kdescription",tquery)
	case else
		query=king.likey("ktitle",tquery)
	end select

	sql="kid,ktitle,kc_urlpath,khit,kshow,kup,kcommend,khead,kgrade,listid"'9

	if len(query)=0 then query=" kid=0 "

	sql="select "&sql&" from king__link_page where "&query&" order by kdate desc;"

	kc.list

	Il "<form class=""k_form"" action=""index.asp"" name=""form_search""  method=""get"" >"
	Il "<p class=""c""><span>"&kc.lang("common/search")&"</span>：<input type=""text"" name=""query"" value="""&formencode(quest("query",0))&""" class=""in3"" maxlength=""100"" /> "
	Il "<select name=""space"">"
	if cstr(space)="0" then selected=" selected=""selected""" else selected=""
	Il "<option value=""0"""&selected&">"&kc.lang("label/sel/title")&"</option>"
	if cstr(space)="2" then selected=" selected=""selected""" else selected=""
	Il "<option value=""2"""&selected&">"&kc.lang("label/sel/author")&"</option>"
	if cstr(space)="1" then selected=" selected=""selected""" else selected=""
	Il "<option value=""1"""&selected&">"&kc.lang("label/sel/content")&"</option>"
	Il "</select> "
	Il "<input type=""submit"" value="""&king.lang("common/search")&""" class=""k_button"" />"
	Il "<input type=""hidden"" name=""action"" value=""search"" />"
	Il "</p></form>"

	set dp=new record
'		out sql
		dp.create sql
		dp.purl="index.asp?action=search&pid=$&rn="&dp.rn&"&query="&quest("query",0)&"&space="&space
		dp.but=dp.sect("moveto:"&kc.lang("common/moveto"))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&listid='+K[9]+'&kid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a> '"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[4],'show')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[5],'up')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[6],'commend')+'</i>'"
		'dp.js="'<i>'+setag('index.asp?action=set',K[0],K[7],'head')+'</i>'"
		dp.js="'<i>'+isexist(K[2],K[3],K[0])+'</i>'"
		'dp.js="K[8]"
		dp.js="edit('index.asp?action=edt&listid='+K[9]+'&kid='+K[0])"

		Il dp.open

		'Il "<tr><th>"&kc.lang("list/id")&") "&kc.lang("list/title")&"</th><th class=""c"">"&kc.lang("label/show")&"</th><th class=""c"">"&kc.lang("label/up")&"</th><th class=""c"">"&kc.lang("label/commend")&"</th><th class=""c"">"&kc.lang("label/head")&"</th><th class=""c"">"&kc.lang("list/file")&"</th><th>"&kc.lang("list/grade")&"</th><th class=""w2"">"&kc.lang("list/manage")&"</th></tr>"
		Il "<tr><th>"&kc.lang("list/id")&") "&kc.lang("list/title")&"</th><th class=""c"">"&kc.lang("label/show")&"</th><th class=""c"">"&kc.lang("label/up")&"</th><th class=""c"">"&kc.lang("label/commend")&"</th><th class=""c"">"&king.lang("common/brow")&"</th><th class=""w2"">"&kc.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			lpath=king_system&"system/link.asp?url="&dp.data(2,i)
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&True&"','"&lpath&"',"&dp.data(4,i)&","&dp.data(5,i)&","&dp.data(6,i)&","&listid&");"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,kc.lang("title")

	dim rs,data,i,dp,js'lpath:linkpath
	dim but,sql,listcount,inbut,k4,listid,sublist

	listid=quest("listid",2)
	if len(listid)=0 then listid=0

	kc.list

	sql="select listid,listname,listpath from king__link_list where listid1="&listid&" order by listorder desc,listid desc;"

	set dp=new record
		dp.action="index.asp?action=setlist"
		dp.purl="index.asp?pid=$&rn="&dp.rn&"&listid="&listid 'E1126
		dp.create sql
		dp.but=dp.sect("union:"&encode(kc.lang("common/union")))&dp.prn & dp.plist
		js="'<td>'+cklist(K[0])+K[4]+'<a href=""index.asp?action=field&listid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a></td>'"
		js=js&"+'<td>'+K[3]+'</td>'"
		'js=js&"+'<td><a href="""&king_system&"system/link.asp?url='+K[2]+'/"" target=""_blank""><img src=""../system/images/os/brow.gif""/>'+K[2]+'</a></td>'"
		js=js&"+'<td><a href=""index.asp?action=field&listid='+K[0]+'"" ><img src=""../system/images/os/brow.gif""/>'+K[2]+'</a></td>'"
		js=js&"+'<td>'+edit('index.asp?action=edtlist&listid='+K[0])+updown('index.asp?listid='+K[0],'index.asp')+'</td>'"

		Il dp.open

		Il "<tr><th>"&kc.lang("list/id")&") "&kc.lang("list/listname")&"</th><th>"&kc.lang("list/count")&"</th><th>"&kc.lang("list/path")&"</th><th class=""w2"">"&kc.lang("list/manage")&"</th></tr>"
		Il "<script>"
		Il "function ll(){var K=ll.arguments;document.write('<tbody id=""tr_'+K[0]+'""><tr>'+"&js&"+'</tr></tbody>');};var k_delete='"&htm2js(king.lang("confirm/delete"))&"';var k_clear='"&htm2js(king.lang("confirm/clear"))&"';"
		for i=0 to dp.length
			sublist=conn.execute("select count(listid) from king__link_list where listid1="&dp.data(0,i)&";")(0)
			if sublist=0 then
				k4="<img src=""../system/images/os/dir2.gif""/>"
			else
				k4="<a href=""index.asp?listid="&dp.data(0,i)&""" title="""&kc.lang("list/sublist")&":"&sublist&" ""><img src=""../system/images/os/dir1.gif""/></a>"
			end if
			listcount=conn.execute("select count(kid) from king__link_page where listid="&dp.data(0,i)&";")(0)
			Il "ll("&dp.data(0,i)&",'"&htm2js(htmlencode(dp.data(1,i)))&"','"&htm2js(king.inst&dp.data(2,i))&"','"&listcount&"','"&htm2js(k4)&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tree(l1,l2)

	dim rs,I1,data,i,nbsp

	if cstr(l1)="0" then
		king.head king.path,kc.lang("common/tree")
		kc.list
		I1=king_table_s
		I1=I1&"<tr><th>"&kc.lang("common/tree")&"</th></tr>"
		I1=I1&"<script>function ll(){var K=ll.arguments;var I1='<tr><td>'+nbsp(K[2])+' <img src=""../system/images/os/dir2.gif""/> <a href=""index.asp?action=field&listid='+K[0]+'"">'+K[1]+'</a></td></tr>';document.write(I1);};"
	end if
	
	for i=1 to l2
		nbsp=nbsp&"&nbsp; &nbsp; "
	next

	set rs=conn.execute("select listid,listname from king__link_list where listid1="&l1&" order by listorder asc,listid")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				I1=I1&"ll("&data(0,i)&",'"&htm2js(data(1,i))&"',"&l2&");"
				if conn.execute("select count(listid) from king__link_list where listid1="&data(0,i)&";")(0)>0 then
					I1=I1&king_tree(data(0,i),l2+1)
				end if
			next
		end if
		rs.close
	set rs=nothing

	if cstr(l1)="0" then
		I1=I1&"</script></table>"
	end if

	king_tree=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_group()
	king.head king.path,kc.lang("common/group")
	dim rs,data,i,listid

	listid=quest("listid",2)

	kc.list

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=group"">"
	Il king_table_s
	Il "<tr><th>"&kc.lang("list/id")&")"&kc.lang("list/group")&"</th><th class=""c"">"&kc.lang("list/num")&"</th><th>"&kc.lang("list/user")&"</th></tr>"
	Il "<tr><td>0) "&kc.lang("list/alluser")&"</td><td><i>1</i></td><td>"&kc.lang("list/alluser")&"</td></tr>"
	set rs=conn.execute("select groupid,groupnum,groupname from king__link_group order by groupnum;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				Il "<tr><td><a href=""index.asp?action=edtgroup&groupid="&data(0,i)&"&listid="&listid&""">"&data(0,i)&") "&htmlencode(data(2,i))&"</a></td><td><i>"&data(1,i)&"</i></td>"
				Il "<td><a href=""index.asp?action=edtgroup&groupid="&data(0,i)&"&listid="&listid&"""><img src=""../system/images/os/edit.gif""/></a>"
				Il "<a href=""javascript:;"" onclick=""javascript:confirm('"&king.lang("confirm/delete")&"')?posthtm('index.asp?action=setgroup','flo','groupid="&data(0,i)&"'):void(0);""><img src=""../system/images/os/del.gif""/></a></td></tr>"
			next
		end if
		rs.close
	set rs=nothing
	Il "</table>"
	Il "</form>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_setgroup()
	king.head king.path,0
	dim groupid
	groupid=form("groupid")
	if len(groupid)>0 then
		if validate(groupid,2)=false then king.error king.lang("error/invalid")
		conn.execute "delete from king__link_group where groupid="&groupid&";"
		king.flo kc.lang("flo/delgroup"),1
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edtgroup()
	king.head king.path,kc.lang("common/group")

	dim rs,data,i,dataform,sql,listid
	dim groupid,checknum,isnum

	listid=quest("listid",2):if len(listid)=0 then listid=form("listid")

	groupid=quest("groupid",2)
	if len(groupid)=0 then groupid=form("groupid")
	if len(form("groupid"))>0 then'若表单有值的情况下
		if validate(groupid,2)=false then king.error king.lang("error/invalid")
	end if

	kc.list

	sql="groupnum,groupname,groupuser"

	if king.ismethod or len(groupid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if king.ismethod=false then
			if conn.execute("select count(groupid) from king__link_group;")(0)>0 then
				data(0,0)=conn.execute("select max(groupnum) from king__link_group;")(0)+1
			else
				data(0,0)=2
			end if
		end if
	else
		set rs=conn.execute("select "&sql&" from king__link_group where groupid="&groupid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edtgroup"">"
	Il "<p><label>"&kc.lang("label/num")&"</label><input type=""text"" name=""groupnum"" class=""in1"" value="""&data(0,0)&""" maxlength=""3"" />"
	isnum=false
	if validate(form("groupnum"),2) then
		if cdbl(form("groupnum"))>1 then isnum=true
	end if
	if len(groupid)>0 then
		checknum="groupnum|6|"&encode(kc.lang("check/num"))&"|1-5;groupnum|9|"&encode(kc.lang("check/num1"))&"|select count(groupid) from king__link_group where groupnum=$pro$ and groupid<>"&groupid&";groupnum|2|"&encode(kc.lang("check/num2"))&";"&isnum&"|13|"&encode(kc.lang("check/num3"))
	else
		checknum="groupnum|6|"&encode(kc.lang("check/num"))&"|1-5;groupnum|9|"&encode(kc.lang("check/num1"))&"|select count(groupid) from king__link_group where groupnum=$pro$;groupnum|2|"&encode(kc.lang("check/num2"))&";"&isnum&"|13|"&encode(kc.lang("check/num3"))
	end if
	Il king.check(checknum)
	Il "</p>"
	king.form_input "groupname",kc.lang("label/groupname"),data(1,0),"groupname|6|"&encode(kc.lang("check/groupname"))&"|1-50"
	Il "<p><label>"&kc.lang("label/groupuser")&"</label><textarea name=""groupuser"" class=""in5"" rows=""25"" cols=""70"">"&formencode(data(2,0))&"</textarea>"
	king.form_but "save"
	king.form_hidden "groupid",groupid
	king.form_hidden "listid",listid

	Il "</form>"
	if king.ischeck and king.ismethod then
		if len(groupid)>0 then
			conn.execute "update king__link_group set groupnum="&data(0,0)&",groupname='"&safe(data(1,0))&"',groupuser='"&safe(data(2,0))&"' where groupid="&groupid
		else
			conn.execute "insert into king__link_group ("&sql&") values ("&data(0,0)&",'"&safe(data(1,0))&"','"&safe(data(2,0))&"')"
		end if
		Il "<script>confirm('"&htm2js(kc.lang("alert/saveokgroup"))&"')?eval(""parent.location='index.asp?action=edtgroup&listid="&listid&"'""):eval(""parent.location='index.asp?action=group&listid="&listid&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_field()
	king.head king.path,kc.lang("title")
	dim rs,data,i,dp,listid'lpath:linkpath
	dim but,sql,ispath,lpath,listpath
	dim lists

	listid=quest("listid",2)
	if len(listid)=0 then king.error link("error/listid")

	set rs=conn.execute("select listpath from king__link_list where listid="&listid&";")
		if not rs.eof and not rs.bof then
			listpath=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	kc.list

	sql="kid,ktitle,kc_urlpath,khit,kshow,kup,kcommend,khead,kgrade"'8
	sql="select "&sql&" from king__link_page where listid="&listid&" order by korder desc,kid desc;"

	set dp=new record
		dp.create sql
		dp.value="listid="&listid
		dp.purl="index.asp?action=field&pid=$&rn="&dp.rn&"&listid="&listid
		dp.but=dp.sect("moveto:"&kc.lang("common/moveto")&"|-|show1:"&kc.lang("common/show1")&"|up1:"&kc.lang("common/up1")&"|commend1:"&kc.lang("common/commend1")&"|head1:"&kc.lang("common/head1")&"|-|show0:"&kc.lang("common/show0")&"|up0:"&kc.lang("common/up0")&"|commend0:"&kc.lang("common/commend0")&"|head0:"&kc.lang("common/head0"))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&listid="&listid&"&kid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a> '"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[4],'show')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[5],'up')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[6],'commend')+'</i>'"
		'dp.js="'<i>'+setag('index.asp?action=set',K[0],K[7],'head')+'</i>'"
		dp.js="'<i>'+isexist(K[2],K[3],K[0])+'</i>'"
		'dp.js="K[8]"
		dp.js="edit('index.asp?action=edt&listid="&listid&"&kid='+K[0])+updown('index.asp?listid="&listid&"&kid='+K[0],'index.asp?action=field&listid="&listid&"')"

		Il dp.open

		'Il "<tr><th>"&kc.lang("list/id")&") "&kc.lang("list/title")&"</th><th class=""c"">"&kc.lang("label/show")&"</th><th class=""c"">"&kc.lang("label/up")&"</th><th class=""c"">"&kc.lang("label/commend")&"</th><th class=""c"">"&kc.lang("label/head")&"</th><th class=""c"">"&kc.lang("list/file")&"</th><th>"&kc.lang("list/grade")&"</th><th class=""w2"">"&kc.lang("list/manage")&"</th></tr>"
		Il "<tr><th>"&kc.lang("list/id")&") "&kc.lang("list/title")&"</th><th class=""c"">"&kc.lang("label/show")&"</th><th class=""c"">"&kc.lang("label/up")&"</th><th class=""c"">"&kc.lang("label/commend")&"</th><th class=""c"">"&king.lang("common/brow")&"</th><th class=""w2"">"&kc.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			lpath=king_system&"system/link.asp?url="&dp.data(2,i)
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&True&"','"&lpath&"',"&dp.data(4,i)&","&dp.data(5,i)&","&dp.data(6,i)&","&listid&");"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	Server.ScriptTimeOut=86400
	king.head king.path,0
	dim list,rs,data,i,j,lists
	dim listpath,listid,ol,listids,kids
	dim newlist,ksubmit,kis
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	'action=set 文章操作，action=setlist 列表操作

	select case form("submits")
	case"show","up","commend","head"
		dim id,url,tag
		id=safe(form("id"))
		url=form("url")
		tag=form("tag"):if cstr(tag)="1" then tag=0 else tag=1
		conn.execute "update king__link_page set k"&form("submits")&"="&tag&" where kid="&id&";"
		king.txt "<img onclick=""javascript:posthtm('"&url&"','tag_"&form("submits")&id&"','submits="&form("submits")&"&url="&server.urlencode(url)&"&id="&id&"&tag="&tag&"');"" src=""../system/images/os/tag"&tag&".gif""/>"
	case"show0","show1","up0","up1","commend1","commend0","head0","head1"
		if len(list)>0 then
			ksubmit=left(form("submits"),len(form("submits"))-1)
			kis=right(form("submits"),1)
			conn.execute "update king__link_page set k"&ksubmit&"="&kis&" where kid in ("&list&");"
			king.flo kc.lang("flo/"&form("submits")),1
		else
			king.flo kc.lang("flo/select"),0
		end if
	case"search" 
		king.ol="<form class=""k_form"" action=""index.asp""  method=""get"" >"
		king.ol="<p><label>"&kc.lang("label/key")&"</label><input type=""text"" name=""query"" class=""in3"" maxlength=""100"" /> "
		king.ol="<select name=""space"">"
		king.ol="<option value=""0"">"&kc.lang("label/sel/title")&"</option>"
		king.ol="<option value=""2"">"&kc.lang("label/sel/author")&"</option>"
		king.ol="<option value=""1"">"&kc.lang("label/sel/content")&"</option>"
		king.ol="</select>"
		king.ol="</p>"
		king.ol="<div class=""k_but""><input type=""submit"" value="""&king.lang("common/search")&""" />"
		king.ol="<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');"" /></div>"
		king.ol="<input type=""hidden"" name=""action"" value=""search"" />"
		king.ol="</form>"
		king.flo king.writeol,2
	case"union"
		if len(list)>0 then
			newlist=form("newlist")
			if len(newlist)=0 then
				ol="<div id=""main"">"
				ol=ol&"<p><label>"&kc.lang("label/newlist")&"</label>"
				ol=ol&"<select name=""newlist"" id=""king_newlist"">"
				set rs=conn.execute("select listid,listname from king__link_list where listid in ("&list&") order by listorder desc")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							ol=ol&"<option value="""&data(0,i)&""">"&formencode(data(1,i))&"</option>"
						next
					end if
					rs.close
				set rs=nothing
				ol=ol&"</select>"
				ol=ol&"</p>"

				ol=ol&"<div class=""k_menu""><input type=""button"" value="""&kc.lang("list/move")&""" "
				ol=ol&"onclick=""javascript:posthtm('index.asp?action=set','flo','submits=union&newlist='+encodeURIComponent(document.getElementById('king_newlist').value)+'&list="&list&"');"" />"
				ol=ol&"<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');""/>"
				ol=ol&"</div>"'end k_but

				ol=ol&"</div>"'end k_form
				king.flo ol,2
				
			else
				'删除原数据
				set rs=conn.execute("select listid,listpath from king__link_list where listid in ("&list&") and listid<>"&newlist&";")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							king.deletefolder "../../"&data(1,i)
						next
					end if
					rs.close
				set rs=nothing
				conn.execute "update king__link_page set listid="&newlist&" where listid in ("&list&");"
				king.flo kc.lang("flo/unionok"),0
			end if
		else
			king.flo kc.lang("flo/select"),0
		end if
	case"moveto"
		if len(list)>0 then
			newlist=form("newlist")
			if len(newlist)=0 then
				ol="<div id=""main"">"
				ol=ol&"<p><label>"&kc.lang("label/newlist")&"</label>"
				ol=ol&king__list1(0,0)
				ol=ol&"</p>"

				ol=ol&"<div class=""k_menu""><input type=""button"" value="""&kc.lang("list/move")&""" "
				ol=ol&"onclick=""javascript:posthtm('index.asp?action=set','flo','submits=moveto&newlist='+encodeURIComponent(document.getElementById('listid').value)+'&list="&list&"');"" />"
				ol=ol&"<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');""/>"
				ol=ol&"</div>"'end k_but

				ol=ol&"</div>"'end k_form
				king.flo ol,2
			else
				'读取删除目录
				set rs=conn.execute("select listid,kid,kpath from king__link_page where kid in ("&list&")")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if listid<>data(0,i) then
								listpath=conn.execute("select listpath from king__link_list where listid="&data(0,i)&";")(0)
								listid=data(0,i)
							end if
							if king.isfile(data(2,i)) then'文件
								for j=1 to 50
									king.deletefile kc.pagepath("../../"&listpath&"/"&data(2,i),j)
								next
							else
								king.deletefolder "../../"&listpath&"/"&data(2,i)
							end if
							if len(listids)>0 then
								if king.instre(listids,data(0,i))=false then
									listids=listids&","&data(0,i)
								end if
							else
								listids=data(0,i)
							end if
						next
					end if
					rs.close
				set rs=nothing
				'数据移动
				conn.execute "update king__link_page set listid="&newlist&" where kid in ("&list&");"
				king.flo kc.lang("flo/moveok"),1
			end if
		else
			king.flo kc.lang("flo/select"),0
		end if
	case"delete"
		if len(list)>0 then
			if action="set" then
				set rs=conn.execute("select kid,listid,kpath from king__link_page where kid in ("&list&");")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if cstr(listid)<>cstr(data(1,i)) then
								listpath=conn.execute("select listpath from king__link_list where listid="&data(1,i)&";")(0)
								listid=data(1,i)
							end if
							if king.isfile(data(2,i)) then'文件
								for j=1 to 50
									king.deletefile kc.pagepath("../../"&listpath&"/"&data(2,i),j)
								next
							else
								king.deletefolder "../../"&listpath&"/"&data(2,i)
							end if
						next
						conn.execute "delete from king__link_page where kid in ("&list&");"
					else
						king.flo kc.lang("flo/invalid"),1
					end if
					rs.close
				set rs=nothing
			else'删除list及list下面的文章
				set rs=conn.execute("select listid,listpath from king__link_list where listid in ("&list&");")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if conn.execute("select count(*) from king__link_list where listid1="&data(0,i)&";")(0)>0 then
								king.flo kc.lang("flo/notdel"),1
							end if
							king.deletefolder "../../"&data(1,i)
							conn.execute "delete from king__link_list where listid="&data(0,i)&";"
							conn.execute "delete from king__link_page where listid="&data(0,i)&";"
						next
					else
						king.flo kc.lang("flo/invalid"),1
					end if
					rs.close
				set rs=nothing
			end if
			king.flo kc.lang("flo/deleteok"),1
		else
			king.flo kc.lang("flo/select"),0
		end if
	case"list"
		listid=form("listid")
		listids=form("listids")
		king.ol="<form name=""form2"" class=""k_form"">"
		king.ol="<p><label>"&kc.lang("list/listids")&"</label></p>"
		king.ol=king__lists(0,0,listid,listids)
		king.ol="<div class=""k_menu"">"
		king.ol="<input type=""button"" value="""&king.lang("common/submit")&""" onclick=""javascript:document.getElementById('listids').value=fgetchecked();document.getElementById('listid').value=rgetchecked();display('aja');"" />"
		king.ol="<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('aja');"" />"
		king.ol="</div>"
		king.ol="</form>"
		king.aja kc.lang("common/listids"),king.writeol
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	king.head king.path,kc.lang("title")

	dim rs,data,dataform,sql,i,kid,listid,insql,sql_field,fields
	dim kdescription,kkeywords,checkpath,checktitle
	dim maxkid,datalist,checked,selected,idata,snapfield,snapfields
	dim k_is:k_is=array(0,1,0)
	dim re:re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="index.asp?action=art&listid="&listid

	sql_field="kc_image,kc_urlpath"
	sql="ktitle,kshow,kcommend,kup,khead,kgrade,kkeywords,kdescription,kpath,listids"
	if len(sql_field)>0 then sql=sql&","&sql_field

	kid=quest("kid",2)
	if len(kid)=0 then kid=form("kid")
	if len(form("kid"))>0 then'若表单有值的情况下
		if validate(kid,2)=false then king.error king.lang("error/invalid")
	end if

	listid=quest("listid",2)
	if len(listid)=0 then listid=form("listid")
	if len(form("listid"))>0 then
		if validate(listid,2)=false then king.error king.lang("error/invalid")
	end if

	if king.ismethod or len(kid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if king.ismethod=false then
			data(1,0)=1
			data(8,0)=kc.lang("common/pinyin")

		end if

	else
		set rs=conn.execute("select "&sql&" from king__link_page where kid="&kid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	kc.list
	'Il "<script>"
	'Il "function fgetchecked(){var strcheck;strcheck="""";"
	'Il "if (document.form2.list!=undefined){for(var i=0;i<document.form2.list.length;i++){if(document.form2.list[i].checked){"
	'Il "if (strcheck==""""){strcheck=document.form2.list[i].value;}"
	'Il "else{strcheck=strcheck+','+document.form2.list[i].value;}}}"
	'Il "if (document.form2.list.length==undefined){if (document.form2.list.checked==true)"
	'Il "{strcheck=document.form2.list.value;}}}return strcheck;}"
	'Il "function rgetchecked(){var strcheck;strcheck="""";"
	'Il "if (document.form2.f_listid!=undefined){for(var i=0;i<document.form2.f_listid.length;i++){if(document.form2.f_listid[i].checked){"
	'Il "if (strcheck==""""){strcheck=document.form2.f_listid[i].value;}"
	'Il "else{strcheck=strcheck+','+document.form2.f_listid[i].value;}}}"
	'Il "if (document.form2.f_listid.length==undefined){if (document.form2.f_listid.checked==true)"
	'Il "{strcheck=document.form2.f_listid.value;}}}return strcheck;}"
	'Il "</script>"

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"

	if conn.execute("select count(listid) from king__link_list;")(0)=0 then
		king.error  kc.lang("error/notlist")
	end if

	'info
	Il "<p>"
	Il "<label>"&kc.lang("label/info")&"</label><span>"
	'Il "<a href=""javascript:;"" onclick=""javascript:posthtm('index.asp?action=set','aja','submits=list&listid='+document.getElementById('listid').value+'&listids='+document.getElementById('listids').value)"">["&kc.lang("label/list")&"]</a> - "
	if cstr(data(1,0))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""kshow"" id=""kshow"""&checked&"><label for=""kshow"">"&kc.lang("label/show")&"</label> "
	if cstr(data(2,0))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""kcommend"" id=""kcommend"""&checked&"><label for=""kcommend"">"&kc.lang("label/commend")&"</label> "
	if cstr(data(3,0))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""kup"" id=""kup"""&checked&"><label for=""kup"">"&kc.lang("label/up")&"</label> "
	'if cstr(data(4,0))="1" then checked=" checked=""checked""" else checked=""
	'Il "<input type=""checkbox"" value=""1"" name=""khead"" id=""khead"""&checked&"><label for=""khead"">"&kc.lang("label/head")&"</label> "
	Il " - "
	

	'if cstr(form("uplist"))="1" then checked=" checked=""checked""" else checked="" ' or cstr(form("uplist"))=""
	'Il "<input type=""checkbox"" value=""1"" name=""uplist"" id=""uplist"""&checked&"><label for=""uplist"">"&kc.lang("label/uplist")&"</label> "
	'if cstr(form("createhome"))="1" or cstr(form("createhome"))="" then checked=" checked=""checked""" else checked=""
	'Il "<input type=""checkbox"" value=""1"" name=""createhome"" id=""createhome"""&checked&"><label for=""createhome"">"&king.lang("common/createhome")&"</label> "
	if cstr(form("checktitle"))="1" or cstr(form("checktitle"))="" then checked=" checked=""checked""" else checked=""
	Il " <input type=""checkbox"" value=""1"" name=""checktitle"" id=""checktitle"""&checked&"><label for=""checktitle"">"&kc.lang("label/checktitle")&"</label>"
	Il "</span></p>"

	'ktitle
	'需要检查标题是否重复
	if cstr(form("checktitle"))="1" then
		if len(kid)>0 then
			checktitle="ktitle|6|"&encode(kc.lang("check/title"))&"|1-100;ktitle|9|"&encode(kc.lang("check/title1"))&"|select count(kid) from king__link_page where listid="&listid&" and ktitle='$pro$' and kid<>"&kid
		else
			checktitle="ktitle|6|"&encode(kc.lang("check/title"))&"|1-100;ktitle|9|"&encode(kc.lang("check/title1"))&"|select count(kid) from king__link_page where listid="&listid&" and ktitle='$pro$'"
		end if
	else
		checktitle="ktitle|6|"&encode(kc.lang("check/title"))&"|1-100"
	end if
	king.form_input "ktitle",kc.lang("label/title"),data(0,0),checktitle

	'image
	Il "<p><label>"&kc.lang("label/image")&"<i>{king:image/}</i></label><input maxlength="""" type=""text"" name=""kc_image"" id=""kc_image"" value="""&formencode(data(10,0))&""" class=""in4"" />"
	king.form_brow "kc_image","jpeg/jpg/png/gif"
if len(form("kc_image"))>0 then
	Il king.check("")
end if
	Il "</p>"
	'urlpath
	Il "<p><label>"&kc.lang("label/urlpath")&"<i>{king:urlpath/}</i></label><input maxlength="""" type=""text"" name=""kc_urlpath"" id=""kc_urlpath"" value="""&formencode(data(11,0))&""" class=""in4"" />"
	Il king.check("kc_urlpath|0|"&encode(kc.lang("check/urlpath1"))&";kc_urlpath|5|"&encode(kc.lang("check/urlpath2")))
	Il "</p>"

	'kpath
	if k_is(2)=1 then
		if len(kid)>0 then'更新
			checkpath=";kpath|9|"&encode(kc.lang("check/path2"))&"|select count(kid) from king__link_page where listid="&listid&" and kpath='$pro$' and kid<>"&kid
		else
			checkpath=";kpath|9|"&encode(kc.lang("check/path2"))&"|select count(kid) from king__link_page where listid="&listid&" and kpath='$pro$'"
		end if
		Il "<p><label>"&kc.lang("label/fpath")&"</label><input maxlength=""255"" type=""text"" name=""kpath"" id=""kpath"" value="""&formencode(data(8,0))&""" class=""in4"" />"
		if len(kid)=0 then
			maxkid=king.neworder("king__link_page","kid")
			Il king.form_eval("kpath",maxkid&"."&split(king_ext,".")(1))
			Il king.form_eval("kpath",formatdate(now,2)&"/"&maxkid)
		end if
		Il " <a href=""javascript:;"" onclick=""javascript:document.getElementById('kpath').value=document.getElementById('ktitle').value"">["&kc.lang("common/accord")&"]</a>"
		Il king.form_eval("kpath",kc.lang("common/pinyin"))
		Il king.form_eval("kpath","MD5")
		Il king.check("kpath|6|"&encode(kc.lang("check/path"))&"|1-255;kpath|15|"&encode(kc.lang("check/path1"))&checkpath)
		Il "</p>"

		'没有路径的时候，无需访问权限
		if king.instre(king.plugin,"passport") then
			Il "<p><label>"&kc.lang("label/grade/title")&"</label>"
			Il "<select name=""kgrade"" id=""kgrade"">"
			Il "<option value=""0"">"&kc.lang("label/grade/g0")&"</option>"
			Il "<option value=""1"">"&kc.lang("label/grade/g1")&"</option>"
			set rs=conn.execute("select groupnum,groupname from king__link_group order by groupnum")
				if not rs.eof and not rs.bof then
					idata=rs.getrows()
					for i=0 to ubound(idata,2)
						if cstr(idata(0,i))=cstr(data(5,0)) then selected=" selected=""selected""" else selected=""
						Il "<option value="""&idata(0,i)&""""&selected&">"&htmlencode(idata(1,i))&"</option>"
					next
				end if
				rs.close
			set rs=nothing
			Il "</select>"
			Il " <a href=""index.asp?action=group"" target=""_blank"">["&king.lang("common/manage")&"]</a>"
			Il "</p>"
		else
			king.form_hidden "kgrade",0
		end if

	end if

	'0直接生成html 1:限会员访问 4:限vip访问 
	if k_is(0)=1 then
		'linkkeyword
		king.form_input "kkeywords",kc.lang("label/keyword"),data(6,0),"kkeywords|6|"&encode(kc.lang("check/keyword"))&"|0-100"
	end if
	'kdescription
	if k_is(1)=1 then
		king.form_area "kdescription",kc.lang("label/description"),data(7,0),"kdescription|6|"&encode(kc.lang("check/description"))&"|0-255"
	end if

	king.form_but "save"
	king.form_hidden "kid",kid
	king.form_hidden "listid",listid
	king.form_hidden "listids",data(9,0)
	king.form_hidden "re",re

	Il "</form>"

	if king.ischeck and king.ismethod then
		'kdescription
		if len(data(7,0))>0 then
			kdescription=king.lefte(data(7,0),250)
		end if
		'kkeywords
		kkeywords=king.key(data(0,0)&","&kdescription,data(6,0))

		'kpath
		if data(8,0)=kc.lang("common/pinyin") then'拼音文件名
			data(8,0)=king.pinyin(data(0,0))
			data(8,0)=replace(data(8,0),".","_")
		end if
		if data(8,0)="MD5" then
			if len(kid)>0 then
				data(8,0)=md5(salt(10)&kid,0)
			else
				data(8,0)=md5(salt(10)&king.neworder("king__link_page","korder"),0)
			end if
		end if
		'listids
		if len(data(9,0))>0 then
			data(9,0)=","&data(9,0)&","
		end if


		snapfields=split("10",",")
		for i=0 to ubound(snapfields)
			if validate(data(snapfields(i),0),5) then
				snapfield=data(snapfields(i),0)
				data(snapfields(i),0)=king.inst&king_upath&"/image/"&kc.path&"/"&formatdate(date(),2)&"/"&int(timer()*100)&i&"."&king.extension(snapfield)
				king.createfolder data(snapfields(i),0)
				king.remote2local snapfield,data(snapfields(i),0)
			end if
		next

		if cstr(data(1,0))<>"1" then data(1,0)=0
		if cstr(data(2,0))<>"1" then data(2,0)=0
		if cstr(data(3,0))<>"1" then data(3,0)=0
		'if cstr(data(4,0))<>"1" then 
		data(4,0)=0
		if validate(data(5,0),2)=false then data(5,0)=0

'	sql="ktitle,kshow,kcommend,kup,khead,kgrade,kkeywords,kdescription,kpath,listids,kc_image,kc_urlpath"

		'Insert Update
		if len(kid)>0 then
			if len(sql_field)>0 then
				fields=split(sql_field,",")
				for i=0 to ubound(fields)
					insql=insql&","&fields(i)&"='"&safe(data(i+10,0))&"'"
				next
			end if
			conn.execute "update king__link_page set ktitle='"&safe(data(0,0))&"',kshow="&safe(data(1,0))&",kcommend="&safe(data(2,0))&" ,kup="&safe(data(3,0))&",khead="&safe(data(4,0))&",kgrade="&safe(data(5,0))&",kpath='"&safe(data(8,0))&"',listids='"&safe(data(9,0))&"',listid="&listid&",kdescription='"&safe(kdescription)&"',kkeywords='"&safe(kkeywords)&"'"&insql&" where kid="&kid&";"
		else
			if len(sql_field)>0 then
				fields=split(sql_field,",")
				for i=0 to ubound(fields)
					insql=insql&",'"&safe(data(i+10,0))&"'"
				next
			end if
			conn.execute "insert into king__link_page ("&sql&",kdate,korder,listid) values ('"&safe(data(0,0))&"',"&safe(data(1,0))&","&safe(data(2,0))&","&safe(data(3,0))&","&safe(data(4,0))&","&safe(data(5,0))&",'"&safe(kkeywords)&"','"&safe(kdescription)&"','"&safe(data(8,0))&"','"&safe(data(9,0))&"'"&insql&",'"&tnow&"',"&king.neworder("king__link_page","korder")&","&listid&")"
			kid=king.newid("king__link_page","kid")

			set rs=conn.execute("select listname,listpath from king__link_list where listid="&listid&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
				end if
				rs.close
			set rs=nothing

'			king.letrss data(0,0),kc.getpath(kid,data(8,0),king.inst&datalist(1,0)&"/"&data(11,0)),kdescription,data(1,0),data(12,0),0,datalist(0,0),data(3,0),data(2,0),tnow
'			king.createrss
		end if

		Il "<script>confirm('"&htm2js(kc.lang("alert/saveokobj"))&"')?eval(""parent.location='index.asp?action=edt&listid="&listid&"'""):eval(""parent.location='"&re&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king__list(l1,l2,l3,l4)
	dim rs,I1,data,i,nbsp,selected
	dim l5
	if cstr(l1)="0" then
		I1="<select name=""listid1"">"
		I1=I1&"<option value=""0"">"&kc.lang("common/root")&"</option>"
	end if
	
	for i=0 to l2
		nbsp=nbsp&"&nbsp; &nbsp; "
	next

	set rs=conn.execute("select listid,listname from king__link_list where listid1="&l1&" order by listorder asc,listid")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				if cstr(l4)<>cstr(data(0,i)) then
					if cstr(l3)=cstr(data(0,i)) then selected=" selected=""selected""" else selected=""
					I1=I1&"<option value="""&data(0,i)&""""&selected&">"&nbsp&formencode(data(1,i))&"</option>"
					if conn.execute("select count(listid) from king__link_list where listid1="&data(0,i)&";")(0)>0 then
						I1=I1&king__list(data(0,i),l2+1,l3,l4)
					end if
				end if
			next
		end if
		rs.close
	set rs=nothing

	if cstr(l1)="0" then
		I1=I1&"</select>"
	end if

	king__list=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king__list1(l1,l2)
	dim rs,I1,data,i,nbsp
	if cstr(l1)="0" then
		I1="<select name=""listid"">"
	end if
	
	for i=1 to l2
		nbsp=nbsp&"&nbsp; &nbsp; "
	next

	set rs=conn.execute("select listid,listname from king__link_list where listid1="&l1&" order by listorder asc,listid")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				I1=I1&"<option value="""&data(0,i)&""">"&nbsp&formencode(data(1,i))&"</option>"
				if conn.execute("select count(listid) from king__link_list where listid1="&data(0,i)&";")(0)>0 then
					I1=I1&king__list1(data(0,i),l2+1)
				end if
			next
		end if
		rs.close
	set rs=nothing

	if cstr(l1)="0" then
		I1=I1&"</select>"
	end if

	king__list1=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king__lists(l1,l2,l3,l4)'0,0,listid,listids
	dim rs,I1,data,i,nbsp,checked
	
	for i=0 to l2-1
		nbsp=nbsp&"----"
	next

	set rs=conn.execute("select listid,listname from king__link_list where listid1="&l1&" order by listorder asc,listid")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				if cstr(l3)=cstr(data(0,i)) then checked=" checked=""checked""" else checked=""
				I1=I1&"<p><span>"
				I1=I1&"<input type=""radio"" name=""f_listid"" id=""f_listid"" value="""&data(0,i)&""""&checked&">"
				if king.instre(l4,data(0,i)) then checked=" checked=""checked""" else checked=""
				I1=I1&nbsp&"<input type=""checkbox"" value="""&data(0,i)&""" name=""list"" id=""list_"&data(0,i)&""""&checked&">"
				I1=I1&"<label for=""list_"&data(0,i)&""">"&htmlencode(data(1,i))&"</label>"
				I1=I1&"</span></p>"
				if conn.execute("select count(listid) from king__link_list where listid1="&data(0,i)&";")(0)>0 then
					I1=I1&king__lists(data(0,i),l2+1,l3,l4)
				end if
			next
		end if
		rs.close
	set rs=nothing

	king__lists=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edtlist()
	king.head king.path,kc.lang("title")

	dim re:re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="index.asp?action=edtlist"

	dim rs,data,dataform,sql,i,listid,checkpath
	sql="listname,listpath,listkeyword,listdescription,listtitle"'9
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
		if len(quest("listid1",2))>0 then
			data(6,0)=quest("listid1",2)
		end if
	else
		set rs=conn.execute("select "&sql&" from king__link_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	kc.list

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edtlist"">"

	'Il "<p><label>"&kc.lang("label/suplist")&"</label>"&king__list(0,0,data(2,0),listid)&"</p>"

	king.form_input "listname",kc.lang("list/listname"),data(0,0),"listname|6|"&encode(kc.lang("check/listname"))&"|1-30"
	king.form_input "listtitle",kc.lang("label/listtitle"),data(4,0),"listtitle|6|"&encode(kc.lang("check/listtitle"))&"|1-100"

	if len(listid)>0 then'更新
		checkpath="listpath|6|"&encode(kc.lang("check/path"))&"|1-100;listpath|15|"&encode(kc.lang("check/path1"))&";listpath|9|"&encode(kc.lang("check/path2"))&"|select count(listid) from king__link_list where listpath='$pro$' and listid<>"&listid
	else
		checkpath="listpath|6|"&encode(kc.lang("check/path"))&"|1-100;listpath|15|"&encode(kc.lang("check/path1"))&";listpath|9|"&encode(kc.lang("check/path2"))&"|select count(listid) from king__link_list where listpath='$pro$'"
	end if
	king.form_input "listpath",kc.lang("label/path"),data(1,0),checkpath
	king.form_input "listkeyword",kc.lang("label/listkeyword"),data(2,0),"listkeyword|6|"&encode(kc.lang("check/keyword"))&"|0-120"
	king.form_area "listdescription",kc.lang("label/listdescription"),data(3,0),"listdescription|6|"&encode(kc.lang("check/description"))&"|0-250"

	king.form_but "save"
	king.form_hidden "listid",listid
	king.form_hidden "re",re

	Il "</form>"

	if king.ischeck and king.ismethod then
		if len(listid)>0 then
			conn.execute "update king__link_list set listname='"&safe(data(0,0))&"',listpath='"&safe(data(1,0))&"',listkeyword='"&safe(data(2,0))&"',listdescription='"&safe(data(3,0))&"',listtitle='"&safe(data(4,0))&"' where listid="&listid&";"
		else
			conn.execute "insert into king__link_list ("&sql&",listorder) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"',"&king.neworder("king__link_list","listorder")&")"
		end if
		Il "<script>confirm('"&htm2js(kc.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=edtlist'""):eval(""parent.location='"&re&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_updown()
	king.head king.path,0
	dim kid,listid
	kid=quest("kid",2)
	listid=quest("listid",2)

	if len(kid)>0 then
		king.updown "king__link_page,kid,korder",kid,"listid="&listid
	else
		king.updown "king__link_list,listid,listorder",listid,0
	end if
end sub

%>