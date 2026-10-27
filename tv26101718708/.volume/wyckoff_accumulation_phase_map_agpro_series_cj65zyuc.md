# Wyckoff Accumulation Phase Map [AGPro Series]

- url: https://www.tradingview.com/script/cJ65zYuc-Wyckoff-Accumulation-Phase-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;41108b657af24da79f4190d02083fb66
- version: 3.0

## Description

Wyckoff Accumulation Phase Map [AGPro Series]


🟢 OVERVIEW

Wyckoff Accumulation Phase Map is the bullish counterpart of the Wyckoff Distribution Phase Map and completes the AGPro Wyckoff structural cycle. It is a retrospective structural mapping tool that locates and labels the seven core accumulation events — Preliminary Support (PS), Selling Climax (SC), Automatic Rally (AR), Secondary Test (ST), Spring, Last Point of Support (LPS) and Sign of Strength (SOS) — only after a bullish Change of Character (CHoCH) confirms that the prior downtrend has structurally broken. The indicator frames the active trading range as a shaded zone, plots SC and AR horizontal references, tracks the current phase (A, B, C, D, E) in a dedicated info panel, and introduces three accumulation-specific layers absent from the distribution companion: a Spring Quality Score, a Cause-to-Effect markup projection and a rolling volume footprint classifier.


🟢 COMPANION TO THE DISTRIBUTION PHASE MAP

This indicator is intentionally designed as the symmetric counterpart of Wyckoff Distribution Phase Map [AGPro Series]. The two scripts share a unified AGPro visual language and a CHoCH-gated reveal philosophy, but they operate on opposite market regimes and different event sets:

- Distribution map works on uptrends and draws PSY, BC, AR, UT, SOW and LPSY after a bearish CHoCH.
- Accumulation map works on downtrends and draws PS, SC, AR, ST, Spring, LPS and SOS after a bullish CHoCH.
- Distribution projects a potential markdown line from LPSY.
- Accumulation projects a Cause-to-Effect markup target from SOS.
- Accumulation additionally provides a 0-100 Spring Quality Score, which has no structural equivalent in the distribution schematic.

Both tools are standalone. Users running the full AGPro Wyckoff workflow can apply them together for complete cycle coverage, but neither depends on the other.


🟢 WHAT MAKES IT DIFFERENT

Most Wyckoff scripts on TradingView react to every elevated swing low during a downtrend and label PS / SC / Spring on every modest dip. The result is a noisy chart, often with contradictory events stacked on top of each other. This indicator takes the opposite approach. During a qualified downtrend, the chart remains completely clean. Rolling trackers silently maintain candidate values for SC, PS and AR in memory, while a live Watching row in the panel shows what the engine is currently monitoring. Events are only drawn on the chart after a bullish CHoCH locks the schematic, at which point PS, SC and AR appear together as a confirmed retrospective bundle. ST, Spring, LPS and SOS then populate as post-CHoCH structure unfolds. A multi-tier expiry system closes both incomplete and fully-played-out accumulations, ensuring the active schematic on screen always reflects current market structure and not stale history.


🟢 METHODOLOGY

The engine runs in three coordinated layers.

Layer one qualifies a prior downtrend. A valid Wyckoff accumulation precondition requires four concurrent factors: structural lower highs and lower lows, a minimum ATR-multiple depth from the lookback-window high, a duration sustained across the full lookback window, and price currently located in the lower portion of that window. All four conditions must hold before any candidate can form.

Layer two rolls candidate values during that qualified downtrend. SC candidate is the running lowest pivot low with elevated or climactic volume. PS candidate is the prior elevated swing low that predates the SC. AR candidate is the highest post-SC swing high that remains within a structurally reasonable distance from SC. Candidates are automatically invalidated if price drifts far above the SC without a structural break or if the candidate ages beyond a configurable maximum.

Layer three watches for a bullish Change of Character, defined as the first bar that closes above the qualified AR candidate. On CHoCH confirmation, PS, SC and AR are snapshotted as labeled events, the trading range is drawn, and the state machine advances to forward detection. ST, Spring, LPS and SOS are then detected in sequence using a combination of price-to-SC, price-to-AR and volume-to-average filters. Volume context is computed against a configurable moving-average baseline with separate climactic, elevated and weak thresholds.

The Spring Quality Score blends four components into a 0-100 rating: penetration depth below SC, volume dry-up on the sweep bar, recovery strength measured by close position within the candle range, and close location relative to SC. The Cause-to-Effect projection draws a symmetrical markup target from the SOS bar using the trading range height.


🟢 SIGNALS AND ALERTS

The indicator fires three categories of alerts, all reserved for confirmed structural events:

- CHoCH Confirmation alert triggers when the structural break locks in, including the resolved SC and AR levels.
- Spring alert fires when the Spring is detected, including the Spring Quality score.
- Sign of Strength alert fires when SOS confirms with climactic volume above AR.

No alerts are emitted during the forming phase. This keeps notification volume low and focused on decisive structural moments.


🟢 KEY INPUTS

Core Engine inputs control swing lookback sensitivity, candidate maximum age, post-CHoCH timeout, prior downtrend lookback, minimum downtrend depth in ATR multiples, and the near-lows threshold used in downtrend qualification. Volume Analysis exposes the moving-average length and three separate multipliers for climactic, elevated and weak volume classification. Visual inputs toggle the trading range zone, SC and AR horizontal levels, the CHoCH dashed break line, the Cause-to-Effect projection, the floating summary label and the keep-historical-events mode, with full control over font size and zone transparency. The info panel can be repositioned to six anchor points and switched between dark and light themes.


🟢 HOW TO USE

Apply the indicator to any liquid instrument and any timeframe. During downtrends, observe the Watching row in the panel to monitor the forming SC candidate. When CHoCH prints, the full PS, SC and AR bundle appears and the trading range is shaded. From that point, use the Next Expected row to track what the engine is waiting for. The Confidence score progresses from 70 at CHoCH to 97 at SOS. The Spring Quality Score becomes populated when a Spring is detected and quantifies the character of the sweep. The Volume Footprint row rolls through Range forming, Supply exhausting, Weak hands shaken, Supply absorbed and Demand in control as the schematic matures. The floating summary label on the right edge of the chart provides an at-a-glance status even when the primary event labels are scrolled off to the left. The indicator works standalone but is designed to complement any market structure, order flow or supply-and-demand workflow.


🟢 LIMITATIONS AND TRANSPARENCY

This tool is a pattern-recognition and labeling engine, not a strategy or a trading signal generator. All events are detected retrospectively after their confirming bar has closed plus the swing lookback period. This is by design to eliminate redrawing. The Wyckoff schematic is a framework, not a deterministic forecast. Not every accumulation completes the full seven-event sequence, and markets frequently fail schematics entirely and resume the prior downtrend. The volume analysis assumes reliable reported volume, so thin or fragmented markets may produce weaker classification. The Spring Quality Score and Confidence score are internal heuristics tied to event progression and are not statistical probabilities. The Cause-to-Effect projection is a classical Wyckoff reference line derived from range height, not a mechanical target guaranteed to be reached. Past schematic completions do not predict future market behavior.


🟢 RISK DISCLOSURE

This indicator is published for educational and analytical purposes only. It does not constitute financial advice, a trading recommendation or an investment solicitation. Trading any financial instrument involves substantial risk, including the potential loss of principal. Past performance does not guarantee future results. Users are solely responsible for their own trading decisions, risk management and independent research. Always backtest thoroughly and trade within a risk framework you understand.

## Source Code

````pine
// -------------------------------------------------
// Wyckoff Accumulation Phase Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.3
//
// Companion script to Wyckoff Distribution Phase Map [AGPro Series].
// CHoCH-gated retrospective mapping of core Wyckoff accumulation events
// after a bullish Change of Character confirms a structural break of the
// prior downtrend. Includes Spring Quality, cause-to-effect projection,
// volume footprint context, phase state, an AR target / SC invalidation
// read, a stop-aware spring follow-through proof rate, and a clean AGPro panel.
// -------------------------------------------------

//@version=6
indicator("Wyckoff Accumulation Phase Map [AGPro Series]",
     shorttitle = "AG Pro WAM",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count = 500)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpCore = "Core Engine"
pivotLen = input.int(10, "Swing Lookback", minval = 3, maxval = 50, group = grpCore,
     tooltip = "Bars of left/right context used to qualify swing highs and lows. Higher values create more structural but slower Wyckoff event mapping.")
candidateMaxAge = input.int(200, "Candidate Maximum Age", minval = 30, maxval = 1000, group = grpCore,
     tooltip = "Maximum bars an SC candidate remains in memory before a confirmed bullish CHoCH. Prevents stale candidates from anchoring old accumulation structures.")
postChochTimeout = input.int(120, "Post-CHoCH Timeout", minval = 30, maxval = 500, group = grpCore,
     tooltip = "Bars allowed after CHoCH for ST, Spring, LPS, and SOS to develop before the schematic is considered expired.")
priorTrendLen = input.int(50, "Prior Downtrend Lookback", minval = 20, maxval = 200, group = grpCore,
     tooltip = "Window used to qualify the prior downtrend before an accumulation candidate can be tracked.")
depthAtrMult = input.float(3.0, "Minimum Downtrend Depth ATR", minval = 1.0, maxval = 10.0, step = 0.5, group = grpCore,
     tooltip = "Minimum drop from the lookback high to the current low, measured in ATR. Filters shallow corrections.")
nearLowsPct = input.float(0.40, "Near-Lows Threshold", minval = 0.20, maxval = 0.80, step = 0.05, group = grpCore,
     tooltip = "Price must be near the lower portion of the recent range to qualify as downtrend pressure.")

grpVol = "Volume Analysis"
volLen = input.int(20, "Volume MA Length", minval = 5, maxval = 100, group = grpVol,
     tooltip = "Volume baseline used for climactic, elevated, and dry-up classification.")
climaxMult = input.float(2.0, "Climactic Volume Multiplier", minval = 1.2, step = 0.1, group = grpVol,
     tooltip = "Multiple of volume baseline required to flag climactic activity.")
elevatedMult = input.float(1.3, "Elevated Volume Multiplier", minval = 1.0, step = 0.05, group = grpVol,
     tooltip = "Multiple of volume baseline used to qualify above-average accumulation activity.")
weakMult = input.float(0.7, "Weak Volume Multiplier", minval = 0.3, maxval = 1.0, step = 0.05, group = grpVol,
     tooltip = "Multiple of volume baseline used to identify dry-up behavior.")

grpVis = "Visuals"
showRangeZone = input.bool(true, "Show Trading Range Zone", group = grpVis)
showCenteredRangeBadge = input.bool(true, "Show Centered Range Badge", group = grpVis,
     tooltip = "Adds a separate centered badge inside the active Wyckoff accumulation range.")
showChochLine = input.bool(true, "Show CHoCH Break Line", group = grpVis)
showScArRefs = input.bool(true, "Show SC and AR References", group = grpVis)
showProjection = input.bool(true, "Show Cause-to-Effect Projection", group = grpVis,
     tooltip = "Projects a symmetrical markup reference from SOS using trading range height. Visual context only.")
showSummaryLabel = input.bool(false, "Show Floating Summary Label", group = grpVis,
     tooltip = "Optional floating label near current price. Off by default because the panel already summarizes the schematic.")
keepHistory = input.bool(false, "Keep Historical Schematics", group = grpVis,
     tooltip = "When disabled, old schematics are cleared when a new cycle begins or expires.")
zoneOpacity = input.int(85, "Zone Transparency", minval = 50, maxval = 95, group = grpVis)
labelSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVis)

grpPan = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPan)
panelPos = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"],
     group = grpPan)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPan)
panelSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPan)

grpAlert = "Alerts"
alertChoch = input.bool(true, "Alert on CHoCH Confirmation", group = grpAlert)
alertSpring = input.bool(true, "Alert on Spring", group = grpAlert)
alertSos = input.bool(true, "Alert on Sign of Strength", group = grpAlert)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
basePanelBg = color.rgb(15, 23, 42)
basePanelBorder = color.rgb(51, 65, 85)
basePanelLabel = color.rgb(148, 163, 184)
basePanelValue = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_panel_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Center" ? position.bottom_center :
     p == "Bottom Left" ? position.bottom_left : position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : basePanelBg

f_panel_label_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(22, 32, 56)

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : basePanelLabel

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : basePanelValue

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : basePanelBorder

f_phase_name(int phs) =>
    phs == 0 ? "None" :
     phs == 1 ? "A - Stopping Action" :
     phs == 2 ? "B - Building Cause" :
     phs == 3 ? "C - Spring Test" :
     phs == 4 ? "D - Sign of Strength" : "E - Markup"

f_draw_label(int x, float y, string txt, color bg, bool above, float offset) =>
    label result = na
    if not na(x) and not na(y)
        labelY = above ? y + offset : y - offset
        labelStyle = above ? label.style_label_down : label.style_label_up
        result := label.new(x, labelY, txt, xloc = xloc.bar_index, yloc = yloc.price,
             color = bg, textcolor = f_text_on(bg), style = labelStyle, size = f_size(labelSize))
    result

atr = ta.atr(14)
atrSafe = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
labelOff = atrSafe * 0.5

// -------------------------------------------------
// Volume and swing context
// -------------------------------------------------
volAvg = ta.sma(volume, volLen)
isClimaxVol = not na(volAvg) and volume > volAvg * climaxMult
isElevated = not na(volAvg) and volume > volAvg * elevatedMult
isWeakVol = not na(volAvg) and volume < volAvg * weakMult

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
isPivotHigh = not na(ph)
isPivotLow = not na(pl)
phBar = bar_index - pivotLen
plBar = bar_index - pivotLen

var float lastSwingHigh = na
var float prevSwingHigh = na
var float lastSwingLow = na
var float prevSwingLow = na

if isPivotHigh
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := ph
if isPivotLow
    prevSwingLow := lastSwingLow
    lastSwingLow := pl

structuralDt = not na(prevSwingHigh) and not na(prevSwingLow) and lastSwingHigh < prevSwingHigh and lastSwingLow < prevSwingLow
lookbackHigh = ta.highest(high, priorTrendLen)
dropFromHigh = lookbackHigh - low
depthQualified = not na(lookbackHigh) and dropFromHigh > atrSafe * depthAtrMult
recentHigh = ta.highest(high, priorTrendLen)
recentLow = ta.lowest(low, priorTrendLen)
recentRange = recentHigh - recentLow
nearLows = recentRange > 0 and (low - recentLow) / recentRange < nearLowsPct
downtrendActive = structuralDt and depthQualified and nearLows

// -------------------------------------------------
// Candidate tracking
// -------------------------------------------------
var float scCandPrice = na
var int scCandBar = na
var float psCandPrice = na
var int psCandBar = na
var float arCandPrice = na
var int arCandBar = na
var int candBirthBar = na

if not na(candBirthBar) and bar_index - candBirthBar > candidateMaxAge
    scCandPrice := na
    scCandBar := na
    psCandPrice := na
    psCandBar := na
    arCandPrice := na
    arCandBar := na
    candBirthBar := na

if not na(scCandPrice) and close > scCandPrice * 1.30
    scCandPrice := na
    scCandBar := na
    psCandPrice := na
    psCandBar := na
    arCandPrice := na
    arCandBar := na
    candBirthBar := na

if downtrendActive and isPivotLow and (isElevated[pivotLen] or isClimaxVol[pivotLen])
    if na(scCandPrice) or pl < scCandPrice
        if not na(scCandPrice)
            psCandPrice := scCandPrice
            psCandBar := scCandBar
        scCandPrice := pl
        scCandBar := plBar
        arCandPrice := na
        arCandBar := na
        if na(candBirthBar)
            candBirthBar := plBar

if not na(scCandBar) and isPivotHigh and phBar > scCandBar
    maxArDistance = scCandPrice * 1.25
    if ph < maxArDistance
        if na(arCandPrice) or ph > arCandPrice
            arCandPrice := ph
            arCandBar := phBar

// -------------------------------------------------
// Confirmed event storage
// -------------------------------------------------
var int chochBar = na
var float chochLevel = na
var bool schemaLocked = false

var int psBar = na
var float psPrice = na
var int scBar = na
var float scPrice = na
var int arBar = na
var float arPrice = na
var int stBar = na
var float stPrice = na
var int springBar = na
var float springPrice = na
var int lpsBar = na
var float lpsPrice = na
var int sosBar = na
var float sosPrice = na
var float rangeHi = na
var float rangeLo = na
var float rangeHgt = na
var float springQuality = na
var int currentPhase = 0
var int confidence = 0

var box rangeBox = na
var line scRefLine = na
var line arRefLine = na
var line chochLine = na
var line projLine = na
var label rangeBadge = na
var label summaryLbl = na
var label psLbl = na
var label scLbl = na
var label arLbl = na
var label stLbl = na
var label springLbl = na
var label lpsLbl = na
var label sosLbl = na
var array<box> histBoxes = array.new<box>()
var array<line> histLines = array.new<line>()
var array<label> histLabels = array.new<label>()

f_store_or_delete_box(box item) =>
    if not na(item)
        if keepHistory
            array.push(histBoxes, item)
        else
            box.delete(item)

f_store_or_delete_line(line item) =>
    if not na(item)
        if keepHistory
            array.push(histLines, item)
        else
            line.delete(item)

f_store_or_delete_label(label item) =>
    if not na(item)
        if keepHistory
            array.push(histLabels, item)
        else
            label.delete(item)

chochCond = not schemaLocked and not na(scCandPrice) and not na(arCandPrice) and close > arCandPrice and close[1] <= arCandPrice and close < arCandPrice * 1.05

if chochCond
    f_store_or_delete_box(rangeBox)
    f_store_or_delete_line(scRefLine)
    f_store_or_delete_line(arRefLine)
    f_store_or_delete_line(chochLine)
    f_store_or_delete_line(projLine)
    f_store_or_delete_label(rangeBadge)
    f_store_or_delete_label(psLbl)
    f_store_or_delete_label(scLbl)
    f_store_or_delete_label(arLbl)
    f_store_or_delete_label(stLbl)
    f_store_or_delete_label(springLbl)
    f_store_or_delete_label(lpsLbl)
    f_store_or_delete_label(sosLbl)
    rangeBox := na
    scRefLine := na
    arRefLine := na
    chochLine := na
    projLine := na
    rangeBadge := na
    psLbl := na
    scLbl := na
    arLbl := na
    stLbl := na
    springLbl := na
    lpsLbl := na
    sosLbl := na

    scBar := scCandBar
    scPrice := scCandPrice
    psBar := psCandBar
    psPrice := psCandPrice
    arBar := arCandBar
    arPrice := arCandPrice
    chochBar := bar_index
    chochLevel := arCandPrice
    rangeHi := arCandPrice
    rangeLo := scCandPrice
    rangeHgt := rangeHi - rangeLo
    schemaLocked := true
    currentPhase := 2
    confidence := 70
    stBar := na
    stPrice := na
    springBar := na
    springPrice := na
    lpsBar := na
    lpsPrice := na
    sosBar := na
    sosPrice := na
    springQuality := na
    scCandPrice := na
    scCandBar := na
    psCandPrice := na
    psCandBar := na
    arCandPrice := na
    arCandBar := na
    candBirthBar := na

// -------------------------------------------------
// Post-CHoCH detection
// -------------------------------------------------
barsSinceChoch = schemaLocked and not na(chochBar) ? bar_index - chochBar : 0
withinWindow = schemaLocked and barsSinceChoch <= postChochTimeout

stCond = withinWindow and isPivotLow and na(stBar) and pl >= scPrice * 0.95 and pl <= scPrice + rangeHgt * 0.40 and plBar > chochBar and (isWeakVol[pivotLen] or not isClimaxVol[pivotLen])
if stCond
    stBar := plBar
    stPrice := pl
    confidence := math.max(confidence, 80)

springCond = withinWindow and na(springBar) and low < scPrice and close > scPrice and bar_index > chochBar + math.max(2, int(math.round(pivotLen * 0.50)))
if springCond
    springBar := bar_index
    springPrice := low
    currentPhase := 3
    penetration = math.min(30.0, (scPrice - low) / atrSafe * 30.0)
    volScore = isWeakVol ? 25.0 : volume < volAvg ? 18.0 : volume < volAvg * 1.5 ? 10.0 : 0.0
    candleRange = math.max(high - low, syminfo.mintick)
    recovery = math.min(25.0, ((close - low) / candleRange) * 25.0)
    closeLoc = close > scPrice ? 20.0 : 0.0
    springQuality := math.round(penetration + volScore + recovery + closeLoc)
    confidence := math.max(confidence, 87)

lpsCond = withinWindow and isPivotLow and na(lpsBar) and not na(springBar) and plBar > springBar and pl > (na(stPrice) ? scPrice : stPrice)
if lpsCond
    lpsBar := plBar
    lpsPrice := pl
    currentPhase := 4
    confidence := math.max(confidence, 92)

sosCond = withinWindow and na(sosBar) and not na(lpsBar) and close > arPrice and isClimaxVol
if sosCond
    sosBar := bar_index
    sosPrice := close
    currentPhase := 5
    confidence := 97

if schemaLocked and not na(chochBar) and na(springBar) and currentPhase < 2
    currentPhase := 2

expired = false
if schemaLocked and not na(chochBar)
    expired := (barsSinceChoch > postChochTimeout and na(sosBar)) or (not na(sosBar) and close > arPrice + rangeHgt * 1.5 and barsSinceChoch > postChochTimeout) or (na(sosBar) and close < scPrice)

if expired
    f_store_or_delete_box(rangeBox)
    f_store_or_delete_line(scRefLine)
    f_store_or_delete_line(arRefLine)
    f_store_or_delete_line(chochLine)
    f_store_or_delete_line(projLine)
    f_store_or_delete_label(rangeBadge)
    f_store_or_delete_label(psLbl)
    f_store_or_delete_label(scLbl)
    f_store_or_delete_label(arLbl)
    f_store_or_delete_label(stLbl)
    f_store_or_delete_label(springLbl)
    f_store_or_delete_label(lpsLbl)
    f_store_or_delete_label(sosLbl)
    rangeBox := na
    scRefLine := na
    arRefLine := na
    chochLine := na
    projLine := na
    rangeBadge := na
    psLbl := na
    scLbl := na
    arLbl := na
    stLbl := na
    springLbl := na
    lpsLbl := na
    sosLbl := na
    schemaLocked := false
    currentPhase := 0
    confidence := 0
    psBar := na
    psPrice := na
    scBar := na
    scPrice := na
    arBar := na
    arPrice := na
    stBar := na
    stPrice := na
    springBar := na
    springPrice := na
    lpsBar := na
    lpsPrice := na
    sosBar := na
    sosPrice := na
    chochBar := na
    chochLevel := na
    rangeHi := na
    rangeLo := na
    rangeHgt := na
    springQuality := na

// -------------------------------------------------
// Stop-aware Proof — spring follow-through
// After a confirmed spring (shakeout), did price reach the AR range high (the
// markup objective) before closing back under the spring low (invalidation)?
// Confirmed-bar gated, resolve-then-open, timeout uncounted, "Building (n)" < 6.
// -------------------------------------------------
proofBuffer = atrSafe * 0.30
var float wamTarget    = na
var float wamStop      = na
var bool  wamProofOpen = false
var int   wamProofAge  = na
var int   wamProofWins = 0
var int   wamProofLosses = 0

if springCond and not na(rangeHi) and barstate.isconfirmed and not wamProofOpen
    wamTarget    := rangeHi
    wamStop      := low - proofBuffer
    wamProofAge  := 0
    wamProofOpen := true

if wamProofOpen and barstate.isconfirmed and not na(wamTarget) and not na(wamStop)
    if close < wamStop
        wamProofLosses += 1
        wamProofOpen := false
    else if high >= wamTarget
        wamProofWins += 1
        wamProofOpen := false
    else
        wamProofAge := nz(wamProofAge) + 1
        if wamProofAge > postChochTimeout
            wamProofOpen := false   // timeout — uncounted

wamProofTotal = wamProofWins + wamProofLosses
wamProofRate  = wamProofTotal == 0 ? 0.0 : 100.0 * wamProofWins / wamProofTotal

// -------------------------------------------------
// Event labels
// -------------------------------------------------
var bool psDrawn = false
var bool scDrawn = false
var bool arDrawn = false
var bool stDrawn = false
var bool springDrawn = false
var bool lpsDrawn = false
var bool sosDrawn = false

if not schemaLocked
    psDrawn := false
    scDrawn := false
    arDrawn := false
    stDrawn := false
    springDrawn := false
    lpsDrawn := false
    sosDrawn := false

if schemaLocked
    if not psDrawn and not na(psBar)
        psLbl := f_draw_label(psBar, psPrice, "PS", bearColor, false, labelOff)
        psDrawn := true
    if not scDrawn and not na(scBar)
        scLbl := f_draw_label(scBar, scPrice, "SC", bearColor, false, labelOff)
        scDrawn := true
    if not arDrawn and not na(arBar)
        arLbl := f_draw_label(arBar, arPrice, "AR", neutralColor, true, labelOff)
        arDrawn := true
    if not stDrawn and not na(stBar)
        stLbl := f_draw_label(stBar, stPrice, "ST", neutralColor, false, labelOff)
        stDrawn := true
    if not springDrawn and not na(springBar)
        springLbl := f_draw_label(springBar, springPrice, "Spring", accentColor, false, labelOff)
        springDrawn := true
    if not lpsDrawn and not na(lpsBar)
        lpsLbl := f_draw_label(lpsBar, lpsPrice, "LPS", bullColor, false, labelOff)
        lpsDrawn := true
    if not sosDrawn and not na(sosBar)
        sosLbl := f_draw_label(sosBar, sosPrice, "SOS", bullColor, true, labelOff)
        sosDrawn := true

// -------------------------------------------------
// Drawings
// -------------------------------------------------
if barstate.islast and schemaLocked
    rngRight = math.max(bar_index + 30, scBar + int(math.round(postChochTimeout * 0.50)))

    if showRangeZone and not na(scBar) and not na(arBar)
        if not na(rangeBox)
            box.delete(rangeBox)
        rangeBox := box.new(scBar, rangeHi, rngRight, rangeLo, xloc = xloc.bar_index,
             bgcolor = color.new(basePanelLabel, zoneOpacity),
             border_color = color.new(basePanelLabel, 40), border_width = 1)

    if showCenteredRangeBadge and showRangeZone and not na(scBar) and not na(arBar)
        if not na(rangeBadge)
            label.delete(rangeBadge)
        badgeX = int(math.round((scBar + rngRight) * 0.50))
        badgeY = (rangeHi + rangeLo) * 0.50
        rangeBadge := label.new(badgeX, badgeY, "ACCUMULATION\nRANGE", xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_label_center, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_size(labelSize))
    else
        if not na(rangeBadge)
            label.delete(rangeBadge)
            rangeBadge := na

    if showScArRefs and not na(scBar)
        if not na(scRefLine)
            line.delete(scRefLine)
        scRefLine := line.new(scBar, scPrice, rngRight, scPrice, xloc = xloc.bar_index,
             color = color.new(bearColor, 30), width = 1, style = line.style_dashed)

    if showScArRefs and not na(arBar)
        if not na(arRefLine)
            line.delete(arRefLine)
        arRefLine := line.new(arBar, arPrice, rngRight, arPrice, xloc = xloc.bar_index,
             color = color.new(neutralColor, 30), width = 1, style = line.style_dashed)

    if showChochLine and not na(chochBar)
        if not na(chochLine)
            line.delete(chochLine)
        chochLine := line.new(chochBar, rangeLo, chochBar, rangeHi + rangeHgt * 0.3, xloc = xloc.bar_index,
             color = color.new(bullColor, 0), width = 2, style = line.style_dashed)

    if showProjection and not na(sosBar) and not na(arPrice) and not na(rangeHgt)
        target = arPrice + rangeHgt
        if not na(projLine)
            line.delete(projLine)
        projLine := line.new(sosBar, target, bar_index + 30, target, xloc = xloc.bar_index,
             color = color.new(bullColor, 30), width = 2, style = line.style_dotted)

if barstate.islast and (not schemaLocked or not showRangeZone) and not na(rangeBox)
    box.delete(rangeBox)
    rangeBox := na

if barstate.islast and showSummaryLabel and schemaLocked
    if not na(summaryLbl)
        label.delete(summaryLbl)
    summaryTxt = f_phase_name(currentPhase)
    if not na(springQuality)
        summaryTxt += " | SQ " + str.tostring(springQuality) + "/100"
    if not na(sosBar) and not na(arPrice) and not na(rangeHgt)
        summaryTxt += " | Target " + str.tostring(arPrice + rangeHgt, format.mintick)
    summaryLbl := label.new(bar_index + 3, close, summaryTxt, xloc = xloc.bar_index, yloc = yloc.price,
         color = color.new(accentColor, 70), textcolor = f_panel_value(), style = label.style_label_left, size = f_size(labelSize))

if barstate.islast and (not showSummaryLabel or not schemaLocked) and not na(summaryLbl)
    label.delete(summaryLbl)
    summaryLbl := na

// -------------------------------------------------
// Panel strings
// -------------------------------------------------
phaseName = f_phase_name(currentPhase)
phaseCol = currentPhase == 0 ? f_panel_label() : currentPhase == 1 ? bearColor : currentPhase == 2 ? neutralColor : currentPhase == 3 ? accentColor : bullColor
volFootprint = not schemaLocked ? "-" : not na(sosBar) ? "Demand in control" : not na(lpsBar) ? "Supply absorbed" : not na(springBar) ? "Weak hands shaken" : not na(stBar) ? "Supply exhausting" : "Range forming"
// Price has cleared the range top without a textbook spring — the schematic ran
// ahead of the classic sequence, so the next-expected read reflects that instead
// of still pointing at a Secondary Test inside the range.
aboveARNoSpring = schemaLocked and not na(arPrice) and na(springBar) and na(sosBar) and close > arPrice
nextEvent = not schemaLocked ? (not na(scCandPrice) ? "Watching SC candidate" : "Downtrend - no candidate yet") :
     aboveARNoSpring ? "Breakout above AR (no spring)" :
     na(stBar) ? "Secondary Test (ST)" : na(springBar) ? "Spring / Shakeout" : na(lpsBar) ? "Last Point of Support" : na(sosBar) ? "Sign of Strength" : "Markup in progress"
nextEventCol = aboveARNoSpring ? accentColor : f_panel_value()
schemaTxt = schemaLocked ? "Locked" : downtrendActive ? "Watching" : "Idle"
schemaCol = schemaLocked ? bullColor : downtrendActive ? neutralColor : f_panel_label()
confCol = confidence >= 90 ? bullColor : confidence >= 70 ? accentColor : confidence >= 40 ? neutralColor : f_panel_label()
sqCol = na(springQuality) ? f_panel_label() : springQuality >= 70 ? bullColor : springQuality >= 40 ? neutralColor : bearColor
sqDisplay = na(springQuality) ? (schemaLocked ? "Awaiting" : "-") : str.tostring(springQuality) + " / 100"
arDisplay = schemaLocked and not na(arPrice) ? str.tostring(arPrice, format.mintick) : "-"
scDisplay = schemaLocked and not na(scPrice) ? str.tostring(scPrice, format.mintick) : "-"
proofText = wamProofTotal < 6 ? "Building (" + str.tostring(wamProofTotal) + ")" : str.tostring(math.round(wamProofRate)) + "% (" + str.tostring(wamProofTotal) + ")"
proofCol = wamProofTotal < 6 ? f_panel_label() : wamProofRate >= 55 ? bullColor : wamProofRate >= 45 ? neutralColor : bearColor

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na

if barstate.islast
    if showPanel
        if na(panel)
            panel := table.new(f_panel_pos(panelPos), 2, 10, bgcolor = f_panel_bg(), border_color = f_panel_border(), border_width = 1, frame_color = f_panel_border(), frame_width = 1)
        table.set_position(panel, f_panel_pos(panelPos))
        table.set_border_color(panel, f_panel_border())
        table.set_frame_color(panel, f_panel_border())
        table.clear(panel, 0, 0, 1, 9)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Wyckoff Accumulation Phase Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelSize), text_halign = text.align_center)
        table.cell(panel, 0, 1, "Schema", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 1, schemaTxt, text_color = schemaCol, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 2, "Current Phase", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 2, phaseName, text_color = phaseCol, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 3, "Confidence", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 3, str.tostring(confidence) + " / 100", text_color = confCol, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 4, "Spring Quality", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 4, sqDisplay, text_color = sqCol, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 5, "Volume Footprint", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 5, volFootprint, text_color = accentColor, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 6, "Next Expected", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 6, nextEvent, text_color = nextEventCol, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 7, "Target (AR)", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 7, arDisplay, text_color = neutralColor, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 8, "Invalidation (SC)", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 8, scDisplay, text_color = bearColor, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 9, "Proof", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelSize))
        table.cell(panel, 1, 9, proofText, text_color = proofCol, bgcolor = f_panel_bg(), text_size = f_size(panelSize), text_halign = text.align_right)
    else
        if not na(panel)
            table.delete(panel)
            panel := na

// -------------------------------------------------
// Alerts
// -------------------------------------------------
if alertChoch and chochCond
    alert("Wyckoff Accumulation CHoCH confirmed | SC: " + str.tostring(scPrice, format.mintick) + " | AR: " + str.tostring(arPrice, format.mintick) + " | " + syminfo.ticker, alert.freq_once_per_bar_close)

if alertSpring and springCond
    alert("Wyckoff Spring detected at " + str.tostring(low, format.mintick) + " | Quality: " + str.tostring(springQuality) + "/100 | " + syminfo.ticker, alert.freq_once_per_bar_close)

if alertSos and sosCond
    alert("Wyckoff Sign of Strength confirmed at " + str.tostring(close, format.mintick) + " | " + syminfo.ticker, alert.freq_once_per_bar_close)
````
