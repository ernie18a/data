# Volume Footprint, Absorption & Imbalance Analysis by Gurujames

- url: https://www.tradingview.com/script/YVtr7hha-Volume-Footprint-Absorption-Imbalance-Analysis-by-Gurujames/
- type: indicator
- pine_id: PUB;2c9c78f53bbe48f19ee6a989200798af
- version: 1.0

## Description

Here is a breakdown of exactly what the tool does and how it helps you analyze the market.

1. Intrabar Order Flow Splitting (Delta Calculation)
Instead of just showing total volume, the script peers into the 1-minute timeframe inside your current candle to calculate the Volume Delta.

What it does: It separates aggressive market buying from aggressive market selling.

Why it matters: It tells you who is actually in control. A candle might close green, but if the delta is heavily negative, it means sellers were aggressively hitting the bid, but buyers held the line.

2. Trapped Trader Detection (Absorption Bubbles)
The script identifies exact moments when aggressive traders get trapped by passive limit orders from larger participants.

What it does: When extreme selling pressure fails to push the price down (leaving a bullish wick), or extreme buying pressure fails to push the price up (leaving a bearish wick), it triggers an absorption event.

Visual Output: It plots a circular bubble above or below the wick. Inside the bubble is the exact percentage of that candle's total volume that was absorbed.

Example: A green bubble reading "72%" means 72% of the bar's volume was aggressive selling that completely failed to move the market down.

3. Institutional Imbalance Zones (Extending Boxes)
This feature finds areas where the market became extremely one-sided, leaving a "vacuum" in the order book.

What it does: It scans for high-volume candles where one side outpaced the other by 300% or more (a 3:1 ratio).

Visual Output: It draws a semi-transparent, extending box (Green for Buy Imbalances, Red for Sell Imbalances) originating from the extreme of the candle.

Why it matters: These areas act as high-probability Supply and Demand zones. Because the move was so aggressive, liquidity was skipped. The market will very often retrace back to these boxes to "mitigate" or fill the skipped orders. The boxes auto-delete after an hour (configurable) to keep your chart clean once they become stale.

4. Unfinished Liquidity Magnets (Missed Auctions / Poor Extremes)
In auction market theory, a healthy market sweeps the high or low until volume tapers off to zero. When it doesn't, it creates a "poor" high or low.

What it does: It detects candles that close at their absolute highest or lowest tick while both buyers and sellers are still actively transacting high volume.

Visual Output: It highlights the upper or lower body of that specific candle with a bright extending box (Green for Missed Buys, Red for Missed Sells), accompanied by a small cross ().X

Why it matters: These zones represent "unfinished business." The market is highly likely to revisit these exact levels later to properly sweep the liquidity that was left hanging. You can toggle these visual zones on or off in the settings.

5. Real-Time Analytics Dashboards
The script paints two distinct data tables on your chart to give you micro and macro perspectives without having to do any math yourself.

The Macro Table (Top Right): Keeps a rolling 7-day memory of market aggressiveness. It shows you the total percentage of volume over the last week that resulted in trapped buyers vs. trapped sellers, helping you gauge the broader structural trend.

The Micro Table (Bottom Right): Acts as a live ticker for the active, moving candlestick. It updates tick-by-tick to show you the current bar's absorption percentages, whether an imbalance has triggered, and explicitly states the structural status (e.g., "BULLISH (Absorbing Sells)" or "Neutral").

## Source Code

````pine
//@version=6
indicator("Volume Footprint, Absorption & Imbalance Analysis by Gurujames", overlay=true, max_labels_count=500, max_boxes_count=500)

// ==============================================================================
// 1. INPUTS & CONFIGURATION
// ==============================================================================
grp1 = "Order Flow Settings"
ltf = input.timeframe("1", title="Intrabar Resolution", group=grp1, tooltip="Lower timeframe used to calculate buy/sell volume split.")
lookbackDays = input.int(7, title="Macro Lookback Period (Days)", group=grp1, minval=1)
volMultiplier = input.float(1.5, title="Absorption Vol Multiplier", group=grp1, tooltip="Volume threshold to detect absorption")

grp2 = "Imbalance Zone Settings"
imbalanceMult = input.float(3.0, title="Imbalance Threshold (3.0 = 300%)", group=grp2)
imbVolMultiplier = input.float(2.5, title="Imbalance Zone Vol Multiplier", group=grp2, tooltip="Strict volume requirement for high-volume areas only")
zoneLookbackHours = input.float(1.0, title="Zone Expiration Lookback (Hours)", group=grp2, tooltip="Deletes extending zones older than this period")

grp3 = "Missed Auction Settings"
showMissedAuctions = input.bool(true, title="Show Missed Auction Zones", group=grp3, tooltip="Toggle green/red highlight areas for missed auctions")
missedVolMult = input.float(1.0, title="Missed Auction Vol Threshold", group=grp3, tooltip="1.0 = 100% of average volume. Filters out low-volume poor highs/lows.")

// ==============================================================================
// 2. INTRABAR VOLUME SPLIT (FOOTPRINT PROXY)
// ==============================================================================
[ltfOpen, ltfClose, ltfVol] = request.security_lower_tf(syminfo.tickerid, ltf, [open, close, volume])

float buyVol = 0.0
float sellVol = 0.0

if array.size(ltfClose) > 0
    for i = 0 to array.size(ltfClose) - 1
        float c = array.get(ltfClose, i)
        float o = array.get(ltfOpen, i)
        float v = array.get(ltfVol, i)
        
        if c > o
            buyVol += v
        else if c < o
            sellVol += v
        else
            buyVol += (v / 2)
            sellVol += (v / 2)

float totalVol = buyVol + sellVol
float barDelta = buyVol - sellVol
float barDeltaPct = totalVol > 0 ? (barDelta / totalVol) * 100 : 0

// ==============================================================================
// 3. ABSORPTION & MISSED AUCTION LOGIC
// ==============================================================================
float avgVol = ta.sma(totalVol, 20)
bool isHighVol = totalVol > (avgVol * volMultiplier)
bool isExtremeVol = totalVol > (avgVol * imbVolMultiplier) 
bool isMissedVol = totalVol > (avgVol * missedVolMult) // 100%+ Volume Check for Missed Auctions

bool bullishWick = (close - low) > (high - close) and close >= open
bool bearishWick = (high - close) > (close - low) and close <= open

// Absorption
bool buyAbsorption = isHighVol and (sellVol > buyVol) and bullishWick 
bool sellAbsorption = isHighVol and (buyVol > sellVol) and bearishWick

// Missed Auctions (Requires extreme price close + volume threshold)
bool missedBuyAuction = (close == high) and (buyVol > 0) and (sellVol > 0) and isMissedVol
bool missedSellAuction = (close == low) and (sellVol > 0) and (buyVol > 0) and isMissedVol

float currentBuyAbsPct = buyAbsorption and totalVol > 0 ? (sellVol / totalVol) * 100 : 0.0
float currentSellAbsPct = sellAbsorption and totalVol > 0 ? (buyVol / totalVol) * 100 : 0.0
float currentBarTrappedBuyVol = buyAbsorption ? sellVol : 0.0
float currentBarTrappedSellVol = sellAbsorption ? buyVol : 0.0

// ==============================================================================
// 4. 300% VOLUME IMBALANCE LOGIC
// ==============================================================================
float safeSellVol = sellVol == 0 ? 1 : sellVol
float safeBuyVol = buyVol == 0 ? 1 : buyVol

bool isBuyImbalance = isExtremeVol and (close > open) and (buyVol / safeSellVol >= imbalanceMult)
bool isSellImbalance = isExtremeVol and (close < open) and (sellVol / safeBuyVol >= imbalanceMult)

// ==============================================================================
// 5. 7-DAY ROLLING METRICS ACCUMULATOR
// ==============================================================================
var array<float> deltaArray = array.new<float>()
var array<int>   timeArray  = array.new<int>()
var array<float> volArray   = array.new<float>()
var array<float> trapBuyArray = array.new<float>()
var array<float> trapSellArray = array.new<float>()

array.push(deltaArray, barDelta)
array.push(timeArray, time)
array.push(volArray, totalVol)
array.push(trapBuyArray, currentBarTrappedBuyVol)
array.push(trapSellArray, currentBarTrappedSellVol)

int msMacroLookback = lookbackDays * 86400000
while array.size(timeArray) > 0 and (time - array.get(timeArray, 0)) > msMacroLookback
    array.shift(deltaArray)
    array.shift(timeArray)
    array.shift(volArray)
    array.shift(trapBuyArray)
    array.shift(trapSellArray)

float rollingTotalVol = 0.0
float rollingTotalTrapBuy = 0.0
float rollingTotalTrapSell = 0.0

if array.size(deltaArray) > 0
    for i = 0 to array.size(deltaArray) - 1
        rollingTotalVol += array.get(volArray, i)
        rollingTotalTrapBuy += array.get(trapBuyArray, i)
        rollingTotalTrapSell += array.get(trapSellArray, i)

float rollingBuyAbsRate = rollingTotalVol > 0 ? (rollingTotalTrapBuy / rollingTotalVol) * 100 : 0
float rollingSellAbsRate = rollingTotalVol > 0 ? (rollingTotalTrapSell / rollingTotalVol) * 100 : 0

// ==============================================================================
// 6. VISUAL PLOTTING (ZONES, BUBBLES, CROSSES)
// ==============================================================================
var array<box> imbBoxes = array.new<box>()
var array<int> imbBoxTimes = array.new<int>()

// Plotting Imbalance Zones
if isBuyImbalance
    box b = box.new(left=bar_index, top=high, bottom=low, right=bar_index + 1, extend=extend.right, border_color=color.new(color.lime, 40), bgcolor=color.new(color.lime, 90), text="Buy Imb Zone")
    array.push(imbBoxes, b)
    array.push(imbBoxTimes, time)

if isSellImbalance
    box b = box.new(left=bar_index, top=high, bottom=low, right=bar_index + 1, extend=extend.right, border_color=color.new(color.red, 40), bgcolor=color.new(color.red, 90), text="Sell Imb Zone")
    array.push(imbBoxes, b)
    array.push(imbBoxTimes, time)

// Plotting Missed Auction Zones (Check Menu Toggle)
if showMissedAuctions and missedBuyAuction
    box maB = box.new(left=bar_index, top=high, bottom=open, right=bar_index + 1, extend=extend.right, border_color=color.new(color.green, 40), bgcolor=color.new(color.green, 85), text="Missed Buy (Poor High)")
    array.push(imbBoxes, maB)
    array.push(imbBoxTimes, time)

if showMissedAuctions and missedSellAuction
    box maS = box.new(left=bar_index, top=open, bottom=low, right=bar_index + 1, extend=extend.right, border_color=color.new(color.red, 40), bgcolor=color.new(color.red, 85), text="Missed Sell (Poor Low)")
    array.push(imbBoxes, maS)
    array.push(imbBoxTimes, time)

// Clean up ALL Zones older than the Lookback Period
int msZoneLookback = int(zoneLookbackHours * 3600000)
while array.size(imbBoxTimes) > 0 and (time - array.get(imbBoxTimes, 0)) > msZoneLookback
    array.shift(imbBoxTimes) 
    box oldBox = array.shift(imbBoxes) 
    box.delete(oldBox) 

// Absorption Bubbles
if buyAbsorption
    label.new(bar_index, low, text=str.tostring(currentBuyAbsPct, "#.#") + "%", yloc=yloc.belowbar, style=label.style_circle, color=color.new(#08d371, 30), textcolor=color.rgb(196, 185, 24), size=size.normal, tooltip="Aggressive Selling Absorbed")

if sellAbsorption
    label.new(bar_index, high, text=str.tostring(currentSellAbsPct, "#.#") + "%", yloc=yloc.abovebar, style=label.style_circle, color=color.new(color.red, 30), textcolor=color.rgb(195, 17, 17), size=size.normal, tooltip="Aggressive Buying Absorbed")

// Small Crosses for Missed Auctions (Evaluated in global scope to prevent compilation errors)
plotshape(showMissedAuctions and missedBuyAuction, title="Missed Buy Cross", style=shape.xcross, location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.tiny)
plotshape(showMissedAuctions and missedSellAuction, title="Missed Sell Cross", style=shape.xcross, location=location.belowbar, color=color.new(color.aqua, 0), size=size.tiny)

// ==============================================================================
// 7. DASHBOARDS
// ==============================================================================
var table macroTable = table.new(position.top_right, 2, 3, border_width=1, border_color=color.gray)
if barstate.islast
    table.cell(macroTable, 0, 0, str.tostring(lookbackDays) + "-Day Order Flow", text_color=color.white, bgcolor=color.gray)
    table.cell(macroTable, 1, 0, "Absorption Rate", text_color=color.white, bgcolor=color.gray)
    
    table.cell(macroTable, 0, 1, "7D Buy Absorption", text_color=color.lime, bgcolor=color.black)
    table.cell(macroTable, 1, 1, str.tostring(rollingBuyAbsRate, "#.##") + "%", text_color=color.lime, bgcolor=color.black)
    
    table.cell(macroTable, 0, 2, "7D Sell Absorption", text_color=color.red, bgcolor=color.black)
    table.cell(macroTable, 1, 2, str.tostring(rollingSellAbsRate, "#.##") + "%", text_color=color.red, bgcolor=color.black)

var table microTable = table.new(position.bottom_right, 2, 5, border_width=1, border_color=color.gray)

string currentStatus = buyAbsorption ? "BULLISH (Absorbing Sells)" : sellAbsorption ? "BEARISH (Absorbing Buys)" : "Neutral"
color statusColor = buyAbsorption ? color.lime : sellAbsorption ? color.red : color.silver

string imbStatus = isBuyImbalance ? "Buy Imbalance (300%+)" : isSellImbalance ? "Sell Imbalance (300%+)" : "Balanced"
color imbColor = isBuyImbalance ? color.lime : isSellImbalance ? color.red : color.silver

if barstate.islast
    table.cell(microTable, 0, 0, "Current Bar Data", text_color=color.white, bgcolor=color.gray)
    table.cell(microTable, 1, 0, "Metrics", text_color=color.white, bgcolor=color.gray)
    
    table.cell(microTable, 0, 1, "Bar Buy Abs Pct", text_color=color.lime, bgcolor=color.black)
    table.cell(microTable, 1, 1, str.tostring(currentBuyAbsPct, "#.##") + "%", text_color=color.lime, bgcolor=color.black)
    
    table.cell(microTable, 0, 2, "Bar Sell Abs Pct", text_color=color.red, bgcolor=color.black)
    table.cell(microTable, 1, 2, str.tostring(currentSellAbsPct, "#.##") + "%", text_color=color.red, bgcolor=color.black)

    table.cell(microTable, 0, 3, "Live Status", text_color=statusColor, bgcolor=color.black)
    table.cell(microTable, 1, 3, currentStatus, text_color=statusColor, bgcolor=color.black)
    
    table.cell(microTable, 0, 4, "Order Flow State", text_color=imbColor, bgcolor=color.black)
    table.cell(microTable, 1, 4, imbStatus, text_color=imbColor, bgcolor=color.black)
````
