<?php require_once '../global.php';
//已读未读
function king_ajax_read(){
	global $king;
	$king->access('ordersystem_edt');
	$kid=kc_get('list',2,1);
	$value=kc_get('value',2,1);
	$king->db->query("update %s_ordersystem set nread=$value where kid=$kid;");
	$value ? $ico='n2':$ico='n1';
	kc_ajax('',kc_icon($ico,($value?$king->lang->get('ordersystem/list/unread'):$king->lang->get('ordersystem/list/read'))),0,"$('#nread_{$kid}').attr('rel','{CMD:\'read\',value:".(1-$value).",ID:\'nread_{$kid}\',list:\'$kid\',IS:2}')");
}

//删除留言
function king_ajax_delete(){
	global $king;
	$king->access('ordersystem_delete');
	$list=kc_getlist();
	$king->db->query("delete from %s_ordersystem where kid in ($list)");
	kc_ajax('OK',"<p class=\"k_ok\">".$king->lang->get('system/ok/delete')."</p>",1);
}

//排序
function king_ajax_updown(){
	global $king;
	$king->access('ordersystem_updown');

	$kid=kc_get('kid',2,1);
	$king->db->updown('%s_ordersystem',$kid);
}
//显示隐藏
function king_ajax_show(){
	global $king;
	$king->access('ordersystem_edt');
	$kid=kc_get('list',2,1);
	$value=kc_get('value',2,1);
	$king->db->query("update %s_ordersystem set nshow=$value where kid=$kid;");
	$value ? $ico='n1':$ico='n2';
	kc_ajax('',
		kc_icon($ico,($value?$king->lang->get('ordersystem/list/unshow'):$king->lang->get('ordersystem/list/show'))),
		0,
		"$('#nshow_{$kid}').attr('rel','{CMD:\'show\',value:".(1-$value).",ID:\'nshow_{$kid}\',list:\'$kid\',IS:2}')");
}
//回复留言
function king_ajax_reply(){
	global $king;
	$king->access('ordersystem_reply');
	$kid=kc_get('kid',2,1);
	$kreply=kc_post('reply');
	
	$king->db->update('%s_ordersystem',array('nreply'=>1,'kreply'=>$kreply),'kid='.$kid);
	kc_ajax('OK',"<p class=\"k_ok\">".$king->lang->get('ordersystem/ok/reply')."</p>",1);
}
/**
菜单调用
*/
function inc_menu(){
	global $king;
	$left=array(
		''=>array(
			'href'=>'manage.php',
			'ico'=>'p7',
			'title'=>$king->lang->get('system/common/list'),
			),
	);
	if(isset($_GET['kid'])){
		$left['view']=array(
			'href'=>'manage.php?action=view&kid='.$_GET['kid'],
			'ico'=>'p8',
			'title'=>$king->lang->get('system/common/view'),
		);
	}
	return array($left,array());
}

function king_def(){
	global $king;
	$king->access('ordersystem');

	$_cmd=array(
		'delete'=>$king->lang->get('system/common/del'),
	);
	$manage="'<a href=\"manage.php?action=view&kid='+K[0]+'\">'+\$.kc_icon('q7','".addslashes($king->lang->get('system/common/view'))."')+'</a>'";
	$manage.="+'<a href=\"javascript:;\" class=\"k_ajax\" rel=\"{CMD:\'delete\',list:'+K[0]+'}\">'+\$.kc_icon('q8','".addslashes($king->lang->get('system/common/del'))."')+'</a>'";
	$manage.="+\$.kc_updown(K[0])";

	$_js=array(
		"\$.kc_list(K[0],K[1],'manage.php?action=view&kid='+K[0])",
		$manage,
		"'<i>'+isread('manage.php',K[0],K[2])+'</i>'",//状态
		"'<i>'+ishow('manage.php',K[0],K[3])+'</i>'",//显示
		"K[4]",
		"K[5]",
		"K[6]",
	);
	$s=$king->openList($_cmd,'',$_js,$king->db->pagelist('manage.php?pid=PID&rn=RN',$king->db->getRows_number('%s_ordersystem','kid!=0')));

	$_sql="select kid,ktitle,nread,kname,kemail,kcountry,kcompany,kmobile,kfactory_name,kfactory_tel,kaddress,kfactory_mobile,kfactory_contact,kfactory_email,kdate,kpreshipment,kfactory_audit,kduringproduction,kloadingcheck,kfirstarticle,ksocialaudit,kother,kproduct_description1,kmodel_number1,kquantity1,kproduct_description2,kmodel_number2,kquantity2,kproduct_description3,kmodel_number3,kquantity3,kproduct_description4,kmodel_number4,kquantity4,kproduct_description5,kmodel_number5,kquantity5,ndate,nshow from %s_ordersystem order by norder desc,kid desc";
	if(!$res=$king->db->getRows($_sql,1))
		$res=array();

	$s.="function isread(url,id,is){var I1,ico;is?ico='n2':ico='n1';";
	$s.="I1='<a id=\"nread_'+id+'\" class=\"k_ajax\" rel=\"{CMD:\'read\',value:'+ (1-is) +',ID:\'nread_'+id+'\',list:'+id+',IS:2}\" >'+$.kc_icon(ico,(is?'".$king->lang->get('ordersystem/list/unread')."':'".$king->lang->get('ordersystem/list/read')."'))+'</a>';return I1;};";
	$s.="function ishow(url,id,is){var I1,ico;is?ico='n1':ico='n2';";
	$s.="I1='<a id=\"nshow_'+id+'\" class=\"k_ajax\" rel=\"{CMD:\'show\',value:'+ (1-is) +',ID:\'nshow_'+id+'\',list:'+id+',IS:2}\" >'+$.kc_icon(ico,(is?'".$king->lang->get('ordersystem/list/unshow')."':'".$king->lang->get('ordersystem/list/show')."'))+'</a>';return I1;};";
	$s.="ll('".$king->lang->get('ordersystem/list/title')."',
	    'manage',
	    '<i>".$king->lang->get('ordersystem/list/status')."<i>',
	    '<i>".$king->lang->get('ordersystem/list/nshow')."</i>',
	    '".$king->lang->get('ordersystem/list/name')."',
	    '".$king->lang->get('ordersystem/list/email')."',
	    '".$king->lang->get('ordersystem/list/date')."',1);";

	foreach($res as $rs){
		$s.="ll({$rs['kid']},
		    '".addslashes(htmlspecialchars($rs['ktitle']))."',
		    ".$rs['nread'].",
		    ".$rs['nshow'].",
		    '".addslashes(htmlspecialchars($rs['kname']))."',
		    '".addslashes($rs['kemail'])."',
		    '".kc_formatdate($rs['ndate'])."',0);";
	}

	$s.=$king->closeList();

	list($left,$right)=inc_menu();
	$king->skin->output($king->lang->get('ordersystem/title/center'),$left,$right,$s);
}

function king_view(){
	global $king;
	$king->access('ordersystem');
	
	$kid=kc_get('kid',2);
	$sql="kid,ktitle,kname,kemail,kphone,kcontent,kcountry,kcompany,kmobile,kfactory_name,kfactory_tel,kaddress,kfactory_mobile,kfactory_contact,kfactory_email,kdate,kpreshipment,kfactory_audit,kduringproduction,kloadingcheck,kfirstarticle,ksocialaudit,kother,kproduct_description1,kmodel_number1,kquantity1,kproduct_description2,kmodel_number2,kquantity2,kproduct_description3,kmodel_number3,kquantity3,kproduct_description4,kmodel_number4,kquantity4,kproduct_description5,kmodel_number5,kquantity5,ndate,kreply,nreply";

	if(!$res=$king->db->getRows("select $sql from %s_ordersystem where kid=$kid"))
		$res=array();

	if(empty($kid)){
		kc_error($king->lang->get('system/error/param'));
	}else{
		if(!$rs=$king->db->getRows_one("select $sql from %s_ordersystem where kid=$kid order by norder asc"))
			kc_error($king->lang->get('system/error/notrecord'));

		foreach ($rs as &$r) {
			$r=htmlspecialchars($r);
		}
		$rs['kcontent']=nl2br($rs['kcontent']);

		$s=$king->openForm($king->lang->get('ordersystem/name'),'','ordersystem_edt');
		$s.=$king->htmForm($king->lang->get('ordersystem/label/name'),$rs['ktitle']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/country'),$rs['kcountry']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/mobile'),$rs['kmobile']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/company'),$rs['kcompany']);
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/factoryName'),$rs['kfactory_name']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/factoryTel'),$rs['kfactory_tel']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/address'),$rs['kaddress']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/factoryMobile'),$rs['kfactory_mobile']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/factoryContact'),$rs['kfactory_contact']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/factoryEmail'),$rs['kfactory_email']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/factoryDate'),$rs['kdate']);
		
		$rs['kpreshipment'] = empty($rs['kpreshipment'])? "" : $rs['kpreshipment'].'<span style="margin:0 15px;">|</span>';
		$rs['kfactory_audit'] = empty($rs['kfactory_audit'])? "" : $rs['kfactory_audit'].'<span style="margin:0 15px;">|</span>';
		$rs['kduringproduction'] = empty($rs['kduringproduction'])? "" : $rs['kduringproduction'].'<span style="margin:0 10px;">|</span>';
		$rs['kloadingcheck'] = empty($rs['kloadingcheck'])? "" : $rs['kloadingcheck'].'<span style="margin:0 10px;">|</span>';
		$rs['kfirstarticle'] = empty($rs['kfirstarticle'])? "" : $rs['kfirstarticle'].'<span style="margin:0 10px;">|</span>';
		$rs['ksocialaudit'] = empty($rs['ksocialaudit'])? "" : $rs['ksocialaudit'].'<span style="margin:0 10px;">|</span>';
		$rs['kother'] = empty($rs['kother'])? "" : $rs['kother'].'';
	
		$s.=$king->htmForm($king->lang->get('ordersystem/label/servicetype'),$rs['kpreshipment'].$rs['kfactory_audit'].$rs['kduringproduction'].$rs['kloadingcheck'].$rs['kfirstarticle'].$rs['ksocialaudit'].$rs['kother']);
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/product'),'<span class="product1">'.$king->lang->get('ordersystem/label/ProductDescription').'</span><span class="product2">'.$king->lang->get('ordersystem/label/ModelNumber').'</span><span class="product3">'.$king->lang->get('ordersystem/label/Quantity').'</span>');
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/product'),'<span class="product11">'.$rs['kproduct_description1'].'</span><span class="product22">'.$rs['kmodel_number1'].'</span><span class="product33">'.$rs['kquantity1'].'</span>');
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/product'),'<span class="product11">'.$rs['kproduct_description2'].'</span><span class="product22">'.$rs['kmodel_number2'].'</span><span class="product33">'.$rs['kquantity2'].'</span>');
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/product'),'<span class="product11">'.$rs['kproduct_description3'].'</span><span class="product22">'.$rs['kmodel_number3'].'</span><span class="product33">'.$rs['kquantity3'].'</span>');
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/product'),'<span class="product11">'.$rs['kproduct_description4'].'</span><span class="product22">'.$rs['kmodel_number4'].'</span><span class="product33">'.$rs['kquantity4'].'</span>');
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/product'),'<span class="product11">'.$rs['kproduct_description5'].'</span><span class="product22">'.$rs['kmodel_number5'].'</span><span class="product33">'.$rs['kquantity5'].'</span>');
		
		
		
		$s.=$king->htmForm($king->lang->get('ordersystem/label/email'),'<a href="mailto:'.$rs['kemail'].'" title="'.$king->lang->get('ordersystem/list/sendmail').$rs['kname'].'">'.$rs['kemail'].'</a>');
		$s.=$king->htmForm($king->lang->get('ordersystem/label/phone'),$rs['kphone']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/content'),$rs['kcontent']);
		$s.=$king->htmForm($king->lang->get('ordersystem/label/date'),kc_formatdate($rs['ndate']));
		//$s.=$king->htmForm($king->lang->get('ordersystem/list/reply'),kc_htm_textarea('reply', $rs['kreply']));
		//$but='<input type="button" onclick="javascript:history.back(-1)" value="'.$king->lang->get('system/common/back').'[B]" class="big" accesskey="b"/>';
		//增加回复
		/*
		if($rs['nreply']=='0'){
		    $but.="<input type=\"button\" value=\"".$king->lang->get('ordersystem/ACCESS/ordersystem_reply')."\" onClick=\"\$.kc_ajax({CMD:'reply',kid:{$rs['kid']},FORM:'ordersystem_edt'});\" />";
		}
		*/
		$s.=$king->htmForm(null,$but);
		$s.=$king->closeForm('none');
	}
	//设置为已读状态
	$king->db->update('%s_ordersystem',array('nread'=>1),'kid='.$kid);

	list($left,$right)=inc_menu();
	$king->skin->output($king->lang->get('ordersystem/title/center'),$left,$right,$s);

}


?>