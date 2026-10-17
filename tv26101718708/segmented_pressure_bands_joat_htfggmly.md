# Segmented Pressure Bands [JOAT]

- url: https://www.tradingview.com/script/HTfGgMLY-Segmented-Pressure-Bands-JOAT/
- type: indicator
- pine_id: PUB;c984ac441ef24c0a8a5a6f67b8f4d8e2
- version: 1.0

## Description

[b]Segmented Pressure Bands [JOAT][/b]

[b]Introduction[/b]

Segmented Pressure Bands (SPB) is an open-source, institutional-grade regression channel system that computes a linear best-fit line and deviation bands from scratch using manual Ordinary Least Squares (OLS) mathematics — no built-in regression functions used. The channel operates in distinct segments: it builds over a dynamic lookback window, freezes all parameters at a minimum length threshold, extrapolates forward using the frozen slope and intercept, and resets automatically when price closes beyond the outer deviation band. Gradient linefill layers between the basis and outer bands communicate channel pressure visually. A volume regime tint adjusts visual weight based on relative volume activity, and ATR-based TP/SL visualization is drawn on each breakout reset.

The core problem SPB solves is that standard regression channels repaint continuously as new bars add to the calculation window, making historical channel boundaries unreliable for reference. SPB's freeze-and-extrapolate architecture locks the regression parameters at a fixed point in time, then projects the channel forward. Price that deviates far enough from that projection triggers a segment reset — the channel is redrawn from the breakout point. This creates a clear, non-repainting record of each regression segment and the breakout that ended it.

[image]https://www.tradingview.com/x/kQlzoYd9/[/image]

[b]Core Concepts[/b]

[b]1. Manual OLS Linear Regression[/b]

The regression is computed using the standard Ordinary Least Squares normal equations applied to the source series over the active lookback window:

[pine]
float denom = float(length) * sumX2 - sumX * sumX
slope     := (float(length) * sumXY - sumX * sumY) / denom
intercept := (sumY - slope * sumX) / float(length)
[/pine]

RMSE (root mean square error) is calculated as the deviation of the source from the fitted line, providing the basis for band width. All accumulator variables (sumX, sumY, sumXY, sumX2) are computed in a per-bar loop, giving full control over the calculation window without relying on built-in functions that may change behavior across versions.

[b]2. Channel Freeze and Extrapolation[/b]

When the lookback window reaches the minimum length threshold, the slope, intercept, and RMSE are locked into freeze variables. From that point forward, the x-coordinate passed to the regression formula is the number of bars elapsed since the freeze bar, allowing the channel to project forward without recalculating:

[pine]
float xCur = -float(bar_index - freezeBar)
basis     := frozenIcpt + frozenSlope * xCur
[/pine]

This extrapolation means the bands continue to move with the slope direction, but their relative spacing (the RMSE deviation) remains constant from the freeze point.

[b]3. Segment Reset on Breakout[/b]

When a candle closes beyond the outer upper or lower band, the current segment is terminated. The channel redraws from the current bar using the fresh source data from that point forward. Old linefill objects are explicitly deleted before new ones are created to stay within Pine Script's object limits.

[b]4. Gradient Linefills and Volume Regime Tint[/b]

N intermediate lines are drawn between the basis and each outer band, filled progressively with increasing transparency from the inner region to the outer edge. This creates a gradient pressure visualization — tighter fills near the basis signal equilibrium, wider fills near the outer band signal stretch. When the volume regime ratio (short-term MA / long-term MA) is elevated above the high threshold, line widths increase and fill opacity deepens to communicate high-activity conditions visually.

[b]Features[/b]

[list]
[*][b]Manual OLS Regression:[/b] Slope, intercept, and RMSE computed entirely from first principles — no built-in regression functions
[*][b]Freeze and Extrapolate Architecture:[/b] Regression parameters locked at minimum length; channel projected forward along the locked slope
[*][b]Automatic Segment Reset:[/b] Outer band close-beyond triggers segment restart — prior segment preserved as a historical record
[*][b]RMSE Deviation Bands:[/b] Upper and lower bands placed at configurable RMSE multiples from the basis line
[*][b]Gradient Linefill Layers:[/b] N intermediate lines fill the channel space with a visual pressure gradient — configurable step count
[*][b]Volume Regime Tint:[/b] Relative volume ratio (short/long MA) adjusts visual weight — elevated volume deepens channel fills and thickens lines
[*][b]ATR TP/SL Visualization:[/b] On each breakout reset, ATR-based take profit and stop loss boxes drawn from the breakout close
[*][b]Channel Direction Color:[/b] Downward slope (bullish context — price above a declining regression) renders in teal; upward slope (bearish context) renders in rose
[*][b]Non-Repainting Basis:[/b] Freeze architecture ensures historical segment boundaries do not move after they are drawn
[*][b]Configurable Source:[/b] Basis line source is selectable (close, hl2, hlc3, ohlc4, etc.)
[*][b]Dashboard (Top Right):[/b] Current slope, RMSE, volume regime label, band multiplier, and active segment bar count
[*][b]Near-Band Warning Dots:[/b] Subtle circle markers appear on the chart when price is within 12% of either channel edge — early warning that price is approaching a band extreme before a breakout occurs
[*][b]Distance-to-Nearest-Band in Dashboard:[/b] Current distance from price to the nearest band displayed as a percentage of channel width — provides a precise quantitative read of how stretched or compressed the current position is within the segment
[*][b]Live Regression Slope in Dashboard:[/b] Live regression slope value shown in the dashboard — communicates the current directional angle of the frozen channel projection in real time
[*][b]Breakout Win/Loss Tracking:[/b] Outcome of every breakout trade tracked against ATR-based TP/SL levels — total breakout trade count and cumulative win rate displayed in the dashboard
[*][b]Expanded Dashboard (7 Rows):[/b] Dashboard expanded to 7 rows — now includes distance-to-band percentage, live slope, and breakout win rate alongside existing regime and segment data
[/list]

[b]Input Parameters[/b]

[b]Regression Settings:[/b]
[list]
[*]Source: Price input for regression calculation (default: close)
[*]Lookback Length: Maximum bar window for OLS computation (default: 50)
[*]Min Length to Freeze: Bar count at which slope/intercept are locked (default: 20)
[*]Band Multiplier: RMSE multiple for outer band placement (default: 2.0)
[/list]

[b]Gradient Settings:[/b]
[list]
[*]Gradient Steps: Number of intermediate fill lines between basis and outer band (default: 5)
[/list]

[b]Volume Regime:[/b]
[list]
[*]Short Vol MA: Short-term volume moving average length (default: 10)
[*]Long Vol MA: Long-term volume moving average length (default: 40)
[*]High Vol Threshold: Vol ratio above which volume tint activates (default: 1.5)
[/list]

[b]ATR / Risk:[/b]
[list]
[*]ATR Length: Period for ATR calculation (default: 14)
[*]ATR SL Multiplier: Stop loss distance on breakout (default: 1.5)
[*]Reward:Risk Ratio: Take profit multiple of stop distance (default: 3.0)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Channel Direction[/b]
A teal channel indicates a downward-sloping regression — price is above a declining trend line, suggesting bullish pressure within the distribution. A rose channel indicates an upward-sloping regression — price is below a rising channel ceiling, suggesting bearish pressure. The gradient fills communicate how far price has deviated from the basis within that segment.

[b]Step 2: Trade Within the Channel[/b]
Price compressing toward the basis from an outer band (thin fill region narrowing) suggests mean reversion is underway. Price expanding toward the outer band (fills widening) suggests momentum continuation. The outer band itself acts as a stretch boundary — closes beyond it trigger a new segment.

[b]Step 3: React to Breakout Resets[/b]
When a segment resets, the breakout bar is the reference point for directional bias. The ATR TP/SL boxes visualize the immediate risk/reward from that close. The new channel building from the breakout will establish the next directional context.

[b]Step 4: Monitor Volume Context[/b]
Elevated volume regime (shown in dashboard) at a channel boundary gives more conviction to breakout or reversal signals. Low-volume channel touches carry less institutional weight.

[b]Indicator Limitations[/b]

[list]
[*]The OLS calculation runs a loop over the lookback window on every bar. On very long lookback lengths with high chart data density, this may increase script execution time — keep lookback below 200 for best performance
[*]The freeze architecture means the channel projection can diverge significantly from price if the instrument trends strongly after the freeze point. Segment resets bring the channel back to current price, but wide outer bands may delay that reset on low-volatility instruments
[*]Gradient linefills are subject to Pine Script's 50-linefill object limit. SPB manages this with explicit deletion on each segment reset. If the gradient steps setting is set very high (above 10), this limit may be approached in active markets
[*]ATR TP/SL boxes on breakout are drawn from the breakout close. They do not adjust for gaps, overnight moves, or instrument-specific spread — manual adjustment of the ATR multiplier may be needed for highly volatile instruments
[*]Volume regime calculation uses simple moving averages of volume. On instruments where volume data is synthetic or unavailable, the regime indicator will not reflect true market activity
[/list]

[b]Originality Statement[/b]

SPB implements a regression channel with a freeze-extrapolate-reset lifecycle that produces stable, non-repainting historical segment boundaries. This design is original for the following reasons:

[list]
[*]Computing OLS slope, intercept, and RMSE from scratch using raw accumulator mathematics — rather than using ta.linreg() or similar built-ins — gives full control over the calculation window, source, and update behavior, and avoids implicit look-ahead that some built-in functions can introduce
[*]The freeze-and-extrapolate architecture is distinct from standard rolling regression, where every new bar shifts the entire historical channel. Once frozen, SPB's channel parameters are immutable — historical band boundaries drawn in past segments are permanent reference levels
[*]The gradient linefill layer system communicates statistical deviation pressure visually across the full channel width, rather than drawing only a basis and outer band with no information about the space between them
[*]The integration of a volume regime tint directly into the regression channel visualization — adjusting visual weight based on relative volume — provides immediate context for whether current channel position is occurring during active or quiet market conditions
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Regression channels and statistical deviation bands are mathematical constructs applied to historical data — they do not predict future price behavior. Breakout signals at band extremes do not guarantee continuation in any direction. Always apply proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Segmented Pressure Bands [JOAT]", shorttitle="SPB [JOAT]",
     overlay=true, max_lines_count=500, max_labels_count=200)

// ── GROUPS ─────────────────────────────────────────────────────────────────────
var string GRP_CH  = "Channel Settings"
var string GRP_VOL = "Volume Regime Tint"
var string GRP_TP  = "TP/SL"
var string GRP_TPD = "TP/SL Display"
var string GRP_VIS = "Visual"
var string GRP_DASH= "Dashboard"
var string GRP_ALT = "Alerts"

// ── CHANNEL INPUTS ─────────────────────────────────────────────────────────────
i_src      = input.source(close, "Source",              group=GRP_CH)
i_devMult  = input.float(1.5,  "Deviation Multiplier", minval=0.5, step=0.1,  group=GRP_CH)
i_minLen   = input.int(15,     "Min Channel Length",   minval=5,   maxval=100, group=GRP_CH,
     tooltip="At this length the slope freezes. Channel extrapolates forward until a breakout.")
i_maxLen   = input.int(300,    "Max Channel Length",   minval=50,              group=GRP_CH)
i_gradN    = input.int(4,      "Gradient Steps",       minval=1,   maxval=8,   group=GRP_CH,
     tooltip="Number of linefill bands between each outer edge and the regression basis.")
i_bullCol  = input.color(color.new(#00bcd4, 0), "Bull Channel Color",          group=GRP_CH)
i_bearCol  = input.color(color.new(#dd326b, 0), "Bear Channel Color",          group=GRP_CH)

// ── VOLUME TINT INPUTS ─────────────────────────────────────────────────────────
i_useVolTint = input.bool(true,  "Enable Volume Tint",                          group=GRP_VOL,
     tooltip="Thickens the channel border and deepens fill opacity when volume regime is High or Extreme.")
i_volShort   = input.int(5,   "Volume Short SMA", minval=1,                    group=GRP_VOL)
i_volLong    = input.int(100, "Volume Long SMA",  minval=10,                   group=GRP_VOL)
i_volHigh    = input.float(1.8,"High Volume Threshold", step=0.1,              group=GRP_VOL)

// ── TP/SL INPUTS ───────────────────────────────────────────────────────────────
i_showTP   = input.bool(true,  "Show TP/SL on Breakout",                       group=GRP_TP)
i_useATRSL = input.bool(true,  "SL = ATR x Multiplier (vs %)",                group=GRP_TP)
i_atrPer   = input.int(14,     "ATR Period",    minval=1,                      group=GRP_TP)
i_slATR    = input.float(1.5,  "SL ATR Mult",  step=0.1,                      group=GRP_TP)
i_slPct    = input.float(1.0,  "SL %",         step=0.1,                      group=GRP_TP)
i_rrTP1    = input.float(1.0,  "TP1 RR",       step=0.1,                      group=GRP_TP)
i_rrTP2    = input.float(2.0,  "TP2 RR",       step=0.1,                      group=GRP_TP)
i_rrTP3    = input.float(3.0,  "TP3 RR",       step=0.1,                      group=GRP_TP)

i_showSL   = input.bool(true,  "SL",  group=GRP_TPD)
i_showTP1  = input.bool(true,  "TP1", group=GRP_TPD)
i_showTP2  = input.bool(true,  "TP2", group=GRP_TPD)
i_showTP3  = input.bool(true,  "TP3", group=GRP_TPD)

// ── DASHBOARD INPUT ────────────────────────────────────────────────────────────
i_showDash = input.bool(true, "Show Dashboard", group=GRP_DASH)

// ── ALERT INPUTS ───────────────────────────────────────────────────────────────
i_altBreakUp   = input.bool(true,"Breakout Up Alert",   group=GRP_ALT)
i_altBreakDown = input.bool(true,"Breakout Down Alert", group=GRP_ALT)

// ── CORE CALCULATIONS ─────────────────────────────────────────────────────────
float atrVal   = ta.atr(i_atrPer)
float volShort = ta.sma(volume, i_volShort)
float volLong  = ta.sma(volume, i_volLong)
float volReg   = volLong > 0 ? volShort / volLong : 1.0
bool  highVol  = volReg >= i_volHigh

// ── CHANNEL STATE VARIABLES ───────────────────────────────────────────────────
var int   chanStart   = 0
var line  upperLine   = na
var line  lowerLine   = na
var line  baseLine    = na

var bool  isFrozen    = false
var int   freezeBar   = na
var float frozenSlope = na
var float frozenIcpt  = na
var float frozenDev   = na

// Gradient line + fill arrays — cleared on each new segment
var array<line>     upperInterLines = array.new<line>()
var array<line>     lowerInterLines = array.new<line>()
var array<float>    upperInterFs    = array.new<float>()
var array<float>    lowerInterFs    = array.new<float>()
var array<linefill> upperFills      = array.new<linefill>()
var array<linefill> lowerFills      = array.new<linefill>()

// TP/SL state
var int   tradeDir    = 0
var int   tradeBar    = na
var float slLvl       = na
var float extLvl      = na

// Win / Loss tracking
var int   spbTotT = 0
var int   spbTotW = 0
var int   spbUpT  = 0
var int   spbUpW  = 0
var int   spbDnT  = 0
var int   spbDnW  = 0
var line  entLine     = na
var label entLbl      = na
var line  slLine      = na
var label slLbl       = na
var line  tp1Line     = na
var label tp1Lbl      = na
var line  tp2Line     = na
var label tp2Lbl      = na
var line  tp3Line     = na
var label tp3Lbl      = na
var line  extLine     = na
var linefill riskFill = na
var linefill rwdFill  = na

// ── SEGMENT METRICS ───────────────────────────────────────────────────────────
int  segBars  = bar_index - chanStart + 1
bool canCalc  = segBars >= 2
bool canExt   = segBars < i_maxLen
int  length   = canExt ? segBars : i_maxLen
bool enough   = segBars >= i_minLen

// ── OLS LINEAR REGRESSION (manual, dynamic window) ────────────────────────────
float slope     = na
float intercept = na
float dev       = na

// x = 0 at current bar, x = length-1 at oldest bar (i = bar offset)
if canCalc and not isFrozen
    float sumX  = 0.0
    float sumY  = 0.0
    float sumXY = 0.0
    float sumX2 = 0.0
    for i = 0 to length - 1
        float xi = float(i)
        float yi = i_src[i]
        if not na(yi)
            sumX  += xi
            sumY  += yi
            sumXY += xi * yi
            sumX2 += xi * xi
    float denom = float(length) * sumX2 - sumX * sumX
    if denom != 0.0
        slope     := (float(length) * sumXY - sumX * sumY) / denom
        intercept := (sumY - slope * sumX) / float(length)

    // RMSE (standard deviation of residuals)
    float sumSq = 0.0
    for i = 0 to length - 1
        if not na(i_src[i])
            float regVal = intercept + slope * float(i)
            float diff   = i_src[i] - regVal
            sumSq += diff * diff
    dev := math.sqrt(sumSq / float(length))

// ── FREEZE SLOPE AT minLength ──────────────────────────────────────────────────
if enough and not isFrozen and segBars == i_minLen and barstate.isconfirmed
    isFrozen    := true
    freezeBar   := bar_index
    frozenSlope := slope
    frozenIcpt  := intercept
    frozenDev   := dev

// ── COMPUTE CURRENT BAND LEVELS ────────────────────────────────────────────────
float basis = na
float upper = na
float lower = na

if canCalc
    if isFrozen
        float xCur = -float(bar_index - freezeBar)
        basis := frozenIcpt + frozenSlope * xCur
        upper := basis + frozenDev * i_devMult
        lower := basis - frozenDev * i_devMult
    else
        basis := intercept
        upper := basis + dev * i_devMult
        lower := basis - dev * i_devMult

// ── BREAKOUT CONDITIONS ────────────────────────────────────────────────────────
bool brkUp   = enough and not na(upper) and close > upper and barstate.isconfirmed and
               (not isFrozen or (bar_index - freezeBar) >= 1)
bool brkDown = enough and not na(lower) and close < lower and barstate.isconfirmed and
               (not isFrozen or (bar_index - freezeBar) >= 1)

// ── CHANNEL COLOR: slope direction + optional volume tint ─────────────────────
// slope < 0 → price trending up (x decreases toward present) → bullish
// slope > 0 → price trending down → bearish
bool chBull  = isFrozen ? frozenSlope <= 0.0 : (not na(slope) and slope <= 0.0)
color chBase = chBull ? i_bullCol : i_bearCol
int   lnWid  = i_useVolTint and highVol ? 2 : 1
float fOuter = i_useVolTint and highVol ? 70.0 : 75.0
float fInner = i_useVolTint and highVol ? 90.0 : 95.0

// ── DRAW/UPDATE CHANNEL LINES ─────────────────────────────────────────────────
if canCalc and barstate.isconfirmed
    float sY     = na
    float sUpper = na
    float sLower = na

    if isFrozen
        float xStart = float(freezeBar - chanStart)
        sY     := frozenIcpt + frozenSlope * xStart
        sUpper := sY + frozenDev * i_devMult
        sLower := sY - frozenDev * i_devMult
    else
        sY     := intercept + slope * float(length - 1)
        sUpper := sY + dev * i_devMult
        sLower := sY - dev * i_devMult

    if na(baseLine)
        // ── First draw of this segment ─────────────────────────────────────
        baseLine  := line.new(chanStart, sY,     bar_index, basis, color=color.new(#888888,50), width=1)
        upperLine := line.new(chanStart, sUpper, bar_index, upper, color=color.new(chBase,0),   width=lnWid)
        lowerLine := line.new(chanStart, sLower, bar_index, lower, color=color.new(chBase,0),   width=lnWid)

        array.clear(upperInterLines)
        array.clear(upperInterFs)
        array.clear(lowerInterLines)
        array.clear(lowerInterFs)

        // Intermediate lines — upper side (from outer to center)
        for k = 1 to i_gradN - 1
            float f  = float(i_gradN - k) / float(i_gradN)
            float y1 = sY + f * (sUpper - sY)
            float y2 = basis + f * (upper - basis)
            line il  = line.new(chanStart, y1, bar_index, y2, color=color.new(chBase, 100), width=1)
            array.push(upperInterLines, il)
            array.push(upperInterFs, f)

        // Intermediate lines — lower side
        for k = 1 to i_gradN - 1
            float f  = float(i_gradN - k) / float(i_gradN)
            float y1 = sY + f * (sLower - sY)
            float y2 = basis + f * (lower - basis)
            line il  = line.new(chanStart, y1, bar_index, y2, color=color.new(chBase, 100), width=1)
            array.push(lowerInterLines, il)
            array.push(lowerInterFs, f)

        // ── Create upper gradient fills ───────────────────────────────────
        if array.size(upperFills) > 0
            for fi = 0 to array.size(upperFills) - 1
                linefill.delete(array.get(upperFills, fi))
        array.clear(upperFills)

        line prevU = upperLine
        for i = 0 to i_gradN - 1
            float trp = fOuter + (fInner - fOuter) * (float(i) / float(i_gradN))
            color col = color.new(chBase, trp)
            line  currL = i < i_gradN - 1 ? array.get(upperInterLines, i) : baseLine
            linefill lf = linefill.new(prevU, currL, col)
            array.push(upperFills, lf)
            prevU := currL

        // ── Create lower gradient fills ───────────────────────────────────
        if array.size(lowerFills) > 0
            for fi = 0 to array.size(lowerFills) - 1
                linefill.delete(array.get(lowerFills, fi))
        array.clear(lowerFills)

        line prevL = lowerLine
        for i = 0 to i_gradN - 1
            float trp = fOuter + (fInner - fOuter) * (float(i) / float(i_gradN))
            color col = color.new(chBase, trp)
            line  currL = i < i_gradN - 1 ? array.get(lowerInterLines, i) : baseLine
            linefill lf = linefill.new(prevL, currL, col)
            array.push(lowerFills, lf)
            prevL := currL

    else if canExt and not (brkUp or brkDown)
        // ── Update existing lines ─────────────────────────────────────────
        line.set_xy1(baseLine,  chanStart, sY)
        line.set_xy2(baseLine,  bar_index, basis)
        line.set_xy1(upperLine, chanStart, sUpper)
        line.set_xy2(upperLine, bar_index, upper)
        line.set_xy1(lowerLine, chanStart, sLower)
        line.set_xy2(lowerLine, bar_index, lower)

        for ui = 0 to array.size(upperInterLines) - 1
            line   il = array.get(upperInterLines, ui)
            float  f  = array.get(upperInterFs,    ui)
            line.set_xy1(il, chanStart, sY + f * (sUpper - sY))
            line.set_xy2(il, bar_index, basis + f * (upper - basis))

        for li = 0 to array.size(lowerInterLines) - 1
            line   il = array.get(lowerInterLines, li)
            float  f  = array.get(lowerInterFs,    li)
            line.set_xy1(il, chanStart, sY + f * (sLower - sY))
            line.set_xy2(il, bar_index, basis + f * (lower - basis))

// ── HANDLE BREAKOUT: RESET SEGMENT + OPEN TP/SL ───────────────────────────────
if brkUp or brkDown
    // Old lines remain as historical record — do not delete
    chanStart   := bar_index
    baseLine    := na
    upperLine   := na
    lowerLine   := na
    isFrozen    := false
    freezeBar   := na
    frozenSlope := na
    frozenIcpt  := na
    frozenDev   := na
    array.clear(upperInterLines)
    array.clear(upperInterFs)
    array.clear(lowerInterLines)
    array.clear(lowerInterFs)

    if i_showTP
        // Delete previous TP/SL set
        line.delete(entLine)
        label.delete(entLbl)
        line.delete(slLine)
        label.delete(slLbl)
        line.delete(tp1Line)
        label.delete(tp1Lbl)
        line.delete(tp2Line)
        label.delete(tp2Lbl)
        line.delete(tp3Line)
        label.delete(tp3Lbl)
        line.delete(extLine)
        linefill.delete(riskFill)
        linefill.delete(rwdFill)

        int   dir       = brkUp ? 1 : -1
        tradeDir       := dir
        tradeBar       := bar_index
        float entPrice  = close
        float riskDist  = i_useATRSL ? atrVal * i_slATR : entPrice * (i_slPct / 100.0)
        float slLocal   = dir == 1 ? entPrice - riskDist : entPrice + riskDist
        float tp1p      = dir == 1 ? entPrice + riskDist * i_rrTP1 : entPrice - riskDist * i_rrTP1
        float tp2p      = dir == 1 ? entPrice + riskDist * i_rrTP2 : entPrice - riskDist * i_rrTP2
        float tp3p      = dir == 1 ? entPrice + riskDist * i_rrTP3 : entPrice - riskDist * i_rrTP3

        // Compute extreme TP for fill
        float extLocal = na
        if i_showTP3
            extLocal := tp3p
        if i_showTP2
            extLocal := na(extLocal) ? tp2p : (dir == 1 ? math.max(extLocal, tp2p) : math.min(extLocal, tp2p))
        if i_showTP1
            extLocal := na(extLocal) ? tp1p : (dir == 1 ? math.max(extLocal, tp1p) : math.min(extLocal, tp1p))

        slLvl  := slLocal
        extLvl := extLocal

        color eLine = dir == 1 ? i_bullCol : i_bearCol
        color sLine = color.new(#dd326b, 40)
        color tLine = color.new(#00bcd4, 40)

        entLine := line.new(bar_index, entPrice, bar_index + 1, entPrice,
             color=eLine, width=2, extend=extend.right)
        entLbl  := label.new(bar_index, entPrice,
             (dir == 1 ? "BUY " : "SELL ") + str.tostring(entPrice, format.mintick),
             style=label.style_label_left, color=eLine, textcolor=color.white, size=size.small)

        if i_showSL
            slLine := line.new(bar_index, slLocal, bar_index + 1, slLocal,
                 color=sLine, width=1, style=line.style_dashed, extend=extend.right)
            slLbl  := label.new(bar_index, slLocal,
                 "SL " + str.tostring(slLocal, format.mintick),
                 style=label.style_label_left, color=sLine, textcolor=color.white, size=size.tiny)

        if i_showTP1
            tp1Line := line.new(bar_index, tp1p, bar_index + 1, tp1p,
                 color=tLine, width=1, extend=extend.right)
            tp1Lbl  := label.new(bar_index, tp1p,
                 "TP1 " + str.tostring(tp1p, format.mintick),
                 style=label.style_label_left, color=tLine, textcolor=color.white, size=size.tiny)

        if i_showTP2
            tp2Line := line.new(bar_index, tp2p, bar_index + 1, tp2p,
                 color=tLine, width=1, extend=extend.right)
            tp2Lbl  := label.new(bar_index, tp2p,
                 "TP2 " + str.tostring(tp2p, format.mintick),
                 style=label.style_label_left, color=tLine, textcolor=color.white, size=size.tiny)

        if i_showTP3
            tp3Line := line.new(bar_index, tp3p, bar_index + 1, tp3p,
                 color=tLine, width=1, style=line.style_dotted, extend=extend.right)
            tp3Lbl  := label.new(bar_index, tp3p,
                 "TP3 " + str.tostring(tp3p, format.mintick),
                 style=label.style_label_left, color=tLine, textcolor=color.white, size=size.tiny)

        if i_showSL
            riskFill := linefill.new(entLine, slLine, color.new(#dd326b, 88))

        if not na(extLocal)
            extLine  := line.new(bar_index, extLocal, bar_index + 1, extLocal,
                 color=na, extend=extend.right)
            rwdFill  := linefill.new(entLine, extLine, color.new(#00bcd4, 88))

// ── MANAGE ACTIVE TP/SL ────────────────────────────────────────────────────────
if tradeDir != 0
    label.set_x(entLbl, bar_index)
    if not na(slLbl)
        label.set_x(slLbl,  bar_index)
    if not na(tp1Lbl)
        label.set_x(tp1Lbl, bar_index)
    if not na(tp2Lbl)
        label.set_x(tp2Lbl, bar_index)
    if not na(tp3Lbl)
        label.set_x(tp3Lbl, bar_index)

    bool slHit = tradeDir == 1 ? low  <= slLvl : high >= slLvl
    bool tpHit = not na(extLvl) and (tradeDir == 1 ? high >= extLvl : low <= extLvl)

    if bar_index > tradeBar and (slHit or tpHit)
        line.set_extend(entLine, extend.none)
        line.set_x2(entLine, bar_index)
        if not na(slLine)
            line.set_extend(slLine,  extend.none)
            line.set_x2(slLine,  bar_index)
        if not na(tp1Line)
            line.set_extend(tp1Line, extend.none)
            line.set_x2(tp1Line, bar_index)
        if not na(tp2Line)
            line.set_extend(tp2Line, extend.none)
            line.set_x2(tp2Line, bar_index)
        if not na(tp3Line)
            line.set_extend(tp3Line, extend.none)
            line.set_x2(tp3Line, bar_index)
        if not na(extLine)
            line.set_extend(extLine, extend.none)
            line.set_x2(extLine, bar_index)
        spbTotT += 1
        if tpHit
            spbTotW += 1
            if tradeDir == 1
                spbUpW += 1
            else
                spbDnW += 1
        if tradeDir == 1
            spbUpT += 1
        else
            spbDnT += 1
        tradeDir := 0

// ── NEAR BAND WARNING MARKERS ─────────────────────────────────────────────────
bool nearUpper = not na(upper) and not na(lower) and (upper - close) / math.max(upper - lower, 0.0001) < 0.12
bool nearLower = not na(upper) and not na(lower) and (close - lower) / math.max(upper - lower, 0.0001) < 0.12
plotshape(nearUpper and not brkUp,   "Near Upper Band", shape.circle, location.abovebar, color.new(chBull ? i_bullCol : i_bearCol, 60), size=size.tiny)
plotshape(nearLower and not brkDown, "Near Lower Band", shape.circle, location.belowbar, color.new(chBull ? i_bullCol : i_bearCol, 60), size=size.tiny)

// ── BREAKOUT SHAPE MARKERS ─────────────────────────────────────────────────────
plotshape(brkUp,   "Break Up",   shape.triangleup,   location.belowbar, i_bullCol, size=size.small)
plotshape(brkDown, "Break Down", shape.triangledown, location.abovebar, i_bearCol, size=size.small)

// ── DASHBOARD ─────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 4, 7,
     bgcolor=color.new(#0d0d14, 80), border_width=0, frame_width=0)

if barstate.islast and i_showDash
    color cHead = chBull ? color.new(#00bcd4, 0) : color.new(#dd326b, 0)
    color cBody = color.new(#d0d0d0, 0)
    color cDim  = color.new(#707070, 0)
    color cBgH  = color.new(#0d0d14, 72)
    color cBgR  = color.new(#111118, 60)

    string slopeDir = chBull ? "BULL" : "BEAR"
    string volStr   = highVol ? "HIGH" : volReg < 0.7 ? "LOW" : "NORM"
    color  volCol   = highVol ? cHead : cDim

    table.cell(dash, 0, 0, "SPB [JOAT]",   text_color=cHead, text_size=size.small, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 1, 0, "",             text_size=size.normal, bgcolor=cBgH)
    table.cell(dash, 2, 0, slopeDir,       text_color=cHead, text_size=size.small, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 3, 0, "Vol " + volStr,text_color=volCol,text_size=size.normal,  text_halign=text.align_right, bgcolor=cBgH)

    table.cell(dash, 0, 1, "Seg Bars",     text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 1, 1, str.tostring(segBars), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 1, "Frozen",       text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 3, 1, isFrozen ? "YES" : "NO", text_color=isFrozen ? cHead : cDim, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    table.cell(dash, 0, 2, "Deviation",    text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    float curDev = isFrozen ? frozenDev : dev
    table.cell(dash, 1, 2, na(curDev) ? "---" : str.tostring(curDev, "#.4f"), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 2, 2, "Vol Reg",      text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 3, 2, str.tostring(volReg, "#.2f"), text_color=volCol,  text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

    table.cell(dash, 0, 3, "Min Len",      text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 1, 3, str.tostring(i_minLen), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 3, "Dev Mult",     text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 3, 3, str.tostring(i_devMult, "#.1f") + "x", text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    table.cell(dash, 0, 4, "Trade",        text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    string tStr = tradeDir == 1 ? "LONG" : tradeDir == -1 ? "SHORT" : "FLAT"
    color  tCol = tradeDir == 1 ? color.new(#00bcd4,0) : tradeDir == -1 ? color.new(#dd326b,0) : cDim
    table.cell(dash, 1, 4, tStr, text_color=tCol, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 2, 4, "RR",          text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 3, 4, str.tostring(i_rrTP3,"#.0") + ":1", text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

    // ── Row 5 — Distance to band ─────────────────────────────────────────────
    float chanWidth = not na(upper) and not na(lower) ? upper - lower : na
    float distUp    = not na(upper) ? upper - close : na
    float distLo    = not na(lower) ? close - lower : na
    float nearDist  = not na(distUp) and not na(distLo) ? math.min(distUp, distLo) : na
    float nearPct   = not na(nearDist) and not na(chanWidth) and chanWidth > 0 ? nearDist / chanWidth * 100.0 : na
    string nearStr  = not na(nearPct) ? str.tostring(nearPct, "#.1") + "%" : "---"
    color  nearCol  = not na(nearPct) and nearPct < 15.0 ? cHead : cBody
    table.cell(dash, 0, 5, "To Band",      text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    table.cell(dash, 1, 5, nearStr,         text_color=nearCol, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 5, "Slope",         text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    float curSlope  = isFrozen ? frozenSlope : slope
    string slopeStr = not na(curSlope) ? str.tostring(curSlope, "#.5f") : "---"
    table.cell(dash, 3, 5, slopeStr,        text_color=cHead, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    // ── Row 6 — Breakout win rate ─────────────────────────────────────────────
    float spbWR = spbTotT > 0 ? spbTotW * 100.0 / spbTotT : 0.0
    table.cell(dash, 0, 6, "Brk Trades", text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgH)
    table.cell(dash, 1, 6, str.tostring(spbTotT),           text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 2, 6, "Win Rate",   text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgH)
    table.cell(dash, 3, 6, str.tostring(spbWR, "#.0") + "%", text_color=spbWR >= 50.0 ? color.new(#00bcd4, 0) : color.new(#dd326b, 0), text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

// ── ALERTS ─────────────────────────────────────────────────────────────────────
alertcondition(i_altBreakUp   and brkUp,   "SPB Break Up",   "Segmented Pressure Bands [JOAT]: Upward breakout from channel")
alertcondition(i_altBreakDown and brkDown, "SPB Break Down", "Segmented Pressure Bands [JOAT]: Downward breakout from channel")
````
