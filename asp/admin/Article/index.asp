<!--#include file="../system/plugin.asp"-->
<%
dim art
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set art=new article
	select case action
	case"" king_def
	case"art" king_art
	case"edt" king_edt
	case"openlist" king_openlist
	case"edtlist" king_edtlist
	case"set","setlist" king_set
	case"create" king_create
	case"creates" king_creates
	case"up","down" king_updown
	case"group" king_group
	case"edtgroup" king_edtgroup
	case"setgroup" king_setgroup
	case"tree" Il king_tree(0,0)
	case"search" king_search
	end select
set art=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_search()
	king.head king.path,art.lang("common/search")
	dim rs,data,i,dp,listid'lpath:linkpath
	dim but,sql,ispath,lpath,listpath
	dim lists,insql
	dim query,tquery,space,selected

	tquery=quest("query",4)

	space=quest("space",2)
	if len(space)=0 then space=0
	select case cstr(space)
	case"1"
		query=king.likey("artdescription",tquery)
	case"2"
		query=king.likey("artauthor",tquery)
	case else
		query=king.likey("arttitle",tquery)
	end select

	sql="artid,arttitle,artpath,arthit,artshow,artup,artcommend,arthead,artimg,artgrade,listid"'10

	if len(query)=0 then query=" artid=0 "

	sql="select "&sql&" from kingart where "&query&" order by artdate desc;"

	art.list

	Il "<form class=""k_form"" action=""index.asp"" name=""form_search""  method=""get"" >"
	Il "<p class=""c""><span>"&art.lang("common/search")&"</span>：<input type=""text"" name=""query"" value="""&formencode(quest("query",0))&""" class=""in3"" maxlength=""100"" /> "
	Il "<select name=""space"">"
	if cstr(space)="0" then selected=" selected=""selected""" else selected=""
	Il "<option value=""0"""&selected&">"&art.lang("label/sel/title")&"</option>"
	if cstr(space)="2" then selected=" selected=""selected""" else selected=""
	Il "<option value=""2"""&selected&">"&art.lang("label/sel/author")&"</option>"
	if cstr(space)="1" then selected=" selected=""selected""" else selected=""
	Il "<option value=""1"""&selected&">"&art.lang("label/sel/content")&"</option>"
	Il "</select> "
	Il "<input type=""submit"" value="""&king.lang("common/search")&""" class=""k_button"" />"
	Il "<input type=""hidden"" name=""action"" value=""search"" />"
	Il "</p></form>"

	set dp=new record
'		out sql
		dp.create sql
		dp.purl="index.asp?action=search&pid=$&rn="&dp.rn&"&query="&quest("query",0)&"&space="&space
		dp.but=dp.sect("create:"&encode(king.lang("common/create"))&"|-|moveto:"&art.lang("common/moveto"))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&listid='+K[10]+'&artid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a> '+showimg(K[8])"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[4],'show')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[5],'up')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[6],'commend')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[7],'head')+'</i>'"
		dp.js="'<i>'+isexist(K[2],K[3],K[0])+'</i>'"
		dp.js="K[9]"
		dp.js="edit('index.asp?action=edt&listid='+K[10]+'&artid='+K[0])"

		Il dp.open

		Il "<tr><th>"&art.lang("list/id")&") "&art.lang("list/title")&"</th><th class=""c"">"&art.lang("label/show")&"</th><th class=""c"">"&art.lang("label/up")&"</th><th class=""c"">"&art.lang("label/commend")&"</th><th class=""c"">"&art.lang("label/head")&"</th><th class=""c"">"&art.lang("list/file")&"</th><th>"&art.lang("list/grade")&"</th><th class=""w2"">"&art.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			if cstr(listid)<>cstr(dp.data(10,i)) then
				listid=dp.data(10,i)
				set rs=conn.execute("select listpath from kingart_list where listid="&listid&";")
					if not rs.eof and not rs.bof then
						listpath=rs(0)
					else
						king.error king.lang("error/invalid")
					end if
					rs.close
				set rs=nothing
			end if

			lists=split(dp.data(2,i),"/")

			ispath=king.isexist("../../"&listpath&"/"&dp.data(2,i))

			if ispath then
				if dp.data(9,i)=0 then'若为静态
					if king.isfile(dp.data(2,i)) then'file
						lpath=king_system&"system/link.asp?url="&king.inst&listpath&"/"&dp.data(2,i)
					else
						lpath=king_system&"system/link.asp?url="&king.inst&listpath&"/"&dp.data(2,i)&"/"
					end if
				else
					lpath=king_system&"system/link.asp?url="&king.page&"article/page.asp?artid="&dp.data(0,i)
				end if
			else
				lpath="index.asp?action=create&artid="&dp.data(0,i)
			end if

			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&ispath&"','"&lpath&"',"&dp.data(4,i)&","&dp.data(5,i)&","&dp.data(6,i)&","&dp.data(7,i)&",'"&dp.data(8,i)&"','"&art.getgrade(dp.data(9,i),dp.data(0,i))&"',"&listid&");"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,art.lang("title")

	dim rs,data,i,dp,js'lpath:linkpath
	dim but,sql,listcount,inbut,k4,listid,sublist

	listid=quest("listid",2)
	if len(listid)=0 then listid=0

	art.list
	Il "<div class=""k_form""><div><input type=""button"" value="""&encode(art.lang("common/createlist"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createlist&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createpage"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createpage&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createall"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createall&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createlists"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createlists');""><input type=""button"" value="""&encode(art.lang("common/createpages"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createpages');""><input type=""button"" value="""&encode(art.lang("common/createalls"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createalls');""></div></div>"

	sql="select listid,listname,listpath from kingart_list where listid1="&listid&" order by listorder desc,listid desc;"

	if len(king.mapname)>0 then inbut="|-|createmap:"&encode(art.lang("common/createmap"))

	set dp=new record
		dp.action="index.asp?action=setlist"
		dp.purl="index.asp?pid=$&rn="&dp.rn&"&listid="&listid 'E1126
		dp.create sql
		dp.but=dp.sect("createall:"&encode(art.lang("common/createall"))&"|createlist:"&encode(art.lang("common/createlist"))&"|createpage:"&encode(art.lang("common/createpage"))&"|-|createnotfile:"&encode(art.lang("common/createnotfile"))&inbut&"|-|union:"&encode(art.lang("common/union")))&dp.prn & dp.plist
		js="'<td>'+cklist(K[0])+K[4]+'<a href=""index.asp?action=art&listid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a></td>'"
		js=js&"+'<td>'+K[3]+'</td>'"
		js=js&"+'<td><a href="""&king_system&"system/link.asp?url='+K[2]+'/"" target=""_blank""><img src=""../system/images/os/brow.gif""/>'+K[2]+'</a></td>'"
		js=js&"+'<td>'+edit('index.asp?action=edtlist&listid='+K[0])+updown('index.asp?listid='+K[0],'index.asp')+'</td>'"

		Il dp.open
		Il "<tr><th>"&art.lang("list/id")&") "&art.lang("list/listname")&"</th><th>"&art.lang("list/count")&"</th><th>"&art.lang("list/path")&"</th><th class=""w2"">"&art.lang("list/manage")&"</th></tr>"
		Il "<script>"
		Il "function ll(){var K=ll.arguments;document.write('<tbody id=""tr_'+K[0]+'""><tr>'+"&js&"+'</tr></tbody>');};var k_delete='"&htm2js(king.lang("confirm/delete"))&"';var k_clear='"&htm2js(king.lang("confirm/clear"))&"';"
		for i=0 to dp.length
			sublist=conn.execute("select count(listid) from kingart_list where listid1="&dp.data(0,i)&";")(0)
			if sublist=0 then
				k4="<img src=""../system/images/os/dir2.gif""/>"
			else
				k4="<a href=""index.asp?listid="&dp.data(0,i)&""" title="""&art.lang("list/sublist")&":"&sublist&" ""><img src=""../system/images/os/dir1.gif""/></a>"
			end if
			listcount=conn.execute("select count(artid) from kingart where listid="&dp.data(0,i)&";")(0)
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
		king.head king.path,art.lang("common/tree")
		art.list
		I1=king_table_s
		I1=I1&"<tr><th>"&art.lang("common/tree")&"</th></tr>"
		I1=I1&"<script>function ll(){var K=ll.arguments;var I1='<tr><td>'+nbsp(K[2])+' <img src=""../system/images/os/dir2.gif""/> <a href=""index.asp?action=art&listid='+K[0]+'"">'+K[1]+'</a></td></tr>';document.write(I1);};"
	end if
	
	for i=1 to l2
		nbsp=nbsp&"&nbsp; &nbsp; "
	next

	set rs=conn.execute("select listid,listname from kingart_list where listid1="&l1&" order by listorder desc,listid")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				I1=I1&"ll("&data(0,i)&",'"&htm2js(data(1,i))&"',"&l2&");"
				if conn.execute("select count(listid) from kingart_list where listid1="&data(0,i)&";")(0)>0 then
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
	king.head king.path,art.lang("common/group")
	dim rs,data,i,listid

	listid=quest("listid",2)

	art.list

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=group"">"
	Il king_table_s
	Il "<tr><th>"&art.lang("list/id")&")"&art.lang("list/group")&"</th><th class=""c"">"&art.lang("list/num")&"</th><th>"&art.lang("list/user")&"</th></tr>"
	Il "<tr><td>0) "&art.lang("list/alluser")&"</td><td><i>1</i></td><td>"&art.lang("list/alluser")&"</td></tr>"
	set rs=conn.execute("select groupid,groupnum,groupname from kingart_group order by groupnum;")
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
		conn.execute "delete from kingart_group where groupid="&groupid&";"
		king.flo art.lang("flo/delgroup"),1
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edtgroup()
	king.head king.path,art.lang("common/group")

	dim rs,data,i,dataform,sql,listid
	dim groupid,checknum,isnum

	listid=quest("listid",2):if len(listid)=0 then listid=form("listid")

	groupid=quest("groupid",2)
	if len(groupid)=0 then groupid=form("groupid")
	if len(form("groupid"))>0 then'若表单有值的情况下
		if validate(groupid,2)=false then king.error king.lang("error/invalid")
	end if

	art.list

	sql="groupnum,groupname,groupuser"

	if king.ismethod or len(groupid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if king.ismethod=false then
			if conn.execute("select count(groupid) from kingart_group;")(0)>0 then
				data(0,0)=conn.execute("select max(groupnum) from kingart_group;")(0)+1
			else
				data(0,0)=2
			end if
		end if
	else
		set rs=conn.execute("select "&sql&" from kingart_group where groupid="&groupid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edtgroup"">"
	Il "<p><label>"&art.lang("label/num")&"</label><input type=""text"" name=""groupnum"" class=""in1"" value="""&data(0,0)&""" maxlength=""3"" />"
	isnum=false
	if validate(form("groupnum"),2) then
		if cdbl(form("groupnum"))>1 then isnum=true
	end if
	if len(groupid)>0 then
		checknum="groupnum|6|"&encode(art.lang("check/num"))&"|1-5;groupnum|9|"&encode(art.lang("check/num1"))&"|select count(groupid) from kingart_group where groupnum=$pro$ and groupid<>"&groupid&";groupnum|2|"&encode(art.lang("check/num2"))&";"&isnum&"|13|"&encode(art.lang("check/num3"))
	else
		checknum="groupnum|6|"&encode(art.lang("check/num"))&"|1-5;groupnum|9|"&encode(art.lang("check/num1"))&"|select count(groupid) from kingart_group where groupnum=$pro$;groupnum|2|"&encode(art.lang("check/num2"))&";"&isnum&"|13|"&encode(art.lang("check/num3"))
	end if
	Il king.check(checknum)
	Il "</p>"
	king.form_input "groupname",art.lang("label/groupname"),data(1,0),"groupname|6|"&encode(art.lang("check/groupname"))&"|1-50"
	Il "<p><label>"&art.lang("label/groupuser")&"</label><textarea name=""groupuser"" class=""in5"" rows=""25"" cols=""70"">"&formencode(data(2,0))&"</textarea>"
	king.form_but "save"
	king.form_hidden "groupid",groupid
	king.form_hidden "listid",listid

	Il "</form>"
	if king.ischeck and king.ismethod then
		if len(groupid)>0 then
			conn.execute "update kingart_group set groupnum="&data(0,0)&",groupname='"&safe(data(1,0))&"',groupuser='"&safe(data(2,0))&"' where groupid="&groupid
		else
			conn.execute "insert into kingart_group ("&sql&") values ("&data(0,0)&",'"&safe(data(1,0))&"','"&safe(data(2,0))&"')"
		end if
		Il "<script>confirm('"&htm2js(art.lang("alert/saveokgroup"))&"')?eval(""parent.location='index.asp?action=edtgroup&listid="&listid&"'""):eval(""parent.location='index.asp?action=group&listid="&listid&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_art()
	king.head king.path,art.lang("title")
	dim rs,data,i,dp,listid'lpath:linkpath
	dim but,sql,ispath,lpath,listpath
	dim lists

	listid=quest("listid",2)
	if len(listid)=0 then king.error art.lang("error/listid")

	set rs=conn.execute("select listpath from kingart_list where listid="&listid&";")
		if not rs.eof and not rs.bof then
			listpath=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	art.list
	Il "<div class=""k_form""><div><input type=""button"" value="""&encode(king.lang("common/create"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=create&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createlist"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createlist&list="&listid&"');""><input type=""button"" value="""&encode(art.lang("common/createpage"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createpage&list="&listid&"');""><input type=""button"" value="""&encode(art.lang("common/createall"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createall&list="&listid&"');""></div></div>"

	sql="artid,arttitle,artpath,arthit,artshow,artup,artcommend,arthead,artimg,artgrade"'9
	sql="select "&sql&" from kingart where listid="&listid&" order by artorder desc,artid desc;"

	set dp=new record
		dp.create sql
		dp.purl="index.asp?action=art&pid=$&rn="&dp.rn&"&listid="&listid
		dp.value="listid="&listid
		dp.but=dp.sect("create:"&encode(king.lang("common/create"))&"|createlist1:"&encode(art.lang("common/createlist"))&"|-|moveto:"&art.lang("common/moveto")&"|-|show1:"&art.lang("common/show1")&"|up1:"&art.lang("common/up1")&"|commend1:"&art.lang("common/commend1")&"|head1:"&art.lang("common/head1")&"|-|show0:"&art.lang("common/show0")&"|up0:"&art.lang("common/up0")&"|commend0:"&art.lang("common/commend0")&"|head0:"&art.lang("common/head0"))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&listid="&listid&"&artid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a> '+showimg(K[8])"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[4],'show')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[5],'up')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[6],'commend')+'</i>'"
		dp.js="'<i>'+setag('index.asp?action=set',K[0],K[7],'head')+'</i>'"
		dp.js="'<i>'+isexist(K[2],K[3],K[0])+'</i>'"
		dp.js="K[9]"
		dp.js="edit('index.asp?action=edt&listid="&listid&"&artid='+K[0])+updown('index.asp?listid="&listid&"&artid='+K[0],'index.asp?action=art&listid="&listid&"')"

		Il dp.open

		Il "<tr><th>"&art.lang("list/id")&") "&art.lang("list/title")&"</th><th class=""c"">"&art.lang("label/show")&"</th><th class=""c"">"&art.lang("label/up")&"</th><th class=""c"">"&art.lang("label/commend")&"</th><th class=""c"">"&art.lang("label/head")&"</th><th class=""c"">"&art.lang("list/file")&"</th><th>"&art.lang("list/grade")&"</th><th class=""w2"">"&art.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			lists=split(dp.data(2,i),"/")

			ispath=king.isexist("../../"&listpath&"/"&dp.data(2,i))

			if ispath then
				if dp.data(9,i)=0 then'若为静态
					if king.isfile(dp.data(2,i)) then'file
						lpath=king_system&"system/link.asp?url="&king.inst&listpath&"/"&dp.data(2,i)
					else
						lpath=king_system&"system/link.asp?url="&king.inst&listpath&"/"&dp.data(2,i)&"/"
					end if
				else
					lpath=king_system&"system/link.asp?url="&king.page&"article/page.asp?artid="&dp.data(0,i)
				end if
			else
				lpath="index.asp?action=create&artid="&dp.data(0,i)
			end if

			Il "ll("&dp.data(0,i)&",'"&htm2js(htmlencode(dp.data(1,i)))&"','"&ispath&"','"&lpath&"',"&dp.data(4,i)&","&dp.data(5,i)&","&dp.data(6,i)&","&dp.data(7,i)&",'"&dp.data(8,i)&"','"&art.getgrade(dp.data(9,i),dp.data(0,i))&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_create()
	king.nocache
	king.head king.path,0
	dim I1,artid,rs,listpath,lists
	artid=quest("artid",2)
	set rs=conn.execute("select artid,listid,artpath,artgrade from kingart where artid="&artid)
		if not rs.eof and not rs.bof then
			art.createpage artid

			listpath=conn.execute("select listpath from kingart_list where listid="&rs(1))(0)
			if cstr(rs(3))="0" then
				I1="<a href="""&king_system&"system/link.asp?url="&server.urlencode(king.inst&listpath&"/"&rs(2))&""" target=""_blank""><img src=""../system/images/os/brow.gif"" class=""os"" /></a>"
			else
				I1="<a href="""&king_system&"system/link.asp?url="&server.urlencode(king.page&"article/page.asp?artid="&rs(0))&""" target=""_blank""><img src=""../system/images/os/brow.gif"" class=""os"" /></a>"
			end if
		else
			I1="<img src=""../system/images/os/error.gif"" class=""os""/>"
		end if
		rs.close
	set rs=nothing
	king.txt I1
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_creates()

	Server.ScriptTimeOut=86400
	king.nocache
	king.head "0","0"

	dim list,rs,dp,data,i,j,lists
	dim listid,listids,artids,artid,artpath,listpath
	dim nid,ntime,starttime,I1,I2,pct
	starttime=Timer
	ntime=quest("time",0)

	Il "<html><head><meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" /><script type=""text/javascript"" charset=""UTF-8"" src=""../system/images/jquery.js""></script><style type=""text/css"">p{font-size:12px;padding:0px;margin:0px;line-height:14px;width:450px;white-space:nowrap;}</style></head><body></body></html>"

	select case quest("submits",0)
		case"create"
			list=quest("list",0)
			if len(list)>0 then
				artids=split(list,",")
				for i =0 to ubound(artids)
					II "<script>setTimeout(""window.parent.gethtm('index.asp?action=create&artid="&artids(i)&"','isexist_"&artids(i)&"',1);"","&art.time*i&")</script>"
				next
			else
				alert art.lang("flo/select")
			end if

		case"createlist","createlists"
			listid=quest("listid",0)
			if lcase(quest("submits",0))=lcase("createlists") then
				set rs=conn.execute("select listid from kingart_list order by listid;")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if len(listid)>0 then
								listid=listid&","&data(0,i)
							else
								listid=data(0,i)
							end if
						next
					end if
					rs.close
				set rs=nothing
			end if
			if len(listid)=0 then alert art.lang("flo/select") :exit sub
			II "<script>window.parent.progress_show();</script>"
			dim ncount,listpidcount,listpidcounts:listpidcounts=0
			nid=quest("nid",0):if len(nid)=0 then nid=0
			ncount=quest("ncount",0):if len(ncount)=0 then ncount=0
			I1=split(listid,",")
			for i= 0 to ubound(I1)
				listpidcounts=listpidcounts+getlistpidcount(I1(i))
			next
			for i=1 to getlistpidcount(I1(nid))
				pct=int(((fix(ncount)+i)/listpidcounts)*100)
				j=Timer
				art.createlist1 I1(nid),i
				II "<script>window.parent.progress('progress','"&king.lang("progress/createlist")&pct&"%','"&king.lang("progress/usetime")&formattime(ntime+(Timer-starttime))&"','"&pct&"%');$('body').prepend('<p>- ["&I1(nid)&"] ["&(fix(ncount)+i)&"/"&listpidcounts&"] "&king.lang("progress/createtime")&formattime(Timer-j)&"</p>')</script>"
			next
			ncount=ncount+getlistpidcount(I1(nid))
			nid=nid+1
			if nid>ubound(I1) then
				if len(quest("submits2",0))>0 then
					createpause "index.asp?action=creates&submits="&quest("submits2",0)&"&listid="&listid&"&time="&ntime+(Timer-starttime)
				else
					II "<script>window.parent.progress('progress','"&king.lang("progress/ok")&"','"&king.lang("progress/alltime")&formattime(ntime+(Timer-starttime))&"','100%')</script>"
				end if
			else
				if len(quest("submits2",0))>0 then
					createpause "index.asp?action=creates&submits=createlist&submits2="&quest("submits2",0)&"&listid="&listid&"&nid="&nid&"&ncount="&ncount&"&time="&ntime+(Timer-starttime)
				else
					createpause "index.asp?action=creates&submits=createlist&listid="&listid&"&nid="&nid&"&ncount="&ncount&"&time="&ntime+(Timer-starttime)
				end if
		end if

		case "createpage"
			listid=quest("listid",0)
			if len(listid)=0 then alert art.lang("flo/select") :exit sub
			II "<script>window.parent.progress_show();</script>"
			set dp=new record
				dp.rn=quest("rn",2):if len(dp.rn)=0 then dp.rn=30
				dp.create "select artid from kingart where listid in ("&listid&") and artshow=1 order by artid,listid;"
				if dp.length>-1 then
					for i=0 to dp.length
						j=Timer
						art.createpage dp.data(0,i)
						pct=int((fix(dp.rn*(dp.pid-1)+i+1)/dp.count)*100)
						II "<script>window.parent.progress('progress','"&king.lang("progress/createpage")&pct&"%','"&king.lang("progress/usetime")&formattime(ntime+(Timer-starttime))&"','"&pct&"%');$('body').prepend('<p>-  ["&fix(dp.rn*(dp.pid-1)+i+1)&"/"&dp.count&"] "&king.lang("progress/createtime")&formattime(Timer-j)&"</p>')</script>"
					next
				end if
				if cint(dp.pid)<dp.pagecount then
					createpause "index.asp?action=creates&submits=createpage&listid="&listid&"&pid="&(dp.pid+1)&"&rn="&dp.rn&"&time="&ntime+(Timer-starttime)
				else	
					II "<script>window.parent.progress('progress','"&king.lang("progress/ok")&"','"&king.lang("progress/alltime")&formattime(ntime+(Timer-starttime))&"','100%')</script>"
				end if 
			set dp=nothing

		case"createpages"
			II "<script>window.parent.progress_show();</script>"
			set dp=new record
				dp.create "select artid from kingart where artshow=1 order by artid,listid;"
				for i=0 to dp.length
						j=Timer
						art.createpage dp.data(0,i)
						pct=int((fix(dp.rn*(dp.pid-1)+i+1)/dp.count)*100)
						II "<script>window.parent.progress('progress','"&king.lang("progress/createpage")&pct&"%','"&king.lang("progress/usetime")&formattime(ntime+(Timer-starttime))&"','"&pct&"%');$('body').prepend('<p>-  ["&fix(dp.rn*(dp.pid-1)+i+1)&"/"&dp.count&"] "&king.lang("progress/createtime")&formattime(Timer-j)&"</p>')</script>"
				next
				if cint(dp.pid)<dp.pagecount then
					createpause "index.asp?action=creates&submits=createpages&pid="&(dp.pid+1)&"&rn="&dp.rn&"&time="&ntime+(Timer-starttime)
				else	
					II "<script>window.parent.progress('progress','"&king.lang("progress/ok")&"','"&king.lang("progress/alltime")&formattime(ntime+(Timer-starttime))&"','100%')</script>"
				end if 
			set dp=nothing

		case"createnotfile"
			listid=quest("listid",0)
			artid=quest("artid",0)
			if len(listid)>0 then
				II "<script>window.parent.progress_show();</script>"
				if len(artid)=0 then
					set dp=new record
						dp.create "select artid,artpath,listid from kingart where listid in ("&listid&");"
						for i=0 to dp.length
							if cstr(dp.data(2,i))<>cstr(listid) then
								listpath=conn.execute("select listpath from kingart_list where listid="&dp.data(2,i)&";")(0)
							end if
							if king.isfile(dp.data(1,i)) then
								artpath="../../"&listpath&"/"&dp.data(1,i)
							else
								artpath="../../"&listpath&"/"&dp.data(1,i)&"/"&king_ext
							end if
							if king.isexist(artpath)=false then
								if len(artid)>0 then
									artid=artid&","&dp.data(0,i)
								else
									artid=dp.data(0,i)
								end if
							end if
						next
					set dp=nothing
				end if
				if len(artid)>0 then
					set dp=new record
						dp.create "select artid from kingart where artid in ("&artid&") and artshow=1 order by artid,listid;"
						for i=0 to dp.length
							j=Timer
							art.createpage dp.data(0,i)
							pct=int((fix(dp.rn*(dp.pid-1)+i+1)/dp.count)*100)
							II "<script>window.parent.progress('progress','"&king.lang("progress/createpage")&pct&"%','"&king.lang("progress/usetime")&formattime(ntime+(Timer-starttime))&"','"&pct&"%');$('body').prepend('<p>-  ["&fix(dp.rn*(dp.pid-1)+i+1)&"/"&dp.count&"] "&king.lang("progress/createtime")&formattime(Timer-j)&"</p>')</script>"
						next
					if cint(dp.pid)<dp.pagecount then
						createpause "index.asp?action=creates&submits=createnotfile&listid="&list&"&artid="&artid&"&pid="&(dp.pid+1)&"&rn="&dp.rn&"&time="&ntime+(Timer-starttime)
					else	
						II "<script>window.parent.progress('progress','"&king.lang("progress/ok")&"','"&king.lang("progress/alltime")&formattime(ntime+(Timer-starttime))&"','100%')</script>"
					end if
					set dp=nothing
				else
					II "<script>window.parent.progress('progress','"&king.lang("progress/ok")&"','"&king.lang("progress/alltime")&formattime(ntime+(Timer-starttime))&"','100%')</script>"
				end if
			else
				alert art.lang("flo/select") :exit sub
			end if

	end select

	king.txt ""

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function getlistpidcount(l1)
	dim tmphtm,tmphtmlist,jsorder,jsnumber
	dim rs,sql,i,data,datalist,pidcount'pidcount 总页数
	if len(l1)=0 then exit function
	pidcount=0
	sql="listid,listtemplate1,listtemplate2"'2 datalist
	set rs=conn.execute("select "&sql&" from kingart_list where listid ="&l1&";")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing
	'分析模板及标签，并获得值
	tmphtm=king.read(datalist(1,0),art.path&"[list]/"&datalist(2,0))'内外部模板结合后的htm代码
	tmphtmlist=king.getlist(tmphtm,"article",1)'type="list"部分的tag，包括{king:/}
	jsorder=king.getlabel(tmphtmlist,"order")
	if lcase(jsorder)="asc" then jsorder="asc" else jsorder="desc"
	jsnumber=fix(king.getlabel(tmphtmlist,"number"))
	set rs=conn.execute("select artid from kingart where artshow=1 and listid="&datalist(0,0)&" or listids like '%,"&datalist(0,0)&",%' order by artup desc,artorder "&jsorder&",artid "&jsorder&";")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			'初始化变量值
			pidcount=(ubound(data,2)+1)/jsnumber:if pidcount>int(pidcount) then pidcount=int(pidcount)+1'总页数
		end if
		rs.close
	set rs=nothing
	if pidcount=0 then pidcount=1
	getlistpidcount=pidcount
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	Server.ScriptTimeOut=86400
	king.nocache
	king.head king.path,0
	dim list,rs,data,i,j,lists
	dim listpath,listid,ol,listids,artids,artid
	dim newlist
	dim ksubmit,kis
	dim artpath,cid,pct,s
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
		conn.execute "update kingart set art"&form("submits")&"="&tag&" where artid="&id&";"
		king.txt "<img onclick=""javascript:posthtm('"&url&"','tag_"&form("submits")&id&"','submits="&form("submits")&"&url="&server.urlencode(url)&"&id="&id&"&tag="&tag&"');"" src=""../system/images/os/tag"&tag&".gif""/>"
	case"show0","show1","up0","up1","commend1","commend0","head0","head1"
		if len(list)>0 then
			ksubmit=left(form("submits"),len(form("submits"))-1)
			kis=right(form("submits"),1)
			conn.execute "update kingart set art"&ksubmit&"="&kis&" where artid in ("&list&");"
			king.flo art.lang("flo/"&form("submits")),1
		else
			king.flo art.lang("flo/select"),0
		end if
	case"search" 
		king.ol="<form class=""k_form"" action=""index.asp""  method=""get"" >"
		king.ol="<p><label>"&art.lang("label/key")&"</label><input type=""text"" name=""query"" class=""in3"" maxlength=""100"" /> "
		king.ol="<select name=""space"">"
		king.ol="<option value=""0"">"&art.lang("label/sel/title")&"</option>"
		king.ol="<option value=""2"">"&art.lang("label/sel/author")&"</option>"
		king.ol="<option value=""1"">"&art.lang("label/sel/content")&"</option>"
		king.ol="</select>"
		king.ol="</p>"
		king.ol="<div class=""k_but""><input type=""submit"" value="""&king.lang("common/search")&""" />"
		king.ol="<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');"" /></div>"
		king.ol="<input type=""hidden"" name=""action"" value=""search"" />"
		king.ol="</form>"
		king.flo king.writeol,2
	case"create"'生成
		king.progress "index.asp?action=creates&submits=create&list="&list
	case"createall"'生成列表及文章
		king.progress "index.asp?action=creates&submits=createlist&submits2=createpage&listid="&list
	case"createlist"'只生成文章列表
		king.progress "index.asp?action=creates&submits=createlist&listid="&list
	case"createpage"'只生成文章
		king.progress "index.asp?action=creates&submits=createpage&listid="&list
	case"createnotfile"'生成未生成文章
		king.progress "index.asp?action=creates&submits=createnotfile&listid="&list
	case"createalls"'生成所有列表及文章
		king.progress "index.asp?action=creates&submits=createlists&submits2=createpages"
	case"createlists"'生成所有文章列表
		king.progress "index.asp?action=creates&submits=createlists"
	case"createpages"'生成所有文章
		king.progress "index.asp?action=creates&submits=createpages"
	case"createmap"
		art.createmap
		king.createmap
		king.flo art.lang("flo/createmap")&" <a href=""../../"&art.path&".xml"" target=""_blank"">["&king.lang("common/brow")&"]</a>",0
	case"union"
		if len(list)>0 then
			newlist=form("newlist")
			if len(newlist)=0 then
				ol="<div id=""main"">"
				ol=ol&"<p><label>"&art.lang("label/newlist")&"</label>"
				ol=ol&"<select name=""newlist"" id=""king_newlist"">"
				set rs=conn.execute("select listid,listname from kingart_list where listid in ("&list&") order by listorder desc")
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

				ol=ol&"<div class=""k_menu""><input type=""button"" value="""&art.lang("list/move")&""" "
				ol=ol&"onclick=""javascript:posthtm('index.asp?action=set','flo','submits=union&newlist='+encodeURIComponent(document.getElementById('king_newlist').value)+'&list="&list&"');"" />"
				ol=ol&"<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');""/>"
				ol=ol&"</div>"'end k_but

				ol=ol&"</div>"'end k_form
				king.flo ol,2
				
			else
				'删除原数据
				set rs=conn.execute("select listid,listpath from kingart_list where listid in ("&list&") and listid<>"&newlist&";")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							king.deletefolder "../../"&data(1,i)
						next
					end if
					rs.close
				set rs=nothing
				conn.execute "update kingart set listid="&newlist&" where listid in ("&list&");"
				art.createlist list
				king.flo art.lang("flo/unionok"),0
			end if
		else
			king.flo art.lang("flo/select"),0
		end if
	case"moveto"
		if len(list)>0 then
			newlist=form("newlist")
			if len(newlist)=0 then
				ol="<div id=""main"">"
				ol=ol&"<p><label>"&art.lang("label/newlist")&"</label>"
				ol=ol&king__list1(0,0)'name=listid
				ol=ol&"</p>"

				ol=ol&"<div class=""k_menu""><input type=""button"" value="""&art.lang("list/move")&""" "
				ol=ol&"onclick=""javascript:posthtm('index.asp?action=set','flo','submits=moveto&newlist='+encodeURIComponent(document.getElementById('listid').value)+'&list="&list&"');"" />"
				ol=ol&"<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');""/>"
				ol=ol&"</div>"'end k_but

				ol=ol&"</div>"'end k_form
				king.flo ol,2
			else
				'读取删除目录
				set rs=conn.execute("select listid,artid,artpath from kingart where artid in ("&list&")")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if listid<>data(0,i) then
								listpath=conn.execute("select listpath from kingart_list where listid="&data(0,i)&";")(0)
								listid=data(0,i)
							end if
							if king.isfile(data(2,i)) then'文件
								for j=1 to 50
									king.deletefile art.pagepath("../../"&listpath&"/"&data(2,i),j)
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
				conn.execute "update kingart set listid="&newlist&" where artid in ("&list&");"
				'重新生成文章
				art.createpage list
				'生成列表
				art.createlist listids
				king.flo art.lang("flo/moveok"),1
			end if
		else
			king.flo art.lang("flo/select"),0
		end if
	case"delete"
		if len(list)>0 then
			if action="set" then
				set rs=conn.execute("select artid,listid,artpath from kingart where artid in ("&list&");")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if cstr(listid)<>cstr(data(1,i)) then
								listpath=conn.execute("select listpath from kingart_list where listid="&data(1,i)&";")(0)
								listid=data(1,i)
							end if
							if king.isfile(data(2,i)) then'文件
								for j=1 to 50
									king.deletefile art.pagepath("../../"&listpath&"/"&data(2,i),j)
								next
							else
								king.deletefolder "../../"&listpath&"/"&data(2,i)
							end if
						next
						conn.execute "delete from kingart where artid in ("&list&");"
						art.createlist listid
					else
						king.flo art.lang("flo/invalid"),1
					end if
					rs.close
				set rs=nothing
			else'删除list及list下面的文章
				set rs=conn.execute("select listid,listpath from kingart_list where listid in ("&list&");")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if conn.execute("select count(*) from kingart_list where listid1="&data(0,i)&";")(0)>0 then
								king.flo art.lang("flo/notdel"),1
							end if
							king.deletefolder "../../"&data(1,i)
							conn.execute "delete from kingart_list where listid="&data(0,i)&";"
							conn.execute "delete from kingart where listid="&data(0,i)&";"
						next
					else
						king.flo art.lang("flo/invalid"),1
					end if
					rs.close
				set rs=nothing
			end if
			king.flo art.lang("flo/deleteok"),1
		else
			king.flo art.lang("flo/select"),0
		end if
	case"list"
		listid=form("listid")
		listids=form("listids")
		king.ol="<form name=""form2"" class=""k_form"">"
		king.ol="<p><label>"&art.lang("list/listids")&"</label></p>"
		king.ol=king__lists(0,0,listid,listids)
		king.ol="<div class=""k_menu"">"
		king.ol="<input type=""button"" value="""&king.lang("common/submit")&""" onclick=""javascript:document.getElementById('listids').value=fgetchecked();document.getElementById('listid').value=rgetchecked();display('aja');"" />"
		king.ol="<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('aja');"" />"
		king.ol="</div>"
		king.ol="</form>"
		king.aja art.lang("common/listids"),king.writeol
	end Select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	king.head king.path,art.lang("title")

	dim rs,data,dataform,sql,i,artid,listid,artfrom,artauthor
	dim artdescription,artkeywords,checkpath,checktitle
	dim maxartid,datalist,checked,artgrade,idata
	dim pagelistnumber,replacekeywords,replaceurl
	dim artimg,imgpath
	dim re:re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="index.asp?action=art&listid="&listid


	pagelistnumber=2000
	sql="arttitle,artcontent,artfrom,artauthor,artup,artshow,artcommend,arthead,artgrade,artkeywords,artdescription,artpath,artimg,listids,artdate"'14
	artid=quest("artid",2)
	if len(artid)=0 then artid=form("artid")
	if len(form("artid"))>0 then'若表单有值的情况下
		if validate(artid,2)=false then king.error king.lang("error/invalid")
	end if

	listid=quest("listid",2)
	if len(listid)=0 then listid=form("listid")
	if len(form("listid"))>0 then
		if validate(listid,2)=false then king.error king.lang("error/invalid")
	end if

	if len(listid)>0 then
		set rs=conn.execute("select artfrom,artauthor from kingart_list where listid="&listid)
			if not rs.eof and not rs.bof then
				artfrom=rs(0)
				artauthor=rs(1)
			end if
			rs.close
		set rs=nothing
	end If

	if king.ismethod or len(artid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if king.ismethod then
			pagelistnumber=form("pagelistnumber")
			replaceurl=form("replaceurl")
		else
			data(5,0)=1
			data(11,0)=art.lang("common/pinyin")
		end if

	else
		set rs=conn.execute("select "&sql&" from kingart where artid="&artid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	art.list
	Il "<script>"
	Il "function fgetchecked(){var strcheck;strcheck="""";"
	Il "if (document.form2.list!=undefined){for(var i=0;i<document.form2.list.length;i++){if(document.form2.list[i].checked){"
	Il "if (strcheck==""""){strcheck=document.form2.list[i].value;}"
	Il "else{strcheck=strcheck+','+document.form2.list[i].value;}}}"
	Il "if (document.form2.list.length==undefined){if (document.form2.list.checked==true)"
	Il "{strcheck=document.form2.list.value;}}}return strcheck;}"
	Il "function rgetchecked(){var strcheck;strcheck="""";"
	Il "if (document.form2.f_listid!=undefined){for(var i=0;i<document.form2.f_listid.length;i++){if(document.form2.f_listid[i].checked){"
	Il "if (strcheck==""""){strcheck=document.form2.f_listid[i].value;}"
	Il "else{strcheck=strcheck+','+document.form2.f_listid[i].value;}}}"
	Il "if (document.form2.f_listid.length==undefined){if (document.form2.f_listid.checked==true)"
	Il "{strcheck=document.form2.f_listid.value;}}}return strcheck;}"
	Il "</script>"

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"

	if conn.execute("select count(listid) from kingart_list;")(0)=0 then
		king.error  art.lang("error/notlist")
	end if

	'artinfo
	Il "<p>"
	Il "<label>"&art.lang("label/artinfo")&"</label><span>"
	Il "<a href=""javascript:;"" onclick=""javascript:posthtm('index.asp?action=set','aja','submits=list&listid='+document.getElementById('listid').value+'&listids='+document.getElementById('listids').value)"">["&art.lang("label/list")&"]</a> - "
	if cstr(data(5,0))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""artshow"" id=""artshow"""&checked&"><label for=""artshow"">"&art.lang("label/show")&"</label> "
	if cstr(data(6,0))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""artcommend"" id=""artcommend"""&checked&"><label for=""artcommend"">"&art.lang("label/commend")&"</label> "
	if cstr(data(4,0))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""artup"" id=""artup"""&checked&"><label for=""artup"">"&art.lang("label/up")&"</label> "
	if cstr(data(7,0))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""arthead"" id=""arthead"""&checked&"><label for=""arthead"">"&art.lang("label/head")&"</label> "
	Il " - "
	if cstr(form("snapimg"))="1" or cstr(form("snapimg"))="" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""snapimg"" id=""snapimg"""&checked&"><label for=""snapimg"">"&art.lang("label/snapimg")&"</label> "
	if cstr(form("uplist"))="1" then checked=" checked=""checked""" else checked="" ' or cstr(form("uplist"))=""
	Il "<input type=""checkbox"" value=""1"" name=""uplist"" id=""uplist"""&checked&"><label for=""uplist"">"&art.lang("label/uplist")&"</label> "
	if cstr(form("createhome"))="1" or cstr(form("createhome"))="" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""createhome"" id=""createhome"""&checked&"><label for=""createhome"">"&king.lang("common/createhome")&"</label> "
	if cstr(form("checktitle"))="1" or cstr(form("checktitle"))="" then checked=" checked=""checked""" else checked=""
	Il " <input type=""checkbox"" value=""1"" name=""checktitle"" id=""checktitle"""&checked&"><label for=""checktitle"">"&art.lang("label/checktitle")&"</label>"
	Il "</span></p>"
	'arttitle
	'需要检查标题是否重复
	if cstr(form("checktitle"))="1" then
		if len(artid)>0 then
			checktitle="arttitle|6|"&encode(art.lang("check/title"))&"|1-100;arttitle|9|"&encode(art.lang("check/title1"))&"|select count(artid) from kingart where listid="&listid&" and arttitle='$pro$' and artid<>"&artid
		else
			checktitle="arttitle|6|"&encode(art.lang("check/title"))&"|1-100;arttitle|9|"&encode(art.lang("check/title1"))&"|select count(artid) from kingart where listid="&listid&" and arttitle='$pro$'"
		end if
	else
		checktitle="arttitle|6|"&encode(art.lang("check/title"))&"|1-100"
	end if
	king.form_input "arttitle",art.lang("label/title"),data(0,0),checktitle'article
	'artfrom
	Il "<p><label>"&art.lang("label/from")&"</label><input maxlength=""100"" type=""text"" name=""artfrom"" id=""artfrom"" value="""&formencode(data(2,0))&""" class=""in3"" />"
	Il king.form_eval("artfrom",art.lang("label/from1/originality"))
	Il king.form_eval("artfrom",art.lang("label/from1/net"))
	if len(artfrom)>0 then
		Il king.form_eval("artfrom",artfrom)
	end if
	Il king.check("artfrom|6|"&encode(art.lang("check/from"))&"|1-100")&"</p>"
	'artauthor
	Il "<p><label>"&art.lang("label/author")&"</label><input maxlength=""100"" type=""text"" name=""artauthor"" id=""artauthor"" value="""&formencode(data(3,0))&""" class=""in3"" />"
	Il king.form_eval("artauthor",art.lang("label/authornone"))
	Il king.form_eval("artauthor",king.name)
	if len(artauthor)>0 then
		Il king.form_eval("artauthor",artauthor)
	end if
	Il king.check("artauthor|6|"&encode(art.lang("check/author"))&"|1-100")&"</p>"
	'artimg
	Il "<p><label>"&art.lang("label/img")&"</label><input maxlength=""255"" type=""text"" name=""artimg"" id=""artimg"" value="""&formencode(data(12,0))&""" class=""in4"" />"
	king.form_brow "artimg",king_imgtype
	Il "<input type=""checkbox"" value=""1"" name=""setimg"" id=""setimg"">"
	Il "<span><label for=""setimg"">"&art.lang("label/setimg")&"</label></span>"
	Il king.check("artimg|6|"&encode(art.lang("check/img"))&"|0-255")
	Il "</p>"
	'artpath
	if len(artid)>0 then'更新
		checkpath="artpath|6|"&encode(art.lang("check/path"))&"|1-255;artpath|15|"&encode(art.lang("check/path1"))&";artpath|9|"&encode(art.lang("check/path2"))&"|select count(artid) from kingart where listid="&listid&" and artpath='$pro$' and artid<>"&artid
	else
		checkpath="artpath|6|"&encode(art.lang("check/path"))&"|1-255;artpath|15|"&encode(art.lang("check/path1"))&";artpath|9|"&encode(art.lang("check/path2"))&"|select count(artid) from kingart where listid="&listid&" and artpath='$pro$'"
	end if
	Il "<p><label>"&art.lang("label/path")&"</label><input maxlength=""255"" type=""text"" name=""artpath"" id=""artpath"" value="""&formencode(data(11,0))&""" class=""in4"" />"
	if len(artid)=0 then
		maxartid=king.neworder("kingart","artid")
		Il king.form_eval("artpath",maxartid&"."&split(king_ext,".")(1))
		Il king.form_eval("artpath",formatdate(now,2)&"/"&maxartid)
	end if
	Il " <a href=""javascript:;"" onclick=""javascript:document.getElementById('artpath').value=document.getElementById('arttitle').value"">["&art.lang("common/accord")&"]</a>"
	Il king.form_eval("artpath",art.lang("common/pinyin"))
		Il king.form_eval("artpath","MD5")
	Il king.check(checkpath)
	Il "</p>"
	'artdate
	Il "<p><label>"&art.lang("label/artdate")&" <i>{king:artdate/}</i></label><input maxlength="""" type=""text"" name=""artdate"" id=""artdate"" value="""&formencode(data(14,0))&""" class=""in3"" />"
	Il king.check("")
	Il king.form_eval("artdate",formatdate(now(),0))
	Il "</p>"
	'artcontent
	Il king.form_editor("artcontent",art.lang("label/content"),data(1,0),"artcontent|0|"&encode(art.lang("check/content")))
	'分页
	Il "<p><label>"&art.lang("label/pagelist")&"</label>"
	Il "<input type=""text"" name=""pagelistnumber"" value="""&pagelistnumber&""" maxlength=""10"" class=""in1"" /> "
	if cstr(form("pagelist"))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""pagelist"" id=""pagelist"""&checked&"><span><label for=""pagelist"">"&art.lang("label/pagelistok")&"</label></span>"
	Il king.check("pagelistnumber|2|"&encode(art.lang("check/pagelistnumber")))
	Il "</p>"
	'自动替换关键字链接
	Il "<p><label>自动替换关键字链接</label>"
	if len(replaceurl)=0 then replaceurl="/page/article/tag.asp?query="
	Il "<input type=""text"" name=""replaceurl"" id=""replaceurl"" value="""&replaceurl&""" maxlength=""255"" class=""in4"" /><span><label for=""replaceurl"">关键字链接</label></span>"
	if cstr(form("replacekeywords"))="1" then checked=" checked=""checked""" else checked=""
	Il "<input type=""checkbox"" value=""1"" name=""replacekeywords"" id=""replacekeywords"""&checked&"><span><label for=""replacekeywords"">自动替换</label></span>"
	Il "</p>"
	'artgrade
	set rs=conn.execute("select groupnum,groupname from kingart_group order by groupnum")
		if not rs.eof and not rs.bof then
			idata=rs.getrows()
			for i=0 to ubound(idata,2)
				artgrade=artgrade&"|"&idata(0,i)&":"&encode(htmlencode(idata(1,i)))
			next
		end if
		rs.close
	set rs=nothing
	king.form_select "artgrade",art.lang("label/grade/title"),"0:"&encode(art.lang("label/grade/g0"))&"|1:"&encode(art.lang("label/grade/g1"))&artgrade,data(8,0)
	'0直接生成html 1:限会员访问 4:限vip访问 
	'artkeyword
	king.form_input "artkeywords",art.lang("label/keyword"),data(9,0),"artkeywords|6|"&encode(art.lang("check/keyword"))&"|0-100"
	'artdescription
	king.form_area "artdescription",art.lang("label/description"),data(10,0),"artdescription|6|"&encode(art.lang("check/description"))&"|0-255"
	
	king.form_but "save"
	king.form_hidden "artid",artid
	king.form_hidden "listid",listid
	king.form_hidden "listids",data(13,0)
	king.form_hidden "re",re

	Il "</form>"

	if king.ischeck and king.ismethod then
		'artdescription
		if len(data(10,0))>0 then
			artdescription=king.lefte(data(10,0),250)
		else
			artdescription=king.lefte(king.clshtml(data(1,0)),250)
		end if
		'artkeywords
		artkeywords=king.key(data(0,0)&","&artdescription,data(9,0))
		'artcontent
		if cstr(form("snapimg"))="1" then data(1,0)=king.snap(data(1,0))
		if cstr(form("pagelist"))="1" then data(1,0)=king.paging(data(1,0),form("pagelistnumber"))
		if cstr(form("replacekeywords"))="1" then data(1,0)=king.replacekeywords(data(1,0),replaceurl)
		'artdate
		if data(14,0)="" then data(14,0)=formatdate(now(),0)
		'artpath
		if data(11,0)=art.lang("common/pinyin") then'拼音文件名
			data(11,0)=king.pinyin(data(0,0))
			data(11,0)=formatdate(data(14,0),2)&"/"&replace(data(11,0),".","_")
		end if
		if data(11,0)="MD5" then
			if len(artid)>0 then
				data(11,0)=md5(salt(10)&artid,0)
			else
				data(11,0)=md5(salt(10)&king.neworder("kingart","artorder"),0)
			end if
		end if
		'listids
		if len(data(13,0))>0 then
			data(13,0)=","&data(13,0)&","
		end if
		'artimg
		if cstr(form("setimg"))="1"  then
			artimg=king.match(data(1,0),"(<img([^>]*))( src=)([""'])(.*?)\4(([^>]*)\/?>)")
			if len(artimg)>0 then
				artimg=king.sect(artimg,"(src="")","("")","")
			end if
			if len(artimg)>0 then
				if cstr(form("snapimg"))="1" or validate(artimg,5)=false then
					data(12,0)=artimg'如果已经被抓过图，则直接设置路径
				else'如果没有被抓过图，需要抓图；但考虑到覆盖源图，还是重命名一个图片
					data(12,0)=king.inst&king_upath&"/image/"&art.path&"/"&formatdate(date(),2)&"/"&int(timer()*100)&"."&king.extension(artimg)
					king.createfolder data(12,0)
					king.remote2local artimg,data(12,0)
				end if
			end if
		else
			if validate(data(12,0),7) and validate(data(12,0),5) then'如果是图片路径
				artimg=data(12,0)
				data(12,0)=king.inst&king_upath&"/image/"&art.path&"/"&formatdate(date(),2)&"/"&int(timer()*100)&"."&king.extension(data(12,0))
				king.createfolder data(12,0)
				king.remote2local artimg,data(12,0)
			end if
		end if

		if cstr(data(4,0))<>"1" then data(4,0)=0'up
		if cstr(data(5,0))<>"1" then data(5,0)=0'show
		if cstr(data(6,0))<>"1" then data(6,0)=0'commend
		if cstr(data(7,0))<>"1" then data(7,0)=0'head
		'Insert Update
		if len(artid)>0 then
			conn.execute "update kingart set arttitle='"&safe(data(0,0))&"',artcontent='"&safe(data(1,0))&"',artfrom='"&safe(data(2,0))&"',artauthor='"&safe(data(3,0))&"',artup="&safe(data(4,0))&",artshow="&safe(data(5,0))&",artcommend="&safe(data(6,0))&",arthead="&safe(data(7,0))&",artgrade="&safe(data(8,0))&",artpath='"&safe(data(11,0))&"',artdate='"&safe(data(14,0))&"',artimg='"&safe(data(12,0))&"',listids='"&safe(data(13,0))&"',listid="&listid&",artdescription='"&safe(artdescription)&"',artkeywords='"&safe(artkeywords)&"' where artid="&artid&";"
		else
			conn.execute "insert into kingart ("&sql&",artorder,listid) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"',"&safe(data(4,0))&","&safe(data(5,0))&","&safe(data(6,0))&","&safe(data(7,0))&","&safe(data(8,0))&",'"&safe(artkeywords)&"','"&safe(artdescription)&"','"&safe(data(11,0))&"','"&safe(data(12,0))&"','"&safe(data(13,0))&"','"&safe(data(14,0))&"',"&king.neworder("kingart","artorder")&","&listid&")"
			artid=king.newid("kingart","artid")

			art.createmap
		end if

		'update art_list form
		conn.execute "update kingart_list set lastdate='"&tnow&"' where listid="&listid&";"
		if king.instre(art.lang("label/from1/net")&","&art.lang("label/from1/originality"),data(2,0))=false then
			conn.execute "update kingart_list set artfrom='"&safe(data(2,0))&"' where listid="&listid&";"
		end if
		'update art_list author
		if king.instre(art.lang("label/authornone")&","&king.name,data(3,0))=false then
			conn.execute "update kingart_list set artauthor='"&safe(data(3,0))&"' where listid="&listid&";"
		end if
		'neworder：king.neworder("kingart","artorder")
		art.createpage artid
		'更新并生成rss
		set rs=conn.execute("select listname,listpath from kingart_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				datalist=rs.getrows()
			end if
			rs.close
		set rs=nothing
		king.letrss data(0,0),art.getpath(artid,data(8,0),king.inst&datalist(1,0)&"/"&data(11,0)),artdescription,data(1,0),data(12,0),0,datalist(0,0),data(3,0),data(2,0),tnow
		king.createrss

		if cstr(form("uplist"))="1" then art.createlist listid

		if cstr(form("createhome"))="1" then king.createhome
		
		Il "<script>confirm('"&htm2js(art.lang("alert/saveokart"))&"')?eval(""parent.location='index.asp?action=edt&listid="&listid&"'""):eval(""parent.location='"&re&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king__list(l1,l2,l3,l4)
	dim rs,I1,data,i,nbsp,selected
	dim l5
	if cstr(l1)="0" then
		I1="<select name=""listid1"">"
		I1=I1&"<option value=""0"">"&art.lang("common/root")&"</option>"
	end if
	
	for i=0 to l2
		nbsp=nbsp&"&nbsp; &nbsp; "
	next

	set rs=conn.execute("select listid,listname from kingart_list where listid1="&l1&" order by listorder asc,listid")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				if cstr(l4)<>cstr(data(0,i)) then
					if cstr(l3)=cstr(data(0,i)) then selected=" selected=""selected""" else selected=""
					I1=I1&"<option value="""&data(0,i)&""""&selected&">"&nbsp&formencode(data(1,i))&"</option>"
					if conn.execute("select count(listid) from kingart_list where listid1="&data(0,i)&";")(0)>0 then
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

	set rs=conn.execute("select listid,listname from kingart_list where listid1="&l1&" order by listorder asc,listid")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				I1=I1&"<option value="""&data(0,i)&""">"&nbsp&formencode(data(1,i))&"</option>"
				if conn.execute("select count(listid) from kingart_list where listid1="&data(0,i)&";")(0)>0 then
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

	set rs=conn.execute("select listid,listname from kingart_list where listid1="&l1&" order by listorder asc,listid")
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
				if conn.execute("select count(listid) from kingart_list where listid1="&data(0,i)&";")(0)>0 then
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
	king.head king.path,art.lang("title")

	dim re:re=request.servervariables("http_referer")
	if len(form("re"))>0 then re=form("re"):if len(re)=0 then re="index.asp?action=edtlist"

	dim rs,data,dataform,sql,i,listid,checkpath,checked
	sql="listname,listpath,listtemplate1,listtemplate2,pagetemplate1,pagetemplate2,listid1,listkeyword,listdescription,listtitle,listcontent"'10
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
		set rs=conn.execute("select "&sql&" from kingart_list where listid="&listid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	art.list

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edtlist"">"

	Il "<p><label>"&art.lang("label/suplist")&"</label>"&king__list(0,0,data(6,0),listid)&"</p>"

	king.form_input "listname",art.lang("list/listname"),data(0,0),"listname|6|"&encode(art.lang("check/listname"))&"|1-30"'article
	king.form_input "listtitle",art.lang("label/listtitle"),data(9,0),"listtitle|6|"&encode(art.lang("check/listtitle"))&"|1-100"

	if len(listid)>0 then'更新
		checkpath="listpath|6|"&encode(art.lang("check/path"))&"|1-100;listpath|15|"&encode(art.lang("check/path1"))&";listpath|9|"&encode(art.lang("check/path2"))&"|select count(listid) from kingart_list where listpath='$pro$' and listid<>"&listid
	else
		checkpath="listpath|6|"&encode(art.lang("check/path"))&"|1-100;listpath|15|"&encode(art.lang("check/path1"))&";listpath|9|"&encode(art.lang("check/path2"))&"|select count(listid) from kingart_list where listpath='$pro$'"
	end if
	king.form_input "listpath",art.lang("label/path"),data(1,0),checkpath
	king.form_editor "listcontent",art.lang("label/listcontent"),data(10,0),"listcontent|0|"&encode(art.lang("check/content"))'content
	king.form_input "listkeyword",art.lang("label/listkeyword"),data(7,0),"listkeyword|6|"&encode(art.lang("check/keyword"))&"|0-120"
	king.form_area "listdescription",art.lang("label/listdescription"),data(8,0),"listdescription|6|"&encode(art.lang("check/description"))&"|0-250"

	king.form_tmp "listtemplate1",art.lang("label/listtemplate1"),data(2,0),0
	king.form_tmp "listtemplate2",art.lang("label/listtemplate2"),data(3,0),"article[list]"
	king.form_tmp "pagetemplate1",art.lang("label/pagetemplate1"),data(4,0),0
	king.form_tmp "pagetemplate2",art.lang("label/pagetemplate2"),data(5,0),"article[page]"

	king.form_but "save"
	king.form_hidden "listid",listid
	king.form_hidden "re",re

	Il "</form>"

	if king.ischeck and king.ismethod then
		if len(listid)>0 then
			conn.execute "update kingart_list set listname='"&safe(data(0,0))&"',listpath='"&safe(data(1,0))&"',listtemplate1='"&safe(data(2,0))&"',listtemplate2='"&safe(data(3,0))&"',pagetemplate1='"&safe(data(4,0))&"',pagetemplate2='"&safe(data(5,0))&"',listid1="&safe(data(6,0))&",listkeyword='"&safe(data(7,0))&"',listdescription='"&safe(data(8,0))&"',listtitle='"&safe(data(9,0))&"',listcontent='"&safe(data(10,0))&"' where listid="&listid&";"
		else
			conn.execute "insert into kingart_list ("&sql&",listorder) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&safe(data(5,0))&"',"&safe(data(6,0))&",'"&safe(data(7,0))&"','"&safe(data(8,0))&"','"&safe(data(9,0))&"','"&safe(data(10,0))&"',"&king.neworder("kingart_list","listorder")&")"
		end if
		art.createmap
		Il "<script>confirm('"&htm2js(art.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=edtlist'""):eval(""parent.location='"&re&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_updown()
	king.head king.path,0
	dim artid,listid
	artid=quest("artid",2)
	listid=quest("listid",2)

	if len(artid)>0 then
		king.updown "kingart,artid,artorder",artid,"listid="&listid
	else
		king.updown "kingart_list,listid,listorder",listid,0
	end if
end sub

Sub king_openlist()
	king.head king.path,0

	dim rs,data,i,dp,js'lpath:linkpath
	dim but,sql,listcount,inbut,k4,listid,sublist,tmpstr

	listid=form("listid")

	sql="select listid,listname,listpath from kingart_list where listid1="&listid&" order by listorder desc,listid desc;"

	set dp=new record
		dp.create sql

		for i=0 to dp.length
			sublist=conn.execute("select count(listid) from kingart_list where listid1="&dp.data(0,i)&";")(0)
			if sublist=0 then
				k4="<img src=""../system/images/os/dir2.gif""/>"
			else
				k4="<a href=""javascript:;"" title="""&art.lang("list/sublist")&":"&sublist&""" onclick=""posthtm('index.asp?action=openlist',tr_"&dp.data(0,i)&",listid="&dp.data(0,i)&",0);""><img src=""../system/images/os/dir1.gif"" /></a>"
			end if
			listcount=conn.execute("select count(artid) from kingart where listid="&dp.data(0,i)&";")(0)
			tmpstr=tmpstr&"ll("&dp.data(0,i)&",'"&htm2js(htmlencode(dp.data(1,i)))&"','"&htm2js(king.inst&dp.data(2,i))&"','"&listcount&"','"&htm2js(k4)&"');"
		Next
		king.txt tmpstr
	set dp=nothing
end sub

%>