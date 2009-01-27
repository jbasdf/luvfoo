var swfu;

window.onload = function () {
	
	var parent_id = jQuery.getQueryString({id:"id"});
	var parent_type = jQuery.getQueryString({id:"type"});
	var session_id = jQuery.getQueryString({id:"sessionid"});
	var session_key = jQuery.getQueryString({id:"sessionkey"});
	var settings = {		
			flash_url : '/swf/swfupload.swf',
			upload_url: '/uploads/swfupload.json?id=' + parent_id + '&type=' + parent_type + '&' + session_key + '=' + session_id + '&is_public=true',
			file_size_limit : "100 MB",
			file_types : '*.jpg; *.jpeg; *.psd; *.png; *.gif;',
			file_types_description : "Images",
			file_upload_limit : 100,
			file_queue_limit : 0,
			custom_settings : {
				progressTarget : "fsUploadProgress",
				cancelButtonId : "btnCancel"
			},
			debug: false,

			// Button Settings
			button_image_url : "/images/XPButtonUploadText_61x22.png",	// Relative to the SWF file
			button_placeholder_id : "spanButtonPlaceholder",
			button_width: 61,
			button_height: 22,

			// The event handler functions are defined in handlers.js
			swfupload_loaded_handler : swfUploadLoaded,
			file_queued_handler : fileQueued,
			file_queue_error_handler : fileQueueError,
			file_dialog_complete_handler : fileDialogComplete,
			upload_start_handler : uploadStart,
			upload_progress_handler : uploadProgress,
			upload_error_handler : uploadError,
			upload_success_handler : uploadSuccess,
			upload_complete_handler : uploadComplete,
			queue_complete_handler : queueComplete,	// Queue plugin event

			// SWFObject settings
			minimum_flash_version : "9.0.28",
			swfupload_pre_load_handler : swfUploadPreLoad,
			swfupload_load_failed_handler : swfUploadLoadFailed
		};

	swfu = new SWFUpload(settings);
};

jQuery(document).ready(function()
{
	var path = jQuery.getQueryString({id:"path"});

	jQuery.getJSON(path, function(data){
		jQuery('#upload-list-message').html('');
		if (data.length <= 0){
			jQuery("#upload-list-message").html('No Images Available');
		} else {
			for(i=0;i<data.length;i++){
				add_image(data[i].upload, 'append');
			}
		}
	});	 
});
function upload_file_callback(data){
	jQuery('#upload-status').empty();
	var json = eval('(' + data + ')');
	add_image(json.upload, 'prepend');
}
function upload_file_fail_callback(message){
	jQuery('#upload-status').html(message);
}
function upload_completed_callback(data){
	var json = eval('(' + data + ')');
	add_image(json.upload, 'prepend'); // call add_image from functions.js
}
function add_image(image, location){
	var image_html = '<li id="image-' + image.id + '">' +
		'<div class="thumbs">Insert:<br />' +
		'<a onclick="select_thumb(this);return false;" href="#_icon"> Icon </a>' +
		'<a onclick="select_thumb(this);return false;" href="#_thumb"> Thumbnail </a>' +
	  '<a onclick="select_thumb(this);return false;" href="#_small"> Small </a>' +
		'<a onclick="select_thumb(this);return false;" href="#_medium"> Medium </a>' +
		'<a onclick="select_thumb(this);return false;" href="#"> Large </a><br/><div class="file-controls">' +
		'<a class="file-control" onclick="jQuery(this).parents(\'li\').removeClass(\'selected\');return false;" href="#"> cancel </a><br/>' +
		'<a class="file-control" onclick="delete_image(this, ' + image.id + ');return false;" href="#"> delete </a></div></div>' +
		'<a onclick="select_image(\'image-' + image.id + '\');return false;" href="#">' +
		'<img src="' + image.icon + '" alt="" /></a></li>';
	
	if ('prepend' == location){
		jQuery('#upload-list').prepend(image_html);
	} else {
		jQuery('#upload-list').append(image_html);
	}		
}
function delete_image(element, id){
	jQuery(element).parents('li').removeClass('selected');
	jQuery(element).parents('li').fadeOut();

	jQuery.post('/uploads/' + id + '.js', {action: 'destroy', _method: 'delete' },
	  function(data){
			//show_message(data); the fade out on delete gets the point across
	  });
}
function select_image(element){
	jQuery('#upload-list li').removeClass('selected'); 
	jQuery('#' + element).addClass('selected');
}
function select_thumb(element) {
	var anchor = jQuery(element);
	var size = anchor.attr('href').split('#')[1];
	var img = anchor.parents('li').children('a').children('img');
	var src = img.attr('src').replace('_icon.', size + '.');
	anchor.parents('li').removeClass('selected');
	insert_image_too(src, img.attr('alt') );	
}
function insert_image_too(url, alt_text){
	var formObj = formElement();
	formObj.src.value = url;
	formObj.alt.value = alt_text;
	mcTabs.displayTab('general_tab','general_panel');
	ImageDialog.showPreviewImage(url);
}
function formElement() {
	return document.insert_image;
}
function ts_onload(){
	jQuery('#upload-status').html("Uploading <img src='/images/spinner.gif'>");
	mcTabs.displayTab('dynamic_select_tab','dynamic_select_panel');	
	var iframe1=ts_ce('iframe','html_editor_image_upload_frame');
	iframe1.setAttribute('src','about:blank');
	iframe1.style.border="0px none";
	iframe1.style.position="absolute";
	iframe1.style.width="1px";
	iframe1.style.height="1px";
	iframe1.style.visibility="hidden";
	iframe1.setAttribute('id','html_editor_image_upload_frame');
	jQuery('#image-upload').append(iframe1);
	jQuery('#image_upload_form').attr('action', ts_upload_image_path());
}
function ts_upload_image_path() {
	var parent_id = jQuery.getQueryString({id:"id"});
	var parent_type = jQuery.getQueryString({id:"type"});
  return '/uploads.js?id=' + parent_id + '&type=' + parent_type;
}
function ts_ce(tag,name){
  if (name && window.ActiveXObject){
    element = document.createElement('<'+tag+' name="'+name+'">');
  }else{
    element = document.createElement(tag);
    element.setAttribute('name',name);
  }
  return element;
}
	
var ImageDialog = {
	preInit : function() {
		var url;

		tinyMCEPopup.requireLangPack();

		if (url = tinyMCEPopup.getParam("external_image_list_url"))
			document.write('<script language="javascript" type="text/javascript" src="' + tinyMCEPopup.editor.documentBaseURI.toAbsolute(url) + '"></script>');
	},

	init : function(ed) {
		var f = formElement(), nl = f.elements, ed = tinyMCEPopup.editor, dom = ed.dom, n = ed.selection.getNode();

		tinyMCEPopup.resizeToInnerSize();
		this.fillClassList('class_list');
		this.fillFileList('src_list', 'tinyMCEImageList');
		this.fillFileList('over_list', 'tinyMCEImageList');
		this.fillFileList('out_list', 'tinyMCEImageList');

		if (n.nodeName == 'IMG') {
			nl.src.value = dom.getAttrib(n, 'src');
			nl.width.value = dom.getAttrib(n, 'width');
			nl.height.value = dom.getAttrib(n, 'height');
			nl.alt.value = dom.getAttrib(n, 'alt');
			nl.title.value = dom.getAttrib(n, 'title');
			nl.vspace.value = this.getAttrib(n, 'vspace');
			nl.hspace.value = this.getAttrib(n, 'hspace');
			nl.border.value = this.getAttrib(n, 'border');
			selectByValue(f, 'align', this.getAttrib(n, 'align'));
			selectByValue(f, 'class_list', dom.getAttrib(n, 'class'));
			nl.style.value = dom.getAttrib(n, 'style');
			nl.id.value = dom.getAttrib(n, 'id');
			nl.dir.value = dom.getAttrib(n, 'dir');
			nl.lang.value = dom.getAttrib(n, 'lang');
			nl.usemap.value = dom.getAttrib(n, 'usemap');
			nl.longdesc.value = dom.getAttrib(n, 'longdesc');
			nl.insert.value = ed.getLang('update');

			if (/^\s*this.src\s*=\s*\'([^\']+)\';?\s*$/.test(dom.getAttrib(n, 'onmouseover')))
				nl.onmouseoversrc.value = dom.getAttrib(n, 'onmouseover').replace(/^\s*this.src\s*=\s*\'([^\']+)\';?\s*$/, '$1');

			if (/^\s*this.src\s*=\s*\'([^\']+)\';?\s*$/.test(dom.getAttrib(n, 'onmouseout')))
				nl.onmouseoutsrc.value = dom.getAttrib(n, 'onmouseout').replace(/^\s*this.src\s*=\s*\'([^\']+)\';?\s*$/, '$1');

			if (ed.settings.inline_styles) {
				// Move attribs to styles
				if (dom.getAttrib(n, 'align'))
					this.updateStyle('align');

				if (dom.getAttrib(n, 'hspace'))
					this.updateStyle('hspace');

				if (dom.getAttrib(n, 'border'))
					this.updateStyle('border');

				if (dom.getAttrib(n, 'vspace'))
					this.updateStyle('vspace');
			}
		}

		// Setup browse button
		document.getElementById('srcbrowsercontainer').innerHTML = getBrowserHTML('srcbrowser','src','image','theme_advanced_image');
		if (isVisible('srcbrowser'))
			document.getElementById('src').style.width = '260px';

		// Setup browse button
		// document.getElementById('onmouseoversrccontainer').innerHTML = getBrowserHTML('overbrowser','onmouseoversrc','image','theme_advanced_image');
		// if (isVisible('overbrowser'))
		// 	document.getElementById('onmouseoversrc').style.width = '260px';
		// 
		// // Setup browse button
		// document.getElementById('onmouseoutsrccontainer').innerHTML = getBrowserHTML('outbrowser','onmouseoutsrc','image','theme_advanced_image');
		// if (isVisible('outbrowser'))
		// 	document.getElementById('onmouseoutsrc').style.width = '260px';

		// If option enabled default contrain proportions to checked
		if (ed.getParam("advimage_constrain_proportions", true))
			f.constrain.checked = true;

		// Check swap image if valid data
		// if (nl.onmouseoversrc.value || nl.onmouseoutsrc.value)
		// 	this.setSwapImage(true);
		// else
		// 	this.setSwapImage(false);

		this.changeAppearance();
		this.showPreviewImage(nl.src.value, 1);
	},

	insert : function(file, title) {
		var ed = tinyMCEPopup.editor, t = this, f = formElement();

		if (f.src.value === '') {
			if (ed.selection.getNode().nodeName == 'IMG') {
				ed.dom.remove(ed.selection.getNode());
				ed.execCommand('mceRepaint');
			}

			tinyMCEPopup.close();
			return;
		}

		if (tinyMCEPopup.getParam("accessibility_warnings", 1)) {
			if (!f.alt.value) {
				tinyMCEPopup.editor.windowManager.confirm(tinyMCEPopup.getLang('advimage_dlg.missing_alt'), function(s) {
					if (s)
						t.insertAndClose();
				});

				return;
			}
		}

		t.insertAndClose();
	},

	insertAndClose : function() {
		var ed = tinyMCEPopup.editor, f = formElement(), nl = f.elements, v, args = {}, el;

		// Fixes crash in Safari
		if (tinymce.isWebKit)
			ed.getWin().focus();

		if (!ed.settings.inline_styles) {
			args = {
				vspace : nl.vspace.value,
				hspace : nl.hspace.value,
				border : nl.border.value,
				align : getSelectValue(f, 'align')
			};
		} else {
			// Remove deprecated values
			args = {
				vspace : '',
				hspace : '',
				border : '',
				align : ''
			};
		}

		tinymce.extend(args, {
			src : nl.src.value,
			width : nl.width.value,
			height : nl.height.value,
			alt : nl.alt.value,
			title : nl.title.value,
			'class' : getSelectValue(f, 'class_list'),
			style : nl.style.value
			// id : nl.id.value,
			// dir : nl.dir.value,
			// lang : nl.lang.value,
			// usemap : nl.usemap.value,
			// longdesc : nl.longdesc.value
		});

		// args.onmouseover = args.onmouseout = '';

		// if (f.onmousemovecheck.checked) {
		// 	if (nl.onmouseoversrc.value)
		// 		args.onmouseover = "this.src='" + nl.onmouseoversrc.value + "';";
		// 
		// 	if (nl.onmouseoutsrc.value)
		// 		args.onmouseout = "this.src='" + nl.onmouseoutsrc.value + "';";
		// }

		el = ed.selection.getNode();

		if (el && el.nodeName == 'IMG') {
			ed.dom.setAttribs(el, args);
		} else {
			ed.execCommand('mceInsertContent', false, '<img id="__mce_tmp" src="javascript:;" />', {skip_undo : 1});
			ed.dom.setAttribs('__mce_tmp', args);
			ed.dom.setAttrib('__mce_tmp', 'id', '');
			ed.undoManager.add();
		}

		tinyMCEPopup.close();
	},

	getAttrib : function(e, at) {
		var ed = tinyMCEPopup.editor, dom = ed.dom, v, v2;

		if (ed.settings.inline_styles) {
			switch (at) {
				case 'align':
					if (v = dom.getStyle(e, 'float'))
						return v;

					if (v = dom.getStyle(e, 'vertical-align'))
						return v;

					break;

				case 'hspace':
					v = dom.getStyle(e, 'margin-left')
					v2 = dom.getStyle(e, 'margin-right');

					if (v && v == v2)
						return parseInt(v.replace(/[^0-9]/g, ''));

					break;

				case 'vspace':
					v = dom.getStyle(e, 'margin-top')
					v2 = dom.getStyle(e, 'margin-bottom');
					if (v && v == v2)
						return parseInt(v.replace(/[^0-9]/g, ''));

					break;

				case 'border':
					v = 0;

					tinymce.each(['top', 'right', 'bottom', 'left'], function(sv) {
						sv = dom.getStyle(e, 'border-' + sv + '-width');

						// False or not the same as prev
						if (!sv || (sv != v && v !== 0)) {
							v = 0;
							return false;
						}

						if (sv)
							v = sv;
					});

					if (v)
						return parseInt(v.replace(/[^0-9]/g, ''));

					break;
			}
		}

		if (v = dom.getAttrib(e, at))
			return v;

		return '';
	},

	setSwapImage : function(st) {
		var f = formElement();

		f.onmousemovecheck.checked = st;
		setBrowserDisabled('overbrowser', !st);
		setBrowserDisabled('outbrowser', !st);

		if (f.over_list)
			f.over_list.disabled = !st;

		if (f.out_list)
			f.out_list.disabled = !st;

		f.onmouseoversrc.disabled = !st;
		f.onmouseoutsrc.disabled  = !st;
	},

	fillClassList : function(id) {
		var dom = tinyMCEPopup.dom, lst = dom.get(id), v, cl;

		if (v = tinyMCEPopup.getParam('theme_advanced_styles')) {
			cl = [];

			tinymce.each(v.split(';'), function(v) {
				var p = v.split('=');

				cl.push({'title' : p[0], 'class' : p[1]});
			});
		} else
			cl = tinyMCEPopup.editor.dom.getClasses();

		if (cl.length > 0) {
			lst.options[lst.options.length] = new Option(tinyMCEPopup.getLang('not_set'), '');

			tinymce.each(cl, function(o) {
				lst.options[lst.options.length] = new Option(o.title || o['class'], o['class']);
			});
		} else
			dom.remove(dom.getParent(id, 'tr'));
	},

	fillFileList : function(id, l) {
		var dom = tinyMCEPopup.dom, lst = dom.get(id), v, cl;

		l = window[l];

		if (l && l.length > 0) {
			lst.options[lst.options.length] = new Option('', '');

			tinymce.each(l, function(o) {
				lst.options[lst.options.length] = new Option(o[0], o[1]);
			});
		} else
			dom.remove(dom.getParent(id, 'tr'));
	},

	resetImageData : function() {
		var f = formElement();

		f.elements.width.value = f.elements.height.value = '';
	},

	updateImageData : function(img, st) {
		var f = formElement();

		if (!st) {
			f.elements.width.value = img.width;
			f.elements.height.value = img.height;
		}

		this.preloadImg = img;
	},

	changeAppearance : function() {
		var ed = tinyMCEPopup.editor, f = formElement(), img = document.getElementById('alignSampleImg');

		if (img) {
			if (ed.getParam('inline_styles')) {
				ed.dom.setAttrib(img, 'style', f.style.value);
			} else {
				img.align = f.align.value;
				img.border = f.border.value;
				img.hspace = f.hspace.value;
				img.vspace = f.vspace.value;
			}
		}
	},

	changeHeight : function() {
		var f = formElement(), tp, t = this;

		if (!f.constrain.checked || !t.preloadImg) {
			return;
		}

		if (f.width.value == "" || f.height.value == "")
			return;

		tp = (parseInt(f.width.value) / parseInt(t.preloadImg.width)) * t.preloadImg.height;
		f.height.value = tp.toFixed(0);
	},

	changeWidth : function() {
		var f = formElement(), tp, t = this;

		if (!f.constrain.checked || !t.preloadImg) {
			return;
		}

		if (f.width.value == "" || f.height.value == "")
			return;

		tp = (parseInt(f.height.value) / parseInt(t.preloadImg.height)) * t.preloadImg.width;
		f.width.value = tp.toFixed(0);
	},

	updateStyle : function(ty) {
		var dom = tinyMCEPopup.dom, st, v, f = formElement(), img = dom.create('img', {style : dom.get('style').value});

		if (tinyMCEPopup.editor.settings.inline_styles) {
			// Handle align
			if (ty == 'align') {
				dom.setStyle(img, 'float', '');
				dom.setStyle(img, 'vertical-align', '');

				v = getSelectValue(f, 'align');
				if (v) {
					if (v == 'left' || v == 'right')
						dom.setStyle(img, 'float', v);
					else
						img.style.verticalAlign = v;
				}
			}

			// Handle border
			if (ty == 'border') {
				dom.setStyle(img, 'border', '');

				v = f.border.value;
				if (v || v == '0') {
					if (v == '0')
						img.style.border = '';
					else
						img.style.border = v + 'px solid black';
				}
			}

			// Handle hspace
			if (ty == 'hspace') {
				dom.setStyle(img, 'marginLeft', '');
				dom.setStyle(img, 'marginRight', '');

				v = f.hspace.value;
				if (v) {
					img.style.marginLeft = v + 'px';
					img.style.marginRight = v + 'px';
				}
			}

			// Handle vspace
			if (ty == 'vspace') {
				dom.setStyle(img, 'marginTop', '');
				dom.setStyle(img, 'marginBottom', '');

				v = f.vspace.value;
				if (v) {
					img.style.marginTop = v + 'px';
					img.style.marginBottom = v + 'px';
				}
			}

			// Merge
			dom.get('style').value = dom.serializeStyle(dom.parseStyle(img.style.cssText));
		}
	},

	changeMouseMove : function() {
	},

	showPreviewImage : function(u, st) {
		if (!u) {
			tinyMCEPopup.dom.setHTML('prev', '');
			return;
		}

		if (!st && tinyMCEPopup.getParam("advimage_update_dimensions_onchange", true))
			this.resetImageData();

		u = tinyMCEPopup.editor.documentBaseURI.toAbsolute(u);

		if (!st)
			tinyMCEPopup.dom.setHTML('prev', '<img id="previewImg" src="' + u + '" border="0" onload="ImageDialog.updateImageData(this);" onerror="ImageDialog.resetImageData();" />');
		else
			tinyMCEPopup.dom.setHTML('prev', '<img id="previewImg" src="' + u + '" border="0" onload="ImageDialog.updateImageData(this, 1);" />');
	}
};

ImageDialog.preInit();
tinyMCEPopup.onInit.add(ImageDialog.init, ImageDialog);
