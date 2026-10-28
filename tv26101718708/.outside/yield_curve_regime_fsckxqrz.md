# Yield Curve Regime 

- url: https://www.tradingview.com/script/FsCkxqrz/
- type: indicator
- pine_id: PUB;d0e2ba2bbe2a4415843cb86340531353
- version: 1.0

## Description

Yield Curve Regime – Pro Edition

=== WHAT IT DOES ===
This indicator classifies the U.S. Treasury yield curve into six canonical
regimes by comparing the current behavior of a short-maturity yield
(default 2Y) and a long-maturity yield (default 10Y) against their values
N bars ago. It paints the chart background (or bar color) with the
regime color and renders a modular on-chart dashboard showing the active
regime, a curve-delta trend arrow, live yield snapshots, a quantitative
strength score, multi-horizon confluence, dwell-time, rolling regime
frequencies, and a transition log.

=== WHY IT IS DIFFERENT ===
Most public yield-curve scripts plot the 10Y-2Y spread or flag a single
inversion event. This script decomposes every curve move into the two
dimensions that actually matter for fixed-income interpretation:

  1) Curve direction : did the spread steepen or flatten?
  2) Yield direction : did short and long yields rise or fall?

Crossing these dimensions produces six distinct regimes, each with a
different macro meaning. A +10 bp move in the 2s10s spread can be a
"Bull Steepener" (Fed easing – risk-on friendly) or a "Bear Steepener"
(inflation / term-premium driven – risk-off friendly). Flagging only
the spread hides that distinction; the six-regime framework exposes it.

On top of that six-regime base, this indicator adds four analytical
layers that, to the best of our knowledge, are not combined in any
existing public yield-curve script:

  • A Z-score-based Strength score (0–100) that quantifies *how
    convincing* each regime is instead of treating it as a binary flag.
    Calibrated so |Z| = 2.0 (the 95 % confidence band) maps to 100.
  • A Multi-Horizon Confluence score (0/3, 1/3, 2/3, 3/3) computed by
    running the same regime detection on three independent offsets
    (fast / mid / slow) and measuring agreement across horizons.
  • A Dwell-Time counter plus a rolling history of the last N regime
    transitions, so the viewer can see not just the current regime
    but its persistence and transition path.
  • A rolling Regime-Frequency statistic showing what percentage of
    the last freqLen bars each regime occupied, rendered as an inline
    bar and a precise percentage in a dedicated dashboard block.

These are genuine additions to the calculation – not cosmetics.
All of them are visualized in the on-chart dashboard so the reader
can consume the extra information at a glance.

=== THE SIX REGIMES (core logic) ===
Let curve = longRate - shortRate, compared against its value "offset"
bars ago. A regime fires when all three conditions hold simultaneously:

  Bull Steepener  : curve widens, short falls, long falls
                    (short falls faster – classic early easing cycle)
  Bear Steepener  : curve widens, short rises, long rises
                    (long rises faster – inflation / term premium / supply)
  Steepener Twist : curve widens, short falls, long rises
                    (reflation pivot / policy-vs-inflation divergence)
  Bull Flattener  : curve narrows, short falls, long falls
                    (long falls faster – flight to quality / recession bid)
  Bear Flattener  : curve narrows, short rises, long rises
                    (short rises faster – aggressive Fed tightening)
  Flattener Twist : curve narrows, short rises, long falls
                    (stagflation signal / tightening into weakness)

Exactly one regime fires per bar (the six conditions are mutually
exclusive by construction). When none triggers, the background stays
clean.

=== HOW TO READ THE DASHBOARD ===
• Header row      – ticker + timeframe context.
• Active row      – the regime currently firing, tinted in its own
                    color, with a ▲ / ▼ / ▬ arrow showing the signed
                    change of the curve over the fast offset window.
• Strength bar    – █-fill from 0 to 100 plus the exact score.
• Confluence row  – ●●● / ●●○ / ●○○ / ○○○ plus score 0/3 … 3/3.
• Dwell row       – bars elapsed inside the current regime.
• Yields block    – live short, long, and curve values.
• Legend block    – every enabled regime with a colored dot and a
                    live "● aktiv" / "○ ruhend" status.
• Frequency block – each regime's share of the last freqLen bars,
                    shown as a 10-step bar plus exact percentage.
• Transitions     – a log of the most recent regime changes
                    (newest first).
• Background/bars – tinted in the active regime's color, optionally
                    dimmed when Strength is low.

=== HOW TO READ THE ANALYTICAL LAYERS ===
• Strength bar (█████░░░░░ 65 / 100) – the farther right it fills,
  the more statistically significant the regime move is relative to
  its rolling volatility. Calibrated so a Z-aggregate of 2.0 (roughly
  the 95 % band of a normal distribution) maps to a score of 100.
• Confluence (●●○ 2/3) – how many of the three horizons confirm the
  fast-horizon regime. 3/3 is a strong multi-timeframe signal; 1/3 is
  fast-only; 0/3 means no active regime on any horizon.
• Dwell – bars elapsed inside the current regime. Useful for spotting
  exhausted vs. freshly-started regimes.
• Frequency – every regime's rolling share of the freqLen window,
  letting you see at a glance which regime has dominated the current
  macro cycle.
• Transitions – a compact log of the most recent regime changes.

=== SETTINGS (all inputs are grouped and collapsible) ===
• Symbols & Offset – pick any two yield tickers plus three lookback
                    windows (fast / mid / slow) for confluence.
• Detection       – rolling window for frequency statistics,
                    maximum stored transitions.
• Display         – background vs. bar coloring, transparency,
                    optional strength-coupled transparency.
• Regime selection– enable/disable any subset of the six regimes.
• Color palette   – fully user-overridable regime colors.
• Dashboard       – master toggle, compact mode (active regime only),
                    independent per-section toggles for header,
                    active+strength, confluence, dwell, yields,
                    legend, frequency, and transitions, plus
                    configurable position and text size.

=== HOW TO USE IT ===
• As a macro / risk-regime filter on SPX, NDX, DXY, TLT, HYG, BTC,
  gold or any risk-sensitive instrument: the regime in force often
  explains why cross-asset correlations are behaving the way they are.
• To disambiguate yield-curve headlines: a "curve is steepening"
  print means something very different if it is a Bull Steepener vs.
  a Bear Steepener; this indicator answers that question at a glance.
• To study historical regime transitions: switch background mode on
  and scroll back through past cycles to see how regimes clustered
  around recessions, pivots, and inflation shocks.
• The offset inputs let you tune sensitivity: 1 bar for intraday
  regime nowcasting, 5–20 bars for swing and macro framing.

=== NOTES & LIMITATIONS ===
• Defaults to US02Y and US10Y but accepts any two yield symbols –
  not hard-coded to U.S. Treasuries; works on Bund, Gilt, JGB curves
  if the data is available on your plan.
• Regimes are evaluated on bar-close comparisons and can flip
  intrabar on lower timeframes; use daily or weekly for stable macro
  readings.
• The Strength score relies on rolling standard deviations over a
  50-bar window. On low-liquidity / low-frequency data the σ estimate
  can be unstable for the first 50 bars after loading.
• Multi-Horizon Confluence runs the raw regime detection on mid and
  slow offsets, so slower horizons can confirm a faster signal even
  when their Δcurve is small – this is by design, not a bug.
• The Steepener Twist and Flattener Twist cases are structurally
  rarer than the four main regimes and often mark transitions rather
  than trends – treat them as context, not as standalone signals.
• This is an analytical / visual tool, not a buy/sell system. It does
  not generate entries, exits, or forecasts.

## Source Code

````pine
//@version=6
indicator("Yield Curve Regime – Pro UI", shorttitle="YCR+", overlay=true)

// ============================================================
// EINSTELLUNGEN – jede Gruppe ist im Settings-Panel zuklappbar
// ============================================================

// ——— Symbole & Offset ———
gSym = "📊 Symbole & Offset"
shortSymbol = input.symbol("US02Y", "Short-Rendite", group=gSym)
longSymbol  = input.symbol("US10Y", "Long-Rendite",  group=gSym)
offsetFast  = input.int(1,  "Offset schnell (Bars)",  minval=1, group=gSym, tooltip="Nowcasting-Horizont – Basis für die aktive Regime-Erkennung.")
offsetMid   = input.int(5,  "Offset mittel (Bars)",   minval=1, group=gSym, tooltip="Swing-Horizont für den Confluence-Check.")
offsetSlow  = input.int(20, "Offset langsam (Bars)",  minval=1, group=gSym, tooltip="Makro-Horizont (~1 Monat auf Daily) für den Confluence-Check.")

// ——— Detektion & Statistik ———
gDet = "🧪 Detektion & Statistik"
noiseLen = 50
freqLen  = input.int(252, "Fenster für Regime-Häufigkeit (Bars)", minval=20, group=gDet, tooltip="Lookback für rollende %-Statistik. 252 ≈ 1 Jahr auf Daily.")
maxTrans = input.int(5,   "Max angezeigte Transitionen", minval=1, maxval=10, group=gDet)

// ——— Darstellung ———
gStyle = "🎨 Darstellung"
useBackground = input.bool(true, "Hintergrund einfärben (sonst Kerzen)", group=gStyle)
bgAlpha       = input.int(80,    "Hintergrund-Transparenz %", minval=0, maxval=100, group=gStyle)
dimByStrength = input.bool(true, "Transparenz an Strength koppeln", group=gStyle, tooltip="Schwache Regime werden durchsichtiger, starke kräftiger.")

// ——— Regime-Auswahl ———
gReg = "🌀 Regime-Auswahl"
showBullSteep  = input.bool(true, "Bull Steepener",    group=gReg)
showBearSteep  = input.bool(true, "Bear Steepener",    group=gReg)
showSteepTwist = input.bool(true, "Steepener Twist",   group=gReg)
showBullFlat   = input.bool(true, "Bull Flattener",    group=gReg)
showBearFlat   = input.bool(true, "Bear Flattener",    group=gReg)
showFlatTwist  = input.bool(true, "Flattener Twist",   group=gReg)

// ——— Farbpalette ———
gClr = "🎨 Farbpalette"
colBullSteepRaw  = input.color(#1f77b4, "Bull Steepener",  group=gClr)
colBearSteepRaw  = input.color(#ff7f0e, "Bear Steepener",  group=gClr)
colSteepTwistRaw = input.color(#2ca02c, "Steepener Twist", group=gClr)
colBullFlatRaw   = input.color(#d62728, "Bull Flattener",  group=gClr)
colBearFlatRaw   = input.color(#9467bd, "Bear Flattener",  group=gClr)
colFlatTwistRaw  = input.color(#8c564b, "Flattener Twist", group=gClr)

// ——— Dashboard (auf/zuklappbare Sektionen) ———
gUI = "🧾 Dashboard"
showDashboard = input.bool(true,  "Dashboard anzeigen", group=gUI)
compactMode   = input.bool(false, "Kompakt (nur aktives Regime)", group=gUI)
showHeader    = input.bool(true,  "▸ Kopfzeile", group=gUI)
showActive    = input.bool(true,  "▸ Aktives Regime + Strength", group=gUI)
showConf      = input.bool(true,  "▸ Confluence", group=gUI)
showDwell     = input.bool(true,  "▸ Dwell-Time", group=gUI)
showYields    = input.bool(true,  "▸ Renditen & Kurve", group=gUI)
showLegend    = input.bool(true,  "▸ Legende (live Status)", group=gUI)
showFreq      = input.bool(true,  "▸ Regime-Häufigkeit (% Fenster)", group=gUI)
showTrans     = input.bool(true,  "▸ Letzte Transitionen", group=gUI)
dashPos       = input.string("top_right", "Position", options=["top_left","top_right","bottom_left","bottom_right","middle_right"], group=gUI)
dashSize      = input.string("normal", "Textgröße", options=["tiny","small","normal","large","huge"], group=gUI)

// ============================================================
// KERNLOGIK 
// ============================================================
shortRate = request.security(shortSymbol, timeframe.period, close)
longRate  = request.security(longSymbol,  timeframe.period, close)

curve = longRate - shortRate

// ——— Regime-Formel, parametrisiert auf Offset ———
f_regime(int off) =>
    bS  = curve > curve[off] and shortRate < shortRate[off] and longRate < longRate[off]
    beS = curve > curve[off] and shortRate > shortRate[off] and longRate > longRate[off]
    sT  = curve > curve[off] and shortRate < shortRate[off] and longRate > longRate[off]
    bF  = curve < curve[off] and shortRate < shortRate[off] and longRate < longRate[off]
    beF = curve < curve[off] and shortRate > shortRate[off] and longRate > longRate[off]
    fT  = curve < curve[off] and shortRate > shortRate[off] and longRate < longRate[off]
    [bS, beS, sT, bF, beF, fT]

[bSF, beSF, sTF, bFF, beFF, fTF] = f_regime(offsetFast)
[bSM, beSM, sTM, bFM, beFM, fTM] = f_regime(offsetMid)
[bSS, beSS, sTS, bFS, beFS, fTS] = f_regime(offsetSlow)

curveDeltaFast = curve - curve[offsetFast]

bullSteep  = bSF
bearSteep  = beSF
steepTwist = sTF
bullFlat   = bFF
bearFlat   = beFF
flatTwist  = fTF

// ——— MODUL 1: Regime-Strength-Score (0–100) via Z-Score-Aggregation ———
dShort       = shortRate - shortRate[offsetFast]
dLong        = longRate  - longRate[offsetFast]
dShortStd    = ta.stdev(shortRate - shortRate[1], noiseLen) * math.sqrt(offsetFast)
dLongStd     = ta.stdev(longRate  - longRate[1],  noiseLen) * math.sqrt(offsetFast)
dCurveStdWin = ta.stdev(curve - curve[1], noiseLen) * math.sqrt(offsetFast)

zShort = dShortStd    > 0 ? math.abs(dShort)         / dShortStd    : 0.0
zLong  = dLongStd     > 0 ? math.abs(dLong)          / dLongStd     : 0.0
zCurv  = dCurveStdWin > 0 ? math.abs(curveDeltaFast) / dCurveStdWin : 0.0
rawScore = (zCurv + (zShort + zLong) / 2.0) / 2.0
strength = math.min(100.0, rawScore / 2.0 * 100.0)

// ——— MODUL 2: Multi-Horizon-Confluence (fast / mid / slow) ———
agreeMid  = (bSF and bSM)  or (beSF and beSM) or (sTF and sTM) or (bFF and bFM) or (beFF and beFM) or (fTF and fTM)
agreeSlow = (bSF and bSS)  or (beSF and beSS) or (sTF and sTS) or (bFF and bFS) or (beFF and beFS) or (fTF and fTS)
activeFast = bSF or beSF or sTF or bFF or beFF or fTF
confluence = (activeFast ? 1 : 0) + (agreeMid ? 1 : 0) + (agreeSlow ? 1 : 0)

// ——— Aktives Regime + Farbe + Schlüssel für Dwell/Transitionen ———
var color regimeClrBase = na
regimeClrBase := na
var string regimeKey = "none"
regimeKey := "none"

if     showBullSteep  and bullSteep
    regimeClrBase := colBullSteepRaw
    regimeKey := "BullSteep"
else if showBearSteep  and bearSteep
    regimeClrBase := colBearSteepRaw
    regimeKey := "BearSteep"
else if showSteepTwist and steepTwist
    regimeClrBase := colSteepTwistRaw
    regimeKey := "SteepTwist"
else if showBullFlat   and bullFlat
    regimeClrBase := colBullFlatRaw
    regimeKey := "BullFlat"
else if showBearFlat   and bearFlat
    regimeClrBase := colBearFlatRaw
    regimeKey := "BearFlat"
else if showFlatTwist  and flatTwist
    regimeClrBase := colFlatTwistRaw
    regimeKey := "FlatTwist"

// ——— MODUL 3: Dwell-Time + Transition-History ———
var string prevRegime = "none"
var int    dwellBars  = 0
var array<string> transHistory = array.new_string(0)

isNewRegime = regimeKey != prevRegime
if barstate.isconfirmed
    if isNewRegime and regimeKey != "none"
        array.unshift(transHistory, prevRegime + " → " + regimeKey)
        if array.size(transHistory) > maxTrans
            array.pop(transHistory)
    dwellBars := isNewRegime ? 1 : dwellBars + 1
    prevRegime := regimeKey

// ——— BONUS: Inversions-Counter ———
isInverted  = curve < 0
var int invBars = 0
if barstate.isconfirmed
    invBars := isInverted ? invBars + 1 : 0

// ——— MODUL 5: Rolling Regime-Frequency über freqLen Bars ———
var array<int> histBullS = array.new_int(0)
var array<int> histBearS = array.new_int(0)
var array<int> histStwT  = array.new_int(0)
var array<int> histBullF = array.new_int(0)
var array<int> histBearF = array.new_int(0)
var array<int> histFlatT = array.new_int(0)

if barstate.isconfirmed
    array.push(histBullS, bullSteep  ? 1 : 0)
    array.push(histBearS, bearSteep  ? 1 : 0)
    array.push(histStwT,  steepTwist ? 1 : 0)
    array.push(histBullF, bullFlat   ? 1 : 0)
    array.push(histBearF, bearFlat   ? 1 : 0)
    array.push(histFlatT, flatTwist  ? 1 : 0)
    if array.size(histBullS) > freqLen
        array.shift(histBullS)
        array.shift(histBearS)
        array.shift(histStwT)
        array.shift(histBullF)
        array.shift(histBearF)
        array.shift(histFlatT)

f_pct(arr) =>
    n = array.size(arr)
    n == 0 ? 0.0 : 100.0 * array.sum(arr) / n

pctBullS = f_pct(histBullS)
pctBearS = f_pct(histBearS)
pctStwT  = f_pct(histStwT)
pctBullF = f_pct(histBullF)
pctBearF = f_pct(histBearF)
pctFlatT = f_pct(histFlatT)

// ——— Chart-Färbung – Transparenz optional an Strength gekoppelt ———
color regimeClrSolid = regimeClrBase
color regimeClrBG    = na
if not na(regimeClrBase)
    effAlpha = dimByStrength ? math.min(100, math.round(bgAlpha + (100 - bgAlpha) * (1.0 - strength / 100.0))) : bgAlpha
    regimeClrBG := color.new(regimeClrBase, effAlpha)

bgcolor(useBackground ? regimeClrBG : na)
barcolor(useBackground ? na : regimeClrSolid)

// ============================================================
// DASHBOARD – modular, mit 5 neuen Analyseschichten
// ============================================================
f_bar(float pct) =>
    int filled = math.min(10, math.max(0, math.round(pct / 10)))
    string s = ""
    for i = 0 to 9
        s := s + (i < filled ? "█" : "░")
    s

f_pos(p) =>
    switch p
        "top_left"     => position.top_left
        "top_right"    => position.top_right
        "bottom_left"  => position.bottom_left
        "bottom_right" => position.bottom_right
        => position.middle_right

f_size(s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        "huge"  => size.huge
        => size.normal

// Aktives Regime → Label + Farbe (als if/else-Kaskade für v6-Kompatibilität)
string activeLabel = "⚪ Kein Regime aktiv"
if bullSteep  and showBullSteep
    activeLabel := "🟦 Bull Steepener"
else if bearSteep  and showBearSteep
    activeLabel := "🟧 Bear Steepener"
else if steepTwist and showSteepTwist
    activeLabel := "🟩 Steepener Twist"
else if bullFlat   and showBullFlat
    activeLabel := "🟥 Bull Flattener"
else if bearFlat   and showBearFlat
    activeLabel := "🟪 Bear Flattener"
else if flatTwist  and showFlatTwist
    activeLabel := "🟫 Flattener Twist"

activeClr = na(regimeClrBase) ? color.new(color.gray, 0) : regimeClrBase

// Trend-Pfeil aus Kurven-Delta (fast Horizont)
trendArrow = curveDeltaFast > 0 ? "▲" : curveDeltaFast < 0 ? "▼" : "▬"
trendClr   = curveDeltaFast > 0 ? color.new(color.teal, 0) : curveDeltaFast < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)

// Confluence-Dots (MODUL 3)
confluenceStr = (confluence >= 1 ? "●" : "○") + (confluence >= 2 ? "●" : "○") + (confluence >= 3 ? "●" : "○") + "  " + str.tostring(confluence) + "/3"
confluenceClr = confluence >= 3 ? color.new(color.lime, 0) : confluence == 2 ? color.new(color.yellow, 0) : confluence == 1 ? color.new(color.orange, 0) : color.new(color.gray, 0)

var table dash = table.new(f_pos(dashPos), 3, 60, frame_color=color.new(color.gray, 50), frame_width=1, border_width=1, border_color=color.new(color.black, 80))

if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 2, 59)
    txt    = f_size(dashSize)
    bgHead = color.new(#151715, 0)
    bgRow  = color.new(#1e1e1e, 10)
    fg     = color.new(color.white, 0)
    muted  = color.new(color.gray, 0)

    int r = 0

    // ── Kopfzeile ──
    if showHeader and not compactMode
        table.cell(dash, 0, r, "🌀 YC Regime",  text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, syminfo.ticker,   text_color=muted, bgcolor=bgHead, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(timeframe.period) + (timeframe.isminutes ? "m" : ""), text_color=muted, bgcolor=bgHead, text_size=txt, text_halign=text.align_right)
        r := r + 1

    // ── Aktives Regime + Strength-Bar (MODUL 1) ──
    if showActive or compactMode
        table.cell(dash, 0, r, "Aktiv", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, activeLabel, text_color=color.white, bgcolor=color.new(activeClr, 30), text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, trendArrow + " " + str.tostring(curveDeltaFast, "#.##"), text_color=color.white, bgcolor=trendClr, text_size=txt, text_halign=text.align_center)
        r := r + 1
        table.cell(dash, 0, r, "Strength", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, f_bar(strength), text_color=activeClr, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(strength, "#") + " / 100", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1

    // ── Confluence (MODUL 2) ──
    if showConf and not compactMode
        table.cell(dash, 0, r, "Confluence", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, confluenceStr, text_color=color.white, bgcolor=color.new(confluenceClr, 40), text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "fast/mid/slow", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1

    // ── Dwell-Time (MODUL 3) ──
    if showDwell and not compactMode
        table.cell(dash, 0, r, "Dwell", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, str.tostring(dwellBars) + " Bars", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "seit Regimewechsel", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1

    // ── Inversion (BONUS) – nur anzeigen, wenn curve < 0 ──
    if showDwell and not compactMode and isInverted
        invLabel = invBars >= 60 ? "🚨 Kritisch (≥60)" : invBars >= 20 ? "⚠️ Warnung (≥20)" : "ℹ️ Früh (<20)"
        table.cell(dash, 0, r, "Inversion", text_color=color.new(color.red, 0), bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, str.tostring(invBars) + " Bars", text_color=color.white, bgcolor=color.new(color.red, 20), text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, invLabel, text_color=color.new(color.red, 0), bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1

    // ── Renditen & Kurve ──
    if showYields and not compactMode
        table.cell(dash, 0, r, "Short", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, str.tostring(shortRate, "#.##"), text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "2Y",    text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Long",  text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, str.tostring(longRate, "#.##"),  text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "10Y",   text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Kurve", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, str.tostring(curve, "#.##"),     text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "Long−Short", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1

    // ── Legende aller Regime (mit Live-Status) ──
    if showLegend and not compactMode
        table.cell(dash, 0, r, "Legende", text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, "Regime",  text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "Status",  text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_right)
        r := r + 1

        if showBullSteep
            table.cell(dash, 0, r, "●", text_color=colBullSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
            table.cell(dash, 1, r, "Bull Steepener", text_color=colBullSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
            table.cell(dash, 2, r, bullSteep ? "● aktiv" : "○ ruhend", text_color=bullSteep ? colBullSteepRaw : muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
            r := r + 1
        if showBearSteep
            table.cell(dash, 0, r, "●", text_color=colBearSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
            table.cell(dash, 1, r, "Bear Steepener", text_color=colBearSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
            table.cell(dash, 2, r, bearSteep ? "● aktiv" : "○ ruhend", text_color=bearSteep ? colBearSteepRaw : muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
            r := r + 1
        if showSteepTwist
            table.cell(dash, 0, r, "●", text_color=colSteepTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
            table.cell(dash, 1, r, "Steepener Twist", text_color=colSteepTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
            table.cell(dash, 2, r, steepTwist ? "● aktiv" : "○ ruhend", text_color=steepTwist ? colSteepTwistRaw : muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
            r := r + 1
        if showBullFlat
            table.cell(dash, 0, r, "●", text_color=colBullFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
            table.cell(dash, 1, r, "Bull Flattener", text_color=colBullFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
            table.cell(dash, 2, r, bullFlat ? "● aktiv" : "○ ruhend", text_color=bullFlat ? colBullFlatRaw : muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
            r := r + 1
        if showBearFlat
            table.cell(dash, 0, r, "●", text_color=colBearFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
            table.cell(dash, 1, r, "Bear Flattener", text_color=colBearFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
            table.cell(dash, 2, r, bearFlat ? "● aktiv" : "○ ruhend", text_color=bearFlat ? colBearFlatRaw : muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
            r := r + 1
        if showFlatTwist
            table.cell(dash, 0, r, "●", text_color=colFlatTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
            table.cell(dash, 1, r, "Flattener Twist", text_color=colFlatTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
            table.cell(dash, 2, r, flatTwist ? "● aktiv" : "○ ruhend", text_color=flatTwist ? colFlatTwistRaw : muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
            r := r + 1

    // ── Regime-Häufigkeit (MODUL 4) ──
    if showFreq and not compactMode
        table.cell(dash, 0, r, "Häufigkeit", text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, str.tostring(freqLen) + " Bars", text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "% aktiv", text_color=muted, bgcolor=bgHead, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Bull Steep", text_color=colBullSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, f_bar(pctBullS), text_color=colBullSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(pctBullS, "#.#") + " %", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Bear Steep", text_color=colBearSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, f_bar(pctBearS), text_color=colBearSteepRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(pctBearS, "#.#") + " %", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Steep Twist", text_color=colSteepTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, f_bar(pctStwT), text_color=colSteepTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(pctStwT, "#.#") + " %", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Bull Flat", text_color=colBullFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, f_bar(pctBullF), text_color=colBullFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(pctBullF, "#.#") + " %", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Bear Flat", text_color=colBearFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, f_bar(pctBearF), text_color=colBearFlatRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(pctBearF, "#.#") + " %", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1
        table.cell(dash, 0, r, "Flat Twist", text_color=colFlatTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, f_bar(pctFlatT), text_color=colFlatTwistRaw, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, str.tostring(pctFlatT, "#.#") + " %", text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
        r := r + 1

    // ── Letzte Regime-Transitionen  ──
    if showTrans and not compactMode
        table.cell(dash, 0, r, "Transitionen", text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_left)
        table.cell(dash, 1, r, "letzte " + str.tostring(math.min(maxTrans, array.size(transHistory))), text_color=fg, bgcolor=bgHead, text_size=txt, text_halign=text.align_center)
        table.cell(dash, 2, r, "neu → alt", text_color=muted, bgcolor=bgHead, text_size=txt, text_halign=text.align_right)
        r := r + 1
        if array.size(transHistory) == 0
            table.cell(dash, 0, r, "—", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
            table.cell(dash, 1, r, "noch keine Regimewechsel", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
            table.cell(dash, 2, r, "—", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
            r := r + 1
        else
            for i = 0 to math.min(maxTrans, array.size(transHistory)) - 1
                table.cell(dash, 0, r, "#" + str.tostring(i + 1), text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_left)
                table.cell(dash, 1, r, array.get(transHistory, i), text_color=fg, bgcolor=bgRow, text_size=txt, text_halign=text.align_center)
                table.cell(dash, 2, r, "", text_color=muted, bgcolor=bgRow, text_size=txt, text_halign=text.align_right)
                r := r + 1
````
