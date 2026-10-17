# Narrow Range Contraction (NRC) Box

- url: https://www.tradingview.com/script/zbRPwTiz-Narrow-Range-Contraction-NRC-Box/
- type: indicator
- pine_id: PUB;0768d7cf1ac1456eb4a023609c9b96d5
- version: 3.0

## Description

🎯 Overview
The Narrow Range Contraction (NRC) Box Breakout Indicator automatically identifies high-probability consolidation patterns followed by explosive breakouts. This indicator detects mother bars (low volatility candles) followed by a sequence of inside bars (lower volatility), creating a compression box that often precedes significant price movements.

🔍 How It Works
Step 1: Mother Bar Detection
•	Identifies a "mother bar" (candle with range > ATR × multiplier)
•	Requires the mother bar to be significantly larger than previous candles
•	Typical detection: Range > ATR(14) × 1.2 AND Range > Previous Range × 1.5

Step 2: Inside Bar Confirmation
•	After mother bar detection, monitors subsequent candles
•	Each bar must trade entirely within mother bar's high/low range
•	Configurable minimum inside bars required (default: 4)

Step 3: Box Construction
•	When minimum inside bars achieved, draws a consolidation box
•	Box top = Highest high during the inside bar sequence
•	Box bottom = Lowest low during the inside bar sequence
•	Visual representation of the compressed trading range

Step 4: Breakout Detection
•	Monitors price action relative to the box
•	Bullish breakout: Close above box top
•	Bearish breakdown: Close below box bottom
•	Visual color change and alerts on breakout

📊 Key Features
✅ Automatic Pattern Recognition - No manual drawing required
✅ Dynamic Box Sizing - Adapts to volatility expansion/contraction
✅ Multi-Timeframe Compatible - Works on any chart timeframe
✅ Visual Breakout Confirmation - Box color changes on breakout
✅ Extendable Lines - Project support/resistance levels forward
✅ Customizable Labels - Optional breakout labels
✅ Alert System - Real-time notifications for breakouts
✅ Historical Tracking - Stores up to 500 boxes

⚙️ Input Parameters
Parameter	                   Default	                        Description
ATR Multiplier   :-	      1.2	Sensitivity of mother bar detection (lower = more signals)
Required Inside  Bars:-	4	Minimum inside bars before drawing box (NR4, NR7, etc.)
Show Lines :-	             True	Display extension lines from box boundaries
Extend in Candles  :-	    150	How many candles to extend projection lines
Show Labels  :-	             True	Display breakout direction labels
Box Color  :-	 Blue (80% t)	Fill color of consolidation boxes
Top Line Color  :-	Light Red (50%t)	Extended resistance line color
Bottom Line Color  :-	Light Green (50%t)	Extended support line color
🚀 Usage Instructions
Basic Setup:
1.	Add indicator to your chart
2.	Keep default settings for most markets
3.	Wait for colored boxes to appear
4.	Watch for breakout alerts
Optimization Tips:
For Day Trading (1-15 min charts):
•	Set Required Inside Bars: 3-5
•	ATR Multiplier: 1.2-1.5
•	Expect more frequent signals
For Swing Trading (1-4 hour charts):
•	Set Required Inside Bars: 5-7
•	ATR Multiplier: 1.2-1.5
•	Higher quality signals, less frequent
For Position Trading (Daily/Weekly):
•	Set Required Inside Bars: 5-10
•	ATR Multiplier: 1.5-2.0
•	Major trend signals only
Trading Strategies:
Bullish Setup:
1.	Box appears (consolidation)
2.	Wait for close above top line
3.	Entry on breakout candle close
4.	Stop loss at box bottom
5.	Target: Box height projected upward
Bearish Setup:
1.	Box appears (consolidation)
2.	Wait for close below bottom line
3.	Entry on breakdown candle close
4.	Stop loss at box top
5.	Target: Box height projected downward

📈 Signal Quality Filters
The indicator includes built-in quality filters:
•	Mother bar must exceed ATR threshold
•	Inside bars confirmed sequentially
•	Breakout requires closing price confirmation
🎨 Visual Guide
•	Blue Box → Active consolidation (no breakout yet)
•	Green-tinted Box → Bullish breakout occurred
•	Red-tinted Box → Bearish breakdown occurred
•	Dotted Lines → Projected support/resistance levels
•	Labels → Directional breakout alerts on chart
⚠️ Important Notes
⚠️ Not a standalone trading system - Use with other confirmation tools
⚠️ False breakouts possible - Consider volume or momentum filters
⚠️ Works best in trending markets - Avoid sideways choppy conditions
⚠️ Backtest before live use - Performance varies by market and timeframe
🔔 Alert Conditions

Two alert conditions available:
1.	NRC Bullish Breakout - Price closes above box top
2.	NRC Bearish Breakout - Price closes below box bottom
Recommended Alert Actions:
•	Connect to webhook for automated trading
•	Send to mobile for manual execution
•	Log to CSV for performance tracking

📊 Market Applications
✅ Stocks - Excellent for earnings consolidation patterns
✅ Forex - Works well with range-bound pairs before news
✅ Crypto - Effective for volatility compression patterns
✅ Futures - Good for pre-market range identification
🆚 Comparison with Built-in Tools
Feature	This Indicator	TradingView Default
Auto-box drawing	✅ Yes	❌ Manual only
Inside bar counting	✅ Automatic	❌ Manual
Breakout alerts	       ✅ Yes	 ❌ No
Historical tracking	✅ 500 boxes	❌ Limited
Volatility adjustment	✅ ATR-based	❌ Static

🔧 Technical Requirements
•	TradingView Version: v6
•	Max Boxes: 500
•	Max Labels: 500
•	Max Lines: 500
•	Processing: Optimized for real-time
📝 Version History
v1.0 (Current)
•	Initial release
•	Mother bar detection with ATR multiplier
•	Inside bar confirmation system
•	Visual box drawing with break detection
•	Alert conditions for both directions
•	Customizable colors and extensions
📧 Support
For questions or feature requests:
•	Contact via TradingView private message
•	Check script comments for modification notes
•	Open-source for educational purposes
_______________________________________
Preview Message for TradingView:
text
🎯 NRC Box Breakout - Auto-Detect High Probability Breakouts

Never miss a volatility contraction breakout again! This indicator automatically identifies mother bars followed by inside bars, draws consolidation boxes, and alerts you on breakouts.

✅ 100% Automatic pattern detection
✅ Real-time breakout alerts (Bullish/Bearish)
✅ Customizable sensitivity (ATR-based)
✅ Visual box tracking with color changes
✅ Extension lines for projected levels

Perfect for day traders and swing traders looking for systematic breakout entries.

Based on Toby Crabel's Narrow Range concepts. Works on all timeframes and markets.

Try it now! 🚀

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trend_MyFrend
//@version=6
indicator('Narrow Range Box',"NRC_TMF" ,overlay = true,max_boxes_count = 500,max_labels_count = 500,max_lines_count = 500)

// --- Inputs ---
multiplier = input.float(1.2, 'ATR Multiplier')
minRangeBars = input.int(5, 'Required Inside Bars')
overlapsshow = input.bool(false,"Overlap Signal Show") // User input for toggle
showLines = input.bool(true, 'Show Lines', inline = "Line")
lineextend = input.int(100, "Extend in Candles", active = showLines, inline = "Line")
showLabels = input.bool(true, 'Show Labels')
boxColor = input.color(#2196f333, 'Un Break Color', inline = "col")
lineColor = input.color(#9ca0a3, 'Un Break Border Color', inline = "col")
lineTopColor = input.color(#f07d7d6e, 'Top Line Color', inline = "col")
lineBottomColor = input.color(#67f09b4b, ' Bottom Line Color', inline = "col")

// --- Detection Logic ---
rangePrev = high[1] - low[1]
rangeCurr = high - low
rangeNextToPrev = high[2] - low[2]
atrVal = ta.atr(14)

isMotherDetected = rangePrev > atrVal * multiplier and rangePrev > rangeNextToPrev * 1.5 and rangePrev > rangeCurr * 1.2
isMotherSimple = high[1] - low[1] > ta.atr(14) * multiplier and high[1] - low[1] > (high[2] - low[2]) * 1.5
finalMother = isMotherDetected or isMotherSimple

// --- State Variables ---
var float pendingHigh = na
var float pendingLow = na
var int pendingIdx = na
var int insideCount = 0
var bool motherActive = false

// New variables for overlap tracking
var float lastBoxTop = na
var float lastBoxBottom = na

// --- Storage ---
var boxStorage = array.new_box()
var highLineStorage = array.new_line()
var lowLineStorage = array.new_line()
var labelStorage = array.new_label()
var activeStatus = array.new_bool()

// --- Logic ---
if finalMother and not motherActive
    pendingHigh := high[1]
    pendingLow := low[1]
    pendingIdx := bar_index[1]
    insideCount := 0
    motherActive := true

if motherActive and not na(pendingHigh)
    isInside = open <= pendingHigh and open >= pendingLow and close <= pendingHigh and close >= pendingLow
    if isInside
        insideCount := insideCount + 1
    else 
        motherActive := false
        pendingHigh := na
        pendingLow := na
        insideCount := 0

    if insideCount >= minRangeBars and motherActive
        currentHigh = math.max(pendingHigh, high[1],high[2],high[3])
        currentLow = math.min(pendingLow, low[1], low[2], low[3])
        
        // --- Overlap Check using overlapsshow input ---
        bool overlaps = not overlapsshow and not na(lastBoxTop) and (currentLow < lastBoxTop and currentHigh > lastBoxBottom)
        
        if not overlaps 
            box newBox = box.new(left = pendingIdx, top = currentHigh, right = bar_index, bottom = currentLow, border_color = lineColor, bgcolor = boxColor, border_width = 2)
            array.push(boxStorage, newBox)
            array.push(activeStatus, true)
            
            // Update trackers
            lastBoxTop := currentHigh
            lastBoxBottom := currentLow

            if showLines 
                array.push(highLineStorage, line.new(pendingIdx, currentHigh, bar_index + lineextend, currentHigh, color = lineTopColor, width = 2, style = line.style_dotted))
                array.push(lowLineStorage, line.new(pendingIdx, currentLow, bar_index + lineextend, currentLow, color = lineBottomColor, width = 2, style = line.style_dotted))

        motherActive := false

// --- Breakout Detection & "Publishing" ---
bool alertUp = false
bool alertDown = false

if array.size(boxStorage) > 0
    for i = 0 to array.size(boxStorage) - 1 by 1
        if array.get(activeStatus, i)
            currentBox = array.get(boxStorage, i)
            top = box.get_top(currentBox)
            bottom = box.get_bottom(currentBox)
            box.set_right(currentBox, bar_index)
 
            if close > top
                alertUp := true
                array.set(activeStatus, i, false)
            else if close < bottom
                alertDown := true
                box.set_border_color(currentBox, color = #af4c4c3d)
                array.set(activeStatus, i, false)
            
            if alertUp or alertDown
                box.set_border_color(currentBox, alertUp ? #4caf4f3f : #ff52521f)
                box.set_bgcolor(currentBox, alertUp ? #4caf4f23 : #ff52521f)
                if showLabels
                    label.new(bar_index, alertUp ? bottom : top, text = alertUp ? "Bullish " : "Bearish ", color = alertUp ? color.green : color.red, textcolor = color.white, style = alertUp ? label.style_label_up : label.style_label_down)

// --- Alerts ---
alertcondition(alertUp, title="NRC Bullish Breakout", message="NR Box Breakout UP on {{ticker}} at {{close}}")
alertcondition(alertDown, title="NRC Bearish Breakout", message="NR Box Breakdown DOWN on {{ticker}} at {{close}}")
````
