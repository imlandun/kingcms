<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set kc=new comment
	select case action
	case"good","bad" king_good_bad
	case"post" king_post
	end select
set kc=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***]
sub king_good_bad()
	king.nocache

	dim commentid,I2,cmid,n

	if king.ismethod=false then king.txt king.lang("error/invalid")'不允许访客直接用浏览器方式访问这页面。

	commentid=form("post")
	cmid=form("cmid")
	n=form("n")

	if validate(commentid,"^[A-Za-z0-9\_\-]*\|\d+$") and validate(cmid,2) and validate(n,2) then
		I2=split(commentid,"|")
	else
		king.txt king.lang("error/invalid")
	end if

	if king.instre(kc.plugin,I2(0))=false then king.txt conn.execute("select  k"&action&" from king__"&I2(0)&"_comment where cmid="&cmid&";")(0)
	if kc.judge("",I2(0),I2(1))=false then king.txt conn.execute("select  k"&action&" from king__"&I2(0)&"_comment where cmid="&cmid&";")(0)

	conn.execute "update king__"&I2(0)&"_comment set k"&action&"=k"&action&"+1 where cmid="&cmid&";"

	'更新用户日志数据
	kc.log "",I2(0),I2(1)

	kc.create commentid
	king.txt conn.execute("select  k"&action&" from king__"&I2(0)&"_comment where cmid="&cmid&";")(0)'int(n)+1
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_post()
	dim I1,I2,commentid,rs,data,content,floor
	dim jscomment
	dim quoteid,uname

	king.nocache

	if king.ismethod=false then king.txt king.lang("error/invalid")'不允许访客直接用浏览器方式访问这页面。

	select case(kc.isuser)'0开放评论 1只限制会员评论 -1关闭评论
	case"0","1"'开放评论
		king.pphead kc.isuser
	case"-1"
		king.txt kc.lang("common/isuser_1")'关闭评论
	end select


	commentid=form("post")
	jscomment=commentid
	if len(commentid)=0 then jscomment=form("comment")

	if validate(jscomment,"^[A-Za-z0-9\_\-]*\|\d+$") then
		I2=split(jscomment,"|")
	else
		king.txt king.lang("error/invalid")
	end if

		
	if len(commentid)>0 then
		'引用
		quoteid=form("quoteid")
		if validate(quoteid,2) then
			set rs=conn.execute("select kcontent,kfloor,kusername,kdate from king__"&I2(0)&"_comment where kisview=1 and cmid="&quoteid&";")
				if not rs.eof and not rs.bof then
					if len(rs(2))>0 then uname=rs(2) else uname=kc.lang("common/guest")
					content="[quote][b]#"&rs(1)&" "&uname&"[/b] @ "&rs(3)&vbcrlf&rs(0)&vbcrlf&"[/quote]"&vbcrlf
				end if
				rs.close
			set rs=nothing
		end if
	else
		content=form("content")
	end if

	set rs=conn.execute("select ksize,kisview,kplugin from kingcomment;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			'判断是否支持这个模块下面发表评论
			if king.instre(data(2,0),I2(0))=false then king.txt kc.lang("error/no")
		else
			king.txt king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing


	I1="<div class=""k_form"">"
	'I1=I1&king.ubbshow("k_comment_content",htmlencode(content),60,10,0)
	I1=I1&"<p><textarea id=""k_comment_content"" rows=""6"" cols=""60"" class=""k_in4"">"&formencode(content)&"</textarea>"
	if len(content)>0 and len(commentid)=0 then
		I1=I1&king.check("content|6|"&encode(kc.lang("check/content"))&"|1-"&data(0,0)&";"&king.dirty(content)&"|13|"&encode(kc.lang("check/dirty"))&";"&kc.judge(content,I2(0),I2(1))&"|13|"&encode(kc.lang("check/judge")))
	end if
	I1=I1&"</p>"
	I1=I1&"<div><input type=""submit"" onclick=""posthtm('"&king.page&kc.path&"/index.asp?action=post','k_comment_post','comment="&jscomment&"&content='+encodeURIComponent(document.getElementById('k_comment_content').value))"" value="""&kc.lang("common/post")&""" />(1-"&data(0,0)&")</div>"
	I1=I1&"</div>"

	if len(commentid)=0 and king.ischeck and len(content)>0 then

		floor=king.neworder("king__"&I2(0)&"_comment where kid="&I2(1),"kfloor")

		if king.ischeck and king.ismethod then

			if king.checkcolumn("king__"&I2(0)&"_comment")=false then install I2(0)

			conn.execute "insert into king__"&I2(0)&"_comment (kid,kcontent,kusername,kisview,kuserip,kfloor,kdate) values ("&safe(I2(1))&",'"&safe(content)&"','"&king.name&"',"&data(1,0)&",'"&safe(king.ip)&"',"&floor&",'"&tnow&"')"
			'更新用户日志数据
			kc.log content,I2(0),I2(1)
			'生成
			kc.create jscomment
			I1="<p>"&kc.lang("alert/postok")&"</p>"
			I1=I1&"<p><a href=""javascript:;"" onclick=""gethtm('/"&kc.path&"/"&I2(0)&"/"&I2(1)&"/"&king_ext&"','k_comment')"">"&kc.lang("common/raw")&"</a></p>"
			I1=I1&"<p><a href=""javascript:;"" onclick=""posthtm('"&king.page&kc.path&"/index.asp?action=post','k_comment_post','post="&jscomment&"')"">"&kc.lang("common/postnext")&"</a></p>"
		end if
	end if

	king.txt I1

end sub
%>