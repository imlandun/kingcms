<!--#include file="../../page/system/fun.asp"-->
<!--#include file="../../page/ad/fun.asp"-->
<!--#include file="../../page/Article/fun.asp"-->
<!--#include file="../../page/collect/fun.asp"-->
<!--#include file="../../page/comment/fun.asp"-->
<!--#include file="../../page/digg/fun.asp"-->
<!--#include file="../../page/download/fun.asp"-->
<!--#include file="../../page/EasyArticle/fun.asp"-->
<!--#include file="../../page/feedback/fun.asp"-->
<!--#include file="../../page/link/fun.asp"-->
<!--#include file="../../page/mood/fun.asp"-->
<!--#include file="../../page/movie/fun.asp"-->
<!--#include file="../../page/onepage/fun.asp"-->
<!--#include file="../../page/OO_public/fun.asp"-->
<!--#include file="../../page/passport/fun.asp"-->
<!--#include file="../../page/Tools/fun.asp"-->
<!--#include file="../../page/webftp/fun.asp"-->
<%const king_system = "../../page/"%>
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
case"ad" str=king_tag_ad(tag,invalue)
case"ad#update" str=king_tag_ad_update(tag)
case"article" str=king_tag_article(tag,invalue)
case"articlelist" str=king_tag_article_list(tag,invalue)

case"collect" str=king_tag_collect(tag)
case"comment" str=king_tag_comment(tag,invalue)
case"comment#post" str=king_tag_comment_post(tag,invalue)

case"digg" str=king_tag_digg(tag,invalue)
case"download" str=king_tag_download(tag,invalue)
case"downloadlist" str=king_tag_download_list(tag,invalue)

case"easyarticle" str=king_tag_easyarticle(tag,invalue)
case"link" str=king_tag_link(tag,invalue)
case"linklist" str=king_tag_link_list(tag,invalue)

case"mood" str=king_tag_mood(tag,invalue)
case"movie" str=king_tag_movie(tag,invalue)
case"movielist" str=king_tag_movie_list(tag,invalue)
case"movie#update" str=king_tag_movie_update(tag)
case"onepage" str=king_tag_onepage(tag,invalue)
case"onepage#update" str=king_tag_onepage_update(tag)
case"usernav" str=king_tag_passport_usernav()
case"newuser" str=king_tag_passport_newuser()
case"countuser" str=king_tag_passport_countuser()

case else
	str=I1I1I(tag,invalue,tagname)
end select
lIll=str
end function
%>