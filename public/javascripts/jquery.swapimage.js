/**
 * swapImage - jQuery plugin for swapping image
 *
 * Copyright (c) 2008 tszming (tszming@gmail.com)
 *
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */

/**
 * Enable image swapping, requires metadata plugin.
 *
 * @example $.swapImage(".swapImage");
 * @desc Enable image swapping for all images with CSS class name equal to "swapImage", e.g.
 *	<img class="swapImage {src: 'images/new.gif'}" src="images/old.gif" />
 *
 * @param i Images to be selected.
 * @param preload Preload the image, default = true.
 * @param repeat Repeat the effect, default = true.
 * @param swapInEvent Event for swap In. 
 * @param swapOutEvent Event for swap Out. 
 *  
 * @name $.swapImage
 * @cat Plugins/SwapImage
 * @author tszming (tszming@gmail.com)
 * @version 1.0.1
 */
jQuery.swapImage = function(i, preload, repeat, swapInEvent, swapOutEvent) {

	jQuery.swapImage.preload = function() {
		var img = new Image();
		img.src = jQuery(this).metadata().src;
	};

	jQuery.swapImage.swap = function() {
		var data = jQuery(this).metadata();
		var tmp = data.src;
		data.src = this.src;
		this.src = tmp;
	};

	jQuery(document).ready(function() {
		
		if (typeof preload == "undefined")	preload = true;
		if (typeof repeat == "undefined")	repeat = true;
		if (typeof swapInEvent == "undefined" && typeof swapInEvent == "undefined") {
			swapInEvent = "mouseenter";		swapOutEvent = "mouseleave";
		}
		
		if (repeat) {
			if (typeof swapOutEvent != "undefined") {
				jQuery(i).bind(swapInEvent, jQuery.swapImage.swap).bind(swapOutEvent, jQuery.swapImage.swap);	
			} else {
				jQuery(i).bind(swapInEvent, jQuery.swapImage.swap);	
			}						
		} else {
			jQuery(i).one(swapInEvent, jQuery.swapImage.swap);
		}
				
		if (preload) {
			jQuery(i).each(jQuery.swapImage.preload)
		};
	});
};