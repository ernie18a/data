# Reference Price Operating Map [AGPro Series]

- url: https://www.tradingview.com/script/NUhNgsIH-Reference-Price-Operating-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;5615bf07e23c4a02b0d9210b26c29db7
- version: 5.0

## Description

Reference Price Operating Map [AGPro Series]

🔹 OVERVIEW

Reference Price Operating Map [AGPro Series] is a focused overlay that consolidates the four most universally watched reference prices — Daily Open, Weekly Open, Monthly Open, and Previous Close — into a single operating map. It tracks how price interacts with each level in real time, attributes control to the reference currently leading price action, groups overlapping references into confluence clusters, and fades distant context so the active map stays clean.

The chart answers one direct question at a glance: which reference is controlling the session right now.

Built for intraday operators, swing traders, and position traders who anchor their bias to session and period opens. Works on any symbol and any intraday or daily timeframe.


🔸 WHAT MAKES IT DIFFERENT

Most open-line indicators simply draw horizontal lines for Daily, Weekly, Monthly, and Previous Close and stop there. This script goes further by adding four layers on top of those lines:

• State tracking — each reference is classified as Untouched, 1st Touch, Tested, Held, Reclaimed, or Rejected, and the state updates bar by bar as price interacts with the level.

• Control attribution — a proximity-weighted scoring system selects one reference as the current "controller" of price action, highlighted with a dominant-row background in the panel and a thicker line on the chart.

• Confluence grouping — when two or more references sit within 0.5 ATR of each other, they collapse into a single cluster label (for example "D-Open + W-Open + PClose") instead of stacking separate labels on top of each other.

• Distance-aware rendering — references far from current price are demoted to a thin gray zone with a dotted line, keeping them visible as structural context without crowding the active map.

The engine also includes a far-aware state machine: references that price has not meaningfully engaged stay in the Untouched state instead of being forced into misleading classifications.


🔷 METHODOLOGY

Reference levels are pulled directly from the higher timeframe open (Daily, Weekly, Monthly) and the previous daily close using lookahead-safe security calls on confirmed bars.

Distance classification uses ATR(14) as a volatility scale. A reference is considered "near" when price is within a configurable ATR multiple and "far" when it exceeds the far-distance threshold. This adapts the map to both low-volatility ranges and high-volatility expansions without manual tuning.

State transitions are driven by a finite state machine with six states. Key transitions:

• Untouched → 1st Touch when price enters the touch zone (default 0.25 ATR) or wicks through it.
• 1st Touch / Tested → Held when price moves cleanly away from the level on the same side.
• 1st Touch / Tested → Reclaimed when price closes on the opposite side (optionally requiring multi-bar confirmation).
• Any engaged state → Rejected when a large wick rebounds from the level with more than 60 percent wick ratio.
• Held / Rejected → Reclaimed on a confirmed cross.

The control score combines proximity (how close price is to the reference relative to ATR) with a state weight (Reclaimed and 1st Touch score highest, Held scores lowest). The reference with the highest score is tagged as controller; if no reference has meaningful engagement the panel reports No Active Control.


🔶 SIGNALS AND ALERTS

Three alert conditions are exposed:

• Reference Touched — fires the first time any reference is touched in its period.
• Reference Reclaimed — fires when any reference transitions into the Reclaimed state.
• Reference Rejected — fires when a large-wick rejection bar is registered at any reference.

On-chart, first-touch diamond markers are placed on recent bars to make period engagement easy to spot in screenshots and reviews. The panel footer reports the current controller and updates in real time.


🔹 KEY INPUTS

Reference Lines — independent toggles for Daily Open, Weekly Open, Monthly Open, and Previous Close.

Display — Show Active References Only (hide untouched references for a cleaner map), Strict Reclaim Confirmation (require multiple confirmation bars for Reclaim), Label Density (Minimal shows only the dominant reference, Normal shows all active, Detailed appends state names to labels), Show Reaction Bands, Mark First Touches.

Panel — position (four corners), font size, label font size. All default to Normal per AG Pro Series visual standards.

Sensitivity — Touch Threshold (ATR multiple defining a touch), Reclaim Confirm Bars (strict-mode confirmation count), Band Width (reaction band width in ATR), Far Distance (ATR multiple beyond which references are faded to context).

All parameters are ATR-scaled so defaults transfer cleanly across instruments and timeframes.


🔸 HOW TO USE

1. Open the panel and read the controller. If the footer shows "D-Open Controls" with a Bull bias, intraday operators treat Daily Open as the session pivot and trade with that bias until the state changes.

2. Watch the confluence label. A grouped label such as "D-Open + W-Open + PClose" means three references are stacked — a cluster of this kind is typically a higher-conviction zone than a single isolated reference.

3. Use state transitions as triggers. A Rejected state at Monthly Open during a rally is a different signal than a Reclaimed state at the same level. The state tells you what just happened at the level, not just where the level is.

4. Use the far zone as context. A Monthly Open plotted as a gray zone five ATR away from price is not an execution level — it is orientation. When price approaches it, the zone transitions into an active band and the state engine re-engages.

5. Combine with your own structure work. This map is designed to sit underneath price action analysis, order flow, or trend tools, not replace them.


🔷 LIMITATIONS AND TRANSPARENCY

• This is an indicator, not a strategy. No entries, exits, position sizing, or backtesting is performed.

• Reference prices are sourced from higher timeframe candles using confirmed lookahead. Results on intraday charts should match the official Daily, Weekly, and Monthly opens of the exchange the chart is connected to.

• State classifications are heuristic. They describe observed behavior at each level in historical terms and should not be read as forecasts. A Reclaimed state is a description of what just happened, not a prediction of what comes next.

• ATR-based thresholds mean the map adapts to volatility but can feel different on very low-volume or very thinly traded instruments. Adjust the touch threshold and far distance inputs if defaults feel too loose or too tight.

• Confluence grouping uses a 0.5 ATR window. On very wide-range days this window can become large; on very narrow ranges it can feel tight.


🔶 RISK DISCLOSURE

This indicator is provided for informational and educational purposes only. It does not constitute financial advice, investment advice, trading advice, or any other form of advice. Past performance of any level, state, or methodology shown on the chart does not guarantee future results. Trading and investing involve substantial risk of loss. You alone are responsible for your decisions, for managing your risk, and for complying with the laws and regulations that apply to you. Test any tool on a demo account or in paper trading before using it with real capital.

## Source Code

````pine
// -------------------------------------------------
// Reference Price Operating Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Reference Price Operating Map tracks Daily Open, Weekly Open, Monthly Open,
// and Previous Close as operating references. It maps touch, hold, reclaim,
// rejection, control score, and confluence zones with premium centered badges,
// right-edge labels, and a compact AG Pro panel for reference-price workflows.
// It is an analytical visualization tool, not a prediction engine, not an
// automated strategy, and not financial advice. Version 1.7 adds confirmed
// higher-timeframe references, stable reclaim proof, and unified cluster zones.
// -------------------------------------------------

//@version=6
indicator("Reference Price Operating Map [AGPro Series]",
     shorttitle       = "AG RPM",
     overlay          = true,
     max_lines_count  = 160,
     max_labels_count = 220,
     max_boxes_count  = 80,
     max_bars_back    = 800)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpRefs = "Reference Lines"
showDO = input.bool(true, "Show Daily Open", group = grpRefs,
     tooltip = "Shows the current trading day's opening price as an operating reference.")
showWO = input.bool(true, "Show Weekly Open", group = grpRefs,
     tooltip = "Shows the current trading week's opening price as a medium-term operating reference.")
showMO = input.bool(true, "Show Monthly Open", group = grpRefs,
     tooltip = "Shows the current calendar month's opening price as the broadest operating reference.")
showPC = input.bool(true, "Show Previous Close", group = grpRefs,
     tooltip = "Shows the prior trading day's close as a settlement and gap-analysis reference.")

grpEngine = "State Engine"
touchATR = input.float(0.25, "Touch Threshold (ATR)", minval = 0.05, maxval = 1.50, step = 0.05, group = grpEngine,
     tooltip = "Distance in ATR units required for price to count as interacting with a reference.")
reclaimBars = input.int(2, "Reclaim Confirmation Bars", minval = 1, maxval = 5, group = grpEngine,
     tooltip = "Number of consecutive closes required on the reclaim side when strict reclaim confirmation is enabled.")
strictReclaim = input.bool(false, "Strict Reclaim Confirmation", group = grpEngine,
     tooltip = "Requires multiple closes on the reclaim side before the reference is marked as Reclaimed.")
farATR = input.float(3.5, "Far Distance (ATR)", minval = 1.0, maxval = 20.0, step = 0.5, group = grpEngine,
     tooltip = "References farther than this ATR distance are treated as structural context rather than active operating levels.")
confluenceATR = input.float(0.50, "Confluence Distance (ATR)", minval = 0.10, maxval = 2.00, step = 0.05, group = grpEngine,
     tooltip = "Maximum ATR distance between references before they are grouped into a confluence zone.")
reclaimWindow = input.int(20, "Reclaim Proof Window (bars)", minval = 4, maxval = 200, group = grpEngine,
     tooltip = "Number of bars a reclaim has to follow through in its reclaim direction within, for the Reclaim Rate proof. It only measures historical follow-through and is not a forecast.")
reclaimMoveATR = input.float(0.75, "Reclaim Proof Move (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = grpEngine,
     tooltip = "Frozen ATR distance a confirmed reclaim must travel in its reclaim direction before the proof sample counts as followed through.")

grpVisual = "Visuals"
showLines = input.bool(true, "Show Reference Lines", group = grpVisual,
     tooltip = "Displays enabled reference levels on the chart.")
showBands = input.bool(true, "Show Reaction Bands", group = grpVisual,
     tooltip = "Shows ATR-scaled reaction bands around active references.")
showConfluenceZone = input.bool(true, "Show Confluence Zone", group = grpVisual,
     tooltip = "Highlights the dominant reference cluster with a centered label when multiple references are close together.")
showControlArea = input.bool(true, "Show Standalone Control Area", group = grpVisual,
     tooltip = "When no confluence cluster is active, highlights the dominant operating reference with a subtle centered Control Area badge.")
showFirstMarks = input.bool(false, "Show First-Touch Marks", group = grpVisual,
     tooltip = "Shows compact first-touch marks only in Detailed label density. Off by default to keep publication screenshots clean.")
showLiveTag = input.bool(true, "Show Live Control Tag", group = grpVisual,
     tooltip = "Shows a live right-edge tag for the current controlling reference and control score.")
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = grpVisual,
     tooltip = "Controls right-edge and event label density. Balanced is designed for clear public screenshots.")
bandWidthATR = input.float(0.35, "Reaction Band Width (ATR)", minval = 0.05, maxval = 1.50, step = 0.05, group = grpVisual,
     tooltip = "Visual width of reaction bands around active references.")
projectionBars = input.int(28, "Right Projection Bars", minval = 8, maxval = 90, group = grpVisual,
     tooltip = "How far reference lines and right-edge labels extend beyond the latest bar.")
liveTagOffsetBars = input.int(10, "Live Tag Offset Bars", minval = 4, maxval = 50, group = grpVisual,
     tooltip = "Additional right projection used to keep the live control tag away from candles and reference labels.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVisual,
     tooltip = "Controls on-chart label, confluence badge, touch mark, and live tag size.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows the compact panel with workflow, controlling reference, action, score, location, confluence, and active count.")
panelPosition = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = grpPanel,
     tooltip = "Controls where the panel is anchored on the chart, including center positions for publication layouts.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = grpPanel,
     tooltip = "Switches panel colors for dark or light chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel,
     tooltip = "Controls panel text size.")

grpAlerts = "Alerts"
enableAlerts = input.bool(true, "Enable Alerts", group = grpAlerts,
     tooltip = "Master toggle for reference touch, reclaim, rejection, and control-change alert conditions.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgLight = color.rgb(248, 250, 252)
panelBorderD = color.rgb(51, 65, 85)
panelBorderL = color.rgb(203, 213, 225)
panelLabelD = color.rgb(148, 163, 184)
panelLabelL = color.rgb(71, 85, 105)
panelValueD = color.rgb(226, 232, 240)
panelValueL = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
darkText = color.rgb(15, 23, 42)

isLightTheme = panelTheme == "Light"
isSlateTheme = panelTheme == "Slate"
panelBg = isLightTheme ? panelBgLight : isSlateTheme ? color.rgb(30, 41, 59) : panelBgDark
panelBorder = isLightTheme ? panelBorderL : isSlateTheme ? color.rgb(71, 85, 105) : panelBorderD
panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
panelValueCol = isLightTheme ? panelValueL : panelValueD
panelAltBg = isLightTheme ? color.rgb(241, 245, 249) : isSlateTheme ? color.rgb(37, 49, 70) : color.rgb(24, 35, 55)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
ST_UNTOUCHED = 0
ST_FIRST_TOUCH = 1
ST_TESTED = 2
ST_HELD = 3
ST_RECLAIMED = 4
ST_REJECTED = 5

f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_pos(p) =>
    switch p
        "Top Center" => position.top_center
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_text_on(color bg) =>
    float yiq = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_state_text(st) =>
    st == ST_FIRST_TOUCH ? "First Touch" :
     st == ST_TESTED ? "Tested" :
     st == ST_HELD ? "Held" :
     st == ST_RECLAIMED ? "Reclaimed" :
     st == ST_REJECTED ? "Rejected" :
     "Untouched"

f_ref_name(idx) =>
    idx == 0 ? "D-Open" : idx == 1 ? "W-Open" : idx == 2 ? "M-Open" : idx == 3 ? "P-Close" : "None"

f_state_color(st, bull) =>
    st == ST_UNTOUCHED ? panelLabelCol :
     st == ST_FIRST_TOUCH ? neutralColor :
     st == ST_TESTED ? neutralColor :
     st == ST_HELD ? (bull ? bullColor : bearColor) :
     st == ST_RECLAIMED ? (bull ? bullColor : bearColor) :
     st == ST_REJECTED ? accentColor :
     panelLabelCol

f_clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

f_format_price(p) =>
    na(p) ? "-" : str.tostring(p, format.mintick)

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)

// -------------------------------------------------
// Reference Values
// -------------------------------------------------
atr14 = ta.atr(14)
touchDist = atr14 * touchATR
bandDist = atr14 * bandWidthATR
farDist = atr14 * farATR
confDist = atr14 * confluenceATR

newDay = ta.change(time("D")) != 0
newWeek = ta.change(time("W")) != 0
newMonth = ta.change(time("M")) != 0

var float dailyOpen = na
var float weeklyOpen = na
var float monthlyOpen = na
var float prevClose = na
var int dailyStart = 0
var int weeklyStart = 0
var int monthlyStart = 0
var int prevCloseStart = 0

dailyOpenHtf = request.security(syminfo.tickerid, "D", open, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
weeklyOpenHtf = request.security(syminfo.tickerid, "W", open, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
monthlyOpenHtf = request.security(syminfo.tickerid, "M", open, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
prevCloseHtf = request.security(syminfo.tickerid, "D", close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

if barstate.isfirst or newDay
    dailyOpen := dailyOpenHtf
    prevClose := prevCloseHtf
    dailyStart := bar_index
    prevCloseStart := bar_index
if barstate.isfirst or newWeek
    weeklyOpen := weeklyOpenHtf
    weeklyStart := bar_index
if barstate.isfirst or newMonth
    monthlyOpen := monthlyOpenHtf
    monthlyStart := bar_index

// -------------------------------------------------
// State Storage
// -------------------------------------------------
var int doState = ST_UNTOUCHED
var int woState = ST_UNTOUCHED
var int moState = ST_UNTOUCHED
var int pcState = ST_UNTOUCHED
var bool doBull = true
var bool woBull = true
var bool moBull = true
var bool pcBull = true
var int doReclaimCount = 0
var int woReclaimCount = 0
var int moReclaimCount = 0
var int pcReclaimCount = 0
var bool doFirstDone = false
var bool woFirstDone = false
var bool moFirstDone = false
var bool pcFirstDone = false

if newDay
    doState := ST_UNTOUCHED
    pcState := ST_UNTOUCHED
    doReclaimCount := 0
    pcReclaimCount := 0
    doFirstDone := false
    pcFirstDone := false
if newWeek
    woState := ST_UNTOUCHED
    woReclaimCount := 0
    woFirstDone := false
if newMonth
    moState := ST_UNTOUCHED
    moReclaimCount := 0
    moFirstDone := false

f_is_far(refPrice) =>
    na(refPrice) or atr14 <= 0.0 ? true : math.abs(close - refPrice) > farDist

f_state_update(refPrice, curState, curBull, reclaimCount, firstDone, isFar) =>
    ns = curState
    nb = curBull
    nr = reclaimCount
    nfd = firstDone
    firstTouchNow = false
    if barstate.isconfirmed and not isFar and not na(refPrice) and atr14 > 0.0
        above = close > refPrice
        inZone = math.abs(close - refPrice) <= touchDist
        wickTouch = low <= refPrice + touchDist and high >= refPrice - touchDist
        bodySize = math.abs(close - open)
        candleSize = math.max(high - low, syminfo.mintick)
        wickRatio = (candleSize - bodySize) / candleSize
        rejected = wickRatio > 0.58 and math.abs(close - refPrice) > touchDist * 0.50
        if curState == ST_UNTOUCHED
            if inZone or wickTouch
                ns := ST_FIRST_TOUCH
                nb := above
                firstTouchNow := not firstDone
                nfd := true
        else if curState == ST_FIRST_TOUCH or curState == ST_TESTED
            if (inZone or wickTouch) and rejected
                ns := ST_REJECTED
                nb := above
            else if not inZone and not wickTouch
                if above == curBull
                    ns := ST_HELD
                    nr := 0
                else
                    nr += 1
                    if strictReclaim ? nr >= reclaimBars : true
                        ns := ST_RECLAIMED
                        nb := above
                        nr := 0
        else if curState == ST_HELD
            if inZone or wickTouch
                ns := ST_TESTED
                nr := 0
            else if above != curBull
                nr += 1
                if strictReclaim ? nr >= reclaimBars : true
                    ns := ST_RECLAIMED
                    nb := above
                    nr := 0
            else
                nr := 0
        else if curState == ST_RECLAIMED or curState == ST_REJECTED
            if inZone or wickTouch
                ns := ST_TESTED
                nr := 0
            else if above != curBull
                nr += 1
                if strictReclaim ? nr >= reclaimBars : true
                    ns := ST_RECLAIMED
                    nb := above
                    nr := 0
            else
                nr := 0
    [ns, nb, nr, nfd, firstTouchNow]

doFar = f_is_far(dailyOpen)
woFar = f_is_far(weeklyOpen)
moFar = f_is_far(monthlyOpen)
pcFar = f_is_far(prevClose)

[doS, doB, doR, doFD, doFT] = f_state_update(dailyOpen, doState, doBull, doReclaimCount, doFirstDone, doFar)
doState := doS
doBull := doB
doReclaimCount := doR
doFirstDone := doFD

[woS, woB, woR, woFD, woFT] = f_state_update(weeklyOpen, woState, woBull, woReclaimCount, woFirstDone, woFar)
woState := woS
woBull := woB
woReclaimCount := woR
woFirstDone := woFD

[moS, moB, moR, moFD, moFT] = f_state_update(monthlyOpen, moState, moBull, moReclaimCount, moFirstDone, moFar)
moState := moS
moBull := moB
moReclaimCount := moR
moFirstDone := moFD

[pcS, pcB, pcR, pcFD, pcFT] = f_state_update(prevClose, pcState, pcBull, pcReclaimCount, pcFirstDone, pcFar)
pcState := pcS
pcBull := pcB
pcReclaimCount := pcR
pcFirstDone := pcFD

// -------------------------------------------------
// Scoring And Visibility
// -------------------------------------------------
f_ref_score(refPrice, st, isFar) =>
    score = 0.0
    if not na(refPrice) and atr14 > 0.0 and not isFar
        prox = 1.0 - f_clamp(math.abs(close - refPrice) / (atr14 * 4.0), 0.0, 1.0)
        stateWeight = st == ST_RECLAIMED ? 1.00 :
             st == ST_REJECTED ? 0.88 :
             st == ST_FIRST_TOUCH ? 0.82 :
             st == ST_TESTED ? 0.72 :
             st == ST_HELD ? 0.64 :
             0.0
        score := prox * stateWeight * 100.0
    score

doScore = showDO ? f_ref_score(dailyOpen, doState, doFar) : 0.0
woScore = showWO ? f_ref_score(weeklyOpen, woState, woFar) : 0.0
moScore = showMO ? f_ref_score(monthlyOpen, moState, moFar) : 0.0
pcScore = showPC ? f_ref_score(prevClose, pcState, pcFar) : 0.0

maxScore = math.max(doScore, math.max(woScore, math.max(moScore, pcScore)))
dominantIdx = maxScore <= 0.0 ? -1 : maxScore == doScore ? 0 : maxScore == woScore ? 1 : maxScore == moScore ? 2 : 3
dominantName = f_ref_name(dominantIdx)
controlScore = int(math.round(maxScore))

doActive = doState != ST_UNTOUCHED
woActive = woState != ST_UNTOUCHED
moActive = moState != ST_UNTOUCHED
pcActive = pcState != ST_UNTOUCHED
activeCount = (doActive ? 1 : 0) + (woActive ? 1 : 0) + (moActive ? 1 : 0) + (pcActive ? 1 : 0)

doVisible = showDO and (not doFar or doActive)
woVisible = showWO and (not woFar or woActive)
moVisible = showMO and (not moFar or moActive)
pcVisible = showPC and (not pcFar or pcActive)

// -------------------------------------------------
// Reclaim follow-through proof (Confirm Rate)
// -------------------------------------------------
// When a reference is reclaimed, does price follow through 0.75 ATR in the
// reclaim direction before closing back across the reclaimed reference (a
// failed reclaim)? Counted once per reclaim. A failed reclaim first, or a
// window expiry with no follow-through, is treated as not-followed.
bool doRec = doState == ST_RECLAIMED and doState[1] != ST_RECLAIMED
bool woRec = woState == ST_RECLAIMED and woState[1] != ST_RECLAIMED
bool moRec = moState == ST_RECLAIMED and moState[1] != ST_RECLAIMED
bool pcRec = pcState == ST_RECLAIMED and pcState[1] != ST_RECLAIMED
bool anyRec = doRec or woRec or moRec or pcRec
int recIdx = dominantIdx == 0 and doRec ? 0 : dominantIdx == 1 and woRec ? 1 : dominantIdx == 2 and moRec ? 2 : dominantIdx == 3 and pcRec ? 3 : doRec ? 0 : woRec ? 1 : moRec ? 2 : pcRec ? 3 : -1
int recBull = recIdx == 0 ? (doBull ? 1 : -1) : recIdx == 1 ? (woBull ? 1 : -1) : recIdx == 2 ? (moBull ? 1 : -1) : recIdx == 3 ? (pcBull ? 1 : -1) : 0
float recLevel = recIdx == 0 ? dailyOpen : recIdx == 1 ? weeklyOpen : recIdx == 2 ? monthlyOpen : recIdx == 3 ? prevClose : na

float rcMargin = math.max(nz(atr14, syminfo.mintick), syminfo.mintick) * reclaimMoveATR
var int   rcTotal = 0
var int   rcWon    = 0
var bool  rcPend    = false
var int   rcDir      = 0
var float rcAnchor    = na
var float rcLevel      = na
var float rcTarget     = na
var int   rcLeft        = 0

if barstate.isconfirmed
    if rcPend and not na(rcAnchor) and not na(rcLevel)
        bool failed = rcDir > 0 ? close < rcLevel : close > rcLevel
        bool followed = rcDir > 0 ? close >= rcTarget : close <= rcTarget
        if failed
            rcTotal += 1
            rcPend := false
        else if followed
            rcTotal += 1
            rcWon += 1
            rcPend := false
        else
            rcLeft -= 1
            if rcLeft <= 0
                rcTotal += 1
                rcPend := false
    if anyRec and recBull != 0 and not na(recLevel)
        if rcPend
            rcTotal += 1
        rcDir := recBull
        rcAnchor := close
        rcLevel := recLevel
        rcTarget := close + recBull * rcMargin
        rcLeft := reclaimWindow
        rcPend := true

float rcRate = rcTotal > 0 ? rcWon / rcTotal * 100.0 : na
string reclaimRead = rcTotal > 0 ? str.tostring(math.round(rcRate)) + "% (" + str.tostring(rcTotal) + ")" : "Building"
color reclaimCol = na(rcRate) ? panelValueCol : rcRate >= 60.0 ? bullColor : rcRate < 45.0 ? bearColor : panelValueCol

// -------------------------------------------------
// Drawing Helpers
// -------------------------------------------------
f_ref_color(st, bull, isFar, isDom) =>
    base = isFar ? panelLabelCol : f_state_color(st, bull)
    color.new(base, isDom ? 0 : isFar ? 42 : 16)

f_ref_width(isDom, active, isFar) =>
    isFar ? 1 : isDom and active ? 3 : active ? 2 : 1

f_ref_style(st, isFar) =>
    isFar or st == ST_UNTOUCHED ? line.style_dotted : st == ST_HELD ? line.style_dashed : line.style_solid

f_label_y(refPrice, rank) =>
    refPrice + (rank - 1.5) * atr14 * 0.16

var line doLine = na
var line woLine = na
var line moLine = na
var line pcLine = na
var box doBand = na
var box woBand = na
var box moBand = na
var box pcBand = na
var label doLabel = na
var label woLabel = na
var label moLabel = na
var label pcLabel = na
var box confBox = na
var label confLabel = na
var label liveTag = na
var array<label> firstTouchLabels = array.new<label>()

f_delete_line(line id) =>
    if not na(id)
        line.delete(id)

f_delete_box(box id) =>
    if not na(id)
        box.delete(id)

f_delete_label(label id) =>
    if not na(id)
        label.delete(id)

f_draw_ref(visible, refPrice, st, bull, isFar, isDom, startBar, rank, refTxt, suppressBand) =>
    line outLine = na
    box outBand = na
    label outLabel = na
    if showLines and visible and not na(refPrice)
        leftX = math.max(startBar, bar_index - 260)
        rightX = bar_index + projectionBars
        refCol = f_ref_color(st, bull, isFar, isDom)
        outLine := line.new(leftX, refPrice, rightX, refPrice, xloc = xloc.bar_index, color = refCol, width = f_ref_width(isDom, st != ST_UNTOUCHED, isFar), style = f_ref_style(st, isFar))
        if showBands and st != ST_UNTOUCHED and not isFar and not suppressBand
            bandCol = color.new(f_state_color(st, bull), isDom ? 82 : 88)
            outBand := box.new(leftX, refPrice + bandDist, rightX, refPrice - bandDist, xloc = xloc.bar_index, border_color = color.new(refCol, 55), bgcolor = bandCol)
        showLbl = labelDensity == "Detailed" ? true : labelDensity == "Balanced" ? st != ST_UNTOUCHED or isDom : isDom
        if showLbl
            labelTxt = labelDensity == "Detailed" ? refTxt + "  " + f_state_text(st) : refTxt
            labelBgCol = f_state_color(st, bull)
            outLabel := label.new(rightX + rank * 3, f_label_y(refPrice, rank), labelTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(labelBgCol, isDom ? 4 : 16), textcolor = f_text_on(labelBgCol), size = labelSize)
    [outLine, outBand, outLabel]

f_keep_touch_label(label id) =>
    array.push(firstTouchLabels, id)
    while array.size(firstTouchLabels) > 5
        old = array.shift(firstTouchLabels)
        if not na(old)
            label.delete(old)

// -------------------------------------------------
// Confluence Ownership
// -------------------------------------------------
domPrice = dominantIdx == 0 ? dailyOpen : dominantIdx == 1 ? weeklyOpen : dominantIdx == 2 ? monthlyOpen : dominantIdx == 3 ? prevClose : na
domState = dominantIdx == 0 ? doState : dominantIdx == 1 ? woState : dominantIdx == 2 ? moState : dominantIdx == 3 ? pcState : ST_UNTOUCHED
domBull = dominantIdx == 0 ? doBull : dominantIdx == 1 ? woBull : dominantIdx == 2 ? moBull : dominantIdx == 3 ? pcBull : true

inDoCluster = dominantIdx >= 0 and showDO and not na(dailyOpen) and math.abs(dailyOpen - domPrice) <= confDist
inWoCluster = dominantIdx >= 0 and showWO and not na(weeklyOpen) and math.abs(weeklyOpen - domPrice) <= confDist
inMoCluster = dominantIdx >= 0 and showMO and not na(monthlyOpen) and math.abs(monthlyOpen - domPrice) <= confDist
inPcCluster = dominantIdx >= 0 and showPC and not na(prevClose) and math.abs(prevClose - domPrice) <= confDist
clusterCount = (inDoCluster ? 1 : 0) + (inWoCluster ? 1 : 0) + (inMoCluster ? 1 : 0) + (inPcCluster ? 1 : 0)
clusterTop = math.max(inDoCluster ? dailyOpen : -1e20, math.max(inWoCluster ? weeklyOpen : -1e20, math.max(inMoCluster ? monthlyOpen : -1e20, inPcCluster ? prevClose : -1e20)))
clusterBot = math.min(inDoCluster ? dailyOpen : 1e20, math.min(inWoCluster ? weeklyOpen : 1e20, math.min(inMoCluster ? monthlyOpen : 1e20, inPcCluster ? prevClose : 1e20)))
clusterValid = clusterCount >= 2 and clusterTop > -1e19 and clusterBot < 1e19
string clusterLabel = ""
clusterLabel := inDoCluster ? "D-Open" : clusterLabel
clusterLabel := inWoCluster ? clusterLabel + (clusterLabel == "" ? "" : " + ") + "W-Open" : clusterLabel
clusterLabel := inMoCluster ? clusterLabel + (clusterLabel == "" ? "" : " + ") + "M-Open" : clusterLabel
clusterLabel := inPcCluster ? clusterLabel + (clusterLabel == "" ? "" : " + ") + "P-Close" : clusterLabel

if barstate.islast
    f_delete_line(doLine)
    f_delete_line(woLine)
    f_delete_line(moLine)
    f_delete_line(pcLine)
    f_delete_box(doBand)
    f_delete_box(woBand)
    f_delete_box(moBand)
    f_delete_box(pcBand)
    f_delete_label(doLabel)
    f_delete_label(woLabel)
    f_delete_label(moLabel)
    f_delete_label(pcLabel)

    [dl, db, dlab] = f_draw_ref(doVisible, dailyOpen, doState, doBull, doFar, dominantIdx == 0, dailyStart, 0, "D-Open", showConfluenceZone and clusterValid and labelDensity != "Detailed" and inDoCluster)
    doLine := dl
    doBand := db
    doLabel := dlab
    [wl, wb, wlab] = f_draw_ref(woVisible, weeklyOpen, woState, woBull, woFar, dominantIdx == 1, weeklyStart, 1, "W-Open", showConfluenceZone and clusterValid and labelDensity != "Detailed" and inWoCluster)
    woLine := wl
    woBand := wb
    woLabel := wlab
    [ml, mb, mlab] = f_draw_ref(moVisible, monthlyOpen, moState, moBull, moFar, dominantIdx == 2, monthlyStart, 2, "M-Open", showConfluenceZone and clusterValid and labelDensity != "Detailed" and inMoCluster)
    moLine := ml
    moBand := mb
    moLabel := mlab
    [pl, pb, plab] = f_draw_ref(pcVisible, prevClose, pcState, pcBull, pcFar, dominantIdx == 3, prevCloseStart, 3, "P-Close", showConfluenceZone and clusterValid and labelDensity != "Detailed" and inPcCluster)
    pcLine := pl
    pcBand := pb
    pcLabel := plab

// -------------------------------------------------
// Confluence Zone
// -------------------------------------------------
if barstate.islast
    if showConfluenceZone and clusterValid and labelDensity != "Detailed"
        if inDoCluster
            f_delete_label(doLabel)
            doLabel := na
        if inWoCluster
            f_delete_label(woLabel)
            woLabel := na
        if inMoCluster
            f_delete_label(moLabel)
            moLabel := na
        if inPcCluster
            f_delete_label(pcLabel)
            pcLabel := na

    if showConfluenceZone and clusterValid
        f_delete_box(confBox)
        f_delete_label(confLabel)
        leftX = math.max(0, bar_index - 4)
        rightX = bar_index + projectionBars
        topY = clusterTop + math.max(bandDist * 0.60, syminfo.mintick * 20)
        botY = clusterBot - math.max(bandDist * 0.60, syminfo.mintick * 20)
        cCol = f_state_color(domState, domBull)
        confBox := box.new(leftX, topY, rightX, botY, xloc = xloc.bar_index, bgcolor = color.new(cCol, 88), border_color = color.new(cCol, 40))
        confText = "REFERENCE CLUSTER\n" + clusterLabel + "\nControl " + str.tostring(controlScore) + "/100"
        confLabel := label.new(int(math.round((leftX + rightX) / 2.0)), (topY + botY) / 2.0, confText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(cCol, 4), textcolor = f_text_on(cCol), size = labelSize, textalign = text.align_center)
    else if showControlArea and dominantIdx >= 0 and not na(domPrice)
        f_delete_box(confBox)
        f_delete_label(confLabel)
        leftX = math.max(0, bar_index - 4)
        rightX = bar_index + projectionBars
        areaHalf = math.max(bandDist * 0.72, atr14 * 0.10)
        topY = domPrice + areaHalf
        botY = domPrice - areaHalf
        cCol = f_state_color(domState, domBull)
        confBox := box.new(leftX, topY, rightX, botY, xloc = xloc.bar_index, bgcolor = color.new(cCol, 91), border_color = color.new(cCol, 46))
        confText = "CONTROL AREA\n" + f_ref_name(dominantIdx) + " | " + str.tostring(controlScore) + "/100"
        confLabel := label.new(int(math.round((leftX + rightX) / 2.0)), domPrice, confText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(cCol, 4), textcolor = f_text_on(cCol), size = labelSize, textalign = text.align_center)
    else
        f_delete_box(confBox)
        f_delete_label(confLabel)
        confBox := na
        confLabel := na

// -------------------------------------------------
// First Touch Marks And Live Tag
// -------------------------------------------------
touchMarksAllowed = showFirstMarks and labelDensity == "Detailed" and bar_index > last_bar_index - 45

if touchMarksAllowed
    if doFT and showDO and not na(dailyOpen)
        f_keep_touch_label(label.new(bar_index, dailyOpen, "Touch", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 4), textcolor = f_text_on(neutralColor), size = labelSize))
    if woFT and showWO and not na(weeklyOpen)
        f_keep_touch_label(label.new(bar_index, weeklyOpen, "Touch", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 4), textcolor = f_text_on(neutralColor), size = labelSize))
    if moFT and showMO and not na(monthlyOpen)
        f_keep_touch_label(label.new(bar_index, monthlyOpen, "Touch", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 4), textcolor = f_text_on(neutralColor), size = labelSize))
    if pcFT and showPC and not na(prevClose)
        f_keep_touch_label(label.new(bar_index, prevClose, "Touch", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 4), textcolor = f_text_on(neutralColor), size = labelSize))

actionText = dominantIdx >= 0 and controlScore >= 70 ? "READY" : dominantIdx >= 0 ? "MONITOR" : "WAIT"
actionColor = actionText == "READY" ? f_state_color(domState, domBull) : actionText == "MONITOR" ? accentColor : neutralColor
locationText = dominantIdx < 0 ? "No Control" : close > domPrice ? "Above Control" : close < domPrice ? "Below Control" : "At Control"
workflowText = dominantIdx >= 0 and controlScore >= 70 ? "Track Control" : dominantIdx >= 0 ? "Review Reference" : "Standby"

if showLiveTag and barstate.islast
    f_delete_label(liveTag)
    liveY = dominantIdx >= 0 ? (close >= domPrice ? domPrice + atr14 * 0.70 : domPrice - atr14 * 0.70) : close + atr14
    liveStyle = dominantIdx >= 0 and close < domPrice ? label.style_label_up : label.style_label_down
    liveColor = dominantIdx >= 0 ? f_state_color(domState, domBull) : neutralColor
    liveTag := label.new(bar_index + projectionBars + liveTagOffsetBars, liveY, "Control " + (dominantIdx >= 0 ? f_ref_name(dominantIdx) : "None") + "  " + str.tostring(controlScore) + "/100", xloc = xloc.bar_index, yloc = yloc.price, style = liveStyle, color = color.new(liveColor, 0), textcolor = f_text_on(liveColor), size = labelSize)
else if not showLiveTag
    f_delete_label(liveTag)
    liveTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na
var string lastPanelPosition = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false

panelNeedsRebuild = showPanel and (na(panel) or lastPanelPosition != panelPosition or lastPanelTheme != panelTheme or not lastPanelVisible)

if panelNeedsRebuild
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPosition), 2, 9, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Reference Price Operating Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelPosition := panelPosition
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    color controlBg = dominantIdx >= 0 ? f_state_color(domState, domBull) : neutralColor
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 1, 1, 8)
    table.cell(panel, 0, 0, "AG Pro Reference Price Operating Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 0, 1, "Workflow", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, workflowText, text_color = dominantIdx >= 0 ? f_state_color(domState, domBull) : panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Control", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, dominantName, text_color = f_text_on(controlBg), bgcolor = controlBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Action", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, actionText, text_color = f_text_on(actionColor), bgcolor = actionColor, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Score / State", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, str.tostring(controlScore) + " / " + f_state_text(domState), text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Reclaim Rate", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, reclaimRead, text_color = reclaimCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 6, "Location", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, locationText, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 7, "Confluence", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, str.tostring(clusterCount) + " Refs", text_color = panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 8, "Active", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 8, str.tostring(activeCount) + " / 4", text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
touchFire = barstate.isconfirmed and (doFT or woFT or moFT or pcFT)
reclaimFire = barstate.isconfirmed and anyRec
rejectFire = barstate.isconfirmed and ((doState == ST_REJECTED and doState[1] != ST_REJECTED) or (woState == ST_REJECTED and woState[1] != ST_REJECTED) or (moState == ST_REJECTED and moState[1] != ST_REJECTED) or (pcState == ST_REJECTED and pcState[1] != ST_REJECTED))
controlChanged = barstate.isconfirmed and dominantIdx != dominantIdx[1]

alertcondition(enableAlerts and touchFire, "Reference First Touch", "Reference Price Operating Map: a reference level received its first touch. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and reclaimFire, "Reference Reclaimed", "Reference Price Operating Map: a reference level was reclaimed. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and rejectFire, "Reference Rejected", "Reference Price Operating Map: a reference level was rejected. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and controlChanged, "Controlling Reference Changed", "Reference Price Operating Map: the controlling reference changed. This is an attention marker, not a trade instruction.")

plot(rcRate, "Reclaim Follow Rate", color = bullColor, display = display.data_window)
````
