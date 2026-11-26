# Head & Shoulders Auto Detector [AGPro Series]

- url: https://www.tradingview.com/script/fs0cjTGs-Head-Shoulders-Auto-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;d83be3e79ce74663b7d17061911bb15b
- version: 3.0

## Description

Head & Shoulders Auto Detector [AGPro Series]

🎯 **Overview**

Head & Shoulders Auto Detector is a precision pattern recognition tool that automatically identifies classic Head & Shoulders (bearish) and Inverse Head & Shoulders (bullish) reversal formations across any market and timeframe. Built from the ground up for traders who want the full lifecycle of a pattern tracked on-chart — not just a label and a line, but forming → confirmation → target/stop outcome — with a transparent, quality-scored framework that filters low-probability setups before they clutter the chart.

Every pattern carries a composite quality score, a symmetry percentage, an ATR-adaptive neckline, two projection targets, and a live status label that evolves through the pattern's lifespan.

🔹 **Unique Edge**

Most H&S indicators stop at detection. This one goes further:

• **Full lifecycle state machine** — every pattern moves through four explicit states (Forming → Confirmed → Target Hit / Stopped / Invalidated / Expired), and the visuals update in real time at each transition.

• **Dead pattern hygiene** — once a pattern fails or hits target, orphan TP and stop lines are removed, the neckline freezes at the decision bar, and the status label grays out. The chart never accumulates stale clutter.

• **Quality-driven visual hierarchy** — high-quality patterns (Q≥75) are rendered with a star marker and full saturation, mid-tier patterns get standard treatment, and low-tier patterns (Q<60) fade into the background so the trader's eye is guided to what matters.

• **Dual-target projection with R:R** — every confirmation displays both a classic measured-move TP1 and an extended 1.618× TP2, each labeled with the exact reward-to-risk ratio calculated at entry.

• **ATR-adaptive everything** — shoulder tolerance, neckline flatness, head prominence, stop buffer, and label offsets all scale with volatility, so the same settings work across BTC 4H, gold daily, or small-cap stocks.

🔹 **Methodology**

Patterns are detected from confirmed pivot highs and lows using a configurable pivot length. For a valid Head & Shoulders, three same-side pivots (Left Shoulder → Head → Right Shoulder) must satisfy:

• Head extends beyond both shoulders by at least the configured ATR multiple (prominence test).
• Shoulder heights differ by less than the shoulder tolerance in ATR units (symmetry test).
• Two opposite-side pivots between LS-Head and Head-RS define the neckline; their vertical distance must be within the neckline tolerance.
• Composite symmetry score (50% time symmetry, 50% price symmetry) must exceed the minimum threshold.

Quality score combines four weighted components:
• Symmetry (45%) — time + price balance between shoulders
• Neckline flatness (25%) — how horizontal the neckline is
• Volume profile (15%) — head-bar volume relative to shoulder average
• Head prominence (15%) — how clearly the head dominates

Confirmation triggers when price closes beyond the neckline level (interpolated for sloped necklines). Stop is placed at the head level plus an ATR buffer to avoid wick stop-outs. TP1 uses the standard head-to-neckline measured move; TP2 extends to 1.618× that projection.

🔹 **Signals & Alerts**

Four alert events available:

• **Pattern Forming** — a valid H&S or Inverse H&S structure has been detected but not yet confirmed.
• **Pattern Confirmed** — close has broken the neckline; entry is live with TP/Stop drawn.
• **Target Hit** — TP1 has been reached on a confirmed pattern.
• **Neckline Retest** — after confirmation, price has returned to touch the neckline (common high-probability re-entry zone).

🔹 **Key Inputs**

• **Pivot Length** — controls swing-point sensitivity
• **Min Symmetry Score** — minimum shoulder symmetry percentage to accept a pattern (default 60, balanced)
• **Neckline Tolerance (ATR)** — how sloped a neckline is allowed to be
• **Shoulder Height Tolerance (ATR)** — how different the two shoulders can be
• **Head Prominence (ATR)** — minimum head extension beyond shoulders
• **Volume Soft Confirmation** — toggle volume influence on quality score
• **TP1 Method** — Classic (horizontal neckline reference) or Measured Move (slope-aware)
• **Stop Buffer (ATR)** — extra room beyond the head level (default 0.35)
• **Max Pattern Lifetime** — bars after which an unconfirmed pattern expires
• Full visual controls: font size, panel position, theme, zone display, label offset, color palette

🔹 **How to Use**

1. Apply the indicator to any liquid market and timeframe. 4H and higher tend to produce the most reliable formations; intraday works but expects more noise.
2. Watch for patterns labeled with a ⭐ and bright color (Q≥75) — these are the highest-confidence setups.
3. Wait for the ✓ Confirmed status to appear before entering; the ⚡ breakout marker pinpoints the exact confirmation bar.
4. Use the TP1 / TP2 R:R labels to size the trade. Stop is pre-calculated at head level + ATR buffer.
5. Monitor the panel stats over time to understand the indicator's behavior on your specific market — Win Rate, Avg Quality, and Last Signal all update live.
6. Consider combining with trend context (a bearish H&S is far more powerful at resistance in a downtrend than in the middle of a strong uptrend).

🔹 **Limitations & Transparency**

• Pattern detection uses confirmed pivots, so signals appear with a natural delay equal to the Pivot Length setting. This is intrinsic to pivot-based logic, not a flaw.
• Quality score and historical win rate are chart-native calculations based on the loaded history; they are descriptive, not predictive.
• The script does not include multi-timeframe confluence or trend filters — these are deliberate design choices to keep the tool focused and composable with other indicators.
• Volume confirmation is a soft scoring input, not a hard filter, since many crypto pairs and indices have volume data of variable reliability.
• Pattern state transitions use close-based confirmation; intrabar wicks do not trigger state changes except for stop/target hits, which are high/low based as expected.

🔹 **Risk Disclosure**

This indicator is an analytical tool, not a trading recommendation or financial advice. Pattern recognition describes what has formed on a chart; it does not predict future price movement with certainty. Always use proper risk management, position sizing, and confirm signals with your own analysis. Past pattern statistics shown on the panel are descriptive of the visible history and do not guarantee future performance. Trading involves substantial risk of loss.

## Source Code

````pine
// -----------------------------------------------------
// Head & Shoulders Auto Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Automatic Head & Shoulders and Inverse Head & Shoulders pattern detector
// with symmetry scoring, neckline slope tolerance, volume confirmation,
// ATR-adaptive pivot distance, lifecycle tracking, measured targets, stop
// context, neckline retest logic, and a hand-drawn style pattern outline that
// connects the shoulders, neckline anchors, and head so the structure can be
// read visually without guessing.
// -----------------------------------------------------

//@version=6
indicator("Head & Shoulders Auto Detector [AGPro Series]",
     shorttitle = "AG Pro H&S",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500,
     max_polylines_count = 100)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
grpDetect = "Pattern Detection"
pivotLen = input.int(5, "Pivot Length", minval = 2, maxval = 20, group = grpDetect,
     tooltip = "Lookback bars used on each side of a pivot. Higher values produce fewer but more significant swing points.")
symMin = input.float(60.0, "Min Symmetry Score (%)", minval = 30.0, maxval = 95.0, step = 5.0, group = grpDetect,
     tooltip = "Minimum shoulder symmetry score required to accept a pattern.")
necklineTol = input.float(1.5, "Neckline Tolerance (ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = grpDetect,
     tooltip = "Maximum vertical distance between the two neckline anchors in ATR units.")
shoulderTol = input.float(2.5, "Shoulder Height Tolerance (ATR)", minval = 0.5, maxval = 6.0, step = 0.1, group = grpDetect,
     tooltip = "Maximum allowed height difference between left and right shoulders, expressed in ATR units.")
headMinExt = input.float(1.2, "Head Prominence (ATR)", minval = 0.3, maxval = 5.0, step = 0.1, group = grpDetect,
     tooltip = "Minimum distance the head must extend beyond both shoulders, in ATR units.")
volConfirm = input.bool(true, "Volume Soft Confirmation", group = grpDetect,
     tooltip = "When enabled, head volume is compared against the average shoulder volume. It scores the pattern but does not reject it alone.")

grpLife = "Lifecycle & Targets"
showForming = input.bool(true, "Show Forming Patterns", group = grpLife,
     tooltip = "Display patterns detected before neckline confirmation.")
trackRetest = input.bool(true, "Track Neckline Retest", group = grpLife,
     tooltip = "After a neckline break, watch for price returning to the neckline and alert on retest.")
tp1Mode = input.string("Classic", "TP1 Method", options = ["Classic", "Measured Move"], group = grpLife,
     tooltip = "Classic uses head-to-average-neckline distance. Measured Move uses the slope-adjusted neckline reference at the head.")
showTP2 = input.bool(true, "Show Extended Target (TP2)", group = grpLife,
     tooltip = "Adds a second target at 1.618 times the classic projection.")
stopBuffATR = input.float(0.35, "Stop Buffer (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = grpLife,
     tooltip = "Extra distance beyond the head level for the stop context.")
invalidBars = input.int(120, "Max Pattern Lifetime (bars)", minval = 20, maxval = 500, group = grpLife,
     tooltip = "Unconfirmed patterns older than this number of bars are considered failed.")

grpVisual = "Visual"
fontMode = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVisual,
     tooltip = "Font size for pattern labels, anchor labels, and target labels.")
showLabels = input.bool(true, "Show Pattern Labels", group = grpVisual,
     tooltip = "Display compact pattern labels and anchor labels on the detected structure.")
showPatternSketch = input.bool(true, "Show Hand-Drawn Pattern Outline", group = grpVisual,
     tooltip = "Draws the pattern like a manual chart annotation: left shoulder to neckline, neckline to head, head to neckline, and neckline to right shoulder.")
patternLineWidth = input.int(4, "Pattern Outline Width", minval = 1, maxval = 4, group = grpVisual,
     tooltip = "Thickness of the hand-drawn pattern outline. Higher values make the Head & Shoulders body read like a manual chart annotation.")
showPatternGlow = input.bool(true, "Show Pattern Glow", group = grpVisual,
     tooltip = "Adds a translucent backbone under the main outline so the pattern stands out more clearly on dark and light charts.")
showAnchorLabels = input.bool(true, "Show LS / Head / RS Labels", group = grpVisual,
     tooltip = "Adds small labels to the left shoulder, head, and right shoulder anchors so the pattern is easier to read at a glance.")
showShoulderZones = input.bool(true, "Show Shoulder Zones", group = grpVisual,
     tooltip = "Shade rectangular zones around each shoulder for visual anchoring.")
showHeadZone = input.bool(true, "Show Head Zone", group = grpVisual,
     tooltip = "Shade a compact zone around the head pivot so the highest or lowest extreme is visually owned.")
showMeasuredMove = input.bool(true, "Show Measured-Move Arrow", group = grpVisual,
     tooltip = "On confirmation, draws a measured-move arrow from the neckline break down to the projected target with a TARGET badge, the way a measured move is drawn by hand.")
labelOffsetATR = input.float(1.5, "Label Offset (ATR)", minval = 0.5, maxval = 5.0, step = 0.1, group = grpVisual,
     tooltip = "Vertical offset of pattern labels from price in ATR units.")

grpColors = "Colors"
bullColorIn = input.color(color.rgb(34, 197, 166), "Bullish (Inverse H&S)", group = grpColors)
bearColorIn = input.color(color.rgb(244, 114, 182), "Bearish (H&S)", group = grpColors)
neutralIn = input.color(color.rgb(245, 189, 92), "Neutral / Forming", group = grpColors)
accentIn = input.color(color.rgb(129, 140, 248), "Accent (Neckline)", group = grpColors)

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows or hides the AGPro statistics panel.")
panelPos = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Right", "Top Center", "Middle Left", "Middle Right", "Middle Center", "Bottom Left", "Bottom Right", "Bottom Center"],
     group = grpPanel,
     tooltip = "Controls where the statistics panel is placed on the chart.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPanel,
     tooltip = "Visual theme for the panel. Elite Dark is the AGPro default, Slate is softer, and Clean Light is designed for bright chart backgrounds.")
panelFont = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel,
     tooltip = "Font size used inside the panel.")

grpAlerts = "Alerts"
alertForming = input.bool(true, "Alert: Pattern Forming", group = grpAlerts)
alertConfirmed = input.bool(true, "Alert: Pattern Confirmed", group = grpAlerts)
alertTarget = input.bool(true, "Alert: Target Hit", group = grpAlerts)
alertRetest = input.bool(true, "Alert: Neckline Retest", group = grpAlerts)

// -----------------------------------------------------
// Palette
// -----------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
darkInk = color.rgb(17, 24, 39)
bullColor = bullColorIn
bearColor = bearColorIn
neutralColor = neutralIn
accentColor = accentIn

// Luminance-145 contrast: bright badge fills get dark ink, dark fills get the header text.
f_text_on(_bg) =>
    lum = math.round(0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg))
    lum >= 145 ? darkInk : headerText

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_pos(string locationName) =>
    switch locationName
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_pattern_name(bool bearish) =>
    bearish ? "H-S-H" : "S-H-S"

// Densify a segment with collinear sub-points so the curved polyline rounds the
// corners smoothly without overshooting past the shoulder, head, and neckline
// pivots. More steps = the curve hugs the pivots more tightly.
f_addSeg(array<chart.point> pts, int b1, float p1, int b2, float p2, int steps) =>
    for s = 0 to steps - 1
        t = s / float(steps)
        bi = int(math.round(b1 + (b2 - b1) * t))
        pr = p1 + (p2 - p1) * t
        array.push(pts, chart.point.from_index(bi, pr))

fontSize = f_size(fontMode)
panelSize = f_size(panelFont)

// -----------------------------------------------------
// ATR and pivots
// -----------------------------------------------------
atr14 = ta.atr(14)
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

// -----------------------------------------------------
// Pivot buffers
// -----------------------------------------------------
var float[] phPrice = array.new_float()
var int[] phBar = array.new_int()
var float[] phVol = array.new_float()
var float[] plPrice = array.new_float()
var int[] plBar = array.new_int()
var float[] plVol = array.new_float()

f_pushCap3(arrF, arrI, arrV, p, b, v, cap) =>
    array.push(arrF, p)
    array.push(arrI, b)
    array.push(arrV, v)
    if array.size(arrF) > cap
        array.shift(arrF)
        array.shift(arrI)
        array.shift(arrV)

if not na(ph)
    f_pushCap3(phPrice, phBar, phVol, ph, bar_index - pivotLen, volume[pivotLen], 12)
if not na(pl)
    f_pushCap3(plPrice, plBar, plVol, pl, bar_index - pivotLen, volume[pivotLen], 12)

// -----------------------------------------------------
// Pattern state
// State: 0 = none, 1 = forming, 2 = confirmed, 3 = target hit, 4 = failed
// -----------------------------------------------------
type HSPattern
    int id
    bool bearish
    int lsBar
    float lsPrice
    int headBar
    float headPrice
    int rsBar
    float rsPrice
    int nl1Bar
    float nl1Price
    int nl2Bar
    float nl2Price
    float symScore
    float qualScore
    int state
    int confirmBar
    float tp1
    float tp2
    float stop
    bool retested
    line lnNeck
    line lnLSGlow
    line lnHeadGlow
    line lnRSGlow
    line lnRSFinalGlow
    line lnLS
    line lnHead
    line lnRS
    line lnRSFinal
    polyline plOutline
    polyline plGlow
    line lnShoulderGuide
    line lnHeadStem
    label lblPattern
    label lblStatus
    label lblLS
    label lblHead
    label lblRS
    box zoneLS
    box zoneHead
    box zoneRS
    line lnTP1
    line lnTP2
    line lnStop
    label lblTP1
    label lblTP2
    line lnMove
    label lblMove
    label lblTarget

var HSPattern[] patterns = array.new<HSPattern>()
var int nextId = 1
var int lastPatternBar = 0

// -----------------------------------------------------
// Pattern detection
// -----------------------------------------------------
f_detectHS(bool isBear) =>
    arrPrice = isBear ? phPrice : plPrice
    arrBar = isBear ? phBar : plBar
    arrVol = isBear ? phVol : plVol
    sz = array.size(arrPrice)
    result = HSPattern.new()
    result.state := 0
    if sz >= 3
        rsP = array.get(arrPrice, sz - 1)
        rsB = array.get(arrBar, sz - 1)
        rsV = array.get(arrVol, sz - 1)
        hdP = array.get(arrPrice, sz - 2)
        hdB = array.get(arrBar, sz - 2)
        hdV = array.get(arrVol, sz - 2)
        lsP = array.get(arrPrice, sz - 3)
        lsB = array.get(arrBar, sz - 3)
        lsV = array.get(arrVol, sz - 3)

        headValid = isBear ? (hdP > lsP and hdP > rsP) : (hdP < lsP and hdP < rsP)
        headExt = isBear ? math.min(hdP - lsP, hdP - rsP) : math.min(lsP - hdP, rsP - hdP)
        promOK = headExt >= headMinExt * atr14
        shDiff = math.abs(lsP - rsP)
        shOK = shDiff <= shoulderTol * atr14
        spanLH = hdB - lsB
        spanHR = rsB - hdB
        spacingOK = spanLH >= pivotLen and spanHR >= pivotLen and spanLH < 200 and spanHR < 200

        if headValid and promOK and shOK and spacingOK
            oppPrice = isBear ? plPrice : phPrice
            oppBar = isBear ? plBar : phBar
            oppSz = array.size(oppPrice)
            float nl1P = na
            int nl1B = na
            float nl2P = na
            int nl2B = na

            if oppSz > 0
                for i = oppSz - 1 to 0
                    b = array.get(oppBar, i)
                    if b > lsB and b < hdB
                        nl1P := array.get(oppPrice, i)
                        nl1B := b
                        break
                for i = oppSz - 1 to 0
                    b = array.get(oppBar, i)
                    if b > hdB and b < rsB
                        nl2P := array.get(oppPrice, i)
                        nl2B := b
                        break

            if not na(nl1P) and not na(nl2P)
                necklineDelta = math.abs(nl1P - nl2P)
                necklineOK = necklineDelta <= necklineTol * atr14
                if necklineOK
                    timeSym = 100.0 * (1.0 - math.abs(spanLH - spanHR) / math.max(spanLH, spanHR))
                    priceSym = 100.0 * (1.0 - shDiff / math.max(headExt, atr14))
                    priceSymClamped = math.max(0.0, math.min(100.0, priceSym))
                    symScoreLocal = timeSym * 0.5 + priceSymClamped * 0.5
                    if symScoreLocal >= symMin
                        volScore = 50.0
                        if volConfirm and not na(hdV) and not na(lsV) and not na(rsV)
                            avgVol = (lsV + rsV) / 2.0
                            if avgVol > 0
                                volScore := math.min(100.0, 50.0 + (hdV / avgVol - 1.0) * 50.0)
                                volScore := math.max(0.0, volScore)

                        flatScore = 100.0 * (1.0 - necklineDelta / (necklineTol * atr14))
                        flatScore := math.max(0.0, math.min(100.0, flatScore))
                        qualLocal = symScoreLocal * 0.45 + flatScore * 0.25 + volScore * 0.15 + math.min(100.0, headExt / atr14 * 30.0) * 0.15

                        result.bearish := isBear
                        result.lsBar := lsB
                        result.lsPrice := lsP
                        result.headBar := hdB
                        result.headPrice := hdP
                        result.rsBar := rsB
                        result.rsPrice := rsP
                        result.nl1Bar := nl1B
                        result.nl1Price := nl1P
                        result.nl2Bar := nl2B
                        result.nl2Price := nl2P
                        result.symScore := symScoreLocal
                        result.qualScore := qualLocal
                        result.state := 1
                        result.retested := false
    result

// -----------------------------------------------------
// Draw new pattern
// -----------------------------------------------------
f_drawPattern(HSPattern p) =>
    col = p.bearish ? bearColor : bullColor
    sketchCol = color.new(col, 0)
    glowCol = color.new(col, 72)
    softCol = color.new(col, 55)

    p.lnNeck := line.new(p.nl1Bar, p.nl1Price, p.nl2Bar, p.nl2Price, xloc = xloc.bar_index, color = color.new(accentColor, 10), width = 3, style = line.style_solid, extend = extend.right)

    if showPatternSketch
        ptsOutline = array.new<chart.point>()
        curveSteps = 5
        f_addSeg(ptsOutline, p.lsBar, p.lsPrice, p.nl1Bar, p.nl1Price, curveSteps)
        f_addSeg(ptsOutline, p.nl1Bar, p.nl1Price, p.headBar, p.headPrice, curveSteps)
        f_addSeg(ptsOutline, p.headBar, p.headPrice, p.nl2Bar, p.nl2Price, curveSteps)
        f_addSeg(ptsOutline, p.nl2Bar, p.nl2Price, p.rsBar, p.rsPrice, curveSteps)
        array.push(ptsOutline, chart.point.from_index(p.rsBar, p.rsPrice))
        if showPatternGlow
            p.plGlow := polyline.new(ptsOutline, curved = true, closed = false, xloc = xloc.bar_index, line_color = glowCol, line_width = patternLineWidth + 3, line_style = line.style_solid)
        p.plOutline := polyline.new(ptsOutline, curved = true, closed = false, xloc = xloc.bar_index, line_color = sketchCol, line_width = patternLineWidth, line_style = line.style_solid)
        p.lnShoulderGuide := line.new(p.lsBar, p.lsPrice, p.rsBar, p.rsPrice, xloc = xloc.bar_index, color = color.new(col, 80), width = 1, style = line.style_dotted)
        neckAtHead = p.nl1Price + ((p.nl2Price - p.nl1Price) / math.max(1, p.nl2Bar - p.nl1Bar)) * (p.headBar - p.nl1Bar)
        p.lnHeadStem := line.new(p.headBar, p.headPrice, p.headBar, neckAtHead, xloc = xloc.bar_index, color = color.new(accentColor, 28), width = 2, style = line.style_dashed)
    else
        p.lnLS := line.new(p.lsBar, p.lsPrice, p.headBar, p.headPrice, xloc = xloc.bar_index, color = softCol, width = 1, style = line.style_dotted)
        p.lnHead := line.new(p.headBar, p.headPrice, p.rsBar, p.rsPrice, xloc = xloc.bar_index, color = softCol, width = 1, style = line.style_dotted)

    qOpacity = p.qualScore >= 75.0 ? 8 : p.qualScore >= 60.0 ? 18 : 32
    lblY = p.bearish ? p.headPrice + labelOffsetATR * atr14 : p.headPrice - labelOffsetATR * atr14
    txt = f_pattern_name(p.bearish) + " #" + str.tostring(p.id) + "\nQ " + str.tostring(math.round(p.qualScore)) + " | Sym " + str.tostring(math.round(p.symScore)) + "%"
    lblStyle = p.bearish ? label.style_label_down : label.style_label_up
    if showLabels
        p.lblPattern := label.new(p.headBar, lblY, txt, xloc = xloc.bar_index, style = lblStyle, color = color.new(col, qOpacity), textcolor = f_text_on(col), size = fontSize)

    if showForming
        statusY = p.bearish ? p.rsPrice + labelOffsetATR * atr14 * 0.6 : p.rsPrice - labelOffsetATR * atr14 * 0.6
        statusStyle = p.bearish ? label.style_label_down : label.style_label_up
        p.lblStatus := label.new(p.rsBar, statusY, "FORMING", xloc = xloc.bar_index, style = statusStyle, color = color.new(neutralColor, 12), textcolor = f_text_on(neutralColor), size = fontSize)

    if showAnchorLabels and showLabels
        anchorStyle = p.bearish ? label.style_label_down : label.style_label_up
        lsY = p.bearish ? p.lsPrice + atr14 * 0.35 : p.lsPrice - atr14 * 0.35
        hdY = p.bearish ? p.headPrice + atr14 * 0.35 : p.headPrice - atr14 * 0.35
        rsY = p.bearish ? p.rsPrice + atr14 * 0.35 : p.rsPrice - atr14 * 0.35
        p.lblLS := label.new(p.lsBar, lsY, "LS", xloc = xloc.bar_index, style = anchorStyle, color = color.new(col, 12), textcolor = f_text_on(col), size = size.small)
        p.lblHead := label.new(p.headBar, hdY, "HEAD", xloc = xloc.bar_index, style = anchorStyle, color = color.new(col, 0), textcolor = f_text_on(col), size = size.small)
        p.lblRS := label.new(p.rsBar, rsY, "RS", xloc = xloc.bar_index, style = anchorStyle, color = color.new(col, 12), textcolor = f_text_on(col), size = size.small)

    zoneHalf = atr14 * 0.5
    zoneWidth = math.max(pivotLen * 2, 8)
    if showShoulderZones
        p.zoneLS := box.new(p.lsBar - zoneWidth, p.lsPrice + zoneHalf, p.lsBar + zoneWidth, p.lsPrice - zoneHalf, xloc = xloc.bar_index, bgcolor = color.new(col, 88), border_color = color.new(col, 55), border_width = 1)
        p.zoneRS := box.new(p.rsBar - zoneWidth, p.rsPrice + zoneHalf, p.rsBar + zoneWidth, p.rsPrice - zoneHalf, xloc = xloc.bar_index, bgcolor = color.new(col, 88), border_color = color.new(col, 55), border_width = 1)
    if showHeadZone
        p.zoneHead := box.new(p.headBar - zoneWidth, p.headPrice + zoneHalf, p.headBar + zoneWidth, p.headPrice - zoneHalf, xloc = xloc.bar_index, bgcolor = color.new(col, 82), border_color = color.new(col, 45), border_width = 1)
    p

// -----------------------------------------------------
// Pattern completion cleanup.
// The hand-drawn outline, glow, zones, and anchor labels are ALWAYS kept in
// full color — they are the heart of this tool and must never be dimmed.
// Only the live measured-move projection (arrow + TARGET badge) is cleared,
// because that projection is meaningful only while the pattern is active.
// -----------------------------------------------------
f_fadePattern(HSPattern p) =>
    if not na(p.lnMove)
        line.delete(p.lnMove)
    if not na(p.lblMove)
        label.delete(p.lblMove)
    if not na(p.lblTarget)
        label.delete(p.lblTarget)
    p

// -----------------------------------------------------
// Detect and store
// -----------------------------------------------------
if not na(ph) or not na(pl)
    if bar_index - lastPatternBar >= pivotLen * 2
        newBear = f_detectHS(true)
        if newBear.state == 1
            newBear.id := nextId
            nextId += 1
            newBear := f_drawPattern(newBear)
            array.push(patterns, newBear)
            lastPatternBar := bar_index
            if alertForming
                alert("H&S pattern forming on " + syminfo.tickerid + " @ " + timeframe.period, alert.freq_once_per_bar)
        else
            newBull = f_detectHS(false)
            if newBull.state == 1
                newBull.id := nextId
                nextId += 1
                newBull := f_drawPattern(newBull)
                array.push(patterns, newBull)
                lastPatternBar := bar_index
                if alertForming
                    alert("Inverse H&S pattern forming on " + syminfo.tickerid + " @ " + timeframe.period, alert.freq_once_per_bar)

// -----------------------------------------------------
// Lifecycle management
// -----------------------------------------------------
var int activeForming = 0
var int activeConfirmed = 0
var int totalConfirmed = 0
var int totalTargetHit = 0
var int totalFailed = 0
var float qualitySum = 0.0
var int qualityCount = 0
var int lastConfirmBar = na

f_necklineAt(HSPattern p, int b) =>
    dx = p.nl2Bar - p.nl1Bar
    dy = p.nl2Price - p.nl1Price
    slope = dx == 0 ? 0.0 : dy / dx
    p.nl1Price + slope * (b - p.nl1Bar)

if array.size(patterns) > 0
    for i = 0 to array.size(patterns) - 1
        p = array.get(patterns, i)
        if p.state == 1
            nlLevel = f_necklineAt(p, bar_index)
            broken = p.bearish ? close < nlLevel : close > nlLevel
            if broken and bar_index > p.rsBar
                p.state := 2
                p.confirmBar := bar_index
                headToNeckClassic = math.abs(p.headPrice - (p.nl1Price + p.nl2Price) / 2.0)
                headToNeckMeasured = math.abs(p.headPrice - f_necklineAt(p, p.headBar))
                headToNeck = tp1Mode == "Classic" ? headToNeckClassic : headToNeckMeasured
                p.tp1 := p.bearish ? nlLevel - headToNeck : nlLevel + headToNeck
                p.tp2 := p.bearish ? nlLevel - headToNeck * 1.618 : nlLevel + headToNeck * 1.618
                p.stop := p.bearish ? p.headPrice + stopBuffATR * atr14 : p.headPrice - stopBuffATR * atr14
                col = p.bearish ? bearColor : bullColor
                if not na(p.lblStatus)
                    label.set_text(p.lblStatus, "CONFIRMED")
                    label.set_color(p.lblStatus, color.new(col, 6))
                    label.set_textcolor(p.lblStatus, f_text_on(col))
                breakY = p.bearish ? nlLevel - atr14 * 0.25 : nlLevel + atr14 * 0.25
                breakStyle = p.bearish ? label.style_label_up : label.style_label_down
                label.new(bar_index, breakY, "BREAK", xloc = xloc.bar_index, style = breakStyle, color = color.new(col, 12), textcolor = f_text_on(col), size = size.small)
                rrRisk = math.abs(close - p.stop)
                rrReward = math.abs(p.tp1 - close)
                rrRatio = rrRisk > 0 ? rrReward / rrRisk : 0.0
                p.lnTP1 := line.new(bar_index, p.tp1, bar_index + 20, p.tp1, xloc = xloc.bar_index, color = color.new(col, 30), width = 1, style = line.style_dashed, extend = extend.right)
                p.lblTP1 := label.new(bar_index + 1, p.tp1, "TP1  " + str.tostring(rrRatio, "#.##") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 24), textcolor = f_text_on(col), size = fontSize)
                if showTP2
                    rrReward2 = math.abs(p.tp2 - close)
                    rrRatio2 = rrRisk > 0 ? rrReward2 / rrRisk : 0.0
                    p.lnTP2 := line.new(bar_index, p.tp2, bar_index + 20, p.tp2, xloc = xloc.bar_index, color = color.new(col, 50), width = 1, style = line.style_dashed, extend = extend.right)
                    p.lblTP2 := label.new(bar_index + 1, p.tp2, "TP2  " + str.tostring(rrRatio2, "#.##") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 42), textcolor = f_text_on(col), size = fontSize)
                p.lnStop := line.new(bar_index, p.stop, bar_index + 20, p.stop, xloc = xloc.bar_index, color = color.new(neutralColor, 40), width = 1, style = line.style_dotted, extend = extend.right)
                // Measured-move arrow + TARGET badge (hand-drawn measured-move style)
                if showMeasuredMove
                    moveBar = bar_index + 6
                    moveMidY = (nlLevel + p.tp1) / 2.0
                    p.lnMove := line.new(moveBar, nlLevel, moveBar, p.tp1, xloc = xloc.bar_index, color = color.new(col, 6), width = 2, style = line.style_solid)
                    p.lblMove := label.new(moveBar, moveMidY, "MOVE", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 22), textcolor = f_text_on(col), size = fontSize)
                    p.lblTarget := label.new(moveBar, p.tp1, "TARGET", xloc = xloc.bar_index, style = p.bearish ? label.style_label_up : label.style_label_down, color = color.new(col, 6), textcolor = f_text_on(col), size = fontSize)
                totalConfirmed += 1
                qualitySum += p.qualScore
                qualityCount += 1
                lastConfirmBar := bar_index
                if alertConfirmed
                    alert((p.bearish ? "H&S" : "Inverse H&S") + " CONFIRMED on " + syminfo.tickerid + " @ " + timeframe.period + " | Entry: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
            else if bar_index - p.rsBar > invalidBars
                p.state := 4
                if not na(p.lblStatus)
                    label.set_text(p.lblStatus, "EXPIRED")
                    label.set_color(p.lblStatus, color.new(color.gray, 40))
                    label.set_textcolor(p.lblStatus, headerText)
                if not na(p.lnNeck)
                    line.set_extend(p.lnNeck, extend.none)
                    line.set_x2(p.lnNeck, bar_index)
                    line.set_color(p.lnNeck, color.new(color.gray, 60))
                p := f_fadePattern(p)
                totalFailed += 1
            else
                headBreak = p.bearish ? close > p.headPrice : close < p.headPrice
                if headBreak
                    p.state := 4
                    if not na(p.lblStatus)
                        label.set_text(p.lblStatus, "INVALIDATED")
                        label.set_color(p.lblStatus, color.new(color.gray, 40))
                        label.set_textcolor(p.lblStatus, headerText)
                    if not na(p.lnNeck)
                        line.set_extend(p.lnNeck, extend.none)
                        line.set_x2(p.lnNeck, bar_index)
                        line.set_color(p.lnNeck, color.new(color.gray, 60))
                    p := f_fadePattern(p)
                    totalFailed += 1
        else if p.state == 2
            tpHit = p.bearish ? low <= p.tp1 : high >= p.tp1
            if tpHit
                p.state := 3
                if not na(p.lblStatus)
                    label.set_text(p.lblStatus, "TP1 HIT")
                if not na(p.lnNeck)
                    line.set_extend(p.lnNeck, extend.none)
                    line.set_x2(p.lnNeck, bar_index)
                if not na(p.lnTP1)
                    line.set_extend(p.lnTP1, extend.none)
                    line.set_x2(p.lnTP1, bar_index)
                if not na(p.lnTP2)
                    line.delete(p.lnTP2)
                if not na(p.lnStop)
                    line.delete(p.lnStop)
                if not na(p.lblTP2)
                    label.delete(p.lblTP2)
                p := f_fadePattern(p)
                totalTargetHit += 1
                if alertTarget
                    alert((p.bearish ? "H&S" : "Inverse H&S") + " TP1 hit on " + syminfo.tickerid + " @ " + timeframe.period, alert.freq_once_per_bar)
            stopHit = p.bearish ? high >= p.stop : low <= p.stop
            if stopHit and p.state == 2
                p.state := 4
                if not na(p.lblStatus)
                    label.set_text(p.lblStatus, "STOPPED")
                    label.set_color(p.lblStatus, color.new(color.gray, 40))
                    label.set_textcolor(p.lblStatus, headerText)
                if not na(p.lnNeck)
                    line.set_extend(p.lnNeck, extend.none)
                    line.set_x2(p.lnNeck, bar_index)
                    line.set_color(p.lnNeck, color.new(color.gray, 60))
                if not na(p.lnTP1)
                    line.delete(p.lnTP1)
                if not na(p.lnTP2)
                    line.delete(p.lnTP2)
                if not na(p.lnStop)
                    line.delete(p.lnStop)
                if not na(p.lblTP1)
                    label.delete(p.lblTP1)
                if not na(p.lblTP2)
                    label.delete(p.lblTP2)
                p := f_fadePattern(p)
                totalFailed += 1
            if trackRetest and not p.retested and p.state == 2
                nlNow = f_necklineAt(p, bar_index)
                touch = p.bearish ? high >= nlNow and low <= nlNow : low <= nlNow and high >= nlNow
                if touch and bar_index > p.confirmBar + 2
                    p.retested := true
                    if alertRetest
                        alert((p.bearish ? "H&S" : "Inverse H&S") + " neckline retest on " + syminfo.tickerid + " @ " + timeframe.period, alert.freq_once_per_bar)
        array.set(patterns, i, p)

    activeForming := 0
    activeConfirmed := 0
    for i = 0 to array.size(patterns) - 1
        p = array.get(patterns, i)
        if p.state == 1
            activeForming += 1
        else if p.state == 2
            activeConfirmed += 1

    for i = array.size(patterns) - 1 to 0
        p = array.get(patterns, i)
        if (p.state == 3 or p.state == 4) and bar_index - p.rsBar > invalidBars * 2
            array.remove(patterns, i)

// -----------------------------------------------------
// Panel
// -----------------------------------------------------
var table panel = na

if showPanel and barstate.islast
    if na(panel)
        panel := table.new(f_panel_pos(panelPos), 2, 10,
             bgcolor = f_panel_bg(),
             border_color = f_panel_border(),
             border_width = 1,
             frame_color = f_panel_border(),
             frame_width = 1)
    table.set_position(panel, f_panel_pos(panelPos))
    table.clear(panel, 0, 0, 1, 9)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Head & Shoulders Auto Detector", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)

    table.cell(panel, 0, 1, "Active Forming", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, str.tostring(activeForming), text_color = neutralColor, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Active Confirmed", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, str.tostring(activeConfirmed), text_color = accentColor, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Total Confirmed", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(totalConfirmed), text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Target Hits", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, str.tostring(totalTargetHit), text_color = bullColor, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Failed / Stopped", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, str.tostring(totalFailed), text_color = bearColor, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_right)
    avgQ = qualityCount > 0 ? qualitySum / qualityCount : 0.0
    qCol = avgQ >= 70.0 ? bullColor : avgQ >= 55.0 ? neutralColor : bearColor
    table.cell(panel, 0, 6, "Avg Quality", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, str.tostring(avgQ, "#.#"), text_color = qCol, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_right)

    table.merge_cells(panel, 0, 7, 1, 7)
    table.cell(panel, 0, 7, "— TARGET PROOF —", text_color = accentColor, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_center)
    wr = totalConfirmed > 0 ? 100.0 * totalTargetHit / totalConfirmed : na
    proofReady = totalConfirmed >= 6
    proofCol = not proofReady ? f_panel_label() : wr >= 55.0 ? bullColor : wr >= 45.0 ? neutralColor : bearColor
    proofTxt = not proofReady ? "Building (" + str.tostring(totalConfirmed) + ")" : str.tostring(wr, "#.#") + "% (n=" + str.tostring(totalConfirmed) + ")"
    proofBg = proofReady ? color.new(proofCol, 12) : f_panel_bg()
    proofInk = proofReady ? f_text_on(proofCol) : f_panel_label()
    table.cell(panel, 0, 8, "Target Hit Rate", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 8, proofTxt, text_color = proofInk, bgcolor = proofBg, text_size = panelSize, text_halign = text.align_right)

    lastSigTxt = na(lastConfirmBar) ? "-" : str.tostring(bar_index - lastConfirmBar) + " bars ago"
    lastSigCol = na(lastConfirmBar) ? f_panel_label() : (bar_index - lastConfirmBar) < 20 ? accentColor : f_panel_value()
    table.cell(panel, 0, 9, "Last Signal", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 9, lastSigTxt, text_color = lastSigCol, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_right)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
````
