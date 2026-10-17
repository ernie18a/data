# Permutation Entropy Regime [Jayadev Rana]

- url: https://www.tradingview.com/script/Jm9cPu9E-Permutation-Entropy-Regime-Jayadev-Rana/
- type: indicator
- pine_id: PUB;babeb6ada97e4b94a76dd0f9af92676c
- version: 1.0

## Description

Permutation Entropy Regime

OVERVIEW
Permutation Entropy Regime is an original open-source tool that measures how ordered or random recent price action is, and turns that into a simple market-state read. Instead of moving averages or momentum, it borrows an idea from information theory called permutation entropy (the Bandt-Pompe method) to score the "predictability" of the market, then classifies the current bar into one of five regimes.

It is not a buy/sell signal generator. It is a context and filter tool that tries to answer one question: is the market currently structured enough to trend or swing, or is it behaving like random noise where most systematic edges break down?

HOW IT WORKS
1. Ordinal patterns. Over a rolling window of closes, the script looks at every group of three consecutive closes and records their rank order (which is highest, middle, lowest). With three values there are six possible orderings.
2. Permutation entropy. It builds a histogram of how often each of the six orderings appears in the window, then computes the Shannon entropy of that distribution and normalizes it to a 0-1 scale. A low value means a few orderings dominate (structured, repeatable behavior); a high value means all orderings appear about equally (random-walk-like behavior).
3. Predictability. Predictability is reported as (1 - normalized entropy) x 100. Higher means more ordered.
4. Structure Rank. Because raw predictability sits in different ranges on different symbols and timeframes, the script percentile-ranks the current predictability against its own recent history (Structure Rank Lookback). This adaptive 0-100 Structure Rank is the main line and the basis for the regime decision, so the tool self-calibrates to each market.
5. Drift bias. A separate term measures the net share of up versus down closes across the window (-1 to +1). It is used only to label a structured regime as Up, Down, or Range.

REGIMES
- Structured Up: Structure Rank at or above the Structured Level and drift bias positive.
- Structured Down: Structure Rank at or above the Structured Level and drift bias negative.
- Structured Range: Structure Rank high but drift near zero (ordered but sideways or mean-reverting).
- Neutral: Structure Rank between the two levels.
- Random / Chop: Structure Rank at or below the Chop Level.

INPUTS
- Core: Entropy Window (window length for the ordinal-pattern histogram) and Predictability Smoothing (EMA applied to the raw score).
- Regime: Structure Rank Lookback (adaptive percentile window), Structured Level and Chop Level (the two cutoffs), and Drift Bias Threshold (how strong the directional tilt must be to call Up or Down).
- Visuals: color price bars by regime, shade the indicator pane by regime, show the dashboard and choose its corner.
- Colors: one color per regime.

WHAT IT PLOTS
- Structure Rank line (0-100), colored by the active regime.
- Raw Predictability line for reference.
- Dashed Structured Level, Chop Level, and a midline.
- Optional regime background in the pane, and optional regime coloring of the main price bars.
- A dashboard showing the regime, Structure Rank, Predictability, normalized entropy, drift bias, and how many bars the current regime has lasted.

ALERTS
Five bar-close alertconditions: entered Structured Up, entered Structured Down, entered Structured Range, entered Random / Chop, and a generic Regime Changed. They evaluate on confirmed bar close.

HOW TO USE IT
This is a context filter, not a signal by itself. Common uses:
- Take your own trend or breakout setups mainly while the market is in a Structured Up or Structured Down regime, and stand aside or reduce size in Random / Chop.
- Prefer mean-reversion or range tactics in Structured Range.
- Combine the regime with your existing entries rather than acting on the regime alone.

MARKETS AND TIMEFRAMES
It is symbol- and timeframe-agnostic because the Structure Rank adapts to each market's own history. It runs on intraday and higher timeframes. Note that most liquid instruments are close to random at short intraday scales, so absolute Predictability is often low; the Structure Rank is what makes the reading comparable and actionable across markets.

CALCULATION AND REPAINTING NOTES
- All calculations use closed-bar data (close and historical closes). Values for the most recent, still-forming bar update until that bar closes, which is normal for any close-based indicator; historical values do not repaint after a bar has closed.
- The embedding dimension is fixed at 3 (groups of three closes). Ties between equal closes are resolved with a consistent rule and are rare on most instruments.
- There are no higher-timeframe requests and no future-looking access.

LIMITATIONS
- It measures structure, not direction quality; a structured regime is not a guarantee of follow-through.
- Permutation entropy of order 3 is a coarse estimate; very small windows are noisy and very large windows are slow to react.
- On extremely low-volatility or illiquid data, repeated equal closes can bias the pattern histogram.
- Like all indicators, it describes past and current behavior and does not predict future prices.

This script is open-source under the Mozilla Public License 2.0. It is provided for research and educational purposes only and is not financial advice. Test any tool on your own markets and settings before relying on it.
Open-source script

In true TradingView spirit, the creator of this script has made it open-source, so that traders can review and verify its functionality. Kudos to the author! While you can use it for free, remember that republishing the code is subject to our House Rules.


bluealgocapital
Disclaimer
The information and publications are not meant to be, and do not constitute, financial, investment, trading, or other types of advice or recommendations supplied or endorsed by TradingView. Read more in the Terms of Use.

## Source Code

````pine
//@version=6
// Permutation Entropy Regime [Jayadev Rana]
// This source code is subject to the terms of the Mozilla Public License 2.0.
//
// Concept: classify the market into a "predictability regime" using the
// permutation entropy (Bandt-Pompe, embedding dimension 3) of recent closes.
// Low entropy = ordered / structured price (clean trend or clean oscillation);
// high entropy = disordered / random-walk chop. A drift-bias term splits
// structured regimes into Up / Down / Range. Computed on confirmed bars only.

indicator("Permutation Entropy Regime [Jayadev Rana]", shorttitle="PER", overlay=false, max_bars_back=200)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
grpCore   = "Core"
winLen    = input.int(50, "Entropy Window (bars)", minval=10, maxval=150, group=grpCore, tooltip="Number of ordinal patterns used to estimate permutation entropy. Larger = smoother and slower to react; smaller = more responsive and noisier. Embedding dimension is 3 (compares 3 consecutive closes).")
smoothLen = input.int(3, "Predictability Smoothing", minval=1, maxval=50, group=grpCore, tooltip="EMA length applied to the raw predictability score to reduce single-bar jitter. Set 1 to disable.")

grpReg    = "Regime"
rankLb    = input.int(200, "Structure Rank Lookback", minval=20, maxval=500, group=grpReg, tooltip="History window used to percentile-rank the current predictability against its own past, so the regime cutoff adapts per instrument and timeframe.")
structLv  = input.int(60, "Structured Level", minval=50, maxval=95, group=grpReg, tooltip="A Structure Rank at or above this value marks a structured (predictable) regime.")
chopLv    = input.int(40, "Chop Level", minval=5, maxval=50, group=grpReg, tooltip="A Structure Rank at or below this value marks a random / chop regime. Between the two levels is Neutral.")
driftTh   = input.float(0.15, "Drift Bias Threshold", minval=0.0, maxval=1.0, step=0.05, group=grpReg, tooltip="Minimum absolute drift bias (net share of up vs down closes over the window, -1..+1) needed to call a structured regime Up or Down rather than Range.")

grpVis    = "Visuals"
colorBars = input.bool(true, "Color price bars by regime", group=grpVis, tooltip="Recolor the main chart candles using the current regime color.")
showBg    = input.bool(true, "Shade this pane by regime", group=grpVis)
showDash  = input.bool(true, "Show dashboard", group=grpVis)
dashPos   = input.string("Top Right", "Dashboard position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpVis)

grpCol    = "Colors"
cUp       = input.color(#26a69a, "Structured Up", group=grpCol)
cDn       = input.color(#ef5350, "Structured Down", group=grpCol)
cRange    = input.color(#42a5f5, "Structured Range", group=grpCol)
cNeutral  = input.color(#b0bec5, "Neutral", group=grpCol)
cChop     = input.color(#ffa726, "Random / Chop", group=grpCol)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
// Ordinal pattern id (0..5) of three values using strict rank comparison.
patternId(float a, float b, float c) =>
    int ra = (a > b ? 1 : 0) + (a > c ? 1 : 0)
    int rb = (b > a ? 1 : 0) + (b > c ? 1 : 0)
    int rc = (c > a ? 1 : 0) + (c > b ? 1 : 0)
    int id = ra * 2 + (rb > rc ? 1 : 0)
    id := id < 0 ? 0 : id > 5 ? 5 : id
    id

f1(float x) => na(x) ? "-" : str.tostring(x, "#.0")
f2(float x) => na(x) ? "-" : str.tostring(x, "#.00")

//------------------------------------------------------------------------------
// Permutation entropy (embedding dimension 3, delay 1)
//------------------------------------------------------------------------------
var array<float> hist = array.new<float>(6, 0.0)

float He        = na
float predRaw   = na
float driftBias = na

enoughBars = bar_index > winLen + 3
if enoughBars
    for k = 0 to 5
        array.set(hist, k, 0.0)
    float driftSum = 0.0
    for i = 0 to winLen - 1
        float a = close[i]
        float b = close[i + 1]
        float c = close[i + 2]
        int id = patternId(a, b, c)
        array.set(hist, id, array.get(hist, id) + 1.0)
        driftSum += math.sign(a - b)
    float total = winLen
    float ent = 0.0
    for k = 0 to 5
        float p = array.get(hist, k) / total
        if p > 0.0
            ent -= p * math.log(p)
    He        := ent / math.log(6)
    predRaw   := (1.0 - He) * 100.0
    driftBias := driftSum / winLen

float predScore = ta.ema(predRaw, smoothLen)
float sRank     = ta.percentrank(predScore, rankLb)

//------------------------------------------------------------------------------
// Regime classification
//------------------------------------------------------------------------------
bool hasRank    = not na(sRank)
bool structured = hasRank and sRank >= structLv
bool chop       = hasRank and sRank <= chopLv

color regimeColor = cNeutral
string regime = "Neutral"
if chop
    regime := "Random / Chop"
    regimeColor := cChop
else if structured
    if driftBias > driftTh
        regime := "Structured Up"
        regimeColor := cUp
    else if driftBias < -driftTh
        regime := "Structured Down"
        regimeColor := cDn
    else
        regime := "Structured Range"
        regimeColor := cRange

var string prevRegime = ""
bool regimeChanged = prevRegime != "" and regime != prevRegime
var int barsInRegime = 0
barsInRegime := prevRegime == regime ? barsInRegime + 1 : 1

//------------------------------------------------------------------------------
// Alerts (bar close)
//------------------------------------------------------------------------------
bool aUp    = barstate.isconfirmed and regime == "Structured Up" and barsInRegime == 1
bool aDn    = barstate.isconfirmed and regime == "Structured Down" and barsInRegime == 1
bool aRange = barstate.isconfirmed and regime == "Structured Range" and barsInRegime == 1
bool aChop  = barstate.isconfirmed and regime == "Random / Chop" and barsInRegime == 1
bool aChg   = barstate.isconfirmed and regimeChanged
alertcondition(aUp, "Entered Structured Up", "Permutation Entropy Regime: Structured Up")
alertcondition(aDn, "Entered Structured Down", "Permutation Entropy Regime: Structured Down")
alertcondition(aRange, "Entered Structured Range", "Permutation Entropy Regime: Structured Range")
alertcondition(aChop, "Entered Random / Chop", "Permutation Entropy Regime: Random / Chop")
alertcondition(aChg, "Regime Changed", "Permutation Entropy Regime: regime changed")

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
plot(predScore, "Predictability", color=color.new(color.gray, 40), linewidth=1)
plot(sRank, "Structure Rank", color=regimeColor, linewidth=2)
hline(structLv, "Structured Level", color=color.new(color.green, 60), linestyle=hline.style_dashed)
hline(chopLv, "Chop Level", color=color.new(color.orange, 60), linestyle=hline.style_dashed)
hline(50, "Mid", color=color.new(color.gray, 80))

bgcolor(showBg and hasRank ? color.new(regimeColor, 90) : na, title="Regime background")
barcolor(colorBars and hasRank ? regimeColor : na, title="Regime bar color")

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
tablePos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(tablePos, 2, 8, border_width=1, frame_width=1, frame_color=color.new(color.gray, 50))

if showDash and barstate.islast
    table.cell(dash, 0, 0, "Permutation Entropy Regime", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(dash, 1, 0, "", bgcolor=color.new(color.black, 20))
    table.cell(dash, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 1, 1, regime, text_color=color.white, bgcolor=color.new(regimeColor, 10), text_size=size.small)
    table.cell(dash, 0, 2, "Structure Rank", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 2, f1(sRank), text_color=regimeColor, text_size=size.small)
    table.cell(dash, 0, 3, "Predictability", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 3, f1(predScore), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Norm. Entropy", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 4, na(He) ? "-" : f1(He * 100) + "%", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 5, "Drift Bias", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 5, f2(driftBias), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Bars in Regime", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(barsInRegime), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Window / Dim", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(winLen) + " / 3", text_color=color.white, text_size=size.small)

prevRegime := regime
````
