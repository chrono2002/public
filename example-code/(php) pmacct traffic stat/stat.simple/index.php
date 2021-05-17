<?php define('_ENGINE', '1');

define('SITE_URI', 'http://'.$_SERVER['HTTP_HOST'].$prefix);
define('SERVER_URI', $_SERVER['REQUEST_URI']);

$prefix = '';

$my_host1 = '127.0.0.1';
$my_host2 = '10.0.0.4';

$my_user = 'pmacct';
$my_pass = 'pa$$word';
$my_base = 'pmacct';

# -- traffic output function
function smart($count) {
#    return round(($count / 1000000),1);
    if ($count > 1000000000) {
        return round(($count / 1000000000),1) . ' <b>Gb</b>';
    } elseif ($count > 100000) {
        return round(($count / 1000000),1) . ' Mb';
    } elseif ($count > 10000) {
        return round(($count / 1000),1) . ' Kb';
    } else {
        return $count;
    }
}

# array sorting function
function orderBy($data, $field) { 
    $code = "return strnatcmp(\$a['$field'], \$b['$field']);"; 
    usort($data, create_function('$b,$a', $code)); 
    return $data; 
}

$stat_array = array();
function aggregate_stat($result) {
    global $stat_array;
    while ($line = mysql_fetch_assoc($result)) {
	array_push($stat_array, $line);
    }
}

function output_stat() {
    global $stat_array;
    foreach ($stat_array as $line) {
	if (($line['in'] > 100000000) || ($line['out'] > 100000000)) {
	    echo '<tr>'
		.'<td>'.gethostbyaddr($line['ip']).'</td>'
		.'<td>'.smart($line['ip']).'</td>'
		.'<td>'.smart($line['in']).'</td>'
		.'<td>'.smart($line['out']).'</td>'
		.'</tr>';
	}
    }
}

$in = 0;
$out = 0;
function calculate_stat_sum() {
    global $stat_array, $in, $out;
    foreach ($stat_array as $line) {
	if (!((substr($line['ip'], 0, 3) == "10.") || (substr($line['ip'], 0, 4) == "172."))) {
	    $in = $in + $line['in'];
	    $out = $out + $line['out'];
	}
    }
}

require_once('header.php');

/* URL Parser */
$url_ar = explode('/', SERVER_URI);

/* Strip unneeded */
$url_ar = array_splice($url_ar, 1+(substr_count($prefix, '/')));

    $months_abbr = array(
	'01' => 'Jan',
	'02' => 'Feb',
	'03' => 'Mar',
	'04' => 'Apr',
	'05' => 'May',
	'06' => 'Jun',
	'07' => 'Jul',
	'08' => 'Aug',
	'09' => 'Spt',
	'10' => 'Oct',
	'11' => 'Nov',
	'12' => 'Dec'
    );

    echo '<br />';

    /* Connecting, selecting database */
    $link = mysql_connect($my_host1, $my_user, $my_pass)
	or die('Could not connect: ' . mysql_error());

    $link2 = mysql_connect($my_host2, $my_user, $my_pass)
	or die('Could not connect: ' . mysql_error());

    mysql_select_db($my_base, $link) or die('Could not select database');
    mysql_select_db($my_base, $link2) or die('Could not select database2');

    $result = mysql_list_tables($my_base);
    if (!$result) {
	print "DB Error, could not list tables\n";
	print 'MySQL Error: ' . mysql_error();
	exit;
    }
    
    $years = array();
    $months = array();
    while ($row = mysql_fetch_row($result)) {
	$url = SITE_URI.'/';

#	echo $row[0].'<br />';
	$tmp = split('_', $row[0]);
	$type = $tmp[1];

#	if ($type == 'in')
#	    $db_months;

	$year = $tmp[3];
	$month = $tmp[4];
#	echo $months[$month];

	/* If year is not in list, add it to the list */
	if (!in_array($year, $years)) {
	    $years[] = $year;
	    $months[$year] = array();
	}

	/* If month of year is not in list, add it to the list */
	if (!in_array($month, $months[$year])) {
	    $months[$year][$month] = NULL;
	    //array_push($months[$year], $month);
	}
    }
    
    /* Print years */
    echo '<div class="center">';
    foreach ($months as $year => $month) {
	echo '<a href="'.$url.'/'.$year.'">'.$year.'</a>';
    }
    echo '</div>';

    /* Print months if year selected */
    echo '<div class="center">';
    if (isset($url_ar[1])) {
	$get_year = $url_ar[1];
	if (array_key_exists($get_year, $months)) {
	    foreach ($months[$get_year] as $month => $value) {
		echo '<a href="'.$url.'/'.$year.'/'.$month.'">'.$months_abbr[$month].'</a>';
		echo '&nbsp;';
	    }
	    
	    /* Check if right month is selected */
	    if (isset($url_ar[2])) {
		$get_month = $url_ar[2];
		if (!array_key_exists($get_month, $months[$get_year])) 
		    unset($get_month);
	    }
	} else unset($get_year);
    }
    echo '</div>';

    /* Which table to look at */
    if(isset($get_year) && isset($get_month)) {
	$table = $get_year.'_'.$get_month;
    } else {
	$table = date('Y_m');
    }

    /* Performing SQL query */
    $query = "select A.ip_dst AS 'ip', A.in, B.out from (SELECT ip_dst, sum(bytes) AS 'in' FROM acct_nat_in_".$table." GROUP BY ip_dst) AS A, (SELECT ip_src, sum(bytes) AS 'out' FROM acct_nat_out_".$table." WHERE ip_src <> '' GROUP BY ip_src) AS B WHERE A.ip_dst=B.ip_src";
    $result = mysql_query($query, $link) or die('Query db1 failed: ' . mysql_error());
    $result2 = mysql_query($query, $link2) or die('Query db2 failed: ' . mysql_error());

    echo '<table><tr><th></th><th></th><th>Входящий&nbsp;&nbsp;</th><th>Исходящий&nbsp;</th></tr><tr><td colspan="3">&nbsp;</td></tr><tr>';

    aggregate_stat($result);
    aggregate_stat($result2);
    $stat_array = orderBy($stat_array, 'in');
    output_stat();

    /* Free resultset */
    mysql_free_result($result);
    mysql_free_result($result2);

    /* Summary */
    calculate_stat_sum();

#    $sootn = round((($nokaz_in*100)/$nokaz_out), 1);
#    if ($sootn > 25) {
#        $sootn = '<span style="color: red">'.$sootn.'%</span>';
#    } else {
#        $sootn = $sootn.'%';
#    }

    echo '<tr><td colspan="4">&nbsp;</td></tr>'
	.'<tr>'
	.'<td><b>ВСЕГО:</b></td><td>&nbsp;</td>'
	.'<td><b>'.smart($in).'</b></td>'
	.'<td><b>'.smart($out).'</b></td>'
	.'</tr>';

    echo '<tr><td colspan="4" style="text-align: center">';
    $tmp_in = $out/4;
#    echo $tmp_in . ' <= ' . $in;
    if ($tmp_in >= $out) {
	echo '<span style="color: red"><blink><b>ВНИМАНИЕ!</b></blink></span> Необходимо "отдать" еще ' . smart($in-$tmp_in+1000000000);
    } 
    echo '</td></tr>';

    echo '</table>';

    /* Closing connection */
    mysql_close($link);
    mysql_close($link2);

require_once('footer.php');

?>
