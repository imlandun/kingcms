<!--#include file="../system/plugin.asp"-->
<%
dim tl
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set tl=new tools
	select case action
	case"" king_def
	case"inset" king_inset
	case"sql" king_sql
	case"advsql" king_advsql
	case"dbset" king_dbset
	case"info" king_info
	case"up","down" king_updown
	case"backup" king_backup
	case"included" king_included
	end select
set tl=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,tl.lang("common/info")
	dim I1,item,i

	tl.list
	
	Il "<div class=""k_form"">"
	'request对象
	Il "<h3>"&tl.lang("common/request")&"</h3>"
	Il king_table_s
	Il "<script>function lx(l1,l2){document.write('<tr><th class=""w4"">'+l1+'</th><td>'+l2+'</td></tr>');};"
	for each item in request.servervariables
		if len(request.servervariables(item))>0 then
			Il "lx('"&htm2js(htmlencode(item))&"','"&htm2js(king.cls(replace(htmlencode(request.servervariables(item)),chr(10),"<br/>")))&"');"
		end if
	next
	Il "</script>"
	Il "</table>"
	'内置组件
	Il "<h3>"&tl.lang("common/object")&"</h3>"
	Il king_table_s
	I1=split("MSWC.AdRotator|MSWC.BrowserType|MSWC.NextLink|MSWC.Tools|MSWC.Status|MSWC.Counters|IISSample.ContentRotator|IISSample.PageCounter|MSWC.PermissionChecker|Microsoft.XMLHTTP|"&king_xmldom&"|WScript.Shell|"&king_fso&"|Adodb.Connection|"&king_stm,"|")
	Il "<script>"
	for i=0 to ubound(I1)
		Il "lx('"&htm2js(I1(i))&"','"&king.isobj(I1(i))&"');"
	next
	Il "</script>"
	Il "</table>"
	'上传
	Il "<h3>"&tl.lang("common/objectup")&"</h3>"
	Il king_table_s
	I1=split("SoftArtisans.FileUp|Ironsoft.UpLoad|LyfUpload.UploadFile|Persits.Upload.1|w3.upload","|")
	Il "<script>"
	for i=0 to ubound(I1)
		Il "lx('"&htm2js(I1(i))&"','"&king.isobj(I1(i))&"');"
	next
	Il "</script>"
	Il "</table>"
	'邮件
	Il "<h3>"&tl.lang("common/objectmail")&"</h3>"
	Il king_table_s
	I1=split("Jmail.SmtpMail|CDONTS.NewMail|CDO.Message|Persits.MailSender|SMTPsvg.Mailer|DkQmail.Qmail|SmtpMail.SmtpMail.1","|")
	Il "<script>"
	for i=0 to ubound(I1)
		Il "lx('"&htm2js(I1(i))&"','"&king.isobj(I1(i))&"');"
	next
	Il "</script>"
	Il "</table>"
	'图像
	Il "<h3>"&tl.lang("common/objectpic")&"</h3>"
	Il king_table_s
	I1=split("SoftArtisansImageGen|W3Image.Image|Persits.Jpeg|XY.Graphics|Ironsoft.DrawPic","|")
	Il "<script>"
	for i=0 to ubound(I1)
		Il "lx('"&htm2js(I1(i))&"','"&king.isobj(I1(i))&"');"
	next
	Il "</script>"
	Il "</table>"
	

	Il "</div>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_included()
	king.head king.path,tl.lang("common/included")
	dim l1,I1,I2,i,url

	
	url=king.sect(king.siteurl&"/","://","/","")
	if len(url)>4 then
		if lcase(left(url,4))="www." then url=right(url,len(url)-4)
	end if

	l1=king.readfile("included.inc")
	tl.list
	Il "<div class=""k_form"">"
	if len(l1)>0 then
		I1=split(l1,chr(13)&chr(10))
	else
		Il "<p class=""k_error"">"&tl.lang("error/included")&"</p>"
		response.end
	end if
	for i=0 to ubound(I1)
		if len(I1(i))>0 then
			I2=split(I1(i),"|")
			if ubound(I2)=3 then
				Il "<p id=""kin_"&i&"""><script>posthtm('index.asp?action=inset','kin_"&i&"','submits="&I2(0)&"');</script> =&gt; <a href="""&I2(1)&url&""" target=""_blank"">"&tl.lang("common/search")&"</a></p>"
			end if
		end if
	next
	Il "</div>"
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_inset()
	king.nocache
	king.head king.path,0
	dim url,gethtm,num,l1,I1,I2,i
	l1=king.readfile("included.inc")
	url=king.sect(king.siteurl&"/","://","/","")
	if len(url)>4 then
		if lcase(left(url,4))="www." then url=right(url,len(url)-4)
	end if

	if len(l1)>0 then
		I1=split(l1,chr(13)&chr(10))
	else
		king.txt tl.lang("error/included")
	end if

	for i=0 to ubound(I1)
		if len(I1(i))>0 then
			I2=split(I1(i),"|")
			if ubound(I2)=3 then
				if I2(0)=form("submits") then
					gethtm=king.gethtm(I2(1)&url,4)
					num=king.sect(gethtm,I2(2),I2(3),"(\<.+?\>)")
					if len(num)>0 then
						king.txt I2(0)&": <strong>"&num&"</strong> =&gt; <a href="""&I2(1)&url&""" target=""_blank"">"&tl.lang("common/search")&"</a>"
					else
						king.txt I2(0)&": <strong>0</strong> =&gt; <a href="""&I2(1)&url&""" target=""_blank"">"&tl.lang("common/search")&"</a>"
					end if
				end if
			end if
		end if
	next

	king.txt tl.lang("error/gethtm")
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_backup()
	dim dp,but

	king.head king.path,tl.lang("title")
	tl.list
	set dp=new record
		dp.action="index.asp?action=dbset"
		but=dp.sect("back:"&encode(tl.lang("common/back"))&"|reduct:"&encode(tl.lang("common/reduct"))&"|press:"&encode(tl.lang("common/press")))
		Il "<form name=""form1"" class=""k_form"">"
		Il "<script type=""text/javascript"">var k_delete='"&htm2js(king.lang("confirm/delete"))&"';"
		Il "var but='"&htm2js(but)&"';document.write(but);"
		Il "</script>"

		Il king_table_s
		Il "<tr><th>"&tl.lang("common/dbname")&"</th><th>"&tl.lang("common/size")&"</th><th>"&tl.lang("common/date")&"</th></tr>"

			Il king.getfolder("backup","asp","<tr><td><input name=""list"" type=""checkbox"" value=""$fname$""/>$name$</td><td>$size$</td><td>$date$</td></tr>","")

		Il "</table>"
		
		Il "<script type=""text/javascript"">document.write(but);</script>"
		Il "</form>"
	set dp=nothing
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_dbset()
	king.nocache
	king.head king.path,0
	dim list,i,lists
	list=form("list")

	select case form("submits")
	case"back" 
		king.copyfile king_db,"backup/"&formatdate(tnow,"yyyy-MM-dd")&".asp"
		king.flo tl.lang("flo/backok"),1
	case"reduct"
		if len(list)>0 then
			if instr(list,",")>0 then
				king.flo tl.lang("flo/select1")
			else
				king.copyfile list,king_db
				king.flo tl.lang("flo/reductok"),0
			end if
		else
			king.flo tl.lang("flo/select"),0
		end if
	case"delete"
		if len(list)>0 then
			lists=split(list,",")
			for i=0 to ubound(lists)
				king.deletefile "backup/"&lists(i)
			next
			king.flo tl.lang("flo/deleteok"),1
		else
			king.flo tl.lang("flo/select"),0
		end if
	case"press"
		if len(list)>0 then
			lists=split(list,",")
			for i=0 to ubound(lists)
				king.press "backup/"&lists(i)
			next
			king.flo tl.lang("flo/pressok"),1
		else
			king.flo tl.lang("flo/select"),0
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_sql()
	king.head king.path,tl.lang("common/sql")
	dim data(3),i,incheck

	for i=0 to 3
		data(i)=form("sqltext"&i)
	next

	tl.list

	Il "<form name=""form1"" method=""post"" action=""index.asp?action=sql"">"

	for i=0 to 3
		if len(data(i))>0 then
			if letsql(data(i)) then'成功执行
				incheck="false|13|"&tl.lang("check/sqlok")&""
			else
				incheck="false|13|"&tl.lang("check/sql")&""
			end if
		else
			incheck=""
		end if
		king.form_area "sqltext"&i,tl.lang("label/sql")&" ("&(i+1)&")",data(i),incheck
	next
	
	Il "<h3>"&tl.lang("label/help")&"</h3>"
	Il "<p>"

	Il "<label>INSERT</label>"
	Il "<textarea disabled=""true"" rows=""3"" cols=""80"" class=""in5"">"
	Il "insert into ""tablename"""&vbcrlf&"(first_column,...last_column)"&vbcrlf&"values (first_value,...last_value); </textarea>"

	Il "<label>UPDATE</label>"
	Il "<textarea disabled=""true"" rows=""3"" cols=""80"" class=""in5"">"
	Il "update ""tablename"""&vbcrlf
	Il "set ""columnname"" = ""newvalue""[,""nextcolumn"" = ""newvalue2""...]"&vbcrlf
	Il "where ""columnname"" OPERATOR ""value"" [and|or ""column"" OPERATOR ""value""]; </textarea>"

	Il "<label>DELETE</label>"
	Il "<textarea disabled=""true"" rows=""2"" cols=""80"" class=""in5"">"
	Il "delete from ""tablename"""&vbcrlf
	Il "where ""columnname"" OPERATOR ""value"" [and|or ""column"" OPERATOR ""value""];</textarea>"


	Il "</p>"

	king.form_but "submit"

	Il "</form>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function letsql(l1)
	on error resume next
	conn.execute l1
	if err.number=0 then
		letsql=true
	else
		letsql=false
		err.clear
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_advsql()
	king.head king.path,tl.lang("common/sql")
	tl.list

	dim result,sql,exeselecttf,exeresult,errortf,exeresultnum,filedobj,errobj
	result = form("result")
	if result = "submit" then sql =form("sql")
	if (sql <> "") then
		exeselecttf = (lcase(left(trim(sql),6)) = "select")
		conn.errors.clear
		on error resume next
		if exeselecttf = true then
				set exeresult = conn.execute(sql,exeresultnum)
		else
				conn.execute sql,exeresultnum
		end if
		
		if conn.errors.count<>0 then
			errortf = true
			set exeresult = conn.errors
		else
			errortf = false
		end if
	end if
	Il "<div id=""advsql"">"
	Il "<script type=""text/javascript"">function checkexecute(){if(confirm('您确认执行sql语句吗？\n一旦sql执行了删除或者操作命令，结果将是致命的!')){if(document.executeform.sql.value!=''){return true;}else{alert('请填写sql语句');return false;}}else{return false;}}</script>"
	Il "<table width=""100%"" border=""0"" align=""center"" cellpadding=""2"" cellspacing=""1"" class=""tableborder"">"
	Il "<tr><th>sol语句执行操作</th></tr>"
	Il "<tr><td width=""90%"" align=center>"
	Il "<p>注意：本操作仅限高级、对sql编程比较熟悉的用户，您可以直接输入sql执行语句。"
	Il "<form name=""executeform""  onsubmit=""return checkexecute();"" method=""post"" action="""" ><input type=""hidden"" name=""result"" value=""submit"">"
	Il "<fieldset><legend>请输入sql语句</legend>"
	Il "<br>指令：<input type=""text"" name=""sql"" size=""100"" value="""&sql&"""><br>" 
	Il "</font>"
	Il "<p align=center><input type=""submit"" name=""submit3"" value=""执行sql语句"">  <input type=""reset"" value=""清除""><br>"
	Il "</font><br></p>"
	Il "</fieldset>"
	Il "</form>"
	if result = "submit" then
		if errortf = true then
			Il "<table width=""100%"" border=""1"" align=""center"" cellpadding=""0"" cellspacing=""1"" class=""tableborder"">"
			Il "<tr><td> 错误号</td><td> 来源</td><td> 描述</td><td>帮助</td><td> 帮助文档</td></tr>"
			for sql_i=1 to conn.errors.count
				set errobj=conn.errors(sql_i-1)
				Il "<tr><td>"&errobj.number&"</td><td>"&errobj.description&"</td><td>"&errobj.source&"</td><td>"&errobj.helpcontext&"</td><td>"&errobj.helpfile&"</td></tr>"
			next
			Il "</table>"
		else
			Il "<table width=""98%"" border=""0"" align=""center"" cellpadding=""2"" cellspacing=""1"" class=""tableborder"">"
			if exeselecttf = true then
				Il "<tr>"
				for each filedobj in exeresult.fields
					Il "<td class=forumrow>"&filedobj.name&"</td>"
				next
				Il "</tr>"
				do while not exeresult.eof
					Il "<tr >"
					for each filedobj in exeresult.fields
						Il "<td class=forumrow>"
						if isnull(filedobj.value) or  filedobj.value="" then
							Il "&nbsp;"
						else
							'if instr(filedobj.name,"content") or instr(filedobj.name,"description") then
							if king.lene(filedobj.value)>10 then
								Il king.lefte(king.clshtml(filedobj.value),10)&"..."
							else
								Il filedobj.value
							end if 
						end if
						Il "</td>"
					next
					Il "</tr>"
					exeresult.movenext
				loop
			else
				Il "<tr><td>执行结果</td></tr><tr><td>"&exeresultnum&"条纪录被影响</td></tr>"
			end if
			Il "</table>"
		end if
		result=""
	end if
	Il "<table width=""80%"" align=""center""><tr>"
	Il "<td><pre><b>常用语句对照(access数据库)：</b><br />"
	Il "文本型：text<br />"
	Il "长整型：integer<br />"
	Il "双精度型：float<br />"
	Il "货币型：money<br />"
	Il "日期型：date<br />"
	Il "备注型：memo<br />"
	Il "ole型：general<br />"
	Il "1.查询数据<br />"
	Il "例：查询kingart表中的artid字段,arttitle字段<br />"
	Il "select [artid],[arttitle] from kingart<br />"
	Il "<br />"
	Il "2.查询指定条件的数据<br />"
	Il "例：查询kingart表中artid字段小于100的数据的artid字段,arttitle字段<br />"
	Il "select [artid],[arttitle] from kingart where [artid] < 100<br />"
	Il "例：查询kingart表中前100条数据的artid字段,arttitle字段<br />"
	Il "select top 100  [artid],[arttitle] from kingart<br />"
	Il "<br />"
	Il "3.按照一定排序查询<br />"
	Il "例：按照artid顺序查询kingart表中的artid字段,arttitle字段<br />"
	Il "select  [artid],[arttitle] from kingart order by [artid]  asc<br />"
	Il "例：按照artid倒序查询kingart表中的artid字段,arttitle字段<br />"
	Il "select  [artid],[arttitle] from kingart order by [artid] desc<br />"
	Il "<br />"
	Il "4.添加数据<br />"
	Il "例：在kingart表中增加一条记录,其中arttitle字段值为名称1,zt_enname字段值为名称2<br />"
	Il "insert into kingart([arttitle],[zt_enname])values('名称1','名称2')<br />"
	Il "<br />"
	Il "5.删除数据<br />"
	Il "例：删除kingart表中artid的值为1的数据<br />"
	Il "delete from kingart where [artid]=1<br />"
	Il "<br />"
	Il "6.修改数据<br />"
	Il "例：修改kingart中artid为1的数据的arttitle字段值为 新名称<br />"
	Il "update kingart set [arttitle]='新名称' where [artid]=1<br />"
	Il "</pre></td><br />"
	Il "</tr><br />"
	Il "</table><br />"
	Il "</td></tr></table><br />"
	Il "</div>"
	set exeresult = nothing
end sub

%>