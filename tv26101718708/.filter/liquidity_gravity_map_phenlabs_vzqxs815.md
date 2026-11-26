# Liquidity Gravity Map [PhenLabs]

- url: https://www.tradingview.com/script/vZQxS815-Liquidity-Gravity-Map-PhenLabs/
- type: indicator
- pine_id: PUB;b1da3a10fca8477e99208aa0f0e7b325
- version: 1.0

## Description

[b]📊 Liquidity Gravity Map [PhenLabs][/b]
Version: PineScript™ v6

https://www.tradingview.com/x/9kskCdS4/

[b]📌 Description[/b]
The Liquidity Gravity Map is an advanced, quantitative approach to dynamic support and resistance detection. Rather than simply plotting static lines at prior highs and lows, this indicator treats liquidity as a gravitational force that accumulates, decays, and dynamically shifts based on price action and volume. It builds a real-time, scored “map” of liquidity zones on your chart, quantifying their structural integrity, mitigation behavior, and time-based decay.

It is designed to solve the problem of chart clutter and “false zones.” By continuously scoring and pruning liquidity pools based on their real-time relevance, structural significance, and VWAP acceptance, traders are presented only with the most critical, high-probability areas of interest where price is likely to be attracted or rejected. 

[b]🚀 Points of Innovation[/b]
[list]
[*] [b]Composite Scoring Engine:[/b] Zones are not binary. They are graded on a 0-100 scale using 7 distinct metrics: Structure, Revisits, Wicks, VWAP Context, Mitigation, Decay, and Proximity.
[*] [b]Dynamic Memory Allocation:[/b] Employs an internal memory cap (Max Zones) and a pruning algorithm to actively remove ancient, low-scoring zones, keeping the chart responsive and clean.
[*] [b]VWAP Acceptance Context:[/b] Integrates Session VWAP and Standard Deviation bands. The indicator scores zones higher if their creation aligns with bullish VWAP reclaims or bearish VWAP rejections.
[*] [b]Mitigation & Absorption Tracking:[/b] Dynamically evaluates how price interacts with a zone. It tracks volume, penetration depth, and displacement to quantify if a zone is being absorbed (defended) or broken.
[*] [b]Time-Decay Function:[/b] Untouched liquidity zones lose their “gravitational pull” over time via an exponential decay function, prioritizing fresh liquidity.
[/list]

[b]🔧 Core Components[/b]
[list]
[*] [b]Zone Detection Algorithm:[/b] Identifies swing highs/lows and stop-hunt wicks, factoring in equal highs/lows clustering and wick ratios to establish initial structural strength.
[*] [b]Session VWAP Engine:[/b] Calculates volume-weighted average price and its standard deviations over configurable sessions (RTH, Day, Week, Month) to gauge macro context and acceptance.
[*] [b]Revisit Tracker:[/b] Monitors how many times a zone is tested. A zone’s score adjusts based on its frequency of testing relative to other active zones on the chart.
[/list]

[b]🔥 Key Features[/b]
[list]
[*] Live Composite Score (0-100) dynamically updated per zone.
[*] Automatic culling of stale, irrelevant liquidity levels.
[*] Highly customizable lookback, zone sensitivity, and memory caps.
[*] Dynamic gradient coloring based on zone score (Bullish/Bearish).
[*] Toggleable Zone Labels displaying directional bias, score, and revisit count.
[/list]

[b]🎨 Visualization[/b]
[list]
[*] [b]Gradient Liquidity Boxes:[/b] Visualizes liquidity zones as shaded boxes. The opacity and color temperature (cool to warm) dynamically change based on the zone’s live composite score.
[*] [b]VWAP Bands:[/b] Optional visual overlay of the Session VWAP and ±1σ / ±2σ standard deviation bands.
[*] [b]Zone Labels:[/b] Small text labels attached to active boxes indicating “BULL” or “BEAR”, the “LG” (Liquidity Gravity) score, and “R” (Revisits).
[/list]

[b]📖 Usage Guidelines[/b]
[b]Core Settings[/b]
[list]
[*] [b]Lookback Period:[/b] (Default: 120) Determines the window for identifying stop-hunts and aging cleanup.
[*] [b]Zone Sensitivity:[/b] (Default: 3.0) Controls the width of the generated zones and the tolerance for merging equal highs/lows. Higher values create wider, merged bands.
[*] [b]Max Visible Zones:[/b] (Default: 8) The maximum number of top-scoring zones to render on the chart at one time.
[*] [b]Score Decay Rate:[/b] (Default: 0.010) The exponential rate at which a zone’s score drops while untouched.
[/list]

[b]VWAP Acceptance Settings[/b]
[list]
[*] [b]VWAP Session Type:[/b] (Default: Day) Anchor period for the VWAP calculations (RTH, Day, Week, Month).
[*] [b]RTH Session:[/b] (Default: 0930-1600) Defines Regular Trading Hours if “RTH” is selected as the session type.
[/list]

[b]Visual Settings[/b]
[list]
[*] [b]Color Theme:[/b] (Default: Classic) Choose between Classic, Neon, or Monochrome color palettes for the zone gradients.
[/list]

[b]✅ Best Use Cases[/b]
[list]
[*] Identifying high-probability reversal areas for mean-reversion trading.
[*] Spotting areas where trapped liquidity (stop-hunts) is likely to act as a strong magnet for price.
[*] Filtering out weak support/resistance levels by relying on the composite score to highlight only structurally significant, defended zones.
[/list]

[b]⚠️ Limitations[/b]
[list]
[*] Rapidly changing volatility can cause sudden shifts in zone width, as it is dynamically tied to the Average True Range (ATR).
[*] Because the map limits the number of visible zones to the highest scoring ones, a valid but slightly lower-scoring zone might be hidden from view.
[/list]

[b]💡 What Makes This Unique[/b]
[list]
[*] [b]Quantitative Liquidity Modeling:[/b] Most indicators draw static boxes at highs/lows. This script dynamically evaluates the “health” of a zone through continuous math—scoring penetration, volume absorption, decay, and VWAP alignment.
[/list]

[b]🔬 How It Works[/b]
[b]1. Detection & Generation:[/b]
The script continuously monitors for structural pivots and significant wicks. When detected, a zone is created with an initial strength score based on structural clustering and ATR.
[b]2. Continuous Evaluation:[/b]
Every confirmed bar, the script updates active zones. It tracks if price has touched the zone, penetrated it, or been rejected, factoring in relative volume to determine if the liquidity was absorbed or broken.
[b]3. Scoring & Display:[/b]
A final 0-100 score is computed using structural integrity, VWAP context, wicks, revisits, decay, and proximity to current price. Only the top “N” scoring zones are dynamically rendered on the chart.

[quote][i]💡 Note: Ensure your chart data provides reliable volume data, as the absorption and VWAP scoring mechanics heavily rely on it for accurate calculations.[/i][/quote]

## Source Code

````pine
//@version=6
indicator("Liquidity Gravity Map [PhenLabs]", shorttitle="LGM [Phen]", overlay=true, max_boxes_count=300, max_labels_count=300)

//------------------------------------------------------------------------------
// INPUTS
//------------------------------------------------------------------------------
groupCore  = "Core"
groupVWAP  = "VWAP Acceptance"
groupVis   = "Visuals"

lookback_period   = input.int(120, "Lookback Period", minval=30, maxval=500, group=groupCore)
zone_sensitivity  = input.float(4.0, "Zone Sensitivity", minval=0.5, maxval=10.0, step=0.25, group=groupCore)
max_zones         = input.int(40, "Max Zones (Memory Cap)", minval=10, maxval=150, group=groupCore)
max_visible_zones = input.int(4, "Max Visible Zones", minval=1, maxval=20, group=groupCore)
score_decay_rate  = input.float(0.010, "Score Decay Rate", minval=0.001, maxval=0.050, step=0.001, group=groupCore)

vwap_session_type = input.string("Day", "VWAP Session Type", options=["RTH", "Day", "Week", "Month"], group=groupVWAP)
rth_session       = input.session("0930-1600", "RTH Session", group=groupVWAP)
show_vwap_bands   = input.bool(true, "Show VWAP Bands", group=groupVWAP)

color_theme       = input.string("Classic", "Color Theme", options=["Classic", "Neon", "Monochrome"], group=groupVis)
show_labels       = input.bool(true, "Show Zone Labels", group=groupVis)

//------------------------------------------------------------------------------
// PERSISTENT ARRAYS
//------------------------------------------------------------------------------
var zonePrice      = array.new_float()
var zoneTop        = array.new_float()
var zoneBottom     = array.new_float()
var zoneDir        = array.new_int()      //  1 = bullish support, -1 = bearish resistance
var zoneBirthBar   = array.new_int()
var zoneLastTouch  = array.new_int()
var zoneRevisits   = array.new_int()

var zoneStructSum  = array.new_float()    // structural event intensity accumulator
var zoneStructObs  = array.new_int()      // structural observations
var zoneWickSum    = array.new_float()    // relevant wick ratio accumulator
var zoneWickObs    = array.new_int()      // wick observations
var zoneAbsorbSum  = array.new_float()    // absorption / defended retest accumulator
var zoneBreakSum   = array.new_float()    // clean break accumulator
var zoneScore      = array.new_float()    // live composite score 0-100
var zoneProxScore  = array.new_float()    // live proximity score 0-100

var zoneBoxes      = array.new_box()
var zoneLabels     = array.new_label()

var recentHighPivots = array.new_float()
var recentLowPivots  = array.new_float()

//------------------------------------------------------------------------------
// HELPERS
//------------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_safe_div(float a, float b) =>
    b != 0.0 ? a / b : 0.0

f_zone_halfwidth(float atrv) =>
    // Wider zones at higher sensitivity so equal highs/lows and stop-hunt areas merge into stable bands.
    math.max(syminfo.mintick * (2.0 + zone_sensitivity * 2.0), atrv * (0.035 + zone_sensitivity * 0.012))

f_gradient(bool bull, float score, bool border) =>
    float t = f_clamp(score / 100.0, 0.0, 1.0)

    color cool = na
    color warm = na

    if color_theme == "Classic"
        cool := bull ? color.rgb(32, 166, 179) : color.rgb(111, 89, 224)
        warm := bull ? color.rgb(255, 193, 7) : color.rgb(255, 82, 82)
    else if color_theme == "Neon"
        cool := bull ? color.rgb(0, 255, 170) : color.rgb(180, 90, 255)
        warm := bull ? color.rgb(255, 235, 59) : color.rgb(255, 23, 68)
    else
        cool := bull ? color.rgb(115, 145, 155) : color.rgb(125, 125, 140)
        warm := bull ? color.rgb(235, 235, 235) : color.rgb(245, 210, 210)

    int r = int(math.round(color.r(cool) + (color.r(warm) - color.r(cool)) * t))
    int g = int(math.round(color.g(cool) + (color.g(warm) - color.g(cool)) * t))
    int b = int(math.round(color.b(cool) + (color.b(warm) - color.b(cool)) * t))

    int alpha = border ? int(math.round(40.0 - 30.0 * t)) : int(math.round(88.0 - 58.0 * t))
    color.rgb(r, g, b, f_clamp(alpha, 0, 100))

f_delete_zone_objects(int idx) =>
    box bx = array.get(zoneBoxes, idx)
    label lb = array.get(zoneLabels, idx)
    if not na(bx)
        box.delete(bx)
    if not na(lb)
        label.delete(lb)
    array.set(zoneBoxes, idx, na)
    array.set(zoneLabels, idx, na)

f_remove_zone(int idx) =>
    f_delete_zone_objects(idx)
    array.remove(zonePrice, idx)
    array.remove(zoneTop, idx)
    array.remove(zoneBottom, idx)
    array.remove(zoneDir, idx)
    array.remove(zoneBirthBar, idx)
    array.remove(zoneLastTouch, idx)
    array.remove(zoneRevisits, idx)
    array.remove(zoneStructSum, idx)
    array.remove(zoneStructObs, idx)
    array.remove(zoneWickSum, idx)
    array.remove(zoneWickObs, idx)
    array.remove(zoneAbsorbSum, idx)
    array.remove(zoneBreakSum, idx)
    array.remove(zoneScore, idx)
    array.remove(zoneProxScore, idx)
    array.remove(zoneBoxes, idx)
    array.remove(zoneLabels, idx)

f_prune_one() =>
    if array.size(zonePrice) > 0
        int worstIdx = 0
        float worstMetric = 1e10
        for i = 0 to array.size(zonePrice) - 1
            // Lower score and older age make a zone more disposable when memory cap is hit.
            float metric = array.get(zoneScore, i) - (bar_index - array.get(zoneBirthBar, i)) * 0.02
            if metric < worstMetric
                worstMetric := metric
                worstIdx := i
        f_remove_zone(worstIdx)

f_add_or_merge_zone(float price, int dir, int eventBar, float halfWidth, float structBoost, float wickBoost) =>
    int found = -1
    float mergeTol = math.max(halfWidth * 1.25, syminfo.mintick * zone_sensitivity * 2.0)

    if array.size(zonePrice) > 0
        for i = 0 to array.size(zonePrice) - 1
            if array.get(zoneDir, i) == dir and math.abs(array.get(zonePrice, i) - price) <= mergeTol
                found := i
                break

    if found != -1
        float oldPrice = array.get(zonePrice, found)
        float oldTop = array.get(zoneTop, found)
        float oldBot = array.get(zoneBottom, found)
        float oldStructSum = array.get(zoneStructSum, found)

        float weightOld = math.max(oldStructSum, 1.0)
        float weightNew = math.max(structBoost, 1.0)
        float mergedPrice = (oldPrice * weightOld + price * weightNew) / (weightOld + weightNew)
        float mergedHalf = math.max((oldTop - oldBot) * 0.5, halfWidth)

        array.set(zonePrice, found, mergedPrice)
        array.set(zoneTop, found, mergedPrice + mergedHalf)
        array.set(zoneBottom, found, mergedPrice - mergedHalf)
        array.set(zoneBirthBar, found, math.min(array.get(zoneBirthBar, found), eventBar))
        array.set(zoneStructSum, found, array.get(zoneStructSum, found) + structBoost)
        array.set(zoneStructObs, found, array.get(zoneStructObs, found) + 1)

        if wickBoost > 0
            array.set(zoneWickSum, found, array.get(zoneWickSum, found) + wickBoost)
            array.set(zoneWickObs, found, array.get(zoneWickObs, found) + 1)
    else
        if array.size(zonePrice) >= max_zones
            f_prune_one()

        array.push(zonePrice, price)
        array.push(zoneTop, price + halfWidth)
        array.push(zoneBottom, price - halfWidth)
        array.push(zoneDir, dir)
        array.push(zoneBirthBar, eventBar)
        array.push(zoneLastTouch, na)
        array.push(zoneRevisits, 0)

        array.push(zoneStructSum, structBoost)
        array.push(zoneStructObs, 1)
        array.push(zoneWickSum, math.max(wickBoost, 0.0))
        array.push(zoneWickObs, wickBoost > 0 ? 1 : 0)
        array.push(zoneAbsorbSum, 0.0)
        array.push(zoneBreakSum, 0.0)
        array.push(zoneScore, 0.0)
        array.push(zoneProxScore, 0.0)

        array.push(zoneBoxes, na)
        array.push(zoneLabels, na)

//------------------------------------------------------------------------------
// CORE SERIES
//------------------------------------------------------------------------------
float atrv = ta.atr(14)
float volSma = ta.sma(volume, 20)
float barRange = math.max(high - low, syminfo.mintick)
float bodyRatio = math.abs(close - open) / barRange
float upperWickRatio = (high - math.max(open, close)) / barRange
float lowerWickRatio = (math.min(open, close) - low) / barRange

int swing_len = int(math.round(math.max(2.0, zone_sensitivity + 1.0)))
int pivot_memory = 20
int sweep_window = int(math.max(5.0, math.round(lookback_period * 0.25)))

//------------------------------------------------------------------------------
// SESSION VWAP + ACCEPTANCE BANDS
//------------------------------------------------------------------------------
var float cumPV  = 0.0
var float cumV   = 0.0
var float cumPV2 = 0.0
var float sessVWAP = na
var float sessSD   = na

var int barsFarBelow = 0
var int barsBelow1   = 0
var int barsMid      = 0
var int barsAbove1   = 0
var int barsFarAbove = 0
var int sessionBars  = 0

var int bullReclaims = 0
var int bearRejects  = 0

bool inRth = not na(time(timeframe.period, rth_session))
bool prevInRth = bar_index > 0 ? inRth[1] : false
bool vwapActive = vwap_session_type == "RTH" ? inRth : true
bool newAnchor =
     vwap_session_type == "RTH"  ? (inRth and not prevInRth) :
     vwap_session_type == "Week" ? timeframe.change("W") :
     vwap_session_type == "Month"? timeframe.change("M") :
                                   timeframe.change("D")

if barstate.isconfirmed
    if newAnchor and vwapActive
        cumPV := hlc3 * volume
        cumV := volume
        cumPV2 := hlc3 * hlc3 * volume

        barsFarBelow := 0
        barsBelow1 := 0
        barsMid := 0
        barsAbove1 := 0
        barsFarAbove := 0
        sessionBars := 0
        bullReclaims := 0
        bearRejects := 0
    else if vwapActive
        cumPV += hlc3 * volume
        cumV += volume
        cumPV2 += hlc3 * hlc3 * volume

    if vwapActive and cumV > 0
        sessVWAP := cumPV / cumV
        float variance = math.max(cumPV2 / cumV - sessVWAP * sessVWAP, 0.0)
        sessSD := math.sqrt(variance)

        sessionBars += 1

        float zClose = sessSD > 0 ? (close - sessVWAP) / sessSD : 0.0

        if zClose <= -2.0
            barsFarBelow += 1
        else if zClose < -1.0
            barsBelow1 += 1
        else if zClose <= 1.0
            barsMid += 1
        else if zClose < 2.0
            barsAbove1 += 1
        else
            barsFarAbove += 1

        // VWAP reclaim: close recovers above VWAP after trading below it.
        bool bullReclaimEvent = not na(sessVWAP[1]) and close > sessVWAP and close[1] <= sessVWAP[1]
        // VWAP rejection: price trades to VWAP / above it but is rejected back below.
        bool bearRejectEvent = close < sessVWAP and high >= sessVWAP

        if bullReclaimEvent
            bullReclaims += 1
        if bearRejectEvent
            bearRejects += 1

//------------------------------------------------------------------------------
// ZONE DETECTION
//------------------------------------------------------------------------------
if barstate.isconfirmed
    // Confirmed swing high -> bearish liquidity zone.
    float ph = ta.pivothigh(high, swing_len, swing_len)
    if not na(ph)
        float atrAtPivot = nz(atrv[swing_len], atrv)
        float tol = math.max(syminfo.mintick * zone_sensitivity * 2.0, atrAtPivot * zone_sensitivity * 0.08)
        int eqCount = 0

        if array.size(recentHighPivots) > 0
            int startIdx = math.max(0, array.size(recentHighPivots) - pivot_memory)
            for i = startIdx to array.size(recentHighPivots) - 1
                if math.abs(array.get(recentHighPivots, i) - ph) <= tol
                    eqCount += 1

        float pivotRange = math.max(high[swing_len] - low[swing_len], syminfo.mintick)
        float pivotUpperWick = high[swing_len] - math.max(open[swing_len], close[swing_len])
        float pivotWickRatio = pivotUpperWick / pivotRange

        // Structural strength rises when a swing high also clusters with prior equal highs.
        float structBoost = eqCount > 0 ? math.min(95.0, 60.0 + eqCount * 12.0) : 52.0
        f_add_or_merge_zone(ph, -1, bar_index - swing_len, f_zone_halfwidth(atrAtPivot), structBoost, pivotWickRatio)

        array.push(recentHighPivots, ph)
        if array.size(recentHighPivots) > pivot_memory
            array.shift(recentHighPivots)

    // Confirmed swing low -> bullish liquidity zone.
    float pl = ta.pivotlow(low, swing_len, swing_len)
    if not na(pl)
        float atrAtPivot = nz(atrv[swing_len], atrv)
        float tol = math.max(syminfo.mintick * zone_sensitivity * 2.0, atrAtPivot * zone_sensitivity * 0.08)
        int eqCount = 0

        if array.size(recentLowPivots) > 0
            int startIdx = math.max(0, array.size(recentLowPivots) - pivot_memory)
            for i = startIdx to array.size(recentLowPivots) - 1
                if math.abs(array.get(recentLowPivots, i) - pl) <= tol
                    eqCount += 1

        float pivotRange = math.max(high[swing_len] - low[swing_len], syminfo.mintick)
        float pivotLowerWick = math.min(open[swing_len], close[swing_len]) - low[swing_len]
        float pivotWickRatio = pivotLowerWick / pivotRange

        // Structural strength rises when a swing low also clusters with prior equal lows.
        float structBoost = eqCount > 0 ? math.min(95.0, 60.0 + eqCount * 12.0) : 52.0
        f_add_or_merge_zone(pl, 1, bar_index - swing_len, f_zone_halfwidth(atrAtPivot), structBoost, pivotWickRatio)

        array.push(recentLowPivots, pl)
        if array.size(recentLowPivots) > pivot_memory
            array.shift(recentLowPivots)

    // Stop-hunt wick above prior highs -> bearish liquidity magnet.
    bool upperStopHunt = high > ta.highest(high[1], sweep_window) and close < high - barRange * 0.35 and upperWickRatio >= 0.45
    if upperStopHunt
        float structBoost = math.min(100.0, 75.0 + upperWickRatio * 25.0)
        f_add_or_merge_zone(high, -1, bar_index, f_zone_halfwidth(atrv) * 0.80, structBoost, upperWickRatio)

    // Stop-hunt wick below prior lows -> bullish liquidity magnet.
    bool lowerStopHunt = low < ta.lowest(low[1], sweep_window) and close > low + barRange * 0.35 and lowerWickRatio >= 0.45
    if lowerStopHunt
        float structBoost = math.min(100.0, 75.0 + lowerWickRatio * 25.0)
        f_add_or_merge_zone(low, 1, bar_index, f_zone_halfwidth(atrv) * 0.80, structBoost, lowerWickRatio)

//------------------------------------------------------------------------------
// TOUCH / RETEST / ABSORPTION UPDATE
//------------------------------------------------------------------------------
if barstate.isconfirmed and array.size(zonePrice) > 0
    for i = 0 to array.size(zonePrice) - 1
        float zTop = array.get(zoneTop, i)
        float zBot = array.get(zoneBottom, i)
        float zMid = array.get(zonePrice, i)
        int zDir = array.get(zoneDir, i)

        bool touched = high >= zBot and low <= zTop
        if touched
            int lastTouchBar = array.get(zoneLastTouch, i)

            // Distinct revisit count increments only when the zone is revisited after at least one full bar away.
            if na(lastTouchBar) or (bar_index - lastTouchBar > 1)
                array.set(zoneRevisits, i, array.get(zoneRevisits, i) + 1)

            array.set(zoneLastTouch, i, bar_index)

            // Relevant wick intensity is directional: lower wick at support, upper wick at resistance.
            float relevantWick = zDir == 1 ? lowerWickRatio : upperWickRatio
            array.set(zoneWickSum, i, array.get(zoneWickSum, i) + relevantWick)
            array.set(zoneWickObs, i, array.get(zoneWickObs, i) + 1)

            float width = math.max(zTop - zBot, syminfo.mintick)

            // Penetration measures how far price moved through the zone boundary during mitigation.
            float penetration = zDir == 1 ? math.max(0.0, zBot - low) / width : math.max(0.0, high - zTop) / width

            // Displacement measures how far close finished from the zone's center after the touch.
            float displacement = math.abs(close - zMid) / math.max(atrv, syminfo.mintick)
            float volRatio = volume / math.max(volSma, 1.0)

            bool defended = zDir == 1 ? close >= zMid : close <= zMid
            bool closeInside = close <= zTop and close >= zBot
            bool cleanBreak = zDir == 1 ? close < zBot : close > zTop

            // Absorption score rises when volume is high, penetration is small, and price stalls / closes back inside.
            float absorbMetric =
                 f_clamp(
                     (1.0 - f_clamp(penetration / 1.5, 0.0, 1.0)) *
                     (1.0 - f_clamp(displacement / 1.5, 0.0, 1.0)) *
                     f_clamp(volRatio / 2.5, 0.0, 1.0) +
                     relevantWick * 0.35 +
                     (closeInside ? 0.20 : 0.0) +
                     (defended ? 0.15 : 0.0),
                     0.0, 2.0
                 )

            // Break score rises when penetration is deep, body is decisive, and close exits beyond the zone.
            float breakMetric =
                 f_clamp(
                     f_clamp(penetration / 1.5, 0.0, 1.0) *
                     f_clamp(bodyRatio / 0.85, 0.0, 1.0) *
                     (cleanBreak ? 1.0 : 0.45) *
                     (1.0 + f_clamp(displacement - 0.5, 0.0, 1.0) * 0.35),
                     0.0, 2.0
                 )

            array.set(zoneAbsorbSum, i, array.get(zoneAbsorbSum, i) + absorbMetric)
            array.set(zoneBreakSum, i, array.get(zoneBreakSum, i) + breakMetric)

//------------------------------------------------------------------------------
// SCORE ENGINE
//------------------------------------------------------------------------------
if array.size(zonePrice) > 0
    int maxRev = 0
    for i = 0 to array.size(zonePrice) - 1
        maxRev := math.max(maxRev, array.get(zoneRevisits, i))

    for i = 0 to array.size(zonePrice) - 1
        float zPrice = array.get(zonePrice, i)
        int zDir = array.get(zoneDir, i)
        int birthBar = array.get(zoneBirthBar, i)
        int lastTouchBar = array.get(zoneLastTouch, i)
        int refBar = na(lastTouchBar) ? birthBar : lastTouchBar

        float structScore =
             f_clamp(
                 f_safe_div(array.get(zoneStructSum, i), math.max(array.get(zoneStructObs, i), 1)),
                 0.0, 100.0
             )

        // Revisit score is normalized to the strongest revisit frequency currently visible in memory.
        float revisitScore =
             maxRev > 0 ? f_clamp(100.0 * array.get(zoneRevisits, i) / maxRev, 0.0, 100.0) : 0.0

        // Wick rejection intensity is the mean directional wick ratio converted to a 0-100 score.
        float wickScore =
             array.get(zoneWickObs, i) > 0 ?
             f_clamp(100.0 * f_safe_div(array.get(zoneWickSum, i), array.get(zoneWickObs, i)), 0.0, 100.0) :
             0.0

        float absorb = array.get(zoneAbsorbSum, i)
        float broken = array.get(zoneBreakSum, i)

        // Mitigation score rewards defended retests and penalizes zones that break cleanly.
        float mitigationScore =
             absorb + broken > 0.0 ?
             f_clamp(100.0 * absorb / (absorb + broken), 0.0, 100.0) :
             50.0

        int idleBars = bar_index - refBar

        // Decay score applies exponential age decay so untouched zones lose gravity over time.
        float decayScore = f_clamp(100.0 * math.exp(-score_decay_rate * idleBars), 0.0, 100.0)

        float distAtr = math.abs(close - zPrice) / math.max(atrv, syminfo.mintick)

        // Proximity score favors nearby zones because the map prioritizes likely next attraction.
        float proximityScore = f_clamp(100.0 * (1.0 - math.min(distAtr / 4.0, 1.0)), 0.0, 100.0)
        array.set(zoneProxScore, i, proximityScore)

        float vwapScore = 50.0
        if not na(sessVWAP) and not na(sessSD) and sessionBars > 0
            float zBand = sessSD > 0 ? (zPrice - sessVWAP) / sessSD : 0.0

            float regionFrac =
                 zBand <= -2.0 ? f_safe_div(barsFarBelow, sessionBars) :
                 zBand <  -1.0 ? f_safe_div(barsBelow1,   sessionBars) :
                 zBand <=  1.0 ? f_safe_div(barsMid,      sessionBars) :
                 zBand <   2.0 ? f_safe_div(barsAbove1,   sessionBars) :
                                 f_safe_div(barsFarAbove, sessionBars)

            float bandAffinity =
                 math.abs(zBand) <= 1.0 ? 100.0 :
                 math.abs(zBand) <= 2.0 ? 70.0  :
                                          35.0

            float behaviorDen = math.max(float(bullReclaims + bearRejects), 1.0)

            // Support benefits from bullish VWAP reclaims; resistance benefits from bearish VWAP rejections.
            float behaviorScore =
                 zDir == 1 ?
                 50.0 + 50.0 * (bullReclaims - bearRejects) / behaviorDen :
                 50.0 + 50.0 * (bearRejects - bullReclaims) / behaviorDen

            // VWAP acceptance score combines time-at-price acceptance, band location, and reclaim/rejection behavior.
            vwapScore := f_clamp(regionFrac * 100.0 * 0.50 + bandAffinity * 0.30 + behaviorScore * 0.20, 0.0, 100.0)

        // Composite score: every component is normalized to 0-100 before weighting.
        float composite =
             structScore      * 0.22 +
             revisitScore     * 0.14 +
             wickScore        * 0.14 +
             vwapScore        * 0.18 +
             mitigationScore  * 0.18 +
             decayScore       * 0.08 +
             proximityScore   * 0.06

        array.set(zoneScore, i, f_clamp(composite, 0.0, 100.0))

//------------------------------------------------------------------------------
// OPTIONAL AGING CLEANUP
//------------------------------------------------------------------------------
if barstate.isconfirmed and array.size(zonePrice) > 0
    for i = array.size(zonePrice) - 1 to 0
        int birthBar = array.get(zoneBirthBar, i)
        int lastTouchBar = array.get(zoneLastTouch, i)
        int refBar = na(lastTouchBar) ? birthBar : lastTouchBar
        int staleBars = bar_index - refBar
        float scoreNow = array.get(zoneScore, i)

        // Ancient low-score zones are removed to keep the map responsive and memory bounded.
        if staleBars > lookback_period * 6 and scoreNow < 12.0
            f_remove_zone(i)

//------------------------------------------------------------------------------
// VISIBLE SELECTION
//------------------------------------------------------------------------------
int liveCount = array.size(zonePrice)
bool[] selected = array.new_bool(liveCount, false)
bool[] used     = array.new_bool(liveCount, false)

int visibleCount = math.min(max_visible_zones, liveCount)

if liveCount > 0 and visibleCount > 0
    for pick = 0 to visibleCount - 1
        int bestIdx = -1
        float bestPriority = -1e10

        for i = 0 to liveCount - 1
            if not array.get(used, i)
                float scoreNow = array.get(zoneScore, i)
                float proxNow = array.get(zoneProxScore, i)
                float distNow = math.abs(close - array.get(zonePrice, i)) / math.max(atrv, syminfo.mintick)

                // Selection prioritizes high composite score while still preferring nearby zones.
                float priority = scoreNow * 0.85 + proxNow * 0.15 - distNow * 1.25

                if priority > bestPriority
                    bestPriority := priority
                    bestIdx := i

        if bestIdx != -1
            array.set(selected, bestIdx, true)
            array.set(used, bestIdx, true)

//------------------------------------------------------------------------------
// DRAWING
//------------------------------------------------------------------------------
if liveCount > 0
    for i = 0 to liveCount - 1
        bool showZone = array.get(selected, i)

        if showZone
            float zTop = array.get(zoneTop, i)
            float zBot = array.get(zoneBottom, i)
            float zMid = array.get(zonePrice, i)
            int zDir = array.get(zoneDir, i)
            int zBirth = array.get(zoneBirthBar, i)
            float scoreNow = array.get(zoneScore, i)
            int revisitsNow = array.get(zoneRevisits, i)

            color fillCol = f_gradient(zDir == 1, scoreNow, false)
            color edgeCol = f_gradient(zDir == 1, scoreNow, true)

            box bx = array.get(zoneBoxes, i)
            if na(bx)
                bx := box.new(zBirth, zTop, bar_index + 1, zBot, xloc=xloc.bar_index, border_color=edgeCol, bgcolor=fillCol)
                array.set(zoneBoxes, i, bx)
            else
                box.set_lefttop(bx, zBirth, zTop)
                box.set_rightbottom(bx, bar_index + 1, zBot)
                box.set_bgcolor(bx, fillCol)
                box.set_border_color(bx, edgeCol)

            if show_labels
                string prefix = zDir == 1 ? "BULL" : "BEAR"
                string txt = prefix + " LG " + str.tostring(scoreNow, "#.0") + "\nR " + str.tostring(revisitsNow)
                float y = zDir == 1 ? zBot : zTop

                label lb = array.get(zoneLabels, i)
                if na(lb)
                    lb := label.new(bar_index + 1, y, txt, xloc=xloc.bar_index, style=zDir == 1 ? label.style_label_up : label.style_label_down, color=edgeCol, textcolor=color.white, size=size.tiny)
                    array.set(zoneLabels, i, lb)
                else
                    label.set_x(lb, bar_index + 1)
                    label.set_y(lb, y)
                    label.set_text(lb, txt)
                    label.set_color(lb, edgeCol)
                    label.set_textcolor(lb, color.white)
            else
                label lb = array.get(zoneLabels, i)
                if not na(lb)
                    label.delete(lb)
                    array.set(zoneLabels, i, na)
        else
            f_delete_zone_objects(i)

//------------------------------------------------------------------------------
// VWAP PLOTS
//------------------------------------------------------------------------------
plot(show_vwap_bands ? sessVWAP : na, "Session VWAP", color=color.new(color.white, 20), linewidth=2)
plot(show_vwap_bands and not na(sessSD) ? sessVWAP + sessSD : na, "+1σ", color=color.new(color.aqua, 55), linewidth=1)
plot(show_vwap_bands and not na(sessSD) ? sessVWAP - sessSD : na, "-1σ", color=color.new(color.aqua, 55), linewidth=1)
plot(show_vwap_bands and not na(sessSD) ? sessVWAP + sessSD * 2.0 : na, "+2σ", color=color.new(color.orange, 65), linewidth=1)
plot(show_vwap_bands and not na(sessSD) ? sessVWAP - sessSD * 2.0 : na, "-2σ", color=color.new(color.orange, 65), linewidth=1)
````
