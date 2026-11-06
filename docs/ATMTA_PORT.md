# Перенос одежды и тюремных объектов ATMTA

Источник: `OLD_ExcidiumStation_ATMTA`, исторический кармашоп в `hyntatmta`.
Перенесены все 38 позиций его каталога. Новая категория лодаута — **ATMTA**.
Карма/админские права не нужны; стоимость в очках и ограничения по профессиям
сохранены. Старое название Mechanic сопоставлено Station Engineer,
Internal Affairs Agent — Lawyer. Изменения не расставляют одежду на карте.
Восемь викторианских вещей уже существуют в текущем билде и переиспользованы.

## Каталог лодаута

| Предмет | Слот | Профессии | Очки |
| --- | --- | --- | ---: |
| dio headband | голова | все | 1 |
| dio jacket | верхняя одежда | все | 1 |
| dio pants | униформа | все | 1 |
| dio wristbands | перчатки | все | 1 |
| dio shoes | обувь | все | 1 |
| phantom dio | верхняя одежда | все | 5 |
| old snake suit | верхняя одежда | все | 5 |
| kamina cape | шея | все | 5 |
| simon coat | верхняя одежда | CAPTAIN, HOP, REPRESENTATIVE, BLUESHIELD | 5 |
| adeptus mechanicus | верхняя одежда | CHIEF_ENGINEER, ENGINEER, ATMOSTECH, ROBOTICIST | 5 |
| H.E.V. | верхняя одежда | CHIEF_ENGINEER, ENGINEER, ATMOSTECH | 5 |
| alchemist robes | верхняя одежда | CHEMIST, LIBRARIAN | 5 |
| sergeant helmet | голова | HOS, WARDEN | 5 |
| slastena dress | униформа | CIVILIAN, CHEF | 1 |
| slastena hair wig | голова | CIVILIAN, CHEF | 1 |
| slastena shoes | обувь | CIVILIAN, CHEF | 1 |
| victorian tailcoat | верхняя одежда | все | 1 |
| ladies victorian tailcoat | верхняя одежда | все | 1 |
| ladies red victorian tailcoat | верхняя одежда | все | 1 |
| black victorian dress | униформа | все | 1 |
| red victorian dress | униформа | все | 1 |
| victorian suit | униформа | все | 1 |
| victorian red and black suit | униформа | все | 1 |
| victorian red suit | униформа | все | 1 |
| kung suit | униформа | OFFICER, DETECTIVE | 2 |
| kung shoes | обувь | OFFICER, DETECTIVE | 1 |
| kung headband | голова | OFFICER, DETECTIVE | 1 |
| kung jacket | верхняя одежда | OFFICER, DETECTIVE | 1 |
| literature club skirt | униформа | LIBRARIAN | 2 |
| armoured greatcoat | верхняя одежда | HOS | 5 |
| scorpio jacket | верхняя одежда | все | 5 |
| richard's mask | голова | все | 3 |
| richard's outfit | униформа | все | 3 |
| biker helmet | голова | все | 2 |
| biker suit | униформа | все | 2 |
| biker gloves | перчатки | все | 2 |
| biker shoes | обувь | все | 2 |
| CIA | униформа | LAWYER | 5 |

## Не переносились

- Doomguy/Praetor: маска, комбинезон, магнитные ботинки, шлем и броня — экипировка
  админского отряда, не кармашоп/обычная станция.
- Bane Jacket и Invisible helmet — админские превращения, скрытая усиленная броня.
- Комплект Hunter: шляпа, маска, одежда, пальто и ботинки — выдаётся только
  админскими командами Hunter; не относится к обычному лодауту.
- Sovietrig — закомментированный незавершённый комплект.
- Officer/soldier suits, russofurcoat, Anchor Arms, Grisha apron, Adachi,
  Jabroni, Disco, обычные ATMTA gas mask/magboots/space suit: определения
  есть, но в этом историческом checkout не найден источник обычного получения
  (кармашоп, лодаут, карта, вендомат, экипировка профессии). В лодаут не добавлены.
- Old Contortionist's Jumpsuit не добавлен в лодаут: предмет контрабанды;
  доступен в исходной редкой таблице лута параши через современный тип.
- Системы кармы, whitelist и админского спецснаряжения не переносились.

## Параша и пермабриг

Добавлен `/obj/structure/toilet/parasha` — **BIDLOparasha X-1337** с оригинальным
DMI. Наследует обычные крышку/бачок, воду и взаимодействия унитаза. Открытая
крышка + вилка: поиск 3 секунды, общий кулдаун унитаза 2 минуты. Таблица
исторического лута адаптирована к современным путям; исключённый из билда контент
не создаётся. Одновременные поиски не позволяют обойти кулдаун.
На Ulthor заменены туалеты только в зонах `/area/station/security/prison`;
остальные туалеты, геометрия, направления и настройки карты сохранены.

## Виселица

В старом checkout отсутствует реализация виселицы; сохранились `noose`,
`noose_overlay` в `icons/obj/objects.dmi`, два звука и остаточные `noosed`
ссылки. Поведение восстановлено на текущем API пристёгивания.
Крафт **Gallows**, категория **Misc**: 10 дерева, 5 кабеля, отвёртка, 5 секунд.
Перетащить персонажа на закреплённую конструкцию; harm intent включает рычаг
с задержкой 3 секунды. Help intent снимает персонажа. Кусачки освобождают его
и разбирают конструкцию; отвёртывание с занятым местом запрещено. Смерть
не мгновенная: обрабатывается нехватка воздуха. Удаление и освобождение
останавливают обработку и возвращают смещение спрайта.

## Проверки

Выполняются после завершения исходников; результаты будут дописаны ниже.
