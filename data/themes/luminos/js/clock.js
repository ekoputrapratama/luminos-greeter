let analogclock, digitalclock, secondshand, minuteshand, hourshand, soundtoggle, context;
let now, h, m, s, timerid;

document.addEventListener('DOMContentLoaded', function (e) {
  try { init(); } catch (error) {
    console.log("Data didn't load", error);
  }
});

function init() {
  digitalclock = gid("digitalclock");
  update();
  timerid = setInterval(update, 1000);
}

function update() {
  now = new Date();
  h = now.getHours();
  m = now.getMinutes();
  s = now.getSeconds();
  digitalclock.innerHTML = now.toLocaleTimeString();
  //timerid = requestAnimationFrame(update);
}

function gid(idstring) {
  //saves lots of typing for those who eschew Jquery
  return document.getElementById(idstring);
}

lightdm.onAuthenticationComplete = () => {
  log("onAuthenticationComplete()");
}
