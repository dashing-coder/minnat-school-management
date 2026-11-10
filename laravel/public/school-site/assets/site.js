(()=>{'use strict';
const toggle=document.querySelector('[data-menu-toggle]');
const nav=document.querySelector('[data-nav]');
const close=()=>{if(nav)nav.classList.remove('open');if(toggle){toggle.setAttribute('aria-expanded','false');toggle.setAttribute('aria-label','Open navigation menu');}};
if(toggle&&nav){toggle.addEventListener('click',()=>{const next=!nav.classList.contains('open');nav.classList.toggle('open',next);toggle.setAttribute('aria-expanded',String(next));toggle.setAttribute('aria-label',next?'Close navigation menu':'Open navigation menu');});document.addEventListener('keydown',e=>{if(e.key==='Escape')close();});document.addEventListener('click',e=>{if(!nav.contains(e.target)&&!toggle.contains(e.target))close();});window.addEventListener('resize',()=>{if(window.innerWidth>870)close();});nav.querySelectorAll('a').forEach(a=>a.addEventListener('click',close));}
for(const form of document.querySelectorAll('[data-demo-form]')){form.addEventListener('submit',e=>{e.preventDefault();const feedback=form.querySelector('[data-form-feedback]');if(!form.reportValidity())return;if(feedback){feedback.hidden=false;feedback.textContent='Preview only: your form is valid, but no information was sent or saved. Connect a secure backend before publishing.';feedback.focus();}});}
const year=document.querySelectorAll('[data-year]');year.forEach(el=>{el.textContent=String(new Date().getFullYear());});
})();
