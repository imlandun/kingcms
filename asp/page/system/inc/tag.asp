<%
function lIll(l1,invalue)
dim str,tagname,tag,l2

tag=htmldecode(l1)

tagname=lcase(king.sect(tag,"(king\:)","( |\/|\}|\))",""))
select case tagname
case"sitename" str=king.sitename
case"url","siteurl" str=king.siteurl
case"cms","kingcms" str="<p id=""kingcms"">Powered by: <a href=""http://www."&king.systemname&".com/"" style=""font-weight:bold"" target=""_blank"">"&king.systemname&"</a> <span>"&king.systemver&"</span></p>"
case"now" str=I1I1I(tag,"now:"&encode(tnow),"now")'str=tnow
case"keywords","keyword"'但开发的时候必须用keywords
	str=I1I1I(tag,invalue,"keywords"):if len(str)=0 then str=I1I1I(tag,invalue,"title")
case"description"
	str=I1I1I(tag,invalue,"description"):if len(str)=0 then str=I1I1I(tag,invalue,"title")
case"inst"
	str=king.inst
case"page"
	str=king.page
case"rnd" str=salt(16)
case"rnd4" str=salt(4)
case"rnd8" str=salt(8)
case"guide"
	str=I1I1I(tag,invalue,"guide")
	l2=king.getlabel(tag,"name")
	if len(l2)>0 then
		if len(str)=0 then
			str="<a href=""/"" class=""k_guidename"">"&l2&"</a>"&I1I1I(tag,invalue,"title")
		else
			str="<a href=""/"" class=""k_guidename"">"&l2&"</a>"&str
		end if
	else
		if len(str)=0 then
			str="<a href=""/"" class=""k_guidename"">"&king.sitename&"</a> &gt;&gt; "&I1I1I(tag,invalue,"title")
		else
			str="<a href=""/"" class=""k_guidename"">"&king.sitename&"</a> &gt;&gt; "&str
		end if
	end if
case"sql"
	str=king.ensql(tag)
{king:case/}
case else
	str=I1I1I(tag,invalue,tagname)
end select
lIll=str
end function
%>