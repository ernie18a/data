<!-- tradingview-pine-id: PUB;d4ac998a06834975af9f9c4cc94712c8 -->
<!-- tradingviewscripts-format: 1 -->
# FRK TRADES ORDER BLOCKS

Source: https://www.tradingview.com/script/Yk3e24fw-FRK-TRADES-ORDER-BLOCKS/

## Description

FRK TRADES ORDER BLOCKS
FRK TRADES ORDER BLOCKS is a clean market structure indicator designed to automatically identify the most recent valid bullish or bearish order block on your chart.
Instead of displaying multiple historical zones and cluttering the chart, the indicator focuses on one active order block at a time — the latest valid area created before a confirmed Break of Structure (BOS).
How It Works
A Bullish Order Block is identified as the last bearish candle before price breaks bullish market structure.
A Bearish Order Block is identified as the last bullish candle before price breaks bearish market structure.
When a newer valid order block forms, the previous zone is automatically removed so the chart stays clean and focused.
If the active order block becomes invalidated, the zone is automatically removed.
How to Use It
Use the highlighted order block as a potential area of interest when price returns to the zone.
Green OB: Bullish order block — watch for potential bullish reaction or continuation.
Red OB: Bearish order block — watch for potential bearish reaction or continuation.
An order block should not be used as a trade signal by itself. Look for additional confirmation such as market structure, trend direction, liquidity, rejection, volume, or price action.
Settings
Structure Sensitivity: Controls how sensitive the indicator is when identifying market structure.
Order Block Lookback: Controls how far back the indicator searches for the candle that created the move.
BOS Confirmation: Choose whether structure must break with a candle close or simply a wick.
OB Length: Controls how many candles the order block box extends.
Bullish / Bearish Colors: Fully customizable.
Transparency: Adjust the visibility of the order block zones.
OB Label: Turn the OB label on or off.
Timeframes
FRK TRADES ORDER BLOCKS automatically adapts to the current chart timeframe and can be used on intraday, swing, or higher-timeframe charts.
Designed for markets including NQ, ES, Gold, Forex, Crypto, and other actively traded instruments.
FRK TRADES ORDER BLOCKS — one zone, one focus, clean structure.

---

## Source Code

````pine
//@version=6
indicator("FRK TRADES ORDER BLOCKS", shorttitle="FRK OB", overlay=true, max_boxes_count=10)

// ─────────────────────────────────────────────
// STRUCTURE SETTINGS
// ─────────────────────────────────────────────
swingLength = input.int(3, "Structure Sensitivity", minval=1, maxval=20)

searchBars = input.int(20, "Order Block Lookback", minval=2, maxval=100)

breakType = input.string(
     "Close",
     "BOS Confirmation",
     options=["Close", "Wick"])

// ─────────────────────────────────────────────
// VISUAL SETTINGS
// ─────────────────────────────────────────────
boxLength = input.int(
     20,
     "OB Length (Candles)",
     minval=1,
     maxval=100)

bullColor = input.color(
     color.rgb(76, 175, 80),
     "Bullish OB Color")

bearColor = input.color(
     color.rgb(255, 82, 82),
     "Bearish OB Color")

transparency = input.int(
     80,
     "OB Transparency",
     minval=0,
     maxval=100)

borderTransparency = input.int(
     0,
     "Border Transparency",
     minval=0,
     maxval=100)

showLabel = input.bool(true, "Show OB Label")

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
bullFill = color.new(bullColor, transparency)
bearFill = color.new(bearColor, transparency)

bullBorder = color.new(bullColor, borderTransparency)
bearBorder = color.new(bearColor, borderTransparency)

// ─────────────────────────────────────────────
// MARKET STRUCTURE
// ─────────────────────────────────────────────
swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow  = ta.pivotlow(low, swingLength, swingLength)

var float lastHigh = na
var float lastLow  = na

var bool highBroken = false
var bool lowBroken  = false

if not na(swingHigh)
    lastHigh := swingHigh
    highBroken := false

if not na(swingLow)
    lastLow := swingLow
    lowBroken := false

// ─────────────────────────────────────────────
// BOS CONDITIONS
// ─────────────────────────────────────────────
bullBreak = not na(lastHigh) and (
     breakType == "Close"
     ? close > lastHigh
     : high > lastHigh)

bearBreak = not na(lastLow) and (
     breakType == "Close"
     ? close < lastLow
     : low < lastLow)

// ─────────────────────────────────────────────
// ONLY ONE ACTIVE ORDER BLOCK
// ─────────────────────────────────────────────
var box activeOB = na

// 1 = bullish
// -1 = bearish
// 0 = none
var int activeType = 0

// ─────────────────────────────────────────────
// BULLISH ORDER BLOCK
// Last bearish candle before bullish BOS
// ─────────────────────────────────────────────
if barstate.isconfirmed and bullBreak and not highBroken

    int bullOffset = na

    for i = 1 to searchBars
        if not na(close[i]) and close[i] < open[i]
            bullOffset := i
            break

    if not na(bullOffset)

        int obBar = bar_index - bullOffset

        // Delete previous OB
        if not na(activeOB)
            box.delete(activeOB)

        // Create newest bullish OB
        activeOB := box.new(
             left = obBar,
             top = high[bullOffset],
             right = obBar + boxLength,
             bottom = low[bullOffset],
             xloc = xloc.bar_index,
             extend = extend.none,
             border_color = bullBorder,
             border_width = 1,
             bgcolor = bullFill,
             text = showLabel ? "OB" : "",
             text_color = bullBorder,
             text_size = size.tiny,
             text_halign = text.align_left,
             text_valign = text.align_top)

        activeType := 1

    highBroken := true

// ─────────────────────────────────────────────
// BEARISH ORDER BLOCK
// Last bullish candle before bearish BOS
// ─────────────────────────────────────────────
if barstate.isconfirmed and bearBreak and not lowBroken

    int bearOffset = na

    for i = 1 to searchBars
        if not na(close[i]) and close[i] > open[i]
            bearOffset := i
            break

    if not na(bearOffset)

        int obBar = bar_index - bearOffset

        // Delete previous OB
        if not na(activeOB)
            box.delete(activeOB)

        // Create newest bearish OB
        activeOB := box.new(
             left = obBar,
             top = high[bearOffset],
             right = obBar + boxLength,
             bottom = low[bearOffset],
             xloc = xloc.bar_index,
             extend = extend.none,
             border_color = bearBorder,
             border_width = 1,
             bgcolor = bearFill,
             text = showLabel ? "OB" : "",
             text_color = bearBorder,
             text_size = size.tiny,
             text_halign = text.align_left,
             text_valign = text.align_top)

        activeType := -1

    lowBroken := true

// ─────────────────────────────────────────────
// INVALIDATION
// ─────────────────────────────────────────────
if not na(activeOB)

    // Bullish OB invalidated by close below the zone
    if activeType == 1 and close < box.get_bottom(activeOB)
        box.delete(activeOB)
        activeOB := na
        activeType := 0

    // Bearish OB invalidated by close above the zone
    else if activeType == -1 and close > box.get_top(activeOB)
        box.delete(activeOB)
        activeOB := na
        activeType := 0
````
