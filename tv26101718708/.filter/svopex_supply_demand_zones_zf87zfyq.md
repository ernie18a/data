# Svopex Supply & Demand Zones

- url: https://www.tradingview.com/script/ZF87zFYQ-Svopex-Supply-Demand-Zones/
- type: indicator
- pine_id: PUB;4554e400f23c4a4a9388146a37d2adbf
- version: 7.0

## Description

Automatically detects and plots Supply and Demand zones using 4H price action — works on any chart timeframe.
                                                                                                                                                                                          
This indicator draws the classic Supply & Demand zones that institutional traders watch: areas
  where price consolidated (a "base") and then exploded away sharply. These zones often act as
powerful support/resistance when price returns.                                               
                                                        
- Supply zones (red) — where price consolidated, then dropped sharply → expect selling     
pressure on retest.
- Demand zones (green) — where price consolidated, then rallied sharply → expect buying    
pressure on retest.                                                                           
- Zones extend to the right and automatically freeze the moment price closes through them, so
your chart stays clean.                                                                       
- Detection always runs on the 4H timeframe (configurable), regardless of the chart you're
viewing — so zones stay consistent whether you're on 15m, 1H, 4H or Daily.                    
                                                        
How it works                                                                                  
                                                        
A zone is formed by the textbook 4-candle patterns:                                           
  
- DBR (Drop → Base → Rally) → Demand zone                                                     
- RBR (Rally → Base → Rally) → Demand zone             
- RBD (Rally → Base → Drop) → Supply zone                                                     
- DBD (Drop → Base → Drop) → Supply zone
                                                                                              
Detection logic:                                       
1. Base candle = body smaller than Base body ≤ ATR × (default 0.5 × ATR).                     
2. Explosive candle = body larger than Explosive body ≥ ATR × (default 1.5 × ATR).            
3. When 1–3 base candles are followed by an explosive candle, the base range becomes a zone.
4. The zone is drawn from the base's start time, with top = highest base high and bottom =    
lowest base low.                                                                              
5. Zones are non-repainting — detection uses the previous confirmed HTF bar (request.security 
with lookahead_off + [1]).                                                                    
                                                         
Inputs                                                                                        
                                                                                              
  • Zone Timeframe — default 240 (4H). Timeframe used for zone detection.                                                                                                                      
  • Max base candles — default 3. Maximum base candles allowed before the explosive move.                                                                                                       
  • Base body ≤ ATR × — default 0.5. Base candle body must be smaller than this × ATR.                                                                                                          
  • Explosive body ≥ ATR × — default 1.5. Breakout candle body must be larger than this × ATR.                                                           
  • ATR length — default 14. Reference volatility for base/explosive classification.                                                                                                            
  • Supply / Demand fill — default red / green @ 80% transparency. Zone colors, fully           
  customizable.                                                                                                                                                                                 
  • Show labels — default ON. Displays "Supply" / "Demand" text labels.                           
  • Max active zones per side — default 20. FIFO cap to keep the chart tidy.   

How to use it                                                                                 
  
- Swing / day trading: Watch for price to retest a zone and look for rejection candles /      
reversal signals.                                      
- Confluence: Zones overlapping with POC, VAH/VAL, LVN, prior session high/low or             
psychological levels are significantly stronger.                                              
- Trend continuation: In an uptrend, buy retests of Demand zones; in a downtrend, sell retests
  of Supply zones.                                                                             
- Broken zones: Once price closes through a zone, the box is frozen — a broken Supply often
flips into Demand (and vice versa).                                                           
                                                        
Tuning guide                                                                                  
                                                        
- Too many zones? Increase Explosive body ≥ ATR × to 2.0 and/or lower Base body ≤ ATR × to    
0.3.                                                   
- Not enough zones / high-volatility asset? Raise Max base candles to 5–6 and lower Explosive 
body ≥ ATR × to 1.2.                                                                          
- Forex / indices / futures → defaults work well.
- Crypto → try Explosive body ≥ ATR × = 2.0 for cleaner signals.                              
                                                                                              
Notes                                                                                         
                                                                                              
- Detection is based on candle bodies, not wicks — long-wick base candles may occasionally    
produce wider zones than expected.
- Zone break is measured on close, not wick — intrabar spikes through a zone will NOT         
invalidate it (by design — filters noise).                                                    
- Zones appear only after the next 4H candle confirms → non-repainting, but with one HTF-bar
delay.                                                                                        
                                                                                                                                              
Open-source. Feel free to fork, tweak, and make it your own. Feedback welcome in the comments.

## Source Code

````pine
//@version=5
indicator("Svopex Supply & Demand Zones", "Svopex S&D", overlay=true, max_boxes_count=500, max_labels_count=500)

useChartTF = input.bool(true, "Use chart timeframe", group="Zone timeframe", tooltip="ON = detect zones on chart TF (follows chart when you switch timeframe). OFF = use the 'Zone Timeframe' setting below.")
htf         = input.timeframe("240", "Zone Timeframe", group="Zone timeframe", tooltip="Timeframe used for zone detection (default 4H). Ignored when 'Use chart timeframe' is ON.")
baseMax     = input.int(3, "Max base candles", minval=1, maxval=6)
baseBodyPct = input.float(0.5, "Base body ≤ ATR ×", step=0.1, minval=0.1)
explMult    = input.float(1.5, "Explosive body ≥ ATR ×", step=0.1, minval=0.5)
atrLen      = input.int(14, "ATR length", minval=2)

grpBreak    = "Zone Break"
useWicks    = input.bool(true, "Include wicks (else body only)", group=grpBreak)
breakPct    = input.int(0, "Break threshold (%)", minval=0, maxval=100, group=grpBreak)

grpVis      = "Visuals"
supplyCol   = input.color(color.new(color.red,   80), "Supply fill", group=grpVis)
demandCol   = input.color(color.new(color.green, 80), "Demand fill", group=grpVis)
showBorder  = input.bool(false, "Show zone border", group=grpVis, tooltip="ON = zone ma viditelny okraj. OFF = jen fill.")
showLbl     = input.bool(false, "Show labels", group=grpVis)
maxZones    = input.int(20, "Max active zones per side", minval=1, maxval=100, group=grpVis)

effectiveTf = useChartTF ? timeframe.period : htf

f_detect() =>
    atr  = ta.atr(atrLen)
    body = math.abs(close - open)
    isBase     = body < baseBodyPct * atr
    isExplUp   = (close - open) >  explMult * atr
    isExplDown = (open  - close) >  explMult * atr
    var int   baseCount = 0
    var float baseH     = na
    var float baseL     = na
    var int   baseT     = na
    int   sig = 0
    float zH  = na
    float zL  = na
    int   zT  = na
    if isBase
        if baseCount == 0
            baseH := high
            baseL := low
            baseT := time
        else
            baseH := math.max(baseH, high)
            baseL := math.min(baseL, low)
        baseCount += 1
    else if baseCount >= 1 and baseCount <= baseMax and isExplUp
        sig := 2
        zH  := baseH
        zL  := baseL
        zT  := baseT
        baseCount := 0
        baseH := na
        baseL := na
        baseT := na
    else if baseCount >= 1 and baseCount <= baseMax and isExplDown
        sig := 1
        zH  := baseH
        zL  := baseL
        zT  := baseT
        baseCount := 0
        baseH := na
        baseL := na
        baseT := na
    else
        baseCount := 0
        baseH := na
        baseL := na
        baseT := na
    [sig, zH, zL, zT]

f_detect_prev() =>
    [s, h, l, t] = f_detect()
    [s[1], h[1], l[1], t[1]]

[htfSig, htfZH, htfZL, htfZT] = request.security(syminfo.tickerid, effectiveTf, f_detect_prev(), lookahead=barmerge.lookahead_off)

var box[]   supplyBoxes = array.new<box>()
var box[]   demandBoxes = array.new<box>()

freshSig = htfSig != 0 and not na(htfZT) and nz(htfZT, 0) != nz(htfZT[1], 0)

supBorder = color.new(color.red, 40)
demBorder = color.new(color.green, 40)

supBorderCol = showBorder ? supBorder : na
demBorderCol = showBorder ? demBorder : na
borderW      = showBorder ? 1 : 0

if freshSig and htfSig == 1
    b = box.new(htfZT, htfZH, time, htfZL, border_color=supBorderCol, border_width=borderW, bgcolor=supplyCol, extend=extend.right, xloc=xloc.bar_time)
    if showLbl
        label.new(htfZT, htfZH, "Supply", xloc=xloc.bar_time, style=label.style_label_down, color=supBorder, textcolor=color.white, size=size.small)
    array.push(supplyBoxes, b)
    if array.size(supplyBoxes) > maxZones
        box.delete(array.shift(supplyBoxes))

if freshSig and htfSig == 2
    b = box.new(htfZT, htfZH, time, htfZL, border_color=demBorderCol, border_width=borderW, bgcolor=demandCol, extend=extend.right, xloc=xloc.bar_time)
    if showLbl
        label.new(htfZT, htfZL, "Demand", xloc=xloc.bar_time, style=label.style_label_up, color=demBorder, textcolor=color.white, size=size.small)
    array.push(demandBoxes, b)
    if array.size(demandBoxes) > maxZones
        box.delete(array.shift(demandBoxes))

f_checkBreak(array<box> arr, bool isSupply) =>
    hiProbe = useWicks ? high : math.max(open, close)
    loProbe = useWicks ? low  : math.min(open, close)
    pct = breakPct / 100.0
    i = 0
    while i < array.size(arr)
        bx   = array.get(arr, i)
        top  = box.get_top(bx)
        bot  = box.get_bottom(bx)
        hgt  = top - bot
        broken = false
        if isSupply
            thr = bot + hgt * pct
            broken := hiProbe >= thr
        else
            thr = top - hgt * pct
            broken := loProbe <= thr
        if broken
            box.set_right(bx, time)
            box.set_extend(bx, extend.none)
            array.remove(arr, i)
            i := i
        else
            i := i + 1

if barstate.isconfirmed
    f_checkBreak(supplyBoxes, true)
    f_checkBreak(demandBoxes, false)
````
