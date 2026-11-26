# Breaker Block Engine [AGPro Series]

- url: https://www.tradingview.com/script/g5r0ZPaS-Breaker-Block-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;5a8f7e94bff54a66a5c99ae667b505aa
- version: 3.0

## Description

Breaker Block Engine [AGPro Series]

Overview

Breaker Block Engine is a dedicated detection and tracking tool for one of the
most misunderstood concepts in Smart Money trading: the Breaker Block. A
breaker block is an order block that has failed and flipped role — a bearish
order block broken upward now behaves as bullish support, and a bullish order
block broken downward now behaves as bearish resistance. The engine does not
just draw them; it validates each break with displacement strength, tracks
every retest, scores how well each breaker has held its role, and surfaces the
dominant bullish and bearish breakers through a clean info panel.

Unique Edge

Most breaker block scripts stop at drawing a flipped zone. This engine goes
further:
- Each break is validated using an ATR-scaled close-based displacement filter,
  optionally combined with above-average volume confirmation, to reject weak
  wick-based breaks.
- Every retest of a breaker is counted and evaluated as Held or Lost, and the
  state label on the chart shows a live retest hold percentage for each
  breaker (for example "Bull Breaker | Held x6 (100%)").
- An invalidation buffer prevents single-wick noise from prematurely killing
  otherwise healthy breakers, while genuinely violated zones fade into a gray
  "Lost" state and are removed from tracking shortly after.
- Intra-side and cross-side confluence grouping automatically clean up
  overlapping labels so the chart stays readable even when several breakers
  cluster within half an ATR.
- The info panel summarises the whole picture in one glance: dominant side,
  active counts per side, nearest breaker distance in both price and ATR
  multiples, and overall retest hold percentage.

Methodology

1. Swing Detection. Confirmed pivot highs and pivot lows are identified using
   a configurable pivot length. These pivots anchor the search for order
   block candidates.
2. Order Block Candidate. For each confirmed pivot high, the script walks
   back up to ten bars looking for the last bearish candle — this is the
   bearish order block candidate. The symmetrical process identifies bullish
   order block candidates around pivot lows.
3. Break Validation. A candidate is promoted to a breaker only when price
   closes past the opposite edge of the order block by at least a
   user-defined ATR multiple (default 0.75 × ATR). An optional volume
   confirmation filter can additionally require the break candle to trade
   above its volume moving average.
4. Retest & Hold Scoring. After formation, each breaker is checked every bar.
   If price re-enters the zone and the close respects the breaker's intended
   direction, a Hold is recorded; otherwise the retest is counted but not
   held. A minimum bar spacing prevents consecutive bars of a sustained
   retest from inflating the counter.
5. Invalidation. If price closes past the far edge of the breaker by more
   than the invalidation buffer (in ATR), the breaker is marked Lost,
   visually faded, and removed from active tracking after a short grace
   period.
6. Confluence Grouping. On the most recent bar, breakers whose mid-points
   sit within max(0.5 × ATR, 0.5 % of price) of each other have their
   overlapping state labels resolved: dead labels yield to alive labels,
   older labels yield to newer ones. A cross-side pass prevents stale
   opposite-side labels from sitting on top of active ones.

Signals & Alerts

The script provides three alert events:
- New Breaker: fires on the bar a bullish or bearish breaker is confirmed.
- Retest Hold: fires when price retests an active breaker and the close
  respects the zone direction.
- Invalidation: fires when an active breaker is broken in the opposite
  direction beyond the invalidation buffer.
On-chart signals include the zone itself (coloured by side), a small
directional triangle at the break point, and a dynamic state label on the
right edge showing the breaker's test count and hold percentage.

Key Inputs

- Swing Pivot Length: bars on each side used to confirm swings. Higher values
  produce fewer but structurally stronger swings.
- Max Active Breakers per Side: hard cap on simultaneously tracked bullish
  and bearish breakers; oldest are pruned when the limit is reached.
- Displacement Strength: ATR multiple required for a close-based break to
  validate. Higher values produce fewer, stronger breakers.
- Require Volume Confirmation: when enabled, the break candle must trade
  above its volume moving average.
- Invalidation Buffer: ATR buffer added beyond the breaker edge before the
  breaker is considered invalidated. Prevents wick-based noise kills.
- Min Bars Between Retests: minimum bar spacing between consecutive retests
  of the same breaker, keeping counters from inflating on sustained visits.
- Zone Transparency, Colours, Label & Panel Sizes: full visual control.
- Panel Location, Theme, Far Zone Threshold: the info panel can be placed in
  any of six positions, switched between Dark and Light theme, and the
  threshold for labelling distant zones as "Far" is user-configurable.

How to Use

- On mid-to-high timeframes (15m and up), leave the defaults. The engine is
  tuned for 15m to 4h out of the box but works on any timeframe and
  instrument.
- Use the state label hold percentage as a quality gauge. A breaker with a
  long history of holds (for example "Held x6 (100%)") has demonstrated
  institutional interest at that level; a breaker with mixed results deserves
  more caution.
- Use the panel to orient quickly. If the dominant side is Bullish and the
  nearest bullish breaker sits within a fraction of an ATR, the chart is in
  a supportive regime for long bias; if both nearest values show "Far",
  price is floating between structures and caution is warranted.
- Combine with higher-timeframe context. A bullish breaker on the 1h that
  aligns with a bullish breaker on the 4h is a stronger zone than either
  alone.

Limitations & Transparency

- This is an indicator, not a strategy. It draws zones and tracks their
  behaviour; it does not generate buy or sell orders, manage positions, or
  calculate performance statistics against a price series.
- Pivot-based detection is inherently lagging by the pivot length: a swing
  is only confirmed once the configured number of bars have printed past it.
- Results depend on input choices. Different displacement multipliers, pivot
  lengths, and retest gaps will produce different breaker sets. The defaults
  are a starting point, not a recommendation.
- No indicator can guarantee future behaviour. A breaker that has held ten
  times in the past can fail the next time it is tested.

Risk Disclosure

This script is provided for educational and research purposes only. It is not
financial advice and does not constitute a recommendation to buy, sell, or
hold any instrument. Trading carries substantial risk of loss. Users are
solely responsible for their own trading decisions and risk management. Past
behaviour of a breaker, or of any zone shown by this script, does not
guarantee future results.

## Source Code

````pine
// -------------------------------------------------
// Breaker Block Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Breaker Block Engine tracks failed order-block transitions after a confirmed
// displacement break, then grades the active breaker lifecycle with a 0-100
// decision score. It focuses on breaker defense, retest quality, invalidation
// distance, target context, and the next chart action without becoming a
// generic order block or fair value gap scanner.
// -------------------------------------------------

//@version=6
indicator("Breaker Block Engine [AGPro Series]",
     shorttitle       = "AG Pro BBE",
     overlay          = true,
     max_boxes_count  = 140,
     max_lines_count  = 220,
     max_labels_count = 300)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpDetect  = "Detection Engine"
grpBreaker = "Breaker Decision Engine"
grpVisual  = "Visuals"
grpPanel   = "Info Panel"
grpAlerts  = "Alerts"

sensitivityMode = input.string("Balanced", "Sensitivity", options=["Conservative", "Balanced", "Aggressive"], group=grpDetect,
     tooltip="Controls how strict the breaker confirmation should be. Conservative requires stronger displacement; Aggressive reacts faster with more zones.")
pivotLen = input.int(5, "Swing Pivot Lookback", minval=2, maxval=20, group=grpDetect,
     tooltip="Bars on each side used to confirm swing highs and lows before searching for breaker candidates.")
sourceSearchBars = input.int(10, "Source Candle Search Bars", minval=3, maxval=30, group=grpDetect,
     tooltip="Maximum number of bars searched behind the confirmed swing for the last opposite candle that can become the breaker source.")
maxActive = input.int(4, "Max Visible Breakers Per Side", minval=1, maxval=8, group=grpDetect,
     tooltip="Caps active bullish and bearish breaker zones per side. Lower values create a cleaner public chart.")
overlapRetirePct = input.float(60.0, "Overlap Retirement Threshold (%)", minval=25.0, maxval=95.0, step=5.0, group=grpDetect,
     tooltip="Retires an older breaker when a new breaker occupies this percentage of the same price pocket. This prevents contradictory or duplicate zones from stacking in one area.")
atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group=grpDetect,
     tooltip="ATR period used for displacement validation, invalidation buffers, label offsets, and distance formatting.")

dispMult = input.float(0.75, "Displacement Strength (x ATR)", minval=0.1, maxval=3.0, step=0.05, group=grpBreaker,
     tooltip="Minimum close-based displacement beyond the source candle required to validate a breaker.")
confirmationMode = input.string("Close + Retest", "Confirmation Mode", options=["Close Only", "Close + Retest", "Close + Volume"], group=grpBreaker,
     tooltip="Close Only can qualify a fresh breaker immediately. Close + Retest waits for defended retest context. Close + Volume requires above-average break volume.")
minReadyScore = input.int(65, "Minimum READY Score", minval=0, maxval=100, group=grpBreaker,
     tooltip="Minimum lifecycle score required before the panel marks an active breaker as READY.")
volLen = input.int(20, "Volume Average Length", minval=5, maxval=100, group=grpBreaker,
     tooltip="Volume average used by the Close + Volume confirmation mode and the origin-quality component of the score.")
invalidBuf = input.float(0.12, "Invalidation Buffer (x ATR)", minval=0.0, maxval=1.0, step=0.01, group=grpBreaker,
     tooltip="ATR buffer beyond the far edge of the breaker zone before a breaker is considered invalidated.")
targetRR = input.float(1.50, "Target Guide Multiple", minval=0.5, maxval=5.0, step=0.25, group=grpBreaker,
     tooltip="Projected target guide measured from the active breaker edge using the invalidation distance as a risk reference.")
retestGap = input.int(5, "Min Bars Between Retests", minval=1, maxval=30, group=grpBreaker,
     tooltip="Minimum spacing between counted retests of the same breaker. This prevents one sustained touch from inflating retest quality.")
timeDecayBars = input.int(160, "Lifecycle Decay Bars", minval=30, maxval=600, group=grpBreaker,
     tooltip="Older breakers gradually lose freshness score and receive stronger expiry shading.")

bullColor = input.color(color.rgb(34, 197, 166), "Bullish Breaker", group=grpVisual,
     tooltip="Primary color used for bullish breaker zones, labels, and defense context.")
bearColor = input.color(color.rgb(244, 114, 182), "Bearish Breaker", group=grpVisual,
     tooltip="Primary color used for bearish breaker zones, labels, and defense context.")
neutralColor = input.color(color.rgb(245, 189, 92), "Neutral / Testing", group=grpVisual,
     tooltip="Color used for testing, monitoring, and non-final breaker states.")
accentColor = input.color(color.rgb(129, 140, 248), "Break Marker Accent", group=grpVisual,
     tooltip="Accent color used for break markers and target guide rails.")
boxOpacity = input.int(82, "Zone Transparency", minval=60, maxval=95, group=grpVisual,
     tooltip="Higher values make breaker zones more transparent. The default keeps zones visible without covering candles.")
zoneForwardBars = input.int(48, "Zone Forward Projection", minval=10, maxval=160, group=grpVisual,
     tooltip="How far active breaker zones and guide rails extend into the future.")
showBreakMark = input.bool(true, "Show Break Marker", group=grpVisual,
     tooltip="Displays a compact directional marker on the bar that confirms a new breaker.")
showEventLabels = input.bool(false, "Show Event Labels", group=grpVisual,
     tooltip="Optionally displays compact NEW, READY, HOLD, and LOST labels outside candle bodies. Disabled by default to preserve the classic clean breaker look.")
maxVisibleEventLabels = input.int(5, "Max Visible Event Labels", minval=3, maxval=20, group=grpVisual,
     tooltip="Limits active event labels so the chart stays readable while still showing enough recent context.")
showGuideRails = input.bool(false, "Show Invalidation and Target Rails", group=grpVisual,
     tooltip="Optionally draws concept-native invalidation and target guide rails for each active breaker. Disabled by default to keep the visual style close to the original publication.")
showInvalidatedBreakers = input.bool(false, "Show Invalidated Breakers", group=grpVisual,
     tooltip="Keeps recently invalidated breaker zones on the chart when enabled. Disabled by default to avoid gray LOST clutter.")
showScoreInZoneLabel = input.bool(true, "Show Score In Zone Label", group=grpVisual,
     tooltip="Adds the 0-100 lifecycle score to each centered breaker badge. Enabled by default for a richer publication-ready chart story.")
labelOffsetAtr = input.float(0.45, "Event Label Offset (x ATR)", minval=0.05, maxval=2.0, step=0.05, group=grpVisual,
     tooltip="Vertical offset used to keep event labels above or below candles instead of inside the candle body.")
labelSizeInput = input.string("Normal", "Label Font Size", options=["Tiny", "Small", "Normal", "Large"], group=grpVisual,
     tooltip="Controls the font size for on-chart breaker and event labels.")

showPanel = input.bool(true, "Show Info Panel", group=grpPanel,
     tooltip="Displays the AGPro decision panel. Enabled by default for publication screenshots.")
panelLoc = input.string("Top Right", "Panel Location", options=["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group=grpPanel,
     tooltip="Selects where the information panel appears on the chart.")
panelTheme = input.string("AGPro Dark", "Panel Theme", options=["AGPro Dark", "Slate Light"], group=grpPanel,
     tooltip="Controls the panel color theme.")
panelSizeInput = input.string("Normal", "Panel Font Size", options=["Tiny", "Small", "Normal", "Large"], group=grpPanel,
     tooltip="Controls the text size used in the information panel.")
farThreshold = input.float(3.0, "Far Zone Threshold (x ATR)", minval=1.0, maxval=10.0, step=0.5, group=grpPanel,
     tooltip="Distances beyond this ATR multiple are shown as Far in the panel to avoid overemphasizing irrelevant zones.")

alertOnNew = input.bool(true, "Alert on New Breaker", group=grpAlerts,
     tooltip="Enables alert conditions when a new bullish or bearish breaker is confirmed.")
alertOnReady = input.bool(true, "Alert on READY Breaker", group=grpAlerts,
     tooltip="Enables alert conditions when a retested breaker reaches the READY score threshold.")
alertOnRetest = input.bool(true, "Alert on Retest Hold", group=grpAlerts,
     tooltip="Enables alert conditions when a breaker retest is held but does not yet reach READY state.")
alertOnInval = input.bool(true, "Alert on Invalidation", group=grpAlerts,
     tooltip="Enables alert conditions when an active breaker closes beyond its invalidation buffer.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)

isDarkPanel = panelTheme == "AGPro Dark"
panelBg = isDarkPanel ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)
panelBorder = isDarkPanel ? color.rgb(51, 65, 85) : color.rgb(203, 213, 225)
panelLabelCol = isDarkPanel ? color.rgb(148, 163, 184) : color.rgb(71, 85, 105)
panelValueCol = isDarkPanel ? color.rgb(226, 232, 240) : color.rgb(15, 23, 42)
labelTextCol = color.rgb(245, 247, 250)

deadLifeBars = 12

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_toSize(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.normal

f_tablePos(string loc) =>
    switch loc
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_scoreText(float score) =>
    str.tostring(math.round(score))

f_priceText(float level) =>
    na(level) ? "-" : str.tostring(level, format.mintick)

f_scoreColor(float score) =>
    score >= minReadyScore ? bullColor : score >= math.max(45, minReadyScore - 15) ? neutralColor : bearColor

f_zoneMidX(int leftBar) =>
    int(math.round((leftBar + bar_index + zoneForwardBars) / 2.0))

labelTxtSize = f_toSize(labelSizeInput)
panelTxtSize = f_toSize(panelSizeInput)

// -------------------------------------------------
// Core series
// -------------------------------------------------
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
volRatio = volAvg > 0 ? volume / volAvg : 1.0
sensitivityFactor = sensitivityMode == "Conservative" ? 1.15 : sensitivityMode == "Aggressive" ? 0.85 : 1.0
breakThr = atr * dispMult * sensitivityFactor
volumeConfirmed = volume > volAvg
volumeModeOk = confirmationMode != "Close + Volume" or volumeConfirmed
readyNeedsRetest = confirmationMode == "Close + Retest"
confirmedBar = barstate.isconfirmed

phPrice = ta.pivothigh(high, pivotLen, pivotLen)
plPrice = ta.pivotlow(low, pivotLen, pivotLen)

// -------------------------------------------------
// Breaker type
// -------------------------------------------------
type Breaker
    int id
    bool isBull
    float top
    float bot
    int bornBar
    int obBar
    float breakLevel
    float originScore
    float quality
    int retests
    int holds
    bool alive
    box bx
    label breakLbl
    label stateLbl
    line invalidLine
    line targetLine
    int lastRetestBar
    int deadSince

var array<Breaker> bulls = array.new<Breaker>()
var array<Breaker> bears = array.new<Breaker>()
var array<label> eventLabels = array.new<label>()
var int nextId = 0

// Per-bar alert signals.
newBullAlert = false
newBearAlert = false

// -------------------------------------------------
// Pending source candles
// -------------------------------------------------
var float bearSourceTop = na
var float bearSourceBot = na
var int bearSourceBar = na
var float bullSourceTop = na
var float bullSourceBot = na
var int bullSourceBar = na

if not na(phPrice)
    for i = pivotLen to pivotLen + sourceSearchBars
        if i < bar_index and close[i] < open[i]
            bearSourceTop := high[i]
            bearSourceBot := low[i]
            bearSourceBar := bar_index - i
            break

if not na(plPrice)
    for i = pivotLen to pivotLen + sourceSearchBars
        if i < bar_index and close[i] > open[i]
            bullSourceTop := high[i]
            bullSourceBot := low[i]
            bullSourceBar := bar_index - i
            break

// -------------------------------------------------
// Score and visual helpers
// -------------------------------------------------
f_originScore(float topV, float botV, float breakLvl) =>
    zoneHeight = math.max(topV - botV, syminfo.mintick)
    dispScore = f_clamp(math.abs(close - breakLvl) / math.max(breakThr, syminfo.mintick) * 14.0, 0.0, 14.0)
    volumeScore = f_clamp((volRatio - 0.80) / 1.20 * 8.0, 0.0, 8.0)
    compactScore = f_clamp(8.0 - math.max(0.0, zoneHeight / math.max(atr, syminfo.mintick) - 1.35) * 4.0, 2.0, 8.0)
    f_clamp(dispScore + volumeScore + compactScore, 0.0, 30.0)

f_invalidLevel(Breaker br, bool isBull) =>
    isBull ? br.bot - atr * invalidBuf : br.top + atr * invalidBuf

f_targetLevel(Breaker br, bool isBull) =>
    inv = f_invalidLevel(br, isBull)
    riskRef = isBull ? br.top - inv : inv - br.bot
    isBull ? br.top + riskRef * targetRR : br.bot - riskRef * targetRR

f_reclaimScore(Breaker br, bool isBull) =>
    mid = (br.top + br.bot) / 2.0
    if isBull
        close > br.top ? 20.0 : close >= mid ? 14.0 : close >= br.bot ? 8.0 : 0.0
    else
        close < br.bot ? 20.0 : close <= mid ? 14.0 : close <= br.top ? 8.0 : 0.0

f_quality(Breaker br, bool isBull) =>
    retestComponent = br.retests > 0 ? 25.0 * br.holds / br.retests : 12.0
    reclaimComponent = f_reclaimScore(br, isBull)
    reactionComponent = f_clamp(br.holds * 5.0, 0.0, 10.0)
    age = bar_index - br.bornBar
    freshnessComponent = f_clamp(15.0 * (1.0 - age / timeDecayBars), 0.0, 15.0)
    f_clamp(br.originScore + retestComponent + reclaimComponent + reactionComponent + freshnessComponent, 0.0, 100.0)

f_holdRate(Breaker br) =>
    br.retests > 0 ? 100.0 * br.holds / br.retests : na

f_defenseState(Breaker br, bool isBull) =>
    holdRate = f_holdRate(br)
    age = bar_index - br.bornBar
    if not br.alive
        "Invalidated"
    else if br.retests == 0
        "Fresh"
    else if not na(holdRate) and holdRate >= 70 and f_reclaimScore(br, isBull) >= 14
        "Defended"
    else if not na(holdRate) and holdRate < 50
        "Weakening"
    else if age > timeDecayBars
        "Aging"
    else
        "Testing"

f_zoneLabelText(Breaker br, bool isBull) =>
    baseTxt = (isBull ? "BULL" : "BEAR") + " BREAKER"
    scoreTxt = showScoreInZoneLabel ? " | Q" + f_scoreText(br.quality) : ""
    if not br.alive
        baseTxt + " | LOST" + scoreTxt
    else if br.retests == 0
        baseTxt + " | FRESH" + scoreTxt
    else if br.holds > 0
        holdRate = f_holdRate(br)
        rateTxt = na(holdRate) ? "" : " (" + str.tostring(math.round(holdRate)) + "%)"
        baseTxt + " | HELD " + str.tostring(br.holds) + "x" + rateTxt + scoreTxt
    else
        baseTxt + " | TEST" + scoreTxt

f_badgeColor(Breaker br, bool isBull) =>
    state = f_defenseState(br, isBull)
    if not br.alive
        color.gray
    else if state == "Fresh" or state == "Testing" or state == "Aging"
        neutralColor
    else if state == "Weakening"
        bearColor
    else
        isBull ? bullColor : bearColor

f_action(Breaker br, bool isBull) =>
    state = f_defenseState(br, isBull)
    retestOk = not readyNeedsRetest or br.retests > 0
    if not br.alive
        "Remove Context"
    else if br.quality >= minReadyScore and retestOk and state != "Weakening"
        "READY"
    else if br.retests == 0 and readyNeedsRetest
        "Wait Retest"
    else if state == "Weakening"
        "Reduce Trust"
    else if br.quality >= math.max(40, minReadyScore - 15)
        "Monitor"
    else
        "Stand Aside"

f_eventLabel(bool isBull, string txt, float y, color bgCol) =>
    if showEventLabels
        labStyle = isBull ? label.style_label_up : label.style_label_down
        ev = label.new(bar_index, y, txt, style=labStyle, color=bgCol, textcolor=labelTextCol, size=labelTxtSize)
        array.push(eventLabels, ev)
        while array.size(eventLabels) > maxVisibleEventLabels
            old = array.shift(eventLabels)
            if not na(old)
                label.delete(old)

f_createBreaker(int newId, bool isBull, float topV, float botV, int obBar, float breakLvl) =>
    col = isBull ? bullColor : bearColor
    bgCol = color.new(col, boxOpacity)
    bx = box.new(left=obBar, top=topV, right=bar_index + zoneForwardBars, bottom=botV,
         bgcolor=bgCol, border_color=col, border_width=1)
    label breakLabel = na
    if showBreakMark
        breakLabel := label.new(bar_index, isBull ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr,
             text="", style=isBull ? label.style_triangleup : label.style_triangledown,
             color=accentColor, textcolor=labelTextCol, size=size.tiny)
    label stateLabel = label.new(f_zoneMidX(obBar), (topV + botV) / 2.0,
         text=(isBull ? "BULL" : "BEAR") + " BREAKER | FRESH",
         style=label.style_label_center, color=neutralColor, textcolor=labelTextCol, size=labelTxtSize)
    line invLine = na
    line tgtLine = na
    tempOrigin = f_originScore(topV, botV, breakLvl)
    tempBreaker = Breaker.new(id=newId, isBull=isBull, top=topV, bot=botV, bornBar=bar_index, obBar=obBar,
         breakLevel=breakLvl, originScore=tempOrigin, quality=0.0, retests=0, holds=0, alive=true,
         bx=bx, breakLbl=breakLabel, stateLbl=stateLabel, invalidLine=invLine, targetLine=tgtLine,
         lastRetestBar=bar_index, deadSince=0)
    if showGuideRails
        invLevel = f_invalidLevel(tempBreaker, isBull)
        tgtLevel = f_targetLevel(tempBreaker, isBull)
        invLine := line.new(obBar, invLevel, bar_index + zoneForwardBars, invLevel, color=color.new(col, 10), style=line.style_dashed, width=1)
        tgtLine := line.new(obBar, tgtLevel, bar_index + zoneForwardBars, tgtLevel, color=color.new(accentColor, 35), style=line.style_dotted, width=1)
        tempBreaker.invalidLine := invLine
        tempBreaker.targetLine := tgtLine
    tempBreaker.quality := f_quality(tempBreaker, isBull)
    if not na(tempBreaker.stateLbl)
        label.set_text(tempBreaker.stateLbl, f_zoneLabelText(tempBreaker, isBull))
        label.set_color(tempBreaker.stateLbl, f_badgeColor(tempBreaker, isBull))
    eventY = isBull ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    f_eventLabel(isBull, "NEW " + f_scoreText(tempBreaker.quality), eventY, col)
    tempBreaker

f_deleteBreaker(Breaker br) =>
    box.delete(br.bx)
    if not na(br.breakLbl)
        label.delete(br.breakLbl)
    if not na(br.stateLbl)
        label.delete(br.stateLbl)
    if not na(br.invalidLine)
        line.delete(br.invalidLine)
    if not na(br.targetLine)
        line.delete(br.targetLine)

f_pruneOld(array<Breaker> arr) =>
    while array.size(arr) > maxActive
        old = array.shift(arr)
        f_deleteBreaker(old)

f_overlapRatio(Breaker a, Breaker b) =>
    overlapHeight = math.max(0.0, math.min(a.top, b.top) - math.max(a.bot, b.bot))
    smallerHeight = math.max(math.min(a.top - a.bot, b.top - b.bot), syminfo.mintick)
    overlapHeight / smallerHeight

f_retireOverlaps(array<Breaker> arr, Breaker incoming) =>
    n = array.size(arr)
    if n > 0
        for k = 0 to n - 1
            idx = n - 1 - k
            existing = array.get(arr, idx)
            if existing.alive and f_overlapRatio(existing, incoming) * 100.0 >= overlapRetirePct
                f_deleteBreaker(existing)
                array.remove(arr, idx)

// -------------------------------------------------
// Break detection
// -------------------------------------------------
newBullBreaker = confirmedBar and not na(bearSourceTop) and close > bearSourceTop + breakThr and volumeModeOk
if newBullBreaker
    nextId += 1
    b = f_createBreaker(nextId, true, bearSourceTop, bearSourceBot, bearSourceBar, bearSourceTop)
    f_retireOverlaps(bulls, b)
    f_retireOverlaps(bears, b)
    array.push(bulls, b)
    f_pruneOld(bulls)
    bearSourceTop := na
    bearSourceBot := na
    bearSourceBar := na
    newBullAlert := true

newBearBreaker = confirmedBar and not na(bullSourceBot) and close < bullSourceBot - breakThr and volumeModeOk
if newBearBreaker
    nextId += 1
    b = f_createBreaker(nextId, false, bullSourceTop, bullSourceBot, bullSourceBar, bullSourceBot)
    f_retireOverlaps(bears, b)
    f_retireOverlaps(bulls, b)
    array.push(bears, b)
    f_pruneOld(bears)
    bullSourceTop := na
    bullSourceBot := na
    bullSourceBar := na
    newBearAlert := true

// -------------------------------------------------
// Retest, defense, invalidation, and lifecycle update
// -------------------------------------------------
f_updateBreakers(array<Breaker> arr, bool isBull) =>
    toDelete = array.new<int>()
    bool holdSig = false
    bool readySig = false
    bool lostSig = false
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            br = array.get(arr, i)
            col = isBull ? bullColor : bearColor
            if br.alive
                invalidLevel = f_invalidLevel(br, isBull)
                targetLevel = f_targetLevel(br, isBull)
                invalidated = confirmedBar and (isBull ? close < invalidLevel : close > invalidLevel)
                if invalidated
                    br.alive := false
                    br.deadSince := bar_index
                    br.quality := math.min(br.quality, 20.0)
                    if showInvalidatedBreakers
                        box.set_bgcolor(br.bx, color.new(color.gray, 92))
                        box.set_border_color(br.bx, color.gray)
                        if not na(br.invalidLine)
                            line.set_color(br.invalidLine, color.gray)
                        if not na(br.targetLine)
                            line.set_color(br.targetLine, color.new(color.gray, 70))
                        if not na(br.stateLbl)
                            label.set_text(br.stateLbl, f_zoneLabelText(br, isBull))
                            label.set_color(br.stateLbl, color.gray)
                            label.set_size(br.stateLbl, labelTxtSize)
                    else
                        array.push(toDelete, i)
                    eventY = isBull ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
                    f_eventLabel(isBull, "LOST", eventY, color.gray)
                    lostSig := true
                else
                    inZone = low <= br.top and high >= br.bot
                    spaced = bar_index - br.lastRetestBar >= retestGap
                    if inZone and spaced and confirmedBar
                        br.retests += 1
                        br.lastRetestBar := bar_index
                        held = isBull ? close > br.bot : close < br.top
                        if held
                            br.holds += 1
                            holdSig := true
                    br.quality := f_quality(br, isBull)
                    stateTxt = f_defenseState(br, isBull)
                    actionTxt = f_action(br, isBull)
                    isReadyNow = actionTxt == "READY"
                    if inZone and spaced and confirmedBar and isReadyNow
                        readySig := true
                    if inZone and spaced and confirmedBar
                        eventY = isBull ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
                        eventTxt = isReadyNow ? "READY " + f_scoreText(br.quality) : "HOLD " + f_scoreText(br.quality)
                        eventCol = isReadyNow ? bullColor : neutralColor
                        f_eventLabel(isBull, eventTxt, eventY, eventCol)
                    age = bar_index - br.bornBar
                    fadeBoost = int(math.round(f_clamp(age / timeDecayBars * 10.0, 0.0, 10.0)))
                    activeOpacity = math.min(94, boxOpacity + fadeBoost)
                    box.set_bgcolor(br.bx, color.new(col, activeOpacity))
                    box.set_border_color(br.bx, f_badgeColor(br, isBull))
                    if not na(br.invalidLine)
                        line.set_xy1(br.invalidLine, br.obBar, invalidLevel)
                        line.set_xy2(br.invalidLine, bar_index + zoneForwardBars, invalidLevel)
                        line.set_color(br.invalidLine, color.new(col, 10))
                    if not na(br.targetLine)
                        line.set_xy1(br.targetLine, br.obBar, targetLevel)
                        line.set_xy2(br.targetLine, bar_index + zoneForwardBars, targetLevel)
                        line.set_color(br.targetLine, color.new(accentColor, 35))
                    if not na(br.stateLbl)
                        label.set_x(br.stateLbl, f_zoneMidX(br.obBar))
                        label.set_y(br.stateLbl, (br.top + br.bot) / 2.0)
                        label.set_text(br.stateLbl, f_zoneLabelText(br, isBull))
                        label.set_color(br.stateLbl, f_badgeColor(br, isBull))
                        label.set_size(br.stateLbl, labelTxtSize)
            if br.alive
                box.set_right(br.bx, bar_index + zoneForwardBars)
            if not br.alive and (bar_index - br.deadSince) > deadLifeBars
                array.push(toDelete, i)
            array.set(arr, i, br)
    removeCount = array.size(toDelete)
    if removeCount > 0
        for k = 0 to removeCount - 1
            idx = array.get(toDelete, removeCount - 1 - k)
            if idx < array.size(arr)
                dead = array.get(arr, idx)
                f_deleteBreaker(dead)
                array.remove(arr, idx)
    [holdSig, readySig, lostSig]

[bullHoldSig, bullReadySig, bullLostSig] = f_updateBreakers(bulls, true)
[bearHoldSig, bearReadySig, bearLostSig] = f_updateBreakers(bears, false)

// -------------------------------------------------
// Panel stats
// -------------------------------------------------
f_best(array<Breaker> arr, bool isBull) =>
    int activeCount = 0
    float bestRank = -1.0
    float bestScore = na
    float bestDist = na
    float bestInv = na
    float bestTarget = na
    string bestState = "Waiting"
    string bestAction = "Wait"
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            br = array.get(arr, i)
            if br.alive
                activeCount += 1
                mid = (br.top + br.bot) / 2.0
                dist = math.abs(close - mid)
                distancePenalty = atr > 0 ? math.min(25.0, dist / atr * 5.0) : 0.0
                rank = br.quality - distancePenalty
                if rank > bestRank
                    bestRank := rank
                    bestScore := br.quality
                    bestDist := dist
                    bestInv := f_invalidLevel(br, isBull)
                    bestTarget := f_targetLevel(br, isBull)
                    bestState := f_defenseState(br, isBull)
                    bestAction := f_action(br, isBull)
    [activeCount, bestRank, bestScore, bestDist, bestInv, bestTarget, bestState, bestAction]

[bullActive, bullRank, bullScore, bullDist, bullInv, bullTarget, bullState, bullAction] = f_best(bulls, true)
[bearActive, bearRank, bearScore, bearDist, bearInv, bearTarget, bearState, bearAction] = f_best(bears, false)

hasBull = bullActive > 0
hasBear = bearActive > 0
useBull = hasBull and (not hasBear or bullRank >= bearRank)
useBear = hasBear and not useBull

panelSide = useBull ? "Bullish" : useBear ? "Bearish" : "None"
panelScore = useBull ? bullScore : useBear ? bearScore : 0.0
panelState = useBull ? bullState : useBear ? bearState : "Waiting"
panelInv = useBull ? bullInv : useBear ? bearInv : na
panelTarget = useBull ? bullTarget : useBear ? bearTarget : na
panelDist = useBull ? bullDist : useBear ? bearDist : na
panelActionRaw = useBull ? bullAction : useBear ? bearAction : "Wait"
panelIsFar = not na(panelDist) and atr > 0 and panelDist / atr > farThreshold
panelAction = panelActionRaw == "READY" and panelIsFar ? "Monitor" : panelActionRaw
panelSideColor = useBull ? bullColor : useBear ? bearColor : neutralColor
panelScoreColor = f_scoreColor(panelScore)

f_distText(float dist) =>
    if na(dist)
        "-"
    else
        distAtr = atr > 0 ? dist / atr : 0.0
        distAtr > farThreshold ? "Far" : str.tostring(distAtr, "#.##") + " ATR"

// -------------------------------------------------
// Info panel
// -------------------------------------------------
var table panel = na

if not showPanel and barstate.islast and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_tablePos(panelLoc), 2, 6, bgcolor=panelBg, border_width=1, border_color=panelBorder, frame_width=1, frame_color=panelBorder)

    table.cell(panel, 0, 0, "AG Pro Breaker Block Engine", bgcolor=headerBg, text_color=headerText, text_size=panelTxtSize)
    table.cell(panel, 1, 0, "", bgcolor=headerBg, text_color=headerText, text_size=panelTxtSize)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Breaker Side", bgcolor=panelBg, text_color=panelLabelCol, text_size=panelTxtSize, text_halign=text.align_left)
    table.cell(panel, 1, 1, panelSide, bgcolor=panelBg, text_color=panelSideColor, text_size=panelTxtSize, text_halign=text.align_right)

    table.cell(panel, 0, 2, "Retest Quality", bgcolor=panelBg, text_color=panelLabelCol, text_size=panelTxtSize, text_halign=text.align_left)
    table.cell(panel, 1, 2, f_scoreText(panelScore) + "/100 | " + f_distText(panelDist), bgcolor=panelBg, text_color=panelScoreColor, text_size=panelTxtSize, text_halign=text.align_right)

    table.cell(panel, 0, 3, "Defense State", bgcolor=panelBg, text_color=panelLabelCol, text_size=panelTxtSize, text_halign=text.align_left)
    table.cell(panel, 1, 3, panelState, bgcolor=panelBg, text_color=panelScoreColor, text_size=panelTxtSize, text_halign=text.align_right)

    table.cell(panel, 0, 4, "Invalidation", bgcolor=panelBg, text_color=panelLabelCol, text_size=panelTxtSize, text_halign=text.align_left)
    table.cell(panel, 1, 4, f_priceText(panelInv) + " | T " + f_priceText(panelTarget), bgcolor=panelBg, text_color=panelValueCol, text_size=panelTxtSize, text_halign=text.align_right)

    actionColor = panelAction == "READY" ? bullColor : panelAction == "Reduce Trust" or panelAction == "Stand Aside" or panelAction == "Remove Context" ? bearColor : neutralColor
    table.cell(panel, 0, 5, "Action", bgcolor=panelBg, text_color=panelLabelCol, text_size=panelTxtSize, text_halign=text.align_left)
    table.cell(panel, 1, 5, panelAction, bgcolor=panelBg, text_color=actionColor, text_size=panelTxtSize, text_halign=text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertOnNew and newBullAlert, title="New Bullish Breaker", message="Breaker Block Engine: a new bullish breaker has been confirmed.")
alertcondition(alertOnNew and newBearAlert, title="New Bearish Breaker", message="Breaker Block Engine: a new bearish breaker has been confirmed.")
alertcondition(alertOnReady and bullReadySig, title="Bullish Breaker READY", message="Breaker Block Engine: a bullish breaker reached READY state after retest evaluation.")
alertcondition(alertOnReady and bearReadySig, title="Bearish Breaker READY", message="Breaker Block Engine: a bearish breaker reached READY state after retest evaluation.")
alertcondition(alertOnRetest and bullHoldSig and not bullReadySig, title="Bullish Breaker Retest Hold", message="Breaker Block Engine: a bullish breaker retest was held.")
alertcondition(alertOnRetest and bearHoldSig and not bearReadySig, title="Bearish Breaker Retest Hold", message="Breaker Block Engine: a bearish breaker retest was held.")
alertcondition(alertOnInval and bullLostSig, title="Bullish Breaker Invalidated", message="Breaker Block Engine: a bullish breaker closed beyond its invalidation buffer.")
alertcondition(alertOnInval and bearLostSig, title="Bearish Breaker Invalidated", message="Breaker Block Engine: a bearish breaker closed beyond its invalidation buffer.")
````
