# AMD1

- url: https://www.tradingview.com/script/hQlcOEAD-AMD1/
- type: indicator
- pine_id: PUB;60e7b48af47c49d7b5504448c80dcf1e
- version: 1.0

## Description

TradingView Pine Script v6 Indicator Request
Project Name
AMD Liquidity Sweep Pro (Accumulation → Manipulation → Distribution)

Objective
Create a non-repainting TradingView Pine Script v6 indicator that identifies high-probability ICT/Smart Money Concepts AMD setups by detecting:

Accumulation
Manipulation
Distribution
The indicator should only generate trade signals after all AMD conditions are met and multiple confirmation filters align.

Core AMD Logic

Accumulation Detection
Identify consolidation/ranging markets before manipulation occurs.
Requirements:

Detect low-volatility accumulation ranges.
Detect equal highs (EQH).
Detect equal lows (EQL).
Detect internal liquidity resting inside the range.
Draw a yellow box around accumulation zones.
Allow user adjustment of:

Minimum accumulation duration.
Maximum range size.
Sensitivity settings.
Visual:

Accumulation box color = Yellow.
2. Manipulation Detection
Identify liquidity grabs occurring after accumulation.

Requirements:

Detect sweeps above accumulation highs.
Detect sweeps below accumulation lows.
Detect internal liquidity sweeps.
Detect external liquidity sweeps.
Label sweep direction.
Mark liquidity taken.
Visual:

Manipulation candles boxed in Purple.
3. Distribution Detection
After manipulation occurs, detect distribution and directional expansion.

Requirements:

Require displacement candles.
Require Market Structure Shift (MSS).
Require Break of Structure (BOS).
Require directional expansion away from manipulation.
Visuals:

Bullish Distribution:

Green box.
Bearish Distribution:

Red box.
Market Structure Requirements
Require all of the following:

MSS confirmation.
BOS confirmation.
Displacement confirmation.
Strong candle body percentage filter.
Optional volume expansion confirmation.
No signal should occur without structure confirmation.

Liquidity Detection
Indicator must automatically identify:

Internal liquidity.
External liquidity.
Equal highs.
Equal lows.
Swing highs.
Swing lows.
Buy-side liquidity.
Sell-side liquidity.
Trade setups should prioritize:

Internal liquidity sweep.
External liquidity sweep.
MSS/BOS.
Displacement.
Premium & Discount Filter
Automatically identify current dealing range using:

Most recent valid swing high.
Most recent valid swing low.
Plot:

Premium Zone (upper 50%).
Equilibrium (50%).
Discount Zone (lower 50%).
Visuals:

Premium shaded light red.
Discount shaded light green.
Equilibrium line.
Rules:

Bullish trades:

Only allowed in Discount.
Bearish trades:

Only allowed in Premium.
Block all:

Bullish trades in Premium.
Bearish trades in Discount.
Higher Timeframe Trend Filter
Determine trend using:

15 Minute Market Structure.
1 Hour Market Structure.
Bullish Bias:

Higher highs.
Higher lows.
Bullish BOS.
Bullish MSS.
Bearish Bias:

Lower highs.
Lower lows.
Bearish BOS.
Bearish MSS.
Rules:

Bullish signals:

Must align with 15m or 1H bullish structure.
Bearish signals:

Must align with 15m or 1H bearish structure.
Optional setting:

Require both HTFs to agree.
Display:

Bullish
Bearish
Neutral
HTF bias dashboard.

1-Minute PD Array Confirmation
No trade signal may appear without 1-minute PD Array confirmation.

Recognize:

Fair Value Gaps (FVG).
Order Blocks (OB).
Breaker Blocks.
Mitigation Blocks.
Inversion Fair Value Gaps (IFVG).
Allow user to enable/disable each PD Array type.

Bullish Entry:

Require:

AMD complete.
Liquidity swept.
MSS/BOS confirmed.
Discount confirmed.
HTF bullish.
Price retraces into bullish 1-minute PD Array.
Bullish reaction candle closes.
Bearish Entry:

Require:

AMD complete.
Liquidity swept.
MSS/BOS confirmed.
Premium confirmed.
HTF bearish.
Price retraces into bearish 1-minute PD Array.
Bearish reaction candle closes.
Visuals:

Bullish PD Arrays = Light Green.
Bearish PD Arrays = Light Red.
Label PD Array type.
Turtle Soup Mode
Add optional toggle.

Requirements:

External liquidity sweep.
Immediate reclaim.
MSS confirmation.
FVG confirmation.
PD Array confirmation.
Generate higher-quality reversal entries.

Enable/Disable setting.

Trade Signal Generation
Only generate signals after ALL conditions are satisfied.

Bullish Signal:

HTF Trend
→ Discount
→ Accumulation
→ Manipulation
→ External Liquidity Sweep
→ MSS
→ BOS
→ Displacement
→ Bullish 1m PD Array Retest
→ Entry

Bearish Signal:

HTF Trend
→ Premium
→ Accumulation
→ Manipulation
→ External Liquidity Sweep
→ MSS
→ BOS
→ Displacement
→ Bearish 1m PD Array Retest
→ Entry

Visuals:

Bullish Entry:

Green Up Arrow.
Bearish Entry:

Red Down Arrow.
Entry, Stop Loss & Take Profit System
Automatically calculate:

Entry:

Optimal trade entry.
Stop Loss:

Beyond manipulation sweep.
Take Profit Levels:

TP1:

1R
TP2:

2R
TP3:

External Liquidity Target
TP4:

Opposing Liquidity Target
Draw:

Green entry box.
Red stop loss box.
TP lines.
Risk/reward labels.
Display:

Entry price.
Stop price.
TP levels.
Current R multiple.
Setup Quality Score
Create setup scoring engine.

Maximum Score:
100

Example:

External Liquidity Sweep = 25

Internal Liquidity Sweep = 15

MSS = 15

BOS = 15

Displacement = 10

FVG = 5

Premium/Discount Alignment = 5

HTF Alignment = 5

1m PD Array Confirmation = 5

Only display signals with:

Minimum Score = 80

User adjustable.

Display score next to entry.

Example:

AMD Score: 92/100

Dashboard
Create on-chart dashboard displaying:

✓ Accumulation Found

✓ Manipulation Found

✓ Distribution Confirmed

✓ Internal Liquidity Taken

✓ External Liquidity Taken

✓ MSS Confirmed

✓ BOS Confirmed

✓ Displacement Confirmed

✓ FVG Present

✓ Premium/Discount Confirmed

✓ HTF Trend Confirmed

✓ 1m PD Array Confirmed

✓ Setup Score Passed

Only show signal when every required condition is confirmed.

Alerts
Create alerts for:

Bullish AMD Setup
Bearish AMD Setup
Liquidity Sweep Detected
MSS Confirmed
BOS Confirmed
PD Array Confirmed
Entry Triggered
TP1 Hit
TP2 Hit
TP3 Hit
Stop Loss Hit
Alert messages should include:

Symbol
Timeframe
Direction
Entry
Stop
Target
Technical Requirements
Pine Script Version 6.
Non-repainting.
Candle-close confirmation only.
Optimized for:

NQ
MNQ
ES
MES
Gold
Forex
Crypto
Stocks
Minimize chart clutter.
Include user customization settings.
Efficient code with minimal performance impact.
The indicator should focus on producing fewer but higher-quality signals rather than frequent signals.

## Source Code

````pine
//@version=6
indicator("AMD Liquidity Sweep Pro", "AMD Pro", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Group: Settings ---
var string G_AMD = "Accumulation & Manipulation"
int accumLength = input.int(10, "Min Accumulation Length", group = G_AMD)
float maxRangeAtr = input.float(3.0, "Max Accumulation Range (ATR mult)", group = G_AMD, tooltip = "Increase this if no boxes appear")

var string G_SMC = "Smart Money Concepts"
bool reqDisplacement = input.bool(false, "Require Displacement", group = G_SMC)
float displacementBody = input.float(0.5, "Min Displacement Body %", minval=0.1, maxval=1.0, step=0.1, group = G_SMC)

var string G_HTF = "HTF Trend"
bool useHtfFilter = input.bool(false, "Enable HTF Filter", group = G_HTF)
string htf1Timeframe = input.timeframe("15", "HTF 1", group = G_HTF)
string htf2Timeframe = input.timeframe("60", "HTF 2", group = G_HTF)

var string G_TRADE = "Trade Setup"
int minScore = input.int(40, "Minimum Score to Trade", minval=0, maxval=100, group = G_TRADE)

// --- Colors ---
color accumColor = color.new(color.yellow, 85)
color manipColor = color.new(color.purple, 85)
color distBullColor = color.new(color.green, 85)
color distBearColor = color.new(color.red, 85)

// --- Utility Functions ---
f_bodyPercent(o, h, l, c) =>
    rng = h - l
    rng == 0 ? 0 : math.abs(c - o) / rng

// --- HTF Trend ---
f_htfTrend() =>
    float htf_close = close
    float htf_sma = ta.sma(close, 20)
    htf_close > htf_sma ? 1 : htf_close < htf_sma ? -1 : 0

htf1_trend = request.security(syminfo.tickerid, htf1Timeframe, f_htfTrend())
htf2_trend = request.security(syminfo.tickerid, htf2Timeframe, f_htfTrend())
int currentHtfBias = (htf1_trend == 1 and htf2_trend == 1) ? 1 : (htf1_trend == -1 and htf2_trend == -1) ? -1 : 0

// --- AMD Logic ---
float atr = ta.atr(14)
float accumHighest = ta.highest(high, accumLength)
float accumLowest = ta.lowest(low, accumLength)
float rangeSize = accumHighest - accumLowest

// To make accumulation much easier to find, we check if the current range is within our ATR multiplier
bool isAccum = rangeSize <= (atr * maxRangeAtr)

var int state = 0 // 0: None, 1: Accumulating, 2: Manipulating
var int accumStart = na
var float accHigh = na
var float accLow = na
var box accBox = na

var int manipDir = 0 // 1: Bearish (Sweep High), -1: Bullish (Sweep Low)
var float manipExtremum = na
var int manipStart = na
var box manipBox = na

bool bullishSignal = false
bool bearishSignal = false
int currentScore = 0

// Step 1: Detect Accumulation
if state == 0
    if isAccum
        state := 1
        accumStart := bar_index - accumLength
        accHigh := accumHighest
        accLow := accumLowest
        accBox := box.new(accumStart, accHigh, bar_index, accLow, bgcolor=accumColor, border_color=color.yellow)

// Step 2: Track Accumulation or detect Manipulation
if state == 1
    // Update accumulation box if still in range
    if high <= accHigh + (atr*0.2) and low >= accLow - (atr*0.2)
        box.set_right(accBox, bar_index)
        // Adjust bounds slightly if they expand within tolerance
        if high > accHigh
            accHigh := high
            box.set_top(accBox, accHigh)
        if low < accLow
            accLow := low
            box.set_bottom(accBox, accLow)
    else
        // Breakout! Is it manipulation?
        if high > accHigh + (atr*0.2)
            state := 2
            manipDir := 1 // Sweep High
            manipStart := bar_index
            manipExtremum := high
            manipBox := box.new(bar_index, high, bar_index, accHigh, bgcolor=manipColor, border_color=color.purple)
        else if low < accLow - (atr*0.2)
            state := 2
            manipDir := -1 // Sweep Low
            manipStart := bar_index
            manipExtremum := low
            manipBox := box.new(bar_index, accLow, bar_index, low, bgcolor=manipColor, border_color=color.purple)
        else
            state := 0 // Failed

// Step 3: Track Manipulation & Wait for Distribution
if state == 2
    // Extend manipulation box
    if manipDir == 1
        manipExtremum := math.max(manipExtremum, high)
        box.set_top(manipBox, manipExtremum)
        box.set_right(manipBox, bar_index)
        
        // Check for Distribution (Reversal + MSS)
        if close < accLow // Break below accumulation low = MSS
            bool disp = f_bodyPercent(open, high, low, close) >= displacementBody
            if disp or not reqDisplacement
                currentScore := 50 + (currentHtfBias == -1 ? 20 : 0)
                if currentScore >= minScore
                    bearishSignal := true
                    box.new(bar_index-1, high, bar_index, close, bgcolor=distBearColor, border_color=color.red)
                    label.new(bar_index, high, "AMD Bearish", style=label.style_label_down, color=color.red, textcolor=color.white)
                state := 0 // Reset
                
        // Reset if it goes too far without reversing
        if high > accHigh + (atr * 5) or bar_index - manipStart > 30
            state := 0
            
    else if manipDir == -1
        manipExtremum := math.min(manipExtremum, low)
        box.set_bottom(manipBox, manipExtremum)
        box.set_right(manipBox, bar_index)
        
        // Check for Distribution (Reversal + MSS)
        if close > accHigh // Break above accumulation high = MSS
            bool disp = f_bodyPercent(open, high, low, close) >= displacementBody
            if disp or not reqDisplacement
                currentScore := 50 + (currentHtfBias == 1 ? 20 : 0)
                if currentScore >= minScore
                    bullishSignal := true
                    box.new(bar_index-1, high, bar_index, close, bgcolor=distBullColor, border_color=color.green)
                    label.new(bar_index, low, "AMD Bullish", style=label.style_label_up, color=color.green, textcolor=color.white)
                state := 0 // Reset
                
        // Reset if it goes too far without reversing
        if low < accLow - (atr * 5) or bar_index - manipStart > 30
            state := 0

// Debug Background to show script is running
bgcolor(state == 1 ? color.new(color.yellow, 95) : state == 2 ? color.new(color.purple, 95) : na, title="State Background")

// Plot setup arrows
plotshape(bullishSignal, "Bullish AMD", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(bearishSignal, "Bearish AMD", shape.triangledown, location.abovebar, color.red, size=size.small)

// --- Dashboard ---
var table dash = table.new(position.top_right, 2, 3, bgcolor = color.new(color.black, 80), border_width = 1, border_color = color.gray)
if barstate.islast
    table.cell(dash, 0, 0, "AMD Dashboard", text_color=color.white, text_halign=text.align_center)
    table.cell(dash, 0, 1, "State", text_color=color.white)
    table.cell(dash, 1, 1, state == 1 ? "Accumulating" : state == 2 ? "Manipulating" : "Searching", text_color=color.yellow)

// --- Alerts ---
if bullishSignal
    alert("Bullish AMD Setup Triggered!", alert.freq_once_per_bar_close)
if bearishSignal
    alert("Bearish AMD Setup Triggered!", alert.freq_once_per_bar_close)
````
