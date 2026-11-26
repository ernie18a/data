# Liquidity Void Navigator [AGPro Series]

- url: https://www.tradingview.com/script/239d5bYe-Liquidity-Void-Navigator-AGPro-Series/
- type: indicator
- pine_id: PUB;5677a227458f4128ad4a31044376b641
- version: 4.0

## Description

Liquidity Void Navigator [AGPro Series]

🔹 OVERVIEW

Liquidity Void Navigator identifies impulsive price displacements that were produced with disproportionately low volume participation — the institutional footprint of a true liquidity void. Unlike geometric gap concepts that rely purely on wick-to-wick imbalance, this engine measures the efficiency of each impulsive bar: how much price moved relative to how much volume was transacted. When price travels faster than the order book justifies, a magnet zone is born. These zones frequently act as high-probability retest and mean-reversion targets for SMC and ICT traders.


🔹 UNIQUE EDGE

Most gap-based tools on TradingView detect Fair Value Gaps using a 3-bar geometric pattern. This indicator uses a fundamentally different signature:

- Volume Efficiency Ratio (core innovation): efficiency = (volume / avgVol) / (range / ATR). Values below the threshold reveal bars where price displacement outpaced volume effort — the statistical definition of a liquidity void.
- Body-based zones, not wick-to-wick: the void box spans the impulsive candle body, excluding wicks that represent liquidity sweeps.
- Dynamic lifecycle management: zones are tracked from birth through mid-line mitigation, with configurable trigger modes (close cross, wick touch, or full fill).
- Strongest-void emphasis: the lowest-efficiency active void automatically receives a bold neutral-colored border, giving traders an at-a-glance view of the most reliable magnet on the chart.


🔹 METHODOLOGY

Each completed bar is evaluated against four quality filters:

1. Range Expansion — bar range must exceed ATR × configurable multiplier (default 1.3).
2. Volume Efficiency — the efficiency ratio must fall below the configurable cap (default 0.85).
3. Minimum Height — void must be at least a fraction of ATR to filter micro-noise (default 0.5×).
4. Body Dominance — the candle body must represent at least 50% of the total range, confirming directional conviction rather than indecision.

Qualifying bars create a directional void zone spanning the body. An optional next-bar gap confirmation adds stricter FVG-style filtering. Active zones are continuously evaluated against the selected mitigation mode and updated in real time. Oldest active voids are pruned when the per-side cap is exceeded, keeping the chart focused on recent, actionable structure.


🔹 SIGNALS & ALERTS

Four alert conditions are available:

- New Bullish Liquidity Void — an upward impulsive void is detected.
- New Bearish Liquidity Void — a downward impulsive void is detected.
- Bull Void Mitigated — closing price crosses the mid-line of an active bullish void from above.
- Bear Void Mitigated — closing price crosses the mid-line of an active bearish void from below.

Each alert fires only on bar close to eliminate repainting concerns. Alert messages include the ticker and timeframe for multi-chart workflows.


🔹 KEY INPUTS

Void Detection
- Volume Baseline Lookback — window for average volume and range calculations.
- Min Range Expansion (×ATR) — minimum impulsive bar size.
- Max Volume Efficiency Ratio — core void qualification threshold.
- Min Void Height (×ATR) — filters micro-voids.
- Require Gap with Next Bar — optional strict confirmation.
- Mitigation Trigger — choose between Close Cross (institutional default), Wick Touch (strict), or Full Fill (swing).

Lifecycle
- Max Active Voids per Side — visual cap to prevent chart clutter.
- Zone Right Extension — how far zones project to the right.
- Show Mitigated Voids — optionally display filled zones in gray.

Visuals
- Bullish / Bearish / Mitigated colors, mid-line toggle, projection arrow toggle, label size.

Panel
- Show / position / font size.


🔹 HOW TO USE

Trend-aligned reversion entries: When price returns to an unmitigated void in the direction of the higher-timeframe trend, watch for rejection at the mid-line or far edge as a potential long (bull void) or short (bear void) trigger.

Breakout continuation context: Newly formed voids in the direction of a breakout often indicate institutional participation. Waiting for a retest of the void zone can provide improved risk-to-reward compared to chasing the breakout bar.

Strongest-void bias: The yellow-bordered void on the chart represents the lowest-efficiency (statistically strongest) active zone. Traders can treat it as the highest-probability magnet for price revisits.

Fill Rate context: A persistently high fill rate on a given symbol or timeframe indicates that voids fill rapidly — more suitable for scalping. A lower fill rate suggests that unfilled voids accumulate meaningfully, offering swing-style opportunities.

Multi-timeframe workflow: Identify voids on a higher timeframe (4H or 1D) as strategic bias zones, then use a lower timeframe (15m or 1H) for tactical execution when price approaches those higher-timeframe voids.


🔹 LIMITATIONS & TRANSPARENCY

- This indicator is built for liquid markets with reliable volume data. Thinly traded symbols or instruments without accurate volume feeds (some spot FX, certain indices) will produce unreliable results.
- Not every detected void will be retested or filled. Voids are statistical zones of interest, not guarantees.
- The indicator is a visualization and analytical tool, not a trading strategy. It does not generate buy or sell recommendations.
- Fill rate statistics are computed over the visible history of active and mitigated voids and are approximate; they are intended as a relative gauge of symbol behavior, not as a backtested performance metric.
- Mitigation triggers are bar-close based to avoid repainting. Intrabar signals may appear and disappear until the bar confirms.
- Zones have a fixed right extension from their birth bar; the indicator does not extend zones infinitely.


🔹 RISK DISCLOSURE

Trading financial markets involves substantial risk of loss and is not suitable for all investors. Past performance of any technical indicator, including this one, is not indicative of future results. This tool is provided for educational and analytical purposes only and does not constitute financial advice, investment recommendations, or solicitation to trade. Users are solely responsible for their own trading decisions, risk management, and outcomes. Always conduct independent analysis and consult with a qualified financial advisor before making investment decisions.

## Source Code

````pine
// -----------------------------------------------------
// Liquidity Void Navigator [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Detects volume-based liquidity voids: price corridors formed during
// impulsive moves where volume dropped below a statistical baseline while
// range expanded. The engine combines volume contraction, range expansion,
// and velocity to identify void zones, mitigation behavior, fill rate, and
// nearest/strongest void context with clean on-chart labels and panel output.
// Version 1.3 adds a windowed fill-rate proof, an action row, and
// contrast-safe void badges.
// -----------------------------------------------------

//@version=6
indicator("Liquidity Void Navigator [AGPro Series]",
     shorttitle = "AG Pro LVN",
     overlay    = true,
     max_boxes_count    = 50,
     max_lines_count    = 40,
     max_labels_count   = 60)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
grpDet = "Void Detection"
lookback = input.int(50, "Volume Baseline Lookback", minval = 10, maxval = 200, group = grpDet,
     tooltip = "Bars used to compute average volume and range baseline.")
rangeExpMult = input.float(1.3, "Min Range Expansion (ATR)", minval = 0.8, maxval = 5.0, step = 0.1, group = grpDet,
     tooltip = "Bar range must exceed ATR times this multiplier to qualify as impulsive displacement.")
effRatio = input.float(0.85, "Max Volume Efficiency Ratio", minval = 0.3, maxval = 1.5, step = 0.05, group = grpDet,
     tooltip = "Efficiency equals volume/average volume divided by range/ATR. Lower values mean price moved more than volume justified.")
minVoidATR = input.float(0.5, "Min Void Height (ATR)", minval = 0.2, maxval = 3.0, step = 0.1, group = grpDet,
     tooltip = "Minimum void zone height. Filters micro-voids.")
requireGreen = input.bool(false, "Require Gap with Next Bar", group = grpDet,
     tooltip = "Only qualify voids when the next bar does not retrace into the void immediately.")
mitMode = input.string("Close Cross", "Mitigation Trigger", options = ["Close Cross", "Wick Touch", "Full Fill"], group = grpDet,
     tooltip = "How voids get mitigated. Close Cross uses the mid-line, Wick Touch uses any wick to mid-line, and Full Fill uses the far edge.")

grpLife = "Lifecycle"
maxActive = input.int(4, "Max Active Voids per Side", minval = 2, maxval = 10, group = grpLife,
     tooltip = "Caps visible voids per direction to keep chart clean.")
zoneExtend = input.int(40, "Zone Right Extension (bars)", minval = 10, maxval = 300, group = grpLife,
     tooltip = "How many bars the void zone extends to the right.")
fillWindow = input.int(60, "Fill Review Window (bars)", minval = 5, maxval = 500, group = grpLife,
     tooltip = "Bars after a void forms during which fill behavior is measured for the windowed Fill Rate. A void that does not mitigate within this window is counted as not-filled, which keeps the rate honest instead of approaching 100% over time.")
showMitigated = input.bool(false, "Show Mitigated Voids", group = grpLife,
     tooltip = "Display mitigated voids as gray overlays.")

grpVis = "Visuals"
bullVoidCol = input.color(color.new(color.rgb(129, 140, 248), 80), "Bullish Void", group = grpVis)
bearVoidCol = input.color(color.new(color.rgb(244, 114, 182), 80), "Bearish Void", group = grpVis)
mitigatedCol = input.color(color.new(color.gray, 85), "Mitigated", group = grpVis)
showMidLine = input.bool(true, "Show Mid-Line", group = grpVis,
     tooltip = "Display the 50% mitigation threshold line.")
showProjArrow = input.bool(false, "Show Fill Projection Arrow", group = grpVis,
     tooltip = "Arrow indicating probable fill direction on detection.")
showOutsideLabels = input.bool(false, "Show Outside Labels", group = grpVis,
     tooltip = "Shows the original outside void labels with efficiency values.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = grpVis,
     tooltip = "Adds separate centered badges inside active void zones so each rectangle has clear ownership.")
showBadgeEfficiency = input.bool(true, "Show Badge Efficiency", group = grpVis,
     tooltip = "Adds efficiency score to centered void badges.")
labelSize = input.string("normal", "Label Font Size", options = ["tiny", "small", "normal", "large", "huge"], group = grpVis)

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel)
panelPos = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Right", "Top Center", "Middle Right", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = grpPanel)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPanel)
panelFontSize = input.string("normal", "Panel Font Size", options = ["tiny", "small", "normal", "large", "huge"], group = grpPanel)

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
darkText      = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
f_toSize(s) =>
    s == "tiny" ? size.tiny :
     s == "small" ? size.small :
     s == "large" ? size.large :
     s == "huge" ? size.huge : size.normal

f_toPos(p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Center" ? position.middle_center :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left" ? position.bottom_left :
     p == "Bottom Center" ? position.bottom_center : position.top_right

f_text_on(color bg) =>
    float yiq = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_badge_text(bool isBull, float eff) =>
    base = isBull ? "BULL VOID" : "BEAR VOID"
    showBadgeEfficiency ? base + "\nEFF " + str.tostring(eff, "#.00") : base

// -----------------------------------------------------
// Void detection engine
// -----------------------------------------------------
atr14 = ta.atr(14)
avgVol = ta.sma(volume, lookback)
avgRng = ta.sma(high - low, lookback)

rangeExpOK = high - low >= atr14 * rangeExpMult
voidHgtOK = high - low >= atr14 * minVoidATR
rangeRatio = atr14 > 0 ? (high - low) / atr14 : 0
volRatio = avgVol > 0 ? volume / avgVol : 1
efficiency = rangeRatio > 0 ? volRatio / rangeRatio : 1
efficiencyOK = efficiency <= effRatio

bodyStrong = math.abs(close - open) >= (high - low) * 0.5
isBullRaw = rangeExpOK and voidHgtOK and efficiencyOK and close > open and bodyStrong
isBearRaw = rangeExpOK and voidHgtOK and efficiencyOK and close < open and bodyStrong

isBullImpulse = requireGreen ? (isBullRaw[1] and low > close[1] * 0.998) : isBullRaw
isBearImpulse = requireGreen ? (isBearRaw[1] and high < close[1] * 1.002) : isBearRaw

// -----------------------------------------------------
// Void data structure
// -----------------------------------------------------
type Void
    box zone
    line mid
    label lbl
    label badge
    line arrow
    float top
    float bot
    float midPrice
    float effScore
    int bornBar
    bool isBull
    bool mitigated

var array<Void> bullVoids = array.new<Void>()
var array<Void> bearVoids = array.new<Void>()

// -----------------------------------------------------
// Fill-rate proof probe (windowed, honest)
// -----------------------------------------------------
type VoidProbe
    int bornBar
    int left
    bool isBull
    float top
    float bot
    float mid

var array<VoidProbe> voidProbes = array.new<VoidProbe>()
var int pfTotal = 0
var int pfFilled = 0

f_probe_crossed(VoidProbe p) =>
    bool crossed = false
    if mitMode == "Wick Touch"
        crossed := p.isBull ? low <= p.mid : high >= p.mid
    else if mitMode == "Full Fill"
        crossed := p.isBull ? close <= p.bot : close >= p.top
    else
        crossed := p.isBull ? close <= p.mid : close >= p.mid
    crossed

// -----------------------------------------------------
// Create new voids
// -----------------------------------------------------
f_createVoid(bool isBull) =>
    float topP = math.max(open, close)
    float botP = math.min(open, close)
    float midP = (topP + botP) / 2
    float effScore = efficiency
    color zoneCol = isBull ? bullVoidCol : bearVoidCol
    color borderCol = isBull ? color.new(accentColor, 40) : color.new(bearColor, 40)
    color labelCol = isBull ? accentColor : bearColor

    box b = box.new(bar_index, topP, bar_index + zoneExtend, botP, border_color = borderCol, bgcolor = zoneCol, border_width = 1)

    line m = na
    if showMidLine
        m := line.new(bar_index, midP, bar_index + zoneExtend, midP, color = color.new(neutralColor, 40), style = line.style_dotted, width = 1)

    float localHigh = math.max(high, high[1], high[2], high[3], high[4])
    float localLow = math.min(low, low[1], low[2], low[3], low[4])
    float strengthBonus = effRatio > 0 ? (effRatio - effScore) / effRatio : 0.0
    float labelOffset = atr14 * (1.5 + math.max(0.0, strengthBonus))
    float labelY = isBull ? localHigh + labelOffset : localLow - labelOffset
    string labelText = isBull ? "Bull Void\neff " + str.tostring(effScore, "#.00") : "Bear Void\neff " + str.tostring(effScore, "#.00")

    label lb = na
    if showOutsideLabels
        lb := label.new(bar_index, labelY, labelText, style = isBull ? label.style_label_down : label.style_label_up, color = color.new(labelCol, 20), textcolor = f_text_on(labelCol), size = f_toSize(labelSize))

    label bdg = na
    if showZoneBadges
        bdg := label.new(bar_index + int(math.round(zoneExtend * 0.50)), midP, f_badge_text(isBull, effScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(labelCol, 0), textcolor = f_text_on(labelCol), size = f_toSize(labelSize))

    line ar = na
    if showProjArrow
        ar := line.new(bar_index, isBull ? topP : botP, bar_index + math.round(zoneExtend / 3), midP, color = color.new(labelCol, 50), style = line.style_arrow_right, width = 1)

    Void.new(b, m, lb, bdg, ar, topP, botP, midP, effScore, bar_index, isBull, false)

// -----------------------------------------------------
// Prune oldest
// -----------------------------------------------------
f_deleteVoidVisuals(Void v) =>
    if not na(v.zone)
        box.delete(v.zone)
    if not na(v.mid)
        line.delete(v.mid)
    if not na(v.lbl)
        label.delete(v.lbl)
    if not na(v.badge)
        label.delete(v.badge)
    if not na(v.arrow)
        line.delete(v.arrow)

f_pruneOldest(array<Void> arr) =>
    int activeCount = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if not array.get(arr, i).mitigated
                activeCount += 1

    int absoluteMax = maxActive * 5
    while array.size(arr) > absoluteMax
        oldDrop = array.shift(arr)
        f_deleteVoidVisuals(oldDrop)

    while activeCount > maxActive
        if array.size(arr) == 0
            break
        int idx = -1
        for i = 0 to array.size(arr) - 1
            if not array.get(arr, i).mitigated
                idx := i
                break
        if idx < 0
            break
        Void old = array.get(arr, idx)
        f_deleteVoidVisuals(old)
        array.remove(arr, idx)
        activeCount -= 1

// -----------------------------------------------------
// Main detection + proof
// -----------------------------------------------------
if barstate.isconfirmed
    // Resolve pending fill-rate probes first (iterate descending for safe removal)
    if array.size(voidProbes) > 0
        for i = array.size(voidProbes) - 1 to 0
            VoidProbe p = array.get(voidProbes, i)
            if bar_index > p.bornBar
                if f_probe_crossed(p)
                    pfTotal += 1
                    pfFilled += 1
                    array.remove(voidProbes, i)
                else
                    p.left -= 1
                    if p.left <= 0
                        pfTotal += 1
                        array.remove(voidProbes, i)
                    else
                        array.set(voidProbes, i, p)
    if isBullImpulse
        Void v = f_createVoid(true)
        array.push(bullVoids, v)
        f_pruneOldest(bullVoids)
        float tp = math.max(open, close)
        float bp = math.min(open, close)
        array.push(voidProbes, VoidProbe.new(bar_index, fillWindow, true, tp, bp, (tp + bp) / 2))
    if isBearImpulse
        Void v = f_createVoid(false)
        array.push(bearVoids, v)
        f_pruneOldest(bearVoids)
        float tp = math.max(open, close)
        float bp = math.min(open, close)
        array.push(voidProbes, VoidProbe.new(bar_index, fillWindow, false, tp, bp, (tp + bp) / 2))

float pfRate = pfTotal > 0 ? pfFilled / pfTotal * 100.0 : na
string fillRateRead = pfTotal > 0 ? str.tostring(math.round(pfRate)) + "% (" + str.tostring(pfTotal) + ")" : "Building"

// -----------------------------------------------------
// Mitigation check
// -----------------------------------------------------
f_hasMitigationEvent(array<Void> arr) =>
    bool found = false
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Void v = array.get(arr, i)
            if not v.mitigated and bar_index > v.bornBar
                bool crossed = false
                if mitMode == "Wick Touch"
                    crossed := v.isBull ? low <= v.midPrice : high >= v.midPrice
                else if mitMode == "Full Fill"
                    crossed := v.isBull ? close <= v.bot : close >= v.top
                else
                    crossed := v.isBull ? close <= v.midPrice : close >= v.midPrice
                if crossed
                    found := true
    found

f_checkMitigation(array<Void> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Void v = array.get(arr, i)
            if not v.mitigated and bar_index > v.bornBar
                bool crossed = false
                if mitMode == "Wick Touch"
                    crossed := v.isBull ? low <= v.midPrice : high >= v.midPrice
                else if mitMode == "Full Fill"
                    crossed := v.isBull ? close <= v.bot : close >= v.top
                else
                    crossed := v.isBull ? close <= v.midPrice : close >= v.midPrice
                if crossed
                    v.mitigated := true
                    if showMitigated
                        box.set_bgcolor(v.zone, mitigatedCol)
                        box.set_border_color(v.zone, color.new(color.gray, 60))
                        if not na(v.mid)
                            line.delete(v.mid)
                            v.mid := na
                        if not na(v.lbl)
                            label.delete(v.lbl)
                            v.lbl := na
                        if not na(v.badge)
                            label.delete(v.badge)
                            v.badge := na
                    else
                        f_deleteVoidVisuals(v)
                        v.zone := na
                        v.mid := na
                        v.lbl := na
                        v.badge := na
                        v.arrow := na
                    array.set(arr, i, v)
                else if bar_index - v.bornBar >= fillWindow
                    f_deleteVoidVisuals(v)
                    v.zone := na
                    v.mid := na
                    v.lbl := na
                    v.badge := na
                    v.arrow := na
                    v.mitigated := true
                    array.set(arr, i, v)

bool bullMidCross = f_hasMitigationEvent(bullVoids)
bool bearMidCross = f_hasMitigationEvent(bearVoids)

if barstate.isconfirmed
    f_checkMitigation(bullVoids)
    f_checkMitigation(bearVoids)

// -----------------------------------------------------
// Panel metrics
// -----------------------------------------------------
f_computeMetrics() =>
    int activeBull = 0
    int activeBear = 0
    int totalBorn = 0
    int totalMitig = 0
    float minDist = na
    float minEff = na
    string state = "Neutral"
    color stateCol = f_panel_value()

    if array.size(bullVoids) > 0
        for i = 0 to array.size(bullVoids) - 1
            Void v = array.get(bullVoids, i)
            totalBorn += 1
            if v.mitigated
                totalMitig += 1
            else
                activeBull += 1
                float d = math.min(math.abs(close - v.top), math.abs(close - v.bot))
                if na(minDist) or d < minDist
                    minDist := d
                if na(minEff) or v.effScore < minEff
                    minEff := v.effScore
                if close <= v.top and close >= v.bot
                    state := "Inside Bull Void"
                    stateCol := accentColor

    if array.size(bearVoids) > 0
        for i = 0 to array.size(bearVoids) - 1
            Void v = array.get(bearVoids, i)
            totalBorn += 1
            if v.mitigated
                totalMitig += 1
            else
                activeBear += 1
                float d = math.min(math.abs(close - v.top), math.abs(close - v.bot))
                if na(minDist) or d < minDist
                    minDist := d
                if na(minEff) or v.effScore < minEff
                    minEff := v.effScore
                if close <= v.top and close >= v.bot
                    state := "Inside Bear Void"
                    stateCol := bearColor

    float fillRate = totalBorn > 0 ? totalMitig / totalBorn * 100 : 0
    [activeBull, activeBear, minDist, minEff, state, stateCol, fillRate]

// -----------------------------------------------------
// Strongest void highlight
// -----------------------------------------------------
f_highlightStrongest(array<Void> arr, color baseBorder) =>
    float minE = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Void v = array.get(arr, i)
            if not v.mitigated
                if na(minE) or v.effScore < minE
                    minE := v.effScore
    if array.size(arr) > 0 and not na(minE)
        for i = 0 to array.size(arr) - 1
            Void v = array.get(arr, i)
            if not v.mitigated and not na(v.zone)
                if v.effScore == minE
                    box.set_border_width(v.zone, 3)
                    box.set_border_color(v.zone, color.new(neutralColor, 20))
                else
                    box.set_border_width(v.zone, 1)
                    box.set_border_color(v.zone, color.new(baseBorder, 40))

// -----------------------------------------------------
// Panel render
// -----------------------------------------------------
var table panel = na

if barstate.islast
    f_highlightStrongest(bullVoids, accentColor)
    f_highlightStrongest(bearVoids, bearColor)

if barstate.islast and showPanel
    if na(panel)
        panel := table.new(f_toPos(panelPos), 2, 8, border_width = 1, border_color = f_panel_border(), frame_color = f_panel_border(), frame_width = 1, bgcolor = f_panel_bg())
    table.set_position(panel, f_toPos(panelPos))
    table.clear(panel, 0, 0, 1, 7)
    table.cell(panel, 0, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_toSize(panelFontSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Liquidity Void Navigator", text_color = headerText, bgcolor = headerBg, text_size = f_toSize(panelFontSize), text_halign = text.align_center)

    [activeBull, activeBear, nearDist, strongest, state, stateCol, fillRate] = f_computeMetrics()

    table.cell(panel, 0, 1, "State", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 1, state, text_color = stateCol, bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))

    string nearStr = na(nearDist) ? "None" : str.tostring(nearDist / atr14, "#.00") + " ATR"
    table.cell(panel, 0, 2, "Nearest Void", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 2, nearStr, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))

    string strongStr = na(strongest) ? "-" : "eff " + str.tostring(strongest, "#.00")
    table.cell(panel, 0, 3, "Best Efficiency", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 3, strongStr, text_color = neutralColor, bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))

    table.cell(panel, 0, 4, "Active Voids", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 4, str.tostring(activeBull) + " Bull / " + str.tostring(activeBear) + " Bear", text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))

    color fillCol = na(pfRate) ? f_panel_value() : pfRate >= 60.0 ? bullColor : pfRate >= 40.0 ? neutralColor : bearColor
    table.cell(panel, 0, 5, "Fill Rate", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 5, fillRateRead, text_color = fillCol, bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))

    string effStr = str.tostring(efficiency, "#.00") + " / " + str.tostring(effRatio, "#.00")
    color effCol = efficiency <= effRatio ? bullColor : f_panel_value()
    table.cell(panel, 0, 6, "Current / Gate", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 6, effStr, text_color = effCol, bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))

    string actionStr = "Wait for void"
    color actionCol = f_panel_value()
    if state == "Inside Bull Void"
        actionStr := "Review bull void"
        actionCol := accentColor
    else if state == "Inside Bear Void"
        actionStr := "Review bear void"
        actionCol := bearColor
    else if activeBull + activeBear > 0
        actionStr := "Watch nearest void"
        actionCol := neutralColor
    table.cell(panel, 0, 7, "Action", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))
    table.cell(panel, 1, 7, actionStr, text_color = actionCol, bgcolor = f_panel_bg(), text_size = f_toSize(panelFontSize))

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

// -----------------------------------------------------
// Data window
// -----------------------------------------------------
plot(pfRate, title = "Void Fill Rate", color = bullColor, display = display.data_window)

// -----------------------------------------------------
// Alerts
// -----------------------------------------------------
alertcondition(barstate.isconfirmed and isBullImpulse, title = "New Bullish Liquidity Void", message = "New Bullish Liquidity Void detected on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and isBearImpulse, title = "New Bearish Liquidity Void", message = "New Bearish Liquidity Void detected on {{ticker}} {{interval}}")

alertcondition(barstate.isconfirmed and bullMidCross, title = "Bull Void Mitigated", message = "Bullish Liquidity Void mitigated on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and bearMidCross, title = "Bear Void Mitigated", message = "Bearish Liquidity Void mitigated on {{ticker}} {{interval}}")
````
