# luminos-greeter

Another web greeter for LightDM.

#### Runtime Dependencies
|                         | ![antergos][antergos] &nbsp;&nbsp; ![arch][arch] | ![ubuntu][ubuntu]    | ![fedora][fedora]   | ![openSUSE][openSUSE] | 
|-------------------------|--------------------------------------------------|----------------------|---------------------|-----------------------|
|**webkit2gtk**           |webkit2gtk                                        |webkit2gtk            |webkit2gtk           |webkit2gtk             |
|**liblightdm-gobject**   |lightdm                                           |liblightdm-gobject-dev|lightdm-gobject-devel|liblightdm-gobject-1-0 |
|**glib**                 |glib                                              |libglib2.0-dev        |glib2-2.xx.x-x       |glib2                  |
|**gobject-introspection**|gobject-introspection                             |gobject-introspection |gobject-introspection|gobject-introspection  |

#### Development Dependencies
See meson.build for all dependencies used by luminos-greeter


## Debugging
You can run the greeter from within your desktop session if you add the following line to the desktop file for your session located in `/usr/share/xsessions/`: `X-LightDM-Allow-Greeter=true`.

You have to log out and log back in after adding that line. Then you can run the greeter from command line.

```sh
luminos-greeter
```
Themes can be opened with a debug console if you run luminos-greeter with --debug or -d option.

> ***Note:*** Do not use `lightdm --test-mode` as it is not supported.

> ***Warning:*** This is not the successor of antergos web-greeter, this project is written from scratch using vala but it provide compatibility for theme made using antergos web-greeter so it's possible to use web-greeter theme when using this greeter. But i can't promise you that i'll keep these compatibility for long, so it's recommended that you migrate as soon as possible.

[antergos]: https://antergos.com/distro-logos/logo-square26x26.png "antergos"
[arch]: https://antergos.com/distro-logos/archlogo26x26.png "arch"
[fedora]: https://antergos.com/distro-logos/fedora-logo.png "fedora"
[openSUSE]: https://antergos.com/distro-logos/Geeko-button-bling7.png "openSUSE"
[ubuntu]: https://antergos.com/distro-logos/ubuntu_orange_hex.png "ubuntu"
[debian]: https://antergos.com/distro-logos/openlogo-nd-25.png "debian"

[release]: https://img.shields.io/github/release/Antergos/web-greeter.svg?style=flat-square "Latest Release"
[codacy]: https://img.shields.io/codacy/grade/43c95c8c0e3749b8afa3bfd2b6edf541.svg?style=flat-square "Codacy Grade"
[circleci]: https://img.shields.io/circleci/project/Antergos/web-greeter/master.svg?style=flat-square "CI Status"
[api]: https://img.shields.io/badge/API--Docs-ready-brightgreen.svg?style=flat-square "Theme API Docs"
[aur]: https://img.shields.io/aur/votes/lightdm-webkit2-greeter.svg?maxAge=604800&style=flat-square "AUR Votes"
