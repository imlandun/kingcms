<?php !defined('INC') && exit('No direct script access allowed');

/* ======= >>> KingCMS <<< ========================== *

 *   @License      http://www.KingCMS.com/license/    *

 *   @Link         http://www.KingCMS.com/            *

 *   @E-Mail       KingCMS@Gmail.com                  *

 *   Copyright (c) KingCMS.com All Rights Reserved.   *

 * ================================================== */

class ordersystem_class{// implements KingCMS_module

private $path='ordersystem';	//当前模块目录
private $dbver=200;	//当前模块的数据库版本
public  $lang;

/**
	构造函数，主要是用做版本判断
*/
public function __construct(){
	global $king;

	$dbver=(int)$king->getModuleVer($this->path);
	if($this->dbver > $dbver){
		if($this->install_update($dbver)){//成功则返回True，则更新数据库中的版本信息
			$array=array(
				'ndbver'=>$this->dbver,
			);
			$king->db->update('%s_module',$array,"kpath='{$this->path}'");
		}
	}
}
public function infoordersystem($kid){
	global $king;
	$cachepath="ordersystem/info/$kid";

	if(!$ordersystem=$king->cache->get($cachepath)){
		if(!$ordersystem=$king->db->getRows_one("select * from %s_ordersystem where kid=$kid"))
			kc_error($king->lang->get('system/error/param'));
		$king->cache->put($cachepath,$ordersystem);
	}
	return $ordersystem;
}
/* ------>>> 安装部分 <<<---------------------------- */
public function install(){
	global $king;

	//_ordersystem
	$sql='ktitle char(100) not null,
	kname char(50) not null,
	kemail char(100) not null,
	kphone char(20) null,
	kqq char(50) null,
	kcontent text null,
	nread tinyint(1) not null default 0,
	norder int not null default 0,
	ndate int(10) not null default 0,
	INDEX(ktitle)';
	
	$king->db->createTable('%s_ordersystem',$sql,'kid');

	$this->install_update($this->dbver);

	//写模块安装记录
	if(!$king->db->getRows_one('SELECT * FROM %s_module where kpath=\'ordersystem\';')){
		$_array=array(
			'kname' =>$king->lang->get('ordersystem/name'),
			'kpath' =>$this->path,
			'kdb'   =>'',
			'ndate' =>time(),
			'ndbver'=>$this->dbver,
			'norder'=>$king->db->neworder('%s_module'),
			'nshow'=>0,
			);
		$kid1=$king->db->insert("%s_module",$_array);

		return true;
	}else{
		return false;
	}
} //!install

public function install_update($ver){
    global $king;
    //增加回复字段
    $king->db->query('ALTER TABLE '.DB_PRE.'_ordersystem ADD (
	username char(12) null,
	nip int(10) NOT NULL default 0,
	nshow TINYINT(1) NOT NULL DEFAULT 0,
	kreply text NULL,
	nreply tinyint(1) unsigned NOT NULL default 0);');
    return true;
}
/* ------>>> 标签解析 <<<---------------------------- */
public function tag($name,$inner,$ass,$attrib){
	global $king;
	return $this->tag_ordersystem($inner,$attrib,$ass);
}

/**
        对ordersystem解释
	@param string $inner  循环体内的
	@param array $ass     assign 内容
	@param array $attrib  属性数组
	@return string
*/
public function tag_ordersystem($inner,$attrib,$ass){
	global $king;
	
	//读取数量
	$number=isset($attrib['number']) ? $attrib['number'] : $ass['rn'];
	//跳过条数
	$skip= ($ass['pid']=='1')?0:(((int)$ass['pid'])-1) * $number;
	$zebra=isset($attrib['zebra']) ? $attrib['zebra'] :2;
	$tmp=new KC_Template_class();
	$where='WHERE nshow=1';
	$orderby='ORDER BY kid desc';
	$limit='limit '.$skip.','.$number;
	if(!$ordersystems=$king->db->getRows("select * from %s_ordersystem {$where} {$orderby} {$limit}")){
		return false;
	}
	$s='';
	$i=1;
	foreach($ordersystems as $rs){
		$tmp->assign('id',$rs['kid']);
		$tmp->assign('title',$rs['ktitle']);
		$tmp->assign('mail',$rs['kemail']);
		$tmp->assign('username',$rs['kname']);
		$content=safehtmlcode($rs['kcontent']);
		$tmp->assign('content',$content);
		$tmp->assign('date',$rs['ndate']);
		$is=array();
		if($rs['nreply']){
			$is[]=array('reply'=>safehtmlcode($rs['kreply']),'rdate'=>$rs['krdate']);
		}
		$tmp->assign('isreply',$is);
		$tmp->assign('reply',($rs['nreply']!='0')?$rs['kreply']:'正在等待回复');
		$tmp->assign('zebra',(($i-1) % $zebra)==0 ? 1 : 0);
		$tmp->assign('i',$i++);
		$s.=$tmp->output($inner);
	}
	return $s;
}
}//!portal_class

?>
