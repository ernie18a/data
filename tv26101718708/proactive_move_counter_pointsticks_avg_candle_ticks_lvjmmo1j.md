# PRO-Active Move Counter (Points/Ticks) + Avg Candle (Ticks)

- url: https://www.tradingview.com/script/lvJmmO1j-PRO-Active-Move-Counter-Points-Ticks-Avg-Candle-Ticks/
- type: indicator
- pine_id: PUB;e87ab8f00d1643c3af0d6faafda2602c
- version: 1.0

## Description

[symbol="COMEX_MINI:MGC1!"]COMEX_MINI:MGC1![/symbol] 

Overview
The Active Move Counter is a high-performance momentum and trend-tracking tool designed for intraday traders. Unlike standard range indicators, this script identifies "Legs" of price action and provides a real-time, persistent data readout of the current move’s origin, travel distance, and active strength.
The core logic focuses on Move Persistence. It tracks exactly when a trend "flips" and anchors a starting point, allowing you to see how much "Net Push" the market is achieving relative to the start of the leg, rather than just the high-low range.


Key Features
Locked Origin Tracking: The indicator captures the exact Start Price and Start Time the moment a trend changes direction and holds them constant until the next flip.
Net Push Metric: Measures the current price's distance from the move's origin. This is vital for distinguishing between a strong trend and a weakening retrace.
Adaptive Direction Logic: Choose between Close vs. Close for sensitive tracking or Candle Body for a smoother, more stable trend filter.
Dynamic Table Readout: A clean, real-time dashboard in the corner of your chart keeping you informed on:
Leg Range: The total high-to-low span of the current move.
Net Push: Actual progress made from the leg's start.
Avg Candle Size: A lookback-based volatility gauge (in ticks) to help you set realistic targets.
Bar Count: Know exactly how many candles the current move has lasted.


How to Use
Identify the Start: Use the Start Time to reference the specific candle where momentum shifted.
Gauging Strength: Watch the Net Push. If the Leg Range is large but the Net Push is small, the market is retracing or consolidating. A Net Push that stays close to the Leg Range indicates a powerful trend.
Filtering Noise: Adjust the Min Flip Size (ticks) input to ignore small wiggles and keep the indicator anchored to significant market moves.

Settings
Avg Candle Lookback: Adjusts the period for the average candle size calculation.
Direction Method: Choose how the script detects a trend change.
Min Flip Size: The minimum number of ticks required to confirm a direction change (helps filter chop).
Rounding: Choose how points and ticks are rounded in the display.

## Source Code

````pine
//@version=6
indicator("Active Move Counter (Points/Ticks) + Avg Candle (Ticks)", overlay=true, max_labels_count=500)

//==================== Inputs ====================
lenAvg = input.int(9, "Avg Candle Lookback (bars)", minval=1)

round_output = input.string("Nearest", "Rounding", options=["Floor","Nearest","Ceil"])
dirMethod = input.string("Close vs Close", "Direction Method", options=["Close vs Close","Candle Body (Close vs Open)"])
minFlipTicks = input.int(0, "Min Flip Size (ticks) to change direction", minval=0,
     tooltip="0 = flip immediately when direction changes. Set >0 to ignore tiny flips.")

//==================== Helpers ====================
tickSize = syminfo.mintick

f_round(x) =>
    float out = na
    if round_output == "Floor"
        out := math.floor(x)
    else if round_output == "Ceil"
        out := math.ceil(x)
    else
        out := math.round(x)
    out

//==================== Avg Candle (ticks) ====================
rng = high - low
avgRange = ta.sma(rng, lenAvg)
avgTicksLive = avgRange / tickSize

var float avgTicksConfirmed = na
if barstate.isconfirmed
    avgTicksConfirmed := avgTicksLive

avgTicksRounded = f_round(avgTicksConfirmed)

//==================== Direction Detection ====================
float delta = na
if dirMethod == "Close vs Close"
    delta := close - close[1]
else
    delta := close - open

deltaTicks = delta / tickSize

var int dir = 0
int newDir = dir

bool upCandidate = deltaTicks > minFlipTicks
bool dnCandidate = deltaTicks < -minFlipTicks

if upCandidate
    newDir := 1
else if dnCandidate
    newDir := -1
else
    newDir := nz(dir, 0)

if dir == 0 and newDir == 0
    newDir := close > close[1] ? 1 : close < close[1] ? -1 : 0

//==================== Leg Tracking ====================
var float legHigh = na
var float legLow = na
var int legBars = 0
var int legStartTime = na
var float moveStartPrice = na // Variable to lock the origin price

bool flipped = (newDir != 0 and dir != 0 and newDir != dir)

if (dir == 0 and newDir != 0) or flipped
    dir := newDir
    legHigh := high
    legLow := low
    legBars := 1
    legStartTime := time
    // LOCK the price at the start of the leg
    // For UP moves, it's the Low of the candle that started it.
    // For DOWN moves, it's the High of the candle that started it.
    moveStartPrice := (dir == 1) ? low : high 
else
    dir := newDir
    legHigh := na(legHigh) ? high : math.max(legHigh, high)
    legLow := na(legLow) ? low : math.min(legLow, low)
    legBars += 1

// Safety check for first bars
if na(moveStartPrice)
    moveStartPrice := (dir == 1) ? low : high
    legStartTime := time

//==================== Metrics ====================
movePoints = (na(legHigh) or na(legLow)) ? na : (legHigh - legLow)
moveTicks = movePoints / tickSize

float netPoints = na
if not na(moveStartPrice)
    // Distance from the locked origin
    netPoints := dir == 1 ? (close - moveStartPrice) : (moveStartPrice - close)
netTicks = netPoints / tickSize

moveTicksR = f_round(moveTicks)
netTicksR = f_round(netTicks)

startTimeStr = str.format_time(legStartTime, "HH:mm:ss", syminfo.timezone)

//==================== Visuals ====================
plot(na) 

//==================== Table ====================
// Increased rows from 5 to 8
var table t = table.new(position.bottom_right, 1, 8, frame_color=color.new(color.white, 100), force_overlay=true)

dirTxt = dir == 1 ? "UP" : dir == -1 ? "DOWN" : "—"
dirIcon = dir == 1 ? "▲" : dir == -1 ? "▼" : "•"

if barstate.islast
    table.cell(t, 0, 0, "Active Move", text_color=color.white, bgcolor=color.black)
    table.cell(t, 0, 1, dirIcon + " " + dirTxt + " | Bars: " + str.tostring(legBars), text_color=color.white, bgcolor=color.black)

    // Row 2: Leg Range (Total high-low span of the move)
    table.cell(t, 0, 2, "Leg Range: " + (na(movePoints) ? "na" : str.tostring(movePoints, "#.##")) + " pts (" + (na(moveTicksR) ? "na" : str.tostring(moveTicksR)) + " ticks)", text_color=color.white, bgcolor=color.black)

    // Row 3: Start Price (LOCKED at the start of the leg)
    table.cell(t, 0, 3, "Start Price: " + str.tostring(moveStartPrice, format.mintick), text_color=color.white, bgcolor=color.black)

    // Row 4: Start Time (HH:mm:ss)
    table.cell(t, 0, 4, "Start Time: " + startTimeStr, text_color=color.white, bgcolor=color.black)

    // Row 5: Net Push (Distance price has actually pushed from Start Price)
    table.cell(t, 0, 5, "Net Push: " + (na(netPoints) ? "na" : str.tostring(netPoints, "#.##")) + " pts (" + (na(netTicksR) ? "na" : str.tostring(netTicksR)) + " ticks)", text_color=color.white, bgcolor=color.black)

    // Row 6: Current Price (Real-time update)
    table.cell(t, 0, 6, "Current Price: " + str.tostring(close, format.mintick), text_color=color.white, bgcolor=color.black)

    // Row 7: Avg Candle size
    table.cell(t, 0, 7, "Avg Candle (" + str.tostring(lenAvg) + "): " + (na(avgTicksRounded) ? "na" : str.tostring(avgTicksRounded)) + " ticks", text_color=color.white, bgcolor=color.black)
````
