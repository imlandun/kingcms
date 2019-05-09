<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set kc=new moodclass
	select case action
	case"" king_def
	case"mood" king_mood
	end select
set kc=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()
	king.nocache
	dim commentid,rs,I1,I2,I3,i,sql,data

	commentid=quest("c",0)

	if validate(commentid,"^[A-Za-z0-9\_\-]*\|\d+$") then

		sql="mood1,mood2,mood3,mood4,mood5,mood6,mood7,mood8"
		I1=split(commentid,"|")
		set rs=conn.execute("select "&sql&" from kingmood where kplugin='"&safe(I1(0))&"' and kid="&I1(1)&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				rs.close
				set rs=nothing
				for i=0 to ubound(data,1)
					if len(I2)>0 then
						I2=I2&","&data(i,0)
					else
						I2=data(i,0)
					end if
				next
				I3="moodinner('"&I2&"');"
			else
				conn.execute "insert into kingmood (kplugin,kid) values ('"&safe(I1(0))&"',"&I1(1)&");"
      			I3="moodinner('0,0,0,0,0,0,0,0');"
			end if
	else
		I1="alert('"&htm2js(king.lang("error/invalid"))&"');"
	end if

	king.txt "{main:'HDR',js:'"&htm2js(I3)&"'}"'&"alert('"&htm2js("HDR")&"');"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_mood()
	king.nocache
	dim commentid,moodid,rs,I1,I2,I3,i,sql,data

	if king.ismethod=false then king.txt king.lang("error/invalid")'不允许访客直接用浏览器方式访问这页面。
	
	commentid=form("c")
	moodid=form("mood_id")

	if validate(commentid,"^[A-Za-z0-9\_\-]*\|\d+$") then

		sql="mood1,mood2,mood3,mood4,mood5,mood6,mood7,mood8"
		I1=split(commentid,"|")

		if kc.judge(I1(0),I1(1)) then'非刷新
			conn.execute "update kingmood set "&moodid&"="&moodid&"+1 where kplugin='"&safe(I1(0))&"' and kid="&I1(1)&";"
			set rs=conn.execute("select "&sql&" from kingmood where kplugin='"&safe(I1(0))&"' and kid="&I1(1)&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
				rs.close
				set rs=nothing
				for i=0 to ubound(data,1)
					if len(I2)>0 then
						I2=I2&","&data(i,0)
					else
						I2=data(i,0)
					end if
				next
				I3="moodinner('"&I2&"');"
			else
				conn.execute "insert into kingmood (kplugin,kid) values ('"&safe(I1(0))&"',"&I1(1)&");"
      			I3="moodinner('0,0,0,0,0,0,0,0');"
			end if

		else'刷新的时候
			I3="alert('"&htm2js(kc.lang("error/no"))&"');"
		end if
	else
		I1="alert('"&htm2js(king.lang("error/invalid"))&"');"
	end if

	kc.log I1(0),I1(1)

	king.txt "{main:'HDR',js:'"&htm2js(I3)&"'}"'&"alert('"&htm2js("HDR")&"');"

end sub
%>