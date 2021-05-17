<?php
	require_once('functions.php');

    require_once('db_connect.php');
	$result = $mysqli->query('select name, timestamp from games order by timestamp desc');
	$games_array = $result->fetch_all(MYSQLI_ASSOC);
	$result->free();
    $mysqli->close();
	
	$urls_array = [];
	array_push($urls_array, '/');

	$games_num = count ($games_array);
	$pages_num = floor($games_num / $games_per_page)-1;
//	$pages_num = floor($games_num / $games_per_page);

	for ($i=1; $i<=$pages_num; $i++) {
		array_push($urls_array, '/page/' . $i);
	}
	
	foreach ($games_array as $game) {
		array_push($urls_array, '/games/' . urlify($game['name']));
	}
	
	$lastmod = '2016-09-16';
//	substr($games_array[count($games_array)-1]['timestamp'], 0,10);
//	print_r($urls_array); die;

	header("Content-type: text/xml");
	
    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';

	foreach ($urls_array as $url) {
		echo '<url>';
		echo '<loc>http://bearsubmarine.ru' . $url . '</loc>';
		echo '<lastmod>' . $lastmod . '</lastmod>';
		echo '<changefreq>daily</changefreq>';
		echo '<priority>1</priority>';
		echo '</url>';
	}
	
    echo '</urlset>';
?>