# Fan Principle Signals [MarkitTick]

- url: https://www.tradingview.com/script/vR9kCx5r-Fan-Principle-Signals-MarkitTick/
- type: indicator
- pine_id: PUB;d1f5f2f7397c4bf0938384321ca749b4
- version: 1.0

## Description

💡 Maps out market structure using a sequence of ascending swing lows (or descending swing highs) to construct a three-legged trendline fan, then triggers actionable trade signals the moment price breaks through the steepest line in that fan. Rather than relying on a single moving average or oscillator crossover, this script builds its bias from the actual geometry of recent price swings, giving traders a structural, visually intuitive way to time entries around the exhaustion of a trend.

[b]✨ Originality and Utility[/b]
Most breakout tools react to a single reference line, such as a moving average, a fixed channel, or a static trendline drawn from only two points. This script instead applies the fan principle, a technique that connects a common origin point to three successive pivots in the same trend, producing three lines of increasing steepness. The logic behind this approach is that the third and steepest line in the fan typically represents the most aggressive rate of trend continuation, and a decisive close beyond it has historically signaled that the prevailing trend has lost its structural support.

What makes this implementation useful in practice is that it does not stop at drawing the fan. It automatically identifies valid pivot sequences from raw price action, filters out insignificant micro-swings using a minimum leg percentage threshold, validates the freshness of the structure with a lookback cap, and then converts the break event into a complete trade plan, including entry, stop-loss, and three take-profit levels, all derived mathematically from the fan's own geometry and the market's current volatility. The optional volume and higher-timeframe filters allow traders to demand additional confirmation before a signal is accepted, and the built-in dashboard keeps the entire state of the system visible at a glance. The combination of automated structural fan detection, ATR-adaptive risk placement, and live trade monitoring is what distinguishes this from a simple trendline break script.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/mzowq18p/[/image]
[b]• Pivot Detection[/b]
The script continuously scans for swing highs and swing lows using a symmetrical lookback and lookforward window defined by the Pivot Len input. A bar qualifies as a swing high only if it is strictly greater than every other bar within that window on both sides, and a swing low only if it is strictly lower than every bar in that window. Each time a new pivot is confirmed, its bar index and price are stored in a rolling array, keeping the most recent twenty pivots in memory for both highs and lows.

[b]• Fan Construction[/b]
Once at least four pivot lows (for an uptrend fan) or four pivot highs (for a downtrend fan) are available, the script selects the four most recent ones. The oldest of the four becomes the fan's origin point. The remaining three form Leg 1, Leg 2, and Leg 3 respectively, each connected back to that same origin. A slope is then calculated for each leg using simple rise-over-run between the origin and that leg's pivot. For the fan to be accepted, the price move between the origin and the first leg must exceed the Min Leg % threshold, which filters out fans built from statistically insignificant noise, and the origin must fall within the Max Fan Lookback window, which prevents the script from anchoring to structure that is too old to remain relevant.

[b]• The Break Condition[/b]
Leg 3, the line connecting the origin to the most recent and steepest pivot, is treated as the trigger line. Its price value is projected forward on every bar using the slope calculated at formation. A bullish break requires the fan to currently be in an uptrend orientation, the previous confirmed bar's close to be above the projected Leg 3 value, and the bar before that to have closed at or below it, meaning the break itself happens on a confirmed, completed bar rather than an in-progress one. The bearish break condition mirrors this logic in the opposite direction for downtrend fans. This confirmed-close approach means the script never fires or removes a signal based on an incomplete, still-forming bar, so historical signals will not disappear or move once printed.

[b]• Optional Confirmation Filters[/b]
Two independent filters can be layered on top of the raw break condition. The volume filter requires the breaking bar's volume to exceed a multiple of its recent moving average, screening out breaks that occur on unusually thin participation. The higher-timeframe filter compares the breakout bar's close against the prior, fully closed bar on a higher timeframe of your choosing, requiring the breakout direction to align with that broader trend context before a signal is allowed to fire.

[b]• Trade Level Calculation[/b]
When a break is confirmed, the script builds an entry, stop, and three take-profit levels automatically. Entry is anchored to the close of the breakout bar. The stop-loss is placed beyond the nearest of the two most recent fan legs, offset further by a small ATR buffer to avoid being clipped by minor wicks, but it is also capped by a maximum ATR distance so a single outlier swing cannot produce an oversized stop. The distance between entry and stop becomes the base risk unit, and the three take-profit levels are placed at user-defined multiples of that risk unit, giving a consistent, R-multiple-based framework for managing the position rather than arbitrary fixed-price targets.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/h8aTO6Ow/[/image]
[list]
[*]Dotted lines connecting the origin point to Leg 1 and Leg 2 show the earlier, less steep sections of the fan structure and provide visual context for how the trend developed.
[*]The solid, extended line represents Leg 3, the active trigger line. It is colored using the Bull Fan color when the fan is in an uptrend orientation and the Bear Fan color when it is in a downtrend orientation, and it projects forward in real time as new bars form.
[*]A blue dashed line marks the Entry level once a signal fires, extending to the right for as many bars as the trade remains active or until a new signal replaces it.
[*]A red solid line marks the Stop-Loss level, with a light red shaded zone (the Risk Fill) drawn between the entry and stop lines to make the risk portion of the trade immediately visible.
[*]Three dashed lines in progressively deeper shades of teal mark Take-Profit 1, 2, and 3, moving from lightest (TP1, closest to entry) to fully opaque (TP3, furthest away). A light teal shaded zone (the Reward Fill) spans from the entry line to the TP3 line, visually contrasting the reward portion of the trade against the risk portion.
[*]Small labels are anchored to each of these lines on the left, displaying the exact price of the Stop, Entry, and each Take-Profit level, and updating their horizontal position as the trade progresses.
[*]An upward-pointing "▲ BUY" label appears below the breakout bar on a bullish break, and a downward-pointing "▼ SELL" label appears above the breakout bar on a bearish break.
[*]An optional on-chart dashboard table displays the ticker and timeframe, whether the Lock Signal feature is active, the current fan orientation, the origin price, the live value of the Leg 3 trigger line, the current entry, stop, a live risk-to-reward progress bar showing how far price has travelled toward TP3 relative to the initial risk, the volume filter status, and the number of bars elapsed since the last signal.
[/list]

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/rOL36Vkv/[/image]
A signal is generated only when price decisively closes beyond the Leg 3 trigger line of an established fan, so treat the fan's orientation, shown both by the line color and by the Fan State readout on the dashboard, as the prevailing structural bias before a break occurs. When a bullish break prints, the suggested plan is to consider a long entry near the displayed Entry line, with the Stop-Loss line defining the invalidation point below and the three Take-Profit lines offering staged exit levels as the move develops. A bearish break mirrors this in the opposite direction for short setups.

The R:R Progress bar on the dashboard is useful for monitoring an active trade at a glance: it fills from 0% toward 100% as price advances from entry toward the TP3 target, and its color shifts from red through amber to teal as the trade's risk-to-reward ratio improves. If the Lock Signal option is enabled, the script freezes the most recently confirmed signal and its levels in place rather than allowing a new one to overwrite them, which can help when you want to manage an open position without the on-chart levels shifting. Because signals are confirmed only on closed bars, always wait for bar close before acting on a fresh line break rather than reacting to an in-progress wick.

Enabling the optional Volume and HTF filters will typically reduce signal frequency while raising the bar for confirmation, so consider testing both configurations to see which better matches the behavior of the instrument and timeframe you trade.

[b]⚙️ Inputs and Settings[/b]
[image]https://www.tradingview.com/x/vEMFdwS5/[/image]
[list]
[*][b]Pivot Len[/b] — Controls how many bars on each side must confirm a swing high or low. Smaller values detect pivots faster but produce noisier, more frequent fan structures; larger values produce fewer but more structurally significant pivots.
[*][b]Max Fan Lookback[/b] — The maximum age, in bars, that a fan's origin point can have and still be considered valid. Lowering this keeps the script focused on recent structure only.
[*][b]Min Leg %[/b] — The minimum percentage price move required between the origin and the first leg for a fan to be accepted, filtering out fans built on insignificant price movement.
[*][b]Use Vol Filt / Vol Avg Len / Vol Mult[/b] — Enables a volume confirmation requirement, comparing current volume against its moving average over the specified length, multiplied by the chosen factor.
[*][b]Use HTF Filt / HTF[/b] — Enables a higher-timeframe trend alignment requirement, comparing the breakout close against the prior confirmed close on the chosen higher timeframe.
[*][b]SL ATR Buf[/b] — The ATR-based buffer added beyond the nearest fan leg when placing the stop-loss, giving the stop room to avoid minor wick noise.
[*][b]SL Max ATR[/b] — A ceiling, expressed in ATR multiples, on how far the stop-loss can be placed from entry, preventing outsized stops on unusually wide fans.
[*][b]ATR Len[/b] — The lookback length used for the ATR calculation that feeds both the stop buffer and the stop cap.
[*][b]TP1 R / TP2 R / TP3 R[/b] — The risk-multiple distances used to place the three take-profit levels relative to the initial risk unit between entry and stop.
[*][b]Lock Signal[/b] — Freezes the current signal and its associated levels in place, preventing a new signal from overwriting them until manually disabled.
[*][b]Show Fan Lines / Show Trade Levels / Show Labels[/b] — Independently toggle the visibility of the fan structure lines, the entry/stop/TP levels, and their accompanying price labels.
[*][b]Show Dash / Dash Pos[/b] — Toggle the on-chart dashboard and choose which corner of the chart it is anchored to.
[*]A full set of color inputs is available to customize the fan lines, trade level lines, fill zones, signal labels, and dashboard appearance to match your own chart theme.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The fan principle applied here descends from classical technical analysis literature on trendline construction, most notably the Gann fan and Andrews' Pitchfork family of tools, which share the premise that connecting a structural origin point to successive swing extremes produces a family of trendlines whose slopes carry predictive meaning about the trend's rate of change. Where this script departs from those older, largely manual techniques is in how the origin and legs are selected: rather than relying on the analyst's subjective choice of anchor points, pivot selection here is fully algorithmic, using a symmetric local-extremum test to ensure each point used is objectively the highest or lowest price within its surrounding window.

The core statistical assumption underlying any trendline-break system is that price trends exhibit a degree of serial correlation, meaning that the rate of ascent or descent between swing points tends to persist for some period before mean-reverting or reversing, and that a violation of the most recent, steepest rate of change is informative about a shift in that underlying process. This is conceptually related to the broader family of change-point detection methods used in time-series analysis, where a structural break in a fitted trend line is used as a signal that the data-generating process has shifted regime. The ATR-based position sizing layered on top draws from the well-established use of Average True Range as a volatility-normalized unit of risk, a concept popularized in behavioral and quantitative trading literature as a way of scaling stop and target distances to the instrument's own recent volatility rather than using arbitrary fixed-point distances, which do not generalize across different assets or market conditions.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Fan Principle Signals [MarkitTick]", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ── INPUTS ─────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core"
var string GRP_FILT = "🕯️ Filters"
var string GRP_TT   = "📐 Trade Tools"
var string GRP_VIS  = "🎨 Visuals"
var string GRP_DASH = "📊 Dashboard"
var string GRP_WH   = "🔔 Alerts"
var string GRP_COL  = "🌈 Colors"
i_pivLen      = input.int(5, "Pivot Len", minval=2, group=GRP_CORE)
i_lockSignal  = input.bool(false, "🔒 Lock Signal", group=GRP_TT, tooltip="Freeze current signal · block new ones")
i_maxFanBars  = input.int(300, "Max Fan Lookback", minval=50, group=GRP_CORE)
i_minLegPct   = input.float(0.1, "Min Leg %", minval=0.0, step=0.05, group=GRP_CORE)
i_useVolFilt  = input.bool(false, "Use Vol Filt", group=GRP_FILT)
i_volLen      = input.int(20, "Vol Avg Len", minval=5, group=GRP_FILT)
i_volMult     = input.float(1.2, "Vol Mult", minval=0.5, step=0.1, group=GRP_FILT)
i_useHtfFilt  = input.bool(false, "Use HTF Filt", group=GRP_FILT)
i_htfTf       = input.timeframe("60", "HTF", group=GRP_FILT)
i_slBufAtr    = input.float(0.1, "SL ATR Buf", minval=0.0, step=0.05, group=GRP_TT)
i_slMaxAtr    = input.float(3.0, "SL Max ATR", minval=0.5, step=0.5, group=GRP_TT)
i_atrLen      = input.int(14, "ATR Len", minval=1, group=GRP_TT)
i_tp1R        = input.float(1.0, "TP1 R", minval=0.1, step=0.1, group=GRP_TT)
i_tp2R        = input.float(2.0, "TP2 R", minval=0.1, step=0.1, group=GRP_TT)
i_tp3R        = input.float(3.0, "TP3 R", minval=0.1, step=0.1, group=GRP_TT)
i_showFanLn   = input.bool(false, "Show Fan Lines", group=GRP_VIS)
i_showLevels  = input.bool(true, "Show Trade Levels", group=GRP_VIS)
i_showLbl     = input.bool(true, "Show Labels", group=GRP_VIS)
i_showDash    = input.bool(true, "Show Dash", group=GRP_DASH)
i_dashPos     = input.string("Top Right", "Dash Pos", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_DASH)
i_actionLong        = input.string("long", "↑ Long Act", group=GRP_WH)
i_actionShort       = input.string("short", "↓ Short Act", group=GRP_WH)
i_actionCloseLong   = input.string("closelong", "✕ CloseLong Act", group=GRP_WH)
i_actionCloseShort  = input.string("closeshort", "✕ CloseShort Act", group=GRP_WH)
c_fanBull     = input.color(color.new(#26a69a, 0), "Bull Fan", group=GRP_COL)
c_fanBear     = input.color(color.new(#ef5350, 0), "Bear Fan", group=GRP_COL)
c_sl          = input.color(#ef5350, "SL Line", group=GRP_COL)
c_entry       = input.color(#2196f3, "Entry Line", group=GRP_COL)
c_tp1         = input.color(color.new(#26a69a, 40), "TP1 Line", group=GRP_COL)
c_tp2         = input.color(color.new(#26a69a, 20), "TP2 Line", group=GRP_COL)
c_tp3         = input.color(color.new(#26a69a, 0), "TP3 Line", group=GRP_COL)
c_riskFill    = input.color(color.new(#ef5350, 80), "Risk Fill", group=GRP_COL)
c_rewardFill  = input.color(color.new(#26a69a, 85), "Reward Fill", group=GRP_COL)
c_buyLbl      = input.color(#26a69a, "BUY Label", group=GRP_COL)
c_sellLbl     = input.color(#ef5350, "SELL Label", group=GRP_COL)
C_DASH_HDR    = input.color(color.new(#3a2a6d, 55), "Dash Hdr", group=GRP_COL)
_mt741a     = input.color(color.new(#0a0f1a, 10), "Dash BG", group=GRP_COL)
C_DASH_TXT    = input.color(color.new(#ffffff, 0), "Dash Txt", group=GRP_COL)

// ── CORE LOGIC ──────────────────────────────────────────
f_pivotHigh(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 0 to len * 2
        if i != len and src[i] >= candidate
            isValid := false
    isValid ? candidate : na
f_pivotLow(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 0 to len * 2
        if i != len and src[i] <= candidate
            isValid := false
    isValid ? candidate : na
float ph = f_pivotHigh(high, i_pivLen)
float pl = f_pivotLow(low, i_pivLen)
var int phBar = na
var int plBar = na
var float phVal = na
var float plVal = na
if not na(ph)
    phBar := bar_index - i_pivLen
    phVal := ph
if not na(pl)
    plBar := bar_index - i_pivLen
    plVal := pl
atrVal = ta.atr(i_atrLen)
volAvg = ta.sma(volume, i_volLen)
bool volOk = i_useVolFilt ? volume > volAvg * i_volMult : true
float htfClose = request.security(syminfo.tickerid, i_htfTf, close[1], lookahead=barmerge.lookahead_on)
float htfCloseNow = i_useHtfFilt ? htfClose : na
var array<int> loBarArr = array.new<int>()
var array<float> loValArr = array.new<float>()
var array<int> hiBarArr = array.new<int>()
var array<float> hiValArr = array.new<float>()
if not na(pl) and barstate.isconfirmed
    array.push(loBarArr, plBar)
    array.push(loValArr, plVal)
    if array.size(loBarArr) > 20
        array.shift(loBarArr)
        array.shift(loValArr)
if not na(ph) and barstate.isconfirmed
    array.push(hiBarArr, phBar)
    array.push(hiValArr, phVal)
    if array.size(hiBarArr) > 20
        array.shift(hiBarArr)
        array.shift(hiValArr)
f_slope(int x1, float y1, int x2, float y2) =>
    x2 != x1 ? (y2 - y1) / (x2 - x1) : 0.0
f_lineValAt(int x1, float y1, float m, int xTarget) =>
    y1 + m * (xTarget - x1)
var int originBar = na
var float originVal = na
var int fanDir = 0
var int fL1Bar = na
var float fL1Val = na
var int fL2Bar = na
var float fL2Val = na
var int fL3Bar = na
var float fL3Val = na
var float fanM1 = na
var float fanM2 = na
var float fanM3 = na
bool canBuildBullFan = array.size(loBarArr) >= 4
bool canBuildBearFan = array.size(hiBarArr) >= 4
if barstate.isconfirmed and canBuildBullFan
    int n = array.size(loBarArr)
    int oB = array.get(loBarArr, n - 4)
    float oV = array.get(loValArr, n - 4)
    int b1 = array.get(loBarArr, n - 3)
    float v1 = array.get(loValArr, n - 3)
    int b2 = array.get(loBarArr, n - 2)
    float v2 = array.get(loValArr, n - 2)
    int b3 = array.get(loBarArr, n - 1)
    float v3 = array.get(loValArr, n - 1)
    bool freshEnough = (bar_index - oB) <= i_maxFanBars
    bool _mt741b = math.abs(v1 - oV) / oV * 100.0 >= i_minLegPct
    if freshEnough and _mt741b and b1 > oB and b2 > b1 and b3 > b2 and (na(fanDir) or fanDir != -1 or b3 > fL3Bar)
        originBar := oB
        originVal := oV
        fanDir := 1
        fL1Bar := b1
        fL1Val := v1
        fL2Bar := b2
        fL2Val := v2
        fL3Bar := b3
        fL3Val := v3
        fanM1 := f_slope(oB, oV, b1, v1)
        fanM2 := f_slope(oB, oV, b2, v2)
        fanM3 := f_slope(oB, oV, b3, v3)
if barstate.isconfirmed and canBuildBearFan
    int n = array.size(hiBarArr)
    int oB = array.get(hiBarArr, n - 4)
    float oV = array.get(hiValArr, n - 4)
    int b1 = array.get(hiBarArr, n - 3)
    float v1 = array.get(hiValArr, n - 3)
    int b2 = array.get(hiBarArr, n - 2)
    float v2 = array.get(hiValArr, n - 2)
    int b3 = array.get(hiBarArr, n - 1)
    float v3 = array.get(hiValArr, n - 1)
    bool freshEnough = (bar_index - oB) <= i_maxFanBars
    bool _mt741b = math.abs(v1 - oV) / oV * 100.0 >= i_minLegPct
    if freshEnough and _mt741b and b1 > oB and b2 > b1 and b3 > b2 and (na(fanDir) or fanDir != 1 or b3 > fL3Bar)
        originBar := oB
        originVal := oV
        fanDir := -1
        fL1Bar := b1
        fL1Val := v1
        fL2Bar := b2
        fL2Val := v2
        fL3Bar := b3
        fL3Val := v3
        fanM1 := f_slope(oB, oV, b1, v1)
        fanM2 := f_slope(oB, oV, b2, v2)
        fanM3 := f_slope(oB, oV, b3, v3)
float fan3ValNow = na(fanM3) ? na : f_lineValAt(originBar, originVal, fanM3, bar_index)
float fan3ValPrev = na(fanM3) ? na : f_lineValAt(originBar, originVal, fanM3, bar_index - 1)
bool bullBreak = fanDir == 1 and not na(fan3ValNow) and close[1] > fan3ValPrev and close[2] <= f_lineValAt(originBar, originVal, fanM3, bar_index - 2) and volOk and (not i_useHtfFilt or (not na(htfCloseNow) and close[1] > htfCloseNow)) and barstate.isconfirmed
bool bearBreak = fanDir == -1 and not na(fan3ValNow) and close[1] < fan3ValPrev and close[2] >= f_lineValAt(originBar, originVal, fanM3, bar_index - 2) and volOk and (not i_useHtfFilt or (not na(htfCloseNow) and close[1] < htfCloseNow)) and barstate.isconfirmed
var float lowestOfTrend = na
var float highestOfTrend = na
if fanDir == 1 and not na(originBar)
    lowestOfTrend := math.min(originVal, math.min(fL1Val, math.min(fL2Val, fL3Val)))
if fanDir == -1 and not na(originBar)
    highestOfTrend := math.max(originVal, math.max(fL1Val, math.max(fL2Val, fL3Val)))
var int lastSignalBar = na
var int signalDir = 0
var float entryPrice = na
var float slPrice = na
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na
var float riskDist = na
if bullBreak
    lastSignalBar := bar_index
    signalDir := 1
    entryPrice := close[1]
    float nearestLegLow = math.min(fL2Val, fL3Val)
    float rawSl = nearestLegLow - atrVal[1] * i_slBufAtr
    float slFloor = entryPrice - atrVal[1] * i_slMaxAtr
    slPrice := math.max(rawSl, slFloor)
    riskDist := entryPrice - slPrice
    tp1Price := entryPrice + riskDist * i_tp1R
    tp2Price := entryPrice + riskDist * i_tp2R
    tp3Price := entryPrice + riskDist * i_tp3R
if bearBreak
    lastSignalBar := bar_index
    signalDir := -1
    entryPrice := close[1]
    float nearestLegHigh = math.max(fL2Val, fL3Val)
    float rawSl = nearestLegHigh + atrVal[1] * i_slBufAtr
    float slCeil = entryPrice + atrVal[1] * i_slMaxAtr
    slPrice := math.min(rawSl, slCeil)
    riskDist := slPrice - entryPrice
    tp1Price := entryPrice - riskDist * i_tp1R
    tp2Price := entryPrice - riskDist * i_tp2R
    tp3Price := entryPrice - riskDist * i_tp3R
bool tp1Hit = not na(tp1Price) and signalDir == 1 ? high >= tp1Price : not na(tp1Price) and signalDir == -1 ? low <= tp1Price : false
bool tp2Hit = not na(tp2Price) and signalDir == 1 ? high >= tp2Price : not na(tp2Price) and signalDir == -1 ? low <= tp2Price : false
bool tp3Hit = not na(tp3Price) and signalDir == 1 ? high >= tp3Price : not na(tp3Price) and signalDir == -1 ? low <= tp3Price : false
// ── VISUALS ─────────────────────────────────────────
var line fanLn1 = na
var line fanLn2 = na
var line fanLn3 = na
f_deleteFan() =>
    line.delete(fanLn1)
    line.delete(fanLn2)
    line.delete(fanLn3)
if i_showFanLn and barstate.isconfirmed and (bullBreak or bearBreak or (not na(fanM3) and fanDir != 0 and (na(fL3Bar[1]) or fL3Bar != fL3Bar[1])))
    f_deleteFan()
    color fanClr = fanDir == 1 ? c_fanBull : c_fanBear
    fanLn1 := line.new(originBar, originVal, fL1Bar, fL1Val, color=fanClr, style=line.style_dotted, width=1)
    fanLn2 := line.new(originBar, originVal, fL2Bar, fL2Val, color=fanClr, style=line.style_dotted, width=1)
    fanLn3 := line.new(originBar, originVal, fL3Bar, fL3Val, color=fanClr, style=line.style_solid, width=2)
    line.set_extend(fanLn3, extend.right)
var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na
f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)
bool newSignal = bullBreak or bearBreak
bool _locked = i_lockSignal and barstate.islast
if i_showLevels and newSignal and not _locked
    f_deleteLevels()
    int _x2 = bar_index + 50
    slLine := line.new(bar_index, slPrice, _x2, slPrice, color=c_sl, style=line.style_solid, width=2)
    entryLine := line.new(bar_index, entryPrice, _x2, entryPrice, color=c_entry, style=line.style_dashed, width=1)
    tp1Line := line.new(bar_index, tp1Price, _x2, tp1Price, color=c_tp1, style=line.style_dashed, width=1)
    tp2Line := line.new(bar_index, tp2Price, _x2, tp2Price, color=c_tp2, style=line.style_dashed, width=1)
    tp3Line := line.new(bar_index, tp3Price, _x2, tp3Price, color=c_tp3, style=line.style_dashed, width=1)
    riskFill := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)
    if i_showLbl
        slLbl := label.new(bar_index, slPrice, "✕ SL " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=c_sl, textcolor=color.white, size=size.small)
        entryLbl := label.new(bar_index, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=c_entry, textcolor=color.white, size=size.small)
        tp1Lbl := label.new(bar_index, tp1Price, "◆ TP1 " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=c_tp1, textcolor=color.white, size=size.small)
        tp2Lbl := label.new(bar_index, tp2Price, "✦ TP2 " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=c_tp2, textcolor=color.white, size=size.small)
        tp3Lbl := label.new(bar_index, tp3Price, "◆ TP3 " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=c_tp3, textcolor=color.white, size=size.small)
if i_showLevels and not na(slLine) and not na(lastSignalBar) and (i_lockSignal or bar_index <= lastSignalBar + 50)
    int _extX = i_lockSignal ? bar_index + 50 : lastSignalBar + 50
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    if i_showLbl
        label.set_x(slLbl, _extX)
        label.set_x(entryLbl, _extX)
        label.set_x(tp1Lbl, _extX)
        label.set_x(tp2Lbl, _extX)
        label.set_x(tp3Lbl, _extX)
if i_showLbl and bullBreak
    label.new(bar_index - 1, low[1], "▲ BUY", style=label.style_label_up, color=c_buyLbl, textcolor=color.white, size=size.small)
if i_showLbl and bearBreak
    label.new(bar_index - 1, high[1], "▼ SELL", style=label.style_label_down, color=c_sellLbl, textcolor=color.white, size=size.small)

// ── ALERTS ────────────────────────────────────────────
string _longInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"', i_actionLong, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick))
string longPayload = "{" + _longInner + "}"
string _shortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"', i_actionShort, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick))
string shortPayload = "{" + _shortInner + "}"
string _clInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}"', i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _clInner + "}"
string _csInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}"', i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _csInner + "}"
string _tp1Inner = str.format('"action":"tp1hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp1Price, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"
string _tp2Inner = str.format('"action":"tp2hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp2Price, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"
string _tp3Inner = str.format('"action":"tp3hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp3Price, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"
if bullBreak and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if bearBreak and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if bearBreak and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if bullBreak and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
if tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)
alertcondition(bullBreak and barstate.isconfirmed, "BUY Signal", "FanPro — BUY Signal Fired")
alertcondition(bearBreak and barstate.isconfirmed, "SELL Signal", "FanPro — SELL Signal Fired")
alertcondition(bearBreak and barstate.isconfirmed, "Close Long Signal", "FanPro — Close Long")
alertcondition(bullBreak and barstate.isconfirmed, "Close Short Signal", "FanPro — Close Short")
// ── DASHBOARD ──────────────────────────────────────
string _mt741c = i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : i_dashPos == "Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(_mt741c, 2, 10, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40))
f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(math.max(val, 0.0) / maxVal, 1.0) * 10)
    string barStr = ""
    for i = 1 to 10
        barStr += i <= filled ? "█" : "░"
    barStr + "  " + str.tostring(math.round(math.min(math.max(val, 0.0) / maxVal, 1.0) * 100)) + "%"
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)
if i_showDash
    row_a = _mt741a
    row_b = color.new(_mt741a, 40)
    table.cell(dash, 0, 0, "FanPro", text_color=C_DASH_TXT, bgcolor=C_DASH_HDR, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, bgcolor=C_DASH_HDR, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 1, "  Lock", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 1, (i_lockSignal ? "ACTIVE" : "OFF") + "  ", text_color=i_lockSignal ? color.new(#ef5350, 0) : C_DASH_TXT, bgcolor=row_a, text_halign=text.align_right, text_size=size.small)
    string fanState = fanDir == 1 ? "▲ Bull" : fanDir == -1 ? "▼ Bear" : "○ None"
    color fanStCol = fanDir == 1 ? c_fanBull : fanDir == -1 ? c_fanBear : C_DASH_TXT
    table.cell(dash, 0, 2, "  Fan State", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, fanState + "  ", text_color=fanStCol, bgcolor=row_b, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 3, "  Origin", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 3, (na(originVal) ? "n/a" : str.tostring(originVal, format.mintick)) + "  ", text_color=C_DASH_TXT, bgcolor=row_a, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 4, "  Fan3 Lvl", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, (na(fan3ValNow) ? "n/a" : str.tostring(fan3ValNow, format.mintick)) + "  ", text_color=C_DASH_TXT, bgcolor=row_b, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 5, "  Entry", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 5, (na(entryPrice) ? "n/a" : str.tostring(entryPrice, format.mintick)) + "  ", text_color=C_DASH_TXT, bgcolor=row_a, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 6, "  SL", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 6, (na(slPrice) ? "n/a" : str.tostring(slPrice, format.mintick)) + "  ", text_color=color.new(#ef5350, 0), bgcolor=row_b, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 7, "  R:R Prog", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_halign=text.align_left, text_size=size.small)
    float rrNow = na(riskDist) or riskDist == 0 ? na : signalDir == 1 ? (high - entryPrice) / riskDist : signalDir == -1 ? (entryPrice - low) / riskDist : na
    float rrPct = na(rrNow) ? 0.0 : math.min(math.max(rrNow, 0.0), i_tp3R) / i_tp3R
    string rrBarStr = na(rrNow) ? "░░░░░░░░░░  0%" : f_bar(rrNow, i_tp3R)
    table.cell(dash, 1, 7, rrBarStr + "  ", text_color=f_barColor(rrPct), bgcolor=row_a, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 8, "  Vol Filt", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_b, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 8, (volOk ? "✓ OK" : "✕ Block") + "  ", text_color=volOk ? color.new(#26a69a, 0) : color.new(#ef5350, 0), bgcolor=row_b, text_halign=text.align_right, text_size=size.small)
    table.cell(dash, 0, 9, "  Bars Since Sig", text_color=color.new(C_DASH_TXT, 25), bgcolor=row_a, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 9, (na(lastSignalBar) ? "n/a" : str.tostring(bar_index - lastSignalBar)) + "  ", text_color=C_DASH_TXT, bgcolor=row_a, text_halign=text.align_right, text_size=size.small)
````
