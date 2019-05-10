<?php require_once '../global.php';

/* ======= >>> KingCMS <<< ========================== *

 *   @License      http://www.KingCMS.com/license/    *

 *   @Link         http://www.KingCMS.com/            *

 *   @E-Mail       KingCMS@Gmail.com                  *

 *   Copyright (c) KingCMS.com All Rights Reserved.   *

 * ================================================== */

//显示搜索结果列表
function king_def(){
	global $king;
	//权限要求
	$king->access("search");

	$words=kc_get('words',0); 
	//取得匹配的结果集
	//四模型联合搜索只能取共有的列
	$_sql="select kid,kid1,listid,ktitle,kpath,kimage,nshow,nhead,ncommend,nup,nfocus,nhot,ncount from ".DB_PRE."__article where ktitle like '%{$words}%'
	union 
	select kid,kid1,listid,ktitle,kpath,kimage,nshow,nhead,ncommend,nup,nfocus,nhot,ncount from ".DB_PRE."__bbs where ktitle like '%{$words}%'
	union
	select kid,kid1,listid,ktitle,kpath,kimage,nshow,nhead,ncommend,nup,nfocus,nhot,ncount from ".DB_PRE."__product where ktitle like '%{$words}%'
	union
	select kid,kid1,listid,ktitle,kpath,kimage,nshow,nhead,ncommend,nup,nfocus,nhot,ncount from ".DB_PRE."__shop where ktitle like '%{$words}%'
	";
	if(!$res=$king->db->getRows($_sql,1))
		$res=array();
	$_cmd=array();
	$_cmd['create']=$king->lang->get('portal/cmd/createpage');
	$_cmd['delete']=$king->lang->get('system/common/del');
	$_js=array(
		"$.kc_list(K[0],K[3],'manage.content.php?listid='+K[2]+'&action='+(K[13]==1?'edt&kid='+K[0]:'pag&kid1='+K[0]),1,1,null,null,null,iskimage(K[5]))",
		"isexist(K[0],K[4],K[13],K[14],K[0],K[15],K[2])+'<a href=\"manage.content.php?action=edt&listid='+K[2]+'&kid='+K[0]+'&kid1='+K[1]+'\">'+$.kc_icon('e5','编辑')+'</a>'+'<a class=\"k_ajax\" rel=\"{CMD:\'delete\',list:'+K[0]+',listid:'+K[2]+'}\">'+$.kc_icon('g5','删除')+'</a>'",
		"'<i>'+isset('manage.content.php',K[0],'nshow',K[6],K[2])+'</i>'", //开灯
		"'<i>'+isset('manage.content.php',K[0],'nhead',K[7],K[2])+'</i>'",
		"'<i>'+isset('manage.content.php',K[0],'ncommend',K[8],K[2])+'</i>'",
		"'<i>'+isset('manage.content.php',K[0],'nup',K[9],K[2])+'</i>'",
		"'<i>'+isset('manage.content.php',K[0],'nfocus',K[10],K[2])+'</i>'",
		"'<i>'+isset('manage.content.php',K[0],'nhot',K[11],K[2])+'</i>'",
		"'<i>'+K[12]+'</i>'",
		
	); 
	$i=1;
	//打印列表需要的JS函数
	$s='<script>';
	$s.="function isexist(id,path,is,npn,kid,np,listid){var I1;
	if(npn==1 || kid==''){
		if(np==0){
			I1=(is?'<a id=\"page_'+id+'\" href=\"'+path+'\" target=\"_blank\">'+$.kc_icon('h7','".$king->lang->get('system/common/brow')."')+'</a>':'<a id=\"page_'+id+'\" href=\"javascript:;\" class=\"k_ajax\" rel=\"{CMD:\'create_one\',ID:\'page_'+id+'\',listid:'+listid+',IS:2}\">'+$.kc_icon('i7')+'</a>')
		}else{
			I1='<a href=\"'+path+'\" target=\"_blank\">'+$.kc_icon('h7','".$king->lang->get('system/common/brow')."')+'</a>'
		}
	}else{
		I1=''
	}
	return I1};";

	$s.="function iskimage(img){
		var s;
		if(img==''){
			s='';
		}else{

			s=img.match(/^[a-zA-Z]{3,10}:\/\/[^\s]+$/)
				?'<a href=\"'+img+'\" target=\"_blank\">'
				:'<a href=\"../'+img+'\" target=\"_blank\">';
			s+=\$.kc_icon('i6')+'</a>';
		}
		return s;
	};";
	$s.="function isLink(listid,kid){var I1;I1='manage.content.php?action=edt&listid='+listid+'&kid='+kid;return I1};";
	$s.="function isset(url,id,attrib,is,attp){var I1,ico;is?ico='n1':ico='n2';if(is==2) ico='n3';";
	$s.="I1='<a id=\"'+attrib+'_'+id+'\" class=\"k_ajax\" rel=\"{URL:\''+url+'\',CMD:\'attrib\',field:\''+attrib+'\',value:'+ (is==2 ? 0 : 1-is) +',ID:\''+attrib+'_'+id+'\',listid:'+attp+',list:'+id+',IS:2}\" >'+$.kc_icon(ico)+'</a>';return I1;};";
	$s.='</script>';
	
	$s.=$king->openList($_cmd,'',$_js,$king->db->pagelist('search.php?words={$words}&pid=PID&rn=RN',count($res)));
	//行头
	$s.="ll('".$king->lang->get('system/common/title')."', 
			'".$king->lang->get('system/common/manage')."',
			'<i>".$king->lang->get('system/module/show')."</i>',
			'<i>".$king->lang->get('portal/attrib/head')."</i>',
			'<i>".$king->lang->get('portal/attrib/commend')."</i>',
			'<i>".$king->lang->get('portal/label/attrib/isup')."</i>',
			'<i>".$king->lang->get('portal/label/attrib/isfocus')."</i>',
			'<i>".$king->lang->get('portal/label/attrib/ishot')."</i>', 
			'<i>".$king->lang->get('portal/common/pcount')."</i>',1);";   //标题|管理|显示|头条|推荐|置顶|焦点|热门|作者|统计
	//打印记录
	foreach($res as $rs){//td
	    $info=$king->portal->infoList($rs['listid']);
	    if($info['npage']==0){
		    $kpath=$king->portal->pathPage($info,$rs['kid'],$rs['kpath'],1, 1);//根相对地址
		    $isexist=is_file(ROOT.$kpath) ? 1 : 0;
	    }else{
		    $isexist=1;
	    }
	    //kid,kid1,listid,ktitle,kpath,kimage,nshow,nhead,ncommend,nup,nfocus,nhot,ncount
	    $kpath=$king->portal->pathPage($info,$rs['kid'],$rs['kpath']);
	    $s.='ll('.$rs['kid'].',
		    '.$rs['kid1'].',
		    '.$rs['listid'].',
		    \''.addslashes(htmlspecialchars($rs['ktitle'])).'\',
		    \''.addslashes($kpath).'\',
		    \''.addslashes(htmlspecialchars($rs['kimage'])).'\',
		    '.$rs['nshow'].',
		    '.$rs['nhead'].',
		    '.$rs['ncommend'].',
		    '.$rs['nup'].',
		    '.$rs['nfocus'].',
		    '.$rs['nhot'].',
		    '.$rs['ncount'].',
		    '.$isexist.',
		    '.$info['npagenumber'].',
		    '.$info['npage'].',0);';
	}
	//结束列表
	$s.=$king->closeList();
	//打印左标签
	$left=array();
	$right=array();
	$left['']=array(
		'href'=>'manage.php',
		'ico'=>'a1',
		'title'=>$king->lang->get('portal/title/listhome'),
	);
	$left[]=array(
		'class'=>'k_ajax',
		'rel'=>'{CMD:\'clear_cacheall\'}',
		'ico'=>'d8',
		'title'=>$king->lang->get('portal/list/delcache'),
	);
	$king->skin->output($king->lang->get('portal/title/search'),$left,$right,$s);
}

?>
