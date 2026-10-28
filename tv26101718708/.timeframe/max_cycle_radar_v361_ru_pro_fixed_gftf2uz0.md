# MAX CYCLE RADAR v3.6.1 RU PRO FIXED

- url: https://www.tradingview.com/script/gftF2uZ0-max-cycle-radar-v3-6-1-ru-pro-fixed/
- type: indicator
- pine_id: PUB;de0a0f08d6a94b9b9c2fed0fc0d91a6c
- version: 1.0

## Description

Главный вывод:
Это уже не просто “стрелочник купить/продать”. Это **комбайн-радар рыночного цикла**, который пытается понять: рынок копит, сжимается, снимает ликвидность, даёт импульс, входит в тренд или уже тухнет.
Главная задача индикатора — не угадывать дно, а дать нормальный вход **после подтверждения**, со стопом, тейками и пониманием, не поздно ли лезть.

 Что это за индикатор

Название: MAX CYCLE RADAR v3.6.1 RU PRO FIXED

Тип: индикатор TradingView на Pine Script v6, не стратегия.

То есть он:

* показывает сигналы ПОКУПАТЬ / ПРОДАВАТЬ;
* рисует вход, стоп, тейки;
* показывает состояние рынка в инфо-окне;
* учитывает старшие таймфреймы;
* определяет фазу рынка;
* пытается не лезть в поздний вход после пампа.

Но он не открывает сделки сам и не тестируется как полноценная стратегия в Strategy Tester. Для тестера позже надо делать отдельную версию `strategy()`.

Главная идея

Мы не ушли от основной логики:

**накопление → сжатие → вынос ликвидности → импульс → откат / ретест → вход → тренд → затухание / боковик**

Индикатор пытается не просто увидеть зелёную свечу, а понять, где мы внутри этого цикла.

Что встроено внутрь

1. Squeeze / Momentum

Это модуль раннего предупреждения.

Он ищет:

* сжатие волатильности;
* выход из сжатия;
* пробуждение импульса;
* смену momentum.

Задача: заранее подсказать, что рынок может скоро рвануть.

Но сам по себе squeeze — не вход. Это как сигнал:
“готовься, скоро будет движение”.

---

2. Directional Flux

Это модуль силы направления.

Он смотрит, есть ли реальное ускорение цены относительно ATR.

Простыми словами:

* Flux вверх → покупатели начинают давить;
* Flux вниз → продавцы давят;
* Flux слабый → рынок шумит, сигналы хуже.

---

3. Liquidity Sweep

Это важный блок.

Он ищет ситуации, где рынок:

* пробил предыдущий high и вернулся обратно;
* пробил предыдущий low и вернулся обратно;
* сделал ложный пробой диапазона.

То есть он пытается поймать момент:

**толпу вынесли по стопам, а цена вернулась обратно.**

Это нужно для логики:

* сняли низ → возможен лонг;
* сняли верх → возможен шорт.

---

4. BOS / CHoCH

Это структурный блок из идеи Meridian Flow.

Он определяет:

BOS — пробой структуры по тренду.
CHoCH— смена характера движения, возможный разворот.

Простыми словами:

* BOS вверх → тренд вверх подтверждается;
* BOS вниз → тренд вниз подтверждается;
* CHoCH вверх → медвежий рынок может разворачиваться вверх;
* CHoCH вниз → бычий рынок может ломаться вниз.

Важно: этот блок не самый ранний, потому что работает через swing/pivot. Он подтверждает структуру с задержкой, зато меньше фантазирует.

---

5. Order Block

Индикатор берёт последнюю значимую свечную зону перед пробоем.

Для лонга:

* после BOS/CHoCH вверх берётся последняя медвежья зона;
* если цена возвращается туда и удерживается — это может быть зона входа.

Для шорта:

* после BOS/CHoCH вниз берётся последняя бычья зона;
* возврат туда может быть зоной шорта.

На графике мы не рисуем десятки OB, а только последнюю важную зону, чтобы не засрать экран.

---

6. Fibonacci Structure

Это модуль из Fibonacci Structure Engine.

Он ищет:

* последний импульс;
* fib-зону отката;
* цели по расширению.

Главная логика:

Для лонга лучше покупать не на хаях, а когда цена вернулась в нормальную зону:

0.5–0.786

Для шорта аналогично — не шортить низ, а ждать откат выше.

Это защищает от тупого входа после свечи в космос.

---

7. Trend Quality Index / TQI

Это идея из Self-Aware Trend System.

Индикатор оценивает качество тренда по нескольким факторам:

* эффективность движения;
* ADX;
* устойчивость momentum;
* состояние волатильности.

В инфо-окне это строка:

Тренд: сильный / средний / слабый

Смысл простой:

* сильный тренд → можно держать дальше;
* средний → осторожно;
* слабый → не добирать, готовиться к выходу.

---

8. Adaptive Trail

Это умная тренд-линия.

Она работает как динамическая защита позиции.

Если рынок шумный — линия шире.
Если тренд сильный — линия подтягивается лучше.

По ней индикатор может понять:

* держать позицию;
* выходить;
* тренд сломался;
* вход уже поздний.

---

9. MTF-фильтр

Индикатор смотрит несколько таймфреймов:

* 15m
* 1h
* 4h
* 1D

В инфо-окне строка **ТФ** показывает:

* Б = бычьи таймфреймы;
* М = медвежьи;
* Н = нейтральные.

Например:

Б3 / М1 / Н0

Это значит: 3 таймфрейма за рост, 1 против.

---

10. Новости вручную

TradingView не даёт нормально подключить реальные политические новости и календарь прямо внутрь Pine Script. Поэтому сделан ручной блок.

Можно включить:

* Новость 1;
* Новость 2;
* Новость 3;
* политический риск вручную.

Индикатор может:

* блокировать вход перед новостью;
* показать “СКОРО НОВОСТЬ”;
* после новости учитывать импульс вверх или вниз.

Это не автоматический новостной ИИ. Это ручной предохранитель.

## Что показывает на графике

На графике должно быть минимально:

ПОКУПАТЬ — когда условия за лонг набрали достаточно баллов.
ПРОДАВАТЬ — когда условия за шорт набрали достаточно баллов.
ВХОД — цена входа.
СТОП — примерный стоп.
ТЕЙК 1 / 2 / 3** — цели.
Фоновая зона** — текущий цикл рынка.
Fib-зона / OB-зона** — если включены.

Мы специально убрали кучу надписей типа `SCOUT`, `LATE`, `PRE`, чтобы график не превращался в помойку.

 Что в инфо-окне самое важное

Оставляем только полезное:

Действие
Главное поле. Что делать сейчас:

* ПОКУПАТЬ
* ПРОДАВАТЬ
* ДЕРЖАТЬ ЛОНГ
* ДЕРЖАТЬ ШОРТ
* ЖДИ FIB-ОТКАТ
* ПОЗДНО ЛОНГ
* ПОЗДНО ШОРТ
* НЕ ЛЕЗТЬ

**Цикл**
Где рынок сейчас:

* НАКОПЛЕНИЕ
* СЖАТИЕ
* ВЫНОС СНИЗУ
* ВЫНОС СВЕРХУ
* ИМПУЛЬС ВВЕРХ
* ИМПУЛЬС ВНИЗ
* ТРЕНД ВВЕРХ
* ТРЕНД ВНИЗ
* ЗАТУХАНИЕ
* БОКОВИК

**Структура**
Показывает:

* BOS ↑
* BOS ↓
* CHoCH ↑
* CHoCH ↓
* БЫЧЬЯ
* МЕДВЕЖЬЯ
* НЕТ

**Зона**
Показывает:

* FIB ЛОНГ
* FIB ШОРТ
* OB ЛОНГ
* OB ШОРТ
* В FIB ЗОНЕ
* ПРЕМИУМ / ПОЗДНО
* ДИСКАУНТ / ПОЗДНО

**Тренд**
Сила тренда в процентах.

**Готовность**
Например:

**ЛОНГ 72% / ШОРТ 18%**

Это не вероятность на 100%, а оценка совпадения условий.

**ТФ**
Согласие старших таймфреймов.

**Объём**
OK / средний / слабый.

**Новости**
OFF / скоро новость / политический риск / новость вверх / новость вниз.

**Цели**
Потенциал до TP1 / TP2 / TP3 в процентах.

## Как читать сигналы

### “ПОКУПАТЬ”

Это появляется, когда совпали несколько условий:

* тренд или разворот в сторону лонга;
* MTF не против;
* есть momentum;
* есть структура / ретест / OB / Fib / пробой;
* нет признака “поздно”;
* нет блокировки новостей.

### “ПРОДАВАТЬ”

То же самое, но в обратную сторону.

### “ЖДИ FIB-ОТКАТ”

Это важная команда.

Она означает:

**движение уже пошло, но сейчас покупать поздно. Лучше ждать откат в нормальную зону.**

Вот это как раз защита от ситуации, когда ты покупаешь зелёную свечу на самом верху.

### “ПОЗДНО ЛОНГ”

Это значит:

тренд вверх есть, но цена уже слишком далеко от нормальной зоны. Вход плохой.

### “ЛОНГ СЛАБЕЕТ”

Это не обязательно “сразу продавай”.
Это предупреждение:

**тренд теряет качество, подтягивай стоп, не добирай.**

## На каких таймфреймах использовать

Для BTC:

* Основной вход: **15m / 30m**
* Подтверждение: **1h / 4h**
* Контекст: **1D**

Для ETH:

* Основной вход: **15m / 30m**
* Подтверждение: **1h / 4h**

Для альтов:

* Лучше не ниже **15m**
* И обязательно смотреть **1h / 4h**
* На 5m альты будут давать много шума.

Для скальпа:

* 5m можно, но только если рынок активный;
* входы чаще, но ложных будет больше.

## Какие настройки ставить

Для BTC:

**Профиль:** BTC
**Режим входа:** ГИБРИД
**Визуал:** НОРМАЛЬНО

Для ETH:

**Профиль:** ETH
**Режим входа:** ГИБРИД

Для альтов:

**Профиль:** ALT
**Режим входа:** БЕЗОПАСНЫЙ

Для агрессивной ловли ранних движений:

**Режим входа:** АГРЕССИВНЫЙ
Но там будет больше мусора.

## Важный честный момент

Этот индикатор не будет покупать самое дно.
И это правильно.

Если он начнёт покупать каждую нижнюю свечу, он будет ловить ножи.

Наша система должна работать так:

1. Сначала предупреждение: возможно разворот / вынос / сжатие.
2. Потом подтверждение структуры.
3. Потом вход на откате / ретесте / пробое.
4. Потом стоп и тейки.

То есть он не должен быть “угадайкой”. Он должен быть **радаром риска**.

## Что ещё надо будет доделать

Следующий нормальный шаг — сделать **отдельную strategy-версию**.

Она нужна, чтобы проверить:

* сколько сигналов было;
* win rate;
* средний R;
* просадку;
* какие настройки лучше для BTC;
* какие для ETH;
* какие для альтов.

Сейчас у нас индикатор. Он показывает логику.
Но чтобы понять, зарабатывает он или красиво рисует, нужна версия:

`strategy("MAX CYCLE RADAR STRATEGY")`

Вот там уже можно будет реально прогнать историю.

## Итог

Это индикатор не для тупого “зелёное — покупай”.
Это система, которая собирает несколько слоёв:

**цикл рынка + ликвидность + структура + Fib-зона + качество тренда + MTF + объём + риск новостей**

И финально выдаёт:

**ПОКУПАТЬ / ПРОДАВАТЬ / ДЕРЖАТЬ / ЖДАТЬ / ПОЗДНО / НЕ ЛЕЗТЬ**

Главное: не надо ожидать от него грааль. Его сила не в том, что он угадывает каждое движение, а в том, что он должен отсекать тупые входы и давать более чистые точки после подтверждения.

## Source Code

````pine
//@version=6
indicator("MAX CYCLE RADAR v3.6.1 RU PRO FIXED", overlay=true, max_lines_count=240, max_labels_count=120, max_boxes_count=60)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. ОСНОВНЫЕ НАСТРОЙКИ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMain = "1. Основное"

profileInput = input.string("АВТО", "Профиль монеты", options=["АВТО", "BTC", "ETH", "ALT", "SCALP", "CUSTOM"], group=groupMain)
entryMode = input.string("ГИБРИД", "Режим входа", options=["БЕЗОПАСНЫЙ", "ГИБРИД", "АГРЕССИВНЫЙ"], group=groupMain)
visualMode = input.string("НОРМАЛЬНО", "Визуал", options=["ЧИСТО", "НОРМАЛЬНО", "ПОЛНО"], group=groupMain)

showDashboard = input.bool(true, "Показывать инфо-окно", group=groupMain)
showZones = input.bool(true, "Показывать зоны рынка фоном", group=groupMain)
showTradeLines = input.bool(true, "Показывать вход / стоп / тейки", group=groupMain)
showFibZones = input.bool(true, "Показывать Fib-зону входа / цель", group=groupMain)
showOBZone = input.bool(true, "Показывать последнюю OB-зону", group=groupMain)
showEMA = input.bool(false, "Показывать EMA", group=groupMain)
showTrail = input.bool(false, "Показывать тренд-линию", group=groupMain)

groupCustom = "2. CUSTOM профиль"

customEntryScore = input.int(68, "CUSTOM: вход %", minval=45, maxval=95, group=groupCustom)
customPreScore = input.int(58, "CUSTOM: ранний вход %", minval=35, maxval=90, group=groupCustom)
customLead = input.int(7, "CUSTOM: перевес стороны %", minval=0, maxval=40, group=groupCustom)
customVolMult = input.float(1.20, "CUSTOM: объём множитель", step=0.05, group=groupCustom)
customStopATR = input.float(1.9, "CUSTOM: стоп ATR", step=0.1, group=groupCustom)
customTrailATR = input.float(1.45, "CUSTOM: трейл ATR", step=0.1, group=groupCustom)
customMtfNeed = input.int(2, "CUSTOM: минимум ТФ", minval=1, maxval=4, group=groupCustom)

groupCore = "3. Ядро рынка"

emaFastLen = input.int(21, "EMA быстрая", minval=1, group=groupCore)
emaSlowLen = input.int(55, "EMA медленная", minval=1, group=groupCore)
atrLen = input.int(10, "ATR период", minval=1, group=groupCore)
adxLen = input.int(14, "ADX период", minval=1, group=groupCore)
adxSmooth = input.int(14, "ADX сглаживание", minval=1, group=groupCore)
adxTrendMin = input.float(18.0, "Минимум ADX для тренда", step=0.5, group=groupCore)

groupSqueeze = "4. Сжатие / импульс"

sqLen = input.int(20, "Squeeze длина", minval=5, maxval=100, group=groupSqueeze)
bbMult = input.float(2.0, "BB множитель", step=0.1, group=groupSqueeze)
kcMult = input.float(1.5, "KC множитель", step=0.1, group=groupSqueeze)
momSigLen = input.int(5, "Momentum сглаживание", minval=1, maxval=30, group=groupSqueeze)
fluxLen = input.int(14, "Directional Flux", minval=3, maxval=80, group=groupSqueeze)

groupStructure = "5. Структура / ликвидность"

swingLen = input.int(5, "Swing длина", minval=2, maxval=30, group=groupStructure)
rangeLen = input.int(36, "Диапазон пробоя", minval=10, maxval=200, group=groupStructure)
retestBars = input.int(12, "Свечей ждать ретест", minval=1, maxval=100, group=groupStructure)

groupFib = "6. Fibonacci"

useFibFilter = input.bool(true, "Использовать Fib-зону для входа", group=groupFib)
fibZoneFrom = input.float(0.50, "Fib зона от", minval=0.236, maxval=0.786, step=0.001, group=groupFib)
fibZoneTo = input.float(0.786, "Fib зона до", minval=0.382, maxval=0.886, step=0.001, group=groupFib)
fibTarget1 = input.float(-0.50, "Fib цель 1", step=0.001, group=groupFib)
fibTarget2 = input.float(-0.618, "Fib цель 2", step=0.001, group=groupFib)
fibExtendBars = input.int(80, "Длина Fib-зоны", minval=20, maxval=500, group=groupFib)

groupTrendQuality = "7. Качество тренда"

tqLen = input.int(20, "TQI длина", minval=5, maxval=80, group=groupTrendQuality)
tqStrong = input.float(70.0, "TQI сильный тренд", minval=40, maxval=95, step=1, group=groupTrendQuality)
tqWeak = input.float(40.0, "TQI слабый тренд", minval=10, maxval=70, step=1, group=groupTrendQuality)
useDynamicTP = input.bool(true, "Динамические тейки по силе тренда", group=groupTrendQuality)

groupEntry = "8. Входы"

allowPreEntry = input.bool(true, "Разрешить ранний PRE-вход", group=groupEntry)
allowPullbackEntry = input.bool(true, "Разрешить вход на откате", group=groupEntry)
reentryHours = input.float(4.0, "Повторный шанс каждые часов", minval=0.5, maxval=24, step=0.5, group=groupEntry)
pullbackZoneATR = input.float(0.35, "Зона отката к EMA, ATR", minval=0.05, maxval=2.0, step=0.05, group=groupEntry)
lateDistanceATR = input.float(2.2, "Поздно, если дальше ATR", minval=1.0, maxval=5.0, step=0.1, group=groupEntry)

groupMTF = "9. Старшие ТФ"

tf1 = input.timeframe("15", "ТФ 1", group=groupMTF)
tf2 = input.timeframe("60", "ТФ 2", group=groupMTF)
tf3 = input.timeframe("240", "ТФ 3", group=groupMTF)
tf4 = input.timeframe("D", "ТФ 4", group=groupMTF)
useClosedHTF = input.bool(true, "Закрытые свечи старших ТФ", group=groupMTF)

groupRisk = "10. Риск"

useSwingSL = input.bool(true, "Стоп от swing / OB", group=groupRisk)
rr1 = input.float(1.0, "Базовый тейк 1 R", step=0.25, group=groupRisk)
rr2 = input.float(2.0, "Базовый тейк 2 R", step=0.25, group=groupRisk)
rr3 = input.float(3.0, "Базовый тейк 3 R", step=0.25, group=groupRisk)
lineBars = input.int(80, "Длина линий сделки", minval=20, maxval=500, group=groupRisk)
moveSLtoBE = input.bool(true, "После TP1 считать безубыток", group=groupRisk)

groupNews = "11. Новости вручную"

useNewsMode = input.bool(true, "Включить режим новостей", group=groupNews)
blockBeforeNews = input.bool(true, "Блокировать вход перед новостью", group=groupNews)
newsBeforeMin = input.int(30, "Минут до новости", minval=0, maxval=240, group=groupNews)
newsAfterMin = input.int(60, "Минут после новости", minval=0, maxval=360, group=groupNews)

news1On = input.bool(false, "Новость 1 включена", group=groupNews)
news1Time = input.time(1767225600000, "Новость 1 UTC", group=groupNews)

news2On = input.bool(false, "Новость 2 включена", group=groupNews)
news2Time = input.time(1767225600000, "Новость 2 UTC", group=groupNews)

news3On = input.bool(false, "Новость 3 включена", group=groupNews)
news3Time = input.time(1767225600000, "Новость 3 UTC", group=groupNews)

manualRisk = input.bool(false, "Политический риск вручную", group=groupNews)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. ПРОФИЛЬ МОНЕТЫ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isBTC = str.contains(syminfo.ticker, "BTC")
isETH = str.contains(syminfo.ticker, "ETH")

string prof = profileInput

if profileInput == "АВТО"
    prof := isBTC ? "BTC" : isETH ? "ETH" : "ALT"

entryNeedBase = prof == "BTC" ? 66 : prof == "ETH" ? 68 : prof == "ALT" ? 72 : prof == "SCALP" ? 62 : customEntryScore
preNeedBase = prof == "BTC" ? 56 : prof == "ETH" ? 58 : prof == "ALT" ? 64 : prof == "SCALP" ? 52 : customPreScore
leadBase = prof == "BTC" ? 6 : prof == "ETH" ? 7 : prof == "ALT" ? 10 : prof == "SCALP" ? 4 : customLead
volMult = prof == "BTC" ? 1.08 : prof == "ETH" ? 1.12 : prof == "ALT" ? 1.30 : prof == "SCALP" ? 1.05 : customVolMult
stopATR = prof == "BTC" ? 1.8 : prof == "ETH" ? 2.0 : prof == "ALT" ? 2.4 : prof == "SCALP" ? 1.5 : customStopATR
trailATRBase = prof == "BTC" ? 1.35 : prof == "ETH" ? 1.45 : prof == "ALT" ? 1.75 : prof == "SCALP" ? 1.15 : customTrailATR
mtfNeed = prof == "BTC" ? 2 : prof == "ETH" ? 2 : prof == "ALT" ? 3 : prof == "SCALP" ? 1 : customMtfNeed

entryNeed = manualRisk ? entryNeedBase + 6 : entryNeedBase
preNeed = manualRisk ? preNeedBase + 6 : preNeedBase
leadNeed = manualRisk ? leadBase + 4 : leadBase

isClean = visualMode == "ЧИСТО"
isFull = visualMode == "ПОЛНО"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. БАЗА
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, 50)

[plusDI, minusDI, adx] = ta.dmi(adxLen, adxSmooth)
rsi = ta.rsi(close, 14)

volAvg = ta.sma(volume, 20)
volOk = volume > volAvg * volMult
volSoft = volume > volAvg * 0.85

emaBull = emaFast > emaSlow and close > emaFast
emaBear = emaFast < emaSlow and close < emaFast
trendPowerOk = adx >= adxTrendMin

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. НОВОСТИ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
beforeMs = newsBeforeMin * 60 * 1000
afterMs = newsAfterMin * 60 * 1000

f_beforeNews(_on, _t) =>
    useNewsMode and _on and time >= _t - beforeMs and time < _t

f_afterNews(_on, _t) =>
    useNewsMode and _on and time >= _t and time <= _t + afterMs

newsBefore = f_beforeNews(news1On, news1Time) or f_beforeNews(news2On, news2Time) or f_beforeNews(news3On, news3Time)
newsAfter = f_afterNews(news1On, news1Time) or f_afterNews(news2On, news2Time) or f_afterNews(news3On, news3Time)

newsMoveUp = newsAfter and close > open and close > close[1] and volume > volAvg
newsMoveDn = newsAfter and close < open and close < close[1] and volume > volAvg

blockedByNews = useNewsMode and blockBeforeNews and newsBefore

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. SQUEEZE / MOMENTUM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
basis = ta.sma(close, sqLen)
dev = bbMult * ta.stdev(close, sqLen)

bbUp = basis + dev
bbDn = basis - dev

kcUp = basis + atr * kcMult
kcDn = basis - atr * kcMult

squeezeOn = bbUp < kcUp and bbDn > kcDn
squeezeOff = not squeezeOn and squeezeOn[1]

barsFromSqz = ta.barssince(squeezeOn)
recentSqueeze = not na(barsFromSqz) and barsFromSqz <= 12

highestSq = ta.highest(high, sqLen)
lowestSq = ta.lowest(low, sqLen)
midSq = math.avg(math.avg(highestSq, lowestSq), ta.sma(close, sqLen))

mom = ta.linreg(close - midSq, sqLen, 0)
momSignal = ta.ema(mom, momSigLen)

momUp = mom > mom[1]
momDn = mom < mom[1]

momBull = mom > momSignal and momUp
momBear = mom < momSignal and momDn

momCrossUp = ta.crossover(mom, momSignal)
momCrossDn = ta.crossunder(mom, momSignal)

squeezeBuy = (squeezeOff or recentSqueeze) and momBull
squeezeSell = (squeezeOff or recentSqueeze) and momBear

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. DIRECTIONAL FLUX — исправленный блок
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priceChangeEma = ta.ema(ta.change(close), fluxLen)
fluxRaw = atr > 0 ? priceChangeEma / atr * 100.0 : 0.0
fluxSig = ta.ema(fluxRaw, 5)

fluxBull = fluxRaw > fluxSig and fluxRaw > 0
fluxBear = fluxRaw < fluxSig and fluxRaw < 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. СТРУКТУРА: SWING / BOS / CHoCH / SWEEP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

var float swHigh1 = na
var float swHigh2 = na
var int swHigh1Idx = na
var int swHigh2Idx = na

var float swLow1 = na
var float swLow2 = na
var int swLow1Idx = na
var int swLow2Idx = na

if not na(pivotHigh)
    swHigh2 := swHigh1
    swHigh2Idx := swHigh1Idx
    swHigh1 := pivotHigh
    swHigh1Idx := bar_index - swingLen

if not na(pivotLow)
    swLow2 := swLow1
    swLow2Idx := swLow1Idx
    swLow1 := pivotLow
    swLow1Idx := bar_index - swingLen

rangeHigh = ta.highest(high[1], rangeLen)
rangeLow = ta.lowest(low[1], rangeLen)

sweepUp = not na(swHigh1) and high > swHigh1 + atr * 0.05 and close < swHigh1 and open < swHigh1
sweepDn = not na(swLow1) and low < swLow1 - atr * 0.05 and close > swLow1 and open > swLow1

fakeBreakUp = high > rangeHigh and close < rangeHigh and volSoft
fakeBreakDn = low < rangeLow and close > rangeLow and volSoft

liqSweepUp = sweepUp or fakeBreakUp
liqSweepDn = sweepDn or fakeBreakDn

var int structureBias = 0
var int lastBrokenHighIdx = na
var int lastBrokenLowIdx = na

bool bullBreakCond = not na(swHigh1) and barstate.isconfirmed and close > swHigh1 and (na(lastBrokenHighIdx) or swHigh1Idx != lastBrokenHighIdx)
bool bearBreakCond = not na(swLow1) and barstate.isconfirmed and close < swLow1 and (na(lastBrokenLowIdx) or swLow1Idx != lastBrokenLowIdx)

if bullBreakCond and bearBreakCond
    if structureBias <= 0
        bearBreakCond := false
    else
        bullBreakCond := false

bool chochUp = false
bool chochDn = false
bool bosUp = false
bool bosDn = false

if bullBreakCond
    if structureBias <= 0
        chochUp := true
    else
        bosUp := true
    structureBias := 1
    lastBrokenHighIdx := swHigh1Idx

if bearBreakCond
    if structureBias >= 0
        chochDn := true
    else
        bosDn := true
    structureBias := -1
    lastBrokenLowIdx := swLow1Idx

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. ORDER BLOCK — последняя зона
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lastBearHigh = ta.valuewhen(close < open, high, 0)
lastBearLow = ta.valuewhen(close < open, low, 0)
lastBearIdx = ta.valuewhen(close < open, bar_index, 0)

lastBullHigh = ta.valuewhen(close > open, high, 0)
lastBullLow = ta.valuewhen(close > open, low, 0)
lastBullIdx = ta.valuewhen(close > open, bar_index, 0)

var float bullOBTop = na
var float bullOBBot = na
var int bullOBIdx = na
var bool bullOBActive = false

var float bearOBTop = na
var float bearOBBot = na
var int bearOBIdx = na
var bool bearOBActive = false

if chochUp or bosUp
    bullOBTop := lastBearHigh
    bullOBBot := lastBearLow
    bullOBIdx := int(lastBearIdx)
    bullOBActive := not na(bullOBTop) and not na(bullOBBot)

if chochDn or bosDn
    bearOBTop := lastBullHigh
    bearOBBot := lastBullLow
    bearOBIdx := int(lastBullIdx)
    bearOBActive := not na(bearOBTop) and not na(bearOBBot)

bullOBRetest = bullOBActive and low <= bullOBTop and close >= bullOBBot
bearOBRetest = bearOBActive and high >= bearOBBot and close <= bearOBTop

if bullOBActive and close < bullOBBot
    bullOBActive := false

if bearOBActive and close > bearOBTop
    bearOBActive := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9. FIBONACCI STRUCTURE CORE — исправленный блок
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int fibDir = 0
var float fibHigh = na
var float fibLow = na
var int fibHighIdx = na
var int fibLowIdx = na

if chochUp or bosUp
    fibDir := 1
    fibHigh := high
    fibHighIdx := bar_index
    fibLow := swLow1
    fibLowIdx := nz(swLow1Idx, bar_index - 10)

if chochDn or bosDn
    fibDir := -1
    fibLow := low
    fibLowIdx := bar_index
    fibHigh := swHigh1
    fibHighIdx := nz(swHigh1Idx, bar_index - 10)

if fibDir == 1 and not na(fibHigh) and high > fibHigh
    fibHigh := high
    fibHighIdx := bar_index

if fibDir == -1 and not na(fibLow) and low < fibLow
    fibLow := low
    fibLowIdx := bar_index

fibRangeValid = not na(fibHigh) and not na(fibLow) and fibHigh > fibLow and fibDir != 0
fibRange = fibRangeValid ? fibHigh - fibLow : na

float fib382 = na
float fib500 = na
float fib618 = na
float fib786 = na
float fibZoneA = na
float fibZoneB = na
float fibTgt1 = na
float fibTgt2 = na

if fibRangeValid
    if fibDir == 1
        fib382 := fibHigh - fibRange * 0.382
        fib500 := fibHigh - fibRange * 0.500
        fib618 := fibHigh - fibRange * 0.618
        fib786 := fibHigh - fibRange * 0.786
        fibZoneA := fibHigh - fibRange * fibZoneFrom
        fibZoneB := fibHigh - fibRange * fibZoneTo
        fibTgt1 := fibHigh - fibRange * fibTarget1
        fibTgt2 := fibHigh - fibRange * fibTarget2
    else
        fib382 := fibLow + fibRange * 0.382
        fib500 := fibLow + fibRange * 0.500
        fib618 := fibLow + fibRange * 0.618
        fib786 := fibLow + fibRange * 0.786
        fibZoneA := fibLow + fibRange * fibZoneFrom
        fibZoneB := fibLow + fibRange * fibZoneTo
        fibTgt1 := fibLow + fibRange * fibTarget1
        fibTgt2 := fibLow + fibRange * fibTarget2

fibZoneTop = fibRangeValid ? math.max(fibZoneA, fibZoneB) : na
fibZoneBot = fibRangeValid ? math.min(fibZoneA, fibZoneB) : na

inFibZone = fibRangeValid and high >= fibZoneBot and low <= fibZoneTop

fibDiscountLong = fibRangeValid and fibDir == 1 and close <= fib500
fibPremiumLong = fibRangeValid and fibDir == 1 and close > fib500

fibPremiumShort = fibRangeValid and fibDir == -1 and close >= fib500
fibDiscountShort = fibRangeValid and fibDir == -1 and close < fib500

fibLongConfluence = useFibFilter and fibDir == 1 and inFibZone and (liqSweepDn or bullOBRetest or momUp or close > fib500)
fibShortConfluence = useFibFilter and fibDir == -1 and inFibZone and (liqSweepUp or bearOBRetest or momDn or close < fib500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10. РЕТЕСТ ДИАПАЗОНА ПОСЛЕ ПРОБОЯ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
breakoutUp = close > rangeHigh and volSoft and (recentSqueeze or close[1] <= rangeHigh)
breakoutDn = close < rangeLow and volSoft and (recentSqueeze or close[1] >= rangeLow)

var bool waitLongRetest = false
var bool waitShortRetest = false
var int longBreakBar = na
var int shortBreakBar = na
var float longBreakLevel = na
var float shortBreakLevel = na

if breakoutUp
    waitLongRetest := true
    longBreakBar := bar_index
    longBreakLevel := rangeHigh

if breakoutDn
    waitShortRetest := true
    shortBreakBar := bar_index
    shortBreakLevel := rangeLow

retestLong = waitLongRetest and not na(longBreakBar) and bar_index > longBreakBar and bar_index - longBreakBar <= retestBars and low <= longBreakLevel and close > longBreakLevel
retestShort = waitShortRetest and not na(shortBreakBar) and bar_index > shortBreakBar and bar_index - shortBreakBar <= retestBars and high >= shortBreakLevel and close < shortBreakLevel

if retestLong or (waitLongRetest and not na(longBreakBar) and bar_index - longBreakBar > retestBars)
    waitLongRetest := false

if retestShort or (waitShortRetest and not na(shortBreakBar) and bar_index - shortBreakBar > retestBars)
    waitShortRetest := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11. СВЕЧИ / ДИВЕРГЕНЦИИ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bodySize = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bullPin = lowerWick > bodySize * 2.0 and close > open
bearPin = upperWick > bodySize * 2.0 and close < open

bullEngulf = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
bearEngulf = close < open and close[1] > open[1] and close <= open[1] and open >= close[1]

bullCandle = bullPin or bullEngulf
bearCandle = bearPin or bearEngulf

pricePivotLow = ta.pivotlow(low, swingLen, swingLen)
pricePivotHigh = ta.pivothigh(high, swingLen, swingLen)

rsiAtLow = rsi[swingLen]
rsiAtHigh = rsi[swingLen]

prevPriceLow = ta.valuewhen(not na(pricePivotLow), pricePivotLow, 1)
prevPriceHigh = ta.valuewhen(not na(pricePivotHigh), pricePivotHigh, 1)
prevRsiLow = ta.valuewhen(not na(pricePivotLow), rsiAtLow, 1)
prevRsiHigh = ta.valuewhen(not na(pricePivotHigh), rsiAtHigh, 1)

bullDiv = not na(pricePivotLow) and not na(prevPriceLow) and pricePivotLow < prevPriceLow and rsiAtLow > prevRsiLow
bearDiv = not na(pricePivotHigh) and not na(prevPriceHigh) and pricePivotHigh > prevPriceHigh and rsiAtHigh < prevRsiHigh

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 12. MTF
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tfState() =>
    f = ta.ema(close, emaFastLen)
    s = ta.ema(close, emaSlowLen)
    bull = f > s and close > f
    bear = f < s and close < f
    bull ? 1 : bear ? -1 : 0

f_tfFinal() =>
    st = f_tfState()
    useClosedHTF ? nz(st[1], st) : st

tf1State = request.security(syminfo.tickerid, tf1, f_tfFinal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf2State = request.security(syminfo.tickerid, tf2, f_tfFinal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf3State = request.security(syminfo.tickerid, tf3, f_tfFinal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf4State = request.security(syminfo.tickerid, tf4, f_tfFinal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

mtfBull = (tf1State == 1 ? 1 : 0) + (tf2State == 1 ? 1 : 0) + (tf3State == 1 ? 1 : 0) + (tf4State == 1 ? 1 : 0)
mtfBear = (tf1State == -1 ? 1 : 0) + (tf2State == -1 ? 1 : 0) + (tf3State == -1 ? 1 : 0) + (tf4State == -1 ? 1 : 0)
mtfNeutral = 4 - mtfBull - mtfBear

mtfLongOk = mtfBull >= mtfNeed
mtfShortOk = mtfBear >= mtfNeed
mtfNotAgainstLong = mtfBear <= 1
mtfNotAgainstShort = mtfBull <= 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 13. TREND QUALITY INDEX + ADAPTIVE TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
absMove = math.abs(close - close[tqLen])
noise = ta.sma(math.abs(ta.change(close)), tqLen) * tqLen
erScore = noise > 0 ? math.min(absMove / noise * 100.0, 100.0) : 0.0

adxScore = math.min(adx / 35.0 * 100.0, 100.0)
momPersistBull = ta.sma(momUp ? 1.0 : 0.0, tqLen) * 100.0
momPersistBear = ta.sma(momDn ? 1.0 : 0.0, tqLen) * 100.0
momPersist = math.max(momPersistBull, momPersistBear)

atrRatio = atrAvg > 0 ? atr / atrAvg : 1.0
volStability = math.max(0.0, 100.0 - math.abs(atrRatio - 1.0) * 60.0)

trendQuality = math.max(0.0, math.min((erScore + adxScore + momPersist + volStability) / 4.0, 100.0))

adaptiveFactorRaw = trailATRBase + (100.0 - trendQuality) / 100.0 * 1.2
adaptiveFactor = math.max(0.8, math.min(adaptiveFactorRaw, 3.8))

adaptiveLoss = atr * adaptiveFactor

var float adaptiveTrail = na
prevAdaptive = nz(adaptiveTrail[1], close - adaptiveLoss)

if close > prevAdaptive and close[1] > prevAdaptive
    adaptiveTrail := math.max(prevAdaptive, close - adaptiveLoss)
else if close < prevAdaptive and close[1] < prevAdaptive
    adaptiveTrail := math.min(prevAdaptive, close + adaptiveLoss)
else if close > prevAdaptive
    adaptiveTrail := close - adaptiveLoss
else
    adaptiveTrail := close + adaptiveLoss

trailBull = close > adaptiveTrail
trailBear = close < adaptiveTrail

trendUp = emaBull and trailBull and trendPowerOk and mtfBull >= 2
trendDn = emaBear and trailBear and trendPowerOk and mtfBear >= 2

characterFlipLong = trendUp and trendQuality < trendQuality[1] and trendQuality < tqWeak and momDn
characterFlipShort = trendDn and trendQuality < trendQuality[1] and trendQuality < tqWeak and momUp

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 14. ЦИКЛ РЫНКА
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bbWidth = basis != 0 ? (bbUp - bbDn) / basis * 100.0 : 0.0
bbWidthAvg = ta.sma(bbWidth, 50)

rangeMarket = adx < adxTrendMin and bbWidth <= bbWidthAvg and not squeezeOn
accumulation = rangeMarket and atr < atrAvg and close < rangeHigh and close > rangeLow

barsBreakUp = ta.barssince(breakoutUp)
barsBreakDn = ta.barssince(breakoutDn)

postImpulseUp = trendUp and not na(barsBreakUp) and barsBreakUp <= 16
postImpulseDn = trendDn and not na(barsBreakDn) and barsBreakDn <= 16

lateLong = trendUp and close > adaptiveTrail + atr * lateDistanceATR and rsi > 64 and trendQuality < tqStrong
lateShort = trendDn and close < adaptiveTrail - atr * lateDistanceATR and rsi < 36 and trendQuality < tqStrong

exhaustLong = trendUp and (rsi > 72 or characterFlipLong) and close > emaFast + atr * 2.2 and not volOk
exhaustShort = trendDn and (rsi < 28 or characterFlipShort) and close < emaFast - atr * 2.2 and not volOk

string cycleText = "НЕЯСНО"
color cycleColor = color.gray
color zoneColor = na

if accumulation
    cycleText := "НАКОПЛЕНИЕ"
    cycleColor := color.gray
    zoneColor := color.new(color.gray, 88)

if rangeMarket
    cycleText := "БОКОВИК"
    cycleColor := color.gray
    zoneColor := color.new(color.gray, 90)

if squeezeOn
    cycleText := "СЖАТИЕ"
    cycleColor := color.orange
    zoneColor := color.new(color.orange, 86)

if liqSweepUp
    cycleText := "ВЫНОС СВЕРХУ"
    cycleColor := color.orange
    zoneColor := color.new(color.red, 88)

if liqSweepDn
    cycleText := "ВЫНОС СНИЗУ"
    cycleColor := color.orange
    zoneColor := color.new(color.green, 88)

if breakoutUp
    cycleText := "ИМПУЛЬС ВВЕРХ"
    cycleColor := color.green
    zoneColor := color.new(color.green, 84)

if breakoutDn
    cycleText := "ИМПУЛЬС ВНИЗ"
    cycleColor := color.red
    zoneColor := color.new(color.red, 84)

if postImpulseUp
    cycleText := "ПОСЛЕ ИМПУЛЬСА ↑"
    cycleColor := color.green
    zoneColor := color.new(color.green, 90)

if postImpulseDn
    cycleText := "ПОСЛЕ ИМПУЛЬСА ↓"
    cycleColor := color.red
    zoneColor := color.new(color.red, 90)

if trendUp
    cycleText := "ТРЕНД ВВЕРХ"
    cycleColor := color.green
    zoneColor := color.new(color.green, 92)

if trendDn
    cycleText := "ТРЕНД ВНИЗ"
    cycleColor := color.red
    zoneColor := color.new(color.red, 92)

if exhaustLong or exhaustShort
    cycleText := "ЗАТУХАНИЕ"
    cycleColor := color.orange
    zoneColor := color.new(color.orange, 86)

bgcolor(showZones ? zoneColor : na, title="Зоны рынка")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 15. РАННИЙ РАДАР / PRE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rawScoutLong = (squeezeBuy and fluxBull) or (liqSweepDn and (momUp or bullCandle)) or (bullDiv and momUp) or (momCrossUp and rsi < 45)
rawScoutShort = (squeezeSell and fluxBear) or (liqSweepUp and (momDn or bearCandle)) or (bearDiv and momDn) or (momCrossDn and rsi > 55)

bullContext = trendUp or mtfBull >= 3
bearContext = trendDn or mtfBear >= 3

realScoutLong = rawScoutLong and not bearContext
realScoutShort = rawScoutShort and not bullContext

preLong = allowPreEntry and realScoutLong and momBull and fluxBull and volSoft and mtfNotAgainstLong
preShort = allowPreEntry and realScoutShort and momBear and fluxBear and volSoft and mtfNotAgainstShort

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 16. СЧЁТ СТОРОН
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
structureLongScore = chochUp ? 12.0 : bosUp ? 8.0 : structureBias == 1 ? 4.0 : 0.0
structureShortScore = chochDn ? 12.0 : bosDn ? 8.0 : structureBias == -1 ? 4.0 : 0.0

fibLongScore = fibLongConfluence ? 14.0 : fibDir == 1 and fibDiscountLong ? 7.0 : 0.0
fibShortScore = fibShortConfluence ? 14.0 : fibDir == -1 and fibPremiumShort ? 7.0 : 0.0

obLongScore = bullOBRetest ? 10.0 : bullOBActive and close > bullOBTop ? 4.0 : 0.0
obShortScore = bearOBRetest ? 10.0 : bearOBActive and close < bearOBBot ? 4.0 : 0.0

tqScore = trendQuality >= tqStrong ? 10.0 : trendQuality >= tqWeak ? 5.0 : 0.0

longScoreRaw = (
     (emaBull ? 10.0 : 0.0) +
     (trailBull ? 10.0 : 0.0) +
     (trendPowerOk ? 6.0 : 0.0) +
     (volOk ? 10.0 : volSoft ? 5.0 : 0.0) +
     (mtfBull * 4.0) +
     (squeezeBuy ? 10.0 : 0.0) +
     (fluxBull ? 7.0 : 0.0) +
     (liqSweepDn ? 10.0 : 0.0) +
     (bullDiv ? 8.0 : 0.0) +
     (bullCandle ? 4.0 : 0.0) +
     (breakoutUp ? 10.0 : 0.0) +
     (retestLong ? 10.0 : 0.0) +
     structureLongScore +
     fibLongScore +
     obLongScore +
     tqScore +
     (newsMoveUp ? 5.0 : 0.0) -
     (newsBefore ? 10.0 : 0.0) -
     (fibPremiumLong and trendQuality < tqStrong ? 5.0 : 0.0)
)

shortScoreRaw = (
     (emaBear ? 10.0 : 0.0) +
     (trailBear ? 10.0 : 0.0) +
     (trendPowerOk ? 6.0 : 0.0) +
     (volOk ? 10.0 : volSoft ? 5.0 : 0.0) +
     (mtfBear * 4.0) +
     (squeezeSell ? 10.0 : 0.0) +
     (fluxBear ? 7.0 : 0.0) +
     (liqSweepUp ? 10.0 : 0.0) +
     (bearDiv ? 8.0 : 0.0) +
     (bearCandle ? 4.0 : 0.0) +
     (breakoutDn ? 10.0 : 0.0) +
     (retestShort ? 10.0 : 0.0) +
     structureShortScore +
     fibShortScore +
     obShortScore +
     tqScore +
     (newsMoveDn ? 5.0 : 0.0) -
     (newsBefore ? 10.0 : 0.0) -
     (fibDiscountShort and trendQuality < tqStrong ? 5.0 : 0.0)
)

longScore = math.max(math.min(longScoreRaw, 100.0), 0.0)
shortScore = math.max(math.min(shortScoreRaw, 100.0), 0.0)

longReady = longScore >= entryNeed and longScore >= shortScore + leadNeed and mtfLongOk
shortReady = shortScore >= entryNeed and shortScore >= longScore + leadNeed and mtfShortOk

preLongReady = longScore >= preNeed and longScore >= shortScore + math.max(leadNeed - 2, 0) and mtfNotAgainstLong
preShortReady = shortScore >= preNeed and shortScore >= longScore + math.max(leadNeed - 2, 0) and mtfNotAgainstShort

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 17. ПОВТОРНЫЙ ВХОД
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tfSec = math.max(float(timeframe.in_seconds(timeframe.period)), 60.0)
reentryBars = int(math.max(1.0, math.ceil(reentryHours * 3600.0 / tfSec)))

var int lastLongEntryBar = na
var int lastShortEntryBar = na

longDue = na(lastLongEntryBar) or bar_index - lastLongEntryBar >= reentryBars
shortDue = na(lastShortEntryBar) or bar_index - lastShortEntryBar >= reentryBars

pullbackLong = allowPullbackEntry and trendUp and longDue and low <= emaFast + atr * pullbackZoneATR and close > emaFast and close > open and momUp and longScore >= preNeed and mtfNotAgainstLong and not lateLong
pullbackShort = allowPullbackEntry and trendDn and shortDue and high >= emaFast - atr * pullbackZoneATR and close < emaFast and close < open and momDn and shortScore >= preNeed and mtfNotAgainstShort and not lateShort

prevHigh10 = ta.highest(high[1], 10)
prevLow10 = ta.lowest(low[1], 10)

continuationLong = trendUp and longDue and close > prevHigh10 and volSoft and longScore >= entryNeed and mtfLongOk and not lateLong and trendQuality >= tqWeak
continuationShort = trendDn and shortDue and close < prevLow10 and volSoft and shortScore >= entryNeed and mtfShortOk and not lateShort and trendQuality >= tqWeak
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 18. СИГНАЛЫ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
safeLong = retestLong or bullOBRetest or fibLongConfluence or pullbackLong or (liqSweepDn and bullCandle and mtfNotAgainstLong)
safeShort = retestShort or bearOBRetest or fibShortConfluence or pullbackShort or (liqSweepUp and bearCandle and mtfNotAgainstShort)

aggressiveLong = breakoutUp or bosUp or chochUp or preLong or continuationLong or newsMoveUp
aggressiveShort = breakoutDn or bosDn or chochDn or preShort or continuationShort or newsMoveDn

validLong = entryMode == "БЕЗОПАСНЫЙ" ? safeLong : entryMode == "АГРЕССИВНЫЙ" ? aggressiveLong : safeLong or aggressiveLong
validShort = entryMode == "БЕЗОПАСНЫЙ" ? safeShort : entryMode == "АГРЕССИВНЫЙ" ? aggressiveShort : safeShort or aggressiveShort

var int pos = 0
var string activeSide = "НЕТ"

longSignal = barstate.isconfirmed and pos != 1 and not blockedByNews and not lateLong and ((longReady and validLong) or (preLong and preLongReady) or pullbackLong or continuationLong)
shortSignal = barstate.isconfirmed and pos != -1 and not blockedByNews and not lateShort and ((shortReady and validShort) or (preShort and preShortReady) or pullbackShort or continuationShort)

if longSignal
    lastLongEntryBar := bar_index

if shortSignal
    lastShortEntryBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 19. УРОВНИ СДЕЛКИ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float activeEntry = na
var float activeSL = na
var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var string entryReason = ""

dynRR1 = useDynamicTP ? trendQuality >= tqStrong ? 1.0 : trendQuality >= tqWeak ? 0.85 : 0.70 : rr1
dynRR2 = useDynamicTP ? trendQuality >= tqStrong ? 2.5 : trendQuality >= tqWeak ? 1.8 : 1.25 : rr2
dynRR3 = useDynamicTP ? trendQuality >= tqStrong ? 4.0 : trendQuality >= tqWeak ? 2.8 : 1.8 : rr3

if longSignal
    activeEntry := close

    longAtrSL = close - atr * stopATR
    longSwingSL = not na(swLow1) and swLow1 < close ? swLow1 - atr * 0.15 : longAtrSL
    longObSL = bullOBActive and not na(bullOBBot) and bullOBBot < close ? bullOBBot - atr * 0.15 : longAtrSL

    activeSL := useSwingSL ? math.max(math.max(longSwingSL, longObSL), longAtrSL) : longAtrSL

    longRisk = math.max(activeEntry - activeSL, syminfo.mintick)

    longCalcTP1 = activeEntry + longRisk * dynRR1
    longCalcTP2 = activeEntry + longRisk * dynRR2
    longCalcTP3 = activeEntry + longRisk * dynRR3

    activeTP1 := longCalcTP1
    activeTP2 := fibDir == 1 and not na(fibTgt1) and fibTgt1 > activeEntry ? fibTgt1 : longCalcTP2
    activeTP3 := fibDir == 1 and not na(fibTgt2) and fibTgt2 > activeEntry ? fibTgt2 : longCalcTP3

    entryReason := fibLongConfluence ? "FIB" : bullOBRetest ? "OB" : preLong ? "PRE" : pullbackLong ? "ОТКАТ" : continuationLong ? "ПРОДОЛЖЕНИЕ" : retestLong ? "РЕТЕСТ" : breakoutUp ? "ПРОБОЙ" : chochUp ? "CHoCH" : bosUp ? "BOS" : "ЛОНГ"

    pos := 1
    activeSide := "ЛОНГ"

if shortSignal
    activeEntry := close

    shortAtrSL = close + atr * stopATR
    shortSwingSL = not na(swHigh1) and swHigh1 > close ? swHigh1 + atr * 0.15 : shortAtrSL
    shortObSL = bearOBActive and not na(bearOBTop) and bearOBTop > close ? bearOBTop + atr * 0.15 : shortAtrSL

    activeSL := useSwingSL ? math.min(math.min(shortSwingSL, shortObSL), shortAtrSL) : shortAtrSL

    shortRisk = math.max(activeSL - activeEntry, syminfo.mintick)

    shortCalcTP1 = activeEntry - shortRisk * dynRR1
    shortCalcTP2 = activeEntry - shortRisk * dynRR2
    shortCalcTP3 = activeEntry - shortRisk * dynRR3

    activeTP1 := shortCalcTP1
    activeTP2 := fibDir == -1 and not na(fibTgt1) and fibTgt1 < activeEntry ? fibTgt1 : shortCalcTP2
    activeTP3 := fibDir == -1 and not na(fibTgt2) and fibTgt2 < activeEntry ? fibTgt2 : shortCalcTP3

    entryReason := fibShortConfluence ? "FIB" : bearOBRetest ? "OB" : preShort ? "PRE" : pullbackShort ? "ОТКАТ" : continuationShort ? "ПРОДОЛЖЕНИЕ" : retestShort ? "РЕТЕСТ" : breakoutDn ? "ПРОБОЙ" : chochDn ? "CHoCH" : bosDn ? "BOS" : "ШОРТ"

    pos := -1
    activeSide := "ШОРТ"

tp1HitLong = pos == 1 and not na(activeTP1) and high >= activeTP1
tp1HitShort = pos == -1 and not na(activeTP1) and low <= activeTP1

beLong = moveSLtoBE and tp1HitLong ? activeEntry : activeSL
beShort = moveSLtoBE and tp1HitShort ? activeEntry : activeSL

exitLong = barstate.isconfirmed and pos == 1 and not longSignal and (close < adaptiveTrail or close < emaSlow or close <= beLong or shortScore > longScore + 18 or exhaustLong)
exitShort = barstate.isconfirmed and pos == -1 and not shortSignal and (close > adaptiveTrail or close > emaSlow or close >= beShort or longScore > shortScore + 18 or exhaustShort)

if exitLong
    pos := 0
    activeSide := "НЕТ"

if exitShort
    pos := 0
    activeSide := "НЕТ"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20. ВИЗУАЛ: ЛИНИИ СДЕЛКИ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

newTrade = longSignal or shortSignal
exitNow = exitLong or exitShort

if newTrade or exitNow
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)

    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)

if newTrade and showTradeLines
    entryLine := line.new(bar_index, activeEntry, bar_index + lineBars, activeEntry, extend=extend.right, color=color.gray, width=2)
    slLine := line.new(bar_index, activeSL, bar_index + lineBars, activeSL, extend=extend.right, color=color.red, width=2)
    tp1Line := line.new(bar_index, activeTP1, bar_index + lineBars, activeTP1, extend=extend.right, color=color.green, width=1)
    tp2Line := line.new(bar_index, activeTP2, bar_index + lineBars, activeTP2, extend=extend.right, color=color.green, width=2)
    tp3Line := line.new(bar_index, activeTP3, bar_index + lineBars, activeTP3, extend=extend.right, color=color.green, width=3)

    entryLabel := label.new(bar_index + 3, activeEntry, "ВХОД " + str.tostring(activeEntry, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.gray)
    slLabel := label.new(bar_index + 3, activeSL, "СТОП " + str.tostring(activeSL, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.red)
    tp1Label := label.new(bar_index + 3, activeTP1, "ТЕЙК 1 " + str.tostring(activeTP1, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.green)
    tp2Label := label.new(bar_index + 3, activeTP2, "ТЕЙК 2 " + str.tostring(activeTP2, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.green)
    tp3Label := label.new(bar_index + 3, activeTP3, "ТЕЙК 3 " + str.tostring(activeTP3, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.green)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 21. ВИЗУАЛ: FIB / OB ЗОНЫ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box fibEntryBox = na
var box fibTargetBox = na
var box obBox = na

if barstate.islast
    if not na(fibEntryBox)
        box.delete(fibEntryBox)
    if not na(fibTargetBox)
        box.delete(fibTargetBox)
    if not na(obBox)
        box.delete(obBox)

    if showFibZones and fibRangeValid and not isClean
        fibCol = fibDir == 1 ? color.green : color.red
        fibEntryBox := box.new(bar_index, fibZoneTop, bar_index + fibExtendBars, fibZoneBot, border_color=color.new(fibCol, 70), bgcolor=color.new(fibCol, 88), border_width=1)

        tgtTop = math.max(fibTgt1, fibTgt2)
        tgtBot = math.min(fibTgt1, fibTgt2)
        fibTargetBox := box.new(bar_index, tgtTop, bar_index + fibExtendBars, tgtBot, border_color=color.new(fibCol, 75), bgcolor=color.new(fibCol, 92), border_width=1)

    if showOBZone and not isClean
        if bullOBActive
            obBox := box.new(nz(bullOBIdx, bar_index), bullOBTop, bar_index + lineBars, bullOBBot, border_color=color.new(color.green, 75), bgcolor=color.new(color.green, 90), border_width=1)
        else if bearOBActive
            obBox := box.new(nz(bearOBIdx, bar_index), bearOBTop, bar_index + lineBars, bearOBBot, border_color=color.new(color.red, 75), bgcolor=color.new(color.red, 90), border_width=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 22. ГРАФИК
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(longSignal, title="ПОКУПАТЬ", text="ПОКУПАТЬ", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.normal)
plotshape(shortSignal, title="ПРОДАВАТЬ", text="ПРОДАВАТЬ", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal)

plot(showEMA ? emaFast : na, "EMA быстрая", color=color.new(color.green, 0))
plot(showEMA ? emaSlow : na, "EMA медленная", color=color.new(color.red, 0))
plot(showTrail ? adaptiveTrail : na, "Тренд-линия", color=trailBull ? color.green : color.red, linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 23. ИНФО-ПАНЕЛЬ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tp1Pct = activeSide == "ЛОНГ" ? (activeTP1 - activeEntry) / activeEntry * 100 : activeSide == "ШОРТ" ? (activeEntry - activeTP1) / activeEntry * 100 : na
tp2Pct = activeSide == "ЛОНГ" ? (activeTP2 - activeEntry) / activeEntry * 100 : activeSide == "ШОРТ" ? (activeEntry - activeTP2) / activeEntry * 100 : na
tp3Pct = activeSide == "ЛОНГ" ? (activeTP3 - activeEntry) / activeEntry * 100 : activeSide == "ШОРТ" ? (activeEntry - activeTP3) / activeEntry * 100 : na

var table dash = table.new(position.top_right, 2, 11, border_width=1)

if barstate.islast and showDashboard
    sideText = activeSide == "ЛОНГ" ? "ЛОНГ" : activeSide == "ШОРТ" ? "ШОРТ" : "НЕТ СДЕЛКИ"
    sideColor = activeSide == "ЛОНГ" ? color.green : activeSide == "ШОРТ" ? color.red : color.gray

    powerVal = math.max(longScore, shortScore)
    powerText = powerVal >= 80 ? "СИЛЬНАЯ" : powerVal >= 62 ? "СРЕДНЯЯ" : "СЛАБАЯ"
    powerColor = powerVal >= 80 ? color.green : powerVal >= 62 ? color.orange : color.gray

    tqiText = trendQuality >= tqStrong ? "СИЛЬНЫЙ " + str.tostring(trendQuality, "#") + "%" : trendQuality >= tqWeak ? "СРЕДНИЙ " + str.tostring(trendQuality, "#") + "%" : "СЛАБЫЙ " + str.tostring(trendQuality, "#") + "%"
    tqiColor = trendQuality >= tqStrong ? color.green : trendQuality >= tqWeak ? color.orange : color.red

    structureText = chochUp ? "CHoCH ↑" : chochDn ? "CHoCH ↓" : bosUp ? "BOS ↑" : bosDn ? "BOS ↓" : structureBias == 1 ? "БЫЧЬЯ" : structureBias == -1 ? "МЕДВЕЖЬЯ" : "НЕТ"
    structureColor = chochUp or bosUp or structureBias == 1 ? color.green : chochDn or bosDn or structureBias == -1 ? color.red : color.gray

    zoneText = fibLongConfluence ? "FIB ЛОНГ" : fibShortConfluence ? "FIB ШОРТ" : bullOBRetest ? "OB ЛОНГ" : bearOBRetest ? "OB ШОРТ" : inFibZone ? "В FIB ЗОНЕ" : fibPremiumLong ? "ПРЕМИУМ / ПОЗДНО" : fibDiscountShort ? "ДИСКАУНТ / ПОЗДНО" : "НЕТ"
    zoneDashColor = fibLongConfluence or bullOBRetest ? color.green : fibShortConfluence or bearOBRetest ? color.red : inFibZone ? color.orange : color.gray

    volumeText = volOk ? "OK" : volSoft ? "СРЕДНИЙ" : "СЛАБЫЙ"
    volumeColor = volOk ? color.green : volSoft ? color.orange : color.gray

    newsText = manualRisk ? "ПОЛИТ. РИСК" : newsBefore ? "СКОРО НОВОСТЬ" : newsMoveUp ? "НОВОСТЬ ВВЕРХ" : newsMoveDn ? "НОВОСТЬ ВНИЗ" : newsAfter ? "НОВОСТЬ АКТИВНА" : "OFF"
    newsColor = manualRisk or newsBefore ? color.orange : newsMoveUp ? color.green : newsMoveDn ? color.red : color.gray

    targetsText = activeSide == "НЕТ" or na(tp1Pct) ? "НЕТ" : "TP1 " + str.tostring(tp1Pct, "#.##") + "% | TP2 " + str.tostring(tp2Pct, "#.##") + "% | TP3 " + str.tostring(tp3Pct, "#.##") + "%"

    actionText = "НЕ ЛЕЗТЬ"
    actionColor = color.gray

    if blockedByNews
        actionText := "ЖДАТЬ НОВОСТЬ"
        actionColor := color.orange
    else if longSignal
        actionText := "ПОКУПАТЬ"
        actionColor := color.green
    else if shortSignal
        actionText := "ПРОДАВАТЬ"
        actionColor := color.red
    else if activeSide == "ЛОНГ"
        actionText := characterFlipLong ? "ЛОНГ СЛАБЕЕТ" : "ДЕРЖАТЬ ЛОНГ"
        actionColor := characterFlipLong ? color.orange : color.green
    else if activeSide == "ШОРТ"
        actionText := characterFlipShort ? "ШОРТ СЛАБЕЕТ" : "ДЕРЖАТЬ ШОРТ"
        actionColor := characterFlipShort ? color.orange : color.red
    else if fibDir == 1 and trendUp and fibPremiumLong
        actionText := "ЖДИ FIB-ОТКАТ"
        actionColor := color.orange
    else if fibDir == -1 and trendDn and fibDiscountShort
        actionText := "ЖДИ FIB-ОТКАТ"
        actionColor := color.orange
    else if lateLong
        actionText := "ПОЗДНО ЛОНГ"
        actionColor := color.orange
    else if lateShort
        actionText := "ПОЗДНО ШОРТ"
        actionColor := color.orange
    else if squeezeOn
        actionText := "СЖАТИЕ / ЖДАТЬ"
        actionColor := color.orange
    else if accumulation or rangeMarket
        actionText := "БОКОВИК / ЖДАТЬ"
        actionColor := color.gray
    else if trendUp and longScore >= 55
        actionText := "ЛОНГ-КОНТЕКСТ"
        actionColor := color.green
    else if trendDn and shortScore >= 55
        actionText := "ШОРТ-КОНТЕКСТ"
        actionColor := color.red

    if exitLong
        actionText := "ВЫХОД ИЗ ЛОНГА"
        actionColor := color.orange

    if exitShort
        actionText := "ВЫХОД ИЗ ШОРТА"
        actionColor := color.orange

    table.cell(dash, 0, 0, "MAX ЦИКЛ", text_color=color.white, bgcolor=color.blue)
    table.cell(dash, 1, 0, sideText, text_color=color.white, bgcolor=sideColor)

    table.cell(dash, 0, 1, "Действие", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, actionText, text_color=color.white, bgcolor=actionColor)

    table.cell(dash, 0, 2, "Цикл", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, cycleText, text_color=color.white, bgcolor=cycleColor)

    table.cell(dash, 0, 3, "Структура", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, structureText, text_color=color.white, bgcolor=structureColor)

    table.cell(dash, 0, 4, "Зона", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, zoneText, text_color=color.white, bgcolor=zoneDashColor)

    table.cell(dash, 0, 5, "Тренд", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, tqiText, text_color=color.white, bgcolor=tqiColor)

    table.cell(dash, 0, 6, "Готовность", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 6, "ЛОНГ " + str.tostring(longScore, "#") + "% / ШОРТ " + str.tostring(shortScore, "#") + "%", text_color=color.white, bgcolor=color.gray)

    table.cell(dash, 0, 7, "ТФ", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 7, "Б" + str.tostring(mtfBull) + " / М" + str.tostring(mtfBear) + " / Н" + str.tostring(mtfNeutral), text_color=color.white, bgcolor=color.gray)

    table.cell(dash, 0, 8, "Объём", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 8, volumeText, text_color=color.white, bgcolor=volumeColor)

    table.cell(dash, 0, 9, "Новости", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 9, newsText, text_color=color.white, bgcolor=newsColor)

    table.cell(dash, 0, 10, "Цели", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 10, targetsText, text_color=color.white, bgcolor=color.gray)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 24. АЛЕРТЫ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longSignal, title="MAX ПОКУПАТЬ", message="MAX CYCLE v3.6.1: ПОКУПАТЬ на {{ticker}} по {{close}}")
alertcondition(shortSignal, title="MAX ПРОДАВАТЬ", message="MAX CYCLE v3.6.1: ПРОДАВАТЬ на {{ticker}} по {{close}}")
alertcondition(exitLong, title="MAX ВЫХОД ИЗ ЛОНГА", message="MAX CYCLE v3.6.1: ВЫХОД ИЗ ЛОНГА на {{ticker}} по {{close}}")
alertcondition(exitShort, title="MAX ВЫХОД ИЗ ШОРТА", message="MAX CYCLE v3.6.1: ВЫХОД ИЗ ШОРТА на {{ticker}} по {{close}}")
alertcondition(newsBefore, title="MAX СКОРО НОВОСТЬ", message="MAX CYCLE v3.6.1: скоро новость, осторожно на {{ticker}}")
alertcondition(characterFlipLong, title="MAX ЛОНГ СЛАБЕЕТ", message="MAX CYCLE v3.6.1: ЛОНГ СЛАБЕЕТ на {{ticker}} по {{close}}")
alertcondition(characterFlipShort, title="MAX ШОРТ СЛАБЕЕТ", message="MAX CYCLE v3.6.1: ШОРТ СЛАБЕЕТ на {{ticker}} по {{close}}")
````
