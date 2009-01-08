jQuery(document).ready(function() {
						
	jQuery(".pageContainer").draggable({
		zIndex : 1000000,
		revert : 'invalid',
		opacity : 0.5,
		scroll : true,
		helper : 'clone'
	});

	jQuery("#pageList").droppable({ 
			accept: ".pageContainer",
			drop: function(ev, ui) { 
				var source_li = jQuery(ui.draggable);
				var child_ul = jQuery(this).children('ul');
				var page_id = source_li.children('input').val();
				var parent_id = 0;
				if(same_parent(source_li, child_ul)){
					return;
				}
				insert_alphabetic(child_ul, source_li);
				update_parent(page_id, parent_id);
	    }
		});
	
	jQuery(".pageContainer").droppable({ 
	  accept: ".pageContainer",
	  hoverClass: 'pageContainer-hover',
	  tolerance : 'pointer',
		greedy : true,
    drop: function(ev, ui) { 
			var source_li = jQuery(ui.draggable);
			var target_li = jQuery(this);
			var page_id = source_li.children('input').val();
			var parent_id = target_li.children('input').val();
			if(target_li.children('ul').length <= 0){
				target_li.append('<ul></ul>');			
			}
			var child_ul = target_li.children('ul');
			if(same_parent(source_li, child_ul)){
				return;
			}
			jQuery(this).children('ul:hidden').slideDown();
			insert_alphabetic(child_ul, source_li);
			update_parent(page_id, parent_id);
    } 
	});
	
	jQuery(".submit-delete").click(function() {
		if(jQuery(this).parents('li:first').siblings('li').length <= 0){
			jQuery(this).parents('li:first').parents('li:first').children('.expander').remove();
		}
		return false;
	});
	
	function insert_alphabetic(child_ul, source_li){
		var kids = child_ul.children('li');
		var source_text = source_li.children('span.link').children('a').html().toLowerCase();
		for(i=0; i<kids.length; i++){				
			var current_text = jQuery(kids[i]).children('span.link').children('a').html().toLowerCase();
			if(source_text < current_text){
				source_li.insertBefore(kids[i]);
				return;
			}			
		}
		source_li.appendTo(child_ul);
	}
	
	function same_parent(source_li, child_ul){
		return source_li.parent() == child_ul;
	}	
	
	function update_parent(page_id, parent_id){
		var path = jQuery('#updatePath').val();
		jQuery.post(path + '/' + page_id + '.js', {parent_id: parent_id, action: 'update', _method: 'put', only_parent: 'true' },
		  function(data){
				apply_expander();
				if(data.length > 0){
					var result = eval('(' + data + ')');
					if(!result.success){
						jQuery.jGrowl.error(result.message);
					}					
				}
		  });
		return false;
	}
	
	apply_expander();
	function apply_expander(){
		jQuery(".expander").remove();
		jQuery(".pageContainer ul:hidden li:first-child").parent().parent().prepend('<a class="expander" href="#"><img src="/images/expand.png" /></a>');
		jQuery(".pageContainer ul:visible li:first-child").parent().parent().prepend('<a class="expander" href="#"><img src="/images/collapse.png" /></a>');				
		jQuery(".expander").click(function(){
			var img = jQuery(this).children('img');
			var target_ul = jQuery(this).siblings('ul');
			if(img.attr('src') == '/images/expand.png'){
				img.attr('src', '/images/collapse.png');
				target_ul.slideDown();
			} else {
				img.attr('src', '/images/expand.png');
				target_ul.slideUp();
			}
			return false;
		});
	}
	
});