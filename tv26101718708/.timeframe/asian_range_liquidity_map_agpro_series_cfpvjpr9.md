# Asian Range Liquidity Map [AGPro Series]

- url: https://www.tradingview.com/script/CfPvjpr9-Asian-Range-Liquidity-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;ab03b94519a54c3c90393e037ab885b2
- version: 5.0

## Description

Asian Range Liquidity Map [AGPro Series]

🔹 OVERVIEW

Asian Range Liquidity Map is a precision tool for ICT and smart-money traders who focus on the London Open liquidity sweep. The indicator maps the Asian session high/low liquidity pool, tracks which side gets taken on the London kill-zone, and keeps a rolling 60-session record of post-sweep reactions. The engine calculates live Reversal / Continuation / Mixed probabilities for both bull and bear sweeps and displays everything in a compact info panel without cluttering the chart.

Whether you trade Turtle Soup setups, session-based liquidity grabs, or simply want clean Asian range context, this indicator gives you the structural read most traders spend months building manually.


🔹 UNIQUE EDGE

This is not another session-box plotter. Three design choices separate it from generic Asian range indicators:

1. ATR-Normalized Quality Filter — the range width is measured against the Daily ATR, not the chart timeframe. Sessions that are abnormally narrow (illiquid) or abnormally wide (news-driven noise) are filtered out of the statistics engine automatically. Only clean, tradable ranges count.

2. Live Historical Statistics Engine — every past sweep in the 60-session rolling window is classified as Reversal, Continuation, or Mixed using close-based validation. When a new sweep fires, a state label immediately shows the historical bias: "Bull Sweep -> Historical Reversal 73% (n=26)". You see the context the moment price reacts.

3. Three-Tier Classification — most tools treat sweep reactions as a binary outcome. This engine separates clean reversals, clean continuations, and indecisive mixed responses, giving a more honest statistical picture. The Mixed bucket is visible in the panel so the trader always knows how confident the signal actually is.


🔹 METHODOLOGY

1. Session Tracking — the Asian window is tracked using pure UTC hour/minute math (default 00:00-08:00 UTC), fully independent of chart timezone. Start and end hours are configurable.

2. Range Validity — on session close, the range width is compared to the Daily ATR. If the ratio falls outside the user-defined band (default 0.3-2.0 x dATR), the session is marked Filtered Out and excluded from statistics.

3. Sweep Detection — after the session closes, the engine watches a configurable post-open window (default 6 hours) for the first break of the Asian High or Low. Only the first sweep per session is recorded, which keeps the sample clean.

4. Reaction Classification — after the reaction window (default 10 bars), the engine evaluates post-sweep closes:
   - Reversal: price closed through the opposite side by at least Reversal Threshold x Range
   - Continuation: price sustained past the sweep level with pullback under Continuation Threshold x Range
   - Mixed: neither condition was met

5. Rolling Sample — the most recent 60 classified sweeps feed the Bull and Bear statistics independently. Default is 60, configurable from 20 to 100.


🔹 SIGNALS AND ON-CHART ELEMENTS

- Asian Range Box: dotted amber rectangle during the session, solidifies on close if the range passes the ATR filter. Filtered sessions fade to near-invisible.
- High and Low Dotted Extensions: projected right from each validated session, showing the liquidity levels the market will target.
- Sweep State Label: appears on the bar that first breaks the range. Color-coded green for bull sweeps, pink for bear sweeps, with the historical bias and sample size baked in.
- Sweep Line: thick horizontal line at the taken level, drawn forward across the projection zone.
- Projection Zone: rectangular post-sweep forecast box where follow-through (or rejection) typically plays out.
- Multi-Day Overlay: up to the last 5 validated Asian ranges rendered with fade hierarchy (oldest most faded, newest most visible).
- Three alerts are included: Bull Sweep Detected, Bear Sweep Detected, and London Open with Valid Asian Range.


🔹 KEY INPUTS

Session Settings:
- Asian Session Start/End Hour (UTC)
- Sweep Detection Window (hours after London Open)

Quality Filter:
- Use ATR filter (on/off)
- Min and Max Range Width (x Daily ATR)
- ATR Length

Historical Stats Engine:
- Sample Size (20-100 sessions)
- Reaction Window (bars after sweep)
- Reversal Threshold (x Range)
- Continuation Threshold (x Range)

Multi-Day Overlay:
- Show historical sessions (on/off)
- Days to show and fade intensity

Post-Sweep Projection:
- Show projection zone (on/off)
- Projection length in bars

Visual Style:
- Label Font Size (independent from panel)
- Show sweep state label (on/off)

Info Panel:
- Show panel, location, theme (Dark/Light)
- Panel Font Size (independent from labels)


🔹 HOW TO USE

Best fit: intraday timeframes from 1m to 60m. The 15m chart is the intended sweet spot and what the defaults are tuned around. The script auto-disables on 4H and higher with a clear on-chart notice.

Typical workflow:

1. Confirm Range Status shows Valid after the Asian session closes. If Filtered Out, stand aside that day.
2. Wait for the London Sweep Window state and watch the Asian High/Low levels.
3. When a sweep fires, read the state label. A high Reversal probability near a major higher-timeframe level often flags a Turtle Soup opportunity. A high Continuation probability suggests fading is risky and trend-aligned entries are preferred.
4. Use the projection zone as a post-sweep attention area, not a target in itself.
5. Cross-check with your own higher-timeframe bias, volume, and structure before committing.


🔹 LIMITATIONS AND TRANSPARENCY

- This is a context tool, not a strategy. No buy/sell signals are generated and no backtest or performance claim is made.
- The historical percentages shown are descriptive statistics of recent price behavior in the sample window. They describe what has happened, not what will happen. A reading like 80% Reversal means four out of five prior sweeps in the sample reversed; the fifth did not.
- On strongly trending or low-volatility instruments, distributions can skew heavily to one category. For example, on a tight range-bound market a liquidity sweep almost always reverts, producing very high Reversal readings. This is a feature of the data, not a bug. If a distribution looks extreme, tighten the Reversal Threshold and shorten the Reaction Window for a stricter definition, or widen them for a looser one.
- Request.security is used to pull Daily ATR and is evaluated without lookahead; no future data is used.
- First-run sample size will be small until the chart has enough history to fill 60 sessions. Expect the panel to show progress like 18 / 60 until the buffer fills.


🔹 RISK DISCLOSURE

This indicator is a research and analysis tool for educational purposes. It does not constitute financial advice, a recommendation, or a solicitation to buy or sell any asset. Past behavior of liquidity sweeps does not guarantee future outcomes. Trading carries substantial risk of loss. Always perform your own analysis, apply risk management that suits your account, and consult a qualified professional before making financial decisions.

## Source Code

````pine
// -------------------------------------------------
// Asian Range Liquidity Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.9
//
// Maps the Asian session high and low as a live liquidity range, then tracks
// which side is swept during the London sweep window. The engine records
// historical high-sweep and low-sweep reactions, classifies post-sweep behavior
// as reversal, continuation or mixed, and presents the active context through
// a controlled visual map, compact labels, projection zones and a premium panel.
// Built for London Open liquidity sweep analysis, Asian range tracking,
// session liquidity mapping and ICT-style intraday context workflows.
// Version 1.8 adds a decision-language Bias row that turns the active sweep's
// historical reaction stats into a clear next-step read, plus hidden outputs
// for the high-sweep and low-sweep reversal and continuation rates.
// Version 1.9 refreshes the publication presentation only. Core calculations,
// alerts, inputs and runtime behavior remain unchanged.
// -------------------------------------------------

//@version=6
indicator("Asian Range Liquidity Map [AGPro Series]",
     shorttitle       = "AG Pro ARL",
     overlay          = true,
     max_lines_count  = 260,
     max_boxes_count  = 220,
     max_labels_count = 220)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
// Brand
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
// Panel
panelBgD      = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgL      = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
// States
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupSess  = "Sessions"
groupFilt  = "Quality Filter"
groupStat  = "Reaction Stats"
groupHist  = "Historical Range Overlay"
groupProj  = "Sweep Projection"
groupVisual= "Visuals"
groupPanel = "Panel"
groupAlert = "Alerts"

sessionTz = input.string("Etc/UTC", "Session Timezone", group = groupSess,
     tooltip = "Timezone used to evaluate the Asian range and London sweep window. Etc/UTC keeps a global reference.")

asianStartH = input.int(0, "Asian Start Hour", minval = 0, maxval = 23, group = groupSess,
     tooltip = "Hour when Asian range tracking begins in the selected session timezone.")

asianEndH = input.int(8, "Asian End / London Open Hour", minval = 0, maxval = 23, group = groupSess,
     tooltip = "Hour when Asian range tracking ends and the London sweep window begins.")

sweepWindowHours = input.int(6, "Sweep Window (hours)", minval = 1, maxval = 12, group = groupSess,
     tooltip = "Hours after Asian range close during which the first high-side or low-side sweep is tracked.")

maxChartTfMin = input.int(120, "Max Chart TF (minutes)", minval = 15, maxval = 240, group = groupSess,
     tooltip = "Maximum chart timeframe allowed for session logic. 15m to 60m is usually the cleanest range for this tool.")

useAtrFilter = input.bool(true, "Use ATR Range Filter", group = groupFilt,
     tooltip = "Filters out unusually small or unusually large Asian ranges using daily ATR.")

atrLen = input.int(14, "ATR Length", minval = 5, maxval = 80, group = groupFilt,
     tooltip = "ATR length used for daily range quality and label/projection spacing.")

atrMinMult = input.float(0.30, "Min Range Width (x Daily ATR)", minval = 0.05, maxval = 1.50, step = 0.05, group = groupFilt,
     tooltip = "Minimum Asian range width relative to daily ATR. Lower values allow narrower ranges.")

atrMaxMult = input.float(2.00, "Max Range Width (x Daily ATR)", minval = 0.50, maxval = 5.00, step = 0.10, group = groupFilt,
     tooltip = "Maximum Asian range width relative to daily ATR. Higher values allow wider, news-driven ranges.")

sampleSize = input.int(60, "Historical Sample Size", minval = 20, maxval = 120, group = groupStat,
     tooltip = "Number of completed sweep reactions used to calculate high-sweep and low-sweep statistics.")

reactionBars = input.int(10, "Reaction Window (bars)", minval = 5, maxval = 60, group = groupStat,
     tooltip = "Bars after a sweep used to classify the reaction as reversal, continuation or mixed.")

reversalThresh = input.float(1.00, "Reversal Threshold (x Range)", minval = 0.25, maxval = 2.50, step = 0.05, group = groupStat,
     tooltip = "Distance back through the swept level required to classify the post-sweep move as a reversal.")

contThreshMult = input.float(0.20, "Continuation Pullback Limit (x Range)", minval = 0.05, maxval = 0.75, step = 0.05, group = groupStat,
     tooltip = "Maximum allowed pullback after a sweep for the reaction to remain classified as continuation.")

showHistory = input.bool(true, "Show Historical Asian Ranges", group = groupHist,
     tooltip = "Keeps recent completed Asian ranges visible with a fade hierarchy.")

historyDays = input.int(3, "Historical Ranges Kept", minval = 1, maxval = 12, group = groupHist,
     tooltip = "Number of completed Asian range boxes kept on chart. Default 3 keeps the view clean.")

historyFade = input.int(88, "Historical Fill Transparency", minval = 70, maxval = 96, group = groupHist,
     tooltip = "Transparency for historical Asian range fills. Higher values are softer.")

showProjection = input.bool(true, "Show Sweep Projection Zone", group = groupProj,
     tooltip = "Draws a compact post-sweep projection zone from the swept liquidity level.")

projectionBars = input.int(28, "Projection Length (bars)", minval = 8, maxval = 120, group = groupProj,
     tooltip = "Horizontal length of the post-sweep projection zone.")

projectionAtrHeight = input.float(0.70, "Projection Height (ATR)", minval = 0.20, maxval = 2.00, step = 0.05, group = groupProj,
     tooltip = "Height of the sweep projection zone, expressed in chart ATR.")

maxSweepLabels = input.int(5, "Max Sweep Labels", minval = 1, maxval = 12, group = groupVisual,
     tooltip = "Maximum number of historical sweep labels kept on chart.")

labelMode = input.string("Balanced", "Label Detail", options = ["Minimal", "Balanced", "Detailed"], group = groupVisual,
     tooltip = "Controls sweep label text. Minimal is very compact; Balanced is publication-friendly; Detailed adds sample context.")

labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Font size for sweep labels, range tags and projection labels.")

showSweepLabels = input.bool(true, "Show Sweep Labels", group = groupVisual,
     tooltip = "Displays compact labels when a valid Asian range high or low is swept.")

showCurrentRangeTag = input.bool(true, "Show Current Range Tag", group = groupVisual,
     tooltip = "Shows one right-edge tag for the active or latest Asian range.")

showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Displays the compact Asian Range Liquidity Map panel. Enabled by default.")

panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = groupPanel,
     tooltip = "Anchor position for the on-chart panel.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Panel visual theme. Dark is the default publication style.")

panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Font size used inside the panel.")

enableAlerts = input.bool(true, "Enable Alert Conditions", group = groupAlert,
     tooltip = "Enables TradingView alert conditions for valid high-side and low-side Asian range sweeps.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(p) =>
    switch p
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_in_session(minNow, startMin, endMin) =>
    startMin < endMin ? (minNow >= startMin and minNow < endMin) : (minNow >= startMin or minNow < endMin)

f_text_on(_bg) =>
    brightness = color.r(_bg) + color.g(_bg) + color.b(_bg)
    brightness >= 360 ? color.rgb(15, 23, 42) : color.white

f_state_on_panel(_isLight, _state) =>
    if _isLight
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(190, 50, 120) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state
    else
        _state

f_panel_bg(isLight, alt) =>
    isLight ? (alt ? color.rgb(226, 232, 240) : panelBgL) : (alt ? color.rgb(30, 41, 59) : panelBgD)

f_panel_label(isLight) =>
    isLight ? panelLabelL : panelLabelD

f_panel_value(isLight) =>
    isLight ? panelValueL : panelValueD

f_bias_text(revPct, contPct, total) =>
    total <= 0 ? "No data" :
     revPct > contPct ? "Reversal " + str.tostring(revPct, "#") + "%" :
     contPct > revPct ? "Continuation " + str.tostring(contPct, "#") + "%" :
     "Mixed"

f_short_bias(revPct, contPct, total) =>
    total <= 0 ? "N/A" :
     revPct > contPct ? "REV " + str.tostring(revPct, "#") + "%" :
     contPct > revPct ? "CONT " + str.tostring(contPct, "#") + "%" :
     "MIX"

// -------------------------------------------------
// Timeframe And Session Detection
// -------------------------------------------------
tfSec = timeframe.in_seconds(timeframe.period)
tfMinutes = na(tfSec) ? na : tfSec / 60.0
tfTooLow = not na(tfMinutes) and tfMinutes < 1
tfTooHigh = not na(tfMinutes) and tfMinutes > maxChartTfMin
scriptActive = timeframe.isintraday and not tfTooLow and not tfTooHigh

sessHour = hour(time, sessionTz)
sessMinute = minute(time, sessionTz)
minOfDay = sessHour * 60 + sessMinute
asianStartMin = asianStartH * 60
asianEndMin = asianEndH * 60

inAsian = scriptActive and f_in_session(minOfDay, asianStartMin, asianEndMin)
wasInAsian = bar_index > 0 ? inAsian[1] : false
sessionStarted = inAsian and not wasInAsian
sessionEnded = wasInAsian and not inAsian

var int sweepWindowStartBar = na
if sessionEnded
    sweepWindowStartBar := bar_index

sweepWindowBars = not na(tfMinutes) ? math.max(1, int(math.round(sweepWindowHours * 60.0 / math.max(tfMinutes, 1.0)))) : 1
inSweepWindow = scriptActive and not na(sweepWindowStartBar) and bar_index - sweepWindowStartBar <= sweepWindowBars

// -------------------------------------------------
// Volatility Context
// -------------------------------------------------
atrChart = ta.atr(atrLen)
dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)

// -------------------------------------------------
// Asian Range Tracking
// -------------------------------------------------
var float asianHigh = na
var float asianLow = na
var int asianStartBar = na
var int asianEndBar = na
var bool rangeValid = false
var float rangeWidthAtr = na
var float sessionAtr = na

if sessionStarted
    asianHigh := high
    asianLow := low
    asianStartBar := bar_index
    asianEndBar := na
    rangeValid := false
    rangeWidthAtr := na
else if inAsian
    asianHigh := math.max(nz(asianHigh, high), high)
    asianLow := math.min(nz(asianLow, low), low)

if sessionEnded
    asianEndBar := bar_index - 1
    rangeWidth = asianHigh - asianLow
    sessionAtr := dailyAtr
    rangeWidthAtr := not na(dailyAtr) and dailyAtr > 0 ? rangeWidth / dailyAtr : na
    rangeValid := useAtrFilter and not na(rangeWidthAtr) ? (rangeWidthAtr >= atrMinMult and rangeWidthAtr <= atrMaxMult) : rangeWidth > 0

// -------------------------------------------------
// Current Sweep State And History
// -------------------------------------------------
var array<string> histSide = array.new<string>()
var array<string> histReaction = array.new<string>()
var array<float> histDepth = array.new<float>()

var string currentSide = "none"
var float currentSweepLevel = na
var int currentSweepBar = na
var float currentSweepDepth = na
var bool currentReactionDone = false
var string currentReaction = "none"
var float currentRangeSnap = na
var float currentHighSnap = na
var float currentLowSnap = na
var bool currentValidSnap = false
var float currentAtrSnap = na

if sessionEnded
    currentSide := "none"
    currentSweepLevel := na
    currentSweepBar := na
    currentSweepDepth := na
    currentReactionDone := false
    currentReaction := "none"
    currentHighSnap := asianHigh
    currentLowSnap := asianLow
    currentRangeSnap := not na(asianHigh) and not na(asianLow) ? asianHigh - asianLow : na
    currentValidSnap := rangeValid
    currentAtrSnap := sessionAtr

// -------------------------------------------------
// Sweep Detection
// -------------------------------------------------
bool sweepJustHappened = false
if inSweepWindow and currentSide == "none" and currentValidSnap and not na(currentHighSnap) and not na(currentLowSnap)
    highSweep = high > currentHighSnap
    lowSweep = low < currentLowSnap
    highDepthPx = highSweep ? high - currentHighSnap : 0.0
    lowDepthPx = lowSweep ? currentLowSnap - low : 0.0
    if highSweep or lowSweep
        pickHigh = highSweep and (not lowSweep or highDepthPx >= lowDepthPx)
        currentSide := pickHigh ? "bull" : "bear"
        currentSweepLevel := pickHigh ? currentHighSnap : currentLowSnap
        currentSweepBar := bar_index
        atrBase = math.max(nz(currentAtrSnap, atrChart), syminfo.mintick)
        currentSweepDepth := (pickHigh ? highDepthPx : lowDepthPx) / atrBase
        sweepJustHappened := true

postLowClose = ta.lowest(close, reactionBars)
postHighClose = ta.highest(close, reactionBars)
postLow = ta.lowest(low, reactionBars)
postHigh = ta.highest(high, reactionBars)

if not currentReactionDone and currentSide != "none" and not na(currentSweepBar) and bar_index - currentSweepBar >= reactionBars
    rng = math.max(nz(currentRangeSnap, 0.0), syminfo.mintick)
    retraceTarget = reversalThresh * rng
    contLimit = contThreshMult * rng
    if currentSide == "bull"
        isReversal = postLowClose <= currentSweepLevel - retraceTarget
        isContinuation = close > currentSweepLevel and postLow >= currentSweepLevel - contLimit
        currentReaction := isReversal ? "reversal" : isContinuation ? "continuation" : "mixed"
    else
        isReversal = postHighClose >= currentSweepLevel + retraceTarget
        isContinuation = close < currentSweepLevel and postHigh <= currentSweepLevel + contLimit
        currentReaction := isReversal ? "reversal" : isContinuation ? "continuation" : "mixed"
    currentReactionDone := true
    array.push(histSide, currentSide)
    array.push(histReaction, currentReaction)
    array.push(histDepth, nz(currentSweepDepth, 0.0))
    while array.size(histSide) > sampleSize
        array.shift(histSide)
        array.shift(histReaction)
        array.shift(histDepth)

// -------------------------------------------------
// Stats
// -------------------------------------------------
f_stats(side) =>
    int total = 0
    int rev = 0
    int cont = 0
    float depthSum = 0.0
    int depthN = 0
    sz = array.size(histSide)
    if sz > 0
        for i = 0 to sz - 1
            s = array.get(histSide, i)
            r = array.get(histReaction, i)
            d = array.get(histDepth, i)
            if s == side
                total += 1
                if r == "reversal"
                    rev += 1
                else if r == "continuation"
                    cont += 1
                if d > 0
                    depthSum += d
                    depthN += 1
    revPct = total > 0 ? rev * 100.0 / total : 0.0
    contPct = total > 0 ? cont * 100.0 / total : 0.0
    mixPct = total > 0 ? math.max(0.0, 100.0 - revPct - contPct) : 0.0
    avgDepth = depthN > 0 ? depthSum / depthN : 0.0
    [total, revPct, contPct, mixPct, avgDepth]

[bullTotal, bullRevPct, bullContPct, bullMixPct, bullAvgDepth] = f_stats("bull")
[bearTotal, bearRevPct, bearContPct, bearMixPct, bearAvgDepth] = f_stats("bear")
totalSamples = array.size(histSide)

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
var box currentRangeBox = na
var line latestHighLine = na
var line latestLowLine = na
var label rangeTag = na
var label tfWarnLabel = na
var array<box> historyBoxes = array.new<box>()
var array<label> sweepLabels = array.new<label>()
var array<line> sweepLines = array.new<line>()
var array<box> projectionBoxes = array.new<box>()
var array<label> projectionLabels = array.new<label>()

if barstate.islast and not scriptActive
    if not na(tfWarnLabel)
        label.delete(tfWarnLabel)
    warnTxt = "ARLM: use intraday chart <= " + str.tostring(maxChartTfMin) + "m"
    tfWarnLabel := label.new(bar_index, high + atrChart, warnTxt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_down,
         color = color.new(bearColor, 0),
         textcolor = headerText,
         size = size.normal)
else if scriptActive and not na(tfWarnLabel)
    label.delete(tfWarnLabel)
    tfWarnLabel := na

if sessionStarted
    if not na(currentRangeBox)
        box.delete(currentRangeBox)
    currentRangeBox := box.new(asianStartBar, asianHigh, bar_index, asianLow,
         xloc = xloc.bar_index,
         bgcolor = color.new(neutralColor, 88),
         border_color = color.new(neutralColor, 32),
         border_style = line.style_dotted,
         border_width = 1)

if inAsian and not na(currentRangeBox)
    box.set_right(currentRangeBox, bar_index)
    box.set_top(currentRangeBox, asianHigh)
    box.set_bottom(currentRangeBox, asianLow)

if sessionEnded and not na(currentRangeBox)
    box.set_right(currentRangeBox, asianEndBar)
    if rangeValid
        box.set_bgcolor(currentRangeBox, color.new(neutralColor, historyFade))
        box.set_border_color(currentRangeBox, color.new(neutralColor, 42))
        box.set_border_style(currentRangeBox, line.style_solid)
        if showHistory
            array.push(historyBoxes, currentRangeBox)
            while array.size(historyBoxes) > historyDays
                oldBox = array.shift(historyBoxes)
                if not na(oldBox)
                    box.delete(oldBox)
            hSize = array.size(historyBoxes)
            if hSize > 0
                for i = 0 to hSize - 1
                    b = array.get(historyBoxes, i)
                    ageWeight = hSize > 1 ? i / (hSize - 1.0) : 1.0
                    fillT = int(math.round(math.min(95.0, math.max(78.0, historyFade + 5.0 - ageWeight * 10.0))))
                    borderT = int(math.max(42, fillT - 22))
                    box.set_bgcolor(b, color.new(neutralColor, fillT))
                    box.set_border_color(b, color.new(neutralColor, borderT))
        else
            box.delete(currentRangeBox)
    else
        box.set_bgcolor(currentRangeBox, color.new(bearColor, 94))
        box.set_border_color(currentRangeBox, color.new(bearColor, 80))
    currentRangeBox := na

if sessionEnded and rangeValid
    if not na(latestHighLine)
        line.delete(latestHighLine)
    if not na(latestLowLine)
        line.delete(latestLowLine)
    latestHighLine := line.new(asianEndBar, asianHigh, bar_index + projectionBars, asianHigh,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(bullColor, 35),
         style = line.style_dotted,
         width = 1)
    latestLowLine := line.new(asianEndBar, asianLow, bar_index + projectionBars, asianLow,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(bearColor, 35),
         style = line.style_dotted,
         width = 1)

if not na(latestHighLine)
    line.set_x2(latestHighLine, bar_index + projectionBars)
if not na(latestLowLine)
    line.set_x2(latestLowLine, bar_index + projectionBars)

// -------------------------------------------------
// Sweep Visuals
// -------------------------------------------------
if sweepJustHappened and showSweepLabels
    isHighSweep = currentSide == "bull"
    baseCol = isHighSweep ? bullColor : bearColor
    totalNow = isHighSweep ? bullTotal : bearTotal
    revNow = isHighSweep ? bullRevPct : bearRevPct
    contNow = isHighSweep ? bullContPct : bearContPct
    sideTxt = isHighSweep ? "High Sweep" : "Low Sweep"
    compactBias = f_short_bias(revNow, contNow, totalNow)
    detailBias = f_bias_text(revNow, contNow, totalNow)
    labelTxt = labelMode == "Minimal" ? sideTxt :
         labelMode == "Detailed" ? sideTxt + "\n" + detailBias + " | n=" + str.tostring(totalNow) + "\nDepth " + str.tostring(currentSweepDepth, "#.##") + " ATR" :
         sideTxt + "\n" + compactBias + " | n=" + str.tostring(totalNow)
    y = isHighSweep ? high + atrChart * 1.35 : low - atrChart * 1.35
    st = isHighSweep ? label.style_label_down : label.style_label_up
    sweepLbl = label.new(bar_index, y, labelTxt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = st,
         color = color.new(baseCol, 4),
         textcolor = f_text_on(baseCol),
         size = labelSize,
         tooltip = "Valid Asian range sweep. The label summarizes historical reaction bias; it is not a trade instruction.")
    array.push(sweepLabels, sweepLbl)
    while array.size(sweepLabels) > maxSweepLabels
        oldLbl = array.shift(sweepLabels)
        if not na(oldLbl)
            label.delete(oldLbl)

    sweepLine = line.new(currentSweepBar, currentSweepLevel, currentSweepBar + projectionBars, currentSweepLevel,
         xloc = xloc.bar_index,
         color = color.new(baseCol, 0),
         style = line.style_solid,
         width = 2)
    array.push(sweepLines, sweepLine)
    while array.size(sweepLines) > maxSweepLabels
        oldLine = array.shift(sweepLines)
        if not na(oldLine)
            line.delete(oldLine)

    if showProjection
        zoneHeight = math.max(atrChart * projectionAtrHeight, syminfo.mintick * 10)
        zoneTop = isHighSweep ? currentSweepLevel + zoneHeight : currentSweepLevel
        zoneBot = isHighSweep ? currentSweepLevel : currentSweepLevel - zoneHeight
        projRight = currentSweepBar + projectionBars
        proj = box.new(currentSweepBar, zoneTop, projRight, zoneBot,
             xloc = xloc.bar_index,
             bgcolor = color.new(baseCol, 84),
             border_color = color.new(baseCol, 36),
             border_style = line.style_dashed,
             border_width = 1)
        projMid = (zoneTop + zoneBot) * 0.5
        projBadgeX = math.max(currentSweepBar + 4, projRight - 4)
        projLabel = label.new(projBadgeX, projMid, sideTxt + " Projection",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = color.new(baseCol, 8),
             textcolor = f_text_on(baseCol),
             size = labelSize)
        array.push(projectionBoxes, proj)
        array.push(projectionLabels, projLabel)
        while array.size(projectionBoxes) > 2
            oldProj = array.shift(projectionBoxes)
            if not na(oldProj)
                box.delete(oldProj)
        while array.size(projectionLabels) > 2
            oldProjLbl = array.shift(projectionLabels)
            if not na(oldProjLbl)
                label.delete(oldProjLbl)

// -------------------------------------------------
// Right-Edge Range Tag
// -------------------------------------------------
if showCurrentRangeTag and barstate.islast and scriptActive and not na(asianHigh) and not na(asianLow)
    if not na(rangeTag)
        label.delete(rangeTag)
    mid = (asianHigh + asianLow) * 0.5
    statusTxt = inAsian ? "ASIAN BUILD" : currentValidSnap or rangeValid ? "ASIAN RANGE" : "RANGE FILTERED"
    rangeTxt = statusTxt + "\nH " + str.tostring(asianHigh, format.mintick) + " | L " + str.tostring(asianLow, format.mintick)
    rangeTag := label.new(bar_index + 5, mid, rangeTxt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(neutralColor, 8),
         textcolor = f_text_on(neutralColor),
         size = labelSize)
else if (not showCurrentRangeTag or not scriptActive) and not na(rangeTag)
    label.delete(rangeTag)
    rangeTag := na

// -------------------------------------------------
// Decision Bias (turns the active sweep's native stats into a next-step read)
// -------------------------------------------------
string biasLine = "Off session"
color biasCol = neutralColor
if not scriptActive
    biasLine := "TF block"
    biasCol := bearColor
else if currentSide == "bull"
    biasLine := bullTotal > 0 ? (bullRevPct > bullContPct ? "Reversal lean " + str.tostring(bullRevPct, "#") + "%" : bullContPct > bullRevPct ? "Continuation lean " + str.tostring(bullContPct, "#") + "%" : "Mixed reaction") : "High swept / no data"
    biasCol := bullTotal > 0 ? (bullRevPct > bullContPct ? bearColor : bullContPct > bullRevPct ? bullColor : neutralColor) : neutralColor
else if currentSide == "bear"
    biasLine := bearTotal > 0 ? (bearRevPct > bearContPct ? "Reversal lean " + str.tostring(bearRevPct, "#") + "%" : bearContPct > bearRevPct ? "Continuation lean " + str.tostring(bearContPct, "#") + "%" : "Mixed reaction") : "Low swept / no data"
    biasCol := bearTotal > 0 ? (bearRevPct > bearContPct ? bullColor : bearContPct > bearRevPct ? bearColor : neutralColor) : neutralColor
else if inAsian
    biasLine := "Building range"
    biasCol := neutralColor
else if inSweepWindow
    biasLine := "Awaiting sweep"
    biasCol := accentColor
else
    biasLine := "Off session"
    biasCol := neutralColor

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelSize = f_size(panelSizeInput)
isLight = panelTheme == "Light"
panelBg = f_panel_bg(isLight, false)
panelAltBg = f_panel_bg(isLight, true)
panelBorder = isLight ? panelBorderL : panelBorderD
panelLabel = f_panel_label(isLight)
panelValue = f_panel_value(isLight)

var table panel = na

if showPanel and na(panel)
    panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Asian Range Liquidity Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 1, 1, 7)

    rangeWidthNow = not na(asianHigh) and not na(asianLow) ? asianHigh - asianLow : na
    atrRatioNow = not na(rangeWidthNow) and not na(dailyAtr) and dailyAtr > 0 ? rangeWidthNow / dailyAtr : na
    rangeLine = not na(rangeWidthNow) ? str.tostring(rangeWidthNow, format.mintick) + (not na(atrRatioNow) ? " | " + str.tostring(atrRatioNow, "#.##") + "x" : "") : "-"
    stateLine = not scriptActive ? "TF BLOCK" : inAsian ? "ASIA ACTIVE" : inSweepWindow ? "SWEEP WINDOW" : "OFF SESSION"
    stateCol = not scriptActive ? bearColor : inAsian ? neutralColor : inSweepWindow ? accentColor : panelValue
    sweptLine = currentSide == "bull" ? "High taken" : currentSide == "bear" ? "Low taken" : "None"
    sweptCol = currentSide == "bull" ? bullColor : currentSide == "bear" ? bearColor : panelValue
    bullLine = bullTotal > 0 ? "R " + str.tostring(bullRevPct, "#") + "% | C " + str.tostring(bullContPct, "#") + "% | n " + str.tostring(bullTotal) : "No data"
    bearLine = bearTotal > 0 ? "R " + str.tostring(bearRevPct, "#") + "% | C " + str.tostring(bearContPct, "#") + "% | n " + str.tostring(bearTotal) : "No data"
    sampleLine = str.tostring(totalSamples) + " / " + str.tostring(sampleSize)

    table.cell(panel, 0, 1, "State", text_color = panelLabel, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, stateLine, text_color = f_state_on_panel(isLight, stateCol), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "Range", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, rangeLine, text_color = rangeValid or inAsian ? panelValue : f_state_on_panel(isLight, bearColor), bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 3, "Sweep", text_color = panelLabel, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, sweptLine, text_color = f_state_on_panel(isLight, sweptCol), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "Bias", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, biasLine, text_color = f_state_on_panel(isLight, biasCol), bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 5, "High Sweep", text_color = panelLabel, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, bullLine, text_color = f_state_on_panel(isLight, bullColor), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 6, "Low Sweep", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, bearLine, text_color = f_state_on_panel(isLight, bearColor), bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 7, "Sample", text_color = panelLabel, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, sampleLine, text_color = f_state_on_panel(isLight, totalSamples >= math.min(sampleSize, 40) ? bullColor : neutralColor), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(enableAlerts and sweepJustHappened and currentSide == "bull", "Asian Range High Sweep", "Asian Range Liquidity Map: Asian range high swept during the active sweep window.")
alertcondition(enableAlerts and sweepJustHappened and currentSide == "bear", "Asian Range Low Sweep", "Asian Range Liquidity Map: Asian range low swept during the active sweep window.")
alertcondition(enableAlerts and sessionEnded and rangeValid, "Valid Asian Range Ready", "Asian Range Liquidity Map: valid Asian range is ready for the sweep window.")

plot(currentSide == "bull" ? 1.0 : currentSide == "bear" ? -1.0 : 0.0, "Sweep Side", display = display.none)
plot(float(totalSamples), "Historical Samples", display = display.none)
plot(rangeWidthAtr, "Range Width Daily ATR", display = display.none)
plot(bullRevPct, "High Sweep Reversal Rate", display = display.none)
plot(bullContPct, "High Sweep Continuation Rate", display = display.none)
plot(bearRevPct, "Low Sweep Reversal Rate", display = display.none)
plot(bearContPct, "Low Sweep Continuation Rate", display = display.none)
````
