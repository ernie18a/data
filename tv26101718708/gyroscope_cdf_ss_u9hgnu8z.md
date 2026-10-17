# Gyroscope CDF [SS]

- url: https://www.tradingview.com/script/u9hGnu8Z-Gyroscope-CDF-SS/
- type: indicator
- pine_id: PUB;35216071d8c94310a1d55dff4c67bd37
- version: 1.0

## Description

Started as a "can I actually pull off 3D on a 2D chart with an animation that syncs to an actual session" experiment,  a rotating gyroscope built from real 3D math (yaw/pitch camera, rotation matrices, a projected unit ring) rendered entirely with polylines and chart points. No image, no library trick, just geometry.

Turns out the shape wasn't just decoration, it's a genuinely useful way to look at intraday range.

[b]How it works:[/b]

Each ring is anchored to the daily SMA(14) and daily stdev(14), scaled to the standard normal CDF confidence levels: 1.00σ (~68%), 1.28σ (~80%), and 1.96σ (~95%). So instead of a flat horizontal band, you get three rotating rings that visually collapse toward the SMA as they tumble, and stretch out to their true deviation width at the widest point of the rotation. The whole thing is session-anchored (9:30–16:00), so the gyroscope's width tracks the actual regular session rather than an arbitrary bar count.

[b]How to read it:[/b]

Center pole + "SMA" label = the daily mean price is being measured against.

Aqua / orange / red rings = 68% / 80% / 95% deviation bands off that mean.

The rotation itself isn't the signal, it's there so you can see all three bands true radius at a glance instead of three overlapping flat lines. When price pushes toward the outer (red) ring intraday, you're looking at a genuinely stretched move relative to the last two weeks of daily closes. I have also added labels that denote the range confidence levels that each band represents. 

Built mostly because a static band chart is easy to glance past, and a rotating one isn't, but it held up as an actual way to gauge whether an intraday move is ordinary noise or something worth paying attention to relative to the recent daily range.

Settings let you tune camera yaw/pitch, session fill (how close the rings reach 9:30/16:00), and ring resolution.

Its currently anchored to intra-day sessions only (daily), but will likely work to expand capability to larger sessions like weekly/monthly in the future and push the update.

As always, hope you enjoy and safe trades everyone!

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
indicator("Gyroscope CDF [SS]", overlay = true, max_polylines_count = 100, max_labels_count = 100)


type Point3D
    float x
    float y
    float z

type Camera
    int   anchorTime
    float anchorY
    float yaw
    float pitch
    float scaleX

// Projects a 3D point onto the 2D chart.

method project(Camera cam, Point3D p, float scaleY) =>
    // Global Camera Yaw (Rotation around Y axis)
    float cy = math.cos(cam.yaw)
    float sy = math.sin(cam.yaw)
    float x1 = p.x * cy - p.z * sy
    float z1 = p.x * sy + p.z * cy
    
    //pitch 
    float cp = math.cos(cam.pitch)
    float sp = math.sin(cam.pitch)
    float y2 = p.y * cp - z1 * sp
    float z2 = p.y * sp + z1 * cp
    
    // chart coordinates 
    int timeOffset = int(x1 * cam.scaleX)
    
    chart.point.from_time(cam.anchorTime + timeOffset, cam.anchorY + y2 * scaleY)

// Rotates pitch / yaw 
f_rotate(Point3D p, float ax, float ay, float az) =>
    // Rotate X (Pitch)
    float y1 = p.y * math.cos(ax) - p.z * math.sin(ax)
    float z1 = p.y * math.sin(ax) + p.z * math.cos(ax)
    // Rotate Y (Yaw)
    float x2 = p.x * math.cos(ay) + z1 * math.sin(ay)
    float z2 = -p.x * math.sin(ay) + z1 * math.cos(ay)
    // Rotate Z (Roll)
    float x3 = x2 * math.cos(az) - y1 * math.sin(az)
    float y3 = x2 * math.sin(az) + y1 * math.cos(az)
    Point3D.new(x3, y3, z2)

// Generates a unit circle in 3D space and applies local gimbal rotation
f_generateUnitRing(float ax, float ay, float az, int segments) =>
    array<Point3D> pts = array.new<Point3D>()
    for i = 0 to segments - 1
        float t = 2.0 * math.pi * i / segments
        float px = math.cos(t)
        float py = math.sin(t)
        float pz = 0.0
        pts.push(f_rotate(Point3D.new(px, py, pz), ax, ay, az))
    pts

// cdf data 
[d_sma, d_std, d_time, d_time_close] = request.security(syminfo.tickerid, "1D", [ta.sma(close, 14), ta.stdev(close, 14), time, time_close], lookahead = barmerge.lookahead_on)

float dev68 = d_std * 1.00 
float dev80 = d_std * 1.28 
float dev95 = d_std * 1.96 


int mid_session_time = not na(d_time) and not na(d_time_close) ? int(math.avg(d_time, d_time_close)) : na

float sessionHalfMs = not na(d_time) and not na(d_time_close) ? (d_time_close - d_time) / 2.0 : na


float camYaw   = input.float(15.0, "Camera Yaw (deg)", group="3D Settings") * math.pi / 180
float camPitch = input.float(20.0, "Camera Pitch (deg)", group="3D Settings") * math.pi / 180
float sessionFill = input.float(0.9, "Session Fill (0-1)", minval = 0.1, maxval = 1.0, group="3D Settings", tooltip="How far the rings' widest swing reaches toward the session open/close. 1.0 = touches 9:30/16:00 exactly.")
int   segs     = input.int(40, "Ring Segments (Resolution)", group="3D Settings")


f_drawRing(Camera cam, array<Point3D> unitRing, float priceDev, color col, string lblText, array<polyline> pArr, array<label> lArr) =>
    array<chart.point> pts = array.new<chart.point>()
    float maxY = -1e9
    int maxTime = 0
    
    for p in unitRing
        chart.point cp = cam.project(p, priceDev)
        pts.push(cp)
        if cp.price > maxY
            maxY := cp.price
            maxTime := cp.time
  
    pArr.push(polyline.new(pts, closed = true, xloc = xloc.bar_time, line_color = col, line_width = 2))
    lArr.push(label.new(chart.point.from_time(maxTime, maxY), lblText, xloc = xloc.bar_time, color=color.new(col, 80), textcolor=color.white, style=label.style_label_down, size=size.small))

var array<polyline> trackedPolys = array.new<polyline>()
var array<label>    trackedLabels = array.new<label>()
var array<line>     trackedLines  = array.new<line>()


if barstate.islast and not na(mid_session_time) and not na(d_sma) and not na(sessionHalfMs)
    

    if trackedPolys.size() > 0
        for p in trackedPolys
            p.delete()
        trackedPolys.clear()
        
    if trackedLabels.size() > 0
        for l in trackedLabels
            l.delete()
        trackedLabels.clear()
        
    if trackedLines.size() > 0
        for ln in trackedLines
            ln.delete()
        trackedLines.clear()

    Camera cam = Camera.new(mid_session_time, d_sma, camYaw, camPitch, sessionHalfMs * sessionFill)

    float t1 = bar_index * 0.03
    float t2 = bar_index * 0.04
    float t3 = bar_index * 0.02

    array<Point3D> ring68 = f_generateUnitRing(t1, t1 * 1.2, 0, segs)
    array<Point3D> ring80 = f_generateUnitRing(-t2 * 0.8, t2, t2 * 0.5, segs)
    array<Point3D> ring95 = f_generateUnitRing(t3 * 1.1, -t3 * 0.9, t3 * 1.5, segs)

    chart.point poleTop = chart.point.from_time(cam.anchorTime, cam.anchorY + dev95 * 1.15)
    chart.point poleBot = chart.point.from_time(cam.anchorTime, cam.anchorY - dev95 * 1.15)
    
    trackedLines.push(line.new(poleBot, poleTop, xloc = xloc.bar_time, color=color.new(color.gray, 50), style=line.style_dotted, width=2))
    trackedLabels.push(label.new(chart.point.from_time(cam.anchorTime, cam.anchorY), "SMA", xloc = xloc.bar_time, color=color.new(color.white, 80), textcolor=color.white, style=label.style_label_center, size=size.small))

    f_drawRing(cam, ring68, dev68, color.new(color.aqua, 10), "68%", trackedPolys, trackedLabels)
    f_drawRing(cam, ring80, dev80, color.new(color.orange, 10), "80%", trackedPolys, trackedLabels)
    f_drawRing(cam, ring95, dev95, color.new(color.red, 10), "95%", trackedPolys, trackedLabels)
````
