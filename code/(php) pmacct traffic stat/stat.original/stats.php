<?php defined('_ENGINE') or die('Forbidden!');
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
#    echo '<h4>'.$host['name'].'</h4>';

    /* Connecting, selecting database */
    $link = mysql_connect($host['sql_host'].':'.$host['sql_port'], $my_user, $my_pass)
	or die('Could not connect: ' . mysql_error());

    mysql_select_db($my_base) or die('Could not select database');

    $result = mysql_list_tables($my_base);
    if (!$result) {
	print "DB Error, could not list tables\n";
	print 'MySQL Error: ' . mysql_error();
	exit;
    }
    
    $years = array();
    $months = array();
    while ($row = mysql_fetch_row($result)) {
	$url = SITE_URI.'/'.$service;

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
    $result = mysql_query($query) or die('Query failed: ' . mysql_error());

#    echo '<table><tr><th>IP</th><th>IN (mb)&nbsp;</th><th>OUT (mb)</th></tr>';
    echo '<table><tr><th></th><th>Входящий&nbsp;&nbsp;</th><th>Исходящий&nbsp;&nbsp;</th></tr><tr><td colspan="3">&nbsp;</td></tr><tr>';
    while ($line = mysql_fetch_object($result)) {
	echo '<tr>'
	    .'<td>'.$line->ip.'</td>'
	    .'<td>'.smart($line->in).'</td>'
	    .'<td>'.smart($line->out).'</td>'
	    .'</tr>';
    }
#    echo '</table>';

    /* Free resultset */
    mysql_free_result($result);

    /* Summary */
    $query = 'select * from (select sum(bytes) AS "in" from acct_nat_in_'.$table.') AS A, (select sum(bytes) as "out" from acct_nat_out_'.$table.') AS B';
    $result = mysql_query($query) or die('Query failed: ' . mysql_error());
    while ($line = mysql_fetch_object($result)) {
	echo '<tr><td colspan="3">&nbsp;</td></tr>'
	    .'<tr>'
	    .'<td><b>TOTAL:</b></td>'
	    .'<td><b>'.smart($line->in).'</b></td>'
	    .'<td><b>'.smart($line->out).'</b></td>'
	    .'</tr>';
    }
    echo '</table>';

    /* Free resultset */
    mysql_free_result($result);

    /* Closing connection */
    mysql_close($link);
?>