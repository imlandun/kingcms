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
	$ktitle=kc_post('ktitle');
	$kemail=kc_post('kemail');
	$kphone=kc_post('kphone');
	$kcountry=kc_post('kcountry');
	$kcontent=kc_post('kcontent');
	
	
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
		'kemail'=>$kemail,
		'kphone'=>$kphone,
		'kcountry'=>$kcountry,
		'kcontent'=>$kcontent,
		//'norder'=>$king->db->neworder('%s_feedback'),
		'ndate' =>time(),
		'nip'=>$fip,
		//'username'=>$data['username'],
		'nshow'=>$ishow
	);
	$king->db->insert('%s_feedback',$array);
	//记录本次发布时间
	setcookie("fbtime",time(),time()+3600,'/');
	$mail = new PHPMailer();
	$mail->IsSMTP();					// 启用SMTP
	$mail->Host = "relay-hosting.secureserver.net";			//SMTP服务器
	$mail->SMTPAuth = false;					//开启SMTP认证
	$mail->Username = "youremail@163.com";			// SMTP用户名
	$mail->Password = "youremailpassword";				// SMTP密码
	
	$mail->From = "youremail@163.com";			//发件人地址
	$mail->FromName = "yourname";				//发件人
	$mail->AddAddress("receiveEmail@163.com", "receiveName");	//添加收件人
	$mail->AddReplyTo($kemail, "");	//回复地址
	$mail->WordWrap = 100;					//设置每行字符长度
	/** 附件设置
	$mail->AddAttachment("/var/tmp/file.tar.gz");		// 添加附件
	$mail->AddAttachment("/tmp/image.jpg", "new.jpg");	// 添加附件,并指定名称
	*/
    
    /**
     * 下面为邮件内容格式，叫EDM，最好采用表格和行业样式编写
     */
	$mail->IsHTML(true);                 // 是否HTML格式邮件
	$mail->CharSet = "utf-8";                // 这里指定字符集！
	$mail->Encoding = "base64"; 
	$mail->Subject = "来自yourweb.com网站的留言：  ".$ktitle;			//邮件主题
	$mail->Body    = "<p>来自yourweb.com网站的最新一条留言</p>
	<p style='color:red'>提示：不能直接回复此邮件给客户哦!!!</p>
	<table cellspacing='0' cellpadding='0' style='border:#2d536e solid 2px; width:100%;'>
  <tbody>
    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>姓&#12288;&#12288;名</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$ktitle."</td>
    </tr>
    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>邮&#12288;&#12288;箱</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kemail."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>手&#12288;&#12288;机</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kphone."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>国&#12288;&#12288;家</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kcountry."</td>
    </tr>
    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>留言内容</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kcontent."</td>
    </tr>
  </tbody>
</table>";	//邮件内容
	$mail->AltBody = "This is the body in plain text for non-HTML mail clients";	//邮件正文不支持HTML的备用显示
	
	if(!$mail->Send())
	{
	   //echo "{title:'OK',main:'成功发布留言 ',but:'确定',js:'',width:320,height:100}";
	   //echo "Mailer Error: " . $mail->ErrorInfo;
	   //exit;
	}
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
/**
   发送留言到邮箱
*/
function king_sendmail(){
	$mail = new PHPMailer();
	$mail->IsSMTP();					// 启用SMTP
	$mail->Host = "smtp1.example.com";			//SMTP服务器
	$mail->SMTPAuth = true;					//开启SMTP认证
	$mail->Username = "name@example.com";			// SMTP用户名
	$mail->Password = "password";				// SMTP密码
	
	$mail->From = "from@example.com";			//发件人地址
	$mail->FromName = "Mailer";				//发件人
	$mail->AddAddress("josh@example.net", "Josh Adams");	//添加收件人
	$mail->AddAddress("ellen@example.com");
	$mail->AddReplyTo("info@example.com", "Information");	//回复地址
	$mail->WordWrap = 50;					//设置每行字符长度
	/** 附件设置
	$mail->AddAttachment("/var/tmp/file.tar.gz");		// 添加附件
	$mail->AddAttachment("/tmp/image.jpg", "new.jpg");	// 添加附件,并指定名称
	*/
	$mail->IsHTML(true);					// 是否HTML格式邮件
	
	$mail->Subject = "Here is the subject";			//邮件主题
	$mail->Body    = "This is the HTML message body <b>in bold!</b>";		//邮件内容
	$mail->AltBody = "This is the body in plain text for non-HTML mail clients";	//邮件正文不支持HTML的备用显示
	
	if(!$mail->Send())
	{
	   echo "Message could not be sent. <p>";
	   echo "Mailer Error: " . $mail->ErrorInfo;
	   exit;
	}
	echo "Message has been sent";
};

?>