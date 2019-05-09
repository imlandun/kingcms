<!--#include file="../system/plugin.asp"-->
<%
dim ad
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set ad=new advertising
	select case action
	case"" king_def
	case"edt" king_edt
	case"set" king_set
	case"create" king_create
	case"creates" king_creates
	case"up","down" king_updown
	end select
set ad=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,ad.lang("title")
	dim rs,data,i,dp'lpath:linkpath
	dim but,sql,ispath,lpath

	ad.list
	Il "<div class=""k_form""><div><input type=""button"" value="""&encode(king.lang("common/create"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=create&list=' + escape(getchecked()));""><input type=""button"" value="""&encode(king.lang("common/createall"))&"""  onClick=""javascript:posthtm('index.asp?action=set', 'progress','submits=creates');""></div></div>"

	sql="select adid,adname,adwidth,adheight,addate,adtitle,adorder from kingad order by adorder desc,adid desc;"'6

	set dp=new record
		dp.create sql
		dp.but=dp.sect("create:"&encode(king.lang("common/create")))&dp.prn & dp.plist
		dp.js="cklist(K[0])+'<a href=""index.asp?action=edt&adid='+K[0]+'"" title=""'+K[5]+'"">'+K[0]+') '+K[1]+'</a>'"
		dp.js="'<span title=""'+K[5]+'"">{king:ad name=""'+K[1]+'""/}</span>'"
		dp.js="isexist(K[6],K[7],K[0])"
		dp.js="K[2]+'X'+K[3]"
		dp.js="K[4]"
		dp.js="edit('index.asp?action=edt&adid='+K[0])+updown('index.asp?adid='+K[0])"'+updown('index.asp?adid='+l1)

		Il dp.open

		Il "<tr><th>"&ad.lang("list/id")&") "&ad.lang("list/name")&"</th><th>"&ad.lang("list/tag")&"</th><th>"&ad.lang("list/file")&"</th><th>"&ad.lang("list/size")&"</th><th>"&ad.lang("list/date")&"</th><th class=""w2"">"&ad.lang("list/manage")&"</th></tr>"
		Il "<script>"
		for i=0 to dp.length


			ispath=king.isexist("../../"&ad.path&"/"&dp.data(1,i)&ad.ext)
			if ispath then
				lpath=king_system&"system/link.asp?url="&server.urlencode(king.inst&ad.path&"/"&dp.data(1,i)&ad.ext)
			else
				lpath="index.asp?action=create&adid="&dp.data(0,i)
			end if
			
			Il "ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"',"&dp.data(2,i)&","&dp.data(3,i)&",'"&htm2js(dp.data(4,i))&"','"&htm2js(htmlencode(dp.data(5,i)))&"','"&ispath&"','"&lpath&"');"
		next
		Il "</script>"
		Il dp.close
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_create()
	king.nocache
	king.head king.path,0
	dim I1,adid,rs
	adid=quest("adid",2)
	set rs=conn.execute("select adname from kingad where adid="&adid)
		if not rs.eof and not rs.bof then
			I1="<a href="""&king_system&"system/link.asp?url="&server.urlencode(king.inst&ad.path&"/"&rs(0)&ad.ext)&""" target=""_blank""><img src=""../system/images/os/brow.gif"" class=""os"" /></a>"
		else
			I1="<img src=""../system/images/os/error.gif"" class=""os""/>"
		end if
		rs.close
	set rs=nothing
	ad.create adid
	king.txt I1
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_creates()

	Server.ScriptTimeOut=86400
	king.nocache
	king.head "0","0"

	dim list,i,adids,adid,dp,pct,starttime,j	,ntime
	starttime=Timer
	ntime=quest("time",0)

	Il "<html><head><meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" /><script type=""text/javascript"" charset=""UTF-8"" src=""../system/images/jquery.js""></script><style type=""text/css"">p{font-size:12px;padding:0px;margin:0px;line-height:14px;width:450px;white-space:nowrap;}</style></head><body></body></html>"

	select case quest("submits",0)
		case"create"
			list=quest("list",0)
			if len(list)>0 then
				adids=split(list,",")
				for i =0 to ubound(adids)
					II "<script>setTimeout(""window.parent.gethtm('index.asp?action=create&adid="&adids(i)&"','isexist_"&adids(i)&"',1);"","&(500*i)&")</script>"
				next
			else
				alert ad.lang("flo/select")
			end if

		case"creates"
			II "<script>window.parent.progress_show();</script>"
			set dp=new record
				dp.create "select adid from kingad order by adid ;"
				for i=0 to dp.length
						j=Timer
						ad.create dp.data(0,i)
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
			set rs=conn.execute("select adname from kingad where adid in ("&list&");")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						king.deletefile "../../"&ad.path&"/"&data(0,i)&ad.ext
					next
					conn.execute "delete from kingad where adid in ("&list&");"
				else
					king.flo ad.lang("flo/invalid"),1
				end if
				rs.close
			set rs=nothing
			king.flo ad.lang("flo/deleteok"),1
		else
			king.flo ad.lang("flo/select"),0
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	king.head king.path,ad.lang("title")

	dim rs,data,dataform,sql,i,adid,checkname,arrwidth,arrheight,istag
	sql="adname,adtext,adwidth,adheight,adtitle"'4
	adid=quest("adid",2)
	if len(adid)=0 then:adid=form("adid")
	if len(adid)>0 then'若有值的情况下
		if validate(adid,2)=false then king.error king.lang("error/invalid")
	end if
	
	if king.ismethod or len(adid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
		if king.ismethod=false then'初始化
			data(2,0)=0:data(3,0)=0
		end if
	else
		set rs=conn.execute("select "&sql&" from kingad where adid="&adid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	ad.list
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"
	if len(adid)>0 then'更新
		checkname="adname|6|"&encode(ad.lang("check/name"))&"|1-50;adname|3|"&encode(ad.lang("check/name1"))&";adname|9|"&encode(ad.lang("check/name2"))&"|select count(*) from kingad where adname='$pro$' and adid<>"&adid
	else
		checkname="adname|6|"&encode(ad.lang("check/name"))&"|1-50;adname|3|"&encode(ad.lang("check/name1"))&";adname|9|"&encode(ad.lang("check/name2"))&"|select count(*) from kingad where adname='$pro$'"
	end if
	king.form_input "adname",ad.lang("label/name"),data(0,0),checkname'adname


	Il "<p><label>"&ad.lang("label/title")&"</label><input type=""text"" class=""in4"" name=""adtitle"" value="""&formencode(data(4,0))&""" maxlength=""250"" />"
	Il king.check("adtitle|6|"&encode(ad.lang("check/title"))&"|1-250")
	Il "</p>"

	Il "<p><label>"&ad.lang("label/text")&"</label><textarea name=""adtext"" rows=""15"" cols=""10"" class=""in5"">"&formencode(data(1,0))&"</textarea>"
	Il king.check("adtext|0|"&encode(ad.lang("check/text")))
	Il "</p>"

	Il "<p><label>"&ad.lang("label/size/title")&"</label><span>"
	Il "<input type=""text"" name=""adwidth"" style=""text-align:right;"" value="""&data(2,0)&""" maxlength=""5"" class=""in1"" />px &nbsp;<label>"&ad.lang("label/size/width")&"</label> "
	arrwidth=array(160,250,336,468,728)
	for i=0 to ubound(arrwidth)
		Il king.form_eval("adwidth",arrwidth(i))
	next
	Il "<br/>"
	Il "<input type=""text"" name=""adheight"" style=""text-align:right;"" value="""&data(3,0)&""" maxlength=""5"" class=""in1"" />px &nbsp;<label>"&ad.lang("label/size/height")&"</label>"
	arrheight=array(60,90,250,280,600)
	for i=0 to ubound(arrheight)
		Il king.form_eval("adheight",arrheight(i))
	next
	Il king.check("adwidth|2|"&encode(ad.lang("check/width"))&";adheight|2|"&encode(ad.lang("check/height")))
	Il "</span></p>"
	
	king.form_but "save"
	king.form_hidden "adid",adid

	Il "</form>"

	if king.ischeck and king.ismethod then
		if instr(lcase(data(1,0)),"{king:")>0 then istag=1 else istag=0
		if len(adid)>0 then
			conn.execute "update kingad set adname='"&safe(data(0,0))&"',adtext='"&safe(data(1,0))&"',adwidth="&data(2,0)&",adheight="&data(3,0)&",adtitle='"&safe(data(4,0))&"',istag="&istag&" where adid="&adid&";"
		else
			conn.execute "insert into kingad ("&sql&",adorder,addate,istag) values ('"&safe(data(0,0))&"','"&safe(data(1,0))&"',"&data(2,0)&","&data(3,0)&",'"&safe(data(4,0))&"',"&king.neworder("kingad","adorder")&",'"&tnow&"',"&istag&")"
			adid=king.newid("kingad","adid")
		end if
		ad.create adid
		
		Il "<script>confirm('"&htm2js(ad.lang("alert/saveok"))&"')?eval(""parent.location='index.asp?action=edt'""):eval(""parent.location='index.asp'"");</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_updown()
	king.head king.path,0

	dim adid
	adid=quest("adid",2)
	king.updown "kingad,adid,adorder",adid,0
end sub

%>