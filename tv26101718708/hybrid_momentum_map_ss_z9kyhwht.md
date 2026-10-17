# Hybrid Momentum Map [SS]

- url: https://www.tradingview.com/script/Z9KyHwHT-Hybrid-Momentum-Map-SS/
- type: indicator
- pine_id: PUB;82839aa5bba44d04a171ce0484076e63
- version: 2.0

## Description

Hey everyone! 
This isn't typically my style of indicator, as I mostly do more math based, but this was a request from my community and am happy to take a stab at it! 

[b]What is this?[/b]
This is the Hybrid Momentum Map indicator. It is an advanced 3D visualization suite built for Pine Script v6. It moves beyond the limitations of traditional 2D indicators by mapping market velocity across a three dimensional coordinate system.

Instead of choosing between a trend-following indicator or a mean-reversion tool, the Map synthesizes the best features of the MACD, RSI, and Z-Score into a single, cohesive momentum based mapping system. 

[b]The Three Amigos [/b]
If you use my indicators, you know that I am all about more math based analysis. So this is the logical outcome of me doing a predominately momentum based indicator. That is, anchoring momentum to some statistical feature (in this case z-score). 

The Map operates by "stealing" the most effective features of two legendary momentum oscillators (MACD and RSI) and anchoring them based on Z-Score: 

[i]The RSI Core (Speed & Velocity)[/i]
At its heart, each layer uses the Relative Strength Index to measure the internal speed of the price movement. This provides the "height" of the map, showing you exactly how much "gas" is left in the tank for the current move.

[i]The MACD Spirit (Convergence & Divergence)[/i]
While the script doesn't plot a standard MACD line, it mimics the MACD's core philosophy. By plotting 10 different periods (from 10 to 46), the Map reveals the spread between short-term momentum (the front layers) and long-term inertia (the back layers).

When the front layers move significantly faster than the back, you are seeing a "MACD Crossover" in 3D space before it ever happens on a 2D chart.

[i]The Z-Score Grounding (Statistical Reality and a Steversteves Classic)[/i]
To prevent momentum chasing, the script uses Z-Score (Standard Deviation) as a grounding mechanism. This calculates how far the current price has drifted from its mathematical mean.

This keeps the signals honest, for example if momentum is high but the Z-Score is at an extreme, the Map will show a sharp peak, warning you of a potential reversion to the mean (aka a pullback).

[b]Key Features & Visualization[/b]

[i]3D Multi-Layer Mapping:[/i] I wanted to try a 3D indicator myself, seeing as I see a lot of developments from the Pinescript community in 3D visualizations. So, to do this, I thought the best use case for 3D is multi-timeframe view. This indicator provides a view of 10 timeframes at once. You can see how a short-term ripple in the front layers eventually turns into a tidal wave in the back layers, confirming a true trend shift.

[i]Automated Structural Mapping:[/i] The indicator detects Bullish and Bearish Divergences within the 3D terrain and automatically projects dashed trendlines onto your price candles.

[i]Smart Signal Latching:[/i] The Map includes a built-in logic gate that prevents repetitive Buy/Sell signals. It waits for high-conviction alignment across the majority of the 10 layers before firing an entry label.

[i]Interactive Perspective:[/i] Fully adjustable Yaw, Pitch, and Zoom allow you to walk through the momentum data to find the angle that reveals the most hidden structure. Just like you're a pilot 🧑‍✈️! 

[b]How to Trade the Map[/b]
[i]The Alignment Entry:[/i] When the Map aligns and triggers a BUY or SELL label, it means the RSI, MACD-style convergence, and Z-Score are all pointing in the same direction. This is your high-probability entry.

[i]The Fading Peak:[/i] If you see the front layers of the map starting to sink while the price is still rising, the MACD-style momentum is dying. This is often the first warning of a trend reversal.

[i]Structural Divergence:[/i] When price creates a new High, but the Map's "ceiling" is lower than the previous peak, the script will highlight a Bearish Divergence. This indicates the move is hollow and likely to fail.

[b]Technical Settings[/b]

[i]Time History:[/i] Length of the momentum trail.

[i]Plot Buy/Sell:[/i] Toggle overlay signals on/off.

[i]3D Controls:[/i] Customize the map's orientation to your liking.

[b]Alert Conditions [/b]

I am traditionally terrible with remembering to add basic alert conditions into my scripts. Its probably one of the biggest requests I get. I did not forget with this one, lol! 
You can set alert conditions for divergence and buy/sell signals. 

Anyway, that is the indicator, I hope you enjoy it and find it useful! 

As always, safe trades!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steversteves
//                                                                                                
//                                                           =                                        
//                            ≈×  ≠±                          ≠≤    ≠:   ≈                            
//                           ≤≠  ≥≈                            ≠∑   ≈≥   ≈≥                           
//                       ≈   ≤∑ √≠=  =>             .           ≈≥:  ∑≈  ∑≠                           
//                       ∑   ≥∑≥√±  ≥≈           :>Iii;.         ≈≤≥ ≥±  ≥±  =                        
//                       ≥∑   ∑∑≠× ≤≈           ->IIii,:;         ±≤∑∑± √×   ≥÷                       
//                       ≥≥∑   ≥≥= ≥=          ->IIIi;   :!i,      ∑≥≤×∑±×   ≤-                       
//                        ≥≥∑  ∑≥≥√=.         <-<IIII; .    ,   ≥≠  ∑≈≥≈÷   √≠                        
//                         ≈≥∑≈ ≤∑≈+  ÷       -IIIIi;i: l       ≥≥= ∑≤±=   ∑≠                         
//                       =≥  ≤≥≤ ≥≈  ≈≤×     !::iii;::  .:      ∑≤ √∑+   ≠≥÷l                         
//                        ≈≥≥= ≠≤≥≠∑  ≥≥     iii;,.  .   >      ≥±=√± √≥≈-+                           
//                          ≈≈≤∑√≤≠≠≥∑≠≤≥   .,;!!Ii;;:,   l    ≥≠∑≥≈×+>>:                             
//                             :+<!!!<>×÷≈=!<iiii;;;;;;i:  .!==><+×+                                  
//                                      ,iI!;.           .,ii,                                        
//                                ;iIII;.    ∂-∇⋆•∇⋆⋆∇√>>:    ,iiIi:,                                 
//                                 I,      : ≥  +∇∫•≥<  !  :      ,:                                  
//                                   ;I:   : °:I≠≥∑⋆≤-  =, :    ;,                                    
//                                        I   <∂•°∂•≤÷×I  , ;                                         
//                                       :.:   ≈•∇≠≥∑÷+    ; ,                                        
//                                       ;....  ∇I, ≠-   ;  ,                                         
//                                          <:i ∇⋆°∏∂+  : ; : .                                       
//                                      I;. Il.:≥∇∏±+< ;:.    :i                                      
//                                  :<l: I.. !II.      ,i   . ,  ,!I                                  
//                                 ilIIIi ;.  >!,,:;, : ;  ,.      .<                                 
//                                 !IiI;II: ; :.!Iii:,;   ;.  ,i.   .i                                
//                                !I,;Ii iii    ,<i::i. ,,  iii      l                                
//                                II ,i;; ,i,;   Il.:     i;i,     :  I                               
//                               i,.  ; ;:  ;. .  l..   ;, :   ,   :  .                               
//                                       .:        ,   .      ,.                                      
//                               iI   i;;IIIi IIi  ,I   .I.i;  i;  .=±+;                              
//                               ∂∂÷ ≥∂÷×∫!!! ∂i ≈∇>∇   :∂.√∇∫,∑× I∂-i,!.                             
//                               ≈I±≈-÷+>±... ≈×±≈,l≠   ,≠.≈=!≠≠> . ,;>≈l                             
//                               I: I i;;IIII I, ;I;IIII.I.Ii  I; .I<><I               
//@version=6
indicator("Hybrid Momentum Map [SS]", overlay = false, max_polylines_count = 100, max_labels_count = 50)

// User inputs 
width  = input.int(45, "Time History", minval = 10, maxval = 70)
zoom   = input.float(4.0, "Scale Factor")
yaw    = input.float(35, "Yaw") * math.pi / 180
pitch  = input.float(40, "Pitch") * math.pi / 180
bs     = input.bool(true, "Plot Buy and Sell Signals")


f_get_data(int l) =>
    float r = ta.rsi(close, l)
    float z = (close - ta.sma(close, l)) / math.max(ta.stdev(close, l), syminfo.mintick)
    float h = math.max(0, math.min(100, (r * 0.5) + ((50 + z * 15) * 0.5)))
    h


float m01 = f_get_data(10), float m02 = f_get_data(14), float m03 = f_get_data(18)
float m04 = f_get_data(22), float m05 = f_get_data(26), float m06 = f_get_data(30)
float m07 = f_get_data(34), float m08 = f_get_data(38), float m09 = f_get_data(42)
float m10 = f_get_data(46)

// init. matrices 
int depth = 10
var matrix<float> terrain = matrix.new<float>(depth, width, 50.0)
int col_idx = bar_index % width

// Matricies 
matrix.set(terrain, 0, col_idx, m01), matrix.set(terrain, 1, col_idx, m02)
matrix.set(terrain, 2, col_idx, m03), matrix.set(terrain, 3, col_idx, m04)
matrix.set(terrain, 4, col_idx, m05), matrix.set(terrain, 5, col_idx, m06)
matrix.set(terrain, 6, col_idx, m07), matrix.set(terrain, 7, col_idx, m08)
matrix.set(terrain, 8, col_idx, m09), matrix.set(terrain, 9, col_idx, m10)

//3d mapping 
type Point3D
    float x
    float y
    float z

method project(Point3D p, int anchorX, float anchorY) =>
    float xr = p.x * math.cos(yaw) - p.y * math.sin(yaw)
    float yr = p.x * math.sin(yaw) + p.y * math.cos(yaw)
    float finalX = xr * zoom
    float finalY = (yr * math.sin(pitch) - (p.z - 50) * math.cos(pitch)) * zoom
    chart.point.from_index(anchorX + int(finalX), anchorY - finalY)

// housekeeping 
if barstate.islast

    for pl in polyline.all
        polyline.delete(pl)
    
    label[] all_labels = label.all
    if array.size(all_labels) > 0
        for i = array.size(all_labels) - 1 to 0
            label lb = array.get(all_labels, i)
            if str.contains(label.get_text(lb), "✦") 
                label.delete(lb)


    int head = bar_index % width


    float xr_lead = (width - 1) * math.cos(yaw) - 0 * math.sin(yaw)
    float finalX_lead = xr_lead * zoom
    int anchorX = bar_index - int(finalX_lead)

    float anchorY = 50.0 

    
    for d = 0 to depth - 2
        array<chart.point> strip = array.new<chart.point>()
        

        for t = 0 to width - 1
            int h = (head + 1 + t) % width
            strip.push(Point3D.new(t, d, terrain.get(d, h)).project(anchorX, anchorY))

        for t = width - 1 to 0
            int h = (head + 1 + t) % width
            strip.push(Point3D.new(t, d + 1, terrain.get(d + 1, h)).project(anchorX, anchorY))
        

        float val = terrain.get(d, head)
        color gradCol = color.from_gradient(val, 30, 70, color.new(#ff1100, 30), color.new(#00ffcc, 30))
        polyline.new(strip, closed = true, fill_color = gradCol, line_color = color.new(gradCol, 60))


    for t = 0 to width - 1 by 2 
        array<chart.point> wire = array.new<chart.point>()
        int h = (head + 1 + t) % width
        for d = 0 to depth - 1
            wire.push(Point3D.new(t, d, terrain.get(d, h)).project(anchorX, anchorY))
        polyline.new(wire, closed = false, line_color = color.new(color.gray, 80))


    chart.point markerPos = Point3D.new(width - 1, 0, m01).project(anchorX, anchorY)
    label.new(markerPos, "✦ " + str.tostring(close, format.mintick), color=#00000000, textcolor=color.white, style=label.style_label_left)

bool rawBuy  = m01 > 60 and m05 > 60 and m10 > 60
bool rawSell = m01 < 40 and m05 < 40 and m10 < 40

// Counting to prevent excessive signaling 
var int signalState = 0 
bool triggerBuy  = rawBuy  and signalState != 1
bool triggerSell = rawSell and signalState != -1

if triggerBuy
    signalState := 1
if triggerSell
    signalState := -1


bool bearishDiv = ta.rising(high, 3) and ta.falling(m01, 3) and m01 > 70

// labels 
if triggerBuy and bs 
    label.new(
         bar_index, 
         low, 
         "BUY", 
         yloc=yloc.belowbar, 
         color=color.new(color.green, 20), 
         textcolor=color.white, 
         style=label.style_label_up, 
         size=size.small,
         force_overlay = true
     )

if triggerSell and bs 
    label.new(
         bar_index, 
         high, 
         "SELL", 
         yloc=yloc.abovebar, 
         color=color.new(color.red, 20), 
         textcolor=color.white, 
         style=label.style_label_down, 
         size=size.small,
         force_overlay = true
     )

    
// trendline for divergences 
lookback = 5 // Candles to confirm a pivot
pr_high  = ta.pivothigh(high, lookback, lookback)
pr_low   = ta.pivotlow(low, lookback, lookback)
m_high   = ta.pivothigh(m01, lookback, lookback)
m_low    = ta.pivotlow(m01, lookback, lookback)


var float last_pr_high = na
var int last_pr_high_idx = na
var float last_m_high = na

if not na(pr_high) and not na(m_high)
    if pr_high > last_pr_high and m_high < last_m_high
        // Draw Trendline on Chart
        line.new(last_pr_high_idx, last_pr_high, bar_index - lookback, pr_high, 
             color=color.red, width=2, style=line.style_dashed, force_overlay=true)
        // Post Label
        label.new(bar_index - lookback, pr_high, "Bearish Div", 
             textcolor=color.white, color=color.red, style=label.style_label_down, force_overlay=true)
    
    last_pr_high := pr_high
    last_pr_high_idx := bar_index - lookback
    last_m_high := m_high

var float last_pr_low = na
var int last_pr_low_idx = na
var float last_m_low = na

if not na(pr_low) and not na(m_low)
    if pr_low < last_pr_low and m_low > last_m_low

        line.new(last_pr_low_idx, last_pr_low, bar_index - lookback, pr_low, 
             color=color.green, width=2, style=line.style_dashed, force_overlay=true)

        label.new(bar_index - lookback, pr_low, "Bullish Div", 
             textcolor=color.white, color=color.green, style=label.style_label_up, force_overlay=true)
    
    last_pr_low := pr_low
    last_pr_low_idx := bar_index - lookback
    last_m_low := m_low

// Alert Cons
alertcondition(triggerBuy,  title="Momentum Map: BUY Signal",  message="3D Momentum Alignment: Bullish [{{close}}]")
alertcondition(triggerSell, title="Momentum Map: SELL Signal", message="3D Momentum Alignment: Bearish [{{close}}]")
bool alertBullDiv = not na(pr_low) and pr_low < last_pr_low and m_low > last_m_low
bool alertBearDiv = not na(pr_high) and pr_high > last_pr_high and m_high < last_m_high
alertcondition(alertBullDiv, title="Momentum Map: Bullish DIV", message="Bullish Divergence Detected on {{ticker}}")
alertcondition(alertBearDiv, title="Momentum Map: Bearish DIV", message="Bearish Divergence Detected on {{ticker}}")
alertcondition(triggerBuy or triggerSell or alertBullDiv or alertBearDiv, title="Momentum Map: ANY Signal", message="Momentum Map Update for {{ticker}} at {{close}}")
````
