# Low-Pass Bands [ChartPrime]

- url: https://www.tradingview.com/script/FikjkZ7D-Low-Pass-Bands-ChartPrime/
- type: indicator
- pine_id: PUB;9ee19669961143c6b2f127c8d00cc340
- version: 1.0

## Description

[b]⯁ OVERVIEW[/b]  
The [b]Low-Pass Bands [ChartPrime][/b] indicator employs a low-pass filter to smooth market noise and highlight trend direction. It consists of an upper band, a lower band, and a central line. The bands are calculated based on a user-defined percentage distance from the smoothed central line, derived using a low-pass filter. The indicator also features dynamic color-coding and bar coloring to help traders quickly identify potential trend shifts and momentum.


[b]⯁ KEY FEATURES & HOW TO USE[/b]

[b]⯌ Low-Pass Filtered Bands[/b]:  
The indicator utilizes a low-pass filter to smooth the input source (e.g., hlc3) over a specified length. It then calculates upper and lower bands as a percentage distance from this smoothed value. The central line and the bands adapt to market movements, filtering out short-term noise and focusing on the overall trend.  
[pine]
// Low-pass filter method
method lp_filter(float src, int length) =>
    float alpha = 2.0 / (length + 1)   // Alpha for EMA smoothing
    var float smooth_val = na
    smooth_val := na(smooth_val[1]) ? src : alpha * src + (1 - alpha) * smooth_val[1]
    smooth_val
[/pine]
[i]Use[/i]: Traders can use these bands to identify the general trend direction. The price oscillating between the bands indicates consolidation, while crossing the bands signifies potential trend shifts.
[image]https://www.tradingview.com/x/wqI2yMDu/[/image]

[b]⯌ Trend Detection and Signals[/b]:  
The indicator detects trend changes by identifying crossovers between the price and the upper or lower bands. When the price crosses above the upper band, it signals a potential upward trend. Conversely, crossing below the lower band signals a potential downward trend. Diamond markers are plotted on the chart to highlight these trend changes.  
[i]Use[/i]: Traders can use these crossover signals to identify entry and exit points, taking long positions on bullish crossovers and short positions on bearish crossovers.
[image]https://www.tradingview.com/x/fLKL751b/[/image]
[image]https://www.tradingview.com/x/mYsIH6DJ/[/image]

[b]⯌ Dynamic Color-Coding[/b]:  
The bands and central line are dynamically color-coded based on the price’s relation to them. If the price is above the lower band, the color changes to indicate a positive trend, while being below changes it to a negative trend color. This color-coding extends to the candlesticks when the bar coloring option is enabled.  
[i]Use[/i]: The color-coding provides an immediate visual representation of the trend's current state, allowing traders to quickly assess market conditions.

[b]⯌ Trend Information Display[/b]:  
The indicator displays trend information in text format on the chart, indicating whether the current trend is "Trend Up" or "Trend Down." Additionally, the indicator denotes momentum by adding a "+" for strong trends. The color of the trend text changes to match the trend direction.  
[i]Use[/i]: This trend display offers a clear and concise summary of the market's direction and momentum, aiding traders in making informed trading decisions.
[i]Trend Losing momentum:[/i]
[image]https://www.tradingview.com/x/55sH8yGE/[/image]
[image]https://www.tradingview.com/x/D9wEuFvy/[/image]
[i]Trends with Strong Momentum:[/i]
[image]https://www.tradingview.com/x/NTkSGbNg/[/image]
[image]https://www.tradingview.com/x/MVDcS6DG/[/image]

[b]⯁ USER INPUTS[/b]  
[list]
[*] [b]Length[/b]: Sets the length for the low-pass filter, determining the degree of smoothing.
[*] [b]% Distance[/b]: Defines the percentage distance from the central line for the upper and lower bands.
[*] [b]Source[/b]: Selects the data source for calculations (default: hlc3).
[*] [b]Color + / -[/b]: Choose colors for positive and negative trends.
[*] [b]Bars Color[/b]: Toggle for coloring bars according to the trend.
[/list]

[b]⯁ CONCLUSION[/b]  
The [b]Low-Pass Bands [ChartPrime][/b] indicator provides a robust way to visualize market trends and potential shifts by filtering out short-term noise using a low-pass filter. Its dynamic bands, trend detection signals, and color-coded visual cues make it a versatile tool for identifying trend direction and momentum. The addition of trend information directly on the chart further enhances its utility, offering traders a clear and concise overview of the market's current state.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime

//@version=6
indicator("Low-Pass Bands [ChartPrime]", overlay = true)

// --------------------------------------------------------------------------------------------------------------------}
// 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

int   length               = input.int(25, "Length")                        // Indicator length
float percentageDistance   = input.float(0.5, "% Distance", step=0.1)       // Percentage distance for bands
float source               = input.source(hlc3, "Source")                   // Source for calculations
color color_plus           = input.color(#1ed872, "+", inline = "1")      // Color for positive trend
color color_minus          = input.color(#d81e5c, "-", inline = "1")      // Color for negative trend
bool  bars_col             = input.bool(false, "Bars Color")                // Toggle for coloring bars


// --------------------------------------------------------------------------------------------------------------------}
// 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{
// Low-pass filter method
method lp_filter(float src, int length) =>
    float alpha = 2.0 / (length + 1)   // Alpha for EMA smoothing
    var float smooth_val = na
    smooth_val := na(smooth_val[1]) ? src : alpha * src + (1 - alpha) * smooth_val[1]
    smooth_val

// Bands calculation method
method bands(float src) =>
    float lower = src * (1 - percentageDistance / 100)  // Lower band
    float upper = src * (1 + percentageDistance / 100)  // Upper band
    [lower, src, upper]

// Calculate the bands
[lower, src, upper] = source.lp_filter(length).bands()

// Determine colors based on source position relative to bands
color1 = source > lower ? color_plus : color_minus
color2 = source > upper ? color_plus : color_minus
color3 = source > src   ? color_plus : color_minus

// Plot bands and fills
p1 = plot(lower, color = color(na))
p2 = plot(upper, color = color(na))
p0 = plot(src, color = color3, linewidth = 2)

fill(p1, p0, src, lower, na, color.new(color1, 50))
fill(p2, p0, upper, src, color.new(color2, 50), na)

// Trend detection
var trend = bool(na)
trend_dn = ta.crossunder(source, lower)
trend_up = ta.crossover(source, upper)

switch
    trend_up => trend := true
    trend_dn => trend := false


// --------------------------------------------------------------------------------------------------------------------}
// 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{
// Plot trend change signals
atr = ta.atr(200) * 0.5
plotshape(trend_up and not trend[1] ? lower - atr : na, "", shape.diamond, location.absolute, color = color_plus, size = size.tiny)
plotshape(trend_dn and trend[1] ? upper + atr : na, "", shape.diamond, location.absolute, color = color_minus, size = size.tiny)

// Determine trend text and color
trend_txt = trend and source > upper 
             ? "Trend Up +" : 
             trend and source < upper 
             ? "Trend Up -" : 
             not trend and source < lower 
             ? "Trend Down +" : 
             not trend and source > lower 
             ? "Trend Down -" 
             : "" 

text_col = str.contains(trend_txt, "Up +") 
             ? color_plus 
             : str.contains(trend_txt, "Down +") 
             ? color_minus 
             : str.contains(trend_txt, "-") 
             ? chart.fg_color 
             : na

// Display trend information on the chart
if barstate.islast
    var table = table.new(position.top_center, 1, 1)
    table.cell(table, 0, 0, trend_txt, text_color = text_col, text_size = size.large)

// Optional bar coloring
bar_color = bars_col ? text_col : na
plotcandle(open, high, low, close, '', color = bar_color, wickcolor = bar_color, bordercolor = bar_color, editable = false)
// --------------------------------------------------------------------------------------------------------------------}
````
