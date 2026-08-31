<!-- tradingview-pine-id: PUB;ce09862da04c4d93808511d822838cb8 -->
<!-- tradingviewscripts-format: 1 -->
# TRADLEWARE-Gaussian Channel ETH

Source: https://www.tradingview.com/script/egTb7TgJ-TRADLEWARE-Gaussian-Channel-StochRSI-ETH/

## Description

[image]https://www.tradingview.com/x/xo5RQhhT/[/image]

Gaussian Channel + Stochastic RSI ETH

This strategy combines a fast Gaussian Channel with a Stochastic RSI filter and a 200-day SMA bull-market gate, aimed at catching trend continuation while sitting out confirmed downtrends.

How it works

The Gaussian Channel is a smoothed price envelope built with an IIR (infinite impulse response) filter — a mathematically elegant alternative to a simple moving average. It applies a bell-curve weighting across recent bars, producing smooth, low-lag output. The channel is formed by adding and subtracting a filtered measure of true range (volatility) around the central filter line.

The channel turns green when the filter is rising (uptrend) and red when it is falling (downtrend). A separate 200-day simple moving average acts as a bull/bear regime switch: the strategy only trades when price is above it.

Entry

A long position is opened when all five conditions are true simultaneously:

[*] The channel is green (filter rising — uptrend confirmed)
[*] Price closes above the upper band (breakout above the channel; an optional buffer above the band can require more room, but testing found this counterproductive — see Parameters)
[*] Stochastic RSI %K is either above 80 (strong momentum confirming the breakout) or below 25 (oversold dip within the uptrend)
[*] Price is above the 200-day SMA (bull regime — can be disabled)
[*] The signal bar itself closes above its own open — a bullish candle (can be disabled)

The bullish-candle check filters out breakout bars that clear the upper band intrabar but still close weak — a common precursor to an immediate whipsaw exit on the next bar.

The 200-day SMA gate exists specifically to block breakout entries that fire during bear-market bounces — dead-cat rallies that look like trend resumption on the channel and oscillator alone but occur underneath a still-falling long-term average.

Exit

The position is closed when either:

[*] Price closes back below the upper band (breakout has failed or the trend is cooling), or
[*] The channel reverses from green to red (trend direction has flipped)

An optional stop-loss (on by default) is placed at the lower band and trails as the channel moves, providing a floor on losses if price drops sharply through both the upper and lower bands in the same move. The regime gate only blocks new entries — it does not force an exit on its own if price falls back below the 200-SMA mid-trade.

Parameters

[*] Poles: 4 (filter smoothness — higher = smoother but more lag)
[*] Sampling Period: 89 (faster channel than the baseline version, reacts sooner to trend changes)
[*] True Range Multiplier: 1.5 (controls channel width)
[*] Stochastic RSI overbought threshold: 80
[*] Stochastic RSI oversold threshold: 25 (a parameter sweep found a stable plateau from 22-28; 25 sits at its center rather than its single best value)
[*] 200-SMA regime gate: on by default, can be disabled; length is adjustable
[*] Bullish entry candle requirement: on by default, can be disabled
[*] Entry breakout buffer: 0% (off) by default; tested at multiple levels above 0% and found to reduce returns at every level, so left disabled
[*] Stop-loss at lower band: on by default, can be disabled
[*] Start/End date range inputs let you restrict the backtest window without editing code

Costs modelled

0.1% commission per side, 3 ticks slippage, fills at next bar's open.

Intended assets and timeframe

Daily bars. Designed and validated on ETH/USDT. Likely applicable to other trending crypto assets; not validated on equities.

Known limitations

Underperforms in choppy or ranging markets — the upper band breakout condition generates whipsaws when price oscillates without directional conviction. The regime gate is a trade-off: it blocks bear-bounce false starts, but it also means the strategy can miss the first leg of a genuine new uptrend until price reclaims the 200-day SMA. The filter requires several hundred bars of history to fully converge; results on very short histories may differ from the validated backtest. The strategy trades infrequently (around 28 trades on the validated window), so treat any single backtest run as a small sample rather than a statistically strong result.

Credit

The Gaussian Channel filter is from the open-source "Gaussian Channel (DW)" indicator by DonovanWall. This script reuses that filter and adds the Stochastic RSI entry filter, the 200-day SMA regime gate, exit rules, stop-loss, and full strategy order management on top of it.

---

## Source Code

````pine
//@version=6
// Author: cs_lev
// Strategy: Gaussian Channel + StochRSI — ETH-edition (faster channel + 200-day SMA regime gate)
// Hypothesis: A faster Gaussian channel (period 89) catches trend entries/exits earlier, while a
//             200-day SMA bull/bear gate blocks the breakout entries that fire during bear-market
//             bounces — the failure mode that wrecked the slow baseline on ETH/SOL in 2022.
// Assumed regime: trending uptrend confirmed by price > 200-day SMA; sits out confirmed downtrends
// Timeframe: 1D (designed and tested on daily bars)
// Best asset: ETH/USDT.

strategy(title="TRADLEWARE-Gaussian Channel ETH", overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     commission_type=strategy.commission.percent,
     commission_value=0.1,
     slippage=3,
     pyramiding=0,
     calc_on_every_tick=false,
     process_orders_on_close=false)

//===================================================================================================================================================================
// DonovanWall's Gaussian Channel indicator — functions, inputs, definitions, and
// outputs below are his original work, unmodified. Nothing added for this strategy
// appears until the "End of DonovanWall's indicator" marker further down.
//===================================================================================================================================================================

f_filt9x (_a, _s, _i) =>
    int _m2 = 0, int _m3 = 0, int _m4 = 0, int _m5 = 0, int _m6 = 0,
    int _m7 = 0, int _m8 = 0, int _m9 = 0, float _f = .0, _x = (1 - _a)
    _m2 := _i == 9 ? 36  : _i == 8 ? 28 : _i == 7 ? 21 : _i == 6 ? 15 : _i == 5 ? 10 : _i == 4 ? 6 : _i == 3 ? 3 : _i == 2 ? 1 : 0
    _m3 := _i == 9 ? 84  : _i == 8 ? 56 : _i == 7 ? 35 : _i == 6 ? 20 : _i == 5 ? 10 : _i == 4 ? 4 : _i == 3 ? 1 : 0
    _m4 := _i == 9 ? 126 : _i == 8 ? 70 : _i == 7 ? 35 : _i == 6 ? 15 : _i == 5 ? 5  : _i == 4 ? 1 : 0
    _m5 := _i == 9 ? 126 : _i == 8 ? 56 : _i == 7 ? 21 : _i == 6 ? 6  : _i == 5 ? 1  : 0
    _m6 := _i == 9 ? 84  : _i == 8 ? 28 : _i == 7 ? 7  : _i == 6 ? 1  : 0
    _m7 := _i == 9 ? 36  : _i == 8 ? 8  : _i == 7 ? 1  : 0
    _m8 := _i == 9 ? 9   : _i == 8 ? 1  : 0
    _m9 := _i == 9 ? 1   : 0
    _f :=   math.pow(_a, _i) * nz(_s) +
      _i  *     _x      * nz(_f[1])      - (_i >= 2 ?
      _m2 * math.pow(_x, 2)  * nz(_f[2]) : 0) + (_i >= 3 ?
      _m3 * math.pow(_x, 3)  * nz(_f[3]) : 0) - (_i >= 4 ?
      _m4 * math.pow(_x, 4)  * nz(_f[4]) : 0) + (_i >= 5 ?
      _m5 * math.pow(_x, 5)  * nz(_f[5]) : 0) - (_i >= 6 ?
      _m6 * math.pow(_x, 6)  * nz(_f[6]) : 0) + (_i >= 7 ?
      _m7 * math.pow(_x, 7)  * nz(_f[7]) : 0) - (_i >= 8 ?
      _m8 * math.pow(_x, 8)  * nz(_f[8]) : 0) + (_i == 9 ?
      _m9 * math.pow(_x, 9)  * nz(_f[9]) : 0)

f_pole (_a, _s, _i) =>
    _f1 =            f_filt9x(_a, _s, 1),      _f2 = (_i >= 2 ? f_filt9x(_a, _s, 2) : 0), _f3 = (_i >= 3 ? f_filt9x(_a, _s, 3) : 0)
    _f4 = (_i >= 4 ? f_filt9x(_a, _s, 4) : 0), _f5 = (_i >= 5 ? f_filt9x(_a, _s, 5) : 0), _f6 = (_i >= 6 ? f_filt9x(_a, _s, 6) : 0)
    _f7 = (_i >= 7 ? f_filt9x(_a, _s, 7) : 0), _f8 = (_i >= 8 ? f_filt9x(_a, _s, 8) : 0), _f9 = (_i == 9 ? f_filt9x(_a, _s, 9) : 0)
    _fn = _i == 1 ? _f1 : _i == 2 ? _f2 : _i == 3 ? _f3 :
      _i == 4     ? _f4 : _i == 5 ? _f5 : _i == 6 ? _f6 :
      _i == 7     ? _f7 : _i == 8 ? _f8 : _i == 9 ? _f9 : na
    [_fn, _f1]

src = input(defval=hlc3, title="Source")
int N        = input.int(defval=4, title="Poles", minval=1, maxval=9)
int per      = input.int(defval=89, title="Sampling Period", minval=2)           // v7: faster channel (was 144)
float mult   = input.float(defval=1.5, title="Filtered True Range Multiplier", minval=0)  // v7: 1.5 (was 1.414)
bool modeLag  = input.bool(defval=false, title="Reduced Lag Mode")
bool modeFast = input.bool(defval=false, title="Fast Response Mode")

beta  = (1 - math.cos(4*math.asin(1)/per)) / (math.pow(1.414, 2/N) - 1)
alpha = - beta + math.sqrt(math.pow(beta, 2) + 2*beta)
lag = (per - 1)/(2*N)

srcdata = modeLag ? src + (src - src[lag]) : src
trdata  = modeLag ? ta.tr(true) + (ta.tr(true) - ta.tr(true)[lag]) : ta.tr(true)

[filtn, filt1]     = f_pole(alpha, srcdata, N)
[filtntr, filt1tr] = f_pole(alpha, trdata,  N)

filt   = modeFast ? (filtn + filt1)/2 : filtn
filttr = modeFast ? (filtntr + filt1tr)/2 : filtntr

hband = filt + filttr*mult
lband = filt - filttr*mult

fcolor = filt > filt[1] ? #0aff68 : filt < filt[1] ? #ff0a5a : #cccccc

filtplot = plot(filt, title="Filter", color=fcolor, linewidth=3)
hbandplot = plot(hband, title="Filtered True Range High Band", color=fcolor)
lbandplot = plot(lband, title="Filtered True Range Low Band", color=fcolor)
fill(hbandplot, lbandplot, title="Channel Fill", color=color.new(fcolor, 80))

//===================================================================================================================================================================
// End of DonovanWall's indicator. Everything below is original to this strategy —
// added on top of his channel, not part of it.
//===================================================================================================================================================================

// Date range filter — integer year/month/day fields instead of input.time(), which
// does not reliably trigger a recalculation in TradingView. Set these to match the
// --since / --until dates used in the Python backtest.
startYear  = input.int(2020, "Start year",  minval=2000, maxval=2099, group="Date Range")
startMonth = input.int(1,    "Start month", minval=1,    maxval=12,   group="Date Range")
startDay   = input.int(1,    "Start day",   minval=1,    maxval=31,   group="Date Range")
endYear    = input.int(2099, "End year",    minval=2000, maxval=2099, group="Date Range")
endMonth   = input.int(12,   "End month",   minval=1,    maxval=12,   group="Date Range")
endDay     = input.int(31,   "End day",     minval=1,    maxval=31,   group="Date Range")
timeCondition = time >= timestamp(startYear, startMonth, startDay, 0, 0) and time <= timestamp(endYear, endMonth, endDay, 23, 59)

// Stochastic RSI entry filter — inputs
stochLength = input.int(14, "Stochastic Length", minval=1, group="Stochastic RSI")
rsiLength = input.int(14, "RSI Length", minval=1, group="Stochastic RSI")
stochK = input.int(3, "Stochastic %K Smoothing", minval=1, group="Stochastic RSI")
stochD = input.int(3, "Stochastic %D Smoothing", minval=1, group="Stochastic RSI")
rsiUpperThreshold = input.float(80, "RSI Upper Threshold (Overbought)", minval=0, maxval=100, group="Stochastic RSI")
rsiLowerThreshold = input.float(25, "RSI Lower Threshold (Oversold)", minval=0, maxval=100, group="Stochastic RSI")  // sensitivity-swept 20-29: plateau 22-28 (~1600-1650% vs 1393% at 20-21), decays past 29 — 25 is the plateau's center, not its peak

// Regime filter — the key v7 addition — inputs
useRegime   = input.bool(defval=true, title="Enable 200-SMA bull-market gate", group="Regime Filter",
     tooltip="Only take entries when close > 200-day SMA. Blocks bear-market-bounce breakouts — the failure mode that wrecked the slow baseline on ETH/SOL in 2022.")
smaLength   = input.int(200, "Regime SMA length", minval=2, group="Regime Filter")

// Entry filter — candle confirmation
useBullishCandle = input.bool(defval=true, title="Require bullish (green) entry candle", group="Entry Filter",
     tooltip="Only enter when the signal bar's close is above its own open. Filters breakout bars that clear the upper band but still close weak — a common precursor to an immediate whipsaw exit.")

// Entry filter — breakout buffer. Tested every value above 0%: monotonically worse
// (the strategy's edge apparently lives partly in the marginal breakouts). Defaulted
// off; left as an input in case it's worth revisiting later.
breakoutBufferPct = input.float(defval=0.0, title="Entry breakout buffer above upper band (%)", minval=0, maxval=50, step=0.5, group="Entry Filter",
     tooltip="Require the close to clear the upper band by at least this percentage before entering, instead of any close just above the band. Tested and found counterproductive at every level above 0% — left available for further testing, not recommended.")

// Risk management
useStopLoss = input.bool(defval=true, title="Enable Stop-Loss at Lower Band", group="Stop Loss")

// Stochastic RSI entry filter — calculation
rsi1 = ta.rsi(close, rsiLength)
stochRSI = ta.stoch(rsi1, rsi1, rsi1, stochLength)
k = ta.sma(stochRSI, stochK)
d = ta.sma(k, stochD)

// Regime filter — calculation
sma200 = ta.sma(close, smaLength)
bullRegime = not useRegime or close > sma200

// Entry filter — calculation
bullishCandle = not useBullishCandle or close > open
breakoutThreshold = hband * (1 + breakoutBufferPct / 100)

// Regime filter — output (not part of DonovanWall's channel plots above)
plot(useRegime ? sma200 : na, title="200 SMA (regime gate)",
     color=close > sma200 ? color.new(#FFB300, 30) : color.new(#FF6D00, 0), linewidth=2)

// Entry filter — output: the buffered breakout line, when different from the raw upper band
plot(breakoutBufferPct > 0 ? breakoutThreshold : na, title="Entry threshold (band + buffer)",
     color=color.new(#2962FF, 20), linewidth=1)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Trading Logic
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

channelGreen = filt > filt[1]

// Entry: channel green, close clears the upper band by the buffer %, Stoch RSI extreme,
// price in a bull regime (> 200-SMA), AND the signal bar itself closes green
longCondition = channelGreen and close > breakoutThreshold and (k > rsiUpperThreshold or k < rsiLowerThreshold) and bullRegime and bullishCandle and timeCondition

// Exit: close below high band OR channel reverses
closeCondition = (close < hband or filt < filt[1]) and timeCondition

if longCondition and strategy.position_size == 0
    strategy.entry("Long", strategy.long)

if closeCondition and strategy.position_size > 0
    strategy.close("Long")

if useStopLoss and strategy.position_size > 0
    strategy.exit("StopLoss", from_entry="Long", stop=lband)

positionJustOpened = strategy.position_size > 0 and strategy.position_size[1] == 0
positionJustClosed = strategy.position_size == 0 and strategy.position_size[1] > 0

if positionJustOpened
    label.new(bar_index, low - filttr * 4,
              "BUY @ " + str.tostring(open, format.mintick),
              color=color.new(color.green, 20), textcolor=color.white,
              style=label.style_label_up, size=size.small)

if positionJustClosed
    lastTrade  = strategy.closedtrades - 1
    entryPx    = strategy.closedtrades.entry_price(lastTrade)
    exitPx     = strategy.closedtrades.exit_price(lastTrade)
    pnlPct     = (exitPx - entryPx) / entryPx * 100
    pnlStr     = (pnlPct >= 0 ? "+" : "") + str.tostring(math.round(pnlPct, 2)) + "%"
    label.new(bar_index, high + filttr * 4,
              "SELL @ " + str.tostring(exitPx, format.mintick) + "\nP&L: " + pnlStr,
              color=color.new(color.red, 20), textcolor=color.white,
              style=label.style_label_down, size=size.small)
````
