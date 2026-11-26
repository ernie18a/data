# Opening Range Breakout Engine - Session Range Signals

- url: https://www.tradingview.com/script/M4UE0Tyf-Opening-Range-Breakout-Engine-Session-Range-Signals/
- type: indicator
- pine_id: PUB;5b1958be0b694cf1973e472f6ed69982
- version: 4.0

## Description

aDESCRIPTION:
RANGE BREAKOUT PRO is a complete range-breakout trading engine: it detects tradeable ranges from confirmed swing pivots, fires BUY and SELL signals when price breaks out in the direction of the trend, and then manages every trade on the chart with entry, stop loss, take profit, break-even and trailing logic - all fully visualized and fully automatable via webhook alerts.

HOW THE ENGINE WORKS

1. RANGE DETECTION - Confirmed swing highs and swing lows (pivot length configurable) become the active RANGE HIGH and RANGE LOW. Each extreme is marked on the chart with a dot and a vertical marker line. A range must be wide enough (minimum height in ATR) and fresh enough (maximum age in bars) to be tradeable - micro-ranges and stale levels are skipped automatically.

2. BREAKOUT SIGNAL - A signal fires only when a candle CLOSES beyond the range extreme plus an ATR buffer (no wick fake-outs), the gradient trend ribbon points in the breakout direction, the trend strength score clears your Buy/Sell Strength threshold, the breakout is not overextended (max distance from the ribbon in ATR - no chasing exhausted moves), and an optional cooldown after a losing trade has expired. Optional MTF Agreement requires the 15-minute trend to confirm.

3. TRADE MANAGEMENT - Every signal is managed like a real trade, live on the chart:
- TP1 (partial target) banks the win early and moves the stop to break-even
- the remainder runs to the full R-multiple take profit or a chandelier trail
- green TP box and red SL box grow bar by bar from the entry, exactly like a position tool
- price tags at the right edge show Entry, Stop Loss, Take Profit and live Profit/Loss %
- every closed trade is marked with a tick (win), circle (break-even) or cross (loss)

4. TWO TRADE MODES - "TP/SL Mode" (fixed targets, split TP1 + runner) or "Trailing Mode" (no fixed target, the trail line is the moving stop).

THE COCKPIT PANEL

- MARKET OVERVIEW: multi-timeframe trend dashboard - live trend strength meters for the chart timeframe, 15m, 1H, 4H and 1D
- SIGNAL SETUP: entry system, MTF agreement, current signal (Long / Flat / Short), Buy/Sell strength thresholds, trend filter state, trade mode, active Take Profit and Stop Loss levels
- PERFORMANCE: asset, exchange, timeframe, total trades and live win rate calculated from every signal on the chart history - no cherry picking, the counter runs over everything the engine fired

Win rate accounting is transparent: a trade counts as WIN when TP1 is banked, as LOSS when the initial stop is hit first, and break-even exits are tracked separately - the same split-target accounting professional scalpers use.

WHY-EXPLANATIONS ON THE CHART

Every BUY/SELL pill carries a tooltip that explains WHY the signal fired: which range level broke, the trend strength at the trigger, entry, stop and target prices. Range dots explain the level they mark. Nothing is a black box.

WEBHOOK AUTOMATION

Create one alert with condition "Any alert() function call" and paste your webhook URL. The indicator sends ready-to-use JSON for every event: BUY, SELL, TP_HIT, SL_HIT, TRAIL_EXIT, BE_EXIT - including symbol, price, stop, target, trade mode, win rate and timeframe. Connect it to any bridge or bot and the strategy runs hands-free.

WORKS ON

Any symbol and timeframe: indices (NASDAQ, S&P, DAX), gold and forex, crypto, stocks. Scalping on 1-5 minute charts, day trading on 15m-1H, swing trading on 4H-Daily. Defaults are tuned for intraday breakout scalping.

DISCLAIMER

This indicator is a technical analysis tool, not financial advice. Past win rates do not guarantee future results. Always test on a demo account first and manage your risk.


WHY THESE PARTS BELONG TOGETHER

An opening range on its own produces a break in both directions on most days. The session filter
and the range-quality measurement exist to decide which of those breaks is tradeable: the session
defines when the range is allowed to form, and the quality measurement rejects ranges that are too
wide or too thin to hold. The breakout level is only meaningful once both have passed.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//   RANGE BREAKOUT PRO  v1.0
//  1:1 rebuild of the "AlgoPro Signals" range-breakout engine (frame-by-frame
//  video analysis, NQ1! 3-min) as a TradingView indicator in a dark cockpit design.
//
//  Engine (exactly as seen in the source video):
//   • Range detection      = confirmed swing pivots mark range high / range low
//                            (white dot + vertical marker line at each extreme)
//   • Entry System         = RANGE BREAKOUT: candle CLOSES beyond the range
//                            extreme in the direction of the trend filter
//   • Trend Filter         = gradient trend ribbon (Bullish / Bearish) + trend
//                            strength scoring 0-100% per timeframe
//   • Market Overview      = multi-timeframe trend meter (Chart / 15m / 1H / 4H / 1D)
//   • Trade Mode           = TP/SL Mode (fixed R-multiple target) or Trailing Mode
//   • Live trade visuals   = TP box (green) + SL box (red) from entry, price tags
//                            Entry / Stop Loss / Take Profit / Profit-Loss %,
//                            signal dot on the trail line, tick / cross on exit
//   • Performance          = live trade counter + win rate, like the video panel
// ═══════════════════════════════════════════════════════════════════════════════

//  v2 - House Rules compliance: no logo, no brand or company names, no external links.

//  v3 - Fix: the theme margin box no longer stretches the price scale.
indicator("Opening Range Breakout Engine", "RANGE BREAKOUT", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────── PALETTE ───────────────────────────────────
color COL_BG     = color.rgb(6, 17, 30)      // navy outer
color COL_PANEL  = color.rgb(10, 29, 46)     // panel glass
color COL_PANEL2 = color.rgb(15, 44, 66)     // panel section
color COL_BULL   = color.rgb(126, 224, 208)  // mint
color COL_BULL2  = color.rgb(186, 240, 228)  // soft mint
color COL_BEAR   = color.rgb(244, 44, 58)    // red
color COL_BEAR2  = color.rgb(255, 148, 158)  // soft red / pink candle
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
color COL_TPBG   = color.rgb(16, 94, 70)     // take-profit tag
color COL_SLBG   = color.rgb(94, 18, 26)     // stop-loss tag
color COL_ENBG   = color.rgb(70, 76, 86)     // entry tag (grey)
color COL_TXT    = color.rgb(235, 235, 235)
color COL_GREY   = color.rgb(176, 182, 192)

// ─────────────────────────────── INPUTS ───────────────────────────────────────
grpT = "① Trend Engine (ribbon + strength score)"
ribLen      = input.int(20, "Trend ribbon length (EMA)", minval = 5, maxval = 100, group = grpT, tooltip = "The gradient ribbon = EMA of highs and EMA of lows. Green glow below price = bullish, red glow above price = bearish — exactly like the source system.")
slowLen     = input.int(50, "Trend baseline length (EMA)", minval = 10, maxval = 300, group = grpT, tooltip = "Fast/baseline EMA distance (normalized by ATR) + RSI momentum are blended into one 0-100% trend strength score. >50% = bullish, <50% = bearish.")
showRibbon  = input.bool(true, "Show gradient trend ribbon", group = grpT)
showTrail   = input.bool(true, "Show trail line (signal line)", group = grpT, tooltip = "The thin line that runs below price in an uptrend and above price in a downtrend. Signal dots are printed on it, and Trailing Mode uses it as the moving stop.")
gradCandles = input.bool(true, "Trend-strength gradient candles", group = grpT, tooltip = "Candles are painted by trend strength: strong mint / soft mint / neutral white / soft red / strong red — the exact 5-tone gradient of the source system.")

grpR = "② Range Breakout Engine (Entry System)"
pivLen      = input.int(5, "Pivot length (range extremes)", minval = 2, maxval = 20, group = grpR, tooltip = "A swing high/low is confirmed after this many bars on both sides. Confirmed extremes become the RANGE HIGH / RANGE LOW that must be broken. Marked with a dot + vertical line, as in the video.")
buyThresh   = input.float(55, "Buy Strength (min %)", minval = 0, maxval = 100, step = 5, group = grpR, tooltip = "Minimum bullish trend strength required for a LONG breakout. Higher = fewer but cleaner signals.")
sellThresh  = input.float(55, "Sell Strength (min %)", minval = 0, maxval = 100, step = 5, group = grpR, tooltip = "Minimum bearish trend strength required for a SHORT breakout. Higher = fewer but cleaner signals.")
mtfAgree    = input.bool(false, "MTF Agreement (15m must confirm)", group = grpR, tooltip = "ON: a breakout is only taken when the 15-minute trend points in the same direction. The video runs it OFF on the 3-min chart.")
breakBuf    = input.float(0.1, "Breakout buffer (ATR)", minval = 0.0, step = 0.05, group = grpR, tooltip = "The close must clear the range extreme by this ATR fraction. Filters out fake breaks that poke the level by a tick.")
rangeMinAtr = input.float(1.0, "Min range height (ATR)", minval = 0.0, step = 0.25, group = grpR, tooltip = "Range high minus range low must span at least this many ATR. Skips micro-ranges = pure noise breakouts.")
rangeMaxAge = input.int(80, "Max range age (bars)", minval = 10, maxval = 500, group = grpR, tooltip = "A range extreme older than this is stale and no longer tradeable.")
stretchMax  = input.float(1.2, "Max overextension (ATR)", minval = 0.2, step = 0.1, group = grpR, tooltip = "The breakout close may sit at most this many ATR beyond the trend ribbon. Blocks chasing an exhausted move — the #1 breakout killer.")
coolBars    = input.int(10, "Cooldown after a loss (bars)", minval = 0, maxval = 100, group = grpR, tooltip = "After a stopped-out trade the same direction is locked for this many bars. Stops revenge-entries into the same chop.")
showRange   = input.bool(true, "Mark range extremes (dot + line)", group = grpR)
showBreak   = input.bool(true, "Draw breakout level line", group = grpR)

grpM = "③ Trade Management"
tradeModeIn = input.string("TP/SL Mode", "Trade Mode", options = ["TP/SL Mode", "Trailing Mode"], group = grpM, tooltip = "TP/SL Mode = fixed take-profit at an R-multiple of the risk (as shown in the video panel). Trailing Mode = no fixed TP, the trail line becomes a moving stop.")
slModeIn    = input.string("ATR", "Stop-loss anchor", options = ["ATR", "Swing"], group = grpM, tooltip = "ATR = entry -/+ ATR x multiplier. Swing = behind the opposite range extreme (with a small ATR buffer).")
slAtrMult   = input.float(2.0, "SL ATR multiplier", minval = 0.3, step = 0.1, group = grpM)
rrMult      = input.float(1.25, "Take Profit (R multiple)", minval = 0.5, step = 0.25, group = grpM, tooltip = "TP distance = risk x this value. 1.25 = you win 1.25x what you risk.")
tp1Enable   = input.bool(true, "Partial TP1 (banks the win)", group = grpM, tooltip = "First target at a fraction of the risk. When TP1 is tagged the trade is booked as a WIN, the stop jumps to break-even and the rest runs to the full TP / trail. Split-target management — the way professional scalpers actually bank a high hit rate.")
tp1RR       = input.float(0.5, "TP1 distance (R)", minval = 0.1, step = 0.05, group = grpM, tooltip = "TP1 = entry + risk x this value (mirrored for shorts).")
beEnable    = input.bool(true, "Move stop to break-even", group = grpM, tooltip = "Once price runs the break-even trigger distance in your favor, the stop jumps to entry. Turns many would-be losers into scratch trades — the classic professional risk cut.")
beRR        = input.float(0.4, "Break-even trigger (R)", minval = 0.1, step = 0.05, group = grpM, tooltip = "BE is armed after price moves this many R in profit.")
trailAfterBE = input.bool(true, "Trail stop after break-even", group = grpM, tooltip = "After BE the stop follows price at the trail distance and locks in profit as the move extends — exactly the behaviour visible in the source video, where the stop sits ABOVE the long entry while the trade runs.")
trailAtr    = input.float(1.0, "Trail distance (ATR)", minval = 0.3, step = 0.1, group = grpM, tooltip = "Chandelier-style trail: the stop follows the highest high (long) / lowest low (short) at this ATR distance.")
showTrade   = input.bool(true, "Draw TP/SL trade boxes + price tags", group = grpM, tooltip = "Green TP box + red SL box from the entry bar, plus live price tags Entry / Stop Loss / Take Profit / Profit-Loss % at the right edge — the full video look.")
keepHist    = input.bool(true, "Keep closed trade boxes on chart", group = grpM)

grpD = "④ Design"
useTheme    = input.bool(true, "Dark chart theme (navy + gradient candles)", group = grpD)
showPanel   = input.bool(true, "Show Cockpit panel", group = grpD)
panelPos    = input.string("Middle Left", "Panel position", options = ["Middle Left", "Top Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group = grpD)

grpA = "⑤ Alerts & Webhook (Automation)"
alSignals   = input.bool(true, "Alert on BUY/SELL (webhook JSON)", group = grpA, tooltip = "Create ONE alert with condition 'Any alert() function call' and paste your webhook URL. Every signal fires ready-to-use JSON for bots, bridges and auto-traders.")
alManage    = input.bool(true, "Alert on TP / SL / Trail exit", group = grpA)
whId        = input.string("RANGE-BREAKOUT-PRO", "Webhook strategy ID", group = grpA)

// ─────────────────────────────── BASICS / THEME ───────────────────────────────
float atr14 = ta.atr(14)
bool proc = barstate.isconfirmed

bgcolor(useTheme ? color.new(COL_BG, 0) : na)

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

// ─────────────────────────────── TREND ENGINE ─────────────────────────────────
f_score() =>
    float emaF = ta.ema(close, 20)
    float emaS = ta.ema(close, 50)
    float a    = ta.atr(14)
    float r    = ta.rsi(close, 14)
    float d    = a > 0 ? math.max(-2.0, math.min(2.0, (emaF - emaS) / a)) : 0.0
    float s    = 50 + d * 15 + (r - 50) * 0.4
    math.max(0.0, math.min(100.0, s))

float sc   = f_score()
float s15  = request.security(syminfo.tickerid, "15",  f_score())
float s60  = request.security(syminfo.tickerid, "60",  f_score())
float s240 = request.security(syminfo.tickerid, "240", f_score())
float sD   = request.security(syminfo.tickerid, "D",   f_score())

bool  bullTrend = sc >= 50
float buyStr    = sc          // live bullish strength 0-100
float sellStr   = 100 - sc    // live bearish strength 0-100

// gradient ribbon (EMA of highs / EMA of lows + ATR glow)
float emaHi = ta.ema(high, ribLen)
float emaLo = ta.ema(low, ribLen)
float glowA = atr14 * 0.7
float glowB = atr14 * 1.4
float trail = bullTrend ? emaLo - atr14 * 1.6 : emaHi + atr14 * 1.6

pRibHi  = plot(showRibbon ? emaHi : na, "Ribbon high", color = color.new(COL_TXT, 100), display = display.pane)
pRibLo  = plot(showRibbon ? emaLo : na, "Ribbon low",  color = color.new(COL_TXT, 100), display = display.pane)
pGlowB1 = plot(showRibbon ? emaLo - glowA : na, "Glow bull 1", color = color.new(COL_TXT, 100), display = display.pane)
pGlowB2 = plot(showRibbon ? emaLo - glowB : na, "Glow bull 2", color = color.new(COL_TXT, 100), display = display.pane)
pGlowS1 = plot(showRibbon ? emaHi + glowA : na, "Glow bear 1", color = color.new(COL_TXT, 100), display = display.pane)
pGlowS2 = plot(showRibbon ? emaHi + glowB : na, "Glow bear 2", color = color.new(COL_TXT, 100), display = display.pane)

fill(pRibHi, pRibLo, color = color.new(COL_TXT, 76), title = "Ribbon core")
fill(pRibLo, pGlowB1, color = bullTrend ? color.new(COL_BULL, 78) : color.new(COL_BULL, 100), title = "Bull glow inner")
fill(pGlowB1, pGlowB2, color = bullTrend ? color.new(COL_BULL, 90) : color.new(COL_BULL, 100), title = "Bull glow outer")
fill(pRibHi, pGlowS1, color = bullTrend ? color.new(COL_BEAR, 100) : color.new(COL_BEAR, 78), title = "Bear glow inner")
fill(pGlowS1, pGlowS2, color = bullTrend ? color.new(COL_BEAR, 100) : color.new(COL_BEAR, 90), title = "Bear glow outer")

plot(showTrail ? trail : na, "Trail line", color = bullTrend ? color.new(COL_BULL, 25) : color.new(COL_BEAR, 25), linewidth = 1, display = display.pane)

// 5-tone gradient candles (strong mint / soft mint / white / soft red / strong red)
color candCol = sc >= 65 ? COL_BULL : sc >= 55 ? COL_BULL2 : sc > 45 ? COL_TXT : sc > 35 ? COL_BEAR2 : COL_BEAR
barcolor(useTheme and gradCandles ? candCol : useTheme ? (close >= open ? COL_BULL : COL_BEAR) : na)

// ─────────────────────────── RANGE ENGINE (pivots) ────────────────────────────
float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)

var float rangeHi    = na
var int   rangeHiBar = na
var bool  usedHi     = true
var float rangeLo    = na
var int   rangeLoBar = na
var bool  usedLo     = true

if not na(ph)
    rangeHi := ph
    rangeHiBar := bar_index - pivLen
    usedHi := false
    if showRange
        label.new(rangeHiBar, ph, "", style = label.style_circle, color = color.new(COL_TXT, 20), size = size.tiny, tooltip = "RANGE HIGH " + str.tostring(ph, format.mintick) + "\nConfirmed swing extreme (pivot " + str.tostring(pivLen) + "/" + str.tostring(pivLen) + ").\nA candle CLOSE above this level + bullish trend filter = LONG breakout signal.")
        line.new(rangeHiBar, ph, rangeHiBar, ph + atr14 * 2.5, color = color.new(COL_GREY, 55), style = line.style_dotted, width = 1)
if not na(pl)
    rangeLo := pl
    rangeLoBar := bar_index - pivLen
    usedLo := false
    if showRange
        label.new(rangeLoBar, pl, "", style = label.style_circle, color = color.new(COL_TXT, 20), size = size.tiny, tooltip = "RANGE LOW " + str.tostring(pl, format.mintick) + "\nConfirmed swing extreme (pivot " + str.tostring(pivLen) + "/" + str.tostring(pivLen) + ").\nA candle CLOSE below this level + bearish trend filter = SHORT breakout signal.")
        line.new(rangeLoBar, pl, rangeLoBar, pl - atr14 * 2.5, color = color.new(COL_GREY, 55), style = line.style_dotted, width = 1)

// ─────────────────────────── TRADE STATE ──────────────────────────────────────
var int    tradeDir  = 0
var float  tEntry    = na
var float  tSL       = na
var float  tTP       = na
var float  tRisk     = na
var bool   beDone    = false
var bool   tp1Hit    = false
var int    tBar      = na
var int    wins      = 0
var int    losses    = 0
var int    beCount   = 0
var int    lastLossBar = -99999
var int    lastLossDir = 0
var string sigTxt    = "FLAT"
var box    tpBox     = na
var box    slBox     = na
var array<box> histBoxes = array.new<box>()

bool buySignal  = false
bool sellSignal = false
bool tpEvent    = false
bool slEvent    = false
bool trailExit  = false
bool beExit     = false

f_keepHist(box b) =>
    if not na(b)
        if keepHist
            array.push(histBoxes, b)
            while array.size(histBoxes) > 120
                box.delete(array.shift(histBoxes))
        else
            box.delete(b)

bool mtfOkLong  = not mtfAgree or s15 >= 50
bool mtfOkShort = not mtfAgree or s15 < 50
bool tpslMode   = tradeModeIn == "TP/SL Mode"

if proc
    // ── manage open trade first ──
    if tradeDir == 1
        if tradeModeIn == "Trailing Mode" or (trailAfterBE and beDone)
            tSL := math.max(tSL, high - atr14 * trailAtr)
        if beEnable and not beDone and high >= tEntry + tRisk * beRR
            beDone := true
            tSL := math.max(tSL, tEntry)
        if tp1Enable and not tp1Hit and high >= tEntry + tRisk * tp1RR
            tp1Hit := true
            wins += 1
            beDone := true
            tSL := math.max(tSL, tEntry)
            tpEvent := true
            label.new(bar_index, tEntry + tRisk * tp1RR, "✓", style = label.style_none, textcolor = COL_BULL, size = size.small, tooltip = "TP1 banked at " + str.tostring(tEntry + tRisk * tp1RR, format.mintick) + " — win booked, stop to break-even, rest runs")
        if low <= tSL
            float pf = tSL - tEntry
            bool w = pf > syminfo.mintick * 2
            bool be = not w and beDone
            slEvent := not w and not be and not tp1Hit
            trailExit := w
            beExit := be and not tp1Hit
            if not tp1Hit
                if w
                    wins += 1
                else if be
                    beCount += 1
                else
                    losses += 1
                    lastLossBar := bar_index
                    lastLossDir := 1
            else if not w
                sigTxt := "TP1 WIN ✔"
            if not tp1Hit or w
                sigTxt := w ? "TRAIL WIN ✔" : be ? "BE EXIT ◦" : "SL HIT ✖"
            label.new(bar_index, tSL, w ? "✓" : be or tp1Hit ? "◦" : "✗", style = label.style_none, textcolor = w ? COL_BULL : be or tp1Hit ? COL_CYAN : COL_BEAR, size = size.normal, tooltip = "LONG closed at stop " + str.tostring(tSL, format.mintick) + (be or tp1Hit ? " (break-even, risk removed)" : ""))
            f_keepHist(tpBox)
            f_keepHist(slBox)
            tpBox := na
            slBox := na
            tradeDir := 0
        else if tpslMode and high >= tTP
            tpEvent := true
            if not tp1Hit
                wins += 1
            sigTxt := "TP HIT ✔"
            label.new(bar_index, tTP, "✓", style = label.style_none, textcolor = COL_BULL, size = size.normal, tooltip = "LONG take profit hit " + str.tostring(tTP, format.mintick))
            f_keepHist(tpBox)
            f_keepHist(slBox)
            tpBox := na
            slBox := na
            tradeDir := 0
    else if tradeDir == -1
        if tradeModeIn == "Trailing Mode" or (trailAfterBE and beDone)
            tSL := math.min(tSL, low + atr14 * trailAtr)
        if beEnable and not beDone and low <= tEntry - tRisk * beRR
            beDone := true
            tSL := math.min(tSL, tEntry)
        if tp1Enable and not tp1Hit and low <= tEntry - tRisk * tp1RR
            tp1Hit := true
            wins += 1
            beDone := true
            tSL := math.min(tSL, tEntry)
            tpEvent := true
            label.new(bar_index, tEntry - tRisk * tp1RR, "✓", style = label.style_none, textcolor = COL_BULL, size = size.small, tooltip = "TP1 banked at " + str.tostring(tEntry - tRisk * tp1RR, format.mintick) + " — win booked, stop to break-even, rest runs")
        if high >= tSL
            float pf2 = tEntry - tSL
            bool w2 = pf2 > syminfo.mintick * 2
            bool be2 = not w2 and beDone
            slEvent := not w2 and not be2 and not tp1Hit
            trailExit := w2
            beExit := be2 and not tp1Hit
            if not tp1Hit
                if w2
                    wins += 1
                else if be2
                    beCount += 1
                else
                    losses += 1
                    lastLossBar := bar_index
                    lastLossDir := -1
            else if not w2
                sigTxt := "TP1 WIN ✔"
            if not tp1Hit or w2
                sigTxt := w2 ? "TRAIL WIN ✔" : be2 ? "BE EXIT ◦" : "SL HIT ✖"
            label.new(bar_index, tSL, w2 ? "✓" : be2 or tp1Hit ? "◦" : "✗", style = label.style_none, textcolor = w2 ? COL_BULL : be2 or tp1Hit ? COL_CYAN : COL_BEAR, size = size.normal, tooltip = "SHORT closed at stop " + str.tostring(tSL, format.mintick) + (be2 or tp1Hit ? " (break-even, risk removed)" : ""))
            f_keepHist(tpBox)
            f_keepHist(slBox)
            tpBox := na
            slBox := na
            tradeDir := 0
        else if tpslMode and low <= tTP
            tpEvent := true
            if not tp1Hit
                wins += 1
            sigTxt := "TP HIT ✔"
            label.new(bar_index, tTP, "✓", style = label.style_none, textcolor = COL_BULL, size = size.normal, tooltip = "SHORT take profit hit " + str.tostring(tTP, format.mintick))
            f_keepHist(tpBox)
            f_keepHist(slBox)
            tpBox := na
            slBox := na
            tradeDir := 0

    // ── entry quality gates ──
    bool rangeOKHi = not na(rangeHi) and not na(rangeLo) and (rangeHi - rangeLo) >= atr14 * rangeMinAtr and bar_index - rangeHiBar <= rangeMaxAge
    bool rangeOKLo = not na(rangeHi) and not na(rangeLo) and (rangeHi - rangeLo) >= atr14 * rangeMinAtr and bar_index - rangeLoBar <= rangeMaxAge
    bool notStretchedUp = close <= emaHi + atr14 * stretchMax
    bool notStretchedDn = close >= emaLo - atr14 * stretchMax
    bool coolOKLong  = coolBars == 0 or lastLossDir != 1 or bar_index - lastLossBar >= coolBars
    bool coolOKShort = coolBars == 0 or lastLossDir != -1 or bar_index - lastLossBar >= coolBars
    // ── LONG breakout: close above range high + bullish filter ──
    if tradeDir == 0 and not usedHi and rangeOKHi and close > rangeHi + atr14 * breakBuf and bullTrend and buyStr >= buyThresh and mtfOkLong and notStretchedUp and coolOKLong
        usedHi := true
        buySignal := true
        tradeDir := 1
        tEntry := close
        float risk = slModeIn == "Swing" and not na(rangeLo) and (tEntry - rangeLo) < atr14 * 4 ? (tEntry - rangeLo) + atr14 * 0.2 : atr14 * slAtrMult
        tSL := tEntry - risk
        tTP := tEntry + risk * rrMult
        tRisk := risk
        beDone := false
        tp1Hit := false
        tBar := bar_index
        sigTxt := "LONG " + str.tostring(tEntry, format.mintick)
        if showBreak
            line.new(rangeHiBar, rangeHi, bar_index, rangeHi, color = color.new(COL_GREY, 35), width = 1)
        if showTrade
            tpBox := box.new(bar_index, tpslMode ? tTP : tEntry + risk, bar_index + 1, tEntry, border_color = color.new(COL_BULL, 65), border_width = 1, bgcolor = color.new(COL_BULL, 86))
            slBox := box.new(bar_index, tEntry, bar_index + 1, tSL, border_color = color.new(COL_BEAR, 65), border_width = 1, bgcolor = color.new(COL_BEAR, 86))
        label.new(bar_index, low, "  BUY ▲  \n" + str.tostring(rrMult, "#.#") + "R · RANGE BREAK + TREND", style = label.style_label_up, color = COL_BUYBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS BUY?\n1) Candle CLOSED above range high " + str.tostring(rangeHi, format.mintick) + "\n2) Trend filter bullish (strength " + str.tostring(buyStr, "#") + "% ≥ " + str.tostring(buyThresh, "#") + "%)\n" + (mtfAgree ? "3) 15m trend agrees\n" : "") + "Entry " + str.tostring(tEntry, format.mintick) + "\nSL " + str.tostring(tSL, format.mintick) + " (" + slModeIn + ")\nTP " + str.tostring(tTP, format.mintick) + " (" + str.tostring(rrMult, "#.#") + "R)")

    // ── SHORT breakout: close below range low + bearish filter ──
    else if tradeDir == 0 and not usedLo and rangeOKLo and close < rangeLo - atr14 * breakBuf and not bullTrend and sellStr >= sellThresh and mtfOkShort and notStretchedDn and coolOKShort
        usedLo := true
        sellSignal := true
        tradeDir := -1
        tEntry := close
        float risk2 = slModeIn == "Swing" and not na(rangeHi) and (rangeHi - tEntry) < atr14 * 4 ? (rangeHi - tEntry) + atr14 * 0.2 : atr14 * slAtrMult
        tSL := tEntry + risk2
        tTP := tEntry - risk2 * rrMult
        tRisk := risk2
        beDone := false
        tp1Hit := false
        tBar := bar_index
        sigTxt := "SHORT " + str.tostring(tEntry, format.mintick)
        if showBreak
            line.new(rangeLoBar, rangeLo, bar_index, rangeLo, color = color.new(COL_GREY, 35), width = 1)
        if showTrade
            tpBox := box.new(bar_index, tEntry, bar_index + 1, tpslMode ? tTP : tEntry - risk2, border_color = color.new(COL_BULL, 65), border_width = 1, bgcolor = color.new(COL_BULL, 86))
            slBox := box.new(bar_index, tSL, bar_index + 1, tEntry, border_color = color.new(COL_BEAR, 65), border_width = 1, bgcolor = color.new(COL_BEAR, 86))
        label.new(bar_index, high, "  SELL ▼  \n" + str.tostring(rrMult, "#.#") + "R · RANGE BREAK + TREND", style = label.style_label_down, color = COL_SELLBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS SELL?\n1) Candle CLOSED below range low " + str.tostring(rangeLo, format.mintick) + "\n2) Trend filter bearish (strength " + str.tostring(sellStr, "#") + "% ≥ " + str.tostring(sellThresh, "#") + "%)\n" + (mtfAgree ? "3) 15m trend agrees\n" : "") + "Entry " + str.tostring(tEntry, format.mintick) + "\nSL " + str.tostring(tSL, format.mintick) + " (" + slModeIn + ")\nTP " + str.tostring(tTP, format.mintick) + " (" + str.tostring(rrMult, "#.#") + "R)")

    // extend live trade boxes
    if tradeDir != 0 and showTrade
        if not na(tpBox)
            box.set_right(tpBox, bar_index)
        if not na(slBox)
            box.set_right(slBox, bar_index)
            box.set_top(slBox, tradeDir == 1 ? tEntry : tSL)
            box.set_bottom(slBox, tradeDir == 1 ? tSL : tEntry)

// signal dot on the trail line (like the video) + MT5-style arrows
plotshape(buySignal ? trail : na, "BUY dot", shape.circle, location.absolute, color.new(COL_BULL, 0), size = size.tiny, display = display.pane)
plotshape(sellSignal ? trail : na, "SELL dot", shape.circle, location.absolute, color.new(COL_BEAR, 0), size = size.tiny, display = display.pane)
plotshape(buySignal, "BUY arrow", shape.triangleup, location.belowbar, COL_BULL, size = size.tiny, display = display.pane)
plotshape(sellSignal, "SELL arrow", shape.triangledown, location.abovebar, COL_BEAR, size = size.tiny, display = display.pane)

// ───────────── RIGHT-EDGE PRICE TAGS (Entry / SL / TP / P&L, video look) ───────
var label labTP = na
var label labSL = na
var label labEN = na
var label labPL = na
if barstate.islast and showTrade and not na(tEntry)
    float plPct = tradeDir == 1 ? (close - tEntry) / tEntry * 100 : tradeDir == -1 ? (tEntry - close) / tEntry * 100 : na
    int lx = bar_index + 8
    if na(labEN)
        labEN := label.new(lx, tEntry, "", style = label.style_label_left, size = size.small)
        labSL := label.new(lx, tSL, "", style = label.style_label_left, size = size.small)
        labTP := label.new(lx, tTP, "", style = label.style_label_left, size = size.small)
        labPL := label.new(lx, close, "", style = label.style_label_left, size = size.small)
    label.set_xy(labEN, lx, tEntry)
    label.set_text(labEN, "Entry : " + str.tostring(tEntry, format.mintick))
    label.set_color(labEN, color.new(COL_ENBG, 15))
    label.set_textcolor(labEN, COL_TXT)
    label.set_xy(labSL, lx, tSL)
    label.set_text(labSL, "Stop Loss : " + str.tostring(tSL, format.mintick))
    label.set_color(labSL, color.new(COL_SLBG, 10))
    label.set_textcolor(labSL, color.rgb(255, 130, 140))
    bool showTPtag = tpslMode or tradeDir == 0
    label.set_xy(labTP, lx, tTP)
    label.set_text(labTP, showTPtag ? "Take Profit : " + str.tostring(tTP, format.mintick) : "Trailing Mode")
    label.set_color(labTP, color.new(COL_TPBG, 10))
    label.set_textcolor(labTP, COL_BULL)
    if tradeDir != 0
        label.set_xy(labPL, lx, close)
        label.set_text(labPL, "Profit / Loss : " + str.tostring(plPct, "#.##") + "%")
        label.set_color(labPL, plPct >= 0 ? color.new(COL_TPBG, 10) : color.new(COL_SLBG, 10))
        label.set_textcolor(labPL, plPct >= 0 ? COL_BULL : color.rgb(255, 130, 140))
    else
        label.set_text(labPL, sigTxt)
        label.set_xy(labPL, lx, close)
        label.set_color(labPL, color.new(COL_ENBG, 25))
        label.set_textcolor(labPL, COL_GREY)

// ─────────────────────────── ALERTS / WEBHOOK ─────────────────────────────────
int   trades  = wins + losses + beCount
float winRate = wins + losses > 0 ? wins / (wins + losses) * 100 : 0

f_json(string action, float px, float sl, float tp) =>
    '{"id":"' + whId + '","symbol":"' + syminfo.ticker + '","action":"' + action + '","price":' + str.tostring(px, format.mintick) + ',"sl":' + str.tostring(na(sl) ? px : sl, format.mintick) + ',"tp":' + str.tostring(na(tp) ? px : tp, format.mintick) + ',"mode":"' + tradeModeIn + '","winrate":"' + str.tostring(winRate, "#.#") + '","tf":"' + timeframe.period + '","time":"' + str.format_time(time, "yyyy-MM-dd HH:mm", "GMT") + '"}'

if alSignals and buySignal
    alert(f_json("BUY", tEntry, tSL, tTP), alert.freq_once_per_bar_close)
if alSignals and sellSignal
    alert(f_json("SELL", tEntry, tSL, tTP), alert.freq_once_per_bar_close)
if alManage and tpEvent
    alert(f_json("TP_HIT", tTP, na, na), alert.freq_once_per_bar_close)
if alManage and slEvent
    alert(f_json("SL_HIT", tSL, na, na), alert.freq_once_per_bar_close)
if alManage and trailExit
    alert(f_json("TRAIL_EXIT", tSL, na, na), alert.freq_once_per_bar_close)
if alManage and beExit
    alert(f_json("BE_EXIT", tSL, na, na), alert.freq_once_per_bar_close)

alertcondition(buySignal, "BUY Signal", "Range Breakout Pro: BUY {{ticker}} @ {{close}}")
alertcondition(sellSignal, "SELL Signal", "Range Breakout Pro: SELL {{ticker}} @ {{close}}")
alertcondition(tpEvent or slEvent or trailExit, "Exit", "Range Breakout Pro: trade closed {{ticker}} {{interval}}")

// ───────────── COCKPIT PANEL (Market Overview / Signal Setup / Performance) ─
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



f_meter(float p) =>
    int n = int(math.round(math.max(0.0, math.min(100.0, p)) / 10))
    str.repeat("▰", n) + str.repeat("▱", 10 - n)

f_spacer(table t, int r) =>
    table.cell(t, 0, r, "", bgcolor = color.new(COL_BG, 0), text_size = size.tiny)

f_header(table t, int r, string leftTxt, string rightTxt) =>
    table.cell(t, 0, r, leftTxt, text_color = COL_CYAN, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(t, 5, r, rightTxt, text_color = COL_GOLD, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_right, text_font_family = font.family_monospace)

f_tfRow(table t, int r, string name, float p, bool isChart) =>
    color mCol = p >= 50 ? COL_BULL : COL_BEAR
    table.cell(t, 0, r, name, text_color = isChart ? COL_GOLD : COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 3, r, f_meter(p >= 50 ? p : 100 - p), text_color = mCol, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(t, 7, r, str.tostring(math.round(p >= 50 ? p : 100 - p)) + "%", text_color = mCol, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)

f_kv(table t, int r, string k, string v, color vCol, color vBg) =>
    table.cell(t, 0, r, k, text_color = COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 4, r, v, text_color = vCol, text_size = size.tiny, bgcolor = color.new(vBg, 0), text_halign = text.align_center, text_font_family = font.family_monospace)

var table pan = na
if showPanel and barstate.islast
    if na(pan)
        pan := table.new(f_pos(), 8, 37, bgcolor = color.new(COL_PANEL, 0), frame_color = COL_CYAN, frame_width = 2, border_color = color.new(COL_CYAN, 88), border_width = 1)
        for r = 0 to 36
            for c = 0 to 7
                table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
        table.merge_cells(pan, 0, 5, 6, 5)
        table.cell(pan, 0, 6, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 6, 7, 6)
        table.merge_cells(pan, 0, 8, 7, 8)
        table.merge_cells(pan, 0, 9, 4, 9)
        table.merge_cells(pan, 5, 9, 7, 9)
        for r = 10 to 14
            table.merge_cells(pan, 0, r, 2, r)
            table.merge_cells(pan, 3, r, 6, r)
        table.merge_cells(pan, 0, 15, 7, 15)
        table.merge_cells(pan, 0, 16, 4, 16)
        table.merge_cells(pan, 5, 16, 7, 16)
        for r = 17 to 25
            table.merge_cells(pan, 0, r, 3, r)
            table.merge_cells(pan, 4, r, 7, r)
        table.merge_cells(pan, 0, 26, 7, 26)
        table.merge_cells(pan, 0, 27, 4, 27)
        table.merge_cells(pan, 5, 27, 7, 27)
        for r = 28 to 32
            table.merge_cells(pan, 0, r, 3, r)
            table.merge_cells(pan, 4, r, 7, r)
        table.cell(pan, 0, 33, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 33, 7, 33)
        table.cell(pan, 0, 34, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 34, 7, 34)
        table.cell(pan, 0, 35, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 35, 7, 35)
        table.merge_cells(pan, 0, 36, 7, 36)
    int gcol = glint % 8
    for r = 0 to 4
        for c = 0 to 7
            table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
    // ── header ──
    table.cell(pan, 0, 5, "RANGE BREAKOUT", text_color = COL_GOLD, text_size = size.normal, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(pan, 7, 5, glint % 2 == 0 ? "●" : "○", text_color = COL_CYAN, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    for c = 0 to 7
        table.cell(pan, c, 7, "▲", text_color = c == gcol ? COL_GOLD : color.new(COL_BULL, 35), text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    f_spacer(pan, 8)
    // ── MARKET OVERVIEW · TREND ──
    f_header(pan, 9, "MARKET OVERVIEW", "TREND")
    f_tfRow(pan, 10, "CHART " + timeframe.period, sc, true)
    f_tfRow(pan, 11, "15M", s15, false)
    f_tfRow(pan, 12, "1H", s60, false)
    f_tfRow(pan, 13, "4H", s240, false)
    f_tfRow(pan, 14, "1D", sD, false)
    f_spacer(pan, 15)
    // ── SIGNAL SETUP ──
    f_header(pan, 16, "SIGNAL SETUP", "")
    f_kv(pan, 17, "Entry System", "Range Breakout", COL_TXT, COL_PANEL)
    f_kv(pan, 18, "MTF Agreement", mtfAgree ? "On" : "Off", mtfAgree ? COL_BULL : COL_GREY, COL_PANEL)
    string sigChip = tradeDir == 1 ? "Long" : tradeDir == -1 ? "Short" : "Flat"
    f_kv(pan, 19, "Signal", sigChip, tradeDir == 0 ? COL_GREY : COL_TXT, tradeDir == 1 ? COL_TPBG : tradeDir == -1 ? COL_SLBG : COL_PANEL2)
    f_kv(pan, 20, "Buy Strength", str.tostring(buyThresh, "#") + "%", COL_TXT, COL_PANEL)
    f_kv(pan, 21, "Sell Strength", str.tostring(sellThresh, "#") + "%", COL_TXT, COL_PANEL)
    f_kv(pan, 22, "Trend Filter", bullTrend ? "Bullish" : "Bearish", COL_TXT, bullTrend ? COL_TPBG : COL_SLBG)
    f_kv(pan, 23, "Trade Mode", tpslMode ? "TP/SL Mode" : "Trailing", COL_TXT, COL_PANEL)
    f_kv(pan, 24, "Take Profit", tradeDir != 0 and tpslMode ? str.tostring(tTP, format.mintick) : "—", tradeDir != 0 and tpslMode ? COL_BULL : COL_GREY, tradeDir != 0 and tpslMode ? COL_TPBG : COL_PANEL)
    f_kv(pan, 25, "Stop Loss", tradeDir != 0 ? str.tostring(tSL, format.mintick) : "—", tradeDir != 0 ? color.rgb(255, 130, 140) : COL_GREY, tradeDir != 0 ? COL_SLBG : COL_PANEL)
    f_spacer(pan, 26)
    // ── PERFORMANCE ──
    f_header(pan, 27, "PERFORMANCE", "")
    f_kv(pan, 28, "Asset", syminfo.ticker, COL_TXT, COL_PANEL)
    f_kv(pan, 29, "Exchange", syminfo.prefix, COL_TXT, COL_PANEL)
    f_kv(pan, 30, "Timeframe", timeframe.period + (timeframe.isminutes ? "m" : ""), COL_TXT, COL_PANEL)
    f_kv(pan, 31, "Trades", str.tostring(trades), COL_TXT, COL_PANEL)
    f_kv(pan, 32, "Win Rate", str.tostring(winRate, "#.##") + "%", winRate >= 50 ? COL_TXT : color.rgb(255, 130, 140), winRate >= 50 ? COL_TPBG : COL_SLBG)
    // ── buttons (links shown in tooltip — TradingView tables are not clickable) ──
    table.cell(pan, 0, 36, (glint % 2 == 0 ? "●" : "○") + " LIVE · webhook JSON ready", text_color = color.new(COL_BULL, 25), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
````
