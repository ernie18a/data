# Z'-Score Histogram

- url: https://www.tradingview.com/script/cS2HG041-Z-Score-Histogram/
- type: indicator
- pine_id: PUB;3d748c5b515147bf95d3757a96cbbafd
- version: 2.0

## Description

WHAT IT DOES:
The Z'-Score Histogram is a volatility-adjusted momentum oscillator that quantifies how far the current asset price has deviated from its historical average. By calculating the standard deviation of price movement over a user-defined lookback period, it translates raw price action into clear statistical units. Instead of relying on the arbitrary overbought or oversold boundaries found in standard indicators like RSI, this script shows exactly how many standard deviations the current price is away from the mean, plotting the data as a clean, real-time histogram.

WHY IT IS USEFUL:
Standard bounded indicators can flatten out or bake at extreme levels during strong, prolonged trends. The Z'-Score Histogram solves this by using an unbounded statistical scale. This approach allows traders to instantly spot statistically significant anomalies, since a move beyond positive or negative three standard deviations happens less than one percent of the time in a normal distribution. It helps traders quickly identify whether an asset is in a sustainable trend or if it has stretched too far and is ripe for a mean-reversion snapback.

HOW IT ADDS VALUE TO THE COMMUNITY:
This script adds value to the community by bridging the gap between complex statistical trading and clean, modern chart aesthetics. Many public Z-score tools are either overly bare-bones or cluttered with heavy UI elements. This version delivers professional statistical data in a highly readable, actionable format without lagging or cluttering the workspace.

WHY THIS SCRIPT IS UNIQUE:
Several features make this script unique from others in the public library:
- Dual-Engine Filtering: Most scripts force you into a Simple Moving Average baseline. This version gives you a toggle to use an Exponential Moving Average instead, allowing the Z-score to react faster to sudden, high-volatility regime shifts.
- Dynamic Regime Classification Engine: The script automatically categorizes market states into six distinct, logical phases based on statistical probability, ranging from oversold and hostile to neutral, strong, and overbought.
- Ultra-Clean Dashboard Panel: Instead of a bulky table that blocks price action, it features a lightweight, floating text HUD in the top right. The background is borderless and transparent, adapting seamlessly to any chart theme.
- Visual Extreme Value Highlights: The histogram instantly shifts to high-contrast signature colors only when the market hits the statistically rare three standard deviation thresholds, immediately alerting you to extreme market exhaustion.

DISCLAIMER:
The author has made every effort to ensure the underlying mathematics and logic in this script are correct. However, trading involves substantial risk. If, for example, you buy an asset simply because it registers as oversold on this indicator, and it proceeds to become even more oversold while your position goes against you, that is entirely on you. This tool is for informational and educational purposes only, not financial or execution advice. Use proper risk management and trade at your own discretion.

## Source Code

````pine
//@version=6
indicator("Z'-Score Histogram", shorttitle="Z'-Score", overlay=false)

// ── Inputs ─────────────────────────────────────
lookback           = input.int(50, title="Lookback Period", minval=1, group="Settings")
maType             = input.string("EMA", title="Moving Average Type", options=["SMA", "EMA"], group="Settings")

// Divergence Settings
showDiv            = input.bool(true, title="Show Divergence Lines", group="Divergence Settings")
maxSearchBars      = input.int(89,  title="Max Backward Search Bars", minval=10, group="Divergence Settings")
divLeft            = input.int(8,   title="Pivot Left Bars",  minval=2, group="Divergence Settings")
divRight           = input.int(8,   title="Pivot Right Bars", minval=2, group="Divergence Settings")
minZPeak           = input.float(3.0, "Min |Z'| for Anchor Peak", minval=1.0, group="Divergence Settings")
minPricePct        = input.float(0.25, "Min Price % Change Threshold", minval=0.0, step=0.05, group="Divergence Settings", tooltip="Requires current price to exceed the previous pivot by this % to count as a true structural higher high / lower low.")

// Visual Toggles
showHLines         = input.bool(true, title="Show Threshold Lines", group="Levels & Labels")
showLabels         = input.bool(true, title="Show Dashboard Panel", group="Levels & Labels")
showFullZHighlights = input.bool(true, title="Enable Tiered Range Highlights", group="Colors")

// ── Calculations ───────────────────────────────
ma    = maType == "EMA" ? ta.ema(close, lookback) : ta.sma(close, lookback)
stdev = ta.stdev(close, lookback)
zScore = (close - ma) / stdev

// ── Color Schemes ──────────────────────────────
deepGreen   = color.rgb(0, 140, 0)
normalGreen = color.green
lightGreen  = color.new(color.green, 40)
lightRed    = color.new(color.red, 40)
normalRed   = color.red
deepRed     = color.rgb(140, 0, 0)

color barColor = na
if showFullZHighlights
    if zScore >= 0
        barColor := zScore > 3 ? deepGreen : zScore >= 1 ? normalGreen : lightGreen
    else
        barColor := zScore < -3 ? deepRed : zScore <= -1 ? normalRed : lightRed
else
    barColor := zScore >= 0 ? color.green : color.red

plot(zScore, title="Z-Score", style=plot.style_columns, color=barColor, linewidth=3)

// ── Reference Levels ───────────────────────────
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
hline(showHLines ? 1 : na,  "+1", color=color.new(color.green, 70), linestyle=hline.style_dashed)
hline(showHLines ? 2 : na,  "+2", color=color.new(color.green, 70), linestyle=hline.style_dashed)
hline(showHLines ? 3 : na,  "+3", color=color.new(color.green, 70), linestyle=hline.style_dashed)
hline(showHLines ? -1 : na, "-1", color=color.new(color.red, 70), linestyle=hline.style_dashed)
hline(showHLines ? -2 : na, "-2", color=color.new(color.red, 70), linestyle=hline.style_dashed)
hline(showHLines ? -3 : na, "-3", color=color.new(color.red, 70), linestyle=hline.style_dashed)

// ── %-Strict Structural Divergence Engine ──────
var array<int>   zHighBars   = array.new<int>()
var array<float> zHighValues = array.new<float>()
var array<float> zHighPrices = array.new<float>()

var array<int>   zLowBars    = array.new<int>()
var array<float> zLowValues  = array.new<float>()
var array<float> zLowPrices  = array.new<float>()

var int lastBearX1 = na
var int lastBullX1 = na

if showDiv and barstate.isconfirmed
    float currentZHigh = ta.pivothigh(zScore, divLeft, divRight)
    float currentZLow  = ta.pivotlow(zScore,  divLeft, divRight)
    
    // Total width of the pivot evaluation window
    int windowLen = divLeft + divRight + 1
    
    // ── %-STRICT BEARISH DIVERGENCE ────────────────
    if not na(currentZHigh)
        int   currentHighBar   = bar_index - divRight
        // Look at the highest structural high across the entire pivot window
        float currentHighPrice = ta.highest(high, windowLen)
        
        if array.size(zHighBars) > 0
            for i = array.size(zHighBars) - 1 to 0
                int   prevBar   = array.get(zHighBars, i)
                float prevZ     = array.get(zHighValues, i)
                float prevPrice = array.get(zHighPrices, i)
                
                if (bar_index - prevBar) > maxSearchBars
                    break
                
                if prevZ > minZPeak
                    float targetPriceThreshold = prevPrice * (1.0 + (minPricePct / 100.0))
                    
                    if (currentHighPrice > targetPriceThreshold) and (currentZHigh < prevZ)
                        
                        // Line of Sight verification
                        bool clearSky = true
                        int checkLen = currentHighBar - prevBar
                        if checkLen > 1
                            for j = 1 to checkLen - 1
                                if high[divRight + j] > currentHighPrice or zScore[divRight + j] > prevZ
                                    clearSky := false
                                    break
                        
                        if clearSky
                            if na(lastBearX1) or lastBearX1 != prevBar
                                line.new(x1 = prevBar, y1 = prevZ, x2 = currentHighBar, y2 = currentZHigh,
                                         xloc = xloc.bar_index, color = color.red, width = 2, style = line.style_solid)
                                lastBearX1 := prevBar
                            break 
        
        array.push(zHighBars, currentHighBar)
        array.push(zHighValues, currentZHigh)
        array.push(zHighPrices, currentHighPrice)
    
    // ── %-STRICT BULLISH DIVERGENCE ────────────────
    if not na(currentZLow)
        int   currentLowBar   = bar_index - divRight
        // Look at the lowest structural low across the entire pivot window
        float currentLowPrice = ta.lowest(low, windowLen)
        
        if array.size(zLowBars) > 0
            for i = array.size(zLowBars) - 1 to 0
                int   prevBar   = array.get(zLowBars, i)
                float prevZ     = array.get(zLowValues, i)
                float prevPrice = array.get(zLowPrices, i)
                
                if (bar_index - prevBar) > maxSearchBars
                    break
                
                if prevZ < -minZPeak
                    float targetPriceThreshold = prevPrice * (1.0 - (minPricePct / 100.0))
                    
                    if (currentLowPrice < targetPriceThreshold) and (currentZLow > prevZ)
                        
                        bool clearSky = true
                        int checkLen = currentLowBar - prevBar
                        if checkLen > 1
                            for j = 1 to checkLen - 1
                                if low[divRight + j] < currentLowPrice or zScore[divRight + j] < prevZ
                                    clearSky := false
                                    break
                        
                        if clearSky
                            if na(lastBullX1) or lastBullX1 != prevBar
                                line.new(x1 = prevBar, y1 = prevZ, x2 = currentLowBar, y2 = currentZLow,
                                         xloc = xloc.bar_index, color = color.green, width = 2, style = line.style_solid)
                                lastBullX1 := prevBar
                            break
        
        array.push(zLowBars, currentLowBar)
        array.push(zLowValues, currentZLow)
        array.push(zLowPrices, currentLowPrice)

    // Array cleanup
    while array.size(zHighBars) > 0 and (bar_index - array.get(zHighBars, 0) > maxSearchBars)
        array.shift(zHighBars)
        array.shift(zHighValues)
        array.shift(zHighPrices)
    while array.size(zLowBars) > 0 and (bar_index - array.get(zLowBars, 0) > maxSearchBars)
        array.shift(zLowBars)
        array.shift(zLowValues)
        array.shift(zLowPrices)

// ── UI Dashboard Table ─────────────────────────
string z_term   = "N/A"
color fontColor = color.gray

if not na(zScore)
    if zScore <= -3
        z_term := "OVERSOLD", fontColor := deepRed
    else if zScore < -1
        z_term := "HOSTILE", fontColor := normalRed
    else if zScore < 0
        z_term := "WEAK", fontColor := lightRed
    else if zScore < 1
        z_term := "NEUTRAL", fontColor := lightGreen
    else if zScore < 3
        z_term := "STRONG", fontColor := normalGreen
    else
        z_term := "OVERBOUGHT", fontColor := deepGreen

var table dashTable = na
if showLabels and barstate.islast
    if na(dashTable)
        dashTable := table.new(position=position.top_right, columns=1, rows=1, border_width=0)
    table.cell(dashTable, 0, 0, z_term + "\nZ': " + str.tostring(zScore, "#.##"), bgcolor=color.new(color.white, 10), text_color=fontColor, text_size=size.normal)
````
