# ICC - SCI

- url: https://www.tradingview.com/script/wgLedtxp-ICC-SCI/
- type: indicator
- pine_id: PUB;45693c8dcf0c4d208ffb710ad64ed786
- version: 1.0

## Description

ICC - SCI
Indication. Correction. Continuation.
This indicator is built on the ICC trading method — a trend-based price action strategy designed to capture high-probability trend continuations by identifying institutional momentum.
The script tracks three market phases:

Indication — a higher high or lower low signals institutional direction
Correction — price pulls back to the indication level (no trade yet)
Continuation — price reclaims the indication level, confirming the trend

Signals displayed directly on the chart:

🟢 BUY — bullish continuation confirmed
🔴 SELL — bearish continuation confirmed
⚫ EXIT — structure break or reversal candle detected

Volume confirmation — a yellow dot appears on BUY/SELL signals when volume is significantly above average, highlighting the highest probability setups.
Built for futures traders on the 5m and 15m timeframe, using the 4H/1H for overall market structure.

## Source Code

````pine
//@version=6
indicator("ICC - SCI", overlay=true)

swing_length = input.int(10, "Swing Length", minval=5, maxval=50)

swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low  = ta.pivotlow(low,  swing_length, swing_length)

var float last_swing_high = na
var float last_swing_low  = na

if not na(swing_high)
    last_swing_high := swing_high
if not na(swing_low)
    last_swing_low := swing_low

higher_high = not na(last_swing_high) and not na(swing_high) and swing_high > last_swing_high
lower_low   = not na(last_swing_low)  and not na(swing_low)  and swing_low  < last_swing_low

bullish_indication = not na(swing_high) and higher_high
bearish_indication = not na(swing_low)  and lower_low

var string indication_type     = na
var float  indication_level    = na
var bool   indication_detected = false
var bool   correction_phase    = false

if bullish_indication and not indication_detected
    indication_detected := true
    indication_level    := swing_high
    indication_type     := "bullish"
    correction_phase    := false

if bearish_indication and not indication_detected
    indication_detected := true
    indication_level    := swing_low
    indication_type     := "bearish"
    correction_phase    := false

if indication_detected and not correction_phase
    if indication_type == "bullish" and close < indication_level
        correction_phase := true
    if indication_type == "bearish" and close > indication_level
        correction_phase := true

buy_signal  = indication_detected and correction_phase and indication_type == "bullish" and close > indication_level and close[1] <= indication_level
sell_signal = indication_detected and correction_phase and indication_type == "bearish" and close < indication_level and close[1] >= indication_level

if indication_detected
    if indication_type == "bullish" and close < indication_level * 0.98
        indication_detected := false
        correction_phase    := false
    if indication_type == "bearish" and close > indication_level * 1.02
        indication_detected := false
        correction_phase    := false

avg_vol  = ta.sma(volume, 20)
is_spike = volume >= avg_vol * 1.8

candle_body  = math.abs(close - open)
candle_range = high - low
upper_wick   = high - math.max(close, open)
lower_wick   = math.min(close, open) - low
bear_reversal = candle_range > 0 and (upper_wick >= candle_range * 0.6 or (close < open and close[1] > open[1] and candle_body > math.abs(close[1] - open[1])))
bull_reversal = candle_range > 0 and (lower_wick >= candle_range * 0.6 or (close > open and close[1] < open[1] and candle_body > math.abs(close[1] - open[1])))

var string trade_dir = "none"
if buy_signal
    trade_dir := "long"
if sell_signal
    trade_dir := "short"

exit_long  = trade_dir == "long"  and (not na(last_swing_low)  and close < last_swing_low  or bear_reversal)
exit_short = trade_dir == "short" and (not na(last_swing_high) and close > last_swing_high or bull_reversal)

if exit_long or exit_short
    trade_dir := "none"

plotshape(buy_signal,  title="BUY",  location=location.abovebar, style=shape.labeldown, color=color.green, textcolor=color.white, text="BUY",  size=size.large)
plotshape(sell_signal, title="SELL", location=location.abovebar, style=shape.labeldown, color=color.red,   textcolor=color.white, text="SELL", size=size.large)
plotshape(exit_long or exit_short,   title="EXIT", location=location.abovebar, style=shape.labeldown, color=color.gray, textcolor=color.white, text="EXIT", size=size.normal)

plotshape(buy_signal  and is_spike, title="Vol Bull", location=location.abovebar, style=shape.circle, color=color.yellow, size=size.tiny)
plotshape(sell_signal and is_spike, title="Vol Bear", location=location.abovebar, style=shape.circle, color=color.yellow, size=size.tiny)

alertcondition(buy_signal,               title="ICC BUY",             message="ICC BUY signal")
alertcondition(sell_signal,              title="ICC SELL",            message="ICC SELL signal")
alertcondition(buy_signal  and is_spike, title="ICC BUY + Vol Spike", message="ICC BUY — Strong volume confirmation")
alertcondition(sell_signal and is_spike, title="ICC SELL + Vol Spike",message="ICC SELL — Strong volume confirmation")
alertcondition(exit_long,                title="ICC EXIT Long",       message="ICC EXIT — Close your long")
alertcondition(exit_short,               title="ICC EXIT Short",      message="ICC EXIT — Close your short")
````
