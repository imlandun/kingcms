<?php require_once '../global.php';
//添加留言
function king_ajax_add(){
	global $king;
	//过滤IP
	$fip=kc_getip();
	if($king->config('lockip')){
		$array_filter=explode('|',$king->config('lockip'));
		$array_filter=array_diff($array_filter,array(null));
	}else{
		$array_filter=array();
	}
	if(in_array(long2ip($fip), $array_filter)){
		kc_ajax('OK',$king->lang->get('feedback/ok/add')
		,$king->lang->get('system/common/enter'));//添加成功后返回的地址
	}
	$fbtime=kc_cookie("fbtime");//获得上次操作时间
	$kcompany=kc_post('kcompany');
	$kfax=kc_post('kfax');
	$kaddress=kc_post('kaddress');
	$ktitle=kc_post('ktitle');
	$kname=kc_post('kname');
	$kemail=kc_post('kemail');
	$kphone=kc_post('kphone');
	$kqq=kc_post('kqq');
	$kcontent=kc_post('kcontent');
	

	//check ktitle
	if(!isset($ktitle{1}) || strlen($ktitle)>50){
		kc_error($king->lang->get('feedback/error/name',0));
	}
	//check Company
	if(!isset($kcompany{1})){
		kc_error($king->lang->get('feedback/error/name',6));
	}

	//check kname
	if(!isset($kname{1}) || strlen($kname)>30){
		kc_error($king->lang->get('feedback/error/name',1));
	}	
	//check kemail
	if(!kc_validate($kemail,5)){
		kc_error($king->lang->get('feedback/error/name',2));
	}
	//check telephone
	if(!isset($kphone{1})){
		kc_error($king->lang->get('feedback/error/name',10));
	}
	
	
	//check kcontent
	if(!isset($kcontent{9})){
		kc_error($king->lang->get('feedback/error/name',3));
	}
	
	
	
    //feedback limit,隔10分钟
	if($fbtime>time()-600){
		kc_ajax($king->lang->get('system/common/tip'),$king->lang->get('feedback/error/name',5),0);
	}
	
	$king->load('user');
	$ishow=0; //不显示
	if($user=$king->user->checkLogin()){
	    $userid=$user['userid'];
	    $data=$king->db->getRows_one("select username from %s_user where userid={$userid}");
	    if(!empty($data)){
		$ishow=($king->db->getRows("select kid from %s_feedback where nshow=1 and username='".$data['username']."'"))?1:0;
	    }
	}
	$array=array(
		'ktitle'=>$ktitle,
		'kcompany'=>$kcompany,
		'kfax'=>$kfax,
		'kaddress'=>$kaddress,
		'kname'=>$kname,
		'kemail'=>$kemail,
		'kphone'=>$kphone,
		'kqq'=>$kqq,
		'kcontent'=>$kcontent,
		//'norder'=>$king->db->neworder('%s_feedback'),
		'ndate' =>time(),
		'nip'=>$fip,
		//'username'=>$data['username'],
		'nshow'=>$ishow,
	);
	$king->db->insert('%s_feedback',$array);
	//记录本次发布时间
	setcookie("fbtime",time(),time()+3600,'/');

	kc_ajax('OK',$king->lang->get('feedback/ok/add'),$king->lang->get('system/common/enter'));//添加成功后返回的地址
}


/**
	添加留言
*/
function king_def(){
	global $king;
	
	$pid=isset($_GET['pid']) ? kc_get('pid',2,1) :1;
	$rn=isset($_GET['rn']) ? kc_get('rn',2,1) :10;
	$skip=($pid==1) ? 0 : ($pid-1)*$rn;

	if($rn>100) $rn=100;
	$count=$king->db->getRows_number('%s_feedback');
	
	$tmp=new KC_Template_class($king->config('templatepath').'/default.htm',$king->config('templatepath').'/inside/feedback/default.htm');
	
	$tmp->assign('title',$king->lang->get('feedback/name'));
	$tmp->assign('type','feedback');  //用于分页
	$tmp->assign('pid',$pid);
	$tmp->assign('rn',$rn);
	$tmp->assign('count',$count);
	
	echo $tmp->output();

}
?>