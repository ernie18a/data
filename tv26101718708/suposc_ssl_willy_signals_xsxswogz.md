# SupOsc + SSL + Willy Signals

- url: https://www.tradingview.com/script/xsXsWogz-SupOsc-SSL-Willy-Signals/
- type: indicator
- pine_id: PUB;e9e82c99d76f4c59b32b95de95aae60f
- version: 1.0

## Description

What It Does

This is a confluence signal indicator that combines three separate technical indicators and only fires a buy or sell signal when all three agree simultaneously. The idea is to reduce false signals by requiring multiple independent conditions to align before triggering an entry. It plots simple B (buy) and S (sell) labels directly on your chart.

The Three Indicators
1. SuperTrend Oscillator (SupOsc)
A normalized oscillator built from a SuperTrend calculation. Rather than plotting the SuperTrend line itself, it measures how far price is from the SuperTrend bands and converts that into an oscillator value between -1 and +1. A smoothed EMA histogram runs underneath it. For signals, it watches for the oscillator crossing the -0.50 level upward (buy) or crossing the +0.50 level downward (sell). Think of it as a momentum/trend confirmation filter.
2. SSL Channel
A simple but effective trend direction tool that uses SMAs of the highs and lows to determine whether price is in a bullish or bearish regime. When the upper SSL line is above the lower line, it's bullish. When below, it's bearish. The signal requires SSL to be confirming the same direction as the SupOsc before anything fires.
3. Williams %R
A momentum oscillator that measures where price closed relative to its recent high-low range, on a scale of 0 to -100. The indicator checks the previous candle's Williams %R reading — requiring it to have been in oversold territory (below -80) for buys, or overbought territory (above -20) for sells. This acts as a pullback/exhaustion filter, helping you buy dips and sell rips rather than chasing.

Does It Repaint?
Largely no, but with one caveat to be aware of.
The SupOsc and Williams %R components are calculated purely on current timeframe bars using standard closed-bar data — no repainting there.
The SSL component uses request.security() with lookahead=barmerge.lookahead_off, which is the correct, repaint-safe setting. However, if you set the SSL Timeframe to a higher timeframe than your chart, the SSL values will only update when that higher timeframe bar closes — meaning mid-bar the value reflects the previous completed HTF bar, which is standard and expected behavior, not true repainting.
The Williams %R check also looks at wR[1] (the previous bar's value), which is already a closed bar — safe.
Bottom line: Signals that appear on a closed bar will not disappear or move. Signals on the current live bar could technically shift if conditions change before the bar closes, which is true of virtually any indicator.

Personally I find it works best for confirmations when combined with the CCI as seen in the image below.
[image]https://www.tradingview.com/x/v6Tv0s5H/[/image]

## Source Code

````pine
//@version=6
indicator("SupOsc + SSL + Willy Signals", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────

// SuperTrend Oscillator Inputs
st_length = input.int(10, "SuperOsc Length", minval=1, group="SuperTrend Oscillator")
st_mult   = input.float(2.0, "SuperOsc Multiplier", minval=0.1, step=0.1, group="SuperTrend Oscillator")
st_smooth = input.int(72, "SuperOsc Smooth", minval=1, group="SuperTrend Oscillator")

// SSL Inputs
ssl_len = input.int(2, "SSL Period", minval=1, group="SSL Channel")
ssl_tf  = input.timeframe("", "SSL Timeframe", group="SSL Channel")

// Williams %R Inputs
willy_len     = input.int(21, "Willy Length", minval=1, group="Williams %R")
willy_ema_len = input.int(13, "Willy EMA Length", minval=1, group="Williams %R")

// ─────────────────────────────────────────
// SUPERTREND OSCILLATOR
// ─────────────────────────────────────────
src = close
atr_val = ta.atr(st_length) * st_mult

var float upper_band = na
var float lower_band = na
var int   trend_dir  = 0

up_raw = hl2 + atr_val
dn_raw = hl2 - atr_val

upper_band := nz(src[1]) < nz(upper_band[1]) ? math.min(up_raw, nz(upper_band[1])) : up_raw
lower_band := nz(src[1]) > nz(lower_band[1]) ? math.max(dn_raw, nz(lower_band[1])) : dn_raw
trend_dir  := src > nz(upper_band[1]) ? 1 : src < nz(lower_band[1]) ? 0 : nz(trend_dir[1])

Spt = trend_dir * lower_band + (1 - trend_dir) * upper_band

var float ama = na
osc   = math.max(math.min((src - Spt) / (upper_band - lower_band), 1.0), -1.0)
alpha = math.pow(osc, 2) / st_length
ama  := na(ama[1]) ? osc : ama[1] + alpha * (osc - ama[1])
hist  = ta.ema(osc - ama, st_smooth)

// SuperOsc Buy/Sell signals
suposc_buy  = osc > -0.50 and osc[1] <= -0.50
suposc_sell = osc <  0.50 and osc[1] >=  0.50

// ─────────────────────────────────────────
// SSL CHANNEL
// ─────────────────────────────────────────
_tf = ssl_tf == "" ? timeframe.period : ssl_tf

smaHigh    = request.security(syminfo.tickerid, _tf, ta.sma(high, ssl_len), lookahead=barmerge.lookahead_off)
smaLow     = request.security(syminfo.tickerid, _tf, ta.sma(low,  ssl_len), lookahead=barmerge.lookahead_off)
closeVal   = request.security(syminfo.tickerid, _tf, close,                 lookahead=barmerge.lookahead_off)

var int Hlv = na
Hlv := closeVal > smaHigh ? 1 : closeVal < smaLow ? -1 : nz(Hlv[1])

sslUp   = Hlv < 0 ? smaLow  : smaHigh
sslDown = Hlv < 0 ? smaHigh : smaLow

ssl_bull = sslUp > sslDown
ssl_bear = sslUp < sslDown

// ─────────────────────────────────────────
// WILLIAMS %R
// ─────────────────────────────────────────
w_upper = ta.highest(willy_len)
w_lower = ta.lowest(willy_len)
wR      = 100 * (close - w_upper) / (w_upper - w_lower)
wEma    = ta.ema(wR, willy_ema_len)

// Previous candle conditions
willy_was_oversold    = wR[1] < -80
willy_was_overbought  = wR[1] > -20

// ─────────────────────────────────────────
// COMBINED SIGNALS
// ─────────────────────────────────────────
buy_signal  = suposc_buy  and ssl_bull and willy_was_oversold
sell_signal = suposc_sell and ssl_bear and willy_was_overbought

// ─────────────────────────────────────────
// PLOTS (signals only, no indicator visuals)
// ─────────────────────────────────────────
plotshape(buy_signal,  title="Buy Signal",  style=shape.labelup,   location=location.belowbar, color=color.new(#0cb51a, 0), textcolor=color.white, text="B", size=size.small)
plotshape(sell_signal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.new(#ff1100, 0), textcolor=color.white, text="S", size=size.small)

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(buy_signal,  title="Buy Alert",  message="BUY Signal: SupOsc + SSL Bull + Willy Oversold — {{ticker}} {{interval}}")
alertcondition(sell_signal, title="Sell Alert", message="SELL Signal: SupOsc + SSL Bear + Willy Overbought — {{ticker}} {{interval}}")
alertcondition(buy_signal or sell_signal, title="Buy or Sell Alert", message="BUY or SELL Signal fired — {{ticker}} {{interval}}")
````
