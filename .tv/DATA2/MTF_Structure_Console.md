<!-- tradingview-pine-id: PUB;2d3634f9df834206b90365280664a2ce -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MTF Structure Console

Source: https://www.tradingview.com/script/kQ340VrN-MTF-Structure-Console-Sreeni/

## Description

MTF Structure Console

by Sreeni

What it does

Combines Bollinger Bands with Strat-style bar classification, multi-timeframe regime context, pre-computed trade levels, and the context a swing trader needs to judge a breakout: volume, structure in the way, and strength relative to the market. A two-candle pattern is never read in isolation.

Most inside-bar indicators mark the pattern and stop there. This one answers the questions that come after: what are the higher timeframes doing, what would the regime become if this bar breaks, where is the trigger, where does the stop go, how wide is the risk relative to normal range, is there a prior high in the way before the first target, and did the break happen on real participation.

Bar classification

Every bar is labelled against the prior bar on the same timeframe:

1 — Inside bar. Range contained within the prior bar. Compression.
2u / 2d — Directional. One side of the prior bar broken.
3 — Outside bar. Both sides broken. Expansion.

Inside bars are coloured and labelled "IB", outside bars "OB". A 3 followed by a 1 — maximum expansion into maximum compression — is highlighted across both candles.

An option controls whether a bar that merely equals the prior high or low counts as having broken that side. The default treats equality as non-breaking, which catches inside bars that a strict greater-than test misses. The same rule is applied to the chart and to every row of the regime table, so the two never disagree about the same bar.

Multi-timeframe regime table

Four configurable timeframes (Monthly / Weekly / Daily / 60m by default), each showing:

Scenario label (1 / 2u / 2d / 3)
Bar colour (close vs open)
In Force state — whether the close has actually cleared the prior bar's high or low, rather than merely drifting inside it

The row matching the chart timeframe is marked. A timeframe below the chart cannot be read from chart bars, so it is shown as n/a and left out of the aggregates rather than shown as a meaningless number.

Then the aggregates:

FTFC — do all readable timeframes agree in colour; when mixed, how many are green and how many red
MTF In Force — how many have genuinely broken prior structure, split into bull / bear / equilibrium so that "3 of 4 committed" cannot hide two bulls and a bear
Regime grade — A (full alignment) through N (standby / chop):
A: colour agreement and In Force in the same direction on every readable timeframe
B: colour agreement on all, but at least one timeframe still in equilibrium
C: all but one agree in colour, and the two highest timeframes are among them
D: anything more conflicted than C
N: the decision timeframe is an inside bar, or the two highest timeframes are opposite colours
If break — the grade the regime would have if the current chart bar broke up, and if it broke down. This is computed by substituting a 2u / 2d reading for the chart timeframe's row and re-running the grade. It tells you which side the higher timeframes support before the break happens. Shown only when the chart timeframe is one of the four table rows.

Agreement and commitment are deliberately kept separate. An instrument can be green on all four timeframes while never clearing a prior high; that is drift, not a breakout, and the table shows the difference.

On repainting: by default every higher-timeframe value comes from the last closed bar on that timeframe, so nothing in the table repaints. The offset is applied only to timeframes above the chart; a row equal to the chart timeframe uses the current bar, which is already complete at the close. A toggle switches to the live forming bar if you prefer current-but-provisional readings. The table footer states which mode is active.

Trigger levels, breaks and setup status

When an inside bar forms, the script projects:

Trigger lines at the bar's high and low, extending right until one is taken out. The pattern is the setup; the break is the event.
Stop levels, both directions, dashed until a break resolves which one applies.
R-multiple targets (default 1R / 2R / 3R) projected from the trigger once a break occurs.
Position size for your stated per-trade risk.

What counts as a break. By default the bar must close beyond the trigger on a completed bar — the same test the table uses for In Force. A wick through the level that closes back inside is not a break; it is usually the opposite. A "Wick" mode is available for traders who enter on the touch, evaluated live.

If a single bar takes out both sides of the inside bar (a 1-3), the direction is decided by its close. If it closes back inside the range, nothing has resolved and the setup keeps watching.

With consecutive inside bars, the triggers can re-anchor to each new narrower bar (default) or stay on the first bar of the run until its outer range breaks.

Setup status. After a break the levels stay on screen and the script keeps tracking the setup for a configurable number of bars: the status row reads Watching → Long / Short active → T1 / T2 / T3 hit, or Failed if the bar closes back inside the inside-bar range before any target is reached, or Stopped if the stop level trades. Bars since the break and the running R (distance from entry in units of initial risk) are shown alongside.

Two stop methods:

Structural + ATR buffer (default) — the stop sits beyond the opposite side of the inside bar, pushed out by a fraction of ATR. The level has a thesis behind it: if price re-enters the range, the setup is invalidated regardless of what volatility says. The ATR buffer pushes it past the wick where obvious stops sit.
ATR from trigger — a fixed ATR distance from the entry level. Simpler and uniform, but it can land inside the bar's own range, where normal movement takes you out.

ATR is frozen at the signal bar and held for the life of the setup. A level that recalculates every bar drifts, and a drifting stop is not a stop.

ATR is a simple average of true range over a configurable length (default 5), read from a configurable timeframe, defaulting to daily. A swing stop should respect the instrument's daily range even when the pattern is found intraday. If the chart timeframe is higher than the ATR timeframe, the chart timeframe is used instead, so a weekly inside bar is measured against weekly ranges rather than being rejected for being wider than a day.

Risk filter

Structural risk is expressed as a multiple of ATR and shown in the table. Setups above your threshold (default 1.5x ATR) are rejected outright — no lines, no alerts. When the stop is that far away, position size shrinks until the trade stops being worth the slot.

Most of the value here is in the setups that never get drawn.

Setup table (optional, off by default)

A second table carries the context around the setup:

Distance to trigger from the current close, in ATR and percent, both directions — whether to be watching tonight or next week.
Inside-bar context — what preceded the inside bar decides what each break means. After a 2d, an upside break is a 2-1-2 reversal and a downside break is continuation; after a 2u the reverse; after a 3 it is a 3-1 resolving.
Structure in the way — the nearest prior pivot high above the trigger and pivot low below it, each expressed as a distance in R, plus the prior completed bar's high / low on the second table timeframe (weekly by default). If the nearest structure sits under a configurable distance (default 1R), the row flags "into structure": the first obstacle arrives before the first target. Prior pivots are treated as targets, not support or resistance — they are where the last group of traders was trapped and where the move tends to travel before deciding. A pivot is defined by a configurable number of bars either side (default 5 / 5), so it is confirmed and never repaints, and is always that many bars stale.
Volume — ratio to the prior N-bar average (default 20), for the inside bar, the bar before it, and the current bar. Tiers: Low under 0.7x, Normal, High above 1.5x, Climax above 2.5x (all configurable). A live intraday bar carries partial volume, so its ratio is projected by the fraction of the session elapsed and marked "proj". Hidden on instruments that report no volume.
Break bar — the break bar's volume ratio, its range as a multiple of ATR, and where it closed within its own range. A wide-range, high-volume bar closing near its extreme is a different event from a narrow churn bar closing mid-range.
Relative strength versus a configurable benchmark (default SPY): the instrument's return over two lookbacks (default 20 and 60 bars) minus the benchmark's, on the chart timeframe. Positive means it outperformed. The benchmark's own bar state is shown, and at the moment of a break the script records whether the benchmark broke too or was itself an inside bar — a break that happens without the index is noted as such. Set the benchmark to a sector ETF if that is the comparison that matters for your names.

Alerts

Nine conditions: inside bar, outside bar, 3-1 pattern, the two trigger breaks, break on elevated volume, failed break, stop hit, and target 1 hit.

Breaks can be gated so they only fire when the direction agrees with the higher-timeframe leaning, and optionally when relative strength agrees too, which cuts alert volume sharply. Break alerts respect the close / wick setting.

A dynamic alert() is also included, carrying the actual trigger price, stop, risk per share, break-bar volume, regime grade and relative strength in the message. Select "Any alert() function call" when creating it.

Settings worth knowing

Break confirmation (default Close). Change it to Wick only if you know why.
Signal only on closed bars (default on). With it off, a live inside bar can become an outside bar before the close and labels shift accordingly.
Text sizes — table body, table headers, IB/OB labels, break arrows and level prices each have independent size controls, Tiny through Huge.
Timeframes are inputs, not hardcoded. Swing traders working a 4H execution timeframe can set W/D/4H/1H, and the "If break" row then reads the 4H row.
Risk per trade drives the position-size column. Set it to your actual figure or the numbers mean nothing.
Price labels on the chart are off by default; every level is in the tables.

How to use it

Read the regime table first. Grade N or D means stand aside regardless of what the candles look like. Then read "If break": if only one side leads to an A or B, that is the side worth waiting for.
Find the inside bar. It is a watchlist item, not an entry. Open the setup table and check what preceded it and whether there is structure inside 1R.
Wait for the close beyond the trigger line. That is the only permission.
Check the break bar: was it on volume, was it wide, did it close near its extreme, did the index break with it or not.
Check risk in ATR terms before sizing. If it is wide, it is wide — reduce or skip.
The stop level is where the premise fails. If you are moving it, you are no longer trading the setup. A failed break — a close back inside the range — is the setup telling you it was wrong.

Known limitations

Markers are drawn as label objects so their size can be configured; TradingView caps these at 500 per chart, so the oldest drop off as you scroll back. Bar colouring and background highlights are unaffected.
The regime grade flags a decision-timeframe inside bar as standby. That is intentional — the decision timeframe has not committed yet — and the "If break" row exists precisely to show what happens once it does.
Stop levels are decision levels. A resting order fills at whatever an opening gap gives you, and no ATR buffer protects against that.
Relative strength on an intraday chart compares bars that may not align exactly if the benchmark trades different session hours. On daily and above this does not arise.
Volume projection for a live bar assumes volume arrives evenly through the session, which it does not; treat the projected figure as a rough gauge.

Credit

Bar classification follows the scenario framework popularised by Rob Smith (TheStrat). The Bollinger Band, ATR and pivot calculations are standard. Everything else — the regime grading, conditional grading, trigger projection, setup state tracking, ATR stop logic, risk filter, sizing, volume tiers and relative-strength readout — is original work in this script.

Author: Sreeni — @t2make

Educational tool — not trading advice

This indicator is published for learning and research purposes only.

It describes the structure of past and current price action using a fixed, published rule set. It does not predict future price movement, does not generate buy or sell recommendations, and is not investment, financial, legal or tax advice. Nothing here is a solicitation to trade any instrument.

No representation is made that any account will or is likely to achieve profits or losses similar to anything shown or described. Past chart behaviour does not indicate future results. Trading and investing involve substantial risk of loss and are not suitable for every person. Only risk capital you can afford to lose.

The levels this script draws — triggers, stops and targets — are illustrations of a rule set, not instructions. Stop levels in particular are decision references, not protection: a resting order fills at whatever an opening gap provides, and an ATR buffer does not change that.

The indicator has not been optimised for any instrument, timeframe or market condition, and no backtest, win rate or performance figure is claimed or implied. The setup status readout records what happened to each drawn setup on the chart; it is a description, not a track record. Any settings shown are defaults for illustration, not recommendations.

You are solely responsible for your own trading decisions and their outcomes. Test any tool independently on your own instruments and timeframes, and consult a licensed financial professional before risking capital.

---

## Source Code

````pine
//@version=6
// ============================================================================
//  MTF STRUCTURE CONSOLE
//  by Sreeni  —  @t2make
// ============================================================================
//  Bollinger Bands + bar-structure classification (1 / 2u / 2d / 3), 3-1
//  compression highlight, multi-timeframe regime table (scenario, colour,
//  In Force, FTFC, regime grade, conditional grade), inside-bar trigger levels
//  with close-confirmed breaks and a setup state machine, ATR-based stop
//  placement, R-multiple and prior-pivot targets, position sizing, volume
//  context, relative strength versus a benchmark, and adjustable text sizes.
//
//  ----------------------------------------------------------------------
//  EDUCATIONAL TOOL — NOT TRADING ADVICE
//  ----------------------------------------------------------------------
//  This indicator is published for learning and research purposes only. It
//  describes the structure of past and current price action. It does not
//  predict future price movement, does not generate buy or sell
//  recommendations, and is not investment, financial, legal or tax advice.
//
//  No representation is made that any account will or is likely to achieve
//  profits or losses similar to anything shown. Past chart behaviour does not
//  indicate future results. Trading involves substantial risk of loss and is
//  not suitable for every person.
//
//  Levels drawn by this script (triggers, stops, targets) are illustrations of
//  a rule set, not instructions. Stop levels are decision references, not
//  protection: a resting order fills at whatever an opening gap provides.
//
//  You are solely responsible for your own decisions. Test independently and
//  consult a licensed professional before risking capital.
//
//  Bar-scenario classification follows the framework popularised by Rob Smith
//  (TheStrat). Bollinger Band, ATR and pivot calculations are standard. All
//  remaining logic — regime grading, conditional grading, trigger projection,
//  setup state tracking, ATR stop handling, risk filtering, sizing, volume
//  tiers and relative-strength readout — is original to this script.
// ============================================================================

indicator(title="MTF Structure Console", shorttitle="MTF Console", overlay=true,
     max_lines_count=500, max_labels_count=500)

// ============================== Inputs ==============================
var string GRP_BB  = "Bollinger Bands"
var string GRP_BAR = "Bar Structure"
var string GRP_TRG = "Trigger Levels & Breaks"
var string GRP_RSK = "Stops, Targets & Sizing"
var string GRP_TF  = "Timeframes"
var string GRP_CTX = "Context: Volume, Pivots, Relative Strength"
var string GRP_TBL = "Regime Table & Text"
var string GRP_TB2 = "Setup Table"

src    = input.source(close, "Source", group=GRP_BB)
length = input.int(20, "Length", minval=1, group=GRP_BB)
mult   = input.float(2.0, "StdDev", minval=0.001, maxval=50.0, group=GRP_BB)
showBB = input.bool(true, "Show bands", group=GRP_BB)

tieAsInside = input.bool(true, "Equal high/low counts as inside bar", group=GRP_BAR,
     tooltip="On: a bar must exceed the prior high/low to count as breaking it, so equal highs or lows stay inside. Off: equality counts as a break. The same rule is applied on the chart and in the regime table.")
confirmOnly = input.bool(true, "Signal only on closed bars", group=GRP_BAR)
showLabels  = input.bool(true, "Show IB / OB labels", group=GRP_BAR)
ibCol    = input.color(color.white,                 "Inside bar color",      group=GRP_BAR)
obCol    = input.color(color.black,                 "Outside bar color",     group=GRP_BAR)
ibTxtCol = input.color(color.black,                 "IB label text",         group=GRP_BAR)
obTxtCol = input.color(color.white,                 "OB label text",         group=GRP_BAR)
hgCol    = input.color(color.new(color.yellow, 85), "3-1 background",        group=GRP_BAR)

showTrig  = input.bool(true,  "Plot inside-bar trigger levels", group=GRP_TRG)
hgOnly    = input.bool(false, "Only for 3-1 setups", group=GRP_TRG)
breakMode = input.string("Close", "Break confirmation", options=["Close", "Wick"], group=GRP_TRG,
     tooltip="Close: the bar must CLOSE beyond the trigger on a completed bar, matching the In Force definition. A wick through the level that closes back inside is not a break. Wick: any trade beyond the level counts, evaluated live.")
anchorMode = input.string("Latest inside bar", "Anchor triggers to", options=["Latest inside bar", "First inside bar in a run"], group=GRP_TRG,
     tooltip="With consecutive inside bars: 'Latest' re-anchors the triggers to each new, narrower bar. 'First' keeps the outer range of the run until it breaks.")
gateAlert = input.bool(true,  "Only alert on breaks that agree with the regime leaning", group=GRP_TRG)
extendBars = input.int(20, "Track a setup this many bars after a break", minval=1, maxval=200, group=GRP_TRG)
trigUpCol = input.color(color.new(color.lime, 0), "Upside trigger",   group=GRP_TRG)
trigDnCol = input.color(color.new(color.red,  0), "Downside trigger", group=GRP_TRG)
trigWidth = input.int(1, "Line width", minval=1, maxval=4, group=GRP_TRG)

showStops  = input.bool(true, "Show stop levels", group=GRP_RSK)
stopMode   = input.string("Structural + ATR buffer", "Stop placement",
     options=["Structural + ATR buffer", "ATR from trigger"], group=GRP_RSK,
     tooltip="Structural: stop sits beyond the opposite side of the inside bar, pushed out by an ATR buffer. The setup is invalidated if price re-enters the range, so the stop has a thesis behind it. ATR from trigger: fixed distance from the entry level — simpler risk, but can land inside the bar's own range.")
atrLen     = input.int(5, "ATR length", minval=1, group=GRP_RSK)
atrTF      = input.timeframe("D", "ATR timeframe", group=GRP_RSK,
     tooltip="Daily ATR is usually right even on intraday charts — a swing stop should respect the instrument's daily range. If the chart timeframe is higher than this, the chart timeframe is used instead so weekly setups are not measured against daily ranges.")
bufferMult = input.float(0.25, "Structural buffer (x ATR)", minval=0.0, maxval=3.0, step=0.05, group=GRP_RSK)
atrMult    = input.float(1.0, "Stop distance from trigger (x ATR)", minval=0.1, maxval=10.0, step=0.1, group=GRP_RSK)

useRiskFilter = input.bool(true, "Reject setups whose risk is too wide", group=GRP_RSK)
maxRiskATR    = input.float(1.5, "Max structural risk (x ATR)", minval=0.1, maxval=10.0, step=0.1, group=GRP_RSK,
     tooltip="Structural risk = inside bar range + buffer, measured in ATR. Above this, the stop is so far away that position size shrinks past the point of usefulness.")

showTargets = input.bool(true, "Show R-multiple targets", group=GRP_RSK)
t1R = input.float(1.0, "Target 1 (R)", minval=0.1, step=0.1, group=GRP_RSK)
t2R = input.float(2.0, "Target 2 (R)", minval=0.1, step=0.1, group=GRP_RSK)
t3R = input.float(3.0, "Target 3 (R)", minval=0.1, step=0.1, group=GRP_RSK)

riskAmt    = input.float(500.0, "Risk per trade (account currency)", minval=0.0, group=GRP_RSK)
showPrices = input.bool(false, "Label levels with prices", group=GRP_RSK, tooltip="One label per event. Prices are always available in the tables; turn this on only if you want them on the chart.")
stopCol    = input.color(color.new(color.maroon, 0), "Stop line",   group=GRP_RSK)
tgtCol     = input.color(color.new(color.blue, 0),   "Target line", group=GRP_RSK)

tf1 = input.timeframe("M",  "Timeframe 1 (highest gravity)", group=GRP_TF)
tf2 = input.timeframe("W",  "Timeframe 2", group=GRP_TF)
tf3 = input.timeframe("D",  "Timeframe 3 (decision TF)", group=GRP_TF)
tf4 = input.timeframe("60", "Timeframe 4 (execution)", group=GRP_TF)

useVol     = input.bool(true, "Volume context", group=GRP_CTX)
volLen     = input.int(20, "Volume average length", minval=2, group=GRP_CTX)
volHi      = input.float(1.5, "Elevated volume (x average)", minval=1.0, step=0.1, group=GRP_CTX)
volClimax  = input.float(2.5, "Climactic volume (x average)", minval=1.0, step=0.1, group=GRP_CTX)
showVolMarks = input.bool(true, "Show volume ratio on IB / OB / break markers", group=GRP_CTX)
usePiv     = input.bool(true, "Prior-pivot structural targets", group=GRP_CTX)
pivL       = input.int(5, "Pivot bars left", minval=1, group=GRP_CTX)
pivR       = input.int(5, "Pivot bars right", minval=1, group=GRP_CTX, tooltip="A pivot is only known this many bars after it forms. The level is therefore always confirmed, never repainted, and always slightly stale.")
minStructR = input.float(1.0, "Warn if nearest structure is under (R)", minval=0.1, step=0.1, group=GRP_CTX)
structCol  = input.color(color.new(color.teal, 0), "Structural target line", group=GRP_CTX)
useRS      = input.bool(true, "Relative strength vs benchmark", group=GRP_CTX)
benchSym   = input.symbol("SPY", "Benchmark symbol", group=GRP_CTX, tooltip="Index or sector ETF. Relative strength = the instrument's return over the lookback minus the benchmark's, measured on the chart timeframe.")
rsLen1     = input.int(20, "RS lookback 1 (bars)", minval=1, group=GRP_CTX)
rsLen2     = input.int(60, "RS lookback 2 (bars)", minval=1, group=GRP_CTX)
rsGate     = input.bool(false, "Only alert on breaks that agree with RS lookback 1", group=GRP_CTX)

showTable  = input.bool(true, "Show regime table", group=GRP_TBL)
htfConfirm = input.bool(true, "Use last CLOSED higher-timeframe bar (no repaint)", group=GRP_TBL,
     tooltip="Applies only to timeframes above the chart. A timeframe equal to the chart uses the current bar, which is already complete at the close.")
tblPos     = input.string("Top Right", "Regime table position", options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=GRP_TBL)
tblSize    = input.string("Small", "Table text size",   options=["Tiny","Small","Normal","Large","Huge"], group=GRP_TBL)
hdrSize    = input.string("Small", "Table header size", options=["Tiny","Small","Normal","Large","Huge"], group=GRP_TBL)
lblSizeIn  = input.string("Small", "IB / OB label size", options=["Tiny","Small","Normal","Large","Huge"], group=GRP_TBL)
arrSizeIn  = input.string("Small", "Break arrow size",   options=["Tiny","Small","Normal","Large","Huge"], group=GRP_TBL)
lvlSizeIn  = input.string("Tiny",  "Level price label size", options=["Tiny","Small","Normal","Large","Huge"], group=GRP_TBL)
tblBg      = input.color(color.new(color.black, 20), "Table background", group=GRP_TBL)
showBrand  = input.bool(true, "Show author attribution in table", group=GRP_TBL)

showTable2 = input.bool(false, "Show setup table", group=GRP_TB2, tooltip="Status, distance to trigger, inside-bar context, volume, structural targets and relative strength. Off by default to keep the chart clean.")
tbl2Pos    = input.string("Bottom Right", "Setup table position", options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=GRP_TB2)

// ============================== Helpers =============================
f_sz(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small

f_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left" ? position.bottom_left :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left" ? position.middle_left : position.top_right

f_del(line l) =>
    if not na(l)
        line.delete(l)

f_ext(line l) =>
    if not na(l)
        line.set_x2(l, bar_index + 1)

f_fmt(float v) => na(v) ? "—" : str.tostring(v, format.mintick)
f_x(float v)   => na(v) ? "—" : str.tostring(v, "#.##") + "x"
f_pct(float v) => na(v) ? "—" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

colSilver = color.new(color.silver, 0)
colGray   = color.new(color.gray, 0)
f_dirCol(int v) => v == 1 ? color.new(color.green, 0) : v == -1 ? color.new(color.red, 0) : colGray
f_sgnCol(float v) => na(v) ? colGray : v > 0 ? color.new(color.green, 0) : v < 0 ? color.new(color.red, 0) : colGray

// ========================= Bollinger Bands ==========================
basis = ta.sma(src, length)
dev   = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

plot(showBB ? basis : na, "Basis", color=color.new(color.red, 10), linewidth=2)
p1 = plot(showBB ? upper : na, "Upper", color=color.new(color.teal, 10), linewidth=2)
p2 = plot(showBB ? lower : na, "Lower", color=color.new(color.teal, 10), linewidth=2)
fill(p1, p2, title="BB Background", color=color.new(#198787, 95))

// ==================== Chart-timeframe classification ================
// One equality rule everywhere: with tieAsInside on, a side must be exceeded
// to count as broken; with it off, equalling the prior high/low is a break.
brokeUp   = tieAsInside ? high > high[1] : high >= high[1]
brokeDown = tieAsInside ? low  < low[1]  : low  <= low[1]

inBar   = not brokeUp and not brokeDown
outBar  = brokeUp and brokeDown
scChart = outBar ? 3 : brokeUp ? 2 : brokeDown ? -2 : 1

confirmed = not confirmOnly or barstate.isconfirmed
showIn    = inBar  and confirmed
showOut   = outBar and confirmed
holyGrail = outBar[1] and inBar and confirmed

barcolor(showIn ? ibCol : showOut ? obCol : na, title="Inside / Outside Bar")
bgcolor(holyGrail ? hgCol : na, offset=-1, title="3-1 - Outside Bar")
bgcolor(holyGrail ? hgCol : na,            title="3-1 - Inside Bar")

// ============================ Volume context ========================
volOk  = useVol and not na(volume)
volAvg = ta.sma(volume, volLen)[1]
// Live bars carry partial volume; project by session fraction elapsed so an
// 11am reading is not compared against full-day averages.
sessFrac = barstate.isrealtime and not barstate.isconfirmed and not na(time_close) and time_close > time ?
     math.max((timenow - time) / (time_close - time), 0.05) : 1.0
volRatio = volOk and volAvg > 0 ? volume / volAvg / sessFrac : na
volProj  = volOk and sessFrac < 1.0
f_tier(float r) => na(r) ? "—" : r >= volClimax ? "Climax" : r >= volHi ? "High" : r < 0.7 ? "Low" : "Normal"
f_tierCol(float r) => na(r) ? colGray : r >= volClimax ? color.new(color.orange, 0) : r >= volHi ? color.new(color.green, 0) : r < 0.7 ? color.new(color.blue, 0) : colSilver
volTxt = showVolMarks and not na(volRatio) ? " " + str.tostring(volRatio, "#.#") + "x" + (volProj ? "p" : "") : ""

if showLabels and showIn
    label.new(bar_index, na, text="IB" + volTxt, yloc=yloc.abovebar, style=label.style_label_down,
         color=ibCol, textcolor=ibTxtCol, size=f_sz(lblSizeIn))
if showLabels and showOut
    label.new(bar_index, na, text="OB" + volTxt, yloc=yloc.belowbar, style=label.style_label_up,
         color=obCol, textcolor=obTxtCol, size=f_sz(lblSizeIn))

// ======================= MTF state calculation ======================
// Scenario: 1 = inside, 2 = 2u, -2 = 2d, 3 = outside
// Color:    1 = green, -1 = red, 0 = flat
// In Force: 1 = close > prior high, -1 = close < prior low, 0 = equilibrium
f_state(simple bool useClosed, simple bool tieIn) =>
    bU  = tieIn ? high > high[1] : high >= high[1]
    bD  = tieIn ? low  < low[1]  : low  <= low[1]
    sc  = bU and bD ? 3 : bU ? 2 : bD ? -2 : 1
    cl  = close > open ? 1 : close < open ? -1 : 0
    inf = close > high[1] ? 1 : close < low[1] ? -1 : 0
    [useClosed ? sc[1] : sc, useClosed ? cl[1] : cl, useClosed ? inf[1] : inf]

chartSec = timeframe.in_seconds()
sec1 = timeframe.in_seconds(tf1)
sec2 = timeframe.in_seconds(tf2)
sec3 = timeframe.in_seconds(tf3)
sec4 = timeframe.in_seconds(tf4)

// A timeframe below the chart cannot be read from chart bars — it is shown as n/a
// and excluded from the aggregates. The closed-bar offset applies only ABOVE the chart.
mV = sec1 >= chartSec
wV = sec2 >= chartSec
dV = sec3 >= chartSec
hV = sec4 >= chartSec
mOff = htfConfirm and sec1 > chartSec
wOff = htfConfirm and sec2 > chartSec
dOff = htfConfirm and sec3 > chartSec
hOff = htfConfirm and sec4 > chartSec

[mSc0, mCl0, mIf0] = request.security(syminfo.tickerid, tf1, f_state(mOff, tieAsInside), lookahead=barmerge.lookahead_off)
[wSc0, wCl0, wIf0] = request.security(syminfo.tickerid, tf2, f_state(wOff, tieAsInside), lookahead=barmerge.lookahead_off)
[dSc0, dCl0, dIf0] = request.security(syminfo.tickerid, tf3, f_state(dOff, tieAsInside), lookahead=barmerge.lookahead_off)
[hSc0, hCl0, hIf0] = request.security(syminfo.tickerid, tf4, f_state(hOff, tieAsInside), lookahead=barmerge.lookahead_off)

mSc = mV ? mSc0 : 1, mCl = mV ? mCl0 : 0, mIf = mV ? mIf0 : 0
wSc = wV ? wSc0 : 1, wCl = wV ? wCl0 : 0, wIf = wV ? wIf0 : 0
dSc = dV ? dSc0 : 1, dCl = dV ? dCl0 : 0, dIf = dV ? dIf0 : 0
hSc = hV ? hSc0 : 1, hCl = hV ? hCl0 : 0, hIf = hV ? hIf0 : 0

// Prior completed bar of timeframe 2 (weekly by default) as the higher-TF structural level
htfHi0 = request.security(syminfo.tickerid, tf2, high[1], lookahead=barmerge.lookahead_off)
htfLo0 = request.security(syminfo.tickerid, tf2, low[1],  lookahead=barmerge.lookahead_off)
htfHi  = sec2 > chartSec ? htfHi0 : na
htfLo  = sec2 > chartSec ? htfLo0 : na

// ATR from the chosen timeframe (or the chart timeframe if that is higher),
// always the last CLOSED bar so it never repaints
atrTFeff = timeframe.in_seconds(atrTF) < chartSec ? timeframe.period : atrTF
atrVal   = request.security(syminfo.tickerid, atrTFeff, ta.sma(ta.tr(true), atrLen)[1], lookahead=barmerge.lookahead_off)
refClose = request.security(syminfo.tickerid, atrTFeff, close[1], lookahead=barmerge.lookahead_off)
atrPct   = refClose > 0 ? atrVal / refClose * 100 : na

f_scTxt(int s)  => s == 3 ? "3" : s == 2 ? "2u" : s == -2 ? "2d" : "1"
f_clTxt(int c)  => c == 1 ? "Green" : c == -1 ? "Red" : "Flat"
f_ifTxt(int i)  => i == 1 ? "Bull IF" : i == -1 ? "Bear IF" : "Equil"

// ---------------- Regime grade (actual and conditional) ----------------
f_grade(int mS, int wS, int dS, int hS, int mC, int wC, int dC, int hC, int mI, int wI, int dI, int hI, bool mV_, bool wV_, bool dV_, bool hV_) =>
    nV    = (mV_ ? 1 : 0) + (wV_ ? 1 : 0) + (dV_ ? 1 : 0) + (hV_ ? 1 : 0)
    bullC = (mC == 1 ? 1 : 0) + (wC == 1 ? 1 : 0) + (dC == 1 ? 1 : 0) + (hC == 1 ? 1 : 0)
    bearC = (mC == -1 ? 1 : 0) + (wC == -1 ? 1 : 0) + (dC == -1 ? 1 : 0) + (hC == -1 ? 1 : 0)
    bullI = (mI == 1 ? 1 : 0) + (wI == 1 ? 1 : 0) + (dI == 1 ? 1 : 0) + (hI == 1 ? 1 : 0)
    bearI = (mI == -1 ? 1 : 0) + (wI == -1 ? 1 : 0) + (dI == -1 ? 1 : 0) + (hI == -1 ? 1 : 0)
    ftfcD = nV > 0 and bullC == nV ? 1 : nV > 0 and bearC == nV ? -1 : 0
    ifD   = nV > 0 and bullI == nV ? 1 : nV > 0 and bearI == nV ? -1 : 0
    htfBull = (mV_ or wV_) and (not mV_ or mC == 1) and (not wV_ or wC == 1)
    htfBear = (mV_ or wV_) and (not mV_ or mC == -1) and (not wV_ or wC == -1)
    mwOpp   = mV_ and wV_ and ((mC == 1 and wC == -1) or (mC == -1 and wC == 1))
    string g = "D — Conflicted"
    int    a = 0
    if ftfcD != 0 and ifD == ftfcD
        g := (ftfcD == 1 ? "A-bullish" : "A-bearish") + " — Full alignment"
        a := ftfcD
    else if ftfcD != 0
        g := (ftfcD == 1 ? "B-bullish" : "B-bearish") + " — Awaiting commitment"
        a := ftfcD
    else if nV >= 3 and bullC == nV - 1 and htfBull
        g := "C-bullish — Partial"
        a := 1
    else if nV >= 3 and bearC == nV - 1 and htfBear
        g := "C-bearish — Partial"
        a := -1
    sb = (dV_ and dS == 1) or mwOpp
    [sb ? "N — Standby / chop" : g, sb ? 0 : a, a, sb, ftfcD, ifD, bullC, bearC, bullI, bearI, nV]

[gradeOut, gradeDir, alignDir, standby, ftfcDir, ifDir, bullColors, bearColors, bullIF, bearIF, nValid] =
     f_grade(mSc, wSc, dSc, hSc, mCl, wCl, dCl, hCl, mIf, wIf, dIf, hIf, mV, wV, dV, hV)

ftfcTxt = ftfcDir == 1 ? "Bullish " + str.tostring(nValid) + "/" + str.tostring(nValid) :
     ftfcDir == -1 ? "Bearish " + str.tostring(nValid) + "/" + str.tostring(nValid) :
     "Mixed  " + str.tostring(bullColors) + "G " + str.tostring(bearColors) + "R"
ifTxt = ifDir == 1 ? "Bullish " + str.tostring(nValid) + "/" + str.tostring(nValid) :
     ifDir == -1 ? "Bearish " + str.tostring(nValid) + "/" + str.tostring(nValid) :
     str.tostring(bullIF) + " bull / " + str.tostring(bearIF) + " bear / " + str.tostring(nValid - bullIF - bearIF) + " eq"

// Conditional grade: what the regime becomes if the chart-timeframe bar breaks
// up or down. Only meaningful when the chart timeframe is one of the table rows.
chartRow = sec1 == chartSec ? 1 : sec2 == chartSec ? 2 : sec3 == chartSec ? 3 : sec4 == chartSec ? 4 : 0
f_sub(int rowIdx, int cur, int val) => chartRow == rowIdx ? val : cur

[gUp, gUpDir, _a1, _s1, _f1, _i1, _b1, _c1, _d1, _e1, _n1] = f_grade(
     f_sub(1, mSc, 2), f_sub(2, wSc, 2), f_sub(3, dSc, 2), f_sub(4, hSc, 2),
     f_sub(1, mCl, 1), f_sub(2, wCl, 1), f_sub(3, dCl, 1), f_sub(4, hCl, 1),
     f_sub(1, mIf, 1), f_sub(2, wIf, 1), f_sub(3, dIf, 1), f_sub(4, hIf, 1), mV, wV, dV, hV)
[gDn, gDnDir, _a2, _s2, _f2, _i2, _b2, _c2, _d2, _e2, _n2] = f_grade(
     f_sub(1, mSc, -2), f_sub(2, wSc, -2), f_sub(3, dSc, -2), f_sub(4, hSc, -2),
     f_sub(1, mCl, -1), f_sub(2, wCl, -1), f_sub(3, dCl, -1), f_sub(4, hCl, -1),
     f_sub(1, mIf, -1), f_sub(2, wIf, -1), f_sub(3, dIf, -1), f_sub(4, hIf, -1), mV, wV, dV, hV)

// ======================= Relative strength ==========================
rsOn   = useRS and benchSym != syminfo.tickerid
bClose = request.security(benchSym, timeframe.period, close, lookahead=barmerge.lookahead_off)
[bSc, bCl, bIf] = request.security(benchSym, timeframe.period, f_state(false, tieAsInside), lookahead=barmerge.lookahead_off)
f_rs(int n) =>
    rsOn and not na(bClose) and close[n] > 0 and bClose[n] > 0 ? ((close / close[n]) / (bClose / bClose[n]) - 1) * 100 : na
rs1 = f_rs(rsLen1)
rs2 = f_rs(rsLen2)
benchName = rsOn ? str.replace(benchSym, ":", " ") : ""

// ============================ Prior pivots ==========================
var pivHiArr = array.new_float()
var pivLoArr = array.new_float()
ph = ta.pivothigh(high, pivL, pivR)
pl = ta.pivotlow(low, pivL, pivR)
if usePiv and not na(ph)
    array.unshift(pivHiArr, ph)
    if array.size(pivHiArr) > 12
        array.pop(pivHiArr)
if usePiv and not na(pl)
    array.unshift(pivLoArr, pl)
    if array.size(pivLoArr) > 12
        array.pop(pivLoArr)

f_nearAbove(array<float> arr, float ref) =>
    float best = na
    if array.size(arr) > 0 and not na(ref)
        for i = 0 to array.size(arr) - 1
            v = array.get(arr, i)
            if v > ref and (na(best) or v < best)
                best := v
    best
f_nearBelow(array<float> arr, float ref) =>
    float best = na
    if array.size(arr) > 0 and not na(ref)
        for i = 0 to array.size(arr) - 1
            v = array.get(arr, i)
            if v < ref and (na(best) or v > best)
                best := v
    best

// ================= Trigger levels, stops, targets, state =============
// Setup state: 0 none, 1 watching, 2 active (broken), 3 finished
var float trigHi    = na
var float trigLo    = na
var float atrSnap   = na      // ATR frozen at the signal bar — a stop that drifts is not a stop
var float stopLong  = na
var float stopShort = na
var float riskLong  = na
var float riskShort = na
var float riskATR   = na
var int   state     = 0
var string statusTxt = "none"
var int   tradeDir  = 0
var int   barsSince = 0
var int   tHit      = 0
var float entryPx   = na
var float stopPx    = na
var float riskPx    = na
var int   ibPrevSc  = 0
var int   ibCount   = 0
var bool  trigIsHG  = false
var float ibVol     = na
var float ibPrevVol = na
var float brkVol    = na
var float brkRange  = na
var float brkLoc    = na
var string brkBench = "—"
var bool  brk13     = false
var float structC   = na
var float structH   = na

var line lnHi = na, var line lnLo = na
var line lnStopL = na, var line lnStopS = na
var line lnT1 = na, var line lnT2 = na, var line lnT3 = na
var line lnStruct = na

f_level(float y, color c, int w, string st) =>
    line.new(bar_index, y, bar_index + 1, y, color=c, width=w,
         style=st == "dashed" ? line.style_dashed : st == "dotted" ? line.style_dotted : line.style_solid)

// --- provisional stop maths for the bar being evaluated ---
pStopL = stopMode == "ATR from trigger" ? high - atrMult * atrVal : low  - bufferMult * atrVal
pStopS = stopMode == "ATR from trigger" ? low  + atrMult * atrVal : high + bufferMult * atrVal
pRiskL = high - pStopL
pRiskS = pStopS - low
pRiskATR = atrVal > 0 ? math.max(pRiskL, pRiskS) / atrVal : na

riskOk     = not useRiskFilter or (not na(pRiskATR) and pRiskATR <= maxRiskATR)
keepAnchor = anchorMode == "First inside bar in a run" and state == 1 and inBar[1]
newSetup   = showTrig and showIn and (not hgOnly or holyGrail) and riskOk and not na(atrVal) and not keepAnchor

if showIn and keepAnchor
    ibCount += 1

if newSetup
    // replace any setup still being watched
    f_del(lnHi), f_del(lnLo), f_del(lnStopL), f_del(lnStopS)
    trigHi    := high
    trigLo    := low
    atrSnap   := atrVal
    stopLong  := pStopL
    stopShort := pStopS
    riskLong  := pRiskL
    riskShort := pRiskS
    riskATR   := pRiskATR
    state     := 1
    statusTxt := (holyGrail ? "3-1" : "IB") + " watching"
    trigIsHG  := holyGrail
    tradeDir  := 0
    barsSince := 0
    tHit      := 0
    entryPx   := na
    stopPx    := na
    riskPx    := na
    ibPrevSc  := scChart[1]
    ibCount   := 1
    ibVol     := volRatio
    ibPrevVol := volRatio[1]
    brkVol    := na
    brkRange  := na
    brkLoc    := na
    brkBench  := "—"
    brk13     := false
    structC   := na
    structH   := na
    lnHi := f_level(trigHi, trigUpCol, holyGrail ? trigWidth + 1 : trigWidth, "solid")
    lnLo := f_level(trigLo, trigDnCol, holyGrail ? trigWidth + 1 : trigWidth, "solid")
    if showStops
        lnStopL := f_level(stopLong,  stopCol, 1, "dashed")
        lnStopS := f_level(stopShort, stopCol, 1, "dashed")
    if showPrices
        label.new(bar_index, trigHi, text="SL▲ " + f_fmt(stopLong) + "  SL▼ " + f_fmt(stopShort),
             style=label.style_label_left, color=color.new(color.black, 100), textcolor=stopCol, size=f_sz(lvlSizeIn))

// --- break detection: close-confirmed by default, wick optional ---
watching = state == 1 and not newSetup
brkUpRaw = watching and (breakMode == "Close" ? close > trigHi : high > trigHi)
brkDnRaw = watching and (breakMode == "Close" ? close < trigLo : low  < trigLo)
evalOk   = breakMode == "Close" ? barstate.isconfirmed : true
// Both sides in one bar (a 1-3): resolve by the close, or stay watching if it closed inside
brkDir = not evalOk ? 0 :
     brkUpRaw and brkDnRaw ? (close > trigHi ? 1 : close < trigLo ? -1 : 0) :
     brkUpRaw ? 1 : brkDnRaw ? -1 : 0
brokeTrigUp = brkDir == 1
brokeTrigDn = brkDir == -1
brkEvent    = brkDir != 0

if watching
    f_ext(lnHi), f_ext(lnLo)
    if showStops
        f_ext(lnStopL), f_ext(lnStopS)
    if brkUpRaw and brkDnRaw and brkDir == 0
        statusTxt := "1-3 closed inside — watching"
    if brkEvent
        state     := 2
        tradeDir  := brkDir
        barsSince := 0
        tHit      := 0
        brk13     := brkUpRaw and brkDnRaw
        entryPx   := brkDir == 1 ? trigHi : trigLo
        stopPx    := brkDir == 1 ? stopLong : stopShort
        riskPx    := brkDir == 1 ? riskLong : riskShort
        brkVol    := volRatio
        brkRange  := atrSnap > 0 ? (high - low) / atrSnap : na
        brkLoc    := high > low ? (close - low) / (high - low) * 100 : na
        brkBench  := rsOn ? f_scTxt(bSc) + " " + f_clTxt(bCl) + (bSc == 1 ? " (alone)" : "") : "—"
        statusTxt := (brkDir == 1 ? "LONG" : "SHORT") + " active" + (brk13 ? " (1-3)" : "")
        if showStops
            keep = brkDir == 1 ? lnStopL : lnStopS
            drop = brkDir == 1 ? lnStopS : lnStopL
            f_del(drop)
            if not na(keep)
                line.set_style(keep, line.style_solid)
                line.set_width(keep, 2)
        if showTargets
            sgn = brkDir
            lnT1 := f_level(entryPx + sgn * t1R * riskPx, tgtCol, 1, "dotted")
            lnT2 := f_level(entryPx + sgn * t2R * riskPx, tgtCol, 1, "dotted")
            lnT3 := f_level(entryPx + sgn * t3R * riskPx, tgtCol, 1, "dotted")
            if showPrices
                label.new(bar_index, entryPx + sgn * t3R * riskPx,
                     text=str.tostring(t1R, "#.#") + "R " + f_fmt(entryPx + sgn * t1R * riskPx) + "  " +
                          str.tostring(t2R, "#.#") + "R " + f_fmt(entryPx + sgn * t2R * riskPx) + "  " +
                          str.tostring(t3R, "#.#") + "R " + f_fmt(entryPx + sgn * t3R * riskPx),
                     style=label.style_label_left, color=color.new(color.black, 100), textcolor=tgtCol, size=f_sz(lvlSizeIn))
        if usePiv
            structC := brkDir == 1 ? f_nearAbove(pivHiArr, entryPx) : f_nearBelow(pivLoArr, entryPx)
            structH := brkDir == 1 ? (htfHi > entryPx ? htfHi : na) : (htfLo < entryPx ? htfLo : na)
            if not na(structC)
                lnStruct := f_level(structC, structCol, 1, "solid")

// --- active setup: stop, targets, failure, expiry ---
evStop = false
evFail = false
evT1   = false
if state == 2 and not brkEvent
    barsSince += 1
    isLong = tradeDir == 1
    stopHit = isLong ? low <= stopPx : high >= stopPx
    if stopHit
        evStop    := true
        state     := 3
        statusTxt := "Stopped" + (tHit > 0 ? " after T" + str.tostring(tHit) : "")
    else
        newHit = tHit
        if showTargets
            if tHit < 3 and (isLong ? high >= entryPx + t3R * riskPx : low <= entryPx - t3R * riskPx)
                newHit := 3
            else if tHit < 2 and (isLong ? high >= entryPx + t2R * riskPx : low <= entryPx - t2R * riskPx)
                newHit := 2
            else if tHit < 1 and (isLong ? high >= entryPx + t1R * riskPx : low <= entryPx - t1R * riskPx)
                newHit := 1
        if newHit > tHit
            evT1 := tHit < 1
            tHit := newHit
            statusTxt := (isLong ? "LONG" : "SHORT") + " · T" + str.tostring(tHit) + " hit"
        failed = tHit == 0 and barstate.isconfirmed and (isLong ? close < trigHi : close > trigLo)
        if failed
            evFail    := true
            state     := 3
            statusTxt := "FAILED — closed back inside range"
        else if tHit >= 3
            state     := 3
            statusTxt := (isLong ? "LONG" : "SHORT") + " · T3 hit · done"
        else if barsSince >= extendBars
            state     := 3
            statusTxt := (isLong ? "LONG" : "SHORT") + " · expired" + (tHit > 0 ? " after T" + str.tostring(tHit) : "")
    if showStops
        f_ext(tradeDir == 1 ? lnStopL : lnStopS)
    if showTargets
        f_ext(lnT1), f_ext(lnT2), f_ext(lnT3)
    f_ext(lnStruct)

if brokeTrigUp and confirmed
    label.new(bar_index, na, text=showVolMarks and not na(brkVol) ? str.tostring(brkVol, "#.#") + "x" : "",
         yloc=yloc.belowbar, style=label.style_triangleup, color=trigUpCol, textcolor=trigUpCol, size=f_sz(arrSizeIn))
if brokeTrigDn and confirmed
    label.new(bar_index, na, text=showVolMarks and not na(brkVol) ? str.tostring(brkVol, "#.#") + "x" : "",
         yloc=yloc.abovebar, style=label.style_triangledown, color=trigDnCol, textcolor=trigDnCol, size=f_sz(arrSizeIn))

// position sizing and live readouts
sizeLong  = state == 1 and riskLong  > 0 ? math.floor(riskAmt / riskLong)  : na
sizeShort = state == 1 and riskShort > 0 ? math.floor(riskAmt / riskShort) : na
sizeTaken = state >= 2 and riskPx > 0 ? math.floor(riskAmt / riskPx) : na
rSoFar    = state >= 2 and riskPx > 0 ? tradeDir * (close - entryPx) / riskPx : na

distUpATR = state == 1 and atrSnap > 0 ? (trigHi - close) / atrSnap : na
distDnATR = state == 1 and atrSnap > 0 ? (close - trigLo) / atrSnap : na
distUpPct = state == 1 and close > 0 ? (trigHi - close) / close * 100 : na
distDnPct = state == 1 and close > 0 ? (close - trigLo) / close * 100 : na

// structural targets both ways while watching, in the trade direction once active
sUpC = state == 1 ? f_nearAbove(pivHiArr, trigHi) : state >= 2 and tradeDir == 1 ? structC : na
sDnC = state == 1 ? f_nearBelow(pivLoArr, trigLo) : state >= 2 and tradeDir == -1 ? structC : na
sUpH = state == 1 ? (htfHi > trigHi ? htfHi : na) : state >= 2 and tradeDir == 1 ? structH : na
sDnH = state == 1 ? (htfLo < trigLo ? htfLo : na) : state >= 2 and tradeDir == -1 ? structH : na
rUpC = state == 1 ? (sUpC - trigHi) / riskLong : (sUpC - entryPx) / riskPx
rDnC = state == 1 ? (trigLo - sDnC) / riskShort : (entryPx - sDnC) / riskPx
rUpH = state == 1 ? (sUpH - trigHi) / riskLong : (sUpH - entryPx) / riskPx
rDnH = state == 1 ? (trigLo - sDnH) / riskShort : (entryPx - sDnH) / riskPx
f_minR(float a, float b) => na(a) ? b : na(b) ? a : math.min(a, b)
nearUpR = f_minR(rUpC, rUpH)
nearDnR = f_minR(rDnC, rDnH)
f_structTxt(float lvl, float r) => na(lvl) ? "none" : f_fmt(lvl) + " · " + str.tostring(r, "#.#") + "R"
f_structCol(float r) => na(r) ? colGray : r < minStructR ? color.new(color.red, 0) : color.new(color.green, 0)

// IB context: what preceded the inside bar decides what each break means
ctxTxt = ibPrevSc == -2 ? "after 2d" : ibPrevSc == 2 ? "after 2u" : ibPrevSc == 3 ? "after 3 (3-1)" : ibPrevSc == 1 ? "after 1 (run)" : "—"
ctxUp  = ibPrevSc == -2 ? "↑ 2-1-2 reversal" : ibPrevSc == 2 ? "↑ continuation" : ibPrevSc == 3 ? "↑ expansion resolves up" : ibPrevSc == 1 ? "↑ range break" : "—"
ctxDn  = ibPrevSc == 2 ? "↓ 2-1-2 reversal" : ibPrevSc == -2 ? "↓ continuation" : ibPrevSc == 3 ? "↓ expansion resolves down" : ibPrevSc == 1 ? "↓ range break" : "—"

// ============================= Tables ===============================
var table t  = table.new(f_pos(tblPos),  4, 14, border_width=1, frame_width=1, frame_color=color.new(color.gray, 50), bgcolor=tblBg)
var table t2 = table.new(f_pos(tbl2Pos), 4, 10, border_width=1, frame_width=1, frame_color=color.new(color.gray, 50), bgcolor=tblBg)

f_hdr(table tb, int c, int r, string txt) =>
    table.cell(tb, c, r, txt, text_color=colSilver, text_size=f_sz(hdrSize))
f_val(table tb, int c, int r, string txt, color col) =>
    table.cell(tb, c, r, txt, text_color=col, text_size=f_sz(tblSize))
f_row(int r, string tf, int sc, int cl, int inf, bool ok, bool isChart) =>
    f_val(t, 0, r, tf + (isChart ? " ◄" : ""), isChart ? color.new(color.yellow, 0) : colSilver)
    if ok
        f_val(t, 1, r, f_scTxt(sc), sc == 3 ? color.new(color.orange, 0) : sc == 1 ? colGray : f_dirCol(sc > 0 ? 1 : -1))
        f_val(t, 2, r, f_clTxt(cl), f_dirCol(cl))
        f_val(t, 3, r, f_ifTxt(inf), f_dirCol(inf))
    else
        f_val(t, 1, r, "n/a", colGray), f_val(t, 2, r, "below chart", colGray), f_val(t, 3, r, "", colGray)

if showTable and barstate.islast
    f_hdr(t, 0, 0, "TF"), f_hdr(t, 1, 0, "Scenario"), f_hdr(t, 2, 0, "Color"), f_hdr(t, 3, 0, "In Force")
    f_row(1, tf1, mSc, mCl, mIf, mV, chartRow == 1)
    f_row(2, tf2, wSc, wCl, wIf, wV, chartRow == 2)
    f_row(3, tf3, dSc, dCl, dIf, dV, chartRow == 3)
    f_row(4, tf4, hSc, hCl, hIf, hV, chartRow == 4)

    f_hdr(t, 0, 5, "FTFC")
    f_val(t, 1, 5, ftfcTxt, f_dirCol(ftfcDir))
    f_hdr(t, 2, 5, "MTF IF")
    f_val(t, 3, 5, ifTxt, f_dirCol(ifDir))

    f_hdr(t, 0, 6, "Regime")
    f_val(t, 1, 6, gradeOut, standby ? colGray : f_dirCol(gradeDir))
    f_hdr(t, 2, 6, "Leaning")
    f_val(t, 3, 6, alignDir == 1 ? "Bullish" : alignDir == -1 ? "Bearish" : "None", f_dirCol(alignDir))

    f_hdr(t, 0, 7, "If break")
    f_val(t, 1, 7, chartRow == 0 ? "chart TF not in table" : "↑ " + gUp, chartRow == 0 ? colGray : f_dirCol(gUpDir))
    f_val(t, 2, 7, chartRow == 0 ? "" : "↓ " + gDn, f_dirCol(gDnDir))
    f_val(t, 3, 7, "", colSilver)

    f_hdr(t, 0, 8, "Trigger")
    f_val(t, 1, 8, state == 1 ? f_fmt(trigHi) : state >= 2 ? f_fmt(entryPx) : "—", state >= 2 ? (tradeDir == 1 ? trigUpCol : trigDnCol) : trigUpCol)
    f_val(t, 2, 8, state == 1 ? f_fmt(trigLo) : "—", trigDnCol)
    f_val(t, 3, 8, statusTxt, state == 2 ? f_dirCol(tradeDir) : colSilver)

    f_hdr(t, 0, 9, "Stop")
    f_val(t, 1, 9, state == 1 ? f_fmt(stopLong)  : state >= 2 ? f_fmt(stopPx) : "—", stopCol)
    f_val(t, 2, 9, state == 1 ? f_fmt(stopShort) : "—", stopCol)
    f_val(t, 3, 9, stopMode == "ATR from trigger" ? "ATR stop" : "Structural", colSilver)

    f_hdr(t, 0, 10, "Risk/sh")
    f_val(t, 1, 10, state == 1 ? f_fmt(riskLong)  : state >= 2 ? f_fmt(riskPx) : "—", colSilver)
    f_val(t, 2, 10, state == 1 ? f_fmt(riskShort) : "—", colSilver)
    f_val(t, 3, 10, state >= 1 and not na(riskATR) ? str.tostring(riskATR, "#.##") + "x ATR" : "—",
         not na(riskATR) and riskATR > maxRiskATR ? color.new(color.red, 0) : color.new(color.green, 0))

    f_hdr(t, 0, 11, "Size")
    f_val(t, 1, 11, state == 1 ? (na(sizeLong) ? "—" : str.tostring(sizeLong)) : state >= 2 ? (na(sizeTaken) ? "—" : str.tostring(sizeTaken)) : "—",
         state >= 2 ? f_dirCol(tradeDir) : trigUpCol)
    f_val(t, 2, 11, state == 1 ? (na(sizeShort) ? "—" : str.tostring(sizeShort)) : "—", trigDnCol)
    f_val(t, 3, 11, "@ " + str.tostring(riskAmt, "#") + " risk", colSilver)

    f_hdr(t, 0, 12, "ATR " + str.tostring(atrLen) + " " + atrTFeff)
    f_val(t, 1, 12, f_fmt(atrVal), colSilver)
    f_val(t, 2, 12, na(atrPct) ? "—" : str.tostring(atrPct, "#.##") + "%", colSilver)
    f_val(t, 3, 12, breakMode == "Close" ? "Break: close" : "Break: wick", colSilver)

    f_hdr(t, 0, 13, htfConfirm ? "HTF: closed bars" : "HTF: LIVE bars")
    f_hdr(t, 1, 13, ""), f_hdr(t, 2, 13, "")
    f_hdr(t, 3, 13, showBrand ? "Sreeni @t2make" : "")

if showTable2 and barstate.islast
    f_hdr(t2, 0, 0, "Setup"), f_hdr(t2, 1, 0, "Up / Long"), f_hdr(t2, 2, 0, "Down / Short"), f_hdr(t2, 3, 0, "Read")

    f_hdr(t2, 0, 1, "Status")
    f_val(t2, 1, 1, statusTxt, state == 2 ? f_dirCol(tradeDir) : colSilver)
    f_val(t2, 2, 1, state >= 2 ? str.tostring(barsSince) + " bars" : state == 1 ? str.tostring(ibCount) + (ibCount > 1 ? " IBs" : " IB") : "", colSilver)
    f_val(t2, 3, 1, state >= 2 and not na(rSoFar) ? (rSoFar >= 0 ? "+" : "") + str.tostring(rSoFar, "#.##") + "R" : "", f_sgnCol(rSoFar))

    f_hdr(t2, 0, 2, "To trigger")
    f_val(t2, 1, 2, state == 1 ? f_x(distUpATR) + " ATR · " + f_pct(distUpPct) : "—", trigUpCol)
    f_val(t2, 2, 2, state == 1 ? f_x(distDnATR) + " ATR · " + f_pct(distDnPct) : "—", trigDnCol)
    f_val(t2, 3, 2, state == 1 ? (distUpATR < distDnATR ? "nearer the high" : "nearer the low") : "", colSilver)

    f_hdr(t2, 0, 3, "IB context")
    f_val(t2, 1, 3, state >= 1 ? ctxUp : "—", state >= 1 ? f_dirCol(1) : colGray)
    f_val(t2, 2, 3, state >= 1 ? ctxDn : "—", state >= 1 ? f_dirCol(-1) : colGray)
    f_val(t2, 3, 3, state >= 1 ? ctxTxt : "", colSilver)

    f_hdr(t2, 0, 4, "Structure")
    f_val(t2, 1, 4, state >= 1 ? f_structTxt(sUpC, rUpC) + (na(sUpH) ? "" : " | " + tf2 + " " + f_structTxt(sUpH, rUpH)) : "—", f_structCol(nearUpR))
    f_val(t2, 2, 4, state >= 1 ? f_structTxt(sDnC, rDnC) + (na(sDnH) ? "" : " | " + tf2 + " " + f_structTxt(sDnH, rDnH)) : "—", f_structCol(nearDnR))
    f_val(t2, 3, 4, not usePiv ? "off" : (not na(nearUpR) and nearUpR < minStructR) or (not na(nearDnR) and nearDnR < minStructR) ? "into structure < " + str.tostring(minStructR, "#.#") + "R" : "room", colSilver)

    f_hdr(t2, 0, 5, "Volume")
    f_val(t2, 1, 5, not volOk ? "n/a" : "IB " + f_x(ibVol) + " " + f_tier(ibVol), f_tierCol(ibVol))
    f_val(t2, 2, 5, not volOk ? "" : "prior " + f_x(ibPrevVol) + " " + f_tier(ibPrevVol), f_tierCol(ibPrevVol))
    f_val(t2, 3, 5, not volOk ? "" : "now " + f_x(volRatio) + (volProj ? " proj" : "") + " " + f_tier(volRatio), f_tierCol(volRatio))

    f_hdr(t2, 0, 6, "Break bar")
    f_val(t2, 1, 6, state >= 2 ? "vol " + f_x(brkVol) + " " + f_tier(brkVol) : "—", f_tierCol(brkVol))
    f_val(t2, 2, 6, state >= 2 ? "range " + f_x(brkRange) + " ATR" : "—", not na(brkRange) and brkRange >= 1.0 ? color.new(color.green, 0) : colSilver)
    f_val(t2, 3, 6, state >= 2 and not na(brkLoc) ? "close at " + str.tostring(brkLoc, "#") + "% of bar" : "", colSilver)

    f_hdr(t2, 0, 7, "RS vs " + benchName)
    f_val(t2, 1, 7, rsOn ? str.tostring(rsLen1) + "b " + f_pct(rs1) : "off", f_sgnCol(rs1))
    f_val(t2, 2, 7, rsOn ? str.tostring(rsLen2) + "b " + f_pct(rs2) : "", f_sgnCol(rs2))
    f_val(t2, 3, 7, rsOn ? "bench now " + f_scTxt(bSc) + " " + f_clTxt(bCl) : "", f_dirCol(bCl))

    f_hdr(t2, 0, 8, "Bench at break")
    f_val(t2, 1, 8, state >= 2 ? brkBench : "—", colSilver)
    f_val(t2, 2, 8, "", colSilver)
    f_val(t2, 3, 8, state >= 2 and rsOn and str.contains(brkBench, "alone") ? "broke without the index" : "", color.new(color.green, 0))

    f_hdr(t2, 0, 9, "Anchor: " + (anchorMode == "Latest inside bar" ? "latest IB" : "first IB"))
    f_hdr(t2, 1, 9, "Pivots " + str.tostring(pivL) + "/" + str.tostring(pivR))
    f_hdr(t2, 2, 9, "Vol avg " + str.tostring(volLen))
    f_hdr(t2, 3, 9, "")

// ============================== Alerts ==============================
gatedUp = brokeTrigUp and (not gateAlert or alignDir == 1)  and (not rsGate or not rsOn or rs1 > 0)
gatedDn = brokeTrigDn and (not gateAlert or alignDir == -1) and (not rsGate or not rsOn or rs1 < 0)
volBreak = brkEvent and not na(brkVol) and brkVol >= volHi

alertcondition(showIn,    title="Inside Bar (1)",   message="{{ticker}} {{interval}}: inside bar formed")
alertcondition(showOut,   title="Outside Bar (3)",  message="{{ticker}} {{interval}}: outside bar formed")
alertcondition(holyGrail, title="3-1 pattern",      message="{{ticker}} {{interval}}: 3-1 formed")
alertcondition(gatedUp,   title="Trigger Break — Up",   message="{{ticker}} {{interval}}: inside-bar high taken out")
alertcondition(gatedDn,   title="Trigger Break — Down", message="{{ticker}} {{interval}}: inside-bar low taken out")
alertcondition(volBreak,  title="Break on elevated volume", message="{{ticker}} {{interval}}: trigger break on elevated volume")
alertcondition(evFail,    title="Failed break",     message="{{ticker}} {{interval}}: break failed — closed back inside the range")
alertcondition(evStop,    title="Stop hit",         message="{{ticker}} {{interval}}: stop level reached")
alertcondition(evT1,      title="Target 1 hit",     message="{{ticker}} {{interval}}: target 1 reached")

// Dynamic alert carrying the actual levels — choose "Any alert() function call" when creating it
if gatedUp or gatedDn
    alert(syminfo.ticker + " " + timeframe.period + (gatedUp ? " upside" : " downside") + " break " + f_fmt(entryPx) +
         " | stop " + f_fmt(stopPx) + " | risk/sh " + f_fmt(riskPx) +
         " | vol " + f_x(brkVol) + " | regime " + gradeOut +
         (rsOn ? " | RS" + str.tostring(rsLen1) + " " + f_pct(rs1) : ""), alert.freq_once_per_bar_close)
````
