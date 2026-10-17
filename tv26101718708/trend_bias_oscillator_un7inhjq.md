# Trend Bias Oscillator

- url: https://www.tradingview.com/script/Un7inhjq-Trend-Bias-Oscillator/
- type: indicator
- pine_id: PUB;9e3dfa2bdb8740f38e42eec55d700446
- version: 2.0

## Description

**Trend Bias Oscillator (TBO)**

---

The Trend Bias Oscillator tracks where price sits within its current trend — not just whether it's bullish or bearish, but *how far along* it is within that move. It normalizes that position to a clean ±100 scale, so readings are consistent across any instrument or timeframe.

When the market is in a bullish structure, the oscillator rises toward +100 as price pushes toward the top of the established range, and pulls back toward zero on retracements. When structure is bearish, it falls toward -100 as price drops, and recovers toward zero on bounces. If price breaks beyond the known range entirely, the oscillator pins at ±100 — a sign of extension.

Structure shifts when price closes decisively above a prior swing high (bullish flip) or below a prior swing low (bearish flip). Once flipped, the bias holds until the opposite level is broken — so the oscillator stays on one side of zero for the entire duration of a trend, not just the bar the signal fired on.

The optional signal line smooths the raw oscillator, making it easier to spot when momentum is building or fading within the current bias. A widening gap between the histogram and signal line suggests continuation. Compression back toward the line suggests a pause or potential reversal ahead.

---

**What makes TBO different**

Most oscillators measure momentum or price position in isolation — they have no awareness of whether the market is in a defined trend or not. RSI, Stochastic, and similar tools will oscillate freely regardless of structure, which means a reading of 70 looks the same in a strong uptrend as it does in the middle of a range.

TBO is different because the oscillator only activates and measures depth *after* a confirmed structural break. Until price breaks a prior swing high or low with a closed bar, the oscillator stays at zero — explicitly signaling that no defined bias exists. Once a break is confirmed, TBO then continuously measures how deep price has traveled into that trend, using the opposing swing level as its reference point rather than an arbitrary lookback window or moving average.

This means TBO doesn't just tell you which direction the market is leaning — it tells you *how committed* it is to that direction at any given moment. A reading compressing back toward zero during an uptrend is a retracement warning. A reading pushing toward +100 is trend continuation. The context is structural, not statistical.

There are indicators on TradingView that normalize price within a range, and others that detect market structure breaks. TBO combines both into a single, continuously updated reading — making it a genuinely different tool rather than a variation on existing oscillator formulas.

---

**Inputs**

**Bars Left** *(default: 20)*
How many bars to the left define a swing point. Higher values find bigger, more meaningful swings. Lower values are more sensitive and react faster.

**Bars Right** *(default: 5)*
How many bars to the right are needed before a swing is confirmed. Lower values confirm faster but can be noisier. This setting also controls how much lag the indicator has — a value of 5 means pivots confirm 5 bars after they form.

**Non-Repaint Mode** *(default: on)*
Ensures structure bias can only flip on a fully closed bar — a signal triggered intrabar will never fire and then disappear before the candle closes. The oscillator value itself will still update in real time as price moves within the current bar, which is normal and expected. What non-repaint protects is the structural flip — that moment when bias switches from bullish to bearish or vice versa. Turning this off allows real-time bias changes but signals may repaint on unclosed candles.

**Show Signal Line** *(default: on)*
Toggles the smoothed line over the histogram on or off.

**Signal Type** *(default: EMA)*
The smoothing method used for the signal line. EMA reacts fastest, SMA is straightforward, WMA weights recent bars more heavily, and RMA (Wilder's) is the smoothest and slowest. Personal preference — try EMA or RMA first.

**Signal Length** *(default: 5)*
How many bars the signal line looks back over. Shorter values follow the oscillator closely. Longer values produce a smoother line that only moves on sustained shifts.

**Signal Color** *(default: blue)*
The color of the signal line, adjustable via the color picker.

**Signal Line Width** *(default: 1)*
The thickness of the signal line. Ranges from 1 to 4.

---

**Reference Lines**

| Level | What it means |
|---|---|
| +100 | Price fully extended in bullish structure |
| +50 | Price in the upper half of the bullish range |
| 0 | No bias established, or structural midpoint |
| -50 | Price in the lower half of the bearish range |
| -100 | Price fully extended in bearish structure |

---

**A few things worth knowing**

Swing pivots confirm with a small natural delay — this is intentional and keeps the indicator from repainting. On very choppy or ranging markets, structure will flip frequently and the oscillator will hover near zero. This is the indicator working as designed, not a malfunction — it simply means no clean trend structure exists at that time. Stepping up to a higher timeframe usually clarifies the picture.

The oscillator value moving on the live bar is normal behavior and not repainting. Non-Repaint Mode specifically prevents structure bias from flipping until a bar fully closes, ensuring signals are never triggered and then taken back within the same candle.

## Source Code

````pine
//@version=6
indicator("Trend Bias Oscillator", overlay=false, max_bars_back=1000)

// ══════════════════════════════════════════════════════════════════════════════
// TREND BIAS OSCILLATOR  |  Architecture: Structural Amortization
//
// L1 — Break Magnitude Scoring  : every BoS is weighted by how far price
//                                  broke past the pivot, normalized to ATR.
//                                  Not a binary event — conviction matters.
//
// L2 — Structural Credit + Decay: credit accumulates on each BoS and decays
//                                  exponentially every bar with no new structure.
//                                  A trend coasting on old breaks bleeds to zero.
//
// L3 — Structural Slope         : rate of change of net credit becomes the
//                                  oscillator. Measures whether the trend is
//                                  being actively confirmed or amortizing.
//
// Five output states:
//   LONG        — osc high and rising    (trend compounding new structure)
//   HOLD LONG   — osc high and falling   (trend present but not confirming)
//   STAND ASIDE — osc near zero          (no structural bias)
//   HOLD SHORT  — osc low and rising     (bearish selling steam running out)
//   SHORT       — osc low and falling    (structure actively collapsing)
// ══════════════════════════════════════════════════════════════════════════════


// ── Constants ─────────────────────────────────────────────────────────────────
const float THRESHOLD = 25.0
const color ORANGE    = color.new(#FF9800, 0)


// ── Pivot inputs ──────────────────────────────────────────────────────────────
leftBars   = input.int(13,    "Bars Left",         minval=3,   maxval=200, group="Pivot Settings")
rightBars  = input.int(5,     "Bars Right",        minval=1,   maxval=100, group="Pivot Settings")
nonRepaint = input.bool(true, "Non-Repaint Mode",                          group="Pivot Settings",
    tooltip="When enabled, signals only fire on confirmed (closed) bars")


// ── L1 inputs ─────────────────────────────────────────────────────────────────
atrLength  = input.int(14,    "ATR Length",        minval=1,   maxval=100, group="L1  Break Magnitude")
maxMagCap  = input.float(3.0, "Magnitude Cap (ATR multiples)", minval=0.5, maxval=10.0, step=0.5,
    group="L1  Break Magnitude",
    tooltip="Break distances above this ATR multiple are capped. Prevents outlier candles from dominating the score.")


// ── L2 inputs ─────────────────────────────────────────────────────────────────
decayRate  = input.float(0.8, "Decay Rate (per bar)", minval=0.50, maxval=0.99, step=0.01,
    group="L2  Credit and Decay",
    tooltip="Rate at which structural credit fades each bar when no new BoS fires. 0.94 = ~12 bar half-life.")
creditCap  = input.float(5.0,  "Credit Cap",           minval=1.0,  maxval=20.0,  step=0.5,
    group="L2  Credit and Decay",
    tooltip="Maximum accumulated credit in either direction. Prevents runaway scores in strong sustained trends.")


// ── L3 inputs ─────────────────────────────────────────────────────────────────
slopeLen   = input.int(10, "Slope Lookback (bars)", minval=2, maxval=50,
    group="L3  Structural Slope",
    tooltip="Rate-of-change window applied to net credit. Shorter = more reactive. Longer = smoother.")
normWindow = input.int(50, "Normalization Window",  minval=10, maxval=200,
    group="L3  Structural Slope",
    tooltip="Rolling window for min/max normalization to -100 / +100. Larger = more stable scale.")


// ── Signal line ───────────────────────────────────────────────────────────────
showSig  = input.bool(true,    "Show Signal Line",                        group="Signal Line")
sigType  = input.string("EMA", "Type", options=["EMA","SMA","WMA","RMA"], group="Signal Line")
sigLen   = input.int(5,        "Length", minval=1, maxval=50,             group="Signal Line")
sigCol   = input.color(color.new(color.blue,  0),  "Color",               group="Signal Line")
sigWidth = input.int(1,        "Width",  minval=1, maxval=4,              group="Signal Line")


// ── Display ───────────────────────────────────────────────────────────────────
showState  = input.bool(true,  "Show State Label",     group="Display")
showBg     = input.bool(true,  "Show Background Tint", group="Display")
labelBgCol = input.color(color.new(color.gray, 75), "Label Background", group="Display")
labelTxCol = input.color(color.blue,               "Label Text",       group="Display")


// ══════════════════════════════════════════════════════════════════════════════
// L1 — BREAK MAGNITUDE SCORING
// ══════════════════════════════════════════════════════════════════════════════

swingHigh = ta.pivothigh(high, leftBars, rightBars)
swingLow  = ta.pivotlow(low,  leftBars, rightBars)

var float lastHigh = na
var float lastLow  = na

if not na(swingHigh)
    lastHigh := swingHigh
if not na(swingLow)
    lastLow := swingLow

atrVal    = ta.atr(atrLength)
confirmed = nonRepaint ? barstate.isconfirmed : true

// Distance price moved beyond the pivot on the break bar
bullDist = not na(lastHigh) and close > lastHigh and close[1] <= lastHigh ? close - lastHigh : 0.0
bearDist = not na(lastLow)  and close < lastLow  and close[1] >= lastLow  ? lastLow - close  : 0.0

// Normalize to ATR, cap at maxMagCap — result range 0.0 to 1.0
bullMag = confirmed and atrVal > 0 ? math.min(bullDist / (atrVal * maxMagCap), 1.0) : 0.0
bearMag = confirmed and atrVal > 0 ? math.min(bearDist / (atrVal * maxMagCap), 1.0) : 0.0

isBullBreak = bullMag > 0
isBearBreak = bearMag > 0


// ══════════════════════════════════════════════════════════════════════════════
// L2 — STRUCTURAL CREDIT WITH EXPONENTIAL DECAY
// ══════════════════════════════════════════════════════════════════════════════

var float bullCredit = 0.0
var float bearCredit = 0.0

// Step 1: decay both sides every bar
bullCredit := bullCredit * decayRate
bearCredit := bearCredit * decayRate

// Step 2: add magnitude on confirmed breaks; opposing credit takes a 50% haircut
if isBullBreak
    bullCredit := math.min(bullCredit + bullMag, creditCap)
    bearCredit := bearCredit * 0.5

if isBearBreak
    bearCredit := math.min(bearCredit + bearMag, creditCap)
    bullCredit := bullCredit * 0.5

// Positive = bullish structural bias, negative = bearish
netCredit = bullCredit - bearCredit


// ══════════════════════════════════════════════════════════════════════════════
// L3 — STRUCTURAL SLOPE
// ══════════════════════════════════════════════════════════════════════════════

rawSlope   = netCredit - nz(netCredit[slopeLen])
hiSlope    = ta.highest(rawSlope, normWindow)
loSlope    = ta.lowest(rawSlope,  normWindow)
slopeRange = hiSlope - loSlope
osc        = slopeRange > 0 ? (rawSlope - loSlope) / slopeRange * 200.0 - 100.0 : 0.0


// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL LINE
// ══════════════════════════════════════════════════════════════════════════════

sigLine = switch sigType
    "EMA" => ta.ema(osc, sigLen)
    "SMA" => ta.sma(osc, sigLen)
    "WMA" => ta.wma(osc, sigLen)
    "RMA" => ta.rma(osc, sigLen)
    =>       ta.ema(osc, sigLen)


// ══════════════════════════════════════════════════════════════════════════════
// STATE CLASSIFICATION
// ══════════════════════════════════════════════════════════════════════════════

isBuilding   = osc >  THRESHOLD and osc >  osc[2]
isCoasting   = osc >  THRESHOLD and osc <= osc[2]
isVacuum     = math.abs(osc) <= THRESHOLD
isRecovering = osc < -THRESHOLD and osc >= osc[2]
isBreakdown  = osc < -THRESHOLD and osc <  osc[2]

// Integer encoding for data window / external use
// 2=building  1=coasting  0=vacuum  -1=recovering  -2=breakdown
stateInt = isBuilding ? 2 : isCoasting ? 1 : isVacuum ? 0 : isRecovering ? -1 : -2


// ══════════════════════════════════════════════════════════════════════════════
// COLORS
// ══════════════════════════════════════════════════════════════════════════════

var color histColor = na
if isBuilding
    histColor := color.new(color.lime,  10)
else if isCoasting
    histColor := color.new(color.green, 45)
else if isVacuum
    histColor := color.new(color.gray,  60)
else if isRecovering
    histColor := color.new(ORANGE,      45)
else
    histColor := color.new(color.red,   10)

var color bgTint = na
if isBuilding
    bgTint := color.new(color.lime, 93)
else if isBreakdown
    bgTint := color.new(color.red,  93)
else
    bgTint := na


// ══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════════════

plot(osc,
    title     = "TBO",
    style     = plot.style_histogram,
    color     = histColor,
    linewidth = 4)

plot(showSig ? sigLine : na,
    title     = "Signal",
    color     = sigCol,
    linewidth = sigWidth)

hline(0,   "Zero",    color=color.new(color.gray,  30), linestyle=hline.style_solid)
hline(25,  "+Bias",   color=color.new(color.green, 55), linestyle=hline.style_dashed)
hline(-25, "-Bias",   color=color.new(color.red,   55), linestyle=hline.style_dashed)
hline(75,  "+Strong", color=color.new(color.lime,  40), linestyle=hline.style_dotted)
hline(-75, "-Strong", color=color.new(color.red,   30), linestyle=hline.style_dotted)

bgcolor(showBg ? bgTint : na, title="State Background")


// ══════════════════════════════════════════════════════════════════════════════
// STATE LABEL
// ══════════════════════════════════════════════════════════════════════════════

var label stateLbl = na
label.delete(stateLbl)

if showState
    var string txt = ""
    var color  clr = na

    if isBuilding
        txt := "LONG"
        clr := color.lime
    else if isCoasting
        txt := "HOLD LONG"
        clr := color.green
    else if isVacuum
        txt := "STAND ASIDE"
        clr := color.gray
    else if isRecovering
        txt := "HOLD SHORT"
        clr := ORANGE
    else
        txt := "SHORT"
        clr := color.red

    stateLbl := label.new(bar_index + 2, 0,
        text      = txt,
        style     = label.style_label_left,
        color     = labelBgCol,
        textcolor = labelTxCol,
        size      = size.small)


// ══════════════════════════════════════════════════════════════════════════════
// DATA WINDOW  (external access for strategies and other indicators)
// ══════════════════════════════════════════════════════════════════════════════

plot(netCredit, title="Net Credit", display=display.data_window)
plot(rawSlope,  title="Raw Slope",  display=display.data_window)
plot(stateInt,  title="State Int",  display=display.data_window)


// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(isBuilding   and not isBuilding[1],
    title="TBO: Long",        message="TBO: LONG - trend actively building new structure")
alertcondition(isCoasting   and not isCoasting[1],
    title="TBO: Hold Long",   message="TBO: HOLD LONG - trend present but no new structure confirming")
alertcondition(isBreakdown  and not isBreakdown[1],
    title="TBO: Short",       message="TBO: SHORT - structure breakdown in progress")
alertcondition(isRecovering and not isRecovering[1],
    title="TBO: Hold Short",  message="TBO: HOLD SHORT - bearish momentum fading")
alertcondition(isVacuum     and not isVacuum[1],
    title="TBO: Stand Aside", message="TBO: STAND ASIDE - no structural bias")
alertcondition(osc > 0 and osc[1] <= 0,
    title="TBO: Zero Cross Up",   message="TBO: Oscillator crossed above zero")
alertcondition(osc < 0 and osc[1] >= 0,
    title="TBO: Zero Cross Down", message="TBO: Oscillator crossed below zero")
````
