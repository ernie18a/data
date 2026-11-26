# Delta Aggregator [XWiseTrade]

- url: https://www.tradingview.com/script/Z3BEvnXs-Delta-Aggregator-XWiseTrade/
- type: indicator
- pine_id: PUB;b414d622da6b4c698c46115a1e67c777
- version: 1.0

## Description

Real-time delta and buy/sell volume label for the current candle.

Aggregates lower timeframe volume to show aggressive buying/selling activity directly on the chart via a clean label:
• Delta (Buy - Sell)
• Percentage
• Buy / Sell / Total volume

Features:
• Supports 1s to 15min lower timeframes
• Customizable label position
• No chart clutter — label only

Perfect for order flow traders who want key numbers at a glance.

## Source Code

````pine
//@version=6
indicator("Delta Aggregator [XWiseTrade]",  overlay=true, max_labels_count=500)

// === Data Source ===
group_data = "Data Source"
low_tf = input.string("1", "Lower Timeframe Source (Delta Aggregation)", 
     options=["1S","5S","15S","1","3","5","15"], group=group_data)

// === Display Settings ===
group_display = "Display Settings"
show_delta_labels = input.bool(true, "Show Delta Labels", group=group_display)
delta_label_offset = input.float(0.0, "Delta Label Vertical Offset", group=group_display, step=0.01, 
     tooltip="Positive values move label above candle, negative below")

// === Timeframe Conversion ===
low_tf_pine = low_tf == "1S" ? "1S" :
               low_tf == "5S" ? "5S" :
               low_tf == "15S" ? "15S" :
               low_tf

// === Core Variables ===
label current_label = na
float deltaSum = 0.0
float buySum = 0.0
float sellSum = 0.0
bool data_valid = false

// Fetch lower timeframe data
[low_close_arr, low_open_arr, low_volume_arr] = request.security_lower_tf(syminfo.tickerid, low_tf_pine, [close, open, volume])

// Validate high TF volume for data availability
totalVol_high_tf = request.security(syminfo.tickerid, timeframe.period, volume, barmerge.gaps_off, lookahead=barmerge.lookahead_off)

if not na(low_tf_pine) and not na(totalVol_high_tf) and totalVol_high_tf > 0 and array.size(low_close_arr) > 0
    float tempBuySum = 0.0
    float tempSellSum = 0.0

    for i = 0 to array.size(low_close_arr) - 1
        o = array.get(low_open_arr, i)
        c = array.get(low_close_arr, i)
        v = array.get(low_volume_arr, i)
        if na(o) or na(c) or na(v) or v <= 0
            continue
        
        buyVol  = c > o ? v : c == o ? v / 2 : 0
        sellVol = c < o ? v : c == o ? v / 2 : 0
        
        tempBuySum  += buyVol
        tempSellSum += sellVol

    buySum   := tempBuySum
    sellSum  := tempSellSum
    deltaSum := buySum - sellSum
    data_valid := true
else
    data_valid := false
    deltaSum := na
    buySum   := na
    sellSum  := na

// === Delta Label Only ===
if show_delta_labels and data_valid
    totalVol = buySum + sellSum
    validTotalVol = totalVol > 0 ? totalVol : 1.0
    deltaRatio = deltaSum / validTotalVol
    
    delta_label_text = str.format("Δ: {0,number}\n({1,number,#.##}%)\nBuy: {2,number}\nSell: {3,number}\nTotal: {4,number}", 
         deltaSum, deltaRatio * 100, buySum, sellSum, totalVol)
    
    if ta.change(time) != 0  // New candle
        current_label := label.new(bar_index, high + delta_label_offset, delta_label_text, 
             color=color.new(#2e2e2e, 32), style=label.style_label_down, 
             textcolor=color.white, size=size.normal, textalign=text.align_center)
    else if barstate.isrealtime
        label.set_text(current_label, delta_label_text)
        label.set_xy(current_label, bar_index, high + delta_label_offset)
````
