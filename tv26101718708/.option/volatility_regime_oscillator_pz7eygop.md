# Volatility Regime Oscillator

- url: https://www.tradingview.com/script/pz7eYgOp-Volatility-Regime-Oscillator/
- type: indicator
- pine_id: PUB;5f8f8238378b4dc19f13edab665f697d
- version: 3.0

## Description

Volatility Regime Oscillator 

OVERVIEW

A 0-100 oscillator confined to the one thing volatility truly does: measure and manage risk. It forecasts how large moves are likely to be, places that forecast on a self-normalising 0-100 percentile scale (calm → extreme), and reports the position-size multiplier a volatility-targeting approach would call for. You read it next to your own method and size accordingly. It places no orders, gives no entry/exit signals, and takes no view on direction. Volatility's only job here is how big, never which way — that restraint is the whole design.

WHY THESE METHODS BELONG IN ONE SCRIPT (mashup rationale)

This is not a folder of separate volatility studies — it is one pipeline, and each stage feeds the next:


Estimate. Range-based estimators (Yang-Zhang, Garman-Klass, Rogers-Satchell, Parkinson) measure realised volatility far more efficiently than close-to-close; combining them is more robust out-of-sample than trusting any single one.
Forecast. A HAR multi-horizon blend (with an optional measurement-error correction that shifts weight off the noisy fast term), EWMA, or window mean turns that estimate forward.
Character. Good/bad semivariance and vol-of-vol report whether the move is downside-driven and whether the volatility itself is stable — context a single number can't carry.
Regime. A percentile rank converts the forecast into a self-normalising 0-100 read, so the same calm/normal/high/extreme bands work on any symbol or timeframe.
Size. Volatility targeting turns the forecast into an exposure multiplier — blended toward constant exposure and gated down in extremes, the robust drawdown-reducing form.


A forecaster without a regime frame is just a number; a regime read without sizing is just a gauge; sizing without the de-risk gates is the naive targeting the research shows underwhelms. Chained, they answer one question end to end: how big is risk now, and what does that imply for size? Remove a stage and the chain breaks.

HOW IT IS DIFFERENT FROM A PLAIN VOLATILITY FORECASTER

Most volatility tools answer "what will volatility be?" This one answers "where does volatility sit, and how much should I size?" The forecast is only the input; the output is a regime percentile plus a position-sizing multiplier — vol targeting, conditional targeting, a managed/constant blend, downside scaling, and an optional stress gate — wrapped in a risk-management frame. It is a sizing and regime gauge, not a forecasting study.

HOW TO USE


Oscillator 0-100 = where current forecast vol sits in its own history (percentile). Bands: <25 calm, 25-65 normal, 65-90 high, ≥90 extreme.
Dotted marker = where your target vol sits in that distribution. Line above the marker = vol above target → size down; below = room to size up.
Suggested exposure (dashboard) = the vol-target multiplier of equity a long would use now (1.0× = 100%). Apply it to your own side.
Optional expected-move envelope on the price chart shows the size of the likely move (for stop placement) — symmetric, regime-coloured, never a direction or target.


UNIVERSAL ACROSS MARKETS

The estimators read OHLC, so it runs on any instrument and timeframe out of the box. An optional Analyse symbol input reroutes the calculation to a different instrument than the one charted. Annualisation is derived from the chart timeframe by default (so the forecast-vol % and the target marker read sensibly on any timeframe), with a manual bars-per-year override available. The India VIX stress gate is OFF by default because it reads an India-specific implied-vol symbol that would mislead on other markets — turn it on only for NIFTY / BANKNIFTY.

ACCURACY — AN HONEST NOTE

This contains the most advanced volatility methods genuinely computable from price bars. It does not and cannot contain the options-data frontier — rough-volatility calibration (rough Heston / fractional Brownian), deep-learning forecasters, or implied-vol-surface models — none of which run on chart OHLC. Even at its best, realised-vol forecasting explains only a minority of realised-vol variance. Treat this as a sharper estimate and a disciplined risk gauge, not a precise or certain forecast. The "suggested exposure" is context for your own risk process, not an instruction; the research is explicit that full vol-targeting often fails to beat constant exposure out of sample — the keepable part is tail/drawdown reduction, which is why sizing is blended toward constant exposure by default.

ORIGINALITY

The individual methods are public and credited below. The original work is the assembly: a single self-normalising oscillator that chains efficient range estimators → a measurement-error-corrected HAR forecast → a semivariance/vol-of-vol character read → a percentile regime → a blended, gated volatility-targeting exposure, with a regime-coloured expected-move envelope — a risk-and-sizing gauge rather than a forecast or a directional signal. No third-party Pine code is reused.

CONCEPT CREDIT

Volatility estimators — M. Parkinson (1980); Garman & Klass (1980); Rogers & Satchell (1991); Yang & Zhang (2000). HAR forecaster — Fulvio Corsi (2009); measurement-error (HARQ) correction — Bollerslev, Patton & Quaedvlieg (2016). EWMA / RiskMetrics — J.P. Morgan (1996). Good/bad realised semivariance — Barndorff-Nielsen, Kinnebrock & Shephard; Patton & Sheppard (2015). Path-dependent leverage effect — Julien Guyon & Jordan Lekeufack (2023). Volatility targeting / conditional targeting — Moreira & Muir (2017); Harvey et al. (2018); robustness caveats — Cederburg et al. (2020); Wang & Yan (2021). Assembly, oscillator framing, regime bands and the target marker are the author's own work. Not affiliated with, nor endorsed by, any third party.

DISCLAIMER

Educational risk-management gauge. NOT financial advice, NOT a signal, and NO guarantee of any outcome. Estimates from price can be wrong, especially through structural breaks and on low-history symbols. Trading carries risk of loss. Do your own research and manage your own risk. The author accepts no liability for any use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// VOLATILITY REGIME OSCILLATOR                                                            v3.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A 0-100 oscillator confined to the one thing volatility truly does: measure and manage RISK.
//   It forecasts how LARGE moves are likely to be, places that forecast on a self-normalising
//   0-100 percentile scale (calm -> extreme), and reports the position-size multiplier a
//   volatility-targeting approach would call for. You read it next to your own method and size
//   accordingly. It places no orders, gives no entry/exit signals, and takes NO view on direction.
//   Volatility's only job here is HOW BIG, never WHICH WAY - that restraint is the whole design.
//
// WHAT MAKES IT DIFFERENT  (why these methods are ONE tool, not a folder of studies)
//   Every component serves a single pipeline - estimate volatility, forecast it, judge its
//   character, place it in regime, and convert that into a size - and each stage feeds the next:
//     - ESTIMATE: range-based estimators (Yang-Zhang / Garman-Klass / Rogers-Satchell / Parkinson)
//       measure realised volatility far more efficiently than close-to-close; combining them is
//       more robust out-of-sample than trusting any one.
//     - FORECAST: a HAR multi-horizon blend (with an optional measurement-error correction that
//       shifts weight off the noisy fast term), a ROUGH-VOLATILITY fractional-kernel forecaster
//       (power-law memory, Gatheral-Jaisson-Rosenbaum), a GARCH(1,1) with variance targeting,
//       EWMA, or a window mean turns the estimate forward - and an out-of-sample QLIKE horse-race
//       can pick the model that is actually forecasting best on THIS instrument.
//     - CHARACTER: good/bad semivariance and vol-of-vol say whether the move is downside-driven
//       and whether the vol itself is stable - context the single number can't carry.
//     - REGIME: a percentile rank turns the forecast into a self-normalising 0-100 read, so the
//       same calm/normal/high/extreme bands work on any symbol or timeframe.
//     - SIZE: volatility targeting converts the forecast into an exposure multiplier, blended
//       toward constant exposure and gated down in extremes - the robust, drawdown-reducing form.
//   A forecaster without a regime frame is just a number; a regime read without sizing is just a
//   gauge; sizing without the de-risk gates is naive targeting that the research shows underwhelms.
//   Chained, they answer one question end to end: how big is risk now, and what does that imply
//   for size? Remove any stage and the chain breaks.
//
// ACCURACY - AN HONEST NOTE
//   This contains the most advanced volatility methods genuinely computable from price bars,
//   including a REALISED rough-volatility forecaster (a fractional power-law kernel fitted to the
//   measured roughness of realised log-vol) and a variance-targeting GARCH(1,1). It still does NOT
//   contain the options-data frontier - the implied rough-Heston surface, options-calibrated
//   fractional-Brownian models or deep-learning forecasters - none of which run on chart OHLC.
//   Even at its best, realised-vol forecasting explains only a MINORITY of realised-vol variance.
//   Treat this as a sharper estimate and a disciplined risk gauge, not a precise or certain forecast.
//
// HOW TO USE
//   * Oscillator 0-100 = where current forecast vol sits in its own history (percentile). Bands:
//     <25 calm, 25-65 normal, 65-90 high, >=90 extreme.
//   * Dotted marker = where YOUR target vol sits in that distribution. Line above the marker = vol
//     above target -> size down; below = room to size up.
//   * Suggested exposure (dashboard) = the vol-target multiplier of equity a LONG would use now
//     (1.0x = 100%). Apply it to your own side. Self-normalising, so the same bands work anywhere.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   The estimators read OHLC, so the engine runs on any instrument and timeframe out of the box.
//   An optional "Analyse symbol" input reroutes the calculation to a different instrument than the
//   one charted. Annualisation is derived from the chart timeframe by default (so the forecast-vol
//   % and the target marker read sensibly on any timeframe), with a manual override available.
//   The India VIX stress gate is OFF by default because it reads an India-specific implied-vol
//   symbol that would mislead on other markets; turn it on only for NIFTY / BANKNIFTY.
//
// CONCEPT CREDIT
//   Volatility estimators - M. Parkinson (1980); Garman & Klass (1980); Rogers & Satchell (1991);
//   Yang & Zhang (2000). HAR forecaster - Fulvio Corsi (2009); measurement-error (HARQ) correction
//   - Bollerslev, Patton & Quaedvlieg (2016). Rough volatility (power-law / fractional kernel) -
//   Gatheral, Jaisson & Rosenbaum (2018); Bennedsen, Lunde & Pakkanen (2022). GARCH(1,1) -
//   Bollerslev (1986); variance targeting - Engle & Mezrich (1996). QLIKE forecast loss - Patton
//   (2011). EWMA / RiskMetrics - J.P. Morgan (1996). Good/bad
//   realised semivariance - Barndorff-Nielsen, Kinnebrock & Shephard; Patton & Sheppard (2015).
//   Path-dependent leverage effect - Julien Guyon & Jordan Lekeufack (2023). Volatility targeting /
//   conditional targeting - Moreira & Muir (2017); Harvey et al. (2018); robustness caveats -
//   Cederburg et al. (2020); Wang & Yan (2021). Assembly, oscillator framing, regime bands and the
//   target marker are the author's own work. Not affiliated with, nor endorsed by, any third party.
//
// HONESTY / LIMITATIONS
//   Estimates from price can be wrong, especially through structural breaks and on low-history
//   symbols. The "suggested exposure" is context for your own risk process, not an instruction, and
//   the research is explicit that full vol-targeting often fails to beat constant exposure out of
//   sample - the keepable part is tail / drawdown reduction, which is why sizing is blended toward
//   constant exposure by default. Nothing here predicts direction or guarantees an outcome.
//
// DISCLAIMER
//   Educational risk-management gauge. NOT financial advice, NOT a signal, and NO guarantee of any
//   outcome. Trading carries risk of loss. Do your own research and manage your own risk. The
//   author accepts no liability for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Volatility Regime Oscillator", "VolRegime", overlay = false, max_bars_back = 1000, max_labels_count = 20, dynamic_requests = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// ── 01 · DATA SOURCE ────────────────────────────────────────────────────────────────────
g0 = "01 · Data source"
calcSym = input.symbol("", "Analyse symbol (blank = chart)", group = g0, tooltip = "Optionally compute the forecast on a DIFFERENT instrument than the one charted. Blank uses the chart symbol, so the script works on any asset out of the box.")

// ── 02 · VOLATILITY FORECAST ────────────────────────────────────────────────────────────
gV = "02 · Volatility forecast"
rvEst   = input.string("Yang-Zhang", "Realised-vol estimator", options = ["Yang-Zhang", "Garman-Klass", "Rogers-Satchell", "Parkinson", "Close-to-close"], group = gV, tooltip = "Yang-Zhang is the most efficient OHLC estimator (handles overnight gaps and drift). Others are simpler; close-to-close is the fallback for rangeless symbols.")
rvLen   = input.int(10, "Realised-vol window", minval = 2, maxval = 100, group = gV, tooltip = "Bars used to measure current realised volatility.")
fcType  = input.string("HAR (multi-horizon)", "Forecaster", options = ["HAR (multi-horizon)", "Rough (fractional-kernel)", "GARCH(1,1)", "EWMA (RiskMetrics)", "SMA (window)", "Auto (best QLIKE)"], group = gV, tooltip = "How per-bar variance becomes a forecast. HAR blends short/medium/long horizons. ROUGH weights the past by a power-law (fractional) kernel whose exponent is the measured roughness of vol - the rough-volatility model. GARCH(1,1) is a mean-reverting recursive-variance model with variance targeting. EWMA decays the past geometrically. SMA is a plain window average. AUTO picks whichever model has the best (lowest) out-of-sample QLIKE on this instrument.")
harMed  = input.int(5,  "HAR medium horizon", minval = 2, maxval = 100, group = gV, tooltip = "Weekly-equivalent horizon for the HAR forecaster.")
harLong = input.int(22, "HAR long horizon", minval = 3, maxval = 300, group = gV, tooltip = "Monthly-equivalent horizon for the HAR forecaster.")
ewmaLam = input.float(0.94, "EWMA lambda", minval = 0.5, maxval = 0.999, step = 0.005, group = gV, tooltip = "RiskMetrics decay. 0.94 is the classic daily value; higher = smoother / slower.")
useCombo = input.bool(true, "Combine estimators & forecasters", group = gV, tooltip = "Forecast combination: average the volatility estimators and the forecasters. Combinations are more robust out-of-sample than any single model.")
useHARQ  = input.bool(true, "HARQ measurement-error correction", group = gV, tooltip = "Realised vol is a noisy estimate and the noise scales with realised quarticity. When the recent reading is noisy, shift weight off the fast term onto slower horizons.")
harqStr  = input.float(0.4, "HARQ correction strength", minval = 0.0, maxval = 1.0, step = 0.05, group = gV)
rghMode  = input.string("Auto (measured)", "Rough-vol roughness (Hurst)", options = ["Auto (measured)", "Manual"], group = gV, tooltip = "Rough-volatility exponent H for the fractional kernel. AUTO measures the roughness of realised log-vol from the scaling of its increments (Gatheral-Jaisson-Rosenbaum); equity vol is typically very rough, H ~ 0.1. Lower H = rougher = more weight on the most recent bars.")
rghH     = input.float(0.10, "Manual roughness H", minval = 0.02, maxval = 0.95, step = 0.01, group = gV, tooltip = "Used only when roughness = Manual. 0.5 reproduces a flat window average; below 0.5 tilts the kernel toward recent bars.")
rghN     = input.int(40, "Rough kernel length", minval = 5, maxval = 200, group = gV, tooltip = "Bars of history the fractional (power-law) kernel spans.")
rghWin   = input.int(120, "Roughness estimation window", minval = 30, maxval = 1000, group = gV, tooltip = "History used to measure the roughness H from the scaling of realised log-vol increments.")
gAlpha   = input.float(0.09, "GARCH alpha (news / ARCH)", minval = 0.0, maxval = 0.5, step = 0.01, group = gV, tooltip = "GARCH(1,1) reaction to the latest squared return. Typical daily equity value ~0.09.")
gBeta    = input.float(0.90, "GARCH beta (persistence)", minval = 0.0, maxval = 0.999, step = 0.01, group = gV, tooltip = "GARCH(1,1) persistence of past variance. alpha+beta must stay below 1 for mean reversion; typical ~0.90.")
garchLR  = input.int(150, "GARCH long-run window", minval = 20, maxval = 1000, group = gV, tooltip = "Window whose mean sets the long-run variance the GARCH recursion targets (variance targeting, Engle-Mezrich).")
usePDV  = input.bool(true, "Path-dependent leverage tilt", group = gV, tooltip = "Lift the forecast after falling paths (leverage effect) -> earlier de-risking into weakness. Takes no side.")
pdvLen  = input.int(20, "Leverage-tilt lookback", minval = 5, maxval = 200, group = gV)
pdvK    = input.float(0.5, "Leverage-tilt strength", minval = 0.0, maxval = 3.0, step = 0.1, group = gV)
annMode = input.string("Auto (from timeframe)", "Annualisation", options = ["Auto (from timeframe)", "Manual (bars/year)"], group = gV, tooltip = "Auto derives the annualisation factor from the chart timeframe (calendar-time) so the forecast-vol % and the target marker read sensibly on ANY timeframe. Manual uses the field below.")
barsYear= input.int(252, "Manual bars per year", minval = 1, group = gV, tooltip = "Used only when Annualisation = Manual. 252 for daily bars; intraday = 252 x bars-per-session.")

// ── 03 · VOLATILITY TARGETING (SUGGESTED SIZE) ──────────────────────────────────────────
gT = "03 · Volatility targeting (suggested size)"
targetVol = input.float(0.15, "Target annual volatility", minval = 0.01, maxval = 1.0, step = 0.01, group = gT, tooltip = "The constant risk level exposure is scaled to. 0.15 = 15% annualised.")
maxLev    = input.float(2.0, "Max leverage (cap)", minval = 0.1, maxval = 10.0, step = 0.1, group = gT)
minLev    = input.float(0.0, "Min leverage (floor)", minval = 0.0, maxval = 5.0, step = 0.1, group = gT)
conditional = input.bool(true, "Conditional targeting (act in extremes)", group = gT, tooltip = "Stay near baseline in normal regimes; scale aggressively only in vol extremes. Cuts turnover, often improves outcomes vs naive targeting.")
blendManaged   = input.float(0.5, "Managed / constant blend", minval = 0.0, maxval = 1.0, step = 0.05, group = gT, tooltip = "Out-of-sample, full vol-targeting often fails to beat constant exposure; a blend toward constant exposure is more robust. 1 = full targeting, 0 = constant, 0.5 = even blend.")
useDownsideVol = input.bool(true, "Scale by downside volatility", group = gT, tooltip = "Downside-volatility scaling is the more robust variant out-of-sample. Tilts sizing toward bad (downside) vol rather than total vol.")

// ── 04 · REGIME DE-RISK ─────────────────────────────────────────────────────────────────
gR = "04 · Regime de-risk"
regLen    = input.int(252, "Regime / percentile window", minval = 20, maxval = 2000, group = gR, tooltip = "History the 0-100 percentile and the target marker are computed over.")
extremePc = input.float(90, "Extreme threshold (percentile)", minval = 60, maxval = 99, group = gR)
extremeFloor = input.float(0.0, "Exposure in Extreme regime", minval = 0.0, maxval = 1.0, step = 0.05, group = gR)
downAmp   = input.float(0.5, "Downside-vol de-risk amplifier", minval = 0.0, maxval = 1.0, step = 0.05, group = gR, tooltip = "De-risk further when vol is downside-driven (bad-vol share high). Character of vol only - no direction.")

// ── 05 · INDIA VIX STRESS GATE (OPTIONAL) ───────────────────────────────────────────────
gX = "05 · India VIX stress gate (optional)"
useVIX   = input.bool(false, "Use India VIX (vol-risk-premium read)", group = gX, tooltip = "De-risk when implied vol is stressed. Volatility-only. India-specific symbol - use only on NIFTY / BANKNIFTY.")
vixSym   = input.symbol("NSE:INDIAVIX", "Implied-vol symbol", group = gX)
vixPc    = input.float(85, "VIX stress threshold (percentile)", minval = 50, maxval = 99, group = gX)
vixFloor = input.float(0.4, "Exposure under VIX stress", minval = 0.0, maxval = 1.0, step = 0.05, group = gX)

// ── 06 · VISUAL STYLE ───────────────────────────────────────────────────────────────────
gS = "06 · Visual style"
visStyle  = input.string("Gradient area + glow", "Line style", options = ["Gradient area + glow","Histogram","Line"], group = gS)
colCalm   = input.color(#2ebd85, "Calm", inline = "c1", group = gS)
colHot    = input.color(#f6465d, "Extreme", inline = "c1", group = gS)
colMid    = input.color(#f7c948, "Midline", group = gS)

// ── 07 · DISPLAY & THEME ────────────────────────────────────────────────────────────────
gD = "07 · Display & theme"
showTarget = input.bool(true, "Show target-vol marker", group = gD)
showPanel  = input.bool(true, "Show dashboard", group = gD)
panelPos   = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)
themeOpt   = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = gD)

// ── 08 · EXPECTED-MOVE ENVELOPE (ON PRICE) ──────────────────────────────────────────────
gB = "08 · Expected-move envelope (on price)"
showBands = input.bool(true, "Draw expected-move bands on price", group = gB, tooltip = "Symmetric volatility envelope on the PRICE chart: centre +/- (forecast vol). Coloured by REGIME, not direction. It shows the SIZE of the likely move (e.g. for stop placement), NOT a target and NOT a buy/sell level.")
bandSrc   = input.string("close", "Envelope centre", options = ["close", "hl2", "ohlc4"], group = gB)
bandK     = input.float(1.0, "Band width (std devs)", minval = 0.25, maxval = 4.0, step = 0.25, group = gB, tooltip = "Standard deviations of the forecast move the bands span. 1 = ~68% of moves, 2 = ~95%.")
bandH     = input.int(1, "Horizon (bars)", minval = 1, maxval = 20, group = gB, tooltip = "Bars ahead the move is scaled to (sqrt-of-time). 1 = next bar.")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    DATA (configurable source)
// ═════════════════════════════════════════════════════════════════════════════════════════
string useSym = calcSym == "" ? syminfo.tickerid : calcSym
[o, h, l, c] = request.security(useSym, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       ADAPTIVE THEME
// ═════════════════════════════════════════════════════════════════════════════════════════
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
bool  uiDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = uiDark ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = uiDark ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = uiDark ? color.white              : color.rgb(16, 20, 24)
color txtSub  = uiDark ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color frameC  = uiDark ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color cCalm  = uiDark ? colCalm : color.rgb(14, 124, 90)
color cWarn  = uiDark ? #f0b24a : #d68a17
color cHot   = uiDark ? colHot  : color.rgb(198, 40, 40)
f_txtOn(color cc) => f_lum(cc) > 140 ? color.rgb(10, 10, 10) : color.white

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              PER-BAR VARIANCE  (selected estimator)
// ═════════════════════════════════════════════════════════════════════════════════════════
float ret  = nz(math.log(c / c[1]))
float lHL  = math.log(h / l)
float lCO  = math.log(c / o)
float rsB  = math.log(h / c) * math.log(h / o) + math.log(l / c) * math.log(l / o)
bool  rngOK = h > l and o > 0

float parkV = (1.0 / (4.0 * math.log(2.0))) * lHL * lHL
float gkV   = 0.5 * lHL * lHL - (2.0 * math.log(2.0) - 1.0) * lCO * lCO
float ctcV  = ret * ret

float oTerm = math.log(o / c[1])
float cTerm = lCO
float biasN = rvLen / math.max(rvLen - 1.0, 1.0)
float Vo    = ta.variance(oTerm, rvLen) * biasN
float Vc    = ta.variance(cTerm, rvLen) * biasN
float Vrs   = ta.sma(rsB, rvLen)
float kYZ   = 0.34 / (1.34 + (rvLen + 1.0) / math.max(rvLen - 1.0, 1.0))
float yzV   = math.max(nz(Vo) + kYZ * nz(Vc) + (1.0 - kYZ) * nz(Vrs), 0.0)

float varBar = rvEst == "Yang-Zhang"      ? yzV :
   rvEst == "Garman-Klass"    ? math.max(nz(gkV), 0.0) :
   rvEst == "Rogers-Satchell" ? math.max(nz(rsB), 0.0) :
   rvEst == "Parkinson"       ? math.max(nz(parkV), 0.0) : ctcV
if not rngOK
    varBar := ctcV
float comboVar = rngOK ? (yzV + math.max(nz(gkV), 0.0) + math.max(nz(rsB), 0.0) + math.max(nz(parkV), 0.0)) / 4.0 : ctcV
if useCombo
    varBar := comboVar

// ═════════════════════════════════════════════════════════════════════════════════════════
//              ROUGHNESS OF VOLATILITY  (Hurst of realised log-vol, from moment scaling)
// ═════════════════════════════════════════════════════════════════════════════════════════
// Rough-volatility signature: E[(log sigma_{t} - log sigma_{t-d})^2] ~ d^(2H). Regress
// log m2(d) on log d across d = 1/2/4/8; slope / 2 = H. Equity vol is typically rough (H<<0.5).
float logRV = 0.5 * math.log(math.max(varBar, 1e-12))
float dv1 = logRV - logRV[1]
float dv2 = logRV - logRV[2]
float dv4 = logRV - logRV[4]
float dv8 = logRV - logRV[8]
float m2d1 = ta.sma(dv1 * dv1, rghWin)
float m2d2 = ta.sma(dv2 * dv2, rghWin)
float m2d4 = ta.sma(dv4 * dv4, rghWin)
float m2d8 = ta.sma(dv8 * dv8, rghWin)
bool  mOK  = m2d1 > 0 and m2d2 > 0 and m2d4 > 0 and m2d8 > 0
// least-squares slope of y=log(m2) on x=log(d); x for d=1,2,4,8 has mean 1.03972, Sxx = 2.40227
float xbar = 1.03972
float sxx  = 2.40227
float ybar = mOK ? (math.log(m2d1) + math.log(m2d2) + math.log(m2d4) + math.log(m2d8)) / 4.0 : na
float sxy  = mOK ? (0.0 - xbar) * (math.log(m2d1) - ybar) + (0.693147 - xbar) * (math.log(m2d2) - ybar) + (1.386294 - xbar) * (math.log(m2d4) - ybar) + (2.079442 - xbar) * (math.log(m2d8) - ybar) : na
float Hest = mOK ? math.min(math.max(sxy / sxx / 2.0, 0.02), 0.95) : na
float Hused = rghMode == "Manual" ? rghH : nz(Hest, 0.10)

// ═════════════════════════════════════════════════════════════════════════════════════════
//        FORECASTER  (HAR · rough fractional-kernel · GARCH(1,1) · EWMA · SMA · auto)
// ═════════════════════════════════════════════════════════════════════════════════════════
float smaShort = ta.sma(varBar, rvLen)
float smaMed   = ta.sma(varBar, harMed)
float smaLong  = ta.sma(varBar, harLong)
float rq      = ta.sma(math.pow(ret, 4.0), rvLen)
float rqRoot  = math.sqrt(math.max(nz(rq), 0.0))
float rqSma   = ta.sma(rqRoot, regLen)
float rqStd   = ta.stdev(rqRoot, regLen)
float rqZ     = (rqRoot - rqSma) / math.max(rqStd, 1e-12)
float shrink  = useHARQ ? math.min(math.max(1.0 - harqStr * math.max(nz(rqZ), 0.0), 0.2), 1.0) : 1.0
float wShort  = 0.5 * shrink
float wRem    = 0.5 - wShort
float wMed    = 0.3 + wRem * 0.6
float wLong   = 0.2 + wRem * 0.4
float harVar  = wShort * smaShort + wMed * smaMed + wLong * smaLong

var float ewmaV = na
ewmaV := na(ewmaV[1]) ? varBar : ewmaLam * nz(ewmaV[1]) + (1.0 - ewmaLam) * varBar

// ROUGH forecaster: power-law (fractional) kernel w_k ~ (k+1)^(H-0.5), normalised. H<0.5 (rough)
// concentrates weight on the most recent bars; H=0.5 reproduces a flat window mean.
float rghSum = 0.0
float rghW   = 0.0
for k = 0 to rghN - 1
    float wk = math.pow(k + 1.0, Hused - 0.5)
    rghSum += wk * nz(varBar[k])
    rghW   += wk
float roughVar = rghW > 0.0 ? rghSum / rghW : varBar

// GARCH(1,1) with variance targeting: sigma2_t = omega + alpha*ret2_{t-1} + beta*sigma2_{t-1},
// omega = (1 - alpha - beta) * long-run variance (Engle-Mezrich). Mean-reverting when alpha+beta<1.
float lrVar   = ta.sma(ctcV, garchLR)
float gPers   = math.min(gAlpha + gBeta, 0.999)
float gOmega  = math.max(1.0 - gPers, 0.001) * nz(lrVar)
var float garchV = na
garchV := na(garchV[1]) ? nz(varBar) : gOmega + gAlpha * nz(ctcV[1]) + gBeta * nz(garchV[1])

// per-model out-of-sample QLIKE horse-race (lower = better forecast of realised variance)
f_ql(float fPrev, float rv) => (not na(fPrev) and fPrev > 0.0 and rv > 0.0) ? rv / fPrev - math.log(rv / fPrev) - 1.0 : na
float rvNow0 = varBar
float qHar   = ta.sma(f_ql(harVar[1],   rvNow0), regLen)
float qRgh   = ta.sma(f_ql(roughVar[1], rvNow0), regLen)
float qGar   = ta.sma(f_ql(garchV[1],   rvNow0), regLen)
float qEwm   = ta.sma(f_ql(ewmaV[1],    rvNow0), regLen)
float qSmaM  = ta.sma(f_ql(smaShort[1], rvNow0), regLen)
float qBest = qHar
int   mBest = 0
if not na(qRgh) and (na(qBest) or qRgh < qBest)
    qBest := qRgh
    mBest := 1
if not na(qGar) and (na(qBest) or qGar < qBest)
    qBest := qGar
    mBest := 2
if not na(qEwm) and (na(qBest) or qEwm < qBest)
    qBest := qEwm
    mBest := 3
if not na(qSmaM) and (na(qBest) or qSmaM < qBest)
    qBest := qSmaM
    mBest := 4
string modName = mBest == 1 ? "Rough" : mBest == 2 ? "GARCH" : mBest == 3 ? "EWMA" : mBest == 4 ? "SMA" : "HAR"
float autoVar  = mBest == 1 ? roughVar : mBest == 2 ? garchV : mBest == 3 ? ewmaV : mBest == 4 ? smaShort : harVar

float fcVar = fcType == "Rough (fractional-kernel)" ? roughVar :
   fcType == "GARCH(1,1)"        ? garchV :
   fcType == "EWMA (RiskMetrics)" ? ewmaV :
   fcType == "SMA (window)"      ? smaShort :
   fcType == "Auto (best QLIKE)" ? autoVar : harVar
if useCombo
    fcVar := (harVar + roughVar + garchV + ewmaV + smaShort) / 5.0
float volF0 = math.sqrt(math.max(nz(fcVar), 0.0))

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  CHARACTER  (semivariance · vol-of-vol) and PATH-DEPENDENT TILT
// ═════════════════════════════════════════════════════════════════════════════════════════
float upVar  = ta.sma(math.pow(math.max(ret, 0.0), 2.0), rvLen)
float dnVar  = ta.sma(math.pow(math.min(ret, 0.0), 2.0), rvLen)
float badShare = (upVar + dnVar) > 0 ? dnVar / (upVar + dnVar) : 0.5

float rLag    = nz(ret[1])
float pathR1  = ta.ema(rLag, pdvLen)
float levTilt = usePDV ? 1.0 + pdvK * math.max(-pathR1, 0.0) / math.max(volF0, 1e-9) : 1.0
float volF    = math.max(volF0 * levTilt, 1e-9)

float barSec = timeframe.in_seconds()
float effBarsYear = (annMode == "Manual (bars/year)" or barSec <= 0) ? barsYear : 31557600.0 / barSec
float af     = math.sqrt(effBarsYear)
float volAnn = volF * af

// ===== QLIKE forecast scoring + skill vs naive =====
float rvNow   = varBar
float fcPrev  = fcVar[1]
float qlikeBar = (not na(fcPrev) and fcPrev > 0 and rvNow > 0) ? rvNow / fcPrev - math.log(rvNow / fcPrev) - 1.0 : na
float qlike    = ta.sma(qlikeBar, regLen)
float fcNaive  = nz(varBar[1])
float qlikeNb  = (fcNaive > 0 and rvNow > 0) ? rvNow / fcNaive - math.log(rvNow / fcNaive) - 1.0 : na
float qlikeNaive = ta.sma(qlikeNb, regLen)
float fcSkill  = (not na(qlike) and not na(qlikeNaive) and qlikeNaive > 0) ? 1.0 - qlike / qlikeNaive : na
float volSma = ta.sma(volAnn, regLen)
float volStd = ta.stdev(volAnn, regLen)
float volVov = volStd / math.max(volSma, 1e-9)

float volShortAnn = math.sqrt(math.max(nz(smaShort), 0.0)) * af
float volLongAnn  = math.sqrt(math.max(nz(smaLong),  0.0)) * af
float vtsSlope    = volLongAnn > 1e-9 ? volShortAnn / volLongAnn - 1.0 : 0.0
string vtsWord    = vtsSlope > 0.05 ? "backwardation (stress)" : vtsSlope < -0.05 ? "contango (calm)" : "flat"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       OSCILLATOR  (percentile) + REGIME + TARGET MARKER
// ═════════════════════════════════════════════════════════════════════════════════════════
float volPct  = ta.percentrank(volAnn, regLen)
string regime = volPct >= extremePc ? "Extreme" : volPct >= 65 ? "High" : volPct >= 25 ? "Normal" : "Low"
color  regCol = volPct >= extremePc ? cHot : volPct >= 65 ? cWarn : volPct >= 25 ? txtMain : cCalm
float targetPct = 100.0 * ta.sma(volAnn <= targetVol ? 1.0 : 0.0, regLen)
bool ready = bar_index > math.max(math.max(regLen, harLong), pdvLen) and volAnn > 0 and not na(volPct)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       SUGGESTED EXPOSURE  (vol targeting -> multiplier)
// ═════════════════════════════════════════════════════════════════════════════════════════
float sizeVolAnn = volAnn * (useDownsideVol ? (0.5 + badShare) : 1.0)
float rawLev = targetVol / math.max(sizeVolAnn, 1e-9)
float levT   = math.min(math.max(rawLev, minLev), maxLev)
if conditional and volPct > 25 and volPct < 75
    levT := math.min(levT, math.max(1.0, minLev))
float lev = blendManaged * levT + (1.0 - blendManaged) * 1.0

float ivRaw  = request.security(vixSym, timeframe.period, close, lookahead = barmerge.lookahead_off)
bool  ivOK   = useVIX and not na(ivRaw)
float ivAnn    = ivOK ? ivRaw / 100.0 : na

// ===== implied-vol predictor blend (shrinkage) =====
ivBlendWt = input.float(0.3, "Implied-vol blend weight", minval = 0.0, maxval = 1.0, step = 0.05, group = "Z2 · Advanced")
float volBlend = (ivOK and not na(ivAnn)) ? (1.0 - ivBlendWt) * volAnn + ivBlendWt * ivAnn : volAnn
float ivPctRaw = ta.percentrank(nz(ivAnn), regLen)
float ivPct    = ivOK ? ivPctRaw : na
bool  vixStress = ivOK and not na(ivPct) and ivPct >= vixPc

float expFactor = 1.0
if regime == "Extreme"
    expFactor := extremeFloor
expFactor := expFactor * (1.0 - downAmp * math.max(badShare - 0.5, 0.0) * 2.0)
if vixStress
    expFactor := math.min(expFactor, vixFloor)
expFactor := math.max(expFactor, 0.0)
float expReco = ready ? lev * expFactor : na
float expRaw  = ready ? levT * expFactor : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// reference lines + house yellow midline at 50
hline(extremePc, "Extreme", color = color.new(colHot, 45), linestyle = hline.style_dashed)
hline(65, "High", color = color.new(#e0922e, 55), linestyle = hline.style_dotted)
plot(50.0, "Mid glow", color = color.new(colMid, 80), linewidth = 6, display = display.pane)
hline(50, "Mid", color = color.new(colMid, 0), linestyle = hline.style_solid)
hline(25, "Calm", color = color.new(colCalm, 55), linestyle = hline.style_dotted)

// gradient regime zones - red brightening toward the extreme top, green toward the calm bottom
pHiEdge = plot(65.0,  "z hi edge",  color = na, display = display.none, editable = false)
pTop    = plot(100.0, "z top",      color = na, display = display.none, editable = false)
pLoEdge = plot(25.0,  "z lo edge",  color = na, display = display.none, editable = false)
pBot    = plot(0.0,   "z bot",      color = na, display = display.none, editable = false)
fill(pHiEdge, pTop, 100.0, 65.0, color.new(cHot, 30),  color.new(cHot, 92),  title = "High/Extreme zone")
fill(pLoEdge, pBot, 25.0,  0.0,  color.new(cCalm, 92), color.new(cCalm, 30), title = "Calm zone")

// the oscillator line - 3-layer glow / histogram / area, per style selector
bool isArea = visStyle == "Gradient area + glow"
bool isHist = visStyle == "Histogram"
bool isLine = visStyle == "Line"
bool showLine = isArea or isLine
plot(showLine and ready ? volPct : na, "glow outer", color = color.new(regCol, 82), linewidth = 8, display = display.pane)
plot(showLine and ready ? volPct : na, "glow inner", color = color.new(regCol, 55), linewidth = 4, display = display.pane)
pMain = plot(showLine and ready ? volPct : na, "Vol percentile", color = color.new(regCol, 0), linewidth = 2, display = display.pane)
plot(isHist and ready ? volPct : na, "Histogram", color = color.new(regCol, 25), style = plot.style_columns, display = display.pane)
pBase = plot(isArea and ready ? 50.0 : na, "area base", color = na, display = display.none, editable = false)
fill(pMain, pBase, color = isArea ? color.new(regCol, 80) : na, title = "Area")

plot(showTarget and ready ? targetPct : na, "Target marker", color = color.new(txtMain, 20), linewidth = 1, style = plot.style_cross, display = display.pane)

// data-window exports (the actionable / underlying numbers)
plot(ready ? volAnn * 100.0 : na, "Forecast vol % (ann)",       display = display.data_window)
plot(expReco,                     "Suggested exposure x",        display = display.data_window)
plot(ready ? expReco * 100.0 : na,"Suggested exposure %",        display = display.data_window)
plot(ready ? badShare * 100.0 : na,"Bad-vol share %",            display = display.data_window)
plot(ready ? volVov : na,         "Vol-of-vol (stability)",      display = display.data_window)
plot(ivOK ? ivAnn * 100.0 : na,   "India VIX %",                 display = display.data_window)
plot(ready ? expRaw : na,         "Exposure full-target x",      display = display.data_window)
plot(ready ? vtsSlope * 100.0 : na,"Vol term-structure slope %", display = display.data_window)
plot(ready ? shrink : na,         "HARQ weight (1=full)",        display = display.data_window)

// expected-move envelope on the PRICE chart (optional) - symmetric, regime-coloured, magnitude only
float bandCenter = bandSrc == "hl2" ? (h + l) / 2.0 : bandSrc == "ohlc4" ? (o + h + l + c) / 4.0 : c
float moveFrac   = volF * bandK * math.sqrt(bandH)
float bandUp = (showBands and ready) ? bandCenter * (1.0 + moveFrac) : na
float bandLo = (showBands and ready) ? bandCenter * (1.0 - moveFrac) : na
pBU = plot(bandUp, "Expected move +", color = color.new(regCol, 25), linewidth = 1, force_overlay = true)
pBL = plot(bandLo, "Expected move -", color = color.new(regCol, 25), linewidth = 1, force_overlay = true)
fill(pBU, pBL, color = showBands ? color.new(regCol, 90) : na, title = "Expected-move zone")

var label emLab = na
if showBands and ready and barstate.islast
    if not na(emLab)
        label.delete(emLab)
    emLab := label.new(bar_index, bandUp, "Exp. +/-" + str.tostring(moveFrac * 100.0, "#.#") + "%  ·  " + regime + " (not a target)", style = label.style_label_down, color = color.new(regCol, 20), textcolor = f_txtOn(regCol), size = size.small, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              DASHBOARD  (theme-adaptive zebra)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right
var table dash = table.new(f_pos(panelPos), 2, 14, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color vc, color rbg) =>
    table.cell(dash, 0, r, k, text_color = txtSub,  text_size = size.small, text_halign = text.align_left,  bgcolor = rbg)
    table.cell(dash, 1, r, v, text_color = vc,      text_size = size.small, text_halign = text.align_right, bgcolor = rbg)

if barstate.islast and showPanel
    table.set_bgcolor(dash, panelBg)
    table.set_frame_color(dash, frameC)
    table.set_border_color(dash, frameC)
    color hdr = color.new(regCol, 0)
    table.cell(dash, 0, 0, "VOLATILITY REGIME", text_color = f_txtOn(hdr), bgcolor = hdr, text_size = size.small)
    table.cell(dash, 1, 0, ready ? (regime + " " + str.tostring(math.round(volPct)) + "%ile") : "warming up", text_color = f_txtOn(hdr), bgcolor = hdr, text_size = size.small)
    f_row(1, "Forecast vol (ann)", ready ? str.tostring(volAnn * 100.0, "#.#") + "%" : "-", txtMain, rowAlt)
    f_row(2, "Target vol", str.tostring(targetVol * 100.0, "#.#") + "%  (" + (ready ? str.tostring(math.round(targetPct)) + "%ile)" : "-)"), txtMain, panelBg)
    f_row(3, "Suggested exposure", ready ? str.tostring(expReco, "#.##") + "x  (blend " + str.tostring(math.round(blendManaged * 100.0)) + "%)" : "-", expReco >= 1.0 ? cCalm : cWarn, rowAlt)
    f_row(4, "Vol character", ready ? (badShare > 0.55 ? "downside-driven" : badShare < 0.45 ? "upside-driven" : "balanced") : "-", badShare > 0.55 ? cHot : txtMain, panelBg)
    f_row(5, "Term structure", ready ? vtsWord : "-", vtsSlope > 0.05 ? cHot : vtsSlope < -0.05 ? cCalm : txtMain, rowAlt)
    f_row(6, "Stability (vol-of-vol)", ready ? str.tostring(volVov, "#.##") : "-", txtMain, panelBg)
    f_row(7, "India VIX", ivOK ? str.tostring(ivAnn * 100.0, "#.#") + "%" + (vixStress ? "  STRESS" : "") : "off", vixStress ? cHot : txtSub, rowAlt)
    f_row(8, "Note", "tail-reduction context, not alpha", txtSub, panelBg)
    f_row(9, "Forecast skill", na(fcSkill) ? "-" : str.tostring(fcSkill * 100.0, "#") + "% vs naive", na(fcSkill) ? txtSub : fcSkill > 0 ? cCalm : cHot, rowAlt)
    f_row(10, "QLIKE (lower=better)", na(qlike) ? "-" : str.tostring(qlike, "0.00"), txtMain, panelBg)
    f_row(11, "Vol roughness (H)", (ready and not na(Hest)) ? str.tostring(Hest, "0.00") + (Hest < 0.2 ? "  very rough" : Hest < 0.4 ? "  rough" : "  smooth") : "-", (not na(Hest) and Hest < 0.2) ? cHot : txtMain, rowAlt)
    f_row(12, "Best forecaster", (ready and not na(qBest)) ? modName + "  (QLIKE " + str.tostring(qBest, "0.00") + ")" : "-", cCalm, panelBg)
    f_row(13, "Implied blend", (ivOK and not na(volBlend)) ? str.tostring(volBlend * 100.0, "#.#") + "%" : "off", txtMain, rowAlt)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
bool xExtreme = ta.crossover(volPct, extremePc)
bool xCalm    = ta.crossunder(volPct, 25.0)
bool xTarget  = ta.crossover(volPct, targetPct)

// ===== IDENTITY STRIP  (name, symbol, timeframe) =====
showId = input.bool(true, "Show identity strip (name, symbol, timeframe)", group = "Z · Identity & exports")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if showId and barstate.islast
    color bgI  = chart.bg_color
    float lumI = na(bgI) ? 0.0 : color.r(bgI) * 0.299 + color.g(bgI) * 0.587 + color.b(bgI) * 0.114
    bool  dkI  = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgI) or lumI < 140)
    table.cell(idT, 0, 0, "Volatility Regime Oscillator   -   " + syminfo.ticker + "   -   " + timeframe.period, text_color = dkI ? color.new(#c8d0da, 10) : color.new(#2a2f37, 10), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ===== EXP_* EXPORTS  (Data Window, generic names for input.source) =====
showEXP = input.bool(true, "Emit EXP_* exports", group = "Z · Identity & exports")
color exC_ = color.new(color.gray, 100)
plot(showEXP ? (volPct) : na, "EXP_VolPct", color = exC_, display = display.data_window)
plot(showEXP ? (volAnn * 100.0) : na, "EXP_VolAnnPct", color = exC_, display = display.data_window)
plot(showEXP ? (expReco) : na, "EXP_Exposure", color = exC_, display = display.data_window)
plot(showEXP ? (badShare * 100.0) : na, "EXP_BadShare", color = exC_, display = display.data_window)
plot(showEXP ? (volVov) : na, "EXP_VoV", color = exC_, display = display.data_window)
plot(showEXP ? (volPct >= extremePc ? 2 : volPct >= 65 ? 1 : volPct >= 25 ? 0 : -1) : na, "EXP_Regime", color = exC_, display = display.data_window)
plot(showEXP ? (ready ? 1 : 0) : na, "EXP_DataLive", color = exC_, display = display.data_window)

plot(showEXP ? (qlike) : na, "EXP_QLIKE", color = exC_, display = display.data_window)
plot(showEXP ? (fcSkill * 100.0) : na, "EXP_ForecastSkill", color = exC_, display = display.data_window)
plot(showEXP ? (volBlend * 100.0) : na, "EXP_VolBlend", color = exC_, display = display.data_window)
plot(showEXP ? (Hest) : na, "EXP_VolH", color = exC_, display = display.data_window)
plot(showEXP ? (math.sqrt(math.max(nz(garchV), 0.0)) * af * 100.0) : na, "EXP_GarchVolPct", color = exC_, display = display.data_window)
plot(showEXP ? (float(mBest)) : na, "EXP_BestModel", color = exC_, display = display.data_window)
alertcondition(xExtreme, "Entered extreme volatility", "VolRegime: extreme volatility - reduce size")
alertcondition(xCalm,    "Entered calm volatility",    "VolRegime: calm volatility - room to size up")
alertcondition(xTarget,  "Vol crossed above target",   "VolRegime: forecast vol above target - size down")
````
