# Mentor Q Locked Levels Engine 4h

- url: https://www.tradingview.com/script/zi7J4RIx-Mentor-Q-Locked-Levels-Engine-4h/
- type: indicator
- pine_id: PUB;d04ed6f49fbd4b418acbe0e20b5ddaee
- version: 1.0

## Description

You are an expert data parsing assistant. I am going to provide you with an XML file containing financial market levels. Your task is to extract specific attributes and convert them into a raw text format compatible with my custom TradingView Pine Script indicator.

Strictly adhere to the following formatting guidelines for each valid level found:
1. Every line must follow this exact syntax:
Level=VALUE; Name="LABEL (TICKER)"; Color=HEX_OR_FALLBACK; Style=STYLE_TYPE; LineWidth=2

2. Formatting Rules:
- 'Level': Extract the exact price or numerical value.
- 'Name': Combine the level's description/name with its asset symbol inside parentheses—e.g., Name="1D Max (QQQ)". It must be enclosed in double quotes.
- 'Color': Map the color to hex format (e.g., #FE0000 for Red, #FF9800 for Orange, #4CAF50 for Green, #2962FF for Blue, #20BDBD for Teal). If the XML color is missing or unclear, assign a fallback based on the level name.
- 'Style': Must be exactly "Solid", "Dashed", or "Dotted".
- 'LineWidth': Keep it consistently at 2.

3. Output Constraints:
- Do NOT include any markdown headers, conversational text, introduction, or explanations. 
- Do NOT group them by headers like "=== QQQ ===". Just output the raw lines directly.
- Output ONLY the clean, copy-and-paste ready text rows.

Here is the XML data to process:

## Source Code

````pine
//@version=5
indicator("Mentor Q Locked Levels Engine", overlay=true, max_lines_count=500, max_labels_count=500)

// Large text block input
var string G_DATA = "Data Input Configuration"
string dataSrc = input.text_area(
     defval = 'Level=30000.00; Name="Call Resistance (NQ1!)"; Color=#FE0000; Style=Dashed; LineWidth=2\nLevel=29930.56; Name="1D Max (NQ1!)"; Color=#FF9800; Style=Solid; LineWidth=2', 
     title  = "Paste Configuration Text Here", 
     group  = G_DATA
 )

// Styling Controls
var string G_STYLE = "Global Label Configuration"
string labelAlignInput = input.string("Right", "Label Horizontal Alignment", options=["Left", "Right"], group=G_STYLE)
int offsetBars          = input.int(15, "Label Offset (Bars Past Current Bar)", minval=0, group=G_STYLE)
int lineLeftExtension  = input.int(100, "Line Left Extension (Bars)", minval=1, group=G_STYLE)

// Helper function to extract parameter values safely
extractValue(string lineStr, string key) =>
    string result = ""
    int keyIdx = str.pos(lineStr, key + "=")
    if not na(keyIdx)
        int startIdx = keyIdx + str.length(key + "=")
        bool isQuoted = str.substring(lineStr, startIdx, startIdx + 1) == '"'
        int finalStart = isQuoted ? startIdx + 1 : startIdx
        
        string remainingStr = str.substring(lineStr, finalStart)
        string searchDelim = isQuoted ? '"' : ";"
        int endIdxRelative = str.pos(remainingStr, searchDelim)
        
        if not na(endIdxRelative)
            result := str.substring(remainingStr, 0, endIdxRelative)
        else if not isQuoted
            result := remainingStr
    result

// Helper function to parse hex strings into colors
parseColor(string hexStr) =>
    color outColor = color.blue
    if str.length(hexStr) > 0
        string cleanHex = str.replace_all(hexStr, "#", "")
        if str.length(cleanHex) == 8
            cleanHex := str.substring(cleanHex, 2)
        
        if cleanHex == "FE0000" or cleanHex == "b20000" or cleanHex == "660000"
            outColor := color.red
        else if cleanHex == "FF9800" or cleanHex == "b36a00" or cleanHex == "663d00"
            outColor := color.orange
        else if cleanHex == "4CAF50" or cleanHex == "357a38" or cleanHex == "1e4620"
            outColor := color.green
        else if cleanHex == "2962FF" or cleanHex == "1d45b3" or cleanHex == "102766"
            outColor := color.blue
        else if cleanHex == "20BDBD" or cleanHex == "168484" or cleanHex == "0d4c4c"
            outColor := color.teal
    outColor

// Persistent arrays to hold graphics objects
var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()

// Trigger drawing updates only when the chart finishes processing or shifts
if barstate.islastconfirmedhistory or barstate.islast
    // Clear out old objects cleanly to refresh placement on the price scale
    if array.size(levelLines) > 0
        for i = 0 to array.size(levelLines) - 1
            line.delete(array.get(levelLines, i))
        array.clear(levelLines)
        
    if array.size(levelLabels) > 0
        for i = 0 to array.size(levelLabels) - 1
            label.delete(array.get(levelLabels, i))
        array.clear(levelLabels)

    // Parse the data lines
    array<string> lines = str.split(dataSrc, "\n")
    int lineCount = array.size(lines)
    
    if lineCount > 0
        for i = 0 to lineCount - 1
            string currentLine = array.get(lines, i)
            
            string rawLevel     = extractValue(currentLine, "Level")
            string levelName    = extractValue(currentLine, "Name")
            string colorHex     = extractValue(currentLine, "Color")
            string lineStyleStr = extractValue(currentLine, "Style")
            string rawWidth     = extractValue(currentLine, "LineWidth")
            
            if rawLevel != ""
                float priceLevel = str.tonumber(rawLevel)
                color plotColor  = parseColor(colorHex)
                int widthVal     = int(nz(str.tonumber(rawWidth), 2.0))
                
                string tvLineStyle = line.style_solid
                if lineStyleStr == "Dashed"
                    tvLineStyle := line.style_dashed
                else if lineStyleStr == "Dotted"
                    tvLineStyle := line.style_dotted
                
                // CRITICAL FIX: Explicitly lock coordinates to actual historical bar indexes 
                // and extend them to anchor into the true price grid.
                line ln = line.new(
                     x1=bar_index - lineLeftExtension, y1=priceLevel, 
                     x2=bar_index + offsetBars, y2=priceLevel, 
                     xloc=xloc.bar_index, 
                     extend=extend.none, 
                     color=plotColor, 
                     style=tvLineStyle, 
                     width=widthVal
                 )
                array.push(levelLines, ln)
                
                string alignStyle = (labelAlignInput == "Right" ? text.align_left : text.align_right)
                
                label lb = label.new(
                     x=bar_index + offsetBars, y=priceLevel, 
                     text=levelName + " (" + rawLevel + ")", 
                     xloc=xloc.bar_index, 
                     textcolor=plotColor, 
                     style=label.style_none, 
                     size=size.normal,
                     textalign=alignStyle
                 )
                array.push(levelLabels, lb)
````
