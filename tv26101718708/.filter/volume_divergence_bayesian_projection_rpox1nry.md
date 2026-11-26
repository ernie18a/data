# Volume Divergence & Bayesian Projection 

- url: https://www.tradingview.com/script/rPOx1NRY-Volume-Divergence-Bayesian-Projection/
- type: indicator
- pine_id: PUB;f553b6bf382d4ad6b076027d18a34a82
- version: 1.0

## Description

Volume Divergence & Bayesian Projection
A statistical edge engine for volume-price divergences

Overview
This indicator detects volume divergences — moments when price and volume disagree — and then applies Bayesian inference to answer a question most divergence tools ignore:

"Historically, when this exact signal fired, what actually happened next?"

Rather than just drawing a line and leaving you to guess, it learns from every completed signal on the chart and projects a probability distribution of the forward move — complete with a credible interval, an expected value, and an effective sample size.

What Makes It Different
Most divergence indicators stop at detection. This one closes the loop:

Typical divergence tool	This indicator
Draws a line, labels it "Bull"	Draws a line, labels it, then learns from the outcome
Same logic for every signal	Two independent detection methods feed the engine
No feedback	Bayesian posterior updates with every completed signal
No uncertainty measure	Credible interval + effective sample size shown live
"This looks bullish"	"62% historical hit rate, CI 54–70%, EV +1.8%, ñ=41"
The result is a tool that gets more informative the longer you use it on a given symbol and timeframe.

Detection: Two Complementary Methods
Divergences are found by comparing pivots in price against pivots in a volume oscillator. The script supports two independent approaches, which can run together or separately:

1. Price-Pivot Method
Volume divergence at price swings

Detects when price makes a new high/low but volume fails to confirm. This is the classic exhaustion signal — the move is running out of participation.

2. Oscillator-Pivot Method
Price divergence at volume swings

Detects when volume makes a new extreme but price fails to follow. This is the absorption signal — someone is quietly taking the other side.

These detect genuinely different market phenomena. Running both together gives you the union of signals; running one at a time lets you compare their behavior directly.

Signal Types
Four divergence classes are detected:

Signal	Regular (Reversal)	Hidden (Continuation)
Bullish	Price LL + Volume HL	Price HL + Volume LL
Bearish	Price HH + Volume LH	Price LH + Volume HH
Regular divergences suggest a reversal is near

Hidden divergences suggest the existing trend will continue

All four are tracked and learned from independently.

The Bayesian Engine
This is the core of the indicator. For each of the four signal types, the script maintains:

A Beta-Bernoulli posterior — "Does the signal work?"
Tracks the probability that the expected directional move occurs within N bars

Configurable prior: Uniform, Jeffreys, Skeptical, or fully Custom

Recency decay lets recent outcomes matter more than old ones

Credible interval (via Z-score) shows the uncertainty band around the estimate

A Normal posterior on return magnitude — "How big is the move?"
Tracks the expected forward return with its own prior and shrinkage

Returns are shrunk toward the prior mean, preventing small-sample overconfidence

An empirical return buffer
Stores the last maxSamples returns per signal type

Used to compute Q25/Q75 for the projection box's range

Effective sample size (ñ)
ñ = α + β

Shrinks toward the prior when few observations exist, grows as evidence accumulates

Projections are gated on a minimum ñ, so you never see a projection built on 2 signals

Visualization
Divergence labels & lines
Solid lines connect regular divergence pivots

Dashed lines connect hidden divergences

Dotted lines (optional) connect oscillator-pivot divergences

All label colors, text color, transparency, and size are fully customizable

Projection (last bar only)
When the most recent signal has enough evidence, the script draws:

A shaded box spanning the Q25–Q75 range of past outcomes

A median line showing the expected return

A label with the full statistical readout:

Posterior probability

Credible interval

Expected value

Whether the CI excludes 50% (statistical edge)

Effective sample size

The box's opacity scales with confidence — stronger edges are more visually prominent.

Stats table
A live table showing, for all four signal types:

Posterior mean P

Credible interval

Expected value

Effective sample size

Fully customizable: 9 positions, background color, border color, text size.

Alerts
Four alert conditions, one per signal type:

Bullish Divergence

Bearish Divergence

Hidden Bullish Divergence

Hidden Bearish Divergence

Running the indicator twice (once per detection method) gives you eight independent alerts — one per method per signal type.

Configuration
Group	Controls
Settings	Volume source (Delta or OBV), pivot sensitivity, lookback window
Filters	Minimum price change %, minimum volume change %
Methods	Toggle price-pivot and oscillator-pivot detection independently
Display	Show/hide regular, hidden, lines, oscillator lines; bull/bear colors
Labels	Label background colors, text color, hidden fade, size
Projection	Forward bars, min samples, max stored outcomes
Bayesian	Prior type, prior strength, prior mean, decay, CI Z-score, edge filter
Table	Position, background, border, text size
How to Use It
Add to a chart on your instrument and timeframe

Let it run — the engine learns from every completed signal

Watch the stats table to see which signal types have a real edge on this market

Interpret the projection on the last bar:

High P + tight CI + positive EV = strong signal

Wide CI or low ñ = insufficient evidence, ignore

Optional — split the methods: Add the indicator twice, one method each, to compare price-pivot vs oscillator-pivot performance independently

Honest Limitations
Signals are confirmed, not predictive: Pivots require pivotRight bars to form, so signals appear with a delay of N bars. This is a fact of pivot-based detection, not a bug.

Learning requires history: The Bayesian engine needs completed outcomes to be useful. On a fresh chart, projections are gated until minSamples is reached.

Past statistics do not guarantee future results: The posterior describes what has happened, not what will happen. It is a probabilistic tool, not a crystal ball.

Two detection methods share posteriors by default: If you want method-specific statistics, run two instances of the indicator.

Summary
Volume Divergence & Bayesian Projection is not just another divergence indicator. It is a self-learning statistical framework for evaluating whether volume divergences actually work on the instrument you trade.

It detects. It learns. It quantifies uncertainty. And it tells you, in plain numbers, whether the signal in front of you is worth acting on — or just noise.

For educational and research purposes. Not financial advice. Always validate on your own data before risking capital.

## Source Code

````pine
//@version=6
indicator("Volume Divergence & Bayesian Projection" , "VolDivBayes  ", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 50)

// ── Settings ────────────────────────────────────────────
volSrc      = input.string("Buy/Sell Volume Delta", "Volume Source",
     options = ["Buy/Sell Volume Delta", "OBV"], group = "Settings")
pivotLeft   = input.int(5,  "Pivot Left Bars",  minval = 1, group = "Settings")
pivotRight  = input.int(5,  "Pivot Right Bars", minval = 1, group = "Settings")
divLookback = input.int(60, "Max Bars Between Pivots", minval = 1, group = "Settings")
minPricePct = input.float(0.0, "Min Price Change %", minval = 0.0, step = 0.05, group = "Filters")
minVolPct   = input.float(0.0, "Min Volume Osc Change %", minval = 0.0, step = 0.5, group = "Filters")

usePricePiv = input.bool(true, "Price-pivot method (vol at price swings)", group = "Methods")
useOscPiv   = input.bool(true, "Oscillator-pivot method (price at vol swings)", group = "Methods")

showReg     = input.bool(true, "Show Regular Divergences",    group = "Display")
showHid     = input.bool(true, "Show Hidden (Continuation)", group = "Display")
showLines   = input.bool(true, "Draw Connecting Lines",      group = "Display")
showOscLines= input.bool(true, "Draw Oscillator-Pivot Lines", group = "Display")
colBull     = input.color(color.new(color.green, 0), "Bullish Color", group = "Display")
colBear     = input.color(color.new(color.red,   0), "Bearish Color", group = "Display")

// ── Label appearance ────────────────────────────────────
lblBullBg    = input.color(color.new(color.green, 0), "Label Bull Background", group = "Labels")
lblBearBg    = input.color(color.new(color.red,   0), "Label Bear Background", group = "Labels")
lblTextCol   = input.color(color.white,               "Label Text Color",      group = "Labels")
lblHidFade   = input.int(50, "Hidden Label Fade (0-100)", minval = 0, maxval = 100, group = "Labels")
lblSize      = input.string("Tiny", "Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Labels")

showProj    = input.bool(true, "Show Probability Projection", group = "Projection")
showTable   = input.bool(true, "Show Stats Table",            group = "Projection")
projBars    = input.int(20, "Forward Bars", minval = 1, maxval = 200, group = "Projection")
minSamples  = input.int(5,  "Min Effective Samples To Project", minval = 1, group = "Projection")
maxSamples  = input.int(200, "Max Stored Outcomes", minval = 20, group = "Projection")

priorKind   = input.string("Custom", "Prior",
     options = ["Uniform Beta(1,1)", "Jeffreys Beta(0.5,0.5)", "Skeptical Beta(8,8)", "Custom"],
     group = "Bayesian")
priorP      = input.float(0.50, "Custom Prior P(expected move)", minval = 0.05, maxval = 0.95, step = 0.01, group = "Bayesian")
priorN      = input.float(12.0, "Custom Prior Strength (pseudo-trades)", minval = 0.5, step = 0.5, group = "Bayesian")
priorMu     = input.float(0.0, "Prior Mean Return %", step = 0.05, group = "Bayesian")
priorKappa  = input.float(12.0, "Prior Strength for Mean (pseudo-obs)", minval = 0.5, step = 0.5, group = "Bayesian")
decay       = input.float(1.00, "Recency Decay", minval = 0.80, maxval = 1.00, step = 0.01, group = "Bayesian")
ciZ         = input.float(1.645, "CI Z-score (1.645≈90%, 1.96≈95%)", minval = 1.0, step = 0.005, group = "Bayesian")
onlyIfEdge  = input.bool(false, "Project Only If CI Excludes 50%", group = "Bayesian")

// ── Table appearance ────────────────────────────────────
tblPos      = input.string("Top Right", "Table Position",
     options = ["Top Right", "Top Center", "Top Left",
                "Middle Right", "Middle Center", "Middle Left",
                "Bottom Right", "Bottom Center", "Bottom Left"],
     group = "Table")
tblBg       = input.color(color.new(color.black, 70), "Table Background", group = "Table")
tblBorder   = input.color(color.gray, "Table Border", group = "Table")
tblTextSize = input.string("Small", "Table Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = "Table")

// ── Helpers: position & size mappers ────────────────────
tablePos(string p) =>
    p == "Top Left"      ? position.top_left      : p == "Top Center"    ? position.top_center    : p == "Top Right"     ? position.top_right     :p == "Middle Left"   ? position.middle_left   :   p == "Middle Center" ? position.middle_center : p == "Middle Right"  ? position.middle_right  :p == "Bottom Left"   ? position.bottom_left   : p == "Bottom Center" ? position.bottom_center : position.bottom_right

tableSize(string s) =>
    s == "Tiny"   ? size.tiny   :s == "Small"  ? size.small  :s == "Normal" ? size.normal :s == "Large"  ? size.large  : size.huge

labelSize(string s) =>
    s == "Tiny"   ? size.tiny   : s == "Small"  ? size.small  :s == "Normal" ? size.normal :s == "Large"  ? size.large  : size.huge

// ── Type indices ────────────────────────────────────────
int I_BULL    = 0
int I_BEAR    = 1
int I_HIDBULL = 2
int I_HIDBEAR = 3
int N_TYPES   = 4
string[] TYPE_NAME = array.from("Bull", "Bear", "HidBull", "HidBear")

// ── Volume oscillator ───────────────────────────────────
buyVol   = high == low ? 0.0 : volume * (close - low)  / (high - low)
sellVol  = high == low ? 0.0 : volume * (high - close) / (high - low)
volOsc   = volSrc == "OBV" ? ta.cum(math.sign(ta.change(close)) * volume) : buyVol - sellVol

priceMoved(a, b) =>
    minPricePct <= 0 or (b != 0.0 and math.abs(a - b) / math.abs(b) * 100.0 >= minPricePct)

volMoved(a, b) =>
    minVolPct <= 0 or (b != 0.0 and math.abs(a - b) / math.abs(b) * 100.0 >= minVolPct) or (b == 0.0 and a != b)

inWindow(curBar, prevBar) =>
    not na(prevBar) and curBar > prevBar and (curBar - prevBar) <= divLookback

pctile(array<float> a, float p) =>
    int n = array.size(a)
    float out = na
    if n > 0
        array<float> tmp = array.copy(a)
        array.sort(tmp)
        int idx = int(math.round((n - 1) * p))
        out := array.get(tmp, math.max(0, math.min(n - 1, idx)))
    out

priorAB() =>
    float a = priorP * priorN
    float b = (1.0 - priorP) * priorN
    if priorKind == "Uniform Beta(1,1)"
        a := 1.0
        b := 1.0
    else if priorKind == "Jeffreys Beta(0.5,0.5)"
        a := 0.5
        b := 0.5
    else if priorKind == "Skeptical Beta(8,8)"
        a := 8.0
        b := 8.0
    [a, b]

betaMean(float a, float b) =>
    a + b > 0 ? a / (a + b) : na

betaSd(float a, float b) =>
    float den = (a + b) * (a + b) * (a + b + 1.0)
    den > 0 ? math.sqrt(a * b / den) : na

ciLo(float a, float b) =>
    float m = betaMean(a, b)
    float s = betaSd(a, b)
    na(m) or na(s) ? na : math.max(0.0, m - ciZ * s)

ciHi(float a, float b) =>
    float m = betaMean(a, b)
    float s = betaSd(a, b)
    na(m) or na(s) ? na : math.min(1.0, m + ciZ * s)

hasEdge(float a, float b) =>
    float lo = ciLo(a, b)
    float hi = ciHi(a, b)
    not na(lo) and not na(hi) and (lo > 0.50 or hi < 0.50)

typeId(string t) =>
    t == "Bull" ? I_BULL : t == "Bear" ? I_BEAR : t == "HidBull" ? I_HIDBULL : t == "HidBear" ? I_HIDBEAR : -1

// ── Bayesian arrays & Flat Return Buffers ───────────────
var array<float> alpha = array.from(0.0, 0.0, 0.0, 0.0)
var array<float> beta  = array.from(0.0, 0.0, 0.0, 0.0)
var array<float> mu    = array.from(0.0, 0.0, 0.0, 0.0)
var array<float> kappa = array.from(0.0, 0.0, 0.0, 0.0)

var array<float> rets_bull    = array.new<float>()
var array<float> rets_bear    = array.new<float>()
var array<float> rets_hidbull = array.new<float>()
var array<float> rets_hidbear = array.new<float>()

get_rets_array(int idx) =>
    idx == I_BULL    ? rets_bull :  idx == I_BEAR    ? rets_bear :  idx == I_HIDBULL ? rets_hidbull : rets_hidbear

pushCap(array<float> a, float v) =>
    array.push(a, v)
    if array.size(a) > maxSamples
        array.shift(a)

observe(int idx, float ret, bool success) =>
    if idx >= 0 and idx < N_TYPES
        pushCap(get_rets_array(idx), ret)
        float a = array.get(alpha, idx)
        float b = array.get(beta, idx)
        array.set(alpha, idx, math.max(a * decay + (success ? 1.0 : 0.0), 1e-6))
        array.set(beta,  idx, math.max(b * decay + (success ? 0.0 : 1.0), 1e-6))
        float m = array.get(mu, idx)
        float k = array.get(kappa, idx)
        float k2 = k * decay + 1.0
        array.set(mu, idx, (k * decay * m + ret) / k2)
        array.set(kappa, idx, k2)

[pA0, pB0] = priorAB()
if barstate.isfirst
    for i = 0 to N_TYPES - 1
        array.set(alpha, i, pA0)
        array.set(beta,  i, pB0)
        array.set(mu,    i, priorMu)
        array.set(kappa, i, priorKappa)

fmtRow(int idx) =>
    float a = array.get(alpha, idx)
    float b = array.get(beta, idx)
    str.format("{0,number,#.#}%  [{1,number,#.#}–{2,number,#.#}]  EV {3,number,+#.##}%  ñ={4,number,#.#}",
         betaMean(a, b) * 100.0, ciLo(a, b) * 100.0, ciHi(a, b) * 100.0, array.get(mu, idx), a + b)

// ── Pivots ──────────────────────────────────────────────
ph  = ta.pivothigh(high,   pivotLeft, pivotRight)
pl  = ta.pivotlow(low,     pivotLeft, pivotRight)
vph = ta.pivothigh(volOsc, pivotLeft, pivotRight)
vpl = ta.pivotlow(volOsc,  pivotLeft, pivotRight)

pivotBar        = bar_index - pivotRight
volAtPricePivot = volOsc[pivotRight]
hiAtPivot       = high[pivotRight]
loAtPivot       = low[pivotRight]

var float prevPH = na
var int   prevPHBar = na
var float prevVolPH = na
var float prevPL = na
var int   prevPLBar = na
var float prevVolPL = na
var float prevVPH = na
var int   prevVPHBar = na
var float prevHiAtVPH = na
var float prevVPL = na
var int   prevVPLBar = na
var float prevLoAtVPL = na

bullDiv = false
bearDiv = false
hidBull = false
hidBear = false
oscBullDiv = false
oscBearDiv = false
oscHidBull = false
oscHidBear = false

if usePricePiv and not na(ph) and not na(prevPH) and not na(prevVolPH) and inWindow(pivotBar, prevPHBar)
    if priceMoved(ph, prevPH) and volMoved(volAtPricePivot, prevVolPH)
        if ph > prevPH and volAtPricePivot < prevVolPH
            bearDiv := true
        if ph < prevPH and volAtPricePivot > prevVolPH
            hidBear := true

if usePricePiv and not na(pl) and not na(prevPL) and not na(prevVolPL) and inWindow(pivotBar, prevPLBar)
    if priceMoved(pl, prevPL) and volMoved(volAtPricePivot, prevVolPL)
        if pl < prevPL and volAtPricePivot > prevVolPL
            bullDiv := true
        if pl > prevPL and volAtPricePivot < prevVolPL
            hidBull := true

if useOscPiv and not na(vph) and not na(prevVPH) and not na(prevHiAtVPH) and inWindow(pivotBar, prevVPHBar)
    if priceMoved(hiAtPivot, prevHiAtVPH) and volMoved(vph, prevVPH)
        if hiAtPivot > prevHiAtVPH and vph < prevVPH
            oscBearDiv := true
        if hiAtPivot < prevHiAtVPH and vph > prevVPH
            oscHidBear := true

if useOscPiv and not na(vpl) and not na(prevVPL) and not na(prevLoAtVPL) and inWindow(pivotBar, prevVPLBar)
    if priceMoved(loAtPivot, prevLoAtVPL) and volMoved(vpl, prevVPL)
        if loAtPivot < prevLoAtVPL and vpl > prevVPL
            oscBullDiv := true
        if loAtPivot > prevLoAtVPL and vpl < prevVPL
            oscHidBull := true

if not na(ph)
    if usePricePiv
        if showLines and showReg and bearDiv and not na(prevPHBar)
            line.new(prevPHBar, prevPH, pivotBar, ph, color = colBear, width = 2)
        if showLines and showHid and hidBear and not na(prevPHBar)
            line.new(prevPHBar, prevPH, pivotBar, ph, color = color.new(colBear, 30), width = 2, style = line.style_dashed)
        if showReg and bearDiv
            label.new(pivotBar, ph, "Bear Div", style = label.style_label_down,
                 color = lblBearBg, textcolor = lblTextCol, size = labelSize(lblSize))
        if showHid and hidBear
            label.new(pivotBar, ph, "Hid Bear", style = label.style_label_down,
                 color = color.new(lblBearBg, lblHidFade), textcolor = lblTextCol, size = labelSize(lblSize))
    prevPH    := ph
    prevPHBar := pivotBar
    prevVolPH := volAtPricePivot

if not na(pl)
    if usePricePiv
        if showLines and showReg and bullDiv and not na(prevPLBar)
            line.new(prevPLBar, prevPL, pivotBar, pl, color = colBull, width = 2)
        if showLines and showHid and hidBull and not na(prevPLBar)
            line.new(prevPLBar, prevPL, pivotBar, pl, color = color.new(colBull, 30), width = 2, style = line.style_dashed)
        if showReg and bullDiv
            label.new(pivotBar, pl, "Bull Div", style = label.style_label_up,
                 color = lblBullBg, textcolor = lblTextCol, size = labelSize(lblSize))
        if showHid and hidBull
            label.new(pivotBar, pl, "Hid Bull", style = label.style_label_up,
                 color = color.new(lblBullBg, lblHidFade), textcolor = lblTextCol, size = labelSize(lblSize))
    prevPL    := pl
    prevPLBar := pivotBar
    prevVolPL := volAtPricePivot

if not na(vph)
    if useOscPiv
        if showLines and showOscLines and showReg and oscBearDiv and not na(prevVPHBar)
            line.new(prevVPHBar, prevHiAtVPH, pivotBar, hiAtPivot, color = colBear, width = 2, style = line.style_dotted)
        if showLines and showOscLines and showHid and oscHidBear and not na(prevVPHBar)
            line.new(prevVPHBar, prevHiAtVPH, pivotBar, hiAtPivot, color = color.new(colBear, 30), width = 2, style = line.style_dotted)
        if showReg and oscBearDiv
            label.new(pivotBar, hiAtPivot, "Osc Bear", style = label.style_label_down,
                 color = lblBearBg, textcolor = lblTextCol, size = labelSize(lblSize))
        if showHid and oscHidBear
            label.new(pivotBar, hiAtPivot, "Osc Hid Bear", style = label.style_label_down,
                 color = color.new(lblBearBg, lblHidFade), textcolor = lblTextCol, size = labelSize(lblSize))
    prevVPH     := vph
    prevVPHBar  := pivotBar
    prevHiAtVPH := hiAtPivot

if not na(vpl)
    if useOscPiv
        if showLines and showOscLines and showReg and oscBullDiv and not na(prevVPLBar)
            line.new(prevVPLBar, prevLoAtVPL, pivotBar, loAtPivot, color = colBull, width = 2, style = line.style_dotted)
        if showLines and showOscLines and showHid and oscHidBull and not na(prevVPLBar)
            line.new(prevVPLBar, prevLoAtVPL, pivotBar, loAtPivot, color = color.new(colBull, 30), width = 2, style = line.style_dotted)
        if showReg and oscBullDiv
            label.new(pivotBar, loAtPivot, "Osc Bull", style = label.style_label_up,
                 color = lblBullBg, textcolor = lblTextCol, size = labelSize(lblSize))
        if showHid and oscHidBull
            label.new(pivotBar, loAtPivot, "Osc Hid Bull", style = label.style_label_up,
                 color = color.new(lblBullBg, lblHidFade), textcolor = lblTextCol, size = labelSize(lblSize))
    prevVPL     := vpl
    prevVPLBar  := pivotBar
    prevLoAtVPL := loAtPivot

bullLike    = showReg and (bullDiv or oscBullDiv)
bearLike    = showReg and (bearDiv or oscBearDiv)
hidBullLike = showHid and (hidBull or oscHidBull)
hidBearLike = showHid and (hidBear or oscHidBear)

var string lastType  = na
var int    lastBar   = na
var float  lastPrice = na
if bearLike
    lastType := "Bear"
    lastBar := bar_index
    lastPrice := close
else if bullLike
    lastType := "Bull"
    lastBar := bar_index
    lastPrice := close
else if hidBearLike
    lastType := "HidBear"
    lastBar := bar_index
    lastPrice := close
else if hidBullLike
    lastType := "HidBull"
    lastBar := bar_index
    lastPrice := close

// ── Record completed outcomes ───────────────────────────
float fwdRet = close[projBars] == 0 ? na : (close - close[projBars]) / close[projBars] * 100.0
if not na(fwdRet)
    if showReg and (bullDiv[projBars] or oscBullDiv[projBars])
        observe(I_BULL, fwdRet, fwdRet > 0)
    if showReg and (bearDiv[projBars] or oscBearDiv[projBars])
        observe(I_BEAR, fwdRet, fwdRet < 0)
    if showHid and (hidBull[projBars] or oscHidBull[projBars])
        observe(I_HIDBULL, fwdRet, fwdRet > 0)
    if showHid and (hidBear[projBars] or oscHidBear[projBars])
        observe(I_HIDBEAR, fwdRet, fwdRet < 0)

var line  projMid = na
var line  projHi  = na
var line  projLo  = na
var box   projBox = na
var label projLbl = na
var table statTbl = na

if barstate.islast
    int idx = typeId(lastType)
    if not na(projMid)
        line.delete(projMid)
    if not na(projHi)
        line.delete(projHi)
    if not na(projLo)
        line.delete(projLo)
    if not na(projBox)
        box.delete(projBox)
    if not na(projLbl)
        label.delete(projLbl)

    if showProj and idx >= 0 and not na(lastBar) and not na(lastPrice)
        float a    = array.get(alpha, idx)
        float b    = array.get(beta, idx)
        float ev   = array.get(mu, idx)
        float nEff = a + b
        float pHat = betaMean(a, b)
        bool wantUp = idx == I_BULL or idx == I_HIDBULL
        bool edgeOk = not onlyIfEdge or hasEdge(a, b)
        if nEff >= minSamples + (pA0 + pB0) * 0.25 and edgeOk and not na(ev)
            array<float> hist = get_rets_array(idx)
            float q25 = pctile(hist, 0.25)
            float q75 = pctile(hist, 0.75)
            int x2 = lastBar + projBars
            float yMed = lastPrice * (1.0 + ev / 100.0)
            float yLo  = lastPrice * (1.0 + (na(q25) ? ev : q25) / 100.0)
            float yHi  = lastPrice * (1.0 + (na(q75) ? ev : q75) / 100.0)
            color base = wantUp ? colBull : colBear
            float fade = na(pHat) ? 85.0 : 85.0 - 25.0 * math.abs(pHat - 0.5) * 2.0
            projBox := box.new(lastBar, yHi, x2, yLo, bgcolor = color.new(base, fade), border_color = color.new(base, 55), border_width = 1)
            projHi  := line.new(lastBar, lastPrice, x2, yHi, color = color.new(base, 50), width = 1, style = line.style_dotted)
            projLo  := line.new(lastBar, lastPrice, x2, yLo, color = color.new(base, 50), width = 1, style = line.style_dotted)
            projMid := line.new(lastBar, lastPrice, x2, yMed, color = base, width = 2)
            projLbl := label.new(x2, yMed,
                 str.format("{0}  Bayes\nP({1}) {2,number,#.#}%\nCI {3,number,#.#}–{4,number,#.#}%\nEV {5,number,+#.##}%  {6}\nñ={7,number,#.#}",
                      lastType, wantUp ? "up" : "down", pHat * 100.0, ciLo(a, b) * 100.0, ciHi(a, b) * 100.0, ev, hasEdge(a, b) ? "CI edge" : "weak", nEff),
                 style = label.style_label_left, color = base, textcolor = color.white, size = size.normal)

    if showTable
        if na(statTbl)
            statTbl := table.new(tablePos(tblPos), 2, 6,
                 bgcolor      = tblBg,
                 border_width = 1,
                 border_color = tblBorder)
        sz = tableSize(tblTextSize)
        table.cell(statTbl, 0, 0, "Bayes / " + str.tostring(projBars) + "b",
             text_color = color.white, text_size = sz)
        table.cell(statTbl, 1, 0,
             str.format("prior {0,number,#.#}%  n0={1,number,#.#}",
                  betaMean(pA0, pB0) * 100.0, pA0 + pB0),
             text_color = color.white, text_size = sz)
        table.cell(statTbl, 0, 1, "Bull", text_color = colBull, text_size = sz)
        table.cell(statTbl, 1, 1, fmtRow(I_BULL), text_color = color.white, text_size = sz)
        table.cell(statTbl, 0, 2, "Bear", text_color = colBear, text_size = sz)
        table.cell(statTbl, 1, 2, fmtRow(I_BEAR), text_color = color.white, text_size = sz)
        table.cell(statTbl, 0, 3, "Hid Bull", text_color = colBull, text_size = sz)
        table.cell(statTbl, 1, 3, fmtRow(I_HIDBULL), text_color = color.white, text_size = sz)
        table.cell(statTbl, 0, 4, "Hid Bear", text_color = colBear, text_size = sz)
        table.cell(statTbl, 1, 4, fmtRow(I_HIDBEAR), text_color = color.white, text_size = sz)
        table.cell(statTbl, 0, 5, "Read", text_color = color.white, text_size = sz)
        table.cell(statTbl, 1, 5,
             "P=posterior mean  CI=normal-approx  EV=shrunk return  ñ=α+β",
             text_color = color.white, text_size = sz)

alertcondition(bullDiv or oscBullDiv, "Bullish Divergence", "Bullish volume divergence")
alertcondition(bearDiv or oscBearDiv, "Bearish Divergence", "Bearish volume divergence")
alertcondition(hidBull or oscHidBull, "Hidden Bullish Divergence", "Hidden bullish volume divergence")
alertcondition(hidBear or oscHidBear, "Hidden Bearish Divergence", "Hidden bearish volume divergence")
````
