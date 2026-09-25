(function(global){
  function resolveAsset(path){
    try { return new URL(path, document.baseURI).href; }
    catch(_) { return path; }
  }

  function mount(container, options){
    if(typeof container === 'string') container=document.querySelector(container);
    if(!container) throw new Error('LowdrusGUI: container não encontrado.');

    options=options||{};

    var root=document.createElement('div');
    root.className='lowdrus-gui';
    root.dataset.dim=options.dim ? 'true' : 'false';
    root.innerHTML='\n      <video class="lowdrus-gui__video" autoplay loop playsinline preload="auto" muted></video>\n      <div class="lowdrus-gui__shade"></div>\n      <div class="lowdrus-gui__content"></div>';

    var video=root.querySelector('video');
    var content=root.querySelector('.lowdrus-gui__content');

    var defaultVideo=resolveAsset('../../lowdrus_gui/assets/lowdrus_razer_plush.mp4');
    var defaultPoster=resolveAsset('../../lowdrus_gui/assets/preview.jpg');

    video.src=options.src || defaultVideo;
    video.poster=options.poster || defaultPoster;
    video.muted=true;
    video.defaultMuted=true;
    video.volume=0;
    video.setAttribute('muted','');

    video.addEventListener('volumechange',function(){
      if(!video.muted || video.volume!==0){
        video.muted=true;
        video.volume=0;
      }
    });

    video.addEventListener('error',function(){
      root.dataset.videoError='true';
    });

    if(options.fit) video.style.objectFit=options.fit;

    container.innerHTML='';
    container.appendChild(root);

    if(options.content){
      if(options.content instanceof Node) content.appendChild(options.content);
      else content.innerHTML=String(options.content);
    }

    var playPromise=video.play();
    if(playPromise && typeof playPromise.catch==='function'){
      playPromise.catch(function(){ /* muted autoplay may be deferred by the host */ });
    }

    return {
      element:root,
      video:video,
      content:content,
      play:function(){return video.play();},
      pause:function(){video.pause();},
      setDim:function(v){root.dataset.dim=v?'true':'false';},
      setOpacity:function(v){video.style.opacity=String(Math.max(0,Math.min(1,Number(v))));},
      destroy:function(){video.pause(); root.remove();}
    };
  }

  global.LowdrusGUI={mount:mount};
})(window);
