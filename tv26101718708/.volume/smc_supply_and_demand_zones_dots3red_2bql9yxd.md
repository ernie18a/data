# SMC Supply and Demand Zones [Dots3Red]

- url: https://www.tradingview.com/script/2BqL9Yxd-SMC-Supply-and-Demand-Zones-Dots3Red/
- type: indicator
- pine_id: PUB;b178cc040255474f94951236ff00f427
- version: 1.0

## Description

[b]SMC Supply & Demand Zones [Dots3Red][/b]
This script automatically detects and visualizes [b]Smart Money Concept[/b] (SMC) [b]Supply and Demand[/b][i][/i] zones using a three-factor confirmation model: [i]base consolidation, impulse breakout, and volume surge[/i].

[b]How zone detection works[/b]
The indicator looks for a tight consolidation base (price range below ATR threshold) followed by a strong impulsive candle breaking out of that base with above-average volume. The direction of the breakout determines the zone type — bullish breakout creates a Demand zone, bearish breakout creates a Supply zone. The base range itself becomes the zone, as that is where institutional activity occurred.

[b]Zone scoring (max 5)[/b]
Each zone is scored at birth based on three factors:
[list]
[*]Base tightness — how compressed the consolidation was (1pt)
[*]Impulse strength — how strong the breakout candle body was relative to ATR (2pts)
[*]Volume confirmation — whether breakout volume exceeded the MA threshold (2pts)
[/list]
Higher scoring zones render with stronger fill intensity.

[b]Visual features[/b]
[list]
[*]Supply and Demand zones themselves
[*]Inactive zones (invalidated or max touches reached) can be shown or hidden via toggle
[/list]
[b]Proximity dashboard[/b]
A live table in the top-right corner shows all active zones ranked by distance from current price. Each zone displays its type, score, distance in ATR units, and status — INSIDE (gold), NEAR (orange), or AWAY (gray).

[b]Zone invalidation[/b]
A zone is considered broken when price closes through it (configurable to wick-based) or when it has been touched too many times — both signals that the institutional order block has been absorbed.

[b]Settings[/b]
All key parameters are tunable — [b]base length, ATR multipliers, volume sensitivity, touch limits, score threshold, and proximity distance[/b][i][/i] — making the indicator adaptable to any instrument and timeframe.

[image]https://www.tradingview.com/x/KjAyeRv3/[/image]

## Source Code

````pine
//@version=6
indicator("SMC Supply and Demand Zones [Dots3Red]", overlay = true, max_boxes_count = 500, max_labels_count = 500)

var color colorBg      = #131722
var color colorBar     = #b2b5be

var color C_DEMAND = #00FFFF
var color C_SUPPLY = #FF00FF
var color C_INACTIVE = #787b86
var color boBgColor = na


baseLen           = input.int(2,   "Base Length",                minval = 1, maxval = 6)
atrLen            = input.int(14,  "ATR Length",                 minval = 1)
impulseAtrMult    = input.float(0.8,"Impulse Body > ATR x",      minval = 0.1, step = 0.1)
baseAtrMaxMult    = input.float(0.8,"Base Range < ATR x",        minval = 0.1, step = 0.1)
volLen            = input.int(15,  "Volume MA Length",           minval = 1)
volMult           = input.float(0.8,"Departure Volume > Vol MA x", minval = 0.1, step = 0.1)  // 
maxTouches        = input.int(6,   "Max Touches Before Hiding",  minval = 1, maxval = 20)
minScoreToShow    = input.int(2,   "Minimum Score To Show",      minval = 1, maxval = 10)
extendBars        = input.int(50, "Box Extend Bars",            minval = 10, maxval = 1000)
showLabels        = input.bool(true,"Show Strength Labels")
useWickTouch      = input.bool(true,"Count Wick Touches")
invalidateOnClose = input.bool(true,"Invalidate On Close Through Zone")
showOffZones      = input.bool(false, "Show Offline Zones")
proximityAtr      = input.float(0.5, "Proximity Alert ATR Distance", minval = 0.1, step = 0.1, group = "Alerts")

atrValue = ta.atr(atrLen)
volMA    = ta.sma(volume, volLen)

type Zone
    float top
    float bottom
    int   leftBar
    int   rightBar
    bool  isDemand
    int   touches
    int   score
    bool  active
    box   bx
    label lb
    int   boBar

var zones = array.new<Zone>()

//proximityAlert Table
var bool nearDemand = false
var bool nearSupply = false
nearDemand := false
nearSupply := false

var table proxTable = table.new(position.top_right, 3, 10,
     bgcolor      = color.new(#131722, 10),
     border_color = color.new(#b2b5be, 70),
     border_width = 1,
     frame_color  = color.new(#b2b5be, 50),
     frame_width  = 1)



f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_x, _max))

f_baseHigh(_len) => ta.highest(high, _len)[1]  
f_baseLow(_len)  => ta.lowest(low,  _len)[1]

f_baseRange(_len) =>
    f_baseHigh(_len) - f_baseLow(_len)

f_isBullImpulse(_atr, _mult) =>
    close > open and (close - open) > _atr * _mult

f_isBearImpulse(_atr, _mult) =>
    close < open and (open - close) > _atr * _mult

f_highVolume(_volMA, _mult) =>
    volume > _volMA * _mult

f_scoreZone(_tightBase, _strongImpulse, _highVol) =>   
    int score = 0
    score += _tightBase      ? 1 : 0
    score += _strongImpulse  ? 2 : 0
    score += _highVol        ? 2 : 0
    score

f_zoneColor(_isDemand, _score) =>
    transp = 88 - f_clamp(_score * 2, 0, 50)
    _isDemand ? color.new(C_DEMAND, transp) : color.new(C_SUPPLY, transp)

f_borderColor(_isDemand) =>
    _isDemand ? color.new(C_DEMAND, 40) : color.new(C_SUPPLY, 40)

f_trimZones() =>
    if array.size(zones) > 20
        old = array.shift(zones)
        box.delete(old.bx)
        if not na(old.lb)
            label.delete(old.lb)

f_updateAlertTable(_table, _zones, _atrValue, _proximityAtr)=>
    table.clear(_table, 0, 0, 2, 9)

    table.cell(_table, 0, 0, "ZONE",   text_color = color.new(#b2b5be, 1), text_size = size.small, bgcolor = color.new(#131722, 10))
    table.cell(_table, 1, 0, "DIST",   text_color = color.new(#b2b5be, 1), text_size = size.small, bgcolor = color.new(#131722, 10))
    table.cell(_table, 2, 0, "STATUS", text_color = color.new(#b2b5be, 1), text_size = size.small, bgcolor = color.new(#131722, 10))

    int row = 1
    if array.size(_zones) > 0
        for i = 0 to array.size(_zones) - 1
            z = array.get(_zones, i)
            if z.active and row <= 9
                distToTop  = math.abs(close - z.top)
                distToBot  = math.abs(close - z.bottom)
                withinZone = close >= z.bottom and close <= z.top
                dist       = math.min(distToTop, distToBot)
                nearby     = dist < _atrValue * _proximityAtr

                status    = withinZone ? "INSIDE" : nearby ? "NEAR" : "AWAY"
                statColor = withinZone ? color.new(#FFD700, 0) :
                             nearby    ? color.new(#FF6600, 0) :
                                         color.new(#b2b5be, 40)

                zoneClr = z.isDemand ? C_DEMAND : C_SUPPLY
                zoneTag = z.isDemand ? "D  S:" + str.tostring(z.score) : "S  S:" + str.tostring(z.score)
                distTxt = str.tostring(math.round(dist / _atrValue * 10) / 10) + " ATR"

                table.cell(_table, 0, row, zoneTag, text_color = zoneClr,   text_size = size.small, bgcolor = color.new(#131722, 10))
                table.cell(_table, 1, row, distTxt, text_color = statColor, text_size = size.small, bgcolor = color.new(#131722, 10))
                table.cell(_table, 2, row, status,  text_color = statColor, text_size = size.small, bgcolor = color.new(#131722, 10))
                row += 1


baseHigh  = f_baseHigh(baseLen)
baseLow   = f_baseLow(baseLen)
baseRange = baseHigh - baseLow

tightBase   = baseRange < atrValue * baseAtrMaxMult
bullImpulse = f_isBullImpulse(atrValue, impulseAtrMult)
bearImpulse = f_isBearImpulse(atrValue, impulseAtrMult)
highVol     = f_highVolume(volMA, volMult)

newDemand = tightBase and bullImpulse and highVol and close > baseHigh
newSupply = tightBase and bearImpulse and highVol and close < baseLow

f_createZone(_top, _bottom, _isDemand, _score) =>
    clr  = f_zoneColor(_isDemand, _score)
    bclr = f_borderColor(_isDemand)
    bx   = box.new(
         left         = bar_index - baseLen,
         top          = _top,
         right        = bar_index + extendBars,
         bottom       = _bottom,
         bgcolor      = clr,
         border_color = bclr)
    lb = label(na)
    if showLabels
        txt = (_isDemand ? "Demand " : "Supply ") + "S:" + str.tostring(_score)
        lb := label.new(bar_index, _isDemand ? _bottom : _top, txt,
             style     = _isDemand ? label.style_label_up : label.style_label_down,
             textcolor = color.white,
             color     = bclr)
    Zone.new(_top, _bottom, bar_index - baseLen, bar_index + extendBars, _isDemand, 0, _score, true, bx, lb, bar_index)

if newDemand
    score = f_scoreZone(tightBase, bullImpulse, highVol)
    if score >= minScoreToShow
        array.push(zones, f_createZone(baseHigh, baseLow, true, score))
        f_trimZones()

if newSupply
    score = f_scoreZone(tightBase, bearImpulse, highVol)
    if score >= minScoreToShow
        array.push(zones, f_createZone(baseHigh, baseLow, false, score))
        f_trimZones()

f_zoneTouched(_z) =>
    if _z.isDemand
        useWickTouch ? (low <= _z.top and high >= _z.bottom) : (close <= _z.top and close >= _z.bottom)
    else
        useWickTouch ? (high >= _z.bottom and low <= _z.top) : (close >= _z.bottom and close <= _z.top)

f_wasOutside(_z) =>
    if _z.isDemand
        low[1] > _z.top          
    else
        high[1] < _z.bottom      

f_zoneInvalidated(_z) =>
    if invalidateOnClose
        _z.isDemand ? close < _z.bottom : close > _z.top
    else
        _z.isDemand ? low < _z.bottom : high > _z.top

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)

        if z.active
            box.set_right(z.bx, bar_index + extendBars)
            touched      = bar_index > z.leftBar + baseLen and f_zoneTouched(z)
            wasOutside   = f_wasOutside(z)

            distToTop    = math.abs(close - z.top)
            distToBottom = math.abs(close - z.bottom)
            withinZone   = close >= z.bottom and close <= z.top
            nearby       = math.min(distToTop, distToBottom) < atrValue * proximityAtr

            if (nearby or withinZone)
                if z.isDemand
                    nearDemand := true
                else                
                    nearSupply := true

            if touched and wasOutside
                z.touches += 1

            invalid        = f_zoneInvalidated(z)
            tooManyTouches = z.touches >= maxTouches

            if invalid or tooManyTouches  
                z.active := false
                if showOffZones
                    box.set_bgcolor(z.bx, color.new(C_INACTIVE, 90))
                    box.set_border_color(z.bx, color.new(C_INACTIVE, 50))
                    box.set_extend(z.bx, extend.none) 
                    box.set_right(z.bx, bar_index)
                    if not na(z.lb)                         
                        label.set_text(z.lb, (z.isDemand ? "D " : "S ") + "OFF")
                        label.set_textcolor(z.lb, C_INACTIVE)
                else
                    box.delete(z.bx)
                    if not na(z.lb)
                        label.delete(z.lb)
                        z.lb := na
            else
                if not na(z.lb)                    

                    label.set_text(z.lb, (z.isDemand ? "D " : "S ") + "« " + str.tostring(z.score) + " | " + str.tostring(z.touches) + " »")
                    label.set_textcolor(z.lb, z.isDemand ? C_DEMAND : C_SUPPLY)
                    label.set_color(z.lb, color.new(color.black, 100))

            array.set(zones, i, z)   

f_updateAlertTable(proxTable, zones, atrValue, proximityAtr)


barcolor(colorBar)
bgcolor(colorBg)
````
