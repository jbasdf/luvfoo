/**
 * $Id: editor_plugin_src.js 520 2008-01-07 16:30:32Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function() {
	tinymce.create('tinymce.plugins.AdvancedFileTooPlugin', {
		init : function(ed, url) {
			// Register commands
			ed.addCommand('mceAdvFileToo', function() {
				var e = ed.selection.getNode();

				// Internal file object like a flash placeholder
				if (ed.dom.getAttrib(e, 'class').indexOf('mceItem') != -1)
					return;

				ed.windowManager.open({
					file : url + '/file.htm?path=' + jQuery('#file-path').val() + 
								'&id=' + jQuery('#parent-id').val() + 
								'&type=' + jQuery('#parent-type').val() +
								'&sessionkey=' + jQuery('#session-key').val() + 
								'&sessionid=' + jQuery('#session-id').val(),
					width : 675 + parseInt(ed.getLang('advfiletoo.delta_width', 0)),
					height : 540 + parseInt(ed.getLang('advfiletoo.delta_height', 0)),
					inline : 1
				}, {
					plugin_url : url
				});
			});

			// Register button
			ed.addButton('file', {
				title : 'Upload Files',
				cmd : 'mceAdvFileToo',
				image : url + '/img/upload.gif'
			});
			
		},

		getInfo : function() {
			return {
				longname : 'Advanced file',
				author : 'Moxiecode Systems AB',
				authorurl : 'http://tinymce.moxiecode.com',
				infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/advfile',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('advfiletoo', tinymce.plugins.AdvancedFileTooPlugin);
})();