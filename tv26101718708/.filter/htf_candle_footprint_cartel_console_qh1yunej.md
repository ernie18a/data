# HTF Candle Footprint [Cartel Console]

- url: https://www.tradingview.com/script/Qh1YuNeJ-HTF-Candle-Footprint-Cartel-Console/
- type: indicator
- pine_id: PUB;ca3ff4e904ad48d28e83d404c064984a
- version: 1.0

## Description

# HTF Candle Footprint [Cartel Console]

HTF Candle Footprint [Cartel Console] is a higher-timeframe volume and delta visualization tool designed to help traders analyze the internal composition of a selected higher-timeframe candle directly on the chart.

The indicator reconstructs a footprint-style profile inside a dynamically generated higher-timeframe candle, allowing users to examine how volume and directional pressure were distributed throughout the candle's range. By combining volume distribution, delta estimation, Point of Control (POC), and higher-timeframe candle structure into a single visualization, traders can gain additional context about market participation and price acceptance within significant trading periods.

Unlike traditional volume profiles that focus on extended historical ranges, this indicator concentrates on the currently developing or recently completed higher-timeframe candle. This approach enables users to study how volume accumulates across price levels while simultaneously monitoring the relationship between bullish and bearish activity inside the candle body.

### Key Features

• Higher-Timeframe Candle Reconstruction
Displays a custom-rendered higher-timeframe candle directly on the chart, including body and wick structure.

• Integrated Footprint Visualization
Shows estimated buying and selling pressure across individual price levels within the selected higher-timeframe range.

• Volume Distribution Profile
Builds a horizontal volume profile that highlights where the greatest amount of trading activity occurred during the analyzed period.

• Delta-Based Pressure Analysis
Calculates directional volume estimates and displays positive and negative pressure zones using color-coded footprint cells.

• Point of Control (POC) Detection
Automatically identifies and plots the highest-volume price level within the profile.

• Dynamic High and Low Levels
Marks the extreme boundaries of the analyzed higher-timeframe candle for additional market structure reference.

• Real-Time Higher-Timeframe Bias Dashboard
Provides a compact dashboard showing the current directional bias of the selected higher-timeframe candle.

• Multi-Timeframe Support
Analyze volume and pressure behavior across Hourly, 4-Hour, Daily, Weekly, and Monthly structures.

### How Traders Use It

Many traders use higher-timeframe candles as key reference points for trend analysis, support and resistance identification, liquidity observations, and contextual decision-making. HTF Candle Footprint [Cartel Console] enhances this process by exposing the internal volume distribution of those candles.

Potential use cases include:

• Identifying high-participation price zones
• Observing areas of price acceptance and rejection
• Comparing volume concentration against candle structure
• Locating potential reaction levels around the Point of Control
• Studying directional pressure within higher-timeframe ranges
• Adding additional context to multi-timeframe analysis workflows

### Notes

This indicator uses volume-based calculations and visual approximations derived from chart data. The displayed footprint and delta values are analytical tools intended to provide additional market context and should not be interpreted as financial advice or guaranteed trading signals.

HTF Candle Footprint [Cartel Console] is designed as a visual analysis aid and can be used alongside existing price action, volume, market structure, and risk management methodologies.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CartelConsole

//@version=6
indicator("HTF Candle Footprint [Cartel Console]", overlay = true, max_boxes_count = 500, max_polylines_count = 100, max_lines_count = 500, max_bars_back = 5000, max_labels_count = 500)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

tf     = input.timeframe("1W", "TimeFrame", ["60", "240", "1D", "1W", "1M"], tooltip = "1H, 4H, Daily, Weekly, Monthly")
offset = input.int(15, "Profile Offset")
minPeriod = input.int(10, "Min Period Profile")
showDash = input.bool(true, "Show Dashboard")

bullishColor = input.color(#81f9fd, "Bullish Color", inline = "candle")
bearishColor = input.color(color.new(#fd0318, 0), "Bearish Color", inline = "candle")
textColor = input.color(color.white, "Text Color", inline = "candle")

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{

var int startBar = na
var int prevStartBar = na
var float htfOpen = na
var float prevHtfOpen = na

if timeframe.change(tf)
    prevStartBar := startBar
    prevHtfOpen := htfOpen
    startBar := bar_index
    htfOpen := open

int period = 0
float Op = na
float Cl = close

if bar_index - startBar < minPeriod and not na(prevStartBar)
    period := bar_index - prevStartBar
    Op := prevHtfOpen
else
    period := bar_index - startBar
    Op := htfOpen

atr = ta.atr(200) * 0.3

type Profile 
    array<line> lines 
    array<box> boxes
    array<label> labels

var ProfileDraws = array.new<Profile>()

// Dashboard
var table dash = table.new(position.top_right, 2, 2, bgcolor = color.rgb(54, 58, 69, 58), border_color = color.gray, border_width = 1)
if showDash and barstate.islast
    table.cell(dash, 0, 0, "HTF Bias", text_color = textColor)
    biasText = Cl > Op ? "BULLISH" : "BEARISH"
    biasColor = Cl > Op ? bullishColor : bearishColor
    table.cell(dash, 1, 0, biasText, text_color = biasColor)

if barstate.islast and not na(Op)
    HL  = array.new<float>()
    if period > 0
        for i = 0 to period
            HL.push(high[i])
            HL.push(low[i])

    maxH = HL.size() > 0 ? HL.max() : high
    minL = HL.size() > 0 ? HL.min() : low

    if ProfileDraws.size() > 0
        for p in ProfileDraws
            for l in p.lines
                l.delete()
            for b in p.boxes
                b.delete()
            for l in p.labels
                l.delete()
        ProfileDraws.clear()

    Height  = (maxH - minL)
    size    = math.max(1, math.ceil(Height / math.max(atr, syminfo.mintick)))
    step    = Height / size
    
    binsVol   = array.new<float>(size, 0.)
    binsDelta = array.new<float>(size, 0.)
    maxVol = 0.0
    pocIndex = 0
        
    if period > 0
        for k = 0 to period
            CloseK = close[k]
            OpenK  = open[k]
            VolK   = volume[k]
            DeltaK = CloseK > OpenK ? VolK : CloseK < OpenK ? -VolK : 0.0
            
            for i = 0 to size - 1
                loww = minL + step * i 
                mid  = loww + step/2 
                if math.abs(CloseK - mid) <= step        
                    binsVol.set(i, binsVol.get(i) + VolK)
                    binsDelta.set(i, binsDelta.get(i) + DeltaK)
                    if binsVol.get(i) > maxVol
                        maxVol := binsVol.get(i)
                        pocIndex := i

    Lines = array.new<line>()
    Boxes = array.new<box>()
    Labels = array.new<label>()

    BarColor = Cl > Op ? bullishColor : bearishColor
    indxBar = bar_index + offset + 5
    
    bodyTop = math.max(Op, Cl)
    bodyBot = math.min(Op, Cl)

    // Wick Glow
    Lines.push(line.new(indxBar + 3, maxH, indxBar + 3, minL, color = color.new(BarColor, 90), width = 8))
    Lines.push(line.new(indxBar + 3, maxH, indxBar + 3, minL, color = color.new(BarColor, 75), width = 5))
    // Wick
    Lines.push(line.new(indxBar + 3, maxH, indxBar + 3, minL, color = BarColor, width = 2))

    // Body Glow
    Boxes.push(box.new(indxBar + 1, bodyTop, indxBar + 6, bodyBot, border_color = color(na), bgcolor = color.new(BarColor, 90)))
    Boxes.push(box.new(indxBar + 2, bodyTop, indxBar + 5, bodyBot, border_color = color(na), bgcolor = color.new(BarColor, 75)))
    // Body
    Boxes.push(box.new(indxBar + 3, bodyTop, indxBar + 4, bodyBot, border_color = color(na), bgcolor = BarColor))

    maxDelta = 0.0
    for i = 0 to size - 1
        d = math.abs(binsDelta.get(i))
        if d > maxDelta
            maxDelta := d

    // Volume Profile extending left & Delta Boxes in body
    for i = 0 to size-1
        bot = minL + step * i
        top = bot + step 
        mid = bot + step / 2
        vVal = binsVol.get(i)
        dVal = binsDelta.get(i)
        
        if maxVol > 0
            volLength = math.round((vVal / maxVol) * 15)
            if volLength > 0
                // Dual colored vertical gradient for the volume profile boxes
                gradCol = color.from_gradient(mid, minL, maxH, bearishColor, bullishColor)
                volBox = box.new(indxBar - 3 - volLength, top, indxBar - 3, bot, border_color = color.new(gradCol, 50), bgcolor = color.new(gradCol, 80))
                Boxes.push(volBox)
        
        // Draw delta data if within candle body
        if mid >= bodyBot and mid <= bodyTop
            deltaRatio = maxDelta > 0 ? math.abs(dVal) / maxDelta : 0
            bgCol = dVal > 0 ? color.new(bullishColor, 100 - math.round(deltaRatio * 60)) : dVal < 0 ? color.new(bearishColor, 100 - math.round(deltaRatio * 60)) : color.new(#787b86, 3)
            
            deltaBox = box.new(indxBar - 3, top, indxBar + 3, bot, border_color = #787b86f5, border_width = 1, bgcolor = bgCol)
            Boxes.push(deltaBox)
            
            deltaLabel = label.new(indxBar, mid, str.tostring(math.round(dVal)), textcolor = textColor, style = label.style_label_center, color = color(na), size = size.tiny)
            Labels.push(deltaLabel)

    // High Line and Label
    Lines.push(line.new(indxBar - 20, maxH, indxBar + 5, maxH, color = bullishColor, style = line.style_dashed))
    Labels.push(label.new(indxBar + 5, maxH, "High: " + str.tostring(maxH, format.mintick), style = label.style_label_down, color = color(na), textcolor = bullishColor, size = size.small))

    // Low Line and Label
    Lines.push(line.new(indxBar - 20, minL, indxBar + 5, minL, color = bearishColor, style = line.style_dashed))
    Labels.push(label.new(indxBar + 5, minL, "Low: " + str.tostring(minL, format.mintick), style = label.style_label_up, color = color(na), textcolor = bearishColor, size = size.small))

    // POC Line
    pocY = minL + step * pocIndex + (step / 2)
    Lines.push(line.new(indxBar - 18, pocY, indxBar + 3, pocY, color = color.new(color.orange, 0), style = line.style_dashed))

    ProfileDraws.push(Profile.new(Lines, Boxes, Labels))
````
