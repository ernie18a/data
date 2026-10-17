# BOS & CHoCH + ICT FVG, IFVG 

- url: https://www.tradingview.com/script/RT9u7r1l-BOS-CHoCH-ICT-FVG-IFVG/
- type: indicator
- pine_id: PUB;5e3b08b4110e4084b2cfe382f024a58a
- version: 1.0

## Description

FVG, IFVG, BOS, and CHoCH are foundational components of Smart Money Concepts (SMC) and ICT (Inner Circle Trader) price action analysis. They are used to track institutional trading activity, map market structure, and identify high-probability entry points.1. CHoCH (Change of Character)CHoCH is the very first sign of a potential trend reversal.What it looks like: In a downtrend (making lower lows), CHoCH happens when the price bounces and breaks above the most recent lower high. It shows that the buyers have overpowered the sellers.2. BOS (Break of Structure)Once a trend has reversed (indicated by a CHoCH), BOS confirms that the new trend is continuing.What it looks like: In an uptrend, the price pushes higher and breaks past a previous swing high. This confirms that the institutional momentum is strong and continuing in that direction.3. FVG (Fair Value Gap)An FVG is a price imbalance or inefficiency left behind after a sudden, aggressive move in the market.What it looks like: It appears as an extended, single candle where the preceding and succeeding candle wicks do not overlap its body. Because the market dislikes these imbalances, price often acts like a magnet, pulling back to "fill" or "mitigate" the gap before continuing the trend.4. IFVG (Inverted/Invalidated Fair Value Gap)An IFVG occurs when a previously established FVG is aggressively broken through and invalidated by the price.

## Source Code

````pine
//@version=6
indicator('BOS & CHoCH + ICT Gaps, Volume & Price Imbalances', shorttitle='BOS+CHoCH+ICT [Julio]', overlay=true, max_boxes_count=500, max_lines_count=500, behind_chart=true)

// ==========================================
// BOS & CHoCH INPUTS
// ==========================================
G_BOS = "BOS & CHoCH Settings"
bos_length  = input.int(5, minval=1, title="Pivot Length", group=G_BOS)
showLabels  = input.bool(true, title="Show BOS/CHoCH Labels", group=G_BOS)
colBull     = input.color(#089981, "Bullish Color", group=G_BOS)
colBear     = input.color(#f23645, "Bearish Color", group=G_BOS)

// ==========================================
// VOLUME IMBALANCE INPUTS
// ==========================================
bool classicvi  = false
bool advancedvi = false
vitype = input.string('Classic', 'Volume Imbalance Type', options=['None', 'Classic', 'Advanced'], group='Volume Imbalance', tooltip='Classic mode includes only a single type of body gap, while advanced mode covers all body gap variants.')

if vitype == 'Classic'
    classicvi  := true
    advancedvi := false
else if vitype == 'Advanced'
    classicvi  := false
    advancedvi := true
else if vitype == 'None'
    classicvi  := false
    advancedvi := false

bullimbalance    = input.color(color.new(#b5892a, 80), 'Bullish VI Color', group='Volume Imbalance', inline='1')
bearimbalance    = input.color(color.new(#e30000, 90), 'Bearish VI Color', group='Volume Imbalance', inline='1')
viMaxBoxSet      = input.int(defval=8, title='Maximum Box Displayed', minval=1, maxval=100, group='Volume Imbalance')
vimitigationtype = input.string(defval='Engulf', title='VI Mitigation Type', options=['Engulf', 'Mitigate'], group='Volume Imbalance')
extendvibox      = input.bool(true, title='Extend Unmitigated VI Boxes', group='Volume Imbalance')
extendallvis     = input.bool(false, title='Extend all VI Boxes', group='Volume Imbalance')

// ==========================================
// GAP INPUTS
// ==========================================
gaptype = input.string('True GAP', 'GAPs Type', options=['None', 'True GAP', 'GAP + Inefficiency'], group='GAP')

bool truegap    = false
bool gapwithimb = false

if gaptype == 'True GAP'
    truegap    := true
    gapwithimb := false
else if gaptype == 'GAP + Inefficiency'
    truegap    := false
    gapwithimb := true
else if gaptype == 'None'
    truegap    := false
    gapwithimb := false

gapcolor          = input.color(color.new(#4ec1f7, 90), 'GAP Color', group='GAP')
gapsMaxBoxSet     = input.int(defval=7, title='Maximum Box Displayed', minval=1, maxval=100, group='GAP')
cegap             = input.bool(true, title='GAP Consequent Encroachment (C.E.)', group='GAP')
cegaplinetype     = input.string(line.style_dashed, 'C.E. Line Style', options=[line.style_dashed, line.style_dotted, line.style_solid], group='GAP')
gapmitigationtype = input.string(defval='Engulf', title='GAP Mitigation Type', options=['Engulf', 'Rebalance'], group='GAP')
extendgapbox      = input.bool(true, title='Extend Unmitigated GAP Boxes', group='GAP')

// ==========================================
// FVG INPUTS
// ==========================================
fvgtype        = input.string('Normal', 'FVG Type', options=['None', 'Normal', 'Liquidity Void'], inline='18', group='FVG')
showifvg       = input.bool(true, 'IMPLIED FVG', inline='19', group='FVG')
Inversefvgmode = input.bool(false, 'INVERSE FVG', group='FVG', inline='19')

bool plotFVG           = fvgtype == 'Normal'
bool liquidityvoidmode = fvgtype == 'Liquidity Void'

fvgBullColor    = input.color(defval=color.new(color.green, 90), title='Bullish FVG', inline='1', group='FVG')
fvgBearColor    = input.color(defval=color.new(color.red, 90),   title='Bearish FVG', inline='1', group='FVG')
ifvgBullColor   = input.color(defval=color.new(color.green, 90), title='Bullish IMP.FVG', inline='3', group='FVG')
ifvgBearColor   = input.color(defval=color.new(color.red, 90),   title='Bearish IMP.FVG', inline='3', group='FVG')
buinvfvgcolor   = input.color(defval=color.new(#fbc02d, 94),     title='Bullish INV.FVG', inline='4', group='FVG')
beinvfvgcolor   = input.color(defval=color.new(#fbc02d, 94),     title='Bearish INV.FVG', inline='4', group='FVG')
fvgMaxBoxSet    = input.int(defval=15, title='FVG/IMP.FVG Box Limit', minval=1, maxval=100, group='FVG')
invfvgMaxBoxSet = input.int(defval=4,  title='Inverse FVG Box Limit',  minval=1, maxval=100, group='FVG')
fvgmitigationtype  = input.string(defval='Engulf', title='FVG/LV Mitigation',    options=['Engulf', 'Mitigate', 'Rebalance'], group='FVG')
ifvgmitigationtype = input.string(defval='Engulf', title='IMPLIED FVG Mitigation', options=['Engulf', 'Mitigate'], group='FVG')
cefvg           = input.bool(true, title='FVG Consequent Encroachment (C.E.)', group='FVG')
celinetype      = input.string(line.style_dashed, 'C.E. Line Style', options=[line.style_dashed, line.style_dotted, line.style_solid], group='FVG')
cetransparency  = input.int(50, title='C.E. Transparency', group='FVG')
extendfvgbox    = input.bool(true, title='Extend All Unmitigated Boxes', group='FVG')

// ==========================================
// BOX STYLE INPUTS
// ==========================================
BoxBorder                      = input.string(defval=line.style_solid, title='Box Border Style', options=[line.style_dashed, line.style_dotted, line.style_solid], group='Box Style')
BorderTransparency             = input.int(defval=85, title='Border Box Transparency', minval=0, maxval=100, group='Box Style')
HighlightBox                   = input.bool(defval=true, title='Highlight Box', group='Box Style')
Highlightboxtransparancy       = input.int(80, 'Highlight Box BG', group='Box Style')
Highlightboxbordertransparancy = input.int(67, 'Highlight Box Border', group='Box Style')
plotBoxLabel                   = input.bool(defval=true, title='Plot Label', group='Box Style')
BoxLabelSize                   = input.string(defval=size.tiny, title='Label Size', options=[size.huge, size.large, size.small, size.tiny, size.auto, size.normal], group='Box Style')
BoxLabelColor                  = input.color(defval=color.rgb(161, 163, 171), title='Label Color', group='Box Style')
labelhalign                    = input.string(text.align_center, 'Label Horizontal Align', options=[text.align_center, text.align_right, text.align_left], group='Box Style')
labelvalign                    = input.string(text.align_center, 'Label Vertical Align', options=[text.align_top, text.align_center, text.align_bottom], group='Box Style')
filterMitBOX                   = input.bool(defval=true, title='Mitigated Box Color', group='Mitigated Box Style')
mitBOXColor                    = input.color(defval=color.new(color.gray, 92), title='Mitigated Box Color', group='Mitigated Box Style')
MitBoxLabelColor               = input.color(defval=color.rgb(161, 163, 171, 88), title='Mitigated Box Label Color', group='Mitigated Box Style')

// ==========================================
// BOS & CHoCH LOGIC
// ==========================================
ph = ta.pivothigh(high, bos_length, bos_length)
pl = ta.pivotlow(low,   bos_length, bos_length)

var float swingHighPrice = na
var int   swingHighIndex = na
var float swingLowPrice  = na
var int   swingLowIndex  = na
var int   trend          = 0

if not na(ph)
    swingHighPrice := high[bos_length]
    swingHighIndex := bar_index[bos_length]

if not na(pl)
    swingLowPrice := low[bos_length]
    swingLowIndex := bar_index[bos_length]

drawBOSLine(x1, y1, x2, y2, col, txt) =>
    line.new(x1, y1, x2, y2, color=col, style=line.style_solid, width=1)
    if showLabels
        int midpoint = int(math.avg(x1, x2))
        label.new(midpoint, y1, text=txt, color=color.new(color.white, 100),
                  style=label.style_label_down, textcolor=col, size=size.tiny)

if not na(swingHighPrice) and close > swingHighPrice
    if trend == -1
        drawBOSLine(swingHighIndex, swingHighPrice, bar_index, swingHighPrice, colBull, "CHoCH")
        trend := 1
    else
        drawBOSLine(swingHighIndex, swingHighPrice, bar_index, swingHighPrice, colBull, "BOS")
        trend := 1
    swingHighPrice := na

if not na(swingLowPrice) and close < swingLowPrice
    if trend == 1
        drawBOSLine(swingLowIndex, swingLowPrice, bar_index, swingLowPrice, colBear, "CHoCH")
        trend := -1
    else
        drawBOSLine(swingLowIndex, swingLowPrice, bar_index, swingLowPrice, colBear, "BOS")
        trend := -1
    swingLowPrice := na

// ==========================================
// ICT STATE VARIABLES
// ==========================================
var bool buimpfvgtouch = false
var bool beimpfvgtouch = false
var bool bufvgtouch    = false
var bool befvgtouch    = false
var bool buvitouch     = false
var bool bevitouch     = false
var bool bugaptouch    = false
var bool begaptouch    = false
var bool buinvfvgtouch = false
var bool beinvfvgtouch = false

bool isbuinversefvg = false
bool isbeinversefvg = false

var array<box>  _bearBoxesFVG = array.new_box()
var array<box>  _bullBoxesFVG = array.new_box()
var array<box>  _gapsboxesbu  = array.new_box()
var array<box>  _gapsboxesbe  = array.new_box()
var array<box>  _bullishvi    = array.new_box()
var array<box>  _bearishvi    = array.new_box()
var array<box>  _bullishifvg  = array.new_box()
var array<box>  _bearishifvg  = array.new_box()
var array<line> _bufvgce      = array.new_line()
var array<line> _befvgce      = array.new_line()
var array<box>  bearInvFVG    = array.new_box()
var array<box>  bullInvFVG    = array.new_box()
var array<line> buinvfvgce    = array.new_line()
var array<line> beinvfvgce    = array.new_line()
var array<line> bugapce       = array.new_line()
var array<line> begapce       = array.new_line()

// ==========================================
// VOLUME IMBALANCE FUNCTIONS
// ==========================================
_controlBox2(_boxes) =>
    if array.size(_boxes) > 0
        for i = array.size(_boxes) - 1 to 0 by 1
            _box = array.get(_boxes, i)
            if extendallvis
                box.set_right(_box, bar_index + 1)

isBuVItype1(index) => open[index] > close[index+1] and low[index] <= high[index+1] and close[index] > open[index] and close[index+1] > open[index+1]
isBeVItype1(index) => open[index] < close[index+1] and high[index] >= low[index+1] and close[index] < open[index] and close[index+1] < open[index+1]
isBuVItype2(index) => open[index] < close[index+1] and close[index] > open[index] and close[index+1] > open[index+1] and high[index] >= low[index+1]
isBeVItype2(index) => open[index] > close[index+1] and close[index] < open[index] and close[index+1] < open[index+1] and low[index] <= high[index+1]
isBuVItype3(index) => (open[index] > close[index+1] or open[index] < close[index+1]) and close[index] > open[index] and close[index+1] < open[index+1] and high[index] >= low[index+1] and low[index] <= high[index+1]
isBeVItype3(index) => (open[index] < close[index+1] or open[index] > close[index+1]) and close[index] < open[index] and close[index+1] > open[index+1] and low[index] <= high[index+1] and high[index] >= low[index+1]

if isBuVItype1(0) and (classicvi or advancedvi)
    _bullboxVI = box.new(left=bar_index-1, top=open, right=bar_index+1, bottom=close[1], bgcolor=bullimbalance, border_style=BoxBorder, border_color=color.new(bullimbalance, BorderTransparency), text=plotBoxLabel ? 'VI+' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bullishvi) > viMaxBoxSet
        box.delete(array.shift(_bullishvi))
    array.push(_bullishvi, _bullboxVI)

if isBeVItype1(0) and (classicvi or advancedvi)
    _bearboxVI = box.new(left=bar_index-1, top=close[1], right=bar_index+1, bottom=open, bgcolor=bearimbalance, border_style=BoxBorder, border_color=color.new(bearimbalance, BorderTransparency), text=plotBoxLabel ? 'VI-' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bearishvi) > viMaxBoxSet
        box.delete(array.shift(_bearishvi))
    array.push(_bearishvi, _bearboxVI)

if isBuVItype2(0) and advancedvi
    _bullboxVI = box.new(left=bar_index-1, top=close[1], right=bar_index+1, bottom=open, bgcolor=bullimbalance, border_style=BoxBorder, border_color=color.new(bullimbalance, BorderTransparency), text=plotBoxLabel ? 'VI+' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bullishvi) > viMaxBoxSet
        box.delete(array.shift(_bullishvi))
    array.push(_bullishvi, _bullboxVI)

if isBeVItype2(0) and advancedvi
    _bearboxVI = box.new(left=bar_index-1, top=open, right=bar_index+1, bottom=close[1], bgcolor=bearimbalance, border_style=BoxBorder, border_color=color.new(bearimbalance, BorderTransparency), text=plotBoxLabel ? 'VI-' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bearishvi) > viMaxBoxSet
        box.delete(array.shift(_bearishvi))
    array.push(_bearishvi, _bearboxVI)

if isBuVItype3(0) and advancedvi
    _bullboxVI = box.new(left=bar_index-1, top=math.max(open, close[1]), right=bar_index+1, bottom=math.min(open, close[1]), bgcolor=bullimbalance, border_style=BoxBorder, border_color=color.new(bullimbalance, BorderTransparency), text=plotBoxLabel ? 'VI+' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bullishvi) > viMaxBoxSet
        box.delete(array.shift(_bullishvi))
    array.push(_bullishvi, _bullboxVI)

if isBeVItype3(0) and advancedvi
    _bearboxVI = box.new(left=bar_index-1, top=math.min(open, close[1]), right=bar_index+1, bottom=math.max(open, close[1]), bgcolor=bearimbalance, border_style=BoxBorder, border_color=color.new(bearimbalance, BorderTransparency), text=plotBoxLabel ? 'VI-' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bearishvi) > viMaxBoxSet
        box.delete(array.shift(_bearishvi))
    array.push(_bearishvi, _bearboxVI)

_controlBox2(_bullishvi)
_controlBox2(_bearishvi)

// ==========================================
// GAP LOGIC
// ==========================================
if (high[1] < low or low[1] > high) and truegap
    box  _gapsbu     = na
    box  _gapsbe     = na
    line bugapceline = na
    line begapceline = na
    if high[1] < low
        _gapsbu     := box.new(left=bar_index-1, top=low, right=bar_index+1, bottom=high[1], bgcolor=gapcolor, border_color=color.new(gapcolor, BorderTransparency), text=plotBoxLabel ? 'GAP+' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        bugapceline := cegap ? line.new(bar_index-1, math.avg(low, high[1]), bar_index, math.avg(low, high[1]), style=cegaplinetype, color=color.new(gapcolor, cetransparency)) : na
    else if low[1] > high
        _gapsbe     := box.new(left=bar_index-1, top=low[1], right=bar_index+1, bottom=high, bgcolor=gapcolor, border_color=color.new(gapcolor, BorderTransparency), text=plotBoxLabel ? 'GAP-' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        begapceline := cegap ? line.new(bar_index-1, math.avg(low[1], high), bar_index, math.avg(low[1], high), style=cegaplinetype, color=color.new(gapcolor, cetransparency)) : na
    if array.size(_gapsboxesbu) > gapsMaxBoxSet and array.size(bugapce) > gapsMaxBoxSet
        box.delete(array.shift(_gapsboxesbu))
        line.delete(array.shift(bugapce))
    array.push(_gapsboxesbu, _gapsbu)
    array.push(bugapce, bugapceline)
    if array.size(_gapsboxesbe) > gapsMaxBoxSet and array.size(begapce) > gapsMaxBoxSet
        box.delete(array.shift(_gapsboxesbe))
        line.delete(array.shift(begapce))
    array.push(_gapsboxesbe, _gapsbe)
    array.push(begapce, begapceline)

else if (high[1] < low or low[1] > high) and gapwithimb
    box  _gapsbu     = na
    box  _gapsbe     = na
    line bugapceline = na
    line begapceline = na
    if high[1] < low
        _gapsbu     := box.new(left=bar_index-1, top=open, right=bar_index+1, bottom=close[1], bgcolor=gapcolor, border_color=color.new(gapcolor, BorderTransparency), text=plotBoxLabel ? 'GAP+' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        bugapceline := cegap ? line.new(bar_index-1, math.avg(open, close[1]), bar_index, math.avg(open, close[1]), style=cegaplinetype, color=color.new(gapcolor, cetransparency)) : na
    else if low[1] > high
        _gapsbe     := box.new(left=bar_index-1, top=close[1], right=bar_index+1, bottom=open, bgcolor=gapcolor, border_color=color.new(gapcolor, BorderTransparency), text=plotBoxLabel ? 'GAP-' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        begapceline := cegap ? line.new(bar_index-1, math.avg(close[1], open), bar_index, math.avg(close[1], open), style=cegaplinetype, color=color.new(gapcolor, cetransparency)) : na
    if array.size(_gapsboxesbu) > gapsMaxBoxSet and array.size(bugapce) > gapsMaxBoxSet
        box.delete(array.shift(_gapsboxesbu))
        line.delete(array.shift(bugapce))
    array.push(_gapsboxesbu, _gapsbu)
    array.push(bugapce, bugapceline)
    if array.size(_gapsboxesbe) > gapsMaxBoxSet and array.size(begapce) > gapsMaxBoxSet
        box.delete(array.shift(_gapsboxesbe))
        line.delete(array.shift(begapce))
    array.push(_gapsboxesbe, _gapsbe)
    array.push(begapce, begapceline)

// ==========================================
// FVG FUNCTIONS
// ==========================================
isFvgUp(index)   => low[index] > high[index+2] and low[index+1] <= high[index+2] and high[index+1] >= low[index]
isFvgDown(index) => high[index] < low[index+2] and high[index] >= low[index+1] and high[index+1] >= low[index+2]
isBuIFvg(index)  => high[index] > high[index+2] and low[index+2] < low[index] and low[index] <= high[index+2] and high[index+2] - math.max(open[index+2], close[index+2]) > (math.max(open[index+2], close[index+2]) - math.min(open[index+2], close[index+2])) / 2 and math.min(open[index], close[index]) - low[index] > (math.max(open[index], close[index]) - math.min(open[index], close[index])) / 2 and low[index] > low[index+1] and (high[index+2] + math.max(open[index+2], close[index+2])) / 2 < (math.min(open[index], close[index]) + low[index]) / 2 and high[index] > high[index+1] and close[index+1] > open[index+1]
isBeIFvg(index)  => low[index] < low[index+2] and high[index+2] > high[index] and high[index] >= low[index+2] and math.min(open[index+2], close[index+2]) - low[index+2] > (math.max(open[index+2], close[index+2]) - math.min(open[index+2], close[index+2])) / 2 and high[index] - math.max(open[index], close[index]) > (math.max(open[index], close[index]) - math.min(open[index], close[index])) / 2 and high[index] < high[index+1] and (math.min(open[index+2], close[index+2]) + low[index+2]) / 2 > (high[index] + math.max(open[index], close[index])) / 2 and low[index] < low[index+1] and close[index+1] < open[index+1]

// ==========================================
// FVG DETECTION
// ==========================================
if isFvgUp(0) and not liquidityvoidmode
    line _buline     = na
    box  _bullboxFVG = na
    if plotFVG or Inversefvgmode
        _bullboxFVG := box.new(left=bar_index-2, top=low[0], right=bar_index, bottom=high[2], bgcolor=fvgBullColor, border_color=color.new(fvgBullColor, BorderTransparency), border_style=BoxBorder, border_width=1, text=plotBoxLabel ? 'FVG+' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        _buline     := cefvg ? line.new(bar_index-2, math.avg(low, high[2]), bar_index, math.avg(low, high[2]), style=celinetype, color=color.new(fvgBullColor, cetransparency)) : na
    if array.size(_bullBoxesFVG) > fvgMaxBoxSet and array.size(_bufvgce) > fvgMaxBoxSet
        box.delete(array.shift(_bullBoxesFVG))
        line.delete(array.shift(_bufvgce))
    array.push(_bullBoxesFVG, _bullboxFVG)
    array.push(_bufvgce, _buline)

if isFvgDown(0) and not liquidityvoidmode
    line _beline     = na
    box  _bearboxFVG = na
    if plotFVG or Inversefvgmode
        _bearboxFVG := box.new(left=bar_index-2, top=low[2], right=bar_index, bottom=high[0], bgcolor=fvgBearColor, border_color=color.new(fvgBearColor, BorderTransparency), border_style=BoxBorder, border_width=1, text=plotBoxLabel ? 'FVG-' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        _beline     := cefvg ? line.new(bar_index-2, math.avg(low[2], high), bar_index, math.avg(low[2], high), style=celinetype, color=color.new(fvgBearColor, cetransparency)) : na
    if array.size(_bearBoxesFVG) > fvgMaxBoxSet and array.size(_befvgce) > fvgMaxBoxSet
        box.delete(array.shift(_bearBoxesFVG))
        line.delete(array.shift(_befvgce))
    array.push(_bearBoxesFVG, _bearboxFVG)
    array.push(_befvgce, _beline)

// ==========================================
// LIQUIDITY VOID MODE
// ==========================================
bool bulv = false
bool belv = false

for i = 0 to 10 by 1
    if isFvgUp(i) and isFvgUp(i+1) and (liquidityvoidmode or Inversefvgmode) and array.size(_bullBoxesFVG) > 0 and not plotFVG
        bulv := true
        x    = array.size(_bullBoxesFVG) - 1
        _box = array.get(_bullBoxesFVG, x)
        tempboxlow  = box.get_bottom(_box)
        tempboxleft = box.get_left(_box)
        box.delete(array.pop(_bullBoxesFVG))
        line.delete(array.pop(_bufvgce))
        _bullboxFVG = box.new(left=tempboxleft, top=low[0], right=bar_index, bottom=tempboxlow, bgcolor=fvgBullColor, border_color=color.new(fvgBullColor, BorderTransparency), border_width=1, text=plotBoxLabel ? 'LV+' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        _buline     = cefvg ? line.new(tempboxleft, math.avg(low, tempboxlow), bar_index, math.avg(low, tempboxlow), style=celinetype, color=color.new(fvgBullColor, cetransparency)) : na
        if array.size(_bullBoxesFVG) > fvgMaxBoxSet and array.size(_bufvgce) > fvgMaxBoxSet
            box.delete(array.shift(_bullBoxesFVG))
            line.delete(array.shift(_bufvgce))
        array.push(_bullBoxesFVG, _bullboxFVG)
        array.push(_bufvgce, _buline)
    if isFvgUp(i) and not isFvgUp(i+1) and (liquidityvoidmode or Inversefvgmode) and not plotFVG
        _bullboxFVG = box.new(left=bar_index-2, top=low[0], right=bar_index, bottom=high[2], bgcolor=fvgBullColor, border_color=color.new(fvgBullColor, BorderTransparency), border_width=1, text=plotBoxLabel ? 'FVG+' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        _buline     = cefvg ? line.new(bar_index-2, math.avg(low, high[2]), bar_index, math.avg(low, high[2]), style=celinetype, color=color.new(fvgBullColor, cetransparency)) : na
        if array.size(_bullBoxesFVG) > fvgMaxBoxSet and array.size(_bufvgce) > fvgMaxBoxSet
            box.delete(array.shift(_bullBoxesFVG))
            line.delete(array.shift(_bufvgce))
        array.push(_bullBoxesFVG, _bullboxFVG)
        array.push(_bufvgce, _buline)
    break

for i = 0 to 10 by 1
    if isFvgDown(i) and isFvgDown(i+1) and (liquidityvoidmode or Inversefvgmode) and array.size(_bearBoxesFVG) > 0 and not plotFVG
        belv := true
        x    = array.size(_bearBoxesFVG) - 1
        _box = array.get(_bearBoxesFVG, x)
        tempboxhigh = box.get_top(_box)
        tempboxleft = box.get_left(_box)
        box.delete(array.pop(_bearBoxesFVG))
        line.delete(array.pop(_befvgce))
        _bearboxFVG = box.new(left=tempboxleft, top=tempboxhigh, right=bar_index, bottom=high[0], bgcolor=fvgBearColor, border_color=color.new(fvgBearColor, BorderTransparency), border_width=1, text=plotBoxLabel ? 'LV-' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        _beline     = cefvg ? line.new(tempboxleft, math.avg(tempboxhigh, high), bar_index, math.avg(tempboxhigh, high), style=celinetype, color=color.new(fvgBearColor, cetransparency)) : na
        if array.size(_bearBoxesFVG) > fvgMaxBoxSet and array.size(_befvgce) > fvgMaxBoxSet
            box.delete(array.shift(_bearBoxesFVG))
            line.delete(array.shift(_befvgce))
        array.push(_bearBoxesFVG, _bearboxFVG)
        array.push(_befvgce, _beline)
    if isFvgDown(i) and not isFvgDown(i+1) and (liquidityvoidmode or Inversefvgmode) and not plotFVG
        _bearboxFVG = box.new(left=bar_index-2, top=low[2], right=bar_index, bottom=high[0], bgcolor=fvgBearColor, border_color=color.new(fvgBearColor, BorderTransparency), border_width=1, text=plotBoxLabel ? 'FVG-' : na, border_style=BoxBorder, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
        _beline     = cefvg ? line.new(bar_index-2, math.avg(low[2], high), bar_index, math.avg(low[2], high), style=celinetype, color=color.new(fvgBearColor, cetransparency)) : na
        if array.size(_bearBoxesFVG) > fvgMaxBoxSet and array.size(_befvgce) > fvgMaxBoxSet
            box.delete(array.shift(_bearBoxesFVG))
            line.delete(array.shift(_befvgce))
        array.push(_bearBoxesFVG, _bearboxFVG)
        array.push(_befvgce, _beline)
    break

// ==========================================
// IMPLIED FVG
// ==========================================
if isBuIFvg(0) and showifvg
    _bullboxifvg = box.new(left=bar_index-2, top=(math.min(open, close) + low) / 2, right=bar_index+1, bottom=(high[2] + math.max(open[2], close[2])) / 2, bgcolor=ifvgBullColor, border_style=BoxBorder, border_color=color.new(ifvgBullColor, BorderTransparency), text=plotBoxLabel ? 'Imp.FVG+' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bullishifvg) > fvgMaxBoxSet
        box.delete(array.shift(_bullishifvg))
    array.push(_bullishifvg, _bullboxifvg)

if isBeIFvg(0) and showifvg
    _bearboxifvg = box.new(left=bar_index-2, top=(math.min(open[2], close[2]) + low[2]) / 2, right=bar_index+1, bottom=(math.max(open, close) + high) / 2, bgcolor=ifvgBearColor, border_style=BoxBorder, border_color=color.new(ifvgBearColor, BorderTransparency), text=plotBoxLabel ? 'Imp.FVG-' : na, text_halign=labelhalign, text_valign=labelvalign, text_size=BoxLabelSize, text_color=BoxLabelColor)
    if array.size(_bearishifvg) > fvgMaxBoxSet
        box.delete(array.shift(_bearishifvg))
    array.push(_bearishifvg, _bearboxifvg)

// ==========================================
// IMPLIED FVG EXTEND - ENGULF
// ==========================================
if array.size(_bullishifvg) > 0 and extendfvgbox and barstate.isconfirmed and ifvgmitigationtype == 'Engulf'
    for i = array.size(_bullishifvg) - 1 to 0 by 1
        _box      = array.get(_bullishifvg, i)
        _boxLow   = box.get_bottom(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if (close < _boxLow or open < _boxLow) and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)

if array.size(_bearishifvg) > 0 and extendfvgbox and barstate.isconfirmed and ifvgmitigationtype == 'Engulf'
    for i = array.size(_bearishifvg) - 1 to 0 by 1
        _box      = array.get(_bearishifvg, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if (close > _boxHigh or open > _boxHigh) and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)

if array.size(_bullishifvg) > 0 and extendfvgbox and ifvgmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bullishifvg) - 1 to 0 by 1
        _box      = array.get(_bullishifvg, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight and low < _boxHigh
            box.set_bgcolor(_box, color.new(ifvgBullColor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(ifvgBullColor, Highlightboxbordertransparancy))
            buimpfvgtouch := true

if array.size(_bearishifvg) > 0 and extendfvgbox and ifvgmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bearishifvg) - 1 to 0 by 1
        _box      = array.get(_bearishifvg, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight and high > _boxLow
            box.set_bgcolor(_box, color.new(ifvgBearColor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(ifvgBearColor, Highlightboxbordertransparancy))
            beimpfvgtouch := true

// ==========================================
// IMPLIED FVG EXTEND - MITIGATE
// ==========================================
if array.size(_bullishifvg) > 0 and extendfvgbox and barstate.isconfirmed and ifvgmitigationtype == 'Mitigate'
    for i = array.size(_bullishifvg) - 1 to 0 by 1
        _box      = array.get(_bullishifvg, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if low >= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if low < _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)

if array.size(_bearishifvg) > 0 and extendfvgbox and barstate.isconfirmed and ifvgmitigationtype == 'Mitigate'
    for i = array.size(_bearishifvg) - 1 to 0 by 1
        _box      = array.get(_bearishifvg, i)
        _boxLow   = box.get_bottom(_box)
        _boxRight = box.get_right(_box)
        if high <= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if high > _boxLow and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)

// ==========================================
// FVG EXTEND - ENGULF
// ==========================================
if array.size(_bullBoxesFVG) > 0 and array.size(_bufvgce) > 0 and extendfvgbox and barstate.isconfirmed and fvgmitigationtype == 'Engulf'
    for i = array.size(_bullBoxesFVG) - 1 to 0 by 1
        box  beifvgbox    = na
        line beifvgceline = na
        _line     = array.get(_bufvgce, i)
        _box      = array.get(_bullBoxesFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if close < _boxLow and bar_index == _boxRight and Inversefvgmode
            beifvgbox    := box.copy(_box)
            beifvgceline := line.copy(_line)
            array.push(bearInvFVG, beifvgbox)
            array.push(beinvfvgce, beifvgceline)
            box.delete(_box)
            line.delete(_line)
            isbeinversefvg := true
        else if close < _boxLow and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_bearBoxesFVG) > 0 and array.size(_befvgce) > 0 and extendfvgbox and barstate.isconfirmed and fvgmitigationtype == 'Engulf'
    for i = array.size(_bearBoxesFVG) - 1 to 0 by 1
        box  buifvgbox    = na
        line buifvgceline = na
        _line     = array.get(_befvgce, i)
        _box      = array.get(_bearBoxesFVG, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if close > _boxHigh and bar_index == _boxRight and Inversefvgmode
            buifvgbox    := box.copy(_box)
            buifvgceline := line.copy(_line)
            array.push(bullInvFVG, buifvgbox)
            array.push(buinvfvgce, buifvgceline)
            box.delete(_box)
            line.delete(_line)
            isbuinversefvg := true
        else if close > _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_bullBoxesFVG) > 0 and extendfvgbox and fvgmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bullBoxesFVG) - 1 to 0 by 1
        _box      = array.get(_bullBoxesFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight and low < _boxHigh
            box.set_bgcolor(_box, color.new(fvgBullColor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(fvgBullColor, Highlightboxbordertransparancy))
            bufvgtouch := true

if array.size(_bearBoxesFVG) > 0 and extendfvgbox and fvgmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bearBoxesFVG) - 1 to 0 by 1
        _box      = array.get(_bearBoxesFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight and high > _boxLow
            box.set_bgcolor(_box, color.new(fvgBearColor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(fvgBearColor, Highlightboxbordertransparancy))
            befvgtouch := true

// ==========================================
// INVERSE FVG EXTEND
// ==========================================
if array.size(bullInvFVG) > 0 and barstate.isconfirmed and fvgmitigationtype == 'Engulf' and Inversefvgmode
    for i = array.size(bullInvFVG) - 1 to 0 by 1
        _box      = array.get(bullInvFVG, i)
        _line     = array.get(buinvfvgce, i)
        _boxLow   = box.get_bottom(_box)
        _boxRight = box.get_right(_box)
        box.set_bgcolor(_box, buinvfvgcolor)
        box.set_border_color(_box, color.new(buinvfvgcolor, BorderTransparency))
        line.set_color(_line, color.new(buinvfvgcolor, cetransparency))
        line.set_style(_line, celinetype)
        if plotBoxLabel
            box.set_text(_box, 'I.FVG+')
            box.set_text_halign(_box, labelhalign)
            box.set_text_valign(_box, labelvalign)
            box.set_text_size(_box, BoxLabelSize)
            box.set_text_color(_box, BoxLabelColor)
        if close >= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if close < _boxLow
            box.delete(_box)
            line.delete(_line)

if array.size(bearInvFVG) > 0 and barstate.isconfirmed and fvgmitigationtype == 'Engulf' and Inversefvgmode
    for i = array.size(bearInvFVG) - 1 to 0 by 1
        _box      = array.get(bearInvFVG, i)
        _line     = array.get(beinvfvgce, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        box.set_bgcolor(_box, beinvfvgcolor)
        box.set_border_color(_box, color.new(beinvfvgcolor, BorderTransparency))
        line.set_color(_line, color.new(beinvfvgcolor, cetransparency))
        line.set_style(_line, celinetype)
        if plotBoxLabel
            box.set_text(_box, 'I.FVG-')
            box.set_text_halign(_box, labelhalign)
            box.set_text_valign(_box, labelvalign)
            box.set_text_size(_box, BoxLabelSize)
            box.set_text_color(_box, BoxLabelColor)
        if close <= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if close > _boxHigh
            box.delete(_box)
            line.delete(_line)

if array.size(bullInvFVG) > 0 and extendfvgbox and fvgmitigationtype == 'Engulf' and Inversefvgmode and HighlightBox
    for i = array.size(bullInvFVG) - 1 to 0 by 1
        _box      = array.get(bullInvFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight and low < _boxHigh
            box.set_bgcolor(_box, color.new(buinvfvgcolor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(buinvfvgcolor, Highlightboxbordertransparancy))
            buinvfvgtouch := true

if array.size(bearInvFVG) > 0 and extendfvgbox and fvgmitigationtype == 'Engulf' and Inversefvgmode and HighlightBox
    for i = array.size(bearInvFVG) - 1 to 0 by 1
        _box      = array.get(bearInvFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight and high > _boxLow
            box.set_bgcolor(_box, color.new(beinvfvgcolor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(beinvfvgcolor, Highlightboxbordertransparancy))
            beinvfvgtouch := true

// ==========================================
// INVERSE FVG ONLY MODE
// ==========================================
if array.size(_bearBoxesFVG) > 0 and array.size(_befvgce) > 0 and not plotFVG and not liquidityvoidmode and Inversefvgmode
    for i = array.size(_bearBoxesFVG) - 1 to 0 by 1
        _box  = array.get(_bearBoxesFVG, i)
        _line = array.get(_befvgce, i)
        box.set_bgcolor(_box, color.new(fvgBearColor, 100))
        box.set_text_color(_box, color.new(BoxLabelColor, 100))
        box.set_border_color(_box, color.new(fvgBearColor, 100))
        line.set_color(_line, color.new(fvgBearColor, 100))

if array.size(_bullBoxesFVG) > 0 and array.size(_bufvgce) > 0 and not plotFVG and not liquidityvoidmode and Inversefvgmode
    for i = array.size(_bullBoxesFVG) - 1 to 0 by 1
        _box  = array.get(_bullBoxesFVG, i)
        _line = array.get(_bufvgce, i)
        box.set_bgcolor(_box, color.new(fvgBullColor, 100))
        box.set_text_color(_box, color.new(BoxLabelColor, 100))
        box.set_border_color(_box, color.new(fvgBullColor, 100))
        line.set_color(_line, color.new(fvgBullColor, 100))

// ==========================================
// FVG EXTEND - MITIGATE
// ==========================================
if array.size(_bullBoxesFVG) > 0 and array.size(_bufvgce) > 0 and extendfvgbox and barstate.isconfirmed and fvgmitigationtype == 'Mitigate'
    for i = array.size(_bullBoxesFVG) - 1 to 0 by 1
        _line     = array.get(_bufvgce, i)
        _box      = array.get(_bullBoxesFVG, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if low >= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if low < _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_bearBoxesFVG) > 0 and array.size(_befvgce) > 0 and extendfvgbox and barstate.isconfirmed and fvgmitigationtype == 'Mitigate'
    for i = array.size(_bearBoxesFVG) - 1 to 0 by 1
        _line     = array.get(_befvgce, i)
        _box      = array.get(_bearBoxesFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxRight = box.get_right(_box)
        if high <= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if high > _boxLow and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

// ==========================================
// FVG EXTEND - REBALANCE
// ==========================================
if array.size(_bullBoxesFVG) > 0 and array.size(_bufvgce) > 0 and extendfvgbox and fvgmitigationtype == 'Rebalance' and barstate.isconfirmed
    for i = array.size(_bullBoxesFVG) - 1 to 0 by 1
        _box      = array.get(_bullBoxesFVG, i)
        _line     = array.get(_bufvgce, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if low >= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if low < _boxHigh and low > _boxLow and bar_index == _boxRight
            box.set_top(_box, low)
            box.set_right(_box, bar_index + 1)
            line.set_y1(_line, (low + _boxLow) / 2)
            line.set_y2(_line, (low + _boxLow) / 2)
            line.set_x2(_line, bar_index + 1)
        else if low <= _boxLow and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_bearBoxesFVG) > 0 and array.size(_befvgce) > 0 and extendfvgbox and fvgmitigationtype == 'Rebalance' and barstate.isconfirmed
    for i = array.size(_bearBoxesFVG) - 1 to 0 by 1
        _box      = array.get(_bearBoxesFVG, i)
        _line     = array.get(_befvgce, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if high <= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if high > _boxLow and high < _boxHigh and bar_index == _boxRight
            box.set_bottom(_box, high)
            box.set_right(_box, bar_index + 1)
            line.set_y1(_line, (high + _boxHigh) / 2)
            line.set_y2(_line, (high + _boxHigh) / 2)
            line.set_x2(_line, bar_index + 1)
        else if high >= _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_bullBoxesFVG) > 0 and extendfvgbox and fvgmitigationtype == 'Rebalance' and HighlightBox
    for i = array.size(_bullBoxesFVG) - 1 to 0 by 1
        _box      = array.get(_bullBoxesFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if low < _boxHigh and bar_index == _boxRight and low > _boxLow
            box.set_bgcolor(_box, color.new(fvgBullColor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(fvgBullColor, Highlightboxbordertransparancy))
            bufvgtouch := true

if array.size(_bearBoxesFVG) > 0 and extendfvgbox and fvgmitigationtype == 'Rebalance' and HighlightBox
    for i = array.size(_bearBoxesFVG) - 1 to 0 by 1
        _box      = array.get(_bearBoxesFVG, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if high > _boxLow and bar_index == _boxRight and high < _boxHigh
            box.set_bgcolor(_box, color.new(fvgBearColor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(fvgBearColor, Highlightboxbordertransparancy))
            befvgtouch := true

// ==========================================
// INV FVG BOX LIMITS
// ==========================================
if array.size(bullInvFVG) > invfvgMaxBoxSet
    box.delete(array.shift(bullInvFVG))
if array.size(bearInvFVG) > invfvgMaxBoxSet
    box.delete(array.shift(bearInvFVG))
if array.size(buinvfvgce) > invfvgMaxBoxSet
    line.delete(array.shift(buinvfvgce))
if array.size(beinvfvgce) > invfvgMaxBoxSet
    line.delete(array.shift(beinvfvgce))

// ==========================================
// VI EXTEND - ENGULF
// ==========================================
if array.size(_bullishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Engulf'
    for i = array.size(_bullishvi) - 1 to 0 by 1
        _box      = array.get(_bullishvi, i)
        _boxLow   = box.get_bottom(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if close < _boxLow and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)

if array.size(_bearishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Engulf'
    for i = array.size(_bearishvi) - 1 to 0 by 1
        _box      = array.get(_bearishvi, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if close > _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)

if array.size(_bullishvi) > 0 and extendvibox and vimitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bullishvi) - 1 to 0 by 1
        _box      = array.get(_bullishvi, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight and low < _boxHigh
            box.set_bgcolor(_box, color.new(bullimbalance, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(bullimbalance, Highlightboxbordertransparancy))
            buvitouch := true

if array.size(_bearishvi) > 0 and extendvibox and vimitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bearishvi) - 1 to 0 by 1
        _box      = array.get(_bearishvi, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight and high > _boxLow
            box.set_bgcolor(_box, color.new(bearimbalance, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(bearimbalance, Highlightboxbordertransparancy))
            bevitouch := true

// ==========================================
// VI EXTEND - MITIGATE
// ==========================================
if array.size(_bullishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Mitigate'
    for i = array.size(_bullishvi) - 1 to 0 by 1
        _box      = array.get(_bullishvi, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if low > _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if low <= _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            buvitouch := true

if array.size(_bearishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Mitigate'
    for i = array.size(_bearishvi) - 1 to 0 by 1
        _box      = array.get(_bearishvi, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if high < _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if high >= _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            bevitouch := true

// ==========================================
// GAP EXTEND - ENGULF
// ==========================================
if array.size(_gapsboxesbu) > 0 and array.size(bugapce) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Engulf'
    for i = array.size(_gapsboxesbu) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbu, i)
        _line     = array.get(bugapce, i)
        _boxLow   = box.get_bottom(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and open >= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if (close < _boxLow or open < _boxLow) and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_gapsboxesbe) > 0 and array.size(begapce) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Engulf'
    for i = array.size(_gapsboxesbe) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbe, i)
        _line     = array.get(begapce, i)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and open <= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if (close > _boxHigh or open > _boxHigh) and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_gapsboxesbu) > 0 and extendgapbox and gapmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_gapsboxesbu) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbu, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close >= _boxLow and open >= _boxLow and bar_index == _boxRight and low < _boxHigh
            box.set_bgcolor(_box, color.new(gapcolor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(gapcolor, Highlightboxbordertransparancy))
            bugaptouch := true

if array.size(_gapsboxesbe) > 0 and extendgapbox and gapmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_gapsboxesbe) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbe, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if close <= _boxHigh and open <= _boxHigh and bar_index == _boxRight and high > _boxLow
            box.set_bgcolor(_box, color.new(gapcolor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(gapcolor, Highlightboxbordertransparancy))
            begaptouch := true

// ==========================================
// GAP EXTEND - REBALANCE
// ==========================================
if array.size(_gapsboxesbu) > 0 and array.size(bugapce) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Rebalance'
    for i = array.size(_gapsboxesbu) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbu, i)
        _line     = array.get(bugapce, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if low >= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if low < _boxHigh and low > _boxLow and bar_index == _boxRight
            box.set_top(_box, low)
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
            line.set_y1(_line, (low + _boxLow) / 2)
            line.set_y2(_line, (low + _boxLow) / 2)
        else if low <= _boxLow and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_gapsboxesbe) > 0 and array.size(begapce) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Rebalance'
    for i = array.size(_gapsboxesbe) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbe, i)
        _line     = array.get(begapce, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if high <= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            line.set_x2(_line, bar_index + 1)
        else if high > _boxLow and high < _boxHigh and bar_index == _boxRight
            box.set_bottom(_box, high)
            box.set_right(_box, bar_index + 1)
            line.set_y1(_line, (high + _boxHigh) / 2)
            line.set_y2(_line, (high + _boxHigh) / 2)
            line.set_x2(_line, bar_index + 1)
        else if high >= _boxHigh and bar_index == _boxRight and filterMitBOX
            box.set_bgcolor(_box, mitBOXColor)
            box.set_border_color(_box, mitBOXColor)
            box.set_text_color(_box, MitBoxLabelColor)
            line.set_color(_line, mitBOXColor)

if array.size(_gapsboxesbu) > 0 and extendgapbox and gapmitigationtype == 'Rebalance' and HighlightBox
    for i = array.size(_gapsboxesbu) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbu, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if low > _boxLow and bar_index == _boxRight and low < _boxHigh
            box.set_bgcolor(_box, color.new(gapcolor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(gapcolor, Highlightboxbordertransparancy))
            bugaptouch := true

if array.size(_gapsboxesbe) > 0 and extendgapbox and gapmitigationtype == 'Rebalance' and HighlightBox
    for i = array.size(_gapsboxesbe) - 1 to 0 by 1
        _box      = array.get(_gapsboxesbe, i)
        _boxLow   = box.get_bottom(_box)
        _boxHigh  = box.get_top(_box)
        _boxRight = box.get_right(_box)
        if high < _boxHigh and bar_index == _boxRight and high > _boxLow
            box.set_bgcolor(_box, color.new(gapcolor, Highlightboxtransparancy))
            box.set_border_color(_box, color.new(gapcolor, Highlightboxbordertransparancy))
            begaptouch := true

// ==========================================
// ALERTS
// ==========================================
alertcondition(barstate.isconfirmed and isFvgUp(0),   title='FVG+',         message='FVG+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isFvgDown(0), title='FVG-',         message='FVG- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isBuIFvg(0),  title='Implied.FVG+', message='I.FVG+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isBeIFvg(0),  title='Implied.FVG-', message='I.FVG- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and ((isBuVItype1(0) or isBuVItype2(0) or isBuVItype3(0)) and advancedvi or isBuVItype1(0) and classicvi), title='VI+', message='VI+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and ((isBeVItype1(0) or isBeVItype2(0) or isBeVItype3(0)) and advancedvi or isBuVItype1(0) and classicvi), title='VI-', message='VI- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and high[1] < low,  title='GAP+', message='GAP+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and low[1] > high,  title='GAP-', message='GAP- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isbuinversefvg, title='Inverse.FVG+', message='Inverse.FVG+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isbeinversefvg, title='Inverse.FVG-', message='Inverse.FVG- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and bulv, title='LV+', message='Bullish Liquidity Void : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and belv, title='LV-', message='Bearish Liquidity Void : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(bugaptouch,    title='GAP(+) Mitigation',         message='GAP(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(begaptouch,    title='GAP(-) Mitigation',         message='GAP(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(buimpfvgtouch, title='Implied.FVG(+) Mitigation', message='Implied.FVG(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(beimpfvgtouch, title='Implied.FVG(-) Mitigation', message='Implied.FVG(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(bufvgtouch,    title='FVG(+) Mitigation',         message='FVG(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(befvgtouch,    title='FVG(-) Mitigation',         message='FVG(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(buvitouch,     title='VI(+) Mitigation',          message='VI(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(bevitouch,     title='VI(-) Mitigation',          message='VI(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(buinvfvgtouch, title='Inverse.FVG(+) Mitigation', message='Inverse.FVG(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(beinvfvgtouch, title='Inverse.FVG(-) Mitigation', message='Inverse.FVG(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
````
