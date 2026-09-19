<!-- tradingview-pine-id: PUB;b9f3bcde151044f49a61e56664ec25d0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pressure Release Confirmation Engine [PhenLabs]

Source: https://www.tradingview.com/script/jEfe7BLy-Pressure-Release-Confirmation-Engine-PhenLabs/

## Description

📊 Pressure Release Confirmation Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
Pressure Release Confirmation Engine waits for trend-pressure to print a real extreme, then it does nothing until that pressure releases back through a hysteresis band on a closed bar. That release is the trade decision: fade a divergent extreme, or (optionally) take an aligned capitulation/extension release.

It is built for the exhaustion / trend-pressure workflow traders are actually using right now — without another locked-in oscillator recipe and without a Premium data gate. Use the built-in Range Position Pressure, or point Source at any plot you already trust (RSI, MACD, WaveTrend, a paid oscillator). Same arm → release → divergence gate either way. Markers print on price from this pane script, alerts fire both directions, and two numeric plots are Pine Screener columns.

🚀 Points of Innovation

[*]Discrete release trigger, not a paint-the-trend oscillator. Nothing fires at the extreme. The signal is the closed-bar hysteresis cross that ends the extreme.
[*]Any-source engine via input.source — run the same gate on built-in pressure or on an oscillator you already have on the chart.
[*]Divergence quality at the trigger, not as a second indicator. DIVERGENT = price refused to confirm the pressure extreme (higher-low / lower-high). ALIGNED = price confirmed it.
[*]One live arm at a time, timeout expiry, no same-bar arm-and-release, no dual-direction fire.
[*]Pane oscillator plus force_overlay price markers from a single script — no second indicator to add.
[*]Full value on every TradingView plan. No footprint, no tick chart, no lower-timeframe request as a requirement.
[*]Pine Screener columns (PRCE Signal, PRCE State) plus four alertconditions.

🔧 Core Components

[*]Range Position Pressure: close located inside the N-bar high/low, EMA-smoothed to 0–100. External mode replaces this with your selected plot (optionally min-max normalized so 80/20 still mean something).
[*]Extreme arm: pressure must be the lookback highest/lowest and through Overbought/Oversold. The engine stores the arm-bar high or low as the price-confirmation reference.
[*]Hysteresis release: bullish cross of Oversold+Hysteresis, bearish cross of Overbought−Hysteresis, evaluated only on barstate.isconfirmed.
[*]Quality gate: while armed, a new price low (bull) or new price high (bear) marks ALIGNED. No new extreme marks DIVERGENT. Default markers show divergent releases only.
[*]Dashboard: source mode, pressure, phase, quality, bars armed, last signal, screener codes.

🔥 Key Features

[*]Built-in and External source modes with progressive disclosure (dependent inputs stay inactive until External is selected).
[*]Readable defaults: divergent triangles only, arm dots off, short dashboard, no extra labels on price.
[*]Timeout so stale arms die instead of lingering into the next swing.
[*]Named alerts for divergent-only and any-release, both directions, plus alert() on the close.
[*]Screener-ready numeric plots hidden from the pane (data window / screener only).
[*]Armed-state background and dashed/dotted level plots so the hysteresis band is visible.

🎨 Visualization

[*]Pressure line (pane): colored by live arm. Green = bull arm, red = bear arm, gray = idle.
[*]Dashed Overbought/Oversold, dotted mid-line and release levels.
[*]Green triangle below the bar = bullish divergent release (force_overlay on price).
[*]Red triangle above the bar = bearish divergent release.
[*]Optional tiny circles = aligned releases (off unless Price Markers = All releases).
[*]Top-right dashboard: Source, Phase, Quality, Bars Armed, Last Signal, Screener codes. Hover any value cell for the definition.

📖 Usage Guidelines

[*]Pressure Source — Default: Built-in Pressure — Built-in uses this chart. External applies the identical gate to another indicator’s plot.
[*]External Plot — Default: close — Active only in External mode. Add your oscillator first, then pick its plot here.
[*]Normalize External to 0–100 — Default: true — Leave on for MACD, delta, unbounded sources. Off if the source is already 0–100 (RSI, Stochastic, %R flipped).
[*]Pressure Length — Default: 14 — Range: 3–100 — Lookback of built-in range-position pressure.
[*]Pressure Smooth — Default: 3 — Range: 1–30 — EMA on the raw pressure series (both modes).
[*]Extreme Lookback — Default: 10 — Range: 3–50 — Highest/lowest test that qualifies an arm.
[*]Overbought / Oversold — Default: 80 / 20 — Arm thresholds.
[*]Hysteresis — Default: 10 — Range: 1–25 — Release band. Bull fires on a close-bar cross of 30 with defaults; bear on a cross of 70.
[*]Arm Timeout — Default: 25 bars — Armed extremes that never release expire with no signal.
[*]Price Markers — Default: Divergent only — Divergent only / All releases / Hide shapes.
[*]Show Arm Markers — Default: false — Tiny pane dots at the arm bar.
[*]Table Size — Default: Small — Tiny / Small / Normal / Large.

✅ Best Use Cases

[*]Intraday and swing fade of exhausted pressure on indices, FX, gold, and crypto — the engine is asset-agnostic.
[*]Traders who already have a favorite oscillator and want a closed-bar trigger instead of reading slope by eye.
[*]Screening a watchlist for PRCE Signal = 2 (divergent bull) or −2 (divergent bear) on the Pine Screener.
[*]Pairing Built-in Pressure with a higher-timeframe chart for swing, then dropping External Source onto an RSI/MACD on the execution timeframe.

⚠️ Limitations

[*]This is a confirmation engine, not a full system. It does not size positions or place stops. Use your own invalidation (arm-bar extreme is the natural reference).
[*]External mode is only as honest as the plot you feed it. If that plot repaints, PRCE will inherit it. Built-in pressure does not.
[*]Hysteresis will miss V-reversals that never cross the release level before timeout. That is intentional.
[*]One live arm. A new opposite extreme cancels the previous arm.
[*]Not financial advice. Past pressure releases do not guarantee future results.

💡 What Makes This Unique

[*]The product is the release gate, not a new oscillator brand. Removing the arm → hysteresis → divergence sequence removes every signal.
[*]Works as a standalone pane tool and as a meta-tool on any other plot, without a Premium data dependency.
[*]Default chart shows only the higher-quality divergent events, so the picture stays readable.

⚙️ Under the Hood

[*]input.source(): the same extreme/release/divergence state machine can run on close-derived Range Position Pressure or on any other script’s plot. That is the core method — not a decorative source picker. Built-in mode is the default so the script is complete on a blank chart.
[*]input.enum + active: External Plot and Normalize stay inactive until Source = External. Progressive disclosure, not a 40-input wall.
[*]force_overlay on plotshape: a pane oscillator that still marks the price candle from one script. Solves the “add two indicators” friction.
[*]plot() linestyle: dashed thresholds and dotted release/mid levels with zero drawing-object budget.
[*]Closed-bar gate: ta.crossover / ta.crossunder and all arm/release mutations sit behind barstate.isconfirmed. Historical and realtime agree. No lookahead.
[*]Data mode / plan note: no plan-gated APIs. Dashboard row Source = BUILT-IN or EXTERNAL is the only mode flag, and both modes are available on every plan.
[*]Screener & alerts: PRCE Signal (2 divergent bull, 1 aligned bull, −1 aligned bear, −2 divergent bear) and PRCE State (1 armed bull, −1 armed bear, 0 idle) are data-window plots. alertcondition exists for divergent and any-release, both directions.

🔬 How It Works

[*]Pressure is computed (or ingested) onto a 0–100 scale and smoothed. Overbought/Oversold are the arm lines; hysteresis sits inside them as the release line.
[*]On a confirmed bar, if pressure is the lookback extreme and through the arm line, the engine stores that bar’s low (bull) or high (bear) and waits. Opposite arms cancel each other.
[*]While armed, any new price low/high versus the arm reference flips quality from DIVERGENT to ALIGNED. If the hysteresis line is not crossed before timeout, the arm expires silent.
[*]A closed-bar crossover of Oversold+Hysteresis (bull) or crossunder of Overbought−Hysteresis (bear) consumes the arm and emits the signal, quality tag, price marker (if enabled), screener value, and alerts.
[*]Read the dashboard: Phase tells you whether to wait or act; Quality tells you whether price confirmed the extreme; Source tells you which series the gate is running on.

💡 Note:
Add the script, leave defaults, and wait for a triangle. Hover the dashboard cells the first time — they are the legend. For External mode, add your oscillator first, switch Pressure Source, pick its plot, and keep Normalize on unless that plot is already 0–100. Alerts: use “PRCE Bull/Bear Divergent Release” unless you explicitly want aligned events. Screener: filter PRCE Signal = 2 or −2.

This is an analytical aid, not financial advice. You are responsible for risk, execution, and whether a release is worth taking in the current market.

---

## Source Code

````pine
//@version=6
indicator(
     title              = "Pressure Release Confirmation Engine [PhenLabs]",
     shorttitle         = "PRCE",
     overlay            = false,
     max_labels_count   = 50,
     max_lines_count    = 20,
     max_bars_back      = 500)

// ─────────────────────────────────────────────────────────────────────────────
// Pressure Release Confirmation Engine [PhenLabs]
// Closed-bar extreme → hysteresis release → divergence quality gate.
// Built-in range-position pressure, or any external plot via input.source.
// All-plan. No request.*. No lookahead. Signals fire only on barstate.isconfirmed.
// ─────────────────────────────────────────────────────────────────────────────

enum SrcMode
    BuiltIn  = "Built-in Pressure"
    External = "External Source"

enum SigMode
    DivOnly = "Divergent only"
    AllRel  = "All releases"
    Hidden  = "Hide shapes"

enum TblSize
    Tiny   = "Tiny"
    Small  = "Small"
    Normal = "Normal"
    Large  = "Large"

// ── Inputs ──────────────────────────────────────────────────────────────────
grpSrc = "Source"
grpPrs = "Pressure"
grpSig = "Signals"
grpVis = "Visuals"
grpTbl = "Dashboard"

SrcMode srcMode = input.enum(SrcMode.BuiltIn, "Pressure Source",
     tooltip = "Built-in Range Position Pressure runs on this chart with no extra indicators. External Source applies the same extreme/release/divergence gate to any plotted series you already have on the chart (RSI, MACD, WaveTrend, etc.).",
     group   = grpSrc)

float extSrc = input.source(close, "External Plot",
     tooltip = "Pick a plot from another indicator. Ignored unless Pressure Source = External Source.",
     group   = grpSrc,
     active  = srcMode == SrcMode.External)

bool normalizeExt = input.bool(true, "Normalize External to 0–100",
     tooltip = "Rescales the selected plot to 0–100 over a rolling window so the Overbought/Oversold levels still apply. Leave ON for unbounded sources (MACD, raw delta). Turn OFF for oscillators that are already 0–100.",
     group   = grpSrc,
     active  = srcMode == SrcMode.External)

int normWin = input.int(100, "Normalize Window", minval = 20, maxval = 500,
     tooltip = "Lookback used to min-max rescale an external source.",
     group   = grpSrc,
     active  = srcMode == SrcMode.External and normalizeExt)

int prLen = input.int(14, "Pressure Length", minval = 3, maxval = 100,
     tooltip = "Lookback of the built-in range-position pressure (close inside the N-bar high/low).",
     group   = grpPrs)

int prSmooth = input.int(3, "Pressure Smooth", minval = 1, maxval = 30,
     tooltip = "EMA smoothing applied to range-position pressure. External sources are smoothed by this too.",
     group   = grpPrs)

int extLook = input.int(10, "Extreme Lookback", minval = 3, maxval = 50,
     tooltip = "A bar is an extreme only when pressure is the highest/lowest of this many bars.",
     group   = grpPrs)

float obLevel = input.float(80.0, "Overbought", minval = 55.0, maxval = 99.0, step = 0.5,
     group = grpPrs)
float osLevel = input.float(20.0, "Oversold",   minval = 1.0,  maxval = 45.0, step = 0.5,
     group = grpPrs)
float hyst    = input.float(10.0, "Hysteresis", minval = 1.0,  maxval = 25.0, step = 0.5,
     tooltip = "Release fires on a closed-bar cross of Oversold+Hysteresis (bull) or Overbought−Hysteresis (bear). Stops the engine from re-firing while pressure is still pinned at the extreme.",
     group   = grpPrs)

int timeout = input.int(25, "Arm Timeout (bars)", minval = 3, maxval = 100,
     tooltip = "Armed extremes that never release are expired with no signal.",
     group   = grpSig)

SigMode sigMode = input.enum(SigMode.DivOnly, "Price Markers",
     tooltip = "Divergent only: plot a price-chart marker when pressure releases AND price refused to confirm the extreme (higher-low / lower-high). All releases: also plot aligned capitulation/extension releases. Hide shapes: dashboard + alerts only.",
     group   = grpSig)

bool showArmMarks = input.bool(false, "Show Arm Markers",
     tooltip = "Small pane dots when an extreme is armed. Off by default to keep the oscillator readable.",
     group   = grpSig)

bool showDash = input.bool(true, "Show Dashboard", group = grpTbl)
TblSize tblEnum = input.enum(TblSize.Small, "Table Size", group = grpTbl)

color bullCol = input.color(#00E5A0, "Bull", inline = "cols", group = grpVis)
color bearCol = input.color(#FF3B6B, "Bear", inline = "cols", group = grpVis)
color midCol  = input.color(#8B8FA3, "Mid / Levels", group = grpVis)
bool  showFill = input.bool(true, "Armed Background", group = grpVis)

// ── Pressure series ─────────────────────────────────────────────────────────
float hh = ta.highest(high, prLen)
float ll = ta.lowest(low, prLen)
float rng = hh - ll
float rawBuilt = rng <= 0 ? 50.0 : 100.0 * (close - ll) / rng

float rawExt = extSrc
if srcMode == SrcMode.External and normalizeExt
    float eHi = ta.highest(extSrc, normWin)
    float eLo = ta.lowest(extSrc, normWin)
    float eRng = eHi - eLo
    rawExt := eRng <= 0 or na(eRng) ? 50.0 : 100.0 * (extSrc - eLo) / eRng

float rawPress = srcMode == SrcMode.External ? rawExt : rawBuilt
float press    = ta.ema(rawPress, prSmooth)

float obRel = obLevel - hyst
float osRel = osLevel + hyst

bool bullCross = ta.crossover(press, osRel)
bool bearCross = ta.crossunder(press, obRel)
bool isBullExt = ta.lowestbars(press, extLook) == 0
bool isBearExt = ta.highestbars(press, extLook) == 0

bool ready = bar_index > math.max(prLen, extLook, prSmooth) + 5 and not na(press)

// ── Persistent arm state (global mutations only) ────────────────────────────
var bool  bullArmed      = false
var bool  bearArmed      = false
var int   bullArmBar     = na
var int   bearArmBar     = na
var float bullArmPx      = na
var float bearArmPx      = na
var bool  bullMadeNewLow = false
var bool  bearMadeNewHigh = false

var bool  bullSig        = false
var bool  bearSig        = false
var bool  bullDivQ       = false
var bool  bearDivQ       = false
var int   lastSigDir     = 0
var int   lastSigBar     = na
var bool  lastSigDiv     = false

bool justBullArm = false
bool justBearArm = false
bullSig := false
bearSig := false

if barstate.isconfirmed and ready
    // 1. Track confirmation of the price extreme while armed (skip the arm bar).
    if bullArmed and not justBullArm and low < bullArmPx
        bullMadeNewLow := true
    if bearArmed and not justBearArm and high > bearArmPx
        bearMadeNewHigh := true

    // 2. Release has priority over timeout so a last-bar cross still fires.
    if bullArmed and not justBullArm and bullCross
        bullSig        := true
        bullDivQ       := not bullMadeNewLow
        lastSigDir     := 1
        lastSigBar     := bar_index
        lastSigDiv     := bullDivQ
        bullArmed      := false
        bullArmBar     := na
        bullArmPx      := na
        bullMadeNewLow := false
    else if bullArmed and not na(bullArmBar) and (bar_index - bullArmBar) >= timeout
        bullArmed      := false
        bullArmBar     := na
        bullArmPx      := na
        bullMadeNewLow := false

    if bearArmed and not justBearArm and bearCross
        bearSig         := true
        bearDivQ        := not bearMadeNewHigh
        lastSigDir      := -1
        lastSigBar      := bar_index
        lastSigDiv      := bearDivQ
        bearArmed       := false
        bearArmBar      := na
        bearArmPx       := na
        bearMadeNewHigh := false
    else if bearArmed and not na(bearArmBar) and (bar_index - bearArmBar) >= timeout
        bearArmed       := false
        bearArmBar      := na
        bearArmPx       := na
        bearMadeNewHigh := false

    // 3. Dual-signal guard: a bar may not arm both sides. Most recent extreme wins.
    bool wantBullArm = not bullSig and isBullExt and press <= osLevel and press < nz(press[1], press)
    bool wantBearArm = not bearSig and isBearExt and press >= obLevel and press > nz(press[1], press)

    if wantBullArm and wantBearArm
        if press <= osLevel and (50.0 - press) >= (press - 50.0)
            wantBearArm := false
        else
            wantBullArm := false

    if wantBullArm
        bullArmed      := true
        bullArmBar     := bar_index
        bullArmPx      := low
        bullMadeNewLow := false
        justBullArm    := true
        // Opposite side yields — one live arm only.
        bearArmed       := false
        bearArmBar      := na
        bearArmPx       := na
        bearMadeNewHigh := false

    if wantBearArm
        bearArmed       := true
        bearArmBar      := bar_index
        bearArmPx       := high
        bearMadeNewHigh := false
        justBearArm     := true
        bullArmed       := false
        bullArmBar      := na
        bullArmPx       := na
        bullMadeNewLow  := false

// ── Visual gates ────────────────────────────────────────────────────────────
bool showDiv  = sigMode != SigMode.Hidden
bool showAln  = sigMode == SigMode.AllRel
bool bullDivMk = bullSig and bullDivQ and showDiv
bool bearDivMk = bearSig and bearDivQ and showDiv
bool bullAlnMk = bullSig and not bullDivQ and showAln
bool bearAlnMk = bearSig and not bearDivQ and showAln

// Pane oscillator
plot(press, "Pressure", color = bullArmed ? bullCol : bearArmed ? bearCol : midCol, linewidth = 2)
plot(obLevel, "Overbought", color = color.new(bearCol, 40), linestyle = plot.linestyle_dashed)
plot(osLevel, "Oversold",   color = color.new(bullCol, 40), linestyle = plot.linestyle_dashed)
plot(50.0,    "Mid",        color = color.new(midCol,  50), linestyle = plot.linestyle_dotted)
plot(obRel,   "Bear Release", color = color.new(bearCol, 70), linestyle = plot.linestyle_dotted)
plot(osRel,   "Bull Release", color = color.new(bullCol, 70), linestyle = plot.linestyle_dotted)

bandTop = press > 50 ? press : 50.0
bandBot = press < 50 ? press : 50.0
pFillHi = plot(showFill ? bandTop : na, display = display.none)
pFillLo = plot(showFill ? bandBot : na, display = display.none)
fill(pFillHi, pFillLo, color = press >= 50 ? color.new(bullCol, 88) : color.new(bearCol, 88), title = "Pressure Fill")

bgcolor(showFill and bullArmed ? color.new(bullCol, 92) : showFill and bearArmed ? color.new(bearCol, 92) : na, title = "Armed Background")

// Pane arm dots (secondary — off by default). location.absolute uses pressure as Y.
plotshape(showArmMarks and justBullArm ? press : na, title = "Bull Arm", style = shape.circle, location = location.absolute, color = color.new(bullCol, 20), size = size.tiny)
plotshape(showArmMarks and justBearArm ? press : na, title = "Bear Arm", style = shape.circle, location = location.absolute, color = color.new(bearCol, 20), size = size.tiny)

// Price-chart markers (force_overlay so a pane script still marks the candle)
plotshape(bullDivMk, title = "Bull Divergent Release", style = shape.triangleup,   location = location.belowbar, color = bullCol, size = size.small, force_overlay = true)
plotshape(bearDivMk, title = "Bear Divergent Release", style = shape.triangledown, location = location.abovebar, color = bearCol, size = size.small, force_overlay = true)
plotshape(bullAlnMk, title = "Bull Aligned Release",   style = shape.circle,       location = location.belowbar, color = color.new(bullCol, 30), size = size.tiny, force_overlay = true)
plotshape(bearAlnMk, title = "Bear Aligned Release",   style = shape.circle,       location = location.abovebar, color = color.new(bearCol, 30), size = size.tiny, force_overlay = true)

// Screener columns (last-bar numeric state)
float sigCol = bullSig ? (bullDivQ ? 2.0 : 1.0) : bearSig ? (bearDivQ ? -2.0 : -1.0) : 0.0
float stCol  = bullArmed ? 1.0 : bearArmed ? -1.0 : 0.0
plot(sigCol, "PRCE Signal", display = display.data_window)
plot(stCol,  "PRCE State",  display = display.data_window)

// ── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(bullSig and bullDivQ,  title = "PRCE Bull Divergent Release", message = "PRCE: Bullish divergent pressure release [𓄀]")
alertcondition(bearSig and bearDivQ,  title = "PRCE Bear Divergent Release", message = "PRCE: Bearish divergent pressure release [𓄀]")
alertcondition(bullSig,               title = "PRCE Any Bull Release",       message = "PRCE: Bullish pressure release [𓄀]")
alertcondition(bearSig,               title = "PRCE Any Bear Release",       message = "PRCE: Bearish pressure release [𓄀]")

if barstate.isconfirmed and bullSig
    alert("PRCE BULL " + (bullDivQ ? "DIVERGENT" : "ALIGNED") + " release @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if barstate.isconfirmed and bearSig
    alert("PRCE BEAR " + (bearDivQ ? "DIVERGENT" : "ALIGNED") + " release @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// ── Dashboard ───────────────────────────────────────────────────────────────
string tblSz = tblEnum == TblSize.Tiny ? size.tiny : tblEnum == TblSize.Small ? size.small : tblEnum == TblSize.Normal ? size.normal : size.large

var table dash = table.new(position.top_right, 2, 8, bgcolor = color.new(#131722, 8), frame_color = color.new(midCol, 40), frame_width = 1, border_width = 1)

f_cell(int r, string a, string b, color vc, string tip) =>
    table.cell(dash, 0, r, a, text_color = color.new(#D1D4DC, 20), text_size = tblSz, text_halign = text.align_left,  bgcolor = color.new(#131722, 8))
    table.cell(dash, 1, r, b, text_color = vc,                     text_size = tblSz, text_halign = text.align_right, bgcolor = color.new(#131722, 8), text_formatting = text.format_bold, tooltip = tip)

if showDash and barstate.islast
    table.clear(dash, 0, 0, 1, 7)
    string srcTxt = srcMode == SrcMode.External ? "EXTERNAL" : "BUILT-IN"
    string phTxt  = bullArmed ? "ARMED BULL" : bearArmed ? "ARMED BEAR" : bullSig ? "BULL RELEASE" : bearSig ? "BEAR RELEASE" : "IDLE"
    color  phCol  = bullArmed or bullSig ? bullCol : bearArmed or bearSig ? bearCol : midCol
    string qTxt   = bullArmed ? (bullMadeNewLow ? "ALIGNED" : "DIVERGENT") : bearArmed ? (bearMadeNewHigh ? "ALIGNED" : "DIVERGENT") : lastSigDir != 0 ? (lastSigDiv ? "LAST: DIV" : "LAST: ALN") : "—"
    int    held   = bullArmed and not na(bullArmBar) ? bar_index - bullArmBar : bearArmed and not na(bearArmBar) ? bar_index - bearArmBar : 0
    string lastTxt = lastSigDir == 0 or na(lastSigBar) ? "—" : (lastSigDir > 0 ? "BULL " : "BEAR ") + (lastSigDiv ? "DIV" : "ALN") + " " + str.tostring(bar_index - lastSigBar) + "b"
    f_cell(0, "PRCE",          "𓄀",  midCol,  "Pressure Release Confirmation Engine. Extreme of the selected pressure series is armed; a signal fires only when that pressure releases through the hysteresis band on a closed bar.")
    f_cell(1, "Source",        srcTxt,      srcMode == SrcMode.External ? color.aqua : midCol, "BUILT-IN = range-position pressure from this chart. EXTERNAL = the plot chosen in settings. Full value on every plan — no footprint / LTF / tick gate.")
    f_cell(2, "Pressure",      str.tostring(press, "#.0"), press >= obLevel ? bearCol : press <= osLevel ? bullCol : midCol, "0–100 pressure. Overbought " + str.tostring(obLevel, "#") + " / Oversold " + str.tostring(osLevel, "#") + ".")
    f_cell(3, "Phase",         phTxt,       phCol,   "IDLE = nothing armed. ARMED = waiting for a closed-bar hysteresis cross. RELEASE = the discrete trigger that just printed.")
    f_cell(4, "Quality",       qTxt,        qTxt == "DIVERGENT" or qTxt == "LAST: DIV" ? bullCol : qTxt == "ALIGNED" or qTxt == "LAST: ALN" ? bearCol : midCol, "DIVERGENT = price refused to confirm the pressure extreme (higher-low / lower-high) — default marker. ALIGNED = price confirmed the extreme.")
    f_cell(5, "Bars Armed",    str.tostring(held), midCol, "Bars since the live extreme was armed. Expires at " + str.tostring(timeout) + " with no signal.")
    f_cell(6, "Last Signal",   lastTxt,     lastSigDir > 0 ? bullCol : lastSigDir < 0 ? bearCol : midCol, "Most recent closed-bar release.")
    f_cell(7, "Screener",      "Sig " + str.tostring(sigCol, "#") + " / St " + str.tostring(stCol, "#"), midCol, "Pine Screener columns: PRCE Signal (2 div-bull, 1 aln-bull, -1 aln-bear, -2 div-bear) and PRCE State (1 armed-bull, -1 armed-bear, 0 idle).")
else if barstate.islast
    table.clear(dash, 0, 0, 1, 7)
````
