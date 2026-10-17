# Prism Channel Architecture [JOAT]

- url: https://www.tradingview.com/script/tpOTBsPb-Prism-Channel-Architecture-JOAT/
- type: indicator
- pine_id: PUB;95fc1567e60f494ea44fecf5f59ab62c
- version: 1.0

## Description

Prism Channel Architecture [JOAT]

[b]Introduction[/b]

Prism Channel Architecture is a dual-channel overlay indicator that layers two mathematically distinct structural frameworks onto your price chart simultaneously: a best-fit Pivot Channel derived from actual price pivot points, and a Linear Regression Channel built from statistical least-squares fitting. Together they create a structural prism through which trend direction, channel quality, and breakout momentum can be evaluated from multiple angles at once.

Most channel tools force you to choose between objectivity and responsiveness. Pivot channels adapt to real market structure but can lag. Regression channels are statistically rigorous but ignore actual swing highs and lows. PCA runs both engines in parallel and highlights the moments when they [i]agree[/i] — bull alignment and bear alignment states — as the highest-conviction reads in the system.

[image]https://www.tradingview.com/x/j0iK5jZI/[/image]

[b]Core Concepts[/b]

[b]Pivot Channel Fitting[/b]

The indicator collects up to a configurable maximum of confirmed pivot highs and pivot lows using TradingView's built-in pivot functions:

[pine]
float pivHigh = ta.pivothigh(high, pivLeft, pivRight)
float pivLow  = ta.pivotlow( low,  pivLeft, pivRight)
[/pine]

From those stored pivot arrays, it searches for the best pair of recent pivot highs to fit the upper channel boundary, and the best pair of recent pivot lows to fit the lower channel boundary. The quality score for each candidate pair is computed by checking how many of the recent bars were actually [i]contained below[/i] the upper line (or above the lower line) within an ATR tolerance:

[pine]
for k = 0 to checks - 1
    float lineY = linePrice(x2, y2, x1, y1, bar_index - k)
    if high[k] <= lineY + atrVal * 0.3
        contained += 1
float q = safeDiv(float(contained), float(checks), 0.0)
[/pine]

The pair with the highest containment ratio wins and becomes the drawn channel. This means the upper channel line is always the tightest valid resistance line through recent pivot highs, not an arbitrary parallel projection.

[b]Linear Regression Channel[/b]

The regression channel computes a full manual least-squares fit over the lookback window, producing slope, intercept, and residual standard deviation:

[pine]
float slope = safeDiv(n * sumXY - sumX * sumY, n * sumXSq - sumX * sumX, 0.0)
float intc  = safeDiv(sumY - slope * sumX, n, close)
float stdDev = math.sqrt(safeDiv(ssRes, n, 0.0))
[/pine]

The upper and lower bands are drawn at `stdDev × Deviation Multiplier` distance from the regression midline, giving bands that are statistically calibrated to the actual spread of price around the trend. Color shifts from bull to bear when slope changes sign.

[b]Channel Alignment Confluence[/b]

The system declares a [b]Bull Alignment[/b] when both channels simultaneously agree price is in a bullish position — the regression slope is rising AND price is above the regression midline, AND price is in the upper half of the pivot channel (between the midline and the upper band):

[pine]
bool lrBull    = close > midNow and slope > 0.0
bool pivBull   = close > uMid and close < uNow
bool alignBull = lrBull and pivBull
[/pine]

This confluence state is highlighted with a subtle background color — a quiet but meaningful signal that two independent structural frameworks are pointing in the same direction.

[b]ATR-Based Breakout Detection[/b]

Breakout signals fire when price moves more than a configurable ATR multiple beyond the prior bar, provided the regression slope confirms direction:

[pine]
bool brkUp = ta.crossover(close, close[1] + crossTol * atrVal) and lrSlope > 0.0
bool brkDn = ta.crossunder(close, close[1] - crossTol * atrVal) and lrSlope < 0.0
[/pine]

Breakout labels (▲ BRK / ▼ BRK) appear above or below the breakout bar and are alert-enabled.

[b]Features[/b]

[list]
[*] Pivot Channel — best-fit upper/lower boundaries through recent pivot highs/lows, quality-scored by containment ratio
[*] Regression Channel — least-squares midline with statistically calibrated deviation bands, auto-colored by slope direction
[*] Channel midline — dashed neutral midline bisecting the pivot channel for zone positioning
[*] Bull and Bear Alignment detection — background highlight when both channels agree on direction
[*] ATR-normalized breakout labels — ▲ BRK and ▼ BRK when price breaks out with trend confirmation
[*] Channel Quality score — displayed in dashboard as percentage of recent bars contained
[*] Pivot position classification — Bull Zone (upper half) or Bear Zone (lower half)
[*] Up to 40 pivot highs and 40 pivot lows stored and evaluated
[*] 10-bar channel projection extended to the right of the last bar
[*] Dashboard: LR direction, deviation mult, pivot quality, pivot position, alignment, breakout, ATR, pivot count
[*] Alerts for bullish breakout, bearish breakout, bull alignment, and bear alignment
[*] Webhook JSON alert format
[*] Watermark
[/list]

[b]Input Parameters[/b]

[b]Pivot Channel[/b]
[list]
[*] Pivot Lookback Left — bars to the left required to confirm a pivot high or low (default 10)
[*] Pivot Lookback Right — bars to the right required to confirm a pivot high or low (default 5)
[*] Max Pivots Stored — maximum number of pivot highs and lows held in memory (default 30)
[*] Quality Check Length — number of recent bars used to score channel containment (default 20)
[*] Breakout ATR Mult — ATR multiplier threshold for breakout label generation (default 1.5)
[*] Show Pivot Channel — toggle the pivot channel lines on/off
[/list]

[b]Regression Channel[/b]
[list]
[*] Regression Length — bars used in the least-squares fit (default 50)
[*] Deviation Mult — standard deviation multiplier for band width (default 2.0)
[*] Show Regression Channel — toggle the regression channel lines and fill on/off
[/list]

[b]ATR Settings[/b]
[list]
[*] ATR Length — lookback for ATR calculation used in breakout detection and containment tolerance (default 14)
[/list]

[b]Visuals[/b]
[list]
[*] Bull Color — color for uptrending channels and bullish labels
[*] Bear Color — color for downtrending channels and bearish labels
[*] Neutral Color — color for channel midlines and neutral dashboard text
[*] Show Dashboard — compact structural summary panel
[*] Show Watermark
[*] Show Breakout Labels — toggle ▲ BRK / ▼ BRK label markers
[/list]

[b]Alerts[/b]
[list]
[*] Webhook JSON Format — switches alert messages to JSON format for automation pipelines
[/list]

[image]https://www.tradingview.com/x/SdUoaWh9/[/image]

[b]How to Use[/b]

[list]
[*] Add PCA to your chart as a main-pane overlay indicator.
[*] Let the chart load enough history so both channels initialize. A warmup period of at least 60 bars is enforced before channels begin drawing.
[*] Use the [b]Regression Channel[/b] to assess macro trend direction. If the midline slope is rising and price is above it, the macro environment is bullish.
[*] Use the [b]Pivot Channel[/b] to identify the structural support and resistance boundaries formed by actual price pivots. The upper pivot line is the tightest valid resistance. The lower pivot line is the strongest structural support.
[*] Watch for [b]Bull Alignment[/b] (cyan background) when both systems agree price is in a bullish structural position. This is the highest-conviction environment for long setups.
[*] Watch for [b]Bear Alignment[/b] (red background) for bearish structural setups.
[*] Treat [b]Breakout labels[/b] as momentum confirmation signals — they only fire when an ATR-significant price move occurs in the direction of the regression slope.
[*] Check the [b]Pivot Quality score[/b] in the dashboard. A quality above 65% means the channels are actively containing price well. Below 40% means the channel fit is loose and breakouts are less reliable.
[/list]

[b]Indicator Limitations[/b]

[list]
[*] Pivot channel fitting evaluates only the 8 most recent pivot highs and the 8 most recent pivot lows when searching for the best pair. In very choppy markets with many closely-spaced pivots, the fitted channel may appear narrow or erratic.
[*] The regression channel is recalculated on every bar over a fixed lookback window. It will repaint the past visually as new bars are added — the channel reflects the lookback window ending at the current bar, not a fixed historical period.
[*] Channel quality scores can be artificially high in low-volatility trending conditions where price barely touches the edges of the channel.
[*] Breakout signals require both an ATR threshold move AND a confirming regression slope. In sideways markets the slope condition filters out most breakout candidates, which may lead to missed signals on genuine horizontal range breaks.
[/list]

[b]Originality Statement[/b]

Prism Channel Architecture is an original Pine Script v6 publication. The dual-engine architecture combining a quality-scored best-fit pivot channel with an independently computed least-squares regression channel, and the definition of alignment confluence as agreement between those two distinct structural systems, is an original design. The pivot quality scoring methodology — measuring the containment ratio of recent bars within the candidate channel bounds with ATR tolerance — is an original technique not derived from any existing published indicator.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Channels, alignment states, and breakout labels are analytical tools and do not constitute financial advice. Channel boundaries can and will be violated without warning. Always apply proper risk management and never trade solely based on indicator signals.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Prism Channel Architecture [JOAT]", shorttitle="PCA [JOAT]", overlay=true,
     max_lines_count=500, max_labels_count=100, max_boxes_count=50)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// Pivot settings
pivGrp        = "Pivot Channel"
int  pivLeft  = input.int(10, "Pivot Lookback Left",   minval=3, maxval=50,  group=pivGrp)
int  pivRight = input.int(5,  "Pivot Lookback Right",  minval=2, maxval=25,  group=pivGrp)
int  maxPivs  = input.int(30, "Max Pivots Stored",     minval=10, maxval=40, group=pivGrp)
int  chkLen   = input.int(20, "Quality Check Length",  minval=5,  maxval=50, group=pivGrp)
float crossTol = input.float(1.5, "Breakout ATR Mult", minval=0.5, maxval=4.0, step=0.1, group=pivGrp)
bool showPivCh = input.bool(true, "Show Pivot Channel", group=pivGrp)

// Linear Regression settings
lrGrp         = "Regression Channel"
int  lrLen    = input.int(50, "Regression Length",   minval=10, maxval=200,  group=lrGrp)
float lrDev   = input.float(2.0, "Deviation Mult",  minval=0.5, maxval=4.0, step=0.1, group=lrGrp)
bool showLrCh = input.bool(true, "Show Regression Channel", group=lrGrp)

// ATR
atrGrp        = "ATR Settings"
int  atrLen   = input.int(14, "ATR Length", minval=5, maxval=50, group=atrGrp)

// Visual
visGrp        = "Visuals"
color cUp     = input.color(#00E5FF, "Bull Color",    group=visGrp)
color cDn     = input.color(#FF4B4B, "Bear Color",    group=visGrp)
color cNeutral= input.color(#B0BEC5, "Neutral Color", group=visGrp)
bool  showDash= input.bool(true, "Show Dashboard",    group=visGrp)
bool  showWm  = input.bool(true, "Show Watermark",    group=visGrp)
bool  showBrk = input.bool(true, "Show Breakout Labels", group=visGrp)

// Alerts
alrtGrp       = "Alerts"
bool  useJson = input.bool(false, "Webhook JSON Format", group=alrtGrp)
string ticker = syminfo.ticker

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — CORE FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

safeDiv(float a, float b, float fallback=0.0) =>
    not na(b) and b != 0.0 ? a / b : fallback

// Linear regression: returns [slope, intercept, stdDev]
linregCalc(int len) =>
    float sumX   = 0.0
    float sumY   = 0.0
    float sumXY  = 0.0
    float sumXSq = 0.0
    float sumYSq = 0.0
    float n = float(len)
    for i = 0 to len - 1
        float xi = float(i)
        float yi = close[len - 1 - i]
        sumX  += xi
        sumY  += yi
        sumXY += xi * yi
        sumXSq += xi * xi
        sumYSq += yi * yi
    float slope = safeDiv(n * sumXY - sumX * sumY, n * sumXSq - sumX * sumX, 0.0)
    float intc  = safeDiv(sumY - slope * sumX, n, close)
    // Residual std dev
    float ssRes = 0.0
    for i = 0 to len - 1
        float xi   = float(i)
        float yi   = close[len - 1 - i]
        float pred = slope * xi + intc
        ssRes += math.pow(yi - pred, 2.0)
    float stdDev = math.sqrt(safeDiv(ssRes, n, 0.0))
    [slope, intc, stdDev]

// Price at a line defined by two points
linePrice(int x1, float y1, int x2, float y2, int x) =>
    float dx = float(x2 - x1)
    dx == 0.0 ? y1 : y1 + safeDiv((y2 - y1) * float(x - x1), dx, 0.0)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — ATR & WARMUP
// ═══════════════════════════════════════════════════════════════════════════════

float atrVal  = ta.atr(atrLen)
int   WARMUP  = math.max(lrLen, pivLeft + pivRight + 10, 60)
bool  warmed  = bar_index >= WARMUP

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — PIVOT DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

var array<int>   phIdx = array.new<int>()
var array<float> phVal = array.new<float>()
var array<int>   plIdx = array.new<int>()
var array<float> plVal = array.new<float>()

float pivHigh = ta.pivothigh(high, pivLeft, pivRight)
float pivLow  = ta.pivotlow( low,  pivLeft, pivRight)

if not na(pivHigh) and warmed
    array.push(phIdx, bar_index - pivRight)
    array.push(phVal, pivHigh)
    if array.size(phIdx) > maxPivs
        array.shift(phIdx)
        array.shift(phVal)

if not na(pivLow) and warmed
    array.push(plIdx, bar_index - pivRight)
    array.push(plVal, pivLow)
    if array.size(plIdx) > maxPivs
        array.shift(plIdx)
        array.shift(plVal)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — CHANNEL FITTING: UPPER (resistance) & LOWER (support)
// ═══════════════════════════════════════════════════════════════════════════════

// Find best-fit upper channel through two pivot highs
// "Quality" = fraction of bars in chkLen window where price is below the line
findUpChannel(array<int> idxArr, array<float> valArr) =>
    float bestQ = -1.0
    int   bx1   = na
    int   bx2   = na
    float by1   = na
    float by2   = na
    int   sz     = array.size(idxArr)
    if sz >= 2
        for i = sz - 1 to math.max(sz - 8, 1)
            for j = i - 1 to math.max(i - 6, 0)
                int   x1 = array.get(idxArr, i)
                float y1 = array.get(valArr, i)
                int   x2 = array.get(idxArr, j)
                float y2 = array.get(valArr, j)
                // slope must be non-positive for a valid upper channel
                float dx = float(x1 - x2)
                float slope = dx == 0.0 ? 0.0 : (y1 - y2) / dx
                if slope <= 0.02 * (y1 / math.max(atrVal, 1.0) / 100.0)
                    int   contained = 0
                    int   checks    = math.min(chkLen, bar_index)
                    for k = 0 to checks - 1
                        float lineY = linePrice(x2, y2, x1, y1, bar_index - k)
                        if high[k] <= lineY + atrVal * 0.3
                            contained += 1
                    float q = safeDiv(float(contained), float(checks), 0.0)
                    if q > bestQ
                        bestQ := q
                        bx1   := x2
                        by1   := y2
                        bx2   := x1
                        by2   := y1
    [bx1, by1, bx2, by2, bestQ]

// Find best-fit lower channel through two pivot lows
findDnChannel(array<int> idxArr, array<float> valArr) =>
    float bestQ = -1.0
    int   bx1   = na
    int   bx2   = na
    float by1   = na
    float by2   = na
    int   sz     = array.size(idxArr)
    if sz >= 2
        for i = sz - 1 to math.max(sz - 8, 1)
            for j = i - 1 to math.max(i - 6, 0)
                int   x1 = array.get(idxArr, i)
                float y1 = array.get(valArr, i)
                int   x2 = array.get(idxArr, j)
                float y2 = array.get(valArr, j)
                float dx = float(x1 - x2)
                float slope = dx == 0.0 ? 0.0 : (y1 - y2) / dx
                if slope >= -0.02 * (y1 / math.max(atrVal, 1.0) / 100.0)
                    int   contained = 0
                    int   checks    = math.min(chkLen, bar_index)
                    for k = 0 to checks - 1
                        float lineY = linePrice(x2, y2, x1, y1, bar_index - k)
                        if low[k] >= lineY - atrVal * 0.3
                            contained += 1
                    float q = safeDiv(float(contained), float(checks), 0.0)
                    if q > bestQ
                        bestQ := q
                        bx1   := x2
                        by1   := y2
                        bx2   := x1
                        by2   := y1
    [bx1, by1, bx2, by2, bestQ]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — PIVOT CHANNEL LINES (persistent)
// ═══════════════════════════════════════════════════════════════════════════════

var line  lnUpA   = na
var line  lnUpB   = na
var line  lnDnA   = na
var line  lnDnB   = na
var line  lnUpMid = na
var line  lnDnMid = na
var float pivChQ  = 0.0
var bool  pivBull = false
var bool  pivBear = false

if warmed and barstate.islast
    [ux1, uy1, ux2, uy2, uq] = findUpChannel(phIdx, phVal)
    [dx1, dy1, dx2, dy2, dq] = findDnChannel(plIdx, plVal)
    pivChQ := math.max(uq, dq)

    // Draw upper pivot channel
    if showPivCh and not na(ux1) and not na(dx1)
        float uNow = linePrice(ux1, uy1, ux2, uy2, bar_index)
        float dNow = linePrice(dx1, dy1, dx2, dy2, bar_index)
        float uFut = linePrice(ux1, uy1, ux2, uy2, bar_index + 10)
        float dFut = linePrice(dx1, dy1, dx2, dy2, bar_index + 10)
        float uMid = (uNow + dNow) / 2.0
        float uMidF= (uFut + dFut) / 2.0
        int   qualAlpha = int(math.max(0.0, math.min(1.0, 1.0 - uq)) * 60.0)
        color chCol = uNow > dNow ? color.new(cUp, qualAlpha) : color.new(cDn, qualAlpha)

        if na(lnUpA)
            lnUpA  := line.new(ux1, uy1, bar_index + 10, uFut,  color=chCol, width=2, extend=extend.none, xloc=xloc.bar_index)
            lnUpB  := line.new(dx1, dy1, bar_index + 10, dFut,  color=chCol, width=2, extend=extend.none, xloc=xloc.bar_index)
            lnUpMid:= line.new(bar_index, uMid, bar_index + 10, uMidF, color=color.new(cNeutral, 60), width=1, style=line.style_dashed, xloc=xloc.bar_index)
        else
            line.set_xy1(lnUpA, ux1, uy1)
            line.set_xy2(lnUpA, bar_index + 10, uFut)
            line.set_xy1(lnUpB, dx1, dy1)
            line.set_xy2(lnUpB, bar_index + 10, dFut)
            line.set_xy2(lnUpMid, bar_index + 10, uMidF)
            line.set_x1(lnUpMid, bar_index)
            line.set_y1(lnUpMid, uMid)
            line.set_color(lnUpA, chCol)
            line.set_color(lnUpB, chCol)

        pivBull := close > uMid and close < uNow
        pivBear := close < uMid and close > dNow

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — LINEAR REGRESSION CHANNEL
// ═══════════════════════════════════════════════════════════════════════════════

var line     lrMid   = na
var line     lrTop   = na
var line     lrBot   = na
var linefill lfUp    = na
var linefill lfDn    = na
var float    lrSlope = 0.0
var bool     lrBull  = false
var bool     lrBear  = false

if warmed
    [slope, intc, stdDev] = linregCalc(lrLen)
    lrSlope := slope

    float nowY    = slope * float(lrLen - 1) + intc
    float prevY   = slope * float(lrLen - 2) + intc
    float futY    = slope * float(lrLen) + intc
    float devBand = stdDev * lrDev

    int   x1bar   = bar_index - lrLen + 1
    int   x2bar   = bar_index + 1
    color lrCol   = slope >= 0.0 ? cUp : cDn
    int   lrAlpha = slope >= 0.0 ? 30 : 30

    if showLrCh
        if na(lrMid)
            lrMid := line.new(x1bar, intc,           x2bar, futY,           color=color.new(lrCol, 0),      width=2, xloc=xloc.bar_index)
            lrTop := line.new(x1bar, intc + devBand, x2bar, futY + devBand, color=color.new(lrCol, 50),     width=1, xloc=xloc.bar_index)
            lrBot := line.new(x1bar, intc - devBand, x2bar, futY - devBand, color=color.new(lrCol, 50),     width=1, xloc=xloc.bar_index)
            lfUp  := linefill.new(lrMid, lrTop, color.new(lrCol, 88))
            lfDn  := linefill.new(lrBot, lrMid, color.new(lrCol, 88))
        else
            line.set_xy1(lrMid, x1bar, intc)
            line.set_xy2(lrMid, x2bar, futY)
            line.set_xy1(lrTop, x1bar, intc + devBand)
            line.set_xy2(lrTop, x2bar, futY + devBand)
            line.set_xy1(lrBot, x1bar, intc - devBand)
            line.set_xy2(lrBot, x2bar, futY - devBand)
            line.set_color(lrMid, color.new(lrCol, 0))
            line.set_color(lrTop, color.new(lrCol, 50))
            line.set_color(lrBot, color.new(lrCol, 50))
            linefill.set_color(lfUp, color.new(lrCol, 88))
            linefill.set_color(lfDn, color.new(lrCol, 88))

    float midNow = prevY
    lrBull := close > midNow and slope > 0.0
    lrBear := close < midNow and slope < 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — ALIGNMENT & BREAKOUT SIGNALS
// ═══════════════════════════════════════════════════════════════════════════════

bool alignBull  = lrBull and pivBull and warmed
bool alignBear  = lrBear and pivBear and warmed

bool brkUp = ta.crossover(close, close[1] + crossTol * atrVal) and lrSlope > 0.0 and warmed and barstate.isconfirmed
bool brkDn = ta.crossunder(close, close[1] - crossTol * atrVal) and lrSlope < 0.0 and warmed and barstate.isconfirmed

// Breakout labels
if showBrk and brkUp
    label.new(bar_index, high + atrVal * 0.5,
         "▲ BRK", color=color.new(cUp, 10), textcolor=color.white,
         style=label.style_label_up, size=size.small, xloc=xloc.bar_index)

if showBrk and brkDn
    label.new(bar_index, low - atrVal * 0.5,
         "▼ BRK", color=color.new(cDn, 10), textcolor=color.white,
         style=label.style_label_down, size=size.small, xloc=xloc.bar_index)

// Alignment background highlight (subtle)
bgcolor(alignBull ? color.new(cUp,  96) : alignBear ? color.new(cDn, 96) : na, title="Alignment BG")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — PIVOT CHANNEL QUALITY GAUGE (plot)
// ═══════════════════════════════════════════════════════════════════════════════

// We plot nothing on the main overlay here (lines drawn above),
// but expose key values for cross-indicator use
plot(na, title="Prism Bull Align",  display=display.data_window)
plot(na, title="Prism Bear Align",  display=display.data_window)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 9,
     bgcolor=color.new(#0D1117, 10), border_color=color.new(#30363D, 80), border_width=1,
     frame_color=color.new(#58A6FF, 60), frame_width=1)

dashCell(int row, string lbl, string val, color vc) =>
    table.cell(dash, 0, row, lbl, text_color=color.new(#8B949E, 0), text_size=size.small, bgcolor=color.new(#0D1117, 10))
    table.cell(dash, 1, row, val, text_color=vc,                     text_size=size.small, bgcolor=color.new(#161B22, 10))

if showDash and barstate.islast
    table.cell(dash, 0, 0, "PCA [JOAT]", text_color=color.new(#58A6FF, 0),
         text_size=size.normal, bgcolor=color.new(#0D1117, 5))
    table.cell(dash, 1, 0, ticker,        text_color=color.new(#E6EDF3, 0),
         text_size=size.normal, bgcolor=color.new(#0D1117, 5))

    string lrDir   = lrSlope > 0.0 ? "▲ Rising" : lrSlope < 0.0 ? "▼ Falling" : "— Flat"
    color  lrDirC  = lrSlope > 0.0 ? cUp : lrSlope < 0.0 ? cDn : cNeutral
    string qStr    = str.tostring(math.round(pivChQ * 100.0)) + "%"
    color  qCol    = pivChQ > 0.65 ? cUp : pivChQ > 0.40 ? color.new(#FFB300, 0) : cDn
    string pivDirS = pivBull ? "▲ Bull Zone" : pivBear ? "▼ Bear Zone" : "— Neutral"
    color  pivDirC = pivBull ? cUp : pivBear ? cDn : cNeutral
    string alStr   = alignBull ? "⬆ BULL ALIGN" : alignBear ? "⬇ BEAR ALIGN" : "— No Align"
    color  alCol   = alignBull ? cUp : alignBear ? cDn : cNeutral
    string brkStr  = brkUp ? "▲ UP BREAK" : brkDn ? "▼ DN BREAK" : "— None"
    color  brkCol  = brkUp ? cUp : brkDn ? cDn : cNeutral
    string atrStr  = str.tostring(math.round(atrVal * 10000.0) / 10000.0)
    string pivCnt  = str.tostring(array.size(plIdx) + array.size(phIdx))

    dashCell(1, "LR Direction",  lrDir,   lrDirC)
    dashCell(2, "LR Dev Mult",   str.tostring(lrDev), cNeutral)
    dashCell(3, "Pivot Quality", qStr,    qCol)
    dashCell(4, "Pivot Position",pivDirS, pivDirC)
    dashCell(5, "Alignment",     alStr,   alCol)
    dashCell(6, "Breakout",      brkStr,  brkCol)
    dashCell(7, "ATR",           atrStr,  cNeutral)
    dashCell(8, "Pivots Stored", pivCnt,  cNeutral)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — WATERMARK
// ═══════════════════════════════════════════════════════════════════════════════

var label wmLbl = na
if showWm and barstate.islast
    label.delete(wmLbl)
    wmLbl := label.new(bar_index - 5, ta.highest(high, 50),
         "JackOfAllTrades", color=color.new(#FFFFFF, 100),
         textcolor=color.new(#FFFFFF, 82), style=label.style_none,
         size=size.large, xloc=xloc.bar_index)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 12 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertMsg(string sig, string dir) =>
    useJson ?
     '{"source":"PCA_JOAT","ticker":"' + ticker + '","signal":"' + sig + '","direction":"' + dir + '","price":"' + str.tostring(close) + '"}' :
     "PCA [JOAT] — " + sig + " | " + dir + " | " + ticker + " @ " + str.tostring(close)

if brkUp
    alert(alertMsg("BREAKOUT", "BULLISH"), alert.freq_once_per_bar_close)
if brkDn
    alert(alertMsg("BREAKOUT", "BEARISH"), alert.freq_once_per_bar_close)
if alignBull and not alignBull[1]
    alert(alertMsg("ALIGNMENT", "BULL CONFLUENCE"), alert.freq_once_per_bar_close)
if alignBear and not alignBear[1]
    alert(alertMsg("ALIGNMENT", "BEAR CONFLUENCE"), alert.freq_once_per_bar_close)

alertcondition(brkUp,     "Bullish Breakout",     "PCA [JOAT] — Bullish Breakout")
alertcondition(brkDn,     "Bearish Breakout",     "PCA [JOAT] — Bearish Breakout")
alertcondition(alignBull, "Bull Channel Align",   "PCA [JOAT] — Bull Channel Alignment")
alertcondition(alignBear, "Bear Channel Align",   "PCA [JOAT] — Bear Channel Alignment")
````
