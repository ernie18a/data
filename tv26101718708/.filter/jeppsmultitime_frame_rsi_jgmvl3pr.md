# Jepps_Multitime Frame RSI

- url: https://www.tradingview.com/script/jGmvL3pR-Jepps-Multitime-Frame-RSI/
- type: indicator
- pine_id: PUB;4c8d841bcb924adeb4d8450b29be92a2
- version: 4.0

## Description

Modified version of the stock TradingView indicator that allows for 3 timeframes to be viewed at the same time. Use for multi-timeframe confirmation strategies.

## Source Code

````pine
//@version=6
indicator(title="Jepps_Multitime Frame RSI v3", shorttitle="Jepps RSI v3", format=format.price, precision=2, max_labels_count=500, max_lines_count=500)

// =============================================================================
// SHARED DIVERGENCE CONSTANTS (matches the stock RSI indicator)
// =============================================================================
LOOKBACK_LEFT  = 5
LOOKBACK_RIGHT = 5
RANGE_LOWER    = 5
RANGE_UPPER    = 60

bearColor = color.red
bullColor = color.green
textColor = color.white
noneColor = color.new(color.white, 100)

// Marker history limit when Backtest Mode is OFF (per zone, per TF)
MARKER_HISTORY_LIMIT = 100

// Marker style options
MARKER_STYLES = "Text (OB/OS),Triangle,Arrow,Circle,Diamond,Cross,Flag"

// =============================================================================
// MA HELPER
// =============================================================================
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

// =============================================================================
// CORE PER-TIMEFRAME CALCULATION
// =============================================================================
calcAll(src, rsiLen, maLen, maType, bbMult, calcDiv) =>
    chg = ta.change(src)
    up  = ta.rma(math.max(chg, 0), rsiLen)
    dn  = ta.rma(-math.min(chg, 0), rsiLen)
    rsiVal = dn == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / dn))

    isBB           = maType == "SMA + Bollinger Bands"
    smoothingMA    = maType != "None" ? ma(rsiVal, maLen, maType) : na
    smoothingStDev = isBB ? ta.stdev(rsiVal, maLen) * bbMult : na
    bbUpper        = isBB ? smoothingMA + smoothingStDev : na
    bbLower        = isBB ? smoothingMA - smoothingStDev : na

    // Divergence
    rsiLBR  = rsiVal[LOOKBACK_RIGHT]
    plFound = not na(ta.pivotlow(rsiVal, LOOKBACK_LEFT, LOOKBACK_RIGHT))
    phFound = not na(ta.pivothigh(rsiVal, LOOKBACK_LEFT, LOOKBACK_RIGHT))

    barsSincePL = ta.barssince(plFound[1])
    barsSincePH = ta.barssince(phFound[1])
    inRangeBull = RANGE_LOWER <= barsSincePL and barsSincePL <= RANGE_UPPER
    inRangeBear = RANGE_LOWER <= barsSincePH and barsSincePH <= RANGE_UPPER

    rsiHL    = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and inRangeBull
    lowLBR   = low[LOOKBACK_RIGHT]
    priceLL  = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond = calcDiv and priceLL and rsiHL and plFound

    rsiLH    = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and inRangeBear
    highLBR  = high[LOOKBACK_RIGHT]
    priceHH  = highLBR > ta.valuewhen(phFound, highLBR, 1)
    bearCond = calcDiv and priceHH and rsiLH and phFound

    [rsiVal, smoothingMA, bbUpper, bbLower, rsiLBR, plFound, phFound, bullCond, bearCond]

// =============================================================================
// INPUTS — AUTO TIMEFRAME SET
// =============================================================================
GA = "Auto Timeframe Set"
autoTF      = input.bool(false, "Auto-pick timeframes from chart", group=GA, tooltip="TF1 follows the chart; TF2/TF3 follow a fixed ladder. Forces all three timeframes on. Chart TFs outside the ladder fall back to the manual Timeframe inputs below.")
showTfTable = input.bool(true,  "Show MTF RSI table",              group=GA, tooltip="Top-right table of the auto-selected intervals and their current RSI values. Appears only in auto mode.")

// =============================================================================
// INPUTS — TIMEFRAME 1
// =============================================================================
G1 = "Timeframe 1"
tf1EnableInput = input.bool(true,        "Enable",                                                                              group=G1)
tf1TF         = input.timeframe("",      "Timeframe (blank = chart)",                                                          group=G1)
tf1Length     = input.int(14,            "RSI Length", minval=1,                                                               group=G1)
tf1Source     = input.source(close,      "Source",                                                                             group=G1)
tf1CalcDiv    = input.bool(false,        "Calculate Divergence", tooltip="Calculating divergences is needed in order for divergence alerts to fire.", group=G1)
tf1MAType     = input.string("None",     "MA Type", options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"], group=G1)
tf1MALen      = input.int(14,            "MA Length", minval=1,                                                                group=G1)
tf1BBMult     = input.float(2.0,         "BB StdDev", minval=0.001, maxval=50, step=0.5,                                       group=G1)
tf1Color      = input.color(color.white, "RSI Color",                                                                          group=G1)
tf1ShowOB     = input.bool(true,         "Show OB Marker",                                                                     group=G1, inline="ob1")
tf1ObLevel    = input.float(70,          "@ RSI", minval=0, maxval=100, step=1,                                                group=G1, inline="ob1")
tf1ShowOS     = input.bool(true,         "Show OS Marker",                                                                     group=G1, inline="os1")
tf1OsLevel    = input.float(30,          "@ RSI", minval=0, maxval=100, step=1,                                                group=G1, inline="os1")
tf1MarkerColor= input.color(color.white, "Marker Color",                                                                       group=G1, inline="mk1")
tf1MarkerStyle= input.string("Text (OB/OS)", "Style", options=["Text (OB/OS)","Triangle","Arrow","Circle","Diamond","Cross","Flag"], group=G1, inline="mk1")
tf1MarkerSize = input.string("Small",        "Marker Size", options=["Tiny","Small","Normal","Large","Huge","Auto"],                group=G1)

// =============================================================================
// INPUTS — TIMEFRAME 2
// =============================================================================
G2 = "Timeframe 2"
tf2EnableInput = input.bool(false,       "Enable",                                                                             group=G2)
tf2TF         = input.timeframe("60",    "Timeframe",                                                                          group=G2)
tf2Length     = input.int(14,            "RSI Length", minval=1,                                                               group=G2)
tf2Source     = input.source(close,      "Source",                                                                             group=G2)
tf2CalcDiv    = input.bool(false,        "Calculate Divergence", tooltip="Calculating divergences is needed in order for divergence alerts to fire.", group=G2)
tf2MAType     = input.string("None",     "MA Type", options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"], group=G2)
tf2MALen      = input.int(14,            "MA Length", minval=1,                                                                group=G2)
tf2BBMult     = input.float(2.0,         "BB StdDev", minval=0.001, maxval=50, step=0.5,                                       group=G2)
tf2Color      = input.color(color.yellow,"RSI Color",                                                                          group=G2)
tf2ShowOB     = input.bool(true,         "Show OB Marker",                                                                     group=G2, inline="ob2")
tf2ObLevel    = input.float(70,          "@ RSI", minval=0, maxval=100, step=1,                                                group=G2, inline="ob2")
tf2ShowOS     = input.bool(true,         "Show OS Marker",                                                                     group=G2, inline="os2")
tf2OsLevel    = input.float(30,          "@ RSI", minval=0, maxval=100, step=1,                                                group=G2, inline="os2")
tf2MarkerColor= input.color(color.yellow,"Marker Color",                                                                       group=G2, inline="mk2")
tf2MarkerStyle= input.string("Text (OB/OS)", "Style", options=["Text (OB/OS)","Triangle","Arrow","Circle","Diamond","Cross","Flag"], group=G2, inline="mk2")
tf2MarkerSize = input.string("Small",        "Marker Size", options=["Tiny","Small","Normal","Large","Huge","Auto"],                group=G2)

// =============================================================================
// INPUTS — TIMEFRAME 3
// =============================================================================
G3 = "Timeframe 3"
tf3EnableInput = input.bool(false,       "Enable",                                                                             group=G3)
tf3TF         = input.timeframe("D",     "Timeframe",                                                                          group=G3)
tf3Length     = input.int(14,            "RSI Length", minval=1,                                                               group=G3)
tf3Source     = input.source(close,      "Source",                                                                             group=G3)
tf3CalcDiv    = input.bool(false,        "Calculate Divergence", tooltip="Calculating divergences is needed in order for divergence alerts to fire.", group=G3)
tf3MAType     = input.string("None",     "MA Type", options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"], group=G3)
tf3MALen      = input.int(14,            "MA Length", minval=1,                                                                group=G3)
tf3BBMult     = input.float(2.0,         "BB StdDev", minval=0.001, maxval=50, step=0.5,                                       group=G3)
tf3Color      = input.color(#791F19,     "RSI Color",                                                                          group=G3)
tf3ShowOB     = input.bool(true,         "Show OB Marker",                                                                     group=G3, inline="ob3")
tf3ObLevel    = input.float(70,          "@ RSI", minval=0, maxval=100, step=1,                                                group=G3, inline="ob3")
tf3ShowOS     = input.bool(true,         "Show OS Marker",                                                                     group=G3, inline="os3")
tf3OsLevel    = input.float(30,          "@ RSI", minval=0, maxval=100, step=1,                                                group=G3, inline="os3")
tf3MarkerColor= input.color(#791F19,     "Marker Color",                                                                       group=G3, inline="mk3")
tf3MarkerStyle= input.string("Text (OB/OS)", "Style", options=["Text (OB/OS)","Triangle","Arrow","Circle","Diamond","Cross","Flag"], group=G3, inline="mk3")
tf3MarkerSize = input.string("Small",        "Marker Size", options=["Tiny","Small","Normal","Large","Huge","Auto"],                group=G3)

// =============================================================================
// INPUTS — DISPLAY
// =============================================================================
GD = "Display"
showBgFill   = input.bool(true,  "Show 30/70 Background Fill", group=GD)
backtestMode = input.bool(false, "Backtest Mode (show all historical OB/OS markers, not just the last 100 per zone)", group=GD)

// =============================================================================
// INPUTS — CONFLUENCE MARKERS (2 TFs OB/OS, all 3 TFs OB/OS)
// =============================================================================
GC = "Confluence Markers"
conf2Enable      = input.bool(true,           "2-of-3 Enable",                                                                       group=GC)
conf2ShowOB      = input.bool(true,           "Show OB Marker (2-of-3)",                                                              group=GC)
conf2ShowOS      = input.bool(true,           "Show OS Marker (2-of-3)",                                                              group=GC)
conf2MarkerColor = input.color(color.orange,  "Marker Color (2-of-3)",                                                                group=GC, inline="c2mk")
conf2MarkerStyle = input.string("Diamond",    "Style", options=["Text (OB/OS)","Triangle","Arrow","Circle","Diamond","Cross","Flag"], group=GC, inline="c2mk")
conf2MarkerSize  = input.string("Small",      "Marker Size (2-of-3)", options=["Tiny","Small","Normal","Large","Huge","Auto"],         group=GC)

conf3Enable      = input.bool(true,           "3-of-3 Enable",                                                                       group=GC)
conf3ShowOB      = input.bool(true,           "Show OB Marker (3-of-3)",                                                              group=GC)
conf3ShowOS      = input.bool(true,           "Show OS Marker (3-of-3)",                                                              group=GC)
conf3MarkerColor = input.color(color.fuchsia, "Marker Color (3-of-3)",                                                                group=GC, inline="c3mk")
conf3MarkerStyle = input.string("Text (OB/OS)", "Style", options=["Text (OB/OS)","Triangle","Arrow","Circle","Diamond","Cross","Flag"], group=GC, inline="c3mk")
conf3MarkerSize  = input.string("Small",      "Marker Size (3-of-3)", options=["Tiny","Small","Normal","Large","Huge","Auto"],         group=GC)

// =============================================================================
// REQUEST DATA FOR EACH TIMEFRAME
// =============================================================================
// --- Auto timeframe set ---------------------------------------------------
// When on: TF1 = chart, TF2/TF3 come from a fixed ladder keyed on the chart
// timeframe, and all three TFs are force-enabled. Chart TFs not in the ladder
// keep the manual inputs. NB: hours are minute-strings (1h="60", 2h="120",
// 4h="240"), so the ladder keys must use them.
[autoT2, autoT3] = switch timeframe.period
    "1"   => ["3",   "5"]
    "3"   => ["5",   "10"]
    "5"   => ["7",   "10"]
    "15"  => ["30",  "60"]
    "30"  => ["60",  "120"]
    "60"  => ["120", "240"]
    "120" => ["240", "D"]
    "240" => ["D",   "3D"]
    "D"   => ["3D",  "W"]
    => [tf2TF, tf3TF]

// Force all three on in auto mode; otherwise honor the per-TF Enable toggles.
tf1Enable = autoTF or tf1EnableInput
tf2Enable = autoTF or tf2EnableInput
tf3Enable = autoTF or tf3EnableInput

tf1Resolved = autoTF ? timeframe.period : (tf1TF == "" ? timeframe.period : tf1TF)
tf2Resolved = autoTF ? autoT2 : tf2TF
tf3Resolved = autoTF ? autoT3 : tf3TF

[rsi1, ma1, bbU1, bbL1, rsiLBR1, pl1, ph1, bull1, bear1] =
     request.security(syminfo.tickerid, tf1Resolved,
         calcAll(tf1Source, tf1Length, tf1MALen, tf1MAType, tf1BBMult, tf1CalcDiv))

[rsi2, ma2, bbU2, bbL2, rsiLBR2, pl2, ph2, bull2, bear2] =
     request.security(syminfo.tickerid, tf2Resolved,
         calcAll(tf2Source, tf2Length, tf2MALen, tf2MAType, tf2BBMult, tf2CalcDiv))

[rsi3, ma3, bbU3, bbL3, rsiLBR3, pl3, ph3, bull3, bear3] =
     request.security(syminfo.tickerid, tf3Resolved,
         calcAll(tf3Source, tf3Length, tf3MALen, tf3MAType, tf3BBMult, tf3CalcDiv))

// =============================================================================
// HORIZONTAL BANDS (drawn once)
// =============================================================================
rsiUpperBand = hline(70, "RSI Upper Band",  color=#787B86)
midline      = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band",  color=#787B86)
fill(rsiUpperBand, rsiLowerBand,
     color = showBgFill ? color.rgb(126, 87, 194, 90) : na,
     title = "RSI Background Fill")

midLinePlot = plot(50, color=na, editable=false, display=display.none)

// =============================================================================
// TIMEFRAME 1 PLOTS
// =============================================================================
tf1IsBB = tf1MAType == "SMA + Bollinger Bands"
tf1MAOn = tf1Enable and tf1MAType != "None"
tf1BBOn = tf1Enable and tf1IsBB

rsi1Plot = plot(tf1Enable ? rsi1 : na, "TF1 RSI",
     color   = tf1Color,
     display = tf1Enable ? display.all : display.none)
plot(tf1MAOn ? ma1 : na, "TF1 RSI-based MA",
     color   = color.yellow,
     display = tf1MAOn ? display.all : display.none,
     editable= tf1MAOn)
bb1U = plot(tf1BBOn ? bbU1 : na, "TF1 Upper Bollinger Band",
     color   = color.green,
     display = tf1BBOn ? display.all : display.none,
     editable= tf1BBOn)
bb1L = plot(tf1BBOn ? bbL1 : na, "TF1 Lower Bollinger Band",
     color   = color.green,
     display = tf1BBOn ? display.all : display.none,
     editable= tf1BBOn)
fill(bb1U, bb1L,
     color   = tf1BBOn ? color.new(color.green, 90) : na,
     title   = "TF1 Bollinger Bands Background Fill",
     display = tf1BBOn ? display.all : display.none,
     editable= tf1BBOn)

// TF1 Divergence
tf1DivOn = tf1Enable and tf1CalcDiv
plot(tf1DivOn and pl1 ? rsiLBR1 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF1 Regular Bullish",
     linewidth = 2,
     color     = (tf1DivOn and bull1 ? bullColor : noneColor),
     display   = tf1DivOn ? display.pane : display.none,
     editable  = tf1DivOn)
plotshape(tf1DivOn and bull1 ? rsiLBR1 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF1 Regular Bullish Label",
     text      = " Bull ",
     style     = shape.labelup,
     location  = location.absolute,
     color     = bullColor,
     textcolor = textColor,
     display   = tf1DivOn ? display.pane : display.none,
     editable  = tf1DivOn)
plot(tf1DivOn and ph1 ? rsiLBR1 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF1 Regular Bearish",
     linewidth = 2,
     color     = (tf1DivOn and bear1 ? bearColor : noneColor),
     display   = tf1DivOn ? display.pane : display.none,
     editable  = tf1DivOn)
plotshape(tf1DivOn and bear1 ? rsiLBR1 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF1 Regular Bearish Label",
     text      = " Bear ",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = bearColor,
     textcolor = textColor,
     display   = tf1DivOn ? display.pane : display.none,
     editable  = tf1DivOn)

// =============================================================================
// TIMEFRAME 2 PLOTS
// =============================================================================
tf2IsBB = tf2MAType == "SMA + Bollinger Bands"
tf2MAOn = tf2Enable and tf2MAType != "None"
tf2BBOn = tf2Enable and tf2IsBB

rsi2Plot = plot(tf2Enable ? rsi2 : na, "TF2 RSI",
     color   = tf2Color,
     display = tf2Enable ? display.all : display.none)
plot(tf2MAOn ? ma2 : na, "TF2 RSI-based MA",
     color   = color.yellow,
     display = tf2MAOn ? display.all : display.none,
     editable= tf2MAOn)
bb2U = plot(tf2BBOn ? bbU2 : na, "TF2 Upper Bollinger Band",
     color   = color.green,
     display = tf2BBOn ? display.all : display.none,
     editable= tf2BBOn)
bb2L = plot(tf2BBOn ? bbL2 : na, "TF2 Lower Bollinger Band",
     color   = color.green,
     display = tf2BBOn ? display.all : display.none,
     editable= tf2BBOn)
fill(bb2U, bb2L,
     color   = tf2BBOn ? color.new(color.green, 90) : na,
     title   = "TF2 Bollinger Bands Background Fill",
     display = tf2BBOn ? display.all : display.none,
     editable= tf2BBOn)

// TF2 Divergence
tf2DivOn = tf2Enable and tf2CalcDiv
plot(tf2DivOn and pl2 ? rsiLBR2 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF2 Regular Bullish",
     linewidth = 2,
     color     = (tf2DivOn and bull2 ? bullColor : noneColor),
     display   = tf2DivOn ? display.pane : display.none,
     editable  = tf2DivOn)
plotshape(tf2DivOn and bull2 ? rsiLBR2 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF2 Regular Bullish Label",
     text      = " Bull ",
     style     = shape.labelup,
     location  = location.absolute,
     color     = bullColor,
     textcolor = textColor,
     display   = tf2DivOn ? display.pane : display.none,
     editable  = tf2DivOn)
plot(tf2DivOn and ph2 ? rsiLBR2 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF2 Regular Bearish",
     linewidth = 2,
     color     = (tf2DivOn and bear2 ? bearColor : noneColor),
     display   = tf2DivOn ? display.pane : display.none,
     editable  = tf2DivOn)
plotshape(tf2DivOn and bear2 ? rsiLBR2 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF2 Regular Bearish Label",
     text      = " Bear ",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = bearColor,
     textcolor = textColor,
     display   = tf2DivOn ? display.pane : display.none,
     editable  = tf2DivOn)

// =============================================================================
// TIMEFRAME 3 PLOTS
// =============================================================================
tf3IsBB = tf3MAType == "SMA + Bollinger Bands"
tf3MAOn = tf3Enable and tf3MAType != "None"
tf3BBOn = tf3Enable and tf3IsBB

rsi3Plot = plot(tf3Enable ? rsi3 : na, "TF3 RSI",
     color   = tf3Color,
     display = tf3Enable ? display.all : display.none)
plot(tf3MAOn ? ma3 : na, "TF3 RSI-based MA",
     color   = color.yellow,
     display = tf3MAOn ? display.all : display.none,
     editable= tf3MAOn)
bb3U = plot(tf3BBOn ? bbU3 : na, "TF3 Upper Bollinger Band",
     color   = color.green,
     display = tf3BBOn ? display.all : display.none,
     editable= tf3BBOn)
bb3L = plot(tf3BBOn ? bbL3 : na, "TF3 Lower Bollinger Band",
     color   = color.green,
     display = tf3BBOn ? display.all : display.none,
     editable= tf3BBOn)
fill(bb3U, bb3L,
     color   = tf3BBOn ? color.new(color.green, 90) : na,
     title   = "TF3 Bollinger Bands Background Fill",
     display = tf3BBOn ? display.all : display.none,
     editable= tf3BBOn)

// TF3 Divergence
tf3DivOn = tf3Enable and tf3CalcDiv
plot(tf3DivOn and pl3 ? rsiLBR3 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF3 Regular Bullish",
     linewidth = 2,
     color     = (tf3DivOn and bull3 ? bullColor : noneColor),
     display   = tf3DivOn ? display.pane : display.none,
     editable  = tf3DivOn)
plotshape(tf3DivOn and bull3 ? rsiLBR3 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF3 Regular Bullish Label",
     text      = " Bull ",
     style     = shape.labelup,
     location  = location.absolute,
     color     = bullColor,
     textcolor = textColor,
     display   = tf3DivOn ? display.pane : display.none,
     editable  = tf3DivOn)
plot(tf3DivOn and ph3 ? rsiLBR3 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF3 Regular Bearish",
     linewidth = 2,
     color     = (tf3DivOn and bear3 ? bearColor : noneColor),
     display   = tf3DivOn ? display.pane : display.none,
     editable  = tf3DivOn)
plotshape(tf3DivOn and bear3 ? rsiLBR3 : na,
     offset    = -LOOKBACK_RIGHT,
     title     = "TF3 Regular Bearish Label",
     text      = " Bear ",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = bearColor,
     textcolor = textColor,
     display   = tf3DivOn ? display.pane : display.none,
     editable  = tf3DivOn)

// =============================================================================
// OB/OS MARKERS ON THE MAIN PRICE CHART
// -----------------------------------------------------------------------------
// Logic (option C — latch + close-confirm):
//   1. Detect HTF bar transitions via ta.change(time(htf_tf)). Reset latches
//      at every new HTF bar so each HTF bar can fire at most one OB and one OS
//      marker.
//   2. Trigger on ta.crossover/ta.crossunder of the HTF RSI series. With
//      lookahead_off (default), this fires intra-bar in real time AND at the
//      HTF close on historical replay — the close-confirm comes "for free"
//      because the historical series only updates at HTF closes.
//   3. Latch the zone after firing so the marker sticks even if RSI retreats
//      back inside the band before the HTF bar closes.
//   4. Per-zone FIFO label retention: keep the last MARKER_HISTORY_LIMIT
//      labels per zone unless Backtest Mode is on, in which case retention is
//      bounded only by Pine's max_labels_count (500 total).
// =============================================================================

// Pick a contrasting text color for "Text (OB/OS)" markers based on luminance
// of the marker color so e.g. white markers don't have white text.
contrastingText(c) =>
    lum = 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
    lum > 140 ? color.black : color.white

// Map style string + zone to label.style_*
obStyleFor(s) =>
    switch s
        "Text (OB/OS)" => label.style_label_down
        "Triangle"     => label.style_triangledown
        "Arrow"        => label.style_arrowdown
        "Circle"       => label.style_circle
        "Diamond"      => label.style_diamond
        "Cross"        => label.style_xcross
        "Flag"         => label.style_flag
        => label.style_label_down

osStyleFor(s) =>
    switch s
        "Text (OB/OS)" => label.style_label_up
        "Triangle"     => label.style_triangleup
        "Arrow"        => label.style_arrowup
        "Circle"       => label.style_circle
        "Diamond"      => label.style_diamond
        "Cross"        => label.style_xcross
        "Flag"         => label.style_flag
        => label.style_label_up

// Map size string to size.* constant
sizeFor(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
        => size.small

// Detect HTF bar transitions on each TF (used for latch reset)
tf1NewHtfBar = ta.change(time(tf1Resolved)) != 0
tf2NewHtfBar = ta.change(time(tf2Resolved)) != 0
tf3NewHtfBar = ta.change(time(tf3Resolved)) != 0

// Latches — one OB and one OS per TF, reset at each new HTF bar
var bool tf1ObLatch = false
var bool tf1OsLatch = false
var bool tf2ObLatch = false
var bool tf2OsLatch = false
var bool tf3ObLatch = false
var bool tf3OsLatch = false

if tf1NewHtfBar
    tf1ObLatch := false
    tf1OsLatch := false
if tf2NewHtfBar
    tf2ObLatch := false
    tf2OsLatch := false
if tf3NewHtfBar
    tf3ObLatch := false
    tf3OsLatch := false

// Precompute crossovers globally so ta.* functions evaluate on every bar.
// (Inlining them in the `and` chain below would let short-circuit evaluation
//  skip the call, which breaks ta.crossover's history-dependent state.)
tf1ObCross = ta.crossover(rsi1,  tf1ObLevel)
tf1OsCross = ta.crossunder(rsi1, tf1OsLevel)
tf2ObCross = ta.crossover(rsi2,  tf2ObLevel)
tf2OsCross = ta.crossunder(rsi2, tf2OsLevel)
tf3ObCross = ta.crossover(rsi3,  tf3ObLevel)
tf3OsCross = ta.crossunder(rsi3, tf3OsLevel)

// Latch-set conditions (drive the latch independent of ShowOB/OS so the
// confluence count below stays accurate even if a per-TF marker is hidden).
tf1ObSet  = tf1Enable and not tf1ObLatch and tf1ObCross
tf1OsSet  = tf1Enable and not tf1OsLatch and tf1OsCross
tf2ObSet  = tf2Enable and not tf2ObLatch and tf2ObCross
tf2OsSet  = tf2Enable and not tf2OsLatch and tf2OsCross
tf3ObSet  = tf3Enable and not tf3ObLatch and tf3ObCross
tf3OsSet  = tf3Enable and not tf3OsLatch and tf3OsCross

// Fire conditions for per-TF markers + alerts (gated on the Show toggle).
tf1ObFire = tf1ObSet and tf1ShowOB
tf1OsFire = tf1OsSet and tf1ShowOS
tf2ObFire = tf2ObSet and tf2ShowOB
tf2OsFire = tf2OsSet and tf2ShowOS
tf3ObFire = tf3ObSet and tf3ShowOB
tf3OsFire = tf3OsSet and tf3ShowOS

// Per-zone label arrays for FIFO retention
var label[] tf1ObLabels = array.new<label>()
var label[] tf1OsLabels = array.new<label>()
var label[] tf2ObLabels = array.new<label>()
var label[] tf2OsLabels = array.new<label>()
var label[] tf3ObLabels = array.new<label>()
var label[] tf3OsLabels = array.new<label>()

// TF1 OB
if tf1ObSet
    tf1ObLatch := true
if tf1ObFire
    txt = tf1MarkerStyle == "Text (OB/OS)" ? "OB" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.abovebar,
         color=tf1MarkerColor, style=obStyleFor(tf1MarkerStyle),
         textcolor=contrastingText(tf1MarkerColor), size=sizeFor(tf1MarkerSize),
         force_overlay=true)
    array.push(tf1ObLabels, l)
    if not backtestMode and array.size(tf1ObLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(tf1ObLabels))

// TF1 OS
if tf1OsSet
    tf1OsLatch := true
if tf1OsFire
    txt = tf1MarkerStyle == "Text (OB/OS)" ? "OS" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.belowbar,
         color=tf1MarkerColor, style=osStyleFor(tf1MarkerStyle),
         textcolor=contrastingText(tf1MarkerColor), size=sizeFor(tf1MarkerSize),
         force_overlay=true)
    array.push(tf1OsLabels, l)
    if not backtestMode and array.size(tf1OsLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(tf1OsLabels))

// TF2 OB
if tf2ObSet
    tf2ObLatch := true
if tf2ObFire
    txt = tf2MarkerStyle == "Text (OB/OS)" ? "OB" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.abovebar,
         color=tf2MarkerColor, style=obStyleFor(tf2MarkerStyle),
         textcolor=contrastingText(tf2MarkerColor), size=sizeFor(tf2MarkerSize),
         force_overlay=true)
    array.push(tf2ObLabels, l)
    if not backtestMode and array.size(tf2ObLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(tf2ObLabels))

// TF2 OS
if tf2OsSet
    tf2OsLatch := true
if tf2OsFire
    txt = tf2MarkerStyle == "Text (OB/OS)" ? "OS" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.belowbar,
         color=tf2MarkerColor, style=osStyleFor(tf2MarkerStyle),
         textcolor=contrastingText(tf2MarkerColor), size=sizeFor(tf2MarkerSize),
         force_overlay=true)
    array.push(tf2OsLabels, l)
    if not backtestMode and array.size(tf2OsLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(tf2OsLabels))

// TF3 OB
if tf3ObSet
    tf3ObLatch := true
if tf3ObFire
    txt = tf3MarkerStyle == "Text (OB/OS)" ? "OB" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.abovebar,
         color=tf3MarkerColor, style=obStyleFor(tf3MarkerStyle),
         textcolor=contrastingText(tf3MarkerColor), size=sizeFor(tf3MarkerSize),
         force_overlay=true)
    array.push(tf3ObLabels, l)
    if not backtestMode and array.size(tf3ObLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(tf3ObLabels))

// TF3 OS
if tf3OsSet
    tf3OsLatch := true
if tf3OsFire
    txt = tf3MarkerStyle == "Text (OB/OS)" ? "OS" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.belowbar,
         color=tf3MarkerColor, style=osStyleFor(tf3MarkerStyle),
         textcolor=contrastingText(tf3MarkerColor), size=sizeFor(tf3MarkerSize),
         force_overlay=true)
    array.push(tf3OsLabels, l)
    if not backtestMode and array.size(tf3OsLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(tf3OsLabels))

// =============================================================================
// CONFLUENCE MARKERS (2-of-3 and 3-of-3 TFs OB/OS)
// -----------------------------------------------------------------------------
// Zone-based counting: a TF contributes to obCount whenever its RSI is
// currently at/above its OB level, and to osCount whenever its RSI is at/below
// its OS level. We DON'T reuse the per-TF cross-latches here because the
// chart-TF latch resets every chart bar, making latch overlap across all 3
// TFs effectively impossible. Zone-based matches the natural read of "all 3
// RSIs are in the zone right now".
//
// A TF counts toward confluence regardless of whether its individual
// ShowOB/ShowOS toggle is on — confluence reflects underlying state.
//
// "On entry only": each tier fires once when the count first transitions
//   INTO the target value. Going from 2 → 0/1 → 2 re-fires; staying at 2
//   does not re-fire.
// "Only 3-of-3 on full confluence": 2-of-3 triggers when count == 2 (was < 2);
//   3-of-3 triggers when count == 3 (was < 3). On a bar where count jumps
//   straight 0 → 3, only the 3-of-3 marker draws. On consecutive bars
//   2 → 3, both fire (one each bar), which is desired entry-into-each-state
//   behavior.
// =============================================================================
tf1ObInZone = tf1Enable and not na(rsi1) and rsi1 >= tf1ObLevel
tf2ObInZone = tf2Enable and not na(rsi2) and rsi2 >= tf2ObLevel
tf3ObInZone = tf3Enable and not na(rsi3) and rsi3 >= tf3ObLevel
tf1OsInZone = tf1Enable and not na(rsi1) and rsi1 <= tf1OsLevel
tf2OsInZone = tf2Enable and not na(rsi2) and rsi2 <= tf2OsLevel
tf3OsInZone = tf3Enable and not na(rsi3) and rsi3 <= tf3OsLevel

obCount = (tf1ObInZone ? 1 : 0) + (tf2ObInZone ? 1 : 0) + (tf3ObInZone ? 1 : 0)
osCount = (tf1OsInZone ? 1 : 0) + (tf2OsInZone ? 1 : 0) + (tf3OsInZone ? 1 : 0)

conf2ObFire = conf2Enable and conf2ShowOB and obCount == 2 and nz(obCount[1], 0) < 2
conf3ObFire = conf3Enable and conf3ShowOB and obCount == 3 and nz(obCount[1], 0) < 3
conf2OsFire = conf2Enable and conf2ShowOS and osCount == 2 and nz(osCount[1], 0) < 2
conf3OsFire = conf3Enable and conf3ShowOS and osCount == 3 and nz(osCount[1], 0) < 3

var label[] conf2ObLabels = array.new<label>()
var label[] conf2OsLabels = array.new<label>()
var label[] conf3ObLabels = array.new<label>()
var label[] conf3OsLabels = array.new<label>()

if conf2ObFire
    txt = conf2MarkerStyle == "Text (OB/OS)" ? "2OB" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.abovebar,
         color=conf2MarkerColor, style=obStyleFor(conf2MarkerStyle),
         textcolor=contrastingText(conf2MarkerColor), size=sizeFor(conf2MarkerSize),
         force_overlay=true)
    array.push(conf2ObLabels, l)
    if not backtestMode and array.size(conf2ObLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(conf2ObLabels))

if conf2OsFire
    txt = conf2MarkerStyle == "Text (OB/OS)" ? "2OS" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.belowbar,
         color=conf2MarkerColor, style=osStyleFor(conf2MarkerStyle),
         textcolor=contrastingText(conf2MarkerColor), size=sizeFor(conf2MarkerSize),
         force_overlay=true)
    array.push(conf2OsLabels, l)
    if not backtestMode and array.size(conf2OsLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(conf2OsLabels))

if conf3ObFire
    txt = conf3MarkerStyle == "Text (OB/OS)" ? "3OB" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.abovebar,
         color=conf3MarkerColor, style=obStyleFor(conf3MarkerStyle),
         textcolor=contrastingText(conf3MarkerColor), size=sizeFor(conf3MarkerSize),
         force_overlay=true)
    array.push(conf3ObLabels, l)
    if not backtestMode and array.size(conf3ObLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(conf3ObLabels))

if conf3OsFire
    txt = conf3MarkerStyle == "Text (OB/OS)" ? "3OS" : ""
    l = label.new(bar_index, na, text=txt, yloc=yloc.belowbar,
         color=conf3MarkerColor, style=osStyleFor(conf3MarkerStyle),
         textcolor=contrastingText(conf3MarkerColor), size=sizeFor(conf3MarkerSize),
         force_overlay=true)
    array.push(conf3OsLabels, l)
    if not backtestMode and array.size(conf3OsLabels) > MARKER_HISTORY_LIMIT
        label.delete(array.shift(conf3OsLabels))

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(bull1, title="TF1 Regular Bullish Divergence", message="TF1: Regular Bullish Divergence detected.")
alertcondition(bear1, title="TF1 Regular Bearish Divergence", message="TF1: Regular Bearish Divergence detected.")
alertcondition(bull2, title="TF2 Regular Bullish Divergence", message="TF2: Regular Bullish Divergence detected.")
alertcondition(bear2, title="TF2 Regular Bearish Divergence", message="TF2: Regular Bearish Divergence detected.")
alertcondition(bull3, title="TF3 Regular Bullish Divergence", message="TF3: Regular Bullish Divergence detected.")
alertcondition(bear3, title="TF3 Regular Bearish Divergence", message="TF3: Regular Bearish Divergence detected.")

alertcondition(tf1ObFire, title="TF1 Overbought",  message="TF1: RSI crossed above OB threshold.")
alertcondition(tf1OsFire, title="TF1 Oversold",    message="TF1: RSI crossed below OS threshold.")
alertcondition(tf2ObFire, title="TF2 Overbought",  message="TF2: RSI crossed above OB threshold.")
alertcondition(tf2OsFire, title="TF2 Oversold",    message="TF2: RSI crossed below OS threshold.")
alertcondition(tf3ObFire, title="TF3 Overbought",  message="TF3: RSI crossed above OB threshold.")
alertcondition(tf3OsFire, title="TF3 Oversold",    message="TF3: RSI crossed below OS threshold.")

alertcondition(conf2ObFire, title="Confluence 2-of-3 Overbought", message="2 of 3 TFs are now Overbought.")
alertcondition(conf2OsFire, title="Confluence 2-of-3 Oversold",   message="2 of 3 TFs are now Oversold.")
alertcondition(conf3ObFire, title="Confluence 3-of-3 Overbought", message="All 3 TFs are now Overbought.")
alertcondition(conf3OsFire, title="Confluence 3-of-3 Oversold",   message="All 3 TFs are now Oversold.")

// =============================================================================
// MTF RSI READOUT TABLE (auto mode only)
// -----------------------------------------------------------------------------
// Left column = each auto-selected interval; right column = its live RSI.
// Styling is exposed as inputs (Inputs tab) — Pine can't add table controls to
// the Style tab, which is auto-generated for plots/fills/lines only.
// =============================================================================
GT = "MTF RSI Table"
tblPosition = input.string("Top Right", "Position",  options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=GT)
tblTextSize = input.string("Small",     "Text Size", options=["Tiny","Small","Normal","Large","Huge","Auto"], group=GT)
tblHdrBg    = input.color(color.new(color.blue, 0),   "Header Background", group=GT)
tblHdrText  = input.color(color.white,                "Header Text",      group=GT)
tblCellBg   = input.color(color.new(color.black, 60), "Cell Background",  group=GT)
tblValText  = input.color(color.white,                "RSI Value Text",   group=GT)
tblBorder   = input.color(color.new(color.gray, 50),  "Border",           group=GT)

// Pretty-print a TF string: daily+ stays raw ("D"/"3D"/"W"), else h/m.
tfLabel(string tf) =>
    s = timeframe.in_seconds(tf)
    s >= 86400 ? tf : (s >= 3600 ? str.tostring(int(s / 3600)) + "h" : str.tostring(int(s / 60)) + "m")

rsiTxt(float v) =>
    na(v) ? "n/a" : str.tostring(v, "0.0")

tblPos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

var table tfTable = table.new(tblPos(tblPosition), 2, 4, border_width=1, border_color=tblBorder)
if barstate.islast and autoTF and showTfTable
    sz = sizeFor(tblTextSize)
    table.cell(tfTable, 0, 0, "Interval",           text_color=tblHdrText, bgcolor=tblHdrBg,  text_size=sz)
    table.cell(tfTable, 1, 0, "RSI",                text_color=tblHdrText, bgcolor=tblHdrBg,  text_size=sz)
    table.cell(tfTable, 0, 1, tfLabel(tf1Resolved), text_color=tf1Color,   bgcolor=tblCellBg, text_size=sz)
    table.cell(tfTable, 1, 1, rsiTxt(rsi1),         text_color=tblValText, bgcolor=tblCellBg, text_size=sz)
    table.cell(tfTable, 0, 2, tfLabel(tf2Resolved), text_color=tf2Color,   bgcolor=tblCellBg, text_size=sz)
    table.cell(tfTable, 1, 2, rsiTxt(rsi2),         text_color=tblValText, bgcolor=tblCellBg, text_size=sz)
    table.cell(tfTable, 0, 3, tfLabel(tf3Resolved), text_color=tf3Color,   bgcolor=tblCellBg, text_size=sz)
    table.cell(tfTable, 1, 3, rsiTxt(rsi3),         text_color=tblValText, bgcolor=tblCellBg, text_size=sz)
````
