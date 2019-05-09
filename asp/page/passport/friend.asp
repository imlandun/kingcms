<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'       好友页面
'***  ***  ***  ***  ***

dim pp
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set pp=new passport
	select case action
	case"" king_def
	case"add" king_add
	case"set" king_set
	case else king.error king.lang("error/invalid")
	end select
set pp=nothing
set king=nothing
'def  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()
	dim dp,sql,i

	if king_remoteurl<>"../" then response.redirect king_remoteurl&"friend.asp"

	king.pphead 1

	sql="select friendid,friendname from kingpassport_friend where username='"&safe(king.name)&"' order by friendid desc;"
	
	king.ol=pp.navigationuser
	king.ol="<div id=""k_usermain"">"
	

	set dp=new record
		dp.create sql
		dp.action="friend.asp?action=set"
		dp.but=dp.sect("msg:"&encode(pp.lang("list/pubmsg"))) & dp.plist
		dp.js="cklist(K[0])+'<label for=""list_'+K[0]+'"">'+K[1]+'</label>'"

		king.ol=dp.open

		king.ol="<tr><th>"&pp.lang("list/friend/name")&"</th></tr>"
		king.ol="<script>"
		for i=0 to dp.length		
			king.ol="ll("&dp.data(0,i)&",'"&htm2js(dp.data(1,i))&"');"
		next
		king.ol="</script>"
		king.ol=dp.close
	set dp=nothing

	king.ol="</div>"

	king.ol="<form class=""k_form"">"
	king.ol="<p>"
	king.ol="<label>"&pp.lang("list/friend/add")&"</label>"
	king.ol="<input class=""k_in2"" type=""text"" size=""5"" onkeydown=""if(event.keyCode==13) {gethtm('friend.asp?action=add&friendname='+encodeURIComponent(this.value),'flo'); return false;}"" />"
	king.ol="</p>"
	king.ol="</form>"

	king.value "title",encode(pp.lang("common/myfriend"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue

	
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.pphead 1

	dim list,rs,data,i,sql,logcount,ol,username,msgtitle,msgcontent,ischeck
	dim users,contents

	list=form("list")
	if len(list)>0 then
		if validate(list,6)=false then king.flo king.lang("error/invalid"),0
	end if

	select case form("submits")
	case"delete"
		if len(list)>0 then
			conn.execute "delete from kingpassport_friend where friendid in ("&list&") and username='"&safe(king.name)&"';"
			king.flo pp.lang("flo/delok"),1
		else
			king.flo pp.lang("flo/select"),0
		end if
	case"msg"
		'判断短信息发送数量，24小时内发送的短信息超过20条，就禁止发信息
		if king_dbtype=1 then
			sql="select count(logid) from kingpassport_log where ip='"&safe(king.ip)&"' and lognum=5 and getdate()-logdate<1;"
		else
			sql="select count(logid) from kingpassport_log where ip='"&safe(king.ip)&"' and lognum=5 and now()-logdate<1;"
		end if
		logcount=conn.execute(sql)(0)

		if logcount>=pp.msgnum then king.flo pp.lang("flo/msgnum"),0


		ischeck=true
		username=form("username")
		msgcontent=form("msgcontent")
		if len(list)>0 and form("system")<>"KingCMS" then
			set rs=conn.execute("select friendname from kingpassport_friend where friendid in("&list&") and username='"&safe(king.name)&"';")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						if len(username)>0 then
							username=username&","&data(0,i)
						else
							username=data(0,i)
						end if
					next
				else
					king.flo king.lang("error/invalid"),0
				end if
				rs.close
			set rs=nothing
		end if

		ol="<div class=""k_form"">"
		ol=ol&"<p><label>"&pp.lang("list/msguser")&"</label><input type=""text"" id=""king_username"" value="""&formencode(username)&""" class=""k_in"" maxlength=""100"" />"
		'检查用户名是否合法
		if form("system")="KingCMS" then
			if len(username)=0 then
				ol=ol&"<span class=""k_error"">"&pp.lang("check/nouser")&"</span>"
				ischeck=false
			else
				users=split(username,",")
				if ubound(users)>4 then
					ol=ol&"<span class=""k_error"">"&pp.lang("check/msguser1")&"</span>"
				else
					for i=0 to ubound(users)
						if len(users(i))>0 then
							if conn.execute("select count(*) from kingpassport where ppname='"&safe(users(i))&"' and isdel=0;")(0)=0 then
								if safe(users(i))<>"[SYSTEM]" then
									ol=ol&"<span class=""k_error"">"&pp.lang("check/msguser")&"</span>"
									ischeck=false
									exit for
								end if
							end if
						end if
					next
				end if
			end if
			
		end if
		ol=ol&"</p>"

		ol=ol&"<p><label>"&pp.lang("list/msgcontent")&"</label><textarea id=""king_msgcontent"" rows=""6"" cols=""30"" class=""k_in"">"&formencode(msgcontent)&"</textarea>"
		'检查内容长度
		if form("system")="KingCMS" then
			if king.lene(msgcontent)>1000 then
				ol=ol&"<span class=""k_error"">"&pp.lang("check/msgcontent")&"</span>"
				ischeck=false
			elseif len(msgcontent)=0 then
				ol=ol&"<span class=""k_error"">"&pp.lang("check/nomsgcontent")&"</span>"
				ischeck=false
			end if
		end if
		ol=ol&"</p>"
		ol=ol&"<div class=""k_but""><input type=""button"" value="""&pp.lang("list/pub")&""" "
		ol=ol&"onclick=""javascript:posthtm('friend.asp?action=set','flo','submits=msg&system=KingCMS&username='+encodeURIComponent(document.getElementById('king_username').value)+'&msgcontent='+encodeURIComponent(document.getElementById('king_msgcontent').value)+'&list="&list&"');"" />"
		ol=ol&"<input type=""button"" value="""&king.lang("common/close")&""" onclick=""javascript:display('flo');""/>"
		ol=ol&"</div>"'end k_but
		ol=ol&"</div>"'end k_form
		
		if ischeck and form("system")="KingCMS" then'通过认证，发送信息
			users=split(username,",")
			username=""
			'获得msgtitle
			contents=split(msgcontent,chr(13)&chr(10))
			for i=0 to ubound(contents)
				if len(msgtitle)>0 then
					exit for
				else
					msgtitle=left(contents(i),50)
				end if
			next

			for i=0 to ubound(users)
				if len(users(i))>0 and king.instre(username,users(i))=false then
					username=users(i)&","&username
					conn.execute "insert into kingpassport_msg (letuser,username,msgtitle,msgcontent,msgdate) values ('"&safe(king.name)&"','"&safe(users(i))&"','"&safe(msgtitle)&"','"&safe(msgcontent)&"','"&tnow&"')"
					'这里还要添加一个passport日志
					conn.execute "insert into kingpassport_log (ppname,lognum,ip,logdate) values ('"&safe(king.name)&"',5,'"&safe(king.ip)&"','"&tnow&"')"
				end if
			next
			king.flo pp.lang("flo/msgok"),0
		else
			king.flo ol,2
		end if
	end select
end sub
'add  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_add()
	king.nocache
	dim friendname,rs
	king.pphead 1
	friendname=quest("friendname",0)
	set rs=conn.execute("select * from kingpassport where ppname='"&safe(friendname)&"' and isdel=0;")
		if not rs.eof and not rs.bof then
			if conn.execute("select count(*) from kingpassport_friend where friendname='"&safe(friendname)&"' and username='"&safe(king.name)&"';")(0)>0 then'如果这个好友已经存在
				king.flo pp.lang("flo/exists"),0
			else
				conn.execute "insert into kingpassport_friend (friendname,username) values ('"&safe(friendname)&"','"&safe(king.name)&"')"
				if instr(lcase(request.servervariables("http_referer")),"friend.asp")>0 then
					king.flo pp.lang("flo/addfriendok"),1'当在friend.asp页面里进行添加操作的时候刷洗屏幕
				else
					king.flo pp.lang("flo/addfriendok"),0'若不是这个页面就关闭
				end if
			end if
		else
			king.flo pp.lang("flo/notuser"),0
		end if
		rs.close
	set rs=nothing
'	king.flo friendname,1
end sub
%>