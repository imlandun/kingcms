<%
class moodclass
private r_doc,r_path,r_time,r_thisver

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()
	dim rs

	r_thisver=1.0
	
	r_path = "mood"

	r_time = 86400 '两次mood的时间 单位(秒)

	if king.checkcolumn("kingmood")=false then
		install:update
	else
		on error resume next
		set rs=conn.execute("select kversion from kingmood_config where systemname='KingCMS'")
			if not rs.eof and not rs.bof then
				dbver=rs(0)
			end if
			rs.close
		set rs=nothing
		if r_thisver>dbver then update
		if err.number<>0 then update
	end if

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function lang(l1)
	on error resume next
	if isobject(r_doc)=false then
		set r_doc=Server.CreateObject(king_xmldom)
		r_doc.async=false
		'判断是否存在所设置的语言包,如果没有就调用默认设置的语言包
		if king.isexist(king_system&r_path&"/language/"&king.language&".xml") then
			r_doc.load(server.mappath(king_system&r_path&"/language/"&king.language&".xml"))
		else
			r_doc.load(server.mappath(king_system&r_path&"/language/"&king_language&".xml"))
		end if
	end if
	lang=r_doc.documentElement.SelectSingleNode("//kingcms/"&l1).text
	if err.number<>0 then
		lang="["&l1&"]"
		err.clear
	end if
end function
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get path
	path=r_path
end property
'  *** Copyright &copy KingCMS.com  All Rights Reserved. ***
public property get time
	time=r_time
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get ip
	dim I1,I2,i
	I1=split(king.ip,".")
	for i=0 to ubound(I1)-1
		I2=I2&right("00"&cstr(I1(i)),3)
	next
	ip=I2
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub log(l1,l2)'日志
	'if king_dbtype=1 then conn.execute("set IDENTITY_INSERT kingmood_log on") 
	if conn.execute("select count(*) from kingmood_log where ip="&kc.ip&" and  kplugin='"&safe(l1)&"' and kid="&l2&";")(0)>0 then
		conn.execute "update kingmood_log set kdate='"&tnow&"',kplugin='"&safe(l1)&"',kid="&safe(l2)&"  where ip="&kc.ip&" and  kplugin='"&safe(l1)&"' and kid="&l2&";"
	else
		conn.execute "insert into kingmood_log (ip,kplugin,kid,kdate) values ("&kc.ip&",'"&safe(l1)&"',"&safe(l2)&",'"&tnow&"')"
	end if
	'if king_dbtype=1 then conn.execute("set IDENTITY_INSERT kingmood_log off") 
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function judge(l1,l2)'判断发帖时间，现在重复发帖
	dim rs,data

	set rs=conn.execute("select kdate,kid,kplugin from kingmood_log  where ip="&kc.ip&" and  kplugin='"&safe(l1)&"' and kid="&l2&";")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			
			if datediff("s",data(0,0),tnow)>r_time then
				judge=true
			else
					'if cstr(l2)=cstr(data(1,0))  and cstr(l1)=cstr(data(2,0)) then
						judge=false
					'else
						'judge=true
					'end if
			end if
		else
			judge=true
		end if
		rs.close
	set rs=nothing

end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub install()
	dim sql
	'kingmood_log
	sql="id int not null identity primary key,"
	sql=sql&"ip int not null,"'IP地址
	sql=sql&"kplugin nvarchar(50),"'模块名称
	sql=sql&"kid int not null default 0,"'对应模块的id
	sql=sql&"kdate datetime"'最后一次添加时间
	conn.execute "create table kingmood_log ("&sql&")"
	'kingmood
	sql="id int not null identity primary key,"
	sql=sql&"kplugin nvarchar(50),"'模块名称
	sql=sql&"kid int not null default 0,"'对应模块的id
	sql=sql&"mood1 int not null default 0,"
	sql=sql&"mood2 int not null default 0,"
	sql=sql&"mood3 int not null default 0,"
	sql=sql&"mood4 int not null default 0,"
	sql=sql&"mood5 int not null default 0,"
	sql=sql&"mood6 int not null default 0,"
	sql=sql&"mood7 int not null default 0,"
	sql=sql&"mood8 int not null default 0"
	conn.execute "create table kingmood ("&sql&")"
	'kingmood_config
	sql="systemname nvarchar(10),"
	sql=sql&"kversion real not null default 1"
	conn.execute "create table kingmood_config ("&sql&")"
	conn.execute "insert into kingmood_config (systemname) values ('KingCMS');"
end sub
'update  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub update()
	dim sql
	on error resume next

	conn.execute "update kingmood_config set kversion="&r_thisver&" where systemname='KingCMS';"
end sub

end class

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_tag_mood(tag,invalue)

	on error resume next

	dim commentid,jsitem
	dim I1,I2,i

	commentid=king.getvalue(invalue,"commentid")

	if validate(commentid,"^[A-Za-z0-9\_\-]*\|\d+$") then
		I1="<div id=""k_mood""><table width=""528"" border=""0"" cellpadding=""0"" cellspacing=""2"" style=""font-size:12px;margin-top: 20px;margin-bottom: 20px;"">"
		I1=I1&"<tr><td colspan=""8"" id=""moodtitle""></td></tr><tr align=""center"" valign=""bottom"">"
		for i = 0 to 7
			I1=I1&"<td height=""60"" id=""moodinfo"&i&"""></td>"
		next
		I1=I1&"</tr><tr align=""center"" valign=""middle"">"
		for i = 0 to 7
			I1=I1&"<td><img src="""&king.page&"mood/images/"&i&".gif"" width=""40"" height=""40""></td>"
		next
		I1=I1&"</tr><tr><td align=""center"">惊呀</td><td align=""center"">欠揍</td><td align=""center"">支持</td><td align=""center"">很棒</td><td align=""center"">愤怒</td><td align=""center"">搞笑</td><td align=""center"">恶心</td><td align=""center"">不解</td></tr><tr align=""center"">"
		for i = 1 to 8
			I1=I1&"<td><input onClick=""posthtm('"&king.page&"mood/index.asp?action=mood','k_moods','c="&server.urlencode(commentid)&"&mood_id=mood"&i&"',0)"" type=""radio"" name=""radiobutton"" value=""radiobutton""></td>"
		next
		I1=I1&"</tr></table><span style=""display: none;""><div id=""k_moods""></div></span></div><script type=""text/javascript"" charset=""utf-8"">gethtm('"&king.page&"mood/index.asp?c="&server.urlencode(commentid)&"','k_moods',0)</script>"
		I1=I1&"<script type=""text/javascript"" charset=""utf-8"">function moodinner(moodtext){var imga = """&king.page&"mood/images/pre_02.gif"";var imgb = """&king.page&"mood/images/pre_01.gif"";var color1 = ""#666666"";var color2 = ""#EB610E"";var heightz = ""80"";var hmax = 0;var hmaxpx = 0;var heightarr = new Array();var moodarr = moodtext.split("","");var moodzs = 0;"
		I1=I1&"for(k=0;k<8;k++) {moodarr[k] = parseInt(moodarr[k]);moodzs += moodarr[k];}"
		I1=I1&"for(i=0;i<8;i++) {heightarr[i]= Math.round(moodarr[i]/moodzs*heightz);if(heightarr[i]<1) heightarr[i]=1;if(moodarr[i]>hmaxpx) {hmaxpx = moodarr[i];}}"
		I1=I1&"$(""#moodtitle"").html(""<span style='color: #555555;padding-left: 20px;font-size:16px;'>您看完此刻的感受是！ 已有<font color='#FF0000'>""+moodzs+""</font>人表态：</span>"");"
		I1=I1&"for(j=0;j<8;j++){if(moodarr[j]==hmaxpx && moodarr[j]!=0) {$(""#moodinfo""+j).html(""<span style='color: ""+color2+"";'>""+moodarr[j]+""</span><br><img src='""+imgb+""' width='20' height='""+heightarr[j]+""'>"");} else {$(""#moodinfo""+j).html(""<span style='color: ""+color1+"";'>""+moodarr[j]+""</span><br><img src='""+imga+""' width='20' height='""+heightarr[j]+""'>"");}}}</script>"
	end if

	if len(I1)=0 or err.number<>0 then
		king_tag_mood=king.errtag(tag)
	else
		king_tag_mood=I1
	end if
end function
%>