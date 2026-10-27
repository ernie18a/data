# Vol Regime Compass [N4]

- url: https://www.tradingview.com/script/Df0C3ubO-Vol-Regime-Compass-N4/
- type: indicator
- pine_id: PUB;1f1230d355084193971d27e5071db123
- version: 2.0

## Description

[b]Vol Regime Compass [N4][/b]
[i]verb · size · regime — three words a week[/i]

A volatility-regime indicator for swing and position traders that converts each asset's own 252-day vol distribution into a verb (BUY+/BUY/REDUCE/WAIT/OBSERVE) and a sizing % (25-200%) — so DCA execution becomes a 5-second decision, not an open question.

[image]https://www.tradingview.com/x/qSoi39GI/[/image]

[b]The 5-second HUD[/b]

Every Monday morning you open the chart. You see three words:

[code]Verb     buy
Size     125%
Regime   NORMAL[/code]

[b]Verb[/b] = the action. Do it.
[b]Size %[/b] = what fraction of your base DCA this week.
[b]Regime[/b] = why the verb says what it says.

Everything else is diagnostic, off by default.

[b]Five verbs. Five size bands. No dissonance.[/b]

[list]
[*]BUY+ (125-200%): low vol or post-crash exit
[*]BUY (75-125%): normal vol
[*]REDUCE (50-100%): elevated vol
[*]WAIT (25-50%): extreme vol or Critical Slowing detected
[*]OBSERVE (0%): insufficient data
[/list]

Why WAIT and never SKIP — Taleb's rule: in markets with asymmetric upside, never go to zero. Size down, don't size zero.

[image]https://www.tradingview.com/x/UQK5oJr3/[/image]

[b]What makes it different[/b]

[b]1. Asset-relative percentile, not fixed thresholds.[/b] BTC, NASDAQ, gold, copper — completely different vol distributions. A "vol > 2.0" threshold works on one asset and fails on another. Vol Regime Compass uses percentile rank against the asset's own 252-day vol history. Scale-free, transferable across assets without re-tuning.

[b]2. Critical Slowing Down detection (Scheffer et al., Nature 2009).[/b] Before a regime change, three things rise together: variance, autocorrelation, and vol-of-vol. Sum z-scores; when sum > 2, the system is at a phase-transition boundary, and the indicator dampens sizing toward 1×. Real statistical physics.

[b]3. Multi-timeframe coupling.[/b] The score combines vol percent-rank across D, W, M timeframes. Coherence or hesitation — the indicator decides.

[b]4. Theta extremal-index (Beirlant 2004 EVT).[/b] Counts clusters of extreme returns, not individual events. θ→1 = independent (coherent). θ→0 = clustered (stressed). Amplification θ^ν with ν=3 validated in parameter sweep.

[b]5. 2×2 regime overlay (trend × vol).[/b] bull-quiet, bull-noisy, bear-quiet, bear-noisy — each multiplies sizing. Bull-quiet accumulates. Bear-noisy survives.

[b]6. Gold anchor.[/b] XAU / XAUT / GOLD get +15% conviction to activate.

[image]https://www.tradingview.com/x/spKwTNKM/[/image]

[b]7. The cloud IS the math.[/b] Cloud between price and SMA200 has direction (color) and density (alpha). High conviction = dense. Low = ghost. User-editable colors (default coral #F4A261 + lilac #E5DCEF).

[b]Honest backtest data[/b]

Single-asset BTC walk-forward, 8.5 years (3,107 daily bars):

[code]Strategy           Sharpe   Per-$    Max DD
Buy & Hold (lump)  0.33     15.76×   -76.6%
Naive DCA          1.08     4.300×   -74.4%
v7 vol-adjusted    1.02     4.305×   -74.6%[/code]

Per-dollar edge over naive DCA: +0.13% — statistically zero. The backtest tells the truth. This is NOT an alpha engine on a single asset.

[b]What it DOES deliver (single-asset):[/b]

[list=1]
[*]Behavioral discipline — the verb removes weekly indecision
[*]Capital efficiency on a fixed budget — distributes $X/week toward low-vol weeks
[*]Regime awareness — you know when not to discretionarily increase
[/list]

[b]Where the multi-asset V6c production strategy DOES show edge[/b]

22-asset rotation, purged combinatorial cross-validation (CPCV 15/15) + Deflated Sharpe Ratio correction (Bailey & López de Prado 2014) for K=130 research runs:

[code]OOS Sharpe:        1.964
DSR_ann:           +0.524
Bootstrap CI lo:   +0.806
COVID 2020 stress: -0.894 (clears -1.0 floor)
2026 H1 OOS:       +0.81
μ / σ annual:      24.01% / 12.24%[/code]

[image]https://www.tradingview.com/x/8696vWjD/[/image]

[b]Stress windows the system still fails (transparent)[/b]

[list]
[*]COVID 2020: Sharpe -0.894 (clears -1.0 by 0.11, single observation, brittle)
[*]Crypto Winter 2022: Sharpe +0.09 (extended crypto bear flips negative)
[*]Gold-reversal: a 20%+ XAUT drawdown in live OOS turns the 85% neutral floor into a concentration killer
[/list]

The system tells the truth about its limits. You operate knowing them.

[b]How to read in 3 steps[/b]

[list=1]
[*]Verb first. Do what it says.
[*]Size second. Multiply your base DCA by the %.
[*]Everything else is diagnostic — open the drawer only if you want to understand WHY.
[/list]

[b]For whom[/b]

Solo operator running weekly/monthly DCA on a handful of assets. Bilingual ES/EN. Wants discipline over magic. Reads statistical physics + ergodicity economics (Peters 2019 Nature Physics) without panic.

[b]NOT for whom[/b]

Looking for directional buy/sell signals (this isn't a signal generator). Want discretionary alpha without work (the verb augments judgment, doesn't replace). Intraday trader (this is daily horizon).

[b]Frequently Asked[/b]

[b]Is this a trading signal indicator?[/b] No. Regime + sizing only. It tells you what regime an asset is in and what fraction of your DCA to deploy.

[b]Does it work on stocks, crypto, forex, metals, indices?[/b] Yes — by design. Asset-relative percentile makes regime classification scale-free. Validated on BTC, ETH, XAUT, NAS100, UK100, GER40, FRA40, gold, silver, platinum, copper, equities.

[b]What's the best timeframe?[/b] Daily. Weekly works for slower operators. Sub-daily out of scope.

[b]Does it predict price direction?[/b] No. Regime classification only.

[b]How was it validated?[/b] Walk-forward backtest with purged combinatorial cross-validation, 130 research runs, Deflated Sharpe Ratio correction, three stress-window evaluations.

[b]How is it different from typical vol regime indicators?[/b] Most use ATR z-score or percentile. This adds Critical Slowing Down detection (Scheffer 2009 statistical physics) + extremal-index theta + multi-timeframe coupling + 5 verbs with size bands. Classifies + orients.

[b]Methodology references[/b]

[list]
[*]Critical Slowing Down: Scheffer M. et al. Nature 461, 53-59 (2009)
[*]Ergodicity: Peters O. Nature Physics 15, 1216-1221 (2019)
[*]Extremal index: Beirlant J. et al. Statistics of Extremes, Wiley (2004)
[*]Asymmetric upside: Taleb N.N. Antifragile (2012)
[*]Walk-forward + DSR: Bailey D., López de Prado M. JPM 40(5) 2014
[*]Purged combinatorial cross-validation: López de Prado, Advances in Financial ML (2018)
[*]Covariance shrinkage: Ledoit O., Wolf M. JMA 88(2) 2004
[/list]

[b]Disclaimer[/b]

Educational content. NOT financial advice. Past performance does not guarantee future results. The operator is responsible for decisions, sizing, and risk. The indicator gives multipliers — you decide the amount. Test on demo first.

[b]Author[/b]

N — psychologist + HR Transformation specialist. Personal V6c system 2025-2026, walk-forward validated 130 runs with deflated Sharpe correction. Pine v6 native. Bilingual ES/EN.

Following González over Kundera: the scar is carried legibly.

## Source Code

````pine
// Vol Regime Compass [N4] (two-color, user-editable, bilingual)
//
// v11 — 2026-05-04. Non-repaint correctness pass + bilingual toggle.
//   • request.security on D/W/M now uses [1] offset + lookahead_on per
//     PineCoders canonical idiom. Prior versions repainted the realtime bar
//     of the lower TF when the higher-TF current bar was still in progress.
//   • ta.percentile_linear_interpolation → ta.percentile_nearest_rank for
//     the 252-bar windows. Nearest-rank is the recommended algorithm above
//     ~100 lookback (Pine v6 profiling-and-optimization guidance) and frees
//     headroom against the RE10139 memory budget for any future HTF tuples.
//   • New input: Idioma / Language (es | en). Deck labels and verb display
//     toggle. ES default preserves prior behavior.
//
// Reduction pass 2026-04-20. User-edit pass + two-color system.
// The cloud IS the math. The cloud's alpha IS conviction.
//
// What you see:
//   1. CANDLES — default price, untouched.
//   2. SMA200 GLOW — triple-layered primary color (outer→inner→core).
//   3. TREND CLOUD — fills between price and SMA200.
//      · Color: primary when price > SMA200 (bullish); secondary otherwise.
//      · Alpha: modulated by conviction. High conv → dense. Low conv → ghost.
//      This is the one math visualization.
//   4. FLOATING DECK — cream paper card, always light, matches cockpit.
//
// User-editable (inputs):
//   · Color primary  (default #F4A261 coral)   — bullish cloud, ACT verb, SMA glow
//   · Color secondary (default #E5DCEF lilac)  — bearish cloud, HOLD verb
//   · Idioma / Language (es | en)              — deck labels + verb display
//
// Pine vs Python cockpit — the contract:
//   Pine conv = time-series rank of THIS asset's score vs its own 252d history
//   Python conv = cross-sectional rank among 24 basket members today
//
// Verbs: act / hold / wait / observe (en). comprar / mantener / esperar / observar (es).
// Pine v6, compile-verified via TradingView CDP.

//@version=6
indicator("Vol Regime Compass [N4]", overlay=true, precision=0)

// ── Inputs ─────────────────────────────────────────────────
volSpan          = input.int(20,   "EWMA vol span",        minval=5,  group="v6c core")
medianLookback   = input.int(252,  "Median/quantile window", minval=50, group="v6c core")
coup_cap_pct     = input.float(0.50, "Winsor cap percentile", minval=0.1, maxval=0.9, step=0.05, group="v6c core")
use_2x2          = input.bool(true,  "2x2 regime",            group="v6c core")
use_gold_anchor  = input.bool(true,  "XAUT gold anchor",      group="v6c core")
nu               = input.float(3.0,  "theta exponent",       minval=0.0, step=0.5, group="v6c core")
sigmoidSteep     = input.float(2.0,  "Sigmoid k",            minval=0.5, step=0.5, group="v6c core")
sizeMin          = input.float(0.25, "Floor (min %)",        minval=0.1, step=0.05, group="v6c core")
sizeMax          = input.float(2.00, "Max %",                minval=1.0, step=0.05, group="v6c core")
tier_min_act     = input.int(75, "Tier ACT threshold (55=A, 65=B, 75=C, 90=D)", minval=35, maxval=99, group="v6c decision")

// Colors — USER EDITABLE
colorPrimary     = input.color(#F4A261, "Color primary (bullish / ACT)", group="colors")
colorSecondary   = input.color(#E5DCEF, "Color secondary (bearish / HOLD)", group="colors")

// Display — minimal
showCloud        = input.bool(true,  "Trend cloud (conviction density)", group="display")
showSMAGlow      = input.bool(true,  "SMA200 glow (triple layer)",       group="display")
showDeck         = input.bool(true,  "Floating deck (paper card)",       group="display")
deckPosition     = input.string("top_right", "Deck position", options=["top_right","bottom_right","top_left","bottom_left"], group="display")
language         = input.string("es", "Idioma / Language", options=["es","en"], group="display")

// ── Deck palette — always light, like cockpit paper ────────
deck_paper = #F5F1E8
deck_ink   = #1B1820
deck_hush  = #8A829A

// ── Primitives ─────────────────────────────────────────────
sigmoid(x, k) => 1.0 / (1.0 + math.exp(k * x))
tanhf(x) => 2.0 / (1.0 + math.exp(-2.0 * x)) - 1.0

logRet = math.log(close / close[1])
absRet = math.abs(logRet)
ewmaVol = ta.ema(absRet, volSpan)
medianVol = ta.percentile_nearest_rank(ewmaVol, medianLookback, 50)
volRatio = nz(ewmaVol / medianVol, 1.0)
pctRank = ta.percentrank(volRatio, medianLookback)
sigInput = (pctRank - 50) / 25.0
sizingRaw = sizeMin + (sizeMax - sizeMin) * sigmoid(sigInput, sigmoidSteep)

sma200 = ta.sma(close, 200)
trendRatio = math.log(close / sma200)
trendFactor = 1.0 + 0.5 * tanhf(trendRatio * 3.0)

_tfExpr() =>
    _lr = math.abs(math.log(close / close[1]))
    _ewma = ta.ema(_lr, volSpan)
    _med = ta.percentile_nearest_rank(_ewma, medianLookback, 50)
    _ratio = nz(_ewma / _med, 1.0)
    ta.percentrank(_ratio, medianLookback)

// v11: non-repaint per PineCoders canonical. [1] offset shifts to the prior
// closed bar; lookahead_on tells the engine the value is intentionally fixed.
// Removing either component reintroduces repaint risk.
rD = request.security(syminfo.tickerid, "D", _tfExpr()[1], lookahead=barmerge.lookahead_on)
rW = request.security(syminfo.tickerid, "W", _tfExpr()[1], lookahead=barmerge.lookahead_on)
rM = request.security(syminfo.tickerid, "M", _tfExpr()[1], lookahead=barmerge.lookahead_on)

tfMean = (rD + rW + rM) / 3.0
couplingStd = not na(rD) and not na(rW) and not na(rM) ? math.sqrt((math.pow(rD - tfMean, 2) + math.pow(rW - tfMean, 2) + math.pow(rM - tfMean, 2)) / 3.0) : na
couplingSq = nz(couplingStd * couplingStd, 100.0)

wCoupRaw = 1.0 / (1e-6 + couplingSq)
wCoupCap = ta.percentile_nearest_rank(wCoupRaw, medianLookback, math.round(coup_cap_pct * 100))
wCoupCapped = math.min(wCoupRaw, wCoupCap)
winsorActive = wCoupRaw > wCoupCap

realizedVol = ta.stdev(logRet, 20)
wVol = 1.0 / (1e-6 + realizedVol)

exceedThresh = ta.percentile_nearest_rank(absRet, medianLookback, 90)
isExceed = absRet > exceedThresh
runStartVal = isExceed and not isExceed[1] ? 1.0 : 0.0
exceedVal = isExceed ? 1.0 : 0.0
runs     = math.sum(runStartVal, medianLookback)
totalExc = math.sum(exceedVal, medianLookback)
thetaExtremal = totalExc > 5 ? math.min(1.0, runs / totalExc) : 0.5
thetaFactor = math.pow(math.max(thetaExtremal, 0.05), nu)

sma50 = ta.sma(close, 50)
avgRet20 = ta.sma(logRet, 20)
bullTrend = sma50 > sma200 and avgRet20 > 0
bearTrend = sma50 < sma200 and avgRet20 < 0
quietVol  = realizedVol < ta.percentile_nearest_rank(realizedVol, medianLookback, 50)
regime_2x2 = bullTrend ? (quietVol ? "bull-quiet" : "bull-noisy") : bearTrend ? (quietVol ? "bear-quiet" : "bear-noisy") : "chop"

regimeMult_2x2 = use_2x2 ? (regime_2x2 == "bull-quiet" ? 1.10 : regime_2x2 == "bull-noisy" ? 0.95 : regime_2x2 == "bear-quiet" ? 1.00 : regime_2x2 == "bear-noisy" ? 0.80 : 1.00) : 1.00

isGoldLike = str.contains(syminfo.ticker, "XAUT") or str.contains(syminfo.ticker, "GOLD") or str.contains(syminfo.ticker, "XAU")
goldFactor = use_gold_anchor and isGoldLike ? 1.15 : 1.00

score = sizingRaw * trendFactor * wCoupCapped * wVol * thetaFactor * regimeMult_2x2 * goldFactor
conviction = math.round(ta.percentrank(score, medianLookback))

marketRegime = thetaExtremal > 0.75 and couplingSq < 0.02 and (regime_2x2 == "bull-quiet" or regime_2x2 == "bull-noisy") ? "COHERENT" : thetaExtremal < 0.5 and couplingSq > 0.05 ? "DISLOCATED" : "STRESSED"

goldActGate = math.max(50, tier_min_act - 15)
verb = marketRegime == "DISLOCATED" ? "WAIT" : (isGoldLike and conviction >= goldActGate) ? "ACT" : conviction >= tier_min_act ? "ACT" : conviction >= math.max(55, tier_min_act - 20) ? "HOLD" : conviction > 0 ? "WAIT" : "OBSERVE"
verbES = verb == "ACT" ? "comprar" : verb == "HOLD" ? "mantener" : verb == "WAIT" ? "esperar" : "observar"

// Two-color verb encoding
verbColor = verb == "ACT" ? colorPrimary : verb == "HOLD" ? colorSecondary : verb == "WAIT" ? color.new(colorPrimary, 55) : deck_hush

// v11: bilingual display values. Source verbs stay UPPERCASE for legibility
// at the math layer; deck display drops to lowercase to match brand register.
isEN = language == "en"
deckHeader     = isEN ? "the kitchen"        : "la cocina"
deckRegimeKey  = isEN ? "regime"             : "régimen"
deckVerbKey    = isEN ? "verb"               : "verbo"
deckConvKey    = isEN ? "conv · solo asset"  : "conv · solo asset"
deckCockpitKey = isEN ? "cockpit.html"       : "cockpit.html"
deckCockpitNote= isEN ? "cross-section rank" : "rank cross-section"

regimeDisplay = isEN ? (marketRegime == "COHERENT" ? "coherent" : marketRegime == "STRESSED" ? "stressed" : "dislocated") : (marketRegime == "COHERENT" ? "coherente" : marketRegime == "STRESSED" ? "estresado" : "dislocado")
verbDisplay   = isEN ? str.lower(verb) : verbES

// ═══════════════════════ OVERLAY — two layers only ═══════════════════════

// 1. SMA200 glow — triple-layered primary (the luxalgo beam)
plot(showSMAGlow ? sma200 : na, title="sma200 outer glow", color=color.new(colorPrimary, 92), linewidth=6)
plot(showSMAGlow ? sma200 : na, title="sma200 inner glow", color=color.new(colorPrimary, 82), linewidth=3)
plot(showSMAGlow ? sma200 : na, title="sma200 core",       color=color.new(colorPrimary, 55), linewidth=1)

// 2. Trend cloud — DIRECTION by color, DENSITY by conviction
cloudBase  = close > sma200 ? colorPrimary : colorSecondary
cloudAlpha = math.max(20, math.round(100.0 - nz(conviction, 0) * 0.8))
cloudColor = color.new(cloudBase, cloudAlpha)
priceGhost = plot(showCloud ? close  : na, title="price anchor",  color=color.new(color.gray, 100), display=display.none)
smaGhost   = plot(showCloud ? sma200 : na, title="sma200 anchor", color=color.new(color.gray, 100), display=display.none)
fill(priceGhost, smaGhost, color=showCloud ? cloudColor : na, title="conviction cloud")

// (ACT dots removed — verb lives in the deck, density lives in the cloud)

// ═══════════════════════ FLOATING DECK — paper card ═══════════════════════
posDeck = deckPosition == "top_right" ? position.top_right : deckPosition == "bottom_right" ? position.bottom_right : deckPosition == "top_left" ? position.top_left : position.bottom_left

if showDeck and barstate.islast
    var table deck = table.new(posDeck, 2, 5, bgcolor=deck_paper, border_color=color.new(deck_hush, 40), border_width=1, frame_color=color.new(deck_hush, 30), frame_width=1)

    table.cell(deck, 0, 0, deckHeader, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 0, syminfo.ticker, text_color=deck_ink, text_size=size.tiny, text_halign=text.align_right)

    table.cell(deck, 0, 1, deckRegimeKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 1, regimeDisplay, text_color=deck_ink, text_size=size.tiny, text_halign=text.align_right)

    table.cell(deck, 0, 2, deckVerbKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 2, verbDisplay, text_color=verbColor, text_size=size.large, text_halign=text.align_right)

    table.cell(deck, 0, 3, deckConvKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 3, str.tostring(conviction), text_color=deck_ink, text_size=size.normal, text_halign=text.align_right)

    table.cell(deck, 0, 4, deckCockpitKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 4, deckCockpitNote, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_right)

// ═══════════════════════ Alerts ═══════════════════════
isMonday = dayofweek == dayofweek.monday
alertcondition(verb == "ACT" and isMonday, "ACT rebalance", "{{ticker}} — ACT Monday, conv {{plot_0}}")
alertcondition(marketRegime == "DISLOCATED", "Market dislocated", "{{ticker}} — market DISLOCATED.")
alertcondition(winsorActive and not winsorActive[1], "Winsor engaged", "{{ticker}} — winsor engaged.")
````
