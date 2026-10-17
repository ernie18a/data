# Renko Keltner Trend Engine - Brick Based Buy Sell Signals

- url: https://www.tradingview.com/script/emkpgqhB-Renko-Keltner-Trend-Engine-Brick-Based-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;b10cb2ad16bb4549ab0a903f5ff20de3
- version: 3.0

## Description

DESCRIPTION:
█ RENKO + KELTNER CHANNEL = A MATCH MADE FOR TREND TRADING

This indicator rebuilds the classic two-window "Keltner Channel + Renko" trend strategy as ONE self-contained tool — and paints real Renko bricks directly on your normal candle chart. No Renko chart subscription needed, no second window: both Renko engines are built internally from chart data, and every indicator runs on the BRICK series, not on time bars.

█ HOW THE STRATEGY WORKS (the exact rule set)

The system uses TWO Renko engines side by side:

1 — TREND FILTER (3x brick Renko + Stochastic 1,1,1)
The big-brick Renko removes all noise. A fast stochastic (1,1,1) on those bricks produces a clean square-wave regime line:
• Crosses UP through 20 → regime turns BULLISH → longs only
• Crosses DOWN through 80 → regime turns BEARISH → shorts only
The regime stays valid until the opposite cross happens.

2 — EXECUTION WINDOW (1x brick Renko + Keltner Channel + Stochastic 7,3,3 + 9 MA)
• Keltner Channel with the classic settings: EMA 20 mid line, 2 x ATR 10 bands — computed on the Renko bricks, so the channel hugs the brick ladder
• Entry: stochastic (7,3,3) crosses in the regime direction AND one FULL Renko brick closes completely OUTSIDE the Keltner channel → that breakout brick is the entry
• Stop: the middle Keltner band (EMA 20) at entry
• Exit: a brick closes back through the 9-period MA (below for longs, above for shorts)

Simple, mechanical, fully rule-based — and every signal on the chart explains WHY it fired (hover the BUY/SELL pill for the full checklist: regime, stochastic values, breakout level, entry, stop).

█ WHAT YOU GET ON THE CHART

• Real RENKO BRICKS painted over your chart (green/red ladder) — you SEE the logic the signals are computed on
• Keltner Channel (gold bands + mid stop line) and the white 9 MA exit line, all computed on bricks
• Designed BUY ▲ / SELL ▼ signal pills with full "WHY THIS TRADE?" tooltips
• TREND ▲/▼ flip tags whenever the 3x-brick filter changes regime
• Entry + stop lines for the running trade, ✓/✗ exit marks with result tooltips
• Animated cockpit panel: Renko engine info (both brick sizes), 4-step entry checklist with live status, position box, live trade counter + win rate
• Auto (ATR) brick sizing so it works on ANY symbol and timeframe out of the box — or fix the brick size manually (e.g. $3 on ES with $9 filter, the classic setup)

█ WEBHOOK AUTOMATION READY

Create ONE alert with condition "Any alert() function call" and paste your webhook URL. The indicator fires ready-to-use JSON on every event:
BUY / SELL / MA_EXIT / SL_HIT — including symbol, price, stop, brick size, regime, win rate, timeframe and timestamp. Plug it straight into bots, bridges and auto-traders.

█ HOW TO USE

1. Add to a liquid symbol (indices, gold, FX, crypto). The video setup: S&P 500 E-mini, 1-min data, $3 brick / $9 filter
2. Leave brick mode on Auto (ATR) or set your fixed brick size
3. Wait for the checklist in the panel to light up: ① Trend Filter ② Stochastic ③ Brick outside Keltner ④ Entry
4. Manage by the rules: stop = mid band, exit = 9 MA recross — or automate it via webhook

█ NOTES

• Signals are computed on confirmed bricks from confirmed bars — no repainting of past signals
• The Renko engines need warm-up bricks; on fresh charts give it a moment of history
• This is a trading TOOL, not financial advice. Test any setting on your market before going live.

Open source — read it, change it, learn from it.


WHY THESE PARTS BELONG TOGETHER

Renko strips time out of the chart and shows only committed movement, but it has no sense of
whether that movement is stretched or normal. A Keltner channel measures exactly that, but on a
time chart it is constantly distorted by bars that carry no movement at all. Building the channel
on the brick series instead of the candle series is the whole point of this script: the volatility
envelope is finally measured on the same axis the trend is measured on.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//   RENKO KELTNER PRO  v1.4
//  1:1 rebuild of the "Keltner Channel + Renko" strategy (frame-by-frame video
//  analysis, S&P 500 E-mini) as a TradingView indicator in a dark cockpit design.
//
//  The source system runs TWO Renko charts side by side:
//   • TREND FILTER window  = Renko [Traditional, 3x brick] + Stochastic (1,1,1)
//                            bullish when %K crosses UP through 20, stays bullish
//                            until %K crosses DOWN through 80 (and vice versa) —
//                            only trade the execution window in that direction
//   • EXECUTION window     = Renko [Traditional, brick] + Keltner Channel
//                            (EMA 20, 2 x ATR 10 — the exact settings dialog shown
//                            in the video) + Stochastic (7,3,3) + 9-period MA
//   • ENTRY                = stochastic crosses in filter direction, then ONE FULL
//                            RENKO BRICK closes completely outside the Keltner
//                            channel = enter on that breakout brick
//   • STOP                 = the middle Keltner band (EMA 20) at entry
//   • EXIT                 = price falls back through the 9 MA (longs) /
//                            rises back through the 9 MA (shorts)
//
//  This indicator builds BOTH Renko engines internally from chart data, paints
//  the execution bricks on the chart, and runs every indicator on the BRICK
//  series (not on time bars) — exactly like the source setup.
// ═══════════════════════════════════════════════════════════════════════════════

//  v2 - House Rules compliance: no logo, no brand or company names, no external links.
indicator("Renko Keltner Trend Engine", "RENKO KELTNER", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────── PALETTE ───────────────────────────────────
color COL_BG     = color.rgb(6, 17, 30)      // navy outer
color COL_PANEL  = color.rgb(10, 29, 46)     // panel glass
color COL_PANEL2 = color.rgb(15, 44, 66)     // panel section
color COL_BULL   = color.rgb(126, 224, 208)  // mint
color COL_BULL2  = color.rgb(186, 240, 228)  // soft mint
color COL_BEAR   = color.rgb(244, 44, 58)    // red
color COL_BEAR2  = color.rgb(255, 148, 158)  // soft red
color COL_CYAN   = color.rgb(53, 200, 255)
color COL_GOLD   = color.rgb(255, 215, 40)
color COL_GOLD2  = color.rgb(255, 236, 130)
color COL_GOLD3  = color.rgb(238, 190, 30)
color COL_GOLD4  = color.rgb(210, 160, 20)
color COL_GOLD5  = color.rgb(170, 125, 12)
color COL_GLINT  = color.rgb(255, 252, 214)
color COL_PINK   = color.rgb(255, 62, 130)
color COL_SELLBG = color.rgb(126, 32, 36)
color COL_BUYBG  = color.rgb(120, 154, 52)
color COL_TPBG   = color.rgb(16, 94, 70)
color COL_SLBG   = color.rgb(94, 18, 26)
color COL_ENBG   = color.rgb(70, 76, 86)
color COL_TXT    = color.rgb(235, 235, 235)
color COL_GREY   = color.rgb(176, 182, 192)

// ─────────────────────────────── INPUTS ───────────────────────────────────────
grpB = "① Renko Engine (built from chart data)"
brickMode  = input.string("Auto (ATR)", "Brick size mode", options = ["Auto (ATR)", "Fixed"], group = grpB, tooltip = "The source video uses a FIXED $3 brick on the S&P 500 E-mini (1-min data) and $9 on the trend filter. Auto (ATR) sizes the brick from volatility so the system works on ANY symbol out of the box — switch to Fixed to replicate the video 1:1.")
brickFixed = input.float(3.0, "Fixed brick size ($/points)", minval = 0.0, step = 0.5, group = grpB, tooltip = "Used when mode = Fixed. $3 on ES in the video. Pick roughly 0.1-0.3% of the symbol price.")
brickAtrLen  = input.int(14, "Auto brick: ATR length", minval = 2, maxval = 100, group = grpB)
brickAtrMult = input.float(1.0, "Auto brick: ATR multiplier", minval = 0.1, step = 0.1, group = grpB, tooltip = "Brick = ATR x multiplier, locked on the first bars so the whole history is built on ONE constant brick — a Renko chart is only valid with a constant brick size.")
filterMult = input.int(3, "Trend filter brick = X times exec brick", minval = 2, maxval = 10, group = grpB, tooltip = "The video rule: TREND FILTER BLOCK SIZE = 3x THE TRADING WINDOW BLOCK SIZE (eg $9 vs $3).")
showBricks = input.bool(true, "Paint Renko bricks on the chart", group = grpB, tooltip = "Draws the execution-window Renko bricks over the chart — green/red brick ladder exactly like the video's Renko chart, so you SEE the brick logic the signals are computed on.")
dimCandles = input.bool(true, "Dim candles so the bricks pop", group = grpB, tooltip = "Fades the normal candles into the background so the Renko brick ladder becomes the main picture — the closest look to a real Renko chart on a standard time chart.")
brickOpac  = input.int(12, "Brick fill transparency", minval = 0, maxval = 90, group = grpB)

grpK = "② Keltner Channel (video settings dialog: 20 / 2 / EMA / ATR 10)"
kcLen    = input.int(20, "Keltner length (EMA)", minval = 2, maxval = 200, group = grpK)
kcMult   = input.float(2.0, "Keltner multiplier", minval = 0.5, step = 0.25, group = grpK)
kcAtrLen = input.int(10, "Keltner ATR length", minval = 1, maxval = 100, group = grpK, tooltip = "Computed on the RENKO BRICK series, not on time bars — the channel hugs the brick ladder like in the video.")

grpS = "③ Stochastics + Exit MA (all computed on Renko bricks)"
stLen    = input.int(7, "Exec stochastic %K length", minval = 1, maxval = 50, group = grpS, tooltip = "Video: 7,3,3 on the execution window.")
stSmooth = input.int(3, "Exec stochastic %K smoothing", minval = 1, maxval = 20, group = grpS)
stDLen   = input.int(3, "Exec stochastic %D smoothing", minval = 1, maxval = 20, group = grpS)
fLen     = input.int(1, "Filter stochastic %K length", minval = 1, maxval = 50, group = grpS, tooltip = "Video: 1,1,1 on the 3x-brick trend filter chart. On Renko bricks this produces the square-wave regime line seen in the video: bullish after crossing UP through 20, bearish after crossing DOWN through 80.")
fSmooth  = input.int(1, "Filter stochastic %K smoothing", minval = 1, maxval = 20, group = grpS)
fDLen    = input.int(1, "Filter stochastic %D smoothing", minval = 1, maxval = 20, group = grpS)
fUp      = input.float(20, "Filter oversold line (bull trigger)", minval = 1, maxval = 50, group = grpS)
fDn      = input.float(80, "Filter overbought line (bear trigger)", minval = 50, maxval = 99, group = grpS)
maLen    = input.int(9, "Exit moving average (SMA on bricks)", minval = 1, maxval = 100, group = grpS, tooltip = "The white 9-period MA from the video. Long exits when a brick closes back BELOW it, short exits when a brick closes back ABOVE it.")
warmupBricks = input.int(25, "Warm-up bricks before first signal", minval = 5, maxval = 200, group = grpS)

grpM = "③b Win-Rate Engine (trade management)"
tp1Enable  = input.bool(true, "Split TP: bank the win early, stop to break-even", group = grpM, tooltip = "TP1 at a fraction of the risk: when it is tagged the trade is booked as a WIN, the stop jumps to break-even and the rest runs to the MA exit. Split-target management — the way professional scalpers bank a high hit rate. Honest counting: win = TP1 tagged, loss = stop before TP1, break-even exits are counted separately and NOT sold as wins. Turn OFF for the pure 1:1 video rules.")
tp1R       = input.float(0.4, "TP1 distance (R)", minval = 0.1, maxval = 3, step = 0.05, group = grpM, tooltip = "TP1 = entry + risk x this value (mirrored for shorts). Risk = distance entry to the middle-band stop.")
coolBricks = input.int(6, "Cooldown after a loss (bricks)", minval = 0, maxval = 100, group = grpM, tooltip = "After a losing trade the same direction is locked for this many bricks. Stops revenge-entries into the same chop.")
stretchMax = input.float(1.5, "Max overextension beyond band (x brick ATR)", minval = 0.25, step = 0.25, group = grpM, tooltip = "The entry brick may close at most this far beyond the Keltner band. Blocks chasing an exhausted breakout — the #1 breakout killer.")
freshMax   = input.int(8, "Stoch cross freshness (bricks)", minval = 1, maxval = 50, group = grpM, tooltip = "The stochastic cross must be at most this many bricks old at entry. Late entries on stale crosses are skipped.")

grpD = "④ Design"
useTheme  = input.bool(true, "Dark chart theme (navy + mint/red bars)", group = grpD)
showKC    = input.bool(true, "Show Keltner channel + 9 MA lines", group = grpD)
showWhy   = input.bool(true, "Explain events on the chart (filter flips, breakouts)", group = grpD)
showPanel = input.bool(true, "Show Cockpit panel", group = grpD)
panelPos  = input.string("Middle Left", "Panel position", options = ["Middle Left", "Top Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group = grpD)

grpA = "⑤ Alerts & Webhook (Automation)"
alSignals = input.bool(true, "Alert on BUY/SELL (webhook JSON)", group = grpA, tooltip = "Create ONE alert with condition 'Any alert() function call' and paste your webhook URL. Every signal fires ready-to-use JSON for bots, bridges and auto-traders.")
alManage  = input.bool(true, "Alert on MA exit / stop hit", group = grpA)
whId      = input.string("RENKO-KELTNER-PRO", "Webhook strategy ID", group = grpA)

// ─────────────────────────────── THEME ────────────────────────────────────────
bgcolor(useTheme ? color.new(COL_BG, 0) : na)
color candDim = close >= open ? color.rgb(34, 66, 60) : color.rgb(70, 30, 36)
barcolor(useTheme ? (showBricks and dimCandles ? candDim : close >= open ? COL_BULL : COL_BEAR) : na)

// future-margin box is clamped to the recent price range so it never distorts the auto-scale
float hh500 = ta.highest(high, 500)
float ll500 = ta.lowest(low, 500)
var box marginBox = na
if useTheme and na(marginBox)
    marginBox := box.new(bar_index + 1, high * 1.02, bar_index + 500, low * 0.98, border_color = color.new(COL_BG, 0), border_width = 1, bgcolor = color.new(COL_BG, 0))
if useTheme and not na(marginBox) and barstate.islast
    box.set_left(marginBox, bar_index + 1)
    box.set_right(marginBox, bar_index + 500)
    box.set_top(marginBox, hh500 * 1.02)
    box.set_bottom(marginBox, ll500 * 0.98)

// ─────────────────────────── BRICK SIZE (locked once) ─────────────────────────
// Auto mode locks the brick from a STABLE volatility read (ATR 200 after enough
// history) — locking on the very first bars produced garbage bricks on low TFs.
float atrRaw    = ta.atr(brickAtrLen)
float atrStable = ta.atr(200)
var float B = na
if na(B)
    if brickMode == "Fixed" and brickFixed > 0
        B := math.max(syminfo.mintick, math.round(brickFixed / syminfo.mintick) * syminfo.mintick)
    else if bar_index >= 500 or (barstate.islast and bar_index >= brickAtrLen)
        float want = nz(atrStable, atrRaw) * brickAtrMult
        if not na(want) and want > 0
            B := math.max(syminfo.mintick, math.round(want / syminfo.mintick) * syminfo.mintick)
float FB = na(B) ? na : B * filterMult

bool proc = barstate.isconfirmed

// ─────────────────────────── FILTER RENKO ENGINE (3x brick) ───────────────────
var float fTop = na
var float fBot = na
var int   fDir = 0
var int   fBrickCount = 0
var array<float> fHiA = array.new<float>()
var array<float> fLoA = array.new<float>()
var array<float> fClA = array.new<float>()
var array<float> fKraw = array.new<float>()
var array<float> fKs   = array.new<float>()
var float fK = na
var float fD = na
var float fKprev = na
var int   regime = 0          // 1 = bullish, -1 = bearish, 0 = undecided
bool regimeFlipUp = false
bool regimeFlipDn = false

f_smaArr(array<float> a, int n) =>
    int sz = array.size(a)
    if sz >= n
        float s = 0.0
        for i = sz - n to sz - 1
            s += array.get(a, i)
        s / n
    else
        float(na)

if proc and not na(FB)
    if na(fTop)
        fBot := math.floor(close / FB) * FB
        fTop := fBot + FB
    int guard = 0
    bool made = true
    while made and guard < 40
        made := false
        guard += 1
        float bO = na
        float bC = na
        int   d  = 0
        if close >= fTop + FB
            bO := fTop
            bC := fTop + FB
            d  := 1
            fBot := fTop
            fTop := fTop + FB
            made := true
        else if close <= fBot - FB
            bO := fBot
            bC := fBot - FB
            d  := -1
            fTop := fBot
            fBot := fBot - FB
            made := true
        if made
            fDir := d
            fBrickCount += 1
            float bH = math.max(bO, bC)
            float bL = math.min(bO, bC)
            array.push(fHiA, bH)
            array.push(fLoA, bL)
            array.push(fClA, bC)
            if array.size(fClA) > 60
                array.shift(fHiA)
                array.shift(fLoA)
                array.shift(fClA)
            // stochastic (1,1,1 default) on filter bricks
            int lb = math.min(fLen, array.size(fClA))
            float hh = -1e12
            float ll = 1e12
            for i = array.size(fClA) - lb to array.size(fClA) - 1
                hh := math.max(hh, array.get(fHiA, i))
                ll := math.min(ll, array.get(fLoA, i))
            float kraw = hh > ll ? (bC - ll) / (hh - ll) * 100 : 50.0
            array.push(fKraw, kraw)
            if array.size(fKraw) > 25
                array.shift(fKraw)
            float kS = f_smaArr(fKraw, fSmooth)
            if not na(kS)
                array.push(fKs, kS)
                if array.size(fKs) > 25
                    array.shift(fKs)
            fKprev := fK
            fK := kS
            fD := f_smaArr(fKs, fDLen)
            // regime state machine: UP through 20 = bullish, DOWN through 80 = bearish
            if not na(fK) and not na(fKprev)
                if fKprev <= fUp and fK > fUp and regime != 1
                    regime := 1
                    regimeFlipUp := true
                if fKprev >= fDn and fK < fDn and regime != -1
                    regime := -1
                    regimeFlipDn := true
            else if not na(fK) and na(fKprev) and regime == 0
                regime := fK > 50 ? 1 : -1

// ─────────────────────────── EXECUTION RENKO ENGINE ───────────────────────────
var float eTop = na
var float eBot = na
var int   eDir = 0
var int   brickCount = 0
var array<float> eHiA = array.new<float>()
var array<float> eLoA = array.new<float>()
var array<float> eClA = array.new<float>()
var array<float> eKraw = array.new<float>()
var array<float> eKs   = array.new<float>()
var float prevBrickC = na
var float kcEma = na          // Keltner middle = EMA(20) of brick closes
var float kcRma = na          // Keltner ATR(10) of bricks (RMA of brick TR)
var float kcUp  = na
var float kcLo  = na
var float ma9   = na
var float eK    = na
var float eD    = na
var float prevEK = na
var float prevED = na
var int   bullAge = 999
var int   bearAge = 999
var bool  prevFullAbove = false
var bool  prevFullBelow = false
var array<box> brickBoxes = array.new<box>()
var array<box> ladderBoxes = array.new<box>()
var int   lastBrickBar = na

// trade state
var int    pos      = 0
var float  tEntry   = na
var float  tSL      = na
var float  tRisk    = na
var bool   tp1Hit   = false
var int    wins     = 0
var int    losses   = 0
var int    beCount  = 0
var int    lastLossBrick = -99999
var int    lastLossDir   = 0
var string sigTxt   = "FLAT"
var line   entryLn  = na
var line   slLn     = na
bool buySignal  = false
bool sellSignal = false
bool maExit     = false
bool slHit      = false
bool tp1Event   = false
bool beExit     = false
float exitPx    = na

f_closeTradeLines() =>
    if not na(entryLn)
        line.set_x2(entryLn, bar_index)
    if not na(slLn)
        line.set_x2(slLn, bar_index)

if proc and not na(B)
    if na(eTop)
        eBot := math.floor(close / B) * B
        eTop := eBot + B
    int guard2 = 0
    bool made2 = true
    while made2 and guard2 < 40
        made2 := false
        guard2 += 1
        float bO = na
        float bC = na
        int   d  = 0
        if close >= eTop + B
            bO := eTop
            bC := eTop + B
            d  := 1
            eBot := eTop
            eTop := eTop + B
            made2 := true
        else if close <= eBot - B
            bO := eBot
            bC := eBot - B
            d  := -1
            eTop := eBot
            eBot := eBot - B
            made2 := true
        if made2
            eDir := d
            brickCount += 1
            float bH = math.max(bO, bC)
            float bL = math.min(bO, bC)
            // ── indicators on the brick series ──
            float tr = na(prevBrickC) ? bH - bL : math.max(bH - bL, math.max(math.abs(bH - prevBrickC), math.abs(bL - prevBrickC)))
            prevBrickC := bC
            kcEma := na(kcEma) ? bC : kcEma + 2.0 / (kcLen + 1) * (bC - kcEma)
            kcRma := na(kcRma) ? tr : (kcRma * (kcAtrLen - 1) + tr) / kcAtrLen
            kcUp := kcEma + kcMult * kcRma
            kcLo := kcEma - kcMult * kcRma
            array.push(eHiA, bH)
            array.push(eLoA, bL)
            array.push(eClA, bC)
            if array.size(eClA) > 60
                array.shift(eHiA)
                array.shift(eLoA)
                array.shift(eClA)
            ma9 := f_smaArr(eClA, maLen)
            int lb2 = math.min(stLen, array.size(eClA))
            float hh2 = -1e12
            float ll2 = 1e12
            for i = array.size(eClA) - lb2 to array.size(eClA) - 1
                hh2 := math.max(hh2, array.get(eHiA, i))
                ll2 := math.min(ll2, array.get(eLoA, i))
            float kraw2 = hh2 > ll2 ? (bC - ll2) / (hh2 - ll2) * 100 : 50.0
            array.push(eKraw, kraw2)
            if array.size(eKraw) > 25
                array.shift(eKraw)
            float kS2 = f_smaArr(eKraw, stSmooth)
            if not na(kS2)
                array.push(eKs, kS2)
                if array.size(eKs) > 25
                    array.shift(eKs)
            eK := kS2
            eD := f_smaArr(eKs, stDLen)
            // cross-freshness tracking (bricks since the last stochastic cross)
            if not na(eK) and not na(eD)
                if not na(prevEK) and not na(prevED) and prevEK <= prevED and eK > eD
                    bullAge := 0
                else
                    bullAge := math.min(bullAge + 1, 999)
                if not na(prevEK) and not na(prevED) and prevEK >= prevED and eK < eD
                    bearAge := 0
                else
                    bearAge := math.min(bearAge + 1, 999)
                prevEK := eK
                prevED := eD
            // ── paint the brick as a CONTINUOUS ladder step (spans since the previous brick) ──
            if showBricks
                int bLeft = na(lastBrickBar) or lastBrickBar >= bar_index ? bar_index : lastBrickBar
                box bb = box.new(bLeft, bH, bar_index + 1, bL, border_color = d == 1 ? color.new(COL_BULL, 0) : color.new(COL_BEAR, 0), border_width = 2, bgcolor = d == 1 ? color.new(COL_BULL, brickOpac) : color.new(COL_BEAR, brickOpac))
                array.push(brickBoxes, bb)
                if array.size(brickBoxes) > 380
                    box.delete(array.shift(brickBoxes))
            lastBrickBar := bar_index
            // ── manage open trade (brick-based, like the source system) ──
            if pos == 1
                if tp1Enable and not tp1Hit and bH >= tEntry + tRisk * tp1R
                    tp1Hit := true
                    wins += 1
                    tSL := math.max(tSL, tEntry)
                    tp1Event := true
                    label.new(bar_index, tEntry + tRisk * tp1R, "✓", style = label.style_none, textcolor = COL_BULL, size = size.small, tooltip = "TP1 banked at " + str.tostring(tEntry + tRisk * tp1R, format.mintick) + " (" + str.tostring(tp1R, "#.##") + "R) — win booked, stop to break-even, rest runs to the MA exit.")
                if bL <= tSL
                    exitPx := tSL
                    if tp1Hit
                        beCount += 1
                        beExit := true
                        sigTxt := "TP1 WIN + BE ◦"
                        label.new(bar_index, tSL, "◦", style = label.style_none, textcolor = COL_CYAN, size = size.normal, tooltip = "LONG runner closed at break-even " + str.tostring(tSL, format.mintick) + " — TP1 was already banked, no risk left.")
                    else
                        slHit := true
                        losses += 1
                        lastLossBrick := brickCount
                        lastLossDir := 1
                        sigTxt := "STOP HIT ✖"
                        label.new(bar_index, tSL, "✗", style = label.style_none, textcolor = COL_BEAR, size = size.normal, tooltip = "LONG stopped at the middle Keltner band " + str.tostring(tSL, format.mintick) + " — the video's stop rule.")
                    f_closeTradeLines()
                    pos := 0
                else if not na(ma9) and bC < ma9
                    maExit := true
                    exitPx := bC
                    bool w = bC > tEntry
                    if not tp1Hit
                        if w
                            wins += 1
                        else
                            losses += 1
                            lastLossBrick := brickCount
                            lastLossDir := 1
                    sigTxt := tp1Hit ? "TP1 WIN ✔" : w ? "MA EXIT WIN ✔" : "MA EXIT LOSS ✖"
                    label.new(bar_index, bC, w or tp1Hit ? "✓" : "✗", style = label.style_none, textcolor = w or tp1Hit ? COL_BULL : COL_BEAR, size = size.normal, tooltip = "LONG closed at " + str.tostring(bC, format.mintick) + " — brick closed back BELOW the " + str.tostring(maLen) + " MA (the video's exit rule).\nResult: " + (bC - tEntry >= 0 ? "+" : "") + str.tostring(bC - tEntry, format.mintick))
                    f_closeTradeLines()
                    pos := 0
            else if pos == -1
                if tp1Enable and not tp1Hit and bL <= tEntry - tRisk * tp1R
                    tp1Hit := true
                    wins += 1
                    tSL := math.min(tSL, tEntry)
                    tp1Event := true
                    label.new(bar_index, tEntry - tRisk * tp1R, "✓", style = label.style_none, textcolor = COL_BULL, size = size.small, tooltip = "TP1 banked at " + str.tostring(tEntry - tRisk * tp1R, format.mintick) + " (" + str.tostring(tp1R, "#.##") + "R) — win booked, stop to break-even, rest runs to the MA exit.")
                if bH >= tSL
                    exitPx := tSL
                    if tp1Hit
                        beCount += 1
                        beExit := true
                        sigTxt := "TP1 WIN + BE ◦"
                        label.new(bar_index, tSL, "◦", style = label.style_none, textcolor = COL_CYAN, size = size.normal, tooltip = "SHORT runner closed at break-even " + str.tostring(tSL, format.mintick) + " — TP1 was already banked, no risk left.")
                    else
                        slHit := true
                        losses += 1
                        lastLossBrick := brickCount
                        lastLossDir := -1
                        sigTxt := "STOP HIT ✖"
                        label.new(bar_index, tSL, "✗", style = label.style_none, textcolor = COL_BEAR, size = size.normal, tooltip = "SHORT stopped at the middle Keltner band " + str.tostring(tSL, format.mintick) + " — the video's stop rule.")
                    f_closeTradeLines()
                    pos := 0
                else if not na(ma9) and bC > ma9
                    maExit := true
                    exitPx := bC
                    bool w2 = bC < tEntry
                    if not tp1Hit
                        if w2
                            wins += 1
                        else
                            losses += 1
                            lastLossBrick := brickCount
                            lastLossDir := -1
                    sigTxt := tp1Hit ? "TP1 WIN ✔" : w2 ? "MA EXIT WIN ✔" : "MA EXIT LOSS ✖"
                    label.new(bar_index, bC, w2 or tp1Hit ? "✓" : "✗", style = label.style_none, textcolor = w2 or tp1Hit ? COL_BULL : COL_BEAR, size = size.normal, tooltip = "SHORT closed at " + str.tostring(bC, format.mintick) + " — brick closed back ABOVE the " + str.tostring(maLen) + " MA (the video's exit rule).\nResult: " + (tEntry - bC >= 0 ? "+" : "") + str.tostring(tEntry - bC, format.mintick))
                    f_closeTradeLines()
                    pos := 0
            // ── entries: filter direction + stoch cross + FULL brick outside the channel ──
            bool warmOK = brickCount >= warmupBricks and not na(kcUp) and not na(eK) and not na(eD)
            bool fullAbove = warmOK and bL >= kcUp
            bool fullBelow = warmOK and bH <= kcLo
            bool coolOKL = coolBricks == 0 or lastLossDir != 1 or brickCount - lastLossBrick >= coolBricks
            bool coolOKS = coolBricks == 0 or lastLossDir != -1 or brickCount - lastLossBrick >= coolBricks
            bool stretchOKL = bC <= kcUp + stretchMax * kcRma
            bool stretchOKS = bC >= kcLo - stretchMax * kcRma
            if pos == 0 and warmOK
                if regime == 1 and d == 1 and eK > eD and bullAge <= freshMax and fullAbove and not prevFullAbove and stretchOKL and coolOKL
                    buySignal := true
                    pos := 1
                    tEntry := bC
                    tSL := kcEma
                    tRisk := tEntry - tSL
                    tp1Hit := false
                    sigTxt := "LONG " + str.tostring(tEntry, format.mintick)
                    label.new(bar_index, bL, "  BUY ▲  \nRENKO BRICK OUT OF KELTNER", style = label.style_label_up, color = COL_BUYBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS BUY?\n1) Trend filter BULLISH — stochastic (" + str.tostring(fLen) + "," + str.tostring(fSmooth) + "," + str.tostring(fDLen) + ") on the " + str.tostring(filterMult) + "x Renko crossed up through " + str.tostring(fUp, "#") + " and has not broken back down through " + str.tostring(fDn, "#") + "\n2) Exec stochastic (" + str.tostring(stLen) + "," + str.tostring(stSmooth) + "," + str.tostring(stDLen) + ") bullish: %K " + str.tostring(eK, "#.#") + " > %D " + str.tostring(eD, "#.#") + "\n3) ONE FULL RENKO BRICK closed completely ABOVE the upper Keltner band " + str.tostring(kcUp, format.mintick) + "\nEntry " + str.tostring(tEntry, format.mintick) + "\nStop = middle Keltner band " + str.tostring(tSL, format.mintick))
                    entryLn := line.new(bar_index, tEntry, bar_index + 1, tEntry, color = color.new(COL_GOLD, 20), style = line.style_dashed, width = 1)
                    slLn := line.new(bar_index, tSL, bar_index + 1, tSL, color = color.new(COL_PINK, 15), style = line.style_dashed, width = 1)
                else if regime == -1 and d == -1 and eK < eD and bearAge <= freshMax and fullBelow and not prevFullBelow and stretchOKS and coolOKS
                    sellSignal := true
                    pos := -1
                    tEntry := bC
                    tSL := kcEma
                    tRisk := tSL - tEntry
                    tp1Hit := false
                    sigTxt := "SHORT " + str.tostring(tEntry, format.mintick)
                    label.new(bar_index, bH, "  SELL ▼  \nRENKO BRICK OUT OF KELTNER", style = label.style_label_down, color = COL_SELLBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS SELL?\n1) Trend filter BEARISH — stochastic (" + str.tostring(fLen) + "," + str.tostring(fSmooth) + "," + str.tostring(fDLen) + ") on the " + str.tostring(filterMult) + "x Renko crossed down through " + str.tostring(fDn, "#") + " and has not broken back up through " + str.tostring(fUp, "#") + "\n2) Exec stochastic (" + str.tostring(stLen) + "," + str.tostring(stSmooth) + "," + str.tostring(stDLen) + ") bearish: %K " + str.tostring(eK, "#.#") + " < %D " + str.tostring(eD, "#.#") + "\n3) ONE FULL RENKO BRICK closed completely BELOW the lower Keltner band " + str.tostring(kcLo, format.mintick) + "\nEntry " + str.tostring(tEntry, format.mintick) + "\nStop = middle Keltner band " + str.tostring(tSL, format.mintick))
                    entryLn := line.new(bar_index, tEntry, bar_index + 1, tEntry, color = color.new(COL_GOLD, 20), style = line.style_dashed, width = 1)
                    slLn := line.new(bar_index, tSL, bar_index + 1, tSL, color = color.new(COL_PINK, 15), style = line.style_dashed, width = 1)
            prevFullAbove := fullAbove
            prevFullBelow := fullBelow

// extend live trade lines
if pos != 0
    if not na(entryLn)
        line.set_x2(entryLn, bar_index + 1)
    if not na(slLn)
        line.set_x2(slLn, bar_index + 1)

// ─────────── TRUE RENKO LADDER (equal-size bricks, right margin) ───────────────
// A real Renko chart of the last bricks — every brick identical in size, pure
// staircase, drawn at the actual price levels right of the live candle.
var label ladderCap = na
if showBricks and barstate.islast and not na(B) and array.size(eClA) >= 2
    while array.size(ladderBoxes) > 0
        box.delete(array.pop(ladderBoxes))
    int nL = math.min(40, array.size(eClA) - 1)
    int wL = 4
    int x0 = bar_index + 14
    float capY = -1e12
    for i = 0 to nL - 1
        int idx = array.size(eClA) - nL + i
        float cL = array.get(eClA, idx)
        float cP = array.get(eClA, idx - 1)
        int dL = cL > cP ? 1 : -1
        float oL = cL - dL * B
        capY := math.max(capY, math.max(oL, cL))
        array.push(ladderBoxes, box.new(x0 + i * wL, math.max(oL, cL), x0 + i * wL + wL - 1, math.min(oL, cL), border_color = dL == 1 ? color.new(COL_BULL, 0) : color.new(COL_BEAR, 0), border_width = 1, bgcolor = dL == 1 ? color.new(COL_BULL, brickOpac) : color.new(COL_BEAR, brickOpac)))
    if na(ladderCap)
        ladderCap := label.new(x0, capY + B, "LIVE RENKO · brick " + str.tostring(B, format.mintick), style = label.style_label_down, color = color.new(COL_PANEL2, 0), textcolor = COL_GOLD, size = size.small, tooltip = "The REAL Renko chart of the last bricks — every brick is exactly one brick size, pure staircase, exactly what the signals are computed on. On the main chart the same bricks are stretched over time.")
    label.set_xy(ladderCap, x0 + nL * wL / 2, capY + B * 2)
else if not na(ladderCap) and not showBricks
    label.delete(ladderCap)
    ladderCap := na

// ─────────────────────────── CHART EXPLANATIONS ───────────────────────────────
if showWhy and regimeFlipUp
    label.new(bar_index, low, "TREND ▲ BULL", style = label.style_label_up, color = color.new(COL_PANEL2, 0), textcolor = COL_BULL, size = size.small, tooltip = "TREND FILTER FLIP — the stochastic (" + str.tostring(fLen) + "," + str.tostring(fSmooth) + "," + str.tostring(fDLen) + ") on the " + str.tostring(filterMult) + "x-brick Renko crossed UP through " + str.tostring(fUp, "#") + ".\nFrom here the system takes LONGS ONLY, until it crosses back down through " + str.tostring(fDn, "#") + " — the exact video rule.")
if showWhy and regimeFlipDn
    label.new(bar_index, high, "TREND ▼ BEAR", style = label.style_label_down, color = color.new(COL_PANEL2, 0), textcolor = COL_BEAR, size = size.small, tooltip = "TREND FILTER FLIP — the stochastic (" + str.tostring(fLen) + "," + str.tostring(fSmooth) + "," + str.tostring(fDLen) + ") on the " + str.tostring(filterMult) + "x-brick Renko crossed DOWN through " + str.tostring(fDn, "#") + ".\nFrom here the system takes SHORTS ONLY, until it crosses back up through " + str.tostring(fUp, "#") + " — the exact video rule.")

// ─────────────────────────── KELTNER + MA PLOTS (brick values) ────────────────
pUp  = plot(showKC ? kcUp : na, "Keltner upper (bricks)", color = color.new(COL_GOLD, 15), linewidth = 2, display = display.pane)
pMid = plot(showKC ? kcEma : na, "Keltner middle = stop line", color = color.new(COL_PINK, 30), linewidth = 1, display = display.pane)
pLo  = plot(showKC ? kcLo : na, "Keltner lower (bricks)", color = color.new(COL_GOLD, 15), linewidth = 2, display = display.pane)
plot(showKC ? ma9 : na, "Exit MA 9 (bricks)", color = color.new(COL_TXT, 10), linewidth = 1, display = display.pane)
fill(pUp, pLo, color = regime == 1 ? color.new(COL_BULL, 94) : regime == -1 ? color.new(COL_BEAR, 94) : color.new(COL_GREY, 96), title = "Channel fill")

plotshape(buySignal, "BUY arrow", shape.triangleup, location.belowbar, COL_BULL, size = size.tiny, display = display.pane)
plotshape(sellSignal, "SELL arrow", shape.triangledown, location.abovebar, COL_BEAR, size = size.tiny, display = display.pane)

// ─────────────────────────── ALERTS / WEBHOOK ─────────────────────────────────
int   trades  = wins + losses
float winRate = trades > 0 ? wins / trades * 100 : 0

f_json(string action, float px, float sl) =>
    '{"id":"' + whId + '","symbol":"' + syminfo.ticker + '","action":"' + action + '","price":' + str.tostring(px, format.mintick) + ',"sl":' + str.tostring(na(sl) ? px : sl, format.mintick) + ',"brick":' + str.tostring(B, format.mintick) + ',"filter":"' + (regime == 1 ? "BULL" : regime == -1 ? "BEAR" : "FLAT") + '","winrate":"' + str.tostring(winRate, "#.#") + '","tf":"' + timeframe.period + '","time":"' + str.format_time(time, "yyyy-MM-dd HH:mm", "GMT") + '"}'

if alSignals and buySignal
    alert(f_json("BUY", tEntry, tSL), alert.freq_once_per_bar_close)
if alSignals and sellSignal
    alert(f_json("SELL", tEntry, tSL), alert.freq_once_per_bar_close)
if alManage and maExit
    alert(f_json("MA_EXIT", exitPx, na), alert.freq_once_per_bar_close)
if alManage and slHit
    alert(f_json("SL_HIT", exitPx, na), alert.freq_once_per_bar_close)
if alManage and tp1Event
    alert(f_json("TP1_HIT", na(tEntry) ? close : tEntry, tSL), alert.freq_once_per_bar_close)
if alManage and beExit
    alert(f_json("BE_EXIT", exitPx, na), alert.freq_once_per_bar_close)

alertcondition(buySignal, "BUY Signal", "Renko Keltner Pro: BUY {{ticker}} @ {{close}}")
alertcondition(sellSignal, "SELL Signal", "Renko Keltner Pro: SELL {{ticker}} @ {{close}}")
alertcondition(maExit or slHit, "Exit", "Renko Keltner Pro: trade closed {{ticker}} {{interval}}")

// ─────────────────────────── COCKPIT PANEL ─────────────────────────────────
varip int glint = 0
if barstate.isrealtime
    glint += 1

f_pos() =>
    switch panelPos
        "Middle Left"  => position.middle_left
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Top Right"    => position.top_right
        "Middle Right" => position.middle_right
        => position.bottom_right



f_spacer(table t, int r) =>
    table.cell(t, 0, r, "", bgcolor = color.new(COL_BG, 0), text_size = size.tiny)

f_header(table t, int r, string leftTxt, string rightTxt) =>
    table.cell(t, 0, r, leftTxt, text_color = COL_CYAN, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(t, 5, r, rightTxt, text_color = COL_GOLD, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_right, text_font_family = font.family_monospace)

f_kv(table t, int r, string k, string v, color vCol, color vBg) =>
    table.cell(t, 0, r, k, text_color = COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 4, r, v, text_color = vCol, text_size = size.tiny, bgcolor = color.new(vBg, 0), text_halign = text.align_center, text_font_family = font.family_monospace)

var table pan = na
if showPanel and barstate.islast
    if na(pan)
        pan := table.new(f_pos(), 8, 36, bgcolor = color.new(COL_PANEL, 0), frame_color = COL_CYAN, frame_width = 2, border_color = color.new(COL_CYAN, 88), border_width = 1)
        for r = 0 to 35
            for c = 0 to 7
                table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
        table.merge_cells(pan, 0, 5, 6, 5)
        table.cell(pan, 0, 6, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 6, 7, 6)
        table.merge_cells(pan, 0, 8, 7, 8)
        table.merge_cells(pan, 0, 9, 4, 9)
        table.merge_cells(pan, 5, 9, 7, 9)
        for r = 10 to 14
            table.merge_cells(pan, 0, r, 3, r)
            table.merge_cells(pan, 4, r, 7, r)
        table.merge_cells(pan, 0, 15, 7, 15)
        table.merge_cells(pan, 0, 16, 4, 16)
        table.merge_cells(pan, 5, 16, 7, 16)
        for r = 17 to 20
            table.merge_cells(pan, 0, r, 3, r)
            table.merge_cells(pan, 4, r, 7, r)
        table.merge_cells(pan, 0, 21, 7, 21)
        table.merge_cells(pan, 0, 22, 4, 22)
        table.merge_cells(pan, 5, 22, 7, 22)
        table.merge_cells(pan, 0, 23, 7, 23)
        table.merge_cells(pan, 0, 24, 7, 24)
        table.merge_cells(pan, 0, 25, 7, 25)
        table.merge_cells(pan, 0, 26, 4, 26)
        table.merge_cells(pan, 5, 26, 7, 26)
        for r = 27 to 30
            table.merge_cells(pan, 0, r, 3, r)
            table.merge_cells(pan, 4, r, 7, r)
        table.cell(pan, 0, 31, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 31, 7, 31)
        table.cell(pan, 0, 32, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 32, 7, 32)
        table.cell(pan, 0, 33, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 33, 7, 33)
        table.merge_cells(pan, 0, 34, 7, 34)
        table.merge_cells(pan, 0, 35, 7, 35)
    int gcol = glint % 8
    for r = 0 to 4
        for c = 0 to 7
            table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
    // ── header ──
    table.cell(pan, 0, 5, "RENKO KELTNER", text_color = COL_GOLD, text_size = size.normal, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(pan, 7, 5, glint % 2 == 0 ? "●" : "○", text_color = COL_CYAN, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    for c = 0 to 7
        table.cell(pan, c, 7, "▲", text_color = c == gcol ? COL_GOLD : color.new(COL_BULL, 35), text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    f_spacer(pan, 8)
    // ── RENKO ENGINE ──
    f_header(pan, 9, "RENKO ENGINE", "BRICKS")
    f_kv(pan, 10, "Exec Brick", na(B) ? "—" : str.tostring(B, format.mintick), COL_GOLD, COL_PANEL)
    f_kv(pan, 11, "Filter Brick (" + str.tostring(filterMult) + "x)", na(FB) ? "—" : str.tostring(FB, format.mintick), COL_GOLD, COL_PANEL)
    f_kv(pan, 12, "Keltner", "EMA" + str.tostring(kcLen) + " · " + str.tostring(kcMult, "#.#") + "xATR" + str.tostring(kcAtrLen), COL_TXT, COL_PANEL)
    f_kv(pan, 13, "Exit MA", "SMA " + str.tostring(maLen), COL_TXT, COL_PANEL)
    f_kv(pan, 14, "Bricks Built", str.tostring(brickCount) + " / " + str.tostring(fBrickCount), COL_TXT, COL_PANEL)
    f_spacer(pan, 15)
    // ── ENTRY CHECKLIST ──
    f_header(pan, 16, "ENTRY CHECKLIST", "")
    string c1 = regime == 1 ? "BULL" : regime == -1 ? "BEAR" : "‥"
    f_kv(pan, 17, "❶ Trend Filter " + str.tostring(fLen) + "," + str.tostring(fSmooth) + "," + str.tostring(fDLen), c1, regime == 0 ? COL_GREY : COL_TXT, regime == 1 ? COL_TPBG : regime == -1 ? COL_SLBG : COL_PANEL2)
    string c2 = na(eK) or na(eD) ? "‥" : eK > eD ? "K>D BULL" : "K<D BEAR"
    f_kv(pan, 18, "❷ Stoch " + str.tostring(stLen) + "," + str.tostring(stSmooth) + "," + str.tostring(stDLen), c2, na(eK) ? COL_GREY : COL_TXT, na(eK) or na(eD) ? COL_PANEL2 : eK > eD ? COL_TPBG : COL_SLBG)
    string c3 = pos != 0 ? "IN TRADE" : prevFullAbove ? "ABOVE ✔" : prevFullBelow ? "BELOW ✔" : "INSIDE ‥"
    f_kv(pan, 19, "❸ Brick out of Keltner", c3, prevFullAbove or prevFullBelow or pos != 0 ? COL_TXT : COL_GREY, prevFullAbove ? COL_TPBG : prevFullBelow ? COL_SLBG : COL_PANEL2)
    string c4 = pos == 1 ? "LONG RUN" : pos == -1 ? "SHORT RUN" : "READY"
    f_kv(pan, 20, "❹ Position", c4, pos == 0 ? COL_GREY : COL_TXT, pos == 1 ? COL_TPBG : pos == -1 ? COL_SLBG : COL_PANEL2)
    f_spacer(pan, 21)
    // ── POSITION ──
    f_header(pan, 22, "POSITION", "")
    string posTxt = pos == 1 ? "LONG " + str.tostring(tEntry, format.mintick) + " · SL " + str.tostring(tSL, format.mintick) : pos == -1 ? "SHORT " + str.tostring(tEntry, format.mintick) + " · SL " + str.tostring(tSL, format.mintick) : "NO POSITION"
    table.cell(pan, 0, 23, posTxt, text_color = pos == 0 ? COL_GREY : COL_TXT, text_size = size.small, bgcolor = color.new(pos == 1 ? COL_TPBG : pos == -1 ? COL_SLBG : COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(pan, 0, 24, sigTxt, text_color = str.contains(sigTxt, "✔") ? COL_BULL : str.contains(sigTxt, "✖") ? COL_BEAR : pos != 0 ? COL_GOLD : COL_GREY, text_size = size.large, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    f_spacer(pan, 25)
    // ── PERFORMANCE ──
    f_header(pan, 26, "PERFORMANCE", "")
    f_kv(pan, 27, "Asset", syminfo.ticker, COL_TXT, COL_PANEL)
    f_kv(pan, 28, "Timeframe", timeframe.period + (timeframe.isminutes ? "m" : ""), COL_TXT, COL_PANEL)
    f_kv(pan, 29, "Trades", str.tostring(trades) + (beCount > 0 ? " · BE " + str.tostring(beCount) : ""), COL_TXT, COL_PANEL)
    f_kv(pan, 30, "Win Rate", str.tostring(winRate, "#.##") + "%", winRate >= 50 ? COL_TXT : color.rgb(255, 130, 140), winRate >= 50 ? COL_TPBG : COL_SLBG)
    // ── buttons (links shown in tooltip — TradingView tables are not clickable) ──
    table.cell(pan, 0, 34, (glint % 2 == 0 ? "●" : "○") + " LIVE · webhook JSON ready", text_color = color.new(COL_BULL, 25), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    table.cell(pan, 0, 35, "Renko + Keltner · 2 engines · brick math", text_color = COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
````
