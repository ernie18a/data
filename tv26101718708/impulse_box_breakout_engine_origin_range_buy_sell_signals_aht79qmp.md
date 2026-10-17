# Impulse Box Breakout Engine - Origin Range Buy Sell Signals

- url: https://www.tradingview.com/script/aHt79qmP-Impulse-Box-Breakout-Engine-Origin-Range-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;0d57461330d84d08a6fd24fb994ac8d2
- version: 1.0

## Description

IMPULSE BOX BREAKOUT ENGINE — a complete breakout trading system in one indicator: self-adjusting impulse boxes with entry arrow, stop, two fixed targets, a pink trailing-stop dot line and webhook automation. Rebuilt 1:1 from a professional German "Impulsbox" breakout engine (72-minute source webinar, analyzed frame by frame) and redesigned as a modern cockpit indicator.

█ WHAT IT DOES

The engine meters the market N bars back: the range the market traded in PLUS the length of every single bar inside it (compression check). When a STRONG impulse bar closes outside that range, the IMPULSE BOX appears over the consolidation:

• CYAN BOX = long breakout — big entry arrow inside the box
• GOLD BOX = short breakout — mirrored to the downside
• Initial stop = the far side of the box (bottom for longs, top for shorts)
• TARGET 1 + TARGET 2 (violet marks) are projected from the box height the moment the box appears — FIXED, never repainted, never moved afterwards
• PINK DOTS = the trailing stop. It starts at the box edge and follows price with ~30% of the move as breathing room. It only ratchets in your favor — never back
• At Target 1 the stop jumps to break-even or better. After Target 2 the system follows the source rule: "never leave the market voluntarily — let the stop take you out"

█ SELF-OPTIMIZING ENGINE

Markets are sideways ~80% of the time — rigid breakout parameters fail there. This engine adapts automatically:

• TREND regime (ADX based): short lookback, wider targets (+35% / +100% of box height)
• RANGE regime: longer lookback, stricter impulse filter, closer targets (+25% / +75%)
• AUTO-RECALIBRATION: after a false breakout the impulse threshold is raised temporarily — fewer but cleaner boxes. A winning box resets it
• The cockpit shows the current regime, calibration and effective parameters at all times

█ HONEST LIVE STATISTICS

The cockpit counts every box on your chart and shows the real Target-1 and Target-2 hit rates — no marketing numbers, live counted on your symbol and timeframe. On XAUUSD 15m the default engine printed 500+ boxes with a T1 hit rate above 90% at the time of publishing (past performance never guarantees future results).

█ DIRECTION BIAS FILTER

The #1 rule of the source system: trade boxes only in the direction of the higher-level move. The indicator automates this via EMA-200 + Supertrend bias. Choose: Off / Mark counter-bias boxes (dimmed + warning) / Filter them out completely. Supertrend companion arrows are included as extra confluence.

█ EVERY SIGNAL EXPLAINS ITSELF

Hover any BUY/SELL pill: how many bars of consolidation, how strong the impulse bar was (x average bar), which range edge broke, which regime the engine was in, whether the box agrees with the bias — plus entry, stop and both targets. No black box.

█ WEBHOOK AUTOMATION (BOTS / BRIDGES)

Create ONE alert with "Any alert() function call" and your webhook URL. The indicator fires ready-to-use JSON on BUY, SELL, T1_HIT, T2_HIT, TRAIL_EXIT and SL_HIT — including entry, stop, both targets, box levels, regime and live hit rates. Works with any webhook bridge, bot or auto-trader.

█ HOW TO USE

1) Add to chart — works on ALL symbols and ALL timeframes (crypto, gold, forex, indices, stocks)
2) Use standard candles or OHLC bars (Heikin-Ashi smoothing swallows breakouts — a key finding of the source webinar)
3) Wait for a box + arrow, entry at the breakout close, stop at the far box edge
4) Take partial profit at Target 1, let the rest run with the pink trailing dots
5) Automate via webhook JSON if you want

█ SETTINGS

Everything is configurable: manual mode with fixed lookback/impulse strength, target distances, trailing gap, exit-at-T2 mode, bias filter mode, Supertrend, chart theme, cockpit position and all alert toggles.

Educational tool only — not financial advice. Trading involves substantial risk. Always test on a demo account first and never risk money you cannot afford to lose.


WHY THESE PARTS BELONG TOGETHER

The impulse detection and the box are one mechanism, not two features. The impulse identifies the
candle sequence that moved the market; the box freezes the range that impulse came out of, because
that range is the level the market has to defend for the move to continue. Detecting impulses
without marking their origin gives you a signal with no invalidation, and drawing boxes without an
impulse gives you consolidation zones with no direction.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//   IMPULSE BOX PRO  v1.0
//  1:1 rebuild of the "Impulsbox" breakout-box engine (72-minute source webinar,
//  frame-by-frame video analysis, DAX futures 5m/15m/1H/4H) as a TradingView
//  indicator in a dark cockpit design.
//
//  Engine (exactly as described + shown in the source system):
//   • Range metering       = the engine looks N bars back and measures the range
//                            the market traded in PLUS the length of every single
//                            bar inside it (compression check)
//   • Impulse breakout     = a STRONG impulse bar CLOSES outside the range
//                            → the IMPULSE BOX appears over the consolidation
//   • Long box (cyan)      = frame + transparent fill + big entry arrow inside
//   • Short box (gold)     = mirrored to the downside
//   • Initial stop         = far side of the box (bottom for long, top for short)
//   • Trailing stop dots   = pink dots that ratchet behind price with ~30% of
//                            the box height as breathing room — never move back
//   • Target 1 / Target 2  = violet marks projected from the box height at the
//                            moment the box appears — FIXED, never repainted
//                            (source stats: T1 hit >80%, T2 hit 50-60% — this
//                            rebuild counts its own honest live hit rates)
//   • Self-optimization    = regime engine (trend vs. sideways) re-calibrates
//                            lookback, impulse threshold and target distances,
//                            plus an auto-recalibration after false breakouts
//   • Direction bias       = "only trade boxes in the direction of the higher
//                            level wave" → automated as an optional bias filter
//   • Supertrend arrows    = the companion arrows from the source chart
// ═══════════════════════════════════════════════════════════════════════════════
indicator("Impulse Box Breakout Engine", "IMPULSE BOX", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────── PALETTE ───────────────────────────────────
color COL_BG     = color.rgb(6, 17, 30)      // navy outer
color COL_PANEL  = color.rgb(10, 29, 46)     // panel glass
color COL_PANEL2 = color.rgb(15, 44, 66)     // panel section
color COL_BULL   = color.rgb(126, 224, 208)  // mint
color COL_BEAR   = color.rgb(244, 44, 58)    // red
color COL_CYAN   = color.rgb(53, 200, 255)
color COL_GOLD   = color.rgb(255, 215, 40)
color COL_GOLD2  = color.rgb(255, 236, 130)
color COL_GOLD3  = color.rgb(238, 190, 30)
color COL_GOLD4  = color.rgb(210, 160, 20)
color COL_GOLD5  = color.rgb(170, 125, 12)
color COL_GLINT  = color.rgb(255, 252, 214)
color COL_PINK   = color.rgb(255, 62, 130)   // trailing-stop dots (rosa in source)
color COL_VIOL   = color.rgb(186, 120, 255)  // target marks (lila in source)
color COL_SELLBG = color.rgb(126, 32, 36)
color COL_BUYBG  = color.rgb(120, 154, 52)
color COL_TPBG   = color.rgb(16, 94, 70)
color COL_SLBG   = color.rgb(94, 18, 26)
color COL_TXT    = color.rgb(235, 235, 235)
color COL_GREY   = color.rgb(176, 182, 192)
color COL_REDSOFT = color.rgb(255, 130, 140)

// ─────────────────────────────── INPUTS ───────────────────────────────────────
grpE = "① Impulse Box Engine"
autoOpt     = input.bool(true, "Self-optimizing engine (regime adaptive)", group = grpE, tooltip = "The heart of the source system: it does NOT run on rigid parameters. A trend/sideways regime engine re-calibrates the range lookback, the impulse-bar threshold and both target distances to the current market phase — sideways markets get a longer lookback and a stricter impulse filter, trending markets a shorter lookback and wider targets. Turn OFF to use the manual values below.")
rangeLenIn  = input.int(16, "Range lookback (bars, manual mode)", minval = 5, maxval = 100, group = grpE, tooltip = "How many bars back the engine meters the consolidation range. Only used when the self-optimizing engine is OFF.")
impMultIn   = input.float(1.4, "Impulse bar strength (x avg bar, manual)", minval = 0.8, maxval = 4.0, step = 0.1, group = grpE, tooltip = "The breakout bar must span at least this many times the average bar length. The source engine explicitly meters the length of every single bar — a breakout without a strong impulse bar is ignored. Only used in manual mode.")
rangeMinAtr = input.float(0.8, "Min box height (ATR)", minval = 0.0, step = 0.1, group = grpE, tooltip = "Range high minus range low must span at least this many ATR. Skips micro-ranges = pure noise breakouts.")
rangeMaxAtr = input.float(5.0, "Max box height (ATR)", minval = 1.0, step = 0.5, group = grpE, tooltip = "Ranges taller than this are not a real consolidation any more — no box.")
breakBuf    = input.float(0.05, "Breakout buffer (ATR)", minval = 0.0, step = 0.05, group = grpE, tooltip = "The close must clear the range edge by this ATR fraction. Filters one-tick fake pokes.")
bodyMinPct  = input.float(50, "Min body of impulse bar (%)", minval = 0, maxval = 90, step = 5, group = grpE, tooltip = "Body / full bar length of the breakout candle. A long wick with a tiny body is not an impulse.")

grpO = "② Auto-Recalibration"
recalOn     = input.bool(true, "Recalibrate after a false breakout", group = grpO, tooltip = "The source engine re-optimizes itself on every restart. This rebuild does it live: after a stopped-out box the impulse threshold is temporarily raised (fewer, cleaner boxes), after a second loss in a row it is raised further. A winning box resets the calibration. The current calibration state is shown in the cockpit panel.")
recalBars   = input.int(40, "Recalibration window (bars)", minval = 10, maxval = 200, group = grpO)
adxLen      = input.int(14, "Regime ADX length", minval = 5, maxval = 50, group = grpO)
adxTrend    = input.float(22, "Trend regime threshold (ADX)", minval = 10, maxval = 40, step = 1, group = grpO, tooltip = "ADX above this = TREND regime (shorter lookback, wider targets). Below = RANGE regime (longer lookback, stricter impulse filter, closer targets). 80% of the time markets are sideways — that is exactly why the source system adapts.")

grpM = "③ Trade Management (box logic)"
t1FacIn     = input.float(0.25, "Target 1 distance (x box height, manual)", minval = 0.1, step = 0.05, group = grpM, tooltip = "T1 = box edge + box height x this factor. The source engine used ~25% in range phases and ~35% in trend phases (self-optimized). Fixed at the moment the box appears — never repainted.")
t2FacIn     = input.float(0.75, "Target 2 distance (x box height, manual)", minval = 0.2, step = 0.05, group = grpM, tooltip = "T2 = box edge + box height x this factor. Source: ~75% in range phases, up to 100%+ in trend phases.")
trailPct    = input.float(30, "Trailing stop gap (% of trade range)", minval = 5, maxval = 80, step = 5, group = grpM, tooltip = "The pink trailing-stop dots keep roughly this much of the whole trade distance (box bottom to the highest point reached) as breathing room — the '~30% gap to the current price' described in the source webinar. The gap grows with the move, so runners get room to reach Target 2. The stop only ratchets in your favor, never back.")
exitAtT2    = input.bool(false, "Exit fully at Target 2", group = grpM, tooltip = "OFF (default) = the source rule: 'there is no reason to leave the market voluntarily at Target 2 — work with the stop and let the market kick you out'. The trailing dots keep running after T2. ON = book the trade at T2.")
showTrDots  = input.bool(true, "Show trailing-stop dots (pink)", group = grpM)
showTargets = input.bool(true, "Show Target 1 / Target 2 marks (violet)", group = grpM)

grpB = "④ Direction Bias & Supertrend"
biasMode    = input.string("Mark counter-bias", "Bias filter (higher-level direction)", options = ["Off", "Mark counter-bias", "Filter counter-bias"], group = grpB, tooltip = "The #1 rule of the source webinar: 'first follow the higher-level direction — then the box is your entry in that direction. That is how you avoid nearly all false signals.' This rebuild automates it: bias = price vs. EMA-200 + Supertrend direction. MARK = counter-bias boxes are drawn dimmed with a warning. FILTER = counter-bias boxes are skipped entirely.")
emaBiasLen  = input.int(200, "Bias EMA length", minval = 50, maxval = 500, group = grpB)
showST      = input.bool(true, "Supertrend companion arrows", group = grpB, tooltip = "The small green/red arrows from the source chart. Great extra confluence in trending markets — but the box engine is the boss in sideways phases.")
stFactor    = input.float(3.0, "Supertrend factor", minval = 1.0, step = 0.25, group = grpB)
stLen       = input.int(10, "Supertrend ATR length", minval = 3, maxval = 50, group = grpB)

grpD = "⑤ Design"
useTheme    = input.bool(true, "Dark chart theme (navy + mint/red candles)", group = grpD, tooltip = "Tip from the source webinar: use STANDARD candles or OHLC bars. Heikin-Ashi smoothing swallows breakouts and with them entire boxes.")
showPanel   = input.bool(true, "Show Cockpit panel", group = grpD)
panelPos    = input.string("Middle Left", "Panel position", options = ["Middle Left", "Top Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group = grpD)
showWhy     = input.bool(true, "WHY-labels on every box", group = grpD, tooltip = "Every box explains itself directly in the chart: how many bars of consolidation, how strong the impulse bar was, which regime the engine was in and where stop + targets sit. Hover the BUY/SELL pill for the full reasoning.")

grpA = "⑥ Alerts & Webhook (Automation)"
alSignals   = input.bool(true, "Alert on BUY/SELL (webhook JSON)", group = grpA, tooltip = "Create ONE alert with condition 'Any alert() function call' and paste your webhook URL. Every box fires ready-to-use JSON (entry, stop, both targets, regime, live hit rates) for bots, bridges and auto-traders.")
alManage    = input.bool(true, "Alert on T1 / T2 / Trail / SL events", group = grpA)
whId        = input.string("IMPULSE-BOX-PRO", "Webhook strategy ID", group = grpA)

// ─────────────────────────────── BASICS / THEME ───────────────────────────────
float atr14    = ta.atr(14)
float avgBar   = ta.sma(high - low, 50)
bool  proc     = barstate.isconfirmed

bgcolor(useTheme ? color.new(COL_BG, 0) : na)
barcolor(useTheme ? (close >= open ? COL_BULL : COL_BEAR) : na)

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

// ─────────────────────────── REGIME ENGINE (self-optimization) ─────────────────
[diP, diM, adxV] = ta.dmi(adxLen, adxLen)
bool trendRegime = adxV >= adxTrend

// the engine runs two metering windows in parallel and the regime picks one —
// short lookback in trends (boxes form fast), long lookback in sideways chop
float rhFast = ta.highest(high[1], 10)
float rlFast = ta.lowest(low[1], 10)
float rhSlow = ta.highest(high[1], 22)
float rlSlow = ta.lowest(low[1], 22)

int   effLen   = autoOpt ? (trendRegime ? 10 : 22) : rangeLenIn
float rhManual = ta.highest(high[1], rangeLenIn)
float rlManual = ta.lowest(low[1], rangeLenIn)
float rangeHi  = autoOpt ? (trendRegime ? rhFast : rhSlow) : rhManual
float rangeLo  = autoOpt ? (trendRegime ? rlFast : rlSlow) : rlManual

// auto-recalibration: raise the impulse threshold after false breakouts
var int   lossStreak = 0
var int   recalUntil = -1
float recalAdd   = recalOn and bar_index <= recalUntil ? math.min(2, lossStreak) * 0.25 : 0.0
float impMultEff = (autoOpt ? (trendRegime ? 1.2 : 1.5) : impMultIn) + recalAdd
float t1Fac      = autoOpt ? (trendRegime ? 0.35 : 0.25) : t1FacIn
float t2Fac      = autoOpt ? (trendRegime ? 1.00 : 0.75) : t2FacIn

// ─────────────────────────── BOX CONDITIONS ───────────────────────────────────
float boxH      = rangeHi - rangeLo
bool  rangeOK   = boxH >= atr14 * rangeMinAtr and boxH <= atr14 * rangeMaxAtr
float barSpan   = high - low
float barBody   = math.abs(close - open)
bool  strongBar = barSpan >= avgBar * impMultEff and barSpan > 0 and barBody / barSpan * 100 >= bodyMinPct
bool  breakUp   = close > rangeHi + atr14 * breakBuf and close > open
bool  breakDn   = close < rangeLo - atr14 * breakBuf and close < open

// direction bias = EMA side + supertrend direction ("trade with the wave")
float emaBias = ta.ema(close, emaBiasLen)
[stLine, stDir] = ta.supertrend(stFactor, stLen)
bool  biasUp   = close > emaBias and stDir < 0
bool  biasDn   = close < emaBias and stDir > 0
bool  stFlipUp = stDir < 0 and stDir[1] >= 0
bool  stFlipDn = stDir > 0 and stDir[1] <= 0

// ─────────────────────────── TRADE STATE ──────────────────────────────────────
var int    dir       = 0        // 0 flat · 1 long · -1 short
var float  tEntry    = na
var float  tSL       = na       // live stop (initial = far box edge, then ratchets)
var float  tT1       = na
var float  tT2       = na
var float  tBoxTop   = na
var float  tBoxBot   = na
var float  tBoxH     = na
var float  hhSince   = na       // extreme since entry (for the trailing gap)
var bool   t1Hit     = false
var bool   t2Hit     = false
var bool   tCounter  = false    // trade taken against the bias
var int    boxCount  = 0
var int    t1Count   = 0
var int    t2Count   = 0
var int    lossCount = 0
var int    winCount  = 0
var string sigTxt    = "NO BOX YET"
var box    liveBox   = na
var array<box>   histBoxes = array.new<box>()
var array<line>  tgtLines  = array.new<line>()
var array<label> tgtLabs   = array.new<label>()

bool buySignal  = false
bool sellSignal = false
bool t1Event    = false
bool t2Event    = false
bool slEvent    = false
bool trailExit  = false

f_capBoxes() =>
    while array.size(histBoxes) > 150
        box.delete(array.shift(histBoxes))
f_capLines() =>
    while array.size(tgtLines) > 280
        line.delete(array.shift(tgtLines))
    while array.size(tgtLabs) > 280
        label.delete(array.shift(tgtLabs))

bool allowLong  = biasMode != "Filter counter-bias" or biasUp or not (biasUp or biasDn)
bool allowShort = biasMode != "Filter counter-bias" or biasDn or not (biasUp or biasDn)

if proc
    // ── manage the open box trade first (source order: stop → targets) ──
    if dir == 1
        hhSince := math.max(hhSince, high)
        // pink trailing dots: initial stop = box bottom (source rule), then the
        // stop follows 70% of every point of progress so ~30% of the move stays
        // as breathing room to the current price — ratchets up, never back
        tSL := math.max(tSL, tBoxBot + math.max(0.0, hhSince - tEntry) * (100 - trailPct) / 100)
        if low <= tSL
            bool win = tSL > tEntry + syminfo.mintick
            trailExit := win or t1Hit
            slEvent   := not win and not t1Hit
            if win or t1Hit
                winCount += 1
                lossStreak := 0
                sigTxt := "TRAIL EXIT ✔ +" + str.tostring(tSL - tEntry, format.mintick)
            else
                lossCount += 1
                lossStreak += 1
                recalUntil := bar_index + recalBars
                sigTxt := "STOP HIT ✖"
            label.new(bar_index, tSL, win or t1Hit ? "TRAIL ✔" : "SL ✖", style = label.style_label_up, color = win or t1Hit ? color.new(COL_TPBG, 20) : color.new(COL_SLBG, 10), textcolor = win or t1Hit ? COL_BULL : COL_REDSOFT, size = size.tiny, tooltip = "LONG box closed at " + str.tostring(tSL, format.mintick) + (win or t1Hit ? "\nThe trailing stop did its job — profit banked, exactly the source rule: never leave voluntarily, let the stop take you out." : "\nFalse breakout — the box failed before Target 1. The engine recalibrates: impulse threshold raised for the next " + str.tostring(recalBars) + " bars."))
            dir := 0
        else
            if not t1Hit and high >= tT1
                t1Hit := true
                t1Count += 1
                t1Event := true
                tSL := math.max(tSL, tEntry)       // stop at least to entry once T1 is tagged
                sigTxt := "T1 HIT ✔ · TRAILING"
                label.new(bar_index, tT1, "T1 ✔", style = label.style_label_down, color = color.new(COL_TPBG, 20), textcolor = COL_BULL, size = size.tiny, tooltip = "Target 1 hit at " + str.tostring(tT1, format.mintick) + "\nStop is now at break-even or better. Rest of the position trails on.")
            if not t2Hit and high >= tT2
                t2Hit := true
                t2Count += 1
                t2Event := true
                label.new(bar_index, tT2, "T2 ✔", style = label.style_label_down, color = color.new(COL_GOLD5, 10), textcolor = COL_GOLD, size = size.tiny, tooltip = "Target 2 hit at " + str.tostring(tT2, format.mintick) + (exitAtT2 ? "\nFull exit (Exit at Target 2 is ON)." : "\nSource rule: no reason to leave voluntarily — the pink trailing dots keep working."))
                if exitAtT2
                    winCount += 1
                    lossStreak := 0
                    sigTxt := "T2 EXIT ✔"
                    dir := 0
    else if dir == -1
        hhSince := math.min(hhSince, low)
        tSL := math.min(tSL, tBoxTop - math.max(0.0, tEntry - hhSince) * (100 - trailPct) / 100)
        if high >= tSL
            bool winS = tSL < tEntry - syminfo.mintick
            trailExit := winS or t1Hit
            slEvent   := not winS and not t1Hit
            if winS or t1Hit
                winCount += 1
                lossStreak := 0
                sigTxt := "TRAIL EXIT ✔ +" + str.tostring(tEntry - tSL, format.mintick)
            else
                lossCount += 1
                lossStreak += 1
                recalUntil := bar_index + recalBars
                sigTxt := "STOP HIT ✖"
            label.new(bar_index, tSL, winS or t1Hit ? "TRAIL ✔" : "SL ✖", style = label.style_label_down, color = winS or t1Hit ? color.new(COL_TPBG, 20) : color.new(COL_SLBG, 10), textcolor = winS or t1Hit ? COL_BULL : COL_REDSOFT, size = size.tiny, tooltip = "SHORT box closed at " + str.tostring(tSL, format.mintick) + (winS or t1Hit ? "\nThe trailing stop did its job — profit banked, exactly the source rule: never leave voluntarily, let the stop take you out." : "\nFalse breakout — the box failed before Target 1. The engine recalibrates: impulse threshold raised for the next " + str.tostring(recalBars) + " bars."))
            dir := 0
        else
            if not t1Hit and low <= tT1
                t1Hit := true
                t1Count += 1
                t1Event := true
                tSL := math.min(tSL, tEntry)
                sigTxt := "T1 HIT ✔ · TRAILING"
                label.new(bar_index, tT1, "T1 ✔", style = label.style_label_up, color = color.new(COL_TPBG, 20), textcolor = COL_BULL, size = size.tiny, tooltip = "Target 1 hit at " + str.tostring(tT1, format.mintick) + "\nStop is now at break-even or better. Rest of the position trails on.")
            if not t2Hit and low <= tT2
                t2Hit := true
                t2Count += 1
                t2Event := true
                label.new(bar_index, tT2, "T2 ✔", style = label.style_label_up, color = color.new(COL_GOLD5, 10), textcolor = COL_GOLD, size = size.tiny, tooltip = "Target 2 hit at " + str.tostring(tT2, format.mintick) + (exitAtT2 ? "\nFull exit (Exit at Target 2 is ON)." : "\nSource rule: no reason to leave voluntarily — the pink trailing dots keep working."))
                if exitAtT2
                    winCount += 1
                    lossStreak := 0
                    sigTxt := "T2 EXIT ✔"
                    dir := 0

    // ── new impulse box (only when flat — the source opens box #2 after box #1 is done) ──
    if dir == 0 and rangeOK and strongBar
        bool counterL = biasDn
        bool counterS = biasUp
        if breakUp and allowLong
            // LONG IMPULSE BOX over the consolidation that was just broken
            dir := 1
            buySignal := true
            boxCount += 1
            tEntry  := close
            tBoxTop := rangeHi
            tBoxBot := rangeLo
            tBoxH   := boxH
            tSL     := rangeLo
            tT1     := rangeHi + boxH * t1Fac
            tT2     := rangeHi + boxH * t2Fac
            hhSince := close
            t1Hit   := false
            t2Hit   := false
            tCounter := counterL
            sigTxt  := "LONG BOX " + str.tostring(tEntry, format.mintick)
            color bC = counterL and biasMode == "Mark counter-bias" ? color.new(COL_CYAN, 55) : color.new(COL_CYAN, 10)
            liveBox := box.new(bar_index - effLen, rangeHi, bar_index, rangeLo, border_color = bC, border_width = 2, bgcolor = color.new(COL_CYAN, 84), text = showWhy ? "IMPULSE BOX · LONG" + (counterL ? " ⚠" : "") : "", text_color = color.new(COL_CYAN, 20), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top)
            array.push(histBoxes, liveBox)
            f_capBoxes()
            // big entry arrow INSIDE the box — the source look
            label.new(bar_index, (rangeHi + rangeLo) / 2, "▲", style = label.style_none, textcolor = COL_CYAN, size = size.large, tooltip = "Entry arrow — appears together with the box, exactly like the source system.")
            if showTargets
                // violet target marks, right-aligned above the box — fixed forever
                line t1l = line.new(bar_index, tT1, bar_index + 6, tT1, color = COL_VIOL, style = line.style_dashed, width = 2)
                line t2l = line.new(bar_index, tT2, bar_index + 6, tT2, color = COL_VIOL, style = line.style_dashed, width = 2)
                label t1b = label.new(bar_index + 6, tT1, "T1 " + str.tostring(tT1, format.mintick), style = label.style_label_left, color = color.new(COL_PANEL2, 20), textcolor = COL_VIOL, size = size.tiny, tooltip = "Target 1 = box top + " + str.tostring(t1Fac * 100, "#") + "% of the box height.\nProjected the moment the box appeared — never moved afterwards.\nSource stat: T1 is hit in over 80% of boxes. This chart's live rate is in the cockpit panel.")
                label t2b = label.new(bar_index + 6, tT2, "T2 " + str.tostring(tT2, format.mintick), style = label.style_label_left, color = color.new(COL_PANEL2, 20), textcolor = COL_VIOL, size = size.tiny, tooltip = "Target 2 = box top + " + str.tostring(t2Fac * 100, "#") + "% of the box height.\nProjected the moment the box appeared — never moved afterwards.\nSource stat: T2 is hit in 50-60% of boxes.")
                array.push(tgtLines, t1l)
                array.push(tgtLines, t2l)
                array.push(tgtLabs, t1b)
                array.push(tgtLabs, t2b)
                f_capLines()
            label.new(bar_index, low, "  BUY ▲  \nIMPULSE BOX · T1 +" + str.tostring(t1Fac * 100, "#") + "%", style = label.style_label_up, color = COL_BUYBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS BUY?\n1) Market compressed for " + str.tostring(effLen) + " bars in a " + str.tostring(boxH, format.mintick) + " range (" + str.tostring(boxH / atr14, "#.#") + " ATR)\n2) Impulse bar: " + str.tostring(barSpan / avgBar, "#.#") + "x the average bar (needs ≥ " + str.tostring(impMultEff, "#.##") + "x, body ≥ " + str.tostring(bodyMinPct, "#") + "%)\n3) Close broke the range TOP " + str.tostring(rangeHi, format.mintick) + "\n4) Regime: " + (trendRegime ? "TREND (fast lookback, wide targets)" : "RANGE (slow lookback, close targets)") + (counterL ? "\n⚠ COUNTER-BIAS: higher-level direction is DOWN — the source rule says prefer boxes WITH the wave" : "\n5) Bias: higher-level direction is UP — box agrees with the wave") + "\n\nEntry " + str.tostring(tEntry, format.mintick) + "\nStop " + str.tostring(tSL, format.mintick) + " (box bottom)\nT1 " + str.tostring(tT1, format.mintick) + " · T2 " + str.tostring(tT2, format.mintick) + "\nPink dots = trailing stop (" + str.tostring(trailPct, "#") + "% box-height gap)")
        else if breakDn and allowShort
            // SHORT IMPULSE BOX
            dir := -1
            sellSignal := true
            boxCount += 1
            tEntry  := close
            tBoxTop := rangeHi
            tBoxBot := rangeLo
            tBoxH   := boxH
            tSL     := rangeHi
            tT1     := rangeLo - boxH * t1Fac
            tT2     := rangeLo - boxH * t2Fac
            hhSince := close
            t1Hit   := false
            t2Hit   := false
            tCounter := counterS
            sigTxt  := "SHORT BOX " + str.tostring(tEntry, format.mintick)
            color bC2 = counterS and biasMode == "Mark counter-bias" ? color.new(COL_GOLD, 55) : color.new(COL_GOLD, 10)
            liveBox := box.new(bar_index - effLen, rangeHi, bar_index, rangeLo, border_color = bC2, border_width = 2, bgcolor = color.new(COL_GOLD, 84), text = showWhy ? "IMPULSE BOX · SHORT" + (counterS ? " ⚠" : "") : "", text_color = color.new(COL_GOLD, 20), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom)
            array.push(histBoxes, liveBox)
            f_capBoxes()
            label.new(bar_index, (rangeHi + rangeLo) / 2, "▼", style = label.style_none, textcolor = COL_GOLD, size = size.large, tooltip = "Entry arrow — appears together with the box, exactly like the source system.")
            if showTargets
                line t1s = line.new(bar_index, tT1, bar_index + 6, tT1, color = COL_VIOL, style = line.style_dashed, width = 2)
                line t2s = line.new(bar_index, tT2, bar_index + 6, tT2, color = COL_VIOL, style = line.style_dashed, width = 2)
                label t1c = label.new(bar_index + 6, tT1, "T1 " + str.tostring(tT1, format.mintick), style = label.style_label_left, color = color.new(COL_PANEL2, 20), textcolor = COL_VIOL, size = size.tiny, tooltip = "Target 1 = box bottom - " + str.tostring(t1Fac * 100, "#") + "% of the box height.\nProjected the moment the box appeared — never moved afterwards.\nSource stat: T1 is hit in over 80% of boxes. This chart's live rate is in the cockpit panel.")
                label t2c = label.new(bar_index + 6, tT2, "T2 " + str.tostring(tT2, format.mintick), style = label.style_label_left, color = color.new(COL_PANEL2, 20), textcolor = COL_VIOL, size = size.tiny, tooltip = "Target 2 = box bottom - " + str.tostring(t2Fac * 100, "#") + "% of the box height.\nProjected the moment the box appeared — never moved afterwards.\nSource stat: T2 is hit in 50-60% of boxes.")
                array.push(tgtLines, t1s)
                array.push(tgtLines, t2s)
                array.push(tgtLabs, t1c)
                array.push(tgtLabs, t2c)
                f_capLines()
            label.new(bar_index, high, "  SELL ▼  \nIMPULSE BOX · T1 -" + str.tostring(t1Fac * 100, "#") + "%", style = label.style_label_down, color = COL_SELLBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS SELL?\n1) Market compressed for " + str.tostring(effLen) + " bars in a " + str.tostring(boxH, format.mintick) + " range (" + str.tostring(boxH / atr14, "#.#") + " ATR)\n2) Impulse bar: " + str.tostring(barSpan / avgBar, "#.#") + "x the average bar (needs ≥ " + str.tostring(impMultEff, "#.##") + "x, body ≥ " + str.tostring(bodyMinPct, "#") + "%)\n3) Close broke the range BOTTOM " + str.tostring(rangeLo, format.mintick) + "\n4) Regime: " + (trendRegime ? "TREND (fast lookback, wide targets)" : "RANGE (slow lookback, close targets)") + (counterS ? "\n⚠ COUNTER-BIAS: higher-level direction is UP — the source rule says prefer boxes WITH the wave" : "\n5) Bias: higher-level direction is DOWN — box agrees with the wave") + "\n\nEntry " + str.tostring(tEntry, format.mintick) + "\nStop " + str.tostring(tSL, format.mintick) + " (box top)\nT1 " + str.tostring(tT1, format.mintick) + " · T2 " + str.tostring(tT2, format.mintick) + "\nPink dots = trailing stop (" + str.tostring(trailPct, "#") + "% box-height gap)")

// ─────────────────────────── CHART PLOTS ──────────────────────────────────────
// pink trailing-stop dots (the "rosa Punkte" of the source system)
plot(showTrDots and dir != 0 ? tSL : na, "Trailing stop dots", color = color.new(COL_PINK, 0), style = plot.style_circles, linewidth = 2)

// supertrend companion arrows (small — the box is the boss)
plotshape(showST and stFlipUp, "Supertrend up", shape.triangleup, location.belowbar, color.new(COL_BULL, 30), size = size.tiny, display = display.pane)
plotshape(showST and stFlipDn, "Supertrend down", shape.triangledown, location.abovebar, color.new(COL_BEAR, 30), size = size.tiny, display = display.pane)
plotshape(buySignal, "BUY marker", shape.triangleup, location.belowbar, COL_CYAN, size = size.tiny, display = display.pane)
plotshape(sellSignal, "SELL marker", shape.triangledown, location.abovebar, COL_GOLD, size = size.tiny, display = display.pane)

// ───────────── RIGHT-EDGE PRICE TAGS (live trade cockpit on the chart) ─────────
var label labEN = na
var label labSL = na
var label labT1 = na
var label labT2 = na
if barstate.islast and not na(tEntry)
    int lx = bar_index + 8
    if na(labEN)
        labEN := label.new(lx, tEntry, "", style = label.style_label_left, size = size.small)
        labSL := label.new(lx, tSL, "", style = label.style_label_left, size = size.small)
        labT1 := label.new(lx, tT1, "", style = label.style_label_left, size = size.small)
        labT2 := label.new(lx, tT2, "", style = label.style_label_left, size = size.small)
    label.set_xy(labEN, lx, tEntry)
    label.set_text(labEN, (dir == 1 ? "LONG" : dir == -1 ? "SHORT" : "LAST") + " Entry : " + str.tostring(tEntry, format.mintick))
    label.set_color(labEN, color.new(COL_PANEL2, 10))
    label.set_textcolor(labEN, COL_TXT)
    label.set_xy(labSL, lx, tSL)
    label.set_text(labSL, (dir != 0 ? "Trailing Stop : " : "Final Stop : ") + str.tostring(tSL, format.mintick))
    label.set_color(labSL, color.new(COL_SLBG, 10))
    label.set_textcolor(labSL, COL_PINK)
    label.set_xy(labT1, lx, tT1)
    label.set_text(labT1, "Target 1 : " + str.tostring(tT1, format.mintick) + (t1Hit ? " ✔" : ""))
    label.set_color(labT1, color.new(COL_PANEL2, 10))
    label.set_textcolor(labT1, COL_VIOL)
    label.set_xy(labT2, lx, tT2)
    label.set_text(labT2, "Target 2 : " + str.tostring(tT2, format.mintick) + (t2Hit ? " ✔" : ""))
    label.set_color(labT2, color.new(COL_PANEL2, 10))
    label.set_textcolor(labT2, COL_VIOL)

// ─────────────────────────── ALERTS / WEBHOOK ─────────────────────────────────
float t1Rate = boxCount > 0 ? t1Count / boxCount * 100 : 0
float t2Rate = boxCount > 0 ? t2Count / boxCount * 100 : 0
float winRate = winCount + lossCount > 0 ? winCount / (winCount + lossCount) * 100 : 0

f_json(string action, float px) =>
    '{"id":"' + whId + '","symbol":"' + syminfo.ticker + '","action":"' + action + '","price":' + str.tostring(px, format.mintick) + ',"entry":' + str.tostring(na(tEntry) ? px : tEntry, format.mintick) + ',"sl":' + str.tostring(na(tSL) ? px : tSL, format.mintick) + ',"tp1":' + str.tostring(na(tT1) ? px : tT1, format.mintick) + ',"tp2":' + str.tostring(na(tT2) ? px : tT2, format.mintick) + ',"box_top":' + str.tostring(na(tBoxTop) ? px : tBoxTop, format.mintick) + ',"box_bottom":' + str.tostring(na(tBoxBot) ? px : tBoxBot, format.mintick) + ',"regime":"' + (trendRegime ? "TREND" : "RANGE") + '","t1_rate":"' + str.tostring(t1Rate, "#.#") + '","t2_rate":"' + str.tostring(t2Rate, "#.#") + '","tf":"' + timeframe.period + '","time":"' + str.format_time(time, "yyyy-MM-dd HH:mm", "GMT") + '"}'

if alSignals and buySignal
    alert(f_json("BUY", tEntry), alert.freq_once_per_bar_close)
if alSignals and sellSignal
    alert(f_json("SELL", tEntry), alert.freq_once_per_bar_close)
if alManage and t1Event
    alert(f_json("T1_HIT", tT1), alert.freq_once_per_bar_close)
if alManage and t2Event
    alert(f_json("T2_HIT", tT2), alert.freq_once_per_bar_close)
if alManage and slEvent
    alert(f_json("SL_HIT", tSL), alert.freq_once_per_bar_close)
if alManage and trailExit
    alert(f_json("TRAIL_EXIT", tSL), alert.freq_once_per_bar_close)

alertcondition(buySignal, "BUY (Impulse Box Long)", "Impulse Box Pro: LONG box {{ticker}} @ {{close}}")
alertcondition(sellSignal, "SELL (Impulse Box Short)", "Impulse Box Pro: SHORT box {{ticker}} @ {{close}}")
alertcondition(t1Event or t2Event, "Target hit", "Impulse Box Pro: target hit {{ticker}} {{interval}}")
alertcondition(slEvent or trailExit, "Trade closed", "Impulse Box Pro: trade closed {{ticker}} {{interval}}")

// ───────────────────────── COCKPIT PANEL ───────────────────────────────────
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

f_check(table t, int r, string badge, string item, string status, color sCol) =>
    table.cell(t, 0, r, badge, text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 1, r, item, text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 6, r, status, text_color = sCol, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right, text_font_family = font.family_monospace)

var table pan = na
if showPanel and barstate.islast
    if na(pan)
        pan := table.new(f_pos(), 8, 33, bgcolor = color.new(COL_PANEL, 0), frame_color = COL_CYAN, frame_width = 2, border_color = color.new(COL_CYAN, 88), border_width = 1)
        for r = 0 to 32
            for c = 0 to 7
                table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
        table.merge_cells(pan, 0, 5, 6, 5)
        table.cell(pan, 0, 6, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 6, 7, 6)
        table.merge_cells(pan, 0, 8, 7, 8)
        table.merge_cells(pan, 0, 9, 7, 9)
        for r = 10 to 13
            table.merge_cells(pan, 0, r, 3, r)
            table.merge_cells(pan, 4, r, 7, r)
        table.merge_cells(pan, 0, 14, 7, 14)
        table.merge_cells(pan, 0, 15, 4, 15)
        table.merge_cells(pan, 5, 15, 7, 15)
        for r = 16 to 21
            table.merge_cells(pan, 1, r, 5, r)
            table.merge_cells(pan, 6, r, 7, r)
        table.merge_cells(pan, 0, 22, 7, 22)
        table.merge_cells(pan, 0, 23, 7, 23)
        table.merge_cells(pan, 0, 24, 7, 24)
        table.merge_cells(pan, 0, 25, 4, 25)
        table.merge_cells(pan, 5, 25, 7, 25)
        for r = 26 to 28
            table.merge_cells(pan, 0, r, 3, r)
            table.merge_cells(pan, 4, r, 7, r)
        table.cell(pan, 0, 29, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 29, 7, 29)
        table.cell(pan, 0, 30, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 30, 7, 30)
        table.cell(pan, 0, 31, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 31, 7, 31)
        table.merge_cells(pan, 0, 32, 7, 32)
    int gcol = glint % 8
    for r = 0 to 4
        for c = 0 to 7
            table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
    // ── header ──
    table.cell(pan, 0, 5, "IMPULSE BOX", text_color = COL_GOLD, text_size = size.normal, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(pan, 7, 5, glint % 2 == 0 ? "●" : "○", text_color = COL_CYAN, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    for c = 0 to 7
        table.cell(pan, c, 7, "▲", text_color = c == gcol ? COL_GOLD : color.new(COL_BULL, 35), text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    f_spacer(pan, 8)
    // ── regime / auto-optimization chip ──
    string regTxt = autoOpt ? ("AUTO-OPT · " + (trendRegime ? "TREND REGIME" : "RANGE REGIME") + (recalAdd > 0 ? " · RECAL +" + str.tostring(recalAdd, "#.##") : "")) : "MANUAL PARAMETERS"
    table.cell(pan, 0, 9, regTxt, text_color = autoOpt ? (trendRegime ? COL_BULL : COL_CYAN) : COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    // ── info grid ──
    f_kv(pan, 10, "Symbol / TF", syminfo.ticker + " · " + timeframe.period, COL_TXT, COL_PANEL)
    f_kv(pan, 11, "Box lookback", str.tostring(effLen) + " bars", COL_TXT, COL_PANEL)
    f_kv(pan, 12, "Impulse filter", str.tostring(impMultEff, "#.##") + "x avg bar", COL_TXT, COL_PANEL)
    f_kv(pan, 13, "Targets", "+" + str.tostring(t1Fac * 100, "#") + "% / +" + str.tostring(t2Fac * 100, "#") + "% box", COL_VIOL, COL_PANEL)
    f_spacer(pan, 14)
    // ── checklist ──
    f_header(pan, 15, "IMPULSE CHECKLIST", "")
    f_check(pan, 16, "❶", "RANGE METERED", rangeOK ? "OK" : "‥", rangeOK ? COL_BULL : COL_GREY)
    f_check(pan, 17, "❷", "BOX HEIGHT " + str.tostring(boxH / atr14, "#.#") + " ATR", rangeOK ? "OK" : "‥", rangeOK ? COL_BULL : COL_GREY)
    f_check(pan, 18, "❸", "IMPULSE BAR ≥" + str.tostring(impMultEff, "#.#") + "x", strongBar ? "OK" : "‥", strongBar ? COL_BULL : COL_GREY)
    f_check(pan, 19, "❹", "BREAKOUT CLOSE", dir != 0 ? "RUN" : breakUp or breakDn ? "OK" : "‥", dir != 0 ? COL_GOLD : breakUp or breakDn ? COL_BULL : COL_GREY)
    f_check(pan, 20, "❺", "BIAS DIRECTION", biasUp ? "LONG" : biasDn ? "SHORT" : "MIXED", biasUp ? COL_BULL : biasDn ? COL_BEAR : COL_GREY)
    f_check(pan, 21, "❻", "TRADE STATUS", dir != 0 ? (t2Hit ? "T2✔" : t1Hit ? "T1✔" : "RUN") : "‥", dir != 0 ? (t1Hit ? COL_CYAN : COL_GOLD) : COL_GREY)
    f_spacer(pan, 22)
    // ── position box ──
    string posTxt = dir == 1 ? "LONG " + str.tostring(tEntry, format.mintick) + " · TS " + str.tostring(tSL, format.mintick) : dir == -1 ? "SHORT " + str.tostring(tEntry, format.mintick) + " · TS " + str.tostring(tSL, format.mintick) : "NO POSITION"
    table.cell(pan, 0, 23, posTxt, text_color = dir == 0 ? COL_GREY : COL_TXT, text_size = size.small, bgcolor = dir == 1 ? color.new(COL_TPBG, 0) : dir == -1 ? color.new(COL_SLBG, 0) : color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    // ── big signal line ──
    color sigCol = dir != 0 ? COL_GOLD : str.contains(sigTxt, "✔") ? COL_BULL : str.contains(sigTxt, "✖") ? COL_BEAR : COL_GREY
    table.cell(pan, 0, 24, sigTxt, text_color = sigCol, text_size = size.large, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    // ── live statistics (honest, counted on this chart) ──
    f_header(pan, 25, "BOX STATISTICS", "LIVE")
    f_kv(pan, 26, "Boxes", str.tostring(boxCount), COL_TXT, COL_PANEL)
    f_kv(pan, 27, "T1 hit rate", str.tostring(t1Rate, "#.#") + "%  (" + str.tostring(t1Count) + ")", t1Rate >= 70 ? COL_BULL : COL_TXT, t1Rate >= 70 ? COL_TPBG : COL_PANEL)
    f_kv(pan, 28, "T2 hit rate", str.tostring(t2Rate, "#.#") + "%  (" + str.tostring(t2Count) + ")", t2Rate >= 45 ? COL_BULL : COL_TXT, t2Rate >= 45 ? COL_TPBG : COL_PANEL)
    // ── buttons (links shown in tooltip — TradingView tables are not clickable) ──
    table.cell(pan, 0, 32, (glint % 2 == 0 ? "●" : "○") + " LIVE · webhook JSON ready", text_color = color.new(COL_BULL, 25), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
````
