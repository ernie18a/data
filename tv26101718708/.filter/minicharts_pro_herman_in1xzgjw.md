# Minicharts Pro+ [Herman]

- url: https://www.tradingview.com/script/IN1XzgJw-Minicharts-Pro-Herman/
- type: indicator
- pine_id: PUB;9a56439aff3547b993a675dcc0e4fba6
- version: 5.0

## Description

[b]Minicharts Pro+ [Herman][/b]

[b]Minicharts Pro+ [Herman][/b] is a multi-timeframe visualization tool designed to display higher timeframe price action directly on your current chart.

The script renders multiple compact “mini charts” representing selected timeframes, allowing users to observe structure, candle behavior, and relative positioning without switching between charts.

It is intended for traders who want to maintain awareness of higher timeframe context while working on a lower timeframe, without interrupting their workflow.

[b]Purpose[/b]

The main purpose of this tool is to improve chart workflow and situational awareness by:

Providing a clear overview of multiple timeframes in one place
Reducing the need to switch between charts
Helping users visually align lower timeframe activity with higher timeframe structure

This script is designed as a visual analysis aid and can be used alongside any trading methodology.

[b]How it works[/b]

The indicator uses request.security() to retrieve OHLC data from selected timeframes and reconstructs them as miniature charts displayed on the right side of the screen.

[b]Each mini chart:[/b]

Displays historical candles from the selected timeframe
Is scaled dynamically based on recent price range and volatility
Is rendered independently to preserve clarity of structure

The layout is organized in a grid format, where each panel represents a different timeframe.
Users can adjust positioning, spacing, and sizing to fit their chart preferences.

[b]Moving Averages & VWAP[/b]

Each mini chart includes optional overlays for additional visual context:

EMA (Exponential Moving Average)
VWAP (Volume Weighted Average Price)

These can be enabled or disabled individually for each mini chart, allowing flexible customization depending on user preference.

Both EMA and VWAP are calculated using standard methods based on the selected timeframe data and are displayed purely for reference.

[b]SMT [/b](Intermarket Comparison)

The script includes an optional SMT-style comparison feature between correlated instruments.

By default, the script automatically selects a related symbol (e.g., NQ ↔ ES, GC ↔ SI)
Users can manually override the symbol if needed
Pivot-based comparisons are used to highlight differences in swing highs and lows between instruments

This feature provides a visual way to compare price behavior between instruments and is based solely on historical price data.

[b]HTF FVG Visualization[/b]

Optional higher timeframe imbalance (FVG) zones can be displayed within each mini chart.

Both standard and inverted FVG structures are supported
Users can choose between extended zones or next-bar-only display
Only the most recent inverted FVG is highlighted to reduce visual clutter

These zones are derived from candle relationships within the selected timeframe and are provided for visual reference only.

[b]Inputs & Customization[/b]

The script provides multiple configuration options to adapt to different workflows:

[b]Minicharts Setup[/b]

Up to 6 independent timeframes
Enable/disable each mini chart
Optional SMT overlay per timeframe
Individual EMA and VWAP toggles per mini chart

SMT Configuration

Automatic or manual symbol selection
Pivot lookback setting
Custom colors for high/low comparisons

[b]HTF FVG Configuration[/b]

Enable/disable FVG display
Extension mode selection
Custom colors for bullish, bearish, and inverted zones

[b]Style & Layout[/b]

Number of candles displayed per mini chart
Spacing and positioning
Chart size and grid layout
Candle colors and background frames
Timeframe label visibility

[b]Notes[/b]
This script is designed for visualization purposes only
It does not generate trading signals, alerts, or recommendations
All calculations are based on historical price data
The tool is intended to support chart analysis, not replace independent decision-making

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Modified by Herman Trading & Quant

//@version=6
indicator("Minicharts Pro+ Bias [Herman]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 20)

// ============================================================================
// AUTO SMT SYMBOL
// ============================================================================
getAutoSmtSymbol() =>
    string root = syminfo.root
    string target = syminfo.tickerid
    if root == "NQ" or root == "MNQ"
        target := "CME_MINI:ES1!"
    else if root == "ES" or root == "MES"
        target := "CME_MINI:NQ1!"
    else if root == "YM" or root == "MYM"
        target := "CME_MINI:ES1!"
    else if root == "GC" or root == "MGC"
        target := "COMEX:SI1!"
    else if root == "SI"
        target := "COMEX:GC1!"
    else if root == "CL" or root == "MCL"
        target := "NYMEX:RB1!"
    else if root == "RB"
        target := "NYMEX:CL1!"
    target

string activeAutoSym = getAutoSmtSymbol()

// ============================================================================
// GROUPS
// ============================================================================
string G_C     = "Minicharts Setup"
string G_SMT   = "SMT Configuration"
string G_EMA   = "EMA Configuration"
string G_VWAP  = "VWAP Configuration"
string G_FVG   = "HTF FVG Configuration"
string G_BIAS  = "Bias Framework"
string G_ST    = "Style & Layout"

// ============================================================================
// INPUTS
// ============================================================================
bool show1 = input.bool(true, "1", group = G_C, inline = "c1")
string tf1 = input.timeframe("1", "", group = G_C, inline = "c1")
bool sSmt1 = input.bool(true, "SMT", group = G_C, inline = "c1")
bool sEma1 = input.bool(true, "EMA", group = G_C, inline = "c1")
bool sVwap1 = input.bool(true, "VWAP", group = G_C, inline = "c1")

bool show2 = input.bool(true, "2", group = G_C, inline = "c2")
string tf2 = input.timeframe("5", "", group = G_C, inline = "c2")
bool sSmt2 = input.bool(true, "SMT", group = G_C, inline = "c2")
bool sEma2 = input.bool(true, "EMA", group = G_C, inline = "c2")
bool sVwap2 = input.bool(true, "VWAP", group = G_C, inline = "c2")

bool show3 = input.bool(true, "3", group = G_C, inline = "c3")
string tf3 = input.timeframe("60", "", group = G_C, inline = "c3")
bool sSmt3 = input.bool(true, "SMT", group = G_C, inline = "c3")
bool sEma3 = input.bool(true, "EMA", group = G_C, inline = "c3")
bool sVwap3 = input.bool(true, "VWAP", group = G_C, inline = "c3")

bool show4 = input.bool(true, "4", group = G_C, inline = "c4")
string tf4 = input.timeframe("240", "", group = G_C, inline = "c4")
bool sSmt4 = input.bool(true, "SMT", group = G_C, inline = "c4")
bool sEma4 = input.bool(true, "EMA", group = G_C, inline = "c4")
bool sVwap4 = input.bool(true, "VWAP", group = G_C, inline = "c4")

bool show5 = input.bool(true, "5", group = G_C, inline = "c5")
string tf5 = input.timeframe("D", "", group = G_C, inline = "c5")
bool sSmt5 = input.bool(true, "SMT", group = G_C, inline = "c5")
bool sEma5 = input.bool(true, "EMA", group = G_C, inline = "c5")
bool sVwap5 = input.bool(true, "VWAP", group = G_C, inline = "c5")

bool show6 = input.bool(true, "6", group = G_C, inline = "c6")
string tf6 = input.timeframe("W", "", group = G_C, inline = "c6")
bool sSmt6 = input.bool(true, "SMT", group = G_C, inline = "c6")
bool sEma6 = input.bool(true, "EMA", group = G_C, inline = "c6")
bool sVwap6 = input.bool(true, "VWAP", group = G_C, inline = "c6")

string SMT_TIP = "Auto SMT pairs:\n- NQ/MNQ ↔ ES\n- YM/MYM ↔ ES\n- ES/MES ↔ NQ\n- GC/MGC ↔ SI\n- CL/MCL ↔ RB"
bool showSmtLabel = input.bool(true, "Show Active SMT Symbol Label", group = G_SMT)
bool manualOverride = input.bool(false, "Manual Symbol Override", group = G_SMT, tooltip = SMT_TIP)
string manualSymbol = input.symbol("CME_MINI:ES1!", "Manual Symbol", group = G_SMT, active = manualOverride)
int smtLookback = input.int(3, "Pivot Lookback", minval = 2, maxval = 10, group = G_SMT)
bool showConfirmedSmt = input.bool(true, "Show SMT", group = G_SMT)
bool showDevelopingSmt = input.bool(true, "Show DEVELOPING SMT", group = G_SMT)
int smtLineWidth = input.int(1, "SMT Line Width", minval = 1, maxval = 4, group = G_SMT)
int smtDevelopingLineWidth = input.int(1, "Developing SMT Line Width", minval = 1, maxval = 4, group = G_SMT)
color smtHighColor = input.color(color.black, "Bearish / High SMT", group = G_SMT)
color smtLowColor = input.color(color.black, "Bullish / Low SMT", group = G_SMT)

string activeSmtSym = manualOverride ? manualSymbol : activeAutoSym

// EMA
bool showEma   = input.bool(false, "Show EMA on Minicharts", group = G_EMA)
int emaPeriod  = input.int(200, "EMA Period", minval = 1, group = G_EMA, active = showEma)
color emaColor = input.color(color.new(color.yellow, 10), "EMA Color", group = G_EMA, active = showEma)

// VWAP
bool showVwap   = input.bool(false, "Show VWAP on Minicharts", group = G_VWAP)
color vwapColor = input.color(color.new(color.blue, 10), "VWAP Color", group = G_VWAP, active = showVwap)

// FVG
bool showFvg = input.bool(true, "Show HTF FVG", group = G_FVG)
string fvgExt = input.string("Next Bar Only", "Extension Mode", options = ["Extended", "Next Bar Only"], group = G_FVG, active = showFvg)
color bullFvgClr = input.color(color.new(#089981, 80), "Bullish FVG", group = G_FVG, active = showFvg)
color bearFvgClr = input.color(color.new(#f23645, 80), "Bearish FVG", group = G_FVG, active = showFvg)
color invFvgClr = input.color(color.new(#9c27b0, 80), "Inverted FVG", group = G_FVG, active = showFvg)

// Bias
bool showBias      = input.bool(false, "Show Bias Labels", group = G_BIAS)
bool highlightBias = input.bool(false, "Highlight Signal Candles", group = G_BIAS)
color biasBull     = input.color(#089981, "Bullish Bias Color", group = G_BIAS)
color biasBear     = input.color(#f23645, "Bearish Bias Color", group = G_BIAS)
color biasAvoid    = input.color(color.gray, "Avoid Bias Color", group = G_BIAS)

// Style
// barsCount is now the TOTAL number of visible candles, including the developing candle.
int barsCount = input.int(30, "Total Bars to Show", minval = 10, maxval = 60, group = G_ST,
     tooltip = "Total candles visible in each minichart, including the current developing candle.")
int barSpacing = input.int(5, "Bar Spacing", minval = 3, maxval = 10, group = G_ST)
bool showBgBoxes = input.bool(true, "Show Background Frames", group = G_ST)
color bullColor = input.color(#089981, "Bull Candle", group = G_ST)
color bearColor = input.color(#f23645, "Bear Candle", group = G_ST)
int xOff = input.int(50, "Right Offset", minval = 1, group = G_ST)
int xGapCols = input.int(35, "Column Gap", minval = 1, group = G_ST)
float ySizePerc = input.float(0.2, "Chart Height (%)", minval = 0.05, group = G_ST)
float yGapRows = input.float(0.05, "Row Gap (%)", minval = 0.0, group = G_ST)
bool showTfLabels = input.bool(true, "Show Timeframe Labels", group = G_ST)

// ============================================================================
// TYPES
// ============================================================================
type BarData
    float o
    float h
    float l
    float c
    float ch
    float cl
    float e
    float v
    int   t

type Store
    float[] oArr
    float[] hArr
    float[] lArr
    float[] cArr
    float[] chArr
    float[] clArr
    float[] eArr
    float[] vArr
    int[]   tArr

// ============================================================================
// STORE HELPERS
// ============================================================================
pushToStore(Store s, float o, float h, float l, float c, float ch, float cl, float e, float v, int t, int maxCount) =>
    if not na(t) and array.indexof(s.tArr, t) == -1
        array.unshift(s.oArr, o)
        array.unshift(s.hArr, h)
        array.unshift(s.lArr, l)
        array.unshift(s.cArr, c)
        array.unshift(s.chArr, nz(ch, h))
        array.unshift(s.clArr, nz(cl, l))
        array.unshift(s.eArr, e)
        array.unshift(s.vArr, v)
        array.unshift(s.tArr, t)

    while array.size(s.tArr) > maxCount
        array.pop(s.oArr)
        array.pop(s.hArr)
        array.pop(s.lArr)
        array.pop(s.cArr)
        array.pop(s.chArr)
        array.pop(s.clArr)
        array.pop(s.eArr)
        array.pop(s.vArr)
        array.pop(s.tArr)

storeToBars(Store s, int count) =>
    array<BarData> result = array.new<BarData>()
    int n = math.min(count, array.size(s.tArr))
    if n > 0
        for i = 0 to n - 1
            array.push(result, BarData.new(
                 array.get(s.oArr, i), array.get(s.hArr, i),
                 array.get(s.lArr, i), array.get(s.cArr, i),
                 array.get(s.chArr, i), array.get(s.clArr, i),
                 array.get(s.eArr, i), array.get(s.vArr, i),
                 array.get(s.tArr, i)))
    result

// ============================================================================
// HYBRID DATA ENGINE
// - HTF/equal TF: request.security()
// - Lower TF:    request.security_lower_tf(), collecting every available intrabar
// - IMPORTANT: requests intentionally use the full available chart history.
//   A fixed calc_bars_count value starves the HTF stores on low chart timeframes
//   (e.g. 500 x 1m bars provide only ~8 hourly and ~2 four-hour transitions).
// ============================================================================
fetchData(string tf, string corr, Store s, int count) =>
    float requestedSeconds = timeframe.in_seconds(tf)
    float chartSeconds = timeframe.in_seconds()
    bool isLowerTf = not na(requestedSeconds) and not na(chartSeconds) and requestedSeconds < chartSeconds

    array<BarData> bars = array.new<BarData>()

    if isLowerTf
        [oA, hA, lA, cA, eA, vA, tA] = request.security_lower_tf(
             syminfo.tickerid, tf,
             [open, high, low, close, ta.ema(close, emaPeriod), ta.vwap, time],
             ignore_invalid_timeframe = true)

        [chA, clA, ctA] = request.security_lower_tf(
             corr, tf, [high, low, time],
             ignore_invalid_symbol = true,
             ignore_invalid_timeframe = true)

        int intrabars = array.size(tA)
        if intrabars > 0
            // Arrays from request.security_lower_tf() are oldest -> newest.
            // pushToStore() unshifts them, leaving newest at index 0.
            for i = 0 to intrabars - 1
                int ti = array.get(tA, i)
                int corrIndex = array.indexof(ctA, ti)
                float ownH = array.get(hA, i)
                float ownL = array.get(lA, i)
                float corrH = corrIndex >= 0 ? array.get(chA, corrIndex) : ownH
                float corrL = corrIndex >= 0 ? array.get(clA, corrIndex) : ownL

                pushToStore(s,
                     array.get(oA, i), ownH, ownL, array.get(cA, i),
                     corrH, corrL, array.get(eA, i), array.get(vA, i), ti, count)

        bars := storeToBars(s, count)

    else
        [o0, h0, l0, c0, e0, v0, t0,
         o1, h1, l1, c1, e1, v1, t1] = request.security(
             syminfo.tickerid, tf,
             [open, high, low, close, ta.ema(close, emaPeriod), ta.vwap, time,
              open[1], high[1], low[1], close[1], ta.ema(close, emaPeriod)[1], ta.vwap[1], time[1]])

        [ch0, cl0, ch1, cl1] = request.security(
             corr, tf, [high, low, high[1], low[1]],
             ignore_invalid_symbol = true)

        bool tfChanged = ta.change(t0) != 0
        if not na(t0) and tfChanged
            // Keep only count - 1 closed bars because the current developing bar
            // is inserted separately below. This fixes the old 30 -> 31 bars bug.
            pushToStore(s, o1, h1, l1, c1, ch1, cl1, e1, v1, t1, math.max(0, count - 1))

        if not na(t0)
            array.push(bars, BarData.new(o0, h0, l0, c0, nz(ch0, h0), nz(cl0, l0), e0, v0, t0))

        int closedToAdd = math.min(math.max(0, count - array.size(bars)), array.size(s.tArr))
        if closedToAdd > 0
            for i = 0 to closedToAdd - 1
                array.push(bars, BarData.new(
                     array.get(s.oArr, i), array.get(s.hArr, i),
                     array.get(s.lArr, i), array.get(s.cArr, i),
                     array.get(s.chArr, i), array.get(s.clArr, i),
                     array.get(s.eArr, i), array.get(s.vArr, i),
                     array.get(s.tArr, i)))

    bars

// ============================================================================
// STORE INITIALIZATION
// ============================================================================
newStore() =>
    Store.new(
         array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(),
         array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(),
         array.new<int>())

var Store s1 = newStore()
var Store s2 = newStore()
var Store s3 = newStore()
var Store s4 = newStore()
var Store s5 = newStore()
var Store s6 = newStore()

array<BarData> data1 = show1 ? fetchData(tf1, activeSmtSym, s1, barsCount) : array.new<BarData>()
array<BarData> data2 = show2 ? fetchData(tf2, activeSmtSym, s2, barsCount) : array.new<BarData>()
array<BarData> data3 = show3 ? fetchData(tf3, activeSmtSym, s3, barsCount) : array.new<BarData>()
array<BarData> data4 = show4 ? fetchData(tf4, activeSmtSym, s4, barsCount) : array.new<BarData>()
array<BarData> data5 = show5 ? fetchData(tf5, activeSmtSym, s5, barsCount) : array.new<BarData>()
array<BarData> data6 = show6 ? fetchData(tf6, activeSmtSym, s6, barsCount) : array.new<BarData>()

// ============================================================================
// GLOBAL CONTEXT + SAFE BAR-INDEX LAYOUT
//
// xloc.bar_time caused future minicharts to collapse at the visible chart edge
// because TradingView does not reserve horizontal bar space for arbitrary
// future timestamps. We therefore use bar_index again, but automatically
// compress only combinations that would exceed the 500-future-bar limit.
// Default settings retain exactly the original spacing and proportions.
// ============================================================================
float g_fullH = ta.highest(high, 300)
float g_fullL = ta.lowest(low, 300)
float g_atr   = ta.atr(14)

int rawFrameWidthUnits = (barsCount - 1) * barSpacing
int rawTotalLayoutUnits = xOff + rawFrameWidthUnits * 2 + xGapCols + barSpacing + 5
int maxFutureLayoutBars = 490
float layoutScale = math.min(1.0, maxFutureLayoutBars / math.max(1.0, float(rawTotalLayoutUnits)))

layoutX(int units) =>
    bar_index + int(math.round(units * layoutScale))

// ============================================================================
// DRAWING STORAGE
// ============================================================================
var table smtTbl = table.new(position.top_right, 1, 1)
var box[] boxArr = array.new<box>()
var line[] lineArr = array.new<line>()
var label[] lblArr = array.new<label>()
var polyline[] polyArr = array.new<polyline>()

// ============================================================================
// RENDER FUNCTION
// ============================================================================
renderMini(array<BarData> bars, int col, int row, string tfName, bool useSmt, bool useEma, bool useVwap) =>
    int n = array.size(bars)
    if n > 0
        float fullH = g_fullH
        float fullL = g_fullL
        float fullR = fullH - fullL
        if na(fullR) or fullR < g_atr * 3
            fullR := nz(g_atr * 3, syminfo.mintick * 100)

        float uH = fullR * ySizePerc
        float bY = fullH - (row - 1) * (uH + fullR * yGapRows) - uH

        int frameWidthUnits = (barsCount - 1) * barSpacing
        int columnStrideUnits = frameWidthUnits + xGapCols
        int xSUnits = xOff + (col - 1) * columnStrideUnits
        int xEUnits = xSUnits + frameWidthUnits
        int xS = layoutX(xSUnits)
        int xE = layoutX(xEUnits)
        int bHWUnits = math.max(1, int(barSpacing * 0.35))
        int bHWBars = math.max(1, int(math.round(bHWUnits * layoutScale)))

        if showBgBoxes
            array.push(boxArr, box.new(
                 layoutX(xSUnits - barSpacing), bY + uH,
                 layoutX(xEUnits + barSpacing + 5), bY,
                 xloc = xloc.bar_index,
                 bgcolor = color.new(color.gray, 95),
                 border_color = color.new(color.gray, 80)))

        float dMax = -1.0e10
        float dMin = 1.0e10
        for i = 0 to n - 1
            BarData bv = array.get(bars, i)
            dMax := math.max(dMax, nz(bv.h, dMax))
            dMin := math.min(dMin, nz(bv.l, dMin))

        float diff = dMax - dMin
        float dR = diff <= 0 ? syminfo.mintick : diff * 1.25
        float sB = ((dMax + dMin) / 2.0) - (dR / 2.0)

        // --------------------------------------------------------------------
        // BIAS: uses only the two most recent CLOSED candles (indexes 2 and 1).
        // --------------------------------------------------------------------
        if n > 2
            BarData c1 = array.get(bars, 2)
            BarData c2 = array.get(bars, 1)

            string biasTxt = "AVOID X"
            color biasClr = biasAvoid

            bool sweepHigh = c2.h > c1.h
            bool sweepLow = c2.l < c1.l
            bool inside = c2.h <= c1.h and c2.l >= c1.l
            bool outside = sweepHigh and sweepLow

            if outside or inside
                biasTxt := "AVOID X"
                biasClr := biasAvoid
            else if sweepHigh
                if c2.c > c1.h
                    biasTxt := "BULLISH"
                    biasClr := biasBull
                else
                    biasTxt := "BEARISH"
                    biasClr := biasBear
            else if sweepLow
                if c2.c < c1.l
                    biasTxt := "BEARISH"
                    biasClr := biasBear
                else
                    biasTxt := "BULLISH"
                    biasClr := biasBull

            if showBias
                array.push(lblArr, label.new(
                     layoutX(xSUnits + int(frameWidthUnits * 0.5)), bY + uH, biasTxt,
                     xloc = xloc.bar_index,
                     color = #00000000, textcolor = biasClr,
                     style = label.style_label_down, size = size.small))

            if highlightBias
                int x1 = layoutX(xEUnits - 2 * barSpacing - bHWUnits)
                int x2 = layoutX(xEUnits - 1 * barSpacing + bHWUnits)
                array.push(boxArr, box.new(
                     x1, bY + uH, x2, bY,
                     xloc = xloc.bar_index,
                     bgcolor = color.new(biasClr, 95), border_color = na))
                array.push(lineArr, line.new(
                     x1, bY, x2, bY,
                     xloc = xloc.bar_index,
                     color = biasClr, width = 2))

        // --------------------------------------------------------------------
        // SMT ENGINE
        // SMT (confirmed):
        //   - pivot requires smtLookback CLOSED candles on both sides
        //   - current developing candle (index 0) is never used for confirmation
        // DEVELOPING:
        //   - one market has broken the latest confirmed pivot, the other has not
        //   - dashed and may change until a new pivot becomes confirmed
        // --------------------------------------------------------------------
        if useSmt and n > smtLookback * 2 + 2
            int mostRecentHighPivot = -1
            int previousHighPivot = -1
            int mostRecentLowPivot = -1
            int previousLowPivot = -1
            int confirmedHighDrawn = 0
            int confirmedLowDrawn = 0
            int maxConfirmedPerSide = 8

            int firstConfirmable = smtLookback + 1
            int lastConfirmable = n - smtLookback - 1

            if firstConfirmable <= lastConfirmable
                for i = firstConfirmable to lastConfirmable
                    BarData bp = array.get(bars, i)
                    bool isPH = true
                    bool isPL = true

                    for k = 1 to smtLookback
                        BarData newer = array.get(bars, i - k)
                        BarData older = array.get(bars, i + k)
                        if newer.h > bp.h or older.h > bp.h
                            isPH := false
                        if newer.l < bp.l or older.l < bp.l
                            isPL := false

                    if isPH
                        if mostRecentHighPivot == -1
                            mostRecentHighPivot := i
                        if previousHighPivot != -1 and showConfirmedSmt and confirmedHighDrawn < maxConfirmedPerSide
                            BarData recent = array.get(bars, previousHighPivot)
                            BarData prior = bp
                            bool mainHH = recent.h > prior.h
                            bool corrHH = recent.ch > prior.ch
                            bool confirmedBearSmt = mainHH != corrHH

                            if confirmedBearSmt
                                int xOld = layoutX(xEUnits - i * barSpacing)
                                int xNew = layoutX(xEUnits - previousHighPivot * barSpacing)
                                float yOld = bY + (prior.h - sB) / dR * uH
                                float yNew = bY + (recent.h - sB) / dR * uH
                                array.push(lineArr, line.new(
                                     xOld, yOld, xNew, yNew,
                                     xloc = xloc.bar_index,
                                     color = smtHighColor, style = line.style_solid, width = smtLineWidth))
                                array.push(lblArr, label.new(
                                     xNew, yNew, "SMT",
                                     xloc = xloc.bar_index,
                                     style = label.style_label_down,
                                     color = #00000000, textcolor = smtHighColor, size = size.tiny))
                                confirmedHighDrawn += 1
                        previousHighPivot := i

                    if isPL
                        if mostRecentLowPivot == -1
                            mostRecentLowPivot := i
                        if previousLowPivot != -1 and showConfirmedSmt and confirmedLowDrawn < maxConfirmedPerSide
                            BarData recent = array.get(bars, previousLowPivot)
                            BarData prior = bp
                            bool mainLL = recent.l < prior.l
                            bool corrLL = recent.cl < prior.cl
                            bool confirmedBullSmt = mainLL != corrLL

                            if confirmedBullSmt
                                int xOld = layoutX(xEUnits - i * barSpacing)
                                int xNew = layoutX(xEUnits - previousLowPivot * barSpacing)
                                float yOld = bY + (prior.l - sB) / dR * uH
                                float yNew = bY + (recent.l - sB) / dR * uH
                                array.push(lineArr, line.new(
                                     xOld, yOld, xNew, yNew,
                                     xloc = xloc.bar_index,
                                     color = smtLowColor, style = line.style_solid, width = smtLineWidth))
                                array.push(lblArr, label.new(
                                     xNew, yNew, "SMT",
                                     xloc = xloc.bar_index,
                                     style = label.style_label_up,
                                     color = #00000000, textcolor = smtLowColor, size = size.tiny))
                                confirmedLowDrawn += 1
                        previousLowPivot := i

            if showDevelopingSmt
                // Developing bearish SMT above the latest confirmed swing high.
                if mostRecentHighPivot > 0
                    BarData pivotH = array.get(bars, mostRecentHighPivot)
                    float mainMax = -1.0e10
                    float corrMax = -1.0e10
                    int mainMaxIndex = 0
                    for j = 0 to mostRecentHighPivot - 1
                        BarData candidate = array.get(bars, j)
                        if candidate.h > mainMax
                            mainMax := candidate.h
                            mainMaxIndex := j
                        corrMax := math.max(corrMax, candidate.ch)

                    bool mainBrokeHigh = mainMax > pivotH.h
                    bool corrBrokeHigh = corrMax > pivotH.ch
                    if mainBrokeHigh != corrBrokeHigh
                        int xPivot = layoutX(xEUnits - mostRecentHighPivot * barSpacing)
                        int xDev = layoutX(xEUnits - mainMaxIndex * barSpacing)
                        float yPivot = bY + (pivotH.h - sB) / dR * uH
                        float yDev = bY + (mainMax - sB) / dR * uH
                        color devColor = color.new(smtHighColor, 25)
                        array.push(lineArr, line.new(
                             xPivot, yPivot, xDev, yDev,
                             xloc = xloc.bar_index,
                             color = devColor, style = line.style_dashed, width = smtDevelopingLineWidth))
                        array.push(lblArr, label.new(
                             xDev, yDev, "DEV SMT",
                             xloc = xloc.bar_index,
                             style = label.style_label_down,
                             color = #00000000, textcolor = devColor, size = size.tiny))

                // Developing bullish SMT below the latest confirmed swing low.
                if mostRecentLowPivot > 0
                    BarData pivotL = array.get(bars, mostRecentLowPivot)
                    float mainMin = 1.0e10
                    float corrMin = 1.0e10
                    int mainMinIndex = 0
                    for j = 0 to mostRecentLowPivot - 1
                        BarData candidate = array.get(bars, j)
                        if candidate.l < mainMin
                            mainMin := candidate.l
                            mainMinIndex := j
                        corrMin := math.min(corrMin, candidate.cl)

                    bool mainBrokeLow = mainMin < pivotL.l
                    bool corrBrokeLow = corrMin < pivotL.cl
                    if mainBrokeLow != corrBrokeLow
                        int xPivot = layoutX(xEUnits - mostRecentLowPivot * barSpacing)
                        int xDev = layoutX(xEUnits - mainMinIndex * barSpacing)
                        float yPivot = bY + (pivotL.l - sB) / dR * uH
                        float yDev = bY + (mainMin - sB) / dR * uH
                        color devColor = color.new(smtLowColor, 25)
                        array.push(lineArr, line.new(
                             xPivot, yPivot, xDev, yDev,
                             xloc = xloc.bar_index,
                             color = devColor, style = line.style_dashed, width = smtDevelopingLineWidth))
                        array.push(lblArr, label.new(
                             xDev, yDev, "DEV SMT",
                             xloc = xloc.bar_index,
                             style = label.style_label_up,
                             color = #00000000, textcolor = devColor, size = size.tiny))

        // --------------------------------------------------------------------
        // FVG + CANDLES
        // --------------------------------------------------------------------
        bool foundIFVG = false
        int fvgDrawn = 0
        int maxFvgPerMini = 18
        for i = 0 to n - 1
            BarData b = array.get(bars, i)
            int x = layoutX(xEUnits - i * barSpacing)

            if showFvg and i <= n - 4
                BarData b1 = array.get(bars, i + 1)
                BarData b3 = array.get(bars, i + 3)
                if b1.l > b3.h or b3.l > b1.h
                    bool isBu = b1.l > b3.h
                    float fT = isBu ? b1.l : b3.l
                    float fB = isBu ? b3.h : b1.h
                    bool isInv = false

                    for k = 0 to i
                        BarData laterBar = array.get(bars, k)
                        if (isBu and nz(laterBar.c) < fB) or (not isBu and nz(laterBar.c) > fT)
                            isInv := true
                            break

                    int fvgLeft = layoutX(xEUnits - (i + 2) * barSpacing - bHWUnits)
                    int fvgRight = fvgExt == "Extended" ? layoutX(xEUnits + 4) : layoutX(xEUnits - i * barSpacing + bHWUnits)
                    float fvgTopY = bY + (fT - sB) / dR * uH
                    float fvgBottomY = bY + (fB - sB) / dR * uH

                    if fvgDrawn < maxFvgPerMini
                        if isInv
                            if not foundIFVG
                                array.push(boxArr, box.new(
                                     fvgLeft, fvgTopY, fvgRight, fvgBottomY,
                                     xloc = xloc.bar_index,
                                     bgcolor = invFvgClr, border_color = na))
                                foundIFVG := true
                                fvgDrawn += 1
                        else
                            array.push(boxArr, box.new(
                                 fvgLeft, fvgTopY, fvgRight, fvgBottomY,
                                 xloc = xloc.bar_index,
                                 bgcolor = isBu ? bullFvgClr : bearFvgClr, border_color = na))
                            fvgDrawn += 1

            color candleColor = b.c >= b.o ? bullColor : bearColor
            array.push(lineArr, line.new(
                 x, bY + (b.h - sB) / dR * uH,
                 x, bY + (b.l - sB) / dR * uH,
                 xloc = xloc.bar_index,
                 color = candleColor))
            array.push(boxArr, box.new(
                 x - bHWBars, bY + (math.max(b.o, b.c) - sB) / dR * uH,
                 x + bHWBars, bY + (math.min(b.o, b.c) - sB) / dR * uH,
                 xloc = xloc.bar_index,
                 bgcolor = candleColor, border_color = candleColor))

        // --------------------------------------------------------------------
        // EMA + VWAP AS POLYLINES
        // Same data points and exact same Y transformation as before.
        // One object per line instead of n-1 separate line objects.
        // --------------------------------------------------------------------
        if showEma and useEma and n > 1
            array<chart.point> emaPoints = array.new<chart.point>()
            for p = 0 to n - 1
                int i = n - 1 - p
                BarData b = array.get(bars, i)
                if not na(b.e)
                    int px = layoutX(xEUnits - i * barSpacing)
                    float py = bY + math.max(0.0, math.min(1.0, (b.e - sB) / dR)) * uH
                    array.push(emaPoints, chart.point.from_index(px, py))
            if array.size(emaPoints) > 1
                array.push(polyArr, polyline.new(
                     emaPoints, curved = false, closed = false,
                     xloc = xloc.bar_index,
                     line_color = emaColor, line_width = 1))

        if showVwap and useVwap and n > 1
            array<chart.point> vwapPoints = array.new<chart.point>()
            for p = 0 to n - 1
                int i = n - 1 - p
                BarData b = array.get(bars, i)
                if not na(b.v)
                    int px = layoutX(xEUnits - i * barSpacing)
                    float py = bY + math.max(0.0, math.min(1.0, (b.v - sB) / dR)) * uH
                    array.push(vwapPoints, chart.point.from_index(px, py))
            if array.size(vwapPoints) > 1
                array.push(polyArr, polyline.new(
                     vwapPoints, curved = false, closed = false,
                     xloc = xloc.bar_index,
                     line_color = vwapColor, line_width = 1))

        if showTfLabels
            array.push(lblArr, label.new(
                 layoutX(xSUnits + int(frameWidthUnits * 0.5)), bY, tfName,
                 xloc = xloc.bar_index,
                 color = #00000000, textcolor = color.gray,
                 style = label.style_label_down, size = size.small))

// ============================================================================
// DRAW
// ============================================================================
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

    for p in polyArr
        polyline.delete(p)
    array.clear(polyArr)

    if showSmtLabel
        table.cell(smtTbl, 0, 0,
             "SMT Linked Symbol: " + activeSmtSym,
             bgcolor = color.new(color.gray, 90),
             text_color = color.gray,
             text_size = size.small)

    renderMini(data1, 1, 1, tf1, sSmt1, sEma1, sVwap1)
    renderMini(data2, 2, 1, tf2, sSmt2, sEma2, sVwap2)
    renderMini(data3, 1, 2, tf3, sSmt3, sEma3, sVwap3)
    renderMini(data4, 2, 2, tf4, sSmt4, sEma4, sVwap4)
    renderMini(data5, 1, 3, tf5, sSmt5, sEma5, sVwap5)
    renderMini(data6, 2, 3, tf6, sSmt6, sEma6, sVwap6)
````
