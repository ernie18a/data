# HTF FVG Tracker (M1D)

- url: https://www.tradingview.com/script/N7zllX8j-HTF-FVG-Tracker-M1D/
- type: indicator
- pine_id: PUB;cb3bc83fd04a477bb156cb6dff165453
- version: 4.0

## Description

HTF FVG Tracker 
Keeps a running ledger of the hourly, four-hour and eight-hour fair value gaps on any intraday chart. Each gap is drawn the moment its candle set completes on its own timeframe, and each zone runs its own timeframe's length forward and then stops — so the day reads left to right as a clean staircase of imbalances, hour by hour, instead of a pile of boxes all stretching to the live candle at once.

It is a marking tool, not a signal tool. It draws where higher-timeframe imbalances printed and what has happened to them since, and leaves the read to you.

[b]The zones[/b]

A bullish gap (BISI) is a candle whose low sits above the high two candles back; a bearish gap (SIBI) is a candle whose high sits under the low two candles back. Each is measured on the tracked timeframe's own candles — H1, H4 and H8, each with its own switch — and drawn from its displacement candle forward.

Every zone carries its name inside the box at the right edge, centred on the zone's midline: H1+ for a bullish hourly gap, H4- for a bearish four-hour one. A setting adds the displacement candle's New York hour, so a four-hour gap reads H4+ 2PM. The fill colour states direction; the border is a solid line on every zone so the edges stay readable where timeframes overlap.

[b]The window[/b]

By default a zone extends exactly its own timeframe past its formation: an hourly gap gets one more hour, a four-hour gap four hours, an eight-hour gap eight — then its right edge is fixed. How many of its own candles it runs is a setting, and a second mode keeps the newest zone per timeframe extending until the next zone on that timeframe prints instead.

Either way, if a new gap prints while an earlier zone on the same timeframe is still open, the earlier zone is cut at the new zone's left edge. Nothing overlaps raggedly, and every box's width tells you how long it was the live imbalance.

[b]Volume imbalance and suspension blocks[/b]

A fair value gap measured wick to wick understates a fast leg. Where the candle bodies also gap on either seam of the displacement candle while the wicks still bridge it, that volume imbalance is part of the same region, and the zone absorbs it — the edge extends from the wick to the body it should have reached. Each seam is tested on its own.

A suspension block is three same-direction candles whose bodies gap at both seams with no wick gap anywhere — a span price never traded back through. It is drawn as its own zone, from the first candle's close to the last candle's open, tagged SB.

A body gap across a session or weekend break is a calendar artefact, not an imbalance, so any seam spanning more than one candle's worth of time is excluded from both rules. Absorption and suspension blocks each have their own switch.

[b]Fills[/b]

A fill is a candle body closing through the far edge of the zone. A wick into the zone is a touch, and a touch never counts. By default a fill inside the zone's window shortens the box to the fill bar but keeps it on the chart — the ledger is the point, and a filled gap is still part of the day's record. You can instead leave a fill unmarked, or delete the zone outright. Zones older than a set number of days are removed either way.

[b]Consequent encroachment[/b]

Each zone can carry its midpoint — the consequent encroachment of that gap — as a dotted line through the box. One switch.

[b]Method & repainting[/b]

Each timeframe is read with a single higher-timeframe request using confirmed candles only — offset by one bar with lookahead, the standard non-repainting form. Detection is gated to the chart bar's close, so a zone appears on the first closed chart bar after its higher-timeframe candle completes, and nothing appears mid-bar and then withdraws.

In the default mode a zone's full window is drawn as soon as the zone prints, so its right edge can sit a little ahead of the live candle until the window closes. In the until-the-next-FVG mode the newest zone per timeframe extends rightward as bars print — that is the box tracking the present, not its history changing.

The chart timeframe has to be at or below the timeframe being tracked. On a 4-hour chart you get the H4 and H8 ledgers only, and above H8 the script says so on the chart rather than drawing nothing.

[b]Alerts[/b]

Three, one per timeframe, firing on bar close when a new zone prints on that timeframe — gap or suspension block.

[b]What it will not do[/b]

It places no entries, exits, stops or targets, draws no bias and grades no gap. It does not decide which imbalance matters — that is a judgement about context this script does not have. A quiet day showing only a handful of zones is the tool working, not failing.

[b]Settings[/b]

The three timeframe switches and days of history; the zone extension mode and its candle count; volume imbalance absorption, suspension blocks, and the fill behaviour; bullish, bearish and border colours with the zone fill transparency; the consequent encroachment line, the New York hour tag, and label text size.

[b]Disclaimer[/b]
This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy
// ═══════════════════════════════════════════════════════════════════════════
//  HTF FVG Tracker
//  ─────────────────────────────────────────────────────────────────────────
//  Tracks the H1, H4, H8, Daily, Weekly and Monthly fair value gaps, kept as a clean
//  left-to-right ledger:
// ═══════════════════════════════════════════════════════════════════════════
//@version=6
indicator("HTF FVG Tracker", "HTF FVG",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == ORIGIN GUARD ==
// A drawing anchored on a stored origin can sit thousands of chart bars back. Placing that x walks the
// `time` series to it, and Pine auto-sizes that buffer from what history happened to need, so a live bar
// that needs one more kills the whole script ("requested historical offset is beyond the historical
// buffer's limit"). Function form buffers `time` alone; anything older than ORIGIN_MAX clamps to the
// buffer's edge and draws short from the left instead of crashing.
const int ORIGIN_MAX = 4900
max_bars_back(time, 5000)
//@function Clamps a bar-time anchor to the oldest bar the drawing engine can still place.
//@param t (int) The stored origin time.
//@returns (int) t, or the time of the oldest reachable bar when t is older than that.
f_xClamp(int t) =>
    math.max(t, time[math.min(bar_index, ORIGIN_MAX)])


// == CONSTANTS ================================================================
const color  C_INK = #000000
const color  C_MID = #787B86    // grey — consequent encroachment midline
const int    ZONE_RUNWAY_BARS = 2       // zones stop ~2 bars past the live candle
const int    MS_H1  = 3600000
const int    MS_H4  = 14400000
const int    MS_H8  = 28800000
const int    MS_DAY = 86400000
const int    MS_WK  = 604800000
// A month has no fixed length: 30 days is its nominal span, and its seams are
// judged with two days of tolerance (28 to 31 days between candle opens).
const int    MS_MO  = 2592000000


// == INPUTS ===================================================================
string G_TF    = "Timeframes"
string G_LOGIC = "Logic"
string G_MIT   = "Mitigation"
string G_STYLE = "Style"

bool trackM   = input.bool(false, "M",  group = G_TF, inline = "tfs")
bool trackW   = input.bool(false, "W",  group = G_TF, inline = "tfs")
bool trackD   = input.bool(true, "D",  group = G_TF, inline = "tfs")
bool track8   = input.bool(true, "H8", group = G_TF, inline = "tfs")
bool track4   = input.bool(true, "H4", group = G_TF, inline = "tfs")
bool track1   = input.bool(true, "H1", group = G_TF, inline = "tfs")
// Hard cap per timeframe store — rolling prune. Each zone owns up to three
// lines (CE + two quadrants); 480 lines shared across the stores in use
// (4 → 40 each, 5 → 32, 6 → 26) stays under the 500-line ceiling, so the oldest
// zone is pruned by this script, never stripped of its lines by Pine's own
// garbage collection.
int MAX_STORED = 480 / (3 * (4 + (trackW ? 1 : 0) + (trackM ? 1 : 0)))
int  keepDays = input.int(5, "Days of history", minval = 1, maxval = 45, group = G_TF,
     tooltip = "H1 to D: zones whose displacement candle is older than this many days are removed from the chart. Weekly and monthly zones keep their own history below.")
int  keepW    = input.int(12, "Weeks of history  W", minval = 1, maxval = 104, group = G_TF, inline = "keepwm")
int  keepM    = input.int(12, "Months  M", minval = 1, maxval = 60, group = G_TF, inline = "keepwm",
     tooltip = "Weekly zones older than this many weeks, and monthly zones older than this many months, are removed from the chart.")
float minGapD = input.float(30, "Minimum daily gap (points)", minval = 0, step = 1, group = G_TF,
     tooltip = "A daily gap or suspension block shorter than this, measured wick to wick before any volume imbalance is absorbed, is not drawn. In the chart's price units — 30 suits gold; set it for the instrument on the chart.")
bool pinD = input.bool(true, "Always keep the newest daily zone", group = G_TF,
     tooltip = "The most recent daily zone stays on the chart whatever its age and ignores the daily cap — only a newer daily zone replaces it. A daily imbalance outranks the rest, so the chart is never without one. Older daily zones follow the normal rules.")

bool mergeVi = input.bool(true, "Absorb volume imbalances into the zone", group = G_LOGIC,
     tooltip = "A BODY gap on either seam of the FVG's displacement candle extends the zone to that body edge, whether a wick bridged it (a volume imbalance) or the wicks gapped too. The imbalance is one region; drawing only the wick gap understates it. Seams broken by a missing candle are skipped.")
bool showSb  = input.bool(true, "Suspension blocks", group = G_LOGIC,
     tooltip = "Three same-direction candles with BODY gaps at both seams — a suspended auction. The zone runs from the first candle's close to the third candle's open, tagged SB. A leg that is also a gap draws once, as the SB. Session-gap seams excluded.")
string extendMode = input.string("Until mitigated", "Zone extension",
     options = ["Until mitigated", "Own timeframe", "Until the next FVG"], group = G_LOGIC,
     tooltip = "Until mitigated: every zone runs bar by bar until it is mitigated, capped by the per-timeframe limits below. Own timeframe: a zone runs a fixed window of its own candles past formation, then stops. Until the next FVG: only the newest zone per timeframe extends, until the next same-timeframe zone prints. In the last two a new zone also cuts a still-extending predecessor at its own left edge.")
int capD = input.int(7, "Cap (days)  D", minval = 1, maxval = 60, group = G_LOGIC, inline = "cap")
int cap8 = input.int(3, "H8", minval = 1, maxval = 60, group = G_LOGIC, inline = "cap")
int cap4 = input.int(3, "H4", minval = 1, maxval = 60, group = G_LOGIC, inline = "cap")
int cap1 = input.int(1, "H1", minval = 1, maxval = 60, group = G_LOGIC, inline = "cap",
     tooltip = "Only used with 'Until mitigated' — the longest a zone of each timeframe runs past its formation before it retires unmitigated.")
int capW = input.int(8, "Cap  W (weeks)", minval = 1, maxval = 104, group = G_LOGIC, inline = "capwm")
int capM = input.int(6, "M (months)", minval = 1, maxval = 60, group = G_LOGIC, inline = "capwm",
     tooltip = "Only used with 'Until mitigated' — the longest a weekly or monthly zone runs past its formation before it retires unmitigated.")
int extendN = input.int(1, "Own-timeframe candles to extend", minval = 1, maxval = 12, group = G_LOGIC,
     tooltip = "Only used with 'Own timeframe' extension — how many candles of the zone's own timeframe it runs past its formation.")
string fillMode = input.string("Stop extending", "When a zone is mitigated",
     options = ["Stop extending", "Keep", "Delete"], group = G_LOGIC,
     tooltip = "Default freezes the zone's right edge at the mitigating bar but keeps it painted, so the day's record stays readable. 'Keep' never freezes on mitigation; 'Delete' removes the zone.")

string fillTest = input.string("Body coverage", "Mitigation test",
     options = ["Body coverage", "Close through the far edge"], group = G_MIT,
     tooltip = "Body coverage: a closed candle of the judging timeframe whose BODY (open to close) covers at least the set share of the zone's height. Wicks never count, and a 1m candle that is only the wick of the judging candle does not count either. The formation candle can never mitigate its own zone. Close through the far edge: the older test — a chart close beyond the zone's far side.")
string mitTf  = input.timeframe("15", "Judging timeframe", group = G_MIT,
     tooltip = "The candle whose body is measured. A chart at or above this timeframe judges with its own candles.")
float  mitPct = input.float(55, "Body must cover (% of zone)", minval = 1, maxval = 100, step = 1, group = G_MIT,
     tooltip = "An engulfing body is 100%. Overlap = min(body top, zone top) − max(body bottom, zone bottom), as a share of the zone's height.")

color bullColor = input.color(color.rgb(29, 94, 216), "Bullish", group = G_STYLE, inline = "cols")
color bearColor = input.color(color.rgb(202, 40, 40), "Bearish", group = G_STYLE, inline = "cols")
color edgeColor = input.color(#000000, "Border",  group = G_STYLE, inline = "cols")
int   fillOpac  = input.int(88, "Zone fill transparency", minval = 50, maxval = 99, group = G_STYLE,
     tooltip = "Several timeframes overlap constantly; 88 keeps a double overlap readable as two zones rather than one slab.")
bool  showCe   = input.bool(true, "Consequent encroachment midline", group = G_STYLE)
bool  showQuad = input.bool(true, "Quadrant lines (0.25 / 0.75)", group = G_STYLE,
     tooltip = "Dotted black lines at a quarter and three quarters of the gap, no labels. With the midline they divide the zone into quadrants. They run and retire with the zone.")
bool  tagHour = input.bool(false, "Add the candle's New York hour to the caption", group = G_STYLE,
     tooltip = "\"H4+ 2PM\" instead of \"H4+\" — the displacement candle's open, New York clock.")
string labelSizeIn = input.string("small", "Label text size",
     options = ["tiny", "small", "normal", "large"], group = G_STYLE)

//@function Resolves the label-size input to a size constant.
//@param s (string) The input choice.
//@returns (string) A size.* constant.
f_lblSize(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

string LBL_SZ = f_lblSize(labelSizeIn)

//@variable Milliseconds per chart bar — right-edge runway arithmetic.
int msPerBar = timeframe.in_seconds() * 1000
//@variable True in the default mode — zones extend on their own until mitigated or capped.
bool capped = extendMode == "Until mitigated"
//@variable The body-coverage threshold as a fraction.
float mitFrac = mitPct / 100.0

// == MODEL ====================================================================
//@type One tracked zone — FVG or suspension block — and its drawings.
type Fvg
    box   bx
    label lb
    line  ce
    line  q25
    line  q75
    float top
    float bottom
    bool  bull
    int   born      // first candle's open time — the zone's left edge, so the box touches the wick that made the gap
    int   formed    // the formation candle's close time — nothing before it can mitigate
    int   expiry    // fixed right edge (own-timeframe) · cap (until mitigated) · na = chase mode
    bool  live      // window still open (unmitigated, uncut, unexpired)

var array<Fvg> store1 = array.new<Fvg>(0)
var array<Fvg> store4 = array.new<Fvg>(0)
var array<Fvg> store8 = array.new<Fvg>(0)
var array<Fvg> storeD = array.new<Fvg>(0)
var array<Fvg> storeW = array.new<Fvg>(0)
var array<Fvg> storeM = array.new<Fvg>(0)
// The slot holds each timeframe's one still-extending zone (0 or 1 element) —
// a size-1 array so functions can swap it in place. Only the two cut modes
// use it; in "Until mitigated" every live zone extends on its own.
var array<Fvg> slot1  = array.new<Fvg>(0)
var array<Fvg> slot4  = array.new<Fvg>(0)
var array<Fvg> slot8  = array.new<Fvg>(0)
var array<Fvg> slotD  = array.new<Fvg>(0)
var array<Fvg> slotW  = array.new<Fvg>(0)
var array<Fvg> slotM  = array.new<Fvg>(0)

// == HELPERS ==================================================================
//@function 12-hour New York clock tag for a bar-open time, e.g. "2PM".
//@param t (int) Bar time in milliseconds.
//@returns (string) The hour tag.
f_nyHour(int t) =>
    int h   = hour(t, "America/New_York")
    int h12 = h % 12 == 0 ? 12 : h % 12
    str.tostring(h12) + (h < 12 ? "AM" : "PM")

//@function Moves a zone's right edge — box, caption, CE and quadrants — to rightT.
//@param z (Fvg) The zone.
//@param rightT (int) The bar time the zone's drawings end at.
//@returns (void)
f_setRight(Fvg z, int rightT) =>
    box.set_right(z.bx, rightT)
    label.set_x(z.lb, rightT)
    if not na(z.ce)
        line.set_x2(z.ce, rightT)
    if not na(z.q25)
        line.set_x2(z.q25, rightT)
        line.set_x2(z.q75, rightT)

//@function Freezes a zone's right edge — it stops extending at rightT.
//@param z (Fvg) The zone to freeze.
//@param rightT (int) The bar time the zone stops at.
//@returns (void)
f_freeze(Fvg z, int rightT) =>
    z.live := false
    f_setRight(z, rightT)

//@function Deletes a zone's drawings.
//@param z (Fvg) The zone to remove from the chart.
//@returns (void)
f_kill(Fvg z) =>
    box.delete(z.bx)
    label.delete(z.lb)
    line.delete(z.ce)
    line.delete(z.q25)
    line.delete(z.q75)

//@function Draws one zone — black-bordered branding box, inside caption on the
//          midline at the right edge, optional CE and quadrants — and returns
//          its record.
//@param bull (bool) Direction — picks the branding fill.
//@param top (float) Zone top.
//@param bot (float) Zone bottom.
//@param born (int) Left edge — the first candle's open time.
//@param formed (int) The formation candle's close time.
//@param expiry (int) Fixed right edge or cap, or na in chase mode.
//@param txt (string) The caption ("H1+", "H4 SB-", …).
//@returns (Fvg) The new zone record, live.
f_spawn(bool bull, float top, float bot, int born, int formed, int expiry, string txt) =>
    // A fixed own-timeframe window draws the whole window at once; chase and
    // until-mitigated start at a short runway and walk right on the last bar.
    int rightT = na(expiry) or capped ? time + ZONE_RUNWAY_BARS * msPerBar : expiry
    int left   = f_xClamp(born)
    box bx = box.new(left, top, rightT, bot,
         xloc         = xloc.bar_time,
         border_color = edgeColor,
         border_width = 1,
         border_style = line.style_solid,
         bgcolor      = color.new(bull ? bullColor : bearColor, fillOpac))
    // Caption INSIDE the zone: anchored at the right edge on the midline —
    // label_right puts the text to the LEFT of its anchor, so it sits inside.
    label lb = label.new(rightT, math.avg(top, bot), txt,
         xloc      = xloc.bar_time,
         style     = label.style_label_right,
         color     = color.new(#FFFFFF, 100),
         textcolor = C_INK,
         size      = LBL_SZ,
         textalign = text.align_right)
    label.set_text_font_family(lb, font.family_monospace)
    line ce = showCe ?
         line.new(left, math.avg(top, bot), rightT, math.avg(top, bot),
             xloc = xloc.bar_time, color = C_MID, style = line.style_dotted, width = 1) :
         line(na)
    // Quadrants of the gap itself: a quarter and three quarters of its height.
    float h   = top - bot
    float y25 = bot + h * 0.25
    float y75 = bot + h * 0.75
    line q25 = showQuad ?
         line.new(left, y25, rightT, y25,
             xloc = xloc.bar_time, color = C_INK, style = line.style_dotted, width = 1) :
         line(na)
    line q75 = showQuad ?
         line.new(left, y75, rightT, y75,
             xloc = xloc.bar_time, color = C_INK, style = line.style_dotted, width = 1) :
         line(na)
    Fvg.new(bx = bx, lb = lb, ce = ce, q25 = q25, q75 = q75, top = top, bottom = bot, bull = bull,
         born = born, formed = formed, expiry = expiry, live = true)

//@function Detects a FVG (or suspension block) on a timeframe's three newest
//          confirmed candles; in the cut modes freezes the previous zone at
//          the new one's left edge; spawns the new zone. A = oldest, C = newest.
//@param fire (bool) True on the chart bar where a new candle of this timeframe begins.
//@param oA (float) Candle A open.   @param hA (float) A high.  @param lA (float) A low.  @param cA (float) A close.
//@param oB (float) Candle B open.   @param hB (float) B high.  @param lB (float) B low.  @param cB (float) B close.
//@param oC (float) Candle C open.   @param hC (float) C high.  @param lC (float) C low.  @param cC (float) C close.
//@param tA (int) A open time.  @param tB (int) B open time.  @param tC (int) C open time.
//@param tfMs (int) The timeframe's length in milliseconds — seam contiguity test.
//@param seamTol (int) Allowed difference from tfMs between candle opens (0 = exact).
//@param formedAt (int) The formation close when the candle length is not fixed, or na for tC + tfMs.
//@param capMs (int) The until-mitigated cap for this timeframe, in milliseconds.
//@param minPts (float) Minimum gap height, wick to wick, for a zone to print (0 = any).
//@param store (array<Fvg>) This timeframe's zone store.
//@param slot (array<Fvg>) This timeframe's live-zone slot (cut modes only).
//@param tfTag (string) "H1" / "H4" / "H8" / "D" / "W" / "M".
//@returns (bool) True when a new zone printed.
f_track(bool fire, float oA, float hA, float lA, float cA,
     float oB, float hB, float lB, float cB,
     float oC, float hC, float lC, float cC,
     int tA, int tB, int tC, int tfMs, int seamTol, int formedAt, int capMs, float minPts,
     array<Fvg> store, array<Fvg> slot, string tfTag) =>
    bool made = false
    if fire and not na(cA) and not na(cC) and not na(tB)
        // A seam broken by a session gap is not a VI seam — the candles must touch.
        bool seamAB = math.abs(tB - tA - tfMs) <= seamTol
        bool seamBC = math.abs(tC - tB - tfMs) <= seamTol
        bool bisi   = lC > hA
        bool sibi   = hC < lA
        float  top  = na
        float  bot  = na
        bool   bull = bisi
        string kind = ""
        // A leg that is both a gap and a suspension block draws once, as the SB: its span
        // always contains the wick gap's.
        bool upTrio   = cA > oA and cB > oB and cC > oC and oB > cA and oC > cB
        bool downTrio = cA < oA and cB < oB and cC < oC and oB < cA and oC < cB
        if showSb and seamAB and seamBC and (upTrio or downTrio) and (upTrio ? oC - cA : cA - oC) >= minPts
            kind := "SB"
            bull := upTrio
            top  := upTrio ? oC : cA
            bot  := upTrio ? cA : oC
        else if (bisi or sibi) and (bisi ? lC - hA : lA - hC) >= minPts
            kind := "FVG"
            top  := bisi ? lC : lA
            bot  := bisi ? hA : hC
            if mergeVi
                // A body gap on a seam is part of the imbalance whether or not the
                // wicks bridge it: the zone runs to the body edge either way.
                if bisi
                    if seamAB and math.min(oB, cB) > math.max(oA, cA)
                        bot := math.min(bot, math.max(oA, cA))
                    if seamBC and math.min(oC, cC) > math.max(oB, cB)
                        top := math.max(top, math.min(oC, cC))
                else
                    if seamAB and math.max(oB, cB) < math.min(oA, cA)
                        top := math.max(top, math.min(oA, cA))
                    if seamBC and math.max(oC, cC) < math.min(oB, cB)
                        bot := math.min(bot, math.max(oC, cC))
        if kind != ""
            // Candle C closes at tC + tfMs — the formation moment.
            int formed = na(formedAt) ? tC + tfMs : formedAt
            // THE CUT (cut modes only) — the new zone freezes a still-live
            // predecessor at its own left edge. A fixed window is only ever
            // shortened, never grown.
            if not capped and slot.size() > 0
                Fvg prev = slot.get(0)
                f_freeze(prev, na(prev.expiry) ? tA : math.min(tA, prev.expiry))
                slot.clear()
            // The window: until-mitigated runs to formation + cap; own-timeframe
            // runs extendN candles of its own timeframe past formation; chase is na.
            int expiry = capped ? formed + capMs :
                 extendMode == "Own timeframe" ? formed + tfMs * extendN : int(na)
            string txt = tfTag + (kind == "SB" ? " SB" : "") + (bull ? "+" : "-") +
                 (tagHour ? " " + f_nyHour(tB) : "")
            Fvg z = f_spawn(bull, top, bot, tA, formed, expiry, txt)
            store.push(z)
            if not capped
                slot.push(z)
            while store.size() > MAX_STORED
                Fvg old = store.shift()
                if old.live
                    slot.clear()
                f_kill(old)
            made := true
    made

//@function Mitigation handling, expiry and age pruning for one timeframe's store.
//@param store (array<Fvg>) The timeframe's zone store.
//@param slot (array<Fvg>) The timeframe's live-zone slot.
//@param judge (bool) True when a judging-timeframe candle has just closed.
//@param bTop (float) That candle's body top.
//@param bBot (float) That candle's body bottom.
//@param jT (int) That candle's open time.
//@param pinLast (bool) True to exempt the newest zone from the age prune and its cap.
//@param keepMs (int) How long a zone stays on the chart, from its first candle, in milliseconds.
//@returns (void)
f_sweep(array<Fvg> store, array<Fvg> slot, bool judge, float bTop, float bBot, int jT, bool pinLast, int keepMs) =>
    int cutoff = time - keepMs
    if store.size() > 0
        for i = store.size() - 1 to 0
            Fvg z = store.get(i)
            bool pinned = pinLast and i == store.size() - 1
            bool filledNow = false
            if fillTest == "Body coverage"
                // The judged candle must have opened at or after the formation
                // close — the displacement candle never mitigates its own gap.
                if judge and jT >= z.formed
                    float ov = math.min(bTop, z.top) - math.max(bBot, z.bottom)
                    float hz = z.top - z.bottom
                    filledNow := ov > 0 and hz > 0 and ov / hz >= mitFrac
            else
                filledNow := z.bull ? close < z.bottom : close > z.top
            if (z.born < cutoff and not pinned) or (fillMode == "Delete" and filledNow)
                if z.live
                    slot.clear()
                // remove() returns the element — keep it off the branch tail so
                // both branches of this if stay void (CE10235)
                Fvg gone = store.remove(i)
                f_kill(gone)
            else if fillMode == "Stop extending" and z.live and filledNow
                // Shorten to the mitigating bar — never past a fixed window's edge.
                f_freeze(z, na(z.expiry) ? time : math.min(time, z.expiry))
                slot.clear()
            else if z.live and not na(z.expiry) and time >= z.expiry and not pinned
                // The window ran its course — the zone is history now.
                f_freeze(z, z.expiry)
                slot.clear()

//@function Walks every still-extending zone's right edge to the runway on the
//          last bar — chase zones and until-mitigated zones (never past their
//          cap). A fixed own-timeframe window already has its edge.
//@param store (array<Fvg>) The timeframe's zone store.
//@param pinLast (bool) True when the newest zone ignores its cap.
//@returns (void)
f_extend(array<Fvg> store, bool pinLast) =>
    if store.size() > 0
        for i = 0 to store.size() - 1
            Fvg z = store.get(i)
            if z.live and (na(z.expiry) or capped)
                int rightT = time + ZONE_RUNWAY_BARS * msPerBar
                if not na(z.expiry) and not (pinLast and i == store.size() - 1)
                    rightT := math.min(rightT, z.expiry)
                f_setRight(z, rightT)

// == HTF DATA — one call per timeframe, confirmed candles only ================
[h1oA, h1hA, h1lA, h1cA, h1oB, h1hB, h1lB, h1cB, h1oC, h1hC, h1lC, h1cC, h1tA, h1tB, h1tC] =
     request.security(syminfo.tickerid, "60",
         [open[3], high[3], low[3], close[3],
          open[2], high[2], low[2], close[2],
          open[1], high[1], low[1], close[1],
          time[3], time[2], time[1]],
         lookahead = barmerge.lookahead_on)

[h4oA, h4hA, h4lA, h4cA, h4oB, h4hB, h4lB, h4cB, h4oC, h4hC, h4lC, h4cC, h4tA, h4tB, h4tC] =
     request.security(syminfo.tickerid, "240",
         [open[3], high[3], low[3], close[3],
          open[2], high[2], low[2], close[2],
          open[1], high[1], low[1], close[1],
          time[3], time[2], time[1]],
         lookahead = barmerge.lookahead_on)

[h8oA, h8hA, h8lA, h8cA, h8oB, h8hB, h8lB, h8cB, h8oC, h8hC, h8lC, h8cC, h8tA, h8tB, h8tC] =
     request.security(syminfo.tickerid, "480",
         [open[3], high[3], low[3], close[3],
          open[2], high[2], low[2], close[2],
          open[1], high[1], low[1], close[1],
          time[3], time[2], time[1]],
         lookahead = barmerge.lookahead_on)

[dOA, dHA, dLA, dCA, dOB, dHB, dLB, dCB, dOC, dHC, dLC, dCC, dTA, dTB, dTC] =
     request.security(syminfo.tickerid, "D",
         [open[3], high[3], low[3], close[3],
          open[2], high[2], low[2], close[2],
          open[1], high[1], low[1], close[1],
          time[3], time[2], time[1]],
         lookahead = barmerge.lookahead_on)

[wOA, wHA, wLA, wCA, wOB, wHB, wLB, wCB, wOC, wHC, wLC, wCC, wTA, wTB, wTC] =
     request.security(syminfo.tickerid, "W",
         [open[3], high[3], low[3], close[3],
          open[2], high[2], low[2], close[2],
          open[1], high[1], low[1], close[1],
          time[3], time[2], time[1]],
         lookahead = barmerge.lookahead_on)

[mOA, mHA, mLA, mCA, mOB, mHB, mLB, mCB, mOC, mHC, mLC, mCC, mTA, mTB, mTC] =
     request.security(syminfo.tickerid, "M",
         [open[3], high[3], low[3], close[3],
          open[2], high[2], low[2], close[2],
          open[1], high[1], low[1], close[1],
          time[3], time[2], time[1]],
         lookahead = barmerge.lookahead_on)

// == JUDGING CANDLE — the last closed candle of the mitigation timeframe =====
[jO, jC, jT0] = request.security(syminfo.tickerid, mitTf, [open[1], close[1], time[1]],
     lookahead = barmerge.lookahead_on)

// A timeframe below the chart's own cannot be tracked from here.
int  chartSecs = timeframe.in_seconds()
bool ok1 = chartSecs <= 3600
bool ok4 = chartSecs <= 14400
bool ok8 = chartSecs <= 28800
bool okD = chartSecs <= 86400
bool okW = chartSecs <= 604800
bool okM = chartSecs <= timeframe.in_seconds("M")

bool fire1 = track1 and ok1 and timeframe.change("60")
bool fire4 = track4 and ok4 and timeframe.change("240")
bool fire8 = track8 and ok8 and timeframe.change("480")
bool fireD = trackD and okD and timeframe.change("D")
bool fireW = trackW and okW and timeframe.change("W")
bool fireM = trackM and okM and timeframe.change("M")

// A chart at or above the judging timeframe judges with its own candle, every
// bar; below it, the judged candle is the one that just closed on that timeframe.
bool  useOwn = chartSecs >= timeframe.in_seconds(mitTf)
bool  judge  = useOwn ? true : timeframe.change(mitTf)
float bodyTop = useOwn ? math.max(open, close) : math.max(jO, jC)
float bodyBot = useOwn ? math.min(open, close) : math.min(jO, jC)
int   judgeT  = useOwn ? time : jT0

// == TRACKING =================================================================
bool new1 = false
bool new4 = false
bool new8 = false
bool newD = false
bool newW = false
bool newM = false
if barstate.isconfirmed
    new1 := f_track(fire1, h1oA, h1hA, h1lA, h1cA, h1oB, h1hB, h1lB, h1cB,
         h1oC, h1hC, h1lC, h1cC, h1tA, h1tB, h1tC, MS_H1, 0, int(na), cap1 * MS_DAY, 0.0, store1, slot1, "H1")
    new4 := f_track(fire4, h4oA, h4hA, h4lA, h4cA, h4oB, h4hB, h4lB, h4cB,
         h4oC, h4hC, h4lC, h4cC, h4tA, h4tB, h4tC, MS_H4, 0, int(na), cap4 * MS_DAY, 0.0, store4, slot4, "H4")
    new8 := f_track(fire8, h8oA, h8hA, h8lA, h8cA, h8oB, h8hB, h8lB, h8cB,
         h8oC, h8hC, h8lC, h8cC, h8tA, h8tB, h8tC, MS_H8, 0, int(na), cap8 * MS_DAY, 0.0, store8, slot8, "H8")
    newD := f_track(fireD, dOA, dHA, dLA, dCA, dOB, dHB, dLB, dCB,
         dOC, dHC, dLC, dCC, dTA, dTB, dTC, MS_DAY, 0, int(na), capD * MS_DAY, minGapD, storeD, slotD, "D")
    // A weekly or monthly candle opens on the chart bar its period begins, so that
    // bar's time is the formation close. A DST change shifts a weekly open by one
    // hour; a month runs 28 to 31 days.
    newW := f_track(fireW, wOA, wHA, wLA, wCA, wOB, wHB, wLB, wCB,
         wOC, wHC, wLC, wCC, wTA, wTB, wTC, MS_WK, MS_H1, time, capW * MS_WK, 0.0, storeW, slotW, "W")
    newM := f_track(fireM, mOA, mHA, mLA, mCA, mOB, mHB, mLB, mCB,
         mOC, mHC, mLC, mCC, mTA, mTB, mTC, MS_MO, 2 * MS_DAY, time, capM * MS_MO, 0.0, storeM, slotM, "M")
    int keepHtf = keepDays * MS_DAY
    f_sweep(store1, slot1, judge, bodyTop, bodyBot, judgeT, false, keepHtf)
    f_sweep(store4, slot4, judge, bodyTop, bodyBot, judgeT, false, keepHtf)
    f_sweep(store8, slot8, judge, bodyTop, bodyBot, judgeT, false, keepHtf)
    f_sweep(storeD, slotD, judge, bodyTop, bodyBot, judgeT, pinD, keepHtf)
    f_sweep(storeW, slotW, judge, bodyTop, bodyBot, judgeT, false, keepW * MS_WK)
    f_sweep(storeM, slotM, judge, bodyTop, bodyBot, judgeT, false, keepM * MS_MO)

if barstate.islast
    f_extend(store1, false)
    f_extend(store4, false)
    f_extend(store8, false)
    f_extend(storeD, pinD)
    f_extend(storeW, false)
    f_extend(storeM, false)

// A chart above M has nothing to track — say so instead of drawing nothing.
var table tfNote = na
if barstate.islast and not (ok1 or ok4 or ok8 or okD or okW or okM)
    if na(tfNote)
        tfNote := table.new(position.top_right, 1, 1)
    table.cell(tfNote, 0, 0, "HTF FVG: chart timeframe above M — nothing to track",
         text_color = C_INK, text_size = LBL_SZ, bgcolor = color.white)

// == ALERTS — script scope, bar close =========================================
alertcondition(new1, "New H1 zone", "H1 FVG/SB printed on {{ticker}}")
alertcondition(new4, "New H4 zone", "H4 FVG/SB printed on {{ticker}}")
alertcondition(new8, "New H8 zone", "H8 FVG/SB printed on {{ticker}}")
alertcondition(newD, "New D zone",  "D FVG/SB printed on {{ticker}}")
alertcondition(newW, "New W zone",  "W FVG/SB printed on {{ticker}}")
alertcondition(newM, "New M zone",  "M FVG/SB printed on {{ticker}}")
````
