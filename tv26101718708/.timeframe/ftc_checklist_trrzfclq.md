# FTC Checklist

- url: https://www.tradingview.com/script/TrRzfClQ-FTC-Checklist/
- type: indicator
- pine_id: PUB;3a7603caccf742c3895efbd6efcf596b
- version: 1.0

## Description

The ACE Trader Method Indicator was built to simplify market structure and help traders execute with confidence instead of confusion.

This tool automatically highlights key market concepts used inside the ACE Trader Method, allowing traders to spend less time overanalyzing charts and more time focusing on execution.

Features include:
• Break of Structure (BOS) Detection
• Change of Character (CHOCH) Identification
• Session & Killzone Visualization
• Clean Market Structure Mapping
• High-Probability Trading Frameworks
• Beginner-Friendly Chart Clarity
• Lightweight & Easy-to-Use Layout

This indicator is designed for traders who want:

Cleaner charts
Faster analysis
More confidence in directional bias
Better execution during active market sessions

The goal of this tool is not to replace skill, but to enhance decision-making and help traders stay aligned with high-probability market structure.

Built for the ACE Trader community. Continuously improving through live trader feedback and real market testing.

## Source Code

````pine
//@version=6
indicator("ForTheCultureFX Clean Structure Tool", overlay=true, max_boxes_count=50, max_lines_count=50)

// =====================================================
// COLORS (BRAND CONTROL)
// =====================================================

blue = color.rgb(0, 120, 255)
white = color.white
green = color.rgb(0, 200, 0)
yellow = color.rgb(255, 215, 0)
darkBlue = color.rgb(0, 70, 160)
lightBlue = color.rgb(135, 206, 250)

// =====================================================
// 4H BIAS (2 WEEK RANGE)
// =====================================================

twoWeekHigh = request.security(syminfo.tickerid, "240", ta.highest(high, 84))
twoWeekLow  = request.security(syminfo.tickerid, "240", ta.lowest(low, 84))
mid = (twoWeekHigh + twoWeekLow) / 2

htfClose = request.security(syminfo.tickerid, "240", close)

htfBias = htfClose > mid ? "BULLISH" : "BEARISH"

// =====================================================
// 15M STRUCTURE
// =====================================================

m15High = request.security(syminfo.tickerid, "15", ta.highest(high, 20))
m15Low  = request.security(syminfo.tickerid, "15", ta.lowest(low, 20))
m15Mid  = (m15High + m15Low) / 2

m15Close = request.security(syminfo.tickerid, "15", close)

m15Wave = m15Close > m15Mid ? "BULLISH" : "BEARISH"
m15Context = m15Wave == htfBias ? "CONTINUATION" : "CORRECTION"

// =====================================================
// 15M KEY LEVEL LINES
// =====================================================

var line m15HighLine = na
var line m15LowLine = na

line.delete(m15HighLine)
line.delete(m15LowLine)

m15HighLine := line.new(bar_index - 50, m15High, bar_index + 50, m15High, color=darkBlue, width=2)
m15LowLine  := line.new(bar_index - 50, m15Low,  bar_index + 50, m15Low,  color=darkBlue, width=2)

// =====================================================
// 5M KEY ZONE
// =====================================================

fiveHigh = request.security(syminfo.tickerid, "5", ta.highest(high, 20))
fiveLow  = request.security(syminfo.tickerid, "5", ta.lowest(low, 20))

var box zoneBox = na

box.delete(zoneBox)

zoneBox := box.new(
    left=bar_index - 20,
    right=bar_index + 20,
    top=fiveHigh,
    bottom=fiveLow,
    bgcolor=color.new(lightBlue, 85),
    border_color=lightBlue
)

// =====================================================
// BREAK LOGIC EXPLANATION (NEW ADDITION)
// =====================================================

breakState =
     close > m15High ? "CONTINUATION ↑ (Break High)" :
     close < m15Low  ? "MARKET SHIFT ↓ (Break Low)" :
     "INSIDE RANGE"

// =====================================================
// DASHBOARD
// =====================================================

var table dash = table.new(position.top_right, 2, 6)

// 4H
table.cell(dash, 0, 0, "4H BIAS")
table.cell(dash, 1, 0, htfBias,
     text_color = htfBias == "BULLISH" ? blue : white)

// 15M WAVE
table.cell(dash, 0, 1, "15M WAVE")
table.cell(dash, 1, 1, m15Wave,
     text_color = m15Wave == "BULLISH" ? blue : white)

// CONTEXT
table.cell(dash, 0, 2, "15M CONTEXT")
table.cell(dash, 1, 2, m15Context,
     text_color = m15Context == "CONTINUATION" ? green : yellow)

// 15M KEY HIGH (PRICE)
table.cell(dash, 0, 3, "15M HIGH")
table.cell(dash, 1, 3, str.tostring(m15High))

// 15M KEY LOW (PRICE)
table.cell(dash, 0, 4, "15M LOW")
table.cell(dash, 1, 4, str.tostring(m15Low))

// BREAK EXPLANATION
table.cell(dash, 0, 5, "STRUCTURE")
table.cell(dash, 1, 5, breakState,
     text_color = breakState == "CONTINUATION ↑ (Break High)" ? green :
                  breakState == "MARKET SHIFT ↓ (Break Low)" ? yellow : white)
````
