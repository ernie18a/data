# SMT Divergence Multi-TF

- url: https://www.tradingview.com/script/zqXiMHtX-SMT-Divergence-Multi-TF/
- type: indicator
- pine_id: PUB;7b88997c98ec43e990d444c5cb376038
- version: 1.0

## Description

# Smart Money Technique (SMT) — Multi-Timeframe, Multi-Asset Divergence Tracker

**Map every SMT divergence across timeframes and correlated assets — without losing your chart to clutter.**

Smart Money Technique (SMT) divergences are one of the cleanest tools in the ICT toolkit: when two correlated assets fail to confirm the same swing, the divergence reveals that liquidity is being engineered on one side of the move. This indicator detects SMT divergences across up to three comparison assets simultaneously, across eight timeframes, and renders them with smart label handling that keeps the chart readable even when divergences stack.

## Features

**Multi-asset comparison** — track up to 3 comparison assets at once, each independently toggleable. Defaults to MNQ/MES/MYM but accepts any correlated pair (e-minis, micros, equity index ETFs, sector or FX correlations).

**Eight timeframes** — 1m, 3m, 5m, 15m, 30m, 1h, 4h, and Daily, each toggleable independently. Higher timeframes render with thicker dashed lines for instant TF identification at a glance.

**Wick-to-wick line rendering** — divergence lines anchor precisely at the swing wicks, not approximations. Uses bar-time anchoring so lines stay accurate across all timeframes without drifting.

**Smart label collision handling** — when multiple SMTs stack at the same swing point (e.g. 5m + 15m + 30m confluence), labels are automatically offset vertically using ATR-scaled spacing. No overlapping text, no garbled stacks. Smallest timeframe sits closest to the wick; higher timeframes layer outward as visual confluence indicators.

**Clean ticker labels** — strips exchange prefixes and contract suffixes automatically, so `CME_MINI:MNQ1!` displays as just `MNQ`. Each label shows asset and timeframe (e.g. `MNQ · 15m`).

**Configurable colors and styles** — every comparison asset has its own line color. Bullish and bearish SMTs can share a color or split independently for additional visual distinction.

**Per-asset, per-timeframe alerts** — bullish and bearish alert conditions for every combination, so you can route signals by setup quality rather than getting pinged on every minor swing.

**Non-repainting** — uses confirmed pivots and lookahead-off security calls. What prints in real time is what stays.

## Built For

ICT, Quarterly Theory, and Wyckoff traders who want SMT confluence visualized across timeframes and assets simultaneously. Particularly valuable when scanning for high-conviction setups where a single swing point shows divergence across multiple correlated indices and timeframes — the kind of confluence that doesn't survive on charts littered with overlapping text and misaligned lines.

## Settings

- Up to 3 configurable comparison assets (symbol, color, enable per asset)
- 8 independent timeframe toggles
- Pivot strength and cross-asset matching tolerance
- Label stacking: ATR multiplier, max stack height, time tolerance
- Line management: per-TF line limits and style customization
- Ticker cleanup toggle for clean displayed names

## Source Code

````pine
//@version=6
indicator("SMT Divergence Multi-TF", shorttitle="SMT MTF", overlay=true,
     max_lines_count=500, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================

gSwing = "Swing Detection"
pivotLeft     = input.int(2, "Pivot left bars",  minval=1, group=gSwing)
pivotRight    = input.int(2, "Pivot right bars", minval=1, group=gSwing,
     tooltip="Bars to the right needed to confirm a pivot. Pivots are non-repainting once confirmed.")
toleranceBars = input.int(3, "Pivot match tolerance (bars)", minval=0, group=gSwing,
     tooltip="Comparison-asset pivot must occur within ±this many bars of the primary pivot, at the SMT timeframe.")

gDisp = "Display"
maxLinesPerCombo = input.int(10, "Max lines per TF/comparison", minval=1, group=gDisp,
     tooltip="Each line gets a paired label; both are FIFO-evicted together. Hard ceiling is 500 of each.")
dashHigherTF  = input.bool(true,  "Dashed lines for higher TFs",         group=gDisp)
thickHigherTF = input.bool(true,  "Thicker lines (width 2) for higher TFs", group=gDisp)

gLabels = "SMT Labels"
showLabels           = input.bool(true,    "Show labels",                            group=gLabels)
labelTextSize        = input.string("small","Label text size",
                                    options=["tiny","small","normal"],               group=gLabels)
showTimeframeInLabel = input.bool(true,    "Include timeframe in label",             group=gLabels,
     tooltip="Off → labels show only the ticker (e.g. 'MNQ'). On → 'MNQ · 5m'.")
tickerCleanup        = input.bool(true,    "Strip exchange prefix & contract suffix",group=gLabels,
     tooltip="On → 'CME_MINI:MNQ1!' displays as 'MNQ'. Off → the full symbol string is used.")

gStack = "Label Stacking"
enableLabelStacking   = input.bool(true,  "Enable vertical stacking on collision",  group=gStack,
     tooltip="When multiple labels would land at the same swing point, push them apart vertically so they don't overlap.")
stackingTimeTolerance = input.int(2,      "Collision window (chart bars)", minval=0, group=gStack,
     tooltip="Two labels are considered colliding if their anchor times are within this many CHART bars of each other.")
offsetMultiplier      = input.float(0.3,  "Offset per row (× ATR-20)",     minval=0.05, step=0.05, group=gStack,
     tooltip="Vertical spacing between stacked labels, scaled by 20-bar ATR so it adapts to instrument volatility.")
maxStackHeight        = input.int(5,      "Max labels per stack",          minval=1,    group=gStack,
     tooltip="Hard cap on a single stack. Additional labels at the same swing are silently dropped (count surfaces in the status line).")

gC1 = "Comparison 1"
c1_en    = input.bool(true,                "Enable",                  group=gC1)
c1_sym   = input.symbol("CME_MINI:MNQ1!",  "Symbol",                  group=gC1)
c1_col   = input.color(color.aqua,         "Line color (default)",    group=gC1)
c1_split = input.bool(false,               "Split bull/bear colors",  group=gC1)
c1_bull  = input.color(color.aqua,         "Bull color", group=gC1, inline="c1bb")
c1_bear  = input.color(color.aqua,         "Bear color", group=gC1, inline="c1bb")

gC2 = "Comparison 2"
c2_en    = input.bool(true,                "Enable",                  group=gC2)
c2_sym   = input.symbol("CME_MINI:MES1!",  "Symbol",                  group=gC2)
c2_col   = input.color(color.orange,       "Line color (default)",    group=gC2)
c2_split = input.bool(false,               "Split bull/bear colors",  group=gC2)
c2_bull  = input.color(color.orange,       "Bull color", group=gC2, inline="c2bb")
c2_bear  = input.color(color.orange,       "Bear color", group=gC2, inline="c2bb")

gC3 = "Comparison 3"
c3_en    = input.bool(false,               "Enable",                  group=gC3)
c3_sym   = input.symbol("CBOT_MINI:MYM1!", "Symbol",                  group=gC3)
c3_col   = input.color(color.fuchsia,      "Line color (default)",    group=gC3)
c3_split = input.bool(false,               "Split bull/bear colors",  group=gC3)
c3_bull  = input.color(color.fuchsia,      "Bull color", group=gC3, inline="c3bb")
c3_bear  = input.color(color.fuchsia,      "Bear color", group=gC3, inline="c3bb")

gTF = "Timeframes"
tf1m_en  = input.bool(true, "1m",  group=gTF, inline="tA")
tf3m_en  = input.bool(true, "3m",  group=gTF, inline="tA")
tf5m_en  = input.bool(true, "5m",  group=gTF, inline="tA")
tf15m_en = input.bool(true, "15m", group=gTF, inline="tA")
tf30m_en = input.bool(true, "30m", group=gTF, inline="tB")
tf1h_en  = input.bool(true, "1h",  group=gTF, inline="tB")
tf4h_en  = input.bool(true, "4h",  group=gTF, inline="tB")
tfD_en   = input.bool(true, "D",   group=gTF, inline="tB")

// ============================================================
// TYPES
// ============================================================
type Piv
    int   t
    float price

type PivFetch
    float phFire
    float plFire
    int   t
    float h
    float l

type SmtState
    array<Piv>   priH
    array<Piv>   priL
    array<Piv>   cmpH
    array<Piv>   cmpL
    array<line>  lines
    array<label> labels

// One row in the global label-stack registry. A registry entry represents
// "an in-progress stack of labels at this swing/direction"; `count` is the
// row index the NEXT incoming label should occupy.
type StackEntry
    int  t       // anchor time (ms) of the swing this stack lives on
    bool isBear  // true = bearish (stacks UP from wick); false = bullish (stacks DOWN)
    int  count   // labels already placed in this stack

// Single-int holder so processSmt() can bump it from inside a function.
// Pine forbids mutating scalar globals across function boundaries, but UDT
// fields are reference-typed and freely mutable — same trick as stackRegistry.
type Counter
    int value

newState() =>
    SmtState.new(array.new<Piv>(),  array.new<Piv>(),
                 array.new<Piv>(),  array.new<Piv>(),
                 array.new<line>(), array.new<label>())


// ============================================================
// GLOBAL STATE  (stacking registry + skipped-label counter)
// ============================================================
// One global registry for the WHOLE indicator — collisions are detected
// across all (TF × comparison) combos, not just within one combo. Two labels
// that happen to anchor at the same swing on different TFs/comparisons
// should still stack apart, which requires shared state.
var array<StackEntry> stackRegistry = array.new<StackEntry>()

// Running count of labels dropped because their stack hit maxStackHeight.
// Surfaced in the status line so you know when to widen maxStackHeight or
// loosen the collision window.
// was: var int stackSkipped = 0
var Counter stackSkipped = Counter.new(0)

// 20-bar ATR drives the vertical spacing — same units as price, scaled by
// volatility so the spacing looks consistent across instruments. nz() guards
// the first 20 bars when ATR is still na (no SMT fires that early anyway).
atr20         = ta.atr(20)
stackOffsetPx = nz(atr20) * offsetMultiplier
chartBarMs    = timeframe.in_seconds(timeframe.period) * 1000
stackTolMs    = stackingTimeTolerance * chartBarMs

// ============================================================
// HELPERS
// ============================================================
pushPiv(array<Piv> arr, int t, float price, int maxKeep) =>
    if not na(t) and not na(price) and (arr.size() == 0 or arr.get(arr.size() - 1).t != t)
        arr.push(Piv.new(t, price))
        while arr.size() > maxKeep
            arr.shift()

findNear(array<Piv> arr, int targetT, int tolMs) =>
    Piv best = na
    int bestDiff = tolMs + 1
    if not na(targetT) and arr.size() > 0
        for i = 0 to arr.size() - 1
            p = arr.get(i)
            d = math.abs(p.t - targetT)
            if d <= tolMs and d < bestDiff
                bestDiff := d
                best := p
    best

trimLines(array<line> arr, int maxN) =>
    while arr.size() > maxN
        line.delete(arr.shift())

trimLabels(array<label> arr, int maxN) =>
    while arr.size() > maxN
        lb = arr.shift()
        if not na(lb)
            label.delete(lb)

tolMsFor(simple string tf, simple int tolBars) =>
    timeframe.in_seconds(tf) * 1000 * tolBars

isHigherTF(simple string tf) =>
    timeframe.in_seconds(tf) > timeframe.in_seconds(timeframe.period)

isChartTF(simple string tf) =>
    timeframe.in_seconds(tf) == timeframe.in_seconds(timeframe.period)

tfAllowed(simple string tf) =>
    timeframe.in_seconds(tf) >= timeframe.in_seconds(timeframe.period)

sizeFor(simple string s) =>
    s == "tiny" ? size.tiny : s == "normal" ? size.normal : size.small

tfDisplay(simple string tf) =>
    int secs = timeframe.in_seconds(tf)
    secs < 60     ? tf + "s" :
     secs < 3600  ? str.tostring(secs / 60) + "m" :
     secs < 86400 ? str.tostring(secs / 3600) + "h" :
     tf == "D"    ? "D" :
     tf == "W"    ? "W" :
     tf == "M"    ? "M" :
     tf

cleanTicker(string sym, bool doClean) =>
    string result = sym
    if doClean
        parts = str.split(sym, ":")
        base  = parts.size() > 1 ? parts.get(parts.size() - 1) : sym
        result := base
        if str.endswith(result, "!")
            result := str.substring(result, 0, str.length(result) - 1)
        endIdx = str.length(result)
        newEnd = endIdx
        if endIdx > 0
            for i = endIdx - 1 to 0
                ch = str.substring(result, i, i + 1)
                if str.contains("0123456789", ch)
                    newEnd := i
                else
                    break
        if newEnd < endIdx and newEnd > 0
            result := str.substring(result, 0, newEnd)
    result

shortName(string sym) =>
    parts = str.split(sym, ":")
    parts.size() > 1 ? parts.get(parts.size() - 1) : sym

// === COLLISION / STACK MANAGEMENT ===
//
// Returns the stack ROW the incoming label should occupy:
//   0  = first/closest-to-wick label at this swing (no vertical offset)
//   1+ = stacked further out from the wick by `row * stackOffsetPx`
//   -1 = stack already at maxHeight — caller should skip creating the label
//
// Collision rule: a new label joins an existing stack iff
//   (1) same direction (both bearish OR both bullish), AND
//   (2) anchor times within ±tolMs.
// Opposite-direction labels at the same anchor never collide — one is above
// the wick (bearish stack), the other below (bullish stack).
//
// Ordering: append-only by arrival. Smaller timeframes confirm pivots faster
// (fewer chart bars of right-side confirmation needed), so the typical
// arrival order is small→large TF, which is exactly the spec'd visual order
// (smallest TF closest to wick). We don't reflow when lines later get
// FIFO-evicted — gaps in the stack are accepted as the cost of simplicity.
registerStack(int anchorT, bool isBear, int tolMs, int maxHeight) =>
    int  row      = 0
    int  foundIdx = -1
    if stackRegistry.size() > 0
        for i = 0 to stackRegistry.size() - 1
            e = stackRegistry.get(i)
            if e.isBear == isBear and math.abs(e.t - anchorT) <= tolMs
                foundIdx := i
                break
    if foundIdx >= 0
        e = stackRegistry.get(foundIdx)
        if e.count >= maxHeight
            row := -1
        else
            row     := e.count
            e.count := row + 1   // mutates the entry in-place (UDTs are by reference)
    else
        // First label at this swing: occupies row 0, register count=1 for the next.
        stackRegistry.push(StackEntry.new(anchorT, isBear, 1))
        row := 0
    // Keep the registry bounded. Old entries refer to swings long since rolled
    // off the chart (their lines are already FIFO-evicted), so dropping the
    // oldest is harmless.
    while stackRegistry.size() > 200
        stackRegistry.shift()
    row

// ============================================================
// PIVOT CAPTURE
// ============================================================
chartPivots(simple int leftBars, simple int rightBars) =>
    ph = ta.pivothigh(leftBars, rightBars)
    pl = ta.pivotlow(leftBars, rightBars)
    PivFetch.new(ph, pl, time[rightBars], high[rightBars], low[rightBars])

fetchPivots(simple string sym, simple string tf, simple int leftBars, simple int rightBars) =>
    [ph, pl, t, h, l] = request.security(sym, tf,
         [ta.pivothigh(leftBars, rightBars),
          ta.pivotlow(leftBars, rightBars),
          time[rightBars],
          high[rightBars],
          low[rightBars]],
         lookahead = barmerge.lookahead_off)
    PivFetch.new(ph, pl, t, h, l)

// ============================================================
// SMT DETECTION + DRAWING
// ============================================================
processSmt(SmtState s, simple string tfStr, string compName,
           PivFetch pri, PivFetch cmp, int tolMs,
           color baseCol, bool splitCol, color bullCol, color bearCol,
           int lineWidth, string lineStyle,
           int maxLines) =>

    pivStoreMax = 30

    // === CAPTURE PIVOTS ===
    if not na(pri.phFire)
        pushPiv(s.priH, pri.t, pri.h, pivStoreMax)
    if not na(pri.plFire)
        pushPiv(s.priL, pri.t, pri.l, pivStoreMax)
    if not na(cmp.phFire)
        pushPiv(s.cmpH, cmp.t, cmp.h, pivStoreMax)
    if not na(cmp.plFire)
        pushPiv(s.cmpL, cmp.t, cmp.l, pivStoreMax)

    bool bullSig = false
    bool bearSig = false

    string lblText = showTimeframeInLabel ? compName + " · " + tfDisplay(tfStr) : compName

    // === BEARISH SMT === primary higher-high, comparison lower-high.
    bool newPriH = not na(pri.phFire) and s.priH.size() > 0 and s.priH.get(s.priH.size() - 1).t == pri.t
    if newPriH and s.priH.size() >= 2
        currP = s.priH.get(s.priH.size() - 1)
        prevP = s.priH.get(s.priH.size() - 2)
        currC = findNear(s.cmpH, currP.t, tolMs)
        prevC = findNear(s.cmpH, prevP.t, tolMs)
        if not na(currC) and not na(prevC) and currP.price > prevP.price and currC.price < prevC.price
            bearSig := true
            col = splitCol ? bearCol : baseCol

            // Line stays at the actual wick — only the label gets offset.
            l = line.new(prevP.t, prevP.price, currP.t, currP.price,
                         xloc=xloc.bar_time, color=col, width=lineWidth, style=lineStyle)
            s.lines.push(l)

            label lbl = na
            if showLabels
                // Ask the global registry where this label belongs in its stack.
                // isBear=true → push UPWARD (price + row * offset).
                int stackRow = enableLabelStacking
                     ? registerStack(currP.t, true, stackTolMs, maxStackHeight)
                     : 0
                if stackRow < 0
                    // Stack overflowed maxStackHeight; surface the drop in the
                    // status line so the user can widen the cap if needed.
                    // was: stackSkipped := stackSkipped + 1
                    stackSkipped.value := stackSkipped.value + 1
                else
                    // Row 0 sits AT the wick (the style_label_down arrow already
                    // visually nudges the text above the anchor); rows 1+ add
                    // explicit price-space offset to clear the labels below them.
                    float labelY = currP.price + stackRow * stackOffsetPx
                    lbl := label.new(currP.t, labelY, lblText,
                                     xloc=xloc.bar_time,
                                     style=label.style_label_down,
                                     color=color.new(color.black, 100),
                                     textcolor=col,
                                     size=sizeFor(labelTextSize))
            s.labels.push(lbl)

            trimLines(s.lines,  maxLines)
            trimLabels(s.labels, maxLines)

    // === BULLISH SMT === primary lower-low, comparison higher-low.
    bool newPriL = not na(pri.plFire) and s.priL.size() > 0 and s.priL.get(s.priL.size() - 1).t == pri.t
    if newPriL and s.priL.size() >= 2
        currP = s.priL.get(s.priL.size() - 1)
        prevP = s.priL.get(s.priL.size() - 2)
        currC = findNear(s.cmpL, currP.t, tolMs)
        prevC = findNear(s.cmpL, prevP.t, tolMs)
        if not na(currC) and not na(prevC) and currP.price < prevP.price and currC.price > prevC.price
            bullSig := true
            col = splitCol ? bullCol : baseCol

            l = line.new(prevP.t, prevP.price, currP.t, currP.price,
                         xloc=xloc.bar_time, color=col, width=lineWidth, style=lineStyle)
            s.lines.push(l)

            label lbl = na
            if showLabels
                // isBear=false → bullish stack pushes DOWNWARD (price - row * offset).
                int stackRow = enableLabelStacking
                     ? registerStack(currP.t, false, stackTolMs, maxStackHeight)
                     : 0
                if stackRow < 0
                    stackSkipped.value := stackSkipped.value + 1
                else
                    float labelY = currP.price - stackRow * stackOffsetPx
                    lbl := label.new(currP.t, labelY, lblText,
                                     xloc=xloc.bar_time,
                                     style=label.style_label_up,
                                     color=color.new(color.black, 100),
                                     textcolor=col,
                                     size=sizeFor(labelTextSize))
            s.labels.push(lbl)

            trimLines(s.lines,  maxLines)
            trimLabels(s.labels, maxLines)

    [bullSig, bearSig]

runOne(SmtState s, simple string tfStr, bool tfEn,
       PivFetch pri, PivFetch cmp,
       bool cEn, string cSym, color baseCol, bool splitCol, color bullCol, color bearCol) =>
    bool bull = false
    bool bear = false
    if cEn and tfEn and tfAllowed(tfStr)
        bool higher = isHigherTF(tfStr)
        int  lw = higher and thickHigherTF ? 2 : 1
        string ls = higher and dashHigherTF ? line.style_dashed : line.style_solid
        string compDisplay = cleanTicker(cSym, tickerCleanup)
        [b, r] = processSmt(s, tfStr, compDisplay, pri, cmp,
                            tolMsFor(tfStr, toleranceBars),
                            baseCol, splitCol, bullCol, bearCol,
                            lw, ls, maxLinesPerCombo)
        bull := b
        bear := r
    [bull, bear]

// ============================================================
// STATE
// ============================================================
var s_1m_1  = newState()
var s_1m_2  = newState()
var s_1m_3  = newState()
var s_3m_1  = newState()
var s_3m_2  = newState()
var s_3m_3  = newState()
var s_5m_1  = newState()
var s_5m_2  = newState()
var s_5m_3  = newState()
var s_15m_1 = newState()
var s_15m_2 = newState()
var s_15m_3 = newState()
var s_30m_1 = newState()
var s_30m_2 = newState()
var s_30m_3 = newState()
var s_1h_1  = newState()
var s_1h_2  = newState()
var s_1h_3  = newState()
var s_4h_1  = newState()
var s_4h_2  = newState()
var s_4h_3  = newState()
var s_D_1   = newState()
var s_D_2   = newState()
var s_D_3   = newState()

// ============================================================
// FETCH PIVOTS
// ============================================================
p_chart = chartPivots(pivotLeft, pivotRight)

p_1m  = isChartTF("1")   ? p_chart : fetchPivots(syminfo.tickerid, "1",   pivotLeft, pivotRight)
p_3m  = isChartTF("3")   ? p_chart : fetchPivots(syminfo.tickerid, "3",   pivotLeft, pivotRight)
p_5m  = isChartTF("5")   ? p_chart : fetchPivots(syminfo.tickerid, "5",   pivotLeft, pivotRight)
p_15m = isChartTF("15")  ? p_chart : fetchPivots(syminfo.tickerid, "15",  pivotLeft, pivotRight)
p_30m = isChartTF("30")  ? p_chart : fetchPivots(syminfo.tickerid, "30",  pivotLeft, pivotRight)
p_1h  = isChartTF("60")  ? p_chart : fetchPivots(syminfo.tickerid, "60",  pivotLeft, pivotRight)
p_4h  = isChartTF("240") ? p_chart : fetchPivots(syminfo.tickerid, "240", pivotLeft, pivotRight)
p_D   = isChartTF("D")   ? p_chart : fetchPivots(syminfo.tickerid, "D",   pivotLeft, pivotRight)

c1_1m  = fetchPivots(c1_sym, "1",   pivotLeft, pivotRight)
c1_3m  = fetchPivots(c1_sym, "3",   pivotLeft, pivotRight)
c1_5m  = fetchPivots(c1_sym, "5",   pivotLeft, pivotRight)
c1_15m = fetchPivots(c1_sym, "15",  pivotLeft, pivotRight)
c1_30m = fetchPivots(c1_sym, "30",  pivotLeft, pivotRight)
c1_1h  = fetchPivots(c1_sym, "60",  pivotLeft, pivotRight)
c1_4h  = fetchPivots(c1_sym, "240", pivotLeft, pivotRight)
c1_D   = fetchPivots(c1_sym, "D",   pivotLeft, pivotRight)

c2_1m  = fetchPivots(c2_sym, "1",   pivotLeft, pivotRight)
c2_3m  = fetchPivots(c2_sym, "3",   pivotLeft, pivotRight)
c2_5m  = fetchPivots(c2_sym, "5",   pivotLeft, pivotRight)
c2_15m = fetchPivots(c2_sym, "15",  pivotLeft, pivotRight)
c2_30m = fetchPivots(c2_sym, "30",  pivotLeft, pivotRight)
c2_1h  = fetchPivots(c2_sym, "60",  pivotLeft, pivotRight)
c2_4h  = fetchPivots(c2_sym, "240", pivotLeft, pivotRight)
c2_D   = fetchPivots(c2_sym, "D",   pivotLeft, pivotRight)

c3_1m  = fetchPivots(c3_sym, "1",   pivotLeft, pivotRight)
c3_3m  = fetchPivots(c3_sym, "3",   pivotLeft, pivotRight)
c3_5m  = fetchPivots(c3_sym, "5",   pivotLeft, pivotRight)
c3_15m = fetchPivots(c3_sym, "15",  pivotLeft, pivotRight)
c3_30m = fetchPivots(c3_sym, "30",  pivotLeft, pivotRight)
c3_1h  = fetchPivots(c3_sym, "60",  pivotLeft, pivotRight)
c3_4h  = fetchPivots(c3_sym, "240", pivotLeft, pivotRight)
c3_D   = fetchPivots(c3_sym, "D",   pivotLeft, pivotRight)

// ============================================================
// RUN DETECTION  (order matters: smaller TFs first so they win row 0 in stacks)
// ============================================================
[bull_1m_1,  bear_1m_1 ] = runOne(s_1m_1,  "1",   tf1m_en,  p_1m,  c1_1m,  c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_1m_2,  bear_1m_2 ] = runOne(s_1m_2,  "1",   tf1m_en,  p_1m,  c2_1m,  c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_1m_3,  bear_1m_3 ] = runOne(s_1m_3,  "1",   tf1m_en,  p_1m,  c3_1m,  c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)
[bull_3m_1,  bear_3m_1 ] = runOne(s_3m_1,  "3",   tf3m_en,  p_3m,  c1_3m,  c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_3m_2,  bear_3m_2 ] = runOne(s_3m_2,  "3",   tf3m_en,  p_3m,  c2_3m,  c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_3m_3,  bear_3m_3 ] = runOne(s_3m_3,  "3",   tf3m_en,  p_3m,  c3_3m,  c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)
[bull_5m_1,  bear_5m_1 ] = runOne(s_5m_1,  "5",   tf5m_en,  p_5m,  c1_5m,  c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_5m_2,  bear_5m_2 ] = runOne(s_5m_2,  "5",   tf5m_en,  p_5m,  c2_5m,  c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_5m_3,  bear_5m_3 ] = runOne(s_5m_3,  "5",   tf5m_en,  p_5m,  c3_5m,  c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)
[bull_15m_1, bear_15m_1] = runOne(s_15m_1, "15",  tf15m_en, p_15m, c1_15m, c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_15m_2, bear_15m_2] = runOne(s_15m_2, "15",  tf15m_en, p_15m, c2_15m, c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_15m_3, bear_15m_3] = runOne(s_15m_3, "15",  tf15m_en, p_15m, c3_15m, c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)
[bull_30m_1, bear_30m_1] = runOne(s_30m_1, "30",  tf30m_en, p_30m, c1_30m, c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_30m_2, bear_30m_2] = runOne(s_30m_2, "30",  tf30m_en, p_30m, c2_30m, c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_30m_3, bear_30m_3] = runOne(s_30m_3, "30",  tf30m_en, p_30m, c3_30m, c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)
[bull_1h_1,  bear_1h_1 ] = runOne(s_1h_1,  "60",  tf1h_en,  p_1h,  c1_1h,  c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_1h_2,  bear_1h_2 ] = runOne(s_1h_2,  "60",  tf1h_en,  p_1h,  c2_1h,  c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_1h_3,  bear_1h_3 ] = runOne(s_1h_3,  "60",  tf1h_en,  p_1h,  c3_1h,  c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)
[bull_4h_1,  bear_4h_1 ] = runOne(s_4h_1,  "240", tf4h_en,  p_4h,  c1_4h,  c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_4h_2,  bear_4h_2 ] = runOne(s_4h_2,  "240", tf4h_en,  p_4h,  c2_4h,  c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_4h_3,  bear_4h_3 ] = runOne(s_4h_3,  "240", tf4h_en,  p_4h,  c3_4h,  c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)
[bull_D_1,   bear_D_1  ] = runOne(s_D_1,   "D",   tfD_en,   p_D,   c1_D,   c1_en, c1_sym, c1_col, c1_split, c1_bull, c1_bear)
[bull_D_2,   bear_D_2  ] = runOne(s_D_2,   "D",   tfD_en,   p_D,   c2_D,   c2_en, c2_sym, c2_col, c2_split, c2_bull, c2_bear)
[bull_D_3,   bear_D_3  ] = runOne(s_D_3,   "D",   tfD_en,   p_D,   c3_D,   c3_en, c3_sym, c3_col, c3_split, c3_bull, c3_bear)

// ============================================================
// STATUS LINE
// ============================================================
// Surfaces the skipped-label counter; rendered only when > 0 so it doesn't
// clutter the status line on clean runs. Transparent color + status-line
// display keeps it off the chart pane itself.
// was: plot(stackSkipped > 0 ? stackSkipped : na, "Labels skipped (stack overflow)",
plot(stackSkipped.value > 0 ? stackSkipped.value : na, "Labels skipped (stack overflow)",
     color=color.new(color.gray, 100), display=display.status_line, editable=false)

// ============================================================
// ALERTS
// ============================================================
alertcondition(bull_1m_1,  "Bullish SMT 1m vs C1",   "Bullish SMT on 1m vs Comparison 1")
alertcondition(bear_1m_1,  "Bearish SMT 1m vs C1",   "Bearish SMT on 1m vs Comparison 1")
alertcondition(bull_1m_2,  "Bullish SMT 1m vs C2",   "Bullish SMT on 1m vs Comparison 2")
alertcondition(bear_1m_2,  "Bearish SMT 1m vs C2",   "Bearish SMT on 1m vs Comparison 2")
alertcondition(bull_1m_3,  "Bullish SMT 1m vs C3",   "Bullish SMT on 1m vs Comparison 3")
alertcondition(bear_1m_3,  "Bearish SMT 1m vs C3",   "Bearish SMT on 1m vs Comparison 3")
alertcondition(bull_3m_1,  "Bullish SMT 3m vs C1",   "Bullish SMT on 3m vs Comparison 1")
alertcondition(bear_3m_1,  "Bearish SMT 3m vs C1",   "Bearish SMT on 3m vs Comparison 1")
alertcondition(bull_3m_2,  "Bullish SMT 3m vs C2",   "Bullish SMT on 3m vs Comparison 2")
alertcondition(bear_3m_2,  "Bearish SMT 3m vs C2",   "Bearish SMT on 3m vs Comparison 2")
alertcondition(bull_3m_3,  "Bullish SMT 3m vs C3",   "Bullish SMT on 3m vs Comparison 3")
alertcondition(bear_3m_3,  "Bearish SMT 3m vs C3",   "Bearish SMT on 3m vs Comparison 3")
alertcondition(bull_5m_1,  "Bullish SMT 5m vs C1",   "Bullish SMT on 5m vs Comparison 1")
alertcondition(bear_5m_1,  "Bearish SMT 5m vs C1",   "Bearish SMT on 5m vs Comparison 1")
alertcondition(bull_5m_2,  "Bullish SMT 5m vs C2",   "Bullish SMT on 5m vs Comparison 2")
alertcondition(bear_5m_2,  "Bearish SMT 5m vs C2",   "Bearish SMT on 5m vs Comparison 2")
alertcondition(bull_5m_3,  "Bullish SMT 5m vs C3",   "Bullish SMT on 5m vs Comparison 3")
alertcondition(bear_5m_3,  "Bearish SMT 5m vs C3",   "Bearish SMT on 5m vs Comparison 3")
alertcondition(bull_15m_1, "Bullish SMT 15m vs C1",  "Bullish SMT on 15m vs Comparison 1")
alertcondition(bear_15m_1, "Bearish SMT 15m vs C1",  "Bearish SMT on 15m vs Comparison 1")
alertcondition(bull_15m_2, "Bullish SMT 15m vs C2",  "Bullish SMT on 15m vs Comparison 2")
alertcondition(bear_15m_2, "Bearish SMT 15m vs C2",  "Bearish SMT on 15m vs Comparison 2")
alertcondition(bull_15m_3, "Bullish SMT 15m vs C3",  "Bullish SMT on 15m vs Comparison 3")
alertcondition(bear_15m_3, "Bearish SMT 15m vs C3",  "Bearish SMT on 15m vs Comparison 3")
alertcondition(bull_30m_1, "Bullish SMT 30m vs C1",  "Bullish SMT on 30m vs Comparison 1")
alertcondition(bear_30m_1, "Bearish SMT 30m vs C1",  "Bearish SMT on 30m vs Comparison 1")
alertcondition(bull_30m_2, "Bullish SMT 30m vs C2",  "Bullish SMT on 30m vs Comparison 2")
alertcondition(bear_30m_2, "Bearish SMT 30m vs C2",  "Bearish SMT on 30m vs Comparison 2")
alertcondition(bull_30m_3, "Bullish SMT 30m vs C3",  "Bullish SMT on 30m vs Comparison 3")
alertcondition(bear_30m_3, "Bearish SMT 30m vs C3",  "Bearish SMT on 30m vs Comparison 3")
alertcondition(bull_1h_1,  "Bullish SMT 1h vs C1",   "Bullish SMT on 1h vs Comparison 1")
alertcondition(bear_1h_1,  "Bearish SMT 1h vs C1",   "Bearish SMT on 1h vs Comparison 1")
alertcondition(bull_1h_2,  "Bullish SMT 1h vs C2",   "Bullish SMT on 1h vs Comparison 2")
alertcondition(bear_1h_2,  "Bearish SMT 1h vs C2",   "Bearish SMT on 1h vs Comparison 2")
alertcondition(bull_1h_3,  "Bullish SMT 1h vs C3",   "Bullish SMT on 1h vs Comparison 3")
alertcondition(bear_1h_3,  "Bearish SMT 1h vs C3",   "Bearish SMT on 1h vs Comparison 3")
alertcondition(bull_4h_1,  "Bullish SMT 4h vs C1",   "Bullish SMT on 4h vs Comparison 1")
alertcondition(bear_4h_1,  "Bearish SMT 4h vs C1",   "Bearish SMT on 4h vs Comparison 1")
alertcondition(bull_4h_2,  "Bullish SMT 4h vs C2",   "Bullish SMT on 4h vs Comparison 2")
alertcondition(bear_4h_2,  "Bearish SMT 4h vs C2",   "Bearish SMT on 4h vs Comparison 2")
alertcondition(bull_4h_3,  "Bullish SMT 4h vs C3",   "Bullish SMT on 4h vs Comparison 3")
alertcondition(bear_4h_3,  "Bearish SMT 4h vs C3",   "Bearish SMT on 4h vs Comparison 3")
alertcondition(bull_D_1,   "Bullish SMT D vs C1",    "Bullish SMT on D vs Comparison 1")
alertcondition(bear_D_1,   "Bearish SMT D vs C1",    "Bearish SMT on D vs Comparison 1")
alertcondition(bull_D_2,   "Bullish SMT D vs C2",    "Bullish SMT on D vs Comparison 2")
alertcondition(bear_D_2,   "Bearish SMT D vs C2",    "Bearish SMT on D vs Comparison 2")
alertcondition(bull_D_3,   "Bullish SMT D vs C3",    "Bullish SMT on D vs Comparison 3")
alertcondition(bear_D_3,   "Bearish SMT D vs C3",    "Bearish SMT on D vs Comparison 3")
````
