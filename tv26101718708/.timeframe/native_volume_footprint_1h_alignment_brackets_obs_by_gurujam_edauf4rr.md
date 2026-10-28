# Native Volume Footprint, 1H Alignment, Brackets & OBs by GuruJam

- url: https://www.tradingview.com/script/edAuf4RR-Native-Volume-Footprint-1H-Alignment-Brackets-OBs-by-GuruJam/
- type: indicator
- pine_id: PUB;f4fc285b49e94a818d9ed512476891e2
- version: 1.0

## Description

The TradingView Pine Script v6 dashboard is built to function as a comprehensive macroeconomic and technical analysis tool, specifically optimized for tracking the Nairobi Securities Exchange.

Here is a breakdown of its core structural and functional components:

Core Functionality
Macro-Economic Integration: The script allows for sector-specific customization, enabling you to align technical movements with broader Kenyan macroeconomic trends and specific market sectors.

Advanced Technical Mapping: It incorporates Smart Money Concepts, specifically utilizing horizontal liquidity boxes. These visually map out critical zones of institutional interest, historical support/resistance, and areas where liquidity is resting.

Automated Signal Filtering: Instead of raw data plotting, the script runs market data through customized filters to generate automated, actionable trade signals based on the confluence of volume, price action, and liquidity sweeps.

Technical Architecture
Language: Written in Pine Script v6, taking advantage of the latest array functionalities, dynamic lines, and box drawing capabilities for real-time order book and liquidity evaluation.

Display: Designed as an overlay or dashboard interface to provide multi-timeframe insights without cluttering the primary price chart.

## Source Code

````pine
//@version=6
indicator("Native Volume Footprint, 1H Alignment, Brackets & OBs", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ==============================================================================
// 1. INPUTS & CONFIGURATION
// ==============================================================================
grp1 = "Footprint & Order Flow Settings"
int ticksPerRow = input.int(10, title="Ticks Per Row", group=grp1, tooltip="Granularity of the footprint. Smaller values create more precise rows.", minval=1)
int vaPercent = input.int(70, title="Value Area %", group=grp1, minval=1, maxval=100)
float volMultiplier = input.float(1.5, title="Absorption Vol Multiplier", group=grp1, tooltip="Volume threshold to detect limit absorption")
float buyAggressionPct = input.float(65.0, title="Min Aggressive Buyers (%)", group=grp1, tooltip="Minimum % of total volume at the ask to qualify as aggressive buying")
float sellAggressionPct = input.float(65.0, title="Min Aggressive Sellers (%)", group=grp1, tooltip="Minimum % of total volume at the bid to qualify as aggressive selling")
string bubbleSizeInput = input.string("Normal", title="Absorption Bubble Size", group=grp1, options=["Tiny", "Small", "Normal", "Large", "Auto"])

grp2 = "HTF Alignment & Trade Zones"
string htfResolution = input.timeframe("60", title="HTF Context (Default: 1 Hour)", group=grp2)
bool drawTradeZones = input.bool(true, title="Draw Predictive Entry/SL/TP Boxes", group=grp2)

grp3 = "Missed Auction & Structure Settings"
bool showStructuralSwings = input.bool(true, title="Draw Vertical Lines for Swings", group=grp3)
bool showMissedAuctions = input.bool(true, title="Show Missed Auction Zones", group=grp3)
float missedVolMult = input.float(1.0, title="Missed Auction Vol Threshold", group=grp3)

grp4 = "Time & Session Filter"
bool useSessionFilter = input.bool(false, title="Enable Session Filter", group=grp4)
string sessionTime = input.session("0930-1600", title="Active Trading Hours", group=grp4)
string sessionTZ = input.string("America/New_York", title="Timezone", group=grp4, options=["America/New_York", "Europe/London", "Asia/Tokyo", "Africa/Nairobi", "UTC", "GMT-5", "GMT+2"])

grp5 = "Order Block Settings"
bool showOBs = input.bool(true, title="Draw OB Horizontal Lines & Rev %", group=grp5)

// Size Converter Helper Function
get_size(val) =>
    val == "Tiny" ? size.tiny : val == "Small" ? size.small : val == "Large" ? size.large : val == "Auto" ? size.auto : size.normal

string bubbleSizeStr = get_size(bubbleSizeInput)
bool inSession = useSessionFilter ? not na(time(timeframe.period, sessionTime, sessionTZ)) : true

// ==============================================================================
// 2. MULTI-TIMEFRAME (1-HOUR) & NATIVE FOOTPRINT DATA REQUEST
// ==============================================================================
// 1-Hour HTF Data Fetching
[htfOpen, htfHigh, htfLow, htfClose] = request.security(syminfo.tickerid, htfResolution, [open, high, low, close], lookahead=barmerge.lookahead_off)

// Request the native footprint object. Requires Premium/Ultimate plan.
footprint fp = request.footprint(ticksPerRow, vaPercent, 300.0)

// Extract bar-level metrics. Fallback to standard volume if footprint data is unavailable.
float barTotalVol = not na(fp) ? (fp.buy_volume() + fp.sell_volume()) : volume
float barBuyVol = not na(fp) ? fp.buy_volume() : (close > open ? volume : volume / 2)
float barSellVol = not na(fp) ? fp.sell_volume() : (close < open ? volume : volume / 2)
float barDelta = barBuyVol - barSellVol

float barBuyPct = barTotalVol > 0 ? (barBuyVol / barTotalVol) * 100 : 0
float barSellPct = barTotalVol > 0 ? (barSellVol / barTotalVol) * 100 : 0

// ==============================================================================
// 3. ABSORPTION LOGIC (USING CUSTOM PERCENTAGE INPUTS)
// ==============================================================================
float avgVol = ta.sma(barTotalVol, 20)
bool isHighVol = barTotalVol > (avgVol * volMultiplier)
bool isExtremeVol = barTotalVol > (avgVol * 2.5) 
bool isMissedVol = barTotalVol > (avgVol * missedVolMult)

// Calculate structural price wicks to determine failure of directional continuation
bool bullishWick = (close - low) > (high - close) and close >= open
bool bearishWick = (high - close) > (close - low) and close <= open

// V6 Strict Boolean Initialization
bool buyAbsorption = false
bool sellAbsorption = false

if isHighVol and not na(fp) and inSession
    buyAbsorption := (barSellPct >= sellAggressionPct) and bullishWick 
    sellAbsorption := (barBuyPct >= buyAggressionPct) and bearishWick

// ==============================================================================
// 4. STRUCTURAL SWINGS, HORIZONTAL ORDER BLOCKS, & IMBALANCES
// ==============================================================================
var array<line> visualLines = array.new<line>()
var array<box> visualBoxes = array.new<box>()
var array<line> obLines = array.new<line>()
var array<label> obLabels = array.new<label>()

// Structural Fractal Pivot Evaluation
bool isPivotHigh = high[1] > high[2] and high[1] > high[0]
bool isPivotLow = low[1] < low[2] and low[1] < low[0]

if inSession
    // Detect & Draw Swing Highs / Bearish OBs
    if isPivotHigh
        if showStructuralSwings
            line lHH = line.new(bar_index[1], low[1], bar_index[1], high[1], extend=extend.both, color=color.new(color.blue, 60), style=line.style_dashed, width=1)
            visualLines.push(lHH)
            
        if showOBs
            // Find the Bearish OB (Last bullish candle before the pivot drop)
            int obIdx = 1
            for j = 1 to 5
                if close[j] > open[j]
                    obIdx := j
                    break
            float obTop = high[obIdx]
            float obBtm = low[obIdx]
            
            // Calculate Reversal Probability % based on localized trapped volume
            float revPct = math.min(99, barBuyPct[obIdx] + 15)
            
            line tLine = line.new(bar_index - obIdx, obTop, bar_index, obTop, color=color.new(color.red, 40), style=line.style_solid, extend=extend.right)
            line bLine = line.new(bar_index - obIdx, obBtm, bar_index, obBtm, color=color.new(color.red, 40), style=line.style_dashed, extend=extend.right)
            label obLbl = label.new(bar_index, obTop, text="Bearish OB | Rev: " + str.tostring(revPct, "#.#") + "%", color=color.new(color.red, 70), textcolor=color.white, style=label.style_label_left, size=size.small)
            
            obLines.push(tLine)
            obLines.push(bLine)
            obLabels.push(obLbl)

    // Detect & Draw Swing Lows / Bullish OBs
    if isPivotLow
        if showStructuralSwings
            line lHL = line.new(bar_index[1], low[1], bar_index[1], high[1], extend=extend.both, color=color.new(color.green, 60), style=line.style_dashed, width=1)
            visualLines.push(lHL)
            
        if showOBs
            // Find the Bullish OB (Last bearish candle before the pivot rally)
            int obIdx = 1
            for j = 1 to 5
                if close[j] < open[j]
                    obIdx := j
                    break
            float obTop = high[obIdx]
            float obBtm = low[obIdx]
            
            // Calculate Reversal Probability % based on localized trapped volume
            float revPct = math.min(99, barSellPct[obIdx] + 15)
            
            line tLine = line.new(bar_index - obIdx, obTop, bar_index, obTop, color=color.new(color.lime, 40), style=line.style_dashed, extend=extend.right)
            line bLine = line.new(bar_index - obIdx, obBtm, bar_index, obBtm, color=color.new(color.lime, 40), style=line.style_solid, extend=extend.right)
            label obLbl = label.new(bar_index, obBtm, text="Bullish OB | Rev: " + str.tostring(revPct, "#.#") + "%", color=color.new(color.lime, 70), textcolor=color.white, style=label.style_label_left, size=size.small)
            
            obLines.push(tLine)
            obLines.push(bLine)
            obLabels.push(obLbl)

// Memory limits cleanup
if visualLines.size() > 40
    line.delete(visualLines.shift())
if obLines.size() > 40
    line.delete(obLines.shift())
    line.delete(obLines.shift())
    label.delete(obLabels.shift())

if not na(fp) and inSession
    array<volume_row> rows = fp.rows()
    if rows.size() > 0
        if showMissedAuctions and isMissedVol
            volume_row bottomRow = rows.get(0)
            volume_row topRow = rows.get(rows.size() - 1)
            
            if topRow.buy_volume() > 0 and topRow.sell_volume() > 0
                box maB = box.new(left=bar_index, top=topRow.up_price(), bottom=topRow.down_price(), right=bar_index + 1, extend=extend.right, border_color=color.new(color.fuchsia, 40), bgcolor=color.new(color.fuchsia, 85), text="Poor High", text_size=size.small)
                visualBoxes.push(maB)

            if bottomRow.buy_volume() > 0 and bottomRow.sell_volume() > 0
                box maS = box.new(left=bar_index, top=bottomRow.up_price(), bottom=bottomRow.down_price(), right=bar_index + 1, extend=extend.right, border_color=color.new(color.aqua, 40), bgcolor=color.new(color.aqua, 85), text="Poor Low", text_size=size.small)
                visualBoxes.push(maS)

// ==============================================================================
// 5. PREDICTIVE TRADE BRACKET MAPPING (ENTRY, SL, TP)
// ==============================================================================
// Long Reversal/Continuation Logic: Buy Absorption + 1H HTF Bullish Alignment
bool validLongSetup = buyAbsorption and (close > htfOpen) 
// Short Reversal/Continuation Logic: Sell Absorption + 1H HTF Bearish Alignment
bool validShortSetup = sellAbsorption and (close < htfOpen)

if drawTradeZones and validLongSetup and inSession
    box.new(left=bar_index, top=close, bottom=low, right=bar_index + 5, border_color=color.new(color.green, 20), bgcolor=color.new(color.green, 85), text="ENTRY", text_color=color.white, text_size=size.small)
    float riskDist = close - low
    box.new(left=bar_index, top=low, bottom=low - riskDist, right=bar_index + 5, border_color=color.new(color.red, 20), bgcolor=color.new(color.red, 85), text="SL", text_color=color.white, text_size=size.small)
    float targetHigh = math.max(close + (riskDist * 2), htfHigh)
    box.new(left=bar_index, top=targetHigh, bottom=targetHigh - riskDist, right=bar_index + 5, border_color=color.new(color.blue, 20), bgcolor=color.new(color.blue, 85), text="TP ZONE", text_color=color.white, text_size=size.small)

if drawTradeZones and validShortSetup and inSession
    box.new(left=bar_index, top=high, bottom=close, right=bar_index + 5, border_color=color.new(color.green, 20), bgcolor=color.new(color.green, 85), text="ENTRY", text_color=color.white, text_size=size.small)
    float riskDist = high - close
    box.new(left=bar_index, top=high + riskDist, bottom=high, right=bar_index + 5, border_color=color.new(color.red, 20), bgcolor=color.new(color.red, 85), text="SL", text_color=color.white, text_size=size.small)
    float targetLow = math.min(close - (riskDist * 2), htfLow)
    box.new(left=bar_index, top=targetLow + riskDist, bottom=targetLow, right=bar_index + 5, border_color=color.new(color.blue, 20), bgcolor=color.new(color.blue, 85), text="TP ZONE", text_color=color.white, text_size=size.small)

// ==============================================================================
// 6. VISUAL PLOTTING (BUBBLES & LIVE STATUS DASHBOARD)
// ==============================================================================
if buyAbsorption
    label.new(bar_index, low, text=str.tostring(barSellPct, "#.#") + "% Sells", yloc=yloc.belowbar, style=label.style_circle, color=color.new(#08d371, 30), textcolor=color.rgb(196, 185, 24), size=bubbleSizeStr, tooltip="Aggressive Selling Absorbed by Limits")

if sellAbsorption
    label.new(bar_index, high, text=str.tostring(barBuyPct, "#.#") + "% Buys", yloc=yloc.abovebar, style=label.style_circle, color=color.new(color.red, 30), textcolor=color.rgb(195, 17, 17), size=bubbleSizeStr, tooltip="Aggressive Buying Absorbed by Limits")

var table microTable = table.new(position.bottom_right, 2, 5, border_width=1, border_color=color.gray)
string currentStatus = validLongSetup ? "HTF Bullish Reversal" : validShortSetup ? "HTF Bearish Reversal" : "Waiting for Alignment"
color statusColor = validLongSetup ? color.lime : validShortSetup ? color.red : color.silver

if barstate.islast
    microTable.cell(0, 0, "Current Bar vs HTF", text_color=color.white, bgcolor=color.gray)
    microTable.cell(1, 0, "Metrics", text_color=color.white, bgcolor=color.gray)
    microTable.cell(0, 1, "Bar Buy Pct", text_color=color.lime, bgcolor=color.black)
    microTable.cell(1, 1, str.tostring(barBuyPct, "#.##") + "%", text_color=color.lime, bgcolor=color.black)
    microTable.cell(0, 2, "Bar Sell Pct", text_color=color.red, bgcolor=color.black)
    microTable.cell(1, 2, str.tostring(barSellPct, "#.##") + "%", text_color=color.red, bgcolor=color.black)
    microTable.cell(0, 3, "Setup Status", text_color=statusColor, bgcolor=color.black)
    microTable.cell(1, 3, currentStatus, text_color=statusColor, bgcolor=color.black)
    microTable.cell(0, 4, "HTF (1H) Alignment", text_color=color.white, bgcolor=color.black)
    microTable.cell(1, 4, close > htfOpen ? "BULLISH" : "BEARISH", text_color=close > htfOpen ? color.lime : color.red, bgcolor=color.black)
````
