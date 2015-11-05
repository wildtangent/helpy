// Sets up autoscroll for any link with class autoscroll
// requires data-target param containing class or ID of target
$(document).ready(function(){
  $(".autoscroll").each(function(){
      $(this).click(function(){
        var scrollTarget=$(this).data("target");
        $('html,body').animate({
          scrollTop: $(scrollTarget).offset().top-40},'slow');
        });
  });

  $(".demo-link").click(function(){
    ga('send', 'event', 'Click', 'Demo')
  });

  $(".github-link").click(function(){
    ga('send', 'event', 'Click', 'Github')
  });

});
