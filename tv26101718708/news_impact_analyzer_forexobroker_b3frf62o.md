# News Impact Analyzer [forexobroker]

- url: https://www.tradingview.com/script/B3fRF62o-News-Impact-Analyzer-forexobroker/
- type: indicator
- pine_id: PUB;2476ff4f2c9748dc8f01c935eccb2600
- version: 1.0

## Description

News Impact Analyzer bridges the gap between fundamental events and technical price action. Instead of relying on external calendars, it detects volatility spikes directly from price data, tracks recurring scheduled events (NFP, FOMC, ECB), measures their historical pip impact, and adjusts your risk management recommendations automatically.

THE PROBLEM WITH NEWS TRADING

Most traders know that news moves markets, but they handle it poorly:

No Historical Context — NFP just dropped and EURUSD moved 80 pips. Is that normal? Without historical impact data, you can't assess whether the move is an overreaction or just getting started. This indicator tracks average pip movement per event type so you have context.

No Pre-Event Awareness — You enter a trade 30 minutes before NFP and get stopped out by the spike. Without a pre-event warning system, you're walking into a minefield blindfolded. This indicator highlights pre-event windows and recommends avoiding new positions.

Wrong Position Sizing — You trade the same lot size during NFP as during Asian session lulls. During high-volatility events, the same position size carries 3-5× more risk. This indicator calculates separate position sizes for normal conditions and event windows.

No Volatility Profile — You don't know that your pair moves twice as much during London session compared to Asia. Without an hourly volatility profile, you're missing the rhythm of the market. This indicator builds a profile from actual price data.

HOW IT WORKS

1. Volatility Spike Detection

The indicator identifies bars where the range (high - low) exceeds a configurable ATR multiplier. These spikes represent high-impact events — whether from scheduled news, unexpected announcements, or institutional activity.

Classification:

Low: 2-3× ATR (routine volatility expansion)
Medium: 3-4× ATR (significant market move)
High: 4× ATR (major event impact)
Extreme: 4×+ ATR (crisis-level volatility)
Nearby spikes are merged to prevent double-counting clustered events.

2. Scheduled Event Detection

The indicator automatically detects recurring forex events:

Event	Detection	Typical Impact
NFP	First Friday of each month, 13:00 UTC bar	50-150 pips on USD pairs
FOMC	Mid-month Wednesday in FOMC months, 19:00 UTC	30-100 pips on USD pairs
ECB	Mid-month Thursday in ECB months, 13:00 UTC	20-80 pips on EUR pairs
Each event type tracks its own historical average pip impact.

3. Pre/Post Event Windows

Pre-Event Zone (yellow background): Bars before a scheduled event. The indicator warns against new positions during this window — spreads widen, liquidity thins, and any position faces imminent high-volatility risk.
Post-Event Zone (red-tinted background): Bars after a detected event. Volatility often remains elevated as the market digests the move.
4. Hourly Volatility Profile

The dashboard builds a volatility profile from actual price data, showing average pip movement per 4-hour UTC block. This reveals your pair's natural rhythm — when it's most active and when it's quiet.

5. Position Sizing Recommendations

Two sizing recommendations are always available:

Normal Size: Based on standard ATR and your normal risk percentage
Event Size: Reduced risk percentage with wider expected stops, calculated from historical event volatility
During pre-event and post-event windows, the dashboard automatically recommends the reduced event size.

ANALYTICS DASHBOARD

Section	Shows
Current State	Volatility level (Calm/Normal/Elevated/Extreme), current bar range, ATR
Zone	Pre-event, post-event, or clear status
Risk Advice	Normal trading, reduced size, or avoid new positions
Event Stats	Total events, high/extreme counts, average and max impact
Pre/Post Avg	Average volatility during pre-event vs post-event windows
Scheduled	NFP, FOMC, ECB average pips and event counts
Sizing	Normal vs event lot sizes with risk amounts
Hourly Profile	4-hour block volatility averages with HIGH/MED/LOW ratings

FEATURES

Volatility spike detection with ATR-based threshold
4-level impact classification (Low/Medium/High/Extreme)
Spike merging to prevent double-counting
Scheduled event detection (NFP, FOMC, ECB)
Per-event historical pip tracking
Pre-event warning zones with background highlighting
Post-event volatility window tracking
Hourly volatility profile (4-hour UTC blocks)
Position sizing for normal and event conditions
Risk advisory system (Normal/Reduced/Avoid)
Expected impact range boxes on scheduled events
Bar coloring by spike impact level
Comprehensive analytics dashboard
Theme-aware colors for light and dark charts
Data Window integration for all metrics
7 alert conditions including pre-event warnings
Zero request.security() calls
barstate.isconfirmed on all spike detections — no repainting
Works on any forex pair and timeframe

ALERTS

Alert	Fires When
High Impact Event	Volatility spike ≥ 3× ATR detected
Extreme Impact Event	Volatility spike ≥ 4× ATR detected
Any Volatility Spike	Any spike above threshold
Scheduled Event	NFP, FOMC, or ECB bar detected
Pre-Event Warning	Entering pre-event window
Post-Event Start	Post-event volatility window begins
Any Event	Any spike or scheduled event

USE CASES

Pre-News Risk Management — Set alerts on "Pre-Event Warning" to get notified before NFP, FOMC, or ECB releases. Close or tighten positions before the spike hits.

Event Impact Assessment — After a news release, check the dashboard to see how the current move compares to historical averages. If the move is significantly larger than the average NFP impact, it may be overextended.

Session Planning — Use the hourly volatility profile to identify the best trading hours for your pair. Trade during HIGH volatility blocks for breakout strategies, or during LOW blocks for range trading.

Position Sizing Discipline — Let the indicator calculate appropriate lot sizes for both normal conditions and event windows. Never be over-leveraged during a news release again.

Volatility Regime Detection — The current state indicator (Calm/Normal/Elevated/Extreme) helps you choose the right strategy. Trend-following in elevated conditions, mean-reversion in calm conditions.

SETTINGS OVERVIEW

Event Detection: Spike threshold (ATR multiplier), ATR length, minimum spike size in pips, merge window.

Scheduled Events: NFP/FOMC/ECB toggles, pre-event and post-event bar windows.

Impact Analysis: Event lookback count, expected impact range display.

Position Sizing: Account size, normal risk %, event risk %, no-trade zone toggle, pip value.

Display: Dashboard, event labels, volatility profile, zone backgrounds, max labels, table position, text size.

Colors: Low/medium/high/extreme impact, pre-event zone, neutral.

TECHNICAL NOTES

Zero request.security() calls — all analysis on chart timeframe
Spike detection on barstate.isconfirmed only — no repainting
Scheduled events use UTC hour detection for consistent timing
NFP detection: dayofweek.friday AND dayofmonth <= 7 AND hour == 13 UTC
FOMC detection: FOMC-month Wednesdays, mid-month, hour == 19 UTC
ECB detection: ECB-month Thursdays, mid-month, hour == 13 UTC
Hourly profile builds from actual bar data — accuracy improves with more history
Position sizing uses standard forex lot calculation
Pre/post event stats tracked in separate arrays for accurate comparison

DISCLAIMER

This indicator is for educational and informational purposes only. It does not constitute financial advice. Scheduled event detection uses approximate date patterns and may not match exact economic calendar dates every time. Volatility spike detection is reactive by nature — it identifies events after they begin, not before. Always verify scheduled event times against an official economic calendar. Past volatility patterns do not guarantee future movements. Use proper risk management at all times.

## Source Code

````pine
//@version=6
indicator("News Impact Analyzer [forexobroker]",
     shorttitle="News Impact",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=200)

// ══════════════════════════════════════════════════════════════════════════════
// News Impact Analyzer [forexobroker]
// Version 1.0
//
// Fundamental-technical bridge tool. Detects volatility spikes as news events,
// tracks recurring scheduled events (NFP, FOMC, ECB), measures pre/post event
// pip movements, builds hourly volatility profiles, and provides position
// sizing recommendations based on expected volatility.
//
// (c) forexobroker | Invite-only (paid)
// ══════════════════════════════════════════════════════════════════════════════

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ INPUTS                                                                  │
// └──────────────────────────────────────────────────────────────────────────┘

grpDetect = "Event Detection"
spikeATRMult  = input.float(2.0, "Spike Threshold (ATR×)", minval=1.0, maxval=5.0, step=0.1, group=grpDetect, tooltip="Bar range exceeding ATR × this = volatility event")
atrLen        = input.int(14, "ATR Length", minval=5, maxval=50, group=grpDetect)
minSpikePips  = input.float(10.0, "Min Spike Size (pips)", minval=1, maxval=200, group=grpDetect, tooltip="Minimum bar range in pips to qualify as event")
mergeBars     = input.int(3, "Merge Window (bars)", minval=1, maxval=10, group=grpDetect, tooltip="Events within this many bars are merged as one")

grpSchedule = "Scheduled Events"
detectNFP   = input.bool(true, "Detect NFP (1st Friday)", group=grpSchedule, tooltip="Non-Farm Payrolls — first Friday of each month")
detectFOMC  = input.bool(true, "Detect FOMC Days", group=grpSchedule, tooltip="FOMC meetings — typically 8 per year on Wednesdays")
detectECB   = input.bool(true, "Detect ECB Days", group=grpSchedule, tooltip="ECB rate decisions — typically Thursdays")
preEventBars  = input.int(6, "Pre-Event Warning (bars)", minval=1, maxval=24, group=grpSchedule, tooltip="Bars before scheduled event to highlight")
postEventBars = input.int(6, "Post-Event Window (bars)", minval=1, maxval=24, group=grpSchedule)

grpImpact = "Impact Analysis"
impactLookback = input.int(50, "Event Lookback Count", minval=10, maxval=200, group=grpImpact, tooltip="How many past events to average for impact stats")
showImpactLevels = input.bool(true, "Show Expected Impact Range", group=grpImpact, tooltip="Draw projected pip range box around scheduled events")

grpSize = "Position Sizing"
accountSize   = input.float(10000, "Account Size ($)", minval=100, group=grpSize)
normalRiskPct = input.float(1.0, "Normal Risk (%)", minval=0.1, maxval=5.0, step=0.1, group=grpSize)
eventRiskPct  = input.float(0.5, "Event Risk (%)", minval=0.1, maxval=5.0, step=0.1, group=grpSize, tooltip="Reduced risk during high-volatility events")
noTradeZone   = input.bool(true, "No-Trade Zone Pre-Event", group=grpSize, tooltip="Show warning during pre-event window")
pipValueInput = input.float(10.0, "Pip Value ($/lot)", minval=0.01, maxval=100.0, group=grpSize)

grpDisplay = "Display"
showDashboard   = input.bool(true, "Show Dashboard", group=grpDisplay)
showEventLabels = input.bool(true, "Show Event Labels", group=grpDisplay)
showVolProfile  = input.bool(true, "Show Volatility Profile", group=grpDisplay, tooltip="Hourly volatility table showing avg pips per hour")
showZones       = input.bool(true, "Show Pre/Post Zones", group=grpDisplay)
maxEventLabels  = input.int(30, "Max Event Labels", minval=5, maxval=100, group=grpDisplay)
tablePosition   = input.string("top_right", "Table Position", options=["top_left","top_center","top_right","bottom_left","bottom_center","bottom_right"], group=grpDisplay)
textSizeInput   = input.string("small", "Text Size", options=["tiny","small","normal"], group=grpDisplay)

grpCol = "Colors"
lowImpactCol    = input.color(#42A5F5, "Low Impact", group=grpCol)
medImpactCol    = input.color(#FF9800, "Medium Impact", group=grpCol)
highImpactCol   = input.color(#EF5350, "High Impact", group=grpCol)
extremeImpactCol = input.color(#9C27B0, "Extreme Impact", group=grpCol)
preEventCol     = input.color(#FFF176, "Pre-Event Zone", group=grpCol)
neutralCol      = input.color(#787B86, "Neutral", group=grpCol)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ THEME + HELPERS                                                         │
// └──────────────────────────────────────────────────────────────────────────┘

bool isDark = color.r(chart.bg_color) < 128
headerBg   = isDark ? #2A2E39 : #E8E8E8
headerText = isDark ? #D1D4DC : #333333
cellBg     = isDark ? #1E222D : #F5F5F5
borderCol  = isDark ? #363A45 : #D0D0D0
titleBg    = #0D47A1
titleText  = color.white

getTablePos() =>
    switch tablePosition
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        => position.bottom_right

getTextSize() =>
    switch textSizeInput
        "tiny"   => size.tiny
        "small"  => size.small
        => size.normal

pipSize = syminfo.mintick * (str.contains(syminfo.ticker, "JPY") ? 100 : 10)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ SCHEDULED EVENT DETECTION                                               │
// └──────────────────────────────────────────────────────────────────────────┘

utcHour   = hour(time, "UTC")
utcDay    = dayofweek(time)
utcDayMo  = dayofmonth(time)
utcMonth  = month(time)
utcYear   = year(time)

// NFP: First Friday of month (usually 8:30 AM ET = 13:30 UTC)
isFirstFriday = utcDay == dayofweek.friday and utcDayMo <= 7
isNFPBar      = detectNFP and isFirstFriday and utcHour == 13

// FOMC: ~8 per year, typically Wednesday 14:00 ET = 19:00 UTC
// Approximate: Jan, Mar, May, Jun, Jul, Sep, Nov, Dec — middle of month Wednesdays
isFOMCMonth   = utcMonth == 1 or utcMonth == 3 or utcMonth == 5 or utcMonth == 6 or utcMonth == 7 or utcMonth == 9 or utcMonth == 11 or utcMonth == 12
isFOMCBar     = detectFOMC and isFOMCMonth and utcDay == dayofweek.wednesday and utcDayMo >= 14 and utcDayMo <= 21 and utcHour == 19

// ECB: ~8 per year, typically Thursdays 13:45 CET = 12:45 UTC → detect at hour 13
isECBMonth    = utcMonth == 1 or utcMonth == 3 or utcMonth == 4 or utcMonth == 6 or utcMonth == 7 or utcMonth == 9 or utcMonth == 10 or utcMonth == 12
isECBBar      = detectECB and isECBMonth and utcDay == dayofweek.thursday and utcDayMo >= 14 and utcDayMo <= 28 and utcHour == 13

isScheduledEvent = isNFPBar or isFOMCBar or isECBBar
scheduledName    = isNFPBar ? "NFP" : isFOMCBar ? "FOMC" : isECBBar ? "ECB" : ""

// Pre-event window detection (look ahead to see if scheduled event is near)
// Track last scheduled event bar for proximity
var int lastScheduledBar = -999
if isScheduledEvent
    lastScheduledBar := bar_index

// For forward-looking pre-event, we check NFP proximity
// Since we can't look ahead, we detect "first Friday approaching" on the same day
isNFPDay   = detectNFP and isFirstFriday and utcHour < 13
isFOMCDay  = detectFOMC and isFOMCMonth and utcDay == dayofweek.wednesday and utcDayMo >= 14 and utcDayMo <= 21 and utcHour < 19
isECBDay   = detectECB and isECBMonth and utcDay == dayofweek.thursday and utcDayMo >= 14 and utcDayMo <= 28 and utcHour < 13

isPreEventWindow = isNFPDay or isFOMCDay or isECBDay
isPostEvent = (bar_index - lastScheduledBar) <= postEventBars and lastScheduledBar > 0

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ VOLATILITY SPIKE DETECTION                                              │
// └──────────────────────────────────────────────────────────────────────────┘

atrVal      = ta.atr(atrLen)
barRng      = high - low
barRngPips  = barRng / pipSize
isSpike     = barRng > atrVal * spikeATRMult and barRngPips >= minSpikePips and barstate.isconfirmed

// Merge close spikes
var int lastSpikeBar = -999
isMerged = isSpike and (bar_index - lastSpikeBar) <= mergeBars and lastSpikeBar > 0
isNewSpike = isSpike and not isMerged

if isNewSpike
    lastSpikeBar := bar_index
else if isSpike
    lastSpikeBar := bar_index

// Impact classification
spikeRatio = barRng / atrVal
impactLevel = spikeRatio >= 4.0 ? 4 : spikeRatio >= 3.0 ? 3 : spikeRatio >= 2.0 ? 2 : 1
impactName  = impactLevel == 4 ? "EXTREME" : impactLevel == 3 ? "HIGH" : impactLevel == 2 ? "MEDIUM" : "LOW"
impactCol   = impactLevel == 4 ? extremeImpactCol : impactLevel == 3 ? highImpactCol : impactLevel == 2 ? medImpactCol : lowImpactCol

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ EVENT TRACKING + STATISTICS                                             │
// └──────────────────────────────────────────────────────────────────────────┘

// Store event pip movements
var array<float> eventPips     = array.new_float()
var array<int>   eventLevels   = array.new_int()
var array<int>   eventHours    = array.new_int()
var int          totalEvents   = 0
var int          highEvents    = 0
var int          extremeEvents = 0

// Hourly volatility profile (24 hours)
var array<float> hourlyPipSum   = array.new_float(24, 0.0)
var array<int>   hourlyBarCount = array.new_int(24, 0)

// Track pre-event average volatility
var array<float> preEventPips   = array.new_float()
var array<float> postEventPips  = array.new_float()

// NFP-specific tracking
var array<float> nfpPips   = array.new_float()
var array<float> fomcPips  = array.new_float()
var array<float> ecbPips   = array.new_float()

// Update hourly profile
if barstate.isconfirmed and utcHour >= 0 and utcHour < 24
    array.set(hourlyPipSum, utcHour, array.get(hourlyPipSum, utcHour) + barRngPips)
    array.set(hourlyBarCount, utcHour, array.get(hourlyBarCount, utcHour) + 1)

// Record events
if isNewSpike
    totalEvents += 1
    if impactLevel >= 3
        highEvents += 1
    if impactLevel >= 4
        extremeEvents += 1

    array.push(eventPips, barRngPips)
    array.push(eventLevels, impactLevel)
    array.push(eventHours, utcHour)

    while array.size(eventPips) > impactLookback
        array.shift(eventPips)
        array.shift(eventLevels)
        array.shift(eventHours)

    // Attribute to scheduled event type
    if isScheduledEvent
        if isNFPBar
            array.push(nfpPips, barRngPips)
            while array.size(nfpPips) > 50
                array.shift(nfpPips)
        if isFOMCBar
            array.push(fomcPips, barRngPips)
            while array.size(fomcPips) > 50
                array.shift(fomcPips)
        if isECBBar
            array.push(ecbPips, barRngPips)
            while array.size(ecbPips) > 50
                array.shift(ecbPips)

// Pre/post event volatility tracking
if barstate.isconfirmed and isPreEventWindow
    array.push(preEventPips, barRngPips)
    while array.size(preEventPips) > 100
        array.shift(preEventPips)

if barstate.isconfirmed and isPostEvent
    array.push(postEventPips, barRngPips)
    while array.size(postEventPips) > 100
        array.shift(postEventPips)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ STATISTICS CALCULATION                                                  │
// └──────────────────────────────────────────────────────────────────────────┘

avgEventPips = array.size(eventPips) > 0 ? array.avg(eventPips) : 0.0
maxEventPips = array.size(eventPips) > 0 ? array.max(eventPips) : 0.0

avgPrePips   = array.size(preEventPips) > 0 ? array.avg(preEventPips) : 0.0
avgPostPips  = array.size(postEventPips) > 0 ? array.avg(postEventPips) : 0.0

avgNFPPips   = array.size(nfpPips) > 0 ? array.avg(nfpPips) : 0.0
avgFOMCPips  = array.size(fomcPips) > 0 ? array.avg(fomcPips) : 0.0
avgECBPips   = array.size(ecbPips) > 0 ? array.avg(ecbPips) : 0.0

// Current volatility state
normalATRPips = atrVal / pipSize
currentVolState = barRngPips >= normalATRPips * 3 ? "EXTREME" : barRngPips >= normalATRPips * 2 ? "ELEVATED" : barRngPips >= normalATRPips * 1.2 ? "NORMAL" : "CALM"
volStateCol = currentVolState == "EXTREME" ? extremeImpactCol : currentVolState == "ELEVATED" ? highImpactCol : currentVolState == "NORMAL" ? neutralCol : lowImpactCol

// Position sizing recommendation
float recommendedRisk = isPreEventWindow or isPostEvent ? eventRiskPct : normalRiskPct
float slDistPips = isPreEventWindow or isPostEvent ? math.max(avgEventPips * 0.5, normalATRPips * 1.5) : normalATRPips * 1.5
float recommendedLots = slDistPips > 0 ? (accountSize * recommendedRisk / 100.0) / (slDistPips * pipValueInput) : 0.0
recommendedLots := math.round(recommendedLots * 100) / 100

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ OVERLAY VISUALS                                                         │
// └──────────────────────────────────────────────────────────────────────────┘

// Event spike labels
if isNewSpike and showEventLabels
    string eName = isScheduledEvent ? scheduledName + " " : ""
    string eTxt = eName + impactName + "\n" + str.tostring(barRngPips, "#.#") + " pips"
    label.new(bar_index, high + atrVal * 0.3, eTxt, color=impactCol, textcolor=color.white, style=label.style_label_down, size=size.small)

// Scheduled event labels (even if not a spike)
if isScheduledEvent and not isNewSpike and showEventLabels
    label.new(bar_index, high + atrVal * 0.3, scheduledName, color=color.new(medImpactCol, 40), textcolor=color.white, style=label.style_label_down, size=size.tiny)

// Pre-event zone background
preEventBgCol = showZones and isPreEventWindow and noTradeZone ? color.new(preEventCol, 90) : na
bgcolor(preEventBgCol, title="Pre-Event Zone")

// Post-event zone
postEventBgCol = showZones and isPostEvent ? color.new(highImpactCol, 92) : na
bgcolor(postEventBgCol, title="Post-Event Zone")

// Expected impact range box on scheduled events
if isScheduledEvent and showImpactLevels and avgEventPips > 0
    float halfRange = avgEventPips * pipSize * 0.5
    box.new(bar_index - 1, close + halfRange, bar_index + postEventBars, close - halfRange, border_color=color.new(medImpactCol, 50), bgcolor=color.new(medImpactCol, 90), border_width=1, border_style=line.style_dashed)

// Bar coloring by impact
barcolor(isNewSpike ? impactCol : na, title="Spike Bar Color")

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ DATA WINDOW                                                             │
// └──────────────────────────────────────────────────────────────────────────┘

plot(barRngPips,       "Bar Range (pips)",    display=display.data_window)
plot(normalATRPips,    "ATR (pips)",          display=display.data_window)
plot(spikeRatio,       "Spike Ratio",         display=display.data_window)
plot(avgEventPips,     "Avg Event Pips",      display=display.data_window)
plot(totalEvents * 1.0, "Total Events",      display=display.data_window)
plot(recommendedLots,  "Recommended Lots",    display=display.data_window)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ DASHBOARD                                                               │
// └──────────────────────────────────────────────────────────────────────────┘

if showDashboard and barstate.islast
    int totalRows = showVolProfile ? 28 : 18
    var table dash = table.new(getTablePos(), 4, totalRows, border_width=1, border_color=borderCol, frame_width=2, frame_color=borderCol)
    tSz = getTextSize()
    int row = 0

    // Title
    table.cell(dash, 0, row, "NEWS IMPACT", text_color=titleText, bgcolor=titleBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "ANALYZER", text_color=titleText, bgcolor=titleBg, text_size=tSz)
    table.cell(dash, 2, row, syminfo.ticker, text_color=titleText, bgcolor=titleBg, text_size=tSz)
    table.cell(dash, 3, row, "forexobroker", text_color=titleText, bgcolor=titleBg, text_size=tSz)
    row += 1

    // Current State
    table.cell(dash, 0, row, "CURRENT STATE", text_color=titleText, bgcolor=color.new(lowImpactCol, 30), text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "", bgcolor=color.new(lowImpactCol, 30), text_size=tSz)
    table.cell(dash, 2, row, "", bgcolor=color.new(lowImpactCol, 30), text_size=tSz)
    table.cell(dash, 3, row, "", bgcolor=color.new(lowImpactCol, 30), text_size=tSz)
    row += 1

    table.cell(dash, 0, row, "Volatility", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, currentVolState, text_color=volStateCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, str.tostring(barRngPips, "#.#") + "p", text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "ATR:" + str.tostring(normalATRPips, "#.#") + "p", text_color=neutralCol, bgcolor=cellBg, text_size=tSz)
    row += 1

    string zoneStatus = isPreEventWindow ? "PRE-EVENT" : isPostEvent ? "POST-EVENT" : "CLEAR"
    color  zoneCol    = isPreEventWindow ? preEventCol : isPostEvent ? highImpactCol : lowImpactCol
    table.cell(dash, 0, row, "Zone", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, zoneStatus, text_color=zoneCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "", bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "", bgcolor=cellBg, text_size=tSz)
    row += 1

    // Risk Advisory
    string riskAdvice = isPreEventWindow and noTradeZone ? "AVOID NEW" : isPostEvent ? "REDUCED SIZE" : "NORMAL"
    color  riskCol    = isPreEventWindow and noTradeZone ? highImpactCol : isPostEvent ? medImpactCol : lowImpactCol
    table.cell(dash, 0, row, "Risk Advice", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, riskAdvice, text_color=riskCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, str.tostring(recommendedRisk, "#.#") + "%", text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, str.tostring(recommendedLots, "#.##") + " lots", text_color=headerText, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Event Statistics
    table.cell(dash, 0, row, "EVENT STATS", text_color=titleText, bgcolor=color.new(medImpactCol, 30), text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "", bgcolor=color.new(medImpactCol, 30), text_size=tSz)
    table.cell(dash, 2, row, "", bgcolor=color.new(medImpactCol, 30), text_size=tSz)
    table.cell(dash, 3, row, "", bgcolor=color.new(medImpactCol, 30), text_size=tSz)
    row += 1

    table.cell(dash, 0, row, "Total Events", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, str.tostring(totalEvents), text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "High:" + str.tostring(highEvents), text_color=highImpactCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "Extr:" + str.tostring(extremeEvents), text_color=extremeImpactCol, bgcolor=cellBg, text_size=tSz)
    row += 1

    table.cell(dash, 0, row, "Avg Impact", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, str.tostring(avgEventPips, "#.#") + " pips", text_color=medImpactCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Max:" + str.tostring(maxEventPips, "#.#"), text_color=highImpactCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "", bgcolor=cellBg, text_size=tSz)
    row += 1

    table.cell(dash, 0, row, "Pre-Event Avg", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, str.tostring(avgPrePips, "#.#") + " pips", text_color=neutralCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Post:", text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, str.tostring(avgPostPips, "#.#") + " pips", text_color=medImpactCol, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Scheduled Event Averages
    table.cell(dash, 0, row, "SCHEDULED", text_color=titleText, bgcolor=color.new(highImpactCol, 30), text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "Avg Pips", text_color=titleText, bgcolor=color.new(highImpactCol, 30), text_size=tSz)
    table.cell(dash, 2, row, "Events", text_color=titleText, bgcolor=color.new(highImpactCol, 30), text_size=tSz)
    table.cell(dash, 3, row, "", bgcolor=color.new(highImpactCol, 30), text_size=tSz)
    row += 1

    if detectNFP
        table.cell(dash, 0, row, "NFP", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
        table.cell(dash, 1, row, avgNFPPips > 0 ? str.tostring(avgNFPPips, "#.#") + "p" : "—", text_color=avgNFPPips > 0 ? highImpactCol : neutralCol, bgcolor=cellBg, text_size=tSz)
        table.cell(dash, 2, row, str.tostring(array.size(nfpPips)), text_color=headerText, bgcolor=cellBg, text_size=tSz)
        table.cell(dash, 3, row, "1st Fri", text_color=neutralCol, bgcolor=cellBg, text_size=tSz)
        row += 1

    if detectFOMC
        table.cell(dash, 0, row, "FOMC", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
        table.cell(dash, 1, row, avgFOMCPips > 0 ? str.tostring(avgFOMCPips, "#.#") + "p" : "—", text_color=avgFOMCPips > 0 ? highImpactCol : neutralCol, bgcolor=cellBg, text_size=tSz)
        table.cell(dash, 2, row, str.tostring(array.size(fomcPips)), text_color=headerText, bgcolor=cellBg, text_size=tSz)
        table.cell(dash, 3, row, "Wed", text_color=neutralCol, bgcolor=cellBg, text_size=tSz)
        row += 1

    if detectECB
        table.cell(dash, 0, row, "ECB", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
        table.cell(dash, 1, row, avgECBPips > 0 ? str.tostring(avgECBPips, "#.#") + "p" : "—", text_color=avgECBPips > 0 ? highImpactCol : neutralCol, bgcolor=cellBg, text_size=tSz)
        table.cell(dash, 2, row, str.tostring(array.size(ecbPips)), text_color=headerText, bgcolor=cellBg, text_size=tSz)
        table.cell(dash, 3, row, "Thu", text_color=neutralCol, bgcolor=cellBg, text_size=tSz)
        row += 1

    // Position Sizing
    table.cell(dash, 0, row, "SIZING", text_color=titleText, bgcolor=color.new(#26A69A, 30), text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "", bgcolor=color.new(#26A69A, 30), text_size=tSz)
    table.cell(dash, 2, row, "", bgcolor=color.new(#26A69A, 30), text_size=tSz)
    table.cell(dash, 3, row, "", bgcolor=color.new(#26A69A, 30), text_size=tSz)
    row += 1

    float normalLots = normalATRPips * 1.5 > 0 ? (accountSize * normalRiskPct / 100.0) / (normalATRPips * 1.5 * pipValueInput) : 0.0
    normalLots := math.round(normalLots * 100) / 100
    float eventLots = avgEventPips * 0.5 > 0 ? (accountSize * eventRiskPct / 100.0) / (avgEventPips * 0.5 * pipValueInput) : 0.0
    eventLots := math.round(eventLots * 100) / 100

    table.cell(dash, 0, row, "Account", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "$" + str.tostring(accountSize, "#"), text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "", bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "", bgcolor=cellBg, text_size=tSz)
    row += 1

    table.cell(dash, 0, row, "Normal Size", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, str.tostring(normalLots, "#.##") + " lots", text_color=lowImpactCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Risk:" + str.tostring(normalRiskPct, "#.#") + "%", text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "$" + str.tostring(accountSize * normalRiskPct / 100.0, "#.##"), text_color=headerText, bgcolor=cellBg, text_size=tSz)
    row += 1

    table.cell(dash, 0, row, "Event Size", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, str.tostring(eventLots, "#.##") + " lots", text_color=highImpactCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Risk:" + str.tostring(eventRiskPct, "#.#") + "%", text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "$" + str.tostring(accountSize * eventRiskPct / 100.0, "#.##"), text_color=headerText, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Hourly Volatility Profile
    if showVolProfile
        table.cell(dash, 0, row, "HOURLY PROFILE", text_color=titleText, bgcolor=color.new(extremeImpactCol, 30), text_size=tSz, text_halign=text.align_left)
        table.cell(dash, 1, row, "Avg Pips", text_color=titleText, bgcolor=color.new(extremeImpactCol, 30), text_size=tSz)
        table.cell(dash, 2, row, "Bars", text_color=titleText, bgcolor=color.new(extremeImpactCol, 30), text_size=tSz)
        table.cell(dash, 3, row, "Level", text_color=titleText, bgcolor=color.new(extremeImpactCol, 30), text_size=tSz)
        row += 1

        // Find max hourly avg for relative scaling
        float maxHourlyAvg = 0.0
        for h = 0 to 23
            int cnt = array.get(hourlyBarCount, h)
            if cnt > 0
                float avg = array.get(hourlyPipSum, h) / cnt
                maxHourlyAvg := math.max(maxHourlyAvg, avg)

        // Show key trading hours (group into 4-hour blocks for compact display)
        blockNames   = array.from("00-03", "04-07", "08-11", "12-15", "16-19", "20-23")
        for b = 0 to 5
            int startH = b * 4
            float blockSum = 0.0
            int   blockCnt = 0
            for h = startH to startH + 3
                blockSum += array.get(hourlyPipSum, h)
                blockCnt += array.get(hourlyBarCount, h)
            float blockAvg = blockCnt > 0 ? blockSum / blockCnt : 0.0
            string blockLevel = blockAvg >= maxHourlyAvg * 0.8 ? "HIGH" : blockAvg >= maxHourlyAvg * 0.4 ? "MED" : "LOW"
            color  blockCol   = blockLevel == "HIGH" ? highImpactCol : blockLevel == "MED" ? medImpactCol : lowImpactCol

            table.cell(dash, 0, row, array.get(blockNames, b) + " UTC", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
            table.cell(dash, 1, row, str.tostring(blockAvg, "#.#") + "p", text_color=blockCol, bgcolor=cellBg, text_size=tSz)
            table.cell(dash, 2, row, str.tostring(blockCnt), text_color=neutralCol, bgcolor=cellBg, text_size=tSz)
            table.cell(dash, 3, row, blockLevel, text_color=blockCol, bgcolor=cellBg, text_size=tSz)
            row += 1

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ ALERT CONDITIONS                                                        │
// └──────────────────────────────────────────────────────────────────────────┘

alertcondition(isNewSpike and impactLevel >= 3, "High Impact Event", "News Impact: High volatility spike detected")
alertcondition(isNewSpike and impactLevel >= 4, "Extreme Impact Event", "News Impact: Extreme volatility spike detected")
alertcondition(isNewSpike, "Any Volatility Spike", "News Impact: Volatility spike detected")
alertcondition(isScheduledEvent, "Scheduled Event", "News Impact: Scheduled event bar (NFP/FOMC/ECB)")
alertcondition(isPreEventWindow and not isPreEventWindow[1], "Pre-Event Warning", "News Impact: Entering pre-event window")
alertcondition(isPostEvent and not isPostEvent[1], "Post-Event Start", "News Impact: Post-event volatility window active")
alertcondition(isNewSpike or isScheduledEvent, "Any Event", "News Impact: Event detected")
````
