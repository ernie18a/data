# Kinetic MTF Trend & Structure Ribbons

- url: https://www.tradingview.com/script/AaYudXFe-Kinetic-MTF-Trend-Structure-Ribbons/
- type: indicator
- pine_id: PUB;932d82ba1877458cb5dbfe5e44dc12e8
- version: 1.0

## Description

[i]Kinetic Trend & Structure Ribbons is a multi-layer trend framework designed to make market structure visible across multiple time horizons on a single chart.[/i]

Instead of treating moving averages as isolated crossover signals, Kinetic organizes them into a visual hierarchy: [b]Execution → Trend → Structure → Long-Term Regime[/b]

The goal is simple: quickly identify whether price is trending, pulling back, compressing, transitioning, or undergoing a deeper structural change.

The framework is primarily designed around [b]stocks and swing trading[/b], while retaining enough short-term information to assist with lower-timeframe execution.

[b]Core Concept[/b]
Markets operate across multiple time horizons simultaneously.

A short-term selloff can occur inside a strong intermediate uptrend. An intermediate downtrend can occur while long-term structure remains bullish. Likewise, a short-term breakout means much more when the larger structural layers are aligned behind it.

Kinetic separates these horizons visually rather than compressing everything into a single bullish/bearish signal.

The framework is designed to answer four questions:
1. What is price doing right now?
2. What direction is the active trend?
3. Where is deeper market structure?
4. What is the long-term regime?

The relationship between these layers is often more important than any individual moving average.

[b]Visual Hierarchy[/b]
1. Execution Ribbon
The fastest group of averages follows price closely and represents short-term market behavior.
Use it to observe:
*Short-term momentum
* Expansion and contraction
* Trend rotation
* Pullbacks
* Reclaims
* Early changes in direction

When the ribbon is tightly compressed, the market may be entering equilibrium.

When it expands cleanly in one direction, short-term trend strength is increasing.

2. Gaussian Trend Line
The Gaussian filter acts as a smooth trend spine between short-term price action and the broader structural ribbons.

Its purpose is to reduce short-term noise while remaining responsive enough to identify meaningful changes in direction.

Watch for:
* Price reclaiming or losing the Gaussian
* Changes in Gaussian slope
* Interaction between the Gaussian and execution ribbon
* Compression between the Gaussian and larger trend structure
The Gaussian should be interpreted in context rather than as a standalone buy or sell signal.

3. Blue Trend Ribbon
The blue ribbon represents the primary trend layer.

This is the area where normal pullbacks within an established trend can often be distinguished from more meaningful structural deterioration.

Key characteristics include:
* Rising + expanding: strengthening bullish trend
* Falling + expanding: strengthening bearish trend
* Flattening: trend momentum is weakening
* Compressing: equilibrium or transition
* Price repeatedly respecting the ribbon: established trend behavior

The location of the execution layer and Gaussian relative to the blue ribbon provides additional context.

4. Gold Structure Ribbon
The gold ribbon represents slower, deeper market structure.

Because this layer reacts more slowly than the blue trend ribbon, interaction with gold generally represents a more significant event than an ordinary short-term pullback.

The gold ribbon can help distinguish between:
* Routine trend retracement
* Intermediate correction
* Structural reset
* Major trend transition

A market can lose its short-term trend while its deeper structure remains intact.

This distinction is one of the central ideas behind Kinetic.

5. Red Long-Term Regime
The red layer represents the slowest structural reference within the framework.

It is intended to provide long-term regime context rather than short-term entries.
Think of the hierarchy as:

Fast price behavior 
↓
Execution
↓
Gaussian
↓
Blue Trend
↓
Gold Structure
↓
Red Long-Term Regime

As price penetrates progressively deeper layers, the significance of the move generally increases.

[b]Reading the Framework[/b]
Bullish Alignment
The cleanest bullish environments occur when the layers become progressively ordered beneath price.

Typical characteristics:
* Price above the execution ribbon
* Execution ribbon expanding upward
* Gaussian rising
* Blue trend ribbon rising
* Gold structure ribbon rising
* Faster layers positioned above slower layers

This creates a visual hierarchy in which shorter-term momentum is supported by progressively deeper structure.

Bearish Alignment
The opposite configuration represents bearish alignment.
Typical characteristics:
* Price below the execution ribbon
* Execution ribbon expanding downward
* Gaussian falling
* Blue trend ribbon declining
* Gold structure deteriorating
* Faster layers positioned beneath slower layers

The more completely the hierarchy becomes inverted, the more significant the bearish regime.

Compression → Expansion
One of the most important concepts in Kinetic is compression and expansion.

During compression, multiple layers begin moving closer together. Trend separation decreases and the market approaches equilibrium.

Compression itself does not predict direction.
Instead, it identifies an environment where the existing trend structure has weakened and a new directional move may eventually develop.

The subsequent expansion provides the directional information.
Compression

Look for:
* Narrowing ribbons
* Flattening slopes
* Gaussian convergence
* Price repeatedly crossing the same structural area
* Reduced separation between fast and slow layers

Expansion
Look for:
* Ribbon separation increasing
* Consistent slope developing
* Price holding one side of the framework
* Faster layers leading slower layers
* Structural ordering becoming increasingly clean

Compression represents potential energy. Expansion reveals direction.

Pullbacks vs. Structural Breaks
Not every decline is bearish.

This framework was specifically designed to preserve the distinction between short-term weakness and long-term structural weakness.

For example, price may:
1. Lose the execution ribbon while remaining above blue.
2. Enter the blue trend ribbon while gold remains intact.
3. Lose blue and test deeper gold structure.
4. Lose both trend and structure and begin approaching the long-term regime layer.
These events should not be treated as equivalent.

The deeper price moves through the hierarchy, the more meaningful the structural deterioration becomes.

The same concept applies in reverse during recovery from a bearish regime.

Trend Transitions
Markets rarely move instantly from fully bullish to fully bearish structure.
Transitions frequently occur progressively:

Expansion → Deceleration → Compression → Rotation → Reordering → Expansion

Kinetic is designed to make this process visible.

Rather than attempting to predict every turning point, the framework allows the trader to observe the market reorganizing itself across multiple time horizons.

Practical Use
Kinetic is best used as a context and structure framework, not as a mechanical buy/sell system.
Potential applications include:
* Trend identification
* Swing-trade filtering
* Pullback evaluation
* Structural support/resistance
* Compression identification
* Breakout context
* Trend continuation
* Regime identification
* Multi-timeframe alignment
* Risk management context

A trader may combine the framework with independent tools such as price action, volume, relative strength, volume profile, or anchored VWAP depending on their methodology.
These external tools are not required for the framework itself.

Signals
Where enabled, Kinetic includes visual signals designed to highlight changes within the faster components of the framework.

Signals should not be interpreted as automatic entries or exits.

Their significance depends heavily on surrounding structure.

For example, a bullish short-term signal occurring above rising blue and gold ribbons represents a very different environment from the same signal occurring beneath declining structural layers.

Context comes first. Signal comes second.

Timeframe Philosophy
Kinetic uses multiple structural horizons so that a lower-timeframe chart can retain awareness of the larger trend.

This makes it particularly useful for traders who execute on shorter charts while making decisions based on higher-timeframe structure.

The objective is not to make every timeframe look identical.

It is to maintain a consistent structural framework while allowing price behavior to be examined at different levels of detail.

What Kinetic Is — and Isn’t
Kinetic is designed to visualize trend architecture.
It is not intended to:
* Predict exact tops or bottoms
* Generate guaranteed trade entries
* Replace risk management
* Eliminate false breakouts
* Function as a standalone trading strategy

The framework organizes information that already exists in price into a more intuitive structural hierarchy.

Its value comes from interpreting the relationships, slopes, ordering, compression, and expansion of those layers.

Quick Reference
Execution Ribbon → Short-term behavior and rotation
Gaussian → Smoothed trend spine
Blue Ribbon → Primary trend
Gold Ribbon → Deeper market structure
Red Layer → Long-term regime

The basic visual rule:
Ordered + expanding = trend
Compressed + intertwined = equilibrium / transition
Reordered + expanding = new trend structure

Final Notes
Kinetic was built around a simple premise: Price should not be viewed against one moving average or one timeframe in isolation.

Trend exists as a hierarchy.

Short-term momentum moves first. Intermediate trend follows. Deeper structure moves more slowly. Long-term regime changes slowest of all.

Kinetic brings those layers together so that their relationship can be read visually on a single chart.

Execution → Trend → Structure → Regime

The goal is not to predict what the market must do next.

The goal is to make it easier to see what the market is doing now.

## Source Code

````pine
//@version=6
indicator("Kinetic Framework - Stocks", shorttitle = "Kinetic Stocks", overlay = true, max_bars_back = 5000)

/// OVERTABLE OF CONTENTS ///
// 1. TIMEFRAMES
// 2. KINETIC MTF ZONES
// 3. GMMA "GUPPY" RIBBONS & SIGNAL
// 4. GAUSSIAN "EQUILIBRIUM" & SIGNAL 
// 5. USED SEPERATELY: AVWAP (EARNINGS, MAJOR SH/SL) & VOLUME PROFILE, MACD, RSI

// MOVING-AVERAGE FUNCTION //////////////////////////////////////////////////
ma(source, length, maType) =>
    switch maType
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        => na

// TIMEFRAMES //////////////////////////////////////////////////////////
string kineticTimeframe = input.timeframe("15","Kinetic timeframe",group = "Timeframes")
string kineticTimeframe2 = input.timeframe("30","Kinetic timeframe2",group = "Timeframes")
string gmmaTimeframe = input.timeframe("15","GMMA timeframe",group = "Timeframes")
string gaussianTimeframe = input.timeframe("15","Gaussian timeframe",group = "Timeframes")

// MARKETMODE
string marketModeGroup = "Market Mode"
bool use24HMode = input.bool(false, "Use 24H Market Lengths", group = marketModeGroup)
string activeKineticTimeframe = use24HMode ? "30" : kineticTimeframe
string activeKineticTimeframe2 = use24HMode ? "60" : kineticTimeframe2
string activeGaussianTimeframe = use24HMode ? "30" : gaussianTimeframe

// KINETIC ZONE SETTINGS //////////////////////////////////////////////
// BLUE - TREND ZONE // 8D, 13D, 21D EMA
string trendZoneGroup = "Kinetic Trend Zone"
bool showTrendZone = input.bool(true, "Show Trend Zone", group = trendZoneGroup)
int ma1Length = input.int(208, "8D EMA", minval = 1, inline = "K1", group = trendZoneGroup)
int ma2Length = input.int(338, "13D EMA", minval = 1, inline = "K2", group = trendZoneGroup)
int ma3Length = input.int(546, "21D EMA", minval = 1, inline = "K3", group = trendZoneGroup)
color trendZoneColor = input.color(#1848c9, "Trend Zone Color", group = trendZoneGroup)

// GOLD - STRUCTURE ZONE // 34D, 67D EMA (MID), 100D
string structureZoneGroup = "Kinetic Structure Zone"
bool showStructureZone = input.bool(true, "Show Structure Zone", group = structureZoneGroup)
int ma4Length = input.int(884, "34D EMA", minval = 1, inline = "K4", group = structureZoneGroup)
int ma5Length = input.int(1586, "67D EMA (Midpoint)", minval = 1, inline = "K5", group = structureZoneGroup)
int ma6Length = input.int(2600, "100D EMA", minval = 1, inline = "K6", group = structureZoneGroup)
color structureZoneColor = input.color(#a2804b, "Structure Zone Color", group = structureZoneGroup)

// RED - LONG TERM STRUCTURE ZONE // 150D, 200D EMA
string longtermstructureZoneGroup = "Kinetic Structure Zone"
bool showlongtermStructureZone = input.bool(true, "Show Long Term Zone", group = longtermstructureZoneGroup)
int ma7Length = input.int(1950, "150D EMA (Midpoint)", minval = 1, inline = "K7", group = longtermstructureZoneGroup)
int ma8Length = input.int(2600, "200D EMA", minval = 1, inline = "K8", group = longtermstructureZoneGroup)
color longtermstructureZoneColor = input.color(color.rgb(160, 50, 16), "Long Term Structure Zone Color", group = longtermstructureZoneGroup)

// 24H KINETIC ZONE Lengths
string h24trendZoneGroup = "24H Kinetic Trend Zone"
string h24structureZoneGroup = "24H Kinetic Structure Zone"
string h24longtermstructureZoneGroup = "24H Kinetic Long Term Structure Zone"

int h24ma1Length = input.int(384, "8D EMA", minval = 1, inline = "K1", group = h24trendZoneGroup)
int h24ma2Length = input.int(624, "13D EMA", minval = 1, inline = "K2", group = h24trendZoneGroup)
int h24ma3Length = input.int(1008, "21D EMA", minval = 1, inline = "K3", group = h24trendZoneGroup)
int h24ma4Length = input.int(1632, "34D EMA", minval = 1, inline = "K4", group = h24structureZoneGroup)
int h24ma5Length = input.int(2928, "61D EMA (Midpoint)", minval = 1, inline = "K5", group = h24structureZoneGroup)
int h24ma6Length = input.int(4800, "100D EMA", minval = 1, inline = "K6", group = h24structureZoneGroup)
int h24ma7Length = input.int(3500, "150D EMA", minval = 1, inline = "K7", group = h24longtermstructureZoneGroup)
int h24ma8Length = input.int(4550, "200D EMA", minval = 1, inline = "K8", group = h24longtermstructureZoneGroup)

// ACTIVE KINETIC LENGTHS   
int activeMa1Length = use24HMode ? h24ma1Length : ma1Length
int activeMa2Length = use24HMode ? h24ma2Length : ma2Length
int activeMa3Length = use24HMode ? h24ma3Length : ma3Length

int activeMa4Length = use24HMode ? h24ma4Length : ma4Length
int activeMa5Length = use24HMode ? h24ma5Length : ma5Length
int activeMa6Length = use24HMode ? h24ma6Length : ma6Length

int activeMa7Length = use24HMode ? h24ma7Length : ma7Length
int activeMa8Length = use24HMode ? h24ma8Length : ma8Length

// KINETIC ZONE CALCULATIONS — FIXED DAILY 
ma1 = request.security(syminfo.tickerid,activeKineticTimeframe,ta.ema(close, activeMa1Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
ma2 = request.security(syminfo.tickerid,activeKineticTimeframe,ta.ema(close, activeMa2Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
ma3 = request.security(syminfo.tickerid,activeKineticTimeframe,ta.ema(close, activeMa3Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
ma4 = request.security(syminfo.tickerid,activeKineticTimeframe,ta.ema(close, activeMa4Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
ma5 = request.security(syminfo.tickerid,activeKineticTimeframe,ta.ema(close, activeMa5Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
ma6 = request.security(syminfo.tickerid,activeKineticTimeframe,ta.ema(close, activeMa6Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
ma7 = request.security(syminfo.tickerid,activeKineticTimeframe2,ta.ema(close, activeMa7Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
ma8 = request.security(syminfo.tickerid,activeKineticTimeframe2,ta.ema(close, activeMa8Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)

// KINETIC SLOPE
slopeColor(maValue, baseColor, dimAmount) =>na (maValue[2]) or maValue >= maValue[2] ? baseColor: color.new(baseColor, dimAmount)
int bearishDim = input.int(80, "Bearish Zone Dumping", minval = 0, maxval = 100, group = "Visual Settings")

// KINETIC ZONE PLOTS 
pMa1 = plot(showTrendZone ? ma1: na, title = "8D EMA", color = slopeColor(ma1, trendZoneColor, bearishDim), linewidth = 1)
pMa2 = plot(showTrendZone ? ma2: na, title = "13D EMA", color = slopeColor(ma2, trendZoneColor, bearishDim), linewidth = 1)
pMa3 = plot(showTrendZone ? ma3: na, title = "21D EMA", color = slopeColor(ma3, trendZoneColor, bearishDim), linewidth = 1)
pMa4 = plot(showTrendZone ? ma4: na, title = "34D EMA", color = slopeColor(ma4, structureZoneColor, bearishDim), linewidth = 1)
pMa5 = plot(showTrendZone ? ma5: na, title = "67D EMA", color = slopeColor(ma5, structureZoneColor, bearishDim), linewidth = 1)
pMa6 = plot(showTrendZone ? ma6: na, title = "100D EMA", color = slopeColor(ma6, structureZoneColor, bearishDim), linewidth = 1)
pMa7 = plot(showTrendZone ? ma7: na, title = "150D EMA", color = slopeColor(ma7, longtermstructureZoneColor, bearishDim), linewidth = 1)
pMa8 = plot(showTrendZone ? ma8: na, title = "200D EMA", color = slopeColor(ma8, longtermstructureZoneColor, bearishDim), linewidth = 1)

// ZONE FILL SETTINGS 
string fillGroup = "Kinetic Zone Fills" 

// TREND ZONE FILLS
bool showBlueFill1 = input.bool(true, "8/13D", inline = "BF1", group = fillGroup)
int blueTrans1 = input.int(80, "", minval = 0, maxval = 100, inline = "BF1", group = fillGroup)
bool showBlueFill2 = input.bool(true, "13/21D", inline = "BF2", group = fillGroup)
int blueTrans2 = input.int(90, "", minval = 0, maxval = 100, inline = "BF2", group = fillGroup)

// STRUCTURE ZONE FILLS
bool showGoldFill1 = input.bool(true, "34/67D", inline = "GF1", group = fillGroup)
int goldTrans1 = input.int(85, "", minval = 0, maxval = 100, inline = "GF1", group = fillGroup)
bool showGoldFill2 = input.bool(true, "67D/100D", inline = "GF3", group = fillGroup)
int goldTrans2 = input.int(90, "", minval = 0, maxval = 100, inline = "GF3", group = fillGroup)

// LT STRUCTURE ZONE FILLS
bool showRedFill1 = input.bool(true, "150/200D", inline = "GF1", group = fillGroup)
int redTrans1 = input.int(95, "", minval = 0, maxval = 100, inline = "GF1", group = fillGroup)

// KINETIC ZONE FILLS 
color blueFill1 = showBlueFill1 ? color.new(trendZoneColor, blueTrans1) : na    
color blueFill2 = showBlueFill2 ? color.new(trendZoneColor, blueTrans2) : na
color goldFill1 = showGoldFill1 ? color.new(structureZoneColor, goldTrans1) : na
color goldFill2 = showGoldFill2 ? color.new(structureZoneColor, goldTrans2) : na
color redFill1 = showRedFill1 ? color.new(longtermstructureZoneColor, redTrans1) : na
     
fill(pMa1,pMa2,color = blueFill1,title = "8/13D Fill")
fill(pMa2,pMa3,color = blueFill2,title = "13/21D Fill")
fill(pMa4,pMa5,color = goldFill1,title = "34/67D Fill")
fill(pMa5, pMa6,color = goldFill2, title = "67/100D Fill")
fill(pMa7, pMa8,color = redFill1, title = "150/200D Fill")

// GMMA SETTINGS //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
string shortGmmaGroup = "GMMA — Short Group"
bool showShortGmma = input.bool(true,"Show short GMMA", group = shortGmmaGroup)
color shortGmmaColor = input.color(#5EF3E8,"Short GMMA color", group = shortGmmaGroup)

int shortGmmaTransparency = input.int(90,"Short GMMA transparency",minval = 0,maxval = 100,group = shortGmmaGroup)
int short1Length = input.int(6, "Short GMMA 1", minval = 1, group = shortGmmaGroup)
int short2Length = input.int(10, "Short GMMA 2", minval = 1, group = shortGmmaGroup)
int short3Length = input.int(16, "Short GMMA 3", minval = 1, group = shortGmmaGroup)
int short4Length = input.int(20, "Short GMMA 4", minval = 1, group = shortGmmaGroup)
int short5Length = input.int(24, "Short GMMA 5", minval = 1, group = shortGmmaGroup)
int short6Length = input.int(30, "Short GMMA 6", minval = 1, group = shortGmmaGroup)

string longGmmaGroup = "GMMA — Long Group"
bool showLongGmma = input.bool(true,"Show long GMMA",group = longGmmaGroup)
color longGmmaColor = input.color(#f7525f,"Long GMMA color",group = longGmmaGroup)

int longGmmaTransparency = input.int(90,"Long GMMA transparency",minval = 0,maxval = 100,group = longGmmaGroup)
int long1Length = input.int(60, "Long GMMA 1", minval = 1, group = longGmmaGroup)
int long2Length = input.int(70, "Long GMMA 2", minval = 1, group = longGmmaGroup)
int long3Length = input.int(80, "Long GMMA 3", minval = 1, group = longGmmaGroup)
int long4Length = input.int(90, "Long GMMA 4", minval = 1, group = longGmmaGroup)
int long5Length = input.int(110, "Long GMMA 5", minval = 1, group = longGmmaGroup)
int long6Length = input.int(120, "Long GMMA 6", minval = 1, group = longGmmaGroup)

// 24H GMMA LENGTHS
string h24shortGmmaGroup = "24H Short GMMA"
string h24longGmmaGroup = "24H Long GMMA"

int h24short1Length = input.int(22, "Short GMMA 1", minval = 1, group = h24shortGmmaGroup)
int h24short2Length = input.int(37, "Short GMMA 2", minval = 1, group = h24shortGmmaGroup)
int h24short3Length = input.int(59, "Short GMMA 3", minval = 1, group = h24shortGmmaGroup)
int h24short4Length = input.int(74, "Short GMMA 4", minval = 1, group = h24shortGmmaGroup)
int h24short5Length = input.int(89, "Short GMMA 5", minval = 1, group = h24shortGmmaGroup)
int h24short6Length = input.int(111, "Short GMMA 6", minval = 1, group = h24shortGmmaGroup)

int h24long1Length = input.int(222, "Long GMMA 1", minval = 1, group = h24longGmmaGroup)
int h24long2Length = input.int(258, "Long GMMA 2", minval = 1, group = h24longGmmaGroup)
int h24long3Length = input.int(295, "Long GMMA 3", minval = 1, group = h24longGmmaGroup)
int h24long4Length = input.int(332, "Long GMMA 4", minval = 1, group = h24longGmmaGroup)
int h24long5Length = input.int(406, "Long GMMA 5", minval = 1, group = h24longGmmaGroup)
int h24long6Length = input.int(443, "Long GMMA 6", minval = 1, group = h24longGmmaGroup)

// ACTIVE GMMA LENGTHS
int activeshort1Length = use24HMode ? h24short1Length : short1Length
int activeshort2Length = use24HMode ? h24short2Length : short2Length
int activeshort3Length = use24HMode ? h24short3Length : short3Length
int activeshort4Length = use24HMode ? h24short4Length : short4Length
int activeshort5Length = use24HMode ? h24short5Length : short5Length
int activeshort6Length = use24HMode ? h24short6Length : short6Length

int activelong1Length = use24HMode ? h24long1Length : long1Length
int activelong2Length = use24HMode ? h24long2Length : long2Length
int activelong3Length = use24HMode ? h24long3Length : long3Length
int activelong4Length = use24HMode ? h24long4Length : long4Length
int activelong5Length = use24HMode ? h24long5Length : long5Length
int activelong6Length = use24HMode ? h24long6Length : long6Length

// GMMA CALCULATIONS - SELECTED GMMA TIMEFRAME
short1 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activeshort1Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
short2 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activeshort2Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
short3 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activeshort3Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
short4 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activeshort4Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
short5 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activeshort5Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
short6 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activeshort6Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
long1 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activelong1Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
long2 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activelong2Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
long3 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activelong3Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
long4 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activelong4Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
long5 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activelong5Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)
long6 = request.security(syminfo.tickerid,gmmaTimeframe,ta.ema(close, activelong6Length),gaps = barmerge.gaps_off,lookahead = barmerge.lookahead_off)

// GMMA PLOTS 
color shortColor = color.new(shortGmmaColor,shortGmmaTransparency)
color longColor = color.new(longGmmaColor,longGmmaTransparency)

plot(showShortGmma ? short1 : na,title = "Short GMMA 1",color = shortColor,linewidth = 1)
plot(showShortGmma ? short2 : na,title = "Short GMMA 2",color = shortColor,linewidth = 1)
plot(showShortGmma ? short3 : na,title = "Short GMMA 3",color = shortColor,linewidth = 1)
plot(showShortGmma ? short4 : na,title = "Short GMMA 4",color = shortColor,linewidth = 1)
plot(showShortGmma ? short5 : na,title = "Short GMMA 5",color = shortColor,linewidth = 1)
plot(showShortGmma ? short6 : na,title = "Short GMMA 6",color = shortColor,linewidth = 1)
plot(showLongGmma ? long1 : na,title = "Long GMMA 7",color = longColor,linewidth = 1)
plot(showLongGmma ? long2 : na,title = "Long GMMA 8",color = longColor,linewidth = 1)
plot(showLongGmma ? long3 : na,title = "Long GMMA 9",color = longColor,linewidth = 1)
plot(showLongGmma ? long4 : na,title = "Long GMMA 10",color = longColor,linewidth = 1)
plot(showLongGmma ? long5 : na,title = "Long GMMA 11",color = longColor,linewidth = 1)
plot(showLongGmma ? long6 : na,title = "Long GMMA 12",color = longColor,linewidth = 1)

// GMMA ROTATION DOTS ///////////////////////////////////////////////////////////
string gmmaSignalGroup = "GMMA Signals"
bool showGmmaDots = input.bool(true,"Show GMMA rotation dots",group = gmmaSignalGroup)
color gmmaBullColor = input.color(#00ffbb,"Bull dot color",group = gmmaSignalGroup)
color gmmaBearColor = input.color(color.red,"Bear dot color",group = gmmaSignalGroup)

gmmaCross(gmma) => 
    int flag = 0

    if( 
       gmma > long1 and
       gmma > long2 and
       gmma > long3 and
       gmma > long4 and
       gmma > long5 and
       gmma > long6
    )
        flag := 1

    if(
        
       gmma < long1 and
       gmma < long2 and
       gmma < long3 and
       gmma < long4 and
       gmma < long5 and
       gmma < long6
    )
        flag := -1
    flag

s1Cross = gmmaCross(short1)
s2Cross = gmmaCross(short2)
s3Cross = gmmaCross(short3)
s4Cross = gmmaCross(short4)
s5Cross = gmmaCross(short5)
s6Cross = gmmaCross(short6)

crossCount = s1Cross + s2Cross + s3Cross + s4Cross + s5Cross
bool gmmaBullRotation = crossCount == 5 and ta.crossover(s6Cross, 0)
bool gmmaBearRotation = crossCount == -5 and ta.crossunder(s6Cross, 0)
plotshape(showGmmaDots and gmmaBullRotation ? short6 : na, title = "GMMA Bull Rotation Dot", style = shape.circle, location = location.absolute, color = gmmaBullColor, size = size.tiny)
plotshape(showGmmaDots and gmmaBearRotation ? short6 : na,title = "GMMA Bear Rotation Dot",style = shape.circle,location = location.absolute,color = gmmaBearColor,size = size.tiny)

// GAUSSIAN TREND FILTER SETTINGS //////////////////////////////////////////////////////////////////////////////////////////////////////////////
string gaussianGroup = "Gaussian Filter"
bool showGaussian = input.bool(true,"Show Gaussian line",group = gaussianGroup)
bool showGaussianSignals = input.bool(true,"Show Gaussian signals", group = gaussianGroup)
int gaussianLength = input.int(260,"Gaussian length",minval = 1, group = gaussianGroup)
int gaussianPoles = input.int(2,"Gaussian poles", minval = 1, maxval = 4, group = gaussianGroup)
int gaussianSmoothLength = input.int(26,"Smoothing length", minval = 1, group = gaussianGroup)
int gaussianFlatten = input.int(10,"Flatten multiplier",group = gaussianGroup)

color gaussianBullLineColor = input.color(#00ffbb,"Bullish line color", group = gaussianGroup)
color gaussianBearLineColor = input.color(#f7525f, "Bearish line color", group = gaussianGroup)
int gaussianLineWidth = input.int(2,"Gaussian line width",minval = 1, maxval = 4, group = gaussianGroup)

// 24H GAUSSIAN
string h24gaussianGroup1 = "24H - Gaussian 1"

int h24gaussianLength = input.int(480,"Gaussian length",minval = 1, group = h24gaussianGroup1)
int h24gaussianSmoothLength = input.int(26,"Smoothing length", minval = 1, group = h24gaussianGroup1)

int activegaussianLength = use24HMode ? h24gaussianLength : gaussianLength
int activegaussianSmoothLength = use24HMode ? h24gaussianSmoothLength : gaussianSmoothLength

// GAUSSIAN FUNCTIONS //////////////////////////////////////////////////////////////////
calcGaussianAlpha(_length, _order) =>
    float frequency = 2.0 * math.pi / _length

    float factorB =
         (1.0 - math.cos(frequency)) /
         (math.pow(1.414, 2.0 / _order) - 1.0)

    float alphaValue =
         -factorB +
         math.sqrt(factorB * factorB + 2.0 * factorB)

    alphaValue

gaussianSmooth(_source, _poles, _alpha) =>
    var float filterValue = 0.0

    float oneMinusAlpha = 1.0 - _alpha
    float alphaSquared = _alpha * _alpha
    float alphaCubed = alphaSquared * _alpha
    float alphaFourth = alphaCubed * _alpha
    float omaSquared = oneMinusAlpha * oneMinusAlpha
    float omaCubed = omaSquared * oneMinusAlpha
    float omaFourth = omaCubed * oneMinusAlpha

    if _poles == 1
        filterValue :=
             _alpha * _source +
             oneMinusAlpha * nz(filterValue[1])

    else if _poles == 2
        filterValue :=
             alphaSquared * _source +
             2.0 * oneMinusAlpha * nz(filterValue[1]) -
             omaSquared * nz(filterValue[2])

    else if _poles == 3
        filterValue :=
             alphaCubed * _source +
             3.0 * oneMinusAlpha * nz(filterValue[1]) -
             3.0 * omaSquared * nz(filterValue[2]) +
             omaCubed * nz(filterValue[3])

    else
        filterValue :=
             alphaFourth * _source +
             4.0 * oneMinusAlpha * nz(filterValue[1]) -
             6.0 * omaSquared * nz(filterValue[2]) +
             4.0 * omaCubed * nz(filterValue[3]) -
             omaFourth * nz(filterValue[4])

    filterValue

gaussianSupertrend(_source, _factor, _atrLength) =>
    float atrValue = ta.atr(_atrLength)

    float upperBand = _source + _factor * atrValue
    float lowerBand = _source - _factor * atrValue
    float previousLowerBand = nz(lowerBand[1])
    float previousUpperBand = nz(upperBand[1])

    lowerBand :=
         lowerBand > previousLowerBand or
         _source[1] < previousLowerBand
         ? lowerBand
         : previousLowerBand

    upperBand :=
         upperBand < previousUpperBand or
         _source[1] > previousUpperBand
         ? upperBand
         : previousUpperBand

    int direction = na
    float supertrendValue = na

    float previousSupertrend = supertrendValue[1]

    if na(atrValue[1])
        direction := 1

    else if previousSupertrend == previousUpperBand
        direction := _source > upperBand ? -1 : 1

    else
        direction := _source < lowerBand ? 1 : -1

    supertrendValue :=
         direction == -1
         ? lowerBand
         : upperBand

    [supertrendValue, direction]

gaussianCalculation() => 
    float gaussianAlphaLocal = calcGaussianAlpha(activegaussianLength, gaussianPoles)
    float gaussianRawLocal = gaussianSmooth(close, gaussianPoles, gaussianAlphaLocal)
    float gaussianLineLocal = ta.linreg(gaussianRawLocal, activegaussianSmoothLength, gaussianFlatten)
    [gaussianTrendLineLocal, gaussianDirectionLocal] = gaussianSupertrend(gaussianLineLocal, 0.15, 21)
    int gaussianTrendLocal = gaussianLineLocal > gaussianTrendLineLocal ? 1 : -1
    [gaussianLineLocal, gaussianTrendLineLocal, gaussianTrendLocal]
    
// GAUSSIAN CALCULATIONS ////////////////////////////////////////////////////////
[gaussianLine, gaussianTrendLine, gaussianTrend] = request.security(syminfo.tickerid, activeGaussianTimeframe, gaussianCalculation(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// GAUSSIAN SIGNALS /////////////////////////////////////////////////////////////
bool gaussianBullSignal = gaussianTrend == 1 and gaussianTrend[1] == -1
bool gaussianBearSignal = gaussianTrend == -1 and gaussianTrend[1] == 1

// GAUSSIAN SIGNAL LOCATIONS ////////////////////////////////////////////////////
float gaussianDistance = ta.sma(math.abs(close - open), 100)
float gaussianSignalLow = math.min(ta.lowest(low, 14),math.min(ta.lowest(gaussianLine, 14),gaussianLine - gaussianDistance * 2.0))
float gaussianSignalHigh = math.max(ta.highest(high, 14),math.max(ta.highest(gaussianLine, 14),gaussianLine + gaussianDistance * 2.0))

// GAUSSIAN LINE ////////////////////////////////////////////////////////////////
color gaussianCurrentColor = gaussianTrend == 1 ? gaussianBullLineColor : gaussianBearLineColor
plot(showGaussian ? gaussianLine : na,title = "Gaussian Filter",color = gaussianCurrentColor, linewidth = gaussianLineWidth)
````
