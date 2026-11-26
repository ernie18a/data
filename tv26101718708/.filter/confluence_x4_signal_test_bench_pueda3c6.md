# Confluence x4 Signal Test Bench

- url: https://www.tradingview.com/script/PUEDA3c6-Confluence-x4-Signal-Test-Bench/
- type: strategy
- pine_id: PUB;177bf40658e1483f84aafd95be6edaa2
- version: 1.0

## Description

Confluence x4 Signal Test Bench is a strategy for testing entry signals, not a strategy to follow. It answers one question: does an entry trigger beat random entries when both use the same exits and the same costs?

WHY IT IS DIFFERENT
Most published strategies report one equity curve and leave the reader to guess how much of it is signal and how much is luck. This script puts a random-entry control on equal footing with four indicator triggers: the same exit rule, the same position size, the same commission and slippage, the same date range. Only the timing of the entry changes. It also lets you switch on one confluence filter at a time (ablation), so you can see what each component adds instead of judging the whole stack at once.

HOW EACH COMPONENT IS CALCULATED 
All conditions are evaluated on the close of the bar; orders fill at the open of the next bar.

MA Cross trigger: the 20-period SMA crosses the 80-period SMA, with ADX above 20 (DMI length 15, ADX smoothing 90). Long crosses also require RSI(20) below 60; short crosses require RSI(20) above 40.
Trifecta trigger: the first bar on which RSI(14) > 50, the MACD line (12, 26) > 0 and the 20-period Chaikin Money Flow > 0 are all true at once (mirror conditions for shorts).

MT-Stoch trigger: a score from -5 to +5 built from five votes: three stochastics (20/12/12, 10/6/6 and 5/3/3, K versus D), a stochastic RSI oscillator (RSI 13, range 5, smoothing 8) above 20 or below 80, and the 100-bar percentile rank of the stochastic RSI K/D ratio. The trigger fires on the first bar the score reaches the threshold (default 3; -3 for shorts).

MCU trigger: a score from -9 to +9 built from nine votes in three groups: Ichimoku-style structure (20/60/120 periods, cloud displaced 30 bars back, price versus cloud, conversion versus base line, price versus 30 bars ago), ATR expansion (14-period ATR relative to its 50-period average, plus price versus the 20 EMA), and a Bollinger/Keltner squeeze with linear-regression momentum. The trigger fires on the first bar the score reaches the threshold (default 7; -7 for shorts).

Random (control): on each bar, a seeded pseudo-random number opens a long (or short) with the probability you set (default 2% per bar). The same seed reproduces the same entries on historical bars.

Filters: each filter requires that component to be in its bullish state (bearish for shorts) at the moment of the trigger. With all filters off, only the trigger decides.

Exits: Fixed bars (default, 10 bars), Opposite signal, ATR stop and target (2 and 3 times the 14-period ATR), or RSI(14) crossing 80/20. Fixed bars is the default because it gives every entry, the random one included, the same holding period, which is the cleanest way to ask whether the entry carries information.

The background color marks bars on which all four components agree; it is visual only and does not affect trades.

DEFAULT PROPERTIES (used for the published report)

[list]
[*]Initial capital: 10,000.
[*]Order size: 10% of equity per trade, no pyramiding.
[*]Commission: 0.05% per order, a typical retail cost for liquid stocks, ETFs and index CFDs. Adjust it to your instrument.
[*]Slippage: 2 ticks per order.
[*]Margin: 100% for longs and shorts, that is, a cash account without leverage.
[*]The strategy does not recalculate on every tick or after order fills.
[*]Date range: from 2018-01-01. Trigger: MT-Stoch. Mode: Both (long and short). Exit: Fixed bars, 10.
[*]MT-Stoch is the default trigger because it fires often enough to give a meaningful sample on daily charts. MA Cross and MCU fire much less often; with them, use a lower timeframe or a longer date range to reach a comparable number of trades.
[*]The report shown with this publication uses these defaults on SPY, daily timeframe, and contains more than 100 trades.
[/list]

HOW TO USE THE RANDOM CONTROL

[list=1]
[*]Keep the exit on Fixed bars and keep the costs on.
[*]Run your trigger and note the result and the number of trades.
[*]Switch the trigger to Random (control), adjust the entry probability until the trade count is similar, and run several seeds (for example 42, 43, 44...).
[*]Compare. If your trigger's result falls inside the range of the random runs, it is indistinguishable from chance on that chart and period.
[/list]

LIMITATIONS

One instrument and one history at a time. A result that survives the random control is a reason to test further, not evidence of an edge, because the history has already been looked at.
The random control is reproducible on historical bars for a given seed; on real-time bars new random draws occur.

The Ichimoku-style component uses values displaced 30 bars into the past only; no plot is shifted into the future.

Costs are approximations; spreads, financing and borrow fees are not modeled.

Nothing here is investment advice.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dead_signals_lab
// Confluence x4 Signal Test Bench - v1.5
// Ablation test bench: selectable entry trigger (including a random control),
// per-indicator filters, interchangeable exits and a date range.
//@version=6
// Defaults meant to resemble a retail cash account: 10,000 capital, 10% of equity
// per trade, 0.05% commission per order, 2 ticks of slippage, 100% margin (no leverage).
strategy("Confluence x4 Signal Test Bench", shorttitle="CX4 Bench", overlay=true,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     commission_type=strategy.commission.percent, commission_value=0.05, slippage=2, pyramiding=0,
     margin_long=100, margin_short=100)

// ==============================================
// 1. INPUTS - EXPERIMENT DESIGN
// ==============================================
grpLab  = "Experiment"
trigSrc = input.string("MT-Stoch", "Entry trigger", options=["MA Cross", "Trifecta", "MT-Stoch", "MCU", "Random (control)"], group=grpLab, tooltip="Which event opens the position. 'Random' is the null control: same exits and costs, random timing.")
useTriF = input.bool(false, "Filter: Trifecta aligned",       group=grpLab)
useMTF  = input.bool(false, "Filter: MT-Stoch aligned",       group=grpLab)
useMCUF = input.bool(false, "Filter: MCU aligned",            group=grpLab)
useMAF  = input.bool(false, "Filter: MA + ADX structure",     group=grpLab, tooltip="Each filter requires that indicator to be in a bullish state (bearish for shorts) at the moment of the trigger. The trigger's own filter is redundant.")
tradeMode = input.string("Both", "Mode", options=["Long Only", "Short Only", "Both"], group=grpLab)

grpExit  = "Exit"
exitMode = input.string("Fixed bars", "Exit mode", options=["Fixed bars", "Opposite signal", "ATR SL/TP", "RSI extreme"], group=grpExit, tooltip="'Fixed bars' is the cleanest way to measure whether the signal contains information (event study): the same horizon for every entry, the random one included.")
exitBars = input.int(10,    "Fixed bars: N",    minval=1, group=grpExit)
atrLenX  = input.int(14,    "ATR: length",      minval=1, group=grpExit)
slMult   = input.float(2.0, "ATR: SL multiple", step=0.1, group=grpExit)
tpMult   = input.float(3.0, "ATR: TP multiple", step=0.1, group=grpExit)

grpRand  = "Random control"
randProb = input.float(2.0, "Entry probability per bar (%)", minval=0.1, maxval=50, step=0.1, group=grpRand, tooltip="Adjust it so the control's trade count is similar to the signal you are comparing.")
randSeed = input.int(42, "Seed", group=grpRand, tooltip="Change the seed and re-run several times: a 'dead' signal should fall inside the distribution of the controls.")

grpDate = "Date range"
startT  = input.time(timestamp("2018-01-01T00:00:00"), "Start", group=grpDate)
endT    = input.time(timestamp("2035-01-01T00:00:00"), "End",   group=grpDate)

grpThr    = "Score thresholds"
mtThresh  = input.int(3, "MT-Stoch: minimum score (1-5)", minval=1, maxval=5, group=grpThr)
mcuThresh = input.int(7, "MCU: minimum score (1-9)",      minval=1, maxval=9, group=grpThr)

// ==============================================
// 2. COMPONENT - TRIFECTA (RSI / MACD / CMF)
// ==============================================
triRsi = ta.rsi(close, 14)
[triMacd, _, _] = ta.macd(close, 12, 26, 9)
mfm  = high == low ? 0.0 : (2 * close - low - high) / (high - low)
volS = math.sum(volume, 20)
mfvS = math.sum(mfm * volume, 20)
triCmf  = volS == 0 ? 0.0 : mfvS / volS
triBull = triRsi > 50 and triMacd > 0 and triCmf > 0
triBear = triRsi < 50 and triMacd < 0 and triCmf < 0

// ==============================================
// 3. COMPONENT - MT-STOCHASTIC RSI 4
// ==============================================
mk1 = ta.sma(ta.stoch(close, high, low, 20), 12)
md1 = ta.sma(mk1, 12)
mk2 = ta.sma(ta.stoch(close, high, low, 10), 6)
md2 = ta.sma(mk2, 6)
mk3 = ta.sma(ta.stoch(close, high, low, 5), 3)
md3 = ta.sma(mk3, 3)
mrsi = ta.rsi(close, 14)
mk   = ta.sma(ta.stoch(mrsi, mrsi, mrsi, 14), 3)
md   = ta.sma(mk, 3)
sveR  = ta.rsi(close, 13)
sveLo = ta.sma(sveR - ta.lowest(sveR, 5), 8)
sveRg = ta.sma(ta.highest(sveR, 5) - ta.lowest(sveR, 5), 8)
sve   = sveLo / (0.1 + sveRg) * 100
kdRatio = md == 0 ? 1.0 : mk / md
mtPos   = ta.percentrank(kdRatio, 100)
mtUp = (mk1 >= md1 ? 1 : 0) + (mk2 >= md2 ? 1 : 0) + (mk3 >= md3 ? 1 : 0) + (sve > 20 ? 1 : 0) + (mtPos >= 50 ? 1 : 0)
mtDn = (mk1 <= md1 ? 1 : 0) + (mk2 <= md2 ? 1 : 0) + (mk3 <= md3 ? 1 : 0) + (sve < 80 ? 1 : 0) + (mtPos < 50 ? 1 : 0)
mtScore = mtUp - mtDn
mtBull  = mtScore >= mtThresh
mtBear  = mtScore <= -mtThresh

// ==============================================
// 4. COMPONENT - MCU (Ichimoku / ATR / Squeeze)
// ==============================================
tenkan = (ta.highest(high, 20)  + ta.lowest(low, 20))  / 2
kijun  = (ta.highest(high, 60)  + ta.lowest(low, 60))  / 2
senA   = (tenkan + kijun) / 2
senB   = (ta.highest(high, 120) + ta.lowest(low, 120)) / 2
cTop   = math.max(senA[30], senB[30])
cBot   = math.min(senA[30], senB[30])
ichUp  = (close > cTop ? 1 : 0) + (tenkan > kijun ? 1 : 0) + (close > close[30] ? 1 : 0)
ichDn  = (close < cBot ? 1 : 0) + (tenkan < kijun ? 1 : 0) + (close < close[30] ? 1 : 0)

atrP   = ta.atr(14) / close * 100
atrR   = atrP / ta.sma(atrP, 50)
atrExp = atrR > 1.005
ema20  = ta.ema(close, 20)
atrUp  = (atrExp and close > close[1] ? 1 : 0) + (atrR > 1.2 and close > close[1] ? 1 : 0) + (close > ema20 ? 1 : 0)
atrDn  = (atrExp and close < close[1] ? 1 : 0) + (atrR > 1.2 and close < close[1] ? 1 : 0) + (close < ema20 ? 1 : 0)

bbB  = ta.sma(close, 20)
bbD  = 2.0 * ta.stdev(close, 20)
kcB  = ta.ema(close, 20)
kcR  = 1.5 * ta.atr(20)
sqOn = bbB + bbD < kcB + kcR and bbB - bbD > kcB - kcR
bsq  = ta.barssince(sqOn)
sqFired = not sqOn and not na(bsq) and bsq <= 5
momSrc  = close - math.avg(math.avg(ta.highest(high, 12), ta.lowest(low, 12)), ta.sma(close, 12))
sqM     = ta.linreg(momSrc, 12, 0)
sqUp = (sqM > 0 ? 1 : 0) + (sqM > 0 and sqM > sqM[1] ? 1 : 0) + (sqFired and sqM > 0 ? 1 : 0)
sqDn = (sqM < 0 ? 1 : 0) + (sqM < 0 and sqM < sqM[1] ? 1 : 0) + (sqFired and sqM < 0 ? 1 : 0)

mcuScore = (ichUp + atrUp + sqUp) - (ichDn + atrDn + sqDn)
mcuBull  = mcuScore >= mcuThresh
mcuBear  = mcuScore <= -mcuThresh

// ==============================================
// 5. COMPONENT - MA CROSSOVER (MA / ADX / RSI)
// ==============================================
maS = ta.sma(close, 20)
maL = ta.sma(close, 80)
[diP, diM, adxV] = ta.dmi(15, 90)
trendOk = adxV > 20
maRsi   = ta.rsi(close, 20)
maXup = ta.crossover( maS, maL) and trendOk and maRsi < 60
maXdn = ta.crossunder(maS, maL) and trendOk and maRsi > 40
maBullState = maS > maL and trendOk
maBearState = maS < maL and trendOk

// ==============================================
// 6. RANDOM CONTROL
// ==============================================
randUp = math.random(0, 100, randSeed)     < randProb
randDn = math.random(0, 100, randSeed + 1) < randProb

// ==============================================
// 7. TRIGGERS, FILTERS AND ENTRIES
// ==============================================
trigUp = trigSrc == "MA Cross" ? maXup : trigSrc == "Trifecta" ? triBull and not triBull[1] : trigSrc == "MT-Stoch" ? mtBull and not mtBull[1] : trigSrc == "MCU" ? mcuBull and not mcuBull[1] : randUp
trigDn = trigSrc == "MA Cross" ? maXdn : trigSrc == "Trifecta" ? triBear and not triBear[1] : trigSrc == "MT-Stoch" ? mtBear and not mtBear[1] : trigSrc == "MCU" ? mcuBear and not mcuBear[1] : randDn

fUp = (not useTriF or triBull) and (not useMTF or mtBull) and (not useMCUF or mcuBull) and (not useMAF or maBullState)
fDn = (not useTriF or triBear) and (not useMTF or mtBear) and (not useMCUF or mcuBear) and (not useMAF or maBearState)

inRange = time >= startT and time <= endT
longOk  = tradeMode != "Short Only"
shortOk = tradeMode != "Long Only"

enterL = inRange and longOk  and trigUp and fUp
enterS = inRange and shortOk and trigDn and fDn

if enterL
    strategy.entry("L", strategy.long)
if enterS
    strategy.entry("S", strategy.short)

// ==============================================
// 8. EXITS (all precomputed at global scope)
// ==============================================
var int entryBar = na
if strategy.position_size != 0 and math.sign(strategy.position_size) != math.sign(strategy.position_size[1])
    entryBar := bar_index

atrX     = ta.atr(atrLenX)
rsiExitL = ta.crossover( ta.rsi(close, 14), 80)
rsiExitS = ta.crossunder(ta.rsi(close, 14), 20)

if exitMode == "Fixed bars" and strategy.position_size != 0 and not na(entryBar) and bar_index - entryBar >= exitBars
    strategy.close_all(comment="t+" + str.tostring(exitBars))

if exitMode == "Opposite signal"
    if strategy.position_size > 0 and trigDn
        strategy.close("L", comment="reverse")
    if strategy.position_size < 0 and trigUp
        strategy.close("S", comment="reverse")

if exitMode == "ATR SL/TP"
    if strategy.position_size > 0
        strategy.exit("xL", "L", stop=strategy.position_avg_price - slMult * atrX, limit=strategy.position_avg_price + tpMult * atrX)
    if strategy.position_size < 0
        strategy.exit("xS", "S", stop=strategy.position_avg_price + slMult * atrX, limit=strategy.position_avg_price - tpMult * atrX)

if exitMode == "RSI extreme"
    if strategy.position_size > 0 and rsiExitL
        strategy.close("L", comment="rsi80")
    if strategy.position_size < 0 and rsiExitS
        strategy.close("S", comment="rsi20")

// Outside the experiment's date range, always flat
if not inRange and strategy.position_size != 0
    strategy.close_all(comment="end of range")

// ==============================================
// 9. VISUALS (minimal)
// ==============================================
plot(maS, "MA 20", color=color.new(color.red,  40))
plot(maL, "MA 80", color=color.new(color.blue, 40))

allBull = triBull and mtBull and mcuBull and maBullState
allBear = triBear and mtBear and mcuBear and maBearState
bgcolor(allBull ? color.new(color.green, 88) : allBear ? color.new(color.red, 88) : na, title="Confluence x4")
````
