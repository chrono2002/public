<?php define('_ENGINE', '1');

require_once('config.php');
require_once('functions.php');
require_once('header.php');

/* URL Parser */
$url_ar = explode('/', SERVER_URI);

/* Strip unneeded */
$url_ar = array_splice($url_ar, 1+(substr_count($prefix, '/')));

$service = '';
$host['sql_host']='127.0.0.1';
$host['sql_port']=3306;

require_once('stats.php');
require_once('footer.php');

?>
