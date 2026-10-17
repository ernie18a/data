# NL LBR 3-10 Oscillator

- url: https://www.tradingview.com/script/cRejAecQ-NL-LBR-3-10-Oscillator/
- type: indicator
- pine_id: PUB;2d8ec0053668416a948d0f2a65df5083
- version: 1.0

## Description

LBR 3-10 Oscillator with Divergence & Convergence
The LBR 3-10 Oscillator is a momentum indicator developed by Linda Bradford Raschke. It measures the difference between a 3-period and 10-period moving average, smoothed by a 16-period signal line — functionally similar to MACD but tuned for shorter-term momentum cycles. It is particularly effective for identifying trend direction, pullback entries, and momentum exhaustion.

Oscillator

Fast MA (default 3) minus Slow MA (default 10), plotted as both a line and histogram
Signal line smoothing (default 16) displayed as an overlay
Optional volatility normalization via ATR to compare momentum across instruments and timeframes
Optional standard deviation bands to identify statistically extended readings
Choice of SMA or EMA for both the oscillator and signal line


Divergence & Convergence
Lines are drawn directly on the oscillator pane connecting MACD pivot points — no cluttered price chart markings.
🟢 Bullish Divergence (solid green) — Price makes a lower low while the oscillator makes a higher low. Classic reversal signal indicating selling momentum is fading.
🔴 Bearish Divergence (solid red) — Price makes a higher high while the oscillator makes a lower high. Momentum is fading into the new high, warning of a potential reversal.
🟢 Bullish Convergence (dashed green) — Price makes a higher low while the oscillator makes a lower low. Hidden bullish signal confirming trend continuation to the upside.
🔴 Bearish Convergence (dashed red) — Price makes a lower high while the oscillator makes a higher high. Hidden bearish signal confirming trend continuation to the downside.
Each divergence and convergence type can be toggled on or off independently. Pivot lookback is fully adjustable to control signal sensitivity.

Alerts
All signals support TradingView alerts:

Trend change up / down
Pullback in uptrend / downtrend
First cross in uptrend / downtrend
Bullish / Bearish Divergence
Bullish / Bearish Convergence

## Source Code

````pine
//@version=6

indicator(title='LBR 3-10 Oscillator', shorttitle='LBR 3-10')

// === INPUTS ===
fast_length           = input(3,     'Fast Length')
slow_length           = input(10,    'Slow Length')
src                   = input(close, 'Source')
stdev_mult            = input(1.5,   'St. dev.')
stdev_length          = input(100,   'St. dev. length')
signal_length         = input.int(16,'Signal Smoothing', minval=1, maxval=50)
sma_source            = input(true,  'Simple MA(Oscillator)')
sma_signal            = input(true,  'Simple MA(Signal Line)')
show_std_bands        = input(false, 'Show std. bands')
volatility_normalized = input(false, 'Volatility normalized')

// === DIVERGENCE INPUTS ===
show_bull_div  = input(true, 'Show Bullish Divergence',  group='Divergence / Convergence')
show_bear_div  = input(true, 'Show Bearish Divergence',  group='Divergence / Convergence')
show_bull_conv = input(true, 'Show Bullish Convergence', group='Divergence / Convergence')
show_bear_conv = input(true, 'Show Bearish Convergence', group='Divergence / Convergence')
div_lookback   = input.int(5,'Pivot Lookback', minval=2, maxval=20, group='Divergence / Convergence')

// === CORE CALCULATION ===
fast_ma = sma_source ? ta.sma(src, fast_length) : ta.ema(src, fast_length)
slow_ma = sma_source ? ta.sma(src, slow_length) : ta.ema(src, slow_length)

macd   = volatility_normalized ? ((fast_ma - slow_ma) / ta.atr(slow_length)) * 100.0 : (fast_ma - slow_ma)
signal = sma_signal ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length)

// === PLOTS ===
plot(macd,   'MACD Line',      color=color.new(#42A5F5, 0))
plot(macd,   'MACD Histogram', color=color.new(#42A5F5, 0), style=plot.style_histogram, linewidth=1)
plot(signal, 'Signal',         color=color.new(#E57373, 0))
hline(0, 'Zero line', color=color.gray, linestyle=hline.style_dotted)

plot(show_std_bands ?  stdev_mult * ta.stdev(macd, stdev_length) : na, color=color.new(color.gray, 0), style=plot.style_cross)
plot(show_std_bands ? -stdev_mult * ta.stdev(macd, stdev_length) : na, color=color.new(color.gray, 0), style=plot.style_cross)

// === PIVOT DETECTION ===
// pivothigh/low confirm div_lookback bars after the actual swing bar
float price_ph = ta.pivothigh(src,  div_lookback, div_lookback)
float price_pl = ta.pivotlow (src,  div_lookback, div_lookback)
float macd_ph  = ta.pivothigh(macd, div_lookback, div_lookback)
float macd_pl  = ta.pivotlow (macd, div_lookback, div_lookback)

// === PIVOT STATE (two most recent highs and lows) ===
var int   ph_bar1 = 0
var int   ph_bar2 = 0
var float ph_val1 = 0.0
var float ph_val2 = 0.0
var float mh_val1 = 0.0
var float mh_val2 = 0.0
var bool  ph_has2 = false

var int   pl_bar1 = 0
var int   pl_bar2 = 0
var float pl_val1 = 0.0
var float pl_val2 = 0.0
var float ml_val1 = 0.0
var float ml_val2 = 0.0
var bool  pl_has2 = false

// Rotate on each new confirmed pivot high
if not na(price_ph) and not na(macd_ph)
    ph_bar2  := ph_bar1
    ph_val2  := ph_val1
    mh_val2  := mh_val1
    ph_bar1  := bar_index - div_lookback
    ph_val1  := price_ph
    mh_val1  := macd_ph
    ph_has2  := ph_bar2 != 0

// Rotate on each new confirmed pivot low
if not na(price_pl) and not na(macd_pl)
    pl_bar2  := pl_bar1
    pl_val2  := pl_val1
    ml_val2  := ml_val1
    pl_bar1  := bar_index - div_lookback
    pl_val1  := price_pl
    ml_val1  := macd_pl
    pl_has2  := pl_bar2 != 0

// === DIVERGENCE CONDITIONS ===
// Bearish divergence  : price HH + macd LH  (momentum fading on new high)
bool bear_div  = not na(price_ph) and not na(macd_ph) and ph_has2 and ph_val1 > ph_val2 and mh_val1 < mh_val2
// Bullish divergence  : price LL + macd HL  (momentum fading on new low)
bool bull_div  = not na(price_pl) and not na(macd_pl) and pl_has2 and pl_val1 < pl_val2 and ml_val1 > ml_val2
// Bearish convergence : price LH + macd HH  (hidden bearish, trend continuation down)
bool bear_conv = not na(price_ph) and not na(macd_ph) and ph_has2 and ph_val1 < ph_val2 and mh_val1 > mh_val2
// Bullish convergence : price HL + macd LL  (hidden bullish, trend continuation up)
bool bull_conv = not na(price_pl) and not na(macd_pl) and pl_has2 and pl_val1 > pl_val2 and ml_val1 < ml_val2

// === DRAW LINES ON LBR PANE ===
if show_bear_div and bear_div
    line.new(ph_bar2, mh_val2, ph_bar1, mh_val1, color=color.red,   width=2, style=line.style_solid)

if show_bull_div and bull_div
    line.new(pl_bar2, ml_val2, pl_bar1, ml_val1, color=color.green, width=2, style=line.style_solid)

if show_bear_conv and bear_conv
    line.new(ph_bar2, mh_val2, ph_bar1, mh_val1, color=color.red,   width=2, style=line.style_dashed)

if show_bull_conv and bull_conv
    line.new(pl_bar2, ml_val2, pl_bar1, ml_val1, color=color.green, width=2, style=line.style_dashed)

// === EXISTING ALERTS ===
bool trendChangeUp       = ta.crossover(signal, 0)
bool trendChangeDown     = ta.crossunder(signal, 0)
bool pullbackInUptrend   = signal > 0 and ta.crossunder(macd, signal)
bool pullbackInDowntrend = signal < 0 and ta.crossover(macd, signal)
bool uptrendFirstCross   = pullbackInUptrend   and ta.barssince(ta.crossover(signal,  0)) < ta.barssince(ta.crossunder(macd[1], signal[1]))
bool downtrendFirstCross = pullbackInDowntrend and ta.barssince(ta.crossunder(signal, 0)) < ta.barssince(ta.crossover(macd[1],  signal[1]))

alertcondition(trendChangeUp,       'Trend change up',       'Trend change up')
alertcondition(trendChangeDown,     'Trend change down',     'Trend change down')
alertcondition(pullbackInUptrend,   'Pullback in uptrend',   'Pullback in uptrend')
alertcondition(pullbackInDowntrend, 'Pullback in downtrend', 'Pullback in downtrend')
alertcondition(uptrendFirstCross,   'First cross uptrend',   'First cross uptrend')
alertcondition(downtrendFirstCross, 'First cross downtrend', 'First cross downtrend')

// === DIVERGENCE ALERTS ===
alertcondition(bull_div,  'Bullish Divergence',  'LBR 3-10: Bullish Divergence')
alertcondition(bear_div,  'Bearish Divergence',  'LBR 3-10: Bearish Divergence')
alertcondition(bull_conv, 'Bullish Convergence', 'LBR 3-10: Bullish Convergence')
alertcondition(bear_conv, 'Bearish Convergence', 'LBR 3-10: Bearish Convergence')
````
