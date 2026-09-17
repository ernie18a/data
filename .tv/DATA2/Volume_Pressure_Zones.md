<!-- tradingview-pine-id: PUB;2379cc07617a41ab869512631ba307e7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Pressure Zones

Source: https://www.tradingview.com/script/A0FgGN7Z/

## Description

The Volume Pressure Zones indicator identifies areas of concentrated buying and selling pressure by analyzing intra-bar price action and volume.

Rather than relying purely on price structure, this script estimates the internal volume pressure behind price movements. It splits the volume of each candle into Buy and Sell components based on where the candle closes relative to its high-low range.

How it Works:

Pressure Calculation: The script tracks the cumulative Buy and Sell volumes over a specified lookback period (default 6) and compares them against the average volume.

Zone Projection: When the concentrated pressure exceeds a user-defined threshold (default 1.3), it projects a visual zone forward.

Buy Zones (White): Represent areas of concentrated buying pressure, potentially acting as support.

Sell Zones (Black): Represent areas of concentrated selling pressure, potentially acting as resistance.

Overlap Prevention: To maintain a clean and readable chart, the script prevents new boxes of the same type from overlapping. A new zone is drawn only after the previous zone's extension period has fully elapsed.

Settings:

Pressure Threshold: Adjusts the sensitivity of zone creation. A higher value requires a stronger concentration of volume to draw a box.

Zone Extension: Determines how many bars forward the support/resistance box is projected.

Moving Average (Optional): An optional EMA is included with slope-based color coding for trend context. This is hidden by default to keep the chart clean.

This indicator does not predict future price movements but provides a visual mapping of where significant volume pressure has recently occurred. It is best used alongside other contextual market analysis.

How to Use (Trading Strategies & Applications):

1. The Pullback & Retest Strategy
These zones represent areas where significant capital was committed. Rather than entering a trade immediately as the zone forms, wait for the initial move to play out and look for a pullback to the zone.

Bullish Setup: Wait for a White (Buy) zone to form and price to move higher. When the price retraces back into this white zone, look for bullish rejection (e.g., a pin bar or engulfing candle) to enter long.

Bearish Setup: Wait for a Black (Sell) zone to form and price to drop. Sell on the retracement back into the black zone, using it as a resistance ceiling.

2. Trend Alignment (Using the Optional MA)
To avoid trading against the dominant momentum, use the built-in Moving Average (or your own preferred trend filter) to select high-probability zones.

Enable the Moving Average in the settings.

If the price is trading above a rising MA, prioritize White (Buy) zones for long entries and ignore black zones.

If the price is trading below a falling MA, prioritize Black (Sell) zones for short entries and ignore white zones.

3. Dynamic Risk Management (Stop Loss & Take Profit)
The zones provide logical, volume-backed levels for managing your risk and targeting profits.

Stop Loss Placement: When taking a long position from a support area, place your stop loss just below the bottom edge of the current White (Buy) zone.

Take Profit Placement: If you are in a long position, use the nearest developing or existing Black (Sell) zone as a realistic take-profit target, as it represents historical selling pressure.

4. Breakout Validation
When the price approaches a previously established pressure zone, observe how volume and price behave. If the price easily breaks through a thick Black (Sell) zone with strong momentum, it indicates that the buyers have fully absorbed the historical selling pressure. This invalidated resistance zone often flips to become future support.

Disclaimer: Like all technical indicators, Volume Pressure Zones should not be used in isolation. It works best when combined with broader market structure analysis, price action, and proper risk management.

---

## Source Code

````pine
//@version=6
indicator("Volume Pressure Zones", overlay=true, max_boxes_count=500)

// ──────────────────────────────────────────────
// 1. Volume Pressure Zones - Core 
// ──────────────────────────────────────────────
grpCore          = "Volume Pressure Zones - Core"
pressureLen      = input.int(6, "Pressure Lookback Length", minval=2, maxval=20, group=grpCore, tooltip="Lookback period for calculating volume pressure.")
pressureThresh   = input.float(1.3, "Pressure Threshold", minval=1.0, maxval=2.0, step=0.05, group=grpCore, tooltip="Volume concentration threshold (1.0 = Neutral, 1.3 = 65% concentration).")

// ──────────────────────────────────────────────
// 2. Volume Pressure Zones - Style 
// ──────────────────────────────────────────────
grpStyle         = "Volume Pressure Zones - Style"
zoneExtend       = input.int(15, "Zone Extension (Bars)", minval=1, maxval=100, group=grpStyle, tooltip="Number of bars the zone will extend forward.") 
sellColor        = input.color(color.new(#000000, 0), "Sell Color (Resistance)", group=grpStyle) // Black
buyColor         = input.color(color.new(#FFFFFF, 0), "Buy Color (Support)", group=grpStyle) // White
zoneOpacity      = input.int(70, "Zone Opacity", minval=0, maxval=100, group=grpStyle)
zoneBorderW      = input.int(1, "Border Width", minval=0, maxval=5, group=grpStyle)

// ──────────────────────────────────────────────
// 3. Moving Average 
// ──────────────────────────────────────────────
grpMA            = "Moving Average (Optional)"
showMA           = input.bool(false, "Show Moving Average", group=grpMA) 
maLength         = input.int(20, "Moving Average Length", minval=5, maxval=100, group=grpMA)
maColor1         = input.color(color.new(#FFFFFF, 0), "Color (Rising)", group=grpMA)
maColor2         = input.color(color.new(#000000, 0), "Secondary Color (Falling)", group=grpMA)
maAutoColor      = input.string("Slope", "Auto Color", options=["None", "Slope"], group=grpMA)
maLineWidth      = input.int(1, "Line Width", minval=1, maxval=5, group=grpMA)

// ──────────────────────────────────────────────
// Volume Delta Estimation (Pressure Calculation)
// ──────────────────────────────────────────────
float vol    = nz(volume, 1)
float rng    = high - low
float clsPos = rng > 0 ? (close - low) / rng : 0.5

float buyVol  = vol * clsPos
float sellVol = vol * (1.0 - clsPos)

float cumBuy  = math.sum(buyVol, pressureLen)
float cumSell = math.sum(sellVol, pressureLen)
float avgVol  = math.sum(vol, pressureLen) / 2.0 

float buyPressure  = avgVol > 0 ? cumBuy / avgVol : 1.0
float sellPressure = avgVol > 0 ? cumSell / avgVol : 1.0

bool isClosed = barstate.isconfirmed

// ──────────────────────────────────────────────
// Zone Detection & Overlap Prevention Logic
// ──────────────────────────────────────────────
bool isSellZone = isClosed and sellPressure >= pressureThresh and sellPressure > buyPressure
bool isBuyZone  = isClosed and buyPressure >= pressureThresh and buyPressure > sellPressure

// Variables to store the bar index of the last generated boxes
var int lastSellBar = -1000
var int lastBuyBar  = -1000

// Cooldown logic: Ensure distance from the last box is greater than zoneExtend to prevent overlap
bool newSellZone = isSellZone and not isSellZone[1] and (bar_index - lastSellBar > zoneExtend)
bool newBuyZone  = isBuyZone and not isBuyZone[1] and (bar_index - lastBuyBar > zoneExtend)

// ──────────────────────────────────────────────
// Zone Visualization (Boxes)
// ──────────────────────────────────────────────
int zoneTransp        = 100 - zoneOpacity
color sellZoneColor   = color.new(sellColor, zoneTransp)
color buyZoneColor    = color.new(buyColor, zoneTransp)
color sellBorderColor = zoneBorderW > 0 ? color.new(sellColor, math.max(zoneTransp - 20, 0)) : color.new(sellColor, 100)
color buyBorderColor  = zoneBorderW > 0 ? color.new(buyColor, math.max(zoneTransp - 20, 0)) : color.new(buyColor, 100)

if newSellZone
    lastSellBar := bar_index 
    float boxTop = high
    float boxBot = math.max(open, close) 
    box.new(bar_index, boxTop, bar_index + zoneExtend, boxBot, bgcolor=sellZoneColor, border_color=sellBorderColor, border_width=zoneBorderW)

if newBuyZone
    lastBuyBar := bar_index 
    float boxTop = math.min(open, close) 
    float boxBot = low
    box.new(bar_index, boxTop, bar_index + zoneExtend, boxBot, bgcolor=buyZoneColor, border_color=buyBorderColor, border_width=zoneBorderW)

// ──────────────────────────────────────────────
// Moving Average Visualization
// ──────────────────────────────────────────────
float maVal = ta.ema(close, maLength)
bool isMaRising = maVal > nz(maVal[1], maVal)
color maPlotColor = maAutoColor == "Slope" ? (isMaRising ? maColor1 : maColor2) : maColor1
plot(maVal, "Moving Average", color=maPlotColor, linewidth=maLineWidth, display = showMA ? display.all : display.none)

// ──────────────────────────────────────────────
// Alerts
// ──────────────────────────────────────────────
alertcondition(newSellZone, "Strong Sell Pressure Detected", "⚫ Sell Pressure Zone Created - Resistance Formed")
alertcondition(newBuyZone, "Strong Buy Pressure Detected", "⚪ Buy Pressure Zone Created - Support Formed")
````
