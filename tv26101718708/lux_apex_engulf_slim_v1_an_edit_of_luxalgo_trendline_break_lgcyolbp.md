# Lux Apex Engulf SLIM v1, an edit of LuxAlgo Trendline Break

- url: https://www.tradingview.com/script/LgCyoLBP-Lux-Apex-Engulf-SLIM-v1-an-edit-of-LuxAlgo-Trendline-Break/
- type: indicator
- pine_id: PUB;f40d1f30b5394f2db379b591f6da5573
- version: 1.0

## Description

See how well the dark blue lines play with the FibGrid?  The Lux Apex Engulf helps time entries, the FibGrid helps define targets.

## Source Code

````pine
//@version=5
indicator("Lux Apex Engulf SLIM v1", "LuxEngulf SLIM", overlay=true, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════
// TRENDLINE INPUTS + CALCULATIONS KEPT
// ═══════════════════════════════════════════════════════════════

grpLux = "TRENDLINES - THREE LUX INSTANCES"
lenFast  = input.int(50,  "TL 1 Length / Fast", minval=5, group=grpLux)
lenSlow  = input.int(100, "TL 2 Length / Mid",  minval=5, group=grpLux)
lenThird = input.int(150, "TL 3 Length / Slow", minval=5, group=grpLux)
mult     = input.float(1.0, "Shared Slope Multiplier", minval=0, step=0.1, group=grpLux)
calcMethod = input.string("Atr", "Slope Calculation Method", options=["Atr", "Stdev", "Linreg"], group=grpLux)
hitTestSource = input.string("Visible Extended Lines", "Engulf Hit-Test Source", options=["State Values", "Visible Extended Lines"], group=grpLux)
backpaint = input.bool(true, "Backpaint?", group=grpLux)
anchorSource = input.string("Wick High/Low", "Pivot Source", options=["Wick High/Low", "Body High/Low", "Close"], group=grpLux)

grpStyle = "TRENDLINE STYLE"
showAllTrendlines = input.bool(true, "Show All Trendlines?", group=grpStyle)
showExtendedLines = input.bool(true, "Show Extended Lines?", group=grpStyle)
upCol = input.color(color.new(color.teal, 30), "Upper Color", group=grpStyle)
dnCol = input.color(color.new(color.red, 30), "Lower Color", group=grpStyle)
width = input.int(2, "Line Width", minval=1, maxval=5, group=grpStyle)

grpProjection = "PROJECTION LINES"
showProjectionLines = input.bool(true, "Show Projection Lines?", group=grpProjection)
useProjectionForEngulf = input.bool(true, "Use Projection Lines For Engulf Test?", group=grpProjection)
projectionBarsMode = input.string("Each TL Length", "Projection Bars Mode", options=["Each TL Length", "Manual"], group=grpProjection)
manualProjectionBars = input.int(50, "Manual Projection Bars", minval=1, maxval=500, group=grpProjection)
projUpCol = input.color(color.new(color.teal, 45), "Projection Upper Color", group=grpProjection)
projDnCol = input.color(color.new(color.red, 45), "Projection Lower Color", group=grpProjection)
projWidth = input.int(2, "Projection Width", minval=1, maxval=5, group=grpProjection)
projStyleIn = input.string("Dashed", "Projection Style", options=["Solid", "Dashed", "Dotted"], group=grpProjection)

grpEngulf = "TRENDLINE ENGULF BARCOLOR ONLY"
showEngulf = input.bool(true, "Enable TL Engulf Barcolor?", group=grpEngulf)
minLuxLinesEngulfed = input.int(2, "Minimum TLs Engulfed Same Bar", minval=2, maxval=6, group=grpEngulf)
engulfBodyOnly = input.bool(false, "Body-Only TL Engulf?", group=grpEngulf)
engulfMinAtrPct = input.float(0.0, "TL Engulf Min Range % of ATR (0=off)", step=5.0, minval=0.0, group=grpEngulf)
requireUpperAndLowerEngulf = input.bool(false, "Require At Least 1 Upper + 1 Lower TL?", group=grpEngulf)
engulfMatchMode = input.string("Touch/Near ATR", "TL Match Mode", options=["Exact Span", "Touch/Near ATR", "Exact OR Near"], group=grpEngulf)
tlNearAtrPct = input.float(20.0, "Near TL Buffer % ATR", minval=0.0, step=1.0, group=grpEngulf)
engulfAtrLen = input.int(14, "Engulf ATR Length", minval=1, group=grpEngulf)
cooldown = input.int(0, "Barcolor Cooldown Bars", minval=0, maxval=500, group=grpEngulf)

grpBar = "BARCOLOR STYLE"
showFireBar = input.bool(true, "Color Qualified Engulf Bars?", group=grpBar)
fireBullBar = input.color(color.new(color.lime, 30), "Bull Engulf Bar", group=grpBar)
fireBearBar = input.color(color.new(color.red, 30), "Bear Engulf Bar", group=grpBar)
showDebugValues = input.bool(false, "Show Debug Values In Data Window?", group=grpBar)

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

srcHigh = anchorSource == "Wick High/Low" ? high : anchorSource == "Body High/Low" ? bodyHigh : close
srcLow  = anchorSource == "Wick High/Low" ? low  : anchorSource == "Body High/Low" ? bodyLow  : close

boolToInt(_cond) =>
    _cond ? 1 : 0

linePriceOrFallback(_ln, _fallback) =>
    float p = line.get_price(_ln, bar_index)
    na(p) ? _fallback : p

linePriceInRangeOrNa(_ln, _x1, _x2) =>
    float p = line.get_price(_ln, bar_index)
    bool inRange = not na(_x1) and not na(_x2) and bar_index >= math.min(_x1, _x2) and bar_index <= math.max(_x1, _x2)
    inRange and not na(p) ? p : na

styleFromInput(_style) =>
    _style == "Solid" ? line.style_solid : _style == "Dashed" ? line.style_dashed : line.style_dotted

// ═══════════════════════════════════════════════════════════════
// PIVOTS
// ═══════════════════════════════════════════════════════════════

phFast  = ta.pivothigh(srcHigh, lenFast, lenFast)
plFast  = ta.pivotlow(srcLow, lenFast, lenFast)
phSlow  = ta.pivothigh(srcHigh, lenSlow, lenSlow)
plSlow  = ta.pivotlow(srcLow, lenSlow, lenSlow)
phThird = ta.pivothigh(srcHigh, lenThird, lenThird)
plThird = ta.pivotlow(srcLow, lenThird, lenThird)

// ═══════════════════════════════════════════════════════════════
// LUXALGO TRENDLINE STATE MACHINE
// ═══════════════════════════════════════════════════════════════

f_lux(_ph, _pl, _len, _mult) =>
    var upper = 0.0
    var lower = 0.0
    var sph = 0.0
    var spl = 0.0
    float n = bar_index
    float sl = switch calcMethod
        "Atr"    => ta.atr(_len) / _len * _mult
        "Stdev"  => ta.stdev(close, _len) / _len * _mult
        "Linreg" => math.abs(ta.sma(close * n, _len) - ta.sma(close, _len) * ta.sma(n, _len)) / ta.variance(n, _len) / 2.0 * _mult
        => ta.atr(_len) / _len * _mult
    sph := not na(_ph) ? sl : sph
    spl := not na(_pl) ? sl : spl
    upper := not na(_ph) ? _ph : upper - sph
    lower := not na(_pl) ? _pl : lower + spl
    [upper, lower, sph, spl]

[upFast, dnFast, sphFast, splFast] = f_lux(phFast, plFast, lenFast, mult)
[upSlow, dnSlow, sphSlow, splSlow] = f_lux(phSlow, plSlow, lenSlow, mult)
[upThird, dnThird, sphThird, splThird] = f_lux(phThird, plThird, lenThird, mult)

offFast = backpaint ? lenFast : 0
offSlow = backpaint ? lenSlow : 0
offThird = backpaint ? lenThird : 0

fastUp = upFast - sphFast * lenFast
fastDn = dnFast + splFast * lenFast
slowUp = upSlow - sphSlow * lenSlow
slowDn = dnSlow + splSlow * lenSlow
thirdUp = upThird - sphThird * lenThird
thirdDn = dnThird + splThird * lenThird

// ═══════════════════════════════════════════════════════════════
// EXTENDED + PROJECTION TRENDLINES
// Calculations remain active even when hidden.
// ═══════════════════════════════════════════════════════════════

var uptlFast  = line.new(na, na, na, na, color=color.new(upCol, 0), style=line.style_dashed, extend=extend.right, width=width)
var dntlFast  = line.new(na, na, na, na, color=color.new(dnCol, 0), style=line.style_dashed, extend=extend.right, width=width)
var uptlSlow  = line.new(na, na, na, na, color=color.new(upCol, 0), style=line.style_dashed, extend=extend.right, width=width)
var dntlSlow  = line.new(na, na, na, na, color=color.new(dnCol, 0), style=line.style_dashed, extend=extend.right, width=width)
var uptlThird = line.new(na, na, na, na, color=color.new(upCol, 0), style=line.style_dashed, extend=extend.right, width=width)
var dntlThird = line.new(na, na, na, na, color=color.new(dnCol, 0), style=line.style_dashed, extend=extend.right, width=width)

projStyle = styleFromInput(projStyleIn)
projFastBars  = projectionBarsMode == "Each TL Length" ? lenFast : manualProjectionBars
projSlowBars  = projectionBarsMode == "Each TL Length" ? lenSlow : manualProjectionBars
projThirdBars = projectionBarsMode == "Each TL Length" ? lenThird : manualProjectionBars

var projUptlFast  = line.new(na, na, na, na, color=projUpCol, style=line.style_dashed, extend=extend.none, width=projWidth)
var projDntlFast  = line.new(na, na, na, na, color=projDnCol, style=line.style_dashed, extend=extend.none, width=projWidth)
var projUptlSlow  = line.new(na, na, na, na, color=projUpCol, style=line.style_dashed, extend=extend.none, width=projWidth)
var projDntlSlow  = line.new(na, na, na, na, color=projDnCol, style=line.style_dashed, extend=extend.none, width=projWidth)
var projUptlThird = line.new(na, na, na, na, color=projUpCol, style=line.style_dashed, extend=extend.none, width=projWidth)
var projDntlThird = line.new(na, na, na, na, color=projDnCol, style=line.style_dashed, extend=extend.none, width=projWidth)

var int projFastUpX1 = na
var int projFastUpX2 = na
var int projFastDnX1 = na
var int projFastDnX2 = na
var int projSlowUpX1 = na
var int projSlowUpX2 = na
var int projSlowDnX1 = na
var int projSlowDnX2 = na
var int projThirdUpX1 = na
var int projThirdUpX2 = na
var int projThirdDnX1 = na
var int projThirdDnX2 = na

drawExtended = showAllTrendlines and showExtendedLines
drawProjected = showAllTrendlines and showProjectionLines

if not na(phFast)
    int x1 = bar_index - offFast
    float y1 = backpaint ? phFast : fastUp
    uptlFast.set_xy1(x1, y1)
    uptlFast.set_xy2(x1 + 1, y1 - sphFast)
    uptlFast.set_color(drawExtended ? color.new(upCol, 0) : color.new(upCol, 100))
    uptlFast.set_width(width)
    if showProjectionLines
        int x2 = x1 + projFastBars
        projUptlFast.set_xy1(x1, y1)
        projUptlFast.set_xy2(x2, y1 - sphFast * projFastBars)
        projUptlFast.set_color(drawProjected ? projUpCol : color.new(projUpCol, 100))
        projUptlFast.set_width(projWidth)
        projUptlFast.set_style(projStyle)
        projFastUpX1 := x1
        projFastUpX2 := x2

if not na(plFast)
    int x1 = bar_index - offFast
    float y1 = backpaint ? plFast : fastDn
    dntlFast.set_xy1(x1, y1)
    dntlFast.set_xy2(x1 + 1, y1 + splFast)
    dntlFast.set_color(drawExtended ? color.new(dnCol, 0) : color.new(dnCol, 100))
    dntlFast.set_width(width)
    if showProjectionLines
        int x2 = x1 + projFastBars
        projDntlFast.set_xy1(x1, y1)
        projDntlFast.set_xy2(x2, y1 + splFast * projFastBars)
        projDntlFast.set_color(drawProjected ? projDnCol : color.new(projDnCol, 100))
        projDntlFast.set_width(projWidth)
        projDntlFast.set_style(projStyle)
        projFastDnX1 := x1
        projFastDnX2 := x2

if not na(phSlow)
    int x1 = bar_index - offSlow
    float y1 = backpaint ? phSlow : slowUp
    uptlSlow.set_xy1(x1, y1)
    uptlSlow.set_xy2(x1 + 1, y1 - sphSlow)
    uptlSlow.set_color(drawExtended ? color.new(upCol, 0) : color.new(upCol, 100))
    uptlSlow.set_width(width)
    if showProjectionLines
        int x2 = x1 + projSlowBars
        projUptlSlow.set_xy1(x1, y1)
        projUptlSlow.set_xy2(x2, y1 - sphSlow * projSlowBars)
        projUptlSlow.set_color(drawProjected ? projUpCol : color.new(projUpCol, 100))
        projUptlSlow.set_width(projWidth)
        projUptlSlow.set_style(projStyle)
        projSlowUpX1 := x1
        projSlowUpX2 := x2

if not na(plSlow)
    int x1 = bar_index - offSlow
    float y1 = backpaint ? plSlow : slowDn
    dntlSlow.set_xy1(x1, y1)
    dntlSlow.set_xy2(x1 + 1, y1 + splSlow)
    dntlSlow.set_color(drawExtended ? color.new(dnCol, 0) : color.new(dnCol, 100))
    dntlSlow.set_width(width)
    if showProjectionLines
        int x2 = x1 + projSlowBars
        projDntlSlow.set_xy1(x1, y1)
        projDntlSlow.set_xy2(x2, y1 + splSlow * projSlowBars)
        projDntlSlow.set_color(drawProjected ? projDnCol : color.new(projDnCol, 100))
        projDntlSlow.set_width(projWidth)
        projDntlSlow.set_style(projStyle)
        projSlowDnX1 := x1
        projSlowDnX2 := x2

if not na(phThird)
    int x1 = bar_index - offThird
    float y1 = backpaint ? phThird : thirdUp
    uptlThird.set_xy1(x1, y1)
    uptlThird.set_xy2(x1 + 1, y1 - sphThird)
    uptlThird.set_color(drawExtended ? color.new(upCol, 0) : color.new(upCol, 100))
    uptlThird.set_width(width)
    if showProjectionLines
        int x2 = x1 + projThirdBars
        projUptlThird.set_xy1(x1, y1)
        projUptlThird.set_xy2(x2, y1 - sphThird * projThirdBars)
        projUptlThird.set_color(drawProjected ? projUpCol : color.new(projUpCol, 100))
        projUptlThird.set_width(projWidth)
        projUptlThird.set_style(projStyle)
        projThirdUpX1 := x1
        projThirdUpX2 := x2

if not na(plThird)
    int x1 = bar_index - offThird
    float y1 = backpaint ? plThird : thirdDn
    dntlThird.set_xy1(x1, y1)
    dntlThird.set_xy2(x1 + 1, y1 + splThird)
    dntlThird.set_color(drawExtended ? color.new(dnCol, 0) : color.new(dnCol, 100))
    dntlThird.set_width(width)
    if showProjectionLines
        int x2 = x1 + projThirdBars
        projDntlThird.set_xy1(x1, y1)
        projDntlThird.set_xy2(x2, y1 + splThird * projThirdBars)
        projDntlThird.set_color(drawProjected ? projDnCol : color.new(projDnCol, 100))
        projDntlThird.set_width(projWidth)
        projDntlThird.set_style(projStyle)
        projThirdDnX1 := x1
        projThirdDnX2 := x2

// Keep plot calculations, but use transparent color when trendlines are hidden.
plot(backpaint ? upFast : fastUp, "TL 1 Fast Upper", color=showAllTrendlines ? (not na(phFast) ? na : color.new(upCol, 0)) : color.new(upCol, 100), offset=-offFast, linewidth=width)
plot(backpaint ? dnFast : fastDn, "TL 1 Fast Lower", color=showAllTrendlines ? (not na(plFast) ? na : color.new(dnCol, 0)) : color.new(dnCol, 100), offset=-offFast, linewidth=width)
plot(backpaint ? upSlow : slowUp, "TL 2 Mid Upper", color=showAllTrendlines ? (not na(phSlow) ? na : color.new(upCol, 0)) : color.new(upCol, 100), offset=-offSlow, linewidth=width)
plot(backpaint ? dnSlow : slowDn, "TL 2 Mid Lower", color=showAllTrendlines ? (not na(plSlow) ? na : color.new(dnCol, 0)) : color.new(dnCol, 100), offset=-offSlow, linewidth=width)
plot(backpaint ? upThird : thirdUp, "TL 3 Slow Upper", color=showAllTrendlines ? (not na(phThird) ? na : color.new(upCol, 0)) : color.new(upCol, 100), offset=-offThird, linewidth=width)
plot(backpaint ? dnThird : thirdDn, "TL 3 Slow Lower", color=showAllTrendlines ? (not na(plThird) ? na : color.new(dnCol, 0)) : color.new(dnCol, 100), offset=-offThird, linewidth=width)

// ═══════════════════════════════════════════════════════════════
// TRENDLINE ENGULF BARCOLOR LOGIC ONLY
// ═══════════════════════════════════════════════════════════════

atr = ta.atr(engulfAtrLen)

engulfHigh = engulfBodyOnly ? bodyHigh : high
engulfLow  = engulfBodyOnly ? bodyLow : low

fastReady = upFast != 0.0 and dnFast != 0.0
slowReady = upSlow != 0.0 and dnSlow != 0.0
thirdReady = upThird != 0.0 and dnThird != 0.0

fastUpBaseLevel = hitTestSource == "Visible Extended Lines" and showExtendedLines ? linePriceOrFallback(uptlFast, fastUp) : fastUp
fastDnBaseLevel = hitTestSource == "Visible Extended Lines" and showExtendedLines ? linePriceOrFallback(dntlFast, fastDn) : fastDn
slowUpBaseLevel = hitTestSource == "Visible Extended Lines" and showExtendedLines ? linePriceOrFallback(uptlSlow, slowUp) : slowUp
slowDnBaseLevel = hitTestSource == "Visible Extended Lines" and showExtendedLines ? linePriceOrFallback(dntlSlow, slowDn) : slowDn
thirdUpBaseLevel = hitTestSource == "Visible Extended Lines" and showExtendedLines ? linePriceOrFallback(uptlThird, thirdUp) : thirdUp
thirdDnBaseLevel = hitTestSource == "Visible Extended Lines" and showExtendedLines ? linePriceOrFallback(dntlThird, thirdDn) : thirdDn

fastUpProjLevel = useProjectionForEngulf and showProjectionLines ? linePriceInRangeOrNa(projUptlFast, projFastUpX1, projFastUpX2) : na
fastDnProjLevel = useProjectionForEngulf and showProjectionLines ? linePriceInRangeOrNa(projDntlFast, projFastDnX1, projFastDnX2) : na
slowUpProjLevel = useProjectionForEngulf and showProjectionLines ? linePriceInRangeOrNa(projUptlSlow, projSlowUpX1, projSlowUpX2) : na
slowDnProjLevel = useProjectionForEngulf and showProjectionLines ? linePriceInRangeOrNa(projDntlSlow, projSlowDnX1, projSlowDnX2) : na
thirdUpProjLevel = useProjectionForEngulf and showProjectionLines ? linePriceInRangeOrNa(projUptlThird, projThirdUpX1, projThirdUpX2) : na
thirdDnProjLevel = useProjectionForEngulf and showProjectionLines ? linePriceInRangeOrNa(projDntlThird, projThirdDnX1, projThirdDnX2) : na

fastUpHitLevel = not na(fastUpProjLevel) ? fastUpProjLevel : fastUpBaseLevel
fastDnHitLevel = not na(fastDnProjLevel) ? fastDnProjLevel : fastDnBaseLevel
slowUpHitLevel = not na(slowUpProjLevel) ? slowUpProjLevel : slowUpBaseLevel
slowDnHitLevel = not na(slowDnProjLevel) ? slowDnProjLevel : slowDnBaseLevel
thirdUpHitLevel = not na(thirdUpProjLevel) ? thirdUpProjLevel : thirdUpBaseLevel
thirdDnHitLevel = not na(thirdDnProjLevel) ? thirdDnProjLevel : thirdDnBaseLevel

tlNearBuffer = atr * tlNearAtrPct / 100.0

exactFastUpper = fastReady and engulfHigh >= fastUpHitLevel and engulfLow <= fastUpHitLevel
exactFastLower = fastReady and engulfHigh >= fastDnHitLevel and engulfLow <= fastDnHitLevel
exactSlowUpper = slowReady and engulfHigh >= slowUpHitLevel and engulfLow <= slowUpHitLevel
exactSlowLower = slowReady and engulfHigh >= slowDnHitLevel and engulfLow <= slowDnHitLevel
exactThirdUpper = thirdReady and engulfHigh >= thirdUpHitLevel and engulfLow <= thirdUpHitLevel
exactThirdLower = thirdReady and engulfHigh >= thirdDnHitLevel and engulfLow <= thirdDnHitLevel

nearFastUpper = fastReady and engulfHigh >= fastUpHitLevel - tlNearBuffer and engulfLow <= fastUpHitLevel + tlNearBuffer
nearFastLower = fastReady and engulfHigh >= fastDnHitLevel - tlNearBuffer and engulfLow <= fastDnHitLevel + tlNearBuffer
nearSlowUpper = slowReady and engulfHigh >= slowUpHitLevel - tlNearBuffer and engulfLow <= slowUpHitLevel + tlNearBuffer
nearSlowLower = slowReady and engulfHigh >= slowDnHitLevel - tlNearBuffer and engulfLow <= slowDnHitLevel + tlNearBuffer
nearThirdUpper = thirdReady and engulfHigh >= thirdUpHitLevel - tlNearBuffer and engulfLow <= thirdUpHitLevel + tlNearBuffer
nearThirdLower = thirdReady and engulfHigh >= thirdDnHitLevel - tlNearBuffer and engulfLow <= thirdDnHitLevel + tlNearBuffer

hitFastUpper = engulfMatchMode == "Exact Span" ? exactFastUpper : engulfMatchMode == "Touch/Near ATR" ? nearFastUpper : exactFastUpper or nearFastUpper
hitFastLower = engulfMatchMode == "Exact Span" ? exactFastLower : engulfMatchMode == "Touch/Near ATR" ? nearFastLower : exactFastLower or nearFastLower
hitSlowUpper = engulfMatchMode == "Exact Span" ? exactSlowUpper : engulfMatchMode == "Touch/Near ATR" ? nearSlowUpper : exactSlowUpper or nearSlowUpper
hitSlowLower = engulfMatchMode == "Exact Span" ? exactSlowLower : engulfMatchMode == "Touch/Near ATR" ? nearSlowLower : exactSlowLower or nearSlowLower
hitThirdUpper = engulfMatchMode == "Exact Span" ? exactThirdUpper : engulfMatchMode == "Touch/Near ATR" ? nearThirdUpper : exactThirdUpper or nearThirdUpper
hitThirdLower = engulfMatchMode == "Exact Span" ? exactThirdLower : engulfMatchMode == "Touch/Near ATR" ? nearThirdLower : exactThirdLower or nearThirdLower

upperHitCount = boolToInt(hitFastUpper) + boolToInt(hitSlowUpper) + boolToInt(hitThirdUpper)
lowerHitCount = boolToInt(hitFastLower) + boolToInt(hitSlowLower) + boolToInt(hitThirdLower)

tlEngulfCount =
     boolToInt(hitFastUpper) +
     boolToInt(hitFastLower) +
     boolToInt(hitSlowUpper) +
     boolToInt(hitSlowLower) +
     boolToInt(hitThirdUpper) +
     boolToInt(hitThirdLower)

tlCountOK = tlEngulfCount >= minLuxLinesEngulfed
upperLowerOK = not requireUpperAndLowerEngulf or (upperHitCount >= 1 and lowerHitCount >= 1)
tlSizeOK = engulfMinAtrPct <= 0 or (engulfHigh - engulfLow) >= atr * engulfMinAtrPct / 100.0

tlEngulfOK = showEngulf and tlCountOK and upperLowerOK and tlSizeOK

rawBull = tlEngulfOK and close >= open
rawBear = tlEngulfOK and close < open

var int lastFire = -999
cooldownOK = (bar_index - lastFire) >= cooldown
bullFire = rawBull and cooldownOK
bearFire = rawBear and cooldownOK

if bullFire or bearFire
    lastFire := bar_index

barcolor(showFireBar and bullFire ? fireBullBar : showFireBar and bearFire ? fireBearBar : na, title="TL Engulf Barcolor")

// Debug/data-window only; no icons, no vertical lines, no background.
plot(showDebugValues ? tlEngulfCount : na, "TL Engulf Count", display=display.data_window)
plot(showDebugValues and tlEngulfOK ? 1 : na, "TL Engulf OK", display=display.data_window)
plot(showDebugValues ? tlNearBuffer : na, "TL Near Buffer", display=display.data_window)

alertcondition(bullFire, "Bull TL Engulf Barcolor", "Bull trendline engulf/touch bar on {{ticker}}")
alertcondition(bearFire, "Bear TL Engulf Barcolor", "Bear trendline engulf/touch bar on {{ticker}}")
````
