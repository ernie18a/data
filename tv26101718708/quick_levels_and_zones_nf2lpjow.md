# quick levels and zones

- url: https://www.tradingview.com/script/nf2lpjow-quick-levels-and-zones/
- type: indicator
- pine_id: PUB;1826a1f5dce547729dca488b2977415a
- version: 5.0

## Description

Manual Levels and Zones Plotter is a lightweight, high-utility tool designed to instantly map out your entire technical analysis framework from a single text block. Simply paste your raw text notes, level levels, or automated scanner outputs directly into the indicator settings, and the script handles the rest.

🚀 Key Features
Instant Bulk Plotting: Parses multiple lines of text simultaneously. No more manual line drawings or repeating actions for every single price point.

Dynamic Range & Zone Detection: If a line contains a price range (e.g., 742–746 major resistance zone), the script automatically detects it and draws a shaded visual box (zone) instead of a single line.

Smart Color Coding: Automatically identifies key market terms within your text notes and applies contextual color profiles:

🔴 Red: Exhaustion, Resistance, Outliers

🟢 Green: Support, Expansion Targets

🟠 Orange: Pivot points, Line-in-the-sand levels

⚪ Gray: Standard micro or unclassified levels

Smart Label Staggering: Labels are dynamically staggered off the right edge of the price action (bar_index + spacer) to prevent overlap and maintain a pristine, readable chart view.

Replay & Real-Time Performance Optimized: Built using persistent garbage-collection arrays running strictly on barstate.islast. It renders flawlessly during historical Bar Replay sessions without lagging your chart or cluttering background memory.

🛠 How to Use It
Open the indicator settings window.

In the "Paste Levels Here" text area, paste your levels. Each level must be on its own line, starting with the numeric price value.

Example format:

Plaintext
766.70 outlier monthly resistance
742–746 major resistance zone
733.55 daily pivot / line in the sand
708.43 weekly support
Toggle "Extend Across Entire Screen?" to choose between historical infinite projections or localized, clean right-side tracking.

## Source Code

````pine
//@version=5
indicator("Manual Levels and Zones Plotter", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=50)

// --- Inputs ---
levelsText    = input.text_area(title="Paste Levels Here", defval="766.70 outlier monthly resistance expansion target\n761.15 structural continuation upside target\n756.85 structural continuation upside target\n755.00 outlier weekly resistance expansion target\n746.65 projected resistance / trend continuation breakout line / 745C contract trigger level\n746.23 outlier daily resistance\n745.60 quarterly exhaust resistance\n745.25 structural resistance level\n744.85 weekly exhaust resistance\n744.00 structural continuation upside target\n742.60 daily exhaust resistance\n742–746 major multi-timeframe decision zone / 742.00 long contract trigger level\n741.55 continuation reclaim confirmation level\n738.40 immediate structure level\n738.00 daily resistance\n733.90 immediate structure level\n733.55 daily pivot / bullish trend invalidation level / 733P contract trigger level\n731.67 weekly resistance / downside continuation target\n729.93 daily support / 728P contract trigger level\n727.75 downside continuation target\n726.30 daily exhaust support\n726.20 immediate structure level\n721.80 outlier daily support / 722P contract trigger level\n718.50 weekly pivot / macro trend breakdown confirmation anchor\n708.43 weekly support / macro downside rotation target\n700.00 macro breakout accumulation anchor")
extendRight   = input.bool(title="Extend Across Entire Screen?", defval=true)
zoneFillAlpha = input.int(title="Zone Shading Transparency (0-100)", defval=92, minval=0, maxval=100)

// --- Alignment & Offset Configurations ---
labelOffset   = input.int(title="Label Distance From Price (Bars Offset)", defval=35, minval=1, tooltip="Increase this value if labels overlap your candles or other right-side indicators.")

// --- Color Customization Inputs ---
grpColors    = "Level Colors"
colorBull    = input.color(color.green, title="Bullish (Support/Floor)", group=grpColors)
colorBear    = input.color(color.red, title="Bearish (Resistance)", group=grpColors)
colorPivot   = input.color(color.orange, title="Pivot / Rotation", group=grpColors)
colorTrigger = input.color(color.blue, title="Trigger / Breakout", group=grpColors)
colorOutlier = input.color(color.purple, title="Outlier / Anomaly", group=grpColors)
colorDefault = input.color(color.gray, title="Default (Uncategorized)", group=grpColors)

// --- Style Customization Inputs ---
grpStyles    = "Line & Box Styles"
lineStyleStr = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyles)
lineWidth    = input.int(1, title="Line Width", minval=1, maxval=4, group=grpStyles)

// Helper to convert user string selection into Pine Script line style constant
getLineStyle(styleStr) =>
    styleStr == "Solid" ? line.style_solid : styleStr == "Dashed" ? line.style_dashed : line.style_dotted

userLineStyle = getLineStyle(lineStyleStr)

// Persistent array structure to track and clear old drawing elements
var label[] activeLabels = array.new<label>()
var line[] activeLines = array.new<line>()
var box[] activeBoxes = array.new<box>()

// Simple helper check for numeric strings
isDigit(txtChar) =>
    txtChar == "0" or txtChar == "1" or txtChar == "2" or txtChar == "3" or txtChar == "4" or txtChar == "5" or txtChar == "6" or txtChar == "7" or txtChar == "8" or txtChar == "9" or txtChar == "."

// Execute ONLY on the final tracking bar (handles Replay steps dynamically)
if barstate.islast
    // Clear out drawing elements from the previous replay step
    if array.size(activeLabels) > 0
        for x = 0 to array.size(activeLabels) - 1
            label.delete(array.get(activeLabels, x))
        array.clear(activeLabels)
        
    if array.size(activeLines) > 0
        for x = 0 to array.size(activeLines) - 1
            line.delete(array.get(activeLines, x))
        array.clear(activeLines)
        
    if array.size(activeBoxes) > 0
        for x = 0 to array.size(activeBoxes) - 1
            box.delete(array.get(activeBoxes, x))
        array.clear(activeBoxes)

    linesArray = str.split(levelsText, "\n")
    
    if array.size(linesArray) > 0
        for i = 0 to array.size(linesArray) - 1
            currentLine = str.trim(array.get(linesArray, i))
            if str.length(currentLine) == 0
                continue
                
            // Extract numerical strings from left edge
            priceStr = ""
            charIndex = 0
            lineLength = str.length(currentLine)
            
            for j = 0 to lineLength - 1
                txtChar = str.substring(currentLine, j, j + 1)
                if isDigit(txtChar)
                    priceStr += txtChar
                    charIndex := j + 1
                else
                    break
            
            float priceValue = str.tonumber(priceStr)
            
            // Render elements if validation check passes
            if not na(priceValue) and priceValue > 0
                string labelText = str.trim(str.substring(currentLine, charIndex, lineLength))
                if labelText == ""
                    labelText := priceStr
                    
                // --- High-Fidelity Color Profile Engine ---
                lowerLabel = str.lower(labelText)
                color executionColor = colorDefault 
                
                // Added "downside" to Bearish, "upside" and "accumulation" to Bullish
                isBearish = str.contains(lowerLabel, "resistance") or str.contains(lowerLabel, "exhaust") or str.contains(lowerLabel, "upper") or str.contains(lowerLabel, "downside")
                isBullish = str.contains(lowerLabel, "support") or str.contains(lowerLabel, "floor") or str.contains(lowerLabel, "lower") or str.contains(lowerLabel, "upside") or str.contains(lowerLabel, "accumulation")
                
                // Added "decision" and "structure" to Pivots (removes the gray default for structure levels)
                isPivot   = str.contains(lowerLabel, "pivot") or str.contains(lowerLabel, "sand") or str.contains(lowerLabel, "rotation") or str.contains(lowerLabel, "decision") or str.contains(lowerLabel, "structure")
                
                // Added "breakdown" to Triggers
                isTrigger = str.contains(lowerLabel, "trigger") or str.contains(lowerLabel, "reclaim") or str.contains(lowerLabel, "breakout") or str.contains(lowerLabel, "breakdown")
                
                // Added "macro" to Outliers
                isOutlier = str.contains(lowerLabel, "outlier") or str.contains(lowerLabel, "macro")

                // Map user-defined colors (Reordered for better priority)
                if isOutlier
                    executionColor := colorOutlier    // Catch Outliers & Macro first
                else if isTrigger and not isBearish and not isBullish
                    executionColor := colorTrigger    // Catch standalone triggers next
                else if isBearish
                    executionColor := colorBear       // Then directional resistance
                else if isBullish
                    executionColor := colorBull       // Then directional support
                else if isPivot
                    executionColor := colorPivot      // Finally, catch neutral pivots/structure
                
                // Range / Zone Tracking Logic
                float secondaryPrice = na
                bool isZone = false
                
                if str.contains(labelText, "–") or str.contains(labelText, "-")
                    string secPriceStr = ""
                    bool gatheringDigits = false
                    
                    for k = 0 to str.length(labelText) - 1
                        string c = str.substring(labelText, k, k + 1)
                        if isDigit(c)
                            secPriceStr += c
                            gatheringDigits := true
                        else
                            if gatheringDigits
                                break
                    
                    if secPriceStr != ""
                        secondaryPrice := str.tonumber(secPriceStr)
                        if not na(secondaryPrice) and secondaryPrice != priceValue and secondaryPrice > 0
                            isZone := true

                int startX = extendRight ? bar_index - 500 : bar_index - 30

                // Render dynamic layouts and push elements to tracking garbage collector arrays
                if isZone
                    currentBox = box.new(
                       left=startX, top=math.max(priceValue, secondaryPrice),
                       right=bar_index, bottom=math.min(priceValue, secondaryPrice),
                       xloc=xloc.bar_index,
                       extend=extendRight ? extend.both : extend.right,
                       bgcolor=color.new(executionColor, zoneFillAlpha),
                       border_color=color.new(executionColor, 50),
                       border_style=userLineStyle, // Applies user-selected style
                       border_width=lineWidth      // Applies user-selected width
                       )
                    array.push(activeBoxes, currentBox)
                    
                    // Clean up label range text structure
                    int textCleanIdx = 0
                    for m = 0 to str.length(labelText) - 1
                        string charCheck = str.substring(labelText, m, m + 1)
                        if not isDigit(charCheck) and charCheck != "–" and charCheck != "-" and charCheck != " "
                            textCleanIdx := m
                            break
                    labelText := str.substring(labelText, textCleanIdx, str.length(labelText))
                else
                    currentLineElement = line.new(
                       x1=startX, y1=priceValue,
                       x2=bar_index, y2=priceValue,
                       xloc=xloc.bar_index,
                       extend=extendRight ? extend.both : extend.right,
                       color=color.new(executionColor, 30),
                       style=userLineStyle,       // Applies user-selected style
                       width=lineWidth            // Applies user-selected width
                       )
                    array.push(activeLines, currentLineElement)
                   
                // Render flat, left-justified descriptions cleanly sitting ABOVE your drawing paths
                string displayPrice = isZone ? str.tostring(priceValue) + "–" + str.tostring(secondaryPrice) : priceStr
                
                currentLabel = label.new(
                   x=bar_index + labelOffset, y=priceValue,
                   text=labelText + " (" + displayPrice + ")\n", 
                   xloc=xloc.bar_index,
                   style=label.style_label_left,        
                   textalign=text.align_left,           
                   color=color.new(color.black, 100),   
                   textcolor=executionColor,
                   size=size.normal
                   )
                array.push(activeLabels, currentLabel)
````
