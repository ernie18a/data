# Alpha Forge Liquidity Matrix v2.2

- url: https://www.tradingview.com/script/if5kzXaM-Alpha-Forge-Liquidity-Matrix-v2-2/
- type: indicator
- pine_id: PUB;0f1af1b307e749ccaccb74853293f15d
- version: 1.0

## Description

# Liquidity Matrix

Liquidity Matrix is a native TradingView overlay designed to map probable liquidity zones, identify sweep traps, and help traders understand where price may be hunting stops.

Instead of focusing only on traditional trend signals, this tool looks at market structure through the lens of liquidity.

Where are traders likely trapped?
Where are stops likely clustered?
Where did price sweep liquidity and reject?
Did the reclaim actually confirm, or did it fail?

Liquidity Matrix was built to answer those questions directly on the chart.

---

## What It Does

Liquidity Matrix tracks recent swing highs and swing lows, then clusters nearby levels into projected liquidity zones.

These zones represent areas where stop orders may be concentrated:

* Swing highs can create buy-side liquidity above price
* Swing lows can create sell-side liquidity below price
* Repeated reactions near the same area increase the weight of that zone
* Stronger zones are shown as heavier projected boxes

The result is a visual map of where liquidity may be sitting before price reaches it.

---

## Liquidity Zones

The indicator draws forward-projected heat boxes directly on the chart.

Upper zones represent probable buy-side liquidity.

Lower zones represent probable sell-side liquidity.

Zone strength is classified as:

* Minor
* Active
* Major

The stronger the zone, the more important that area may become when price approaches it.

These zones are not standard support and resistance lines. They are designed to highlight areas where traders may be trapped, where stops may be clustered, and where fake breakouts or sweep moves may occur.

---

## Sweep and Reclaim Logic

A key feature of Liquidity Matrix is its ability to identify liquidity sweeps.

A sweep occurs when price pushes beyond a liquidity zone, grabs that liquidity, and then rejects or reclaims.

The script separates these events into clearer signal types:

### Buy Signal

A buy signal can occur when sell-side liquidity is swept and price confirms a bullish reclaim.

This suggests price pushed below a lower liquidity zone, triggered stops, and then recovered back above the level.

### Sell Signal

A sell signal can occur when buy-side liquidity is swept and price confirms a bearish rejection.

This suggests price pushed above an upper liquidity zone, triggered stops, and then failed to hold the breakout.

### Exit Long

An exit long signal appears when price sweeps upper liquidity and rejects strongly enough to trigger a structural warning.

This is designed as a circuit-breaker style warning for long positions.

### Exit Short

An exit short signal appears when price sweeps lower liquidity and reclaims strongly enough to trigger a structural warning for short positions.

---

## Signal Strictness

Liquidity Matrix includes three signal strictness modes:

### Early

Signals can trigger faster using wick-based reclaim or rejection logic.

This mode is more responsive, but may produce more early signals in choppy markets.

### Balanced

Signals require a cleaner close-based reclaim or rejection.

This is the default mode and is designed to balance responsiveness with confirmation.

### Confirmed

Signals require follow-through confirmation after the sweep.

This mode is stricter and may reduce false signals, but signals can appear later.

---

## Trade Direction Control

The indicator includes trade direction settings so users can match the tool to their trading style.

Options include:

* Longs & Shorts
* Longs Only
* Shorts Only

In Longs Only mode, buy signals remain active while short-style sell signals are treated as warnings instead of short entries.

In Shorts Only mode, sell signals remain active while long-style buy signals are treated as warnings instead of long entries.

This makes the tool easier to use for stock traders, crypto traders, futures traders, and users who only trade one side of the market.

---

## Signal Label Styles

Liquidity Matrix includes flexible label wording.

Users can choose between:

* Liquidity Terms
* Plain Buy/Sell
* Both

Liquidity Terms display labels such as SSL Reclaim and BSL Reject.

Plain Buy/Sell mode displays simple BUY, SELL, EXIT LONG, and EXIT SHORT labels.

Both mode displays the trade meaning and the liquidity event together.

This allows advanced traders to keep the market-structure terminology, while newer users can choose simpler chart labels.

---

## Dashboard

The dashboard provides a quick read of the current liquidity environment.

It can show:

* Current analysis timeframe
* Nearest upper liquidity zone
* Nearest lower liquidity zone
* Circuit breaker state
* Latest event
* Current bias
* ATR sweep power
* Confirmation status

The bias reading helps identify whether the chart is currently leaning toward sweep risk above, sweep risk below, post-sweep bullish behavior, post-sweep bearish behavior, or a circuit-breaker state.

---

## Confirmation Filters

Liquidity Matrix includes several optional filters to improve signal quality.

### Volume Confirmation

Requires relative volume to meet a minimum threshold before sweep signals are confirmed.

### Trend Filter

Allows signals to be filtered by trend conditions.

Modes include:

* Off
* Signal Quality
* Strict Signals

### Session Killzones

Allows users to define preferred trading windows.

Signals can be filtered to specific sessions, and optional session shading can be displayed on the chart.

### ATR Sweep Strength

The dashboard can show how powerful a sweep is relative to ATR.

This helps separate small liquidity taps from stronger displacement-style sweeps.

---

## Alerts

The indicator includes simplified alert names for easier setup.

Available alert types include:

* Buy Signal
* Sell Signal
* Exit Long
* Exit Short
* Any Buy/Sell Signal
* Any Exit Signal
* Long Warning
* Short Warning

This makes it much easier to create TradingView alerts without needing to understand every internal liquidity term.

Webhook-ready JSON alert calls are also available for users who want structured alert messages for automation, bots, dashboards, or external systems.

---

## How to Use It

Liquidity Matrix is best used as a structure and risk tool, not as a blind signal generator.

Common use cases include:

* Avoiding breakout traps near major liquidity zones
* Spotting failed sweeps before price reverses
* Confirming potential entries after sell-side or buy-side liquidity is swept
* Exiting long positions after upper liquidity rejection
* Exiting short positions after lower liquidity reclaim
* Identifying areas where price may be drawn toward liquidity
* Filtering trade ideas with volume, trend, session, and ATR confirmation

A strong use case is combining Liquidity Matrix with a separate trend or momentum tool.

For example:

A buy signal after sell-side liquidity is swept may carry more weight when trend, volume, and momentum are also aligned.

A sell signal after buy-side liquidity is swept may be more meaningful when price rejects a major upper zone with strong ATR expansion.

---

## Important Notes

Liquidity Matrix does not know where actual stop orders are placed.

It estimates probable liquidity areas using swing structure, repeated reactions, clustering, volatility, and rejection behavior.

The indicator does not guarantee future price movement.

It is designed to help traders better understand where liquidity may be building, when price may be sweeping that liquidity, and when a move may be a trap instead of a true breakout.

As always, this tool should be used with proper risk management and as part of a complete trading plan.

---

## Summary

Liquidity Matrix is a visual liquidity-mapping system built for traders who want to look beyond basic support, resistance, and lagging indicators.

It identifies probable stop clusters, projects liquidity zones forward, detects sweeps and reclaims, provides buy/sell/exit signals, and gives traders a clearer view of when price may be hunting liquidity.

The goal is simple:

See the trap before reacting to it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha Forge

//@version=6
indicator("Alpha Forge Liquidity Matrix Pro v2.2", "AF Liquidity Matrix Pro v2.2", overlay = true, max_boxes_count = 120, max_labels_count = 120, max_lines_count = 50)

//──────────────────────────────────────────────────────────────────────────────
// ALPHA FORGE LIQUIDITY MATRIX PRO v2.2
// Native Pine liquidity-zone engine using swings, clustering, weighted heat boxes,
// cooldown-filtered sweep/reclaim detection, volume confirmation, ATR sweep strength,
// trend/session filters, A/A+/Extreme grading, post-sweep bias logic,
// proximity-filtered zones, optional MTF analysis, webhook-ready alert() JSON,
// circuit breaker dashboard state, mobile dashboard controls, and alerts.
//
// Updates in v2.2:
// - Usability pass: cleaner default boxes and simpler signal behavior.
// - Project Boxes Forward default reduced to 25 and Max Zones Per Side default reduced to 2.
// - Added Signal Strictness: Early, Balanced, or Confirmed. Balanced uses Close Reclaim by default.
// - Failed setup labels are now hidden by default to reduce chart clutter.
// - Keeps Trade Direction control: Longs & Shorts, Longs Only, or Shorts Only.
// - Keeps plain BUY / SELL / EXIT alert aliases for easier TradingView alert setup.
//──────────────────────────────────────────────────────────────────────────────

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
groupCore    = "Core Engine"
groupZones   = "Liquidity Zones"
groupSweep   = "Sweep / Structural Exit"
groupVisual  = "Visuals"
groupDash    = "Dashboard"
groupConfirm = "Confirmations / Filters"
groupAlert   = "Alerts"

tfInput       = input.timeframe("", "Indicator Timeframe (Empty = Chart)", group = groupCore)
swingLen      = input.int(5, "Swing Length", minval = 2, maxval = 25, group = groupCore)
maxSwings     = input.int(50, "Tracked Swings", minval = 10, maxval = 100, group = groupCore)
sensitivity   = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = groupCore)
useVolume     = input.bool(true, "Use Volume Weight", group = groupCore)
volLen        = input.int(30, "Volume Average Length", minval = 5, maxval = 200, group = groupCore)
atrLen        = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupCore)
mergeAtrMult     = input.float(0.35, "Zone Merge Distance ATR", minval = 0.05, maxval = 2.00, step = 0.05, group = groupZones)
zoneAtrHeight    = input.float(0.18, "Minimum Zone Height ATR", minval = 0.02, maxval = 1.00, step = 0.02, group = groupZones)
projection       = input.int(25, "Project Boxes Forward", minval = 10, maxval = 300, group = groupZones)
maxZonesSide     = input.int(2, "Max Zones Per Side", minval = 1, maxval = 15, group = groupZones)
zoneDisplay      = input.string("Active + Major", "Displayed Zone Strength", options = ["All", "Active + Major", "Major Only"], group = groupZones)
showDistantZones = input.bool(false, "Show Distant Zones", group = groupZones)
maxZoneAtrDist   = input.float(6.0, "Max Zone Distance ATR", minval = 1.0, maxval = 50.0, step = 0.5, group = groupZones)

useVolumeConfirm  = input.bool(true, "Volume Confirmation", group = groupConfirm)
volConfirmMin     = input.float(1.20, "Minimum Relative Volume", minval = 0.50, maxval = 5.00, step = 0.05, group = groupConfirm)
trendFilterMode   = input.string("Signal Quality", "Trend Filter", options = ["Off", "Signal Quality", "Strict Signals"], group = groupConfirm)
trendLen          = input.int(50, "Trend EMA Length", minval = 5, maxval = 300, group = groupConfirm)
useSessionKillzones = input.bool(false, "Use Session Killzones", group = groupConfirm)
sessionA          = input.session("0930-1130", "Killzone Session 1", group = groupConfirm)
sessionB          = input.session("1400-1600", "Killzone Session 2", group = groupConfirm)
showSessionBg     = input.bool(false, "Highlight Session Killzones", group = groupConfirm)
sessionBgTrans    = input.int(94, "Killzone Background Transparency", minval = 80, maxval = 100, group = groupConfirm)

wickAtrMin    = input.float(0.35, "Sweep Wick Minimum ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupSweep)
rejectClosePc = input.float(0.55, "Rejection Close Back Inside %", minval = 0.10, maxval = 1.00, step = 0.05, group = groupSweep)
signalStrictness = input.string("Balanced", "Signal Strictness", options = ["Early", "Balanced", "Confirmed"], group = groupSweep)
reclaimConfirmMode = signalStrictness == "Early" ? "Wick Reclaim" : signalStrictness == "Confirmed" ? "Close + Follow Through" : "Close Reclaim"
tradeDirection = input.string("Longs & Shorts", "Trade Direction", options = ["Longs & Shorts", "Longs Only", "Shorts Only"], group = groupSweep)
showOppositeWarnings = input.bool(true, "Show Opposite-Direction Warnings", group = groupSweep)
followThroughBars = input.int(1, "Follow-Through Window Bars", minval = 1, maxval = 5, group = groupSweep)
showFailedReclaims = input.bool(false, "Show Failed Reclaim / Reject", group = groupSweep)
sweepCooldown = input.int(8, "Sweep Label Cooldown Bars", minval = 0, maxval = 100, group = groupSweep)
minSweepWt    = input.float(2.0, "Minimum Sweep Zone Weight", minval = 1.0, maxval = 9.0, step = 0.5, group = groupSweep)
exitMode      = input.string("Balanced", "Structural Exit Mode", options = ["Fast", "Balanced", "Strict"], group = groupSweep)
exitMinWt     = input.float(5.0, "Structural Exit Minimum Weight", minval = 1.0, maxval = 9.0, step = 0.5, group = groupSweep)
showSweeps    = input.bool(true, "Show Sweep / Reclaim Labels", group = groupSweep)
showExit      = input.bool(true, "Show Structural Exit Labels", group = groupSweep)
postSweepBars = input.int(20, "Post-Sweep Bias Memory Bars", minval = 1, maxval = 100, group = groupSweep)

showBoxes       = input.bool(true, "Show Heat Boxes", group = groupVisual)
showLabels      = input.bool(true, "Show Zone Labels", group = groupVisual)
showNearest     = input.bool(false, "Show Nearest Liquidity Lines", group = groupVisual)
boxTransMinor   = input.int(88, "Minor Box Transparency", minval = 60, maxval = 98, group = groupVisual)
boxTransMajor   = input.int(72, "Major Box Transparency", minval = 40, maxval = 95, group = groupVisual)
labelSizeIn     = input.string("Tiny", "Signal Label Size", options = ["Tiny", "Small", "Normal"], group = groupVisual)
zoneLabelSizeIn = input.string("Tiny", "Zone Label Size", options = ["Tiny", "Small", "Normal"], group = groupVisual)
labelTextMode   = input.string("Compact", "Signal Label Text", options = ["Compact", "Classic"], group = groupVisual)
signalLabelStyle = input.string("Both", "Signal Label Style", options = ["Liquidity Terms", "Plain Buy/Sell", "Both"], group = groupVisual)
showSignalGrade = input.bool(true, "Show A / A+ / Extreme Grade", group = groupVisual)
labelOffsetAtr  = input.float(0.20, "Signal Label Offset ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupVisual)
showTrendEma    = input.bool(false, "Show Trend EMA", group = groupVisual)
colorCandles    = input.bool(false, "Color Candles by Matrix Bias", group = groupVisual)

showDash        = input.bool(true, "Show Dashboard", group = groupDash)
dashCompact     = input.bool(true, "Compact Dashboard", group = groupDash)
dashTextIn      = input.string("Tiny", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = groupDash)
dashPos         = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = groupDash)
dashShowCircuit = input.bool(true, "Show Circuit State Row", group = groupDash)
dashShowPower   = input.bool(true, "Show ATR Power Row", group = groupDash)
dashShowConfirm = input.bool(true, "Show Confirmation Row", group = groupDash)

alertMode     = input.string("Important Only", "Alert Mode", options = ["All", "Important Only", "Structural Exits Only"], group = groupAlert)
useJsonAlerts = input.bool(false, "Use Dynamic Webhook JSON alert() Calls", group = groupAlert)

//──────────────────────────────────────────────────────────────────────────────
// Alpha Forge Logo-Matched Colors
//──────────────────────────────────────────────────────────────────────────────
// Primary brand colors
bullCol     = color.rgb(41, 211, 255)     // Electric cyan
bullDeep    = color.rgb(0, 145, 255)      // Logo blue
bullSoft    = color.rgb(75, 225, 255)     // Soft cyan highlight
// Bear / upper-liquidity colors
bearCol     = color.rgb(185, 195, 205)    // Silver
bearDeep    = color.rgb(105, 115, 130)    // Graphite
bearSoft    = color.rgb(145, 155, 170)    // Soft steel

// Dashboard / warning colors
neutralCol  = color.rgb(80, 95, 115)      // Slate
warnCol     = color.rgb(0, 145, 255)      // Logo blue warning accent, no muddy gold
dangerCol   = color.rgb(255, 55, 95)      // Hot magenta-red trap/exit
blackSoft   = color.rgb(8, 12, 18)

// Candle tint colors, intentionally separated from dashboard state colors
candleBull    = color.rgb(41, 211, 255)
candleBear    = color.rgb(185, 195, 205)
candleTrap    = color.rgb(255, 55, 95)
candleNeutral = color.rgb(80, 95, 115)

labelSize     = labelSizeIn == "Tiny" ? size.tiny : labelSizeIn == "Small" ? size.small : size.normal
zoneLabelSize = zoneLabelSizeIn == "Tiny" ? size.tiny : zoneLabelSizeIn == "Small" ? size.small : size.normal
dashTextSize  = dashTextIn == "Tiny" ? size.tiny : dashTextIn == "Small" ? size.small : size.normal
//──────────────────────────────────────────────────────────────────────────────
// Helpers
//──────────────────────────────────────────────────────────────────────────────
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_zone_color(bool upper, float weight) =>
    int t = weight >= 5.0 ? boxTransMajor : weight >= 3.0 ? int(math.avg(boxTransMajor, boxTransMinor)) : boxTransMinor
    upper ? color.new(bearCol, t) : color.new(bullCol, t)

f_border_color(bool upper, float weight) =>
    int t = weight >= 5.0 ? 5 : weight >= 3.0 ? 30 : 55
    upper ? color.new(bearCol, t) : color.new(bullCol, t)

f_weight_name(float w) =>
    w >= 5.0 ? "MAJOR" : w >= 3.0 ? "ACTIVE" : "MINOR"

f_zone_in_range(float lvl, float atrVal) =>
    showDistantZones or atrVal == 0.0 or math.abs(lvl - close) <= atrVal * maxZoneAtrDist

f_sweep_grade(float w, float rejectStrength, float wickSize, float atrVal, float volRatio, bool trendOk, bool sessionOk) =>
    float atrStrength = atrVal == 0.0 ? 0.0 : wickSize / atrVal
    bool volOk = not useVolumeConfirm or volRatio >= volConfirmMin
    bool trendBoost = trendFilterMode == "Off" or trendOk
    bool sessionBoost = not useSessionKillzones or sessionOk
    bool gradeExtreme = w >= 7.0 and rejectStrength >= 0.78 and atrStrength >= wickAtrMin * 1.85 and volOk and trendBoost and sessionBoost
    bool gradePlus = w >= 5.0 and rejectStrength >= 0.70 and atrStrength >= wickAtrMin * 1.35 and volOk
    bool gradeA = w >= 3.0 and rejectStrength >= 0.55
    gradeExtreme ? "EXTREME" : gradePlus ? "A+" : gradeA ? "A" : "B"

f_grade_rank(string g) =>
    g == "EXTREME" ? 3 : g == "A+" ? 2 : g == "A" ? 1 : 0

f_dash_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Center" ? position.bottom_center :
     p == "Bottom Left" ? position.bottom_left : position.top_right
f_sens_mult() =>
    sensitivity == "Aggressive" ? 0.75 : sensitivity == "Conservative" ? 1.30 : 1.00

f_exit_mult() =>
    exitMode == "Fast" ? 0.85 : exitMode == "Strict" ? 1.25 : 1.00

//──────────────────────────────────────────────────────────────────────────────
// Multi-Timeframe Context Resolvers
//──────────────────────────────────────────────────────────────────────────────
srcOpen   = request.security(syminfo.tickerid, tfInput, open, barmerge.gaps_off, barmerge.lookahead_off)
srcHigh   = request.security(syminfo.tickerid, tfInput, high, barmerge.gaps_off, barmerge.lookahead_off)
srcLow    = request.security(syminfo.tickerid, tfInput, low, barmerge.gaps_off, barmerge.lookahead_off)
srcClose  = request.security(syminfo.tickerid, tfInput, close, barmerge.gaps_off, barmerge.lookahead_off)
srcVolume = request.security(syminfo.tickerid, tfInput, volume, barmerge.gaps_off, barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────────────────────
// Core Metrics
//──────────────────────────────────────────────────────────────────────────────
atr      = request.security(syminfo.tickerid, tfInput, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)
volAvg   = request.security(syminfo.tickerid, tfInput, ta.sma(volume, volLen), barmerge.gaps_off, barmerge.lookahead_off)
trendEma = request.security(syminfo.tickerid, tfInput, ta.ema(close, trendLen), barmerge.gaps_off, barmerge.lookahead_off)
volRel   = na(volAvg) or volAvg == 0.0 ? 1.0 : srcVolume / volAvg
bullTrend = srcClose >= trendEma
bearTrend = srcClose <= trendEma
inSessionA = not na(time(timeframe.period, sessionA))
inSessionB = not na(time(timeframe.period, sessionB))
inKillzone = inSessionA or inSessionB
sessionPass = not useSessionKillzones or inKillzone
volPass = not useVolumeConfirm or volRel >= volConfirmMin
sensM = f_sens_mult()
exitM = f_exit_mult()
allowLongs = tradeDirection == "Longs & Shorts" or tradeDirection == "Longs Only"
allowShorts = tradeDirection == "Longs & Shorts" or tradeDirection == "Shorts Only"
mergeD = atr * mergeAtrMult * sensM
zoneH = atr * zoneAtrHeight

bgcolor(showSessionBg and inKillzone ? color.new(warnCol, sessionBgTrans) : na, title = "Session Killzone Highlight")
plot(showTrendEma and trendFilterMode != "Off" ? trendEma : na, "Trend Filter EMA", color = color.new(neutralCol, 35), linewidth = 1)

//──────────────────────────────────────────────────────────────────────────────
// Swing Storage
//──────────────────────────────────────────────────────────────────────────────
var float[] upperLvls = array.new_float()
var float[] upperWts  = array.new_float()
var int[]   upperBars = array.new_int()

var float[] lowerLvls = array.new_float()
var float[] lowerWts  = array.new_float()
var int[]   lowerBars = array.new_int()

ph = request.security(syminfo.tickerid, tfInput, ta.pivothigh(high, swingLen, swingLen), barmerge.gaps_off, barmerge.lookahead_off)
pl = request.security(syminfo.tickerid, tfInput, ta.pivotlow(low, swingLen, swingLen), barmerge.gaps_off, barmerge.lookahead_off)

// MTF duplicate protection: HTF pivots can repeat across several chart bars.
// These guards only insert the pivot when a new pivot value first appears.
newPH = not na(ph) and na(ph[1])
newPL = not na(pl) and na(pl[1])

f_add_swing(float[] lvls, float[] wts, int[] bars, float lvl, int b, float baseW) =>
    bool merged = false
    int n = array.size(lvls)
    if n > 0
        for i = 0 to n - 1
            float old = array.get(lvls, i)
            float d = math.abs(old - lvl)
            if d <= mergeD
                float oldW = array.get(wts, i)
                float newW = oldW + baseW + math.max(0.0, 1.0 - d / math.max(mergeD, syminfo.mintick))
                float newLvl = (old * oldW + lvl * baseW) / math.max(oldW + baseW, 0.001)
                array.set(lvls, i, newLvl)
                array.set(wts, i, f_clamp(newW, 1.0, 9.0))
                array.set(bars, i, b)
                merged := true
                break
    if not merged
        array.unshift(lvls, lvl)
        array.unshift(wts, baseW)
        array.unshift(bars, b)

    // Memory protection: when the array is full, lower-weight zones are removed first.
    // If every stored zone is major, the oldest remaining entry is removed as a final fallback.
    while array.size(lvls) > maxSwings
        int idxToRemove = array.size(lvls) - 1
        for i = array.size(lvls) - 1 to 0
            if array.get(wts, i) < 5.0
                idxToRemove := i
                break
        array.remove(lvls, idxToRemove)
        array.remove(wts, idxToRemove)
        array.remove(bars, idxToRemove)

baseW = 1.0 + (useVolume ? f_clamp(volRel[swingLen] - 1.0, 0.0, 2.0) * 0.35 : 0.0)

if newPH
    f_add_swing(upperLvls, upperWts, upperBars, ph, bar_index - swingLen, baseW)

if newPL
    f_add_swing(lowerLvls, lowerWts, lowerBars, pl, bar_index - swingLen, baseW)

//──────────────────────────────────────────────────────────────────────────────
// Touch / Bounce Weighting
//──────────────────────────────────────────────────────────────────────────────
f_update_bounces(float[] lvls, float[] wts, bool upper) =>
    int n = array.size(lvls)
    if n > 0
        for i = 0 to n - 1
            float lvl = array.get(lvls, i)
            float w = array.get(wts, i)
            bool approached = upper ? srcHigh >= lvl - mergeD and srcClose < lvl : srcLow <= lvl + mergeD and srcClose > lvl
            bool rejected = upper ? srcHigh < lvl + mergeD * 0.60 and srcClose < lvl - mergeD * 0.15 : srcLow > lvl - mergeD * 0.60 and srcClose > lvl + mergeD * 0.15
            if approached and rejected
                float add = 0.08 + (useVolume ? f_clamp(volRel - 1.0, 0.0, 2.0) * 0.04 : 0.0)
                array.set(wts, i, f_clamp(w + add, 1.0, 9.0))
            else
                array.set(wts, i, f_clamp(w * 0.999, 1.0, 9.0))

f_update_bounces(upperLvls, upperWts, true)
f_update_bounces(lowerLvls, lowerWts, false)

//──────────────────────────────────────────────────────────────────────────────
// Nearest / Strongest Zone Calculations
//──────────────────────────────────────────────────────────────────────────────
f_nearest(float[] lvls, float[] wts, bool above) =>
    float bestLvl = na
    float bestWt = na
    float bestDist = na
    int n = array.size(lvls)
    if n > 0
        for i = 0 to n - 1
            float lvl = array.get(lvls, i)
            float wt = array.get(wts, i)
            bool valid = above ? lvl > srcClose : lvl < srcClose
            float dist = math.abs(lvl - srcClose)
            if valid and (na(bestDist) or dist < bestDist)
                bestDist := dist
                bestLvl := lvl
                bestWt := wt
    [bestLvl, bestWt, bestDist]

f_strongest(float[] lvls, float[] wts, bool above) =>
    float bestLvl = na
    float bestWt = na
    int n = array.size(lvls)
    if n > 0
        for i = 0 to n - 1
            float lvl = array.get(lvls, i)
            float wt = array.get(wts, i)
            bool valid = above ? lvl > srcClose : lvl < srcClose
            if valid and (na(bestWt) or wt > bestWt)
                bestLvl := lvl
                bestWt := wt
    [bestLvl, bestWt]

[nearUpper, nearUpperW, nearUpperD] = f_nearest(upperLvls, upperWts, true)
[nearLower, nearLowerW, nearLowerD] = f_nearest(lowerLvls, lowerWts, false)
[strongUpper, strongUpperW] = f_strongest(upperLvls, upperWts, true)
[strongLower, strongLowerW] = f_strongest(lowerLvls, lowerWts, false)

//──────────────────────────────────────────────────────────────────────────────
// Sweep / Rejection Logic
//──────────────────────────────────────────────────────────────────────────────
upperTop = na(nearUpper) ? na : nearUpper + zoneH
upperBot = na(nearUpper) ? na : nearUpper - zoneH
lowerTop = na(nearLower) ? na : nearLower + zoneH
lowerBot = na(nearLower) ? na : nearLower - zoneH

useFollowConfirm = reclaimConfirmMode == "Close + Follow Through"
useWickMode = reclaimConfirmMode == "Wick Reclaim"

// Wick mode allows the reclaim/reject candle to close back inside the zone body.
// Close mode requires a close back beyond the core liquidity level.
upperSweepRaw = not na(nearUpper) and srcHigh > upperTop and (useWickMode ? srcClose < upperTop : srcClose < nearUpper)
lowerSweepRaw = not na(nearLower) and srcLow < lowerBot and (useWickMode ? srcClose > lowerBot : srcClose > nearLower)

upperWickSize = srcHigh - math.max(srcOpen, srcClose)
lowerWickSize = math.min(srcOpen, srcClose) - srcLow

upperRejectStrength = not na(upperTop) and srcHigh > upperTop ? (srcHigh - srcClose) / math.max(srcHigh - upperBot, syminfo.mintick) : 0.0
lowerRejectStrength = not na(lowerBot) and srcLow < lowerBot ? (srcClose - srcLow) / math.max(lowerTop - srcLow, syminfo.mintick) : 0.0

upperTrendOk = trendFilterMode != "Strict Signals" or bearTrend
lowerTrendOk = trendFilterMode != "Strict Signals" or bullTrend
upperVolOk = volPass
lowerVolOk = volPass
upperSessionOk = sessionPass
lowerSessionOk = sessionPass
upperAtrStrength = atr == 0.0 ? 0.0 : upperWickSize / atr
lowerAtrStrength = atr == 0.0 ? 0.0 : lowerWickSize / atr

upperSweepConfirmed = upperSweepRaw and nz(nearUpperW, 0) >= minSweepWt and upperWickSize >= atr * wickAtrMin * exitM and upperRejectStrength >= rejectClosePc * exitM and upperVolOk and upperSessionOk and upperTrendOk
lowerSweepConfirmed = lowerSweepRaw and nz(nearLowerW, 0) >= minSweepWt and lowerWickSize >= atr * wickAtrMin * exitM and lowerRejectStrength >= rejectClosePc * exitM and lowerVolOk and lowerSessionOk and lowerTrendOk

var int lastUpperSweepBar = na
var int lastLowerSweepBar = na
canUpperSweep = na(lastUpperSweepBar) or bar_index - lastUpperSweepBar > sweepCooldown
canLowerSweep = na(lastLowerSweepBar) or bar_index - lastLowerSweepBar > sweepCooldown

upperBaseEvent = upperSweepConfirmed and canUpperSweep
lowerBaseEvent = lowerSweepConfirmed and canLowerSweep

// Grades calculated on the actual sweep candle.
upperBaseGrade = f_sweep_grade(nz(nearUpperW, 0), upperRejectStrength, upperWickSize, atr, volRel, bearTrend, inKillzone)
lowerBaseGrade = f_sweep_grade(nz(nearLowerW, 0), lowerRejectStrength, lowerWickSize, atr, volRel, bullTrend, inKillzone)

// Pending follow-through memory. In Close + Follow Through mode, the visible A/A+/Extreme labels are delayed until the next candle confirms.
var bool pendingUpperReject = false
var bool pendingLowerReclaim = false
var int pendingUpperBar = na
var int pendingLowerBar = na
var float pendingUpperLevel = na
var float pendingLowerLevel = na
var float pendingUpperHigh = na
var float pendingLowerLow = na
var float pendingUpperClose = na
var float pendingLowerClose = na
var float pendingUpperWt = na
var float pendingLowerWt = na
var float pendingUpperAtr = na
var float pendingLowerAtr = na
var string pendingUpperGrade = ""
var string pendingLowerGrade = ""

bool upperFollowConfirmed = false
bool lowerFollowConfirmed = false
bool upperFollowFailed = false
bool lowerFollowFailed = false

// First process existing pending states before creating new ones.
if useFollowConfirm and pendingUpperReject
    int upperAge = bar_index - pendingUpperBar
    bool upperStillValid = srcHigh <= pendingUpperHigh + syminfo.mintick and srcClose < pendingUpperLevel
    bool upperFollowThrough = upperStillValid and srcClose < pendingUpperClose
    bool upperInvalidated = srcHigh > pendingUpperHigh + syminfo.mintick or srcClose > pendingUpperLevel
    if upperAge >= 1 and upperAge <= followThroughBars and upperFollowThrough
        upperFollowConfirmed := true
        pendingUpperReject := false
    else if (upperAge >= 1 and upperInvalidated) or upperAge > followThroughBars
        upperFollowFailed := true
        pendingUpperReject := false

if useFollowConfirm and pendingLowerReclaim
    int lowerAge = bar_index - pendingLowerBar
    bool lowerStillValid = srcLow >= pendingLowerLow - syminfo.mintick and srcClose > pendingLowerLevel
    bool lowerFollowThrough = lowerStillValid and srcClose > pendingLowerClose
    bool lowerInvalidated = srcLow < pendingLowerLow - syminfo.mintick or srcClose < pendingLowerLevel
    if lowerAge >= 1 and lowerAge <= followThroughBars and lowerFollowThrough
        lowerFollowConfirmed := true
        pendingLowerReclaim := false
    else if (lowerAge >= 1 and lowerInvalidated) or lowerAge > followThroughBars
        lowerFollowFailed := true
        pendingLowerReclaim := false

// Create new pending states or immediate signals.
if upperBaseEvent
    lastUpperSweepBar := bar_index
    if useFollowConfirm
        pendingUpperReject := true
        pendingUpperBar := bar_index
        pendingUpperLevel := nearUpper
        pendingUpperHigh := srcHigh
        pendingUpperClose := srcClose
        pendingUpperWt := nz(nearUpperW, 0)
        pendingUpperAtr := upperAtrStrength
        pendingUpperGrade := upperBaseGrade

if lowerBaseEvent
    lastLowerSweepBar := bar_index
    if useFollowConfirm
        pendingLowerReclaim := true
        pendingLowerBar := bar_index
        pendingLowerLevel := nearLower
        pendingLowerLow := srcLow
        pendingLowerClose := srcClose
        pendingLowerWt := nz(nearLowerW, 0)
        pendingLowerAtr := lowerAtrStrength
        pendingLowerGrade := lowerBaseGrade

upperSweep = useFollowConfirm ? upperFollowConfirmed : upperBaseEvent
lowerSweep = useFollowConfirm ? lowerFollowConfirmed : lowerBaseEvent

upperSignalWt = useFollowConfirm ? nz(pendingUpperWt, 0) : nz(nearUpperW, 0)
lowerSignalWt = useFollowConfirm ? nz(pendingLowerWt, 0) : nz(nearLowerW, 0)
upperGrade = useFollowConfirm ? pendingUpperGrade : upperBaseGrade
lowerGrade = useFollowConfirm ? pendingLowerGrade : lowerBaseGrade
upperSignalAtrStrength = useFollowConfirm ? nz(pendingUpperAtr, upperAtrStrength) : upperAtrStrength
lowerSignalAtrStrength = useFollowConfirm ? nz(pendingLowerAtr, lowerAtrStrength) : lowerAtrStrength

majorUpperSweep = upperSweep and upperSignalWt >= 3.0
majorLowerSweep = lowerSweep and lowerSignalWt >= 3.0
upperGradeRank = f_grade_rank(upperGrade)
lowerGradeRank = f_grade_rank(lowerGrade)
upperGradePlus = upperSweep and upperGradeRank >= 2
lowerGradePlus = lowerSweep and lowerGradeRank >= 2
upperExtreme = upperSweep and upperGrade == "EXTREME"
lowerExtreme = lowerSweep and lowerGrade == "EXTREME"
// Structural exits remain fast by design. They act as circuit breakers and do not wait for follow-through.
structExitLongRaw  = showExit and upperBaseEvent and nz(nearUpperW, 0) >= exitMinWt and srcClose < srcOpen and srcClose < nearUpper - atr * 0.05
structExitShortRaw = showExit and lowerBaseEvent and nz(nearLowerW, 0) >= exitMinWt and srcClose > srcOpen and srcClose > nearLower + atr * 0.05

// Direction-aware trade interpretation.
// BUY = confirmed sell-side liquidity reclaim.
// SELL = confirmed buy-side liquidity rejection.
// In Longs Only mode, upper rejects become long warnings instead of short entries.
// In Shorts Only mode, lower reclaims become short warnings instead of long entries.
buySignal = allowLongs and lowerSweep
sellSignal = allowShorts and upperSweep
longWarningSignal = allowLongs and not allowShorts and upperSweep and showOppositeWarnings
shortWarningSignal = allowShorts and not allowLongs and lowerSweep and showOppositeWarnings
structExitLong = allowLongs and structExitLongRaw
structExitShort = allowShorts and structExitShortRaw
anyTradeSignal = buySignal or sellSignal
anyExitSignal = structExitLong or structExitShort

trapWarningLong = upperSweep and upperSignalWt >= 5.0
trapWarningShort = lowerSweep and lowerSignalWt >= 5.0

var string postSweepBias = ""
var int postSweepBar = na
if structExitLong or upperSweep
    postSweepBias := "Post-Sweep Bearish"
    postSweepBar := bar_index
if structExitShort or lowerSweep
    postSweepBias := "Post-Sweep Bullish"
    postSweepBar := bar_index
postSweepActive = not na(postSweepBar) and bar_index - postSweepBar <= postSweepBars

// Circuit breaker state memory.
var bool breakerLongTripped = false
var bool breakerShortTripped = false
var int breakerLongBar = na
var int breakerShortBar = na

if structExitLong
    breakerLongTripped := true
    breakerLongBar := bar_index
if breakerLongTripped and not na(breakerLongBar) and bar_index - breakerLongBar > postSweepBars
    breakerLongTripped := false

if structExitShort
    breakerShortTripped := true
    breakerShortBar := bar_index
if breakerShortTripped and not na(breakerShortBar) and bar_index - breakerShortBar > postSweepBars
    breakerShortTripped := false

//──────────────────────────────────────────────────────────────────────────────
// Box Rendering
//──────────────────────────────────────────────────────────────────────────────
var box[] upperBoxes = array.new_box()
var label[] upperLabs = array.new_label()
var box[] lowerBoxes = array.new_box()
var label[] lowerLabs = array.new_label()

f_clear_boxes(box[] boxes, label[] labs) =>
    int nb = array.size(boxes)
    if nb > 0
        for i = 0 to nb - 1
            box.delete(array.get(boxes, i))
    int nl = array.size(labs)
    if nl > 0
        for i = 0 to nl - 1
            label.delete(array.get(labs, i))
    array.clear(boxes)
    array.clear(labs)

f_draw_side(float[] lvls, float[] wts, int[] bars, box[] boxes, label[] labs, bool upper) =>
    f_clear_boxes(boxes, labs)
    if showBoxes
        int n = array.size(lvls)
        int drawn = 0
        if n > 0
            for i = 0 to n - 1
                if drawn >= maxZonesSide
                    break
                float lvl = array.get(lvls, i)
                float wt = array.get(wts, i)
                int b = array.get(bars, i)
                bool correctSide = upper ? lvl > srcClose : lvl < srcClose
                bool passWeight = zoneDisplay == "Major Only" ? wt >= 5.0 : zoneDisplay == "Active + Major" ? wt >= 3.0 : wt >= 1.0
                bool passDistance = f_zone_in_range(lvl, atr)
                if correctSide and passWeight and passDistance
                    float h = zoneH * (1.0 + wt * 0.12)
                    float top = lvl + h
                    float bot = lvl - h
                    box bx = box.new(left = math.max(b, bar_index - 500), top = top, right = bar_index + projection, bottom = bot, bgcolor = f_zone_color(upper, wt), border_color = f_border_color(upper, wt), border_width = wt >= 5.0 ? 2 : 1)
                    array.push(boxes, bx)
                    if showLabels
                        string txt = (upper ? "Buy-Side " : "Sell-Side ") + f_weight_name(wt)
                        label lb = label.new(bar_index + projection, lvl, txt, style = label.style_label_left, textcolor = upper ? bearCol : bullCol, color = color.new(blackSoft, 5), size = zoneLabelSize)
                        array.push(labs, lb)
                    drawn += 1

if barstate.islast
    f_draw_side(upperLvls, upperWts, upperBars, upperBoxes, upperLabs, true)
    f_draw_side(lowerLvls, lowerWts, lowerBars, lowerBoxes, lowerLabs, false)

//──────────────────────────────────────────────────────────────────────────────
// Nearest Liquidity Lines
//──────────────────────────────────────────────────────────────────────────────
plot(showNearest ? nearUpper : na, "Nearest Buy-Side Liquidity", color = color.new(bearCol, 15), linewidth = 1, style = plot.style_linebr)
plot(showNearest ? nearLower : na, "Nearest Sell-Side Liquidity", color = color.new(bullCol, 15), linewidth = 1, style = plot.style_linebr)

//──────────────────────────────────────────────────────────────────────────────
// Signal Labels
//──────────────────────────────────────────────────────────────────────────────
upperGradeShort = upperGrade == "EXTREME" ? "X" : upperGrade
lowerGradeShort = lowerGrade == "EXTREME" ? "X" : lowerGrade
upperGradeTxt = showSignalGrade ? " " + upperGradeShort : ""
lowerGradeTxt = showSignalGrade ? " " + lowerGradeShort : ""

liqUpperTxt = labelTextMode == "Compact" ? "BSL" + upperGradeTxt + "\nREJECT" : "BUY-SIDE SWEEP " + upperGradeTxt + "\nBEARISH REJECT"
liqLowerTxt = labelTextMode == "Compact" ? "SSL" + lowerGradeTxt + "\nRECLAIM" : "SELL-SIDE SWEEP " + lowerGradeTxt + "\nBULLISH RECLAIM"
plainUpperTxt = "SELL" + upperGradeTxt
plainLowerTxt = "BUY" + lowerGradeTxt
bothUpperTxt = "SELL" + upperGradeTxt + "\nBSL REJECT"
bothLowerTxt = "BUY" + lowerGradeTxt + "\nSSL RECLAIM"
warnLongTxt = labelTextMode == "Compact" ? "LONG\nWARN" : "LONG WARNING\nBSL REJECT"
warnShortTxt = labelTextMode == "Compact" ? "SHORT\nWARN" : "SHORT WARNING\nSSL RECLAIM"

upperSweepTxt = longWarningSignal ? warnLongTxt : signalLabelStyle == "Plain Buy/Sell" ? plainUpperTxt : signalLabelStyle == "Both" ? bothUpperTxt : liqUpperTxt
lowerSweepTxt = shortWarningSignal ? warnShortTxt : signalLabelStyle == "Plain Buy/Sell" ? plainLowerTxt : signalLabelStyle == "Both" ? bothLowerTxt : liqLowerTxt
upperFailedTxt = signalLabelStyle == "Liquidity Terms" ? (labelTextMode == "Compact" ? "BSL\nFAILED" : "BUY-SIDE REJECT\nFAILED") : "SELL\nFAILED"
lowerFailedTxt = signalLabelStyle == "Liquidity Terms" ? (labelTextMode == "Compact" ? "SSL\nFAILED" : "SELL-SIDE RECLAIM\nFAILED") : "BUY\nFAILED"
exitLongTxt   = labelTextMode == "Compact" ? "EXIT\nLONG" : "STRUCTURAL EXIT\nLONG"
exitShortTxt  = labelTextMode == "Compact" ? "EXIT\nSHORT" : "STRUCTURAL EXIT\nSHORT"

showUpperConfirmedLabel = showSweeps and upperSweep and not structExitLong and (sellSignal or longWarningSignal or tradeDirection == "Longs & Shorts")
showLowerConfirmedLabel = showSweeps and lowerSweep and not structExitShort and (buySignal or shortWarningSignal or tradeDirection == "Longs & Shorts")
showUpperFailedLabel = showFailedReclaims and upperFollowFailed and (allowShorts or showOppositeWarnings)
showLowerFailedLabel = showFailedReclaims and lowerFollowFailed and (allowLongs or showOppositeWarnings)

if showUpperConfirmedLabel
    label.new(bar_index, srcHigh + atr * labelOffsetAtr, upperSweepTxt, style = label.style_label_down, textcolor = color.white, color = color.new(longWarningSignal ? warnCol : dangerCol, 0), size = labelSize)

if showLowerConfirmedLabel
    label.new(bar_index, srcLow - atr * labelOffsetAtr, lowerSweepTxt, style = label.style_label_up, textcolor = color.white, color = color.new(shortWarningSignal ? warnCol : bullCol, 0), size = labelSize)

if showUpperFailedLabel
    label.new(bar_index, srcHigh + atr * labelOffsetAtr, upperFailedTxt, style = label.style_label_down, textcolor = color.white, color = color.new(neutralCol, 0), size = labelSize)

if showLowerFailedLabel
    label.new(bar_index, srcLow - atr * labelOffsetAtr, lowerFailedTxt, style = label.style_label_up, textcolor = color.white, color = color.new(neutralCol, 0), size = labelSize)

if structExitLong
    label.new(bar_index, srcHigh + atr * 0.35, exitLongTxt, style = label.style_label_down, textcolor = color.white, color = color.new(dangerCol, 0), size = labelSize)

if structExitShort
    label.new(bar_index, srcLow - atr * 0.35, exitShortTxt, style = label.style_label_up, textcolor = color.white, color = color.new(bullCol, 0), size = labelSize)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard Rendering
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(f_dash_pos(dashPos), 2, 9, border_width = 1, frame_color = color.new(neutralCol, 50), border_color = color.new(neutralCol, 60))

f_cell(int c, int r, string txt, color bg, color tc) =>
    table.cell(dash, c, r, txt, bgcolor = bg, text_color = tc, text_size = dashTextSize)

upperState = na(nearUpperW) ? "None" : f_weight_name(nearUpperW)
lowerState = na(nearLowerW) ? "None" : f_weight_name(nearLowerW)
upperAtrAway = na(nearUpperD) or atr == 0.0 ? na : nearUpperD / atr
lowerAtrAway = na(nearLowerD) or atr == 0.0 ? na : nearLowerD / atr
lastEvent = structExitLong ? "EXIT LONG" : structExitShort ? "EXIT SHORT" : buySignal ? "BUY " + lowerGrade : sellSignal ? "SELL " + upperGrade : longWarningSignal ? "LONG WARNING" : shortWarningSignal ? "SHORT WARNING" : upperFollowFailed ? "SELL Failed" : lowerFollowFailed ? "BUY Failed" : pendingUpperReject ? "BSL Pending" : pendingLowerReclaim ? "SSL Pending" : postSweepActive ? postSweepBias : "Watching"
biasTxt = breakerLongTripped ? "Circuit Long Breaker" : breakerShortTripped ? "Circuit Short Breaker" : structExitLong ? "Trap Above" : structExitShort ? "Trap Below" : postSweepActive ? postSweepBias : trapWarningLong ? "Bull Trap Risk" : trapWarningShort ? "Bear Trap Risk" : nz(nearUpperW, 0) > nz(nearLowerW, 0) ? "Sweep Risk Above" : nz(nearLowerW, 0) > nz(nearUpperW, 0) ? "Sweep Risk Below" : "Balanced"
biasCol = breakerLongTripped or breakerShortTripped or structExitLong or trapWarningLong or (postSweepActive and postSweepBias == "Post-Sweep Bearish") ? dangerCol : structExitShort or trapWarningShort or (postSweepActive and postSweepBias == "Post-Sweep Bullish") ? bullCol : warnCol
lastStrength = upperSweep ? upperSignalAtrStrength : lowerSweep ? lowerSignalAtrStrength : math.max(upperAtrStrength, lowerAtrStrength)
confirmTxt = (volPass ? "Vol OK" : "Low Vol") + " / " + (trendFilterMode == "Off" ? "Trend Off" : bullTrend ? "Bull Trend" : "Bear Trend") + " / " + (useSessionKillzones ? inKillzone ? "Killzone" : "No Session" : "Session Off")

matrixCandleCol = breakerLongTripped or breakerShortTripped or structExitLong or trapWarningLong or (postSweepActive and postSweepBias == "Post-Sweep Bearish") ? candleTrap :
     structExitShort or trapWarningShort or (postSweepActive and postSweepBias == "Post-Sweep Bullish") ? candleBull :
     bullTrend ? candleBull :
     bearTrend ? candleBear :
     candleNeutral

barcolor(colorCandles ? color.new(matrixCandleCol, 58) : na, title = "Matrix Bias Candle Tint")

if barstate.islast and showDash
    f_cell(0, 0, "AF LIQUIDITY", color.new(blackSoft, 0), bullCol)
    f_cell(1, 0, "MATRIX v2.2", color.new(blackSoft, 0), bearCol)
    f_cell(0, 1, "Timeframe", color.new(blackSoft, 10), color.white)
    f_cell(1, 1, tfInput == "" ? "Chart (" + timeframe.period + ")" : tfInput, color.new(blackSoft, 10), warnCol)
    f_cell(0, 2, "Upper", color.new(blackSoft, 10), bearCol)
    f_cell(1, 2, upperState + (na(upperAtrAway) ? "" : " / " + str.tostring(upperAtrAway, "#.##") + " ATR"), color.new(blackSoft, 10), bearCol)
    f_cell(0, 3, "Lower", color.new(blackSoft, 10), bullCol)
    f_cell(1, 3, lowerState + (na(lowerAtrAway) ? "" : " / " + str.tostring(lowerAtrAway, "#.##") + " ATR"), color.new(blackSoft, 10), bullCol)

    color breakerBg = breakerLongTripped or breakerShortTripped ? color.new(dangerCol, 20) : color.new(blackSoft, 10)
    color breakerTc = breakerLongTripped or breakerShortTripped ? color.white : color.new(neutralCol, 35)
    string breakerTxt = breakerLongTripped ? "BREAKER TRIPPED [LONG]" : breakerShortTripped ? "BREAKER TRIPPED [SHORT]" : "BREAKER STATE: NOMINAL"

    if dashShowCircuit
        f_cell(0, 4, "Circuit State", breakerBg, breakerTc)
        f_cell(1, 4, breakerTxt, breakerBg, breakerTc)
    else
        f_cell(0, 4, "", color.new(blackSoft, 100), color.white)
        f_cell(1, 4, "", color.new(blackSoft, 100), color.white)

    if dashCompact
        f_cell(0, 5, "Event", color.new(blackSoft, 10), color.white)
        f_cell(1, 5, lastEvent, color.new(blackSoft, 10), color.white)
        f_cell(0, 6, "Bias", color.new(blackSoft, 0), color.white)
        f_cell(1, 6, biasTxt, color.new(biasCol, 75), color.white)
        if dashShowPower
            f_cell(0, 7, "ATR Power", color.new(blackSoft, 10), color.white)
            f_cell(1, 7, str.tostring(lastStrength, "#.##") + "x", color.new(blackSoft, 10), color.white)
        else
            f_cell(0, 7, "", color.new(blackSoft, 100), color.white)
            f_cell(1, 7, "", color.new(blackSoft, 100), color.white)
        if dashShowConfirm
            f_cell(0, 8, "Confirm", color.new(blackSoft, 10), color.white)
            f_cell(1, 8, confirmTxt, color.new(blackSoft, 10), color.white)
        else
            f_cell(0, 8, "", color.new(blackSoft, 100), color.white)
            f_cell(1, 8, "", color.new(blackSoft, 100), color.white)
    else
        f_cell(0, 5, "Strong Upper", color.new(blackSoft, 10), bearCol)
        f_cell(1, 5, na(strongUpperW) ? "None" : f_weight_name(strongUpperW), color.new(blackSoft, 10), bearCol)
        f_cell(0, 6, "Strong Lower", color.new(blackSoft, 10), bullCol)
        f_cell(1, 6, na(strongLowerW) ? "None" : f_weight_name(strongLowerW), color.new(blackSoft, 10), bullCol)
        f_cell(0, 7, "Last Event", color.new(blackSoft, 10), color.white)
        f_cell(1, 7, lastEvent, color.new(blackSoft, 10), color.white)
        f_cell(0, 8, "Bias", color.new(blackSoft, 0), color.white)
        f_cell(1, 8, biasTxt, color.new(biasCol, 75), color.white)

if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 8)

//──────────────────────────────────────────────────────────────────────────────
// Dynamic Webhook JSON Generator
//──────────────────────────────────────────────────────────────────────────────
f_json_payload(string eventType, string details, float metric) =>
    "{\"strategy\":\"Alpha Forge Liquidity Matrix Pro\",\"ticker\":\"" + syminfo.ticker + "\",\"symbol\":\"" + syminfo.tickerid + "\",\"timeframe\":\"" + timeframe.period + "\",\"matrix_timeframe\":\"" + (tfInput == "" ? timeframe.period : tfInput) + "\",\"event\":\"" + eventType + "\",\"grade\":\"" + details + "\",\"atr_power\":" + str.tostring(metric, "#.##") + ",\"price\":" + str.tostring(srcClose, format.mintick) + ",\"bias\":\"" + biasTxt + "\"}"

//──────────────────────────────────────────────────────────────────────────────
// Alerts Messaging Setup
//──────────────────────────────────────────────────────────────────────────────
allAlerts = alertMode == "All"
importantAlerts = alertMode == "Important Only"
exitAlerts = alertMode == "Structural Exits Only"

alertBuySignal = (allAlerts or importantAlerts) and buySignal and majorLowerSweep
alertSellSignal = (allAlerts or importantAlerts) and sellSignal and majorUpperSweep
alertLongWarning = (allAlerts or importantAlerts) and longWarningSignal and majorUpperSweep
alertShortWarning = (allAlerts or importantAlerts) and shortWarningSignal and majorLowerSweep
alertUpperSweep = (allAlerts or importantAlerts) and majorUpperSweep
alertLowerSweep = (allAlerts or importantAlerts) and majorLowerSweep
alertUpperFailed = allAlerts and upperFollowFailed
alertLowerFailed = allAlerts and lowerFollowFailed
alertExitLong = (allAlerts or importantAlerts or exitAlerts) and structExitLong
alertExitShort = (allAlerts or importantAlerts or exitAlerts) and structExitShort
alertAnyTradeSignal = alertBuySignal or alertSellSignal
alertAnyExitSignal = alertExitLong or alertExitShort

// Plain-English TradingView alert aliases for easier setup.
alertcondition(alertBuySignal, "AF Matrix BUY Signal", "AF Liquidity Matrix: BUY signal on {{ticker}}. Sell-side liquidity reclaim confirmed.")
alertcondition(alertSellSignal, "AF Matrix SELL Signal", "AF Liquidity Matrix: SELL signal on {{ticker}}. Buy-side liquidity rejection confirmed.")
alertcondition(alertAnyTradeSignal, "AF Matrix Any BUY/SELL Signal", "AF Liquidity Matrix: BUY or SELL signal on {{ticker}}.")
alertcondition(alertExitLong, "AF Matrix EXIT LONG", "AF Liquidity Matrix: EXIT LONG on {{ticker}}. Upper liquidity trap/circuit breaker detected.")
alertcondition(alertExitShort, "AF Matrix EXIT SHORT", "AF Liquidity Matrix: EXIT SHORT on {{ticker}}. Lower liquidity trap/circuit breaker detected.")
alertcondition(alertAnyExitSignal, "AF Matrix Any EXIT Signal", "AF Liquidity Matrix: EXIT signal on {{ticker}}.")
alertcondition(alertLongWarning, "AF Matrix Long Warning", "AF Liquidity Matrix: Long warning on {{ticker}}. Buy-side liquidity rejection detected.")
alertcondition(alertShortWarning, "AF Matrix Short Warning", "AF Liquidity Matrix: Short warning on {{ticker}}. Sell-side liquidity reclaim detected.")

// Advanced liquidity-term alertconditions kept for experienced users.
alertcondition(alertUpperSweep, "AF Upper Liquidity Sweep", "AF Liquidity Matrix: Upper buy-side liquidity sweep rejection confirmed on {{ticker}}.")
alertcondition(alertLowerSweep, "AF Lower Liquidity Sweep", "AF Liquidity Matrix: Lower sell-side liquidity reclaim confirmed on {{ticker}}.")
alertcondition(alertUpperFailed, "AF Failed Upper Reject", "AF Liquidity Matrix: Upper buy-side reject failed on {{ticker}}.")
alertcondition(alertLowerFailed, "AF Failed Lower Reclaim", "AF Liquidity Matrix: Lower sell-side reclaim failed on {{ticker}}.")
alertcondition(alertUpperSweep or alertLowerSweep, "AF Any Liquidity Sweep", "AF Liquidity Matrix: Liquidity sweep detected on {{ticker}}.")
alertcondition(upperGradePlus and allowShorts, "AF Upper A+ SELL", "AF Liquidity Matrix: A+ or Extreme SELL / upper rejection on {{ticker}}.")
alertcondition(lowerGradePlus and allowLongs, "AF Lower A+ BUY", "AF Liquidity Matrix: A+ or Extreme BUY / lower reclaim on {{ticker}}.")
alertcondition(upperExtreme and allowShorts, "AF Upper Extreme SELL", "AF Liquidity Matrix: EXTREME SELL / upper rejection on {{ticker}}.")
alertcondition(lowerExtreme and allowLongs, "AF Lower Extreme BUY", "AF Liquidity Matrix: EXTREME BUY / lower reclaim on {{ticker}}.")

// Dynamic webhook JSON alerts.
// To use these, create a TradingView alert on "Any alert() function call".
if useJsonAlerts and alertBuySignal
    alert(f_json_payload("BUY", lowerGrade, lowerSignalAtrStrength), alert.freq_once_per_bar_close)

if useJsonAlerts and alertSellSignal
    alert(f_json_payload("SELL", upperGrade, upperSignalAtrStrength), alert.freq_once_per_bar_close)

if useJsonAlerts and alertLongWarning
    alert(f_json_payload("LONG WARNING", upperGrade, upperSignalAtrStrength), alert.freq_once_per_bar_close)

if useJsonAlerts and alertShortWarning
    alert(f_json_payload("SHORT WARNING", lowerGrade, lowerSignalAtrStrength), alert.freq_once_per_bar_close)

if useJsonAlerts and alertUpperFailed
    alert(f_json_payload("SELL Failed", pendingUpperGrade, nz(pendingUpperAtr, 0.0)), alert.freq_once_per_bar_close)

if useJsonAlerts and alertLowerFailed
    alert(f_json_payload("BUY Failed", pendingLowerGrade, nz(pendingLowerAtr, 0.0)), alert.freq_once_per_bar_close)

if useJsonAlerts and alertExitLong
    alert(f_json_payload("EXIT LONG", upperBaseGrade, upperAtrStrength), alert.freq_once_per_bar_close)

if useJsonAlerts and alertExitShort
    alert(f_json_payload("EXIT SHORT", lowerBaseGrade, lowerAtrStrength), alert.freq_once_per_bar_close)

// End v2.1
````
