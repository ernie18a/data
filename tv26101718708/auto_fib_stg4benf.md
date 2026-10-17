# Auto Fib

- url: https://www.tradingview.com/script/STG4BENF-Auto-Fib/
- type: indicator
- pine_id: PUB;37ee0b15afdc48668ff9c6a231e17801
- version: 1.0

## Description

the Fib level in yellow are not that visiblile i want to adjust the size of themAdding configurable inputs for line visibility adjustmentsAdding configurable inputs for line visibility adjustmentsLet me look at how the fib lines and labels are currently configured, and what inputs exist:Architected configurable inputs for Fibonacci line visibilityArchitected configurable inputs for Fibonacci line visibilityFound it. The fib lines are hardcoded to width=1 and style=line.style_dotted, and labels to size=size.small — that's why they're faint. I'll add user-adjustable inputs for line width, line style, and label size so you can tune visibility yourself. Let me view the input section first:View the fib input declarations to add new appearance inputsView the fib input declarations to add new appearance inputsNow let me add the appearance inputs and their mapping:Add line width, line style, and label size inputs for fib visibilityAdd line width, line style, and label size inputs for fib visibilityNow update the six line.new calls to use the new inputs:Apply fibStyle and fibWidth to all six fib linesApply fibStyle and fibWidth to all six fib linesNow update the six labels to use the adjustable size and a more visible background:Edited a file, read a fileEdited a file, read a fileDone. Three new controls in the Levels settings group:

Fib line width (1–5, default now 2) — the main visibility lever
Fib line style — Solid / Dashed / Dotted (default now Solid)
Fib label size — Tiny / Small / Normal / Large / Huge (default now Normal)

I also bumped the defaults toward more visible (solid, width 2, normal labels) and made the label backgrounds less transparent (60 instead of 80), so they'll stand out more right away. If solid width-2 is too heavy, drop width back to 1 or switch to dashed. Recompile in TradingView and tune from the settings panel.Mes fib countertouch v1PINE ok now we need to remove everything what has nothing to do with the Fiblevels, i do not need to send a signal i just want the fib levles. 
Als the name needs to be "Auto Fib"Strategized script refactoring to isolate Fibonacci levels functionality exclusivelyStrategized script refactoring to isolate Fibonacci levels functionality exclusivelyLet me read the full script to see exactly what's fib-related and what's signal/trade logic to strip out:Distinguishing Fibonacci-only features from extraneous signal componentsDistinguishing Fibonacci-only features from extraneous signal componentsLet me see the truncated middle section to understand the full structure:Architected stripped-down indicator retaining only Fibonacci level functionalityArchitected stripped-down indicator retaining only Fibonacci level functionalityThis is a big strip-down — I'll remove all the signal state, entry/exit logic, force-flat, trade lines, plotshape markers, export plots, and the entire webhook block, keeping only the fib build/draw code (plus the session divider, since it marks the fib build window). Renaming to "Auto Fib" and saving as a clean new file so your strategy version stays intact.Created a file, read a fileCreated a file, read a fileDone. Auto_Fib.pine — clean display-only indicator, named "Auto Fib".
Kept (everything fib-related):

Build window inputs (15:00 start → 02:00 freeze, excluding the 02:00 candle)
The 6 fib levels in trend direction, frozen at 02:00, drawn to 14:00
All your visibility controls (color, line width, line style, label size, sessions to display)
Session divider at the build start (optional toggle)

Removed (~310 lines):

Entire signal state machine — entries, exits, TP/SL brackets, force-flat, max-trades, skip-list, used-levels
Trade lines + entry/exit plotshape markers
Invisible export plots (the Python-backtest columns)
The whole webhook/alert block + the Signals, Webhook, and trade-Display input groups

Went from 421 lines to ~135. Recompiles to a pure overlay that just paints the fib levels. Your MES_Fib_CounterTouch_v1.pine is untouched if you ever want the signal version back.Auto fibPINE What time does the fib level gets generated and what time is it using ?Analyzed script logic to pinpoint generation timing and timezoneAnalyzed script logic to pinpoint generation timing and timezoneTwo things, both pulled straight from the script:
Timezone: Everything runs on Pacific Time — America/Los_Angeles, hardcoded. It's DST-aware (auto-shifts PST↔PDT), and it's independent of whatever timezone your TradingView chart is set to display. So even if your chart shows exchange time or UTC, the fib build is using PT internally.
When it's generated: At the close of the 02:00 PT candle. That's the freezeNow trigger — the first confirmed bar where PT time crosses 02:00. At that moment it takes the accumulated session high/low, picks the trend direction (green if the 02:00 close is above the 15:00 open, red if below), computes the six levels, and draws them.
What data goes into it: the candles from 15:00 PT through 01:59:59 PT — the 02:00 candle itself is excluded (that's the fix from earlier; freeze runs before that bar gets accumulated). The lines are then drawn from 02:00 PT out to 14:00 PT the same day.
All three times are adjustable in the Fib Levels input group (build start, freeze/end, line end), but the defaults are 15:00 → 02:00 build, drawn to 14:00.i want to publish it can you give me a discriptionHere's a description for publishing:

Auto Fib
Auto Fib automatically plots six Fibonacci levels each day, built from the overnight session and projected across the following trading day.
How it works
At the close of the 02:00 PT candle, the indicator measures the range of the overnight session — from 15:00 PT the prior afternoon through 01:59:59 PT. It determines direction from that session's move (bullish if the session closed above its open, bearish if below), anchors the 0% point accordingly, and computes six levels: -1.236, -0.786, -0.236, 0.236, 0.786, and 1.236. The levels freeze at 02:00 and are drawn as clean horizontal segments across the day to 14:00 PT.
Because the levels are locked once the session closes, they don't repaint — what you see at 02:00 is what stays on the chart.
Settings

Build window — fully adjustable start, freeze, and line-end times (defaults: 15:00 build start → 02:00 freeze → 14:00 line end, all Pacific Time)
Appearance — line color, width, and style (solid / dashed / dotted); label size; and how many past sessions to keep on screen
Session divider — optional vertical marker at the build-window start

All times run on Pacific Time internally and are DST-aware, independent of your chart's display timezone.
Notes
This is a display-only indicator — it draws levels and does not generate buy/sell signals or send alerts. It works on any intraday timeframe; lower timeframes (1–15 min) give the most precise session range. Designed and tested on index futures (MES/ES), but it runs on any symbol.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
//  AUTO FIB
//  • Daily fib levels built in TREND direction from the 15:00 → 02:00 PT
//    session candle (green day: 0% = high, extends up; red day: 0% = low,
//    extends down). The 02:00 candle is EXCLUDED → range = 15:00–01:59:59.
//  • Levels: -1.236, -0.786, -0.236, 0.236, 0.786, 1.236
//    Frozen at 02:00 PT, drawn as fixed-length segments to 14:00 PT same day.
//  • Display only — no signals, no orders, no webhook.
// ═══════════════════════════════════════════════════════════════════
indicator("Auto Fib", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ─── INPUTS ───
grpLvl = "Fib Levels"
sessionStartHourPT = input.int(15, "Build window START hour PT", group=grpLvl, minval=0, maxval=23)
sessionStartMinPT  = input.int(0,  "Build window START min PT",  group=grpLvl, minval=0, maxval=59)
freezeHourPT       = input.int(2,  "Build window END / freeze hour PT", group=grpLvl, minval=0, maxval=23)
freezeMinPT        = input.int(0,  "Build window END / freeze min PT",  group=grpLvl, minval=0, maxval=59)
lineEndHourPT      = input.int(14, "Fib line END hour PT (same day)",    group=grpLvl, minval=0, maxval=23)
lineEndMinPT       = input.int(0,  "Fib line END min PT",                group=grpLvl, minval=0, maxval=59)
fibShow      = input.bool(true,  "Show fib levels",      group=grpLvl)
fibShowLbls  = input.bool(true,  "Show fib labels",      group=grpLvl)
fibShowDays  = input.int(5,      "Sessions to display",  group=grpLvl, minval=1, maxval=60)
fibColor     = input.color(color.orange, "Fib color",   group=grpLvl)
fibWidth     = input.int(2, "Fib line width", group=grpLvl, minval=1, maxval=5)
fibStyleStr  = input.string("Solid", "Fib line style", options=["Solid","Dashed","Dotted"], group=grpLvl)
fibLblSzStr  = input.string("Normal", "Fib label size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLvl)
showDivider  = input.bool(true, "Show session divider (build start)", group=grpLvl)
fibStyle = fibStyleStr == "Dashed" ? line.style_dashed : fibStyleStr == "Dotted" ? line.style_dotted : line.style_solid
fibLblSz = fibLblSzStr == "Tiny" ? size.tiny : fibLblSzStr == "Small" ? size.small : fibLblSzStr == "Large" ? size.large : fibLblSzStr == "Huge" ? size.huge : size.normal

// ─── TIME (PT) ───
ptHour   = hour(time,   "America/Los_Angeles")
ptMinute = minute(time, "America/Los_Angeles")
modNow   = ptHour * 60 + ptMinute
startThr = sessionStartHourPT * 60 + sessionStartMinPT
freezeThr= freezeHourPT       * 60 + freezeMinPT
buildStartNow = not na(modNow[1]) and modNow >= startThr  and modNow[1] < startThr
freezeNow     = not na(modNow[1]) and modNow >= freezeThr and modNow[1] < freezeThr

// ─── FIB BUILD STATE ───
var float acc_O  = na
var float acc_H  = na
var float acc_L  = na
var bool  acc_on = false

var float fib_Lm = na   // -1.236
var float fib_L0 = na   // -0.786
var float fib_L1 = na   // -0.236
var float fib_L2 = na   //  0.236
var float fib_L3 = na   //  0.786
var float fib_Lp = na   //  1.236

var line[]  fib_archL = array.new<line>()
var label[] fib_archB = array.new<label>()

fib_roundTick(_x) => math.round(_x / syminfo.mintick) * syminfo.mintick

if barstate.isconfirmed
    // freeze FIRST (before accumulating current bar) so the 02:00 candle is excluded.
    // Range is 15:00–01:59:59 only.
    if freezeNow and acc_on
        cC  = close
        grn = cC >= acc_O
        a0  = grn ? acc_H : acc_L
        a1  = grn ? acc_L : acc_H
        rng = a1 - a0
        fib_Lm := fib_roundTick(a0 + (-1.236) * rng)
        fib_L0 := fib_roundTick(a0 + (-0.786) * rng)
        fib_L1 := fib_roundTick(a0 + (-0.236) * rng)
        fib_L2 := fib_roundTick(a0 + ( 0.236) * rng)
        fib_L3 := fib_roundTick(a0 + ( 0.786) * rng)
        fib_Lp := fib_roundTick(a0 + ( 1.236) * rng)
        acc_on := false

        if fibShow
            // fixed-length segment: from freeze (02:00) to lineEnd (14:00) the SAME PT day
            endTime = timestamp("America/Los_Angeles", year(time, "America/Los_Angeles"), month(time, "America/Los_Angeles"), dayofmonth(time, "America/Los_Angeles"), lineEndHourPT, lineEndMinPT, 0)
            lm = line.new(time, fib_Lm, endTime, fib_Lm, xloc=xloc.bar_time, extend=extend.none, color=fibColor, style=fibStyle, width=fibWidth)
            l0 = line.new(time, fib_L0, endTime, fib_L0, xloc=xloc.bar_time, extend=extend.none, color=fibColor, style=fibStyle, width=fibWidth)
            l1 = line.new(time, fib_L1, endTime, fib_L1, xloc=xloc.bar_time, extend=extend.none, color=fibColor, style=fibStyle, width=fibWidth)
            l2 = line.new(time, fib_L2, endTime, fib_L2, xloc=xloc.bar_time, extend=extend.none, color=fibColor, style=fibStyle, width=fibWidth)
            l3 = line.new(time, fib_L3, endTime, fib_L3, xloc=xloc.bar_time, extend=extend.none, color=fibColor, style=fibStyle, width=fibWidth)
            lp = line.new(time, fib_Lp, endTime, fib_Lp, xloc=xloc.bar_time, extend=extend.none, color=fibColor, style=fibStyle, width=fibWidth)
            array.push(fib_archL, lm)
            array.push(fib_archL, l0)
            array.push(fib_archL, l1)
            array.push(fib_archL, l2)
            array.push(fib_archL, l3)
            array.push(fib_archL, lp)
            if fibShowLbls
                bm = label.new(time, fib_Lm, "-1.236", xloc=xloc.bar_time, style=label.style_label_right, color=color.new(fibColor, 60), textcolor=fibColor, size=fibLblSz)
                b0 = label.new(time, fib_L0, "-0.786", xloc=xloc.bar_time, style=label.style_label_right, color=color.new(fibColor, 60), textcolor=fibColor, size=fibLblSz)
                b1 = label.new(time, fib_L1, "-0.236", xloc=xloc.bar_time, style=label.style_label_right, color=color.new(fibColor, 60), textcolor=fibColor, size=fibLblSz)
                b2 = label.new(time, fib_L2,  "0.236", xloc=xloc.bar_time, style=label.style_label_right, color=color.new(fibColor, 60), textcolor=fibColor, size=fibLblSz)
                b3 = label.new(time, fib_L3,  "0.786", xloc=xloc.bar_time, style=label.style_label_right, color=color.new(fibColor, 60), textcolor=fibColor, size=fibLblSz)
                bp = label.new(time, fib_Lp,  "1.236", xloc=xloc.bar_time, style=label.style_label_right, color=color.new(fibColor, 60), textcolor=fibColor, size=fibLblSz)
                array.push(fib_archB, bm)
                array.push(fib_archB, b0)
                array.push(fib_archB, b1)
                array.push(fib_archB, b2)
                array.push(fib_archB, b3)
                array.push(fib_archB, bp)
            // keep only the last N sessions on screen
            fib_cap = fibShowDays * 6
            while array.size(fib_archL) > fib_cap
                line.delete(array.shift(fib_archL))
            while array.size(fib_archB) > fib_cap
                label.delete(array.shift(fib_archB))

    // accumulate the session candle (EXCLUDING the freeze hour candle)
    if buildStartNow
        acc_O  := open
        acc_H  := high
        acc_L  := low
        acc_on := true
    else if acc_on
        acc_H := math.max(acc_H, high)
        acc_L := math.min(acc_L, low)

// ─── SESSION DIVIDER at build start (15:00) ───
var array<line> dividerLines = array.new<line>()
if barstate.isconfirmed and buildStartNow and showDivider
    dl = line.new(bar_index, low - syminfo.mintick, bar_index, high + syminfo.mintick, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.gray, 40), style=line.style_dotted, width=1)
    array.push(dividerLines, dl)
    if array.size(dividerLines) > 40
        line.delete(array.shift(dividerLines))
````
