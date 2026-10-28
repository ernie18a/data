# Universal MTF Pulse v2.0.1

- url: https://www.tradingview.com/script/M2kzQAzq-Universal-MTF-Pulse-v2-0-1/
- type: indicator
- pine_id: PUB;8193ebfeecbc4d539b005cacb177169e
- version: 1.0

## Description

Universal MTF Pulse is a descriptive, five-timeframe view of trend, price movement, and trading activity. It lets you compare the latest completed 1D, 4H, 1H, 15m, and 5m candles without treating those readings as five independent votes or as a trading signal. It places no orders and provides no entries, exits, or alerts.

HOW THE READINGS ARE CALCULATED
• Trend: Up requires the source close above EMA50 and EMA50 above its value three source candles earlier. Down requires both relationships to be below; all other valid combinations are Mixed. This needs at least 53 source candles.
• Momentum: (source close − close three source candles earlier) / source ATR14. A reading of +1.0 means a three-candle net rise equal to one ATR. “Turning up/down” marks a change across zero beyond the flat band of 0.15 ATR. “Building/easing” compares the magnitude of consecutive ATR-normalized readings; a change in ATR can affect it, so it is not pure price acceleration.
• Activity: the completed source candle’s volume divided by the mean volume of the preceding 20 source candles, excluding the candle being measured. Below 0.8× is Quiet, 0.8–<1.5× Usual, 1.5–<2.5× Elevated, and 2.5× or more Surge. These are descriptive thresholds, not probabilities. Missing volume or an invalid baseline gives N/A.
• Three-bar path efficiency: absolute net close change divided by the sum of the three absolute close-to-close changes. A one-directional path is 100%; a round trip or valid flat path is 0%. It ignores movement inside each candle and is not a probability. The exact value is available in the Data Window and event tooltips.

HOW TO READ THE DISPLAY
The optional dashboard, off by default, can show each timeframe’s most recent closed source candle, its UTC close time, trend, momentum, and activity. It is a latest snapshot, not a crosshair readout. The lower pane’s wave shows momentum for the chart timeframe on confirmed chart candles. It is visually capped at ±3 ATR by default; clipped samples are marked and the uncapped number remains in the Data Window. The activity strip and five trend strips are categorical lanes; their vertical positions are not ATR values. Broader-timeframe strips are thicker by default, but width is customizable and does not indicate confidence. On a chart timeframe broader than a source timeframe, historical lower-timeframe states are sampled at chart closes rather than showing every intrabar change.

Optional triangles mark a momentum turn, dots the onset of Elevated-or-higher activity, and diamonds the onset of a Busy candle. “Busy / little progress” means at least 2.5× relative volume while that same candle’s body is under 0.25 ATR; it does not prove absorption. A “strong move” means at least 1 ATR of three-candle momentum with at least 1.5× relative volume. “Pullback” is negative momentum within an Up trend; “Bounce” is positive momentum within a Down trend. These labels describe current conditions, not what happens next. When events coincide, Busy has display priority, then a turn, then an activity onset.

For example, 4H Up alongside negative 1H momentum and a 5m activity surge shows a higher-timeframe uptrend with shorter-term disagreement and unusual volume. It is a prompt to inspect price structure and risk, not an automatic long.

LIMITATIONS
Pulse is intended for standard time-based candles and the selected symbol’s feed. Relative volume is not time-of-day adjusted and does not reveal trader count, buy/sell aggression, or market-wide flow. EMA, ATR, and volume measures need source history to warm up. Lower-timeframe requests are limited to 10,000 source bars, so older readings may be unavailable. The dashboard updates when chart data ticks; provider revisions or differences between live and reloaded data may change historical readings. No predictive edge or strategy performance is claimed.

## Source Code

````pine
//@version=6
// Independent descriptive companion to S&R. No orders, entry signals, alerts or zone imports.
indicator("Universal MTF Pulse v2.0.1", shorttitle = "Univ. MTF Pulse v2.0.1", overlay = false, behind_chart = false, max_bars_back = 1000, max_labels_count = 500, dynamic_requests = true)

string PANEL = "Panel — closed chart history"
bool showPanel = input.bool(true, "Show panel visuals", group = PANEL, tooltip = "Independent of the price dashboard and candle markers. Hiding visuals does not collapse TradingView's pane.", display = display.none)
bool showWave = input.bool(true, "Momentum wave", group = PANEL, display = display.none)
bool showActivityStrip = input.bool(true, "Activity strip", group = PANEL, display = display.none)
bool showTrendStrips = input.bool(true, "Trend strips", group = PANEL, display = display.none)
bool showLegend = input.bool(true, "Legend and context", group = PANEL, display = display.none)
bool showStateLabels = input.bool(true, "Current labels beside wave and strips", group = PANEL, tooltip = "Turn off in a shallow pane when the labels overlap. Closed-bar values remain in the Data Window. Enable the dashboard for latest closed-source readings.", display = display.none)
float waveCap = input.float(3.0, "Wave display cap (ATR)", minval = 1.0, maxval = 10.0, step = 0.5, group = PANEL, tooltip = "Presentation only. Cross marks disclose clipped samples; exact values remain in the Data Window.", display = display.none)
int panelTextSize = input.int(12, "Panel text size", minval = 10, maxval = 24, group = PANEL, display = display.none)
int waveWidth = input.int(2, "Wave thickness", minval = 1, maxval = 4, group = PANEL, display = display.none)
int activityWidth = input.int(4, "Activity thickness", minval = 1, maxval = 8, group = PANEL, display = display.none)
bool stripD = input.bool(true, "1D", group = PANEL, inline = "daily", display = display.none)
int widthD = input.int(5, "Thickness", minval = 1, maxval = 8, group = PANEL, inline = "daily", display = display.none)
bool strip4H = input.bool(true, "4H", group = PANEL, inline = "four", display = display.none)
int width4H = input.int(4, "Thickness", minval = 1, maxval = 8, group = PANEL, inline = "four", display = display.none)
bool strip1H = input.bool(true, "1H", group = PANEL, inline = "hour", display = display.none)
int width1H = input.int(2, "Thickness", minval = 1, maxval = 8, group = PANEL, inline = "hour", display = display.none)
bool strip15m = input.bool(true, "15m", group = PANEL, inline = "fifteen", display = display.none)
int width15m = input.int(2, "Thickness", minval = 1, maxval = 8, group = PANEL, inline = "fifteen", display = display.none)
bool strip5m = input.bool(true, "5m", group = PANEL, inline = "five", display = display.none)
int width5m = input.int(2, "Thickness", minval = 1, maxval = 8, group = PANEL, inline = "five", display = display.none)
color quietStripColor = input.color(color.rgb(157, 170, 184), "Quiet activity", group = PANEL, display = display.none)
color usualStripColor = input.color(color.rgb(135, 196, 229), "Usual activity", group = PANEL, display = display.none)
color elevatedStripColor = input.color(color.rgb(50, 147, 215), "Elevated activity", group = PANEL, display = display.none)
color surgeStripColor = input.color(color.rgb(44, 92, 192), "Surge activity", group = PANEL, display = display.none)
string panelNote = input.string("Closed chart history · lower TFs sampled at chart close", "Sampling note", group = PANEL, display = display.none)
string stripNote = input.string("Strips = categories, not ATR · thicker = broader TF", "Categorical strip note", group = PANEL, display = display.none)
string clipText = input.string("Clipped · exact ATR in Data Window", "Clipped reading label", group = PANEL, display = display.none)
string zeroText = input.string("0 ATR · no net progress", "Zero guide label", group = PANEL, display = display.none)

string EVENTS = "Events — descriptions, not entries"
bool showPanelEvents = input.bool(true, "Panel events", group = EVENTS, display = display.none)
bool panelTurns = input.bool(true, "Panel: momentum turns", group = EVENTS, display = display.none)
bool panelActivity = input.bool(true, "Panel: activity begins", group = EVENTS, display = display.none)
bool panelBusy = input.bool(true, "Panel: busy / little progress", group = EVENTS, display = display.none)
bool showPriceEvents = input.bool(true, "Candle markers", group = EVENTS, display = display.none)
bool showPriceMarkerText = input.bool(false, "Text beside candle markers", group = EVENTS, tooltip = "Marker descriptions and exact readings remain in hover tooltips when this is off.", display = display.none)
bool priceTurns = input.bool(true, "Candles: momentum turns", group = EVENTS, display = display.none)
bool priceActivity = input.bool(false, "Candles: activity begins", group = EVENTS, display = display.none)
bool priceBusy = input.bool(true, "Candles: busy / little progress", group = EVENTS, display = display.none)
int eventRetention = input.int(100, "Retained event candles", minval = 25, maxval = 200, group = EVENTS, display = display.none)
string eventSizeChoice = input.string("Tiny", "Marker size", options = ["Tiny", "Small", "Normal"], group = EVENTS, display = display.none)
string eventSize = eventSizeChoice == "Tiny" ? size.tiny : eventSizeChoice == "Small" ? size.small : size.normal
float priceEventOffset = input.float(0.25, "Candle spacing (ATR)", minval = 0.1, maxval = 2.0, step = 0.05, group = EVENTS, display = display.none)
string markerUpText = input.string("Turn ↑", "Up triangle text", group = EVENTS, display = display.none)
string markerDownText = input.string("Turn ↓", "Down triangle text", group = EVENTS, display = display.none)
string markerActivityText = input.string("Active", "Activity dot text", group = EVENTS, display = display.none)
string markerBusyText = input.string("Busy", "Busy diamond text", group = EVENTS, display = display.none)
string eventLegendText = input.string("▲▼ momentum turn · ● activity begins · ◆ busy / little progress", "Event legend", group = EVENTS, display = display.none)
string placementText = input.string("Candle marker unavailable: no valid ATR spacing", "Missing placement warning", group = EVENTS, display = display.none)

string DISPLAY = "Dashboard"
bool showDashboard = input.bool(false, "Show dashboard", group = DISPLAY, tooltip = "Hides the table only. Candle markers and the lower panel have independent controls.", display = display.none)
bool showExplanation = input.bool(true, "Show short explanation", group = DISPLAY, display = display.none)
bool showPreview = input.bool(false, "Show forming chart-candle preview", group = DISPLAY, tooltip = "Separate UNCONFIRMED row. Forming volume is never classified as a completed candle.", display = display.none)
string selectedPosition = input.string("Bottom right", "Position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = DISPLAY, display = display.none)
int textSize = input.int(14, "Table text size", minval = 10, maxval = 24, group = DISPLAY, display = display.none)
int noteSize = input.int(12, "Explanation / footer text size", minval = 10, maxval = 24, group = DISPLAY, display = display.none)
bool showNumbers = input.bool(true, "Show numerical readings", group = DISPLAY, display = display.none)
bool showTimes = input.bool(true, "Show source close times (UTC)", group = DISPLAY, tooltip = "Full dates remain in the row tooltip when compact times are hidden.", display = display.none)
bool showTrend = input.bool(true, "Trend column", group = DISPLAY, inline = "cols", display = display.none)
bool showMomentum = input.bool(true, "Momentum", group = DISPLAY, inline = "cols", display = display.none)
bool showActivity = input.bool(true, "Activity", group = DISPLAY, inline = "cols", display = display.none)
bool showD = input.bool(true, "1D", group = DISPLAY, inline = "rows", display = display.none)
bool show4H = input.bool(true, "4H", group = DISPLAY, inline = "rows", display = display.none)
bool show1H = input.bool(true, "1H", group = DISPLAY, inline = "rows", display = display.none)
bool show15m = input.bool(true, "15m", group = DISPLAY, inline = "rows", display = display.none)
bool show5m = input.bool(true, "5m", group = DISPLAY, inline = "rows", display = display.none)

string APPEARANCE = "Appearance"
color backgroundColor = input.color(color.rgb(19, 27, 35), "Body background", group = APPEARANCE, display = display.none)
color headerColor = input.color(color.rgb(34, 46, 57), "Header background", group = APPEARANCE, display = display.none)
color selectedColor = input.color(color.rgb(39, 58, 71), "Current chart row background", group = APPEARANCE, display = display.none)
color foregroundColor = input.color(color.rgb(235, 241, 246), "Text", group = APPEARANCE, display = display.none)
color mutedColor = input.color(color.rgb(158, 177, 191), "Neutral / quiet text", group = APPEARANCE, display = display.none)
color upColor = input.color(color.rgb(86, 220, 173), "Upward readings", group = APPEARANCE, display = display.none)
color downColor = input.color(color.rgb(255, 134, 146), "Downward readings", group = APPEARANCE, display = display.none)
color warningColor = input.color(color.rgb(245, 193, 96), "Warnings / forming preview", group = APPEARANCE, display = display.none)
color activityColor = input.color(color.rgb(108, 195, 245), "Elevated activity (not direction)", group = APPEARANCE, display = display.none)
color borderColor = input.color(color.rgb(57, 72, 84), "Borders", group = APPEARANCE, display = display.none)

string WORDS = "Wording — headings and status"
string titleText = input.string("MTF PULSE", "Title", group = WORDS, display = display.none)
string confirmedText = input.string("CLOSED CANDLES", "Confirmed heading", group = WORDS, display = display.none)
string sourceText = input.string("TF / UTC", "Source heading", group = WORDS, display = display.none)
string trendText = input.string("TREND", "Trend heading", group = WORDS, display = display.none)
string momentumText = input.string("MOMENTUM", "Momentum heading", group = WORDS, display = display.none)
string activityText = input.string("ACTIVITY", "Activity heading", group = WORDS, display = display.none)
string unavailableText = input.string("N/A", "Unavailable reading", group = WORDS, display = display.none)
string waitingText = input.string("No closed data", "Missing source status", group = WORDS, display = display.none)
string staleText = input.string("Stale / gap", "Old source status", group = WORDS, display = display.none)
string futureText = input.string("Invalid time", "Future source status", group = WORDS, display = display.none)
string previewText = input.string("UNCONFIRMED", "Forming label", group = WORDS, display = display.none)
string pendingText = input.string("Pending close", "Forming volume status", group = WORDS, display = display.none)
string blockedText = input.string("Use standard time-based candles", "Unsupported chart warning", group = WORDS, display = display.none)
string rowsOffText = input.string("Enable at least one timeframe in Settings", "Hidden rows message", group = WORDS, display = display.none)
string columnsOffText = input.string("Enable a reading column in Settings", "Hidden columns message", group = WORDS, display = display.none)
string contextText = input.string("Context", "Daily / 4H prefix", group = WORDS, display = display.none)
string setupText = input.string("Setup", "1H / 15m prefix", group = WORDS, display = display.none)
string timingText = input.string("Timing", "5m prefix", group = WORDS, display = display.none)
string footerText = input.string("Context, not an entry signal", "Footer", group = WORDS, display = display.none)
string historyText = input.string("Historical snapshot", "Historical / replay label", group = WORDS, display = display.none)
string feedText = input.string("Last chart update", "Update timestamp label", group = WORDS, display = display.none)

string STATES = "Wording — readings"
string upText = input.string("Up", "Uptrend", group = STATES, display = display.none)
string downText = input.string("Down", "Downtrend", group = STATES, display = display.none)
string mixedText = input.string("Mixed", "Mixed trend", group = STATES, display = display.none)
string flatText = input.string("Flat", "Flat momentum", group = STATES, display = display.none)
string turnUpText = input.string("Turning up", "Turn up", group = STATES, display = display.none)
string turnDownText = input.string("Turning down", "Turn down", group = STATES, display = display.none)
string buildingText = input.string("Building", "Increasing momentum magnitude", group = STATES, display = display.none)
string easingText = input.string("Easing", "Decreasing momentum magnitude", group = STATES, display = display.none)
string steadyText = input.string("Steady", "Stable momentum magnitude", group = STATES, display = display.none)
string quietText = input.string("Quiet", "Low activity", group = STATES, display = display.none)
string usualText = input.string("Usual", "Normal activity", group = STATES, display = display.none)
string elevatedText = input.string("Elevated", "Elevated activity", group = STATES, display = display.none)
string surgeText = input.string("Surge", "Activity surge", group = STATES, display = display.none)
string strongUpText = input.string("Strong upward move", "Strong upward state", group = STATES, display = display.none)
string strongDownText = input.string("Strong downward move", "Strong downward state", group = STATES, display = display.none)
string busyText = input.string("High volume, small body", "Busy / stalled state", group = STATES, display = display.none)
string pullbackText = input.string("Pullback", "Pullback state", group = STATES, display = display.none)
string bounceText = input.string("Bounce", "Bounce state", group = STATES, display = display.none)
string ordinaryText = input.string("No standout state", "Ordinary state", group = STATES, display = display.none)

// BEGIN CALCULATIONS
type PulseReading
    int closedAt
    int trend
    float momentum
    float previousMomentum
    float relativeVolume
    float bodyProgress
    float pathEfficiency

// Pure source-independent calculations. Codes are presentation-neutral, not trade signals.
f_relativeVolume(float currentVolume, float precedingMean, bool completeWindow) =>
    float result = completeWindow and not na(currentVolume) and currentVolume >= 0.0 and not na(precedingMean) and precedingMean > 0.0 ? currentVolume / precedingMean : na
    result

f_trend(float price, float average, float previousAverage) =>
    int result = na(price) or na(average) or na(previousAverage) ? na : price > average and average > previousAverage ? 1 : price < average and average < previousAverage ? -1 : 0
    result

f_momentum(float price, float previousPrice, float averageRange) =>
    float result = not na(price) and not na(previousPrice) and not na(averageRange) and averageRange > 0.0 ? (price - previousPrice) / averageRange : na
    result

// Net displacement / close-to-close path length over the same three bars.
// 0 = no net displacement; 1 = a one-directional path. No predictive weighting.
f_efficiency(float displacement, float pathLength, bool completeWindow) =>
    float result = na
    if completeWindow and not na(displacement) and not na(pathLength) and pathLength >= 0.0
        result := pathLength == 0.0 ? 0.0 : math.abs(displacement) / pathLength
    result

// Compare one closed candle's volume with that same candle's absolute body.
f_busy(float bodyProgress, float relativeVolume) =>
    not na(bodyProgress) and not na(relativeVolume) and relativeVolume >= 2.5 and math.abs(bodyProgress) < 0.25

f_activity(float relativeVolume) =>
    int result = na(relativeVolume) or relativeVolume < 0.0 ? na : relativeVolume < 0.8 ? 0 : relativeVolume < 1.5 ? 1 : relativeVolume < 2.5 ? 2 : 3
    result

f_change(float momentum, float previousMomentum) =>
    int result = na
    if not na(momentum) and not na(previousMomentum)
        float magnitudeChange = math.abs(momentum) - math.abs(previousMomentum)
        result := math.abs(momentum) < 0.15 ? 0 : momentum > 0.0 and previousMomentum <= 0.0 ? 1 : momentum < 0.0 and previousMomentum >= 0.0 ? -1 : magnitudeChange > 0.000001 ? 2 : magnitudeChange < -0.000001 ? 3 : 4
    result

f_state(int trend, float momentum, float relativeVolume, float bodyProgress) =>
    int result = na
    if not na(trend) and not na(momentum)
        // Candle-local stalling can coexist with a strong three-bar move.
        result := f_busy(bodyProgress, relativeVolume) ? 2 : not na(relativeVolume) and math.abs(momentum) >= 1.0 and relativeVolume >= 1.5 ? (momentum > 0.0 ? 1 : -1) : trend == 1 and momentum < 0.0 ? 3 : trend == -1 and momentum > 0.0 ? 4 : not na(relativeVolume) ? 0 : na
    result

// An unshifted request is only usable once its source close is at/before the chart cutoff.
// This admits the just-closed historical boundary candle, never the developing HTF candle.
f_latestClosed(PulseReading candidate, PulseReading previous, int cutoff) =>
    PulseReading result = previous
    if not na(candidate) and not na(candidate.closedAt) and candidate.closedAt <= cutoff
        if na(previous) or na(previous.closedAt) or candidate.closedAt >= previous.closedAt
            result := candidate
    result

// 0 current, 1 missing, 2 future, 3 old; freshness is independent of metric availability.
f_status(PulseReading reading, int sourceDuration, int cutoff) =>
    int result = na(reading) ? 1 : na(reading.closedAt) ? 1 : reading.closedAt > cutoff ? 2 : cutoff - reading.closedAt >= sourceDuration ? 3 : 0
    result
type PulseEvents
    int turn
    bool activity
    bool busy

// Adjacent snapshots only. Missing data suppresses dependent events, never invents an onset.
f_events(PulseReading current, PulseReading previous) =>
    int turn = 0
    bool activity = false
    bool busy = false
    if not na(current) and not na(previous)
        int change = f_change(current.momentum, previous.momentum)
        turn := change == 1 ? 1 : change == -1 ? -1 : 0
        bool validVolumes = not na(f_activity(current.relativeVolume)) and not na(f_activity(previous.relativeVolume))
        if validVolumes
            activity := current.relativeVolume >= 1.5 and previous.relativeVolume < 1.5
            if not na(current.bodyProgress) and not na(previous.bodyProgress)
                bool busyNow = f_busy(current.bodyProgress, current.relativeVolume)
                bool busyBefore = f_busy(previous.bodyProgress, previous.relativeVolume)
                busy := busyNow and not busyBefore
    PulseEvents.new(turn, activity, busy)

// Filter enabled types before applying clutter priority; inputs are never modified.
f_selectEvent(PulseEvents events, array<int> enabledKinds) =>
    int selected = events.busy and array.includes(enabledKinds, 3) ? 3 : events.turn != 0 and array.includes(enabledKinds, events.turn) ? events.turn : events.activity and array.includes(enabledKinds, 2) ? 2 : 0
    selected

f_clipMomentum(float value, float cap) =>
    float clipped = na(value) ? na : math.max(-cap, math.min(cap, value))
    clipped

// Lane positions are categorical coordinates, not measurements in ATR units.
f_laneCenter(int lane, float cap) =>
    float spacing = 0.6 * math.max(1.0, cap / 3.0)
    float center = -cap - spacing * (lane + 1)
    center
// END CALCULATIONS

// All rolling functions execute in the requested source context on every source bar.
f_snapshot() =>
    float average = ta.ema(close, 50)
    float averageRange = ta.atr(14)
    float precedingMean = ta.sma(volume[1], 20)
    float precedingValidShare = ta.sma(not na(volume[1]) and volume[1] >= 0.0 ? 1.0 : 0.0, 20)
    float momentum = f_momentum(close, close[3], averageRange)
    int trend = bar_index >= 52 ? f_trend(close, average, average[3]) : na
    float relativeVolume = f_relativeVolume(volume, precedingMean, bar_index >= 20 and precedingValidShare == 1.0)
    float bodyProgress = f_momentum(close, open, averageRange)
    float pathLength = math.sum(math.abs(ta.change(close)), 3)
    float validPathShare = math.sum(not na(close) and not na(close[1]) ? 1.0 : 0.0, 3)
    float pathEfficiency = f_efficiency(close - close[3], pathLength, bar_index >= 3 and validPathShare == 3.0)
    PulseReading.new(time_close, trend, momentum, momentum[1], relativeVolume, bodyProgress, pathEfficiency)

f_priorSnapshot() =>
    PulseReading reading = f_snapshot()
    reading[1]

// Empty intrabar arrays retain the last observed close, never an invented new reading.
// The presentation independently rejects it when its timestamp becomes stale.
f_source(string sourceTimeframe, PulseReading previous, PulseReading chartReading, int cutoff) =>
    float sourceSeconds = timeframe.in_seconds(sourceTimeframe)
    float chartSeconds = timeframe.in_seconds()
    PulseReading result = previous
    if sourceSeconds < chartSeconds
        array<PulseReading> intrabars = request.security_lower_tf(syminfo.tickerid, sourceTimeframe, chartReading, calc_bars_count = 10000)
        int index = array.size(intrabars) - 1
        while index >= 0
            PulseReading candidate = array.get(intrabars, index)
            if not na(candidate) and candidate.closedAt <= cutoff
                result := candidate
                break
            index -= 1
    else if sourceSeconds == chartSeconds
        result := barstate.isconfirmed ? chartReading : chartReading[1]
    else
        PulseReading priorSource = request.security(syminfo.tickerid, sourceTimeframe, chartReading[1], lookahead = barmerge.lookahead_on, calc_bars_count = 10000)
        PulseReading boundarySource = request.security(syminfo.tickerid, sourceTimeframe, chartReading, lookahead = barmerge.lookahead_off, calc_bars_count = 10000)
        result := f_latestClosed(boundarySource, priorSource, cutoff)
    result

f_statusText(int status) =>
    status == 1 ? waitingText : status == 2 ? futureText : status == 3 ? staleText : ""

f_trendText(int trend) =>
    na(trend) ? unavailableText : trend == 1 ? "↑ " + upText : trend == -1 ? "↓ " + downText : "↔ " + mixedText

f_changeText(int change) =>
    na(change) ? unavailableText : change == 0 ? flatText : change == 1 ? turnUpText : change == -1 ? turnDownText : change == 2 ? buildingText : change == 3 ? easingText : steadyText

f_activityText(float relativeVolume) =>
    int activity = f_activity(relativeVolume)
    na(activity) ? unavailableText : activity == 0 ? quietText : activity == 1 ? usualText : activity == 2 ? elevatedText : surgeText

f_stateText(int state) =>
    na(state) ? unavailableText : state == 1 ? strongUpText : state == -1 ? strongDownText : state == 2 ? busyText : state == 3 ? pullbackText : state == 4 ? bounceText : ordinaryText

f_directionColor(float direction) =>
    na(direction) ? warningColor : direction > 0.0 ? upColor : direction < 0.0 ? downColor : mutedColor

f_position(string selected) =>
    switch selected
        "Top left" => position.top_left
        "Top center" => position.top_center
        "Top right" => position.top_right
        "Middle left" => position.middle_left
        "Middle center" => position.middle_center
        "Middle right" => position.middle_right
        "Bottom left" => position.bottom_left
        "Bottom center" => position.bottom_center
        => position.bottom_right

f_momentumText(PulseReading reading) =>
    string number = (reading.momentum > 0.0 ? "+" : "") + str.tostring(reading.momentum, "0.00") + " ATR"
    na(reading.momentum) ? unavailableText : (showNumbers ? number + "\n" : (reading.momentum > 0.0 ? "↑ " : reading.momentum < 0.0 ? "↓ " : "↔ ")) + f_changeText(f_change(reading.momentum, reading.previousMomentum))

f_volumeText(PulseReading reading) =>
    na(reading.relativeVolume) ? unavailableText : (showNumbers ? str.tostring(reading.relativeVolume, "0.00") + "×\n" : "") + f_activityText(reading.relativeVolume)

f_brief(PulseReading reading, string sourceLabel, int status) =>
    string description = f_statusText(status)
    if status == 0
        int state = f_state(reading.trend, reading.momentum, reading.relativeVolume, reading.bodyProgress)
        description := f_stateText(state)
        if state == 0
            description := f_trendText(reading.trend) + " · " + f_activityText(reading.relativeVolume)
    sourceLabel + ": " + description

// Keep the request gate chart-invariant so wrapped source requests execute consistently.
bool standardChart = chart.is_standard and not timeframe.isticks
// Replay updates can report realtime; its wall clock must never admit later source candles.
// TradingView documents this replay detection in Concepts / Strings / Checking for substrings.
bool replayChart = str.contains(syminfo.tickerid, "replay")
int cutoff = barstate.isrealtime and not replayChart ? timenow : barstate.isconfirmed ? math.min(time_close, timenow) : time
PulseReading chartReading = f_snapshot()
var PulseReading dailyReading = na
var PulseReading fourHourReading = na
var PulseReading oneHourReading = na
var PulseReading fifteenReading = na
var PulseReading fiveReading = na
if standardChart
    dailyReading := f_source("1D", dailyReading, chartReading, cutoff)
    fourHourReading := f_source("240", fourHourReading, chartReading, cutoff)
    oneHourReading := f_source("60", oneHourReading, chartReading, cutoff)
    fifteenReading := f_source("15", fifteenReading, chartReading, cutoff)
    fiveReading := f_source("5", fiveReading, chartReading, cutoff)

// Table is a latest snapshot, not a crosshair readout. UI writes stay in the main scope.
int columnCount = 1 + (showTrend ? 1 : 0) + (showMomentum ? 1 : 0) + (showActivity ? 1 : 0)
int trendColumn = 1
int momentumColumn = 1 + (showTrend ? 1 : 0)
int activityColumn = 1 + (showTrend ? 1 : 0) + (showMomentum ? 1 : 0)
array<bool> visibleRows = array.from(showD, show4H, show1H, show15m, show5m)
array<string> sourceLabels = array.from("1D", "4H", "1H", "15m", "5m")
array<int> sourceDurations = array.from(86400000, 14400000, 3600000, 900000, 300000)
array<PulseReading> readings = array.from(dailyReading, fourHourReading, oneHourReading, fifteenReading, fiveReading)
var table dashboard = table.new(f_position(selectedPosition), columnCount, 13, border_width = 1, border_color = borderColor, force_overlay = true)

if barstate.islast and showDashboard
    table.clear(dashboard, 0, 0, columnCount - 1, 12)
    if columnCount > 1
        table.merge_cells(dashboard, 0, 0, columnCount - 1, 0)
        for row = 7 to 12
            table.merge_cells(dashboard, 0, row, columnCount - 1, row)

    if showDashboard
        string heading = titleText + " · " + confirmedText
        table.cell(dashboard, 0, 0, heading, bgcolor = headerColor, text_color = foregroundColor, text_size = textSize, tooltip = "Each row describes its own latest closed source candle. Independent EMA50 trend, three-bar price progress / ATR14, and volume / preceding 20-bar mean. Not independent votes or a probability. Updates require chart ticks.")
        if not standardChart
            table.cell(dashboard, 0, 7, blockedText, bgcolor = backgroundColor, text_color = warningColor, text_size = textSize)
        else if columnCount == 1
            table.cell(dashboard, 0, 7, columnsOffText, bgcolor = backgroundColor, text_color = warningColor, text_size = textSize)
        else
            table.cell(dashboard, 0, 1, sourceText, bgcolor = headerColor, text_color = mutedColor, text_size = textSize)
            if showTrend
                table.cell(dashboard, trendColumn, 1, trendText, bgcolor = headerColor, text_color = mutedColor, text_size = textSize)
            if showMomentum
                table.cell(dashboard, momentumColumn, 1, momentumText, bgcolor = headerColor, text_color = mutedColor, text_size = textSize)
            if showActivity
                table.cell(dashboard, activityColumn, 1, activityText, bgcolor = headerColor, text_color = mutedColor, text_size = textSize)
            int visibleCount = 0
            array<string> briefs = array.new<string>()
            for index = 0 to 4
                if array.get(visibleRows, index)
                    PulseReading reading = array.get(readings, index)
                    int duration = array.get(sourceDurations, index)
                    string sourceLabel = array.get(sourceLabels, index)
                    int status = f_status(reading, duration, cutoff)
                    bool current = duration == int(timeframe.in_seconds() * 1000)
                    color rowColor = current ? selectedColor : backgroundColor
                    string closeText = not na(reading) and not na(reading.closedAt) ? str.format_time(reading.closedAt, "dd MMM HH:mm", "UTC") : waitingText
                    string rowTitle = (current ? "▸ " : "") + sourceLabel + (showTimes ? "\n" + closeText : "") + (status != 0 ? "\n" + f_statusText(status) : "")
                    string provenance = ticker.standard(syminfo.tickerid) + " · " + sourceLabel + "\nSource close: " + closeText + " UTC\n" + (status == 0 ? "Latest available closed source candle." : f_statusText(status))
                    int row = visibleCount + 2
                    table.cell(dashboard, 0, row, rowTitle, bgcolor = rowColor, text_color = status == 0 ? foregroundColor : warningColor, text_size = textSize, tooltip = provenance)
                    if showTrend
                        table.cell(dashboard, trendColumn, row, status == 0 ? f_trendText(reading.trend) : f_statusText(status), bgcolor = rowColor, text_color = status == 0 ? f_directionColor(reading.trend) : warningColor, text_size = textSize, tooltip = "Up: source close above EMA50 and EMA50 above its value three source bars ago. Down: both reversed. Otherwise mixed. At least 53 source candles required.")
                    if showMomentum
                        table.cell(dashboard, momentumColumn, row, status == 0 ? f_momentumText(reading) : unavailableText, bgcolor = rowColor, text_color = status == 0 ? f_directionColor(reading.momentum) : warningColor, text_size = textSize, tooltip = "(Close - close three source bars ago) / ATR14. Building/easing describes ATR-normalized magnitude, which also changes with ATR; it is not pure price acceleration. Below 0.15 ATR is flat. Zero/missing ATR is unavailable.")
                    if showActivity
                        table.cell(dashboard, activityColumn, row, status == 0 ? f_volumeText(reading) : unavailableText, bgcolor = rowColor, text_color = status != 0 or na(reading.relativeVolume) ? warningColor : reading.relativeVolume >= 1.5 ? activityColor : mutedColor, text_size = textSize, tooltip = "Completed candle volume / mean of preceding 20 source candles, excluding measured candle. <0.8 quiet; <1.5 usual; <2.5 elevated; otherwise surge. Heuristic category boundaries. Selected feed only; not time-of-day adjusted, trader count or buy/sell aggression. Missing/zero baseline = N/A.")
                    string prefix = index <= 1 ? contextText : index <= 3 ? setupText : timingText
                    array.push(briefs, prefix + " · " + f_brief(reading, sourceLabel, status))
                    visibleCount += 1
            if visibleCount == 0
                table.cell(dashboard, 0, 7, rowsOffText, bgcolor = backgroundColor, text_color = warningColor, text_size = textSize)
            else if showExplanation
                table.cell(dashboard, 0, 7, array.join(briefs, "\n"), bgcolor = backgroundColor, text_color = foregroundColor, text_size = noteSize, text_halign = text.align_left, tooltip = "Heuristic descriptions, not calibrated probabilities. Busy takes priority: at least 2.5x candle volume with an absolute candle body below 0.25 ATR. Strong move: at least 1 ATR three-bar progress with at least 1.5x candle volume. Pullback/bounce uses price alone. Busy does not prove absorption. Hidden columns remain available to the explanation.")
            if showPreview and visibleCount > 0 and barstate.isrealtime and not barstate.isconfirmed
                string preview = previewText + " · " + timeframe.period + "\n" + f_trendText(chartReading.trend) + " · " + f_momentumText(chartReading) + "\n" + activityText + ": " + pendingText
                table.cell(dashboard, 0, 8, preview, bgcolor = headerColor, text_color = warningColor, text_size = noteSize, tooltip = "Forming chart candle only. It can change or disappear after reload. No activity classification until close. Confirmed rows above are unchanged.")
            table.cell(dashboard, 0, 9, ticker.standard(syminfo.tickerid), bgcolor = backgroundColor, text_color = mutedColor, text_size = noteSize)
            string clockText = barstate.isrealtime and not replayChart ? feedText + ": " + str.format_time(timenow, "HH:mm:ss", "UTC") + " UTC" : historyText + " · " + str.format_time(cutoff, "dd MMM HH:mm", "UTC") + " UTC"
            table.cell(dashboard, 0, 10, clockText, bgcolor = backgroundColor, text_color = mutedColor, text_size = noteSize)
            table.cell(dashboard, 0, 11, footerText, bgcolor = headerColor, text_color = mutedColor, text_size = noteSize, tooltip = "Combine with price location, S&R reactions, candle confirmation and a risk plan. The table does not read zones from another script. Historical feed revisions and intrabar availability can change readings. No claim of a backtested trading edge.")

// Freeze panel history at confirmed chart closes; dashboard updates remain independent.
bool closedChart = standardChart and barstate.isconfirmed
float confirmedMomentum = closedChart ? chartReading.momentum : na
float confirmedActivity = closedChart ? chartReading.relativeVolume : na
array<PulseReading> historicalReadings = closedChart ? readings : array.new<PulseReading>(5)
array<bool> stripRows = array.from(stripD, strip4H, strip1H, strip15m, strip5m)
array<int> historyTrends = array.new<int>(5)
for index = 0 to 4
    PulseReading historical = array.get(historicalReadings, index)
    if f_status(historical, array.get(sourceDurations, index), time_close) == 0
        array.set(historyTrends, index, historical.trend)

f_activityColor(float relativeVolume) =>
    int activity = f_activity(relativeVolume)
    na(activity) ? warningColor : activity == 0 ? quietStripColor : activity == 1 ? usualStripColor : activity == 2 ? elevatedStripColor : surgeStripColor

float wave = f_clipMomentum(confirmedMomentum, waveCap)
bool waveVisible = showPanel and showWave and standardChart
bool activityVisible = showPanel and showActivityStrip and standardChart
bool trendsVisible = showPanel and showTrendStrips and standardChart
plot(waveVisible ? wave : na, "Momentum wave (display clipped)", color = f_directionColor(confirmedMomentum), linewidth = waveWidth, style = plot.style_linebr, display = display.pane)
plot(waveVisible and math.abs(confirmedMomentum) > waveCap ? wave : na, "Clipped wave sample", color = warningColor, linewidth = 2, style = plot.style_cross, display = display.pane)
plot(confirmedMomentum, "Closed momentum — raw ATR", display = display.data_window, precision = 3)
plot(confirmedActivity, "Closed activity — volume multiple", display = display.data_window, precision = 3)
plot(closedChart ? chartReading.bodyProgress : na, "Closed candle body — signed ATR", display = display.data_window, precision = 3)
plot(closedChart ? chartReading.pathEfficiency * 100.0 : na, "Closed three-bar path efficiency — %", display = display.data_window, precision = 1)
plot(waveVisible ? waveCap : na, "Upper display cap", color = color.new(mutedColor, 85), display = display.pane)
plot(waveVisible ? -waveCap : na, "Lower display cap", color = color.new(mutedColor, 85), display = display.pane)
plot(waveVisible ? 0 : na, "Zero reference", color = color.new(mutedColor, 50), display = display.pane)
neutralUpper = plot(waveVisible ? 0.15 : na, "Flat band upper", color = na, display = display.pane)
neutralLower = plot(waveVisible ? -0.15 : na, "Flat band lower", color = na, display = display.pane)
fill(neutralUpper, neutralLower, color = color.new(mutedColor, 90), title = "Flat momentum band")
plot(activityVisible and not na(f_activity(confirmedActivity)) ? f_laneCenter(0, waveCap) : na, "Activity category strip", color = f_activityColor(confirmedActivity), linewidth = activityWidth, style = plot.style_linebr, display = display.pane)

// Only the selected chart row receives an outline, beneath its directional colour.
int currentLane = timeframe.isticks ? -1 : array.indexof(sourceDurations, int(timeframe.in_seconds() * 1000))
string chartLabel = currentLane >= 0 ? array.get(sourceLabels, currentLane) : timeframe.period
float outline = currentLane >= 0 and trendsVisible and array.get(stripRows, currentLane) and not na(array.get(historyTrends, currentLane)) ? f_laneCenter(currentLane + 1, waveCap) : na
plot(currentLane == 0 ? outline : na, "Current 1D outline", color = foregroundColor, linewidth = widthD + 2, style = plot.style_linebr, display = display.pane)
plot(currentLane == 1 ? outline : na, "Current 4H outline", color = foregroundColor, linewidth = width4H + 2, style = plot.style_linebr, display = display.pane)
plot(currentLane == 2 ? outline : na, "Current 1H outline", color = foregroundColor, linewidth = width1H + 2, style = plot.style_linebr, display = display.pane)
plot(currentLane == 3 ? outline : na, "Current 15m outline", color = foregroundColor, linewidth = width15m + 2, style = plot.style_linebr, display = display.pane)
plot(currentLane == 4 ? outline : na, "Current 5m outline", color = foregroundColor, linewidth = width5m + 2, style = plot.style_linebr, display = display.pane)
plot(trendsVisible and stripD and not na(array.get(historyTrends, 0)) ? f_laneCenter(1, waveCap) : na, "1D trend strip", color = f_directionColor(array.get(historyTrends, 0)), linewidth = widthD, style = plot.style_linebr, display = display.pane)
plot(trendsVisible and strip4H and not na(array.get(historyTrends, 1)) ? f_laneCenter(2, waveCap) : na, "4H trend strip", color = f_directionColor(array.get(historyTrends, 1)), linewidth = width4H, style = plot.style_linebr, display = display.pane)
plot(trendsVisible and strip1H and not na(array.get(historyTrends, 2)) ? f_laneCenter(3, waveCap) : na, "1H trend strip", color = f_directionColor(array.get(historyTrends, 2)), linewidth = width1H, style = plot.style_linebr, display = display.pane)
plot(trendsVisible and strip15m and not na(array.get(historyTrends, 3)) ? f_laneCenter(4, waveCap) : na, "15m trend strip", color = f_directionColor(array.get(historyTrends, 3)), linewidth = width15m, style = plot.style_linebr, display = display.pane)
plot(trendsVisible and strip5m and not na(array.get(historyTrends, 4)) ? f_laneCenter(5, waveCap) : na, "5m trend strip", color = f_directionColor(array.get(historyTrends, 4)), linewidth = width5m, style = plot.style_linebr, display = display.pane)
plot(array.get(historyTrends, 0), "1D trend code (up 1 / mixed 0 / down -1)", display = display.data_window)
plot(array.get(historyTrends, 1), "4H trend code (up 1 / mixed 0 / down -1)", display = display.data_window)
plot(array.get(historyTrends, 2), "1H trend code (up 1 / mixed 0 / down -1)", display = display.data_window)
plot(array.get(historyTrends, 3), "15m trend code (up 1 / mixed 0 / down -1)", display = display.data_window)
plot(array.get(historyTrends, 4), "5m trend code (up 1 / mixed 0 / down -1)", display = display.data_window)

type PulseEventLabels
    int closedAt
    label panelLabel
    label priceLabel

f_eventStyle(int eventKind) =>
    eventKind == 1 ? label.style_triangleup : eventKind == -1 ? label.style_triangledown : eventKind == 2 ? label.style_circle : label.style_diamond

f_eventColor(int eventKind) =>
    eventKind == 1 ? upColor : eventKind == -1 ? downColor : eventKind == 2 ? activityColor : warningColor

f_eventText(int eventKind) =>
    eventKind == 1 ? markerUpText : eventKind == -1 ? markerDownText : eventKind == 2 ? markerActivityText : markerBusyText

f_eventTooltip(PulseEvents events, PulseReading reading, string sourceLabel) =>
    string facts = (events.turn != 0 ? f_changeText(events.turn) + "\n" : "") + (events.activity ? markerActivityText + "\n" : "") + (events.busy ? busyText + "\n" : "")
    string rawMomentum = na(reading.momentum) ? unavailableText : str.tostring(reading.momentum, "+0.000;-0.000") + " ATR"
    string rawVolume = na(reading.relativeVolume) ? unavailableText : str.tostring(reading.relativeVolume, "0.000") + "×"
    facts + sourceLabel + " · " + str.format_time(reading.closedAt, "dd MMM yyyy HH:mm", "UTC") + " UTC\n" + momentumText + ": " + rawMomentum + "\n" + activityText + ": " + rawVolume + "\nCandle body: " + str.tostring(reading.bodyProgress, "+0.000;-0.000") + " ATR\nThree-bar path efficiency: " + str.tostring(reading.pathEfficiency * 100.0, "0.0") + "% (not probability)\n" + footerText

// Calculate facts and spacing every bar; switches affect only destination selection.
PulseEvents chartEvents = f_events(chartReading, chartReading[1])
float markerRange = ta.atr(14)
array<int> panelKinds = array.new<int>()
array<int> priceKinds = array.new<int>()
if panelTurns
    array.push(panelKinds, 1)
    array.push(panelKinds, -1)
if panelActivity
    array.push(panelKinds, 2)
if panelBusy
    array.push(panelKinds, 3)
if priceTurns
    array.push(priceKinds, 1)
    array.push(priceKinds, -1)
if priceActivity
    array.push(priceKinds, 2)
if priceBusy
    array.push(priceKinds, 3)
int panelKind = f_selectEvent(chartEvents, panelKinds)
int priceKind = f_selectEvent(chartEvents, priceKinds)
bool placementUnavailable = closedChart and showPriceEvents and priceKind != 0 and (na(markerRange) or markerRange <= 0 or na(high) or na(low))
var array<PulseEventLabels> retainedEvents = array.new<PulseEventLabels>()
var int lastEventClosedAt = na
if closedChart and (na(lastEventClosedAt) or chartReading.closedAt > lastEventClosedAt)
    label panelMarker = na
    label priceMarker = na
    string tip = f_eventTooltip(chartEvents, chartReading, chartLabel)
    if showPanel and showPanelEvents and panelKind != 0
        float panelY = not na(wave) ? wave : panelKind == 2 ? f_laneCenter(0, waveCap) : na
        if not na(panelY)
            panelMarker := label.new(bar_index, panelY, "", style = f_eventStyle(panelKind), color = f_eventColor(panelKind), size = eventSize, tooltip = tip)
    if showPriceEvents and priceKind != 0 and not placementUnavailable
        float priceY = priceKind == 1 ? low - markerRange * priceEventOffset : high + markerRange * priceEventOffset
        priceMarker := label.new(bar_index, priceY, showPriceMarkerText ? f_eventText(priceKind) : "", style = f_eventStyle(priceKind), color = f_eventColor(priceKind), textcolor = f_eventColor(priceKind), size = eventSize, tooltip = tip, force_overlay = true)
    if not na(panelMarker) or not na(priceMarker)
        array.push(retainedEvents, PulseEventLabels.new(chartReading.closedAt, panelMarker, priceMarker))
        lastEventClosedAt := chartReading.closedAt
        while array.size(retainedEvents) > eventRetention
            PulseEventLabels expired = array.shift(retainedEvents)
            label.delete(expired.panelLabel)
            label.delete(expired.priceLabel)

// Last closed labels never follow an evolving chart candle or move its historical sample.
var array<PulseReading> lastClosedSources = array.new<PulseReading>(5)
var PulseReading lastChartReading = na
var int lastChartIndex = na
if closedChart
    lastClosedSources := array.copy(historicalReadings)
    lastChartReading := chartReading
    lastChartIndex := bar_index
var array<label> stateLabels = array.new<label>()
var table panelLegend = table.new(position.top_center, 1, 2)
string safetyPosition = showDashboard and selectedPosition == "Top center" ? position.bottom_center : position.top_center
var table safetyStatus = table.new(safetyPosition, 1, 1, force_overlay = true)
if barstate.islast
    for ownedLabel in stateLabels
        label.delete(ownedLabel)
    array.clear(stateLabels)
    table.clear(panelLegend, 0, 0, 0, 1)
    table.clear(safetyStatus, 0, 0, 0, 0)
    array<string> warnings = array.new<string>()
    if not standardChart
        array.push(warnings, blockedText)
    else
        if barstate.isconfirmed ? placementUnavailable : placementUnavailable[1]
            array.push(warnings, placementText)
        PulseReading latestChart = barstate.isconfirmed ? chartReading : chartReading[1]
        if na(latestChart)
            array.push(warnings, waitingText)
        else
            if na(latestChart.momentum)
                array.push(warnings, momentumText + ": " + unavailableText)
            if na(f_activity(latestChart.relativeVolume))
                array.push(warnings, activityText + ": " + unavailableText)
        for index = 0 to 4
            PulseReading reading = array.get(readings, index)
            int status = f_status(reading, array.get(sourceDurations, index), cutoff)
            if status != 0
                array.push(warnings, array.get(sourceLabels, index) + ": " + f_statusText(status))
            else if na(reading.trend) or na(reading.momentum) or na(f_activity(reading.relativeVolume))
                string absent = (na(reading.trend) ? trendText + " " : "") + (na(reading.momentum) ? momentumText + " " : "") + (na(f_activity(reading.relativeVolume)) ? activityText : "")
                array.push(warnings, array.get(sourceLabels, index) + " " + absent + ": " + unavailableText)
    if array.size(warnings) > 0
        table.cell(safetyStatus, 0, 0, titleText + "\n" + array.join(warnings, "\n"), bgcolor = headerColor, text_color = warningColor, text_size = noteSize)
    if showPanel and standardChart and not na(lastChartReading)
        int chartClose = lastChartReading.closedAt
        string chartTime = str.format_time(chartClose, "dd MMM HH:mm", "UTC") + " UTC"
        string sampleTip = panelNote + "\n" + chartTime + "\nCandle body: " + str.tostring(lastChartReading.bodyProgress, "+0.000;-0.000") + " ATR\nThree-bar path efficiency: " + str.tostring(lastChartReading.pathEfficiency * 100.0, "0.0") + "% (not probability)"
        if showStateLabels and showWave
            string rawMomentum = na(lastChartReading.momentum) ? unavailableText : str.tostring(lastChartReading.momentum, "+0.00;-0.00") + " ATR · " + f_changeText(f_change(lastChartReading.momentum, lastChartReading.previousMomentum))
            string waveLabel = momentumText + " · " + chartLabel + " · " + rawMomentum + (math.abs(lastChartReading.momentum) > waveCap ? "\n" + clipText : "")
            array.push(stateLabels, label.new(lastChartIndex, waveCap, waveLabel, style = label.style_label_right, color = backgroundColor, textcolor = foregroundColor, size = panelTextSize, tooltip = sampleTip))
            array.push(stateLabels, label.new(lastChartIndex, 0, zeroText, style = label.style_label_right, color = backgroundColor, textcolor = mutedColor, size = panelTextSize))
            array.push(stateLabels, label.new(lastChartIndex, -waveCap, "−" + str.tostring(waveCap) + " ATR", style = label.style_label_right, color = backgroundColor, textcolor = mutedColor, size = panelTextSize))
        if showStateLabels and showActivityStrip
            string activityLabel = activityText + " · " + f_activityText(lastChartReading.relativeVolume) + (na(lastChartReading.relativeVolume) ? "" : " · " + str.tostring(lastChartReading.relativeVolume, "0.00") + "×")
            array.push(stateLabels, label.new(lastChartIndex, f_laneCenter(0, waveCap), activityLabel, style = label.style_label_right, color = backgroundColor, textcolor = f_activityColor(lastChartReading.relativeVolume), size = panelTextSize, tooltip = sampleTip))
        if showStateLabels and showTrendStrips
            for index = 0 to 4
                if array.get(stripRows, index)
                    PulseReading reading = array.get(lastClosedSources, index)
                    int status = f_status(reading, array.get(sourceDurations, index), chartClose)
                    string state = status == 0 ? f_trendText(reading.trend) : f_statusText(status)
                    string row = (index == currentLane ? "▸ " : "") + array.get(sourceLabels, index) + " · " + state
                    string sourceClose = not na(reading) ? str.format_time(reading.closedAt, "dd MMM HH:mm", "UTC") + " UTC" : waitingText
                    array.push(stateLabels, label.new(lastChartIndex, f_laneCenter(index + 1, waveCap), row, style = label.style_label_right, color = backgroundColor, textcolor = status == 0 ? f_directionColor(reading.trend) : warningColor, size = panelTextSize, tooltip = sampleTip + "\n" + sourceText + ": " + sourceClose))
        if showLegend
            table.cell(panelLegend, 0, 0, titleText + " · " + chartLabel + " · " + confirmedText, bgcolor = backgroundColor, text_color = foregroundColor, text_size = panelTextSize, text_halign = text.align_left, tooltip = sampleTip)
            table.cell(panelLegend, 0, 1, stripNote, bgcolor = backgroundColor, text_color = mutedColor, text_size = panelTextSize, text_halign = text.align_left, tooltip = panelNote + (showPanelEvents or showPriceEvents ? "\n" + eventLegendText : ""))
````
