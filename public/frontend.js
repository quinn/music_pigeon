window._ = jQuery;

_.fn.editInPlace = function(e) {
  var parent = this.parent(), input;
  _('input').blur();
  this.replaceWith('<input type="text">');
  (input = parent.children('input'))
  .val(this.text())
  .focus()
  .attr('size',input.val().length)
  .one('blur', function() {
		p= parent
    _.ajax({
       type: 'PUT'
		  ,url: '/songs/'+parent.parent()[0].id.replace(/song-/, '')
			,data: {
				title: input.val()
			}
			,success: function (message) {
				console.log(message)
			}
		});
		if (input.val().replace(/( |\t|\n)/g, '') == '') {
			parent.remove();
		}
		else {
			input.replaceWith('<span>' + input.val() + '</span>');
			parent.children('span').bind('click', editMe);
		}
  })
  .keydown(function(e){
    input.attr('size', parseInt(input.attr('size')) + 1);
  })
  .keyup(function(e){
    input.attr('size',input.val().length);
  });

  if(e) {
    input.each(function(i, el){
      var node = _(el);
      var offset = e.pageX - node.offset().left;
      var charWidth = node.width() / node.attr('size');      
      var pos = Math.floor(offset / charWidth);
      el.setSelectionRange(pos, pos);
    });
  }
};

_.fn.ajaxify= function (c) {
  _(this).submit(function () {
    params= {}; 
    _('#add_new form input').each(function () { 
      params[this.name]= this.value
    })
    _.ajax({
       type: this.method
      ,url: this.action
      ,data: _(this).serialize()
      ,success: c.success
      ,error: c.error
    });
    return false;
  });
};

_(document).ready(function(){
  //for songs
  function editMe() {
    _(this).editInPlace();
  }
	_('.title span').bind('click', editMe);
	_("#songs").tablesorter( {sortList: [[0,0], [1,0]]} ); 
	
	//for keywords
	_('#add_new a').click(function () {
	  _(this).addClass('hidden');
	  _('#add_new form')
	    .removeClass('hidden')
	    .ajaxify({
	      success: function (data, status) {
	        _('#add_new form').addClass('hidden');
	        _('#add_new a').removeClass('hidden');
	        _('#keywords_list').append('<li>'+_('#add_new form input').val()+'</li>')
	      }
  	    ,error: function (request, status, error) {
	        alert('An Error occured.');
  	    }
	    });
	  return false;
	});
});



