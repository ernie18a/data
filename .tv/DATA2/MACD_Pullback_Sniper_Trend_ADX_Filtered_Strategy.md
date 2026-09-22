<!-- tradingview-pine-id: PUB;aeae32205bbc4e4eb1e472b3bbe4e57d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MACD Pullback Sniper | Trend + ADX Filtered Strategy

Source: https://www.tradingview.com/script/V87nRt9v-MACD-Pullback-Sniper-Trend-ADX-Filtered-Strategy/

## Description

MACD Pullback Sniper is a simple trend-following strategy. It uses the classic MACD signal-line cross, but only takes the crosses that line up with the larger trend. The goal is fewer trades, taken at better moments.

How it works
The strategy waits for the MACD line to cross the signal line, then checks three filters before entering:

[*]Trend filter: Longs are allowed only when price is above the 200 EMA, and shorts only when it is below.
[*]Zero-line filter: Longs must cross below the zero line and shorts above it. In an uptrend, a bullish cross below zero usually marks a pullback ending, so entries come after the dip rather than after the move.
[*]ADX filter: Trades are taken only when ADX is above the threshold (default 20). This cuts out many of the whipsaws that MACD produces in sideways markets.

Exits and risk management

[*]Stop loss: ATR-based (default 2x ATR), so it adapts to volatility.
[*]Take profit: A fixed reward:risk multiple (default 2R).
[*]Optional signal exit: Closes the trade on an opposite MACD cross.
[*]Position sizing: Each trade risks a fixed percentage of current equity (default 1%). A maximum position size cap stops very tight stops from creating oversized trades.
[*]Stop and target placement: After entry, both are re-anchored to the actual fill price. The stop and target are drawn on the price chart while a trade is open.

Features

[*]Long and short trading, with shorts switchable off
[*]Each filter can be turned on or off independently
[*]Custom start and end dates for backtesting
[*]MACD histogram, MACD line and signal line in a separate pane
[*]Trend EMA, stop, target and entry markers drawn on the main chart
[*]Commission (0.05%) and slippage (2 ticks) included in the default settings

Tips

[*]Use it on trending markets and higher timeframes (1H, 4H, Daily). MACD crosses on very low timeframes are mostly noise.
[*]If you want more trades, turn off the zero-line filter first. If you want higher quality, raise the ADX minimum to 25.
[*]Check the trade count. Judge results on at least 100 trades, and be wary of any setting that looks great over only 20 or 30.
[*]Avoid over-optimizing. The defaults (12/26/9, 200 EMA, 14 ADX and ATR) are standard values, and results that hold up across nearby settings are more trustworthy.
[*]Test on several symbols and timeframes rather than one.
[*]Adjust the commission and slippage inputs to match your broker or exchange.
[*]Position sizing assumes one contract moves one currency unit per point of price, which fits crypto and stocks. For forex or futures, check the contract value and adjust sizing.
[*]For live trading, use a lower risk per trade than you think you need, and set the maximum drawdown you can accept before you start.

Disclaimer: This script is for educational purposes only and is not financial advice. Backtest results do not guarantee future performance. Always test on a demo account first and trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blitz_locked

//@version=6
strategy('MACD Pullback Sniper | Trend + ADX Filtered Strategy', overlay = false,
     initial_capital = 10000,
     commission_type = strategy.commission.percent, commission_value = 0.05,
     slippage = 2, pyramiding = 0,
     margin_long = 100, margin_short = 100)

// MACD signal-line cross, filtered by trend, zero line and ADX.
// Exits use an ATR stop and a fixed reward:risk target.

// --- Inputs ---
grpM = 'MACD'
fastLen   = input.int(12, 'Fast EMA', minval = 1, group = grpM)
slowLen   = input.int(26, 'Slow EMA', minval = 1, group = grpM)
signalLen = input.int(9, 'Signal EMA', minval = 1, group = grpM)

grpF = 'Filters'
useTrend = input.bool(true, 'Trend filter (price vs EMA)', group = grpF)
trendLen = input.int(200, 'Trend EMA length', minval = 2, group = grpF)
useZero  = input.bool(true, 'Zero-line filter', group = grpF, tooltip = 'Longs only when the cross happens below zero, shorts only above zero.')
useAdx   = input.bool(true, 'ADX filter', group = grpF)
adxLen   = input.int(14, 'ADX length', minval = 1, group = grpF)
adxMin   = input.float(20.0, 'ADX minimum', minval = 1, group = grpF)

grpR = 'Risk'
atrLen    = input.int(14, 'ATR length', minval = 1, group = grpR)
slMult    = input.float(2.0, 'Stop distance (x ATR)', minval = 0.1, step = 0.1, group = grpR)
rrRatio   = input.float(2.0, 'Reward : Risk', minval = 0.5, step = 0.1, group = grpR)
riskPct   = input.float(1.0, 'Risk per trade (% of equity)', minval = 0.1, maxval = 10, step = 0.1, group = grpR)
maxLev    = input.float(1.0, 'Max position size (x equity)', minval = 0.1, step = 0.1, group = grpR, tooltip = 'Caps position value so a tight stop cannot create an oversized trade.')
exitCross = input.bool(true, 'Exit on opposite MACD cross', group = grpR)

grpG = 'General'
allowShort = input.bool(true, 'Allow shorts', group = grpG)
startDate  = input.time(timestamp('01 Jan 2018 00:00 +0000'), 'Start date', group = grpG)
endDate    = input.time(timestamp('31 Dec 2069 23:59 +0000'), 'End date', group = grpG)

// --- Calculations ---
[macdLine, signalLine, hist] = ta.macd(close, fastLen, slowLen, signalLen)
trendEma = ta.ema(close, trendLen)
[_, _, adx] = ta.dmi(adxLen, adxLen)
atr = ta.atr(atrLen)

inRange   = time >= startDate and time <= endDate
bullCross = ta.crossover(macdLine, signalLine)
bearCross = ta.crossunder(macdLine, signalLine)

// --- Signals ---
trendLongOk  = not useTrend or close > trendEma
trendShortOk = not useTrend or close < trendEma
zeroLongOk   = not useZero or macdLine < 0
zeroShortOk  = not useZero or macdLine > 0
adxOk        = not useAdx or adx > adxMin

longSignal  = bullCross and trendLongOk and zeroLongOk and adxOk and inRange
shortSignal = bearCross and trendShortOk and zeroShortOk and adxOk and inRange and allowShort

// --- Position sizing (fixed % risk per trade) ---
f_qty(float stopDist) =>
    float riskAmt = strategy.equity * riskPct / 100
    float q = stopDist > 0 ? riskAmt / stopDist : 0.0
    q := math.min(q, strategy.equity * maxLev / close)
    float step = syminfo.mincontract > 0 ? syminfo.mincontract : 1.0
    math.floor(q / step) * step

// --- Trade management ---
var float entryAtr = na
var float slLvl = na
var float tpLvl = na

// Open position: anchor stop and target to the actual fill price
if strategy.position_size > 0
    slLvl := strategy.position_avg_price - entryAtr * slMult
    tpLvl := strategy.position_avg_price + entryAtr * slMult * rrRatio
    strategy.exit('Long Exit', 'Long', stop = slLvl, limit = tpLvl)
else if strategy.position_size < 0
    slLvl := strategy.position_avg_price + entryAtr * slMult
    tpLvl := strategy.position_avg_price - entryAtr * slMult * rrRatio
    strategy.exit('Short Exit', 'Short', stop = slLvl, limit = tpLvl)
else
    slLvl := na
    tpLvl := na

// Exit on opposite cross (unless it is also a valid reversal entry)
if exitCross and bearCross and strategy.position_size > 0 and not shortSignal
    strategy.close('Long', comment = 'MACD cross')
if exitCross and bullCross and strategy.position_size < 0 and not longSignal
    strategy.close('Short', comment = 'MACD cross')

// Entries (provisional stop/target protect the fill bar)
if longSignal and strategy.position_size <= 0
    float q = f_qty(atr * slMult)
    if q > 0
        entryAtr := atr
        strategy.entry('Long', strategy.long, qty = q)
        strategy.exit('Long Exit', 'Long', stop = close - atr * slMult, limit = close + atr * slMult * rrRatio)

if shortSignal and strategy.position_size >= 0
    float q = f_qty(atr * slMult)
    if q > 0
        entryAtr := atr
        strategy.entry('Short', strategy.short, qty = q)
        strategy.exit('Short Exit', 'Short', stop = close + atr * slMult, limit = close - atr * slMult * rrRatio)

// --- Visuals ---
hColor = hist >= 0 ? (hist > hist[1] ? color.new(color.teal, 0) : color.new(color.teal, 60)) : (hist < hist[1] ? color.new(color.red, 0) : color.new(color.red, 60))
plot(hist, 'Histogram', style = plot.style_columns, color = hColor)
plot(macdLine, 'MACD', color = color.blue, linewidth = 2)
plot(signalLine, 'Signal', color = color.orange, linewidth = 1)
hline(0, 'Zero', color = color.gray, linestyle = hline.style_dashed)

plot(trendEma, 'Trend EMA', color = color.new(color.gray, 20), linewidth = 2, force_overlay = true)
plot(slLvl, 'Stop', color = color.red, style = plot.style_linebr, force_overlay = true)
plot(tpLvl, 'Target', color = color.green, style = plot.style_linebr, force_overlay = true)
plotshape(longSignal, 'Long', style = shape.triangleup, location = location.belowbar, color = color.teal, size = size.small, force_overlay = true)
plotshape(shortSignal, 'Short', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small, force_overlay = true)
````
