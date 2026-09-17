<!-- tradingview-pine-id: PUB;6e5cabbf71a140a9b5602de9d549685c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Precision PushBack [MohaveTrader]

Source: https://www.tradingview.com/script/Nl0U9MU2-Precision-PushBack-MohaveTrader/

## Description

WHAT PUSHBACK IS

PushBack is a support-and-resistance overlay whose levels are built from a dual Williams %R engine, paired with a rail-based trend layer that runs on its own detection. Where the source oscillator treats a %R extreme as exhaustion — a spent move likely to reverse — PushBack reads that same condition as sustained directional pressure: the side in control pushing price to an extreme.

Two terms carry the whole design. Every completed pressure run is an EVENT. An event that clears qualification earns a LEVEL. Events that do not qualify are marked, but no level is built. When an event does qualify, PushBack takes the price extreme reached by that push and stamps it as a structural zone, then carries that zone through its own lifecycle of resistance, support, reclaim and testing. The panel counts both, so how selective the current settings are running on this instrument is readable at a glance.

It is intended for traders who want structure that emerges from qualifying pressure events rather than levels drawn on a fixed schedule, with a separate trend read layered on the same chart.

WHAT'S ORIGINAL

PushBack retains the dual fast and slow %R detection from upslidedown's open-source "%R Trend Exhaustion" (credited below and in the source code) and uses it only as the raw event source. Everything built on top is original: the reinterpretation of the extreme as directional pressure; event qualification by price range and, when enabled, sustained duration; the Event Mode presets that set how selective that qualification is; event-derived zone geometry, where a zone's depth is taken from the run's own candles; the support and resistance lifecycle with reclaim and testing states; role-flip management and retirement; ATR relevance hiding; optional same-state merging; the live run ribbon; the candle coloring modes; the trend layer with its fast and structure rails, defended-level state machine and rail-assisted transitions; and the information panel. The following image illustrates upslidedown's "%R Trend Exhaustion," the open-source indicator PushBack's detection comes from. Each filled box is one %R run — red where both fast and slow %R are overbought, blue where both are oversold — with a triangle where the run ended. PushBack reads these same runs as pressure rather than exhaustion, and keeps the price extreme each one reached as a structural level. For comparison the second image renders PushBack and %R Trend Exhaustion on the same chart.

https://www.tradingview.com/x/AeBQGvnz/

https://www.tradingview.com/x/yCaw1C7s/

WHAT MAKES IT DIFFERENT

The structure is emergent, not scheduled. No structural zone is created without a completed qualifying pressure run, so the absence of nearby zones is itself information rather than a missing calculation.

Structure and events are kept separate. The zones are the structural layer and carry the role-based color set. The pressure marks and run ribbon are a distinct event layer in a single neutral color, held off the price and clear of the zones, so a mark is never mistaken for a directional signal.

The run ribbon reads live. It sketches in real time across the pressure run and settles into the completion triangle, so a developing run is visible on price as it happens rather than only after it ends.

The trend line is the rail, not a separate object. The plotted line is the fast adaptive rail itself rather than an average derived from it, so the drawn line and the value the engine reads are the same series and cannot disagree.

%R PRESSURE

Pressure is read from a dual fast and slow Williams %R with independent smoothing. Both periods and the threshold are fixed internally at settled values rather than exposed as inputs. A shared threshold defines the overbought condition (bullish pressure) and the oversold condition (bearish pressure), and a run is the span in which that condition holds. The single event PushBack acts on is the run's completion — the bar the condition is lost.

Not every run qualifies. A completed run must clear a size test — its price range as a multiple of ATR — and, when duration filtering is on, a duration test as well: it must have persisted for the required number of bars. Both conditions must be met, and a larger or faster move does not waive the duration requirement. An Event Mode control — Responsive, Balanced, Strict, or Manual — sets how demanding that qualification is; in Manual, the Advanced values are read instead and the duration test can be turned off to gate on range alone. The duration test is not scaled by timeframe.

ZONES

When a qualifying run completes, its price extreme seeds a zone: a bullish pressure run's high becomes resistance, a bearish pressure run's low becomes support — the rail where the push stalled. Zone depth is set at birth from the run's own candles: the mean or the median of the run's bar ranges, median by default so a single outlier bar does not distort the level. Neither method applies a multiplier, so depth comes from the same bars that produced the level and there is no width setting to tune. Depth is frozen at birth. An optional merge step, off by default, can consolidate same-state zones that overlap or fall within a configurable price gap; with it off, distinct qualified levels stay separate.

A level holds until price closes through it. A close through flips it to a reclaim, which can firm back into support or resistance as price tests and holds. Red is resistance, green is support, cyan is reclaim, yellow is testing. A level keeps flipping between roles until it reaches its Max Role Flips limit — three by default — after which it is retired rather than reclaimed again; fresh pressure re-seeds it if it matters again.

Zones persist as structural objects and can change role as price interacts with them. A zone originally created as support or resistance may later become reclaim, enter testing, and resolve back into support or resistance. Its displayed color and label represent its current state, not necessarily the state in which it originated.

Previously established zones can remain stored after the pressure event that created them has passed. A zone outside the configured ATR relevance distance is hidden rather than deleted and can reappear when price returns. Because a zone can persist through multiple state changes, a currently visible zone may have originated much earlier, in a different role, and its original completion mark may no longer be visible on the chart. A fresh reclaim is held visible for a short grace period regardless of distance. A per-side cap limits the number of native support and resistance zones retained; reclaim zones are exempt from that cap.

PRESSURE MARKS AND RUN RIBBON

A triangle marks where each run completed — a down triangle where a bullish run ended, an up triangle where a bearish run ended. The run ribbon traces the run into that completion, one bar short of the triangle. Both use a single neutral color and float off the price in ATR-scaled offset space, so side is read from triangle direction and ribbon position rather than color. They show the duration and completion of a pressure run and are not buy or sell signals. By default every completed run is marked with a triangle. A qualified event also carries a ribbon into its triangle and seeds a zone; a filtered turn — one that did not clear qualification — is marked identically but with no ribbon and no zone, so the triangle shows that an event occurred while the ribbon and zone show whether it earned a level. Show All Event Marks turns the filtered triangles on or off.

TREND LAYER

A second engine runs alongside the zones, with its own dual %R detection independent of the one above. Its pressure runs do not create zones; they set rails. A completed bullish run leaves a lower rail at its low, a completed bearish run leaves an upper rail at its high, and one of those rails is held as the defended level that owns the current trend state. A close beyond the defended level flips the campaign, but only when an opposing rail exists and price has cleared it; otherwise the campaign continues.

Two adaptive followers of the body-weighted midpoint support that state machine. The fast rail shortens its own averaging length as a bar's body sits further from it, so a displaced bar moves it most of the way in one bar. The structure rail uses the same formula with a longer base and sits inside a hysteresis channel scaled to a long-period ATR, so its direction holds through ordinary pullbacks and only turns when price crosses the far edge of that channel.

Between them these supply two transitions the defended level alone cannot make. Once a bullish event has set a campaign ceiling, a failure of the fast rail can end the campaign early at that ceiling. In the other direction, both rails turning up together can start a bullish campaign with no completed %R event at all. These rail-assisted transitions print a diamond alongside the flip triangle so they are distinguishable from a defended-level flip. A campaign entered by the rails alone carries no defended level and exits late by construction.

The plotted trend line is the fast rail, drawn in the campaign color rather than the rail's own direction, so the line's shape comes from the follower and its color from the campaign. An optional two-tier fill runs from price to the fast rail and from the fast rail out to the structure rail, each tier colored by its own source, so a disagreement between the two renders as a two-tone band. Optional sequence marks compare each completed rail event's extreme to the previous event on the same side and print HH, LH, HL or LL; these are instrumentation only and drive nothing.

CANDLE COLORS

Candles can optionally be recolored, in one of two modes.

Pressure mode carries the bar's own direction as hue and whether a %R pressure run is active as brightness, so a bearish bar inside a buying-pressure run stays a bright bearish candle and a developing push is visible on the candles themselves.

Wave mode drops bar direction and paints the campaign instead, reusing the trend line's own two colors so the candles and the line always agree. Three independent sources are then readable at once on the same bars: campaign state sets the candle's hue, an active %R pressure run sets its brightness, and the inner fill follows the fast rail's own direction. Because the fill is the only one of the three tied to the fast rail, a pullback inside a campaign renders as candle color standing against fill color, while an actual campaign flip changes the candles themselves. That is the distinction Wave exists to make. Wave draws nothing before the first campaign is established, since no trend state exists yet to color.

Both modes dim between pressure runs and brighten during them. This uses plotcandle, so native candles should be hidden in chart settings to avoid overlap. Turned off, it draws nothing and leaves the native candles untouched.

INFO PANEL

An optional corner panel reports three rows. RSI is colored relative to the current campaign rather than against fixed bands, since RSI ranges differently in an advance than in a decline; the color meaning is constant — one color when buyers hold RSI control, another when sellers do, and a neutral shade in between — while the bands themselves shift with the campaign. EVENTS counts every completed pressure run for the session. LEVELS counts how many of those earned structure, with the percentage being that earned share. That percentage largely reflects how demanding the current Event Mode is rather than a property of the instrument, so it reads as feedback on whether the mode suits what is being traded: a very low share suggests qualification is tighter than the instrument supports, and a very high one suggests it is filtering little. The panel frame carries the RSI color so the state reads from across the screen. The session count can include extended hours or regular hours only.

ALERTS

Two alert conditions are provided, one for a qualified bullish pressure event and one for a qualified bearish pressure event. Alerts fire only when a completed run clears PushBack's active qualification requirements and earns structure; filtered event marks do not alert. The trend layer does not carry its own alerts.

HOW TO READ IT

Read the zones as structure and the marks as events: every triangle is an event, and only the ones carrying a ribbon and a zone earned a level. PushBack keeps four things distinct: the pressure event is where a zone came from; price interaction is what has since happened to it; the current color and label are what the level means now; and ATR relevance decides whether it is shown at all. A currently visible zone may have originated much earlier, in a different role, than the state now displayed. Treat a blank area as the absence of currently relevant qualifying pressure structure, not a missing calculation. Use the live ribbon to watch a qualifying run develop. The completion triangle identifies where a pressure run ended; when that completion also qualifies, its ribbon remains, a structural zone is established, and the corresponding alert can fire.

The two layers are independent and can disagree. The zones and the trend campaign are computed from separate detections and neither gates the other, so a level forming against the prevailing campaign is a normal reading rather than a conflict to resolve.

LIMITATIONS

A zone is not created until its run completes, so the level is confirmed after the move that produced it, not during. The %R condition can persist for a long time in a strong trend, so a run's duration is not itself a timing signal. PushBack is most expressive on instruments that produce qualifying pressure events and is quiet on orderly price.

The trend layer's rail events carry no qualification of their own, so a very short pressure run can set a rail. Because two of its transitions are driven by the rails rather than by a completed event, the campaign can change direction with no %R event involved, and a campaign entered that way holds no defended level. Zone role changes are driven by subsequent price interaction, so a zone's displayed state reflects the bar being evaluated and changes as price develops. On very low-priced instruments a run whose bar ranges are near the minimum tick can produce a zone thin enough to render as a line rather than a band.

PushBack does not predict future prices, does not manage risk, and does not guarantee any outcome.

ATTRIBUTION AND LICENSE

PushBack's dual-period Williams %R detection is derived from the open-source "%R Trend Exhaustion" indicator by upslidedown, who is credited here and in the source code. That indicator reads the %R extreme as exhaustion; PushBack uses the same detection only as a raw event source and reinterprets the extreme as sustained directional pressure. The pressure-event qualification, the persistent zone construction and event-derived geometry, the support and resistance interpretation, the reclaim and testing lifecycle, flip management and retirement, relevance behavior, merging, the run ribbon, the candle coloring modes, the trend layer and its rails and transitions, and the price-overlay presentation are original to PushBack. PushBack is published open-source under the Mozilla Public License 2.0.

DISCLAIMER

PushBack's zones, marks and trend state are analytical structures derived from the rules described above, not recommendations to buy or sell any instrument. You remain solely responsible for every trading decision.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
//
// © MohaveTrader
//
// Precision PushBack [MohaveTrader]
// Version 1.0 — August 2026
//
// Based in part on the dual fast/slow Williams %R detection from "%R Trend Exhaustion"
// by upslidedown (© upslidedown), used under MPL 2.0.
//
// OVERVIEW
// PushBack turns sustained dual Williams %R pressure into price structure. A completed
// pressure run can leave a support or resistance level behind, and what price does next
// decides whether that level holds, reclaims, or reverses role.
//
// PRESSURE
// Bullish and bearish pressure runs are tracked from first bar to turn. Event Mode sets how
// much duration and range a run must earn to qualify. A pressure mark shows where a run
// ended. It is not a directional call: a run ending means the pressure stopped, not that the
// opposite move has started.
//
// STRUCTURE
// A qualified bullish run leaves resistance, a qualified bearish run leaves support. Zone
// depth comes from the candle ranges of the run itself, mean or median, with no multiplier,
// and is frozen at birth. Levels stay stateful afterwards and move between Resistance,
// Support, Reclaim and Testing. Distant levels are hidden rather than deleted. Max Role Flips
// caps how long a repeatedly contested level stays alive before it is dropped.
//
// TREND
// A separate dual %R engine drives a fast adaptive rail and a slower structure rail. The
// plotted trend line is the fast rail itself, coloured by campaign state rather than by rail
// direction. The structure rail carries an ATR(200) hysteresis channel, so it holds through
// ordinary pullbacks and supplies the selectivity behind both assisted transitions.
//
// CANDLES
// Pressure mode carries the bar's own direction as hue, so a bearish bar inside a buying-
// pressure run stays a bright bearish candle. Wave mode drops bar direction and paints the
// campaign instead, reusing the trend line's own two colours. Both brighten while a %R run
// is active and dim between runs. The inner fill always follows fast-rail direction, so in
// Wave mode a disagreement between the fast rail and the campaign shows up as candle colour
// against fill colour.
//
// PANEL
// The optional panel shows RSI coloured against the current campaign, EVENTS as every
// completed pressure run today, and LEVELS as how many of them earned structure.
//
// READING IT
// A run ending on a fast chart while the same move is still running on a slower one is an
// early warning, not a reversal. The level a run leaves behind only matters through what
// price does with it afterwards.
//
// DISCLAIMER
// This script is provided for educational and informational purposes only and does not
// constitute financial, investment, or trading advice. Trading involves substantial risk.
// You are solely responsible for your decisions. Past performance is not indicative of
// future results.
//
//@version=6
indicator("Precision PushBack [MohaveTrader]", "PushBack", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)
max_bars_back(time, 5000)

const string grpMain = "00. Main"
sensMode         = input.string("Balanced", "Event Mode", options = ["Responsive", "Balanced", "Strict", "Manual"], group = grpMain, tooltip = "How strict event qualification is. Responsive keeps more events, Strict keeps fewer, Balanced sits between. Manual ignores the preset and reads the Advanced values instead. Default: Balanced.")
showZones        = input.bool(true, "Show Zones", group = grpMain, tooltip = "Draw the support / resistance / reclaim zones and their labels. Marks and candles are unaffected. Default: on.")
showMarks        = input.bool(true, "Show Pressure Marks", group = grpMain, tooltip = "Mark where each bullish or bearish pressure run ended. Default: on.")
candleMode       = input.string("Pressure", "Candle Colors", options = ["Off", "Pressure", "Wave"], group = grpMain, tooltip = "Pressure: hue is the candle's own direction. Wave: candles take the trend line's own two colours, so they follow the campaign rather than the bar. Both dim outside a %R pressure run. Uses plotcandle, so hide native candles in chart settings to avoid overlap. Off leaves native candles untouched. Default: Pressure.")

const string grpZ = "01. Zones"
maxPerSide    = input.int(4,     "Max Native Zones Per Side", minval = 1, group = grpZ, tooltip = "Caps born resistance and support zones. Reclaim zones are not culled. Default: 4.")
maxFlips      = input.int(3,     "Max Role Flips", minval = 0, group = grpZ, tooltip = "How many times a zone may reverse between support and resistance before it is dropped instead of kept as another reclaim. Lower clears fought-over levels sooner. 0 drops a zone the first time price closes back through it. Default: 3.")
relevanceMult = input.float(6.0, "Relevance Distance x ATR", step = 0.5, minval = 0.0, group = grpZ, tooltip = "Hide zones farther than this from price. They are kept, not deleted. 0 shows all. Default: 6.0.")
zoneExt       = input.int(20,    "Zone Extend bars", minval = 0, group = grpZ, tooltip = "How far a zone extends to the right of the last bar. Default: 20.")
showLabels    = input.bool(true, "Show Zone Labels", group = grpZ, tooltip = "Default: on.")

const string grpM = "02. Pressure Marks"
showRibbon        = input.bool(true, "Show Run Ribbon", group = grpM, tooltip = "Traces the pressure run from its first bar into the end triangle. Requires Show Pressure Marks. Default: on.")
showFilteredMarks = input.bool(true, "Show All Event Marks", group = grpM, tooltip = "Also mark completed pressure runs that did not earn a level. They print the same triangle but get no ribbon, no zone and no alert. Off marks only events that earned a level. Works in every Event Mode. Default: on.")

const string grpPR = "03. Trend Layer"
prShowLine      = input.bool(true,  "Show Trend Line", group = grpPR, tooltip = "The fast adaptive rail, drawn in the campaign colour. Default: on.")
prShowMark      = input.bool(true,  "Show Flip Marks", group = grpPR, tooltip = "Triangles at trend flips, diamonds at rail-assisted transitions. Default: on.")
prShowSeq       = input.bool(true,  "Show Event Sequence Marks", group = grpPR, tooltip = "Instrumentation only, no effect on state or line. Compares each completed pressure event's extreme to the previous event on the same side. HH / LH on bearish event highs, HL / LL on bullish event lows. Default: on.")
prShowStruct    = input.bool(true,  "Show Structure Rail", group = grpPR, tooltip = "Draws the structure rail. Display only. The rail direction drives trend transitions whether or not it is drawn. Default: on.")
prShowFill      = input.bool(true,  "Show Rail Fill", group = grpPR, tooltip = "Two-tier nested fill: price to the fast rail, then the fast rail out to the structure rail. Each tier fades to clear at the fast rail. Default: on.")
prInnerTransp   = input.int(65, "Inner Fill Transparency", minval = 0, maxval = 100, group = grpPR, tooltip = "Transparency at the fast rail edge of the inner fill, fading to clear at price. Higher is lighter. Default: 65.")
prOuterTransp   = input.int(50, "Outer Fill Transparency", minval = 0, maxval = 100, group = grpPR, tooltip = "Transparency at the structure rail edge of the outer fill, fading to clear at the fast rail. Higher is lighter. Default: 50.")

const string grpS = "04. Style"
resColor      = input.color(#FF1744, "Resistance", group = grpS)
supColor      = input.color(#39FF14, "Support", group = grpS)
reclaimColor  = input.color(#00E5FF, "Reclaim", group = grpS)
testColor     = input.color(#FFEB3B, "Testing", group = grpS)
borderTransp  = input.int(35, "Zone Border Transparency", minval = 0, maxval = 100, group = grpS)
fillTransp    = input.int(88, "Zone Fill Transparency", minval = 0, maxval = 100, group = grpS)
dullBullCol   = input.color(#2E7D32, "Native Bullish (dull)",     group = grpS, tooltip = "Pressure mode only. Bullish candle color outside a pressure run.")
dullBearCol   = input.color(#9A2D3A, "Native Bearish (dull)",     group = grpS, tooltip = "Pressure mode only. Bearish candle color outside a pressure run.")
brightBullCol = input.color(#39FF14, "Pressure Bullish (bright)", group = grpS, tooltip = "Pressure mode only. Bullish candle color while a pressure run is active.")
brightBearCol = input.color(#FF1744, "Pressure Bearish (bright)", group = grpS, tooltip = "Pressure mode only. Bearish candle color while a pressure run is active.")

const string grpPanel = "05. Panel"
showInfoPanel = input.bool(false, "Show Info Panel", group = grpPanel, tooltip = "Corner readout. RSI(14) is colored against the current campaign - teal when buyers have RSI control, magenta when sellers do, silver in between. EVENTS counts every completed pressure run today; LEVELS is how many earned structure, and the percentage is that earned share. Default: off.")
panelPos      = input.string("Top Right", "Panel Position", options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left", "Middle Right", "Middle Left"], group = grpPanel, tooltip = "Default: Bottom Right.")
panelText     = input.string("large", "Panel Text Size", options = ["tiny", "small", "normal", "large"], group = grpPanel, tooltip = "Default: normal.")
filtFullDay   = input.bool(true, "Count Full Day (incl pre/post)", group = grpPanel, tooltip = "On: the counter resets at each new trading day and counts premarket, regular and after-hours. Off: resets at the regular-session open and counts regular hours only. Default: on.")

const string grpAdv = "06. Advanced"
minEpisodeATR  = input.float(0.25, "Min Episode Size x ATR", step = 0.05, minval = 0.0, group = grpAdv, tooltip = "Manual mode only. A pressure run must span at least this much price, as a multiple of ATR, to qualify as an event. Combined with the duration test below. 0 disables the range test. Default: 0.25.")
useMinBars     = input.bool(true, "Require Minimum Duration", group = grpAdv, tooltip = "Manual mode only. When on, a run must ALSO last at least Min Episode Bars to qualify (range AND duration). Off gates on range alone. Default: on.")
minEpisodeBars = input.int(7, "Min Episode Bars", minval = 1, group = grpAdv, tooltip = "Manual mode only. Minimum bars the run held the %R extreme, counted from its first bar to the turn. Applies only when Require Minimum Duration is on. Default: 7.")
widthMethod    = input.string("Median Candle Range", "Zone Width Method", options = ["Mean Candle Range", "Median Candle Range"], group = grpAdv, tooltip = "How zone depth is set at birth: the mean or median of each bar's high-low across the run. No multiplier, so depth comes from the same bars that produced the level. Frozen at birth. Default: Median Candle Range.")
mergeOverlap   = input.bool(false, "Merge Overlapping Zones", group = grpAdv, tooltip = "Collapse zones of the same state that overlap. Off by default so distinct qualified levels stay separate. Default: off.")
mergeGapATR    = input.float(0.0, "Merge Gap x ATR", step = 0.05, minval = 0.0, group = grpAdv, tooltip = "Only used when Merge Overlapping Zones is on. Same-state zones within this distance merge, not only when they strictly overlap. 0 = overlap only. Default: 0.0.")

// ----------------------------------------------------------------------------
// SETTLED ENGINE VALUES. Validated and fixed; deliberately not user inputs.
// ----------------------------------------------------------------------------
const int    fastLen       = 21     // PushBack detector: fast %R length
const int    fastSmooth    = 7
const int    slowLen       = 112    // PushBack detector: slow %R length
const int    slowSmooth    = 3
const int    threshold     = 20     // distance from the %R extreme that counts as pressure
const int    atrLen        = 14
const int    zoneMaxBack   = 4999   // oldest bar a zone box may start from
const int    reclaimGrace  = 20     // bars a fresh reclaim stays visible regardless of distance
const int    prFastLen     = 21     // rail detector, independent of the PushBack detector above
const int    prFastSm      = 7
const int    prSlowLen     = 112
const int    prSlowSm      = 3
const float  prThr         = 20.0   // bull pressure above -20, bear pressure below -80
const int    prRailLen     = 21     // fast rail base length
const float  prRailStrRef  = 0.20   // fast rail deadzone reference
const int    prStructSpeed = 55     // structure rail base length
const float  prStructWidth = 2.0    // structure rail half-width, in ATR(200)
const float  markOffset    = 0.5    // mark / ribbon offset from the extreme, in ATR
const int    ribbonWidth   = 4
const int    ribbonGap     = 1      // clear bars between the ribbon end and the triangle
const int    ribbonTransp  = 40
const color  markColor     = #C0C0C0

_pr(int len) =>
    float hh = ta.highest(len)
    float ll = ta.lowest(len)
    100.0 * (close - hh) / (hh - ll)

float sR = ta.ema(_pr(fastLen), fastSmooth)
float lR = ta.ema(_pr(slowLen), slowSmooth)

bool overbought = sR >= -threshold and lR >= -threshold
bool oversold   = sR <= -100 + threshold and lR <= -100 + threshold
bool obStart = overbought and not overbought[1]
bool osStart = oversold and not oversold[1]
bool obEnd   = not overbought and overbought[1]
bool osEnd   = not oversold and oversold[1]

var float obHi = na
var float obLo = na
var int   obStartBar = na
var array<float> obRangeArr = array.new<float>()
if obStart
    obHi := high
    obLo := low
    obStartBar := bar_index
    array.clear(obRangeArr)
    array.push(obRangeArr, high - low)
else if overbought
    obHi := math.max(nz(obHi, high), high)
    obLo := math.min(nz(obLo, low), low)
    array.push(obRangeArr, high - low)

var float osHi = na
var float osLo = na
var int   osStartBar = na
var array<float> osRangeArr = array.new<float>()
if osStart
    osHi := high
    osLo := low
    osStartBar := bar_index
    array.clear(osRangeArr)
    array.push(osRangeArr, high - low)
else if oversold
    osHi := math.max(nz(osHi, high), high)
    osLo := math.min(nz(osLo, low), low)
    array.push(osRangeArr, high - low)

float atr = ta.atr(atrLen)
float rsiVal = ta.rsi(close, 14)

// A run qualifies as an event only by clearing BOTH range and, when duration filtering is on,
// duration. There is no alternate path: a large or fast move never waives the bar requirement.
// One flag per side (obQual/osQual) gates everything downstream - zone, mark, ribbon, alert.
// obBars/osBars count bars held at the %R extreme, from the first bar to the turn.
float obRange = math.abs(nz(obHi) - nz(obLo))
float osRange = math.abs(nz(osHi) - nz(osLo))
int   obBars  = bar_index - nz(obStartBar, bar_index)
int   osBars  = bar_index - nz(osStartBar, bar_index)
// Event Mode preset -> effective qualification thresholds. Duration is NOT timeframe-scaled.
// Manual mode ignores the preset and reads the Advanced inputs instead.
int   presetBars       = sensMode == "Responsive" ? 5    : sensMode == "Strict" ? 10  : 7
float presetRangeATR   = sensMode == "Responsive" ? 0.15 : sensMode == "Strict" ? 0.50 : 0.30
bool  manualMode     = sensMode == "Manual"
float effMinRangeATR = manualMode ? minEpisodeATR : presetRangeATR
bool  effUseMinBars  = manualMode ? useMinBars    : true
int   effMinBars     = manualMode ? minEpisodeBars : presetBars

bool  obRangeOK = effMinRangeATR <= 0.0 or obRange >= effMinRangeATR * atr
bool  osRangeOK = effMinRangeATR <= 0.0 or osRange >= effMinRangeATR * atr
bool  obDurOK   = not effUseMinBars or obBars >= effMinBars
bool  osDurOK   = not effUseMinBars or osBars >= effMinBars
bool  obQual  = obEnd and not na(atr) and obRangeOK and obDurOK
bool  osQual  = osEnd and not na(atr) and osRangeOK and osDurOK

// Daily counters for the info panel: every completed run is an event, and qualEvents is the
// subset that earned a level. Full-day mode resets per trading day and counts extended hours;
// otherwise the reset is at the RTH open.
var int qualEvents = 0
var int filtEvents = 0
bool countReset = filtFullDay ? ta.change(time("D")) != 0 : session.isfirstbar_regular
if countReset
    qualEvents := 0
    filtEvents := 0
if obEnd
    qualEvents := qualEvents + (obQual ? 1 : 0)
    filtEvents := filtEvents + (obQual ? 0 : 1)
if osEnd
    qualEvents := qualEvents + (osQual ? 1 : 0)
    filtEvents := filtEvents + (osQual ? 0 : 1)

type Zone
    float  top
    float  bottom
    float  anchor
    bool   isRes
    int    startBar
    string state
    bool   tested
    int    reclaimBar
    bool   reclaimUp
    int    flips
    int    absorbed
    bool   pressing

var array<Zone> zones = array.new<Zone>()
var array<box>   drawnBoxes  = array.new<box>()
var array<label> drawnLabels = array.new<label>()

f_zoneDepth(float evHi, float evLo, array<float> arr) =>
    int n = array.size(arr)
    float natural = evHi - evLo
    float d = switch widthMethod
        "Mean Candle Range" => n > 0 ? array.avg(arr) : natural
        => n > 0 ? array.median(arr) : natural
    d

f_addZone(bool isRes, float extreme, float depth) =>
    if not na(atr)
        float thick = math.max(depth, syminfo.mintick)
        float top    = isRes ? extreme : extreme + thick
        float bottom = isRes ? extreme - thick : extreme
        string native = isRes ? "RES" : "SUP"
        bool merged = false
        if mergeOverlap and zones.size() > 0
            float mergeGap = mergeGapATR * nz(atr, 0)
            for i = 0 to zones.size() - 1
                Zone z = zones.get(i)
                if z.state == native and top + mergeGap >= z.bottom and bottom - mergeGap <= z.top
                    z.top    := math.max(z.top, top)
                    z.bottom := math.min(z.bottom, bottom)
                    z.anchor := isRes ? math.max(z.anchor, extreme) : math.min(z.anchor, extreme)
                    merged := true
                    break
        if not merged
            zones.push(Zone.new(top, bottom, extreme, isRes, bar_index, native, false, na, false, 0, 0, false))
            int cnt = 0
            for i = 0 to zones.size() - 1
                if zones.get(i).state == native
                    cnt += 1
            if cnt > maxPerSide
                for i = 0 to zones.size() - 1
                    if zones.get(i).state == native
                        zones.remove(i)
                        break

// Enforce Max Native Zones Per Side on the settled state every bar, not only at birth.
// Reclaim promotions (RECLAIM back to RES/SUP) never pass through the birth cull, so
// without this a side can drift above the cap. Removes the oldest native first, same rule
// as the birth cull. Reclaims stay exempt.
f_capSide(string native) =>
    if zones.size() > 0
        int cnt = 0
        for i = 0 to zones.size() - 1
            if zones.get(i).state == native
                cnt += 1
        while cnt > maxPerSide and zones.size() > 0
            int idx = -1
            for i = 0 to zones.size() - 1
                if zones.get(i).state == native
                    idx := i
                    break
            if idx < 0
                break
            zones.remove(idx)
            cnt -= 1

if obQual
    f_addZone(true, obHi, f_zoneDepth(obHi, obLo, obRangeArr))
if osQual
    f_addZone(false, osLo, f_zoneDepth(osHi, osLo, osRangeArr))

if zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        bool interacting = high >= z.bottom and low <= z.top
        bool removed = false
        if z.state == "RES"
            if close > z.top
                if z.flips >= maxFlips
                    zones.remove(i)
                    removed := true
                else
                    z.state      := "RECLAIM"
                    z.reclaimUp  := true
                    z.tested     := false
                    z.reclaimBar := bar_index
        else if z.state == "SUP"
            if close < z.bottom
                if z.flips >= maxFlips
                    zones.remove(i)
                    removed := true
                else
                    z.state      := "RECLAIM"
                    z.reclaimUp  := false
                    z.tested     := false
                    z.reclaimBar := bar_index
        else if z.state == "RECLAIM"
            if z.reclaimUp
                if close < z.bottom
                    z.state  := "RES"
                    z.tested := false
                else if z.tested and not interacting and close > z.top
                    z.state    := "SUP"
                    z.flips    += 1
                    z.absorbed := 0
                else if interacting
                    z.tested := true
            else
                if close > z.top
                    z.state  := "SUP"
                    z.tested := false
                else if z.tested and not interacting and close < z.bottom
                    z.state    := "RES"
                    z.flips    += 1
                    z.absorbed := 0
                else if interacting
                    z.tested := true
        // Structural strength (historical). A qualified opposing run that ENDS at a zone
        // it did not break counts as one absorbed hold; pressing is that opposition acting
        // on the zone right now. Uses post-transition state, so a zone that broke this bar
        // is excluded. Skip the zone's own birth bar so a run never credits the level it made.
        if not removed and z.startBar != bar_index
            bool oppNow  = (z.state == "RES" and overbought) or (z.state == "SUP" and oversold)
            z.pressing := oppNow and interacting
            bool heldRun = (z.state == "RES" and obQual) or (z.state == "SUP" and osQual)
            if heldRun and interacting
                z.absorbed += 1

if mergeOverlap and zones.size() > 1
    float mergeGap = mergeGapATR * nz(atr, 0)
    int mi = 0
    while mi < zones.size()
        Zone zi = zones.get(mi)
        int mj = mi + 1
        while mj < zones.size()
            Zone zj = zones.get(mj)
            bool sameDir = zi.state != "RECLAIM" or zi.reclaimUp == zj.reclaimUp
            bool nearby = zi.state == zj.state and sameDir and zi.top + mergeGap >= zj.bottom and zi.bottom - mergeGap <= zj.top
            if nearby
                zi.top      := math.max(zi.top, zj.top)
                zi.bottom   := math.min(zi.bottom, zj.bottom)
                zi.anchor   := zi.isRes ? math.max(zi.anchor, zj.anchor) : math.min(zi.anchor, zj.anchor)
                zi.startBar := zj.startBar < zi.startBar ? zj.startBar : zi.startBar
                zi.tested   := zi.tested or zj.tested
                zi.flips    := math.max(zi.flips, zj.flips)
                zi.absorbed := math.max(zi.absorbed, zj.absorbed)
                zi.pressing := zi.pressing or zj.pressing
                int rb = na(zi.reclaimBar) ? zj.reclaimBar : na(zj.reclaimBar) ? zi.reclaimBar : (zi.reclaimBar < zj.reclaimBar ? zi.reclaimBar : zj.reclaimBar)
                zi.reclaimBar := rb
                zones.remove(mj)
            else
                mj += 1
        mi += 1

f_capSide("RES")
f_capSide("SUP")

if barstate.islast
    if drawnBoxes.size() > 0
        for b in drawnBoxes
            box.delete(b)
        drawnBoxes.clear()
    if drawnLabels.size() > 0
        for l in drawnLabels
            label.delete(l)
        drawnLabels.clear()
    float relD = relevanceMult <= 0.0 or na(atr) ? na : atr * relevanceMult
    if showZones and zones.size() > 0
        for i = 0 to zones.size() - 1
            Zone z = zones.get(i)
            bool fresh = z.state == "RECLAIM" and not na(z.reclaimBar) and bar_index - z.reclaimBar <= reclaimGrace
            bool near = fresh or na(relD) or math.abs(close - z.anchor) <= relD
            if near
                bool bornThisBar = z.state == "RECLAIM" and not na(z.reclaimBar) and bar_index == z.reclaimBar
                bool testing = not bornThisBar and high >= z.bottom and low <= z.top
                color c = testing ? testColor : z.state == "RES" ? resColor : z.state == "SUP" ? supColor : reclaimColor
                string role = testing ? "Testing" : z.state == "RES" ? "Resistance" : z.state == "SUP" ? "Support" : "Reclaim " + (z.reclaimUp ? "▲" : "▼")
                int left = math.max(z.startBar, bar_index - zoneMaxBack)
                box bb = box.new(left, z.top, bar_index + zoneExt, z.bottom, xloc = xloc.bar_index, border_color = color.new(c, borderTransp), border_width = 1, bgcolor = color.new(c, fillTransp))
                drawnBoxes.push(bb)
                if showLabels
                    float mid = math.avg(z.top, z.bottom)
                    label ll = label.new(bar_index + zoneExt + 1, mid, role + " " + str.tostring(mid, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = c, size = size.small)
                    drawnLabels.push(ll)

float markOff = markOffset * nz(atr, 0)
float obMarkY = obQual ? obHi + markOff : na
float osMarkY = osQual ? osLo - markOff : na
float obFiltY = (showMarks and showFilteredMarks and obEnd and not obQual) ? obHi + markOff : na
float osFiltY = (showMarks and showFilteredMarks and osEnd and not osQual) ? osLo - markOff : na

var line obRibbon = na
var line osRibbon = na
string ribbonStyleN = line.style_solid

if showMarks and showRibbon
    if obStart
        obRibbon := line.new(obStartBar, obHi + markOff, bar_index, obHi + markOff, xloc = xloc.bar_index, color = color.new(markColor, ribbonTransp), width = ribbonWidth, style = ribbonStyleN)
    else if overbought and not na(obRibbon)
        line.set_xy1(obRibbon, obStartBar, obHi + markOff)
        line.set_xy2(obRibbon, bar_index, obHi + markOff)
    if obEnd and not na(obRibbon)
        if obQual
            int rEnd = math.max(obStartBar, bar_index - ribbonGap)
            line.set_xy1(obRibbon, obStartBar, obHi + markOff)
            line.set_xy2(obRibbon, rEnd, obHi + markOff)
        else
            line.delete(obRibbon)
        obRibbon := na

    if osStart
        osRibbon := line.new(osStartBar, osLo - markOff, bar_index, osLo - markOff, xloc = xloc.bar_index, color = color.new(markColor, ribbonTransp), width = ribbonWidth, style = ribbonStyleN)
    else if oversold and not na(osRibbon)
        line.set_xy1(osRibbon, osStartBar, osLo - markOff)
        line.set_xy2(osRibbon, bar_index, osLo - markOff)
    if osEnd and not na(osRibbon)
        if osQual
            int rEnd = math.max(osStartBar, bar_index - ribbonGap)
            line.set_xy1(osRibbon, osStartBar, osLo - markOff)
            line.set_xy2(osRibbon, rEnd, osLo - markOff)
        else
            line.delete(osRibbon)
        osRibbon := na

// A mark flags where a pressure run ended, not a buy or sell. Down = bullish run ended,
// up = bearish run ended. The "no level" pair are events that did not earn structure.
plotshape(showMarks ? obMarkY : na, "Bullish run end", style = shape.triangledown, location = location.absolute, color = markColor, size = size.tiny)
plotshape(showMarks ? osMarkY : na, "Bearish run end", style = shape.triangleup,   location = location.absolute, color = markColor, size = size.tiny)
plotshape(obFiltY, "Bullish event end, no level", style = shape.triangledown, location = location.absolute, color = markColor, size = size.tiny)
plotshape(osFiltY, "Bearish event end, no level", style = shape.triangleup,   location = location.absolute, color = markColor, size = size.tiny)


alertcondition(obQual, "Bullish Pressure Event", "PushBack bullish pressure event ended")
alertcondition(osQual, "Bearish Pressure Event", "PushBack bearish pressure event ended")

// ============================================================================
// TREND LAYER. Its own dual %R, independent of the PushBack detector above: pressure runs
// set rails and a defended rail owns trend state, with rail-driven transitions layered on
// top. The plotted line is the fast rail, coloured by campaign state.
// ============================================================================
f_prPctr(len, sm) =>
    hh  = ta.highest(high, len)
    ll  = ta.lowest(low, len)
    den = hh - ll
    raw = den == 0 ? -50.0 : 100 * (close - hh) / den
    ta.ema(raw, sm)

float prFastR = f_prPctr(prFastLen, prFastSm)
float prSlowR = f_prPctr(prSlowLen, prSlowSm)

float prUpBand = -prThr
float prDnBand = -100 + prThr

bool prBullPress = prFastR > prUpBand and prSlowR > prUpBand
bool prBearPress = prFastR < prDnBand and prSlowR < prDnBand

var bool  prInBull     = false
var bool  prInBear     = false
var float prRunLo      = na
var float prRunHi      = na
var float prBullRunHi  = na
var float prBearRunLo  = na

bool prNewBullRail = false
bool prNewBearRail = false

if prBullPress
    if not prInBull
        prInBull    := true
        prRunLo     := low
        prBullRunHi := high
    else
        prRunLo     := math.min(prRunLo, low)
        prBullRunHi := math.max(prBullRunHi, high)
else if prInBull
    prInBull := false
    prNewBullRail := true

if prBearPress
    if not prInBear
        prInBear    := true
        prRunHi     := high
        prBearRunLo := low
    else
        prRunHi     := math.max(prRunHi, high)
        prBearRunLo := math.min(prBearRunLo, low)
else if prInBear
    prInBear := false
    prNewBearRail := true

var float prLowerRail = na
var float prUpperRail = na
var float prRefBullLo = na
var float prRefBearHi = na

bool prSeqHL = false
bool prSeqLL = false
bool prSeqHH = false
bool prSeqLH = false

if prNewBullRail
    if na(prRefBullLo)
        prRefBullLo := prRunLo
    else if prRunLo < prRefBullLo
        prSeqLL := true
        prRefBullLo := prRunLo
    else
        prSeqHL := true
if prNewBearRail
    if na(prRefBearHi)
        prRefBearHi := prRunHi
    else if prRunHi > prRefBearHi
        prSeqHH := true
        prRefBearHi := prRunHi
    else
        prSeqLH := true

if prNewBullRail
    prLowerRail := prRunLo
if prNewBearRail
    prUpperRail := prRunHi

// ----------------------------------------------------------------------------
// STRUCTURE RAIL. LIVE STATE AUTHORITY - prStructUp gates both event-independent
// transitions below, so this is not display code. A slow adaptive follower of the
// body-weighted midpoint inside a hysteresis channel of +/- ATR(200) x prStructWidth.
// State flips only when the body midpoint crosses the FAR edge, which is what makes
// it ignore ordinary pullbacks. ATR(200) here is deliberately separate from atrLen.
// prStructCrossUp / prStructCrossDn and prStructLine are display only.
// ----------------------------------------------------------------------------
float prAtr200  = ta.atr(200)
float prBodyPct = high != low ? math.abs(close - open) / (high - low) : 0.0
float prBodyMid = math.avg(high, low) + prBodyPct * (close - math.avg(high, low))

// FAST RAIL. The same adaptive follower as the structure rail but short, so a bar whose
// body sits far from the rail collapses adaptLen toward 1 and moves it most of the way in
// one bar. Direction flips only when the bar's rail movement exceeds an ATR deadzone.
// The step is (bodyMid - rail) / adaptLen, so prRailUp is effectively a price-above-rail
// test, not a slope reading - too loose to gate anything on its own.
var float prRailBasis = na
float prRailPrev    = nz(prRailBasis[1], prBodyMid)
float prRailDev     = atr != 0 ? math.abs(prBodyMid - prRailPrev) / atr : 0.0
float prRailAdaptLen = math.max(prRailLen / (1.0 + prRailDev), 1.0)
float prRailRawStep = (prBodyMid - prRailPrev) / prRailAdaptLen
float prRailMaxStep = 2.5 * atr
float prRailStep    = prRailMaxStep > 0 ? math.sign(prRailRawStep) * math.min(math.abs(prRailRawStep), prRailMaxStep) : prRailRawStep
prRailBasis := na(prRailBasis[1]) ? prBodyMid : prRailBasis[1] + prRailStep

float prRailOpen     = nz(prRailBasis[1], prRailBasis)
float prRailDeadzone = atr * prRailStrRef * 0.1
var bool prRailUp = true
if prRailBasis - prRailOpen > prRailDeadzone
    prRailUp := true
else if prRailOpen - prRailBasis > prRailDeadzone
    prRailUp := false

var float prStructRail = na
float prStructPrev    = nz(prStructRail[1], prBodyMid)
float prStructDev     = atr != 0 ? math.abs(prBodyMid - prStructPrev) / atr : 0.0
float prStructAdaptLen = math.max(prStructSpeed / (1.0 + prStructDev), 1.0)
float prStructRawStep = (prBodyMid - prStructPrev) / prStructAdaptLen
float prStructMaxStep = 1.5 * atr
float prStructStep    = prStructMaxStep > 0 ? math.sign(prStructRawStep) * math.min(math.abs(prStructRawStep), prStructMaxStep) : prStructRawStep
prStructRail := na(prStructRail[1]) ? prBodyMid : prStructRail[1] + prStructStep

float prStructUpper = prStructRail + prAtr200 * prStructWidth
float prStructLower = prStructRail - prAtr200 * prStructWidth

var bool prStructUp = false
if ta.crossover(prBodyMid, prStructUpper)
    prStructUp := true
if ta.crossunder(prBodyMid, prStructLower)
    prStructUp := false

bool prStructCrossUp = not prStructUp[1] and prStructUp
bool prStructCrossDn = prStructUp[1] and not prStructUp

// Continuous active boundary. prStructLine below goes na at a cross so the drawn line
// breaks cleanly, which makes it useless as a fill anchor - this one never does.
float prStructActive = prStructUp ? prStructLower : prStructUpper

var float prStructLine = na
if prStructUp
    prStructLine := prStructLower
if not prStructUp
    prStructLine := prStructUpper
if prStructCrossUp or prStructCrossDn
    prStructLine := na

// ----------------------------------------------------------------------------
// TRANSITION ENGINE. Rail-driven transitions run ALONGSIDE the defended-rail machine,
// never replacing it. The defended-rail path always runs first; each assisted path below
// carries a state guard so it can only act as a fallback.
//   prTopHi    - the campaign ceiling, set by the highest completed bull event. Its
//                existence enables the sharp early Bear exit, and it becomes the
//                defended level after that flip.
//   Fast rail  - timing.
//   Struct rail- selectivity; supplies the second condition on both assisted paths.
// Bull -> Bear: defended-rail break; assisted exit once prTopHi exists and the fast rail
// fails; and, only while no bull event has completed, a no-event exit needing both rails
// down. Bear -> Bull: defended-rail reclaim, and an assisted entry on both rails up.
// Assisted paths set prAssistFire and print a diamond; a defended-rail flip prints the
// triangle alone. Every test reads a live level state, so no flag can go stale.
// Rails-only campaigns carry no defended level and exit late by construction.
// ----------------------------------------------------------------------------
var float prTopHi = na

bool prNewTop = prNewBullRail and (na(prTopHi) or prBullRunHi > prTopHi)

var int   prTrendState = 0
var float prDefLevel   = na

bool prFlipUp = false
bool prFlipDn = false
bool prAssistFire = false

if prTrendState == 0
    if prNewBullRail
        prTrendState := 1
        prDefLevel   := prLowerRail
        prFlipUp     := true
    else if prNewBearRail
        prTrendState := -1
        prDefLevel   := prUpperRail
        prFlipDn     := true
else if prTrendState == 1
    if prNewBullRail
        prDefLevel := prLowerRail
    if not na(prDefLevel) and close < prDefLevel
        // A rail break only flips the trend if an opposing rail exists and price is
        // beyond it; otherwise the campaign continues.
        if not na(prUpperRail) and close < prUpperRail
            prTrendState := -1
            prDefLevel   := prUpperRail
            prFlipDn     := true
    if prNewTop
        prTopHi := prBullRunHi
    if prTrendState == 1 and not na(prTopHi) and not prRailUp
        prTrendState := -1
        prDefLevel   := prTopHi
        prFlipDn     := true
        prAssistFire := true
    // No-event Bull exit. A rails-only Bull campaign has no prTopHi and no defended level,
    // so neither authority above can end it. Mirror of the assisted Bear -> Bull entry:
    // both rails down exits, as both rails up entered. Gated on na(prTopHi), so it goes
    // dormant the moment a bull event completes. Late by construction - an exit that
    // always exists, not a well-timed one.
    if prTrendState == 1 and na(prTopHi) and not prRailUp and not prStructUp
        prTrendState := -1
        prDefLevel   := na
        prFlipDn     := true
        prAssistFire := true
else
    if prNewBearRail
        prDefLevel := prUpperRail
    if not na(prDefLevel) and close > prDefLevel
        if not na(prLowerRail) and close > prLowerRail
            prTrendState := 1
            prDefLevel   := prLowerRail
            prFlipUp     := true
    // Assisted Bear -> Bull, gated on the structure rail rather than a campaign floor:
    // there is no bearish equivalent of prTopHi. prStructUp supplies the selectivity,
    // prRailUp blocks the window just after an assisted Bull -> Bear flip. No defended
    // level is assigned, so Bull runs undefended until its own bull rail forms.
    if prTrendState == -1 and prRailUp and prStructUp
        prTrendState := 1
        prDefLevel   := na
        prFlipUp     := true
        prAssistFire := true

if prFlipUp
    prTopHi := na

if prFlipUp or prFlipDn
    prRefBullLo := na
    prRefBearHi := na

// The plotted trend line IS the fast rail - the same series, never a separate object, so
// the two cannot diverge. Gated to an established campaign because prRailBasis exists from
// bar one, where a campaign colour would be meaningless. The follower supplies shape;
// prTrendState supplies colour.
float prTrendLine = prTrendState == 0 ? na : prRailBasis

color prBullCol = #39FF14
color prBearCol = #FF1744
// Rail / structure direction colours, plus a separate pair used only by the inner fill
// so the two tiers read apart.
color prColUp   = #17DFAD
color prColDn   = #DD326B
color prFillUp  = #00B1C8
color prFillDn  = #C850FF
// The trend line takes the same palette but switches on campaign state, not rail direction.
color prLineCol = prTrendState == 1 ? prColUp : prColDn

// Candle painting. Display only. Both modes dim outside a %R run - the rail colours do not dim
// on their own, so that separation is PushBack's contribution. Wave reuses the trend line's own
// pair and its campaign switching, so candles and line always agree; the inner fill still reads
// prRailUp, so a rail/campaign disagreement shows as candle-against-fill contrast.
// Off => na => plotcandle draws nothing and native candles are left alone.
const color waveUpD = #0E7F63
const color waveDnD = #7F1D3D

bool pressureOn = overbought or oversold
bool barUp      = close >= open

color dirCandleCol   = pressureOn ? (barUp ? brightBullCol : brightBearCol) : (barUp ? dullBullCol : dullBearCol)
color waveCandleCol  = prTrendState == 0 ? na : pressureOn ? (prTrendState == 1 ? prColUp : prColDn) : (prTrendState == 1 ? waveUpD : waveDnD)
color pressCandleCol = candleMode == "Off" ? na : candleMode == "Wave" ? waveCandleCol : dirCandleCol
plotcandle(open, high, low, close, title = "Pressure Candles", color = pressCandleCol, wickcolor = pressCandleCol, bordercolor = pressCandleCol)

// Rails and defended level are data-window only, never drawn, but kept readable for
// diagnosis.
plot(prLowerRail, "Lower Bull Rail", display = display.data_window)
plot(prUpperRail, "Upper Bear Rail", display = display.data_window)
plot(prDefLevel,  "Defended Rail",   display = display.data_window)
pPrRail = plot(prShowLine ? prTrendLine : na, "Trend Line", color = color.new(prLineCol, 25), linewidth = 1)
pPrMid    = plot(hl2,            "Fill anchor (price)",     display = display.none)
pPrStruct = plot(prStructActive, "Fill anchor (structure)", display = display.none)

// Inner tier: clear at price, tinted at the fast rail, coloured by RAIL direction. Outer
// tier: clear at the fast rail, tinted out to the structure rail, coloured by STRUCTURE
// direction. Two colour sources on purpose - when the rails disagree the fill goes
// two-tone, which is the momentum read.
fill(pPrRail, pPrMid, prTrendLine, hl2, prShowFill ? color.new(prRailUp ? prFillUp : prFillDn, prInnerTransp) : na, na)
fill(pPrStruct, pPrRail, prStructActive, prTrendLine, prShowFill ? color.new(prStructUp ? prColUp : prColDn, prOuterTransp) : na, na)


plotshape(prShowSeq and prSeqHL, "HL", style = shape.labelup,   location = location.belowbar, color = color.new(prBullCol, 30), textcolor = color.black, text = "HL", size = size.tiny)
plotshape(prShowSeq and prSeqLL, "LL", style = shape.labelup,   location = location.belowbar, color = color.new(prBearCol, 30), textcolor = color.white, text = "LL", size = size.tiny)
plotshape(prShowSeq and prSeqHH, "HH", style = shape.labeldown, location = location.abovebar, color = color.new(prBullCol, 30), textcolor = color.black, text = "HH", size = size.tiny)
plotshape(prShowSeq and prSeqLH, "LH", style = shape.labeldown, location = location.abovebar, color = color.new(prBearCol, 30), textcolor = color.white, text = "LH", size = size.tiny)

plotshape(prShowMark and prFlipUp, "Trend Up",   style = shape.triangleup,   location = location.belowbar, color = prBullCol, size = size.tiny)
plotshape(prShowMark and prFlipDn, "Trend Down", style = shape.triangledown, location = location.abovebar, color = prBearCol, size = size.tiny)

plot(prShowStruct ? prStructLine : na, "Structure Rail", color = prStructUp ? prColUp : prColDn, linewidth = 2, style = plot.style_linebr)


plotshape(prShowMark and prAssistFire and prTrendState == -1, "Transition Down", style = shape.diamond, location = location.abovebar, color = prBearCol, size = size.tiny)
plotshape(prShowMark and prAssistFire and prTrendState == 1,  "Transition Up",   style = shape.diamond, location = location.belowbar, color = prBullCol, size = size.tiny)

plot(prTrendState, "Rail Trend State", display = display.data_window)
plot(not na(prTopHi) ? 1 : 0, "Top Event Live", display = display.data_window)
plot(prTopHi, "Top Event High", display = display.data_window)
plot(prRailUp ? 1 : 0, "Fast Rail Up", display = display.data_window)
plot(prStructUp ? 1 : 0, "Structure Trend Up", display = display.data_window)

// ----------------------------------------------------------------------------
// INFO PANEL. Must stay below the trend layer: the RSI colour reads prTrendState
// and the rail palette.
//
// RSI colour is campaign-relative. Teal = buyers have RSI control, magenta =
// sellers do, silver = neither, but the bands shift with the campaign because RSI
// ranges differently by regime.
//   Bull:  >= 50 teal    |  40-50 silver  |  < 40 magenta
//   Bear:  <= 50 magenta |  50-60 silver  |  > 60 teal
// Silver is a real state, not an absence of one; no campaign yet also reads silver.
// Drives nothing - no rail, level, zone or transition reads it.
//
// EVENTS is every completed pressure run today, LEVELS is the subset that earned
// structure, and the percentage is that earned share. Pine has no per-cell border
// colour, so the outer frame carries the state for the whole panel.
// ----------------------------------------------------------------------------
posSel = panelPos == "Bottom Left" ? position.bottom_left : panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Middle Right" ? position.middle_right : panelPos == "Middle Left" ? position.middle_left : position.bottom_right
ptSize = panelText == "tiny" ? size.tiny : panelText == "normal" ? size.normal : panelText == "large" ? size.large : size.small
var table panel = na

color rsiCol = prTrendState == 1 ? (rsiVal >= 50 ? prColUp : rsiVal >= 40 ? color.silver : prColDn) : prTrendState == -1 ? (rsiVal <= 50 ? prColDn : rsiVal <= 60 ? color.silver : prColUp) : color.silver

if showInfoPanel and barstate.islast
    int totalEv = qualEvents + filtEvents
    float pctLev = totalEv > 0 ? 100.0 * qualEvents / totalEv : 0.0
    string levTxt = totalEv > 0 ? str.tostring(qualEvents) + " (" + str.tostring(pctLev, "#") + "%)" : str.tostring(qualEvents)

    if not na(panel)
        table.delete(panel)
    panel := table.new(posSel, 2, 3, bgcolor = color.new(color.black, 20), frame_color = rsiCol, frame_width = 2, border_color = color.new(color.gray, 70), border_width = 1)
    table.cell(panel, 0, 0, "RSI",    text_color = color.silver, text_size = ptSize, text_halign = text.align_left)
    table.cell(panel, 1, 0, str.tostring(rsiVal, "#.0"), text_color = rsiCol, text_size = ptSize, text_halign = text.align_right)
    table.cell(panel, 0, 1, "EVENTS", text_color = color.silver, text_size = ptSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, str.tostring(totalEv), text_color = color.white, text_size = ptSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "LEVELS", text_color = color.silver, text_size = ptSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, levTxt, text_color = color.white, text_size = ptSize, text_halign = text.align_right)
````
