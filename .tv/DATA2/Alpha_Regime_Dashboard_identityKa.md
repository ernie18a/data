<!-- tradingview-pine-id: PUB;3e1c342ec04d4dc7a7c03cc6e9db7ad6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Alpha Regime Dashboard [identityKa]

Source: https://www.tradingview.com/script/srb2nU0A/

## Description

Alpha Regime Dashboard [identityKa]

**One question, answered clearly: is this market trending, choppy, or somewhere in between?**

Most trading mistakes are not bad entries. They are good entries taken in the wrong regime: a trend-following idea in a range, or a mean-reversion idea in a strong trend. This tool classifies the current regime so you can match your approach to the environment before you place a trade.

How it works

The score blends three independent measures of "trendiness":

1. **Efficiency Ratio (40%)**: net price change divided by the total distance price travelled over the lookback. Close to 1 means price moved in a straight line; close to 0 means it went nowhere despite lots of movement.
2. **ADX (30%)**: classic directional strength.
3. **EMA slope in ATR units (30%)**: how fast the trend EMA is moving, normalized by volatility so it is comparable across symbols.

Each component is then converted into a **percentile rank of its own recent history** (default 250 bars). This is the key idea: a "high ADX" on a slow index and a "high ADX" on a volatile altcoin mean very different things in raw numbers, but they are both "high relative to that market's own behavior". Because of this, the same thresholds work across crypto, stocks, indices and FX without manual tuning.

The blended score (0 to 100) is smoothed and passed through a **confirmation filter**: a new regime is only accepted after it persists for a set number of bars, which removes most of the flicker you see in raw threshold indicators.

Regimes

- **Trending Up / Trending Down**: score at or above the Trending threshold, with direction from EMA slope and price position
- **Transition**: between thresholds, the market is deciding
- **Choppy**: score at or below the Choppy threshold, movement without progress

What you see

- A pane with the regime score, colored by state
- A dashboard with State, Score, Regime Age (bars in the current regime), Efficiency Ratio, ADX, Slope and Directional Bias, each with its percentile rank
- Optional component rank lines to see which measure is driving the reading

How to use it

- Use it as a **context filter**, not a signal generator. Trend-following setups tend to make more sense in Trending regimes; mean-reversion setups tend to make more sense in Choppy regimes.
- Watch **Regime Age**: very young regimes are less reliable than established ones.
- Compare timeframes. A Trending regime on 4H inside a Choppy regime on 15m is a different situation from full alignment.

Settings

- **Calculation**: Efficiency Ratio length, ADX length, trend EMA length, slope lookback, adaptive rank window, score smoothing
- **Regime Rules**: Trending and Choppy thresholds, confirmation bars
- **Display / Dashboard**: colors, position, text size, footer toggle

Alerts

Alerts are available for Trending Up, Trending Down, Choppy, Transition and any regime change. For stable, non-repainting triggers, set the alert to **Once Per Bar Close**.

Notes and limitations

- Percentile ranking needs history. The first bars (equal to the rank window) show "Warming up".
- Regime classification describes what has been happening, not what will happen next. Regimes change.
- Values on the current, unfinished bar can change until the bar closes.

*This script is for educational and informational purposes only and is not financial advice. Past behavior does not guarantee future results.*

Part of the **Alpha Quant Toolkit** by identityKa: a series of free, open-source market analysis tools built on a common design standard.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IdentityKa
//
// Alpha Quant Toolkit · #01 Regime Dashboard
// Classifies the market into Trending / Transition / Choppy using three independent measures
// (Efficiency Ratio, ADX, ATR-normalised EMA slope), each converted to a percentile rank of
// its OWN history so the same thresholds work on crypto, stocks, FX and indices.

//@version=6
indicator("Alpha Regime Dashboard [identityKa]", shorttitle="AQ Regime", overlay=false, precision=1)

// ═══════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════
const string GRP_CALC = "Calculation"
const string GRP_REG  = "Regime Rules"
const string GRP_VIS  = "Display"
const string GRP_DASH = "Dashboard"
const string BRAND    = "Alpha Quant Toolkit · identityKa"

const float W_ER    = 0.40
const float W_ADX   = 0.30
const float W_SLOPE = 0.30

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
lenER     = input.int(20,  "Efficiency Ratio Length", minval=5, group=GRP_CALC,
     tooltip="Lookback for Kaufman's Efficiency Ratio: net price change divided by total path travelled.")
lenADX    = input.int(14,  "ADX Length", minval=5, group=GRP_CALC)
lenEMA    = input.int(50,  "Trend EMA Length", minval=10, group=GRP_CALC)
lenSlope  = input.int(10,  "Slope Lookback (bars)", minval=2, group=GRP_CALC,
     tooltip="Number of bars used to measure the EMA slope in ATR units.")
rankLen   = input.int(250, "Adaptive Rank Window", minval=50, maxval=1000, group=GRP_CALC,
     tooltip="Each component is ranked against its own last N bars (percentile). Longer window = slower, more stable regime reading.")
smoothLen = input.int(3,   "Score Smoothing", minval=1, maxval=10, group=GRP_CALC)

trendThr  = input.float(65, "Trending Threshold", minval=50, maxval=95, step=1, group=GRP_REG,
     tooltip="Score at or above this level = Trending.")
chopThr   = input.float(35, "Choppy Threshold", minval=5, maxval=50, step=1, group=GRP_REG,
     tooltip="Score at or below this level = Choppy.")
confirmN  = input.int(3, "Confirmation Bars", minval=1, maxval=10, group=GRP_REG,
     tooltip="A new regime must persist for this many consecutive bars before it is accepted. Reduces flicker.")

cUp     = input.color(#19D3A2, "Trending Up",   group=GRP_VIS, inline="c1")
cDn     = input.color(#FF4D6A, "Trending Down", group=GRP_VIS, inline="c1")
cChop   = input.color(#8A94A6, "Choppy",        group=GRP_VIS, inline="c2")
cTrans  = input.color(#FFB020, "Transition",    group=GRP_VIS, inline="c2")
showComp = input.bool(false, "Show component ranks", group=GRP_VIS)

showTable = input.bool(true, "Show Dashboard", group=GRP_DASH)
posInput  = input.string("Top Right", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=GRP_DASH)
sizeInput = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=GRP_DASH)
showBrand = input.bool(true, "Show footer", group=GRP_DASH)

// ═══════════════════════════════════════════════════════════════
//  CALCULATION
// ═══════════════════════════════════════════════════════════════
// 1) Efficiency Ratio (0..1)
erNum = math.abs(close - close[lenER])
erDen = math.sum(math.abs(close - close[1]), lenER)
er    = erDen == 0 ? 0.0 : erNum / erDen

// 2) ADX
[diPlus, diMinus, adx] = ta.dmi(lenADX, lenADX)

// 3) EMA slope in ATR units per bar
emaTrend = ta.ema(close, lenEMA)
atrVal   = ta.atr(14)
slope    = atrVal == 0 ? 0.0 : (emaTrend - emaTrend[lenSlope]) / (lenSlope * atrVal)

// Percentile ranks against own history (0..100)
rER    = ta.percentrank(er, rankLen)
rADX   = ta.percentrank(adx, rankLen)
rSlope = ta.percentrank(math.abs(slope), rankLen)

ready    = bar_index >= rankLen
rawScore = W_ER * rER + W_ADX * rADX + W_SLOPE * rSlope
score    = ready ? ta.sma(rawScore, smoothLen) : na

// Direction bias
dir = slope > 0 and close > emaTrend ? 1 : slope < 0 and close < emaTrend ? -1 : 0

// ═══════════════════════════════════════════════════════════════
//  REGIME STATE MACHINE (with confirmation)
//  regime:  1 = Trending, 0 = Transition, -1 = Choppy
// ═══════════════════════════════════════════════════════════════
rawRegime = na(score) ? 0 : score >= trendThr ? 1 : score <= chopThr ? -1 : 0

var int regime    = 0
var int pending   = 0
var int pendCount = 0

if rawRegime != regime
    if rawRegime == pending
        pendCount += 1
    else
        pending   := rawRegime
        pendCount := 1
    if pendCount >= confirmN
        regime    := rawRegime
        pendCount := 0
else
    pending   := regime
    pendCount := 0

regimeChanged = regime != regime[1]
var int age = 0
age := regimeChanged ? 1 : age + 1

// stateCode: 2 = Trending Up, -2 = Trending Down, 3 = Trending (no bias), 0 = Transition, -1 = Choppy
stateCode = regime == 1 ? (dir == 1 ? 2 : dir == -1 ? -2 : 3) : regime == -1 ? -1 : 0

stateText = not ready ? "Warming up" :
     stateCode == 2  ? "Trending Up" :
     stateCode == -2 ? "Trending Down" :
     stateCode == 3  ? "Trending" :
     stateCode == -1 ? "Choppy" : "Transition"

stateColor = stateCode == 2 ? cUp : stateCode == -2 ? cDn : stateCode == 3 ? cUp : stateCode == -1 ? cChop : cTrans

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
hline(trendThr, "Trending Threshold", color=color.new(color.teal, 40), linestyle=hline.style_dashed)
hline(chopThr,  "Choppy Threshold",   color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(50,       "Midline",            color=color.new(color.gray, 75), linestyle=hline.style_dotted)

plot(score, "Regime Score (fill)", style=plot.style_area, color=color.new(stateColor, 85), linewidth=1)
plot(score, "Regime Score", color=stateColor, linewidth=2)

plot(showComp ? rER    : na, "Rank · Efficiency Ratio", color=color.new(color.aqua,   40), linewidth=1)
plot(showComp ? rADX   : na, "Rank · ADX",              color=color.new(color.purple, 40), linewidth=1)
plot(showComp ? rSlope : na, "Rank · Slope",            color=color.new(color.orange, 40), linewidth=1)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
tblPos = switch posInput
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

txtSize = switch sizeInput
    "Small" => size.small
    "Large" => size.large
    => size.normal

fmt(float x, int d) => na(x) ? "—" : str.tostring(math.round(x, d))

var table dash = table.new(tblPos, 2, 9, bgcolor=color.new(#0F1420, 8), border_width=1, border_color=color.new(#2A3350, 0), frame_width=1, frame_color=color.new(#2A3350, 0))

if barstate.islast and showTable
    cTxt  = #E6EAF2
    cDim  = #9AA4B8
    biasText = dir == 1 ? "Up" : dir == -1 ? "Down" : "Flat"
    biasCol  = dir == 1 ? cUp : dir == -1 ? cDn : cDim

    table.cell(dash, 0, 0, "MARKET REGIME", text_color=cTxt, text_size=txtSize, text_halign=text.align_center, bgcolor=color.new(#1B2440, 0))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "State", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, stateText, text_color=stateColor, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Regime Score", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, fmt(score, 1) + " / 100", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Regime Age", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(age) + " bars", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Efficiency Ratio", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, fmt(er, 2) + "  (P" + fmt(rER, 0) + ")", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 5, "ADX", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, fmt(adx, 1) + "  (P" + fmt(rADX, 0) + ")", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Slope (ATR/bar)", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, fmt(slope, 2) + "  (P" + fmt(rSlope, 0) + ")", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Directional Bias", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, biasText, text_color=biasCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 8, showBrand ? BRAND : "", text_color=cDim, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 8, 1, 8)

// ═══════════════════════════════════════════════════════════════
//  ALERTS  (set to "Once Per Bar Close" for stable, non-repainting triggers)
// ═══════════════════════════════════════════════════════════════
stateChanged = ta.change(stateCode) != 0 and ready

alertcondition(stateChanged and stateCode == 2,  "Regime: Trending Up",   "{{ticker}} ({{interval}}): market regime turned Trending Up")
alertcondition(stateChanged and stateCode == -2, "Regime: Trending Down", "{{ticker}} ({{interval}}): market regime turned Trending Down")
alertcondition(stateChanged and stateCode == -1, "Regime: Choppy",        "{{ticker}} ({{interval}}): market regime turned Choppy")
alertcondition(stateChanged and stateCode == 0,  "Regime: Transition",    "{{ticker}} ({{interval}}): market regime is in Transition")
alertcondition(stateChanged,                     "Regime: Any Change",    "{{ticker}} ({{interval}}): market regime changed")
````
