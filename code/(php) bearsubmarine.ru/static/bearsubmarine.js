/************** YOUTUBE PLAYER ******************/

function youtube_watch(preview_container, youtube_url) {
	var preview_tmp = preview_container.getElementsByClassName('youtube_preview_container')[0];
	preview_tmp.style.display = 'none';

	var iframe_tmp = preview_container.getElementsByTagName("iframe")[0];
	iframe_tmp.src = youtube_url;
	iframe_tmp.style.display = 'block'; 

	$('#'+preview_container.id).fitVids();

	iframe_tmp.src += '&autoplay=1';
}
