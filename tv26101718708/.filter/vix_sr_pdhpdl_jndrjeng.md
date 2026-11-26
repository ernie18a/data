# VIX SR + PDH/PDL

- url: https://www.tradingview.com/script/jnDrJENG-VIX-SR-PDH-PDL/
- type: indicator
- pine_id: PUB;d540645e10494aa38a770fc14aa407af
- version: 1.0

## Description

This script contains 6 lines. Two are for PDH and PDL. Other lines are probable support and resistance ( standard deviation-1 and standard deviation-2). 
There is 68 % probability that standard deviation-1 will hold and similarly there is 95 % probability that standard deviation-2 will hold. 

The script is valid only for Nifty. 

The standard deviation is calculated as follows-
Standard deviation-1 = Closing pricing of Nifty (daily TF) * Closing value of INDIAVIX * (1/100) * (1/16)

Standard deviation-2 = 2 * Standard deviation-1

## Source Code

````pine
//@version=6
indicator(title = 'VIX SR + PDH/PDL', shorttitle = 'VIX SR + PDH/PDL', overlay = true, max_bars_back = 2584)

// =================== INPUTS ===================
Main_Group = 'Mark the Checkbox to turn on Indicator'

Show_VIX_SR  = input.bool(true,  ' VIX Based SR Levels', group = Main_Group)
Show_HighLow = input.bool(true,  ' Previous Day High & Low', group = Main_Group)

VIXGroup    = 'VIX Based SR Levels'
useManual   = input.bool(false, 'Use Manual Values', group = VIXGroup)
manualNifty = input.float(24350, 'Manual Nifty', step = 10, group = VIXGroup)
manualVIX   = input.float(16.5, 'Manual VIX', step = 0.1, group = VIXGroup)
niftySymbol = input.symbol('NSE:NIFTY', 'Nifty Symbol', group = VIXGroup)
vixSymbol   = input.symbol('NSE:INDIAVIX', 'India VIX Symbol', group = VIXGroup)

// =================== TIME & SESSION LOGIC ===================
timeChange = ta.change(time("D"))
new_day    = not na(timeChange) and timeChange != 0

// =================== 1. PREVIOUS DAY HIGH / LOW ===================
pdh_source = request.security(syminfo.tickerid, "D", high, lookahead = barmerge.lookahead_off)
pdl_source = request.security(syminfo.tickerid, "D", low,  lookahead = barmerge.lookahead_off)

var float pdh_plot = na
var float pdl_plot = na

if new_day
    pdh_plot := pdh_source[1]
    pdl_plot := pdl_source[1]

// =================== 2. VIX S/R CALCULATIONS ===================
niftyCloseD_raw = request.security(niftySymbol, 'D', close, lookahead = barmerge.lookahead_off)
vixCloseD_raw   = request.security(vixSymbol,   'D', close, lookahead = barmerge.lookahead_off)

var float anchorNifty = na
var float anchorVIX   = na

if new_day
    anchorNifty := useManual ? manualNifty : niftyCloseD_raw[1]
    anchorVIX   := useManual ? manualVIX   : vixCloseD_raw[1]

// Math calculation based on daily values snapshotted at open
sd = (anchorVIX * anchorNifty * 0.01) / 16

// SD 1 Levels
var float vixRes = na
var float vixSup = na
// SD 2 Levels
var float vixRes2 = na
var float vixSup2 = na

if new_day
    // Assigning SD 1
    vixRes  := anchorNifty + sd
    vixSup  := anchorNifty - sd
    // Assigning SD 2
    vixRes2 := anchorNifty + (sd * 2)
    vixSup2 := anchorNifty - (sd * 2)

// =================== PLOTTING ===================
// VIX SD 1 Levels (Thicker Lines)
plot(Show_VIX_SR ? vixRes : na, title='VIX Resistance 1', color=color.new(#0E7A34, 0), linewidth=2)
plot(Show_VIX_SR ? vixSup : na, title='VIX Support 1',     color=color.new(#DC143C, 0), linewidth=2)

// VIX SD 2 Levels (Thinner Lines for Visual Hierarchy)
plot(Show_VIX_SR ? vixRes2 : na, title='VIX Resistance 2', color=color.new(#22C55E, 0), linewidth=2)
plot(Show_VIX_SR ? vixSup2 : na, title='VIX Support 2',     color=color.new(#EF4444, 0), linewidth=2)

// PDH / PDL Lines
plot(Show_HighLow ? pdh_plot : na, title='Prev Day High', color=color.black, linewidth=2)
plot(Show_HighLow ? pdl_plot : na, title='Prev Day Low',  color=color.black, linewidth=2)
````
