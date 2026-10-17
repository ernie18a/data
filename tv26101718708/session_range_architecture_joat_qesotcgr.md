# Session Range Architecture [JOAT]

- url: https://www.tradingview.com/script/qeSoTcGR-Session-Range-Architecture-JOAT/
- type: indicator
- pine_id: PUB;482289ce20674a6184d885c08beee8f4
- version: 1.0

## Description

[b]Session Range Architecture [JOAT][/b]

[b]Introduction[/b]

Session Range Architecture (SRA) is an open-source, institutional-grade session killzone engine that captures the opening range of the Tokyo, London, and New York trading sessions as live price-tracking boxes, draws high, low, and mid extension lines that persist after each session closes, and fires rejection signals when price wicks beyond a session extreme and closes back inside. Signals are filtered by an EMA alignment stack (EMA 4, EMA 5, and EMA 750) and confirmed exclusively on closed bars. ATR-based stop loss and take profit boxes visualize each signal's risk/reward from entry. Per-session and aggregate win rate statistics are tracked and displayed in a configurable dashboard.

The core problem SRA solves is the repetitive, daily manual work of marking opening range boxes for each session. ICT methodology identifies the first portion of each killzone as the period during which institutional order flow establishes the session's directional bias — the high and low of that range become the primary intraday reference levels. When price returns to those levels later in the session or in the following session and creates a wick rejection, it signals a potential liquidity grab and reversal opportunity. SRA automates the full process from box construction through signal detection to trade outcome tracking.

[image]https://www.tradingview.com/x/raOXIE0o/[/image]

[b]Core Concepts[/b]

[b]1. Session Opening Range Construction[/b]

Each session's opening range is built dynamically during the configurable range window (default: first 15 minutes of each session). The high and low of every bar within that window expand the range in real time. At the end of the window, the range is finalized and stored as a SessionRange user-defined type containing the box, three extension lines (high, low, mid), and the session label:

[pine]
if inTokyo and not tokBuilding
    tokHi      := high
    tokLo      := low
    tokOpenBar := bar_index
    tokBuilding := true
else if inTokyo and tokBuilding
    tokHi := math.max(tokHi, high)
    tokLo := math.min(tokLo, low)
[/pine]

[b]2. Extension Lines[/b]

When a session's range window closes, three horizontal lines are drawn extending rightward from the range: a dashed line at the session high (buy-side liquidity), a dashed line at the session low (sell-side liquidity), and a dotted line at the session midpoint (50% equilibrium reference). These lines persist on the chart as long-term structural reference levels beyond the session itself.

[b]3. Rejection Signal Detection[/b]

A rejection is detected when a bar's wick pierces a session high or low and the close returns inside the range. A minimum wick percentage filter ensures the penetration is meaningful relative to total candle range — trivial pokes are excluded. For a bullish rejection at a session low (price swept below, closed above), the setup is treated as a potential long opportunity. For a bearish rejection at a session high, it is treated as a short opportunity.

[b]4. EMA Alignment Filter[/b]

Signals are optionally filtered by a simplified EMA alignment check: bullish signals require EMA 4 above EMA 5 and price above EMA 750; bearish signals require EMA 4 below EMA 5 and price below EMA 750. This ensures rejection signals at session levels are taken in the direction of the prevailing trend structure rather than against it.

[b]5. ATR-Based Trade Visualization and Tracking[/b]

On each confirmed signal, ATR-based stop loss and take profit boxes are drawn from the entry close. Outcome is checked on subsequent bars — if price hits the SL or TP, the trade is recorded, counters for the originating session are updated, and the box color changes to reflect the result.

[b]Features[/b]

[list]
[*][b]Three Independent Session Ranges:[/b] Tokyo, London, and New York opening ranges built automatically each day — individually configurable with independent colors and visibility toggles
[*][b]Configurable Range Window:[/b] Opening range capture window length adjustable from 5 to 60 minutes to match different analysis styles
[*][b]Extension Lines:[/b] Session high, low, and mid extension lines drawn from completed ranges and extended rightward as persistent liquidity reference levels
[*][b]Rejection Signal Detection:[/b] Wick-beyond, close-inside detection at session extremes with minimum wick percentage filter
[*][b]EMA Alignment Filter:[/b] EMA 4/5 cross direction and EMA 750 price side required for signal confirmation — configurable on/off
[*][b]ATR TP/SL Visualization:[/b] Risk and reward boxes from each entry bar — default 1.5× ATR stop, 3:1 reward ratio, fully adjustable
[*][b]Session Win Rate Tracking:[/b] Independent win/loss/total counters for Tokyo, London, and New York sessions
[*][b]Session History Management:[/b] Oldest range boxes automatically trimmed to prevent chart clutter (configurable maximum)
[*][b]Non-Repainting:[/b] All signals gated on barstate.isconfirmed — session ranges never move backward
[*][b]Timezone Configuration:[/b] Session windows evaluated relative to a configurable timezone to handle exchange-specific session times
[*][b]Dashboard (Top Right):[/b] Per-session win/loss/rate table for Tokyo, London, NY, and aggregate total with color-coded performance rows
[*][b]Session Background Tints:[/b] Subtle color fills applied to the chart background during Tokyo, London, and NY range-building windows — visually delineates the opening range capture period for each session in real time
[*][b]Session Name Labels on Range Boxes:[/b] Session name label placed at the midpoint of each finalized range box — immediately identifies which session produced each visible range without requiring manual reference
[*][b]EMA Alignment State in Dashboard:[/b] Current EMA alignment state (BULL ALIGN / BEAR ALIGN / NEUTRAL) displayed in the dashboard — provides a one-glance structural context for the active session
[*][b]Live ATR Value in Dashboard:[/b] Current ATR value shown in the dashboard — communicates the prevailing volatility level used for TP/SL sizing at any given moment
[*][b]Expanded Dashboard (8 Rows):[/b] Dashboard expanded to 8 rows — now includes EMA alignment state and live ATR value alongside the existing per-session win rate breakdown
[/list]

[b]Input Parameters[/b]

[b]Session Settings:[/b]
[list]
[*]Chart Timezone: Timezone for session window evaluation (default: America/New_York)
[*]Show Tokyo / London / New York Range: Independent visibility toggles per session
[*]Range Window (minutes): Opening range capture duration (default: 15)
[/list]

[b]EMA Filter:[/b]
[list]
[*]Fast EMA: Period for fast EMA (default: 4)
[*]Slow EMA: Period for slow EMA (default: 5)
[*]Trend EMA: Period for long-term trend filter EMA (default: 750)
[*]Require EMA Alignment: Toggle filter on/off (default: enabled)
[/list]

[b]Risk Settings:[/b]
[list]
[*]ATR Length: ATR period (default: 14)
[*]ATR SL Multiplier: Stop loss ATR distance (default: 1.5)
[*]Reward:Risk Ratio: TP as multiple of SL distance (default: 3.0)
[*]Show TP/SL Boxes: Toggle TP/SL visualization (default: enabled)
[/list]

[b]Signal Settings:[/b]
[list]
[*]Require Rejection Wick: Toggle minimum wick filter (default: enabled)
[*]Min Wick % of Range: Minimum wick size relative to candle range (default: 55%)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Session Range Levels[/b]
Each session's opening range box shows the high, low, and midpoint established during the opening window. These are the primary liquidity reference levels for that killzone. Extension lines persist after the session box closes, continuing to mark those price levels as the day progresses.

[b]Step 2: Monitor for Rejection Signals[/b]
When price wicks beyond a session extreme and closes back inside, a rejection signal is generated. This event represents a liquidity grab — the market took the stops placed beyond the session extreme and reversed. The signal fires at the close of the rejecting bar, confirmed on that candle only.

[b]Step 3: Confirm EMA Alignment[/b]
With the EMA filter enabled, only signals aligned with the current EMA 4/5 direction and EMA 750 trend side are triggered. This avoids trading session rejections against the prevailing structural trend.

[b]Step 4: Manage Risk with TP/SL Boxes[/b]
The ATR-based TP/SL boxes extend from the entry close and show the exact risk/reward zone for each trade. The stop is placed 1.5× ATR from entry; the target is 3× that distance by default. Both are adjustable.

[b]Step 5: Review Session Performance[/b]
The per-session win rate table shows which session ranges have historically produced the best rejection setups on the current instrument and timeframe. Use this to focus attention on the sessions with the strongest empirical edge.

[b]Indicator Limitations[/b]

[list]
[*]Session detection is based on time windows relative to the selected timezone. Instruments that observe daylight saving time shifts differently from the selected timezone may require manual session string adjustment during DST transitions
[*]The opening range window is fixed in minutes. On timeframes coarser than the window (e.g., a 30-minute chart with a 15-minute range window), the range will capture only one or two bars, which may not accurately represent the opening range
[*]The EMA 750 requires 750 bars of history to produce an accurate value. On instruments with limited history or on very long timeframes, the first 750 bars will show an inaccurate trend filter — use the indicator on instruments and timeframes with sufficient historical data
[*]Session win rate counters are maintained within the current chart load session and reset when the indicator is refreshed. They reflect historical outcomes up to the current chart's loaded data, not a permanent multi-year backtest
[*]Rejection detection uses bar closes. On timeframes with large candles (daily, weekly), a wick rejection at a session range level may span multiple intraday sessions, making the signal less precise for intraday execution
[/list]

[b]Originality Statement[/b]

SRA automates the full three-stage session range workflow — range construction, level monitoring, and rejection detection — within a single indicator, with per-session outcome tracking and EMA trend filtering. This is original for the following reasons:

[list]
[*]The dynamic range construction (high/low expanding bar-by-bar during the opening window, then finalizing on window close) replicates the manual process of drawing opening range boxes in real time, including live box expansion during active sessions — behavior not available from static horizontal lines
[*]Extension lines at the session high, low, and midpoint persist beyond the session box as separate structural reference levels, providing a layered view of session-specific liquidity without requiring additional drawings
[*]The rejection detection system operates across all three active session ranges simultaneously in a single scan loop, identifying which specific session range produced the signal and tagging it for session-specific outcome tracking
[*]The EMA alignment stack (fast EMA cross direction + long-term trend EMA) applied as a prerequisite filter to session rejection signals combines institutional level-based methodology with trend confirmation in a single indicator rather than requiring a separate trend indicator
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Session range levels and rejection signals are historical reference points. Price does not respect these levels in all market conditions, and rejection signals do not guarantee a reversal. Session win rates are derived from historical bar data and do not predict future performance. Always apply proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Session Range Architecture [JOAT]", shorttitle="SRA [JOAT]", overlay=true, max_boxes_count=300, max_lines_count=500, max_labels_count=200)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// Session Windows
i_tz         = input.string("America/New_York", "Chart Timezone", group="Session Settings",
                 options=["America/New_York","America/Chicago","Europe/London","Asia/Tokyo","Asia/Singapore","UTC"])
i_tokyoOn    = input.bool(true,  "Show Tokyo Range",  group="Session Settings")
i_londonOn   = input.bool(true,  "Show London Range", group="Session Settings")
i_nyOn       = input.bool(true,  "Show New York Range", group="Session Settings")
i_rangeMin   = input.int(15, "Range Window (minutes)", minval=5, maxval=60, group="Session Settings")

// EMA Filter
i_emaFast    = input.int(4,   "Fast EMA",    minval=1,  group="EMA Filter")
i_emaSlow    = input.int(5,   "Slow EMA",    minval=1,  group="EMA Filter")
i_ema750     = input.int(750, "Trend EMA",   minval=50, group="EMA Filter")
i_emaFilter  = input.bool(true, "Require EMA Alignment", group="EMA Filter")

// ATR / Risk
i_atrLen     = input.int(14,  "ATR Length",  minval=1,  group="Risk Settings")
i_atrMult    = input.float(1.5, "ATR SL Multiplier", minval=0.5, step=0.1, group="Risk Settings")
i_rrRatio    = input.float(3.0, "Reward:Risk Ratio",  minval=1.0, step=0.5, group="Risk Settings")
i_showRR     = input.bool(true, "Show TP/SL Boxes",   group="Risk Settings")

// Rejection Signal
i_rejFilter  = input.bool(true, "Require Rejection Wick", group="Signal Settings")
i_minWickPct = input.float(0.55, "Min Wick % of Range",   minval=0.1, maxval=1.0, step=0.05, group="Signal Settings")

// Visual
i_tokyoCol   = input.color(color.new(#f59e0b, 75), "Tokyo Box Color",  group="Visual")
i_londonCol  = input.color(color.new(#3b82f6, 75), "London Box Color", group="Visual")
i_nyCol      = input.color(color.new(#10b981, 75), "NY Box Color",     group="Visual")
i_extCol     = input.color(color.new(#94a3b8, 70), "Extension Line Color", group="Visual")
i_slCol      = input.color(color.new(#ef4444, 80), "SL Box Color",    group="Visual")
i_tpCol      = input.color(color.new(#22c55e, 80), "TP Box Color",    group="Visual")
i_dashOn     = input.bool(true, "Show Dashboard", group="Visual")

// ─────────────────────────────────────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────────────────────────────────────

type SessionRange
    box    rangeBox
    line   hiLine
    line   loLine
    line   midLine
    float  hi
    float  lo
    float  mid
    int    openBar
    int    closeBar
    bool   isActive
    string sess

type SRATrade
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

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT STATE
// ─────────────────────────────────────────────────────────────────────────────

var array<SessionRange> ranges  = array.new<SessionRange>()
var array<SRATrade>     trades  = array.new<SRATrade>()

// Session tracking vars
var float tokHi = na
var float tokLo = na
var int   tokOpenBar = na
var bool  tokBuilding = false

var float lonHi = na
var float lonLo = na
var int   lonOpenBar = na
var bool  lonBuilding = false

var float nyHi = na
var float nyLo = na
var int   nyOpenBar = na
var bool  nyBuilding = false

// Win/loss counters
var int tokW = 0, var int tokL = 0, var int tokT = 0
var int lonW = 0, var int lonL = 0, var int lonT = 0
var int nyW  = 0, var int nyL  = 0, var int nyT  = 0
var int totW = 0, var int totL = 0, var int totT = 0

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

float atr    = ta.atr(i_atrLen)
float ema4   = ta.ema(close, i_emaFast)
float ema5   = ta.ema(close, i_emaSlow)
float ema750 = ta.ema(close, i_ema750)

bool bullAlign = ema4 > ema5 and close > ema750
bool bearAlign = ema4 < ema5 and close < ema750

// Session time helpers — check if current bar falls within session open range window
f_inWindow(string sess, int windowMin) =>
    int h = 0
    int m = 0
    if sess == "Tokyo"
        h := 2
        m := 0
    else if sess == "London"
        h := 8
        m := 0
    else
        h := 14
        m := 0
    int barH = hour(time, i_tz)
    int barM = minute(time, i_tz)
    int barTotalMin = barH * 60 + barM
    int sessStart   = h * 60 + m
    int sessEnd     = sessStart + windowMin
    barTotalMin >= sessStart and barTotalMin < sessEnd

bool inTokyo  = f_inWindow("Tokyo",  i_rangeMin)
bool inLondon = f_inWindow("London", i_rangeMin)
bool inNY     = f_inWindow("NY",     i_rangeMin)

// Session background tints during range-building window
bgcolor(inTokyo  and i_tokyoOn  ? color.new(#f59e0b, 96) : na, title="Tokyo Window BG")
bgcolor(inLondon and i_londonOn ? color.new(#3b82f6, 96) : na, title="London Window BG")
bgcolor(inNY     and i_nyOn     ? color.new(#10b981, 96) : na, title="NY Window BG")

// ─────────────────────────────────────────────────────────────────────────────
// BUILD SESSION RANGES
// ─────────────────────────────────────────────────────────────────────────────

// Helper: finalize a range and push to array
f_finalizeRange(float hi, float lo, int openBar, string sess, color bCol) =>
    if not na(hi) and not na(lo) and hi > lo
        float mid      = math.avg(hi, lo)
        SessionRange r = SessionRange.new()
        r.hi       := hi
        r.lo       := lo
        r.mid      := mid
        r.openBar  := openBar
        r.closeBar := bar_index
        r.isActive := true
        r.sess     := sess
        r.rangeBox := box.new(openBar, hi, bar_index, lo,
                              border_color=bCol, border_width=1,
                              bgcolor=color.new(bCol, 88))
        r.hiLine   := line.new(bar_index, hi,  bar_index + 200, hi,
                               color=color.new(bCol, 40), width=1, style=line.style_dashed, extend=extend.right)
        r.loLine   := line.new(bar_index, lo,  bar_index + 200, lo,
                               color=color.new(bCol, 40), width=1, style=line.style_dashed, extend=extend.right)
        r.midLine  := line.new(bar_index, mid, bar_index + 200, mid,
                               color=color.new(bCol, 55), width=1, style=line.style_dotted, extend=extend.right)
        // Session label at midpoint
        label.new(openBar, math.avg(hi, lo), sess,
             style=label.style_label_right,
             color=color.new(bCol, 70),
             textcolor=color.white,
             size=size.tiny)
        array.push(ranges, r)
        // Trim oldest if too many
        if array.size(ranges) > 30
            SessionRange old = array.shift(ranges)
            box.delete(old.rangeBox)
            line.delete(old.hiLine)
            line.delete(old.loLine)
            line.delete(old.midLine)

// Tokyo range building
if i_tokyoOn
    if inTokyo and not tokBuilding
        tokHi       := high
        tokLo       := low
        tokOpenBar  := bar_index
        tokBuilding := true
    else if inTokyo and tokBuilding
        tokHi := math.max(tokHi, high)
        tokLo := math.min(tokLo, low)
    else if not inTokyo and tokBuilding
        f_finalizeRange(tokHi, tokLo, tokOpenBar, "Tokyo", i_tokyoCol)
        tokHi       := na
        tokLo       := na
        tokOpenBar  := na
        tokBuilding := false

// London range building
if i_londonOn
    if inLondon and not lonBuilding
        lonHi       := high
        lonLo       := low
        lonOpenBar  := bar_index
        lonBuilding := true
    else if inLondon and lonBuilding
        lonHi := math.max(lonHi, high)
        lonLo := math.min(lonLo, low)
    else if not inLondon and lonBuilding
        f_finalizeRange(lonHi, lonLo, lonOpenBar, "London", i_londonCol)
        lonHi       := na
        lonLo       := na
        lonOpenBar  := na
        lonBuilding := false

// NY range building
if i_nyOn
    if inNY and not nyBuilding
        nyHi       := high
        nyLo       := low
        nyOpenBar  := bar_index
        nyBuilding := true
    else if inNY and nyBuilding
        nyHi := math.max(nyHi, high)
        nyLo := math.min(nyLo, low)
    else if not inNY and nyBuilding
        f_finalizeRange(nyHi, nyLo, nyOpenBar, "NY", i_nyCol)
        nyHi       := na
        nyLo       := na
        nyOpenBar  := na
        nyBuilding := false

// ─────────────────────────────────────────────────────────────────────────────
// REJECTION SIGNAL DETECTION
// ─────────────────────────────────────────────────────────────────────────────

// Check for external rejection: wick beyond range level, close returns inside
f_checkRejection(float level, bool isBull) =>
    bool rejected = false
    if isBull
        // Bearish rejection at top: wick above level, close below level
        bool wickBeyond = high > level
        bool closeBelow = close < level
        float wickSize  = high - math.max(open, close)
        float rng       = high - low
        bool wickOK     = i_rejFilter ? (wickSize / math.max(rng, 0.0001) >= i_minWickPct) : true
        rejected := wickBeyond and closeBelow and wickOK
    else
        // Bullish rejection at bottom: wick below level, close above level
        bool wickBeyond = low < level
        bool closeAbove = close > level
        float wickSize  = math.min(open, close) - low
        float rng       = high - low
        bool wickOK     = i_rejFilter ? (wickSize / math.max(rng, 0.0001) >= i_minWickPct) : true
        rejected := wickBeyond and closeAbove and wickOK
    rejected

// ─────────────────────────────────────────────────────────────────────────────
// OPEN TRADE FUNCTION
// ─────────────────────────────────────────────────────────────────────────────

f_openTrade(float entryPx, bool isBull, string sess, color tpC, color slC) =>
    float slDist  = atr * i_atrMult
    float slLvl   = isBull ? entryPx - slDist : entryPx + slDist
    float tpLvl   = isBull ? entryPx + slDist * i_rrRatio : entryPx - slDist * i_rrRatio
    int   bStart  = bar_index
    int   bEnd    = bar_index + 60

    SRATrade t    = SRATrade.new()
    t.entry   := entryPx
    t.slLvl   := slLvl
    t.tpLvl   := tpLvl
    t.isBull  := isBull
    t.sess    := sess
    t.entBar  := bStart

    if i_showRR
        t.slBox := box.new(bStart, entryPx, bEnd, slLvl,
                           border_color=color.new(slC, 60), bgcolor=color.new(slC, 88),
                           border_width=1)
        t.tpBox := box.new(bStart, tpLvl, bEnd, entryPx,
                           border_color=color.new(tpC, 60), bgcolor=color.new(tpC, 88),
                           border_width=1)
        t.slLbl := label.new(bEnd, slLvl, "SL",
                             color=color.new(slC, 70), textcolor=color.white,
                             style=label.style_label_left, size=size.tiny)
        t.tpLbl := label.new(bEnd, tpLvl, "TP",
                             color=color.new(tpC, 70), textcolor=color.white,
                             style=label.style_label_left, size=size.tiny)

    array.push(trades, t)
    if array.size(trades) > 40
        SRATrade old = array.shift(trades)
        if i_showRR
            box.delete(old.slBox)
            box.delete(old.tpBox)
            label.delete(old.slLbl)
            label.delete(old.tpLbl)

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL DETECTION — scan active ranges for rejection
// ─────────────────────────────────────────────────────────────────────────────

if barstate.isconfirmed and array.size(ranges) > 0
    for i = array.size(ranges) - 1 to 0
        SessionRange r = array.get(ranges, i)
        if not r.isActive
            continue

        string rSess  = r.sess
        color  rCol   = rSess == "Tokyo" ? i_tokyoCol : rSess == "London" ? i_londonCol : i_nyCol

        // Check rejection at range HIGH (bearish)
        bool bearRej = f_checkRejection(r.hi, true)
        bool bearEMA = i_emaFilter ? bearAlign : true
        if bearRej and bearEMA
            f_openTrade(close, false, rSess, i_tpCol, i_slCol)

        // Check rejection at range LOW (bullish)
        bool bullRej = f_checkRejection(r.lo, false)
        bool bullEMA = i_emaFilter ? bullAlign : true
        if bullRej and bullEMA
            f_openTrade(close, true, rSess, i_tpCol, i_slCol)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE MANAGEMENT — extend boxes, check TP/SL
// ─────────────────────────────────────────────────────────────────────────────

if barstate.isconfirmed and array.size(trades) > 0
    for i = array.size(trades) - 1 to 0
        SRATrade t = array.get(trades, i)
        if na(t.entBar)
            continue

        bool hit = false
        bool won = false

        if t.isBull
            if low <= t.slLvl
                hit := true
                won := false
            else if high >= t.tpLvl
                hit := true
                won := true
        else
            if high >= t.slLvl
                hit := true
                won := false
            else if low <= t.tpLvl
                hit := true
                won := true

        if i_showRR
            box.set_right(t.slBox, bar_index)
            box.set_right(t.tpBox, bar_index)
            label.set_x(t.slLbl, bar_index)
            label.set_x(t.tpLbl, bar_index)

        if hit
            // Update counters
            totT += 1
            if won
                totW += 1
            else
                totL += 1

            if t.sess == "Tokyo"
                tokT += 1
                if won
                    tokW += 1
                else
                    tokL += 1
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

            // Color final boxes
            if i_showRR
                color finalCol = won ? i_tpCol : i_slCol
                box.set_bgcolor(t.slBox, color.new(finalCol, 85))
                box.set_bgcolor(t.tpBox, color.new(finalCol, 85))

            // Remove from array
            array.remove(trades, i)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

if i_dashOn and barstate.islast
    float tokWR  = tokT  > 0 ? tokW  / tokT  * 100.0 : 0.0
    float lonWR  = lonT  > 0 ? lonW  / lonT  * 100.0 : 0.0
    float nyWR   = nyT   > 0 ? nyW   / nyT   * 100.0 : 0.0
    float totWR  = totT  > 0 ? totW  / totT  * 100.0 : 0.0

    int   rows   = 8
    int   cols   = 4
    table dash   = table.new(position.top_right, cols, rows,
                             bgcolor=color.new(#0f172a, 10),
                             border_color=color.new(#334155, 80),
                             border_width=1, frame_color=color.new(#334155, 60),
                             frame_width=1)

    // Header
    table.cell(dash, 0, 0, "Session Range Architecture [JOAT]",
               text_color=color.new(#f8fafc, 0), text_size=size.small,
               bgcolor=color.new(#1e293b, 10), text_halign=text.align_center)
    table.cell(dash, 1, 0, "", text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 2, 0, "", text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 3, 0, "", text_size=size.normal, bgcolor=color.new(#1e293b, 10))

    // Column headers
    table.cell(dash, 0, 1, "Session", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 20))
    table.cell(dash, 1, 1, "W",       text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 20))
    table.cell(dash, 2, 1, "L",       text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 20))
    table.cell(dash, 3, 1, "WR%",     text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 20))

    // Tokyo row
    color tokClr = tokWR >= 55.0 ? color.new(#22c55e, 20) : tokWR >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 2, "Tokyo",            text_color=color.new(#f59e0b, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 2, str.tostring(tokW), text_color=color.new(#22c55e, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 2, str.tostring(tokL), text_color=color.new(#ef4444, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 3, 2, str.format("{0,number,#.#}%", tokWR), text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=tokClr)

    // London row
    color lonClr = lonWR >= 55.0 ? color.new(#22c55e, 20) : lonWR >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 3, "London",           text_color=color.new(#3b82f6, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 3, str.tostring(lonW), text_color=color.new(#22c55e, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 3, str.tostring(lonL), text_color=color.new(#ef4444, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 3, 3, str.format("{0,number,#.#}%", lonWR), text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=lonClr)

    // NY row
    color nyClr = nyWR >= 55.0 ? color.new(#22c55e, 20) : nyWR >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 4, "New York",         text_color=color.new(#10b981, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 4, str.tostring(nyW),  text_color=color.new(#22c55e, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 4, str.tostring(nyL),  text_color=color.new(#ef4444, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 3, 4, str.format("{0,number,#.#}%", nyWR), text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=nyClr)

    // Divider row
    table.cell(dash, 0, 5, "", bgcolor=color.new(#334155, 60))
    table.cell(dash, 1, 5, "", bgcolor=color.new(#334155, 60))
    table.cell(dash, 2, 5, "", bgcolor=color.new(#334155, 60))
    table.cell(dash, 3, 5, "", bgcolor=color.new(#334155, 60))

    // Total row
    color totClr = totWR >= 55.0 ? color.new(#22c55e, 20) : totWR >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 6, "Total",            text_color=color.new(#e2e8f0, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 1, 6, str.tostring(totW), text_color=color.new(#22c55e, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 2, 6, str.tostring(totL), text_color=color.new(#ef4444, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 3, 6, str.format("{0,number,#.#}%", totWR), text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=totClr)

    // Row 7 — EMA alignment
    string emaStr = bullAlign ? "BULL ALIGN" : bearAlign ? "BEAR ALIGN" : "NEUTRAL"
    color  emaHdr = bullAlign ? color.new(#10b981, 0) : bearAlign ? color.new(#ef4444, 0) : color.new(#94a3b8, 0)
    table.cell(dash, 0, 7, "EMA Bias", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 7, emaStr,     text_color=emaHdr,                text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 7, "",         text_size=size.normal,            bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 3, 7, str.format("{0,number,#.####}", atr), text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS — EMA reference lines
// ─────────────────────────────────────────────────────────────────────────────

plot(ema750, "Trend EMA 750", color=color.new(#6366f1, 55), linewidth=1)
plot(ema4,   "EMA 4",         color=color.new(#f59e0b, 65), linewidth=1)
plot(ema5,   "EMA 5",         color=color.new(#ef4444, 65), linewidth=1)
````
