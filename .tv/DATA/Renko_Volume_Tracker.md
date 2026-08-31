<!-- tradingview-pine-id: PUB;18cc211094b44e45aac0180528ba0914 -->
<!-- tradingviewscripts-format: 1 -->
# Renko Volume Tracker

Source: https://www.tradingview.com/script/qOsPq5SH-Renko-Volume-Tracker/

## Description

Introduction
The Renko Volume Tracker is an overlay indicator designed to bridge the gap between time-based volume and price-action-based movement. While standard volume indicators analyze activity within fixed time intervals (like a 5-minute or 1-hour candle), this script dynamically groups time-based candles into "chunks" dictated by the formation of Renko bricks. By doing so, it highlights the exact time-based candle that experienced the highest volume during a specific, measurable price movement.

This indicator is designed to be applied to a standard candlestick chart while it calculates Renko price action in the background.

How It Works
Renko charts eliminate the element of time, focusing purely on price movement. A new Renko brick is only formed when the price moves by a predefined amount.

Background Renko Calculation: The script uses TradingView's ticker.renko function to track Renko brick formations in the background. Users can choose between an ATR-based box size or a Traditional fixed box size.

Volume Chunking: The script introduces a "Chunk Window" defined by 'N' number of Renko bricks (default is 3). It monitors the underlying time-based candles as these N bricks are being formed.

Pinpointing Volume Nodes: As the candles print, the script tracks the volume of each one. Once the defined number of Renko bricks (the chunk) is completed, the script drops a permanent circular label on the exact candlestick that had the highest volume within that period.

Visual Output

Teal Circles: Plotted at the low of the high-volume candle during a Renko uptrend.

Purple Circles: Plotted at the high of the high-volume candle during a Renko downtrend.

Tooltips: Hovering over any circular label will display the exact volume traded during that specific candlestick.

How to Use This Indicator
This tool is highly effective for identifying significant volume nodes and potential institutional footprints within price trends:

Dynamic Support & Resistance: The high-volume candles identified by the indicator often act as strong support and resistance levels. A high-volume candle during an uptrend (teal circle) represents a heavy area of buying interest; subsequent pullbacks to this price level may offer bounce opportunities.

Trend Exhaustion: If a high-volume node appears at the extreme top of an extended move, it may signal a climax or absorption, warning of a potential reversal.

Filtering Time Noise: Because the "chunking" is based on actual price travel (Renko) rather than arbitrary time limits, the volume nodes identified are inherently tied to meaningful price displacement rather than sideways chop.

Settings & Inputs

Box Size Method: Choose between ATR (dynamic, based on market volatility) or Traditional (fixed price amount).

Renko ATR Period / Traditional Box Size: Defines the parameters for the size of a single Renko brick.

Chunk Window (N Bricks): The number of Renko bricks required to complete a "chunk." A lower number plots more frequently, while a higher number identifies macro high-volume nodes over larger price moves.

Colors: Fully customizable pivot colors for up and down trends.

(Note: Ensure your chart data provides sufficient volume information for your selected ticker to get accurate readings).

---

## Source Code

````pine
//@version=6
indicator("Renko Volume Tracker", overlay=true, max_labels_count=500)

// ==============================================================================
// 1. SETTINGS (Copy these inputs to your script)
// ==============================================================================
chunkGroup = '--- Renko Volume Chunking ---'
paramType = input.string('ATR', title='Box Size Method', options=['ATR', 'Traditional'], group=chunkGroup)
renkoAtrLength = input.int(14, title='Renko ATR Period', minval=1, group=chunkGroup)
traditionalBoxSize = input.float(1.0, title='Traditional Box Size', minval=0.0001, group=chunkGroup)

nBricks = input.int(3, title='Chunk Window (N Bricks)', minval=1, group=chunkGroup)
pivotColorUp = input.color(color.new(color.teal, 0), title='Pivot Color (Up Trend)', group=chunkGroup)
pivotColorDn = input.color(color.new(color.purple, 0), title='Pivot Color (Down Trend)', group=chunkGroup)

// ==============================================================================
// 2. FETCH RENKO DATA
// ==============================================================================
renkoTicker = ticker.renko(syminfo.tickerid, paramType, paramType == 'ATR' ? renkoAtrLength : traditionalBoxSize)

// Get Renko Close to determine when a brick forms and trend direction
renkoClose = request.security(renkoTicker, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Determine basic Renko trend (1 = Up, -1 = Down)
var int renkoTrend = 1
renkoTrend := renkoClose > nz(renkoClose[1], renkoClose) ? 1 : renkoClose < nz(renkoClose[1], renkoClose) ? -1 : renkoTrend

// ==============================================================================
// 3. CORE VOLUME CHUNKING LOGIC
// ==============================================================================
bool newBrick = ta.change(renkoClose) != 0
float currentVol = nz(volume)

// State variables to track data inside the N-brick window
var int   brickCount     = 0
var float chunkMaxVol    = 0.0
var int   chunkMaxBar    = na
var float chunkMaxPivot  = na
var color chunkMaxColor  = na

// Step A: Continually check and update the highest volume candle inside the chunk
if currentVol > chunkMaxVol or chunkMaxVol == 0
    chunkMaxVol   := currentVol
    chunkMaxBar   := bar_index
    // Plot at Low if it's an Up brick, High if it's a Down brick
    chunkMaxPivot := renkoTrend == 1 ? low : high 
    chunkMaxColor := renkoTrend == 1 ? pivotColorUp : pivotColorDn

// Step B: A Renko brick completes on this bar
if newBrick
    brickCount += 1
    
    // Step C: Check if we reached our target N bricks (e.g., 3 bricks)
    if brickCount >= nBricks
        if not na(chunkMaxBar)
            // Plot the permanent historical circle on that exact highest-volume candle
            label.new(
                 x = chunkMaxBar, 
                 y = chunkMaxPivot, 
                 text = "", 
                 style = label.style_circle, 
                 color = chunkMaxColor, 
                 size = size.normal, 
                 tooltip = "Top Vol Candle (Chunk of " + str.tostring(nBricks) + " Bricks)\nCandle Vol: " + str.tostring(chunkMaxVol, format.volume)
             )
        
        // Reset our variables to start tracking the NEXT chunk of N bricks fresh
        brickCount    := 0
        chunkMaxVol   := 0.0
        chunkMaxBar   := na
        chunkMaxPivot := na
        chunkMaxColor := na
````
