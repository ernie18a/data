# EMA + MACD + RSI Confluence Signal

- url: https://www.tradingview.com/script/e8ABY7TP-EMA-MACD-RSI-Confluence-Signal/
- type: indicator
- pine_id: PUB;3ca0d4e34ce841a0b711d22384037cd9
- version: 3.0

## Description

[b]Description:
[/b]
This indicator identifies high-probability trend reversal and continuation points by requiring three independent momentum conditions to align simultaneously before printing a signal. Once a signal is printed, no duplicate is shown until the opposite side triggers — keeping your chart clean and unambiguous.

[b]Signal Logic
[/b]
A BUY label appears when the last of the following three conditions falls into place while the other two are already active:

[list]
[*]9 EMA crosses above 20 EMA (bullish alignment)
[*]MACD line crosses above Signal line (golden cross)
[*]RSI crosses above its own 14-period EMA (momentum shift)
[/list]

A SELL label appears on the mirror-image bearish confluence.

Signals alternate strictly: after a BUY, no further BUY labels appear until a SELL is confirmed, and vice versa.

Confluence Ribbon

The ribbon filled between the 9 EMA and 20 EMA reflects real-time signal strength across 6 conditions:

# / Condition / Bull / Bear
1 / EMA alignment / Fast > Slow / Fast < Slow
2 / MACD cross / MACD > Signal / MACD < Signal
3 / RSI cross / RSI > RSI EMA / RSI < RSI EMA
4 / RSI level / RSI > 50 / RSI < 50
5 / RSI EMA level / RSI EMA > 50 / RSI EMA < 50
6 / MACD histogram / Histogram > 0 / Histogram < 0


The ribbon fades from nearly transparent (1 condition) to solid color (all 6), giving you an at-a-glance read of how strong the current trend environment is — even between signals.

Settings

Parameter / Default / Description
Fast EMA / 9 / Fast EMA period
Slow EMA / 20 / Slow EMA period
MACD Fast / 12 / MACD fast length
MACD Slow / 26 / MACD slow length
MACD Signal / 9 / MACD signal smoothing
RSI Length / 14 / RSI period
RSI EMA Length / 14 / EMA applied to RSI
RSI Level / 50 / Midline for conditions 4 & 5

[b]How to Use
[/b]
Add the indicator to any chart and timeframe. Works on all assets.
Watch the ribbon color: green = bullish pressure building, red = bearish. The more opaque, the more conditions are aligned.
Wait for a BUY or SELL label — this is your signal entry bar.
Use the ribbon between signals to gauge whether the trend is holding or weakening.
Set an alert via right-click → Add Alert on the indicator for hands-free notification.

[b]Tips
[/b]
Higher timeframes (15m, 1H) produce fewer but higher-quality signals.
A strong ribbon (5–6 conditions) that precedes a label increases conviction.
Combine with support/resistance or session levels for best results.

## Source Code

````pine
//@version=5
indicator("EMA + MACD + RSI Signal", overlay=true, max_labels_count=500)

// ── Inputs ──────────────────────────────────────────────────────────────────
emaFastLen  = input.int(9,   "Fast EMA",        minval=1)
emaSlowLen  = input.int(20,  "Slow EMA",        minval=1)
macdFast    = input.int(12,  "MACD Fast",       minval=1)
macdSlow    = input.int(26,  "MACD Slow",       minval=1)
macdSignal  = input.int(9,   "MACD Signal",     minval=1)
rsiLen      = input.int(14,  "RSI Length",      minval=1)
rsiEmaLen   = input.int(14,  "RSI EMA Length",  minval=1)
rsiLevel    = input.float(50, "RSI Level",      minval=1, maxval=99,
     tooltip="RSI and RSI-EMA must be above/below this level")
showOnlyToday = input.bool(false, "Only Show Today's Session")

// ── Calculations ─────────────────────────────────────────────────────────────
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)

rsi    = ta.rsi(close, rsiLen)
rsiEma = ta.ema(rsi, rsiEmaLen)

// ── Condition 1 — EMA cross ───────────────────────────────────────────────────
emaBullCross = ta.crossover(emaFast, emaSlow)
emaBearCross = ta.crossunder(emaFast, emaSlow)
emaAlignBull = emaFast > emaSlow
emaAlignBear = emaFast < emaSlow

// ── Condition 2 — MACD golden/death cross ────────────────────────────────────
macdBullCross = ta.crossover(macdLine, signalLine)
macdBearCross = ta.crossunder(macdLine, signalLine)
macdAlignBull = macdLine > signalLine
macdAlignBear = macdLine < signalLine

// ── Condition 3 — RSI golden/death cross (RSI vs its EMA) ───────────────────
rsiBullCross = ta.crossover(rsi, rsiEma)
rsiBearCross = ta.crossunder(rsi, rsiEma)
rsiAlignBull = rsi > rsiEma
rsiAlignBear = rsi < rsiEma

// For ribbon score — conditions are active when aligned (not just on cross bar)
emaBull  = emaAlignBull
emaBear  = emaAlignBear
macdBull = macdAlignBull
macdBear = macdAlignBear
rsiBull  = rsiAlignBull
rsiBear  = rsiAlignBear

// ── Condition 4 — RSI above/below level ──────────────────────────────────────
rsiAbove = rsi > rsiLevel
rsiBelow = rsi < rsiLevel

// ── Condition 5 — RSI EMA above/below level ──────────────────────────────────
rsiEmaAbove = rsiEma > rsiLevel
rsiEmaBelow = rsiEma < rsiLevel

// ── Condition 6 — MACD histogram green/red column ────────────────────────────
histGreen = histLine > 0
histRed   = histLine < 0

// ── Raw signals — fire when the last cross completes while the other two are aligned
buyRaw  = (emaBullCross  and macdAlignBull and rsiAlignBull) or
          (macdBullCross and emaAlignBull  and rsiAlignBull) or
          (rsiBullCross  and emaAlignBull  and macdAlignBull)
sellRaw = (emaBearCross  and macdAlignBear and rsiAlignBear) or
          (macdBearCross and emaAlignBear  and rsiAlignBear) or
          (rsiBearCross  and emaAlignBear  and macdAlignBear)

// ── State machine — suppress repeat signals until the opposite side fires ─────
// posState: 1 = in buy, -1 = in sell, 0 = flat
var int posState = 0
buySignal  = buyRaw  and posState != 1
sellSignal = sellRaw and posState != -1
if buySignal
    posState := 1
if sellSignal
    posState := -1

// ── Confluence score (0–6) ────────────────────────────────────────────────────
bullScore = (emaBull     ? 1 : 0) + (macdBull    ? 1 : 0) + (rsiBull    ? 1 : 0)
          + (rsiAbove    ? 1 : 0) + (rsiEmaAbove ? 1 : 0) + (histGreen  ? 1 : 0)
bearScore = (emaBear     ? 1 : 0) + (macdBear    ? 1 : 0) + (rsiBear    ? 1 : 0)
          + (rsiBelow    ? 1 : 0) + (rsiEmaBelow ? 1 : 0) + (histRed    ? 1 : 0)

// ── Ribbon color — opacity scales with score (1=faintest, 6=strongest) ───────
bullTrans = bullScore == 6 ? 10 : bullScore == 5 ? 25 : bullScore == 4 ? 45
          : bullScore == 3 ? 62 : bullScore == 2 ? 78 : 90
bearTrans = bearScore == 6 ? 10 : bearScore == 5 ? 25 : bearScore == 4 ? 45
          : bearScore == 3 ? 62 : bearScore == 2 ? 78 : 90

ribbonColor =
  bullScore > bearScore ? color.new(color.lime, bullTrans) :
  bearScore > bullScore ? color.new(color.red,  bearTrans) :
  color.new(color.gray, 92)

// ── Today's session filter ──────────────────────────────────────────────────
var int currentDay = na
if barstate.islast
    currentDay := dayofmonth
bool isToday = showOnlyToday ? (dayofmonth == currentDay) : true

// ── Plot EMAs + ribbon fill ───────────────────────────────────────────────────
p1 = plot(emaFast, "EMA 9",  color=color.new(color.aqua,   0), linewidth=1)
p2 = plot(emaSlow, "EMA 20", color=color.new(color.orange,  0), linewidth=1)
fill(p1, p2, color=isToday ? ribbonColor : na, title="Confluence Ribbon")

// ── Signal labels ─────────────────────────────────────────────────────────────
if buySignal and barstate.isconfirmed
    label.new(bar_index, low,  "BUY",  yloc=yloc.belowbar,
     color=color.new(color.lime, 10), textcolor=color.black,
     style=label.style_label_up,  size=size.normal)

if sellSignal and barstate.isconfirmed
    label.new(bar_index, high, "SELL", yloc=yloc.abovebar,
     color=color.new(color.red,  10), textcolor=color.white,
     style=label.style_label_down, size=size.normal)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(buySignal,  "BUY Signal",  "6/6 Bull confluence")
alertcondition(sellSignal, "SELL Signal", "6/6 Bear confluence")
````
