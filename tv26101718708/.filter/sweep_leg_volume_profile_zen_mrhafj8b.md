# Sweep Leg Volume Profile [Zen]

- url: https://www.tradingview.com/script/MrhAFj8b-Sweep-Leg-Volume-Profile-Zen/
- type: indicator
- pine_id: PUB;a44c433c083f44d1969e54be40fb24de
- version: 1.0

## Description

Sweep Leg Volume Profile [Zen] draws a volume profile for swing legs that started with a liquidity sweep, then tracks each leg's point of control (POC) and value area (VA) after the leg ends: UNTESTED, TESTED or BROKEN.

Settings you can change are listed under INPUTS with their defaults. ATR(14), the 100-candle volume average, the 1,500-candle history window and the Auto lower-timeframe map are fixed.

WHAT IS ORIGINAL
Swings, volume profiles and ATR are standard tools. This script combines them under one rule set:
- Only legs that started with a sweep are profiled: the swing where the leg starts took out the previous swing of the same type with its wick, and that candle or the next one closed back.
- Only legs of at least 3 x ATR(14) are kept, so small swings do not crowd the chart.
- Each profile is built from lower-timeframe candles inside the leg whenever that data is available, not from the chart candles.
- Each leg's POC and value area get a status that updates on every closed candle, with alerts.
- The developing leg is shown too. If price runs past the last swing, the previous leg is shown as still extending instead of a new leg being started.
Instead of profiling every swing, the script shows only the legs that began with a sweep of a prior swing, where volume traded inside them, and whether price has come back to those levels.

WHAT IT SHOWS
- Swings: pivot highs and lows with 5 candles on each side. A leg runs from one swing to the next opposite swing. If a higher high (up leg) or a lower low (down leg) is confirmed before the opposite swing, the leg is extended and its profile is rebuilt.
- Sweep filter: for an up leg, the starting swing low went below the previous swing low, and the same or the next candle closed above that previous low. Down legs mirror this.
- Size filter: leg range (highest high to lowest low of the leg) divided by ATR(14) on the leg's last candle must be at least 3.
- Profile: up to 24 grey rows across the leg range (rows with no volume are not drawn), drawn from the leg's first candle. The longest row is about half the leg's length (at least 5 candles, never longer than the leg). The POC row is the darkest, value area rows are medium, the rest are light.
- Levels, drawn from the leg's last candle to the right:
  UNTESTED: POC is a solid line, VAH and VAL are dashed lines; blue for up legs, orange for down legs. A small "POC price" label sits at the right edge ("POC live price" for the developing leg).
  TESTED: the three lines turn grey and dotted, and the label is removed.
  BROKEN: grey and dotted, and the lines stop at the candle that broke the leg.
- On the chart: the 2 most recent completed legs that pass the filters (1 to 3 in Inputs) and the developing leg.

HOW THE PROFILE IS CALCULATED
- Data: lower-timeframe candles from request.security_lower_tf. Auto: a chart up to 15m uses 1m, up to 1H uses 5m, up to 4H uses 15m, up to 1D uses 60m, higher uses 240m. A manual choice of 1, 3, 5, 15, 30 or 60 minutes is possible; a choice above the chart timeframe falls back to Auto.
- The volume of each lower-timeframe candle is split equally across the rows its high-low range covers.
- If a chart candle has no lower-timeframe data, the chart candle itself is used. The table counts these candles as "chart-bar fallback".
- POC: the row with the most volume (the lower row if two are equal). Its price is the middle of the row.
- Value area: at least 70% of the leg's volume, grown row by row from the POC toward the neighbouring row with more volume. VAH and VAL are the outer edges of the value area.

STATUS
Checked on closed candles after the leg's last candle, including candles before the leg appeared on the chart:
- UNTESTED: no candle has traded at the POC since the leg ended.
- TESTED: a candle's high-low range included the POC.
- BROKEN: a candle closed beyond the far edge of the value area: below VAL for an up leg, above VAH for a down leg. A leg can go from UNTESTED straight to BROKEN. BROKEN is final.

DEVELOPING LEG
- Runs from the last confirmed swing to the furthest price reached since then in the opposite direction: from a swing high down to the lowest low, or from a swing low up to the highest high.
- If price has already moved past that swing (for example, a higher high after the last swing high), the previous leg is still extending: the developing leg is that leg up to the new extreme, and its older completed version is hidden. It comes back if the extension is not confirmed.
- It passes the same sweep and size filters, so it is not always shown.
- It is updated on closed candles and keeps changing until the next swing is confirmed.

TABLE
- One row per leg: the developing leg first, then completed legs, newest first. The hidden older version of an extending leg is not listed.
- Leg: up or down arrow and the open time (UTC) of the leg's last candle, or "live" for the developing leg.
- Size ATR: leg range / ATR(14) on the leg's last candle.
- Vol: the leg's average volume per chart candle (from the profile) / the 100-candle average volume on the leg's last candle.
- POC: price of the POC.
- Dist: distance from the current price to the POC in percent; positive means the POC is above the price.
- Status: UNTESTED, TESTED or BROKEN.
- Bottom row: the lower timeframe in use and the number of chart-bar fallback candles in the legs shown.

ALERTS
All alerts fire at candle close.
- "Any alert() function call": one message per candle that lists its events for the legs on the chart: the first touch of a POC, or a broken leg with its VAL or VAH price. Events of the developing leg are marked "live".
- Two alert conditions with fixed text: "First touch of a POC" and "Leg broken".
- Touches or breaks that happened before a leg appeared on the chart update its status but send no alert. A hidden older version of an extending leg sends no alerts.

HOW TO USE
- Use a symbol with volume data.
- Look at a recent sweep leg: where most of its volume traded (POC) and its value area.
- An UNTESTED POC is a level price has not returned to since the leg ended. TESTED and BROKEN show what happened when price came back.
- It is context for your own analysis, not an entry signal.

INPUTS (defaults)
- Completed legs on chart: 2 (1 to 3)
- Show developing leg: on
- Min leg size (x ATR): 3.0 (0 turns the size filter off)
- Only legs that start with a sweep: on
- Swing length (bars each side): 5
- Profile rows: 24
- Value area %: 70
- Lower timeframe: Auto
- Max leg length (bars): 400
- Show table: on
- Table position: top right

REALTIME BEHAVIOUR AND LIMITS
- A swing is confirmed 5 candles after it forms, so a completed leg appears 5 candles after its last candle. When a leg is extended, its previous version is replaced.
- The developing leg changes until the next swing is confirmed. After a chart reload it is rebuilt from history.
- Profiles are built only for legs that start within the last 1,500 candles (counted from the latest candle when the chart loads) and are no longer than Max leg length.
- TradingView limits how much lower-timeframe history a script receives (the limit depends on the plan), so older legs may use chart-bar fallback or may not be profiled. A finer manual lower timeframe shortens the history further.
- After a chart reload the lower-timeframe volume can differ slightly from what was received live, so the POC and the value area edges can shift slightly.
- Symbols without volume data cannot be profiled. Chart timeframes below 1 minute are not supported (the script shows an error).
- Built for standard candles. Heikin Ashi, Renko and other synthetic charts change the prices the script reads.
- Colours follow the chart theme (light or dark) automatically.

Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
//@version=6
indicator("Sweep Leg Volume Profile [Zen]", shorttitle = "SLVP", overlay = true, max_boxes_count = 500, max_lines_count = 100, max_labels_count = 50, max_bars_back = 1100)

// Sweep Leg Volume Profile [Zen]
// Swing legs that start with a liquidity sweep and span at least N x ATR: volume profile from lower-timeframe candles,
// POC / VAH / VAL with UNTESTED / TESTED / BROKEN status, developing (live) leg, alerts, table.

// ---------- inputs ----------
gL = "Legs"
nShow    = input.int(2, "Completed legs on chart", minval = 1, maxval = 3, group = gL, display = display.none)
showLive = input.bool(true, "Show developing leg", group = gL, display = display.none, tooltip = "The leg from the last confirmed swing to the latest extreme. It keeps changing until the next swing is confirmed.")
minAtr   = input.float(3.0, "Min leg size (x ATR)", minval = 0.0, step = 0.5, group = gL, display = display.none, tooltip = "Leg range divided by ATR(14) at the leg end. Set to 0 to turn the size filter off.")
onlySw   = input.bool(true, "Only legs that start with a sweep", group = gL, display = display.none, tooltip = "The starting swing took out the previous swing of the same type with its wick, and that bar or the next one closed back.")
pivLen   = input.int(5, "Swing length (bars each side)", minval = 2, maxval = 50, group = gL, display = display.none, tooltip = "A swing is confirmed this many bars after it forms.")
gP = "Profile"
rows     = input.int(24, "Profile rows", minval = 8, maxval = 60, group = gP, display = display.none)
vaPct    = input.float(70.0, "Value area %", minval = 50.0, maxval = 95.0, step = 5.0, group = gP, display = display.none)
ltfMode  = input.string("Auto", "Lower timeframe", options = ["Auto", "1", "3", "5", "15", "30", "60"], group = gP, display = display.none, tooltip = "Candles used to build the profiles. Auto: chart up to 15m uses 1m, up to 1H uses 5m, up to 4H uses 15m, up to 1D uses 60m, higher uses 240m. A finer timeframe shortens the history that can be profiled.")
maxLeg   = input.int(400, "Max leg length (bars)", minval = 20, maxval = 1000, group = gP, display = display.none)
showTbl  = input.bool(true, "Show table", group = "Display", display = display.none)
tblPosIn = input.string("Top right", "Table position", options = ["Top right", "Bottom right", "Bottom left", "Top left"], group = "Display", display = display.none)

// ---------- colours (ChartZenFX, auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cINK    = isLight ? #1F2937 : #D1D4DC
color cNEU    = isLight ? #647482 : #8C9098
color cMUTED  = isLight ? #505C69 : #9AA3B2
color cPANEL  = isLight ? #F4F5F7 : #1E222D
color cHEAD   = #2A2E39
color cHEADTX = isLight ? #FFFFFF : #D1D4DC
color cBORDER = isLight ? #C4C8CE : #363A45
color cHI     = isLight ? #AD4A12 : #D9703A
color cLO     = isLight ? #1B46B4 : #6F88EE

// ---------- lower timeframe ----------
int WIN = 1500
int tfSec = timeframe.in_seconds()
if tfSec < 60
    runtime.error("Use a chart timeframe of 1 minute or higher.")
string ltfAuto = tfSec <= 900 ? "1" : tfSec <= 3600 ? "5" : tfSec <= 14400 ? "15" : tfSec <= 86400 ? "60" : "240"
string ltf = ltfMode == "Auto" ? ltfAuto : ltfMode
string ltfUse = timeframe.in_seconds(ltf) <= tfSec ? ltf : ltfAuto

[aH, aL, aC, aO, aV] = request.security_lower_tf(syminfo.tickerid, ltfUse, [high, low, close, open, volume])

// keep only as many chart bars as fit into the 90 000-element storage
int perBar   = math.max(1, int(math.ceil(float(tfSec) / timeframe.in_seconds(ltfUse))))
int keepBars = math.min(WIN + maxLeg + pivLen, int(89000.0 / perBar))

// ---------- store lower-timeframe candles (recent window only) ----------
var array<float> sH = array.new<float>()
var array<float> sL = array.new<float>()
var array<float> sV = array.new<float>()
var array<bool>  sB = array.new<bool>()
var array<bool>  sF = array.new<bool>()
var array<int>   sI = array.new<int>()

if barstate.isconfirmed and bar_index >= last_bar_index - keepBars
    int n = array.size(aV)
    int add = math.max(n, 1)
    // safety net: drop whole chart bars, so the first stored bar is always complete
    while array.size(sI) > 0 and array.size(sI) + add > 90000
        int dropBar = array.get(sI, 0)
        while array.size(sI) > 0 and array.get(sI, 0) == dropBar
            array.shift(sH)
            array.shift(sL)
            array.shift(sV)
            array.shift(sB)
            array.shift(sF)
            array.shift(sI)
    if n > 0
        for j = 0 to n - 1
            array.push(sH, array.get(aH, j))
            array.push(sL, array.get(aL, j))
            array.push(sV, nz(array.get(aV, j)))
            array.push(sB, array.get(aC, j) >= array.get(aO, j))
            array.push(sF, false)
            array.push(sI, bar_index)
    else
        array.push(sH, high)
        array.push(sL, low)
        array.push(sV, nz(volume))
        array.push(sB, close >= open)
        array.push(sF, true)
        array.push(sI, bar_index)

// ---------- series used by the legs ----------
float ph    = ta.pivothigh(high, pivLen, pivLen)
float pl    = ta.pivotlow(low, pivLen, pivLen)
float atr14 = ta.atr(14)
float smaV  = ta.sma(volume, 100)

// ---------- leg object ----------
type Leg
    int        dir
    int        s
    int        e
    int        et
    float      lo
    float      hi
    float      poc
    float      vah
    float      val
    float      sizeA
    float      volX
    int        status
    int        brokeBar
    bool       live
    int        nUsed
    int        nFb
    array<box> bxs
    array<color> bcs
    line       lP
    line       lH
    line       lL
    label      lb

f_tf() => timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(int(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.period
f_stat(int st) => st == 0 ? "UNTESTED" : st == 1 ? "TESTED" : "BROKEN"

// delete all drawings of a leg
f_del(Leg lg) =>
    if not na(lg)
        for b in lg.bxs
            box.delete(b)
        line.delete(lg.lP)
        line.delete(lg.lH)
        line.delete(lg.lL)
        label.delete(lg.lb)

// line look by status: UNTESTED = side colour, TESTED = grey dots, BROKEN = grey dots that stop at the break
// hid = the leg is still extending as the developing leg, so its older completed version is hidden
f_style(Leg lg, bool hid) =>
    if not na(lg)
        bool un = lg.status == 0
        color cS = hid ? color.new(cNEU, 100) : un ? (lg.dir == 1 ? cLO : cHI) : cNEU
        for [i, b] in lg.bxs
            box.set_bgcolor(b, hid ? color.new(cNEU, 100) : array.get(lg.bcs, i))
        int x2 = lg.status == 2 ? lg.brokeBar : bar_index
        line.set_color(lg.lP, cS)
        line.set_color(lg.lH, cS)
        line.set_color(lg.lL, cS)
        line.set_width(lg.lP, un ? 2 : 1)
        line.set_style(lg.lP, un ? line.style_solid : line.style_dotted)
        line.set_style(lg.lH, un ? line.style_dashed : line.style_dotted)
        line.set_style(lg.lL, un ? line.style_dashed : line.style_dotted)
        line.set_x2(lg.lP, x2)
        line.set_x2(lg.lH, x2)
        line.set_x2(lg.lL, x2)
        label.set_xy(lg.lb, bar_index, lg.poc)
        label.set_text(lg.lb, un and not hid ? (lg.live ? "POC live " : "POC ") + str.tostring(lg.poc, format.mintick) : "")

// build the profile of the leg s..e; returns na if the leg is too small or the data does not cover it
// aE = ATR(14) and sv = SMA(volume, 100) at the leg end; they are read in the global scope by the caller,
// because history of a script variable read inside a conditionally called function returns values from earlier calls, not earlier bars
f_build(int s, int e, int dir, bool isLive, float aE, float sv) =>
    Leg res = na
    int k0 = bar_index - e
    int k1 = bar_index - s
    int sFirst = array.size(sI) > 0 ? array.get(sI, 0) : na
    if e - s >= 2 and e - s <= maxLeg and k1 <= 1090 and s >= last_bar_index - WIN and not na(sFirst) and sFirst <= s
        float lo = low[k0]
        float hi = high[k0]
        for k = k0 to k1
            lo := math.min(lo, low[k])
            hi := math.max(hi, high[k])
        float sizeA = aE > 0 ? (hi - lo) / aE : 0.0
        float step = (hi - lo) / rows
        if sizeA >= minAtr and step > 0
            array<float> vol = array.new<float>(rows, 0.0)
            int used = 0
            int fb = 0
            for j = array.size(sI) - 1 to 0
                int bi = array.get(sI, j)
                if bi < s
                    break
                if bi <= e
                    used += 1
                    if array.get(sF, j)
                        fb += 1
                    float h = math.min(array.get(sH, j), hi)
                    float l = math.max(array.get(sL, j), lo)
                    if h >= l
                        int r0 = math.max(0, math.min(rows - 1, int(math.floor((l - lo) / step))))
                        int r1 = h > l ? math.max(r0, math.min(rows - 1, int(math.ceil((h - lo) / step)) - 1)) : r0
                        float share = array.get(sV, j) / (r1 - r0 + 1)
                        for r = r0 to r1
                            array.set(vol, r, array.get(vol, r) + share)
            float tot = array.sum(vol)
            if tot > 0
                int poc = 0
                float mx = array.get(vol, 0)
                for r = 1 to rows - 1
                    if array.get(vol, r) > mx
                        mx := array.get(vol, r)
                        poc := r
                float target = tot * vaPct / 100.0
                int up = poc
                int dn = poc
                float acc = mx
                while acc < target and (up < rows - 1 or dn > 0)
                    float va = up < rows - 1 ? array.get(vol, up + 1) : -1.0
                    float vb = dn > 0 ? array.get(vol, dn - 1) : -1.0
                    if va >= vb
                        up += 1
                        acc += va
                    else
                        dn -= 1
                        acc += vb
                float pocP = lo + (poc + 0.5) * step
                float vahP = lo + (up + 1) * step
                float valP = lo + dn * step
                // profile bars from the leg start, longest row = half of the leg
                array<box> bxs = array.new<box>()
                array<color> bcs = array.new<color>()
                int legLen = e - s + 1
                int maxW = math.max(2, math.min(legLen, math.max(5, int(math.round((e - s) * 0.5)))))
                for r = 0 to rows - 1
                    float v = array.get(vol, r)
                    if v > 0
                        int w = math.max(1, int(math.round(v / mx * maxW)))
                        int trn = r == poc ? (isLight ? 20 : 40) : (r >= dn and r <= up) ? (isLight ? 40 : 60) : (isLight ? 60 : 75)
                        color bc = color.new(cNEU, trn)
                        array.push(bxs, box.new(s, lo + (r + 1) * step, s + w, lo + r * step, border_width = 0, bgcolor = bc))
                        array.push(bcs, bc)
                // levels start at the leg end
                color cS = dir == 1 ? cLO : cHI
                line lP = line.new(e, pocP, bar_index, pocP, color = cS, width = 2)
                line lH = line.new(e, vahP, bar_index, vahP, color = cS, width = 1, style = line.style_dashed)
                line lL = line.new(e, valP, bar_index, valP, color = cS, width = 1, style = line.style_dashed)
                label lb = label.new(bar_index, pocP, "", style = label.style_label_left, color = color.new(cMUTED, 100), textcolor = cMUTED, size = size.tiny)
                // status from the closed bars after the leg end up to the previous bar (touches before the leg appeared count too);
                // the current bar is checked by f_update, so an event on it still sends an alert
                int st = 0
                int bb = na
                float far = dir == 1 ? valP : vahP
                if k0 >= 2
                    for k = k0 - 1 to 1
                        if st == 0 and low[k] <= pocP and high[k] >= pocP
                            st := 1
                        if dir == 1 ? close[k] < far : close[k] > far
                            st := 2
                            bb := bar_index - k
                            break
                float vx = sv > 0 ? (tot / legLen) / sv : na
                res := Leg.new(dir = dir, s = s, e = e, et = time[k0], lo = lo, hi = hi, poc = pocP, vah = vahP, val = valP, sizeA = sizeA, volX = vx, status = st, brokeBar = bb, live = isLive, nUsed = used, nFb = fb, bxs = bxs, bcs = bcs, lP = lP, lH = lH, lL = lL, lb = lb)
    res

// status update on a closed bar after the leg end: 1 = first touch of the POC, 2 = broken, 3 = both
f_update(Leg lg) =>
    int ev = 0
    if not na(lg)
        if lg.status < 2 and bar_index > lg.e
            if lg.status == 0 and low <= lg.poc and high >= lg.poc
                lg.status := 1
                ev := 1
            if lg.dir == 1 ? close < lg.val : close > lg.vah
                lg.status := 2
                lg.brokeBar := bar_index
                ev += 2
    ev

f_name(Leg lg) => (lg.dir == 1 ? "up leg" : "down leg") + (lg.live ? " (live)" : "")

// ---------- swings, sweeps and legs ----------
var int   lpType    = 0
var int   lpBar     = na
var float lpPrice   = na
var float lastLowP  = na
var float prevLowP  = na
var float lastHighP = na
var float prevHighP = na
var bool  lowSwept  = false
var bool  highSwept = false
var int   legS   = na
var int   legE   = na
var int   legDir = 0
var bool  legSw  = false
bool legNew   = false
bool swingChg = false

if barstate.isconfirmed and not na(ph)
    int pb = bar_index - pivLen
    if lpType == 1
        if ph > lpPrice
            // a higher high extends the current up leg
            if legDir == 1 and legE == lpBar
                legE := pb
                legNew := true
            lpBar := pb
            lpPrice := ph
            lastHighP := ph
            highSwept := not na(prevHighP) and ph > prevHighP and (close[pivLen] < prevHighP or close[pivLen - 1] < prevHighP)
            swingChg := true
    else
        if lpType == -1 and lpBar != pb
            legS := lpBar
            legE := pb
            legDir := 1
            legSw := lowSwept
            legNew := true
        lpType := 1
        lpBar := pb
        lpPrice := ph
        prevHighP := lastHighP
        lastHighP := ph
        highSwept := not na(prevHighP) and ph > prevHighP and (close[pivLen] < prevHighP or close[pivLen - 1] < prevHighP)
        swingChg := true

if barstate.isconfirmed and not na(pl)
    int pb = bar_index - pivLen
    if lpType == -1
        if pl < lpPrice
            // a lower low extends the current down leg
            if legDir == -1 and legE == lpBar
                legE := pb
                legNew := true
            lpBar := pb
            lpPrice := pl
            lastLowP := pl
            lowSwept := not na(prevLowP) and pl < prevLowP and (close[pivLen] > prevLowP or close[pivLen - 1] > prevLowP)
            swingChg := true
    else
        if lpType == 1 and lpBar != pb
            legS := lpBar
            legE := pb
            legDir := -1
            legSw := highSwept
            legNew := true
        lpType := -1
        lpBar := pb
        lpPrice := pl
        prevLowP := lastLowP
        lastLowP := pl
        lowSwept := not na(prevLowP) and pl < prevLowP and (close[pivLen] > prevLowP or close[pivLen - 1] > prevLowP)
        swingChg := true

// ---------- completed legs ----------
var array<Leg> legs = array.new<Leg>()
var Leg liveLeg = na

// true when the developing leg is this same leg still extending (same start, same direction)
f_hid(Leg lg) => not na(liveLeg) and not na(lg) and liveLeg.s == lg.s and liveLeg.dir == lg.dir

if legNew
    // an extended leg replaces its older version
    int nL0 = array.size(legs)
    if nL0 > 0
        for i = nL0 - 1 to 0
            Leg g = array.get(legs, i)
            if g.s == legS and g.dir == legDir
                f_del(g)
                array.remove(legs, i)
    if not na(liveLeg)
        if liveLeg.s == legS and liveLeg.dir == legDir
            f_del(liveLeg)
            liveLeg := na
    if legSw or not onlySw
        Leg nl = f_build(legS, legE, legDir, false, atr14[bar_index - legE], smaV[bar_index - legE])
        if not na(nl)
            array.push(legs, nl)
            if array.size(legs) > nShow
                f_del(array.shift(legs))

// ---------- developing (live) leg ----------
// from the last confirmed swing to the current extreme; if price has already gone past that swing,
// the previous leg is still extending, so the developing leg is that leg up to the new extreme
var int   liveSBar  = na
var int   hiBar     = na
var int   loBar     = na
var float hiP       = na
var float loP       = na
var bool  liveDirty = false

if barstate.isconfirmed and not na(lpBar)
    if swingChg or na(liveSBar) or lpBar != liveSBar
        liveSBar := lpBar
        hiP := na
        loP := na
        hiBar := na
        loBar := na
        int kk = math.min(bar_index - lpBar, maxLeg + pivLen)
        if kk >= 1
            for k = kk - 1 to 0
                if na(hiP) or high[k] > hiP
                    hiP := high[k]
                    hiBar := bar_index - k
                if na(loP) or low[k] < loP
                    loP := low[k]
                    loBar := bar_index - k
        liveDirty := true
    else
        if high > hiP
            hiP := high
            hiBar := bar_index
            liveDirty := true
        if low < loP
            loP := low
            loBar := bar_index
            liveDirty := true

if showLive and liveDirty and barstate.isconfirmed and bar_index >= last_bar_index - 1
    int  ldir = 0
    int  ls   = na
    int  le   = na
    bool lsw  = false
    if lpType == 1
        if not na(hiP) and hiP > lpPrice and legDir == 1 and legE == lpBar
            ldir := 1
            ls := legS
            le := hiBar
            lsw := legSw
        else
            ldir := -1
            ls := lpBar
            le := loBar
            lsw := highSwept
    else if lpType == -1
        if not na(loP) and loP < lpPrice and legDir == -1 and legE == lpBar
            ldir := -1
            ls := legS
            le := loBar
            lsw := legSw
        else
            ldir := 1
            ls := lpBar
            le := hiBar
            lsw := lowSwept
    // rebuild only when the leg bounds change, so a kept leg keeps its status and alert history
    bool liveValid = ldir != 0 and not na(ls) and not na(le) and le - ls >= 2 and le - ls <= maxLeg and bar_index - ls <= 1090 and ls >= last_bar_index - WIN and (lsw or not onlySw)
    bool sameLive = liveValid and not na(liveLeg) and liveLeg.s == ls and liveLeg.e == le and liveLeg.dir == ldir
    if not sameLive
        f_del(liveLeg)
        liveLeg := na
        if liveValid
            liveLeg := f_build(ls, le, ldir, true, atr14[bar_index - le], smaV[bar_index - le])
    liveDirty := false

// ---------- status updates and alerts ----------
bool touchEvt = false
bool brokeEvt = false
string evtMsg = ""

if barstate.isconfirmed
    int nL1 = array.size(legs)
    if nL1 > 0
        for i = 0 to nL1 - 1
            Leg g = array.get(legs, i)
            int ev = f_update(g)
            if f_hid(g)
                ev := 0
            if ev == 1 or ev == 3
                touchEvt := true
                evtMsg += syminfo.ticker + " " + f_tf() + ": first touch of POC " + str.tostring(g.poc, format.mintick) + ", " + f_name(g) + ". "
            if ev >= 2
                brokeEvt := true
                evtMsg += syminfo.ticker + " " + f_tf() + ": " + f_name(g) + " broken, close " + (g.dir == 1 ? "below VAL " + str.tostring(g.val, format.mintick) : "above VAH " + str.tostring(g.vah, format.mintick)) + ". "
    int evL = f_update(liveLeg)
    if evL == 1 or evL == 3
        touchEvt := true
        evtMsg += syminfo.ticker + " " + f_tf() + ": first touch of POC " + str.tostring(liveLeg.poc, format.mintick) + ", " + f_name(liveLeg) + ". "
    if evL >= 2
        brokeEvt := true
        evtMsg += syminfo.ticker + " " + f_tf() + ": " + f_name(liveLeg) + " broken, close " + (liveLeg.dir == 1 ? "below VAL " + str.tostring(liveLeg.val, format.mintick) : "above VAH " + str.tostring(liveLeg.vah, format.mintick)) + ". "

if evtMsg != ""
    alert(evtMsg, alert.freq_once_per_bar_close)
alertcondition(touchEvt, "First touch of a POC", "Sweep Leg Volume Profile: first touch of a POC")
alertcondition(brokeEvt, "Leg broken", "Sweep Leg Volume Profile: a leg value area was broken by a close")

// ---------- table ----------
tblPos = switch tblPosIn
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_left

var table tb = table.new(tblPos, 6, 7, bgcolor = cPANEL, frame_color = cBORDER, frame_width = 1, border_width = 0)
if barstate.isfirst and showTbl
    table.merge_cells(tb, 0, 0, 5, 0)

f_cell(int c, int r, string t, color col, bool num) =>
    table.cell(tb, c, r, t, text_color = col, text_size = size.small, text_halign = num ? text.align_right : text.align_left, text_font_family = num ? font.family_monospace : font.family_default)

f_row(Leg lg, int r) =>
    bool un = lg.status == 0
    color cS = un ? (lg.dir == 1 ? cLO : cHI) : cMUTED
    color cT = un ? cINK : cMUTED
    float d = (lg.poc - close) / close * 100.0
    f_cell(0, r, (lg.dir == 1 ? "▲ " : "▼ ") + (lg.live ? "live" : str.format_time(lg.et, "MM-dd HH:mm", "UTC")), cS, false)
    f_cell(1, r, str.tostring(lg.sizeA, "0.0"), cT, true)
    f_cell(2, r, na(lg.volX) ? "—" : str.tostring(lg.volX, "0.0") + "×", cT, true)
    f_cell(3, r, str.tostring(lg.poc, format.mintick), cT, true)
    f_cell(4, r, (d >= 0 ? "+" : "−") + str.tostring(math.abs(d), "0.0") + "%", cT, true)
    f_cell(5, r, f_stat(lg.status), cT, false)

if barstate.islast
    int nL2 = array.size(legs)
    if nL2 > 0
        for i = 0 to nL2 - 1
            Leg g = array.get(legs, i)
            f_style(g, f_hid(g))
    f_style(liveLeg, false)
    if showTbl
        table.cell(tb, 0, 0, "Sweep Leg Volume Profile [Zen] · " + f_tf(), text_color = cHEADTX, bgcolor = cHEAD, text_size = size.small)
        f_cell(0, 1, "Leg", cMUTED, false)
        f_cell(1, 1, "Size ATR", cMUTED, true)
        f_cell(2, 1, "Vol", cMUTED, true)
        f_cell(3, 1, "POC", cMUTED, true)
        f_cell(4, 1, "Dist", cMUTED, true)
        f_cell(5, 1, "Status", cMUTED, false)
        int r = 2
        int fbAll = 0
        if not na(liveLeg)
            f_row(liveLeg, r)
            fbAll += liveLeg.nFb
            r += 1
        if nL2 > 0
            for i = nL2 - 1 to 0
                Leg g = array.get(legs, i)
                if not f_hid(g)
                    f_row(g, r)
                    fbAll += g.nFb
                    r += 1
        bool noLegs = r == 2
        while r <= 5
            for c = 0 to 5
                table.cell(tb, c, r, "")
            r += 1
        if noLegs
            f_cell(0, 2, "No qualifying legs yet", cMUTED, false)
        f_cell(0, 6, "LTF " + ltfUse, cMUTED, false)
        f_cell(1, 6, "", cMUTED, true)
        f_cell(2, 6, "", cMUTED, true)
        f_cell(3, 6, "chart-bar", cMUTED, true)
        f_cell(4, 6, "fallback", cMUTED, true)
        f_cell(5, 6, str.tostring(fbAll), cMUTED, false)
````
