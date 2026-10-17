# CTZ Elliott Wave Pro (based on LuxAlgo)

- url: https://www.tradingview.com/script/DVHUKaDu-CTZ-Elliott-Wave-Pro-based-on-LuxAlgo/
- type: indicator
- pine_id: PUB;6cde2a46d6d542c2b2bd4645b7c17ad2
- version: 4.0

## Description

Elliott Wave Pro (based on LuxAlgo)

CREDIT
This script is built on "Elliott Wave [LuxAlgo]" by LuxAlgo. Full credit to LuxAlgo for the original concept and code structure.
Original script: [paste link to LuxAlgo's Elliott Wave script]
Shared under the same Creative Commons Attribution-NonCommercial-ShareAlike 4.0 licence (CC BY-NC-SA 4.0) as the original.

OVERVIEW
Elliott Wave Pro automatically detects 5-wave impulses and ABC corrections across three wave degrees at once, then tells you where the market is in the count, what the next targets are, and exactly where the count is invalidated.

It keeps the multi-degree zigzag approach of the original and adds stricter wave validation, a (5) confirmation system, live Fibonacci projections, correction classification and a status dashboard.

HOW IT WORKS
Pivots are found on three zigzag lengths (Minor, Intermediate, Primary). An optional ATR filter ignores swings smaller than a set multiple of ATR to reduce noise.

Each new 6-point sequence is tested against the hard Elliott rules:
- Wave 2 never retraces beyond the start of wave 1
- Wave 3 is never the shortest of waves 1, 3 and 5
- Wave 4 never overlaps wave 1
- Waves 3 and 5 extend beyond the ends of waves 1 and 3

In Strict mode, guideline ratios are also required: wave 2 retrace range, minimum wave 3 length, and maximum wave 4 retrace (all adjustable).

FIB CONFLUENCE SCORE
Every impulse is scored 0–100% on how closely its waves match common Fibonacci relationships:
- W2 ≈ 0.5 / 0.618 of W1
- W3 ≈ 1.618 / 2.618 of W1
- W4 ≈ 0.236 / 0.382 of W3
- W5 ≈ 0.618 / 1.0 of W1
Hover the (5) label to see the exact ratios.

WAVE (5) CONFIRMATION
A completed (5) is drawn faded with a dashed final leg until it is confirmed. It is confirmed when price pulls back a set fraction of the whole impulse (default 0.236) or when a valid ABC forms. Once confirmed, it turns solid.
While unconfirmed, if price makes a new high (or low for bearish counts), the (5) snaps to the new extreme and the ratios and score are recalculated.

LIVE PROJECTIONS
On the latest bar each degree shows its current state with targets and an invalidation line:
- Wave 3 setup: W3 targets at 1.0 / 1.618 / 2.618 × W1
- Wave 4 in progress: retracement zones at 0.236 / 0.382 / 0.5 of W3
- Wave 5 in progress: targets at 0.618 × W1, 1.0 × W1 and 0.618 × (0→3), plus a cap when W3 is shorter than W1
- Impulse complete: retracement levels of the whole impulse with the 0.5–0.618 zone shaded
- Wave B / Wave C forming: B retracements and C targets at 0.618 / 1.0 / 1.618 × A

ABC CORRECTIONS
Corrections after an impulse are drawn with a zone box and classified as Zigzag or Flat, with the C/A ratio shown.

SIGNALS
- Trend resumption: a triangle prints when price breaks the B point after a completed ABC
- Impulse invalidation: the count is faded if price fully retraces the impulse

STATUS TABLE
One row per degree showing current state, key detail (score, ratios or confirmation level) and invalidation price. Position and edge gap are adjustable.

ALERTS
Create an alert on the indicator with "Any alert() function call". Alerts include ticker, timeframe, degree and price for:
new impulse, (5) snapped, (5) confirmed, ABC formed, ABC invalidated, impulse invalidated and trend resumption.

KEY SETTINGS
- Source & filter: high/low source, ATR length, minimum swing size
- Wave degrees: enable, length, colour and label notation for each degree
- Wave rules: Classic or Strict, guideline ratios, ABC maximum retrace, fib match tolerance
- Wave (5) confirmation: retrace required, faded transparency
- Levels & projections: retracement levels, projection toggle and length
- Display: waves kept, signals, table position and gap, label stacking and size

CHANGES FROM THE ORIGINAL
Fixes: low-source input bug, waves evaluated on pivots not added to the zigzag, conditionally called cross functions, mislabelled bearish alert, junk waves on early bars, label budget overflow, unbounded history loop.
Additions: everything listed above.

NOTES
Pivots confirm one bar after they form, so the most recent swing can still change. Elliott Wave counts are interpretive. Use the invalidation levels and your own analysis, and treat this as a tool, not a signal service.

This script is for educational purposes only and is not financial advice.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// Original script: "Elliott Wave [LuxAlgo]" © LuxAlgo — full credit to LuxAlgo for the original concept and structure.
// Modified version (2026) by CTZ, shared under the same CC BY-NC-SA 4.0 licence.
//
// Changes from the original:
//  Fixes
//   - low source input tested i_hi instead of i_lo
//   - waves were evaluated on pivots that never entered the zigzag (false / misplaced (5) labels)
//   - ta.crossover/crossunder called conditionally (inconsistent history)
//   - wrong "Bullish" text on bearish corrective invalidation alert
//   - zero-seeded zigzag produced junk waves on early bars
//   - unbounded break labels consumed the label budget and deleted old wave labels
//   - unbounded history loop on the fib break check
//  Upgrades
//   - ATR minimum-swing filter
//   - Classic / Strict rule sets (hard rules + guideline ratios)
//   - Fib confluence score per impulse, ratio tooltips on the (5) label
//   - Per-degree notation: (1) / 1 / i / [1]
//   - Live projections: wave 3, wave 4 zones, wave 5 targets, B and C targets, invalidation levels
//   - ABC classification (Zigzag / Flat) with C/A ratio
//   - Impulse invalidation on full retrace, trend-resumption signals on B break
//   - Status table, alerts with ticker / timeframe / degree / price
//   - (5) confirmation: faded until price retraces a set fraction of the impulse, then full.
//     While unconfirmed, a new higher high / lower low snaps (5) to it
//   - Smart label stacking: labels only offset when another degree already labels the same pivot
//   - Status table defaults to bottom right, with an edge-gap input so it clears TradingView's events icon / OHLC legend
//   - Pine Script v6
//   - Dashboard oscillator column: green / red Awesome Oscillator divergence check (wave 5 vs wave 3 peak)
//   - Reaction zone for wave C (1.0–1.618 × A from B), zone-entry alert, "C ended in zone" check
//   - Swing-sequence count in the dashboard (3-7-11 corrective / 5-9-13 impulsive)
//   - Fib score adds deep wave 2 (0.764 / 0.854) and shallow wave 4 (0.146); wave 4 zones 0.146 / 0.236 / 0.382
//   - Equal legs (C = A) highlighted as its own target
//   - Fix: (5) confirmation now only counts price AFTER the (5) bar (pivot candle's own wick no longer confirms it on higher timeframes)

//@version=6
indicator('Elliott Wave Pro (based on LuxAlgo)', shorttitle='EW Pro', overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100, max_bars_back=5000)

//------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------
G_SRC    = 'Source & filter'
i_hi     = input.string('high', 'High / Low source', options=['high', 'close', 'max open/close'], group=G_SRC, inline='src')
i_lo     = input.string('low' , ''                 , options=['low' , 'close', 'min open/close'], group=G_SRC, inline='src')
i_atrL   = input.int   (14    , 'ATR length'       , minval=1, group=G_SRC)
i_minSw  = input.float (0.5   , 'Min swing (× ATR)', minval=0, step=0.1, group=G_SRC, tooltip='A new zigzag leg must move at least this many ATRs. 0 = off (original behaviour).')
i_showZZ = input.bool  (false , 'Show zigzag'      , group=G_SRC)

G_DEG = 'Wave degrees  [on · length · colour · notation]'
en1  = input.bool  (true         , ''            , group=G_DEG, inline='1')
len1 = input.int   (4            , 'Minor       ', minval=1, group=G_DEG, inline='1')
col1 = input.color (color.red    , ''            , group=G_DEG, inline='1')
nt1  = input.string('Roman i'    , ''            , options=['Paren (1)', 'Plain 1', 'Roman i', 'Bracket [1]'], group=G_DEG, inline='1')
en2  = input.bool  (true         , ''            , group=G_DEG, inline='2')
len2 = input.int   (8            , 'Intermediate', minval=1, group=G_DEG, inline='2')
col2 = input.color (color.blue   , ''            , group=G_DEG, inline='2')
nt2  = input.string('Plain 1'    , ''            , options=['Paren (1)', 'Plain 1', 'Roman i', 'Bracket [1]'], group=G_DEG, inline='2')
en3  = input.bool  (true         , ''            , group=G_DEG, inline='3')
len3 = input.int   (16           , 'Primary     ', minval=1, group=G_DEG, inline='3')
col3 = input.color (color.orange , ''            , group=G_DEG, inline='3')
nt3  = input.string('Paren (1)'  , ''            , options=['Paren (1)', 'Plain 1', 'Roman i', 'Bracket [1]'], group=G_DEG, inline='3')

G_RUL    = 'Wave rules'
i_rules  = input.string('Strict', 'Rule set', options=['Classic', 'Strict'], group=G_RUL, tooltip='Classic = the hard Elliott rules only. Strict = hard rules + the guideline ratios below.')
i_w2min  = input.float (0.236, 'Wave 2 retrace of W1   min', minval=0, step=0.01, group=G_RUL, inline='w2')
i_w2max  = input.float (0.886, 'max'                       , minval=0, step=0.01, group=G_RUL, inline='w2')
i_w3min  = input.float (1.0  , 'Wave 3 min (× W1)'         , minval=0, step=0.1 , group=G_RUL)
i_w4max  = input.float (0.5  , 'Wave 4 max retrace of W3'  , minval=0, step=0.01, group=G_RUL)
i_abcMax = input.float (0.886, 'ABC max retrace of impulse', minval=0, maxval=1, step=0.01, group=G_RUL)
i_tol    = input.float (0.1  , 'Fib match tolerance'       , minval=0.01, maxval=0.5, step=0.01, group=G_RUL, tooltip='Used for the fib confluence score. 0.1 = within 10% of the target ratio.')

G_CNF     = 'Wave (5) confirmation'
i_confRet = input.float(0.236, 'Confirm after retrace of impulse', minval=0.01, maxval=1, step=0.01, group=G_CNF, tooltip='(5) stays faded until price pulls back this fraction of the whole 0→5 move. Until confirmed, a new higher high (lower low if bearish) snaps (5) to it.')
i_fadeT   = input.int  (65   , 'Unconfirmed transparency', minval=0, maxval=95, group=G_CNF)

G_OSC     = 'Oscillator (dashboard only)'
i_aoF     = input.int  (5    , 'AO fast', minval=1, group=G_OSC, inline='ao')
i_aoS     = input.int  (34   , 'slow'   , minval=2, group=G_OSC, inline='ao', tooltip='Awesome Oscillator = MA(source, fast) − MA(source, slow). Only feeds the dashboard divergence check — wave drawing is unaffected.')
i_aoSrc   = input.source(hl2 , 'Source' , group=G_OSC, inline='ao2')
i_aoMA    = input.string('SMA', 'MA type', options=['SMA', 'EMA'], group=G_OSC, inline='ao2', tooltip='Set these to match your CTZ AO Div settings so the dashboard reads the same values as your oscillator pane.')

G_EWF     = 'Reaction zone & sequences'
i_rzShow  = input.bool (true   , 'Reaction zone (C = 1.0–1.618 × A)', group=G_EWF, inline='rz', tooltip='Shaded zone where wave C is most likely to end: between equal legs (C = A) and C = 1.618 × A, measured from B.')
i_rzCol   = input.color(#2962FF, ''                                 , group=G_EWF, inline='rz')
i_seqShow = input.bool (true   , 'Swing sequence count (dashboard)' , group=G_EWF, tooltip='Counts zigzag swings from the last major extreme. 3 / 7 / 11 = corrective sequence, 5 / 9 / 13 = impulsive sequence, anything else = incomplete.')

G_FIB     = 'Levels & projections'
i_fibShow = input.bool (true , 'Retracements after completed (5)', group=G_FIB)
i_f1      = input.float(0.382, 'Level 1', minval=0, maxval=1, step=0.001, group=G_FIB, inline='f1')
i_f2      = input.float(0.5  , 'Level 2', minval=0, maxval=1, step=0.001, group=G_FIB, inline='f1')
i_f3      = input.float(0.618, 'Level 3', minval=0, maxval=1, step=0.001, group=G_FIB, inline='f2')
i_f4      = input.float(0.786, 'Level 4', minval=0, maxval=1, step=0.001, group=G_FIB, inline='f2')
i_proj    = input.bool (true , 'Live projections (W3 / W4 / W5 / B / C)', group=G_FIB)
i_projLen = input.int  (15   , 'Projection length (bars)', minval=1, group=G_FIB)

G_DSP   = 'Display'
i_keep  = input.int   (15         , 'Completed waves kept per degree', minval=1, maxval=20, group=G_DSP)
i_sig   = input.bool  (true       , 'Trend-resumption signals', group=G_DSP)
i_table = input.bool  (true       , 'Status table', group=G_DSP, inline='tb')
i_tpos  = input.string('Bottom right', '', options=['Top right', 'Bottom right', 'Top left', 'Bottom left'], group=G_DSP, inline='tb')
i_tgap  = input.float (5          , 'Table edge gap (% of chart)', minval=0, maxval=25, step=1, group=G_DSP, tooltip='Space between the table and the chart edge so it clears the TradingView events icon (bottom) or the OHLC legend (top).')
i_stack = input.bool  (true       , 'Stack labels across degrees', group=G_DSP, inline='lb', tooltip='When two degrees label the same pivot, the later label is offset so they do not overlap. Labels on their own pivot always sit right on the swing.')
i_lsize = input.string('Small'    , 'Size', options=['Tiny', 'Small', 'Normal'], group=G_DSP, inline='lb')

//------------------------------------------------------------------------------
// Types
//------------------------------------------------------------------------------
type ZZ
    int[]   d
    int[]   x
    float[] y
    line[]  l

type Ewave
    int     dir
    int[]   px
    float[] py
    line[]  ln
    label[] lb
    bool    on      = true
    float   ext
    float   score
    bool    hasABC  = false
    bool    abcDead = false
    bool    resumed = false
    int     xA
    int     xB
    int     xC
    float   yB
    string  abcTxt  = ''
    bool    conf    = false
    color   col
    line[]  cln
    label[] clb
    box     bx

//------------------------------------------------------------------------------
// Globals
//------------------------------------------------------------------------------
hi  = i_hi == 'high' ? high : i_hi == 'close' ? close : math.max(open, close)
lo  = i_lo == 'low'  ? low  : i_lo == 'close' ? close : math.min(open, close)
atr = ta.atr(i_atrL)
aoSma = ta.sma(i_aoSrc, i_aoF) - ta.sma(i_aoSrc, i_aoS)
aoEma = ta.ema(i_aoSrc, i_aoF) - ta.ema(i_aoSrc, i_aoS)
ao    = i_aoMA == 'SMA' ? aoSma : aoEma

// per-bar record of AO / high / low, indexed by bar number (element i = bar HBASE + i).
// Lookups read these arrays instead of series history, which is unreliable inside last-bar-only functions.
var float[] AOH   = array.new<float>()
var float[] HIH   = array.new<float>()
var float[] LOH   = array.new<float>()
var int     HBASE = 0
AOH.push(ao)
HIH.push(high)
LOH.push(low)
if AOH.size() > 5000
    AOH.shift()
    HIH.shift()
    LOH.shift()
    HBASE += 1

var string[] ROM = array.from('i', 'ii', 'iii', 'iv', 'v', 'a', 'b', 'c')
var string[] NUM = array.from('1', '2', '3', '4', '5', 'A', 'B', 'C')

// labels already placed per pivot (key = bar * 2 + side), shared across all degrees
var map<int, int> OCC = map.new<int, int>()

// Fibonacci targets for the confluence score (includes deep W2 0.764 / 0.854 and shallow W4 0.146)
var float[] T2 = array.from(0.5, 0.618, 0.764, 0.854)
var float[] T3 = array.from(1.618, 2.618)
var float[] T4 = array.from(0.146, 0.236, 0.382)
var float[] T5 = array.from(0.618, 1.0)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_base(string st, int i) =>
    string b = st == 'Roman i' ? ROM.get(i) : NUM.get(i)
    st == 'Paren (1)' ? '(' + b + ')' : st == 'Bracket [1]' ? '[' + b + ']' : b

f_nearAny(float r, float[] t) =>
    bool hit = false
    for v in t
        if math.abs(r - v) <= v * i_tol
            hit := true
    hit

f_score(float r2, float r3, float r4, float r5) =>
    float sc = (f_nearAny(r2, T2) ? 25 : 0) + (f_nearAny(r3, T3) ? 25 : 0) + (f_nearAny(r4, T4) ? 25 : 0) + (f_nearAny(r5, T5) ? 25 : 0)
    sc

f_tip(float r2, float r3, float r4, float r5, float score) =>
    str.format('W2 = {0,number,#.###} × W1\nW3 = {1,number,#.###} × W1\nW4 = {2,number,#.###} × W3\nW5 = {3,number,#.###} × W1\nFib confluence: {4,number,#}%', r2, r3, r4, r5, score)

f_alert(string deg, string msg, float price) =>
    alert(syminfo.ticker + ' ' + timeframe.period + ' · ' + deg + ' · ' + msg + ' @ ' + str.tostring(price, format.mintick), alert.freq_once_per_bar_close)

f_label(int x, float y, bool isHigh, string txt, color c, string tip, string lsz) =>
    int    key  = x * 2 + (isHigh ? 1 : 0)
    int    used = nz(OCC.get(key))
    OCC.put(key, used + 1)
    string pad  = not i_stack or used == 0 ? '' : used == 1 ? '\n' : '\n\n'
    label.new(x, y, isHigh ? txt + pad : pad + txt, color=color(na), textcolor=c, style=isHigh ? label.style_label_down : label.style_label_up, size=lsz, tooltip=tip)

f_proj(line[] pl, label[] pb, int x1, int x2, float y, color c, string txt, string st, int lw = 1) =>
    pl.push(line.new(x1, y, x2, y, color=c, style=st, width=lw))
    pb.push(label.new(x2, y, txt + '  ' + str.tostring(y, format.mintick), color=color(na), textcolor=c, style=label.style_label_left, size=size.small))
    true

// AO extreme between two bar indexes, normalised by direction (s = 1 → highest AO, s = -1 → lowest AO, negated)
f_aoExt(int x1, int x2, int s) =>
    float e = na
    int   a = math.max(x1 - HBASE, 0)
    int   b = math.min(x2 - HBASE, AOH.size() - 1)
    if b >= a
        for i = a to b
            float v = s * AOH.get(i)
            if not na(v)
                e := na(e) ? v : math.max(e, v)
    e

// price extreme between two bar indexes, normalised by direction
f_pxExt(int x1, int x2, int s) =>
    float e = na
    int   a = math.max(x1 - HBASE, 0)
    int   b = math.min(x2 - HBASE, HIH.size() - 1)
    if b >= a
        for i = a to b
            float v = s == 1 ? HIH.get(i) : -LOH.get(i)
            e := na(e) ? v : math.max(e, v)
    e

// divergence = wave-5 AO peak smaller than wave-3 AO peak; pct = W5 peak as % of W3 peak
f_div(float a3, float a5) =>
    bool   dv  = not na(a3) and not na(a5) and a3 > 0 and a5 < a3
    string pct = na(a3) or na(a5) or a3 <= 0 ? '' : ' · ' + str.tostring(100 * a5 / a3, '#') + '%'
    bool   known = not na(a3) and not na(a5) and a3 > 0
    [dv, pct, known]

// dashboard tooltip: raw AO peaks and the bar ranges scanned (hover the Oscillator cell)
f_aoTip(float a3, float a5, int s, int x2, int x3, int x4, int x5) =>
    'AO W3 peak: ' + str.tostring(s * a3, '#.##') + '  (bars ' + str.tostring(bar_index - x3) + '–' + str.tostring(bar_index - x2) + ' ago)\n' +
     'AO W5 peak: ' + str.tostring(s * a5, '#.##') + '  (bars ' + str.tostring(bar_index - x5) + '–' + str.tostring(bar_index - x4) + ' ago)\n' +
     'AO now: ' + str.tostring(ao, '#.##')

// swing sequence from the last major extreme: 3 / 7 / 11 corrective, 5 / 9 / 13 impulsive
f_seq(ZZ z) =>
    int    sz  = z.d.size()
    string out = '—'
    if sz >= 3
        int ih = 0
        int il = 0
        for i = 1 to sz - 1
            if z.y.get(i) > z.y.get(ih)
                ih := i
            if z.y.get(i) < z.y.get(il)
                il := i
        // anchor = most recent extreme; if the newest point is itself the extreme, count from the opposite one
        int    a    = math.min(ih, il) == 0 ? math.max(ih, il) : math.min(ih, il)
        bool   up   = a == il
        string kind = a == 3 or a == 7 or a == 11 ? 'corrective' : a == 5 or a == 9 or a == 13 ? 'impulsive' : a > 13 ? 'extended' : 'incomplete → ' + str.tostring(a % 2 == 0 ? a + 1 : a + 2)
        out := (up ? '↑ ' : '↓ ') + str.tostring(a) + ' · ' + kind
    out

// Adds a pivot to the zigzag. Returns true only if the zigzag actually changed.
method add(ZZ z, int d, int x, float y, float minMove, color col) =>
    bool changed = false
    int  sz      = z.d.size()
    if sz == 0
        z.d.unshift(d)
        z.x.unshift(x)
        z.y.unshift(y)
        changed := true
    else
        int   d0 = z.d.get(0)
        float y0 = z.y.get(0)
        if d0 == d
            if d * y > d * y0
                z.x.set(0, x)
                z.y.set(0, y)
                changed := true
                if i_showZZ and z.l.size() > 0
                    z.l.get(0).set_xy2(x, y)
        else if math.abs(y - y0) >= minMove
            int x0 = z.x.get(0)
            z.d.unshift(d)
            z.x.unshift(x)
            z.y.unshift(y)
            if z.d.size() > 16
                z.d.pop()
                z.x.pop()
                z.y.pop()
            if i_showZZ
                z.l.unshift(line.new(x0, y0, x, y, color=color.new(col, 50)))
                if z.l.size() > 12
                    z.l.pop().delete()
            changed := true
    changed

method fade(Ewave w) =>
    for l in w.ln
        l.set_style(line.style_dotted)
    for b in w.lb
        b.set_textcolor(color.gray)
    w.on := false

method dashABC(Ewave w) =>
    for l in w.cln
        l.set_style(line.style_dashed)
    for b in w.clb
        b.set_textcolor(color.gray)
    if not na(w.bx)
        w.bx.set_bgcolor(color(na))
        w.bx.set_text('ABC invalid')
    w.abcDead := true

method kill(Ewave w) =>
    for l in w.ln
        l.delete()
    for b in w.lb
        b.delete()
    for l in w.cln
        l.delete()
    for b in w.clb
        b.delete()
    if not na(w.bx)
        w.bx.delete()
    true

// Evaluates the last 6 zigzag points as a 1-2-3-4-5 impulse (normalised so bullish logic covers both directions)
f_motive(ZZ z) =>
    int   s  = z.d.get(0)
    float v0 = s * z.y.get(5)
    float v1 = s * z.y.get(4)
    float v2 = s * z.y.get(3)
    float v3 = s * z.y.get(2)
    float v4 = s * z.y.get(1)
    float v5 = s * z.y.get(0)
    float w1 = v1 - v0
    float w2 = v1 - v2
    float w3 = v3 - v2
    float w4 = v3 - v4
    float w5 = v5 - v4
    // hard rules: W2 < 100% of W1, W3 not shortest, W4 no overlap with W1, W3 beyond W1, W5 beyond W3
    bool  hard  = w1 > 0 and w2 > 0 and w3 > 0 and w4 > 0 and w5 > 0 and v2 > v0 and v3 > v1 and v4 > v1 and v5 > v3 and not (w3 < w1 and w3 < w5)
    float r2    = w2 / w1
    float r3    = w3 / w1
    float r4    = w4 / w3
    float r5    = w5 / w1
    bool  guide = r2 >= i_w2min and r2 <= i_w2max and r3 >= i_w3min and r4 <= i_w4max
    bool  ok    = hard and (i_rules == 'Classic' or guide)
    float score = f_score(r2, r3, r4, r5)
    [ok, s, score, r2, r3, r4, r5]

// Recomputes ratios / score from a wave's stored points (used when (5) snaps)
f_ratios(float[] py, int s) =>
    float w1 = s * (py.get(1) - py.get(0))
    float w2 = s * (py.get(1) - py.get(2))
    float w3 = s * (py.get(3) - py.get(2))
    float w4 = s * (py.get(3) - py.get(4))
    float w5 = s * (py.get(5) - py.get(4))
    float r2 = w2 / w1
    float r3 = w3 / w1
    float r4 = w4 / w3
    float r5 = w5 / w1
    float score = f_score(r2, r3, r4, r5)
    [r2, r3, r4, r5, score]

// Faded + dashed wave-5 leg and (5) label while unconfirmed, full once confirmed
method style5(Ewave w) =>
    color c = w.conf ? w.col : color.new(w.col, i_fadeT)
    w.ln.get(4).set_color(c)
    w.ln.get(4).set_style(w.conf ? line.style_solid : line.style_dashed)
    w.lb.get(4).set_textcolor(c)
    true

// Runs only when the zigzag changed
f_eval(ZZ z, Ewave[] waves, color col, string nt, string deg, int wd, string lsz) =>
    int  sz      = z.d.size()
    bool snapped = false
    //--------------------------------------------------------------- snap unconfirmed-or-no-ABC (5) to a new extreme
    if sz >= 3 and waves.size() > 0
        Ewave w = waves.get(0)
        int   s = w.dir
        if w.on and not w.hasABC and z.d.get(0) == s and z.x.get(0) > w.px.get(5) and s * z.y.get(0) > s * w.py.get(5)
            bool found = false
            bool holds = true
            for i = 1 to sz - 1
                if z.x.get(i) == w.px.get(5)
                    found := true
                    break
                if z.x.get(i) < w.px.get(5)
                    break
                // pullbacks since the old (5) must stay beyond wave 4, otherwise it's a new structure
                if z.d.get(i) == -s and s * z.y.get(i) <= s * w.py.get(4)
                    holds := false
            if found and holds
                int   x = z.x.get(0)
                float y = z.y.get(0)
                w.px.set(5, x)
                w.py.set(5, y)
                w.ln.get(4).set_xy2(x, y)
                w.lb.get(4).set_xy(x, y)
                [q2, q3, q4, q5, qs] = f_ratios(w.py, s)
                w.lb.get(4).set_tooltip(f_tip(q2, q3, q4, q5, qs))
                w.score := qs
                w.ext   := s == 1 ? low : high
                w.conf  := false
                w.style5()
                snapped := true
                f_alert(deg, '(5) snapped to new ' + (s == 1 ? 'high' : 'low') + ' (unconfirmed)', y)
    //--------------------------------------------------------------- impulse
    if sz >= 6 and not snapped
        [ok, s, score, r2, r3, r4, r5] = f_motive(z)
        bool same = false
        if waves.size() > 0
            Ewave prev = waves.get(0)
            same := prev.px.get(0) == z.x.get(5) and prev.px.get(1) == z.x.get(4) and prev.px.get(2) == z.x.get(3) and prev.px.get(3) == z.x.get(2) and prev.px.get(4) == z.x.get(1)
        if ok
            string tip = f_tip(r2, r3, r4, r5, score)
            if same
                // wave 5 extending
                Ewave last = waves.get(0)
                int   x    = z.x.get(0)
                float y    = z.y.get(0)
                last.px.set(5, x)
                last.py.set(5, y)
                last.ln.get(4).set_xy2(x, y)
                last.lb.get(4).set_xy(x, y)
                last.lb.get(4).set_tooltip(tip)
                last.score := score
                last.ext   := s == 1 ? low : high
                last.conf  := false
                last.style5()
            else
                Ewave w = Ewave.new(dir=s, px=array.new<int>(), py=array.new<float>(), ln=array.new<line>(), lb=array.new<label>(), cln=array.new<line>(), clb=array.new<label>(), score=score, col=col, ext=s == 1 ? low : high)
                for i = 5 to 0
                    w.px.push(z.x.get(i))
                    w.py.push(z.y.get(i))
                for i = 1 to 5
                    bool isHigh = (i % 2 == 1) == (s == 1)
                    w.ln.push(line.new(w.px.get(i - 1), w.py.get(i - 1), w.px.get(i), w.py.get(i), color=col, width=wd))
                    w.lb.push(f_label(w.px.get(i), w.py.get(i), isHigh, f_base(nt, i - 1), col, i == 5 ? tip : '', lsz))
                w.style5()
                waves.unshift(w)
                if waves.size() > i_keep
                    waves.pop().kill()
                f_alert(deg, 'New ' + (s == 1 ? 'bullish' : 'bearish') + ' impulse 1-5 (unconfirmed) · fib ' + str.tostring(score, '#') + '%', z.y.get(0))
    //--------------------------------------------------------------- ABC
    if sz >= 4 and waves.size() > 0
        Ewave w = waves.get(0)
        int   s = w.dir
        if z.x.get(3) == w.px.get(5) and z.d.get(0) == -s
            float top     = s * w.py.get(5)
            float org     = s * w.py.get(0)
            float vA      = s * z.y.get(2)
            float vB      = s * z.y.get(1)
            float vC      = s * z.y.get(0)
            float lim     = top - (top - org) * i_abcMax
            bool  valid   = w.on and vA < top and vB > vA and vB < top and vC < vB and vA > lim and vC > lim
            bool  sameABC = w.hasABC and w.xA == z.x.get(2) and w.xB == z.x.get(1)
            if valid
                float  aLen = top - vA
                float  rB   = (vB - vA) / aLen
                float  rC   = (vB - vC) / aLen
                string txt  = (rB >= 0.9 ? 'Flat' : 'Zigzag') + ' · C = ' + str.tostring(rC, '#.##') + '×A'
                int    xA   = z.x.get(2)
                int    xB   = z.x.get(1)
                int    xC   = z.x.get(0)
                float  yA   = z.y.get(2)
                float  yB   = z.y.get(1)
                float  yC   = z.y.get(0)
                int    wdt  = math.max(xC - w.px.get(5), 1)
                if sameABC
                    // C extending
                    w.cln.get(2).set_xy2(xC, yC)
                    w.clb.get(2).set_xy(xC, yC)
                    w.clb.get(2).set_tooltip(txt)
                    w.bx.set_lefttop(xC, math.max(yA, yC))
                    w.bx.set_rightbottom(xC + wdt, math.min(yA, yC))
                    w.bx.set_text(txt)
                    w.xC     := xC
                    w.abcTxt := txt
                else
                    if w.hasABC
                        for l in w.cln
                            l.delete()
                        for b in w.clb
                            b.delete()
                        w.cln.clear()
                        w.clb.clear()
                        if not na(w.bx)
                            w.bx.delete()
                    w.cln.push(line.new(w.px.get(5), w.py.get(5), xA, yA, color=col, width=wd))
                    w.cln.push(line.new(xA, yA, xB, yB, color=col, width=wd))
                    w.cln.push(line.new(xB, yB, xC, yC, color=col, width=wd))
                    w.clb.push(f_label(xA, yA, s == -1, f_base(nt, 5), col, '' , lsz))
                    w.clb.push(f_label(xB, yB, s ==  1, f_base(nt, 6), col, '' , lsz))
                    w.clb.push(f_label(xC, yC, s == -1, f_base(nt, 7), col, txt, lsz))
                    w.bx      := box.new(xC, math.max(yA, yC), xC + wdt, math.min(yA, yC), border_color=color.new(col, 60), bgcolor=color.new(col, 92), text=txt, text_color=col, text_size=size.small, text_halign=text.align_left, text_valign=text.align_top)
                    w.hasABC  := true
                    w.abcDead := false
                    w.resumed := false
                    w.xA      := xA
                    w.xB      := xB
                    w.xC      := xC
                    w.yB      := yB
                    w.abcTxt  := txt
                    f_alert(deg, 'ABC after ' + (s == 1 ? 'bullish' : 'bearish') + ' impulse (' + txt + ')', yC)
            else if sameABC and not w.abcDead
                w.dashABC()
                f_alert(deg, 'ABC invalidated', z.y.get(0))
    true

//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
draw(bool enabled, simple int len, color col, int n, string nt, string deg) =>
    var ZZ         z     = ZZ.new(array.new<int>(), array.new<int>(), array.new<float>(), array.new<line>())
    var Ewave[]    waves = array.new<Ewave>()
    var line[]     pln   = array.new<line>()
    var label[]    plb   = array.new<label>()
    var linefill[] pfl   = array.new<linefill>()
    var string     state = 'Waiting for pivots'
    var string     info  = '—'
    var float      inval = na
    var string     aoTxt = '—'
    var color      aoCol = na
    var string     aoTip = ''
    var string     seqTxt = '—'
    var box[]      pbx   = array.new<box>()
    var bool       rzIn  = false
    bool   bullSig = false
    bool   bearSig = false
    float  ph      = ta.pivothigh(hi, len, 1)
    float  pl      = ta.pivotlow (lo, len, 1)
    string lsz     = i_lsize == 'Tiny' ? size.tiny : i_lsize == 'Normal' ? size.normal : size.small
    int    wd      = n + 1
    float  minMove = nz(atr) * i_minSw
    if enabled
        //----------------------------------------------------------- pivots
        if not na(ph)
            if z.add(1, bar_index - 1, ph, minMove, col)
                f_eval(z, waves, col, nt, deg, wd, lsz)
        if not na(pl)
            if z.add(-1, bar_index - 1, pl, minMove, col)
                f_eval(z, waves, col, nt, deg, wd, lsz)
        //----------------------------------------------------------- per-bar tracking
        if waves.size() > 0
            Ewave w = waves.get(0)
            if w.on
                w.ext := w.dir == 1 ? math.min(nz(w.ext, low), low) : math.max(nz(w.ext, high), high)
                bool broke = w.dir == 1 ? w.ext < w.py.get(0) : w.ext > w.py.get(0)
                if broke
                    w.fade()
                    f_alert(deg, 'Impulse invalidated (fully retraced)', close)
                else if not w.conf
                    float d   = w.py.get(5) - w.py.get(0)
                    float lvl = w.py.get(5) - d * i_confRet
                    bool  hit = w.dir == 1 ? w.ext <= lvl : w.ext >= lvl
                    if hit or w.hasABC
                        w.conf := true
                        w.style5()
                        f_alert(deg, '(5) confirmed', close)
            if w.hasABC and not w.abcDead and not w.resumed and bar_index > w.xC
                if w.dir == 1 ? close > w.yB : close < w.yB
                    w.resumed := true
                    if w.dir == 1
                        bullSig := true
                    else
                        bearSig := true
                    f_alert(deg, 'Trend resumption: ' + (w.dir == 1 ? 'bullish' : 'bearish') + ' (B broken)', close)
        //----------------------------------------------------------- last bar: state + projections
        if barstate.islast
            for l in pln
                l.delete()
            for b in plb
                b.delete()
            for f in pfl
                linefill.delete(f)
            for rb in pbx
                rb.delete()
            pln.clear()
            plb.clear()
            pfl.clear()
            pbx.clear()
            seqTxt := i_seqShow ? f_seq(z) : '—'
            state := 'Scanning'
            info  := '—'
            inval := na
            aoTxt := '—'
            aoCol := na
            aoTip := ''
            int  sz   = z.d.size()
            int  xr   = bar_index + i_projLen
            bool done  = false
            bool nowIn = false
            if sz >= 6
                // ----- states tied to the latest completed impulse
                if waves.size() > 0
                    Ewave w = waves.get(0)
                    if w.on
                        int   s  = w.dir
                        float p0 = w.py.get(0)
                        float p5 = w.py.get(5)
                        int   x5 = w.px.get(5)
                        if z.x.get(0) == x5
                            done  := true
                            float cl = p5 - (p5 - p0) * i_confRet
                            state := w.conf ? 'Impulse (5) confirmed' : 'Impulse (5) unconfirmed'
                            info  := 'Fib ' + str.tostring(w.score, '#') + '%' + (w.conf ? '' : ' · confirms ' + (s == 1 ? '< ' : '> ') + str.tostring(cl, format.mintick))
                            inval := p0
                            if i_fibShow
                                float  d    = p5 - p0
                                bool   deep = s == 1 ? w.ext < p5 - d * i_f4 : w.ext > p5 - d * i_f4
                                color  fc   = deep ? color.red : w.conf ? col : color.new(col, i_fadeT)
                                string fs   = deep ? line.style_dotted : line.style_solid
                                f_proj(pln, plb, x5, xr, p5 - d * i_f1, fc, str.tostring(i_f1), fs)
                                f_proj(pln, plb, x5, xr, p5 - d * i_f2, fc, str.tostring(i_f2), fs)
                                f_proj(pln, plb, x5, xr, p5 - d * i_f3, fc, str.tostring(i_f3), fs)
                                f_proj(pln, plb, x5, xr, p5 - d * i_f4, fc, str.tostring(i_f4), fs)
                                pfl.push(linefill.new(pln.get(1), pln.get(2), color.new(fc, 88)))
                        else if z.x.get(1) == x5
                            done := true
                            float yA   = z.y.get(0)
                            float aLen = math.abs(p5 - yA)
                            state := (w.conf ? '' : '(5)? · ') + 'Wave B forming'
                            info  := 'A = ' + str.tostring(aLen / math.abs(p5 - p0), '#.###') + ' of impulse'
                            inval := p5
                            if i_proj
                                int xa = z.x.get(0)
                                f_proj(pln, plb, xa, xr, yA + s * aLen * 0.5  , col      , 'B 0.5'           , line.style_dashed)
                                f_proj(pln, plb, xa, xr, yA + s * aLen * 0.618, col      , 'B 0.618'         , line.style_dashed)
                                f_proj(pln, plb, xa, xr, yA + s * aLen * 0.786, col      , 'B 0.786'         , line.style_dashed)
                                f_proj(pln, plb, xa, xr, p5                   , color.red, 'B limit (5 end)' , line.style_dotted)
                        else if z.x.get(2) == x5
                            done := true
                            float yA   = z.y.get(1)
                            float yB   = z.y.get(0)
                            float aLen = math.abs(p5 - yA)
                            float lim  = p5 - (p5 - p0) * i_abcMax
                            state := (w.conf ? '' : '(5)? · ') + 'Wave C forming'
                            float rz1 = yB - s * aLen
                            float rz2 = yB - s * aLen * 1.618
                            float rzH = math.max(rz1, rz2)
                            float rzL = math.min(rz1, rz2)
                            nowIn := close <= rzH and close >= rzL
                            info  := 'B = ' + str.tostring(math.abs(yB - yA) / aLen, '#.###') + ' of A' + (nowIn ? ' · IN ZONE' : ' · zone ' + str.tostring(rzL, format.mintick) + '–' + str.tostring(rzH, format.mintick))
                            if i_rzShow
                                pbx.push(box.new(z.x.get(0), rzH, xr, rzL, border_color=color.new(i_rzCol, 40), bgcolor=color.new(i_rzCol, 85), text='Reaction zone', text_color=i_rzCol, text_size=size.small, text_halign=text.align_right, text_valign=text.align_top))
                            inval := lim
                            if i_proj
                                int xb = z.x.get(0)
                                f_proj(pln, plb, xb, xr, yB - s * aLen * 0.618, col      , 'C 0.618×A', line.style_dashed)
                                f_proj(pln, plb, xb, xr, yB - s * aLen        , col      , 'Equal legs (C = A)', line.style_solid, 2)
                                f_proj(pln, plb, xb, xr, yB - s * aLen * 1.618, col      , 'C 1.618×A', line.style_dashed)
                                f_proj(pln, plb, xb, xr, lim                  , color.red, 'ABC limit', line.style_dotted)
                        else if z.x.get(3) == x5 and w.hasABC and not w.abcDead
                            if w.xC == z.x.get(0)
                                done  := true
                                state := w.resumed ? 'Trend resumed' : 'ABC complete?'
                                float aL2 = math.abs(p5 - z.y.get(2))
                                float rzA = w.yB - s * aL2
                                float rzB = w.yB - s * aL2 * 1.618
                                float rH2 = math.max(rzA, rzB)
                                float rL2 = math.min(rzA, rzB)
                                bool  cIn = z.y.get(0) <= rH2 and z.y.get(0) >= rL2
                                info  := w.abcTxt + (cIn ? ' · C in zone ✓' : ' · C outside zone')
                                inval := z.y.get(0)
                                if i_rzShow
                                    pbx.push(box.new(w.xB, rH2, xr, rL2, border_color=color.new(i_rzCol, 40), bgcolor=color.new(i_rzCol, 85), text='Reaction zone', text_color=i_rzCol, text_size=size.small, text_halign=text.align_right, text_valign=text.align_top))
                                if i_proj
                                    f_proj(pln, plb, z.x.get(0), xr, w.yB      , col      , 'Confirm (break B)', line.style_dashed)
                                    f_proj(pln, plb, z.x.get(0), xr, z.y.get(0), color.red, 'C extreme'        , line.style_dotted)
                        if done
                            // AO lags price: each wave's window runs until the next wave starts
                            int x5e = bar_index
                            for i = 1 to sz - 1
                                if z.x.get(i) == x5
                                    x5e := z.x.get(i - 1)
                                    break
                            float aoW3 = f_aoExt(w.px.get(2), w.px.get(4), s)
                            float aoW5 = f_aoExt(w.px.get(4), x5e, s)
                            [dv, pct, known] = f_div(aoW3, aoW5)
                            aoTxt := not known ? 'AO n/a' : (dv ? '✓ Divergence' : '✗ No divergence') + pct
                            aoCol := not known ? color(na) : dv ? color.green : color.red
                            aoTip := f_aoTip(aoW3, aoW5, s, w.px.get(2), w.px.get(4), w.px.get(4), x5e)
                // ----- 0-1-2-3-4 → wave 5 in progress
                if not done
                    int   sd = -z.d.get(0)
                    float v0 = sd * z.y.get(4)
                    float v1 = sd * z.y.get(3)
                    float v2 = sd * z.y.get(2)
                    float v3 = sd * z.y.get(1)
                    float v4 = sd * z.y.get(0)
                    float w1 = v1 - v0
                    float w2 = v1 - v2
                    float w3 = v3 - v2
                    float w4 = v3 - v4
                    bool  ok = w1 > 0 and w2 > 0 and w3 > 0 and w4 > 0 and v2 > v0 and v3 > v1 and v4 > v1
                    if ok and i_rules == 'Strict'
                        ok := w2 / w1 >= i_w2min and w2 / w1 <= i_w2max and w3 / w1 >= i_w3min and w4 / w3 <= i_w4max
                    if ok
                        done := true
                        float y4 = z.y.get(0)
                        int   x4 = z.x.get(0)
                        state := 'Wave 5 in progress'
                        info  := 'W3 = ' + str.tostring(w3 / w1, '#.##') + '×W1'
                        inval := z.y.get(3)
                        if f_pxExt(z.x.get(0), bar_index, sd) > sd * z.y.get(1)
                            float aoW3 = f_aoExt(z.x.get(2), z.x.get(0), sd)
                            float aoW5 = f_aoExt(z.x.get(0), bar_index, sd)
                            [dv, pct, known] = f_div(aoW3, aoW5)
                            aoTxt := not known ? 'AO n/a' : (dv ? '✓ Div so far' : '✗ No div') + pct
                            aoCol := not known ? color(na) : dv ? color.green : color.red
                            aoTip := f_aoTip(aoW3, aoW5, sd, z.x.get(2), z.x.get(0), z.x.get(0), bar_index)
                        else
                            aoTxt := 'W5 not past W3 yet'
                        if i_proj
                            f_proj(pln, plb, x4, xr, y4 + sd * w1 * 0.618       , col, 'W5 0.618×W1'    , line.style_dashed)
                            f_proj(pln, plb, x4, xr, y4 + sd * w1               , col, 'W5 = W1'        , line.style_dashed)
                            f_proj(pln, plb, x4, xr, y4 + sd * (v3 - v0) * 0.618, col, 'W5 0.618×(0→3)' , line.style_dashed)
                            if w3 < w1
                                f_proj(pln, plb, x4, xr, y4 + sd * w3, color.orange, 'W5 max (W3 not shortest)', line.style_dotted)
                            f_proj(pln, plb, x4, xr, inval, color.red, 'Invalidation (W1 overlap)', line.style_dotted)
                // ----- 0-1-2-3 → wave 4 in progress
                if not done
                    int   sd = z.d.get(0)
                    float v0 = sd * z.y.get(3)
                    float v1 = sd * z.y.get(2)
                    float v2 = sd * z.y.get(1)
                    float v3 = sd * z.y.get(0)
                    float w1 = v1 - v0
                    float w2 = v1 - v2
                    float w3 = v3 - v2
                    bool  ok = w1 > 0 and w2 > 0 and w3 > 0 and v2 > v0 and v3 > v1
                    if ok and i_rules == 'Strict'
                        ok := w2 / w1 >= i_w2min and w2 / w1 <= i_w2max and w3 / w1 >= i_w3min
                    if ok
                        done := true
                        float y3 = z.y.get(0)
                        int   x3 = z.x.get(0)
                        state := 'Wave 4 in progress'
                        info  := 'W3 = ' + str.tostring(w3 / w1, '#.##') + '×W1'
                        inval := z.y.get(2)
                        if i_proj
                            f_proj(pln, plb, x3, xr, y3 - sd * w3 * 0.146, col, 'W4 0.146', line.style_dashed)
                            f_proj(pln, plb, x3, xr, y3 - sd * w3 * 0.236, col, 'W4 0.236', line.style_dashed)
                            f_proj(pln, plb, x3, xr, y3 - sd * w3 * 0.382, col, 'W4 0.382', line.style_dashed)
                            f_proj(pln, plb, x3, xr, inval, color.red, 'Invalidation (W1 overlap)', line.style_dotted)
                // ----- 0-1-2 → wave 3 setup
                if not done
                    int   sd = -z.d.get(0)
                    float v0 = sd * z.y.get(2)
                    float v1 = sd * z.y.get(1)
                    float v2 = sd * z.y.get(0)
                    float w1 = v1 - v0
                    float w2 = v1 - v2
                    bool  ok = w1 > 0 and w2 > 0 and v2 > v0
                    if ok and i_rules == 'Strict'
                        ok := w2 / w1 >= i_w2min and w2 / w1 <= i_w2max
                    if ok
                        done := true
                        float y2 = z.y.get(0)
                        int   x2 = z.x.get(0)
                        state := 'Wave 3 setup'
                        info  := 'W2 = ' + str.tostring(w2 / w1, '#.###') + '×W1'
                        inval := z.y.get(2)
                        if i_proj
                            f_proj(pln, plb, x2, xr, y2 + sd * w1        , col, 'W3 = W1'    , line.style_dashed)
                            f_proj(pln, plb, x2, xr, y2 + sd * w1 * 1.618, col, 'W3 1.618×W1', line.style_dashed)
                            f_proj(pln, plb, x2, xr, y2 + sd * w1 * 2.618, col, 'W3 2.618×W1', line.style_dashed)
                            f_proj(pln, plb, x2, xr, inval, color.red, 'Invalidation (W1 start)', line.style_dotted)
            if nowIn and not rzIn
                f_alert(deg, 'Price entered wave C reaction zone', close)
            rzIn := nowIn
    [bullSig, bearSig, state, info, inval, aoTxt, aoCol, aoTip, seqTxt]

//------------------------------------------------------------------------------
// Run
//------------------------------------------------------------------------------
[bu1, be1, st1, in1, iv1, ao1, ac1, at1, sq1] = draw(en1, len1, col1, 0, nt1, 'Minor')
[bu2, be2, st2, in2, iv2, ao2, ac2, at2, sq2] = draw(en2, len2, col2, 1, nt2, 'Intermediate')
[bu3, be3, st3, in3, iv3, ao3, ac3, at3, sq3] = draw(en3, len3, col3, 2, nt3, 'Primary')

plot(ao, 'AO (data window)', display=display.data_window)

plotshape(i_sig and bu1, 'Minor bull resume'       , shape.triangleup  , location.belowbar, col1, size=size.tiny )
plotshape(i_sig and be1, 'Minor bear resume'       , shape.triangledown, location.abovebar, col1, size=size.tiny )
plotshape(i_sig and bu2, 'Intermediate bull resume', shape.triangleup  , location.belowbar, col2, size=size.small)
plotshape(i_sig and be2, 'Intermediate bear resume', shape.triangledown, location.abovebar, col2, size=size.small)
plotshape(i_sig and bu3, 'Primary bull resume'     , shape.triangleup  , location.belowbar, col3, size=size.normal)
plotshape(i_sig and be3, 'Primary bear resume'     , shape.triangledown, location.abovebar, col3, size=size.normal)

//------------------------------------------------------------------------------
// Status table
//------------------------------------------------------------------------------
f_pos(string p) =>
    p == 'Top right' ? position.top_right : p == 'Bottom right' ? position.bottom_right : p == 'Top left' ? position.top_left : position.bottom_left

f_cell(table tb, int c, int r, string t, color tc, color bg, string ha) =>
    table.cell(tb, c, r, t, text_color=tc, bgcolor=bg, text_size=size.small, text_halign=ha)
    true

f_row(table tb, int r, bool en, string deg, color c, string st, string inf, string sq, string aot, color aoc, string aotip, float iv) =>
    if en
        color bg = color.new(chart.bg_color, 10)
        f_cell(tb, 0, r, deg, c             , bg, text.align_left)
        f_cell(tb, 1, r, st , chart.fg_color, bg, text.align_left)
        f_cell(tb, 2, r, inf, chart.fg_color, bg, text.align_left)
        f_cell(tb, 3, r, sq , chart.fg_color, bg, text.align_left)
        f_cell(tb, 4, r, aot, na(aoc) ? chart.fg_color : color.white, na(aoc) ? bg : color.new(aoc, 20), text.align_center)
        table.cell_set_tooltip(tb, 4, r, aotip)
        f_cell(tb, 5, r, na(iv) ? '—' : str.tostring(iv, format.mintick), color.red, bg, text.align_center)
    true

// transparent table; each cell carries its own background so the spacer row stays invisible
var table tb = table.new(f_pos(i_tpos), 6, 5, bgcolor=color(na), frame_width=0, border_width=0)

if barstate.islast and i_table
    bool  top = i_tpos == 'Top right' or i_tpos == 'Top left'
    int   o   = top ? 1 : 0
    color hb  = color.new(chart.fg_color, 85)
    // spacer on the anchored edge
    table.cell(tb, 0, top ? 0 : 4, '', height=i_tgap, bgcolor=color(na))
    f_cell(tb, 0, o, 'Degree'      , chart.fg_color, hb, text.align_center)
    f_cell(tb, 1, o, 'State'       , chart.fg_color, hb, text.align_center)
    f_cell(tb, 2, o, 'Detail'      , chart.fg_color, hb, text.align_center)
    f_cell(tb, 3, o, 'Swings'      , chart.fg_color, hb, text.align_center)
    f_cell(tb, 4, o, 'Oscillator'  , chart.fg_color, hb, text.align_center)
    f_cell(tb, 5, o, 'Invalidation', chart.fg_color, hb, text.align_center)
    f_row(tb, o + 1, en1, 'Minor ('        + str.tostring(len1) + ')', col1, st1, in1, sq1, ao1, ac1, at1, iv1)
    f_row(tb, o + 2, en2, 'Intermediate (' + str.tostring(len2) + ')', col2, st2, in2, sq2, ao2, ac2, at2, iv2)
    f_row(tb, o + 3, en3, 'Primary ('      + str.tostring(len3) + ')', col3, st3, in3, sq3, ao3, ac3, at3, iv3)
//------------------------------------------------------------------------------
````
