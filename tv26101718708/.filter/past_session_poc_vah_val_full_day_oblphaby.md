# Past Session POC / VAH / VAL (Full Day)

- url: https://www.tradingview.com/script/OBlpHAby-Past-Session-POC-VAH-VAL-Full-Day/
- type: indicator
- pine_id: PUB;058c76fd594a49e6803c07e709fb7a10
- version: 1.0

## Description

Past Session POC / VAH / VAL (Full Day)

Plots the Point of Control, Value Area High and Value Area Low from up to 5 previous full trading sessions (for CME futures, the 18:00 ET open through the 17:00 ET close).

HOW IT WORKS
Instead of estimating volume from chart candles, the script pulls lower-timeframe data (1 minute by default) and distributes each intrabar's volume across the price levels it actually traded through. This builds a full volume-at-price profile for each session, so the levels closely match TradingView's built-in Session Volume Profile when the row settings are the same.

- POC: the price row with the highest traded volume
- Value Area: expands outward from the POC, comparing the next two rows above and below and adding the larger side, until the chosen % of session volume (default 70%) is covered
- VAH / VAL: the top and bottom of that value area

SETTINGS
Profile: set Rows Layout, Row Size and Value Area % to match your Session Volume Profile. "Ticks Per Row" is recommended for precise levels (e.g. 4 ticks = 1 point on NQ).
Sessions: show or hide the POC, VAH and VAL for each of the last 5 sessions individually, each with its own colour.
Display: line widths and styles, how far lines extend past the current bar, and label position and size.

NOTES
- Intrabar Timeframe must be equal to or lower than the chart timeframe.
- Levels are calculated once each session closes, so they do not repaint.
- Built from intrabar candle data, not tick data, so on sessions where two rows are nearly tied the POC can occasionally differ by one row from the built-in profile.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Past Session POC / VAH / VAL (Full Day)", shorttitle = "Prev POC/VA", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
grpP       = "Profile — set these the SAME as TV's Session Volume Profile"
rowsLayout = input.string("Ticks Per Row", "Rows Layout", options = ["Number of Rows", "Ticks Per Row"], group = grpP)
rowSizeIn  = input.int(4, "Row Size", minval = 1, group = grpP, tooltip = "Ticks Per Row: ticks in each row (NQ: 4 ticks = 1 point).\nNumber of Rows: how many rows the session range is split into (TV default is 24).")
vaPct      = input.int(70, "Value Area Volume %", minval = 1, maxval = 100, group = grpP)
ltf        = input.timeframe("1", "Intrabar Timeframe", group = grpP, tooltip = "Lower timeframe used to place volume at price. Must be ≤ chart timeframe.")

grpS = "Sessions — pick which levels to show for each day"
d1C   = input.color(color.red,    "-1d", inline = "d1", group = grpS)
d1Poc = input.bool(true,  "POC", inline = "d1", group = grpS)
d1Vah = input.bool(true,  "VAH", inline = "d1", group = grpS)
d1Val = input.bool(true,  "VAL", inline = "d1", group = grpS)
d2C   = input.color(color.orange, "-2d", inline = "d2", group = grpS)
d2Poc = input.bool(true,  "POC", inline = "d2", group = grpS)
d2Vah = input.bool(true,  "VAH", inline = "d2", group = grpS)
d2Val = input.bool(true,  "VAL", inline = "d2", group = grpS)
d3C   = input.color(color.yellow, "-3d", inline = "d3", group = grpS)
d3Poc = input.bool(true,  "POC", inline = "d3", group = grpS)
d3Vah = input.bool(true,  "VAH", inline = "d3", group = grpS)
d3Val = input.bool(true,  "VAL", inline = "d3", group = grpS)
d4C   = input.color(color.teal,   "-4d", inline = "d4", group = grpS)
d4Poc = input.bool(false, "POC", inline = "d4", group = grpS)
d4Vah = input.bool(false, "VAH", inline = "d4", group = grpS)
d4Val = input.bool(false, "VAL", inline = "d4", group = grpS)
d5C   = input.color(color.purple, "-5d", inline = "d5", group = grpS)
d5Poc = input.bool(false, "POC", inline = "d5", group = grpS)
d5Vah = input.bool(false, "VAH", inline = "d5", group = grpS)
d5Val = input.bool(false, "VAL", inline = "d5", group = grpS)

grpD    = "Display"
pocW    = input.int(2, "POC width", minval = 1, maxval = 5, inline = "pw", group = grpD)
pocSt   = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "pw", group = grpD)
vaW     = input.int(1, "VAH/VAL width", minval = 1, maxval = 5, inline = "vw", group = grpD)
vaSt    = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "vw", group = grpD)
extBars = input.int(15, "Extend lines past last bar (bars)", minval = 1, maxval = 500, group = grpD)
showLbl = input.bool(true, "Show labels", group = grpD)
lblPos  = input.string("Right of line", "Label position", options = ["Right of line", "Above line"], group = grpD)
lblSize = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpD)

if not timeframe.isintraday
    runtime.error("Use an intraday chart timeframe (e.g. 1m, 5m, 15m).")
if timeframe.in_seconds() < timeframe.in_seconds(ltf)
    runtime.error("Intrabar Timeframe must be lower than or equal to the chart timeframe.")

const int MAX_DAYS = 5

styleOf(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
sizeOf(s)  => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

// ─────────────────────────────────────────────────────────────
// Intrabar data
// ─────────────────────────────────────────────────────────────
[ltfH, ltfL, ltfV] = request.security_lower_tf(syminfo.tickerid, ltf, [high, low, nz(volume)])

// ─────────────────────────────────────────────────────────────
// Profile → POC, VAH, VAL for one completed session
// ─────────────────────────────────────────────────────────────
calcProfile(array<float> hs, array<float> ls, array<float> vs, string layout, int rowIn, int vaP) =>
    float poc = na
    float vah = na
    float val = na
    int   n   = hs.size()
    if n > 0
        float lo   = ls.min()
        float hi   = hs.max()
        float tk   = syminfo.mintick
        array<float> rows = array.new<float>()

        if layout == "Ticks Per Row"
            int levels = int(math.round((hi - lo) / tk)) + 1
            int nRows  = int(math.floor((levels - 1) / rowIn)) + 1
            rows := array.new<float>(nRows, 0.0)
            for i = 0 to n - 1
                int   jl     = int(math.round((ls.get(i) - lo) / tk))
                int   jh     = int(math.round((hs.get(i) - lo) / tk))
                float perLvl = vs.get(i) / (jh - jl + 1)
                for r = int(math.floor(jl / rowIn)) to int(math.floor(jh / rowIn))
                    int a = math.max(jl, r * rowIn)
                    int b = math.min(jh, r * rowIn + rowIn - 1)
                    rows.set(r, rows.get(r) + perLvl * (b - a + 1))
        else
            float rs = (hi - lo) / rowIn
            rows := array.new<float>(rowIn, 0.0)
            for i = 0 to n - 1
                float l = ls.get(i)
                float h = hs.get(i)
                float v = vs.get(i)
                if rs <= 0
                    rows.set(0, rows.get(0) + v)
                else
                    int rl = math.min(int(math.floor((l - lo) / rs)), rowIn - 1)
                    int rh = math.min(int(math.floor((h - lo) / rs)), rowIn - 1)
                    if h == l
                        rows.set(rl, rows.get(rl) + v)
                    else
                        for r = rl to rh
                            float bot = lo + r * rs
                            float top = bot + rs
                            float ov  = math.min(h, top) - math.max(l, bot)
                            if ov > 0
                                rows.set(r, rows.get(r) + v * ov / (h - l))

        int nR = rows.size()

        // POC row (first one wins on a tie)
        int   bi   = 0
        float maxV = -1.0
        for r = 0 to nR - 1
            float rv = rows.get(r)
            if rv > maxV
                maxV := rv
                bi   := r

        // Value Area: expand from POC, comparing the next two rows above vs the next two below
        float target = rows.sum() * vaP / 100.0
        float acc    = rows.get(bi)
        int   up     = bi
        int   dn     = bi
        while acc < target and (up < nR - 1 or dn > 0)
            float upV = 0.0
            if up + 1 < nR
                upV += rows.get(up + 1)
            if up + 2 < nR
                upV += rows.get(up + 2)
            float dnV = 0.0
            if dn - 1 >= 0
                dnV += rows.get(dn - 1)
            if dn - 2 >= 0
                dnV += rows.get(dn - 2)
            if up < nR - 1 and (dn <= 0 or upV >= dnV)
                up  := math.min(up + 2, nR - 1)
                acc += upV
            else
                dn  := math.max(dn - 2, 0)
                acc += dnV

        if layout == "Ticks Per Row"
            poc := lo + (bi * rowIn + (rowIn - 1) / 2.0) * tk
            vah := math.min(hi, lo + (up * rowIn + rowIn - 1) * tk)
            val := lo + dn * rowIn * tk
        else
            float rs2 = (hi - lo) / rowIn
            poc := lo + (bi + 0.5) * rs2
            vah := lo + (up + 1) * rs2
            val := lo + dn * rs2
    [poc, vah, val]

// ─────────────────────────────────────────────────────────────
// Drawing helper
// ─────────────────────────────────────────────────────────────
drawLevel(array<line> L, array<label> B, int t, float y, color c, string st, int w, string txt) =>
    if not na(y)
        L.push(line.new(t, y, time, y, xloc.bar_time, extend.none, c, styleOf(st), w))
        if showLbl
            string ls = lblPos == "Above line" ? label.style_label_lower_right : label.style_label_left
            B.push(label.new(time, y, txt, xloc.bar_time, yloc.price, color(na), ls, c, sizeOf(lblSize)))

// ─────────────────────────────────────────────────────────────
// Session tracking (CME daily session: 18:00 ET open → 17:00 ET close)
// ─────────────────────────────────────────────────────────────
var array<color> dCol = array.from(d1C, d2C, d3C, d4C, d5C)
var array<bool>  dPoc = array.from(d1Poc, d2Poc, d3Poc, d4Poc, d5Poc)
var array<bool>  dVah = array.from(d1Vah, d2Vah, d3Vah, d4Vah, d5Vah)
var array<bool>  dVal = array.from(d1Val, d2Val, d3Val, d4Val, d5Val)

var array<float> sH = array.new<float>()
var array<float> sL = array.new<float>()
var array<float> sV = array.new<float>()
var int sStart = na

var array<float> pocs  = array.new<float>()
var array<float> vahs  = array.new<float>()
var array<float> vals  = array.new<float>()
var array<int>   times = array.new<int>()
var array<line>  lns   = array.new<line>()
var array<label> lbls  = array.new<label>()

newSess = timeframe.change("1D")

if newSess
    // Finalize the session that just ended (skip the partial first one on the chart)
    if not na(sStart) and sV.size() > 0 and sV.sum() > 0
        [p, h, l] = calcProfile(sH, sL, sV, rowsLayout, rowSizeIn, vaPct)
        pocs.unshift(p)
        vahs.unshift(h)
        vals.unshift(l)
        times.unshift(sStart)
        while pocs.size() > MAX_DAYS
            pocs.pop()
            vahs.pop()
            vals.pop()
            times.pop()

        // Redraw
        for ln in lns
            ln.delete()
        for lb in lbls
            lb.delete()
        lns.clear()
        lbls.clear()
        for i = 0 to pocs.size() - 1
            color  c   = dCol.get(i)
            int    t   = times.get(i)
            string tag = "-" + str.tostring(i + 1) + "d "
            if dPoc.get(i)
                drawLevel(lns, lbls, t, pocs.get(i), c, pocSt, pocW, tag + "POC")
            if dVah.get(i)
                drawLevel(lns, lbls, t, vahs.get(i), c, vaSt, vaW, tag + "VAH")
            if dVal.get(i)
                drawLevel(lns, lbls, t, vals.get(i), c, vaSt, vaW, tag + "VAL")

    sH.clear()
    sL.clear()
    sV.clear()
    sStart := time

// Add this bar's intrabars to the running session
if ltfH.size() > 0
    sH.concat(ltfH)
    sL.concat(ltfL)
    sV.concat(ltfV)

// End lines a few bars into the future and pin labels at the line ends
if barstate.islast
    int endT = time + extBars * timeframe.in_seconds() * 1000
    for ln in lns
        ln.set_x2(endT)
    for lb in lbls
        lb.set_x(endT)
````
