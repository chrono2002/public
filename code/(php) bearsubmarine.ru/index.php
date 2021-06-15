<?php
	require_once('functions.php');

	$engine_url = 'http://' . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI'] ;
	$engine_description = 'Подборка наиболее значимых и ярких компьютерных и видеоигр за всю историю развития игровой индустрии. Гениальные, а также просто занимательные игры которые не обыдляют. Видеоигры с позиции здорового человека а не игромана.';

	/* URL specific magic */

	if (strpos($_SERVER['REQUEST_URI'], '/games/') !== false) {
		$page = 'blog';
	} else {
		if (strpos($_SERVER['REQUEST_URI'], '/page/') !== false) {
			$url_array = explode('/', $_SERVER['REQUEST_URI']);
			if (is_numeric($url_array[2]) && ($url_array[2] != 0)) $pagenum = $url_array[2];
			else	{ http_response_code(404); die; }
		}
		$page = 'index';
	}

	/* Connect to MySQL */
	
	require_once('db_connect.php');
	
	/* Fetch total number of games 4 paginator */
	
	$result = $mysqli->query('select count(*) as games_num from games');
	$array = $result->fetch_all(MYSQLI_ASSOC);
	$result->free();
	$games_num = $array[0]['games_num'];
	
//	$result = $mysqli->query("select games.*, isos.iso_url from games left join isos on (isos.game_id=games.id) order by timestamp desc");
//	$result = $mysqli->query("select games.*, isos.iso_url, article_text from games left join isos on (isos.game_id=games.id) left join articles_new on (articles_new.game_id=games.id) order by timestamp desc");
//	select games.*, isos.iso_url, article_text from games left join isos on (isos.game_id=games.id) left join articles_new on (articles_new.game_id=games.id) order by timestamp desc limit 1;
//	$result = $mysqli->query("select games.*, isos.iso_url, articles.article_text from games left join isos on (isos.game_id=games.id) left join articles on articles.game_id=games.id order by timestamp desc");

	/* Paginator */

	$mysql_suffix = '';
	if ($page == 'index') {
		$mysql_suffix = 'limit ';
		$pages_num = floor($games_num / $games_per_page);
		if (($games_num % $games_per_page) >= $min_games_on_first_page) $games_on_first_page = $games_num % $games_per_page;
		else $games_on_first_page = $games_per_page + ($games_num % $games_per_page);

		if (isset($pagenum)) {
//			$pagenum = $pagenum - 1;
			$pagenum = $pages_num - $pagenum;
			if ($pagenum <= $pages_num) {
				$position = ($games_per_page * $pagenum) + ($games_num % $games_per_page);
				$mysql_suffix .=  $position . ',' . $games_per_page;
				$previous_page = $pages_num - $pagenum - 1;
				$next_page = $pages_num - $pagenum + 1;
				if ($next_page > $pages_num) $next_page = NULL;
				if ($previous_page == 0) $previous_page = NULL;
			} else {
				http_response_code(404); die;
			}
		} else {
			$mysql_suffix .= '0,' . $games_on_first_page;
//			$previous_page = $pages_num;
			$previous_page = $pages_num - 1;
			$next_page = NULL;
		}
	}
	
//	echo 'previous page: ' . $previous_page . '; next page = ' . $next_page;
		
	/* Fetch games */

	$result = $mysqli->query('select games.*, isos.iso_url, (SELECT COUNT(id) FROM articles_new where articles_new.game_id=games.id) as articles_count, buy.* from games left join isos on (isos.game_id=games.id) left join buy on (buy.game_id=games.id) order by timestamp desc ' . $mysql_suffix);
	
	while($row = $result->fetch_array(MYSQLI_ASSOC)) {
		$games_array[urlify($row["name"])] = $row;
	}
//	$games_array = $result->fetch_all(MYSQLI_ASSOC);
	$result->free();
//	print_r($games_array); die;

	/* Check game existence */

	$article_array = NULL;
	$title = 'Медвежья подводная лодка: служба доставки гениальных игр';
	if ($page == 'blog') {
		$url_array = explode('/', $_SERVER['REQUEST_URI']);
		if (isset($url_array[2]) && (isset($games_array[urlify($url_array[2])]))) {
			$game = $games_array[urlify($url_array[2])];
			unset($games_array);
			$games_array[0] = $game;
			if ($game["name"] != $game["header"]) $title = $game["name"] . ' · ' . $game["header"];
			else $title = $game["name"];
			$title .= ' | Медвежья подводная лодка';
			
			/* Fetch game article */
			
			$result = $mysqli->query('select articles_new.*, authors.author_name, authors.author_image, authors.author_url, press.*, art.* from articles_new left join authors on (authors.id=articles_new.author_id) left join press on (press.press_id=articles_new.press_id) left join art on (art.art_id=articles_new.art_id) where game_id='.$game['id']);
			$article_array = $result->fetch_all(MYSQLI_ASSOC);
			$result->free();

			/* Fetch similar games */
			
			$result = $mysqli->query('select games.name, similar.* from similar left join games on (games.id = similar.game_id) where game_id='.$game['id']);
			$similar_array = $result->fetch_all(MYSQLI_ASSOC);
			$result->free();
			
			if (isset($article_array[0]['press_url'])) $page = 'article';
		} else {
			http_response_code(404);
			die;
		}
	}

	/* Fetch games platforms */
	
	$result = $mysqli->query("select games_platforms.game_id, games_platforms.game_url, platforms.short_name, platforms.name, platforms.title, platforms.url from games_platforms inner join platforms on games_platforms.platform_id=platforms.id order by games_platforms.id");
	$games_platforms_array = $result->fetch_all(MYSQLI_ASSOC);
	$result->free();

	// enumerate mysql array here for paginator
	
//	$result = $mysqli->query("select * from articles");
//	while($row = $result->fetch_array(MYSQLI_ASSOC)) {
//		$games_articles_array[$row["game_id"]] = $row["article_text"];
//	}
//	$games_articles_array = $result->fetch_all(MYSQLI_ASSOC);
//	$result->free();
//	print_r($games_articles_array); die;
	
	$mysqli->close();
?>

<html>
<head>
    <title><?php echo $title; ?></title>

    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	
<!--	<meta name="viewport" content="width=device-width, initial-scale=1"> -->

	<meta property="og:title" content="<?php echo $title; ?>">
	<meta property="og:type" content="website">
	<meta property="og:url" content="<?php echo $engine_url; ?>">
	<meta property="og:site_name" content="Медвежья подводная лодка">
	<meta property="og:locale" content="ru_RU">
	<?php 
		if (isset($game['trailer_text'])) $engine_description = htmlspecialchars(strip_tags($game['trailer_text']));
		elseif (isset($article_array[0]['article_text'])) $engine_description = html_entity_decode(strip_tags($article_array[0]['article_text']));
	
		echo '<meta name="description" content="' . $engine_description . '">' . "\n"; 
		echo "\t". '<meta property="og:description" content="' . $engine_description . '">' . "\n";
			
//		if ($page == 'blog') {
		if (isset($game['trailer_picture'])) echo '<meta property="og:image" content="http://bearsubmarine.ru/images/games/' . $game['trailer_picture'] . '">' . "\n"; 
		else	echo '<meta property="og:image" content="http://bearsubmarine.ru/images/bearsubmarine-02.jpg">' . "\n"; 
			// http://bearsubmarine.ru/images/bearsubmarine-02.jpg
//		}
	?>
		
    <link rel="stylesheet" href="/static/foundation/css/foundation.min.css" />
	<script type="text/javascript" src="/static/foundation/js/vendor/modernizr.js"></script>
	
    <script type="text/javascript" src="/static/jquery/dist/jquery.min.js"></script>
    <script type="text/javascript" src="/static/jquery-migrate/jquery-migrate.min.js"></script>

    <script type="text/javascript" src="/static//jquery.fitvids/jquery.fitvids.js"></script>
    <script type="text/javascript" src="/static/masonry/dist/masonry.pkgd.min.js"></script>
    <script type="text/javascript" src="/static/imagesloaded/imagesloaded.pkgd.min.js"></script>
    
    <link href="/static/bearsubmarine.css" rel="stylesheet" type="text/css" />

	<?php if(isset($article_array)) echo '<link href="/static/slick/slick.css" rel="stylesheet" type="text/css" />'; ?>
	<script type="text/javascript" src="/static/bearsubmarine.js"></script>
	
<!--	<script type="text/javascript" src="//vk.com/js/api/openapi.js?127"></script> -->
</head>

<?php 
	echo '<body class="';

	switch ($page) {
		case 'index':
			echo 'blog';
		case 'article':
			echo 'article';
	}	

	if (isset($game['wallpaper'])) echo '" style="background-image: url(/images/wallpapers/'.$game['wallpaper'].');"';
	else echo '" style="background-image: url(/images/wallpapers/'.randombg().');"';

	echo '>';
?>

<div id="header">
    <div id="header_content" class="condensed">
	<a href="/"><img src="/images/bearsubmarine-logo-03.png" /></a>
	</div>
</div>

<?php
	switch ($page) {
		case 'article':
			echo '<div id="article">';
			print_article($game, create_platform_list_for_game($games_platforms_array, $game["id"]), $article_array, $similar_array, $count, $page);
			echo '</div>';
			echo '<script type="text/javascript">$(\'.youtube_music\').fitVids();</script>';
			break;
		default:
			echo '<div class="';
			if ($page == 'blog')
				echo 'grid full';
			else
				echo 'grid';
			echo '">';
			$count = 0;
			foreach ($games_array as $game) {
				echo ' <div class="grid-sizer"></div>';
//				if (isset($game['trailer_text'])) 
				print_grid_item($game, create_platform_list_for_game($games_platforms_array, $game["id"]), $article_array, $count, $page);
//				else echo '<div class="grid-item grid-item--width2"><div class="grid-container"><img src="/images/games/'.$game['trailer_picture'].'" /></div></div>';
//				print_grid_item($game, create_platform_list_for_game($games_platforms_array, $game["id"]), $article_array, $count, $page);
				$count = $count + 1;
			}
			echo '</div><br />';

			echo '<div class="paginator" style="width: 100%">';
			if (isset($previous_page)) echo '<span><nobr><a href="/page/'.$previous_page.'">‹‹ Предыдущая страница</a></nobr></span>&nbsp; &nbsp; &nbsp;';
//			if ($pagenum == 1) echo '<span><nobr><a href="/">Следующая страница ››</a></nobr></span>';
			if (isset($pagenum) && ($pagenum <= 1)) echo '<span><nobr><a href="/">Следующая страница ››</a></nobr></span>';
			elseif (isset($next_page)) echo '<span><a href="/page/'.$next_page.'">Следующая страница ››</a></span>';
			echo '</div>';
			
			if ($page == 'index') {?><script type="text/javascript">
			   var $container = $('.grid'); 
			   $(function(){ 
					$container.imagesLoaded(function() { 
						$container.masonry({
							itemSelector: '.grid-item',
							columnWidth: '.grid-sizer',
							percentPosition: true
						});
					});
				});
			</script><?php }
			
/*			echo '<div id="article">';
			eval($game_article);
			echo '</div>'; */
	}	
?>

<div id="footer">
<img style="float: left; height: 200px; width: auto" src="/images/bearsubmarine-left.png" />
<img style="float: right; height: 200px; width: auto" src="/images/bearsubmarine-right.png" />

<div class="col" style="width: 60%"><div class="title">НАШИ ДРУЗЬЯ</div>
<div id="about">
	<div><a href="http://toucharcade.com/" title="Touch Arcade: iPhone Game Reviews and News"><img src="/images/toucharcade.png" /></a></div>
	<div><a href="http://www.ign.com/" title="Video Games, Wikis, Cheats, Walkthroughs, Reviews, News & Videos - IGN"><img src="/images/ign.png" /></a></div>
	<div><a href="http://www.gamespot.com/" title="Video Games Reviews & News - GameSpot"><img src="/images/gamespot.png" /></a></div>
	<div><a href="http://www.eurogamer.net/" title="Eurogamer.net • Video game reviews, news, previews, forums and videos"><img src="/images/eurogamer.jpg" /></a></div>
	<div><a href="http://www.rockpapershotgun.com/" title="Rock, Paper, Shotgun - PC Game Reviews, Previews, Subjectivity"><img src="/images/rock-paper-shotgun.png" /></a></div>
	<div><a href="http://www.ag.ru/" title="Игровой портал AG.ru — Всё о компьютерных играх!"><img src="/images/ag-ru.jpg" /></a></div>
	<div><a href="http://www.rpgamer.com/" title="RPGamer - You're like the omega weapon of innkeepers."><img src="/images/rpgamer.png" /></a></div>
	<div><a href="http://homeoftheunderdogs.net/" title="Home of the Underdogs"><img src="/images/hotu.png" /></a></div>
	<div style="height: 50px; width: 140px;"><a href="http://www.hardcoregaming101.net/" title="Hardcore Gaming 101: Promoting the rich history of video game culture throughout the ages"><img src="/images/hg101.png" /></a></div>
</div></div>
<div class="col"><div class="title">ПОМОЧЬ САЙТУ</div>
<iframe frameborder="0" allowtransparency="true" scrolling="no" src="https://money.yandex.ru/embed/donate.xml?account=41001261680327&quickpay=donate&payment-type-choice=on&mobile-payment-type-choice=on&default-sum=50&targets=%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%BA%D0%B0+%D1%81%D0%B0%D0%B9%D1%82%D0%B0&project-name=&project-site=&button-text=05&successURL=" width="508" height="64"></iframe>
</div>
<div class="col"><div class="title">КОНТАКТЫ</div>

<!-- <div id="vk_contact_us"></div>
<script type="text/javascript">
VK.Widgets.ContactUs("vk_contact_us", {redesign: 1, height: 30}, 265210323);
</script> -->

<script type="text/javascript" src="//vk.com/js/api/openapi.js?130"></script>

<!-- VK Widget -->
<div id="vk_groups"></div>
<script type="text/javascript">
VK.Widgets.Group("vk_groups", {mode: 3, width: "200", height: "400", color1: 'FFFFFF', color2: '000000', color3: '5E81A8'}, 128657292);
</script>
</div>

<div style="clear: both"></div>
</div>

<!-- Yandex.Metrika counter --> <script type="text/javascript"> (function (d, w, c) { (w[c] = w[c] || []).push(function() { try { w.yaCounter39648960 = new Ya.Metrika({ id:39648960, clickmap:true, trackLinks:true, accurateTrackBounce:true }); } catch(e) { } }); var n = d.getElementsByTagName("script")[0], s = d.createElement("script"), f = function () { n.parentNode.insertBefore(s, n); }; s.type = "text/javascript"; s.async = true; s.src = "https://mc.yandex.ru/metrika/watch.js"; if (w.opera == "[object Opera]") { d.addEventListener("DOMContentLoaded", f, false); } else { f(); } })(document, window, "yandex_metrika_callbacks"); </script> <noscript><div><img src="https://mc.yandex.ru/watch/39648960" style="position:absolute; left:-9999px;" alt="" /></div></noscript> <!-- /Yandex.Metrika counter -->
</body>
</html>
