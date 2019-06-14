import { get } from './config.js';
/**
 *
 *
 * @export
 * @param {Object} config
 */
export function setupTheme(config) {
  $("#container").css(config.styles.panel);
  $(document.body).css({
    '--primary-color': config.pallete.primary,
    '--secondary-color': config.pallete.secondary,
    '--accent-color': config.pallete.accent
  });
  setBannerImage(config.banner);

  setActionButtonStyle(config.styles["actionButton"]);
  setActionButtonHoverStyle(config.styles["actionButton:hover"]);
  setInputLineStyle(config.styles["inputLine"]);
  setInputStyle(config.styles["input"]);
}
/**
 *
 *
 * @export
 * @param {Object} style
 */
export async function setActionButtonStyle(style) {
  let s = $(".actionButton").attr("style") || "";
  for (let i in style) {
    s += `--action-button-${i.toLowerCase()}:${style[i]};`;
  }
  $(".actionButton").attr("style", s);
}
/**
 *
 *
 * @export
 * @param {Object} style
 */
export function setActionButtonHoverStyle(style) {
  let s = $(".actionButton").attr("style") || "";
  for (let i in style) {
    s += `--action-button-hover-${i.toLowerCase()}:${style[i]};`;
  }
  $(".actionButton").attr("style", s);
  $(".other-account").attr("style", s);
}
/**
 *
 *
 * @export
 * @param {Object} style
 */
export function setInputLineStyle(style) {
  let s = $(".input").attr("style") || "";
  for (let i in style) {
    s += `--input-line-${i.toLowerCase()}:${style[i]};`;
  }
  $(".input").attr("style", s);
}

export function setInputStyle(style) {
  let s = $(".input").attr("style") || "";
  for (let i in style) {
    s += `--input-${i.toLowerCase()}:${style[i]};`;
  }
  $(".input").attr("style", s);
}
/**
 *
 *
 * @export
 * @param {String} image
 */
export function setBannerImage(image) {
  $("#signin-banner img").attr("src", `themes://luminos/img/banners/${image}.png`);
}
/**
 *
 *
 * @param {String} id
 * @returns {String}
 */
function getFAIconString(id) {
  if (id == "shutdown") {
    return "power-off";
  } else if (id == "hibernate") {
    return "asterisk";
  } else if (id == "suspend") {
    return "arrow-down";
  } else if (id == "restart") {
    return "refresh";
  }
}
/**
 *
 *
 * @export
 * @param {String} id
 * @param {String} label
 * @returns {String}
 */
export function createActionLink(id, label) {
  const icon = getFAIconString(id);
  return `
    <button type="button" class="btn btn-default ${id} actionButton" data-toggle="tooltip" data-placement="top" title="${label}"
      data-container="body" onclick="handleAction('${id}')">
      <i class="fa fa-${icon}"></i>
    </button>`
}
/**
 *
 *
 * @export
 * @param {Object} user
 * @param {String} lastSession
 * @param {String} fallbackImage
 * @returns {String}
 */
export function createUserItem(user, lastSession, fallbackImage) {
  var imageSrc = user.image ? user.image : fallbackImage;
  return `
    <li class="account">
      <div href="#${user.name}" class="item" onclick="authenticate(event,'${user.name}')" data-session="${lastSession}">
        <div class="pic" aria-hidden="true">
          <img src="${imageSrc}" alt="">
        </div>
        <div class="info">
          <p role="presentation" class="wpW1cb">${user.display_name}</p>
          <p class="uRhzae" role="heading" aria-level="2">Last Session ${lastSession}</p>
        </div>
      </div>
    </li>`;
}

export function createSessionItem(session) {
  let theClass = session.name.replace(/ /g, "");
  return `
    <li>
      <a href="#" data-session-id="${session.key}" onclick="sessionToggle(this)" class="${theClass}">
        ${session.name}
      </a>
    </li>`;
}
