# iFVG 3Bar Signals [LuxAlgo] - Modified by FullPotato

- url: https://www.tradingview.com/script/H1ONGuPa-iFVG-3Bar-Signals-LuxAlgo-Modified-by-FullPotato/
- type: indicator
- pine_id: PUB;af7804616b42481d86c9a7dccf943abb
- version: 1.0

## Description

Overview
The FVG Instantaneous Mitigation Signals with LVN is an advanced TradingView indicator that combines the powerful Fair Value Gap (FVG) mitigation detection methodology from LuxAlgo with an integrated Low Volume Node (LVN) filtering system and volume confirmation. This sophisticated tool identifies high-probability reversal signals when price returns to fill previously created FVGs while respecting critical LVN zones and volume conditions. The script extends the original LuxAlgo FVG Instantaneous Mitigation Signals indicator with enhanced filtering capabilities and expanded LVN integration (up to 16 customizable zones).

Core Concept
The indicator operates on the principle that Fair Value Gaps (imbalances created by aggressive price movements) act as magnetic zones that price tends to revisit and "mitigate" (fill). When price returns to these zones, the instantaneous mitigation creates a reaction that can signal potential reversals. By combining this FVG concept with LVN validation and volume confirmation, the indicator identifies higher-quality entry points where multiple confluence factors align.

Key Features
1. FVG Mitigation Detection
Bullish Mitigation: Identifies when price fills a bearish FVG (gap created by selling pressure)

Condition: low[3] > high[1] (bearish gap) then close > low[3] (mitigation)

Additional filtering: close[2] < low[3] ensures the gap remained unfilled for one bar

Bearish Mitigation: Identifies when price fills a bullish FVG (gap created by buying pressure)

Condition: low[1] > high[3] (bullish gap) then close < high[3] (mitigation)

Additional filtering: close[2] > high[3] ensures the gap remained unfilled for one bar

2. Low Volume Node (LVN) Validation (Expanded to 16 Zones)
Manually define up to 16 LVN zones (areas of low trading volume acting as key support/resistance)

Signal validation: Unlike the Candle Sweep indicator, this version only requires the signal candle to touch the LVN zone (no 50% close requirement)

LVN zones are visually displayed as semi-transparent gray boxes on the chart

Each LVN zone can be independently defined with high/low prices

Provides additional confluence for FVG mitigation signals

3. Volume Confirmation
Volume Multiplier Filter: Signal candle volume must be ≥ prior candle volume × multiplier

Default multiplier: 1.0 (equal volume)

Adjustable from 0.0 to infinity in 0.05 increments

Example: 1.1 = requires 10% more volume than previous candle

Helps confirm genuine market participation and reduces false signals

4. FVG Width Filter
Filters out FVGs that are too narrow to be significant

Calculated as: FVG width > ATR × filterWidth

Default: 0 (no filtering)

Adjustable in 0.1 increments

Helps focus on more significant imbalances

5. Visual Signal Representation
Signal Arrows: Yellow triangles with lightning bolt (⚡) markers

Bullish: Below the candle (▲⚡)

Bearish: Above the candle (▼⚡)

FVG Zones: Semi-transparent boxes showing the imbalance area

Average Lines: Optional dashed lines at the midpoint of the FVG zone

Real-time extension: Lines extend to current bar until mitigated

6. Take Profit / Stop Loss Management
Take Profit Zones: Automatically calculated based on ATR × multiplier (default 4×)

Stop Loss Zones: Automatically calculated based on ATR × multiplier (default 2×)

Visual tracking: Zones extend to the right until price reaches them

Completion detection: Automatically marks when TP/SL levels are hit

Fully customizable colors and multipliers

7. Smart Alert System
NEW SIGNAL ONLY: Alerts trigger only on new signal formation, not on every bar

Prevents alert spam while maintaining awareness

Separate alert conditions for bullish/bearish signals

Customizable alert messages

Technical Parameters
FVG Settings
FVG Width Filter (0+ in 0.1 increments): Minimum FVG width relative to ATR

Volume Multiplier (0+ in 0.05 increments): Volume requirement for signal confirmation

LVN Settings (16 LVN Zones)
Individual high/low price inputs for each zone

Enable LVN Filter: Toggle LVN validation on/off

Show LVN Boxes: Toggle visual display of LVN zones

Simple touch validation (no 50% close requirement)

TP/SL Settings
TP Area: Enable/disable take profit zone visualization

SL Area: Enable/disable stop loss zone visualization

TP Multiplier: ATR multiplier for TP level (default 4×)

SL Multiplier: ATR multiplier for SL level (default 2×)

Customizable colors for both zones

Style Settings
Bullish Signals

Toggle display

Customizable color

Toggle average line display

Bearish Signals

Toggle display

Customizable color

Toggle average line display

Signal Logic Breakdown
Bullish Signal (Long)
FVG exists: low[3] > high[1] (bearish gap)

Gap remains unfilled: close[2] < low[3]

Price mitigates gap: close > low[3]

FVG width is significant (filter)

LVN validation (if enabled): Candle touches any defined LVN zone

Volume confirmation: Current volume ≥ prior volume × multiplier

All conditions met → LONG signal with yellow lightning bolt

Bearish Signal (Short)
FVG exists: low[1] > high[3] (bullish gap)

Gap remains unfilled: close[2] > high[3]

Price mitigates gap: close < high[3]

FVG width is significant (filter)

LVN validation (if enabled): Candle touches any defined LVN zone

Volume confirmation: Current volume ≥ prior volume × multiplier

All conditions met → SHORT signal with yellow lightning bolt

Trading Strategy Application
Ideal Use Cases
Reversal Trading: Captures reactions at key FVG levels with LVN confluence

Mean Reversion: Identifies when price returns to fill imbalances

Breakout Retests: Validates breakouts through volume and LVN confirmation

Scalping and Day Trading: Instantaneous signals work well on lower timeframes

Best Practices
Use on 5min to 1H timeframes for optimal signals

Combine with market structure analysis

Adjust volume multiplier based on average volume patterns (higher during active sessions)

Use FVG width filter to eliminate insignificant gaps

Set LVN zones at key support/resistance levels from volume profile analysis

Advanced Usage Tips
Bullish Signal + Upward Trend: Strongest confluence

Bearish Signal + Downward Trend: Strongest confluence

Multiple LVN Zones: The more LVN zones the candle touches, the stronger the signal

Volume Spikes: Significant volume spikes increase signal reliability

Wider FVGs: Larger gaps (relative to ATR) tend to produce stronger reactions

Customization Flexibility
The indicator offers extensive customization options:

Feature	Customization Options
FVG Detection	Width filter, visual style
Volume Validation	Multiplier adjustment
LVN Integration	16 zones, toggle validation, visual display
TP/SL Management	Enable/disable, multiplier adjustment, colors
Visual Style	Colors, average lines, marker style
Alerts	New signal detection with custom messages

LVN zones require manual definition (not automatically detected)

FVG detection only works on specified gap patterns (3-bar lookback)

TP/SL levels are based on ATR (may not suit all market conditions)

Volume multiplier may need adjustment across different trading sessions

Best used as confluence tool rather than standalone signal system

License & Attribution
This indicator builds upon the original FVG Instantaneous Mitigation Signals by LuxAlgo and extends it with LVN integration, volume filtering, and expanded configuration options. The original work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0).

This indicator is ideal for traders who combine Fair Value Gap analysis with volume profile concepts, seeking high-quality reversal signals at key price levels where multiple confluence factors align.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("FVG Instantaneous Mitigation Signals [LuxAlgo] with LVN", "LuxAlgo - FVG Instantaneous Mitigation Signals with LVN", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
//Settings
//---------------------------------------------------------------------------------------------------------------------{
filterWidth = input.float(0., 'FVG Width Filter', minval = 0, step = .1)

// Volume Settings
volumeMultiplier = input.float(1.0, "Volume Multiplier", minval = 0.0, step = 0.05, tooltip = "Signal candle volume must be >= prior candle volume * multiplier. Example: 1.1 = 10% more volume")

// LVN Inputs (16 LVN levels = 32 high+low)
enableLVNFilter = input.bool(true, "Enable LVN Filter", group = "LVN Settings")
lvn1High = input.float(0.0, "LVN 1 High", group = "LVN Settings")
lvn1Low  = input.float(0.0, "LVN 1 Low", group = "LVN Settings")
lvn2High = input.float(0.0, "LVN 2 High", group = "LVN Settings")
lvn2Low  = input.float(0.0, "LVN 2 Low", group = "LVN Settings")
lvn3High = input.float(0.0, "LVN 3 High", group = "LVN Settings")
lvn3Low  = input.float(0.0, "LVN 3 Low", group = "LVN Settings")
lvn4High = input.float(0.0, "LVN 4 High", group = "LVN Settings")
lvn4Low  = input.float(0.0, "LVN 4 Low", group = "LVN Settings")
lvn5High = input.float(0.0, "LVN 5 High", group = "LVN Settings")
lvn5Low  = input.float(0.0, "LVN 5 Low", group = "LVN Settings")
lvn6High = input.float(0.0, "LVN 6 High", group = "LVN Settings")
lvn6Low  = input.float(0.0, "LVN 6 Low", group = "LVN Settings")
lvn7High = input.float(0.0, "LVN 7 High", group = "LVN Settings")
lvn7Low  = input.float(0.0, "LVN 7 Low", group = "LVN Settings")
lvn8High = input.float(0.0, "LVN 8 High", group = "LVN Settings")
lvn8Low  = input.float(0.0, "LVN 8 Low", group = "LVN Settings")
lvn9High = input.float(0.0, "LVN 9 High", group = "LVN Settings")
lvn9Low  = input.float(0.0, "LVN 9 Low", group = "LVN Settings")
lvn10High = input.float(0.0, "LVN 10 High", group = "LVN Settings")
lvn10Low  = input.float(0.0, "LVN 10 Low", group = "LVN Settings")
lvn11High = input.float(0.0, "LVN 11 High", group = "LVN Settings")
lvn11Low  = input.float(0.0, "LVN 11 Low", group = "LVN Settings")
lvn12High = input.float(0.0, "LVN 12 High", group = "LVN Settings")
lvn12Low  = input.float(0.0, "LVN 12 Low", group = "LVN Settings")
lvn13High = input.float(0.0, "LVN 13 High", group = "LVN Settings")
lvn13Low  = input.float(0.0, "LVN 13 Low", group = "LVN Settings")
lvn14High = input.float(0.0, "LVN 14 High", group = "LVN Settings")
lvn14Low  = input.float(0.0, "LVN 14 Low", group = "LVN Settings")
lvn15High = input.float(0.0, "LVN 15 High", group = "LVN Settings")
lvn15Low  = input.float(0.0, "LVN 15 Low", group = "LVN Settings")
lvn16High = input.float(0.0, "LVN 16 High", group = "LVN Settings")
lvn16Low  = input.float(0.0, "LVN 16 Low", group = "LVN Settings")
showLVNBoxes = input.bool(true, "Show LVN Boxes on Chart", group = "LVN Settings")

//TP/SL
showTp = input.bool(false, 'TP Area', inline = 'tp', group = 'TP/SL')
tpMult = input.float(4., 'Multiplier', minval = 0, inline = 'tp', group = 'TP/SL')
tpCss = input.color(color.new(#5b9cf6, 80), '', inline = 'tp', group = 'TP/SL')

showSl = input.bool(false, 'SL Area', inline = 'sl', group = 'TP/SL')
slMult = input.float(2., 'Multiplier', minval = 0, inline = 'sl', group = 'TP/SL')
slCss = input.color(color.new(color.gray, 80), '', inline = 'sl', group = 'TP/SL')

//Style
showBull = input.bool(true, 'Bullish IMFVG', inline = 'bull', group = 'Style')
bullCss = input.color(color.teal, '', inline = 'bull', group = 'Style')
bullAvg = input.bool(true, 'Average', inline = 'bull', group = 'Style')

showBear = input.bool(true, 'Bearish IMFVG', inline = 'bear', group = 'Style')
bearCss = input.color(#f23645, '', inline = 'bear', group = 'Style')
bearAvg = input.bool(true, 'Average', inline = 'bear', group = 'Style')

//---------------------------------------------------------------------------------------------------------------------}
//Functions
//---------------------------------------------------------------------------------------------------------------------{
n = bar_index
atr = ta.atr(200)

// LVN Functions - ONLY checks if candle TOUCHES the LVN (no 50% close requirement)
f_is_touching_lvn(float highPrice, float lowPrice, float lvnHigh, float lvnLow) =>
    (highPrice >= lvnLow and lowPrice <= lvnHigh)

f_check_lvn_validation(float candleHigh, float candleLow) =>
    bool isValid = false
    // Check all 16 LVN levels - ONLY require touching, no 50% close condition
    if lvn1High != 0 or lvn1Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn1High, lvn1Low)
            isValid := true
    if lvn2High != 0 or lvn2Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn2High, lvn2Low)
            isValid := true
    if lvn3High != 0 or lvn3Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn3High, lvn3Low)
            isValid := true
    if lvn4High != 0 or lvn4Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn4High, lvn4Low)
            isValid := true
    if lvn5High != 0 or lvn5Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn5High, lvn5Low)
            isValid := true
    if lvn6High != 0 or lvn6Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn6High, lvn6Low)
            isValid := true
    if lvn7High != 0 or lvn7Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn7High, lvn7Low)
            isValid := true
    if lvn8High != 0 or lvn8Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn8High, lvn8Low)
            isValid := true
    if lvn9High != 0 or lvn9Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn9High, lvn9Low)
            isValid := true
    if lvn10High != 0 or lvn10Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn10High, lvn10Low)
            isValid := true
    if lvn11High != 0 or lvn11Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn11High, lvn11Low)
            isValid := true
    if lvn12High != 0 or lvn12Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn12High, lvn12Low)
            isValid := true
    if lvn13High != 0 or lvn13Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn13High, lvn13Low)
            isValid := true
    if lvn14High != 0 or lvn14Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn14High, lvn14Low)
            isValid := true
    if lvn15High != 0 or lvn15Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn15High, lvn15Low)
            isValid := true
    if lvn16High != 0 or lvn16Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn16High, lvn16Low)
            isValid := true
    isValid

tpsl(condition, opposite_condition, level, islong)=>
    var box tp_area = na
    var box sl_area = na
    var bool reached = false

    if condition
        if islong
            if showTp
                tp_area := box.new(n, level + atr * tpMult, n, level, na, bgcolor = tpCss)
            if showSl
                sl_area := box.new(n, level, n, level - atr * slMult, na, bgcolor = slCss)
        else
            if showTp
                tp_area := box.new(n, level, n, level - atr * tpMult, na, bgcolor = tpCss)
            if showSl
                sl_area := box.new(n, level + atr * slMult, n, level, na, bgcolor = slCss)

        reached := false

    else if opposite_condition
        reached := true

    if not reached
        tp_area.set_right(n)
        sl_area.set_right(n)

        if islong
            if high > tp_area.get_top() or low < sl_area.get_bottom()
                reached := true
        else
            if low < tp_area.get_bottom() or high > sl_area.get_top()
                reached := true
    
    reached

filter(a, b)=> a - b > atr * filterWidth

//---------------------------------------------------------------------------------------------------------------------}
//Signals
//---------------------------------------------------------------------------------------------------------------------{
var line bull_line = na
var bool bull_lvl_reached = false
var line bear_line = na
var bool bear_lvl_reached = false

// Volume condition: signal candle volume >= prior candle volume * multiplier
volCondition = volume >= (volume[1] * volumeMultiplier)

//Bullish Signals - current candle (index 0) is the signal candle with the arrow
bull = low[3] > high[1] and close[2] < low[3] and close > low[3] and filter(low[3], high[1]) and showBull and (enableLVNFilter ? f_check_lvn_validation(high[1], low[1]) : true) and volCondition

//Bearish Signals - current candle (index 0) is the signal candle with the arrow
bear = low[1] > high[3] and close[2] > high[3] and close < high[3] and filter(low[1], high[3]) and showBear and (enableLVNFilter ? f_check_lvn_validation(high[1], low[1]) : true) and volCondition

//Set bullish tpsl zones
if bull
    //Imbalance area
    box.new(n-3, low[3], n, high[1], na, bgcolor = color.new(bullCss, 50))
    avg = math.avg(low[3], high[1])

    //Imbalance area average
    if bullAvg
        bull_line := line.new(n, avg, n, avg, color = bullCss, style = line.style_dashed)

    //Long Signal - Below the bar (keeping the same style)
    label.new(n, low - (atr * 0.2), '▲', color = color(na), textcolor = color.yellow, style = label.style_label_up, size = size.small)

    bull_lvl_reached := false

//Set bearish tpsl zones
if bear
    //Imbalance area
    box.new(n-3, low[1], n, high[3], na, bgcolor = color.new(bearCss, 50))
    avg = math.avg(low[1], high[3])
    
    //Imbalance area average
    if bearAvg
        bear_line := line.new(n, avg, n, avg, color = bearCss, style = line.style_dashed)

    //Short Signal - Above the bar (keeping the same style)
    label.new(n, high + (atr * 0.2), '▼', color = color(na), textcolor = color.yellow, style = label.style_label_down, size = size.small)

    bear_lvl_reached := false

//Extend average imabalance areas
if not bull_lvl_reached
    bull_line.set_x2(n)
if not bear_lvl_reached
    bear_line.set_x2(n)

//Test if reached
if close < bull_line.get_y2()
    bull_lvl_reached := true

if close > bear_line.get_y2()
    bear_lvl_reached := true

bull_reached = tpsl(bull, bear, math.avg(low[3], high[1]), true)
bear_reached = tpsl(bear, bull, math.avg(low[1], high[3]), false)

//---------------------------------------------------------------------------------------------------------------------}
//Plots
//---------------------------------------------------------------------------------------------------------------------{

// Draw LVN Boxes (from Candle Sweep script)
if showLVNBoxes
    if lvn1High != 0 or lvn1Low != 0
        box.new(left=bar_index-50, top=lvn1High, right=bar_index, bottom=lvn1Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn2High != 0 or lvn2Low != 0
        box.new(left=bar_index-50, top=lvn2High, right=bar_index, bottom=lvn2Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn3High != 0 or lvn3Low != 0
        box.new(left=bar_index-50, top=lvn3High, right=bar_index, bottom=lvn3Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn4High != 0 or lvn4Low != 0
        box.new(left=bar_index-50, top=lvn4High, right=bar_index, bottom=lvn4Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn5High != 0 or lvn5Low != 0
        box.new(left=bar_index-50, top=lvn5High, right=bar_index, bottom=lvn5Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn6High != 0 or lvn6Low != 0
        box.new(left=bar_index-50, top=lvn6High, right=bar_index, bottom=lvn6Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn7High != 0 or lvn7Low != 0
        box.new(left=bar_index-50, top=lvn7High, right=bar_index, bottom=lvn7Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn8High != 0 or lvn8Low != 0
        box.new(left=bar_index-50, top=lvn8High, right=bar_index, bottom=lvn8Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn9High != 0 or lvn9Low != 0
        box.new(left=bar_index-50, top=lvn9High, right=bar_index, bottom=lvn9Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn10High != 0 or lvn10Low != 0
        box.new(left=bar_index-50, top=lvn10High, right=bar_index, bottom=lvn10Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn11High != 0 or lvn11Low != 0
        box.new(left=bar_index-50, top=lvn11High, right=bar_index, bottom=lvn11Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn12High != 0 or lvn12Low != 0
        box.new(left=bar_index-50, top=lvn12High, right=bar_index, bottom=lvn12Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn13High != 0 or lvn13Low != 0
        box.new(left=bar_index-50, top=lvn13High, right=bar_index, bottom=lvn13Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn14High != 0 or lvn14Low != 0
        box.new(left=bar_index-50, top=lvn14High, right=bar_index, bottom=lvn14Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn15High != 0 or lvn15Low != 0
        box.new(left=bar_index-50, top=lvn15High, right=bar_index, bottom=lvn15Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn16High != 0 or lvn16Low != 0
        box.new(left=bar_index-50, top=lvn16High, right=bar_index, bottom=lvn16Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))

//---------------------------------------------------------------------------------------------------------------------}
// ALERT - Triggers only on NEW Bullish or Bearish IMFVG signals
//---------------------------------------------------------------------------------------------------------------------{
// Track previous signal state to detect NEW signals only
var bool prev_bull = false
var bool prev_bear = false

// Detect if signal is NEW (just triggered on this bar)
new_bull = bull and not prev_bull
new_bear = bear and not prev_bear

// Update previous states for next bar
if barstate.isconfirmed
    prev_bull := bull
    prev_bear := bear

// Combined new signal - triggers only ONCE when a new signal appears
imfvg_signal = new_bull or new_bear

// Alert condition - triggers only on new signals
alertcondition(imfvg_signal, title="IMFVG Signal with LVN", message="IMFVG Signal Detected with LVN!")

// Separate signals with original style (yellow triangles with lightning bolt)
// Long signal - below bar
plotshape(new_bull, title="Long Signal", location=location.belowbar, color=color.yellow, style=shape.labelup, text="⚡", size=size.small)

// Short signal - above bar
plotshape(new_bear, title="Short Signal", location=location.abovebar, color=color.yellow, style=shape.labeldown, text="⚡", size=size.small)
````
