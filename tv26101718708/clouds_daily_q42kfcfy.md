# Clouds Daily

- url: https://www.tradingview.com/script/q42KfCFy-Clouds-Daily/
- type: indicator
- pine_id: PUB;8022d95bdcbe4139ad6b1a446a93e1e5
- version: 1.0

## Description

Clouds Daily (based on Ripster EMA Clouds) is a trend and extension dashboard built for daily swing trading, especially for stocks and options. It uses multiple moving-average clouds to show whether short-term momentum, recovery trend, swing trend, and long-term regime are aligned.

The indicator plots configurable MA clouds:

5/12 Fast Momentum Cloud
8/21 Short Trend Cloud
21/34 Recovery Cloud
34/50 Swing Trend Cloud
Optional 180/200 Regime Cloud
A top-right trend table summarizes the current state of each condition as bullish or bearish. The Extension row is designed to help avoid chasing extended moves. It measures price distance from the 21 EMA using ATR and combines that with a breakout check.

Extension states include:

Setup: price is not extended and has not broken out yet
High Base: price is elevated inside a base
Base Ext: price is stretched above the 21 EMA but has not broken out
Buyable: breakout confirmed without excessive ATR extension
Chase Risk: breakout confirmed while price is already extended
Pullback: price is below the 21 EMA by more than 1 ATR
Discount: deeper pullback zone
Damage: trend deterioration based on price, moving averages, and RSI
ATR risk markers can optionally plot 1, 2, and 3 ATR bands around the 21 EMA to visualize extension and pullback zones directly on the chart.

This indicator is intended as a visual decision-support tool for trend quality, breakout context, and entry risk. It is not a standalone buy/sell system. Always combine it with your own price action, volume, market context, and risk management.

## Source Code

````pine
//@version=5
indicator("Clouds Daily", overlay=true)

// =====================
// Inputs
// =====================
maType = input.string("EMA", "Fast/Recovery Cloud MA Type", options=["EMA", "SMA"])
src = input.source(close, "Fast/Recovery Source")

showFastCloud   = input.bool(true,  "Show 5/12 Fast Momentum Cloud")
showShortCloud  = input.bool(true,  "Show 8/21 Short Trend Cloud")
showRecovery    = input.bool(true,  "Show 21/34 Recovery Cloud")
showSwingCloud  = input.bool(true,  "Show 34/SMA 50 Swing Trend Cloud")
showRegimeCloud = input.bool(false, "Show 180/200 Regime Cloud")
showAllClouds = input.bool(true, "Show All Cloud Fills")

showLines = input.bool(false, "Show MA Lines")
showKeyMALines = input.bool(false, "Show 8/21 EMA + 50/200 SMA Lines")
showCandleTint = input.bool(false, "Tint Candles")
candleOpacity = input.int(40, "Candle Opacity %", minval=0, maxval=100)
showTable = input.bool(true, "Show Trend State Table")
showCloudLegend = input.bool(true, "Show Cloud Color Legend")

// ATR extension
atrLen = input.int(14, "ATR Length")
chaseAtrMult = input.float(2.0, "Chase Risk ATR Multiple", step=0.25)
breakoutLookback = input.int(50, "Breakout Lookback Bars", minval=5, maxval=252)

// RSI trend-damage filter
rsiLen = input.int(14, "RSI Length")
rsiBearLevel = input.float(45, "RSI Bear Level")

// =====================
// MA Function
// =====================
f_ma(_src, _len) =>
    maType == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

// =====================
// Moving Averages
// =====================
ma5   = f_ma(src, 5)
ma8   = f_ma(src, 8)
ma12  = f_ma(src, 12)
ma21  = f_ma(src, 21)
ma34  = f_ma(src, 34)
ma50  = ta.sma(close, 50)
ma180 = ta.sma(close, 180)
ma200 = ta.sma(close, 200)

ema8Line = ta.ema(close, 8)
ema21Line = ta.ema(close, 21)
ema5Line = ta.ema(close, 5)

atrBase = ema21Line

// =====================
// Conditions
// =====================
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)

fastBull     = ma5 > ma12
shortBull    = ma8 > ma21
recoveryBull = ma21 > ma34
swingBull    = ma34 > ma50
regimeBull   = close > ma200

bearDamage =
     close < ma34 and
     ma21 < ma34 and
     rsi < rsiBearLevel

priorBreakoutHigh = ta.highest(high[1], breakoutLookback)
breakoutConfirmed = not na(priorBreakoutHigh) and close > priorBreakoutHigh
atrExtended = close > atrBase + atr * chaseAtrMult
chaseRisk = atrExtended and breakoutConfirmed

deepDiscount =
     close < atrBase - atr * chaseAtrMult

extensionAtr = not na(atr) and atr != 0 ? (close - atrBase) / atr : na
extensionAtrText = na(extensionAtr) ? "n/a" : (extensionAtr > 0 ? "+" : "") + str.tostring(extensionAtr, "0.0") + " ATR"
// Chase risk requires both a breakout and ATR extension; extension inside a base gets its own label.
extensionState =
     bearDamage ? "Damage " + extensionAtrText :
     chaseRisk ? "Chase Risk " + extensionAtrText :
     breakoutConfirmed ? "Buyable " + extensionAtrText :
     atrExtended ? "Base Ext " + extensionAtrText :
     deepDiscount ? "Discount " + extensionAtrText :
     extensionAtr >= 1.0 ? "High Base " + extensionAtrText :
     extensionAtr <= -1.0 ? "Pullback " + extensionAtrText :
     "Setup " + extensionAtrText
extensionColor =
     bearDamage ? color.red :
     chaseRisk ? color.red :
     breakoutConfirmed ? color.green :
     atrExtended ? color.orange :
     deepDiscount ? color.green :
     extensionAtr >= 1.0 ? color.orange :
     extensionAtr <= -1.0 ? color.teal :
     color.gray

// =====================
// Plot Clouds
// =====================
p5   = plot(showFastCloud ? ma5 : na,   "MA 5",   color=showLines ? color.new(color.green, 0) : na)
p12  = plot(showFastCloud ? ma12 : na,  "MA 12",  color=showLines ? color.new(color.red, 0) : na)

p8   = plot(showShortCloud ? ma8 : na,  "MA 8",   color=showLines ? color.new(color.green, 0) : na)
p21  = plot(showShortCloud ? ma21 : na, "MA 21",  color=showLines ? color.new(color.red, 0) : na)

p21r = plot(showRecovery ? ma21 : na,   "MA 21 Recovery", color=showLines ? color.new(color.blue, 0) : na)
p34  = plot(showRecovery ? ma34 : na,   "MA 34", color=showLines ? color.new(color.orange, 0) : na)

p34s = plot(showSwingCloud ? ma34 : na, "MA 34 Swing", color=showLines ? color.new(color.blue, 0) : na)
p50  = plot(showSwingCloud ? ma50 : na, "SMA 50", color=showLines ? color.new(color.orange, 0) : na)

p180 = plot(showRegimeCloud ? ma180 : na, "SMA 180", color=showLines ? color.new(color.aqua, 0) : na)
p200 = plot(showRegimeCloud ? ma200 : na, "SMA 200", color=showLines ? color.new(color.gray, 0) : na)

fill(p5, p12,   color=showAllClouds ? fastBull ? color.new(color.green, 87) : color.new(color.red, 90) : na, title="5/12 Fast Cloud")
fill(p8, p21,   color=showAllClouds ? shortBull ? color.new(color.lime, 90) : color.new(color.red, 92) : na, title="8/21 Short Cloud")
fill(p21r, p34, color=showAllClouds ? recoveryBull ? color.new(color.blue, 90) : color.new(color.orange, 92) : na, title="21/34 Recovery Cloud")
fill(p34s, p50, color=showAllClouds ? swingBull ? color.new(color.teal, 90) : color.new(color.maroon, 92) : na, title="34/SMA 50 Swing Cloud")
fill(p180, p200, color=showAllClouds ? ma180 > ma200 ? color.new(color.aqua, 92) : color.new(color.orange, 94) : na, title="180/200 Regime Cloud")

plot(showKeyMALines ? ema5Line : na, "EMA 5 Line", color=color.new(color.yellow, 25), linewidth=2)
plot(showKeyMALines ? ema8Line : na, "EMA 8 Line", color=color.new(color.green, 25), linewidth=2)
plot(showKeyMALines ? ema21Line : na, "EMA 21 Line", color=color.new(color.blue, 25), linewidth=2)
plot(showKeyMALines ? ma50 : na, "SMA 50 Line", color=color.new(color.red, 25), linewidth=2)
plot(showKeyMALines ? ma200 : na, "SMA 200 Line", color=color.new(color.black, 20), linewidth=2)

// =====================
// Trend Table
// =====================
var table trendTable = table.new(position.top_right, 2, 7, border_width=1)

if showTable and barstate.islast
    table.cell(trendTable, 0, 0, "Condition", text_color=color.white, bgcolor=color.black)
    table.cell(trendTable, 1, 0, "State", text_color=color.white, bgcolor=color.black)

    table.cell(trendTable, 0, 1, "Fast 5/12")
    table.cell(trendTable, 1, 1, fastBull ? "Bullish" : "Bearish", bgcolor=fastBull ? color.green : color.red, text_color=color.white)

    table.cell(trendTable, 0, 2, "Short 8/21")
    table.cell(trendTable, 1, 2, shortBull ? "Bullish" : "Bearish", bgcolor=shortBull ? color.green : color.red, text_color=color.white)

    table.cell(trendTable, 0, 3, "Recovery 21/34")
    table.cell(trendTable, 1, 3, recoveryBull ? "Bullish" : "Bearish", bgcolor=recoveryBull ? color.green : color.red, text_color=color.white)

    table.cell(trendTable, 0, 4, "Swing 34/SMA50")
    table.cell(trendTable, 1, 4, swingBull ? "Bullish" : "Bearish", bgcolor=swingBull ? color.green : color.red, text_color=color.white)

    table.cell(trendTable, 0, 5, "200 Regime")
    table.cell(trendTable, 1, 5, regimeBull ? "Above 200" : "Below 200", bgcolor=regimeBull ? color.green : color.orange, text_color=color.white)

    table.cell(trendTable, 0, 6, "Extension")
    table.cell(trendTable, 1, 6, extensionState, bgcolor=extensionColor, text_color=color.white)

// =====================
// Cloud Color Legend
// =====================
var table cloudLegend = table.new(position.bottom_left, 3, 6, border_width=1)

if showCloudLegend and barstate.islast
    table.cell(cloudLegend, 0, 0, "Cloud", width=12, height=2, bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 1, 0, "Bull", width=7, height=2, bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 2, 0, "Bear", width=7, height=2, bgcolor=color.black, text_color=color.white, text_size=size.small)

    table.cell(cloudLegend, 0, 1, "5/12 Fast", width=12, height=2, bgcolor=color.new(color.black, 15), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 1, 1, "Green", width=7, height=2, bgcolor=color.new(color.green, 20), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 2, 1, "Red", width=7, height=2, bgcolor=color.new(color.red, 20), text_color=color.white, text_size=size.small)

    table.cell(cloudLegend, 0, 2, "8/21 Short", width=12, height=2, bgcolor=color.new(color.black, 15), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 1, 2, "Lime", width=7, height=2, bgcolor=color.new(color.lime, 20), text_color=color.black, text_size=size.small)
    table.cell(cloudLegend, 2, 2, "Red", width=7, height=2, bgcolor=color.new(color.red, 25), text_color=color.white, text_size=size.small)

    table.cell(cloudLegend, 0, 3, "21/34 Rec", width=12, height=2, bgcolor=color.new(color.black, 15), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 1, 3, "Blue", width=7, height=2, bgcolor=color.new(color.blue, 20), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 2, 3, "Orange", width=7, height=2, bgcolor=color.new(color.orange, 20), text_color=color.white, text_size=size.small)

    table.cell(cloudLegend, 0, 4, "34/SMA50", width=12, height=2, bgcolor=color.new(color.black, 15), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 1, 4, "Teal", width=7, height=2, bgcolor=color.new(color.teal, 20), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 2, 4, "Maroon", width=7, height=2, bgcolor=color.new(color.maroon, 20), text_color=color.white, text_size=size.small)

    table.cell(cloudLegend, 0, 5, "180/200 Reg", width=12, height=2, bgcolor=color.new(color.black, 15), text_color=color.white, text_size=size.small)
    table.cell(cloudLegend, 1, 5, "Aqua", width=7, height=2, bgcolor=color.new(color.aqua, 20), text_color=color.black, text_size=size.small)
    table.cell(cloudLegend, 2, 5, "Orange", width=7, height=2, bgcolor=color.new(color.orange, 25), text_color=color.white, text_size=size.small)

// =====================
// Alerts
// =====================
alertcondition(chaseRisk and not chaseRisk[1], "Chase Risk", "Price is breaking out while extended above the ATR band")
alertcondition(bearDamage and not bearDamage[1], "Trend Damage", "Bearish trend damage signal triggered")


// =====================
// ATR Risk Markers
// =====================
showATRMarkers = input.bool(true, "Show ATR Risk Markers")

atrVal = ta.atr(atrLen)

// 1, 2, and 3 ATR extension markers.
upperATR1 = atrBase + atrVal
lowerATR1 = atrBase - atrVal
upperATR2 = atrBase + atrVal * 2
lowerATR2 = atrBase - atrVal * 2
upperATR3 = atrBase + atrVal * 3
lowerATR3 = atrBase - atrVal * 3

// Plot
plot(showATRMarkers ? upperATR1 : na, "Upper 1 ATR Marker", color=color.new(color.red, 65), linewidth=1, style=plot.style_circles)
plot(showATRMarkers ? lowerATR1 : na, "Lower 1 ATR Marker", color=color.new(color.green, 65), linewidth=1, style=plot.style_circles)

plot(showATRMarkers ? upperATR2 : na, "Upper 2 ATR Risk Marker", color=color.new(color.red, 35), linewidth=2, style=plot.style_circles)
plot(showATRMarkers ? lowerATR2 : na, "Lower 2 ATR Discount Marker", color=color.new(color.green, 35), linewidth=2, style=plot.style_circles)

plot(showATRMarkers ? upperATR3 : na, "Upper 3 ATR Extreme Marker", color=color.new(color.red, 55), linewidth=2, style=plot.style_cross)
plot(showATRMarkers ? lowerATR3 : na, "Lower 3 ATR Extreme Marker", color=color.new(color.green, 55), linewidth=2, style=plot.style_cross)

candleTransparency = 100 - candleOpacity
candleColor = close >= open ? color.new(color.teal, candleTransparency) : color.new(color.red, candleTransparency)
barcolor(showCandleTint ? candleColor : na)
````
