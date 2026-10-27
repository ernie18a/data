# Strong ORB Matrix | ProjectSyndicate

- url: https://www.tradingview.com/script/EK0Xe69y-Strong-ORB-Matrix-ProjectSyndicate/
- type: indicator
- pine_id: PUB;90b7019194d84d46ac2893d76de2d8b4
- version: 1.0

## Description

▪️Strong ORB Matrix takes the one level every intraday trader watches, the opening range, and tells you how it has actually behaved. The first minutes of a session carve out a high and a low that the rest of the day trades around. "Breakout above the opening range" on its own is a guess. Some sessions break and run. Others poke through and fail straight back inside. This indicator stops treating those the same. It measures every session, scores every breakout as it happens, and shows you the range's own track record before you commit.

▪️The opening range becomes a shaded box with three extension targets stacked above and below it. When price closes beyond an edge, the engine opens a trade, follows it to a resolved outcome, and logs it: a third banked at each target, stop to breakeven after the first, a trail on the runner. Those outcomes become each signal type's win rate, average R, profit factor and target-reach ladder. The range's color and the level labels come from real history: how often each target has been reached, and how often it was reached when the first break went that way.

▪️Most opening-range tools draw a box and a couple of lines and stop there. This one counts, across every session it can see, which way the first break went, whether it held or failed, how wide the range was, and whether each extension target actually gets reached. All of it is written onto the levels and laid out in a five-panel dashboard.

🎯 The Breakout Classifier (the core). The moment price closes beyond the range edge, the engine asks which of three things is happening:

BRK — a clean first close beyond the edge. The classic opening-range breakout.
RTST — price broke out, pulled back to the edge, and closed back in the break direction. The retest held.
FAIL — a break that closed back inside the range by a set depth within a set window. The move is faded toward the opposite side.

Wicks don't trigger anything. Only a confirmed close opens a signal.

⭐ Strength Score (0–10). Every setup is graded before it fires on seven inputs: volume surge versus its baseline, where the bar closes in its range, how far price displaced past the edge in ATR, how narrow or wide the opening range is against its own history, higher-timeframe trend alignment, aggressive buy/sell delta, and which side of session VWAP price sits on. Narrow ranges score breakouts higher, wide ranges score fades higher. A setup below the minimum score is filtered out; a high-conviction score is drawn larger. The weights are all adjustable.

📊 The Level Matrix That Shows Its Record. Six levels sit in the dashboard, three above price and three below, split by a live PRICE row. Each extension target reports its unconditional hit rate across all tracked sessions and, next to it, its conditional hit rate on sessions whose first break went that way, because a target reached after an upside break is a different claim from one reached after a downside break. The range edges report their close-break rates. A gauge and a distance-in-ATR column make the read instant.

🔬 The Intrabar Delta Engine. Rather than guessing buying and selling from the chart bar alone, the engine reads lower-timeframe bars inside each chart bar and sums their real order flow, falling back to a modelled estimate only when intrabars aren't available. That flow feeds the strength score, the session buy/sell pressure gauge, and a two-tone opening-range volume profile with its point of control and value area marked.

🧪 Honest Trade Model. Entry is at the signal bar's close, where you could actually act, not at the range edge price has already left. A third is taken at each of three targets, the stop moves to breakeven after the first, and the last third trails. Stop gaps fill at the open. When a target bar also trades back through the stop, the remainder is booked at the stop, not the target, so the numbers never flatter themselves. Every closed trade is counted. Losers keep their marker on the chart. The analytics panel reports win rate, average R, profit factor, net R, max drawdown, expectancy, the exit mix (full stop, breakeven, final target, window end) and the current streak.

🔧 The Stop Optimizer. On every first break of each session, five ATR trailing-stop widths run in parallel, measured in ATR units so different stop distances compare fairly. The panel ranks them by net result and stars the best, alongside the live trail drawn on the chart. It answers one question with your market's own data: how tight should the stop be?

📈 Session Statistics. Booked only when a session's window closes, so today's half-finished session never inflates the rates: how often the first break goes up versus down, how often both sides break (the two-way chop days), how often the first break fails, the average delay from range completion to first break, the average range width, and the first-target reach rate on narrow ranges versus wide ones.

🏛️ Level Hierarchy. The range high and low are the anchors. Three extension targets on each side are set by multiplier or by Fibonacci (0.382 / 0.618 / 1.0 of the range). A dotted midline marks the equilibrium. Every level carries its own history rather than being lumped together.

🎨 Shaded Zones with Live Levels. The opening range is a filled box; the breakout zones above and below fade outward through the three targets. The session itself is shaded while the range builds. An optional bar-color mode tints candles by where they sit relative to the range. Level labels carry plain-English hit rates with no hover-only text.

🔒 DST-Aware Sessions. The range is built in a named timezone that follows daylight saving automatically, so a 09:30 New York range stays at 09:30 through the whole year. Any bar that overlaps the range window counts, so the range forms correctly on every intraday timeframe, and overnight sessions that cross midnight are handled.

🔔 Native Alerts. Long signal, short signal, high-conviction signal, retest signal, failed-breakout signal, close above or below the range, opening range complete, and each of the four extension targets reached. Every alert names the level and the event and carries the entry, stop and targets.

🎯 Why this is different. An opening-range box treats every session the same. This one grades each breakout as it forms, keeps the first-break direction's record apart from the raw one, shows how often each target is actually reached, proves which stop width pays with your market's data, and counts every trade honestly so the win rate is one you could have lived through.

🚀 Built to adapt. The session, timezone, range source, extension type and all thresholds are inputs, so it fits the New York cash open, the London open, index futures, FX or crypto, on any intraday chart.

💡 Cleanest setup: run the chart at 5m–15m so the range resolves exactly, set the session and timezone to your market's open, and leave the classifier on all three types. Use a chart timeframe no longer than the range itself; the dashboard warns you when it isn't.

🎯 How To Trade It: Two Approaches

Everything comes down to one question: when price leaves this opening range, does it tend to run or snap back, and is the setup in front of you strong enough to lean on?

⚡ 1) Trade the Breakout: continuation out of the range

Use this on a BRK or RTST signal in the break direction.

▪️Read the record. You want a score of ★★★ or more, a narrow-range session (breakouts carry best out of compression), higher-timeframe trend on your side, volume surging on the break, and a healthy first-target hit rate for that side in the matrix.

▪️Trigger: the confirmed BRK close, or the RTST close after the pullback holds the edge.
Target: the three extension levels, scaled out a third at a time.
Stop: the range mid or opposite edge, as set in the trade model.
Invalidation: a close back inside that turns the setup into a FAIL. The break gave way, so stand aside or look to fade.

🧱 2) Fade the Failure: the break that snaps back

Use this on a FAIL signal.

▪️Read the record. You want a wide-range session (overextended ranges fail more), a high historical failed-break rate in the statistics panel, and price rejecting from beyond the edge back inside.

▪️Trigger: the confirmed FAIL close back inside the range.
Target: the range mid, then the opposite edge, then the first extension on the far side.
Stop: beyond the failed break's extreme.
Watch: a reclaim of the broken edge. If price pushes back out, the fade is done.

✋ Stand down: when the dashboard says wait

A score below your minimum, or a setup filtered out by the counter-HTF or session-cap guard.
A session that has already broken both sides: it's a two-way chop day.
Too few tracked sessions to trust the hit rates, or the first-target rates roughly equal on both sides.
A timeframe warning in the panel: the range isn't resolving cleanly.
Price sitting inside the range with no break in progress: wait for the close and let the alert bring you in.

Rule of thumb: ⚡ Narrow range + high score + HTF aligned + strong first-target rate → trade the breakout, scale out at the extensions. 🧱 Wide range + high failed-break history + rejection back inside → fade the failure toward the mid and opposite edge. ❄️ Low score, both sides broken, thin sample or a timeframe warning → stand down until the session has shown its hand.

▪️Honest statistics. This is a measurement and analysis tool, not a signal service and not a promise that any range will break or hold. Every trade is counted, none are dropped for losing, stops gap against you at the open, and session rates exclude the live session so nothing is flattered. The probabilities are the historical frequencies of this range on this market in the sessions the indicator can see. They describe how the opening range has behaved, not how it must behave next. Outcomes are recorded on confirmed closes and a live trade can still change until its bar closes.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Strong ORB Matrix", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 2000)

//───────────────────────────────────────────────────────────────────────────────────────────────
// Inputs
//───────────────────────────────────────────────────────────────────────────────────────────────
gO = "═══ Opening Range ═══"
sessInput = input.session("0930-1000", "Opening Range Session", group = gO, tooltip = "Time block that forms the opening range. Format HHMM-HHMM in the timezone below.")
sessDays  = input.string("23456", "Days Of Week", group = gO, tooltip = "Digits of the days to build a range on. 1 = Sunday … 7 = Saturday. 23456 = Monday to Friday.")
tzInput   = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "America/Sao_Paulo", "Europe/London", "Europe/Berlin", "Europe/Moscow", "Asia/Dubai", "Asia/Kolkata", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Tokyo", "Australia/Sydney", "UTC", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC+1", "UTC+2", "UTC+3", "UTC+8", "UTC+9"], group = gO, tooltip = "Named zones (America/New_York …) follow daylight saving automatically. Fixed UTC offsets do not.")
srcInput  = input.string("High/Low", "Range Source", options = ["High/Low", "Body"], group = gO, tooltip = "High/Low uses wicks. Body uses the open/close extremes of each opening-range bar.")
endMode   = input.string("16:00 · Cash Close", "Session Window Ends", options = ["16:00 · Cash Close", "17:00 · Futures Close", "11:30 · London Close", "Manual Time", "23:59 · End Of Day", "Next OR · Unlimited"], group = gO, tooltip = "Levels are drawn, signals are taken and open trades are flattened inside this window. Times are in the timezone above.")
manualEnd = input.string("16:00", "Manual End (HH:MM)", group = gO)
breakBuf  = input.float(0.0, "Break Buffer (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gO, tooltip = "A close must clear the range edge by this ATR fraction to count as a break.")

gX = "═══ Extension Targets ═══"
extType = input.string("Multiples", "Extension Type", options = ["Multiples", "Fibonacci"], group = gX, tooltip = "Fibonacci = 0.382 / 0.618 / 1.0 of the range beyond each edge.")
mult1   = input.float(1.0, "Multiplier 1", minval = 0.05, step = 0.05, group = gX, inline = "m")
mult2   = input.float(2.0, "2", minval = 0.05, step = 0.05, group = gX, inline = "m")
mult3   = input.float(3.0, "3", minval = 0.05, step = 0.05, group = gX, inline = "m")

gB = "═══ Breakout Classifier ═══"
enBRK     = input.bool(true, "BRK", group = gB, inline = "ty")
enRTST    = input.bool(true, "RTST", group = gB, inline = "ty")
enFAIL    = input.bool(true, "FAIL", group = gB, inline = "ty")
confClose = input.bool(true, "Confirm On Bar Close (non-repaint)", group = gB)
maxBrkSd  = input.int(1, "BRK Signals / Side / Session", minval = 1, maxval = 5, group = gB, tooltip = "1 = classic ORB: only the first close-break on each side is a BRK signal. Re-breaks after a return inside are still tracked.")
maxSigDay = input.int(4, "Max Signals / Session", minval = 1, maxval = 20, group = gB)
retestWin = input.int(12, "RTST · Window (bars)", minval = 1, maxval = 200, group = gB, inline = "rt")
retestTol = input.float(0.15, "Tol (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gB, inline = "rt", tooltip = "The pullback must trade to within this distance of the broken edge, then close back beyond it with a candle in the breakout direction.")
failWin   = input.int(8, "FAIL · Window (bars)", minval = 1, maxval = 200, group = gB, inline = "fl")
failDepth = input.float(0.25, "Depth (× OR)", minval = 0.0, maxval = 1.0, step = 0.05, group = gB, inline = "fl", tooltip = "A break fails when price closes back inside the range by this share of its width within the window. The fade is signalled toward the opposite side.")
minScore  = input.float(4.0, "Min Signal Score", minval = 0.0, maxval = 10.0, step = 0.5, group = gB)
hiScore   = input.float(7.0, "High-Conviction Score", minval = 0.0, maxval = 10.0, step = 0.5, group = gB)
htfBlock  = input.bool(false, "Block Counter-HTF Signals", group = gB)
showWeak  = input.bool(false, "Mark Sub-Threshold Setups", group = gB)

gW = "═══ Score Weights ═══"
wVol   = input.float(1.2, "Volume Surge", minval = 0.0, maxval = 3.0, step = 0.1, group = gW, inline = "w1")
wBody  = input.float(1.0, "Close Location", minval = 0.0, maxval = 3.0, step = 0.1, group = gW, inline = "w1")
wDisp  = input.float(1.0, "Displacement", minval = 0.0, maxval = 3.0, step = 0.1, group = gW, inline = "w2")
wWidth = input.float(0.8, "OR Width Rank", minval = 0.0, maxval = 3.0, step = 0.1, group = gW, inline = "w2")
wHtf   = input.float(0.8, "HTF Alignment", minval = 0.0, maxval = 3.0, step = 0.1, group = gW, inline = "w3")
wDelta = input.float(1.0, "Bar Delta", minval = 0.0, maxval = 3.0, step = 0.1, group = gW, inline = "w3")
wVwap  = input.float(0.6, "VWAP Side", minval = 0.0, maxval = 3.0, step = 0.1, group = gW, inline = "w4")
hvMult = input.float(1.3, "HV ≥ (× avg vol)", minval = 1.0, maxval = 5.0, step = 0.1, group = gW, inline = "w4")

gC = "═══ Context ═══"
atrLen    = input.int(14, "ATR Length", minval = 1, maxval = 500, group = gC)
volLen    = input.int(20, "Volume Baseline", minval = 2, maxval = 500, group = gC)
dispRef   = input.float(0.6, "Displacement For Full Score (ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = gC)
htfTf     = input.timeframe("60", "HTF Bias Timeframe", group = gC, tooltip = "Read non-repainting from the last closed HTF bar.")
htfLen    = input.int(50, "HTF EMA Length", minval = 2, maxval = 500, group = gC)
widthLook = input.int(100, "OR Width Rank Lookback (sessions)", minval = 10, maxval = 500, group = gC, tooltip = "The session's OR width (as % of daily ATR) is ranked against this many prior sessions. Narrow ranges score higher for BRK/RTST, wide ranges for FAIL.")
deltaSrc  = input.string("Intrabar (auto fallback)", "Delta Source", options = ["Intrabar (auto fallback)", "Synthetic Only"], group = gC)
ltfDepth  = input.int(15, "Target Intrabars / Bar", minval = 2, maxval = 100, group = gC)
synthMdl  = input.string("Hybrid (CLV + Body)", "Delta Model", options = ["Hybrid (CLV + Body)", "Close Location (CLV)", "Body Ratio"], group = gC)

gT = "═══ Trade Model · Honest Stats ═══"
trackOn  = input.bool(true, "Track Signal Outcomes", group = gT, tooltip = "Entry at signal close. 1/3 scaled out at each TP. Gaps through the stop fill at the open. Same-bar ambiguity resolved against the trade. Every closed trade is counted.")
slMode   = input.string("OR Mid", "Stop Basis (BRK / RTST)", options = ["OR Opposite", "OR Mid", "ATR", "Signal Bar"], group = gT, tooltip = "FAIL fades always stop beyond the failed break's extreme.")
slAtr    = input.float(1.2, "ATR Stop Distance", minval = 0.1, maxval = 10.0, step = 0.1, group = gT, inline = "sl")
slBuf    = input.float(0.1, "Buffer (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = gT, inline = "sl")
minRisk  = input.float(0.3, "Risk Floor (ATR)", minval = 0.05, maxval = 5.0, step = 0.05, group = gT, inline = "rk")
maxRisk  = input.float(4.0, "Cap", minval = 0.2, maxval = 20.0, step = 0.1, group = gT, inline = "rk")
tpMode   = input.string("OR Extensions", "Targets", options = ["OR Extensions", "R Multiples"], group = gT, tooltip = "OR Extensions: BRK/RTST target T1/T2/T3; FAIL targets OR mid, opposite edge, opposite T1. A target that sits too close to entry falls back to its R multiple.")
tp1R     = input.float(1.0, "TP1 R", minval = 0.2, maxval = 20.0, step = 0.1, group = gT, inline = "tp")
tp2R     = input.float(2.0, "TP2 R", minval = 0.2, maxval = 30.0, step = 0.1, group = gT, inline = "tp")
tp3R     = input.float(3.0, "TP3 R", minval = 0.2, maxval = 50.0, step = 0.1, group = gT, inline = "tp")
beOn     = input.bool(true, "Stop To Breakeven After TP1", group = gT)
runTrail = input.bool(true, "ATR-Trail The Runner After TP2", group = gT)
maxHold  = input.int(0, "Max Hold (bars, 0 = window end)", minval = 0, maxval = 5000, group = gT)
showLvls = input.bool(true, "Draw Levels For Latest Open Trade", group = gT)
showExit = input.bool(true, "Mark Trade Exits", group = gT)

gS = "═══ Trailing Stop · Optimizer ═══"
showTrail = input.bool(false, "Show ATR Trailing Stop", group = gS)
trailMult = input.float(2.0, "Trail ATR Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = gS)
trailLen  = input.int(14, "Trail ATR Length", minval = 1, maxval = 500, group = gS)
optBase   = input.float(1.0, "Optimizer · Base Mult", minval = 0.1, maxval = 10.0, step = 0.1, group = gS, inline = "op")
optStep   = input.float(0.5, "Step", minval = 0.1, maxval = 5.0, step = 0.1, group = gS, inline = "op", tooltip = "Five chandelier-style ATR trails run on every first close-break of each side. Results are measured in ATR units at entry so different stop widths compare fairly.")

gV = "═══ Visuals ═══"
bullCol   = input.color(#21c997, "Bull", group = gV, inline = "cl")
bearCol   = input.color(#f23661, "Bear", group = gV, inline = "cl")
rngCol    = input.color(#f5b942, "Range", group = gV, inline = "cl")
pocCol    = input.color(#e8e6f0, "POC", group = gV, inline = "cl")
fillTr    = input.int(86, "Zone Fill Transparency", minval = 50, maxval = 98, group = gV)
showSessBg = input.bool(true, "Shade Opening-Range Session", group = gV)
showExt   = input.bool(true, "Show Extension Levels", group = gV)
showMid   = input.bool(true, "Show OR Midline", group = gV)
showLbls  = input.bool(true, "Level Labels With Hit Rates", group = gV)
showOrTag = input.bool(true, "OR Completion Tag", group = gV)
barColOn  = input.bool(false, "Color Bars By Range Position", group = gV)
sigSizeS  = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal"], group = gV)
maxSigLbl = input.int(150, "Max Signal Labels", minval = 10, maxval = 400, group = gV)
showVP    = input.bool(true, "OR Volume Profile", group = gV)
vpRows    = input.int(20, "Profile Rows", minval = 5, maxval = 60, group = gV, inline = "vp")
vpWidth   = input.int(30, "Width (bars)", minval = 5, maxval = 120, group = gV, inline = "vp")
vpOff     = input.int(4, "Profile Offset (bars)", minval = 1, maxval = 60, group = gV, inline = "vp2")
vaPct     = input.int(70, "Value Area %", minval = 30, maxval = 95, group = gV, inline = "vp2")

gD = "═══ Dashboard ═══"
dashOn    = input.bool(true, "Show Dashboard", group = gD)
dashPos   = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group = gD)
dashSizeS = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
showP1    = input.bool(true, "Panel I · Session State", group = gD)
showP2    = input.bool(true, "Panel II · ORB Level Matrix", group = gD)
showP3    = input.bool(true, "Panel III · Breakout Analytics", group = gD)
showP4    = input.bool(true, "Panel IV · Session Statistics", group = gD)
showP5    = input.bool(true, "Panel V · Stop Optimizer", group = gD)
panelTr   = input.int(6, "Panel Transparency", minval = 0, maxval = 90, step = 2, group = gD)
sepH      = input.float(0.9, "Separator Gap (% height)", minval = 0.1, maxval = 4.0, step = 0.1, group = gD)
monoFont  = input.bool(true, "Monospace Numbers", group = gD)

gA = "═══ Alerts ═══"
richAlerts = input.bool(true, "Detailed alert() Messages", group = gA, tooltip = "Create the alert with 'Any alert() function call' to receive entry, stop and targets in the message.")

//───────────────────────────────────────────────────────────────────────────────────────────────
// Constants · theme
//───────────────────────────────────────────────────────────────────────────────────────────────
color TXT     = #d9dce6
color MUTED   = #7d8597
color DIM     = #4a5163
color CLEAR   = color.new(#000000, 100)
color PANEL   = color.new(#0b0e15, panelTr)
color PANEL2  = color.new(#10141e, panelTr)
color HEAD    = color.new(#181e2c, panelTr)
color COLHD   = color.new(#131826, panelTr)
color PRICEBG = color.new(#1d2333, panelTr)

var array<string> TN = array.from("BRK", "RTST", "FAIL")
var array<string> TF = array.from("Breakout · first close beyond the opening range edge", "Break & Retest · a broken edge was retested and held on a close", "Failed Breakout · a break closed back inside the range, faded toward the other side")

string sigSz = sigSizeS == "Tiny" ? size.tiny : sigSizeS == "Normal" ? size.normal : size.small

//───────────────────────────────────────────────────────────────────────────────────────────────
// Types
//───────────────────────────────────────────────────────────────────────────────────────────────
type Trade
    int   dir
    int   typ
    float entry
    float sl
    float risk
    float tp1
    float tp2
    float tp3
    int   ebar
    int   stage
    float realized
    float score
    bool  slMoved

//───────────────────────────────────────────────────────────────────────────────────────────────
// Global state
//───────────────────────────────────────────────────────────────────────────────────────────────
// Session
var float orH         = na
var float orL         = na
var bool  orDone      = false
var bool  finalized   = true
var int   orStartBar  = -1
var int   orEndBar    = -1
var int   firstBreak  = 0
var int   firstBrkBar = -1
var bool  dayBrkUp    = false
var bool  dayBrkDn    = false
var bool  dayFake     = false
var int   dayCls      = 0
var float orWNow      = na
var float orWPct      = na
var int   sigToday    = 0
var array<bool>  dayHit = array.new<bool>(6, false)

// Per-side break machine (index 0 = up, 1 = down)
var array<bool>  sOut  = array.new<bool>(2, false)
var array<int>   sCnt  = array.new<int>(2, 0)
var array<int>   sLast = array.new<int>(2, -1)
var array<float> sExt  = array.new<float>(2, na)
var array<bool>  sRtst = array.new<bool>(2, false)
var array<bool>  sFail = array.new<bool>(2, false)

// Session statistics
var int nSess   = 0
var int nUpF    = 0
var int nDnF    = 0
var int nNone   = 0
var int nBrkUp  = 0
var int nBrkDn  = 0
var int nBoth   = 0
var int nFake   = 0
var int nDelay  = 0
var int sumDel  = 0
var int nNar    = 0
var int nNarT1  = 0
var int nWide   = 0
var int nWideT1 = 0
var array<int>   cnt   = array.new<int>(6, 0)
var array<int>   cntUF = array.new<int>(6, 0)
var array<int>   cntDF = array.new<int>(6, 0)
var array<float> orW   = array.new<float>()

// Session VWAP / flow and OR profile capture
var float vPV  = 0.0
var float vV   = 0.0
var float sVol = 0.0
var float sDel = 0.0
var array<float> vpH = array.new<float>()
var array<float> vpL = array.new<float>()
var array<float> vpV = array.new<float>()
var array<float> vpD = array.new<float>()

// Trades and honest stats
var array<Trade> trades  = array.new<Trade>()
var array<label> sigLbls = array.new<label>()
var array<label> lvlLbls = array.new<label>()
var array<line>  trLines = array.new<line>()
var array<label> trLbls  = array.new<label>()
var array<box>   vpBoxes = array.new<box>()
var array<line>  vpLines = array.new<line>()

var array<int>   stN  = array.new<int>(3, 0)
var array<int>   stW  = array.new<int>(3, 0)
var array<float> stR  = array.new<float>(3, 0.0)
var array<float> stGW = array.new<float>(3, 0.0)
var array<float> stGL = array.new<float>(3, 0.0)
var int   totN   = 0
var int   totW   = 0
var float totR   = 0.0
var float totGW  = 0.0
var float totGL  = 0.0
var float eqPeak = 0.0
var float maxDD  = 0.0
var int   streak = 0
var int   hit1   = 0
var int   hit2   = 0
var int   hit3   = 0
var int   exSL   = 0
var int   exBE   = 0
var int   exTP3  = 0
var int   exEOD  = 0

var int   lastSigTyp = -1
var int   lastSigDir = 0
var int   lastSigBar = na
var float lastSigSc  = na

// Optimizer (0-4 = optimizer multipliers, 5 = live trailing stop)
var array<int>   oDir = array.new<int>(6, 0)
var array<float> oEnt = array.new<float>(6, na)
var array<float> oStp = array.new<float>(6, na)
var array<float> oAtr = array.new<float>(6, na)
var array<int>   oN   = array.new<int>(6, 0)
var array<int>   oW   = array.new<int>(6, 0)
var array<float> oNet = array.new<float>(6, 0.0)
var array<float> oGW  = array.new<float>(6, 0.0)
var array<float> oGL  = array.new<float>(6, 0.0)

//───────────────────────────────────────────────────────────────────────────────────────────────
// Helpers
//───────────────────────────────────────────────────────────────────────────────────────────────
clamp01(float x) => math.min(math.max(x, 0.0), 1.0)

f_sv(float v) => (v > 0 ? "+" : "") + str.tostring(v, format.volume)

f_sn(float v, string fmt) => (v > 0 ? "+" : "") + str.tostring(v, fmt)

f_px(float v) => na(v) ? "—" : str.tostring(v, format.mintick)

f_pct(int n, int d) => d > 0 ? str.tostring(float(n) / d * 100.0, "#") + "%" : "—"

f_frac(int n, int d) => d > 0 ? float(n) / d : 0.0

f_stars(float sc) => sc >= 8 ? "★★★★" : sc >= 6.5 ? "★★★" : sc >= 5 ? "★★" : sc >= 3 ? "★" : "·"

f_gauge(float frac, int n) =>
    int k = math.max(0, math.min(n, int(math.round(frac * n))))
    str.repeat("▰", k) + str.repeat("▱", n - k)

f_tfn(string tf) =>
    int s = timeframe.in_seconds(tf)
    string out = ""
    if s < 60
        out := str.tostring(s) + "s"
    else if s < 3600 or s % 3600 != 0
        out := str.tostring(int(s / 60)) + "m"
    else if s < 86400
        out := str.tostring(int(s / 3600)) + "H"
    else if s < 604800
        out := str.tostring(int(s / 86400)) + "D"
    else if s < 2419200
        out := str.tostring(int(s / 604800)) + "W"
    else
        out := str.tostring(int(s / 2592000)) + "M"
    out

// Signed aggression weight of one bar: +1 = all buying, -1 = all selling
f_w(float o, float h, float l, float c, float tick) =>
    float r = h - l
    float w = 0.0
    if r > 0
        float clv  = (2.0 * c - h - l) / r
        float body = (c - o) / r
        w := synthMdl == "Close Location (CLV)" ? clv : synthMdl == "Body Ratio" ? body : 0.5 * clv + 0.5 * body
    else
        w := tick
    w

//───────────────────────────────────────────────────────────────────────────────────────────────
// Session windows
//───────────────────────────────────────────────────────────────────────────────────────────────
string orStartS = str.substring(sessInput, 0, 4)
string orEndS   = str.substring(sessInput, 5, 9)
int    orMin    = ((int(str.tonumber(str.substring(orEndS, 0, 2))) * 60 + int(str.tonumber(str.substring(orEndS, 2, 4)))) - (int(str.tonumber(str.substring(orStartS, 0, 2))) * 60 + int(str.tonumber(str.substring(orStartS, 2, 4)))) + 1440) % 1440
bool   unlimited = endMode == "Next OR · Unlimited"
string endS = switch endMode
    "16:00 · Cash Close"    => "1600"
    "17:00 · Futures Close" => "1700"
    "11:30 · London Close"  => "1130"
    "Manual Time"           => str.replace(manualEnd, ":", "")
    => "2359"
string endLbl = unlimited ? "next OR" : str.substring(endS, 0, 2) + ":" + str.substring(endS, 2, 4)

int  chartSec  = timeframe.in_seconds(timeframe.period)
int  sHr       = int(str.tonumber(str.substring(orStartS, 0, 2)))
int  sMi       = int(str.tonumber(str.substring(orStartS, 2, 4)))
int  eHr       = int(str.tonumber(str.substring(orEndS, 0, 2)))
int  eMi       = int(str.tonumber(str.substring(orEndS, 2, 4)))
int  wHr       = int(str.tonumber(str.substring(endS, 0, 2)))
int  wMi       = int(str.tonumber(str.substring(endS, 2, 4)))

// Overlap-based session membership: a bar belongs to a window when its [open, close) span overlaps it.
// Works on any intraday timeframe (a 1H bar opening 09:00 overlaps a 09:30-10:00 range), follows DST
// through the named timezone, and handles windows that cross midnight (checks today's and yesterday's start).
f_member(int endH, int endM) =>
    int  barEnd = na(time_close) ? time + chartSec * 1000 : time_close
    int  tToday = timestamp(tzInput, year(time, tzInput), month(time, tzInput), dayofmonth(time, tzInput), sHr, sMi)
    int  eToday = timestamp(tzInput, year(time, tzInput), month(time, tzInput), dayofmonth(time, tzInput), endH, endM)
    int  span   = eToday > tToday ? eToday - tToday : eToday - tToday + 86400000
    bool hit    = false
    for off = 0 to 1
        int  t0    = tToday - off * 86400000
        int  t1    = t0 + span
        bool dayOk = str.contains(sessDays, str.tostring(dayofweek(t0, tzInput)))
        if dayOk and time < t1 and barEnd > t0
            hit := true
    hit

bool inSession = timeframe.isintraday and f_member(eHr, eMi)
bool inWin     = unlimited or (timeframe.isintraday and f_member(wHr, wMi))
bool sessStart = inSession and not inSession[1]
bool tfWarn    = not timeframe.isintraday or (orMin > 0 and chartSec > orMin * 60)

//───────────────────────────────────────────────────────────────────────────────────────────────
// Delta engine · intrabar reconstruction with synthetic fallback
//───────────────────────────────────────────────────────────────────────────────────────────────
string ltfTf    = timeframe.from_seconds(math.max(60, int(chartSec / ltfDepth)))
bool   ltfValid = deltaSrc == "Intrabar (auto fallback)" and timeframe.in_seconds(ltfTf) < chartSec

[iO, iH, iL, iC, iV] = request.security_lower_tf(syminfo.tickerid, ltfValid ? ltfTf : timeframe.period, [open, high, low, close, volume], ignore_invalid_timeframe = true)

float prevClose = nz(close[1], open)
float barVol    = 0.0
float barDelta  = 0.0
int   nIntra    = 0
if ltfValid and array.size(iH) > 0
    float pc = prevClose
    for i = 0 to array.size(iH) - 1
        float ih = iH.get(i)
        float il = iL.get(i)
        float ic = iC.get(i)
        float io = iO.get(i)
        if not na(ih) and not na(il) and not na(ic) and not na(io)
            float iv = na(iV.get(i)) ? 1.0 : iV.get(i)
            barVol   += iv
            barDelta += iv * f_w(io, ih, il, ic, math.sign(ic - pc))
            nIntra   += 1
            pc := ic
bool usedLtf = nIntra > 0
if not usedLtf
    float bv = na(volume) ? 1.0 : volume
    barVol   := bv
    barDelta := bv * f_w(open, high, low, close, math.sign(close - prevClose))

//───────────────────────────────────────────────────────────────────────────────────────────────
// Market context
//───────────────────────────────────────────────────────────────────────────────────────────────
float atrV   = math.max(nz(ta.atr(atrLen), high - low), syminfo.mintick)
float atrT   = math.max(nz(ta.atr(trailLen), atrV), syminfo.mintick)
float avgVol = math.max(nz(ta.sma(barVol, volLen), barVol), 1e-10)
float dAtr   = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead = barmerge.lookahead_on)

[hEma1, hEma2, hC1] = request.security(syminfo.tickerid, htfTf, [ta.ema(close, htfLen)[1], ta.ema(close, htfLen)[2], close[1]], lookahead = barmerge.lookahead_on)
int htfBias = na(hEma1) or na(hEma2) or na(hC1) ? 0 : hC1 > hEma1 and hEma1 >= hEma2 ? 1 : hC1 < hEma1 and hEma1 <= hEma2 ? -1 : 0

//───────────────────────────────────────────────────────────────────────────────────────────────
// Event flags (reset every bar)
//───────────────────────────────────────────────────────────────────────────────────────────────
bool evOrDone = false
bool evBrkUp  = false
bool evBrkDn  = false
bool sigBull  = false
bool sigBear  = false
bool sigHigh  = false
bool sigRtst  = false
bool sigFail  = false
bool evTUp1   = false
bool evTUp3   = false
bool evTDn1   = false
bool evTDn3   = false
int  rawBrk   = 0

//───────────────────────────────────────────────────────────────────────────────────────────────
// 1 · Resolve open trades (before anything new; entries are evaluated from the next bar)
//───────────────────────────────────────────────────────────────────────────────────────────────
if trades.size() > 0
    for i = trades.size() - 1 to 0
        Trade t = trades.get(i)
        if bar_index > t.ebar
            bool  done  = false
            int   kind  = 0
            float exPx  = close
            float fr    = 1.0 / 3.0
            if sessStart or not inWin
                exPx := open
                t.realized += (3 - t.stage) * fr * (exPx - t.entry) * t.dir / t.risk
                done := true
                kind := 4
            else
                bool stopHit = t.dir == 1 ? low <= t.sl : high >= t.sl
                if stopHit
                    exPx := t.dir == 1 ? math.min(open, t.sl) : math.max(open, t.sl)
                    t.realized += (3 - t.stage) * fr * (exPx - t.entry) * t.dir / t.risk
                    done := true
                    kind := t.stage == 0 ? 1 : 2
                else
                    int st0 = t.stage
                    if t.stage == 0 and (t.dir == 1 ? high >= t.tp1 : low <= t.tp1)
                        t.stage    := 1
                        t.realized += fr * (t.tp1 - t.entry) * t.dir / t.risk
                        if beOn
                            t.sl      := t.entry
                            t.slMoved := true
                    if t.stage == 1 and (t.dir == 1 ? high >= t.tp2 : low <= t.tp2)
                        t.stage    := 2
                        t.realized += fr * (t.tp2 - t.entry) * t.dir / t.risk
                    if t.stage == 2 and (t.dir == 1 ? high >= t.tp3 : low <= t.tp3)
                        t.stage    := 3
                        t.realized += fr * (t.tp3 - t.entry) * t.dir / t.risk
                        exPx := t.tp3
                        done := true
                        kind := 3
                    // Pessimistic: a target bar that also traded back through the freshly moved stop exits the remainder there
                    if not done and t.stage > st0 and t.slMoved and (t.dir == 1 ? low <= t.sl : high >= t.sl)
                        exPx := t.sl
                        t.realized += (3 - t.stage) * fr * (t.sl - t.entry) * t.dir / t.risk
                        done := true
                        kind := 2
                    if not done and maxHold > 0 and bar_index - t.ebar >= maxHold
                        exPx := close
                        t.realized += (3 - t.stage) * fr * (close - t.entry) * t.dir / t.risk
                        done := true
                        kind := 4
                    // Runner trail (applies from the next bar)
                    if not done and runTrail and t.stage >= 2
                        float trl = t.dir == 1 ? close - trailMult * atrT : close + trailMult * atrT
                        t.sl      := t.dir == 1 ? math.max(t.sl, trl) : math.min(t.sl, trl)
                        t.slMoved := true
            if done
                int  ty  = t.typ
                bool win = t.realized > 0
                stN.set(ty, stN.get(ty) + 1)
                stR.set(ty, stR.get(ty) + t.realized)
                if win
                    stW.set(ty, stW.get(ty) + 1)
                    stGW.set(ty, stGW.get(ty) + t.realized)
                    totW  += 1
                    totGW += t.realized
                else
                    stGL.set(ty, stGL.get(ty) - t.realized)
                    totGL -= t.realized
                totN += 1
                totR += t.realized
                hit1 += t.stage >= 1 ? 1 : 0
                hit2 += t.stage >= 2 ? 1 : 0
                hit3 += t.stage >= 3 ? 1 : 0
                exSL  += kind == 1 ? 1 : 0
                exBE  += kind == 2 ? 1 : 0
                exTP3 += kind == 3 ? 1 : 0
                exEOD += kind == 4 ? 1 : 0
                eqPeak := math.max(eqPeak, totR)
                maxDD  := math.max(maxDD, eqPeak - totR)
                streak := t.realized > 0 ? (streak > 0 ? streak + 1 : 1) : t.realized < 0 ? (streak < 0 ? streak - 1 : -1) : 0
                if showExit
                    string ek = kind == 1 ? "SL" : kind == 2 ? (t.stage >= 1 ? "STOP · " + str.tostring(t.stage) + "/3 banked" : "STOP") : kind == 3 ? "TP3" : "WINDOW END"
                    color  xc = t.realized > 0 ? bullCol : t.realized < 0 ? bearCol : MUTED
                    sigLbls.push(label.new(bar_index, exPx, (t.realized > 0 ? "✓ " : t.realized < 0 ? "✕ " : "◦ ") + f_sn(t.realized, "#.00") + "R", style = label.style_label_left, color = color.new(xc, 80), textcolor = xc, size = size.tiny, tooltip = TN.get(ty) + (t.dir == 1 ? " long" : " short") + " closed · " + ek + "\nEntry " + f_px(t.entry) + " → exit " + f_px(exPx) + "\nRealized " + f_sn(t.realized, "#.00") + "R"))
                trades.remove(i)

//───────────────────────────────────────────────────────────────────────────────────────────────
// 2 · Optimizer / live trailing stop · update before new entries
//───────────────────────────────────────────────────────────────────────────────────────────────
for i = 0 to 5
    int od = oDir.get(i)
    if od != 0
        float m    = i < 5 ? optBase + i * optStep : trailMult
        bool  exNow = false
        float px    = close
        if sessStart or not inWin
            exNow := true
            px    := open
        else
            float st = od == 1 ? math.max(oStp.get(i), low - atrT * m) : math.min(oStp.get(i), high + atrT * m)
            oStp.set(i, st)
            exNow := od == 1 ? close < st : close > st
        if exNow
            float res = (px - oEnt.get(i)) * od / math.max(oAtr.get(i), syminfo.mintick)
            oN.set(i, oN.get(i) + 1)
            oNet.set(i, oNet.get(i) + res)
            if res > 0
                oW.set(i, oW.get(i) + 1)
                oGW.set(i, oGW.get(i) + res)
            else
                oGL.set(i, oGL.get(i) - res)
            oDir.set(i, 0)
            oStp.set(i, na)

//───────────────────────────────────────────────────────────────────────────────────────────────
// 3 · Session rollover · finalize the previous session's statistics, then reset
//───────────────────────────────────────────────────────────────────────────────────────────────
bool doFinal = not finalized and orDone and (sessStart or (not inWin and inWin[1]))
if doFinal
    nSess += 1
    for k = 0 to 5
        if dayHit.get(k)
            cnt.set(k, cnt.get(k) + 1)
            if firstBreak == 1
                cntUF.set(k, cntUF.get(k) + 1)
            else if firstBreak == -1
                cntDF.set(k, cntDF.get(k) + 1)
    nUpF   += firstBreak == 1 ? 1 : 0
    nDnF   += firstBreak == -1 ? 1 : 0
    nNone  += firstBreak == 0 ? 1 : 0
    nBrkUp += dayBrkUp ? 1 : 0
    nBrkDn += dayBrkDn ? 1 : 0
    nBoth  += dayBrkUp and dayBrkDn ? 1 : 0
    nFake  += firstBreak != 0 and dayFake ? 1 : 0
    if firstBreak != 0 and firstBrkBar >= 0
        nDelay += 1
        sumDel += firstBrkBar - orEndBar
    bool anyT1 = dayHit.get(0) or dayHit.get(3)
    if dayCls == 1
        nNar   += 1
        nNarT1 += anyT1 ? 1 : 0
    else if dayCls == 3
        nWide   += 1
        nWideT1 += anyT1 ? 1 : 0
    finalized := true

if sessStart
    orH         := na
    orL         := na
    orDone      := false
    finalized   := false
    orStartBar  := bar_index
    orEndBar    := -1
    firstBreak  := 0
    firstBrkBar := -1
    dayBrkUp    := false
    dayBrkDn    := false
    dayFake     := false
    dayCls      := 0
    orWNow      := na
    orWPct      := na
    sigToday    := 0
    dayHit.fill(false)
    sOut.fill(false)
    sCnt.fill(0)
    sLast.fill(-1)
    sExt.fill(float(na))
    sRtst.fill(false)
    sFail.fill(false)
    vPV  := 0.0
    vV   := 0.0
    sVol := 0.0
    sDel := 0.0
    vpH.clear()
    vpL.clear()
    vpV.clear()
    vpD.clear()

//───────────────────────────────────────────────────────────────────────────────────────────────
// 4 · Opening range build · session VWAP · session flow
//───────────────────────────────────────────────────────────────────────────────────────────────
if orStartBar >= 0
    vPV  += hlc3 * barVol
    vV   += barVol
    sVol += barVol
    sDel += barDelta
float sVwap = vV > 0 ? vPV / vV : na

if inSession
    float hiS = srcInput == "High/Low" ? high : math.max(open, close)
    float loS = srcInput == "High/Low" ? low : math.min(open, close)
    orH := na(orH) ? hiS : math.max(orH, hiS)
    orL := na(orL) ? loS : math.min(orL, loS)
    if vpH.size() < 3000
        vpH.push(high)
        vpL.push(low)
        vpV.push(barVol)
        vpD.push(barDelta)

float orR = orH - orL
float orM = (orH + orL) / 2.0

if not inSession and inSession[1] and not na(orH) and not orDone
    orDone   := true
    orEndBar := bar_index
    evOrDone := true
    if not na(dAtr) and dAtr > 0
        orWNow := orR / dAtr * 100.0
        if orW.size() >= 5
            int below = 0
            for w in orW
                below += w < orWNow ? 1 : 0
            orWPct := float(below) / orW.size() * 100.0
            dayCls := orWPct <= 30 ? 1 : orWPct >= 70 ? 3 : 2
        orW.push(orWNow)
        while orW.size() > widthLook
            orW.shift()

float f1 = extType == "Fibonacci" ? 0.382 : mult1
float f2 = extType == "Fibonacci" ? 0.618 : mult2
float f3 = extType == "Fibonacci" ? 1.0 : mult3
float u1 = orH + orR * f1
float u2 = orH + orR * f2
float u3 = orH + orR * f3
float d1 = orL - orR * f1
float d2 = orL - orR * f2
float d3 = orL - orR * f3

bool live = orDone and inWin and not inSession and not na(orH)

//───────────────────────────────────────────────────────────────────────────────────────────────
// 5 · Scoring and trade planning
//───────────────────────────────────────────────────────────────────────────────────────────────
f_score(int d, int ty, float ref) =>
    float rngB = math.max(high - low, syminfo.mintick)
    float volR = barVol / avgVol
    float sV   = clamp01((volR - 0.8) / math.max(hvMult * 1.5 - 0.8, 0.1))
    float sB   = clamp01(d == 1 ? (close - low) / rngB : (high - close) / rngB)
    float disp = (close - ref) * d / atrV
    float sD   = clamp01(disp / dispRef)
    float sW   = na(orWPct) ? 0.5 : ty == 2 ? orWPct / 100.0 : 1.0 - orWPct / 100.0
    float sH   = htfBias == d ? 1.0 : htfBias == 0 ? 0.5 : 0.0
    float dr   = barVol > 0 ? barDelta / barVol * d : 0.0
    float sF   = clamp01(dr / 0.5)
    float sP   = na(sVwap) ? 0.5 : (close - sVwap) * d > 0 ? 1.0 : 0.0
    float ws   = wVol + wBody + wDisp + wWidth + wHtf + wDelta + wVwap
    float sc   = ws > 0 ? 10.0 * (wVol * sV + wBody * sB + wDisp * sD + wWidth * sW + wHtf * sH + wDelta * sF + wVwap * sP) / ws : 0.0
    [sc, volR, sB, disp, sW, dr, sP]

f_plan(int d, int ty, float entry, float ext) =>
    float slRaw = ty == 2 ? ext - d * slBuf * atrV : slMode == "OR Opposite" ? (d == 1 ? orL : orH) - d * slBuf * atrV : slMode == "OR Mid" ? orM - d * slBuf * atrV : slMode == "ATR" ? entry - d * slAtr * atrV : (d == 1 ? low : high) - d * slBuf * atrV
    float risk  = math.min(math.max((entry - slRaw) * d, minRisk * atrV), maxRisk * atrV)
    float sl    = entry - d * risk
    array<float> ex = ty == 2 ? array.from(orM, d == 1 ? orH : orL, d == 1 ? u1 : d1) : array.from(d == 1 ? u1 : d1, d == 1 ? u2 : d2, d == 1 ? u3 : d3)
    array<float> rr = array.from(tp1R, tp2R, tp3R)
    array<float> tp = array.new<float>()
    float prev = entry
    for k = 0 to 2
        float cand = ex.get(k)
        float rT   = entry + d * risk * rr.get(k)
        bool  useX = tpMode == "OR Extensions" and not na(cand) and (cand - entry) * d >= 0.25 * risk and (cand - prev) * d >= 0.1 * risk
        float t    = useX ? cand : (rT - prev) * d > 0 ? rT : prev + d * 0.5 * risk
        tp.push(t)
        prev := t
    [sl, risk, tp.get(0), tp.get(1), tp.get(2)]

//───────────────────────────────────────────────────────────────────────────────────────────────
// 6 · Break machine · BRK / RTST / FAIL candidates, target tracking
//───────────────────────────────────────────────────────────────────────────────────────────────
array<int>   cD = array.new<int>()
array<int>   cT = array.new<int>()
array<float> cR = array.new<float>()
array<float> cX = array.new<float>()

if live
    // Target first-touch tracking (wick based, as in the classic hit-rate model)
    array<float> tg = array.from(u1, u2, u3, d1, d2, d3)
    for k = 0 to 5
        float lv = tg.get(k)
        bool  hitNow = k < 3 ? high >= lv : low <= lv
        if hitNow and not dayHit.get(k)
            dayHit.set(k, true)
            evTUp1 := evTUp1 or k == 0
            evTUp3 := evTUp3 or k == 2
            evTDn1 := evTDn1 or k == 3
            evTDn3 := evTDn3 or k == 5

    for s in array.from(1, -1)
        int   k      = s == 1 ? 0 : 1
        float edge   = s == 1 ? orH : orL
        bool  beyond = (close - edge) * s > breakBuf * atrV
        bool  wasOut = sOut.get(k)
        int   lb     = sLast.get(k)
        bool  rtFired = false

        if wasOut
            sExt.set(k, s == 1 ? math.max(sExt.get(k), high) : math.min(sExt.get(k), low))

        if lb >= 0 and bar_index > lb
            int age = bar_index - lb
            // FAIL: the break closed back inside by the required depth
            if not sFail.get(k) and age <= failWin and (edge - close) * s >= failDepth * orR
                sFail.set(k, true)
                sRtst.set(k, true)
                if s == firstBreak and sCnt.get(k) == 1
                    dayFake := true
                if enFAIL
                    cD.push(-s)
                    cT.push(2)
                    cR.push(edge)
                    cX.push(sExt.get(k))
            // RTST: pullback into the edge that closes back beyond it, in the break direction
            else if not sRtst.get(k) and not sFail.get(k) and age <= retestWin
                bool touched = s == 1 ? low <= edge + retestTol * atrV : high >= edge - retestTol * atrV
                if touched and (close - edge) * s > 0 and (close - open) * s > 0
                    sRtst.set(k, true)
                    rtFired := true
                    if enRTST
                        cD.push(s)
                        cT.push(1)
                        cR.push(edge)
                        cX.push(na)

        if beyond and not wasOut
            sOut.set(k, true)
            sCnt.set(k, sCnt.get(k) + 1)
            sLast.set(k, bar_index)
            sExt.set(k, s == 1 ? high : low)
            if not rtFired
                sRtst.set(k, false)
            sFail.set(k, false)
            if s == 1
                dayBrkUp := true
                evBrkUp  := true
            else
                dayBrkDn := true
                evBrkDn  := true
            if firstBreak == 0
                firstBreak  := s
                firstBrkBar := bar_index
            if sCnt.get(k) == 1
                rawBrk := rawBrk == 0 ? s : rawBrk
            if enBRK and sCnt.get(k) <= maxBrkSd and not rtFired
                cD.push(s)
                cT.push(0)
                cR.push(edge)
                cX.push(na)
        else if wasOut and not beyond
            sOut.set(k, false)

// Optimizer entries on raw first breaks (independent of the score gate)
if rawBrk != 0
    for i = 0 to 5
        if oDir.get(i) == 0
            float m = i < 5 ? optBase + i * optStep : trailMult
            oDir.set(i, rawBrk)
            oEnt.set(i, close)
            oAtr.set(i, atrT)
            oStp.set(i, rawBrk == 1 ? low - atrT * m : high + atrT * m)

//───────────────────────────────────────────────────────────────────────────────────────────────
// 7 · Signals → labels, trades, alerts
//───────────────────────────────────────────────────────────────────────────────────────────────
bool canSig = not confClose or barstate.isconfirmed

if cD.size() > 0
    for i = 0 to cD.size() - 1
        int   d   = cD.get(i)
        int   ty  = cT.get(i)
        float ref = cR.get(i)
        [sc, volR, sB, disp, sW, dr, sP] = f_score(d, ty, ref)
        bool htfOk = not htfBlock or htfBias != -d
        if canSig and sigToday < maxSigDay and sc >= minScore and htfOk
            [sl, risk, t1, t2, t3] = f_plan(d, ty, close, cX.get(i))
            string nm  = TN.get(ty)
            color  cc  = d == 1 ? bullCol : bearCol
            int    trn = sc >= hiScore ? 0 : sc >= (minScore + hiScore) / 2.0 ? 18 : 38
            string vt  = volR >= hvMult ? "HV" : "LV"
            string tip = TF.get(ty) + "\n" + (d == 1 ? "LONG" : "SHORT") + " · score " + str.tostring(sc, "#.0") + " / 10  " + f_stars(sc) + "\n— Volume " + str.tostring(volR, "#.00") + "× avg (" + vt + ")\n— Close location " + str.tostring(sB * 100, "#") + "%\n— Displacement " + f_sn(disp, "#.00") + " ATR\n— OR width rank " + (na(orWPct) ? "n/a" : str.tostring(orWPct, "#") + " pctl") + "\n— Bar delta " + f_sn(dr * 100, "#") + "% aligned\n— VWAP side " + (sP >= 1 ? "with" : sP <= 0 ? "against" : "n/a") + "\n— HTF bias " + (htfBias == 1 ? "BULL" : htfBias == -1 ? "BEAR" : "NEUTRAL") + "\nEntry " + f_px(close) + "  SL " + f_px(sl) + "  (" + str.tostring(risk / atrV, "#.00") + " ATR)\nTP " + f_px(t1) + " / " + f_px(t2) + " / " + f_px(t3)
            sigLbls.push(label.new(bar_index, d == 1 ? low : high, nm + (d == 1 ? " ▲" : " ▼") + "\n" + str.tostring(sc, "#.0") + " · " + vt, style = d == 1 ? label.style_label_up : label.style_label_down, color = color.new(cc, trn), textcolor = color.white, size = sc >= hiScore and sigSz == size.small ? size.normal : sigSz, tooltip = tip))
            if trackOn
                trades.push(Trade.new(d, ty, close, sl, risk, t1, t2, t3, bar_index, 0, 0.0, sc, false))
            sigToday   += 1
            lastSigTyp := ty
            lastSigDir := d
            lastSigBar := bar_index
            lastSigSc  := sc
            sigBull    := sigBull or d == 1
            sigBear    := sigBear or d == -1
            sigHigh    := sigHigh or sc >= hiScore
            sigRtst    := sigRtst or ty == 1
            sigFail    := sigFail or ty == 2
            if richAlerts
                alert("SORB " + (d == 1 ? "LONG " : "SHORT ") + nm + " · score " + str.tostring(sc, "#.0") + "/10 · " + syminfo.ticker + " " + timeframe.period + " · entry " + f_px(close) + " · SL " + f_px(sl) + " · TP " + f_px(t1) + " / " + f_px(t2) + " / " + f_px(t3), alert.freq_once_per_bar_close)
        else if canSig and showWeak
            sigLbls.push(label.new(bar_index, d == 1 ? low : high, "", style = label.style_circle, color = color.new(d == 1 ? bullCol : bearCol, 55), size = size.tiny, tooltip = "Filtered " + TN.get(ty) + (d == 1 ? " ▲" : " ▼") + " · score " + str.tostring(sc, "#.0") + (not htfOk ? " · counter-HTF" : sigToday >= maxSigDay ? " · session cap" : "")))

// OR completion tag
if evOrDone and showOrTag
    string cls = dayCls == 1 ? "NARROW" : dayCls == 3 ? "WIDE" : dayCls == 2 ? "NORMAL" : "—"
    color  tc  = dayCls == 1 ? bullCol : dayCls == 3 ? bearCol : rngCol
    sigLbls.push(label.new(bar_index, orH, "OR " + (na(orWNow) ? "" : str.tostring(orWNow, "#") + "% ADR · ") + cls, style = label.style_label_lower_left, color = color.new(rngCol, 85), textcolor = tc, size = size.tiny, tooltip = "Opening range complete\nHigh " + f_px(orH) + " · Low " + f_px(orL) + "\nWidth " + f_px(orR) + (na(orWPct) ? "" : " · rank " + str.tostring(orWPct, "#") + " pctl of last " + str.tostring(orW.size() - 1) + " sessions")))
    if richAlerts
        alert("SORB opening range complete · " + syminfo.ticker + " · H " + f_px(orH) + " · L " + f_px(orL) + " · " + cls, alert.freq_once_per_bar_close)

while sigLbls.size() > maxSigLbl
    sigLbls.shift().delete()

//───────────────────────────────────────────────────────────────────────────────────────────────
// 8 · Plots · range, extensions, fills, trail
//───────────────────────────────────────────────────────────────────────────────────────────────
bool  drawOk = inWin and not na(orH)
float pH  = drawOk ? orH : na
float pL  = drawOk ? orL : na
float pM  = drawOk and showMid ? orM : na
float pU1 = drawOk and showExt ? u1 : na
float pU2 = drawOk and showExt ? u2 : na
float pU3 = drawOk and showExt ? u3 : na
float pD1 = drawOk and showExt ? d1 : na
float pD2 = drawOk and showExt ? d2 : na
float pD3 = drawOk and showExt ? d3 : na

bgcolor(showSessBg and inSession ? color.new(rngCol, 92) : na, title = "OR Session Shade")

plH  = plot(pH, "OR High", color.new(rngCol, 10), 2, plot.style_linebr)
plL  = plot(pL, "OR Low", color.new(rngCol, 10), 2, plot.style_linebr)
plot(pM, "OR Mid", color.new(rngCol, 45), 1, plot.style_linebr, linestyle = plot.linestyle_dotted)
fill(plH, plL, color.new(rngCol, fillTr), "Range Fill")

plU1 = plot(pU1, "Upper T1", color.new(bullCol, 35), 1, plot.style_linebr)
plU2 = plot(pU2, "Upper T2", color.new(bullCol, 35), 1, plot.style_linebr)
plU3 = plot(pU3, "Upper T3", color.new(bullCol, 20), 1, plot.style_linebr)
plD1 = plot(pD1, "Lower T1", color.new(bearCol, 35), 1, plot.style_linebr)
plD2 = plot(pD2, "Lower T2", color.new(bearCol, 35), 1, plot.style_linebr)
plD3 = plot(pD3, "Lower T3", color.new(bearCol, 20), 1, plot.style_linebr)

fill(plH, plU1, color.new(bullCol, fillTr), "Bull Zone 1")
fill(plU1, plU2, color.new(bullCol, math.min(fillTr + 4, 98)), "Bull Zone 2")
fill(plU2, plU3, color.new(bullCol, math.min(fillTr + 8, 98)), "Bull Zone 3")
fill(plL, plD1, color.new(bearCol, fillTr), "Bear Zone 1")
fill(plD1, plD2, color.new(bearCol, math.min(fillTr + 4, 98)), "Bear Zone 2")
fill(plD2, plD3, color.new(bearCol, math.min(fillTr + 8, 98)), "Bear Zone 3")

int   trDir = oDir.get(5)
float trVal = showTrail and trDir != 0 ? oStp.get(5) : na
plot(trVal, "ATR Trailing Stop", trDir == 1 ? bullCol : bearCol, 2, plot.style_linebr)

barcolor(barColOn and live ? (close > orH ? bullCol : close < orL ? bearCol : color.new(rngCol, 30)) : na, title = "Range Position Bars")

//───────────────────────────────────────────────────────────────────────────────────────────────
// 9 · Last-bar rendering · OR volume profile, level labels, open-trade ladder
//───────────────────────────────────────────────────────────────────────────────────────────────
if barstate.islast
    for b in vpBoxes
        b.delete()
    vpBoxes.clear()
    for l in vpLines
        l.delete()
    vpLines.clear()
    for l in lvlLbls
        l.delete()
    lvlLbls.clear()
    for l in trLines
        l.delete()
    trLines.clear()
    for l in trLbls
        l.delete()
    trLbls.clear()

    bool vpDrawn = false
    // Two-tone opening-range volume profile (buy | sell), value area and POC
    if showVP and drawOk and orR > 0 and vpH.size() > 0
        float step = orR / vpRows
        array<float> rb = array.new<float>(vpRows, 0.0)
        array<float> rs = array.new<float>(vpRows, 0.0)
        for i = 0 to vpH.size() - 1
            float h  = vpH.get(i)
            float l  = vpL.get(i)
            float v  = vpV.get(i)
            float dd = vpD.get(i)
            float bu = math.max((v + dd) / 2.0, 0.0)
            float se = math.max((v - dd) / 2.0, 0.0)
            int   j0 = math.max(0, math.min(vpRows - 1, int(math.floor((l - orL) / step))))
            int   j1 = math.max(0, math.min(vpRows - 1, int(math.floor((h - orL) / step))))
            float r  = h - l
            for j = j0 to j1
                float lo = orL + j * step
                float ov = math.min(h, lo + step) - math.max(l, lo)
                float sh = r > 0 ? math.max(ov, 0.0) / r : 1.0 / (j1 - j0 + 1)
                rb.set(j, rb.get(j) + bu * sh)
                rs.set(j, rs.get(j) + se * sh)
        array<float> tot = array.new<float>(vpRows, 0.0)
        float tv = 0.0
        float mx = 0.0
        int   poc = 0
        for j = 0 to vpRows - 1
            float t = rb.get(j) + rs.get(j)
            tot.set(j, t)
            tv += t
            if t > mx
                mx  := t
                poc := j
        if mx > 0
            // Value area: expand from the POC toward the heavier neighbour until vaPct of volume is covered
            int   vaLo = poc
            int   vaHi = poc
            float acc  = tot.get(poc)
            while acc < tv * vaPct / 100.0 and (vaLo > 0 or vaHi < vpRows - 1)
                float nUp = vaHi < vpRows - 1 ? tot.get(vaHi + 1) : -1.0
                float nDn = vaLo > 0 ? tot.get(vaLo - 1) : -1.0
                if nUp >= nDn
                    vaHi += 1
                    acc  += nUp
                else
                    vaLo -= 1
                    acc  += nDn
            int x0 = bar_index + vpOff
            for j = 0 to vpRows - 1
                float t = tot.get(j)
                if t > 0
                    bool  inVA = j >= vaLo and j <= vaHi
                    int   trB  = j == poc ? 5 : inVA ? 35 : 68
                    int   wb   = int(math.round(rb.get(j) / mx * vpWidth))
                    int   ws   = int(math.round(rs.get(j) / mx * vpWidth))
                    float yT   = orL + (j + 1) * step - step * 0.06
                    float yB   = orL + j * step + step * 0.06
                    if wb > 0
                        vpBoxes.push(box.new(x0, yT, x0 + wb, yB, border_color = CLEAR, bgcolor = color.new(bullCol, trB)))
                    if ws > 0
                        vpBoxes.push(box.new(x0 + wb, yT, x0 + wb + ws, yB, border_color = j == poc ? color.new(pocCol, 20) : CLEAR, bgcolor = color.new(bearCol, trB)))
            float pocPx = orL + (poc + 0.5) * step
            vpLines.push(line.new(orStartBar, pocPx, x0, pocPx, color = color.new(pocCol, 30), style = line.style_dotted, width = 1))
            vpLines.push(line.new(x0 - 1, orL + (vaHi + 1) * step, x0 - 1, orL + vaLo * step, color = color.new(rngCol, 20), width = 2))
            lvlLbls.push(label.new(x0 + vpWidth + 1, pocPx, "POC " + f_px(pocPx) + " · VA " + str.tostring(vaPct) + "%", style = label.style_label_left, color = CLEAR, textcolor = pocCol, size = size.tiny, tooltip = "Opening-range point of control\nValue area " + f_px(orL + vaLo * step) + " – " + f_px(orL + (vaHi + 1) * step) + "\nSession Δ in OR " + f_sv(sDel)))
            vpDrawn := true

    // Level labels with historical hit rates
    if showLbls and drawOk
        int xL = bar_index + (vpDrawn ? vpOff + vpWidth + 2 : 3)
        int xR = xL
        lvlLbls.push(label.new(xR, orH, "OR HIGH  " + f_px(orH) + "  · brk " + f_pct(nBrkUp, nSess), style = label.style_label_left, color = color.new(rngCol, 15), textcolor = #0b0e15, size = size.small, tooltip = "Share of tracked sessions with a close above the OR high"))
        lvlLbls.push(label.new(xR, orL, "OR LOW  " + f_px(orL) + "  · brk " + f_pct(nBrkDn, nSess), style = label.style_label_left, color = color.new(rngCol, 15), textcolor = #0b0e15, size = size.small, tooltip = "Share of tracked sessions with a close below the OR low"))
        if showExt
            array<float>  ep = array.from(u1, u2, u3, d1, d2, d3)
            array<float>  em = array.from(f1, f2, f3, f1, f2, f3)
            for k = 0 to 5
                bool   up  = k < 3
                string nmK = "T" + str.tostring(k % 3 + 1) + (up ? " ▲ " : " ▼ ") + str.tostring(em.get(k), "#.###") + "×"
                string cnd = up ? f_pct(cntUF.get(k), nUpF) : f_pct(cntDF.get(k), nDnF)
                color  c   = up ? bullCol : bearCol
                lvlLbls.push(label.new(xL, ep.get(k), nmK + "  " + f_pct(cnt.get(k), nSess) + (dayHit.get(k) ? "  ✓" : ""), style = label.style_label_left, color = color.new(c, dayHit.get(k) ? 20 : 70), textcolor = color.white, size = size.small, tooltip = nmK + " at " + f_px(ep.get(k)) + "\nReached in " + f_pct(cnt.get(k), nSess) + " of " + str.tostring(nSess) + " sessions\nWhen the first break was " + (up ? "UP" : "DOWN") + ": " + cnd + "\nToday: " + (dayHit.get(k) ? "HIT" : "not yet")))

    // Latest open trade · entry / SL / TP ladder
    if showLvls and trades.size() > 0
        Trade t  = trades.last()
        int   x2 = bar_index + 3
        array<float>  pr = array.from(t.entry, t.sl, t.tp1, t.tp2, t.tp3)
        array<string> nm = array.from("ENTRY " + TN.get(t.typ), t.stage >= 2 and runTrail ? "TRAIL" : t.slMoved ? "SL · BE" : "SL", "TP1", "TP2", "TP3")
        for k = 0 to 4
            color lc   = k == 0 ? pocCol : k == 1 ? bearCol : bullCol
            bool  hitK = k >= 2 and t.stage >= k - 1
            float rK   = (pr.get(k) - t.entry) * t.dir / t.risk
            trLines.push(line.new(t.ebar, pr.get(k), x2, pr.get(k), color = color.new(lc, hitK ? 60 : 10), style = k == 0 ? line.style_dashed : line.style_solid, width = 1))
            trLbls.push(label.new(x2, pr.get(k), nm.get(k) + (k == 0 ? "" : " " + f_sn(rK, "#.0") + "R") + (hitK ? " ✓" : "") + "  " + f_px(pr.get(k)), style = label.style_label_left, color = CLEAR, textcolor = color.new(lc, hitK ? 50 : 0), size = size.tiny))

//───────────────────────────────────────────────────────────────────────────────────────────────
// 10 · Two-tier dashboard · five stacked panels with transparent separators
//───────────────────────────────────────────────────────────────────────────────────────────────
string dSize = dashSizeS == "Tiny" ? size.tiny : dashSizeS == "Normal" ? size.normal : dashSizeS == "Large" ? size.large : size.small
string dFont = monoFont ? font.family_monospace : font.family_default
string dPos  = switch dashPos
    "Top Right"    => position.top_right
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Middle Left"  => position.middle_left
    => position.bottom_left

var table dash = table.new(dPos, 9, 64, bgcolor = CLEAR, frame_width = 0, border_width = 0)

f_c(int c, int r, string tx, color tc, color bg, string ha, string tip) =>
    table.cell(dash, c, r, tx, text_color = tc, bgcolor = bg, text_halign = ha, text_size = dSize, text_font_family = dFont, tooltip = tip)

f_strip(int r, color ac) =>
    table.cell(dash, 0, r, "", bgcolor = ac, width = 0.3)

f_sep(int r) =>
    for c = 0 to 8
        table.cell(dash, c, r, "", bgcolor = CLEAR, height = sepH)
    table.merge_cells(dash, 0, r, 8, r)

f_head(int r, string title, string sub, color ac) =>
    f_strip(r, ac)
    f_c(1, r, title, TXT, HEAD, text.align_left, "")
    table.merge_cells(dash, 1, r, 5, r)
    f_c(6, r, sub, ac, HEAD, text.align_right, "")
    table.merge_cells(dash, 6, r, 8, r)

f_kv(int r, string k, string v, color vc, color ac, string tip) =>
    color bg = r % 2 == 0 ? PANEL : PANEL2
    f_strip(r, color.new(ac, 55))
    f_c(1, r, k, MUTED, bg, text.align_left, "")
    table.merge_cells(dash, 1, r, 3, r)
    f_c(4, r, v, vc, bg, text.align_right, tip)
    table.merge_cells(dash, 4, r, 8, r)

f_colhd(int r, array<string> hd, color ac) =>
    f_strip(r, color.new(ac, 55))
    for c = 1 to 8
        f_c(c, r, hd.get(c - 1), MUTED, COLHD, c == 1 ? text.align_left : text.align_right, "")

f_prow(int r, string nm, int n, int w, float sr, float gw, float gl, bool isOn, color ac, string tip) =>
    color bg  = r % 2 == 0 ? PANEL : PANEL2
    float wr  = n > 0 ? float(w) / n * 100.0 : 0.0
    float ar  = n > 0 ? sr / n : 0.0
    string pf = gl > 0 ? str.tostring(gw / gl, "#.00") : gw > 0 ? "∞" : "—"
    color wc  = n == 0 ? DIM : wr >= 55 ? bullCol : wr <= 45 ? bearCol : TXT
    f_strip(r, color.new(ac, 55))
    f_c(1, r, nm, isOn ? TXT : DIM, bg, text.align_left, tip)
    table.merge_cells(dash, 1, r, 2, r)
    f_c(3, r, isOn ? str.tostring(n) : "off", isOn ? TXT : DIM, bg, text.align_right, "")
    f_c(4, r, n > 0 ? str.tostring(wr, "#.0") + "%" : "—", wc, bg, text.align_right, "")
    f_c(5, r, n > 0 ? f_sn(ar, "#.00") : "—", n == 0 ? DIM : ar >= 0 ? bullCol : bearCol, bg, text.align_right, "")
    f_c(6, r, n > 0 ? pf : "—", n == 0 ? DIM : TXT, bg, text.align_right, "")
    f_c(7, r, n > 0 ? f_gauge(wr / 100.0, 6) : "", wc, bg, text.align_left, "")
    table.merge_cells(dash, 7, r, 8, r)

// Level row of the ORB matrix. key: 0-5 = extension index, 10 = OR high, 11 = OR mid, 12 = OR low
f_lrow(int r, int key, float px, color ac) =>
    color  bg  = r % 2 == 0 ? PANEL : PANEL2
    bool   isX = key < 10
    int    kx  = math.min(key, 5)
    bool   up  = isX ? key < 3 : key == 10
    color  lc  = isX ? (up ? bullCol : bearCol) : key == 11 ? MUTED : rngCol
    float  fm  = isX ? (key % 3 == 0 ? f1 : key % 3 == 1 ? f2 : f3) : na
    string nm  = isX ? "T" + str.tostring(key % 3 + 1) + (up ? " ▲ " : " ▼ ") + str.tostring(fm, "#.##") + "×" : key == 10 ? "OR HIGH" : key == 11 ? "OR MID" : "OR LOW"
    int    hN  = isX ? cnt.get(kx) : key == 10 ? nBrkUp : key == 12 ? nBrkDn : 0
    float  hit = f_frac(hN, nSess)
    string hS  = key == 11 ? "—" : f_pct(hN, nSess)
    string cS  = isX ? (up ? f_pct(cntUF.get(kx), nUpF) : f_pct(cntDF.get(kx), nDnF)) : key == 10 ? f_pct(nUpF, nSess) : key == 12 ? f_pct(nDnF, nSess) : "—"
    bool   tdy = isX ? dayHit.get(kx) : key == 10 ? dayBrkUp : key == 12 ? dayBrkDn : false
    f_strip(r, color.new(ac, 55))
    f_c(1, r, nm, lc, bg, text.align_left, isX ? "Extension target " + str.tostring(fm, "#.###") + "× the range beyond the edge" : key == 11 ? "Opening range midpoint" : "Opening range edge · rates are close-breaks")
    f_c(2, r, f_px(px), TXT, bg, text.align_right, "")
    f_c(3, r, na(px) ? "—" : f_sn((px - close) / atrV, "#.00"), MUTED, bg, text.align_right, "Distance from price in ATR")
    f_c(4, r, hS, key == 11 ? DIM : color.from_gradient(hit, 0.0, 1.0, MUTED, lc), bg, text.align_right, "Share of tracked sessions that reached this level")
    f_c(5, r, cS, key == 11 ? DIM : TXT, bg, text.align_right, isX ? "Hit rate on sessions whose FIRST close-break was on this side" : "Share of sessions whose first close-break was on this side")
    f_c(6, r, key == 11 ? "·" : tdy ? "✓" : "·", tdy ? lc : DIM, bg, text.align_center, "Reached in the current session")
    f_c(7, r, key == 11 ? "" : f_gauge(hit, 6), color.new(lc, 20), bg, text.align_left, "")
    table.merge_cells(dash, 7, r, 8, r)

if barstate.islast
    dash.clear(0, 0, 8, 63)
    if dashOn
        int  r       = 0
        bool needSep = false

        // ── PANEL I · TIER I · SESSION STATE ────────────────────────────────
        if showP1
            color ac = rngCol
            f_head(r, "◆ TIER I · SESSION STATE", syminfo.ticker + " · " + f_tfn(timeframe.period), ac)
            r += 1
            f_kv(r, "Session", sessInput + " · " + tzInput, TXT, ac, "Opening-range block and timezone. Window runs to " + endLbl + ".")
            r += 1
            string ph = inSession ? "◉ BUILDING · " + str.tostring(bar_index - orStartBar + 1) + " bars" : live ? "● LIVE · window to " + endLbl : orDone ? "○ CLOSED" : "○ WAITING · OR " + str.substring(orStartS, 0, 2) + ":" + str.substring(orStartS, 2, 4)
            f_kv(r, "Phase", ph, inSession ? rngCol : live ? bullCol : MUTED, ac, "")
            r += 1
            f_kv(r, "Opening Range", na(orH) ? "—" : "H " + f_px(orH) + " · L " + f_px(orL), rngCol, ac, "")
            r += 1
            float  wLive = na(orH) or na(dAtr) or dAtr <= 0 ? na : orR / dAtr * 100.0
            string clsS  = dayCls == 1 ? "NARROW" : dayCls == 3 ? "WIDE" : dayCls == 2 ? "NORMAL" : inSession ? "forming" : "—"
            f_kv(r, "OR Width", na(orH) ? "—" : f_px(orR) + (na(wLive) ? "" : " · " + str.tostring(wLive, "#") + "% ADR") + " · " + clsS + (na(orWPct) ? "" : " p" + str.tostring(orWPct, "#")), dayCls == 1 ? bullCol : dayCls == 3 ? bearCol : TXT, ac, "Width as % of the prior daily ATR(14), ranked against the last " + str.tostring(widthLook) + " sessions")
            r += 1
            string posS = na(orH) ? "—" : close > orH ? "▲ ABOVE " + f_sn((close - orH) / atrV, "#.00") + " ATR" : close < orL ? "▼ BELOW " + f_sn((close - orL) / atrV, "#.00") + " ATR" : "◆ INSIDE · " + str.tostring(orR > 0 ? (close - orL) / orR * 100 : 50, "#") + "% of range"
            f_kv(r, "Price vs Range", posS, na(orH) ? MUTED : close > orH ? bullCol : close < orL ? bearCol : rngCol, ac, "")
            r += 1
            string fbS = firstBreak == 0 ? (live ? "PENDING" : "—") : (firstBreak == 1 ? "▲ UP" : "▼ DOWN") + " · +" + str.tostring(firstBrkBar - orEndBar) + " bars" + (dayFake ? " · FAILED" : "")
            f_kv(r, "First Break", fbS, firstBreak == 1 ? bullCol : firstBreak == -1 ? bearCol : MUTED, ac, "Direction of the first close beyond the range, bars after the range completed")
            r += 1
            f_kv(r, "Session VWAP", na(sVwap) ? "—" : f_px(sVwap) + (close >= sVwap ? " · ▲ above" : " · ▼ below"), na(sVwap) ? MUTED : close >= sVwap ? bullCol : bearCol, ac, "Volume-weighted average price anchored at the OR open")
            r += 1
            f_kv(r, "HTF Bias · " + f_tfn(htfTf == "" ? timeframe.period : htfTf), htfBias == 1 ? "▲ BULL" : htfBias == -1 ? "▼ BEAR" : "◆ NEUTRAL", htfBias == 1 ? bullCol : htfBias == -1 ? bearCol : MUTED, ac, "Last closed HTF bar vs its EMA " + str.tostring(htfLen) + " and EMA slope (non-repainting)")
            r += 1
            float bp = sVol > 0 ? (sVol + sDel) / (2.0 * sVol) : 0.5
            f_kv(r, "Session Flow", f_gauge(bp, 10) + " " + str.tostring(math.round(math.max(bp, 1 - bp) * 100)) + "% " + (bp >= 0.5 ? "BUY" : "SELL") + " · Δ " + f_sv(sDel), bp >= 0.55 ? bullCol : bp <= 0.45 ? bearCol : TXT, ac, "Aggressive buy share and cumulative delta since the OR open")
            r += 1
            f_kv(r, "Delta Engine", usedLtf ? "INTRABAR · " + f_tfn(ltfTf) + " × " + str.tostring(nIntra) : "SYNTHETIC · " + (synthMdl == "Hybrid (CLV + Body)" ? "CLV+BODY" : synthMdl == "Body Ratio" ? "BODY" : "CLV"), usedLtf ? bullCol : TXT, ac, "Intrabar = lower-timeframe flow summed per bar. Synthetic = modelled from the chart bar.")
            r += 1
            string ls = na(lastSigBar) ? "—" : TN.get(math.max(lastSigTyp, 0)) + (lastSigDir == 1 ? " ▲ " : " ▼ ") + str.tostring(lastSigSc, "#.0") + " · " + str.tostring(bar_index - lastSigBar) + " bars ago"
            f_kv(r, "Last Signal · Today", ls + " · " + str.tostring(sigToday) + "/" + str.tostring(maxSigDay), na(lastSigBar) ? MUTED : lastSigDir == 1 ? bullCol : bearCol, ac, na(lastSigBar) ? "" : TF.get(math.max(lastSigTyp, 0)))
            r += 1
            if tfWarn
                f_kv(r, "⚠ Timeframe", not timeframe.isintraday ? "intraday chart required" : "bars longer than the OR · range approximated · use ≤ " + str.tostring(orMin) + "m", bearCol, ac, "On bars longer than the opening range, every bar that overlaps the range window forms the range, so it is wider than the true one.")
                r += 1
            needSep := true

        // ── PANEL II · TIER I · ORB LEVEL MATRIX (price ladder) ─────────────
        if showP2
            if needSep
                f_sep(r)
                r += 1
            color ac = pocCol
            f_head(r, "◆ TIER I · ORB LEVEL MATRIX", str.tostring(nSess) + " sessions", ac)
            r += 1
            f_colhd(r, array.from("LEVEL", "PRICE", "ATR", "HIT%", "IF 1ST", "TODAY", "EDGE", ""), ac)
            table.merge_cells(dash, 7, r, 8, r)
            r += 1
            array<float> lp = array.from(u3, u2, u1, orH, orM, orL, d1, d2, d3)
            array<int>   lk = array.from(2, 1, 0, 10, 11, 12, 3, 4, 5)
            if na(orH)
                f_strip(r, color.new(ac, 55))
                f_c(1, r, "no opening range yet · waiting for " + sessInput, DIM, PANEL, text.align_center, "")
                table.merge_cells(dash, 1, r, 8, r)
                r += 1
            else
                array<int> ord = lp.sort_indices(order.descending)
                bool priceDone = false
                for j = 0 to 8
                    int ix = ord.get(j)
                    if not priceDone and close >= lp.get(ix)
                        f_strip(r, ac)
                        f_c(1, r, "PRICE ◀", pocCol, PRICEBG, text.align_left, "")
                        f_c(2, r, f_px(close), pocCol, PRICEBG, text.align_right, "")
                        f_c(3, r, "ATR " + f_px(atrV), MUTED, PRICEBG, text.align_left, "")
                        table.merge_cells(dash, 3, r, 5, r)
                        f_c(6, r, "Δ " + f_sv(barDelta), barDelta >= 0 ? bullCol : bearCol, PRICEBG, text.align_right, "Current bar delta")
                        table.merge_cells(dash, 6, r, 8, r)
                        r += 1
                        priceDone := true
                    f_lrow(r, lk.get(ix), lp.get(ix), ac)
                    r += 1
                if not priceDone
                    f_strip(r, ac)
                    f_c(1, r, "PRICE ◀", pocCol, PRICEBG, text.align_left, "")
                    f_c(2, r, f_px(close), pocCol, PRICEBG, text.align_right, "")
                    f_c(3, r, "ATR " + f_px(atrV), MUTED, PRICEBG, text.align_left, "")
                    table.merge_cells(dash, 3, r, 5, r)
                    f_c(6, r, "Δ " + f_sv(barDelta), barDelta >= 0 ? bullCol : bearCol, PRICEBG, text.align_right, "Current bar delta")
                    table.merge_cells(dash, 6, r, 8, r)
                    r += 1
            needSep := true

        // ── PANEL III · TIER II · BREAKOUT ANALYTICS ────────────────────────
        if showP3
            if needSep
                f_sep(r)
                r += 1
            color ac = bullCol
            f_head(r, "◆ TIER II · BREAKOUT ANALYTICS", "R-model · SL-first", ac)
            r += 1
            f_strip(r, color.new(ac, 55))
            f_c(1, r, "TYPE", MUTED, COLHD, text.align_left, "")
            table.merge_cells(dash, 1, r, 2, r)
            f_c(3, r, "N", MUTED, COLHD, text.align_right, "")
            f_c(4, r, "WIN%", MUTED, COLHD, text.align_right, "")
            f_c(5, r, "AVG R", MUTED, COLHD, text.align_right, "")
            f_c(6, r, "PF", MUTED, COLHD, text.align_right, "")
            f_c(7, r, "EDGE", MUTED, COLHD, text.align_left, "")
            table.merge_cells(dash, 7, r, 8, r)
            r += 1
            array<bool> ons = array.from(enBRK, enRTST, enFAIL)
            for k = 0 to 2
                f_prow(r, TN.get(k), stN.get(k), stW.get(k), stR.get(k), stGW.get(k), stGL.get(k), ons.get(k), ac, TF.get(k))
                r += 1
            f_prow(r, "ALL", totN, totW, totR, totGW, totGL, true, ac, "All closed signal trades")
            r += 1
            f_kv(r, "Net R · Max DD", f_sn(totR, "#.00") + "R · −" + str.tostring(maxDD, "#.00") + "R", totR >= 0 ? bullCol : bearCol, ac, "Cumulative realized R and peak-to-trough drawdown of the closed-trade equity curve")
            r += 1
            f_kv(r, "Expectancy", totN > 0 ? f_sn(totR / totN, "#.000") + "R / trade" : "—", totN == 0 ? MUTED : totR >= 0 ? bullCol : bearCol, ac, "")
            r += 1
            f_kv(r, "Target Ladder", totN > 0 ? "TP1 " + f_pct(hit1, totN) + " · TP2 " + f_pct(hit2, totN) + " · TP3 " + f_pct(hit3, totN) : "—", TXT, ac, "Share of closed trades that reached each target")
            r += 1
            f_kv(r, "Exit Mix", totN > 0 ? "SL " + str.tostring(exSL) + " · STOP+ " + str.tostring(exBE) + " · TP3 " + str.tostring(exTP3) + " · END " + str.tostring(exEOD) : "—", TXT, ac, "SL = full stop before TP1 · STOP+ = breakeven or trailed stop after a target · END = window end or max hold")
            r += 1
            f_kv(r, "Streak · Open", (streak > 0 ? "W" + str.tostring(streak) : streak < 0 ? "L" + str.tostring(-streak) : "—") + " · " + str.tostring(trades.size()) + " open", streak > 0 ? bullCol : streak < 0 ? bearCol : MUTED, ac, "")
            r += 1
            f_strip(r, color.new(ac, 55))
            f_c(1, r, "every closed trade counted · same-bar ambiguity resolved against the trade", DIM, PANEL, text.align_center, "Entry at signal close. 1/3 off at each TP. Stop gaps fill at the open. Flattened at the window end.")
            table.merge_cells(dash, 1, r, 8, r)
            r += 1
            needSep := true

        // ── PANEL IV · TIER II · SESSION STATISTICS ─────────────────────────
        if showP4
            if needSep
                f_sep(r)
                r += 1
            color ac = bearCol
            f_head(r, "◆ TIER II · SESSION STATISTICS", "completed sessions", ac)
            r += 1
            f_kv(r, "Sessions Tracked", str.tostring(nSess) + (orDone and not finalized ? " · today live" : ""), TXT, ac, "Statistics are booked when a session's window closes, so today's partial session never inflates the rates")
            r += 1
            f_kv(r, "First Break", "▲ " + f_pct(nUpF, nSess) + " · ▼ " + f_pct(nDnF, nSess) + " · none " + f_pct(nNone, nSess), nUpF > nDnF ? bullCol : nDnF > nUpF ? bearCol : TXT, ac, "")
            r += 1
            f_kv(r, "Both Sides Broken", f_pct(nBoth, nSess), TXT, ac, "Sessions with a close beyond both edges · chop / two-way days")
            r += 1
            f_kv(r, "Failed First Break", f_pct(nFake, nUpF + nDnF), nFake * 2 > nUpF + nDnF ? bearCol : TXT, ac, "First close-breaks that closed back inside by the FAIL depth within the FAIL window")
            r += 1
            f_kv(r, "Avg Break Delay", nDelay > 0 ? str.tostring(float(sumDel) / nDelay, "#.0") + " bars after OR" : "—", TXT, ac, "")
            r += 1
            float avgW = orW.size() > 0 ? orW.avg() : na
            f_kv(r, "Avg OR Width", na(avgW) ? "—" : str.tostring(avgW, "#.0") + "% ADR" + (na(orWNow) ? "" : " · today " + str.tostring(orWNow, "#.0") + "%"), TXT, ac, "")
            r += 1
            f_kv(r, "T1 Reach · Narrow vs Wide", "NARROW " + f_pct(nNarT1, nNar) + " (" + str.tostring(nNar) + ") · WIDE " + f_pct(nWideT1, nWide) + " (" + str.tostring(nWide) + ")", f_frac(nNarT1, nNar) > f_frac(nWideT1, nWide) ? bullCol : TXT, ac, "Share of narrow-range (≤ p30) and wide-range (≥ p70) sessions in which either T1 was reached")
            r += 1
            needSep := true

        // ── PANEL V · TIER II · STOP OPTIMIZER ──────────────────────────────
        if showP5
            if needSep
                f_sep(r)
                r += 1
            color ac = rngCol
            f_head(r, "◆ TIER II · STOP OPTIMIZER", "ATR trail · ATR units", ac)
            r += 1
            f_colhd(r, array.from("STOP", "N", "WIN%", "NET", "AVG", "PF", "OPEN", ""), ac)
            table.merge_cells(dash, 7, r, 8, r)
            r += 1
            int   best  = 0
            float bestV = -1e10
            for i = 0 to 4
                if oN.get(i) > 0 and oNet.get(i) > bestV
                    bestV := oNet.get(i)
                    best  := i
            for i = 0 to 4
                color bg = r % 2 == 0 ? PANEL : PANEL2
                int   n  = oN.get(i)
                float nt = oNet.get(i)
                bool  isB = n > 0 and i == best
                string pf = oGL.get(i) > 0 ? str.tostring(oGW.get(i) / oGL.get(i), "#.00") : oGW.get(i) > 0 ? "∞" : "—"
                f_strip(r, color.new(ac, isB ? 0 : 55))
                f_c(1, r, str.tostring(optBase + i * optStep, "#.0#") + "× ATR" + (isB ? " ★" : ""), isB ? rngCol : TXT, bg, text.align_left, "")
                f_c(2, r, str.tostring(n), TXT, bg, text.align_right, "")
                f_c(3, r, n > 0 ? f_pct(oW.get(i), n) : "—", n == 0 ? DIM : TXT, bg, text.align_right, "")
                f_c(4, r, n > 0 ? f_sn(nt, "#.0") : "—", n == 0 ? DIM : nt >= 0 ? bullCol : bearCol, bg, text.align_right, "Net result in ATR units")
                f_c(5, r, n > 0 ? f_sn(nt / n, "#.00") : "—", n == 0 ? DIM : nt >= 0 ? bullCol : bearCol, bg, text.align_right, "")
                f_c(6, r, n > 0 ? pf : "—", n == 0 ? DIM : TXT, bg, text.align_right, "")
                f_c(7, r, oDir.get(i) == 1 ? "● LONG" : oDir.get(i) == -1 ? "● SHORT" : "", oDir.get(i) == 1 ? bullCol : bearCol, bg, text.align_left, "Position currently open")
                table.merge_cells(dash, 7, r, 8, r)
                r += 1
            f_kv(r, "Live Trail " + str.tostring(trailMult, "#.0#") + "×", oN.get(5) > 0 ? f_sn(oNet.get(5), "#.0") + " ATR · " + str.tostring(oN.get(5)) + " trades · " + f_pct(oW.get(5), oN.get(5)) : "—", oNet.get(5) >= 0 ? bullCol : bearCol, ac, "The trailing stop drawn on the chart, run on the same first breaks")
            r += 1
            f_strip(r, color.new(ac, 55))
            f_c(1, r, "first close-break per side · exit on close through the trail or at window end", DIM, PANEL, text.align_center, "")
            table.merge_cells(dash, 1, r, 8, r)

//───────────────────────────────────────────────────────────────────────────────────────────────
// Alerts
//───────────────────────────────────────────────────────────────────────────────────────────────
alertcondition(sigBull,            "Long Signal",               "SORB: long opening-range signal.")
alertcondition(sigBear,            "Short Signal",              "SORB: short opening-range signal.")
alertcondition(sigBull or sigBear, "Any Signal",                "SORB: opening-range signal.")
alertcondition(sigHigh,            "High-Conviction Signal",    "SORB: high-conviction opening-range signal.")
alertcondition(sigRtst,            "Retest Signal",             "SORB: break-and-retest signal.")
alertcondition(sigFail,            "Failed Breakout Signal",    "SORB: failed breakout fade signal.")
alertcondition(evBrkUp,            "Close Above OR",            "SORB: price closed above the opening range.")
alertcondition(evBrkDn,            "Close Below OR",            "SORB: price closed below the opening range.")
alertcondition(evOrDone,           "Opening Range Complete",    "SORB: the opening range is complete.")
alertcondition(evTUp1,             "Upper T1 Reached",          "SORB: upper target 1 reached.")
alertcondition(evTUp3,             "Upper T3 Reached",          "SORB: upper target 3 reached.")
alertcondition(evTDn1,             "Lower T1 Reached",          "SORB: lower target 1 reached.")
alertcondition(evTDn3,             "Lower T3 Reached",          "SORB: lower target 3 reached.")
````
