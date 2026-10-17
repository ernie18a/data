# Super Envolvente by Emma-Fu #EMCT

- url: https://www.tradingview.com/script/zsNKk6W9-Super-Envolvente-by-Emma-Fu-EMCT/
- type: indicator
- pine_id: PUB;dfeaf478b9f941d19f4b85ebd281db51
- version: 1.0

## Description

Super Envolvente by Emma-Fu #EMCT

An “Outer Box” engulfing candle indicator: it detects when a candle fully engulfs the previous candle’s entire range — wick and body, not just the body — and plots the exact level price must break to confirm entry.

How it works:

Setup detection (Outer Box): identified when the current candle’s high and low fully exceed the previous candle’s high and low (wicks included), forming a “box” that completely wraps around the prior candle — covering the body alone is not enough.
Opposite-color filter (optional): requires the engulfed candle to be the opposite color of the engulfing candle, to validate a genuine structural shift.
EMA trend filter (optional): only takes setups aligned with a configurable EMA.
Entry level: automatically plotted at the body extreme of the engulfing candle (the close of the bullish or bearish candle).
Entry trigger: the BUY/SELL signal only fires when price breaks that level with a candle body in the direction of the setup — a wick touch is not enough.
Time validity: each setup expires after a configurable number of candles if price never breaks the level.

Includes: automatic alerts for both setup and confirmed entry, an optional trend EMA, live-plotted entry levels, and configurable visual labels.

Note: This indicator identifies the entry trigger of the Super Envolvente strategy within the #EMCT (El Mejor Club de Trading) methodology. It is not financial advice and does not guarantee results.

What is the “Super Envolvente / Outer Box”

The Super Envolvente is a stricter variant of the classic engulfing candle pattern. A traditional engulfing pattern only requires the current candle’s body to cover the previous candle’s body. The Super Envolvente requires the current candle to cover the previous candle’s entire range — upper wick, lower wick, and body — literally forming a “box” that engulfs the prior candle from the outside.

This produces more reliable entries because:

It confirms the full range of the prior move — including the liquidity extremes marked by the wicks — was absorbed by the current candle.
It filters out weaker body-only engulfing patterns that still leave wicks sticking out — price zones the market hasn’t fully swept.
By additionally requiring price to break the engulfing candle’s body level (not just touch it), the entry trigger only fires when there’s real directional continuation, avoiding premature entries while the candle is still forming.

In the #EMCT methodology, the outer box of the Super Envolvente acts as confirmation of a structural shift or continuation, and the subsequent break of its body level is the operational trigger (entry trigger) that starts trade management.

## Source Code

````pine
//@version=6
// ============================================================================
// Super Envolvente by Emma-Fu #EMCT
// ============================================================================
// Based on a full-candle ("outer box") engulfing engine.
//
// CONCEPT — "Outer Box" (Super Envolvente):
// A standard engulfing pattern only requires the current candle's BODY to
// engulf the previous candle's body. The "outer box" / Super Envolvente is
// stricter: the current candle must engulf the previous candle's ENTIRE
// RANGE — wick to wick, high and low included — not just the body.
//
//   Current high  >=  Previous high (wick)
//   Current low   <=  Previous low  (wick)
//
// Visually, the current candle draws a "box" around the full outer shape of
// the prior candle. This is the trigger condition for entry in the #EMCT
// Super Envolvente strategy: once that outer box is confirmed, price must
// then break back through the engulfing candle's own body extreme (the
// "entry level") in the direction of the setup to actually trigger BUY/SELL.
// ============================================================================

indicator(
     "Super Envolvente by Emma-Fu #EMCT",
     shorttitle = "Super Envolvente by Emma-Fu #EMCT",
     overlay=true,
     max_labels_count=500
)

//==============================================================================
// INPUTS
//==============================================================================

enableBuy  = input.bool(true, "Enable BUY")
enableSell = input.bool(true, "Enable SELL")

entryValidityBars = input.int(
     1,
     "Entry Validity Bars",
     minval=1,
     maxval=20
)

requireOppositeColor = input.bool(
     true,
     "Require Previous Candle Opposite Colour"
)

useTrendFilter = input.bool(
     false,
     "Use EMA Trend Filter"
)

emaLength = input.int(
     34,
     "EMA Length",
     minval=1
)

showEMA = input.bool(
     true,
     "Show EMA"
)

showEntryLevels = input.bool(
     true,
     "Show Entry Levels"
)

showEngulfingLabels = input.bool(
     false,
     "Show Super Envolvente Labels"
)

strictBreakout = input.bool(
     true,
     "Require Price to Break Entry Level"
)

//==============================================================================
// EMA TREND FILTER
//==============================================================================

emaValue = ta.ema(close, emaLength)

bullishTrend =
     not useTrendFilter or
     (close > emaValue and emaValue >= emaValue[1])

bearishTrend =
     not useTrendFilter or
     (close < emaValue and emaValue <= emaValue[1])

//==============================================================================
// CANDLE DIRECTION
//==============================================================================

currentBullish = close > open
currentBearish = close < open

previousBullish = close[1] > open[1]
previousBearish = close[1] < open[1]

//==============================================================================
// OUTER BOX — FULL-RANGE ENGULFING
//
// The current candle's full range (wick to wick) must completely contain
// the previous candle's full range (wick to wick):
//
// Current high >= previous wick high
// Current low  <= previous wick low
//==============================================================================

engulfsPreviousFullCandle =
     high >= high[1] and
     low <= low[1]

//==============================================================================
// BULLISH OUTER BOX (Super Envolvente Alcista)
//==============================================================================

bullishColourCondition =
     not requireOppositeColor or previousBearish

bullishSetup =
     enableBuy and
     currentBullish and
     bullishColourCondition and
     engulfsPreviousFullCandle and
     bullishTrend

//==============================================================================
// BEARISH OUTER BOX (Super Envolvente Bajista)
//==============================================================================

bearishColourCondition =
     not requireOppositeColor or previousBullish

bearishSetup =
     enableSell and
     currentBearish and
     bearishColourCondition and
     engulfsPreviousFullCandle and
     bearishTrend

//==============================================================================
// SAVE BULLISH ENTRY
//
// Body high of a bullish candle = close
//==============================================================================

var float buyEntryLevel = na
var int buySetupBar = na
var bool buyTriggered = false

// Remove expired bullish setup.
if not na(buySetupBar) and bar_index > buySetupBar + entryValidityBars
    buyEntryLevel := na
    buySetupBar := na
    buyTriggered := false

// Store new bullish setup.
if bullishSetup
    buyEntryLevel := math.max(open, close)
    buySetupBar := bar_index
    buyTriggered := false

buySetupActive =
     not na(buySetupBar) and
     bar_index > buySetupBar and
     bar_index <= buySetupBar + entryValidityBars and
     not buyTriggered

// BUY requires a bullish candle body to close above the entry level.
buyBreakCondition =
     currentBullish and
     close > buyEntryLevel

buyEntry =
     buySetupActive and
     buyBreakCondition

if buyEntry
    buyTriggered := true

//==============================================================================
// SAVE BEARISH ENTRY
//
// Body low of a bearish candle = close
//==============================================================================

var float sellEntryLevel = na
var int sellSetupBar = na
var bool sellTriggered = false

// Remove expired bearish setup.
if not na(sellSetupBar) and bar_index > sellSetupBar + entryValidityBars
    sellEntryLevel := na
    sellSetupBar := na
    sellTriggered := false

// Store new bearish setup.
if bearishSetup
    sellEntryLevel := math.min(open, close)
    sellSetupBar := bar_index
    sellTriggered := false

sellSetupActive =
     not na(sellSetupBar) and
     bar_index > sellSetupBar and
     bar_index <= sellSetupBar + entryValidityBars and
     not sellTriggered

// SELL requires a bearish candle body to close below the entry level.
sellBreakCondition =
     currentBearish and
     close < sellEntryLevel

sellEntry =
     sellSetupActive and
     sellBreakCondition

if sellEntry
    sellTriggered := true

//==============================================================================
// DISPLAY
//==============================================================================

plot(
     showEMA ? emaValue : na,
     title="EMA",
     color=color.orange,
     linewidth=2
)

plot(
     showEntryLevels ? buyEntryLevel : na,
     title="BUY Entry Level",
     color=color.lime,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showEntryLevels ? sellEntryLevel : na,
     title="SELL Entry Level",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

// Highlight outer-box (Super Envolvente) candles.
barcolor(
     bullishSetup ? color.aqua :
     bearishSetup ? color.orange :
     na
)

// Bearish Super Envolvente label.
plotshape(
     showEngulfingLabels and bearishSetup,
     title="Super Envolvente Bajista",
     text="ENVOLVENTE BAJISTA",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.orange,
     textcolor=color.white,
     size=size.small
)

// Bullish Super Envolvente label.
plotshape(
     showEngulfingLabels and bullishSetup,
     title="Super Envolvente Alcista",
     text="ENVOLVENTE ALCISTA",
     style=shape.labelup,
     location=location.belowbar,
     color=color.aqua,
     textcolor=color.black,
     size=size.small
)

// BUY entry.
plotshape(
     buyEntry,
     title="BUY Entry",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.black,
     size=size.small
)

// SELL entry.
plotshape(
     sellEntry,
     title="SELL Entry",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small
)

//==============================================================================
// ALERTS
//==============================================================================

alertcondition(
     bullishSetup,
     title="Super Envolvente Alcista Setup",
     message="Super Envolvente (outer box) alcista en {{ticker}} {{interval}}"
)

alertcondition(
     bearishSetup,
     title="Super Envolvente Bajista Setup",
     message="Super Envolvente (outer box) bajista en {{ticker}} {{interval}}"
)

alertcondition(
     buyEntry,
     title="Super Envolvente BUY",
     message="BUY: precio rompió el nivel de entrada de la Super Envolvente alcista en {{ticker}} {{interval}}"
)

alertcondition(
     sellEntry,
     title="Super Envolvente SELL",
     message="SELL: precio rompió el nivel de entrada de la Super Envolvente bajista en {{ticker}} {{interval}}"
)
````
