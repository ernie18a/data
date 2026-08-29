<!-- tradingview-pine-id: PUB;c9ef036b849e488c96811719caf7a6a6 -->
<!-- tradingviewscripts-format: 1 -->
# Anchored VWAP + Opening Range

Source: https://www.tradingview.com/script/YIc8MSr0-Anchored-VWAP-Adjustable-Range/

## Description

An adjustable range with an attached anchored VWAP

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © silas7467

//@version=6
indicator("Anchored VWAP + Opening Range", shorttitle = "AVWAP+OR", overlay = true)

// ═══ INPUTS ═══════════════════════════════════════════════
gA = "Anchor"
anchorType = input.string("Custom Time", "Anchor period", options = ["Hour", "Day", "Week", "Month", "Quarter", "Year", "RTH", "Custom Time"], group = gA)
hourMult   = input.int(4, "Hour multiplier (Hour anchor only)", minval = 1, group = gA)
customSess = input.session("1600-1601", "Custom anchor time", group = gA)
tz         = input.string("America/New_York", "Timezone", group = gA)

gV = "VWAP"
src           = input.source(hlc3, "Source", group = gV)
devUp         = input.float(1.0,  "Upper deviation", step = 0.1, group = gV)
devDn         = input.float(-1.0, "Lower deviation", step = 0.1, group = gV)
showBands     = input.bool(true,  "Show deviation bands", group = gV)
showVwapCloud = input.bool(false, "Show high/low VWAP cloud", group = gV)

gR = "Opening Range"
showRange = input.bool(true, "Show opening range cloud", group = gR)
orMinutes = input.int(60, "Range length (minutes)", minval = 1, group = gR)
orMult    = input.float(1.0, "Range multiplier", minval = 0.1, step = 0.1, group = gR)

gM = "Midpoint"
showMid      = input.bool(false, "Show period midpoint", group = gM)
showMidCloud = input.bool(false, "Shade VWAP vs midpoint", group = gM)

// ═══ PERIOD DETECTION ═════════════════════════════════════
hourTf   = str.tostring(hourMult * 60)
inCustom = not na(time(timeframe.period, customSess, tz))

newPeriod = switch anchorType
    "Hour"        => timeframe.change(hourTf)
    "Day"         => timeframe.change("1D")
    "Week"        => timeframe.change("1W")
    "Month"       => timeframe.change("1M")
    "Quarter"     => timeframe.change("3M")
    "Year"        => timeframe.change("12M")
    "RTH"         => session.ismarket and not session.ismarket[1]
    "Custom Time" => inCustom and not inCustom[1]
    => false

// ═══ VWAP + VOLUME-WEIGHTED DEVIATION ═════════════════════
var float vSum   = na
var float vpSum  = na
var float vp2Sum = na
var float vhSum  = na
var float vlSum  = na

roll = newPeriod or na(vSum)

if roll
    vSum   := volume
    vpSum  := volume * src
    vp2Sum := volume * src * src
    vhSum  := volume * high
    vlSum  := volume * low
else
    vSum   += volume
    vpSum  += volume * src
    vp2Sum += volume * src * src
    vhSum  += volume * high
    vlSum  += volume * low

vwapVal  = vpSum / vSum
dev      = math.sqrt(math.max(vp2Sum / vSum - vwapVal * vwapVal, 0))
vwapHigh = vhSum / vSum
vwapLow  = vlSum / vSum

// ═══ OPENING RANGE ════════════════════════════════════════
orMs = int(math.round(orMinutes * orMult * 60000))
var int   anchorT = na
var float orHigh  = na
var float orLow   = na

if roll
    anchorT := time
    orHigh  := high
    orLow   := low
else if time < anchorT + orMs
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow,  low)

// ═══ PERIOD RANGE + MIDPOINT ══════════════════════════════
var float pHigh = na
var float pLow  = na

if roll
    pHigh := high
    pLow  := low
else
    pHigh := math.max(pHigh, high)
    pLow  := math.min(pLow,  low)

midPoint = (pHigh + pLow) / 2

// ═══ PLOTS ════════════════════════════════════════════════
brk = not newPeriod

pVwap = plot(brk ? vwapVal : na, "VWAP", color = color.yellow, linewidth = 2, style = plot.style_linebr)

pUp = plot(showBands and brk ? vwapVal + devUp * dev : na, "Upper band", color = color.gray, style = plot.style_linebr)
pDn = plot(showBands and brk ? vwapVal + devDn * dev : na, "Lower band", color = color.gray, style = plot.style_linebr)

pOrH = plot(showRange and brk ? orHigh : na, "OR High", color = color.new(color.yellow, 40), style = plot.style_linebr)
pOrL = plot(showRange and brk ? orLow  : na, "OR Low",  color = color.new(color.yellow, 40), style = plot.style_linebr)
fill(pOrH, pOrL, color = color.new(#666600, 70), title = "Opening range")

pVwH = plot(showVwapCloud and brk ? vwapHigh : na, "VWAP High", color = color.new(color.gray, 60), style = plot.style_linebr)
pVwL = plot(showVwapCloud and brk ? vwapLow  : na, "VWAP Low",  color = color.new(color.gray, 60), style = plot.style_linebr)
fill(pVwH, pVwL, color = color.new(#666600, 75), title = "VWAP cloud")

pMid = plot(showMid and brk ? midPoint : na, "Midpoint", color = color.gray, style = plot.style_linebr)
fill(pVwap, pMid, color = not showMidCloud ? na : vwapVal > midPoint ? color.new(color.green, 85) : color.new(color.red, 85), title = "VWAP vs Mid")
````
