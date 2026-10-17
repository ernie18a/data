# MTF MACD Cross-Decay Oscillator

- url: https://www.tradingview.com/script/88xURpTt-MTF-MACD-Cross-Decay-Oscillator/
- type: indicator
- pine_id: PUB;eccdd66e06b14da2ad17b49c9329626a
- version: 1.0

## Description

[b]MTF MACD Cross-Decay Oscillator[/b]
[i]A multi-timeframe momentum compass that tracks MACD crossovers across 15 different timeframes simultaneously — from 1-minute to monthly — and weights them by both recency and importance. Think of it as having 15 different speedometers for the same car, each measuring speed at a different scale, then combining them into one clear "direction and strength" reading.[/i]
[b]What This Actually Does (In Plain English)[/b]
Most traders look at MACD on one timeframe and make decisions. But a 5-minute MACD crossover might mean nothing if the daily MACD is strongly bearish. Or a daily MACD might be sluggish while the 1-minute is already flipping back and forth.
This indicator solves that by:
[list]
[*]Running MACD on [b]15 timeframes at once[/b] — 5 lower than your chart, 10 higher
[*]Scoring each timeframe based on [b]how fresh its most recent crossover is[/b] (recent crossovers count more)
[*][b]Weighting higher timeframes more heavily[/b] because they represent bigger, more significant moves
[*]Combining everything into a single score from -1 to +1
[/list]
The result is a "consensus view" of momentum across all time scales.
[b]How The Scoring Works[/b]
For each timeframe, the indicator asks three questions:
[list]
[*][b]Did MACD recently cross?[/b] If MACD line crossed above signal line = bullish (+1). If below = bearish (-1). If no recent cross = 0.
[*][b]How fresh is that cross?[/b] A cross from 2 bars ago counts fully. A cross from 20 bars ago counts less. A cross from 100 bars ago counts almost nothing. This is "exponential decay" — like radioactive half-life for signals.
[*][b]Is the signal still alive?[/b] If the freshness drops below a "floor" threshold, the score goes to zero. Stale signals are ignored.
[/list]
[b]All The Settings Explained[/b]
[i]MACD Settings[/i]
[list]
[*][b]Fast/Slow/Signal:[/b] Standard MACD parameters. Default 12/26/9. These apply to ALL timeframes. You generally don't need to change these.
[/list]
[i]Scoring Engine[/i]
[list]
[*][b]Decay λ (Lambda):[/b] How fast old crossovers lose importance. Default 0.08. Higher (0.12) = signals fade quickly, only very recent crossovers matter. Lower (0.05) = signals last longer, older crossovers still contribute. Think of it as "how long does a MACD cross stay relevant?" At 0.08, a cross from ~9 bars ago has half its original strength.
[*][b]Apply Auto-Weight Scaling:[/b] When ON, the indicator automatically makes higher timeframes more important. Recommended: ON.
[*][b]Auto-Weight Exponent α:[/b] How much more important higher timeframes become. Default 0.25. At 0 = all timeframes equal. At 1.0 = higher timeframes completely dominate. 0.25 gives a noticeable but balanced HTF bias.
[*][b]Freshness Floor:[/b] The minimum "freshness" score before a timeframe is silenced. Default 0.05. Prevents ancient, barely-relevant crossovers from adding noise. Raise to 0.10 for cleaner signals (fewer timeframes contributing). Lower to 0.01 for more sensitivity.
[*][b]Output Smoothing:[/b] EMA smoothing on the final combined score. Default 5. Higher = smoother line, more lag. Lower = more jagged, more immediate.
[/list]
[i]Lower Timeframes (5 slots)[/i]
[list]
[*][b]L1 through L5:[/b] Timeframes below your current chart. Defaults: 1, 2, 5, 10, 15 minutes. Each has an ON toggle and a manual weight.
[*][b]Manual Weights:[/b] Default 0.1, 0.2, 0.3, 0.4, 0.5. These are multiplied by the auto-weight if enabled. Higher numbers = more influence from that timeframe.
[*][b]Important:[/b] Lower timeframes use [b]confirmed previous-bar data[/b] (with 1-bar delay) to prevent repainting. This means LTF signals lag by 1 bar but are reliable.
[/list]
[i]Higher Timeframes (10 slots)[/i]
[list]
[*][b]H1 through H10:[/b] Timeframes above your current chart. Defaults: 30min, 1hr, 1.5hr, 2hr, 4hr, Daily, 2D, 3D, Weekly, Monthly.
[*][b]Manual Weights:[/b] Default 0.6 through 1.5, increasing with timeframe. These represent the "structural importance" of each scale.
[*][b]Important:[/b] HTF data uses [b]confirmed close[/b] (no repainting) because higher timeframes naturally lag.
[/list]
[b]How To Read The Chart[/b]
[list]
[*][b]Main Line (Thick Green/Red):[/b] The combined MXDO score. Ranges from -1 to +1.
[list]
[*]Above zero = bullish consensus across timeframes
[*]Below zero = bearish consensus
[*]Near zero = mixed or quiet — no clear direction
[/list]
[*][b]Thin Line (Faded, HTF Backbone):[/b] The score using ONLY higher timeframes. When this aligns with the main line, the signal is strong. When they diverge, lower timeframes are fighting higher timeframes — caution.
[*][b]Histogram Columns:[/b] The same score as columns. Green = bullish, red = bearish. Brighter = score increasing in that direction. Faded = score weakening or reversing.
[*][b]Filled Area (Zero Fill):[/b] The shaded region between the score line and zero. Shows intensity of the consensus.
[*][b]Dotted Lines at ±0.5:[/b] Moderate strength markers. Crossing these indicates meaningful momentum building.
[/list]

## Source Code

````pine
//@version=6
indicator("MTF MACD Cross-Decay Oscillator", "MXDO v3", overlay=false, max_bars_back=5000)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string GP_M = "MACD"
int    fast   = input.int(12, "Fast",   minval=1, group=GP_M)
int    slow   = input.int(26, "Slow",   minval=1, group=GP_M)
int    sigLen = input.int(9,  "Signal", minval=1, group=GP_M)

string GP_S = "Scoring Engine"
float LAMBDA = input.float(0.08, "Decay λ  (half-life ≈ 0.693/λ TF-bars)", minval=0.005, maxval=1.0, step=0.005, group=GP_S,
               tooltip="Exponential decay rate per bar *in each TF's own time*.\n0.05 → ~14 TF-bars   0.08 → ~9   0.12 → ~6")
bool  useAW  = input.bool(true, "Apply Auto-Weight Scaling", group=GP_S,
               tooltip="When ON, manual weights are multiplied by (TF_sec / chart_sec)^α.\nWhen OFF, only manual weights are used.")
float ALPHA  = input.float(0.25, "Auto-Weight Exponent α", minval=0.0, maxval=1.0, step=0.05, group=GP_S,
               tooltip="Only active when Auto-Weight is ON.\nHigher α → more HTF dominance.\n0 = equal, 0.5 = strong HTF bias")
float GATE   = input.float(0.05, "Freshness Floor", minval=0.0, maxval=0.5, step=0.01, group=GP_S,
               tooltip="Scores below this freshness are zeroed.\nPrevents stale crosses from contributing noise.")
int   smLen  = input.int(5, "Output Smoothing (EMA)", minval=1, maxval=50, group=GP_S)

string GP_L = "Lower Timeframes  ( TF │ On │ Weight )"
string lt1 = input.timeframe("1",  "L 1", group=GP_L, inline="l1"),  bool lu1 = input.bool(true, "", group=GP_L, inline="l1"),  float lw1 = input.float(0.1, "W", group=GP_L, inline="l1", minval=0, step=0.1)
string lt2 = input.timeframe("2",  "L 2", group=GP_L, inline="l2"),  bool lu2 = input.bool(true, "", group=GP_L, inline="l2"),  float lw2 = input.float(0.2, "W", group=GP_L, inline="l2", minval=0, step=0.1)
string lt3 = input.timeframe("5",  "L 3", group=GP_L, inline="l3"),  bool lu3 = input.bool(true, "", group=GP_L, inline="l3"),  float lw3 = input.float(0.3, "W", group=GP_L, inline="l3", minval=0, step=0.1)
string lt4 = input.timeframe("10", "L 4", group=GP_L, inline="l4"),  bool lu4 = input.bool(true, "", group=GP_L, inline="l4"),  float lw4 = input.float(0.4, "W", group=GP_L, inline="l4", minval=0, step=0.1)
string lt5 = input.timeframe("15", "L 5", group=GP_L, inline="l5"),  bool lu5 = input.bool(true, "", group=GP_L, inline="l5"),  float lw5 = input.float(0.5, "W", group=GP_L, inline="l5", minval=0, step=0.1)

string GP_H = "Higher Timeframes  ( TF │ On │ Weight )"
string ht1  = input.timeframe("30",  "H 1",  group=GP_H, inline="h1"),   bool hu1  = input.bool(true, "", group=GP_H, inline="h1"),   float hw1  = input.float(0.6, "W", group=GP_H, inline="h1",  minval=0, step=0.1)
string ht2  = input.timeframe("60",  "H 2",  group=GP_H, inline="h2"),   bool hu2  = input.bool(true, "", group=GP_H, inline="h2"),   float hw2  = input.float(0.7, "W", group=GP_H, inline="h2",  minval=0, step=0.1)
string ht3  = input.timeframe("90", "H 3",  group=GP_H, inline="h3"),   bool hu3  = input.bool(true, "", group=GP_H, inline="h3"),   float hw3  = input.float(0.8, "W", group=GP_H, inline="h3",  minval=0, step=0.1)
string ht4  = input.timeframe("120", "H 4",  group=GP_H, inline="h4"),   bool hu4  = input.bool(true, "", group=GP_H, inline="h4"),   float hw4  = input.float(0.9, "W", group=GP_H, inline="h4",  minval=0, step=0.1)
string ht5  = input.timeframe("240", "H 5",  group=GP_H, inline="h5"),   bool hu5  = input.bool(true, "", group=GP_H, inline="h5"),   float hw5  = input.float(1, "W", group=GP_H, inline="h5",  minval=0, step=0.1)
string ht6  = input.timeframe("1D", "H 6",  group=GP_H, inline="h6"),   bool hu6  = input.bool(true, "", group=GP_H, inline="h6"),   float hw6  = input.float(1.1, "W", group=GP_H, inline="h6",  minval=0, step=0.1)
string ht7  = input.timeframe("2D",   "H 7",  group=GP_H, inline="h7"),   bool hu7  = input.bool(true, "", group=GP_H, inline="h7"),   float hw7  = input.float(1.2, "W", group=GP_H, inline="h7",  minval=0, step=0.1)
string ht8  = input.timeframe("3D",   "H 8",  group=GP_H, inline="h8"),   bool hu8  = input.bool(true, "", group=GP_H, inline="h8"),   float hw8  = input.float(1.3, "W", group=GP_H, inline="h8",  minval=0, step=0.1)
string ht9  = input.timeframe("W",   "H 9",  group=GP_H, inline="h9"),   bool hu9  = input.bool(true, "", group=GP_H, inline="h9"),   float hw9  = input.float(1.4, "W", group=GP_H, inline="h9",  minval=0, step=0.1)
string ht10 = input.timeframe("1M",  "H10",  group=GP_H, inline="h10"),  bool hu10 = input.bool(true, "", group=GP_H, inline="h10"),  float hw10 = input.float(1.5, "W", group=GP_H, inline="h10", minval=0, step=0.1)

string GP_V = "Display"
bool showHist  = input.bool(true, "Histogram",       group=GP_V)
bool showFill  = input.bool(true, "Zero Fill",       group=GP_V)
bool showHTF   = input.bool(true, "HTF-Only Trace",  group=GP_V)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CORE SCORE FUNCTION
//
//  Evaluated INSIDE request.security() → bar_index, close, etc.
//  resolve in that TF's own context. Decay is measured in
//  *that TF's bars*, not chart bars.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
macdScore() =>
    float m = ta.ema(close, fast) - ta.ema(close, slow)
    float s = ta.ema(m, sigLen)
    var int _dir = 0
    var int _cb  = 0
    bool ok = not na(m[1]) and not na(s[1])
    if ok and m > s and m[1] <= s[1]
        _dir := 1,  _cb := bar_index
    if ok and m < s and m[1] >= s[1]
        _dir := -1, _cb := bar_index
    float freshness = math.exp(-LAMBDA * (bar_index - _cb))
    float sc = (_dir == 0 or freshness < GATE) ? 0.0 : _dir * freshness
    sc

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  NON-REPAINTING SECURITY CALLS — 15 TFs × 2 = 30 calls
//
//  HTF / same-TF :  lookahead_off  (confirms on bar close)
//  LTF           :  [1] + lookahead_on  (previous confirmed bar)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string S   = syminfo.tickerid
int    cSec = timeframe.in_seconds(timeframe.period)
isLTF(string tf) => timeframe.in_seconds(tf) < cSec

// ── Lower TFs (5) ──
float _l1h = request.security(S, lt1, macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _l1l = request.security(S, lt1, macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float l1s  = lu1 ? nz(isLTF(lt1) ? _l1l : _l1h) : 0.0

float _l2h = request.security(S, lt2, macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _l2l = request.security(S, lt2, macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float l2s  = lu2 ? nz(isLTF(lt2) ? _l2l : _l2h) : 0.0

float _l3h = request.security(S, lt3, macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _l3l = request.security(S, lt3, macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float l3s  = lu3 ? nz(isLTF(lt3) ? _l3l : _l3h) : 0.0

float _l4h = request.security(S, lt4, macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _l4l = request.security(S, lt4, macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float l4s  = lu4 ? nz(isLTF(lt4) ? _l4l : _l4h) : 0.0

float _l5h = request.security(S, lt5, macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _l5l = request.security(S, lt5, macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float l5s  = lu5 ? nz(isLTF(lt5) ? _l5l : _l5h) : 0.0

// ── Higher TFs (10) ──
float _h1h = request.security(S, ht1,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h1l = request.security(S, ht1,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h1s  = hu1  ? nz(isLTF(ht1)  ? _h1l  : _h1h)  : 0.0

float _h2h = request.security(S, ht2,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h2l = request.security(S, ht2,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h2s  = hu2  ? nz(isLTF(ht2)  ? _h2l  : _h2h)  : 0.0

float _h3h = request.security(S, ht3,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h3l = request.security(S, ht3,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h3s  = hu3  ? nz(isLTF(ht3)  ? _h3l  : _h3h)  : 0.0

float _h4h = request.security(S, ht4,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h4l = request.security(S, ht4,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h4s  = hu4  ? nz(isLTF(ht4)  ? _h4l  : _h4h)  : 0.0

float _h5h = request.security(S, ht5,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h5l = request.security(S, ht5,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h5s  = hu5  ? nz(isLTF(ht5)  ? _h5l  : _h5h)  : 0.0

float _h6h = request.security(S, ht6,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h6l = request.security(S, ht6,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h6s  = hu6  ? nz(isLTF(ht6)  ? _h6l  : _h6h)  : 0.0

float _h7h = request.security(S, ht7,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h7l = request.security(S, ht7,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h7s  = hu7  ? nz(isLTF(ht7)  ? _h7l  : _h7h)  : 0.0

float _h8h = request.security(S, ht8,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h8l = request.security(S, ht8,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h8s  = hu8  ? nz(isLTF(ht8)  ? _h8l  : _h8h)  : 0.0

float _h9h = request.security(S, ht9,  macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h9l = request.security(S, ht9,  macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h9s  = hu9  ? nz(isLTF(ht9)  ? _h9l  : _h9h)  : 0.0

float _h10h = request.security(S, ht10, macdScore(),    barmerge.gaps_off, barmerge.lookahead_off)
float _h10l = request.security(S, ht10, macdScore()[1], barmerge.gaps_off, barmerge.lookahead_on)
float h10s  = hu10 ? nz(isLTF(ht10) ? _h10l : _h10h) : 0.0

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  WEIGHT CALCULATION
//
//  Auto-Weight ON  →  final_w = manual_w × (TF_sec / chart_sec)^α
//  Auto-Weight OFF →  final_w = manual_w
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
calcW(string tf, bool on, float mw) =>
    float aw = useAW ? math.pow(math.max(timeframe.in_seconds(tf) / math.max(cSec, 1), 0.001), ALPHA) : 1.0
    on ? mw * aw : 0.0

float wL1 = calcW(lt1, lu1, lw1),  float wL2 = calcW(lt2, lu2, lw2)
float wL3 = calcW(lt3, lu3, lw3),  float wL4 = calcW(lt4, lu4, lw4)
float wL5 = calcW(lt5, lu5, lw5)

float wH1  = calcW(ht1,  hu1,  hw1),   float wH2  = calcW(ht2,  hu2,  hw2)
float wH3  = calcW(ht3,  hu3,  hw3),   float wH4  = calcW(ht4,  hu4,  hw4)
float wH5  = calcW(ht5,  hu5,  hw5),   float wH6  = calcW(ht6,  hu6,  hw6)
float wH7  = calcW(ht7,  hu7,  hw7),   float wH8  = calcW(ht8,  hu8,  hw8)
float wH9  = calcW(ht9,  hu9,  hw9),   float wH10 = calcW(ht10, hu10, hw10)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  COMPOSITE — weighted sum normalised to [−1, +1]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float sumLTF = wL1*l1s + wL2*l2s + wL3*l3s + wL4*l4s + wL5*l5s
float wLTF   = wL1 + wL2 + wL3 + wL4 + wL5

float sumHTF = wH1*h1s  + wH2*h2s  + wH3*h3s  + wH4*h4s  + wH5*h5s +
               wH6*h6s  + wH7*h7s  + wH8*h8s  + wH9*h9s  + wH10*h10s
float wHTF   = wH1 + wH2 + wH3 + wH4 + wH5 +
               wH6 + wH7 + wH8 + wH9 + wH10

float wAll   = wLTF + wHTF
float sumAll = sumLTF + sumHTF

float rawAll = sumAll / math.max(wAll, 1e-10)
float rawHTF = sumHTF / math.max(wHTF, 1e-10)

float out    = smLen > 1 ? ta.ema(rawAll, smLen) : rawAll
float outHTF = smLen > 1 ? ta.ema(rawHTF, smLen) : rawHTF

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PLOTTING
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color cBull = #26a69a
color cBear = #ef5350
color cNeut = color.gray

color lineC  = out > 0 ? cBull : out < 0 ? cBear : cNeut
color htfCol = outHTF > 0 ? cBull : outHTF < 0 ? cBear : cNeut

plot(out, "MXDO", lineC, 2)
plot(showHTF ? outHTF : na, "HTF Backbone", color.new(htfCol, 60), 1, plot.style_line)

hline( 0,    "Zero", color.new(cNeut, 70), hline.style_dotted)
hline( 0.5,  "+0.5", color.new(cNeut, 85), hline.style_dotted)
hline(-0.5,  "−0.5", color.new(cNeut, 85), hline.style_dotted)

color hCol = out > 0 ? (out > out[1] ? cBull : color.new(cBull, 55)) :
             out < 0 ? (out < out[1] ? cBear : color.new(cBear, 55)) : cNeut
plot(showHist ? out : na, "Hist", hCol, 1, plot.style_columns)

p0 = plot(showFill ? 0   : na, "", color.new(na, 100), display=display.none)
p1 = plot(showFill ? out : na, "", color.new(na, 100), display=display.none)
fill(p0, p1, out > 0 ? color.new(cBull, 85) : color.new(cBear, 85))
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````
