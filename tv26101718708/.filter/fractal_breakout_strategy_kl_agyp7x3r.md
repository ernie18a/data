# Fractal Breakout Strategy [KL]

- url: https://www.tradingview.com/script/agyP7x3R-Fractal-Breakout-Strategy-KL/
- type: strategy
- pine_id: PUB;e9475a9ee73e4de7b5e90a8d1e72aa2e
- version: 2.0

## Description

[b]Fractal Breakout Strategy[/b]
This strategy will enter into a Long position when (a) bullish fractal is formed, combined with (b) ATR is relatively low. Trailing stop loss is set based on ATR.

[b]Bullish fractal pattern[/b]:
A bullish fractal pattern looks like this:
[image]https://www.tradingview.com/x/9dL128Uf/[/image]
It is formed when lower-low has reached a local minimum followed by higher-lows.
By default, this script plots the pivot point (the local minimum) using green crosses. This line will extend to the right until the next bullish fractal is formed. The local minimum pivot point is considered as key level of support. For long position entry, entry price must be higher or equal to it.

On the other hand, a bearish fractal pattern looks like the exact opposite. Reversing the logic, it is a local maximum indicated by higher-highs followed by lower-highs. This is shown by red crosses.

[b]Why use ATR to confirm entry[/b]:
Two reasons to enter when ATR is low:
1) Since trailing stop loss is based on ATR, entering the market when ATR is low means risking less for potentially high reward.
2) Low ATR often signals price consolidation. There are two favorable scenarios, either: (i) period of accumulation, or (ii) bull flag, ideally followed by breakout.

[b]Determining whether ATR is low[/b]:
Relative lows are quantified out by using the method in my other script: [url=https://www.tradingview.com/script/1TJH9UzS-Modified-ATR-Indicator-KL/]Modified ATR Indicator[/url]

The method involves applying two-tailed hypothesis testing to assess whether ATR (ie. by default lookback period of 5) has greatly deviated from a larger sample size (ie. lookback period of 50). Assuming ATR is normally distributed and variance is known, then test statistic (z) can be used to determine whether ATR5 is within the critical area under Null Hypothesis: ATR5 == ATR50. If z falls below/above the left/right critical values (ie. 1.645 for a 90% confidence interval), then ATR is determined to the relatively low/high respectively. For the purpose of assessing whether ATR is low, the left-tail is the main focus. 

[b]Profit taking[/b]:
Profits by default are taken over 3 levels based on risk to reward ratio (ie. 1R, 2R, 3R). When a target is met at each level, strategy will close out one third of current position size. Remainders (ie. already taken once at 1R, but not yet reaching 2R or 3R) will eventually be closed at the trailing stop loss price.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DojiEmoji

//@version=5
strategy("Fractal Strat [KL] ", overlay=true, pyramiding=1, initial_capital=1000000000, default_qty_type=strategy.percent_of_equity, default_qty_value=5)
var string ENUM_LONG = "Long"
var string GROUP_ENTRY = "Entry"
var string GROUP_TSL = "Stop loss"
var string GROUP_ORDER = "Order size and Profit taking"

backtest_timeframe_start = input.time(defval=timestamp("01 Apr 2000 13:30 +0000"), title="Backtest Start Time")
within_timeframe = time >= backtest_timeframe_start

// TSL: calculate the stop loss price. {
_multiple       = input(2.0, title="ATR Multiplier for trailing stop loss", group=GROUP_TSL)
ATR_TSL         = ta.atr(input(14, title="Length of ATR for trailing stop loss", group=GROUP_TSL, tooltip="Initial risk amount = atr(this length) x multiplier")) * _multiple
TSL_source      = low
TSL_line_color  = color.green
TSL_transp      = 100
var stop_loss_price = float(0)

var float initial_entry_p    = float(0)
var float risk_amt           = float(0)
var float initial_order_size = float(0)

if strategy.position_size == 0 or not within_timeframe
    TSL_line_color := color.black
    stop_loss_price := TSL_source - ATR_TSL
else if strategy.position_size > 0
    stop_loss_price := math.max(stop_loss_price, TSL_source - ATR_TSL)
    TSL_transp := 0

plot(stop_loss_price, color=color.new(TSL_line_color, TSL_transp))
// } end of "TSL" block


// Profit taking {
var bool  tp_mode = input(true, title="Take profit and different levels", group=GROUP_ORDER)
var float FIRST_LVL_PROFIT = input.float(1, title="First level profit", tooltip="Relative to risk. Example: entry at $10 and inital stop loss at $9. Taking first level profit at 1R means taking profits at $11", group=GROUP_ORDER)
var float SECOND_LVL_PROFIT = input.float(2, title="Second level profit", tooltip="Relative to risk. Example: entry at $10 and inital stop loss at $9. Taking second level profit at 2R means taking profits at $12", group=GROUP_ORDER)
var float THIRD_LVL_PROFIT = input.float(3, title="Third level profit", tooltip="Relative to risk. Example: entry at $10 and inital stop loss at $9. Taking third level profit at 3R means taking profits at $13", group=GROUP_ORDER)
// }

// Fractals {
// Modified from synapticEx's implementation: https://www.tradingview.com/script/cDCNneRP-Fractal-Support-Resistance-Fixed-Volume-2/
rel_vol_len = 6 // Relative volume is used; the middle candle has to have volume above the average (say sma over prior 6 bars)
rel_vol = ta.sma(volume, rel_vol_len)
_up = high[3]>high[4] and high[4]>high[5] and high[2]<high[3] and high[1]<high[2] and volume[3]>rel_vol[3]
_down = low[3]<low[4] and low[4]<low[5] and low[2]>low[3] and low[1]>low[2] and volume[3]>rel_vol[3]

fractal_resistance = high[3], fractal_support = low[3]   // initialize

fractal_resistance :=  _up ? high[3] : fractal_resistance[1]
fractal_support := _down ? low[3] : fractal_support[1]

plot(fractal_resistance, "fractal_resistance", color=color.new(color.red,50), linewidth=2, style=plot.style_cross, offset =-3, join=false)
plot(fractal_support, "fractal_support", color=color.new(color.lime,50), linewidth=2, style=plot.style_cross, offset=-3, join=false)
// }

// ATR diversion test {
// Hypothesis testing (2-tailed):
//
// Null hypothesis (H0) and Alternative hypothesis (Ha):
//     H0 : atr_fast equals atr_slow
//     Ha : atr_fast not equals to atr_slow; implies atr_fast is either too low or too high
len_fast    = input(5,title="Length of ATR (fast) for diversion test", group=GROUP_ENTRY)
atr_fast    = ta.atr(len_fast)
atr_slow    = ta.atr(input(50,title="Length of ATR (slow) for diversion test", group=GROUP_ENTRY, tooltip="This needs to be larger than Fast"))

// Calculate test statistic (test_stat)
std_error   = ta.stdev(ta.tr, len_fast) / math.pow(len_fast, 0.5)
test_stat = (atr_fast - atr_slow) / std_error

// Compare test_stat against critical value defined by user in settings
//critical_value = input.float(1.645,title="Critical value", tooltip="Strategy uses 2-tailed test to compare atr_fast vs atr_slow. Null hypothesis (H0) is that both should equal. Based on the computed test statistic value, if absolute value of it is +/- this critical value, then H0 will be rejected.", group=GROUP_ENTRY)
conf_interval = input.string(title="Confidence Interval", defval="95%", options=["90%","95%","99%"], tooltip="Critical values of 1.645, 1.96, 2.58, for CI=90%/95%/99%, respectively; Under 2-tailed test to compare atr_fast vs atr_slow. Null hypothesis (H0) is that both should equal. Based on the computed test statistic value, if absolute value of it is +/- critical value, then H0 will be rejected.")
critical_value = conf_interval == "90%" ? 1.645 : conf_interval == "95%" ? 1.96 : 2.58
reject_H0_lefttail = test_stat < -critical_value
reject_H0_righttail = test_stat > critical_value

// } end of "ATR diversion test" block

// Entry Signals
entry_signal_long = close >= fractal_support and reject_H0_lefttail

// MAIN {
// Update the stop limit if strategy holds a position.
if strategy.position_size > 0
    strategy.exit(ENUM_LONG, comment="SL", stop=stop_loss_price)

// Entry
if within_timeframe and entry_signal_long and strategy.position_size == 0
    initial_entry_p := close
    risk_amt := ATR_TSL
    strategy.entry(ENUM_LONG, strategy.long)

var int TP_taken_count = 0
if tp_mode and close > strategy.position_avg_price
    if close >= initial_entry_p + THIRD_LVL_PROFIT * risk_amt and TP_taken_count == 2
        strategy.close(ENUM_LONG, comment="TP Lvl3", qty=math.floor(strategy.position_size / 3))
        TP_taken_count := TP_taken_count + 1
    else if close >= initial_entry_p + SECOND_LVL_PROFIT * risk_amt and TP_taken_count == 1
        strategy.close(ENUM_LONG, comment="TP Lvl2", qty=math.floor(strategy.position_size / 3))
        TP_taken_count := TP_taken_count + 1
    else if close >= initial_entry_p + FIRST_LVL_PROFIT * risk_amt and TP_taken_count == 0
        strategy.close(ENUM_LONG, comment="TP Lvl1", qty=math.floor(strategy.position_size / 3))
        TP_taken_count := TP_taken_count + 1
    
// Alerts
_atr = ta.atr(14)
alert_helper(msg) =>
    prefix = "[" + syminfo.root + "] "
    suffix = "(P=" + str.tostring(close, "#.##") + "; atr=" + str.tostring(_atr, "#.##") + ")"
    alert(str.tostring(prefix) + str.tostring(msg) + str.tostring(suffix), alert.freq_once_per_bar)

if strategy.position_size > 0 and ta.change(strategy.position_size)
    if strategy.position_size > strategy.position_size[1]
        alert_helper("BUY")
    else if strategy.position_size < strategy.position_size[1]
        alert_helper("SELL")

// Clean up - set the variables back to default values once no longer in use
if ta.change(strategy.position_size) and strategy.position_size == 0
    TP_taken_count := 0
    initial_entry_p := float(0)
    risk_amt := float(0)
    initial_order_size := float(0)
    stop_loss_price := float(0)
// } end of MAIN block
````
