# SessionStack Pro 24h MarketMap for ES

- url: https://www.tradingview.com/script/d5Ck4Get-SessionStack-Pro-24h-MarketMap-for-ES/
- type: indicator
- pine_id: PUB;532ac69f43c64ffc8af63cfcd12edce6
- version: 3.0

## Description

Session Highlighter + Key Levels — All-in-One 24h Trading Reference
This indicator consolidates everything a 24h futures trader needs into a single overlay — session context, key price levels, VWAP reference, and an overnight inventory bias estimate.
Sessions (background highlights)
Visualizes all major global trading sessions with configurable colors and transparency: Full Asia (23:00–08:00 GMT), Tokyo (00:00–06:00 GMT), HK/Singapore (01:00–09:00 GMT), Frankfurt (07:00–15:30 GMT), London (08:00–16:30 GMT), London/NY Overlap (dynamically computed — 1h in winter, 2h in summer due to DST), US AM and US PM windows (configurable 1h or 1.5h). All GMT-anchored sessions are DST-immune. US sessions use America/New_York timezone and adjust automatically twice a year.
Key Price Levels

PMH/PML — Premarket High/Low (04:00–09:30 ET), line anchored to the exact bar where the extreme was set
YH/YL — Yesterday's RTH High/Low, drawn at next session open
GH/GL — Globex High/Low (18:00–09:30 ET), anchored to the extreme bar
SH/SL — Live session High/Low, single label that moves as new extremes are set
MO — Midnight Open (00:00 ET), ICT-style daily bias reference
ORB H/L — Opening Range Breakout (configurable 5/15/30 min), with range box

VWAP (three anchors)

Globex VWAP — resets at 18:00 ET, runs full 24h cycle, primary reference
RTH VWAP — resets at 09:30 ET, visible only during regular session
Premarket VWAP — resets at 04:00 ET, visible only during premarket window

Overnight Inventory Bias Table
A real-time table estimating the directional skew of overnight participants using Globex VWAP as fair value anchor and ±1 standard deviation bands as a Value Area High/Low proxy (approximating the 70% value area concept from volume profile theory). Displays: directional bias (LONG/SHORT), value area position (IN VALUE / ABOVE VAH / BELOW VAL), estimated % of overnight range in profit, distance from Globex VWAP in points, and the ±1SD width for context. This is a heuristic approximation — it does not use tick-by-tick order flow data, but provides a statistically grounded directional reference updated on every bar.
Settings
All sessions, levels, and VWAPs are individually toggleable. Colors, transparency, line width, ORB window, US AM/PM duration, and table position are fully configurable.
Designed for: ES, NQ, MES, MNQ futures and any instrument with meaningful overnight sessions. Works on any intraday timeframe (1m–4h recommended).

## Source Code

````pine
//@version=6
indicator("Session Highlighter + Key Levels v5", overlay=true, max_lines_count=50, max_labels_count=150)

// ─────────────────────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────────────────────

var g_bg = "Session Visibility & Transparency"
bgAlpha       = input.int(85, "Background Transparency %", minval=0, maxval=100, group=g_bg)
showTokyo     = input.bool(false, "Show Tokyo (00:00–06:00 GMT)",          group=g_bg)
showHKSG      = input.bool(false, "Show HK / Singapore (01:00–09:00 GMT)", group=g_bg)
showFullAsia  = input.bool(true,  "Show Full Asia (23:00–08:00 GMT)",       group=g_bg)
showFrankfurt = input.bool(false, "Show Frankfurt (07:00–15:30 GMT)",       group=g_bg)
showLondon    = input.bool(true,  "Show London (08:00–16:30 GMT)",          group=g_bg)
showLNYOver   = input.bool(false, "Show London/NY Overlap",                 group=g_bg)
showUSAM      = input.bool(true,  "Show US AM",                             group=g_bg)
showUSPM      = input.bool(true,  "Show US PM",                             group=g_bg)

var g_colors = "Session Colors"
colorTokyo     = input.color(color.new(#4FC3F7, 85), "Tokyo",             group=g_colors)
colorHKSG      = input.color(color.new(#CE93D8, 85), "HK / Singapore",    group=g_colors)
colorFullAsia  = input.color(color.new(#1565C0, 85), "Full Asia",          group=g_colors)
colorFrankfurt = input.color(color.new(#FFB74D, 85), "Frankfurt",          group=g_colors)
colorLondon    = input.color(color.new(#FF8A65, 85), "London",             group=g_colors)
colorLNYOver   = input.color(color.new(#A5D6A7, 85), "London/NY Overlap",  group=g_colors)
colorUSAM      = input.color(color.new(#66BB6A, 85), "US AM",              group=g_colors)
colorUSPM      = input.color(color.new(#EF5350, 85), "US PM",              group=g_colors)

var g_rth = "RTH Window Duration"
amDur = input.string("1.5h", "US AM Duration", options=["1h","1.5h"], group=g_rth)
pmDur = input.string("1.5h", "US PM Duration", options=["1h","1.5h"], group=g_rth)

var g_levels = "Key Levels"
showPMH  = input.bool(true,  "PMH  – Premarket High",      group=g_levels)
showPML  = input.bool(true,  "PML  – Premarket Low",       group=g_levels)
showYH   = input.bool(true,  "YH   – Yesterday High",      group=g_levels)
showYL   = input.bool(true,  "YL   – Yesterday Low",       group=g_levels)
showSH   = input.bool(true,  "SH   – Session High",        group=g_levels)
showSL   = input.bool(true,  "SL   – Session Low",         group=g_levels)
showGH   = input.bool(true,  "GH   – Globex High",         group=g_levels)
showGL   = input.bool(true,  "GL   – Globex Low",          group=g_levels)
showMO   = input.bool(true,  "MO   – Midnight Open",       group=g_levels)
showORB  = input.bool(true,  "ORB  – Opening Range",       group=g_levels)
orbMin   = input.string("15", "ORB Window (min)", options=["5","15","30"], group=g_levels)

var g_vwap = "VWAP"
showGlobexVWAP = input.bool(true,  "Globex VWAP (18:00 ET, 24h)",  group=g_vwap)
showRTHVWAP    = input.bool(false, "RTH VWAP (09:30 ET, RTH only)", group=g_vwap)
showPMVWAP     = input.bool(true,  "PM VWAP  (04:00 ET, premarket only)", group=g_vwap)
colorGlobexVWAP = input.color(color.new(#FF6F00, 0), "Globex VWAP Color", group=g_vwap)
colorRTHVWAP    = input.color(color.new(#00BCD4, 0), "RTH VWAP Color",    group=g_vwap)
colorPMVWAP     = input.color(color.new(#CE93D8, 0), "PM VWAP Color",     group=g_vwap)
vwapWidth        = input.int(2, "VWAP Line Width", minval=1, maxval=4,    group=g_vwap)
showVWAPBands    = input.bool(true, "Show VWAP ±1 SD Bands (VAH/VAL proxy)", group=g_vwap)
colorVWAPBands   = input.color(color.new(#FF6F00, 75), "VWAP Band Color",    group=g_vwap)

var g_inv = "Overnight Inventory"
showInventory    = input.bool(true, "Show Inventory Table",                  group=g_inv)
invPosition      = input.string("Top Right", "Table Position",
                   options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_inv)

var g_lstyle = "Line Style"
lineWidth  = input.int(1, "Line Width", minval=1, maxval=4, group=g_lstyle)
colorPMH   = input.color(color.new(#FFD54F, 0), "PMH",  group=g_lstyle)
colorPML   = input.color(color.new(#FFD54F, 0), "PML",  group=g_lstyle)
colorYH    = input.color(color.new(#90A4AE, 0), "YH",   group=g_lstyle)
colorYL    = input.color(color.new(#90A4AE, 0), "YL",   group=g_lstyle)
colorSH    = input.color(color.new(#66BB6A, 0), "SH",   group=g_lstyle)
colorSL    = input.color(color.new(#EF5350, 0), "SL",   group=g_lstyle)
colorGH    = input.color(color.new(#80DEEA, 0), "GH",   group=g_lstyle)
colorGL    = input.color(color.new(#80DEEA, 0), "GL",   group=g_lstyle)
colorMO    = input.color(color.new(#F48FB1, 0), "MO",   group=g_lstyle)
colorORB   = input.color(color.new(#FFF176, 0), "ORB",  group=g_lstyle)

// ─────────────────────────────────────────────────────────────
// TIME HELPERS
// ─────────────────────────────────────────────────────────────
gmtHM() =>
    h = hour(time, "GMT")
    m = minute(time, "GMT")
    h + m / 60.0

etHM() =>
    h = hour(time, "America/New_York")
    m = minute(time, "America/New_York")
    h + m / 60.0

// ─────────────────────────────────────────────────────────────
// SESSION DETECTION
// ─────────────────────────────────────────────────────────────
gmt = gmtHM()
et  = etHM()

isTokyo()     => gmt >= 0.0  and gmt < 6.0
isHKSG()      => gmt >= 1.0  and gmt < 9.0
isFullAsia()  => gmt >= 23.0 or  gmt < 8.0
isFrankfurt() => gmt >= 7.0  and gmt < 15.5
isLondon()    => gmt >= 8.0  and gmt < 16.5

rthStart  = 9.5
rthEnd    = 16.0
amEndET   = amDur == "1h" ? rthStart + 1.0 : rthStart + 1.5
pmStartET = pmDur == "1h" ? rthEnd - 1.0   : rthEnd - 1.5

isRTH()       => et >= rthStart and et < rthEnd
isUSAM()      => et >= rthStart and et < amEndET
isUSPM()      => et >= pmStartET and et < rthEnd
isLNYOver()   => isLondon() and isRTH()
isGlobex()    => et >= 18.0 or et < 9.5
isPremarket() => et >= 4.0 and et < 9.5

// Globex session starts at 18:00 ET
globexJustStart = isGlobex() and not isGlobex()[1]
rthJustStarted  = isRTH()    and not isRTH()[1]
rthJustEnded    = not isRTH() and isRTH()[1]
preStarted      = isPremarket() and not isPremarket()[1]

// Globex H/L — declared early so inventory table can reference them
var float ghVal = na
var float glVal = na

// ─────────────────────────────────────────────────────────────
// BACKGROUND
// ─────────────────────────────────────────────────────────────
a = bgAlpha
bgCol =
  showLNYOver   and isLNYOver()   ? color.new(colorLNYOver,   a) :
  showUSPM      and isUSPM()      ? color.new(colorUSPM,      a) :
  showUSAM      and isUSAM()      ? color.new(colorUSAM,      a) :
  showLondon    and isLondon()    ? color.new(colorLondon,     a) :
  showFrankfurt and isFrankfurt() ? color.new(colorFrankfurt, a) :
  showHKSG      and isHKSG()      ? color.new(colorHKSG,      a) :
  showTokyo     and isTokyo()     ? color.new(colorTokyo,     a) :
  showFullAsia  and isFullAsia()  ? color.new(colorFullAsia,  a) :
  na
bgcolor(bgCol)

// ─────────────────────────────────────────────────────────────
// SESSION LABELS
// ─────────────────────────────────────────────────────────────
makeLabel(txt, col) =>
    label.new(bar_index, high, txt,
              color=color.new(col, 60), textcolor=color.white,
              size=size.small, style=label.style_label_down)

if showTokyo     and isTokyo()     and not isTokyo()[1]
    makeLabel("Tokyo",     colorTokyo)
if showHKSG      and isHKSG()      and not isHKSG()[1]
    makeLabel("HK/SG",     colorHKSG)
if showFullAsia  and isFullAsia()  and not isFullAsia()[1]
    makeLabel("Full Asia", colorFullAsia)
if showFrankfurt and isFrankfurt() and not isFrankfurt()[1]
    makeLabel("Frankfurt", colorFrankfurt)
if showLondon    and isLondon()    and not isLondon()[1]
    makeLabel("London",    colorLondon)
if showLNYOver   and isLNYOver()   and not isLNYOver()[1]
    makeLabel("LN/NY",     colorLNYOver)
if showUSAM      and isUSAM()      and not isUSAM()[1]
    makeLabel("US AM",     colorUSAM)
if showUSPM      and isUSPM()      and not isUSPM()[1]
    makeLabel("US PM",     colorUSPM)

// ─────────────────────────────────────────────────────────────
// GLOBEX VWAP + StdDev Bands — resets at 18:00 ET, runs full 24h cycle
// StdDev via running variance: Var = E[TP²] - E[TP]²  (volume-weighted)
// ─────────────────────────────────────────────────────────────
var float gvwapTPV  = 0.0   // sum of TP * vol
var float gvwapTP2V = 0.0   // sum of TP² * vol
var float gvwapVol  = 0.0   // sum of vol
var int   gvwapN    = 0     // bar count in session

if globexJustStart
    tp            = (high + low + close) / 3.0
    gvwapTPV      := tp * volume
    gvwapTP2V     := tp * tp * volume
    gvwapVol      := volume
    gvwapN        := 1
else
    tp            = (high + low + close) / 3.0
    gvwapTPV      := gvwapTPV  + tp * volume
    gvwapTP2V     := gvwapTP2V + tp * tp * volume
    gvwapVol      := gvwapVol  + volume
    gvwapN        := gvwapN + 1

globexVwapVal = gvwapVol > 0 ? gvwapTPV / gvwapVol : na

// Variance = weighted mean of TP² minus square of weighted mean of TP
gvwapVariance = gvwapVol > 0 and gvwapN > 1
                 ? math.max(0, gvwapTP2V / gvwapVol - math.pow(globexVwapVal, 2))
                 : 0.0
gvwapSD       = math.sqrt(gvwapVariance)
gvwapVAH      = globexVwapVal + gvwapSD
gvwapVAL      = globexVwapVal - gvwapSD

plot(showGlobexVWAP  ? globexVwapVal : na,
     "Globex VWAP",  color=colorGlobexVWAP, linewidth=vwapWidth, style=plot.style_linebr)
plot(showVWAPBands   ? gvwapVAH : na,
     "Globex VAH",   color=colorVWAPBands,  linewidth=1, style=plot.style_linebr)
plot(showVWAPBands   ? gvwapVAL : na,
     "Globex VAL",   color=colorVWAPBands,  linewidth=1, style=plot.style_linebr)

// ─────────────────────────────────────────────────────────────
// RTH VWAP — resets at 09:30 ET, shown only during RTH
// ─────────────────────────────────────────────────────────────
var float rvwapTPV = 0.0
var float rvwapVol = 0.0

if rthJustStarted
    rvwapTPV := (high + low + close) / 3.0 * volume
    rvwapVol := volume
else if isRTH()
    rvwapTPV := rvwapTPV + (high + low + close) / 3.0 * volume
    rvwapVol := rvwapVol + volume

rthVwapVal = (isRTH() and rvwapVol > 0) ? rvwapTPV / rvwapVol : na

plot(showRTHVWAP ? rthVwapVal : na,
     "RTH VWAP", color=colorRTHVWAP, linewidth=vwapWidth,
     style=plot.style_linebr)

// ─────────────────────────────────────────────────────────────
// PREMARKET VWAP — resets at 04:00 ET, shown only during premarket
// ─────────────────────────────────────────────────────────────
var float pmvwapTPV = 0.0
var float pmvwapVol = 0.0

if preStarted
    pmvwapTPV := (high + low + close) / 3.0 * volume
    pmvwapVol := volume
else if isPremarket()
    pmvwapTPV := pmvwapTPV + (high + low + close) / 3.0 * volume
    pmvwapVol := pmvwapVol + volume

pmVwapVal = (isPremarket() and pmvwapVol > 0) ? pmvwapTPV / pmvwapVol : na

plot(showPMVWAP ? pmVwapVal : na,
     "PM VWAP", color=colorPMVWAP, linewidth=vwapWidth,
     style=plot.style_linebr)

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────
fmt(v) => str.tostring(math.round(v * 4) / 4, "0.00")

// ─────────────────────────────────────────────────────────────
// OVERNIGHT INVENTORY TABLE
// ─────────────────────────────────────────────────────────────
// Uses Globex VWAP as fair value anchor, ±1 SD as value area proxy
// Bias    = price vs Globex VWAP
// Value   = price vs VAH/VAL bands
// In Profit% = positional estimate within Globex range
// ─────────────────────────────────────────────────────────────

tblPos = switch invPosition
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table invTable = na

if showInventory and barstate.islast
    if na(invTable)
        invTable := table.new(tblPos, 2, 6,
                               bgcolor=color.new(#1a1a2e, 20),
                               border_color=color.new(#444466, 60),
                               border_width=1, frame_color=color.new(#444466, 40),
                               frame_width=1)

    // derive values
    gvwap    = globexVwapVal
    gh       = ghVal
    gl       = glVal
    vah      = gvwapVAH
    val      = gvwapVAL
    cp       = close

    isLong   = not na(gvwap) and cp >= gvwap
    globexRng = not na(gh) and not na(gl) and (gh - gl) > 0

    // Bias
    biasStr  = na(gvwap) ? "–" : (isLong ? "LONG  ▲" : "SHORT ▼")
    biasCol  = na(gvwap) ? color.gray : (isLong ? color.new(#66BB6A, 0) : color.new(#EF5350, 0))

    // Value area position
    inValue  = not na(vah) and not na(val) and cp >= val and cp <= vah
    aboveVal = not na(vah) and cp > vah
    valueStr = na(vah) ? "–" : (inValue ? "IN VALUE" : (aboveVal ? "ABOVE VAH" : "BELOW VAL"))
    valueCol = na(vah) ? color.gray : (inValue ? color.new(#90A4AE, 0) : (aboveVal ? color.new(#66BB6A, 0) : color.new(#EF5350, 0)))

    // Est. % in profit (range position proxy)
    profitStr = "–"
    profitCol = color.gray
    if globexRng and not na(gvwap)
        pct = isLong
               ? (cp - gl) / (gh - gl) * 100
               : (gh - cp) / (gh - gl) * 100
        pct := math.max(0, math.min(100, pct))
        profitStr := str.tostring(math.round(pct, 1)) + "%"
        profitCol := pct >= 60 ? color.new(#66BB6A, 0) :
                     pct >= 40 ? color.new(#FFD54F, 0) :
                                 color.new(#EF5350, 0)

    // VWAP distance
    distStr  = na(gvwap) ? "–" : (cp >= gvwap ? "+" : "") + fmt(cp - gvwap) + " pts"
    distCol  = na(gvwap) ? color.gray : (cp >= gvwap ? color.new(#66BB6A, 0) : color.new(#EF5350, 0))

    // SD / range context
    sdStr    = na(gvwapSD) or gvwapSD == 0 ? "–" : "±" + fmt(gvwapSD) + " pts"

    hdrCol   = color.new(#ccccee, 0)
    lblCol   = color.new(#aaaacc, 0)
    cellBg   = color.new(#1a1a2e, 20)
    sz       = size.small

    // Row 0: header
    table.cell(invTable, 0, 0, "OVERNIGHT INVENTORY", text_color=hdrCol,
               text_size=sz, bgcolor=color.new(#2a2a4e, 20), text_halign=text.align_left)
    table.cell(invTable, 1, 0, "", bgcolor=color.new(#2a2a4e, 20))

    // Row 1: Bias
    table.cell(invTable, 0, 1, "Bias", text_color=lblCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_left)
    table.cell(invTable, 1, 1, biasStr, text_color=biasCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_right)

    // Row 2: Value area
    table.cell(invTable, 0, 2, "Value Area", text_color=lblCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_left)
    table.cell(invTable, 1, 2, valueStr, text_color=valueCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_right)

    // Row 3: Est. in profit
    table.cell(invTable, 0, 3, "Est. In Profit", text_color=lblCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_left)
    table.cell(invTable, 1, 3, profitStr, text_color=profitCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_right)

    // Row 4: VWAP dist
    table.cell(invTable, 0, 4, "VWAP Dist", text_color=lblCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_left)
    table.cell(invTable, 1, 4, distStr, text_color=distCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_right)

    // Row 5: SD context
    table.cell(invTable, 0, 5, "Value Area (±1SD)", text_color=lblCol, text_size=sz, bgcolor=cellBg, text_halign=text.align_left)
    table.cell(invTable, 1, 5, sdStr, text_color=color.new(#aaaacc, 0), text_size=sz, bgcolor=cellBg, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────
// MIDNIGHT OPEN — 00:00 ET
// ─────────────────────────────────────────────────────────────
etHour = hour(time, "America/New_York")
etMin  = minute(time, "America/New_York")
isMidnight = etHour == 0 and etMin == 0

var line lineMO = na

if isMidnight and showMO
    line.delete(lineMO)
    lineMO := line.new(bar_index, open, bar_index + 1, open,
                        color=colorMO, width=lineWidth, style=line.style_dashed, extend=extend.right)
    label.new(bar_index, open, "MO " + str.tostring(open, format.mintick),
              color=color.new(colorMO, 70), textcolor=colorMO, size=size.tiny, style=label.style_label_right)

// ─────────────────────────────────────────────────────────────
// GLOBEX H/L — 18:00 ET to 09:30 ET
// ─────────────────────────────────────────────────────────────
var int   ghBarIdx   = na
var int   glBarIdx   = na
var bool  globexActive = false

if globexJustStart
    ghVal        := high
    glVal        := low
    ghBarIdx     := bar_index
    glBarIdx     := bar_index
    globexActive := true

if globexActive and isGlobex()
    if high >= ghVal
        ghVal    := high
        ghBarIdx := bar_index
    if low <= glVal
        glVal    := low
        glBarIdx := bar_index

var line lineGH = na
var line lineGL = na

if rthJustStarted and globexActive
    if showGH
        line.delete(lineGH)
        lineGH := line.new(ghBarIdx, ghVal, bar_index, ghVal,
                            color=colorGH, width=lineWidth, style=line.style_dashed, extend=extend.right)
        label.new(ghBarIdx, ghVal, "GH " + str.tostring(ghVal, format.mintick),
                  color=color.new(colorGH, 70), textcolor=colorGH, size=size.tiny, style=label.style_label_right)
    if showGL
        line.delete(lineGL)
        lineGL := line.new(glBarIdx, glVal, bar_index, glVal,
                            color=colorGL, width=lineWidth, style=line.style_dashed, extend=extend.right)
        label.new(glBarIdx, glVal, "GL " + str.tostring(glVal, format.mintick),
                  color=color.new(colorGL, 70), textcolor=colorGL, size=size.tiny, style=label.style_label_right)
    globexActive := false

// ─────────────────────────────────────────────────────────────
// PREMARKET H/L — 04:00–09:30 ET
// ─────────────────────────────────────────────────────────────
var float pmhVal    = na
var float pmlVal    = na
var int   pmhBarIdx = na
var int   pmlBarIdx = na
var bool  preActive = false

if preStarted
    pmhVal    := high
    pmlVal    := low
    pmhBarIdx := bar_index
    pmlBarIdx := bar_index
    preActive := true

if preActive and isPremarket()
    if high >= pmhVal
        pmhVal    := high
        pmhBarIdx := bar_index
    if low <= pmlVal
        pmlVal    := low
        pmlBarIdx := bar_index

var line linePMH = na
var line linePML = na

if rthJustStarted and preActive
    if showPMH
        line.delete(linePMH)
        linePMH := line.new(pmhBarIdx, pmhVal, bar_index, pmhVal,
                             color=colorPMH, width=lineWidth, style=line.style_dashed, extend=extend.right)
        label.new(pmhBarIdx, pmhVal, "PMH " + str.tostring(pmhVal, format.mintick),
                  color=color.new(colorPMH, 70), textcolor=colorPMH, size=size.tiny, style=label.style_label_right)
    if showPML
        line.delete(linePML)
        linePML := line.new(pmlBarIdx, pmlVal, bar_index, pmlVal,
                             color=colorPML, width=lineWidth, style=line.style_dashed, extend=extend.right)
        label.new(pmlBarIdx, pmlVal, "PML " + str.tostring(pmlVal, format.mintick),
                  color=color.new(colorPML, 70), textcolor=colorPML, size=size.tiny, style=label.style_label_right)
    preActive := false

// ─────────────────────────────────────────────────────────────
// YESTERDAY H/L
// ─────────────────────────────────────────────────────────────
var float yhVal = na
var float ylVal = na
var float _rthH = na
var float _rthL = na

if rthJustStarted
    _rthH := high
    _rthL := low

if isRTH()
    _rthH := na(_rthH) ? high : math.max(_rthH, high)
    _rthL := na(_rthL) ? low  : math.min(_rthL, low)

if rthJustEnded
    yhVal := _rthH
    ylVal := _rthL

var line lineYH = na
var line lineYL = na

if rthJustStarted and not na(yhVal)
    if showYH
        line.delete(lineYH)
        lineYH := line.new(bar_index, yhVal, bar_index + 1, yhVal,
                            color=colorYH, width=lineWidth, style=line.style_dotted, extend=extend.right)
        label.new(bar_index, yhVal, "YH " + str.tostring(yhVal, format.mintick),
                  color=color.new(colorYH, 70), textcolor=colorYH, size=size.tiny, style=label.style_label_right)
    if showYL
        line.delete(lineYL)
        lineYL := line.new(bar_index, ylVal, bar_index + 1, ylVal,
                            color=colorYL, width=lineWidth, style=line.style_dotted, extend=extend.right)
        label.new(bar_index, ylVal, "YL " + str.tostring(ylVal, format.mintick),
                  color=color.new(colorYL, 70), textcolor=colorYL, size=size.tiny, style=label.style_label_right)

// ─────────────────────────────────────────────────────────────
// ORB — Opening Range Breakout
// ─────────────────────────────────────────────────────────────
orbMinutes    = str.tonumber(orbMin)
orbEndET       = rthStart + orbMinutes / 60.0
inORBWindow    = et >= rthStart and et < orbEndET
var bool prevInORB = false
orbJustEnded   = prevInORB and not inORBWindow
prevInORB      := inORBWindow

var float orbH        = na
var float orbL        = na
var int   orbHIdx     = na
var int   orbLIdx     = na
var int   orbStartIdx = na
var bool  orbBuilding = false

if rthJustStarted
    orbH        := high
    orbL        := low
    orbHIdx     := bar_index
    orbLIdx     := bar_index
    orbStartIdx := bar_index
    orbBuilding := true

if orbBuilding and inORBWindow
    if high >= orbH
        orbH    := high
        orbHIdx := bar_index
    if low <= orbL
        orbL    := low
        orbLIdx := bar_index

var line lineORBH = na
var line lineORBL = na
var box  boxORB   = na

if orbJustEnded and orbBuilding
    if showORB
        line.delete(lineORBH)
        line.delete(lineORBL)
        lineORBH := line.new(orbHIdx, orbH, bar_index, orbH,
                              color=colorORB, width=lineWidth, style=line.style_solid, extend=extend.right)
        lineORBL := line.new(orbLIdx, orbL, bar_index, orbL,
                              color=colorORB, width=lineWidth, style=line.style_solid, extend=extend.right)
        box.delete(boxORB)
        boxORB := box.new(orbStartIdx, orbH,
                           bar_index, orbL,
                           border_color=color.new(colorORB, 100),
                           border_width=0,
                           bgcolor=color.new(colorORB, 88))
        label.new(bar_index, orbH, "ORB H " + str.tostring(orbH, format.mintick),
                  color=color.new(colorORB, 70), textcolor=colorORB, size=size.tiny, style=label.style_label_right)
        label.new(bar_index, orbL, "ORB L " + str.tostring(orbL, format.mintick),
                  color=color.new(colorORB, 70), textcolor=colorORB, size=size.tiny, style=label.style_label_right)
    orbBuilding := false

// ─────────────────────────────────────────────────────────────
// SESSION H/L — RTH, line starts at bar where extreme was set
// ─────────────────────────────────────────────────────────────
var float shVal    = na
var float slVal    = na
var int   shBarIdx = na
var int   slBarIdx = na
var line  lineSH   = na
var line  lineSL   = na
var label labelSH  = na
var label labelSL  = na

if rthJustStarted
    shVal    := high
    slVal    := low
    shBarIdx := bar_index
    slBarIdx := bar_index

if isRTH()
    if high >= shVal or na(shVal)
        shVal    := high
        shBarIdx := bar_index
    if low <= slVal or na(slVal)
        slVal    := low
        slBarIdx := bar_index

    if showSH
        line.delete(lineSH)
        lineSH := line.new(shBarIdx, shVal, bar_index + 1, shVal,
                            color=colorSH, width=lineWidth, extend=extend.right)
        if high >= shVal
            label.delete(labelSH)
            labelSH := label.new(shBarIdx, shVal, "SH " + str.tostring(shVal, format.mintick),
                                  color=color.new(colorSH, 70), textcolor=colorSH, size=size.tiny, style=label.style_label_right)

    if showSL
        line.delete(lineSL)
        lineSL := line.new(slBarIdx, slVal, bar_index + 1, slVal,
                            color=colorSL, width=lineWidth, extend=extend.right)
        if low <= slVal
            label.delete(labelSL)
            labelSL := label.new(slBarIdx, slVal, "SL " + str.tostring(slVal, format.mintick),
                                  color=color.new(colorSL, 70), textcolor=colorSL, size=size.tiny, style=label.style_label_right)

if rthJustEnded
    labelSH := na
    labelSL := na
````
