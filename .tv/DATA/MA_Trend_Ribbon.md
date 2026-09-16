<!-- tradingview-pine-id: PUB;6626f3c2cb624830aa95adb6ab0c597f -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# MA Trend Ribbon

Source: https://www.tradingview.com/script/hN3rPHlV-MA-Trend-Ribbon/

## Description

# MA Trend Ribbon

## Overview

MA Trend Ribbon is a trend-following overlay that sits directly on the price chart. It draws a band made of six moving-average lines stacked from fastest to slowest. The band fills with color to show whether the market is leaning up or down, and it prints clear BUY and SELL labels at the moments the trend flips. It can also read the entire ribbon from a higher timeframe, so a lower-timeframe chart can be traded in line with the broader trend. The goal is a single, easy-to-read picture of trend direction and the points where that direction changes.

## What It Shows

- **The ribbon** — six moving averages of increasing length, drawn together as a colored band. When the band tilts and expands upward the trend is up; when it rolls over and expands downward the trend is down. A band that pinches flat signals a market with little direction.
- **The color** — the entire ribbon turns one color for an up-trend and another for a down-trend, so direction reads at a glance without studying the individual lines.
- **The labels** — a BUY label marks the bar where the trend turns up, and a SELL label marks the bar where the trend turns down. By default the labels ride the ribbon itself, sitting just outside the band; they can instead be pinned to the price candles. A label always appears on the same bar the ribbon changes color, so the two never disagree.
- **Optional bar coloring** — price bars can be tinted to match the trend for an even faster read.
- **Alerts** — built-in alerts announce each new BUY and SELL so the chart does not have to be watched constantly.

## The Structure Timeframe

The ribbon can be calculated on a timeframe other than the one being viewed. Left blank, it simply uses the chart's own timeframe. Set to a higher timeframe, the whole ribbon — its lines, its color, and its signals — is drawn from that broader view and displayed on the current chart. This makes it possible to watch a fast chart while keeping every reading aligned to a slower, more meaningful trend.

Two things are worth knowing when a higher timeframe is selected. The ribbon will look stepped, because each higher-timeframe value holds flat across the smaller bars until the larger bar completes. And the most recent portion can shift while the current higher-timeframe bar is still forming, settling once that bar closes; the confirm-on-close option keeps alerts from acting before it settles.

## How Direction Is Decided

The ribbon offers two ways to define the trend, chosen from a single setting:

- **Ribbon Flip** — the trend is up while the fastest line sits above the slowest line, and down when it drops below. This waits for the whole ribbon to turn over, giving steadier, less frequent signals.
- **Fastest MA Slope** — the trend is up the moment the fastest line starts rising and down the moment it starts falling. This reacts earlier and produces more signals.

Whichever method is selected controls both the ribbon color and the labels, keeping the visual and the signals in step.

## Choice of Averages

The ribbon is not limited to one style of average. A dropdown selects the type used for all six lines, ranging from smooth-and-steady to fast-and-reactive. Smoother types change direction later but hold trends more calmly. Faster types change direction sooner but shift more often. Because every line uses the same base length regardless of the type chosen, the base length usually deserves a fresh look after switching types, since the same number behaves differently from one average to the next.

The default type is volume-weighted, which leans on the bars that trade the most. On symbols whose data feed does not carry real volume, a volume-weighted average may behave unpredictably; on those markets one of the price-only types is the better choice.

## Optional Polish

Two extra touches can be switched on to make trends easier to judge, and both are off by default so the standard look stays clean:

- **Momentum-scaled ribbon** — the fill grows more solid as the band expands during a strong trend and fades as it compresses in a quiet market, so strong moves stand out and flat stretches recede.
- **Price-to-ribbon fill** — a soft shade fills the gap between price and the ribbon, making pullbacks toward the band easy to spot.

---

## User Inputs

### Structure

- **Structure Timeframe** — the timeframe the entire ribbon is calculated on. Blank uses the chart's own timeframe. A higher selection draws that higher timeframe's ribbon and signals on the current chart. Default is blank.

### Moving Average

- **Source** — the price used for the calculation. Default is the closing price. Other choices include the open, high, low, or an average of these.
- **MA Type** — the style of average used for every line in the ribbon. Ten options are available, from the smoothest and steadiest to the fastest and most reactive: Simple, Exponential, Weighted, Hull, Wilder's, Volume-Weighted, Double Exponential, Triple Exponential, Arnaud Legoux, and Least Squares. Default is Volume-Weighted.
- **Base MA Length** — the length of the fastest line in the ribbon. Smaller values make the whole ribbon quicker to react; larger values make it slower and smoother. Default is 40.
- **Ribbon Spacing** — the amount added to each line's length as the ribbon steps from fastest to slowest. Smaller values pack the six lines into a tight band; larger values spread them apart so the band widens and narrows more dramatically. Default is 8.

### Advanced MA Inputs

These settings apply only to specific average types and are ignored by the rest.

- **ALMA Offset** — applies only when the Arnaud Legoux type is selected. Higher values make that average track price more closely; lower values make it smoother. Default is 0.85.
- **ALMA Sigma** — applies only when the Arnaud Legoux type is selected. Larger values produce a smoother line; smaller values follow price more closely. Default is 6.
- **LSMA Offset** — applies only when the Least Squares type is selected. Shifts that line forward or backward by a set number of bars. Default is 0.

### Signals

- **Signal Trigger** — chooses how the trend is defined, either Ribbon Flip (steadier, later) or Fastest MA Slope (earlier, more frequent). Default is Ribbon Flip.
- **Show Buy/Sell Labels** — turns the BUY and SELL labels on or off. Default is on.
- **Label Position** — chooses where labels sit. Ribbon attaches them to the band, just below the lowest line for a buy and just above the highest for a sell, so they travel with the ribbon. Bar pins them to the candles instead, below the low for a buy and above the high for a sell. Default is Ribbon.
- **Label ATR Offset** — sets how far a label sits from the ribbon in Ribbon mode, scaled to recent price movement so the gap stays consistent in calm and volatile markets. A value of zero places the label right on the band; larger values push it further away. Has no effect in Bar mode. Default is 0.5.
- **Color Bars By Trend** — tints the price bars to match the current trend color. Default is off.
- **Confirm Signals On Bar Close** — when on, alerts wait until a bar has fully closed before firing, so a signal cannot appear and then disappear before the bar finishes. Labels still show while the bar is forming. Default is on.

### Style

- **Bullish Color** — the color of the ribbon and labels during an up-trend.
- **Bearish Color** — the color of the ribbon and labels during a down-trend.
- **Ribbon Fill Transparency** — how see-through the shaded band is, from solid to invisible. Default is 78.
- **Ribbon Line Width** — the thickness of each ribbon line. Default is 1.
- **Label Size** — the text size of the BUY and SELL labels, from tiny to large. Default is Normal.

### Visual Polish

- **Momentum-Scaled Ribbon** — when on, the fill grows more solid as the ribbon expands and fades as it compresses, so trend strength is reflected in the shading. Default is off.
- **Strong-Trend Fill Transparency** — the solidity of the fill at full ribbon expansion when the scaling above is on. Lower is more solid. Default is 38.
- **Momentum Normalization Length** — how many bars are used to judge how wide the ribbon is now compared with its recent range. Shorter values react faster to changes in strength; longer values give a steadier scale. Default is 100.
- **Fill Price To Ribbon** — shades the gap between price and the ribbon to highlight pullbacks. Default is off.
- **Price Fill Transparency** — how subtle that price-to-ribbon shading is. Higher is fainter. Default is 88.

---

## Best Use

The ribbon works best as a trend filter rather than a stand-alone entry system. Trends are followed most cleanly when trades lean in the direction of the ribbon color, using the labels to mark the turning points. Reading the ribbon from a higher Structure Timeframe while entering on a faster chart is a natural way to keep trades aligned with the larger trend. In quiet, sideways markets the ribbon will change color back and forth and produce more frequent, less reliable signals; the Ribbon Flip setting and a wider spacing reduce this, at the cost of later entries. Faster average types and tighter spacing suit active, short-term charts, while smoother types and wider spacing suit calmer, longer-term views.

---

## Source Code

````pine
//@version=6
indicator("MA Trend Ribbon", overlay=true, max_labels_count=500)

// =====================================================================
// INPUTS
// =====================================================================
grpStructure = "Structure"
structureTF  = input.timeframe("", "Structure Timeframe", group=grpStructure, tooltip="Timeframe the entire ribbon is calculated on. Leave blank to use the chart's own timeframe. Selecting a higher timeframe (e.g. 60, 240, D) draws that higher timeframe's ribbon and signals on the current chart, so a lower-timeframe chart can be traded in line with a broader structure.\n\nNote: values from a higher timeframe update while its current bar is still forming and settle once that bar closes.")

grpMA = "Moving Average"
src        = input.source(close, "Source", group=grpMA, tooltip="Price series the moving averages are calculated from.")
maType     = input.string("HMA", "MA Type", options=["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA", "DEMA", "TEMA", "ALMA", "LSMA"], group=grpMA, tooltip="Moving-average type used for every line in the ribbon.\n\n• SMA — Simple. Equal weight, smoothest, most lag.\n• EMA — Exponential. Weights recent price more.\n• WMA — Weighted. Linear front-weighting.\n• HMA — Hull. Very low lag, fast turns (default).\n• RMA — Wilder's / SMMA. Heavy smoothing, used in RSI/ATR.\n• VWMA — Volume-weighted. Emphasizes high-volume bars.\n• DEMA — Double EMA. Faster than EMA, less lag.\n• TEMA — Triple EMA. Even faster, more responsive.\n• ALMA — Arnaud Legoux. Gaussian-weighted, low lag and low noise (uses the Offset/Sigma below).\n• LSMA — Least Squares. Linear-regression line, minimal lag (uses the Offset below).")
baseLength = input.int(40, "Base MA Length", minval=1, group=grpMA, tooltip="Length of the fastest (innermost) moving average in the ribbon. Every other ribbon line is this length plus a multiple of the spacing below.")
spacing    = input.int(8, "Ribbon Spacing", minval=1, group=grpMA, tooltip="Bars added to each successive ribbon line's length. Larger values spread the ribbon out; smaller values pack it tighter. The ribbon has six lines: Base, Base+Spacing, ... up to Base + 5×Spacing.")

grpAdvMA = "Advanced MA Inputs"
almaOffset = input.float(0.85, "ALMA Offset", minval=0, maxval=1, step=0.05, group=grpAdvMA, tooltip="Only affects the ALMA type. Position of the Gaussian window: higher (toward 1) makes ALMA more responsive and closer to price; lower (toward 0) makes it smoother. Ignored by all other MA types.")
almaSigma  = input.float(6.0, "ALMA Sigma", minval=0.1, step=0.5, group=grpAdvMA, tooltip="Only affects the ALMA type. Sharpness of the Gaussian window: larger values give a smoother, more filtered line; smaller values follow price more closely. Ignored by all other MA types.")
lsmaOffset = input.int(0, "LSMA Offset", group=grpAdvMA, tooltip="Only affects the LSMA (Least Squares) type. Shifts the regression line forward or backward by this many bars. 0 uses the standard least-squares value. Ignored by all other MA types.")

grpSignal = "Signals"
showSignals  = input.bool(true, "Show Buy/Sell Labels", group=grpSignal, tooltip="Draws BUY and SELL labels on the bar where the trend flips.")
signalMode   = input.string("Ribbon Flip", "Signal Trigger", options=["Ribbon Flip", "Fastest MA Slope"], group=grpSignal, tooltip="Ribbon Flip: buy/sell when the fastest MA crosses the slowest one — the whole ribbon flips. Slower and less frequent, fewer false signals.\n\nFastest MA Slope: buy/sell the moment the fastest MA turns up or down. Earlier, but more signals and more noise.\n\nThe ribbon color always matches whichever trend definition this mode uses, so a label appears exactly when the ribbon changes color.")
labelPos     = input.string("Ribbon", "Label Position", options=["Bar", "Ribbon"], group=grpSignal, tooltip="Bar: labels hug the price candles — BUY just below the bar's low, SELL just above the bar's high.\n\nRibbon: labels attach to the ribbon instead — BUY below the lowest ribbon line, SELL above the highest — so they ride with the ribbon rather than the candles.")
labelOffsetMult = input.float(0.5, "Label ATR Offset", minval=0, step=0.1, group=grpSignal, tooltip="Gap between a label and the ribbon in Ribbon position mode, measured in multiples of ATR(14). 0 places the label right on the ribbon edge; larger values push it further away. Has no effect in Bar position mode.")
colorBars    = input.bool(false, "Color Bars By Trend", group=grpSignal, tooltip="Recolors price bars to match the current ribbon trend.")
confirmClose = input.bool(true, "Confirm Signals On Bar Close", group=grpSignal, tooltip="When ON, alerts only fire once the bar has closed, so a signal cannot appear and then vanish intrabar. Labels still draw on the live bar for visibility, but the alert waits for the close.")

grpStyle = "Style"
bullColor     = input.color(#00c3ff, "Bullish Color", group=grpStyle)
bearColor     = input.color(#ff0062, "Bearish Color", group=grpStyle)
ribbonTransp  = input.int(78, "Ribbon Fill Transparency", minval=0, maxval=100, group=grpStyle, tooltip="Transparency of the shaded ribbon fill when the trend is weak or the ribbon is compressed. 0 is opaque, 100 is invisible. With Momentum-Scaled Ribbon on, this is the faded end the ribbon returns to in flat markets.")
baseLineWidth = input.int(3, "Base Line Width", minval=1, maxval=4, group=grpStyle, tooltip="Pixel width of the fastest (innermost) ribbon line, set independently from the other lines.")
lineWidth     = input.int(1, "Ribbon Line Width", minval=1, maxval=4, group=grpStyle, tooltip="Pixel width of the remaining ribbon lines (MA 2 through MA 6).")
labelSizeIn   = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpStyle, tooltip="Text size of the BUY and SELL labels.")

grpVisual = "Visual Polish"
momentumColor   = input.bool(false, "Momentum-Scaled Ribbon", group=grpVisual, tooltip="When ON, the ribbon fill grows more solid as the ribbon expands (strong trend) and fades as it compresses (weak or ranging). Strong trends look strong; flat markets recede. When OFF, the fill uses a single fixed transparency.")
strongTransp    = input.int(38, "Strong-Trend Fill Transparency", minval=0, maxval=100, group=grpVisual, tooltip="Fill transparency at maximum ribbon expansion when Momentum-Scaled Ribbon is on. Lower is more solid. As the trend weakens the fill fades toward the standard Ribbon Fill Transparency.")
momentumLen     = input.int(100, "Momentum Normalization Length", minval=10, group=grpVisual, tooltip="How many bars are used to gauge how wide the ribbon is right now relative to its recent range. Shorter values react faster to shifts in trend strength; longer values give a steadier scale.")
showPriceFill   = input.bool(false, "Fill Price To Ribbon", group=grpVisual, tooltip="Shades the gap between price and the fastest ribbon line, making pullbacks toward the ribbon easy to see. Colored by the current trend.")
priceFillTransp = input.int(88, "Price Fill Transparency", minval=0, maxval=100, group=grpVisual, tooltip="Transparency of the price-to-ribbon shading. Higher is more subtle.")

grpInfo = "Info Box"
showInfoBox   = input.bool(true, "Show Info Box", group=grpInfo, tooltip="Shows a small summary box on the chart with the current trend and settings.")
infoDetail    = input.string("Medium", "Info Box Detail", options=["Small", "Medium", "Large"], group=grpInfo, tooltip="How much the box shows.\n\n• Small — trend and MA type.\n• Medium — adds timeframe, signal mode, and lengths.\n• Large — adds ribbon expansion, trend strength, bars since the last flip, and the last signal.")
infoPos       = input.string("Top Right", "Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpInfo, tooltip="Where the box sits on the chart.")
infoTextSize  = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpInfo, tooltip="Text size inside the box.")
infoBg        = input.color(color.new(#131722, 10), "Background", group=grpInfo, tooltip="Background color of the box body.")
infoHeaderBg  = input.color(color.new(#2962ff, 10), "Header Background", group=grpInfo, tooltip="Background color of the box header row.")
infoText      = input.color(color.white, "Text Color", group=grpInfo, tooltip="Color of the values shown in the right column and the header.")
infoLabelText = input.color(color.new(#b2b5be, 0), "Label Text Color", group=grpInfo, tooltip="Color of the metric names shown in the left column.")
infoBorder    = input.color(color.new(color.gray, 40), "Border Color", group=grpInfo, tooltip="Color of the box border.")

// =====================================================================
// HELPERS
// =====================================================================
f_hma(float source, simple int length) =>
    int halfLen = math.max(1, math.floor(length / 2))
    int sqrtLen = math.max(1, math.round(math.sqrt(length)))
    ta.wma(2 * ta.wma(source, halfLen) - ta.wma(source, length), sqrtLen)

// Dispatches to the selected moving-average type. maType is a constant
// input, so exactly one branch runs on every bar and each ta.* series
// keeps correct internal state.
f_ma(string mtype, float source, simple int length, simple float aOffset, simple float aSigma, simple int lOffset) =>
    float result = na
    if mtype == "SMA"
        result := ta.sma(source, length)
    else if mtype == "EMA"
        result := ta.ema(source, length)
    else if mtype == "WMA"
        result := ta.wma(source, length)
    else if mtype == "HMA"
        result := f_hma(source, length)
    else if mtype == "RMA"
        result := ta.rma(source, length)
    else if mtype == "VWMA"
        result := ta.vwma(source, length)
    else if mtype == "DEMA"
        float e1 = ta.ema(source, length)
        float e2 = ta.ema(e1, length)
        result := 2 * e1 - e2
    else if mtype == "TEMA"
        float e1 = ta.ema(source, length)
        float e2 = ta.ema(e1, length)
        float e3 = ta.ema(e2, length)
        result := 3 * (e1 - e2) + e3
    else if mtype == "ALMA"
        result := ta.alma(source, length, aOffset, aSigma)
    else if mtype == "LSMA"
        result := ta.linreg(source, length, lOffset)
    else
        result := f_hma(source, length)
    result

f_label_size(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_table_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.bottom_right

// Identifies which built-in price field a source input points to.
f_src_name(float s) =>
    s == close ? "Close" : s == open ? "Open" : s == high ? "High" : s == low ? "Low" : s == hl2 ? "HL2" : s == hlc3 ? "HLC3" : s == ohlc4 ? "OHLC4" : s == hlcc4 ? "HLCC4" : "Custom"

// =====================================================================
// RIBBON MOVING AVERAGES (6 lines)
// Calculated on the Structure Timeframe (blank = chart timeframe).
// =====================================================================
structureTFres = structureTF == "" ? timeframe.period : structureTF

[ma1, ma2, ma3, ma4, ma5, ma6] = request.security(syminfo.tickerid, structureTFres, [f_ma(maType, src, baseLength, almaOffset, almaSigma, lsmaOffset), f_ma(maType, src, baseLength + spacing, almaOffset, almaSigma, lsmaOffset), f_ma(maType, src, baseLength + spacing * 2, almaOffset, almaSigma, lsmaOffset), f_ma(maType, src, baseLength + spacing * 3, almaOffset, almaSigma, lsmaOffset), f_ma(maType, src, baseLength + spacing * 4, almaOffset, almaSigma, lsmaOffset), f_ma(maType, src, baseLength + spacing * 5, almaOffset, almaSigma, lsmaOffset)], lookahead=barmerge.lookahead_off)

// =====================================================================
// TREND STATE + SIGNALS
// Ribbon color and signals share one trend definition, so the label
// always fires on the same bar the ribbon changes color.
// =====================================================================
trendUp = signalMode == "Ribbon Flip" ? ma1 > ma6 : ma1 > ma1[1]

buySignal  = trendUp and not trendUp[1]
sellSignal = not trendUp and trendUp[1]

rColor = trendUp ? bullColor : bearColor

// =====================================================================
// MOMENTUM-SCALED FILL TRANSPARENCY
// Ribbon width relative to its recent range gauges trend strength.
// A wide (expanding) ribbon fills solid; a pinched ribbon fades.
// =====================================================================
ribbonWidth = math.abs(ma1 - ma6)
maxWidth    = ta.highest(ribbonWidth, momentumLen)
intensity   = maxWidth > 0 ? math.min(1.0, ribbonWidth / maxWidth) : 0.0
fillTransp  = momentumColor ? math.round(ribbonTransp - intensity * (ribbonTransp - strongTransp)) : ribbonTransp
fillTransp := math.max(0, math.min(100, fillTransp))

// =====================================================================
// PLOTTING — RIBBON
// Inner line is most opaque; outer lines fade for depth.
// =====================================================================
p1 = plot(ma1, "MA 1 (fastest)", color=color.new(rColor, 0),  linewidth=baseLineWidth)
p2 = plot(ma2, "MA 2",           color=color.new(rColor, 12), linewidth=lineWidth)
p3 = plot(ma3, "MA 3",           color=color.new(rColor, 24), linewidth=lineWidth)
p4 = plot(ma4, "MA 4",           color=color.new(rColor, 36), linewidth=lineWidth)
p5 = plot(ma5, "MA 5",           color=color.new(rColor, 48), linewidth=lineWidth)
p6 = plot(ma6, "MA 6 (slowest)", color=color.new(rColor, 60), linewidth=lineWidth)

// Invisible anchor for the price-to-ribbon fill (line itself not drawn).
pPrice = plot(showPriceFill ? src : na, "Price (fill anchor)", color=na, editable=false)

// Price-to-ribbon shading (subtle, trend-colored).
fill(pPrice, p1, color=showPriceFill ? color.new(rColor, priceFillTransp) : na)

// Ribbon band fills (momentum-scaled when enabled).
fill(p1, p2, color=color.new(rColor, fillTransp))
fill(p2, p3, color=color.new(rColor, fillTransp))
fill(p3, p4, color=color.new(rColor, fillTransp))
fill(p4, p5, color=color.new(rColor, fillTransp))
fill(p5, p6, color=color.new(rColor, fillTransp))

// =====================================================================
// SIGNAL LABELS
// Bar mode hugs the candles; Ribbon mode rides the outer ribbon edge.
// =====================================================================
labelOffset = ta.atr(14) * labelOffsetMult
ribbonLow   = math.min(ma1, ma2, ma3, ma4, ma5, ma6)
ribbonHigh  = math.max(ma1, ma2, ma3, ma4, ma5, ma6)

if showSignals and buySignal
    float yBuy = labelPos == "Ribbon" ? ribbonLow - labelOffset : low
    label.new(bar_index, yBuy, "BUY", yloc = labelPos == "Ribbon" ? yloc.price : yloc.belowbar, style=label.style_label_up, color=bullColor, textcolor=color.white, size=f_label_size(labelSizeIn))
if showSignals and sellSignal
    float ySell = labelPos == "Ribbon" ? ribbonHigh + labelOffset : high
    label.new(bar_index, ySell, "SELL", yloc = labelPos == "Ribbon" ? yloc.price : yloc.abovebar, style=label.style_label_down, color=bearColor, textcolor=color.white, size=f_label_size(labelSizeIn))

// =====================================================================
// BAR COLORING
// =====================================================================
barcolor(colorBars ? rColor : na)

// =====================================================================
// INFO BOX
// =====================================================================
var string lastSig = "—"
if buySignal
    lastSig := "Buy"
else if sellSignal
    lastSig := "Sell"

flipEvent = buySignal or sellSignal
barsSince = ta.barssince(flipEvent)
expanding = ribbonWidth > ribbonWidth[1]

var table infoTbl = na
if barstate.islast
    if not na(infoTbl)
        table.delete(infoTbl)
        infoTbl := na
    if showInfoBox
        int nRows = infoDetail == "Small" ? 4 : infoDetail == "Medium" ? 7 : 11
        infoTbl := table.new(f_table_pos(infoPos), 2, nRows, bgcolor=infoBg, border_color=infoBorder, border_width=1)
        infoSz = f_label_size(infoTextSize)

        bool isMed   = infoDetail == "Medium" or infoDetail == "Large"
        bool isLarge = infoDetail == "Large"

        string trendText = trendUp ? "BULLISH" : "BEARISH"
        string tfText    = structureTF == "" ? "Chart" : structureTF
        string srcText   = f_src_name(src)
        color  lastCol   = lastSig == "Buy" ? bullColor : lastSig == "Sell" ? bearColor : infoText

        // Header
        table.cell(infoTbl, 0, 0, "MA TREND RIBBON", text_color=infoText, bgcolor=infoHeaderBg, text_size=infoSz)
        table.merge_cells(infoTbl, 0, 0, 1, 0)

        // Rows follow the input panel order top-to-bottom.
        int r = 1

        // Trend (headline)
        table.cell(infoTbl, 0, r, "Trend", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
        table.cell(infoTbl, 1, r, trendText, text_color=rColor, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
        r += 1

        // Structure Timeframe
        if isMed
            table.cell(infoTbl, 0, r, "Timeframe", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
            table.cell(infoTbl, 1, r, tfText, text_color=infoText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
            r += 1

        // MA Source
        table.cell(infoTbl, 0, r, "MA Source", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
        table.cell(infoTbl, 1, r, srcText, text_color=infoText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
        r += 1

        // MA Type
        table.cell(infoTbl, 0, r, "MA Type", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
        table.cell(infoTbl, 1, r, maType, text_color=infoText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
        r += 1

        // Length / Spacing
        if isMed
            table.cell(infoTbl, 0, r, "Length / Spacing", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
            table.cell(infoTbl, 1, r, str.tostring(baseLength) + " / " + str.tostring(spacing), text_color=infoText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
            r += 1

        // Signal
        if isMed
            table.cell(infoTbl, 0, r, "Signal", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
            table.cell(infoTbl, 1, r, showSignals ? signalMode : "Off", text_color=showSignals ? infoText : infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
            r += 1

        // Last Signal
        if isLarge
            table.cell(infoTbl, 0, r, "Last Signal", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
            table.cell(infoTbl, 1, r, lastSig, text_color=lastCol, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
            r += 1

        // Bars Since Flip
        if isLarge
            table.cell(infoTbl, 0, r, "Bars Since Flip", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
            table.cell(infoTbl, 1, r, na(barsSince) ? "—" : str.tostring(barsSince), text_color=infoText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
            r += 1

        // Ribbon expansion
        if isLarge
            table.cell(infoTbl, 0, r, "Ribbon", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
            table.cell(infoTbl, 1, r, expanding ? "Expanding" : "Compressing", text_color=expanding ? rColor : infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
            r += 1

        // Strength
        if isLarge
            table.cell(infoTbl, 0, r, "Strength", text_color=infoLabelText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_left)
            table.cell(infoTbl, 1, r, str.tostring(math.round(intensity * 100)) + "%", text_color=infoText, bgcolor=infoBg, text_size=infoSz, text_halign=text.align_right)
            r += 1

// =====================================================================
// ALERTS
// =====================================================================
alertcondition(buySignal,  "Ribbon Buy",  "MA Trend Ribbon flipped bullish — BUY")
alertcondition(sellSignal, "Ribbon Sell", "MA Trend Ribbon flipped bearish — SELL")

alertFreq = confirmClose ? alert.freq_once_per_bar_close : alert.freq_once_per_bar
if buySignal
    alert("MA Trend Ribbon flipped bullish — BUY", alertFreq)
if sellSignal
    alert("MA Trend Ribbon flipped bearish — SELL", alertFreq)
````
