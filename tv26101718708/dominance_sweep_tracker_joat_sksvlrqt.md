# Dominance Sweep Tracker [JOAT]

- url: https://www.tradingview.com/script/SksvlRqT-Dominance-Sweep-Tracker-JOAT/
- type: indicator
- pine_id: PUB;90bf6df0285e4eb8861d9c25dc55be9d
- version: 1.0

## Description

[b]Dominance Sweep Tracker [JOAT][/b]

[b]Introduction[/b]

Dominance Sweep Tracker (DST) is an open-source, institutional-grade order flow engine that combines three detection layers — market structure dominance, liquidity sweep identification, and order block entry confirmation — into a single, unified trading framework. It tracks confirmed swing pivots, identifies when body-close breaks through those levels signal a structural shift in market dominance, detects liquidity sweeps where wicks pierce prior pivots and price closes back inside, and marks the last opposing candle before each sweep as the entry order block. ATR-based trade visualizations with risk/reward boxes and per-session win rate tracking complete the system.

The core problem DST solves is the fragmentation of ICT order flow analysis across multiple manual steps. Traders watching for structural dominance shifts, hunting sweeps of prior swing liquidity, and locating order block entries typically need to perform those three steps separately, often missing the interaction between them. DST connects all three into a single detection pipeline that fires on confirmed bars, identifies the relevant entry zone automatically, and tracks the resulting trade outcome against configurable TP and SL levels across four distinct trading sessions.

[image]https://www.tradingview.com/x/ZVPzZ5ny/[/image]

[b]Core Concepts[/b]

[b]1. Swing Pivot Detection[/b]

DST uses Pine Script's built-in ta.pivothigh() and ta.pivotlow() functions to identify confirmed swing highs and lows. These are inherently non-repainting — a pivot is only confirmed after the required number of bars on both sides have formed. The most recent confirmed swing high and low are stored as the active liquidity levels.

[b]2. Market Dominance Detection[/b]

A dominance shift occurs when a bar's body — not its wick — closes beyond a confirmed swing level. Bullish dominance is confirmed when the close exceeds the most recent swing high. Bearish dominance is confirmed when the close falls below the most recent swing low. This body-close requirement eliminates wick-based false breaks and isolates genuine structural displacement:

[pine]
bool bullDom = close > swingHi and open > swingHi[1]
bool bearDom = close < swingLo and open < swingLo[1]
[/pine]

[b]3. Liquidity Sweep Detection[/b]

A sweep occurs when a bar's wick pierces a prior swing level and the close returns back inside. DST applies a minimum wick depth filter (default: 0.2 ATR) to avoid noise from trivial touches. A bullish sweep fires when the low exceeds the swing low but the close is above it. A bearish sweep fires when the high exceeds the swing high but the close is below it. Both are gated on barstate.isconfirmed.

[b]4. Order Block from Last Opposing Candle[/b]

When a sweep is confirmed, DST scans back through recent bars to identify the last candle that moved in the opposite direction of the sweep. For a bullish sweep setup (price swept below a low and recovered), the last bearish candle before the sweep is marked as the entry order block. This zone represents the origin of the move that created the liquidity pool — the level where institutional positioning likely occurred.

[b]5. Session-Aware Trade Tracking[/b]

Each detected signal is tagged with the trading session active at that bar (Asia, London, NY, or Off-Session). ATR-based stop loss and take profit levels are calculated at signal time and visualized as color-coded boxes. Outcome is tracked against those levels, and win/loss counters are maintained per session for statistical context.

[b]Features[/b]

[list]
[*][b]Swing Pivot Tracking:[/b] Confirmed swing highs and lows rendered as horizontal reference lines — the primary liquidity pool levels
[*][b]Body-Close Dominance Detection:[/b] Structural breaks confirmed only on candle body close beyond swing level, eliminating wick-false-break noise
[*][b]Liquidity Sweep Detection:[/b] Wick-beyond, close-inside detection across all recent pivots with configurable ATR depth filter
[*][b]ATR Wick Filter:[/b] Minimum wick penetration depth prevents noise from triggering sweep signals on trivial pokes
[*][b]Order Block Identification:[/b] Automatic scan of last opposing candle before each sweep — rendered as a colored zone box
[*][b]OB Touch Signal:[/b] Secondary signal fires when price returns to touch an active order block zone
[*][b]EMA 750 Trend Filter:[/b] Optional filter that requires price to be on the correct side of the EMA 750 for long and short signals
[*][b]ATR-Based TP/SL Boxes:[/b] Risk (SL) and reward (TP) areas visualized as colored boxes from entry — default 1.5× ATR stop, 3:1 reward
[*][b]Session Detection:[/b] Asia, London, NY, and Off-Session windows (configurable) tag each signal for session-specific tracking
[*][b]Per-Session Win Rate:[/b] Independent win/loss/total counters for all four sessions displayed in the dashboard
[*][b]Non-Repainting:[/b] All signals gated on barstate.isconfirmed; ta.pivothigh/ta.pivotlow inherently confirmed
[*][b]Dashboard (Top Right):[/b] Session win rates for Asia, London, NY, and Off-Session with color-coded performance indicators
[*][b]BOS Dominance Labels:[/b] "BOS ▲" and "BOS ▼" dominance labels replace simple B/S markers — clearly communicates the direction of each confirmed structural break on the chart
[*][b]Order Block Dominance Labels:[/b] "BULL DOM" and "BEAR DOM" labels placed inside order block boxes at creation — identifies the structural context in which each OB was formed
[*][b]Dominance Candle Tint:[/b] Candles colored teal when dominant bull conditions are active, rose when dominant bear — encodes structural dominance state directly into price bar color
[*][b]Upgraded TP/SL Pip Labels:[/b] SL and TP labels now include session name and RR ratio in the format "142p TP 3.0R | London" — full trade context visible directly on the chart
[*][b]Sweep and Dominance Shift Counters:[/b] Sweep counter and dominance shift counter displayed in the dashboard — cumulative structural activity metrics updated on each confirmed event
[*][b]Expanded Dashboard (8 Rows):[/b] Dashboard expanded to 8 rows — now includes sweep count and dominance shift count alongside existing session win rate data
[/list]

[b]Input Parameters[/b]

[b]Pivot Settings:[/b]
[list]
[*]Swing Lookback: Number of bars on each side required to confirm a pivot (default: 5)
[/list]

[b]Sweep Settings:[/b]
[list]
[*]Min Sweep Wick (ATR×): Minimum wick depth relative to ATR (default: 0.2)
[*]Sweep Lookback Bars: How many recent bars to scan for swing levels to test against (default: 50)
[/list]

[b]Order Block:[/b]
[list]
[*]OB Scan Back: How far back to search for the last opposing candle (default: 10)
[*]OB Max Active: Maximum number of live order blocks displayed simultaneously (default: 5)
[/list]

[b]Filter Settings:[/b]
[list]
[*]EMA Trend Filter: Require price on correct side of EMA 750 for signal confirmation (default: enabled)
[*]EMA Length: Period for the trend EMA (default: 750)
[/list]

[b]Risk Management:[/b]
[list]
[*]ATR Length: Period for ATR calculation (default: 14)
[*]ATR SL Multiplier: Stop loss distance as ATR multiple (default: 1.5)
[*]Reward:Risk Ratio: Take profit as multiple of stop distance (default: 3.0)
[/list]

[b]Session Settings:[/b]
[list]
[*]Timezone, Asia/London/NY window hours — fully configurable per session
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Current Structural Context[/b]
Swing highs and lows on the chart represent the live liquidity pools. Price above the most recent swing high in an uptrend signals buy-side liquidity accumulation. Price below swing lows signals sell-side liquidity. The dominance signal (filled triangle) fires when price body-closes through a swing, marking a genuine structural shift.

[b]Step 2: Monitor for Sweep Signals[/b]
When a sweep label appears, price has taken liquidity from a swing level and rejected back inside. This is the setup precondition — the liquidity event has occurred. The order block zone identified at that bar is the entry reference level.

[b]Step 3: Enter at the Order Block[/b]
The last opposing candle before the sweep is rendered as a box. Price returning to that zone represents a potential re-entry into the displacement move. Combine with EMA 750 trend direction for higher-probability setups.

[b]Step 4: Manage the Trade with TP/SL Boxes[/b]
ATR-based SL and TP boxes extend from the entry bar. Stop loss is set 1.5× ATR below (long) or above (short) entry. Take profit is at 3:1 reward by default. Both are fully configurable.

[b]Step 5: Review Session Performance[/b]
The per-session win rate table highlights which killzones have historically produced the best outcomes on your instrument and timeframe. Use this to weight your activity toward higher-performing sessions.

[b]Indicator Limitations[/b]

[list]
[*]Swing pivot detection requires a minimum number of confirmed bars on both sides of the pivot. On very fast timeframes (sub-1 minute), pivot lookback may be impractically long relative to the session window
[*]The order block scan selects the last opposing candle within a fixed lookback window. In trending conditions with extended single-direction candle runs, no opposing candle may be found within the scan range
[*]Session win rate counters reset when the indicator is removed and re-added, or when the chart is refreshed with no history. They are valid only within the current chart session
[*]The EMA 750 filter is based on a 750-period EMA. On shorter timeframes, 750 bars may not be available on instruments with limited history, causing the EMA to be inaccurate until sufficient data loads
[*]ATR-based TP and SL levels are static from entry — they do not trail or adjust. Volatile markets may require manual adjustment of the ATR multiplier for realistic risk sizing
[/list]

[b]Originality Statement[/b]

DST integrates three distinct ICT order flow concepts — structural dominance, liquidity sweeps, and order block entry — into a unified detection and tracking pipeline. This combination is original for the following reasons:

[list]
[*]The three-layer detection pipeline (dominance → sweep → order block) processes each concept in sequence, where a sweep only becomes significant in the context of the structural level it targets, and the order block is identified relative to that sweep specifically — not as an independent scan
[*]The body-close dominance confirmation (requiring the entire body, not just the wick, to close beyond the swing level) is a stricter filter than standard breakout detection, reducing false structural break signals in choppy conditions
[*]Per-session win rate tracking, maintained independently for four distinct trading windows within a single indicator, provides empirical context for which market periods generate the most consistent outcomes on a given instrument
[*]The order block touch signal — a secondary detection layer that fires when price returns to interact with a previously identified OB zone — closes the loop between zone creation and zone interaction without requiring separate indicators
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Liquidity sweeps and order block zones are historical reference levels. The appearance of a sweep signal does not guarantee price continuation in any direction. Session win rates are based on historical bar data and do not predict future performance. Always apply proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Dominance Sweep Tracker [JOAT]", shorttitle="DST [JOAT]",
     overlay=true, max_boxes_count=200, max_lines_count=300, max_labels_count=150)

// ── GROUPS ─────────────────────────────────────────────────────────────────────
var string GRP_SW  = "Swing Detection"
var string GRP_DOM = "Dominance"
var string GRP_SWP = "Liquidity Sweep"
var string GRP_OB  = "Order Block"
var string GRP_EMA = "EMA Filter"
var string GRP_SESS= "Sessions"
var string GRP_TRD = "Trade Visualization"
var string GRP_DASH= "Dashboard"
var string GRP_ALT = "Alerts"

// ── SWING INPUTS ───────────────────────────────────────────────────────────────
i_swLen    = input.int(5, "Swing Length — Dominance",    minval=1, maxval=30, group=GRP_SW)
i_swLenSW  = input.int(5, "Swing Length — Sweep",        minval=1, maxval=30, group=GRP_SW)
i_swLenOB  = input.int(5, "Swing Length — OB Placement", minval=1, maxval=30, group=GRP_SW)
i_sweepLB  = input.int(1, "Sweep Re-entry Candles",      minval=1, maxval=10, group=GRP_SW,
     tooltip="Max candles after a spike beyond a swing to confirm price closed back inside.")

// ── DOMINANCE INPUTS ───────────────────────────────────────────────────────────
i_showDomL  = input.bool(true, "Show Dominance Labels", group=GRP_DOM)
i_showDomLn = input.bool(true, "Show Dominance Lines",  group=GRP_DOM)

// ── SWEEP INPUTS ───────────────────────────────────────────────────────────────
i_showSwp   = input.bool(true,  "Show Sweep Markers",      group=GRP_SWP)
i_showSwpLn = input.bool(false, "Show Sweep Level Lines",  group=GRP_SWP)

// ── OB INPUTS ──────────────────────────────────────────────────────────────────
i_showOB    = input.bool(true,  "Show Order Blocks",       group=GRP_OB)
i_obFull    = input.bool(false, "OB: Include Wicks",       group=GRP_OB)

// ── EMA INPUTS ─────────────────────────────────────────────────────────────────
i_emaLen    = input.int(750,  "EMA Period",               minval=1,  group=GRP_EMA)
i_useEMA    = input.bool(true,"Enable EMA Filter",                   group=GRP_EMA)
i_emaSwp    = input.bool(true,"EMA Filter on Sweeps",                group=GRP_EMA)
i_emaOB     = input.bool(true,"EMA Filter on OB Touch",             group=GRP_EMA)
i_showEMAl  = input.bool(true,"Show EMA Line",                       group=GRP_EMA)

// ── SESSION INPUTS ─────────────────────────────────────────────────────────────
i_utcOff    = input.int(0,     "UTC Offset",  minval=-12, maxval=14, group=GRP_SESS)
i_useSess   = input.bool(true, "Enable Session Filter",              group=GRP_SESS)
i_useAsia   = input.bool(true, "Asia",                               group=GRP_SESS)
i_asiaRng   = input.session("0000-0800","Asia Range",                group=GRP_SESS)
i_useLon    = input.bool(true, "London",                             group=GRP_SESS)
i_lonRng    = input.session("0700-1600","London Range",              group=GRP_SESS)
i_useNY     = input.bool(true, "New York",                           group=GRP_SESS)
i_nyRng     = input.session("1300-2200","New York Range",            group=GRP_SESS)
i_useExcl   = input.bool(false,"Custom Exclusion",                   group=GRP_SESS)
i_exclRng   = input.session("2200-0700","Exclusion Range",           group=GRP_SESS)
i_showAsiBg = input.bool(false,"Show Asia Background",               group=GRP_SESS)
i_asiBgCol  = input.color(color.new(#8e21f3, 97),"Asia BG",         group=GRP_SESS)
i_showLonBg = input.bool(false,"Show London Background",             group=GRP_SESS)
i_lonBgCol  = input.color(color.new(#003bfd, 97),"London BG",       group=GRP_SESS)
i_showNYBg  = input.bool(false,"Show New York Background",           group=GRP_SESS)
i_nyBgCol   = input.color(color.new(#fffb00, 97),"New York BG",     group=GRP_SESS)

// ── TRADE INPUTS ───────────────────────────────────────────────────────────────
i_showRR    = input.bool(true,  "Show RR Boxes (OB Touch)",          group=GRP_TRD)
i_rrRatio   = input.float(3.0,  "Risk:Reward Ratio", minval=0.1, step=0.1, group=GRP_TRD)
i_showPips  = input.bool(true,  "Show Pip Labels",                   group=GRP_TRD)
i_showTable = input.bool(true,  "Show Win Rate Table",               group=GRP_TRD)
i_showSessS = input.bool(false, "Session Breakdown in Table",        group=GRP_TRD)

// ── DASHBOARD INPUT ────────────────────────────────────────────────────────────
i_showDash  = input.bool(true, "Show Dashboard", group=GRP_DASH)

// ── ALERT INPUTS ───────────────────────────────────────────────────────────────
i_altBullDom = input.bool(true,"Bullish Dominance Alert",  group=GRP_ALT)
i_altBearDom = input.bool(true,"Bearish Dominance Alert",  group=GRP_ALT)
i_altBullSwp = input.bool(true,"Bullish Sweep Alert",      group=GRP_ALT)
i_altBearSwp = input.bool(true,"Bearish Sweep Alert",      group=GRP_ALT)
i_altBullOB  = input.bool(true,"Bullish OB Touch Alert",   group=GRP_ALT)
i_altBearOB  = input.bool(true,"Bearish OB Touch Alert",   group=GRP_ALT)

// ── COLORS ─────────────────────────────────────────────────────────────────────
color cBull     = color.new(#00bcd4, 10)
color cBear     = color.new(#dd326b, 10)
color cBullLbl  = color.new(#00bcd4, 45)
color cBearLbl  = color.new(#dd326b, 45)
color cSwpBull  = #00bcd4
color cSwpBear  = #ff9800
color cOBBullF  = color.new(#00bcd4, 85)
color cOBBearF  = color.new(#dd326b, 85)
color cOBBullB  = color.new(#00bcd4, 60)
color cOBBearB  = color.new(#dd326b, 60)

float pipSize = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)

// ── TIMEZONE / SESSION ─────────────────────────────────────────────────────────
f_tz() =>
    "UTC" + (i_utcOff >= 0 ? "+" + str.tostring(i_utcOff) : str.tostring(i_utcOff))

bool inAsia   = i_useAsia and not na(time(timeframe.period, i_asiaRng, f_tz()))
bool inLondon = i_useLon  and not na(time(timeframe.period, i_lonRng,  f_tz()))
bool inNY     = i_useNY   and not na(time(timeframe.period, i_nyRng,   f_tz()))
bool inExcl   = i_useExcl and not na(time(timeframe.period, i_exclRng, f_tz()))
bool sessOK   = not inExcl and (not i_useSess or (inAsia or inLondon or inNY))

f_sessTag() =>
    inNY and inLondon ? "LN+NY" : inLondon ? "London" : inNY ? "NY" : inAsia ? "Asia" : "Off"
string curSess = f_sessTag()

bgcolor(i_showAsiBg and inAsia   ? i_asiBgCol : na, title="Asia BG")
bgcolor(i_showLonBg and inLondon ? i_lonBgCol : na, title="London BG")
bgcolor(i_showNYBg  and inNY     ? i_nyBgCol  : na, title="NY BG")

// ── EMA ────────────────────────────────────────────────────────────────────────
float ema       = ta.ema(close, i_emaLen)
bool  abvEMA    = close > ema
color emaDynCol = abvEMA ? color.new(#00bcd4, 20) : color.new(#dd326b, 20)
plot(i_showEMAl ? ema : na, "EMA Filter", color=emaDynCol, linewidth=1)
// Dominance candle tint — placed after dominance var declaration below

// ── SWING DETECTION ────────────────────────────────────────────────────────────
// Dominance swings — pivothigh/pivotlow are confirmed (look left AND right)
float swH   = ta.pivothigh(high, i_swLen,   i_swLen)
float swL   = ta.pivotlow (low,  i_swLen,   i_swLen)
float swHOB = ta.pivothigh(high, i_swLenOB, i_swLenOB)
float swLOB = ta.pivotlow (low,  i_swLenOB, i_swLenOB)
float swHSW = ta.pivothigh(high, i_swLenSW, i_swLenSW)
float swLSW = ta.pivotlow (low,  i_swLenSW, i_swLenSW)

var float lastSH    = na
var int   lastSHBar    = na
var float lastSL    = na
var int   lastSLBar    = na
var float lastSHOB  = na
var int   lastSHBarOB  = na
var float lastSLOB  = na
var int   lastSLBarOB  = na
var float lastSHSW  = na
var int   lastSHBarSW  = na
var float lastSLSW  = na
var int   lastSLBarSW  = na

if not na(swH)
    lastSH    := swH
    lastSHBar := bar_index - i_swLen
if not na(swL)
    lastSL    := swL
    lastSLBar := bar_index - i_swLen
if not na(swHOB)
    lastSHOB    := swHOB
    lastSHBarOB := bar_index - i_swLenOB
if not na(swLOB)
    lastSLOB    := swLOB
    lastSLBarOB := bar_index - i_swLenOB
if not na(swHSW)
    lastSHSW    := swHSW
    lastSHBarSW := bar_index - i_swLenSW
if not na(swLSW)
    lastSLSW    := swLSW
    lastSLBarSW := bar_index - i_swLenSW

// ── DOMINANCE STATE ────────────────────────────────────────────────────────────
// Body-close break: open on one side, close on the other
var int dominance = 0

bool bullBreak = not na(lastSH) and close > lastSH and open < lastSH and
                 (not i_useEMA or close > ema) and barstate.isconfirmed
bool bearBreak = not na(lastSL) and close < lastSL and open > lastSL and
                 (not i_useEMA or close < ema) and barstate.isconfirmed

if bullBreak
    dominance := 1
if bearBreak
    dominance := -1

bool domChanged = bullBreak or bearBreak
barcolor(dominance == 1 ? color.new(#00bcd4, 75) : dominance == -1 ? color.new(#dd326b, 75) : na, title="Dominance Candle Tint")

// ── DOMINANCE LABELS & LINES ───────────────────────────────────────────────────
if i_showDomL and domChanged
    string domTxt = dominance == 1 ? "BOS ▲" : "BOS ▼"
    if dominance == 1
        label.new(bar_index, low, domTxt,
             style=label.style_label_up,
             color=cBullLbl, textcolor=color.white, size=size.small)
    else
        label.new(bar_index, high, domTxt,
             style=label.style_label_down,
             color=cBearLbl, textcolor=color.white, size=size.small)

if i_showDomLn and domChanged
    if dominance == 1 and not na(lastSH)
        line.new(lastSHBar, lastSH, bar_index + 20, lastSH,
             color=cBull, width=1, style=line.style_dashed)
    if dominance == -1 and not na(lastSL)
        line.new(lastSLBar, lastSL, bar_index + 20, lastSL,
             color=cBear, width=1, style=line.style_dashed)

// ── SWEEP / DOMINANCE COUNTERS ────────────────────────────────────────────────
var int swpCnt = 0
var int domCnt = 0

// ── LIQUIDITY SWEEP DETECTION ─────────────────────────────────────────────────
// Bear sweep: wick above swing high, close back below (grab of sell-side liquidity)
// Bull sweep: wick below swing low, close back above (grab of buy-side liquidity)
bool bearSwp = false
bool bullSwp = false

if not na(lastSHSW) and not domChanged
    bool emaOK = not i_emaSwp or not abvEMA
    // Same-bar spike
    if high > lastSHSW and close < lastSHSW and emaOK
        bearSwp := true
    // Multi-bar re-entry (up to i_sweepLB candles later)
    if not bearSwp and emaOK
        for k = 1 to i_sweepLB
            if close[k] > lastSHSW and close < lastSHSW
                bearSwp := true
                break

if not na(lastSLSW) and not domChanged
    bool emaOK = not i_emaSwp or abvEMA
    if low < lastSLSW and close > lastSLSW and emaOK
        bullSwp := true
    if not bullSwp and emaOK
        for k = 1 to i_sweepLB
            if close[k] < lastSLSW and close > lastSLSW
                bullSwp := true
                break

bearSwp := bearSwp and barstate.isconfirmed and sessOK
bullSwp := bullSwp and barstate.isconfirmed and sessOK
if bearSwp or bullSwp
    swpCnt += 1
if domChanged
    domCnt += 1

if i_showSwp
    if bullSwp
        label.new(bar_index, low, "x",
             style=label.style_label_up,
             color=color.new(cSwpBull, 50), textcolor=cSwpBull, size=size.tiny)
    if bearSwp
        label.new(bar_index, high, "x",
             style=label.style_label_down,
             color=color.new(cSwpBear, 50), textcolor=cSwpBear, size=size.tiny)

if i_showSwpLn
    if bullSwp and not na(lastSLSW)
        line.new(lastSLBarSW, lastSLSW, bar_index + 15, lastSLSW,
             color=color.new(cSwpBull, 20), width=1, style=line.style_dotted)
    if bearSwp and not na(lastSHSW)
        line.new(lastSHBarSW, lastSHSW, bar_index + 15, lastSHSW,
             color=color.new(cSwpBear, 20), width=1, style=line.style_dotted)

// ── ORDER BLOCK PLACEMENT ON DOMINANCE SHIFT ──────────────────────────────────
var box[]   bullOBBoxes = array.new<box>()
var box[]   bearOBBoxes = array.new<box>()
var float[] bullOBTop   = array.new<float>()
var float[] bullOBBot   = array.new<float>()
var float[] bearOBTop   = array.new<float>()
var float[] bearOBBot   = array.new<float>()

if i_showOB and domChanged
    if dominance == 1 and not na(lastSLBarOB)
        // Last bearish candle before the bullish impulse
        int obBar = -1
        int scanN = math.min(bar_index - lastSLBarOB + 1, 50)
        for k = 1 to scanN
            if close[k] < open[k]
                obBar := k
                break
        if obBar != -1
            float obH = i_obFull ? high[obBar]  : math.max(open[obBar], close[obBar])
            float obL = i_obFull ? low[obBar]   : math.min(open[obBar], close[obBar])
            box b = box.new(bar_index - obBar, obH, bar_index + 500, obL,
                 border_color=cOBBullB, border_width=1, bgcolor=cOBBullF)
            array.push(bullOBBoxes, b)
            array.push(bullOBTop, obH)
            array.push(bullOBBot, obL)
            float bObMid = (obH + obL) * 0.5
            label.new(bar_index - obBar + 1, bObMid, "BULL DOM",
                 style=label.style_label_right,
                 color=color.new(#00bcd4, 85),
                 textcolor=color.new(#00bcd4, 0),
                 size=size.small)

    if dominance == -1 and not na(lastSHBarOB)
        // Last bullish candle before the bearish impulse
        int obBar = -1
        int scanN = math.min(bar_index - lastSHBarOB + 1, 50)
        for k = 1 to scanN
            if close[k] > open[k]
                obBar := k
                break
        if obBar != -1
            float obH = i_obFull ? high[obBar]  : math.max(open[obBar], close[obBar])
            float obL = i_obFull ? low[obBar]   : math.min(open[obBar], close[obBar])
            box b = box.new(bar_index - obBar, obH, bar_index + 500, obL,
                 border_color=cOBBearB, border_width=1, bgcolor=cOBBearF)
            array.push(bearOBBoxes, b)
            array.push(bearOBTop, obH)
            array.push(bearOBBot, obL)
            float bObMid2 = (obH + obL) * 0.5
            label.new(bar_index - obBar + 1, bObMid2, "BEAR DOM",
                 style=label.style_label_right,
                 color=color.new(#dd326b, 85),
                 textcolor=color.new(#dd326b, 0),
                 size=size.small)

// ── OB TOUCH DETECTION & INVALIDATION ────────────────────────────────────────
bool bullOBTch = false
bool bearOBTch = false

// Bullish OBs: wick enters zone, body stays above bottom (not invalidated)
if array.size(bullOBBoxes) > 0
    for i = array.size(bullOBBoxes) - 1 to 0
        float obT = array.get(bullOBTop, i)
        float obB = array.get(bullOBBot, i)
        bool bodyBelow = math.max(open, close) < obB
        bool wickIn    = low <= obT and low >= obB
        if bodyBelow
            // Zone invalidated — body closed below bottom
            box.delete(array.get(bullOBBoxes, i))
            array.remove(bullOBBoxes, i)
            array.remove(bullOBTop, i)
            array.remove(bullOBBot, i)
        else if wickIn and abvEMA and sessOK and barstate.isconfirmed
            bullOBTch := true

// Bearish OBs
if array.size(bearOBBoxes) > 0
    for i = array.size(bearOBBoxes) - 1 to 0
        float obT = array.get(bearOBTop, i)
        float obB = array.get(bearOBBot, i)
        bool bodyAbove = math.min(open, close) > obT
        bool wickIn    = high >= obB and high <= obT
        if bodyAbove
            box.delete(array.get(bearOBBoxes, i))
            array.remove(bearOBBoxes, i)
            array.remove(bearOBTop, i)
            array.remove(bearOBBot, i)
        else if wickIn and not abvEMA and sessOK and barstate.isconfirmed
            bearOBTch := true

// ── UDT: TRADE ─────────────────────────────────────────────────────────────────
type DSTTrade
    box    slBox
    box    tpBox
    label  slLbl
    label  tpLbl
    float  slLvl
    float  tpLvl
    float  entry
    bool   isBull
    string sess
    int    entBar

var array<DSTTrade> activeTrades = array.new<DSTTrade>()

// ── WIN RATE COUNTERS ──────────────────────────────────────────────────────────
var int   totT  = 0
var int   totW  = 0
var float wPips = 0.0
var float lPips = 0.0
var int asiaW=0
var int asiaL=0
var int asiaT=0
var int lonW=0
var int lonL=0
var int lonT=0
var int nyW=0
var int nyL=0
var int nyT=0
var int offW=0
var int offL=0
var int offT=0
// ── ATR FOR TRADE SL CALCULATION ──────────────────────────────────────────────
float atrNow = ta.atr(14)

// ── OPEN NEW TRADE ON OB TOUCH ────────────────────────────────────────────────
if i_showRR and (bullOBTch or bearOBTch)
    bool  newBull  = bullOBTch
    float entPrice = close
    float slDist   = atrNow * 1.5
    float slLvl    = newBull ? entPrice - slDist : entPrice + slDist
    float tpLvl    = newBull ? entPrice + slDist * i_rrRatio : entPrice - slDist * i_rrRatio

    color slFill  = color.new(#dd326b, 82)
    color tpFill  = color.new(#00bcd4, 82)
    color slBord  = color.new(#dd326b, 40)
    color tpBord  = color.new(#00bcd4, 40)

    box slBx = box.new(bar_index, entPrice, bar_index + 1, slLvl,
         bgcolor=slFill, border_color=slBord, border_width=1)
    box tpBx = box.new(bar_index, entPrice, bar_index + 1, tpLvl,
         bgcolor=tpFill, border_color=tpBord, border_width=1)

    float slPips = math.round(slDist / pipSize)
    float tpPips = math.round(slDist * i_rrRatio / pipSize)

    string slTxt = str.tostring(slPips, "#") + "p SL | " + curSess
    string tpTxt = str.tostring(tpPips, "#") + "p TP " + str.tostring(i_rrRatio, "#.0") + "R"
    label slL = i_showPips ?
         label.new(bar_index, slLvl,
              slTxt,
              style=newBull ? label.style_label_up : label.style_label_down,
              color=color.new(#dd326b, 55), textcolor=color.white, size=size.small) : na
    label tpL = i_showPips ?
         label.new(bar_index, tpLvl,
              tpTxt,
              style=newBull ? label.style_label_down : label.style_label_up,
              color=color.new(#00bcd4, 55), textcolor=color.white, size=size.small) : na

    array.push(activeTrades,
         DSTTrade.new(slBx, tpBx, slL, tpL, slLvl, tpLvl, entPrice, newBull, curSess, bar_index))
    totT += 1

// ── UPDATE ACTIVE TRADES ───────────────────────────────────────────────────────
if array.size(activeTrades) > 0
    for i = array.size(activeTrades) - 1 to 0
        DSTTrade t = array.get(activeTrades, i)

        if bar_index > t.entBar
            box.set_right(t.slBox, bar_index + 1)
            box.set_right(t.tpBox, bar_index + 1)
            if not na(t.slLbl)
                label.set_x(t.slLbl, bar_index)
            if not na(t.tpLbl)
                label.set_x(t.tpLbl, bar_index)

            bool slHit = t.isBull ? low  <= t.slLvl : high >= t.slLvl
            bool tpHit = t.isBull ? high >= t.tpLvl : low  <= t.tpLvl

            if slHit or tpHit
                bool  won  = tpHit
                float pips = math.abs((won ? t.tpLvl : t.slLvl) - t.entry) / pipSize

                if won
                    totW += 1
                    wPips += pips
                else
                    lPips += pips

                // Session-level tallies
                if t.sess == "Asia"
                    asiaT += 1
                    if won
                        asiaW += 1
                    else
                        asiaL += 1
                else if t.sess == "London"
                    lonT += 1
                    if won
                        lonW += 1
                    else
                        lonL += 1
                else if t.sess == "NY"
                    nyT += 1
                    if won
                        nyW += 1
                    else
                        nyL += 1
                else
                    offT += 1
                    if won
                        offW += 1
                    else
                        offL += 1

                box.set_right(t.slBox, bar_index)
                box.set_right(t.tpBox, bar_index)
                array.remove(activeTrades, i)

// ── DASHBOARD ─────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 4, 8,
     bgcolor=color.new(#0d0d14, 80), border_width=0, frame_width=0)

if barstate.islast and i_showDash
    color cHead = color.new(#00bcd4, 0)
    color cBearC= color.new(#dd326b, 0)
    color cBody = color.new(#d0d0d0, 0)
    color cDim  = color.new(#707070, 0)
    color cBgH  = color.new(#0d0d14, 72)
    color cBgR  = color.new(#111118, 60)

    float wrPct  = totT > 0 ? totW * 100.0 / totT : 0.0
    float netP   = wPips - lPips
    string domStr = dominance == 1 ? "BULL" : dominance == -1 ? "BEAR" : "NEUT"
    color  domCol = dominance == 1 ? cHead  : dominance == -1 ? cBearC : cDim

    // Row 0 — Header
    table.cell(dash, 0, 0, "DST [JOAT]", text_color=cHead, text_size=size.small, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 1, 0, "",           text_size=size.normal, bgcolor=cBgH)
    table.cell(dash, 2, 0, domStr,       text_color=domCol, text_size=size.small, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 3, 0, curSess,      text_color=cDim,   text_size=size.normal,  text_halign=text.align_right,  bgcolor=cBgH)

    // Row 1 — Overall stats
    table.cell(dash, 0, 1, "Trades",   text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 1, 1, str.tostring(totT), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 1, "Win Rate", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 3, 1, str.tostring(wrPct, "#.0") + "%",
         text_color=wrPct >= 50 ? cHead : cBearC, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    // Row 2 — Pip stats
    table.cell(dash, 0, 2, "Win Pips", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 1, 2, str.tostring(wPips, "#.0"), text_color=cHead, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 2, 2, "Net Pips", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 3, 2, str.tostring(netP, "#.0"),
         text_color=netP >= 0 ? cHead : cBearC, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

    if i_showSessS
        float awR = asiaT > 0 ? asiaW * 100.0 / asiaT : 0.0
        float lwR = lonT  > 0 ? lonW  * 100.0 / lonT  : 0.0
        float nwR = nyT   > 0 ? nyW   * 100.0 / nyT   : 0.0

        table.cell(dash, 0, 3, "Session", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
        table.cell(dash, 1, 3, "T",       text_color=cDim, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
        table.cell(dash, 2, 3, "W",       text_color=cDim, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
        table.cell(dash, 3, 3, "WR%",     text_color=cDim, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

        table.cell(dash, 0, 4, "Asia",    text_color=color.new(#8e21f3,0), text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
        table.cell(dash, 1, 4, str.tostring(asiaT), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
        table.cell(dash, 2, 4, str.tostring(asiaW), text_color=cHead, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
        table.cell(dash, 3, 4, str.tostring(awR,"#.0")+"%", text_color=awR>=50?cHead:cBearC, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

        table.cell(dash, 0, 5, "London",  text_color=color.new(#003bfd,0), text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
        table.cell(dash, 1, 5, str.tostring(lonT), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
        table.cell(dash, 2, 5, str.tostring(lonW), text_color=cHead, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
        table.cell(dash, 3, 5, str.tostring(lwR,"#.0")+"%", text_color=lwR>=50?cHead:cBearC, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

        table.cell(dash, 0, 6, "New York",text_color=color.new(#b8a000,0), text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
        table.cell(dash, 1, 6, str.tostring(nyT), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
        table.cell(dash, 2, 6, str.tostring(nyW), text_color=cHead, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
        table.cell(dash, 3, 6, str.tostring(nwR,"#.0")+"%", text_color=nwR>=50?cHead:cBearC, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

    // ── Row 7 — Sweep / Dom counts ───────────────────────────────────────────
    table.cell(dash, 0, 7, "Sweeps",   text_color=cDim,      text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    table.cell(dash, 1, 7, str.tostring(swpCnt), text_color=color.new(#f59e0b, 0), text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 7, "Dom Shifts", text_color=cDim,    text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    table.cell(dash, 3, 7, str.tostring(domCnt), text_color=cHead, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

// ── ALERTS ─────────────────────────────────────────────────────────────────────
alertcondition(i_altBullDom and bullBreak, "DST Bull Dominance", "Dominance Sweep Tracker [JOAT]: Bullish dominance shift")
alertcondition(i_altBearDom and bearBreak, "DST Bear Dominance", "Dominance Sweep Tracker [JOAT]: Bearish dominance shift")
alertcondition(i_altBullSwp and bullSwp,   "DST Bull Sweep",     "Dominance Sweep Tracker [JOAT]: Bullish liquidity sweep")
alertcondition(i_altBearSwp and bearSwp,   "DST Bear Sweep",     "Dominance Sweep Tracker [JOAT]: Bearish liquidity sweep")
alertcondition(i_altBullOB  and bullOBTch, "DST Bull OB Touch",  "Dominance Sweep Tracker [JOAT]: Bullish OB touch signal")
alertcondition(i_altBearOB  and bearOBTch, "DST Bear OB Touch",  "Dominance Sweep Tracker [JOAT]: Bearish OB touch signal")
````
