# Minicharts Multi Market [Herman]

- url: https://www.tradingview.com/script/fm27vaKk-Minicharts-Multi-Market-Herman/
- type: indicator
- pine_id: PUB;2ce9b019e9b34c0ba6d66f945c65ee9d
- version: 1.0

## Description

[b]Minicharts Multi Market [Herman][/b]

[b]Minicharts Multi Market [Herman] [/b]is a multi-asset visualization tool designed to display several different markets directly on a single chart using compact embedded mini charts.

Instead of switching between multiple tabs and layouts, this script allows traders to monitor intermarket behavior, relative strength, SMT relationships, and higher timeframe structure from one workspace.

The indicator is intended as a visual decision-support tool only and does not generate buy or sell signals.

[b]Purpose[/b]

The main goal of this script is to improve chart workflow and market awareness by allowing users to:

• Monitor multiple correlated assets at the same time
• Compare futures markets such as NQ, ES, YM, RTY, CL, GC and others
• Observe relative strength and weakness across markets
• Identify potential SMT divergences between correlated instruments
• Keep higher timeframe structure visible while executing on lower timeframes
• Reduce the need to constantly switch charts during active trading sessions

This helps traders maintain better context and avoid missing important intermarket information.

[b]How It Works
[/b]
The script uses request.security() to retrieve OHLC data from multiple user-selected symbols and reconstructs them as compact mini charts displayed on the right side of the main chart.

Each mini chart functions independently and can display:

• Custom symbol
• Custom timeframe
• Optional EMA
• Optional VWAP
• Optional SMT detection
• Optional HTF Fair Value Gaps (FVG / iFVG)

The indicator does not use repainting logic for visualization purposes and is designed for structural reference and contextual analysis.

[b]Main Features[/b]
1. Multi-Asset Minicharts

Display up to 6 different assets simultaneously.

Examples:

• NQ
• ES
• YM
• RTY
• CL
• GC
• SI
• Forex pairs
• Indices
• Any TradingView-supported symbol

Each chart can use its own symbol and its own timeframe.

[b]This makes the script useful for:[/b]

• Index traders
• Futures traders
• SMT traders
• Intermarket analysis
• Session-based traders
• Higher timeframe structure alignment

2. Automatic SMT Detection

The script includes optional SMT (Smart Money Technique) divergence visualization.

It automatically detects correlated comparison assets:

Examples:

• NQ ↔ ES
• ES ↔ NQ
• YM ↔ ES
• RTY ↔ ES
• GC ↔ SI
• CL ↔ RB

When pivot highs or lows diverge between assets, the script highlights these areas visually.

This feature is designed to assist traders who use SMT as confirmation, not as a standalone entry signal.

3. EMA Overlay

Each mini chart can optionally display EMA.

Settings include:

• Enable / disable EMA globally
• Enable / disable EMA per mini chart
• Custom EMA period
• Custom EMA color

This helps users quickly identify trend alignment across markets.

4. VWAP Overlay

Each mini chart can optionally display VWAP.

Settings include:

• Enable / disable VWAP globally
• Enable / disable VWAP per mini chart
• Custom VWAP color

This allows users to monitor mean reversion and institutional reference pricing across multiple instruments.

5. HTF Fair Value Gaps (FVG)

Optional HTF Fair Value Gap visualization is included.

The script detects:

• Bullish FVG
• Bearish FVG
• Inverted FVG (iFVG)

Users can choose:

• Extended mode
• Next Bar Only mode

This helps provide additional structural context on higher timeframe inefficiencies.

[b]Settings Overview[/b]
Minicharts Assets Setup

For each mini chart:

• Enable / disable chart
• Select symbol
• Select timeframe
• Enable / disable SMT
• Enable / disable EMA
• Enable / disable VWAP

Each of the 6 mini charts can be customized independently.

EMA Configuration

• Show EMA
• EMA period
• EMA color

VWAP Configuration

• Show VWAP
• VWAP color

HTF FVG Configuration

• Show FVG
• Extension mode
• Bullish FVG color
• Bearish FVG color
• Inverted FVG color

Style & Layout

• Pivot lookback for SMT
• SMT colors
• Candle colors
• Number of bars shown
• Bar spacing
• Background frames
• Right offset
• Column spacing
• Chart height
• Row spacing
• Asset / timeframe labels

These controls allow users to fully adapt the layout to their chart style.
[b]
Important Notes[/b]

This script is designed for visualization purposes only
It does not generate trading signals, alerts, or recommendations
All calculations are based on historical price data
The tool is intended to support chart analysis, not replace independent decision-making

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// | Modified by Herman Trading

//@version=6
indicator("Minicharts Multi Market [Herman]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Auto SMT Detection Logic ---
getAutoSmtSymbol(string sym) =>
    target = sym // Fallback to itself
    if str.contains(sym, "NQ") or str.contains(sym, "MNQ")
        target := "CME_MINI:ES1!"
    else if str.contains(sym, "ES") or str.contains(sym, "MES")
        target := "CME_MINI:NQ1!"
    else if str.contains(sym, "YM") or str.contains(sym, "MYM")
        target := "CME_MINI:ES1!"
    else if str.contains(sym, "RTY") or str.contains(sym, "M2K")
        target := "CME_MINI:ES1!"
    else if str.contains(sym, "GC") or str.contains(sym, "MGC")
        target := "COMEX:SI1!"
    else if str.contains(sym, "SI")
        target := "COMEX:GC1!"
    else if str.contains(sym, "CL") or str.contains(sym, "MCL")
        target := "NYMEX:RB1!"
    else if str.contains(sym, "RB")
        target := "NYMEX:CL1!"
    target

// --- Groups ---
string G_C   = "Minicharts Assets Setup"
string G_EMA = "EMA Configuration"
string G_VWAP = "VWAP Configuration"
string G_FVG = "HTF FVG Configuration"
string G_ST  = "Style & Layout"

// --- Inputs ---
// Using generic symbols to let TradingView auto-resolve based on user's data feed
bool show1 = input.bool(true, "1", group = G_C, inline = "c1")
string sym1 = input.symbol("NQ1!", "", group = G_C, inline = "c1")
string tf1 = input.timeframe("5", "", group = G_C, inline = "c1")
bool sSmt1 = input.bool(true, "SMT", group = G_C, inline = "c1")
bool sEma1 = input.bool(true, "EMA", group = G_C, inline = "c1")
bool sVwap1 = input.bool(true, "VWAP", group = G_C, inline = "c1")

bool show2 = input.bool(true, "2", group = G_C, inline = "c2")
string sym2 = input.symbol("ES1!", "", group = G_C, inline = "c2")
string tf2 = input.timeframe("5", "", group = G_C, inline = "c2")
bool sSmt2 = input.bool(true, "SMT", group = G_C, inline = "c2")
bool sEma2 = input.bool(true, "EMA", group = G_C, inline = "c2")
bool sVwap2 = input.bool(true, "VWAP", group = G_C, inline = "c2")

bool show3 = input.bool(true, "3", group = G_C, inline = "c3")
string sym3 = input.symbol("YM1!", "", group = G_C, inline = "c3")
string tf3 = input.timeframe("5", "", group = G_C, inline = "c3")
bool sSmt3 = input.bool(true, "SMT", group = G_C, inline = "c3")
bool sEma3 = input.bool(true, "EMA", group = G_C, inline = "c3")
bool sVwap3 = input.bool(true, "VWAP", group = G_C, inline = "c3")

bool show4 = input.bool(true, "4", group = G_C, inline = "c4")
string sym4 = input.symbol("RTY1!", "", group = G_C, inline = "c4")
string tf4 = input.timeframe("5", "", group = G_C, inline = "c4")
bool sSmt4 = input.bool(true, "SMT", group = G_C, inline = "c4")
bool sEma4 = input.bool(true, "EMA", group = G_C, inline = "c4")
bool sVwap4 = input.bool(true, "VWAP", group = G_C, inline = "c4")

bool show5 = input.bool(true, "5", group = G_C, inline = "c5")
string sym5 = input.symbol("CL1!", "", group = G_C, inline = "c5")
string tf5 = input.timeframe("5", "", group = G_C, inline = "c5")
bool sSmt5 = input.bool(true, "SMT", group = G_C, inline = "c5")
bool sEma5 = input.bool(true, "EMA", group = G_C, inline = "c5")
bool sVwap5 = input.bool(true, "VWAP", group = G_C, inline = "c5")

bool show6 = input.bool(true, "6", group = G_C, inline = "c6")
string sym6 = input.symbol("GC1!", "", group = G_C, inline = "c6")
string tf6 = input.timeframe("5", "", group = G_C, inline = "c6")
bool sSmt6 = input.bool(true, "SMT", group = G_C, inline = "c6")
bool sEma6 = input.bool(true, "EMA", group = G_C, inline = "c6")
bool sVwap6 = input.bool(true, "VWAP", group = G_C, inline = "c6")

// --- Shared Config ---
int smtLookback = input.int(3, "Pivot Lookback", minval = 2, group = G_ST)
color smtHighColor = input.color(color.orange, "Swing High SMT Color", group = G_ST)
color smtLowColor = input.color(color.blue, "Swing Low SMT Color", group = G_ST)

// --- EMA Inputs ---
bool showEma   = input.bool(true, "Show EMA on Minicharts", group = G_EMA)
int emaPeriod  = input.int(200, "EMA Period", minval = 1, group = G_EMA)
color emaColor = input.color(color.new(color.yellow, 10), "EMA Color", group = G_EMA)

// --- VWAP Inputs ---
bool showVwap   = input.bool(true, "Show VWAP on Minicharts", group = G_VWAP)
color vwapColor = input.color(color.new(color.blue, 10), "VWAP Color", group = G_VWAP)

// --- HTF FVG Inputs ---
bool showFvg = input.bool(true, "Show HTF FVG", group = G_FVG)
string fvgExt = input.string("Next Bar Only", "Extension Mode", options = ["Extended", "Next Bar Only"], group = G_FVG)
color bullFvgClr = input.color(color.new(#089981, 80), "Bullish FVG", group = G_FVG)
color bearFvgClr = input.color(color.new(#f23645, 80), "Bearish FVG", group = G_FVG)
color invFvgClr = input.color(color.new(#9c27b0, 80), "Inverted FVG", group = G_FVG)

// --- Style Inputs ---
int barsCount = input.int(30, "HTF Bars to Show", minval = 10, maxval = 60, group = G_ST)
int barSpacing = input.int(5, "Bar Spacing", minval = 3, maxval = 10, group = G_ST)
bool showBgBoxes = input.bool(true, "Show Background Frames", group = G_ST)
color bullColor = input.color(#089981, "Bull Candle", group = G_ST)
color bearColor = input.color(#f23645, "Bear Candle", group = G_ST)
int xOff = input.int(50, "Right Offset", group = G_ST)
int xGapCols = input.int(35, "Column Gap", group = G_ST)
float ySizePerc = input.float(0.2, "Chart Height (%)", group = G_ST)
float yGapRows = input.float(0.05, "Row Gap (%)", group = G_ST)
bool showTfLabels = input.bool(true, "Show Asset/TF Labels", group = G_ST)

// --- Types ---
type BarData
    float o
    float h
    float l
    float c
    float ch
    float cl
    float e
    float v

type Store
    float[] oArr
    float[] hArr
    float[] lArr
    float[] cArr
    float[] chArr
    float[] clArr
    float[] eArr
    float[] vArr

// --- Data Fetching ---
fetchData(string sId, string tf, Store s, int count) =>
    sActual = sId == "" ? syminfo.tickerid : sId
    corrSym = getAutoSmtSymbol(sActual)
    
    [o0, h0, l0, c0, e0, v0, t0, o1, h1, l1, c1, e1, v1] = request.security(sActual, tf, 
         [open, high, low, close, ta.ema(close, emaPeriod), ta.vwap, time, open[1], high[1], low[1], close[1], ta.ema(close, emaPeriod)[1], ta.vwap[1]], 
         ignore_invalid_symbol = true)
    
    [ch0, cl0, ch1, cl1] = request.security(corrSym, tf, 
         [high, low, high[1], low[1]], 
         ignore_invalid_symbol = true)

    tfChanged = ta.change(t0) != 0
    if not na(t0) and tfChanged
        array.unshift(s.oArr, o1)
        array.unshift(s.hArr, h1)
        array.unshift(s.lArr, l1)
        array.unshift(s.cArr, c1)
        array.unshift(s.chArr, nz(ch1, h1))
        array.unshift(s.clArr, nz(cl1, l1))
        array.unshift(s.eArr, nz(e1))
        array.unshift(s.vArr, nz(v1))
        
        if array.size(s.oArr) > count
            array.pop(s.oArr)
            array.pop(s.hArr)
            array.pop(s.lArr)
            array.pop(s.cArr)
            array.pop(s.chArr)
            array.pop(s.clArr)
            array.pop(s.eArr)
            array.pop(s.vArr)

    array<BarData> bars = array.new<BarData>()
    if not na(t0)
        bars.push(BarData.new(o0, h0, l0, c0, nz(ch0, h0), nz(cl0, l0), e0, v0))
        if array.size(s.oArr) > 0
            for i = 0 to array.size(s.oArr) - 1
                bars.push(BarData.new(
                     array.get(s.oArr, i), array.get(s.hArr, i),
                     array.get(s.lArr, i), array.get(s.cArr, i),
                     array.get(s.chArr, i), array.get(s.clArr, i),
                     array.get(s.eArr, i), array.get(s.vArr, i)))
    bars

// --- Store Initialization ---
var s1 = Store.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())
var s2 = Store.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())
var s3 = Store.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())
var s4 = Store.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())
var s5 = Store.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())
var s6 = Store.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())

data1 = show1 ? fetchData(sym1, tf1, s1, barsCount) : na
data2 = show2 ? fetchData(sym2, tf2, s2, barsCount) : na
data3 = show3 ? fetchData(sym3, tf3, s3, barsCount) : na
data4 = show4 ? fetchData(sym4, tf4, s4, barsCount) : na
data5 = show5 ? fetchData(sym5, tf5, s5, barsCount) : na
data6 = show6 ? fetchData(sym6, tf6, s6, barsCount) : na

// --- Global Context for Positioning ---
float g_fullH = ta.highest(high, 300)
float g_fullL = ta.lowest(low, 300)
float g_atr   = ta.atr(14)

// --- Drawing Arrays ---
var box[]   boxArr  = array.new<box>()
var line[]  lineArr = array.new<line>()
var label[] lblArr  = array.new<label>()

// --- Render Function ---
renderMini(array<BarData> bars, int col, int row, string tfName, string sName, bool useSmt, bool useEma, bool useVwap) =>
    if not na(bars) and array.size(bars) > 0
        float fullH = g_fullH
        float fullL = g_fullL
        float fullR = fullH - fullL
        if na(fullR) or fullR < (g_atr * 3)
            fullR := nz(g_atr * 3, syminfo.mintick * 100)

        float uH = fullR * ySizePerc
        float bY = fullH - (row - 1) * (uH + fullR * yGapRows) - uH
        int n = array.size(bars), cW = (barsCount - 1) * barSpacing
        int xS = bar_index + xOff + (col - 1) * (cW + xGapCols), xE = xS + cW

        if showBgBoxes
            array.push(boxArr, box.new(xS - barSpacing, bY + uH, xE + barSpacing + 5, bY,
                 bgcolor = color.new(color.gray, 95), border_color = color.new(color.gray, 80)))

        float dMax = -1.0e10, float dMin = 1.0e10
        for i = 0 to n - 1
            bv = array.get(bars, i)
            dMax := math.max(dMax, nz(bv.h, dMax))
            dMin := math.min(dMin, nz(bv.l, dMin))

        float diff = dMax - dMin
        float dR = diff <= 0 ? syminfo.mintick : diff * 1.25
        float sB = ((dMax + dMin) / 2) - (dR / 2)
        int bHW = math.max(1, int(barSpacing * 0.35))

        // --- SMT ---
        if useSmt and n > (smtLookback * 2)
            int lastH = -1, int lastL = -1
            for i = smtLookback to n - smtLookback - 1
                bp = array.get(bars, i)
                bool isPH = true, bool isPL = true
                for k = 1 to smtLookback
                    if nz(array.get(bars, i-k).h) > bp.h or nz(array.get(bars, i+k).h) > bp.h
                        isPH := false
                    if nz(array.get(bars, i-k).l) < bp.l or nz(array.get(bars, i+k).l) < bp.l
                        isPL := false
                if isPH
                    if lastH != -1
                        prev = array.get(bars, lastH)
                        if (bp.h - prev.h) * (bp.ch - prev.ch) < 0
                            array.push(lineArr, line.new(xS + (n-1-lastH)*barSpacing, bY+(prev.h-sB)/dR*uH, xS + (n-1-i)*barSpacing, bY+(bp.h-sB)/dR*uH, color = smtHighColor))
                            array.push(lblArr, label.new(xS + (n-1-i)*barSpacing, bY+(bp.h-sB)/dR*uH, "✦", style = label.style_label_down, color = #00000000, textcolor = smtHighColor, size = size.tiny))
                    lastH := i
                if isPL
                    if lastL != -1
                        prev = array.get(bars, lastL)
                        if (bp.l - prev.l) * (bp.cl - prev.cl) < 0
                            array.push(lineArr, line.new(xS + (n-1-lastL)*barSpacing, bY+(prev.l-sB)/dR*uH, xS + (n-1-i)*barSpacing, bY+(bp.l-sB)/dR*uH, color = smtLowColor))
                            array.push(lblArr, label.new(xS + (n-1-i)*barSpacing, bY+(bp.l-sB)/dR*uH, "❖", style = label.style_label_up, color = #00000000, textcolor = smtLowColor, size = size.tiny))
                    lastL := i

        // --- FVG ---
        bool foundIFVG = false
        for i = 0 to n - 1
            b = array.get(bars, i)
            int p = n-1-i, x = xS + p*barSpacing
            if showFvg and i <= n-4
                b1 = array.get(bars, i+1), b3 = array.get(bars, i+3)
                if b1.l > b3.h or b3.l > b1.h
                    isBu = b1.l > b3.h
                    fT = isBu ? b1.l : b3.l, fB = isBu ? b3.h : b1.h
                    isInv = false
                    for k = 0 to i
                        if (isBu and nz(array.get(bars, k).c) < fB) or (not isBu and nz(array.get(bars, k).c) > fT)
                            isInv := true
                            break
                    if isInv
                        if not foundIFVG
                            array.push(boxArr, box.new(xS + (n-1-(i+2))*barSpacing - bHW, bY+(fT-sB)/dR*uH, fvgExt == "Extended" ? xE + 4 : xS + (n-1-i) * barSpacing + bHW, bY+(fB-sB)/dR*uH, bgcolor = invFvgClr, border_color = na))
                            foundIFVG := true
                    else
                        array.push(boxArr, box.new(xS + (n-1-(i+2))*barSpacing - bHW, bY+(fT-sB)/dR*uH, fvgExt == "Extended" ? xE + 4 : xS + (n-1-i) * barSpacing + bHW, bY+(fB-sB)/dR*uH, bgcolor = isBu ? bullFvgClr : bearFvgClr, border_color = na))

            // --- Candle ---
            color c = b.c >= b.o ? bullColor : bearColor
            array.push(lineArr, line.new(x, bY+(b.h-sB)/dR*uH, x, bY+(b.l-sB)/dR*uH, color = c))
            array.push(boxArr, box.new(x-bHW, bY+(math.max(b.o,b.c)-sB)/dR*uH, x+bHW, bY+(math.min(b.o,b.c)-sB)/dR*uH, bgcolor = c, border_color = c))

        // --- EMA ---
        if showEma and useEma and n > 1
            for i = 0 to n - 2
                b1 = array.get(bars, i), b2 = array.get(bars, i + 1)
                if not na(b1.e) and not na(b2.e)
                    x1 = xS + (n-1-i) * barSpacing, x2 = xS + (n-1-(i+1)) * barSpacing
                    y1 = bY + math.max(0.0, math.min(1.0, (b1.e - sB) / dR)) * uH
                    y2 = bY + math.max(0.0, math.min(1.0, (b2.e - sB) / dR)) * uH
                    array.push(lineArr, line.new(x1, y1, x2, y2, color = emaColor, width = 1))

        // --- VWAP ---
        if showVwap and useVwap and n > 1
            for i = 0 to n - 2
                b1 = array.get(bars, i), b2 = array.get(bars, i + 1)
                if not na(b1.v) and not na(b2.v)
                    x1 = xS + (n-1-i) * barSpacing, x2 = xS + (n-1-(i+1)) * barSpacing
                    y1 = bY + math.max(0.0, math.min(1.0, (b1.v - sB) / dR)) * uH
                    y2 = bY + math.max(0.0, math.min(1.0, (b2.v - sB) / dR)) * uH
                    array.push(lineArr, line.new(x1, y1, x2, y2, color = vwapColor, width = 1))

        if showTfLabels
            array.push(lblArr, label.new(xS + cW / 2, bY, sName + " (" + tfName + ")", color = #00000000, textcolor = color.gray, style = label.style_label_down, size = size.small))

// --- Clear and Draw ---
if barstate.islast
    for b in boxArr
        box.delete(b)
    array.clear(boxArr)
    for l in lineArr
        line.delete(l)
    array.clear(lineArr)
    for lb in lblArr
        label.delete(lb)
    array.clear(lblArr)

    renderMini(data1, 1, 1, tf1, sym1, sSmt1, sEma1, sVwap1)
    renderMini(data2, 2, 1, tf2, sym2, sSmt2, sEma2, sVwap2)
    renderMini(data3, 1, 2, tf3, sym3, sSmt3, sEma3, sVwap3)
    renderMini(data4, 2, 2, tf4, sym4, sSmt4, sEma4, sVwap4)
    renderMini(data5, 1, 3, tf5, sym5, sSmt5, sEma5, sVwap5)
    renderMini(data6, 2, 3, tf6, sym6, sSmt6, sEma6, sVwap6)
````
