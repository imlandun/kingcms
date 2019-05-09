<!--#include file="../system/plugin.asp"-->
<%
dim one
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set one=new onepage
	select case action
	case"" king_def
	case"edt" king_edt
	case"set" king_set
	case"create" king_create
	case"creates" king_creates
	case"up","down" king_updown
	case"insearch" king_insearch
	end select
set one=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_insearch()
	king.nocache
	king.head king.path,0
	king.txt "<input type=""text"" onkeydown=""if(event.keyCode==13) {window.location='index.asp?query='+encodeURI(this.value); return false;}"" />"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,one.lang("title")
	dim rs,data,i,dp,fpath,lpath,paths,ispath'lpath:linkpath
	dim but,sql,query,inbut

	one.list
	Il "<div class=""k_form""><div><input type=""button"" value="""&encode(king.lang("common/create"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=create&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(king.lang("common/createall"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=creates');""></div></div>"

	query=quest("query",0)
	if len(query)>0 then
		sql="select oneid,onename,onepath from kingonepage where onename like '%"&safe(query)&"%' order by oneorder desc,oneid desc;"
	else
		sql="select oneid,onename,onepath from kingonepage order by oneorder desc,oneid desc;"
	end if

	if len(king.mapname)>0 then inbut="|createmap:"&encode(one.lang("common/createmap"))
	
	set dp=new record
		dp.create sql
		dp.but=dp.sect("create:"&encode(king.lang("common/create"))&inbut)&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&oneid='+K[0]+'"">'+K[0]+') '+K[1]+'</a>'"
		dp.js="isexist(K[3],K[4],K[0])+K[2]"
		dp.js="edit('index.asp?action=edt&oneid='+K[0])+updown('index.asp?oneid='+K[0])"'+updown('index.asp?oneid='+l1)

		Il dp.open

		Il "<tr><th>"&one.lang("list/id")&") "&one.lang("list/name")&"</th><th>"&one.lang("list/path")&"</th><th class=""w2"">"&one.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length

			if len(dp.data(2,i))>0 then
				fpath=dp.data(2,i)
			else
				fpath="["&king_ext&"]"
			end if

			if len(dp.data(2,i))>0 then
				paths=split(dp.data(2,i),"/")
				if instr(paths(ubound(paths)),".")>0 then'文件
					ispath=king.isexist("../../"&dp.data(2,i))
				else
					ispath=king.isexist("../../"&dp.data(2,i)&"/"&king_ext)
				end if
			else
				ispath=king.isexist("../../"&king_ext)
			end if

			if ispath then
				lpath=king_system&"system/link.asp?url="&server.urlencode(king.inst&dp.data(2,i))
			else
				lpath="index.asp?action=create&oneid="&dp.data(0,i)
			end if
			
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"','"&fpath&"','"&ispath&"','"&lpath&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_create()
	king.nocache
	king.head king.path,0
	dim I1,oneid,rs
	oneid=quest("oneid",2)
	set rs=conn.execute("select onepath from kingonepage where oneid="&oneid)
		if not rs.eof and not rs.bof then
			I1="<a href="""&king_system&"system/link.asp?url="&server.urlencode("../../"&rs(0))&""" target=""_blank""><img src=""../system/images/os/brow.gif"" class=""os"" /></a>"
		else
			I1="<img src=""../system/images/os/error.gif"" class=""os""/>"
		end if
		rs.close
	set rs=nothing
	one.create oneid
	king.txt I1
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_creates()

	Server.ScriptTimeOut=86400
	king.nocache
	king.head "0","0"

	dim list,i,oneids,oneid,dp,pct,starttime,j	,ntime
	starttime=Timer
	ntime=quest("time",0)	

	Il "<html><head><meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" /><script type=""text/javascript"" charset=""UTF-8"" src=""../system/images/jquery.js""></script><style type=""text/css"">p{font-size:12px;padding:0px;margin:0px;line-height:14px;width:450px;white-space:nowrap;}</style></head><body></body></html>"

	select case quest("submits",0)
		case"create"
			list=quest("list",0)
			if len(list)>0 then
				oneids=split(list,",")
				for i =0 to ubound(oneids)
					II "<script>setTimeout(""window.parent.gethtm('index.asp?action=create&oneid="&oneids(i)&"','isexist_"&oneids(i)&"',1);"","&(1000*i)&")</script>"
				next
			else
				alert one.lang("flo/select")
			end if

		case"creates"
			II "<script>window.parent.progress_show();</script>"
			set dp=new record
				dp.create "select oneid from kingonepage order by oneid ;"
				for i=0 to dp.length
						j=Timer
						one.create dp.data(0,i)
						pct=int((fix(dp.rn*(dp.pid-1)+i+1)/dp.count)*100)
						II "<script>window.parent.progress('progress','"&king.lang("common/create")&pct&"%','"&king.lang("progress/usetime")&formattime(ntime+(Timer-starttime))&"','"&pct&"%');$('body').prepend('<p>-  ["&fix(dp.rn*(dp.pid-1)+i+1)&"/"&dp.count&"] "&king.lang("progress/createtime")&formattime(Timer-j)&"</p>')</script>"
				next
				if cint(dp.pid)<dp.pagecount then
					createpause "index.asp?action=creates&submits=creates&pid="&(dp.pid+1)&"&rn="&dp.rn&"&time="&ntime+(Timer-starttime)
				else	
					II "<script>window.parent.progress('progress','"&king.lang("progress/ok")&"','"&king.lang("progress/alltime")&formattime(ntime+(Timer-starttime))&"','100%')</script>"
				end if 
			set dp=nothing

	end select

	king.txt ""

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.head king.path,0
	dim list,rs,data,i
	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	select case form("submits")
	case"create" 
		king.progress "index.asp?action=creates&submits=create&list="&list
	case"creates" 
		king.progress "index.asp?action=creates&submits=creates"

	case"delete"
		if len(list)>0 then
			set rs=conn.execute("select onepath from kingonepage where oneid in ("&list&");")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						if len(data(0,i))>0 then
							king.deletefolder "../../"&data(0,i)
						else
							king.deletefile "../../"&king_ext
						end if
					next
					conn.execute "delete from kingonepage where oneid in ("&list&");"
				else
					king.flo one.lang("flo/invalid"),1
				end if
				rs.close
			set rs=nothing
			king.flo one.lang("flo/deleteok"),1
		else
			king.flo one.lang("flo/select"),0
		end if
	case"createmap"
		one.createmap
		king.flo one.lang("flo/createmapok"),0
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	king.head king.path,one.lang("title")

	dim rs,data,dataform,sql,i,oneid,checkpath
	sql="onename,onetitle,onepath,onekeyword,onedescription,onecontent,onetemplate1,onetemplate2"'7
	oneid=quest("oneid",2)
	if len(oneid)=0 then:oneid=form("oneid")
	if len(oneid)>0 then'若有值的情况下
		if validate(oneid,2)=false then king.error king.lang("error/invalid")
	end if
	
	if king.ismethod or len(oneid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from kingonepage where oneid="&oneid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	one.list
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"
	king.form_input "onename",one.lang("label/name"),data(0,0),"onename|6|"&encode(one.lang("check/name"))&"|1-50"'name
	king.form_input "onetitle",one.lang("label/title"),data(1,0),"onetitle|6|"&encode(one.lang("check/title"))&"|1-100"'title
	'
	if len(oneid)>0 then'更新
		checkpath="onepath|6|"&encode(one.lang("check/path"))&"|0-100;onepath|15|"&encode(one.lang("check/path1"))&";onepath|9|"&encode(one.lang("check/path2"))&"|select count(oneid) from kingonepage where onepath='$pro$' and oneid<>"&oneid
	else
		checkpath="onepath|6|"&encode(one.lang("check/path"))&"|0-100;onepath|15|"&encode(one.lang("check/path1"))&";onepath|9|"&encode(one.lang("check/path2"))&"|select count(oneid) from kingonepage where onepath='$pro$'"
	end if
	king.form_input "onepath",one.lang("label/path"),data(2,0),checkpath'path

	king.form_editor "onecontent",one.lang("label/content"),data(5,0),"onecontent|0|"&encode(one.lang("check/content"))'content

	king.form_input "onekeyword",one.lang("label/keyword"),data(3,0),"onekeyword|6|"&encode(one.lang("check/keyword"))&"|0-50"'keyword
	king.form_area "onedescription",one.lang("label/description"),data(4,0),"onedescription|6|"&encode(one.lang("check/description"))&"|0-250"'description
	
	king.form_tmp "onetemplate1",one.lang("label/template1"),data(6,0),0

	king.form_tmp "onetemplate2",one.lang("label/template2"),data(7,0),king.path
	
	king.form_but "save"
	king.form_hidden "oneid",oneid

	Il "</form>"

	if king.ischeck and king.ismethod then
		if len(oneid)>0 then
			conn.execute "update kingonepage set onename='"&safe(data(0,0))&"',onetitle='"&safe(data(1,0))&"',onepath='"&safe(data(2,0))&"',onekeyword='"&safe(data(3,0))&"',onedescription='"&safe(left(data(4,0),250))&"',onecontent='"&safe(data(5,0))&"',onetemplate1='"&safe(data(6,0))&"',onetemplate2='"&safe(data(7,0))&"' where oneid="&oneid&";"
		else
			conn.execute "insert into kingonepage ("&sql&",oneorder) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"','"&safe(data(2,0))&"','"&safe(data(3,0))&"','"&safe(left(data(4,0),250))&"','"&safe(data(5,0))&"','"&safe(data(6,0))&"','"&safe(data(7,0))&"',"&king.neworder("kingonepage","oneorder")&")"
			oneid=king.newid("kingonepage","oneid")
		end if
		Il "<script>confirm('"&htm2js(one.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=edt'""):eval(""parent.location='index.asp'"");</script>"
		one.createmap
		one.create oneid
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_updown()
	king.head king.path,0

	dim oneid
	oneid=quest("oneid",2)
	king.updown "kingonepage,oneid,oneorder",oneid,0
end sub

%>