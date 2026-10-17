# Trend Momentum Breakout [AlphaPine]

- url: https://www.tradingview.com/script/CtzvSeyv-Trend-Momentum-Breakout-AlphaPine/
- type: indicator
- pine_id: PUB;e165381637384376b267addf24b2db58
- version: 2.0

## Description

[b]Overview[/b]
Trend Momentum Breakout [AlphaPine] is built for traders who use trendline breaks as part of their market-structure review.
The indicator displays support and resistance trendline references, keeps the chart focused on recent structure, and highlights breakout conditions based on the selected confirmation settings.
It is designed to answer one focused chart-reading question:
Where is price showing a confirmed break of a support or resistance trendline reference?
This indicator is not a complete trading system. It is a structure layer that can be used alongside broader market context, price action, volume, higher-timeframe bias, risk planning, and a trader's own execution rules.

[b]What It Shows[/b]
[list]
[*]Support and resistance trendline references.
[*]Bullish breakout markers after resistance breaks.
[*]Bearish breakout markers after support breaks.
[*]Smaller and larger structure views.
[*]Optional volume confirmation.
[*]Optional moving averages for trend context.
[*]Optional structure point markers for visual review.
[*]Alerts for monitored breakout conditions.
[/list]
[b]Visual Legend[/b]
[list]
[*]Red line: resistance trendline reference.
[*]Green line: support trendline reference.
[*]Thicker line: larger structure.
[*]Thinner line: smaller structure.
[*]Dashed line: projected or recently broken trendline segment.
[*]Green up marker: bullish resistance breakout.
[*]Red down marker: bearish support breakout.
[*]Gray marker: optional structure point marker.
[/list]

[b]How To Use[/b]
Add the indicator to a liquid market and start with the default settings.
Use the visible trendline references as market-structure context. When a breakout marker appears, treat it as a confirmed structure event, not as an automatic trade entry.
Traders can adjust the structure scale, chart cleanliness, breakout confirmation, optional volume filter, display style, and optional moving averages to match their chart-reading workflow.
Alerts can be used to monitor breakout conditions without watching every chart continuously. Alerts should be treated as notifications, not automatic trade instructions.

[b]Confirmation Behavior[/b]
Breakout markers appear only after the indicator has enough confirmed chart structure to display an active trendline reference. A marker is shown when price confirms a break under the selected settings.
Optional volume confirmation can be enabled for traders who want an additional participation filter.

[b]Important Live-Chart Note[/b]
This indicator uses confirmed chart structure. Confirmed structure requires time to form, so historical trendlines can look cleaner than what a trader would have seen live at the original turning point.
This is normal for structure-based indicators. Historical plots should be used for review and learning, not as proof of profitability or as evidence that every past marker was tradable in real time.
For live use, wait for the current bar to close, the trendline to be confirmed, and the breakout marker or alert to appear under the selected settings.

[b]Settings Overview[/b]
The default settings are designed to keep the chart readable while showing recent support and resistance trendline structure.
Available controls include:
[list]
[*]Structure lookback and scale.
[*]Maximum visible lines.
[*]Trendline selectiveness.
[*]Advanced structure sensitivity.
[*]Scan depth and chart-performance balance.
[*]Breakout confirmation strictness.
[*]Optional volume confirmation.
[*]Recent marker display.
[*]Marker size and visibility.
[*]Trendline and marker colors.
[*]Optional moving averages.
[*]Alert controls and cooldown.
[/list]

[b]Moving Averages[/b]
Moving averages are included as an optional chart overlay only.
They are useful when traders want basic trend context without adding a separate moving average indicator. They do not turn Trend Momentum Breakout into a trend-following system and should still be interpreted with the broader chart.

[b]Best Use[/b]
This indicator is intended for markets and timeframes where traders already use trendline structure as part of their analysis.
Good fit:
[list]
[*]Trendline breakout review.
[*]Market structure mapping.
[*]Support and resistance break monitoring.
[*]Discretionary trade planning.
[*]Multi-timeframe chart review.
[*]Breakout watchlists with alert support.
[/list]
Less suitable for:
[list]
[*]Automatic buy/sell execution.
[*]Low-liquidity markets with erratic candles.
[*]Choppy conditions where trendline breaks may be less informative.
[*]Using historical markers as standalone proof of profitability.
[/list]

[b]Trading Notes[/b]
Resistance and support are often better understood as areas, not perfect single-price levels. This indicator draws trendlines as visual references because its purpose is trendline breakout mapping. Traders should still account for spread, volatility, liquidity, candle context, and nearby support/resistance zones.
Breakouts can fail. A confirmed trendline break does not remove the need for risk management, invalidation planning, and broader market context.

[b]What Makes It Useful[/b]
Trend Momentum Breakout helps organize trendline breakout analysis by combining structure references, confirmation markers, visual controls, optional volume context, optional moving averages, and alert support into one focused indicator.
The goal is not to replace a trader's decision process. The goal is to make trendline breakout structure easier to see, review, and monitor.

[b]Disclaimer[/b]
This indicator is for educational and analytical use only. It is not financial advice and does not guarantee any trading result. Traders are responsible for their own analysis, risk management, and execution decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha Pine

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha Pine
//
// Trend Momentum Breakout | AlphaPine
// Version 2.0 · 2026-10-07
//
// v2.0 is computed one confirmed bar at a time, and nothing it decides on a
// bar is revised later:
//   - a trendline forms on the bar its second pivot matures, from pivots
//     confirmed by that bar, and only if no candle body crossed it from its
//     first anchor to that bar;
//   - lines it displaces (overlap, small inside large, the per-side cap) and
//     lines past their projected extension retire on that bar and stay on the
//     chart, faded, up to it;
//   - a break is N consecutive closes beyond an active line, recorded on the
//     bar it happens;
//   - a close back across the broken line within the negation window negates
//     the break, as its own event.
// v1 rebuilt every line from the newest bar, so its history could change as
// new swings confirmed. v2's history is what the script showed in real time.
//
// Structure only: trendlines, breaks and their invalidation. No orders.

//@version=6
indicator("Trend Momentum Breakout | AlphaPine", shorttitle="TMB | AlphaPine", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

//=============================================================================
// Inputs
//=============================================================================
grpMain     = "Main"
grpBreakout = "Breakout"
grpAdv      = "Advanced"
grpEngine   = "Structure Engine"
grpDisp     = "Display"
grpCol      = "Colors"
grpMA       = "Moving Averages"
grpAlert    = "Alerts"

lookback   = input.int(500, "Lookback Bars", minval=300, maxval=5000, group=grpMain,
             tooltip="How far back a trendline's first anchor may lie.")
szInput    = input.string("Both", "Pivot Scale", options=["Small","Large","Both"], group=grpMain,
             tooltip="Small: 5/5 pivots with a responsive ATR filter. Large: 25/25 pivots with a wider ATR filter.")
maxLines   = input.int(5, "Max Active Lines", minval=1, maxval=20, group=grpMain,
             tooltip="Per side and pivot scale. When a new line would exceed it, the oldest active line of that side and scale retires.")
minTouches = input.int(2, "Min Touches", minval=2, maxval=5, group=grpMain,
             tooltip="Minimum touches required for a valid trendline.")

nBreak     = input.int(3, "Breakout Candles", minval=1, maxval=20, group=grpBreakout,
             tooltip="Consecutive closes beyond the line that confirm a break.")
breakAtr   = input.float(0.0, "Break Distance ATR", minval=0.0, maxval=5.0, step=0.1, group=grpBreakout,
             tooltip="The confirming close must also be this many ATR(14) beyond the line. 0 = off.")
volFilter  = input.bool(false, "Volume Filter", group=grpBreakout,
             tooltip="Require at least one breakout candle to have above-average volume.")
volMult    = input.float(1.5, "Volume ×", minval=1.0, maxval=5.0, step=0.1, group=grpBreakout,
             tooltip="Breakout candle volume must exceed this × SMA(volume, 20). Only used when Volume Filter is enabled.")
maFilter   = input.string("Off", "MA Filter", options=["Off","MA 1","MA 2","MA 3"], group=grpBreakout,
             tooltip="An upward break also needs a close above the selected moving average (Moving Averages group); a downward break, a close below it. The MA does not need to be shown.")
negBars    = input.int(12, "Negation Window", minval=1, maxval=100, group=grpBreakout,
             tooltip="A close back across the broken line within this many bars negates the break.")

pivotAge   = input.int(3, "Pivot Maturity", minval=1, maxval=10, group=grpAdv,
             tooltip="Bars to wait after a pivot is confirmed before it can anchor a trendline.")
minSlope   = input.float(1, "Min Slope %", minval=0, maxval=10, step=0.1, group=grpAdv,
             tooltip="Minimum steepness required. Filters flat lines. 0 = off.")
maxSlope   = input.float(0, "Max Slope %", minval=0, maxval=20, step=0.5, group=grpAdv,
             tooltip="Maximum steepness allowed. Filters too-steep lines. 0 = off.")

smallAtrMult = input.float(2.0, "Small Structure ATR", minval=0.5, maxval=10.0, step=0.1, group=grpEngine,
               tooltip="ATR movement needed to qualify smaller structure. Lower = more responsive, higher = cleaner.")
largeAtrMult = input.float(4.0, "Large Structure ATR", minval=1.0, maxval=15.0, step=0.1, group=grpEngine,
               tooltip="ATR movement needed to qualify larger structure. Lower = more lines, higher = broader structure.")
touchAtrMult = input.float(0.5, "Touch Tolerance ATR", minval=0.1, maxval=2.0, step=0.1, group=grpEngine,
               tooltip="Distance from the trendline allowed for an extra pivot touch.")
overlapPct   = input.float(30.0, "Overlap Filter %", minval=0.0, maxval=90.0, step=5.0, group=grpEngine,
               tooltip="Overlap amount used to remove similar trendlines. Higher = keep more nearby lines.")
smallDepth   = input.int(20, "Small Scan Depth", minval=5, maxval=60, group=grpEngine,
               tooltip="Number of recent smaller structure points a new point is paired with.")
largeDepth   = input.int(50, "Large Scan Depth", minval=10, maxval=100, group=grpEngine,
               tooltip="Number of recent larger structure points a new point is paired with.")

showBreak   = input.bool(true, "Show Break Markers", group=grpDisp)
showNeg     = input.bool(true, "Show Negation Markers", group=grpDisp)
showRetired = input.bool(true, "Show Retired Lines", group=grpDisp,
              tooltip="Lines that expired or were replaced stay on the chart, faded and dotted, up to the bar they retired.")
showInval   = input.bool(true, "Show Negation Window", group=grpDisp,
              tooltip="After a break, the broken line continues as a dotted line through the negation window; it stops where a negation happens.")

colRes    = input.color(color.red, "Resistance", group=grpCol)
colSup    = input.color(color.green, "Support", group=grpCol)
colBull   = input.color(color.green, "Upward Break", group=grpCol)
colBear   = input.color(color.red, "Downward Break", group=grpCol)
colNeg    = input.color(color.orange, "Negation", group=grpCol)
grayLines = input.bool(false, "Grayscale Trendlines", group=grpCol,
             tooltip="Makes support and resistance trendlines neutral. Break markers keep their directional colors.")

showMA  = input.bool(false, "Show MA", group=grpMA,
          tooltip="Chart overlay. A moving average only affects breaks when it is selected as the MA Filter.")
maType  = input.string("EMA", "Type", options=["SMA","EMA","WMA","RMA","VWMA"], group=grpMA)
ma1Len  = input.int(20, "MA 1", minval=0, maxval=1000, inline="ma1", group=grpMA, tooltip="0=off")
maCol1  = input.color(color.orange, "Color", inline="ma1", group=grpMA)
ma2Len  = input.int(50, "MA 2", minval=0, maxval=1000, inline="ma2", group=grpMA, tooltip="0=off")
maCol2  = input.color(color.blue, "Color", inline="ma2", group=grpMA)
ma3Len  = input.int(200, "MA 3", minval=0, maxval=1000, inline="ma3", group=grpMA, tooltip="0=off")
maCol3  = input.color(color.purple, "Color", inline="ma3", group=grpMA)

alertOn  = input.bool(true, "Enable Alerts", group=grpAlert)
alertRes = input.bool(true, "Upward Breaks", group=grpAlert)
alertSup = input.bool(true, "Downward Breaks", group=grpAlert)
alertNeg = input.bool(true, "Negations", group=grpAlert)

//=============================================================================
// Types
//=============================================================================
type Piv
    int   idx
    float price
    float atr
    bool  isHigh
    int   size        // 0=3/3, 1=5/5, 2=25/25

// ATR zigzag of one pivot scale: alternating swing highs and lows.
type ZZ
    array<Piv> highs
    array<Piv> lows
    Piv        lastP
    int        dir

type TL
    int   p1Idx
    float p1Price
    int   p2Idx
    float p2Price
    float slope
    float area        // touch tolerance
    int   touches
    int   p2Size
    int   baseLen
    int   maxExt      // last bar on which the line can break
    bool  isHigh
    bool  isLarge
    int   cnt         // consecutive closes beyond
    bool  volHit
    line  ln

// A break inside its negation window.
type Brk
    int   dir
    int   bar
    int   p1Idx
    float p1Price
    float slope
    line  ln

// What one bar did.
type Tally
    int formed
    int retired
    int newP1
    int newP2

//=============================================================================
// State (from the chart's first bar)
//=============================================================================
var array<Piv> piv3    = array.new<Piv>()      // touch pivots for small lines
var array<Piv> piv5    = array.new<Piv>()      // touch pivots for large lines
var ZZ         zzS     = ZZ.new(array.new<Piv>(), array.new<Piv>(), na, 0)
var ZZ         zzL     = ZZ.new(array.new<Piv>(), array.new<Piv>(), na, 0)
var array<TL>  active  = array.new<TL>()
var array<Brk> pending = array.new<Brk>()
// Finished drawings (retired or broken lines, closed negation windows), oldest first. The script deletes
// the oldest itself, so TradingView's own limit never removes a line that is still being updated.
var array<line> doneLines = array.new<line>()
const int MAX_DONE_LINES = 300

// The newest break's side while it stands, and its line.
var int   biasDir     = 0
var int   biasP1Idx   = na
var float biasP1Price = na
var float biasSlope   = na

//=============================================================================
// Series
//=============================================================================
float atr14  = ta.atr(14)
float volAvg = ta.sma(volume, 20)

float ph3  = ta.pivothigh(high, 3, 3)
float pl3  = ta.pivotlow(low, 3, 3)
float ph5  = ta.pivothigh(high, 5, 5)
float pl5  = ta.pivotlow(low, 5, 5)
float ph25 = ta.pivothigh(high, 25, 25)
float pl25 = ta.pivotlow(low, 25, 25)

// Pivots that matured on this bar (confirmed pivotAge bars ago).
float mph5   = ph5[pivotAge]
float mpl5   = pl5[pivotAge]
float mph25  = ph25[pivotAge]
float mpl25  = pl25[pivotAge]
float matr5  = nz(atr14[pivotAge + 5], atr14[pivotAge])
float matr25 = nz(atr14[pivotAge + 25], atr14[pivotAge])

f_ma(int len) =>
    len <= 0 ? na :
     maType == "SMA"  ? ta.sma(close, len) :
     maType == "WMA"  ? ta.wma(close, len) :
     maType == "RMA"  ? ta.rma(close, len) :
     maType == "VWMA" ? ta.vwma(close, len) :
     ta.ema(close, len)

float ma1 = f_ma(ma1Len)
float ma2 = f_ma(ma2Len)
float ma3 = f_ma(ma3Len)
float maF = maFilter == "MA 1" ? ma1 : maFilter == "MA 2" ? ma2 : maFilter == "MA 3" ? ma3 : na

//=============================================================================
// Helpers
//=============================================================================
f_y(int x1, float y1, float slope, int x) =>
    y1 + slope * (x - x1)

// Extension length scales with touch count (2-touch = 2x base, 5+-touch = 3.5x)
f_extLen(int baseLen, int touches) =>
    int(baseLen * math.min(2.0 + (touches - 2) * 0.5, 3.5))

f_lineCol(TL L) =>
    grayLines ? color.new(color.gray, 30) : L.isHigh ? colRes : colSup

f_overlaps(TL a, TL b) =>
    int oS = math.max(a.p1Idx, b.p1Idx)
    int oE = math.min(a.p2Idx, b.p2Idx)
    bool res = false
    if oE > oS
        float ov = oE - oS
        float ratio = overlapPct / 100.0
        res := ov / a.baseLen > ratio or ov / b.baseLen > ratio
    res

// A small line whose anchors both sit within a large line's touch band, inside its span.
f_nests(TL lg, TL s) =>
    s.p1Idx >= lg.p1Idx and s.p2Idx <= lg.p2Idx and math.abs(s.p1Price - f_y(lg.p1Idx, lg.p1Price, lg.slope, s.p1Idx)) <= lg.area and math.abs(s.p2Price - f_y(lg.p1Idx, lg.p1Price, lg.slope, s.p2Idx)) <= lg.area

// Overlap ranking: more touches, then the more recent P2, the longer base, the larger P2 pivot, the steeper slope.
f_wins(TL a, TL b) =>
    a.touches != b.touches ? a.touches > b.touches :
     a.p2Idx   != b.p2Idx   ? a.p2Idx > b.p2Idx :
     a.baseLen != b.baseLen ? a.baseLen > b.baseLen :
     a.p2Size  != b.p2Size  ? a.p2Size > b.p2Size :
     math.abs(a.slope) > math.abs(b.slope)

// A drawing that will not change again joins the finished ones; the oldest beyond the cap are deleted.
f_done(line ln) =>
    if not na(ln)
        doneLines.push(ln)
        while doneLines.size() > MAX_DONE_LINES
            line.delete(doneLines.shift())
    true

// End a line's drawing on bar t: solid to its break, faded and dotted when it retired otherwise.
f_retire(TL L, int t, bool broken) =>
    if not na(L.ln)
        if broken or showRetired
            line.set_xy2(L.ln, t, f_y(L.p1Idx, L.p1Price, L.slope, t))
            line.set_extend(L.ln, extend.none)
            if not broken
                line.set_style(L.ln, line.style_dotted)
                line.set_color(L.ln, color.new(f_lineCol(L), 70))
            f_done(L.ln)
        else
            line.delete(L.ln)
    true

// Admit a candidate against the active lines. Returns how many lines it retired, or -1 when it is not admitted.
f_admit(TL C, int t) =>
    bool keep = true
    if szInput == "Both" and not C.isLarge
        for A1 in active
            if A1.isLarge and A1.isHigh == C.isHigh and f_nests(A1, C)
                keep := false
                break
    if keep
        for A2 in active
            if A2.isHigh == C.isHigh and A2.isLarge == C.isLarge and f_overlaps(A2, C) and not f_wins(C, A2)
                keep := false
                break
    int retiredHere = -1
    if keep
        retiredHere := 0
        int i = 0
        while i < active.size()
            TL A3 = active.get(i)
            bool drop = A3.isHigh == C.isHigh and A3.isLarge == C.isLarge and f_overlaps(A3, C)
            if not drop and szInput == "Both" and C.isLarge and not A3.isLarge and A3.isHigh == C.isHigh
                drop := f_nests(C, A3)
            if drop
                f_retire(A3, t, false)
                active.remove(i)
                retiredHere += 1
            else
                i += 1
        active.push(C)
        int same = 0
        for A4 in active
            if A4.isHigh == C.isHigh and A4.isLarge == C.isLarge
                same += 1
        while same > maxLines
            int k = 0
            while k < active.size()
                TL A5 = active.get(k)
                if A5.isHigh == C.isHigh and A5.isLarge == C.isLarge
                    break
                k += 1
            f_retire(active.get(k), t, false)
            active.remove(k)
            retiredHere += 1
            same -= 1
    retiredHere

// Same direction keeps the better extreme; a turn needs an ATR * atrMult move. True when p joined the zigzag.
f_zzAdd(ZZ z, Piv p, float atrMult) =>
    bool added = false
    if na(z.lastP)
        (p.isHigh ? z.highs : z.lows).push(p)
        z.lastP := p
        z.dir := p.isHigh ? 1 : -1
        added := true
    else if (z.dir == 1) == p.isHigh
        bool better = z.dir == 1 ? p.price > z.lastP.price : p.price < z.lastP.price
        if better
            array<Piv> arr = z.dir == 1 ? z.highs : z.lows
            if arr.size() > 0
                arr.pop()
            arr.push(p)
            z.lastP := p
            added := true
    else if math.abs(z.lastP.price - p.price) > z.lastP.atr * atrMult
        (p.isHigh ? z.highs : z.lows).push(p)
        z.lastP := p
        z.dir := p.isHigh ? 1 : -1
        added := true
    added

// Candidate lines ending at the zigzag's newest point on one side, formed on bar t.
f_form(array<Piv> pts, array<Piv> touchPivots, bool isLarge, bool isHigh, int t, Tally tal) =>
    int cntPts = pts.size()
    if cntPts >= 2
        int depth = isLarge ? largeDepth : smallDepth
        Piv p2 = pts.get(cntPts - 1)
        for i = math.max(0, cntPts - depth) to cntPts - 2
            Piv p1 = pts.get(i)
            if p1.idx < t - lookback
                continue
            bool okStruct = isHigh ? p1.price > p2.price : p1.price < p2.price
            int baseLen = p2.idx - p1.idx
            if not okStruct or baseLen <= 0
                continue
            float slope = (p2.price - p1.price) / baseLen
            float avgAtr = (p1.atr + p2.atr) * 0.5
            float area = avgAtr * touchAtrMult
            if minSlope > 0 and math.abs(slope) < avgAtr * minSlope / 100.0
                continue
            if maxSlope > 0 and math.abs(slope) > avgAtr * maxSlope / 100.0
                continue
            // Respect: no candle body beyond the line from P1 up to this bar (wicks may cross).
            bool ok = true
            for x = p1.idx + 1 to t
                if x != p2.idx
                    int off = t - x
                    float y = f_y(p1.idx, p1.price, slope, x)
                    if isHigh ? math.max(open[off], close[off]) > y : math.min(open[off], close[off]) < y
                        ok := false
                        break
            if not ok
                continue
            // Touches: P1 and P2, plus touch pivots between them within the tolerance.
            int touches = 2
            for px in touchPivots
                if px.idx >= p2.idx
                    break
                if px.idx > p1.idx and px.isHigh == isHigh and math.abs(px.price - f_y(p1.idx, p1.price, slope, px.idx)) <= area
                    touches += 1
            int maxExt = p2.idx + f_extLen(baseLen, touches)
            if touches < minTouches or t >= maxExt
                continue
            TL C = TL.new(p1.idx, p1.price, p2.idx, p2.price, slope, area, touches, p2.size, baseLen, maxExt, isHigh, isLarge, 0, false, na)
            int r = f_admit(C, t)
            if r >= 0
                C.ln := line.new(C.p1Idx, C.p1Price, C.p2Idx, C.p2Price, extend=extend.right, color=f_lineCol(C), width=isLarge ? 2 : 1)
                tal.formed := tal.formed + 1
                tal.retired := tal.retired + r
                tal.newP1 := C.p1Idx
                tal.newP2 := C.p2Idx
    true

f_feed(ZZ z, Piv p, float atrMult, int depth, array<Piv> touchPivots, bool isLarge, int t, Tally tal) =>
    if f_zzAdd(z, p, atrMult)
        array<Piv> pts = p.isHigh ? z.highs : z.lows
        f_form(pts, touchPivots, isLarge, p.isHigh, t, tal)
        while pts.size() > depth
            pts.shift()
    true

//=============================================================================
// Main: once per confirmed bar
//=============================================================================
bool upS   = false
bool upL   = false
bool dnS   = false
bool dnL   = false
bool negUp = false
bool negDn = false
Tally tal = Tally.new(0, 0, na, na)

if barstate.isconfirmed
    int t = bar_index
    float c = close

    // 1. Breaks inside their negation window: a close back across the line negates them.
    int i = 0
    while i < pending.size()
        Brk b = pending.get(i)
        float y = f_y(b.p1Idx, b.p1Price, b.slope, t)
        if b.dir == 1 ? c < y : c > y
            if b.dir == 1
                negUp := true
            else
                negDn := true
            if not na(b.ln)
                line.set_xy2(b.ln, t, y)
            f_done(b.ln)
            pending.remove(i)
        else if t - b.bar >= negBars
            f_done(b.ln)
            pending.remove(i)
        else
            i += 1
    // The bias ends on a close back across the newest break's line.
    if biasDir != 0
        float yb = f_y(biasP1Idx, biasP1Price, biasSlope, t)
        if biasDir == 1 ? c < yb : c > yb
            biasDir := 0

    // 2. Active lines take the close: N consecutive closes beyond break a line; a line past its extension retires.
    float upY       = na
    int   upP1      = na
    float upP1Price = na
    float upSlope   = na
    float dnY       = na
    int   dnP1      = na
    float dnP1Price = na
    float dnSlope   = na
    i := 0
    while i < active.size()
        TL L = active.get(i)
        float y = f_y(L.p1Idx, L.p1Price, L.slope, t)
        bool broke = false
        if L.isHigh ? c > y : c < y
            L.cnt := L.cnt + 1
            if not L.volHit and volume > volAvg * volMult
                L.volHit := true
            bool volPass  = not volFilter or L.volHit
            bool distPass = breakAtr <= 0 or (L.isHigh ? c - y : y - c) >= breakAtr * atr14
            bool maPass   = maFilter == "Off" or (L.isHigh ? c > maF : c < maF)
            broke := L.cnt >= nBreak and volPass and distPass and maPass
        else
            L.cnt := 0
            L.volHit := false
        if broke
            // One break per direction and bar, on the broken line nearest to the close.
            if L.isHigh
                if L.isLarge
                    upL := true
                else
                    upS := true
                if na(upY) or y > upY
                    upY := y
                    upP1 := L.p1Idx
                    upP1Price := L.p1Price
                    upSlope := L.slope
            else
                if L.isLarge
                    dnL := true
                else
                    dnS := true
                if na(dnY) or y < dnY
                    dnY := y
                    dnP1 := L.p1Idx
                    dnP1Price := L.p1Price
                    dnSlope := L.slope
            f_retire(L, t, true)
            active.remove(i)
        else if t >= L.maxExt
            f_retire(L, t, false)
            active.remove(i)
            tal.retired := tal.retired + 1
        else
            i += 1

    // 3. Record the bar's breaks; the newest sets the bias.
    bool anyUp = upS or upL
    bool anyDn = dnS or dnL
    if anyUp
        line invUp = showInval ? line.new(t, upY, t + negBars, f_y(upP1, upP1Price, upSlope, t + negBars), color=colNeg, style=line.style_dotted, width=1) : na
        pending.push(Brk.new(1, t, upP1, upP1Price, upSlope, invUp))
    if anyDn
        line invDn = showInval ? line.new(t, dnY, t + negBars, f_y(dnP1, dnP1Price, dnSlope, t + negBars), color=colNeg, style=line.style_dotted, width=1) : na
        pending.push(Brk.new(-1, t, dnP1, dnP1Price, dnSlope, invDn))
    if anyUp and anyDn
        biasDir := 0
    else if anyUp
        biasDir := 1
        biasP1Idx := upP1
        biasP1Price := upP1Price
        biasSlope := upSlope
    else if anyDn
        biasDir := -1
        biasP1Idx := dnP1
        biasP1Price := dnP1Price
        biasSlope := dnSlope

    // 4. Pivots confirmed on this bar join the touch lists.
    if not na(ph3)
        piv3.push(Piv.new(t - 3, ph3, na, true, 0))
    if not na(pl3)
        piv3.push(Piv.new(t - 3, pl3, na, false, 0))
    if not na(ph5)
        piv5.push(Piv.new(t - 5, ph5, na, true, 1))
    if not na(pl5)
        piv5.push(Piv.new(t - 5, pl5, na, false, 1))
    while piv3.size() > 0
        if piv3.get(0).idx >= t - lookback
            break
        piv3.shift()
    while piv5.size() > 0
        if piv5.get(0).idx >= t - lookback
            break
        piv5.shift()

    // 5. Pivots that matured on this bar feed the zigzags and form lines: large, then small; highs, then lows.
    if szInput != "Small"
        if not na(mph25)
            f_feed(zzL, Piv.new(t - pivotAge - 25, mph25, matr25, true, 2), largeAtrMult, largeDepth, piv5, true, t, tal)
        if not na(mpl25)
            f_feed(zzL, Piv.new(t - pivotAge - 25, mpl25, matr25, false, 2), largeAtrMult, largeDepth, piv5, true, t, tal)
    if szInput != "Large"
        if not na(mph5)
            f_feed(zzS, Piv.new(t - pivotAge - 5, mph5, matr5, true, 1), smallAtrMult, smallDepth, piv3, false, t, tal)
        if not na(mpl5)
            f_feed(zzS, Piv.new(t - pivotAge - 5, mpl5, matr5, false, 1), smallAtrMult, smallDepth, piv3, false, t, tal)

//=============================================================================
// Markers and alerts
//=============================================================================
bool upBreak = upS or upL
bool dnBreak = dnS or dnL

plotshape(showBreak and upBreak, "Upward break", shape.triangleup, location.belowbar, colBull, size=size.small)
plotshape(showBreak and dnBreak, "Downward break", shape.triangledown, location.abovebar, colBear, size=size.small)
plotshape(showNeg and negUp, "Upward break negated", shape.xcross, location.abovebar, colNeg, size=size.tiny)
plotshape(showNeg and negDn, "Downward break negated", shape.xcross, location.belowbar, colNeg, size=size.tiny)

alertcondition(alertOn and alertRes and upBreak, "TMB Upward Break", "TMB: resistance trendline broken upward")
alertcondition(alertOn and alertSup and dnBreak, "TMB Downward Break", "TMB: support trendline broken downward")
alertcondition(alertOn and alertNeg and negUp, "TMB Upward Break Negated", "TMB: upward break negated, close back below the broken line")
alertcondition(alertOn and alertNeg and negDn, "TMB Downward Break Negated", "TMB: downward break negated, close back above the broken line")

if alertOn
    string where = " | " + syminfo.ticker + " | " + timeframe.period
    if alertRes and upBreak
        alert("TMB: resistance trendline broken upward" + where, alert.freq_once_per_bar_close)
    if alertSup and dnBreak
        alert("TMB: support trendline broken downward" + where, alert.freq_once_per_bar_close)
    if alertNeg and negUp
        alert("TMB: upward break negated" + where, alert.freq_once_per_bar_close)
    if alertNeg and negDn
        alert("TMB: downward break negated" + where, alert.freq_once_per_bar_close)

//=============================================================================
// Optional Moving Averages
//=============================================================================
plot(showMA ? ma1 : na, "MA 1", color=maCol1)
plot(showMA ? ma2 : na, "MA 2", color=maCol2)
plot(showMA ? ma3 : na, "MA 3", color=maCol3)
````
