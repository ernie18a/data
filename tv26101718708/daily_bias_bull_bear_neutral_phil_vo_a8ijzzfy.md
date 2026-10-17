# Daily Bias - Bull / Bear / Neutral [Phil Vo]

- url: https://www.tradingview.com/script/A8ijZZFy-Daily-Bias-Bull-Bear-Neutral-Phil-Vo/
- type: indicator
- pine_id: PUB;14b5ba2b9fe2431da1c062046ee4dee7
- version: 1.0

## Description

This indicator is built to help traders quickly understand the current daily market bias in a simple visual way. It combines basic market structure with moving average trend filters to classify price conditions as bullish, bearish, or neutral.

The script looks at swing highs and swing lows to detect whether price is forming higher highs and higher lows, or lower highs and lower lows. It then confirms that structure with the 50-period and 200-period moving averages. When both structure and trend filter agree, the indicator displays a clear directional bias. When they do not align, it shows a neutral or choppy condition instead.

The goal is to reduce confusion and help traders stay aligned with the broader directional context before looking for entries on lower timeframes.

Key features:
Clear Bullish / Bearish / Neutral bias label
Optional background color for fast chart reading
50 MA and 200 MA trend filters
Swing-based market structure confirmation
Last swing high and swing low reference points
Alert conditions when bias flips bullish or bearish

This is not a signal or entry tool. It is designed as a simple decision-support overlay to help traders understand whether the market structure and trend are aligned.

You can use it as a higher-timeframe guide before planning executions with your own strategy, price action model, or risk management rules.

## Source Code

````pine
//@version=5
indicator("Daily Bias - Bull / Bear / Neutral [Phil Vo]", overlay = true, max_labels_count = 500)

// ── Inputs ───────────────────────────────────────
show_label     = input.bool(true,  "Show Bias Label")
show_bg        = input.bool(true,  "Show Background Color")
swing_length   = input.int(5,     "Swing Detection Strength", minval=3, maxval=20)

// ── Moving Averages (Key Trend Filters) ──────────
ma50  = ta.sma(close, 50)
ma200 = ta.sma(close, 200)

plot(ma50,  "50 MA",  color=color.new(color.blue, 0), linewidth=2)
plot(ma200, "200 MA", color=color.new(color.red, 0),  linewidth=2)

// ── Market Structure Detection (Higher Highs / Lows) ──
ph = ta.pivothigh(high, swing_length, swing_length)
pl = ta.pivotlow (low,  swing_length, swing_length)

var float last_swing_high = na
var float last_swing_low  = na
var int   bias            = 0     // 1 = Bullish, -1 = Bearish, 0 = Neutral

if not na(ph)
    last_swing_high := ph

if not na(pl)
    last_swing_low := pl

// Update bias based on structure
if not na(ph) and not na(last_swing_high[1])
    if ph > last_swing_high[1]
        bias := 1          // Higher High → Bullish structure
    else
        bias := -1         // Lower High → Bearish structure

if not na(pl) and not na(last_swing_low[1])
    if pl > last_swing_low[1]
        bias := 1          // Higher Low → Bullish
    else
        bias := -1         // Lower Low → Bearish

// Additional filter using MAs
ma_bias = close > ma50 and ma50 > ma200 ? 1 : 
          close < ma50 and ma50 < ma200 ? -1 : 0

// Final combined bias (structure + MA filter)
final_bias = bias == ma_bias and bias != 0 ? bias : 0

// ── Plotting & Labels ─────────────────────────────
bg_color = final_bias == 1 ? color.new(color.green, 92) : 
           final_bias == -1 ? color.new(color.red, 92) : na

bgcolor(show_bg ? bg_color : na)

// Big clear label on the chart
var label bias_label = label.new(bar_index, na, "", style=label.style_label_left, size=size.large, color=color.white)

if barstate.islast and show_label
    label_text = final_bias == 1 ? "BULLISH BIAS" : 
                 final_bias == -1 ? "BEARISH BIAS" : "NEUTRAL / CHOP"

    label_color = final_bias == 1 ? color.new(color.green, 0) : 
                  final_bias == -1 ? color.new(color.red, 0) : color.gray

    label.set_text(bias_label, label_text)
    label.set_color(bias_label, label_color)
    label.set_textcolor(bias_label, color.white)
    label.set_x(bias_label, bar_index + 5)
    label.set_y(bias_label, high * 1.02)

// Optional: Show last swing levels
plot(last_swing_high, "Last Swing High", color.new(color.red, 60), 1, plot.style_circles)
plot(last_swing_low,  "Last Swing Low",  color.new(color.green, 60), 1, plot.style_circles)

// Alerts
alertcondition(final_bias == 1 and final_bias[1] != 1, "Daily Bias → Bullish", "Daily bias flipped to BULLISH")
alertcondition(final_bias == -1 and final_bias[1] != -1, "Daily Bias → Bearish", "Daily bias flipped to BEARISH")
````
