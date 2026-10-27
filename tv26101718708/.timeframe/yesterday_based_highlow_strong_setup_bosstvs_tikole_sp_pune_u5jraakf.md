# Yesterday Based High/Low strong  setup bosstvs tikole s.p. pune 

- url: https://www.tradingview.com/script/u5jRaakF-Yesterday-Based-High-Low-strong-setup-bosstvs-tikole-s-p-pune/
- type: indicator
- pine_id: PUB;210c0055370d4a6bae495e74cc2d33d5
- version: 1.0

## Description

### **Indicator Overview**
This indicator is designed specifically for intraday traders (especially for the Indian/NSE market). It automatically plots Yesterday’s key levels and marks the High and Low of specific afternoon time ranges (2:25 to 2:35 PM) to help you find breakout or breakdown trades.



#### **1. Yesterday’s Key Levels (Yellow, Red, Blue Circles)**
These levels are calculated from the previous day's High, Low, and 50% midpoint. They act as major support and resistance for the current day.
*   **Yellow Line (Yesterday 50%):** This is the midpoint of yesterday's High and Low. It is a strong psychological level. If the price is above this line, the market sentiment is generally bullish; if below, it's bearish.
*   **Red Line (Yesterday High):** The highest point reached yesterday. If the price breaks above this line today, it signals a strong breakout.
*   **Blue Line (Yesterday Low):** The lowest point reached yesterday. If the price breaks below this line today, it signals a strong breakdown.

#### **2. Time-Based High/Low Markers (2:25 PM to 2:35 PM)**
The afternoon session (around 2:30 PM) often creates a strong momentum move or a range before the market closes. This indicator captures the exact High and Low of these specific time ranges.
*   **Orange Line (2:30 H):** This line represents the **Highest Price** between **14:25 and 14:30**. If the price breaks above this orange line after 2:30 PM, you can take a Buy (Long) trade.
*   **Red Line (2:35 H):** This line represents the **Highest Price** between **14:30 and 14:35**. Another breakout level for Buy trades.
*   **Green/Lime Line (2:35 L):** This line represents the **Lowest Price** between **14:30 and 14:35**. If the price breaks below this green line after 2:35 PM, you can take a Sell (Short) trade.

*Note: The price values (e.g., 44250.50) are displayed as labels on the left side of the lines so you know the exact level to watch.*

#### **3. "No History" Clean Chart Feature**
To keep your chart clean, the 2:30 and 2:35 lines are **only drawn for the current day**. When you scroll back to previous days, you will *not* see those old lines cluttering the chart. However, Yesterday's High, Low, and 50% lines will naturally remain visible in history.

---

### **How to Trade Using This Indicator (Example Strategy)**

1.  **Pre-Market / Morning:** Watch how the price reacts to the **Yellow (50%)** line. Use it as a trend filter.
2.  **Afternoon (2:25 PM - 2:35 PM):** Wait for the time ranges to finish. Do not trade during the 10 minutes while the lines are being formed.
3.  **The Breakout Trade:**
    *   After 2:35 PM, if the price crosses **above** the Orange (2:30 H) or Red (2:35 H) lines with a strong candle, **Buy**. Keep your Stop Loss slightly below the Green (2:35 L) line.
    *   After 2:35 PM, if the price crosses **below** the Green (2:35 L) line with a strong candle, **Sell**. Keep your Stop Loss slightly above the Red (2:35 H) line.
4.  **Confluence:** The best trades happen when the 2:30/2:35 breakout lines align with Yesterday's High or Low (Red/Blue circles).

---

### **Important Note on Timeframes**
This indicator is coded to work accurately on **1-minute, 3-minute, and 5-minute** charts. It automatically adjusts its internal calculation based on which of these three timeframes you are currently viewing. For best results, use a 3-minute or 5-minute chart.

## Source Code

````pine
//@version=6
indicator("Yesterday 50% + Time Based High/Low Marker", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== 1. YESTERDAY HIGH, LOW & 50% LINE =====
prevHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
prevLow  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
yesterday50 = (prevHigh + prevLow) / 2.0

// Lines draw karna
plot(yesterday50, title="Yesterday 50%", color=color.new(color.yellow, 0), linewidth=2, style=plot.style_circles)
plot(prevHigh, title="Yesterday High", color=color.new(color.red, 0), linewidth=2, style=plot.style_circles)
plot(prevLow, title="Yesterday Low", color=color.new(color.blue, 0), linewidth=2, style=plot.style_circles)

// Dynamic Labels for Yesterday Levels (Right side mein price dikhane ke liye)
var label lblYHigh = na
var label lblYLow  = na
var label lblY50   = na

if barstate.islast
    // Puraana label delete karna (taaki duplicate na bane)
    if not na(lblYHigh)
        label.delete(lblYHigh)
    if not na(lblYLow)
        label.delete(lblYLow)
    if not na(lblY50)
        label.delete(lblY50)
        
    // Naya label current candle par banana
    lblYHigh := label.new(x=bar_index, y=prevHigh, text="Y High : " + str.tostring(prevHigh, format.mintick), style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
    lblYLow  := label.new(x=bar_index, y=prevLow, text="Y Low : " + str.tostring(prevLow, format.mintick), style=label.style_label_left, color=color.new(color.blue, 0), textcolor=color.white, size=size.small)
    lblY50   := label.new(x=bar_index, y=yesterday50, text="Y 50% : " + str.tostring(yesterday50, format.mintick), style=label.style_label_left, color=color.new(color.yellow, 0), textcolor=color.white, size=size.small)


// ===== CHECK FOR CURRENT DAY =====
currentDayStart = request.security(syminfo.tickerid, "D", time, lookahead=barmerge.lookahead_on)
isToday = (time >= currentDayStart)

// ===== TIME VARIABLES =====
timeStr = str.tostring(hour, "00") + ":" + str.tostring(minute, "00")
tfSec = timeframe.in_seconds()

// ===== 2. LOGIC FOR 14:25 TO 14:30 CANDLE =====
var float range1High = na
var float range1Low  = na

bool is230Range = false
if tfSec == 300
    is230Range := (timeStr == "14:25")
else if tfSec == 180
    is230Range := (timeStr == "14:25" or timeStr == "14:28")
else if tfSec == 60
    is230Range := (hour == 14 and minute >= 25 and minute <= 29)

if is230Range and isToday
    range1High := nz(range1High, high) > high ? nz(range1High, high) : high
    range1Low  := nz(range1Low, low) < low ? nz(range1Low, low) : low

// ===== 3. LOGIC FOR 14:30 TO 14:35 CANDLE =====
var float range2High = na
var float range2Low  = na

bool is235Range = false
if tfSec == 300
    is235Range := (timeStr == "14:30")
else if tfSec == 180
    is235Range := (timeStr == "14:30" or timeStr == "14:33")
else if tfSec == 60
    is235Range := (hour == 14 and minute >= 30 and minute <= 34)

if is235Range and isToday
    range2High := nz(range2High, high) > high ? nz(range2High, high) : high
    range2Low  := nz(range2Low, low) < low ? nz(range2Low, low) : low

// ===== 4. DRAWING LINES ONLY FOR TODAY =====
var array<line> linesToday = array.new<line>()
var array<label> labelsToday = array.new<label>()

// Naya din start hone par purane din ki lines aur labels delete karna
var bool isDayChanged = false
if isToday
    if not isDayChanged
        isDayChanged := true
        
        if array.size(linesToday) > 0
            for i = 0 to array.size(linesToday) - 1
                line.delete(array.get(linesToday, i))
        array.clear(linesToday)
        
        if array.size(labelsToday) > 0
            for i = 0 to array.size(labelsToday) - 1
                label.delete(array.get(labelsToday, i))
        array.clear(labelsToday)

// Lines sirf tab banengi jab time 14:35 ho aur aaj ke din ki candle ho
if timeStr == "14:35" and isToday
    // --- Draw 2:25-2:30 Range (Only High) ---
    if not na(range1High)
        l1 = line.new(x1=bar_index - 1, y1=range1High, x2=bar_index + 200, y2=range1High, color=color.new(color.orange, 0), width=2, style=line.style_solid)
        lb1 = label.new(x=bar_index + 2, y=range1High, text=str.tostring(range1High, format.mintick), style=label.style_label_left, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
        array.push(linesToday, l1)
        array.push(labelsToday, lb1)
        
    // --- Draw 2:30-2:35 Range (High & Low) ---
    if not na(range2High)
        l2 = line.new(x1=bar_index - 1, y1=range2High, x2=bar_index + 200, y2=range2High, color=color.new(color.red, 0), width=2, style=line.style_solid)
        lb2 = label.new(x=bar_index + 2, y=range2High, text=str.tostring(range2High, format.mintick), style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
        array.push(linesToday, l2)
        array.push(labelsToday, lb2)
        
        l3 = line.new(x1=bar_index - 1, y1=range2Low, x2=bar_index + 200, y2=range2Low, color=color.new(color.lime, 0), width=2, style=line.style_solid)
        lb3 = label.new(x=bar_index + 2, y=range2Low, text=str.tostring(range2Low, format.mintick), style=label.style_label_left, color=color.new(color.lime, 0), textcolor=color.black, size=size.small)
        array.push(linesToday, l3)
        array.push(labelsToday, lb3)

    // Reset both ranges for the next day
    range1High := na
    range1Low  := na
    range2High := na
    range2Low  := na
````
