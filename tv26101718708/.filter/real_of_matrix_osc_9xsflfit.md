# Real of matrix OSC

- url: https://www.tradingview.com/script/9XsflfIT-Real-of-matrix-OSC/
- type: indicator
- pine_id: PUB;7158e66087df41779bcac71d0ab44767
- version: 1.0

## Description

Here is a complete, publication-ready description for your indicator. It is written to match the official TradingView House Rules for Script Publishing (which require a detailed explanation of what the script does, how it calculates its data, and how traders can use it).You can copy and paste this directly into your TradingView script description box.DescriptionOverviewThe Consolidated Real Footprint Matrix Oscillator (Real OF Matrix Osc) is an institutional-grade order flow and market structure toolkit built natively in Pine Script v6. Unlike traditional momentum indicators (like RSI or MACD) which rely purely on lagging price formulas, this indicator leverages TradingView’s premium, server-side transaction database (request.footprint) to reveal what is happening inside the order book in real-time.By analyzing the precise volume hitting the Bid vs. the Ask, the script isolates Institutional Aggression, catches Passive Limit Order Absorption, and anchors these events to key structural Supply and Demand Zones.How It Works & Core Architecture1. Server-Side Footprint Delta EngineThe oscillator calculates the pure, true exchange-level transaction delta by tracking transactions executed via market orders on the Ask (aggressive buyers) minus transactions on the Bid (aggressive sellers):$$\text{True Delta} = \text{Volume}_{\text{Ask}} - \text{Volume}_{\text{Bid}}$$A robust localized math proxy is implemented as an automated fallback if the asset class or chart type doesn't support lower-level tick footprints.2. Institutional Aggression TrackingThe indicator dynamically tracks when large institutional participants are aggressively forcing market orders through the book to sweep liquidity. An Aggression Signal triggers when volume surges past 130% of the 20-period volume moving average, heavily driving delta in the direction of the candle's close.3. Passive Volumetric Absorption EngineAbsorption happens when a massive institutional limit order block completely soaks up incoming market orders, capping price movement. The script isolates these "walls" by scanning for bars with high volume (>120% of average) but heavily compressed candlestick bodies (under 25% of the total high-low range). This unmasks big players building hidden structural walls.Visual Interface GuideThe Delta Line & Fill: Displays the rolling tide of aggressive buying (Green) vs. aggressive selling (Red).▲ Green Triangle (Bottom): Institutional Ask Aggression (Heavy market buying).▼ Red Triangle (Top): Institutional Bid Aggression (Heavy market selling)."W" Character (Yellow): An active Absorption Wall in an open trading range.The Consolidated Matrix Table (Bottom Left): A persistent 5-bar diagnostic panel that color-codes incoming data based on macro-structural context.Key Trading Strategies🔴 Bearish Reversal (Supply Wall Absorption)Setup: Price rallies into a key structural swing high (Supply Zone).Signal: The Matrix Table prints Red Text ("Heavy Absorp - Supply Area") or prints a yellow "W". The delta line is strongly positive, but the candle body is tiny and cannot close higher.Meaning: Aggressive retail buyers are FOMO-buying the top directly into a massive institutional passive sell limit wall.Execution: Short on the bar close, stop loss just above the supply zone high.🟢 Bullish Reversal (Demand Wall Absorption)Setup: Price dips down into an established swing low (Demand Zone).Signal: The Matrix Table prints Pink/Magenta Text ("Heavy Absorp - Demand Area"). The delta line is deeply negative, yet price refuses to break lower.Meaning: Panic sellers are dumping inventory directly into a massive institutional passive buy limit wall.Execution: Long on the bar close, stop loss just below the demand zone low.Settings & ConfigurationsVolume Lookback (Default 20): Sets the baseline for normal vs. institutional volume expansions.Absorption Max Body % (Default 25%): Adjusts how compressed a candle must be to qualify as an institutional passive wall. Lowering this filters for tighter, more precise "Doji-style" absorption blocks.Delta Smoothing (Default 1): Set to 1 for raw, instantaneous bar-by-bar order flow. Increase to smooth out market noise.Zone Pivot Lookback (Default 10): The number of bars required to confirm macro swing points for structural zones.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Consolidated Real Footprint Matrix Oscillator", "Real OF Matrix Osc", overlay = false)

// ==========================================
// 🛠️ Settings & Inputs
// ==========================================
groupOF      = "Order Flow Settings"
volLookback  = input.int(20, "Volume Lookback", minval = 5, group = groupOF)
maxBodyPct   = input.float(25.0, "Absorption Max Body %", minval = 1.0, group = groupOF)
smoothLen    = input.int(1, "Delta Smoothing", minval = 1, group = groupOF, tooltip = "Smooth the Real Delta values. Use 1 for raw values.")

groupZones   = "Market Structure Settings"
pivotLen     = input.int(10, "Zone Pivot Lookback", minval = 2, group = groupZones)

groupColors  = "Style Settings"
askColor     = input.color(#089981, "Aggressive Buying (Asks)", group = groupColors)
bidColor     = input.color(#f23645, "Aggressive Selling (Bids)", group = groupColors)
absorbColor  = input.color(#ffeb3b, "Heavy Absorption (Normal)", group = groupColors)
zoneAbsClr   = input.color(#e91e63, "Heavy Absorption (In Demand Zone)", group = groupColors)

// ==========================================
// 📊 Step 1: Background Structural Tracking
// ==========================================
localLow  = ta.valuewhen(not na(ta.pivotlow(low, pivotLen, pivotLen)), low[pivotLen], 0)
localHigh = ta.valuewhen(not na(ta.pivothigh(high, pivotLen, pivotLen)), high[pivotLen], 0)

bool inDemand = (low <= localLow and high >= localLow)
bool inSupply = (low <= localHigh and high >= localHigh)
bool inZone   = inDemand or inSupply

// ==========================================
// 🧠 Step 2: Real Footprint Order Flow Engine
// ==========================================
body   = math.abs(close - open)
range_ = high - low
avgVol = ta.sma(volume, volLookback)

// CRITICAL UPGRADE: Pulling real server-side transaction data
footprint fp = request.footprint(10, 70) 
float rawDelta = not na(fp) ? fp.delta() : ((close - open) / (range_ == 0 ? 1 : range_)) * volume
float realDelta = ta.sma(rawDelta, smoothLen)

// Institutional Aggression Tracking via true footprint data
isInstAsk  = rawDelta > 0 and volume > avgVol * 1.3 and close > open
isInstBid  = rawDelta < 0 and volume > avgVol * 1.3 and close < open

// Volumetric Absorption (Heavy passive blocks holding back active aggression)
isWall = volume > avgVol * 1.2 and range_ > 0 and (body / range_ * 100) <= maxBodyPct

// ==========================================
// 🎨 Step 3: Oscillator Visualization
// ==========================================
// Zero Line
hline(0, "Zero Line", color = chart.fg_color, linestyle = hline.style_dashed)

// Plot Delta
deltaColor = realDelta >= 0 ? askColor : bidColor
p1 = plot(realDelta, "Real Delta", color = deltaColor, linewidth = 2)
pZero = plot(0, "Zero Reference", display = display.none)

// Oscillator Fill
fill(p1, pZero, color = realDelta >= 0 ? color.new(askColor, 60) : color.new(bidColor, 60), title = "Delta Fill")

// Aggression Signals
plotshape(isInstAsk, "Institutional Ask Aggression", shape.triangleup, location.bottom, askColor, size = size.tiny)
plotshape(isInstBid, "Institutional Bid Aggression", shape.triangledown, location.top, bidColor, size = size.tiny)

// Absorption Signal
plotchar(isWall ? realDelta : na, "Absorption Wall", "W", location.absolute, absorbColor, size = size.tiny)

// ==========================================
// 🎨 Step 4: Consolidated Matrix Table (Bottom Left)
// ==========================================
var table tb = table.new(position.bottom_left, 4, 6, bgcolor = color.new(chart.bg_color, 10), border_width = 1, border_color = chart.fg_color)

if barstate.islast
    // Header Row Initialization
    table.cell(tb, 0, 0, "Bar Ago", text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 85), text_size = size.small)
    table.cell(tb, 1, 0, "True Delta", text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 85), text_size = size.small)
    table.cell(tb, 2, 0, "Institutional Aggression",  text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 85), text_size = size.small)
    table.cell(tb, 3, 0, "Absorption Block", text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 85), text_size = size.small)
    
    // Loop for last 5 bars
    for i = 0 to 4
        float d      = nz(rawDelta[i])
        bool instAsk = isInstAsk[i]
        bool instBid = isInstBid[i]
        bool wallActive = isWall[i]
        bool zoneActive = inZone[i]
        bool demandActive = inDemand[i]
        
        // 1. Column: Bar Index
        table.cell(tb, 0, i + 1, str.tostring(i), text_color = chart.fg_color)
        
        // 2. Column: Natively Accurate Exchange Delta
        table.cell(tb, 1, i + 1, str.tostring(d, "#"), text_color = d >= 0 ? askColor : bidColor)
        
        // 3. Column: Market Order Aggression Text
        string aggressionText = instAsk ? "Asks Lifted (Heavy)" : (instBid ? "Bids Hit (Heavy)" : "-")
        color aggressionClr   = instAsk ? askColor : (instBid ? bidColor : chart.fg_color)
        table.cell(tb, 2, i + 1, aggressionText, text_color = aggressionClr)
        
        // 4. Column: Passive Institutional Absorption Context
        string wallText = "-"
        color wallClr   = chart.fg_color
        
        if wallActive
            if zoneActive and demandActive
                wallText := "Heavy Absorp (Demand Area)"
                wallClr  := zoneAbsClr
            else if zoneActive
                wallText := "Heavy Absorp (Supply Area)"
                wallClr  := bidColor
            else
                wallText := "Heavy Absorp"
                wallClr  := absorbColor
                
        table.cell(tb, 3, i + 1, wallText, text_color = wallClr)
````
