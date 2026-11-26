# EMA/VWAP/BB FLOW [TT]

- url: https://www.tradingview.com/script/Z6EkKd7C-EMA-VWAP-BB-FLOW-TT/
- type: indicator
- pine_id: PUB;7419428ed7e441d4962a2bd31217d248
- version: 1.0

## Description

# EMA/VWAP/BB FLOW [TT]

EMA/VWAP/BB FLOW [TT] is a streamlined trend and structure tool designed for traders who rely on moving averages, VWAP, and Bollinger Bands without unnecessary clutter.

This indicator combines multiple key EMAs, session VWAP, and customizable Bollinger Bands into a single lightweight package, allowing traders to build their preferred workflow while keeping charts clean and organized.

### Features

• 11 Exponential Moving Averages:

* EMA 5
* EMA 9
* EMA 14
* EMA 21
* EMA 30
* EMA 40
* EMA 50
* EMA 60
* EMA 100
* EMA 200
* EMA 800

• Fully customizable colors and line widths for every EMA

• Session VWAP

* VWAP only (no deviation bands)
* Adjustable color and line width

• Bollinger Bands

* Custom length and multiplier
* Independent colors for upper, middle, and lower bands
* Optional shaded fill between bands
* Adjustable line widths and shading color

### Default Layout

Enabled by default:

* EMA 9 (Gray)
* EMA 50 (Red)
* EMA 100 (Orange)
* EMA 200 (Purple)

Disabled by default:

* EMA 5
* EMA 14
* EMA 21
* EMA 30
* EMA 40
* EMA 60
* EMA 800
* VWAP
* Bollinger Bands

Bollinger Band defaults:

* Upper Band = Red
* Basis = Gray
* Lower Band = Green

### Designed For

EMA/VWAP/BB FLOW [TT] was built for futures, stocks, forex, and crypto traders who want quick access to key trend references while maintaining complete control over chart appearance.

Simple. Fast. Clean.

## Source Code

````pine
//@version=6
indicator("EMA/VWAP/BB FLOW [TT]", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpEMA = "EMAs"

emaWidth = input.int(2, "EMA Line Width", minval=1, maxval=5, group=grpEMA)

showEMA5   = input.bool(false, "Show EMA 5", group=grpEMA)
showEMA9   = input.bool(true,  "Show EMA 9", group=grpEMA)
showEMA14  = input.bool(false, "Show EMA 14", group=grpEMA)
showEMA21  = input.bool(false, "Show EMA 21", group=grpEMA)
showEMA30  = input.bool(false, "Show EMA 30", group=grpEMA)
showEMA40  = input.bool(false, "Show EMA 40", group=grpEMA)
showEMA50  = input.bool(true,  "Show EMA 50", group=grpEMA)
showEMA60  = input.bool(false, "Show EMA 60", group=grpEMA)
showEMA100 = input.bool(true,  "Show EMA 100", group=grpEMA)
showEMA200 = input.bool(true,  "Show EMA 200", group=grpEMA)
showEMA800 = input.bool(false, "Show EMA 800", group=grpEMA)

ema5Color   = input.color(color.white,  "EMA 5 Color", group=grpEMA)
ema9Color   = input.color(color.gray,   "EMA 9 Color", group=grpEMA)
ema14Color  = input.color(color.aqua,   "EMA 14 Color", group=grpEMA)
ema21Color  = input.color(color.lime,   "EMA 21 Color", group=grpEMA)
ema30Color  = input.color(color.yellow, "EMA 30 Color", group=grpEMA)
ema40Color  = input.color(color.blue,   "EMA 40 Color", group=grpEMA)
ema50Color  = input.color(color.red,    "EMA 50 Color", group=grpEMA)
ema60Color  = input.color(color.fuchsia,"EMA 60 Color", group=grpEMA)
ema100Color = input.color(color.orange, "EMA 100 Color", group=grpEMA)
ema200Color = input.color(color.purple, "EMA 200 Color", group=grpEMA)
ema800Color = input.color(color.teal,   "EMA 800 Color", group=grpEMA)

// EMA CALCS
ema5   = ta.ema(close, 5)
ema9   = ta.ema(close, 9)
ema14  = ta.ema(close, 14)
ema21  = ta.ema(close, 21)
ema30  = ta.ema(close, 30)
ema40  = ta.ema(close, 40)
ema50  = ta.ema(close, 50)
ema60  = ta.ema(close, 60)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)
ema800 = ta.ema(close, 800)

// EMA PLOTS
plot(showEMA5   ? ema5   : na, "EMA 5",   color=ema5Color,   linewidth=emaWidth)
plot(showEMA9   ? ema9   : na, "EMA 9",   color=ema9Color,   linewidth=emaWidth)
plot(showEMA14  ? ema14  : na, "EMA 14",  color=ema14Color,  linewidth=emaWidth)
plot(showEMA21  ? ema21  : na, "EMA 21",  color=ema21Color,  linewidth=emaWidth)
plot(showEMA30  ? ema30  : na, "EMA 30",  color=ema30Color,  linewidth=emaWidth)
plot(showEMA40  ? ema40  : na, "EMA 40",  color=ema40Color,  linewidth=emaWidth)
plot(showEMA50  ? ema50  : na, "EMA 50",  color=ema50Color,  linewidth=emaWidth)
plot(showEMA60  ? ema60  : na, "EMA 60",  color=ema60Color,  linewidth=emaWidth)
plot(showEMA100 ? ema100 : na, "EMA 100", color=ema100Color, linewidth=emaWidth)
plot(showEMA200 ? ema200 : na, "EMA 200", color=ema200Color, linewidth=emaWidth)
plot(showEMA800 ? ema800 : na, "EMA 800", color=ema800Color, linewidth=emaWidth)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpVWAP = "VWAP"

showVWAP  = input.bool(false, "Show VWAP", group=grpVWAP)
vwapColor = input.color(color.blue, "VWAP Color", group=grpVWAP)
vwapWidth = input.int(2, "VWAP Line Width", minval=1, maxval=5, group=grpVWAP)

vwapLine = ta.vwap(hlc3)

plot(showVWAP ? vwapLine : na, "VWAP", color=vwapColor, linewidth=vwapWidth)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BOLLINGER BAND SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpBB = "Bollinger Bands"

showBB       = input.bool(false, "Show Bollinger Bands", group=grpBB)
bbLength     = input.int(20, "BB Length", minval=1, group=grpBB)
bbMult       = input.float(2.0, "BB Multiplier", minval=0.1, step=0.1, group=grpBB)
bbSource     = input.source(close, "BB Source", group=grpBB)
bbWidth      = input.int(2, "BB Line Width", minval=1, maxval=5, group=grpBB)

bbBasisColor = input.color(color.gray, "BB Basis Color", group=grpBB)
bbUpperColor = input.color(color.red, "BB Upper Color", group=grpBB)
bbLowerColor = input.color(color.rgb(114, 171, 92), "BB Lower Color", group=grpBB)

showBBShade  = input.bool(true, "Show BB Shade", group=grpBB)
bbShadeColor = input.color(color.new(color.gray, 90), "BB Shade Color", group=grpBB)

// BB CALCS
bbBasis = ta.sma(bbSource, bbLength)
bbDev   = bbMult * ta.stdev(bbSource, bbLength)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

// BB PLOTS
bbUpperPlot = plot(showBB ? bbUpper : na, "BB Upper", color=bbUpperColor, linewidth=bbWidth)
bbBasisPlot = plot(showBB ? bbBasis : na, "BB Basis", color=bbBasisColor, linewidth=bbWidth)
bbLowerPlot = plot(showBB ? bbLower : na, "BB Lower", color=bbLowerColor, linewidth=bbWidth)

fill(bbUpperPlot, bbLowerPlot, color=showBB and showBBShade ? bbShadeColor : na, title="BB Shade")
````
