# Fair Value Gap (FVG)

- url: https://www.tradingview.com/script/eOzbLuWn-Fair-Value-Gap-FVG/
- type: indicator
- pine_id: PUB;f24d98651db7423cb3e96085d9ad914b
- version: 5.0

## Description

Simple FVG marker for futures. It only places them on areas where price hasn't passed through yet that day for futures.

## Source Code

````pine
//@version=6
indicator("Fair Value Gap (FVG)", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
showBullish  = input.bool(true, "Show Bullish FVGs",     group="Display")
showBearish  = input.bool(true, "Show Bearish FVGs",     group="Display")
showMidline  = input.bool(true, "Show Midline",          group="Display")
showBands    = input.bool(true, "Show Top/Bottom Lines", group="Display")
maxFVGs      = input.int(3,     "Max Total FVGs",        group="Display", minval=1, maxval=20)
fvgTF        = input.timeframe("", "FVG Timeframe", group="Timeframe", tooltip="Leave blank to use chart timeframe. Enter 5, 15, etc.")
bullClr      = input.color(#00882B, "Bullish Color", group="Colors")
bearClr      = input.color(#CC1414, "Bearish Color", group="Colors")
midlineWidth = input.int(2, "Midline Width", group="Colors", minval=1, maxval=4)
bandWidth    = input.int(1, "Band Width",    group="Colors", minval=1, maxval=4)
sessionHour  = input.int(17, "Session Start Hour (CT)", group="Session Filter", minval=0, maxval=23)
sessionMin   = input.int(0,  "Session Start Minute",    group="Session Filter", minval=0, maxval=59)

// ── Resolve timeframe ─────────────────────────────────────────────────────────
resolvedTF = fvgTF == "" ? timeframe.period : fvgTF
tfMs = timeframe.in_seconds(resolvedTF) * 1000

// ── gaps=on ───────────────────────────────────────────────────────────────────
f_h0() => high
f_h2() => high[2]
f_l0() => low
f_l2() => low[2]
f_t2() => time[2]

h0 = request.security(syminfo.tickerid, resolvedTF, f_h0(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
h2 = request.security(syminfo.tickerid, resolvedTF, f_h2(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
l0 = request.security(syminfo.tickerid, resolvedTF, f_l0(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
l2 = request.security(syminfo.tickerid, resolvedTF, f_l2(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
t2 = request.security(syminfo.tickerid, resolvedTF, f_t2(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

tfBarClosed = not na(h0)

// ── Session boundary ─────────────────────────────────────────────────────────
sessStart() =>
    t = timestamp("America/Chicago", year, month, dayofmonth, sessionHour, sessionMin, 0)
    t > time ? t - 86400000 : t

sessBegin   = sessStart()
c1InSession = not na(t2) and t2 >= sessBegin

// ── FVG conditions ────────────────────────────────────────────────────────────
isBullFVG = tfBarClosed and c1InSession and h2 < l0
isBearFVG = tfBarClosed and c1InSession and l2 > h0

// ── Data-only storage (no line objects stored — redrawn fresh each bar) ───────
var array<float> fvg_tops  = array.new<float>()
var array<float> fvg_bots  = array.new<float>()
var array<int>   fvg_t1    = array.new<int>()
var array<color> fvg_color = array.new<color>()

// Lines are redrawn every bar — tracked only so we can delete them
var array<line>  active_lines = array.new<line>()

// ── Add FVG data only ─────────────────────────────────────────────────────────
fvg_add(float gapTop, float gapBot, color clr, int t1) =>
    array.push(fvg_tops,  gapTop)
    array.push(fvg_bots,  gapBot)
    array.push(fvg_t1,    t1)
    array.push(fvg_color, clr)
    if array.size(fvg_tops) > maxFVGs
        array.shift(fvg_tops)
        array.shift(fvg_bots)
        array.shift(fvg_t1)
        array.shift(fvg_color)

// ── Session reset ─────────────────────────────────────────────────────────────
isNewSession = sessBegin != sessStart()[1]
if isNewSession
    array.clear(fvg_tops)
    array.clear(fvg_bots)
    array.clear(fvg_t1)
    array.clear(fvg_color)

// ── Register new FVGs ─────────────────────────────────────────────────────────
if isBullFVG and showBullish
    fvg_add(l0, h2, bullClr, int(t2))

if isBearFVG and showBearish
    fvg_add(l2, h0, bearClr, int(t2))

// ── Delete all active lines then redraw oldest→newest so newest is on top ─────
for ln in active_lines
    line.delete(ln)
array.clear(active_lines)

sz = array.size(fvg_tops)
if sz > 0
    for i = 0 to sz - 1
        gapTop  = array.get(fvg_tops,  i)
        gapBot  = array.get(fvg_bots,  i)
        clr     = array.get(fvg_color, i)
        t1      = array.get(fvg_t1,    i)
        gapMid  = math.avg(gapTop, gapBot)
        t2x     = t1 + tfMs
        bandClr = showBands   ? clr : color.new(clr, 100)
        midClr  = showMidline ? clr : color.new(clr, 100)
        tl = line.new(t1, gapTop, t2x, gapTop, color=bandClr, width=bandWidth,    style=line.style_solid, extend=extend.right, xloc=xloc.bar_time)
        ml = line.new(t1, gapMid, t2x, gapMid, color=midClr,  width=midlineWidth, style=line.style_solid, extend=extend.right, xloc=xloc.bar_time)
        bl = line.new(t1, gapBot, t2x, gapBot, color=bandClr, width=bandWidth,    style=line.style_solid, extend=extend.right, xloc=xloc.bar_time)
        array.push(active_lines, tl)
        array.push(active_lines, ml)
        array.push(active_lines, bl)
````
