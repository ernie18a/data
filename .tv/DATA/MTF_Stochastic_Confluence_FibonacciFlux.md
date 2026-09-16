<!-- tradingview-pine-id: PUB;4cfa54c0fbf74e27a938fd314c89fdee -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MTF Stochastic Confluence [FibonacciFlux]

Source: https://www.tradingview.com/script/dYxSAc89-MTF-Stochastic-Confluence-FibonacciFlux/

## Description

Three Stochastic timeframes scored into one confluence number, published with the measurement that says the trigger it was built around fires two to six times in two months - and that this is arithmetic, not a rare market state.

WHAT IT COMPUTES

Stochastic %K is computed on 15m, 1H and 4H bars, each inside its own timeframe, and pulled onto the chart. Their weighted mean becomes the white composite line; the weighted spread around it becomes a coherence term. Two scores are then built, one for each direction:

score = 100 x position x (0.30 + 0.25 coherence + 0.30 turn + 0.15 cross)

where position is how deep the three legs sit inside the extreme (1.0 at or beyond the oversold line, falling linearly to 0 across the soft band above it), turn is how fast they are coming back out, and cross is how many have %K above %D. A trigger needs three things at once: all three legs to have visited the same extreme within the last sixteen bars, at least two to be turning, and the score to clear its threshold.

THE TRIGGER ALMOST NEVER FIRES, AND NOT BECAUSE THE MARKET IS QUIET

Over 5,982 scored bars of 15m data from 2026-06-25 to 2026-08-26, at the default threshold of 70, this fires 2 bull and 4 bear signals on BINANCE:BTCUSDT, 0 bull and 2 bear on ETHUSDT, 1 bull and 2 bear on SOLUSDT. Six signals in two months on the busiest of the three, and ETHUSDT produces no bullish signal at all.

The reason is in the formula. The bracket is bounded above by 1.0, so a score of 70 needs position at or above 0.70 even if coherence, turn and cross are all perfect. In practice the bracket never gets near 1 on the bars where it would matter: its median is 0.63 across all bars, but on bars deep enough in the extreme to matter (position at or above 0.85) the median falls to 0.58 and the maximum falls from 0.98 to between 0.72 and 0.77.

That is not bad luck, it is the design. Position and the bracket are negatively correlated - -0.35 on BTCUSDT, -0.38 on ETHUSDT, -0.37 on SOLUSDT - because they ask for opposite things. Position is high only while price is still deep inside the extreme; turn and cross are high only once a leg has started climbing back out, which raises %K and destroys position. The source comment calls the position term "a hard gate through multiplication" so that alignment in the middle of the range cannot generate a reversal score. It does that. It also multiplies away the bars it was built to select.

The scale of the loss: if the bracket were 1, BTCUSDT would have 1,060 bars at or above 70. With the real bracket it has 8, and after the arming and turning gates and the one-shot latch, six signals.

The clearest way to see it is the slider itself. The highest score this formula produced anywhere in the sample - three instruments, both data modes, roughly 36,000 bars - is 74.46. The threshold input runs from 40 to 95 in steps of 1, so 21 of its 56 positions cannot ever fire, whatever the market does. The top 38% of the control is dead travel.

Lowering the threshold to 50 gives 10 bull and 21 bear signals on BTCUSDT over the same window, 5 and 17 on ETHUSDT, 8 and 21 on SOLUSDT. Nothing in this publication validates that setting - it is stated so the shape of the knob is visible, not recommended.

ONE ADVERTISED FILTER IS INERT AT THE DEFAULTS

"Require at least two timeframes turning" removes exactly zero signals at the default threshold, on all three instruments: 6/6 on BTCUSDT counting both directions, 2/2 on ETHUSDT, 3/3 on SOLUSDT. It only starts to bite lower down - at a threshold of 60 it removes 2, 4 and 9 respectively. At the shipped defaults the score gate has already removed everything the turn gate would have.

THE DEFAULT USED TO BE THE REPAINTING MODE

The previous version shipped with the HTF data mode set to "Developing HTF", which reads the 1H and 4H bars while they are still forming. What that costs, measured by replaying every 15m bar as if it were the live bar and comparing against what the same bar shows once its higher-timeframe bar has closed, on BTCUSDT over 5,983 bars:

The 1H %K settles a median of 1.13 points away from what was displayed, p90 5.35, maximum 21.18. The 4H %K a median of 1.41, p90 5.79, maximum 27.37. More to the point for this script, the sign of the per-timeframe turn - one of the three gates the trigger depends on - flips after the fact on 10.2% of bars for the 1H leg and 12.7% for the 4H, and the %K/%D cross flips on 7.7% and 8.1%. ETHUSDT and SOLUSDT give the same figures within a tenth of a point.

The default is now "Confirmed only". The developing mode is still there, and its tooltip now says the word repaints.

One surprise came out of checking this, and it is worth stating because the setting's name misleads. On historical bars, switching between the two modes does not change the 1H or 4H legs at all - they are bit-identical across every one of 6,000 bars on all three instruments, because request.security resolves both to the last closed higher-timeframe bar. What the setting actually changes is the 15m leg, which is the chart's own timeframe: Confirmed reads the previous chart bar and Developing the current one, and they differ on essentially every bar, by up to 33 points. So the input labelled "HTF data mode" is, in history, a 15m setting. The repaint measured above is a separate thing: it is what the chart showed live, not what this toggle does to the past.

WHAT WAS TESTED INSTEAD, AND WHAT IT SAYS

Six events cannot be tested. What can be tested are the states this script draws often enough to have a sample: both strict three-timeframe extremes, both armed windows, both score bands, the composite extremes and high coherence. Testing all eleven at horizons of 4, 16 and 96 bars, in both signed and absolute return, counted as episodes rather than overlapping bars, against 500 shared circular shifts of the forward-return series:

BTCUSDT gives a largest standardised effect of 3.56 across 66 tests, against a family whose own median maximum on a shifted copy is 2.37; family-wise p = 0.120. SOLUSDT gives 3.00 against 2.33, p = 0.202. ETHUSDT gives 6.14 against 2.11, p = 0.008 - the only cell in the batch that clears its own family-wise correction.

That ETHUSDT result is worth naming precisely, because it is about the size of moves and not their direction. Bars entering a bear-score-above-50 episode are followed by larger absolute four-bar returns: 0.712% against a 0.328% baseline, 2.17 times, over 60 episodes, p = 0.0005 at 2,000 shifts, and 0.607% after dropping the single largest event. The direction of that effect replicates on the other two instruments but the significance does not: BTCUSDT gives 1.278 times at p = 0.060 over 70 episodes and SOLUSDT 1.354 times at p = 0.053 over 84. The mirror state - bull score above 50 - shows nothing anywhere: 0.72, 1.07 and 1.07 times.

So the honest reading is: a high bear score marks bars that are about to move more, on one instrument convincingly and on two others suggestively, and it says nothing about which way. Directionally it points, if anything, the wrong way: the mean signed one-hour return after a bear-score-above-50 episode is +0.038%, +0.109% and +0.153% on the three instruments, all positive, against baselines of +0.017%, +0.028% and +0.024%.

WHAT THAT WINDOW COULD HAVE DETECTED

62 days of 15m bars hold 1,494 non-overlapping one-hour windows, 372 four-hour windows and 61 daily ones. For a state occupying a quarter of them, the smallest mean difference detectable at 80% power is 0.065% at one hour, 0.255% at four hours and 1.603% at one day. The one-hour and four-hour tests above are therefore real tests. The daily horizon is not: nothing short of an enormous daily edge could show up in 61 windows, so a null result there means very little.

WHAT CHANGED IN THIS VERSION

An entire "Forward outcome audit" section was dead code. A settings toggle promised a "statistics table" that did not exist anywhere in the file - no table, no cell, no label - and the hit rates and Wilson lower bounds it computed were never rendered by anything. The arrays, the win counters and both helper functions fed only those six unreachable numbers. The promise was deleted rather than the table built, which took the file from 242 lines to 197 with no change to a single plotted value.

The two score areas were declared last, so they were painted over the lines they were meant to annotate: at least one plotted line sat underneath one of them on 38.7% of bars, a median of 13.4 points deep, with the 4H %K line covered on 16.8% and the white composite on 11.2%. They are now declared first and much fainter, because they are context rather than the subject. The 4H line was linewidth 4, which made the slowest and most stepped series the loudest thing in the pane; the composite now leads instead. The armed shading reused the same lime and red as the score areas, so three different things were saying red - it is one neutral wash now, and its title says what it means. The tiny "3" glyphs on the extreme markers and the "MTF+"/"MTF-" labels on the triggers are gone.

The bear score area was drawn the wrong way up. Both areas were anchored at 0 and grew upward, but a bear reading means %K is high - so the red area lived at the bottom of the pane, under the oversold line, covering it on 45.4% of bars of BTCUSDT (38.8% on ETHUSDT, 41.8% on SOLUSDT), and could never reach the overbought line it is about: its maximum over 5,982 bars is 71.75. Each score is now drawn at the end of the pane its own condition lives at - the bull score up from 0, the bear score down from 100.

The title's en-dashes and one Unicode minus sign became ASCII, 770 box-drawing characters in the comment separators became hyphens, an MPL header was added, and the two threshold inputs and the data-mode input now carry the measurements above in their tooltips. The alert messages no longer say a filter was "passed" and say in their own text how rarely they fire.

WHAT ACTUALLY MOVES THE OUTPUT

Not the threshold everyone will reach for first. Measured on BTCUSDT against the defaults over 5,700 bars after warm-up, the %K smoothing is the single most consequential setting for whether this script does anything at all: at 1 it produces 20 signals, at the default 3 it produces 6, at 6 it produces zero. The slope-for-full-turn input is next - at 2 it gives 12 signals, at 20 it gives zero - and it moves the composite by exactly nothing, because it only touches the gates.

For the composite line itself, the timeframe weights dominate: a 4H-heavy setting moves it by a median of 8.07 points, equal weights by 3.47, against 4.42 for a %K length of 9 and 3.82 for 21. The soft band, the cluster window and the %D smoothing move the composite by exactly zero - they only change which bars are eligible.

WHAT THE MEASUREMENTS COVER

All of it is 15m data from 2026-06-25 to 2026-08-26, 62 days, on three instruments, in a window where BTCUSDT rose 26.5%, ETHUSDT 48.4% and SOLUSDT 38.7%. That matters here: in a rising window the three legs sit above 50 more often than below - 51.6% to 61.3% of bars on BTCUSDT - which is why the bear side of the pane is busier than the bull side and why bearish arming is roughly twice as common as bullish. Nothing was tested outside that window, in a falling market, or on a non-crypto instrument. Everything is measured on the Confirmed data mode; the Developing mode is measured only for its repaint, above.

HOW THE NUMBERS WERE CHECKED

The whole computation was reimplemented outside Pine and cross-checked against this chart's Data Window: thirty quantities on ten bars - all three %K and %D legs and their bar-to-bar changes, the composite, dispersion, coherence, both position terms, both scores, both armed flags, both strict-extreme flags and both triggers - with two of the ten bars carrying events, including one that fires the bearish trigger, so the event and latch paths were exercised rather than assumed. All 300 values round to the exact two decimals TradingView prints, with a worst raw difference of 5.0e-3, the display's own rounding floor.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("MTF Stochastic Confluence [FibonacciFlux]", "MTF Stoch Confluence 3TF", overlay = false, precision = 2)

// Designed primarily for a 15-minute chart. The score is not called a
// probability. Forward hit rate and Wilson lower bound are measured separately.

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
string GROUP_STOCH = "01. Stochastic"
int kLength = input.int(14, "%K length", minval = 2, group = GROUP_STOCH)
int kSmooth = input.int(3, "%K smoothing", minval = 1, group = GROUP_STOCH)
int dLength = input.int(3, "%D smoothing", minval = 1, group = GROUP_STOCH)
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Developing HTF", "Confirmed only"], group = GROUP_STOCH,
     tooltip = "Confirmed only reads the last CLOSED 1H and 4H bar, so a value never changes once its chart bar has opened. Developing HTF REPAINTS: it reads those bars while they are still forming, so what you see live is not what the history shows afterwards. Measured by replaying every 15m bar as if it were the live bar, on BINANCE:BTCUSDT over 5983 bars: the 1H %K settles a median of 1.13 points away from what was displayed (p90 5.35, max 21.18) and the 4H %K a median of 1.41 (p90 5.79, max 27.37). More to the point for this script, the sign of the per-timeframe turn - one of the three gates the trigger depends on - flips after the fact on 10.2% of bars for the 1H leg and 12.7% for the 4H, and the %K/%D cross flips on 7.7% and 8.1%. ETHUSDT and SOLUSDT give the same figures within a tenth of a point. The default was Developing in the previous version; it is Confirmed now. One surprise worth knowing: despite the name, on historical bars this setting does not change the 1H or 4H legs at all - they are bit-identical between the two modes on every one of 6000 bars, because request.security resolves both to the last closed higher-timeframe bar. What it changes is the 15m leg, which is the chart timeframe: Confirmed reads the previous chart bar and Developing the current one, and they differ on essentially every bar by up to 33 points. The repaint above is about what the chart showed LIVE, which is a different thing from what switching this setting does to history.")

string GROUP_SIGNAL = "02. Confluence signal"
float oversold = input.float(20.0, "Oversold", minval = 0.0, maxval = 50.0, step = 1.0, group = GROUP_SIGNAL)
float overbought = input.float(80.0, "Overbought", minval = 50.0, maxval = 100.0, step = 1.0, group = GROUP_SIGNAL)
float softBand = input.float(15.0, "Soft extreme width", minval = 1.0, maxval = 40.0, step = 1.0, group = GROUP_SIGNAL)
int clusterBars = input.int(16, "Extreme clustering window (chart bars)", minval = 1, maxval = 100, group = GROUP_SIGNAL,
     tooltip = "On a 15-minute chart, 16 bars equals four hours. All three timeframes must have visited the same extreme during this window.")
float slopeFull = input.float(8.0, "Slope for full turn score", minval = 0.5, maxval = 30.0, step = 0.5, group = GROUP_SIGNAL)
float triggerScore = input.float(70.0, "Signal score threshold", minval = 40.0, maxval = 95.0, step = 1.0, group = GROUP_SIGNAL,
     tooltip = "At its default of 70 this threshold is very nearly unreachable, and that is a property of the score rather than of the market. score = 100 * position * (0.30 + 0.25*coherence + 0.30*turn + 0.15*cross), so the bracket is bounded by 1.0 and a score of 70 needs position >= 0.70 even if every other term is maxed out. In practice the bracket never gets close to 1 ON THE BARS THAT MATTER: measured over 5983 bars of 15m data, its median is 0.63 across all bars but only 0.58 on bars where position >= 0.85, and its MAXIMUM there falls from 0.98 to between 0.72 and 0.77. Position and the bracket are negatively correlated (-0.35 to -0.39 on the three instruments tested) because they ask for opposite things: position is high only deep inside the extreme, while turn and cross are high only once a leg has started back out of it. On the shipped Confirmed-only default the result is 2 bull and 4 bear triggers on BINANCE:BTCUSDT over 62 days, 0 and 2 on ETHUSDT, 1 and 2 on SOLUSDT. Lower it to 50 to get 10 and 21 on BTCUSDT, 5 and 17 on ETHUSDT, 8 and 21 on SOLUSDT. Nothing about the lower setting is validated - see the description - but 70 is not a strict filter, it is an off switch. Note also that the highest score this formula produced anywhere in the sample - three instruments, both data modes, about 36000 bars - is 74.46, so every setting above 75 on this slider is unreachable: 21 of its 56 positions cannot ever fire.")
bool requireTwoTurning = input.bool(true, "Require at least two timeframes turning", group = GROUP_SIGNAL,
     tooltip = "This gate is inert at the shipped defaults. Measured over 5983 bars of 15m data, turning it off changes the trigger count by nothing at all: 6 signals with it and 6 without on BINANCE:BTCUSDT, 2 and 2 on ETHUSDT, 3 and 3 on SOLUSDT. It only starts to matter once the score threshold is lowered - at a threshold of 60 it removes 2, 4 and 9 signals respectively. At 70 the score gate has already removed everything this gate would have.")

string GROUP_WEIGHTS = "03. Timeframe weights"
float w15Input = input.float(0.20, "15m", minval = 0.0, step = 0.05, group = GROUP_WEIGHTS)
float w1hInput = input.float(0.35, "1H", minval = 0.0, step = 0.05, group = GROUP_WEIGHTS)
float w4hInput = input.float(0.45, "4H", minval = 0.0, step = 0.05, group = GROUP_WEIGHTS)


string GROUP_VISUAL = "05. Visuals"
bool showD = input.bool(false, "Show %D lines", group = GROUP_VISUAL)
bool showScores = input.bool(true, "Show bull/bear scores", group = GROUP_VISUAL)
bool shadeArmed = input.bool(true, "Shade armed confluence windows", group = GROUP_VISUAL)
color color15 = input.color(color.rgb(0, 220, 220), "15m", group = GROUP_VISUAL)
color color1h = input.color(color.rgb(35, 110, 255), "1H", group = GROUP_VISUAL)
color color4h = input.color(color.rgb(255, 155, 25), "4H", group = GROUP_VISUAL)

// -----------------------------------------------------------------------------
// Helpers and MTF state
// -----------------------------------------------------------------------------
f_clamp01(float value) => math.max(0.0, math.min(1.0, value))

f_k() =>
    float raw = ta.stoch(close, high, low, kLength)
    ta.sma(raw, kSmooth)

f_state() =>
    float k = f_k()
    float d = ta.sma(k, dLength)
    [k, d, k - k[1]]

f_stateConfirmed() =>
    float k = f_k()
    float d = ta.sma(k, dLength)
    [k[1], d[1], k[1] - k[2]]

[k15Dev, d15Dev, v15Dev] = request.security(syminfo.tickerid, "15", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1hDev, d1hDev, v1hDev] = request.security(syminfo.tickerid, "60", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k4hDev, d4hDev, v4hDev] = request.security(syminfo.tickerid, "240", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[k15Con, d15Con, v15Con] = request.security(syminfo.tickerid, "15", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1hCon, d1hCon, v1hCon] = request.security(syminfo.tickerid, "60", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k4hCon, d4hCon, v4hCon] = request.security(syminfo.tickerid, "240", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

bool confirmedMode = dataMode == "Confirmed only"
float k15 = confirmedMode ? k15Con : k15Dev
float k1h = confirmedMode ? k1hCon : k1hDev
float k4h = confirmedMode ? k4hCon : k4hDev
float d15 = confirmedMode ? d15Con : d15Dev
float d1h = confirmedMode ? d1hCon : d1hDev
float d4h = confirmedMode ? d4hCon : d4hDev
float v15 = confirmedMode ? v15Con : v15Dev
float v1h = confirmedMode ? v1hCon : v1hDev
float v4h = confirmedMode ? v4hCon : v4hDev

float EPS = 1e-10
float weightSum = math.max(w15Input + w1hInput + w4hInput, EPS)
float w15 = w15Input / weightSum
float w1h = w1hInput / weightSum
float w4h = w4hInput / weightSum

// -----------------------------------------------------------------------------
// Confluence mathematics
// -----------------------------------------------------------------------------
float x15 = (k15 - 50.0) / 50.0
float x1h = (k1h - 50.0) / 50.0
float x4h = (k4h - 50.0) / 50.0
float meanX = w15 * x15 + w1h * x1h + w4h * x4h
float variance = w15 * math.pow(x15 - meanX, 2) + w1h * math.pow(x1h - meanX, 2) + w4h * math.pow(x4h - meanX, 2)
float dispersion = math.sqrt(math.max(variance, 0.0))
float coherence = 100.0 * (1.0 - f_clamp01(dispersion))
float composite = 50.0 + 50.0 * meanX

// Soft extreme membership equals 1 inside the strict extreme, then declines
// linearly to zero across softBand.
float bullPos15 = f_clamp01((oversold + softBand - k15) / softBand)
float bullPos1h = f_clamp01((oversold + softBand - k1h) / softBand)
float bullPos4h = f_clamp01((oversold + softBand - k4h) / softBand)
float bearPos15 = f_clamp01((k15 - (overbought - softBand)) / softBand)
float bearPos1h = f_clamp01((k1h - (overbought - softBand)) / softBand)
float bearPos4h = f_clamp01((k4h - (overbought - softBand)) / softBand)
float bullPosition = w15 * bullPos15 + w1h * bullPos1h + w4h * bullPos4h
float bearPosition = w15 * bearPos15 + w1h * bearPos1h + w4h * bearPos4h

float bullTurn15 = f_clamp01(v15 / slopeFull)
float bullTurn1h = f_clamp01(v1h / slopeFull)
float bullTurn4h = f_clamp01(v4h / slopeFull)
float bearTurn15 = f_clamp01(-v15 / slopeFull)
float bearTurn1h = f_clamp01(-v1h / slopeFull)
float bearTurn4h = f_clamp01(-v4h / slopeFull)
float bullTurn = w15 * bullTurn15 + w1h * bullTurn1h + w4h * bullTurn4h
float bearTurn = w15 * bearTurn15 + w1h * bearTurn1h + w4h * bearTurn4h
float bullCross = w15 * (k15 > d15 ? 1.0 : 0.0) + w1h * (k1h > d1h ? 1.0 : 0.0) + w4h * (k4h > d4h ? 1.0 : 0.0)
float bearCross = w15 * (k15 < d15 ? 1.0 : 0.0) + w1h * (k1h < d1h ? 1.0 : 0.0) + w4h * (k4h < d4h ? 1.0 : 0.0)

// Extreme location is a hard gate through multiplication. Alignment alone at
// the middle of the range therefore cannot generate a high reversal score.
float bullScore = 100.0 * bullPosition * (0.30 + 0.25 * coherence / 100.0 + 0.30 * bullTurn + 0.15 * bullCross)
float bearScore = 100.0 * bearPosition * (0.30 + 0.25 * coherence / 100.0 + 0.30 * bearTurn + 0.15 * bearCross)

bool strictBullExtreme = k15 <= oversold and k1h <= oversold and k4h <= oversold
bool strictBearExtreme = k15 >= overbought and k1h >= overbought and k4h >= overbought
int sinceBull15 = nz(ta.barssince(k15 <= oversold), 1000000)
int sinceBull1h = nz(ta.barssince(k1h <= oversold), 1000000)
int sinceBull4h = nz(ta.barssince(k4h <= oversold), 1000000)
int sinceBear15 = nz(ta.barssince(k15 >= overbought), 1000000)
int sinceBear1h = nz(ta.barssince(k1h >= overbought), 1000000)
int sinceBear4h = nz(ta.barssince(k4h >= overbought), 1000000)
bool bullArmed = sinceBull15 <= clusterBars and sinceBull1h <= clusterBars and sinceBull4h <= clusterBars
bool bearArmed = sinceBear15 <= clusterBars and sinceBear1h <= clusterBars and sinceBear4h <= clusterBars

int bullTurningCount = (v15 > 0 ? 1 : 0) + (v1h > 0 ? 1 : 0) + (v4h > 0 ? 1 : 0)
int bearTurningCount = (v15 < 0 ? 1 : 0) + (v1h < 0 ? 1 : 0) + (v4h < 0 ? 1 : 0)
bool bullTurnGate = not requireTwoTurning or bullTurningCount >= 2
bool bearTurnGate = not requireTwoTurning or bearTurningCount >= 2

var bool bullFired = false
var bool bearFired = false
if composite > 55.0 or not bullArmed
    bullFired := false
if composite < 45.0 or not bearArmed
    bearFired := false

bool bullSignal = bullArmed and bullTurnGate and bullScore >= triggerScore and not bullFired
bool bearSignal = bearArmed and bearTurnGate and bearScore >= triggerScore and not bearFired
if bullSignal
    bullFired := true
if bearSignal
    bearFired := true

// -----------------------------------------------------------------------------
// Plots and alerts
// -----------------------------------------------------------------------------
hline(overbought, "Overbought", color = color.new(color.red, 35), linestyle = hline.style_dashed)
hline(50.0, "Equilibrium", color = color.new(color.gray, 70), linestyle = hline.style_dotted)
hline(oversold, "Oversold", color = color.new(color.lime, 35), linestyle = hline.style_dashed)
// The two score areas are declared FIRST so every line draws on top of them. In the previous
// version they came last at transparency 35 and buried what they were meant to annotate: at
// least one plotted line sat underneath one of them on 38.7% of bars of BINANCE:BTCUSDT 15m,
// median 13.4 points deep, with the 4H %K line covered on 16.8% and the white composite on 11.2%.
// They are also much fainter now, because they are context rather than the subject.
// Each score is drawn at the end of the pane its own condition lives at: the bull score grows
// up from 0 (oversold), the bear score hangs down from 100 (overbought). In the previous
// version both grew up from 0, which put the red area under the oversold line - it covered
// that line on 45.4% of bars of BINANCE:BTCUSDT 15m (38.8% on ETHUSDT, 41.8% on SOLUSDT) and
// never once reached the overbought line it describes: its maximum over 5982 bars is 71.75.
plot(showScores ? bullScore : na, "Bull confluence area", color = color.new(color.lime, 84), style = plot.style_area, histbase = 0.0, linewidth = 1, display = display.pane)
plot(showScores ? 100.0 - bearScore : na, "Bear confluence area", color = color.new(color.red, 84), style = plot.style_area, histbase = 100.0, linewidth = 1, display = display.pane)

// The areas are shapes rather than readings, so the two scores report their real values in
// the Data Window rather than putting a plotted complement in the legend.
plot(bullScore, "Bull confluence score", display = display.data_window)
plot(bearScore, "Bear confluence score", display = display.data_window)

// %D is off by default and stays behind its own %K.
plot(showD ? d15 : na, "15m %D", color = color.new(color15, 65), linewidth = 1)
plot(showD ? d1h : na, "1H %D", color = color.new(color1h, 65), linewidth = 1)
plot(showD ? d4h : na, "4H %D", color = color.new(color4h, 65), linewidth = 1)

// Weight the lines by what they summarise rather than by timeframe: the composite is the one
// series that carries all three, so it leads. The 4H leg was linewidth 4, which made the
// slowest and most stepped series the loudest thing in the pane.
plot(k15, "15m %K", color = color.new(color15, 25), linewidth = 1)
plot(k1h, "1H %K", color = color.new(color1h, 15), linewidth = 1)
plot(k4h, "4H %K", color = color4h, linewidth = 2)
plot(composite, "Weighted 3TF composite", color = color.white, linewidth = 3)

// One neutral wash rather than a second lime/red pair competing with the score areas.
color armedColor = (bullArmed or bearArmed) ? color.new(color.gray, 90) : na
bgcolor(shadeArmed ? armedColor : na, title = "All three timeframes recently at the same extreme")
plotshape(strictBullExtreme, "All three timeframes oversold", shape.circle, location.bottom, color = color.new(color.lime, 30), size = size.tiny)
plotshape(strictBearExtreme, "All three timeframes overbought", shape.circle, location.top, color = color.new(color.red, 30), size = size.tiny)
plotshape(bullSignal, "Bullish confluence trigger", shape.triangleup, location.bottom, color = color.lime, size = size.small)
plotshape(bearSignal, "Bearish confluence trigger", shape.triangledown, location.top, color = color.red, size = size.small)

alertcondition(bullSignal, "Bullish 15m/1H/4H STOCH confluence", "15m, 1H and 4H Stochastic formed an oversold cluster and the confluence score cleared its threshold. This describes the current geometry and is not a forecast. At the default threshold this fires between two and six times per two months depending on the instrument, so it has never been tested on a usable sample - see the description for what was tested instead.")
alertcondition(bearSignal, "Bearish 15m/1H/4H STOCH confluence", "15m, 1H and 4H Stochastic formed an overbought cluster and the confluence score cleared its threshold. This describes the current geometry and is not a forecast. At the default threshold this fires between two and six times per two months depending on the instrument, so it has never been tested on a usable sample - see the description for what was tested instead.")
alertcondition(strictBullExtreme and not strictBullExtreme[1], "Strict 3TF oversold", "All three STOCH timeframes are simultaneously oversold.")
alertcondition(strictBearExtreme and not strictBearExtreme[1], "Strict 3TF overbought", "All three STOCH timeframes are simultaneously overbought.")
````
