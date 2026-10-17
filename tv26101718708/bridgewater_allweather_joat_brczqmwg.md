# Bridgewater All-Weather [JOAT]

- url: https://www.tradingview.com/script/bRczQMwg-Bridgewater-All-Weather-JOAT/
- type: indicator
- pine_id: PUB;9e4d363c98a74794b86e0aac4392c2d7
- version: 1.0

## Description

[b]BRIDGEWATER ALL-WEATHER [JOAT][/b]

A tribute to Ray Dalio's [i]All-Weather[/i] framework — the macro-regime engine that classifies the current environment along [b]two orthogonal axes[/b]: [i]growth[/i] (rising or falling) and [i]inflation/volatility[/i] (rising or falling) — and maps the resulting quadrant to the asset class that historically performs best in that regime. Bridgewater All-Weather distils that idea into a Pine script: a quadrant classifier built on Z-scored growth and volatility proxies, a 2×2 mini-chart rendered on the chart itself, a regime-tinted background, a rotation-event label, and a Suggested-JOAT-Indicator row that names the best companion script for the current quadrant.

[image]https://www.tradingview.com/x/mEb35mY9/[/image]

[b]The four quadrants[/b]

[list]
[*] [b]Q1 — Growth UP, Vol DOWN[/b] — Risk-On / Equities regime. Blue.
[*] [b]Q2 — Growth UP, Vol UP[/b] — Inflation / Commodities regime. Gold.
[*] [b]Q3 — Growth DOWN, Vol DOWN[/b] — Disinflation / Bonds regime. Sage.
[*] [b]Q4 — Growth DOWN, Vol UP[/b] — Crisis / Gold regime. Pink.
[/list]

The asset-class analogues are Dalio's institutional defaults; they can be toggled off if you want pure regime classification without the asset overlay.

[b]Growth and Vol proxies[/b]

Macro frameworks need macro inputs. The script approximates the two factors purely from chart data so it runs on any instrument:

[list]
[*] [b]Growth proxy[/b] — long-window smoothed return (default 100-bar EMA-smoothed return). Z-scored against a long baseline (default 252 bars, the trading-year canonical).
[*] [b]Volatility proxy[/b] — rolling standard deviation of returns over the volatility window (default 100 bars). Z-scored against the same baseline.
[/list]

A configurable [b]Z dead-zone[/b] (default ±0.10) treats small Z values as neutral and refuses to register quadrant changes until the Z moves clearly off zero. This eliminates flicker between adjacent quadrants when the signal is genuinely uncertain.

[b]Minimum-bars-hold filter[/b]

A quadrant must persist for at least [b]N bars[/b] (default 3) before a rotation is committed. This prevents whipsaw classification when growth and volatility cross their respective zero lines on the same bar.

[b]Mini 2D quadrant chart[/b]

The script's signature visual: a 2×2 grid rendered directly on the chart (anchored to any of four corners, with configurable cell size in bars and price-height in ATR units). The currently-active quadrant is highlighted in its quadrant colour; the other three are muted. At a glance you see the entire four-state regime classification mapped to its asset analogue. The four hues appear simultaneously [i]only[/i] in the mini chart — by design — because elsewhere the script obeys strict one-active-quadrant colour discipline.

[b]Visual system[/b]

[list]
[*] [b]Background tint by active quadrant[/b] (configurable transparency, default 92 institutional-subtle).
[*] [b]Quadrant badge[/b] — right-side floating label showing the active quadrant with its colour. Configurable corner.
[*] [b]Rotation label[/b] — drops a label on the chart every time the quadrant changes.
[*] [b]Mini 2D quadrant chart[/b] (the signature) — 2×2 grid in the chosen corner.
[*] [b]Hidden growth-Z and vol-Z line plots[/b] — for users who want to see the underlying scores in the Data Window or feed them to alerts. Off by default.
[/list]

A locked Sapphire palette: one hue per quadrant (Q1 blue, Q2 gold, Q3 sage, Q4 pink). Because only one quadrant is active at a time, the chart only ever shows one family + the muted background. The strict 4-hue discipline only appears in the mini chart.

[image]https://www.tradingview.com/x/sONA7Xcn/[/image]

[b]Suggested JOAT Indicator row[/b]

The dashboard exposes a [b]Suggested Indicator[/b] row that names the best-fit companion from the JOAT suite per quadrant. Defaults:

[list]
[*] Q1 (risk-on) → [i]Quantum Trend Matrix[/i] (trend amplification in a benign environment).
[*] Q2 (inflation) → [i]Liquid Reversal Engine[/i] (mean-reversion bands in a volatile-up regime).
[*] Q3 (disinflation) → [i]Smart SR Zones[/i] (structure-focused reads in a calming environment).
[*] Q4 (crisis) → [i]Z-Score Flow Pro[/i] (extreme-statistics regime for risk-off conditions).
[/list]

Every suggestion is user-configurable.

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, with optional row-gradient. Surfaces:

[list]
[*] Active quadrant with asset analogue.
[*] Growth Z value and direction.
[*] Vol Z value and direction.
[*] Bars in current quadrant.
[*] Last rotation: from → to with bars-ago.
[*] Suggested JOAT Indicator (toggleable).
[/list]

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] Any Quadrant Rotation
[*] Entered Q4 (Risk-Off / Crisis) — the most actionable single alert; usually accompanies risk-off moves across asset classes.
[*] Entered Q1 (Risk-On) — off by default; useful for trend-following entry timing.
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Q4 entry[/b] — the highest-priority macro alert. Growth is falling and volatility is rising — historically the regime in which risk assets sell off, gold rallies, and defensive positioning wins. Reduce risk exposure regardless of the chart-timeframe signal.
[*] [b]Sustained Q1[/b] — the trend amplifier. The market is in a healthy growth/calm environment; momentum tools have their largest edge. The mini chart visually confirms the regime.
[*] [b]Rotation between adjacent quadrants[/b] (e.g. Q1 → Q2 or Q3 → Q4) — regime-transition warning. The market is rotating along one of the two axes; this often precedes the larger directional move.
[/list]

[b]Suggested settings[/b]

Defaults (growth 100 / vol 100 / baseline 252 / dead-zone 0.10 / 3-bar hold) are calibrated to daily charts on broad indices. For lower timeframes drop windows proportionally. For weekly+ raise to 200 / 200 / 500. The dead-zone is the single most important anti-flicker input; widen if your instrument has noisy growth/vol behaviour.

[b]Originality / what's reused[/b]

The [i]All-Weather[/i] framework is Ray Dalio / Bridgewater Associates' published macro philosophy — a public conceptual framework, not proprietary code. The implementation here — the chart-data-only growth and volatility proxies, the Z-baseline normalisation with dead-zone gate, the minimum-bars-hold rotation filter, the 2×2 mini-chart render in chart units with ATR-scaled cell height, the per-quadrant single-hue palette discipline, the suggested-JOAT-indicator dashboard row, and the rotation-event label engine — is JOAT-original. No third-party code reused. The script is a [i]tribute[/i], not a direct replication of any proprietary Bridgewater model.

[b]Limitations[/b]

The growth and volatility proxies are computed from chart data only — they are approximations, not the macroeconomic series an actual All-Weather portfolio uses. The Z-baseline assumes 252 bars approximates a trading year; on non-daily timeframes the interpretation shifts (e.g. on 1H, 252 bars is roughly 10 trading days). The quadrant classification is descriptive of recent chart behaviour, not of the broader macro environment — pair with macro context for serious portfolio decisions.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Bridgewater All-Weather [JOAT]", shorttitle="BW [JOAT]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================
grpCalc   = "+------- Regime Calculation -------+"
grpClass  = "+------- Classification -------+"
grpTheme  = "+------- Theme & Palette -------+"
grpVis    = "+------- Visuals -------+"
grpMini   = "+------- Mini Quadrant Chart -------+"
grpDash   = "+------- Dashboard -------+"
grpSugg   = "+------- Suggestion Engine -------+"
grpAlert  = "+------- Alerts -------+"

// --- Regime Calculation ------------------------------------------------------
int   growthWindow = input.int(100, "Growth Window (bars)",      minval=20,  maxval=500, group=grpCalc, tooltip="Long-window smoothed return used as the GROWTH proxy.  100 bars approximates a quarterly horizon on daily data.")
int   growthSmooth = input.int(20,  "Growth EMA Smoothing",       minval=1,   maxval=100, group=grpCalc, tooltip="EMA smoothing applied to the long-window return before normalisation.")
int   volWindow    = input.int(100, "Volatility Window (bars)",  minval=20,  maxval=500, group=grpCalc, tooltip="Rolling standard deviation window for the VOLATILITY proxy.  Use the same length as the growth window for consistency.")
int   zWindow      = input.int(252, "Z-Score Baseline (bars)",   minval=50,  maxval=1000, group=grpCalc, tooltip="Long baseline for Z-scoring growth and volatility.  252 bars approximates one year of daily data.")
float zDeadzone    = input.float(0.10, "Z Dead-Zone",            minval=0.0, maxval=0.5, step=0.01, group=grpCalc, tooltip="Z values inside +/- this threshold are treated as neutral and won't trigger quadrant changes.  Reduces flicker.")
int   minBarsHold  = input.int(3, "Min Bars Before Rotation",    minval=1,   maxval=50,   group=grpCalc, tooltip="Minimum bars a quadrant must persist before a new rotation can register.  Prevents whipsaw classification.")

// --- Classification labels (immutable, define once) --------------------------
bool useAssetAnalog = input.bool(true,  "Show Asset-Class Analog", group=grpClass)

// --- Visuals -----------------------------------------------------------------
bool showBgTint     = input.bool(true,  "Background Tint by Quadrant", group=grpVis)
int  bgTransparency = input.int(92,     "BG Transparency",      minval=70, maxval=99, group=grpVis, tooltip="Higher = more subtle.  Default 92 keeps the tint barely visible so candles stay readable.")
bool showBadge      = input.bool(true,  "Show Quadrant Badge",  group=grpVis)
string badgePos     = input.string("Middle Right", "Badge Position", options=["Top Right","Middle Right","Bottom Right"], group=grpVis)
bool showRotation   = input.bool(true,  "Show Rotation Label",  group=grpVis, tooltip="Drops a label on the chart each time the quadrant changes.")
bool showScoreLine  = input.bool(false, "Plot Growth-Z Line (hidden by default)", group=grpVis)
bool showVolLine    = input.bool(false, "Plot Vol-Z Line (hidden by default)",    group=grpVis)

// --- Mini Quadrant Chart -----------------------------------------------------
bool showMini       = input.bool(true,  "Show Mini 2D Quadrant Chart", group=grpMini)
string miniAnchor   = input.string("Top Left", "Mini Chart Anchor", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpMini, tooltip="Selects which screen corner the 2x2 quadrant grid is anchored to.")
int  miniSize       = input.int(8, "Mini Chart Cell Size (bars)", minval=4, maxval=40, group=grpMini, tooltip="Width of each quadrant cell in bars.  Each cell is square (cellSize x cellSize price units, scaled to ATR).")
int  miniOffsetBars = input.int(20, "Mini Chart Offset (bars)",   minval=0, maxval=200, group=grpMini, tooltip="Horizontal offset from current bar.")
float miniHeightAtr = input.float(2.5, "Mini Chart Cell Height (ATR)", minval=0.5, maxval=10.0, step=0.1, group=grpMini, tooltip="Each cell's price-height in multiples of ATR(20).")

// --- Dashboard ---------------------------------------------------------------
bool showDash       = input.bool(true, "Show Dashboard", group=grpDash)
string dashPos      = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"], group=grpDash)
string dashSize     = input.string("Small", "Dashboard Text Size",   options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)
bool dashGradient   = input.bool(true, "Dashboard Row Gradient", group=grpDash, tooltip="Subtle vertical fade across dashboard rows for the premium institutional feel.")

// --- Suggestion --------------------------------------------------------------
bool useSugg        = input.bool(true, "Enable Suggested-JOAT Row", group=grpSugg, tooltip="Row 7 of the dashboard names the JOAT indicator best paired with the current regime.")
string suggQ1       = input.string("Quantum Trend Matrix [JOAT]",  "Q1 Suggested", group=grpSugg)
string suggQ2       = input.string("Liquid Reversal Engine [JOAT]", "Q2 Suggested", group=grpSugg)
string suggQ3       = input.string("Smart S/R Zones [JOAT]",        "Q3 Suggested", group=grpSugg)
string suggQ4       = input.string("Z-Score Flow Pro [JOAT]",       "Q4 Suggested", group=grpSugg)

// --- Alerts ------------------------------------------------------------------
bool alertOnRotation = input.bool(true,  "Alert: Any Quadrant Rotation", group=grpAlert)
bool alertOnQ4       = input.bool(true,  "Alert: Entered Q4 (Risk-Off)", group=grpAlert)
bool alertOnQ1       = input.bool(false, "Alert: Entered Q1 (Risk-On)",  group=grpAlert)

// =============================================================================
//  SECTION 2 - COLOR PALETTE  (Sapphire - 4 quadrant tints, locked)
// =============================================================================
//  Single curated palette. No theme switcher. Each quadrant owns ONE hue;
//  because only ONE quadrant is active at a time the chart only ever shows
//  ONE family + the muted bg. The 4 hues appear simultaneously ONLY in the
//  mini 2D quadrant chart - by design (that IS its purpose).
//    Q1 (equities)        -> blue   #1E90FF
//    Q2 (commodities)     -> gold   #FFD700
//    Q3 (bonds)           -> sage   #8FBC8F
//    Q4 (gold / risk-off) -> pink   #FF69B4

const color Q1_COL  = #1E90FF
const color Q2_COL  = #FFD700
const color Q3_COL  = #8FBC8F
const color Q4_COL  = #FF69B4

const color C_BULL  = Q1_COL          // legacy alias - resolves to active-q semantics via quadrantBase
const color C_BEAR  = Q4_COL
const color C_NEUT  = Q2_COL
const color C_MID   = Q3_COL
const color C_BG    = #2C2C2C
const color C_FRAME = #1A1A1A
const color C_TEXT  = #E5E7EB
const color C_MUTED = #6B7280

// --- Quadrant Family Anchor Colors (one base hue per quadrant) --------------
quadrantBase(int q) =>
    color c = Q1_COL
    if q == 1
        c := Q1_COL
    else if q == 2
        c := Q2_COL
    else if q == 3
        c := Q3_COL
    else if q == 4
        c := Q4_COL
    c

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================
f_clamp(float x, float mn, float mx) => math.max(mn, math.min(x, mx))

// RGB linear-interpolation gradient between two colors at ratio in [0,1]
f_colorGradient(float ratio, color a, color b) =>
    rA = color.r(a), gA = color.g(a), bA = color.b(a)
    rB = color.r(b), gB = color.g(b), bB = color.b(b)
    r  = rA + int((rB - rA) * f_clamp(ratio, 0.0, 1.0))
    g  = gA + int((gB - gA) * f_clamp(ratio, 0.0, 1.0))
    bb = bA + int((bB - bA) * f_clamp(ratio, 0.0, 1.0))
    color.rgb(r, g, bb, 0)

// Position string -> position constant
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.top_right

// Size string -> size constant
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

// Dashboard row vertical gradient
grad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? minT : (minT + (maxT - minT) * (row / float(rows - 1)))
    color.new(base, int(t))

// Quadrant name
quadrantName(int q) =>
    string s = "Neutral"
    if q == 1
        s := "Q1 - Rising Growth, Low Vol"
    else if q == 2
        s := "Q2 - Rising Growth, High Vol"
    else if q == 3
        s := "Q3 - Falling Growth, Low Vol"
    else if q == 4
        s := "Q4 - Falling Growth, High Vol"
    s

// Short quadrant code (for tickers / labels)
quadrantCode(int q) =>
    string s = "--"
    if q == 1
        s := "Q1"
    else if q == 2
        s := "Q2"
    else if q == 3
        s := "Q3"
    else if q == 4
        s := "Q4"
    s

// Asset-class analog (Bridgewater style)
quadrantAsset(int q) =>
    string s = "Cash"
    if q == 1
        s := "Equities (risk-on)"
    else if q == 2
        s := "Commodities / Inflation hedges"
    else if q == 3
        s := "Long-Duration Bonds"
    else if q == 4
        s := "Gold / TIPS / Cash (risk-off)"
    s

// Suggested JOAT indicator per quadrant
quadrantSuggestion(int q) =>
    string s = "--"
    if q == 1
        s := suggQ1
    else if q == 2
        s := suggQ2
    else if q == 3
        s := suggQ3
    else if q == 4
        s := suggQ4
    s

// Format a number with sign and 2 decimals
fmtSigned(float v) =>
    string sign = v >= 0 ? "+" : ""
    sign + str.tostring(v, "0.00")

// Format integer with optional suffix
fmtBars(int b) =>
    str.tostring(b) + " bars"

// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
// =============================================================================
//  Growth proxy:
//     raw return over a long window  ->  smoothed via EMA  ->  expressed
//     as percent of current price for dimensional consistency.
//
//  Volatility proxy:
//     rolling stdev of 1-bar absolute returns over the same window.
//
//  Both Z-scored on a long baseline (default 252 bars).
// =============================================================================

// Guard windows against tiny series at the start of history
int gW = math.max(2, growthWindow)
int vW = math.max(2, volWindow)
int zW = math.max(5, zWindow)

// 1) GROWTH proxy: long-window return, smoothed, normalised by price
float windowReturn = close - close[gW]
float growthRaw    = ta.ema(windowReturn, growthSmooth)
float growth       = close != 0 ? growthRaw / close : 0.0

// 2) VOLATILITY proxy: rolling stdev of single-bar dollar returns
float dollarReturn = close - close[1]
float vol          = ta.stdev(dollarReturn, vW)

// 3) Z-scores on long baseline
float growthMean  = ta.sma(growth, zW)
float growthStdev = ta.stdev(growth, zW)
float volMean     = ta.sma(vol, zW)
float volStdev    = ta.stdev(vol, zW)

float growth_z = growthStdev > 0 ? (growth - growthMean) / growthStdev : 0.0
float vol_z    = volStdev    > 0 ? (vol    - volMean)    / volStdev    : 0.0

// Clamp Z values to a sane display range
growth_z := f_clamp(nz(growth_z, 0.0), -5.0, 5.0)
vol_z    := f_clamp(nz(vol_z,    0.0), -5.0, 5.0)

// Polar magnitude (distance from origin in 2D Z-space) - intensity proxy
float zMagnitude = math.sqrt(growth_z * growth_z + vol_z * vol_z)
float zMagNorm   = f_clamp(zMagnitude / 3.0, 0.0, 1.0)   // 3-sigma -> full

// =============================================================================
//  SECTION 5 - STATE / TRACKING
// =============================================================================
var int currentQuadrant   = 0       // 0 = uninitialised
var int previousQuadrant  = 0
var int quadrantStartBar  = 0
var int lastRotationBar   = 0
var int prevRotationBar   = 0       // 2nd-to-last rotation
var int rotationCount     = 0

// Short rolling history of the last 6 quadrants (most recent at end)
var array<int> rotationHist = array.new<int>()
int    rotHistCap = 6

// Long memory: per-bar quadrant series for analytics
var array<int> quadSeries = array.new<int>()
int   quadSeriesCap = 5000

// =============================================================================
//  SECTION 6 - CLASSIFICATION
// =============================================================================
//  A quadrant is assigned only when BOTH growth_z and vol_z escape the
//  +/- zDeadzone band. Otherwise we hold the previous classification.
// =============================================================================
classifyQuadrant(float gZ, float vZ, float dz, int hold) =>
    int q = hold
    bool gPos = gZ >  dz
    bool gNeg = gZ < -dz
    bool vPos = vZ >  dz
    bool vNeg = vZ < -dz
    bool resolved = (gPos or gNeg) and (vPos or vNeg)
    if resolved
        if gPos and vNeg
            q := 1
        else if gPos and vPos
            q := 2
        else if gNeg and vNeg
            q := 3
        else if gNeg and vPos
            q := 4
    q

int newQuadrant = classifyQuadrant(growth_z, vol_z, zDeadzone, currentQuadrant)

// Rotation guard: enforce minBarsHold before a change registers
bool rotated = false
if newQuadrant != currentQuadrant and newQuadrant != 0
    bool firstAssign = currentQuadrant == 0
    bool heldLong    = bar_index - quadrantStartBar >= minBarsHold
    if firstAssign or heldLong
        previousQuadrant := currentQuadrant
        currentQuadrant  := newQuadrant
        prevRotationBar  := lastRotationBar
        lastRotationBar  := bar_index
        if not firstAssign
            rotationCount += 1
            rotated := true
        quadrantStartBar := bar_index
        // append to rotation history
        rotationHist.push(currentQuadrant)
        if rotationHist.size() > rotHistCap
            rotationHist.shift()

// Append to long-memory series every bar (bounded)
if barstate.isconfirmed and currentQuadrant != 0
    quadSeries.push(currentQuadrant)
    if quadSeries.size() > quadSeriesCap
        quadSeries.shift()

// Derived: bars in current quadrant, bars since last rotation, rotation gap
int barsInQuadrant   = currentQuadrant == 0 ? 0 : bar_index - quadrantStartBar
int barsSinceRot     = lastRotationBar == 0 ? 0 : bar_index - lastRotationBar
int lastRotationGap  = lastRotationBar > prevRotationBar ? lastRotationBar - prevRotationBar : 0

// Build human-readable transition pattern (most recent first, max 6)
buildRotationString(array<int> hist) =>
    string out = ""
    int n = hist.size()
    if n == 0
        out := "-"
    else
        for i = 0 to n - 1
            int q = hist.get(i)
            string sep = (i == n - 1) ? "" : " -> "
            out += quadrantCode(q) + sep
    out

string rotationPattern = buildRotationString(rotationHist)

// Active quadrant color (used by EVERY visual layer to keep hue count <= 3)
color activeBase = currentQuadrant == 0 ? C_MUTED : quadrantBase(currentQuadrant)

// =============================================================================
//  SECTION 7 - PLOTS / FILLS / BG TINT
// =============================================================================
//  Background tint:
//   - tint family = the active quadrant's base color, very high transparency
//   - because only one quadrant is active, only one hue tints the chart
//   - magnitude modulates how strong the tint is within the chosen family
// =============================================================================
color bgTintColor = na
if showBgTint and currentQuadrant != 0
    int tintAlpha = int(f_clamp(bgTransparency - zMagNorm * 5.0, 80.0, 99.0))
    bgTintColor := color.new(activeBase, tintAlpha)

bgcolor(bgTintColor, title="Quadrant BG Tint")

// Optional hidden Z plots (useful for in-pane diagnostics / alerts)
plot(showScoreLine ? growth_z : na, title="Growth Z", color=color.new(activeBase, 30), linewidth=1)
plot(showVolLine   ? vol_z    : na, title="Vol Z",    color=color.new(activeBase, 30), linewidth=1, style=plot.style_circles)

// =============================================================================
//  SECTION 8 - DRAWINGS  (badge, rotation label, mini 2D quadrant chart)
// =============================================================================
//  Drawn one-shot on barstate.islast to stay under the 500-drawing cap.
//  Older instances are deleted and replaced rather than accumulating.
// =============================================================================

// --- Badge (right-side persistent label) ------------------------------------
var label badge = na

if showBadge and barstate.islast
    if not na(badge)
        label.delete(badge)
    // Y location based on badgePos selection (vertical region)
    float badgeY = close
    if badgePos == "Top Right"
        badgeY := high + ta.atr(20) * 3.0
    else if badgePos == "Bottom Right"
        badgeY := low  - ta.atr(20) * 3.0
    else
        badgeY := close
    string badgeText = currentQuadrant == 0 ? "BW [JOAT]\nNeutral" : "BW [JOAT]\n" + quadrantCode(currentQuadrant) + " | g " + fmtSigned(growth_z) + " | v " + fmtSigned(vol_z)
    color badgeBg = color.new(activeBase, 78)
    color badgeFg = C_TEXT
    badge := label.new(bar_index + 5, badgeY, badgeText, style=label.style_label_left, color=badgeBg, textcolor=badgeFg, size=size.small, textalign=text.align_left)

// --- Rotation label (drops once per rotation event) -------------------------
if showRotation and rotated
    string rotText = quadrantCode(previousQuadrant) + " -> " + quadrantCode(currentQuadrant)
    color  rotCol  = color.new(activeBase, 25)
    label.new(bar_index, low - ta.atr(20) * 1.2, rotText, style=label.style_label_up, color=rotCol, textcolor=C_TEXT, size=size.small)

// --- Mini 2D Quadrant Chart  ------------------------------------------------
//  4 boxes arranged in a 2x2 grid:
//        +----+----+
//        | Q1 | Q2 |   (top row = Growth UP)
//        +----+----+
//        | Q3 | Q4 |   (bottom row = Growth DN)
//        +----+----+
//        left = Vol DN,  right = Vol UP
//  Only the ACTIVE quadrant's box is filled in the family color. The other
//  three are rendered as outlines in C_MUTED -> total hue count stays <= 3.
//  A small "you are here" dot marks the current 2D Z-space position.
// =============================================================================
var array<box>   miniBoxes = array.new<box>()
var array<label> miniLabels = array.new<label>()
var label miniDot = na

clearMini() =>
    while miniBoxes.size() > 0
        box.delete(miniBoxes.shift())
    while miniLabels.size() > 0
        label.delete(miniLabels.shift())

// Draws one quadrant cell. Returns na. Defined at global scope (Pine v6).
drawMiniCell(int qIdx, int xL, float yT, int xR, float yB, int activeQ) =>
    bool active = qIdx == activeQ
    color baseCol = quadrantBase(qIdx)
    color border  = active ? color.new(baseCol, 0) : color.new(C_MUTED, 35)
    color fillCol = active ? color.new(baseCol, 55) : color.new(C_FRAME, 80)
    box b = box.new(xL, yT, xR, yB, border_color=border, border_width=active ? 2 : 1, bgcolor=fillCol)
    miniBoxes.push(b)
    string lbl = quadrantCode(qIdx)
    color  tc  = active ? C_TEXT : color.new(C_MUTED, 20)
    label cl = label.new(int((xL + xR) / 2.0), (yT + yB) / 2.0, lbl, style=label.style_none, textcolor=tc, size=size.small)
    miniLabels.push(cl)

if showMini and barstate.islast
    clearMini()
    if not na(miniDot)
        label.delete(miniDot)

    float atr20 = ta.atr(20)
    float cellH = atr20 * miniHeightAtr            // price units per cell
    int   cellW = math.max(2, miniSize)            // bars per cell
    int   anchorBar = bar_index + miniOffsetBars

    // determine grid bottom-left price + bar (depends on chosen anchor corner)
    float topY = high + atr20 * 6.0
    float botY = topY - 2.0 * cellH
    int   leftBar = anchorBar
    if miniAnchor == "Top Left"
        leftBar := bar_index - cellW * 3
        topY := high + atr20 * 6.0
        botY := topY - 2.0 * cellH
    else if miniAnchor == "Top Right"
        leftBar := anchorBar
        topY := high + atr20 * 6.0
        botY := topY - 2.0 * cellH
    else if miniAnchor == "Bottom Left"
        leftBar := bar_index - cellW * 3
        botY := low - atr20 * 6.0
        topY := botY + 2.0 * cellH
    else
        leftBar := anchorBar
        botY := low - atr20 * 6.0
        topY := botY + 2.0 * cellH

    int rightBar = leftBar + cellW * 2
    float midY   = (topY + botY) / 2.0
    int   midBar = leftBar + cellW

    // 4 cells - (Q index, left, top, right, bottom)
    // Q1 = top-left, Q2 = top-right, Q3 = bottom-left, Q4 = bottom-right
    drawMiniCell(1, leftBar, topY, midBar,   midY, currentQuadrant)
    drawMiniCell(2, midBar,  topY, rightBar, midY, currentQuadrant)
    drawMiniCell(3, leftBar, midY, midBar,   botY, currentQuadrant)
    drawMiniCell(4, midBar,  midY, rightBar, botY, currentQuadrant)

    // Axis labels (muted - they are reference, not a 3rd hue family)
    color axisCol = color.new(C_MUTED, 25)
    label axTop = label.new(leftBar - 1, (topY + midY) / 2.0, "G+", style=label.style_none, textcolor=axisCol, size=size.tiny)
    label axBot = label.new(leftBar - 1, (midY + botY) / 2.0, "G-", style=label.style_none, textcolor=axisCol, size=size.tiny)
    label axL   = label.new(int((leftBar + midBar) / 2.0),  botY - cellH * 0.10, "V-", style=label.style_none, textcolor=axisCol, size=size.tiny)
    label axR   = label.new(int((midBar + rightBar) / 2.0), botY - cellH * 0.10, "V+", style=label.style_none, textcolor=axisCol, size=size.tiny)
    miniLabels.push(axTop)
    miniLabels.push(axBot)
    miniLabels.push(axL)
    miniLabels.push(axR)

    // "You are here" dot - map (growth_z, vol_z) into the grid
    float gNorm = f_clamp(growth_z / 3.0, -1.0, 1.0)
    float vNorm = f_clamp(vol_z    / 3.0, -1.0, 1.0)
    // x: vNorm  -1 -> leftBar, +1 -> rightBar
    int   dotBar = int(midBar + vNorm * cellW)
    // y: gNorm  +1 -> topY,   -1 -> botY
    float dotY   = midY + gNorm * cellH
    miniDot := label.new(dotBar, dotY, "*", style=label.style_none, textcolor=color.new(activeBase, 0), size=size.normal)

// =============================================================================
//  SECTION 9 - DASHBOARD (9 rows)
// =============================================================================
//  Row 0 : Title header
//  Row 1 : Current Quadrant (code + full name)
//  Row 2 : Growth Z
//  Row 3 : Volatility Z
//  Row 4 : Bars in current quadrant
//  Row 5 : Last rotation (n bars ago)
//  Row 6 : Quadrant transition pattern
//  Row 7 : Suggested JOAT indicator
//  Row 8 : Asset-class analog
// =============================================================================
var table dash = na

if showDash
    if barstate.islast
        if not na(dash)
            table.delete(dash)
        dash := table.new(strToPos(dashPos), 2, 9, bgcolor=color.new(C_FRAME, 25), frame_color=color.new(C_FRAME, 0), frame_width=1, border_color=color.new(C_FRAME, 60), border_width=1)

        // local helper for one row write
        color hdrBg     = color.new(activeBase, 65)
        color cellLeft  = color.new(C_FRAME, 35)
        color cellRight = color.new(C_FRAME, 50)
        color valHi     = activeBase
        color valLo     = C_MUTED

        // gradient backgrounds precomputed per row (avoid nested funcs)
        color bgL1 = dashGradient ? grad(C_FRAME, 1, 9, 30, 60) : cellLeft
        color bgR1 = dashGradient ? grad(C_FRAME, 1, 9, 45, 70) : cellRight
        color bgL2 = dashGradient ? grad(C_FRAME, 2, 9, 30, 60) : cellLeft
        color bgR2 = dashGradient ? grad(C_FRAME, 2, 9, 45, 70) : cellRight
        color bgL3 = dashGradient ? grad(C_FRAME, 3, 9, 30, 60) : cellLeft
        color bgR3 = dashGradient ? grad(C_FRAME, 3, 9, 45, 70) : cellRight
        color bgL4 = dashGradient ? grad(C_FRAME, 4, 9, 30, 60) : cellLeft
        color bgR4 = dashGradient ? grad(C_FRAME, 4, 9, 45, 70) : cellRight
        color bgL5 = dashGradient ? grad(C_FRAME, 5, 9, 30, 60) : cellLeft
        color bgR5 = dashGradient ? grad(C_FRAME, 5, 9, 45, 70) : cellRight
        color bgL6 = dashGradient ? grad(C_FRAME, 6, 9, 30, 60) : cellLeft
        color bgR6 = dashGradient ? grad(C_FRAME, 6, 9, 45, 70) : cellRight
        color bgL7 = dashGradient ? grad(C_FRAME, 7, 9, 30, 60) : cellLeft
        color bgR7 = dashGradient ? grad(C_FRAME, 7, 9, 45, 70) : cellRight
        color bgL8 = dashGradient ? grad(C_FRAME, 8, 9, 30, 60) : cellLeft
        color bgR8 = dashGradient ? grad(C_FRAME, 8, 9, 45, 70) : cellRight

        // -- Row 0: Header --
        table.cell(dash, 0, 0, "BW [JOAT] | BRIDGEWATER ALL-WEATHER",
             text_color=C_TEXT, bgcolor=hdrBg, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 0, currentQuadrant == 0 ? "* INIT" : "* " + quadrantCode(currentQuadrant),
             text_color=C_TEXT, bgcolor=hdrBg, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 1: Quadrant --
        table.cell(dash, 0, 1, "Quadrant",
             text_color=C_MUTED, bgcolor=bgL1, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 1, quadrantName(currentQuadrant),
             text_color=valHi,   bgcolor=bgR1, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 2: Growth Z --
        color gZcol = growth_z > zDeadzone ? activeBase : growth_z < -zDeadzone ? activeBase : valLo
        table.cell(dash, 0, 2, "Growth Z",
             text_color=C_MUTED, bgcolor=bgL2, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 2, fmtSigned(growth_z),
             text_color=gZcol,   bgcolor=bgR2, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 3: Volatility Z --
        color vZcol = vol_z > zDeadzone ? activeBase : vol_z < -zDeadzone ? activeBase : valLo
        table.cell(dash, 0, 3, "Volatility Z",
             text_color=C_MUTED, bgcolor=bgL3, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 3, fmtSigned(vol_z),
             text_color=vZcol,   bgcolor=bgR3, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 4: Bars in current quadrant --
        table.cell(dash, 0, 4, "Bars in quadrant",
             text_color=C_MUTED, bgcolor=bgL4, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 4, fmtBars(barsInQuadrant),
             text_color=C_TEXT,  bgcolor=bgR4, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 5: Last rotation --
        string lastRotText = lastRotationBar == 0 ? "-" : str.tostring(barsSinceRot) + " bars ago"
        table.cell(dash, 0, 5, "Last rotation",
             text_color=C_MUTED, bgcolor=bgL5, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 5, lastRotText,
             text_color=C_TEXT,  bgcolor=bgR5, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 6: Rotation pattern --
        table.cell(dash, 0, 6, "Rotation pattern",
             text_color=C_MUTED, bgcolor=bgL6, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 6, rotationPattern,
             text_color=C_TEXT,  bgcolor=bgR6, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 7: Suggested JOAT --
        string suggText = (useSugg and currentQuadrant != 0) ? quadrantSuggestion(currentQuadrant) : "-"
        table.cell(dash, 0, 7, "Suggested JOAT",
             text_color=C_MUTED, bgcolor=bgL7, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 7, suggText,
             text_color=activeBase, bgcolor=bgR7, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

        // -- Row 8: Asset-class analog --
        string assetText = (useAssetAnalog and currentQuadrant != 0) ? quadrantAsset(currentQuadrant) : "-"
        table.cell(dash, 0, 8, "Asset analog",
             text_color=C_MUTED, bgcolor=bgL8, text_size=strToSize(dashSize), text_halign=text.align_left, text_font_family=font.family_monospace)
        table.cell(dash, 1, 8, assetText,
             text_color=C_TEXT,  bgcolor=bgR8, text_size=strToSize(dashSize), text_halign=text.align_right, text_font_family=font.family_monospace)

// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================
bool enteredQ1 = rotated and currentQuadrant == 1
bool enteredQ2 = rotated and currentQuadrant == 2
bool enteredQ3 = rotated and currentQuadrant == 3
bool enteredQ4 = rotated and currentQuadrant == 4

if alertOnRotation and rotated
    alert("BW [JOAT] rotation: " + quadrantCode(previousQuadrant) + " -> " + quadrantCode(currentQuadrant) + "  |  Growth Z " + fmtSigned(growth_z) + "  |  Vol Z " + fmtSigned(vol_z), alert.freq_once_per_bar_close)
if alertOnQ4 and enteredQ4
    alert("BW [JOAT] risk-off: entered Q4 (Falling Growth, High Vol). Asset analog: " + quadrantAsset(4), alert.freq_once_per_bar_close)
if alertOnQ1 and enteredQ1
    alert("BW [JOAT] risk-on: entered Q1 (Rising Growth, Low Vol). Asset analog: " + quadrantAsset(1), alert.freq_once_per_bar_close)

alertcondition(enteredQ1, title="Entered Q1", message="BW [JOAT] entered Q1 - Rising Growth, Low Vol (equities)")
alertcondition(enteredQ2, title="Entered Q2", message="BW [JOAT] entered Q2 - Rising Growth, High Vol (commodities)")
alertcondition(enteredQ3, title="Entered Q3", message="BW [JOAT] entered Q3 - Falling Growth, Low Vol (bonds)")
alertcondition(enteredQ4, title="Entered Q4", message="BW [JOAT] entered Q4 - Falling Growth, High Vol (gold / risk-off)")
alertcondition(rotated,   title="Any Rotation", message="BW [JOAT] quadrant rotation event")

// =============================================================================
//  END OF FILE
// =============================================================================
````
