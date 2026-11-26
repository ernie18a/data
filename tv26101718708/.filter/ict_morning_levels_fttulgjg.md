# ICT Morning Levels

- url: https://www.tradingview.com/script/fTtULGjg-ICT-Morning-Levels/
- type: indicator
- pine_id: PUB;12a89c6da9e84dc5bc7dd48d6935c396
- version: 1.0

## Description

Auto-draws the pre-market and in-session levels I watch into the NY morning — prior session, Asia, London, 6am, overnight, opening range, daily 50%, NWOG, swings — plus multi-timeframe FVGs. Every level is anchored to the time it formed, cuts when liquidity is taken, and merges with nearby levels so the chart stays readable.

WHAT IT DOES

This indicator draws the key liquidity levels and fair-value gaps for the New York morning session automatically, so you don't have to mark them by hand each day. It's built for intraday index-futures trading (NQ/ES) on a low chart timeframe, but works on any symbol.

LEVELS DRAWN (all times America/New_York)

• Prev Session H/L — prior RTH session (09:30–16:00)
• Asia H/L — 19:00 to 02:00
• London H/L — 02:00 to 08:00
• 6am H/L — 06:00 to 10:00 (the 06:00 4H candle)
• Overnight H/L — 18:00 to 09:30
• Opening Range H/L — 09:30 to 09:45
• Daily 50% — midpoint of the CME daily candle
• NWOG — New Week Opening Gap (Mondays: Fri RTH close to Mon RTH open)
• 1H / 4H swing H/L — pivot highs/lows on those timeframes

FAIR-VALUE GAPS (FVGs)

Every open 3-candle gap on the 15m, 1H, and 4H timeframes is drawn as a shaded zone, tinted by timeframe. Gaps move through a lifecycle:

• Unmitigated (untested) — read louder; these are the actionable targets
• Mitigated (price entered the zone but hasn't traded through) — faded, tagged "Mitigated"
• Filled / aged out — removed automatically

When multiple gaps overlap (e.g. a 1H gap nested inside a 4H gap), their tags stack into a single legend so you can see every timeframe at that price without the labels colliding.

HOW IT BEHAVES

• Time-anchored: every level is stored with its formation time and spawns from its true origin, so it never shifts when you change or zoom the chart timeframe.
• Cuts on sweep: when liquidity is taken, the line stops at the exact bar where it happened (toggleable — turn off for full reference lines).
• Confluence merge: levels at the same price collapse into one line, showing the most significant name (e.g. an Opening Range low sitting on the Prev Day low just reads "Prev Day L").
• Distance filter: only levels within a set distance of price are drawn, so the chart stays clean.
• Replay-safe: intraday sessions and the opening range are computed chart-native, so they form correctly during bar replay and register sweeps at first touch.

SETTINGS

Everything is toggleable — pick which levels, sessions, swings, and FVG timeframes you want; adjust colors, label size, merge tolerance, max distance, min FVG size, and how long levels persist before they're pruned.

NOTES

• Designed around the NY morning session on index futures; session windows are fixed to New York time.
• Not financial advice — this is a charting/workflow tool for marking levels, not a signal or strategy.

## Source Code

````pine
//@version=6
// =============================================================================
// FVGC Morning Levels  —  auto-draws Phil's daily pre-market + in-session levels
// -----------------------------------------------------------------------------
// Session windows match data/levels/build_session_levels.py (America/New_York):
//   Prev Session H/L  prior RTH 09:30-16:00                    [ref: CHART TF, replay-safe]
//   Asia H/L          prior day 19:00 -> 02:00                 [ref: CHART TF, replay-safe]
//   London H/L        02:00 -> 08:00                           [ref: CHART TF, replay-safe]
//   6am H/L           06:00 -> 10:00  (the 06:00 4H candle)    [ref: CHART TF, replay-safe]
//   Overnight H/L     prior day 18:00 -> 09:30                 [ref: CHART TF, replay-safe]
//   Opening Range H/L 09:30 -> 09:45  (= the 09:30 15m candle)  [ref: CHART TF, replay-safe]
//   Daily 50%         CME daily candle midpoint (18:00->17:00) [ref: Session TF]
//   NWOG H/L          Mondays: Fri RTH close <-> Mon RTH open  [ref: Session TF]
//   1H / 4H Swing H/L pivot high/low on that timeframe         [ref: Swing TFs]
//   15m / 1H FVG      3-candle gap, min size = fvgMin          [ref: FVG TFs]
//
// KEY DESIGN — every level is stored with its formation TIME (not bar_index) and
// drawn with xloc.bar_time, so it's spawned from its origin and NEVER moves when you
// change/zoom the chart TF. Intraday sessions + Opening Range are computed CHART-NATIVE
// (latch on time, replay-safe, sweep-accurate); Daily 50 / NWOG / swings / FVG use
// request.security() on a fixed reference TF (their lookback exceeds a 30s chart's bars).
//
// Behaviour:
//   * Neat horizontal line per level, text label at the right end.
//   * When liquidity is taken, the line CUTS at the bar where it happened.
//   * Levels at the same price MERGE into one line; the most significant name
//     is shown alone (e.g. OR L coinciding with Prev Day L -> "Prev Day L").
//   * Naming band (wider than merge): an Overnight or swing level within `nameTol` of a
//     primary session level (Prev Day / Asia / London / OR / NWOG / Daily 50) is fully
//     hidden, so the session level alone represents that price.
//   * 6am and Opening Range are current-day-only — they drop off once the ET day rolls
//     over (any prior-session extreme they marked is still drawn as its own session level).
//   * Only levels within `Max distance` of price are drawn.
// =============================================================================
indicator("FVGC Morning Levels", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200, max_bars_back=5000)

TZ  = "America/New_York"
SYM = syminfo.tickerid

// ---------------- Inputs: reference timeframes ----------------
gR = "Reference timeframes"
sessTF   = input.timeframe("15",  "Daily 50 / NWOG reference TF (other sessions are chart-native)", group=gR)
swing1TF = input.timeframe("60",  "Swing 1 TF (1H)",   group=gR)
swing2TF = input.timeframe("240", "Swing 2 TF (4H)",   group=gR)

// ---------------- Inputs: display ----------------
gD = "Display"
maxDist    = input.float(500,  "Max distance from price (pts, 0 = off)", group=gD)
confTol    = input.float(5,    "Confluence merge tolerance (pts)",       group=gD)
nameTol    = input.float(20,   "Session naming band (pts, 0 = off) — hide 6am/ON/swing labels this close to a primary session level", group=gD)
theme      = input.string("Light chart", "Chart background", options=["Light chart","Dark chart","Custom"], tooltip="Light chart = dark levels (black). Dark chart = light levels (soft off-white) for TV's default dark theme. Custom = use the color below.", group=gD)
lineColor  = input.color(color.black, "Custom line / text color (used when theme = Custom)", group=gD)
lineWidth  = input.int(1,      "Line width", minval=1,                   group=gD)
fontSize   = input.string("small", "Label size (small ~= 11pt)", options=["tiny","small","normal","large"], group=gD)
cutOnSweep = input.bool(true,  "Cut lines at sweep point (off = full reference lines)", group=gD)
maxAgeDays = input.float(3,    "Prune levels older than (days, 0 = off)",group=gD)

// ---------------- Inputs: which levels ----------------
gL = "Levels"
showPrevDay = input.bool(true, "Previous session H/L (RTH)",     group=gL)
showAsia    = input.bool(true, "Asia H/L (19:00-02:00)",         group=gL)
showLondon  = input.bool(true, "London H/L (02:00-08:00)",       group=gL)
show6am     = input.bool(true, "6am H/L (6:00 4H candle, 06:00-10:00)", group=gL)
showON      = input.bool(true, "Overnight H/L (18:00-09:30)",    group=gL)
showOR      = input.bool(true, "Opening Range H/L (09:30-09:45)",group=gL)
show50      = input.bool(true, "Daily 50% (CME 18:00-17:00)",    group=gL)
showNWOG    = input.bool(true, "NWOG (Mondays)",                 group=gL)

// ---------------- Inputs: swings ----------------
gS = "Swings (pivot high/low)"
showSwing1 = input.bool(true, "1H swing H/L",                    group=gS)
showSwing2 = input.bool(true, "4H swing H/L",                    group=gS)
swingLen   = input.int(2, "Pivot strength (bars each side)", minval=1, group=gS)

// ---------------- Inputs: FVGs ----------------
gF = "FVG / Gaps"
show15  = input.bool(true, "15m FVG", group=gF)
show1H  = input.bool(true, "1H FVG",  group=gF)
show4H  = input.bool(true, "4H FVG",  group=gF)
fvgMin  = input.float(3,   "Min FVG size (pts)", group=gF)
// subtle per-timeframe tint so gaps stay in the background behind the candles
fvg15Col   = input.color(color.blue,   "15m gap tint", group=gF)
fvg1HCol   = input.color(color.purple, "1h gap tint",  group=gF)
fvg4HCol   = input.color(color.teal,   "4h gap tint",  group=gF)
fvgUnmitT  = input.int(90, "Unmitigated transparency (higher = fainter)", minval=50, maxval=100, group=gF)
fvgMitT    = input.int(96, "Mitigated transparency (higher = fainter)",   minval=50, maxval=100, group=gF)
fvgBorder  = input.bool(false, "Gap borders", group=gF)
fvgLabelMit= input.bool(true,  "Label mitigated gaps (tagged 'Mitigated', muted)", group=gF)

fSize = fontSize == "tiny" ? size.tiny : fontSize == "small" ? size.small : fontSize == "large" ? size.large : size.normal

// Line / label color resolved from the chart-background theme. Dark chart uses a soft
// off-white (not pure white) so lines/labels read clearly over TV's default dark navy +
// red/green candles without glaring. Custom falls back to the color input above.
lvlColor = theme == "Dark chart" ? color.rgb(230, 230, 230) : theme == "Custom" ? lineColor : color.black

// Labels render in the chart's native font (font.family_default = SF Pro /
// Trebuchet, whatever your platform uses) and use Pine v6's real bold via
// text_formatting=text.format_bold. This matches TradingView's native bold
// trendline text exactly — no unicode-glyph hack (which forced a serif fallback).
LBL_FONT = font.family_default

// significance rank for confluence: when levels merge, the lowest number wins
// and its name is shown alone (no combination). Prev Day supersedes OR, etc.
f_prio(_name) =>
    p = 50
    if str.contains(_name, "Prev Day")
        p := 1
    else if str.contains(_name, "NWOG")
        p := 2
    else if str.contains(_name, "Daily 50")
        p := 3
    else if str.contains(_name, "Opening Range")
        p := 4    // OR keeps its own label vs sessions/swings; yields only to the structural daily levels above (Prev Day / NWOG / Daily 50 — the ones that hold all session)
    else if str.contains(_name, "London")
        p := 5
    else if str.contains(_name, "Asia")
        p := 6
    else if str.contains(_name, "6am")
        p := 7
    else if str.contains(_name, "ON ")
        p := 8    // Overnight yields to any named session it sits on (Asia/London/6am)
    else if str.contains(_name, "4H Swing")
        p := 9
    else if str.contains(_name, "1H Swing")
        p := 10
    p

// same ET calendar day? used to prune current-day-only utility levels (6am / OR)
f_sameDay(_t1, _t2) =>
    year(_t1, TZ) == year(_t2, TZ) and month(_t1, TZ) == month(_t2, TZ) and dayofmonth(_t1, TZ) == dayofmonth(_t2, TZ)

// ---------------- Level store (parallel arrays; times in ms) ----------------
var arrP     = array.new_float()
var arrName  = array.new_string()
var arrSide  = array.new_int()    //  1 = high (swept when high>=p), -1 = low (low<=p), 0 = mid
var arrForm  = array.new_int()    // formation TIME (ms) at the origin reference bar
var arrSwept = array.new_int()    // sweep TIME (ms) where taken, -1 if still live

f_removeAt(_i) =>
    array.remove(arrP, _i)
    array.remove(arrName, _i)
    array.remove(arrSide, _i)
    array.remove(arrForm, _i)
    array.remove(arrSwept, _i)

addLvl(_p, _name, _side, _form) =>
    if not na(_p) and not na(_form)
        array.push(arrP, _p)
        array.push(arrName, _name)
        array.push(arrSide, _side)
        array.push(arrForm, _form)
        array.push(arrSwept, -1)

// replace: drop any still-live level of the same name, then add (for swings —
// keeps only the most recent unswept pivot per name; swept ones persist).
replaceLvl(_p, _name, _side, _form) =>
    if not na(_p) and not na(_form)
        if array.size(arrP) > 0
            for i = array.size(arrP) - 1 to 0
                if array.get(arrName, i) == _name and array.get(arrSwept, i) == -1
                    f_removeAt(i)
        addLvl(_p, _name, _side, _form)

// unique: keep only the SINGLE latest instance of a once-per-day level (drops all
// prior same-name, swept or not). Prevents 3 days of "Prev Day L"/"OR L"/etc.
// piling up and merging into confusing labels. Used for all daily session levels.
setLvl(_p, _name, _side, _form) =>
    if not na(_p) and not na(_form)
        if array.size(arrP) > 0
            for i = array.size(arrP) - 1 to 0
                if array.get(arrName, i) == _name
                    f_removeAt(i)
        addLvl(_p, _name, _side, _form)

// session H/L that stays until TAKEN: like addLvl, but when a fresh instance of the same
// name forms it clears only prior instances that were already SWEPT (spent cut-lines).
// Still-live prior-session extremes are KEPT — an untaken Asia/London high from an earlier
// session remains as resting liquidity until price sweeps it (then it cuts, and the next
// session's formation clears the spent line). maxAgeDays caps how far back they pile up.
keepLiveLvl(_p, _name, _side, _form) =>
    if not na(_p) and not na(_form)
        if array.size(arrP) > 0
            for i = array.size(arrP) - 1 to 0
                if array.get(arrName, i) == _name and array.get(arrSwept, i) != -1
                    f_removeAt(i)
        addLvl(_p, _name, _side, _form)

// =============================================================================
// Reference-TF computation functions — these run INSIDE request.security() on
// their target timeframe, so `time`, `high`, `low` below are the reference TF's.
// Each returns the LAST COMPLETED result, latched, so the chart just watches
// for the returned time to change and adds the level once.
// =============================================================================

// Session window extreme, latched at session end. wrap=true for windows that
// cross midnight (e.g. 18:00 -> 09:30).
f_sessLatched(_h, _l, _startHHMM, _endHHMM, _wrap) =>
    hm = hour(time, TZ) * 100 + minute(time, TZ)
    inw = _wrap ? (hm >= _startHHMM or hm < _endHHMM) : (hm >= _startHHMM and hm < _endHHMM)
    var float curHi  = na
    var float curLo  = na
    var int   curHiT = na
    var int   curLoT = na
    var float outHi  = na
    var float outLo  = na
    var int   outHiT = na
    var int   outLoT = na
    bool started = inw and not inw[1]
    bool ended   = (not inw) and inw[1]
    if started
        curHi  := _h
        curLo  := _l
        curHiT := time
        curLoT := time
    else if inw
        if _h > curHi
            curHi  := _h
            curHiT := time
        if _l < curLo
            curLo  := _l
            curLoT := time
    if ended
        outHi  := curHi
        outLo  := curLo
        outHiT := curHiT
        outLoT := curLoT
    [outHi, outLo, outHiT, outLoT]

// NWOG: Friday RTH close <-> Monday RTH open, latched on Monday open.
f_nwogLatched(_c, _o) =>
    hm = hour(time, TZ) * 100 + minute(time, TZ)
    d  = dayofweek(time, TZ)
    inRTH = hm >= 930 and hm < 1600
    var float friC = na
    var float outH = na
    var float outL = na
    var int   outT = na
    if d == dayofweek.friday and inRTH
        friC := _c
    isMonOpen = d == dayofweek.monday and inRTH and not inRTH[1]
    if isMonOpen and not na(friC)
        outH := math.max(friC, _o)
        outL := math.min(friC, _o)
        outT := time
    [outH, outL, outT]

// Opening Range computed on the CHART timeframe (NOT via request.security), so it
// still forms during bar replay — HTF security is unreliable for bars inside the
// replay window. Assumes the chart TF is <= 15m (always true for the morning
// session it's used in). Both H and L anchor to the 09:30 window start.
f_orWindow(_startHHMM, _endHHMM) =>
    hm = hour(time, TZ) * 100 + minute(time, TZ)
    inw = hm >= _startHHMM and hm < _endHHMM
    var float cHi  = na
    var float cLo  = na
    var int   cHiT = na
    var int   cLoT = na
    var float oH   = na
    var float oL   = na
    var int   oHT  = na
    var int   oLT  = na
    started = inw and not inw[1]
    ended   = (not inw) and inw[1]
    if started
        cHi  := high
        cLo  := low
        cHiT := time
        cLoT := time
    else if inw
        if high > cHi
            cHi  := high
            cHiT := time
        if low < cLo
            cLo  := low
            cLoT := time
    if ended
        oH  := cHi
        oL  := cLo
        oHT := cHiT     // anchor to the bar that MADE the high (not window start)
        oLT := cLoT     // ...and the bar that made the low — so neither self-sweeps
    [oH, oL, oHT, oLT]

// Pivot high/low on the reference TF; returns the pivot value + its bar time.
f_piv(_len) =>
    ph  = ta.pivothigh(_len, _len)
    pl  = ta.pivotlow(_len, _len)
    pht = na(ph) ? na : time[_len]
    plt = na(pl) ? na : time[_len]
    [ph, pht, pl, plt]

// ---------------- Pull each level from its reference timeframe ----------------
LA = barmerge.lookahead_off

// Intraday session windows are computed CHART-NATIVE (not via request.security). A
// 15m security value isn't delivered until its 15m bar CLOSES, so a level would enter
// the store up to 15m after its session actually ended — long enough to miss an early
// breach and mis-cut (the "ON L pierces through" bug). Chart-native latches exactly at
// the session boundary, so sweeps register at the true first-touch. Values are identical
// (a session's extreme is the same at any bar size); only the anchor time is finer.
[pdH,  pdL,  pdHT,  pdLT ] = f_sessLatched(high, low,  930, 1600, false)   // prior NY RTH 09:30-16:00
[asH,  asL,  asHT,  asLT ] = f_sessLatched(high, low, 1900,  200, true )   // Asia   19:00-02:00
[loH,  loL,  loHT,  loLT ] = f_sessLatched(high, low,  200,  800, false)   // London 02:00-08:00
[s6H,  s6L,  s6HT,  s6LT ] = f_sessLatched(high, low,  600, 1000, false)   // 6am    06:00-10:00
[onH,  onL,  onHT,  onLT ] = f_sessLatched(high, low, 1800,  930, true )   // Overnight 18:00-09:30
[orH,  orL,  orHT,  orLT ] = f_orWindow(930, 945)   // Opening Range 09:30-09:45
// Daily 50% / NWOG keep request.security — their windows reach back further than a 30s
// chart holds in max_bars_back, and they're not the fast-moving intraday sweeps above.
[dyH,  dyL,  dyHT,  dyLT ] = request.security(SYM, sessTF, f_sessLatched(high, low, 1800, 1700, true ), lookahead=LA)
[nwH,  nwL,  nwT        ] = request.security(SYM, sessTF, f_nwogLatched(close, open), lookahead=LA)
[s1H,  s1HT, s1L,  s1LT ] = request.security(SYM, swing1TF, f_piv(swingLen), lookahead=LA)
[s2H,  s2HT, s2L,  s2LT ] = request.security(SYM, swing2TF, f_piv(swingLen), lookahead=LA)

// helper: latched value just changed to a new completed reading
f_new(_t) => not na(_t) and (na(_t[1]) or _t != _t[1])

// ---------------- Add levels when their reference reading updates ----------------
// Daily session levels use setLvl -> only the single most-recent instance is kept
// (no multi-day pile-up). "Previous Day" = yesterday's RTH 09:30-16:00, latched 16:00.
if showPrevDay and f_new(pdHT)
    setLvl(pdH, "Prev Day H", 1, pdHT)
if showPrevDay and f_new(pdLT)
    setLvl(pdL, "Prev Day L", -1, pdLT)
if showAsia and f_new(asHT)
    keepLiveLvl(asH, "Asia H", 1, asHT)
if showAsia and f_new(asLT)
    keepLiveLvl(asL, "Asia L", -1, asLT)
if showLondon and f_new(loHT)
    keepLiveLvl(loH, "London H", 1, loHT)
if showLondon and f_new(loLT)
    keepLiveLvl(loL, "London L", -1, loLT)
if show6am and f_new(s6HT)
    setLvl(s6H, "6am H", 1, s6HT)
if show6am and f_new(s6LT)
    setLvl(s6L, "6am L", -1, s6LT)
if showON and f_new(onHT)
    setLvl(onH, "ON H", 1, onHT)
if showON and f_new(onLT)
    setLvl(onL, "ON L", -1, onLT)
if showOR and f_new(orHT)
    setLvl(orH, "Opening Range H", 1, orHT)
if showOR and f_new(orLT)
    setLvl(orL, "Opening Range L", -1, orLT)
if show50 and f_new(dyHT)
    setLvl((dyH + dyL) / 2, "Daily 50%", 0, math.min(dyHT, dyLT))
if showNWOG and f_new(nwT)
    setLvl(nwH, "NWOG H", 1, nwT)
    setLvl(nwL, "NWOG L", -1, nwT)

// swings: replace prior live pivot of the same name (keep only latest live one)
if showSwing1 and f_new(s1HT)
    replaceLvl(s1H, "1H Swing H", 1, s1HT)
if showSwing1 and f_new(s1LT)
    replaceLvl(s1L, "1H Swing L", -1, s1LT)
if showSwing2 and f_new(s2HT)
    replaceLvl(s2H, "4H Swing H", 1, s2HT)
if showSwing2 and f_new(s2LT)
    replaceLvl(s2L, "4H Swing L", -1, s2LT)

// ---------------- Per-bar: prune old + detect sweeps ----------------
maxAgeMs = maxAgeDays * 86400000.0
if array.size(arrP) > 0
    for i = array.size(arrP) - 1 to 0
        formT = array.get(arrForm, i)
        if maxAgeDays > 0 and (time - formT) > maxAgeMs
            f_removeAt(i)
        else
            if array.get(arrSwept, i) == -1 and time > formT
                p  = array.get(arrP, i)
                sd = array.get(arrSide, i)
                swept = (sd == 1 and high >= p) or (sd == -1 and low <= p) or (sd == 0 and high >= p and low <= p)
                if swept
                    array.set(arrSwept, i, time)

// ---------------- Render (last bar only) ----------------
var poolL = array.new_line()
var poolT = array.new_label()
var int firstBarTime = na
if barstate.isfirst
    firstBarTime := time

if barstate.islast
    if array.size(poolL) > 0
        for i = 0 to array.size(poolL) - 1
            line.delete(array.get(poolL, i))
    if array.size(poolT) > 0
        for i = 0 to array.size(poolT) - 1
            label.delete(array.get(poolT, i))
    array.clear(poolL)
    array.clear(poolT)

    nowT   = time

    // gather renderable: distance filter + current-day-only prune for utility levels.
    // 6am and Opening Range are intraday utility marks — only meaningful for today's
    // session, so once we're on a later ET day they drop off (any that mattered as a
    // prior-session extreme is already drawn as Prev Day / Asia / London in its own right).
    tP    = array.new_float()
    tN    = array.new_string()
    tForm = array.new_int()
    tX2   = array.new_int()
    if array.size(arrP) > 0
        for i = 0 to array.size(arrP) - 1
            p  = array.get(arrP, i)
            nm = array.get(arrName, i)
            fm = array.get(arrForm, i)
            isUtil  = str.contains(nm, "Opening Range") or str.contains(nm, "6am")
            inDist  = maxDist <= 0 or math.abs(p - close) <= maxDist
            if inDist and (not isUtil or f_sameDay(fm, nowT))
                sw = array.get(arrSwept, i)
                array.push(tP, p)
                array.push(tN, nm)
                array.push(tForm, fm)
                array.push(tX2, (cutOnSweep and sw != -1) ? sw : nowT)

    // selection sort ascending by price
    m = array.size(tP)
    if m > 1
        for a = 0 to m - 2
            mn = a
            for b = a + 1 to m - 1
                if array.get(tP, b) < array.get(tP, mn)
                    mn := b
            if mn != a
                f = array.get(tP, a)
                array.set(tP, a, array.get(tP, mn))
                array.set(tP, mn, f)
                s = array.get(tN, a)
                array.set(tN, a, array.get(tN, mn))
                array.set(tN, mn, s)
                g = array.get(tForm, a)
                array.set(tForm, a, array.get(tForm, mn))
                array.set(tForm, mn, g)
                x = array.get(tX2, a)
                array.set(tX2, a, array.get(tX2, mn))
                array.set(tX2, mn, x)

    // group by confluence tolerance -> collect ONE leader per cluster (time-anchored).
    // The leader is the highest-priority level in the cluster; we take its exact price,
    // origin, and end. Lesser members sharing the <=confTol price band are suppressed
    // (name dropped), NOT blended — so the line sits precisely on the significant level
    // and starts at its real formation point (no averaging, no drag-left from an old swing).
    lP    = array.new_float()
    lName = array.new_string()
    lForm = array.new_int()
    lX2   = array.new_int()
    lPrio = array.new_int()
    lHide = array.new_bool()
    i = 0
    while i < m
        gP    = array.get(tP, i)
        ldName = array.get(tN, i)
        ldPrio = f_prio(ldName)
        ldP    = gP
        ldForm = array.get(tForm, i)
        ldX2   = array.get(tX2, i)
        j = i + 1
        while j < m and (array.get(tP, j) - gP) <= confTol
            nm = array.get(tN, j)
            if f_prio(nm) < ldPrio                            // a more significant level leads
                ldPrio := f_prio(nm)
                ldName := nm
                ldP    := array.get(tP, j)
                ldForm := array.get(tForm, j)
                ldX2   := array.get(tX2, j)
            j := j + 1
        array.push(lP, ldP)
        array.push(lName, ldName)
        array.push(lForm, ldForm)
        array.push(lX2, ldX2)
        array.push(lPrio, ldPrio)
        array.push(lHide, false)
        i := j

    // Naming precedence (wider than the merge band): an Overnight or 1H/4H swing level
    // (prio >= 8) that sits within nameTol of a PRIMARY structural session level (Prev Day /
    // NWOG / Daily 50 / Opening Range / London / Asia, prio <= 6) is fully HIDDEN — line and
    // label — so the session level alone represents that price and you're never reading a
    // derived/swing name for what is really a session high/low. Lines never move or merge here
    // (that stays governed by confTol); the subordinate is simply dropped. Standalone ON/swings
    // (nothing structural nearby, e.g. a genuine distinct overnight high) keep their line+label.
    // 6am is excluded — it's already current-day-only, and shows on its own day.
    nL = array.size(lP)
    if nL > 0 and nameTol > 0
        for a = 0 to nL - 1
            if array.get(lPrio, a) >= 8
                pa = array.get(lP, a)
                for b = 0 to nL - 1
                    if b != a and array.get(lPrio, b) <= 6 and math.abs(pa - array.get(lP, b)) <= nameTol
                        array.set(lHide, a, true)

    // draw one line + label per surviving leader
    if nL > 0
        for a = 0 to nL - 1
            if not array.get(lHide, a)
                avgP  = array.get(lP, a)
                gForm = array.get(lForm, a)
                gX2   = array.get(lX2, a)
                gName = array.get(lName, a)
                leftT = na(firstBarTime) ? gForm : math.max(gForm, firstBarTime)
                ln = line.new(leftT, avgP, gX2, avgP, xloc=xloc.bar_time, color=lvlColor, width=lineWidth)
                array.push(poolL, ln)
                // TradingView "Top/Right" alignment for EVERY label: text right-edge sits at the
                // line's right end, always ABOVE the line. lower_right anchors the text block by
                // its lower-right corner (not its center) so it stops exactly at the line end.
                lb = label.new(gX2, avgP, gName, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_lower_right, color=color.new(color.white, 100), textcolor=lvlColor, size=fSize, text_font_family=LBL_FONT, text_formatting=text.format_bold)
                array.push(poolT, lb)

// ---------------- FVG / gaps (multi-gap store per TF, time-anchored) ----------
// Every open 3-candle gap on each enabled TF is stored & drawn — not just the
// latest. Lifecycle: UNMITIGATED (untested) -> MITIGATED (price entered the
// zone but hasn't crossed it) -> removed (traded fully through, or aged out).
// Unmitigated gaps are the actionable targets, so they read louder; mitigated
// gaps fade into the background but keep a muted TF tag (marked 'Mitigated').
// All gap tags sit in the right margin, outside the box, clear of level labels.
var gTop  = array.new_float()
var gBot  = array.new_float()
var gGform= array.new_int()     // gap origin: CLOSE of the 3rd (confirming) candle (box left edge)
var gBull = array.new_bool()
var gLbl  = array.new_string()
var gMit  = array.new_bool()    // has price entered the zone yet?

f_gapRemoveAt(_i) =>
    array.remove(gTop, _i)
    array.remove(gBot, _i)
    array.remove(gGform, _i)
    array.remove(gBull, _i)
    array.remove(gLbl, _i)
    array.remove(gMit, _i)

// scan one reference TF; push any freshly-completed gap to the store
f_scanFVG(tfStr, lbl, en) =>
    h1 = request.security(SYM, tfStr, high[1], lookahead=LA)
    l1 = request.security(SYM, tfStr, low[1],  lookahead=LA)
    h3 = request.security(SYM, tfStr, high[3], lookahead=LA)
    l3 = request.security(SYM, tfStr, low[3],  lookahead=LA)
    tt = request.security(SYM, tfStr, time[2], lookahead=LA)   // middle-candle time (for newBar detection)
    tc = request.security(SYM, tfStr, time,    lookahead=LA)   // current HTF bar open = close of the 3rd/confirming candle
    newBar = not na(tt) and (na(tt[1]) or tt != tt[1])
    if en and newBar and not na(h3)
        if (l1 - h3) >= fvgMin           // bullish gap (support below)
            array.push(gTop, l1)
            array.push(gBot, h3)
            array.push(gGform, tc)
            array.push(gBull, true)
            array.push(gLbl, lbl)
            array.push(gMit, false)
        else if (l3 - h1) >= fvgMin      // bearish gap (resistance above)
            array.push(gTop, l3)
            array.push(gBot, h1)
            array.push(gGform, tc)
            array.push(gBull, false)
            array.push(gLbl, lbl)
            array.push(gMit, false)
    true

dummy15 = f_scanFVG("15",  "15M Gap", show15)
dummy1H = f_scanFVG("60",  "1H Gap",  show1H)
dummy4H = f_scanFVG("240", "4H Gap",  show4H)

// per-bar: flag mitigation (price entered near edge), drop fully-filled / aged
if array.size(gTop) > 0
    for i = array.size(gTop) - 1 to 0
        formT = array.get(gGform, i)
        top   = array.get(gTop, i)
        bot   = array.get(gBot, i)
        bull  = array.get(gBull, i)
        active = time > formT
        tooOld = maxAgeDays > 0 and (time - formT) > maxAgeMs
        // bullish gap fills top->bot as price drops in; bearish fills bot->top
        entered = active and (bull ? low  <= top : high >= bot)
        filled  = active and (bull ? low  <= bot : high >= top)
        if tooOld or filled
            f_gapRemoveAt(i)
        else if entered and not array.get(gMit, i)
            array.set(gMit, i, true)

// render (last bar only): every open gap within range
var poolBx  = array.new_box()
var poolBxL = array.new_label()
if barstate.islast
    if array.size(poolBx) > 0
        for i = 0 to array.size(poolBx) - 1
            box.delete(array.get(poolBx, i))
    if array.size(poolBxL) > 0
        for i = 0 to array.size(poolBxL) - 1
            label.delete(array.get(poolBxL, i))
    array.clear(poolBx)
    array.clear(poolBxL)
    // Boxes draw per-gap (own TF tint + left edge). Labels group by confluence: gaps
    // that overlap in price are one zone, so instead of letting their tags collide
    // (concentric gaps share a mid) they STACK into a single legend block — one row per
    // gap, smallest TF on top. Pass 1 draws each in-range box and stashes its band;
    // pass 2 sorts by low edge, sweep-merges overlapping bands, emits one stacked tag.
    rTop  = array.new_float()
    rBot  = array.new_float()
    rMit  = array.new_bool()
    rRank = array.new_int()     // 15M=0, 1H=1, 4H=2 (row order within a stacked tag)
    if array.size(gTop) > 0
        for i = 0 to array.size(gTop) - 1
            top = array.get(gTop, i)
            bot = array.get(gBot, i)
            mid = (top + bot) / 2
            if maxDist <= 0 or math.abs(mid - close) <= maxDist
                mit    = array.get(gMit, i)
                lblTxt = array.get(gLbl, i)
                base   = lblTxt == "15M Gap" ? fvg15Col : lblTxt == "1H Gap" ? fvg1HCol : fvg4HCol
                fill   = color.new(base, mit ? fvgMitT : fvgUnmitT)
                bord   = fvgBorder ? color.new(base, 55) : color.new(color.white, 100)
                bx = box.new(array.get(gGform, i), top, time, bot, xloc=xloc.bar_time, border_color=bord, border_width=1, bgcolor=fill)
                array.push(poolBx, bx)
                array.push(rTop, top)
                array.push(rBot, bot)
                array.push(rMit, mit)
                array.push(rRank, lblTxt == "15M Gap" ? 0 : lblTxt == "1H Gap" ? 1 : 2)

    // sort the collected bands by LOW edge ascending, so overlapping gaps sit adjacent
    nb = array.size(rTop)
    if nb > 1
        for a = 0 to nb - 2
            mn = a
            for b = a + 1 to nb - 1
                if array.get(rBot, b) < array.get(rBot, mn)
                    mn := b
            if mn != a
                fB = array.get(rBot, a)
                array.set(rBot, a, array.get(rBot, mn))
                array.set(rBot, mn, fB)
                fT = array.get(rTop, a)
                array.set(rTop, a, array.get(rTop, mn))
                array.set(rTop, mn, fT)
                fM = array.get(rMit, a)
                array.set(rMit, a, array.get(rMit, mn))
                array.set(rMit, mn, fM)
                fR = array.get(rRank, a)
                array.set(rRank, a, array.get(rRank, mn))
                array.set(rRank, mn, fR)

    // one linear sweep tags each band with a cluster id: a band joins the running
    // cluster when its low sits within confTol of the cluster's high (overlap / touch),
    // folding nested + concentric gaps together; otherwise it opens a new cluster.
    gid  = array.new_int()
    ngrp = 0
    if nb > 0
        cur    = 0
        runTop = array.get(rTop, 0)
        array.push(gid, 0)
        if nb > 1
            for i = 1 to nb - 1
                if array.get(rBot, i) <= runTop + confTol
                    runTop := math.max(runTop, array.get(rTop, i))
                else
                    cur    := cur + 1
                    runTop := array.get(rTop, i)
                array.push(gid, cur)
        ngrp := cur + 1

    // emit one stacked legend per cluster. The rank scan (0->2) naturally lays rows out
    // 15M -> 1H -> 4H; each row keeps its own mitigation tag (honoring fvgLabelMit per
    // row), a fully-mitigated cluster reads muted, and the extent spans every member so
    // the block centers on the whole zone.
    for gg = 0 to ngrp - 1
        float uTop = na
        float uBot = na
        txt    = ""
        allMit = true
        anyRow = false
        for rnk = 0 to 2
            for i = 0 to nb - 1
                if array.get(gid, i) == gg and array.get(rRank, i) == rnk
                    uTop := na(uTop) ? array.get(rTop, i) : math.max(uTop, array.get(rTop, i))
                    uBot := na(uBot) ? array.get(rBot, i) : math.min(uBot, array.get(rBot, i))
                    mt = array.get(rMit, i)
                    if (not mt) or fvgLabelMit
                        nm  = rnk == 0 ? "15M Gap" : rnk == 1 ? "1H Gap" : "4H Gap"
                        row = nm + (mt ? "  ·  Mitigated" : "")
                        txt := txt == "" ? row : txt + "\n" + row
                        allMit := allMit and mt
                        anyRow := true
        if anyRow
            tc = color.new(lvlColor, allMit ? 45 : 25)
            lb = label.new(time, (uTop + uBot) / 2, txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(color.white, 100), textcolor=tc, size=fSize, text_font_family=LBL_FONT, text_formatting=text.format_bold)
            array.push(poolBxL, lb)
````
