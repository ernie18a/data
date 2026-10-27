# SMC Pro: Strategy & Liquidity

- url: https://www.tradingview.com/script/6iAh8TWT-SMC-Pro-Strategy-Liquidity/
- type: indicator
- pine_id: PUB;bc619dc5adeb45e78359847c577dfeff
- version: 1.0

## Description

SMC Pro: Strategy & Liquidity


OVERVIEW

SMC Pro: Strategy & Liquidity is a Smart Money Concepts toolkit built around one
idea: a price level only matters once the liquidity resting at it has been taken,
and a liquidity raid only matters once price confirms that delivery has changed
direction afterwards. Instead of plotting every pattern the market prints, the
script sequences six engines so that context, the raid, and the confirmation are
read in order on a single overlay.

The six engines are:

  1. Higher timeframe and session reference levels
  2. Confirmed liquidity sweeps
  3. Fair Value Gaps and Inverse Fair Value Gaps
  4. Order Blocks and Breaker Blocks
  5. CISD - Change In State Of Delivery, with a dashboard and alerts
  6. SMT divergence against a correlated symbol

Every engine evaluates on closed bars. Zones, sweeps, structure breaks and CISD
events are not created or removed based on the movement of the unclosed candle.


WHAT MAKES IT DIFFERENT

The individual concepts here are public knowledge in the Smart Money Concepts
community. What this script contributes is how they are filtered and joined
together:

- Reference levels carry an invalidation state. Once price has CLOSED through a
  1H, 4H or session level, that level is permanently disqualified from producing
  a sweep for the remainder of its cycle. A level that has already been accepted
  by price is no longer liquidity, so it stops being tested as such. Most sweep
  tools re-flag the same level repeatedly after it has been broken.

- Only the first sweep per side is drawn per reference cycle. The flags reset
  when a new 1H, 4H or session level is confirmed. One raid produces one marker
  rather than a cluster of near-duplicates.

- The CISD engine anchors to a swept series, not to a single candle. A candidate
  is built from consecutive same-direction candles that swept a confirmed swing,
  and the delivery level is taken from the opening price of the FIRST candle in
  that series - the price at which the raid began. The confirmed zone then covers
  the entire high-to-low range of the series rather than one candle's body.

- Opposing CISD setups cannot both survive. Confirming one direction cancels the
  pending setup on the other side, and an optional conflict window removes a
  preceding opposite CISD when a new one confirms immediately behind it. The
  chart never shows two contradictory claims on the same move.

- FVGs and Order Blocks have a full lifecycle rather than a binary valid/invalid
  state: mitigation, inversion or breaker conversion, then a second invalidation
  that removes them. An inverted FVG restarts its mitigation clock from the
  inversion bar so it can be re-tested in its new role.


HOW EACH ENGINE WORKS

Higher timeframe and session levels

The script requests the high and low of the previous COMPLETED 1H and 4H candle,
and tracks the high and low of each COMPLETED Asian, London and New York session.
Session windows and the session timezone are user-configurable; the timezone
defaults to the exchange timezone so levels stay correct across instruments.
These levels are the pools that the sweep engine tests against.

Liquidity sweeps

A sweep is marked only when a single candle wicks through a reference level and
closes back on its origin side:

  Bearish - open below the level, high above it, close back below it
  Bullish - open above the level, low below it, close back above it

The invalidation and first-sweep-only filters described above then decide whether
the event is drawn. Confirmed sweeps print a LIQ SWEEP marker at the level.

Fair Value Gaps and Inverse Fair Value Gaps

Three-candle imbalances are detected on confirmed bars: bullish when the current
low is above the high two bars back, bearish when the current high is below the
low two bars back. Trading back into a zone marks it mitigated, and the box stops
extending. A close through the far side inverts the zone: it flips polarity, is
relabelled IFVG, and its mitigation clock restarts from the inversion bar. An
inverted zone that is invalidated a second time is removed.

Order Blocks and Breaker Blocks

Order Blocks are structure-confirmed rather than pattern-guessed. The script
tracks confirmed swing pivots; when price closes through an active swing high,
the most recent down-close candle before that break is stored as a bullish Order
Block, and the mirror applies for bearish. Each swing can be used only once, and
the source candle must sit within a configurable lookback of the break, so a
stale candle cannot be retro-fitted onto a much later structural move. A failed
Order Block can be converted into a Breaker Block: the zone flips polarity, is
relabelled BB, and becomes a retest area in the opposite direction. With breaker
conversion disabled, failed Order Blocks are removed instead.

CISD - Change In State Of Delivery

Building the setup. A bullish candidate begins when a down-close candle sweeps
liquidity below. With the swing sweep filter enabled (default) that means trading
below the most recent CONFIRMED swing low; with it disabled, simply taking the
previous candle's low. Consecutive down-close candles extend the same series, and
the delivery level is anchored to the opening price of the first candle in the
series. Bearish candidates mirror this with up-close candles sweeping a high.

Confirmation. While pending, a dotted line projects forward from the delivery
level. The CISD confirms when a bar CLOSES through that line - above it for
bullish, below it for bearish - within the configured lifetime. If no close
reclaims the level in time the setup expires and its pending line is removed
rather than left on the chart.

On confirmation the script draws the delivery line in the directional colour, a
+CISD or -CISD label, a zone covering the full range of the setup series, and a
coloured halo marking the sequence.

Dashboard. An optional table reports running bullish and bearish CISD counts for
the chart timeframe, current pending state, the most recent event and its bar,
glow status, and how many drawings are retained against the cap. A compact mode
reduces it to counts, last event and sequence status.

SMT divergence

Confirmed pivots on the chart symbol are compared against a correlated symbol.
Bullish SMT is flagged when the chart makes a lower low while the correlated
symbol holds above its prior pivot low; bearish SMT when the chart makes a higher
high while the correlated symbol fails to. An alignment setting caps how far
apart the two pivots may be in bars, so unrelated pivots are never paired.


HOW TO USE IT

The engines are meant to be read in sequence:

  1. Where is the liquidity? Read the higher timeframe and session levels.
  2. Has it been taken? Wait for a LIQ SWEEP marker, or for a CISD setup series
     to sweep a confirmed swing.
  3. Has delivery changed? A confirmed +CISD or -CISD after that raid is the
     signal that the sweep was a reversal rather than continuation. The CISD zone
     marks the range of the candles that did the sweeping.
  4. Where would you engage? Use the FVG, IFVG, Order Block and Breaker zones
     left behind by the resulting displacement as the retracement areas.
  5. Confluence. An SMT divergence aligned with the same raid, or a glow-marked
     CISD sequence, adds weight to the read.

Suggested starting values for CISD Lifetime, the number of bars a pending setup
stays valid: 1m 10-20, 5m 12-24, 15m 8-16, 1H 4-8, 4H 3-6, Daily 3-5. Increase it
if setups expire just before they would have confirmed; decrease it if stale
pending lines linger.

Alerts are available for a confirmed bullish CISD, a confirmed bearish CISD,
either direction, and for the bullish and bearish glow sequences.


SETTINGS

HTF & Liquidity - toggles for HTF levels, session levels and sweeps; the three
session windows and their timezone; level projection length; maximum retained
sweep drawings.

FVG - display toggle, forward extension, maximum retained zones.

Order Blocks - display toggle, breaker conversion toggle, source-candle lookback,
forward extension, maximum retained zones.

CISD - display toggle, lifetime, forward extension, swing sweep filter and its
pivot length, conflict window, and full visual control over labels, pending
lines, zones, transparency, line width and style, colours, glow width, colour and
transparency, drawing cap, alert toggles, and dashboard position, text size and
compact mode.

SMT - correlated symbol, display toggle, pivot length, alignment tolerance,
maximum retained drawings.


LIMITATIONS AND DISCLAIMER

Higher timeframe levels are taken from the previous completed candle, so they are
stable on the chart timeframe. Session levels appear only after the session has
closed.

Swing pivots require bars on both sides before they confirm, so the features that
depend on structure - Order Blocks, the CISD swing sweep filter and SMT - confirm
with the natural lag of pivot detection. This is inherent to pivot logic.

SMT requires the correlated symbol to be genuinely correlated and available on
your data subscription. Pairing unrelated instruments produces meaningless
divergences.

Drawing counts are capped by the maximum settings in each group; the oldest
drawings are removed as new ones form. Very low caps on a busy chart will discard
history quickly.

This script is an analysis and visualisation tool. It is not a signal service and
it does not generate orders. It highlights context and confirmation; entry, stop,
target and position sizing decisions remain entirely with the trader. Nothing
here is financial advice, and the historical behaviour of any pattern does not
guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("SMC Pro: Strategy & Liquidity", "SMC Pro", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, calc_bars_count = 5000)

// --- Inputs ---
string HTF = "HTF & Liquidity"
string FVG = "FVG"
string OB = "Order Blocks"
string CISD = "CISD"
string SMT = "SMT"
showHtf = input.bool(true, "Show HTF Levels", group = HTF, tooltip = "Show previous confirmed 1H and 4H levels.")
showSessions = input.bool(true, "Show Session Levels", group = HTF, tooltip = "Show completed Asian, London, and New York levels.")
showSweeps = input.bool(true, "Show Liquidity Sweeps", group = HTF, tooltip = "Show confirmed wick-through-and-close-back sweeps.")
asianSession = input.session("1900-0000", "Asian Session", group = HTF, tooltip = "Asian session range.")
londonSession = input.session("0300-1100", "London Session", group = HTF, tooltip = "London session range.")
nySession = input.session("0800-1700", "New York Session", group = HTF, tooltip = "New York session range.")
timezoneInput = input.string("Exchange", "Session Timezone", options = ["Exchange", "Etc/UTC", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group = HTF, tooltip = "Session timezone.")
levelLength = input.int(100, "Level Length", minval = 1, maxval = 500, group = HTF, tooltip = "Level projection length.")
maxSweepCount = input.int(100, "Maximum Sweeps", minval = 1, maxval = 500, group = HTF, tooltip = "Maximum retained sweep drawings.")
showFvg = input.bool(true, "Show FVG / IFVG", group = FVG, tooltip = "Display fair value gaps and inversions.")
fvgExtension = input.int(5, "FVG Extension", minval = 0, maxval = 500, group = FVG, tooltip = "Forward FVG extension.")
maxFvgCount = input.int(50, "Maximum FVG Zones", minval = 1, maxval = 100, group = FVG, tooltip = "Maximum retained FVG zones.")
showOb = input.bool(true, "Show Order Blocks", inline = "obDisplay", group = OB, tooltip = "Display structure-confirmed order blocks.")
showBreakers = input.bool(true, "Show Breakers", inline = "obDisplay", group = OB, tooltip = "Convert invalidated order blocks into breaker blocks and display them.")
obLookback = input.int(20, "OB Source Lookback", minval = 1, maxval = 100, group = OB, tooltip = "Maximum source-candle distance.")
obExtension = input.int(20, "OB Extension", minval = 1, maxval = 500, group = OB, tooltip = "Forward OB extension.")
maxObCount = input.int(25, "Maximum OB Zones", minval = 1, maxval = 100, group = OB, tooltip = "Maximum retained OBs and breakers.")
showCisd = input.bool(true, "Show CISD", group = CISD, tooltip = "Show chart-timeframe CISD transitions.")
cisdLength = input.int(20, "CISD Lifetime", minval = 1, maxval = 500, group = CISD, tooltip = "Number of chart bars from the first swept series candle that a pending CISD can remain valid. Starting guide: 1m = 10-20, 5m = 12-24, 15m = 8-16, 1H = 4-8, 4H = 3-6, Daily = 3-5. Increase if setups expire too early; decrease if stale pending lines persist.")
cisdForward = input.int(0, "CISD Forward Extension", minval = 0, maxval = 500, group = CISD, tooltip = "Number of bars to project a confirmed CISD line and label beyond the confirmation bar. Zero ends them on the confirmation bar.")
useCisdSwingSweepFilter = input.bool(true, "Use CISD Swing High/Low Sweep Filter", group = CISD, tooltip = "Require a down-close candle to sweep the latest confirmed swing low, or an up-close candle to sweep the latest confirmed swing high, before starting a CISD series. Enabled by default for structural CISD identification.")
cisdSweepPivotLength = input.int(3, "CISD Sweep Pivot Length", minval = 1, maxval = 20, active = useCisdSwingSweepFilter, group = CISD, tooltip = "Confirmed swing pivot length for CISD sweeps. The default value of 3 requires three bars on each side of the pivot.")
cisdConflictWindow = input.int(5, "CISD Conflict Window", minval = 1, maxval = 100, active = not useCisdSwingSweepFilter, group = CISD, tooltip = "When the swing sweep filter is disabled, an opposite confirmed CISD within this many bars replaces the preceding CISD. The newest confirmed CISD always wins.")
showCisdLabels = input.bool(true, "Show CISD Labels", group = CISD, tooltip = "Display labels for confirmed chart and HTF CISD events.")
showCisdPendingLines = input.bool(true, "Show Pending CISD Lines", group = CISD, tooltip = "Display delivery lines while a CISD setup is awaiting confirmation.")
showCisdZones = input.bool(true, "Show CISD Zones", group = CISD, tooltip = "Highlight the setup candle range for confirmed CISD events.")
extendCisdZones = input.bool(true, "Extend CISD Zones", group = CISD, tooltip = "Extend confirmed CISD zones to the line endpoint.")
cisdZoneTransparency = input.int(88, "CISD Zone Transparency", minval = 0, maxval = 100, group = CISD, tooltip = "Transparency of bullish and bearish CISD zones.")
cisdZoneBorderTransparency = input.int(100, "CISD Zone Border Transparency", minval = 0, maxval = 100, group = CISD, tooltip = "Transparency of CISD zone borders.")
cisdLineWidth = input.int(1, "CISD Line Width", minval = 1, maxval = 4, group = CISD, tooltip = "Width of pending and confirmed CISD lines.")
cisdLineStyleInput = input.string("Solid", "CISD Line Style", options = ["Solid", "Dashed", "Dotted"], group = CISD, tooltip = "Style of confirmed CISD delivery lines.")
cisdPendingColor = input.color(#808080, "Pending CISD Color", group = CISD, tooltip = "Color of unconfirmed pending CISD lines. Pending lines always use a dotted style to distinguish them from confirmed CISD lines.")
cisdLabelSizeInput = input.string("Small", "CISD Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = CISD, tooltip = "Size of CISD labels.")
cisdLabelStyleInput = input.string("Left", "CISD Label Anchor", options = ["Left", "Right", "Center", "Up", "Down", "None"], group = CISD, tooltip = "Anchor style for confirmed CISD labels.")
cisdBullColor = input.color(#089981, "Bullish CISD Color", group = CISD, tooltip = "Color for bullish CISD lines, labels, and zones.")
cisdBearColor = input.color(#f23645, "Bearish CISD Color", group = CISD, tooltip = "Color for bearish CISD lines, labels, and zones.")
maxCisdVisuals = input.int(100, "Maximum CISD Visuals", minval = 1, maxval = 500, group = CISD, tooltip = "Maximum retained confirmed CISD labels, lines, and zones.")
cisdGlowWidth = input.int(4, "CISD Glow Width", minval = 2, maxval = 8, group = CISD, tooltip = "Width of the halo behind every confirmed CISD line.")
cisdGlowBullColor = input.color(#5b9cf6, "Bullish CISD Glow Color", group = CISD, tooltip = "Color of the halo behind a confirmed bullish CISD line.")
cisdGlowBearColor = input.color(#f23645, "Bearish CISD Glow Color", group = CISD, tooltip = "Color of the halo behind a confirmed bearish CISD line.")
cisdGlowTransparency = input.int(65, "CISD Glow Transparency", minval = 0, maxval = 100, group = CISD, tooltip = "Transparency of the halo behind confirmed CISD lines.")
alertCisdChart = input.bool(true, "Alert Chart CISD", group = CISD, tooltip = "Enable chart-timeframe CISD alert conditions.")
alertCisdGlow = input.bool(true, "Alert CISD Glow", group = CISD, tooltip = "Enable alert conditions when a same-direction CISD glow event occurs.")
showCisdDashboard = input.bool(true, "Show CISD Dashboard", group = CISD, tooltip = "Display chart-timeframe CISD counts, pending state, latest event, and glow status.")
cisdDashboardPosition = input.string("Top Right", "CISD Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = CISD, tooltip = "Chart position of the CISD dashboard.")
cisdDashboardBackgroundColor = input.color(color.new(#1e222d, 10), "CISD Dashboard Background", group = CISD, tooltip = "Background color and transparency for the CISD dashboard.")
cisdDashboardTextSizeInput = input.string("Small", "CISD Dashboard Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = CISD, tooltip = "Text size used in every CISD dashboard cell.")
cisdDashboardCompact = input.bool(false, "Compact Dashboard View", group = CISD, tooltip = "Show only the dashboard header, chart CISD counts, latest event, and sequence status.")
smtSymbol = input.symbol("CME_MINI:ES1!", "SMT Symbol", group = SMT, tooltip = "Correlated symbol.")
showSmt = input.bool(true, "Show SMT", group = SMT, tooltip = "Show confirmed pivot divergence.")
smtLength = input.int(3, "SMT Pivot Length", minval = 1, maxval = 20, group = SMT, tooltip = "Pivot confirmation length.")
smtAlignment = input.int(10, "SMT Alignment", minval = 1, maxval = 100, group = SMT, tooltip = "Maximum pivot alignment distance.")
maxSmtCount = input.int(100, "Maximum SMT Drawings", minval = 1, maxval = 500, group = SMT, tooltip = "Maximum retained SMT drawings.")

// --- Constants and Types ---
color BULL = #089981
color BEAR = #f23645
color BLUE = #5b9cf6
int MAX_FORWARD = 500

type Zone
    int startBar
    int createdBar
    float top
    float bottom
    bool bullish
    bool inverted
    bool mitigated
    int inversionBar
    box zoneBox

type Block
    int startBar
    int createdBar
    float top
    float bottom
    bool bullish
    bool breaker
    bool mitigated
    int breakerBar
    box zoneBox
    line zoneLine

type Drawing
    float level
    int startBar
    bool upper
    line levelLine
    label levelLabel

type Pending
    int startBar
    float level
    bool active
    line levelLine
    float setupTop
    float setupBottom

type CisdVisual
    line eventLine
    label eventLabel
    box eventZone
    bool bullish

f_cisd_line_style(string styleInput) =>
    switch styleInput
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_cisd_label_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

f_cisd_label_style(string styleInput) =>
    switch styleInput
        "Right" => label.style_label_right
        "Center" => label.style_label_center
        "Up" => label.style_label_up
        "Down" => label.style_label_down
        "None" => label.style_none
        => label.style_label_left

f_cisd_dashboard_position(string positionInput) =>
    switch positionInput
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_cisd_dashboard_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

var array<CisdVisual> cisdVisuals = array.new<CisdVisual>()
var array<line> cisdGlowLines = array.new<line>()
var int lastChartCisdBar = na
var bool lastChartCisdBullish = false
var line lastChartCisdLine = na
var line lastChartCisdGlowLine = na
var label lastChartCisdLabel = na
var box lastChartCisdZone = na
var bool cisdGlowCurrent = false
var table cisdDashboard = table.new(f_cisd_dashboard_position(cisdDashboardPosition), 3, 9, bgcolor = cisdDashboardBackgroundColor, frame_color = color.new(chart.fg_color, 30), frame_width = 1, border_color = color.new(chart.fg_color, 80), border_width = 1)
var int chartBullCisdCount = 0
var int chartBearCisdCount = 0

f_delete_cisd_visual(CisdVisual item) =>
    if not na(item.eventLine)
        line.delete(item.eventLine)
    if not na(item.eventLabel)
        label.delete(item.eventLabel)
    if not na(item.eventZone)
        box.delete(item.eventZone)

f_store_cisd_visual(Pending pending, bool bullish, int confirmationBar) =>
    color eventColor = bullish ? cisdBullColor : cisdBearColor
    string eventText = bullish ? "+CISD" : "-CISD"
    int endBar = confirmationBar + cisdForward
    line.set_x2(pending.levelLine, endBar)
    line.set_color(pending.levelLine, eventColor)
    line.set_style(pending.levelLine, f_cisd_line_style(cisdLineStyleInput))
    line.set_width(pending.levelLine, cisdLineWidth)
    line glowLine = na
    if cisdGlowCurrent
        glowLine := line.new(pending.startBar, pending.level, endBar, pending.level, xloc = xloc.bar_index, color = color.new(bullish ? cisdGlowBullColor : cisdGlowBearColor, cisdGlowTransparency), style = f_cisd_line_style(cisdLineStyleInput), width = cisdGlowWidth)
    label eventLabel = na
    if showCisdLabels and barstate.isconfirmed
        eventLabel := label.new(endBar, pending.level, eventText, xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, textcolor = eventColor, style = f_cisd_label_style(cisdLabelStyleInput), size = f_cisd_label_size(cisdLabelSizeInput))
    box eventZone = na
    if showCisdZones
        int zoneRight = extendCisdZones ? endBar : confirmationBar
        eventZone := box.new(pending.startBar, pending.setupTop, zoneRight, pending.setupBottom, border_color = color.new(eventColor, cisdZoneBorderTransparency), bgcolor = color.new(eventColor, cisdZoneTransparency))
    array.push(cisdVisuals, CisdVisual.new(pending.levelLine, eventLabel, eventZone, bullish))
    array.push(cisdGlowLines, glowLine)
    while array.size(cisdVisuals) > maxCisdVisuals
        CisdVisual oldVisual = array.shift(cisdVisuals)
        line oldGlowLine = array.shift(cisdGlowLines)
        f_delete_cisd_visual(oldVisual)
        if not na(oldGlowLine)
            line.delete(oldGlowLine)
    [eventLabel, eventZone]

f_delete_zone(Zone item) =>
    if not na(item.zoneBox)
        box.delete(item.zoneBox)

f_delete_block(Block item) =>
    if not na(item.zoneBox)
        box.delete(item.zoneBox)
    if not na(item.zoneLine)
        line.delete(item.zoneLine)

f_delete_drawing(Drawing item) =>
    if not na(item.levelLine)
        line.delete(item.levelLine)
    if not na(item.levelLabel)
        label.delete(item.levelLabel)

f_session(string sessionInput, string timezone) =>
    var float runningHigh = na
    var float runningLow = na
    var float completedHigh = na
    var float completedLow = na
    bool active = not na(time(timeframe.period, sessionInput, timezone))
    bool previousActive = bar_index > 0 and active[1]
    if active and not previousActive
        runningHigh := high
        runningLow := low
    else if active
        runningHigh := math.max(nz(runningHigh, high), high)
        runningLow := math.min(nz(runningLow, low), low)
    else if previousActive
        completedHigh := runningHigh
        completedLow := runningLow
    [completedHigh, completedLow]

var array<Zone> zones = array.new<Zone>()
var array<Block> blocks = array.new<Block>()
var array<Drawing> drawings = array.new<Drawing>()
var array<line> smtLines = array.new<line>()
var array<label> smtLabels = array.new<label>()
var array<int> zoneRemovals = array.new_int()
var array<int> blockRemovals = array.new_int()
var Pending bearPending = Pending.new(na, na, false, na, na, na)
var Pending bullPending = Pending.new(na, na, false, na, na, na)
var int bearSeriesLastBar = na
var int bullSeriesLastBar = na

// --- Confirmed Reference Levels ---
string sessionTimezone = timezoneInput == "Exchange" ? syminfo.timezone : timezoneInput
[h1HighRaw, h1LowRaw] = request.security(syminfo.tickerid, "60", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[h4HighRaw, h4LowRaw] = request.security(syminfo.tickerid, "240", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[asianHigh, asianLow] = f_session(asianSession, sessionTimezone)
[londonHigh, londonLow] = f_session(londonSession, sessionTimezone)
[nyHigh, nyLow] = f_session(nySession, sessionTimezone)

// --- Level and Sweep Engine ---
var bool highInvalid = false
var bool lowInvalid = false
var bool highSeen = false
var bool lowSeen = false
bool newReference = timeframe.change("60") or timeframe.change("240") or (not na(asianHigh) and asianHigh != asianHigh[1]) or (not na(londonHigh) and londonHigh != londonHigh[1]) or (not na(nyHigh) and nyHigh != nyHigh[1])
if newReference
    highInvalid := false
    lowInvalid := false
    highSeen := false
    lowSeen := false
f_invalid(float level, bool upper, bool state) =>
    na(level) ? state : state or (upper ? close > level : close < level)
highInvalid := f_invalid(h1HighRaw, true, highInvalid)
highInvalid := f_invalid(h4HighRaw, true, highInvalid)
highInvalid := f_invalid(asianHigh, true, highInvalid)
highInvalid := f_invalid(londonHigh, true, highInvalid)
highInvalid := f_invalid(nyHigh, true, highInvalid)
lowInvalid := f_invalid(h1LowRaw, false, lowInvalid)
lowInvalid := f_invalid(h4LowRaw, false, lowInvalid)
lowInvalid := f_invalid(asianLow, false, lowInvalid)
lowInvalid := f_invalid(londonLow, false, lowInvalid)
lowInvalid := f_invalid(nyLow, false, lowInvalid)
f_sweep(float level, bool invalid, bool upper) =>
    upper ? not invalid and not na(level) and open < level and high > level and close < level : not invalid and not na(level) and open > level and low < level and close > level
bool bearishSweep = barstate.isconfirmed and not highSeen and (f_sweep(h1HighRaw, highInvalid, true) or f_sweep(h4HighRaw, highInvalid, true) or f_sweep(asianHigh, highInvalid, true) or f_sweep(londonHigh, highInvalid, true) or f_sweep(nyHigh, highInvalid, true))
bool bullishSweep = barstate.isconfirmed and not lowSeen and (f_sweep(h1LowRaw, lowInvalid, false) or f_sweep(h4LowRaw, lowInvalid, false) or f_sweep(asianLow, lowInvalid, false) or f_sweep(londonLow, lowInvalid, false) or f_sweep(nyLow, lowInvalid, false))
float bearishLevel = f_sweep(h1HighRaw, highInvalid, true) ? h1HighRaw : f_sweep(h4HighRaw, highInvalid, true) ? h4HighRaw : f_sweep(asianHigh, highInvalid, true) ? asianHigh : f_sweep(londonHigh, highInvalid, true) ? londonHigh : nyHigh
float bullishLevel = f_sweep(h1LowRaw, lowInvalid, false) ? h1LowRaw : f_sweep(h4LowRaw, lowInvalid, false) ? h4LowRaw : f_sweep(asianLow, lowInvalid, false) ? asianLow : f_sweep(londonLow, lowInvalid, false) ? londonLow : nyLow
if bearishSweep
    highSeen := true
    if showSweeps
        line itemLine = line.new(bar_index, bearishLevel, bar_index + 2, bearishLevel, color = BEAR, style = line.style_dotted)
        label itemLabel = label.new(math.min(bar_index + 3, bar_index + MAX_FORWARD), bearishLevel, "LIQ SWEEP", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, textcolor = BEAR, style = label.style_label_left, size = size.tiny)
        array.push(drawings, Drawing.new(bearishLevel, bar_index, true, itemLine, itemLabel))
if bullishSweep
    lowSeen := true
    if showSweeps
        line itemLine = line.new(bar_index, bullishLevel, bar_index + 2, bullishLevel, color = BULL, style = line.style_dotted)
        label itemLabel = label.new(math.min(bar_index + 3, bar_index + MAX_FORWARD), bullishLevel, "LIQ SWEEP", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, textcolor = BULL, style = label.style_label_left, size = size.tiny)
        array.push(drawings, Drawing.new(bullishLevel, bar_index, false, itemLine, itemLabel))
while array.size(drawings) > maxSweepCount
    Drawing oldDrawing = array.shift(drawings)
    f_delete_drawing(oldDrawing)

// --- FVG Engine ---
array.clear(zoneRemovals)
if barstate.isconfirmed and bar_index >= 2 and low > high[2]
    array.push(zones, Zone.new(bar_index - 2, bar_index, low, high[2], true, false, false, na, na))
if barstate.isconfirmed and bar_index >= 2 and high < low[2]
    array.push(zones, Zone.new(bar_index - 2, bar_index, low[2], high, false, false, false, na, na))
while array.size(zones) > maxFvgCount
    Zone oldZone = array.shift(zones)
    f_delete_zone(oldZone)
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        Zone item = array.get(zones, i)
        bool overlap = high >= item.bottom and low <= item.top
        bool invalid = item.bullish ? close < item.bottom : close > item.top
        bool inverseInvalid = item.bullish ? close > item.top : close < item.bottom
        int activation = item.inverted ? item.inversionBar : item.createdBar
        if barstate.isconfirmed and bar_index > activation and overlap and not item.mitigated
            item.mitigated := true
            if item.inverted
                array.push(zoneRemovals, i)
        if barstate.isconfirmed and not item.inverted and invalid
            item.inverted := true
            item.inversionBar := bar_index
            item.mitigated := false
        else if barstate.isconfirmed and item.inverted and inverseInvalid and not item.mitigated
            array.push(zoneRemovals, i)
        if showFvg
            color itemColor = item.inverted ? (item.bullish ? BEAR : BULL) : (item.bullish ? BULL : BEAR)
            int rightBar = item.mitigated ? bar_index : bar_index + fvgExtension
            if na(item.zoneBox)
                item.zoneBox := box.new(item.startBar, item.top, rightBar, item.bottom, border_color = color.new(itemColor, 100), bgcolor = color.new(itemColor, item.mitigated ? 94 : 90), text = item.inverted ? "IFVG" : "FVG", text_color = color.new(itemColor, 20), text_size = size.tiny)
            else
                box.set_right(item.zoneBox, rightBar)
                box.set_bgcolor(item.zoneBox, color.new(itemColor, item.mitigated ? 94 : 90))
                box.set_text(item.zoneBox, item.inverted ? "IFVG" : "FVG")
        else if not na(item.zoneBox)
            box.delete(item.zoneBox)
            item.zoneBox := na
        array.set(zones, i, item)
while array.size(zoneRemovals) > 0
    int removeIndex = array.pop(zoneRemovals)
    if removeIndex < array.size(zones)
        Zone removedZone = array.get(zones, removeIndex)
        f_delete_zone(removedZone)
        array.remove(zones, removeIndex)

// --- Order Block Engine ---
float swingHigh = ta.pivothigh(high, 3, 3)
float swingLow = ta.pivotlow(low, 3, 3)
var float activeSwingHigh = na
var float activeSwingLow = na
var bool swingHighUsed = false
var bool swingLowUsed = false
if not na(swingHigh)
    activeSwingHigh := swingHigh
    swingHighUsed := false
if not na(swingLow)
    activeSwingLow := swingLow
    swingLowUsed := false
float bearTop = ta.valuewhen(close[1] < open[1], high[1], 0)
float bearBottom = ta.valuewhen(close[1] < open[1], low[1], 0)
int bearSource = ta.valuewhen(close[1] < open[1], bar_index[1], 0)
float bullTop = ta.valuewhen(close[1] > open[1], high[1], 0)
float bullBottom = ta.valuewhen(close[1] > open[1], low[1], 0)
int bullSource = ta.valuewhen(close[1] > open[1], bar_index[1], 0)
bool bullishBreak = barstate.isconfirmed and not swingHighUsed and not na(activeSwingHigh) and close > activeSwingHigh
bool bearishBreak = barstate.isconfirmed and not swingLowUsed and not na(activeSwingLow) and close < activeSwingLow
if bullishBreak
    swingHighUsed := true
    if showOb and not na(bearSource) and bar_index - bearSource <= obLookback
        array.push(blocks, Block.new(bearSource, bar_index, bearTop, bearBottom, true, false, false, na, na, na))
if bearishBreak
    swingLowUsed := true
    if showOb and not na(bullSource) and bar_index - bullSource <= obLookback
        array.push(blocks, Block.new(bullSource, bar_index, bullTop, bullBottom, false, false, false, na, na, na))
while array.size(blocks) > maxObCount
    Block oldBlock = array.shift(blocks)
    f_delete_block(oldBlock)
array.clear(blockRemovals)
if array.size(blocks) > 0
    for i = 0 to array.size(blocks) - 1
        Block item = array.get(blocks, i)
        bool overlap = high >= item.bottom and low <= item.top
        bool invalid = item.bullish ? close < item.bottom : close > item.top
        if barstate.isconfirmed and bar_index > item.createdBar and overlap and not item.mitigated
            item.mitigated := true
            if item.breaker
                array.push(blockRemovals, i)
        if barstate.isconfirmed and not item.breaker and invalid
            if showBreakers
                item.breaker := true
                item.breakerBar := bar_index
                item.bullish := not item.bullish
                item.mitigated := false
            else
                array.push(blockRemovals, i)
        else if barstate.isconfirmed and item.breaker and invalid and not item.mitigated
            array.push(blockRemovals, i)
        if showOb
            color itemColor = item.bullish ? BULL : BEAR
            int rightBar = item.mitigated ? bar_index : bar_index + obExtension
            if na(item.zoneBox)
                item.zoneBox := box.new(item.startBar, item.top, rightBar, item.bottom, border_color = color.new(itemColor, 100), bgcolor = color.new(itemColor, item.breaker ? 84 : 88), text = item.breaker ? "BB" : "OB", text_color = color.new(itemColor, 15), text_size = size.tiny)
            else
                box.set_right(item.zoneBox, rightBar)
                box.set_bgcolor(item.zoneBox, color.new(itemColor, item.breaker ? 84 : 88))
                box.set_text(item.zoneBox, item.breaker ? "BB" : "OB")
        else
            f_delete_block(item)
            item.zoneBox := na
            item.zoneLine := na
        array.set(blocks, i, item)
while array.size(blockRemovals) > 0
    int removeIndex = array.pop(blockRemovals)
    if removeIndex < array.size(blocks)
        Block removedBlock = array.get(blocks, removeIndex)
        f_delete_block(removedBlock)
        array.remove(blocks, removeIndex)

// --- Chart CISD ---
float cisdPivotHigh = ta.pivothigh(high, cisdSweepPivotLength, cisdSweepPivotLength)
float cisdPivotLow = ta.pivotlow(low, cisdSweepPivotLength, cisdSweepPivotLength)
var float cisdLastSwingHigh = na
var float cisdLastSwingLow = na
if not na(cisdPivotHigh)
    cisdLastSwingHigh := cisdPivotHigh
if not na(cisdPivotLow)
    cisdLastSwingLow := cisdPivotLow
bool downCloseCandle = close < open
bool upCloseCandle = close > open
bool downCloseSweepsLow = downCloseCandle and (useCisdSwingSweepFilter ? not na(cisdLastSwingLow) and low < cisdLastSwingLow : low < low[1])
bool upCloseSweepsHigh = upCloseCandle and (useCisdSwingSweepFilter ? not na(cisdLastSwingHigh) and high > cisdLastSwingHigh : high > high[1])
bool downCloseSeries = downCloseCandle and bullPending.active and not na(bullSeriesLastBar) and bar_index == bullSeriesLastBar + 1
bool upCloseSeries = upCloseCandle and bearPending.active and not na(bearSeriesLastBar) and bar_index == bearSeriesLastBar + 1

// A bullish CISD candidate is built from a consecutive series of down-close candles that sweep lows.
if showCisd and (downCloseSweepsLow or downCloseSeries)
    if not bullPending.active or not downCloseSeries
        if not na(bullPending.levelLine)
            line.delete(bullPending.levelLine)
        bullPending := Pending.new(bar_index, open, true, line.new(bar_index, open, bar_index, open, color = showCisdPendingLines ? cisdPendingColor : #00000000, style = line.style_dotted, width = cisdLineWidth), high, low)
    else
        bullPending.setupTop := math.max(bullPending.setupTop, high)
        bullPending.setupBottom := math.min(bullPending.setupBottom, low)
    bullSeriesLastBar := bar_index

// A bearish CISD candidate is built from a consecutive series of up-close candles that sweep highs.
if showCisd and (upCloseSweepsHigh or upCloseSeries)
    if not bearPending.active or not upCloseSeries
        if not na(bearPending.levelLine)
            line.delete(bearPending.levelLine)
        bearPending := Pending.new(bar_index, open, true, line.new(bar_index, open, bar_index, open, color = showCisdPendingLines ? cisdPendingColor : #00000000, style = line.style_dotted, width = cisdLineWidth), high, low)
    else
        bearPending.setupTop := math.max(bearPending.setupTop, high)
        bearPending.setupBottom := math.min(bearPending.setupBottom, low)
    bearSeriesLastBar := bar_index
bool bullishCisd = false
bool bearishCisd = false
bool bullishCisdGlow = false
bool bearishCisdGlow = false
if showCisd and bearPending.active
    if bar_index - bearPending.startBar > cisdLength
        line.delete(bearPending.levelLine)
        bearPending := Pending.new(na, na, false, na, na, na)
        bearSeriesLastBar := na
    else
        line.set_x2(bearPending.levelLine, bar_index)
        line.set_style(bearPending.levelLine, line.style_dotted)
        line.set_color(bearPending.levelLine, showCisdPendingLines ? cisdPendingColor : #00000000)
        line.set_width(bearPending.levelLine, cisdLineWidth)
        if barstate.isconfirmed and close < bearPending.level
            cisdGlowCurrent := true
            bearishCisdGlow := true
            if bullPending.active and not na(bullPending.levelLine)
                line.delete(bullPending.levelLine)
            bullPending := Pending.new(na, na, false, na, na, na)
            bullSeriesLastBar := na
            bool conflictingCisd = not useCisdSwingSweepFilter and not na(lastChartCisdBar) and bar_index - lastChartCisdBar <= cisdConflictWindow and lastChartCisdBullish
            if conflictingCisd
                if array.size(cisdVisuals) > 0
                    CisdVisual previousVisual = array.pop(cisdVisuals)
                    line previousGlowLine = array.pop(cisdGlowLines)
                    f_delete_cisd_visual(previousVisual)
                    if not na(previousGlowLine)
                        line.delete(previousGlowLine)
                else
                    if not na(lastChartCisdLine)
                        line.delete(lastChartCisdLine)
                    if not na(lastChartCisdGlowLine)
                        line.delete(lastChartCisdGlowLine)
                    if not na(lastChartCisdLabel)
                        label.delete(lastChartCisdLabel)
                    if not na(lastChartCisdZone)
                        box.delete(lastChartCisdZone)
            [confirmedLabel, confirmedZone] = f_store_cisd_visual(bearPending, false, bar_index)
            lastChartCisdBar := bar_index
            lastChartCisdBullish := false
            lastChartCisdLine := bearPending.levelLine
            lastChartCisdGlowLine := array.size(cisdGlowLines) > 0 ? array.get(cisdGlowLines, array.size(cisdGlowLines) - 1) : na
            lastChartCisdLabel := confirmedLabel
            lastChartCisdZone := confirmedZone
            bearishCisd := true
            bearPending := Pending.new(na, na, false, na, na, na)
            bearSeriesLastBar := na
if showCisd and bullPending.active
    if bar_index - bullPending.startBar > cisdLength
        line.delete(bullPending.levelLine)
        bullPending := Pending.new(na, na, false, na, na, na)
        bullSeriesLastBar := na
    else
        line.set_x2(bullPending.levelLine, bar_index)
        line.set_style(bullPending.levelLine, line.style_dotted)
        line.set_color(bullPending.levelLine, showCisdPendingLines ? cisdPendingColor : #00000000)
        line.set_width(bullPending.levelLine, cisdLineWidth)
        if barstate.isconfirmed and close > bullPending.level
            cisdGlowCurrent := true
            bullishCisdGlow := true
            if bearPending.active and not na(bearPending.levelLine)
                line.delete(bearPending.levelLine)
            bearPending := Pending.new(na, na, false, na, na, na)
            bearSeriesLastBar := na
            bool conflictingCisd = not useCisdSwingSweepFilter and not na(lastChartCisdBar) and bar_index - lastChartCisdBar <= cisdConflictWindow and not lastChartCisdBullish
            if conflictingCisd
                if array.size(cisdVisuals) > 0
                    CisdVisual previousVisual = array.pop(cisdVisuals)
                    line previousGlowLine = array.pop(cisdGlowLines)
                    f_delete_cisd_visual(previousVisual)
                    if not na(previousGlowLine)
                        line.delete(previousGlowLine)
                else
                    if not na(lastChartCisdLine)
                        line.delete(lastChartCisdLine)
                    if not na(lastChartCisdGlowLine)
                        line.delete(lastChartCisdGlowLine)
                    if not na(lastChartCisdLabel)
                        label.delete(lastChartCisdLabel)
                    if not na(lastChartCisdZone)
                        box.delete(lastChartCisdZone)
            [confirmedLabel, confirmedZone] = f_store_cisd_visual(bullPending, true, bar_index)
            lastChartCisdBar := bar_index
            lastChartCisdBullish := true
            lastChartCisdLine := bullPending.levelLine
            lastChartCisdGlowLine := array.size(cisdGlowLines) > 0 ? array.get(cisdGlowLines, array.size(cisdGlowLines) - 1) : na
            lastChartCisdLabel := confirmedLabel
            lastChartCisdZone := confirmedZone
            bullishCisd := true
            bullPending := Pending.new(na, na, false, na, na, na)
            bullSeriesLastBar := na
while array.size(cisdVisuals) > maxCisdVisuals
    CisdVisual oldCisdVisual = array.shift(cisdVisuals)
    line oldGlowLine = array.shift(cisdGlowLines)
    f_delete_cisd_visual(oldCisdVisual)
    if not na(oldGlowLine)
        line.delete(oldGlowLine)
if bullishCisd
    chartBullCisdCount += 1
if bearishCisd
    chartBearCisdCount += 1
alertcondition(alertCisdChart and bullishCisd, "+CISD Chart", "Bullish +CISD confirmed on {{ticker}} {{interval}}")
alertcondition(alertCisdChart and bearishCisd, "-CISD Chart", "Bearish -CISD confirmed on {{ticker}} {{interval}}")
alertcondition(alertCisdGlow and bullishCisdGlow, "+CISD Glow", "Bullish CISD glow sequence confirmed on {{ticker}} {{interval}}")
alertcondition(alertCisdGlow and bearishCisdGlow, "-CISD Glow", "Bearish CISD glow sequence confirmed on {{ticker}} {{interval}}")
alertcondition(alertCisdChart and (bullishCisd or bearishCisd), "Any Chart CISD", "Chart CISD confirmed on {{ticker}} {{interval}}")

// --- CISD Dashboard ---
if barstate.islast
    if showCisdDashboard
        color dashboardHeader = color.new(BLUE, 75)
        color dashboardBackground = cisdDashboardBackgroundColor
        string lastEventText = na(lastChartCisdBar) ? "n/a" : (lastChartCisdBullish ? "+CISD" : "-CISD") + " @ " + str.tostring(lastChartCisdBar)
        dashboardTextSize = f_cisd_dashboard_text_size(cisdDashboardTextSizeInput)
        string sequenceModeText = "Confirmed CISD"
        string pendingText = (bullPending.active ? "+ pending" : "") + (bullPending.active and bearPending.active ? " / " : "") + (bearPending.active ? "- pending" : not bullPending.active ? "None" : "")
        table.set_bgcolor(cisdDashboard, dashboardBackground)
        table.cell(cisdDashboard, 0, 0, "CISD Dashboard", text_color = chart.fg_color, bgcolor = dashboardHeader, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 1, 0, "Bullish", text_color = cisdBullColor, bgcolor = dashboardHeader, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 2, 0, "Bearish", text_color = cisdBearColor, bgcolor = dashboardHeader, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 0, 1, "Chart " + timeframe.period, text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 1, 1, str.tostring(chartBullCisdCount), text_color = cisdBullColor, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 2, 1, str.tostring(chartBearCisdCount), text_color = cisdBearColor, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 0, 2, "Last Event", text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 1, 2, lastEventText, text_color = lastChartCisdBullish ? cisdBullColor : cisdBearColor, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 2, 2, cisdGlowCurrent ? "Glow" : "Normal", text_color = cisdGlowCurrent ? (lastChartCisdBullish ? cisdGlowBullColor : cisdGlowBearColor) : chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 0, 3, "Sequence", text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 1, 3, sequenceModeText, text_color = BLUE, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 2, 3, cisdGlowCurrent ? "Glow" : "Normal", text_color = cisdGlowCurrent ? (lastChartCisdBullish ? cisdGlowBullColor : cisdGlowBearColor) : chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 0, 4, "Pending", text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 1, 4, pendingText, text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 2, 4, showCisd ? "Enabled" : "Disabled", text_color = showCisd ? BLUE : color.gray, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 0, 5, "Visuals", text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 1, 5, str.tostring(array.size(cisdVisuals)), text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 2, 5, "Max " + str.tostring(maxCisdVisuals), text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 0, 6, "Glow Colors", text_color = chart.fg_color, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 1, 6, "+", text_color = cisdGlowBullColor, text_size = dashboardTextSize)
        table.cell(cisdDashboard, 2, 6, "-", text_color = cisdGlowBearColor, text_size = dashboardTextSize)
        if cisdDashboardCompact
            table.clear(cisdDashboard, 0, 0, 2, 8)
            table.cell(cisdDashboard, 0, 0, "CISD", text_color = chart.fg_color, bgcolor = dashboardHeader, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 1, 0, "+", text_color = cisdBullColor, bgcolor = dashboardHeader, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 2, 0, "-", text_color = cisdBearColor, bgcolor = dashboardHeader, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 0, 1, "Chart", text_color = chart.fg_color, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 1, 1, str.tostring(chartBullCisdCount), text_color = cisdBullColor, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 2, 1, str.tostring(chartBearCisdCount), text_color = cisdBearColor, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 0, 2, "Last", text_color = chart.fg_color, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 1, 2, lastEventText, text_color = lastChartCisdBullish ? cisdBullColor : cisdBearColor, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 2, 2, cisdGlowCurrent ? "Glow" : "Normal", text_color = cisdGlowCurrent ? (lastChartCisdBullish ? cisdGlowBullColor : cisdGlowBearColor) : chart.fg_color, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 0, 3, "Sequence", text_color = chart.fg_color, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 1, 3, sequenceModeText, text_color = BLUE, text_size = dashboardTextSize)
            table.cell(cisdDashboard, 2, 3, cisdGlowCurrent ? "Glow" : "Normal", text_color = cisdGlowCurrent ? (lastChartCisdBullish ? cisdGlowBullColor : cisdGlowBearColor) : chart.fg_color, text_size = dashboardTextSize)
    else
        table.clear(cisdDashboard, 0, 0, 2, 8)

// --- SMT ---
float localHigh = ta.pivothigh(high, smtLength, smtLength)
float localLow = ta.pivotlow(low, smtLength, smtLength)
var int lastHighBar = na
var float lastHighPrice = na
var int lastLowBar = na
var float lastLowPrice = na
var bool highConsumed = false
var bool lowConsumed = false
if not na(localHigh)
    lastHighBar := bar_index - smtLength
    lastHighPrice := localHigh
    highConsumed := false
if not na(localLow)
    lastLowBar := bar_index - smtLength
    lastLowPrice := localLow
    lowConsumed := false
float correlatedHighPivot = request.security(smtSymbol, timeframe.period, ta.pivothigh(high, smtLength, smtLength), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float correlatedLowPivot = request.security(smtSymbol, timeframe.period, ta.pivotlow(low, smtLength, smtLength), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float correlatedHigh = request.security(smtSymbol, timeframe.period, high, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float correlatedLow = request.security(smtSymbol, timeframe.period, low, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float priorCorrelatedHigh = ta.valuewhen(not na(correlatedHighPivot), correlatedHighPivot, 1)
float priorCorrelatedLow = ta.valuewhen(not na(correlatedLowPivot), correlatedLowPivot, 1)
int correlatedHighBar = ta.valuewhen(not na(correlatedHighPivot), bar_index - smtLength, 0)
int correlatedLowBar = ta.valuewhen(not na(correlatedLowPivot), bar_index - smtLength, 0)
int highDistance = not na(lastHighBar) and not na(correlatedHighBar) ? math.abs(lastHighBar - correlatedHighBar) : na
int lowDistance = not na(lastLowBar) and not na(correlatedLowBar) ? math.abs(lastLowBar - correlatedLowBar) : na
bool bullishSmt = barstate.isconfirmed and showSmt and not lowConsumed and not na(lastLowPrice) and not na(priorCorrelatedLow) and not na(correlatedLow) and not na(lowDistance) and lowDistance <= smtAlignment and low < lastLowPrice and correlatedLow > priorCorrelatedLow
bool bearishSmt = barstate.isconfirmed and showSmt and not highConsumed and not na(lastHighPrice) and not na(priorCorrelatedHigh) and not na(correlatedHigh) and not na(highDistance) and highDistance <= smtAlignment and high > lastHighPrice and correlatedHigh < priorCorrelatedHigh
if bullishSmt
    line smtLine = line.new(lastLowBar, lastLowPrice, bar_index, low, color = BULL)
    label smtLabel = label.new(math.floor((lastLowBar + bar_index) / 2), math.avg(lastLowPrice, low), "SMT", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, textcolor = BULL, style = label.style_label_center, size = size.tiny)
    array.push(smtLines, smtLine)
    array.push(smtLabels, smtLabel)
if bearishSmt
    line smtLine = line.new(lastHighBar, lastHighPrice, bar_index, high, color = BEAR)
    label smtLabel = label.new(math.floor((lastHighBar + bar_index) / 2), math.avg(lastHighPrice, high), "SMT", xloc = xloc.bar_index, yloc = yloc.price, color = #00000000, textcolor = BEAR, style = label.style_label_center, size = size.tiny)
    array.push(smtLines, smtLine)
    array.push(smtLabels, smtLabel)
while array.size(smtLines) > maxSmtCount
    line oldLine = array.shift(smtLines)
    label oldLabel = array.shift(smtLabels)
    line.delete(oldLine)
    label.delete(oldLabel)
if not na(lastLowPrice) and low < lastLowPrice
    lowConsumed := true
if not na(lastHighPrice) and high > lastHighPrice
    highConsumed := true
````
