# VervoortCrossover Zero-Lag [NPR21]

- url: https://www.tradingview.com/script/3lzS3vlI-VervoortCrossover-Zero-Lag-NPR21/
- type: indicator
- pine_id: PUB;04bb8a0e060a4c5baf60f2628582b817
- version: 1.0

## Description

A Pine Script v6 conversion and enhancement of Sylvain Vervoort's published
zero-lag crossover indicator, originally written in ThinkScript and published
by Vervoort in Stocks & Commodities magazine in 2009. Full credit to Sylvain
Vervoort for the underlying mathematical concept.

WHAT IT DOES

The indicator plots two zero-lag TEMA lines and signals when they cross.
Both lines apply Vervoort's zero-lag transform to triple-smoothed EMAs of
two different price inputs:

  Green line: zero-lag TEMA of Typical Price (HLC/3)
  Red line:   zero-lag TEMA of Vervoort's modified Heikin-Ashi close

The zero-lag transform is: ZL = TMA1 + (TMA1 - TMA2), where TMA2 is the
TEMA of TMA1. This is the same compensation method published by Vervoort,
which subtracts smoothing lag from the underlying TEMA without introducing
forward bias or repainting.

A BUY signal fires when the Typical-price line crosses above the
Heikin-Ashi line. A SELL signal fires on the inverse cross. Signals confirm
on bar close and do not repaint.

WHY TWO DIFFERENT INPUTS

The Heikin-Ashi line responds to body-direction shifts in the underlying
candles, while the Typical-price line tracks the volume-weighted center
of each bar's range. The crossover captures the moment where bar-by-bar
direction agreement and centered price flow diverge from one another -
which is Vervoort's stated rationale for the dual-input approach.

ENHANCEMENTS OVER THE ORIGINAL

This version is not a straight port. It adds:

  - Three preset periods (Scalp 21, Vervoort 34, Swing 55) plus a custom
    period input. 34 is Vervoort's published default.
  - Configurable signal markers: triangle arrows, dot at cross, or dot
    above/below bar.
  - Optional BUY/SELL callout labels with ATR-based pushaway positioning
    so labels stay clear of candles, with a connector line from the label
    triangle tip back to the dot at the exact crossover price.
  - Optional momentum fill between the two lines, tinted by which line
    is leading.
  - Configurable label sizes and colors with larger defaults suitable for
    users with vision impairment.
  - Built-in alert conditions for BUY, SELL, and any-signal events.

UNIVERSAL APPLICATION

The indicator is symbol-agnostic and works on any liquid market and any
timeframe. Default settings are tuned for intraday work; the Swing preset
or larger custom periods are appropriate for daily and weekly charts.

NON-REPAINTING

Signals are based on confirmed bar closes via ta.crossover and
ta.crossunder on the zero-lag values. There is no lookahead, no future
data referencing, and no forward-shifted plot offset. Historical signals
on the chart are exactly the signals that fired in real time.

HOW TO USE IT

  STEP 1 - ADD TO CHART
  Apply the indicator to any liquid instrument and timeframe. The two
  zero-lag lines (green and red) will plot directly on price. The faint
  shaded fill between them indicates which line is currently leading
  (green tint when Typical leads, red tint when Heikin-Ashi leads).

  STEP 2 - CHOOSE A PERIOD PRESET
  Match the preset to the timeframe and trading style:
    - Scalp (21):    1-5 minute charts, fast intraday turns
    - Vervoort (34): 5-30 minute charts, balanced (Vervoort's default)
    - Swing (55):    1-4 hour and daily charts, longer holds
    - Custom:        manual period for fine-tuning

  STEP 3 - READ THE SIGNALS
  A BUY fires when the green Typical-price line crosses above the red
  Heikin-Ashi line. A SELL fires on the inverse cross. The dot marks
  the exact crossover price on the green line. The label provides the
  formatted price and direction.

  STEP 4 - CONFIRM BEFORE ACTING
  The crossover is a directional trigger, not a complete trading system.
  Best results come from confirming the signal against:
    - Higher-timeframe trend (do not fade against the dominant trend)
    - Support and resistance levels visible on the chart
    - Volume confirmation on the signal bar
    - Your own risk management (stop placement, position sizing)

  STEP 5 - MANAGE THE EXIT
  This indicator signals entries. Exits should be governed by your own
  rules - a fixed risk-reward ratio, a trailing stop, a structural level,
  or the opposite-direction crossover. The indicator does not generate
  exit signals on its own.

  STEP 6 - SET ALERTS
  Three alert conditions are exposed:
    - Vervoort ZL - Buy Signal
    - Vervoort ZL - Sell Signal
    - Vervoort ZL - Any Signal
  Right-click the indicator name, select "Add alert on Vervoort ZL,"
  and choose the condition. The default message includes ticker and
  timeframe.

  BEST PRACTICES
    - Avoid using the Scalp preset on illiquid or low-volume instruments;
      noise will generate frequent false crossovers.
    - On daily and weekly charts, the Swing preset reduces whipsaw but
      gives later entries - this is the expected trade-off.
    - In strong directional trends, expect counter-trend crossovers to
      fail more often than they succeed. The crossover does not measure
      trend strength on its own.
    - The dot-at-cross marker matches the original ThinkScript appearance
      and is the cleanest visual for chart-heavy users.

SETTINGS WORTH TUNING

  Period Preset: lower for faster signals on shorter timeframes
  Marker Style: Dot at Cross matches the original ThinkScript look
  Show BUY / SELL Callout Labels: turn off if you prefer a cleaner chart
  Label Pushaway (ATR x): raise for more space between labels and candles
  Momentum Fill: toggle off if you find it visually busy

CREDIT

Original concept and ThinkScript implementation: Sylvain Vervoort,
Stocks & Commodities magazine, 2009. This Pine Script v6 conversion and
the listed enhancements are by NPR21.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NPR21
// VervoortCrossover Zero-Lag [NPR21]
// Based on Sylvain Vervoort's original ThinkScript crossover concept (2009)
// Converted, enhanced, and NPR21-standardized for Pine Script v6
// Date: May 24, 2026
// v1.4.6.1 - Added optional connector line from the label\'s triangle tip to
//            the dot at the crossover price. Vertical line on the signal bar
//            same color as the label, toggleable.
// v1.4.6 - Label positioning fixed: anchored ABOVE bar high (SELL) or BELOW
//          bar low (BUY) with ATR offset. Vertical pointer style ensures
//          label body is in clear space, never on candles.

//@version=6
indicator("VervoortCrossover Zero-Lag [NPR21]",
     shorttitle = "Vervoort ZL [NPR21] v1.4.6.1",
     overlay = true,
     max_labels_count = 500,
     max_lines_count  = 500)

// ============================================================================
// === INPUTS =================================================================
// ============================================================================

grpCore    = "Core Settings"
grpVisual  = "Visual Settings"
grpMarker  = "Signal Markers (Dots/Arrows)"
grpCallout = "BUY / SELL Callouts"
grpAlert   = "Alerts"
grpFill    = "Momentum Fill"

// --- Period preset ---
presetChoice = input.string("Vervoort (34)", "Period Preset",
     options  = ["Scalp (21)", "Vervoort (34)", "Swing (55)", "Custom"],
     group    = grpCore,
     tooltip  = "Scalp = faster signals on lower timeframes\nVervoort = Sylvain Vervoort\'s published 34-period setting (balanced)\nSwing = slower signals for higher timeframes\nCustom = use the manual period below")

customPeriod = input.int(34, "Custom Period", minval = 2, maxval = 500, group = grpCore,
     tooltip = "Only used when Preset = Custom")

int period = switch presetChoice
    "Scalp (21)"    => 21
    "Vervoort (34)" => 34
    "Swing (55)"    => 55
    => customPeriod

// --- Visual ---
showTypical = input.bool(true, "Show Typical Price Zero-Lag TEMA (green line)", group = grpVisual)
showHA      = input.bool(true, "Show Heikin-Ashi Zero-Lag TEMA (red line)",     group = grpVisual)
typicalCol  = input.color(color.new(#26a69a, 0), "Typical Line Color", group = grpVisual)
haCol       = input.color(color.new(#ef5350, 0), "Heikin-Ashi Line Color", group = grpVisual)
lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 5, group = grpVisual)

// --- Signal markers (dots/arrows) ---
showMarkers = input.bool(true, "Show Signal Markers", group = grpMarker)
markerStyle = input.string("Dot at Cross", "Marker Style",
     options = ["None", "Triangle Arrow", "Dot Above/Below", "Dot at Cross"],
     group   = grpMarker,
     tooltip = "None = no marker\nTriangle Arrow = directional arrows above/below bar\nDot Above/Below = small dots above/below bar\nDot at Cross = small dot ON the green (typical) zero-lag line at the crossover bar")

dotSizeChoice = input.string("Tiny", "Dot Size",
     options = ["Tiny", "Small"],
     group   = grpMarker)

triangleSize = input.string("small", "Triangle Arrow Size",
     options = ["tiny", "small", "normal", "large", "huge"],
     group   = grpMarker)

buyMarkerCol = input.color(color.new(#00FF00, 0), "Buy Marker Color",  group = grpMarker)
sellMarkerCol= input.color(color.new(#FF0000, 0), "Sell Marker Color", group = grpMarker)

// --- Callout Labels ---
showCallouts        = input.bool(true, "Show BUY / SELL Callout Labels", group = grpCallout,
     tooltip = "Labels anchored ABOVE bar high (SELL) or BELOW bar low (BUY) with ATR pushaway. Vertical pointer reaches back to the bar. Body always in clear space.")

calloutPushAtr      = input.float(1.5, "Label Pushaway (ATR x)", minval = 0.5, maxval = 6.0, step = 0.25, group = grpCallout,
     tooltip = "How far above bar high (SELL) or below bar low (BUY) the label sits, in ATR(14) multiples. Higher = more space from candles. Default 1.5 ATR works for most charts.")

showConnector       = input.bool(true, "Show Connector Line (triangle tip to dot)", group = grpCallout,
     tooltip = "Vertical line connecting the label\'s triangle tip to the dot at the crossover price. Helps the eye trace from the label back to the exact signal point.")

connectorWidth      = input.int(1, "Connector Line Width", minval = 1, maxval = 5, group = grpCallout)

buyText             = input.string("BUY",  "Buy Label Text",  group = grpCallout)
sellText            = input.string("SELL", "Sell Label Text", group = grpCallout)

showPriceOnLabel    = input.bool(true,  "Show Price on Label",       group = grpCallout)
showTimestamp       = input.bool(false, "Show Timestamp on Label",   group = grpCallout)
showTriangleOnLabel = input.bool(true,  "Show Directional Triangle", group = grpCallout)

calloutSize         = input.string("Small", "Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = grpCallout)

buyCalloutCol       = input.color(color.new(#00FF00, 0), "Buy Callout Background",  group = grpCallout)
sellCalloutCol      = input.color(color.new(#FF0000, 0), "Sell Callout Background", group = grpCallout)
buyTextCol          = input.color(color.black, "Buy Text Color",  group = grpCallout)
sellTextCol         = input.color(color.white, "Sell Text Color", group = grpCallout)

// --- Momentum Fill ---
showFill    = input.bool(true, "Show Momentum Fill Between Lines", group = grpFill,
     tooltip = "Faint colored fill between the two zero-lag lines.")
fillOpacity = input.int(85, "Fill Transparency (0=solid, 100=invisible)",
     minval = 50, maxval = 95, group = grpFill)

// ============================================================================
// === ZERO-LAG TEMA FUNCTION =================================================
// ============================================================================

zeroLagTEMA(series float src, simple int len) =>
    e1   = ta.ema(src, len)
    e2   = ta.ema(e1,  len)
    e3   = ta.ema(e2,  len)
    tma1 = 3.0 * e1 - 3.0 * e2 + e3

    e4   = ta.ema(tma1, len)
    e5   = ta.ema(e4,   len)
    e6   = ta.ema(e5,   len)
    tma2 = 3.0 * e4 - 3.0 * e5 + e6

    tma1 + (tma1 - tma2)

// ============================================================================
// === CALCULATIONS ===========================================================
// ============================================================================

typicalPrice = (high + low + close) / 3.0
zlTypical    = zeroLagTEMA(typicalPrice, period)

// Vervoort's modified Heikin-Ashi close
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0
       : ((open[1] + high[1] + low[1] + close[1]) / 4.0 + haOpen[1]) / 2.0

haClose = ((open + high + low + close) / 4.0 + haOpen + math.max(high, haOpen) + math.min(low, haOpen)) / 4.0
zlHA    = zeroLagTEMA(haClose, period)

buySignal  = ta.crossover (zlTypical, zlHA)
sellSignal = ta.crossunder(zlTypical, zlHA)

atr14 = ta.atr(14)

// ============================================================================
// === PRICE FORMATTING HELPER ================================================
// ============================================================================

formatPrice(float value) =>
    string raw = str.tostring(value, format.mintick)
    string[] parts = str.split(raw, ".")
    string intPart = array.get(parts, 0)
    string decPart = array.size(parts) > 1 ? "." + array.get(parts, 1) : ""
    int len = str.length(intPart)
    if len <= 3
        "$" + intPart + decPart
    else
        string formatted = ""
        for i = 0 to len - 1
            string char = str.substring(intPart, i, i + 1)
            formatted := formatted + char
            int remaining = len - i - 1
            if remaining > 0 and remaining % 3 == 0 and char != "-"
                formatted := formatted + ","
        "$" + formatted + decPart

// ============================================================================
// === PLOTS ==================================================================
// ============================================================================

pTypical = plot(showTypical ? zlTypical : na, "Typical Zero-Lag TEMA",
     color = typicalCol, linewidth = lineWidth)
pHA      = plot(showHA ? zlHA : na, "Heikin-Ashi Zero-Lag TEMA",
     color = haCol, linewidth = lineWidth)

fillColor = zlTypical >= zlHA
     ? color.new(typicalCol, fillOpacity)
     : color.new(haCol, fillOpacity)
fill(pTypical, pHA, color = showFill ? fillColor : na, title = "Momentum Fill")

// ============================================================================
// === DOT / TRIANGLE MARKERS =================================================
// ============================================================================

useDotAboveBelow = showMarkers and markerStyle == "Dot Above/Below"
useDotAtCross    = showMarkers and markerStyle == "Dot at Cross"
useTriangle      = showMarkers and markerStyle == "Triangle Arrow"

plotshape(useDotAboveBelow and buySignal and dotSizeChoice == "Tiny"  ? low : na,
     "Buy Dot (Above/Below) Tiny",  shape.circle, location.belowbar, buyMarkerCol, size = size.tiny)
plotshape(useDotAboveBelow and buySignal and dotSizeChoice == "Small" ? low : na,
     "Buy Dot (Above/Below) Small", shape.circle, location.belowbar, buyMarkerCol, size = size.small)

plotshape(useDotAboveBelow and sellSignal and dotSizeChoice == "Tiny"  ? high : na,
     "Sell Dot (Above/Below) Tiny",  shape.circle, location.abovebar, sellMarkerCol, size = size.tiny)
plotshape(useDotAboveBelow and sellSignal and dotSizeChoice == "Small" ? high : na,
     "Sell Dot (Above/Below) Small", shape.circle, location.abovebar, sellMarkerCol, size = size.small)

plotshape(useDotAtCross and buySignal and dotSizeChoice == "Tiny"  ? zlTypical : na,
     "Buy Dot (At Cross) Tiny",  shape.circle, location.absolute, buyMarkerCol, size = size.tiny)
plotshape(useDotAtCross and buySignal and dotSizeChoice == "Small" ? zlTypical : na,
     "Buy Dot (At Cross) Small", shape.circle, location.absolute, buyMarkerCol, size = size.small)

plotshape(useDotAtCross and sellSignal and dotSizeChoice == "Tiny"  ? zlTypical : na,
     "Sell Dot (At Cross) Tiny",  shape.circle, location.absolute, sellMarkerCol, size = size.tiny)
plotshape(useDotAtCross and sellSignal and dotSizeChoice == "Small" ? zlTypical : na,
     "Sell Dot (At Cross) Small", shape.circle, location.absolute, sellMarkerCol, size = size.small)

plotshape(useTriangle and buySignal and triangleSize == "tiny"   ? low : na,
     "Buy Triangle Tiny",   shape.triangleup, location.belowbar, buyMarkerCol, size = size.tiny)
plotshape(useTriangle and buySignal and triangleSize == "small"  ? low : na,
     "Buy Triangle Small",  shape.triangleup, location.belowbar, buyMarkerCol, size = size.small)
plotshape(useTriangle and buySignal and triangleSize == "normal" ? low : na,
     "Buy Triangle Normal", shape.triangleup, location.belowbar, buyMarkerCol, size = size.normal)
plotshape(useTriangle and buySignal and triangleSize == "large"  ? low : na,
     "Buy Triangle Large",  shape.triangleup, location.belowbar, buyMarkerCol, size = size.large)
plotshape(useTriangle and buySignal and triangleSize == "huge"   ? low : na,
     "Buy Triangle Huge",   shape.triangleup, location.belowbar, buyMarkerCol, size = size.huge)

plotshape(useTriangle and sellSignal and triangleSize == "tiny"   ? high : na,
     "Sell Triangle Tiny",   shape.triangledown, location.abovebar, sellMarkerCol, size = size.tiny)
plotshape(useTriangle and sellSignal and triangleSize == "small"  ? high : na,
     "Sell Triangle Small",  shape.triangledown, location.abovebar, sellMarkerCol, size = size.small)
plotshape(useTriangle and sellSignal and triangleSize == "normal" ? high : na,
     "Sell Triangle Normal", shape.triangledown, location.abovebar, sellMarkerCol, size = size.normal)
plotshape(useTriangle and sellSignal and triangleSize == "large"  ? high : na,
     "Sell Triangle Large",  shape.triangledown, location.abovebar, sellMarkerCol, size = size.large)
plotshape(useTriangle and sellSignal and triangleSize == "huge"   ? high : na,
     "Sell Triangle Huge",   shape.triangledown, location.abovebar, sellMarkerCol, size = size.huge)

// ============================================================================
// === CALLOUT LABELS =========================================================
// ============================================================================
// Simple and direct:
//   SELL: anchor at (high + ATR * pushFactor), style = label_down
//         → pointer at bottom of label points DOWN to the bar
//         → label body extends UP from that anchor — fully clear of price
//   BUY:  anchor at (low - ATR * pushFactor),  style = label_up
//         → pointer at top of label points UP to the bar
//         → label body extends DOWN from that anchor — fully clear of price
// ============================================================================

calloutSizeValue = switch calloutSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

if showCallouts and buySignal
    string txt = ""
    if showTriangleOnLabel
        txt := txt + "▲ "
    txt := txt + buyText
    if showPriceOnLabel
        txt := txt + "\n" + formatPrice(zlTypical)
    if showTimestamp
        txt := txt + "\n" + str.format_time(time, "HH:mm", syminfo.timezone)

    float anchorY = low - (atr14 * calloutPushAtr)
    label.new(bar_index, anchorY, text = txt,
         style    = label.style_label_up,
         color    = buyCalloutCol,
         textcolor= buyTextCol,
         size     = calloutSizeValue,
         yloc     = yloc.price,
         xloc     = xloc.bar_index)

    // Connector: from label's top triangle tip (anchorY) UP to the dot at zlTypical
    if showConnector
        line.new(bar_index, anchorY, bar_index, zlTypical,
             xloc  = xloc.bar_index,
             color = buyCalloutCol,
             width = connectorWidth)

if showCallouts and sellSignal
    string txt = ""
    if showTriangleOnLabel
        txt := txt + "▼ "
    txt := txt + sellText
    if showPriceOnLabel
        txt := txt + "\n" + formatPrice(zlTypical)
    if showTimestamp
        txt := txt + "\n" + str.format_time(time, "HH:mm", syminfo.timezone)

    float anchorY = high + (atr14 * calloutPushAtr)
    label.new(bar_index, anchorY, text = txt,
         style    = label.style_label_down,
         color    = sellCalloutCol,
         textcolor= sellTextCol,
         size     = calloutSizeValue,
         yloc     = yloc.price,
         xloc     = xloc.bar_index)

    // Connector: from label's bottom triangle tip (anchorY) DOWN to the dot at zlTypical
    if showConnector
        line.new(bar_index, anchorY, bar_index, zlTypical,
             xloc  = xloc.bar_index,
             color = sellCalloutCol,
             width = connectorWidth)

// ============================================================================
// === ALERTS =================================================================
// ============================================================================
alertcondition(buySignal,  title = "Vervoort ZL - Buy Signal",
     message = "Vervoort Zero-Lag Crossover BUY on {{ticker}} {{interval}}")
alertcondition(sellSignal, title = "Vervoort ZL - Sell Signal",
     message = "Vervoort Zero-Lag Crossover SELL on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal, title = "Vervoort ZL - Any Signal",
     message = "Vervoort Zero-Lag Crossover signal on {{ticker}} {{interval}}")

// ============================================================================
// === END OF SCRIPT ==========================================================
// ============================================================================
````
