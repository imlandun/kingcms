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
		kc_ajax('OK',$king->lang->get('ordersystem/ok/add')
		,$king->lang->get('system/common/enter'));//添加成功后返回的地址
	}
	$fbtime=kc_cookie("fbtime");//获得上次操作时间
	$ktitle=kc_post('ktitle');
	$kemail=kc_post('kemail');
	$kphone=kc_post('kphone');
	$kcountry=kc_post('kcountry');
	$kcontent=kc_post('kcontent');
	$kcompany=kc_post('kcompany');
	$kmobile=kc_post('kmobile');
	
	$kfactory_name=kc_post('kfactory_name');
	$kfactory_tel=kc_post('kfactory_tel');
	$kaddress=kc_post('kaddress');
	$kfactory_mobile=kc_post('kfactory_mobile');
	$kfactory_contact=kc_post('kfactory_contact');
	$kfactory_email=kc_post('kfactory_email');
	$kdate=kc_post('kdate');
	
	$kpreshipment=kc_post('kpreshipment');
	$kfactory_audit=kc_post('kfactory_audit');
	$kduringproduction=kc_post('kduringproduction');
	$kloadingcheck=kc_post('kloadingcheck');
	$kfirstarticle=kc_post('kfirstarticle');
	$ksocialaudit=kc_post('ksocialaudit');
	$kother=kc_post('kother');
	
	
	$kproduct_description1=kc_post('kproduct_description1');
	$kproduct_description2=kc_post('kproduct_description2');
	$kproduct_description3=kc_post('kproduct_description3');
	$kproduct_description4=kc_post('kproduct_description4');
	$kproduct_description5=kc_post('kproduct_description5');
	
	$kmodel_number1=kc_post('kmodel_number1');
	$kmodel_number2=kc_post('kmodel_number2');
	$kmodel_number3=kc_post('kmodel_number3');
	$kmodel_number4=kc_post('kmodel_number4');
	$kmodel_number5=kc_post('kmodel_number5');
	
	$kquantity1=kc_post('kquantity1');
	$kquantity2=kc_post('kquantity2');
	$kquantity3=kc_post('kquantity3');
	$kquantity4=kc_post('kquantity4');
	$kquantity5=kc_post('kquantity5');
		
	
	
	$king->load('user');
	$ishow=0; //不显示
	if($user=$king->user->checkLogin()){
	    $userid=$user['userid'];
	    $data=$king->db->getRows_one("select username from %s_user where userid={$userid}");
	    if(!empty($data)){
		$ishow=($king->db->getRows("select kid from %s_ordersystem where nshow=1 and username='".$data['username']."'"))?1:0;
	    }
	}
	$array=array(
		'ktitle'=>$ktitle,
		'kemail'=>$kemail,
		'kphone'=>$kphone,
		'kcountry'=>$kcountry,
		'kcontent'=>$kcontent,
		'kcompany'=>$kcompany,
		'kmobile'=>$kmobile,
		
		'kfactory_name'=>$kfactory_name,
		'kfactory_tel'=>$kfactory_tel,
		'kaddress'=>$kaddress,
		'kfactory_mobile'=>$kfactory_mobile,
		'kfactory_contact'=>$kfactory_contact,
		'kfactory_email'=>$kfactory_email,
		'kdate'=>$kdate,
		
		'kpreshipment'=>$kpreshipment,
		'kfactory_audit'=>$kfactory_audit,
		'kduringproduction'=>$kduringproduction,
		'kloadingcheck'=>$kloadingcheck,
		'kfirstarticle'=>$kfirstarticle,
		'ksocialaudit'=>$ksocialaudit,
		'kother'=>$kother,
		
		'kproduct_description1'=>$kproduct_description1,
		'kproduct_description2'=>$kproduct_description2,
		'kproduct_description3'=>$kproduct_description3,
		'kproduct_description4'=>$kproduct_description4,
		'kproduct_description5'=>$kproduct_description5,
		
		'kmodel_number1'=>$kmodel_number1,
		'kmodel_number2'=>$kmodel_number2,
		'kmodel_number3'=>$kmodel_number3,
		'kmodel_number4'=>$kmodel_number4,
		'kmodel_number5'=>$kmodel_number5,
		
		'kquantity1'=>$kquantity1,
		'kquantity2'=>$kquantity2,
		'kquantity3'=>$kquantity3,
		'kquantity4'=>$kquantity4,
		'kquantity5'=>$kquantity5,
		
		
		

		//'norder'=>$king->db->neworder('%s_ordersystem'),
		'ndate' =>time(),
		'nip'=>$fip,
		//'username'=>$data['username'],
		'nshow'=>$ishow
	);
	$king->db->insert('%s_ordersystem',$array);
	
	$mailDatas = $king->db->getRows_one("select kcontent from %s_block where kid=7");
	$mailDatas2 = explode("|",$mailDatas[0]);
	$mailUsername = $mailDatas2[0];
	$mailPassword = $mailDatas2[1];
	$mailSmtp = $mailDatas2[2];
	//记录本次发布时间
	setcookie("fbtime",time(),time()+3600,'/');
	$mail = new PHPMailer();
	$mail->IsSMTP();					// 启用SMTP
	$mail->Host = "relay-hosting.secureserver.net";			//SMTP服务器
	$mail->SMTPAuth = false;					//开启SMTP认证
	$mail->Username = "remail@freequalityasia.com";			// SMTP用户名
	$mail->Password = "abc123456";				// SMTP密码
	
	$mail->From = "remail@freequalityasia.com";			//发件人地址
	$mail->FromName = "www.freequalityasia.com";				//发件人
	$mail->AddAddress("remail@freequalityasia.com", "www.freequalityasia.com");	//添加收件人
	$mail->AddReplyTo($kemail, "");	//回复地址
	$mail->WordWrap = 100;					//设置每行字符长度
	/** 附件设置
	$mail->AddAttachment("/var/tmp/file.tar.gz");		// 添加附件
	$mail->AddAttachment("/tmp/image.jpg", "new.jpg");	// 添加附件,并指定名称
	*/
	
	$mail->IsHTML(true);                 // 是否HTML格式邮件
	$mail->CharSet = "utf-8";                // 这里指定字符集！
	$mail->Encoding = "base64"; 
	
	$mail->Subject = "来自Freequalityasia.com网站的订单：  ".$ktitle;			//邮件主题
	$mail->Body    = "<p>来自Freequalityasia.com网站的最新一条订单</p>
	<p style='color:red'>提示：不能直接回复此邮件给客户哦!!!</p>
	<table cellspacing='0' cellpadding='0' style='border:#2d536e solid 2px; width:100%;'>
  <tbody>
    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>姓&#12288;&#12288;名</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$ktitle."</td>
    </tr>
    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>国&#12288;&#12288;家</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kcountry."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>手&#12288;&#12288;机</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kphone."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>公司名称</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kcompany."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>工厂名称</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kfactory_name."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>工厂电话</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kfactory_tel."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>工厂地址</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kaddress."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>工厂联系人手机</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kfactory_mobile."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>工厂联系人</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kfactory_contact."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>工厂邮箱</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kfactory_email."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>检查日期</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kdate."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>服务类型</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'><table width='100%' border='0' cellpadding='0' cellspacing='0'>
          <tbody>
            <tr>
              <td style='font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-bottom:#ccc solid 1px; padding:0 15px;'>1、&nbsp;".$kpreshipment."</td>
            </tr>
            <tr>
              <td style='font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-bottom:#ccc solid 1px; padding:0 15px;'>2、&nbsp;".$kfactory_audit."</td>
            </tr>
            <tr>
              <td style='font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-bottom:#ccc solid 1px; padding:0 15px;'>3、&nbsp;".$kduringproduction."</td>
            </tr>
            <tr>
              <td style='font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-bottom:#ccc solid 1px; padding:0 15px;'>4、&nbsp;".$kloadingcheck."</td>
            </tr>
			 <tr>
              <td style='font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-bottom:#ccc solid 1px; padding:0 15px;'>5、&nbsp;".$kfirstarticle."</td>
            </tr>
			 <tr>
              <td style='font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-bottom:#ccc solid 1px; padding:0 15px;'>6、&nbsp;".$ksocialaudit."</td>
            </tr>
            <tr>
              <td style='font-size:12px;color:#4d4d4d;height:35px; line-height:35px; padding:0 15px;'>5(other)、&nbsp;".$kother."</td>
            </tr>
          </tbody>
      </table></td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>其他产品描述</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'><table width='100%' border='0' cellpadding='0' cellspacing='0'>
          <tbody>
            <tr>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%; text-align:center; font-weight:bold;'>Product Description</td>
              <td style='border-bottom:#ccc solid 1px; border-right:#ccc solid 1px; border-left:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%; text-align:center; font-weight:bold;'>Model Number</td>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%; text-align:center; font-weight:bold;'>Quantity</td>
            </tr>
			<tr>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%;'>&nbsp;".$kproduct_description1."</td>
              <td style='border-bottom:#ccc solid 1px; border-right:#ccc solid 1px; border-left:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kmodel_number1."</td>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kquantity1."</td>
            </tr>
            <tr>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%;'>&nbsp;".$kproduct_description2."</td>
              <td style='border-bottom:#ccc solid 1px; border-right:#ccc solid 1px; border-left:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kmodel_number2."</td>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kquantity2."</td>
            </tr>
            <tr>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%;'>&nbsp;".$kproduct_description3."</td>
              <td style='border-bottom:#ccc solid 1px; border-right:#ccc solid 1px; border-left:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kmodel_number3."</td>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kquantity3."</td>
            </tr>
            <tr>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%;'>&nbsp;".$kproduct_description4."</td>
              <td style='border-bottom:#ccc solid 1px; border-right:#ccc solid 1px; border-left:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kmodel_number4."</td>
              <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kquantity4."</td>
            </tr>
            <tr>
              <td style='font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kproduct_description5."</td>
              <td style='border-right:#ccc solid 1px; border-left:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kmodel_number5."</td>
              <td style='font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;width:33%'>&nbsp;".$kquantity5."</td>
            </tr>
          </tbody>
      </table></td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>邮箱地址</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;<a title='发邮件给' href='mailto:".$kemail."'>".$kemail."</a></td>
    </tr>
    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>联系电话</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kmobile."</td>
    </tr>

    <tr>
      <th style='border-bottom:#ccc solid 1px; width:100px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px;'>订单说明</th>
      <td style='border-bottom:#ccc solid 1px; font-size:12px; padding:0 15px;color:#4d4d4d;height:35px; line-height:35px; border-left:#ccc solid 1px;'>&nbsp;".$kcontent."</td>
    </tr>
  </tbody>
</table>";		//邮件内容
	$mail->AltBody = "This is the body in plain text for non-HTML mail clients";	//邮件正文不支持HTML的备用显示
	
	if(!$mail->Send())
	{
	   //echo "{title:'OK',main:'成功发布留言 ',but:'确定',js:'',width:320,height:100}";
	   //echo "Mailer Error: " . $mail->ErrorInfo;
	   //exit;
	}
	
	kc_ajax('OK',$king->lang->get('ordersystem/ok/add'),$king->lang->get('system/common/enter'));//添加成功后返回的地址
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
	$count=$king->db->getRows_number('%s_ordersystem');
	
	$tmp=new KC_Template_class($king->config('templatepath').'/default.htm',$king->config('templatepath').'/inside/ordersystem/default.htm');
	
	$tmp->assign('title',$king->lang->get('ordersystem/name'));
	$tmp->assign('type','ordersystem');  //用于分页
	$tmp->assign('pid',$pid);
	$tmp->assign('rn',$rn);
	$tmp->assign('count',$count);
	
	echo $tmp->output();

}
?>