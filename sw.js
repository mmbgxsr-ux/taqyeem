const V='vt-v12';
const SHELL=['./','./index.html','./manifest.webmanifest','./icon-192.png','./icon-512.png'];
const EXT=['https://cdn.jsdelivr.net/npm/mp4-muxer@5.1.3/build/mp4-muxer.js','https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js','https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js'];
const FONTS=['https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap','https://fonts.googleapis.com/css2?family=Playpen+Sans+Arabic:wght@400;600&display=swap'];
const HOSTS=['cdn.jsdelivr.net','cdnjs.cloudflare.com','fonts.googleapis.com','fonts.gstatic.com'];
self.addEventListener('install',e=>{
  e.waitUntil((async()=>{
    const c=await caches.open(V);
    await c.addAll(SHELL);
    for(const u of EXT){try{const r=await fetch(u,{mode:'cors'});if(r.ok)await c.put(u,r)}catch(_){}}
    for(const u of FONTS){
      try{
        const r=await fetch(u,{mode:'cors'});if(!r.ok)continue;
        const css=await r.clone().text();await c.put(u,r);
        for(const f of new Set(css.match(/https:\/\/fonts\.gstatic\.com[^)'"\s]+/g)||[])){try{const fr=await fetch(f,{mode:'cors'});if(fr.ok)await c.put(f,fr)}catch(_){}}
      }catch(_){}
    }
    self.skipWaiting();
  })());
});
self.addEventListener('activate',e=>{
  e.waitUntil((async()=>{
    for(const k of await caches.keys())if(k!==V)await caches.delete(k);
    await self.clients.claim();
  })());
});
self.addEventListener('fetch',e=>{
  const r=e.request;if(r.method!=='GET')return;
  const u=new URL(r.url);
  if(u.origin!==location.origin&&!HOSTS.includes(u.hostname))return;
  e.respondWith((async()=>{
    const c=await caches.open(V),hit=await c.match(r,{ignoreSearch:true});
    const net=fetch(r).then(res=>{if(res&&(res.ok||res.type==='opaque'))c.put(r,res.clone());return res}).catch(()=>null);
    if(hit){e.waitUntil(net);return hit}
    const res=await net;
    return res||(r.mode==='navigate'?c.match('./index.html'):Response.error());
  })());
});
