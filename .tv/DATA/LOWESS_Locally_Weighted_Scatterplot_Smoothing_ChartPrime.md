<!-- tradingview-pine-id: PUB;9f9f713bc85b431e84afe7178496ab62 -->
<!-- tradingviewscripts-format: 1 -->
# LOWESS (Locally Weighted Scatterplot Smoothing) [ChartPrime]

Source: https://www.tradingview.com/script/hyeoDyZn-LOWESS-Locally-Weighted-Scatterplot-Smoothing-ChartPrime/

## Description

LOWESS (Locally Weighted Scatterplot Smoothing) [ChartPrime]

⯁ OVERVIEW
The LOWESS (Locally Weighted Scatterplot Smoothing) [ChartPrime] indicator is an advanced technical analysis tool that combines LOWESS smoothing with a Modified Adaptive Gaussian Moving Average. This indicator provides traders with a sophisticated method for trend analysis, pivot point identification, and breakout detection.

◆ KEY FEATURES

[*] LOWESS Smoothing: Implements Locally Weighted Scatterplot Smoothing for trend analysis.
[*] Modified Adaptive Gaussian Moving Average: Incorporates a volatility-adapted Gaussian MA for enhanced trend detection.
[*] Pivot Point Identification: Detects and visualizes significant pivot highs and lows.
[*] Breakout Detection: Tracks and optionally displays the count of consecutive breakouts.
[*] Gaussian Scatterplot: Offers a unique visualization of price movements using randomly colored points.
[*] Customizable Parameters: Allows users to adjust calculation length, pivot detection, and visualization options.

◆ FUNCTIONALITY DETAILS

⬥ LOWESS Calculation:

[*] Utilizes a weighted local regression to smooth price data.
[*] Adapts to local trends, reducing noise while preserving important price movements.

⬥ Modified Adaptive Gaussian Moving Average:

[*] Combines Gaussian weighting with volatility adaptation using ATR and standard deviation.
[*] Smooths the Gaussian MA using LOWESS for enhanced trend visualization.

⬥ Pivot Point Detection and Visualization:

[*] Identifies pivot highs and lows using customizable left and right bar counts.
[*] Draws lines and labels to mark broke pivot points on the chart.

⬥ Breakout Tracking:

[*] Monitors price crossovers of pivot lines to detect breakouts.
[*] Optionally displays and updates the count of consecutive breakouts.

◆ USAGE

[*] Trend Analysis: Use the color and direction of the smoothed Gaussian MA line to identify overall trend direction.
[*] Breakout Trading: Monitor breakouts from pivot levels and their persistence using the breakout count feature.
[*] Volatility Assessment: The spread of the Gaussian scatterplot can provide insights into market volatility.

⯁ USER INPUTS

[*] Length: Sets the lookback period for LOWESS and Gaussian MA calculations (default: 30).
[*] Pivot Length: Determines the number of bars to the left for pivot calculation (default: 5).
[*] Count Breaks: Toggle to show the count of consecutive breakouts (default: false).
[*] Gaussian Scatterplot: Toggle to display the Gaussian MA as a scatterplot (default: true).

⯁ TECHNICAL NOTES

[*] Implements a custom LOWESS function for efficient local regression smoothing.
[*] Uses a modified Gaussian MA calculation that adapts to market volatility.
[*] Employs Pine Script's line and label drawing capabilities for clear pivot point visualization.
[*] Utilizes random color generation for the Gaussian scatterplot to enhance visual distinction between different time periods.

The LOWESS (Locally Weighted Scatterplot Smoothing) [ChartPrime] indicator offers traders a sophisticated tool for trend analysis and breakout detection. By combining advanced smoothing techniques with pivot point analysis, it provides a comprehensive view of market dynamics. The indicator's adaptability to different market conditions and its customizable nature make it suitable for various trading styles and timeframes.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime

//@version=5
indicator("LOWESS (Locally Weighted Scatterplot Smoothing) [ChartPrime]", "Lowess & GaussianMA [ChartPrime]",
         overlay            = true,
         max_lines_count    = 500,
         max_labels_count   = 500)


// ---------------------------------------------------------------------------------------------------------------------}
// 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎 
// ---------------------------------------------------------------------------------------------------------------------{

// @variable Length for LOWESS calculation
int length      = input.int(30, minval=1, title="Length", group = "LOWESS (Locally Weighted Scatterplot Smoothing)")

// @variable Number of bars to the left for pivot calculation
int leftBars    = input.int(5, "Length", group = "Pivots")
// @variable Number of bars to the right for pivot calculation
int rightBars   = leftBars - 2
// @variable Toggle to show break count
bool show_count = input.bool(false, "Count Breaks", group = "===")
// @variable Toggle to show Gaussian scatterplot
bool Gaussian_plot = input.bool(false, "Gaussian Scatterplot")

// @variable Line object for high pivot
var line line_h = na
// @variable Line object for low pivot
var line line_l = na

// @variable Label object for high pivot
var label lbl_h = na
// @variable Label object for low pivot
var label lbl_l = na

// @variable Counter for upward breaks
var count_up    = 0
// @variable Counter for downward breaks
var count_dn    = 0

// @variable Color for upward movements
color col_up = #60befd
// @variable Color for downward movements
color col_dn = #ab61ff


// ---------------------------------------------------------------------------------------------------------------------}
// 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// ---------------------------------------------------------------------------------------------------------------------{

// Calculate pivot high and low
ph = ta.pivothigh(leftBars, rightBars)
pl = ta.pivotlow(leftBars, rightBars)

//@function Calculates LOWESS (Locally Weighted Scatterplot Smoothing)
//@param src (float) Source series
//@param length (int) Lookback period
//@returns (float) LOWESS value
lowess(src, length) =>
    sum_w = 0.0
    sum_wx = 0.0
    sum_wy = 0.0
    for i = 0 to length - 1
        w = math.pow(1 - math.pow(i / length, 3), 3)
        sum_w += w
        sum_wx += w * i
        sum_wy += w * src[i]
    a = sum_wy / sum_w
    b = sum_wx / sum_w
    a + b / (length - 1) / 2000

//@function Calculates Modified Adaptive Gaussian Moving Average
//@param src (float) Source series
//@param length (int) Lookback period
//@returns [float, float] Gaussian MA and smoothed Gaussian MA
GaussianMA(src, length)=>
    h_l                = array.new<float>(length)

    float gma          = 0.0
    float sumOfWeights = 0.0
    float sigma        = (ta.atr(length) + ta.stdev(close, length)) / 2  // Volatility adaption
    float highest      = 0.0
    float lowest       = 0.0
    float smoothed     = 0.0

    for i = 0 to length - 1
        h_l.push(close[i])
        highest      := h_l.max()
        lowest       := h_l.min()
        weight        = math.exp(-math.pow(((i - (length - 1)) / (2 * sigma)), 2) / 2)
        value         = math.max(highest[i], highest) + math.min(lowest[i], lowest)
        gma          := gma + (value * weight)
        sumOfWeights += weight

    gma := (gma / sumOfWeights) / 2

    smoothed := lowess(gma, 10)

    [gma, smoothed]

[gma, smoothed] = GaussianMA(close, length)

// Generate random color for Gaussian MA plot
random1       = math.random(0, 255)
gmaColor      = color.rgb(random1, random1, random1)

// Determine color for smoothed line based on its direction
smoothedColor =    smoothed > smoothed[2]  ? col_up 
                 : smoothed <= smoothed[2]  ? col_dn 
                 : na


// ---------------------------------------------------------------------------------------------------------------------}
// 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// ---------------------------------------------------------------------------------------------------------------------{

plot(gma, "Gaussian Moving Average", bar_index % 4 == 0 ? (Gaussian_plot ? gmaColor : na) : na, 1, plot.style_cross)

plot(smoothed, "Gaussian Moving Average", smoothedColor)
plot(smoothed, "Gaussian Moving Average", color.new(smoothedColor, 80), 5)

// Draw lines and labels for pivot highs
if smoothedColor == col_up and ph
    line_h := line.new(bar_index[rightBars], high[rightBars], bar_index[rightBars], high[rightBars])
    lbl_h  := label.new(na, high[rightBars], "⬥",color = #00000000, textcolor = col_up, size = size.large)

// Handle crossovers for pivot highs
if ta.crossover(close, line_h.get_y1())
    count_dn := 0
    count_up += 1
    line_h.set_x2(bar_index),  line_h.set_color(color.new(col_up, 30))
    lbl_h.set_x(bar_index)

    if not show_count
        lbl_h.set_style(label.style_label_center)
    if show_count
        lbl_h.set_y(high)
        lbl_h.set_size(size.normal)    
        lbl_h.set_style(label.style_label_down)
        lbl_h.set_text(str.tostring(count_up))

    line_h := na    

// Draw lines and labels for pivot lows
if smoothedColor == col_dn and pl
    line_l := line.new(bar_index[rightBars], low[rightBars], bar_index[rightBars], low[rightBars])
    lbl_l  := label.new(na, low[rightBars], "⬥", color = #00000000, textcolor = col_dn, size = size.large)

// Handle crossunders for pivot lows
if ta.crossunder(close, line_l.get_y1())
    count_up := 0
    count_dn += 1
    line_l.set_x2(bar_index),  line_l.set_color(color.new(col_dn, 30))
    lbl_l.set_x(bar_index)

    if not show_count
        lbl_l.set_style(label.style_label_center)
    if show_count
        lbl_l.set_y(low)
        lbl_l.set_size(size.normal)  
        lbl_l.set_style(label.style_label_up)
        lbl_l.set_text(str.tostring(count_dn))

    line_l := na

// Trend Change Points
plotshape(smoothed, "",
 shape.diamond, 
 location.absolute, 
 color  = ta.crossover(smoothed, smoothed[2]) ? col_up : ta.crossunder(smoothed, smoothed[2]) ? col_dn : na, 
 offset = 0, 
 size   = size.tiny
 )

// ---------------------------------------------------------------------------------------------------------------------}
````
