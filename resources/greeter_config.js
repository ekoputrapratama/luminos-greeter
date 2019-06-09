/**
 * Provides theme authors with a way to retrieve values from the greeter's config
 * file located at `/etc/lightdm/lightdm-webkit2-greeter.conf`. The greeter will
 * create an instance of this class when it starts. The instance can be accessed
 * with the global variable: `config`.
 * @memberOf LightDM
 */
class GreeterConfig {
  constructor() {
    this.config = new ConfigManager();
    let obj = this.config.read(
      CONFIG_DIR + "/" + "lightdm-webkit2-greeter.conf"
    );
    window.greeter_config = obj;
  }
  /**
   * Returns the value of `key` from the greeter's config file.
   *
   * @arg {String} key
   * @returns {String} Config value for `key`.
   */
  get_str(section, key) {
    return this.config.get(section, key);
  }
  /**
   * Returns the value of `key` from the greeter's config file.
   *
   * @arg {String} key
   * @returns {Boolean} Config value for `key`.
   */
  get_bool(section, key) {
    return Boolean(this.config.get(section, key));
  }
  /**
   * Returns the value of `key` from the greeter's config file.
   *
   * @arg {String} key
   * @returns {Number} Config value for `key`.
   */
  get_num(section, key) {
    return parseInt(this.config.get(section, key));
  }
}

if (typeof config === "undefined") window.config = new GreeterConfig();

/**
 * Provides theme authors with a way to retrieve values from the greeter's theme config
 * file located at `/usr/share/lightdm-webkit/themes/[theme name]/config.json`. The greeter will
 * create an instance of this class when it starts. The instance can be accessed
 * with the global variable: `theme_config`.
 * @memberOf LightDM
 */
class ThemeConfig {
  constructor() {
    const themeName = greeter_config.greeter.webkit_theme;

    this.configMgr = new ConfigManager();
    // this.config = this.configMgr.read(
    //   THEMES_DIR + "/" + themeName + "/" + "config.json"
    // );
  }
  /**
   * Load theme config in case theme authors not using default filename and return the config value.
   *
   * @arg {String} key
   * @returns {Object} Theme config value.
   */
  read(name) {
    this.config = this.configMgr.read(
      THEMES_DIR + "/" + themeName + "/" + name
    );
    return this.config;
  }
  /**
   * Returns the value of `key` from the theme config file.
   *
   * @arg {String} key
   * @returns {String} Config value for `key`.
   */
  get(key) {
    return this.config[key];
  }
}
if (typeof theme_config === "undefined")
  window.theme_config = new ThemeConfig();
