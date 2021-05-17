<?php 

$games_per_page = 6;
$min_games_on_first_page = 3;

function urlify($string) {
	$string = str_replace('&', 'and', $string);
	$string = str_replace('\'', '', $string);
	$string = str_replace(':', '', $string);
	$string = strtolower(preg_replace("/[^a-zA-Z0-9]/", "-", $string));
	return $string;
}

function create_platform_list_for_game($games_platforms_array, $game_id) {
    $new_array = array();
    foreach ($games_platforms_array as $entry) {
	if ($entry["game_id"] == $game_id) array_push($new_array,$entry);
    }
    return $new_array;
}

function print_article($game, $platforms_array, $article_array = NULL, $similar_array = NULL, $count, $page) {
		$count = 0;
		foreach ($article_array as $entry) {

			/* press quote */
			if (isset($entry['press_url'])) {
				if ($count == 0) template_article_quote_press($entry['article_text'], $entry['press_image'], $entry['press_url'], $entry['press_name'], 1);
				else template_article_quote_press($entry['article_text'], $entry['press_image'], $entry['press_url'], $entry['press_name']);

			/* screenshot */
			} elseif(isset($entry['screenshot'])) {
				if (isset($entry['screenshot_url'])) template_article_screenshot($entry['screenshot'], $entry['screenshot_url']);
				else template_article_screenshot($entry['screenshot']);

			/* youtube */
			} elseif (isset($entry['youtube_id'])) {
				if (isset($entry['youtube_image'])) template_article_youtube_wrapper($entry["youtube_id"], '/images/' . $entry["youtube_image"], $entry["youtube_button_black"], $page);
				else template_article_youtube_music($entry['youtube_id']);
			}

			elseif (isset($entry['author_name'])) template_article_quote_author($entry);
			elseif (isset($entry['article_text'])) template_article_quote_press($entry['article_text']);
			elseif($entry['art_id'] > 0) template_article_slider(urlify($game['name']), $entry['art_size'], $entry['art_name'], array_map('str_getcsv', str_getcsv($entry['art_csv'],"\n")));

			$count = $count+1;
		}

		/* Buy */
		for ($i = 0; $i < count($platforms_array); $i++) $platforms_array2[$platforms_array[$i]['name']] = $platforms_array[$i];
		template_article_buy($platforms_array2);

		/* Similar */
		if (count($similar_array) > 0) template_article_same_as($similar_array);
}

function print_grid_item($game, $platforms_array, $article_array = NULL, $count, $page) {
	$h1_style='';
	if ($page == 'blog')
		echo '<div class="grid-item-full">';
	elseif (isset($game['trailer_text']))
		echo '<div class="grid-item">';
	else
		echo '<div class="grid-item grid-item--width2">';
	
	echo '<div class="grid-container">';
    echo '<div class="grid-header">';

    if (isset($game["metascore"])) {
	if ($game["metascore"] >= 75) {
	    $meta_color='#6c3';
	} else {
	    $meta_color='#fc3';
	}
	echo '<a class="nostyle" href="'. $game["metalink"] . '"><div class="metascore" title="Средний рейтинг игры" style="background-color: '. $meta_color .'">' . $game["metascore"] . '</div></a>';
    }
    
	if (isset($game["is_collection"])) $name = $game["header"];
	else $name = $game["name"] . ' &middot; ' . $game["header"];

	if (isset($article_array) || ($game["articles_count"] == 0)) echo '<h1>' . $name . '</h1>';
	else echo '<h1><a href="' . '/games/'. urlify($game["name"]) . '">' . $name . '</a></h1>';
//	elseif(isset($game['trailer_text'])) echo '<h1><a href="' . '/games/'. urlify($game["name"]) . '">' . $name . '</a></h1>';
//	else echo '<h1>' . $name . '</h1>';
	
    echo '</div>';
	
    echo '<div class="grid-content">';

	if ($page == 'blog') {
		echo '<p>' . $game["trailer_text"] . '</p>';
		template_article_youtube_wrapper($game["trailer_youtube_id"], '/images/games/' . $game["trailer_picture"], $game["trailer_button_black"]);
		foreach ($article_array as $entry) {
			if (isset($entry['youtube_image'])) template_article_youtube_wrapper($entry["youtube_id"], '/images/' . $entry["youtube_image"], $entry["youtube_button_black"]);
//			elseif (isset($entry['author_name'])) template_article_quote_author($entry['article_text'], $entry['author_name'], $entry['author_image'], $entry['interview_url'], $entry['author_url']);
			elseif (isset($entry['author_name'])) template_article_quote_author($entry);
			else echo '<p>'.$entry['article_text'].'</p>';
		}
	} else {
		if (isset($game['trailer_text'])) {
			template_article_youtube_wrapper($game["trailer_youtube_id"], '/images/games/' . $game["trailer_picture"], $game["trailer_button_black"]);
			echo '<div class="preview">' . $game["trailer_text"] . '<br /><br />';
			if ($game["articles_count"] > 0) echo '<div class="more"><a href="/games/'. urlify($game["name"]) .'">Читать дальше &rarr;</a></div>';
			echo '</div>';
		} else {
			echo  '<a href="/games/' . urlify($game["name"]) . '"><img alt="[Картинка игры]" title="Перейти к обзору игры" src="/images/games/' . $game['trailer_picture'] . '" class="youtube_preview" /></a>';
		}
	}
    
    echo '<div class="prate"><span title="Рекомендуемый возраст">' . $game["rate"] . '+</span>';
	
//	echo '<pre>'; print_r($platforms_array);
    echo '<div class="platform">';
    for ($x = 0; $x < count($platforms_array); $x++) {		
		echo '<span><a href="';
		if (isset($platforms_array[$x]["game_url"])) {
			echo $platforms_array[$x]["game_url"];
		} else {
			echo $platforms_array[$x]["url"];
		}
		echo '" title="'. $platforms_array[$x]["title"] .'">' . $platforms_array[$x]["short_name"] . '</a></span>';
		if (($platforms_array[$x]["short_name"] == "Эмулятор") && (isset($game["iso_url"]))) {
			echo ' + <a href="'. $game["iso_url"] .'" title="Скачать образ игры для эмулятора">Образ</a>';
		}
		if (isset($platforms_array[$x+1])) echo ' &middot; ';
    }
    echo '</div></div>';
    echo '</div></div></div>';
}

function title_generator($filename) {
    $titles = array(
	'PSP' => 'Для игры необходима приставка PSP',
	'Эмулятор' => 'Игру можно запустить на ПК через эмулятор'
    );
    foreach ($titles as $key => $value) {
	if (strstr($filename, $key)) {
	    return $value;
	}
    }
    return $filename;
}

function randombg() {
    $bg_dir = getcwd() . '/images/wallpapers';
    $bg = array();

    /* load all bg into array */
    if ($handle = opendir($bg_dir)) {
	while (false !== ($entry = readdir($handle))) {
	    if (preg_match("/.jpg$/", $entry))
		array_push($bg, $entry);
	}
	closedir($handle);
    }

    $i = rand(0, count($bg)-1); // generate random number size of the array
    $selectedBg = "$bg[$i]"; // set variable equal to which random filename was chosen

    return $selectedBg;
}


/** DEPRECATED **/

function check_link($link, $dir) {
	if (strstr($link, 'http')) {
		return $link;
	}  else {
		return $dir . '/' . $link;
	}
}

function template_article_header($link_img, $link_url, $text) {
	echo '<div class="p" style="margin-top: 0">';
	echo '<a href="' . $link_url . '"><img alt="[' . title_generator($link_img) . ']" title="' . title_generator($link_img) . '" class="author fade" style="margin-top: 0.1em" src="/images/' . $link_img . '" /></a>';
	echo $text;
	echo '</div>';
}

function template_article_quote_author($entry) {
	echo '<p class="interview">';
	echo '<a href="' . $entry['author_url'] . '"><img title="Подробнее об авторе" class="author" src="/images/authors/' . $entry['author_image'] . '" /></a>';
	echo '&laquo;' . substr_replace($entry['article_text'], "&raquo;.", -1) . '<a title="Прочесть интервью полностью (на английском языке)" href="'. $entry['interview_url'] .'" class="external">&nbsp;</a>';
	echo '<span class="author">&mdash; <a href="'.$entry['author_url'].'">'.$entry['author_name'].'</a>, ' . $entry['author_role']. '</span>';
	echo '</p>';
}

function template_article_quote_press($quote_text, $author_img=null, $quote_url=null, $author_name=null, $first=null) {
	if (isset($first)) echo '<div class="p">';
	else echo '<p>';
	if ($author_img) echo '<a href="' . $quote_url .'"><img alt="[' . $author_name . ']" title="Подробнее об игре в «' . $author_name . '»" class="author fade" src="' . check_link($author_img, '/images') . '" /></a>';

	echo $quote_text;
//	if ($author_img) echo $quote_text;
//	else $quote_text;

	if (isset($first)) echo '</div>';
	else echo '</p>';
}

$yt_count = 0;
function template_article_youtube_wrapper($youtube_embed_code, $image_path, $num=0, $page=null) {
	global $yt_count;
	$yt_count = $yt_count + 1;

	$class = '';
	if ($page == 'article') $class = 'screenshot';
	
	if (strlen($youtube_embed_code) > 11) {
		$youtube_embed_code = '?listType=playlist&list=' . $youtube_embed_code . '&';
	}

    echo '<div onclick="youtube_watch(this, \'//www.youtube.com/embed/' . $youtube_embed_code . '?autohide=1&fs=1&hl=ru&modestbranding=1&rel=0&iv_load_policy=3&controls=1\')" id="yt' . $yt_count . '" class="yt '.$class.'">';

	if (stripos($image_path, "screenshots") !== false) $title = 'Посмотреть игровой процесс';
	else $title = 'Посмотреть трейлер игры';
	if ($page == 'article') $title = 'Посмотреть трейлер игры';
	
    echo '<div class="youtube_preview_container" title="'. $title .'">';
	
    echo  '<img alt=\'[Скриншот]\' src="' . $image_path . '" class="youtube_preview" />';
	
    if ($num == 1) {
	echo '<img src="/images/youtube-01.png" class="youtube_play_button"></div>';
    } else {
	echo '<img src="/images/youtube-00.png" class="youtube_play_button"></div>';
    }
    
    echo '<iframe frameborder="0" allowfullscreen="" style="display: none"></iframe></div>';
}

function template_article_screenshot($filename, $url=null) {
	if (isset($url)) {
		echo '<a href="' . $url . '"><img alt="[Иллюстрация]" title="Иллюстрация" src="/images/' . $filename . '" class="screenshot" /></a>';
	} else {
		echo '<img alt="[Скриншот]" title="Скриншот" src="/images/' . $filename . '" class="screenshot scr_full" />';
	}
}

function template_article_buy($platform_array) {
	echo '<div id="buy" style="position: relative">';

	if (isset($platform_array['3ds'])) {
			echo '<div class="pt2">';
			echo '<a href=' . $eshop_url . '>';
			echo '<img alt="[Загрузить в Nintendo eShop]" title="Загрузить в Nintendo eShop" src="/images/eshop.png" />';
			echo '</a>';
			echo '</div>&nbsp;';
	}

	if (isset($platform_array['pc'])) {
		echo '<div class="row">';
//		echo '<div class="large-12 columns" style="overflow: hidden">';
		echo '<div class="large-12 columns">';
//		echo '<iframe src="https://store.steampowered.com/widget/' . $steam_id . '" frameborder="0" width="646" height="190"></iframe>';
//		echo '<iframe src="http://store.steampowered.com/widget/' . $steam_id . '" frameborder="0" style="height: 190; width: 100%; max-width: 646px"></iframe>';
		echo '<iframe src="http://store.steampowered.com/widget/' . preg_replace("/[^0-9]/","",$platform_array['pc']['game_url']) . '" frameborder="0" style="height: 190; width: 100%; max-width: 646px"></iframe>';
		echo '</div>';
		echo '</div>';
	}
		
	if (isset($platform_array['android']) || isset($platform_array['ipad'])) {
		echo '<div class="row">';
			
		if (isset($platform_array['android'])) {
			echo '<div class="large-6 columns pt2">';
//			echo '<a href="//play.google.com/store/apps/details?id=' . $google_id . '">';
			echo '<a href="' . $platform_array['android']['game_url'] . '">';
			echo '<img alt="[Загрузить на Google Play]" title="Загрузить на Google Play" src="/images/google-play.png" />';
			echo '</a>';
			echo '</div>';
		}
			
		if (isset($platform_array['ipad'])) {
			echo '<div class="large-6 columns pt2">';
//			echo '<a href="//itunes.apple.com/' . $appstore_id . '">';
			echo '<a href="' . $platform_array['ipad']['game_url'] . '">';
			echo '<img alt="[Загрузить в App Store]" title="Загрузить в App Store" src="/images/appstore.png" />';
			echo '</a>';
			echo '</div>';
		}
		echo '</div>';
	}

	if (isset($platform_array['ps3']) || isset($platform_array['xbox360'])) {
		echo '<div class="row">';
			
		if (isset($platform_array['ps3'])) {
			echo '<div class="large-6 columns pt2">';
//			echo '<a href=' . $psn_url . '>';
			echo '<a href="' . $platform_array['ps3']['game_url'] . '">';
			echo '<img alt="[Загрузить в PSN Store]" title="Загрузить в PSN Store" src="/images/psn.png" />';
			echo '</a>';
			echo '</div>&nbsp;';
		}
			
		if (isset($platform_array['xbox360'])) {
			echo '<div class="large-6 columns pt2">';
//			echo '<a href=' . $xbla_url . '>';
			echo '<a href="' . $platform_array['xbox360']['game_url'] . '">';
			echo '<img alt="[Загрузить в Xbox 360 Marketplace]" title="Загрузить в Xbox 360 Marketplace" src="/images/xbla.png" />';
			echo '</a>';
			echo '</div>&nbsp;';
		}
		echo '</div>';
	}

	if (isset($platform_array['ps4']) || isset($platform_array['xboxone'])) {
		echo '<div class="row">';
			
		if (isset($platform_array['ps4'])) {
			echo '<div class="large-6 columns pt2">';
//			echo '<a href=' . $psn_url . '>';
			echo '<a href="' . $platform_array['ps4']['game_url'] . '">';
			echo '<img alt="[Загрузить в PSN Store]" title="Загрузить в PSN Store" src="/images/psn.png" />';
			echo '</a>';
			echo '</div>&nbsp;';
		}
			
		if (isset($platform_array['xboxone'])) {
			echo '<div class="large-6 columns pt2">';
//			echo '<a href=' . $xbla_url . '>';
			echo '<a href="' . $platform_array['xboxone']['game_url'] . '">';
			echo '<img style="height: 200px; width: auto" alt="[Загрузить в Магазине Майкрософт]" title="Загрузить в Магазине Майкрософт" src="/images/msstore.png" />';
			echo '</a>';
			echo '</div>&nbsp;';
		}
		echo '</div>';
	}

	echo '</div>	';
}

function template_article_youtube_music($playlist_code) {
	echo '<div class="youtube_music screenshot">';
	echo '<iframe src="//www.youtube.com/embed/?listType=playlist&list=' . $playlist_code . '&fs=0&hl=ru&modestbranding=1&rel=0&iv_load_policy=3&controls=0" frameborder="0"></iframe>';
	echo '</div>';
}

function template_article_slider($game_name, $height, $author_name, $pictures_array) {
	if (strlen($author_name)>0) {
		$author_name = $author_name . '. ';
	}
	echo '<script type="text/javascript" src="/static/slick-carousel/slick/slick.min.js"></script>';
	echo '<div class="slider_article_wrapper screenshot">';
	echo '<div class="slider slider_article">';
	foreach ($pictures_array as $picture_array) {
//		echo '<div class="bg" style="max-height: 90%; height: ' . $height. '; background-image: url(/images/art/' . $picture_array[0] . ')" title="' . $picture_array[1] . '"></div>';
		echo '<div style="max-height: 90%; height: ' . $height. '"><div class="bg" style="height: 90%; width: auto; background-image: url(/images/art/' . $game_name . '/' . $picture_array[0] . ')"></div><div class="picture_author">' . $author_name . $picture_array[1] .'</div></div>';
	}
	echo '</div>';
//	echo '<div class="picture_author">Художник: <a href="' . $author_url . '">' . $author_name . '</a></div>';
//	echo '<div class="picture_author">Художник: ' . $author_name . '</div>';
	echo '</div>';
	echo '<script type="text/javascript" src="/static/slider.js"></script>';
}

function template_article_same_as($games_array) {
	echo '<div id="same">';
	foreach ($games_array as $game) {
		echo '<a href="'. $game['similar_url'] .'"><img src="/images/boxes/' . $game['similar_image'] . '" alt="['. $game['similar_name'] .']" title="Игра похожа на «'. $game['similar_name'] .'»"/></a>';
	}
	echo '</div>';
}
?>
