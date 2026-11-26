# SBOD Trend by readCrypto

- url: https://www.tradingview.com/script/0Et8J3Y3-SBOD-Trend-by-readCrypto/
- type: indicator
- pine_id: PUB;a99bfc2c1f5b4687a42e7dfa1e1a17fa
- version: 1.0

## Description

WHY A NEW VERSION
The original SBOD ("OBV by readCrypto") shows BSSC, OBV and StochRSI as separate plots in one pane. Each is useful on its own, but reading them together has limits:
- The three often disagree, and the chart does not tell you which one to follow.
- Some readings depend on direction (rising / falling), so they flip on small moves and make it hard to tell a trend from noise.
- Overbought / oversold can only be judged on StochRSI, which reflects price momentum alone and ignores volume flow.
SBOD Trend keeps the same three calculations and combines them into one reading: is the market in an uptrend or a downtrend, how strong is it, and is it stretched far enough that a reversal becomes more likely.

WHAT IT CALCULATES
The three components use the same formulas as the original SBOD:
- BSSC: a combined score of MFI, Accumulation/Distribution and Williams %R (-6 to +6)
- OBV: On-Balance Volume based on OHLC4, compared with its EMA(18) and its 18-bar high-low band
- StochRSI: RSI(14) of OHLC4 -> Stochastic(7) -> K(3), D(3) -> (K + D) / 2

1. Trend histogram
Each component casts one vote. The votes are based on position, not direction, so short pullbacks do not flip them:
- BSSC: score above 0 = up, below 0 = down
- OBV: above its EMA(18) = up, below = down
- StochRSI: above 50 = up, below 50 = down
The sum of the votes is shown as columns:
- +3 (dark green): strong uptrend, all three agree
- +1 (light green): uptrend, two of three agree
- -1 (light red): downtrend, two of three agree
- -3 (dark red): strong downtrend, all three agree

2. Strength line (-100 to +100)
Each component is scaled to the same -1 to +1 range and the three are averaged:
- BSSC / 50
- OBV position inside its 18-bar high-low band
- (StochRSI - 50) / 50
The histogram shows the side of the trend; the strength line shows how much force is behind it.

3. Overbought / oversold zones
Similar to the 80 / 20 levels of StochRSI, but measured on the combined strength line, so price momentum and volume flow must both be extended before a zone is reached.
- Overbought: strength at or above +60 (orange zone, the line turns orange)
- Oversold: strength at or below -60 (blue zone, the line turns blue)

HOW TO READ IT
- Trend: follow the histogram color. Dark colors mean all three components agree.
- Momentum: watch the strength line within the trend. A rising line means the trend is strengthening; a falling line while the histogram keeps its color means it is losing force.
- Exhaustion: when the strength line reaches the orange zone in an uptrend and then turns down, the move may be ending. The same applies to a downtrend in the blue zone.
- Trend change: a change of trend is confirmed when the histogram itself changes from green to red, or from red to green.
In strong trends the strength line can stay inside a zone for a long time. A zone is a warning to watch for a reversal, not a signal on its own.

SETTINGS
- Volume source: Auto uses real volume when the symbol has it, and the high-low range for symbols without volume (such as indices). Real volume or Range can also be selected.
- Show strength line: on / off
- Overbought / Oversold levels: default +60 / -60

NOTES
- All values are calculated on the chart timeframe.
- On symbols without volume, the OBV, MFI and A/D components use the high-low range as a substitute, so the reading is an approximation.
- The histogram and strength line of the current bar can change until the bar closes.
- This indicator is a tool for chart analysis and is not financial advice.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © readCrypto
//
// SBOD Trend : BSSC + OBV + StochRSI combined into one trend reading
//
// Each of the three indicators casts one vote (+1 up / -1 down):
//   BSSC     : score above 0 = up, below 0 = down      (MFI + A/D line + Williams %R)
//   OBV      : OBV above its EMA18 = up, below = down
//   StochRSI : StochRSI above 50 = up, below 50 = down
//
// Trend (sum of the votes, -3 ~ +3)
//   +3 Strong uptrend   : all three agree up
//   +1 Uptrend          : two of three up
//   -1 Downtrend        : two of three down
//   -3 Strong downtrend : all three agree down
//   (0 only appears while a component is exactly on its line)
//
// Strength line (-100 ~ +100)
//   Average of the three components scaled to the same range:
//   BSSC / 50, OBV position inside its 18-bar High-Low band, (StochRSI - 50) / 50.
//
// Overbought / oversold zones (like StochRSI 80 / 20) on the strength line
//   Overbought : strength >= +60  -> an uptrend may be near its end
//   Oversold   : strength <= -60  -> a downtrend may be near its end

indicator("SBOD Trend by readCrypto", shorttitle = "SBOD Trend", overlay = false, precision = 0)

//==================================================
// INPUTS
//==================================================
volMode = input.string("Auto", "Volume source", options = ["Auto", "Real volume", "Range (High-Low)"], tooltip = "Auto: real volume when the symbol has it, otherwise the High-Low range (for indices without volume).", display = display.none)
showStrength = input.bool(true, "Show strength line", display = display.none)

groupZ   = "Overbought / Oversold"
obLevel  = input.int(60, "Overbought level", minval = 10, maxval = 100, group = groupZ, display = display.none)
osLevel  = input.int(-60, "Oversold level", minval = -100, maxval = -10, group = groupZ, display = display.none)

//==================================================
// VOLUME SOURCE (index-compatible)
//==================================================
hasVol   = ta.cum(nz(volume)) > 0
useRange = volMode == "Range (High-Low)" or (volMode == "Auto" and not hasVol)
volSrc   = useRange ? (high - low) : nz(volume)

//==================================================
// BSSC = MFI + ADL + Williams %R  (same as SBOD)
//==================================================
f_mfi(src, len, v) =>
    upper = math.sum(v * (ta.change(src) <= 0 ? 0 : src), len)
    lower = math.sum(v * (ta.change(src) >= 0 ? 0 : src), len)
    lower == 0 ? 100.0 : 100.0 - 100.0 / (1.0 + upper / lower)

mfi = f_mfi(close, 14, volSrc)
mfiScore = mfi > 80 ? 2 : mfi > 50 ? 1 : mfi >= 20 ? -1 : -2

ad = ta.cum(high == low ? 0 : ((2 * close - low - high) / (high - low)) * volSrc)
hhADL = ta.highest(ad, 18)
llADL = ta.lowest(ad, 18)
var float h1ADL = na
var float l1ADL = na
h1ADL := hhADL == hhADL[1] ? hhADL : nz(h1ADL[1], hhADL)
l1ADL := llADL == llADL[1] ? llADL : nz(l1ADL[1], llADL)
adMid = (h1ADL + l1ADL) * 0.5
adlScore = ad >= h1ADL ? 2 : ad > adMid ? 1 : ad > l1ADL ? -1 : -2

hh14 = ta.highest(high, 14)
ll14 = ta.lowest(low, 14)
percentR = hh14 != ll14 ? 100 * (close - hh14) / (hh14 - ll14) : -50
wrScore = percentR > -20 ? 2 : percentR > -50 ? 1 : percentR >= -80 ? -1 : -2

score = mfiScore + adlScore + wrScore           // -6 ~ +6
bssc  = score * 50.0 / 6.0                      // -50 ~ +50 (same scale as SBOD)

//==================================================
// StochRSI  (same as SBOD)
//==================================================
rsiValue = ta.rsi(ohlc4, 14)
k = ta.sma(ta.stoch(rsiValue, rsiValue, rsiValue, 7), 3)
d = ta.sma(k, 3)
stochRsi = (k + d) * 0.5                        // 0 ~ 100

//==================================================
// OBV  (same as SBOD)
//==================================================
obv = ta.cum(math.sign(ta.change(ohlc4)) * volSrc)
hhOBV = ta.highest(obv, 18)
llOBV = ta.lowest(obv, 18)
var float h1OBV = na
var float l1OBV = na
h1OBV := hhOBV == hhOBV[1] ? hhOBV : nz(h1OBV[1], hhOBV)
l1OBV := llOBV == llOBV[1] ? llOBV : nz(l1OBV[1], llOBV)
obvEMA18 = ta.ema(obv, 18)

//==================================================
// VOTES AND TREND
//==================================================
vB = score > 0 ? 1 : score < 0 ? -1 : 0
vO = obv > obvEMA18 ? 1 : obv < obvEMA18 ? -1 : 0
vS = stochRsi > 50 ? 1 : stochRsi < 50 ? -1 : 0

trendSum = vB + vO + vS                          // -3 ~ +3

// Strength line: each component scaled to -1 ~ +1, averaged, x100
nB = bssc / 50.0
nO = h1OBV != l1OBV ? math.max(-1.0, math.min(1.0, 2.0 * (obv - l1OBV) / (h1OBV - l1OBV) - 1.0)) : 0.0
nS = (stochRsi - 50.0) / 50.0
strength = 100.0 * (nB + nO + nS) / 3.0

//==================================================
// OVERBOUGHT / OVERSOLD ZONES
//==================================================
inOB = strength >= obLevel
inOS = strength <= osLevel

//==================================================
// DISPLAY
//==================================================
colStrongUp = color.new(#00332a, 75)
colUp       = color.new(#26A69A, 75)
colDn       = color.new(#FF5252, 75)
colStrongDn = color.new(color.maroon, 75)

trendCol = trendSum >= 3 ? colStrongUp : trendSum > 0 ? colUp : trendSum <= -3 ? colStrongDn : trendSum < 0 ? colDn : color.gray

// Trend histogram scaled to the strength range: +3 -> +100, +1 -> +33 ...
plot(trendSum * 100.0 / 3.0, "Trend (votes x33)", color = trendCol, style = plot.style_columns)
strengthCol = inOB ? color.new(color.orange, 0) : inOS ? color.new(color.blue, 0) : color.new(color.black, 0)
plot(showStrength ? strength : na, "Strength", color = strengthCol, linewidth = 2)

hline(0, "Zero", color = color.new(#787B86, 40), linestyle = hline.style_solid)
hTop = hline(100, "Strong up", color = color.new(#787B86, 80), linestyle = hline.style_dotted)
hBot = hline(-100, "Strong down", color = color.new(#787B86, 80), linestyle = hline.style_dotted)
hOB  = hline(obLevel, "Overbought", color = color.new(color.orange, 40), linestyle = hline.style_dashed, display = display.none)
hOS  = hline(osLevel, "Oversold", color = color.new(color.blue, 40), linestyle = hline.style_dashed, display = display.none)
fill(hOB, hTop, color = color.new(color.orange, 90), title = "Overbought zone")
fill(hBot, hOS, color = color.new(color.blue, 90), title = "Oversold zone")
````
