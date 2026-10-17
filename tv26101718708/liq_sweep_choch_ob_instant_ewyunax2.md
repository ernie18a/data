# Liq Sweep + CHoCH + OB Instant

- url: https://www.tradingview.com/script/EwYuNAx2-Liq-Sweep-CHoCH-OB-Instant/
- type: indicator
- pine_id: PUB;cd7b8dd7d2c14826a23703725afe62c6
- version: 2.0

## Description

LIQ SWEEP + CHoCH + OB INSTANT

This script is a three-stage liquidity-trap detector that resolves a full smart-money sequence into a single confirmed entry, with no retest wait. It is not a collection of separate SMC tools stacked on one chart. It is one state machine in which each stage must validate before the next can arm, and only the completed sequence produces a signal.


WHY THE SEQUENCE MATTERS

Most liquidity-based scripts fire on a single event: a sweep, or a change of character, or an order-block tap. Each of those in isolation is noisy. Sweeps occur constantly without follow-through. CHoCH prints in chop with no displacement behind it. Order blocks form everywhere.

The idea here is that none of those events is treated as a signal on its own. They are treated as preconditions that must occur in order, within a defined window, all supporting the same directional thesis. The script formalizes the trap as a sequence and refuses to act until that sequence completes. A sweep with no CHoCH is discarded. A CHoCH with no identifiable order block produces nothing. Only the full chain fires.


HOW THE COMPONENTS INTEGRATE

STAGE 1 — LIQUIDITY SWEEP
Pivot-based swing highs and lows are tracked in rolling arrays. A sweep registers only when price wicks through a tracked level and closes back inside it, marking that resting liquidity above a high or below a low has been taken rather than genuinely broken. Each sweep opens a candidate setup and records the opposite-side structure level that will be watched next.

STAGE 2 — CHANGE OF CHARACTER
A candidate is promoted only if price then closes through that opposite structure level within a user-set lookback window. This is the directional confirmation: after buy-side liquidity is swept, a close below the prior swing low confirms reversal intent, and the mirror applies for the bullish case. Candidates that never produce a CHoCH inside the window expire and are discarded, so a stale sweep from fifty bars ago cannot fire later.

STAGE 3 — ORDER BLOCK AS ENTRY
On a confirmed CHoCH, the script scans back for the last opposing candle before the displacement move and marks that zone as the order block, along with its 50 percent midline. Because the sweep and the CHoCH have already validated the setup, order-block identification is treated as the entry trigger itself rather than waiting for a retest that may never come. The stop is placed beyond the swept level, since that level is what the setup is predicated on. The target is derived either from a configurable risk-to-reward multiple of the stop distance, or from an optional fixed-percentage mode.

The three stages are not independent indicators sharing a chart. Stage 2 cannot exist without Stage 1's swept level. Stage 3's scan window is anchored to Stage 2's displacement bar. The stop is defined by Stage 1's level. Removing any stage collapses the logic entirely, which is why they are integrated into one state machine rather than published as separate tools.


WHAT YOU SEE

Confirmed setups draw the swept-liquidity line, the accumulation zone spanning sweep to CHoCH, the highlighted CHoCH candle, and the order-block zone with its midline. Entries print a labeled trade box showing entry, stop, target and risk-to-reward. Exits are marked with the realized result as take-profit, stop, or time-based close. A status dashboard summarizes current stage, direction, swept level, active order block, setup counts, exit mode, position state, and trade management values.


SETTINGS

Structure — swing lookback for pivot detection, wick-sweep requirement, CHoCH lookback window.
Order Block — scan depth, minimum rejection-wick ratio, midline toggle, maximum zone age.
Trade Management — risk-to-reward ratio, stop buffer beyond the swept level, maximum bars in trade, cooldown between signals, RSI filter bounds, label toggles.
Exit Management — optional percentage-based take-profit and stop mode. Default behavior uses the risk-to-reward derived from the swept level.
Visuals — zone colors, ghost candles, dashboard, per-stage step labels.


HOW TO USE

Apply to a clean chart. Watch the dashboard stage indicator move from scanning, to sweep, to CHoCH as a setup builds. A trade box prints when the order block is identified on a confirmed bar. Tune the swing lookback and order-block scan depth to your instrument and timeframe. The tooltips include suggested starting ranges for futures and crypto. The risk-to-reward ratio controls target distance measured off the swept-level stop.


REFERENCE SETTINGS

The defaults are deliberately neutral. As a concrete starting point, these are the values I run on MNQ:

Swing Lookback 6
CHoCH Lookback 10
OB Scan Bars 50
Enable % Exit Mode: on
TP 0.25%
SL 1.0%
Max Bars in Trade 55
Cooldown Bars 3

These are a starting point for one instrument, not an optimized or recommended configuration, and they are not intended to suggest any particular outcome. Different instruments, timeframes and volatility conditions will call for different values. Treat them as a place to begin your own testing rather than a setting to adopt as-is.


NON-REPAINTING

All structure, sweep, CHoCH and order-block evaluations run on confirmed bar closes. Pivot detection uses right-side confirmation. Signals do not repaint once a bar has closed. Take-profit and stop levels are evaluated intrabar for realistic exit marking, while the entry itself is fixed on the confirmed bar that completes the sequence.


DISCLAIMER

For educational and informational purposes only. This is not financial advice, and nothing here is a guarantee of future results. Markets are uncertain and past behavior does not predict future behavior. Always do your own analysis and use proper risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Liq Sweep + CHoCH + OB Instant", overlay=true,
     max_boxes_count=300, max_lines_count=300, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────────
grp_str = "Structure Settings"
grp_ob  = "Order Block Settings"
grp_tm  = "Trade Management"
grp_vis = "Visuals"

// Structure
swingLen     = input.int(10,    "Swing Lookback",              group=grp_str, minval=3,  maxval=50,
               tooltip="Bars each side for pivot detection.\nFutures: 8–15   Crypto: 10–20")
sweepWick    = input.bool(true, "Require Wick Sweep (not close)", group=grp_str,
               tooltip="ON: sweep = wick through level, close back inside (cleaner)\nOFF: any close through level counts")
chochBars    = input.int(20,    "CHoCH Lookback (bars)",       group=grp_str, minval=5,  maxval=100,
               tooltip="How many bars after sweep to watch for CHoCH confirmation")

// OB
obScanBars   = input.int(15,    "OB Scan Bars",                group=grp_ob,  minval=3,  maxval=50,
               tooltip="Bars back from CHoCH to find the OB candle.\nFutures: 8–15   Crypto: 10–20")
rejectionWick= input.float(0.3, "Min Rejection Wick Ratio",    group=grp_ob,  minval=0.0, maxval=1.0, step=0.05,
               tooltip="Rejection candle filter: wick/total range ratio.\n0 = any candle   0.3 = meaningful wick required\nHigher = more selective entries")
showOBMid    = input.bool(true, "Show OB Midline",             group=grp_ob,
               tooltip="50% level of OB — institutions often defend this exact level")
obExpire     = input.int(60,    "OB Max Age (bars)",           group=grp_ob,  minval=5,  maxval=300)

// Trade Management
rrRatio      = input.float(3.0, "Risk:Reward Ratio",           group=grp_tm,  minval=0.5, maxval=10.0, step=0.5,
               tooltip="TP distance = SL distance × this ratio.\nDefault 1:3 as described in the strategy.\nFutures: 2.0–4.0   Crypto: 2.0–5.0")
slBuffer     = input.float(0.1, "SL Buffer % above swept high",group=grp_tm,  minval=0.0, maxval=2.0, step=0.05,
               tooltip="Extra buffer above swept high for SL.\nFutures: 0.05–0.15%   Crypto: 0.1–0.3%")
maxBars      = input.int(50,    "Max Bars in Trade",           group=grp_tm,  minval=1,  maxval=500,
               tooltip="Time-based exit. Set low (1-5) for a fixed-hold scalp.")
cooldown     = input.int(1,     "Cooldown Bars",               group=grp_tm,  minval=0,  maxval=100,
               tooltip="Bars between signals. Default 1 — the 3-step A+M+D sequence is already the quality filter.\nSet to 0 to never block consecutive signals.")
rsiLen       = input.int(14,    "RSI Length",                  group=grp_tm)
rsiOB        = input.int(70,    "RSI OB Filter",               group=grp_tm,  minval=60, maxval=90)
rsiOS        = input.int(30,    "RSI OS Filter",               group=grp_tm,  minval=10, maxval=40)
showSig      = input.bool(true, "Show Entry Labels",           group=grp_tm)
showTPSL     = input.bool(true, "Show TP/SL Lines",            group=grp_tm)
showRR       = input.bool(true, "Show RR on Entry Label",      group=grp_tm)

// Exit Management
grp_coda     = "Exit Management"
codaOn       = input.bool(false,"Enable % Exit Mode",    group=grp_coda,
               tooltip="ON = use % based TP/SL exits\nOFF = uses RR ratio from swept level (native)")
tpPct        = input.float(0.5, "TP %",                         group=grp_coda, minval=0.05, maxval=20.0, step=0.05,
               tooltip="Take Profit %. Active when % Exit Mode is ON.\nFutures (MNQ): 0.3–0.8%   Crypto: 1.0–3.0%")
slPct        = input.float(0.3, "SL %",                         group=grp_coda, minval=0.05, maxval=20.0, step=0.05,
               tooltip="Stop Loss %. Active when % Exit Mode is ON.\nFutures (MNQ): 0.2–0.5%   Crypto: 0.5–2.0%")
codaMaxBars  = input.int(50,    "Max Bars in Trade",            group=grp_coda, minval=1,  maxval=500,
               tooltip="Time-based exit. Set low (1-5) for a fixed-hold scalp.")
codaCooldown = input.int(3,     "Cooldown Bars",                group=grp_coda, minval=0,  maxval=100)

// Visuals
colSweepH    = input.color(color.new(#FF4466,  0), "BSL Sweep Line",    group=grp_vis)
colSweepL    = input.color(color.new(#00FF88,  0), "SSL Sweep Line",    group=grp_vis)
colChoch     = input.color(color.new(#FFD700,  0), "CHoCH Arrow",       group=grp_vis)
colOBBear    = input.color(color.new(#AA00FF, 82), "IS Supply OB Zone", group=grp_vis)
colOBBull    = input.color(color.new(#00F5D4, 82), "ID Demand OB Zone", group=grp_vis)
colSweptLiq  = input.color(color.new(#FF8800, 70), "Swept Liq Level",   group=grp_vis)
showGhost    = input.bool(true,  "Ghost Candles",               group=grp_vis)
showDash     = input.bool(true,  "Show Dashboard",              group=grp_vis)
showSteps    = input.bool(true,  "Show Step Labels on Chart",   group=grp_vis,
               tooltip="Labels each confirmed step: SWEEP → CHoCH → OB")

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
color C_TEAL   = #00F5D4
color C_PURPLE = #AA00FF
color C_GOLD   = #FFD700
color C_BULL   = #00FF88
color C_BEAR   = #FF4466
color C_ORANGE = #FF8800
color C_MUTED  = color.new(#AAAAAA, 40)
color C_HDR_BG = color.new(#0d1f1e,  0)
color C_COL_BG = color.new(#0a0a14, 10)
color C_COL_ALT= color.new(#0d1117, 30)
color C_STRIPE = color.new(#00F5D4, 20)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  g_inTrade   = false
var int   lastSigBar  = 0
var int   entryBar    = 0
var float entryPrice  = na
var bool  g_isLong    = false
var float g_tp        = na
var float g_sl        = na
var float g_sweptLiq  = na
var line  g_tpLine    = na
var line  g_slLine    = na
var line  g_liqLine   = na
var box   g_tpBox     = na
var box   g_slBox     = na
var line  g_entryLine = na

// ─────────────────────────────────────────────────────────────────────────────
// SWING DETECTION
// ─────────────────────────────────────────────────────────────────────────────
float pvtH = ta.pivothigh(high, swingLen, swingLen)
float pvtL = ta.pivotlow(low,   swingLen, swingLen)

var float[] swingHighs = array.new<float>()
var int[]   swingHighB = array.new<int>()
var float[] swingLows  = array.new<float>()
var int[]   swingLowB  = array.new<int>()

if not na(pvtH) and barstate.isconfirmed
    array.unshift(swingHighs, pvtH)
    array.unshift(swingHighB, bar_index - swingLen)
    if array.size(swingHighs) > 20
        array.pop(swingHighs)
        array.pop(swingHighB)

if not na(pvtL) and barstate.isconfirmed
    array.unshift(swingLows, pvtL)
    array.unshift(swingLowB, bar_index - swingLen)
    if array.size(swingLows) > 20
        array.pop(swingLows)
        array.pop(swingLowB)

float recentHigh  = array.size(swingHighs) > 0 ? array.get(swingHighs, 0) : na
float recentLow   = array.size(swingLows)  > 0 ? array.get(swingLows,  0) : na
int   recentHighB = array.size(swingHighB) > 0 ? array.get(swingHighB, 0) : na
int   recentLowB  = array.size(swingLowB)  > 0 ? array.get(swingLowB,  0) : na

// ─────────────────────────────────────────────────────────────────────────────
// RSI
// ─────────────────────────────────────────────────────────────────────────────
float rsi14 = ta.rsi(close, rsiLen)

// ─────────────────────────────────────────────────────────────────────────────
// SETUP STATE MACHINE
// ─────────────────────────────────────────────────────────────────────────────
int ST_SWEEP = 1
int ST_CHOCH = 2
int ST_OB    = 3
int ST_DONE  = 4

type LiqSetup
    bool  isBear
    float sweptLevel
    int   sweepBar
    float chochLevel
    int   chochBar
    float obTop
    float obBot
    float obMid
    int   obBar
    int   state
    int   stateBar
    box   obBox      = na
    box   sweepBox   = na
    box   chochBox   = na
    line  obMidLine  = na
    line  sweptLine  = na

var LiqSetup[] setups = array.new<LiqSetup>()

// ─────────────────────────────────────────────────────────────────────────────
// OB FINDER
// ─────────────────────────────────────────────────────────────────────────────
f_findOB(bool isBearSetup, int fromBar) =>
    float obTop = na
    float obBot = na
    int   obIdx = na
    for lb = 1 to obScanBars
        if lb <= fromBar
            float rngC = high[lb] - low[lb]
            float bodC = math.abs(close[lb] - open[lb])
            float wikC = rngC > 0 ? (rngC - bodC) / rngC : 0.0
            bool  wikOK = wikC >= rejectionWick
            if isBearSetup
                if close[lb] > open[lb] and wikOK
                    obTop := high[lb]
                    obBot := math.min(open[lb], close[lb])
                    obIdx := bar_index - lb
                    break
            else
                if close[lb] < open[lb] and wikOK
                    obTop := math.max(open[lb], close[lb])
                    obBot := low[lb]
                    obIdx := bar_index - lb
                    break
    [obTop, obBot, obIdx]

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — SWEEP DETECTION
// ─────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed and not na(recentHigh) and not na(recentLow)
    bool bslSwept = sweepWick ? (high > recentHigh and close < recentHigh) : (close > recentHigh and close[1] <= recentHigh)
    bool sslSwept = sweepWick ? (low < recentLow and close > recentLow) : (close < recentLow and close[1] >= recentLow)

    if bslSwept
        LiqSetup s = LiqSetup.new(
             isBear      = true,
             sweptLevel  = recentHigh,
             sweepBar    = bar_index,
             chochLevel  = not na(recentLow) ? recentLow : close * 0.99,
             chochBar    = 0,
             obTop       = na,
             obBot       = na,
             obMid       = na,
             obBar       = 0,
             state       = ST_SWEEP,
             stateBar    = bar_index)
        array.unshift(setups, s)
    if sslSwept
        LiqSetup s = LiqSetup.new(
             isBear      = false,
             sweptLevel  = recentLow,
             sweepBar    = bar_index,
             chochLevel  = not na(recentHigh) ? recentHigh : close * 1.01,
             chochBar    = 0,
             obTop       = na,
             obBot       = na,
             obMid       = na,
             obBar       = 0,
             state       = ST_SWEEP,
             stateBar    = bar_index)
        array.unshift(setups, s)

if array.size(setups) > 8
    LiqSetup old = array.pop(setups)
    if not na(old.obBox)
        box.delete(old.obBox)
    if not na(old.sweepBox)
        box.delete(old.sweepBox)
    if not na(old.chochBox)
        box.delete(old.chochBox)
    if not na(old.obMidLine)
        line.delete(old.obMidLine)
    if not na(old.sweptLine)
        line.delete(old.sweptLine)

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY READINESS
// ─────────────────────────────────────────────────────────────────────────────
int   activeCooldown = codaOn ? codaCooldown : cooldown
int   activeMaxBars  = codaOn ? codaMaxBars  : maxBars
bool  cdOK           = bar_index - lastSigBar >= activeCooldown
bool  ready          = not g_inTrade and cdOK and barstate.isconfirmed
bool  rsiLongOK      = rsi14 < rsiOB
bool  rsiShortOK     = rsi14 > rsiOS
bool  buySignal      = false
bool  sellSignal     = false
float sigSwept       = na
float sigOBTop       = na
float sigOBBot       = na
int   sigOBBar       = 0

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 + 3 — CHoCH DETECTION + OB IDENTIFICATION → INSTANT SIGNAL
// ─────────────────────────────────────────────────────────────────────────────
int _sz = array.size(setups)
if _sz > 0
    for _i = 0 to _sz - 1
        LiqSetup s = array.get(setups, _i)

        if s.state == ST_SWEEP and (bar_index - s.stateBar) > chochBars and barstate.isconfirmed
            s.state := ST_DONE

        if s.state == ST_SWEEP and barstate.isconfirmed
            if s.isBear
                bool choch = close < s.chochLevel
                if choch
                    s.state    := ST_CHOCH
                    s.chochBar := bar_index
                    s.stateBar := bar_index

                    s.sweptLine := line.new(s.sweepBar, s.sweptLevel, bar_index + obExpire, s.sweptLevel,
                         color=color.new(colSweepH, 30), style=line.style_dotted, width=1)

                    if showSteps
                        // Full accumulation zone — sweep candle to CHoCH candle
                        s.sweepBox := box.new(s.sweepBar, s.sweptLevel, bar_index, s.chochLevel,
                             border_color=color.new(C_ORANGE, 35), border_style=line.style_dashed,
                             border_width=2, bgcolor=color.new(C_ORANGE, 85))
                        // CHoCH candle highlight
                        s.chochBox := box.new(bar_index, high, bar_index + 1, low,
                             border_color=color.new(C_GOLD, 25), border_style=line.style_dashed,
                             border_width=2, bgcolor=color.new(C_GOLD, 82))

                    [oT, oB, oBI] = f_findOB(true, bar_index)
                    if not na(oT)
                        s.obTop  := oT
                        s.obBot  := oB
                        s.obMid  := math.avg(oT, oB)
                        s.obBar  := oBI
                        s.state  := ST_OB

                        s.obBox := box.new(oBI, oT, oBI + 6, oB,
                             border_color=color.new(colOBBear, 30),
                             bgcolor=colOBBear, border_width=1)
                        if showOBMid
                            s.obMidLine := line.new(oBI, s.obMid, oBI + 6, s.obMid,
                                 color=color.new(C_BEAR, 40), style=line.style_dashed, width=1)

                        // IS zone box drawn above — purple, no text label needed

                        if ready and rsiShortOK and not sellSignal
                            sellSignal := true
                            sigSwept   := s.sweptLevel
                            sigOBTop   := oT
                            sigOBBot   := oB
                            sigOBBar   := oBI

            else
                bool choch = close > s.chochLevel
                if choch
                    s.state    := ST_CHOCH
                    s.chochBar := bar_index
                    s.stateBar := bar_index

                    s.sweptLine := line.new(s.sweepBar, s.sweptLevel, bar_index + obExpire, s.sweptLevel,
                         color=color.new(colSweepL, 30), style=line.style_dotted, width=1)

                    if showSteps
                        // Full accumulation zone — sweep candle to CHoCH candle
                        s.sweepBox := box.new(s.sweepBar, s.chochLevel, bar_index, s.sweptLevel,
                             border_color=color.new(C_ORANGE, 35), border_style=line.style_dashed,
                             border_width=2, bgcolor=color.new(C_ORANGE, 85))
                        // CHoCH candle highlight
                        s.chochBox := box.new(bar_index, high, bar_index + 1, low,
                             border_color=color.new(C_GOLD, 25), border_style=line.style_dashed,
                             border_width=2, bgcolor=color.new(C_GOLD, 82))

                    [oT, oB, oBI] = f_findOB(false, bar_index)
                    if not na(oT)
                        s.obTop  := oT
                        s.obBot  := oB
                        s.obMid  := math.avg(oT, oB)
                        s.obBar  := oBI
                        s.state  := ST_OB

                        s.obBox := box.new(oBI, oT, oBI + 6, oB,
                             border_color=color.new(colOBBull, 30),
                             bgcolor=colOBBull, border_width=1)
                        if showOBMid
                            s.obMidLine := line.new(oBI, s.obMid, oBI + 6, s.obMid,
                                 color=color.new(C_BULL, 40), style=line.style_dashed, width=1)

                        // ID zone box drawn above — teal, no text label needed

                        if ready and rsiLongOK and not buySignal
                            buySignal  := true
                            sigSwept   := s.sweptLevel
                            sigOBTop   := oT
                            sigOBBot   := oB
                            sigOBBar   := oBI

        if s.state == ST_OB and (bar_index - s.chochBar) > obExpire and barstate.isconfirmed
            s.state := ST_DONE
            if not na(s.obBox)
                box.set_bgcolor(s.obBox, color.new(C_MUTED, 92))



// ─────────────────────────────────────────────────────────────────────────────
// EXTEND TRADE ZONE BOXES — keep right edge at current bar + buffer
// ─────────────────────────────────────────────────────────────────────────────
if g_inTrade
    if not na(g_tpBox)
        box.set_right(g_tpBox, bar_index + 3)
    if not na(g_slBox)
        box.set_right(g_slBox, bar_index + 3)
    if not na(g_entryLine)
        line.set_x2(g_entryLine, bar_index + 3)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE EXITS — intrabar TP/SL, confirmed time exit
// ─────────────────────────────────────────────────────────────────────────────
if g_inTrade
    bool tpHit    = g_isLong ? high >= g_tp : low  <= g_tp
    bool slHit    = g_isLong ? low  <= g_sl : high >= g_sl
    bool timeExit = barstate.isconfirmed and (bar_index - entryBar) >= activeMaxBars

    if tpHit
        float pnl = math.abs(g_tp - entryPrice) / entryPrice * 100
        g_inTrade := false
        if not na(g_tpLine)
            line.delete(g_tpLine)
        if not na(g_slLine)
            line.delete(g_slLine)
        if not na(g_liqLine)
            line.delete(g_liqLine)
        if not na(g_tpBox)
            box.set_bgcolor(g_tpBox, color.new(C_TEAL, 92))
            box.set_border_color(g_tpBox, color.new(C_TEAL, 70))
        if not na(g_slBox)
            box.set_bgcolor(g_slBox, color.new(C_MUTED, 95))
            box.set_border_color(g_slBox, color.new(C_MUTED, 80))
        if not na(g_entryLine)
            line.set_color(g_entryLine, color.new(color.white, 80))
        if not na(g_tpBox)
            box.set_right(g_tpBox, bar_index)
        if not na(g_slBox)
            box.set_right(g_slBox, bar_index)
        if not na(g_entryLine)
            line.set_x2(g_entryLine, bar_index)
        label.new(bar_index, g_tp, " ✦ TP  +" + str.tostring(pnl, "#.##") + "% ",
             yloc=yloc.price,
             style=g_isLong ? label.style_label_down : label.style_label_up,
             color=color.new(C_TEAL, 85), textcolor=C_TEAL, size=size.small)

    else if slHit
        float pnl = math.abs(g_sl - entryPrice) / entryPrice * 100
        g_inTrade := false
        if not na(g_tpLine)
            line.delete(g_tpLine)
        if not na(g_slLine)
            line.delete(g_slLine)
        if not na(g_liqLine)
            line.delete(g_liqLine)
        if not na(g_tpBox)
            box.set_bgcolor(g_tpBox, color.new(C_MUTED, 95))
            box.set_border_color(g_tpBox, color.new(C_MUTED, 80))
        if not na(g_slBox)
            box.set_bgcolor(g_slBox, color.new(C_BEAR, 88))
            box.set_border_color(g_slBox, color.new(C_BEAR, 60))
        if not na(g_entryLine)
            line.set_color(g_entryLine, color.new(color.white, 80))
        if not na(g_tpBox)
            box.set_right(g_tpBox, bar_index)
        if not na(g_slBox)
            box.set_right(g_slBox, bar_index)
        if not na(g_entryLine)
            line.set_x2(g_entryLine, bar_index)
        label.new(bar_index, g_sl, " ✦ SL  -" + str.tostring(pnl, "#.##") + "% ",
             yloc=yloc.price,
             style=g_isLong ? label.style_label_up : label.style_label_down,
             color=color.new(C_BEAR, 85), textcolor=C_BEAR, size=size.tiny)

    else if timeExit
        float exitPnl = g_isLong ? (close - entryPrice) / entryPrice * 100 : (entryPrice - close) / entryPrice * 100
        g_inTrade := false
        if not na(g_tpLine)
            line.delete(g_tpLine)
        if not na(g_slLine)
            line.delete(g_slLine)
        if not na(g_liqLine)
            line.delete(g_liqLine)
        if not na(g_tpBox)
            box.set_bgcolor(g_tpBox, color.new(C_MUTED, 92))
            box.set_border_color(g_tpBox, color.new(C_MUTED, 75))
        if not na(g_slBox)
            box.set_bgcolor(g_slBox, color.new(C_MUTED, 95))
            box.set_border_color(g_slBox, color.new(C_MUTED, 80))
        if not na(g_entryLine)
            line.set_color(g_entryLine, color.new(color.white, 80))
        if not na(g_tpBox)
            box.set_right(g_tpBox, bar_index)
        if not na(g_slBox)
            box.set_right(g_slBox, bar_index)
        if not na(g_entryLine)
            line.set_x2(g_entryLine, bar_index)
        label.new(bar_index, close, " ✦ TIME  " + (exitPnl >= 0 ? "+" : "") + str.tostring(exitPnl, "#.##") + "% ",
             yloc=yloc.price,
             style=g_isLong ? label.style_label_up : label.style_label_down,
             color=color.new(C_MUTED, 85), textcolor=C_MUTED, size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE EXECUTION
// ─────────────────────────────────────────────────────────────────────────────
if sellSignal and not g_inTrade
    g_inTrade    := true
    g_isLong     := false
    entryBar     := bar_index
    entryPrice   := close
    lastSigBar   := bar_index
    g_sweptLiq   := sigSwept

    float slLevel  = codaOn ? close * (1 + slPct / 100) : (not na(sigSwept) ? sigSwept * (1 + slBuffer / 100) : close * (1 + 0.5 / 100))
    float slDist   = math.abs(slLevel - close)
    float tpLevel  = codaOn ? close * (1 - tpPct / 100) : close - slDist * rrRatio

    g_sl := slLevel
    g_tp := tpLevel

    if not na(g_tpLine)
        line.delete(g_tpLine)
    if not na(g_slLine)
        line.delete(g_slLine)
    if not na(g_liqLine)
        line.delete(g_liqLine)
    if not na(g_tpBox)
        box.delete(g_tpBox)
    if not na(g_slBox)
        box.delete(g_slBox)
    if not na(g_entryLine)
        line.delete(g_entryLine)

    // Two-tone trade zone box — purple top (entry→TP) + red bottom (SL→entry)
    g_tpBox     := box.new(bar_index, g_tp, bar_index + 3, entryPrice,
         border_color=color.new(C_PURPLE, 30), border_width=1,
         bgcolor=color.new(C_PURPLE, 78))
    g_slBox     := box.new(bar_index, entryPrice, bar_index + 3, g_sl,
         border_color=color.new(C_BEAR, 30), border_width=1,
         bgcolor=color.new(C_BEAR, 82))
    g_entryLine := line.new(bar_index, entryPrice, bar_index + 3, entryPrice,
         color=color.new(color.white, 55), style=line.style_solid, width=1)

    if showTPSL
        g_tpLine  := line.new(bar_index, g_tp, bar_index + activeMaxBars, g_tp,
             color=color.new(C_TEAL, 25), style=line.style_dashed, width=2)
        g_slLine  := line.new(bar_index, g_sl, bar_index + activeMaxBars, g_sl,
             color=color.new(C_BEAR, 40), style=line.style_dashed, width=1)
        g_liqLine := line.new(bar_index, sigSwept, bar_index + activeMaxBars, sigSwept,
             color=color.new(C_ORANGE, 40), style=line.style_dotted, width=1)

    if showSig
        float tpDist = math.abs(entryPrice - g_tp)
        float rrShow = slDist > 0 ? tpDist / slDist : 0.0
        string rrTxt = showRR ? "  1:" + str.tostring(rrShow, "#.##") + " RR" : ""
        line.new(sigOBBar, math.avg(sigOBTop, sigOBBot), bar_index, entryPrice,
             color=color.new(colSweptLiq, 30), style=line.style_dotted, width=1)
        label.new(bar_index, na,
             "▼ SELL" + rrTxt + "\nIN: " + str.tostring(entryPrice, format.mintick) + "\nSL: " + str.tostring(g_sl, format.mintick) + "\nTP: " + str.tostring(g_tp, format.mintick),
             yloc=yloc.abovebar, style=label.style_label_down,
             color=color.new(C_BEAR, 55), textcolor=C_BEAR, size=size.small,
             text_font_family=font.family_monospace)

else if buySignal and not g_inTrade
    g_inTrade    := true
    g_isLong     := true
    entryBar     := bar_index
    entryPrice   := close
    lastSigBar   := bar_index
    g_sweptLiq   := sigSwept

    float slLevel  = codaOn ? close * (1 - slPct / 100) : (not na(sigSwept) ? sigSwept * (1 - slBuffer / 100) : close * (1 - 0.5 / 100))
    float slDist   = math.abs(close - slLevel)
    float tpLevel  = codaOn ? close * (1 + tpPct / 100) : close + slDist * rrRatio

    g_sl := slLevel
    g_tp := tpLevel

    if not na(g_tpLine)
        line.delete(g_tpLine)
    if not na(g_slLine)
        line.delete(g_slLine)
    if not na(g_liqLine)
        line.delete(g_liqLine)
    if not na(g_tpBox)
        box.delete(g_tpBox)
    if not na(g_slBox)
        box.delete(g_slBox)
    if not na(g_entryLine)
        line.delete(g_entryLine)

    // Two-tone trade zone box — teal top (entry→TP) + red bottom (SL→entry)
    g_tpBox     := box.new(bar_index, g_tp, bar_index + 3, entryPrice,
         border_color=color.new(C_TEAL, 30), border_width=1,
         bgcolor=color.new(C_TEAL, 78))
    g_slBox     := box.new(bar_index, entryPrice, bar_index + 3, g_sl,
         border_color=color.new(C_BEAR, 30), border_width=1,
         bgcolor=color.new(C_BEAR, 82))
    g_entryLine := line.new(bar_index, entryPrice, bar_index + 3, entryPrice,
         color=color.new(color.white, 55), style=line.style_solid, width=1)

    if showTPSL
        g_tpLine  := line.new(bar_index, g_tp, bar_index + activeMaxBars, g_tp,
             color=color.new(C_TEAL, 25), style=line.style_dashed, width=2)
        g_slLine  := line.new(bar_index, g_sl, bar_index + activeMaxBars, g_sl,
             color=color.new(C_BEAR, 40), style=line.style_dashed, width=1)
        g_liqLine := line.new(bar_index, sigSwept, bar_index + activeMaxBars, sigSwept,
             color=color.new(C_ORANGE, 40), style=line.style_dotted, width=1)

    if showSig
        float tpDist = math.abs(g_tp - entryPrice)
        float rrShow = slDist > 0 ? tpDist / slDist : 0.0
        string rrTxt = showRR ? "  1:" + str.tostring(rrShow, "#.##") + " RR" : ""
        line.new(sigOBBar, math.avg(sigOBTop, sigOBBot), bar_index, entryPrice,
             color=color.new(colSweptLiq, 30), style=line.style_dotted, width=1)
        label.new(bar_index, na,
             "▲ BUY" + rrTxt + "\nIN: " + str.tostring(entryPrice, format.mintick) + "\nSL: " + str.tostring(g_sl, format.mintick) + "\nTP: " + str.tostring(g_tp, format.mintick),
             yloc=yloc.belowbar, style=label.style_label_up,
             color=color.new(C_BULL, 55), textcolor=C_BULL, size=size.small,
             text_font_family=font.family_monospace)

// No plotshape triangles — trade zone boxes replace them

// ─────────────────────────────────────────────────────────────────────────────
// GHOST CANDLES
// ─────────────────────────────────────────────────────────────────────────────
barcolor(showGhost ? color.new(color.gray, 80) : na)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD — 9x4 status bar, bottom_center
// ─────────────────────────────────────────────────────────────────────────────
if showDash and barstate.islast

    int   newestState = 0
    bool  newestBear  = true
    float newestSwept = na
    float newestOBTop = na
    float newestOBBot = na
    int   _dsz = array.size(setups)
    if _dsz > 0
        for _di = 0 to _dsz - 1
            LiqSetup _s = array.get(setups, _di)
            if _s.state != ST_DONE and _s.state > newestState
                newestState := _s.state
                newestBear  := _s.isBear
                newestSwept := _s.sweptLevel
                newestOBTop := _s.obTop
                newestOBBot := _s.obBot

    int cntSweep = 0
    int cntChoch = 0
    int cntOB    = 0
    if _dsz > 0
        for _di = 0 to _dsz - 1
            int st = array.get(setups, _di).state
            if st == ST_SWEEP
                cntSweep += 1
            else if st == ST_CHOCH
                cntChoch += 1
            else if st == ST_OB
                cntOB += 1

    string stateTxt = newestState == ST_OB ? "④ WATCHING OB" : newestState == ST_CHOCH ? "③ CHoCH ✓" : newestState == ST_SWEEP ? "② SWEEP ✓" : "SCANNING..."
    color  stateCol = newestState == ST_OB ? C_BULL : newestState == ST_CHOCH ? C_GOLD : newestState == ST_SWEEP ? C_ORANGE : C_MUTED

    string dirTxt  = newestState == 0 ? "--" : newestBear ? "BEARISH ▼" : "BULLISH ▲"
    color  dirCol  = newestState == 0 ? C_MUTED : newestBear ? C_BEAR : C_BULL

    string sweptTxt = na(newestSwept) ? "--" : str.tostring(newestSwept, format.mintick)
    string obTxt    = na(newestOBTop) ? "--" : str.tostring(newestOBBot, format.mintick) + "–" + str.tostring(newestOBTop, format.mintick)

    string posTxt  = not g_inTrade ? "  FLAT  --" : g_isLong ? "LONG   ●" : "SHORT  ●"
    color  posCol  = not g_inTrade ? C_MUTED : g_isLong ? C_BULL : C_BEAR
    string tpDTxt  = not g_inTrade or na(g_tp) ? "--" : str.tostring(g_tp, format.mintick)
    string slDTxt  = not g_inTrade or na(g_sl) ? "--" : str.tostring(g_sl, format.mintick)
    string cdTxt   = g_inTrade ? "IN TRADE" : bar_index - lastSigBar < activeCooldown ? "CD " + str.tostring(activeCooldown - (bar_index - lastSigBar)) + "b" : "READY ✅"
    color  cdCol   = g_inTrade ? C_GOLD : bar_index - lastSigBar < activeCooldown ? C_GOLD : C_BULL

    var table dash = table.new(position.bottom_center, 9, 4,
         bgcolor=C_COL_BG, border_width=1, border_color=color.new(C_TEAL, 55))

    for _c = 0 to 8
        table.cell(dash, _c, 0, "", bgcolor=C_STRIPE, text_size=size.tiny)
    table.cell(dash, 0, 0, " ◈ LIQ SWEEP + CHoCH + OB INSTANT ◈ ",
         text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 8, 0, " CONFIRMED ◈ ",
         text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)

    table.cell(dash, 0, 1, " ◈ STAGE ",       text_color=stateCol, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 1, " ◈ DIRECTION ",   text_color=dirCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#0a0a20, 30))
    table.cell(dash, 2, 1, " ◈ SWEPT LIQ ",   text_color=C_ORANGE, text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#1a0a00, 30))
    table.cell(dash, 3, 1, " ◈ ORDER BLOCK ", text_color=newestBear ? C_BEAR : C_BULL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#001a14, 30))
    table.cell(dash, 4, 1, " ◈ SETUPS ",      text_color=cntOB > 0 ? C_BULL : C_MUTED, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 5, 1, " ◈ EXIT MODE ",   text_color=C_TEAL,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 1, " ◈ POSITION ",    text_color=posCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 7, 1, " ◈ TP / SL ",     text_color=C_TEAL,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 1, " ◈ STATUS ",      text_color=cdCol,    text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

    table.cell(dash, 0, 2, " " + stateTxt,    text_color=stateCol, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 2, " " + dirTxt,      text_color=dirCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#0a0a20, 40))
    table.cell(dash, 2, 2, " " + sweptTxt,    text_color=C_ORANGE, text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#1a0a00, 40))
    table.cell(dash, 3, 2, " " + obTxt,       text_color=newestBear ? C_BEAR : C_BULL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#001a14, 40))
    table.cell(dash, 4, 2, " SW " + str.tostring(cntSweep) + "  CH " + str.tostring(cntChoch) + "  OB " + str.tostring(cntOB), text_color=cntOB > 0 ? C_BULL : C_MUTED, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    float dashRR = codaOn ? (slPct > 0 ? tpPct / slPct : 0.0) : rrRatio
    color dashRRc = dashRR >= 1.0 ? C_TEAL : C_BEAR
    table.cell(dash, 5, 2, " RR 1:" + str.tostring(dashRR, "#.##"), text_color=dashRRc, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 2, " " + posTxt,      text_color=posCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 7, 2, " TP  " + tpDTxt,  text_color=C_TEAL,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 2, " " + cdTxt,       text_color=cdCol,    text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

    table.cell(dash, 0, 3, " ①Sweep ②CHoCH ③OB=Entry", text_color=color.new(stateCol, 50), text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 3, " Institutions revealed",     text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 2, 3, " SL above this level",       text_color=color.new(C_ORANGE, 50), text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 3, 3, " OB mid: " + (na(newestOBTop) or na(newestOBBot) ? "--" : str.tostring(math.avg(newestOBTop, newestOBBot), format.mintick)), text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 4, 3, " Total: " + str.tostring(_dsz) + "  Active: " + str.tostring(cntSweep + cntChoch + cntOB), text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 5, 3, codaOn ? " TP " + str.tostring(tpPct) + "%  SL " + str.tostring(slPct) + "%" : " SL = swept lvl", text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 3, " Bars " + (g_inTrade ? str.tostring(bar_index - entryBar) + "/" + str.tostring(activeMaxBars) : "--"), text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 7, 3, " SL  " + slDTxt,             text_color=color.new(C_BEAR, 50), text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 3, " CD " + str.tostring(activeCooldown) + "b  MAX " + str.tostring(activeMaxBars) + "b", text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(sellSignal, "IS SELL — Institutional Supply", "Liq Sweep+CHoCH+OB Instant — SELL: BSL swept, CHoCH confirmed, Institutional Supply OB identified")
alertcondition(buySignal,  "ID BUY  — Institutional Demand", "Liq Sweep+CHoCH+OB Instant — BUY:  SSL swept, CHoCH confirmed, Institutional Demand OB identified")
````
