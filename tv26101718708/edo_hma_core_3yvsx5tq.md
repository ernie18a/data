# Edo HMA Core

- url: https://www.tradingview.com/script/3yvSX5tQ-Edo-HMA-Core/
- type: indicator
- pine_id: PUB;e81adb780cda4bce8b120ed4f966cc83
- version: 1.0

## Description

Edo HMA Core — Clean Trend Reading Built on the Hull Moving Average with Slope, State, Fast Acceleration, Inflexion Markers and Information Panel

The Hull Moving Average was introduced by Alan Hull in 2005 to solve the permanent dilemma of classical moving averages: the smoother the average, the more lag; the faster the average, the more noise. By combining three weighted moving averages with mathematically derived lengths, the HMA produces a curve that is visually smooth but reacts to price flips with significantly less lag than an equivalent EMA or SMA.

Edo HMA Core takes that original idea and turns it into a complete trend indicator. On its own, an HMA is just a line. With Edo HMA Core, that line gains state colour, a percentage slope reading, an automatic inflexion detector, a translucent state fill between price and average, and a second faster HMA that adds an acceleration reading. Five coordinated layers on a single overlay, designed to keep the visual purity of a moving average while delivering far richer information about the regime of the asset.


THREE HMA VARIANTS

A single dropdown selects between three Hull constructions:

— Standard — Alan Hull's original three-WMA formula. Balanced, default option. Recommended for 4H, daily and weekly charts.
— Exponential (EHMA) — Variant built with EMA instead of WMA. Slightly smoother and slower to react. Useful on highly volatile assets or low timeframes.
— Triple (THMA) — Variant using three WMAs with 1/3, 1/2 and full lengths weighted for sharper turns. Most reactive variant, useful for early inflexion detection at the cost of a small noise increase.

The three variants share plots, markers and panel — only the calculation engine of the line changes.


SLOPE AND STATE CLASSIFICATION

Slope is calculated as the difference between the current HMA value and its value a few bars back:

slope = HMA − HMA[lookback]

The Slope Lookback parameter (default 2) controls how reactive the reading is. Low lookbacks catch turns earlier; high lookbacks filter noise.

Based on the sign of the slope, the indicator assigns one of three states:

— Trend Up — Slope > 0. Main HMA, fast HMA and fill turn green.
— Trend Down — Slope < 0. Main HMA, fast HMA and fill turn red.
— Flat — Slope = 0. Lines turn neutral teal.

The colour system is consistent across every visual element, so the regime is readable at a glance without needing to look at the panel.


FAST HMA AND ACCELERATION CROSSES

A second HMA is calculated with a shorter length (21 by default), sharing type and source with the main. The relationship between fast and main is read as an acceleration measure:

— Fast above main → recent momentum accelerating relative to the underlying trend
— Fast below main → recent momentum decelerating or reversing

Each cross is automatically marked with an X-cross: green below the candle for a Fast Cross Up, red above the candle for a Fast Cross Down. These are acceleration signals, not trend-change signals — for that, the indicator provides explicit inflexion triangles.


INFLEXION MARKERS

The most structural signals of the indicator. Every time the main slope changes sign, the indicator draws a triangle:

— Flip Up (▲) — Green triangle below the candle when slope crosses from negative to positive. Start of a new bullish regime.
— Flip Down (▼) — Red triangle above the candle when slope crosses from positive to negative. Start of a new bearish regime.

Every flip is accompanied by a simultaneous update of the HMA colour, fast HMA colour and state fill.


PRICE / HMA CROSSES AND STATE FILL

Direct crosses of price with the main HMA do not produce visual markers (to keep the chart clean) but are available as alert conditions:

— Price Crossed Above HMA — close reclaims the main HMA. Bullish reclaim.
— Price Crossed Below HMA — close loses the main HMA. Loss of dynamic support.

Between price and HMA the indicator draws a translucent fill whose colour matches the active state. Fill Opacity is configurable from 50 (very opaque) to 99 (almost invisible), default 85. The fill provides an immediate state reading and makes the magnitude of the price/HMA separation visible at all times.


INFORMATION PANEL

A five-field panel summarises the current regime in real time:

— State — Trend Up / Trend Down / Flat
— Slope — current slope as a percentage of the HMA value (e.g. +4.402%, −0.739%)
— Price vs HMA — distance of price from the HMA as a percentage (e.g. +50.25%, −13.00%)
— Fast — relative position of the fast HMA versus main (Fast > Slow, Fast < Slow, Off)
— Type — current variant and length (e.g. Standard - 55)

Numeric fields are coloured according to the active state. The panel can be placed in any of the four chart corners and resized to Small or Medium. Dark and Light themes adapt the panel to the chart background.


CONFIGURATION

— Hull MA: HMA Length (default 55), HMA Type (Standard / Exponential / Triple), Source (default close), HMA Line Width (1-5)
— Fast Cross: Show Fast HMA Cross, Fast HMA Length (default 21), Fast HMA Width (1-4)
— State: Show Inflexion Markers, Slope Lookback in bars (1-10), Fill Between Price and HMA, Fill Opacity (50-99)
— Style: Bull Color, Bear Color, Neutral Color, Theme (Dark / Light)
— Panel: Show Panel, Panel Position (four corners), Panel Size (Small / Medium)


ALERTS

Six predefined alert conditions cover every meaningful event:

— HMA Flip Up — slope crosses from negative to positive
— HMA Flip Down — slope crosses from positive to negative
— Fast Cross Up — fast HMA crosses above main
— Fast Cross Down — fast HMA crosses below main
— Price Crossed Above HMA — close reclaims the main HMA
— Price Crossed Below HMA — close loses the main HMA

All alerts evaluate on bar close in the active timeframe. The two inflexion alerts work well for medium and long-term position management; the two fast crosses are common in active management; the two price/HMA alerts confirm breaks of the average in mature trends.


HOW TO READ IT

A clean reading combines the five layers into common patterns.

Clean bullish reactivation — After prolonged Trend Down, a Flip Up appears, price reclaims the HMA, the fast crosses above the main and the fill switches from red to green. The cleanest sequence for confirming a new bullish regime.

Bullish exhaustion — In a sustained Trend Up, slope shrinks while price keeps advancing. A Fast Cross Down appears before any slope change. Usually precedes a Flip Down.

Bearish capitulation — In an advanced Trend Down, a Fast Cross Up appears inside the red fill. If price then reclaims the HMA and slope turns, a Flip Up arrives.

Sideways noise — In flat zones, slope crosses zero repeatedly and alternating flips appear within a few bars. Raise Slope Lookback to 5+ bars to filter non-structural flips.


OPEN SOURCE

Edo HMA Core is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem alongside Edo SuperTrend Core, Edo EMA Core Cross, Edo Sentiment Map, Edo TRIX Core Cross, Edo RSI Dual, Edo Multi Stoch, Edo A/D Flow Core, Edo Liquidity Zones, Edo ZigZag Auto Fib SR and Edo Bands Fusion.


This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets


//@version=6
indicator("Edo HMA Core", overlay=true, max_labels_count=500)

// ================== INPUTS — HMA ==================
hmaLen   = input.int(55, "HMA Length", minval=4, group="Hull MA")
hmaType  = input.string("Standard", "HMA Type", options=["Standard", "Exponential", "Triple"], group="Hull MA", tooltip="Standard: classic Hull MA. Exponential (EHMA): EMA-based, smoother. Triple (THMA): 3-WMA combination, sharper turns.")
hmaSrc   = input.source(close, "Source", group="Hull MA")
hmaWidth = input.int(3, "HMA Line Width", minval=1, maxval=5, group="Hull MA")

// ================== INPUTS — FAST CROSS ==================
showFast    = input.bool(true, "Show Fast HMA Cross", group="Fast Cross")
hmaFastLen  = input.int(21, "Fast HMA Length", minval=4, group="Fast Cross")
fastWidth   = input.int(1, "Fast HMA Width", minval=1, maxval=4, group="Fast Cross")

// ================== INPUTS — STATE ==================
showInflex   = input.bool(true, "Show Inflexion Markers", group="State")
slopeBars    = input.int(2, "Slope Lookback (bars)", minval=1, maxval=10, group="State", tooltip="Bars used to evaluate trend direction.")
showFill     = input.bool(true, "Fill Between Price and HMA", group="State")
fillOpacity  = input.int(85, "Fill Opacity", minval=50, maxval=99, step=1, group="State")

// ================== INPUTS — STYLE ==================
colorBull    = input.color(#1FA64B, "Bull Color",    group="Style")
colorBear    = input.color(#C73535, "Bear Color",    group="Style")
colorNeutral = input.color(#5B9FAD, "Neutral Color", group="Style")
themeMode    = input.string("Dark", "Theme", options=["Dark", "Light"], group="Style")

// ================== INPUTS — PANEL ==================
showPanel = input.bool(true, "Show Panel", group="Panel")
panelPos  = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Panel")
panelSize = input.string("Medium", "Panel Size", options=["Small", "Medium"], group="Panel")

// ================== THEME ==================
isDark        = themeMode == "Dark"
panelBg       = isDark ? color.new(#1A1A2E, 10)     : color.new(color.white, 5)
panelHeader   = isDark ? color.new(#2A2E39, 0)      : color.new(#D1D4DC, 0)
panelSubBg    = isDark ? color.new(#363A45, 0)      : color.new(#E0E3EB, 0)
panelText     = isDark ? color.new(color.white, 0)  : color.new(color.black, 0)
panelTextSub  = isDark ? color.new(color.white, 30) : color.new(color.black, 30)
panelBorder   = color.new(color.gray, 50)
panSize       = panelSize == "Small" ? size.tiny : size.small

// ================== HMA VARIANTS ==================
f_hmaStd(src, len) =>
    half    = math.max(1, math.floor(len / 2))
    sqrtLen = math.max(1, math.round(math.sqrt(len)))
    ta.wma(2 * ta.wma(src, half) - ta.wma(src, len), sqrtLen)

f_hmaEma(src, len) =>
    half    = math.max(1, math.floor(len / 2))
    sqrtLen = math.max(1, math.round(math.sqrt(len)))
    ta.ema(2 * ta.ema(src, half) - ta.ema(src, len), sqrtLen)

f_hmaTriple(src, len) =>
    third  = math.max(1, math.floor(len / 3))
    half   = math.max(1, math.floor(len / 2))
    ta.wma(ta.wma(src, third) * 3 - ta.wma(src, half) - ta.wma(src, len), len)

f_hma(src, len, kind) =>
    kind == "Exponential" ? f_hmaEma(src, len) : kind == "Triple" ? f_hmaTriple(src, len) : f_hmaStd(src, len)

hmaMain = f_hma(hmaSrc, hmaLen,     hmaType)
hmaFast = f_hma(hmaSrc, hmaFastLen, hmaType)

// ================== STATE ==================
slope    = hmaMain - hmaMain[slopeBars]
isBull   = slope > 0
isBear   = slope < 0
flipUp   = ta.crossover(slope, 0)
flipDown = ta.crossunder(slope, 0)

rawFastCrossUp   = ta.crossover(hmaFast, hmaMain)
rawFastCrossDown = ta.crossunder(hmaFast, hmaMain)
fastCrossUp      = showFast and rawFastCrossUp
fastCrossDown    = showFast and rawFastCrossDown

priceCrossUp   = ta.crossover(close, hmaMain)
priceCrossDown = ta.crossunder(close, hmaMain)

state    = "Flat"
stateCol = colorNeutral

if isBull
    state    := "Trend Up"
    stateCol := colorBull
else if isBear
    state    := "Trend Down"
    stateCol := colorBear

// ================== HMA LINE COLOR ==================
hmaCol = isBull ? colorBull : isBear ? colorBear : colorNeutral

// ================== PLOTS — HMA ==================
hmaPlot   = plot(hmaMain, "HMA",      color=hmaCol, linewidth=hmaWidth)
fastPlot  = plot(showFast ? hmaFast : na, "Fast HMA", color=color.new(hmaCol, 50), linewidth=fastWidth)
pricePlot = plot(showFill ? close : na, "", display=display.none)

fillCol = color.new(stateCol, fillOpacity)
fill(hmaPlot, pricePlot, showFill ? fillCol : na, title="Price-HMA Fill")

// ================== INFLEXION MARKERS ==================
plotshape(showInflex and flipUp,   "Flip Up",   style=shape.triangleup,   location=location.belowbar, color=colorBull, size=size.small)
plotshape(showInflex and flipDown, "Flip Down", style=shape.triangledown, location=location.abovebar, color=colorBear, size=size.small)

// ================== FAST CROSS MARKERS ==================
plotshape(fastCrossUp,   "Fast Cross Up",   style=shape.xcross, location=location.belowbar, color=colorBull, size=size.tiny)
plotshape(fastCrossDown, "Fast Cross Down", style=shape.xcross, location=location.abovebar, color=colorBear, size=size.tiny)

// ================== PANEL ==================
panelPosTV = panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Bottom Left" ? position.bottom_left : position.top_right

var table panel = table.new(panelPosTV, 2, 6, frame_color=panelBorder, frame_width=1, border_color=panelBorder, border_width=1)

distPct      = hmaMain != 0 ? (close - hmaMain) / hmaMain * 100 : 0.0
slopePct     = hmaMain != 0 ? slope / hmaMain * 100 : 0.0
distTxt      = na(distPct)  ? "—" : (distPct  >= 0 ? "+" : "") + str.tostring(distPct,  "#.##") + "%"
slopeTxt     = na(slopePct) ? "—" : (slopePct >= 0 ? "+" : "") + str.tostring(slopePct, "#.###") + "%"
fastStateTxt = showFast ? (hmaFast > hmaMain ? "Fast > Slow" : "Fast < Slow") : "Off"
fastStateCol = showFast ? (hmaFast > hmaMain ? colorBull : colorBear) : panelTextSub
typeTxt      = hmaType + " · " + str.tostring(hmaLen)

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "EDO HMA CORE", text_color=panelText, bgcolor=panelHeader, text_size=panSize)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "State", text_color=panelText, bgcolor=panelSubBg, text_size=panSize)
    table.cell(panel, 1, 1, state,   text_color=stateCol,  bgcolor=panelBg,    text_size=panSize)

    table.cell(panel, 0, 2, "Slope",  text_color=panelText, bgcolor=panelSubBg, text_size=panSize)
    table.cell(panel, 1, 2, slopeTxt, text_color=stateCol,  bgcolor=panelBg,    text_size=panSize)

    table.cell(panel, 0, 3, "Price vs HMA", text_color=panelText,    bgcolor=panelSubBg, text_size=panSize)
    table.cell(panel, 1, 3, distTxt,        text_color=panelTextSub, bgcolor=panelBg,    text_size=panSize)

    table.cell(panel, 0, 4, "Fast",     text_color=panelText, bgcolor=panelSubBg, text_size=panSize)
    table.cell(panel, 1, 4, fastStateTxt, text_color=fastStateCol, bgcolor=panelBg, text_size=panSize)

    table.cell(panel, 0, 5, "Type",  text_color=panelText,    bgcolor=panelSubBg, text_size=panSize)
    table.cell(panel, 1, 5, typeTxt, text_color=panelTextSub, bgcolor=panelBg,    text_size=panSize)

// ================== ALERTS ==================
alertcondition(flipUp,
     "HMA Flip Up",
     "Edo HMA Core — HMA slope flipped positive. Bullish inflexion.")
alertcondition(flipDown,
     "HMA Flip Down",
     "Edo HMA Core — HMA slope flipped negative. Bearish inflexion.")
alertcondition(fastCrossUp,
     "Fast Cross Up",
     "Edo HMA Core — Fast HMA crossed above main HMA. Bullish acceleration.")
alertcondition(fastCrossDown,
     "Fast Cross Down",
     "Edo HMA Core — Fast HMA crossed below main HMA. Bearish acceleration.")
alertcondition(priceCrossUp,
     "Price Crossed Above HMA",
     "Edo HMA Core — Price crossed above HMA. Bullish reclaim.")
alertcondition(priceCrossDown,
     "Price Crossed Below HMA",
     "Edo HMA Core — Price crossed below HMA. Bearish loss.")
````
