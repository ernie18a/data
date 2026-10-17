# The Little Bank Levels (250s)

- url: https://www.tradingview.com/script/k3oYCGB5-The-Little-Bank-Levels-250s/
- type: indicator
- pine_id: PUB;d3079e78084e437686dcc12eef6a39b8
- version: 1.0

## Description

Key Bank Levels where the market really moves. This indicator helps eliminate the manual adding of these major levels and leaves it simple and sleek.

## Source Code

````pine
// @version=5
indicator("Indices Bank Levels (250s)", overlay=true, max_lines_count=500)

// --- Inputs ---
int increment = input.int(250, "Level Increment", minval=10)
color line_color = input.color(color.new(color.gray, 50), "Line Color")
string line_style_input = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"])

// Style Logic
line_style = line_style_input == "Solid" ? line.style_solid : 
             line_style_input == "Dashed" ? line.style_dashed : 
             line.style_dotted

// Arrays to handle drawing
var line[] level_lines = array.new_line()
var label[] level_labels = array.new_label()

if barstate.islast
    // Clear old drawings to keep chart clean
    if array.size(level_lines) > 0
        for i = 0 to array.size(level_lines) - 1
            line.delete(array.get(level_lines, i))
            label.delete(array.get(level_labels, i))
        array.clear(level_lines)
        array.clear(level_labels)

    // Calculate how many lines to show (covers roughly 2000 points above/below)
    float lookback_range = increment * 8
    float top = close + lookback_range
    float bottom = close - lookback_range
    
    // This is the "Snap" logic: Finds the nearest 250 below the current bottom
    float start_level = math.floor(bottom / increment) * increment
    
    // Draw the lines
    for i = 0 to 20 
        float level = start_level + (i * increment)
        
        // Only draw if the level is within our visible range
        if level <= top + increment
            ln = line.new(
                 x1=bar_index - 200, y1=level, 
                 x2=bar_index, y2=level, 
                 extend=extend.both, 
                 color=line_color, 
                 style=line_style, 
                 width=1
                 )
            array.push(level_lines, ln)
            
            lb = label.new(
                 bar_index + 2, level, 
                 text=str.tostring(level, "#"), 
                 style=label.style_none, 
                 textcolor=line_color, 
                 textalign=text.align_left
                 )
            array.push(level_labels, lb)
````
