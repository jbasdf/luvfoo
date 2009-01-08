
var SLIDE_SPEED = 500

//jQuery.noConflict();

jQuery(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

jQuery.jGrowl.info = function(msg){
	jQuery.jGrowl(msg, {position: 'center'}, "Information!", "#BBF66F", "#000");
}

jQuery.jGrowl.warn = function(msg){
	jQuery.jGrowl(msg, {position: 'center'}, "Warning!", "#F6BD6F", "#000");	
}

jQuery.jGrowl.error = function(msg){
	jQuery.jGrowl(msg, {position: 'center'}, "Critical!", "#F66F82", "#000");	
}

function jeval(str){return eval('(' +  str + ');'); }

function tog(clicker, toggler, callback, speed){
  if (speed == undefined)
    speed = SLIDE_SPEED;
  if (callback)
    jQuery(clicker).click(function(){jQuery(toggler).slideToggle(speed, callback); return false;});
  else
    jQuery(clicker).click(function(){jQuery(toggler).slideToggle(speed); return false;});
}
function togger(j, callback, speed){
  if (speed == undefined)
    speed = SLIDE_SPEED;
  if(callback)
  jQuery(j).slideToggle(speed, callback); 
  else 
  jQuery(j).slideToggle(speed); 
}

function async_message(m, d){message(m, d);}
function messages(m, d){message(m, d);}
function message(message, duration){
    if (duration == undefined){
        duration = 3000;
    }
    if (jQuery.browser.msie) { jQuery("#message").css({position: 'absolute'}); }
    jQuery("#message").text(message).fadeIn(1000);
    setTimeout('jQuery("#message").fadeOut(2000)',duration);
    return false;
}

function debug(m){if (typeof console != 'undefined'){console.log(m);}}
function puts(m){debug(m);}

function thickbox(id, title, height, width){
    if (height == undefined){ height = 300}
    if (width == undefined){ width = 300}
    tb_show(title, '#TB_inline?height='+ height +'&amp;width='+ width +'&amp;inlineId='+ id +'', false);
    return false;
}

function tog_login_element() {
	jQuery('.login_element, .checkout_element').toggle();
}

function toggleComments(comment_id)
{
	jQuery('#comment_'+comment_id+'_short, #comment_'+comment_id+'_complete').toggleClass('hidden');
  
	jQuery('#comment_'+comment_id+'_toggle_link').html(
    	jQuery('#comment_'+comment_id+'_toggle_link').html() == "(more)" ? "(less)" : "(more)"
	); 
}

jQuery(document).ready(function() {
	
	jQuery('#search_q').bind('focus.search_query_field', function(){
		if(jQuery(this).val()=='Search for Friends'){
			jQuery(this).val('');
		}
	});
	
	jQuery('#search_q').bind('blur.search_query_field', function(){
		if(jQuery(this).val()==''){
			jQuery(this).val('Search for Friends');
		}
	});
	
	jQuery(".tip-field").focus(function() {
		jQuery(".active").removeClass("active");
		jQuery(".hidden-tips").css("display", "none");
		jQuery("#" + this.id + "-help").show();
		jQuery("#" + this.id + "-container").addClass("active");
	});
	
	jQuery(".hidden-tips").css("display", "none");

	jQuery(".required-value").blur(function() {
		if (jQuery(this).val().length == 0) {
			jQuery('#' + this.id + '_required').show();
		} else {
			jQuery('#' + this.id + '_required').hide();
			jQuery("#" + this.id + "-container").children().removeClass("fieldWithErrors");
			jQuery('#' + this.id + '-label-required').hide();
		}
	});

	jQuery(".submit-delete").click(function() {
		jQuery(this).parents('.delete-container:first').fadeOut();
		var form = jQuery(this).parents('form');
		jQuery.post(form.attr('action') + '.js', form.serialize(),
		  function(data){
				jQuery.jGrowl.info(data);
		  });			
		return false;
	});	
  
});
