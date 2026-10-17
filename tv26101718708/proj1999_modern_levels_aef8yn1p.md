# PROJ-1999 Modern Levels

- url: https://www.tradingview.com/script/aEF8Yn1P-PROJ-1999-Modern-Levels/
- type: indicator
- pine_id: PUB;fe44aa1cfa634be78485ce8a0ecc945b
- version: 2.0

## Description

this is for light bull crap levels 

 Add to chart (best on 2m/5m futures charts):

Auto-anchors at 10:30 ET (first-hour end, configurable) and draws both ladders — teal projected highs off the first-hour low, red projected lows off the first-hour high — with TOUCH-80 dashed, MEDIAN solid, CAP-80 dotted, price labels on each
Computes the 10-day RTH range internally (seeding hint shows until it has 10 days of chart history)
Toggle the classic 1999 0.8× line to see how the old worksheet compares live
Alerts on TOUCH-80 hits both directions
All three multipliers are inputs — when we refit on more data, you just update the settings
How to actually use it (per the validated numbers): once one early extreme holds, TOUCH-80 on the other side is a ~4-in-5 magnet — a target-confidence tool, not a fade level (CAP-80 gets run through 1-in-5 days; the 0.8× line gets steamrolled half the time). Everything's logged and vaulted; refit is a 1-command rerun when more archive accrues.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// PROJ-1999 · MODERN LEVELS v2 — GHOSTKEYZ edition (2026-07-11)
//
// The 1996-99 "Trading Tutor / BEK" worksheet, recalibrated on 2026 CME micro
// futures (MNQ/MES/MGC, RTH 09:30-16:00 ET, 82-day pooled sweep, split-half
// validated). What survived, what changed:
//   · the day's HIGH or LOW forms in the first hour ~85% of days (96% in two)
//   · BEST SETTINGS (OOS-calibrated): anchor 60 min · 5-DAY avg range base
//     (5d beats 10d — tracks the current regime faster) · multipliers:
//         preset        TOUCH-80   MEDIAN   CAP-80
//         Pooled          0.70      1.00     1.34
//         MNQ             0.70      0.90     1.29
//         MES             0.63      1.01     1.30
//         MGC             0.56      0.98     1.71   (gold = fat tails)
//     TOUCH-80 = minimum objective (~70-80% reached) · CAP-80 = stretch
//     ceiling (~80% contained). The original 0.80x is obsolete as drawn.
//   · TURN WINDOWS modernized: extremes cluster in the OPEN BLOCK
//     (09:30-10:30, 45% of all extremes — BEK's 09:45/WW 10:00 confirmed)
//     and the CLOSE BLOCK (15:30-16:00, 10%); the 1996 midday turn times
//     (11:45/12:40/13:15) are dead (2-4%). Both windows shade on-chart.
// Ladders print at the end of the first hour:
//   UP   = first-hour LOW  + m × 5R   (projected highs)
//   DOWN = first-hour HIGH − m × 5R   (projected lows)
// Watch which early extreme holds; TOUCH-80 on the other side is the magnet.
// Never fade these levels blind — the market blows through CAP 1-in-5 days.
// ─────────────────────────────────────────────────────────────────────────────
indicator("PROJ-1999 Modern Levels v2", overlay = true,
          max_lines_count = 500, max_labels_count = 500)

sessStr   = input.session("0930-1600", "RTH session")
tzStr     = input.string("America/New_York", "Session timezone")
anchorMin = input.int(60, "Anchor: minutes after open", minval = 15, maxval = 240)
lookback  = input.int(5, "Average-range days (5R = best OOS)", minval = 3, maxval = 30)
preset    = input.string("Pooled (best OOS)", "Multiplier preset",
             options = ["Pooled (best OOS)", "MNQ", "MES", "MGC", "Custom"])
cTouch    = input.float(0.70, "Custom TOUCH-80", step = 0.01)
cMed      = input.float(1.00, "Custom MEDIAN",   step = 0.01)
cCap      = input.float(1.34, "Custom CAP-80",   step = 0.01)
showClassic = input.bool(false, "Show classic 1999 level (0.80x)")
showDn    = input.bool(true, "Show DOWN ladder (projected lows)")
showUp    = input.bool(true, "Show UP ladder (projected highs)")
showWins  = input.bool(true, "Shade extreme-formation windows (open + close)")

mTouch = preset == "MNQ" ? 0.70 : preset == "MES" ? 0.63 :
         preset == "MGC" ? 0.56 : preset == "Custom" ? cTouch : 0.70
mMed   = preset == "MNQ" ? 0.90 : preset == "MES" ? 1.01 :
         preset == "MGC" ? 0.98 : preset == "Custom" ? cMed : 1.00
mCap   = preset == "MNQ" ? 1.29 : preset == "MES" ? 1.30 :
         preset == "MGC" ? 1.71 : preset == "Custom" ? cCap : 1.34

inSess  = not na(time(timeframe.period, sessStr, tzStr))
newSess = inSess and not inSess[1]
endSess = (not inSess) and inSess[1]
closeWin = not na(time(timeframe.period, "1530-1600", tzStr))

var float dayHi = na
var float dayLo = na
var float fhHi  = na
var float fhLo  = na
var int   sess0 = na
var bool  anchored = false
var ranges = array.new_float()

if newSess
    dayHi := high
    dayLo := low
    sess0 := time
    anchored := false
    fhHi := na
    fhLo := na
if inSess
    dayHi := math.max(nz(dayHi, high), high)
    dayLo := math.min(nz(dayLo, low), low)
if endSess and not na(dayHi) and not na(dayLo)
    array.unshift(ranges, dayHi - dayLo)
    if array.size(ranges) > lookback
        array.pop(ranges)

mkLine(px, col, sty, wid) =>
    line.new(bar_index, px, bar_index + 1, px, color = col, style = sty,
             width = wid, extend = extend.none)

mkLab(px, txt, col, up) =>
    label.new(bar_index, px, txt, style = up ? label.style_label_lower_left
              : label.style_label_upper_left, color = color.new(col, 82),
              textcolor = col, size = size.small)

var line[] lns = array.new_line()
var float baseR = na

if inSess and not anchored and not na(sess0) and (time - sess0 >= anchorMin * 60 * 1000)
    anchored := true
    fhHi := dayHi
    fhLo := dayLo
    baseR := array.size(ranges) >= lookback ? array.avg(ranges) : na
    if not na(baseR)
        array.clear(lns)
        cUp = color.new(color.teal, 0)
        cDn = color.new(color.red, 15)
        cCl = color.new(color.orange, 0)
        if showUp
            array.push(lns, mkLine(fhLo + mTouch * baseR, cUp, line.style_dashed, 2))
            array.push(lns, mkLine(fhLo + mMed   * baseR, cUp, line.style_solid,  2))
            array.push(lns, mkLine(fhLo + mCap   * baseR, cUp, line.style_dotted, 1))
            mkLab(fhLo + mTouch * baseR, "TOUCH-80 ▲ " + str.tostring(fhLo + mTouch * baseR, format.mintick), cUp, true)
            mkLab(fhLo + mMed   * baseR, "MEDIAN ▲ "   + str.tostring(fhLo + mMed   * baseR, format.mintick), cUp, true)
            mkLab(fhLo + mCap   * baseR, "CAP-80 ▲ "   + str.tostring(fhLo + mCap   * baseR, format.mintick), cUp, true)
            if showClassic
                array.push(lns, mkLine(fhLo + 0.80 * baseR, cCl, line.style_dotted, 1))
                mkLab(fhLo + 0.80 * baseR, "1999 0.8x ▲", cCl, true)
        if showDn
            array.push(lns, mkLine(fhHi - mTouch * baseR, cDn, line.style_dashed, 2))
            array.push(lns, mkLine(fhHi - mMed   * baseR, cDn, line.style_solid,  2))
            array.push(lns, mkLine(fhHi - mCap   * baseR, cDn, line.style_dotted, 1))
            mkLab(fhHi - mTouch * baseR, "TOUCH-80 ▼ " + str.tostring(fhHi - mTouch * baseR, format.mintick), cDn, false)
            mkLab(fhHi - mMed   * baseR, "MEDIAN ▼ "   + str.tostring(fhHi - mMed   * baseR, format.mintick), cDn, false)
            mkLab(fhHi - mCap   * baseR, "CAP-80 ▼ "   + str.tostring(fhHi - mCap   * baseR, format.mintick), cDn, false)
            if showClassic
                array.push(lns, mkLine(fhHi - 0.80 * baseR, cCl, line.style_dotted, 1))
                mkLab(fhHi - 0.80 * baseR, "1999 0.8x ▼", cCl, false)

if inSess and anchored and array.size(lns) > 0
    for i = 0 to array.size(lns) - 1
        line.set_x2(array.get(lns, i), bar_index)

// extreme-formation windows: open block (pre-anchor) + close block
bgcolor(showWins and inSess and not anchored ? color.new(color.blue, 93) :
        showWins and closeWin ? color.new(color.purple, 93) : na)

upTouch = anchored and not na(fhLo) and not na(baseR) and showUp and
          ta.crossover(high, fhLo + mTouch * baseR)
dnTouch = anchored and not na(fhHi) and not na(baseR) and showDn and
          ta.crossunder(low, fhHi - mTouch * baseR)
alertcondition(upTouch, "TOUCH-80 UP reached", "PROJ1999v2: minimum upside objective reached")
alertcondition(dnTouch, "TOUCH-80 DOWN reached", "PROJ1999v2: minimum downside objective reached")

var table t = table.new(position.bottom_right, 1, 1)
if barstate.islast and array.size(ranges) < lookback
    table.cell(t, 0, 0, "PROJ-1999: seeding ranges " + str.tostring(array.size(ranges)) +
               "/" + str.tostring(lookback) + " days — load more history",
               text_color = color.orange, bgcolor = color.new(color.black, 40))
````
