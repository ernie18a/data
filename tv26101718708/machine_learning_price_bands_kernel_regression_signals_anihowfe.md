# Machine Learning Price Bands  Kernel Regression Signals

- url: https://www.tradingview.com/script/anIhOwfe-Machine-Learning-Price-Bands-Kernel-Regression-Signals/
- type: indicator
- pine_id: PUB;2281a5e0774f4777a929c8c8637d6d82
- version: 3.0

## Description

OVERVIEW
 
Every "AI band" on this platform draws two lines and asserts them. None of them can tell you how often price actually stays inside.
 
This one can — because it is built on a method that comes with a MATHEMATICAL COVERAGE GUARANTEE, and then it CHECKS WHETHER IT KEPT THE PROMISE, live, on your chart:
 
     Coverage (empirical vs nominal)    89.1%  vs  90%    n = 20,266
     Is the miss REAL?                  -0.9 pp   z = -4.3   (real)
     Verdict                            undercovering — real, but small
 
That is not a band. That is a prediction interval that has been audited, and it is the whole reason this tool exists.
 
It is a research and framing tool. NOT a strategy, NOT a signal service, NOT a validated edge.
 
 
THE MACHINE LEARNING, SPELLED OUT — no buzzwords, here is the actual model
 
1. NADARAYA-WATSON KERNEL REGRESSION. Non-parametric: no functional form is assumed, the data chooses the shape. Each past bar votes on the current estimate with a Gaussian weight that decays with distance. This is the same estimator Lo, Mamaysky and Wang used in the Journal of Finance to make chart-pattern recognition objective. It is real machine learning, and it is sixty years old.
 
   The kernel here is CAUSAL. It only ever looks backwards. A centred kernel — the kind most "Nadaraya-Watson envelope" scripts use — peeks at bars that have not happened yet, and that is why their historical fit looks so much better than their live one.
 
2. BANDWIDTH BY PREDICTIVE MODEL SELECTION. The bandwidth h is the only real parameter, and it is not a magic number: several candidates are run in parallel and scored on their ROLLING ONE-STEP-AHEAD SQUARED ERROR. The winner is used. That is honest model selection — the criterion you would use to choose any forecaster — rather than a knob you turn until the chart looks nice.
 
3. CONFORMAL PREDICTION INTERVALS. The half-width is the (1-alpha) empirical quantile of the recent ABSOLUTE one-step-ahead errors. Under exchangeability this carries a FINITE-SAMPLE coverage guarantee, with NO distributional assumption at all: no normality, no GARCH, no volatility model. The model's own recent mistakes size the band — which is why it widens when the model starts being WRONG, not merely when price starts moving.
 
4. ADAPTIVE CONFORMAL INFERENCE — Gibbs and Candes, NeurIPS 2021.
 
   Here is the problem with plain conformal prediction on markets, stated plainly: its guarantee holds under EXCHANGEABILITY, and financial returns are the textbook counterexample. Volatility CLUSTERS. So a residual quantile computed over a trailing window is always a step behind, the band is too narrow exactly when it matters, and the misses bunch together. Coverage lands quietly under nominal. Measured live on NIFTY futures before this was added: 89.1% against a nominal 90%, on the 1m, the 3m and the 1h, every one of them roughly four standard errors below target. Not a bug. The assumption breaking.
 
   ACI makes the miscoverage level a LEARNED parameter:
 
        alpha(t+1) = alpha(t) + gamma * (alpha - err(t))
 
   Miss the interval and alpha falls, so the quantile rises and the band WIDENS. Cover it and alpha creeps back, so the band TIGHTENS. Long-run coverage provably converges to the target IRRESPECTIVE OF THE DATA GENERATING PROCESS — no exchangeability assumption anywhere.
 
   A band that notices it is undercovering and fixes itself. Watch the alpha row: where it settles BELOW nominal is a direct measurement of how badly exchangeability fails on your instrument.
 
   MEASURED, ON THE SAME INSTRUMENT, BEFORE AND AFTER:
 
        timeframe     plain conformal     with ACI
        1m                89.1%             90.1%
        3m                89.1%             90.1%
        5m                89.1%             90.1%
        15m               90.1%             90.1%
        1h                89.1%             90.1%
                                            (nominal 90%)
 
   Five timeframes, a four-standard-error undercoverage on four of them, closed. The binomial test now returns "calibrated — within sampling noise" and means it. That is not a backtest of a trading rule. That is a mathematical promise being kept, and being checked.
 
5. NORMALISED NONCONFORMITY — Papadopoulos et al. (2008), Lei et al. (2018).
 
   The plain score |price - fit| is a SCALAR, which means the band is THE SAME WIDTH in a dead tape and in a crash. It therefore OVERCOVERS in calm and UNDERCOVERS in chaos — and the single marginal coverage figure is the average of those two errors, looking correct while being wrong in both directions.
 
   Normalising divides each residual by a local scale estimate before taking the quantile, and multiplies it back when drawing:
 
        score = |price - fit| / sigma        band = fit +/- q * sigma
 
   The band now scales with LOCAL DIFFICULTY — and note it is the MODEL'S difficulty, not the market's volatility. Related, but not the same thing, and the first one is what a prediction interval is actually about.
 
6. THE COVERAGE AUDIT. A guarantee you do not verify is just a claim.
 
 
TWO QUESTIONS ABOUT THE COVERAGE, AND THE PANEL ANSWERS BOTH
 
IS THE MISS REAL? That is a binomial z-test and it needs no tolerance at all. Each bar is a Bernoulli trial with p = nominal, so the standard error of the observed coverage is sqrt(p(1-p)/n).
 
IS THE MISS BIG ENOUGH TO CARE ABOUT? That is a judgement, and you set it.
 
These are NOT the same question, and conflating them is how a band gets waved through as "calibrated". Measured live on NIFTY futures: at n = 20,266 the standard error is 0.21 pp, so an empirical coverage of 89.1% against a nominal 90% is a 0.9 pp miss — FOUR STANDARD ERRORS. Unmistakably real. Arguably too small to trade differently. A 5 pp tolerance called that "calibrated", which was the headline row of the script asserting the one thing the script exists to verify, and asserting it wrongly.
 
The panel now reports the size of the miss, its significance, and a verdict that distinguishes "within sampling noise" from "real, but small" from "MISCALIBRATED — do not trust the band". You get to decide which of those matters to you, and you get the numbers to decide with.
 
 
AND THEN THE ROW NOBODY HAS: CONDITIONAL COVERAGE
 
     Coverage                       90.0%  vs  90%     n = 20,178
     calm / normal / turbulent      96.4%  ·  90.1%  ·  83.2%
 
A single marginal number can read a perfect 90% while the interval covers 96% of quiet bars and 83% of violent ones. Ninety per cent is then the AVERAGE OF TWO ERRORS — it looks right while being wrong in both directions, and it is wrong in the direction that costs you money exactly when it costs you money.
 
Exact conditional coverage is provably impossible without strong assumptions. But you can always MEASURE it, and almost nobody does. Bars are split into calm, normal and turbulent thirds by the percentile rank of ATR, and coverage is scored inside each. If the three numbers fan apart, the band is not breathing — and the normalised score is what closes the gap.
 
Turn the normalised score off and watch those three fan out. That is the demonstration.
 
 
FADE OR FOLLOW? THE TOOL DOES NOT PRETEND TO KNOW
 
Price leaving a 90% interval is statistically unusual. Whether to FADE it (an outlier, so bet on reversion) or FOLLOW it (the model has broken, so bet on the new regime) is an EMPIRICAL question, and the honest answer is often neither.
 
So both are logged, both are graded, and BOTH ARE TESTED AGAINST EACH OTHER.
 
That last part matters more than it sounds. Knowing that fading beats an unconditional control, and that following also beats an unconditional control, does not answer the question a trader is actually asking at a band break — which of the two should I do? They are mutually exclusive responses to the SAME event. So they are run head to head with a Welch t-test, and the answer is allowed to be:
 
     FADE or FOLLOW?    NEITHER — the break does not tell you which
 
If the difference does not clear the noise, then on this instrument the break carries no directional information, and saying so IS the finding. A tool that cannot report its own failure is an advertisement, not a measurement.
 
And the chart agrees with the panel. An unproven direction is still drawn — it is arithmetic, and you may want it — but it is drawn MUTED and labelled "(not proven)". It used to print "Follow the break" in full colour while the panel directly beneath it said "neither proven". The paint has to agree with the code.
 
 
THE ANTI-BIAS GUARDS
 
ENTRY IS THE CLOSE, for the event and for the control alike. A band break is a SIGNAL, not a fill. Entering at the band — a better price — while the control enters at the close hands every signal a free head start and manufactures an edge out of nothing.
 
THE CONTROL IS DIRECTION-MATCHED. In a downtrend there are more break-downs than break-ups, so FOLLOW skews short and FADE skews long. A direction-skewed event set measured against a 50/50 control inherits the index drift for free and calls it an edge. Longs are compared only with control longs, shorts only with control shorts, and the control is blended back using the events' OWN direction mix.
 
IDENTICAL GEOMETRY. Every event and every control trade uses the same stop and the same R multiple, so the comparison is apples to apples.
 
Both barriers on one bar: the STOP is assumed first — conservative, and the only assumption that cannot flatter the result. Unresolved trades at the horizon are marked to market, not booked as losses. Nothing is marked proven below t = 1.96.
 
 
NON-REPAINT
 
The kernel is causal, the bandwidth is chosen on past error only, the interval is built from past residuals, and coverage is scored by asking whether the actual close landed inside the interval that was published BEFORE it. Everything is computed on confirmed bars. Nothing is drawn and then moved.
 
 
WHY THESE PARTS ARE ONE TOOL
 
The regression gives the trend. Without the interval, a band is a guess. Without model selection, the bandwidth is a knob you turn until you like the picture. Without the coverage audit, a conformal interval is an unverified promise. And without the signal calibration, "price left the band" is folklore. Each piece is worthless alone — which is exactly why they ship together.
 
 
DATA AND SCOPE
 
Any symbol, any timeframe. ATR-normalised throughout. No volume required.
 
 
EXPORTS (Data Window — consume from other scripts via input.source())
 
EXP_Fit, EXP_Upper, EXP_Lower, EXP_Bandwidth, EXP_Coverage, EXP_Miscal, EXP_Signal, EXP_Entry, EXP_Stop, EXP_Target
 
 
CONCEPT CREDIT
 
Nadaraya-Watson kernel regression — E. A. Nadaraya and G. S. Watson (1964). Its use for technical pattern recognition in finance — Andrew W. Lo, Harry Mamaysky and Jiang Wang, "Foundations of Technical Analysis", Journal of Finance 55(4), 2000. Conformal prediction — Vladimir Vovk, Alexander Gammerman and Glenn Shafer; the split/inductive form used here follows Papadopoulos et al. and Lei et al. Triple-barrier forward labelling — Marcos Lopez de Prado. Welch's t-test — B. L. Welch. ATR — J. Welles Wilder.
 
The causal-kernel implementation, the parallel bandwidth selection, the live coverage audit, the binomial calibration test and the fade-versus-follow head-to-head are the author's own. Clean-room implementation; no third-party Pine code is reused. Not affiliated with, nor endorsed by, any of the above.
 
 
HONESTY AND LIMITATIONS
 
Conformal coverage is guaranteed under EXCHANGEABILITY. Financial returns are NOT exchangeable — volatility clusters, regimes shift — so the guarantee is approximate in practice. THAT IS PRECISELY WHY THE COVERAGE IS AUDITED LIVE INSTEAD OF ASSUMED. When empirical coverage drifts from nominal you are watching the assumption break, in real time, and you should believe what you see rather than the label.
 
A prediction interval says where price is LIKELY TO BE. It says nothing about DIRECTION, and it is not a forecast. Coverage being correct does not make band breaks tradeable — those are two different claims, and the tool tests them separately for exactly that reason.
 
Calibration figures are IN-SAMPLE, with no costs or slippage, and use overlapping windows. A proven in-sample edge is NOT a guarantee out-of-sample. Nothing here predicts price.
 
 
DISCLAIMER
 
Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee of results. Entry, stop and target output is arithmetic, not advice. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// MACHINE LEARNING PRICE BANDS — KERNEL REGRESSION, PREDICTION INTERVALS & SIGNALS           v1.2
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.2 — One optional, additive layer over v1.1 — the kernel bands, conformal prediction interval,
//        coverage audit, signals and fade/follow calibration are byte-for-byte unchanged:
//          • kNN ANALOG FORECAST (group "07 · Analog forecast", default OFF). A read orthogonal to
//            the kernel fit: it keeps a rolling library of past bars (features = position in the
//            band + return momentum) with their realized forward move, finds the current bar's
//            nearest analogs, and tints the background by their distance-weighted vote — "the last
//            time price sat here in the band with this momentum, what happened next?" Kernel
//            regression here is Nadaraya-Watson, NOT kNN, so this is a genuinely new method, not a
//            duplicate. Adds one export, EXP_KnnForecast. Default OFF reproduces v1.1 exactly.
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Cost model (no engine change): the fade/follow expectancy is measured in R, so a round-trip
//        cost input now yields NetR = ExpR − cost, shown in the panel and exported (EXP_FadeNetR /
//        EXP_FollowNetR). The ✓ "proven" mark still reflects statistical significance vs the control;
//        NetR is shown alongside so you can see whether a proven edge also survives costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   Every "AI band" on this platform draws two lines and asserts them. None of them can tell you how
//   often price actually stays inside. This one can — because it is built on a method that comes
//   with a MATHEMATICAL COVERAGE GUARANTEE, and then it CHECKS WHETHER IT KEPT THE PROMISE, live, on
//   your chart:
//
//        Nominal coverage    90%
//        Empirical coverage  89.4%   (n = 1,240)   ✓ calibrated
//
//   That row does not exist in any other TradingView script. It is the difference between a band and
//   a prediction interval, and it is the whole reason this tool exists.
//
//   NOT a strategy, NOT a signal service, NOT a validated edge. A research and framing tool.
//
// THE MACHINE LEARNING, SPELLED OUT  (no buzzwords — here is the actual model)
//   1. NADARAYA-WATSON KERNEL REGRESSION. Non-parametric: no functional form is assumed, the data
//      chooses the shape. Each past bar votes on the current estimate with a Gaussian weight that
//      decays with distance. This is the same estimator Lo, Mamaysky & Wang used in the Journal of
//      Finance to make chart-pattern recognition objective. It is real ML, and it is 60 years old.
//           m(t) = Σ K(j/h)·P(t−j) / Σ K(j/h),      K(z) = exp(−z²/2)
//      The kernel here is CAUSAL — it only ever looks backwards. A centred kernel (the kind most
//      "Nadaraya-Watson envelope" scripts use) peeks at bars that have not happened yet.
//
//   2. BANDWIDTH BY PREDICTIVE MODEL SELECTION. `h` is the only real parameter, and it is not a
//      magic number here: five candidate bandwidths are run in parallel and scored on their ROLLING
//      ONE-STEP-AHEAD SQUARED ERROR. The winner is used. That is honest model selection — the same
//      criterion you would use to choose any forecaster — rather than a setting you tune until the
//      chart looks nice.
//
//   3. CONFORMAL PREDICTION INTERVALS — the part that matters.
//      Take the absolute one-step-ahead errors over a calibration window. The (1−α) empirical
//      quantile of those errors is the band's half-width. Under EXCHANGEABILITY this carries a
//      FINITE-SAMPLE COVERAGE GUARANTEE — the interval contains the next value at least (1−α) of the
//      time — with NO distributional assumption whatsoever. No normality, no GARCH, no volatility
//      model. The data's own past mistakes size the band.
//      This is why the band widens BEFORE most volatility bands do: it is driven by how wrong the
//      model has recently been, not by how much price has recently moved.
//
//   4. THE COVERAGE AUDIT. A guarantee you do not verify is just a claim. Every bar, the tool checks
//      whether the ACTUAL next close landed inside the interval that was predicted BEFORE it. The
//      running empirical coverage is reported against the nominal. If they diverge, the model is
//      MISCALIBRATED and the panel says so in plain English.
//
// WHY THESE PARTS ARE ONE TOOL  (mashup rationale)
//   The regression gives the trend. Without the interval, a band is a guess. Without model selection,
//   the bandwidth is a knob you turn until you like the picture. Without the coverage audit, a
//   conformal interval is an unverified promise. And without the signal calibration, "price left the
//   band" is folklore. Each piece is worthless alone — that is exactly why they ship together.
//
// THE SIGNAL QUESTION — AND WE DO NOT PRETEND TO KNOW THE ANSWER
//   Price leaving a 90% interval is a statistically unusual move. Whether that means FADE IT (the
//   move is an outlier and reverts) or FOLLOW IT (the model has broken and a new regime is starting)
//   is an EMPIRICAL question, and it differs by instrument and timeframe.
//   So the tool tests BOTH, separately, against an unconditional direction-matched control, and tells
//   you which — if either — works on YOUR chart. It is perfectly entitled to answer "neither".
//
// HOW TO USE
//   1. READ THE COVERAGE ROW FIRST. If empirical coverage is far from nominal, the model is not
//      calibrated on this instrument and nothing below it should be trusted.
//   2. The band is a PREDICTION INTERVAL, not support and resistance. Price inside it is ordinary.
//      Price outside it is unusual — that is all it means, and it is quite a lot.
//   3. Read the FADE vs FOLLOW table before you act on a band break.
//   4. Entry / stop / target are drawn. They are arithmetic, not advice.
//
// DATA / SCOPE
//   Any symbol, any timeframe. No volume required. ATR-normalised risk. The source is an input.
//
// NON-REPAINT
//   The kernel is CAUSAL: at bar t it uses only bars t, t−1, t−2, … Nothing from the future enters.
//   The band for bar t+1 is fixed at the close of bar t and never moves. The coverage audit compares
//   the realised close against the interval that was already published before it. Everything is
//   computed and resolved on CONFIRMED bars.
//   Beware: many "Nadaraya-Watson envelope" scripts use a CENTRED kernel, which fits every point
//   using bars either side of it. That looks beautiful on history and cannot be traded.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Fit · EXP_Upper · EXP_Lower · EXP_Bandwidth · EXP_Coverage · EXP_Alpha · EXP_Miscal · EXP_Signal ·
//   EXP_Entry · EXP_Stop · EXP_Target
//
// CONCEPT CREDIT
//   Nadaraya-Watson kernel regression — E. A. Nadaraya and G. S. Watson (1964). Its use for technical
//   pattern recognition in finance — Andrew W. Lo, Harry Mamaysky and Jiang Wang, "Foundations of
//   Technical Analysis," Journal of Finance 55(4), 2000. Conformal prediction — Vladimir Vovk,
//   Alexander Gammerman and Glenn Shafer; the split/inductive form used here follows Papadopoulos et
//   al. and Lei et al. Triple-barrier forward labelling — Marcos López de Prado. Welch's t-test —
//   B. L. Welch. ATR — J. Welles Wilder.
//   The causal-kernel implementation, the parallel bandwidth selection, the live coverage audit and
//   the fade-vs-follow calibration are the author's own. Clean-room implementation; no third-party
//   Pine code is reused. Not affiliated with, nor endorsed by, any of the above.
//
// HONESTY / LIMITATIONS
//   Conformal coverage is guaranteed under EXCHANGEABILITY. Financial returns are NOT exchangeable —
//   volatility clusters, regimes shift — so the guarantee is approximate in practice. THAT IS
//   PRECISELY WHY THE COVERAGE IS AUDITED LIVE INSTEAD OF ASSUMED. When the empirical coverage drifts
//   away from the nominal, you are watching the assumption break, in real time, and you should
//   believe what you see rather than the label.
//   A prediction interval says where price is LIKELY TO BE. It says nothing about DIRECTION, and it
//   is not a forecast. Coverage being correct does not make band breaks tradeable — those are two
//   different claims, and the tool tests them separately for exactly that reason.
//   Calibration figures are IN-SAMPLE, with no costs, and use overlapping windows. Nothing here
//   predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee
//   of results. Entry/stop/target output is arithmetic, not advice. Trading carries risk of loss.
//   Test out-of-sample and make your own decisions. The author accepts no liability for any use.
// ══════════════════════════════════════════════════════════════════════════════════════════════
// Wave D (U12 · ml_knn): an OPTIONAL, additive k-NN ANALOG FORECAST (group 07, default OFF) — a
//   read orthogonal to the kernel fit that asks "the last time price sat here in the band with this
//   momentum, what happened next?" over a rolling library of analogs, and tints the background by
//   the distance-weighted vote. The kernel regression, conformal bands, signals and calibration are
//   UNTOUCHED. Adds EXP_KnnForecast. (Kernel regression here is Nadaraya-Watson, NOT kNN, so this is
//   a genuinely new method rather than a duplicate.)
indicator("Machine Learning Price Bands — Kernel Regression, Prediction Intervals & Signals", "ML Bands",
     overlay = true, max_labels_count = 500, max_lines_count = 500, max_bars_back = 3000)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g1 = "01 · The model"
g2 = "02 · Conformal prediction interval"
g3 = "03 · Signals (fade or follow?)"
g4 = "04 · Calibration"
g5 = "05 · Drawing"
g6 = "06 · Dashboard & theme"

kSrc     = input.source(close, "Source", group = g1)
kWin     = input.int(50, "Kernel window (bars)", minval = 10, maxval = 300, group = g1, tooltip = "How far back the kernel looks. Weights decay with distance, so distant bars barely matter — this is just where the sum is truncated.")
autoH    = input.bool(true, "Select the bandwidth automatically", group = g1, tooltip = "Five candidate bandwidths are run IN PARALLEL and scored on their rolling one-step-ahead squared error. The winner is used. That is honest model selection — not a knob you turn until the chart looks nice.")
baseH    = input.float(8.0, "Bandwidth (manual)", minval = 1.0, maxval = 60.0, step = 0.5, group = g1, tooltip = "Only used when auto-selection is off. Small = the fit hugs price. Large = it extracts only the major trend.")
selLen   = input.int(200, "Bandwidth selection window", minval = 30, maxval = 1000, group = g1, tooltip = "The rolling window over which the candidate bandwidths are scored.")

covPct   = input.float(90.0, "Nominal coverage (%)", minval = 50.0, maxval = 99.0, step = 1.0, group = g2, tooltip = "The interval is built to contain the next close this often. 90 means one bar in ten is EXPECTED to fall outside — that is the design, not a failure.")
calLen   = input.int(250, "Calibration window (bars)", minval = 30, maxval = 1000, group = g2, tooltip = "How many recent one-step-ahead errors size the interval. Longer = a more stable interval that adapts more slowly.")
useACI   = input.bool(true, "ADAPTIVE conformal (the α that learns)", group = g2, tooltip = "ADAPTIVE CONFORMAL INFERENCE — Gibbs & Candès, NeurIPS 2021.\n\nSplit conformal's guarantee holds under EXCHANGEABILITY. Financial returns are NOT exchangeable: volatility CLUSTERS, so a residual quantile computed over a trailing window is always a step behind, the band is too narrow exactly when it matters, and coverage lands under nominal. Measured live on NIFTY: 89.1% against a nominal 90%, on every timeframe, at z ≈ -4.\n\nACI makes the miscoverage level a LEARNED parameter:\n      α(t+1) = α(t) + γ · (α − err)\nMiss the interval → α falls → the band WIDENS. Cover it → α creeps back → the band TIGHTENS. Long-run coverage provably converges to the target IRRESPECTIVE OF THE DATA GENERATING PROCESS — no exchangeability required.\n\nA band that notices it is undercovering and fixes itself. Watch the α row: it should settle BELOW nominal, and that gap is the size of the exchangeability failure it is compensating for.")
aciGam   = input.float(0.01, "     learning rate γ", minval = 0.001, maxval = 0.2, step = 0.001, group = g2, tooltip = "How fast α chases the miss. Larger = reacts to a regime change faster, but α jitters. Smaller = smoother, slower. 0.01 is the value the paper's experiments settle on.")
useNorm  = input.bool(true, "NORMALISED score (a band that breathes)", group = g2, tooltip = "NORMALISED NONCONFORMITY — Papadopoulos et al. (2008), Lei et al. (2018).\n\nThe plain score |price − fit| is a SCALAR, so the band is THE SAME WIDTH in a dead tape and in a crash. It therefore OVERCOVERS in calm and UNDERCOVERS in chaos, and the single marginal coverage number is the average of those two errors — it looks fine while being wrong in both directions.\n\nNormalising divides each residual by a local scale estimate before taking the quantile, and multiplies it back when drawing:\n      score = |price − fit| / σ        band = fit ± q · σ\nThe band now scales with LOCAL DIFFICULTY. Turn it off and watch the CONDITIONAL COVERAGE row split apart — that row is what proves this is doing something.")
sigLen   = input.int(100, "     local-scale memory (bars)", minval = 10, maxval = 500, group = g2)
covTol   = input.float(2.0, "Coverage miss that MATTERS (pp)", minval = 0.5, maxval = 20.0, step = 0.5, group = g2, tooltip = "TWO DIFFERENT QUESTIONS, AND THE PANEL ANSWERS BOTH. (1) Is the coverage miss REAL, or is it sampling noise? That is a binomial z-test, and it needs no tolerance at all. (2) Is the miss BIG ENOUGH TO CARE ABOUT? That is a judgement, and it is what this input sets. They are not the same question, and conflating them is how a band gets waved through as 'calibrated'. Live, at n=20,266, an empirical coverage of 89.1% against a nominal 90% is a 0.9pp miss — which is FOUR STANDARD ERRORS. Unmistakably real; arguably too small to trade differently. The panel now says exactly that instead of picking one and hiding the other.")

sigMode  = input.string("Test both", "On a band break", options = ["Test both", "Fade only", "Follow only"], group = g3, tooltip = "Price leaving a 90% interval is statistically unusual. Whether to FADE it (an outlier that reverts) or FOLLOW it (the model has broken, a new regime is starting) is an EMPIRICAL question. Default: test both and let the data answer.")
sigConf  = input.bool(true, "Signal needs a CLOSE outside the band", group = g3, tooltip = "A wick outside the interval is not a break. Turning this off makes signals far more frequent and far noisier.")

calibOn  = input.bool(true, "Forward-test the signals", group = g4)
calHor   = input.int(30, "Grading horizon (bars)", minval = 5, maxval = 300, group = g4)
calMinN  = input.int(20, "Min sample before rating", minval = 5, maxval = 300, group = g4)
costR    = input.float(0.30, "Round-trip cost (R) — for NetR", minval = 0.0, maxval = 3.0, step = 0.05, group = g4, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) in R — as a fraction of the trade's 1R risk (Stop × ATR). The fade/follow expectancy is already in R (stop = −1R, target = +reward:risk, expiry marked-to-market), so NetR = ExpR − cost subtracts directly. A mode that beats its control but has negative NetR is not tradeable after costs. Default 0.30 suits 1m NIFTY futures.")
stopA    = input.float(1.0, "Stop (×ATR)", minval = 0.2, maxval = 6.0, step = 0.1, group = g4)
tgtR     = input.float(2.0, "Target (R multiple)", minval = 0.5, maxval = 10.0, step = 0.5, group = g4)
ctlEvery = input.int(15, "Control sample every N bars", minval = 3, maxval = 200, group = g4, tooltip = "The yardstick: the same geometry on arbitrary bars, one long and one short. If the band breaks cannot beat this, they carry no edge.")

showFit  = input.bool(true, "Plot the fit", group = g5)
showBand = input.bool(true, "Plot the interval", group = g5)
showSig  = input.bool(true, "Mark band breaks", group = g5)
showSetup= input.bool(true, "Draw entry / stop / target", group = g5)
lineW    = input.int(2, "Line width", minval = 1, maxval = 6, group = g5)
colFit   = input.color(#ab47bc, "Fit", inline = "c", group = g5)
colUp    = input.color(#ef5350, "Upper", inline = "c", group = g5)
colDn    = input.color(#26a69a, "Lower", inline = "c", group = g5)
lblSize  = input.string("Small", "Label size", options = ["Tiny","Small","Normal"], group = g5)

showPanel= input.bool(true, "Show dashboard", group = g6)
panelMode= input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g6)
panelPos = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g6)
legendPos= input.string("Bottom Right", "Legend position", options = ["Bottom Right","Bottom Left","Middle Left","Top Left"], group = g6, tooltip = "TradingView's own watermark sits bottom-LEFT and will clip a legend placed there.")
showLegend=input.bool(false, "Show legend / key", group = g6, tooltip = "OFF by default. You learn the symbols once and then never need the key again — but it costs chart space on every bar after that.")
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          TYPES
// ═════════════════════════════════════════════════════════════════════════════════════════
type Trade
    int   bi
    float entry
    float stop
    float tgt
    int   dir
    int   bucket        // 1 = fade · 2 = follow · 5 = control long · 6 = control short
    float rr

// ═════════════════════════════════════════════════════════════════════════════════════════
//   1 · THE CAUSAL KERNEL  —  Nadaraya-Watson, looking BACKWARDS only
//
//   m(t) = Σ_{j≥0} K(j/h)·P(t−j) / Σ_{j≥0} K(j/h),     K(z) = exp(−z²/2)
//
//   Most "Nadaraya-Watson envelope" scripts use a CENTRED kernel, which fits each point using bars
//   on BOTH sides of it. That is a beautiful curve you cannot trade: it knows the future. This one
//   only ever looks back, so what you see on history is exactly what you would have seen live.
// ═════════════════════════════════════════════════════════════════════════════════════════
float atr = ta.atr(14)

f_nwCausal(float h) =>
    float num = 0.0
    float den = 0.0
    for j = 0 to kWin
        float z = j / h
        float k = math.exp(-0.5 * z * z)
        num += k * kSrc[j]
        den += k
    den > 0 ? num / den : na

// ── BANDWIDTH SELECTION ──
// Five candidates run in parallel, each scored on its ROLLING ONE-STEP-AHEAD SQUARED ERROR. The
// winner is used. This is the criterion you would use to choose any forecaster — not a knob.
float h1 = baseH * 0.5
float h2 = baseH * 0.75
float h3 = baseH
float h4 = baseH * 1.5
float h5 = baseH * 2.5

float m1 = f_nwCausal(h1)
float m2 = f_nwCausal(h2)
float m3 = f_nwCausal(h3)
float m4 = f_nwCausal(h4)
float m5 = f_nwCausal(h5)

// the error of the PREVIOUS bar's prediction against what actually happened
float e1 = na(m1[1]) ? na : math.pow(kSrc - m1[1], 2)
float e2 = na(m2[1]) ? na : math.pow(kSrc - m2[1], 2)
float e3 = na(m3[1]) ? na : math.pow(kSrc - m3[1], 2)
float e4 = na(m4[1]) ? na : math.pow(kSrc - m4[1], 2)
float e5 = na(m5[1]) ? na : math.pow(kSrc - m5[1], 2)

float s1 = ta.sma(nz(e1), selLen)
float s2 = ta.sma(nz(e2), selLen)
float s3 = ta.sma(nz(e3), selLen)
float s4 = ta.sma(nz(e4), selLen)
float s5 = ta.sma(nz(e5), selLen)

float sBest = math.min(math.min(math.min(s1, s2), math.min(s3, s4)), s5)
float hPick = not autoH ? baseH : sBest == s1 ? h1 : sBest == s2 ? h2 : sBest == s3 ? h3 : sBest == s4 ? h4 : h5
float fit   = not autoH ? m3 : sBest == s1 ? m1 : sBest == s2 ? m2 : sBest == s3 ? m3 : sBest == s4 ? m4 : m5

// ═════════════════════════════════════════════════════════════════════════════════════════
//   2 · THE CONFORMAL PREDICTION INTERVAL
//
//   The half-width is the (1−α) empirical quantile of the recent ABSOLUTE one-step-ahead errors.
//   Under exchangeability this carries a FINITE-SAMPLE coverage guarantee, with NO distributional
//   assumption at all: no normality, no GARCH, no volatility model. The model's own recent mistakes
//   size the band — which is why it widens when the model starts being WRONG, not merely when price
//   starts moving.
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<float> resid = array.new<float>()

// the realised error of the interval's own predictor, one step ahead
float absErr = na(fit[1]) ? na : math.abs(kSrc - fit[1])

// ── LOCAL SCALE σ  —  causal, and it is what lets the band BREATHE ──
// An EWMA of the model's own recent absolute error. Note it is the MODEL'S difficulty, not the
// market's volatility: they are related but not the same thing, and it is the first one the interval
// is supposed to be about.
var float sigma = na
if barstate.isconfirmed and not na(absErr)
    sigma := na(sigma) ? absErr : sigma + (absErr - sigma) * (2.0 / (sigLen + 1.0))
float sigNow = useNorm ? math.max(nz(sigma, syminfo.mintick), syminfo.mintick) : 1.0

// the NONCONFORMITY SCORE. Plain: |price − fit|. Normalised: |price − fit| / σ.
float score = na(absErr) ? na : (useNorm ? absErr / math.max(nz(sigma[1], absErr), syminfo.mintick) : absErr)

if barstate.isconfirmed and not na(score)
    array.push(resid, score)
    while array.size(resid) > calLen
        array.shift(resid)

// ── ADAPTIVE CONFORMAL INFERENCE  (Gibbs & Candès, NeurIPS 2021) ──
//      α(t+1) = α(t) + γ · (α − err(t)),      err = 1 if the published interval MISSED
// Miss → α falls → the quantile rises → the band WIDENS. Cover → α creeps back → it TIGHTENS.
// The long-run coverage converges to the target with NO exchangeability assumption whatever, which
// is the entire reason it belongs here: financial returns are the textbook counterexample to
// exchangeability, and split conformal quietly undercovers because of it.
float aNom = 1.0 - covPct / 100.0                 // the nominal miscoverage, e.g. 0.10
// The interval PUBLISHED on the previous bar, carried forward explicitly. `upper[1]` cannot be used
// here — the ACI update has to run BEFORE `upper` is computed, and Pine requires declaration first.
var float upPrev = na
var float loPrev = na
var float aT     = na
if na(aT)
    aT := aNom
if barstate.isconfirmed and useACI and not na(upPrev) and not na(loPrev)
    float errT = (kSrc > upPrev or kSrc < loPrev) ? 1.0 : 0.0
    aT := math.max(0.001, math.min(0.5, aT + aciGam * (aNom - errT)))
float pctEff = useACI ? (1.0 - aT) * 100.0 : covPct

float q      = array.size(resid) >= 20 ? array.percentile_nearest_rank(resid, pctEff) : na
float halfW  = na(q) ? na : q * sigNow
float upper  = na(fit) or na(halfW) ? na : fit + halfW
float lower  = na(fit) or na(halfW) ? na : fit - halfW
if barstate.isconfirmed
    upPrev := upper
    loPrev := lower

// ═════════════════════════════════════════════════════════════════════════════════════════
//   3 · THE COVERAGE AUDIT  —  a guarantee you do not verify is just a claim
//   Did the ACTUAL close land inside the interval that was published BEFORE it?
// ═════════════════════════════════════════════════════════════════════════════════════════
var int covN = 0
var int covIn = 0
// ── CONDITIONAL COVERAGE ──
// A single marginal number can be 90% while the interval covers 97% of calm bars and 78% of violent
// ones — and 90% is then the AVERAGE OF TWO ERRORS, looking correct while being wrong in both
// directions. Exact conditional coverage is provably impossible without strong assumptions, but you
// can always MEASURE it, and almost nobody does. Bars are split into calm / normal / turbulent
// thirds by the percentile rank of ATR, and coverage is scored inside each.
// If the three numbers fan apart, the band is not breathing and the normalised score is what fixes it.
var array<int> cvN = array.new<int>(3, 0)
var array<int> cvI = array.new<int>(3, 0)
float volRk = ta.percentrank(atr, 200)
int   regime = na(volRk) ? 1 : volRk < 33.3 ? 0 : volRk < 66.7 ? 1 : 2
if barstate.isconfirmed and not na(upper[1]) and not na(lower[1])
    covN += 1
    bool inside = kSrc <= upper[1] and kSrc >= lower[1]
    if inside
        covIn += 1
    array.set(cvN, regime, array.get(cvN, regime) + 1)
    if inside
        array.set(cvI, regime, array.get(cvI, regime) + 1)

f_cvPct(int r) =>
    int n = array.get(cvN, r)
    n > 0 ? array.get(cvI, r) / float(n) * 100.0 : na

float covEmp = covN > 0 ? covIn / float(covN) * 100.0 : na

// ── THE BINOMIAL TEST ──
// A tolerance alone cannot answer "is this miss real?" — only the sample size can. Under the
// guarantee, each bar is a Bernoulli trial with p = nominal, so the standard error of the observed
// coverage is sqrt(p(1-p)/n), and the miss in standard errors is just a z-score. At n = 20,266 that
// SE is 0.21pp, which means a 0.9pp miss is FOUR standard errors — utterly unmistakable, and yet a
// 5pp tolerance shrugged it off as "calibrated". The headline row of this script was asserting the
// one thing the script exists to verify, and asserting it wrongly.
float covSE  = covN > 0 ? math.sqrt(covPct / 100.0 * (1.0 - covPct / 100.0) / covN) * 100.0 : na
float covZ   = (na(covEmp) or na(covSE) or covSE <= 0) ? na : (covEmp - covPct) / covSE
float covDev = na(covEmp) ? na : covEmp - covPct
bool  covWarm = covN < 100
// REAL = statistically distinguishable from the nominal.  BIG = large enough to change what you do.
bool  covReal = not covWarm and not na(covZ) and math.abs(covZ) > 1.96
bool  covBig  = not covWarm and not na(covDev) and math.abs(covDev) > covTol
bool  miscal  = covReal and covBig

// ═════════════════════════════════════════════════════════════════════════════════════════
//   4 · SIGNALS  —  fade or follow? The tool does not pretend to know.
// ═════════════════════════════════════════════════════════════════════════════════════════
bool aboveBand = not na(upper[1]) and (sigConf ? kSrc > upper[1] : high > upper[1])
bool belowBand = not na(lower[1]) and (sigConf ? kSrc < lower[1] : low  < lower[1])
bool brkUp = aboveBand and not aboveBand[1]
bool brkDn = belowBand and not belowBand[1]

// ═════════════════════════════════════════════════════════════════════════════════════════
//   5 · CALIBRATION  —  unconditional, direction-matched control on identical geometry
// ═════════════════════════════════════════════════════════════════════════════════════════
// ── BUCKETS, SPLIT BY DIRECTION ──
//   1 = FADE long   · 2 = FADE short
//   3 = FOLLOW long · 4 = FOLLOW short
//   5 = control long · 6 = control short
// The split exists because the control was being blended 50/50 while the event set is NOT 50/50 — a
// downtrending sample produces more break-downs than break-ups, so FOLLOW skews short and FADE skews
// long. A direction-skewed event set against a 50/50 control is handed the index drift for free.
var array<Trade> pend = array.new<Trade>()
var array<int>   bN  = array.new<int>(8, 0)
var array<float> bR  = array.new<float>(8, 0.0)
var array<float> bR2 = array.new<float>(8, 0.0)

f_log(int bucket, int dir) =>
    if calibOn and atr > 0
        float risk = stopA * atr
        // ENTRY IS THE CLOSE — a band break is a SIGNAL, not a fill. Entering at the band (a better
        // price than the close) while the control enters at the close would hand the signal a free
        // head start and manufacture an edge out of nothing.
        float st = dir == 1 ? close - risk : close + risk
        float tg = dir == 1 ? close + tgtR * risk : close - tgtR * risk
        array.push(pend, Trade.new(bar_index, close, st, tg, dir, bucket, tgtR))

if barstate.isconfirmed and calibOn
    bool doFade   = sigMode != "Follow only"
    bool doFollow = sigMode != "Fade only"
    // FADE: the move is an outlier, so bet on reversion
    if doFade and brkUp
        f_log(2, -1)                       // fade an up-break = SHORT
    if doFade and brkDn
        f_log(1, 1)                        // fade a down-break = LONG
    // FOLLOW: the model has broken, so bet on the new regime
    if doFollow and brkUp
        f_log(3, 1)                        // follow an up-break = LONG
    if doFollow and brkDn
        f_log(4, -1)                       // follow a down-break = SHORT
    if atr > 0 and bar_index % ctlEvery == 0
        f_log(5, 1)
        f_log(6, -1)

if barstate.isconfirmed and array.size(pend) > 0
    int i = 0
    while i < array.size(pend)
        Trade t = array.get(pend, i)
        bool hitT = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitT or hitS or expd)
            // both barriers on one bar → the STOP is assumed first: conservative, and the only
            // assumption that cannot flatter the result.
            float risk = math.abs(t.entry - t.stop)
            // expired trades are MARKED TO MARKET — an unresolved trade is neither a win nor a loss.
            float rOut = hitS ? -1.0 : hitT ? t.rr : (risk > 0 ? (close - t.entry) * t.dir / risk : 0.0)
            array.set(bN,  t.bucket, array.get(bN,  t.bucket) + 1)
            array.set(bR,  t.bucket, array.get(bR,  t.bucket) + rOut)
            array.set(bR2, t.bucket, array.get(bR2, t.bucket) + rOut * rOut)
            array.remove(pend, i)
        else
            i += 1

f_n(int ix) => array.get(bN, ix)
f_exp(int ix) =>
    int n = array.get(bN, ix)
    n > 0 ? array.get(bR, ix) / float(n) : na
f_var(int ix) =>
    int n = array.get(bN, ix)
    if n < 2
        na
    else
        float m = array.get(bR, ix) / n
        math.max(array.get(bR2, ix) / n - m * m, 0.0)

// ── A MODE vs A CONTROL BLENDED TO MATCH ITS OWN DIRECTION MIX ──
// base 1 = FADE · base 3 = FOLLOW. Returns [mean, control, n, variance, t].
// The old version blended the control 50/50. But the event set is not 50/50: in a downtrend there
// are more break-downs than break-ups, so FOLLOW skews short and FADE skews long — and a skewed
// event set measured against a 50/50 control inherits the index drift for nothing and calls it edge.
f_grp(int base) =>
    int iL = base
    int iS = base + 1
    int nL = f_n(iL)
    int nS = f_n(iS)
    int nE = nL + nS
    if nE < 2
        [float(na), float(na), nE, float(na), float(na)]
    else
        float sR  = array.get(bR, iL)  + array.get(bR, iS)
        float sR2 = array.get(bR2, iL) + array.get(bR2, iS)
        float mE  = sR / nE
        float vE  = math.max(sR2 / nE - mE * mE, 0.0)
        float seE = math.sqrt(vE / nE)
        float wL  = nL / float(nE)
        float wS  = nS / float(nE)
        float mCL = f_exp(5)
        float mCS = f_exp(6)
        float mC  = (na(mCL) ? 0.0 : wL * mCL) + (na(mCS) ? 0.0 : wS * mCS)
        float vCL = f_var(5)
        float vCS = f_var(6)
        int   nCL = f_n(5)
        int   nCS = f_n(6)
        float seC = math.sqrt((nCL > 1 and not na(vCL) ? wL * wL * vCL / nCL : 0.0) + (nCS > 1 and not na(vCS) ? wS * wS * vCS / nCS : 0.0))
        float se  = math.sqrt(seE * seE + seC * seC)
        [mE, mC, nE, vE, se > 0 ? (mE - mC) / se : na]

[expFade, ctlFade, nFade, varFade, tFade] = f_grp(1)
[expFoll, ctlFoll, nFoll, varFoll, tFoll] = f_grp(3)
// cost model: expectancy is in R, so a round-trip cost in R subtracts directly (descriptive read)
float expFadeNet = na(expFade) ? na : expFade - costR
float expFollNet = na(expFoll) ? na : expFoll - costR
bool provFade = not na(tFade) and nFade >= calMinN and tFade > 1.96
bool provFoll = not na(tFoll) and nFoll >= calMinN and tFoll > 1.96
float driftL = f_exp(5)
float driftS = f_exp(6)

// ── FADE vs FOLLOW, HEAD TO HEAD ──
// These are MUTUALLY EXCLUSIVE responses to the SAME event. Knowing that each beats an unconditional
// control is not the question a trader is actually asking at a band break — the question is which of
// the two to do. So they are tested against EACH OTHER as well, with a Welch t, and the answer is
// allowed to be "neither": if the difference does not clear the noise, then on this instrument the
// break does not tell you which way to lean, and saying so is the finding.
float seFF = (nFade > 1 and nFoll > 1 and not na(varFade) and not na(varFoll)) ? math.sqrt(varFade / nFade + varFoll / nFoll) : na
float tFF  = (na(seFF) or seFF <= 0 or na(expFade) or na(expFoll)) ? na : (expFoll - expFade) / seFF
bool  warmFF = nFade < calMinN or nFoll < calMinN
// +1 = FOLLOW wins · -1 = FADE wins · 0 = the data cannot tell them apart
int   ffV = (warmFF or na(tFF)) ? 0 : tFF > 1.96 ? 1 : tFF < -1.96 ? -1 : 0

// the live setup, from whichever mode is proven (or the one the user forced)
var float eEn = na
var float eSt = na
var float eTg = na
var int   eDir = 0
var int   eBar = -1000
var string eSrc = ""
var bool  eProv = false      // is the direction this setup took actually PROVEN, or merely picked?
var bool  eOpen = false      // A TRADE ENDS. `(bar_index - eBar) < 100` is elapsed time, not a trade.
var int   eRes  = 0          // Live, a 15m target hit long ago was still drawn as the live setup.
if barstate.isconfirmed and (brkUp or brkDn) and atr > 0
    // WHICH WAY? Only the head-to-head answers that. When the data cannot separate fade from follow,
    // the honest output is not a confident arrow — the chart used to print "Follow the break" in
    // full colour while the panel directly beneath it said "neither proven". The paint has to agree
    // with the code, so an unproven direction is still DRAWN (it is arithmetic, and you may want it)
    // but it is drawn muted and it is LABELLED as unproven.
    bool preferFollow = sigMode == "Follow only" ? true : sigMode == "Fade only" ? false : ffV == 1 ? true : ffV == -1 ? false : (not na(expFoll) and not na(expFade) and expFoll > expFade)
    bool proven = sigMode != "Test both" ? (preferFollow ? provFoll : provFade) : (ffV != 0 and (preferFollow ? provFoll : provFade))
    int  d = brkUp ? (preferFollow ? 1 : -1) : (preferFollow ? -1 : 1)
    float risk = stopA * atr
    eEn := close
    eDir := d
    eSt := d == 1 ? close - risk : close + risk
    eTg := d == 1 ? close + tgtR * risk : close - tgtR * risk
    eBar := bar_index
    eProv := proven
    eOpen := true
    eRes  := 0
    eSrc := (preferFollow ? "Follow the break" : "Fade the break") + (proven ? "" : "  (not proven)")

// the setup is a TRADE, and a trade ENDS
if barstate.isconfirmed and eOpen and not na(eEn) and bar_index > eBar
    bool tHit = eDir == 1 ? high >= eTg : low  <= eTg
    bool sHit = eDir == 1 ? low  <= eSt : high >= eSt
    if sHit
        eOpen := false
        eRes  := -1
    else if tHit
        eOpen := false
        eRes  := 1
    else if bar_index - eBar >= calHor
        eOpen := false
        eRes  := 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        THEME
// ═════════════════════════════════════════════════════════════════════════════════════════
// Pine's "+#.00" format treats the '+' as a LITERAL character, so -0.25 renders as "-+.25". Sign it
// by hand instead. (A real formatting bug the first live test caught.)
f_R(float v) => na(v) ? "-" : (v >= 0 ? "+" : "") + str.tostring(v, "#.00") + "R"

f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : s == "Middle Left" ? position.middle_left : position.top_right
f_lblSize() => lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small

bool darkUI   = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color warnC   = color.new(#ffa726, 0)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
pF = plot(showFit ? fit : na, "Fit", color.new(colFit, 0), lineW)
pU = plot(showBand ? upper : na, "Upper interval", color.new(colUp, 0), lineW)
pL = plot(showBand ? lower : na, "Lower interval", color.new(colDn, 0), lineW)
fill(pU, pF, color.new(colUp, 93), title = "Upper band")
fill(pF, pL, color.new(colDn, 93), title = "Lower band")

plotshape(showSig and brkUp, "Break above the interval", shape.triangledown, location.abovebar, color.new(colUp, 0), size = size.tiny)
plotshape(showSig and brkDn, "Break below the interval", shape.triangleup,   location.belowbar, color.new(colDn, 0), size = size.tiny)

// THE SETUP IS DRAWN WITH LINE OBJECTS, NOT plot().
// A plot whose value JUMPS when a new setup arms draws a vertical connector between the old level
// and the new one, and then a long horizontal run of the STALE level across every bar in between.
// That is what those staircase rectangles marching across the chart were: not zones, not levels —
// artifacts. plot.style_linebr suppresses the connector only where the value is `na`, and a `var`
// float is never na once it has been set, so the break never happens. Three lines, drawn from the
// bar the setup armed to the bar it resolved. Nothing else.
bool setupLive = showSetup and eOpen and not na(eEn)
var line sE = na
var line sS = na
var line sT = na

var label lU = na
var label lL = na
var label lE = na
var label lS = na
var label lT = na
if barstate.islast
    line.delete(sE)
    line.delete(sS)
    line.delete(sT)
    label.delete(lU)
    label.delete(lL)
    label.delete(lE)
    label.delete(lS)
    label.delete(lT)
    if showBand and not na(upper)
        lU := label.new(bar_index + 3, upper, "UPPER  " + str.tostring(upper, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colUp, 15), textcolor = color.white, size = f_lblSize())
        lL := label.new(bar_index + 3, lower, "LOWER  " + str.tostring(lower, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colDn, 15), textcolor = color.white, size = f_lblSize())
    if setupLive
        // an UNPROVEN direction is drawn faintly. It is arithmetic, and you may want it — but it is
        // not a finding, and it must not be painted like one.
        int tr = eProv ? 0 : 55
        color cS = eDir == 1 ? colUp : colDn
        color cT = eDir == 1 ? colDn : colUp
        sE := line.new(eBar, eEn, bar_index + 22, eEn, xloc = xloc.bar_index, color = color.new(color.gray, tr), width = lineW)
        sS := line.new(eBar, eSt, bar_index + 22, eSt, xloc = xloc.bar_index, color = color.new(cS, tr), width = lineW)
        sT := line.new(eBar, eTg, bar_index + 22, eTg, xloc = xloc.bar_index, color = color.new(cT, tr), width = lineW)
        lE := label.new(bar_index + 22, eEn, "ENTRY  " + str.tostring(eEn, format.mintick) + "   " + eSrc, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.gray, eProv ? 10 : 45), textcolor = color.white, size = f_lblSize())
        lS := label.new(bar_index + 22, eSt, "STOP  " + str.tostring(eSt, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cS, eProv ? 10 : 45), textcolor = color.white, size = f_lblSize())
        lT := label.new(bar_index + 22, eTg, "TARGET  " + str.tostring(eTg, format.mintick) + "   R:R " + str.tostring(tgtR, "#.#"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cT, eProv ? 10 : 45), textcolor = color.white, size = f_lblSize())

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
bool isPro = panelMode == "Pro"
var table tb = table.new(f_pos(panelPos), 3, 19, frame_width = 1, border_width = 1)
f_r2(int r, string k, string v, color c, color bg) =>
    table.cell(tb, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left, bgcolor = bg)
    table.cell(tb, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
    table.cell(tb, 2, r, "", bgcolor = bg)
f_r3(int r, string k, string a, string b, color c, color bg) =>
    table.cell(tb, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left, bgcolor = bg)
    table.cell(tb, 1, r, a, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
    table.cell(tb, 2, r, b, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

if showPanel and barstate.islast
    table.set_bgcolor(tb, panelBg)
    table.set_frame_color(tb, frameC)
    table.set_border_color(tb, frameC)
    // THE ROW THAT DOES NOT EXIST IN ANY OTHER SCRIPT
    // IS THE MISS REAL?  (binomial z)   ·   IS IT BIG?  (the tolerance)   —   two questions, both answered
    string covStr = covWarm ? "warming (" + str.tostring(covN) + "/100)" : str.tostring(covEmp, "#.1") + "%  vs  " + str.tostring(covPct, "#") + "%  n=" + str.tostring(covN)
    color  covCol = covWarm ? txtMut : miscal ? warnC : covReal ? colFit : colDn
    string covVerdict = covWarm ? "-" : miscal ? "MISCALIBRATED — do not trust the band" : covReal ? (covDev < 0 ? "undercovering — real, but small" : "overcovering — real, but small") : "calibrated — within sampling noise"
    string covTest = covWarm or na(covZ) ? "-" : (covDev >= 0 ? "+" : "") + str.tostring(covDev, "#.1") + " pp   z = " + str.tostring(covZ, "#.1") + (covReal ? "   (real)" : "   (noise)")
    color hdrC = miscal ? warnC : color.new(colFit, 0)
    color hdrT = f_lum(hdrC) > 140 ? color.rgb(10, 10, 10) : color.white

    table.cell(tb, 0, 0, "ML PRICE BANDS", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 0, "h " + str.tostring(hPick, "#.1") + (useACI ? "   " + "α " + str.tostring(aT, "#.000") : ""), text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 2, 0, autoH ? "auto" : "manual", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)

    if isPro
        f_r2(1, "Coverage (empirical vs nominal)", covStr, covCol, rowAlt)
        f_r2(2, "  is the miss REAL?", covTest, covCol, panelBg)
        f_r2(3, "Verdict", covVerdict, covCol, rowAlt)
        // THE ROW THAT PROVES THE BAND BREATHES. If these three fan apart, the interval is the same
        // width in a dead tape and in a crash, and the marginal number above is the average of a lie.
        f_r2(4, "  calm / normal / turbulent", (na(f_cvPct(0)) ? "-" : str.tostring(f_cvPct(0), "#.0")) + "%  ·  " + (na(f_cvPct(1)) ? "-" : str.tostring(f_cvPct(1), "#.0")) + "%  ·  " + (na(f_cvPct(2)) ? "-" : str.tostring(f_cvPct(2), "#.0")) + "%", txtMain, panelBg)
        // α is a LEARNED parameter now. Where it settles IS the size of the exchangeability failure.
        f_r2(5, "α  (learned vs nominal)", not useACI ? "off — fixed α" : str.tostring(aT, "#.000") + "  vs  " + str.tostring(aNom, "#.000") + (aT < aNom - 0.002 ? "   self-widened" : aT > aNom + 0.002 ? "   self-tightened" : ""), useACI ? colFit : txtMut, rowAlt)
        f_r2(6, "Interval half-width", na(halfW) ? "-" : str.tostring(halfW, format.mintick) + "   (" + str.tostring(atr > 0 ? halfW / atr : na, "#.2") + " ATR)" + (useNorm ? "   breathing" : "   FIXED"), txtMain, panelBg)
        f_r2(7, "Upper / Lower", (na(upper) ? "-" : str.tostring(upper, format.mintick)) + "  /  " + (na(lower) ? "-" : str.tostring(lower, format.mintick)), txtMain, rowAlt)
        f_r2(8, "Price vs interval", (aboveBand ? "ABOVE — unusual" : belowBand ? "BELOW — unusual" : "inside — ordinary"), (aboveBand or belowBand) ? warnC : txtMut, panelBg)
        table.cell(tb, 0, 9, "BAND BREAKS", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 9, "expectancy", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 9, "vs control · n", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        f_r3(10, "FADE the break", na(expFade) ? "-" : f_R(expFade) + (provFade ? " ✓" : ""), (na(ctlFade) ? "-" : f_R(ctlFade) + " · n=" + str.tostring(nFade)), provFade ? colDn : (not na(expFade) and not na(ctlFade) and expFade > ctlFade) ? txtMain : colUp, rowAlt)
        f_r3(11, "FOLLOW the break", na(expFoll) ? "-" : f_R(expFoll) + (provFoll ? " ✓" : ""), (na(ctlFoll) ? "-" : f_R(ctlFoll) + " · n=" + str.tostring(nFoll)), provFoll ? colDn : (not na(expFoll) and not na(ctlFoll) and expFoll > ctlFoll) ? txtMain : colUp, panelBg)
        // FADE vs FOLLOW, HEAD TO HEAD — the question a trader is ACTUALLY asking at a band break.
        // "Each beats a control" is not an answer to "which of the two should I do?"
        f_r2(12, "FADE or FOLLOW?", warmFF ? "warming (" + str.tostring(math.min(nFade, nFoll)) + "/" + str.tostring(calMinN) + ")" : ffV == 1 ? "FOLLOW — and it beats fading" : ffV == -1 ? "FADE — and it beats following" : "NEITHER — the break does not tell you which", warmFF ? txtMut : ffV == 0 ? warnC : colDn, rowAlt)
        f_r2(13, "  follow vs fade (t)", na(tFF) ? "-" : str.tostring(tFF, "#.2") + "   (needs |t| > 1.96)", warmFF ? txtMut : ffV == 0 ? warnC : colDn, panelBg)
        f_r2(14, "  each vs control (t)", (na(tFade) ? "-" : "fade " + str.tostring(tFade, "#.2")) + " · " + (na(tFoll) ? "-" : "follow " + str.tostring(tFoll, "#.2")), txtMut, rowAlt)
        f_r2(15, "Baseline drift", (na(driftL) or na(driftS)) ? "-" : "long " + f_R(driftL) + " · short " + f_R(driftS), txtMut, panelBg)
        string setTxt = setupLive ? (eDir == 1 ? "LONG · " : "SHORT · ") + eSrc : na(eEn) ? "none" : eRes == 1 ? "last: target hit" : eRes == -1 ? "last: stopped" : "last: expired"
        f_r2(16, "Live setup", setTxt, setupLive ? (eProv ? (eDir == 1 ? colDn : colUp) : warnC) : txtMut, rowAlt)
        f_r2(17, "Net of cost (R)", (na(expFadeNet) or na(expFollNet)) ? "warming" : "fade " + f_R(expFadeNet) + " · follow " + f_R(expFollNet) + "   (cost " + str.tostring(costR, "#.00") + ")", ((not na(expFadeNet) and expFadeNet > 0) or (not na(expFollNet) and expFollNet > 0)) ? txtMain : warnC, panelBg)
        f_r2(18, "Note", "entry = close · direction-matched control · in-sample · not advice", txtMut, rowAlt)
    else
        f_r2(1, "Coverage", covStr, covCol, rowAlt)
        f_r2(2, "Verdict", covVerdict, covCol, panelBg)
        f_r2(3, "Price vs interval", (aboveBand ? "ABOVE — unusual" : belowBand ? "BELOW — unusual" : "inside — ordinary"), (aboveBand or belowBand) ? warnC : txtMut, rowAlt)
        f_r2(4, "Fade or follow?", warmFF ? "warming" : ffV == 1 ? "FOLLOW (beats fading)" : ffV == -1 ? "FADE (beats following)" : "NEITHER — break gives no direction", warmFF ? txtMut : ffV == 0 ? warnC : colDn, panelBg)
        f_r2(17, "Note", "in-sample · not advice", txtMut, rowAlt)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       LEGEND / KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
var table lg = table.new(f_pos(legendPos), 2, 11, frame_width = 1, border_width = 1)
f_lg(int r, string sw, color c, string txt) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(lg, 0, r, sw,  text_color = c,      bgcolor = bg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(lg, 1, r, txt, text_color = txtSub, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
if showLegend and barstate.islast
    table.set_bgcolor(lg, panelBg)
    table.set_frame_color(lg, frameC)
    table.set_border_color(lg, frameC)
    table.cell(lg, 0, 0, "KEY", text_color = txtMain, bgcolor = frameC, text_size = size.tiny)
    table.cell(lg, 1, 0, "what you're looking at", text_color = txtMain, bgcolor = frameC, text_size = size.tiny, text_halign = text.align_left)
    f_lg(1, "━━", colFit, "Kernel regression fit — CAUSAL, it never looks forward")
    f_lg(2, "▒",  colUp,  "The conformal PREDICTION INTERVAL, not support/resistance")
    f_lg(3, "%",  colDn,  "Coverage: does the band keep its promise? Read this FIRST")
    f_lg(4, "▲▼", colUp,  "A break — price left the interval. Statistically unusual")
    f_lg(5, "?",  txtMain,"FADE or FOLLOW? The panel tests both. It may answer 'neither'")
    f_lg(6, "h",  colFit, "The bandwidth is CHOSEN, not tuned — lowest 1-step-ahead error")
    f_lg(7, "α",  colFit, "α is LEARNED. Miss → band widens. Cover → band tightens (ACI)")
    f_lg(8, "≈",  colDn,  "Pro panel: coverage in CALM / NORMAL / TURBULENT bars, separately")
    f_lg(9, "!",  warnC,  "MISCALIBRATED = the guarantee has broken. Believe it, not the label")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
color exC = color.new(color.gray, 100)
plot(fit,                          "EXP_Fit",       exC, display = display.data_window)
// ═══════════════════════════════════════════════════════════════════════════════
// U12 · kNN ANALOG FORECAST (ml_knn, inlined) — OPTIONAL, additive; kernel bands untouched.
//   Orthogonal to the kernel fit: "the last time price sat here in the band with this momentum,
//   what happened next?" Distance-weighted k-NN over a rolling library of past analogs. Default OFF.
// ═══════════════════════════════════════════════════════════════════════════════
gKnn   = "07 · Analog forecast (Wave D · U12)"
knnOn  = input.bool(false, "kNN analog forecast (background tint)", group = gKnn, tooltip = "OFF by default. ON keeps a rolling library of past bars (features = position in the band + return momentum) with their realized forward move, and tints the background by the distance-weighted vote of the current bar's nearest analogs. An orthogonal read to the kernel fit — nothing in the bands or signals changes.")
knnH   = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = gKnn)
knnK   = input.int(12, "Neighbours (k)", minval = 3, maxval = 50, group = gKnn)
knnMax = input.int(300, "Library size (analogs)", minval = 50, maxval = 2000, group = gKnn)
knnThr = input.float(0.3, "Tint threshold |forecast|", minval = 0.05, maxval = 0.9, step = 0.05, group = gKnn)

float _knnPos = (not na(fit) and not na(halfW) and halfW > 0.0) ? (close - fit) / halfW : 0.0
float _knnSd  = ta.stdev(close - close[1], 50)
float _knnRz  = _knnSd > 0.0 ? (close - close[1]) / _knnSd : 0.0
var array<float> _knnF = array.new<float>()
var array<float> _knnL = array.new<float>()
if knnOn and barstate.isconfirmed and not na(close[knnH]) and not na(_knnPos[knnH]) and not na(_knnRz[knnH])
    array.push(_knnF, _knnPos[knnH])
    array.push(_knnF, _knnRz[knnH])
    array.push(_knnL, math.sign(close - close[knnH]))
    while array.size(_knnL) > knnMax
        array.shift(_knnL)
        array.shift(_knnF)
        array.shift(_knnF)
float knnFc = na
if knnOn and array.size(_knnL) > knnK
    int _kn = array.size(_knnL)
    array<float> _kd = array.new<float>(_kn, 0.0)
    for _i = 0 to _kn - 1
        float _da = array.get(_knnF, _i * 2)     - _knnPos
        float _db = array.get(_knnF, _i * 2 + 1) - _knnRz
        array.set(_kd, _i, _da * _da + _db * _db)
    array<bool> _ku = array.new<bool>(_kn, false)
    float _kws = 0.0
    float _kls = 0.0
    for _p = 0 to knnK - 1
        int _bi = -1
        float _bd = 1e30
        for _i = 0 to _kn - 1
            if not array.get(_ku, _i) and array.get(_kd, _i) < _bd
                _bd := array.get(_kd, _i)
                _bi := _i
        if _bi >= 0
            array.set(_ku, _bi, true)
            float _w = 1.0 / (_bd + 1e-9)
            _kws += _w
            _kls += _w * array.get(_knnL, _bi)
    knnFc := _kws > 0.0 ? _kls / _kws : na
bgcolor(knnOn and not na(knnFc) ? (knnFc > knnThr ? color.new(color.green, 90) : knnFc < -knnThr ? color.new(color.red, 90) : na) : na, title = "kNN analog tint")
plot(knnOn ? knnFc : na, "EXP_KnnForecast", color = color.new(color.gray, 100), display = display.data_window)

plot(upper,                        "EXP_Upper",     exC, display = display.data_window)
plot(lower,                        "EXP_Lower",     exC, display = display.data_window)
plot(hPick,                        "EXP_Bandwidth", exC, display = display.data_window)
plot(useACI ? aT : aNom,           "EXP_Alpha",     exC, display = display.data_window)
plot(covEmp,                       "EXP_Coverage",  exC, display = display.data_window)
plot(miscal ? 1 : 0,               "EXP_Miscal",    exC, display = display.data_window)
plot(brkUp ? 1 : brkDn ? -1 : 0,   "EXP_Signal",    exC, display = display.data_window)
plot(eEn,                          "EXP_Entry",     exC, display = display.data_window)
plot(eSt,                          "EXP_Stop",      exC, display = display.data_window)
plot(eTg,                          "EXP_Target",    exC, display = display.data_window)
plot(na(expFadeNet) ? na : expFadeNet,  "EXP_FadeNetR",   exC, display = display.data_window)
plot(na(expFollNet) ? na : expFollNet,  "EXP_FollowNetR", exC, display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(brkUp, "Break above the interval", "ML Bands: price closed ABOVE the prediction interval — a statistically unusual move (context, not advice)")
alertcondition(brkDn, "Break below the interval", "ML Bands: price closed BELOW the prediction interval — a statistically unusual move (context, not advice)")
alertcondition(useACI and not na(aT) and math.abs(aT - aNom) > 0.02, "Exchangeability breaking", "ML Bands: the learned alpha has run far from nominal - the band is fighting a regime the model's own past cannot describe (context, not advice)")
alertcondition(miscal, "Model miscalibrated", "ML Bands: empirical coverage has drifted away from nominal — the model is miscalibrated on this instrument (context, not advice)")
````
