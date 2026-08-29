<!-- tradingview-pine-id: PUB;feb86c5583ff41f6857e969263fa8546 -->
<!-- tradingviewscripts-format: 1 -->
# hamster-bot MRS

Source: https://www.tradingview.com/script/tCKIm6og-Multi-Mean-Reversion-Strategy/

## Description

MRS - Mean Reversion Strategy (Countertrend) (Envelope strategy)

This script does not claim to be unique and does not mislead anyone. Even the unattractive backtest result is attached. The source code is open. The idea has been described many times in various sources. But at the same time, their collection in one place provides unique opportunities.

Published by popular demand and for ease of use. so that users can track the development of the script and can offer their ideas in the comments. Otherwise, you have to communicate in several telegram chats.

Representative of the family of counter-trend strategies. The basis of the strategy is Mean reversion. You can also read about the Envelope strategy.

Mean reversion, or reversion to the mean, is a theory used in finance that suggests that asset price volatility and historical returns eventually will revert to the long-run mean or average level of the entire dataset.

The strategy is very simple. Has very few settings. Good for beginners to get acquainted with algorithmic trading. A simple adjustment will help avoid overfitting. There are many variations of this strategy, but for understanding it is better to start with this implementation.

Principle of operation.
1) [Closing]
A conventional MA is being built. (fuchsia line). A limit order is placed on this line to close the position.
2) [BUY | LONG]
(green line) A limit order is placed on this line to open a long position
3) [SELL | SHORT]
(red line) A limit order is placed on this line to open a short position

Attention!
Please note that a limit order is used. Conclude that the strategy has a limited capacity. And the results obtained on low-liquid instruments will be too high in the tester. On real auctions there will be a different result.

Note for testing the strategy in the spot market:
When testing in the spot market, do not include both long and short at the same time. It is recommended to test only the long mode on the spot. Short mode for more advanced users.

Settings:
Available types of moving averages:
SMA
EMA
TEMA - triple exponential moving average
DEMA - Double Exponential Moving Average
ZLEMA - Zero lag exponential moving average
WMA - weighted moving average
Hma - Hull Moving Average
Thma - Triple Exponential Hull Moving Average
Ehma - Exponential Hull Moving Average
H - MA built based on highs for n candles | ta.highest(len)
L - MA built based on lows for n candles | ta.lowest(len)
DMA - Donchian Moving Average

A Kalman filter can be applied to all MA

The peculiarity of the strategy is a large selection of MA and the possibility of shifting lines. You can set up a reverse trending strategy on the Donchian channel for example.

Use Long - enable/disable opening a Long position
Use Short - enable/disable opening a Short position

Lot Long, % - % allocated from the deposit for opening a Long position. In the spot market, do not use % greater than 100%
Lot Short, % - allocated % of the deposit for opening a Short position

Start date - the beginning of the testing period
End date - the end of the testing period (Example: only August 2020 can be tested)

Mul - multiplier. Used to offset lines. Example:
Mul = 0.99 is shift -1%
Mul = 1.01 is shift +1%

Non-strict recommendations:
1) Test the SPOT market on crypto exchanges. (The countertrend strategy has liquidation risk on futures)
2) Symbols altcoin/bitcoin or altcoin/altcoin. Example: ETH/BTC or DOGE/ETH
3) Timeframe is usually 1 hour

---

## Source Code

````pine
//@version=6
strategy(title = 'hamster-bot MRS', overlay = true, default_qty_type = strategy.percent_of_equity, initial_capital = 100, default_qty_value = 100, pyramiding = 9, commission_value = 0.045, backtest_fill_limits_assumption = 1, margin_long = 0, margin_short = 0)
info_options = 'Options'

on_close = input(false, title = 'Entry on close', inline = info_options, group = info_options)
OFFS = input.int(0, minval = 0, maxval = 1, title = '| Offset View', inline = info_options, group = info_options)
trade_offset = input.int(0, minval = 0, maxval = 1, title = 'Trade', inline = info_options, group = info_options)
use_kalman_filter = input.bool(false, title = 'Use Kalman filter', group = info_options)

// Filter
info_filter_1 = 'Filter 1'
//filter_low_use = input(false, title = "Filter 1", inline=info_filter_1, group=info_filter_1)
filter_low_candles = input.int(0, minval = 0, title = 'Filter X', inline = info_filter_1, group = info_filter_1)

//MA Opening
info_opening = 'MA Opening'
maopeningtyp = input.string('SMA', title = '', options = ['SMA', 'EMA', 'TEMA', 'DEMA', 'ZLEMA', 'WMA', 'Hma', 'Thma', 'Ehma', 'H', 'L', 'DMA'], inline = info_opening, group = info_opening)
maopeningsrc = input.source(ohlc4, title = '', inline = info_opening, group = info_opening)
maopeninglen = input.int(3, minval = 1, maxval = 200, title = '', inline = info_opening, group = info_opening)

//MA Closing
info_closing = 'MA Closing'
use_maclosing = input(true, title = 'Use', group = info_closing)
maclosingtyp = input.string('SMA', title = '', options = ['SMA', 'EMA', 'TEMA', 'DEMA', 'ZLEMA', 'WMA', 'Hma', 'Thma', 'Ehma', 'H', 'L', 'DMA'], inline = info_closing, group = info_closing)
maclosingsrc = input.source(ohlc4, title = '', inline = info_closing, group = info_closing)
maclosinglen = input.int(3, minval = 1, maxval = 200, title = '', inline = info_closing, group = info_closing)
//maclosingoff = input.int(0, minval = 0, maxval = 100, title = "", inline=info_closing, group=info_closing)

use_fast_close = input(false, title = 'Use fast close', group = info_closing)
ma_fast_len_1 = input.int(1, minval = 1, maxval = 200, title = '1', inline = 'fast1', group = info_closing)
ma_fast_typ_1 = input.string('SMA', title = '', options = ['SMA', 'EMA', 'TEMA', 'DEMA', 'ZLEMA', 'WMA', 'Hma', 'Thma', 'Ehma', 'DMA'], inline = 'fast1', group = info_closing)
ma_fast_src_1 = input.source(ohlc4, title = '', inline = 'fast1', group = info_closing)
ma_fast_mul_1 = input.float(1.0, title = '', step = 0.001, inline = 'fast1', group = info_closing)
f_1_color = input.color(color.yellow, title = '', inline = 'fast1', group = info_closing)

ma_fast_len_2 = input.int(1, minval = 1, maxval = 200, title = '2', inline = 'fast2', group = info_closing)
ma_fast_typ_2 = input.string('SMA', title = '', options = ['SMA', 'EMA', 'TEMA', 'DEMA', 'ZLEMA', 'WMA', 'Hma', 'Thma', 'Ehma', 'DMA'], inline = 'fast2', group = info_closing)
ma_fast_src_2 = input.source(ohlc4, title = '', inline = 'fast2', group = info_closing)
ma_fast_mul_2 = input.float(1.0, title = '', step = 0.001, inline = 'fast2', group = info_closing)
f_2_color = input.color(color.orange, title = '', inline = 'fast2', group = info_closing)

ma_fast_len_3 = input.int(1, minval = 1, maxval = 200, title = '3', inline = 'fast3', group = info_closing)
ma_fast_typ_3 = input.string('SMA', title = '', options = ['SMA', 'EMA', 'TEMA', 'DEMA', 'ZLEMA', 'WMA', 'Hma', 'Thma', 'Ehma', 'DMA'], inline = 'fast3', group = info_closing)
ma_fast_src_3 = input.source(ohlc4, title = '', inline = 'fast3', group = info_closing)
ma_fast_mul_3 = input.float(1.0, title = '', step = 0.001, inline = 'fast3', group = info_closing)
f_3_color = input.color(color.red, title = '', inline = 'fast3', group = info_closing)


//ma_fast_closingoff = input.int(0, minval = 0, maxval = 100, title = "", inline="fast", group=info_closing)

// //SL and TP
// slandtpbox = input(true, title = "=============== SL & TP ===============")
// tplong = input.float(3, minval = 0, maxval = 10000, title = "Take-profit Long")
// tpshort = input.float(3, minval = 0, maxval = 10000, title = "Take-profit Short")
// sllong = input.float(3.0, minval = 0, maxval = 10000, title = "Stop-loss Long")
// slshort = input.float(3.0, minval = 0, maxval = 10000, title = "Stop-loss Short")

//Shifts long
long = input(true, title = '================== Long ==================')
long1on = input(true, title = '', inline = 'long1')
long1shift = input.float(7, minval = 0, maxval = 10000, step = 0.1, title = 'Long 1', inline = 'long1')
long1lot = input.int(10, minval = 0, maxval = 10000, step = 10, title = 'Lot 1', inline = 'long1')
long2on = input(true, title = '', inline = 'long2')
long2shift = input.float(8, minval = 0, maxval = 10000, step = 0.1, title = 'Long 2', inline = 'long2')
long2lot = input.int(20, minval = 0, maxval = 10000, step = 10, title = 'Lot 2', inline = 'long2')
long3on = input(true, title = '', inline = 'long3')
long3shift = input.float(9, minval = 0, maxval = 10000, step = 0.1, title = 'Long 3', inline = 'long3')
long3lot = input.int(30, minval = 0, maxval = 10000, step = 10, title = 'Lot 3', inline = 'long3')
long4on = input(false, title = '', inline = 'long4')
long4shift = input.float(20, minval = 0, maxval = 10000, step = 0.1, title = 'Long 4', inline = 'long4')
long4lot = input.int(40, minval = 0, maxval = 10000, step = 10, title = 'Lot 4', inline = 'long4')
long5on = input(false, title = '', inline = 'long5')
long5shift = input.float(25, minval = 0, maxval = 10000, step = 0.1, title = 'Long 5', inline = 'long5')
long5lot = input.int(50, minval = 0, maxval = 10000, step = 10, title = 'Lot 5', inline = 'long5')
long6on = input(false, title = '', inline = 'long6')
long6shift = input.float(30, minval = 0, maxval = 10000, step = 0.1, title = 'Long 6', inline = 'long6')
long6lot = input.int(60, minval = 0, maxval = 10000, step = 10, title = 'Lot 6', inline = 'long6')
long7on = input(false, title = '', inline = 'long7')
long7shift = input.float(35, minval = 0, maxval = 10000, step = 0.1, title = 'Long 7', inline = 'long7')
long7lot = input.int(70, minval = 0, maxval = 10000, step = 10, title = 'Lot 7', inline = 'long7')
long8on = input(false, title = '', inline = 'long8')
long8shift = input.float(40, minval = 0, maxval = 10000, step = 0.1, title = 'Long 8', inline = 'long8')
long8lot = input.int(80, minval = 0, maxval = 10000, step = 10, title = 'Lot 8', inline = 'long8')
long9on = input(false, title = '', inline = 'long9')
long9shift = input.float(45, minval = 0, maxval = 10000, step = 0.1, title = 'Long 9', inline = 'long9')
long9lot = input.int(90, minval = 0, maxval = 10000, step = 10, title = 'Lot 9', inline = 'long9')

//Shifts short
short = input(true, title = '================== Short ==================')
short1on = input(true, title = '', inline = 'short1')
short1shift = input.float(12, minval = 0, maxval = 10000, step = 0.1, title = 'short 1', inline = 'short1')
short1lot = input.int(10, minval = 0, maxval = 10000, step = 10, title = 'Lot 1', inline = 'short1')
short2on = input(true, title = '', inline = 'short2')
short2shift = input.float(14, minval = 0, maxval = 10000, step = 0.1, title = 'short 2', inline = 'short2')
short2lot = input.int(20, minval = 0, maxval = 10000, step = 10, title = 'Lot 2', inline = 'short2')
short3on = input(true, title = '', inline = 'short3')
short3shift = input.float(16, minval = 0, maxval = 10000, step = 0.1, title = 'short 3', inline = 'short3')
short3lot = input.int(30, minval = 0, maxval = 10000, step = 10, title = 'Lot 3', inline = 'short3')
short4on = input(false, title = '', inline = 'short4')
short4shift = input.float(20, minval = 0, maxval = 10000, step = 0.1, title = 'short 4', inline = 'short4')
short4lot = input.int(40, minval = 0, maxval = 10000, step = 10, title = 'Lot 4', inline = 'short4')
short5on = input(false, title = '', inline = 'short5')
short5shift = input.float(25, minval = 0, maxval = 10000, step = 0.1, title = 'short 5', inline = 'short5')
short5lot = input.int(50, minval = 0, maxval = 10000, step = 10, title = 'Lot 5', inline = 'short5')
short6on = input(false, title = '', inline = 'short6')
short6shift = input.float(30, minval = 0, maxval = 10000, step = 0.1, title = 'short 6', inline = 'short6')
short6lot = input.int(60, minval = 0, maxval = 10000, step = 10, title = 'Lot 6', inline = 'short6')
short7on = input(false, title = '', inline = 'short7')
short7shift = input.float(35, minval = 0, maxval = 10000, step = 0.1, title = 'short 7', inline = 'short7')
short7lot = input.int(70, minval = 0, maxval = 10000, step = 10, title = 'Lot 7', inline = 'short7')
short8on = input(false, title = '', inline = 'short8')
short8shift = input.float(40, minval = 0, maxval = 10000, step = 0.1, title = 'short 8', inline = 'short8')
short8lot = input.int(80, minval = 0, maxval = 10000, step = 10, title = 'Lot 8', inline = 'short8')
short9on = input(false, title = '', inline = 'short9')
short9shift = input.float(45, minval = 0, maxval = 10000, step = 0.1, title = 'short 9', inline = 'short9')
short9lot = input.int(90, minval = 0, maxval = 10000, step = 10, title = 'Lot 9', inline = 'short9')

//Period
period = input(true, title = '================= Period ==================')
startTime = input.time(timestamp('01 Jan 2010 00:00 +0000'), 'Start date', inline = 'period')
finalTime = input.time(timestamp('31 Dec 2030 23:59 +0000'), 'Final date', inline = 'period')

HMA(_src, _length) =>
    ta.wma(2 * ta.wma(_src, _length / 2) - ta.wma(_src, _length), math.round(math.sqrt(_length)))
EHMA(_src, _length) =>
    ta.ema(2 * ta.ema(_src, _length / 2) - ta.ema(_src, _length), math.round(math.sqrt(_length)))
THMA(_src, _length) =>
    ta.wma(ta.wma(_src, _length / 3) * 3 - ta.wma(_src, _length / 2) - ta.wma(_src, _length), _length)
tema(sec, length) =>
    tema1 = ta.ema(sec, length)
    tema2 = ta.ema(tema1, length)
    tema3 = ta.ema(tema2, length)
    tema_r = 3 * tema1 - 3 * tema2 + tema3
    tema_r
donchian(len) =>
    math.avg(ta.lowest(len), ta.highest(len))
ATR_func(_src, _len) =>
    atrLow = low - ta.atr(_len)
    trailAtrLow = atrLow
    trailAtrLow := na(trailAtrLow[1]) ? trailAtrLow : atrLow >= trailAtrLow[1] ? atrLow : trailAtrLow[1]
    supportHit = _src <= trailAtrLow
    trailAtrLow := supportHit ? atrLow : trailAtrLow
    trailAtrLow
f_dema(src, len) =>
    EMA1 = ta.ema(src, len)
    EMA2 = ta.ema(EMA1, len)
    DEMA = 2 * EMA1 - EMA2
    DEMA
f_zlema(src, period) =>
    lag = math.round((period - 1) / 2)
    ema_data = src + src - src[lag]
    zl = ta.ema(ema_data, period)
    zl
f_kalman_filter(src) =>
    float value1 = na
    float value2 = na
    value1 := 0.2 * (src - src[1]) + 0.8 * nz(value1[1])
    value2 := 0.1 * ta.tr + 0.8 * nz(value2[1])
    lambda = math.abs(value1 / value2)
    alpha = (-math.pow(lambda, 2) + math.sqrt(math.pow(lambda, 4) + 16 * math.pow(lambda, 2))) / 8
    value3 = float(na)
    value3 := alpha * src + (1 - alpha) * nz(value3[1])
    value3
    //SWITCH
ma_func(modeSwitch, src, len, use_k_f = true) =>
    modeSwitch == 'SMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(ta.sma(src, len)) : ta.sma(src, len) : modeSwitch == 'RMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(ta.rma(src, len)) : ta.rma(src, len) : modeSwitch == 'EMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(ta.ema(src, len)) : ta.ema(src, len) : modeSwitch == 'TEMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(tema(src, len)) : tema(src, len) : modeSwitch == 'DEMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(f_dema(src, len)) : f_dema(src, len) : modeSwitch == 'ZLEMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(f_zlema(src, len)) : f_zlema(src, len) : modeSwitch == 'WMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(ta.wma(src, len)) : ta.wma(src, len) : modeSwitch == 'VWMA' ? use_kalman_filter and use_k_f ? f_kalman_filter(ta.vwma(src, len)) : ta.vwma(src, len) : modeSwitch == 'Hma' ? use_kalman_filter and use_k_f ? f_kalman_filter(HMA(src, len)) : HMA(src, len) : modeSwitch == 'Ehma' ? use_kalman_filter and use_k_f ? f_kalman_filter(EHMA(src, len)) : EHMA(src, len) : modeSwitch == 'Thma' ? use_kalman_filter and use_k_f ? f_kalman_filter(THMA(src, len / 2)) : THMA(src, len / 2) : modeSwitch == 'ATR' ? use_kalman_filter and use_k_f ? f_kalman_filter(ATR_func(src, len)) : ATR_func(src, len) : modeSwitch == 'L' ? use_kalman_filter and use_k_f ? f_kalman_filter(ta.lowest(len)) : ta.lowest(len) : modeSwitch == 'H' ? use_kalman_filter and use_k_f ? f_kalman_filter(ta.highest(len)) : ta.highest(len) : modeSwitch == 'DMA' ? donchian(len) : na

//Var
sum = 0.0
maopening = 0.0
maclosing = 0.0
os = maopeningsrc
cs = maclosingsrc
pos = strategy.position_size
p = 0.0
p := pos == 0 ? strategy.equity / 100 / close : p[1]
truetime = period == false ? true : time > startTime and time < finalTime
loss = 0.0
maxloss = 0.0
equity = 0.0

//MA Opening
maopening := ma_func(maopeningtyp, maopeningsrc, maopeninglen)

//MA Closing
if use_maclosing
    maclosing := ma_func(maclosingtyp, maclosingsrc, maclosinglen)
    maclosing
if use_maclosing == false
    maclosing := maopening
    maclosing

//MA Closing fast
ma_fast_closing_1 = ma_func(ma_fast_typ_1, ma_fast_src_1, ma_fast_len_1) * ma_fast_mul_1
ma_fast_closing_2 = ma_func(ma_fast_typ_2, ma_fast_src_2, ma_fast_len_2) * ma_fast_mul_2
ma_fast_closing_3 = ma_func(ma_fast_typ_3, ma_fast_src_3, ma_fast_len_3) * ma_fast_mul_3

//Shifts long
long1 = long == false ? 0 : long1on == false ? 0 : long1shift == 0 ? 0 : long1lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long1shift
long2 = long == false ? 0 : long2on == false ? 0 : long2shift == 0 ? 0 : long2lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long2shift
long3 = long == false ? 0 : long3on == false ? 0 : long3shift == 0 ? 0 : long3lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long3shift
long4 = long == false ? 0 : long4on == false ? 0 : long4shift == 0 ? 0 : long4lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long4shift
long5 = long == false ? 0 : long5on == false ? 0 : long5shift == 0 ? 0 : long5lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long5shift
long6 = long == false ? 0 : long6on == false ? 0 : long6shift == 0 ? 0 : long6lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long6shift
long7 = long == false ? 0 : long7on == false ? 0 : long7shift == 0 ? 0 : long7lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long7shift
long8 = long == false ? 0 : long8on == false ? 0 : long8shift == 0 ? 0 : long8lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long8shift
long9 = long == false ? 0 : long9on == false ? 0 : long9shift == 0 ? 0 : long9lot == 0 ? 0 : maopening == 0 ? 0 : maopening - maopening / 100 * long9shift

//Shifts short
short1 = short == false ? 0 : short1on == false ? 0 : short1shift == 0 ? 0 : short1lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short1shift
short2 = short == false ? 0 : short2on == false ? 0 : short2shift == 0 ? 0 : short2lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short2shift
short3 = short == false ? 0 : short3on == false ? 0 : short3shift == 0 ? 0 : short3lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short3shift
short4 = short == false ? 0 : short4on == false ? 0 : short4shift == 0 ? 0 : short4lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short4shift
short5 = short == false ? 0 : short5on == false ? 0 : short5shift == 0 ? 0 : short5lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short5shift
short6 = short == false ? 0 : short6on == false ? 0 : short6shift == 0 ? 0 : short6lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short6shift
short7 = short == false ? 0 : short7on == false ? 0 : short7shift == 0 ? 0 : short7lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short7shift
short8 = short == false ? 0 : short8on == false ? 0 : short8shift == 0 ? 0 : short8lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short8shift
short9 = short == false ? 0 : short9on == false ? 0 : short9shift == 0 ? 0 : short9lot == 0 ? 0 : maopening == 0 ? 0 : maopening + maopening / 100 * short9shift

//Colors
maopeningcol = maopening == 0 ? na : color.blue
maclosingcol = maclosing == 0 ? na : color.fuchsia
long1col = long1 == 0 ? na : color.green
long2col = long2 == 0 ? na : color.green
long3col = long3 == 0 ? na : color.green
long4col = long4 == 0 ? na : color.green
long5col = long5 == 0 ? na : color.green
long6col = long6 == 0 ? na : color.green
long7col = long7 == 0 ? na : color.green
long8col = long8 == 0 ? na : color.green
long9col = long9 == 0 ? na : color.green
short1col = short1 == 0 ? na : color.red
short2col = short2 == 0 ? na : color.red
short3col = short3 == 0 ? na : color.red
short4col = short4 == 0 ? na : color.red
short5col = short5 == 0 ? na : color.red
short6col = short6 == 0 ? na : color.red
short7col = short7 == 0 ? na : color.red
short8col = short8 == 0 ? na : color.red
short9col = short9 == 0 ? na : color.red

//Lines
plot(maopening, offset = OFFS, color = maopeningcol)
plot(maclosing, offset = OFFS, color = maclosingcol)
long1line = long1 == 0 ? close : long1
long2line = long2 == 0 ? close : long2
long3line = long3 == 0 ? close : long3
long4line = long4 == 0 ? close : long4
long5line = long5 == 0 ? close : long5
long6line = long6 == 0 ? close : long6
long7line = long7 == 0 ? close : long7
long8line = long8 == 0 ? close : long8
long9line = long9 == 0 ? close : long9
short1line = short1 == 0 ? close : short1
short2line = short2 == 0 ? close : short2
short3line = short3 == 0 ? close : short3
short4line = short4 == 0 ? close : short4
short5line = short5 == 0 ? close : short5
short6line = short6 == 0 ? close : short6
short7line = short7 == 0 ? close : short7
short8line = short8 == 0 ? close : short8
short9line = short9 == 0 ? close : short9
plot(long1line, offset = OFFS, color = long1col)
plot(long2line, offset = OFFS, color = long2col)
plot(long3line, offset = OFFS, color = long3col)
plot(long4line, offset = OFFS, color = long4col)
plot(long5line, offset = OFFS, color = long5col)
plot(long6line, offset = OFFS, color = long6col)
plot(long7line, offset = OFFS, color = long7col)
plot(long8line, offset = OFFS, color = long8col)
plot(long9line, offset = OFFS, color = long9col)
plot(short1line, offset = OFFS, color = short1col)
plot(short2line, offset = OFFS, color = short2col)
plot(short3line, offset = OFFS, color = short3col)
plot(short4line, offset = OFFS, color = short4col)
plot(short5line, offset = OFFS, color = short5col)
plot(short6line, offset = OFFS, color = short6col)
plot(short7line, offset = OFFS, color = short7col)
plot(short8line, offset = OFFS, color = short8col)
plot(short9line, offset = OFFS, color = short9col)

//Lots
lotlong1 = p * long1lot
lotlong2 = p * long2lot
lotlong3 = p * long3lot
lotlong4 = p * long4lot
lotlong5 = p * long5lot
lotlong6 = p * long6lot
lotlong7 = p * long7lot
lotlong8 = p * long8lot
lotlong9 = p * long9lot
lotshort1 = p * short1lot
lotshort2 = p * short2lot
lotshort3 = p * short3lot
lotshort4 = p * short4lot
lotshort5 = p * short5lot
lotshort6 = p * short6lot
lotshort7 = p * short7lot
lotshort8 = p * short8lot
lotshort9 = p * short9lot

// Filter
filter = false
if filter_low_candles > 0
    filter := long1 >= ta.lowest(filter_low_candles)
    filter

plotshape(filter, 'filter 1', style = shape.xcross)


//Entry
if maopening > 0 and maclosing > 0 and truetime and filter == false
    //Long
    sum := 0
    if long1 > 0 and pos <= sum and (on_close ? close <= long1[trade_offset] : true)
        strategy.entry('L1', strategy.long, lotlong1, limit = on_close ? na : long1)
    sum := lotlong1
    if long2 > 0 and pos <= sum and (on_close ? close <= long2[trade_offset] : true)
        strategy.entry('L2', strategy.long, lotlong2, limit = on_close ? na : long2)
    sum := lotlong1 + lotlong2
    if long3 > 0 and pos <= sum and (on_close ? close <= long3[trade_offset] : true)
        strategy.entry('L3', strategy.long, lotlong3, limit = on_close ? na : long3)
    sum := lotlong1 + lotlong2 + lotlong3
    if long4 > 0 and pos <= sum and (on_close ? close <= long4[trade_offset] : true)
        strategy.entry('L4', strategy.long, lotlong4, limit = on_close ? na : long4)
    sum := lotlong1 + lotlong2 + lotlong3 + lotlong4
    if long5 > 0 and pos <= sum and (on_close ? close <= long5[trade_offset] : true)
        strategy.entry('L5', strategy.long, lotlong5, limit = on_close ? na : long5)
    sum := lotlong1 + lotlong2 + lotlong3 + lotlong4 + lotlong5
    if long6 > 0 and pos <= sum and (on_close ? close <= long6[trade_offset] : true)
        strategy.entry('L6', strategy.long, lotlong6, limit = on_close ? na : long6)
    sum := lotlong1 + lotlong2 + lotlong3 + lotlong4 + lotlong5 + lotlong6
    if long7 > 0 and pos <= sum and (on_close ? close <= long7[trade_offset] : true)
        strategy.entry('L7', strategy.long, lotlong7, limit = on_close ? na : long7)
    sum := lotlong1 + lotlong2 + lotlong3 + lotlong4 + lotlong5 + lotlong6 + lotlong7
    if long8 > 0 and pos <= sum and (on_close ? close <= long8[trade_offset] : true)
        strategy.entry('L8', strategy.long, lotlong8, limit = on_close ? na : long8)
    sum := lotlong1 + lotlong2 + lotlong3 + lotlong4 + lotlong5 + lotlong6 + lotlong7 + lotlong8
    if long9 > 0 and pos <= sum and (on_close ? close <= long9[trade_offset] : true)
        strategy.entry('L9', strategy.long, lotlong9, limit = on_close ? na : long9)

    //Short
    sum := 0
    pos := -1 * pos
    if short1 > 0 and pos <= sum and (on_close ? close >= short1[trade_offset] : true)
        strategy.entry('S1', strategy.short, lotshort1, limit = on_close ? na : short1)
    sum := lotshort1
    if short2 > 0 and pos <= sum and (on_close ? close >= short2[trade_offset] : true)
        strategy.entry('S2', strategy.short, lotshort2, limit = on_close ? na : short2)
    sum := lotshort1 + lotshort2
    if short3 > 0 and pos <= sum and (on_close ? close >= short3[trade_offset] : true)
        strategy.entry('S3', strategy.short, lotshort3, limit = on_close ? na : short3)
    sum := lotshort1 + lotshort2 + lotshort3
    if short4 > 0 and pos <= sum and (on_close ? close >= short4[trade_offset] : true)
        strategy.entry('S4', strategy.short, lotshort4, limit = on_close ? na : short4)
    sum := lotshort1 + lotshort2 + lotshort3 + lotshort4
    if short5 > 0 and pos <= sum and (on_close ? close >= short5[trade_offset] : true)
        strategy.entry('S5', strategy.short, lotshort5, limit = on_close ? na : short5)
    sum := lotshort1 + lotshort2 + lotshort3 + lotshort4 + lotshort5
    if short6 > 0 and pos <= sum and (on_close ? close >= short6[trade_offset] : true)
        strategy.entry('S6', strategy.short, lotshort6, limit = on_close ? na : short6)
    sum := lotshort1 + lotshort2 + lotshort3 + lotshort4 + lotshort5 + lotshort6
    if short7 > 0 and pos <= sum and (on_close ? close >= short7[trade_offset] : true)
        strategy.entry('S7', strategy.short, lotshort7, limit = on_close ? na : short7)
    sum := lotshort1 + lotshort2 + lotshort3 + lotshort4 + lotshort5 + lotshort6 + lotshort7
    if short8 > 0 and pos <= sum and (on_close ? close >= short8[trade_offset] : true)
        strategy.entry('S8', strategy.short, lotshort8, limit = on_close ? na : short8)
    sum := lotshort1 + lotshort2 + lotshort3 + lotshort4 + lotshort5 + lotshort6 + lotshort7 + lotshort8
    if short9 > 0 and pos <= sum and (on_close ? close >= short9[trade_offset] : true)
        strategy.entry('S9', strategy.short, lotshort9, limit = on_close ? na : short9)

avg = strategy.position_avg_price

// if strategy.position_size > 0    
//     strategy.entry("Take", strategy.short, 0, limit = avg + ((avg / 100) * tplong))
//     strategy.entry("Stop", strategy.short, 0, stop = avg - ((avg / 100) * sllong))

// if strategy.position_size < 0
//     strategy.entry("Take", strategy.long, 0, limit = avg - ((avg / 100) * tpshort))
//     strategy.entry("Stop", strategy.long, 0, stop = avg + ((avg / 100) * slshort))

//     //Cancel order
// if strategy.position_size == 0
//     strategy.cancel("Take")
//     strategy.cancel("Stop")

// takelong = avg != 0 ? avg + ((avg / 100) * tplong) : na
// stoplong = avg != 0 ? avg - ((avg / 100) * sllong) : na
// takeshort = avg != 0 ? avg - ((avg / 100) * tpshort) : na
// stopshort = avg != 0 ? avg + ((avg / 100) * slshort) : na
// takelinecolor = avg == avg[1] and avg != 0 ? color.green : na
// stoplinecolor = avg == avg[1] and avg != 0 ? color.red : na
// plot(takelong, offset = OFFS, color = takelinecolor, linewidth = 3)
// plot(stoplong, offset = OFFS, color = stoplinecolor, linewidth = 3)
// plot(takeshort, offset = OFFS, color = takelinecolor, linewidth = 3)
// plot(stopshort, offset = OFFS, color = stoplinecolor, linewidth = 3)

barsSinceLastEntry() =>
    strategy.opentrades > 0 ? bar_index - strategy.opentrades.entry_bar_index(strategy.opentrades - 1) : 0

// if barsSinceLastEntry() > 0 and barsSinceLastEntry() < 4
//     label.new(bar_index, high*1.01, text=str.tostring(barsSinceLastEntry()), color=color.gray, style=label.style_circle)

plot(ma_fast_closing_1, offset = OFFS, color = use_fast_close ? f_1_color : na, title = 'fast 1')
plot(ma_fast_closing_2, offset = OFFS, color = use_fast_close ? f_2_color : na, title = 'fast 2')
plot(ma_fast_closing_3, offset = OFFS, color = use_fast_close ? f_3_color : na, title = 'fast 3')

if use_fast_close and barsSinceLastEntry() == 0
    maclosing := ma_fast_closing_1
    maclosing
if use_fast_close and barsSinceLastEntry() == 1
    maclosing := ma_fast_closing_2
    maclosing
if use_fast_close and barsSinceLastEntry() == 2
    maclosing := ma_fast_closing_3
    maclosing

//Exit
strategy.exit('Exit', na, limit = maclosing)

//End
if time > finalTime
    strategy.close_all()

//Drawdown
max = 0.0
min = 100.0
max := math.max(strategy.equity, nz(max[1]))
dd = (strategy.equity / max - 1) * 100
min := math.min(dd, nz(min[1]))

//Max loss size
equity := strategy.position_size != strategy.position_size[1] ? strategy.equity : equity[1]
loss := equity < equity[1] ? (equity / equity[1] - 1) * 100 : 0
maxloss := math.min(nz(maxloss[1]), loss)

//Label
min := math.round(min * 100) / 100
maxloss := math.round(maxloss * 100) / 100
labeltext = 'Drawdown: ' + str.tostring(min) + '%' + '\nMax.loss ' + str.tostring(maxloss) + '%'
var label la = na
label.delete(la)
tc = min > -100 ? color.blue : color.red
osx = timenow + math.round(ta.change(time) * 50)
osy = ta.highest(100)
la := label.new(x = osx, y = osy, text = labeltext, xloc = xloc.bar_time, yloc = yloc.price, color = color.black, style = label.style_label_left, textcolor = tc)
````
