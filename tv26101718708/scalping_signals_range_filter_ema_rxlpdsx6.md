# Scalping Signals (Range Filter + EMA)

- url: https://www.tradingview.com/script/RxlPDSX6-Scalping-Signals-Range-Filter-EMA/
- type: indicator
- pine_id: PUB;887db0d5124743d1835f39415e87aa28
- version: 3.0

## Description

Scalping Signals Range Filter + EMA Gate Indicator — Confirmed Signals

The Indicator is a trend-following and momentum confirmation tool designed to identify high-probability BUY and SELL opportunities while filtering out market noise and low-quality signals.

This indicator combines a dynamic Range Filter system with EMA trend alignment, optional Bollinger filtering, and non-repainting confirmed candle logic to create cleaner market entries.

Core Concepts
1. Range Filter Engine

At the heart of the indicator is a smoothed Range Filter that adapts to market volatility.
The filter acts as a dynamic trend baseline:

Price above the filter → bullish pressure
Price below the filter → bearish pressure

The filter continuously adjusts based on recent market movement, helping reduce false signals during choppy conditions.

2. EMA Gate System

The indicator uses a dual EMA gate mechanism:

Fast EMA (default: 50)
Slow EMA (default: 150)

Signals are only allowed in the direction of the active EMA gate:

50 EMA above 150 EMA → long signals only
50 EMA below 150 EMA → short signals only

This prevents counter-trend trades and helps align entries with the dominant market structure.

3. Optional EMA 200 Trend Filter

An additional higher-timeframe style trend filter can be enabled using the EMA 200.

When enabled:

BUY signals require price above EMA 200
SELL signals require price below EMA 200

This helps avoid trading against the broader trend.

4. Optional Bollinger Filter

The Bollinger filter can be enabled to further validate momentum:

Longs allowed only above Bollinger basis
Shorts allowed only below Bollinger basis

This can help remove weak signals during sideways conditions.

5. Confirmed Non-Repainting Signals

The indicator uses confirmed candle logic:

Signals only appear after candle close
No future candle references
No lookahead logic
No repainting on closed candles

This makes the signals more reliable for live trading and alerts.

Features
Adaptive Range Filter
EMA Gate Direction System
Optional EMA 200 Trend Filter
Optional Bollinger Confirmation Filter
BUY/SELL Signal Labels
Confirmed Candle Signals
Non-Repainting Logic
Heikin-Ashi Source Support
Alert Conditions Included
Debug Visualization Mode
Recommended Usage

This indicator works best in trending environments and can be used for:

Trend-following strategies
Pullback entries
Momentum continuation trades
Scalping
Intraday trading
Swing trading

Popular timeframes:

1m
5m
15m
1H
Alerts

Included alert conditions:

BUY Signal Confirmed
SELL Signal Confirmed
EMA Gate Bullish Confirmed
EMA Gate Bearish Confirmed

For best results, use TradingView alerts with:
“Once Per Bar Close”

Notes

This indicator is designed as a signal and confirmation tool, not a complete trading system. Proper risk management, stop-loss placement, and market context analysis are still required.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Range Filter + EMA Gate Indicator — Confirmed Signals", 
     shorttitle="RF + EMA Confirmed", 
     overlay=true,
     max_labels_count=500)

//────────────────────────────────────────────────────────────────────
// Colors
//────────────────────────────────────────────────────────────────────
color BULL_COLOR    = #089981
color BEAR_COLOR    = #f23645
color NEUTRAL_COLOR = #5b9cf6

//────────────────────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────────────────────
srcChoice = input.string("Close", "Source", options=["Close","Open","High","Low","HL2","HLC3","OHLC4"], group="Source Settings")
useHA     = input.bool(false, "Use Heikin-Ashi Candles", group="Source Settings")

per  = input.int(50, "Sampling Period", minval=1, group="Range Filter")
mult = input.float(3.0, "Range Multiplier", minval=0.1, step=0.1, group="Range Filter")

ema50Len   = input.int(50, "Fast EMA Gate", group="EMA Filters")
ema150Len  = input.int(150, "Slow EMA Gate", group="EMA Filters")
useTrend   = input.bool(true, "Use EMA 200 Trend Filter", group="EMA Filters")
ema200Len  = input.int(200, "EMA 200 Length", group="EMA Filters")

useBBFilter = input.bool(false, "Enable Bollinger Filter?", group="Bollinger Filter")
bbLength    = input.int(20, "Bollinger Length", group="Bollinger Filter")
bbMult      = input.float(2.0, "Bollinger Multiplier", group="Bollinger Filter")

maxSignals = input.int(2, "Max Signals per EMA Gate", minval=1, group="Signal Rules")

showEMAs        = input.bool(true, "Show EMAs", group="Visuals")
showEMARibbon   = input.bool(true, "Show EMA Ribbon", group="Visuals")
showGateBg      = input.bool(false, "Show EMA Gate Background", group="Visuals")
colorBars       = input.bool(false, "Color Bars by Range Direction", group="Visuals")
showStatusPanel = input.bool(true, "Show Status Panel", group="Visuals")
showDebug       = input.bool(false, "Show Debug Markers", group="Visuals")

//────────────────────────────────────────────────────────────────────
// Heikin-Ashi Source
//────────────────────────────────────────────────────────────────────
ha_close = (open + high + low + close) / 4.0

var float ha_open = na
ha_open := na(ha_open[1]) ? (open + close) / 2.0 : (ha_open[1] + ha_close[1]) / 2.0

ha_high = math.max(high, math.max(ha_open, ha_close))
ha_low  = math.min(low, math.min(ha_open, ha_close))

src_ha = switch srcChoice
    "Close" => ha_close
    "Open"  => ha_open
    "High"  => ha_high
    "Low"   => ha_low
    "HL2"   => (ha_high + ha_low) / 2.0
    "HLC3"  => (ha_high + ha_low + ha_close) / 3.0
    "OHLC4" => (ha_open + ha_high + ha_low + ha_close) / 4.0

src_raw = switch srcChoice
    "Close" => close
    "Open"  => open
    "High"  => high
    "Low"   => low
    "HL2"   => hl2
    "HLC3"  => hlc3
    "OHLC4" => ohlc4

src = useHA ? src_ha : src_raw

//────────────────────────────────────────────────────────────────────
// Range Filter
//────────────────────────────────────────────────────────────────────
smoothrng(src_, t, m) =>
    wper = (t * 2) - 1
    avrng = ta.ema(math.abs(src_ - src_[1]), t)
    ta.ema(avrng, wper) * m

smrng = smoothrng(src, per, mult)

rngfilt(x, r) =>
    var float rf = na
    rf := na(rf[1]) ? x : x > rf[1] ? math.max(rf[1], x - r) : math.min(rf[1], x + r)
    rf

filt = rngfilt(src, smrng)

var int upcount = 0
var int downcount = 0

upcount := filt > filt[1] ? nz(upcount[1]) + 1 : filt < filt[1] ? 0 : nz(upcount[1])
downcount := filt < filt[1] ? nz(downcount[1]) + 1 : filt > filt[1] ? 0 : nz(downcount[1])

longCond  = src > filt and upcount > 0
shortCond = src < filt and downcount > 0

var int CondIni = 0
CondIni := longCond ? 1 : shortCond ? -1 : nz(CondIni[1])

//────────────────────────────────────────────────────────────────────
// EMA Filters
//────────────────────────────────────────────────────────────────────
ema50  = ta.ema(src, ema50Len)
ema150 = ta.ema(src, ema150Len)
ema200 = ta.ema(src, ema200Len)

trendLong  = not useTrend or src > ema200
trendShort = not useTrend or src < ema200

crossUp = ta.crossover(ema50, ema150)
crossDn = ta.crossunder(ema50, ema150)

// EMA gate direction
var int gate_dir = na
var int signals_taken = 0

if na(gate_dir)
    gate_dir := ema50 > ema150 ? 1 : -1

if crossUp
    gate_dir := 1
    signals_taken := 0

if crossDn
    gate_dir := -1
    signals_taken := 0

allowLongByGate  = gate_dir == 1
allowShortByGate = gate_dir == -1

//────────────────────────────────────────────────────────────────────
// Bollinger Filter
//────────────────────────────────────────────────────────────────────
basis = ta.sma(src, bbLength)
dev   = bbMult * ta.stdev(src, bbLength)

bbLongFilter  = not useBBFilter or src > basis
bbShortFilter = not useBBFilter or src < basis

//────────────────────────────────────────────────────────────────────
// Signal Logic — confirmed candle only
//────────────────────────────────────────────────────────────────────
longEntrySignal  = longCond and CondIni[1] != 1 and trendLong and bbLongFilter
shortEntrySignal = shortCond and CondIni[1] != -1 and trendShort and bbShortFilter

rawBuySignal  = longEntrySignal and allowLongByGate and signals_taken < maxSignals
rawSellSignal = shortEntrySignal and allowShortByGate and signals_taken < maxSignals

buySignal  = barstate.isconfirmed and rawBuySignal
sellSignal = barstate.isconfirmed and rawSellSignal

if buySignal
    signals_taken += 1

if sellSignal
    signals_taken += 1

//────────────────────────────────────────────────────────────────────
// Improved Visuals
//────────────────────────────────────────────────────────────────────
filterColor = upcount > 0 ? BULL_COLOR : downcount > 0 ? BEAR_COLOR : NEUTRAL_COLOR
gateColor   = gate_dir == 1 ? BULL_COLOR : BEAR_COLOR

// Soft EMA gate background
bgcolor(showGateBg ? color.new(gateColor, 93) : na, title="EMA Gate Background")

// Optional bar coloring
barcolor(colorBars ? color.new(filterColor, 0) : na)

// Range filter glow + main line
plot(filt, title="Range Filter Glow", color=color.new(filterColor, 85), linewidth=7)
plot(filt, title="Range Filter", color=filterColor, linewidth=3)

// EMA plots
fastPlot = plot(showEMAs ? ema50 : na, title="Fast EMA", color=color.new(color.orange, 0), linewidth=2)
slowPlot = plot(showEMAs ? ema150 : na, title="Slow EMA", color=color.new(color.blue, 0), linewidth=2)

ribbonColor = showEMAs and showEMARibbon ? 
     ema50 > ema150 ? color.new(BULL_COLOR, 86) : color.new(BEAR_COLOR, 86) : na

fill(fastPlot, slowPlot, color=ribbonColor, title="EMA Gate Ribbon")

plot(showEMAs and useTrend ? ema200 : na, 
     title="EMA 200 Trend Filter", 
     color=color.new(color.gray, 25), 
     linewidth=2)

// Cleaner buy/sell labels
plotshape(
     buySignal,
     title="BUY Signal",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(BULL_COLOR, 0),
     textcolor=color.white,
     size=size.normal)

plotshape(
     sellSignal,
     title="SELL Signal",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(BEAR_COLOR, 0),
     textcolor=color.white,
     size=size.normal)

//────────────────────────────────────────────────────────────────────
// Status Panel
//────────────────────────────────────────────────────────────────────
var table statusTable = table.new(position.top_right, 2, 5, border_width=1)

rfText = upcount > 0 ? "UP" : downcount > 0 ? "DOWN" : "FLAT"
gateText = gate_dir == 1 ? "BULLISH" : "BEARISH"
trendText = useTrend ? src > ema200 ? "ABOVE 200" : "BELOW 200" : "OFF"
leftSignals = math.max(maxSignals - signals_taken, 0)

if barstate.islast
    if showStatusPanel
        table.cell(statusTable, 0, 0, "RF + EMA", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(statusTable, 1, 0, "CONFIRMED", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(statusTable, 0, 1, "Range", text_color=color.white, bgcolor=color.new(color.black, 15))
        table.cell(statusTable, 1, 1, rfText, text_color=color.white, bgcolor=color.new(filterColor, 10))

        table.cell(statusTable, 0, 2, "Gate", text_color=color.white, bgcolor=color.new(color.black, 15))
        table.cell(statusTable, 1, 2, gateText, text_color=color.white, bgcolor=color.new(gateColor, 10))

        table.cell(statusTable, 0, 3, "Trend", text_color=color.white, bgcolor=color.new(color.black, 15))
        table.cell(statusTable, 1, 3, trendText, text_color=color.white, bgcolor=color.new(color.gray, 55))

        table.cell(statusTable, 0, 4, "Signals Left", text_color=color.white, bgcolor=color.new(color.black, 15))
        table.cell(statusTable, 1, 4, str.tostring(leftSignals) + "/" + str.tostring(maxSignals), text_color=color.white, bgcolor=color.new(color.gray, 55))
    else
        table.cell(statusTable, 0, 0, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, 0, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 0, 1, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, 1, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 0, 2, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, 2, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 0, 3, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, 3, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 0, 4, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, 4, "", bgcolor=color.new(color.black, 100))

//────────────────────────────────────────────────────────────────────
// Debug Markers
//────────────────────────────────────────────────────────────────────
plotshape(showDebug and longCond, 
     title="Range Filter Long", 
     color=BULL_COLOR, 
     location=location.bottom, 
     style=shape.circle, 
     size=size.tiny)

plotshape(showDebug and shortCond, 
     title="Range Filter Short", 
     color=BEAR_COLOR, 
     location=location.bottom, 
     style=shape.circle, 
     size=size.tiny)

plotshape(showDebug and (trendLong or trendShort), 
     title="Trend OK", 
     color=color.gray, 
     location=location.bottom, 
     style=shape.circle, 
     size=size.tiny)

plotshape(showDebug and (bbLongFilter or bbShortFilter), 
     title="BB OK", 
     color=color.blue, 
     location=location.bottom, 
     style=shape.circle, 
     size=size.tiny)

plotshape(showDebug and (allowLongByGate or allowShortByGate), 
     title="Gate Open", 
     color=color.orange, 
     location=location.bottom, 
     style=shape.circle, 
     size=size.tiny)

//────────────────────────────────────────────────────────────────────
// Alerts — confirmed candle only
//────────────────────────────────────────────────────────────────────
alertcondition(buySignal, 
     title="BUY Signal Confirmed", 
     message="Confirmed BUY signal: Range Filter + EMA Gate conditions confirmed after candle close.")

alertcondition(sellSignal, 
     title="SELL Signal Confirmed", 
     message="Confirmed SELL signal: Range Filter + EMA Gate conditions confirmed after candle close.")

alertcondition(barstate.isconfirmed and crossUp, 
     title="Bullish EMA Gate Flip", 
     message="Bullish EMA Gate Flip: Fast EMA crossed above Slow EMA after candle close.")

alertcondition(barstate.isconfirmed and crossDn, 
     title="Bearish EMA Gate Flip", 
     message="Bearish EMA Gate Flip: Fast EMA crossed below Slow EMA after candle close.")
````
