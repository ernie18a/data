# edgeful - supply and demand zones

- url: https://www.tradingview.com/script/vOpLnN91-edgeful-supply-and-demand-zones/
- type: indicator
- pine_id: PUB;1469f9f567cb44bea158318dfeb7afbc
- version: 1.0

## Description

edgeful — supply and demand zones

what this indicator does

this indicator automatically draws supply zones (potential resistance) and demand zones (potential support) on your chart. it uses one strict rule: a zone is only created when the market produces a measurable impulse move away from a candle. the candle that immediately precedes that impulse is preserved as the zone — the area where price was last balanced before the imbalance occurred.

there are no swing pivots, no fractals, no volume profile, no order-flow approximations, and no higher-timeframe lookups. zones come purely from how big a candle is relative to recent volatility, which makes the logic transparent and the output reproducible.

how a zone is detected

1. volatility baseline. ATR (default length 14) measures the "normal" candle size for the current market regime.
2. impulse test. each closed candle's body is compared to ATR. the candle is treated as an impulse only if its body is at least impulse strength × ATR (default 1.5× ATR). wicks are ignored here — wicks reflect rejection, not commitment.
3. origin candle. when a bullish impulse closes, the last bearish or doji candle before it becomes a demand zone. when a bearish impulse closes, the last bullish or doji candle before it becomes a supply zone.
4. zone geometry. by default the zone is the body of the origin candle (open-to-close range). toggling "zone uses candle body" off widens it to the full candle range (high-to-low) for more conservative entries with deeper stops.
5. display. each zone is drawn as a colored box that extends to the right of the chart until it gets mitigated.

mitigation — when a zone is removed

- close (default) — zone is removed only when a candle closes beyond the far edge. filters out intrabar wicks and stop-runs that don't actually break structure.
- wick — zone is removed as soon as any wick pierces the far edge. stricter, fewer surviving zones, but reacts faster to liquidity sweeps.

mitigation runs 24/7 regardless of the session filter — a zone created during one session can still be invalidated outside it.

session filter

zones can be restricted to form only during a specific session:

- daily — no restriction
- new york — default 0930–1600
- london — default 0300–1100
- asian — default 1900–0400

all session times use the timezone you select (default America/New_York, but any IANA timezone or GMT±N offset works). useful if you only trade liquidity from one session and want to ignore zones built during low-participation hours. mitigation is not session-restricted — a zone built during NY can be broken during Asia.

day-aging filter

"limit zones to N days back" removes zones whose origin candle is older than N calendar days in the selected timezone. 0 disables it. 1 keeps only today's zones. 2 keeps today + yesterday. the cutoff handles daylight-saving correctly, so it never shifts by an hour around DST transitions.

display controls

- max demand / max supply zones — independent caps (1–50 each). when exceeded, the oldest zone on that side is removed first.
- zone colors — fully configurable, transparency included.
- show zone border — toggle a darker border for readability on busy charts.

alerts

- new demand zone — fires when a fresh demand zone is plotted.
- new supply zone — fires when a fresh supply zone is plotted.
- demand zone mitigated — fires when an existing demand zone is invalidated.
- supply zone mitigated — fires when an existing supply zone is invalidated.

how to use it

- bias / context. treat unmitigated demand zones as areas where buyers previously stepped in hard enough to drive an impulse, and supply zones the same way for sellers. these are levels of interest, not automatic trade triggers.
- entry workflow. wait for price to return into a zone, then look for a lower-timeframe confirmation (engulfing candle, break of internal structure, FVG fill, etc.) before entering. the zone defines the area; your trigger defines the moment.
- stop placement. with the default body-based zone, a stop just beyond the far edge respects the same mitigation rule the indicator uses internally — if the zone is mitigated, the thesis was wrong. switch to full-range zones if you prefer wider stops.
- tuning. on instruments that move in clean impulses (index futures during NY), the default 1.5× ATR setting produces a small number of high-quality zones per session. on choppier instruments or lower timeframes, raise the multiplier (e.g. 2.0–2.5×) to keep zone count manageable.
- session focus. if you only trade the NY open, set the session filter to "new york" so overnight zones don't clutter the chart — they'll still be respected on mitigation, just not created.

what makes this implementation original

most public supply/demand scripts mix several heuristics together: pivot-based swings, multi-candle base detection, volume confirmation, breaker-block re-classification. that makes them hard to reason about and tune.

this script does the opposite — it isolates one definition: the last opposite-color candle before an ATR-scaled impulse is the zone. every other behavior (geometry, mitigation, session, aging, max counts) is a transparent filter layered on top of that one rule.

specific choices that distinguish it:

- ATR-relative impulse measurement instead of a fixed point/percentage threshold, so the same settings adapt across instruments and volatility regimes.
- body-only impulse detection with independent body-or-wick zone geometry — usually these are conflated; here you control them separately.
- close vs. wick mitigation as a first-class user input, not hardcoded.
- calendar-aware day-back aging that uses local-timezone midnight rather than fixed-millisecond subtraction, so DST changes don't shift the cutoff.
- session-scoped creation with unconditional mitigation — matches how discretionary traders actually use these zones: only build them when liquidity is real, but always respect invalidation.
- non-repainting by design — every zone is anchored to a closed historical bar, and once drawn it never moves.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © edgeful
// ============================================================================
// Name:        edgeful - supply and demand zones
// Author:      edgeful
// Version:     1.3
// Created:     2026-05-06
// Updated:     2026-05-06
// Description: Plots simple supply and demand zones based on impulse moves.
//              The candle preceding a strong (ATR-multiple) move becomes
//              the zone. No volume, no swings, no pivots.
// Type:        indicator
// Instrument:  Any
// Timeframe:   Any (intraday recommended)
// Session:     All / NY / London / Asian (selectable)
// Tags:        supply, demand, zones, order block, impulse, session
//
// CHANGELOG:
// ----------
// v1.3  2026-05-06
//   [Added]   "Limit zones to N days back" input. When set above 0,
//             zones whose origin candle is older than N calendar days
//             (in the selected timezone) are removed from the chart.
//             Overrides the max-zone counts. 0 disables the filter.
// v1.2  2026-05-06
//   [Changed] Default mitigation method changed from "Wick" to "Close"
//             so zones survive intrabar wicks and only break on a
//             confirmed candle close through the far edge.
// v1.1  2026-05-06
//   [Added]   Session filter dropdown: Daily, New York, London, Asian.
//             Only impulses inside the selected session create new
//             zones. Mitigation still runs 24/7 so zones built earlier
//             can still get broken outside their formation window.
// v1.0  2026-05-06
//   [Added]   Initial release. Detects demand zones as the last bearish
//             candle before a strong bullish impulse, and supply zones
//             as the last bullish candle before a strong bearish
//             impulse. Strong = body >= ATR multiplier. Wick or close
//             mitigation. Configurable max zones per side.
// ============================================================================

//@version=6
indicator("edgeful - supply and demand zones", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpSession = "Session Filter"
sessionFilter = input.string("Daily", "Only create zones during", options = ["Daily", "New York", "London", "Asian"], group = grpSession, tooltip = "daily: zones can form at any time. otherwise only impulses inside the selected session create new zones. mitigation still runs 24/7 regardless of this filter.")
i_tz       = input.string("America/New_York", "Timezone", group = grpSession, tooltip = "popular options: America/New_York, America/Chicago, Europe/London, Europe/Berlin, Asia/Tokyo, Asia/Hong_Kong, Asia/Singapore, Australia/Sydney. you can also use offsets like GMT-4 or GMT+9.")
nySession  = input.session("0930-1600", "New York session", group = grpSession)
lnSession  = input.session("0300-1100", "London session",   group = grpSession)
asSession  = input.session("1900-0400", "Asian session",    group = grpSession)

grpDetect = "Detection"
atrLen      = input.int(14, "ATR length", minval = 1, group = grpDetect)
impulseMult = input.float(1.5, "Impulse strength (× ATR)", minval = 0.1, step = 0.1, group = grpDetect, tooltip = "a candle's body must be at least this many ATRs to count as an impulse. higher = fewer, more selective zones.")
useBody     = input.bool(true, "Zone uses candle body (off = full wick range)", group = grpDetect, tooltip = "on: zone is open/close of the origin candle. off: zone is high/low of the origin candle (wider).")
mitigation  = input.string("Close", "Mitigation method", options = ["Wick", "Close"], group = grpDetect, tooltip = "wick: zone is removed when any wick pierces the far edge. close: zone is removed only when a candle closes beyond the far edge.")

grpDisplay = "Display"
daysBack    = input.int(0, "Limit zones to N days back (0 = no limit)", minval = 0, maxval = 30, group = grpDisplay, tooltip = "if greater than 0, zones older than N days are removed from the chart. overrides max zone counts. e.g. 1 = only today's zones; 2 = today + yesterday. day boundaries use the timezone above.")
maxDemand   = input.int(5, "Max demand zones", minval = 1, maxval = 50, group = grpDisplay, tooltip = "maximum number of unmitigated demand zones to display at one time.")
maxSupply   = input.int(5, "Max supply zones", minval = 1, maxval = 50, group = grpDisplay, tooltip = "maximum number of unmitigated supply zones to display at one time.")
demandClr   = input.color(color.new(color.green, 80), "Demand zone color", group = grpDisplay)
supplyClr   = input.color(color.new(color.red, 80),   "Supply zone color", group = grpDisplay)
borderClr   = input.bool(true, "Show zone border", group = grpDisplay)

grpAlerts = "Alerts"
alertNew      = input.bool(true, "Alert on new zone formed", group = grpAlerts)
alertMitigate = input.bool(true, "Alert on zone mitigated",  group = grpAlerts)

// ─────────────────────────────────────────────────────────────────────────────
// CALCS
// ─────────────────────────────────────────────────────────────────────────────
atrVal     = ta.atr(atrLen)
bodySize   = math.abs(close - open)
isBull     = close > open
isBear     = close < open

// Session filter — only the selected session allows new zones.
inSess(s) => not na(time(timeframe.period, s, i_tz))
sessionAllows = switch sessionFilter
    "Daily"    => true
    "New York" => inSess(nySession)
    "London"   => inSess(lnSession)
    "Asian"    => inSess(asSession)
    => true

isImpulse  = bodySize >= atrVal * impulseMult and sessionAllows
bullImpulse = isImpulse and isBull
bearImpulse = isImpulse and isBear

// Track the last opposite-color (or doji) candle. This is the zone origin.
// For a demand zone we want the last bearish/doji candle before a bull impulse.
// For a supply zone we want the last bullish/doji candle before a bear impulse.
var float lastBearTop = na
var float lastBearBot = na
var int   lastBearBar = na
var int   lastBearTime = na
var float lastBullTop = na
var float lastBullBot = na
var int   lastBullBar = na
var int   lastBullTime = na

// Update trackers each bar (uses confirmed prior bar so we don't use the
// in-progress impulse candle as its own origin).
if not isBull[1]
    lastBearTop  := useBody ? math.max(open[1], close[1]) : high[1]
    lastBearBot  := useBody ? math.min(open[1], close[1]) : low[1]
    lastBearBar  := bar_index - 1
    lastBearTime := time[1]
if not isBear[1]
    lastBullTop  := useBody ? math.max(open[1], close[1]) : high[1]
    lastBullBot  := useBody ? math.min(open[1], close[1]) : low[1]
    lastBullBar  := bar_index - 1
    lastBullTime := time[1]

// ─────────────────────────────────────────────────────────────────────────────
// ZONE STATE
// ─────────────────────────────────────────────────────────────────────────────
var array<box>   demandBoxes = array.new<box>()
var array<float> demandTops  = array.new<float>()
var array<float> demandBots  = array.new<float>()
var array<int>   demandTimes = array.new<int>()

var array<box>   supplyBoxes = array.new<box>()
var array<float> supplyTops  = array.new<float>()
var array<float> supplyBots  = array.new<float>()
var array<int>   supplyTimes = array.new<int>()

bool newDemand = false
bool newSupply = false
bool mitDemand = false
bool mitSupply = false

// ─────────────────────────────────────────────────────────────────────────────
// CREATE ZONES
// ─────────────────────────────────────────────────────────────────────────────
borderClrDemand = borderClr ? color.new(color.green, 40) : color.new(color.green, 100)
borderClrSupply = borderClr ? color.new(color.red, 40)   : color.new(color.red, 100)

if barstate.isconfirmed and bullImpulse and not na(lastBearBar)
    b = box.new(left = lastBearBar, top = lastBearTop, right = bar_index,
         bottom = lastBearBot, bgcolor = demandClr, border_color = borderClrDemand,
         extend = extend.right)
    array.unshift(demandBoxes, b)
    array.unshift(demandTops, lastBearTop)
    array.unshift(demandBots, lastBearBot)
    array.unshift(demandTimes, lastBearTime)
    newDemand := true

    while array.size(demandBoxes) > maxDemand
        old = array.pop(demandBoxes)
        box.delete(old)
        array.pop(demandTops)
        array.pop(demandBots)
        array.pop(demandTimes)

if barstate.isconfirmed and bearImpulse and not na(lastBullBar)
    b = box.new(left = lastBullBar, top = lastBullTop, right = bar_index,
         bottom = lastBullBot, bgcolor = supplyClr, border_color = borderClrSupply,
         extend = extend.right)
    array.unshift(supplyBoxes, b)
    array.unshift(supplyTops, lastBullTop)
    array.unshift(supplyBots, lastBullBot)
    array.unshift(supplyTimes, lastBullTime)
    newSupply := true

    while array.size(supplyBoxes) > maxSupply
        old = array.pop(supplyBoxes)
        box.delete(old)
        array.pop(supplyTops)
        array.pop(supplyBots)
        array.pop(supplyTimes)

// ─────────────────────────────────────────────────────────────────────────────
// MITIGATION
// ─────────────────────────────────────────────────────────────────────────────
// Demand mitigated when price breaks below the bottom of the zone.
// Supply  mitigated when price breaks above the top of the zone.
demandBreak = mitigation == "Close" ? close : low
supplyBreak = mitigation == "Close" ? close : high

int dIdx = array.size(demandBoxes) - 1
while dIdx >= 0
    if demandBreak < array.get(demandBots, dIdx)
        box.delete(array.get(demandBoxes, dIdx))
        array.remove(demandBoxes, dIdx)
        array.remove(demandTops, dIdx)
        array.remove(demandBots, dIdx)
        array.remove(demandTimes, dIdx)
        mitDemand := true
    dIdx -= 1

int sIdx = array.size(supplyBoxes) - 1
while sIdx >= 0
    if supplyBreak > array.get(supplyTops, sIdx)
        box.delete(array.get(supplyBoxes, sIdx))
        array.remove(supplyBoxes, sIdx)
        array.remove(supplyTops, sIdx)
        array.remove(supplyBots, sIdx)
        array.remove(supplyTimes, sIdx)
        mitSupply := true
    sIdx -= 1

// ─────────────────────────────────────────────────────────────────────────────
// DAY-BACK AGING (drop zones older than the cutoff)
// ─────────────────────────────────────────────────────────────────────────────
// daysBack=1 → today only (cutoff = midnight of today in selected tz).
// daysBack=2 → today + yesterday.
// daysBack=0 → no day filter.
if daysBack > 0 and barstate.isconfirmed
    // DST-safe cutoff: shift by ~N-1 days, then snap to local-tz midnight
    // via calendar fields. Fixed-ms subtraction alone would mis-handle
    // spring-forward / fall-back transitions.
    cutoffApprox = time - (daysBack - 1) * 86400000
    dayCutoff = timestamp(i_tz, year(cutoffApprox, i_tz), month(cutoffApprox, i_tz), dayofmonth(cutoffApprox, i_tz), 0, 0)

    int adIdx = array.size(demandBoxes) - 1
    while adIdx >= 0
        if array.get(demandTimes, adIdx) < dayCutoff
            box.delete(array.get(demandBoxes, adIdx))
            array.remove(demandBoxes, adIdx)
            array.remove(demandTops, adIdx)
            array.remove(demandBots, adIdx)
            array.remove(demandTimes, adIdx)
        adIdx -= 1

    int asIdx = array.size(supplyBoxes) - 1
    while asIdx >= 0
        if array.get(supplyTimes, asIdx) < dayCutoff
            box.delete(array.get(supplyBoxes, asIdx))
            array.remove(supplyBoxes, asIdx)
            array.remove(supplyTops, asIdx)
            array.remove(supplyBots, asIdx)
            array.remove(supplyTimes, asIdx)
        asIdx -= 1

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(newDemand, "New demand zone", "new demand zone formed")
alertcondition(newSupply, "New supply zone", "new supply zone formed")
alertcondition(mitDemand, "Demand zone mitigated", "demand zone mitigated")
alertcondition(mitSupply, "Supply zone mitigated", "supply zone mitigated")
````
