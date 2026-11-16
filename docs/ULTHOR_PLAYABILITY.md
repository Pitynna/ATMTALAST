# Ulthor: что нужно для играбельности (сравнение с Delta и Cyberiad)

16 ноября 2026. Получено скриптом `python -I tools/ulthor/compare_reference_maps.py`
(только чтение; сравнивает типы объектов по всей карте и по отделам
`/area/station/<отдел>`). Числа: Ulthor / Delta / Cyberiad.

## Критично — без этого раунд не работает

| Что | Ulthor | Delta | Cyberiad | Заметка |
|---|---|---|---|---|
| `gravity_generator/main/station` | 0 | 1 | 1 | нет гравитации |
| `particle_accelerator` (пульт + 6 частей) | 0 | 1 | 1 | генератор сингулярности, 4 поля и 5 эмиттеров есть, а ускорителя нет — двигатель не запустить |
| `message_server` | 0 | 1 | 1 | PDA-сообщения |
| `blackbox_recorder` | 0 | 1 | 1 | логи раунда |
| Доки капсул `pod1..pod4` | 1 | 4 | 4 | есть только `pod1_home` |
| `ai_module/*` (набор законов) | 1 | 14 | 14 | в аплоаде ИИ только reset |
| `landmark/spawner/late/prisoner`, `start/prisoner` | 0 | есть | есть | |
| Старты `coroner, intern, explorer, trainee_engineer, student_sientist, security_pod_pilot` | 0 | есть | есть | профессии без точки появления |
| `landmark/start/hangover` | 0 | 223 | 214 | |
| `landmark/spawner/tripai` | 0 | 2 | 2 | режим трёх ИИ |
| `spawner/airdrop`, `marauder_entry` | 0 | есть | есть | события/антагонисты |

## Сильно меньше нормы (станция пустая и тёмная)

| Что | Ulthor | Delta | Cyberiad |
|---|---|---|---|
| `machinery/light` + `light/small` | 200 | 1052 | 759 |
| `light_switch` | 25 | 97 | 120 |
| `status_display` / `ai_status_display` | 21 / 8 | 157 / 31 | 116 / 33 |
| `holopad` | 42 | 205 | 140 |
| `newscaster` | 21 | 123 | 54 |
| `extinguisher_cabinet` | 26 | 146 | 71 |
| `navbeacon` (маршруты ботов) | 0 | 63 | 31 |
| `navigate_destination` (навигация /navigate) | 1 | 53 | 49 |
| `spawner/random_spawners` + `lootdrop` (лут техов) | 1 | 490 | 445 |
| `firecloset` / `emcloset` | 4 / 14 | 36 / 39 | 23 / 48 |
| `cryopod` | 7 | 25 | 27 |
| `hydroponics` (лотки) | 22 | ~19 в ботанике + прочие | ~16 |
| `computer/operating` | 1 | 6 | 4 |
| `morgue` (лотки) | ~9 | ~6 в морге | |
| `ai_slipper`, `turretid`, `porta_turret` | 1 / 2 / 7 | 12 / 6 / 23 | 7 / 6 / 16 |

## Чего нет в отделах (есть в отделе на обеих эталонных картах)

- **ИИ:** блюспейс-маяк, транзитная труба к спутнику (если будет спутник).
- **Карго:** `logistics_core`, `logistics_interface`, `supply_display`, `destTagger`,
  отраслевой ClothesMate.
- **Командование:** СШК `blueshield/cmo/qm/rd`, `papershredder`, оконная тонировка,
  `computer/addition_goals`, `rcd/combat`.
- **Инженерия:** гравген, ускоритель, `energy_accumulator`, `electrolyzer`,
  `pipedispenser/disposal`, СШК атмосферы, `rcd/preloaded`, запасные платы
  (телепорт, хим. автоматы, пандемия, aifixer, prisoner), `camera/emp_proof`, toolcloset.
- **Медбей:** `holosign/surgery` + выключатели, операционные компьютеры у каждого стола,
  отраслевой ClothesMate, `clonepod` в зоне медбея (проверить, где стоит).
- **Наука:** отраслевой ClothesMate, `reagent_dispensers/oil`.
- **СБ:** `door_timer/cell_5` (камер меньше), `vending/ammo`, `gun_stand`,
  `treadmill_monitor`, перцовые баллоны.
- **Сервис:** джукбокс бара, `portrait_printer`, `fishtank/wall`, `closet/burial`.
- **Общие помещения:** голодек (`HolodeckControl`), спорт-шкафы, minesweeper,
  `vending/protein`.

## Общие принципы эталонных карт (что должно быть в комнате)

- Обычная комната: АПЦ, свет + выключатель, пожарная и воздушная тревоги, вентиль и
  скруббер, огнетушитель, голопад, камера по назначению, интерком. Отдел: консоль запросов,
  статус-дисплей, newscaster, отраслевой вендор одежды, ClothesMate.
- Каждый глава: личный шкаф, СШК, штамп, keycard_auth, свой кабинет с консолями отдела.
- Техи: свет `light/small`, лут-спавнеры, пожарные/аварийные шкафы, без обязательной вентиляции.
- У каждой профессии из `jobs` — `landmark/start/<job>` на рабочем месте; у важных точек — `navigate_destination`.

Найденные пробелы — список кандидатов; перед правкой сверять в StrongDMM
(может стоять другой подтип или у карты своя планировка).
