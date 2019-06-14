import { getConfig } from './config.js';


// setup input animation
$(".input input").focus(function () {
  $(this).parent(".input")
    .each(function () {
      $("label", this).css({
        "line-height": "18px",
        "font-size": "18px",
        "font-weight": "300",
        top: "0px"
      });

      $(".spin", this).css({
        width: "calc(100% - 80px)"
      });
    });
}).blur(function () {
  $(".spin").css({
    width: "0px"
  });
  if ($(this).val() == "") {
    $(this).parent(".input")
      .each(function () {
        $("label", this).css({
          "line-height": "60px",
          "font-size": "24px",
          "font-weight": "500",
          top: "10px"
        });
      });
  }
});


export function showPanel() {
  $("#container").fadeTo("slow", 1);
}
/**
 *
 *
 * @export
 * @param {MouseEvent} e
 * @returns {void}
 */
export function slideContent(e) {
  let cfg = getConfig();
  const selectedUser = e.target.cloneNode(true);
  selectedUser.onclick = undefined;
  selectedUser.removeAttribute("style");
  $(selectedUser).css(cfg.styles.selectedUser);
  $(".selected-user").append(selectedUser);

  const content = document.querySelector(".content");
  const onTransitionEnd = function (e) {
    $("#pass").focus();
    content.removeEventListener("transitionend", onTransitionEnd);
  };
  content.addEventListener("transitionend", onTransitionEnd);

  $(".content").css({
    marginLeft: "-450px"
  });
  $("#session-list .selected").html(e.target.getAttribute("data-session"));
}
