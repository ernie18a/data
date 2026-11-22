# MA Retest Strategy

- url: https://www.tradingview.com/script/hQWz13rn-ma-retest-strategy/
- type: indicator
- pine_id: PUB;97530c740cb34297913969f2f8b0ac17
- version: 2.0

## Description

[b]MA Retest Strategy [Newtrader189][/b]

[b]Overview[/b]

MA Retest Strategy is a trend-following system built around a simple but powerful idea: price rarely moves in a straight line — it pulls back to test a moving average before continuing in the direction of the trend. Instead of just plotting two moving averages and leaving you to guess, this indicator turns that pullback-and-continuation behavior into a complete, rule-based trade framework: it detects the retest, marks the exact entry, calculates a volatility-aware stop-loss and take-profit, tracks the outcome of every signal, and even scans four other symbols of your choice for the same setup in real time.
The trend direction is defined by two Exponential Moving Averages (EMA) — a fast one (default length 50) and a slow one (default length 200). Their relationship (fast above slow = uptrend, fast below slow = downtrend) is combined with a retest of the fast EMA: price must pierce through the fast EMA against the trend and then close back on the trend side. That close is the signal.

[b]Trading Logic[/b]
[b]Long entry conditions:[/b]
1.	The fast EMA is above the slow EMA (uptrend).
2.	Within the last few bars, price has pierced below the fast EMA (a genuine pullback, not just noise).
3.	The current candle closes back above the fast EMA, confirming the retest is over and the trend is resuming.
When all three conditions align, the indicator plots a BUY label, and immediately draws four price levels: Entry, Stop-Loss, Take-Profit, and Breakeven, each as a line with a live price tag on the right edge for easy order placement.
[b]Short entry conditions are the mirror image: [/b]fast EMA below slow EMA, a pierce above the fast EMA, and a close back below it.
If price is currently trading between the two moving averages (neither clearly above nor below), no new signal is evaluated — this "no man's land" filter avoids chasing signals in a choppy, undecided market.
Once a setup is triggered, it stays open (as a pending order, then as an active trade once price reaches the entry) until it's resolved by hitting the stop, hitting the target, timing out, or being invalidated by an opposite signal — only one setup per direction is ever open at a time, and an opposite signal automatically cancels whatever is currently active.

[b]Risk Management[/b]
The stop-loss is never left to guesswork. You can choose between three calculation methods:
•	[b]Swing (High/Low):[/b] stop placed at the nearest swing low/high within a lookback window.
•	[b]ATR: [/b]stop placed at a multiple of the Average True Range from the entry price — automatically adapts to the current volatility of the instrument.
•	[b]Percent of Price:[/b] a fixed percentage distance from the entry price.
Regardless of the method chosen, a hard risk ceiling (expressed as % of price) prevents the stop from ever being placed unreasonably far away — for example because of a single abnormal wick or a bad tick in the data feed. Swing mode additionally has its own volatility-aware clamp (a maximum deviation expressed in ATR multiples), since raw swing highs/lows are the most exposed to being skewed by one outlier candle.
The take-profit is calculated as a multiple of the initial risk (an "R-multiple"), and a separate breakeven marker line shows where price would need to reach for you to consider moving your stop to entry — because in a mean-reversion-to-trend system like this, once price reaches roughly 1R in your favor, the probability of it snapping back toward the moving average (rather than continuing cleanly to the full target) increases, so protecting the trade at breakeven is a sound practice.

[b]Dual Dashboard System[/b]

[b]Statistics Panel[/b] — tracks every signal the indicator has generated on the current chart and breaks the results down into Take-Profit, Stop-Loss, and Breakeven outcomes (a stop hit after price already touched the breakeven level is counted separately from a "clean" stop-loss, since in practice you'd have moved your stop by then). You can filter the statistics to the full history, the last N days, or from a fixed date — ideal for quickly gauging how well the current settings are performing on a specific symbol before you commit to trading it.
[b]Symbol Scanner[/b] — lets you monitor up to five other symbols for the exact same setup, in real time, without leaving your current chart. For each symbol it shows whether a signal is currently pending or already active, in which direction, and its entry/stop/target levels. Note: the scanner applies the same strategy settings (moving average lengths, stop method, R-multiple, etc.) that are set for the main chart — it is not independently configurable per symbol.

[b]How to Use[/b]

1.	Open the symbol and timeframe you're interested in, and check the Statistics panel — a strong win rate and consistent R:R suggest the market is currently trending cleanly enough for mean-reversion entries to work.
2.	If the recent win rate is high, the market is respecting the moving average structure and the setup is worth trading. If it's dropping, the market may be entering consolidation — better to wait for a cleaner trend to re-establish.
3.	Use the plotted Entry/Stop/Take-Profit/Breakeven lines and their price tags to place your actual order.
4.	Once price reaches the breakeven marker, consider moving your live stop-loss to entry — this is a discretionary decision the indicator flags for you but does not automate.
5.	Use the Symbol Scanner to keep an eye on other assets in your watchlist without switching charts constantly.

[b]Settings Reference[/b]

[b]General[/b]
•	Source — the price series used to calculate both moving averages (default: Close).
[b]Moving Average[/b]
•	MA fast — length of the fast EMA (default 50).
•	MA fast line width — plot thickness of the fast EMA.
•	MA slow — length of the slow EMA (default 200).
•	MA slow line width — plot thickness of the slow EMA.
•	Bull color / Bear color — color of each MA line and of the shaded fill between them (tinted according to current trend direction).
[b]Strategy[/b]
•	MA Pierce Check Window (bars) — how many recent bars are checked to confirm price genuinely pierced the fast EMA before the retest close (default 3).
•	Swing Point Lookback (bars) — lookback window used to find the nearest swing high/low for Swing-mode stops, and also used as part of the warm-up gate before the indicator starts evaluating signals (default 10).
•	Take Profit, R (risk multiple) — target distance expressed as a multiple of the initial risk (default 3 = 3R).
•	Max Bars in Open Setup (timeout) — if a signal doesn't resolve (neither stop nor target hit) within this many bars, it's force-closed and logged separately as a timeout rather than left open indefinitely (default 300).
•	Stop Loss Calculation Method — choose between Swing (High/Low), ATR, or Percent of Price.
•	ATR Length — averaging period for the ATR calculation (default 14).
•	ATR Multiplier for Stop — multiplier applied to ATR when the Stop mode is set to ATR (default 1.5).
•	Stop, % of Entry Price — fixed stop distance used only when the Stop mode is set to Percent of Price (default 1%).
•	Max Allowed Risk, % of Price — hard ceiling on stop distance, applied regardless of the selected mode, to protect against abnormal candles or bad data ticks (default 5%).
•	Also Cap Swing Stop by ATR (recommended) — an additional, volatility-adaptive safety clamp that applies only in Swing mode, tighter and more responsive than the flat percentage cap.
•	Max Swing Stop Deviation, x ATR — multiplier for the clamp above (default 3).
•	Move to Breakeven, R (risk multiple) — the R-distance at which the breakeven marker line is drawn (default 1 = 1R).
[b]Visualization[/b]
•	Show BUY/SELL Labels — toggle the signal labels on the chart.
•	Show SL/TP/BE Price Tags on Lines — toggle the live price tags at the right edge of each level line.
•	Fill Risk/Reward Zones — toggle the shaded risk/reward boxes.
•	BUY Label Color / SELL Label Color — colors of the signal labels.
•	Entry Line Color / Stop Loss Line Color / Take Profit Line Color / Breakeven Line Color — colors of the four level lines.
•	Reward Zone Color / Risk Zone Color — colors of the shaded zones.
•	Entry/SL/TP Line Width — thickness of the level lines.
[b]Statistics[/b]
•	Show Statistics Panel — toggle the on-chart stats table.
•	Panel Position — corner of the chart where the table is drawn.
•	Text Size — table font size.
•	Statistics Period — All History, Last N Days, or From Fixed Date.
•	N Days Back — used when Statistics Period is set to "Last N Days".
•	Start Date — used when Statistics Period is set to "From Fixed Date".
[b]Symbol Scanner[/b]
•	Show Scanner for Other Symbols — toggle the scanner table.
•	Symbol 1–5 — the five symbols to monitor.
•	Scanner Timeframe — timeframe used for the scan; leave blank to match the current chart's timeframe.
•	Scanner Panel Position — corner of the chart where the scanner table is drawn.
•	Scanner Panel Text Size — scanner table font size.

[b]Alerts[/b]

The indicator includes two ready-to-use alert conditions — Buy signal and Sell signal — that fire once per bar close and include the entry price, stop-loss, take-profit, and their distance in ticks directly in the alert message, so you can act on them without needing to open the chart.

[b]Disclaimer[/b]

This indicator is a tool to assist with technical analysis and trade planning — it does not constitute financial advice, and past signal performance shown in the Statistics panel is not a guarantee of future results. Always combine it with your own risk management and market context.

[b]Обзор[/b]
[b]MA Retest Strategy[/b] — это трендовая система, построенная вокруг простой, но рабочей идеи: цена редко движется по прямой — она откатывается к скользящей средней для ретеста, прежде чем продолжить движение по тренду. Вместо того чтобы просто отрисовать две скользящие средние и оставить трейдера гадать, этот индикатор превращает такое поведение "откат-продолжение" в полноценную систему с чёткими правилами: он находит ретест, отмечает точный вход, рассчитывает стоп-лосс и тейк-профит с учётом волатильности, отслеживает исход каждого сигнала и даже сканирует ещё четыре выбранных вами актива на предмет такой же ситуации в реальном времени.
Направление тренда определяется двумя экспоненциальными скользящими средними (EMA) — быстрой (по умолчанию период 50) и медленной (по умолчанию период 200). Их взаимное расположение (быстрая выше медленной — восходящий тренд, быстрая ниже — нисходящий) сочетается с ретестом быстрой EMA: цена должна проколоть быструю EMA против тренда, а затем закрыться обратно на стороне тренда. Это закрытие и есть сигнал.

[b]Логика торговли[/b]

[b]Условия входа в лонг:[/b]
1.	Быстрая EMA выше медленной EMA (восходящий тренд).
2.	За последние несколько баров цена проколола быструю EMA вниз (настоящий откат, а не рыночный шум).
3.	Текущая свеча закрывается обратно выше быстрой EMA, подтверждая, что ретест завершён и тренд возобновляется.
Когда все три условия совпадают, индикатор рисует ярлык BUY и сразу же размечает четыре ценовых уровня: вход, стоп-лосс, тейк-профит и безубыток — каждый в виде линии с "живым" ценником у правого края для удобной постановки ордера.
[b]Условия входа в шорт зеркальны:[/b] быстрая EMA ниже медленной, прокол быстрой EMA вверх, и закрытие обратно ниже неё.
Если цена в данный момент находится между двумя скользящими средними (не выше и не ниже отчётливо), новый сигнал не рассматривается — этот фильтр "нейтральной зоны" не даёт индикатору гнаться за сигналами на "рваном", неопределившемся рынке.
После срабатывания сетап остаётся открытым (сначала как отложенный ордер, затем как активная сделка после достижения цены входа), пока не будет закрыт по стопу, по тейку, по тайм-ауту или отменён встречным сигналом — в каждый момент времени открыт только один сетап на направление, и встречный сигнал автоматически отменяет текущий активный.

[b]Управление риском[/b]

Стоп-лосс никогда не рассчитывается "на глаз". Доступны три метода расчёта:
•	[b]Свинг (high/low):[/b] стоп ставится на ближайший минимум/максимум в пределах окна поиска.
•	[b]ATR:[/b] стоп ставится на расстоянии, кратном среднему истинному диапазону (ATR) от цены входа — автоматически подстраивается под текущую волатильность инструмента.
•	[b]Процент от цены:[/b] фиксированное процентное расстояние от цены входа.
Независимо от выбранного метода, жёсткий лимит риска (в % от цены) не позволяет стопу оказаться неоправданно далеко — например, из-за одиночного аномального фитиля или сбойного тика в данных биржи. У режима "Свинг" есть дополнительный, чувствительный к волатильности предохранитель (максимальное отклонение в множителях ATR), поскольку "сырые" свинг-хаи/лоу сильнее всего подвержены искажению одной нетипичной свечой.
Тейк-профит рассчитывается как кратное исходному риску значение ("R-множитель"), а отдельная линия безубытка показывает, на каком уровне цены имеет смысл задуматься о переводе стопа в точку входа — потому что в системе возврата-к-тренду вроде этой, как только цена проходит примерно 1R в вашу пользу, вероятность отката обратно к скользящей средней (вместо чистого продолжения до полного тейка) возрастает, поэтому защита сделки на безубытке — разумная практика.

[b]Двойная система панелей[/b]

[b]Панель статистики[/b] — отслеживает каждый сигнал, сгенерированный индикатором на текущем графике, и разбивает результаты на исходы "тейк-профит", "стоп-лосс" и "безубыток" (стоп, сработавший после того как цена уже коснулась уровня безубытка, считается отдельно от "чистого" стоп-лосса, поскольку на практике к этому моменту вы, скорее всего, уже перевели бы стоп). Статистику можно фильтровать по всей истории, последним N дням или с конкретной даты — удобно для быстрой оценки того, насколько хорошо текущие настройки работают на конкретном инструменте, прежде чем начинать торговать по нему.
[b]Сканер монет[/b] — позволяет отслеживать до пяти других выбранных активов на предмет точно такой же ситуации в реальном времени, не покидая текущий график. По каждому активу показывается, есть ли сейчас отложенный или уже активный сигнал, в каком направлении, а также его уровни входа/стопа/тейка. Важно: сканер использует те же настройки стратегии (периоды скользящих средних, метод расчёта стопа, R-множитель и т.д.), что заданы для основного графика — отдельной настройки под каждый актив в сканере нет.

[b]Применение[/b]

1.	Откройте нужный актив и таймфрейм и посмотрите на панель статистики — высокий процент выигрышных сделок и стабильное R:R говорят о том, что рынок сейчас достаточно чисто трендовый для входов по возврату к средней.
2.	Если недавний винрейт высокий, рынок соблюдает структуру скользящих средних, и сетап стоит торговать. Если он снижается, рынок может входить в фазу консолидации — лучше дождаться, пока тренд снова выровняется.
3.	Используйте отрисованные линии входа/стопа/тейка/безубытка и их ценники для постановки реального ордера.
4.	Когда цена достигает отметки безубытка, стоит рассмотреть перевод реального стоп-лосса в точку входа — это решение, на которое индикатор указывает, но не выполняет автоматически.
5.	Используйте сканер монет, чтобы следить за другими активами из вашего вотчлиста, не переключаясь постоянно между графиками.

[b]Описание настроек[/b]

[b]General (Общие настройки)[/b]
•	Source — ценовой ряд, по которому рассчитываются обе скользящие средние (по умолчанию — цена закрытия).
Moving Average
•	MA fast — период быстрой EMA (по умолчанию 50).
•	MA fast line width — толщина линии быстрой EMA.
•	MA slow — период медленной EMA (по умолчанию 200).
•	MA slow line width — толщина линии медленной EMA.
•	Bull color / Bear color — цвет каждой линии MA и заливки между ними (окрашивается в зависимости от текущего направления тренда).

[b]Strategy[/b]
•	MA Pierce Check Window (bars) — сколько последних баров проверяется на предмет реального прокола быстрой EMA перед закрытием-ретестом (по умолчанию 3).
•	Swing Point Lookback (bars) — окно поиска ближайшего свинг-хая/лоу для режима стопа "Свинг", а также используется как часть "прогрева" перед тем, как индикатор начнёт оценивать сигналы (по умолчанию 10).
•	Take Profit, R (risk multiple) — целевое расстояние тейк-профита, выраженное как множитель исходного риска (по умолчанию 3 = 3R).
•	Max Bars in Open Setup (timeout) — если сигнал не резолвится (не задет ни стоп, ни тейк) за это количество баров, он принудительно закрывается и учитывается отдельно как тайм-аут, а не остаётся открытым бесконечно (по умолчанию 300).
•	Stop Loss Calculation Method — выбор между Свинг (high/low), ATR или Процент от цены.
•	ATR Length — период усреднения для расчёта ATR (по умолчанию 14).
•	ATR Multiplier for Stop — множитель ATR, применяемый, когда метод стопа — ATR (по умолчанию 1.5).
•	Stop, % of Entry Price — фиксированное расстояние стопа, используется только в режиме "Процент от цены" (по умолчанию 1%).
•	Max Allowed Risk, % of Price — жёсткий лимит расстояния стопа, применяется независимо от выбранного режима, для защиты от аномальных свечей или сбойных тиков в данных (по умолчанию 5%).
•	Also Cap Swing Stop by ATR (recommended) — дополнительный, чувствительный к волатильности предохранитель, работающий только в режиме "Свинг", теснее и отзывчивее плоского процентного лимита.
•	Max Swing Stop Deviation, x ATR — множитель для указанного выше лимита (по умолчанию 3).
•	Move to Breakeven, R (risk multiple) — расстояние в R, на котором рисуется линия отметки безубытка (по умолчанию 1 = 1R).
Visualization
•	Show BUY/SELL Labels — вкл/выкл ярлыков сигналов на графике.
•	Show SL/TP/BE Price Tags on Lines — вкл/выкл "живых" ценников у правого края каждой линии уровня.
•	Fill Risk/Reward Zones — вкл/выкл закрашенных зон риска/прибыли.
•	BUY Label Color / SELL Label Color — цвета ярлыков сигналов.
•	Entry Line Color / Stop Loss Line Color / Take Profit Line Color / Breakeven Line Color — цвета четырёх линий уровней.
•	Reward Zone Color / Risk Zone Color — цвета закрашенных зон.
•	Entry/SL/TP Line Width — толщина линий уровней.

[b]Statistics[/b]
•	Show Statistics Panel — вкл/выкл таблицы статистики на графике.
•	Panel Position — угол графика, в котором рисуется таблица.
•	Text Size — размер шрифта таблицы.
•	Statistics Period — вся история, последние N дней или с фиксированной даты.
•	N Days Back — используется, если период статистики — "последние N дней".
•	Start Date — используется, если период статистики — "с фиксированной даты".

[b]Symbol Scanner[/b]
•	Show Scanner for Other Symbols — вкл/выкл таблицы сканера.
•	Symbol 1–5 — пять отслеживаемых активов.
•	Scanner Timeframe — таймфрейм для сканирования; оставьте пустым, чтобы использовать таймфрейм текущего графика.
•	Scanner Panel Position — угол графика, в котором рисуется таблица сканера.
•	Scanner Panel Text Size — размер шрифта таблицы сканера.

[b]Алерты[/b]

Индикатор включает два готовых условия для алертов — Buy signal и Sell signal — которые срабатывают один раз на закрытии бара и содержат в тексте сообщения цену входа, стоп-лосс, тейк-профит и расстояние до них в тиках, так что действовать по ним можно, не открывая график.

[b]Отказ от ответственности[/b]
Этот индикатор — инструмент для технического анализа и планирования сделок, он не является финансовой рекомендацией, а прошлая эффективность сигналов, показанная на панели статистики, не гарантирует результатов в будущем. Всегда сочетайте его использование с собственным управлением риском и оценкой рыночного контекста.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Newtrader189

//@version=6
indicator(title="MA Retest Strategy", shorttitle="MA retest+", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// === VARIABLES ================================================={
string CORE  = "General"
string MA    = "Moving Average"
string STRAT = "Strategy"
string VIS   = "Visualization"
string STATS = "Statistics"
string SCAN  = "Symbol Scanner"
string FILT  = "Chop Filter"

var bool longSignal = false
var bool shortSignal = false

// Исходы сделок храним как (тип, время) для возможности фильтрации по периоду:
// тип: 0 = TP, 1 = SL, 2 = безубыток, 3 = отменено (стоп раньше входа/тайм-аут без входа), 4 = тайм-аут активной сделки
var array<int> outcomeType = array.new_int(0)
var array<int> outcomeTime = array.new_int(0)
//}

// === INPUTS: MA =================================================={
src  = input.source(close, title="Source", group=CORE)

ema1 = input.int(50, title='MA fast', group=MA)
ema1_line = input.int(1, title='MA fast line width', minval=1, maxval=5, step=1, group=MA)
ema2 = input.int(200, title='MA slow', group=MA)
ema2_line = input.int(3, title='MA slow line width', minval=1, maxval=5, step=1, group=MA)
color Bull = input.color(color.green, "Bull color", group=MA, inline="Line")
color Bear = input.color(color.red, "Bear color", group=MA, inline="Line")
//}

// === INPUTS: логика стратегии ====================================={
pierceLookback = input.int(3, "MA Pierce Check Window (bars)", minval=1, maxval=10, group=STRAT)
swingLookback  = input.int(10, "Swing Point Lookback (bars)", minval=2, maxval=25, group=STRAT)
rrMultiple     = input.float(3.0, "Take Profit, R (risk multiple)", minval=0.5, step=0.5, group=STRAT)
maxBarsOpen    = input.int(300, "Max Bars in Open Setup (timeout)", minval=10, group=STRAT)

slMode = input.string("ATR", "Stop Loss Calculation Method", options=["Swing (High/Low)", "ATR", "Percent of Price"], group=STRAT)
atrLength      = input.int(14, "ATR Length", minval=1, group=STRAT)
atrMultiplier  = input.float(1.5, "ATR Multiplier for Stop", minval=0.1, step=0.1, group=STRAT)
stopPercent    = input.float(1.0, "Stop, % of Entry Price (for Percent mode)", minval=0.05, step=0.05, group=STRAT)
maxRiskPercent = input.float(5.0, "Max Allowed Risk, % of Price (protection from abnormal candles)", minval=0.1, step=0.1, group=STRAT)
capSwingByATR       = input.bool(true, "Also Cap Swing Stop by ATR (recommended)", group=STRAT)
swingAtrCapMultiple = input.float(3.0, "Max Swing Stop Deviation, x ATR", minval=0.5, step=0.5, group=STRAT)
beMultiple     = input.float(1.0, "Move to Breakeven, R (risk multiple)", minval=0.1, step=0.1, group=STRAT)
//}

// === INPUTS: визуализация ==========================================={
showLabels = input.bool(true, "Show BUY/SELL Labels", group=VIS)
showPriceTags = input.bool(true, "Show SL/TP/BE Price Tags on Lines", group=VIS)
showZones  = input.bool(true, "Fill Risk/Reward Zones", group=VIS)
buyColor   = input.color(color.new(color.lime, 0), "BUY Label Color", group=VIS)
sellColor  = input.color(color.new(color.red, 0), "SELL Label Color", group=VIS)
entryColor = input.color(color.new(color.blue, 0), "Entry Line Color", group=VIS)
stopColor  = input.color(color.new(color.red, 0), "Stop Loss Line Color", group=VIS)
tpColor    = input.color(color.new(color.teal, 0), "Take Profit Line Color", group=VIS)
beColor    = input.color(color.new(color.gray, 0), "Breakeven Line Color", group=VIS)
rewardZoneColor = input.color(color.new(color.teal, 85), "Reward Zone Color", group=VIS)
riskZoneColor   = input.color(color.new(color.red, 85), "Risk Zone Color", group=VIS)
lineWidth  = input.int(2, "Entry/SL/TP Line Width", minval=1, maxval=5, group=VIS)
//}

// === INPUTS: панель статистики ======================================{
showStatsPanel = input.bool(true, "Show Statistics Panel", group=STATS)
statsPosInput  = input.string("Top Right", "Panel Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=STATS)
statsSizeInput = input.string("normal", "Text Size", options=["tiny", "small", "normal", "large"], group=STATS)
statsPeriodMode = input.string("All History", "Statistics Period", options=["All History", "Last N Days", "From Fixed Date"], group=STATS)
statsDaysBack   = input.int(7, "N Days Back (for 'Last N Days' mode)", minval=1, group=STATS)
statsStartDate  = input.time(timestamp("2026-01-01 00:00"), "Start Date (for 'From Fixed Date' mode)", group=STATS)
//}

// === INPUTS: сканер других монет ===================================={
showScanner = input.bool(true, "Show Scanner for Other Symbols", group=SCAN)
scanSymbol1 = input.symbol("BYBIT:BTCUSDT.P",  "Symbol 1", group=SCAN)
scanSymbol2 = input.symbol("BYBIT:ETHUSDT.P",  "Symbol 2", group=SCAN)
scanSymbol3 = input.symbol("BYBIT:XRPUSDT.P",  "Symbol 3", group=SCAN)
scanSymbol4 = input.symbol("BYBIT:SUIUSDT.P",  "Symbol 4", group=SCAN)
scanSymbol5 = input.symbol("BYBIT:HBARUSDT.P", "Symbol 5", group=SCAN)
scanTFInput = input.timeframe("", "Scanner Timeframe (blank = same as chart)", group=SCAN)
scanPosInput  = input.string("Top Left", "Scanner Panel Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=SCAN)
scanSizeInput = input.string("small", "Scanner Panel Text Size", options=["tiny", "small", "normal", "large"], group=SCAN)
//}

// === INPUTS: chop / whipsaw filter ==================================={
useATRSpreadFilter = input.bool(true, "Enable ATR Spread Filter", group=FILT)
minSpreadATR       = input.float(0.5, "Min EMA Spread, x ATR", minval=0, step=0.1, group=FILT)

usePercentileFilter  = input.bool(false, "Enable Percentile Spread Filter", group=FILT)
percentileLookback   = input.int(150, "Percentile Lookback (bars)", minval=20, group=FILT)
percentileThreshold  = input.float(30, "Min Spread Percentile, %", minval=0, maxval=100, step=5, group=FILT)

useCooldown  = input.bool(true, "Enable Opposite-Signal Cooldown", group=FILT)
cooldownBars = input.int(10, "Cooldown Bars After Opposite Signal", minval=0, group=FILT)
//}

// === MA counter =================================================={
pema1 = ta.ema(src, ema1)
pema2 = ta.ema(src, ema2)
atr   = ta.atr(atrLength)
//}

// === MA drawing ==================================================={
ema1plot = plot(pema1, title='MA fast', color=Bull, linewidth=ema1_line, style=plot.style_line)
ema2plot = plot(pema2, title='MA slow', color=Bear, linewidth=ema2_line, style=plot.style_line)
fill(ema1plot, ema2plot, color=pema1 > pema2 ? color.new(Bull, 95) : color.new(Bear, 95), editable=true, fillgaps=true)
//}

// === Тренд / фильтр "между скользящими не торгуем" ================{
longTrend   = pema1 > pema2
shortTrend  = pema1 < pema2
noTradeZone = close < math.max(pema1, pema2) and close > math.min(pema1, pema2)
readyToTrade = bar_index > (ema2 + swingLookback)   // не считаем сигналы, пока EMA slow не "прогрелась"
//}

// === Chop / whipsaw filter: blocks signals while the MAs are "glued" together =={
emaSpread = math.abs(pema1 - pema2)

atrSpreadOK = not useATRSpreadFilter or emaSpread >= minSpreadATR * atr

percentileSpreadValue = ta.percentile_nearest_rank(emaSpread, percentileLookback, percentileThreshold)
percentileSpreadOK = not usePercentileFilter or emaSpread >= percentileSpreadValue

chopFilterOK = atrSpreadOK and percentileSpreadOK
//}

// === Проверка прокола MA fast в недавних барах ====================={
bool pierceBelowMA = false
for i = 0 to pierceLookback - 1
    if low[i] <= pema1[i]
        pierceBelowMA := true

bool pierceAboveMA = false
for i = 0 to pierceLookback - 1
    if high[i] >= pema1[i]
        pierceAboveMA := true
//}

// === Условия сигналов =============================================={
// Long: тренд вверх, цена проколола ema1 снизу вверх и закрылась выше ema1
rawConfirmLong  = readyToTrade and longTrend  and ta.crossover(close, pema1)  and pierceBelowMA and not noTradeZone and chopFilterOK
// Short: зеркально
rawConfirmShort = readyToTrade and shortTrend and ta.crossunder(close, pema1) and pierceAboveMA and not noTradeZone and chopFilterOK

// Кулдаун: сигнал блокируется на N баров после сигнала в противоположную сторону
var int lastLongSignalBar  = na
var int lastShortSignalBar = na

cooldownOKLong  = not useCooldown or na(lastShortSignalBar) or (bar_index - lastShortSignalBar) > cooldownBars
cooldownOKShort = not useCooldown or na(lastLongSignalBar)  or (bar_index - lastLongSignalBar)  > cooldownBars

confirmLong  = rawConfirmLong  and cooldownOKLong
confirmShort = rawConfirmShort and cooldownOKShort

if confirmLong
    lastLongSignalBar := bar_index
if confirmShort
    lastShortSignalBar := bar_index
//}

// === Состояния LONG и SHORT (объявлены вместе, чтобы можно было гасить друг друга) ={
var float lEntry = na
var float lStop  = na
var float lTp    = na
var float lBe    = na
var bool  lPending = false
var bool  lActive  = false
var int   lSignalBar = na
var bool  lBeReached = false
var line  lEntryLine = na
var line  lStopLine  = na
var line  lTpLine    = na
var line  lBeLine    = na
var label lEntryLabel = na
var label lStopLabel = na
var label lTpLabel   = na
var label lBeLabel   = na
var box   lRewardBox = na
var box   lRiskBox   = na

var float sEntry = na
var float sStop  = na
var float sTp    = na
var float sBe    = na
var bool  sPending = false
var bool  sActive  = false
var int   sSignalBar = na
var bool  sBeReached = false
var line  sEntryLine = na
var line  sStopLine  = na
var line  sTpLine    = na
var line  sBeLine    = na
var label sEntryLabel = na
var label sStopLabel = na
var label sTpLabel   = na
var label sBeLabel   = na
var box   sRewardBox = na
var box   sRiskBox   = na
//}

// === Взаимная отмена: новый сигнал в противоположную сторону гасит текущий открытый сетап ={
if confirmLong and (sPending or sActive)
    line.set_x2(sEntryLine, bar_index)
    line.set_x2(sStopLine,  bar_index)
    line.set_x2(sTpLine,    bar_index)
    line.set_x2(sBeLine,    bar_index)
    if showPriceTags
        label.set_x(sStopLabel, bar_index)
        label.set_x(sTpLabel,   bar_index)
        label.set_x(sBeLabel,   bar_index)
        label.set_x(sEntryLabel, bar_index)
    if showZones
        box.set_right(sRewardBox, bar_index)
        box.set_right(sRiskBox,   bar_index)
    sPending := false
    sActive  := false
    sEntry := na
    sStop  := na
    sTp    := na
    sSignalBar := na

if confirmShort and (lPending or lActive)
    line.set_x2(lEntryLine, bar_index)
    line.set_x2(lStopLine,  bar_index)
    line.set_x2(lTpLine,    bar_index)
    line.set_x2(lBeLine,    bar_index)
    if showPriceTags
        label.set_x(lStopLabel, bar_index)
        label.set_x(lTpLabel,   bar_index)
        label.set_x(lBeLabel,   bar_index)
        label.set_x(lEntryLabel, bar_index)
    if showZones
        box.set_right(lRewardBox, bar_index)
        box.set_right(lRiskBox,   bar_index)
    lPending := false
    lActive  := false
    lEntry := na
    lStop  := na
    lTp    := na
    lSignalBar := na
//}

// === LONG сетап ===================================================={
if confirmLong and not lPending and not lActive
    float entryCand = close                            // пробой хая сигнальной свечи
    float swingStop = ta.lowest(low, swingLookback)    // ближайший минимум слева
    float atrStop    = entryCand - atr * atrMultiplier
    float pctStop     = entryCand * (1 - stopPercent / 100)
    float stopCand = slMode == "ATR" ? atrStop : slMode == "Percent of Price" ? pctStop : swingStop
    float minAllowedStop = entryCand * (1 - maxRiskPercent / 100)
    stopCand := math.max(stopCand, minAllowedStop)     // не даем стопу улететь дальше maxRiskPercent от входа (защита от аномальных свечей)
    if slMode == "Swing (High/Low)" and capSwingByATR
        float minAllowedByAtr = entryCand - atr * swingAtrCapMultiple
        stopCand := math.max(stopCand, minAllowedByAtr)  // доп. защита свинг-стопа от одиночного аномального фитиля в окне поиска
    if stopCand < entryCand
        lEntry := entryCand
        lStop  := stopCand
        lTp    := lEntry + (lEntry - lStop) * rrMultiple
        lBe    := lEntry + (lEntry - lStop) * beMultiple
        lPending := true
        lSignalBar := bar_index
        lEntryLine := line.new(bar_index, lEntry, bar_index, lEntry, color=entryColor, width=lineWidth, style=line.style_dashed)
        lStopLine  := line.new(bar_index, lStop,  bar_index, lStop,  color=stopColor,  width=lineWidth)
        lTpLine    := line.new(bar_index, lTp,    bar_index, lTp,    color=tpColor,    width=lineWidth)
        lBeLine    := line.new(bar_index, lBe,    bar_index, lBe,    color=beColor,    width=1, style=line.style_dashed)
        if showPriceTags
            lEntryLabel := label.new(bar_index, lEntry, str.tostring(lEntry, format.mintick), style=label.style_label_left, color=entryColor, textcolor=color.white, size=size.small)
            lStopLabel := label.new(bar_index, lStop, str.tostring(lStop, format.mintick), style=label.style_label_left, color=stopColor, textcolor=color.white, size=size.small)
            lTpLabel   := label.new(bar_index, lTp,   str.tostring(lTp,   format.mintick), style=label.style_label_left, color=tpColor,   textcolor=color.white, size=size.small)
            lBeLabel   := label.new(bar_index, lBe,   str.tostring(lBe,   format.mintick), style=label.style_label_left, color=beColor,   textcolor=color.white, size=size.small)
        if showZones
            lRewardBox := box.new(bar_index, lTp, bar_index, lEntry, border_color=na, bgcolor=rewardZoneColor)
            lRiskBox   := box.new(bar_index, lEntry, bar_index, lStop, border_color=na, bgcolor=riskZoneColor)
        if showLabels
            label.new(bar_index, low, "BUY", style=label.style_label_up, color=buyColor, textcolor=color.white, size=size.small)

if lPending or lActive
    line.set_x2(lEntryLine, bar_index)
    line.set_x2(lStopLine,  bar_index)
    line.set_x2(lTpLine,    bar_index)
    line.set_x2(lBeLine,    bar_index)
    if showPriceTags
        label.set_x(lEntryLabel, bar_index)
        label.set_x(lStopLabel, bar_index)
        label.set_x(lTpLabel,   bar_index)
        label.set_x(lBeLabel,   bar_index)
    if showZones
        box.set_right(lRewardBox, bar_index)
        box.set_right(lRiskBox,   bar_index)

    if lActive and high >= lBe
        lBeReached := true

    if lPending and bar_index > lSignalBar and low <= lStop
        // цена ушла в стоп раньше, чем сработал вход - сетап отменяется
        array.push(outcomeType, 3)
        array.push(outcomeTime, time)
        lPending := false
        lEntry := na
        lStop  := na
        lTp    := na
        lSignalBar := na
    else if lPending and bar_index > lSignalBar and high >= lEntry
        // вход исполнен
        lPending := false
        lActive  := true
        lBeReached := false
    else if lActive and high >= lTp
        // тейк достигнут - линии перестают отрисовываться дальше
        array.push(outcomeType, 0)
        array.push(outcomeTime, time)
        lActive := false
        lEntry := na
        lStop  := na
        lTp    := na
        lSignalBar := na
    else if lActive and low <= lStop
        // стоп достигнут - линии перестают отрисовываться дальше
        array.push(outcomeType, lBeReached ? 2 : 1)
        array.push(outcomeTime, time)
        lActive := false
        lEntry := na
        lStop  := na
        lTp    := na
        lSignalBar := na
    else if not na(lSignalBar) and (bar_index - lSignalBar) > maxBarsOpen
        // тайм-аут: сетап не резолвился слишком долго - принудительно закрываем
        array.push(outcomeType, lPending ? 3 : 4)
        array.push(outcomeTime, time)
        lPending := false
        lActive  := false
        lEntry := na
        lStop  := na
        lTp    := na
        lSignalBar := na
//}

// === SHORT сетап (зеркально) ========================================{
if confirmShort and not sPending and not sActive
    float entryCand = close                              // пробой лоу сигнальной свечи
    float swingStop = ta.highest(high, swingLookback)   // ближайший максимум слева
    float atrStop    = entryCand + atr * atrMultiplier
    float pctStop     = entryCand * (1 + stopPercent / 100)
    float stopCand = slMode == "ATR" ? atrStop : slMode == "Percent of Price" ? pctStop : swingStop
    float maxAllowedStop = entryCand * (1 + maxRiskPercent / 100)
    stopCand := math.min(stopCand, maxAllowedStop)      // не даем стопу улететь дальше maxRiskPercent от входа
    if slMode == "Swing (High/Low)" and capSwingByATR
        float maxAllowedByAtr = entryCand + atr * swingAtrCapMultiple
        stopCand := math.min(stopCand, maxAllowedByAtr)  // доп. защита свинг-стопа от одиночного аномального фитиля в окне поиска
    if stopCand > entryCand
        sEntry := entryCand
        sStop  := stopCand
        sTp    := sEntry - (sStop - sEntry) * rrMultiple
        sBe    := sEntry - (sStop - sEntry) * beMultiple
        sPending := true
        sSignalBar := bar_index
        sEntryLine := line.new(bar_index, sEntry, bar_index, sEntry, color=entryColor, width=lineWidth, style=line.style_dashed)
        sStopLine  := line.new(bar_index, sStop,  bar_index, sStop,  color=stopColor,  width=lineWidth)
        sTpLine    := line.new(bar_index, sTp,    bar_index, sTp,    color=tpColor,    width=lineWidth)
        sBeLine    := line.new(bar_index, sBe,    bar_index, sBe,    color=beColor,    width=1, style=line.style_dashed)
        if showPriceTags
            sEntryLabel := label.new(bar_index, sEntry, str.tostring(sEntry, format.mintick), style=label.style_label_left, color=entryColor, textcolor=color.white, size=size.small)
            sStopLabel := label.new(bar_index, sStop, str.tostring(sStop, format.mintick), style=label.style_label_left, color=stopColor, textcolor=color.white, size=size.small)
            sTpLabel   := label.new(bar_index, sTp,   str.tostring(sTp,   format.mintick), style=label.style_label_left, color=tpColor,   textcolor=color.white, size=size.small)
            sBeLabel   := label.new(bar_index, sBe,   str.tostring(sBe,   format.mintick), style=label.style_label_left, color=beColor,   textcolor=color.white, size=size.small)
        if showZones
            sRewardBox := box.new(bar_index, sEntry, bar_index, sTp, border_color=na, bgcolor=rewardZoneColor)
            sRiskBox   := box.new(bar_index, sStop, bar_index, sEntry, border_color=na, bgcolor=riskZoneColor)
        if showLabels
            label.new(bar_index, high, "SELL", style=label.style_label_down, color=sellColor, textcolor=color.white, size=size.small)

if sPending or sActive
    line.set_x2(sEntryLine, bar_index)
    line.set_x2(sStopLine,  bar_index)
    line.set_x2(sTpLine,    bar_index)
    line.set_x2(sBeLine,    bar_index)
    if showPriceTags
        label.set_x(sEntryLabel, bar_index)
        label.set_x(sStopLabel, bar_index)
        label.set_x(sTpLabel,   bar_index)
        label.set_x(sBeLabel,   bar_index)
    if showZones
        box.set_right(sRewardBox, bar_index)
        box.set_right(sRiskBox,   bar_index)

    if sActive and low <= sBe
        sBeReached := true

    if sPending and bar_index > sSignalBar and high >= sStop
        array.push(outcomeType, 3)
        array.push(outcomeTime, time)
        sPending := false
        sEntry := na
        sStop  := na
        sTp    := na
        sSignalBar := na
    else if sPending and bar_index > sSignalBar and low <= sEntry
        sPending := false
        sActive  := true
        sBeReached := false
    else if sActive and low <= sTp
        array.push(outcomeType, 0)
        array.push(outcomeTime, time)
        sActive := false
        sEntry := na
        sStop  := na
        sTp    := na
        sSignalBar := na
    else if sActive and high >= sStop
        array.push(outcomeType, sBeReached ? 2 : 1)
        array.push(outcomeTime, time)
        sActive := false
        sEntry := na
        sStop  := na
        sTp    := na
        sSignalBar := na
    else if not na(sSignalBar) and (bar_index - sSignalBar) > maxBarsOpen
        array.push(outcomeType, sPending ? 3 : 4)
        array.push(outcomeTime, time)
        sPending := false
        sActive  := false
        sEntry := na
        sStop  := na
        sTp    := na
        sSignalBar := na
//}

// ═════════════════════════════ ЕДИНЫЙ АЛЕРТ ═════════════════════════════{
// if confirmLong and lPending 
//     longSignal := true
// if confirmShort and sPending
//     shortSignal := true

longSignal := confirmLong and lPending
shortSignal := confirmShort and sPending

if longSignal
    slTicks = math.round((close - lStop) / syminfo.mintick)
    tpTicks = math.round((lTp - close) / syminfo.mintick)
    alert("BUY | " + syminfo.ticker + " | " + timeframe.period +
         " | Entry: " + str.tostring(close, format.mintick) +
         " | SL: " + str.tostring(lStop, format.mintick) + " (-" + str.tostring(slTicks) + " ticks)" +
         " | TP: " + str.tostring(lTp, format.mintick) + " (+" + str.tostring(tpTicks) + " ticks)" +
         " | " + str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone),
         alert.freq_once_per_bar_close)

if shortSignal
    slTicks = math.round((sStop - close) / syminfo.mintick)
    tpTicks = math.round((close - sTp) / syminfo.mintick)
    alert("SELL | " + syminfo.ticker + " | " + timeframe.period +
         " | Entry: " + str.tostring(close, format.mintick) +
         " | SL: " + str.tostring(sStop, format.mintick) + " (-" + str.tostring(slTicks) + " ticks)" +
         " | TP: " + str.tostring(sTp, format.mintick) + " (+" + str.tostring(tpTicks) + " ticks)" +
         " | " + str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone),
         alert.freq_once_per_bar_close)

alertcondition(longSignal,"Buy signal")
alertcondition(shortSignal,"Sell signal")
//}

// ═════════════════════════════ ПАНЕЛЬ СТАТИСТИКИ ═════════════════════════════{
tableSize = statsSizeInput == "tiny" ? size.tiny : statsSizeInput == "small" ? size.small : statsSizeInput == "large" ? size.large : size.normal
tablePos  = statsPosInput == "Top Right" ? position.top_right : statsPosInput == "Bottom Right" ? position.bottom_right : statsPosInput == "Top Left" ? position.top_left : position.bottom_left

var table statTable = table.new(tablePos, 2, 8, border_width=1, border_color=color.new(color.gray, 40))

if showStatsPanel and barstate.islast
    // время, начиная с которого учитываем исходы, зависит от выбранного режима периода
    float filterFrom = statsPeriodMode == "Last N Days" ? time - statsDaysBack * 86400000 : statsPeriodMode == "From Fixed Date" ? statsStartDate : 0

    int tp  = 0
    int sl  = 0
    int be  = 0
    int cnc = 0
    int tmo = 0
    for idx = 0 to array.size(outcomeType) - 1
        if array.get(outcomeTime, idx) >= filterFrom
            typ = array.get(outcomeType, idx)
            if typ == 0
                tp += 1
            else if typ == 1
                sl += 1
            else if typ == 2
                be += 1
            else if typ == 3
                cnc += 1
            else if typ == 4
                tmo += 1

    int total = tp + sl + be
    float tpPct = total > 0 ? tp / total * 100 : 0.0
    float slPct = total > 0 ? sl / total * 100 : 0.0
    float bePct = total > 0 ? be / total * 100 : 0.0
    float wrPct = total > 0 ? (tp + be) / total * 100 : 0.0

    headerBg = color.new(color.navy, 0)
    labelBg  = color.new(color.gray, 80)

    periodLabel = statsPeriodMode == "Last N Days" ? str.tostring(statsDaysBack) + " days" : statsPeriodMode == "From Fixed Date" ? "from " + str.format_time(statsStartDate, "dd.MM.yyyy") : "all history"

    table.cell(statTable, 0, 0, "MA Retest — Statistics", text_color=color.white, bgcolor=headerBg, text_size=tableSize)
    table.cell(statTable, 1, 0, periodLabel, text_color=color.white, bgcolor=headerBg, text_size=tableSize)

    table.cell(statTable, 0, 1, "Total Trades", text_color=color.black, bgcolor=labelBg, text_size=tableSize)
    table.cell(statTable, 1, 1, str.tostring(total), text_color=color.black, bgcolor=labelBg, text_size=tableSize)

    table.cell(statTable, 0, 2, "Take Profit", text_color=color.white, bgcolor=tpColor, text_size=tableSize)
    table.cell(statTable, 1, 2, str.tostring(tp) + "  (" + str.tostring(tpPct, "#.#") + "%)", text_color=color.white, bgcolor=tpColor, text_size=tableSize)

    table.cell(statTable, 0, 3, "Breakeven", text_color=color.white, bgcolor=beColor, text_size=tableSize)
    table.cell(statTable, 1, 3, str.tostring(be) + "  (" + str.tostring(bePct, "#.#") + "%)", text_color=color.white, bgcolor=beColor, text_size=tableSize)

    table.cell(statTable, 0, 4, "Stop Loss", text_color=color.white, bgcolor=stopColor, text_size=tableSize)
    table.cell(statTable, 1, 4, str.tostring(sl) + "  (" + str.tostring(slPct, "#.#") + "%)", text_color=color.white, bgcolor=stopColor, text_size=tableSize)

    table.cell(statTable, 0, 5, "Winrate (TP+BE)", text_color=color.black, bgcolor=labelBg, text_size=tableSize)
    table.cell(statTable, 1, 5, str.tostring(wrPct, "#.#") + "%", text_color=color.black, bgcolor=labelBg, text_size=tableSize)

    table.cell(statTable, 0, 6, "Cancelled", text_color=color.black, bgcolor=color.new(color.gray, 85), text_size=tableSize)
    table.cell(statTable, 1, 6, str.tostring(cnc), text_color=color.black, bgcolor=color.new(color.gray, 85), text_size=tableSize)

    table.cell(statTable, 0, 7, "Timeout (in market)", text_color=color.black, bgcolor=color.new(color.gray, 85), text_size=tableSize)
    table.cell(statTable, 1, 7, str.tostring(tmo), text_color=color.black, bgcolor=color.new(color.gray, 85), text_size=tableSize)
//}

// ═════════════════════════════ СКАНЕР ДРУГИХ МОНЕТ ═════════════════════════════{
// Полностью повторяет логику сигнала/сетапа с основного графика, но выполняется
// через request.security() на выбранных символах. Использует те же параметры
// стратегии (ema1/ema2, окна поиска, метод SL, R и т.д.), что заданы в "Strategy".
f_scan() =>
    _pema1 = ta.ema(close, ema1)
    _pema2 = ta.ema(close, ema2)
    _atr   = ta.atr(atrLength)
    _longTrend   = _pema1 > _pema2
    _shortTrend  = _pema1 < _pema2
    _noTradeZone = close < math.max(_pema1, _pema2) and close > math.min(_pema1, _pema2)
    _ready = bar_index > (ema2 + swingLookback)

    bool _pierceBelow = false
    for i = 0 to pierceLookback - 1
        if low[i] <= _pema1[i]
            _pierceBelow := true
    bool _pierceAbove = false
    for i = 0 to pierceLookback - 1
        if high[i] >= _pema1[i]
            _pierceAbove := true

    _emaSpread = math.abs(_pema1 - _pema2)
    _atrSpreadOK = not useATRSpreadFilter or _emaSpread >= minSpreadATR * _atr
    _percentileSpreadValue = ta.percentile_nearest_rank(_emaSpread, percentileLookback, percentileThreshold)
    _percentileSpreadOK = not usePercentileFilter or _emaSpread >= _percentileSpreadValue
    _chopFilterOK = _atrSpreadOK and _percentileSpreadOK

    _rawConfirmLong  = _ready and _longTrend  and ta.crossover(close, _pema1)  and _pierceBelow and not _noTradeZone and _chopFilterOK
    _rawConfirmShort = _ready and _shortTrend and ta.crossunder(close, _pema1) and _pierceAbove and not _noTradeZone and _chopFilterOK

    var int _lastLongSignalBar  = na
    var int _lastShortSignalBar = na
    _cooldownOKLong  = not useCooldown or na(_lastShortSignalBar) or (bar_index - _lastShortSignalBar) > cooldownBars
    _cooldownOKShort = not useCooldown or na(_lastLongSignalBar)  or (bar_index - _lastLongSignalBar)  > cooldownBars

    _confirmLong  = _rawConfirmLong  and _cooldownOKLong
    _confirmShort = _rawConfirmShort and _cooldownOKShort

    if _confirmLong
        _lastLongSignalBar := bar_index
    if _confirmShort
        _lastShortSignalBar := bar_index

    var float _entry = na
    var float _stop  = na
    var float _tp    = na
    var int   _dir   = 0        // 1 = long, -1 = short, 0 = нет сетапа
    var bool  _pending = false
    var bool  _active  = false
    var int   _signalBar = na

    // взаимная отмена встречным сигналом
    if _confirmLong and _dir == -1 and (_pending or _active)
        _pending := false
        _active  := false
        _entry := na
        _stop  := na
        _tp    := na
        _dir   := 0
        _signalBar := na
    if _confirmShort and _dir == 1 and (_pending or _active)
        _pending := false
        _active  := false
        _entry := na
        _stop  := na
        _tp    := na
        _dir   := 0
        _signalBar := na

    if _confirmLong and not _pending and not _active
        float _entryCand = close
        float _swingStop = ta.lowest(low, swingLookback)
        float _atrStop   = _entryCand - _atr * atrMultiplier
        float _pctStop   = _entryCand * (1 - stopPercent / 100)
        float _stopCand  = slMode == "ATR" ? _atrStop : slMode == "Percent of Price" ? _pctStop : _swingStop
        float _minAllowed = _entryCand * (1 - maxRiskPercent / 100)
        _stopCand := math.max(_stopCand, _minAllowed)
        if slMode == "Swing (High/Low)" and capSwingByATR
            float _minAllowedByAtr = _entryCand - _atr * swingAtrCapMultiple
            _stopCand := math.max(_stopCand, _minAllowedByAtr)
        if _stopCand < _entryCand
            _entry := _entryCand
            _stop  := _stopCand
            _tp    := _entry + (_entry - _stop) * rrMultiple
            _dir   := 1
            _pending := true
            _signalBar := bar_index

    if _confirmShort and not _pending and not _active
        float _entryCand = close
        float _swingStop = ta.highest(high, swingLookback)
        float _atrStop   = _entryCand + _atr * atrMultiplier
        float _pctStop   = _entryCand * (1 + stopPercent / 100)
        float _stopCand  = slMode == "ATR" ? _atrStop : slMode == "Percent of Price" ? _pctStop : _swingStop
        float _maxAllowed = _entryCand * (1 + maxRiskPercent / 100)
        _stopCand := math.min(_stopCand, _maxAllowed)
        if slMode == "Swing (High/Low)" and capSwingByATR
            float _maxAllowedByAtr = _entryCand + _atr * swingAtrCapMultiple
            _stopCand := math.min(_stopCand, _maxAllowedByAtr)
        if _stopCand > _entryCand
            _entry := _entryCand
            _stop  := _stopCand
            _tp    := _entry - (_stop - _entry) * rrMultiple
            _dir   := -1
            _pending := true
            _signalBar := bar_index

    if (_pending or _active) and _dir == 1
        if _pending and bar_index > _signalBar and low <= _stop
            _pending := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na
        else if _pending and bar_index > _signalBar and high >= _entry
            _pending := false
            _active  := true
        else if _active and high >= _tp
            _active := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na
        else if _active and low <= _stop
            _active := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na
        else if not na(_signalBar) and (bar_index - _signalBar) > maxBarsOpen
            _pending := false
            _active  := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na
    else if (_pending or _active) and _dir == -1
        if _pending and bar_index > _signalBar and high >= _stop
            _pending := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na
        else if _pending and bar_index > _signalBar and low <= _entry
            _pending := false
            _active  := true
        else if _active and low <= _tp
            _active := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na
        else if _active and high >= _stop
            _active := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na
        else if not na(_signalBar) and (bar_index - _signalBar) > maxBarsOpen
            _pending := false
            _active  := false
            _entry := na
            _stop  := na
            _tp    := na
            _dir   := 0
            _signalBar := na

    // код статуса: 2 = LONG в рынке, 1 = LONG лимит, -1 = SHORT лимит, -2 = SHORT в рынке, 0 = нет сетапа
    int _statusCode = _active ? (_dir == 1 ? 2 : -2) : _pending ? (_dir == 1 ? 1 : -1) : 0
    [_statusCode, _entry, _stop, _tp]

scanTF = scanTFInput == "" ? timeframe.period : scanTFInput

[st1, e1, sl1, tp1] = request.security(scanSymbol1, scanTF, f_scan())
[st2, e2, sl2, tp2] = request.security(scanSymbol2, scanTF, f_scan())
[st3, e3, sl3, tp3] = request.security(scanSymbol3, scanTF, f_scan())
[st4, e4, sl4, tp4] = request.security(scanSymbol4, scanTF, f_scan())
[st5, e5, sl5, tp5] = request.security(scanSymbol5, scanTF, f_scan())

f_statusText(code) =>
    code == 2 ? "LONG (Active)" : code == 1 ? "LONG (Pending)" : code == -1 ? "SHORT (Pending)" : code == -2 ? "SHORT (Active)" : "—"

f_statusColor(code) =>
    code == 2 ? color.new(color.green, 15) : code == 1 ? color.new(color.green, 60) : code == -1 ? color.new(color.red, 60) : code == -2 ? color.new(color.red, 15) : color.new(color.gray, 85)

f_shortName(sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : sym

scanSize = scanSizeInput == "tiny" ? size.tiny : scanSizeInput == "small" ? size.small : scanSizeInput == "large" ? size.large : size.normal
scanPos  = scanPosInput == "Top Right" ? position.top_right : scanPosInput == "Bottom Right" ? position.bottom_right : scanPosInput == "Top Left" ? position.top_left : position.bottom_left

var table scanTable = table.new(scanPos, 4, 6, border_width=1, border_color=color.new(color.gray, 40))

if showScanner and barstate.islast
    headBg = color.new(color.navy, 0)
    table.cell(scanTable, 0, 0, "Symbol", text_color=color.white, bgcolor=headBg, text_size=scanSize)
    table.cell(scanTable, 1, 0, "Status", text_color=color.white, bgcolor=headBg, text_size=scanSize)
    table.cell(scanTable, 2, 0, "Entry / SL", text_color=color.white, bgcolor=headBg, text_size=scanSize)
    table.cell(scanTable, 3, 0, "TP", text_color=color.white, bgcolor=headBg, text_size=scanSize)

    // строка 1
    table.cell(scanTable, 0, 1, f_shortName(scanSymbol1), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 1, 1, f_statusText(st1), text_color=color.black, bgcolor=f_statusColor(st1), text_size=scanSize)
    table.cell(scanTable, 2, 1, st1 == 0 ? "—" : str.tostring(e1, format.mintick) + " / " + str.tostring(sl1, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 3, 1, st1 == 0 ? "—" : str.tostring(tp1, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)

    // строка 2
    table.cell(scanTable, 0, 2, f_shortName(scanSymbol2), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 1, 2, f_statusText(st2), text_color=color.black, bgcolor=f_statusColor(st2), text_size=scanSize)
    table.cell(scanTable, 2, 2, st2 == 0 ? "—" : str.tostring(e2, format.mintick) + " / " + str.tostring(sl2, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 3, 2, st2 == 0 ? "—" : str.tostring(tp2, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)

    // строка 3
    table.cell(scanTable, 0, 3, f_shortName(scanSymbol3), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 1, 3, f_statusText(st3), text_color=color.black, bgcolor=f_statusColor(st3), text_size=scanSize)
    table.cell(scanTable, 2, 3, st3 == 0 ? "—" : str.tostring(e3, format.mintick) + " / " + str.tostring(sl3, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 3, 3, st3 == 0 ? "—" : str.tostring(tp3, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)

    // строка 4
    table.cell(scanTable, 0, 4, f_shortName(scanSymbol4), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 1, 4, f_statusText(st4), text_color=color.black, bgcolor=f_statusColor(st4), text_size=scanSize)
    table.cell(scanTable, 2, 4, st4 == 0 ? "—" : str.tostring(e4, format.mintick) + " / " + str.tostring(sl4, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 3, 4, st4 == 0 ? "—" : str.tostring(tp4, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)

    // строка 5
    table.cell(scanTable, 0, 5, f_shortName(scanSymbol5), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 1, 5, f_statusText(st5), text_color=color.black, bgcolor=f_statusColor(st5), text_size=scanSize)
    table.cell(scanTable, 2, 5, st5 == 0 ? "—" : str.tostring(e5, format.mintick) + " / " + str.tostring(sl5, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
    table.cell(scanTable, 3, 5, st5 == 0 ? "—" : str.tostring(tp5, format.mintick), text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=scanSize)
//}
````
