# RSI + ADR_B Combined

- url: https://www.tradingview.com/script/VKmZKmVu-RSI-ADR-B-Combined/
- type: indicator
- pine_id: PUB;6e41a8c8bb114a8994d4fd7b9d31dfc2
- version: 1.0

## Description

super indicftor for analyse patterns in chats its mega puper veruy good indicator

## Source Code

````pine
//@version=6
indicator(title="RSI + ADR_B Combined", shorttitle="RSI+ADR", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// ─────────────────────────────────────────────
// GROUP: RSI Settings
// ─────────────────────────────────────────────
rsiLengthInput    = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput    = input.source(close, "Source", group="RSI Settings")
calculateDivergence = input.bool(false, title="Calculate Divergence", group="RSI Settings",
     display=display.none,
     tooltip="Calculating divergences is needed in order for divergence alerts to fire.")

// ─────────────────────────────────────────────
// GROUP: ADR_B Settings
// ─────────────────────────────────────────────
adrLength = input.int(9, minval=1, title="ADR_B Length", group="ADR_B Settings")
showADR   = input.bool(true, title="Show ADR_B Line", group="ADR_B Settings")

// ─────────────────────────────────────────────
// GROUP: Smoothing (RSI MA)
// ─────────────────────────────────────────────
GRP    = "RSI Smoothing"
TT_BB  = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput   = input.string("SMA", "Type",
     options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"],
     group=GRP, display=display.none)
var isBB      = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group=GRP, display=display.none, active=maTypeInput != "None")
bbMultInput   = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5,
     tooltip=TT_BB, group=GRP, display=display.none, active=isBB)
var enableMA  = maTypeInput != "None"

// ─────────────────────────────────────────────
// RSI Calculation
// ─────────────────────────────────────────────
change = ta.change(rsiSourceInput)
up     = ta.rma(math.max(change, 0), rsiLengthInput)
down   = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi    = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// ─────────────────────────────────────────────
// ADR_B Calculation  (scaled to RSI 0–100 range)
// Raw ADR goes 0..∞  →  scale to 0–100 via: adrScaled = (ad / (ad + 1)) * 100
// At ad=1 (equality) → 50, mirrors RSI midline perfectly
// ─────────────────────────────────────────────
isUp     = (close - open) >= 0.0
upBars   = math.sum(isUp ? 1 : 0, adrLength)
downBars = math.sum(not isUp ? 1 : 0, adrLength)
ad       = downBars == 0 ? upBars : upBars / downBars
adrScaled = (ad / (ad + 1)) * 100   // maps [0,∞) → [0,100); equality at 50

// ─────────────────────────────────────────────
// RSI Smoothing MA
// ─────────────────────────────────────────────
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA    = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB     ? ta.stdev(rsi, maLengthInput) * bbMultInput : na

// ─────────────────────────────────────────────
// Plots — RSI
// ─────────────────────────────────────────────
rsiPlot     = plot(rsi, "RSI", color=#7E57C2, linewidth=2)
midLinePlot = plot(50, color=na, editable=false, display=display.none)

rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86)
midline      = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86)

fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
fill(rsiPlot, midLinePlot, 100, 70,
     top_color=color.new(color.green, 0), bottom_color=color.new(color.green, 100),
     title="Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30, 0,
     top_color=color.new(color.red, 100), bottom_color=color.new(color.red, 0),
     title="Oversold Gradient Fill")

// RSI Smoothing plots
plot(smoothingMA, "RSI-based MA", color=color.yellow,
     display=enableMA ? display.all : display.none, editable=enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title="Upper Bollinger Band", color=color.green,
     display=isBB ? display.all : display.none, editable=isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title="Lower Bollinger Band", color=color.green,
     display=isBB ? display.all : display.none, editable=isBB)
fill(bbUpperBand, bbLowerBand,
     color=isBB ? color.new(color.green, 90) : na,
     title="Bollinger Bands Background Fill",
     display=isBB ? display.all : display.none, editable=isBB)

// ─────────────────────────────────────────────
// Plots — ADR_B (scaled, overlaid on RSI pane)
// ─────────────────────────────────────────────
plot(showADR ? adrScaled : na, "ADR_B (scaled)", color=#2962FF, linewidth=2)
// Equality line at 50 (= raw ad of 1.0) — shared with RSI midline, no duplicate needed

// ─────────────────────────────────────────────
// Divergence (RSI)
// ─────────────────────────────────────────────
lookbackRight = 5
lookbackLeft  = 5
rangeUpper    = 60
rangeLower    = 5
bearColor  = color.red
bullColor  = color.green
textColor  = color.white
noneColor  = color.new(color.white, 100)

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plFound  = false
phFound  = false
bullCond = false
bearCond = false
rsiLBR   = rsi[lookbackRight]

// Pre-compute _inRange results on every bar to avoid inconsistent history warnings
inRangePL = _inRange(plFound[1])
inRangePH = _inRange(phFound[1])

if calculateDivergence
    // Regular Bullish
    plFound := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))
    rsiHL    = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and inRangePL
    lowLBR   = low[lookbackRight]
    priceLL  = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond := priceLL and rsiHL and plFound

    // Regular Bearish
    phFound := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))
    rsiLH    = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and inRangePH
    highLBR  = high[lookbackRight]
    priceHH  = highLBR > ta.valuewhen(phFound, highLBR, 1)
    bearCond := priceHH and rsiLH and phFound

plot(plFound ? rsiLBR : na, offset=-lookbackRight, title="Regular Bullish",
     linewidth=2, color=bullCond ? bullColor : noneColor,
     display=display.pane, editable=calculateDivergence)
plotshape(bullCond ? rsiLBR : na, offset=-lookbackRight, title="Regular Bullish Label",
     text=" Bull ", style=shape.labelup, location=location.absolute,
     color=bullColor, textcolor=textColor,
     display=display.pane, editable=calculateDivergence)

plot(phFound ? rsiLBR : na, offset=-lookbackRight, title="Regular Bearish",
     linewidth=2, color=bearCond ? bearColor : noneColor,
     display=display.pane, editable=calculateDivergence)
plotshape(bearCond ? rsiLBR : na, offset=-lookbackRight, title="Regular Bearish Label",
     text=" Bear ", style=shape.labeldown, location=location.absolute,
     color=bearColor, textcolor=textColor,
     display=display.pane, editable=calculateDivergence)

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(bullCond, title="Regular Bullish Divergence",
     message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
alertcondition(bearCond, title="Regular Bearish Divergence",
     message="Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
````
