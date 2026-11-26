# ICT Smart Money Footprint [AGPro Series]

- url: https://www.tradingview.com/script/27ZW7UhT-ICT-Smart-Money-Footprint-AGPro-Series/
- type: indicator
- pine_id: PUB;b90d6d951c74411b944d0c92dc44a79d
- version: 6.0

## Description

ICT Smart Money Footprint [AGPro Series]

🔷 OVERVIEW

ICT Smart Money Footprint is a multi-timeframe price action engine that maps institutional liquidity behavior directly onto your chart. It combines higher-timeframe reaction zones (BSL/SSL) derived from swing pivots with candle-by-candle lower-timeframe footprint states — Liquidity Grab, Displacement, and Reclaim — into one cohesive visualization. A live panel tracks session bias, daily event counts, and zone lifecycle, giving price action traders a complete context window for ICT-style analysis across every timeframe.

[image]https://www.tradingview.com/x/V7EoCgL8/[/image]

🧭 UNIQUE EDGE

Most Smart Money Concept indicators plot every swing as a zone, producing cluttered charts that obscure the very structure they aim to reveal. This tool takes a different route. It separates the question "where is liquidity?" (answered at HTF with wide, contextual zones) from "what is price doing right now?" (answered at LTF with footprint labels). The two layers communicate through a single panel and a shared color palette, so the trader always sees both the macro landscape and the tactical footprint without layering multiple scripts. Priority filtering ensures only the highest-conviction event is printed per bar, and confluence windowing prevents label clustering.


⚙️ METHODOLOGY

The script runs two parallel engines.

The HTF Zone Engine pulls pivot highs and lows from a higher timeframe using request.security with lookahead disabled. Each confirmed pivot anchors a reaction zone sized by HTF ATR × 1.5, ensuring natural visibility on any chart view. Buy-Side Liquidity (BSL) zones form above price at pivot highs; Sell-Side Liquidity (SSL) zones form below price at pivot lows. Zones extend right via line.new with extend.right and a linefill between the two edges. When price tags a zone, the zone is marked mitigated: its lines switch to dashed style, width drops, color fades, and right extension freezes at the touch point.

The LTF Footprint Engine evaluates each confirmed candle for three events. Liquidity Grab triggers when price sweeps the prior LTF swing with a buffer and closes back inside range in the opposite direction. Displacement triggers when candle range exceeds ATR × multiplier and the candle breaks the prior bar's extreme. Reclaim triggers when price recovers a recently lost swing level within a 20-bar window. A priority filter (DISP > LG > REC) prints only the strongest event per bar and direction. A session bias score accumulates these events and resets daily, tinting the chart background and updating the panel in real time.


📡 SIGNALS & ALERTS

Six alert conditions are built in:
• Liquidity Grab (bull or bear)
• Displacement (bull or bear)
• HTF Mitigation (any zone tagged)
• Reclaim (bull or bear)
• Bias Turned Bullish
• Bias Turned Bearish

All alerts include ticker and interval placeholders for multi-chart monitoring.


🎛️ KEY INPUTS

HTF Source — Auto scales the higher timeframe to your chart (15m→4H, 1H→D, 4H→W, 1D→M), or pick a manual HTF.
HTF Pivot Length — controls strength threshold of liquidity zones.
HTF Zone Height (ATR x) — default 1.5; tune for wider or tighter zones.
LTF Pivot Length — swing sensitivity for LG and REC detection.
Displacement ATR Multiplier — default 2.0; raise for only the most explosive candles.
Sweep Buffer — extra cushion above or below swing levels for LG qualification.
Confluence Window — suppresses back-to-back same-direction labels.
Session Bias Band — subtle background tint reflecting daily event accumulation.
Panel Location, Theme, Font Size — full control over on-chart presentation.


🧩 HOW TO USE

Start with your normal trading timeframe. The HTF Source set to Auto will anchor the zones to a relevant higher timeframe. Watch how price interacts with the BSL and SSL zones: unmitigated HTF zones act as liquidity targets and reaction areas, while mitigated (dashed) zones mark where liquidity has already been absorbed.

Use the LTF footprint labels to read the tactical story inside those zones. A Liquidity Grab near an SSL zone hints at institutional accumulation. A Displacement candle after an LG often precedes a structural shift. A Reclaim of a recently lost level signals inducement and potential continuation. The panel's Session Bias gives you a running directional read; when it flips, an alert can fire.

Traders typically combine this tool with their own execution framework: HTF zones for bias and target selection, LTF footprints for timing and confirmation. The indicator provides the map; risk management, entry rules, and position sizing remain the trader's responsibility.


⚠️ LIMITATIONS & TRANSPARENCY

This indicator is an analytical mapping tool, not a trading strategy. It identifies structural patterns and plots them for visual analysis.

HTF zones rely on request.security with lookahead disabled, which means new zones appear only after the HTF pivot is fully confirmed — this introduces a natural lag consistent with non-repainting practice but means some reactions may occur before the zone is drawn.

LTF footprint labels are confirmed on bar close. Intrabar signals during live bars may flicker until the bar closes.

Different market conditions produce different zone densities. Ranging markets generate more mitigated zones; trending markets leave more unmitigated zones above or below price. Use the Max Active Zones input to cap chart clutter.

Past structural patterns do not guarantee future outcomes. Liquidity sweeps can mark reversals or simply precede continuation moves. Always validate signals with your own analysis and broader market context.


📌 RISK DISCLOSURE

This script is provided for educational and analytical purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any asset. Trading involves substantial risk of loss. Past performance does not guarantee future results. Users are solely responsible for their trading decisions, risk management, and position sizing. The author assumes no liability for any outcome arising from the use of this indicator.

## Source Code

````pine
// ─────────────────────────────────────────────────
// ICT Smart Money Footprint [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 5.0
//
// Multi-timeframe ICT and Smart Money Concepts footprint engine built to map
// liquidity sweeps, displacement expansion, reclaim behavior, and higher-
// timeframe liquidity interaction in one premium overlay. This update shifts
// the script toward sequence-based price action tracking, so traders can read
// how institutional footprints develop instead of only seeing isolated events.
// Version 5.0 adds owned HTF zone badges, hero-range visual prioritization,
// collision-safe event hierarchy, and a persistent panel lifecycle.
// ─────────────────────────────────────────────────

//@version=6
indicator("ICT Smart Money Footprint [AGPro Series]",
     shorttitle = "AG Pro SMF",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 100)

// ═════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════

// ── General ──────────────────────────────────────
grpGen = "General"
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 50, group = grpGen, tooltip = "ATR period used for sweep buffers, displacement filters, label offsets, and footprint range sizing.")
lblLookback = input.int(220, "Label Lookback (bars)", minval = 50, maxval = 1500, group = grpGen, tooltip = "Labels older than this many bars are removed to keep the chart responsive and visually clean.")
displayMode = input.string("Clean", "Display Mode", options = ["Full", "Clean", "Publish"], group = grpGen, tooltip = "Full keeps the richest event detail. Clean reduces minor noise. Publish prioritizes the clearest premium presentation for screenshots and public releases.")
workflowProfile = input.string("Auto", "Workflow Profile", options = ["Auto", "Scalp", "Intraday", "Swing", "Publish"], group = grpGen, tooltip = "Applies a workflow bias to sequence selectivity and presentation density without changing the script's core identity.")

// ── HTF Reaction Zones ───────────────────────────
grpHTF = "HTF Reaction Zones"
showHTF = input.bool(true, "Show HTF Liquidity Zones", group = grpHTF, tooltip = "Displays higher-timeframe buy-side and sell-side liquidity zones built from confirmed pivots.")
htfMode = input.string("Auto", "HTF Source", options = ["Auto", "Manual"], group = grpHTF, tooltip = "Auto scales the higher timeframe to the current chart. Manual lets you select a specific higher timeframe.")
htfManual = input.timeframe("240", "Manual HTF", group = grpHTF, tooltip = "Used only when HTF Source is set to Manual.")
htfPivotLen = input.int(3, "HTF Pivot Length", minval = 2, maxval = 10, group = grpHTF, tooltip = "Lower values create more liquidity zones. Higher values create fewer, stronger zones.")
htfZoneATRm = input.float(1.4, "HTF Zone Height (ATR x)", minval = 0.5, maxval = 4.0, step = 0.1, group = grpHTF, tooltip = "Controls zone thickness as a multiple of higher-timeframe ATR.")
htfMaxZones = input.int(8, "Max Active HTF Zones", minval = 3, maxval = 15, group = grpHTF, tooltip = "Caps the number of active HTF zones kept on the chart.")
htfOpacT = input.int(82, "HTF Zone Fill Transparency", minval = 55, maxval = 95, group = grpHTF, tooltip = "Higher values produce subtler fills. Keep high for a premium chart look.")
htfLineWActive = input.int(2, "Active Zone Line Width", minval = 1, maxval = 4, group = grpHTF, tooltip = "Border width for active higher-timeframe liquidity zones.")
htfLineWMit = input.int(1, "Mitigated Zone Line Width", minval = 1, maxval = 4, group = grpHTF, tooltip = "Border width after a higher-timeframe zone is mitigated.")
htfZoneLbl = input.bool(true, "Show Zone Type Labels", group = grpHTF, tooltip = "Adds compact BSL and SSL tags to each higher-timeframe zone.")
compressFarHTF = input.bool(true, "Compress Distant HTF Zones", group = grpHTF, tooltip = "Visually suppresses distant higher-timeframe zones on any timeframe so the chart stays focused on the most relevant context near price.")
farHTFAtrMult = input.float(7.0, "Distant Zone Filter (ATR x)", minval = 2.0, maxval = 20.0, step = 0.5, group = grpHTF, tooltip = "If a higher-timeframe zone sits farther than this ATR multiple from price it is faded; well beyond it the zone is hidden for a cleaner chart.")
hideFarHTF = input.bool(true, "Hide Very Distant HTF Zones", group = grpHTF, tooltip = "Completely hides very distant higher-timeframe zones for a cleaner presentation and cleaner publication screenshots.")

// ── LTF Footprint Events ─────────────────────────
grpLTF = "LTF Footprint Events"
showEvents = input.bool(true, "Show Event Labels", group = grpLTF, tooltip = "Shows sweep, displacement, and reclaim labels directly on the chart.")
showSeqLabels = input.bool(true, "Show Sequence Labels", group = grpLTF, tooltip = "Shows sequence labels when a same-direction sweep and displacement combine into a stronger footprint.")
enSweep = input.bool(true, "Enable Liquidity Sweep", group = grpLTF, tooltip = "Detects when price sweeps a recent swing level and closes back through it.")
enDisp = input.bool(true, "Enable Displacement", group = grpLTF, tooltip = "Detects strong directional expansion candles using ATR and close-location filters.")
enReclaim = input.bool(true, "Enable Reclaim", group = grpLTF, tooltip = "Detects a return back through a previously lost swing level.")
ltfPivotLen = input.int(5, "LTF Pivot Length", minval = 2, maxval = 15, group = grpLTF, tooltip = "Controls local swing sensitivity used for sweeps and reclaim anchors.")
dispMult = input.float(1.8, "Displacement ATR Multiplier", minval = 0.7, maxval = 5.0, step = 0.1, group = grpLTF, tooltip = "Minimum candle range, expressed as ATR multiples, required for a displacement event.")
dispCloseStrength = input.float(0.65, "Displacement Close Strength", minval = 0.50, maxval = 0.95, step = 0.01, group = grpLTF, tooltip = "Requires the displacement candle to close near its directional extreme for higher quality signals.")
sweepBuf = input.float(0.10, "Sweep Buffer (ATR %)", minval = 0.0, maxval = 0.5, step = 0.01, group = grpLTF, tooltip = "Extra ATR-based buffer added beyond the swing level before a sweep qualifies.")
reclaimBars = input.int(20, "Reclaim Window (bars)", minval = 3, maxval = 50, group = grpLTF, tooltip = "Maximum number of bars allowed between the level loss and the reclaim event.")
confWin = input.int(6, "Same-Direction Label Gap", minval = 0, maxval = 12, group = grpLTF, tooltip = "Prevents repeated same-direction event labels from clustering too tightly.")
lblOffset = input.float(1.35, "Label Offset (ATR x)", minval = 0.5, maxval = 4.0, step = 0.05, group = grpLTF, tooltip = "Moves labels away from candles so they remain visible and do not get buried inside price action.")

// ── Footprint Ranges ─────────────────────────────
grpSeq = "Footprint Ranges"
showRanges = input.bool(true, "Show Footprint Ranges", group = grpSeq, tooltip = "Projects sequence-derived footprint ranges when sweep and displacement align in the same direction.")
showRangeLabel = input.bool(true, "Show Range Focus Label", group = grpSeq, tooltip = "Adds a centered focus label inside the strongest active footprint range, showing its sequence score, direction, and state.")
seqWindow = input.int(8, "Sequence Window (bars)", minval = 1, maxval = 25, group = grpSeq, tooltip = "Maximum bars allowed between a sweep and its same-direction displacement to build a footprint range.")
rangeProjBars = input.int(80, "Range Projection (bars)", minval = 10, maxval = 300, group = grpSeq, tooltip = "How far active footprint ranges project to the right.")
rangeLifeBars = input.int(90, "Range Lifetime (bars)", minval = 20, maxval = 400, group = grpSeq, tooltip = "Maximum number of bars an uninvalidated footprint range remains active.")
rangeMax = input.int(6, "Max Active Footprint Ranges", minval = 2, maxval = 12, group = grpSeq, tooltip = "Caps active footprint ranges to keep the chart efficient and readable.")
rangeFillT = input.int(85, "Range Fill Transparency", minval = 60, maxval = 95, group = grpSeq, tooltip = "Higher values create subtler footprint range shading.")
filterWeakSeq = input.bool(true, "Filter Weak Sequences", group = grpSeq, tooltip = "Allows only stronger sequence chains to create footprint ranges and sequence labels.")
minSeqScore = input.int(60, "Minimum Sequence Score", minval = 0, maxval = 100, group = grpSeq, tooltip = "Minimum quality score required before a sequence becomes a visible footprint range.")
rangeInvalidation = input.string("Close", "Range Invalidation", options = ["Close", "Wick"], group = grpSeq, tooltip = "Close waits for a confirmed close through the range. Wick invalidates as soon as price pierces the opposite side.")

// ── Bias Band ────────────────────────────────────
grpBias = "Session Bias"
showBias = input.bool(true, "Show Daily Bias Band", group = grpBias, tooltip = "Adds a subtle daily bias tint based on accumulated directional footprint events.")
biasOpacT = input.int(97, "Bias Band Transparency", minval = 92, maxval = 99, group = grpBias, tooltip = "Higher values create a lighter and more premium background tint.")

// ── Panel ────────────────────────────────────────
grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel, tooltip = "Displays a compact summary panel with bias, footprint state, and daily event totals.")
panelPos = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = grpPanel,
     tooltip = "Places the panel in one of six chart positions.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel, tooltip = "Switches the panel between dark and light presentation.")
panelFont = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel, tooltip = "Adjusts panel font size.")

// ── Labels ───────────────────────────────────────
grpLbl = "Labels"
lblFont = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpLbl, tooltip = "Adjusts chart label font size.")
maxVisibleLabels = input.int(12, "Max Visible Labels", minval = 4, maxval = 30, group = grpLbl, tooltip = "Caps the number of recent labels kept on the chart for a cleaner premium presentation.")

// ═════════════════════════════════════════════════
// COLOR PALETTE - AGPRO
// ═════════════════════════════════════════════════
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelColDark = color.rgb(148, 163, 184)
panelLabelColLight = color.rgb(71, 85, 105)
panelValueColDark = color.rgb(226, 232, 240)
panelValueColLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
labelTextCol = color.rgb(245, 247, 250)
darkInk = color.rgb(17, 24, 39)

panelBg = panelTheme == "Dark" ? panelBgDark : panelBgLight
panelLabelCol = panelTheme == "Dark" ? panelLabelColDark : panelLabelColLight
panelValueCol = panelTheme == "Dark" ? panelValueColDark : panelValueColLight

// Panel-safe state colors (theme-aware): vivid on dark, darkened on light for readable panel text
psBull = panelTheme == "Dark" ? bullColor : color.rgb(13, 148, 136)
psBear = panelTheme == "Dark" ? bearColor : color.rgb(219, 39, 119)
psNeut = panelTheme == "Dark" ? neutralColor : color.rgb(180, 83, 9)
psAcc = panelTheme == "Dark" ? accentColor : color.rgb(79, 70, 229)
bannerBg = panelTheme == "Dark" ? color.rgb(30, 41, 59) : color.rgb(226, 232, 240)

// ═════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════
f_toSize(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Large" ? size.large :
     size.normal

f_panelPos(string p) =>
    p == "Top Right" ? position.top_right :
     p == "Top Left" ? position.top_left :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     position.bottom_left

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_norm(float v, float lo, float hi) =>
    hi == lo ? 0.0 : f_clamp((v - lo) / (hi - lo), 0.0, 1.0)

// Contrast-safe on-badge text color: dark ink on bright fills, light text on dark fills
f_text_on(color c) =>
    br = (color.r(c) * 299 + color.g(c) * 587 + color.b(c) * 114) / 1000
    br >= 145 ? darkInk : headerText

f_autoHTF() =>
    tfMin = timeframe.in_seconds() / 60
    tfMin <= 1 ? "60" :
     tfMin <= 5 ? "240" :
     tfMin <= 15 ? "240" :
     tfMin <= 60 ? "D" :
     tfMin <= 240 ? "W" :
     tfMin <= 1440 ? "M" :
     "3M"

f_effectiveMinSeqScore() =>
    profileFloor = workflowProfile == "Publish" ? 74 :
     workflowProfile == "Swing" ? 68 :
     workflowProfile == "Intraday" ? 64 :
     workflowProfile == "Scalp" ? 58 :
     minSeqScore
    displayMode == "Publish" ? math.max(math.max(minSeqScore, profileFloor), 70) :
     displayMode == "Clean" ? math.max(math.max(minSeqScore, profileFloor), 64) :
     math.max(minSeqScore, profileFloor)

f_effectiveLabelBudget() =>
    profileBudget = workflowProfile == "Publish" ? math.min(maxVisibleLabels, 6) :
     workflowProfile == "Swing" ? math.min(maxVisibleLabels, 8) :
     workflowProfile == "Intraday" ? math.min(maxVisibleLabels, 10) :
     workflowProfile == "Scalp" ? math.min(maxVisibleLabels + 2, 18) :
     maxVisibleLabels
    displayMode == "Publish" ? math.min(profileBudget, 6) :
     displayMode == "Clean" ? math.min(profileBudget, 10) :
     profileBudget

f_rangeFillAlpha(float score_) =>
    int(math.round(f_clamp(rangeFillT - (score_ - 60.0) * 0.12, 68, 92)))

f_rangeLiveAlpha(float score_, bool confirmed_) =>
    base_ = f_rangeFillAlpha(score_)
    confirmed_ ? int(math.max(60, base_ - 10)) : base_

f_rangeBorderWidth(float score_, bool confirmed_) =>
    confirmed_ ? 2 : score_ >= 78 ? 2 : 1

f_scoreTag(float score_) =>
    na(score_) ? "Idle" :
     score_ >= 90 ? "Elite" :
     score_ >= 78 ? "Strong" :
     score_ >= 66 ? "Building" :
     score_ >= 54 ? "Developing" :
     "Weak"

f_scoreGrade(float score_) =>
    na(score_) ? "-" :
     score_ >= 92 ? "A+" :
     score_ >= 84 ? "A" :
     score_ >= 76 ? "B" :
     score_ >= 66 ? "C" :
     "D"

// ═════════════════════════════════════════════════
// CORE SERIES
// ═════════════════════════════════════════════════
htfTF = htfMode == "Auto" ? f_autoHTF() : htfManual
atrLtf = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
rangeNow = math.max(high - low, syminfo.mintick)
buf = sweepBuf * atrLtf
isFullMode = displayMode == "Full"
isCleanMode = displayMode == "Clean"
isPublishMode = displayMode == "Publish"
effectiveMinSeqScore = f_effectiveMinSeqScore()
effectiveLabelBudget = f_effectiveLabelBudget()
weeklyFocus = timeframe.isweekly or timeframe.ismonthly or workflowProfile == "Swing" or workflowProfile == "Publish"

ltfPH = ta.pivothigh(high, ltfPivotLen, ltfPivotLen)
ltfPL = ta.pivotlow(low, ltfPivotLen, ltfPivotLen)

var float lastPHLtf = na
var float lastPLLtf = na

if not na(ltfPH)
    lastPHLtf := ltfPH
if not na(ltfPL)
    lastPLLtf := ltfPL

// ═════════════════════════════════════════════════
// HTF ZONES
// ═════════════════════════════════════════════════
[htfPH, htfPL, htfATR] = request.security(
     syminfo.tickerid, htfTF,
     [ta.pivothigh(high, htfPivotLen, htfPivotLen),
      ta.pivotlow(low, htfPivotLen, htfPivotLen),
      ta.atr(atrLen)],
     lookahead = barmerge.lookahead_off)

htfPHConfirmed = not na(htfPH) and na(htfPH[1]) ? htfPH : na
htfPLConfirmed = not na(htfPL) and na(htfPL[1]) ? htfPL : na

type HTFZone
    line topLn
    line botLn
    linefill fill
    label lb
    float top
    float bot
    bool isBull
    bool mitigated
    int startBar

var array<HTFZone> htfZones = array.new<HTFZone>()

f_htfZoneColor(bool isBull_) =>
    isBull_ ? bullColor : bearColor

f_addHTFZone(float level_, bool isBull_) =>
    zHalf = htfATR * htfZoneATRm * 0.5
    top_ = level_ + zHalf
    bot_ = level_ - zHalf
    zCol = f_htfZoneColor(isBull_)
    topLn_ = line.new(bar_index, top_, bar_index + 1, top_, color = zCol, width = htfLineWActive, extend = extend.right)
    botLn_ = line.new(bar_index, bot_, bar_index + 1, bot_, color = zCol, width = htfLineWActive, extend = extend.right)
    fill_ = linefill.new(topLn_, botLn_, color.new(zCol, htfOpacT))

    label lb_ = na
    if htfZoneLbl
        tag = isBull_ ? "SSL | HTF" : "BSL | HTF"
        lb_ := label.new(bar_index, (top_ + bot_) * 0.5, tag,
             color = color.new(zCol, 8),
             textcolor = f_text_on(zCol),
             style = label.style_label_center,
             size = f_toSize(lblFont),
             textalign = text.align_center)

    array.push(htfZones, HTFZone.new(topLn_, botLn_, fill_, lb_, top_, bot_, isBull_, false, bar_index))

    while array.size(htfZones) > htfMaxZones
        old = array.shift(htfZones)
        line.delete(old.topLn)
        line.delete(old.botLn)
        linefill.delete(old.fill)
        if not na(old.lb)
            label.delete(old.lb)

f_updateHTFZones() =>
    bool newMit_ = false
    int zoneCount_ = array.size(htfZones)
    if zoneCount_ > 0
        for i = zoneCount_ - 1 to 0
            z = array.get(htfZones, i)
            baseCol = f_htfZoneColor(z.isBull)
            zoneMid = (z.top + z.bot) * 0.5
            zoneDistAtr = math.abs(zoneMid - close) / math.max(atrLtf, syminfo.mintick)
            zoneVisible = not compressFarHTF or zoneDistAtr <= farHTFAtrMult
            zoneHidden = hideFarHTF and zoneDistAtr > farHTFAtrMult * 1.2
            zoneEndBar = z.mitigated ? line.get_x2(z.topLn) : bar_index + 1
            zoneBadgeX = int(math.floor((z.startBar + zoneEndBar) * 0.5))
            if not z.mitigated
                touched = low <= z.top and high >= z.bot
                if touched
                    line.set_color(z.topLn, color.new(baseCol, 45))
                    line.set_color(z.botLn, color.new(baseCol, 45))
                    line.set_width(z.topLn, htfLineWMit)
                    line.set_width(z.botLn, htfLineWMit)
                    line.set_style(z.topLn, line.style_dashed)
                    line.set_style(z.botLn, line.style_dashed)
                    line.set_extend(z.topLn, extend.none)
                    line.set_extend(z.botLn, extend.none)
                    line.set_x2(z.topLn, bar_index)
                    line.set_x2(z.botLn, bar_index)
                    linefill.set_color(z.fill, color.new(baseCol, math.min(htfOpacT + 8, 94)))
                    if not na(z.lb)
                        label.set_xy(z.lb, int(math.floor((z.startBar + bar_index) * 0.5)), zoneMid)
                    z.mitigated := true
                    newMit_ := true
                else
                    if not na(z.lb)
                        label.set_xy(z.lb, zoneBadgeX, zoneMid)
                array.set(htfZones, i, z)
            else
                if not na(z.lb)
                    label.set_xy(z.lb, zoneBadgeX, zoneMid)
            hideZoneVisual_ = zoneHidden or not zoneVisible
            liveCol = hideZoneVisual_ ? color.new(baseCol, 100) : z.mitigated ? color.new(baseCol, 45) : color.new(baseCol, 0)
            fillCol = hideZoneVisual_ ? color.new(baseCol, 100) : z.mitigated ? color.new(baseCol, math.min(htfOpacT + 8, 94)) : color.new(baseCol, htfOpacT)
            line.set_color(z.topLn, liveCol)
            line.set_color(z.botLn, liveCol)
            linefill.set_color(z.fill, fillCol)
            if not na(z.lb)
                badgeHidden_ = hideZoneVisual_
                label.set_color(z.lb, badgeHidden_ ? color.new(baseCol, 100) : color.new(baseCol, z.mitigated ? 45 : 8))
                label.set_textcolor(z.lb, badgeHidden_ ? color.new(f_text_on(baseCol), 100) : color.new(f_text_on(baseCol), z.mitigated ? 20 : 0))
    newMit_

f_hasHTFContext(bool isBull_) =>
    bool has_ = false
    int zoneCount_ = array.size(htfZones)
    if zoneCount_ > 0
        for i = 0 to zoneCount_ - 1
            z = array.get(htfZones, i)
            if not z.mitigated and z.isBull == isBull_
                inZone = high >= z.bot and low <= z.top
                if inZone
                    has_ := true
                    break
    has_

if showHTF and not na(htfPHConfirmed) and not na(htfATR)
    f_addHTFZone(htfPHConfirmed, false)
if showHTF and not na(htfPLConfirmed) and not na(htfATR)
    f_addHTFZone(htfPLConfirmed, true)

htfMitHit = showHTF ? f_updateHTFZones() : false

// ═════════════════════════════════════════════════
// FOOTPRINT EVENT DETECTION
// ═════════════════════════════════════════════════
bullClosePos = (close - low) / rangeNow
bearClosePos = (high - close) / rangeNow

bullSweep = enSweep and not na(lastPLLtf) and low < lastPLLtf - buf and close > lastPLLtf and close > open
bearSweep = enSweep and not na(lastPHLtf) and high > lastPHLtf + buf and close < lastPHLtf and close < open

bullDisp = enDisp and close > open and rangeNow > atrLtf * dispMult and close > high[1] and bullClosePos >= dispCloseStrength
bearDisp = enDisp and close < open and rangeNow > atrLtf * dispMult and close < low[1] and bearClosePos >= dispCloseStrength

var float lostLevelBull = na
var float lostLevelBear = na
var int lostBarBull = na
var int lostBarBear = na

bullLossNow = not na(lastPLLtf) and close[1] >= lastPLLtf and close < lastPLLtf
bearLossNow = not na(lastPHLtf) and close[1] <= lastPHLtf and close > lastPHLtf

if bullLossNow
    lostLevelBull := lastPLLtf
    lostBarBull := bar_index
if bearLossNow
    lostLevelBear := lastPHLtf
    lostBarBear := bar_index

bullReclaim = enReclaim and not na(lostLevelBull) and bar_index > lostBarBull and bar_index - lostBarBull <= reclaimBars and close > lostLevelBull and close[1] <= lostLevelBull
bearReclaim = enReclaim and not na(lostLevelBear) and bar_index > lostBarBear and bar_index - lostBarBear <= reclaimBars and close < lostLevelBear and close[1] >= lostLevelBear

if bullReclaim
    lostLevelBull := na
    lostBarBull := na
if bearReclaim
    lostLevelBear := na
    lostBarBear := na

// ═════════════════════════════════════════════════
// SEQUENCE TRACKER
// ═════════════════════════════════════════════════
var float bullSweepOpen = na
var float bullSweepClose = na
var float bullSweepLow = na
var int bullSweepBar = na

var float bearSweepOpen = na
var float bearSweepClose = na
var float bearSweepHigh = na
var int bearSweepBar = na

if bullSweep
    bullSweepOpen := open
    bullSweepClose := close
    bullSweepLow := low
    bullSweepBar := bar_index

if bearSweep
    bearSweepOpen := open
    bearSweepClose := close
    bearSweepHigh := high
    bearSweepBar := bar_index

type FootRange
    box bx
    label lb
    float top
    float bot
    int startBar
    int dir
    bool tested
    bool invalid
    bool confirmed
    float score

var array<FootRange> footRanges = array.new<FootRange>()

f_addFootRange(float top_, float bot_, int dir_, float score_) =>
    rangeCol = dir_ == 1 ? bullColor : bearColor
    bx_ = box.new(left = bar_index, top = top_, right = bar_index + rangeProjBars, bottom = bot_,
         border_color = rangeCol,
         border_width = f_rangeBorderWidth(score_, false),
         bgcolor = color.new(rangeCol, f_rangeLiveAlpha(score_, false)))
    label lb_ = na
    if showRangeLabel
        dirTxt_ = dir_ == 1 ? "Bull" : "Bear"
        lb_ := label.new(bar_index + int(rangeProjBars * 0.5), (top_ + bot_) * 0.5,
             "FP " + str.tostring(int(math.round(score_))) + " " + dirTxt_ + " Active",
             color = color.new(rangeCol, 8),
             textcolor = f_text_on(rangeCol),
             style = label.style_label_center,
             size = f_toSize(lblFont),
             textalign = text.align_center)
    array.push(footRanges, FootRange.new(bx_, lb_, top_, bot_, bar_index, dir_, false, false, false, score_))

    while array.size(footRanges) > rangeMax
        old = array.shift(footRanges)
        box.delete(old.bx)
        if not na(old.lb)
            label.delete(old.lb)

f_confirmLatestRange(int dir_) =>
    int rangeCount_ = array.size(footRanges)
    if rangeCount_ > 0
        for i = rangeCount_ - 1 to 0
            fr = array.get(footRanges, i)
            if not fr.invalid and fr.dir == dir_
                baseCol = fr.dir == 1 ? bullColor : bearColor
                fr.confirmed := true
                box.set_bgcolor(fr.bx, color.new(baseCol, f_rangeLiveAlpha(fr.score, true)))
                box.set_border_color(fr.bx, accentColor)
                box.set_border_width(fr.bx, f_rangeBorderWidth(fr.score, true))
                if not na(fr.lb)
                    dirTxt_ = fr.dir == 1 ? "Bull" : "Bear"
                    label.set_text(fr.lb, "FP " + str.tostring(int(math.round(math.min(100, fr.score + 12)))) + " " + dirTxt_ + " Confirmed")
                    label.set_color(fr.lb, color.new(accentColor, 8))
                    label.set_textcolor(fr.lb, f_text_on(accentColor))
                array.set(footRanges, i, fr)
                break

f_updateFootRanges() =>
    int bullCount_ = 0
    int bearCount_ = 0
    bool retestNow_ = false
    bool invalidNow_ = false
    int rangeCount_ = array.size(footRanges)
    int heroBullIdx_ = -1
    int heroBearIdx_ = -1
    float heroBullScore_ = -1.0
    float heroBearScore_ = -1.0
    if rangeCount_ > 0
        for i = rangeCount_ - 1 to 0
            fr = array.get(footRanges, i)
            baseCol = fr.dir == 1 ? bullColor : bearColor
            liveBorderCol = fr.confirmed ? accentColor : baseCol
            invalidBull = rangeInvalidation == "Close" ? fr.dir == 1 and close < fr.bot : fr.dir == 1 and low < fr.bot
            invalidBear = rangeInvalidation == "Close" ? fr.dir == -1 and close > fr.top : fr.dir == -1 and high > fr.top
            if not fr.invalid
                expired = bar_index - fr.startBar > rangeLifeBars
                touched = bar_index > fr.startBar and high >= fr.bot and low <= fr.top

                if expired or invalidBull or invalidBear
                    fr.invalid := true
                    invalidNow_ := true
                    box.set_right(fr.bx, bar_index)
                    box.set_bgcolor(fr.bx, color.new(baseCol, 100))
                    box.set_border_color(fr.bx, color.new(liveBorderCol, 100))
                    if not na(fr.lb)
                        dirTxtI_ = fr.dir == 1 ? "Bull" : "Bear"
                        label.set_text(fr.lb, "FP " + str.tostring(int(math.round(fr.score))) + " " + dirTxtI_)
                        label.set_color(fr.lb, color.new(baseCol, 100))
                        label.set_textcolor(fr.lb, color.new(f_text_on(baseCol), 100))
                        label.set_xy(fr.lb, int((fr.startBar + bar_index) * 0.5), (fr.top + fr.bot) * 0.5)
                else
                    box.set_right(fr.bx, bar_index + rangeProjBars)
                    if not na(fr.lb)
                        label.set_xy(fr.lb, int((fr.startBar + bar_index + rangeProjBars) * 0.5), (fr.top + fr.bot) * 0.5)
                    if touched and not fr.tested
                        fr.tested := true
                        retestNow_ := true
                        retestAlpha = fr.confirmed ? int(math.max(66, f_rangeLiveAlpha(fr.score, true))) : int(math.min(f_rangeLiveAlpha(fr.score, false) + 6, 94))
                        box.set_bgcolor(fr.bx, color.new(baseCol, retestAlpha))
                        box.set_border_color(fr.bx, color.new(liveBorderCol, 20))

                    heroScore_ = fr.score + (fr.confirmed ? 8 : 0) - (fr.tested ? 2 : 0)
                    if fr.dir == 1 and heroScore_ > heroBullScore_
                        heroBullScore_ := heroScore_
                        heroBullIdx_ := i
                    if fr.dir == -1 and heroScore_ > heroBearScore_
                        heroBearScore_ := heroScore_
                        heroBearIdx_ := i

                    if fr.dir == 1
                        bullCount_ += 1
                    else
                        bearCount_ += 1

                array.set(footRanges, i, fr)
        for i = rangeCount_ - 1 to 0
            fr = array.get(footRanges, i)
            if not fr.invalid
                baseCol = fr.dir == 1 ? bullColor : bearColor
                liveBorderCol = fr.confirmed ? accentColor : baseCol
                isHero_ = fr.dir == 1 ? i == heroBullIdx_ : i == heroBearIdx_
                fillAlpha_ = isHero_ ? f_rangeLiveAlpha(fr.score, fr.confirmed) :
                     isFullMode ? int(math.min(94, f_rangeLiveAlpha(fr.score, fr.confirmed) + 4)) : 100
                borderCol_ = isHero_ ? (fr.confirmed ? accentColor : color.new(liveBorderCol, 0)) :
                     isFullMode ? color.new(liveBorderCol, 16) : color.new(liveBorderCol, 100)
                borderWidth_ = isHero_ ? (weeklyFocus ? 3 : math.max(2, f_rangeBorderWidth(fr.score, fr.confirmed))) :
                     isPublishMode ? 1 :
                     1
                box.set_bgcolor(fr.bx, color.new(baseCol, fillAlpha_))
                box.set_border_color(fr.bx, borderCol_)
                box.set_border_width(fr.bx, borderWidth_)
                if not na(fr.lb)
                    badgeBg_ = fr.confirmed ? accentColor : baseCol
                    bAlpha_ = isHero_ ? 8 : isFullMode ? 30 : 100
                    label.set_color(fr.lb, color.new(badgeBg_, bAlpha_))
                    label.set_textcolor(fr.lb, color.new(f_text_on(badgeBg_), isHero_ ? 0 : isFullMode ? 20 : 100))
    [bullCount_, bearCount_, retestNow_, invalidNow_]

// Stop-aware footprint follow-through capture (set at sequence arm, in range scope)
int pfArmDir = 0
float pfArmTarget = na
float pfArmStop = na

bool bullSeqTriggered = false
bool bearSeqTriggered = false
float bullSeqScore = na
float bearSeqScore = na

if showRanges and bullDisp and not na(bullSweepBar) and bar_index - bullSweepBar <= seqWindow
    bullCtx = f_hasHTFContext(true) ? 10.0 : 0.0
    bullDispStrength = rangeNow / atrLtf
    bullSeqScore := math.round(f_clamp(45 + 25 * f_norm(bullDispStrength, dispMult, dispMult * 2.4) + 20 * bullClosePos + bullCtx, 0, 100))
    bullQualified = not filterWeakSeq or bullSeqScore >= effectiveMinSeqScore
    bullTop = math.max(math.min(bullSweepOpen, bullSweepClose), math.min(open, close))
    bullBot = math.min(bullSweepLow, low)
    if bullTop > bullBot and bullQualified
        f_addFootRange(bullTop, bullBot, 1, bullSeqScore)
        bullSeqTriggered := true
        pfArmDir := 1
        pfArmStop := bullBot
        pfArmTarget := bullTop + (bullTop - bullBot)
        bullSweepBar := na

if showRanges and bearDisp and not na(bearSweepBar) and bar_index - bearSweepBar <= seqWindow
    bearCtx = f_hasHTFContext(false) ? 10.0 : 0.0
    bearDispStrength = rangeNow / atrLtf
    bearSeqScore := math.round(f_clamp(45 + 25 * f_norm(bearDispStrength, dispMult, dispMult * 2.4) + 20 * bearClosePos + bearCtx, 0, 100))
    bearQualified = not filterWeakSeq or bearSeqScore >= effectiveMinSeqScore
    bearTop = math.max(bearSweepHigh, high)
    bearBot = math.min(math.max(bearSweepOpen, bearSweepClose), math.max(open, close))
    if bearTop > bearBot and bearQualified
        f_addFootRange(bearTop, bearBot, -1, bearSeqScore)
        bearSeqTriggered := true
        pfArmDir := -1
        pfArmStop := bearTop
        pfArmTarget := bearBot - (bearTop - bearBot)
        bearSweepBar := na

if not na(bullSweepBar) and bar_index - bullSweepBar > seqWindow
    bullSweepBar := na
if not na(bearSweepBar) and bar_index - bearSweepBar > seqWindow
    bearSweepBar := na

int activeBullRanges = 0
int activeBearRanges = 0
bool rangeRetestNow = false
bool rangeInvalidatedNow = false
if showRanges
    [activeBullRanges, activeBearRanges, rangeRetestNow, rangeInvalidatedNow] = f_updateFootRanges()

var int activeSeqDir = 0
var string activeSeqStage = "Idle"
var float activeSeqScore = na
var int activeSeqBar = na

if bullSeqTriggered
    activeSeqDir := 1
    activeSeqStage := "Expansion"
    activeSeqScore := bullSeqScore
    activeSeqBar := bar_index

if bearSeqTriggered
    activeSeqDir := -1
    activeSeqStage := "Expansion"
    activeSeqScore := bearSeqScore
    activeSeqBar := bar_index

bullSeqConfirmNow = activeSeqDir == 1 and activeSeqStage == "Expansion" and not na(activeSeqBar) and bullReclaim and bar_index - activeSeqBar <= reclaimBars
bearSeqConfirmNow = activeSeqDir == -1 and activeSeqStage == "Expansion" and not na(activeSeqBar) and bearReclaim and bar_index - activeSeqBar <= reclaimBars

if bullSeqConfirmNow
    activeSeqStage := "Confirmed"
    activeSeqScore := math.min(100, nz(activeSeqScore) + 12)
    f_confirmLatestRange(1)

if bearSeqConfirmNow
    activeSeqStage := "Confirmed"
    activeSeqScore := math.min(100, nz(activeSeqScore) + 12)
    f_confirmLatestRange(-1)

if activeSeqDir != 0 and not na(activeSeqBar) and bar_index - activeSeqBar > rangeLifeBars
    activeSeqDir := 0
    activeSeqStage := "Idle"
    activeSeqScore := na
    activeSeqBar := na

// ═════════════════════════════════════════════════
// FOOTPRINT FOLLOW-THROUGH PROOF (stop-aware)
// ═════════════════════════════════════════════════
// When a footprint sequence is armed, did price travel one range height beyond
// the range (target) before closing through the range invalidation edge (stop)?
// Win = target first, Loss = invalidation first, neither in lifetime = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfStop   = na
var int   pfBar    = na

if barstate.isconfirmed
    if pfOpen
        bool pfHitStop   = pfDir == 1 ? close < pfStop : close > pfStop
        bool pfHitTarget = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        if pfHitStop
            pfTotal += 1
            pfOpen  := false
        else if pfHitTarget
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > rangeLifeBars
            pfOpen := false
    if pfArmDir != 0 and not pfOpen and not na(pfArmTarget) and not na(pfArmStop)
        pfOpen   := true
        pfDir    := pfArmDir
        pfTarget := pfArmTarget
        pfStop   := pfArmStop
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
followRateTxt = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
followRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? psBull : pfRate >= 45.0 ? psNeut : psBear) : panelValueCol

stateTxt = activeSeqDir == 1 ? (activeSeqStage == "Confirmed" ? "Bull Confirmed" : "Bull Expansion") :
           activeSeqDir == -1 ? (activeSeqStage == "Confirmed" ? "Bear Confirmed" : "Bear Expansion") :
           "Idle"
stateCol = activeSeqDir == 1 ? psBull : activeSeqDir == -1 ? psBear : psNeut
htfAlignedNow = activeSeqDir == 1 ? f_hasHTFContext(true) : activeSeqDir == -1 ? f_hasHTFContext(false) : false

// ═════════════════════════════════════════════════
// DAILY COUNTERS + BIAS
// ═════════════════════════════════════════════════
isNewDay = timeframe.change("D")

var int cntSweep = 0
var int cntDisp = 0
var int cntReclaim = 0
var int cntMit = 0
var int cntSeq = 0

if isNewDay
    cntSweep := 0
    cntDisp := 0
    cntReclaim := 0
    cntMit := 0
    cntSeq := 0

if bullSweep or bearSweep
    cntSweep += 1
if bullDisp or bearDisp
    cntDisp += 1
if bullReclaim or bearReclaim
    cntReclaim += 1
if htfMitHit
    cntMit += 1
if bullSeqTriggered or bearSeqTriggered
    cntSeq += 1

var int biasScore = 0
if isNewDay
    biasScore := 0
else
    biasScore := nz(biasScore[1])

if bullSweep or bullDisp or bullReclaim
    biasScore += 1
if bearSweep or bearDisp or bearReclaim
    biasScore -= 1
if bullSeqTriggered or bullSeqConfirmNow
    biasScore += 2
if bearSeqTriggered or bearSeqConfirmNow
    biasScore -= 2

biasTxt = biasScore >= 3 ? "BULLISH" : biasScore <= -3 ? "BEARISH" : "NEUTRAL"
biasCol = biasScore >= 3 ? psBull : biasScore <= -3 ? psBear : psNeut

biasBandCol = biasScore >= 3 ? color.new(bullColor, biasOpacT) :
              biasScore <= -3 ? color.new(bearColor, biasOpacT) :
              na
bgcolor(showBias ? biasBandCol : na, title = "Daily Bias Band")

// ═════════════════════════════════════════════════
// LAST FOOTPRINT STATE
// ═════════════════════════════════════════════════
var string lastFP = "-"
var color lastFPCol = panelValueCol
panelEventTxt = lastFP
panelEventCol = lastFPCol

if bullSeqConfirmNow
    lastFP := "CONF (Bull)"
    lastFPCol := psBull
else if bearSeqConfirmNow
    lastFP := "CONF (Bear)"
    lastFPCol := psBear
else if bullSeqTriggered
    lastFP := "SEQ+ (Bull)"
    lastFPCol := psAcc
else if bearSeqTriggered
    lastFP := "SEQ+ (Bear)"
    lastFPCol := psAcc
else if bullDisp
    lastFP := "DISP (Bull)"
    lastFPCol := psAcc
else if bearDisp
    lastFP := "DISP (Bear)"
    lastFPCol := psAcc
else if bullSweep
    lastFP := "SWP (Bull)"
    lastFPCol := psNeut
else if bearSweep
    lastFP := "SWP (Bear)"
    lastFPCol := psNeut
else if bullReclaim
    lastFP := "RCL (Bull)"
    lastFPCol := psBull
else if bearReclaim
    lastFP := "RCL (Bear)"
    lastFPCol := psBear

panelEventTxt := activeSeqDir == 1 ? (activeSeqStage == "Confirmed" ? "Confirmed Bull" : "Active Bull") :
                 activeSeqDir == -1 ? (activeSeqStage == "Confirmed" ? "Confirmed Bear" : "Active Bear") :
                 lastFP
panelEventCol := activeSeqDir != 0 ? stateCol : lastFPCol

// ═════════════════════════════════════════════════
// LABELS
// ═════════════════════════════════════════════════
var int lastBullEventBar = -1000
var int lastBearEventBar = -1000
var int lastBullSeqBar = -1000
var int lastBearSeqBar = -1000
var array<label> plotLabels = array.new<label>()

f_canEmit(bool isBull_) =>
    confWin <= 0 ? true :
     isBull_ ? bar_index - lastBullEventBar > confWin :
     bar_index - lastBearEventBar > confWin

f_canEmitSeq(bool isBull_) =>
    confWin <= 0 ? true :
     isBull_ ? bar_index - lastBullSeqBar > confWin :
     bar_index - lastBearSeqBar > confWin

string bullTag = ""
color bullTagCol = na
bool bullFire = false
if bullDisp and not bullSeqTriggered and not isPublishMode and not weeklyFocus
    bullTag := "DISP"
    bullTagCol := accentColor
    bullFire := true
else if bullSweep and isFullMode
    bullTag := "SWP"
    bullTagCol := neutralColor
    bullFire := true
else if bullReclaim and not bullSeqConfirmNow and not isPublishMode and not weeklyFocus
    bullTag := "RCL"
    bullTagCol := bullColor
    bullFire := true

string bearTag = ""
color bearTagCol = na
bool bearFire = false
if bearDisp and not bearSeqTriggered and not isPublishMode and not weeklyFocus
    bearTag := "DISP"
    bearTagCol := accentColor
    bearFire := true
else if bearSweep and isFullMode
    bearTag := "SWP"
    bearTagCol := neutralColor
    bearFire := true
else if bearReclaim and not bearSeqConfirmNow and not isPublishMode and not weeklyFocus
    bearTag := "RCL"
    bearTagCol := bearColor
    bearFire := true

if showEvents and bullFire and not bullSeqTriggered and not bullSeqConfirmNow and f_canEmit(true)
    lbBull = label.new(bar_index, low - atrLtf * lblOffset, bullTag,
         color = color.new(bullTagCol, 12),
         textcolor = f_text_on(bullTagCol),
         style = label.style_label_up,
         size = f_toSize(lblFont),
         textalign = text.align_center)
    array.push(plotLabels, lbBull)
    lastBullEventBar := bar_index

if showEvents and bearFire and not bearSeqTriggered and not bearSeqConfirmNow and f_canEmit(false)
    lbBear = label.new(bar_index, high + atrLtf * lblOffset, bearTag,
         color = color.new(bearTagCol, 12),
         textcolor = f_text_on(bearTagCol),
         style = label.style_label_down,
         size = f_toSize(lblFont),
         textalign = text.align_center)
    array.push(plotLabels, lbBear)
    lastBearEventBar := bar_index

if showSeqLabels and bullSeqTriggered and not bullSeqConfirmNow and f_canEmitSeq(true)
    lbBullSeq = label.new(bar_index, low - atrLtf * (lblOffset + 0.85), "SEQ+",
         color = color.new(accentColor, 12),
         textcolor = f_text_on(accentColor),
         style = label.style_label_up,
         size = f_toSize(lblFont),
         textalign = text.align_center)
    array.push(plotLabels, lbBullSeq)
    lastBullSeqBar := bar_index

if showSeqLabels and bearSeqTriggered and not bearSeqConfirmNow and f_canEmitSeq(false)
    lbBearSeq = label.new(bar_index, high + atrLtf * (lblOffset + 0.85), "SEQ+",
         color = color.new(accentColor, 12),
         textcolor = f_text_on(accentColor),
         style = label.style_label_down,
         size = f_toSize(lblFont),
         textalign = text.align_center)
    array.push(plotLabels, lbBearSeq)
    lastBearSeqBar := bar_index

if showSeqLabels and bullSeqConfirmNow
    lbBullConf = label.new(bar_index, low - atrLtf * (lblOffset + 1.5), "CONF",
         color = color.new(bullColor, 0),
         textcolor = f_text_on(bullColor),
         style = label.style_label_up,
         size = f_toSize(lblFont),
         textalign = text.align_center)
    array.push(plotLabels, lbBullConf)

if showSeqLabels and bearSeqConfirmNow
    lbBearConf = label.new(bar_index, high + atrLtf * (lblOffset + 1.5), "CONF",
         color = color.new(bearColor, 0),
         textcolor = f_text_on(bearColor),
         style = label.style_label_down,
         size = f_toSize(lblFont),
         textalign = text.align_center)
    array.push(plotLabels, lbBearConf)

while array.size(plotLabels) > 0
    oldestLbl = array.get(plotLabels, 0)
    if bar_index - label.get_x(oldestLbl) > lblLookback
        label.delete(oldestLbl)
        array.shift(plotLabels)
    else
        break

while array.size(plotLabels) > effectiveLabelBudget
    oldestLbl = array.shift(plotLabels)
    label.delete(oldestLbl)

// ═════════════════════════════════════════════════
// PANEL
// ═════════════════════════════════════════════════
var table pnl = table.new(f_panelPos(panelPos), 2, 16,
     border_color = panelBorder,
     border_width = 1,
     frame_color = panelBorder,
     frame_width = 1)

if barstate.isfirst
    table.merge_cells(pnl, 0, 0, 1, 0)
    table.merge_cells(pnl, 0, 1, 1, 1)
    table.merge_cells(pnl, 0, 10, 1, 10)

scoreTxt = na(activeSeqScore) ? "-" : str.tostring(math.round(activeSeqScore)) + "/100"
scoreTag = f_scoreTag(activeSeqScore)
scoreGrade = f_scoreGrade(activeSeqScore)
activeRangeTxt = str.tostring(activeBullRanges) + " / " + str.tostring(activeBearRanges)
rangeSummaryTxt = activeBullRanges == 0 and activeBearRanges == 0 and cntSeq == 0 ? "Idle" : activeRangeTxt + " | " + str.tostring(cntSeq) + " seq"
displayTxt = isPublishMode ? "Publish" : isCleanMode ? "Clean" : "Full"
bannerTxt = activeSeqDir == 0 ? stateTxt + " | " + (htfAlignedNow ? "HTF Aligned" : "Standalone") : stateTxt + " | " + scoreGrade + " " + scoreTag + " | " + (htfAlignedNow ? "HTF Aligned" : "Standalone")
workflowTxt = workflowProfile == "Auto" ? "Adaptive" : workflowProfile

if showPanel and barstate.islast
    table.cell(pnl, 0, 0, "AG Pro Smart Money Footprint", bgcolor = headerBg, text_color = headerText, text_size = f_toSize(panelFont), text_halign = text.align_center)

    table.cell(pnl, 0, 1, bannerTxt, bgcolor = bannerBg, text_color = stateCol, text_size = f_toSize(panelFont), text_halign = text.align_center)

    table.cell(pnl, 0, 2, "Display", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 2, displayTxt, bgcolor = panelBg, text_color = panelValueCol, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 3, "Workflow", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 3, workflowTxt, bgcolor = panelBg, text_color = panelValueCol, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 4, "HTF", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 4, htfTF, bgcolor = panelBg, text_color = psAcc, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 5, "Session Bias", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 5, biasTxt, bgcolor = panelBg, text_color = biasCol, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 6, "Footprint State", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 6, stateTxt, bgcolor = panelBg, text_color = stateCol, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 7, "Sequence Score", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 7, scoreTxt + " " + scoreGrade, bgcolor = panelBg, text_color = activeSeqDir == 0 ? panelValueCol : psAcc, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 8, "Follow Rate", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 8, followRateTxt, bgcolor = panelBg, text_color = followRateCol, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 9, "Active Event", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 9, panelEventTxt, bgcolor = panelBg, text_color = panelEventCol, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 10, "- Today -", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont), text_halign = text.align_center)

    table.cell(pnl, 0, 11, "Sweeps", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 11, str.tostring(cntSweep), bgcolor = panelBg, text_color = psNeut, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 12, "Displacements", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 12, str.tostring(cntDisp), bgcolor = panelBg, text_color = psAcc, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 13, "Reclaims", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 13, str.tostring(cntReclaim), bgcolor = panelBg, text_color = psBull, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 14, "HTF Mitigations", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 14, str.tostring(cntMit), bgcolor = panelBg, text_color = panelValueCol, text_size = f_toSize(panelFont))

    table.cell(pnl, 0, 15, "Ranges / Sequences", bgcolor = panelBg, text_color = panelLabelCol, text_size = f_toSize(panelFont))
    table.cell(pnl, 1, 15, rangeSummaryTxt, bgcolor = panelBg, text_color = panelValueCol, text_size = f_toSize(panelFont))
else if not showPanel and barstate.islast
    table.clear(pnl, 0, 0, 1, 15)

// ═════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════
alertcondition(bullSweep or bearSweep, title = "Liquidity Sweep", message = "ICT SMF: Liquidity Sweep detected on {{ticker}} {{interval}}")
alertcondition(bullDisp or bearDisp, title = "Displacement", message = "ICT SMF: Displacement detected on {{ticker}} {{interval}}")
alertcondition(bullReclaim or bearReclaim, title = "Reclaim", message = "ICT SMF: Reclaim detected on {{ticker}} {{interval}}")
alertcondition(htfMitHit, title = "HTF Mitigation", message = "ICT SMF: HTF zone mitigation on {{ticker}} {{interval}}")
alertcondition(bullSeqTriggered or bearSeqTriggered, title = "Footprint Sequence", message = "ICT SMF: Footprint sequence armed on {{ticker}} {{interval}}")
alertcondition(rangeRetestNow, title = "Footprint Range Retest", message = "ICT SMF: Active footprint range retested on {{ticker}} {{interval}}")
alertcondition(bullSeqConfirmNow or bearSeqConfirmNow, title = "Footprint Confirmation", message = "ICT SMF: Footprint sequence confirmed on {{ticker}} {{interval}}")
alertcondition(rangeInvalidatedNow, title = "Footprint Range Invalidated", message = "ICT SMF: Footprint range invalidated on {{ticker}} {{interval}}")
alertcondition(biasScore >= 3 and biasScore[1] < 3, title = "Bias Turned Bullish", message = "ICT SMF: Bias turned BULLISH on {{ticker}} {{interval}}")
alertcondition(biasScore <= -3 and biasScore[1] > -3, title = "Bias Turned Bearish", message = "ICT SMF: Bias turned BEARISH on {{ticker}} {{interval}}")
````
