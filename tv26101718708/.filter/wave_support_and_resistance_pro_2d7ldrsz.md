# Wave Support and Resistance Pro

- url: https://www.tradingview.com/script/2d7lDRsz-Wave-Support-and-Resistance-Pro/
- type: indicator
- pine_id: PUB;80a5cb5c9b304374b6f86813065888d2
- version: 3.0

## Description

Copy and paste the level that is shared every morning in the Discord channel of Market Wave

## Source Code

````pine
//@version=6
indicator("Wave Support and Resistance Pro v2", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================
// AUTO SYMBOL DETECTION
// ============================================================
symbolName = syminfo.ticker

// ============================================================
// LEVEL INPUTS  ->  paste straight from the Market Wave bot
// ============================================================
gLevels = "LEVELS (paste from Market Wave)"
supportText    = input.string("", "Support Levels",    group=gLevels, tooltip="Paste the 'Support (Next 5 Levels Down)' numbers, comma-separated. These alert when price drops THROUGH them.")
resistanceText = input.string("", "Resistance Levels", group=gLevels, tooltip="Paste the 'Resistance (Next 5 Levels Up)' numbers, comma-separated. These alert when price rises THROUGH them.")
keyLevel       = input.float(0.0, "Key Level (0 = none, MANUAL)", group=gLevels, tooltip="Manually typed. If it matches a pasted level it just recolors that one as the key; otherwise it draws its own line.")

// ============================================================
// AUTO LEVELS  ->  previous day / week high & low
// ============================================================
gAuto = "AUTO LEVELS (prev day / week)"
showPDH = input.bool(false, "Show Prev Day High",  inline="PDH", group=gAuto)
alrtPDH = input.bool(false, "Alert",               inline="PDH", group=gAuto)
showPDL = input.bool(false, "Show Prev Day Low",   inline="PDL", group=gAuto)
alrtPDL = input.bool(false, "Alert",               inline="PDL", group=gAuto)
showPWH = input.bool(false, "Show Prev Week High", inline="PWH", group=gAuto)
alrtPWH = input.bool(false, "Alert",               inline="PWH", group=gAuto)
showPWL = input.bool(false, "Show Prev Week Low",  inline="PWL", group=gAuto)
alrtPWL = input.bool(false, "Alert",               inline="PWL", group=gAuto)
colPDH  = input.color(color.orange, "PDH Color", group=gAuto)
colPDL  = input.color(color.aqua,   "PDL Color", group=gAuto)
colPWH  = input.color(color.purple, "PWH Color", group=gAuto)
colPWL  = input.color(color.blue,   "PWL Color", group=gAuto)

// ============================================================
// STYLE
// ============================================================
gStyle = "STYLE"
supportColor    = input.color(color.new(color.green, 0), "Support Color",     group=gStyle)
resistanceColor = input.color(color.new(color.red, 0),   "Resistance Color",  group=gStyle)
keyColor        = input.color(color.yellow,              "Key Level Color",   group=gStyle)
labelTextColor  = input.color(color.white, "Label Text Color",  group=gStyle)
labelBgColor    = input.color(color.black, "Label Background",   group=gStyle)
regularWidth    = input.int(1, "Regular Width", minval=1, maxval=5, group=gStyle)
keyWidth        = input.int(3, "Key Width",     minval=1, maxval=5, group=gStyle)
showLabels      = input.bool(true, "Show Labels", group=gStyle)

// ============================================================
// ALERTS
// ============================================================
gAlert = "ALERTS"
alertSupport    = input.bool(true, "Alert on Support levels (price drops THROUGH)",  group=gAlert)
alertResistance = input.bool(true, "Alert on Resistance levels (price rises THROUGH)", group=gAlert)

// ============================================================
// ORDER BLOCKS + MARKET STRUCTURE
// ============================================================
gOB = "ORDER BLOCKS"
showOB     = input.bool(true,  "Show Order Blocks", group=gOB)
obSwingLen = input.int(5, "Swing Length (structure sensitivity)", minval=1, maxval=50, group=gOB, tooltip="Higher = only bigger swings count as a break of structure. Raise this if you see too many BOS/CHoCH.")
obScan     = input.int(20, "Lookback to find the block candle", minval=2, maxval=100, group=gOB)
obMaxCount = input.int(4, "Max Order Blocks shown", minval=1, maxval=20, group=gOB)
obUseBody  = input.bool(true, "Tight blocks (use candle body)", group=gOB, tooltip="On: box covers only the candle body (open-close) for clean thin zones like LuxAlgo. Off: full high-low range.")
obNoOverlap = input.bool(true, "Hide overlapping blocks", group=gOB, tooltip="Skip a new block if it sits on top of an existing one, so zones don't stack up.")
obMaxHtAtr = input.float(0.5, "Max block height (x ATR, 0 = no cap)", minval=0, maxval=10, step=0.1, group=gOB, tooltip="Caps how tall a block can be so one big candle can't flood the chart. Lower = thinner zones like LuxAlgo. 0 turns the cap off.")
obMitWick  = input.bool(false, "Mitigate on wick (else close)", group=gOB, tooltip="On: a block is broken as soon as a wick pierces it. Off: needs a close beyond it.")
obDeleteMit = input.bool(true, "Remove blocks once mitigated", group=gOB, tooltip="Off keeps them on the chart greyed out.")
obStructLbl = input.bool(true,  "Show BOS / CHoCH labels", group=gOB, tooltip="BOS = break continuing the trend. CHoCH = break that flips the trend. Bullish breaks draw green, bearish red.")
obSwingLbl  = input.bool(true,  "Show swing labels (HH/HL/LH/LL)", group=gOB)
msKeep      = input.int(20, "Structure markers to keep", minval=1, maxval=100, group=gOB, tooltip="How many recent swing labels and BOS/CHoCH markers to keep on the chart.")
obShowVol   = input.bool(true,  "Show volume on blocks", group=gOB, tooltip="Shows estimated volume traded in the block + the buy/sell share. Estimated from a lower timeframe (TradingView has no true bid/ask volume).")
obLTF       = input.timeframe("1", "Volume detail timeframe", group=gOB, tooltip="Lower timeframe used to estimate buy vs sell volume. Must be LOWER than your chart timeframe (e.g. 1 on a 5m chart).")
obBullColor = input.color(color.new(color.green, 85), "Bullish Block",  group=gOB)
obBearColor = input.color(color.new(color.red, 85),   "Bearish Block",  group=gOB)

// ============================================================
// PARSING HELPER
// ============================================================
parseLevels(string raw) =>
    out = array.new_float()
    cleaned = str.replace_all(raw, "\n", ",")
    cleaned := str.replace_all(cleaned, "$", "")
    if str.length(str.trim(cleaned)) > 0
        parts = str.split(cleaned, ",")
        for i = 0 to array.size(parts) - 1
            v = str.tonumber(str.trim(array.get(parts, i)))
            if not na(v)
                array.push(out, v)
    out

// ============================================================
// STORAGE
// ============================================================
type Lvl
    line  ln
    float val
    bool  key

var Lvl[]   lvlArr        = array.new<Lvl>()
var label[] labelsArr      = array.new_label()
var float[] supportVals    = array.new_float()
var float[] resistanceVals = array.new_float()

var string prevSupport = ""
var string prevResist  = ""
var float  prevKey     = na
var bool   initialized = false

needsRefresh = not initialized or supportText != prevSupport or resistanceText != prevResist or keyLevel != prevKey

if needsRefresh
    if array.size(lvlArr) > 0
        for i = 0 to array.size(lvlArr) - 1
            line.delete(array.get(lvlArr, i).ln)
        array.clear(lvlArr)
    if array.size(labelsArr) > 0
        for i = 0 to array.size(labelsArr) - 1
            label.delete(array.get(labelsArr, i))
        array.clear(labelsArr)
    array.clear(supportVals)
    array.clear(resistanceVals)

    // ---- SUPPORT (down-side) ----
    supArr = parseLevels(supportText)
    for i = 0 to array.size(supArr) - 1
        lvl   = array.get(supArr, i)
        isKey = keyLevel > 0 and math.abs(lvl - keyLevel) <= syminfo.mintick
        wid   = isKey ? keyWidth : regularWidth
        ln    = line.new(bar_index, lvl, bar_index + 1, lvl, extend=extend.both, color=supportColor, width=wid)
        array.push(lvlArr, Lvl.new(ln, lvl, isKey))
        array.push(supportVals, lvl)
        if showLabels
            txt = (isKey ? symbolName + " KEY " : symbolName + " S ") + str.tostring(lvl)
            lb  = label.new(bar_index, lvl, text=txt, style=label.style_label_left, color=labelBgColor, textcolor=labelTextColor, size=(isKey ? size.normal : size.small))
            array.push(labelsArr, lb)

    // ---- RESISTANCE (up-side) ----
    resArr = parseLevels(resistanceText)
    for i = 0 to array.size(resArr) - 1
        lvl   = array.get(resArr, i)
        isKey = keyLevel > 0 and math.abs(lvl - keyLevel) <= syminfo.mintick
        wid   = isKey ? keyWidth : regularWidth
        ln    = line.new(bar_index, lvl, bar_index + 1, lvl, extend=extend.both, color=resistanceColor, width=wid)
        array.push(lvlArr, Lvl.new(ln, lvl, isKey))
        array.push(resistanceVals, lvl)
        if showLabels
            txt = (isKey ? symbolName + " KEY " : symbolName + " R ") + str.tostring(lvl)
            lb  = label.new(bar_index, lvl, text=txt, style=label.style_label_left, color=labelBgColor, textcolor=labelTextColor, size=(isKey ? size.normal : size.small))
            array.push(labelsArr, lb)

    // ---- KEY LEVEL on its own line if it didn't match a pasted level ----
    if keyLevel > 0
        keyExists = false
        for i = 0 to array.size(supportVals) - 1
            if math.abs(array.get(supportVals, i) - keyLevel) <= syminfo.mintick
                keyExists := true
        for i = 0 to array.size(resistanceVals) - 1
            if math.abs(array.get(resistanceVals, i) - keyLevel) <= syminfo.mintick
                keyExists := true
        if not keyExists
            kln = line.new(bar_index, keyLevel, bar_index + 1, keyLevel, extend=extend.both, color=keyColor, width=keyWidth)
            array.push(lvlArr, Lvl.new(kln, keyLevel, true))
            if showLabels
                klb = label.new(bar_index, keyLevel, text=symbolName + " KEY " + str.tostring(keyLevel), style=label.style_label_left, color=labelBgColor, textcolor=labelTextColor, size=size.normal)
                array.push(labelsArr, klb)

    prevSupport := supportText
    prevResist  := resistanceText
    prevKey     := keyLevel
    initialized := true

// ---- recolor levels every bar by ROLE: above price = support (green), below = resistance (red); key keeps its color ----
if array.size(lvlArr) > 0
    for i = 0 to array.size(lvlArr) - 1
        L = array.get(lvlArr, i)
        line.set_color(L.ln, L.key ? keyColor : (close >= L.val ? supportColor : resistanceColor))

// ============================================================
// AUTO LEVELS DATA (non-repainting previous period values)
// ============================================================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)

pdhCol = colPDH
pdlCol = colPDL
pwhCol = colPWH
pwlCol = colPWL

plot(showPDH ? pdh : na, "Prev Day High",  color=pdhCol, style=plot.style_linebr, linewidth=1)
plot(showPDL ? pdl : na, "Prev Day Low",   color=pdlCol, style=plot.style_linebr, linewidth=1)
plot(showPWH ? pwh : na, "Prev Week High", color=pwhCol, style=plot.style_linebr, linewidth=2)
plot(showPWL ? pwl : na, "Prev Week Low",  color=pwlCol, style=plot.style_linebr, linewidth=2)

// ---- auto-level tags on the last bar ----
var label pdhLbl = na
var label pdlLbl = na
var label pwhLbl = na
var label pwlLbl = na
if barstate.islast
    label.delete(pdhLbl)
    label.delete(pdlLbl)
    label.delete(pwhLbl)
    label.delete(pwlLbl)
    if showLabels and showPDH
        pdhLbl := label.new(bar_index, pdh, symbolName + " PDH " + str.tostring(pdh), style=label.style_label_left, color=pdhCol, textcolor=labelTextColor, size=size.small)
    if showLabels and showPDL
        pdlLbl := label.new(bar_index, pdl, symbolName + " PDL " + str.tostring(pdl), style=label.style_label_left, color=pdlCol, textcolor=labelTextColor, size=size.small)
    if showLabels and showPWH
        pwhLbl := label.new(bar_index, pwh, symbolName + " PWH " + str.tostring(pwh), style=label.style_label_left, color=pwhCol, textcolor=labelTextColor, size=size.small)
    if showLabels and showPWL
        pwlLbl := label.new(bar_index, pwl, symbolName + " PWL " + str.tostring(pwl), style=label.style_label_left, color=pwlCol, textcolor=labelTextColor, size=size.small)

// ============================================================
// ALERTS  (manual cross detection so it stays loop-safe)
// ============================================================
if alertSupport and array.size(supportVals) > 0
    for i = 0 to array.size(supportVals) - 1
        lvl = array.get(supportVals, i)
        if close < lvl and close[1] >= lvl
            alert(symbolName + " dropped BELOW support " + str.tostring(lvl), alert.freq_once_per_bar)

if alertResistance and array.size(resistanceVals) > 0
    for i = 0 to array.size(resistanceVals) - 1
        lvl = array.get(resistanceVals, i)
        if close > lvl and close[1] <= lvl
            alert(symbolName + " rose ABOVE resistance " + str.tostring(lvl), alert.freq_once_per_bar)

if alrtPDH and not na(pdh) and close > pdh and close[1] <= pdh
    alert(symbolName + " rose ABOVE Prev Day High " + str.tostring(pdh), alert.freq_once_per_bar)
if alrtPDL and not na(pdl) and close < pdl and close[1] >= pdl
    alert(symbolName + " dropped BELOW Prev Day Low " + str.tostring(pdl), alert.freq_once_per_bar)
if alrtPWH and not na(pwh) and close > pwh and close[1] <= pwh
    alert(symbolName + " rose ABOVE Prev Week High " + str.tostring(pwh), alert.freq_once_per_bar)
if alrtPWL and not na(pwl) and close < pwl and close[1] >= pwl
    alert(symbolName + " dropped BELOW Prev Week Low " + str.tostring(pwl), alert.freq_once_per_bar)

// ============================================================
// ORDER BLOCKS + MARKET STRUCTURE
//   - swings via pivots; BOS = continuation, CHoCH = trend flip
//   - each swing high/low can only break ONCE (no duplicate BOS)
//   - order block anchored at the leg's extreme candle
//   - volume ESTIMATED from a lower timeframe (no true bid/ask)
// ============================================================
fmtVol(float v) =>
    av = math.abs(v)
    av >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : av >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : av >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" : str.tostring(v, "#.#")

type OB
    box   bx
    label lb
    float top
    float bot
    bool  bull
    bool  done

var OB[]  obList = array.new<OB>()
var label[] swingLbls  = array.new_label()
var label[] structLbls = array.new_label()
var line[]  structLns  = array.new_line()
var float swHigh    = na
var int   swHighBar = na
var float swLow     = na
var int   swLowBar  = na
var int   trend     = 0      // 1 = up, -1 = down
var bool  topCrossed = false // current swing high already broken?
var bool  btmCrossed = false // current swing low already broken?

obAtr = ta.atr(14)
capH  = obMaxHtAtr > 0 ? obAtr * obMaxHtAtr : na

// ---- estimate buy vs sell volume from a lower timeframe ----
ltfO = request.security_lower_tf(syminfo.tickerid, obLTF, open)
ltfC = request.security_lower_tf(syminfo.tickerid, obLTF, close)
ltfV = request.security_lower_tf(syminfo.tickerid, obLTF, volume)
float barBuy  = 0.0
float barSell = 0.0
if array.size(ltfV) > 0
    for m = 0 to array.size(ltfV) - 1
        v = array.get(ltfV, m)
        if array.get(ltfC, m) >= array.get(ltfO, m)
            barBuy  := barBuy + v
        else
            barSell := barSell + v

// ---- confirmed swing points (pivots) ----
ph = ta.pivothigh(obSwingLen, obSwingLen)
pl = ta.pivotlow(obSwingLen, obSwingLen)
if not na(ph)
    isHH = na(swHigh) or ph > swHigh
    if obSwingLbl
        sl = label.new(bar_index - obSwingLen, ph, isHH ? "HH" : "LH", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=resistanceColor, size=size.tiny)
        array.push(swingLbls, sl)
        if array.size(swingLbls) > msKeep
            label.delete(array.shift(swingLbls))
    swHigh    := ph
    swHighBar := bar_index - obSwingLen
    topCrossed := false
if not na(pl)
    isHL = na(swLow) or pl > swLow
    if obSwingLbl
        sl = label.new(bar_index - obSwingLen, pl, isHL ? "HL" : "LL", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=supportColor, size=size.tiny)
        array.push(swingLbls, sl)
        if array.size(swingLbls) > msKeep
            label.delete(array.shift(swingLbls))
    swLow    := pl
    swLowBar := bar_index - obSwingLen
    btmCrossed := false

// ---- break of structure detection (each swing fires only once) ----
bullBreak = not na(swHigh) and not topCrossed and close > swHigh and close[1] <= swHigh
bearBreak = not na(swLow)  and not btmCrossed and close < swLow  and close[1] >= swLow

// ---- maintain existing blocks (extend right + move label + mitigation) ----
if showOB and array.size(obList) > 0
    for i = array.size(obList) - 1 to 0
        ob = array.get(obList, i)
        if not ob.done
            box.set_right(ob.bx, bar_index)
            if not na(ob.lb)
                label.set_x(ob.lb, bar_index)
            bullMit = obMitWick ? low  < ob.bot : close < ob.bot
            bearMit = obMitWick ? high > ob.top : close > ob.top
            if (ob.bull ? bullMit : bearMit)
                ob.done := true
                if obDeleteMit
                    box.delete(ob.bx)
                    label.delete(ob.lb)
                    array.remove(obList, i)
                else
                    box.set_bgcolor(ob.bx, color.new(color.gray, 85))
                    box.set_border_color(ob.bx, color.new(color.gray, 60))

// ---- bullish break of structure ----
if bullBreak
    isBOS = trend == 1
    trend := 1
    topCrossed := true
    if obStructLbl
        sln = line.new(na(swHighBar) ? bar_index - 1 : swHighBar, swHigh, bar_index, swHigh, color=supportColor, style=line.style_dashed, width=1)
        array.push(structLns, sln)
        if array.size(structLns) > msKeep
            line.delete(array.shift(structLns))
        mx = na(swHighBar) ? bar_index : int((swHighBar + bar_index) / 2)
        slb = label.new(mx, swHigh, isBOS ? "BOS" : "CHoCH", style=label.style_none, color=color.new(color.gray, 100), textcolor=supportColor, size=size.tiny)
        array.push(structLbls, slb)
        if array.size(structLbls) > msKeep
            label.delete(array.shift(structLbls))
    if showOB
        maxLook = na(swLowBar) ? obScan : math.min(bar_index - swLowBar, obScan)
        obOff = 0
        lo = low
        for j = 0 to maxLook
            if low[j] < lo
                lo := low[j]
                obOff := j
        t = obUseBody ? math.max(open[obOff], close[obOff]) : high[obOff]
        b = obUseBody ? math.min(open[obOff], close[obOff]) : low[obOff]
        if not na(capH) and (t - b) > capH
            b := t - capH
        overlap = false
        if obNoOverlap and array.size(obList) > 0
            for k = 0 to array.size(obList) - 1
                o = array.get(obList, k)
                if o.bull and not o.done and b <= o.top and o.bot <= t
                    overlap := true
        if not overlap
            bx = box.new(bar_index - obOff, t, bar_index, b, border_color=color.new(color.green, 40), bgcolor=obBullColor, border_width=1)
            label lb = na
            if obShowVol
                bv  = barBuy[obOff]
                sv  = barSell[obOff]
                tot = bv + sv > 0 ? bv + sv : volume[obOff]
                pct = bv + sv > 0 ? bv / (bv + sv) * 100 : na
                vtxt = fmtVol(tot) + (na(pct) ? "" : "  " + str.tostring(pct, "#") + "% buy")
                lb := label.new(bar_index, math.avg(t, b), vtxt, style=label.style_label_left, color=color.new(color.green, 70), textcolor=color.white, size=size.tiny)
            array.push(obList, OB.new(bx, lb, t, b, true, false))
            if array.size(obList) > obMaxCount
                old = array.shift(obList)
                box.delete(old.bx)
                label.delete(old.lb)

// ---- bearish break of structure ----
if bearBreak
    isBOS = trend == -1
    trend := -1
    btmCrossed := true
    if obStructLbl
        sln = line.new(na(swLowBar) ? bar_index - 1 : swLowBar, swLow, bar_index, swLow, color=resistanceColor, style=line.style_dashed, width=1)
        array.push(structLns, sln)
        if array.size(structLns) > msKeep
            line.delete(array.shift(structLns))
        mx = na(swLowBar) ? bar_index : int((swLowBar + bar_index) / 2)
        slb = label.new(mx, swLow, isBOS ? "BOS" : "CHoCH", style=label.style_none, color=color.new(color.gray, 100), textcolor=resistanceColor, size=size.tiny)
        array.push(structLbls, slb)
        if array.size(structLbls) > msKeep
            label.delete(array.shift(structLbls))
    if showOB
        maxLook = na(swHighBar) ? obScan : math.min(bar_index - swHighBar, obScan)
        obOff = 0
        hi = high
        for j = 0 to maxLook
            if high[j] > hi
                hi := high[j]
                obOff := j
        t = obUseBody ? math.max(open[obOff], close[obOff]) : high[obOff]
        b = obUseBody ? math.min(open[obOff], close[obOff]) : low[obOff]
        if not na(capH) and (t - b) > capH
            t := b + capH
        overlap = false
        if obNoOverlap and array.size(obList) > 0
            for k = 0 to array.size(obList) - 1
                o = array.get(obList, k)
                if (not o.bull) and not o.done and b <= o.top and o.bot <= t
                    overlap := true
        if not overlap
            bx = box.new(bar_index - obOff, t, bar_index, b, border_color=color.new(color.red, 40), bgcolor=obBearColor, border_width=1)
            label lb = na
            if obShowVol
                bv  = barBuy[obOff]
                sv  = barSell[obOff]
                tot = bv + sv > 0 ? bv + sv : volume[obOff]
                pct = bv + sv > 0 ? sv / (bv + sv) * 100 : na
                vtxt = fmtVol(tot) + (na(pct) ? "" : "  " + str.tostring(pct, "#") + "% sell")
                lb := label.new(bar_index, math.avg(t, b), vtxt, style=label.style_label_left, color=color.new(color.red, 70), textcolor=color.white, size=size.tiny)
            array.push(obList, OB.new(bx, lb, t, b, false, false))
            if array.size(obList) > obMaxCount
                old = array.shift(obList)
                box.delete(old.bx)
                label.delete(old.lb)
````
