function save_page() {
	tinyMCE.triggerSave(true,true);
	var form = jQuery('#editor-form');
	jQuery.post(form.attr('action') + '.js', form.serialize(),
	  function(data){
			var result = eval('(' + data + ')');
			show_message(result['message']);
			if('true' == result['success']){
				undirty();
				update_permalink(result['url_key']);
			}			
	  });
	return false;
}

function show_message(message){
	jQuery.jGrowl.info(message);
}

function undirty(){
	var ed = tinyMCE.get('mce-content');
	ed.isNotDirty = 1;
}

// The following are use to manage the permalink on a given page
jQuery(document).ready(function() {
		
	jQuery('#permalink-edit').click(function() {
		jQuery('#finish-permalink-buttons').show();
		jQuery('#edit-permalink').show();
		jQuery('#view-permalink').hide();
		jQuery('#edit-permalink-buttons').hide();
		return false;
	});
	
	jQuery('#permalink-save').click(function() {
		hide_edit();
		save_permalink();
		return false;
	});
	
	jQuery('#permalink-cancel').click(function() {
		hide_edit();
		jQuery("#url-key").val(jQuery('#view-permalink').html());
		return false;
	});
});

function hide_edit(){
	jQuery('#finish-permalink-buttons').hide();
	jQuery('#view-permalink').show();
	jQuery('#edit-permalink-buttons').show();
	jQuery('#edit-permalink').hide();
}

function save_permalink() {
  var form = jQuery('#editor-form');
	jQuery.post(form.attr('action') + '.js', {url_key: jQuery('#url-key').val(), action: 'update', _method: 'put', only_permalink: 'true' },
	  function(data){
			var result = eval('(' + data + ')');
			show_message(result['message']);
			if('true' == result['success']){
				update_permalink(result['url_key']);
			}			
	  });
	return false;
}

function update_permalink(url){
	jQuery("#preview-page").attr('href', '/pages/' + url )
	jQuery("#view-permalink").html(url);
	jQuery("#url-key").val(url);
}


