# Custom Percentage Levels

- url: https://www.tradingview.com/script/bLCaSs9J-Custom-Percentage-Levels/
- type: indicator
- pine_id: PUB;cfb052d11a8146558a0f71e9d6f9f43b
- version: 2.0

## Description

Custom Percentage Levels
Based  on secret entry values

## Source Code

````pine
//@version=6
indicator('Custom Percentage Levels with Labels', overlay = true)

// ==========================================
// USER INPUTS
// ==========================================
C = input.float(title = 'Base Price (C Value)', defval = 100.0)

// Dropdown for you to choose Left or Center text alignment
alignInput = input.string('Left', title = 'Text Alignment', options = ['Left', 'Center', 'Right'])

// Convert the input string into Pine Script's built-in text alignment variables
var string txtAlign = text.align_left
if alignInput == 'Center'
    txtAlign := text.align_center
    txtAlign
else if alignInput == 'Right'
    txtAlign := text.align_right
    txtAlign


// ==========================================
// PLOT LINES
// ==========================================
// Plot the main C value line
plot(C, title = 'Base C', color = color.white, linewidth = 2)

// 10 Lines ABOVE C Value
plot(C * 1.005, title = 'Above +0.5%', color = color.green)
plot(C * 1.010, title = 'Above +1.0%', color = color.green)
plot(C * 1.015, title = 'Above +1.5%', color = color.green)
plot(C * 1.020, title = 'Above +2.0%', color = color.green)
plot(C * 1.025, title = 'Above +2.5%', color = color.green)
plot(C * 1.030, title = 'Above +3.0%', color = color.green)
plot(C * 1.035, title = 'Above +3.5%', color = color.green)
plot(C * 1.040, title = 'Above +4.0%', color = color.green)
plot(C * 1.045, title = 'Above +4.5%', color = color.green)
plot(C * 1.050, title = 'Above +5.0%', color = color.green)

// 10 Lines BELOW C Value
plot(C * 0.995, title = 'Below -0.5%', color = color.red)
plot(C * 0.990, title = 'Below -1.0%', color = color.red)
plot(C * 0.985, title = 'Below -1.5%', color = color.red)
plot(C * 0.980, title = 'Below -2.0%', color = color.red)
plot(C * 0.975, title = 'Below -2.5%', color = color.red)
plot(C * 0.970, title = 'Below -3.0%', color = color.red)
plot(C * 0.965, title = 'Below -3.5%', color = color.red)
plot(C * 0.960, title = 'Below -4.0%', color = color.red)
plot(C * 0.955, title = 'Below -4.5%', color = color.red)
plot(C * 0.950, title = 'Below -5.0%', color = color.red)


// ==========================================
// DRAW TEXT LABELS (Only on the last bar)
// ==========================================
if barstate.islast
    // Offset the text by a few bars into the future so it doesn't overlap the current candle
    labelX = bar_index + 3

    // Draw Base Line Label
    label.new(x = labelX, y = C, text = 'Base C', color = color.new(color.white, 100), textcolor = color.white, style = label.style_none, textalign = txtAlign)

    // Use a loop to efficiently draw all 20 percentage labels
    for i = 1 to 10 by 1
        pct = i * 0.5

        // Calculate and draw ABOVE labels (+0.5% to +5.0%)
        valAbove = C * (1 + pct / 100)
        txtAbove = '+' + str.tostring(pct) + '%'
        label.new(x = labelX, y = valAbove, text = txtAbove, color = color.new(color.white, 100), textcolor = color.green, style = label.style_none, textalign = txtAlign)

        // Calculate and draw BELOW labels (-0.5% to -5.0%)
        valBelow = C * (1 - pct / 100)
        txtBelow = '-' + str.tostring(pct) + '%'
        label.new(x = labelX, y = valBelow, text = txtBelow, color = color.new(color.white, 100), textcolor = color.red, style = label.style_none, textalign = txtAlign)
````
