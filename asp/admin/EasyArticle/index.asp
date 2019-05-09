<!--#include file="../system/plugin.asp"-->
<%
dim art
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set art=new easyarticle
	select case action
	case"" king_def
	case"art" king_art
	case"edt" king_edt
	case"edtlist" king_edtlist
	case"set","setlist" king_set
	case"create" king_create
	case"creates" king_creates
	case"up","down" king_updown
	end select
set art=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,art.lang("title")

	dim rs,data,i,dp'lpath:linkpath
	dim but,sql,listcount,inbut

	art.list
	Il "<div class=""k_form""><div><input type=""button"" value="""&encode(art.lang("common/createlist"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createlist&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createpage"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createpage&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createall"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createall&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createlists"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createlists');""><input type=""button"" value="""&encode(art.lang("common/createpages"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createpages');""><input type=""button"" value="""&encode(art.lang("common/createalls"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createalls');""></div></div>"

	sql="select listid,listname,listpath from kingeasyart_list order by listorder desc,listid desc;"

	if len(king.mapname)>0 then inbut="|-|createmap:"&encode(art.lang("common/createmap"))

	set dp=new record
		dp.action="index.asp?action=setlist"
		dp.create sql
		dp.but=dp.sect("createall:"&encode(art.lang("common/createall"))&"|createlist:"&encode(art.lang("common/createlist"))&"|createpage:"&encode(art.lang("common/createpage"))&"|-|createnotfile:"&encode(art.lang("common/createnotfile"))&inbut&"|-|union:"&encode(art.lang("common/union")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=art&listid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a>'"
		dp.js="K[3]"
		dp.js="'<a href="""&king_system&"system/link.asp?url='+K[2]+'/"" target=""_blank""><img src=""../system/images/os/brow.gif""/>'+K[2]+'</a>'"
		dp.js="edit('index.asp?action=edtlist&listid='+K[0])+updown('index.asp?listid='+K[0])"

		Il dp.open

		Il "<tr><th>"&art.lang("list/id")&") "&art.lang("list/listname")&"</th><th>"&art.lang("list/count")&"</th><th>"&art.lang("list/path")&"</th><th class=""w2"">"&art.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			listcount=conn.execute("select count(artid) from kingeasyart where listid="&dp.data(0,i)&";")(0)
			Il "ll("&dp.data(0,i)&",'"&htm2js(htmlencode(dp.data(1,i)))&"','"&htm2js(king.inst&dp.data(2,i))&"','"&listcount&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

	
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_art()
	king.head king.path,art.lang("title")
	dim rs,data,i,dp,listid'lpath:linkpath
	dim but,sql,ispath,lpath,listpath
	listid=quest("listid",2)
	if len(listid)=0 then king.error art("error/listid")

	set rs=conn.execute("select listpath from kingeasyart_list where listid="&listid&";")
		if not rs.eof and not rs.bof then
			listpath=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	art.list
	Il "<div class=""k_form""><div><input type=""button"" value="""&encode(king.lang("common/create"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=create&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(art.lang("common/createlist"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createlist&list="&listid&"');""><input type=""button"" value="""&encode(art.lang("common/createpage"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createpage&list="&listid&"');""><input type=""button"" value="""&encode(art.lang("common/createall"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=createall&list="&listid&"');""></div></div>"

	sql="select artid,arttitle from kingeasyart where listid="&listid&" order by artorder desc,artid desc;"

	set dp=new record
		dp.create sql
		dp.purl="index.asp?action=art&pid=$&rn="&dp.rn&"&listid="&listid
		dp.but=dp.sect("create:"&encode(king.lang("common/create"))&"|-|moveto:"&art.lang("common/moveto"))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&listid="&listid&"&artid='+K[0]+'"" >'+K[0]+') '+K[1]+'</a>'"
		dp.js="isexist(K[2],K[3],K[0])"
		dp.js="edit('index.asp?action=edt&listid="&listid&"&artid='+K[0])+updown('index.asp?listid="&listid&"&artid='+K[0],'index.asp?action=art&listid="&listid&"')"

		Il dp.open

		Il "<tr><th>"&art.lang("list/id")&") "&art.lang("list/title")&"</th><th>"&art.lang("list/file")&"</th><th class=""w2"">"&art.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length
			ispath=king.isexist("../../"&listpath&"/"&art.initially&dp.data(0,i)&"/"&king_ext)
			if ispath then
				lpath=king_system&"system/link.asp?url="&server.urlencode(king.inst&listpath&"/"&art.initially&dp.data(0,i))
			else
				lpath="index.asp?action=create&artid="&dp.data(0,i)
			end if
			Il "ll("&dp.data(0,i)&",'"&htm2js(htmlencode(dp.data(1,i)))&"','"&ispath&"','"&lpath&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_create()
	king.nocache
	king.head king.path,0
	dim I1,artid,rs,listpath
	artid=quest("artid",2)
	set rs=conn.execute("select artid,listid from kingeasyart where artid="&artid)
		if not rs.eof and not rs.bof then
			art.createpage artid
			listpath=conn.execute("select listpath from kingeasyart_list where listid="&rs(1))(0)
			I1="<a href="""&king_system&"system/link.asp?url="&server.urlencode(king.inst&listpath&"/"&art.initially&rs(0))&""" target=""_blank""><img src=""../system/images/os/brow.gif"" class=""os"" /></a>"
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
					II "<script>setTimeout(""window.parent.gethtm('index.asp?action=create&artid="&artids(i)&"','isexist_"&artids(i)&"',1);"","&(500*i)&")</script>"
				next
			else
				alert art.lang("flo/select")
			end if

		case"createlist","createlists"
			listid=quest("listid",0)
			if lcase(quest("submits",0))=lcase("createlists") then
				set rs=conn.execute("select listid from kingeasyart_list order by listid;")
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
				dp.create "select artid from kingeasyart where listid in ("&listid&") order by artid,listid;"
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
				dp.create "select artid from kingeasyart order by artid,listid;"
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
						dp.create "select artid,listid from kingeasyart where listid in ("&listid&");"
						for i=0 to dp.length
							if cstr(dp.data(1,i))<>cstr(listid) then
								listpath=conn.execute("select listpath from kingeasyart_list where listid="&dp.data(1,i)&";")(0)
							end if
							artpath="../../"&listpath&"/"&art.initially&dp.data(0,i)
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
						dp.create "select artid from kingeasyart where artid in ("&artid&") order by artid,listid;"
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
	set rs=conn.execute("select "&sql&" from kingeasyart_list where listid ="&l1&";")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			redim datalist(0,-1)
		end if
		rs.close
	set rs=nothing
	'分析模板及标签，并获得值
	tmphtm=king.read(datalist(1,0),art.path&"[list]/"&datalist(2,0))'内外部模板结合后的htm代码
	tmphtmlist=king.getlist(tmphtm,"easyarticle",1)'type="list"部分的tag，包括{king:/}
	jsorder=king.getlabel(tmphtmlist,"order")
	if lcase(jsorder)="asc" then jsorder="asc" else jsorder="desc"
	jsnumber=fix(king.getlabel(tmphtmlist,"number"))
	set rs=conn.execute("select artid from kingeasyart where listid="&datalist(0,0)&" order by artorder "&jsorder&",artid "&jsorder&";")
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
	king.nocache
	king.head king.path,0
	dim list,rs,data,i,lists
	dim listpath,listid,ol,listids,artids
	dim newlist
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	'action=set 文章操作，action=setlist 列表操作

	select case form("submits")
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
				set rs=conn.execute("select listid,listname from kingeasyart_list where listid in ("&list&") order by listorder desc")
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
				conn.execute "update kingeasyart set listid="&newlist&" where listid in ("&list&");"
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
				ol=ol&"<select name=""newlist"" id=""king_newlist"">"
				set rs=conn.execute("select listid,listname from kingeasyart_list order by listorder desc")
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
				ol=ol&"onclick=""javascript:posthtm('index.asp?action=set','flo','submits=moveto&newlist='+encodeURIComponent(document.getElementById('king_newlist').value)+'&list="&list&"');"" />"
				ol=ol&"<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');""/>"
				ol=ol&"</div>"'end k_but

				ol=ol&"</div>"'end k_form
				king.flo ol,2
			else
				'读取删除目录
				set rs=conn.execute("select listid,artid from kingeasyart where artid in ("&list&")")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							king.deletefolder "../../"&data(0,i)&"/"&data(1,i)
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
				conn.execute "update kingeasyart set listid="&newlist&" where artid in ("&list&");"
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
				set rs=conn.execute("select artid,listid from kingeasyart where artid in ("&list&");")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							if cstr(listid)<>cstr(data(1,i)) then
								listpath=conn.execute("select listpath from kingeasyart_list where listid="&data(1,i)&";")(0)
							end if
							listid=data(1,i)
							king.deletefolder "../../"&listpath&"/"&art.initially&data(0,i)
						next
						conn.execute "delete from kingeasyart where artid in ("&list&");"
					else
						king.flo art.lang("flo/invalid"),1
					end if
					rs.close
				set rs=nothing
			else'删除list及list下面的文章
				set rs=conn.execute("select listid,listpath from kingeasyart_list where listid in ("&list&");")
					if not rs.eof and not rs.bof then
						data=rs.getrows()
						for i=0 to ubound(data,2)
							king.deletefolder "../../"&data(1,i)
						next
						conn.execute "delete from kingeasyart_list where listid in ("&list&");"
						conn.execute "delete from kingeasyart where listid in ("&list&");"
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

	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	king.head king.path,art.lang("title")

	dim rs,data,dataform,datalist,sql,i,artid,listid,artfrom,listids
	dim artdescription,artkeywords
	sql="arttitle,artcontent,artfrom"
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
		set rs=conn.execute("select artfrom from kingeasyart_list where listid="&listid)
			if not rs.eof and not rs.bof then
				artfrom=rs(0)
			end if
			rs.close
		set rs=nothing
	end if

	if king.ismethod or len(artid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from kingeasyart where artid="&artid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	art.list
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"

	set rs=conn.execute("select listid,listname from kingeasyart_list;")
		if not rs.eof and not rs.bof then
			datalist=rs.getrows()
		else
			king.error  art.lang("error/notlist")
		end if
		rs.close
	set rs=nothing
	for i=0 to ubound(datalist,2)
		listids=listids&encode(datalist(0,i))&":"&encode(datalist(1,i))&"|"
	next
	king.form_select "listid",art.lang("label/list"),listids,listid

	king.form_input "arttitle",art.lang("label/title"),data(0,0),"arttitle|6|"&encode(art.lang("check/title"))&"|1-100"'article

	Il "<p><label>"&art.lang("label/from")&"</label><input type=""text"" id=""artfrom"" value="""&formencode(data(2,0))&""" class=""in3"" />"
	Il king.form_eval("artfrom",art.lang("label/from1/originality"))
	Il king.form_eval("artfrom",art.lang("label/from1/net"))
	if len(artfrom)>0 then
		Il king.form_eval("artfrom",artfrom)
	end if
	Il king.check("artfrom|6|"&encode(art.lang("check/from"))&"|1-100")&"</p>"

	Il king.form_editor("artcontent",art.lang("label/content"),data(1,0),"artcontent|0|"&encode(art.lang("check/content")))
	
	king.form_but "save"
	king.form_hidden "artid",artid

	Il "</form>"

	if king.ischeck and king.ismethod then
		artdescription=left(king.clshtml(data(1,0)),255)
		artkeywords=king.key(data(0,0)&","&artdescription,"")
		if len(artid)>0 then
			conn.execute "update kingeasyart set arttitle='"&safe(data(0,0))&"',artcontent='"&safe(data(1,0))&"',artfrom='"&safe(data(2,0))&"',listid="&listid&",artdescription='"&safe(artdescription)&"',artkeywords='"&safe(artkeywords)&"' where artid="&artid&";"
		else
			conn.execute "insert into kingeasyart ("&sql&",artdate,artorder,listid,artdescription,artkeywords) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&tnow&"',"&king.neworder("kingeasyart","artorder")&","&listid&",'"&safe(artdescription)&"','"&safe(artkeywords)&"')"
			artid=king.newid("kingeasyart","artid")
			conn.execute "update kingeasyart_list set lastdate='"&tnow&"' where listid="&listid&";"
			if king.instre(art.lang("label/form/net")&","&art.lang("label/form/originality"),data(2,0))=false then
				conn.execute "update kingeasyart_list set artfrom='"&safe(data(2,0))&"' where listid="&listid&";"
			end if
			set rs=conn.execute("select listname,listpath from kingeasyart_list where listid="&listid&";")
				if not rs.eof and not rs.bof then
					datalist=rs.getrows()
				end if
				rs.close
			set rs=nothing
			king.letrss data(0,0),king.inst&datalist(1,0)&"/"&art.initially&artid,0,data(1,0),0,0,datalist(0,0),0,data(2,0),tnow
			king.createrss
			art.createmaplist
			art.createmappage listid
		end if
		'neworder：king.neworder("kingeasyart","artorder")
		art.createpage artid
		art.createlist listid
		
		Il "<script>confirm('"&htm2js(art.lang("alert/saveokart"))&"')?eval(""parent.location='index.asp?action=edt&listid="&listid&"'""):eval(""parent.location='index.asp?action=art&listid="&listid&"'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edtlist()
	king.head king.path,art.lang("title")

	dim rs,data,dataform,sql,i,listid,checkpath
	sql="listname,listpath,listtemplate1,listtemplate2,pagetemplate1,pagetemplate2"'5
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
	else
		set rs=conn.execute("select "&sql&" from kingeasyart_list where listid="&listid&";")
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

	king.form_input "listname",art.lang("list/listname"),data(0,0),"listname|6|"&encode(art.lang("check/listname"))&"|1-30"'article

	if len(listid)>0 then'更新
		checkpath="listpath|6|"&encode(art.lang("check/path"))&"|1-100;listpath|15|"&encode(art.lang("check/path1"))&";listpath|9|"&encode(art.lang("check/path2"))&"|select count(listid) from kingeasyart_list where listpath='$pro$' and listid<>"&listid
	else
		checkpath="listpath|6|"&encode(art.lang("check/path"))&"|1-100;listpath|15|"&encode(art.lang("check/path1"))&";listpath|9|"&encode(art.lang("check/path2"))&"|select count(listid) from kingeasyart_list where listpath='$pro$'"
	end if
	king.form_input "listpath",art.lang("label/path"),data(1,0),checkpath

	king.form_tmp "listtemplate1",art.lang("label/listtemplate1"),data(2,0),0
	king.form_tmp "listtemplate2",art.lang("label/listtemplate2"),data(3,0),"easyarticle[list]"
	king.form_tmp "pagetemplate1",art.lang("label/pagetemplate1"),data(4,0),0
	king.form_tmp "pagetemplate2",art.lang("label/pagetemplate2"),data(5,0),"easyarticle[page]"

	king.form_but "save"
	king.form_hidden "listid",listid

	Il "</form>"

	if king.ischeck and king.ismethod then
		if len(listid)>0 then
			conn.execute "update kingeasyart_list set listname='"&safe(data(0,0))&"',listpath='"&safe(data(1,0))&"',listtemplate1='"&safe(data(2,0))&"',listtemplate2='"&safe(data(3,0))&"',pagetemplate1='"&safe(data(4,0))&"',pagetemplate2='"&safe(data(5,0))&"' where listid="&listid&";"
		else
			conn.execute "insert into kingeasyart_list ("&sql&",listorder) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(data(4,0))&"','"&safe(data(5,0))&"',"&king.neworder("kingeasyart_list","listorder")&")"
		end if
		art.createmaplist
		Il "<script>confirm('"&htm2js(art.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=edtlist'""):eval(""parent.location='index.asp'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_updown()
	king.head king.path,0
	dim artid,listid
	artid=quest("artid",2)
	listid=quest("listid",2)

	if len(artid)>0 then
		king.updown "kingeasyart,artid,artorder",artid,"listid="&listid
	else
		king.updown "kingeasyart_list,listid,listorder",listid,0
	end if
end sub

%>