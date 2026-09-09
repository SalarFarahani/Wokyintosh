
function dismissBoot(){
  const b=document.getElementById('boot');
  if(!b)return;
  b.classList.add('boot-hidden');
  setTimeout(()=>{ if(b&&b.parentNode)b.remove(); },220);
}
window.addEventListener('DOMContentLoaded',()=>setTimeout(dismissBoot,700));
window.addEventListener('load',()=>setTimeout(dismissBoot,550));

const $=id=>document.getElementById(id);
let lastArtwork="";

function tickClock(){
  const n=new Date();
  $('time').textContent=new Intl.DateTimeFormat('en-GB',{hour:'2-digit',minute:'2-digit',hour12:false}).format(n);
  $('date').textContent=new Intl.DateTimeFormat('en-GB',{weekday:'long',day:'numeric',month:'short',year:'numeric'}).format(n).replace(',',' ·');
}

function weatherMeta(code){
  const m={
    0:['clear','Clear'],1:['partly','Mostly clear'],2:['partly','Partly cloudy'],3:['cloud','Cloudy'],
    45:['fog','Fog'],48:['fog','Fog'],51:['drizzle','Drizzle'],53:['drizzle','Drizzle'],55:['drizzle','Drizzle'],
    61:['rain','Rain'],63:['rain','Rain'],65:['rain','Heavy rain'],71:['snow','Snow'],73:['snow','Snow'],
    75:['snow','Heavy snow'],80:['rain','Showers'],81:['rain','Showers'],82:['rain','Heavy showers'],95:['storm','Thunderstorm']
  };
  return m[code]||['cloud','Weather'];
}
function weatherSVG(type){
  const cloud=`<path class="wx-fill" d="M24 72h47c13 0 23-8 23-19 0-10-8-18-19-19-4-11-15-18-29-18-16 0-29 10-32 24C6 42 1 49 1 58c0 8 4 14 10 18 4 3 8 4 13 4z"/>`;
  const icons={
    clear:`<svg viewBox="0 0 100 100"><circle class="wx-fill" cx="50" cy="50" r="20"/><path class="wx-stroke" d="M50 8v14M50 78v14M8 50h14M78 50h14M20 20l10 10M70 70l10 10M20 80l10-10M70 30l10-10"/></svg>`,
    partly:`<svg viewBox="0 0 100 100"><circle class="wx-fill" cx="34" cy="35" r="14"/>${cloud}</svg>`,
    cloud:`<svg viewBox="0 0 100 100">${cloud}</svg>`,
    fog:`<svg viewBox="0 0 100 100">${cloud}<path class="wx-stroke" d="M16 78h68M10 90h64"/></svg>`,
    drizzle:`<svg viewBox="0 0 100 100">${cloud}<path class="wx-stroke" d="M28 78l-3 10M50 78l-3 10M72 78l-3 10"/></svg>`,
    rain:`<svg viewBox="0 0 100 100">${cloud}<path class="wx-stroke" d="M24 76l-5 15M46 76l-5 15M68 76l-5 15M90 76l-5 15"/></svg>`,
    snow:`<svg viewBox="0 0 100 100">${cloud}<path class="wx-stroke" d="M25 82h14M32 75v14M58 82h14M65 75v14"/></svg>`,
    storm:`<svg viewBox="0 0 100 100">${cloud}<path class="wx-fill" d="M53 68L39 89h13l-5 11l23-26H56l7-6z"/></svg>`
  };
  return icons[type]||icons.cloud;
}
function setArtwork(url){
  const img=$('artwork'),fallback=$('fallback-art');
  if(!url){img.classList.add('hidden');fallback.style.display='block';lastArtwork='';return}
  if(url===lastArtwork&&!img.classList.contains('hidden'))return;
  lastArtwork=url;
  img.onload=()=>{img.classList.remove('hidden');fallback.style.display='block'};
  img.onerror=()=>{img.classList.add('hidden');fallback.style.display='block';lastArtwork=''};
  img.src=url;
}
function meter(id,v){$(id).style.width=`${Math.max(0,Math.min(100,Number(v)||0))}%`}
function fmt(s){s=Math.max(0,Math.floor(Number(s)||0));return `${String(Math.floor(s/60)).padStart(2,'0')}:${String(s%60).padStart(2,'0')}`}

window.WokyintoshNative={
  updateSystem(d){
    $('cpu').textContent=`${Math.round(d.cpu||0)}%`;
    $('ram').textContent=`${Math.round(d.ram||0)}%`;
    const f=Number(d.ssd_free_gb||0);
    $('ssd').textContent=f>=1024?`${(f/1024).toFixed(1)} TB`:`${Math.round(f)} GB`;
    $('net').textContent=d.net_rate||'0 KB/s';
    meter('cpu-bar',d.cpu);meter('ram-bar',d.ram);meter('ssd-bar',d.disk_used_pct);
    const m=String(d.net_rate||'').match(/([\d.]+)/);let n=m?Number(m[1]):0;if(String(d.net_rate).includes('MB'))n*=18;meter('net-bar',Math.min(100,n));
  },
  updateNowPlaying(d){
    if(!d.playing){
      $('track').textContent='Nothing playing';$('artist').textContent='Music / Spotify';$('source').textContent='—';$('elapsed').textContent='00:00 / 00:00';$('progress-bar').style.width='0%';$('play-state').textContent='▶';setArtwork('');return;
    }
    $('track').textContent=d.track||'Unknown track';$('artist').textContent=d.artist||'';$('source').textContent=d.app||'';
    $('elapsed').textContent=`${fmt(d.position)} / ${fmt(d.duration)}`;
    const p=d.duration>0?Math.max(0,Math.min(100,d.position/d.duration*100)):0;$('progress-bar').style.width=`${p}%`;
    $('play-state').textContent=d.state==='playing'?'Ⅱ':'▶';setArtwork(d.artwork_url||'');
  },
  updateWeather(d){
    if(Number(d.weather_code)===-1){$('weather-temp').textContent='--°C';$('weather-text').textContent='Offline';$('location-name').textContent=d.location||'LOCAL';$('weather-icon').innerHTML=weatherSVG('cloud');return}
    const [type,text]=weatherMeta(Number(d.weather_code));$('weather-icon').innerHTML=weatherSVG(type);$('weather-temp').textContent=`${Math.round(d.temperature)}°C`;$('weather-text').textContent=text;$('location-name').textContent=d.location||'LOCAL';
  }
};

tickClock();setInterval(tickClock,1000);

document.title='Wokyintosh — UI Ready';
