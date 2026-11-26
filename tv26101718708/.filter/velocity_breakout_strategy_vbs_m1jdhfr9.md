# Velocity Breakout Strategy (VBS)

- url: https://www.tradingview.com/script/m1JDhFR9-Velocity-Breakout-Strategy-VBS/
- type: strategy
- pine_id: PUB;69b0ce5169ea4cb59a0e8c91b63ebfa1
- version: 1.0

## Description

Overview
The Velocity Breakout Strategy (VBS) is a comprehensive, institutional-grade swing trading system designed to identify high-probability momentum shifts. Rather than relying on a single lagging indicator, VBS synthesizes five distinct dimensions of market data: Macro Trend, Market Structure, Smart Money Concepts (SMC) valuation, Volatility (ATR/ADX), and Intrabar Volume Delta.
The goal of VBS is to filter out low-probability "chop" and only trigger entries when structural momentum aligns with aggressive buying volume.
Core Mechanics & Underlying Logic
1. Trend & Gradient Cloud Baseline The foundation of VBS is a multi-timeframe moving average system utilizing a Micro (9), Fast (20), and Slow (50) EMA. The relationship between the Fast and Slow EMAs paints a dynamic Gradient Cloud, instantly visualizing the macro trend.
2. Intrabar Volume Delta Estimation Standard volume tells you how much was traded, but not who was in control. VBS includes a custom Volume Delta Estimation engine. It approximates buying vs. selling pressure within a single candle by analyzing where the candle closes relative to its total high-to-low range.
The Filter: VBS can be configured to strictly block any buy signals if the current candle exhibits negative Delta (where estimated selling pressure outweighs buying pressure), preventing entries into hidden institutional distribution.
3. Smart Money Concepts (SMC) Valuation Zones VBS calculates a rolling 100-bar Dealing Range to map out institutional liquidity. It splits this range to identify "Premium" (overvalued) and "Discount" (undervalued) zones. The strategy actively looks for pullback entries (Reloads) when the asset drops into the Discount zone.
4. Volatility & Dynamic ATR Trailing Stops Risk management is handled by a responsive ATR Trailing Stop that adapts to the Average Directional Index (ADX).
During trending phases, the ATR multiplier is wide to let the trade breathe.
When the ADX detects a volatility "Squeeze" (ADX < 20), VBS dynamically tightens the ATR multiplier, protecting profits before a sudden volatile expansion occurs.
5. Master Candle Consolidation VBS scans for extreme volatility contraction using a "Master Candle" concept. If the price prints 4 consecutive bars entirely within the High/Low bounds of a previous Master Candle, the system arms a Breakout Trigger.
Entry Signals (When to Buy)
VBS generates specific, visual entry signals on the chart:
A+ Buy (Lime Triangle): A Golden Cross (20/50 EMA) occurs simultaneously with a verified Higher Low in market structure, backed by positive volume delta.
Risky Buy (Orange Triangle): A Golden Cross occurs, but the strict Higher Low market structure is not yet confirmed.
Bullish Reload (Blue Arrow): A zero-lag pullback entry. Price dips into the SMC Discount zone, touches the Fast EMA, and sweeps liquidity (long lower wick), closing with positive delta.
Consolidation Breakout (Purple Arrow): Price violently breaks the bounds of a 4-bar Master Candle consolidation in the direction of the macro trend.
Exit Strategy (When to Sell)
ATR Trail Exit (Red Down Triangle): The primary exit. Triggers when price closes below the dynamic ATR Trailing Stop.
Macro Break: A failsafe exit triggered if a Death Cross (20 EMA crossing under 50 EMA) occurs while holding a position.
The Strategy Manual: How to Use the Settings
We have built a professional-grade algorithm, which means it has "levers" designed to adapt to almost any market condition. Think of these settings as the steering wheel, gas pedal, and brakes for your strategy. Here is your complete manual on exactly what each setting does, when to change it, and how to use it.
1. Moving Averages & Trend These define the "macro environment." They tell the algorithm whether it is allowed to look for long setups or if it needs to stay out.
Micro EMA Length (Default: 9): The fast-moving trigger line. Decrease to 5 if you are scalping on a 1-minute chart. Increase to 12 if you want to ignore tiny 1-bar pullbacks.
Fast/Slow EMA Length (Default: 20/50): The core trend cloud. If you are swing trading daily charts and want to catch massive, long-term trends, change these to the traditional 50 and 200.
2. Smart Triggers & Structure This is the "Brain" of the algorithm that filters out bad setups.
Real-Time Lookback (Micro) (Default: 12): How many candles backward the script looks to verify a recent "Higher Low" was made before a crossover. If the script is missing valid entries because the pullback was long and drawn out, increase this to 20.
Pivot Lookback/Forward (Macro) (Default: 5): Purely visual. It dictates how many candles are needed to confirm the HH/LL text labels on the chart.
Require Higher Low for A+ Entry (Default: Checked): The strictest safety filter. Uncheck this if you are trading highly volatile assets (like Crypto) that often V-bottom and explode upward without stopping to form a higher low.
Max Run-up % (Chase Filter) (Default: 10.0): Stops the algorithm from buying if the price has already pumped 10% from the bottom. If you are trading Small Caps that regularly pump 30% in a single candle, you must increase this to 20 or 30.
Block Entries in Gray Chop Zone (Default: Checked): The anti-whipsaw filter. Uncheck only if you are actively trying to buy at the absolute bottom of a sideways consolidation box before the momentum officially kicks in.
3. Master Candle Consolidation Your custom logic for catching coiled breakouts.
Required Follow-up Bars (Default: 4): How many candles must get trapped inside the Master Candle. Reduce to 3 on high-timeframes (Daily/Weekly) where 4 days of resting is rare. Increase to 6 or 8 on 5-minute charts to ensure the consolidation is truly exhausted.
Use Master High/Low Bounds (Default: Checked): If unchecked, it only uses the candle body (Open to Close). Uncheck this on highly volatile, "wicky" charts where a single stray wick keeps ruining your consolidation count.
Require Bull Trend & Green ATR for Breakout (Default: Checked): Uncheck this if you want to trade "Reversal Breakouts" (buying an upward breakout before the macro trend has officially flipped bullish).
4. Smart Money Concepts (SMC) Ensures you are buying at a wholesale price.
Dealing Range Lookback (Default: 100): Decrease to 50 for faster, more aggressive zone shifting during rapid market regimes.
Require SMC Zone for Reloads (Default: Checked): Uncheck this during a raging, parabolic bull market where price never pulls back deep enough to hit the discount zone.
5. Dynamic ATR Exits (ADX Squeeze) Your trailing stop-loss manager.
Base ATR Multiplier (Trend) (Default: 3.0): Change to 2.0 for tighter risk management on large-cap stocks. Increase to 4.0 or 5.0 for highly erratic Crypto assets.
Tight ATR Multiplier (Chop) (Default: 1.5): The "choke" stop. Keep this very tight (1.0 to 1.5) to protect profits when momentum dies.
ADX Squeeze Threshold (Default: 20): Increase to 25 if you want the algorithm to aggressively lock in profits the second a trend shows minor weakness.
6. Volume Analysis & POC (Visuals)
Volume Lookback & StDev Multiplier: These dictate when the Fuchsia (Distribution) and Blue (Accumulation) diamonds appear. If you are getting too many diamond alerts, increase the Multiplier to 4.0 so it only flags true anomaly volume.
POC Profile Rows (Default: 40): Resolution of the Volume Profile calculation that draws the yellow Point of Control line. Increase to 100 for a more precise POC line. Decrease to 20 if your TradingView app is lagging.
The VBS Dashboard
The script features a built-in, non-intrusive HUD (Heads Up Display) utilizing a "Lazy-Draw" architecture to prevent memory buffer crashes. It provides a real-time readout of:
Current Macro Trend & Market Structure (HH/HL/LL/LH)
Intrabar Delta State (Positive/Negative)
Volatility State (Expanding vs. ADX Squeeze)
Current SMC Zone (Premium vs. Discount)
Real-time Stop Risk (%)
Usage & Backtesting Notes
By default, the strategy is optimized for comprehensive backtesting. It utilizes a fixed quantity size (qty=1) and allows pyramiding. This ensures the Strategy Tester captures and records the success rate of every single signal generated by the engine, providing a pure, unclouded view of the strategy's mathematical edge.
Disclaimer: VBS is an educational tool designed for analyzing market structure and volume dynamics. It does not guarantee profits. Always use proper risk management and test extensively on paper before deploying real capital.

## Source Code

````pine
//@version=6
// ==========================================
// Velocity Breakout Strategy (VBS) - v2.0
// Type: Strategy (Backtester + Live UI)
// Updates: Rebranded to VBS. (Built on Verified Baseline v1.14 + Lazy Table Fix)
// ==========================================
// FIX: Added max_bars_back=1000 to prevent volume memory crashes
strategy("Velocity Breakout Strategy (VBS)", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.05, max_labels_count=500, max_lines_count=100, max_boxes_count=100, max_bars_back=1000)

// ==========================================
// 1. INPUTS
// ==========================================
groupMA      = "Moving Averages & Trend"
microLength  = input.int(9, title="Micro EMA Length", group=groupMA)
fastLength   = input.int(20, title="Fast EMA Length", group=groupMA)
slowLength   = input.int(50, title="Slow EMA Length", group=groupMA)

groupTrig    = "Smart Triggers & Structure"
structWindow = input.int(12, title="Real-Time Lookback (Micro)", group=groupTrig)
pivotBars    = input.int(5, title="Pivot Lookback/Forward (Macro)", group=groupTrig)
strictAplus  = input.bool(true, title="Require Higher Low for A+ Entry", group=groupTrig)
maxChasePct  = input.float(10.0, title="Max Run-up % (Chase Filter)", group=groupTrig)
blockChop    = input.bool(false, title="Block Entries in Gray Chop Zone", group=groupTrig) // UPDATED: Default is now false

groupConsol  = "Master Candle Consolidation"
consolBars   = input.int(4, title="Required Follow-up Bars", group=groupConsol)
useMasterWicks = input.bool(true, title="Use Master High/Low Bounds", group=groupConsol)
strictTrendBrk = input.bool(true, title="Require Bull Trend & Green ATR for Breakout", group=groupConsol, tooltip="Blocks consolidation breakouts if the stock is in a macro downtrend.")
showConsol   = input.bool(true, title="Highlight Consolidation Zone", group=groupConsol)

groupSMC     = "Smart Money Concepts (SMC)"
smcLookback  = input.int(100, title="Dealing Range Lookback", group=groupSMC)
strictSMC    = input.bool(true, title="Require SMC Zone for Reloads", group=groupSMC)

groupATR     = "Dynamic ATR Exits (ADX Squeeze)"
atrPeriod    = input.int(10, title="ATR Period", group=groupATR)
atrMult      = input.float(3.0, title="Base ATR Multiplier (Trend)", group=groupATR)
tightAtrMult = input.float(1.5, title="Tight ATR Multiplier (Chop)", group=groupATR)
adxSqueeze   = input.int(20, title="ADX Squeeze Threshold", group=groupATR)

groupVol     = "Volume Analysis & POC (Visuals)"
volLength    = input.int(300, title="Volume Lookback Baseline", group=groupVol)
volDevMult   = input.float(3.0, title="Volume StDev Multiplier", group=groupVol)
pocRows      = input.int(40, title="POC Profile Rows", group=groupVol)

groupVis     = "Visuals & HUD"
showHUD      = input.bool(true, title="Show VBS HUD Dashboard", group=groupVis)
color1       = input.color(color.new(color.yellow, 35), title='Cloud Center (Yellow)', group=groupVis)
color2       = input.color(color.new(color.lime, 35), title='Cloud Bull Top (Lime)', group=groupVis)
color3       = input.color(color.new(color.red, 35), title='Cloud Bear Bottom (Red)', group=groupVis)
fillCloud    = input.bool(true, title='Enable Gradient Cloud Fill', group=groupVis)


// ==========================================
// 2. CORE ENGINE & MACRO ENVIRONMENT
// ==========================================
microEMA = ta.ema(close, microLength)
fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)
[diplus, diminus, adx] = ta.dmi(14, 14)

plot(microEMA, color=color.new(#00e5ff, 15), title="Micro 9 EMA", linewidth=1)
pFast = plot(fastEMA, color=na, title="Fast EMA")
pSlow = plot(slowEMA, color=na, title="Slow EMA")

topVal = math.max(fastEMA, slowEMA)
botVal = math.min(fastEMA, slowEMA)
topClr = fillCloud ? (fastEMA > slowEMA ? color2 : color1) : na
botClr = fillCloud ? (fastEMA > slowEMA ? color1 : color3) : na
fill(pFast, pSlow, topVal, botVal, topClr, botClr, title="EMA Gradient Cloud")

isTightRange = ta.atr(14) < ta.atr(50)
bgcolor(isTightRange ? color.new(color.gray, 92) : na, title="ATR Chop Zone")

isBullCandle = close >= open


// ------------------------------------------
// 3. SMC & BASIC TREND LOGIC 
// ------------------------------------------
drHigh = ta.highest(high, smcLookback)
drLow  = ta.lowest(low, smcLookback)
drRange = drHigh - drLow
upperEq = drLow + (drRange * 0.60) 
inDiscount = close <= upperEq
inPremium  = close > upperEq

isBullishTrend = (fastEMA > slowEMA)
isBearishTrend = (fastEMA < slowEMA)


// ==========================================
// 4. DYNAMIC ATR TRAILING STOP 
// ==========================================
inProfit = strategy.position_size > 0 and close > strategy.position_avg_price
squeezeActive = (adx < adxSqueeze) and inProfit

currentAtrMult = squeezeActive ? tightAtrMult : atrMult
nLoss = currentAtrMult * ta.atr(atrPeriod)
var float xATRTrailingStop = 0.0

xATRTrailingStop := (close > nz(xATRTrailingStop[1], 0) and close[1] > nz(xATRTrailingStop[1], 0)) ? math.max(nz(xATRTrailingStop[1]), close - nLoss) :
   (close < nz(xATRTrailingStop[1], 0) and close[1] < nz(xATRTrailingStop[1], 0)) ? math.min(nz(xATRTrailingStop[1]), close + nLoss) : 
   (close > nz(xATRTrailingStop[1], 0)) ? close - nLoss : close + nLoss

var int pos = 0 
pos := (close[1] < nz(xATRTrailingStop[1], 0) and close > nz(xATRTrailingStop[1], 0)) ? 1 :
   (close[1] > nz(xATRTrailingStop[1], 0) and close < nz(xATRTrailingStop[1], 0)) ? -1 : nz(pos[1], 0)

color trailColor = pos == 1 ? (squeezeActive ? color.new(color.yellow, 0) : color.new(color.green, 20)) : color.new(color.red, 20)
plot(xATRTrailingStop, color=trailColor, title="ATR Trailing Stop", linewidth=2, style=plot.style_stepline)
atrIsGreen = (pos == 1)


// ------------------------------------------
// 5. MASTER CANDLE CONSOLIDATION & BREAKOUT
// ------------------------------------------
var float mTop = na
var float mBot = na
var int insideCount = 0
var bool consolArmed = false 

validTrendForBrk = strictTrendBrk ? (isBullishTrend and atrIsGreen) : true
isBreakoutUp = consolArmed and close > mTop and isBullCandle and validTrendForBrk
takeConsolBreakout = isBreakoutUp and (not blockChop or not isTightRange)

if na(mTop) or close > mTop or close < mBot
    mTop := useMasterWicks ? high : math.max(open, close)
    mBot := useMasterWicks ? low : math.min(open, close)
    insideCount := 0
    consolArmed := false 
else
    insideCount += 1

isTightConsolidation = insideCount >= consolBars
bgcolor(showConsol and isTightConsolidation ? color.new(#673ab7, 85) : na, title="Tight Master Consolidation") 

if isTightConsolidation
    consolArmed := true 

plotshape(takeConsolBreakout, title="Consolidation Breakout", style=shape.arrowup, location=location.belowbar, color=color.purple, size=size.normal, text="BrkOut")


// ==========================================
// 6. INSTITUTIONAL VOLUME ANALYSIS
// ==========================================
avgVol = ta.sma(volume, volLength)
stdevVol = ta.stdev(volume, volLength)
isClimacticVol = volume > (avgVol + (volDevMult * stdevVol))

isAccumulation = isClimacticVol and isBearishTrend
isDistribution = isClimacticVol and isBullishTrend

plotshape(isAccumulation, title="Accumulation", style=shape.diamond, location=location.belowbar, color=color.blue, size=size.small)
plotshape(isDistribution, title="Distribution", style=shape.diamond, location=location.abovebar, color=color.fuchsia, size=size.small)


// ==========================================
// 7. SMART CROSSOVER LOGIC
// ==========================================
var float macroBearLow = low
if ta.crossunder(fastEMA, slowEMA)
    macroBearLow := low 
if not isBullishTrend
    macroBearLow := math.min(macroBearLow, low)

goldenCross = ta.crossover(fastEMA, slowEMA) and barstate.isconfirmed
deathCross  = ta.crossunder(fastEMA, slowEMA) and barstate.isconfirmed

goldenCrossPrice = goldenCross ? fastEMA : na
deathCrossPrice  = deathCross ? fastEMA : na

plotshape(goldenCrossPrice, title="Golden Cross (+)", style=shape.cross, location=location.absolute, color=color.rgb(11, 11, 10), size=size.small)
plotshape(deathCrossPrice, title="Death Cross (+)", style=shape.cross, location=location.absolute, color=color.maroon, size=size.small)

recentLow  = ta.lowest(low, structWindow)
isRealTimeHL = recentLow > macroBearLow
validBullStructure = strictAplus ? isRealTimeHL : true

runUpPct = ((close - recentLow) / recentLow) * 100
validChase = runUpPct <= maxChasePct

takeLongCross = goldenCross and validBullStructure and validChase and (not blockChop or not isTightRange)
takeRiskyLong = goldenCross and not validBullStructure and not strictAplus and validChase and (not blockChop or not isTightRange)

plotshape(takeLongCross, title="A+ Buy", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.normal)
plotshape(takeRiskyLong, title="Risky Buy", style=shape.triangleup, location=location.belowbar, color=color.orange, size=size.normal)


// ==========================================
// 8. VISUAL MARKET STRUCTURE (Labels)
// ==========================================
ph = ta.pivothigh(high, pivotBars, pivotBars)
pl = ta.pivotlow(low, pivotBars, pivotBars)

var float lastPH = na
var float lastPL = na
var string currentStructMap = "Consolidating" 

if not na(ph)
    isHH = na(lastPH) ? false : ph > lastPH
    txt = isHH ? "HH" : ((not na(lastPH) and ph < lastPH) ? "LH" : "H")
    textColor = isHH ? color.green : color.red
    label.new(bar_index[pivotBars], ph, text=txt, style=label.style_none, textcolor=textColor, yloc=yloc.price, size=size.small)
    lastPH := ph
    currentStructMap := txt

if not na(pl)
    isLL = na(lastPL) ? false : pl < lastPL
    txt = (not na(lastPL) and pl > lastPL) ? "HL" : (isLL ? "LL" : "L")
    textColor = (not na(lastPL) and pl > lastPL) ? color.green : color.red
    label.new(bar_index[pivotBars], pl, text=txt, style=label.style_none, textcolor=textColor, yloc=yloc.price, size=size.small)
    lastPL := pl
    currentStructMap := txt


// ==========================================
// 9. ZERO-LAG RELOAD TRIGGERS (Pullback Buys)
// ==========================================
var bool bullArmed = true
if (close > ta.highest(high, 5)[1])
    bullArmed := true

bodySize = math.abs(close - open)
lowerWick = math.min(open, close) - low
isBullSweep = (lowerWick > bodySize * 1.5) and isBullCandle 

validSMC_Bull = strictSMC ? inDiscount : true
touchedEMA = ta.lowest(low, 4) <= fastEMA 
bullShift = (close > fastEMA) and isBullCandle 

rtBullishReload = isBullishTrend and bullArmed and touchedEMA and validSMC_Bull and (bullShift or isBullSweep) and atrIsGreen and barstate.isconfirmed and not goldenCross and (not blockChop or not isTightRange)

if rtBullishReload
    bullArmed := false

plotshape(rtBullishReload, title="Bullish Reload Entry", style=shape.arrowup, location=location.belowbar, color=color.blue, size=size.normal)


// ==========================================
// 10. STRATEGY EXECUTION & VISUAL EXITS
// ==========================================
longEntryCondition  = (takeLongCross or takeRiskyLong or rtBullishReload or takeConsolBreakout)

if longEntryCondition and strategy.position_size == 0
    strategy.entry("Long", strategy.long) 

visualAtrExit = (pos == -1 and pos[1] == 1) 

plotshape(visualAtrExit, title="SELL MARKER", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal)

if visualAtrExit
    strategy.close("Long", comment="Trail Exit")
    
if deathCross 
    strategy.close("Long", comment="Macro Break")


// ==========================================
// 11. VISUALS: MACRO POC & LAZY-DRAW DASHBOARD
// ==========================================
// FIX: Safely pulled historical functions out of the 'islast' block to prevent silent memory crashes
float maxP = ta.highest(high, volLength)
float minP = ta.lowest(low, volLength)
bool recentAcc = nz(math.sum(isAccumulation ? 1 : 0, 15)) > 0
bool recentDist = nz(math.sum(isDistribution ? 1 : 0, 15)) > 0

var float pocPrice = na
if barstate.islast
    float step = (maxP - minP) / pocRows
    a_vol = array.new_float(pocRows, 0.0)

    for i = 0 to volLength - 1
        if not na(close[i]) and step > 0
            int bin = math.floor((close[i] - minP) / step)
            bin := math.max(0, math.min(pocRows - 1, bin))
            array.set(a_vol, bin, array.get(a_vol, bin) + volume[i])

    float maxVol = 0.0
    int bestBin = 0
    for i = 0 to pocRows - 1
        if array.get(a_vol, i) > maxVol
            maxVol := array.get(a_vol, i)
            bestBin := i

    pocPrice := minP + (bestBin * step) + (step / 2)
    var line pocLine = na
    var label pocLabel = na
    if not na(pocLine)
        line.delete(pocLine)
    if not na(pocLabel)
        label.delete(pocLabel)

    pocLine := line.new(bar_index - volLength, pocPrice, bar_index + 20, pocPrice, color=color.yellow, width=2, style=line.style_dashed)
    pocLabel := label.new(bar_index + 20, pocPrice, "⬥ MACRO POC", color=color.new(color.black, 100), textcolor=color.yellow, style=label.style_label_left, size=size.small)

// FIX: Lazy-Draw architecture. Evaluates on every bar so it never vanishes.
var table hud = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.rgb(50, 50, 80, 50))

if showHUD
    string trendTxt = isBullishTrend ? "Bullish" : (isBearishTrend ? "Bearish" : "Neutral")
    color trendCol = isBullishTrend ? color.lime : (isBearishTrend ? color.red : color.gray)
    color structCol = (currentStructMap == "HH" or currentStructMap == "HL") ? color.lime : ((currentStructMap == "LL" or currentStructMap == "LH") ? color.red : color.gray)
    
    string volTxt = recentAcc ? "Accumulation" : (recentDist ? "Distribution" : "Normal Flow")
    color volCol = recentAcc ? color.aqua : (recentDist ? color.fuchsia : color.gray)
    
    string volaTxt = squeezeActive ? "ADX Squeeze" : "Expanding"
    color volaCol = squeezeActive ? color.orange : color.gray

    // FIX: Fallback string added so the table doesn't crash before the first POC calculations are complete
    float distToPOC = not na(pocPrice) and pocPrice > 0 ? (close - pocPrice) / pocPrice * 100 : 0.0
    string distTxt = not na(pocPrice) ? ((distToPOC > 0 ? "+" : "") + str.tostring(distToPOC, "#.##") + "%") : "..."
    color distCol = math.abs(distToPOC) < 1.0 ? color.yellow : color.white
    
    float atrRisk = close > 0 ? math.abs(close - nz(xATRTrailingStop)) / close * 100 : 0.0
    string riskTxt = str.tostring(atrRisk, "#.##") + "%"
    
    string smcZoneTxt = inPremium ? "Premium (Sell)" : "Discount (Buy)"
    color smcZoneCol = inPremium ? color.red : color.lime
    
    string consolTxt = consolArmed ? "Breakout Armed" : (isTightConsolidation ? "Tightly Coiled" : "Standard Action")
    color consolCol = consolArmed ? color.orange : (isTightConsolidation ? color.purple : color.gray)

    table.cell(hud, 0, 0, "VBS SYSTEM STATE", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 20), text_halign=text.align_left)
    table.cell(hud, 1, 0, "DATA", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 20), text_halign=text.align_right)
    table.cell(hud, 0, 1, "Macro Trend", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 1, trendTxt, text_color=trendCol, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 2, "Structure", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 2, currentStructMap, text_color=structCol, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 3, "Smart Volume", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 3, volTxt, text_color=volCol, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 4, "Volatility", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 4, volaTxt, text_color=volaCol, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 5, "Dist. to POC", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 5, distTxt, text_color=distCol, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 6, "SMC Zone", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 6, smcZoneTxt, text_color=smcZoneCol, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 7, "Stop Risk", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 7, riskTxt, text_color=color.orange, text_size=size.small, text_halign=text.align_right)
    table.cell(hud, 0, 8, "Price Action", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 8, consolTxt, text_color=consolCol, text_size=size.small, text_halign=text.align_right)
````
