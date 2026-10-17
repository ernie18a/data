# ICT 15m FVG Retest Alert

- url: https://www.tradingview.com/script/i8yXJVHd-ICT-15m-FVG-Retest-Alert/
- type: indicator
- pine_id: PUB;51a37084d0b94b089680f8b65c145929
- version: 1.0

## Description

Sends a notification to app when price retests a 15min FVG

## Source Code

````pine
//@version=6
// =====================================================================
//  ICT 15m FVG • Retest Alert (intrabar + re-arm)  •  Pine v6
//  - Detects 3-candle ICT Fair Value Gaps (run on a 15m chart, e.g. NQ1!)
//  - Phone alert fires INTRABAR the instant price taps the gap
//  - Re-arms: once the gap has been fully untouched (no candle range
//    overlap) for >= N minutes, the next entry fires another alert
//  - Green/red arrow drawn on every tap (first + re-taps); state commits
//    at bar close so nothing flickers
//  - Removes UNMITIGATED gaps older than N days (default 5)
//  - Deletes the box AND ALL its arrows once a candle CLOSES fully
//    through the gap (inversion / fully traded through)
// =====================================================================
indicator("ICT 15m FVG • Retest Alert", "ICT 15m FVG", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────── Inputs ─────────────────────────
gA = "Setup"
warnTF        = input.bool(true,  "Warn if chart is not 15m", group = gA)

gV = "Appearance"
bullCol       = input.color(color.new(#26a69a, 0), "Bullish FVG color", group = gV)
bearCol       = input.color(color.new(#ef5350, 0), "Bearish FVG color", group = gV)
boxTransp     = input.int(85, "Box fill transparency", minval = 0, maxval = 100, group = gV)
showMid       = input.bool(true, "Show midline (CE)", group = gV)
arrowSize     = input.string("large", "Tap arrow size", options = ["small", "normal", "large", "huge"], group = gV)

gL = "Lifecycle"
expiryDays    = input.int(5, "Remove UNMITIGATED gaps after (days)", minval = 1, group = gL, tooltip = "Calendar days. Gaps never retested and older than this are deleted.")
removeMitDays = input.int(0, "Remove mitigated gaps after (days, 0 = keep)", minval = 0, group = gL, tooltip = "0 keeps retested gaps on the chart until they close through / invert.")

gAL = "Alerts"
alertOn       = input.bool(true, "Enable tap alerts", group = gAL)
reArmMin      = input.int(1, "Re-arm after N minutes fully outside gap (0 = first tap only)", minval = 0, group = gAL, tooltip = "After a tap, the gap re-arms only once price has left the gap entirely (no candle range overlaps it) for at least N minutes. Then the next entry fires another alert. Set 0 to alert on first tap only.")

// arrow size mapping
aSize = arrowSize == "small" ? size.small : arrowSize == "normal" ? size.normal : arrowSize == "huge" ? size.huge : size.large

// constants
DAY     = 24 * 60 * 60 * 1000
MIN     = 60 * 1000
reArmMs = reArmMin * MIN

// ───────────────────────── Type ─────────────────────────
type fvg
    box           bx
    line          mid
    array<label>  arrows
    float         top           // upper edge of gap (higher price)
    float         bot           // lower edge of gap (lower price)
    bool          bull
    bool          mitigated     // tapped at least once?
    int           tCreated      // bar time when formed (ms)
    int           outsideSince  // 0 if currently overlapping; else time when current outside streak began

// ───────────────────────── State ─────────────────────────
var array<fvg> store = array.new<fvg>()

// ═════════════════ Intrabar alert engine ═════════════════
// Fires the instant price touches the gap. Once per bar. Re-fires only
// after the gap has been fully outside for >= reArmMs.
if alertOn and array.size(store) > 0
    for g in store
        overlap = low <= g.top and high >= g.bot
        if overlap
            firstTap = not g.mitigated
            reTap    = g.mitigated and reArmMin > 0 and g.outsideSince != 0 and (time - g.outsideSince) >= reArmMs
            if firstTap or reTap
                kind = firstTap ? "TAP" : "RE-TAP"
                dir  = g.bull ? "Bullish" : "Bearish"
                msg  = dir + " 15m FVG " + kind + " • " + syminfo.ticker + " • " + str.tostring(math.min(g.top, g.bot), format.mintick) + " – " + str.tostring(math.max(g.top, g.bot), format.mintick)
                alert(msg, alert.freq_once_per_bar)

// ═════════════════ Bar-close engine (state changes) ═════════════════
if barstate.isconfirmed
    // ----- 1) manage existing FVGs -----
    i = array.size(store) - 1
    while i >= 0
        f = array.get(store, i)
        kill = false

        // inversion: candle closes fully through the gap -> delete everything
        if f.bull and close < f.bot
            kill := true
        if (not f.bull) and close > f.top
            kill := true

        // age-out
        if not kill
            ageDays = (time - f.tCreated) / DAY
            if (not f.mitigated) and ageDays > expiryDays
                kill := true
            if f.mitigated and removeMitDays > 0 and ageDays > removeMitDays
                kill := true

        if kill
            box.delete(f.bx)
            line.delete(f.mid)
            for arw in f.arrows
                label.delete(arw)
            array.remove(store, i)
        else
            overlap  = low <= f.top and high >= f.bot
            firstTap = overlap and not f.mitigated
            reTap    = overlap and f.mitigated and reArmMin > 0 and f.outsideSince != 0 and (time - f.outsideSince) >= reArmMs

            // commit arrow for any tap event (alert already fired intrabar)
            if firstTap or reTap
                f.mitigated := true
                ay  = f.bull ? f.bot : f.top
                arw = label.new(bar_index, ay, "", yloc = yloc.price, style = (f.bull ? label.style_arrowup : label.style_arrowdown), color = (f.bull ? bullCol : bearCol), size = aSize)
                array.push(f.arrows, arw)

            // update outside-streak tracking based on this bar's overlap
            if overlap
                f.outsideSince := 0
            else
                if f.outsideSince == 0
                    f.outsideSince := time
                // else: keep the existing streak start time

            // keep extending the box / midline to the current bar
            box.set_right(f.bx, bar_index + 1)
            if showMid and not na(f.mid)
                line.set_x2(f.mid, bar_index + 1)

        i -= 1

    // ----- 2) detect a new FVG on the just-closed 3-candle pattern -----
    bullFVG = low > high[2]
    bearFVG = high < low[2]

    if bullFVG
        t = low          // c3 low  = top of gap
        b = high[2]      // c1 high = bottom of gap
        bx = box.new(bar_index - 1, t, bar_index + 1, b, border_color = color.new(bullCol, 50), bgcolor = color.new(bullCol, boxTransp))
        line ml = na
        if showMid
            ml := line.new(bar_index - 1, math.avg(t, b), bar_index + 1, math.avg(t, b), color = color.new(bullCol, 0), style = line.style_dashed)
        array.push(store, fvg.new(bx, ml, array.new<label>(), t, b, true, false, time, 0))

    if bearFVG
        t = low[2]       // c1 low  = top of gap
        b = high         // c3 high = bottom of gap
        bx = box.new(bar_index - 1, t, bar_index + 1, b, border_color = color.new(bearCol, 50), bgcolor = color.new(bearCol, boxTransp))
        line ml = na
        if showMid
            ml := line.new(bar_index - 1, math.avg(t, b), bar_index + 1, math.avg(t, b), color = color.new(bearCol, 0), style = line.style_dashed)
        array.push(store, fvg.new(bx, ml, array.new<label>(), t, b, false, false, time, 0))

// ───────────────────────── Timeframe warning ─────────────────────────
var label tfWarn = na
if warnTF and barstate.islast and timeframe.period != "15"
    label.delete(tfWarn)
    tfWarn := label.new(bar_index, high, "Apply on a 15-minute chart for 15m FVGs (current: " + timeframe.period + ")", style = label.style_label_down, color = color.orange, textcolor = color.white, size = size.small)
````
