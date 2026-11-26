# Simple Scalper PRO V1.1 (Alx_Sport_Tour)

- url: https://www.tradingview.com/script/PIJqWPZC-simple-scalper-pro-v1-1-alx-sport-tour/
- type: indicator
- pine_id: PUB;f5b7fae991b348138ca1e1fe9a909296
- version: 2.0

## Description

# Simple Scalper PRO

## 🇬🇧 ENGLISH

**Clear signals. Clean chart. Simple rules.**

Simple Scalper PRO is a practical intraday and scalping indicator designed for traders who want to quickly identify potential market entries and dynamic exits without filling the chart with unnecessary information.

The indicator combines **EMA 9/20/50/100/200** with **ATR-based volatility analysis** to create a simple, structured trading framework.

### 🚀 ENTRY SIGNALS

**LONG**
EMA 9 crosses EMA 50 upward.

**SHORT**
EMA 9 crosses EMA 50 downward.

Signals are displayed directly on the chart with clean **L** and **S** markers, making potential entry points easy to identify.

### 🛡️ ATR-BASED STOP LOSS

Stop Loss is calculated using:

**1.5 × ATR**

ATR timeframe, ATR period and Stop Loss multiplier are fully configurable in the indicator settings, allowing the tool to be adapted to different instruments and trading styles.

### 🎯 DYNAMIC EXIT

Simple Scalper PRO does **not** use fixed Take Profit targets.

Instead, exits are generated dynamically using the relationship between **EMA 9 and EMA 20**.

**LONG → EXIT**
EMA 9 crosses EMA 20 downward.

**SHORT → EXIT**
EMA 9 crosses EMA 20 upward.

This approach allows the exit signal to react to changing market conditions instead of relying on a predetermined price target.

### 📊 BUILT-IN DASHBOARD

The compact dashboard provides the most important information at a glance:

• Position
• Entry Price
• ATR
• ATR Timeframe
• ATR Period
• Exit Price
• Current Trend

No unnecessary TP levels or overloaded statistics — just the information needed for quick decision-making.

### ⚙️ FULLY CONFIGURABLE

The indicator gives you control over the main parameters:

• EMA 9 Period
• EMA 20 Period
• EMA 50 Period
• EMA 100 Period
• EMA 200 Period
• ATR Timeframe
• ATR Period
• Stop Loss × ATR

### 🔔 ALERTS

TradingView alerts are available for:

🟢 LONG
🔴 SHORT

The indicator intentionally keeps alerts focused on entry signals.

### 💡 DESIGNED FOR

Simple Scalper PRO can be useful for:

• Scalping
• Intraday trading
• Short-term trend following
• Fast market analysis
• Traders who prefer clean and uncomplicated charts

**Simple Scalper PRO focuses on one thing: keeping your trading view simple, structured and easy to read.**

Use it as part of your own trading strategy and always consider market conditions, risk management and confirmation from additional analysis.

*Simple Scalper PRO is a technical analysis tool and does not provide financial advice or guarantee trading results.*

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 🇷🇺 РУССКАЯ ВЕРСИЯ

**Чёткие сигналы. Чистый график. Простые правила.**

Simple Scalper PRO — практичный индикатор для **скальпинга и внутридневной торговли**, созданный для трейдеров, которым важно быстро видеть потенциальные точки входа и динамические выходы без перегруженного графика.

Индикатор объединяет **EMA 9/20/50/100/200** и анализ волатильности на основе **ATR**, создавая простую и понятную структуру для принятия торговых решений.

### 🚀 СИГНАЛЫ ВХОДА

**LONG**
EMA 9 пересекает EMA 50 снизу вверх.

**SHORT**
EMA 9 пересекает EMA 50 сверху вниз.

Сигналы отображаются непосредственно на графике в виде компактных меток **L** и **S**, благодаря чему потенциальные точки входа легко заметить даже при быстром движении рынка.

### 🛡️ STOP LOSS НА ОСНОВЕ ATR

Stop Loss рассчитывается по формуле:

**1.5 × ATR**

Таймфрейм ATR, период ATR и множитель Stop Loss полностью настраиваются в параметрах индикатора.

Это позволяет адаптировать расчёт под различные инструменты и торговые стили.

### 🎯 ДИНАМИЧЕСКИЙ ВЫХОД

Simple Scalper PRO **не использует фиксированный Take Profit**.

Вместо заранее заданных целей выход определяется динамически с помощью пересечения **EMA 9 и EMA 20**.

**LONG → EXIT**
EMA 9 пересекает EMA 20 сверху вниз.

**SHORT → EXIT**
EMA 9 пересекает EMA 20 снизу вверх.

Такой подход позволяет сигналу выхода реагировать на изменение рыночной динамики, а не зависеть от заранее установленной ценовой цели.

### 📊 ВСТРОЕННЫЙ DASHBOARD

Компактная информационная панель показывает всё самое необходимое:

• Position
• Entry Price
• ATR
• ATR Timeframe
• ATR Period
• Exit Price
• Current Trend

Без лишних уровней Take Profit и перегруженной статистики — только ключевая информация для быстрого анализа.

### ⚙️ ПОЛНАЯ НАСТРОЙКА

В параметрах индикатора можно настроить:

• EMA 9 Period
• EMA 20 Period
• EMA 50 Period
• EMA 100 Period
• EMA 200 Period
• ATR Timeframe
• ATR Period
• Stop Loss × ATR

### 🔔 ALERTS

Алерты TradingView доступны для:

🟢 LONG
🔴 SHORT

Алерты специально ограничены сигналами входа, чтобы не перегружать уведомления.

### 💡 ДЛЯ КОГО ПОДХОДИТ

Simple Scalper PRO может быть полезен для:

• Скальпинга
• Внутридневной торговли
• Краткосрочной торговли по тренду
• Быстрого анализа рынка
• Трейдеров, предпочитающих чистый и понятный график

**Simple Scalper PRO создан с одной главной идеей: сделать торговый график простым, структурированным и удобным для чтения.**

Используйте индикатор как часть собственной торговой системы и учитывайте рыночные условия, управление рисками и дополнительные подтверждения.

*Simple Scalper PRO является инструментом технического анализа, не является финансовой рекомендацией и не гарантирует прибыльность торговли.*

## Source Code

````pine
//@version=6
indicator("Simple Scalper PRO V2.1 (Alx_Sport_Tour)", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ema9Length = input.int(9, "Период EMA 9", minval=1)
ema20Length = input.int(20, "Период EMA 20", minval=1)
ema50Length = input.int(50, "Период EMA 50", minval=1)
ema100Length = input.int(100, "Период EMA 100", minval=1)
ema200Length = input.int(200, "Период EMA 200", minval=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrMode = input.string("Auto — Adaptive", "Режим таймфрейма ATR", options=["Auto — Adaptive", "Manual"])

atrManualTimeframe = input.timeframe("1", "Ручной таймфрейм ATR")

atrPeriod = input.int(30, "Период ATR", minval=1, step=1)

slATRMult = input.float(1.5, "Стоп-лосс × ATR", minval=0.1, step=0.1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// APPEARANCE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Entry line
entryLineColor = input.color(color.blue, "Цвет линии входа")
entryLineWidth = input.int(2, "Ширина линии входа", minval=1, maxval=5)

// Stop loss
stopLineColor = input.color(color.red, "Цвет линии стоп-лосса")
stopLineWidth = input.int(1, "Ширина линии стоп-лосса", minval=1, maxval=5)

// Signal colors
longColor = input.color(color.green, "Цвет лонг-сейва")
shortColor = input.color(color.red, "Цвет шорт-сейва")
exitColor = input.color(color.blue, "Цвет выхода")
signalTextColor = input.color(color.white, "Цвет текста сигнала")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tableBgColor = input.color(color.new(color.black, 15), "Фон таблицы")
tableLabelBgColor = input.color(color.new(color.gray, 70), "Background of Table Label")
tableTextColor = input.color(color.white, "Color of Table Text")
tableBorderColor = input.color(color.gray, "Color of Table Border")

// Trend colors
trendBullColor = input.color(color.green, "Trend Bullish Color")
trendBearColor = input.color(color.red, "Тренд медвежий")
trendNeutralColor = input.color(color.blue, "Тренд нейтральный")

// Position colors
positionLongColor = input.color(color.green, "Позиция ДЛИННАЯ")
positionShortColor = input.color(color.red, "Позиция КОРОТКАЯ")
positionFlatColor = input.color(color.gray, "Position FLAT Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enableLongAlert = input.bool(true, "Включить ДЛИТЕЛЬНОЕ оповещение")
enableShortAlert = input.bool(true, "Включить КОРОТКОЕ оповещение")
enableLongExitAlert = input.bool(true, "Включить ДЛИТЕЛЬНОЕ оповещение при выходе")
enableShortExitAlert = input.bool(true, "Включить КОРОТКОЕ оповещение при выходе")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR TIMEFRAME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrTimeframe = atrMode == "Auto — Adaptive" ? timeframe.period : atrManualTimeframe

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ema9 = ta.ema(close, ema9Length)
ema20 = ta.ema(close, ema20Length)
ema50 = ta.ema(close, ema50Length)
ema100 = ta.ema(close, ema100Length)
ema200 = ta.ema(close, ema200Length)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

impulseATR = request.security(syminfo.tickerid, atrTimeframe, ta.atr(atrPeriod), lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longSignal = ta.crossover(ema9, ema50)
shortSignal = ta.crossunder(ema9, ema50)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 1 = LONG
// -1 = SHORT
// 0 = FLAT

var float entry = na 
var float sl = na 
var float tradeATR = na 
var float exitPrice = na 
var int direction = 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXIT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longExitSignal = direction == 1 and ta.crossunder(ema9, ema20)
shortExitSignal = direction == -1 and ta.crossover(ema9, ema20)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAVE EXIT PRICE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if longExitSignal or shortExitSignal
    exitPrice := close
    direction := 0 
    entry := na
    sl := na 
    tradeATR := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONG ENTRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if longSignal and direction == 0
    entry := close 
    tradeATR := impulseATR
    sl := entry - tradeATR * slATRMult 
    direction := 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHORT ENTRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if shortSignal and direction == 0
    entry := close 
    tradeATR := impulseATR
    sl := entry + tradeATR * slATRMult 
    direction := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullish = ema9 > ema50
bearish = ema9 < ema50

trendText = "NEUTRAL"

if bullish 
    trendText := "BULLISH"

if bearish 
    trendText := "BEARISH"

trendColor = trendNeutralColor

if bullish
    trendColor := trendBullColor

if bearish
    trendColor := trendBearColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION TEXT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

positionText = "FLAT"

if direction == 1
    positionText := "LONG"

if direction == -1
    positionText := "SHORT"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

positionColor = positionFlatColor

if direction == 1
    positionColor := positionLongColor

if direction == -1
    positionColor := positionShortColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(ema9, title="EMA 9", color=color.aqua, linewidth=1)
plot(ema20, title="EMA 20", color=color.blue, linewidth=1)
plot(ema50, title="EMA 50", color=color.yellow, linewidth=1)
plot(ema100, title="EMA 100", color=color.orange, linewidth=1)
plot(ema200, title="EMA 200", color=color.red, linewidth=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA 9 / 50 FILL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

p9 = plot(ema9, title="EMA 9 Fill", display=display.none)
p50 = plot(ema50, title="EMA 50 Fill", display=display.none)

fillColor = color.new(color.gray, 97)

if bullish
    fillColor := color.new(color.green, 94)

if bearish
    fillColor := color.new(color.red, 94)

fill(p9, p50, color=fillColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONG MARKER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(longSignal, title="LONG", style=shape.labelup, location=location.belowbar, color=longColor, textcolor=signalTextColor, text="L", size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHORT MARKER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(shortSignal, title="SHORT", style=shape.labeldown, location=location.abovebar, color=shortColor, textcolor=signalTextColor, text="S", size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONG EXIT MARKER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(longExitSignal, title="LONG EXIT", style=shape.labeldown, location=location.abovebar, color=exitColor, textcolor=signalTextColor, text="EXIT", size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHORT EXIT MARKER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(shortExitSignal, title="SHORT EXIT", style=shape.labelup, location=location.belowbar, color=exitColor, textcolor=signalTextColor, text="EXIT", size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY LINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(direction != 0 ? entry : na, title="ENTRY", color=entryLineColor, linewidth=entryLineWidth, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOP LOSS LINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(direction != 0 ? sl : na, title="STOP LOSS", color=stopLineColor, linewidth=stopLineWidth, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 5 rows:
// 0 = Position
// 1 = ATR
// 2 = ATR Timeframe
// 3 = ATR Period
// 4 = Trend

var dashboard = table.new(position.top_right, 2, 5, border_width=1, border_color=tableBorderColor)

if barstate.islast
    table.set_border_color(dashboard, tableBorderColor)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // POSITION
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    table.cell(dashboard, 0, 0, "Position", bgcolor=tableLabelBgColor, text_color=tableTextColor)
    table.cell(dashboard, 1, 0, positionText, bgcolor=positionColor, text_color=tableTextColor)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ATR
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    atrText = "-"
    if not na(tradeATR)
        atrText := str.tostring(tradeATR, format.mintick)

    table.cell(dashboard, 0, 1, "ATR", bgcolor=tableLabelBgColor, text_color=tableTextColor)
    table.cell(dashboard, 1, 1, atrText, bgcolor=tableBgColor, text_color=tableTextColor)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ATR TIMEFRAME
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    table.cell(dashboard, 0, 2, "ATR Timeframe", bgcolor=tableLabelBgColor, text_color=tableTextColor)
    table.cell(dashboard, 1, 2, atrTimeframe, bgcolor=tableBgColor, text_color=tableTextColor)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ATR PERIOD
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    table.cell(dashboard, 0, 3, "ATR Period", bgcolor=tableLabelBgColor, text_color=tableTextColor)
    table.cell(dashboard, 1, 3, str.tostring(atrPeriod), bgcolor=tableBgColor, text_color=tableTextColor)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // TREND
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    table.cell(dashboard, 0, 4, "Trend", bgcolor=tableLabelBgColor, text_color=tableTextColor)
    table.cell(dashboard, 1, 4, trendText, bgcolor=trendColor, text_color=tableTextColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INSTANT ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// IMPORTANT:
//
// TradingView Alert:
// Condition
// → Simple Scalper PRO
// → Any alert() function call
//
// Alerts are intentionally NOT restricted
// by barstate.isconfirmed.
//
// So the alert fires immediately
// when the corresponding signal appears.
//
// Frequency:
// alert.freq_once_per_bar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONG ALERT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if enableLongAlert and longSignal
    alert("LONG | " + syminfo.ticker + " | EMA 9 crossed EMA 50 upwards | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHORT ALERT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if enableShortAlert and shortSignal
    alert("SHORT | " + syminfo.ticker + " | EMA 9 crossed EMA 50 downwards | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONG EXIT ALERT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if enableLongExitAlert and longExitSignal
    alert("EXIT LONG | " + syminfo.ticker + " | EMA 9 crossed EMA 20 downwards | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHORT EXIT ALERT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if enableShortExitAlert and shortExitSignal
    alert("EXIT SHORT | " + syminfo.ticker + " | EMA 9 crossed EMA 20 upwards | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
````
