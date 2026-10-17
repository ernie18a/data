# Ankita_SMA_Screener

- url: https://www.tradingview.com/script/2WAyYmis-Ankita-SMA-Screener/
- type: indicator
- pine_id: PUB;3df28b4ca22740c7a5fd323970095806
- version: 1.0

## Description

screener to screen sma20 crossing over sma200 after 10+ days

## Source Code

````pine
//@version=6
indicator("SMA20 Golden Cross After 10+ Days Below - Screener", shorttitle="GC Scanner", overlay=false)

// Inputs
sma20_len  = input.int(20,  "SMA 20 Length",  minval=1)
sma200_len = input.int(200, "SMA 200 Length", minval=1)
min_below  = input.int(10,  "Minimum Days Below", minval=5)

// Calculations
sma20  = ta.sma(close, sma20_len)
sma200 = ta.sma(close, sma200_len)

// Count consecutive days below
var int below_days = 0
if sma20 < sma200
    below_days := below_days + 1
else
    below_days := 0

// Signal
cross_up     = ta.crossover(sma20, sma200)
valid_signal = cross_up and below_days >= min_below

// Plots
plot(sma20,  color=color.blue,  title="SMA 20", linewidth=2)
plot(sma200, color=color.red,   title="SMA 200", linewidth=2)

bgcolor(valid_signal ? color.new(color.green, 80) : na)

// Label when signal occurs
if valid_signal
    label.new(bar_index, low, "✅ Golden Cross\n(" + str.tostring(below_days) + " days)", 
              color=color.green, textcolor=color.white, style=label.style_label_up, size=size.normal)

// For Screener
plotchar(valid_signal, title="Golden Cross Signal", char="▲", location=location.top, color=color.lime, size=size.large)

// Table (shows current below days)
var table t = table.new(position.top_right, 1, 2, bgcolor=color.new(color.white, 10))
if barstate.islast
    table.cell(t, 0, 0, "Days Below", text_color=color.gray)
    table.cell(t, 0, 1, str.tostring(below_days), text_color= color.green)

// Alert Condition (Fixed - static message)
alertcondition(valid_signal, 
     title="Valid Golden Cross Alert", 
     message="SMA20 crossed above SMA200 after being below for 10+ days - Check chart!")
````
