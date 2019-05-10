<?php

define(‘KC_ROOT’,dirname(__FILE__).‘/’);

define(‘KC_IN’,True);

define(‘KC_DB_PR

<?php

define(‘KC_ROOT’,dirname(__FILE__).‘/’);

define(‘KC_IN’,True);

define(‘KC_DB_PREFIX’,”);

require_once KC_ROOT.‘config.php’;

require_once KC_ROOT.’system/lib/kc.func.php’;

require_once KC_ROOT.’system/lib/mysql.class.php’;

$cats = $_GET['cats'];

$url = $_GET['url'];

$pid=$_GET['pid']? $_GET['pid'] :1;

//每页返回条数

$rn=isset( $_GET['rn'] ) ? $_GET['rn'] :9;

$db = new KC_mysql_class();

$reccount = $db->getRows(“select count(*) as cnt from my__product where listid in($cats)”);

$reccount = $reccount[0]['cnt'];

//查询数据库记录

$data = $db->getRows(“select kid,ktitle,kimage,kpath from my__product where listid in($cats) limit “ . ($pid-1)*$rn . “,$rn“);

//输出产品,如果要调用别的内容，在这里加上数据库里的字段名.

foreach( $data as $it ){

//输出产品的展示样式 这里可以自己定义

echo ‘<li><a href=”../../’ .

$it['kpath'].‘”><img src=”/’ .

$it['kimage'] .

‘” width=”160″ height=”120″ border=”0″  alt=”‘.

$it['ktitle'].

‘” /></a><p><a href=”../../’.

$it['kpath'].‘”>’ .

$it['ktitle'] .

‘</a></p></li>’;

}

$pages = ceil( $reccount / $rn );

echo ‘<div class=pagelist style=”text-align:right”>’;

if( $pid>1 ) echo ‘<a href=”‘ .$url . ‘?pid=’ . ( $pid-1 ) . ‘&rn=’ . $rn . ‘”><<上一页</a>’;

echo ‘&nbsp;&nbsp;&nbsp;&nbsp;’;

if( $pid<$pages ) echo ‘<a href=”‘ .$url . ‘?pid=’ . ( $pid+1 ) . ‘&rn=’ . $rn . ‘”>下一页>></a>’;

echo ‘</div>’;

?>

EFIX’,”);

require_once KC_ROOT.‘config.php’;

require_once KC_ROOT.’system/lib/kc.func.php’;

require_once KC_ROOT.’system/lib/mysql.class.php’;

$cats = $_GET['cats'];

$url = $_GET['url'];

$pid=$_GET['pid']? $_GET['pid'] :1;

//每页返回条数

$rn=isset( $_GET['rn'] ) ? $_GET['rn'] :9;

$db = new KC_mysql_class();

$reccount = $db->getRows(“select count(*) as cnt from my__product where listid in($cats)”);

$reccount = $reccount[0]['cnt'];

//查询数据库记录

$data = $db->getRows(“select kid,ktitle,kimage,kpath from my__product where listid in($cats) limit “ . ($pid-1)*$rn . “,$rn“);

//输出产品,如果要调用别的内容，在这里加上数据库里的字段名.

foreach( $data as $it ){

//输出产品的展示样式 这里可以自己定义

echo ‘<li><a href=”../../’ .

$it['kpath'].‘”><img src=”/’ .

$it['kimage'] .

‘” width=”160″ height=”120″ border=”0″  alt=”‘.

$it['ktitle'].

‘” /></a><p><a href=”../../’.

$it['kpath'].‘”>’ .

$it['ktitle'] .

‘</a></p></li>’;

}

$pages = ceil( $reccount / $rn );

echo ‘<div class=pagelist style=”text-align:right”>’;

if( $pid>1 ) echo ‘<a href=”‘ .$url . ‘?pid=’ . ( $pid-1 ) . ‘&rn=’ . $rn . ‘”><<上一页</a>’;

echo ‘&nbsp;&nbsp;&nbsp;&nbsp;’;

if( $pid<$pages ) echo ‘<a href=”‘ .$url . ‘?pid=’ . ( $pid+1 ) . ‘&rn=’ . $rn . ‘”>下一页>></a>’;

echo ‘</div>’;

?>