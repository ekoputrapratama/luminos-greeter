/*
 * Copyright © 2019 Luminos
 *
 * greeter.js
 *
 * This file is part of luminos-greeter
 *
 * luminos-greeter is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License,
 * or any later version.
 *
 * luminos-greeter is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * The following additional terms are in effect as per Section 7 of this license:
 *
 * The preservation of all legal notices and author attributions in
 * the material or in the Appropriate Legal Notices displayed
 * by works containing it is required.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import './cache.js';
import { setBackground, loadBackgroundList } from './bg_utils.js';
import { createActionLink, setupTheme, setActionButtonStyle, setActionButtonHoverStyle, createSessionItem } from './theme_utils.js';
import { showPanel, slideContent } from './animation.js';
import { log, showLog, hideLog } from './logging.js';
import { getConfig } from './config.js';
import { createUserItem } from './theme_utils.js';

var selectedUser = null,
  authPending = null,
  animating = false;

const defaultBackground = "themes://luminos/img/default-bg.jpg";
const defaultUserImage = "themes://luminos/img/icons/user.png";

const cfg = getConfig();

function capitalize(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

function get_hostname() {
  var hostname = lightdm.hostname;
  var hostname_span = document.getElementById("hostname");
  $(hostname_span).append(hostname);
}

function getUserLastSession(username) {
  var lastSession = _cache.get(username);

  if (lastSession === null || lastSession === undefined) {
    _cache.set(username, lightdm.default_session);
    lastSession = _cache.get(username);
  }
  return lastSession;
}
function buildUserList() {
  // User list building
  var accountList = $(".account-list");
  for (var i in lightdm.users) {
    let user = lightdm.users[i];
    let lastSession = getUserLastSession(user.name);
    log("Last Session (" + user.name + "): " + lastSession);
    let item = createUserItem(user, lastSession, defaultUserImage);
    $(accountList).append(item);
  }

  $(".account-list .item").hover(
    function () {
      $(this).css(cfg.styles["accountListItem:hover"]);
    },
    function () {
      $(this).css(cfg.styles["accountListItem"]);
    }
  );
}

function buildSessionList() {
  // Build Session List
  var btnGrp = $("#sessions");
  for (var i in lightdm.sessions) {
    var session = lightdm.sessions[i];
    var theClass = session.name.replace(/ /g, "");
    var button = createSessionItem(session);

    $(btnGrp).append(button);
  }
  $(".dropdown-toggle").dropdown();
}
/**
   * Actions management.
   *
   *
   */

function update_time() {
  var time = document.getElementById("current_time");
  var date = new Date();
  var twelveHr = [
    "sq-al",
    "zh-cn",
    "zh-tw",
    "en-au",
    "en-bz",
    "en-ca",
    "en-cb",
    "en-jm",
    "en-ng",
    "en-nz",
    "en-ph",
    "en-us",
    "en-tt",
    "en-zw",
    "es-us",
    "es-mx"
  ];
  var userLang = window.navigator.language;
  var is_twelveHr = twelveHr.indexOf(userLang);
  var hh = date.getHours();
  var mm = date.getMinutes();
  var suffix = "AM";
  if (hh >= 12) {
    suffix = "PM";
    if (is_twelveHr !== -1 && is_twelveHr !== 12) {
      hh = hh - 12;
    }
  }
  if (mm < 10) {
    mm = "0" + mm;
  }
  if (hh === 0 && is_twelveHr !== -1) {
    hh = 12;
  }
  if (is_twelveHr === -1) {
    suffix = "";
  }
  time.innerHTML = hh + ":" + mm + " " + suffix;
}

function initialize_timer() {
  var userLang = window.navigator.language;
  log(userLang);
  update_time();
  // setInterval(update_time, 60000);
}

function addActionLink(id) {
  if (eval("lightdm.can_" + id)) {
    var label = id.substr(0, 1).toUpperCase() + id.substr(1, id.length - 1);

    const actionItem = createActionLink(id, label);
    $("#actionsArea").append(actionItem);

    if (cfg && cfg.styles) {
      setActionButtonStyle(cfg.styles.actionButton);
      setActionButtonHoverStyle(cfg.styles['actionButton:hover']);
    }
  }
}
window.handleAction = function (id) {
  log("handleAction(" + id + ")");
  eval("lightdm." + id + "()");
};

window.authenticate = function (e, username, skipStart = false) {
  slideContent(e);
  if (selectedUser !== null) {
    lightdm.cancel_authentication();
    _cache.set("selUser", null);
    log("authentication cancelled for " + selectedUser);
  }
  selectedUser = username;
  _cache.set("selUser", username);

  var usrSession = _cache.get(username);

  log("user session: " + usrSession);
  var usrSessionEl = "[data-session-id=" + usrSession + "]";
  var usrSessionName = $(usrSessionEl).html();
  $(".selected").html(usrSessionName);
  $(".selected").attr("data-session-id", usrSession);
  $("#session-list").removeClass("hidden");
  $("#session-list").show();
  $(".dropdown-toggle").dropdown();
  authPending = true;

  if (!skipStart) {
    log("start authentication");
    lightdm.start_authentication(username);
  }
};

// window.cancelAuthentication = function () {
//   log("cancelAuthentication()");
//   $("#session-list").hide();
//   lightdm.cancel_authentication();
//   log("authentication cancelled for : %s", selectedUser);
//   $(".fa-toggle-down").show();
//   selectedUser = null;
//   authPending = false;
//   return true;
// };

/**
 * Image loading management.
 */

window.imgNotFound = function (source) {
  source.src = "img/logo-user.png";
  source.onerror = "";
  return true;
};

window.sessionToggle = function (el) {

  var selText = $(el).text();
  var theID = $(el).attr("data-session-id");
  var selUser = _cache.get("selUser");
  log(`selected session changed to ${theID}`);
  $(el)
    .parents(".btn-group")
    .find(".selected")
    .attr("data-session-id", theID);
  $(el)
    .parents(".btn-group")
    .find(".selected")
    .html(selText);
  _cache.set(selUser, theID);
};

$(window).on("load", function () {
  /**
   * UI Initialization.
   */
  if (!_cache.has("bgdefault") && !_cache.has("bgsaved")) {
    _cache.set("bgdefault", "1");
  }

  if (_cache.has("bgsaved") && _cache.get("bgdefault", "1") === "0") {
    setBackground(
      _cache.get("bgsaved"),
      cfg && cfg.styles ? cfg.styles.background : {}, showPanel
    );
  } else {
    setBackground(defaultBackground, cfg && cfg.styles ? cfg.styles.background : {}, showPanel);
  }

  $(".other-account").click(function (e) {
    $(".selected-user").html("");
    $(".content").css({
      marginLeft: "0px"
    });
    $("#session-list .selected").html("");
    $("#session-list").addClass("hidden");
    $("#session-list").addClass("hidden");
    lightdm.cancel_authentication();
    $("#pass").val("");
    $('.password-message').removeClass("show");
    log("authentication cancelled for " + selectedUser);
    selectedUser = null;
    authPending = false;
  });

  $(".login__submit").click(function (e) {
    e.preventDefault();
    if (animating) return;
    animating = true;
    $(this).addClass("processing");
    log(`respond(${$("#pass").val()})`);
    lightdm.respond($("#pass").val());
  });
  // Password submit when enter key is pressed
  $("#pass").keydown(function (e) {
    switch (e.which) {
      case 13:
        $(".login__submit").trigger("click");
        break;
    }
  });
});

function getUserByName(username) {
  let u = null;
  lightdm.users.forEach(user => {
    if (user.name == username) {
      u = user;
    }
  });
  return u;
}
$(document).ready(function () {
  setupTheme(cfg);
  loadBackgroundList(cfg.backgrounds, cfg.styles);
  buildUserList();
  buildSessionList();

  // Action buttons
  addActionLink("shutdown");
  addActionLink("hibernate");
  addActionLink("suspend");
  addActionLink("restart");

  /**
   * Check whatever we need to automaticly prompt a password input to
   * user. This case happen when lightdm.select_user_hint is set or when
   * there is only 1 user available.
   */
  let selectUser = lightdm.select_user_hint;
  let userToSelect = (selectUser != null) ? selectUser : null;
  let userSelected = false;
  let currentUser = null;

  if (userToSelect != null) {
    let user = getUserByName(userToSelect);
    if (user !== null) {
      currentUser = user;
      userSelected = true;
    }
  } else if (userToSelect === null && lightdm.users.length === 1) {
    let user = null;
    lightdm.users.forEach((u) => {
      user = u;
    });
    if (user !== null) {
      currentUser = user;
      userSelected = true;
    }
  }

  if (userSelected) {
    const lastSession = getUserLastSession(currentUser.name);
    const user = currentUser;
    const imageSrc = user.image ? user.image : defaultUserImage;
    var item = `
      <div href="#${user.name}" class="item" onclick="authenticate(event,'${user.name}')" data-session="${lastSession}">
        <div class="pic" aria-hidden="true">
          <img src="${imageSrc}" alt="">
        </div>
        <div class="info">
          <p role="presentation" class="wpW1cb">${user.display_name}</p>
          <p class="uRhzae" role="heading" aria-level="2">Last Session ${lastSession}</p>
        </div>
      </div>
    `;
    authenticate({ target: $(item)[0] }, user.name);
  }
});

window.toggleConsole = (e) => {
  $('#logArea').toggleClass("show");
}

window.onbeforeunload = () => {
  setShouldDestroyInstance(true);
}

/**
 * Lightdm Callbacks
 */
function show_prompt(text, type) {
  log("show_prompt(" + text + "," + type + ")");
  if (type === "password") {
    const currentUser = lightdm.currentUser;
    const lastSession = getUserLastSession(currentUser.name);
    const item = createUserItem(currentUser, lastSession, defaultUserImage);
    const html = $(item)[0];
    slideContent({ target: html });
  }
}

lightdm.onAuthenticationComplete = function () {
  log("onAuthenticationComplete()");
  authPending = false;
  var selSession = $(".selected").attr("data-session-id");
  if (lightdm.is_authenticated) {
    log("authenticated !");
    setTimeout(() => {
      $(".login__submit").removeClass("processing");
      $("#container").fadeTo("slow", 0, function () {
        $("#bg").fadeTo("slow", 0, function () {
          log(`login user with session ${selSession}`);
          lightdm.login(lightdm.authentication_user, selSession);
        });
      });
    }, 500);
  } else {
    log("not authenticated !");
    animating = false;
    $(".login__submit").removeClass("processing");
    $('.password-message').toggleClass("show");
  }
}


