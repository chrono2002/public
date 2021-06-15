<?php defined('_ENGINE') or die('Forbidden!');

define('SITE_URI', 'http://'.$_SERVER['HTTP_HOST'].$prefix);
define('SERVER_URI', $_SERVER['REQUEST_URI']);

$prefix = '';

$my_user = 'pmacct';
$my_pass = 'pa$$word';
$my_base = 'pmacct';

class Hosts {
    var $elements = array();
    
    function add_host($name, $ip, $statistic, $monit, $cyradm) {
	$last = count($this->elements);

	$this->elements[$last]['name'] = $name;
	$this->elements[$last]['ip'] = $ip;

	if ($monit == 1)
	    $this->elements[$last]['monit'] = $monit;
	
	if (is_array($statistic)) {
	    $this->elements[$last]['sql_host'] = $statistic[0];
	    $this->elements[$last]['sql_port'] = $statistic[1];
	}

	if ($cyradm == 1)
	    $this->elements[$last]['cyradm'] = 1;
    }

    function print_hosts($num=NULL, $service=NULL) {
	$hosts = $this->elements;

	/* Hosts */
	echo '<div class="center">';
	$count = count($hosts);
	
	foreach ($hosts as $key => $host) {
	    if (is_numeric($num) && ($key == $num))
		echo $host['name'];
	    else
		echo '<a href="'.SITE_URI.$prefix.'/'.$key.'">'.$host['name'].'</a>';
	    if (($key+1) != $count) echo ' &middot; ';
	}
	echo '</div>';

	if (is_numeric($num)) {

	    $host = $this->elements[$num];
	    $services = array();
	    echo '<div class="center">[&nbsp;';

	    /* Stats */
	    if (isset($host['sql_host']))
#		if ($service == 'stats') 
#		    $services[] = 'stats';
#		else
		    $services[] = '<a href="'.SITE_URI.'/'.$num.'/stats">stats</a>';

	    /* Monit */
	    if ($host['monit']) {
		if ($service == 'monit') {
		    $services[] = 'monit';
		} else {
		    $services[] = '<a href="'.SITE_URI.'/'.$num.'/monit">monit</a>';
#		    $services[] = '<a href="http://'.$host['ip'].':2812">monit</a>';
		}
	    }

	    if (isset($host['cyradm']))
		$services[] = '<a href="'.SITE_URI.'/cyradm">cyradm</a>';
#		$services[] = '<a href="'.SITE_URI.'/'.$num.'/cyradm">cyradm</a>';
#		if ($service == 'stats') 
#		    $services[] = 'stats';
#		else
#		    $services[] = '<a href="'.SITE_URI.'/'.$num.'/stats">stats</a>';

	    echo implode($services, '&nbsp;&middot;&nbsp;');
	    echo '&nbsp;]</div>';
	}
    }
}								

#$hosts = new Hosts;
#$hosts->add_host('liro', '192.168.23.1', array('127.0.0.1', '3306'), 1, 1);
#$hosts->add_host('mainrouter', '81.1.254.9', array('127.0.0.1', '3307'), 1);

?>
