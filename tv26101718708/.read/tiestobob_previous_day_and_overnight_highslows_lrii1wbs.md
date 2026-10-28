# [Tiestobob] Previous Day and Overnight Highs/Lows

- url: https://www.tradingview.com/script/lrii1wbS-Tiestobob-Previous-Day-and-Overnight-Highs-Lows/
- type: indicator
- pine_id: PUB;5256ada3ce844391acc3fba902fce1bd
- version: 2.0

## Description

**[Tiestobob] Previous Day and Overnight Highs/Lows**

This indicator plots two of the most widely watched price levels used by intraday traders — the **Previous Day High/Low (PDH/PDL)** and the **Overnight High/Low (ONH/ONL)** — directly on your chart, automatically adjusted for New York time (EST/EDT).

---

**📌 What It Does**

- **Previous Day H/L** — Draws dashed white lines at the prior trading day's high and low (6:00 PM – 4:00 PM ET session)
- **Overnight H/L** — Draws dotted green/red lines marking the high and low of the overnight session (6:00 PM – 9:30 AM ET), a key range watched by futures and forex traders before the regular market open
- Optional **H/L labels** (PDH, PDL, ONH, ONL) appear at the close of each session
- Lines can be **extended to the right** so levels remain visible throughout the trading day

---

**⚙️ Settings**

| Option | Description |
|---|---|
| Select what to plot | Choose between Previous Day H/L or Overnight H/L |
| Show H/L Labels | Toggle end-of-session labels on/off |
| Line Width | Adjust line thickness (1–3) |
| Extend Lines Right | Keep levels visible after the session ends |

---

**📋 Notes**

- All sessions are calculated using the **America/New_York** timezone, automatically accounting for daylight saving time
- Best used on intraday timeframes (1m, 5m, 15m, 1H)
- Pairs well with volume profile, VWAP, and market structure tools

---

*These levels are commonly used as areas of interest for reversals, breakouts, and liquidity sweeps. Use them as context — not signals.*

## Source Code

````pine
//@version=6
// NOTE: max_labels_count added so older PDH/PDL/ONH/ONL labels aren't dropped
// (default cap is 50 labels ≈ 12 sessions). Remove it if you want stock behaviour.
indicator("[Tiestobob] Previous Day and Overnight Highs/Lows", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ─────────────────────────────────────
// Previous Day
showPDHL    = input.bool(true,  "Show Previous Day H/L", group="Previous Day", tooltip="Everything is based on New York Time Zone (EST)")
colPDH      = input.color(color.white, "PDH line colour", group="Previous Day")
colPDL      = input.color(color.white, "PDL line colour", group="Previous Day")
linPD       = input.string("line.style_dashed", "Previous High/Low line style", options = ["line.style_dashed","line.style_dotted","line.style_solid"], group="Previous Day")

// Overnight
showONHL    = input.bool(true,  "Show Overnight H/L", group="Overnight")
colONH      = input.color(color.green, "ONH line colour", group="Overnight")
colONL      = input.color(color.red,   "ONL line colour", group="Overnight")
linON       = input.string("line.style_dotted", "Overnight High/Low line style", options = ["line.style_dashed","line.style_dotted","line.style_solid"], group="Overnight")

// General
stopAtBreach = input.bool(true, "Stop level at first breach (1800-1659)", group="Toggles", tooltip="Any level (PDH/PDL/ONH/ONL) stops extending at the first bar it is broken. PD levels: breach counts the whole session. ON levels: breach counts after the 09:30 measurement window closes. Untick to always extend full session.")
showLabels  = input.bool(true,  "Show H/L Labels", group="Toggles")
lineWidth   = input.int(1, "Line Width", minval=1, maxval=3, group="Toggles")
extendLines = input.bool(true, "Extend Lines Right", group="Toggles")

// Map the style strings coming from the dropdowns onto real line style constants
f_lineStyle(string s) =>
    switch s
        "line.style_solid"  => line.style_solid
        "line.style_dotted" => line.style_dotted
        => line.style_dashed

stylePD = f_lineStyle(linPD)
styleON = f_lineStyle(linON)

// Use New York timezone explicitly (handles EST/EDT automatically)
nyTZ = "America/New_York"

// Session windows
pdSession = "1800-1655"
onSession = "1800-0930"

// Session flags
inPD   = not na(time(timeframe.period, pdSession, nyTZ))   // ETH day 1800-1600
inAsia = not na(time(timeframe.period, onSession, nyTZ))   // overnight 1800-0930

// ════════════════════════════════════════════════
// 1) PREVIOUS DAY H/L  (measured from chart bars over the 1800-1600 ETH session)
// ════════════════════════════════════════════════
newPD = inPD and not inPD[1]   // rising edge = start of a new ETH day (1800)

// Running high/low of the CURRENT ETH session (accumulates while inPD)
var float curHigh = na
var float curLow  = na

// Frozen PREVIOUS-session high/low used for this session's PDH/PDL
var float pdHigh  = na
var float pdLow   = na

var int   pdStartT = na
var line  pdHighLn = na
var line  pdLowLn  = na

// Breach tracking for the current display session
var bool pdhBreached = false
var bool pdlBreached = false

if showPDHL
    // Freeze previous PD line on the falling edge (leaving the PD window at 1600)
    if not inPD and inPD[1]
        if not na(pdHighLn)
            line.set_extend(pdHighLn, extend.none)
        if not na(pdLowLn)
            line.set_extend(pdLowLn, extend.none)

    // New ETH day: roll the just-finished session's running H/L into PDH/PDL (frozen),
    // then start accumulating the new session's running H/L.
    if newPD
        pdHigh   := curHigh        // previous completed session's high (na on very first day)
        pdLow    := curLow         // previous completed session's low
        curHigh  := high           // begin new session accumulation
        curLow   := low
        pdStartT := time
        pdHighLn := na
        pdLowLn  := na
        pdhBreached := false
        pdlBreached := false

    // Accumulate the current ETH session's running high/low (the FUTURE PDH/PDL)
    if inPD and not newPD
        curHigh := na(curHigh) ? high : math.max(curHigh, high)
        curLow  := na(curLow)  ? low  : math.min(curLow, low)

    // Breach detection against the FROZEN pdHigh/pdLow (whole session 1800-1659)
    pdhJustBreached = inPD and not pdhBreached and not na(pdHigh) and high > pdHigh
    pdlJustBreached = inPD and not pdlBreached and not na(pdLow)  and low  < pdLow
    if pdhJustBreached
        pdhBreached := true
    if pdlJustBreached
        pdlBreached := true

    pdHiFrozen = stopAtBreach and pdhBreached
    pdLoFrozen = stopAtBreach and pdlBreached

    // Label mitigated levels at the bar where the line stops. Unbreached levels are
    // still labelled at session end below, so every line ends up with exactly one label.
    if showLabels and stopAtBreach
        if pdhJustBreached
            label.new(time, pdHigh, "PDH", xloc=xloc.bar_time,
                    color=color.new(colPDH, 80), textcolor=color.white,
                    style=label.style_text_outline, size=size.small)
        if pdlJustBreached
            label.new(time, pdLow, "PDL", xloc=xloc.bar_time,
                    color=color.new(colPDL, 80), textcolor=color.white,
                    style=label.style_text_outline, size=size.small)

    // Draw only when we actually have a previous-session level (skip very first day)
    if inPD and (not na(pdHigh) or not na(pdLow))
        if na(pdHighLn) and na(pdLowLn)
            if not na(pdHigh)
                pdHighLn := line.new(pdStartT, pdHigh, time, pdHigh, xloc=xloc.bar_time,
                             color=colPDH, width=lineWidth,
                             extend=extendLines ? extend.right : extend.none,
                             style=stylePD)
            if not na(pdLow)
                pdLowLn  := line.new(pdStartT, pdLow, time, pdLow, xloc=xloc.bar_time,
                             color=colPDL, width=lineWidth,
                             extend=extendLines ? extend.right : extend.none,
                             style=stylePD)
        else
            // PDH: freeze at the breach bar, otherwise keep extending the right edge
            if not na(pdHighLn)
                if pdhJustBreached
                    line.set_xy2(pdHighLn, time, pdHigh)
                    line.set_extend(pdHighLn, extend.none)
                else if not pdHiFrozen
                    line.set_xy1(pdHighLn, pdStartT, pdHigh)
                    line.set_xy2(pdHighLn, time, pdHigh)
            // PDL: freeze at the breach bar, otherwise keep extending the right edge
            if not na(pdLowLn)
                if pdlJustBreached
                    line.set_xy2(pdLowLn, time, pdLow)
                    line.set_extend(pdLowLn, extend.none)
                else if not pdLoFrozen
                    line.set_xy1(pdLowLn, pdStartT, pdLow)
                    line.set_xy2(pdLowLn, time, pdLow)

    // Labels at session end — only for levels that were NOT breached
    if not inPD and inPD[1] and showLabels
        if not na(pdHigh) and not pdHiFrozen
            label.new(time, pdHigh, "PDH", xloc=xloc.bar_time,
                    color=color.new(colPDH, 80), textcolor=color.white,
                    style=label.style_text_outline, size=size.small)
        if not na(pdLow) and not pdLoFrozen
            label.new(time, pdLow, "PDL", xloc=xloc.bar_time,
                    color=color.new(colPDL, 80), textcolor=color.white,
                    style=label.style_text_outline, size=size.small)

// ════════════════════════════════════════════════
// 2) OVERNIGHT H/L
// ════════════════════════════════════════════════
inON      = inAsia                                            // measurement window 1800-0930
inRTH     = not na(time(timeframe.period, "0930-1659", nyTZ)) // display end at 4:59 PM EST
inONDisp  = inON or inRTH                                     // full display window 1800-1659

newON = inON and not inON[1]
endON = not inONDisp and inONDisp[1]

var float onHigh    = na
var float onLow     = na
var int   onStartT  = na
var line  onHighLn  = na
var line  onLowLn   = na
var bool  onActive  = false
var bool  onhBreached = false
var bool  onlBreached = false

if showONHL
    // Start a new overnight session at 1800 (freeze any still-active prior line)
    if newON
        // Safety net: on symbols with a 1700-1800 break (CME futures) there is no bar
        // outside the display window, so endON never fires and the outgoing levels
        // would never be labelled. Label them here instead, at the line's right edge.
        if onActive and showLabels
            if not na(onHighLn) and not na(onHigh) and not (stopAtBreach and onhBreached)
                label.new(line.get_x2(onHighLn), onHigh, "ONH", xloc=xloc.bar_time,
                        color=color.new(colONH, 80), textcolor=color.white,
                        style=label.style_text_outline, size=size.small)
            if not na(onLowLn) and not na(onLow) and not (stopAtBreach and onlBreached)
                label.new(line.get_x2(onLowLn), onLow, "ONL", xloc=xloc.bar_time,
                        color=color.new(colONL, 80), textcolor=color.white,
                        style=label.style_text_outline, size=size.small)
        if not na(onHighLn)
            line.set_extend(onHighLn, extend.none)
        if not na(onLowLn)
            line.set_extend(onLowLn, extend.none)
        onHigh   := high
        onLow    := low
        onStartT := time
        onHighLn := na
        onLowLn  := na
        onActive := true
        onhBreached := false
        onlBreached := false

    // Update overnight high/low only during the measurement window
    if inON and onActive and not na(onHigh)
        onHigh := math.max(onHigh, high)
        onLow  := math.min(onLow, low)

    // Breach detection ONLY after measurement closes (during RTH 0930-1659)
    onhJustBreached = inRTH and onActive and not onhBreached and not na(onHigh) and high > onHigh
    onlJustBreached = inRTH and onActive and not onlBreached and not na(onLow)  and low  < onLow
    if onhJustBreached
        onhBreached := true
    if onlJustBreached
        onlBreached := true

    onHiFrozen = stopAtBreach and onhBreached
    onLoFrozen = stopAtBreach and onlBreached

    // Label mitigated levels at the bar where the line stops. Unbreached levels are
    // still labelled at the end of the display window, so every line gets one label.
    if showLabels and stopAtBreach
        if onhJustBreached
            label.new(time, onHigh, "ONH", xloc=xloc.bar_time,
                    color=color.new(colONH, 80), textcolor=color.white,
                    style=label.style_text_outline, size=size.small)
        if onlJustBreached
            label.new(time, onLow, "ONL", xloc=xloc.bar_time,
                    color=color.new(colONL, 80), textcolor=color.white,
                    style=label.style_text_outline, size=size.small)

    // Draw / extend the overnight line during the display window
    if inONDisp and onActive and not na(onHigh)
        if na(onHighLn)
            onHighLn := line.new(onStartT, onHigh, time, onHigh, xloc=xloc.bar_time,
                         color=colONH, width=lineWidth,
                         extend=extendLines ? extend.right : extend.none,
                         style=styleON)
            onLowLn  := line.new(onStartT, onLow, time, onLow, xloc=xloc.bar_time,
                         color=colONL, width=lineWidth,
                         extend=extendLines ? extend.right : extend.none,
                         style=styleON)
        else
            // ONH: freeze at breach, otherwise extend
            if not na(onHighLn)
                if onhJustBreached
                    line.set_xy2(onHighLn, time, onHigh)
                    line.set_extend(onHighLn, extend.none)
                else if not onHiFrozen
                    line.set_xy1(onHighLn, onStartT, onHigh)
                    line.set_xy2(onHighLn, time, onHigh)
            // ONL: freeze at breach, otherwise extend
            if not na(onLowLn)
                if onlJustBreached
                    line.set_xy2(onLowLn, time, onLow)
                    line.set_extend(onLowLn, extend.none)
                else if not onLoFrozen
                    line.set_xy1(onLowLn, onStartT, onLow)
                    line.set_xy2(onLowLn, time, onLow)

    // Freeze + label at the end of the display window (1659)
    if endON and onActive
        if not na(onHighLn)
            line.set_extend(onHighLn, extend.none)
        if not na(onLowLn)
            line.set_extend(onLowLn, extend.none)
        if showLabels
            if not onHiFrozen and not na(onHigh)
                label.new(time, onHigh, "ONH", xloc=xloc.bar_time,
                        color=color.new(colONH, 80), textcolor=color.white,
                        style=label.style_text_outline, size=size.small)
            if not onLoFrozen and not na(onLow)
                label.new(time, onLow, "ONL", xloc=xloc.bar_time,
                        color=color.new(colONL, 80), textcolor=color.white,
                        style=label.style_text_outline, size=size.small)
        onActive := false
````
