var swfu;

window.onload = function () {
	
	var parent_id = jQuery.getQueryString({id:"id"});
	var parent_type = jQuery.getQueryString({id:"type"});
	var session_id = jQuery.getQueryString({id:"sessionid"});
	var session_key = jQuery.getQueryString({id:"sessionkey"});
 	var settings = {		
			flash_url : '/swf/swfupload.swf',
			upload_url: '/uploads/swfupload.json?id=' + parent_id + '&type=' + parent_type + '&' + session_key + '=' + session_id  + '&is_public=true',		
			file_size_limit : "100 MB",
			file_types : "*.*",
			file_types_description : "All Files",
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
			jQuery("#upload-list-message").html('No Files Available');
		} else {
			for(i=0;i<data.length;i++){
				add_file(data[i].upload, 'append');
			}
		}
	});	 
});
function upload_file_callback(data){
	jQuery('#upload-status').empty();
	var json = eval('(' + data + ')');
	add_file(json.upload, 'prepend');
}
function upload_file_fail_callback(message){
	jQuery('#upload-status').html(message);
}
function upload_completed_callback(data){
	var json = eval('(' + data + ')');
	add_file(json.upload, 'prepend'); // call add_file from functions.js
}
function add_file(file, location){
	var file_html = '<li id="file-' + file.id + '">' +
		'<img class="icon" src="' + file.icon + '" alt="" />' +
		'<a onclick="select_file(this);return false;" href="#">' + file.filename + '</a>' +
		'<a onclick="delete_file(this, ' + file.id + ');return false;" href="#"><img src="/images/delete.png" /></a>' +
		'<input type="hidden" value="' + file.public_filename + '" /></li>';	
	if ('prepend' == location){
		jQuery('#upload-list').prepend(file_html);
	} else {
		jQuery('#upload-list').append(file_html);
	}		
}
function delete_file(element, id){
	jQuery(element).parents('li').removeClass('selected');
	jQuery(element).parents('li').fadeOut();

	jQuery.post('/uploads/' + id + '.js', {action: 'destroy', _method: 'delete' },
	  function(data){
			// just chuck the message
	  });
}
function select_file(element){
	var anchor = jQuery(element);
	var url = anchor.parents('li').children('input').val();
	var name = anchor.html();
	insert_file_too(url, name);	
}
function insert_file_too(url, name){
	jQuery('input#href').val(url);
	if(jQuery('input#title').val().length <= 0){
		jQuery('input#title').val(name);
	}
	mcTabs.displayTab('general_tab','general_panel');
}
function formElement() {
	return document.insert_file;
}
function ts_onload(){
	jQuery('#upload-status').html("Uploading <img src='/files/spinner.gif'>");
	mcTabs.displayTab('dynamic_select_tab','dynamic_select_panel');	
	var iframe1=ts_ce('iframe','html_editor_file_upload_frame');
	iframe1.setAttribute('src','about:blank');
	iframe1.style.border="0px none";
	iframe1.style.position="absolute";
	iframe1.style.width="1px";
	iframe1.style.height="1px";
	iframe1.style.visibility="hidden";
	iframe1.setAttribute('id','html_editor_file_upload_frame');
	jQuery('#file-upload').append(iframe1);
	jQuery('#file_upload_form').attr('action', ts_upload_file_path());
}
function ts_upload_file_path() {
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

tinyMCEPopup.requireLangPack();

var templates = {
	"window.open" : "window.open('${url}','${target}','${options}')"
};

function preinit() {
	var url;

	if (url = tinyMCEPopup.getParam("external_link_list_url"))
		document.write('<script language="javascript" type="text/javascript" src="' + tinyMCEPopup.editor.documentBaseURI.toAbsolute(url) + '"></script>');
}

function init() {
	tinyMCEPopup.resizeToInnerSize();

	var formObj = formElement();
	var inst = tinyMCEPopup.editor;

	if(inst.selection.getContent().length > 0){
		formObj.title.value = inst.selection.getContent();
	}

	// Resize some elements
	if (isVisible('hrefbrowser'))
		document.getElementById('href').style.width = '260px';

}

function checkPrefix(n) {
	if (n.value && Validator.isEmail(n) && !/^\s*mailto:/i.test(n.value) && confirm(tinyMCEPopup.getLang('advlink_dlg.is_email')))
		n.value = 'mailto:' + n.value;

	if (/^\s*www./i.test(n.value) && confirm(tinyMCEPopup.getLang('advlink_dlg.is_external')))
		n.value = 'http://' + n.value;
}

function setAttrib(elm, attrib, value) {
	var formObj = formElement();
	var valueElm = formObj.elements[attrib.toLowerCase()];
	var dom = tinyMCEPopup.editor.dom;

	if (typeof(value) == "undefined" || value == null) {
		value = "";

		if (valueElm)
			value = valueElm.value;
	}

	// Clean up the style
	if (attrib == 'style')
		value = dom.serializeStyle(dom.parseStyle(value));

	dom.setAttrib(elm, attrib, value);
}

function insertAction() {
	var inst = tinyMCEPopup.editor;
	var elm, elementArray, i;
	var formObj = formElement();
	
	if(inst.selection.getContent().length <= 0){
		inst.selection.setContent('<a href="#mce_temp_url#">' + formObj.title.value + '</a>');
	}
	
	elm = inst.selection.getNode();
	checkPrefix(formObj.href);

	elm = inst.dom.getParent(elm, "A");

	// Remove element if there is no href
	if (!formObj.href.value) {
		tinyMCEPopup.execCommand("mceBeginUndoLevel");
		i = inst.selection.getBookmark();
		inst.dom.remove(elm, 1);
		inst.selection.moveToBookmark(i);
		tinyMCEPopup.execCommand("mceEndUndoLevel");
		tinyMCEPopup.close();
		return;
	}

	tinyMCEPopup.execCommand("mceBeginUndoLevel");

	// Create new anchor elements
	if (elm == null) {
		
		tinyMCEPopup.execCommand("CreateLink", false, "#mce_temp_url#", {skip_undo : 1});

		elementArray = tinymce.grep(inst.dom.select("a"), function(n) {return inst.dom.getAttrib(n, 'href') == '#mce_temp_url#';});
		for (i=0; i<elementArray.length; i++)
			setAllAttribs(elm = elementArray[i]);
	} else
		setAllAttribs(elm);

	// Don't move caret if selection was image
	if (elm.childNodes.length != 1 || elm.firstChild.nodeName != 'IMG') {
		inst.focus();
		inst.selection.select(elm);
		inst.selection.collapse(0);
		tinyMCEPopup.storeSelection();
	}

	tinyMCEPopup.execCommand("mceEndUndoLevel");
	tinyMCEPopup.close();
}

function setAllAttribs(elm) {
	var formObj = formElement();
	var href = formObj.href.value;
	var target = getSelectValue(formObj, 'targetlist');

	setAttrib(elm, 'href', href);
	setAttrib(elm, 'title');
	setAttrib(elm, 'target', target == '_self' ? '' : target);
	setAttrib(elm, 'id');
	setAttrib(elm, 'style');
	setAttrib(elm, 'class', getSelectValue(formObj, 'classlist'));
	setAttrib(elm, 'rel');
	setAttrib(elm, 'rev');
	setAttrib(elm, 'charset');
	setAttrib(elm, 'hreflang');
	setAttrib(elm, 'dir');
	setAttrib(elm, 'lang');
	setAttrib(elm, 'tabindex');
	setAttrib(elm, 'accesskey');
	setAttrib(elm, 'type');

	// Refresh in old MSIE
	if (tinyMCE.isMSIE5)
		elm.outerHTML = elm.outerHTML;
}

function getSelectValue(form_obj, field_name) {
	var elm = form_obj.elements[field_name];

	if (!elm || elm.options == null || elm.selectedIndex == -1)
		return "";

	return elm.options[elm.selectedIndex].value;
}

// While loading
preinit();
tinyMCEPopup.onInit.add(init);
