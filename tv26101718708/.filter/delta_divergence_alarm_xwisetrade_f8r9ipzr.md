# Delta Divergence Alarm [XWiseTrade]

- url: https://www.tradingview.com/script/f8r9IPZR-Delta-Divergence-Alarm-XWiseTrade/
- type: indicator
- pine_id: PUB;7ff10bcac8a241c4a1f7f1d420123707
- version: 2.0

## Description

Detect hidden buying/selling pressure with real-time delta divergence alerts.

This indicator aggregates lower timeframe volume to calculate delta and triggers alerts when:
• Price makes a lower low/higher high but delta shows opposite pressure (hidden divergence)

Features:
• Supports ultra-low timeframes (1s, 15s, 1-15min)
• Visual labels on divergence candles
• Built-in alerts
• Debug mode for data issues

Perfect for spotting absorption, exhaustion, and potential reversals.

## Source Code

````pine
//@version=6
indicator("Delta Divergence Alarm [XWiseTrade]",  overlay=true, max_labels_count=500)

// === Data Source ===
group_data = "Data Source"
low_tf = input.string("1", "Lower Timeframe Source (Delta Aggregation)", 
     options=["1S","15S","1","3","5","15"], group=group_data)

// === Appearance ===
group_style = "Appearance"
bullish_color = input.color(color.new(color.green, 0), "Bullish Divergence Color", group=group_style)
bearish_color = input.color(color.new(color.red, 0), "Bearish Divergence Color", group=group_style)
label_y_offset = input.int(1, "Label Vertical Offset (ticks)", group=group_style)
show_debug_labels = input.bool(false, "Debug Mode (Show 'No Data' Labels)", group=group_style, 
     tooltip="When data is missing, show a 'No Data' label to help diagnose why signals are not appearing.")

// === Timeframe Conversion ===
low_tf_pine = low_tf == "1S" ? "1S" :
               low_tf == "15S" ? "15S" :
               low_tf

// === Delta Calculation ===
float deltaSum = na
bool data_valid = false

totalVol_high_tf = request.security(syminfo.tickerid, timeframe.period, volume, barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[low_close_arr, low_open_arr, low_volume_arr] = request.security_lower_tf(syminfo.tickerid, low_tf_pine, [close, open, volume])

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

    deltaSum := tempBuySum - tempSellSum
    data_valid := true
else
    data_valid := false
    deltaSum := na

// === Divergence Detection & Alerts (on previous bar when new bar appears) ===
if ta.change(time) != 0 and not barstate.islast
    if data_valid[1]
        is_bullish_div = close[1] < open[1] and deltaSum[1] > 0
        is_bearish_div = close[1] > open[1] and deltaSum[1] < 0

        if is_bullish_div
            label_text = str.format("Bullish Divergence\nΔ: {0,number}", deltaSum[1])
            label.new(bar_index[1], low[1] - syminfo.mintick * label_y_offset, text=label_text, 
                 color=bullish_color, style=label.style_label_up, textcolor=color.white, size=size.normal)
            alert("Bullish Divergence Detected! Delta: " + str.tostring(deltaSum[1]), alert.freq_once_per_bar_close)

        if is_bearish_div
            label_text = str.format("Bearish Divergence\nΔ: {0,number}", deltaSum[1])
            label.new(bar_index[1], high[1] + syminfo.mintick * label_y_offset, text=label_text, 
                 color=bearish_color, style=label.style_label_down, textcolor=color.white, size=size.normal)
            alert("Bearish Divergence Detected! Delta: " + str.tostring(deltaSum[1]), alert.freq_once_per_bar_close)
    else if show_debug_labels
        label.new(bar_index[1], high[1], "No Data", color=color.new(color.maroon, 20), style=label.style_label_down, textcolor=color.white, size=size.tiny)
````
