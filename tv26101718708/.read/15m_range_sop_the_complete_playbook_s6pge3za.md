# 15m Range SOP: The Complete Playbook

- url: https://www.tradingview.com/script/S6PGe3zA-15m-Range-SOP-The-Complete-Playbook/
- type: indicator
- pine_id: PUB;404a775c5a7a4b6c8f54b40337824449
- version: 1.0

## Description

Here is a professional, comprehensive description formatted specifically for a TradingView script publication. It explains the ICT logic, the strict mechanical rules, and the built-in trade management in a way that other traders will immediately understand and value.
You can copy and paste this directly into the description box when you publish the script.
### Title: 15m Range SOP: The Complete Playbook (Liquidity & Displacement)
**Overview**
This indicator is a complete, mechanical trading system designed to map the transition from Accumulation to Distribution. Built for traders looking to remove emotion and trade strict probabilities—especially those navigating proprietary firm evaluations—this script visually tracks liquidity sweeps, confirms breakouts with volume, and dynamically plots scale-out targets.
Rather than guessing where a breakout will happen, this playbook forces you to wait for the market to reveal its hand by purging liquidity on *both* sides of a defined range before signaling an entry.
**Core Features & Mechanics**
 * **The Accumulation Range:** The script draws a strict 15-minute range box (High and Low) based on a user-defined reference time (default: 09:30 - 09:45) and plots the exact Equilibrium (50%) midline. It projects this active trading window forward for a customizable duration.
 * **Strict "Double Sweep" Filter (The Orange ✖):** Retail traders often get trapped by early, false breakouts. This script tracks wicks that pierce the boundaries but close back inside the box. It will **not** validate a breakout until *both* the top (Buy-Side Liquidity) and bottom (Sell-Side Liquidity) of the range have been swept, ensuring the market has fully engineered liquidity before making its true move.
 * **Displacement & CVD Confirmation (The Buy/Sell Arrows):**
   Once the Double Sweep is complete, the script waits for true Displacement—a full-body candle close outside the range boundary. When this happens, it prints an entry signal and calculates the intra-bar Volume Delta (buying vs. selling volume) of the trigger candle. This allows you to verify if the breakout is backed by aggressive order flow or if it is a low-volume trap.
 * **The 80/20 Protocol & Dynamic Targets:**
   The script looks back at previous price action to find major structural swing highs/lows. If a valid Displacement occurs, it automatically plots:
   * **TP1 (Scale Out):** The exact midpoint between your breakout entry and the final target. This is designed for the "80/20 Protocol"—securing 80% of your position to guarantee realized profit while moving your stop to breakeven/+10 on the runners.
   * **TP2 (Final Target):** The major structural Liquidity Pool.
**How to Use This Script**
 1. **Set Your Reference Candle:** In the settings, input the exact time of the 15-minute candle that establishes your range (e.g., the 09:30 open, or a specific news event candle).
 2. **Wait for the Setup:** Watch for the orange "✖ Sweep" labels. Let the market chop out the early participants.
 3. **Confirm the Trigger:** Wait for the bold Displacement arrow to print. Check the Volume Delta printed inside the label to confirm strong participation.
 4. **Execute the Plan:** Place your strict stop loss (e.g., 15 points on NQ/MNQ), take 80% off at the blue dashed TP1 line, and let the runners work toward the final dotted TP2 line.
**Why This Works**
By strictly waiting for a full candle close *after* both sides of the range have been swept, you avoid the "chop zone." This script is designed to protect mental capital, enforce rigid risk management, and shift your mindset from predicting the market to reacting mechanically to high-probability setups.





Here is a dedicated section you can add directly to your TradingView description. It breaks down exactly how to interpret the Volume Delta numbers so traders know how to spot the difference between genuine momentum and a trap.

You can paste this right below the **"Core Features & Mechanics"** section of your description:
### How to Read the CVD (Volume Delta) Parameters
The script calculates the intrabar Volume Delta (Net Buying Volume minus Net Selling Volume) of the exact candle that triggers the Displacement breakout. Because volume totals differ across assets (e.g., MNQ vs. ES vs. Crypto) and timeframes, you are looking for **polarity (positive/negative)** and **relative magnitude**, rather than a specific fixed number.
Here is how to use the Vol Delta readout to filter your trades:
**1. The True Breakout (Alignment)**
A valid breakout occurs when the price direction and the volume delta agree. This shows aggressive market participation pushing through the boundary.
 * **True Bullish Breakout (BUY):** The script prints a ▲ BUY arrow, and the Vol Delta is a **large positive number**. This confirms aggressive buyers are lifting the offer to displace price upward.
 * **True Bearish Breakout (SELL):** The script prints a ▼ SELL arrow, and the Vol Delta is a **large negative number**. This confirms aggressive sellers are hitting the bid to force price lower.
**2. The False Breakout (Divergence / The Trap)**
A false breakout (or trap) occurs when the price closes outside the range, but the volume delta contradicts the move. This indicates heavy absorption by the opposing side.
 * **Bullish Trap (Fake BUY):** The script prints a ▲ BUY arrow, but the Vol Delta is **negative** or unusually low. This means that even though the candle closed higher, sellers were aggressively dumping into the move, absorbing the buying pressure. *Do not go long.*
 * **Bearish Trap (Fake SELL):** The script prints a ▼ SELL arrow, but the Vol Delta is **positive** or unusually low. This means that as the price dropped below the range, buyers were waiting with limit orders, absorbing the sell-off. *Do not go short.*
**Pro-Tip for Prop Traders:** If you see a Displacement arrow fire but the Volume Delta shows a divergence (a trap), this is often a signal that the price is about to aggressively reverse back into the 15-minute range to seek liquidity on the opposite side.
*** This addition makes the volume feature highly actionable. It tells traders exactly what to look for on that label before they risk their capital on the breakout.

## Source Code

````pine
//@version=5
indicator("15m Range SOP: The Complete Playbook", overlay=true, max_boxes_count=50, max_lines_count=50, max_labels_count=500)

// --- INPUTS ---
grp1 = "Range Settings"
sessionTime = input.session("0930-0945", title="Reference 15m Candle Time", group=grp1)
tz = input.string("America/New_York", title="Timezone", group=grp1)
extendMult = input.int(15, title="Box Extension (15m Candles)", group=grp1)

grp2 = "Targets & Volume"
liqLookback = input.int(100, title="Liquidity Pool Lookback (Bars)", group=grp2, tooltip="Bars to look back to find structural Take Profit targets.")

// --- VARIABLES ---
var float rHigh = na
var float rLow = na
var int startTime = na
var int endTime = na
var int extensionTime = na
var bool boxActive = false

var bool bullFired = false
var bool bearFired = false
var bool hasTopSweep = false
var bool hasBottomSweep = false

// Take Profit Tracking Variables
var float previousSwingHigh = na
var float previousSwingLow = na
var float longMidpoint = na
var float shortMidpoint = na

var bool tp1BullFired = false
var bool tp2BullFired = false
var bool tp1BearFired = false
var bool tp2BearFired = false

// Calculate pre-range structural highs/lows
highestHigh = ta.highest(high, liqLookback)
lowestLow = ta.lowest(low, liqLookback)

// --- CVD APPROXIMATION ---
volFrac = high == low ? 0.5 : (close - low) / (high - low)
upVol = volume * volFrac
dnVol = volume * (1 - volFrac)
barDelta = upVol - dnVol

// --- LOGIC: ESTABLISH THE RANGE ---
inSession = not na(time(timeframe.period, sessionTime, tz))

if inSession
    if not inSession[1]
        // Reset all variables for the new session
        rHigh := high
        rLow := low
        startTime := time
        boxActive := false
        bullFired := false
        bearFired := false
        hasTopSweep := false    
        hasBottomSweep := false 
        
        tp1BullFired := false
        tp2BullFired := false
        tp1BearFired := false
        tp2BearFired := false
        
        previousSwingHigh := highestHigh[1]
        previousSwingLow := lowestLow[1]
    else
        rHigh := math.max(rHigh, high)
        rLow := math.min(rLow, low)
    endTime := time

// --- DRAWING THE SETUP & TARGETS ---
if not inSession and inSession[1]
    rMid = (rHigh + rLow) / 2
    extensionTime := endTime + (extendMult * 15 * 60 * 1000)
    
    // Draw the 15m Range Box
    box.new(left=startTime, top=rHigh, right=extensionTime, bottom=rLow, xloc=xloc.bar_time, 
         border_color=color.rgb(14, 165, 233), border_width=2, 
         bgcolor=color.new(color.blue, 95), text="15m Active Range", 
         text_halign=text.align_right, text_valign=text.align_bottom, text_size=size.small, text_color=color.gray)
    
    // Draw Equilibrium (Midline)
    line.new(x1=startTime, y1=rMid, x2=extensionTime, y2=rMid, xloc=xloc.bar_time, 
         color=color.rgb(14, 165, 233), style=line.style_dashed, width=2)
         
    // Calculate and Draw Long Targets (Only if BSL is above the range)
    if previousSwingHigh > rHigh
        longMidpoint := rHigh + ((previousSwingHigh - rHigh) / 2)
        
        // Final BSL Target
        line.new(x1=startTime, y1=previousSwingHigh, x2=extensionTime, y2=previousSwingHigh, xloc=xloc.bar_time, color=color.rgb(34, 197, 94), style=line.style_dotted, width=2)
        label.new(extensionTime, previousSwingHigh, text="Final Target (BSL)", color=color.new(color.green, 100), textcolor=color.green, style=label.style_label_left, size=size.small, xloc=xloc.bar_time)
        
        // Midpoint Scale-Out Target
        line.new(x1=startTime, y1=longMidpoint, x2=extensionTime, y2=longMidpoint, xloc=xloc.bar_time, color=color.rgb(59, 130, 246), style=line.style_dashed, width=1)
        label.new(extensionTime, longMidpoint, text="Scale Out (80%) / +10 Stop", color=color.new(color.blue, 100), textcolor=color.blue, style=label.style_label_left, size=size.small, xloc=xloc.bar_time)

    // Calculate and Draw Short Targets (Only if SSL is below the range)
    if previousSwingLow < rLow
        shortMidpoint := rLow - ((rLow - previousSwingLow) / 2)
        
        // Final SSL Target
        line.new(x1=startTime, y1=previousSwingLow, x2=extensionTime, y2=previousSwingLow, xloc=xloc.bar_time, color=color.rgb(239, 68, 68), style=line.style_dotted, width=2)
        label.new(extensionTime, previousSwingLow, text="Final Target (SSL)", color=color.new(color.red, 100), textcolor=color.red, style=label.style_label_left, size=size.small, xloc=xloc.bar_time)
        
        // Midpoint Scale-Out Target
        line.new(x1=startTime, y1=shortMidpoint, x2=extensionTime, y2=shortMidpoint, xloc=xloc.bar_time, color=color.rgb(59, 130, 246), style=line.style_dashed, width=1)
        label.new(extensionTime, shortMidpoint, text="Scale Out (80%) / +10 Stop", color=color.new(color.blue, 100), textcolor=color.blue, style=label.style_label_left, size=size.small, xloc=xloc.bar_time)
         
    boxActive := true

// --- SWEEP & DISPLACEMENT LOGIC ---
isActiveWindow = boxActive and not inSession and time <= extensionTime

topSweep = isActiveWindow and high > rHigh and close <= rHigh
bottomSweep = isActiveWindow and low < rLow and close >= rLow

if topSweep
    hasTopSweep := true
if bottomSweep
    hasBottomSweep := true

doubleSweepComplete = hasTopSweep and hasBottomSweep

bullDisplacement = isActiveWindow and close > rHigh and doubleSweepComplete
bearDisplacement = isActiveWindow and close < rLow and doubleSweepComplete

// --- PLOTTING VISUALS & ALERTS ---

// 1. Sweeps
if topSweep
    label.new(bar_index, high + (syminfo.mintick * 20), text="✖ Sweep", color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
if bottomSweep
    label.new(bar_index, low - (syminfo.mintick * 20), text="✖ Sweep", color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_up, size=size.small)

// 2. Displacements (Entry Triggers)
if bullDisplacement and not bullFired
    deltaStr = str.tostring(math.round(barDelta))
    label.new(bar_index, low - (syminfo.mintick * 40), text="▲ BUY\nVol Delta: " + deltaStr, color=color.green, textcolor=color.white, style=label.style_label_up, size=size.normal)
    bullFired := true

if bearDisplacement and not bearFired
    deltaStr = str.tostring(math.round(barDelta))
    label.new(bar_index, high + (syminfo.mintick * 40), text="▼ SELL\nVol Delta: " + deltaStr, color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)
    bearFired := true

// 3. Take Profit Triggers (Only active after a valid displacement)
if bullFired
    if not tp1BullFired and high >= longMidpoint
        label.new(bar_index, high + (syminfo.mintick * 20), text="☑ TP1: Scale 80%", color=color.blue, textcolor=color.white, style=label.style_label_down, size=size.small)
        tp1BullFired := true
        
    if not tp2BullFired and high >= previousSwingHigh
        label.new(bar_index, high + (syminfo.mintick * 40), text="★ FINAL TP HIT", color=color.rgb(202, 138, 4), textcolor=color.white, style=label.style_label_down, size=size.normal)
        tp2BullFired := true

if bearFired
    if not tp1BearFired and low <= shortMidpoint
        label.new(bar_index, low - (syminfo.mintick * 20), text="☑ TP1: Scale 80%", color=color.blue, textcolor=color.white, style=label.style_label_up, size=size.small)
        tp1BearFired := true
        
    if not tp2BearFired and low <= previousSwingLow
        label.new(bar_index, low - (syminfo.mintick * 40), text="★ FINAL TP HIT", color=color.rgb(202, 138, 4), textcolor=color.white, style=label.style_label_up, size=size.normal)
        tp2BearFired := true
````
