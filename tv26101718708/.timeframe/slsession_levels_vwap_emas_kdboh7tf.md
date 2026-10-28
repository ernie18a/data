# SL-Session Levels + VWAP + EMAs

- url: https://www.tradingview.com/script/kdbOh7tF-SL-Session-Levels-VWAP-EMAs/
- type: indicator
- pine_id: PUB;2179ec2526bc4b7ebe99df391dfa6c62
- version: 1.0

## Description

Previous Day High and Low
Asia and London Session High and Low
VWAP
Multiple EMAs

## Source Code

````pine
//@version=6
indicator("Session Levels + VWAP + EMAs", shorttitle="SessLevels", overlay=true, max_lines_count=500, max_labels_count=200)

// ══════════════════════════════════════════════
//  GROUP: Label Settings
// ══════════════════════════════════════════════
grpLbl  = "Label Settings"
lblSize = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLbl)

// ══════════════════════════════════════════════
//  GROUP: Previous Day High / Low
// ══════════════════════════════════════════════
grpDay      = "Previous Day High / Low"
showPDHL    = input.bool(true,  "Show Prev Day H/L",  group=grpDay)
pdHighCol   = input.color(color.new(#00BCD4, 0), "Prev Day High Color", group=grpDay)
pdLowCol    = input.color(color.new(#FF5722, 0), "Prev Day Low Color",  group=grpDay)
pdLineWid   = input.int(1, "Line Width", minval=1, maxval=4, group=grpDay)
pdLineStyle = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grpDay)
pdExtBars   = input.int(20, "Right Extension (bars)", minval=0, maxval=500, group=grpDay)

// ══════════════════════════════════════════════
//  GROUP: Previous 4H High / Low
// ══════════════════════════════════════════════
grp4H        = "Previous 4H High / Low"
show4HHL     = input.bool(true,  "Show Prev 4H H/L",  group=grp4H)
p4hHighCol   = input.color(color.new(#9C27B0, 0), "Prev 4H High Color", group=grp4H)
p4hLowCol    = input.color(color.new(#E91E63, 0), "Prev 4H Low Color",  group=grp4H)
p4hLineWid   = input.int(1, "Line Width", minval=1, maxval=4, group=grp4H)
p4hLineStyle = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grp4H)
p4hExtBars   = input.int(20, "Right Extension (bars)", minval=0, maxval=500, group=grp4H)

// ══════════════════════════════════════════════
//  GROUP: Previous 1H High / Low
// ══════════════════════════════════════════════
grp1H        = "Previous 1H High / Low"
show1HHL     = input.bool(true,  "Show Prev 1H H/L",  group=grp1H)
p1hHighCol   = input.color(color.new(#4CAF50, 0), "Prev 1H High Color", group=grp1H)
p1hLowCol    = input.color(color.new(#F44336, 0), "Prev 1H Low Color",  group=grp1H)
p1hLineWid   = input.int(1, "Line Width", minval=1, maxval=4, group=grp1H)
p1hLineStyle = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=grp1H)
p1hExtBars   = input.int(20, "Right Extension (bars)", minval=0, maxval=500, group=grp1H)

// ══════════════════════════════════════════════
//  GROUP: Asia Session High / Low
// ══════════════════════════════════════════════
grpAsia       = "Asia Session High / Low"
showAsiaHL    = input.bool(true,  "Show Asia H/L",     group=grpAsia)
asiaStart     = input.session("0000-0800", "Asia Session (Exchange TZ)", group=grpAsia)
asiaHighCol   = input.color(color.new(#FF9800, 0), "Asia High Color", group=grpAsia)
asiaLowCol    = input.color(color.new(#FFC107, 0), "Asia Low Color",  group=grpAsia)
asiaLineWid   = input.int(1, "Line Width", minval=1, maxval=4, group=grpAsia)
asiaLineStyle = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=grpAsia)
asiaExtBars   = input.int(20, "Right Extension (bars)", minval=0, maxval=500, group=grpAsia)

// ══════════════════════════════════════════════
//  GROUP: London Session High / Low
// ══════════════════════════════════════════════
grpLon       = "London Session High / Low"
showLonHL    = input.bool(true,  "Show London H/L",   group=grpLon)
lonStart     = input.session("0800-1600", "London Session (Exchange TZ)", group=grpLon)
lonHighCol   = input.color(color.new(#2196F3, 0), "London High Color", group=grpLon)
lonLowCol    = input.color(color.new(#03A9F4, 0), "London Low Color",  group=grpLon)
lonLineWid   = input.int(1, "Line Width", minval=1, maxval=4, group=grpLon)
lonLineStyle = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=grpLon)
lonExtBars   = input.int(20, "Right Extension (bars)", minval=0, maxval=500, group=grpLon)

// ══════════════════════════════════════════════
//  GROUP: VWAP
// ══════════════════════════════════════════════
grpVWAP   = "VWAP"
showVWAP  = input.bool(true, "Show VWAP",  group=grpVWAP)
vwapCol   = input.color(color.new(#FFFFFF, 0), "VWAP Color", group=grpVWAP)
vwapWidth = input.int(2, "Line Width", minval=1, maxval=4, group=grpVWAP)

// ══════════════════════════════════════════════
//  GROUP: EMAs
// ══════════════════════════════════════════════
grpEMA      = "EMAs"
showEMA9    = input.bool(true, "Show 9 EMA",   group=grpEMA)
ema9Len     = input.int(9,   "9 EMA Length",   group=grpEMA, minval=1)
ema9Col     = input.color(color.new(#F6C90E, 0), "9 EMA Color",   group=grpEMA)
ema9Width   = input.int(1, "9 EMA Width",  minval=1, maxval=4, group=grpEMA)

showEMA25   = input.bool(true, "Show 25 EMA",  group=grpEMA)
ema25Len    = input.int(25,  "25 EMA Length",  group=grpEMA, minval=1)
ema25Col    = input.color(color.new(#FF6B35, 0), "25 EMA Color",  group=grpEMA)
ema25Width  = input.int(1, "25 EMA Width", minval=1, maxval=4, group=grpEMA)

showEMA50   = input.bool(true, "Show 50 EMA",  group=grpEMA)
ema50Len    = input.int(50,  "50 EMA Length",  group=grpEMA, minval=1)
ema50Col    = input.color(color.new(#7FBA00, 0), "50 EMA Color",  group=grpEMA)
ema50Width  = input.int(1, "50 EMA Width", minval=1, maxval=4, group=grpEMA)

showEMA200  = input.bool(true, "Show 200 EMA", group=grpEMA)
ema200Len   = input.int(200, "200 EMA Length", group=grpEMA, minval=1)
ema200Col   = input.color(color.new(#E91E63, 0), "200 EMA Color", group=grpEMA)
ema200Width = input.int(2, "200 EMA Width", minval=1, maxval=4, group=grpEMA)

// ══════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════
f_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_lblSize(s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small

// Convert bars → milliseconds for the current chart timeframe
barMs = timeframe.in_seconds() * 1000

// ══════════════════════════════════════════════
//  VWAP
// ══════════════════════════════════════════════
isNewDay = ta.change(time("D")) != 0
var float cumVol = 0.0
var float cumTP  = 0.0
cumVol := isNewDay ? volume : cumVol[1] + volume
cumTP  := isNewDay ? volume * hlc3 : cumTP[1] + volume * hlc3
vwapVal = cumTP / cumVol
plot(showVWAP ? vwapVal : na, title="VWAP", color=vwapCol, linewidth=vwapWidth)

// ══════════════════════════════════════════════
//  EMAs
// ══════════════════════════════════════════════
plot(showEMA9   ? ta.ema(close, ema9Len)   : na, title="9 EMA",   color=ema9Col,   linewidth=ema9Width)
plot(showEMA25  ? ta.ema(close, ema25Len)  : na, title="25 EMA",  color=ema25Col,  linewidth=ema25Width)
plot(showEMA50  ? ta.ema(close, ema50Len)  : na, title="50 EMA",  color=ema50Col,  linewidth=ema50Width)
plot(showEMA200 ? ta.ema(close, ema200Len) : na, title="200 EMA", color=ema200Col, linewidth=ema200Width)

// ══════════════════════════════════════════════
//  PREVIOUS DAY HIGH / LOW
// ══════════════════════════════════════════════
var float _dHigh    = na
var float _dLow     = na
var int   dayStartT = na
var float pdHigh    = na
var float pdLow     = na
var int   pdStartT  = na
var line  pdHighLn  = na
var label pdHighLb  = na
var line  pdLowLn   = na
var label pdLowLb   = na

_dHigh := isNewDay ? high : math.max(nz(_dHigh, high), high)
_dLow  := isNewDay ? low  : math.min(nz(_dLow,  low),  low)

// Pre-compute right edge for this group (current bar + extension)
pdX2 = int(time) + pdExtBars * barMs

if isNewDay
    pdHigh    := nz(_dHigh[1], high)
    pdLow     := nz(_dLow[1],  low)
    pdStartT  := nz(dayStartT, int(time))
    dayStartT := int(time)
    line.delete(pdHighLn)
    label.delete(pdHighLb)
    line.delete(pdLowLn)
    label.delete(pdLowLb)
    if showPDHL and not na(pdHigh)
        pdHighLn := line.new(pdStartT, pdHigh, pdX2, pdHigh, xloc=xloc.bar_time, extend=extend.none, color=pdHighCol, width=pdLineWid, style=f_style(pdLineStyle))
        pdHighLb := label.new(pdX2, pdHigh, "PDH", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=pdHighCol, style=label.style_none, size=f_lblSize(lblSize))
        pdLowLn  := line.new(pdStartT, pdLow, pdX2, pdLow,  xloc=xloc.bar_time, extend=extend.none, color=pdLowCol,  width=pdLineWid, style=f_style(pdLineStyle))
        pdLowLb  := label.new(pdX2, pdLow, "PDL", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=pdLowCol,  style=label.style_none, size=f_lblSize(lblSize))

if showPDHL and not na(pdHighLn)
    line.set_x2(pdHighLn, pdX2)
    label.set_x(pdHighLb, pdX2)
if showPDHL and not na(pdLowLn)
    line.set_x2(pdLowLn,  pdX2)
    label.set_x(pdLowLb,  pdX2)

// ══════════════════════════════════════════════
//  PREVIOUS 4H HIGH / LOW
// ══════════════════════════════════════════════
[prev4hH, prev4hL] = request.security(syminfo.tickerid, "240", [high[1], low[1]], lookahead=barmerge.lookahead_on)
isNew4H = ta.change(time("240")) != 0

var int   fourHStartT = na
var float cur4hH      = na
var float cur4hL      = na
var int   cur4hStartT = na
var line  p4hHighLn   = na
var label p4hHighLb   = na
var line  p4hLowLn    = na
var label p4hLowLb    = na

p4hX2 = int(time) + p4hExtBars * barMs

if isNew4H
    cur4hH      := prev4hH
    cur4hL      := prev4hL
    cur4hStartT := nz(fourHStartT, int(time))
    fourHStartT := int(time)
    line.delete(p4hHighLn)
    label.delete(p4hHighLb)
    line.delete(p4hLowLn)
    label.delete(p4hLowLb)
    if show4HHL and not na(cur4hH)
        p4hHighLn := line.new(cur4hStartT, cur4hH, p4hX2, cur4hH, xloc=xloc.bar_time, extend=extend.none, color=p4hHighCol, width=p4hLineWid, style=f_style(p4hLineStyle))
        p4hHighLb := label.new(p4hX2, cur4hH, "P4H", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=p4hHighCol, style=label.style_none, size=f_lblSize(lblSize))
        p4hLowLn  := line.new(cur4hStartT, cur4hL, p4hX2, cur4hL, xloc=xloc.bar_time, extend=extend.none, color=p4hLowCol,  width=p4hLineWid, style=f_style(p4hLineStyle))
        p4hLowLb  := label.new(p4hX2, cur4hL, "P4L", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=p4hLowCol,  style=label.style_none, size=f_lblSize(lblSize))

if show4HHL and not na(p4hHighLn)
    line.set_x2(p4hHighLn, p4hX2)
    label.set_x(p4hHighLb, p4hX2)
if show4HHL and not na(p4hLowLn)
    line.set_x2(p4hLowLn,  p4hX2)
    label.set_x(p4hLowLb,  p4hX2)

// ══════════════════════════════════════════════
//  PREVIOUS 1H HIGH / LOW
// ══════════════════════════════════════════════
[prev1hH, prev1hL] = request.security(syminfo.tickerid, "60", [high[1], low[1]], lookahead=barmerge.lookahead_on)
isNew1H = ta.change(time("60")) != 0

var int   oneHStartT  = na
var float cur1hH      = na
var float cur1hL      = na
var int   cur1hStartT = na
var line  p1hHighLn   = na
var label p1hHighLb   = na
var line  p1hLowLn    = na
var label p1hLowLb    = na

p1hX2 = int(time) + p1hExtBars * barMs

if isNew1H
    cur1hH      := prev1hH
    cur1hL      := prev1hL
    cur1hStartT := nz(oneHStartT, int(time))
    oneHStartT  := int(time)
    line.delete(p1hHighLn)
    label.delete(p1hHighLb)
    line.delete(p1hLowLn)
    label.delete(p1hLowLb)
    if show1HHL and not na(cur1hH)
        p1hHighLn := line.new(cur1hStartT, cur1hH, p1hX2, cur1hH, xloc=xloc.bar_time, extend=extend.none, color=p1hHighCol, width=p1hLineWid, style=f_style(p1hLineStyle))
        p1hHighLb := label.new(p1hX2, cur1hH, "P1H", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=p1hHighCol, style=label.style_none, size=f_lblSize(lblSize))
        p1hLowLn  := line.new(cur1hStartT, cur1hL, p1hX2, cur1hL, xloc=xloc.bar_time, extend=extend.none, color=p1hLowCol,  width=p1hLineWid, style=f_style(p1hLineStyle))
        p1hLowLb  := label.new(p1hX2, cur1hL, "P1L", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=p1hLowCol,  style=label.style_none, size=f_lblSize(lblSize))

if show1HHL and not na(p1hHighLn)
    line.set_x2(p1hHighLn, p1hX2)
    label.set_x(p1hHighLb, p1hX2)
if show1HHL and not na(p1hLowLn)
    line.set_x2(p1hLowLn,  p1hX2)
    label.set_x(p1hLowLb,  p1hX2)

// ══════════════════════════════════════════════
//  ASIA SESSION HIGH / LOW
// ══════════════════════════════════════════════
inAsia = not na(time(timeframe.period, asiaStart))

var float asiaH          = na
var float asiaL          = na
var bool  wasInAsia      = false
var int   asiaStartT     = na
var float prevAsiaH      = na
var float prevAsiaL      = na
var int   prevAsiaStartT = na
var line  asiaHighLn     = na
var label asiaHighLb     = na
var line  asiaLowLn      = na
var label asiaLowLb      = na

if inAsia and not wasInAsia
    asiaH      := high
    asiaL      := low
    asiaStartT := int(time)
else if inAsia
    asiaH := math.max(asiaH, high)
    asiaL := math.min(asiaL, low)

if not inAsia and wasInAsia
    prevAsiaH      := asiaH
    prevAsiaL      := asiaL
    prevAsiaStartT := asiaStartT
    // Session close: x2 = session-end bar + extension
    asiaX2 = int(time) + asiaExtBars * barMs
    line.delete(asiaHighLn)
    label.delete(asiaHighLb)
    line.delete(asiaLowLn)
    label.delete(asiaLowLb)
    if showAsiaHL
        asiaHighLn := line.new(prevAsiaStartT, prevAsiaH, asiaX2, prevAsiaH, xloc=xloc.bar_time, extend=extend.none, color=asiaHighCol, width=asiaLineWid, style=f_style(asiaLineStyle))
        asiaHighLb := label.new(asiaX2, prevAsiaH, "Asia High", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=asiaHighCol, style=label.style_none, size=f_lblSize(lblSize))
        asiaLowLn  := line.new(prevAsiaStartT, prevAsiaL, asiaX2, prevAsiaL, xloc=xloc.bar_time, extend=extend.none, color=asiaLowCol,  width=asiaLineWid, style=f_style(asiaLineStyle))
        asiaLowLb  := label.new(asiaX2, prevAsiaL, "Asia Low",  xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=asiaLowCol,  style=label.style_none, size=f_lblSize(lblSize))

wasInAsia := inAsia

// ══════════════════════════════════════════════
//  LONDON SESSION HIGH / LOW
// ══════════════════════════════════════════════
inLon = not na(time(timeframe.period, lonStart))

var float lonH           = na
var float lonL           = na
var bool  wasInLon       = false
var int   lonStartT      = na
var float prevLonH       = na
var float prevLonL       = na
var int   prevLonStartT  = na
var line  lonHighLn      = na
var label lonHighLb      = na
var line  lonLowLn       = na
var label lonLowLb       = na

if inLon and not wasInLon
    lonH      := high
    lonL      := low
    lonStartT := int(time)
else if inLon
    lonH := math.max(lonH, high)
    lonL := math.min(lonL, low)

if not inLon and wasInLon
    prevLonH      := lonH
    prevLonL      := lonL
    prevLonStartT := lonStartT
    lonX2 = int(time) + lonExtBars * barMs
    line.delete(lonHighLn)
    label.delete(lonHighLb)
    line.delete(lonLowLn)
    label.delete(lonLowLb)
    if showLonHL
        lonHighLn := line.new(prevLonStartT, prevLonH, lonX2, prevLonH, xloc=xloc.bar_time, extend=extend.none, color=lonHighCol, width=lonLineWid, style=f_style(lonLineStyle))
        lonHighLb := label.new(lonX2, prevLonH, "London High", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=lonHighCol, style=label.style_none, size=f_lblSize(lblSize))
        lonLowLn  := line.new(prevLonStartT, prevLonL, lonX2, prevLonL, xloc=xloc.bar_time, extend=extend.none, color=lonLowCol,  width=lonLineWid, style=f_style(lonLineStyle))
        lonLowLb  := label.new(lonX2, prevLonL, "London Low",  xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=lonLowCol,  style=label.style_none, size=f_lblSize(lblSize))

wasInLon := inLon
````
