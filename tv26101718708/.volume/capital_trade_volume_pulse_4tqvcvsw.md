# Capital Trade | Volume Pulse

- url: https://www.tradingview.com/script/4tQVcVsW-capital-trade-volume-pulse/
- type: indicator
- pine_id: PUB;3ebabab579ae4e87a6856b7a34c55e44
- version: 3.0

## Description

# Capital Trade | Volume Pulse

**Volume Pulse is a price-action and volume visualization tool designed to reduce chart noise and highlight the market events that deserve attention.**

Instead of displaying every volume fluctuation with the same visual importance, the indicator filters incoming volume, classifies significant events by strength, and integrates them directly into the price chart.

The second component of Volume Pulse is a body-based fractal system. Together, volume events and confirmed fractals create a compact framework for reading price action:

**Fractal → Swing → Fractal**

The goal is not to generate automatic buy or sell signals. The goal is to make market structure, changes in activity, and important price events easier to see and easier to monitor.

---

## 1. Volume Filtering

Volume Pulse analyzes the volume of every closed candle against an adaptive statistical baseline.

The calculation uses:

- EMA of volume;
- standard deviation of volume;
- percentage change in volume relative to the previous candle.

Significant volume events are divided into four levels.

**Growth**

Identifies a meaningful acceleration in volume compared with the previous candle.

With the default settings, volume must increase by more than 20%.

This allows the indicator to detect a sudden increase in market activity even before absolute volume reaches an extreme statistical level.

**Elevated Volume**

Volume reaches the first statistical threshold above its recent average:

`EMA Volume + 0.7 × Standard Deviation`

**High Volume**

A stronger statistical deviation from the recent volume environment:

`EMA Volume + 1.8 × Standard Deviation`

**Extreme Volume**

The strongest volume event classified by the indicator:

`EMA Volume + 3.0 × Standard Deviation`

The system uses hierarchical priority. If a candle satisfies several conditions simultaneously, only the highest qualifying level is assigned.

This prevents duplicated information and keeps the chart visually clean.

Volume Pulse does not use one fixed volume value for every market condition. Its thresholds continuously adapt to the recent volume environment of the instrument and timeframe.

Normal candles can also be visually faded, allowing the eye to focus naturally on the bars where meaningful volume activity occurred.

https://www.tradingview.com/x/gHQiRIen/

---

## 2. Fractals & Swings

Volume Pulse includes an independent body-based fractal engine.

Unlike a traditional Williams Fractal that normally evaluates candle highs and lows, this implementation calculates structural extremes from candle bodies:

`Body High = max(Open, Close)`

`Body Low = min(Open, Close)`

Wicks therefore do not determine whether the fractal itself exists.

This provides an alternative way of reading market structure where temporary wick extensions are separated from the body structure of price.

Two fractal lengths are available:

**3-bar fractal**

One candle is required on each side of the structural point.

**5-bar fractal**

Two candles are required on each side.

Once confirmed, the marker is plotted on the candle where the structural extreme originally occurred.

Two equal-level modes are also available:

**Last Bar** — equal body levels are allowed on the left side of the candidate fractal, while the right side must confirm the level strictly.

**Strict** — equality on either side invalidates the fractal.

One practical way to use Volume Pulse is to simplify price action into two main elements:

**Fractal → Swing → Fractal**

A confirmed fractal represents a structural reference point.

The movement between structural points forms the swing.

Volume Pulse then adds another layer of information by showing where meaningful volume activity appeared inside that movement.

Instead of analyzing every candle individually, the trader can focus on:

- where the current swing originated;
- where meaningful volume appeared;
- whether activity increased during continuation or near an extreme;
- whether a new structural fractal formed afterward;
- how price reacted after the event.

The indicator does not interpret the entire market automatically. It organizes the information required for that analysis.

https://www.tradingview.com/x/eP7WKUzh/

---

## 3. Alerts & Workflow

Volume Pulse is designed not only to improve chart readability but also to simplify market monitoring.

Volume alerts can be enabled independently for each volume level.

Fractal alerts can also be enabled separately for:

- Lower Fractal / LONG context;
- Upper Fractal / SHORT context.

All events are evaluated on confirmed bars.

A single TradingView alert using **Any alert() function call** can receive all enabled Volume Pulse events.

If several enabled events occur on the same closing bar, the indicator combines them into a single notification.

This creates a practical workflow:

**Structure → Volume Event → Price Reaction → Fractal Confirmation**

The trader can identify the current structural swing, wait for a meaningful volume event, evaluate the subsequent price reaction, and then use the next confirmed body fractal as additional structural information.

The alert system reduces the need to continuously watch every chart and helps focus attention on moments where something relevant has actually changed.

https://www.tradingview.com/x/6eVXW9u5/

---

## Candle Visualization

Two visualization modes are available.

**Direction Mode**

Significant volume candles retain directional price context:

- bullish candle — bullish color;
- bearish candle — bearish color.

**Level Mode**

Each volume level can have its own color, shifting the visual focus toward the strength of the volume event rather than candle direction.

Colors and transparency values can be customized independently.

---

## Fractal Visualization

Fractals can be displayed using:

- dots;
- crosses;
- triangles.

Upper and lower fractals can be enabled or disabled independently.

Marker size, color, transparency, and distance from price are configurable.

The visual anchor can be set to either **Wick** or **Body**.

This affects only marker placement. Fractal calculation itself always remains body-based.

Marker spacing is calculated relative to ATR, helping maintain consistent visual separation across different instruments and price scales.

---

## How to Interpret Volume Pulse

Volume Pulse uses the volume series provided by the chart.

It does **not** calculate true Bid/Ask Delta and does not directly identify aggressive buyers or sellers.

In Direction Mode, bullish and bearish colors represent candle direction, not separately measured buy and sell volume.

For this reason, volume events should always be interpreted together with:

**Price Action + Location + Structure + Subsequent Reaction**

A high-volume bullish candle shows increased activity during an upward candle, but volume alone does not prove buyer control.

The same principle applies to bearish candles.

Context remains essential.

---

## Why Volume Pulse Is Useful

The main advantage of the indicator is **information compression**.

A standard chart contains hundreds of candles and continuous changes in volume, but not every event deserves equal attention.

Volume Pulse creates a hierarchy:

**Normal activity → Increased activity → Significant volume → Structural event**

This allows the trader to spend less time scanning every candle and more time analyzing the areas where market behavior actually changed.

The indicator can be useful for:

- discretionary price-action analysis;
- market structure analysis;
- monitoring several instruments;
- identifying changes in market activity;
- studying the interaction between volume and structural extremes;
- building an alert-driven trading workflow.

---

## Customization

Volume Pulse allows the trader to configure:

- volume calculation length;
- volume growth sensitivity;
- statistical volume thresholds;
- candle coloring mode;
- bullish and bearish colors;
- colors for individual volume levels;
- transparency for normal and significant candles;
- 3-bar or 5-bar body fractals;
- equal-level logic;
- upper and lower fractal visibility;
- marker type and size;
- Wick or Body visual anchor;
- ATR-based marker spacing;
- individual volume alerts;
- individual fractal alerts.

This makes the indicator adaptable to different instruments, timeframes, visual styles, and trading workflows.

---

**Capital Trade | Volume Pulse is not designed to predict the market.**

Its purpose is to make the information already present in price and volume easier to filter, structure, monitor, and interpret.

**Less noise.  
More relevant information.  
Structure, volume, and alerts in one chart.**

https://www.tradingview.com/x/0obCEVoB/

# Capital Trade | Volume Pulse

**Volume Pulse — это инструмент визуального анализа Price Action и объёма, задача которого — уменьшить количество шума на графике и выделить события рынка, действительно заслуживающие внимания трейдера.**

Вместо того чтобы воспринимать каждое изменение объёма как одинаково значимое, индикатор фильтрует поступающие данные, классифицирует важные события по силе и отображает их непосредственно на ценовом графике.

Вторая часть Volume Pulse — система фракталов по телам свечей.

Вместе объём и фракталы позволяют упростить Price Action до понятной последовательности:

**Фрактал → Свинг → Фрактал**

Задача индикатора — не генерировать готовые сигналы LONG или SHORT, а сделать структуру рынка, изменение активности и важные события цены более наглядными и удобными для мониторинга.

---

## 1. Фильтрация объёма

Volume Pulse анализирует объём каждой закрытой свечи относительно динамически изменяющейся статистической нормы.

Для расчёта используются:

- EMA объёма;
- стандартное отклонение объёма;
- процентное изменение объёма относительно предыдущей свечи.

Значимые объёмные события разделяются на четыре уровня.

**Рост объёма**

Показывает существенное ускорение объёма относительно предыдущей свечи.

При стандартных настройках объём должен увеличиться более чем на 20%.

Это позволяет обнаруживать резкое изменение активности ещё до того, как абсолютный объём достигнет экстремального статистического значения.

**Повышенный объём**

Объём достигает первого статистического порога:

`EMA объёма + 0.7 × стандартное отклонение`

**Высокий объём**

Более сильное отклонение от текущего объёмного режима:

`EMA объёма + 1.8 × стандартное отклонение`

**Экстремальный объём**

Самый сильный уровень объёмного события:

`EMA объёма + 3.0 × стандартное отклонение`

Между уровнями действует строгий приоритет.

Если свеча одновременно соответствует нескольким условиям, ей присваивается только самый высокий уровень.

Это убирает дублирование информации и сохраняет график чистым.

Volume Pulse не использует одно фиксированное значение объёма для любых рыночных условий. Пороговые значения постоянно адаптируются к текущему режиму конкретного инструмента и таймфрейма.

Обычные свечи можно визуально приглушить, чтобы внимание автоматически концентрировалось на участках с действительно значимой активностью.

https://www.tradingview.com/x/gHQiRIen/

---

## 2. Фракталы и свинги

В Volume Pulse встроена отдельная система Body Fractals.

В отличие от классического Williams Fractal, где структура обычно определяется по максимумам и минимумам свечей, здесь расчёт производится по телам:

`Body High = max(Open, Close)`

`Body Low = min(Open, Close)`

Таким образом, фитиль сам по себе не определяет наличие фрактала.

Это позволяет отделять временные выбросы цены через wick от структуры, сформированной телами свечей.

Доступны два режима:

**Фрактал из 3 свечей**

Для формирования структурной точки требуется одна свеча слева и одна справа.

**Фрактал из 5 свечей**

Используются две свечи слева и две справа.

После подтверждения маркер отображается непосредственно на той свече, где сформировался исходный структурный экстремум.

Также доступны два режима работы с равными уровнями:

**Last Bar** — равные уровни допускаются слева от потенциального фрактала, однако справа уровень должен быть подтверждён строго.

**Strict** — любое равенство уровня слева или справа отменяет формирование фрактала.

Один из основных способов использования Volume Pulse — упростить Price Action до двух элементов:

**Фрактал → Свинг → Фрактал**

Подтверждённый фрактал становится структурной точкой.

Движение между такими точками формирует свинг.

Volume Pulse дополнительно показывает, где внутри движения происходило существенное изменение объёмной активности.

Вместо анализа каждой отдельной свечи можно концентрироваться на более важных вопросах:

- откуда начался текущий свинг;
- где появился значимый объём;
- увеличивалась ли активность во время продолжения движения или возле экстремума;
- появился ли после этого новый структурный фрактал;
- как цена отреагировала после события.

Индикатор не интерпретирует рынок вместо трейдера. Он структурирует информацию, необходимую для анализа.

https://www.tradingview.com/x/eP7WKUzh/

---

## 3. Оповещения и рабочий процесс

Volume Pulse не только улучшает визуальное чтение графика, но и упрощает мониторинг рынка.

Отдельно можно включать уведомления для каждого уровня объёма.

Также независимо настраиваются уведомления по фракталам:

- Lower Fractal / LONG context;
- Upper Fractal / SHORT context.

Все события определяются на закрытой свече.

Для работы достаточно создать один Alert в TradingView и выбрать:

**Any alert() function call**

После этого один Alert может принимать все включённые события Volume Pulse.

Если на закрытии одного бара одновременно происходит несколько активных событий, индикатор объединяет их в одно уведомление.

Практический рабочий процесс может выглядеть следующим образом:

**Structure → Volume Event → Price Reaction → Fractal Confirmation**

Сначала определяется текущий структурный свинг.

Далее трейдер наблюдает за появлением значимого объёмного события.

После этого оценивается реакция цены.

Следующий подтверждённый Body Fractal добавляет новую структурную информацию.

Система уведомлений уменьшает необходимость постоянно наблюдать за каждым графиком и помогает концентрироваться на моментах, когда на рынке действительно произошло что-то важное.

https://www.tradingview.com/x/6eVXW9u5/

---

## Отображение свечей

В индикаторе предусмотрено два режима.

**Direction Mode**

Значимые объёмные свечи сохраняют направление цены:

- растущая свеча — bullish-цвет;
- падающая свеча — bearish-цвет.

**Level Mode**

Каждому уровню объёма можно назначить собственный цвет.

В этом режиме визуальный акцент смещается с направления свечи на силу объёмного события.

Все цвета и значения прозрачности можно настроить самостоятельно.

---

## Отображение фракталов

Фракталы могут отображаться в виде:

- точек;
- крестиков;
- треугольников.

Верхние и нижние фракталы можно включать и выключать отдельно.

Настраиваются размер, цвет, прозрачность и расстояние маркера от цены.

Также доступно два варианта визуальной привязки:

**Wick** или **Body**.

Эта настройка влияет только на положение маркера на графике.

Сам расчёт фрактала всегда производится по телам свечей.

Расстояние маркеров рассчитывается относительно ATR, что помогает сохранять аккуратный визуальный отступ на разных инструментах и масштабах цены.

---

## Как интерпретировать Volume Pulse

Volume Pulse использует стандартную серию объёма, которую предоставляет источник данных графика.

Индикатор **не рассчитывает настоящий Bid/Ask Delta** и напрямую не определяет агрессивных покупателей и продавцов.

В режиме Direction bullish- и bearish-цвет отражает направление самой свечи, а не отдельно рассчитанный покупательский или продавецкий объём.

Поэтому объёмное событие необходимо анализировать вместе с:

**Price Action + Location + Structure + Subsequent Reaction**

Высокий объём на bullish-свече говорит о повышенной активности во время роста цены, но сам по себе ещё не доказывает контроль покупателей.

То же самое относится к bearish-свечам.

Контекст остаётся критически важным.

---

## Зачем трейдеру Volume Pulse

Главное преимущество индикатора — **сжатие информации**.

Обычный график состоит из сотен свечей и постоянных изменений объёма.

Но далеко не каждое событие заслуживает одинакового внимания.

Volume Pulse создаёт иерархию:

**Обычная активность → Рост активности → Значимый объём → Структурное событие**

В результате трейдер может меньше времени тратить на просмотр каждой отдельной свечи и больше — на анализ областей, где поведение рынка действительно изменилось.

Индикатор может быть полезен для:

- discretionary-трейдинга;
- анализа Price Action;
- анализа рыночной структуры;
- мониторинга нескольких активов;
- поиска изменений объёмной активности;
- анализа взаимодействия структуры и объёма;
- построения работы через систему уведомлений.

---

## Настройки

Volume Pulse позволяет изменять:

- период расчёта объёма;
- чувствительность роста объёма;
- статистические пороги;
- режим окрашивания свечей;
- bullish- и bearish-цвет;
- цвета отдельных уровней;
- прозрачность обычных и значимых свечей;
- фракталы из 3 или 5 свечей;
- правила работы с равными уровнями;
- отображение верхних и нижних фракталов;
- тип и размер маркеров;
- визуальную привязку к Wick или Body;
- ATR-отступ маркеров;
- уведомления для каждого уровня объёма;
- уведомления для верхних и нижних фракталов.

Это позволяет адаптировать индикатор под разные рынки, таймфреймы и визуальный стиль трейдера.

---

**Capital Trade | Volume Pulse не пытается прогнозировать рынок вместо трейдера.**

Его задача — сделать уже существующую информацию цены и объёма проще для фильтрации, структурирования, мониторинга и последующего анализа.

**Меньше визуального шума.  
Больше значимой информации.  
Структура, объём и уведомления — на одном графике.**

https://www.tradingview.com/x/0obCEVoB/

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// Original Williams Fractals template: Mit Nayi.
// Modified for Capital Trade: body-only fractals, adaptive spacing and alerts.
// Combined with Volume Pulse candle highlighting.

//@version=6
indicator("Capital Trade | Volume Pulse", shorttitle="CT Volume Pulse", overlay=true, max_labels_count=500)

// ── Alerts ──
gAlerts = "Alerts"

volumeAlerts = input.bool(true, "Volume alerts", group=gAlerts,
     tooltip="Create one TradingView alert using Any alert() function call. All enabled events are evaluated at bar close on the chart timeframe.")

alertL1 = input.bool(true, "L1", inline="volumeAlerts", group=gAlerts)
alertL2 = input.bool(true, "L2", inline="volumeAlerts", group=gAlerts)
alertL3 = input.bool(true, "L3", inline="volumeAlerts", group=gAlerts)
alertL4 = input.bool(true, "L4", inline="volumeAlerts", group=gAlerts)

alertVolumeLong = input.bool(true, "Long", inline="volumeDirection", group=gAlerts,
    tooltip="Volume direction follows the candle: close >= open = Long; close < open = Short.")
alertVolumeShort = input.bool(true, "Short", inline="volumeDirection", group=gAlerts)

fractalAlerts = input.bool(true, "Fractal alerts", group=gAlerts)
alertLower = input.bool(true, "Lower · Long", inline="fractalAlerts", group=gAlerts)
alertUpper = input.bool(true, "Upper · Short", inline="fractalAlerts", group=gAlerts)

// ── Volume ──
gVolume = "Volume"

volLength = input.int(20, "EMA / StDev length", minval=2, group=gVolume)

growthPct = input.float(16.0, "L1 · Growth (%)", minval=0, step=1, group=gVolume,
     tooltip="Volume must increase by more than this percentage versus the previous bar. Higher volume levels take priority.")

mult1 = input.float(0.6, "L2 · StDev multiplier", minval=0.1, step=0.1, group=gVolume)
mult2 = input.float(1.8, "L3 · StDev multiplier", minval=0.1, step=0.1, group=gVolume)
mult3 = input.float(3.0, "L4 · StDev multiplier", minval=0.1, step=0.1, group=gVolume)

// ── Candle appearance ──
gCandles = "Candles"

paintCandles = input.bool(true, "Color candles", group=gCandles)

colorMode = input.string("Direction", "Color mode",
     options=["Direction", "Level"], group=gCandles)

fadeNormal = input.bool(true, "Fade normal candles", group=gCandles,
     tooltip="Apply normal-bar transparency to candles without a volume event. Display only; does not affect alerts.")

bullColor = input.color(#089981, "Bullish", inline="direction", group=gCandles)
bearColor = input.color(#000000, "Bearish", inline="direction", group=gCandles)

normalColor = input.color(#000000, "Normal", inline="levels0", group=gCandles,
     tooltip="Used in Level color mode only.")

level1Color = input.color(#2B2B2B, "L1", inline="levels1", group=gCandles)
level2Color = input.color(#2B2B2B, "L2", inline="levels1", group=gCandles)
level3Color = input.color(#2B2B2B, "L3", inline="levels2", group=gCandles)
level4Color = input.color(#2B2B2B, "L4", inline="levels2", group=gCandles)

// ── Candle transparency ──
gOpacity = "Candle Transparency"

normalAlpha = input.int(45, "Normal", minval=0, maxval=100, group=gOpacity,
     tooltip="0 = opaque. 100 = invisible.")

level1Alpha = input.int(0, "L1", minval=0, maxval=100, inline="alpha12", group=gOpacity)
level2Alpha = input.int(0, "L2", minval=0, maxval=100, inline="alpha12", group=gOpacity)
level3Alpha = input.int(0, "L3", minval=0, maxval=100, inline="alpha34", group=gOpacity)
level4Alpha = input.int(0, "L4", minval=0, maxval=100, inline="alpha34", group=gOpacity)

// ── Body fractals ──
gFractals = "Body Fractals"

fractalBars = input.string("5", "Length", options=["3", "5"], group=gFractals)

equalMode = input.string("Last bar", "Equal levels",
     options=["Last bar", "Strict"], group=gFractals,
     tooltip="Last bar: equal body levels are allowed on the left, but not on the right. Strict: equal levels on either side invalidate the fractal.")

showUpper = input.bool(true, "Upper", inline="fractalVisibility", group=gFractals,
     tooltip="Display only. Does not affect alerts.")

showLower = input.bool(true, "Lower", inline="fractalVisibility", group=gFractals,
     tooltip="Display only. Does not affect alerts.")

// ── Fractal appearance ──
gMarkers = "Fractal Markers"

markerType = input.string("Triangles", "Shape",
     options=["Dots", "Crosses", "Triangles"], group=gMarkers)

markerColor = input.color(color.rgb(160, 160, 160), "Color", group=gMarkers)
markerAlpha = input.int(60, "Transparency", minval=0, maxval=100, group=gMarkers)

pointSize = input.int(1, "Dot / cross size", minval=1, maxval=5, group=gMarkers)

triangleSize = input.string("Classic", "Triangle size",
     options=["Classic", "Tiny", "Small", "Normal"], group=gMarkers,
     tooltip="Classic uses automatic sizing from the original Williams Fractals template.")

anchor = input.string("Wick", "Anchor", options=["Wick", "Body"], group=gMarkers,
     tooltip="Visual anchor only. Fractals are always calculated from candle bodies.")

upperGapPct = input.float(10.0, "Upper gap (% ATR)", minval=0, step=1, group=gMarkers)
lowerGapPct = input.float(10.0, "Lower gap (% ATR)", minval=0, step=1, group=gMarkers)

// ── Validate volume settings ──
if barstate.isfirst and not (mult1 < mult2 and mult2 < mult3)
    runtime.error("StDev multipliers must increase: L2 < L3 < L4.")

// ── Volume calculation ──
// Thresholds include the current bar, as in the original Volume Pulse.

emaVol = ta.ema(volume, volLength)
stdVol = ta.stdev(volume, volLength)

threshold1 = emaVol + stdVol * mult1
threshold2 = emaVol + stdVol * mult2
threshold3 = emaVol + stdVol * mult3

validVolume = not na(volume) and volume > 0

volumeGrowth = not na(volume[1]) and volume[1] > 0 ? (volume - volume[1]) / volume[1] * 100.0 : na

growthEvent = validVolume and not na(volumeGrowth) and volumeGrowth > growthPct
thresholdsReady = validVolume and not na(stdVol) and stdVol > 0

int volumeLevel = 0

if thresholdsReady and volume >= threshold3
    volumeLevel := 4
else if thresholdsReady and volume >= threshold2
    volumeLevel := 3
else if thresholdsReady and volume >= threshold1
    volumeLevel := 2
else if growthEvent
    volumeLevel := 1

// ── Candle coloring ──
volumeColor = switch volumeLevel
    4 => level4Color
    3 => level3Color
    2 => level2Color
    1 => level1Color
    => normalColor

candleAlpha = switch volumeLevel
    4 => level4Alpha
    3 => level3Alpha
    2 => level2Alpha
    1 => level1Alpha
    => normalAlpha

directionColor = close >= open ? bullColor : bearColor
candleColor = colorMode == "Direction" ? directionColor : volumeColor

shouldPaint = paintCandles and barstate.isconfirmed and not na(volume) and (volumeLevel > 0 or fadeNormal)

barcolor(shouldPaint ? color.new(candleColor, candleAlpha) : na,
     title="Volume candles")

// ── Body fractal calculation ──
// Fractals are independent of volume conditions.

bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)

int rightBars = fractalBars == "5" ? 2 : 1
bool allowEqualLeft = equalMode == "Last bar"

bool upperFractal = bar_index >= 2 * rightBars and barstate.isconfirmed
bool lowerFractal = bar_index >= 2 * rightBars and barstate.isconfirmed

for i = 1 to rightBars
    bool upperLeft = allowEqualLeft ? bodyHigh[rightBars] >= bodyHigh[rightBars + i] : bodyHigh[rightBars] > bodyHigh[rightBars + i]
    bool lowerLeft = allowEqualLeft ? bodyLow[rightBars] <= bodyLow[rightBars + i] : bodyLow[rightBars] < bodyLow[rightBars + i]

    upperFractal := upperFractal and upperLeft and bodyHigh[rightBars] > bodyHigh[rightBars - i]
    lowerFractal := lowerFractal and lowerLeft and bodyLow[rightBars] < bodyLow[rightBars - i]

// ── Fractal spacing ──
atrValue = ta.atr(14)
trValue = ta.tr(true)

float spacingRange = nz(atrValue[rightBars], trValue[rightBars])

float upperDistance = spacingRange * upperGapPct / 100.0
float lowerDistance = spacingRange * lowerGapPct / 100.0

float upperBase = anchor == "Wick" ? high[rightBars] : bodyHigh[rightBars]
float lowerBase = anchor == "Wick" ? low[rightBars] : bodyLow[rightBars]

float upperY = showUpper and upperFractal ? upperBase + upperDistance : na
float lowerY = showLower and lowerFractal ? lowerBase - lowerDistance : na

// ── Fractal display ──
// One object per fractal: recolor the actual marker, with no overlay or lines.
// Only the latest visible confirmation is highlighted until the next one.
// If both sides confirm on the same bar, both belong to that latest event.
// TradingView retains at most 500 label-based markers.

drawColor = color.new(markerColor, markerAlpha)

fractalMarkerSize = markerType == "Triangles" ? (triangleSize == "Classic" ? size.auto : triangleSize == "Tiny" ? size.tiny : triangleSize == "Small" ? size.small : size.normal) : (pointSize == 1 ? size.tiny : pointSize == 2 ? size.small : pointSize == 3 ? size.normal : pointSize == 4 ? size.large : size.huge)

upperStyle = markerType == "Triangles" ? label.style_triangledown : markerType == "Crosses" ? label.style_cross : label.style_circle
lowerStyle = markerType == "Triangles" ? label.style_triangleup : markerType == "Crosses" ? label.style_cross : label.style_circle

var label latestUpperMarker = na
var label latestLowerMarker = na

bool newUpper = showUpper and upperFractal
bool newLower = showLower and lowerFractal

if newUpper or newLower
    if not na(latestUpperMarker)
        label.set_color(latestUpperMarker, drawColor)

    if not na(latestLowerMarker)
        label.set_color(latestLowerMarker, drawColor)

    latestUpperMarker := na
    latestLowerMarker := na

    if newUpper
        latestUpperMarker := label.new(x=time[rightBars], y=upperY, text="", xloc=xloc.bar_time, yloc=yloc.price, color=color.new(#F23645, 0), style=upperStyle, size=fractalMarkerSize)

    if newLower
        latestLowerMarker := label.new(x=time[rightBars], y=lowerY, text="", xloc=xloc.bar_time, yloc=yloc.price, color=color.new(#089981, 0), style=lowerStyle, size=fractalMarkerSize)

// ── Alert helpers ──
f_timeframeLabel() =>
    string result = timeframe.period

    if timeframe.isseconds
        result := str.tostring(timeframe.multiplier) + "S"
    else if timeframe.isminutes
        result := timeframe.multiplier % 60 == 0 ? str.tostring(timeframe.multiplier / 60, "#") + "H" : str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isdaily
        result := str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        result := str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        result := str.tostring(timeframe.multiplier) + "M"

    result

f_append(string existing, string eventText) =>
    existing + (str.length(existing) > 0 ? "\n" : "") + eventText

// ── Unified alert engine ──
// One message per closing bar, containing every enabled event.
// A disabled higher volume level does not fall back to a lower level.

bool volumeLevelEnabled = switch volumeLevel
    4 => alertL4
    3 => alertL3
    2 => alertL2
    1 => alertL1
    => false

string volumeMessage = switch volumeLevel
    4 => "▂▄▆█ VOLUME"
    3 => "▂▄▆ VOLUME"
    2 => "▂▄ VOLUME"
    1 => "▂ VOLUME"
    => ""

// Match the existing candle coloring, including doji candles.
bool volumeIsLong = close >= open
bool volumeDirectionEnabled = volumeIsLong ? alertVolumeLong : alertVolumeShort
string volumeDirection = volumeIsLong ? "LONG" : "SHORT"

string tfLabel = f_timeframeLabel()
string fractalContext = " · " + syminfo.ticker + " · " + tfLabel
string alertMessage = ""

if barstate.isconfirmed
    if volumeAlerts and volumeLevelEnabled and volumeDirectionEnabled
        alertMessage := f_append(alertMessage, volumeMessage + " " + volumeDirection)

    if fractalAlerts and alertLower and lowerFractal
        alertMessage := f_append(alertMessage, "▲ LONG FRACTAL CONFIRM")

    if fractalAlerts and alertUpper and upperFractal
        alertMessage := f_append(alertMessage, "▼ SHORT FRACTAL CONFIRM")

    if str.length(alertMessage) > 0
        alert(alertMessage, alert.freq_once_per_bar_close)
````
