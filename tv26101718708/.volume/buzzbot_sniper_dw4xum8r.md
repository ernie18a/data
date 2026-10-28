# BUZZBOT SNIPER

- url: https://www.tradingview.com/script/dW4xum8R-BUZZBOT-SNIPER/
- type: indicator
- pine_id: PUB;913428f3b6414425b3471fd0f2a0b765
- version: 1.0

## Description

# BUZZBOT SNIPER — Quick Brief

## What it is
A multi-confluence entry/exit system built on EMA crosses with volume confirmation, dressed up with a full bias dashboard and 5 take-profit levels. Designed to be visual, decisive, and idiot-proof — see the signal, see the levels, take the trade.

## How signals fire
The trigger is dead simple under the hood:
- **BUY** → 9 EMA crosses above 21 EMA **AND** current candle volume ≥ 2x prior candle's volume
- **SELL** → 9 EMA crosses below 21 EMA **AND** current candle volume ≥ 2x prior candle's volume
- No volume spike = no signal. The 2x filter is what cuts the chop and keeps you out of fake crosses.

When a signal fires, the indicator auto-plots:
- **Entry** at the close of the signal candle
- **Stop Loss** at 1.5x ATR(14) away (configurable)
- **5 take-profits** at 1R, 2R, 3R, 4R, 5R — each TP turns turquoise + gets a 🔥 when price hits it

## The Dashboard (top right by default)
8 rows of read-at-a-glance intel:

| Row | What it tells you |
|-----|------|
| **BIAS** | The headline call — STRONG BULL / MILD BEAR / etc., based on a 7-factor confluence score |
| **BULL / BEAR** | Score split as a % (each factor confirms = +1/7) |
| **TREND** | EMA + VWAP combined → 🟢 UP / 🔴 DOWN / ⚪ MIXED |
| **MOMENTUM** | RSI translated → OVERBOUGHT / OVERSOLD / BULLISH / BEARISH |
| **STRENGTH** | ADX → STRONG (>25) or WEAK |
| **VOLUME** | Live multiple vs. prior candle (✅ 2.4x means the filter passed) |
| **SIGNAL** | What's happening NOW → 🚨 BUY / 🚨 SELL / IN LONG / IN SHORT / WAITING |

The 7-factor confluence score behind BULL/BEAR checks: price vs VWAP, RSI direction, MACD, EMA cross, ADX + price vs EMA9, volume + candle direction, and 5m RSI. So the BIAS row isn't pulling one number — it's a vote across 7 signals.

## What's on the chart
- **EMA 9 / EMA 21 ribbon** — green when bullish, red when bearish, fills between them so the trend is obvious at a glance
- **VWAP** plotted as a 2-width line, color shifts based on whether price is above or below
- **BUY/SELL labels** on the signal bar, signal candle turns black
- **Retest candles** turn orange — when price pulls back to the 9 EMA after a signal (potential second-chance entry zone)
- **Live entry/SL/TP lines** extend right, labels float to the right of price action

## Alerts
Three alert conditions baked in:
- `BUY Signal (Vol Confirmed)`
- `SELL Signal (Vol Confirmed)`
- `Any Signal (Vol Confirmed)`

Right-click chart → Add Alert → pick condition → set "Once Per Bar Close" so you don't get fakeouts.

## Customization
Everything is wired to inputs:
- **Risk** → SL ATR multiplier, volume multiplier (default 2.0x), volume filter on/off toggle
- **Visuals** → font sizes, ribbon opacity, label offset, dashboard position (any of 6 corners)
- **Colors** → 4 groups, 25+ pickers covering dashboard, EMAs, VWAP, signals, every TP/SL line, and status colors

## Best timeframes
EMA 9/21 + 2x volume is built for intraday — 1m, 5m, 15m on futures (ES, NQ, MNQ, MES) is the sweet spot. The 5m RSI confluence in the score makes it timeframe-aware. On daily/weekly the volume filter still works but signals will be rare.

## What it's NOT
Not a system that takes every cross. The 2x volume gate is doing real work — most EMA crosses on a chop day will get filtered out, which is the whole point. Patience pays.

*Educational purposes only — not financial advice.*

## Source Code

````pine
//@version=6
// © KhanSaab - 2026. All rights reserved.
// Modified: Volume-confirmed signals (2x prior candle volume required)
indicator("BUZZBOT SNIPER", overlay=true, max_labels_count=500, max_boxes_count=500, max_bars_back=1000)

// --- INPUTS ---
groupVis         = "Visuals & UI"
dashTextSize     = input.string("normal", "Dashboard Font Size", options=["tiny", "small", "normal", "large", "huge"], group=groupVis)
tradeTextSize    = input.string("small", "Trade Label Size", options=["tiny", "small", "normal", "large", "huge"], group=groupVis)
ribbonOpacity    = input.int(75, "EMA Ribbon Opacity", minval=0, maxval=100, group=groupVis)
labelOffset      = input.int(12, "Label Right Offset (Bars)", minval=1, group=groupVis)
dashPosition     = input.string("top_right", "Dashboard Position", options=["top_right", "top_left", "middle_right", "middle_left", "bottom_right", "bottom_left"], group=groupVis)

groupRisk        = "Risk Management"
atrMultiplier    = input.float(1.5, "SL ATR Multiplier", minval=0.1, step=0.1, group=groupRisk)

groupVol         = "Volume Filter"
volMultiplier    = input.float(2.0, "Volume Multiplier vs Prior Candle", minval=1.0, step=0.1, group=groupVol, tooltip="Current candle volume must be this many times the prior candle's volume to trigger a signal.")
useVolFilter     = input.bool(true, "Require Volume Confirmation", group=groupVol)

// --- DASHBOARD COLORS ---
groupDashColor   = "Dashboard Colors"
c_dashHeader     = input.color(#6A0DAD, "Header Color",       group=groupDashColor)
c_dashLabel      = input.color(#4B0082, "Label Column Color", group=groupDashColor)
c_dashBg         = input.color(#1A0033, "Background Color",   group=groupDashColor)
c_dashBorder     = input.color(#9B59B6, "Border Color",       group=groupDashColor)
c_dashHeaderTxt  = input.color(color.white, "Header Text",    group=groupDashColor)
c_dashLabelTxt   = input.color(color.white, "Label Text",     group=groupDashColor)

// --- INDICATOR COLORS ---
groupIndColor    = "Indicator Colors"
c_ema9           = input.color(color.green, "EMA 9 Color",  group=groupIndColor)
c_ema21          = input.color(color.red,   "EMA 21 Color", group=groupIndColor)
c_vwapUp         = input.color(color.green, "VWAP (Above)", group=groupIndColor)
c_vwapDn         = input.color(color.red,   "VWAP (Below)", group=groupIndColor)
c_buySignal      = input.color(color.green, "BUY Label",    group=groupIndColor)
c_sellSignal     = input.color(color.red,   "SELL Label",   group=groupIndColor)
c_retest         = input.color(color.orange,"Retest Candle",group=groupIndColor)

// --- TP / SL COLORS ---
groupTpColor     = "TP & SL Colors"
c_entry          = input.color(color.blue,            "Entry Line",     group=groupTpColor)
c_sl             = input.color(color.red,             "Stop Loss Line", group=groupTpColor)
c_tp1            = input.color(color.green,           "TP1 Line",       group=groupTpColor)
c_tp2            = input.color(color.green,           "TP2 Line",       group=groupTpColor)
c_tp3            = input.color(color.green,           "TP3 Line",       group=groupTpColor)
c_tp4            = input.color(color.rgb(0, 100, 0),  "TP4 Line",       group=groupTpColor)
c_tp5            = input.color(color.rgb(0, 70, 0),   "TP5 Line",       group=groupTpColor)
c_tpHit          = input.color(#40E0D0,               "TP Hit Color",   group=groupTpColor, tooltip="Color a TP line turns when price reaches it.")

// --- STATUS COLORS ---
groupStatusColor = "Status Colors"
c_bullish        = input.color(color.lime,   "Bullish / Confirmed", group=groupStatusColor)
c_bearish        = input.color(color.red,    "Bearish",             group=groupStatusColor)
c_neutral        = input.color(color.gray,   "Neutral / Weak",      group=groupStatusColor)
c_warning        = input.color(color.orange, "Warning (OB/OS)",     group=groupStatusColor)

// --- POSITION HELPER ---
dashPos = dashPosition == "top_right" ? position.top_right : dashPosition == "top_left" ? position.top_left : dashPosition == "middle_right" ? position.middle_right : dashPosition == "middle_left" ? position.middle_left : dashPosition == "bottom_right" ? position.bottom_right : position.bottom_left

// --- GLOBAL INDICATORS ---
ema9    = ta.ema(close, 9)
ema21   = ta.ema(close, 21)
vwapV   = ta.vwap(hlc3)
atr     = ta.atr(14)
rsiVal  = ta.rsi(close, 14)
rsi5m   = request.security(syminfo.tickerid, "5", ta.rsi(close, 14))
[m, s, _] = ta.macd(close, 12, 26, 9)
[_, _, adx] = ta.dmi(14, 14)
volAvg  = ta.sma(volume, 20)

// --- VOLUME CONFIRMATION ---
volConfirmed = volume >= (volume[1] * volMultiplier)
volPassed    = useVolFilter ? volConfirmed : true

// --- DUAL SCORE LOGIC ---
float bScore = 0
bScore += (close > vwapV ? 1 : 0), bScore += (rsiVal > 50 ? 1 : 0), bScore += (m > s ? 1 : 0)
bScore += (ema9 > ema21 ? 1 : 0), bScore += (adx > 25 and close > ema9 ? 1 : 0)
bScore += (volume > volAvg and close > open ? 1 : 0), bScore += (rsi5m > 50 ? 1 : 0)
float bullPct = (bScore / 7) * 100

float rScore = 0
rScore += (close < vwapV ? 1 : 0), rScore += (rsiVal < 50 ? 1 : 0), rScore += (m < s ? 1 : 0)
rScore += (ema9 < ema21 ? 1 : 0), rScore += (adx > 25 and close < ema9 ? 1 : 0)
rScore += (volume > volAvg and close < open ? 1 : 0), rScore += (rsi5m < 50 ? 1 : 0)
float bearPct = (rScore / 7) * 100

// --- BIAS LOGIC ---
string biasText = (bullPct - bearPct) >= 40 ? "STRONG BULL" : (bearPct - bullPct) >= 40 ? "STRONG BEAR" : bullPct > bearPct ? "MILD BULL" : "MILD BEAR"
color biasCol = biasText == "STRONG BULL" ? c_bullish : biasText == "STRONG BEAR" ? c_bearish : c_neutral

// --- SIGNAL LOGIC & TRADE SETUP ---
var int lastSignalState = 0 
var float entryP = 0.0, var float slP = 0.0, var float t1 = 0.0, var float t2 = 0.0, var float t3 = 0.0, var float t4 = 0.0, var float t5 = 0.0
var bool t1Hit = false, var bool t2Hit = false, var bool t3Hit = false, var bool t4Hit = false, var bool t5Hit = false

buyCond  = ta.crossover(ema9, ema21)
sellCond = ta.crossunder(ema9, ema21)

triggerBuy  = buyCond  and lastSignalState <= 0 and volPassed
triggerSell = sellCond and lastSignalState >= 0 and volPassed

if triggerBuy or triggerSell
    lastSignalState := triggerBuy ? 1 : -1
    entryP := close
    float risk = atr * atrMultiplier
    slP := triggerBuy ? entryP - risk : entryP + risk
    t1  := triggerBuy ? entryP + risk : entryP - risk
    t2  := triggerBuy ? entryP + (risk * 2) : entryP - (risk * 2)
    t3  := triggerBuy ? entryP + (risk * 3) : entryP - (risk * 3)
    t4  := triggerBuy ? entryP + (risk * 4) : entryP - (risk * 4)
    t5  := triggerBuy ? entryP + (risk * 5) : entryP - (risk * 5)
    t1Hit := false, t2Hit := false, t3Hit := false, t4Hit := false, t5Hit := false

// --- TARGET HIT DETECTION ---
if lastSignalState == 1
    if high >= t1 
        t1Hit := true
    if high >= t2 
        t2Hit := true
    if high >= t3 
        t3Hit := true
    if high >= t4 
        t4Hit := true
    if high >= t5 
        t5Hit := true
if lastSignalState == -1
    if low <= t1 
        t1Hit := true
    if low <= t2 
        t2Hit := true
    if low <= t3 
        t3Hit := true
    if low <= t4 
        t4Hit := true
    if low <= t5 
        t5Hit := true

// --- DASHBOARD ---
var table d = table.new(dashPos, 2, 9, bgcolor=c_dashBg, border_width=1, border_color=c_dashBorder, frame_color=c_dashBorder, frame_width=2)

if barstate.islast
    // Header
    table.cell(d, 0, 0, "⚡ TheBullishBuzz Sniper ⚡", text_color=c_dashHeaderTxt, bgcolor=c_dashHeader, text_size=dashTextSize)
    table.merge_cells(d, 0, 0, 1, 0)
    
    // Bias
    table.cell(d, 0, 1, "BIAS",     text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 1, biasText,   text_color=color.white,    bgcolor=biasCol,     text_size=dashTextSize, text_halign=text.align_right)
    
    // Bull vs Bear
    table.cell(d, 0, 2, "BULL",     text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 2, str.tostring(bullPct, "#") + "%", text_color=bullPct > bearPct ? c_bullish : c_neutral, bgcolor=c_dashBg, text_size=dashTextSize, text_halign=text.align_right)
    
    table.cell(d, 0, 3, "BEAR",     text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 3, str.tostring(bearPct, "#") + "%", text_color=bearPct > bullPct ? c_bearish : c_neutral, bgcolor=c_dashBg, text_size=dashTextSize, text_halign=text.align_right)
    
    // Trend
    bool trendUp = ema9 > ema21 and close > vwapV
    bool trendDn = ema9 < ema21 and close < vwapV
    string trendStr = trendUp ? "🟢 UP" : trendDn ? "🔴 DOWN" : "⚪ MIXED"
    color trendCol = trendUp ? c_bullish : trendDn ? c_bearish : c_neutral
    table.cell(d, 0, 4, "TREND",    text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 4, trendStr,   text_color=trendCol,       bgcolor=c_dashBg,    text_size=dashTextSize, text_halign=text.align_right)
    
    // Momentum
    string rsiStr = rsiVal > 70 ? "OVERBOUGHT" : rsiVal < 30 ? "OVERSOLD" : rsiVal > 50 ? "BULLISH" : "BEARISH"
    color rsiCol = rsiVal > 70 ? c_warning : rsiVal < 30 ? c_warning : rsiVal > 50 ? c_bullish : c_bearish
    table.cell(d, 0, 5, "MOMENTUM", text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 5, rsiStr + " " + str.tostring(rsiVal, "#"), text_color=rsiCol, bgcolor=c_dashBg, text_size=dashTextSize, text_halign=text.align_right)
    
    // Strength
    string adxStr = adx > 25 ? "STRONG" : "WEAK"
    color adxCol = adx > 25 ? c_bullish : c_neutral
    table.cell(d, 0, 6, "STRENGTH", text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 6, adxStr + " " + str.tostring(adx, "#"), text_color=adxCol, bgcolor=c_dashBg, text_size=dashTextSize, text_halign=text.align_right)
    
    // Volume
    float volRatio = volume / nz(volume[1], 1)
    string volStr = volConfirmed ? "✅ " + str.tostring(volRatio, "#.#") + "x" : "❌ " + str.tostring(volRatio, "#.#") + "x"
    color volColor = volConfirmed ? c_bullish : c_neutral
    table.cell(d, 0, 7, "VOLUME",   text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 7, volStr,     text_color=volColor,       bgcolor=c_dashBg,    text_size=dashTextSize, text_halign=text.align_right)
    
    // Signal
    string sigStr = triggerBuy ? "🚨 BUY" : triggerSell ? "🚨 SELL" : lastSignalState == 1 ? "IN LONG" : lastSignalState == -1 ? "IN SHORT" : "WAITING"
    color sigCol = triggerBuy ? c_bullish : triggerSell ? c_bearish : lastSignalState == 1 ? c_buySignal : lastSignalState == -1 ? c_sellSignal : c_neutral
    table.cell(d, 0, 8, "SIGNAL",   text_color=c_dashLabelTxt, bgcolor=c_dashLabel, text_size=dashTextSize, text_halign=text.align_left)
    table.cell(d, 1, 8, sigStr,     text_color=color.white,    bgcolor=sigCol,      text_size=dashTextSize, text_halign=text.align_right)

// --- VISUALS: RIBBON & PLOTS ---
p9 = plot(ema9, color=color.new(c_ema9, 20), title="EMA 9")
p21 = plot(ema21, color=color.new(c_ema21, 20), title="EMA 21")
fill(p9, p21, color = ema9 > ema21 ? color.new(c_ema9, 100 - ribbonOpacity) : color.new(c_ema21, 100 - ribbonOpacity))

// --- CANDLE COLORS ---
isRetest = (lastSignalState == 1 and low <= ema9 and low > ema21) or (lastSignalState == -1 and high >= ema9 and high < ema21)
barcolor((triggerBuy or triggerSell) ? color.black : isRetest ? c_retest : na)
plotshape(triggerBuy, text="BUY", style=shape.labelup, location=location.belowbar, color=c_buySignal, textcolor=color.white, size=size.small)
plotshape(triggerSell, text="SELL", style=shape.labeldown, location=location.abovebar, color=c_sellSignal, textcolor=color.white, size=size.small)

// --- TP LINES & LABELS ---
var line lE = na, var line lSL = na, var line lT1 = na, var line lT2 = na, var line lT3 = na, var line lT4 = na, var line lT5 = na
var label lbE = label.new(na, na, "", color=c_entry, textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT1 = label.new(na, na, "", color=c_tp1, textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT2 = label.new(na, na, "", color=c_tp2, textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT3 = label.new(na, na, "", color=c_tp3, textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT4 = label.new(na, na, "", color=c_tp4, textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT5 = label.new(na, na, "", color=c_tp5, textcolor=color.white, style=label.style_label_left, size=tradeTextSize)

if triggerBuy or triggerSell
    line.delete(lE), line.delete(lSL), line.delete(lT1), line.delete(lT2), line.delete(lT3), line.delete(lT4), line.delete(lT5)
    lE  := line.new(bar_index, entryP, bar_index + 20, entryP, color=c_entry, width=2, extend=extend.right)
    lSL := line.new(bar_index, slP,    bar_index + 20, slP,    color=c_sl,    width=2, extend=extend.right)
    lT1 := line.new(bar_index, t1,     bar_index + 20, t1,     color=c_tp1,   style=line.style_dashed, extend=extend.right)
    lT2 := line.new(bar_index, t2,     bar_index + 20, t2,     color=c_tp2,   style=line.style_dashed, extend=extend.right)
    lT3 := line.new(bar_index, t3,     bar_index + 20, t3,     color=c_tp3,   style=line.style_dashed, extend=extend.right)
    lT4 := line.new(bar_index, t4,     bar_index + 20, t4,     color=c_tp4,   width=2, extend=extend.right)
    lT5 := line.new(bar_index, t5,     bar_index + 20, t5,     color=c_tp5,   width=3, extend=extend.right)
    
    label.set_color(lbE, c_entry)
    label.set_color(lbT1, c_tp1)
    label.set_color(lbT2, c_tp2)
    label.set_color(lbT3, c_tp3)
    label.set_color(lbT4, c_tp4)
    label.set_color(lbT5, c_tp5)

if lastSignalState != 0
    int tX = bar_index + labelOffset
    line.set_color(lT1, t1Hit ? c_tpHit : c_tp1)
    line.set_color(lT2, t2Hit ? c_tpHit : c_tp2)
    line.set_color(lT3, t3Hit ? c_tpHit : c_tp3)
    line.set_color(lT4, t4Hit ? c_tpHit : c_tp4)
    line.set_color(lT5, t5Hit ? c_tpHit : c_tp5)
    
    label.set_xy(lbE, tX, entryP), label.set_text(lbE, "ENTRY: " + str.tostring(entryP, "#.##"))
    label.set_xy(lbT1, tX, t1), label.set_text(lbT1, "TP1: " + str.tostring(t1, "#.##") + (t1Hit ? " 🔥" : ""))
    label.set_xy(lbT2, tX, t2), label.set_text(lbT2, "TP2: " + str.tostring(t2, "#.##") + (t2Hit ? " 🔥" : ""))
    label.set_xy(lbT3, tX, t3), label.set_text(lbT3, "TP3: " + str.tostring(t3, "#.##") + (t3Hit ? " 🔥" : ""))
    label.set_xy(lbT4, tX, t4), label.set_text(lbT4, "TP4: " + str.tostring(t4, "#.##") + (t4Hit ? " 🔥" : ""))
    label.set_xy(lbT5, tX, t5), label.set_text(lbT5, "TP5: " + str.tostring(t5, "#.##") + (t5Hit ? " 🔥" : ""))

plot(vwapV, color=close > vwapV ? c_vwapUp : c_vwapDn, linewidth=2, title="VWAP")

// --- ALERTS ---
alertcondition(triggerBuy,  title="BUY Signal (Vol Confirmed)",  message="🚨 BUY SIGNAL — {{ticker}} @ {{close}} | 2x Volume Confirmed")
alertcondition(triggerSell, title="SELL Signal (Vol Confirmed)", message="🚨 SELL SIGNAL — {{ticker}} @ {{close}} | 2x Volume Confirmed")
alertcondition(triggerBuy or triggerSell, title="Any Signal (Vol Confirmed)", message="🚨 SNIPER ENTRY — {{ticker}} @ {{close}} | 2x Volume Confirmed")
````
