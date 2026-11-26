# Wyckoff Architectural Range - erdensedat

- url: https://www.tradingview.com/script/qyZm2O45-Wyckoff-Architectural-Range-erdensedat/
- type: indicator
- pine_id: PUB;698d10af8d084c6a9d5f3eafe42e02f7
- version: 1.0

## Description

The "Wyckoff Architectural Probability Range" is an advanced, non-overlapping consolidation detector and liquidity sweep identification system. Designed to keep charts clean, it dynamically adapts to market volatility and focuses solely on the current active trading range. 

Key Features:
- Dynamic ATR-Based Range Width: The indicator automatically adjusts its maximum allowed range width based on the asset's current volatility, ensuring it works seamlessly across both major assets (BTC, ETH) and highly volatile altcoins.
- Non-Overlapping Architecture: Historical ranges are completely removed upon a confirmed breakout, leaving only the active, actionable consolidation zone on your chart.
- Premium & Discount Zones: The range is mathematically divided into Premium (Top 25%), Equilibrium (Middle 50%), and Discount (Bottom 25%) zones. Internal EQ levels (0.4 and 0.6) are also projected.
- Advanced Retest Signals: 
  > Buy Signal: Prints when price crosses below the Discount EQ and subsequently retests and closes above it.
  > Sell Signal: Prints when price crosses above the Premium EQ and subsequently retests and closes below it.
- Smart Liquidity Detection (Spring & UTAD): Automatically identifies and labels wick-based liquidity sweeps outside the range.
- Mean Reversion Probability: A dynamic stats panel calculates the mean reversion probability based on the current deviation from the main Equilibrium level.
- Built-in Alert System: Provides any() alert conditions for Buy/Sell signals, Spring/UTAD sweeps, and Range Breakouts.
- Optional VWAP: Toggle a standard VWAP line on or off directly from the settings for additional confluence.

How to Use:
Use the statistical panel and structural boxes to identify institutional accumulation (Discount Zone) and distribution (Premium Zone). Wait for confirmed retest signals (Triangles) or liquidity sweeps (Spring/UTAD) for high-probability mean-reversion entries.

Disclaimer:
The information and scripts provided in this indicator are for educational and informational purposes only and do not constitute financial advice. Trading cryptocurrencies, forex, and other financial markets involves a high degree of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always conduct your own research and consult with a certified financial advisor before making any trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("Wyckoff Architectural Range - erdensedat", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Watermark (erdensedat) ---
var table watermark = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(watermark, 0, 0, "erdensedat", text_size = size.huge, text_color = color.new(color.gray, 85))

// --- Group: Core Settings ---
int lookback = input.int(200, "Lookback for Consolidation", group = "Architecture")
bool autoRangeWidth = input.bool(true, "Auto Range Width (ATR based)", group = "Architecture")
float maxRangeWidth = input.float(15.0, "Max Range Width (%) (If Auto is off)", tooltip = "Maximum allowed height of the range as a percentage", group = "Architecture")
int minBarsInRange = input.int(20, "Minimum Bars in Range", group = "Architecture")
bool showFibs = input.bool(true, "Show 0.4, 0.5 & 0.6 Levels", group = "Architecture")
int extendRight = input.int(2, "Extend Boxes (Bars to Right)", group = "Architecture")
bool showVwap = input.bool(false, "Show VWAP", group = "Indicators")

// --- VWAP Calculation ---
float vwapValue = ta.vwap
plot(showVwap ? vwapValue : na, "VWAP", color=color.new(#2962ff, 0), linewidth=2)

// --- Colors & Aesthetics ---
// Premium Split Colors
color colPremTop = color.new(#5c0e15, 90) // Darker red, more transparent
color colPremBot = color.new(#f23645, 80) // Normal red

// Discount Split Colors
color colDiscTop = color.new(#089981, 80) // Normal transparent green
color colDiscBot = color.new(#04473b, 90) // Darker green, more transparent

color colEq = color.new(#787b86, 90)
color colText = color.white

// --- Variables to Prevent Overlapping & Keep Only Active ---
var float rangeHigh = na
var float rangeLow = na
var int startIndex = na
var bool isActive = false

// Split Boxes
var box premiumTopBox = na
var box premiumBotBox = na
var box eqBox = na
var box discountTopBox = na
var box discountBotBox = na

var label statsLabel = na

// Lines
var line premiumEqLine = na
var line discountEqLine = na
var line mainEqLine = na
var line fib40Line = na
var line fib60Line = na

// Buy/Sell Labels next to EQs
var label buyLevelLbl = na
var label sellLevelLbl = na

// Array to store event labels (Signals, Sweeps, Breakouts)
var label[] eventLabels = array.new_label()

// Setup States for Signals
var int buyState = 0
var int sellState = 0

// --- Logic ---
float currentHigh = ta.highest(high, lookback)
float currentLow = ta.lowest(low, lookback)
float rangePercent = ((currentHigh - currentLow) / currentLow) * 100

// ATR multiplier adjusted: 200 mumluk bir aralık genellikle ortalama mum boyunun 25-30 katı kadar genişleyebilir.
float dynamicMaxPercent = autoRangeWidth ? (ta.atr(lookback) * 30 / currentLow) * 100 : maxRangeWidth
dynamicMaxPercent := math.max(3.0, dynamicMaxPercent) // Clamp minimum at 3%

float atrSpace = ta.atr(14) * 0.5 // For dynamic spacing of triangles

// Define when a new range should start
bool canStartNew = not isActive and rangePercent <= dynamicMaxPercent and rangePercent > 0.5

if canStartNew
    bool contained = true
    for i = 1 to minBarsInRange
        if high[i] > currentHigh or low[i] < currentLow
            contained := false
            break
            
    if contained
        isActive := true
        rangeHigh := currentHigh
        rangeLow := currentLow
        startIndex := bar_index - minBarsInRange
        
        buyState := 0
        sellState := 0
        
        float rangeHeight = rangeHigh - rangeLow
        float premiumBottom = rangeHigh - (rangeHeight * 0.25)
        float discountTop = rangeLow + (rangeHeight * 0.25)
        
        // EQs
        float premiumEq = (rangeHigh + premiumBottom) / 2
        float discountEq = (discountTop + rangeLow) / 2
        float mainEq = (rangeHigh + rangeLow) / 2 // This is the 0.5 level
        
        // Fibs
        float f40 = rangeHigh - (rangeHeight * 0.4)
        float f60 = rangeHigh - (rangeHeight * 0.6)
        
        // Clear old event labels
        for lbl in eventLabels
            label.delete(lbl)
        array.clear(eventLabels)
        
        string initialStats = "📐 Wyckoff Architecture\n" + "Range: " + str.tostring(rangePercent, "#.##") + "%\n" + "Mean Reversion Prob: ~68%"
        
        int rightIndex = bar_index + extendRight
        
        if na(premiumTopBox)
            // Create Boxes (Split)
            premiumTopBox := box.new(startIndex, rangeHigh, rightIndex, premiumEq, border_color = color.new(color.gray, 100), bgcolor = colPremTop)
            premiumBotBox := box.new(startIndex, premiumEq, rightIndex, premiumBottom, border_color = color.new(color.gray, 100), bgcolor = colPremBot)
            
            eqBox := box.new(startIndex, premiumBottom, rightIndex, discountTop, border_color = color.new(color.gray, 100), bgcolor = colEq)
            
            discountTopBox := box.new(startIndex, discountTop, rightIndex, discountEq, border_color = color.new(color.gray, 100), bgcolor = colDiscTop)
            discountBotBox := box.new(startIndex, discountEq, rightIndex, rangeLow, border_color = color.new(color.gray, 100), bgcolor = colDiscBot)
            
            // Create EQ Lines
            premiumEqLine := line.new(startIndex, premiumEq, rightIndex, premiumEq, color = color.new(#f23645, 30), style = line.style_dashed, width = 1)
            mainEqLine := line.new(startIndex, mainEq, rightIndex, mainEq, color = showFibs ? color.new(color.white, 30) : na, style = line.style_dashed, width = 2)
            discountEqLine := line.new(startIndex, discountEq, rightIndex, discountEq, color = color.new(#089981, 30), style = line.style_dashed, width = 1)
            
            // Create Fib Lines (0.4 and 0.6)
            fib40Line := line.new(startIndex, f40, rightIndex, f40, color = showFibs ? color.new(color.gray, 50) : na, style = line.style_dotted)
            fib60Line := line.new(startIndex, f60, rightIndex, f60, color = showFibs ? color.new(color.gray, 50) : na, style = line.style_dotted)
            
            // Stats Label
            statsLabel := label.new(bar_index, rangeHigh, initialStats, color = color.new(color.black, 50), textcolor = colText, style = label.style_label_left, size = size.small)
            
            // Level Labels
            buyLevelLbl := label.new(rightIndex, discountEq, "Buy Level", color = color.new(color.black, 100), textcolor = #089981, style = label.style_label_left, size = size.small)
            sellLevelLbl := label.new(rightIndex, premiumEq, "Sell Level", color = color.new(color.black, 100), textcolor = #f23645, style = label.style_label_left, size = size.small)
            
        else
            box.set_lefttop(premiumTopBox, startIndex, rangeHigh)
            box.set_rightbottom(premiumTopBox, rightIndex, premiumEq)
            box.set_lefttop(premiumBotBox, startIndex, premiumEq)
            box.set_rightbottom(premiumBotBox, rightIndex, premiumBottom)
            
            box.set_lefttop(eqBox, startIndex, premiumBottom)
            box.set_rightbottom(eqBox, rightIndex, discountTop)
            
            box.set_lefttop(discountTopBox, startIndex, discountTop)
            box.set_rightbottom(discountTopBox, rightIndex, discountEq)
            box.set_lefttop(discountBotBox, startIndex, discountEq)
            box.set_rightbottom(discountBotBox, rightIndex, rangeLow)
            
            line.set_xy1(premiumEqLine, startIndex, premiumEq)
            line.set_xy2(premiumEqLine, rightIndex, premiumEq)
            
            line.set_xy1(mainEqLine, startIndex, mainEq)
            line.set_xy2(mainEqLine, rightIndex, mainEq)
            line.set_color(mainEqLine, showFibs ? color.new(color.white, 30) : na)
            
            line.set_xy1(discountEqLine, startIndex, discountEq)
            line.set_xy2(discountEqLine, rightIndex, discountEq)
            
            line.set_xy1(fib40Line, startIndex, f40)
            line.set_xy2(fib40Line, rightIndex, f40)
            line.set_color(fib40Line, showFibs ? color.new(color.gray, 50) : na)
            
            line.set_xy1(fib60Line, startIndex, f60)
            line.set_xy2(fib60Line, rightIndex, f60)
            line.set_color(fib60Line, showFibs ? color.new(color.gray, 50) : na)
            
            label.set_xy(statsLabel, bar_index, rangeHigh)
            label.set_text(statsLabel, initialStats)
            
            label.set_xy(buyLevelLbl, rightIndex, discountEq)
            label.set_xy(sellLevelLbl, rightIndex, premiumEq)

// Manage Active Range
if isActive
    int rightIndex = bar_index + extendRight

    box.set_right(premiumTopBox, rightIndex)
    box.set_right(premiumBotBox, rightIndex)
    box.set_right(eqBox, rightIndex)
    box.set_right(discountTopBox, rightIndex)
    box.set_right(discountBotBox, rightIndex)
    
    line.set_x2(premiumEqLine, rightIndex)
    line.set_x2(mainEqLine, rightIndex)
    line.set_x2(discountEqLine, rightIndex)
    line.set_x2(fib40Line, rightIndex)
    line.set_x2(fib60Line, rightIndex)
    
    label.set_x(statsLabel, bar_index)
    label.set_x(buyLevelLbl, rightIndex)
    label.set_x(sellLevelLbl, rightIndex)
    
    float midLine = (rangeHigh + rangeLow) / 2
    float currentDev = math.abs(close - midLine) / (rangeHigh - rangeLow) * 100
    
    float meanReversionProb = 100 - (currentDev * 2)
    meanReversionProb := math.max(10, math.min(99, meanReversionProb))
    
    float rangeHeight = rangeHigh - rangeLow
    float premiumBottom = rangeHigh - (rangeHeight * 0.25)
    float discountTop = rangeLow + (rangeHeight * 0.25)
    float premiumEq = (rangeHigh + premiumBottom) / 2
    float discountEq = (discountTop + rangeLow) / 2
    
    // --- SIGNAL LOGIC (erdensedat specific) ---
    // Buy Logic State Machine
    if buyState == 0 and close < discountEq
        buyState := 1 // Indicated a cross below Buy Level
    else if buyState == 1 and close > discountEq
        buyState := 2 // Crossed back above
    else if buyState == 2 and low <= discountEq and close > discountEq
        // Retested and closed above!
        // Added ATR spacing so the triangle does not touch the candle wick
        array.push(eventLabels, label.new(bar_index, low - atrSpace, style = label.style_triangleup, color = #089981, size = size.small))
        buyState := 3 // Signal fired, prevent duplicate until reset
        alert("Wyckoff Architecture: Buy Level Retest Triggered!", alert.freq_once_per_bar_close)
        
    // Sell Logic State Machine
    if sellState == 0 and close > premiumEq
        sellState := 1 // Crossed above Sell Level
    else if sellState == 1 and close < premiumEq
        sellState := 2 // Crossed back below
    else if sellState == 2 and high >= premiumEq and close < premiumEq
        // Retested and bearish close below!
        // Added ATR spacing so the triangle does not touch the candle wick
        array.push(eventLabels, label.new(bar_index, high + atrSpace, style = label.style_triangledown, color = #f23645, size = size.small))
        sellState := 3 // Signal fired
        alert("Wyckoff Architecture: Sell Level Retest Triggered!", alert.freq_once_per_bar_close)
    
    // --- Breakout & Sweep Checks ---
    bool breakoutUp = close > rangeHigh
    bool breakoutDown = close < rangeLow
    
    bool isSpring = low < rangeLow and close > rangeLow
    bool isUTAD = high > rangeHigh and close < rangeHigh
    
    string eventText = ""
    if isSpring
        eventText := "\n⚠️ Spring Detected"
        array.push(eventLabels, label.new(bar_index, low - atrSpace, "Spring", color = color.new(#089981, 0), textcolor = color.white, style = label.style_label_up, size = size.tiny))
        alert("Wyckoff Architecture: Spring Detected (Liquidity Sweep)!", alert.freq_once_per_bar_close)
    else if isUTAD
        eventText := "\n⚠️ UTAD Detected"
        array.push(eventLabels, label.new(bar_index, high + atrSpace, "UTAD", color = color.new(#f23645, 0), textcolor = color.white, style = label.style_label_down, size = size.tiny))
        alert("Wyckoff Architecture: UTAD Detected (Liquidity Sweep)!", alert.freq_once_per_bar_close)
        
    string stats = "📐 Wyckoff Architecture\n" + 
                   "Width: " + str.tostring(rangePercent, "#.##") + "%\n" + 
                   "Deviation from EQ: " + str.tostring(currentDev, "#.##") + "%\n" +
                   "Mean Rev. Prob: " + str.tostring(meanReversionProb, "#.#") + "%" + eventText
                   
    label.set_text(statsLabel, stats)
    label.set_y(statsLabel, rangeHigh)
    
    if breakoutUp or breakoutDown
        if breakoutUp
            alert("Wyckoff Architecture: Range Breakout UP!", alert.freq_once_per_bar_close)
        else
            alert("Wyckoff Architecture: Range Breakout DOWN!", alert.freq_once_per_bar_close)
        
        isActive := false
        label.delete(statsLabel)
        label.delete(buyLevelLbl)
        label.delete(sellLevelLbl)
        box.delete(premiumTopBox)
        box.delete(premiumBotBox)
        box.delete(eqBox)
        box.delete(discountTopBox)
        box.delete(discountBotBox)
        line.delete(premiumEqLine)
        line.delete(mainEqLine)
        line.delete(discountEqLine)
        line.delete(fib40Line)
        line.delete(fib60Line)
        
        premiumTopBox := na
        premiumBotBox := na
        eqBox := na
        discountTopBox := na
        discountBotBox := na
        premiumEqLine := na
        mainEqLine := na
        discountEqLine := na
        fib40Line := na
        fib60Line := na
        statsLabel := na
        buyLevelLbl := na
        sellLevelLbl := na
````
