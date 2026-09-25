(function(global){
  function mount(container, options){
    if(typeof container === 'string') container=document.querySelector(container);
    if(!container) throw new Error('LowdrusGUI: container não encontrado.');
    options=options||{};
    var root=document.createElement('div');
    root.className='lowdrus-gui';
    root.dataset.dim=options.dim ? 'true' : 'false';
    root.innerHTML='\n      <video class="lowdrus-gui__video" autoplay loop playsinline preload="auto"'+(options.muted!==false?' muted':'')+'></video>\n      <div class="lowdrus-gui__shade"></div>\n      <div class="lowdrus-gui__content"></div>';
    var video=root.querySelector('video');
    var content=root.querySelector('.lowdrus-gui__content');
    video.src=options.src || 'assets/lowdrus_razer_plush.mp4';
    if(options.poster) video.poster=options.poster;
    if(options.fit) video.style.objectFit=options.fit;
    container.innerHTML='';
    container.appendChild(root);
    if(options.content) {
      if(options.content instanceof Node) content.appendChild(options.content);
      else content.innerHTML=String(options.content);
    }
    var api={
      element:root, video:video, content:content,
      play:function(){return video.play();},
      pause:function(){video.pause();},
      mute:function(v){video.muted=(v===undefined?true:!!v);},
      setVolume:function(v){video.volume=Math.max(0,Math.min(1,Number(v)||0));},
      setDim:function(v){root.dataset.dim=v?'true':'false';},
      setOpacity:function(v){video.style.opacity=String(Math.max(0,Math.min(1,Number(v))));},
      destroy:function(){video.pause(); root.remove();}
    };
    return api;
  }
  global.LowdrusGUI={mount:mount};
})(window);
