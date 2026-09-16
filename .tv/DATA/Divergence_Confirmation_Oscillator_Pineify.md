<!-- tradingview-pine-id: PUB;6e5b5865a6a24bd78988084884a2b16c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Divergence Confirmation Oscillator [Pineify]

Source: https://www.tradingview.com/script/Ih58BPBL-Divergence-Confirmation-Oscillator-Pineify/

## Description

Divergence Confirmation Oscillator [Pineify]

Overview
This RSI divergence indicator starts from one timing fact: a pivot is knowable only after its right-side bars close. It scores regular and hidden events, showing both the formation location and the later confirmation time.

Problem Definition
A divergence line drawn back to a pivot can look actionable there, although several bars were still required to confirm it. Binary markers also give equal weight to shallow disagreements and well-separated price/RSI moves. The failures are timing ambiguity and absent evidence quality. This script exposes the delay and ranks completed events; it does not assume divergence predicts reversal.

Design Rationale
Price pivots are the anchors, with RSI sampled on those exact bars. A solid diagonal shows formation; a dotted track from the second pivot to the confirmation bar shows knowledge time. Quality combines spacing, ATR-normalized price movement, RSI movement, threshold context, and RSI departure by confirmation. ATR avoids raw-point scale dependence. Unconfirmed turns would appear earlier, but would break the timing invariant. The chosen tradeoff is delay and selectivity for auditable events.

Key Features

[*]Confirmed regular/hidden bullish and bearish divergence.
[*]Adjustable 0–100 quality gate.
[*]Pivot bridge plus confirmation wait track.
[*]Bounded follow-through, invalidation, or expiry state.
[*]Four close-confirmed alerts and optional dashboard.

How It Works

[*]RSI uses closes. Price highs/lows become pivots only after the configured bars on both sides; processing occurs when the right-side bar closes.
[*]Regular bullish means lower price low and higher RSI; hidden bullish means higher price low and lower RSI. Bearish definitions are symmetric at highs.
[*]Only consecutive confirmed pivots inside the separation range interact. Each new pivot becomes the next reference even if no event passes.
[*]The score weights spacing 25%, ATR-normalized price displacement 25%, RSI displacement 25%, threshold context 15%, and departure from the second pivot 10%. Price ATR and RSI delta inputs define full component scores.
[*]Passing events receive a solid bridge, a dotted pivot-to-confirmation track, and a REG/HID label with Q at confirmation. Nearby labels rotate through three vertical lanes.
[*]After confirmation, the watch records favorable ATR movement or RSI midpoint reclaim as follow-through, a buffered close beyond the pivot as invalidation, or the time limit as expiry. Circles and crosses mark these later outcomes without duplicate edge text; they are not alert signals.

Warm-up requires valid RSI, ATR, and pivot history; invalid spacing suppresses events.

How Multiple Indicators Work Together
Price pivots supply auditable anchors; RSI measures momentum there; ATR normalizes price distance; the score ranks the completed disagreement; and the lifecycle observes only later evidence. Removing any part changes the result: without pivots timing is undefined, without RSI divergence disappears, without ATR price scale leaks into quality, and without the wait track confirmation delay is hidden. This is one causal chain, not an unrelated mashup.

Trading Ideas and Insights
Regular events show price extending while RSI disagrees; hidden events show price holding structure while RSI pulls back. Compare the confirmation bar, Q, and lifecycle before forming a thesis. Repeated invalidation suggests retuning the pivot scale. The indicator supplies no entry, stop, size, or expected return.

Unique Aspects
Confirmation geometry is the structural contribution. The diagonal shows where the relationship formed; the dotted track and label show when it became knowable. Five score components rank evidence without altering RSI, and the bounded lifecycle keeps later behavior separate. A historical bridge is therefore created at confirmation, not proof of availability at the pivot.

How to Use
Start with defaults. Cyan/green lower labels show bullish confirmations; orange/red upper labels show bearish ones. Nearby labels rotate through three lanes. Follow the dotted track to confirmation and read Q. Triangles mark events; circles/crosses mark later outcomes named in the dashboard. Use the four close-confirmed alerts.

Customization
Short pivot sides reduce delay but admit noise; long sides select broader swings and confirm later. Separation limits choose pivots. Price ATR, RSI delta, quality, and context calibrate scoring. Follow distance, buffer, and window control lifecycle. Label spacing sets the clustering window. Visual layers and retained events are switchable.

Assumptions and Limitations
Confirmed does not mean correct or profitable. Pivots lag, and historical bridges are drawn only at confirmation. Events and lifecycle changes require a closed bar. ATR is scale, not probability. Consecutive-pivot logic can miss a relationship that skips an intermediate pivot. Trends may invalidate regular divergence; ranges may create many pivots; gaps, thin trading, parameters, and synthetic chart prices can distort results. The script uses chart OHLC only, requests no external or lower-timeframe data, infers no order flow, and performs no execution backtest.

Conclusion
The oscillator makes RSI divergence auditable through confirmed anchors, scale-aware quality, explicit knowledge time, and bounded follow-up. It exposes delay and evidence while preserving uncertainty.

---

## Source Code

````pine
//@version=6
indicator("Divergence Confirmation Oscillator [Pineify]", overlay = false, max_lines_count = 200, max_labels_count = 100)

string GROUP_ENGINE = "RSI and Pivot Engine"
string GROUP_SCORE = "Quality Score"
string GROUP_LIFECYCLE = "Post-Confirmation Lifecycle"
string GROUP_DISPLAY = "Display"

int rsiLength = input.int(14, "RSI length", minval = 2, maxval = 100, group = GROUP_ENGINE)
int leftBars = input.int(5, "Pivot left bars", minval = 1, maxval = 25, group = GROUP_ENGINE)
int rightBars = input.int(5, "Pivot confirmation bars", minval = 1, maxval = 25, group = GROUP_ENGINE)
int minSeparation = input.int(6, "Minimum pivot separation", minval = 2, maxval = 100, group = GROUP_ENGINE)
int maxSeparation = input.int(60, "Maximum pivot separation", minval = 5, maxval = 250, group = GROUP_ENGINE)
float oversoldLevel = input.float(35.0, "Bullish context level", minval = 5.0, maxval = 49.0, step = 1.0, group = GROUP_ENGINE)
float overboughtLevel = input.float(65.0, "Bearish context level", minval = 51.0, maxval = 95.0, step = 1.0, group = GROUP_ENGINE)

float fullPriceAtr = input.float(0.60, "Price move for full score (ATR)", minval = 0.05, maxval = 5.0, step = 0.05, group = GROUP_SCORE)
float fullRsiDelta = input.float(8.0, "RSI change for full score", minval = 1.0, maxval = 40.0, step = 0.5, group = GROUP_SCORE)
float minQuality = input.float(58.0, "Minimum confirmation quality", minval = 20.0, maxval = 95.0, step = 1.0, group = GROUP_SCORE)

int followWindow = input.int(20, "Follow-through window", minval = 3, maxval = 100, group = GROUP_LIFECYCLE)
float followAtr = input.float(0.75, "Follow-through distance (ATR)", minval = 0.10, maxval = 5.0, step = 0.05, group = GROUP_LIFECYCLE)
float invalidationAtr = input.float(0.20, "Invalidation buffer (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = GROUP_LIFECYCLE)

bool showRegular = input.bool(true, "Show regular divergence bridges", group = GROUP_DISPLAY)
bool showHidden = input.bool(true, "Show hidden divergence bridges", group = GROUP_DISPLAY)
bool showLifecycle = input.bool(true, "Show lifecycle markers and wash", group = GROUP_DISPLAY)
bool showEventLabels = input.bool(true, "Show confirmation score labels", group = GROUP_DISPLAY)
bool showDashboard = input.bool(true, "Show dashboard", group = GROUP_DISPLAY)
int maxVisibleEvents = input.int(24, "Maximum visible event bridges", minval = 5, maxval = 50, group = GROUP_DISPLAY)
int labelClusterBars = input.int(10, "Nearby label spacing (bars)", minval = 1, maxval = 50, group = GROUP_DISPLAY, tooltip = "Confirmation labels closer than this alternate across three vertical lanes to reduce overlap.")
string dashboardPositionInput = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_DISPLAY)

f_clip(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

f_bull_zone(float firstRsi, float secondRsi) =>
    float extreme = math.min(firstRsi, secondRsi)
    f_clip((50.0 - extreme) / math.max(50.0 - oversoldLevel, 1.0), 0.0, 1.0)

f_bear_zone(float firstRsi, float secondRsi) =>
    float extreme = math.max(firstRsi, secondRsi)
    f_clip((extreme - 50.0) / math.max(overboughtLevel - 50.0, 1.0), 0.0, 1.0)

f_quality(int separation, float priceMoveAtr, float rsiMove, float zoneScore, float departureScore) =>
    float midpoint = (minSeparation + maxSeparation) * 0.5
    float halfRange = math.max((maxSeparation - minSeparation) * 0.5, 1.0)
    float spacingScore = 0.5 + 0.5 * f_clip(1.0 - math.abs(separation - midpoint) / halfRange, 0.0, 1.0)
    float priceScore = f_clip(priceMoveAtr / fullPriceAtr, 0.0, 1.0)
    float oscillatorScore = f_clip(rsiMove / fullRsiDelta, 0.0, 1.0)
    float departure = f_clip(departureScore, 0.0, 1.0)
    100.0 * (0.25 * spacingScore + 0.25 * priceScore + 0.25 * oscillatorScore + 0.15 * zoneScore + 0.10 * departure)

float rsi = ta.rsi(close, rsiLength)
float atr = ta.atr(14)
float pivotLow = ta.pivotlow(low, leftBars, rightBars)
float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
bool spacingValid = minSeparation < maxSeparation
bool ready = spacingValid and not na(rsi[rightBars]) and not na(atr[rightBars]) and atr[rightBars] > syminfo.mintick
bool newLowPivot = barstate.isconfirmed and ready and not na(pivotLow)
bool newHighPivot = barstate.isconfirmed and ready and not na(pivotHigh)

var float previousLowPrice = na
var float previousLowRsi = na
var float previousLowAtr = na
var int previousLowBar = na
var float previousHighPrice = na
var float previousHighRsi = na
var float previousHighAtr = na
var int previousHighBar = na

bool regularBull = false
bool hiddenBull = false
bool regularBear = false
bool hiddenBear = false
bool bullSignal = false
bool bearSignal = false
float bullQuality = na
float bearQuality = na
float bullAnchorPriceCandidate = na
float bullAnchorAtrCandidate = na
float bearAnchorPriceCandidate = na
float bearAnchorAtrCandidate = na
int bullStartBar = na
int bullPivotBar = na
int bearStartBar = na
int bearPivotBar = na
float bullStartRsi = na
float bullPivotRsi = na
float bearStartRsi = na
float bearPivotRsi = na

if newLowPivot
    int currentLowBar = bar_index - rightBars
    float currentLowPrice = pivotLow
    float currentLowRsi = rsi[rightBars]
    float currentLowAtr = atr[rightBars]
    if not na(previousLowPrice) and not na(previousLowRsi) and not na(previousLowAtr) and not na(previousLowBar)
        int separation = currentLowBar - previousLowBar
        bool separationAccepted = separation >= minSeparation and separation <= maxSeparation
        regularBull := separationAccepted and currentLowPrice < previousLowPrice and currentLowRsi > previousLowRsi
        hiddenBull := separationAccepted and currentLowPrice > previousLowPrice and currentLowRsi < previousLowRsi
        if regularBull or hiddenBull
            float scale = math.max((previousLowAtr + currentLowAtr) * 0.5, syminfo.mintick)
            float priceMoveAtr = math.abs(currentLowPrice - previousLowPrice) / scale
            float rsiMove = math.abs(currentLowRsi - previousLowRsi)
            float departureScore = math.max(rsi - currentLowRsi, 0.0) / fullRsiDelta
            bullQuality := f_quality(separation, priceMoveAtr, rsiMove, f_bull_zone(previousLowRsi, currentLowRsi), departureScore)
            bullSignal := bullQuality >= minQuality
            if bullSignal
                bullAnchorPriceCandidate := currentLowPrice
                bullAnchorAtrCandidate := currentLowAtr
                bullStartBar := previousLowBar
                bullPivotBar := currentLowBar
                bullStartRsi := previousLowRsi
                bullPivotRsi := currentLowRsi
    previousLowPrice := currentLowPrice
    previousLowRsi := currentLowRsi
    previousLowAtr := currentLowAtr
    previousLowBar := currentLowBar

if newHighPivot
    int currentHighBar = bar_index - rightBars
    float currentHighPrice = pivotHigh
    float currentHighRsi = rsi[rightBars]
    float currentHighAtr = atr[rightBars]
    if not na(previousHighPrice) and not na(previousHighRsi) and not na(previousHighAtr) and not na(previousHighBar)
        int separation = currentHighBar - previousHighBar
        bool separationAccepted = separation >= minSeparation and separation <= maxSeparation
        regularBear := separationAccepted and currentHighPrice > previousHighPrice and currentHighRsi < previousHighRsi
        hiddenBear := separationAccepted and currentHighPrice < previousHighPrice and currentHighRsi > previousHighRsi
        if regularBear or hiddenBear
            float scale = math.max((previousHighAtr + currentHighAtr) * 0.5, syminfo.mintick)
            float priceMoveAtr = math.abs(currentHighPrice - previousHighPrice) / scale
            float rsiMove = math.abs(currentHighRsi - previousHighRsi)
            float departureScore = math.max(currentHighRsi - rsi, 0.0) / fullRsiDelta
            bearQuality := f_quality(separation, priceMoveAtr, rsiMove, f_bear_zone(previousHighRsi, currentHighRsi), departureScore)
            bearSignal := bearQuality >= minQuality
            if bearSignal
                bearAnchorPriceCandidate := currentHighPrice
                bearAnchorAtrCandidate := currentHighAtr
                bearStartBar := previousHighBar
                bearPivotBar := currentHighBar
                bearStartRsi := previousHighRsi
                bearPivotRsi := currentHighRsi
    previousHighPrice := currentHighPrice
    previousHighRsi := currentHighRsi
    previousHighAtr := currentHighAtr
    previousHighBar := currentHighBar

var int bullLife = 0
var int bearLife = 0
var int bullAge = 0
var int bearAge = 0
var float bullAnchorPrice = na
var float bearAnchorPrice = na
var float bullAnchorAtr = na
var float bearAnchorAtr = na
var float lastBullScore = na
var float lastBearScore = na
var string lastBullType = "NONE"
var string lastBearType = "NONE"
var int lastBullConfirmBar = na
var int lastBearConfirmBar = na

bool bullFollowedNow = false
bool bullInvalidatedNow = false
bool bullExpiredNow = false
bool bearFollowedNow = false
bool bearInvalidatedNow = false
bool bearExpiredNow = false

if barstate.isconfirmed
    if bullLife == 1
        bullAge += 1
        if close < bullAnchorPrice - bullAnchorAtr * invalidationAtr
            bullLife := -1
            bullInvalidatedNow := true
        else if close >= bullAnchorPrice + bullAnchorAtr * followAtr or rsi >= 50.0
            bullLife := 2
            bullFollowedNow := true
        else if bullAge > followWindow
            bullLife := -2
            bullExpiredNow := true
    if bearLife == 1
        bearAge += 1
        if close > bearAnchorPrice + bearAnchorAtr * invalidationAtr
            bearLife := -1
            bearInvalidatedNow := true
        else if close <= bearAnchorPrice - bearAnchorAtr * followAtr or rsi <= 50.0
            bearLife := 2
            bearFollowedNow := true
        else if bearAge > followWindow
            bearLife := -2
            bearExpiredNow := true
    if bullSignal
        bullLife := 1
        bullAge := 0
        bullAnchorPrice := bullAnchorPriceCandidate
        bullAnchorAtr := bullAnchorAtrCandidate
        lastBullScore := bullQuality
        lastBullType := regularBull ? "REGULAR" : "HIDDEN"
        lastBullConfirmBar := bar_index
    if bearSignal
        bearLife := 1
        bearAge := 0
        bearAnchorPrice := bearAnchorPriceCandidate
        bearAnchorAtr := bearAnchorAtrCandidate
        lastBearScore := bearQuality
        lastBearType := regularBear ? "REGULAR" : "HIDDEN"
        lastBearConfirmBar := bar_index

color COLOR_BULL_REGULAR = color.rgb(0, 188, 212)
color COLOR_BULL_HIDDEN = color.rgb(0, 200, 145)
color COLOR_BEAR_REGULAR = color.rgb(255, 145, 0)
color COLOR_BEAR_HIDDEN = color.rgb(239, 83, 80)
color COLOR_NEUTRAL = color.rgb(120, 144, 156)
color COLOR_READY = color.rgb(126, 87, 194)

var line[] eventLines = array.new_line()
var label[] eventLabels = array.new_label()
var int lastBullLabelBar = na
var int lastBearLabelBar = na
var int bullLabelLane = 0
var int bearLabelLane = 0

bool drawBull = bullSignal and (regularBull ? showRegular : showHidden)
if drawBull
    color eventColor = regularBull ? COLOR_BULL_REGULAR : COLOR_BULL_HIDDEN
    int eventWidth = bullQuality >= 80.0 ? 4 : bullQuality >= 68.0 ? 3 : 2
    line bridge = line.new(bullStartBar, bullStartRsi, bullPivotBar, bullPivotRsi, xloc = xloc.bar_index, extend = extend.none, color = eventColor, style = line.style_solid, width = eventWidth)
    line waitTrack = line.new(bullPivotBar, bullPivotRsi, bar_index, bullPivotRsi, xloc = xloc.bar_index, extend = extend.none, color = color.new(eventColor, 32), style = line.style_dotted, width = 2)
    array.push(eventLines, bridge)
    array.push(eventLines, waitTrack)
    if showEventLabels
        bool clusteredLabel = not na(lastBullLabelBar) and bar_index - lastBullLabelBar <= labelClusterBars
        bullLabelLane := clusteredLabel ? (bullLabelLane + 1) % 3 : 0
        float labelY = bullLabelLane == 0 ? 5.0 : bullLabelLane == 1 ? 17.0 : 29.0
        string labelText = (regularBull ? "REG BULL" : "HID BULL") + "\nQ " + str.tostring(bullQuality, "#") + " | C+" + str.tostring(rightBars)
        label eventLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(eventColor, 5), style = label.style_label_up, textcolor = color.white, size = size.tiny)
        array.push(eventLabels, eventLabel)
        lastBullLabelBar := bar_index

bool drawBear = bearSignal and (regularBear ? showRegular : showHidden)
if drawBear
    color eventColor = regularBear ? COLOR_BEAR_REGULAR : COLOR_BEAR_HIDDEN
    int eventWidth = bearQuality >= 80.0 ? 4 : bearQuality >= 68.0 ? 3 : 2
    line bridge = line.new(bearStartBar, bearStartRsi, bearPivotBar, bearPivotRsi, xloc = xloc.bar_index, extend = extend.none, color = eventColor, style = line.style_solid, width = eventWidth)
    line waitTrack = line.new(bearPivotBar, bearPivotRsi, bar_index, bearPivotRsi, xloc = xloc.bar_index, extend = extend.none, color = color.new(eventColor, 32), style = line.style_dotted, width = 2)
    array.push(eventLines, bridge)
    array.push(eventLines, waitTrack)
    if showEventLabels
        bool clusteredLabel = not na(lastBearLabelBar) and bar_index - lastBearLabelBar <= labelClusterBars
        bearLabelLane := clusteredLabel ? (bearLabelLane + 1) % 3 : 0
        float labelY = bearLabelLane == 0 ? 95.0 : bearLabelLane == 1 ? 83.0 : 71.0
        string labelText = (regularBear ? "REG BEAR" : "HID BEAR") + "\nQ " + str.tostring(bearQuality, "#") + " | C+" + str.tostring(rightBars)
        label eventLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(eventColor, 5), style = label.style_label_down, textcolor = color.white, size = size.tiny)
        array.push(eventLabels, eventLabel)
        lastBearLabelBar := bar_index

while array.size(eventLines) > maxVisibleEvents * 2
    line.delete(array.shift(eventLines))
while array.size(eventLabels) > maxVisibleEvents
    label.delete(array.shift(eventLabels))

color rsiColor = not ready ? COLOR_NEUTRAL : rsi >= 50.0 ? COLOR_BULL_REGULAR : COLOR_BEAR_REGULAR
lowerBoundary = hline(0.0, "Lower scale boundary", color = color.new(COLOR_NEUTRAL, 88))
oversoldLine = hline(oversoldLevel, "Bullish context", color = color.new(COLOR_BULL_REGULAR, 50), linestyle = hline.style_dotted)
midline = hline(50.0, "RSI midpoint", color = color.new(COLOR_NEUTRAL, 55), linestyle = hline.style_dashed)
overboughtLine = hline(overboughtLevel, "Bearish context", color = color.new(COLOR_BEAR_REGULAR, 50), linestyle = hline.style_dotted)
upperBoundary = hline(100.0, "Upper scale boundary", color = color.new(COLOR_NEUTRAL, 88))
fill(lowerBoundary, oversoldLine, color = color.new(COLOR_BULL_REGULAR, 93), title = "Bullish context chamber")
fill(overboughtLine, upperBoundary, color = color.new(COLOR_BEAR_REGULAR, 93), title = "Bearish context chamber")
plot(ready ? rsi : na, "RSI halo", color = color.new(rsiColor, 78), linewidth = 7)
plot(ready ? rsi : na, "RSI spine", color = rsiColor, linewidth = 2)

bool bullWatchDominant = bullLife == 1 and (bearLife != 1 or nz(lastBullConfirmBar, -1) >= nz(lastBearConfirmBar, -1))
bool bearWatchDominant = bearLife == 1 and not bullWatchDominant
color lifecycleWash = bullWatchDominant ? color.new(COLOR_BULL_REGULAR, 93) : bearWatchDominant ? color.new(COLOR_BEAR_REGULAR, 93) : na
bgcolor(showLifecycle ? lifecycleWash : na, title = "Active confirmation lifecycle")

plotshape(showRegular and regularBull and bullSignal, title = "Confirmed regular bullish divergence", style = shape.triangleup, location = location.bottom, color = COLOR_BULL_REGULAR, size = size.tiny)
plotshape(showHidden and hiddenBull and bullSignal, title = "Confirmed hidden bullish divergence", style = shape.triangleup, location = location.bottom, color = COLOR_BULL_HIDDEN, size = size.tiny)
plotshape(showRegular and regularBear and bearSignal, title = "Confirmed regular bearish divergence", style = shape.triangledown, location = location.top, color = COLOR_BEAR_REGULAR, size = size.tiny)
plotshape(showHidden and hiddenBear and bearSignal, title = "Confirmed hidden bearish divergence", style = shape.triangledown, location = location.top, color = COLOR_BEAR_HIDDEN, size = size.tiny)
plotshape(showLifecycle and bullFollowedNow, title = "Bullish follow-through confirmed", style = shape.circle, location = location.bottom, color = COLOR_BULL_REGULAR, size = size.tiny)
plotshape(showLifecycle and bearFollowedNow, title = "Bearish follow-through confirmed", style = shape.circle, location = location.top, color = COLOR_BEAR_REGULAR, size = size.tiny)
plotshape(showLifecycle and (bullInvalidatedNow or bullExpiredNow), title = "Bullish lifecycle ended", style = shape.xcross, location = location.bottom, color = COLOR_NEUTRAL, size = size.tiny)
plotshape(showLifecycle and (bearInvalidatedNow or bearExpiredNow), title = "Bearish lifecycle ended", style = shape.xcross, location = location.top, color = COLOR_NEUTRAL, size = size.tiny)

f_life_text(int state, int age) =>
    state == 1 ? "WATCH " + str.tostring(age) + "/" + str.tostring(followWindow) : state == 2 ? "FOLLOWED" : state == -1 ? "INVALIDATED" : state == -2 ? "EXPIRED" : "NONE"

f_life_color(int state, color directionalColor) =>
    state == 1 ? directionalColor : state == 2 ? COLOR_READY : COLOR_NEUTRAL

string dashboardPosition = dashboardPositionInput == "Top Left" ? position.top_left : dashboardPositionInput == "Bottom Right" ? position.bottom_right : dashboardPositionInput == "Bottom Left" ? position.bottom_left : position.top_right
var table dashboard = table.new(dashboardPosition, 2, 6, bgcolor = color.new(chart.bg_color, 3), frame_color = color.new(chart.fg_color, 58), frame_width = 1, border_color = color.new(chart.fg_color, 82), border_width = 1)
if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 1, 0)

if barstate.islast
    table.clear(dashboard, 0, 0, 1, 5)
    if showDashboard
        color statusColor = not spacingValid ? COLOR_BEAR_HIDDEN : ready ? rsiColor : COLOR_NEUTRAL
        table.cell(dashboard, 0, 0, "DIVERGENCE CONFIRMATION", text_color = color.white, bgcolor = color.new(statusColor, 8), text_size = size.small)
        table.cell(dashboard, 0, 1, "ENGINE", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 1, 1, not spacingValid ? "CHECK SPACING" : not ready ? "WARM-UP" : "READY", text_color = statusColor, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 0, 2, "RSI / PIVOT", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 1, 2, (na(rsi) ? "NA" : str.tostring(rsi, "#.0")) + " / C+" + str.tostring(rightBars), text_color = rsiColor, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 0, 3, "LAST BULL", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 1, 3, lastBullType + " " + (na(lastBullScore) ? "--" : str.tostring(lastBullScore, "#")) + " | " + f_life_text(bullLife, bullAge), text_color = f_life_color(bullLife, COLOR_BULL_REGULAR), bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 0, 4, "LAST BEAR", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 1, 4, lastBearType + " " + (na(lastBearScore) ? "--" : str.tostring(lastBearScore, "#")) + " | " + f_life_text(bearLife, bearAge), text_color = f_life_color(bearLife, COLOR_BEAR_REGULAR), bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 0, 5, "QUALITY GATE", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)
        table.cell(dashboard, 1, 5, str.tostring(minQuality, "#") + " / 100", text_color = COLOR_READY, bgcolor = color.new(chart.bg_color, 5), text_size = size.tiny)

alertcondition(regularBull and bullSignal, "Confirmed regular bullish divergence", "Divergence Confirmation Oscillator: a regular bullish divergence passed the quality gate at the confirmation bar.")
alertcondition(hiddenBull and bullSignal, "Confirmed hidden bullish divergence", "Divergence Confirmation Oscillator: a hidden bullish divergence passed the quality gate at the confirmation bar.")
alertcondition(regularBear and bearSignal, "Confirmed regular bearish divergence", "Divergence Confirmation Oscillator: a regular bearish divergence passed the quality gate at the confirmation bar.")
alertcondition(hiddenBear and bearSignal, "Confirmed hidden bearish divergence", "Divergence Confirmation Oscillator: a hidden bearish divergence passed the quality gate at the confirmation bar.")
````
