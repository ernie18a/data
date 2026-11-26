# [CP]6 EMA Multi Timeframe Inception

- url: https://www.tradingview.com/script/N0oXzXCg-CP-6-EMA-Multi-Timeframe-Inception/
- type: indicator
- pine_id: PUB;vV1FW7kxYp2nX2gWz0s5US94wuLc5sPM
- version: 1.0

## Description

A collection of 6 EMAs.
Each EMA can be attached to a different timeframe and have a different offset.

Great for building strategies that combine EMAs from different timeframes.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © pranjalchaubey

//@version=4
// 6 EMAs from different timeframes 
study(title="[CP]6 EMA Multi Timeframe Inception", shorttitle="[CP]6-EMA-Inception", overlay=true)

// Overall Visibility
group1 = input(title="Enable Group 1", type=input.bool, defval=true)
group2 = input(title="Enable Group 2", type=input.bool, defval=false)

// EMA 1  
//==============================================================================
// Visibility
vis1 = input(true, title="Enable 1st MA")
// Timeframe
res1 = input(title="EMA 1 Timeframe", type=input.resolution, defval="1")
// Period
len1 = input(7, minval=1, title="EMA 1 Length")
// Source
src1 = input(close, title="EMA 1 Source")
// Offsets and Band Adjustments
off1 = input(title="Offset 1st EMA", defval=0, minval=-500, maxval=500)
smooth1 = input(title="Smooth EMA 1", type=input.bool, defval=false)
// Calculations
ema1 = ema(src1, len1)
ema1_rough = security(syminfo.tickerid, res1, ema1, barmerge.gaps_off, barmerge.lookahead_off)
ema1_smooth = security(syminfo.tickerid, res1, ema1, barmerge.gaps_on, barmerge.lookahead_off)
// Plots
plot(vis1 and group1 ? smooth1 ? ema1_smooth: ema1_rough: na, title="EMA1", color=color.red, linewidth=1, offset=off1)

// EMA 2  
//==============================================================================
// Visibility
vis2 = input(true, title="Enable 2nd MA")
// Timeframe
res2 = input(title="EMA 2 Timeframe", type=input.resolution, defval="1")
// Period
len2 = input(20, minval=1, title="EMA 2 Length")
// Source
src2 = input(close, title="EMA 2 Source")
// Offsets and Band Adjustments
off2 = input(title="Offset 2nd EMA", defval=0, minval=-500, maxval=500)
smooth2 = input(title="Smooth EMA 2", type=input.bool, defval=false)
// Calculations
ema2 = ema(src2, len2)
ema2_rough = security(syminfo.tickerid, res2, ema2, barmerge.gaps_off, barmerge.lookahead_off)
ema2_smooth = security(syminfo.tickerid, res2, ema2, barmerge.gaps_on, barmerge.lookahead_off)
// Plots
plot(vis2 and group1 ? smooth2 ? ema2_smooth: ema2_rough: na, title="EMA2", color=color.green, linewidth=1, offset=off2)

// EMA 3  
//==============================================================================
// Visibility
vis3 = input(true, title="Enable 3rd MA")
// Timeframe
res3 = input(title="EMA 3 Timeframe", type=input.resolution, defval="1")
// Period
len3 = input(55, minval=1, title="EMA 3 Length")
// Source
src3 = input(close, title="EMA 3 Source")
// Offsets and Band Adjustments
off3 = input(title="Offset 3rd EMA", defval=0, minval=-500, maxval=500)
smooth3 = input(title="Smooth EMA 3", type=input.bool, defval=false)
// Calculations
ema3 = ema(src3, len3)
ema3_rough = security(syminfo.tickerid, res3, ema3, barmerge.gaps_off, barmerge.lookahead_off)
ema3_smooth = security(syminfo.tickerid, res3, ema3, barmerge.gaps_on, barmerge.lookahead_off)
// Plots
plot(vis3 and group1 ? smooth3 ? ema3_smooth: ema3_rough: na, title="EMA3", color=color.blue, linewidth=1, offset=off3)

// EMA 4  
//==============================================================================
// Visibility
vis4 = input(true, title="Enable 4th MA")
// Timeframe
res4 = input(title="EMA 4 Timeframe", type=input.resolution, defval="5")
// Period
len4 = input(7, minval=1, title="EMA 4 Length")
// Source
src4 = input(close, title="EMA 4 Source")
// Offsets and Band Adjustments
off4 = input(title="Offset 4th EMA", defval=0, minval=-500, maxval=500)
smooth4 = input(title="Smooth EMA 4", type=input.bool, defval=false)
// Calculations
ema4 = ema(src4, len4)
ema4_rough = security(syminfo.tickerid, res4, ema4, barmerge.gaps_off, barmerge.lookahead_off)
ema4_smooth = security(syminfo.tickerid, res4, ema4, barmerge.gaps_on, barmerge.lookahead_off)
// Plots
plot(vis4 and group2 ? smooth4 ? ema4_smooth: ema4_rough: na, title="EMA4", color=#dcedc1, linewidth=1, offset=off4)

// EMA 5  
//==============================================================================
// Visibility
vis5 = input(true, title="Enable 5th MA")
// Timeframe
res5 = input(title="EMA 5 Timeframe", type=input.resolution, defval="5")
// Period
len5 = input(20, minval=1, title="EMA 5 Length")
// Source
src5 = input(close, title="EMA 5 Source")
// Offsets and Band Adjustments
off5 = input(title="Offset 5th EMA", defval=0, minval=-500, maxval=500)
smooth5 = input(title="Smooth EMA 5", type=input.bool, defval=false)
// Calculations
ema5 = ema(src5, len5)
ema5_rough = security(syminfo.tickerid, res5, ema5, barmerge.gaps_off, barmerge.lookahead_off)
ema5_smooth = security(syminfo.tickerid, res5, ema5, barmerge.gaps_on, barmerge.lookahead_off)
// Plots
plot(vis5 and group2 ? smooth5 ? ema5_smooth: ema5_rough: na, title="EMA5", color=#ffd3b6, linewidth=1, offset=off5)

// EMA 6  
//==============================================================================
// Visibility
vis6 = input(true, title="Enable 6th MA")
// Timeframe
res6 = input(title="EMA 6 Timeframe", type=input.resolution, defval="5")
// Period
len6 = input(55, minval=1, title="EMA 6 Length")
// Source
src6 = input(close, title="EMA 6 Source")
// Offsets and Band Adjustments
off6 = input(title="Offset 6th EMA", defval=0, minval=-600, maxval=600)
smooth6 = input(title="Smooth EMA 6", type=input.bool, defval=false)
// Calculations
ema6 = ema(src6, len6)
ema6_rough = security(syminfo.tickerid, res6, ema6, barmerge.gaps_off, barmerge.lookahead_off)
ema6_smooth = security(syminfo.tickerid, res6, ema6, barmerge.gaps_on, barmerge.lookahead_off)
// Plots
plot(vis6 and group2 ? smooth6 ? ema6_smooth: ema6_rough: na, title="EMA6", color=#ffaaa5, linewidth=1, offset=off6)
````
