# AlphaSpark Levels v6

- url: https://www.tradingview.com/script/SmUJ6OTt-AlphaSpark-Levels-v6/
- type: indicator
- pine_id: PUB;9da8f2902d164163af32372c258a5620
- version: 2.0

## Description

AlphaSpark Levels v6

Complete trading levels indicator with Volume Profile, VWAPs, Liquidity Swings, Previous Session H/L, and Gamma Exposure (GEX) Levels.

Features:
• Volume Profile (periodic + developing)
• VWAPs (Daily/Weekly/Monthly) with naked levels
• Liquidity Swings (15m, 4h, Daily, Weekly)
• Previous Session H/L (Daily, Weekly, Monthly) with labels
• GEX Levels (Gamma Flip, Call Wall, Put Wall, Highest OI, 0DTE Magnet)
• Dashboard widget with level summary
• Alerts for level crosses

How to use GEX Levels:
1. Join Discord for live GEX updates (link in comments)
2. Copy values from Discord posts
3. Paste into indicator inputs
4. Levels appear on chart automatically

Based on market maker hedging mechanics. Free for community members.

## Source Code

````pine
//@version=6
indicator("🔼 AlphaSpark Levels v6", "🔼 Levels v6", true, max_bars_back = 500, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ===================================================================
// v6 - v5 + Custom Session Hours (wrap-around midnight support)
// ===================================================================

// ═══════════════════════════════════════════════════════════════════════
// 1. UTILITIES
// ═══════════════════════════════════════════════════════════════════════

f_resInMinutes() =>
    timeframe.multiplier * (timeframe.isseconds ? 1. / 60 : timeframe.isminutes ? 1. : timeframe.isdaily ? 1440. : timeframe.isweekly ? 10080. : timeframe.ismonthly ? 43830. : na)

f_tfResInMinutes(_res) =>
    request.security(syminfo.tickerid, _res, f_resInMinutes())

f_tfIsIntraday(_res) =>
    [intraday, daily, weekly, monthly] = request.security(syminfo.tickerid, _res, [timeframe.isintraday, timeframe.isdaily, timeframe.isweekly, timeframe.ismonthly])
    intraday ? "Intraday" : daily ? "Daily" : weekly ? "Weekly" : monthly ? "Monthly" : "Error"

// ─── Line/box helpers ───

f_line(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width) =>
    line.new(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width)

f_line_upd(_id, _x1, _y1, _x2, _y2, _color, string _extend = na) =>
    line.set_xy1(_id, _x1, _y1)
    line.set_xy2(_id, _x2, _y2)
    line.set_color(_id, _color)
    if not na(_extend)
        line.set_extend(_id, _extend)

f_box(_left, _top, _right, _bottom, _border_color, _bg) =>
    box.new(_left, _top, _right, _bottom, _border_color, 1, line.style_solid, bgcolor = _bg)

f_box_upd(_id, _left, _top, _right, _bottom, _border_color, _bg) =>
    box.set_lefttop(_id, _left, _top)
    box.set_rightbottom(_id, _right, _bottom)
    box.set_border_color(_id, _border_color)
    box.set_bgcolor(_id, _bg)

// ─── Volume helpers ───

f_add_bar_vol(_arr, _bar, _lo, _step, _n) =>
    lvl = 0
    top = _lo + _step * (_n - 1)
    for p = _lo to top by _step
        hi = high[_bar]
        lo = low[_bar]
        sz = hi - lo
        if hi >= p and lo < p + _step
            v = nz(volume[_bar])
            if hi <= p + _step and lo >= p
                array.set(_arr, lvl, array.get(_arr, lvl) + v)
            else if hi >= p + _step and lo <= p
                array.set(_arr, lvl, array.get(_arr, lvl) + v * (_step / sz))
            else if hi >= p + _step
                array.set(_arr, lvl, array.get(_arr, lvl) + v * ((p + _step - lo) / sz))
            else if lo <= p
                array.set(_arr, lvl, array.get(_arr, lvl) + v * ((hi - p) / sz))
        lvl += 1

f_va_loop(_vol, _n, _vaPct, _poc) =>
    _total = array.sum(_vol) * _vaPct
    _va    = array.get(_vol, _poc)
    _above = _poc
    _below = _poc
    while _va < _total and _total > 0
        if _below == 0 and _above == _n - 1
            break
        _vAbove = _above < _n - 1 ? array.get(_vol, _above + 1) : 0.
        _vBelow = _below > 0 ? array.get(_vol, _below - 1) : 0.
        if _vBelow == 0 and _vAbove == 0
            break
        if _vAbove >= _vBelow
            _va    += _vAbove
            _above += 1
        else
            _va    += _vBelow
            _below -= 1
        if _above - _below >= _n
            break
    [_below, _above]

// ─── Liquidity line management ───

f_lvl_check(_lines, _levels, _isHigh, _touched, _touchColor) =>
    sz = array.size(_lines)
    if sz > 0
        for i = 0 to sz - 1
            if not array.get(_touched, i)
                lv = array.get(_levels, i)
                ih = array.get(_isHigh, i)
                ln = array.get(_lines, i)
                if (ih and high >= lv) or (not ih and low <= lv)
                    array.set(_touched, i, true)
                    line.set_color(ln, _touchColor)

f_lvl_add(_lines, _levels, _isHigh, _touched, _level, _isHighVal, _color, _max, _style, _width) =>
    nl = line.new(time, _level, time + 1, _level, xloc = xloc.bar_time, extend = extend.right, color = _color, style = _style, width = _width)
    array.push(_lines, nl)
    array.push(_levels, _level)
    array.push(_isHigh, _isHighVal)
    array.push(_touched, false)
    while array.size(_lines) > _max
        line.delete(array.shift(_lines))
        array.shift(_levels)
        array.shift(_isHigh)
        array.shift(_touched)

// ═══════════════════════════════════════════════════════════════════════
// 2. INPUTS
// ═══════════════════════════════════════════════════════════════════════

// ─── GEX Levels ───
GGX = "🎯 Gamma Exposure (GEX)"

gex_on       = input.bool(true, "Show GEX Levels", group = GGX)
gex_flip     = input.float(0.0, "Gamma Flip Price", group = GGX, tooltip = "Level where GEX crosses zero - above = positive, below = negative")
gex_callwall = input.float(0.0, "Call Wall Price", group = GGX, tooltip = "Strike with highest call gamma - resistance")
gex_putwall  = input.float(0.0, "Put Wall Price", group = GGX, tooltip = "Strike with highest put gamma - support")
gex_oi       = input.float(0.0, "Highest OI Strike", group = GGX, tooltip = "Strike with most open interest - magnet")
gex_0dte     = input.float(0.0, "0DTE Magnet", group = GGX, tooltip = "Strike where 0DTE flows concentrate - pin risk")
gex_positive = input.bool(true, "Gamma Positive (above flip)", group = GGX, tooltip = "True if current price is above Gamma Flip")

gex_flip_col     = input.color(color.new(color.orange, 0), "Gamma Flip Color", inline = "gex1", group = GGX)
gex_callwall_col = input.color(color.new(color.red, 0), "Call Wall Color", inline = "gex1", group = GGX)
gex_putwall_col  = input.color(color.new(color.green, 0), "Put Wall Color", inline = "gex1", group = GGX)
gex_oi_col       = input.color(color.new(color.purple, 0), "Highest OI Color", inline = "gex1", group = GGX)
gex_0dte_col     = input.color(color.new(color.aqua, 0), "0DTE Magnet Color", inline = "gex1", group = GGX)

gex_flip_w     = input.int(2, "Gamma Flip Width", minval = 1, maxval = 4, inline = "gex2", group = GGX)
gex_callwall_w = input.int(2, "Call Wall Width", minval = 1, maxval = 4, inline = "gex2", group = GGX)
gex_putwall_w  = input.int(2, "Put Wall Width", minval = 1, maxval = 4, inline = "gex2", group = GGX)
gex_oi_w       = input.int(1, "Highest OI Width", minval = 1, maxval = 4, inline = "gex2", group = GGX)
gex_0dte_w     = input.int(1, "0DTE Magnet Width", minval = 1, maxval = 4, inline = "gex2", group = GGX)

gex_flip_sty_s     = input.string("Dashed", "Gamma Flip Style", options = ["Solid", "Dashed", "Dotted"], inline = "gex3", group = GGX)
gex_callwall_sty_s = input.string("Dashed", "Call Wall Style", options = ["Solid", "Dashed", "Dotted"], inline = "gex3", group = GGX)
gex_putwall_sty_s  = input.string("Dashed", "Put Wall Style", options = ["Solid", "Dashed", "Dotted"], inline = "gex3", group = GGX)
gex_oi_sty_s       = input.string("Dotted", "Highest OI Style", options = ["Solid", "Dashed", "Dotted"], inline = "gex3", group = GGX)
gex_0dte_sty_s     = input.string("Dotted", "0DTE Magnet Style", options = ["Solid", "Dashed", "Dotted"], inline = "gex3", group = GGX)

gex_flip_sty     = gex_flip_sty_s == "Solid" ? line.style_solid : gex_flip_sty_s == "Dashed" ? line.style_dashed : line.style_dotted
gex_callwall_sty = gex_callwall_sty_s == "Solid" ? line.style_solid : gex_callwall_sty_s == "Dashed" ? line.style_dashed : line.style_dotted
gex_putwall_sty  = gex_putwall_sty_s == "Solid" ? line.style_solid : gex_putwall_sty_s == "Dashed" ? line.style_dashed : line.style_dotted
gex_oi_sty       = gex_oi_sty_s == "Solid" ? line.style_solid : gex_oi_sty_s == "Dashed" ? line.style_dashed : line.style_dotted
gex_0dte_sty     = gex_0dte_sty_s == "Solid" ? line.style_solid : gex_0dte_sty_s == "Dashed" ? line.style_dashed : line.style_dotted

gex_show_labels  = input.bool(true, "Show Labels", group = GGX)
gex_show_dashboard = input.bool(true, "Show Dashboard", group = GGX)
gex_dash_pos       = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GGX)

// ─── Volume Profile ───
GVP  = "PVP Replacement"

periodic_tf   = input.timeframe("1D", "Periodic Timeframe", group = GVP)
regular_sess  = input.bool(false, "Profile resets on RTH", group = GVP, tooltip = "For tickers with Extended Trading Hours")
volumeProfile = input.bool(false, "Volume Profile", inline = "BB3", group = GVP)
totalVolCol   = input.color(color.new(color.blue, 50), "", inline = "BB3", group = GVP)
vaVolCol      = input.color(color.new(color.blue, 80), "", inline = "BB3", group = GVP)
vaPct         = input.float(70, "Value Area %", minval = 0, maxval = 100, group = GVP) / 100
nLevels       = input.int(100, "Rows", minval = 10, maxval = 400, step = 1, group = GVP)
vpPlacement   = input.string("Left", "Placement", options = ["Right", "Left", "Next Period"], group = GVP)
vpWidth       = input.int(75, "Profile Width %", minval = 0, maxval = 100, group = GVP) / 100

pointOfControl = input.bool(false, "PoC", inline = "PoC", group = GVP)
pocColor       = input.color(color.new(color.red, 0), "", inline = "PoC", group = GVP)
pocWidth       = input.int(1, "", inline = "PoC", group = GVP)
pocExtend      = input.string("Until Bar Tap", "PoC Extend", options = ["Until Last Bar", "Until Bar Cross", "Until Bar Tap", "None"], group = GVP)

valueAreaHigh  = input.bool(false, "VAH", inline = "VAH", group = GVP)
vahColor       = input.color(color.new(color.blue, 0), "", inline = "VAH", group = GVP)
valueAreaLow   = input.bool(false, "VAL", inline = "VAL", group = GVP)
valColor       = input.color(color.new(color.blue, 0), "", inline = "VAL", group = GVP)

vaBg       = input.bool(false, "VA Background", inline = "vBG", group = GVP)
vaBgCol    = input.color(color.new(color.blue, 90), "", inline = "vBG", group = GVP)
bgFill     = input.bool(false, "Profile Background", inline = "BG", group = GVP)
bgCol      = input.color(color.new(color.blue, 95), "", inline = "BG", group = GVP)

show_prev  = input.bool(true, "Show Previous POC/VAH/VAL", group = GVP)
show_dvp   = input.bool(false, "Show Developing Profile", group = GVP)
show_dpoc  = input.bool(false, "Dev POC path", inline = "dpoc", group = GVP)
dpoc_col   = input.color(#ff693b, "", inline = "dpoc", group = GVP)
show_dvah  = input.bool(false, "Dev VAH path", inline = "dvah", group = GVP)
dvah_col   = input.color(color.aqua, "", inline = "dvah", group = GVP)
show_dval  = input.bool(false, "Dev VAL path", inline = "dval", group = GVP)
dval_col   = input.color(color.aqua, "", inline = "dval", group = GVP)

show_cross_plot = input.bool(false, "Show POC Crosses", group = GVP)
show_touch_plot = input.bool(false, "Show POC Taps", group = GVP)

// ─── VWAP ───
GVW = "VWAPs & Gaps"

d_on  = input(true, "Daily VWAP", inline = "vw1", group = GVW)
d_gap = input(true, "Naked", inline = "vw1", group = GVW)
d_lbl = input(true, "Labels", inline = "vw1", group = GVW)
d_lt  = d_lbl ? 0 : 100

w_on  = input(true, "Weekly VWAP", inline = "vw2", group = GVW)
w_gap = input(true, "Naked", inline = "vw2", group = GVW)
w_lbl = input(true, "Labels", inline = "vw2", group = GVW)
w_lt  = w_lbl ? 0 : 100

m_on  = input(true, "Monthly VWAP", inline = "vw3", group = GVW)
m_gap = input(true, "Naked", inline = "vw3", group = GVW)
m_lbl = input(true, "Labels", inline = "vw3", group = GVW)
m_lt  = m_lbl ? 0 : 100

prevLvls    = input(true, "Previous VWAP Close", inline = "pvl", group = "Levels")
plabel      = input(true, "Labels", inline = "pvl", group = "Levels")
plabelt     = plabel ? 0 : 100
plot_pL     = input(true, "Historical VWAP Closes", group = "Levels")

dvwapcolor  = input.color(color.white, "Daily", inline = "ci1", group = "Color Inputs")
dlabelcolor = input.color(color.white, "", inline = "ci1", group = "Color Inputs")
wvwapcolor  = input.color(color.yellow, "Weekly", inline = "ci2", group = "Color Inputs")
wlabelcolor = input.color(color.yellow, "", inline = "ci2", group = "Color Inputs")
mvwapcolor  = input.color(color.purple, "Monthly", inline = "ci3", group = "Color Inputs")
mlabelcolor = input.color(color.purple, "", inline = "ci3", group = "Color Inputs")

// ─── Swings ───
GSW = "⏱ Liquidity Swings"

sw_days      = input.int(2, "Days Lookback", minval = 1, maxval = 30, group = GSW, tooltip = "Number of days to look back for swing levels")
sw_max       = input.int(10, "Max Lines / TF", minval = 5, maxval = 100, group = GSW)
sw_touch     = input.color(color.gray, "Touched Color", group = GSW)
sw_w         = input.int(1, "Line Width", minval = 1, maxval = 4, group = GSW)
sw_sty_s     = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = GSW)
sw_sty       = sw_sty_s == "Solid" ? line.style_solid : sw_sty_s == "Dashed" ? line.style_dashed : line.style_dotted
sw_lb        = input.int(3, "Pivot Left/Right Bars", minval = 1, maxval = 20, group = GSW, tooltip = "Bars left/right to confirm swing")

sw_15m = input.bool(true, "15m", inline = "s15", group = GSW)
sc_15m = input.color(color.new(color.orange, 50), "", inline = "s15", group = GSW)
sw_cur = input.bool(false, "Chart", inline = "sC", group = GSW)
sc_cur = input.color(#ff9800, "", inline = "sC", group = GSW)
sw_4h  = input.bool(false, "4h",  inline = "s4",  group = GSW)
sc_4h  = input.color(color.blue, "", inline = "s4",  group = GSW)
sw_D   = input.bool(false, "D",   inline = "sD",  group = GSW)
sc_D   = input.color(color.fuchsia, "", inline = "sD", group = GSW)
sw_W   = input.bool(false, "W",   inline = "sW",  group = GSW)
sc_W   = input.color(color.red, "", inline = "sW", group = GSW)

// ─── Previous Session H/L ───
GPS = "📅 Previous Session H/L"

ps_max      = input.int(10, "Max Lines / Period", minval = 5, maxval = 50, group = GPS)
ps_sty_s    = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], group = GPS)
ps_sty      = ps_sty_s == "Solid" ? line.style_solid : ps_sty_s == "Dashed" ? line.style_dashed : line.style_dotted
ps_w        = input.int(1, "Width", minval = 1, maxval = 4, group = GPS)
ps_touch    = input.color(color.gray, "Touched Color", group = GPS)
ps_lbl      = input.bool(true, "Show Labels", group = GPS)

ps_D = input.bool(true, "Daily",   inline = "psD", group = GPS)
pc_D = input.color(color.blue, "", inline = "psD", group = GPS)
ps_W = input.bool(true, "Weekly",  inline = "psW", group = GPS)
pc_W = input.color(color.orange, "", inline = "psW", group = GPS)
ps_M = input.bool(true, "Monthly", inline = "psM", group = GPS)
pc_M = input.color(color.red, "", inline = "psM", group = GPS)

// ═══════════════════════════════════════════════════════════════════════
// 3. VOLUME PROFILE (Multi-day, CantoLab style)

int vpDaysBack = input.int(20, "POC Days Back", minval = 1, maxval = 20, group = "📊 Volume Profile", tooltip = "Number of days to show POCs for")
// ═══════════════════════════════════════════════════════════════════════

// Session detection
bool isNewDay = ta.change(time("D")) != 0

// Track multiple sessions
var array<int> dayStarts = array.new<int>()
var array<int> dayEnds = array.new<int>()
var array<float> dayHighs = array.new<float>()
var array<float> dayLows = array.new<float>()

var float curDayHigh = na
var float curDayLow = na

if isNewDay
    if dayStarts.size() > 0
        dayEnds.set(dayEnds.size() - 1, bar_index - 1)
        dayHighs.set(dayHighs.size() - 1, nz(curDayHigh, high))
        dayLows.set(dayLows.size() - 1, nz(curDayLow, low))
    dayStarts.push(bar_index)
    dayEnds.push(bar_index)
    dayHighs.push(high)
    dayLows.push(low)
    curDayHigh := high
    curDayLow := low
    // Keep only last 7 days
    while dayStarts.size() > vpDaysBack + 2
        dayStarts.shift()
        dayEnds.shift()
        dayHighs.shift()
        dayLows.shift()
else
    curDayHigh := math.max(nz(curDayHigh, high), high)
    curDayLow := math.min(nz(curDayLow, low), low)
    if dayEnds.size() > 0
        dayEnds.set(dayEnds.size() - 1, bar_index)
        dayHighs.set(dayEnds.size() - 1, curDayHigh)
        dayLows.set(dayEnds.size() - 1, curDayLow)

// Build volume profile for a session
buildVP(int fromBar, int toBar, float priceBot, float priceTop, int bins) =>
    float binStep = (priceTop - priceBot) / bins
    array<float> volArr = array.new<float>(bins, 0.0)
    int offset = bar_index - toBar
    int span = toBar - fromBar
    for i = offset to span + offset
        float cH = nz(high[i], close[i])
        float cL = nz(low[i], close[i])
        float v = nz(volume[i], 0.0)
        if v > 0 and cH > cL
            float rng = cH - cL
            int kS = math.max(int(math.floor((cL - priceBot) / binStep)), 0)
            int kE = math.min(int(math.floor((cH - priceBot) / binStep)), bins - 1)
            for k = kS to kE
                if k >= 0 and k < bins
                    float bL = priceBot + k * binStep
                    float bH = bL + binStep
                    float oL = math.max(cL, bL)
                    float oH = math.min(cH, bH)
                    if oH > oL
                        float aV = v * (oH - oL) / rng
                        volArr.set(k, volArr.get(k) + aV)
        else if v > 0
            int nb = int(math.floor((close[i] - priceBot) / binStep))
            nb := math.max(math.min(nb, bins - 1), 0)
            volArr.set(nb, volArr.get(nb) + v)
    // Find POC
    float maxV = 0.0
    int pocIdx = 0
    for k = 0 to bins - 1
        if volArr.get(k) > maxV
            maxV := volArr.get(k)
            pocIdx := k
    float pocPrice = priceBot + (pocIdx + 0.5) * binStep
    [volArr, pocPrice]

// Draw profiles for multiple days
var line[] vpLines = array.new_line()
var label[] vpLabels = array.new_label()

if barstate.islast
    // Cleanup
    for l in vpLines
        l.delete()
    vpLines.clear()
    for lb in vpLabels
        lb.delete()
    vpLabels.clear()
    
    int totalDays = dayStarts.size()
    int showDays = math.min(vpDaysBack, totalDays)
    
    // Collect POC prices for naked POC detection
    array<float> pocPrices = array.new<float>()
    
    for d = 0 to showDays - 1
        int idx = totalDays - 1 - d
        if idx < 0
            continue
        int sIdx = dayStarts.get(idx)
        int eIdx = dayEnds.get(idx)
        float dHi = dayHighs.get(idx)
        float dLo = dayLows.get(idx)
        bool isCur = d == 0
        
        if dHi <= dLo or eIdx <= sIdx
            continue
        
        int bins = 34
        
        [volArr, pocPrice] = buildVP(sIdx, eIdx, dLo, dHi, bins)
        
        // Draw POC line (red)
        color pocClr = isCur ? color.red : color.new(color.red, 50)
        vpLines.push(line.new(sIdx, pocPrice, eIdx, pocPrice, color = pocClr, width = isCur ? 2 : 1))
        
        // Draw POC label
        if isCur
            vpLabels.push(label.new(sIdx, pocPrice, "POC", style = label.style_none, textcolor = color.red, size = size.small))
        
        // Store POC for naked detection (not current day)
        if not isCur
            pocPrices.push(pocPrice)
    
    // Naked POC detection
    if pocPrices.size() > 0
        for np = 0 to pocPrices.size() - 1
            float npPrice = pocPrices.get(np)
            int npBar = dayEnds.get(totalDays - 2 - np)
            bool touched = false
            // Check ALL bars since this POC was created
            int barsToCheck = bar_index - npBar
            if barsToCheck > 0
                for c = 1 to math.min(barsToCheck, 500)
                    if nz(low[c]) <= npPrice and nz(high[c]) >= npPrice
                        touched := true
                        break
            if not touched
                // Draw naked POC line from session end to current bar
                vpLines.push(line.new(npBar, npPrice, bar_index, npPrice, color = color.red, width = 1, style = line.style_dashed))
                vpLabels.push(label.new(npBar, npPrice, "nPOC", style = label.style_none, textcolor = color.red, size = size.small))

// ═══════════════════════════════════════════════════════════════════════
// 4. VWAPs// ═══════════════════════════════════════════════════════════════════════
// 4. VWAPs// ═══════════════════════════════════════════════════════════════════════
// 4. VWAPs// ═══════════════════════════════════════════════════════════════════════
// 4. VWAPs// ═══════════════════════════════════════════════════════════════════════
// 4. VWAPs
// ═══════════════════════════════════════════════════════════════════════

src = hlc3

f_vwap(per) =>
    t     = time(per)
    start = na(t[1]) or t > t[1]
    sumS  = src * volume
    sumV  = volume
    sumS2 = volume * volume
    sumS  := start ? sumS : sumS + sumS[1]
    sumV  := start ? sumV : sumV + sumV[1]
    v     = sumS / sumV
    sumS2 := start ? volume * src * src : sumS2[1] + volume * src * src
    [v, math.sqrt(math.max(sumS2 / sumV - v * v, 0))]

dvwap = float(na)
wvwap = float(na)
mvwap = float(na)

if d_on and not(timeframe.isweekly or timeframe.ismonthly)
    [x1, _] = f_vwap("D")
    dvwap := x1
if w_on and not timeframe.ismonthly
    [x2, _] = f_vwap("W")
    wvwap := x2
if m_on
    [x3, _] = f_vwap("M")
    mvwap := x3

is_today = year == year(timenow) and month == month(timenow) and dayofmonth == dayofmonth(timenow)
is_week  = year == year(timenow) and month == month(timenow) and weekofyear == weekofyear(timenow)
is_month = year == year(timenow) and month == month(timenow)

f_tchg(p) => ta.change(time(p))

// ─── VWAP compute (3 separate instances for var isolation) ───

f_vwap1(src1, newP) =>
    var float ss = 0.
    var float sv = 0.
    ss := bool(newP) ? src1 * volume : src1 * volume + ss[1]
    sv := bool(newP) ? volume : volume + sv[1]
    ss / sv

f_vwap2(src1, newP) =>
    var float ss = 0.
    var float sv = 0.
    ss := bool(newP) ? src1 * volume : src1 * volume + ss[1]
    sv := bool(newP) ? volume : volume + sv[1]
    ss / sv

f_vwap3(src1, newP) =>
    var float ss = 0.
    var float sv = 0.
    ss := bool(newP) ? src1 * volume : src1 * volume + ss[1]
    sv := bool(newP) ? volume : volume + sv[1]
    ss / sv

f_prev1(chg, vw) =>
    var float p = na
    p := bool(chg) ? vw[1] : p
    p

f_prev2(chg, vw) =>
    var float p = na
    p := bool(chg) ? vw[1] : p
    p

f_prev3(chg, vw) =>
    var float p = na
    p := bool(chg) ? vw[1] : p
    p

// ─── Naked VWAP helper (no internal var - arrays passed in) ───

f_naked(arrUp, pUp, arrDn, pDn, lbUp, lbDn, p_vwap, bool isNew, bool isNow, bool gapOn, col, lcol, lt, pref, bool showPrev) =>
    if isNew and gapOn
        array.push(arrUp, line.new(time, p_vwap, time + 1, p_vwap, xloc = xloc.bar_time, style = line.style_dotted, color = col, extend = extend.right))
        array.push(arrDn, line.new(time, p_vwap, time + 1, p_vwap, xloc = xloc.bar_time, style = line.style_dotted, color = col, extend = extend.right))
        array.push(pUp,  p_vwap)
        array.push(pDn,  p_vwap)
        array.push(lbUp, label.new(timenow, p_vwap, text = "                                       " + pref + "nVWAP - " + str.tostring(p_vwap, format.mintick), color = color.new(col, 100), textcolor = color.new(lcol, lt), style = label.style_none, size = size.normal, xloc = xloc.bar_time, textalign = text.align_right))
        array.push(lbDn, label.new(timenow, p_vwap, text = "                                       " + pref + "nVWAP - " + str.tostring(p_vwap, format.mintick), color = color.new(col, 100), textcolor = color.new(lcol, lt), style = label.style_none, size = size.normal, xloc = xloc.bar_time, textalign = text.align_right))
    if isNew and isNow and showPrev
        label.new(timenow, p_vwap, text = "                                       " + pref + "pVWAP - " + str.tostring(p_vwap, format.mintick), color = color.new(col, 100), textcolor = color.new(lcol, plabelt), style = label.style_none, size = size.normal, xloc = xloc.bar_time, textalign = text.align_right)
    szU = array.size(pUp)
    if szU > 0
        for i = 0 to szU - 1
            if i < array.size(pUp) and array.get(pUp, i) <= high
                line.delete(array.get(arrUp, i))
                label.delete(array.get(lbUp, i))
    szD = array.size(pDn)
    if szD > 0
        for i = 0 to szD - 1
            if i < array.size(pDn) and array.get(pDn, i) >= low
                line.delete(array.get(arrDn, i))
                label.delete(array.get(lbDn, i))

// ─── VWAP arrays ───

var line[]  d_u = array.new_line()
var float[] d_pu = array.new_float()
var line[]  d_d = array.new_line()
var float[] d_pd = array.new_float()
var label[] d_lu = array.new_label()
var label[] d_ld = array.new_label()

var line[]  w_u = array.new_line()
var float[] w_pu = array.new_float()
var line[]  w_d = array.new_line()
var float[] w_pd = array.new_float()
var label[] w_lu = array.new_label()
var label[] w_ld = array.new_label()

var line[]  m_u = array.new_line()
var float[] m_pu = array.new_float()
var line[]  m_d = array.new_line()
var float[] m_pd = array.new_float()
var label[] m_lu = array.new_label()
var label[] m_ld = array.new_label()

// Daily
nS1 = f_tchg("D")
vw1 = f_vwap1(src, nS1)
pv1 = f_prev1(nS1, vw1)
if d_gap
    f_naked(d_u, d_pu, d_d, d_pd, d_lu, d_ld, pv1, bool(nS1), is_today, true, dvwapcolor, dlabelcolor, d_lt, "d", prevLvls)
p1 = f_prev1(nS1, vw1)
plot(plot_pL ? p1 : na, "Prev dVWAP", color = dvwapcolor, style = plot.style_circles, linewidth = 1)
plot(prevLvls and is_today ? p1 : na, "pdVWAP", color = dvwapcolor, style = plot.style_circles, linewidth = 1)

// Weekly
nS2 = f_tchg("W")
vw2 = f_vwap2(src, nS2)
pv2 = f_prev2(nS2, vw2)
if w_gap
    f_naked(w_u, w_pu, w_d, w_pd, w_lu, w_ld, pv2, bool(nS2), is_week, true, wvwapcolor, wlabelcolor, w_lt, "w", prevLvls)
p2 = f_prev2(nS2, vw2)
plot(plot_pL ? p2 : na, "Prev wVWAP", color = wvwapcolor, style = plot.style_circles, linewidth = 1)
plot(prevLvls and is_week ? p2 : na, "pwVWAP", color = wvwapcolor, style = plot.style_circles, linewidth = 1)

// Monthly
nS3 = f_tchg("M")
vw3 = f_vwap3(src, nS3)
pv3 = f_prev3(nS3, vw3)
if m_gap
    f_naked(m_u, m_pu, m_d, m_pd, m_lu, m_ld, pv3, bool(nS3), is_month, true, mvwapcolor, mlabelcolor, m_lt, "m", prevLvls)
p3 = f_prev3(nS3, vw3)
plot(plot_pL ? p3 : na, "Prev mVWAP", color = mvwapcolor, style = plot.style_circles, linewidth = 1)
plot(prevLvls and is_month ? p3 : na, "pmVWAP", color = mvwapcolor, style = plot.style_circles, linewidth = 1)

plot(d_on ? dvwap : na, "Daily VWAP", dvwapcolor, style = plot.style_circles, linewidth = 1)
plot(w_on ? wvwap : na, "Weekly VWAP", wvwapcolor, style = plot.style_circles, linewidth = 1)
plot(m_on ? mvwap : na, "Monthly VWAP", mvwapcolor, style = plot.style_circles, linewidth = 1)

// ═══════════════════════════════════════════════════════════════════════
// 5. LIQUIDITY - Swings + Previous Session H/L
// ═══════════════════════════════════════════════════════════════════════

// ─── Chart-TF Swings ───
var line[]  sl_cur = array.new_line()
var float[] sv_cur = array.new_float()
var bool[]  sh_cur = array.new_bool()
var bool[]  st_cur = array.new_bool()
var int     sp_cur = -1
var int     sl_cur_bar = -1

if sw_cur
    f_lvl_check(sl_cur, sv_cur, sh_cur, st_cur, sw_touch)

    ph_cur = ta.pivothigh(high, sw_lb, sw_lb)
    if not na(ph_cur) and bar_index != sp_cur
        sp_cur := bar_index
        f_lvl_add(sl_cur, sv_cur, sh_cur, st_cur, ph_cur, true, sc_cur, sw_max, sw_sty, sw_w)

    pl_cur = ta.pivotlow(low, sw_lb, sw_lb)
    if not na(pl_cur) and bar_index != sl_cur_bar
        sl_cur_bar := bar_index
        f_lvl_add(sl_cur, sv_cur, sh_cur, st_cur, pl_cur, false, sc_cur, sw_max, sw_sty, sw_w)

// ─── 15m Swings (overlay-style: store all, check touches/expiration) ───
var line[]  sl_15m = array.new_line()
var float[] sv_15m = array.new_float()
var bool[]  sh_15m = array.new_bool()
var bool[]  st_15m = array.new_bool()
var int[]   st_15m_time = array.new_int()

// Fetch 15m pivots securely using tuple (same as overlay)
[ph15, pl15] = request.security(syminfo.tickerid, "15", [ta.pivothigh(high, sw_lb, sw_lb), ta.pivotlow(low, sw_lb, sw_lb)], barmerge.gaps_off, barmerge.lookahead_off)

// Convert days to milliseconds for expiration
ms_in_day = 86400000
cutoff_15m = time - (sw_days * ms_in_day)

if sw_15m
    // Add new pivots (like overlay does)
    if not na(ph15)
        array.push(sl_15m, line.new(bar_index, ph15, bar_index + 1, ph15, xloc = xloc.bar_index, extend = extend.right, color = sc_15m, style = sw_sty, width = sw_w))
        array.push(sv_15m, ph15)
        array.push(sh_15m, true)
        array.push(st_15m, false)
        array.push(st_15m_time, time)
    if not na(pl15)
        array.push(sl_15m, line.new(bar_index, pl15, bar_index + 1, pl15, xloc = xloc.bar_index, extend = extend.right, color = sc_15m, style = sw_sty, width = sw_w))
        array.push(sv_15m, pl15)
        array.push(sh_15m, false)
        array.push(st_15m, false)
        array.push(st_15m_time, time)
    
    // Check for touches & expiration (like overlay)
    if array.size(sl_15m) > 0
        for i = array.size(sl_15m) - 1 to 0
            l = array.get(sl_15m, i)
            t = array.get(st_15m_time, i)
            val = line.get_y1(l)
            ih = array.get(sh_15m, i)
            touched = (ih and high >= val) or (not ih and low <= val)
            if touched or t < cutoff_15m
                line.delete(l)
                array.remove(sl_15m, i)
                array.remove(sv_15m, i)
                array.remove(sh_15m, i)
                array.remove(st_15m, i)
                array.remove(st_15m_time, i)

// ─── 4h Swings (overlay-style) ───
var line[]  sl_4h = array.new_line()
var float[] sv_4h = array.new_float()
var bool[]  sh_4h = array.new_bool()
var bool[]  st_4h = array.new_bool()
var int[]   st_4h_time = array.new_int()

[ph4, pl4] = request.security(syminfo.tickerid, "240", [ta.pivothigh(high, sw_lb, sw_lb), ta.pivotlow(low, sw_lb, sw_lb)], barmerge.gaps_off, barmerge.lookahead_off)

cutoff_4h = time - (sw_days * ms_in_day)

if sw_4h
    if not na(ph4)
        array.push(sl_4h, line.new(bar_index, ph4, bar_index + 1, ph4, xloc = xloc.bar_index, extend = extend.right, color = sc_4h, style = sw_sty, width = sw_w))
        array.push(sv_4h, ph4)
        array.push(sh_4h, true)
        array.push(st_4h, false)
        array.push(st_4h_time, time)
    if not na(pl4)
        array.push(sl_4h, line.new(bar_index, pl4, bar_index + 1, pl4, xloc = xloc.bar_index, extend = extend.right, color = sc_4h, style = sw_sty, width = sw_w))
        array.push(sv_4h, pl4)
        array.push(sh_4h, false)
        array.push(st_4h, false)
        array.push(st_4h_time, time)
    
    if array.size(sl_4h) > 0
        for i = array.size(sl_4h) - 1 to 0
            l = array.get(sl_4h, i)
            t = array.get(st_4h_time, i)
            val = line.get_y1(l)
            ih = array.get(sh_4h, i)
            touched = (ih and high >= val) or (not ih and low <= val)
            if touched or t < cutoff_4h
                line.delete(l)
                array.remove(sl_4h, i)
                array.remove(sv_4h, i)
                array.remove(sh_4h, i)
                array.remove(st_4h, i)
                array.remove(st_4h_time, i)

// ─── Daily Swings ───
var line[]  sl_D = array.new_line()
var float[] sv_D = array.new_float()
var bool[]  sh_D = array.new_bool()
var bool[]  st_D = array.new_bool()

[phD, plD] = request.security(syminfo.tickerid, "D", [ta.pivothigh(high, sw_lb, sw_lb), ta.pivotlow(low, sw_lb, sw_lb)], barmerge.gaps_off, barmerge.lookahead_off)

if sw_D
    f_lvl_check(sl_D, sv_D, sh_D, st_D, sw_touch)
    if not na(phD)
        f_lvl_add(sl_D, sv_D, sh_D, st_D, phD, true, sc_D, sw_max, sw_sty, sw_w)
    if not na(plD)
        f_lvl_add(sl_D, sv_D, sh_D, st_D, plD, false, sc_D, sw_max, sw_sty, sw_w)

// ─── Weekly Swings ───
var line[]  sl_W = array.new_line()
var float[] sv_W = array.new_float()
var bool[]  sh_W = array.new_bool()
var bool[]  st_W = array.new_bool()

[phW, plW] = request.security(syminfo.tickerid, "W", [ta.pivothigh(high, sw_lb, sw_lb), ta.pivotlow(low, sw_lb, sw_lb)], barmerge.gaps_off, barmerge.lookahead_off)

if sw_W
    f_lvl_check(sl_W, sv_W, sh_W, st_W, sw_touch)
    if not na(phW)
        f_lvl_add(sl_W, sv_W, sh_W, st_W, phW, true, sc_W, sw_max, sw_sty, sw_w)
    if not na(plW)
        f_lvl_add(sl_W, sv_W, sh_W, st_W, plW, false, sc_W, sw_max, sw_sty, sw_w)

// ─── Previous Session H/L (trading session based) ───

// Previous Daily H/L
var line[]  pd_ln = array.new_line()
var float[] pd_lv = array.new_float()
var bool[]  pd_ih = array.new_bool()
var bool[]  pd_tc = array.new_bool()
var int[]   pd_time = array.new_int()
var label[] pd_lb = array.new_label()

var float session_high = na
var float session_low = na
var int   session_start_time = na

// Track session high/low throughout the session
current_day_start = ta.change(time("D"))

if current_day_start != 0
    // New session started - save previous session's high/low
    if not na(session_high)
        // Add Previous Daily High
        array.push(pd_ln, line.new(bar_index, session_high, bar_index + 1, session_high, xloc = xloc.bar_index, extend = extend.right, color = pc_D, style = ps_sty, width = ps_w))
        array.push(pd_lv, session_high)
        array.push(pd_ih, true)
        array.push(pd_tc, false)
        array.push(pd_time, time)
        if ps_lbl
            array.push(pd_lb, label.new(bar_index + 5, session_high, "PDH " + str.tostring(session_high, format.mintick), style = label.style_none, textcolor = pc_D, size = size.normal, textalign = text.align_left))
        else
            array.push(pd_lb, label.new(na, na, na))
        
        // Add Previous Daily Low
        array.push(pd_ln, line.new(bar_index, session_low, bar_index + 1, session_low, xloc = xloc.bar_index, extend = extend.right, color = pc_D, style = ps_sty, width = ps_w))
        array.push(pd_lv, session_low)
        array.push(pd_ih, false)
        array.push(pd_tc, false)
        array.push(pd_time, time)
        if ps_lbl
            array.push(pd_lb, label.new(bar_index + 5, session_low, "PDL " + str.tostring(session_low, format.mintick), style = label.style_none, textcolor = pc_D, size = size.normal, textalign = text.align_left))
        else
            array.push(pd_lb, label.new(na, na, na))
    
    // Reset for new session
    session_high := high
    session_low := low
    session_start_time := time
    
    // Enforce max lines limit for Daily
    while array.size(pd_ln) > ps_max
        line.delete(array.shift(pd_ln))
        array.shift(pd_lv)
        array.shift(pd_ih)
        array.shift(pd_tc)
        array.shift(pd_time)
        label.delete(array.shift(pd_lb))
else
    // Track high/low within session
    if not na(session_high)
        session_high := math.max(session_high, high)
        session_low := math.min(session_low, low)

// Check for touches
if ps_D and array.size(pd_ln) > 0
    for i = array.size(pd_ln) - 1 to 0
        l = array.get(pd_ln, i)
        t = array.get(pd_time, i)
        val = line.get_y1(l)
        ih = array.get(pd_ih, i)
        touched = (ih and high >= val) or (not ih and low <= val)
        if touched and t != time
            line.delete(l)
            label.delete(array.get(pd_lb, i))
            array.remove(pd_ln, i)
            array.remove(pd_lv, i)
            array.remove(pd_ih, i)
            array.remove(pd_tc, i)
            array.remove(pd_time, i)
            array.remove(pd_lb, i)

// Previous Weekly H/L
var line[]  pw_ln = array.new_line()
var float[] pw_lv = array.new_float()
var bool[]  pw_ih = array.new_bool()
var bool[]  pw_tc = array.new_bool()
var int[]   pw_time = array.new_int()
var label[] pw_lb = array.new_label()

var float week_high = na
var float week_low = na

current_week_start = ta.change(time("W"))

if current_week_start != 0
    if not na(week_high)
        array.push(pw_ln, line.new(bar_index, week_high, bar_index + 1, week_high, xloc = xloc.bar_index, extend = extend.right, color = pc_W, style = ps_sty, width = ps_w))
        array.push(pw_lv, week_high)
        array.push(pw_ih, true)
        array.push(pw_tc, false)
        array.push(pw_time, time)
        if ps_lbl
            array.push(pw_lb, label.new(bar_index + 5, week_high, "PWH " + str.tostring(week_high, format.mintick), style = label.style_none, textcolor = pc_W, size = size.normal, textalign = text.align_left))
        else
            array.push(pw_lb, label.new(na, na, na))
        
        array.push(pw_ln, line.new(bar_index, week_low, bar_index + 1, week_low, xloc = xloc.bar_index, extend = extend.right, color = pc_W, style = ps_sty, width = ps_w))
        array.push(pw_lv, week_low)
        array.push(pw_ih, false)
        array.push(pw_tc, false)
        array.push(pw_time, time)
        if ps_lbl
            array.push(pw_lb, label.new(bar_index + 5, week_low, "PWL " + str.tostring(week_low, format.mintick), style = label.style_none, textcolor = pc_W, size = size.normal, textalign = text.align_left))
        else
            array.push(pw_lb, label.new(na, na, na))
    
    week_high := high
    week_low := low
else
    if not na(week_high)
        week_high := math.max(week_high, high)
        week_low := math.min(week_low, low)

// Enforce max lines limit (always check)
while array.size(pw_ln) > ps_max
    line.delete(array.shift(pw_ln))
    array.shift(pw_lv)
    array.shift(pw_ih)
    array.shift(pw_tc)
    array.shift(pw_time)
    label.delete(array.shift(pw_lb))

if ps_W and array.size(pw_ln) > 0
    for i = array.size(pw_ln) - 1 to 0
        l = array.get(pw_ln, i)
        t = array.get(pw_time, i)
        val = line.get_y1(l)
        ih = array.get(pw_ih, i)
        touched = (ih and high >= val) or (not ih and low <= val)
        if touched and t != time
            line.delete(l)
            label.delete(array.get(pw_lb, i))
            array.remove(pw_ln, i)
            array.remove(pw_lv, i)
            array.remove(pw_ih, i)
            array.remove(pw_tc, i)
            array.remove(pw_time, i)
            array.remove(pw_lb, i)

// Previous Monthly H/L
var line[]  pm_ln = array.new_line()
var float[] pm_lv = array.new_float()
var bool[]  pm_ih = array.new_bool()
var bool[]  pm_tc = array.new_bool()
var int[]   pm_time = array.new_int()
var label[] pm_lb = array.new_label()

var float month_high = na
var float month_low = na

current_month_start = ta.change(time("M"))

if current_month_start != 0
    if not na(month_high)
        array.push(pm_ln, line.new(bar_index, month_high, bar_index + 1, month_high, xloc = xloc.bar_index, extend = extend.right, color = pc_M, style = ps_sty, width = ps_w))
        array.push(pm_lv, month_high)
        array.push(pm_ih, true)
        array.push(pm_tc, false)
        array.push(pm_time, time)
        if ps_lbl
            array.push(pm_lb, label.new(bar_index + 5, month_high, "PMH " + str.tostring(month_high, format.mintick), style = label.style_none, textcolor = pc_M, size = size.normal, textalign = text.align_left))
        else
            array.push(pm_lb, label.new(na, na, na))
        
        array.push(pm_ln, line.new(bar_index, month_low, bar_index + 1, month_low, xloc = xloc.bar_index, extend = extend.right, color = pc_M, style = ps_sty, width = ps_w))
        array.push(pm_lv, month_low)
        array.push(pm_ih, false)
        array.push(pm_tc, false)
        array.push(pm_time, time)
        if ps_lbl
            array.push(pm_lb, label.new(bar_index + 5, month_low, "PML " + str.tostring(month_low, format.mintick), style = label.style_none, textcolor = pc_M, size = size.normal, textalign = text.align_left))
        else
            array.push(pm_lb, label.new(na, na, na))
    
    month_high := high
    month_low := low
else
    if not na(month_high)
        month_high := math.max(month_high, high)
        month_low := math.min(month_low, low)

// Enforce max lines limit (always check)
while array.size(pm_ln) > ps_max
    line.delete(array.shift(pm_ln))
    array.shift(pm_lv)
    array.shift(pm_ih)
    array.shift(pm_tc)
    array.shift(pm_time)
    label.delete(array.shift(pm_lb))

if ps_M and array.size(pm_ln) > 0
    for i = array.size(pm_ln) - 1 to 0
        l = array.get(pm_ln, i)
        t = array.get(pm_time, i)
        val = line.get_y1(l)
        ih = array.get(pm_ih, i)
        touched = (ih and high >= val) or (not ih and low <= val)
        if touched and t != time
            line.delete(l)
            label.delete(array.get(pm_lb, i))
            array.remove(pm_ln, i)
            array.remove(pm_lv, i)
            array.remove(pm_ih, i)
            array.remove(pm_tc, i)
            array.remove(pm_time, i)
            array.remove(pm_lb, i)

// ═══════════════════════════════════════════════════════════════════════
// 6. GEX LEVELS - Lines + Labels + Dashboard
// ═══════════════════════════════════════════════════════════════════════

// ─── GEX Lines (horizontal, extend right) ───
var line gex_flip_line     = line.new(na, na, na, na)
var line gex_callwall_line = line.new(na, na, na, na)
var line gex_putwall_line  = line.new(na, na, na, na)
var line gex_oi_line       = line.new(na, na, na, na)
var line gex_0dte_line     = line.new(na, na, na, na)

// ─── GEX Labels ───
var label gex_flip_label     = label.new(na, na, na)
var label gex_callwall_label = label.new(na, na, na)
var label gex_putwall_label  = label.new(na, na, na)
var label gex_oi_label       = label.new(na, na, na)
var label gex_0dte_label     = label.new(na, na, na)

if barstate.islast and gex_on
    // Gamma Flip line
    line.delete(gex_flip_line)
    gex_flip_line := line.new(bar_index - 50, gex_flip, bar_index, gex_flip, xloc = xloc.bar_index, extend = extend.right, color = gex_flip_col, style = gex_flip_sty, width = gex_flip_w)
    
    // Call Wall line
    line.delete(gex_callwall_line)
    gex_callwall_line := line.new(bar_index - 50, gex_callwall, bar_index, gex_callwall, xloc = xloc.bar_index, extend = extend.right, color = gex_callwall_col, style = gex_callwall_sty, width = gex_callwall_w)
    
    // Put Wall line
    line.delete(gex_putwall_line)
    gex_putwall_line := line.new(bar_index - 50, gex_putwall, bar_index, gex_putwall, xloc = xloc.bar_index, extend = extend.right, color = gex_putwall_col, style = gex_putwall_sty, width = gex_putwall_w)
    
    // Highest OI line
    line.delete(gex_oi_line)
    gex_oi_line := line.new(bar_index - 50, gex_oi, bar_index, gex_oi, xloc = xloc.bar_index, extend = extend.right, color = gex_oi_col, style = gex_oi_sty, width = gex_oi_w)
    
    // 0DTE Magnet line
    line.delete(gex_0dte_line)
    gex_0dte_line := line.new(bar_index - 50, gex_0dte, bar_index, gex_0dte, xloc = xloc.bar_index, extend = extend.right, color = gex_0dte_col, style = gex_0dte_sty, width = gex_0dte_w)
    
    // Labels
    if gex_show_labels
        label.delete(gex_flip_label)
        gex_flip_label := label.new(bar_index + 5, gex_flip, "FLIP " + str.tostring(gex_flip, format.mintick), style = label.style_none, textcolor = gex_flip_col, size = size.small, textalign = text.align_left)
        
        label.delete(gex_callwall_label)
        gex_callwall_label := label.new(bar_index + 5, gex_callwall, "CALL WALL " + str.tostring(gex_callwall, format.mintick), style = label.style_none, textcolor = gex_callwall_col, size = size.small, textalign = text.align_left)
        
        label.delete(gex_putwall_label)
        gex_putwall_label := label.new(bar_index + 5, gex_putwall, "PUT WALL " + str.tostring(gex_putwall, format.mintick), style = label.style_none, textcolor = gex_putwall_col, size = size.small, textalign = text.align_left)
        
        label.delete(gex_oi_label)
        gex_oi_label := label.new(bar_index + 5, gex_oi, "OI " + str.tostring(gex_oi, format.mintick), style = label.style_none, textcolor = gex_oi_col, size = size.small, textalign = text.align_left)
        
        label.delete(gex_0dte_label)
        gex_0dte_label := label.new(bar_index + 5, gex_0dte, "0DTE " + str.tostring(gex_0dte, format.mintick), style = label.style_none, textcolor = gex_0dte_col, size = size.small, textalign = text.align_left)

// ─── GEX Dashboard ───
if barstate.islast and gex_on and gex_show_dashboard
    // Colors
    flip_col     = gex_positive ? color.new(color.green, 20) : color.new(color.red, 20)
    regime_text  = gex_positive ? "🟢 POSITIVE" : "🔴 NEGATIVE"
    regime_hint  = gex_positive ? "Ranges / Mean Reversion" : "Trends / Momentum"
    
    // Determine position
    dash_pos = gex_dash_pos == "Top Right" ? position.top_right : gex_dash_pos == "Top Left" ? position.top_left : gex_dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left
    
    // Create table
    var table gex_table = table.new(dash_pos, 2, 8, bgcolor = color.new(color.black, 20), border_color = color.new(color.gray, 50), border_width = 1)
    
    // Header
    table.cell(gex_table, 0, 0, "GEX LEVELS", text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 60))
    table.cell(gex_table, 1, 0, regime_text, text_color = color.white, text_size = size.small, bgcolor = flip_col)
    
    // Levels
    table.cell(gex_table, 0, 1, "Gamma Flip", text_color = color.gray, text_size = size.tiny)
    table.cell(gex_table, 1, 1, str.tostring(gex_flip, format.mintick), text_color = gex_flip_col, text_size = size.tiny)
    
    table.cell(gex_table, 0, 2, "Call Wall", text_color = color.gray, text_size = size.tiny)
    table.cell(gex_table, 1, 2, str.tostring(gex_callwall, format.mintick), text_color = gex_callwall_col, text_size = size.tiny)
    
    table.cell(gex_table, 0, 3, "Put Wall", text_color = color.gray, text_size = size.tiny)
    table.cell(gex_table, 1, 3, str.tostring(gex_putwall, format.mintick), text_color = gex_putwall_col, text_size = size.tiny)
    
    table.cell(gex_table, 0, 4, "Highest OI", text_color = color.gray, text_size = size.tiny)
    table.cell(gex_table, 1, 4, str.tostring(gex_oi, format.mintick), text_color = gex_oi_col, text_size = size.tiny)
    
    table.cell(gex_table, 0, 5, "0DTE Magnet", text_color = color.gray, text_size = size.tiny)
    table.cell(gex_table, 1, 5, str.tostring(gex_0dte, format.mintick), text_color = gex_0dte_col, text_size = size.tiny)
    
    table.cell(gex_table, 0, 6, "Spot", text_color = color.gray, text_size = size.tiny)
    table.cell(gex_table, 1, 6, str.tostring(close, format.mintick), text_color = color.white, text_size = size.tiny)
    
    table.cell(gex_table, 0, 7, "Hint", text_color = color.gray, text_size = size.tiny)
    table.cell(gex_table, 1, 7, regime_hint, text_color = color.new(color.white, 30), text_size = size.tiny)

// ─── GEX Alerts ───
gex_alert_flip     = gex_on and gex_flip > 0 and ta.cross(close, gex_flip)
gex_alert_callwall = gex_on and gex_callwall > 0 and ta.cross(close, gex_callwall)
gex_alert_putwall  = gex_on and gex_putwall > 0 and ta.cross(close, gex_putwall)

alertcondition(gex_alert_flip, "GEX Gamma Flip Crossed", "Price crossed Gamma Flip - regime change!")
alertcondition(gex_alert_callwall, "GEX Call Wall Crossed", "Price crossed Call Wall")
alertcondition(gex_alert_putwall, "GEX Put Wall Crossed", "Price crossed Put Wall")
````
