# $$$ SESSION DIGGA $$$

- url: https://www.tradingview.com/script/u3dClip7-SESSION-DIGGA/
- type: indicator
- pine_id: PUB;f55bb2f7f5a440b19667bedb50710fe5
- version: 1.0

## Description

[b]$$$ SESSION DIGGA $$$ v1.0[/b]

[b]A session and liquidity tool that tells you how often each pool actually gets taken on your chart, and which session takes it.[/b]

Everyone marks the Asia high, the London low, yesterday's high. Everyone says liquidity sits there and price will come for it. Sometimes it does, sometimes it never comes back. SESSION DIGGA counts. Every pool it draws, it follows for the next three sessions and writes down whether price took it and in which session. Next to every live pool you see that pool's record on your own chart's history. No opinions, just what your chart has done.

[b]What it draws[/b]

[b]Sessions.[/b] Asia, London and New York, each in its own colour. A solid line along the bottom of the chart marks where each session starts and ends, with its name just above it. Dotted vertical lines mark each session open.

[b]Liquidity pools.[/b] The high and low of every session, the previous day's high and low (PDH / PDL), and, if you switch them on, equal highs and lows. Each pool is a line from where it was made, and it stays on the chart while it is still live.

[b]Sweep rings.[/b] When price takes a pool, a glowing marker appears on the exact spot, a solid core fading out to a faint halo in the pool's colour, and the line goes away. Hover over the marker to see which pool was taken and in which session ("AS L taken · London"). The last 20 sweeps are kept, so you can see at a glance where the liquidity was collected today and yesterday.

[b]Session volume profiles.[/b] When a session closes, its volume profile is drawn over it: the point of control (POC) as a line, the value area (70% of the volume) in the session's colour, everything outside it in grey. The last two session days by default, so the chart stays clean.

[b]Reading the numbers[/b]

Next to every live pool, on the right edge of the chart:

[i]● LDN H  77% · NY[/i]

For example: London highs on this chart were taken within three sessions 77% of the time, and the session that took them most often was New York. A "?" after the number means fewer than 20 pools of that kind behind it, so take it lightly. Hover over the label for the exact count and a range: "57 of 74 · 95% range 66–85%". The true number is somewhere in that range, and it narrows as the chart's history grows.

The panel, a toggle in the settings, puts all of them in one table: every pool type, its percentage and how many pools it counted.

[b]What it found on gold[/b]

On XAUUSD 5m with about 74 session days of history (Athens time, default sessions):

London highs 77% and lows 73%. New York 69% and 64%. Asia 58% and 64%. PDH and PDL only 50% and 56%. Equal highs and lows around 90%.

Three things worth noticing. First, a pool is not a magnet. Half of the previous day's highs were still standing three sessions later. Second, the London session's highs and lows were taken more often (73–77%) than Asia's (58–64%). Third, equal highs and lows get taken nine times out of ten, but they also sit much closer to price than a session extreme does. A high number there does not make them a better trade, only a more frequent one.

Your chart will show different numbers. That is the point: run it on your symbol, your timeframe and your session times, and read your own record before you trust anyone's.

[b]How to use it[/b]

1. Add it to a chart of 30 minutes or less. Every session edge must fall on a bar edge (5m and 15m always work with the default sessions).
2. Set your time zone and session times in the settings. The defaults are in Athens time: Asia 02:00–10:00, London 10:00–15:30, New York 15:30–23:00. Daylight saving is handled by the time zone.
3. Scroll left once so the chart loads its history. The more history, the better the numbers.
4. Read the right edge for the live pools and their record, the rings for what was just taken.
5. Set the alerts if you like: previous day's high or low taken, and Asia high or low taken.

[b]Settings in short[/b]

[b]Sessions:[/b] time zone, the three session windows and their colours.
[b]Pools:[/b] which pools to show, equal highs / lows on or off, how many sessions a pool stays alive (3), show taken pools, how many sweep rings to keep (20) and their size, the PDH / PDL and equal high / low colours.
[b]Profiles:[/b] on or off, how many session days (2), rows (50), width, the colour outside the value area. With many rows fewer sessions are kept (100 rows: the last 5 sessions).
[b]Display:[/b] how many session days of drawings, session open lines, the session line and names, the panel, text size.

[b]A few honest notes[/b]

The numbers come from your chart's loaded history, so a few months give a much better picture than a few weeks. A pool counts as taken when price trades through it by any amount, a wick included. The tool does not say what happened next. The session times are fixed in your time zone, so in the weeks when Europe and the US change their clocks on different dates, New York starts an hour off. On spot gold and forex the volume in the profiles is the broker's tick volume, not traded contracts. And a percentage is what has happened, not what will.

[b]Important[/b]

This tool is a technical assistant, not a financial advisor. It is designed for traders who understand technical analysis. A percentage is a measured frequency in past data, not a forecast. Comprehensive market knowledge and independent validation are required before making any trading decision. PINE DIGGA Indicators shall not be held liable for any trading losses or financial damages.

© PINEDIGGA | October 2026

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PINEDIGGA

//@version=6
//@$$$ SESSION DIGGA $$$ (October 2026 - ver1.0)
// Where does the liquidity sit, and which session takes it?
//   • Asia / London / New York sessions, their highs and lows as liquidity pools, PDH / PDL and
//     (optional) equal highs / lows. Each pool type carries the share taken within three sessions,
//     counted on this chart's own history, with n and a Wilson 95 % range.
//   • Sweep rings: four concentric filled discs, faint halo to solid core, in the pool's colour, where each of the last N pools was taken.
//   • A volume profile per session, drawn when the session closes (last 2 session days by default).
//   • Taken pools are hidden by default; an input keeps their lines.
//   • Reference implementation and tests: scripts/session_digga_ref.py in the PINE DIGGA repo
//     (spec docs/specs/2026-10-14-session-digga-design.md). This file transcribes its session, pool
//     and profile parts (872ea65). v1 ships without the reference's two London setups (spec,
//     "Amended 2026-10-16"); they stay documented there for a later tool.
//
// Order of events per confirmed chart bar, as in the reference (Engine.setup_bar, then
// Engine.chart_bar_close). The engine runs on the chart bars themselves: one "setup bar" is the
// chart bar, and no intrabars are requested.
//   1. the chart bar → session change (close session: expire pools, births, profile; start day:
//      PDH / PDL births) → running session H/L → day H/L → pool takes
//   2. the chart bar's close → session bars for the profile, equal-high / low pivots and pools
// Chart bars never straddle a session edge (timeframe guard below), so the pool counts are the
// same as the reference's bar-by-bar counts.
indicator("$$$ SESSION DIGGA $$$ ver1.0", overlay = true, max_lines_count = 500, max_labels_count = 500,
     max_boxes_count = 500, max_bars_back = 210)

// ══════════════════════════════════════════════════════════════════════
// 🕒 SESSIONS
// ══════════════════════════════════════════════════════════════════════
grpSes = "🕒 Sessions"
tz     = input.string("Europe/Athens", "Timezone", options = ["Europe/Athens", "Europe/London", "Europe/Berlin",
     "America/New_York", "America/Chicago", "Asia/Tokyo", "Asia/Singapore", "Asia/Dubai", "Australia/Sydney", "UTC"],
     group = grpSes, tooltip = "Named zone: daylight saving is handled.", display = display.none)
asiaIn = input.session("0200-1000", "Asia  ",   group = grpSes, inline = "a", display = display.none)
C_ASIA = input.color(color.rgb(139, 108, 240), "", group = grpSes, inline = "a", display = display.none)
ldnIn  = input.session("1000-1530", "London", group = grpSes, inline = "l", display = display.none)
C_LDN  = input.color(color.rgb(63, 169, 245),  "", group = grpSes, inline = "l", display = display.none)
nyIn   = input.session("1530-2300", "NY  ",     group = grpSes, inline = "n", display = display.none)
C_NY   = input.color(color.rgb(240, 138, 60),  "", group = grpSes, inline = "n",
     tooltip = "Local time in the zone above, start before end within one day. Start included, end excluded.", display = display.none)
// The titles carry em / en spaces (U+2003 / U+2002), which TradingView does not trim, so
// the three time pickers line up under "London".
// "0200-1000" → 200 and 1000 (HHMM as an int, as the rest of the script uses them)
f_sesPart(string x, int i) => int(str.tonumber(str.substring(x, 5 * i, 5 * i + 4)))
int asiaS = f_sesPart(asiaIn, 0)
int asiaE = f_sesPart(asiaIn, 1)
int ldnS  = f_sesPart(ldnIn, 0)
int ldnE  = f_sesPart(ldnIn, 1)
int nyS   = f_sesPart(nyIn, 0)
int nyE   = f_sesPart(nyIn, 1)

// ══════════════════════════════════════════════════════════════════════
// 💧 POOLS
// ══════════════════════════════════════════════════════════════════════
grpPool   = "💧 Pools"
showAs    = input.bool(true,  "Asia H/L",   group = grpPool, inline = "sp", display = display.none)
showLdn   = input.bool(true,  "London H/L", group = grpPool, inline = "sp", display = display.none)
showNy    = input.bool(true,  "NY H/L",     group = grpPool, inline = "sp", display = display.none)
showPD    = input.bool(true,  "PDH / PDL", group = grpPool, inline = "pd", display = display.none)
C_PD      = input.color(color.rgb(232, 184, 74), "", group = grpPool, inline = "pd",
     tooltip = "High and low of the previous session day (Asia open to Asia open).", display = display.none)
eqOn      = input.bool(false, "Equal highs / lows", group = grpPool, inline = "eq", display = display.none)
C_EQ      = input.color(color.rgb(201, 204, 214), "", group = grpPool, inline = "eq",
     tooltip = "Two 3/3 pivots within 0.10 ATR inside 100 bars.", display = display.none)
horizon   = input.int(3, "Alive for (sessions)", minval = 1, maxval = 9, group = grpPool,
     tooltip = "A pool not taken within this many sessions counts as not taken.", display = display.none)
showTaken = input.bool(false, "Show taken pools", group = grpPool,
     tooltip = "Off: a pool's line goes when it is taken or expires.", display = display.none)
ringN     = input.int(20, "Sweep rings: last N", minval = 0, maxval = 30, group = grpPool,
     tooltip = "Rings where the last N pools were taken. 0 = off.", display = display.none)
ringSz    = input.string("Medium", "Sweep ring size", options = ["Small", "Medium", "Large"], group = grpPool, display = display.none)

// ══════════════════════════════════════════════════════════════════════
// 📊 PROFILES
// ══════════════════════════════════════════════════════════════════════
grpProf  = "📊 Profiles"
showProf = input.bool(true, "Session volume profile", group = grpProf,
     tooltip = "Drawn when the session closes. Spot gold volume is tick volume.", display = display.none)
profDays = input.int(2, "Profiles: last N session days", minval = 1, maxval = 20, group = grpProf,
     tooltip = "3 sessions a day. With many rows fewer are kept: at most 500 / rows sessions (100 rows → 5).", display = display.none)
rows     = input.int(50, "Rows", minval = 8, maxval = 100, group = grpProf, display = display.none)
C_VAOUT  = input.color(color.rgb(120, 123, 134), "Outside value area", group = grpProf, display = display.none)
profW    = input.float(0.30, "Width (share of session)", minval = 0.05, maxval = 1.0, step = 0.05, group = grpProf, display = display.none)

// ══════════════════════════════════════════════════════════════════════
// 🎨 DISPLAY
// ══════════════════════════════════════════════════════════════════════
grpDisp   = "🎨 Display"
days      = input.int(5, "Draw the last N session days", minval = 1, maxval = 20, group = grpDisp,
     tooltip = "Counted in Asia opens. Drawings only: stats use all history.", display = display.none)
showSesLn = input.bool(true, "Session open lines", group = grpDisp, display = display.none)
showBand  = input.bool(true, "Session line and names", group = grpDisp,
     tooltip = "A line along the bottom of the pane under each session, its name above it.", display = display.none)
showPanel = input.bool(false, "Panel", group = grpDisp, display = display.none)
txtIn     = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = grpDisp, display = display.none)
TXT       = txtIn == "Small" ? size.small : txtIn == "Large" ? size.large : size.normal

// ── constants and colours ────────────────────────────────────────────
int   EQ_LEN  = 3
float EQ_TOL  = 0.10
int   EQ_LB   = 100
int   ATR_LEN = 14
int   PIV_CAP = 50      // PivotBook.CAP
int   LOW_N   = 20      // fewer samples than this → faded with "?"
int   MAX_TF  = 1800    // MAX_CHART_TF, seconds

color C_GOLD  = color.rgb(232, 184, 74)    // title and notice
color C_GREY  = color.rgb(201, 204, 214)   // panel counts

var array<string> POOL_NAMES = array.from("AS H", "AS L", "LDN H", "LDN L", "NY H", "NY L", "PDH", "PDL", "EQH", "EQL")
var array<string> SES_NAMES  = array.from("Asia", "London", "NY", "off")

// ══════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════
// 1530 → 930 minutes after midnight. math.floor: in v6 int / int keeps the fraction.
f_hhmm(int x) => math.floor(x / 100) * 60 + x % 100

int A0 = f_hhmm(asiaS)
int A1 = f_hhmm(asiaE)
int L0 = f_hhmm(ldnS)
int L1 = f_hhmm(ldnE)
int N0 = f_hhmm(nyS)
int N1 = f_hhmm(nyE)

// Session of a bar by its open time: 0 Asia, 1 London, 2 NY, 3 off (reference: session_of).
f_sessOf(int t) =>
    int m = hour(t, tz) * 60 + minute(t, tz)
    m >= A0 and m < A1 ? 0 : m >= L0 and m < L1 ? 1 : m >= N0 and m < N1 ? 2 : 3

// Sessions must sit inside one day (the reference has no midnight wrap) and be valid HHMM.
f_hhOk(int x) => x % 100 < 60
bool sesOk = f_hhOk(asiaS) and f_hhOk(asiaE) and f_hhOk(ldnS) and f_hhOk(ldnE) and f_hhOk(nyS) and f_hhOk(nyE)
     and A0 < A1 and L0 < L1 and N0 < N1

// Drawing windows. The exact cut is in session days (Asia opens): every drawing is tagged with
// its session day and f_prune deletes the old ones at each new day. This calendar pre-filter
// (2N + 4 days covers N session days on 5-day weeks with holidays) only saves creating objects
// deep in history that would be deleted anyway.
f_inWinN(int t, int n) => t >= last_bar_time - (2 * n + 4) * 86400000
f_inWin(int t) => f_inWinN(t, days)

// Profiles: the last 3 × profDays sessions, at most rows boxes each, kept under the 500-box
// limit. Counted in sessions, not days, so at least the last closed session always shows.
int PROF_SES = math.min(3 * profDays, math.floor(500 / rows))

f_sesCol(int s) => s == 0 ? C_ASIA : s == 1 ? C_LDN : C_NY

f_poolCol(int k) => k <= 1 ? C_ASIA : k <= 3 ? C_LDN : k <= 5 ? C_NY : k <= 7 ? C_PD : C_EQ

f_poolShown(int k) => k <= 1 ? showAs : k <= 3 ? showLdn : k <= 5 ? showNy : k <= 7 ? showPD : eqOn

// Drawing registry: object + session day it belongs to. Display only.
// gLn / gLb follow the `days` window (tagged by day); gBx and gPl (profile boxes and POC lines)
// follow PROF_SES (tagged by session number).
var array<line>  gLn  = array.new_line()
var array<int>   gLnD = array.new_int()
var array<label> gLb  = array.new_label()
var array<int>   gLbD = array.new_int()
var array<box>   gBx  = array.new_box()
var array<int>   gBxD = array.new_int()
var array<line>  gPl  = array.new_line()
var array<int>   gPlD = array.new_int()

// Sweep rings: 3 labels per take, oldest first. Not in the registry: they live until newer
// takes push them out (ringN groups kept), whatever the drawing window.
var array<label> RINGS = array.new_label()

f_keepLn(int day, line ln) =>
    if not na(ln)
        gLn.push(ln)
        gLnD.push(day)
    ln

f_keepLb(int day, label lb) =>
    if not na(lb)
        gLb.push(lb)
        gLbD.push(day)
    lb

f_keepBx(int day, box bx) =>
    if not na(bx)
        gBx.push(bx)
        gBxD.push(day)
    bx

f_keepPl(int day, line ln) =>
    if not na(ln)
        gPl.push(ln)
        gPlD.push(day)
    ln

// Delete lines / labels of days before `keepFrom`.
f_prune(int keepFrom) =>
    int n1 = gLn.size()
    if n1 > 0
        for i = n1 - 1 to 0
            if gLnD.get(i) < keepFrom
                line.delete(gLn.remove(i))
                gLnD.remove(i)
    int n2 = gLb.size()
    if n2 > 0
        for i = n2 - 1 to 0
            if gLbD.get(i) < keepFrom
                label.delete(gLb.remove(i))
                gLbD.remove(i)
    true

// Delete profile boxes and POC lines of sessions before `boxFrom`.
f_pruneProf(int boxFrom) =>
    int n3 = gBx.size()
    if n3 > 0
        for i = n3 - 1 to 0
            if gBxD.get(i) < boxFrom
                box.delete(gBx.remove(i))
                gBxD.remove(i)
    int n4 = gPl.size()
    if n4 > 0
        for i = n4 - 1 to 0
            if gPlD.get(i) < boxFrom
                line.delete(gPl.remove(i))
                gPlD.remove(i)
    true

// Four concentric filled discs at a taken pool, outermost first so the smaller ones sit on top:
// four steps down the size scale from the "Sweep ring size" input (Large: huge → small), never
// below tiny; transparency 85 / 65 / 40 / 0, a faint halo to a solid core.
// label.style_circle is a shape centred on (t, y); "●" text was not (each size sat on its own
// baseline). Only the last ringN takes are kept (RING_N labels each).
int RING_N = 4
int RING_TOP = ringSz == "Large" ? 4 : ringSz == "Medium" ? 3 : 2   // index of the outer ring's size
f_szAt(int i) => i <= 0 ? size.tiny : i == 1 ? size.small : i == 2 ? size.normal : i == 3 ? size.large : size.huge
f_rings(int t, float y, int k, int s) =>
    color  c   = f_poolCol(k)
    string tip = POOL_NAMES.get(k) + " taken · " + SES_NAMES.get(s)
    for r = RING_N - 1 to 0
        RINGS.push(label.new(t, y, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_circle,
             color = color.new(c, r == 3 ? 85 : r == 2 ? 65 : r == 1 ? 40 : 0), textcolor = color.new(c, 100),
             size = f_szAt(RING_TOP - 3 + r), tooltip = tip))
    while RINGS.size() > RING_N * ringN
        label.delete(RINGS.shift())
    true

// Wilson score interval at 95 %; n = 0 → [0, 1]
f_wilson(int s, int n) =>
    float lo = 0.0
    float hi = 1.0
    if n > 0
        float p      = s / float(n)
        float z2     = 1.96 * 1.96
        float denom  = 1 + z2 / n
        float centre = (p + z2 / (2 * n)) / denom
        float half   = 1.96 * math.sqrt(p * (1 - p) / n + z2 / (4.0 * n * n)) / denom
        lo := centre - half
        hi := centre + half
    [lo, hi]

f_rate(int s, int n) => n == 0 ? "—" : str.tostring(100.0 * s / n, "#") + "%" + (n < LOW_N ? "?" : "")

f_tip(int s, int n) =>
    [lo, hi] = f_wilson(s, n)
    n == 0 ? "no history yet" : str.tostring(s) + " of " + str.tostring(n) + " · 95% range " + str.tostring(100 * lo, "#") + "–" + str.tostring(100 * hi, "#") + "%"

// Volume spread over the rows each bar covers, by overlap; fills `tot` (rows long, zeros) and
// returns [bottom, step, POC row, POC price]. Reference: profile(). Same row bottom expression
// `lo + j * step`, same bar order, same lowest-row tie rule (indexof(max) = first max).
f_profile(array<float> hs, array<float> ls, array<float> vs, array<float> tot) =>
    float lo   = ls.min()
    float span = hs.max() - lo
    float step = 0.0
    int   nb   = hs.size()
    if span <= 0
        tot.set(0, vs.sum())
    else if nb > 0
        step := span / rows
        for i = 0 to nb - 1
            float h = hs.get(i)
            float l = ls.get(i)
            float v = vs.get(i)
            float r = h - l
            int r0 = math.min(rows - 1, int((l - lo) / step))
            int r1 = math.min(rows - 1, int((h - lo) / step))
            for j = r0 to r1    // l ≤ h, so r0 ≤ r1 and the loop never counts down
                if r > 0
                    float rl = lo + j * step
                    tot.set(j, tot.get(j) + v * math.max(0.0, math.min(h, rl + step) - math.max(l, rl)) / r)
                else
                    tot.set(j, tot.get(j) + v)
    int poc = tot.indexof(tot.max())
    [lo, step, poc, lo + (poc + 0.5) * step]

// ══════════════════════════════════════════════════════════════════════
// ENGINE STATE (reference: Engine.__init__, session / pool / EQ parts)
// ══════════════════════════════════════════════════════════════════════
type E
    int   prevS   = -1        // −1 = None: no bar seen yet
    bool  haveDay = false
    float dayHi   = na
    float dayLo   = na
    int   dayHiT  = na        // display only: where the day's high / low printed (PDH/PDL lines start there)
    int   dayLoT  = na
    float pdh     = na
    float pdl     = na
    // running session (the reference's `ses` dict: high, low and where they printed, start)
    float sH  = na
    float sL  = na
    int   sTH = na
    int   sTL = na
    int   sT0 = na
    // closed chart bars of the running session (ses_cb[s]; see the note at the chart-bar close)
    array<float> cbH
    array<float> cbL
    array<float> cbV
    // live pools (PoolBook.live)
    array<int>   plK
    array<float> plP
    array<bool>  plHi
    array<int>   plLeft
    array<line>  plLn
    // counters: PoolBook n / s / by, same index layout as the reference
    array<int> poolN
    array<int> poolS
    array<int> poolBy
    // PivotBook(EQ_LEN, take_prune=False): price, pivot bar index, used
    array<float> eqH
    array<int>   eqHi
    array<bool>  eqHu
    array<float> eqL
    array<int>   eqLi
    array<bool>  eqLu
    // session-day number for the drawing windows
    int dayNo = 0
    int sesNo = 0           // closed sessions, for the profile window
    // alert flags, reset every script execution
    bool aPD = false
    bool aAs = false

var E eng = E.new(cbH = array.new_float(), cbL = array.new_float(), cbV = array.new_float(),
     plK = array.new_int(), plP = array.new_float(), plHi = array.new_bool(), plLeft = array.new_int(), plLn = array.new_line(),
     poolN = array.new_int(10, 0), poolS = array.new_int(10, 0), poolBy = array.new_int(40, 0),
     eqH = array.new_float(), eqHi = array.new_int(), eqHu = array.new_bool(),
     eqL = array.new_float(), eqLi = array.new_int(), eqLu = array.new_bool())

// ══════════════════════════════════════════════════════════════════════
// POOLS (reference: PoolBook)
// ══════════════════════════════════════════════════════════════════════
// mid: born inside a running session (EQH/EQL), whose own close is not one of the horizon's sessions.
f_birth(E e, int k, float price, bool isHi, int t0, int tNow, bool mid) =>
    e.plK.push(k)
    e.plP.push(price)
    e.plHi.push(isHi)
    e.plLeft.push(mid ? horizon + 1 : horizon)
    line ln = na
    if f_poolShown(k) and f_inWin(t0)
        ln := line.new(t0, price, tNow, price, xloc = xloc.bar_time, color = color.new(f_poolCol(k), 25), width = 1)
    e.plLn.push(ln)

// A live pool's line is never pruned. Once the pool is gone (taken or expired) its line is
// deleted, or with "Show taken pools" it joins today's drawings and is pruned with them.
f_removePool(E e, int i) =>
    e.plK.remove(i)
    e.plP.remove(i)
    e.plHi.remove(i)
    e.plLeft.remove(i)
    line ln = e.plLn.remove(i)
    if showTaken
        f_keepLn(e.dayNo, ln)        // na-safe
    if not showTaken and not na(ln)
        line.delete(ln)
    true

// PoolBook.session_closed
f_sessionClosed(E e) =>
    int n = e.plK.size()
    if n > 0
        for i = n - 1 to 0
            int left = e.plLeft.get(i) - 1
            if left <= 0
                int k = e.plK.get(i)
                e.poolN.set(k, e.poolN.get(k) + 1)
                f_removePool(e, i)
            else
                e.plLeft.set(i, left)
    true

// PoolBook.bar
f_poolsBar(E e, float h, float l, int s, int t) =>
    int n = e.plK.size()
    if n > 0
        for i = n - 1 to 0
            float p = e.plP.get(i)
            if e.plHi.get(i) ? h >= p : l <= p
                int k = e.plK.get(i)
                e.poolN.set(k, e.poolN.get(k) + 1)
                e.poolS.set(k, e.poolS.get(k) + 1)
                e.poolBy.set(k * 4 + s, e.poolBy.get(k * 4 + s) + 1)
                line ln = e.plLn.get(i)
                if not na(ln)
                    line.set_x2(ln, t)       // with "Show taken pools" the line ends at the take bar
                if k == 6 or k == 7
                    e.aPD := true
                if k <= 1
                    e.aAs := true
                // display only: sweep rings, near the right edge only so history doesn't churn objects
                if ringN > 0 and f_poolShown(k) and f_inWin(t)
                    f_rings(t, p, k, s)
                f_removePool(e, i)
    true

// ══════════════════════════════════════════════════════════════════════
// SESSIONS AND DAYS (reference: Engine._close_session, _start_day, setup_bar)
// ══════════════════════════════════════════════════════════════════════
// At most `rows` boxes; f_pruneProf keeps the last PROF_SES sessions, so ≤ PROF_SES × rows ≤ 500.
f_drawProfile(int day, float lo, float step, array<float> tot, int poc, float pocP, int t0, int t1, color c) =>
    if step > 0
        float mx = tot.max()
        int w = int((t1 - t0) * profW)
        // display only: value area = 70 % of the volume, grown from the POC towards the larger
        // neighbouring row; rows outside it are drawn neutral grey
        int vaLo = poc
        int vaHi = poc
        float acc = tot.get(poc)
        float goal = 0.70 * tot.sum()
        while acc < goal and (vaLo > 0 or vaHi < rows - 1)
            float up = vaHi < rows - 1 ? tot.get(vaHi + 1) : -1.0
            float dn = vaLo > 0 ? tot.get(vaLo - 1) : -1.0
            if up >= dn
                vaHi += 1
                acc += up
            else
                vaLo -= 1
                acc += dn
        for j = 0 to rows - 1
            float v = tot.get(j)
            if v > 0 and mx > 0
                color cj = j >= vaLo and j <= vaHi ? c : C_VAOUT
                f_keepBx(day, box.new(t0, lo + (j + 0.92) * step, t0 + int(w * v / mx), lo + (j + 0.08) * step, xloc = xloc.bar_time,
                     border_color = color.new(c, 100), bgcolor = color.new(cj, j == poc ? 10 : int(80 - 50 * v / mx))))
        f_keepPl(day, line.new(t0, pocP, t1, pocP, xloc = xloc.bar_time, color = color.new(c, 15), style = line.style_dashed))
    true

// _close_session(s, t): expire pools, birth the session's H/L, draw its profile.
f_closeSession(E e, int s, int t) =>
    f_sessionClosed(e)
    f_birth(e, 2 * s, e.sH, true, e.sTH, t, false)
    f_birth(e, 2 * s + 1, e.sL, false, e.sTL, t, false)
    // Built from the session's closed chart bars, i.e. those before the current one. Display
    // only now (no setup reads the POC), so it is computed only when it will be drawn.
    e.sesNo := e.sesNo + 1
    if showProf and e.cbH.size() > 0 and f_inWinN(e.sT0, profDays)
        array<float> tot = array.new_float(rows, 0.0)
        [lo, step, pocI, pocP] = f_profile(e.cbH, e.cbL, e.cbV, tot)
        f_drawProfile(e.sesNo, lo, step, tot, pocI, pocP, e.sT0, t, f_sesCol(s))
        f_pruneProf(e.sesNo - PROF_SES + 1)
    e.cbH.clear()
    e.cbL.clear()
    e.cbV.clear()
    true

// _start_day(t)
f_startDay(E e, int t) =>
    // display only: a new session day; keep the last `days` of drawings
    e.dayNo := e.dayNo + 1
    f_prune(e.dayNo - days + 1)
    if e.haveDay
        e.pdh := e.dayHi
        e.pdl := e.dayLo
        f_birth(e, 6, e.pdh, true, e.dayHiT, t, false)
        f_birth(e, 7, e.pdl, false, e.dayLoT, t, false)
    e.haveDay := true
    e.dayHi := na
    e.dayLo := na
    true

// Engine.setup_bar, run on the chart bar: session change → day → session H/L → day H/L → pool takes.
f_bar(E e, int t, float h, float l) =>
    int s = f_sessOf(t)
    if s != e.prevS
        if e.prevS >= 0 and e.prevS <= 2
            f_closeSession(e, e.prevS, t)
        if s == 0                   // a new day starts on the first Asia bar after a bar that was not Asia
            f_startDay(e, t)
        if s != 3
            e.sH  := h
            e.sL  := l
            e.sTH := t
            e.sTL := t
            e.sT0 := t
            if f_inWin(t) and showSesLn   // session open: dotted vertical line
                f_keepLn(e.dayNo, line.new(t, h, t, h + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both,
                     color = color.new(f_sesCol(s), 25), width = 1, style = line.style_dotted))
    else if s != 3
        if h > e.sH
            e.sH  := h
            e.sTH := t
        if l < e.sL
            e.sL  := l
            e.sTL := t
    if e.haveDay
        if na(e.dayHi) or h > e.dayHi
            e.dayHi  := h
            e.dayHiT := t
        if na(e.dayLo) or l < e.dayLo
            e.dayLo  := l
            e.dayLoT := t
    f_poolsBar(e, h, l, s, t)
    e.prevS := s
    true

// Strict n/n pivot confirmed on this chart bar (pivot bar = n bars back); na when none.
// bar_index ≥ 2n is the reference's k − n ≥ 0 (its chart index starts at the first chart bar, as bar_index).
f_pivotHigh(int n) =>
    float ph = high[n]
    bool ok = bar_index >= 2 * n
    if ok
        for k = 1 to n
            if high[n - k] >= ph or high[n + k] >= ph
                ok := false
    ok ? ph : na

f_pivotLow(int n) =>
    float pl = low[n]
    bool ok = bar_index >= 2 * n
    if ok
        for k = 1 to n
            if low[n - k] <= pl or low[n + k] <= pl
                ok := false
    ok ? pl : na

// eq_match: closest earlier unused pivot within tol and EQ_LB bars (ties → the most recent); −1 if none.
// The new pivot is already in the list (index idx) and is skipped, as x[1] == new[1] in the reference.
f_eqMatch(array<float> ps, array<int> ix, array<bool> us, float p, int idx, float tol) =>
    int   best = -1
    float bd   = na
    int   n    = ps.size()
    if n > 0
        for i = 0 to n - 1
            int xi = ix.get(i)
            if xi != idx and not us.get(i) and idx - xi <= EQ_LB
                float dd = math.abs(ps.get(i) - p)
                if dd <= tol
                    bool better = best < 0
                    if not better
                        better := dd < bd or (dd == bd and xi > ix.get(best))
                    if better
                        best := i
                        bd   := dd
    best

// ══════════════════════════════════════════════════════════════════════
// TIMEFRAME GUARD (reference: chart_tf_ok)
// ══════════════════════════════════════════════════════════════════════
// At most 30m, every session edge on a chart-bar edge, and the zone's UTC offset (winter and
// summer) a multiple of the timeframe, since chart bars start on UTC multiples of it.
int chartSec = timeframe.in_seconds()
f_edgeOk(int x) => (f_hhmm(x) * 60) % chartSec == 0
int offJan = timestamp("UTC", 2026, 1, 1, 0, 0, 0) - timestamp(tz, 2026, 1, 1, 0, 0, 0)   // ms
int offJul = timestamp("UTC", 2026, 7, 1, 0, 0, 0) - timestamp(tz, 2026, 7, 1, 0, 0, 0)
bool tfOk = chartSec > 0 and chartSec <= MAX_TF and f_edgeOk(asiaS) and f_edgeOk(asiaE) and f_edgeOk(ldnS)
     and f_edgeOk(ldnE) and f_edgeOk(nyS) and f_edgeOk(nyE)
     and offJan % (chartSec * 1000) == 0 and offJul % (chartSec * 1000) == 0
// Everything runs only with a valid timeframe and valid session times; otherwise one notice.
bool runOk = tfOk and sesOk

// ══════════════════════════════════════════════════════════════════════
// RUN — one confirmed chart bar at a time
// ══════════════════════════════════════════════════════════════════════
float atrV = ta.atr(ATR_LEN)       // equal highs / lows tolerance only
float phE  = f_pivotHigh(EQ_LEN)
float plE  = f_pivotLow(EQ_LEN)

eng.aPD := false
eng.aAs := false

if runOk and barstate.isconfirmed
    // 1. the chart bar as the setup bar (Engine.setup_bar)
    f_bar(eng, time, high, low)

    // 2. Engine.chart_bar_close. ATR is ta.atr above (same RMA seeded by the SMA of the first 14 TRs).
    int sNow = f_sessOf(time)
    // ses_cb[s]: one list suffices, since a chart bar of session s is only pushed while s runs
    // (chart bars never straddle a session edge) and the list is emptied when s closes.
    if sNow != 3
        eng.cbH.push(high)
        eng.cbL.push(low)
        eng.cbV.push(na(volume) ? 1.0 : volume)
    // eqs.chart_bar (take_prune False): add, cap; pivots leave only through the cap
    int pIdx = bar_index - EQ_LEN
    if not na(phE)
        eng.eqH.push(phE)
        eng.eqHi.push(pIdx)
        eng.eqHu.push(false)
    if not na(plE)
        eng.eqL.push(plE)
        eng.eqLi.push(pIdx)
        eng.eqLu.push(false)
    if eng.eqH.size() > PIV_CAP
        eng.eqH.shift()
        eng.eqHi.shift()
        eng.eqHu.shift()
    if eng.eqL.size() > PIV_CAP
        eng.eqL.shift()
        eng.eqLi.shift()
        eng.eqLu.shift()
    // equal highs / lows; a pool born inside a session gets horizon + 1 closes
    if eqOn and not na(atrV)
        float tolEq = EQ_TOL * atrV
        if not na(phE)
            int m = f_eqMatch(eng.eqH, eng.eqHi, eng.eqHu, phE, pIdx, tolEq)
            if m >= 0
                eng.eqHu.set(m, true)
                eng.eqHu.set(eng.eqHu.size() - 1, true)
                f_birth(eng, 8, math.max(eng.eqH.get(m), phE), true, time, time, sNow != 3)
        if not na(plE)
            int m = f_eqMatch(eng.eqL, eng.eqLi, eng.eqLu, plE, pIdx, tolEq)
            if m >= 0
                eng.eqLu.set(m, true)
                eng.eqLu.set(eng.eqLu.size() - 1, true)
                f_birth(eng, 9, math.min(eng.eqL.get(m), plE), false, time, time, sNow != 3)

    // live pools' lines follow the chart
    for ln in eng.plLn
        if not na(ln)
            line.set_x2(ln, time)

// ══════════════════════════════════════════════════════════════════════
// SESSION BANDS — a solid line along the bottom of the pane under each session, its name just
// above it on the bar nearest the session's middle (the text of a transparent char on the edge). Plots, so they sit on the pane's bottom edge at any
// zoom or scroll, on all history. The line is a "▂" char per bar (a block element: no side bearings, so neighbours touch; "━" / "▬" left gaps) at size.auto, which TradingView
// scales with the bar spacing, so neighbours join at any zoom and nothing lifts it off the edge
// (text above a char did, by an offset that changed with zoom). The name's char is transparent.
// ══════════════════════════════════════════════════════════════════════
int tfMin = math.max(1, math.floor(chartSec / 60))
f_mid(int a, int b) => a + math.floor((b - a) / (2 * tfMin)) * tfMin
int   mNow  = hour(time, tz) * 60 + minute(time, tz)
int   sBand = showBand and runOk ? f_sessOf(time) : 3
color CLR   = color.new(color.black, 100)
plotchar(sBand == 0, "Asia band",   "▂", location.bottom, color.new(C_ASIA, 20), size = size.auto, editable = false, display = display.pane)
plotchar(sBand == 1, "London band", "▂", location.bottom, color.new(C_LDN, 20), size = size.auto, editable = false, display = display.pane)
plotchar(sBand == 2, "NY band",     "▂", location.bottom, color.new(C_NY, 20), size = size.auto, editable = false, display = display.pane)
plotchar(sBand == 0 and mNow == f_mid(A0, A1), "Asia name",   "─", location.bottom, CLR, text = "Asia",
     textcolor = C_ASIA, size = size.tiny, editable = false, display = display.pane)
plotchar(sBand == 1 and mNow == f_mid(L0, L1), "London name", "─", location.bottom, CLR, text = "London",
     textcolor = C_LDN, size = size.tiny, editable = false, display = display.pane)
plotchar(sBand == 2 and mNow == f_mid(N0, N1), "NY name",     "─", location.bottom, CLR, text = "NY",
     textcolor = C_NY, size = size.tiny, editable = false, display = display.pane)

// ══════════════════════════════════════════════════════════════════════
// RIGHT EDGE, PANEL, NOTICE
// ══════════════════════════════════════════════════════════════════════
// Right-edge row spacing is 3.5 % of the span autoscale shows: the last 200 bars plus the pool lines.
float hi200 = ta.highest(high, 200)
float lo200 = ta.lowest(low, 200)
var array<label> edge = array.new_label()
var table panel = na
if barstate.islast
    for lb in edge
        label.delete(lb)
    edge.clear()
    if not runOk
        string why = not sesOk ? "SESSION DIGGA: session times must be HHMM within one day" : "SESSION DIGGA: needs 30m or less, with a bar on every session edge"
        edge.push(label.new(bar_index, high, why,
             style = label.style_label_down, color = color.new(C_GOLD, 80), textcolor = C_GOLD, size = size.small))
    else
        int x  = time + 3 * chartSec * 1000
        int np = eng.plK.size()
        // Right-edge rows, top to bottom. Rows closer than `gap` are pushed down so they never
        // overlap; a second pool of the same kind that close is not repeated.
        array<float> ys = array.new_float()
        array<int>   ks = array.new_int()
        if np > 0
            for i = 0 to np - 1
                int k = eng.plK.get(i)
                if f_poolShown(k) and not na(eng.plLn.get(i))
                    ys.push(eng.plP.get(i))
                    ks.push(k)
        int nr = ys.size()
        float edgeGap = (math.max(hi200, nz(ys.max(), hi200)) - math.min(lo200, nz(ys.min(), lo200))) * 0.035
        if nr > 0
            array<int> ord = ys.sort_indices(order.descending)
            float yPrev = na
            int   kPrev = -1
            float pPrev = na
            for j = 0 to nr - 1
                int   i = ord.get(j)
                int   k = ks.get(i)
                float y = ys.get(i)
                if not (k == kPrev and pPrev - y < edgeGap)
                    float yL = na(yPrev) ? y : math.min(y, yPrev - edgeGap)
                    int n    = eng.poolN.get(k)
                    int s    = eng.poolS.get(k)
                    int top  = -1
                    int best = 0
                    for q = 0 to 3
                        if eng.poolBy.get(k * 4 + q) > best
                            best := eng.poolBy.get(k * 4 + q)
                            top  := q
                    string txt = "● " + POOL_NAMES.get(k) + "  " + f_rate(s, n) + (top >= 0 ? " · " + SES_NAMES.get(top) : "")
                    edge.push(label.new(x, yL, txt, xloc = xloc.bar_time, style = label.style_label_left,
                         color = color.new(f_poolCol(k), 100), textcolor = color.new(f_poolCol(k), n < LOW_N ? 50 : 0), size = TXT,
                         tooltip = f_tip(s, n) + " taken within " + str.tostring(horizon) + " sessions"))
                    yPrev := yL
                    kPrev := k
                    pPrev := y
    if showPanel and runOk
        if na(panel)
            panel := table.new(position.top_right, 3, 11, bgcolor = color.new(#131722, 10), border_width = 0)
        int r = 0
        table.cell(panel, 0, r, "SESSION DIGGA", text_color = C_GOLD, text_size = TXT)
        r += 1
        for k = 0 to 9
            if f_poolShown(k)
                int n = eng.poolN.get(k)
                int s = eng.poolS.get(k)
                table.cell(panel, 0, r, POOL_NAMES.get(k), text_color = f_poolCol(k), text_size = TXT, text_halign = text.align_left)
                table.cell(panel, 1, r, f_rate(s, n), text_color = n < LOW_N ? C_GREY : color.white, text_size = TXT, tooltip = f_tip(s, n))
                table.cell(panel, 2, r, "n=" + str.tostring(n), text_color = C_GREY, text_size = TXT)
                r += 1
    else if not na(panel)
        table.delete(panel)
        panel := na

// ══════════════════════════════════════════════════════════════════════
// ALERTS (spec §9) — set while the confirmed chart bar runs, sent once at its close
// ══════════════════════════════════════════════════════════════════════
if barstate.isconfirmed
    string sym = syminfo.ticker + " " + timeframe.period
    if showPD and eng.aPD
        alert("SESSION DIGGA " + sym + ": previous day's high or low taken.", alert.freq_once_per_bar_close)
    if showAs and eng.aAs
        alert("SESSION DIGGA " + sym + ": Asia high or low taken.", alert.freq_once_per_bar_close)
````
