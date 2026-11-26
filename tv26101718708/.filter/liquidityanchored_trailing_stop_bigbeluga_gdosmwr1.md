# Liquidity-Anchored Trailing Stop [BigBeluga]

- url: https://www.tradingview.com/script/gdosMWR1-Liquidity-Anchored-Trailing-Stop-BigBeluga/
- type: indicator
- pine_id: PUB;39722b0f305d421692019d5ad1197324
- version: 2.0

## Description

[b]Liquidity-Anchored Trailing Stop [BigBeluga][/b] is a comprehensive volatility and structural framework designed to provide a protective "heatmap" around price action. By fusing multi-layered ATR-based trailing logic with a dynamic Volume Profile, this indicator identifies where market momentum is accelerating and where institutional liquidity is "anchored."

Instead of a single line, this tool provides a graded risk-mitigation zone that adapts to market noise, ensuring you remain in the trend during healthy pullbacks while identifying the exact structural peaks where volume was most concentrated.

[b]🔵 THE DUAL-ENGINE FRAMEWORK[/b]

[list]
[*] [b]Volatility Heatmap (Trailing Stop):[/b] The indicator calculates four distinct levels of trailing protection (Stop 1 through Stop 4). These are anchored to the trend’s direction and volatility, creating a "safety buffer" that narrows or expands based on the Average True Range (ATR).
[image]https://www.tradingview.com/x/sMxyXwzX/[/image]
[*] [b]Trend-Relative Volume Profile (Right Side):[/b] Unlike static volume profiles, this engine focuses specifically on the current trend segment. It visualizes the total relative volume transacted at each price bin since the last trend flip, highlighting where the real "meat" of the move occurred.
[image]https://www.tradingview.com/x/WN4btYi1/[/image]
[*] [b]High Volume Nodes (HVNs):[/b] The script automatically detects peaks in the volume distribution. These High Volume Nodes represent structural anchors where the market has spent significant time, serving as high-probability zones for support or resistance.
[image]https://www.tradingview.com/x/XBy1JxiO/[/image]
[/list]

[b]🔵 CORE ARCHITECTURE[/b]

[list]
[*] [b]Liquidity Anchoring:[/b] By plotting HVN levels (Structural Peaks), the indicator shows you exactly where liquidity is sitting. When a trailing stop aligns with a volume peak, it creates a "Hard Anchor"—a level that is significantly harder for price to break through.
[*] [b]Adaptive Stop Logic:[/b] The trailing stops (ts1-ts4) use a ratchet mechanism. In an uptrend, the stops only move up; in a downtrend, they only move down. This prevents the "stop-loss creep" that often leads to giving back profits.
[*] [b]Dynamic Gradient Heatmap:[/b] The space between the four trailing bands is filled with a color-coded gradient. Saturated colors represent the core trend, while the outer bands represent the "exhaustion zone" where the trend is at risk of structural failure.
[/list]

[b]🔵 FEATURES[/b]

[list]
[*] [b]Granular Profile Rows:[/b] Fully adjustable vertical resolution (Profile Rows) allows you to define how detailed you want the volume distribution to be, ranging from broad structural areas to precise price levels.
[*] [b]Peak Level Detection:[/b] Horizontal structural lines are automatically drawn across the trend range at major HVNs, providing immediate visual targets and pivot points.
[*] [b]Smart Trend Labels:[/b] Clean UI labels (Bull/Bear) mark the exact bar where the trend flips and the volatility bands reset, ensuring you never miss a shift in market regime.
[*] [b]Visual Clarity Toggle:[/b] Includes options to show or hide the Volume Profile and Peak Levels, allowing you to use the tool as a pure volatility stop or a full-scale market structure map.
[/list]

[b]🔵 STRATEGIC APPLICATION[/b]

[list]
[*] [b]Trailing with the Heatmap:[/b] Use the innermost band (Stop 1) for aggressive scalping or tight management, and the outermost band (Stop 4) for macro trend following. If price closes beyond Stop 4, the trend is officially considered "broken."
[*] [b]HVN Confluence:[/b] Look for instances where the Trailing Stop aligns with a High Volume Node. These "Anchored Stops" are the most robust areas to place your actual exchange orders, as they are backed by both volatility and historical volume.
[*] [b]Volatility Breakouts:[/b] When the ATR bands (Heatmap) contract significantly and then price breaks out, look to the Volume Profile to see if the breakout is supported by a surge in volume at the new price bins.
[*] [b]Targeting Structural Peaks:[/b] In a trending market, use the volume peaks on the right side of the chart as natural take-profit targets or areas to expect temporary price stalls.
[/list]

[b]Liquidity-Anchored Trailing Stop[/b] transforms traditional stop-loss logic into a multi-dimensional map of risk and liquidity. By understanding where volume is anchored and how volatility is breathing, you can stay in winning trades longer and exit with precision when the structure finally fails.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Liquidity-Anchored Trailing Stop [BigBeluga]", overlay=true, max_bars_back = 5000, max_lines_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{


atrLength = input.int(14, "ATR Length", minval=1, group="Calculation Settings", 
     tooltip="The lookback period used for the Average True Range (ATR) calculation to determine market volatility.")

src       = input.source(close, "Source", group="Calculation Settings", 
     tooltip="The price source (e.g., Close, HL2) used as the baseline for the trailing stop calculations.")

mult1     = input.float(6.5, "Band Offset", step=0.1, group="Calculation Settings", 
     tooltip="The base ATR multiplier for the first trailing stop band. Subsequent bands (2, 3, and 4) are calculated by adding +1, +2, and +3 to this value respectively.")

// Incremental offsets logic
mult2 = mult1 + 1
mult3 = mult2 + 1
mult4 = mult3 + 1

//  Volume Profile Inputs 
vp_show   = input.bool(true, "Show Volume Profile", group="Volume Profile", 
     tooltip="Toggle the visibility of the volume profile histogram on the right side of the chart.")

vp_rows   = input.int(30, "Profile Rows", minval=5, maxval=100, group="Volume Profile", 
     tooltip="Defines the vertical granularity by dividing the trend range into this many price bins.")

vp_width  = input.int(40, "Profile Width (Bars)", minval=1, group="Volume Profile", 
     tooltip="The maximum horizontal width of the volume bars, measured in chart bars.")

vp_peaks  = input.bool(true, "Show Peak Levels (HVNs)", group="Volume Profile", inline = "HVNs") 

vp_peaks_st = input.string("Dotted", "", ["Dotted", "Solid", "Dashed"], inline = "HVNs", group="Volume Profile")

vp_peaks_width = input.int(1, "", inline = "HVNs", group="Volume Profile"
     , tooltip="When enabled, the indicator identifies 'High Volume Nodes' where a bin's volume is higher than both its upper and lower neighbors, drawing horizontal structural levels at these points.")

vp_peaks_stl = switch vp_peaks_st
    "Dotted" => line.style_dotted
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed


//  Color Inputs 
bullColor = input.color(color.rgb(26, 209, 96), "Bullish Trend Line", group="Visual Settings", 
     tooltip="Primary color used for the heatmap and volume profile during an uptrend.")

bearColor = input.color(color.rgb(26, 84, 209), "Bearish Trend Line", group="Visual Settings", 
     tooltip="Primary color used for the heatmap and volume profile during a downtrend.")

atrDisp = input.bool(true, "Trailing Stop (Heatmap)", group="Visual Settings")

vp_offset = vp_width + 10
// }



// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

atr = ta.atr(atrLength)

// Initialize variables
var float ts1 = na
var float ts2 = na
var float ts3 = na
var float ts4 = na

var int trend = 1 // 1 for Up, -1 for Down

// Calculate basic offsets
upper1 = src - (atr * mult1)
upper2 = src - (atr * mult2)
upper3 = src - (atr * mult3)
upper4 = src - (atr * mult4)

lower1 = src + (atr * mult1)
lower2 = src + (atr * mult2)
lower3 = src + (atr * mult3)
lower4 = src + (atr * mult4)

// Trend & Trailing Logic
if trend == 1
    if src < ts4[1] 
        trend := -1
        ts1 := lower1
        ts2 := lower2
        ts3 := lower3
        ts4 := lower4
    else
        ts1 := math.max(upper1, nz(ts1[1], upper1))
        ts2 := math.max(upper2, nz(ts2[1], upper2))
        ts3 := math.max(upper3, nz(ts3[1], upper3))
        ts4 := math.max(upper4, nz(ts4[1], upper4))
else
    if src > ts4[1]
        trend := 1
        ts1 := upper1
        ts2 := upper2
        ts3 := upper3
        ts4 := upper4
    else
        ts1 := math.min(lower1, nz(ts1[1], lower1))
        ts2 := math.min(lower2, nz(ts2[1], lower2))
        ts3 := math.min(lower3, nz(ts3[1], lower3))
        ts4 := math.min(lower4, nz(ts4[1], lower4))

//  Visuals & Logic 
activeTrendColor = trend == 1 ? bullColor : bearColor

// Create dynamic heatmap colors based on the trend and user-defined opacity
hColor1 = activeTrendColor

trendChange = trend[1] != trend


lowest = ta.lowest(30)
highest = ta.highest(30)


var trendHigh = high
var trendLow = low

var trendStartBar = 0

if trendChange
    trendHigh:= ts4 > highest ? ts4 : highest
    trendLow := ts4 < lowest ? ts4 : lowest

    trendStartBar := bar_index
else
    trendHigh := math.max(trendHigh, high)
    trendLow := math.min(trendLow, low)


// Plots
plot1 = plot(trendChange ? na : ts1, "Stop 1", color=color.new(activeTrendColor, 80), linewidth=1, style = plot.style_linebr, display = display.none)
plot2 = plot(trendChange ? na : ts2, "Stop 2", color=color.new(activeTrendColor, 50), linewidth=2, style = plot.style_linebr, display = display.none)
plot3 = plot(trendChange ? na : ts3, "Stop 3", color=color.new(activeTrendColor, 25), linewidth=2, style = plot.style_linebr, display = display.none)
plot4 = plot(trendChange ? na : ts4, "Stop 4", color=color.new(activeTrendColor, 0), linewidth=3, style = plot.style_linebr)

// Heatmap Fills
fill(plot1, plot2, color.new(activeTrendColor, 90), title="Inner Heatmap", display = atrDisp ? display.all : display.none)
fill(plot2, plot3, color.new(activeTrendColor, 75), title="Middle Heatmap", display = atrDisp ? display.all : display.none)
fill(plot3, plot4, color.new(activeTrendColor, 60), title="Outer Heatmap", display = atrDisp ? display.all : display.none)


if trendChange 
    
    if trend == 1
        label.new(bar_index, ts4, "▲\nBull", color = na, textcolor = chart.fg_color, style = label.style_label_up)
    else 
        label.new(bar_index, ts4, "Bear\n▼", color = na, textcolor = chart.fg_color, style = label.style_label_down)
// }


// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

//  Volume Profile & Peak Detection 
var box[] vpBoxes = array.new_box()
var line[] vpLines = array.new_line()
var label[] vpLabels = array.new_label()

if barstate.islast
    for b in vpBoxes 
        box.delete(b) 
    for l in vpLines 
        line.delete(l)
    for l in vpLabels 
        label.delete(l)



    array.clear(vpBoxes)
    array.clear(vpLines)
    array.clear(vpLabels)

    float binSize = (trendHigh - trendLow) / vp_rows
    float[] volumes = array.new_float(vp_rows, 0.0)
    float maxVol = 0.0

    // Accumulate volume across the current trend segment
    int lookback = math.min(bar_index, bar_index - trendStartBar+100)
    for i = 0 to lookback
        int binIdx = math.min(vp_rows - 1, math.max(0, int((close[i] - trendLow) / binSize)))
        float v = nz(volume[i])
        float currentBinVol = array.get(volumes, binIdx)
        array.set(volumes, binIdx, currentBinVol + v)
        if (currentBinVol + v) > maxVol
            maxVol := currentBinVol + v

    // Drawing Loop
    for i = 0 to vp_rows - 1
        float vol = array.get(volumes, i)
        float top = trendLow + (binSize * (i + 1))
        float bottom = trendLow + (binSize * i)
        float mid = (top + bottom) / 2
        int boxWidth = int((vol / maxVol) * vp_width)
        color binCol = color.from_gradient(boxWidth, 0, vp_width, color.new(activeTrendColor, 65), activeTrendColor)
        if vp_show
            b = box.new(bar_index + vp_offset+1, top, bar_index + vp_offset - boxWidth, bottom, 
                    bgcolor=binCol, 
                    border_color=chart.bg_color, text = boxWidth == vp_width ? str.tostring(vol, format.volume) : "", text_color = color.rgb(255, 206, 71))
            vpBoxes.push(b)

        // Peak Logic: Check if current bin is higher than its neighbors
        if vp_peaks and i > 0 and i < vp_rows - 1
            float prevVol = array.get(volumes, i - 1)
            float nextVol = array.get(volumes, i + 1)
            
            if vol > prevVol and vol > nextVol
                l = line.new(trendStartBar, mid, bar_index + vp_offset - (vp_show ? boxWidth : 0), mid, 
                     color=binCol, width=boxWidth == vp_width ? 3 : 1, style= boxWidth == vp_width ? line.style_solid : vp_peaks_stl)
                vpLines.push(l)
                
                if boxWidth != vp_width and vp_show
                    b = vpBoxes.get(i)
                    b.set_text(str.tostring(vol, format.volume))
                    b.set_text_color(color.new(chart.fg_color, 40))
            


                if boxWidth == vp_width

                    lbl = label.new(trendStartBar, mid, "", color = binCol, size = size.tiny, style = label.style_circle)
                    lbl1 = label.new(bar_index + vp_offset+1, mid, str.tostring(mid, "(##,###,###.####)"), color = na, textcolor = chart.fg_color, size = size.normal, style = label.style_label_left)

                    vpLabels.push(lbl1)
                    vpLabels.push(lbl)

// }
````
