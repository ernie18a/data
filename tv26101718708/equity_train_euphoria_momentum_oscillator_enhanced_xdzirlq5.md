# Equity Train Euphoria- Momentum Oscillator Enhanced

- url: https://www.tradingview.com/script/XdZiRLq5-Equity-Train-Euphoria-Momentum-Oscillator-Enhanced/
- type: indicator
- pine_id: PUB;cd9f4e5ac2954dfba48eb9e8ed8f8445
- version: 1.0

## Description

Equity Train Euphoria — Momentum Oscillator Enhanced
 is a sentiment-driven momentum oscillator designed to help identify elevated market fear, euphoria, momentum shifts, and potential exhaustion points. It builds on publicly available open-source oscillator concepts with custom enhancements to sentiment readings, velocity metrics, extreme-zone detection, and visual warning stages.

[b]How it works[/b]
The oscillator measures how far price is stretched from its smoothed average, normalized by recent volatility, then smoothed into a single momentum line. The line changes color with direction (lime = rising, red = falling), giving an at-a-glance read on momentum. Gradient heat zones above the overbought level and below the oversold level intensify as the oscillator pushes deeper into extremes, visually representing escalating euphoria or fear.
Key features

Sentiment dashboard — A live table displays the current sentiment stage (Neutral → Greed → Very Greedy → Extreme Greed, and the mirrored fear stages), the oscillator value, and trend direction.
Signal confirmations — Buy signals fire on oscillator/signal crossovers in oversold territory; sell signals fire on crossunders in overbought territory. Optional "Strict Extreme Confirm" requires both the oscillator and signal line to be beyond the threshold.
Pinpoint Mode (divergence confirm) — When enabled, buy/sell confirmations additionally require a regular bullish or bearish divergence between price pivots and oscillator pivots near the extremes, filtering out weaker signals.
Yellow Euphoria Entry — Marks the moment the oscillator first crosses into overbought territory, highlighting early-stage euphoria before a potential exhaustion signal forms.
Adaptive Extremes — Optionally auto-calibrates the overbought/oversold thresholds using rolling percentiles of the oscillator itself, so levels adjust to each symbol's and timeframe's behavior instead of using fixed values.
Turn signals in extremes — Green/red dots and background highlights mark direction flips that occur while the oscillator is in fear or greed zones — often areas of interest for reversals.
Amplification factor — Scales the oscillator and all levels together for visual tuning without changing signal logic.
Bar coloring & alerts — Optional bar painting on key events, plus built-in alert conditions for buy, sell, direction change, and euphoria entry.

[b]Settings overview[/b]
Channel Length and Signal Smoothing control responsiveness; Direction Sensitivity sets how quickly trend flips register; Overbought/Oversold levels can be fixed or adaptive; divergence pivot lengths tune Pinpoint Mode strictness.
How to use
Watch for the oscillator entering the heat zones as a warning of stretched conditions. Yellow entries flag early euphoria; red/green turn dots and confirmed crossover signals suggest potential exhaustion or reversal areas. Signals are generally stronger when Pinpoint Mode divergence confirmation is enabled. Works across timeframes and asset classes; best used alongside price structure, volume, and higher-timeframe context rather than in isolation.
Disclaimer: Not financial advice. Past performance is not indicative of future results. Indicators are imperfect and should be used only as an educational and informational guide.

## Source Code

````pine
//@version=6
// EUFEARIA PRO 7
// Designed to help identify elevated market fear, euphoria, momentum shifts, and potential exhaustion.
// This indicator includes custom enhancements, refinements, and added functionality built upon publicly available/open-source concepts.
// Designed to improve market sentiment readings, velocity metrics, overbought/oversold signals, and visual warning stages.
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Philip Paul
// Disclaimer: Not financial advice. Past performance is not indicative of future results. Indicators are not perfect and should be used only as an educational and informational guide.

indicator(shorttitle="EUFEARIA PRO 7", title="EUFEARIA Pro 7 - Momentum Oscillator Enhanced", overlay=false)

length_channel = input.int(10, "Channel Length", tooltip="Channel smoothing period")
length_signal  = input.int(21, "Signal Smoothing", tooltip="Signal line smoothing")
reactivity     = input.int(1, "Direction Sensitivity", minval=1, tooltip="Direction change sensitivity")

ob_lvl_in = input.int(50, "Overbought Level", tooltip="Optimized threshold for extremes")
os_lvl_in = input.int(-50, "Oversold Level", tooltip="Optimized threshold for extremes")

show_signal    = input.bool(true, "Show Signal Line")
bar_paint      = input.bool(true, "Color Bars on Signals")

amplify = input.float(1.0, "Amplification Factor", step=0.05, tooltip="Scales osc and signal together. Default 1.0 keeps original behavior.")
use_adaptive_extremes = input.bool(false, "Adaptive Extremes", tooltip="If ON, overbought/oversold auto-calibrate using percentiles.")
adapt_len = input.int(300, "Adaptive Lookback", minval=50, tooltip="Lookback window for adaptive extremes.")
adapt_ob_pct = input.float(95.0, "Adaptive Overbought Percentile", minval=50, maxval=99.5, step=0.5)
adapt_os_pct = input.float(5.0, "Adaptive Oversold Percentile", minval=0.5, maxval=50, step=0.5)

pinpoint_mode = input.bool(false, "Pinpoint Mode (Divergence Confirm)", tooltip="If ON, buy/sell confirmations require divergence near extremes.")
pivot_left  = input.int(3, "Divergence Pivot Left", minval=1)
pivot_right = input.int(3, "Divergence Pivot Right", minval=1)

strict_sig_extreme = input.bool(true, "Strict Extreme Confirm", tooltip="If ON, requires both osc and signal to be beyond the extreme for sell/buy confirms.")

show_yellow_entry = input.bool(true, "Show Yellow Euphoria Entry", tooltip="Yellow dot and background when osc crosses above overbought level.")

avg_price = hlc3
ema_esa = ta.ema(avg_price, length_channel)
diff = ta.ema(math.abs(avg_price - ema_esa), length_channel)
ci = (avg_price - ema_esa) / (0.015 * diff)

osc_raw = ta.ema(ci, length_signal)
sig_raw = ta.sma(osc_raw, 4)

osc = osc_raw * amplify
sig = sig_raw * amplify

ob_lvl = use_adaptive_extremes ? ta.percentile_linear_interpolation(osc, adapt_len, adapt_ob_pct) : (ob_lvl_in * amplify)
os_lvl = use_adaptive_extremes ? ta.percentile_linear_interpolation(osc, adapt_len, adapt_os_pct) : (os_lvl_in * amplify)

dir = 0
osc_rising = ta.rising(osc, reactivity)
osc_falling = ta.falling(osc, reactivity)
dir := osc_rising ? 1 : osc_falling ? -1 : nz(dir[1])
dir_changed = ta.change(dir) != 0

osc_col = dir > 0 ? color.lime : dir < 0 ? color.red : na

plot(osc, title="EUFEARIA Pro", color=osc_col, linewidth=2)
// Signal line removed per your request
plot(0, color=color.new(color.gray, 50), title="Zero Line")

plot(ob_lvl, title="Overbought", color=color.new(color.red, 40))
plot(os_lvl, title="Oversold", color=color.new(color.lime, 40))

p0 = plot(ob_lvl, display=display.data_window, title="", editable=false)
p1 = plot(ob_lvl + 7, display=display.data_window, title="", editable=false)
p2 = plot(ob_lvl + 14, display=display.data_window, title="", editable=false)
p3 = plot(ob_lvl + 21, display=display.data_window, title="", editable=false)
p4 = plot(ob_lvl + 28, display=display.data_window, title="", editable=false)
p5 = plot(ob_lvl + 35, display=display.data_window, title="", editable=false)

fill(p0, p1, color=color.new(color.rgb(255, 40, 40), 70), editable=false)
fill(p1, p2, color=color.new(color.rgb(255, 25, 25), 75), editable=false)
fill(p2, p3, color=color.new(color.rgb(240, 15, 15), 80), editable=false)
fill(p3, p4, color=color.new(color.rgb(220, 10, 10), 85), editable=false)
fill(p4, p5, color=color.new(color.rgb(200, 0, 0), 88), editable=false)

q0 = plot(os_lvl, display=display.data_window, title="", editable=false)
q1 = plot(os_lvl - 7, display=display.data_window, title="", editable=false)
q2 = plot(os_lvl - 14, display=display.data_window, title="", editable=false)
q3 = plot(os_lvl - 21, display=display.data_window, title="", editable=false)
q4 = plot(os_lvl - 28, display=display.data_window, title="", editable=false)
q5 = plot(os_lvl - 35, display=display.data_window, title="", editable=false)

fill(q0, q1, color=color.new(color.rgb(40, 255, 40), 70), editable=false)
fill(q1, q2, color=color.new(color.rgb(25, 255, 25), 75), editable=false)
fill(q2, q3, color=color.new(color.rgb(15, 240, 15), 80), editable=false)
fill(q3, q4, color=color.new(color.rgb(10, 220, 10), 85), editable=false)
fill(q4, q5, color=color.new(color.rgb(0, 200, 0), 88), editable=false)

osc_ph = ta.pivothigh(osc, pivot_left, pivot_right)
osc_pl = ta.pivotlow(osc, pivot_left, pivot_right)
px_ph  = ta.pivothigh(high, pivot_left, pivot_right)
px_pl  = ta.pivotlow(low, pivot_left, pivot_right)

var float prev_osc_ph = na
var float prev_px_ph  = na
var float prev_osc_pl = na
var float prev_px_pl  = na

bear_div = false
bull_div = false

if not na(osc_ph) and not na(px_ph)
    bear_div := (not na(prev_osc_ph) and not na(prev_px_ph)) and (px_ph > prev_px_ph) and (osc_ph < prev_osc_ph) and (osc_ph >= ob_lvl)
    prev_osc_ph := osc_ph
    prev_px_ph  := px_ph

if not na(osc_pl) and not na(px_pl)
    bull_div := (not na(prev_osc_pl) and not na(prev_px_pl)) and (px_pl < prev_px_pl) and (osc_pl > prev_osc_pl) and (osc_pl <= os_lvl)
    prev_osc_pl := osc_pl
    prev_px_pl  := px_pl

sell_confirm_core = ta.crossunder(osc, sig) and osc >= ob_lvl and (not strict_sig_extreme or sig >= ob_lvl)
buy_confirm_core  = ta.crossover(osc, sig)  and osc <= os_lvl and (not strict_sig_extreme or sig <= os_lvl)

osc_cross_ob = ta.crossover(osc, ob_lvl)
yellow_entry = show_yellow_entry and osc_cross_ob and not sell_confirm_core

sell_signal = sell_confirm_core and (not pinpoint_mode or bear_div)
buy_signal  = buy_confirm_core  and (not pinpoint_mode or bull_div)

turn_bullish_in_fear = dir_changed and dir > 0 and osc <= os_lvl ? osc : na
turn_bearish_in_greed = dir_changed and dir < 0 and osc >= ob_lvl ? osc : na

plot(turn_bullish_in_fear, title="Bullish Turn", style=plot.style_circles, linewidth=4, color=color.rgb(0, 255, 0))
plot(turn_bearish_in_greed, title="Bearish Turn", style=plot.style_circles, linewidth=4, color=color.rgb(255, 0, 0))
plot(yellow_entry ? ob_lvl : na, title="Yellow Euphoria Entry", style=plot.style_circles, linewidth=4, color=color.yellow)

bgcolor(yellow_entry ? color.new(color.yellow, 60) : na)
bgcolor(not na(turn_bullish_in_fear) ? color.new(color.rgb(0, 255, 0), 55) : na)
bgcolor(not na(turn_bearish_in_greed) ? color.new(color.rgb(255, 0, 0), 55) : na)

barcolor(bar_paint ? (
     yellow_entry ? color.yellow :
     not na(turn_bullish_in_fear) ? color.green :
     not na(turn_bearish_in_greed) ? color.red :
     na) : na)

var table info_table = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 85), border_width=1)

greed_lvl         = 50.0 * amplify
very_greedy_lvl   = 67.0 * amplify
ext_greed_lvl     = 84.0 * amplify

fear_lvl          = -50.0 * amplify
very_fearful_lvl  = -67.0 * amplify
ext_fear_lvl      = -84.0 * amplify

if barstate.islast
    sentiment =
         osc >= ext_greed_lvl    ? "Extreme Greed" :
         osc >= very_greedy_lvl  ? "Very Greedy" :
         osc >= greed_lvl        ? "Greed" :
         osc <= ext_fear_lvl     ? "Extreme Fear" :
         osc <= very_fearful_lvl ? "Very Fearful" :
         osc <= fear_lvl         ? "Fear" :
         osc > 30.0 * amplify    ? "Greed" :
         osc < -30.0 * amplify   ? "Fear" :
         "Neutral"

    sentiment_color =
         osc >= ext_greed_lvl    ? color.red :
         osc >= very_greedy_lvl  ? color.new(color.red, 0) :
         osc >= greed_lvl        ? color.orange :
         osc <= ext_fear_lvl     ? color.lime :
         osc <= very_fearful_lvl ? color.new(color.lime, 0) :
         osc <= fear_lvl         ? color.new(color.lime, 0) :
         color.gray

    table.cell(info_table, 0, 0, "Sentiment:", text_color=color.white, text_size=size.normal)
    table.cell(info_table, 1, 0, sentiment, text_color=sentiment_color, text_size=size.normal)

    table.cell(info_table, 0, 1, "Value:", text_color=color.white, text_size=size.normal)
    table.cell(info_table, 1, 1, str.tostring(math.round(osc, 1)), text_color=color.white, text_size=size.normal)

    table.cell(info_table, 0, 2, "Trend:", text_color=color.white, text_size=size.normal)
    table.cell(info_table, 1, 2, dir > 0 ? "Bullish" : dir < 0 ? "Bearish" : "Ranging",
         text_color=dir > 0 ? color.lime : dir < 0 ? color.red : color.gray, text_size=size.normal)

alertcondition(sell_signal, title="Sell Alert", message="EUFEARIA PRO: Sell Signal at {{ticker}}")
alertcondition(buy_signal, title="Buy Alert", message="EUFEARIA PRO: Buy Signal at {{ticker}}")
alertcondition(dir_changed, title="Trend Direction Change", message="EUFEARIA PRO: Direction Change at {{ticker}}")
alertcondition(yellow_entry, title="Euphoria Entry (Yellow)", message="EUFEARIA PRO: Euphoria Entry at {{ticker}}")

// Disclaimer: Not Financial Advice. Past performance is not indicative of future results. Indicators are not perfect. Use this tool as a guide and for information.
````
