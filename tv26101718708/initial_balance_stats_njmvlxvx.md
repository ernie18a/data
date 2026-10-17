# Initial Balance Stats

- url: https://www.tradingview.com/script/njmVlxVx-Initial-Balance-Stats/
- type: indicator
- pine_id: PUB;2fde2b3ae75f4ca1a073139284104fda
- version: 1.0

## Description

Initial Balance Stats

WHAT IT DOES
This indicator draws the Initial Balance (IB) of each session with its extension levels, and adds a statistics table that shows how price has historically behaved around the IB on this instrument: how often it breaks each side, how far it extends, and where the session closes.

DEFINITIONS
- Initial Balance: the high and low of the first part of the session. Default: the first 60 minutes of the New York cash session (09:30 to 10:30 New York time).
- Extensions: levels beyond the IB high and low, measured as a multiple of the IB range. Defaults are 0.5x, 1x, 1.5x and 2x. Note: a 0.5x extension here is what is often called a "1.5x IB" day.

ON THE CHART
- The IB window is shaded, and the IB high and low are extended to the end of the session, with the IB midpoint as a dashed line.
- Upside extensions are drawn above the IB high, downside extensions below the IB low.
- Only the most recent sessions are drawn (5 by default) to keep the chart clean.

STATISTICS TABLE
Calculated over the last completed sessions (100 by default). The current session is only added once it is complete.
- Broke IB high / Broke IB low / Broke both sides / Stayed inside IB
- Reached each extension (on either side)
- Session close above, inside or below the IB
- Current or last session: IB range compared with the average, classified as Narrow, Normal or Wide
- Conditional stat: how often past sessions with a similar IB size (Narrow, Normal or Wide) reached the second extension (1x by default)
- How far the current or last session has extended so far, up and down

ALERTS
- IB high broken: first break above the IB high in a session
- IB low broken: first break below the IB low in a session

SETTINGS
- Session, timezone and IB length (15, 30, 60 or 90 minutes)
- The four extension multiples
- Number of sessions to draw, lookback for statistics, Narrow / Wide thresholds, table position

REQUIREMENTS
- Use an intraday chart whose bars line up with the session start. For a 09:30 start, use 30m, 15m, 5m or lower. Timeframes that cannot open a bar at the session start (for example 1H) show an error instead of producing shifted levels.
- Sessions whose first bar does not open at the session start (for example because of a data gap) are skipped and counted in the table.

LIMITATIONS
- The number of sessions in the statistics depends on how much history the chart loads. Higher timeframes (15m or 30m) give a larger sample. The table shows how many sessions were actually used.
- Extensions are measured from the highs and lows made after the IB period, within the same session.
- Holidays and shortened sessions are included as they are.
- Statistics describe past behavior on the chosen instrument and session. They are not a forecast and do not guarantee future results.

This script is for chart analysis and education only. It is not a trading signal and does not provide financial advice.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YOUR_TRADINGVIEW_USERNAME

//@version=6
indicator("Initial Balance Stats", shorttitle = "IB Stats", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, behind_chart = false)

// ── Inputs ──────────────────────────────────────────────
const string G_S = "Session"
const string G_L = "Levels"
const string G_T = "Statistics"

sess     = input.session("0930-1600", "RTH session", group = G_S)
tz       = input.string("America/New_York", "Timezone", group = G_S)
ibMin    = input.int(60, "IB length (minutes)", options = [15, 30, 60, 90], group = G_S)

e1       = input.float(0.5, "Extension 1 (x IB range)", minval = 0.1, step = 0.25, group = G_L,
           tooltip = "Extensions are measured beyond the IB high / low as a multiple of the IB range. 0.5 here equals what is often called a 1.5x IB day.")
e2       = input.float(1.0, "Extension 2 (x IB range)", minval = 0.1, step = 0.25, group = G_L)
e3       = input.float(1.5, "Extension 3 (x IB range)", minval = 0.1, step = 0.25, group = G_L)
e4       = input.float(2.0, "Extension 4 (x IB range)", minval = 0.1, step = 0.25, group = G_L)
keepDays = input.int(5, "Draw levels for last N sessions", minval = 1, maxval = 40, group = G_L)
showLbl  = input.bool(true, "Show level labels", group = G_L)
ibCol    = input.color(color.new(#D89B2B, 0), "IB high / low", group = G_L)
ibFill   = input.color(color.new(#D89B2B, 90), "IB fill", group = G_L)
upCol    = input.color(color.new(#089981, 0), "Upside extensions", group = G_L)
dnCol    = input.color(color.new(#F23645, 0), "Downside extensions", group = G_L)

lookback = input.int(100, "Lookback (sessions)", minval = 10, maxval = 500, group = G_T)
showTbl  = input.bool(true, "Show statistics table", group = G_T)
tblPos   = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_T)
narrowTh = input.float(0.8, "Narrow IB: below x average", minval = 0.1, step = 0.05, group = G_T)
wideTh   = input.float(1.25, "Wide IB: above x average", minval = 1.0, step = 0.05, group = G_T)

// ── Validation ─────────────────────────────────────────
if not timeframe.isintraday or timeframe.in_seconds() > ibMin * 60
    runtime.error("Use an intraday chart with a timeframe of " + str.tostring(ibMin) + " minutes or lower.")

exts = array.from(e1, e2, e3, e4)

// ── Session detection ──────────────────────────────────
inSess    = not na(time(timeframe.period, sess, tz))
dayKey    = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
sessStart = inSess and (not inSess[1] or dayKey != dayKey[1])

// Session start as minutes of day (e.g. "0930-1600" -> 570)
startMin = int(str.tonumber(str.substring(sess, 0, 2))) * 60 + int(str.tonumber(str.substring(sess, 2, 4)))
barMin   = hour(time, tz) * 60 + minute(time, tz)

// ── Drawings per session ───────────────────────────────
type DayDraw
    box          ib
    line         mid
    array<line>  lns
    array<label> lbs

var array<DayDraw> draws = array.new<DayDraw>()

// ── State ──────────────────────────────────────────────
var float ibH        = na
var float ibL        = na
var float postH      = na
var float postL      = na
var float sClose     = na
var int   ibEnd      = na
var int   ibStartBar = na
var bool  ibDone     = false
var bool  active     = false
var bool  brokeUp    = false
var bool  brokeDn    = false

// Completed-session history
var array<float> aRange = array.new<float>()
var array<float> aRel   = array.new<float>()
var array<float> aUp    = array.new<float>()
var array<float> aDn    = array.new<float>()
var array<int>   aClose = array.new<int>()

bool upEvt = false
bool dnEvt = false

// ── New session: store yesterday, reset ────────────────
// The chart timeframe must divide into the session start, otherwise the IB is shifted (e.g. 1H bars vs a 09:30 start)
if (startMin * 60) % timeframe.in_seconds() != 0
    runtime.error("This timeframe cannot start a bar at " + str.substring(sess, 0, 4) + ". Use 30m, 15m, 5m or lower.")

// Sessions whose first bar is not at the session start (data gaps) are skipped and counted
var int skipped = 0
if sessStart and bar_index > 0 and barMin != startMin
    skipped += 1

if sessStart
    if active and ibDone and ibH > ibL
        R       = ibH - ibL
        up      = na(postH) ? 0.0 : math.max(0.0, (postH - ibH) / R)
        dn      = na(postL) ? 0.0 : math.max(0.0, (ibL - postL) / R)
        avgPrev = aRange.size() > 0 ? aRange.avg() : R
        aRange.push(R)
        aRel.push(R / avgPrev)
        aUp.push(up)
        aDn.push(dn)
        aClose.push(sClose > ibH ? 1 : sClose < ibL ? -1 : 0)
        if aRange.size() > lookback
            aRange.shift()
            aRel.shift()
            aUp.shift()
            aDn.shift()
            aClose.shift()

    active     := barMin == startMin  // skip a partial first session
    ibH        := high
    ibL        := low
    postH      := na
    postL      := na
    sClose     := close
    ibEnd      := time + ibMin * 60 * 1000
    ibStartBar := bar_index
    ibDone     := false
    brokeUp    := false
    brokeDn    := false

    bx = box.new(bar_index, high, bar_index + 1, low, border_color = ibCol, bgcolor = ibFill)
    draws.push(DayDraw.new(bx, na, array.new<line>(), array.new<label>()))
    while draws.size() > keepDays
        d = draws.shift()
        d.ib.delete()
        if not na(d.mid)
            d.mid.delete()
        for l in d.lns
            l.delete()
        for lb in d.lbs
            lb.delete()

// ── Inside the session ─────────────────────────────────
else if inSess and active
    sClose := close
    d = draws.last()

    if not ibDone
        if time < ibEnd
            // Still building the IB
            ibH := math.max(ibH, high)
            ibL := math.min(ibL, low)
            d.ib.set_top(ibH)
            d.ib.set_bottom(ibL)
            d.ib.set_right(bar_index + 1)
        else
            // IB complete: draw levels
            ibDone := true
            postH  := high
            postL  := low
            R   = ibH - ibL
            mid = (ibH + ibL) / 2
            d.lns.push(line.new(ibStartBar, ibH, bar_index + 1, ibH, color = ibCol, width = 2))
            d.lns.push(line.new(ibStartBar, ibL, bar_index + 1, ibL, color = ibCol, width = 2))
            d.mid := line.new(ibStartBar, mid, bar_index + 1, mid, color = color.new(ibCol, 40), style = line.style_dashed)
            if showLbl
                d.lbs.push(label.new(bar_index + 1, ibH, "IBH", style = label.style_label_left, color = color.new(color.black, 100), textcolor = ibCol, size = size.small))
                d.lbs.push(label.new(bar_index + 1, ibL, "IBL", style = label.style_label_left, color = color.new(color.black, 100), textcolor = ibCol, size = size.small))
            for e in exts
                pu = ibH + e * R
                pd = ibL - e * R
                d.lns.push(line.new(ibStartBar, pu, bar_index + 1, pu, color = color.new(upCol, 30), style = line.style_dotted))
                d.lns.push(line.new(ibStartBar, pd, bar_index + 1, pd, color = color.new(dnCol, 30), style = line.style_dotted))
                if showLbl
                    d.lbs.push(label.new(bar_index + 1, pu, "+" + str.tostring(e) + "x", style = label.style_label_left, color = color.new(color.black, 100), textcolor = upCol, size = size.small))
                    d.lbs.push(label.new(bar_index + 1, pd, "-" + str.tostring(e) + "x", style = label.style_label_left, color = color.new(color.black, 100), textcolor = dnCol, size = size.small))
    else
        postH := math.max(postH, high)
        postL := math.min(postL, low)

    // Extend today's drawings to the current bar
    if ibDone
        if not na(d.mid)
            d.mid.set_x2(bar_index + 1)
        for l in d.lns
            l.set_x2(bar_index + 1)
        for lb in d.lbs
            lb.set_x(bar_index + 1)

        // First break of each side today (for alerts)
        if not brokeUp and high > ibH
            brokeUp := true
            upEvt   := true
        if not brokeDn and low < ibL
            brokeDn := true
            dnEvt   := true

// ── Alerts ─────────────────────────────────────────────
alertcondition(upEvt, "IB high broken", "{{ticker}}: first break above the Initial Balance high")
alertcondition(dnEvt, "IB low broken",  "{{ticker}}: first break below the Initial Balance low")

// ── Statistics table ───────────────────────────────────
f_pct(int c, int n) =>
    n > 0 ? str.tostring(math.round(c * 100.0 / n)) + "%" : "-"

f_row(table t, int r, string a, string b, color bc) =>
    table.cell(t, 0, r, a, text_color = color.new(#D1D4DC, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, r, b, text_color = bc, text_size = size.small, text_halign = text.align_right)

if showTbl and barstate.islast
    pos = tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : position.top_right
    var table t = table.new(pos, 2, 18, bgcolor = color.new(#131722, 10), border_width = 1, border_color = color.new(#2A2E39, 0))
    n = aRange.size()

    int cH     = 0
    int cL     = 0
    int cBoth  = 0
    int cNone  = 0
    int cAbove = 0
    int cIn    = 0
    int cBelow = 0
    extHits = array.new<int>(4, 0)
    for i = 0 to math.max(n - 1, 0)
        if n > 0
            u = aUp.get(i)
            w = aDn.get(i)
            cH    += u > 0 ? 1 : 0
            cL    += w > 0 ? 1 : 0
            cBoth += u > 0 and w > 0 ? 1 : 0
            cNone += u == 0 and w == 0 ? 1 : 0
            for j = 0 to 3
                if math.max(u, w) >= exts.get(j)
                    extHits.set(j, extHits.get(j) + 1)
            c = aClose.get(i)
            cAbove += c == 1 ? 1 : 0
            cIn    += c == 0 ? 1 : 0
            cBelow += c == -1 ? 1 : 0

    white = color.new(#D1D4DC, 0)
    r = 0
    table.cell(t, 0, r, "IB Stats (" + str.tostring(ibMin) + "m)", text_color = ibCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, r, str.tostring(n) + " sessions", text_color = color.gray, text_size = size.small, text_halign = text.align_right)
    r += 1
    avgR = n > 0 ? aRange.avg() : na
    f_row(t, r, "Avg IB range", na(avgR) ? "-" : str.tostring(avgR, format.mintick), white)
    r += 1
    f_row(t, r, "Broke IB high", f_pct(cH, n), upCol)
    r += 1
    f_row(t, r, "Broke IB low", f_pct(cL, n), dnCol)
    r += 1
    f_row(t, r, "Broke both sides", f_pct(cBoth, n), white)
    r += 1
    f_row(t, r, "Stayed inside IB", f_pct(cNone, n), white)
    r += 1
    for j = 0 to 3
        f_row(t, r, "Reached " + str.tostring(exts.get(j)) + "x (either side)", f_pct(extHits.get(j), n), white)
        r += 1
    f_row(t, r, "Close above / inside / below", f_pct(cAbove, n) + " / " + f_pct(cIn, n) + " / " + f_pct(cBelow, n), white)
    r += 1

    // Today
    if ibDone and ibH > ibL and not na(avgR)
        R     = ibH - ibL
        rel   = R / avgR
        isNar = rel < narrowTh
        isWid = rel > wideTh
        bucket = isNar ? "Narrow" : isWid ? "Wide" : "Normal"
        int m = 0
        int mHit = 0
        for i = 0 to math.max(n - 1, 0)
            if n > 0
                rr = aRel.get(i)
                same = isNar ? rr < narrowTh : isWid ? rr > wideTh : rr >= narrowTh and rr <= wideTh
                if same
                    m += 1
                    mHit += math.max(aUp.get(i), aDn.get(i)) >= exts.get(1) ? 1 : 0
        upNow = na(postH) ? 0.0 : math.max(0.0, (postH - ibH) / R)
        dnNow = na(postL) ? 0.0 : math.max(0.0, (ibL - postL) / R)
        pre = inSess ? "Today" : "Last session"
        f_row(t, r, pre + " IB range", str.tostring(R, format.mintick) + " (" + str.tostring(rel, "#.##") + "x avg, " + bucket + ")", ibCol)
        r += 1
        f_row(t, r, bucket + " IB days reaching " + str.tostring(exts.get(1)) + "x", f_pct(mHit, m) + " of " + str.tostring(m), ibCol)
        r += 1
        f_row(t, r, pre + " extension up / down", str.tostring(upNow, "#.##") + "x / " + str.tostring(dnNow, "#.##") + "x", white)
        r += 1
    else
        f_row(t, r, "Today", inSess ? "IB forming..." : "Waiting for session", color.gray)
        r += 1
    if skipped > 0
        f_row(t, r, "Skipped (misaligned start)", str.tostring(skipped), color.gray)
        r += 1
````
