# Ресурсы из Goonstation

Часть спрайтов взята из Goonstation 13 (https://github.com/goonstation/goonstation).
Они распространяются по лицензии Creative Commons Attribution-NonCommercial-ShareAlike 3.0
(CC BY-NC-SA 3.0, `LICENSE-CC-BY-NC-SA-3.0.txt` в корне). Авторы — участники проекта Goonstation.

Код Goonstation не переносился: механики написаны заново под движок ATMTALAST.

| Файл | Откуда | Чем собирается |
| --- | --- | --- |
| `icons/obj/goon_decor.dmi` | `icons/obj/decoration.dmi`, `decals/wallsigns.dmi`, `decals/posters.dmi`, `decals/ISO_signs.dmi`, `decals/floorguides.dmi`, `decals/misc.dmi` | `tools/goon_ports/decor.py` |
| `icons/obj/goon_cabinet.dmi` | `icons/obj/furniture/cabinet.dmi` | `tools/goon_ports/decor.py` |

Скрипт читает исходный чекаут Goonstation (по умолчанию `..\goonstation-master`) и
перезаписывает только перечисленные файлы. Состояния из листов табличек, постеров и знаков ISO
получают префиксы `sign_`, `poster_`, `iso_`.
