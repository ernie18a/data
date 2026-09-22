<!-- tradingview-pine-id: PUB;d9bc754697004befa6a79f7c635bf24f -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# [Chrona] Opening Range Breakout

Source: https://www.tradingview.com/script/S1bnZOYx-Chrona-Opening-Range-Breakout/

## Description

[Chrona] Opening Range Breakout

An opening-range tool for instruments that have an opening auction. It draws the
first 15 and 30 minutes of a session as a range, marks the candle that broke it,
and projects targets measured from the broken level.

WHAT IT DRAWS

- The 15-minute and 30-minute opening range of each enabled session, as a box
  whose high and low freeze when the range closes. The right edge keeps
  following the last printed bar until the session ends, so the box grows with
  price and never extends past it.
- An optional midline through the range.
- A tag on the candle that confirmed the break — above it on an upside break,
  below it on a downside one, so the side carries the direction.
- 1R and 2R targets for the 30-minute range, measured from the broken level.
- Right-axis price tags for the levels and targets of whichever session is open.
- Optional pre-market ranges: the same opening-range construction run on the
  lead minutes before a session opens.

Four sessions run independently — Asia, London, New York and COMEX — each
evaluated in its own timezone.

ORIGINALITY AND UTILITY

Multi-session opening ranges are common. These are the parts that are not, and
they are the reason this exists rather than a settings preset of something else:

- The range is built from one-minute intrabars, not from chart bars. On a
  15-minute chart a chart-bar implementation cannot see inside the first bar, so
  its "15-minute range" is whatever the first candle happened to be. This one
  requests 1-minute data and measures the real first 15 and 30 minutes, so the
  box is the same box on a 1-minute chart and on an hourly one.
- Three break-confirm modes — touch, chart close, and a 5-minute close — and the
  5-minute close is computed natively from time("5") buckets rather than
  requested from a higher timeframe. A higher-timeframe request returns the
  developing value while the bar is still forming, which is how a break appears
  and then un-appears. Nothing here repaints.
- Targets are anchored to the broken level, not to the range. A level-anchored
  1R sits one range-width from the level price; a range-anchored one drifts with
  whichever edge is used to measure it. The two disagree on every trade, and the
  level is the price actually broken.
- Each session carries its own timezone, so daylight saving is resolved per
  region rather than by one global offset. London shifting a week before New
  York does not move the New York range.
- Nothing is hardcoded to 09:30. Instruments with no equity open work by typing
  their real hours: XAUUSD has no cash open at all, and COMEX gold's pit open is
  08:20 New York time.
- The pre-market range is derived from its parent session's own window rather
  than configured separately, so the two cannot drift apart when either is
  edited, and its levels stay live through the parent session — the range forms
  before the open and the break lands after it.
- The break tag exists because of a specific blind spot: on a 1- or 2-minute
  chart you cannot see where the 5-minute bar closed. The tag marks the candle
  that carried that close.

METHOD

For each enabled session the script takes the session window you set, in that
session's timezone, and masks it to weekdays. It collects one-minute highs and
lows from the session open and freezes the extremes at 15 and 30 minutes. A
break is tested against the frozen level in the confirm mode you choose. Once
broken, targets are placed at one and two range-widths from the level, and a
retest is reported when price returns to within a tenth of a range-width of it.
Everything is evaluated on confirmed bars.

ALERTS

Break up, break down, both-sides-broken, and level retest, per session and per
range. Alerts are armed in the settings, but the script's alert calls do nothing
until TradingView has an alert of its own on this indicator with the condition
"Any alert() function call".

Two things about TradingView alerts worth knowing: they fire on the realtime bar
only, never on bars that already printed, so a break that happened before the
alert existed leaves no alert behind; and TradingView saves a copy of the script
when the alert is created, so an alert keeps running the version it was made
from. Re-create alerts after updating.

REPAINT

Nothing repaints. Every value is read on confirmed bars, higher-timeframe
requests are not used, and the 5-minute confirm lands one chart bar after the
5-minute close by construction rather than being back-dated.

LIMITATIONS

- The range needs one-minute data. How far back that data is available varies by
  timeframe and by your TradingView plan, so on a lower plan the historical
  boxes stop earlier than they do on a higher one. "Prior days to keep" defaults
  to 1, which keeps this within the recent sessions most of the time.
- On a 1-minute chart and below there is no lower timeframe to request, so the
  script falls back to the chart bars themselves — which at those timeframes are
  already at or finer than 1-minute resolution.
- Sessions are only as correct as the hours you give them. The defaults are
  reasonable for index futures; other instruments need their real hours typed in.
- An opening range assumes an opening. On instruments that trade continuously
  with no auction, the pre-market range in particular is a borrowed idea rather
  than a measured one.

This is an analysis tool, not financial advice.

---

## Source Code

````pine
//@version=6
// [Chrona] Opening Range Breakout — range, bias and targets. The chart
// carries the range, the levels and the rays; breaks and retests are alerts.
// The first 15m + 30m of a session, break-confirm modes {Touch, Chart close,
// 5m close}, LEVEL-anchored 1R/2R targets (level ± k·range), retest tolerance
// 0.1·range. No repaint: everything runs on confirmed bars, and the 5m close
// is asked of the 5m series for its PREVIOUS, already-closed bar — the form
// the manual documents as non-repainting, expression[1] with lookahead_on,
// whose two halves are interdependent. A plain request.security would return
// the developing HTF value intra-bar and is still never used.
// request.security_lower_tf is a different animal and IS used, for the range
// only: it hands back already-closed 1m bars rather than a developing value.
// The array of the CURRENT chart bar is still growing, so it is read on
// confirmed bars like everything else.
//
// Asia / London / New York / COMEX run independently, each a window in its OWN
// timezone so DST is handled per region. The opening range is derived as the
// first 15/30 minutes of whatever window you set — nothing is hardcoded to 0930,
// so instruments with no equity open (XAUUSD has no cash open at all; COMEX GC's
// pit open is 08:20 ET) just need their real hours typed in.
//
// One switch adds a pre-market to every ticked session: the same opening range
// run on the lead minutes BEFORE that session's open, computed from the
// session's own window so the two can never drift apart, and in the session's
// own timezone. Its levels stay live from its own open through to the END of
// its parent's session, since the range forms pre-open and the break lands
// during RTH. On futures this is a borrowed idea — GC trades continuously
// from 18:00 ET, so a pre-open window has no auction behind it.
//
// The range box is a ZONE, not a 30-minute stub: its high/low freeze when the
// range closes, but its right edge follows the last printed bar until the
// session ends, so it grows with price and never extends past it. Each
// session row carries its own fill swatch, and its pre-market a second one
// from the Pre fills row, so the two never have to be told apart by time. The
// swatches carry hue only -- one slider under Style sets the fill transparency
// for all of them at once.
//
// alert() is inert until TradingView has an alert of its own attached to the
// script, and it fires on the realtime bar only, so a break that predates the
// alert leaves no record at all -- the chart carries no marks. TradingView
// snapshots
// the script when the alert is created, so an existing alert keeps running
// the OLD code: re-create it after editing, it is not invalidated for you.
indicator("[Chrona] Opening Range Breakout", overlay = true,
     max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ── Sessions ────────────────────────────────────────────────────────────────
gS      = "Sessions"
onAsia  = input.bool(false, "Asia", group = gS, inline = "a")
winAsia = input.session("0900-1500", "", group = gS, inline = "a",
     tooltip = "Asia/Tokyo. Gold flow: Shanghai is 0900-1530 CST.")
colAsia = input.color(color.new(#2962ff, 0), "", group = gS, inline = "a")

onLdn   = input.bool(false, "London", group = gS, inline = "l")
winLdn  = input.session("0800-1630", "", group = gS, inline = "l",
     tooltip = "Europe/London. Gold's dominant session — LBMA auctions 1030 / 1500.")
colLdn  = input.color(color.new(#2962ff, 0), "", group = gS, inline = "l")

onNY    = input.bool(true, "New York", group = gS, inline = "n")
winNY   = input.session("0930-1600", "", group = gS, inline = "n",
     tooltip = "America/New_York. Equity cash open.")
colNY   = input.color(color.new(#2962ff, 0), "", group = gS, inline = "n")

onCmx   = input.bool(false, "COMEX", group = gS, inline = "c")
winCmx  = input.session("0820-1330", "", group = gS, inline = "c",
     tooltip = "America/New_York. Metals pit / RTH open — GC, SI, HG. " +
     "Spot XAUUSD has no open of its own, so this is the closest thing to one.")
colCmx  = input.color(color.new(#2962ff, 0), "", group = gS, inline = "c")

preOn   = input.bool(false, "Show pre-market ranges", group = gS,
     tooltip = "One switch for all four: every session ticked above also gets " +
     "the opening range of the lead minutes BEFORE its open. A session you " +
     "have not ticked gets nothing, so this follows your session picks rather " +
     "than adding a set of its own.")

preLead = input.int(60, "Pre-market lead (minutes)", minval = 5, maxval = 720,
     step = 5, group = gS,
     tooltip = "How far before a ticked session's open its pre-market range " +
     "starts. 60 puts NY pre at 0830-0930 (US data anchors it) and COMEX pre " +
     "at 0720-0820. Gold's only real pre-open events are the London open and " +
     "the LBMA AM auction (0530 ET) — for those, tick London as a session.")

// ── Display ─────────────────────────────────────────────────────────────────
gD       = "Display"
gT       = "Break tags"
gA       = "Alerts"
show15   = input.bool(true,  "Show 15m range", group = gD)
show30   = input.bool(true,  "Show 30m range", group = gD)
confMode = input.string("Chart close", "Break confirm",
     options = ["Touch", "Chart close", "5m close"], group = gD)
showT    = input.bool(true,  "1R / 2R targets (30m)", group = gD)
tag5On   = input.bool(true,  "Tag 5m close outside the 30m range", group = gT,
     inline = "t5",
     tooltip = "The reason this exists: on a 1m or 2m chart you cannot see " +
     "where the 5m bar closed. This marks the candle that carried that close " +
     "— above it on an upside break, below it on a downside one — whatever " +
     "'Break confirm' is set to.")
tag5Col  = input.color(color.new(#f23645, 0), "", group = gT, inline = "t5")
tagCOn   = input.bool(false, "Also tag the chart-close break", group = gT,
     inline = "tc",
     tooltip = "Same mark for a close of the CHART's own timeframe — the " +
     "earlier, looser read. Off by default so the 5m tag stands alone.")
tagCCol  = input.color(color.new(#787b86, 0), "", group = gT, inline = "tc")
tagTxCol = input.color(color.white, "Tag text", group = gT)
daysBack = input.int(1, "Prior days to keep (0 = current session only)", minval = 0,
     group = gD)
alertsOn = input.bool(true, "Alerts (create a TradingView alert too)",
     group = gA,
     tooltip = "This box only arms the script's alert calls. TradingView " +
     "still needs an alert of its own on this script, condition 'Any " +
     "alert() function call' — the box on its own fires nothing. Alerts " +
     "fire on the realtime bar only, never on bars that already printed, " +
     "and an alert keeps running the version of the script it was made from.")

// ── Style ───────────────────────────────────────────────────────────────────
// One transparency for every fill, so a swatch only ever carries a HUE. The
// swatches ship fully opaque for that reason -- their own opacity sliders no
// longer reach the fill, and the tooltip says so rather than leaving a dead
// control to be discovered. The midline follows the same rule. The range
// outline is the one exception and still takes its alpha from its own swatch,
// which is why only that swatch ships with any.
gV       = "Style"
outSty   = input.string("Dashed", "Range outline", inline = "ol", group = gV,
     options = ["Dashed", "Dotted", "Solid"])
outCol   = input.color(color.new(#2962ff, 20), "", inline = "ol", group = gV)
fillTransp = input.int(90, "Fill transparency", minval = 0, maxval = 100,
     group = gV,
     tooltip = "0 = solid, 100 = invisible — LOWER is more visible. Set it " +
     "HERE: the opacity slider inside the four session swatches and the Pre " +
     "fills row has no effect on the fill. The outline keeps its own opacity, " +
     "from the swatch on the Range outline row.")
midOn    = input.bool(false, "Range midline", inline = "md", group = gV)
midSty   = input.string("Dotted", "", inline = "md", group = gV,
     options = ["Dashed", "Dotted", "Solid"])
midCol   = input.color(color.new(#2962ff, 0), "", inline = "md", group = gV,
     tooltip = "Halfway between the 30m range high and low. It rides on that " +
     "range, so it needs Show 30m range ticked.")
midTransp = input.int(50, "Midline transparency", minval = 0, maxval = 100,
     group = gV,
     tooltip = "0 = solid, 100 = invisible — LOWER is more visible. Set it " +
     "HERE: the opacity slider inside the midline's own swatch has no effect.")
preColA  = input.color(color.new(#26a69a, 0), "Pre fills: Asia", inline = "pf",
     group = gV)
preColL  = input.color(color.new(#26a69a, 0), "LDN", inline = "pf", group = gV)
preColN  = input.color(color.new(#26a69a, 0), "NY", inline = "pf", group = gV)
preColC  = input.color(color.new(#26a69a, 0), "GC", inline = "pf", group = gV)

bStyle = outSty == "Dashed" ? line.style_dashed :
     outSty == "Dotted" ? line.style_dotted : line.style_solid
mStyle = midSty == "Dashed" ? line.style_dashed :
     midSty == "Dotted" ? line.style_dotted : line.style_solid
midColT = color.new(midCol, midTransp)

RT_TOL = 0.10           // retest tolerance, fraction of range width (ORB_TOL)

// The range is measured on 1m bars, never on the chart's own. A chart coarser
// than the range has no bar inside it -- an hourly has nothing between 09:30
// and 10:00 -- and a session opening mid-bar skips that bar outright (the
// manual's own example: a 09:00 bar is not in a 09:30 session). Read from the
// chart, an hourly NY range came out as the 10:00-11:00 candle. Read from 1m,
// every timeframe draws the same box, and an 08:20 COMEX open lands on the
// minute instead of 10 minutes late.
// ignore_invalid_timeframe was expected to make the 1m and sub-1m case an
// EMPTY array rather than an error. It does not: on a 30s chart "1" is a
// HIGHER timeframe and the script died with a runtime error (RE10052). So the
// request is not made at all below a minute -- the arrays stay empty and the
// scan falls back to the chart bar itself, which at those timeframes already
// resolves every minute boundary. v6 permits request.*() inside a conditional
// block: /pine-script-docs/migration-guides/to-pine-version-6/
array<float> mH = array.new<float>()
array<float> mL = array.new<float>()
array<int>   mT = array.new<int>()
if timeframe.in_seconds() > 60
    [xH, xL, xT] = request.security_lower_tf(syminfo.tickerid, "1",
         [high, low, time], ignore_invalid_timeframe = true)
    mH := xH
    mL := xL
    mT := xT
TZ_JP  = "Asia/Tokyo"
TZ_UK  = "Europe/London"
TZ_US  = "America/New_York"

// ── Derived pre-market windows ──────────────────────────────────────────────
// "0930-1600" with lead 60 -> "0830-0930". Derived rather than typed so a
// pre-market can never point at an open its parent no longer has.
f_hhmm(int m) =>
    int h = int(m / 60)
    int n = m % 60
    (h < 10 ? "0" : "") + str.tostring(h) + (n < 10 ? "0" : "") + str.tostring(n)

f_openMin(string w) =>
    60 * int(str.tonumber(str.substring(w, 0, 2))) +
     int(str.tonumber(str.substring(w, 2, 4)))

f_pre(string w, int lead) =>
    int o = f_openMin(w)
    f_hhmm((o - lead + 1440) % 1440) + "-" + f_hhmm(o)

// Minute-of-day of each window's open. A pre-market opens its parent's open
// minus the lead, which is the same arithmetic f_pre prints into its string.
int oA  = f_openMin(winAsia)
int oL  = f_openMin(winLdn)
int oN  = f_openMin(winNY)
int oC  = f_openMin(winCmx)
int oAp = (oA - preLead + 1440) % 1440
int oLp = (oL - preLead + 1440) % 1440
int oNp = (oN - preLead + 1440) % 1440
int oCp = (oC - preLead + 1440) % 1440

// Membership is resolved here, at global scope: time() inside the session loop
// would share one call-site state across eight different window strings. The
// raw flags ignore the on/off toggles, so a pre-market still knows when its
// parent's window ends even if the parent row itself is unticked.
// A session string with no ":days" suffix applies EVERY day, so these windows
// fired on Saturday and Sunday on any symbol that prints weekend bars (crypto,
// spot FX/metals). None of the four has a weekend: NY and COMEX are exchange
// sessions, London is the LBMA/LSE week, Tokyo and Shanghai are Mon-Fri. The
// mask is appended HERE rather than baked into the input default because the
// Inputs tab lets the user edit a session's times but NOT its days -- a default
// carrying ":23456" loses the days the first time they touch the field.
// Days are read in the window's OWN timezone, which is what makes Asia's Monday
// (0900 JST = Sunday 20:00 ET) still print on a Sunday ET chart. That is the
// one weekend-looking box that is correct, not a leak.
WEEKDAYS = ":23456"          // 1 = Sunday .. 7 = Saturday, so this is Mon-Fri
f_wk(string w) => w + WEEKDAYS

bool rawA = not na(time(timeframe.period, f_wk(winAsia), TZ_JP))
bool rawL = not na(time(timeframe.period, f_wk(winLdn),  TZ_UK))
bool rawN = not na(time(timeframe.period, f_wk(winNY),   TZ_US))
bool rawC = not na(time(timeframe.period, f_wk(winCmx),  TZ_US))
bool inA  = onAsia  and rawA
bool inL  = onLdn   and rawL
bool inN  = onNY    and rawN
bool inC  = onCmx   and rawC
// One switch, applied to the sessions already ticked. A per-row "pre" box used
// to sit beside each session and could run a pre-market for a session whose own
// ORB was off; five controls for that one case read as a duplicate of the
// master, so the master won.
bool pmA  = preOn and onAsia
bool pmL  = preOn and onLdn
bool pmN  = preOn and onNY
bool pmC  = preOn and onCmx
// The pre-markets take the same mask. A lead big enough to wrap past midnight
// (Asia at lead > 540) is still right: for an overnight session the day digit
// names the day the session ENDS, which is its parent's open day.
bool inAp = pmA and not na(time(timeframe.period, f_wk(f_pre(winAsia, preLead)), TZ_JP))
bool inLp = pmL and not na(time(timeframe.period, f_wk(f_pre(winLdn,  preLead)), TZ_UK))
bool inNp = pmN and not na(time(timeframe.period, f_wk(f_pre(winNY,   preLead)), TZ_US))
bool inCp = pmC and not na(time(timeframe.period, f_wk(f_pre(winCmx,  preLead)), TZ_US))

// The 5m close, taken from the 5m series itself rather than inferred from the
// chart's own bars. WHICH bar carries it was never the defect — that is always
// the one before the bucket changes — the PRICE was.
//
// close[1] at a change of time("5") IS that close on a chart whose timeframe
// divides five minutes -- 1m, 5m, 30s. On 2m, 3m and 4m no chart bar ever ends
// on the boundary, so close[1] is the price one chart bar LATE, and it picked a
// different 5m candle rather than a slightly different price: on BTCUSDT.P
// 2026-09-08 the real 10:30 candle closed 78,349.7 at 10:35, while the 2m chart
// read 78,362.7 at 10:46 and the 3m chart 78,372.6 at 10:45 — three charts, three
// answers, and only the 1m and 5m ones were the 5m close.
//
// So the 5m series is asked for its own previous, already-closed bar. That is
// the documented non-repainting form, and its two halves are interdependent —
// neither the [1] nor the lookahead survives without the other:
// /pine-script-docs/concepts/repainting/
// Above 5m this would be a lower-timeframe request, which the same manual says
// to avoid, so there the old close[1] reading stands and the tag is off anyway.
fine5 = timeframe.in_seconds() <= 300
int   q5t = na          // opening time of the last CLOSED 5m bucket
float q5c = na          // its close
if fine5
    [a5t, a5c] = request.security(syminfo.tickerid, "5", [time[1], close[1]],
         lookahead = barmerge.lookahead_on)
    q5t := a5t
    q5c := a5c

// Both reads run on EVERY bar — a ta.*() call that only executes on some bars
// carries the wrong history. Which one is used is fixed by the chart timeframe,
// and below 5m the bucket boundary comes from the same call as the price, so
// the two can never disagree about which candle just closed.
bool chgQ = nz(ta.change(q5t), 0) != 0
bool chgT = nz(ta.change(time("5")), 0) != 0
new5 = fine5 ? chgQ : chgT
var float c5 = na
// the chart tag names the chart's own timeframe. Between a minute and an hour
// that reads as minutes; outside that, whatever TradingView's own period
// string says -- a seconds chart already carries its own S ("30S", not "30Sm")
tagCTxt = "ORB " + timeframe.period +
     (timeframe.in_seconds() >= 60 and timeframe.in_seconds() < 3600 ? "m" : "")

// ── Per-session state ───────────────────────────────────────────────────────
// One object per enabled session, each owning its own drawing history so the
// day trim is independent (a session that never breaks draws fewer objects).
type Sess
    int          id       // 0..3 main, +4 for that session's pre-market
    string       name
    bool         pm       // levels outlive the window (pre-market)
    array<box>   oBox
    array<line>  oLin
    array<label> oLab
    array<int>   starts   // opening bar of each archived occurrence
    int   t0       = na   // session open time, ms
    int   rs       = na   // session open bar
    float hi15     = na
    float lo15     = na
    float hi30     = na
    float lo30     = na
    bool  done15   = false
    bool  done30   = false
    int   bias     = 0    // 30m: +1 first break up, -1 first break down
    int   bias15   = 0
    int   brkBar   = na
    float t1       = na
    float t2       = na
    bool  retested = false
    bool  twoSided = false
    // one tag per side per confirm kind — the tags are independent of the
    // engine's own break, so a 5m close still gets marked when the engine is
    // running on chart close (and vice versa)
    bool  t5Up  = false
    bool  t5Dn  = false
    bool  tcUp  = false
    bool  tcDn  = false
    box   bx15 = na
    box   bx30 = na
    line  lnHi = na
    line  lnLo = na
    line  lnMid = na
    line  lnT1 = na
    line  lnT2 = na

f_add(array<Sess> a, int id, string name, bool pm) =>
    array.push(a, Sess.new(id, name, pm, array.new<box>(), array.new<line>(),
         array.new<label>(), array.new<int>()))

var array<Sess> SS = array.new<Sess>()
if barstate.isfirst
    if onAsia
        f_add(SS, 0, "Asia", false)
    if onLdn
        f_add(SS, 1, "LDN", false)
    if onNY
        f_add(SS, 2, "NY", false)
    if onCmx
        f_add(SS, 3, "GC", false)
    if pmA
        f_add(SS, 4, "Asia PM", true)
    if pmL
        f_add(SS, 5, "LDN PM", true)
    if pmN
        f_add(SS, 6, "NY PM", true)
    if pmC
        f_add(SS, 7, "GC PM", true)

// Trimming counts OCCURRENCES, not objects: a day draws 2..4 lines depending on
// targets and breaks, so an object-count cap kept 2-3 days when daysBack said 1.
f_trim(Sess s) =>
    while array.size(s.starts) > daysBack
        array.shift(s.starts)
    // everything left of the oldest retained occurrence goes; none of today's
    // drawings exist yet on this bar, so bar_index wipes the lot at daysBack 0
    int cut = bar_index
    if array.size(s.starts) > 0
        cut := array.first(s.starts)
    // ponytail: separate loops, `and` in Pine is not short-circuit — array.first
    // on an empty array is a runtime error
    while array.size(s.oBox) > 0
        if box.get_left(array.first(s.oBox)) >= cut
            break
        box.delete(array.shift(s.oBox))
    while array.size(s.oLin) > 0
        if line.get_x1(array.first(s.oLin)) >= cut
            break
        line.delete(array.shift(s.oLin))
    // break tags are pushed at creation (nothing mutates them afterwards), so
    // this array is already in bar order and today's are safely right of `cut`
    while array.size(s.oLab) > 0
        if label.get_x(array.first(s.oLab)) >= cut
            break
        label.delete(array.shift(s.oLab))

// Archive an occurrence's drawings and clear its state for the next one.
// Called from the 1m scan rather than from a chart-bar transition: on a chart
// coarser than the range the open lands mid-bar, so a chart-bar reset fires
// AFTER the range it was supposed to start, and wipes it.
f_reset(Sess s) =>
    if not na(s.bx15)
        array.push(s.oBox, s.bx15)
    if not na(s.bx30)
        array.push(s.oBox, s.bx30)
    if not na(s.lnHi)
        array.push(s.oLin, s.lnHi)
    if not na(s.lnLo)
        array.push(s.oLin, s.lnLo)
    if not na(s.lnMid)
        array.push(s.oLin, s.lnMid)
    if not na(s.lnT1)
        array.push(s.oLin, s.lnT1)
    if not na(s.lnT2)
        array.push(s.oLin, s.lnT2)
    if not na(s.rs)
        array.push(s.starts, s.rs)
    f_trim(s)
    s.bx15 := na
    s.bx30 := na
    s.lnHi := na
    s.lnLo := na
    s.lnMid := na
    s.lnT1 := na
    s.lnT2 := na
    s.hi15 := na
    s.lo15 := na
    s.hi30 := na
    s.lo30 := na
    s.done15 := false
    s.done30 := false
    s.bias := 0
    s.bias15 := 0
    s.brkBar := na
    s.t1 := na
    s.t2 := na
    s.retested := false
    s.twoSided := false
    s.t5Up := false
    s.t5Dn := false
    s.tcUp := false
    s.tcDn := false
    s.rs := bar_index
    s.t0 := time

f_alert(string msg) =>
    if alertsOn
        alert(syminfo.ticker + " " + timeframe.period + ": " + msg, alert.freq_all)

// A break leaves a mark on the chart, not just an alert: the bar that confirmed
// it. The anchor is the CANDLE that closed through — not the ORB level, which
// already has a line, a box and a right-axis tag. It sits ABOVE that candle on
// an upside break and BELOW it on a downside one, so the side carries the
// direction and the text does not have to.
f_tag(Sess s, int bar, float px, bool up, string txt, color col) =>
    array.push(s.oLab, label.new(bar, px, txt,
         style = up ? label.style_label_down : label.style_label_up,
         color = col, textcolor = tagTxCol, size = size.small))

// break-confirm per selected mode. On a 1m chart "Chart close" IS a 1m close,
// so open a 1m or 5m chart if you want the strictest reading of each mode.
f_brk(float lvl, bool upSide) =>
    confMode == "Touch" ? (upSide ? high > lvl : low < lvl) :
     confMode == "Chart close" ? (upSide ? close > lvl : close < lvl) :
     not na(c5) and (upSide ? c5 > lvl : c5 < lvl)

// right-axis tags follow whichever session is currently open. Sessions overlap
// (COMEX 0820-1330 sits inside NY 0930-1600, and a pre-market stays live right
// through its parent), so an open window outranks a merely-live one and the
// last enabled wins ties.
var float pHi   = na
var float pLo   = na
var float pT1   = na
var float pT2   = na
var int   pBias = 0
var int   pPri  = 0

// ── Engine (confirmed bars only) ────────────────────────────────────────────
if barstate.isconfirmed
    if new5
        c5 := fine5 ? q5c : close[1]
    pHi   := na
    pLo   := na
    pT1   := na
    pT2   := na
    pBias := 0
    pPri  := 0

    for s in SS
        bool nowIn = s.id == 0 ? inA : s.id == 1 ? inL : s.id == 2 ? inN :
             s.id == 3 ? inC : s.id == 4 ? inAp : s.id == 5 ? inLp :
             s.id == 6 ? inNp : inCp
        // the opening range is the first 15/30 minutes of the window, whatever
        // the window is — no hardcoded 0930. A pre-market builds its range the
        // same way; its ONE difference is outliving its own window, because the
        // range forms pre-open and the break lands during RTH. It dies with its
        // parent's window: the two are contiguous (pre ends where the parent
        // opens), so `nowIn or parent` is one unbroken stretch.
        bool parent = s.id == 4 ? rawA : s.id == 5 ? rawL : s.id == 6 ? rawN : rawC
        bool live = s.pm ? (not na(s.t0) and (nowIn or parent)) : nowIn

        // a pre-market borrows its parent's swatch (id 4..7 -> 0..3): the
        // two never share an x range, so one swatch per row is enough.
        int cid = s.id % 4
        color sesCol = cid == 0 ? colAsia : cid == 1 ? colLdn :
             cid == 2 ? colNY : colCmx
        color pmCol  = cid == 0 ? preColA : cid == 1 ? preColL :
             cid == 2 ? preColN : preColC
        color bxCol  = color.new(s.pm ? pmCol : sesCol, fillTransp)
        int oMin = s.id == 0 ? oA : s.id == 1 ? oL : s.id == 2 ? oN :
             s.id == 3 ? oC : s.id == 4 ? oAp : s.id == 5 ? oLp :
             s.id == 6 ? oNp : oCp

        // Walk this chart bar's 1m bars. d is minutes since the window opens,
        // so d == 0 IS the open and the scan owns the occurrence -- the chart
        // cannot, because on an hourly the open and the whole range sit inside
        // one bar. A day the symbol does not trade has no 1m bar at d == 0, so
        // nothing resets and no range is invented.
        int n = array.size(mT)
        for i = 0 to (n > 0 ? n : 1) - 1
            int   bt = n > 0 ? array.get(mT, i) : time
            float bh = n > 0 ? array.get(mH, i) : high
            float bl = n > 0 ? array.get(mL, i) : low
            // Each timezone is spelled out rather than selected into a
            // variable: every shipping hour() in this repo passes a literal,
            // and a series-qualified timezone is not something the manual
            // confirms. Three cheap calls beat one unverifiable one.
            int md = cid == 0 ? 60 * hour(bt, TZ_JP) + minute(bt, TZ_JP) :
                 cid == 1 ? 60 * hour(bt, TZ_UK) + minute(bt, TZ_UK) :
                 60 * hour(bt, TZ_US) + minute(bt, TZ_US)
            int d  = (md - oMin + 1440) % 1440
            if d == 0
                f_reset(s)
            if not na(s.t0)
                if d < 15
                    s.hi15 := na(s.hi15) ? bh : math.max(s.hi15, bh)
                    s.lo15 := na(s.lo15) ? bl : math.min(s.lo15, bl)
                else if not na(s.hi15)
                    s.done15 := true
                if d < 30
                    s.hi30 := na(s.hi30) ? bh : math.max(s.hi30, bh)
                    s.lo30 := na(s.lo30) ? bl : math.min(s.lo30, bl)
                else if not na(s.hi30)
                    s.done30 := true

        // draw live so the range appears from the open, not only at +15m. The
        // right edge is pushed by the live block below, so the box reads as a
        // zone; top and bottom stop moving on their own once the range closes.
        if show15 and not na(s.hi15)
            if na(s.bx15)
                s.bx15 := box.new(s.rs, s.hi15, bar_index, s.lo15,
                     border_color = outCol, bgcolor = bxCol,
                     border_style = bStyle)
            else
                box.set_top(s.bx15, s.hi15)
                box.set_bottom(s.bx15, s.lo15)
        if show30 and not na(s.hi30)
            if na(s.bx30)
                s.bx30 := box.new(s.rs, s.hi30, bar_index, s.lo30,
                     border_color = outCol, bgcolor = bxCol,
                     border_style = bStyle)
            else
                box.set_top(s.bx30, s.hi30)
                box.set_bottom(s.bx30, s.lo30)

        // the frozen levels, drawn once as the 30m range closes
        if show30 and s.done30 and na(s.lnHi) and not na(s.hi30)
            s.lnHi := line.new(bar_index - 1, s.hi30, bar_index, s.hi30,
                 color = outCol, style = line.style_dotted)
            s.lnLo := line.new(bar_index - 1, s.lo30, bar_index, s.lo30,
                 color = outCol, style = line.style_dotted)
            if midOn
                float mid = (s.hi30 + s.lo30) / 2
                // x1 is the session open, not this bar: the midline has no box
                // border under it, so starting it where the range CLOSES leaves
                // a visible gap across the first half of the box.
                s.lnMid := line.new(s.rs, mid, bar_index, mid,
                     color = midColT, style = mStyle)

        // extend the boxes and the level/target rays for as long as the
        // session is live. The box dies with the session, not at the right
        // edge of the chart. A pre-market's box stops at its OWN window --
        // only its levels carry into the parent, or the two boxes would sit
        // on top of each other for the whole of RTH.
        bool growBox = s.pm ? nowIn : live
        if growBox
            if not na(s.bx15)
                box.set_right(s.bx15, bar_index)
            if not na(s.bx30)
                box.set_right(s.bx30, bar_index)
        if live
            if not na(s.lnHi)
                line.set_x2(s.lnHi, bar_index)
            if not na(s.lnLo)
                line.set_x2(s.lnLo, bar_index)
            if not na(s.lnMid)
                line.set_x2(s.lnMid, bar_index)
            if not na(s.lnT1)
                line.set_x2(s.lnT1, bar_index)
            if not na(s.lnT2)
                line.set_x2(s.lnT2, bar_index)

        // 15m break — context bias for the reversal read (no targets)
        if live and s.done15 and s.bias15 == 0 and not na(s.hi15)
            if f_brk(s.hi15, true)
                s.bias15 := 1
                f_alert(s.name + " 15m ORB break up")
            else if f_brk(s.lo15, false)
                s.bias15 := -1
                f_alert(s.name + " 15m ORB break down")

        // 30m break — sets the session bias + level-anchored targets
        if live and s.done30 and s.bias == 0 and not na(s.hi30)
            float w = s.hi30 - s.lo30
            if f_brk(s.hi30, true)
                s.bias := 1
                s.brkBar := bar_index
                s.t1 := s.hi30 + w
                s.t2 := s.hi30 + 2 * w
            else if f_brk(s.lo30, false)
                s.bias := -1
                s.brkBar := bar_index
                s.t1 := s.lo30 - w
                s.t2 := s.lo30 - 2 * w
            if s.bias != 0
                if showT
                    s.lnT1 := line.new(bar_index, s.t1, bar_index + 1, s.t1,
                         color = outCol, style = line.style_dashed)
                    s.lnT2 := line.new(bar_index, s.t2, bar_index + 1, s.t2,
                         color = outCol, style = line.style_dashed)
                f_alert(s.name + (s.bias == 1 ? " 30m ORB break up" : " 30m ORB break down"))

        // Tags run on their OWN test, not on the engine's confirm mode. That is
        // the point: with confirm on chart close the engine breaks on the 1m
        // bar, and the 5m close — the thing you cannot see on a 1m chart — would
        // otherwise never be marked. One tag per side per kind.
        if live and s.done30 and not na(s.hi30)
            // over 5m the tag would be the chart close wearing another name
            if tag5On and fine5 and not na(c5)
                // bar_index - 1 is the bar that CARRIED the 5m close, on every
                // timeframe: this bar opens at or after the bucket boundary, so
                // the one before it always contains that boundary. It is the
                // 10:34 candle on a 1m chart and the 10:30 candle on a 5m one —
                // the same close, drawn at the resolution the chart has.
                // Anchoring to the bucket's OPENING bar instead put the tag on
                // a 10:30 candle sitting 74.6 INSIDE the range.
                if not s.t5Up and c5 > s.hi30
                    s.t5Up := true
                    f_tag(s, bar_index - 1, high[1], true, "ORB 5m", tag5Col)
                if not s.t5Dn and c5 < s.lo30
                    s.t5Dn := true
                    f_tag(s, bar_index - 1, low[1], false, "ORB 5m", tag5Col)
            if tagCOn
                if not s.tcUp and close > s.hi30
                    s.tcUp := true
                    f_tag(s, bar_index, high, true, tagCTxt, tagCCol)
                if not s.tcDn and close < s.lo30
                    s.tcDn := true
                    f_tag(s, bar_index, low, false, tagCTxt, tagCCol)

        // opposite side also breaks -> lower-probability session (Golden Ticket
        // flag). The 2nd break flips the active bias and gets its own 1R/2R rays.
        if live and s.done30 and s.bias != 0 and not s.twoSided
            bool secondUp = s.bias == -1 and f_brk(s.hi30, true)
            bool secondDn = s.bias == 1 and f_brk(s.lo30, false)
            if secondUp or secondDn
                s.twoSided := true
                f_alert(s.name + " ORB both sides broken — lower-probability session")

                s.bias := secondUp ? 1 : -1
                s.brkBar := bar_index
                float w3 = s.hi30 - s.lo30
                s.t1 := secondUp ? s.hi30 + w3 : s.lo30 - w3
                s.t2 := secondUp ? s.hi30 + 2 * w3 : s.lo30 - 2 * w3
                if showT
                    if not na(s.lnT1)
                        array.push(s.oLin, s.lnT1)
                    if not na(s.lnT2)
                        array.push(s.oLin, s.lnT2)
                    s.lnT1 := line.new(bar_index, s.t1, bar_index + 1, s.t1,
                         color = outCol, style = line.style_dashed)
                    s.lnT2 := line.new(bar_index, s.t2, bar_index + 1, s.t2,
                         color = outCol, style = line.style_dashed)

        // first return to the broken 30m level (0.1·range tolerance). One
        // marker per session.
        if live and s.bias != 0 and not s.retested and not na(s.brkBar) and bar_index > s.brkBar
            float w2 = s.hi30 - s.lo30
            float lvl = s.bias == 1 ? s.hi30 : s.lo30
            if s.bias == 1 ? (low <= lvl + RT_TOL * w2) : (high >= lvl - RT_TOL * w2)
                s.retested := true
                f_alert(s.name + " 30m ORB level retest")

        int pri = nowIn ? 2 : 1
        if live and s.done30 and pri >= pPri
            pPri  := pri
            pHi   := s.hi30
            pLo   := s.lo30
            pT1   := s.t1
            pT2   := s.t2
            pBias := s.bias

// ── Right-axis price tags (open session only) ───────────────────────────────
plot(show30 ? pHi : na, "ORB30 High", color = outCol,
     display = display.price_scale, editable = false)
plot(show30 ? pLo : na, "ORB30 Low", color = outCol,
     display = display.price_scale, editable = false)
plot(showT and pBias != 0 ? pT1 : na, "Target 1R", color = outCol,
     display = display.price_scale, editable = false)
plot(showT and pBias != 0 ? pT2 : na, "Target 2R", color = outCol,
     display = display.price_scale, editable = false)
````
