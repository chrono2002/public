<?php defined('_ENGINE') or die('Forbidden!');

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

?>