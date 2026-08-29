<!-- tradingview-pine-id: PUB;61fc44c3cc6942aab0660e8d9ae0ef34 -->
<!-- tradingviewscripts-format: 1 -->
# Log Regression Oscillator Channel [BigBeluga]

Source: https://www.tradingview.com/script/eR9y7zmm-Log-Regression-Oscillator-Channel-BigBeluga/

## Description

This unique overlay tool blends logarithmic trend analysis with dynamic oscillator behavior. It projects RSI, MFI, or Stochastic lines directly into a log regression channel on the price chart — offering an intuitive way to detect overbought/oversold momentum within the broader price structure.

[image]https://www.tradingview.com/x/u1k5N1jh/[/image]

🔵Key Features:  
  
[*] Logarithmic Regression Channel:  
   ➣ Draws a trend-based channel using logarithmic regression, adapting to price growth curvature over time.  
   ➣ Features upper, lower, and optional midline boundaries to visualize trend flow and range extremes.  
[image]https://www.tradingview.com/x/Y7hxmKgf/[/image]

[*] Oscillator Overlay (RSI / MFI / Stochastic):  
   ➣ Projects your chosen oscillator inside the channel using dynamic polylines.  
   ➣ Allows switching between RSI, Money Flow Index, or Stochastic for versatile momentum insight.  
[image]https://www.tradingview.com/x/zr4LwtZr/[/image]
[image]https://www.tradingview.com/x/vjE7fbHh/[/image]
[image]https://www.tradingview.com/x/urEuvx6r/[/image]

[*] Threshold-Based Scaling:  
   ➣ The top and bottom of the channel represent traditional oscillator thresholds (e.g., RSI 70/30).  
   ➣ Users can modify the scale in settings to customize what "overbought" or "oversold" means visually.  
[image]https://www.tradingview.com/x/t1a0Kk9T/[/image]

[*] Signal Line Integration:  
   ➣ Adds a yellow moving average (signal line) for smoother confirmation of oscillator turns.  
   ➣ Helps identify divergence, momentum shifts, and fakeouts with better clarity.  
[image]https://www.tradingview.com/x/KaU1Saw8/[/image]

[*] Live Oscillator Readout:  
   ➣ Displays the real-time oscillator value at the right edge of the chart.  
   ➣ Ensures traders stay aware of current momentum levels without switching panels.  
[image]https://www.tradingview.com/x/qDU8lmbx/[/image]

🔵Usage:  
  
[*] Momentum Context:  
   ➣ When the oscillator touches the upper regression band, it may signal local overbought pressure.  
   ➣ Touching the lower band may indicate oversold conditions within the current log trend.  

[*] Divergence Detection:  
   ➣ Use the oscillator’s behavior relative to the channel slope to spot divergence from price.  
   ➣ For example, RSI rising inside a falling channel can flag early trend shifts.  

[*] Trend-Sensitive Entries:  
   ➣ Combine oscillator signals with log channel direction to filter trades in trend alignment.  
   ➣ Signal line crossovers inside the channel act as early warning for momentum turns.  

The Log Regression Oscillator Channel [BigBeluga] transforms how traders view classic momentum tools. By embedding oscillators into a logarithmic trend structure, it offers unmatched clarity on momentum positioning relative to price expansion. Ideal for swing traders, mean-reverters, or trend followers looking to sharpen entries and exits with style.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Log Regression Oscillator Channel [BigBeluga]", overlay=true, max_bars_back = 500)


// ＩＮＰＵＴＳ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
int   length        = input.int(150, "Lookback Period", group = "Channel")
float channel_width = input.float(1.5, "Channel Width", step = 0.1, group = "Channel")

bool  mid_disp      = input.bool(true, "Mid Line", inline = "s", group = "Channel")
bool  fill_band     = input.bool(true, "Fill Background", inline = "s", group = "Channel")
color col_up        = input.color(#a7abb9, "Channel Lines Color:ㅤㅤUpper", group = "Channel", inline = "Col")
color col_mid       = input.color(color.gray, "Mid", group = "Channel", inline = "Col")
color col_low       = input.color(#a7abb9, "Lower", group = "Channel", inline = "Col")

string osc          = input.string("RSI", "Type:", ["RSI", "STOCHASTIC", "STOCHASTIC RSI", "MFI"], group = "Oscillator", inline = "osc")
int lengtht         = input.int(14, "", group = "Oscillator", inline = "osc")
color osc_col       = input.color(#7e57c2, "", group = "Oscillator", inline = "osc")
int upper_threshold = input.int(70, "Scale", group = "Oscillator", inline = "osc1")

bool sig_disp       = input.bool(true, "Signal Line", inline = "sig")
int length_sig      = input.int(14, "", inline = "sig")
color sig_line      = input.color(color.yellow, "", inline = "sig") 
// }

// ＬＯＧＡＲＩＴＨＭＩＣ ＲＥＧＲＥＳＳＩＯＮ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
f_log_regression(src, length) =>
    float sumX      = 0.0
    float sumY      = 0.0
    float sumXSqr   = 0.0
    float sumXY     = 0.0

    for i = 0 to length - 1
        val = math.log(src[i])
        per = i + 1.0
        sumX += per
        sumY += val
        sumXSqr += per * per
        sumXY += val * per

    slope = (length * sumXY - sumX * sumY) / (length * sumXSqr - sumX * sumX)
    intercept = (sumY - slope * sumX) / length

    [slope, intercept]

// Get regression slope & intercept
[slope, intercept] = f_log_regression(close, length)

// Calculate start & end points of the regression line
float reg_start = math.exp(intercept + slope * length)
float reg_end   = math.exp(intercept)

// Compute deviation for channel width
float deviation = ta.stdev(close, length)

// Calculate channel boundaries
float upper_start = reg_start + deviation * channel_width
float upper_end   = reg_end + deviation * channel_width
float lower_start = reg_start - deviation * channel_width
float lower_end   = reg_end - deviation * channel_width

// Create Line Objects
var line mid_line  = na
var line upper_line = na
var line lower_line = na

// Draw Regression Channel with Straight Lines
if na(mid_line) and mid_disp
    mid_line := line.new(bar_index[length], reg_start, bar_index, reg_end, color=col_mid, style=line.style_dashed)
else 
    mid_line.set_xy1(bar_index[length], reg_start)
    mid_line.set_xy2(bar_index, reg_end)

if na(upper_line)
    upper_line := line.new(bar_index[length], upper_start, bar_index, upper_end, width=2, color=col_up)
else 
    upper_line.set_xy1(bar_index[length], upper_start)
    upper_line.set_xy2(bar_index, upper_end)

if na(lower_line)
    lower_line := line.new(bar_index[length], lower_start, bar_index, lower_end, width=2, color=col_low)
else 
    lower_line.set_xy1(bar_index[length], lower_start)
    lower_line.set_xy2(bar_index, lower_end)

// Debug: Label to check the slope value
slope_ = (reg_start - reg_end) / length
lower_threshold = 100 - upper_threshold
step = (upper_end - lower_end) / (upper_threshold-lower_threshold)

rsi = ta.rsi(close, lengtht)
k1 = ta.sma(ta.stoch(rsi, rsi, rsi, lengtht), 3)

Oscillator = switch osc
    "RSI" => rsi
    "MFI" => ta.mfi(hlc3, lengtht) 
    "STOCHASTIC" => ta.stoch(close, high, low, lengtht) 
    'STOCHASTIC RSI' => k1

sma_osc = ta.sma(Oscillator, length_sig)

polyline_disp(float src, bool display, bool shadow = true, color_, width = 1)=>

    if barstate.islast and display
        points = array.new<chart.point>()

        for i = 0 to length - 1
            val = src[i] - lower_threshold
            lower = lower_end + slope_ * i 
            cp  = chart.point.from_index(bar_index[i], lower + step * val)

            points.push(cp)

        p1 = polyline.new(points, line_color = color_, closed = false, force_overlay = true, line_width = width)

        polyline.delete(p1[1])

        if shadow
            label.delete(label.new(bar_index, lower_end + step * (src - lower_threshold), osc + str.tostring(Oscillator, ":  ##.#"), style = label.style_label_left, color = color(na), textcolor = chart.fg_color)[1])
                        
            label.delete(label.new(bar_index, lower_end, str.tostring(lower_threshold, " ##.#"), style = label.style_label_left, color = color(na), textcolor = chart.fg_color)[1])
            label.delete(label.new(bar_index, upper_end, str.tostring(upper_threshold, " ##.#"), style = label.style_label_left, color = color(na), textcolor = chart.fg_color)[1])
                
// }


// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
if fill_band
    linefill.new(upper_line, lower_line, color.new(osc_col, 90))

polyline_disp(Oscillator, true, true, osc_col, 2)
polyline_disp(sma_osc, sig_disp, false, sig_line)

// }
````
