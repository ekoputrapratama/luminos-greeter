import { log } from './logging.js';




/**  @type {HTMLIFrameElement} */
const iframe = document.querySelector("#bg");
/** @type {HTMLBodyElement} */
let iframeBody = iframe.contentDocument.body;
let useHtmlBg = false;

iframe.addEventListener('change', () => {
  disableContextMenu();
});

// iframeBody.style.transition = 'background opacity 0.4s ease-in';
// disable context menu in iframe
function disableContextMenu() {
  iframe.contentWindow.oncontextmenu = (e) => {
    console.log("oncontextmenu");
    return false
  };
}

$("#bg-switch-close").click(function (e) {
  e.preventDefault();
  $("#bg-switch-wrapper").toggleClass("active");
  $(this).css({ visibility: 'hidden' });
  $("#bg-switch-toggle").css({ visibility: 'visible' });
});

$("#bg-switch-toggle").click(function (e) {
  e.preventDefault();
  $(this).css({ visibility: 'hidden' });
  $("#bg-switch-wrapper").toggleClass("active");

  $("#bg-switch-close").css({ visibility: 'visible' });
});

$("*").each(function () {
  $(this).attr("tabindex", -1);
});

$("#collapseTwo").on("shown.bs.collapse", function () {
  $("#collapseTwo a")
    .filter(":not(.dropdown-menu *)")
    .each(function (index) {
      var i = index + 1;
      $(this).attr("tabindex", i);
    });
});

$("#collapseTwo").on("hidden.bs.collapse", function () {
  $("#collapseTwo a")
    .filter(":not(.dropdown-menu *)")
    .each(function (index) {
      $(this).attr("tabindex", -1);
    });
});


/**
 *
 *
 * @export
 * @param {Array} backgrounds
 * @param {Object} styles
 */
export function loadBackgroundList(backgrounds, styles) {

  backgrounds.forEach(function (background) {
    $(".bgs").append(`
          <a href="#" data-img="themes://luminos/${background.image}" class="background clearfix">
            <img src="${background.thumb}" />
          </a>
    `);
  });

  (bglist(BACKGROUNDS_DIR) || []).forEach(item => {
    if (item.html) {
      const img = (item.image) ? item.image : 'themes://luminos/img/no_image.jpg';
      $(".bgs").append(`
            <a href="#" data-url="${item.url}" class="background clearfix">
              <img src="${img}" />
            </a>
      `);
    } else {
      const img = (item.image) ? item.image : 'themes://luminos/img/no_image.jpg';
      $(".bgs").append(`
            <a href="#" data-img="${img}" class="background clearfix">
              <img src="${img}" />
            </a>
      `);
    }
  });

  var $btns = $(".bgs .background");
  $btns.click(function (e) {
    e.preventDefault();
    $btns.removeClass("active");
    $(".bgs .background .default")
      .first()
      .removeClass("active");

    $(this).addClass("active");
    var bg = $(this).data("img") || $(this).data("url");
    if (bg == "default") {
      _cache.set("bgdefault", "1");
      defaultBG();
    } else {
      _cache.set("bgdefault", "0");
      setBackground(
        bg,
        styles.background
      );
      _cache.set("bgsaved", bg);
    }
  });
}
/**
 *
 *
 * @param {String} url
 * @returns {Boolean}
 */
function isHtmlBackground(url) {
  const regex = /\.([0-9a-zA-Z]+)$/;
  const res = url.match(regex);
  return res && res.length > 1 && res[1] === 'html';
}
/**
 *
 *
 * @export
 * @param {String} url
 * @param {Object} [style={}]
 */
export function setBackground(url, style = {}, cb = null) {
  const isHtml = isHtmlBackground(url);
  if (isHtml) {
    useHtmlBg = true;
    $(iframe).fadeTo("fast", 0, function () {
      // need to fetch it first to inject our script
      fetch(url).then(async res => {
        const response = await res.text();
        const parser = new DOMParser();
        const doc = parser.parseFromString(response, "text/html");
        const str = `
        <html>
          <head>
            <script src="themes://luminos/js/cache.js"></script>
            <script src="vendor://js/mime.min.js"></script>
            <script src="themes://luminos/js/background.js"></script>
            ${doc.head.innerHTML}
          </head>
          <body>
            ${doc.body.innerHTML}
          </body>
        </html>`;
        iframe.src = "data:text/html;charset=utf-8," + escape(str);
        $(iframe).fadeTo("slow", 1, cb);
        _cache.set("bgsaved", url);
      });
    });
  } else {
    $(iframe).fadeTo("fast", 0, function () {
      let data = url;
      if (useHtmlBg) {
        const onIframeLoad = () => {
          iframe.contentWindow.postMessage({ url: data }, '*');
          iframe.removeEventListener('load', onIframeLoad);
        };
        iframe.addEventListener('load', onIframeLoad);
        iframe.src = "themes://luminos/background.html";
        useHtmlBg = false;
      } else {
        iframe.contentWindow.postMessage({ url: data }, '*')
      }
      _cache.set("bgsaved", url);
      $(iframe).fadeTo("slow", 1, cb);
    });
  }
}
