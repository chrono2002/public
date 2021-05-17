/************** SLIDER *****************/

$(document).ready(function() {
    $('.slider_article').slick({
	arrows: true,
	adaptiveHeight: false,
	nextArrow: '<button type="button" class="slick-next"></button>',
	prevArrow: '<button type="button" class="slick-prev"></button>',
	autoplay: false,
	autoplaySpeed: 10000,
	dots: true,
	fade: true,
        infinite: true,
        speed: 500,
        slidesToShow: 1,
        slidesToScroll: 1,
	touchThreshold: 15
    });
});
