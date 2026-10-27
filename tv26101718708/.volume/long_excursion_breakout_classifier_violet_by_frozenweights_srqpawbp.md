# Long Excursion Breakout Classifier [Violet] by FrozenWeights

- url: https://www.tradingview.com/script/sRqPaWBP-Long-Excursion-Breakout-Classifier-Violet-by-FrozenWeights/
- type: indicator
- pine_id: PUB;03086ff2e658412a8fbd2dede8113048
- version: 1.0

## Description

[i]Free, open-source (MIT), published by FrozenWeights on TradingView.[/i]


[b]🟪 What it does[/b]

A small, frozen neural classifier that reads raw 30-minute OHLCV on crypto charts and outputs a per-bar probability (p_long) that the next several hours contain an upward breakout shape.

On bar close, the script compares that probability to an [b]adaptive threshold[/b] (Self-Calibrate ON by default). When the score ranks in the top 0.5 % of the recent distribution, a signal is produced. The threshold automatically adjusts to the chart's own score distribution, so you get consistent signal frequency across different pairs, regimes, and even timeframes, without manual retuning.

p_long is a sigmoid in [0, 1]. Higher values mean the model sees stronger structural evidence for an imminent upward excursion. It does [b]not[/b] predict move size, and position sizing on the raw probability is not recommended.

[b]Not trading advice.[/b] This is a ranking signal, not a complete strategy. All entries, stops, targets, and risk management are your responsibility.


[b]🟪 How the model works[/b]

The model is deliberately small (~4 000 weights) and conservative:

[list]
[*][b]No hand-crafted TA features.[/b] No RSI, MACD, EMAs, or volume oscillators. Two independent convolutional banks read the raw OHLCV directly: one focused on the immediate trailing bars, the other on a broader strided context.
[*][b]Binary geometric labels.[/b] During training the model learned to recognise "clean upward excursion" shapes: forward windows that break out without being immediately swallowed by adverse retrace. It classifies geometry, not future return magnitude.
[*][b]Frozen linear head.[/b] The concatenated conv features feed a simple linear scorer + sigmoid. Weights were locked at training time. The script never learns from live chart data.
[*][b]Adaptive threshold.[/b] Instead of a fixed cutoff, the indicator tracks a rolling percentile of p_long over the last 1 000 bars. A signal appears only when the current bar's score exceeds the 99.5th percentile of that window. This keeps signal density stable even when the raw probability distribution drifts.
[/list]
The shipped checkpoint was selected on 2021–2024 data and verified on untouched 2025–2026 slices plus three additional out-of-sample tests (cross-pair, multi-year cross-pair, and resampled-timeframe).


[b]🟪 Why this approach exists[/b]

Most trained breakout models fail at deployment because their probability scores drift: a 0.70 on one chart is not comparable to a 0.70 on another. Fixed thresholds either flood the chart with noise or go silent. This indicator's four design choices were deliberately combined to produce a sigmoid output stable enough to be ranked by percentile, which is what lets the adaptive threshold hold up across pairs, regimes, and timeframes:

[list]
[*][b]Binary geometric labels.[/b] The model is trained on a clean "yes/no" question: does the next window contain a clean upward excursion? It learns to discriminate structure, not to regress on return magnitude.
[*][b]Raw OHLCV convolutional banks.[/b] No technical indicators are fed as inputs. The model must discover its own representation of price geometry rather than re-weighting RSI, MACD, or volume oscillators.
[*][b]Linear scorer on concatenated features.[/b] The classifier is kept simple on purpose: a single linear layer plus sigmoid. This forces the convolutional banks to do the real work of representation, extracting price microstructure rich enough for a linear separator to read. A more flexible head would mask weak features behind classifier flexibility; here, the score is only as good as the conv features.
[*][b]Adversarial bull/bear training on a shared backbone.[/b] During training the conv features were pulled simultaneously by an upward-excursion head and a separate downward-excursion head, both writing into the same shared backbone. This competing pressure prevents the features from collapsing into a one-sided "upward bias" detector; they have to discriminate price [i]geometry[/i] on either side. Only the upward head is exposed in this script. Model selection is side-dependent: a checkpoint optimal for upward signalling may not be optimal for downward signalling, so the two sides require separate trained artifacts.
[/list]
Taken together, these choices yield a sigmoid output whose distribution is stable enough for reliable percentile ranking. The rolling 99.5th-percentile rule therefore delivers roughly constant signal density across instruments and market conditions without per-chart retuning.

The frozen weights are not stored data. They encode the trained discrimination function that this specific methodology was designed to produce.


[b]🟪 What the chart shows[/b]

[list]
[*][b]Probability histogram[/b] (violet columns): zone-coloured for instant readability. Grey below 0.30 (noise), faint violet between 0.30 and the effective threshold (warming), bright violet at or above the threshold (signal).
[*][b]Probability EMA[/b] (default 20-bar): a thicker smoothing line. Crosses above the threshold often give steadier candidates than single-bar spikes.
[*][b]Effective threshold line[/b] (dotted): tracks the rolling percentile when Self-Calibrate is ON, or the static slider when OFF.
[*][b]Signal markers[/b]: small violet triangles drawn below price bars on signal closes.
[/list]
The palette automatically adapts to dark or light TradingView themes. Everything is drawn on bar close: no repainting on closed bars.

The first couple of hundred bars are warmup (conv banks + ATR seed + calibration window). The indicator stays silent until all three are ready.


[b]🟪 How to use[/b]

[list=1]
[*]Load on any [b]30-minute crypto chart[/b] (trained on six major USD pairs; cross-pair generalisation tested).
[*]Leave [b]Self-Calibrate Threshold ON[/b] (the default). The script picks its own threshold per bar.
[*]A violet triangle below a bar = the model has nominated that close as a high-confidence breakout candidate.
[*]Pair the signal with [b]your own[/b] entry, stop, target, and sizing rules. The indicator supplies the ranking only.
[*]For alerts: choose "Once Per Bar Close" so you only receive confirmed, non-repainting signals.
[/list]
If you switch timeframes, re-tune the Calibration Window and Calibration Percentile sliders. The defaults are optimised for 30 m crypto.


[b]🟪 Inputs[/b]

Detector group:
[list]
[*][b]Signal Threshold[/b] (default 0.50). Static fallback used only when Self-Calibrate is OFF.
[*][b]Self-Calibrate Threshold[/b] (default ON). ON = rolling percentile (recommended). OFF = fixed slider value.
[*][b]Calibration Percentile[/b] (default 99.5). Signal when score exceeds this percentile of the rolling window.
[*][b]Calibration Window (bars)[/b] (default 1000). Length of the rolling window for the percentile estimator.
[/list]
Performance group:
[list]
[*][b]Score Last N Bars[/b] (default 3000). Limit scoring to the most recent N bars for faster calculation.
[/list]
Display group:
[list]
[*][b]Probability EMA Length[/b] (default 20). Smoothing length for the EMA overlay (cosmetic).
[*][b]Show Probability Histogram[/b] (default ON). Toggle the zone-coloured columns.
[*][b]Show Probability EMA[/b] (default ON). Toggle the EMA line.
[*][b]Show Threshold Line[/b] (default ON). Toggle the dotted effective-threshold line.
[*][b]Show Signal Markers[/b] (default ON). Toggle the below-bar violet triangles.
[/list]

[b]🟪 Reproducibility & third-party audit[/b]

Every column (p_long, p_long_ema, effective_threshold, signal) is a deterministic function of the chart's OHLCV and the frozen weights. Nothing is fetched or fitted at runtime.

Before publication, an independent third-party reviewer re-implemented the exact downstream trade rule (1× ATR stop, 2× ATR target, 100-bar timeout, one position at a time) from the published CSV export and reproduced the in-house numbers to the required precision on both Self-Calibrate ON and OFF modes.

You can export the core columns yourself via TradingView's "Export chart data…" and verify the signal logic in one line: signal = p_long > effective_threshold.


[b]🟪 Limitations[/b]

[list]
[*]Long-only. No short signals.
[*]Not a complete trading system. Entry, risk, and exits are yours.
[*]Trained and verified on 30-minute crypto. Generalisation to other timeframes, equities, forex, or commodities is untested.
[*]Signals finalise on bar close only. The live bar is provisional.
[*]Backtests assume ideal fills. Real-world slippage and fees will reduce performance.
[*][b]Symbol must have a volume series.[/b] One of the model's input channels is normalised volume. Synthetic / aggregate feeds without volume data (e.g. some [b]CRYPTO:*[/b] symbols) will produce an empty pane. Load an exchange-specific symbol instead (e.g. [b]BINANCE:ETHUSDT[/b], [b]COINBASE:ETHUSD[/b]). The indicator will display a message on chart when this happens.
[/list]

[b]🟪 Try it[/b]

Drop the indicator on your favourite 30-minute crypto chart, leave the defaults alone, and watch how the signals line up with the next 80–100 bars of price action. The Pine source is fully visible, the weights are inline, and every plotted value is exportable for your own analysis.

Open source under MIT. Weights frozen. Output auditable. Built for traders who want a transparent, data-driven edge rather than another black-box oscillator.

[b]Not trading advice.[/b] Trade responsibly.


[b]Updates[/b]

[b]v1.0[/b] (2026-05-26): Initial public release. Self-Calibrate ON by default • 30 m crypto training universe • third-party audit passed.


[i]Feedback welcome in the comments below.[/i]

## Source Code

````pine
//@version=6
// Long Excursion Breakout Classifier [Violet]
// Licensed under MIT.
// © FrozenWeights 2026
// Script version: 1.0.0 (2026-05-21)
//
// Frozen, trained linear-on-conv scorer. Two convolutional banks
// read recent OHLCV (no TA inputs); their concatenated features feed
// a linear head that produces a per-bar probability of
// an upward breakout. Weights are frozen at training time;
// the script does not learn from chart data. See the indicator
// description for more context.

indicator("Long Excursion Breakout Classifier [Violet]", "LEBC [Violet]", overlay=false, precision=4, max_bars_back=300)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
float i_threshold = input.float(0.5, 'Signal Threshold', minval=0.10, maxval=0.99, step=0.01,
     group='Detector',
     tooltip='Static fallback threshold, only effective when Self-Calibrate Threshold (below) is OFF. Higher values produce fewer, more selective signals. The recommended signal rule is Self-Calibrate Threshold; this slider is kept as a sanity-check against a fixed-cutoff comparison.')
bool i_use_calib  = input.bool(true, 'Self-Calibrate Threshold', group='Detector',
     tooltip='Default ON. The threshold tracks a rolling percentile of the probability score, so the indicator picks its own threshold per bar and adapts to changes in the score distribution. Disable to fall back to the static Signal Threshold slider for a fixed-cutoff comparison.')
float i_calib_pct = input.float(99.5, 'Calibration Percentile', minval=80.0, maxval=99.99, step=0.1, group='Detector',
     tooltip='Only effective when Self-Calibrate Threshold is ON. A bar produces a signal when its probability score sits above this percentile of the rolling window. Higher percentiles produce fewer, higher-confidence signals; lower percentiles produce more signals with a lower average edge per trade. Re-tune if you move to a different timeframe; the probability distribution shifts.')
int  i_calib_len  = input.int(1000, 'Calibration Window (bars)', minval=100, maxval=5000, step=100, group='Detector',
     tooltip='Rolling-window length used by the percentile estimator. Larger windows give more stable thresholds; smaller windows adapt faster to regime change but become noisy at the extreme percentiles. The default is the result of a (window, percentile) sweep on the training timeframe.')
int  i_score_bars = input.int(3000, 'Score Last N Bars', minval=500, maxval=20000, step=200,
     group='Performance',
     tooltip='Score only the last N bars to keep compute light. The first couple of hundred bars on any chart sit in warmup; the conv backbone and ATR seed both need history before producing a valid score, and Self-Calibrate then needs a full calibration window before the threshold becomes meaningful. Older bars on the chart will be blank. Increase if you want to see more historical signals; decrease if Pine reports calculation-time issues. TradingView\'s per-indicator Calculation setting can also cap historical bars below this value.')
int  i_ema_len         = input.int(20, 'Probability EMA Length', minval=2, maxval=100, step=1,
     group='Display',
     tooltip='Smoothing length for the EMA overlaid on the probability histogram. Cosmetic; does not affect the signal.')
bool i_show_score_hist = input.bool(true, 'Show Probability Histogram', group='Display')
bool i_show_score_ema  = input.bool(true, 'Show Probability EMA',       group='Display')
bool i_show_thr_line   = input.bool(true, 'Show Threshold Line',        group='Display')
bool i_show_fire       = input.bool(true, 'Show Signal Markers',        group='Display')

bool in_budget = (last_bar_index - bar_index) < i_score_bars

// ---------------------------------------------------------------------------
// Shared TA: Wilder ATR(14) + SMA(volume, 20) for normalisation
// ---------------------------------------------------------------------------
float atr14     = ta.atr(14)
float vol_sma20 = ta.sma(volume, 20)

// ===========================================================================
// PHASE 1: Frozen conv banks
// ===========================================================================

// Near bank: 32 filters, kernel=12, channels=5 (OHLCV).
var array<float> sk00_o = array.from(0.09597286, 0.10941841, -0.04689576, 0.11400072, -0.02440340, 0.04215007, -0.06179067, 0.07115112, 0.12050815, -0.10415105, 0.11666986, -0.30149344)
var array<float> sk00_h = array.from(0.14212810, 0.06237680, 0.10846721, 0.04812503, 0.11092686, 0.02094557, -0.01506332, 0.08665965, -0.01775507, 0.01594217, -0.05592681, 0.18263412)
var array<float> sk00_l = array.from(-0.18721782, -0.11530615, -0.10128370, -0.14805321, -0.03364184, -0.17746444, 0.01995906, -0.14239721, 0.02012372, -0.06010432, -0.08356860, -0.21545903)
var array<float> sk00_c = array.from(0.01803728, 0.08011281, 0.00286397, -0.03828342, 0.04605524, -0.03978596, 0.04069585, 0.11463664, 0.06156562, -0.06099968, -0.24957024, 0.02309928)
var array<float> sk00_v = array.from(0.00117682, -0.17025304, -0.16972473, -0.09403349, -0.11597111, 0.06215206, -0.01139121, 0.03400635, 0.00695692, -0.05049857, 0.06958976, -0.09856487)
var array<float> sk01_o = array.from(0.03114410, -0.06117639, 0.05016700, -0.01959879, 0.06879724, 0.01184044, 0.13028285, -0.06055365, -0.04308088, -0.04984066, 0.16627003, -0.28091750)
var array<float> sk01_h = array.from(0.18953542, -0.04177654, -0.05661491, -0.01846005, -0.04595017, 0.08547326, 0.11040404, 0.17716318, -0.00815809, -0.03867022, 0.10937704, 0.01096985)
var array<float> sk01_l = array.from(0.00830653, -0.07275823, 0.02572767, -0.15448602, -0.09493640, -0.00047414, -0.04412928, -0.06015028, 0.01579376, 0.02683515, -0.12169509, -0.26174197)
var array<float> sk01_c = array.from(0.14149509, -0.03997420, -0.02692803, -0.09611800, -0.03847744, 0.05073725, -0.00939413, -0.06653216, 0.02430175, -0.04659244, -0.42629322, -0.07109024)
var array<float> sk01_v = array.from(-0.16200380, -0.15955815, 0.08207530, -0.02670564, 0.01593881, -0.16669340, -0.12325041, -0.05575398, -0.00676595, -0.15123747, -0.08008113, -0.07327732)
var array<float> sk02_o = array.from(0.00236292, -0.05701625, -0.00133073, -0.08884253, -0.10084764, -0.09966682, -0.04893259, -0.11068568, 0.08793961, -0.02191798, 0.08398163, 0.32066357)
var array<float> sk02_h = array.from(-0.17160606, 0.02871281, -0.08752788, -0.12373199, -0.12299133, -0.13474500, -0.01045310, -0.08137716, 0.00661651, -0.14457406, 0.09742995, -0.25207397)
var array<float> sk02_l = array.from(0.05881413, 0.08355747, 0.12991226, 0.16920140, 0.17186762, -0.05359473, 0.12503488, -0.02185054, 0.05806577, -0.01932549, 0.16085587, 0.15755272)
var array<float> sk02_c = array.from(0.06543268, 0.06181958, 0.04846835, -0.07931507, 0.09971426, 0.03113859, 0.01782025, -0.12563206, 0.05949864, -0.03611426, 0.22578657, 0.11088952)
var array<float> sk02_v = array.from(0.09533015, 0.02145096, -0.01634286, 0.03617285, 0.07919370, 0.00991430, -0.03320623, -0.02841151, -0.07043047, 0.09668260, 0.13346624, -0.12044080)
var array<float> sk03_o = array.from(0.00789989, 0.04710229, 0.03311096, -0.05290836, 0.05696576, 0.04195522, 0.03799057, -0.01466030, -0.04602728, 0.00645647, -0.06306610, 0.40095979)
var array<float> sk03_h = array.from(0.02765658, 0.06093408, -0.07602285, -0.10618576, -0.01644731, -0.01439716, -0.02527713, -0.02864483, -0.16155043, -0.07402556, 0.08121283, 0.04630648)
var array<float> sk03_l = array.from(0.07727645, -0.03429554, -0.02063404, -0.04201101, -0.01745624, 0.08819935, 0.17526837, 0.08228441, -0.03390751, -0.00400905, -0.01514815, 0.46767393)
var array<float> sk03_c = array.from(0.00307018, -0.01604323, 0.05305424, -0.05966946, -0.10650234, 0.08886652, -0.04136951, -0.03018622, -0.12807135, 0.05531367, 0.52647001, 0.04705006)
var array<float> sk03_v = array.from(-0.03130740, -0.03699448, -0.06503402, 0.13996221, 0.08240087, 0.14522333, 0.10327774, 0.04141052, 0.03285332, -0.05048965, -0.07425398, -0.11014966)
var array<float> sk04_o = array.from(0.05136577, -0.02867258, 0.01560098, -0.04000859, 0.01687027, -0.05387042, -0.06394944, 0.09409945, 0.00786482, 0.09752509, 0.02528583, 0.17529090)
var array<float> sk04_h = array.from(0.04761003, 0.01014957, 0.01092896, -0.05099832, 0.09352248, -0.07476602, 0.10384450, 0.09442065, 0.12000218, -0.07147483, 0.07483090, 0.16595149)
var array<float> sk04_l = array.from(-0.00417174, 0.08232979, -0.05852305, -0.03359831, -0.07850349, -0.13573970, -0.00194814, -0.15286842, 0.02789108, 0.03136459, 0.08045182, -0.16061319)
var array<float> sk04_c = array.from(-0.07698639, 0.06248398, 0.09793240, -0.09227534, -0.00083234, -0.06519531, 0.03127665, -0.02484897, -0.03219206, 0.01747147, 0.13512154, 0.10592707)
var array<float> sk04_v = array.from(0.05890981, -0.09033517, -0.05312457, -0.07746653, -0.09612298, -0.15568760, 0.03519290, -0.07762043, -0.09543756, -0.07497678, -0.07601697, -0.01516155)
var array<float> sk05_o = array.from(0.01695371, -0.00513174, -0.03982356, -0.04726493, -0.08053789, 0.14493339, -0.03294447, 0.05301517, -0.01691586, 0.01520372, 0.13962728, -0.22800219)
var array<float> sk05_h = array.from(-0.04142073, 0.12015431, 0.18614407, 0.11899710, 0.11185109, 0.14259566, 0.03845439, 0.09088764, -0.03858632, 0.01484683, 0.09495197, 0.21337928)
var array<float> sk05_l = array.from(-0.15351436, -0.14760648, -0.14023639, -0.18328193, -0.13998161, -0.07048202, 0.00100346, -0.00273128, -0.16657378, -0.17943922, 0.02274151, -0.37110767)
var array<float> sk05_c = array.from(0.00113575, 0.05790783, -0.05292414, 0.00816592, 0.01928457, -0.01894196, -0.05666461, -0.09550141, -0.10208378, -0.06001377, -0.16501567, -0.06235693)
var array<float> sk05_v = array.from(-0.15395124, -0.06430422, -0.01338889, 0.02434387, 0.08647663, 0.02911906, -0.16840836, -0.00185562, 0.05109146, -0.06122440, -0.10601012, 0.12049534)
var array<float> sk06_o = array.from(-0.05916082, -0.04839060, -0.08008034, 0.02806257, 0.08614764, 0.05322857, 0.03876913, -0.04487077, -0.08152324, 0.01520166, 0.18810110, 0.44906867)
var array<float> sk06_h = array.from(0.00536780, 0.06645466, -0.05259268, 0.00721045, 0.03533228, 0.07782257, 0.13931392, -0.09026705, 0.11469784, -0.05032403, 0.00429137, 0.53286529)
var array<float> sk06_l = array.from(-0.04699111, 0.07237805, -0.15375322, -0.07934444, 0.00404185, -0.06176933, -0.09542974, -0.08466867, 0.03917390, -0.00342809, -0.01303118, -0.18277857)
var array<float> sk06_c = array.from(-0.08527946, 0.04272673, 0.05328494, -0.03586944, -0.02080402, 0.09210479, 0.05554483, 0.03791505, -0.01283805, -0.05434794, 0.23426698, -0.06171148)
var array<float> sk06_v = array.from(-0.10576282, -0.03228260, -0.08769809, -0.07743404, 0.14045896, -0.00133620, 0.08394635, -0.06735743, -0.05649566, -0.01362140, -0.12175676, -0.04636936)
var array<float> sk07_o = array.from(0.01458290, -0.02576792, -0.10384338, 0.08753299, 0.12218402, 0.05651096, -0.00308883, -0.11382710, -0.02135191, 0.04489527, 0.08566435, -0.42841566)
var array<float> sk07_h = array.from(-0.00637400, 0.10993152, -0.05366157, 0.15513226, -0.04896034, -0.01037431, 0.02517813, 0.08315789, 0.00949920, 0.11786015, -0.01731779, 0.10812473)
var array<float> sk07_l = array.from(0.05042911, -0.08805828, -0.13708051, 0.04182941, 0.09373786, -0.12808943, -0.11269211, -0.11992943, -0.18732381, -0.05676412, 0.04658474, -0.56010622)
var array<float> sk07_c = array.from(-0.01817108, 0.10371467, 0.02220254, -0.05833739, 0.02436158, 0.04471076, 0.04103802, -0.07357696, 0.05410903, -0.05062439, -0.51237285, -0.07051507)
var array<float> sk07_v = array.from(0.05921758, 0.00125330, 0.06744275, 0.02434183, 0.06856705, -0.04903409, -0.11654593, 0.04615596, -0.10343977, -0.13339780, -0.07748326, 0.02249203)
var array<float> sk08_o = array.from(0.02530904, -0.04493893, -0.05960763, 0.03020171, -0.05776356, -0.07430170, 0.05169137, 0.00861354, 0.16014220, 0.13015197, 0.11382303, 0.31862223)
var array<float> sk08_h = array.from(0.10579549, 0.07869732, 0.03412369, 0.07758861, 0.05106900, 0.11436029, 0.00050971, -0.02114489, -0.00275466, -0.02821366, -0.02887329, 0.48027739)
var array<float> sk08_l = array.from(0.02336692, -0.00196262, -0.15824568, -0.12011568, -0.10298193, -0.06671234, -0.08046717, -0.14867206, -0.02444618, -0.17632787, -0.12998269, -0.32248786)
var array<float> sk08_c = array.from(0.11048360, -0.11631378, 0.10036322, 0.00856414, -0.01593241, 0.05483809, 0.00762052, 0.11332760, 0.10096899, -0.04789142, 0.30665010, 0.02437126)
var array<float> sk08_v = array.from(-0.02665617, -0.07041221, -0.01659641, -0.09193887, -0.00201428, 0.07380983, 0.06957535, -0.01577998, -0.13345245, -0.06035391, -0.14461315, 0.12363081)
var array<float> sk09_o = array.from(-0.03709924, 0.01649754, -0.01316831, 0.04610883, 0.13371135, 0.02282497, 0.09285092, 0.09097810, 0.09231910, -0.03817571, -0.04820120, -0.17460264)
var array<float> sk09_h = array.from(-0.08451024, 0.00905395, -0.06739275, -0.13582146, 0.01228873, -0.02255694, 0.00972594, 0.07934747, 0.03446204, 0.06436792, -0.03258403, -0.23500818)
var array<float> sk09_l = array.from(-0.02355484, -0.01080716, -0.04651694, -0.00416058, -0.04612172, -0.05938666, -0.01315622, -0.07169889, -0.02282478, 0.10836057, 0.17070679, 0.02310146)
var array<float> sk09_c = array.from(-0.00883685, 0.08800653, -0.03715632, -0.04543822, 0.09550647, -0.09005524, 0.01007755, 0.10555933, 0.02410088, 0.02052758, -0.29178652, -0.00178113)
var array<float> sk09_v = array.from(0.05212373, 0.08189841, 0.08493766, 0.13294958, -0.09245037, 0.04267627, -0.04920786, -0.08654688, -0.00697734, -0.05817963, 0.09456877, 0.02083306)
var array<float> sk10_o = array.from(-0.02440845, 0.08033864, -0.11380952, -0.03566543, -0.02192260, -0.10756372, -0.06332558, -0.03599741, 0.08472215, 0.14277139, 0.05577773, -0.35981312)
var array<float> sk10_h = array.from(-0.14610347, 0.05018664, 0.01127663, -0.05574405, 0.00684865, -0.10974507, -0.07727180, 0.08948522, -0.06786110, -0.05058721, -0.09734727, -0.34894389)
var array<float> sk10_l = array.from(0.07303225, -0.01091805, 0.05332491, 0.11253542, -0.04462327, 0.09341791, -0.00077757, -0.01551728, 0.11338142, 0.17643504, 0.02444380, 0.08836294)
var array<float> sk10_c = array.from(-0.09782961, -0.04961212, -0.09075042, -0.02137511, 0.03783474, -0.09339719, 0.10662197, 0.07571866, -0.11223470, -0.07825190, -0.21996871, -0.02652472)
var array<float> sk10_v = array.from(0.04593824, 0.02255814, 0.15298830, -0.03673211, 0.09747562, 0.05360671, 0.04924207, 0.11914192, -0.00944621, -0.01749365, 0.01064228, 0.07641875)
var array<float> sk11_o = array.from(-0.06895585, 0.01583475, -0.14048710, 0.05411971, 0.02416057, -0.01793575, 0.05157791, -0.04044724, 0.02526108, -0.11246888, -0.09718710, -0.16548334)
var array<float> sk11_h = array.from(0.06400620, -0.00194372, -0.12886092, 0.02846818, -0.00460330, 0.00814665, -0.13493551, -0.03916034, 0.08679465, 0.01743009, 0.01767591, -0.38613817)
var array<float> sk11_l = array.from(0.01360048, 0.14621924, -0.07603563, -0.01241530, -0.07511717, -0.03237450, 0.12426317, 0.11676968, 0.06669191, 0.18678753, 0.02423653, 0.35078615)
var array<float> sk11_c = array.from(0.09668060, 0.10434301, -0.07659340, 0.09972060, 0.06439897, -0.05455972, -0.09159024, -0.14513083, 0.01951181, -0.17234558, -0.15416384, 0.04076931)
var array<float> sk11_v = array.from(-0.09596926, 0.10081475, 0.03292994, 0.05114158, 0.03282562, -0.08956963, 0.09508830, 0.10571401, 0.05992851, -0.03275616, 0.04592946, -0.03040401)
var array<float> sk12_o = array.from(-0.07026103, 0.08010857, 0.06565222, 0.10916975, -0.03429003, 0.05470182, 0.04600187, -0.06560367, -0.09331283, -0.06030624, 0.15771821, 0.24349515)
var array<float> sk12_h = array.from(-0.04082343, 0.14654627, 0.10415831, 0.16966383, -0.09659432, -0.09636120, 0.09558575, 0.13857616, 0.10186303, 0.05531635, -0.00958494, 0.56015646)
var array<float> sk12_l = array.from(-0.14955568, -0.11698882, 0.03133955, -0.13287888, -0.15240222, 0.05135458, -0.04109056, 0.00737590, -0.11405205, -0.07684867, 0.06489623, -0.21639457)
var array<float> sk12_c = array.from(0.00259199, 0.07223141, -0.08976251, 0.13443431, -0.06251634, -0.03935110, -0.00119150, -0.05956751, -0.11479327, 0.13400204, 0.38172972, -0.12091465)
var array<float> sk12_v = array.from(-0.12365250, 0.04956771, -0.00324124, 0.02314905, -0.05669138, -0.09711412, -0.01953420, -0.02889271, -0.09175260, -0.04968791, -0.03620085, 0.01377700)
var array<float> sk13_o = array.from(-0.01537425, -0.05563455, 0.04861967, 0.05148418, -0.06031846, -0.11462286, 0.08017683, 0.08158986, -0.04384857, 0.12197047, -0.02227508, 0.54887629)
var array<float> sk13_h = array.from(0.10697156, -0.05710646, 0.07593248, -0.10222489, -0.09296124, -0.03488014, -0.09370903, 0.10662376, -0.03090947, 0.09123316, -0.22541229, 1.10805368)
var array<float> sk13_l = array.from(-0.04868186, -0.12213412, 0.00204343, 0.06609754, 0.03047246, -0.09575942, -0.10162728, -0.00766126, 0.00768588, -0.00582408, 0.02813941, 0.13977140)
var array<float> sk13_c = array.from(0.06319324, 0.10563198, -0.03549064, 0.09410407, 0.06810171, 0.12008425, -0.02660794, -0.04575310, -0.03002946, 0.03803628, 0.51447195, -0.07369805)
var array<float> sk13_v = array.from(0.06150189, -0.05557759, 0.06198569, -0.00828337, -0.06045129, -0.09230943, -0.07127719, 0.06120394, -0.07552201, -0.04981012, 0.01289899, 0.01090129)
var array<float> sk14_o = array.from(0.03563055, -0.12307502, -0.10888565, -0.12326390, -0.04263294, -0.04254336, 0.00811599, -0.04362689, 0.05089078, 0.09882837, 0.04471444, -0.35494164)
var array<float> sk14_h = array.from(-0.07176428, 0.09400378, -0.01245170, 0.12994342, 0.09726447, 0.05210008, 0.16216187, 0.17106222, 0.06202675, -0.06795324, 0.13085409, 0.01275956)
var array<float> sk14_l = array.from(-0.14554068, 0.05450855, 0.03624695, -0.03384493, -0.03854559, -0.16394234, -0.10947486, 0.08336496, -0.05135591, -0.07002352, -0.05740311, -0.28694865)
var array<float> sk14_c = array.from(0.07620560, -0.01542187, 0.07159454, -0.02697556, 0.05742657, 0.03809672, -0.00758792, 0.06453123, 0.05605207, 0.10976799, -0.19859290, -0.03301030)
var array<float> sk14_v = array.from(-0.16496406, -0.05638549, -0.04578496, -0.08537658, -0.04416515, -0.04266839, 0.03973808, 0.01050590, -0.08306551, -0.09584147, -0.06541943, -0.04299978)
var array<float> sk15_o = array.from(0.10233799, 0.07140891, 0.10371390, 0.00009439, 0.03986653, 0.07266816, -0.11364931, 0.03112844, 0.03119565, -0.05583177, -0.04083678, -0.15488820)
var array<float> sk15_h = array.from(0.16421534, 0.11736102, 0.17254190, 0.02243148, -0.01174716, 0.05194916, 0.02923081, 0.03278218, -0.05837602, 0.07759475, -0.07600843, 0.17673846)
var array<float> sk15_l = array.from(0.03351958, -0.10174178, -0.10959423, 0.01051535, -0.09932258, -0.05402014, 0.03000254, -0.07346652, -0.15581003, -0.13801910, -0.05681901, -0.33220229)
var array<float> sk15_c = array.from(-0.06979720, 0.02968210, 0.01299930, -0.03025006, -0.07954904, -0.04016835, -0.04558390, -0.01125872, -0.10199328, 0.07615562, -0.36908525, -0.10054254)
var array<float> sk15_v = array.from(-0.16650316, -0.03738607, -0.12485475, -0.09694978, 0.09201343, 0.01750491, 0.03831191, -0.13904655, -0.11846756, -0.10822615, 0.05797849, 0.01587520)
var array<float> sk16_o = array.from(-0.06468463, 0.02745042, -0.10524425, -0.01438768, -0.01658269, 0.14699104, 0.06217220, -0.02354543, 0.03880203, -0.02385347, 0.07212660, -0.32632738)
var array<float> sk16_h = array.from(0.00976864, -0.08046258, 0.09012859, -0.03045983, -0.11195400, 0.00514526, 0.06849944, 0.09661426, -0.00910434, -0.10696159, 0.00312647, 0.01186004)
var array<float> sk16_l = array.from(-0.08815626, 0.05673778, -0.02779908, 0.06852762, 0.14115302, 0.04074645, 0.01558219, 0.14527424, 0.01952096, -0.06171377, 0.20749168, -0.24958973)
var array<float> sk16_c = array.from(0.00905952, 0.00034258, 0.00053759, -0.10232414, 0.09214637, -0.04052753, -0.07611791, 0.04142186, -0.06036971, -0.04569468, -0.41287887, -0.04849977)
var array<float> sk16_v = array.from(-0.04643764, -0.02634842, 0.05433218, -0.08555894, -0.05137160, 0.05272415, 0.01273418, 0.05620749, -0.09763321, 0.02590552, 0.04015903, 0.03626829)
var array<float> sk17_o = array.from(-0.10951557, -0.01756555, -0.08259813, -0.05713041, 0.10368348, 0.01438221, 0.06874582, -0.04414970, 0.05210762, -0.07130916, 0.10199185, 0.07323699)
var array<float> sk17_h = array.from(0.04502079, -0.03458458, 0.06096392, 0.19728072, 0.09838668, -0.03886628, 0.05250300, 0.03615078, -0.05741470, 0.14792486, 0.01795237, 0.18879679)
var array<float> sk17_l = array.from(-0.10307960, -0.10142387, -0.02292933, 0.00514279, -0.02308265, -0.10338587, 0.05749827, -0.05642332, -0.13661787, -0.12522359, 0.07783397, -0.12827371)
var array<float> sk17_c = array.from(0.00910264, -0.03294200, -0.01621899, -0.08051049, -0.07622468, 0.08225182, 0.13385148, 0.14849193, -0.08507988, 0.09838019, 0.03499522, 0.07701559)
var array<float> sk17_v = array.from(0.03120454, 0.02211020, 0.04019900, 0.03897467, 0.00022826, 0.01991572, -0.06546401, 0.04479944, -0.05293474, -0.04822774, -0.12960497, -0.02076475)
var array<float> sk18_o = array.from(-0.04137447, -0.02848255, -0.09132634, -0.11654448, 0.01365091, 0.09274171, 0.12226623, 0.06078660, -0.06309555, -0.11608882, 0.04410137, -0.27798381)
var array<float> sk18_h = array.from(-0.13173915, 0.01813247, 0.10415642, 0.00387838, -0.10357058, 0.06899625, 0.04626585, 0.08728010, -0.10063402, 0.03128054, -0.11806882, -0.16747029)
var array<float> sk18_l = array.from(-0.04676013, 0.11111440, 0.05124175, 0.04545784, 0.05411431, 0.09453833, -0.03216622, -0.05001515, -0.01526337, 0.14520022, 0.03119324, -0.26770151)
var array<float> sk18_c = array.from(-0.03363064, 0.08515137, 0.07468435, 0.05235125, -0.05619563, -0.10157172, -0.01372278, -0.07469184, 0.11098681, -0.13241845, -0.28147939, 0.12870105)
var array<float> sk18_v = array.from(0.04564516, 0.01365691, -0.12560891, 0.11929429, -0.03951302, -0.09234027, 0.09640969, -0.06294130, -0.01968648, 0.11697589, -0.08527346, -0.18547465)
var array<float> sk19_o = array.from(-0.00748972, -0.01822447, 0.04406393, -0.10238367, 0.01852472, -0.04289982, -0.05267500, -0.07195395, 0.09594360, 0.03235417, -0.04517910, 0.50017124)
var array<float> sk19_h = array.from(0.10278419, 0.09310794, -0.05027557, 0.06925472, 0.13512461, 0.10198891, -0.07347770, 0.13822661, 0.03964998, 0.11633262, 0.07320454, 0.60390186)
var array<float> sk19_l = array.from(-0.14444865, 0.06211128, -0.13477559, -0.02069525, -0.17449331, -0.06910165, -0.06949104, -0.05967113, -0.06930405, -0.05481963, 0.06902639, 0.05539767)
var array<float> sk19_c = array.from(0.06719418, 0.06101273, 0.10100595, 0.00383884, 0.01691883, 0.03098770, -0.07102098, -0.08099208, 0.03097202, 0.00824307, 0.37523669, -0.02962300)
var array<float> sk19_v = array.from(0.00041918, 0.02911337, -0.08370900, 0.08667704, 0.12670614, -0.13715568, -0.08806385, -0.10332042, -0.06588832, -0.09737805, -0.04679426, 0.02469125)
var array<float> sk20_o = array.from(-0.06439977, -0.06485244, -0.07136671, 0.10367532, -0.08357798, -0.13072053, 0.03426510, -0.05110913, 0.05399673, 0.06918992, 0.08132766, -0.21670412)
var array<float> sk20_h = array.from(0.00297227, 0.02809449, -0.12134181, 0.03956077, 0.05969115, -0.03022830, 0.00821173, -0.09832517, -0.16418444, -0.02230343, 0.03466981, -0.30491719)
var array<float> sk20_l = array.from(0.11594398, -0.06424929, 0.15735421, 0.16302942, 0.09127168, -0.04438464, 0.12815879, 0.05456633, 0.08588477, 0.10409021, 0.15201944, 0.07828694)
var array<float> sk20_c = array.from(-0.04752210, 0.01826719, -0.00174421, 0.07270107, -0.09779273, -0.01621541, -0.01140377, -0.07186095, 0.07328881, -0.01418769, -0.22201009, -0.01398610)
var array<float> sk20_v = array.from(0.00070296, 0.09104822, 0.03693998, -0.08988831, -0.02812327, 0.02833265, -0.01502935, 0.13339292, -0.01312284, 0.13615803, 0.06384634, -0.12262145)
var array<float> sk21_o = array.from(0.00371205, 0.08173754, -0.07163372, -0.09982347, 0.09743573, 0.04949921, -0.10256705, 0.06549462, -0.06506085, -0.16575606, -0.10769464, 0.56773406)
var array<float> sk21_h = array.from(-0.05003396, 0.04313533, -0.12852708, 0.04253953, 0.15058006, 0.13237490, 0.01108295, 0.01913401, -0.08884729, -0.00046273, 0.02745552, 0.02514733)
var array<float> sk21_l = array.from(-0.04346928, 0.07028016, 0.09360498, -0.09994282, -0.02887111, 0.01926571, 0.18688461, -0.01787469, 0.14575516, -0.03272970, -0.08231959, 0.87314433)
var array<float> sk21_c = array.from(-0.14182557, -0.08070528, 0.01835212, 0.04191632, -0.11403958, -0.00958992, -0.00069065, -0.00643466, -0.10006380, -0.03336659, 0.60269940, -0.08957671)
var array<float> sk21_v = array.from(0.03132803, 0.06793987, 0.06964424, 0.12717959, 0.03629677, -0.02728296, 0.13576965, -0.02455654, -0.00765601, 0.06312523, -0.01292474, 0.03356424)
var array<float> sk22_o = array.from(-0.05748957, 0.03939418, 0.00855890, 0.03401253, -0.08827659, -0.08564568, 0.08365887, 0.10736331, -0.09855726, 0.05981847, -0.08206918, -0.41376790)
var array<float> sk22_h = array.from(0.13308319, 0.09733743, -0.07365657, 0.11806839, 0.03994126, -0.04513416, 0.13838959, -0.02231632, -0.02600396, -0.09957109, -0.05215426, -0.21037054)
var array<float> sk22_l = array.from(-0.03330855, -0.06455575, -0.06757631, 0.01792869, -0.06199221, -0.00844521, -0.06735078, -0.00107011, -0.00849278, -0.05150923, 0.13464558, -0.80620402)
var array<float> sk22_c = array.from(-0.05900708, 0.08017200, 0.02798552, -0.01584544, -0.05031248, 0.05022284, -0.13543244, 0.04307754, 0.06793811, -0.10858052, -0.49537954, -0.09281293)
var array<float> sk22_v = array.from(0.06218372, 0.02006876, -0.01861808, 0.09002732, -0.07711351, -0.12654364, -0.00389428, 0.02994948, 0.10084999, -0.03953905, 0.05515511, 0.04218529)
var array<float> sk23_o = array.from(0.11425419, -0.12612204, 0.11287094, -0.10368156, 0.11193454, -0.01307903, -0.10249888, 0.03414718, -0.02687197, -0.08604503, -0.04720505, -0.03761075)
var array<float> sk23_h = array.from(0.04353247, -0.09739402, 0.03508725, -0.04513283, -0.00650562, 0.02122805, -0.11681265, -0.14056118, -0.06689908, -0.14744662, -0.05044191, -0.18408981)
var array<float> sk23_l = array.from(-0.01415491, 0.00172902, 0.03595238, 0.04075601, -0.00978811, 0.05446516, 0.06461567, 0.07794175, 0.07482100, 0.01122114, 0.00298865, 0.15901639)
var array<float> sk23_c = array.from(-0.07348749, 0.02454634, 0.00445685, 0.04958843, 0.03004794, 0.11584718, 0.00259198, -0.08860470, 0.08673985, -0.07860895, -0.05615291, -0.04180275)
var array<float> sk23_v = array.from(0.00906964, 0.02645837, 0.15784913, 0.10826731, 0.03093481, 0.16205700, -0.07346527, 0.05295445, 0.10882722, 0.13744260, -0.06811549, 0.03164291)
var array<float> sk24_o = array.from(-0.04888118, 0.01807708, -0.03254734, -0.09313133, -0.10296901, -0.05017544, 0.07487989, 0.06145813, -0.08447745, -0.02923308, 0.04123735, -0.55109346)
var array<float> sk24_h = array.from(0.12510702, 0.16270466, 0.08457986, -0.01406787, 0.04417992, 0.04613106, 0.15900391, 0.00493077, -0.06201094, 0.08591564, 0.01491718, -0.05968697)
var array<float> sk24_l = array.from(-0.13824692, -0.10314000, 0.05094036, -0.08900567, 0.08206708, 0.07789449, -0.08494597, 0.02521854, -0.08777834, 0.01498765, -0.10566238, -0.43087220)
var array<float> sk24_c = array.from(-0.00191777, 0.04563469, 0.00742288, -0.02753490, 0.01785237, 0.08102213, -0.09655298, -0.06124052, -0.01695596, -0.01665847, -0.37929067, 0.08688003)
var array<float> sk24_v = array.from(-0.07654817, 0.01654143, -0.09714177, -0.12005252, -0.08447182, -0.13236491, -0.13322365, -0.12811404, -0.14826439, -0.01515765, 0.03331260, 0.11943290)
var array<float> sk25_o = array.from(0.10479023, -0.00425211, 0.00444740, -0.08360934, 0.05516145, -0.10321014, 0.06103573, 0.01964918, 0.04871811, 0.03244736, -0.05473162, -0.23477279)
var array<float> sk25_h = array.from(0.09240701, 0.11045326, 0.03850076, 0.13342729, 0.05826441, 0.01446453, 0.11489439, 0.00737774, 0.10453121, 0.03666356, 0.01452346, 0.28797379)
var array<float> sk25_l = array.from(-0.05341866, -0.08974132, -0.06823517, -0.02367562, -0.01084465, -0.07114091, -0.01813596, 0.06596193, -0.17071298, -0.10739101, -0.03130800, -0.60403812)
var array<float> sk25_c = array.from(0.01629438, -0.06991245, -0.08154450, -0.03859404, -0.03201101, 0.11591154, 0.03446312, 0.12700227, 0.01775193, 0.02292253, -0.29390043, 0.02215766)
var array<float> sk25_v = array.from(-0.16726172, -0.17991185, -0.07776114, -0.04067236, 0.02861401, 0.02377694, 0.04653549, -0.00122072, -0.07277583, -0.14801985, -0.13454358, -0.08284873)
var array<float> sk26_o = array.from(0.04182243, 0.05711003, 0.11324493, -0.04657838, -0.02749261, -0.06614397, -0.00844705, 0.02390084, -0.02813705, 0.00760557, -0.01482498, 0.23244406)
var array<float> sk26_h = array.from(-0.10790142, -0.14495896, -0.02537402, -0.09255990, -0.08153664, 0.03936803, -0.04998919, -0.07306701, -0.10877964, -0.06104165, -0.11619199, -0.14561813)
var array<float> sk26_l = array.from(0.07786162, 0.13448362, 0.06927709, 0.07102956, 0.09212831, 0.14525577, 0.02452459, 0.11365183, 0.09937058, -0.01159789, 0.09205568, 0.13230583)
var array<float> sk26_c = array.from(-0.04747879, -0.05208067, -0.08531075, 0.08765549, -0.13564283, 0.06469844, -0.12352551, -0.03232093, 0.00984851, 0.07133076, 0.14629896, 0.03715837)
var array<float> sk26_v = array.from(0.08542354, 0.16513191, 0.05512255, 0.08827969, -0.07545915, -0.04651250, 0.14890711, -0.07987995, -0.00016933, 0.03640863, 0.15759343, -0.03467079)
var array<float> sk27_o = array.from(-0.05861088, -0.02806897, 0.06706499, 0.05402979, 0.09751280, -0.03501576, 0.07258438, -0.14471065, 0.02543866, 0.07659999, 0.06868968, -0.26108015)
var array<float> sk27_h = array.from(-0.10134373, -0.03646948, -0.12840322, -0.16799873, -0.12956640, 0.00696771, 0.04686671, -0.00074370, -0.02401956, 0.00811226, -0.03860996, -0.31460628)
var array<float> sk27_l = array.from(0.04035175, -0.00230262, 0.17367931, -0.04930250, 0.09448845, -0.06765537, 0.07939446, -0.02327040, 0.10168926, -0.00104428, 0.13923378, 0.06321071)
var array<float> sk27_c = array.from(0.08824963, -0.08779790, 0.08014873, -0.05879219, 0.00047040, -0.00287873, 0.06951535, 0.02590224, -0.10034721, 0.00707249, -0.25514668, 0.09650977)
var array<float> sk27_v = array.from(0.08410553, 0.05547927, -0.01241902, 0.08000281, -0.08322760, 0.10473301, 0.08963881, 0.10087664, 0.04894084, -0.04707375, 0.14025536, -0.05825615)
var array<float> sk28_o = array.from(-0.02044212, -0.03668516, 0.05893548, 0.07544990, -0.00816218, 0.04134921, -0.12237051, -0.04376859, -0.15749116, 0.02615166, -0.18184485, -0.38502151)
var array<float> sk28_h = array.from(0.00413059, 0.03615229, -0.13004380, -0.14944285, -0.01021271, 0.02986844, -0.06392464, -0.07869554, -0.12308903, 0.00718371, 0.14773683, -0.38793501)
var array<float> sk28_l = array.from(0.11361781, 0.11036897, 0.15106916, 0.02017760, 0.07134386, 0.13198170, 0.15238081, 0.16203994, 0.01748822, 0.11784551, 0.14467217, 0.03787230)
var array<float> sk28_c = array.from(0.00858234, -0.05646997, 0.06668202, -0.08101707, -0.00189430, 0.08364214, -0.15432930, -0.14484009, -0.08867510, 0.00110286, -0.23459579, -0.08817105)
var array<float> sk28_v = array.from(0.07470302, 0.00828530, -0.00835923, 0.13989417, 0.04877047, 0.00790124, 0.02809204, 0.03396945, 0.04131762, 0.01882896, -0.02692867, 0.05205342)
var array<float> sk29_o = array.from(-0.01950463, 0.04090963, -0.04155647, 0.05610398, 0.09524552, 0.07661170, 0.03487718, 0.16252555, 0.00910457, 0.01919831, 0.14729489, 0.57897609)
var array<float> sk29_h = array.from(-0.02554758, 0.15246709, 0.03121064, -0.01508837, 0.09463506, -0.07546792, 0.06906836, 0.10103596, -0.09626935, -0.03856241, -0.19441707, 0.73924184)
var array<float> sk29_l = array.from(-0.12712587, -0.07579903, 0.01416655, 0.08535086, -0.01871222, 0.04176544, 0.01703165, -0.12741694, -0.12916993, -0.04321868, 0.08007863, 0.23715560)
var array<float> sk29_c = array.from(-0.02694502, -0.08279139, -0.07306223, -0.10289263, 0.09483065, -0.02585451, -0.08028983, 0.02125747, 0.01075029, 0.00629093, 0.47727898, 0.06942700)
var array<float> sk29_v = array.from(-0.11568493, -0.08681308, -0.01553067, -0.12370195, -0.07932835, 0.09043577, 0.00823388, -0.06119814, -0.02981654, -0.11292857, 0.10615556, 0.09204066)
var array<float> sk30_o = array.from(-0.04402215, -0.09964521, 0.05598868, -0.02469504, -0.02861783, -0.04923792, -0.07106790, -0.02063444, 0.07055622, -0.08214185, -0.06620299, -0.46030852)
var array<float> sk30_h = array.from(-0.12630847, 0.04273078, -0.02872452, 0.06781963, -0.02697282, -0.07291037, -0.10285974, 0.09322450, -0.12325347, 0.02595676, 0.06757191, -0.40926978)
var array<float> sk30_l = array.from(0.12692882, 0.01939109, 0.13116959, -0.06551842, 0.03564519, 0.13597934, 0.11067569, 0.02282461, 0.02381834, -0.01083264, 0.12958242, 0.07944842)
var array<float> sk30_c = array.from(-0.00109578, 0.01765287, 0.09468539, -0.07596464, -0.05145334, 0.08619720, 0.03591388, -0.08631455, -0.14149161, -0.04152202, -0.27541992, 0.03083633)
var array<float> sk30_v = array.from(0.12097497, -0.03581000, 0.10655753, -0.06393384, 0.04548013, 0.13538730, 0.03700951, 0.10321968, -0.08362266, -0.05928813, -0.08129914, 0.03529021)
var array<float> sk31_o = array.from(0.03085783, -0.11682193, 0.05991544, 0.10358564, -0.15001369, 0.05756889, 0.00190351, -0.00476971, 0.08495130, 0.10415800, 0.01635545, 0.42951840)
var array<float> sk31_h = array.from(-0.01395626, -0.04444937, -0.17671719, -0.05821809, -0.11619577, 0.02445655, -0.03505173, -0.06201186, -0.14039965, -0.12083965, 0.08471210, -0.05497692)
var array<float> sk31_l = array.from(0.14359166, 0.00727146, 0.03217589, 0.02670715, 0.12743196, -0.01554094, 0.16694479, 0.11214206, -0.05038464, 0.07126378, 0.00701705, 0.19860636)
var array<float> sk31_c = array.from(0.03840995, -0.00980421, 0.10633589, -0.10172154, 0.02943846, -0.12139729, -0.07160482, -0.01422211, 0.09280591, 0.03996246, 0.22099563, 0.01429976)
var array<float> sk31_v = array.from(-0.01099192, 0.09808503, -0.05776127, 0.01050607, 0.10357907, -0.07281724, -0.08003778, 0.03804228, 0.04478300, 0.02750332, 0.14558837, -0.08184768)

var array<float> sk_bias = array.from(0.18973418, 0.05236066, -0.30626991, -0.28387195, 0.30431804, 0.28939277, 0.41328892, 0.37666279, 0.54076135, 0.01444179, -0.39504233, -0.56881320, 0.27711108, 0.57077128, 0.07854284, 0.23320138, 0.23247398, 0.04254121, 0.14707887, 0.33657265, -0.11430247, -0.56002790, 0.53369665, -0.19594413, 0.33779967, 0.62659109, -0.38525701, -0.43708006, -0.15291895, 0.24487318, -0.45616317, -0.26304895)

// Far bank: 16 filters, kernel=20 = 20 strided samples, channels=5.
var array<float> lk00_o = array.from(0.00116701, 0.01107833, -0.05506090, 0.03704518, -0.03509758, 0.01720368, 0.04972542, 0.03349973, 0.04363714, 0.04266554, -0.06871042, -0.02607965, -0.04037215, -0.03800793, -0.02555360, 0.16488795, -0.05811636, 0.00211123, 0.07547013, -0.31174266)
var array<float> lk00_h = array.from(-0.01957755, -0.04108401, -0.00550762, 0.05231952, -0.03342804, 0.00546127, 0.03892887, 0.09535739, 0.07388858, 0.01531741, 0.07679562, 0.06021165, 0.05803233, 0.00464953, -0.00569229, 0.07039575, 0.06143374, 0.11140681, 0.02940496, 0.06470986)
var array<float> lk00_l = array.from(0.06755902, -0.02859659, -0.08733763, -0.02280932, -0.00610468, 0.05039019, -0.08422219, -0.00765336, -0.01172068, -0.05559429, 0.02738998, -0.04842272, -0.04645751, -0.09363635, 0.02744417, -0.01392292, -0.08556609, -0.15482722, -0.01519569, -0.28579149)
var array<float> lk00_c = array.from(-0.03978448, -0.06450957, -0.01086367, -0.06965138, 0.11577271, -0.03696110, -0.03600471, 0.02210819, 0.05180692, -0.03255410, 0.08734186, -0.05057530, 0.02453079, 0.01881075, 0.00207179, -0.01321540, 0.03580059, 0.00548297, 0.05924803, 0.06689930)
var array<float> lk00_v = array.from(0.01589311, 0.01270831, 0.01181083, -0.13342577, 0.03200209, -0.08246338, 0.04123015, 0.05093011, 0.04880704, -0.06080526, -0.07964174, 0.03128801, 0.10016303, -0.01581562, -0.03667701, 0.19640541, 0.20102672, 0.10119288, -0.10755876, 0.00691301)
var array<float> lk01_o = array.from(0.04044391, -0.09345213, -0.08932047, -0.03031354, 0.06288363, 0.02529719, -0.09173711, -0.10345602, 0.01117534, -0.00262857, -0.02662987, -0.06047600, 0.05000032, 0.01056569, 0.07797099, -0.02407782, -0.03618887, -0.04322106, -0.05760802, -0.28872776)
var array<float> lk01_h = array.from(-0.10340288, 0.06806177, -0.01003434, -0.00833022, 0.06929924, -0.01203784, 0.01608820, 0.05130924, -0.06041909, 0.04007631, -0.04140729, -0.03802961, -0.00336644, 0.06607620, -0.00506588, -0.01415143, 0.07598236, -0.02479559, 0.04001055, -0.19256073)
var array<float> lk01_l = array.from(0.01602288, 0.07348296, -0.06109714, -0.03973710, 0.07056150, -0.02554813, -0.05125485, -0.09410911, 0.09431341, -0.01801784, -0.05425837, -0.05410985, -0.05965176, 0.01994340, 0.03449641, 0.05464469, -0.07388639, -0.08824407, 0.01544012, -0.33640188)
var array<float> lk01_c = array.from(-0.02883236, 0.01380359, 0.06228799, 0.03084587, 0.08240790, 0.04110036, 0.00515115, 0.02572275, 0.04984915, -0.03573559, 0.08506599, 0.07979846, 0.00542833, -0.01147336, 0.16661061, -0.08731353, 0.05960146, 0.02482471, 0.03812876, -0.00768356)
var array<float> lk01_v = array.from(0.01362621, 0.10744126, 0.00557834, -0.07430623, 0.08211764, -0.10770710, -0.01698693, -0.05975338, 0.08850142, -0.04084499, -0.00291450, 0.11186873, 0.09126304, 0.06858627, -0.03964589, 0.01783101, 0.18705963, 0.14166534, -0.07871423, -0.13947257)
var array<float> lk02_o = array.from(-0.02191350, -0.04507849, 0.05716576, 0.05182202, 0.08042065, 0.05106162, -0.05932747, -0.04306734, -0.02165876, -0.05300763, 0.08837076, 0.02266744, 0.05512739, -0.00839892, -0.06051536, -0.03184032, 0.02822299, 0.03424526, 0.02701295, -0.35446885)
var array<float> lk02_h = array.from(-0.12010027, -0.08157231, -0.01128691, -0.06039950, 0.04836306, -0.00714523, -0.04797044, 0.04058057, -0.05140578, -0.01177214, -0.08677222, -0.11355110, -0.06269357, -0.03263864, -0.04394418, -0.00608799, -0.22426443, -0.28572676, -0.12864451, -0.35547400)
var array<float> lk02_l = array.from(0.04085186, 0.02172625, 0.07150064, -0.07404853, 0.03856854, 0.00893625, 0.03740507, 0.12876061, 0.11966323, -0.06623048, -0.08295920, 0.01804465, 0.01844638, 0.09833382, 0.08492188, 0.13849105, 0.15245363, 0.16438001, 0.05617291, 0.10031694)
var array<float> lk02_c = array.from(0.00627319, 0.08570825, -0.07457133, 0.06868440, -0.03590440, -0.10958552, -0.03524336, 0.03952653, 0.10435393, 0.01413288, -0.01878779, -0.00229267, -0.03527323, -0.00655552, 0.05814379, 0.03835526, 0.03876438, -0.08336514, -0.01453726, -0.06150699)
var array<float> lk02_v = array.from(0.02822958, -0.10818762, 0.09808522, -0.03904584, 0.05106019, 0.09277604, -0.05764752, -0.05088340, -0.01672675, 0.07653509, -0.04910162, -0.03421661, 0.00256960, -0.04492420, 0.01691747, -0.05225489, -0.10225675, 0.10824152, -0.03138759, -0.07657959)
var array<float> lk03_o = array.from(-0.02129059, -0.06902741, -0.00205704, 0.03194390, 0.03001813, -0.03539761, 0.00592821, -0.05176064, -0.01345561, 0.02548917, 0.08208412, -0.03605960, 0.04554160, -0.00942373, 0.01879910, -0.03608251, 0.02927871, 0.05948164, 0.00220430, -0.29929399)
var array<float> lk03_h = array.from(0.08398826, 0.04823218, 0.02999434, -0.09239633, -0.05269086, -0.08271959, 0.03108317, -0.07790712, -0.04900946, -0.04851205, -0.11203922, -0.00097011, -0.02101301, -0.07748294, 0.12461919, -0.01893553, -0.08355527, -0.02597161, 0.03562388, -0.33735365)
var array<float> lk03_l = array.from(-0.02948962, -0.00414552, 0.04700182, 0.10358940, 0.10695092, -0.02988254, -0.08600958, -0.04335796, 0.03406139, 0.01784136, -0.03872577, -0.03852708, 0.04805639, -0.03387647, 0.02812455, -0.03778096, 0.01454653, 0.16762273, 0.08427573, -0.10186782)
var array<float> lk03_c = array.from(0.04526396, 0.05313561, 0.01641864, -0.03831884, -0.01170067, -0.06660929, 0.00151930, -0.07122562, 0.03842921, -0.04719741, 0.12208251, 0.09839131, 0.06689109, 0.02996980, 0.08474599, 0.02448027, -0.06553398, -0.05105216, -0.03033457, -0.02349547)
var array<float> lk03_v = array.from(-0.04179397, -0.00010100, 0.13316225, -0.13992220, -0.01707098, -0.06270763, -0.05408112, -0.01886893, 0.05668468, 0.07341928, -0.21566033, -0.01914253, 0.01148459, 0.01286290, -0.01399480, 0.01681490, -0.10004216, 0.10076950, -0.04001467, -0.06080811)
var array<float> lk04_o = array.from(0.04891267, 0.09575866, 0.03966864, 0.03103527, 0.08807564, 0.06736791, 0.01406732, 0.05193340, 0.02064678, -0.03091553, -0.01459490, -0.01610996, 0.09348163, 0.08470585, -0.02384435, 0.10783266, -0.03897402, 0.08163321, 0.08408412, 0.18586168)
var array<float> lk04_h = array.from(-0.02696302, 0.01980638, 0.05556656, 0.03789032, -0.05572431, 0.06601513, -0.01365710, 0.02565142, 0.01389610, 0.02470532, -0.02562790, -0.01595063, 0.07954942, 0.12615843, 0.10816204, 0.00155782, 0.15107995, 0.08379435, -0.02024777, 0.14074042)
var array<float> lk04_l = array.from(-0.11626208, -0.12755908, -0.11372818, -0.08375612, 0.06511100, 0.03023806, -0.06570419, -0.09542581, -0.12362909, -0.04106833, -0.05930938, 0.00321865, -0.06799638, -0.12776347, -0.02565221, -0.14908391, -0.20599267, -0.13196903, -0.10514594, -0.05636770)
var array<float> lk04_c = array.from(0.08016532, -0.03458021, -0.05106423, 0.03498706, -0.09379584, 0.11488000, -0.02447065, 0.07582738, -0.08134034, -0.03771148, 0.03512150, 0.03336043, 0.05014182, 0.07084281, -0.06081245, 0.03326954, 0.02843135, -0.03688319, 0.00081298, -0.09470483)
var array<float> lk04_v = array.from(-0.08904211, 0.10525688, -0.08813655, 0.04422970, 0.04484950, 0.01090674, 0.07764440, -0.07678244, 0.00059290, -0.01867568, 0.07106306, -0.06691347, 0.05915941, -0.07958565, -0.03192578, 0.11404110, 0.09196021, -0.01847539, -0.08234359, 0.05954067)
var array<float> lk05_o = array.from(0.04395767, 0.00660243, -0.04313286, -0.03986027, 0.04503037, 0.07298678, 0.06427854, -0.09055784, 0.04969673, -0.02596544, 0.10212111, 0.10368188, 0.02708841, -0.05123078, 0.08059929, -0.09634121, 0.11883774, -0.06305362, -0.03905820, 0.21736071)
var array<float> lk05_h = array.from(-0.04736155, 0.04374404, -0.06030983, -0.08264971, 0.03920029, 0.05451977, 0.00312318, -0.07439072, -0.05066685, -0.02325860, 0.07634112, -0.02841642, -0.00637549, -0.05889568, -0.09204122, 0.01498664, 0.06281371, 0.01835107, -0.04012000, 0.69795966)
var array<float> lk05_l = array.from(0.01051198, -0.05471200, -0.04161792, -0.03527805, 0.01248657, 0.03961895, 0.08318641, -0.01987449, 0.05359909, -0.04069028, -0.03088565, -0.04271437, -0.07913983, -0.05895584, -0.13791236, 0.00178044, 0.02501833, -0.01011329, -0.05743835, 0.50183207)
var array<float> lk05_c = array.from(-0.03935434, 0.04927829, 0.07032353, -0.08486611, -0.04114379, 0.05947244, 0.09867480, -0.02076246, 0.04109944, -0.05493309, -0.07603484, 0.08180577, 0.00584811, 0.09655561, -0.06792422, -0.03564180, 0.09369741, 0.09735084, 0.01780177, -0.06062054)
var array<float> lk05_v = array.from(-0.12383284, -0.09153771, -0.01922755, 0.09665305, 0.00441870, 0.06064455, 0.04925818, -0.04719531, 0.06095076, -0.01187990, 0.02353668, 0.00523550, 0.03835595, -0.00260778, -0.01396049, -0.13368326, -0.16343939, -0.11168195, 0.13997540, 0.04741231)
var array<float> lk06_o = array.from(0.06503468, -0.05285877, 0.00766637, -0.06224601, -0.04453209, 0.03423452, 0.05424173, -0.01042425, -0.06937798, 0.04746648, 0.10791150, 0.02315069, -0.04310267, -0.00108713, -0.01703887, 0.03372949, 0.04510549, 0.02908384, -0.00961304, 0.32027969)
var array<float> lk06_h = array.from(-0.03002620, 0.06732634, 0.02609783, -0.07953101, -0.03857458, -0.09752452, -0.07257111, 0.01361956, -0.00908956, 0.00164246, 0.09053521, -0.06152151, -0.06078335, -0.04566112, -0.05451217, -0.09100155, 0.00617729, -0.15793648, -0.09557898, -0.06404678)
var array<float> lk06_l = array.from(0.07936720, 0.02128390, 0.05350950, 0.00370999, 0.05157614, 0.06718171, 0.09019931, -0.00851453, -0.08262338, -0.05315006, 0.05071416, 0.07862973, 0.00806140, 0.10865853, -0.01126689, 0.02581116, 0.07940292, 0.09801709, 0.11399029, 0.27480474)
var array<float> lk06_c = array.from(0.05201516, -0.08614873, -0.05363427, 0.00213189, 0.05735620, 0.03965778, 0.01615371, -0.10522894, -0.01115781, -0.04275479, -0.09855822, 0.00941454, -0.04478159, 0.07771170, -0.11596787, 0.00508658, 0.04395240, -0.07175941, 0.05366125, -0.01338961)
var array<float> lk06_v = array.from(0.02309423, 0.05978729, -0.01666764, 0.05397203, 0.04581467, 0.04234674, 0.01294149, 0.11661515, -0.05381963, 0.03451879, 0.07862721, 0.00442956, -0.10221730, 0.09445108, 0.02313952, -0.12668496, -0.08334382, -0.06234331, 0.03816511, 0.02608971)
var array<float> lk07_o = array.from(0.02739554, -0.06017354, -0.03616903, -0.07954320, 0.01969581, -0.05279618, 0.00529903, -0.02105312, -0.07790267, -0.01408674, -0.07309155, -0.03344174, 0.03265910, -0.06757782, -0.09739314, 0.09068280, 0.05463371, -0.00499545, 0.00976282, 0.37818652)
var array<float> lk07_h = array.from(-0.05713899, -0.02527905, -0.02138710, 0.01450006, -0.00092768, -0.04939153, 0.08131962, -0.05573525, 0.11218128, -0.04906656, 0.03787255, 0.05076951, 0.03459799, 0.15631478, -0.04986271, 0.06690843, 0.04545095, 0.17597419, 0.14493211, 0.30271810)
var array<float> lk07_l = array.from(-0.02616013, -0.07941478, 0.07742074, -0.00274693, 0.04355217, -0.06300837, -0.06020197, -0.10782139, 0.04663454, 0.02547587, -0.06686340, -0.01687097, -0.08300891, -0.03687405, -0.02750742, -0.09388341, -0.07124659, -0.20202123, -0.03691099, -0.15703696)
var array<float> lk07_c = array.from(0.00576104, 0.09929013, 0.09261560, 0.02673763, 0.05176451, 0.11137234, 0.03777190, 0.04085040, -0.00982124, 0.10348675, 0.10674430, -0.03724865, 0.01055427, -0.03891759, 0.00008685, -0.04765017, 0.06571735, -0.00796061, 0.05273469, 0.03121063)
var array<float> lk07_v = array.from(-0.05845864, 0.09048516, 0.01668684, -0.08461650, 0.14619559, 0.08998074, 0.07220796, -0.01525501, 0.06888770, -0.09625789, 0.03278150, 0.04489749, 0.08553263, 0.03212339, -0.11495236, 0.10176332, 0.06709826, 0.01694651, 0.03296990, 0.06976965)
var array<float> lk08_o = array.from(0.08804787, 0.05307036, 0.02150048, -0.03582883, 0.06733420, 0.00822316, 0.06477218, -0.02764622, 0.06368567, 0.05872049, -0.03718167, 0.08136073, -0.06638404, -0.07469239, -0.06803633, 0.00181007, -0.07232516, -0.01932218, -0.04927947, 0.11319686)
var array<float> lk08_h = array.from(-0.13747904, -0.08185676, -0.06368960, -0.00943127, -0.08137870, -0.00568872, -0.08288707, -0.11403044, -0.06533667, -0.07448819, 0.02399209, -0.09557599, -0.07078741, -0.02264782, -0.12059629, -0.00985778, -0.16078764, -0.17488907, -0.12218735, -0.19038954)
var array<float> lk08_l = array.from(0.01536803, -0.04661882, 0.06223204, 0.02185541, 0.10112973, 0.08580116, 0.11308473, 0.06310730, 0.09466048, 0.08993267, 0.11144818, -0.03161322, 0.06413426, -0.02810663, 0.06293073, 0.03181012, 0.20996550, 0.17745918, 0.05882622, 0.05875916)
var array<float> lk08_c = array.from(-0.06583584, 0.01939751, -0.04939356, -0.02946768, 0.06931632, -0.07393954, -0.05773774, 0.06676387, 0.04564463, -0.05855176, 0.02740633, 0.05417871, -0.06184819, 0.01878269, 0.04066790, -0.04231717, 0.09278095, -0.04567323, 0.06587578, -0.05312165)
var array<float> lk08_v = array.from(-0.08983748, 0.02272975, -0.01820751, 0.02466317, 0.01073297, -0.08784786, -0.09635983, 0.04734159, 0.06080773, 0.03010810, 0.02291206, 0.01899312, -0.00852446, -0.03937299, 0.14445607, -0.01025889, -0.10981221, 0.09379946, -0.00214897, 0.01842536)
var array<float> lk09_o = array.from(-0.03695704, -0.00979935, 0.05405506, 0.03162121, 0.04332557, -0.07578610, -0.08361176, -0.00085269, -0.01097959, -0.05480100, 0.05304409, 0.01209997, -0.06278811, 0.06151966, 0.04109291, -0.00768786, 0.03740724, -0.08227245, 0.03629043, -0.01663449)
var array<float> lk09_h = array.from(0.10148267, 0.07889336, 0.03322478, 0.02803151, 0.06650411, 0.05130873, -0.01631098, 0.03381803, 0.00807352, -0.04362124, -0.05530132, -0.05101188, 0.00574937, 0.16462825, 0.07344456, 0.00861668, 0.06621848, 0.17196457, 0.03018856, 0.10725264)
var array<float> lk09_l = array.from(-0.09393384, -0.06884129, -0.02487933, -0.01832825, 0.05571149, 0.02917551, 0.04055877, -0.04195367, -0.08692781, -0.00104267, -0.09600085, 0.00287355, -0.08745053, -0.09243676, -0.12386580, -0.01484058, -0.06391849, -0.06440576, -0.09236722, -0.10764029)
var array<float> lk09_c = array.from(-0.01252304, -0.07564985, -0.07283665, 0.03184331, -0.06369126, 0.07788306, 0.03462621, 0.03513657, 0.05871411, 0.03738930, 0.05183239, 0.05251874, -0.06060819, -0.04440932, -0.00597727, 0.09421150, 0.07681415, 0.05653956, -0.04325666, -0.01268847)
var array<float> lk09_v = array.from(-0.05121857, 0.11122590, -0.07205810, -0.06168141, 0.13100965, 0.03259791, -0.02250897, -0.07447726, -0.03379867, 0.05696799, -0.04727178, 0.11792603, 0.13116740, -0.00409047, -0.04297988, 0.14126313, 0.16764098, 0.08831011, 0.00704553, -0.06711938)
var array<float> lk10_o = array.from(0.06792553, 0.05191684, -0.03160584, 0.04990838, -0.02874314, -0.04971478, -0.01559973, -0.01924859, -0.03161750, -0.04293944, 0.00887577, 0.09882674, -0.01257228, -0.04965292, -0.00816719, -0.03905663, -0.05890834, -0.02492306, 0.07940833, -0.06201160)
var array<float> lk10_h = array.from(0.02242813, -0.01546448, -0.02360693, -0.00010376, 0.03081385, 0.02029675, 0.08314310, 0.06208764, 0.10577224, 0.05454082, 0.04919655, 0.08526413, 0.01168012, 0.12842587, 0.09819888, 0.06153876, 0.12822036, 0.08186037, -0.01737781, 0.14130321)
var array<float> lk10_l = array.from(-0.04548040, -0.07112356, -0.00117798, -0.10192245, -0.06599642, 0.03813801, -0.13697740, -0.03047441, 0.02102138, 0.06720636, -0.00058095, -0.13745274, -0.06548598, -0.09501471, -0.08149473, 0.01974829, -0.13198908, -0.20486404, -0.12521867, -0.05033107)
var array<float> lk10_c = array.from(-0.01418385, 0.09151836, 0.02079742, -0.10857885, 0.02146174, 0.10455237, 0.06385574, 0.02821893, -0.09515601, -0.06846380, 0.06766388, -0.07041511, 0.00587991, -0.00199887, 0.03148442, 0.06583124, -0.04627538, -0.03309969, 0.09570848, 0.01177157)
var array<float> lk10_v = array.from(0.05903773, -0.01361355, 0.05965700, -0.04083117, 0.00567869, 0.02454348, -0.02351003, -0.04965899, 0.01375799, -0.03644969, -0.01631638, 0.04701519, -0.05521760, 0.03708210, 0.04875842, 0.05752110, 0.08598559, -0.11891692, -0.02890970, 0.07439642)
var array<float> lk11_o = array.from(0.08132566, -0.00022056, -0.04797373, 0.08586955, -0.00786187, -0.06082654, -0.05971066, 0.06195529, 0.05845775, 0.04623625, 0.00527390, 0.04117559, -0.04945045, -0.04197992, 0.09102888, -0.15243572, 0.03510860, 0.03837409, -0.06509084, -0.11822380)
var array<float> lk11_h = array.from(-0.09423121, -0.05800709, -0.13664114, -0.13627774, -0.05991464, -0.02101105, -0.04006220, -0.09828609, -0.06831226, -0.02648301, -0.10241600, -0.13098937, -0.16542001, -0.12250999, -0.01541432, -0.02876386, -0.14828244, -0.14409393, -0.01004292, -0.21903129)
var array<float> lk11_l = array.from(0.06995466, 0.15568328, 0.13216034, 0.08589185, -0.02919082, 0.11203813, -0.01904806, 0.12202009, 0.10125352, 0.04427942, -0.04623840, 0.03882177, 0.16003749, 0.16936205, 0.05817439, 0.16825491, 0.11084646, 0.11367792, 0.01310270, 0.12450232)
var array<float> lk11_c = array.from(0.01298959, 0.04838914, -0.07388574, -0.00357435, -0.08520799, 0.06529313, -0.00978710, -0.06938884, 0.03676718, -0.01312160, 0.02521677, -0.00253066, 0.08749367, -0.04173524, 0.01395946, -0.11318692, -0.01859879, 0.08158985, -0.00486889, 0.07694290)
var array<float> lk11_v = array.from(0.08654197, -0.08666719, 0.03847686, -0.01486288, 0.00134775, -0.03168062, 0.02733724, 0.03334956, -0.08185121, -0.00710072, -0.14286682, -0.05635683, -0.00719340, 0.03706600, 0.12577221, -0.12677269, -0.12288207, -0.03737766, 0.07432308, 0.03229798)
var array<float> lk12_o = array.from(-0.09468325, 0.08455885, -0.08717893, 0.05746167, -0.00932884, 0.02890811, 0.08113451, -0.03654668, -0.00364203, 0.03909370, -0.09055061, 0.03454615, -0.09497837, 0.09020419, -0.03416520, -0.03313423, 0.01079295, -0.08880658, 0.06740163, -0.28928190)
var array<float> lk12_h = array.from(0.04978820, -0.14123687, -0.07962833, -0.06686975, 0.01865577, -0.12714332, 0.01263871, -0.03459351, -0.07037193, -0.11591040, -0.01241620, -0.07228998, -0.01952617, -0.05841485, 0.03519948, -0.08182158, -0.15651362, -0.21776199, -0.16007386, -0.21038881)
var array<float> lk12_l = array.from(-0.01408101, 0.09980644, -0.01016422, 0.08335511, 0.11667766, -0.05933311, 0.08597825, 0.03864618, -0.01059145, 0.03171886, 0.05476492, 0.13232410, -0.02613878, 0.15672970, 0.18011452, 0.16388106, 0.16363181, 0.12032660, 0.12857747, 0.14808448)
var array<float> lk12_c = array.from(-0.02856304, -0.02309435, 0.07098689, 0.09945167, 0.09221183, 0.04308510, -0.07652205, -0.02723366, -0.00185192, 0.02556981, 0.01463039, -0.08104691, -0.01439931, -0.08166122, -0.00649239, 0.04267296, -0.07641801, 0.02542445, -0.04597231, -0.02024993)
var array<float> lk12_v = array.from(0.02104939, 0.02687581, 0.03510367, 0.05927926, 0.00531659, 0.03794287, -0.12394719, -0.04134817, -0.11593519, 0.04237890, -0.12813729, 0.01748151, 0.04353355, 0.05640230, -0.03621294, -0.08165994, -0.04802750, 0.10711114, 0.08803277, -0.09677833)
var array<float> lk13_o = array.from(0.01031005, 0.04348933, -0.06164066, 0.05777024, 0.09585120, -0.05368519, -0.05122861, -0.00746589, 0.04982629, -0.00091987, 0.05892013, -0.10017670, -0.05144619, -0.03051838, 0.05082275, 0.07874665, -0.07586323, 0.04693757, -0.08069240, -0.26544154)
var array<float> lk13_h = array.from(-0.03089550, -0.00464697, -0.07137510, -0.06439937, -0.03796028, 0.05827131, -0.03656287, 0.06920544, -0.00504312, -0.02160930, 0.02639506, 0.10338531, 0.00321632, 0.09579901, 0.10188346, 0.15419827, 0.14039786, 0.14215367, 0.01562908, 0.01205606)
var array<float> lk13_l = array.from(0.02697437, 0.05520794, -0.00666234, 0.07035065, -0.02513699, 0.04348945, -0.03550642, -0.06711292, -0.03713993, -0.06684255, 0.00348004, -0.06456891, -0.06843925, -0.03234549, -0.03043928, -0.03172967, -0.10213453, -0.08879042, 0.02220432, -0.28017983)
var array<float> lk13_c = array.from(0.05865213, -0.00307023, -0.05458294, -0.02726007, 0.05290502, 0.02678994, 0.00064175, -0.03539678, 0.08073956, -0.00370482, -0.07337043, -0.00634577, -0.03495291, -0.02395101, 0.02571409, -0.05798865, 0.10343466, -0.10913455, 0.07853936, -0.07861038)
var array<float> lk13_v = array.from(0.03312334, 0.01378239, -0.01702039, -0.02080168, 0.10977684, -0.06674575, -0.04370740, 0.03573547, 0.02521248, 0.02715388, 0.04787572, 0.01940013, 0.01292622, 0.02645193, -0.08459082, 0.03264740, 0.09722657, 0.02802931, 0.01512847, -0.01055734)
var array<float> lk14_o = array.from(0.05734735, 0.02171019, -0.06511849, 0.05924290, 0.00859314, -0.03123553, 0.06250941, -0.05463892, 0.02883624, -0.07339683, 0.01017712, 0.02448879, -0.09188364, 0.06590040, 0.01721507, -0.00800235, 0.06111825, 0.03093447, 0.04734028, -0.27521145)
var array<float> lk14_h = array.from(-0.03453800, -0.03852168, 0.05760506, 0.03102238, -0.02982628, 0.09799516, 0.05316407, -0.03463880, 0.07664297, -0.04518473, 0.03240301, 0.09124853, -0.07191987, -0.02323649, 0.04487988, 0.08942350, -0.01089706, 0.02815500, 0.04825170, 0.04349683)
var array<float> lk14_l = array.from(0.00643890, 0.00502266, 0.01208222, 0.00538112, 0.02215117, -0.02947144, 0.00225530, 0.04826053, -0.06364542, -0.06449646, 0.01051024, -0.09554337, 0.01922133, 0.01238521, 0.01313894, -0.07518753, -0.06190897, -0.16500910, -0.13570121, -0.04580757)
var array<float> lk14_c = array.from(-0.08860243, -0.08567096, -0.03964249, 0.00885229, 0.03471240, -0.05448616, -0.01967163, -0.02718589, 0.08874653, 0.06211781, 0.04044566, -0.00618196, 0.05633043, -0.07736327, 0.08478443, -0.03858669, 0.08861180, -0.08793712, 0.03631248, -0.08221835)
var array<float> lk14_v = array.from(0.09401052, 0.05113656, 0.09900670, -0.10260189, 0.10302852, -0.06095514, -0.04464036, 0.03745628, 0.01017069, -0.07130606, -0.07507600, 0.00613918, 0.07436562, 0.08190610, 0.05551476, 0.06151981, 0.02739537, -0.03691834, 0.01575017, -0.07181268)
var array<float> lk15_o = array.from(0.01058911, -0.06321153, -0.04326237, 0.02212371, 0.02444452, 0.02933509, -0.00622234, 0.02318850, 0.00981034, 0.03740045, -0.00144305, 0.07270918, 0.09182422, -0.05633686, -0.07649815, 0.04266905, -0.03611768, 0.02857773, 0.10361720, -0.18052341)
var array<float> lk15_h = array.from(-0.02868816, 0.02361817, 0.11915846, 0.05803747, -0.01851626, 0.04128066, -0.08446767, -0.01152847, 0.13027442, -0.03363737, 0.09280039, -0.05500867, 0.14450951, 0.10672953, 0.12726074, 0.13326660, 0.12416652, 0.10568758, 0.00492560, 0.06170851)
var array<float> lk15_l = array.from(0.05171522, -0.05078427, -0.00948042, -0.08225700, 0.05550092, -0.04576234, -0.10279615, 0.00057481, -0.10506359, 0.00269437, -0.10276458, 0.03793566, -0.15190923, -0.03796464, 0.03832940, -0.13720073, -0.05603828, -0.08596232, -0.11248858, -0.17215066)
var array<float> lk15_c = array.from(0.03189699, 0.08438994, 0.08169625, -0.07448072, -0.05991903, -0.06689057, -0.02837429, -0.00038731, -0.01810167, 0.05392843, -0.04718686, -0.07197782, -0.09596438, -0.04562231, 0.14200850, 0.04967078, -0.00859684, -0.04460130, -0.08502242, -0.03392812)
var array<float> lk15_v = array.from(0.08065053, 0.11787432, 0.06480480, -0.03842763, -0.00127088, -0.05614079, 0.10309518, -0.10788992, 0.05771280, -0.03405016, 0.11268694, 0.09238460, 0.03060317, -0.10415744, -0.04715755, 0.00689462, 0.13931870, 0.02920659, -0.03537172, -0.02976480)

var array<float> lk_bias = array.from(0.13137004, 0.07017759, -0.34632468, -0.13435584, 0.06976873, -0.10641164, -0.26743084, 0.08072557, -0.08857477, 0.21102098, 0.20833634, -0.07176771, -0.27417094, 0.11210675, 0.03064808, 0.25320774)

// head_bull weights (48-d) + bias.
var array<float> head_w = array.from(-0.02994112, 0.01524032, 0.09031452, -0.02879018, -0.03963157, -0.06986067, -0.16250625, -0.00552051, -0.13978896, 0.01525445, 0.18540926, 0.08617868, -0.11784950, -0.45078731, 0.01716246, -0.04478671, 0.00065216, -0.04043920, 0.01746387, -0.19162367, 0.10682888, 0.00993747, 0.01865564, 0.03749872, 0.01854989, -0.06251132, 0.14564317, 0.11241882, 0.10192160, -0.25332263, 0.18291368, 0.03984211, -0.01019019, 0.00852008, 0.05254713, 0.04778406, -0.01548312, -0.02649405, 0.00648978, -0.01354260, 0.05111337, -0.03723928, -0.03436997, 0.07160386, 0.08356724, -0.00607910, 0.00103703, -0.02510500)
float head_b = -0.13892826

// ---------------------------------------------------------------------------
// Shared window buffers (filled once per bar, read by every filter UDF)
// ---------------------------------------------------------------------------
var array<float> sw_o = array.new<float>(12, 0.0)
var array<float> sw_h = array.new<float>(12, 0.0)
var array<float> sw_l = array.new<float>(12, 0.0)
var array<float> sw_c = array.new<float>(12, 0.0)
var array<float> sw_v = array.new<float>(12, 0.0)
var array<float> lw_o = array.new<float>(20, 0.0)
var array<float> lw_h = array.new<float>(20, 0.0)
var array<float> lw_l = array.new<float>(20, 0.0)
var array<float> lw_c = array.new<float>(20, 0.0)
var array<float> lw_v = array.new<float>(20, 0.0)

// ---------------------------------------------------------------------------
// Per-filter dot products as UDFs: bodies live outside the main body,
// which is what keeps the script under Pine's main-body size limit.
// ---------------------------------------------------------------------------
short_filter(simple array<float> kw_o, simple array<float> kw_h, simple array<float> kw_l, simple array<float> kw_c, simple array<float> kw_v, float bias) =>
    float s = bias
    for p = 0 to 11
        s += array.get(kw_o, p) * array.get(sw_o, p)
        s += array.get(kw_h, p) * array.get(sw_h, p)
        s += array.get(kw_l, p) * array.get(sw_l, p)
        s += array.get(kw_c, p) * array.get(sw_c, p)
        s += array.get(kw_v, p) * array.get(sw_v, p)
    s

long_filter(simple array<float> kw_o, simple array<float> kw_h, simple array<float> kw_l, simple array<float> kw_c, simple array<float> kw_v, float bias) =>
    float s = bias
    for p = 0 to 19
        s += array.get(kw_o, p) * array.get(lw_o, p)
        s += array.get(kw_h, p) * array.get(lw_h, p)
        s += array.get(kw_l, p) * array.get(lw_l, p)
        s += array.get(kw_c, p) * array.get(lw_c, p)
        s += array.get(kw_v, p) * array.get(lw_v, p)
    s

// ===========================================================================
// PHASE 2: Forward pass: near conv + far conv -> concat -> linear head
// ===========================================================================

float p_bull = na
float bull_logit = na

if in_budget and bar_index >= 205 and not na(atr14) and atr14 > 0 and not na(vol_sma20) and vol_sma20 > 0
    // Volume channel uses the ENTRY-BAR vol_sma20 as a single divisor
    // across the whole window (matches the training bundle builder).
    // Prefill the near window (trailing 12 bars, p=0 is oldest, p=11 is current).
    for p = 0 to 11
        int lb = 11 - p
        array.set(sw_o, p, (open[lb]  - close) / atr14)
        array.set(sw_h, p, (high[lb]  - close) / atr14)
        array.set(sw_l, p, (low[lb]   - close) / atr14)
        array.set(sw_c, p, (close[lb] - close) / atr14)
        array.set(sw_v, p, volume[lb] / vol_sma20 - 1.0)
    // Prefill the far window (20 strided samples at lookbacks 190, 180, ..., 10, 0).
    for p = 0 to 19
        int lb = (19 - p) * 10
        array.set(lw_o, p, (open[lb]  - close) / atr14)
        array.set(lw_h, p, (high[lb]  - close) / atr14)
        array.set(lw_l, p, (low[lb]   - close) / atr14)
        array.set(lw_c, p, (close[lb] - close) / atr14)
        array.set(lw_v, p, volume[lb] / vol_sma20 - 1.0)

    // Near bank: 32 filters, dot product over the trailing 12 bars.
    float s00 = short_filter(sk00_o, sk00_h, sk00_l, sk00_c, sk00_v, array.get(sk_bias, 0))
    float s01 = short_filter(sk01_o, sk01_h, sk01_l, sk01_c, sk01_v, array.get(sk_bias, 1))
    float s02 = short_filter(sk02_o, sk02_h, sk02_l, sk02_c, sk02_v, array.get(sk_bias, 2))
    float s03 = short_filter(sk03_o, sk03_h, sk03_l, sk03_c, sk03_v, array.get(sk_bias, 3))
    float s04 = short_filter(sk04_o, sk04_h, sk04_l, sk04_c, sk04_v, array.get(sk_bias, 4))
    float s05 = short_filter(sk05_o, sk05_h, sk05_l, sk05_c, sk05_v, array.get(sk_bias, 5))
    float s06 = short_filter(sk06_o, sk06_h, sk06_l, sk06_c, sk06_v, array.get(sk_bias, 6))
    float s07 = short_filter(sk07_o, sk07_h, sk07_l, sk07_c, sk07_v, array.get(sk_bias, 7))
    float s08 = short_filter(sk08_o, sk08_h, sk08_l, sk08_c, sk08_v, array.get(sk_bias, 8))
    float s09 = short_filter(sk09_o, sk09_h, sk09_l, sk09_c, sk09_v, array.get(sk_bias, 9))
    float s10 = short_filter(sk10_o, sk10_h, sk10_l, sk10_c, sk10_v, array.get(sk_bias, 10))
    float s11 = short_filter(sk11_o, sk11_h, sk11_l, sk11_c, sk11_v, array.get(sk_bias, 11))
    float s12 = short_filter(sk12_o, sk12_h, sk12_l, sk12_c, sk12_v, array.get(sk_bias, 12))
    float s13 = short_filter(sk13_o, sk13_h, sk13_l, sk13_c, sk13_v, array.get(sk_bias, 13))
    float s14 = short_filter(sk14_o, sk14_h, sk14_l, sk14_c, sk14_v, array.get(sk_bias, 14))
    float s15 = short_filter(sk15_o, sk15_h, sk15_l, sk15_c, sk15_v, array.get(sk_bias, 15))
    float s16 = short_filter(sk16_o, sk16_h, sk16_l, sk16_c, sk16_v, array.get(sk_bias, 16))
    float s17 = short_filter(sk17_o, sk17_h, sk17_l, sk17_c, sk17_v, array.get(sk_bias, 17))
    float s18 = short_filter(sk18_o, sk18_h, sk18_l, sk18_c, sk18_v, array.get(sk_bias, 18))
    float s19 = short_filter(sk19_o, sk19_h, sk19_l, sk19_c, sk19_v, array.get(sk_bias, 19))
    float s20 = short_filter(sk20_o, sk20_h, sk20_l, sk20_c, sk20_v, array.get(sk_bias, 20))
    float s21 = short_filter(sk21_o, sk21_h, sk21_l, sk21_c, sk21_v, array.get(sk_bias, 21))
    float s22 = short_filter(sk22_o, sk22_h, sk22_l, sk22_c, sk22_v, array.get(sk_bias, 22))
    float s23 = short_filter(sk23_o, sk23_h, sk23_l, sk23_c, sk23_v, array.get(sk_bias, 23))
    float s24 = short_filter(sk24_o, sk24_h, sk24_l, sk24_c, sk24_v, array.get(sk_bias, 24))
    float s25 = short_filter(sk25_o, sk25_h, sk25_l, sk25_c, sk25_v, array.get(sk_bias, 25))
    float s26 = short_filter(sk26_o, sk26_h, sk26_l, sk26_c, sk26_v, array.get(sk_bias, 26))
    float s27 = short_filter(sk27_o, sk27_h, sk27_l, sk27_c, sk27_v, array.get(sk_bias, 27))
    float s28 = short_filter(sk28_o, sk28_h, sk28_l, sk28_c, sk28_v, array.get(sk_bias, 28))
    float s29 = short_filter(sk29_o, sk29_h, sk29_l, sk29_c, sk29_v, array.get(sk_bias, 29))
    float s30 = short_filter(sk30_o, sk30_h, sk30_l, sk30_c, sk30_v, array.get(sk_bias, 30))
    float s31 = short_filter(sk31_o, sk31_h, sk31_l, sk31_c, sk31_v, array.get(sk_bias, 31))

    // Far bank: 16 filters, dot product over 20 strided samples.
    float l00 = long_filter(lk00_o, lk00_h, lk00_l, lk00_c, lk00_v, array.get(lk_bias, 0))
    float l01 = long_filter(lk01_o, lk01_h, lk01_l, lk01_c, lk01_v, array.get(lk_bias, 1))
    float l02 = long_filter(lk02_o, lk02_h, lk02_l, lk02_c, lk02_v, array.get(lk_bias, 2))
    float l03 = long_filter(lk03_o, lk03_h, lk03_l, lk03_c, lk03_v, array.get(lk_bias, 3))
    float l04 = long_filter(lk04_o, lk04_h, lk04_l, lk04_c, lk04_v, array.get(lk_bias, 4))
    float l05 = long_filter(lk05_o, lk05_h, lk05_l, lk05_c, lk05_v, array.get(lk_bias, 5))
    float l06 = long_filter(lk06_o, lk06_h, lk06_l, lk06_c, lk06_v, array.get(lk_bias, 6))
    float l07 = long_filter(lk07_o, lk07_h, lk07_l, lk07_c, lk07_v, array.get(lk_bias, 7))
    float l08 = long_filter(lk08_o, lk08_h, lk08_l, lk08_c, lk08_v, array.get(lk_bias, 8))
    float l09 = long_filter(lk09_o, lk09_h, lk09_l, lk09_c, lk09_v, array.get(lk_bias, 9))
    float l10 = long_filter(lk10_o, lk10_h, lk10_l, lk10_c, lk10_v, array.get(lk_bias, 10))
    float l11 = long_filter(lk11_o, lk11_h, lk11_l, lk11_c, lk11_v, array.get(lk_bias, 11))
    float l12 = long_filter(lk12_o, lk12_h, lk12_l, lk12_c, lk12_v, array.get(lk_bias, 12))
    float l13 = long_filter(lk13_o, lk13_h, lk13_l, lk13_c, lk13_v, array.get(lk_bias, 13))
    float l14 = long_filter(lk14_o, lk14_h, lk14_l, lk14_c, lk14_v, array.get(lk_bias, 14))
    float l15 = long_filter(lk15_o, lk15_h, lk15_l, lk15_c, lk15_v, array.get(lk_bias, 15))

    // Linear head over the 48-d feature vector + sigmoid.
    bull_logit := head_b
    bull_logit := bull_logit + array.get(head_w, 0) * s00
    bull_logit := bull_logit + array.get(head_w, 1) * s01
    bull_logit := bull_logit + array.get(head_w, 2) * s02
    bull_logit := bull_logit + array.get(head_w, 3) * s03
    bull_logit := bull_logit + array.get(head_w, 4) * s04
    bull_logit := bull_logit + array.get(head_w, 5) * s05
    bull_logit := bull_logit + array.get(head_w, 6) * s06
    bull_logit := bull_logit + array.get(head_w, 7) * s07
    bull_logit := bull_logit + array.get(head_w, 8) * s08
    bull_logit := bull_logit + array.get(head_w, 9) * s09
    bull_logit := bull_logit + array.get(head_w, 10) * s10
    bull_logit := bull_logit + array.get(head_w, 11) * s11
    bull_logit := bull_logit + array.get(head_w, 12) * s12
    bull_logit := bull_logit + array.get(head_w, 13) * s13
    bull_logit := bull_logit + array.get(head_w, 14) * s14
    bull_logit := bull_logit + array.get(head_w, 15) * s15
    bull_logit := bull_logit + array.get(head_w, 16) * s16
    bull_logit := bull_logit + array.get(head_w, 17) * s17
    bull_logit := bull_logit + array.get(head_w, 18) * s18
    bull_logit := bull_logit + array.get(head_w, 19) * s19
    bull_logit := bull_logit + array.get(head_w, 20) * s20
    bull_logit := bull_logit + array.get(head_w, 21) * s21
    bull_logit := bull_logit + array.get(head_w, 22) * s22
    bull_logit := bull_logit + array.get(head_w, 23) * s23
    bull_logit := bull_logit + array.get(head_w, 24) * s24
    bull_logit := bull_logit + array.get(head_w, 25) * s25
    bull_logit := bull_logit + array.get(head_w, 26) * s26
    bull_logit := bull_logit + array.get(head_w, 27) * s27
    bull_logit := bull_logit + array.get(head_w, 28) * s28
    bull_logit := bull_logit + array.get(head_w, 29) * s29
    bull_logit := bull_logit + array.get(head_w, 30) * s30
    bull_logit := bull_logit + array.get(head_w, 31) * s31
    bull_logit := bull_logit + array.get(head_w, 32) * l00
    bull_logit := bull_logit + array.get(head_w, 33) * l01
    bull_logit := bull_logit + array.get(head_w, 34) * l02
    bull_logit := bull_logit + array.get(head_w, 35) * l03
    bull_logit := bull_logit + array.get(head_w, 36) * l04
    bull_logit := bull_logit + array.get(head_w, 37) * l05
    bull_logit := bull_logit + array.get(head_w, 38) * l06
    bull_logit := bull_logit + array.get(head_w, 39) * l07
    bull_logit := bull_logit + array.get(head_w, 40) * l08
    bull_logit := bull_logit + array.get(head_w, 41) * l09
    bull_logit := bull_logit + array.get(head_w, 42) * l10
    bull_logit := bull_logit + array.get(head_w, 43) * l11
    bull_logit := bull_logit + array.get(head_w, 44) * l12
    bull_logit := bull_logit + array.get(head_w, 45) * l13
    bull_logit := bull_logit + array.get(head_w, 46) * l14
    bull_logit := bull_logit + array.get(head_w, 47) * l15
    p_bull := 1.0 / (1.0 + math.exp(-bull_logit))

// ---------------------------------------------------------------------------
// Self-calibrated threshold: rolling p{calib_pct} of p_bull over the last
// `i_calib_len` bars. Replaces the manual `i_threshold` when
// `i_use_calib` is on. Adapts to drift in the probability distribution
// across timeframes and regimes; the indicator picks its own threshold
// so the top (100−pct)% of recent bars produce a signal.
//
// Critically, the calibrated threshold is only valid once the rolling
// window has seen at least `i_calib_len` finite scores. Pine's
// `ta.percentile_*` returns the percentile of *whatever is in the window*,
// not `na`, while the window is filling, so naively using its output
// before warmup completes produces a meaningless threshold (rises from
// ~0 as the first p_bull values trickle in) and bursts of false signals.
// We count finite p_bull bars in a `var int` accumulator and gate the
// effective threshold (and therefore the signal condition, the histogram
// zone-colour, and the threshold line) on that counter reaching
// `i_calib_len`.
// ---------------------------------------------------------------------------
var int p_bull_n_finite = 0
if not na(p_bull)
    p_bull_n_finite += 1
bool calib_ready = p_bull_n_finite >= i_calib_len
// Call the percentile every bar so its internal rolling buffer accumulates
// consistently; gate the *output* (not the call) on calib_ready.
float p_bull_calib_raw = ta.percentile_linear_interpolation(p_bull, i_calib_len, i_calib_pct)
float p_bull_calib_thr = calib_ready ? p_bull_calib_raw : float(na)
float effective_thr = i_use_calib
     ? p_bull_calib_thr
     : i_threshold
float fire = (not na(p_bull) and not na(effective_thr) and p_bull > effective_thr) ? 1.0 : 0.0

// ===========================================================================
// PHASE 3: Display + alerts
// ===========================================================================
// Sub-pane layout: zone-coloured histogram + EMA overlay + threshold
// line + 0/0.5/1 hlines anchor the [0, 1] autoscale. Signal bars get a
// below-bar marker on the price chart.

// EMA of the probability for smoothing single-bar spikes.
float p_bull_ema = ta.ema(p_bull, i_ema_len)

// Theme adaptivity. Branch on the chart's background luminance so
// the palette reads on both dark and light TradingView themes.
bool is_dark = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) < 384
color c_theme_grey = is_dark ? color.new(color.gray, 30) : color.new(color.gray, 40)
color c_theme_grey_faint = is_dark ? color.new(color.gray, 60) : color.new(color.gray, 70)

// Zone colouring for the histogram. Three bands:
//   < 0.3                  : noise (theme-adaptive grey)
//   0.3 .. effective_thr   : warming (faint violet)
//   >= effective_thr       : signal (bright violet)
color c_violet_bright = color.new(#7c3aed, 10)
color c_violet_faint  = color.new(#a78bfa, 60)
color c_violet_ema    = color.new(#5b21b6, 0)
color c_violet_marker = color.new(#7c3aed, 0)
color hist_col  = p_bull >= effective_thr ? c_violet_bright :
     p_bull >= 0.30             ? c_violet_faint :
                                       c_theme_grey_faint

bool display_ready = not na(effective_thr)
plot(i_show_score_hist and display_ready ? p_bull : na, title='p_long',
     color=hist_col, style=plot.style_columns, linewidth=1)
plot(i_show_score_ema  and display_ready ? p_bull_ema : na, title='p_long_ema',
     color=c_violet_ema, linewidth=2)
plot(i_show_thr_line  ? effective_thr : na, title='effective_threshold',
     color=c_theme_grey, style=plot.style_circles, linewidth=1)
hline(0.0, color=c_theme_grey_faint, linestyle=hline.style_dotted)
hline(0.5, color=c_theme_grey_faint, linestyle=hline.style_dotted)
hline(1.0, color=c_theme_grey_faint, linestyle=hline.style_dotted)

// Price-chart marker via force_overlay=true. The y-coordinate is the
// bar's low (long) / high (short) so the marker sits just outside the
// bar; location.belowbar / location.abovebar then nudge it one tick
// further off the bar.
plotshape(i_show_fire and fire == 1.0 ? low : na, title='signal_marker',
     location=location.belowbar,
     style=shape.triangleup, size=size.tiny, color=c_violet_marker, force_overlay=true)

// No-volume detection. Some TV symbols (e.g. CRYPTO:* synthetic
// aggregates) ship without a volume series; vol_sma20 stays na and
// the score gate above produces no output on any bar. Surface the
// reason at the right edge instead of leaving the pane mysteriously
// empty.
var label nv_lbl = na
if barstate.islast and na(p_bull) and bar_index > 250
    label.delete(nv_lbl)
    nv_lbl := label.new(bar_index, 0.5,
         text='No score produced.\nThis symbol may have no volume data\n(common on CRYPTO:* synthetic feeds).\nTry an exchange-specific symbol\n(e.g. BINANCE:ETHUSDT, COINBASE:ETHUSD).',
         style=label.style_label_left, color=color.new(color.gray, 30),
         textcolor=c_theme_grey, size=size.normal)

// Bar-close alerts. In the TV alert dialog choose 'Once Per Bar Close'
// to avoid triggering on provisional intrabar signals.
alertcondition(fire == 1.0, title='Long Excursion Breakout signal',
     message='p_long crossed effective threshold on bar close')
````
