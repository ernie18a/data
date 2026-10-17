# STRYK: SVP

- url: https://www.tradingview.com/script/g4gPt2C3-STRYK-SVP/
- type: indicator
- pine_id: PUB;c4d25556d7d348fd8e7600b8d91c2224
- version: 2.0

## Description

STRYK: SVP — Session Volume Profile

One volume profile per period, hour to month, or per futures session, drawn where the session happened, and every session's point of control carried forward until price trades through it. Built for CME index futures on an intraday chart.

What it draws. A profile for each of the last N sessions, either as a heatmap, where every price row is shaded by how much traded there, or as classic horizontal bars. That session's POC, extended to the right with a tag reading, for example, 2 sessions, Vol 36.3K, 52% up-vol. Naked POCs, meaning nobody has traded back through them since that session closed, stay bright; tested ones fade and, by default, stop at the bar that tested them, so what is left on the chart is the set of levels the market still owes a visit. Value area high and low, the band holding 70 percent of the session's volume around the POC, with optional shading. And the developing profile of the session in progress, rebuilt every bar, with its own POC, value area and tag.

How the profile is built. The lower-timeframe bars inside each chart bar, one-minute by default, are the raw material. By default each intrabar's volume is spread evenly across every price bin between its low and its high, which is the closest a bar-based profile gets to true volume-at-price and stops one fast minute from dumping all its volume on a single tick; you can instead assign each bar to its close, HLC3 or OHLC4. Each intrabar's volume is also signed by its own direction, so every bin carries an up-volume share and every tag can say how one-sided the session was. Up-volume means volume from rising intrabars, not exchange-recorded buying: it is the same lower-timeframe method STRYK: DELTA-TD uses, benchmarked against real aggressor data at r = 0.64 to 0.74, a good estimate and not a tape. Where lower-timeframe data runs out far back on the chart, the chart bar's own typical price and volume are used instead and the profile there is coarser; the panel says which the live session is built from. The POC and value area are computed at a fine resolution you set in ticks, four by default, independent of how many rows are drawn. The value area expands outward from the POC one price bin at a time over a continuous ladder, so an empty bin inside the range counts as zero rather than being skipped.

Initial balance. The high and low of the session's opening window, 60 minutes by default, drawn live for the developing session and optionally on completed ones. On RTH that is the classic IB; on the full-day preset it is the first hour of Globex, which is a different thing, and the setting is there for you to decide.

Periods. One profile per hour, 4 hours, day, week, two weeks or month, following the exchange calendar exactly as the chart's own bars do: a day is the CME trading day, 17:00 to 16:00 Chicago, Sunday evening through Friday, and a week is Sunday 17:00 to Friday 16:00. Or a time window instead: CME RTH 08:30 to 15:00, the overnight 17:00 to 08:30, or any custom session string with its timezone. Boundaries come from the exchange clock, never from whatever timezone the chart happens to be set to.

The panel. Session in use, how many sessions are kept and how many POCs are still naked, the developing POC, value area, session volume with up-volume share, whether price is inside, above or below value right now, the initial balance, and what the live profile is being built from.

Fully customizable. Eight master switches: everything, profiles, POC lines, value area, developing session, tags, panel, initial balance. Heatmap colours and transparency, bar colours, which end bars grow from and how long they can get, rows per profile, POC colour for naked and tested, width, style, whether tested POCs stop or carry on or disappear, tag contents and size, value area colour, style and shading, developing POC colour and width, panel position, size and colours. Keep up to 30 sessions; rows are clamped automatically to stay inside TradingView's drawing limits and the panel says so if that happens.

Alerts. Price trades through a naked POC. Close crosses the developing POC. Close leaves the developing value area. All on bar close.

Nothing here is a signal. A POC is where the most business was done; what price does when it comes back there is for you to judge. No performance claim is made or implied, and this is not financial advice.

## Source Code

````pine
// =============================================================================
// STRYK: SVP v3.3 — Session Volume Profile  (short title STRYK:SVP)
// =============================================================================
// One volume profile per futures session, drawn where the session happened,
// and every session's point of control carried forward until price trades
// through it. Built for CME index futures on an intraday chart.
//
// What it draws
//   • A profile for each of the last N sessions: either a heatmap (every price
//     row shaded by how much traded there) or classic horizontal bars.
//   • That session's POC, extended to the right with a tag:
//        "2 sessions · Vol 36.3K · 52% up-vol"
//     Naked POCs (never traded through since the session closed) stay live;
//     tested ones are faded and, optionally, stop at the bar that tested them.
//   • Value area high / low (70% of the session's volume around the POC).
//   • The developing profile of the session in progress, rebuilt every bar,
//     with its own POC / VAH / VAL.
//
// How the profile is built
//   Lower-timeframe bars inside each chart bar (1-minute by default) are
//   dropped into price bins by their close, weighted by their volume. Each
//   intrabar's volume is also signed by its own direction so every bin has a
//   up-volume share. That is the same lower-timeframe method STRYK: DELTA-TD uses,
//   which was benchmarked against real exchange aggressor data at r = 0.64 to
//   0.74 — a good estimate, not a tape. Where lower-timeframe data runs out
//   (TradingView's intrabar cap, far back on the chart) the chart bar's own
//   typical price and volume are used instead, and the profile there is
//   coarser. The panel says which it is for the live session.
//
// Sessions
//   Three presets for CME, each with the exchange timezone built in, plus a
//   custom string. Session boundaries come from time(timeframe.period, …, tz),
//   never from the chart's local clock.
//
// Nothing here is a signal. A POC is where the most business was done; what
// price does when it comes back there is for you to judge.
// =============================================================================

//@version=6
indicator("STRYK: SVP", shorttitle = "STRYK:SVP", overlay = true,
     max_boxes_count = 500, max_lines_count = 250, max_labels_count = 100)

// =============================================================================
// INPUTS
// =============================================================================
string G0 = "0 · Master switches"
string G1 = "1 · Session"
string G2 = "2 · Profile build"
string G3 = "3 · Profiles on the chart"
string G4 = "4 · POC lines"
string G5 = "5 · Value area"
string G6 = "6 · Developing session"
string G7 = "7 · Panel"
string G8 = "8 · Alerts"
string G9 = "9 · Candle colouring"

// --- 0. master switches ------------------------------------------------------
mAll     = input.bool(true, "EVERYTHING ON", group = G0)
mProf    = input.bool(true, "Session profiles", group = G0, inline = "m1")
mPoc     = input.bool(true, "POC lines", group = G0, inline = "m1")
mVA      = input.bool(true, "Value area", group = G0, inline = "m2")
mDev     = input.bool(true, "Developing session", group = G0, inline = "m2")
mTags    = input.bool(true, "POC tags", group = G0, inline = "m3")
mPanel   = input.bool(true, "Panel", group = G0, inline = "m3")
mIB      = input.bool(true, "Initial balance", group = G0, inline = "m4")
mPaint   = input.bool(true, "Candle colouring", group = G0, inline = "m4")
paintEngine = input.string("Delta HTF candles (DRE)", "Colouring engine",
     options = ["Delta HTF candles (DRE)", "Delta HTF gradient (ΔC)", "Delta gradient", "Delta sign", "Value area position", "Distance from POC", "Volume at price (heat)", "Naked POC proximity", "Session up-vol share"],
     group = G0,
     tooltip = "DELTA HTF CANDLES (DRE) — the STRYK:DRE / STRYK:M engine: each bar is coloured against the volume profile of the delta timeframe — neutral inside its value area (deeper when price sits on the POC and delta is quiet), bull above it, bear below, brighter with distance, with the live HTF delta agreeing (align boost), with consecutive closes beyond the edge (acceptance), with relative volume, and with the POC itself migrating the way price broke. Its settings are the DRE group below. DELTA HTF GRADIENT (ΔC) — the Delta Candles engine: the live, accumulating delta of the higher-timeframe candle, nothing else, so a whole hour of bars shares one colour that shifts as the hour's delta builds. DELTA GRADIENT — the same maths on each bar's own delta (lower-timeframe signed volume) normalised against the recent average, fading through neutral as it flips sign. DELTA SIGN — the Delta-TD tint: bull or bear by the bar's delta sign, nothing in between. VALUE AREA POSITION — bull above the reference value area, bear below, neutral inside. DISTANCE FROM POC — a gradient from neutral at the reference POC to full colour one value-area-width away. VOLUME AT PRICE — the heatmap ramp applied to candles: how much of the session has already traded at this bar's close. NAKED POC PROXIMITY — only bars within reach of an untested POC are coloured; everything else keeps the chart's own colour. SESSION UP-VOL SHARE — the whole session's up-volume share so far, bull above 50%.")

// --- 1. session --------------------------------------------------------------
sessMode = input.string("1 day (17:00–16:00 CT)", "Profile period",
     options = ["1 hour", "4 hours", "1 day (17:00–16:00 CT)", "1 week", "2 weeks", "1 month",
                "CME RTH (08:30–15:00 CT)", "CME overnight (17:00–08:30 CT)", "Custom session"],
     group = G1,
     tooltip = "What one profile covers. The timeframe periods follow the exchange calendar exactly as the chart's own bars do — 1 day is the CME trading day, 17:00 to 16:00 Chicago, Sunday evening through Friday, the same window as the daily candle. 1 week is Sunday 17:00 to Friday 16:00. RTH is the cash-hours profile most day traders mean by 'the session'; overnight is Globex only.")
sessCust = input.session("0830-1500", "Custom session", group = G1)
sessTz   = input.string("America/Chicago", "Timezone", group = G1,
     tooltip = "Sessions are placed in this timezone regardless of what the chart is set to. CME is Chicago.")
maxSess  = input.int(10, "Sessions to keep", minval = 1, maxval = 30, group = G1,
     tooltip = "How many completed periods stay on the chart. Each one costs profile rows, three lines and a tag, so this and 'Rows per profile' trade off against each other — the script clamps rows to stay inside TradingView's drawing limits and says so in the panel.")

// --- 2. profile build --------------------------------------------------------
ltfMode  = input.string("Auto", "Intrabar resolution",
     options = ["Auto", "1 second", "5 seconds", "15 seconds", "30 seconds", "1 minute", "5 minutes"], group = G2,
     tooltip = "The lower timeframe each chart bar is broken into. Finer is more accurate and costs more history: TradingView caps intrabar data at roughly 200,000 bars, so 1-minute on a 5-minute chart covers about 40,000 chart bars.")
binTicks = input.int(4, "Price bin (ticks)", minval = 1, maxval = 100, group = G2,
     tooltip = "The resolution the POC and value area are computed at. 4 ticks on MES is one point. This is independent of how many rows are DRAWN.")
vaPct    = input.int(70, "Value area (% of volume)", minval = 50, maxval = 95, group = G2)
priceSrc = input.string("Spread across bar range", "Where each intrabar's volume goes",
     options = ["Spread across bar range", "Close", "HLC3", "OHLC4"], group = G2,
     tooltip = "SPREAD shares each lower-timeframe bar's volume evenly over every price bin between its low and high — the closest a bar-based profile gets to volume-at-price, and it stops a single fast 1-minute bar from dumping all its volume on one tick. The other three assign the whole bar to one representative price. None of these reconstruct exchange-level volume-at-price.")

// --- 2b. initial balance -----------------------------------------------------
ibOn      = input.bool(true, "Initial balance (first N minutes of the session)", group = G2,
     tooltip = "The high and low of the session's opening window. On RTH this is the classic 30- or 60-minute IB; on the full-day preset it is the first hour of Globex, which is a different animal. Lines are live for the developing session and static for completed ones.")
ibMin     = input.int(60, "IB minutes", minval = 5, maxval = 240, group = G2, inline = "ib")
cIB       = input.color(#AB47BC, "", group = G2, inline = "ib")
wIB       = input.int(1, "", minval = 1, maxval = 4, group = G2, inline = "ib")
sIB       = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = G2, inline = "ib")
ibExtend  = input.bool(true, "Extend IB of the developing session to the current bar", group = G2)
ibHist    = input.bool(false, "Show IB on completed sessions too", group = G2)

// --- 3. profiles on the chart ------------------------------------------------
profStyle = input.string("Heatmap", "Style", options = ["Heatmap", "Bars", "None"], group = G3,
     tooltip = "Heatmap shades every price row across the whole session by how much traded there. Bars draws the classic profile, each row as a bar whose length is its volume. None keeps only the lines.")
rowsIn    = input.int(24, "Rows per profile", minval = 6, maxval = 100, group = G3)
cHeatLo   = input.color(#0B1F3A, "Heat: low", group = G3, inline = "h")
cHeatMid  = input.color(#1E8C7A, "mid", group = G3, inline = "h")
cHeatHi   = input.color(#F5D142, "high", group = G3, inline = "h")
heatT     = input.int(65, "Heatmap transparency", minval = 0, maxval = 95, group = G3)
cBarBuy   = input.color(#26A69A, "Bars: buy-led row", group = G3, inline = "b")
cBarSell  = input.color(#EF5350, "sell-led row", group = G3, inline = "b")
barT      = input.int(55, "Bars transparency", minval = 0, maxval = 95, group = G3)
barAnchor = input.string("Session start", "Bars grow from", options = ["Session start", "Session end"], group = G3)
barMaxW   = input.int(100, "Bars: max length (% of session)", minval = 10, maxval = 100, group = G3)

// --- 4. POC lines ------------------------------------------------------------
cPocNaked = input.color(#FFB74D, "Naked POC", group = G4, inline = "p")
cPocTest  = input.color(#787B86, "Tested POC", group = G4, inline = "p")
wPoc      = input.int(2, "Width", minval = 1, maxval = 5, group = G4, inline = "p")
sPoc      = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = G4, inline = "p")
pocExtend = input.string("To current bar", "Extend", options = ["To current bar", "Across its session only"], group = G4)
pocStopAtTest = input.bool(true, "Stop a tested POC at the bar that tested it", group = G4,
     tooltip = "A naked POC is a level nobody has revisited; once price trades through it, it has done its job. With this on, the line ends where that happened and fades. Off keeps every POC running to the current bar, faded once tested.")
pocHideTested = input.bool(false, "Hide tested POCs entirely", group = G4)
tagOn     = input.bool(true, "Tag each POC", group = G4, inline = "t")
tagSz     = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large"], group = G4, inline = "t")
tagWhat   = input.string("Age · volume · up-vol %", "Tag shows",
     options = ["Age · volume · up-vol %", "Age · volume", "Age only", "Price only"], group = G4)
tagOff    = input.int(2, "Tag offset right (bars)", minval = 0, maxval = 100, group = G4)

// --- 5. value area -----------------------------------------------------------
vaLines   = input.bool(true, "VAH / VAL lines", group = G5, inline = "v")
cVA       = input.color(#42A5F5, "", group = G5, inline = "v")
wVA       = input.int(1, "", minval = 1, maxval = 4, group = G5, inline = "v")
sVA       = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = G5, inline = "v")
vaExtend  = input.bool(false, "Extend VAH / VAL to current bar", group = G5)
vaFill    = input.bool(false, "Shade the value area", group = G5, inline = "vf")
vaFillT   = input.int(88, "", minval = 50, maxval = 100, group = G5, inline = "vf")

// --- 6. developing session ---------------------------------------------------
devProf   = input.bool(true, "Draw the developing profile", group = G6)
devPocOn  = input.bool(true, "Developing POC", group = G6, inline = "d")
cDevPoc   = input.color(#FFFFFF, "", group = G6, inline = "d")
wDevPoc   = input.int(2, "", minval = 1, maxval = 5, group = G6, inline = "d")
devVAOn   = input.bool(true, "Developing VAH / VAL", group = G6)
devTag    = input.bool(true, "Tag the developing POC", group = G6)

// --- 9. candle colouring -----------------------------------------------------
paintHtf   = input.string("60", "Delta HTF candles: higher timeframe", options = ["Profile period", "15", "30", "60", "120", "240", "D"], group = G9,
     tooltip = "Which candle's accumulating delta colours the bars. 'Profile period' uses the same period as the profiles, so the colour is the session's own delta building through the day.")
paintHtfN  = input.int(20, "Delta HTF candles: candles in the average", minval = 3, maxval = 100, group = G9,
     tooltip = "Full colour is reached at sensitivity × the average |delta| of this many completed higher-timeframe candles, so one monster candle cannot mute the palette.")
paintRef   = input.string("Prior session", "Reference levels for VA / POC engines", options = ["Prior session", "Developing session"], group = G9,
     tooltip = "Prior session = yesterday's POC and value area, fixed all day and available on every historical bar. Developing = today's live levels — honest only on the current bar, so historical bars are coloured against the prior session regardless.")
cPaintBull = input.color(#4ADE80, "Bull", group = G9, inline = "pc")
cPaintNeut = input.color(#3B82F6, "Neutral", group = G9, inline = "pc")
cPaintBear = input.color(#E63030, "Bear", group = G9, inline = "pc")
paintT     = input.int(0, "Transparency", minval = 0, maxval = 90, group = G9)
paintLook  = input.int(50, "Delta gradient: lookback for the average", minval = 5, maxval = 500, group = G9)
paintSens  = input.float(1.5, "Delta: sensitivity", minval = 0.5, maxval = 5.0, step = 0.25, group = G9,
     tooltip = "How big delta must be, in multiples of the recent average, to reach full colour. Lower = vivid sooner.")
paintMode  = input.string("Delta size", "Delta: mode", options = ["Delta size", "Delta % (imbalance)"], group = G9)
paintCurve = input.string("Boosted", "Delta: curve", options = ["Linear", "Boosted"], group = G9,
     tooltip = "Boosted is a square-root response: small and mid deltas show noticeably more colour while extremes still cap at full.")
nakedTol   = input.int(8, "Naked POC proximity: within (ticks)", minval = 1, maxval = 200, group = G9)

// --- 9b. DRE engine --------------------------------------------------------
string G9D = "9b · DRE engine (Delta HTF candles)"
dreRef     = input.string("HTF window (N candles)", "Reference profile", options = ["HTF window (N candles)", "Last HTF candle", "Prior session profile"], group = G9D,
     tooltip = "What the value area and POC are taken from. HTF window: a composite of the last N delta-timeframe candles, the STRYK:M default. Last HTF candle: just the previous one. Prior session profile: the SVP's own previous session.")
dreN       = input.int(23, "HTF window: N candles", minval = 1, maxval = 60, group = G9D)
dreLean    = input.float(0.35, "Inside value: lean by POC side", minval = 0.0, maxval = 0.8, step = 0.05, group = G9D,
     tooltip = "Inside the value area bars are neutral; this tilts them toward bull above the POC and bear below, growing toward the edge. 0 keeps them flat neutral.")
dreInt     = input.string("Blend", "Outside value: intensity from", options = ["Distance only", "Blend", "Strongest"], group = G9D,
     tooltip = "Distance only: how far beyond the edge. Blend: distance averaged with acceptance, relative size and migration. Strongest: whichever single factor reads highest.")
dreAccBars = input.int(3, "Acceptance: closes beyond for full", minval = 1, maxval = 20, group = G9D, inline = "da")
dreSizeFull= input.float(2.0, "size full at × avg vol", minval = 1.1, maxval = 6.0, step = 0.1, group = G9D, inline = "da")
dreMigK    = input.int(3, "Migration: candles back", minval = 1, maxval = 50, group = G9D)
dreRamp    = input.float(25, "Ramp width (% of value area)", minval = 5, maxval = 75, step = 5, group = G9D,
     tooltip = "How far beyond the edge, as a share of the value-area width, reaches full colour.")
dreBoost   = input.float(0.35, "Align boost", minval = 0.0, maxval = 0.6, step = 0.05, group = G9D,
     tooltip = "Added to intensity when the live HTF delta agrees with the side price broke to; the same amount removed when it disagrees.")

// --- 7. panel ----------------------------------------------------------------
panelOn   = input.bool(true, "Show panel", group = G7)
panelPos  = input.string("Top right", "Position",
     options = ["Top right", "Middle right", "Bottom right", "Top left", "Middle left", "Bottom left"], group = G7)
panelSz   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = G7)
panelBg   = input.color(#0C0E12, "Background", group = G7, inline = "pb")
panelBgT  = input.int(10, "", minval = 0, maxval = 100, group = G7, inline = "pb")
panelTx   = input.color(#D1D4DC, "Text", group = G7)

// --- 8. alerts ---------------------------------------------------------------
alNaked   = input.bool(true, "Price touches a naked POC", group = G8)
alDevPoc  = input.bool(false, "Price crosses the developing POC", group = G8)
alVA      = input.bool(false, "Price leaves the developing value area", group = G8)

// =============================================================================
// HELPERS
// =============================================================================
f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

f_style(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_pos(string p) =>
    p == "Top right" ? position.top_right : p == "Middle right" ? position.middle_right
     : p == "Bottom right" ? position.bottom_right : p == "Top left" ? position.top_left
     : p == "Middle left" ? position.middle_left : position.bottom_left

f_vol(float v) =>
    float a = math.abs(v)
    a >= 1000000 ? str.tostring(v / 1000000.0, "#.##") + "M"
     : a >= 1000 ? str.tostring(v / 1000.0, "#.#") + "K"
     : str.tostring(v, "#")

// Three-stop colour ramp for the heatmap.
f_heat(float f) =>
    f <= 0.5 ? color.from_gradient(f, 0.0, 0.5, cHeatLo, cHeatMid)
     : color.from_gradient(f, 0.5, 1.0, cHeatMid, cHeatHi)

// =============================================================================
// SESSION
// =============================================================================
string sessStr = sessMode == "CME RTH (08:30–15:00 CT)" ? "0830-1500"
     : sessMode == "CME overnight (17:00–08:30 CT)" ? "1700-0830"
     : sessMode == "Custom session" ? sessCust : "1700-1600"

// Two kinds of anchor. A TIMEFRAME period rolls when that timeframe's bar
// rolls — timeframe.change("D") on CME is exactly the 17:00 CT trading-day
// boundary, "W" is Sunday 17:00, "M" the first session of the month. A
// SESSION window uses time() with a session string, which returns na outside
// the window. Both are evaluated on every bar, as they must be.
bool tfMode = sessMode == "1 hour" or sessMode == "4 hours" or sessMode == "1 day (17:00–16:00 CT)"
     or sessMode == "1 week" or sessMode == "2 weeks" or sessMode == "1 month"
string anchorTf = sessMode == "1 hour" ? "60" : sessMode == "4 hours" ? "240"
     : sessMode == "1 week" ? "W" : sessMode == "2 weeks" ? "2W" : sessMode == "1 month" ? "M" : "D"
bool tfRoll = timeframe.change(anchorTf)
int  sessT   = time(timeframe.period, sessStr, sessTz)
bool inSess  = tfMode ? true : not na(sessT)
bool newSess = tfMode ? (tfRoll or barstate.isfirst) : (inSess and (barstate.isfirst or not inSess[1]))

// =============================================================================
// INTRABAR DATA
// =============================================================================
int chartSec = timeframe.in_seconds()
string ltfAuto = chartSec <= 3600 ? "1" : chartSec <= 14400 ? "5" : "15"
string ltfStr = ltfMode == "1 second" ? "1S" : ltfMode == "5 seconds" ? "5S"
     : ltfMode == "15 seconds" ? "15S" : ltfMode == "30 seconds" ? "30S"
     : ltfMode == "1 minute" ? "1" : ltfMode == "5 minutes" ? "5" : ltfAuto

// Three requests, one per series. Signed volume uses each intrabar's own
// direction, which is the lower-timeframe delta method, not bar polarity.
array<float> ltfC = request.security_lower_tf(syminfo.tickerid, ltfStr,
     priceSrc == "HLC3" ? hlc3 : priceSrc == "OHLC4" ? ohlc4 : close)
array<float> ltfH = request.security_lower_tf(syminfo.tickerid, ltfStr, high)
array<float> ltfL = request.security_lower_tf(syminfo.tickerid, ltfStr, low)
array<float> ltfV = request.security_lower_tf(syminfo.tickerid, ltfStr, volume)
array<float> ltfS = request.security_lower_tf(syminfo.tickerid, ltfStr,
     close > open ? volume : close < open ? -volume : 0.0)

bool haveLtf = not na(ltfC) and not na(ltfH) and not na(ltfL) and not na(ltfV) and not na(ltfS)
     and array.size(ltfC) > 0
     and array.size(ltfH) == array.size(ltfC)
     and array.size(ltfL) == array.size(ltfC)
     and array.size(ltfV) == array.size(ltfC)
     and array.size(ltfS) == array.size(ltfC)
bool spreadMode = priceSrc == "Spread across bar range"
int barMs = chartSec * 1000

float binPx = syminfo.mintick * binTicks
f_bin(float px) => na(px) or binPx <= 0 ? na : math.round(px / binPx) * binPx

// =============================================================================
// SESSION STATE (the one being built)
// =============================================================================
type Sess
    int   b0 = na          // first chart bar of the session (bookkeeping only)
    int   b1 = na          // last chart bar
    int   t0 = na          // open time of the first bar — drawings use TIME, because
    int   t1 = na          // bar_index coordinates error out past the history buffer
    int   tEnd = na        // close time of the last bar
    int   testedT = na
    float hi = na
    float lo = na
    float poc = na
    float pocVol = na
    float vol = 0.0
    float buyVol = 0.0     // volume signed positive, i.e. up-volume numerator
    float vah = na
    float val = na
    bool  tested = false
    int   testedBar = na
    bool  ltfBuilt = true  // false if any bar fell back to chart-bar data
    float ibH = na
    float ibL = na
    line  ibHLn
    line  ibLLn
    array<box>   rows
    box   vaBox
    line  pocLn
    line  vahLn
    line  valLn
    label tag

var map<float, float> volMap = map.new<float, float>()
var map<float, float> buyMap = map.new<float, float>()
var Sess cur = Sess.new()
var array<Sess> done = array.new<Sess>()
var bool curLtf = true
var line ibHLive = na
var line ibLLive = na
// time(period, session, tz) returns THIS bar's time when the bar is inside the
// session, not the session's start — so the start is captured on the first bar.
var int sessStartT = na

f_addBin(float px, float v, float sgn) =>
    float k = f_bin(px)
    if not na(k) and not na(v) and v > 0
        map.put(volMap, k, nz(map.get(volMap, k)) + v)
        if sgn > 0
            map.put(buyMap, k, nz(map.get(buyMap, k)) + v)

// Spread: the bar's volume shared equally over every bin from its low to its
// high. A one-bin bar is just f_addBin. Capped at 400 bins per bar so a bad
// print cannot stall the script.
f_addSpread(float lo, float hi, float v, float sgn) =>
    float k0 = f_bin(lo)
    float k1 = f_bin(hi)
    if not na(k0) and not na(k1) and not na(v) and v > 0
        int nb = int(math.round((k1 - k0) / binPx)) + 1
        nb := math.max(1, math.min(400, nb))
        float share = v / nb
        for j = 0 to nb - 1
            float k = math.round(k0 / binPx + j) * binPx
            map.put(volMap, k, nz(map.get(volMap, k)) + share)
            if sgn > 0
                map.put(buyMap, k, nz(map.get(buyMap, k)) + share)

// --- analyse a finished map: POC, value area, up-volume share ----------------------
// Returns [poc, pocVol, total, buyTotal, vah, val]
f_analyseMap(map<float, float> m, map<float, float> bm) =>
    float poc = na
    float pocV = 0.0
    float tot = 0.0
    float buy = 0.0
    float vah = na
    float val = na
    if map.size(m) > 0
        // Densify the price ladder before expanding the value area. A sparse
        // map skips zero-volume bins; treating the next occupied key as adjacent
        // can make VAH/VAL jump across gaps and distort the calculated value area.
        array<float> occupied = map.keys(m)
        array.sort(occupied, order.ascending)
        float firstK = array.get(occupied, 0)
        float lastK = array.get(occupied, array.size(occupied) - 1)
        int n = int(math.round((lastK - firstK) / binPx)) + 1
        array<float> ks = array.new<float>(n, na)
        array<float> vs = array.new<float>(n, 0.0)
        int pi = 0
        for i = 0 to n - 1
            float k = math.round(firstK / binPx + i) * binPx
            float v = nz(map.get(m, k))
            array.set(ks, i, k)
            array.set(vs, i, v)
            tot += v
            buy += nz(map.get(bm, k))
            if v > pocV
                pocV := v
                poc := k
                pi := i
        // Value area: grow one adjacent price bin at a time from the POC,
        // always taking the heavier side until the configured volume is covered.
        float target = tot * vaPct / 100.0
        float acc = pocV
        int lo = pi
        int hi = pi
        while acc < target and (lo > 0 or hi < n - 1)
            float below = lo > 0 ? array.get(vs, lo - 1) : -1.0
            float above = hi < n - 1 ? array.get(vs, hi + 1) : -1.0
            if above >= below
                hi += 1
                acc += above
            else
                lo -= 1
                acc += below
        vah := array.get(ks, hi) + binPx / 2
        val := array.get(ks, lo) - binPx / 2
    [poc, pocV, tot, buy, vah, val]

f_analyse() => f_analyseMap(volMap, buyMap)

// --- draw rows for a session into a given array of boxes ---------------------
// Rebins the fine map into `rowsN` equal rows across [lo, hi] and draws them.
f_drawRows(array<box> rows, int t0, int t1, float lo, float hi, int rowsN) =>
    // clear anything already there
    if array.size(rows) > 0
        for i = 0 to array.size(rows) - 1
            box.delete(array.get(rows, i))
        array.clear(rows)
    if profStyle != "None" and not na(lo) and not na(hi) and hi > lo and rowsN > 0 and map.size(volMap) > 0
        float rowH = (hi - lo) / rowsN
        array<float> rv = array.new<float>(rowsN, 0.0)
        array<float> rb = array.new<float>(rowsN, 0.0)
        array<float> ks = map.keys(volMap)
        for i = 0 to array.size(ks) - 1
            float k = array.get(ks, i)
            int r = int(math.floor((k - lo) / rowH))
            r := math.max(0, math.min(rowsN - 1, r))
            array.set(rv, r, array.get(rv, r) + nz(map.get(volMap, k)))
            array.set(rb, r, array.get(rb, r) + nz(map.get(buyMap, k)))
        float rowMax = array.max(rv)
        int span = math.max(barMs, t1 - t0)
        for r = 0 to rowsN - 1
            float v = array.get(rv, r)
            float f = rowMax > 0 ? v / rowMax : 0.0
            float y1 = lo + r * rowH
            float y2 = y1 + rowH
            if profStyle == "Heatmap"
                array.push(rows, box.new(t0, y2, t1, y1, border_width = 0,
                     bgcolor = color.new(f_heat(f), heatT), xloc = xloc.bar_time))
            else
                int w = int(math.round(span * f * barMaxW / 100.0))
                bool buyLed = array.get(rb, r) >= v / 2
                color c = color.new(buyLed ? cBarBuy : cBarSell, barT)
                int xa = barAnchor == "Session start" ? t0 : t1 - w
                int xb = barAnchor == "Session start" ? t0 + w : t1
                array.push(rows, box.new(xa, y2, xb, y1, border_width = 0, bgcolor = c, xloc = xloc.bar_time))

// Row budget: profiles share 500 boxes with the developing one and the VA shades.
int rowsN = math.max(6, math.min(rowsIn, int(math.floor((500 - rowsIn - maxSess - 2) / math.max(1, maxSess)))))
bool rowsClamped = rowsN < rowsIn

// =============================================================================
// BUILD
// =============================================================================
// Finalise the session that just ended from the maps, draw its static parts,
// push it to `done`, retire the oldest, then start a fresh one. This lives at
// global scope because a function cannot reassign `cur`.
if newSess
    if not na(cur.b0) and map.size(volMap) > 0
        [poc, pocV, tot, buy, vah, val] = f_analyse()
        cur.poc := poc
        cur.pocVol := pocV
        cur.vol := tot
        cur.buyVol := buy
        cur.vah := vah
        cur.val := val
        cur.ltfBuilt := curLtf
        cur.rows := array.new<box>()
        if mAll and mProf
            f_drawRows(cur.rows, cur.t0, cur.t1, cur.lo, cur.hi, rowsN)
        if mAll and mVA and vaFill and not na(vah) and not na(val)
            cur.vaBox := box.new(cur.t0, vah, cur.t1, val, border_width = 0,
                 bgcolor = color.new(cVA, vaFillT), xloc = xloc.bar_time)
        if mAll and mPoc and not na(poc)
            cur.pocLn := line.new(cur.t0, poc, cur.t1, poc, xloc = xloc.bar_time,
                 color = cPocNaked, width = wPoc, style = f_style(sPoc))
        if mAll and mVA and vaLines and not na(vah)
            cur.vahLn := line.new(cur.t0, vah, cur.t1, vah, xloc = xloc.bar_time,
                 color = cVA, width = wVA, style = f_style(sVA))
            cur.valLn := line.new(cur.t0, val, cur.t1, val, xloc = xloc.bar_time,
                 color = cVA, width = wVA, style = f_style(sVA))
        if mAll and mTags and tagOn and not na(poc)
            cur.tag := label.new(cur.t1, poc, "", xloc = xloc.bar_time, style = label.style_label_left,
                 color = color.new(cPocNaked, 100), textcolor = cPocNaked, size = f_size(tagSz))
        if mAll and mIB and ibOn and ibHist and not na(cur.ibH)
            cur.ibHLn := line.new(cur.t0, cur.ibH, cur.t1, cur.ibH, xloc = xloc.bar_time, color = cIB, width = wIB, style = f_style(sIB))
            cur.ibLLn := line.new(cur.t0, cur.ibL, cur.t1, cur.ibL, xloc = xloc.bar_time, color = cIB, width = wIB, style = f_style(sIB))
        array.push(done, cur)
        while array.size(done) > maxSess
            Sess old = array.shift(done)
            if not na(old.rows) and array.size(old.rows) > 0
                for i = 0 to array.size(old.rows) - 1
                    box.delete(array.get(old.rows, i))
            if not na(old.vaBox)
                box.delete(old.vaBox)
            if not na(old.pocLn)
                line.delete(old.pocLn)
            if not na(old.vahLn)
                line.delete(old.vahLn)
            if not na(old.valLn)
                line.delete(old.valLn)
            if not na(old.tag)
                label.delete(old.tag)
            if not na(old.ibHLn)
                line.delete(old.ibHLn)
            if not na(old.ibLLn)
                line.delete(old.ibLLn)
    cur := Sess.new()
    map.clear(volMap)
    map.clear(buyMap)
    curLtf := true
    cur.b0 := bar_index
    cur.t0 := time
    cur.t1 := time
    cur.hi := high
    cur.lo := low
    cur.ibH := high
    cur.ibL := low
    sessStartT := time

if inSess and not na(cur.b0)
    cur.b1 := bar_index
    cur.t1 := time
    cur.tEnd := time_close
    cur.hi := math.max(nz(cur.hi, high), high)
    cur.lo := math.min(nz(cur.lo, low), low)
    // Initial balance: bars whose OPEN falls inside the first ibMin minutes.
    if time - sessStartT < ibMin * 60000
        cur.ibH := math.max(nz(cur.ibH, high), high)
        cur.ibL := math.min(nz(cur.ibL, low), low)
    // Fold this bar in once it is final; the live bar is handled by the
    // developing draw below, which reads the maps plus the live intrabars.
    if barstate.isconfirmed
        if haveLtf
            for i = 0 to array.size(ltfC) - 1
                if spreadMode
                    f_addSpread(array.get(ltfL, i), array.get(ltfH, i), array.get(ltfV, i), array.get(ltfS, i))
                else
                    f_addBin(array.get(ltfC, i), array.get(ltfV, i), array.get(ltfS, i))
        else if not na(volume) and volume > 0
            curLtf := false
            float sgnBar = close > open ? 1.0 : close < open ? -1.0 : 0.0
            if spreadMode
                f_addSpread(low, high, volume, sgnBar)
            else
                f_addBin(priceSrc == "HLC3" ? hlc3 : priceSrc == "OHLC4" ? ohlc4 : close, volume, sgnBar)

// --- per-bar figures for the colouring engines (every bar, unconditionally) ---
float barDeltaLtf = haveLtf ? array.sum(ltfS) : (close > open ? volume : close < open ? -volume : 0.0)

// Delta HTF candles: the chart bar's delta folded into the higher-timeframe
// candle it belongs to. Closed bars are committed once; the live bar is added
// on top for display so nothing is double-counted when it closes. The history
// of completed HTF deltas feeds the normalisation, exactly as in Delta Candles.
string htfPaintTf = paintHtf == "Profile period" ? anchorTf : paintHtf
bool   htfPaintRoll = paintHtf == "Profile period" ? newSess : timeframe.change(htfPaintTf)
var float htfD = 0.0
var float htfV = 0.0
var array<float> htfHist = array.new<float>()
if htfPaintRoll
    if htfV > 0
        array.push(htfHist, htfD)
        while array.size(htfHist) > paintHtfN
            array.shift(htfHist)
    htfD := 0.0
    htfV := 0.0
if barstate.isconfirmed and not na(barDeltaLtf)
    htfD += barDeltaLtf
    htfV += nz(volume)
// DRE reference profiles: one map per delta-timeframe candle, kept for the
// last dreN candles, plus a running composite of them. On every roll the
// finished candle's map is filed and, if the window is full, the oldest map
// is subtracted from the composite. POC/VA of the composite are taken on the
// roll and held, so the reference is fixed through the live candle.
var map<float, float> cMap = map.new<float, float>()        // current HTF candle
var map<float, float> cBuy = map.new<float, float>()
var map<float, float> wMap = map.new<float, float>()        // composite window
var map<float, float> wBuy = map.new<float, float>()
// Pine does not allow a collection directly inside another collection, so
// each filed candle's two maps ride inside a small object.
type Prof
    map<float, float> vol
    map<float, float> buy
var array<Prof> wStack = array.new<Prof>()
var array<float> wPocHist = array.new<float>()
var float refPocW = na
var float refVahW = na
var float refValW = na
var float refPocL = na
var float refVahL = na
var float refValL = na
f_mapAdd(map<float, float> dst, map<float, float> src, float sgn) =>
    if map.size(src) > 0
        array<float> ks = map.keys(src)
        for i = 0 to array.size(ks) - 1
            float k = array.get(ks, i)
            map.put(dst, k, nz(map.get(dst, k)) + sgn * nz(map.get(src, k)))
if htfPaintRoll
    if map.size(cMap) > 0
        [lp, lpv, lt, lb, lvah, lval] = f_analyseMap(cMap, cBuy)
        refPocL := lp
        refVahL := lvah
        refValL := lval
        array.push(wStack, Prof.new(map.copy(cMap), map.copy(cBuy)))
        f_mapAdd(wMap, cMap, 1.0)
        f_mapAdd(wBuy, cBuy, 1.0)
        while array.size(wStack) > dreN
            Prof old = array.shift(wStack)
            f_mapAdd(wMap, old.vol, -1.0)
            f_mapAdd(wBuy, old.buy, -1.0)
        [wp, wpv, wt, wb, wvah, wval] = f_analyseMap(wMap, wBuy)
        refPocW := wp
        refVahW := wvah
        refValW := wval
        array.push(wPocHist, wp)
        while array.size(wPocHist) > dreMigK + 1
            array.shift(wPocHist)
    map.clear(cMap)
    map.clear(cBuy)
if barstate.isconfirmed and haveLtf
    for i = 0 to array.size(ltfC) - 1
        float v = array.get(ltfV, i)
        float b = array.get(ltfS, i) > 0 ? v : 0.0
        if spreadMode
            float k0 = f_bin(array.get(ltfL, i))
            float k1 = f_bin(array.get(ltfH, i))
            if not na(k0) and not na(k1) and v > 0
                int nb = math.max(1, math.min(400, int(math.round((k1 - k0) / binPx)) + 1))
                for j = 0 to nb - 1
                    float k = math.round(k0 / binPx + j) * binPx
                    map.put(cMap, k, nz(map.get(cMap, k)) + v / nb)
                    map.put(cBuy, k, nz(map.get(cBuy, k)) + b / nb)
        else
            float k = f_bin(array.get(ltfC, i))
            if not na(k) and v > 0
                map.put(cMap, k, nz(map.get(cMap, k)) + v)
                map.put(cBuy, k, nz(map.get(cBuy, k)) + b)
else if barstate.isconfirmed and not na(volume) and volume > 0
    float k = f_bin(close)
    if not na(k)
        map.put(cMap, k, nz(map.get(cMap, k)) + volume)
        map.put(cBuy, k, nz(map.get(cBuy, k)) + (close > open ? volume : 0.0))
float relVolSma = ta.sma(nz(volume), 20)

float htfLiveD = htfD + (barstate.isconfirmed ? 0.0 : nz(barDeltaLtf))
float htfLiveV = htfV + (barstate.isconfirmed ? 0.0 : nz(volume))
float htfAvgAbs = 0.0
if array.size(htfHist) > 0
    for d in htfHist
        htfAvgAbs += math.abs(nz(d))
    htfAvgAbs /= array.size(htfHist)
float barUpVol    = haveLtf ? (array.sum(ltfV) + array.sum(ltfS)) / 2.0 : (close > open ? volume : 0.0)
float avgAbsD     = ta.sma(math.abs(nz(barDeltaLtf)), paintLook)
// session running totals and the heaviest bin seen so far (approximate, cheap)
var float sessVol  = 0.0
var float sessUp   = 0.0
var float sessMaxV = 0.0
if newSess
    sessVol := 0.0
    sessUp := 0.0
    sessMaxV := 0.0
if inSess and barstate.isconfirmed
    sessVol += nz(volume)
    sessUp += nz(barUpVol)
    float vHere = nz(map.get(volMap, f_bin(close)))
    sessMaxV := math.max(sessMaxV, vHere)

// --- naked / tested bookkeeping ---------------------------------------------
// A POC is tested the first time any later bar's range covers it.
bool touchedNaked = false
if barstate.isconfirmed and array.size(done) > 0
    for i = 0 to array.size(done) - 1
        Sess s = array.get(done, i)
        if not s.tested and not na(s.poc) and bar_index > s.b1 and low <= s.poc and high >= s.poc
            s.tested := true
            s.testedBar := bar_index
            s.testedT := time
            touchedNaked := true

// =============================================================================
// LIVE DRAW — runs on the last bar only
// =============================================================================
var array<box> devRows = array.new<box>()
var box   devVaBox = na
var line  devPoc = na
var line  devVah = na
var line  devVal = na
var label devTagL = na
var table tb = table.new(position.top_right, 2, 10, border_width = 1)

float devPocPx = na
float devVahPx = na
float devValPx = na
float devVolT = na
float devBuyT = na

if barstate.islast
    // ---- completed sessions: extend lines, refresh tags, fade tested ones ----
    if array.size(done) > 0
        for i = 0 to array.size(done) - 1
            Sess s = array.get(done, i)
            bool showIt = mAll and mPoc and not (s.tested and pocHideTested)
            int xEnd = pocExtend == "Across its session only" ? s.t1
                 : (s.tested and pocStopAtTest and not na(s.testedT)) ? s.testedT : time
            color pc = s.tested ? cPocTest : cPocNaked
            if not na(s.pocLn)
                line.set_x2(s.pocLn, showIt ? xEnd : s.t1)
                line.set_color(s.pocLn, showIt ? pc : color.new(pc, 100))
            if not na(s.vahLn)
                int vx = vaExtend ? time : s.t1
                line.set_x2(s.vahLn, vx)
                line.set_x2(s.valLn, vx)
                line.set_color(s.vahLn, mAll and mVA ? cVA : color.new(cVA, 100))
                line.set_color(s.valLn, mAll and mVA ? cVA : color.new(cVA, 100))
            if not na(s.tag)
                int ago = array.size(done) - i
                float buyPct = s.vol > 0 ? s.buyVol / s.vol * 100.0 : na
                string txt = tagWhat == "Price only" ? str.tostring(s.poc, format.mintick)
                     : str.tostring(ago) + " " + (tfMode ? (sessMode == "1 hour" ? "h" : sessMode == "4 hours" ? "×4h" : sessMode == "1 week" ? "wk" : sessMode == "2 weeks" ? "×2wk" : sessMode == "1 month" ? "mo" : "day") : (ago == 1 ? "session" : "sessions")) + " ago"
                       + (tagWhat == "Age only" ? "" : " · Vol " + f_vol(s.vol))
                       + (tagWhat == "Age · volume · up-vol %" and not na(buyPct)
                            ? " · " + str.tostring(buyPct, "#") + "% up-vol" : "")
                       + (s.tested ? " · tested" : "")
                label.set_xy(s.tag, xEnd + tagOff * barMs, s.poc)
                label.set_text(s.tag, showIt and mTags and tagOn ? txt : "")
                label.set_textcolor(s.tag, s.tested ? cPocTest : cPocNaked)
                label.set_size(s.tag, f_size(tagSz))

    // ---- developing session -------------------------------------------------
    // Read the closed bars' maps plus the live bar's intrabars without
    // committing the live bar, so nothing is double-counted when it closes.
    if array.size(devRows) > 0
        for i = 0 to array.size(devRows) - 1
            box.delete(array.get(devRows, i))
        array.clear(devRows)
    if not na(devVaBox)
        box.delete(devVaBox)
    if not na(devPoc)
        line.delete(devPoc)
    if not na(devVah)
        line.delete(devVah)
    if not na(devVal)
        line.delete(devVal)
    if not na(devTagL)
        label.delete(devTagL)
    if not na(ibHLive)
        line.delete(ibHLive)
    if not na(ibLLive)
        line.delete(ibLLive)
    if mAll and mDev and inSess and not na(cur.b0)
        // temporarily fold the live bar in, analyse, then take it back out
        array<float> liveK = array.new<float>()
        array<float> liveV = array.new<float>()
        array<float> liveB = array.new<float>()
        // Each live contribution is listed as (bin, volume, up-volume) so the
        // same list can be subtracted again afterwards, spread or not.
        if not barstate.isconfirmed
            if haveLtf
                for i = 0 to array.size(ltfC) - 1
                    float v = array.get(ltfV, i)
                    float b = array.get(ltfS, i) > 0 ? v : 0.0
                    if spreadMode
                        float k0 = f_bin(array.get(ltfL, i))
                        float k1 = f_bin(array.get(ltfH, i))
                        if not na(k0) and not na(k1) and v > 0
                            int nb = math.max(1, math.min(400, int(math.round((k1 - k0) / binPx)) + 1))
                            for j = 0 to nb - 1
                                array.push(liveK, math.round(k0 / binPx + j) * binPx)
                                array.push(liveV, v / nb)
                                array.push(liveB, b / nb)
                    else
                        float k = f_bin(array.get(ltfC, i))
                        if not na(k) and v > 0
                            array.push(liveK, k)
                            array.push(liveV, v)
                            array.push(liveB, b)
            else if not na(volume) and volume > 0
                float b = close > open ? volume : 0.0
                if spreadMode
                    float k0 = f_bin(low)
                    float k1 = f_bin(high)
                    int nb = math.max(1, math.min(400, int(math.round((k1 - k0) / binPx)) + 1))
                    for j = 0 to nb - 1
                        array.push(liveK, math.round(k0 / binPx + j) * binPx)
                        array.push(liveV, volume / nb)
                        array.push(liveB, b / nb)
                else
                    array.push(liveK, f_bin(priceSrc == "HLC3" ? hlc3 : priceSrc == "OHLC4" ? ohlc4 : close))
                    array.push(liveV, volume)
                    array.push(liveB, b)
        if array.size(liveK) > 0
            for i = 0 to array.size(liveK) - 1
                float k = array.get(liveK, i)
                map.put(volMap, k, nz(map.get(volMap, k)) + array.get(liveV, i))
                map.put(buyMap, k, nz(map.get(buyMap, k)) + array.get(liveB, i))
        [dp, dpv, dt, db, dvah, dval] = f_analyse()
        devPocPx := dp
        devVahPx := dvah
        devValPx := dval
        devVolT := dt
        devBuyT := db
        float dHi = math.max(nz(cur.hi, high), high)
        float dLo = math.min(nz(cur.lo, low), low)
        if devProf and mProf
            f_drawRows(devRows, cur.t0, time, dLo, dHi, rowsN)
        if mVA and vaFill and not na(dvah)
            devVaBox := box.new(cur.t0, dvah, time, dval, border_width = 0,
                 bgcolor = color.new(cVA, vaFillT), xloc = xloc.bar_time)
        if devPocOn and not na(dp)
            devPoc := line.new(cur.t0, dp, time + tagOff * barMs, dp, xloc = xloc.bar_time,
                 color = cDevPoc, width = wDevPoc, style = f_style(sPoc))
            if devTag
                float bp = dt > 0 ? db / dt * 100.0 : na
                devTagL := label.new(time + tagOff * barMs, dp,
                     "developing · Vol " + f_vol(dt) + (na(bp) ? "" : " · " + str.tostring(bp, "#") + "% up-vol"),
                     xloc = xloc.bar_time, style = label.style_label_left,
                     color = color.new(cDevPoc, 100), textcolor = cDevPoc, size = f_size(tagSz))
        if devVAOn and mVA and not na(dvah)
            devVah := line.new(cur.t0, dvah, time, dvah, xloc = xloc.bar_time, color = cVA, width = wVA, style = f_style(sVA))
            devVal := line.new(cur.t0, dval, time, dval, xloc = xloc.bar_time, color = cVA, width = wVA, style = f_style(sVA))
        if mIB and ibOn and not na(cur.ibH)
            float ibHi = math.max(cur.ibH, time - sessStartT < ibMin * 60000 ? high : cur.ibH)
            float ibLo = math.min(cur.ibL, time - sessStartT < ibMin * 60000 ? low : cur.ibL)
            int ibX = ibExtend ? time : sessStartT + ibMin * 60000
            ibHLive := line.new(cur.t0, ibHi, ibX, ibHi, xloc = xloc.bar_time, color = cIB, width = wIB, style = f_style(sIB))
            ibLLive := line.new(cur.t0, ibLo, ibX, ibLo, xloc = xloc.bar_time, color = cIB, width = wIB, style = f_style(sIB))
        // take the live bar back out
        if array.size(liveK) > 0
            for i = 0 to array.size(liveK) - 1
                float k = array.get(liveK, i)
                map.put(volMap, k, nz(map.get(volMap, k)) - array.get(liveV, i))
                map.put(buyMap, k, nz(map.get(buyMap, k)) - array.get(liveB, i))

    // ---- panel ----------------------------------------------------------------
    table.clear(tb, 0, 0, 1, 9)
    table.set_position(tb, f_pos(panelPos))
    table.set_bgcolor(tb, color.new(panelBg, panelBgT))
    if mAll and mPanel and panelOn
        int r = 0
        table.cell(tb, 0, r, "STRYK:SVP", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_left)
        table.cell(tb, 1, r, sessMode == "Custom session" ? sessCust : str.replace(sessMode, "CME ", ""), text_color = color.new(panelTx, 40), text_size = f_size(panelSz), text_halign = text.align_right)
        r += 1
        int nakedN = 0
        if array.size(done) > 0
            for i = 0 to array.size(done) - 1
                if not array.get(done, i).tested
                    nakedN += 1
        table.cell(tb, 0, r, "Sessions kept", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_left)
        table.cell(tb, 1, r, str.tostring(array.size(done)) + "  (" + str.tostring(nakedN) + " naked POC)", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_right)
        r += 1
        if inSess and not na(devPocPx)
            float bp = devVolT > 0 ? devBuyT / devVolT * 100.0 : na
            table.cell(tb, 0, r, "Developing POC", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_left)
            table.cell(tb, 1, r, str.tostring(devPocPx, format.mintick), text_color = cDevPoc, text_size = f_size(panelSz), text_halign = text.align_right)
            r += 1
            table.cell(tb, 0, r, "Value area", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_left)
            table.cell(tb, 1, r, (na(devValPx) or na(devVahPx) ? "n/a" : str.tostring(devValPx, format.mintick) + " – " + str.tostring(devVahPx, format.mintick)), text_color = cVA, text_size = f_size(panelSz), text_halign = text.align_right)
            r += 1
            table.cell(tb, 0, r, "Volume · up-vol", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_left)
            table.cell(tb, 1, r, f_vol(devVolT) + (na(bp) ? "" : "  " + str.tostring(bp, "#") + "%"),
                 text_color = na(bp) ? panelTx : bp >= 50 ? cBarBuy : cBarSell, text_size = f_size(panelSz), text_halign = text.align_right)
            r += 1
            string where = na(devVahPx) or na(devValPx) ? "n/a" : close > devVahPx ? "above value" : close < devValPx ? "below value" : "inside value"
            table.cell(tb, 0, r, "Price is", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_left)
            table.cell(tb, 1, r, where, text_color = where == "inside value" ? color.new(panelTx, 30) : cPocNaked, text_size = f_size(panelSz), text_halign = text.align_right)
            r += 1
        if mIB and ibOn and inSess and not na(cur.ibH)
            table.cell(tb, 0, r, "IB " + str.tostring(ibMin) + "m", text_color = panelTx, text_size = f_size(panelSz), text_halign = text.align_left)
            table.cell(tb, 1, r, str.tostring(cur.ibL, format.mintick) + " – " + str.tostring(cur.ibH, format.mintick), text_color = cIB, text_size = f_size(panelSz), text_halign = text.align_right)
            r += 1
        table.cell(tb, 0, r, "Built from", text_color = color.new(panelTx, 40), text_size = f_size(panelSz), text_halign = text.align_left)
        table.cell(tb, 1, r, (curLtf and haveLtf ? ltfStr + " intrabars" : "chart bars (no intrabar data)") + " · " + priceSrc + " · bin " + str.tostring(binTicks) + "t",
             text_color = curLtf and haveLtf ? color.new(panelTx, 40) : cPocNaked, text_size = f_size(panelSz), text_halign = text.align_right)
        r += 1
        if rowsClamped
            table.cell(tb, 0, r, "Rows clamped to " + str.tostring(rowsN) + " to stay inside the box limit", text_color = cPocNaked, text_size = f_size(panelSz), text_halign = text.align_left)
            table.cell(tb, 1, r, "", text_color = cPocNaked, text_size = f_size(panelSz), text_halign = text.align_right)
            r += 1

// =============================================================================
// CANDLE COLOURING
// =============================================================================
// Sits after the live draw so the developing session's levels exist when the
// reference is set to it. Prior session on every historical bar regardless.
Sess refS = array.size(done) > 0 ? array.get(done, array.size(done) - 1) : na
bool useDev = paintRef == "Developing session" and barstate.islast and not na(devPocPx)
float refPoc = useDev ? devPocPx : na(refS) ? na : refS.poc
float refVah = useDev ? devVahPx : na(refS) ? na : refS.vah
float refVal = useDev ? devValPx : na(refS) ? na : refS.val

f_grad(float n) =>
    n >= 0 ? color.from_gradient(n, 0, 1, cPaintNeut, cPaintBull) : color.from_gradient(n, -1, 0, cPaintBear, cPaintNeut)

// 0 · Delta HTF candles (DRE) — the STRYK:DRE / STRYK:M engine, ported as is
float dPoc = dreRef == "HTF window (N candles)" ? refPocW : dreRef == "Last HTF candle" ? refPocL : refPoc
float dVah = dreRef == "HTF window (N candles)" ? refVahW : dreRef == "Last HTF candle" ? refVahL : refVah
float dVal = dreRef == "HTF window (N candles)" ? refValW : dreRef == "Last HTF candle" ? refValL : refVal
// acceptance — consecutive closes beyond the edge; a return inside collapses it
var int dreAcc = 0
bool dreUp = not na(dVah) and close > dVah
bool dreDn = not na(dVal) and close < dVal
if barstate.isconfirmed
    dreAcc := dreUp or dreDn ? ((dreUp and dreUp[1]) or (dreDn and dreDn[1]) ? dreAcc + 1 : 1) : 0
float dreAccF = math.min(1.0, dreAcc / math.max(1.0, dreAccBars))
// relative size — this bar's volume against the recent average
float dreRelV = relVolSma > 0 ? nz(volume) / relVolSma : na
float dreSizeF = na(dreRelV) ? 0.0 : math.max(0.0, math.min(1.0, (dreRelV - 1.0) / math.max(0.1, dreSizeFull - 1.0)))
// migration — is accepted value itself moving the way price broke
float dreVaW = na(dVah) or na(dVal) ? na : dVah - dVal
float dreBack = array.size(wPocHist) > dreMigK ? array.get(wPocHist, array.size(wPocHist) - 1 - dreMigK) : na
float dreMig = na(refPocW) or na(dreBack) or na(dreVaW) or dreVaW <= 0 ? 0.0 : (refPocW - dreBack) / dreVaW
bool dreMigAl = (dreUp and dreMig > 0) or (dreDn and dreMig < 0)
float dreMigF = dreMigAl ? math.min(1.0, math.abs(dreMig)) : 0.0
float dreExtra = dreInt == "Strongest" ? math.max(dreAccF, math.max(dreSizeF, dreMigF)) : (dreAccF + dreSizeF + dreMigF) / 3.0

color cDre = cPaintNeut
if not na(dPoc) and not na(dVah) and not na(dVal) and dVah > dVal
    float w = dVah - dVal
    float rampW = math.max(syminfo.mintick, w * dreRamp / 100.0)
    if close > dVah or close < dVal
        float beyond = close > dVah ? close - dVah : dVal - close
        float fracD = math.min(1.0, beyond / rampW)
        float frac = dreInt == "Distance only" ? fracD : dreInt == "Strongest" ? math.max(fracD, dreExtra) : (fracD + dreExtra) / 2.0
        bool greenZone = close > dVah
        bool aligned = (greenZone and htfLiveD > 0) or (not greenZone and htfLiveD < 0)
        float adj = aligned ? math.min(1.0, frac + dreBoost) : frac * (1.0 - dreBoost)
        cDre := greenZone ? color.from_gradient(adj, 0, 1, cPaintNeut, cPaintBull) : color.from_gradient(adj, 0, 1, cPaintNeut, cPaintBear)
    else
        float halfW = math.max(syminfo.mintick, math.max(dVah - dPoc, dPoc - dVal))
        float centering = 1.0 - math.min(1.0, math.abs(close - dPoc) / halfW)
        float dq = htfAvgAbs > 0 ? 1.0 - math.min(1.0, math.abs(htfLiveD) / htfAvgAbs) : 0.5
        float depth = math.max(0.0, math.min(1.0, (centering + dq) / 2.0))
        int transp = int(math.round(70 - depth * 70))
        float lean = dreLean * math.min(1.0, math.abs(close - dPoc) / halfW)
        color leanCol = close > dPoc ? color.from_gradient(lean, 0, 1, cPaintNeut, cPaintBull) : color.from_gradient(lean, 0, 1, cPaintNeut, cPaintBear)
        cDre := color.new(dreLean > 0 ? leanCol : cPaintNeut, transp)

// 0b · Delta HTF gradient (ΔC) — the Delta Candles engine
float hScale = htfAvgAbs > 0 ? htfAvgAbs * paintSens : math.abs(htfLiveD)
float hPct = htfLiveV > 0 ? htfLiveD / htfLiveV : 0.0
float hRaw = paintMode == "Delta % (imbalance)" ? math.max(-1.0, math.min(1.0, hPct * paintSens / 0.15))
     : hScale > 0 ? math.max(-1.0, math.min(1.0, htfLiveD / hScale)) : 0.0
float hCurved = paintCurve == "Boosted" ? math.sign(hRaw) * math.pow(math.abs(hRaw), 0.55) : hRaw
color cHtf = f_grad(hCurved)

// 1 · Delta gradient — the same maths on the bar's own delta
float scaleRef = avgAbsD > 0 ? avgAbsD * paintSens : math.abs(nz(barDeltaLtf))
float dPct = volume > 0 ? nz(barDeltaLtf) / volume : 0.0
float rawN = paintMode == "Delta % (imbalance)" ? math.max(-1.0, math.min(1.0, dPct * paintSens / 0.15))
     : scaleRef > 0 ? math.max(-1.0, math.min(1.0, nz(barDeltaLtf) / scaleRef)) : 0.0
float curvedN = paintCurve == "Boosted" ? math.sign(rawN) * math.pow(math.abs(rawN), 0.55) : rawN
color cGrad = f_grad(curvedN)

// 2 · Delta sign — the Delta-TD tint
color cSign = nz(barDeltaLtf) > 0 ? cPaintBull : nz(barDeltaLtf) < 0 ? cPaintBear : cPaintNeut

// 3 · Value area position
color cVApos = na(refVah) or na(refVal) ? na
     : close > refVah ? cPaintBull : close < refVal ? cPaintBear : cPaintNeut

// 4 · Distance from POC, scaled by the value-area width
float vaW = na(refVah) or na(refVal) ? na : math.max(syminfo.mintick, refVah - refVal)
float pocN = na(refPoc) or na(vaW) ? na : math.max(-1.0, math.min(1.0, (close - refPoc) / vaW))
color cPocDist = na(pocN) ? na : f_grad(pocN)

// 5 · Volume at price — the heatmap ramp on the bar's own close
float vAtClose = nz(map.get(volMap, f_bin(close)))
float heatF = sessMaxV > 0 ? math.min(1.0, vAtClose / sessMaxV) : 0.0
color cHeatBar = inSess ? f_heat(heatF) : na

// 6 · Naked POC proximity — coloured only when within reach of an untested POC
bool nearNaked = false
if array.size(done) > 0
    for i = 0 to array.size(done) - 1
        Sess s = array.get(done, i)
        if not s.tested and not na(s.poc) and math.abs(close - s.poc) <= nakedTol * syminfo.mintick
            nearNaked := true
color cNaked = nearNaked ? cPocNaked : na

// 7 · Session up-vol share
float upShare = sessVol > 0 ? sessUp / sessVol : na
color cShare = na(upShare) ? na : f_grad(math.max(-1.0, math.min(1.0, (upShare - 0.5) / 0.15)))

color paintCol = paintEngine == "Delta HTF candles (DRE)" ? cDre
     : paintEngine == "Delta HTF gradient (ΔC)" ? cHtf
     : paintEngine == "Delta gradient" ? cGrad
     : paintEngine == "Delta sign" ? cSign
     : paintEngine == "Value area position" ? cVApos
     : paintEngine == "Distance from POC" ? cPocDist
     : paintEngine == "Volume at price (heat)" ? cHeatBar
     : paintEngine == "Naked POC proximity" ? cNaked
     : cShare
// barcolor() recolours bodies only; TradingView leaves wicks and borders on
// the chart's own colours. plotcandle() draws a full candle in one colour on
// top, which is how Delta Candles does it. Hide the chart's own candles (eye
// icon beside the ticker) for the cleanest look.
color paintFinal = mAll and mPaint and not na(paintCol) ? color.new(paintCol, paintT) : na
barcolor(paintFinal, title = "SVP candle colouring (body)")
plotcandle(open, high, low, close, title = "SVP candle colouring", color = paintFinal,
     wickcolor = paintFinal, bordercolor = paintFinal)

// =============================================================================
// ALERTS — on confirmed bars only
// =============================================================================
if barstate.isconfirmed and alNaked and touchedNaked
    alert("STRYK: SVP " + syminfo.ticker + " — price traded through a naked session POC", alert.freq_once_per_bar_close)

// The developing POC moves, so "cross" is evaluated against where it was last bar.
var float lastDevPoc = na
var float lastDevVah = na
var float lastDevVal = na
if barstate.isconfirmed
    if alDevPoc and not na(lastDevPoc) and ((close > lastDevPoc and close[1] <= lastDevPoc) or (close < lastDevPoc and close[1] >= lastDevPoc))
        alert("STRYK: SVP " + syminfo.ticker + " — close crossed the developing POC at " + str.tostring(lastDevPoc, format.mintick), alert.freq_once_per_bar_close)
    if alVA and not na(lastDevVah) and ((close > lastDevVah and close[1] <= lastDevVah) or (close < lastDevVal and close[1] >= lastDevVal))
        alert("STRYK: SVP " + syminfo.ticker + " — close left the developing value area", alert.freq_once_per_bar_close)
if not na(devPocPx)
    lastDevPoc := devPocPx
    lastDevVah := devVahPx
    lastDevVal := devValPx
````
