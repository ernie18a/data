# Volume Analysis TMF

- url: https://www.tradingview.com/script/6yQWIYAy-Volume-Analysis-TMF/
- type: indicator
- pine_id: PUB;3ae6da7426e9452483542edfda3ade85
- version: 2.0

## Description

What This Indicator Does
This professional-grade volume analysis indicator helps traders identify significant volume events and track subsequent price reactions. By analyzing volume patterns and—for Pro users—real footprint buy/sell data, it reveals where institutional interest is concentrated and when breakouts from these high-volume zones are likely to occur.

Core Purpose:
•	Detect abnormally high-volume candles that indicate institutional activity
•	Automatically draw boxes around these high-volume zones
•	Monitor when price breaks out of these zones (both early and mature breakouts)
•	Provide visual and alert-based signals for potential trading opportunities
•	Display real-time volume metrics in an easy-to-read table

Who This Is For :
•	Day traders looking for volume confirmation on breakouts
•	Swing traders identifying key support/resistance zones based on volume
•	Order flow traders (Pro users) analyzing buy/sell aggression
•	Traders wanting to understand when volume is truly "significant"

Advanced Original Unique Key Features
Dynamic Box Management :   Automatically draws boxes around high-volume candles and extends them forward in real-time . Unlike static lines, boxes track price action continuously and adapt to market movement

Sequential Streak Logic :  When multiple high-volume candles occur consecutively, only the highest volume candle gets a box . Prevents chart clutter while preserving the most significant volume event 

Two-Stage Breakout Detection : Separate signals for early breakouts (<10 bars) vs mature breakouts (≥10 bars) . Allows traders to distinguish between immediate momentum vs delayed confirmation

One-Time Signal Firing : Each box can trigger a breakout signal only once . Prevents repetitive alerts on the same zone, reducing noise

Footprint Integration :  For Pro users: displays real buy/sell volume percentages and cumulative delta. Reveals whether buying or selling pressure dominated the volume candle

10-Bar Historical Table : Shows last 10 bars of volume metrics in a color-coded table . Quick visual comparison of recent volume patterns at a glance

Conditional Coloring : Table cells change color based on volume anomalies (e.g., 2× previous sell volume) . Instant visual identification of unusual activity

Table Color Coding (Pro Mode):
•	Buy % Cell: Green if Buy > Sell × 1.5 or Buy > Previous Sell × 2
•	Sell % Cell: Red if Sell > Buy × 1.5 or Sell > Previous Buy × 2
•	Total Volume Cell: Blue if Volume > Avg × 1.5
•	Delta Cell: Green if positive, Red if negative
•	Cumulative Delta Cell: Green if positive, Dark Red if negative

📖 Step-by-Step Usage Guide
Recommended Default Settings:
├── Lookback Period: 200 (adjust down for faster response)
├── Volume Multiplier: 3.0 (lower = more signals, higher = only extreme volume)
├── Bull Box Color: #4caf4f1e (semi-transparent green)
├── Bear Box Color: #ff52521f (semi-transparent red)
├── Pro User Mode: ON if you have TradingView Pro
Step 2: Identify High-Volume Zones
•	Look for 🟡 yellow triangles below candles
•	Note the box drawn around that candle (extends forward in time)
•	The box represents the high-volume zone's price range
Step 3: Watch for Breakouts
•	Within 10 bars: Green/red triangles appear immediately
•	After 10 bars: Only alerts (no triangles) to avoid clutter
•	Breakout direction = potential trade direction
Step 5: Confirm with Table Data (Pro Users)
•	Check Buy/Sell percentages: Higher percentage indicates dominant side
•	Look for Delta > 0 (bullish) or < 0 (bearish)
•	Monitor Cumulative Delta trend

 Table Display Specifications : Last 10 candle data shows
The indicator creates a table at the bottom center of your chart showing:
Column	Data (Standard)	Data (Pro Mode)
1	Total Volume	Total Volume
2	(Hidden)	          Buy %
3	(Hidden)	          Sell %
4	(Hidden)	          Delta
5	(Hidden)	         Cumulative Delta

⚙️ Optimal Settings by Trading Style
Trading Style	   Lookback	Multiplier	    Pro Mode	      Best Timeframe
Scalping	           100 -200	   3	              Optional	         1-5 min
Day Trading	    200-300	   5	             Recommended	  15 min-1 hour
Swing Trading	    300-500	   5	             Optional	          4 hour-daily
Position Trading	    500-1000	   8	             Not needed	          daily

Disclaimer :
THIS INDICATOR IS PROVIDED FOR EDUCATIONAL AND INFORMATIONAL PURPOSES ONLY.

NOT FINANCIAL ADVICE Nothing in this indicator or its documentation constitutes financial advice, investment advice, trading advice, or any other type of professional advice. You should consult with qualified professionals before making any financial decisions.

NO PROFIT GUARANTEES
Past performance of this indicator does not guarantee future results.
Volume patterns that worked historically may not work in the future.
Market conditions change, and no indicator is 100% accurate.

TRADING RISKS
Trading financial markets involves substantial risk of loss.
You can lose all of your invested capital.
Never trade with money you cannot afford to lose.
Consider using stop-losses and proper position sizing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@description Professional volume analysis with footprint data integration, high-volume zone tracking, and precise dual-phase breakout signals.
// ╔═══════════════════════════════════════════════════════════════════════╗
// ║                    VOLUME ANALYSIS PRO - TMF                          ║
// ║              Footprint + Order Flow + Breakout Detector               ║
// ╠═══════════════════════════════════════════════════════════════════════╣
// ║  Author:  Trend_MyFrend                                               ║
// ║  Version: 1.0                                                         ║
// ║  Date:    2026-01-22                                                  ║
// ║  Category: Volume / Order Flow                                        ║
// ║                                                                       ║
// ║  DESCRIPTION:                                                         ║
// ║  This indicator identifies significant volume candles and tracks      ║
// ║  subsequent breakout behavior. For Pro users, it integrates real      ║
// ║  footprint buy/sell volume data showing exact market aggression.      ║
// ║                                                                       ║
// ║  KEY FEATURES:                                                        ║
// ║  • Volume Multiplier System (customizable threshold)                  ║
// ║  • Dynamic Box Drawing on high-volume zones                           ║
// ║  • Early Breakout Detection (< 10 bars)                               ║
// ║  • Mature Breakout Signals (≥ 10 bars)                                ║
// ║  • Real-time Table showing last 10 bars of volume data                ║
// ║  • Buy/Sell Volume Percentages (Pro users)                            ║
// ║  • Cumulative Delta tracking                                          ║
// ║                                                                       ║
// ║  HOW TO USE:                                                          ║
// ║  1. Add indicator to chart                                            ║
// ║  2. Adjust Lookback Period (default 200)                              ║
// ║  3. Set Volume Multiplier (lower = more signals)                      ║
// ║  4. Enable Pro User mode if you have TradingView Pro                  ║
// ║  5. Look for yellow triangles (high volume) followed by boxes         ║
// ║  6. Green/red triangles indicate early breakout signals               ║
// ║                                                                       ║
// ║  SIGNAL INTERPRETATION:                                               ║
// ║  • 🟡 Yellow triangle below bar = High volume detected               ║
// ║  • 🟢 Green triangle below bar = Early upside breakout (<10 bars)    ║
// ║  • 🔴 Red triangle above bar = Early downside breakout (<10 bars)    ║
// ║  • Colored boxes = Active high-volume zones being monitored           ║
// ║                                                                       ║
// ║  LIMITATIONS:                                                         ║
// ║  • Footprint data requires TradingView Pro subscription               ║
// ║  • Maximum 500 boxes and labels (configurable)                        ║
// ║  • Best results on liquid markets with good volume data               ║
// ║                                                                       ║
// ║  DISCLAIMER:                                                          ║
// ║  This indicator is for educational purposes only. Past performance    ║
// ║  does not guarantee future results. Always conduct your own analysis  ║
// ║  and risk management before trading.                                  ║
// ║                                                                       ║
// ╚═══════════════════════════════════════════════════════════════════════╝
//@version=6
// © Trend_MyFrend
indicator('Volume Analysis', 'VA_TMF', overlay = true, max_boxes_count = 500, max_labels_count = 500)

// --- Input Controls ---
lookback_period = input.int(200, title="Lookback Period")
multiplyer      = input.float(3, title="Volume Multiplier")
bullColor       = input.color(#4caf4f1e, "Bull Box Color",inline = 'color')
bearColor       = input.color(#ff52521f, "Bear Box Color",inline = 'color')
proUser         = input.bool(false, "Buy Sell Volume TradingView Pro User only")

// --- Footprint Data Request ---
footprint reqFootprint    = na
float totalBuyVol  = na
float totalSellVol = na

if  proUser 
    reqFootprint    := request.footprint(100, 70)
    if not na(reqFootprint)
        totalBuyVol  := reqFootprint.buy_volume()
        totalSellVol := reqFootprint.sell_volume()

float footprintTotal = (nz(totalBuyVol) + nz(totalSellVol))
float tvolume        = footprintTotal > 0 ? footprintTotal : volume
float volAvrg        = ta.sma(volume, lookback_period)
float delta          = totalBuyVol - totalSellVol
float cumulativeDelta = nz(delta[1]) + delta

// Percentages as raw numbers (e.g., 55.5 for 55.5%)
float buyPercent  = tvolume > 0 ? (nz(totalBuyVol) * 100 / tvolume) : 0
float sellPercent = tvolume > 0 ? (nz(totalSellVol) * 100 / tvolume) : 0
float Voldif      = volAvrg > 0 ? (tvolume / volAvrg) : 0 

// --- High Volume Condition ---
bool isHighestVolume = tvolume > (volAvrg * multiplyer)

// --- Dynamic Sequence Handling Variables ---
var label currentLabel = na
var box currentBox     = na
var float highestVolInStreak = 0.0

if not isHighestVolume
    currentLabel := na
    currentBox   := na
    highestVolInStreak := 0.0

// Parallel tracking arrays to keep sync between geometric boxes and breakout histories
var box[] activeBoxes    = array.new_box()
var bool[] boxFiredEarly = array.new_bool() 

bool signalCrossOver  = false
bool signalCrossUnder = false
string msg = na 

if proUser
    msg := "Ticker : " + syminfo.ticker +
           "\nBuy Volume : " + str.tostring(buyPercent, "#.##") + "%" +
           "\nSell Volume : " + str.tostring(sellPercent, "#.##") + "%" +
           "\nAverage Vol : " + str.tostring(volAvrg, format.volume) +
           "\nCurrent Vol : " + str.tostring(tvolume, format.volume) +
           "\nVol Times : " + str.tostring(Voldif, "#.##") + "x"
else
    msg := "Ticker : " + syminfo.ticker +
           "\nAverage Vol : " + str.tostring(volAvrg, format.volume) +
           "\nCurrent Vol : " + str.tostring(tvolume, format.volume) +
           "\nVol Times : " + str.tostring(Voldif, "#.##") + "x"

// --- Label and Box Logic ---
if isHighestVolume
    if tvolume > highestVolInStreak
        if not na(currentLabel)
            label.delete(currentLabel)
        if not na(currentBox)
            if array.size(activeBoxes) > 0
                array.remove(activeBoxes, array.size(activeBoxes) - 1)
                array.remove(boxFiredEarly, array.size(boxFiredEarly) - 1)
            box.delete(currentBox)
            
        currentLabel := label.new(x=bar_index, y=high, text=msg, yloc=yloc.abovebar, 
                                 color=color.new(#2195f3, 50), textcolor=color.white, 
                                 style=label.style_label_lower_right, size=size.normal)
        currentBox := box.new(left=bar_index, top=high, right=bar_index, bottom=low, 
                             border_color=color.new(#2195f3, 60), border_width=1, 
                             bgcolor=bullColor)
        
        array.push(activeBoxes, currentBox)
        array.push(boxFiredEarly, false) // Initialize new tracking block as 'not fired'
        alert(msg, alert.freq_once_per_bar_close)
        highestVolInStreak := tvolume

// --- Breakout Trigger Outputs ---
bool earlyUpsideBreakout   = false
bool earlyDownsideBreakout = false

// --- Manage Active Boxes Real-Time & Evaluate Crosses ---
if array.size(activeBoxes) > 0
    // Loop backwards to safely mutate array indexes
    for i = array.size(activeBoxes) - 1 to 0
        box b       = array.get(activeBoxes, i)
        bool alreadyFired = array.get(boxFiredEarly, i)
        
        int boxLeft = box.get_left(b)
        float boxTop = box.get_top(b)
        float boxBtm = box.get_bottom(b)
        int boxAge  = bar_index - boxLeft
        
        // Base Condition: Keep extending it forward to the current bar
        box.set_right(b, bar_index)
        
        // EARLY BREAKOUT DETECTION (< 10 Bars) - EXACTLY ONE TIME ONLY
        if boxAge < 10 and not alreadyFired
            bool earlyTopCross = (close[1] <= boxTop and close > boxTop)
            bool earlyBtmCross = (close[1] >= boxBtm and close < boxBtm)
            
            if earlyTopCross
                earlyUpsideBreakout := true
                box.set_bgcolor(b, bullColor) 
                array.set(boxFiredEarly, i, true) // Lock it up so it never triggers again
            else if earlyBtmCross
                earlyDownsideBreakout := true
                box.set_bgcolor(b, bearColor) 
                array.set(boxFiredEarly, i, true) // Lock it up so it never triggers again
                
        // MATURE CROSS CONDITIONS (>= 10 Bars)
        if boxAge >= 10
            bool topCrossover   = (close[1] <= boxTop and close > boxTop)
            bool btmCrossunder  = (close[1] >= boxBtm and close < boxBtm)
            
            if topCrossover
                signalCrossUnder := true
                array.remove(activeBoxes, i)
                array.remove(boxFiredEarly, i) // Clean up memory state tracking
                continue 
            else if btmCrossunder
                signalCrossOver := true
                array.remove(activeBoxes, i)
                array.remove(boxFiredEarly, i) // Clean up memory state tracking
                continue 

// --- Visual Plots ---
plotshape(isHighestVolume, title='Max Vol Candle', style=shape.triangleup, location=location.belowbar, color=color.yellow, size=size.tiny)

// Clean One-Time Only Execution Shapes per block zone
plotshape(earlyUpsideBreakout, title='Early Upside Breakout', style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(earlyDownsideBreakout, title='Early Downside Breakout', style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// ============================================
// ARRAY MANAGEMENT (Last 10 footprint-verified bars)
// ============================================
var buyVolume   = array.new_float(0)
var sellVolume  = array.new_float(0)
var totalVolume = array.new_float(0)
var deltaArr    = array.new_float(0)
var countArr    = array.new_float(0)

if not na(reqFootprint)
    array.push(buyVolume, buyPercent)
    array.push(sellVolume, sellPercent)
    array.push(totalVolume, tvolume)
    array.push(deltaArr, delta)
    array.push(countArr, cumulativeDelta)

    if array.size(buyVolume) > 10
        array.shift(buyVolume)
        array.shift(sellVolume)
        array.shift(totalVolume)
        array.shift(deltaArr)
        array.shift(countArr)

// ============================================
// TABLE DISPLAY
// ============================================
var valumeTable = table.new(position.bottom_center, 11, 6, border_width = 1)
tex = size.small

if barstate.islast and array.size(buyVolume) > 0
    table.cell(valumeTable, 0, 0, "Volume", bgcolor = #dd68244d, text_color = #ffffff, text_size = tex)
    if proUser
        table.cell(valumeTable, 0, 1, "Buy Vol", bgcolor = #3059ee4d, text_color = #ffffff, text_size = tex)
        table.cell(valumeTable, 0, 2, "Sell Vol", bgcolor = #dd68244d, text_color = #ffffff, text_size = tex)
        table.cell(valumeTable, 0, 3, "Delta", bgcolor = #e6e31f94, text_color = #ffffff, text_size = tex)
        table.cell(valumeTable, 0, 4, "cumulativeDelta", bgcolor = #a9b6e993, text_color = #ffffff, text_size = tex)

    for i = 0 to array.size(buyVolume) - 1
        int colIdx = i + 1
        float tVol = array.get(totalVolume, i)
        float bVol = array.get(buyVolume, i)
        float sVol = array.get(sellVolume, i)
        float dVal = array.get(deltaArr, i)
        float cDVal = array.get(countArr, i)
        
        int prevIdx = math.max(0, i - 1)
        float prevSellVol = array.size(sellVolume) > prevIdx ? array.get(sellVolume, prevIdx) : sVol
        float prevBuyVol  = array.size(buyVolume) > prevIdx ? array.get(buyVolume, prevIdx) : bVol
        
        color buyBgColor   = bVol > (prevSellVol * 2) or bVol > sVol * 1.5 ? #49c506af : #7e9969
        color sellBgColor  = sVol > (prevBuyVol * 2) or sVol > bVol * 1.5 ? #ee0f0fcc : #e59999c9
        color totBgColor   = tVol > volAvrg * 1.5 ? #1328e2 : #d3d4db93
        color deltaBgColor = dVal > 0 ? #8cda8e98 : #eb2626a1
        color cumDeltaBgColor = cDVal > 0 ? #275a29 : #691a1a

        table.cell(valumeTable, colIdx, 0, str.tostring(tVol, format.volume), text_color = #ffffff, bgcolor = totBgColor, text_size = tex)
        if proUser
            table.cell(valumeTable, colIdx, 1, str.tostring(bVol, "#.##") + ' %', text_color = #ffffffbd, bgcolor = buyBgColor, text_size = tex)
            table.cell(valumeTable, colIdx, 2, str.tostring(sVol, "#.##") + ' %', text_color = #ffffffbd, bgcolor = sellBgColor, text_size = tex)
            table.cell(valumeTable, colIdx, 3, str.tostring(dVal, format.volume), text_color = color.white, bgcolor = deltaBgColor, text_size = tex)
            table.cell(valumeTable, colIdx, 4, str.tostring(cDVal, format.volume), text_color = #f7cbcb, bgcolor = cumDeltaBgColor, text_size = tex)
````
