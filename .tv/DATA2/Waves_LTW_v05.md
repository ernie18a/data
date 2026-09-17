<!-- tradingview-pine-id: PUB;d4b6f211ba794f27bf7d60900b86e019 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Waves [LTW] v0.5

Source: https://www.tradingview.com/script/S3KmBx8p/

## Description

📊Waves [LTW] v0.5

Among all the indicators I have used, the most effective one remains the fundamental volume indicator, which represents the aggregate of buy and sell orders through column heights—a tool we are all familiar with. However, traditional volume indicators are often insufficient for detecting Market Maker (MM) intervention. This is because the MMs driving the crypto market typically utilize institutional-grade services (Prime Brokerage), such as Prime, Institutional/VIP, and OTC desks.

Does this render volume indicators obsolete? Ludwig Wittgenstein argued that our everyday language is, in fact, strictly bound to the rigorous rules of a massive 'language game.' From a similar perspective, price charts are bound by the strict rule that movement requires volume. Therefore, I believe volume remains an absolutely crucial metric.

Inspired by the meme "In the beginning, there was a sine wave," this custom indicator averages the heights of volume columns and applies mathematical filters—such as HMA (Hull Moving Average) for minimal lag and smooth curves, and ALMA (Arnaud Legoux Moving Average) for excellent noise reduction. This process visualizes volume as a smooth curve with specific periodic wavelengths and amplitudes. The indicator identifies "meaningful volume" only when a volume column breaches this wave amplitude, making it highly effective for visual analysis.

---

⚙️ Key Features (Concept)

Sine Waves

▪️ Low Volatility (Calm Waves): In consolidation phases where volume is practically nonexistent, the user-defined colored area flattens against the bottom and moves slowly. This can be interpreted as a phase where energy is being compressed for the next expansion. Alternatively, from an MM's perspective, this is an uninteresting zone with zero volume generation. As volume gradually dries up, it implies a higher probability of reverting to the price point where the previous volume peaked, potentially returning to the immediate Point of Interest (POI). In a bear market, meaningful volume typically occurs only when breaking new lows.

▪️ Volume Spike (Rising Wavelength & Amplitude): The visual representation of the wave gradually rising, hitting a peak, and then descending becomes highly distinct. Near this peak, there is a high probability of witnessing a trend climax or a Liquidity Sweep.

▪️ Measuring Momentum via Divergence (Short-term vs. Long-term Volume Waves): You can intuitively gauge the intensity of market intervention through these wave-like forms.

Divergence Analysis: If the price makes a higher high, but the peak (amplitude) of the volume wave is lower than the previous peak (Bearish Divergence), it signals that the volume momentum driving the trend is fading. This allows you to respond more swiftly to common RSI divergence traps and anticipate various variables. (For example, in Constance Brown's RSI, the median value of 50 is often more critical than standard overbought/oversold levels. It is very common for RSI to peak, rapidly revert to 50, and then continue to make new highs. Standard RSI divergence fails to analyze this "cooling down" process, leading to frequent false signals in strong, one-way trending markets.)

Pulse Waves

When a volume column breaches the wave, a horizontal extension line is drawn from the peak value of that column towards the right side of the chart until the next breakout occurs. This makes it easy to visually analyze whether subsequent volume is greater or less than the previous peak volume.

You can analyze market flow by observing how many smaller Pulse Waves form within a larger Pulse Wave. For instance, you can spot if the peak column of a large wave opened and closed as a bullish candle, but the peaks of the smaller inner waves are consistently closing as bearish candles.

The newly updated Pulse Wave label allows you to intuitively check the quantitative difference between the currently forming volume and the previous peak volume.

---

📌 Settings Guide

1. Waves Length: You can adjust the smoothing length in the settings. Entering Fibonacci numbers like 21, 34, or 55 groups the historical volume data and major market volume cycles into wavelengths. Applying a mathematical smoothing filter (e.g., ALMA) to this grouped data (default is 34) trims the noise (spiky volume columns) to create a perfectly smooth curve.

2. Smooth Mode: To accommodate different trading styles, users can select various smoothing methods. This allows for faster detection of divergences or quicker identification of volume inflows at POI (Point of Interest) zones.

3. Multiplier: This setting determines the release range of the extension line (which resembles a pulse wave) from the peak volume to the next peak volume, without decay.

---

🔥 Practical Trading Tips (Cautions)

This indicator does not provide standalone entry signals (Buy/Sell) like those used by indicator sellers. It is designed to be a supplementary tool. For optimal results, cross-verify your entry positions using professional order book and data aggregators like TapeSurf (formerly Okotoki), or slippage analysis indicators like the Kinetic Slippage Index (KSI) by HPotter. Rather than blindly trusting a single indicator, please use this to establish and refine your own unique trading style.

---

## Source Code

````pine
//@version=6
//© LoopTheWave
indicator('Waves [LTW] v0.5', shorttitle = '🌊Waves [LTW]', overlay = false, format = format.volume)

// =====================================================================
// 1. Tooltip Strings 
// =====================================================================
string tooltip_length = 'Wave Length Adjustment: You can adjust the smoothing length here. Using Fibonacci sequence numbers like 21, 34, or 55 will group the market\'s large volume cycles into smooth, flowing waves.\n\nLow Volatility: In consolidation zones where trading volume is minimal, the line stays completely flat near the bottom. This indicates that energy is condensing for the next expansion.\n\nVolume Spike: The wave gradually rises, peaks, and then falls. Near the absolute peak of this wave, a trend climax or Liquidity Sweep is highly probable.'

string tooltip_smooth = 'ALMA (Arnaud Legoux): Uses a Gaussian filter to draw an exceptionally smooth, sine-wave-like curve with minimal lag. Highly recommended for volume.\n\nHMA (Hull): Extremely fast and responsive. Eliminates lag almost completely, but can look slightly sharper on sudden spikes.\n\nEMA (Exponential): Places more weight on recent volume data. Faster than SMA.\n\nSMA (Simple): Standard average. Smooth, but suffers from the most significant lag.'

// =====================================================================
// 2. Wave Calculation Settings
// =====================================================================
grp_wave = 'Wave Calculation Settings'
length = input.int(55, title = 'Waves Length', minval = 1, tooltip = tooltip_length, group = grp_wave)

// Independent smoothing settings
smoothTypeBase = input.string('HMA', title = 'Smoothing: Base Wave', options = ['ALMA', 'HMA', 'SMA', 'EMA'], tooltip = tooltip_smooth, group = grp_wave)
smoothTypeA    = input.string('HMA', title = 'Smoothing: Multiplier A', options = ['ALMA', 'HMA', 'SMA', 'EMA'], group = grp_wave)
smoothTypeB    = input.string('ALMA', title = 'Smoothing: Multiplier B', options = ['ALMA', 'HMA', 'SMA', 'EMA'], group = grp_wave)

// =====================================================================
// 3. Breakout Multiplier Settings
// =====================================================================
grp_breakout_mult = 'Breakout Multiplier Settings'
breakoutMultA = input.float(2.0, title = 'Multiplier A', step = 0.1, group = grp_breakout_mult)
breakoutMultB = input.float(3.0, title = 'Multiplier B', step = 0.1, group = grp_breakout_mult)

// =====================================================================
// 4. Up / Down Column Colors
// =====================================================================
grp_color_up = 'Up Volume Column Colors'
upNormColor = input.color(color.new(#00897b, 100), title = 'Up Fill (Base)', group = grp_color_up)
upNormBorder = input.color(color.new(#089981, 50), title = 'Up Border (Base)', group = grp_color_up)
upBreakAColor = input.color(color.new(#089981, 30), title = 'Up Fill (Breakout A)', group = grp_color_up)
upBreakABorder = input.color(color.new(#089981, 30), title = 'Up Border (Breakout A)', group = grp_color_up)
upBreakBColor = input.color(color.new(#056656, 0), title = 'Up Fill (Breakout B)', group = grp_color_up)
upBreakBBorder = input.color(color.new(#00332a, 0), title = 'Up Border (Breakout B)', group = grp_color_up)

grp_color_down = 'Down Volume Column Colors'
downNormColor = input.color(color.new(#ff5252, 100), title = 'Down Fill (Base)', group = grp_color_down)
downNormBorder = input.color(color.new(#f23645, 40), title = 'Down Border (Base)', group = grp_color_down)
downBreakAColor = input.color(color.new(#ff5252, 30), title = 'Down Fill (Breakout A)', group = grp_color_down)
downBreakABorder = input.color(color.new(#ff5252, 30), title = 'Down Border (Breakout A)', group = grp_color_down)
downBreakBColor = input.color(color.new(#e91e63, 0), title = 'Down Fill (Breakout B)', group = grp_color_down)
downBreakBBorder = input.color(color.new(#880e4f, 0), title = 'Down Border (Breakout B)', group = grp_color_down)

// =====================================================================
// 5. Label Settings 
// =====================================================================
grp_label = 'Live Label Settings'
lblTextColor = input.color(color.white, title = 'Label Text Color', group = grp_label)
lblTextSizeStr = input.string('Small', title = 'Label Text Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = grp_label)

lblTextSize = lblTextSizeStr == 'Tiny' ? size.tiny : lblTextSizeStr == 'Small' ? size.small : lblTextSizeStr == 'Normal' ? size.normal : lblTextSizeStr == 'Large' ? size.large : size.huge

// =====================================================================
// 6. Smoothing & Threshold Calculations
// =====================================================================
get_smoothed_vol(src, len, type) =>
    float result = na
    if type == 'HMA'
        result := ta.hma(src, len)
    else if type == 'ALMA'
        result := ta.alma(src, len, 0.85, 6)
    else if type == 'EMA'
        result := ta.ema(src, len)
    else
        result := ta.sma(src, len)
    result

// Direct use of input smoothing variables
smoothed_volBase = get_smoothed_vol(volume, length, smoothTypeBase)
smoothed_volA    = get_smoothed_vol(volume, length, smoothTypeA)
smoothed_volB    = get_smoothed_vol(volume, length, smoothTypeB)

threshold_volA = smoothed_volA * breakoutMultA
threshold_volB = smoothed_volB * breakoutMultB

// =====================================================================
// 7. Conditions & Extended Levels
// =====================================================================
isUp = close > open

isBreakoutB = volume >= threshold_volB
isBreakoutA = volume >= threshold_volA and volume < threshold_volB

volColor = isUp ? isBreakoutB ? upBreakBColor : isBreakoutA ? upBreakAColor : upNormColor : isBreakoutB ? downBreakBColor : isBreakoutA ? downBreakAColor : downNormColor
borderColor = isUp ? isBreakoutB ? upBreakBBorder : isBreakoutA ? upBreakABorder : upNormBorder : isBreakoutB ? downBreakBBorder : isBreakoutA ? downBreakABorder : downNormBorder

var float ext_levelA = na
var float ext_levelB = na

if volume >= threshold_volA
    ext_levelA := volume
if volume >= threshold_volB
    ext_levelB := volume

// =====================================================================
// 8. Plotting
// =====================================================================
plotcandle(0, volume, 0, volume, title = 'Volume Columns', color = volColor, bordercolor = borderColor, wickcolor = na, editable = false)

// Hide Y-axis 0 label (display = display.none)
p_zero = plot(0, color = na, title = 'Zero Anchor', display = display.none, editable = false)

p_wave = plot(smoothed_volBase, color = color.new(#2e2e2e, 90), linewidth = 1, style = plot.style_line, title = 'Wave Line')
p_multA = plot(threshold_volA, color = color.new(#808080, 90), linewidth = 1, style = plot.style_line, title = 'Mult A Line')
p_multB = plot(threshold_volB, color = color.new(#dbdbdb, 90), linewidth = 1, style = plot.style_line, title = 'Mult B Line')

fill(p_wave, p_zero, color = color.new(#2e2e2e, 85), title = 'Wave Area')
fill(p_multA, p_zero, color = color.new(#808080, 85), title = 'Mult A Area')
fill(p_multB, p_zero, color = color.new(#b8b8b8, 85), title = 'Mult B Area')

plot(ext_levelA, color = color.new(#ff9800,30), linewidth = 1, style = plot.style_line, title = 'Ext Level A (Peak)')
plot(ext_levelB, color = color.new(#591efd, 30), linewidth = 1, style = plot.style_line, title = 'Ext Level B (Peak)')

// =====================================================================
// 9. Volume Difference Analysis (Data Window & Live Label)
// =====================================================================
diffA = ext_levelA - volume
diffB = ext_levelB - volume

plot(diffA, title = 'Diff to Peak A', color=color.new(color.gray, 100), display = display.data_window)
plot(diffB, title = 'Diff to Peak B', color=color.new(color.gray, 100), display = display.data_window)

format_vol(v) =>
    v_abs = math.abs(v)
    string res = ""
    if v_abs >= 1000000000
        res := str.tostring(v / 1000000000, "#.##") + "B"
    else if v_abs >= 1000000
        res := str.tostring(v / 1000000, "#.##") + "M"
    else if v_abs >= 1000
        res := str.tostring(v / 1000, "#.##") + "K"
    else
        res := str.tostring(v, "#.##")
    res

var label diff_label = na
if barstate.islast
    string txt = "Vol to Break:\n"
    txt += "Peak A: " + (na(ext_levelA) ? "N/A" : (diffA > 0 ? format_vol(diffA) : "Breakout!")) + "\n"
    txt += "Peak B: " + (na(ext_levelB) ? "N/A" : (diffB > 0 ? format_vol(diffB) : "Breakout!"))
    
    // Label Y position (based on the higher of Ext Level A or B)
    float y_pos = math.max(nz(ext_levelA, volume), nz(ext_levelB, volume))
    
    // Apply offset to shift label to the right
    int x_offset = 0 
    
    if na(diff_label)
        diff_label := label.new(bar_index + x_offset, y_pos, text = txt, color = borderColor, style = label.style_label_left, textcolor = lblTextColor, size = lblTextSize, textalign = text.align_center)
    else
        label.set_xy(diff_label, bar_index + x_offset, y_pos)
        label.set_text(diff_label, txt)
        label.set_style(diff_label, label.style_label_left)
        label.set_color(diff_label, borderColor) 
        label.set_textcolor(diff_label, lblTextColor)
        label.set_size(diff_label, lblTextSize)
````
