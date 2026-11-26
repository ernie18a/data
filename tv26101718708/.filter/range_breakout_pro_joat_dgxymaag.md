# Range Breakout Pro [JOAT]

- url: https://www.tradingview.com/script/DgXYMAAG-Range-Breakout-Pro-JOAT/
- type: indicator
- pine_id: PUB;e22838489b9c4efa98aad96549a49db0
- version: 1.0

## Description

[b]═══ RANGE BREAKOUT PRO [JOAT] ═══[/b]

[b]Range Breakout Pro[/b] is a universal breakout engine. It defines a reference range from the [b]Previous Day[/b], [b]Previous Week[/b], an [b]Initial Balance[/b] window, or a [b]Custom Session[/b], draws that range on the chart, and only fires a trade idea when price confirms a close beyond the edge. Every signal is scored [b]0–10[/b] for conviction and shipped with a full trade plan: stop, three R-multiple targets, and live outcome tracking.

[image]https://www.tradingview.com/x/t9qzXlWB/[/image]

[b]▎ WHAT IT DOES[/b]
It turns a simple "price broke the range" event into a structured, filtered, and scored decision. The chosen range basis is projected onto the current period as a box with edge rails and a midline. A confirmed break becomes a clean [b]LONG[/b] or [b]SHORT[/b] label with a stop, TP1/TP2/TP3 zones, and a running performance panel — all built to keep the chart readable.

[b]▎ HOW IT WORKS[/b]
— [b]Range basis[/b]: Previous Day / Previous Week project the prior completed period's high-low forward. Initial Balance and Custom Session accumulate the high-low inside a session window (in your chosen timezone) and lock the range at the window close.
— [b]Break detection[/b]: a bar must [i]close[/i] beyond the range edge, not just wick through it. In direct mode the close must clear the level by a [b]Break Buffer[/b] measured in ATR.
— [b]Optional retest[/b]: with retest confirmation on, price must break, pull back within a tolerance of the level, then close beyond it again before a signal arms — decisive reversals back through the level cancel the setup.
— [b]Strength score (0–10)[/b]: each candidate is graded on candle body dominance, candle range vs ATR, volume vs its average, 3- and 5-bar momentum agreement, penetration depth past the level, RSI posture, higher-timeframe trend alignment, whether it is the first break of the period, and range size vs ADR. The score maps to a ★ rank and a tier from FORMING to ELITE.
— [b]Filters/gates[/b]: minimum strength to signal, optional "strong only" threshold, HTF EMA trend alignment (longs above, shorts below), a range-vs-ADR gate (skip ranges too tight or too wide), and a max-signals-per-period cap.
— [b]Trade model[/b]: entry at the confirming close. Stop from [b]Structure[/b] (opposite range edge), [b]Mid[/b] (range midline), or [b]ATR[/b], with an ATR buffer plus min/max risk clamps. Targets are placed at your TP1/TP2/TP3 R-multiples off the measured risk.
— [b]Outcome engine[/b]: each trade is tracked bar by bar for TP1/TP2/TP3, stop, or end-of-period flatten, including same-bar stop handling, and the result feeds the stats panel.
— [b]VWAP overlay[/b]: session-anchored VWAP with ±1σ bands and an optional ±2σ outer channel, tinted to the side price is trading.

[b]▎ HOW TO USE IT[/b]
— Pick the range basis that fits your style: intraday traders often use Initial Balance or Custom Session; swing traders use Previous Day or Previous Week.
— Wait for a [b]LONG[/b] / [b]SHORT[/b] label. The ★ rank and score tell you how much confluence backed that break — treat higher tiers as higher conviction.
— The [b]entry line[/b] is the confirming close, the dashed line is the [b]stop[/b], and the three solid lines are targets tagged [b]🎯 TP1[/b], [b]🥈 TP2[/b], [b]🏆 TP3[/b]. The green zone is the reward area; the red zone is risk.
— Use the [b]range box, midline, and rails[/b] as context: reclaims of the midline, failed breaks, and edge retests are all readable at a glance.
— Layer the [b]VWAP bands[/b] as confluence — breakouts extending away from VWAP with room to the outer channel read differently than breaks stalling into a band.
— Result labels (TP / SL / EOP with the R outcome) close each idea so you can review what worked.

[b]▎ KEY SETTINGS[/b]
— [b]Engine[/b]: range basis, session timezone, IB / custom windows, retest toggle, break/retest tolerances, max signals per period.
— [b]Strength & Filters[/b]: ATR length, minimum score, strong-only threshold, HTF trend alignment (timeframe + EMA length), and the range-vs-ADR gate.
— [b]Trade Model[/b]: stop basis and buffer, ATR stop distance, min/max risk caps, TP1/2/3 in R, and how many past trades to keep drawn.
— [b]Visuals[/b]: Ice / Emerald / Mono theme, box, rails, midline, measured-move ×1/×2 guides, projection length, label size, and toggles for signal, lines, zones, level labels, and result labels.
— [b]VWAP & Candles[/b]: VWAP source, σ multiplier and lookback, outer channel, and optional RSI-gradient candles.
— [b]Dashboard[/b]: show/hide, position, text size, and the outcome breakdown row.

[b]▎ DASHBOARD[/b]
A chrome-accented panel reports the active range basis, current range size and % of ADR, price vs VWAP (with σ distance), engine status (forming / armed / trade active), the active and last signal with its score, and live stats: [b]win rate[/b], [b]profit factor[/b], average R per trade, long vs short win%, best direction, total signals, current and max streaks, plus an optional [b]TP1/TP2/TP3 · SL · EOP[/b] outcome breakdown.

[b]▎ ALERTS[/b]
— [b]RBP Long[/b] and [b]RBP Short[/b] on a confirmed, filtered breakout.
— [b]TP3 Hit[/b], [b]Partial TP[/b] (protected exit), [b]SL Hit[/b], and [b]EOP Exit[/b] (end-of-period flatten).

[b]▎ NOTES[/b]
— Works on any market and any timeframe.
— Higher-timeframe data uses confirmed prior values, so signals are evaluated on bar close and do not repaint after the fact.
— Clean-by-default: measured-move guides, extra rails, gradient candles, and the outer channel all sit behind toggles so you can strip the chart down or build it up.
— Drawn history (ranges and trades) is capped to keep the chart light.

[i]This tool is for research and education only. It is not financial advice. No indicator can predict the future, and any statistics shown reflect historical signals on your chart — past behavior does not guarantee future results. Always do your own analysis and manage your own risk.[/i]

[i]Made with passion by JackOfAllTrades ⚡[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Range Breakout Pro [JOAT]", shorttitle = "RBP [JOAT]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ============================================================================
//  RANGE BREAKOUT PRO [JOAT]
//  Universal breakout engine. Range basis: Previous Day / Previous Week /
//  Initial Balance / Custom Session. Draws a clean range box, edge rails and a
//  midline; confirmed closes beyond the range fire scored (0-10) BUY / SELL
//  label pills with ATR or structure stops and R-multiple TP1/2/3 target zones,
//  tracked for live stats. Session-anchored VWAP + σ bands/channel overlay and
//  optional gradient candles. Ice-blue / coral / slate-chrome identity.
//  Clean-by-default: measured-move guides and extra rails hide behind toggles.
// ============================================================================

// ─────────────────────────  01 · ENGINE  ────────────────────────────────────
gEng   = "01 · Engine"
basis    = input.string("Previous Day", "Range Basis", options = ["Previous Day", "Previous Week", "Initial Balance", "Custom Session"], group = gEng, tooltip = "What defines the breakout range.\nPrevious Day / Week: the prior completed period's high-low projected onto the current one.\nInitial Balance: the high-low of the first block of the session.\nCustom Session: the high-low of any session window you define.")
tzIn     = input.string("Exchange", "Session Timezone", options = ["Exchange", "UTC", "America/New_York", "Europe/London", "Asia/Tokyo"], group = gEng, tooltip = "Wall-clock zone used for Initial Balance / Custom Session windows. Exchange = the symbol's own timezone.")
ibSess   = input.session("0930-1030", "Initial Balance Window", group = gEng, tooltip = "The opening block that forms the range when Range Basis = Initial Balance.")
custSess = input.session("0000-0400", "Custom Session Window", group = gEng, tooltip = "The window that forms the range when Range Basis = Custom Session.")
useRetest= input.bool(false, "Require Retest Confirmation", group = gEng, tooltip = "ON: after price breaks the level it must pull back to it and then close beyond again.\nOFF: a single close beyond the level (by the buffer) is enough.")
breakBuf = input.float(0.05, "Break Buffer (× ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = gEng, tooltip = "Direct-mode: how far past the level the breakout close must be, in ATR.")
retestTol= input.float(0.30, "Retest Tolerance (× ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = gEng, tooltip = "Retest-mode: how close price must return to the level to count as a retest.")
maxPer   = input.int(1, "Max Signals / Period", minval = 1, maxval = 5, group = gEng)

// ─────────────────────────  02 · STRENGTH & FILTERS  ────────────────────────
gStr   = "02 · Strength & Filters"
atrLen   = input.int(14, "ATR Length", minval = 1, group = gStr)
minStr   = input.float(4.0, "Min Strength To Signal (0-10)", minval = 0, maxval = 10, step = 0.5, group = gStr, tooltip = "Reject breakouts scoring below this on the 0-10 conviction engine.")
onlyStrong = input.bool(false, "Only Take Strong Breakouts", group = gStr)
strongThr= input.float(7.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)
useHtf   = input.bool(true, "HTF Trend Alignment", group = gStr, tooltip = "Longs only above the HTF EMA, shorts only below it.")
htfTF    = input.timeframe("240", "HTF Timeframe", group = gStr)
htfEmaLen= input.int(50, "HTF EMA Length", minval = 5, maxval = 500, group = gStr)
useAdr   = input.bool(true, "Range-vs-ADR Gate", group = gStr, tooltip = "Skip ranges too tight or too wide relative to the average daily range.")
adrLen   = input.int(14, "ADR Lookback (days)", minval = 3, maxval = 60, group = gStr)
minAdrP  = input.float(15.0, "Min Range (% of ADR)", minval = 0, maxval = 200, step = 1, group = gStr)
maxAdrP  = input.float(120.0, "Max Range (% of ADR)", minval = 5, maxval = 400, step = 1, group = gStr)

// ─────────────────────────  03 · TRADE MODEL  ───────────────────────────────
gTr    = "03 · Trade Model"
slMode   = input.string("Structure", "Stop Basis", options = ["Structure", "ATR", "Mid"], group = gTr, tooltip = "Structure = opposite range edge. Mid = range midline. ATR = pure volatility stop.")
slBuf    = input.float(0.20, "Stop Buffer (× ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = gTr)
slAtrM   = input.float(1.30, "ATR Stop Distance (× ATR)", minval = 0.2, maxval = 6.0, step = 0.1, group = gTr, tooltip = "Used only when Stop Basis = ATR.")
maxRiskA = input.float(4.0, "Max Risk (× ATR) — cap", minval = 0.5, maxval = 12.0, step = 0.1, group = gTr)
minRiskA = input.float(0.4, "Min Risk (× ATR) — floor", minval = 0.1, maxval = 6.0, step = 0.1, group = gTr)
tp1R     = input.float(1.0, "TP1 (R)", minval = 0.3, maxval = 50, step = 0.1, group = gTr)
tp2R     = input.float(2.0, "TP2 (R)", minval = 0.3, maxval = 50, step = 0.1, group = gTr)
tp3R     = input.float(3.0, "TP3 (R)", minval = 0.3, maxval = 50, step = 0.1, group = gTr)
maxHist  = input.int(8, "Max Drawn Trades", minval = 1, maxval = 80, group = gTr, tooltip = "How many past trade drawings to keep. Kept low for a clean chart.")

// ─────────────────────────  04 · VISUALS  ───────────────────────────────────
gVis   = "04 · Visuals"
theme    = input.string("Ice", "Color Theme", options = ["Ice", "Emerald", "Mono"], group = gVis)
showBox  = input.bool(true, "Show Range Box", group = gVis)
showRails= input.bool(true, "Show Range Rails", group = gVis, tooltip = "The projected high/low edge lines. Turn off to leave just the box + labels.")
showMid  = input.bool(true, "Show Midline", group = gVis)
showMM   = input.bool(false, "Show Measured-Move ×1/×2 Guides", group = gVis, tooltip = "Extra projection targets above/below the range. Off by default to keep the chart clean.")
projLen  = input.int(80, "Projection Length (bars)", minval = 5, maxval = 400, group = gVis)
rangeKept= input.int(3, "Ranges Kept", minval = 1, maxval = 40, group = gVis, tooltip = "How many past ranges to keep drawn. Kept low for a clean chart.")
boxTransp= input.int(92, "Range Fill Transparency", minval = 60, maxval = 98, group = gVis)
showSig  = input.bool(true, "Show Signal Label", group = gVis)
showStars= input.bool(true, "Show ★ Rank On Signal", group = gVis)
showLines= input.bool(true, "Show SL / TP Lines", group = gVis)
showZones= input.bool(true, "Show SL / TP Zones", group = gVis)
showLvl  = input.bool(true, "Label Trade Levels", group = gVis)
showExit = input.bool(true, "Show Result Labels", group = gVis)
lblSizeOpt = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gVis)

// ─────────────────────────  05 · VWAP & CANDLES  ────────────────────────────
gVwap  = "05 · VWAP & Candles"
useVwap    = input.bool(true, "Show VWAP + σ Bands / Channel", group = gVwap, tooltip = "Session-anchored VWAP with ±1σ bands and a ±2σ outer channel, gradient-tinted to the side price is trading.")
vwapSrcOpt = input.string("hlc3", "VWAP Source", options = ["hlc3", "close", "ohlc4", "hl2"], group = gVwap)
vwapDev    = input.float(1.0, "Band σ Multiplier", minval = 0.5, maxval = 4.0, step = 0.5, group = gVwap)
vwapLen    = input.int(100, "σ Lookback", minval = 20, maxval = 400, group = gVwap, tooltip = "Bars used for the standard-deviation band width.")
showVwChan = input.bool(true, "Show ±2σ Outer Channel", group = gVwap)
colorCandles = input.bool(false, "Gradient Candles (RSI regime)", group = gVwap, tooltip = "Tints every candle red→blue by RSI momentum. Off by default for a clean chart.")

// ─────────────────────────  06 · DASHBOARD  ─────────────────────────────────
gDash  = "06 · Dashboard"
showDash = input.bool(true, "Show Dashboard", group = gDash)
dashPosOpt = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDash)
dashSizeOpt= input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = gDash)
showHeat = input.bool(true, "Show Outcome Breakdown", group = gDash)

// ─────────────────────────  THEME / PALETTE (Ice · Emerald · Mono)  ─────────
// Ice palette is deliberately distinct from the amber ORB reference.
longCol  = theme == "Emerald" ? color.rgb(46, 217, 160) : theme == "Mono" ? color.rgb(224, 224, 224) : color.rgb(41, 182, 246)  // #29B6F6 ice blue
shortCol = theme == "Emerald" ? color.rgb(255, 92, 122) : theme == "Mono" ? color.rgb(128, 128, 128) : color.rgb(255, 112, 67)  // #FF7043 coral
rangeCol = theme == "Emerald" ? color.rgb(56, 142, 120) : theme == "Mono" ? color.rgb(150, 150, 150) : color.rgb(100, 116, 139) // slate
accent   = theme == "Emerald" ? color.rgb(46, 217, 160) : theme == "Mono" ? color.rgb(210, 210, 210) : color.rgb(120, 190, 240)
tpFill   = theme == "Emerald" ? color.rgb(0, 110, 78) : theme == "Mono" ? color.rgb(70, 70, 70) : color.rgb(20, 90, 130)
slFill   = theme == "Emerald" ? color.rgb(170, 34, 44) : theme == "Mono" ? color.rgb(60, 60, 60) : color.rgb(190, 46, 58)   // red risk zone
chrome   = theme == "Emerald" ? color.rgb(186, 214, 200) : theme == "Mono" ? color.rgb(198, 205, 214) : color.rgb(190, 205, 222) // slate chrome

// Slate/white Bloomberg-style panel
color panelBg     = #0b0f14
color panelBgAlt  = #121821
color panelHdr    = #1a2431
color panelBorder = #24303b
color txtHi       = #e8eef4
color txtLo       = #7c8b9a
color neutralCol  = #64748b
color goodCol     = #2ec7a6
color badCol      = #ff5c7a
color warnCol     = #f2c14e

// ─────────────────────────  HELPERS  ────────────────────────────────────────
f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Right" => position.middle_right
        => position.top_right

f_stars(float sc) => sc >= 8.5 ? "★★★★★" : sc >= 7 ? "★★★★" : sc >= 5.5 ? "★★★" : sc >= 4 ? "★★" : sc >= 2.5 ? "★" : "·"
f_tier(float sc)  => sc >= 8.5 ? "ELITE" : sc >= 7 ? "VERY STRONG" : sc >= 5.5 ? "STRONG" : sc >= 4 ? "MODERATE" : sc >= 2.5 ? "WEAK" : "FORMING"
f_signedR(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "R"
f_px(float v) => str.tostring(v, format.mintick)

string tzUse = tzIn == "Exchange" ? syminfo.timezone : tzIn
bool isSessMode = basis == "Initial Balance" or basis == "Custom Session"
string sessStr = basis == "Initial Balance" ? ibSess : custSess

// ─────────────────────────  SERIES / SECURITY (global scope)  ───────────────
atr       = ta.atr(atrLen)
rsi       = ta.rsi(close, 14)
volSma    = ta.sma(volume, 20)
volRatio  = na(volume) or na(volSma) or volSma <= 0 ? 1.0 : volume / volSma
candleRng = high - low
bodyRatio = candleRng > 0 ? math.abs(close - open) / candleRng : 0.5
atrRatio  = atr > 0 ? candleRng / atr : 0.0
mom3 = close - close[3]
mom5 = close - close[5]

// Session-anchored VWAP + σ bands / channel (ta.* called every bar)
float vwapSrc = vwapSrcOpt == "close" ? close : vwapSrcOpt == "ohlc4" ? ohlc4 : vwapSrcOpt == "hl2" ? hl2 : hlc3
float vwapV = ta.vwap(vwapSrc)
float vwSd  = ta.stdev(close, vwapLen)
float vwUp1 = vwapV + vwapDev * vwSd
float vwLo1 = vwapV - vwapDev * vwSd
float vwUp2 = vwapV + vwapDev * 2.0 * vwSd
float vwLo2 = vwapV - vwapDev * 2.0 * vwSd

htfEma = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
adr    = request.security(syminfo.tickerid, "D", ta.sma(high - low, adrLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
pdH    = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
pdL    = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
pwH    = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
pwL    = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// Period boundary (used for range refresh, counters reset, EOP flatten)
bool wBoundary = ta.change(time("W")) != 0
bool dBoundary = ta.change(time("D")) != 0
bool boundaryReset = basis == "Previous Week" ? wBoundary : dBoundary

// Session tracking for IB / Custom modes
inSess    = isSessMode and not na(time(timeframe.period, sessStr, tzUse))
sessOpen  = inSess and not inSess[1]
sessClose = isSessMode and not inSess and inSess[1]

// ─────────────────────────  OBJECT TYPES  ───────────────────────────────────
type rViz
    box   bx
    line  hl
    line  ll
    line  ml
    line  u1
    line  u2
    line  d1
    line  d2
    label hlb
    label llb
    label mlb
    label u1b
    label u2b
    label d1b
    label d2b

type tViz
    line  en
    line  sl
    line  t1
    line  t2
    line  t3
    box   tb
    box   sb
    label sg
    label le
    label ls
    label l1
    label l2
    label l3
    label ex

var array<rViz> rHist = array.new<rViz>()
var array<tViz> trHist = array.new<tViz>()

// ─────────────────────────  RANGE STATE MACHINE  ────────────────────────────
var float rH = na
var float rL = na
var float rMid = na
var float rRange = na
var bool  rReady = false
var int   periodStartBar = na
var float accH = na
var float accL = na
var float adrAtSet = na
var int   sessEndBar = na

bool justFormed = false

// Non-session modes: refresh range from the prior completed period at each boundary
if boundaryReset and not isSessMode
    float nH = basis == "Previous Week" ? pwH : pdH
    float nL = basis == "Previous Week" ? pwL : pdL
    periodStartBar := bar_index
    if not na(nH) and not na(nL) and nH > nL
        rH := nH
        rL := nL
        rMid := (nH + nL) / 2
        rRange := nH - nL
        adrAtSet := adr
        rReady := true
        justFormed := true

// Session modes: accumulate high/low inside the window, lock it at the close
if isSessMode
    if sessOpen
        accH := high
        accL := low
        periodStartBar := bar_index
        rReady := false
    if inSess and not sessOpen and not na(accH)
        accH := math.max(accH, high)
        accL := math.min(accL, low)
    if sessClose and not na(accH) and accH > accL
        rH := accH
        rL := accL
        rMid := (accH + accL) / 2
        rRange := accH - accL
        adrAtSet := adr
        sessEndBar := bar_index - 1
        rReady := true
        justFormed := true

// Per-period trade counters
var int tradesThisPeriod = 0
var int dirThisPeriod = 0
if boundaryReset
    tradesThisPeriod := 0
    dirThisPeriod := 0

float adrPct = not na(rRange) and not na(adrAtSet) and adrAtSet > 0 ? rRange / adrAtSet * 100.0 : na

// ─────────────────────────  STRENGTH ENGINE (0-10)  ─────────────────────────
f_strength(bool isLong, float pen, float bdy, float atrR, float volR, float m3, float m5, float rsiv, bool htfOk, bool firstOfPeriod, float adrQ) =>
    s = 0.6
    s += bdy >= 0.80 ? 1.6 : bdy >= 0.65 ? 1.1 : bdy >= 0.50 ? 0.6 : 0.2
    s += atrR >= 1.8 ? 1.6 : atrR >= 1.3 ? 1.0 : atrR >= 1.0 ? 0.6 : 0.2
    s += volR >= 1.8 ? 1.4 : volR >= 1.4 ? 1.0 : volR >= 1.15 ? 0.5 : 0.0
    m3ok = (isLong and m3 > 0) or (not isLong and m3 < 0)
    m5ok = (isLong and m5 > 0) or (not isLong and m5 < 0)
    s += m3ok and m5ok ? 1.6 : m3ok or m5ok ? 0.7 : -0.4
    s += pen >= 0.5 ? 1.0 : pen >= 0.25 ? 0.6 : pen >= 0.1 ? 0.3 : 0.0
    rsiOk = (isLong and rsiv > 52) or (not isLong and rsiv < 48)
    s += rsiOk ? 0.5 : 0.0
    s += htfOk ? 1.4 : 0.0
    s += firstOfPeriod ? 0.8 : 0.0
    s += not na(adrQ) and adrQ >= 0.25 and adrQ <= 1.25 ? 0.5 : 0.0
    math.max(0.0, math.min(10.0, math.round(s * 10) / 10))

// ─────────────────────────  TRADE STATE  ────────────────────────────────────
var bool  tradeActive = false
var int   tradeSide = 0
var int   tradeBar = na
var float tEntry = na
var float tStop = na
var float tTp1 = na
var float tTp2 = na
var float tTp3 = na
var float tRisk = na
var int   bestStage = 0

var int   lastSide = 0
var float lastScore = na

var line  aEn = na
var line  aSl = na
var line  aT1 = na
var line  aT2 = na
var line  aT3 = na
var box   aTb = na
var box   aSb = na
var label aSg = na
var label aLe = na
var label aLs = na
var label aL1 = na
var label aL2 = na
var label aL3 = na
var label aEx = na

// Stats
var int   sTotal = 0
var int   sClosed = 0
var int   sWins = 0
var float sR = 0.0
var float sGW = 0.0
var float sGL = 0.0
var int   sLong = 0
var int   sLongW = 0
var int   sShort = 0
var int   sShortW = 0
var int   sTp1 = 0
var int   sTp2 = 0
var int   sTp3 = 0
var int   sSl = 0
var int   sEop = 0
var int   sCurW = 0
var int   sCurL = 0
var int   sMaxW = 0
var int   sMaxL = 0
var int   sStreak = 0

// ─────────────────────────  ACTIVE TRADE — extend drawings  ─────────────────
if tradeActive
    int rightNow = na(tradeBar) ? bar_index : math.min(bar_index, tradeBar + projLen)
    if showLines
        if not na(aEn)
            line.set_x2(aEn, rightNow)
        if not na(aSl)
            line.set_x2(aSl, rightNow)
        if not na(aT1)
            line.set_x2(aT1, rightNow)
        if not na(aT2)
            line.set_x2(aT2, rightNow)
        if not na(aT3)
            line.set_x2(aT3, rightNow)
    if showZones
        if not na(aTb)
            box.set_right(aTb, rightNow)
        if not na(aSb)
            box.set_right(aSb, rightNow)

// ─────────────────────────  TRADE MANAGEMENT / OUTCOMES  ─────────────────────
closedTp3 = false
closedSl  = false
closedTp  = false
closedEop = false

if tradeActive
    bool tp1Hit = tradeSide == 1 ? high >= tTp1 : low <= tTp1
    bool tp2Hit = tradeSide == 1 ? high >= tTp2 : low <= tTp2
    bool tp3Hit = tradeSide == 1 ? high >= tTp3 : low <= tTp3
    bool slHit  = tradeSide == 1 ? low  <= tStop : high >= tStop

    int stage = tp3Hit ? 3 : tp2Hit ? 2 : tp1Hit ? 1 : 0
    bool sameBarSl = slHit and stage > 0
    if stage > bestStage and not sameBarSl
        bestStage := stage

    bool finalTp3 = not sameBarSl and bestStage == 3
    bool finalSl  = slHit and (bestStage == 0 or sameBarSl)
    bool finalTp  = slHit and not sameBarSl and bestStage > 0 and bestStage < 3
    bool finalEop = boundaryReset and not (finalTp3 or finalSl or finalTp)

    if finalTp3 or finalSl or finalTp or finalEop
        float markR = tRisk > 0 ? (tradeSide == 1 ? (close - tEntry) / tRisk : (tEntry - close) / tRisk) : 0.0
        float eopR  = math.max(-1.0, math.min(tp3R, markR))
        float resR  = finalTp3 ? tp3R : finalTp and bestStage == 2 ? tp2R : finalTp and bestStage == 1 ? tp1R : finalSl ? -1.0 : eopR
        bool isWin = resR > 0

        closedTp3 := finalTp3
        closedSl  := finalSl
        closedTp  := finalTp
        closedEop := finalEop

        sClosed += 1
        sR += resR
        if isWin
            sWins += 1
            sGW += resR
            sCurW += 1
            sCurL := 0
            sMaxW := math.max(sMaxW, sCurW)
            sStreak := sCurW
        else
            sGL += math.abs(resR)
            sCurL += 1
            sCurW := 0
            sMaxL := math.max(sMaxL, sCurL)
            sStreak := -sCurL
        if tradeSide == 1
            sLong += 1
            sLongW += isWin ? 1 : 0
        else
            sShort += 1
            sShortW += isWin ? 1 : 0
        if finalTp3
            sTp3 += 1
        else if finalTp and bestStage == 2
            sTp2 += 1
        else if finalTp and bestStage == 1
            sTp1 += 1
        else if finalSl
            sSl += 1
        else
            sEop += 1

        int closeEdge = na(tradeBar) ? bar_index : math.max(tradeBar + 3, bar_index)
        if showLines
            if not na(aEn)
                line.set_x2(aEn, closeEdge)
            if not na(aSl)
                line.set_x2(aSl, closeEdge)
            if not na(aT1)
                line.set_x2(aT1, closeEdge)
            if not na(aT2)
                line.set_x2(aT2, closeEdge)
            if not na(aT3)
                line.set_x2(aT3, closeEdge)
        if showZones
            if not na(aTb)
                box.set_right(aTb, closeEdge)
            if not na(aSb)
                box.set_right(aSb, closeEdge)
        if showLvl
            if not na(aLe)
                label.set_x(aLe, closeEdge)
            if not na(aLs)
                label.set_x(aLs, closeEdge)
            if not na(aL1)
                label.set_x(aL1, closeEdge)
            if not na(aL2)
                label.set_x(aL2, closeEdge)
            if not na(aL3)
                label.set_x(aL3, closeEdge)

        float resPrice = finalTp3 ? tTp3 : finalTp and bestStage == 2 ? tTp2 : finalTp and bestStage == 1 ? tTp1 : finalSl ? tStop : close
        string resTxt = finalTp3 ? "🏆 TP3 ✔ " + f_signedR(resR) : finalTp ? "✔ TP" + str.tostring(bestStage) + " " + f_signedR(resR) : finalSl ? "🛑 SL ✘ -1R" : "⏱ EOP " + f_signedR(resR)
        color resCol = resR >= 0 ? longCol : shortCol
        bool arrowDown = tradeSide == 1 ? resR >= 0 : resR < 0
        if showExit
            aEx := label.new(closeEdge, resPrice, resTxt, style = arrowDown ? label.style_label_down : label.style_label_up, color = color.new(resCol, 0), textcolor = color.white, size = f_size(lblSizeOpt), text_formatting = text.format_bold)

        tViz tv = tViz.new(aEn, aSl, aT1, aT2, aT3, aTb, aSb, aSg, aLe, aLs, aL1, aL2, aL3, aEx)
        array.push(trHist, tv)
        while array.size(trHist) > maxHist
            tViz old = array.shift(trHist)
            if not na(old.en)
                line.delete(old.en)
            if not na(old.sl)
                line.delete(old.sl)
            if not na(old.t1)
                line.delete(old.t1)
            if not na(old.t2)
                line.delete(old.t2)
            if not na(old.t3)
                line.delete(old.t3)
            if not na(old.tb)
                box.delete(old.tb)
            if not na(old.sb)
                box.delete(old.sb)
            if not na(old.sg)
                label.delete(old.sg)
            if not na(old.le)
                label.delete(old.le)
            if not na(old.ls)
                label.delete(old.ls)
            if not na(old.l1)
                label.delete(old.l1)
            if not na(old.l2)
                label.delete(old.l2)
            if not na(old.l3)
                label.delete(old.l3)
            if not na(old.ex)
                label.delete(old.ex)

        aEn := na
        aSl := na
        aT1 := na
        aT2 := na
        aT3 := na
        aTb := na
        aSb := na
        aSg := na
        aLe := na
        aLs := na
        aL1 := na
        aL2 := na
        aL3 := na
        aEx := na

        tradeActive := false
        tradeSide := 0
        tradeBar := na
        tEntry := na
        tStop := na
        tTp1 := na
        tTp2 := na
        tTp3 := na
        tRisk := na
        bestStage := 0

// ─────────────────────────  BREAKOUT DETECTION + RETEST STATE  ───────────────
bool rawUp = rReady and not na(rH) and close > rH and close[1] <= rH
bool rawDn = rReady and not na(rL) and close < rL and close[1] >= rL

float penUp = atr > 0 ? (close - rH) / atr : 0.0
float penDn = atr > 0 ? (rL - close) / atr : 0.0

var int   armDir = 0
var float armLvl = na
var bool  armRetested = false

// Reset arming when the range refreshes
if justFormed or boundaryReset
    armDir := 0
    armLvl := na
    armRetested := false

if useRetest
    if rawUp and armDir == 0
        armDir := 1
        armLvl := rH
        armRetested := false
    else if rawDn and armDir == 0
        armDir := -1
        armLvl := rL
        armRetested := false
    if armDir == 1 and not na(armLvl) and low <= armLvl + retestTol * atr
        armRetested := true
    if armDir == -1 and not na(armLvl) and high >= armLvl - retestTol * atr
        armRetested := true
    // invalidate on a decisive reversal back through the level
    if armDir == 1 and not na(armLvl) and close < armLvl - retestTol * atr
        armDir := 0
    if armDir == -1 and not na(armLvl) and close > armLvl + retestTol * atr
        armDir := 0

bool triggerLong = useRetest ? (armDir == 1 and armRetested and close > armLvl) : (rawUp and (close - rH) >= breakBuf * atr)
bool triggerShort = useRetest ? (armDir == -1 and armRetested and close < armLvl) : (rawDn and (rL - close) >= breakBuf * atr)

// ─────────────────────────  FILTERS  ────────────────────────────────────────
bool htfOkUp = not useHtf or na(htfEma) or close > htfEma
bool htfOkDn = not useHtf or na(htfEma) or close < htfEma
bool adrOk   = not useAdr or (not na(adrPct) and adrPct >= minAdrP and adrPct <= maxAdrP)
bool firstOfPeriod = tradesThisPeriod == 0
bool dirAllowed = maxPer > 1 or dirThisPeriod == 0

float scUp = triggerLong ? f_strength(true, penUp, bodyRatio, atrRatio, volRatio, mom3, mom5, rsi, htfOkUp, firstOfPeriod, na(adrAtSet) or adrAtSet <= 0 ? na : rRange / adrAtSet) : 0.0
float scDn = triggerShort ? f_strength(false, penDn, bodyRatio, atrRatio, volRatio, mom3, mom5, rsi, htfOkDn, firstOfPeriod, na(adrAtSet) or adrAtSet <= 0 ? na : rRange / adrAtSet) : 0.0

bool sigLong  = triggerLong  and htfOkUp and adrOk and dirAllowed and scUp >= minStr and (not onlyStrong or scUp >= strongThr)
bool sigShort = triggerShort and htfOkDn and adrOk and dirAllowed and scDn >= minStr and (not onlyStrong or scDn >= strongThr)
sigShort := sigShort and not sigLong

bool gate = tradesThisPeriod < maxPer and not tradeActive and not na(atr)
bool closedAny = closedTp3 or closedSl or closedTp or closedEop
bool takeLong  = sigLong  and gate and not closedAny
bool takeShort = sigShort and gate and not closedAny

// ─────────────────────────  OPEN TRADE  ─────────────────────────────────────
if takeLong or takeShort
    bool isLong = takeLong
    int side = isLong ? 1 : -1
    float sc = isLong ? scUp : scDn
    float entv = close
    float rawStop = slMode == "ATR" ? (isLong ? entv - atr * slAtrM : entv + atr * slAtrM) : slMode == "Mid" ? (isLong ? rMid - atr * slBuf : rMid + atr * slBuf) : (isLong ? rL - atr * slBuf : rH + atr * slBuf)
    float risk0 = math.abs(entv - rawStop)
    float maxR = atr * maxRiskA
    float minR = atr * minRiskA
    float risk = math.min(math.max(risk0, minR), maxR)
    float stopv = isLong ? entv - risk : entv + risk
    float t1 = isLong ? entv + risk * tp1R : entv - risk * tp1R
    float t2 = isLong ? entv + risk * tp2R : entv - risk * tp2R
    float t3 = isLong ? entv + risk * tp3R : entv - risk * tp3R

    tradeActive := true
    tradeSide := side
    tradeBar := bar_index
    tEntry := entv
    tStop := stopv
    tTp1 := t1
    tTp2 := t2
    tTp3 := t3
    tRisk := risk
    bestStage := 0
    lastSide := side
    lastScore := sc
    sTotal += 1
    tradesThisPeriod += 1
    dirThisPeriod := side
    armDir := 0

    color c = isLong ? longCol : shortCol
    int xr = bar_index + math.min(projLen, 30)

    // ONE clean signal label pill (ATR-scaled offset) — no triangles, no duplicate
    if showSig
        float lblY = isLong ? low - atr * 0.5 : high + atr * 0.5
        string head = isLong ? "▲ RBP LONG" : "▼ RBP SHORT"
        string txt = showStars ? head + "\n" + f_stars(sc) + "  " + str.tostring(math.round(sc * 10) / 10) + "/10  " + f_tier(sc) : head
        aSg := label.new(bar_index, lblY, txt, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(c, 6), textcolor = color.white, size = f_size(lblSizeOpt), text_formatting = text.format_bold)

    // TP reward zone + red risk zone (capped cleanup below)
    if showZones
        float tpTop = isLong ? t3 : entv
        float tpBot = isLong ? entv : t3
        float slTop = isLong ? entv : stopv
        float slBot = isLong ? stopv : entv
        aTb := box.new(bar_index, tpTop, xr, tpBot, xloc = xloc.bar_index, bgcolor = color.new(tpFill, 84), border_color = color.new(c, 45), border_width = 1)
        aSb := box.new(bar_index, slTop, xr, slBot, xloc = xloc.bar_index, bgcolor = color.new(slFill, 82), border_color = color.new(slFill, 45), border_width = 1)

    if showLines
        aEn := line.new(bar_index, entv,  xr, entv,  xloc = xloc.bar_index, color = color.new(c, 0), width = 2, style = line.style_solid)
        aSl := line.new(bar_index, stopv, xr, stopv, xloc = xloc.bar_index, color = color.new(slFill, 0), width = 1, style = line.style_dashed)
        aT1 := line.new(bar_index, t1, xr, t1, xloc = xloc.bar_index, color = color.new(c, 12), width = 1, style = line.style_solid)
        aT2 := line.new(bar_index, t2, xr, t2, xloc = xloc.bar_index, color = color.new(c, 32), width = 1, style = line.style_solid)
        aT3 := line.new(bar_index, t3, xr, t3, xloc = xloc.bar_index, color = color.new(c, 50), width = 1, style = line.style_solid)
        // chrome-tag trade level labels — TP1/2/3 get unique medal touches
        if showLvl
            string dw = isLong ? "LONG" : "SHORT"
            aLe := label.new(xr, entv,  dw + " @ " + f_px(entv), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 0), textcolor = color.white, size = f_size(lblSizeOpt), text_formatting = text.format_bold)
            aLs := label.new(xr, stopv, "SL @ " + f_px(stopv), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(slFill, 0), textcolor = color.white, size = f_size(lblSizeOpt))
            aL1 := label.new(xr, t1, "🎯 TP1  " + str.tostring(tp1R, "#.#") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 12), textcolor = color.white, size = f_size(lblSizeOpt), text_formatting = text.format_bold)
            aL2 := label.new(xr, t2, "🥈 TP2  " + str.tostring(tp2R, "#.#") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 28), textcolor = color.white, size = f_size(lblSizeOpt), text_formatting = text.format_bold)
            aL3 := label.new(xr, t3, "🏆 TP3  " + str.tostring(tp3R, "#.#") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 44), textcolor = color.white, size = f_size(lblSizeOpt), text_formatting = text.format_bold)

// ─────────────────────────  DRAW RANGE (on formation)  ──────────────────────
if justFormed and not na(rH) and not na(periodStartBar)
    int leftB = periodStartBar
    int rightB = isSessMode and not na(sessEndBar) ? sessEndBar : periodStartBar + projLen
    int projR = isSessMode and not na(sessEndBar) ? sessEndBar + projLen : periodStartBar + projLen

    box bx0 = na
    line hl0 = na
    line ll0 = na
    line ml0 = na
    line u10 = na
    line u20 = na
    line d10 = na
    line d20 = na
    label hlb0 = na
    label llb0 = na
    label mlb0 = na
    label u1b0 = na
    label u2b0 = na
    label d1b0 = na
    label d2b0 = na

    if showBox
        bx0 := box.new(leftB, rH, rightB, rL, xloc = xloc.bar_index, bgcolor = color.new(rangeCol, boxTransp), border_color = color.new(rangeCol, 45), border_width = 1)

    if showRails
        hl0 := line.new(leftB, rH, projR, rH, xloc = xloc.bar_index, color = color.new(longCol, 0), width = 2, style = line.style_solid)
        ll0 := line.new(leftB, rL, projR, rL, xloc = xloc.bar_index, color = color.new(shortCol, 0), width = 2, style = line.style_solid)

    if showMid
        ml0 := line.new(leftB, rMid, projR, rMid, xloc = xloc.bar_index, color = color.new(rangeCol, 25), width = 1, style = line.style_dotted)

    // Compact edge labels — range size / ADR% live in the dashboard, not on the chart
    hlb0 := label.new(projR, rH, "R-HIGH  " + f_px(rH), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(longCol, 82), textcolor = longCol, size = f_size(lblSizeOpt))
    llb0 := label.new(projR, rL, "R-LOW  " + f_px(rL), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 82), textcolor = shortCol, size = f_size(lblSizeOpt))
    if showMid
        mlb0 := label.new(projR, rMid, "MID", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(rangeCol, 90), textcolor = rangeCol, size = size.tiny)

    if showMM
        float u1 = rH + rRange
        float u2 = rH + rRange * 2.0
        float d1 = rL - rRange
        float d2 = rL - rRange * 2.0
        u10 := line.new(rightB, u1, projR, u1, xloc = xloc.bar_index, color = color.new(longCol, 55), width = 1, style = line.style_dotted)
        u20 := line.new(rightB, u2, projR, u2, xloc = xloc.bar_index, color = color.new(longCol, 68), width = 1, style = line.style_dotted)
        d10 := line.new(rightB, d1, projR, d1, xloc = xloc.bar_index, color = color.new(shortCol, 55), width = 1, style = line.style_dotted)
        d20 := line.new(rightB, d2, projR, d2, xloc = xloc.bar_index, color = color.new(shortCol, 68), width = 1, style = line.style_dotted)
        u1b0 := label.new(projR, u1, "MM ×1", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(longCol, 90), textcolor = longCol, size = size.tiny)
        u2b0 := label.new(projR, u2, "MM ×2", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(longCol, 90), textcolor = longCol, size = size.tiny)
        d1b0 := label.new(projR, d1, "MM ×1", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 90), textcolor = shortCol, size = size.tiny)
        d2b0 := label.new(projR, d2, "MM ×2", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 90), textcolor = shortCol, size = size.tiny)

    rViz rv = rViz.new(bx0, hl0, ll0, ml0, u10, u20, d10, d20, hlb0, llb0, mlb0, u1b0, u2b0, d1b0, d2b0)
    array.push(rHist, rv)
    while array.size(rHist) > rangeKept
        rViz od = array.shift(rHist)
        if not na(od.bx)
            box.delete(od.bx)
        if not na(od.hl)
            line.delete(od.hl)
        if not na(od.ll)
            line.delete(od.ll)
        if not na(od.ml)
            line.delete(od.ml)
        if not na(od.u1)
            line.delete(od.u1)
        if not na(od.u2)
            line.delete(od.u2)
        if not na(od.d1)
            line.delete(od.d1)
        if not na(od.d2)
            line.delete(od.d2)
        if not na(od.hlb)
            label.delete(od.hlb)
        if not na(od.llb)
            label.delete(od.llb)
        if not na(od.mlb)
            label.delete(od.mlb)
        if not na(od.u1b)
            label.delete(od.u1b)
        if not na(od.u2b)
            label.delete(od.u2b)
        if not na(od.d1b)
            label.delete(od.d1b)
        if not na(od.d2b)
            label.delete(od.d2b)

// ─────────────────────────  VWAP · GRADIENT CANDLES · SHADING (global col 0)  ─
// VWAP center + σ bands + ±2σ channel, gradient-tinted to the trading side.
color vwSide = close >= vwapV ? longCol : shortCol
plot(useVwap ? vwapV : na, "VWAP", color = color.new(chrome, 0), linewidth = 2)
pU1 = plot(useVwap ? vwUp1 : na, "VWAP +σ", color = color.new(vwSide, 62), linewidth = 1)
pL1 = plot(useVwap ? vwLo1 : na, "VWAP -σ", color = color.new(vwSide, 62), linewidth = 1)
pU2 = plot(useVwap and showVwChan ? vwUp2 : na, "VWAP +2σ", color = color.new(vwSide, 80), linewidth = 1)
pL2 = plot(useVwap and showVwChan ? vwLo2 : na, "VWAP -2σ", color = color.new(vwSide, 80), linewidth = 1)
fill(pU1, pL1, color = useVwap ? color.new(vwSide, 90) : na, title = "VWAP σ Band")
fill(pU2, pU1, color = useVwap and showVwChan ? color.new(vwSide, 94) : na, title = "VWAP Upper Channel")
fill(pL1, pL2, color = useVwap and showVwChan ? color.new(vwSide, 94) : na, title = "VWAP Lower Channel")

// Gradient candles — red→blue by RSI regime (idiom #3), default OFF
color barCol = na
if colorCandles
    barCol := color.from_gradient(rsi, 35.0, 65.0, color.new(shortCol, 25), color.new(longCol, 25))
barcolor(barCol, title = "Gradient Candles")

bgcolor(inSess ? color.new(rangeCol, 95) : na, title = "Session Window Shade")

// ─────────────────────────  STATS DERIVED  ──────────────────────────────────
winRate = sClosed > 0 ? 100.0 * sWins / sClosed : 0.0
avgR    = sClosed > 0 ? sR / sClosed : 0.0
pf      = sGL > 0 ? sGW / sGL : sGW > 0 ? 999.0 : 0.0
longWR  = sLong  > 0 ? 100.0 * sLongW  / sLong  : 0.0
shortWR = sShort > 0 ? 100.0 * sShortW / sShort : 0.0
tp1Rate = sClosed > 0 ? 100.0 * sTp1 / sClosed : 0.0
tp2Rate = sClosed > 0 ? 100.0 * sTp2 / sClosed : 0.0
tp3Rate = sClosed > 0 ? 100.0 * sTp3 / sClosed : 0.0
slRate  = sClosed > 0 ? 100.0 * sSl  / sClosed : 0.0
eopRate = sClosed > 0 ? 100.0 * sEop / sClosed : 0.0

bestDir = sLong == 0 and sShort == 0 ? "—" : sLong > 0 and sShort == 0 ? "LONG" : sShort > 0 and sLong == 0 ? "SHORT" : longWR > shortWR ? "LONG" : shortWR > longWR ? "SHORT" : "EVEN"
pfTxt = pf >= 999.0 ? "INF" : str.tostring(pf, "#.##")

basisShort = basis == "Previous Day" ? "PREV DAY" : basis == "Previous Week" ? "PREV WEEK" : basis == "Initial Balance" ? "INIT BALANCE" : "CUSTOM SESS"
statusTxt = tradeActive ? "TRADE ACTIVE" : rReady ? "ARMED" : inSess ? "FORMING RANGE" : "WAITING"
activeTxt = tradeActive ? (tradeSide == 1 ? "LONG" : "SHORT") : "—"
lastTxt = lastSide == 1 ? "LONG" : lastSide == -1 ? "SHORT" : "—"
lastScoreTxt = na(lastScore) ? "—" : f_stars(lastScore) + " " + str.tostring(math.round(lastScore * 10) / 10) + "/10"
sizeTxt = na(rRange) ? "—" : f_px(rRange)
adrPctTxt = na(adrPct) ? "—" : str.tostring(adrPct, "#.#") + "%"

float vwDist = not na(vwapV) and vwSd > 0 ? (close - vwapV) / vwSd : na
vwSideTxt = na(vwapV) ? "—" : (close >= vwapV ? "ABOVE" : "BELOW") + (na(vwDist) ? "" : "  " + (vwDist >= 0 ? "+" : "") + str.tostring(vwDist, "#.#") + "σ")

color statusC = tradeActive ? accent : rReady ? goodCol : neutralCol
color wrC = winRate >= 55 ? goodCol : winRate >= 45 ? warnCol : badCol
color pfC = pf >= 1.5 ? goodCol : pf >= 1.0 ? warnCol : badCol
color adrC = na(adrPct) ? txtLo : (adrPct >= minAdrP and adrPct <= maxAdrP) ? goodCol : warnCol
color vwC  = na(vwapV) ? neutralCol : close >= vwapV ? longCol : shortCol

// ─────────────────────────  DASHBOARD  ──────────────────────────────────────
var int dashRows = 15
var table dash = table.new(f_pos(dashPosOpt), 2, dashRows, frame_color = color.new(panelBorder, 0), frame_width = 1, border_width = 1, border_color = color.new(panelBorder, 20))

if barstate.islast and showDash
    ps = f_size(dashSizeOpt)
    table.clear(dash, 0, 0, 1, dashRows - 1)

    // Gradient / chrome header — bold + italic (idiom #5)
    table.cell(dash, 0, 0, "RANGE BREAKOUT PRO", text_color = #0b0f14, text_size = ps, text_halign = text.align_left, bgcolor = accent)
    table.cell(dash, 1, 0, basisShort, text_color = #0b0f14, text_size = ps, text_halign = text.align_center, bgcolor = chrome)
    table.cell_set_text_formatting(dash, 0, 0, text.format_bold + text.format_italic)
    table.cell_set_text_formatting(dash, 1, 0, text.format_bold + text.format_italic)

    table.cell(dash, 0, 1, "Range Size", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 1, sizeTxt, text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 2, "% of ADR", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 2, adrPctTxt, text_color = adrC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 3, "vs VWAP", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 3, vwSideTxt, text_color = vwC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 4, "Status", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 4, statusTxt, text_color = statusC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 5, "Active Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 5, activeTxt, text_color = tradeSide == 1 ? longCol : tradeSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 6, "Last Signal", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 6, lastTxt + "  " + lastScoreTxt, text_color = lastSide == 1 ? longCol : lastSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 7, "Win Rate", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 7, str.tostring(winRate, "#.#") + "%  (" + str.tostring(sClosed) + ")", text_color = wrC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 8, "Profit Factor", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 8, pfTxt, text_color = pfC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 9, "Avg R / Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 9, f_signedR(avgR), text_color = avgR >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 10, "L / S Win%", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 10, str.tostring(longWR, "#.#") + " / " + str.tostring(shortWR, "#.#"), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 11, "Best Direction", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 11, bestDir, text_color = bestDir == "LONG" ? longCol : bestDir == "SHORT" ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 12, "Total Signals", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 12, str.tostring(sTotal), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 13, "Streak (maxW/L)", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 13, (sStreak > 0 ? "W" + str.tostring(sStreak) : sStreak < 0 ? "L" + str.tostring(math.abs(sStreak)) : "—") + "  (" + str.tostring(sMaxW) + "/" + str.tostring(sMaxL) + ")", text_color = sStreak >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    if showHeat
        table.cell(dash, 0, 14, "TP1/2/3·SL·EOP", text_color = #0b0f14, text_size = ps, text_halign = text.align_left, bgcolor = rangeCol)
        table.cell(dash, 1, 14, str.tostring(tp1Rate, "#") + "/" + str.tostring(tp2Rate, "#") + "/" + str.tostring(tp3Rate, "#") + "·" + str.tostring(slRate, "#") + "·" + str.tostring(eopRate, "#"), text_color = #0b0f14, text_size = ps, text_halign = text.align_center, bgcolor = rangeCol)
    else
        table.cell(dash, 0, 14, "", bgcolor = panelHdr)
        table.cell(dash, 1, 14, "", bgcolor = panelHdr)

// ─────────────────────────  ALERTS  ─────────────────────────────────────────
alertcondition(takeLong,  "RBP Long",   "Range Breakout Pro: LONG breakout of the range on {{ticker}} {{interval}}.")
alertcondition(takeShort, "RBP Short",  "Range Breakout Pro: SHORT breakout of the range on {{ticker}} {{interval}}.")
alertcondition(closedTp3, "TP3 Hit",    "Range Breakout Pro: TP3 reached on {{ticker}} {{interval}}.")
alertcondition(closedTp,  "Partial TP", "Range Breakout Pro: protected TP exit on {{ticker}} {{interval}}.")
alertcondition(closedSl,  "SL Hit",     "Range Breakout Pro: stop-loss on {{ticker}} {{interval}}.")
alertcondition(closedEop, "EOP Exit",   "Range Breakout Pro: end-of-period flatten on {{ticker}} {{interval}}.")
````
