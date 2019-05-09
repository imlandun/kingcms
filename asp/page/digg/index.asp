<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set kc=new diggclass
	king_def
set kc=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()
	king.nocache
	dim commentid,item,number,id
	dim rs,I1,I2,I3,i

	id=0

	if king.ismethod=false then king.txt king.lang("error/invalid")'不允许访客直接用浏览器方式访问这页面。
	
	item=form("i")
	commentid=form("c")
	number=form("n")'ubound(item)
'	item=quest("i",2)
'	commentid=quest("c",0)
'	number=quest("n",2)'ubound(item)



	if validate(commentid,"^[A-Za-z0-9\_\-]*\|\d+$") and validate(item,2) and validate(number,2) then
		if cdbl(number)>4 or cdbl(item)>4 then'这个值不能大于4,最多为5个项目
			I1="alert('"&htm2js(king.lang("error/invalid"))&"');"
		else

			I2=split(commentid,"|")

			if kc.judge(I2(0),I2(1)) then'非刷新
				'判断这个提交项目是否为已存在的模块类型
				if king.instre(king.plugin,I2(0)) then
					set rs=conn.execute("select id from kingdigg where kplugin='"&safe(I2(0))&"' and kid="&I2(1)&";")
						if not rs.eof and not rs.bof then'如果有这个项目，则＋＋
							id=rs(0)
							conn.execute "update kingdigg set digg"&item&"=digg"&item&"+1 where id="&id&";"
						else
							conn.execute "insert into kingdigg (digg"&item&",kplugin,kid) values (1,'"&safe(I2(0))&"',"&I2(1)&")"
							id=king.newid("kingdigg","id")
						end if
						rs.close
					set rs=nothing
				else
					I1="alert('"&htm2js(kc.lang("error/noplugin"))&"');"
				end if

			else'刷新的时候
				I1="alert('"&htm2js(kc.lang("error/no"))&"');"
				set rs=conn.execute("select id from kingdigg where kplugin='"&safe(I2(0))&"' and kid="&I2(1)&";")
					if not rs.eof and not rs.bof then
						id=rs(0)
					end if
					rs.close
				set rs=nothing
			end if

		end if
	else
		I1="alert('"&htm2js(king.lang("error/invalid"))&"');"
	end if

	kc.log I2(0),I2(1)

	'king.txt "{main:'"&king_main(id,number)&"',js:'"&htm2js(I1)&"'}"
	king.txt "{main:'"&king_main(id,item)&"',js:'"&htm2js(I1)&"'}"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved. ***
function king_main(l1,l2)
	dim rs,i,I1,data

	set rs=conn.execute("select digg0,digg1,digg2,digg3,digg4 from kingdigg where id="&l1&";")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			'for i=0 to l2
				'I1=I1&"<span><a href=""javascript:;"">"&data(i,0)&"</a></span>"
			'next
			I1=I1&"<span><a href=""javascript:;"">"&data(l2,0)&"</a></span>"
		else
			'for i=0 to l2
				'I1=I1&"<span><a href=""javascript:;"">0</a></span>"
			'next
			I1=I1&"<span><a href=""javascript:;"">"&data(l2,0)&"</a></span>"
		end if
		rs.close
	set rs=nothing

	king_main=I1
end function
%>