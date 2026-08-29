<!-- tradingview-pine-id: PUB;36833024b359451cb3d58d77714fea3e -->
<!-- tradingviewscripts-format: 1 -->
# HTF Candle Volume Thermometer [ChartPrime]

Source: https://www.tradingview.com/script/Vo99POv0-HTF-Candle-Volume-Thermometer-ChartPrime/

## Description

The HTF Candle Volume Thermometer is a powerful volume heatmap tool that visualizes higher timeframe candle volume distributions directly on the chart. It helps traders identify key price levels where liquidity is concentrated, allowing for more informed trading decisions.  

⯁ KEY FEATURES  
  
[*] Higher Timeframe Volume Mapping  
   Uses higher timeframe (HTF) candles to create a heatmap of volume distribution within each candle.  
[image]https://www.tradingview.com/x/sRDxerrU/[/image]

[*] Dynamic Volume Heatmap  
   Colors each HTF candle background green for bullish and red for bearish, with a gradient heat overlay highlighting volume concentration.  
[image]https://www.tradingview.com/x/bDKyZsEO/[/image]

[*] Max Volume Point Identification  
   Marks the level within each HTF candle where the highest volume was recorded, using red for the most significant volume area.  
[image]https://www.tradingview.com/x/4YevcRMf/[/image]

[*] Fully Customizable Display  
   Users can adjust the HTF timeframe, color settings, and resolution to tailor the indicator to their trading preferences.  
[image]https://www.tradingview.com/x/wcoMwVkK/[/image]

[*] Segmented Volume Distribution  
   Each HTF candle is divided into smaller levels, allowing traders to see volume changes within the range of each candle.  

[*] Key Level Detection  
   Max volume points often act as key support and resistance levels where price is likely to react, helping traders refine their strategies.  
[image]https://www.tradingview.com/x/ywFKbRfT/[/image]
  

⯁ HOW TO USE  
  
[*] Identify Liquidity Zones  
   Use the max volume levels to determine areas where price is likely to find support or resistance.  

[*] Assess Trend Strength  
   Compare volume distribution between bullish and bearish HTF candles to gauge market momentum.  

[*] Optimize Trade Entries & Exits  
   Look for price reactions at high-volume areas to refine stop-loss and take-profit levels.  

[*] Adjust Heatmap Resolution  
   Customize the resolution setting to get a more detailed or broader view of volume segmentation within HTF candles.  
  

⯁ CONCLUSION  
The HTF Candle Volume Thermometer is a must-have tool for traders who want to integrate volume analysis with higher timeframe structures. By visualizing volume heatmaps within each HTF candle, this indicator helps traders pinpoint critical liquidity zones and key price levels.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime

//@version=6
indicator("HTF Candle Volume Thermometer [ChartPrime]", overlay = true, max_boxes_count = 500, max_bars_back = 1000)


// --------------------------------------------------------------------------------------------------------------------}
// 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{
timeframe = input.timeframe("D")
resolution = input.string("Mid", "Resolution", ["High", "Mid", "Low"])
color_up = input.color(color.lime, "Bull/Bear", inline = "col_candle")
color_dn = input.color(color.red, "", inline = "col_candle")
transp  = input.int(80, "", inline = "col_candle")
color_heat = input.color(color.yellow, "Heat/Max", inline = "map")
color_poc = input.color(color.red, "", inline = "map")


// --------------------------------------------------------------------------------------------------------------------}
// 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{

close_htf = request.security(syminfo.tickerid, timeframe, close[1], lookahead = barmerge.lookahead_on)
open_htf = request.security(syminfo.tickerid, timeframe, open[1], lookahead = barmerge.lookahead_on)

time_change = timeframe.change(timeframe)

// Declare arrays to store high/low values during each timeframe period
var array<float> loww = array.new<float>()
var array<float> highh = array.new<float>()

var float H = na
var float L = na
var int index = na

// Dynamic array for bin volumes
var array<float> bin_volumes = array.new<float>()

if time_change
    index := bar_index
    highh.clear()
    loww.clear()
    bin_volumes.clear()  // Reset volume storage

if not time_change
    highh.push(high)
    H := array.max(highh)

    loww.push(low)
    L := array.min(loww)

// Step size based on ATR (dividing into segments)

div = switch resolution
    "High" => 5
    "Mid" => 3
    "Low" => 1

step = ta.atr(200) / div

// --------------------------------------------------------------------------------------------------------------------}
// 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{
if time_change
    box_size = H - L
    levels = int(box_size / step)
    bin = box_size / levels  // Prevent division by zero


    // Initialize bin volume storages
    for i = 0 to levels - 1
        array.push(bin_volumes, 0)

    // Calculate volume per bin
    for j = 0 to bar_index - index[1]
        for i = 0 to levels - 1
            lower = L + bin * i
            upper = lower + bin

            if close[j] >= lower and close[j] <= upper
                array.set(bin_volumes, i, array.get(bin_volumes, i) + volume[j])

    // Normalize volumes to create a gradient
    min_vol = array.min(bin_volumes)

    max_vol = array.max(bin_volumes)
    
    if array.size(bin_volumes) > 0 and max_vol > min_vol
        for i = 0 to levels - 1
            norm_vol = (array.get(bin_volumes, i) - min_vol) / (max_vol - min_vol)
            box_color1 = color.from_gradient(norm_vol, 0, 1, color.new(color_up, transp), color_heat)
            box_color2 = color.from_gradient(norm_vol, 0, 1, color.new(color_dn, transp), color_heat)

            box_color = max_vol == array.get(bin_volumes, i) ? color_poc : close_htf > open_htf ? box_color1 : box_color2

            lower = L + bin * i
            upper = lower + bin

            max_volume_val = max_vol == array.get(bin_volumes, i) ? str.tostring(array.get(bin_volumes, i), format.volume) : ""

            box.new(index[1], upper, bar_index, lower, bgcolor=box_color, border_color = na, text = max_volume_val)
// --------------------------------------------------------------------------------------------------------------------}
````
