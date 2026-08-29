<!-- tradingview-pine-id: PUB;53acdf3223424edab7c512f3cad54946 -->
<!-- tradingviewscripts-format: 1 -->
# Heat Map Seasons

Source: https://www.tradingview.com/script/zuS134uh-Heat-Map-Seasons/

## Description

Heat Map Seasons indicator

  Indicator offers traders a unique perspective on market dynamics by visualizing seasonal trends and deviations from typical price behavior. By blending regression analysis with a color-coded heat map, this indicator highlights periods of heightened volatility and helps identify potential shifts in market sentiment.

Summer:
[image]https://www.tradingview.com/x/5R3tBb8l/[/image]
In the context of the indicator, "summer" represents a period of heightened volatility and upward price momentum in the market. This is analogous to the warmer months of the year when activities are typically more vibrant and energetic. During the "summer" phase indicated by the indicator, traders may observe strong bullish trends, increased trading volumes, and larger price movements. It suggests a favorable environment for bullish strategies, such as trend following or momentum trading. However, traders should exercise caution as heightened volatility can also lead to increased risk and potential drawdowns.

Winter:
[image]https://www.tradingview.com/x/uCR1zqpv/[/image]
Conversely, "winter" signifies a period of decreased volatility and potentially sideways or bearish price action in the market. Similar to the colder months of the year when activities tend to slow down, the "winter" phase in the indicator suggests a quieter market environment with subdued price movements and lower trading volumes. During this phase, traders may encounter choppy price action, consolidation patterns, or even downtrends. It indicates a challenging environment for trend-following strategies and may require a more cautious approach, such as range-bound or mean-reversion trading strategies.

In summary, the "summer" and "winter" phases in the "Heat Map Seasons" indicator provide traders with valuable insights into the prevailing market sentiment and can help inform their trading decisions based on the observed levels of volatility and price momentum.
[image]https://www.tradingview.com/x/AnMbQmPH/[/image]

How to Use:
Watch for price bars that deviate significantly from the regression line, as these may signal potential trading opportunities.
Use the seasonal gauge to gauge the current market sentiment and adjust trading strategies accordingly.
Experiment with different settings for Length and Heat Sensitivity to customize the indicator to your trading style and preferences.

The "Heat Map Seasons" indicator can potentially identify overheated market tops and bottoms on a weekly timeframe by detecting significant deviations from the regression line and observing extreme color gradients in the heat map. Here's how it can be used for this purpose:

Observing Extreme Color Gradients:
When the market is overheated and reaches a potential top, you may observe extremely warm colors (e.g., deep red) in the heat map section of the indicator.
Traders can interpret this as a warning sign of a potential market top, indicating that bullish momentum may be reaching unsustainable levels.
Conversely, when prices deviate too far below the regression line, it may indicate oversold conditions and a potential bottom.

Potential Tops and Bottoms:
[image]https://www.tradingview.com/x/oOKWNpth/[/image]

User Inputs:

[*]Length: Determines the length of the regression analysis period.
[*]Heat Sensitivity: Controls the sensitivity of the heat map to deviations from the regression line.
[*]Show Regression Line: Option to display or hide the regression line on the chart

[image]https://www.tradingview.com/x/VTljeLCY/[/image]

Note: This indicator is best used in conjunction with other technical analysis tools and should not be relied upon as the sole basis for trading decisions.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © VanHe1sing

//@version=5
indicator("Heat Map Seasons", shorttitle = "HeatMapS", overlay =  true)

// ————— User Inputs 
int Length         = input.int(200, "Length")
int heat_sensative = input.int(70, "Heat Sensitivity", step = 10)
bool show_line     = input.bool(true, "Show Regression Line?")


// ————— Normalization Function
normalization(src, mean)=> 
    norm = (src - mean) / ta.stdev(src, 200)
    norm > 5 ? 5 : norm < -5 ? -5 : norm

// ————— Rescale Function (when range is known).
rescale(_src, _oldMin, _oldMax, _newMin, _newMax) =>
    _newMin + (_newMax - _newMin) * (_src - _oldMin) / math.max(_oldMax - _oldMin, 10e-10)

// ————— Regression Line Formula
Regression_Line(length)=>
    x  = bar_index
    y  = hl2
    x_ = ta.sma(x,length)
    y_ = ta.sma(y,length)
    mx = ta.stdev(x,length)
    my = ta.stdev(y,length)
    c  = ta.correlation(x,y,length)
    // -
    slope = c * (my/mx)
    inter = y_ - slope*x_
    // -
    x*slope + inter

Regression_Line = Regression_Line(Length)

// ————— Heat Map Color Bars
color_level = normalization(close - Regression_Line, 0)

color = color_level > 0 
 ? color.from_gradient(color_level, 0, ta.highest(color_level, heat_sensative), color.yellow, color.red)
 : color.from_gradient(color_level, ta.lowest(color_level, heat_sensative), 0, color.aqua, color.yellow)
barcolor(color)

// Plot of Regression_Line
plot(show_line ? Regression_Line : na, color = color.rgb(120, 123, 134, 60), linewidth = 1
 , style = plot.style_stepline_diamond)


// ————— Plot Gauge 
tbl = table.new(position.bottom_center, 100, 10)

for i = 0 to 29 by 1
    table.cell(tbl, i, 1, "",
     bgcolor = i < 15 
      ? color.from_gradient(i, 0, 15, color.aqua, color.yellow) 
         : color.from_gradient(i, 15, 30, color.yellow, color.red)
          )

// Gauge point 
g_p = rescale(color_level, -4, 5, 0, 30)

// Summer Winter marks and gauge point
table.cell(tbl, 0, 1, "❆", text_color = color.rgb(32, 91, 255), text_size = size.large, bgcolor = color.aqua)
table.cell(tbl, 29, 1, "☀︎", text_color = color.rgb(255, 238, 0), text_size = size.large, bgcolor = color.red)

table.cell(tbl, math.round(g_p < 0 ? 0 : g_p), 1, "𖦹", text_color = color.rgb(0, 0, 0), text_size = size.large
 , bgcolor = color)

table.cell(tbl, 35, 0,
 "☀︎ - Summer\n❆ - Winter\n𖦹 - Current Season\n " + "     Value: " + str.tostring(math.round(g_p < 0 ? 0 : g_p)-15),
  text_halign = text.align_left,
   text_color = color.gray
   )


// ❅ ❆ ❃ ❊ ❉ ☀︎ 𖦹
````
