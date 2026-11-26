# ELITE2027

- url: https://www.tradingview.com/script/FWcYjVuW-ELITE2027/
- type: indicator
- pine_id: PUB;3684b76508e0484790bb5da6f7e4fbdb
- version: 1.0

## Description

**External Liquidity Sweep [Elite]**

External Liquidity Sweep [Elite] is a chart overlay that highlights potential reversal setups around swing highs and lows. It helps traders identify price sweeps, evaluate rejection, and filter potential BUY and SELL opportunities.

The indicator tracks confirmed swing levels and looks for price to move beyond them. With close-back confirmation enabled, price must close back inside the swept level to qualify as a potential rejection.

- **BUY setups:** Price sweeps a tracked swing low and meets the selected confirmation conditions.
- **SELL setups:** Price sweeps a tracked swing high and meets the selected confirmation conditions.

Customizable features include swing sensitivity, EMA trend filtering, rejection strength, minimum sweep depth, signal cooldown, and optional volume confirmation. Preset modes provide different levels of selectivity, while Custom mode allows manual adjustment.

For additional context, combine signals with independently identified support and resistance zones. Signals identify potential setups; they do not automatically define entries, stop-losses, or take-profit targets.

**Important:** Swing levels require confirmation before becoming available. Signals on an open candle may change before it closes. The indicator does not guarantee profitable trades or a particular win rate; test your settings and risk-management rules before live use.

## Source Code

````pine
//@version=6
indicator("External Liquidity Sweep [Elite] v2", "Ext Liq Sweep v2", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ════════════════════════════════════════════════════════════
//  EXTERNAL LIQUIDITY SWEEP  ·  Elite Edition v2
//  Detects sweeps of EXTERNAL (major / range-extreme) liquidity
//  only, then filters for quality:
//    • Swept swing HIGH -> SELL   • Swept swing LOW -> BUY
//  v2 adds accuracy filters: trend bias, rejection strength,
//  signal cooldown, no-repeat (alternate) signals, optional
//  volume confirmation. Filtered-but-swept levels are dimmed.
//  NOTE: signal markers only, not financial advice. Confirm
//  with your own bias / entry rules before acting.
// ════════════════════════════════════════════════════════════

// ─── Sensitivity ────────────────────────────────────────────
gS = "Sensitivity"
preset = input.string("Balanced", "Sensitivity Preset", options = ["Custom", "Selective", "Balanced", "Aggressive"], group = gS,
     tooltip = "One-click profiles that override the manual settings below.\nSelective = fewest, cleanest (Swing 21, strong rejection, trend ON).\nBalanced = more signals, still trend-filtered (Swing 8).\nAggressive = maximum frequency, noisier (Swing 5, trend OFF).\nChoose 'Custom' to use your own values below.")

// ─── Detection ──────────────────────────────────────────────
gD = "Detection"
extLen       = input.int(8, "External Swing Strength", minval = 3, group = gD,
     tooltip = "Used only when Preset = Custom. Bars on each side to confirm a MAJOR swing (external liquidity). Lower = more signals; higher = only major range extremes.")
requireClose = input.bool(true, "Require Close-Back Confirmation", group = gD,
     tooltip = "Candle must wick past the level but close back inside (rejection).")
maxTracked   = input.int(8, "Max External Levels Per Side", minval = 1, maxval = 30, group = gD)

// ─── Accuracy Filters ───────────────────────────────────────
gF = "Accuracy Filters"
useTrend   = input.bool(true,  "Trend Bias Filter", group = gF,
     tooltip = "Only BUY when price is above the trend EMA, only SELL when below. Takes sweeps WITH the trend (buy dips / sell rallies).")
trendLen   = input.int(50, "Trend EMA Length", minval = 2, group = gF)
trendTF    = input.timeframe("", "Trend Timeframe (blank = chart)", group = gF,
     tooltip = "Set a higher timeframe (e.g. 60, 240, D) to bias signals to the higher-TF trend.")
rejFrac    = input.float(0.4, "Min Rejection Strength", minval = 0.0, maxval = 1.0, step = 0.05, group = gF,
     tooltip = "Used only when Preset = Custom. How far back inside the candle must close, as a fraction of its range. 0.5 = close in the rejecting half. Higher = only strong rejections.")
minSweepATR= input.float(0.0, "Min Sweep Depth (ATR)", minval = 0.0, step = 0.1, group = gF,
     tooltip = "Wick must pierce the level by at least this × ATR(14). Filters tiny pokes. 0 = off.")
cooldown   = input.int(2, "Signal Cooldown (bars)", minval = 0, group = gF,
     tooltip = "Used only when Preset = Custom. Minimum bars between signals. Main anti-cluster control — raise to space signals out, lower for more.")
alternate  = input.bool(false, "No Repeat Until Opposite", group = gF,
     tooltip = "Block a second BUY (or SELL) until the opposite fires. WARNING: with Trend Bias ON this can DEADLOCK in a strong trend (one BUY, then no SELL ever unblocks it). Keep OFF unless Trend Bias is also off.")
useVol     = input.bool(false, "Volume Confirmation", group = gF,
     tooltip = "Sweep must occur on above-average volume (real liquidity grab). Leave off for instruments without reliable volume.")
volLen     = input.int(20, "Volume Avg Length", minval = 2, group = gF)
volMult    = input.float(1.2, "Volume Multiple", minval = 0.1, step = 0.1, group = gF)

// ─── Design ─────────────────────────────────────────────────
gV = "Design"
bullCol  = input.color(#0bd6a6, "Bullish / BUY", group = gV)
bearCol  = input.color(#ff3b5c, "Bearish / SELL", group = gV)
lvlCol   = input.color(color.new(#b2b5be, 35), "Pending Level", group = gV)
dimCol   = input.color(color.new(#787b86, 55), "Filtered Sweep", group = gV)
showLevels = input.bool(true, "Show Liquidity Levels", group = gV)
showSignal = input.bool(true, "Show BUY / SELL Labels", group = gV)
hlCandle   = input.bool(true, "Highlight Sweep Candle", group = gV)
showDash   = input.bool(true, "Show Dashboard", group = gV)

// ─── Resolve preset into effective settings ─────────────────
// Custom -> use manual inputs. Otherwise the preset wins.
isCustom    = preset == "Custom"
extLenEff   = isCustom ? extLen   : preset == "Selective" ? 21  : preset == "Balanced" ? 8   : 5
rejFracEff  = isCustom ? rejFrac  : preset == "Selective" ? 0.6 : preset == "Balanced" ? 0.4 : 0.3
cooldownEff = isCustom ? cooldown : preset == "Selective" ? 5   : preset == "Balanced" ? 2   : 1
useTrendEff = isCustom ? useTrend : preset != "Aggressive"

// ─── Context (computed once per bar) ────────────────────────
atr    = ta.atr(14)
tfUse  = trendTF == "" ? timeframe.period : trendTF
emaHTF = request.security(syminfo.tickerid, tfUse, ta.ema(close, trendLen), lookahead = barmerge.lookahead_off)
bullCtx = close > emaHTF
bearCtx = close < emaHTF

rng     = math.max(high - low, syminfo.mintick)
sellRej = (high - close) / rng >= rejFracEff   // wicked up, closed in lower part
buyRej  = (close - low)  / rng >= rejFracEff   // wicked down, closed in upper part
volOK   = volume > ta.sma(volume, volLen) * volMult

var int lastBar = na
barsSince = na(lastBar) ? 1000000 : bar_index - lastBar
cdOK = barsSince >= cooldownEff

// ─── State ──────────────────────────────────────────────────
var array<float> hiP = array.new<float>()
var array<line>  hiL = array.new<line>()
var array<float> loP = array.new<float>()
var array<line>  loL = array.new<line>()
var string lastTxt = "—"
var color  lastCol = color.gray

// ─── Register external (major) swings ───────────────────────
ph = ta.pivothigh(high, extLenEff, extLenEff)
pl = ta.pivotlow(low, extLenEff, extLenEff)

if not na(ph)
    array.push(hiP, ph)
    array.push(hiL, showLevels ? line.new(bar_index - extLenEff, ph, bar_index, ph, extend = extend.right, color = lvlCol, width = 1, style = line.style_dashed) : na)
    if array.size(hiP) > maxTracked
        array.shift(hiP)
        l = array.shift(hiL)
        if not na(l)
            line.delete(l)

if not na(pl)
    array.push(loP, pl)
    array.push(loL, showLevels ? line.new(bar_index - extLenEff, pl, bar_index, pl, extend = extend.right, color = lvlCol, width = 1, style = line.style_dashed) : na)
    if array.size(loP) > maxTracked
        array.shift(loP)
        l = array.shift(loL)
        if not na(l)
            line.delete(l)

// ─── Detect sweeps of external highs -> SELL ────────────────
sellSig = false
i = array.size(hiP) - 1
while i >= 0
    lvl = array.get(hiP, i)
    if high > lvl and (not requireClose or close < lvl)
        passQ = sellRej and (high - lvl >= minSweepATR * atr) and (not useTrendEff or bearCtx) and (not useVol or volOK) and cdOK and (not alternate or lastTxt != "SELL")
        l = array.get(hiL, i)
        if not na(l)
            line.set_extend(l, extend.none)
            line.set_x2(l, bar_index)
            line.set_style(l, line.style_solid)
            line.set_color(l, passQ ? bearCol : dimCol)
            line.set_width(l, passQ ? 2 : 1)
        if passQ
            sellSig := true
        array.remove(hiP, i)
        array.remove(hiL, i)
    i := i - 1

// ─── Detect sweeps of external lows -> BUY ──────────────────
buySig = false
j = array.size(loP) - 1
while j >= 0
    lvl = array.get(loP, j)
    if low < lvl and (not requireClose or close > lvl)
        passQ = buyRej and (lvl - low >= minSweepATR * atr) and (not useTrendEff or bullCtx) and (not useVol or volOK) and cdOK and (not alternate or lastTxt != "BUY")
        l = array.get(loL, j)
        if not na(l)
            line.set_extend(l, extend.none)
            line.set_x2(l, bar_index)
            line.set_style(l, line.style_solid)
            line.set_color(l, passQ ? bullCol : dimCol)
            line.set_width(l, passQ ? 2 : 1)
        if passQ
            buySig := true
        array.remove(loP, j)
        array.remove(loL, j)
    j := j - 1

// ─── Conflict guard: never BUY and SELL on the same bar ─────
if sellSig and buySig
    sellSig := false
    buySig  := false

// ─── Record last signal ─────────────────────────────────────
if sellSig
    lastTxt := "SELL"
    lastCol := bearCol
    lastBar := bar_index
if buySig
    lastTxt := "BUY"
    lastCol := bullCol
    lastBar := bar_index

// ─── Plot signals ───────────────────────────────────────────
if sellSig and showSignal
    label.new(bar_index, high, "SELL", yloc = yloc.abovebar, style = label.style_label_down, color = bearCol, textcolor = color.white, size = size.normal, tooltip = "External buy-side liquidity swept and rejected, with trend.")
if buySig and showSignal
    label.new(bar_index, low, "BUY", yloc = yloc.belowbar, style = label.style_label_up, color = bullCol, textcolor = color.white, size = size.normal, tooltip = "External sell-side liquidity swept and rejected, with trend.")

bgcolor(hlCandle and sellSig ? color.new(bearCol, 88) : hlCandle and buySig ? color.new(bullCol, 88) : na)

// ─── Dashboard ──────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 6, border_color = color.new(color.gray, 60), border_width = 1, frame_color = color.new(color.gray, 60), frame_width = 1)
if showDash and barstate.islast
    bsl = array.size(hiP) > 0 ? array.max(hiP) : na
    ssl = array.size(loP) > 0 ? array.min(loP) : na
    biasTxt = not useTrendEff ? "Off" : bullCtx ? "Bullish" : "Bearish"
    biasCol = not useTrendEff ? color.gray : bullCtx ? bullCol : bearCol
    hdr = color.new(#2a2e39, 0)
    bg  = color.new(#1b1f2a, 0)
    table.cell(dash, 0, 0, "EXTERNAL LIQUIDITY", text_color = color.white, text_size = size.small, bgcolor = hdr)
    table.cell(dash, 1, 0, "SWEEP", text_color = color.new(color.white, 30), text_size = size.small, bgcolor = hdr)
    table.cell(dash, 0, 1, "Mode", text_color = color.new(color.white, 20), text_size = size.small, bgcolor = bg)
    table.cell(dash, 1, 1, preset, text_color = color.new(color.white, 0), text_size = size.small, bgcolor = bg)
    table.cell(dash, 0, 2, "Buy-side (BSL)", text_color = color.new(color.white, 20), text_size = size.small, bgcolor = bg)
    table.cell(dash, 1, 2, na(bsl) ? "—" : str.tostring(bsl, format.mintick), text_color = bearCol, text_size = size.small, bgcolor = bg)
    table.cell(dash, 0, 3, "Sell-side (SSL)", text_color = color.new(color.white, 20), text_size = size.small, bgcolor = bg)
    table.cell(dash, 1, 3, na(ssl) ? "—" : str.tostring(ssl, format.mintick), text_color = bullCol, text_size = size.small, bgcolor = bg)
    table.cell(dash, 0, 4, "Trend bias", text_color = color.new(color.white, 20), text_size = size.small, bgcolor = bg)
    table.cell(dash, 1, 4, biasTxt, text_color = biasCol, text_size = size.small, bgcolor = bg)
    table.cell(dash, 0, 5, "Last signal", text_color = color.new(color.white, 20), text_size = size.small, bgcolor = bg)
    table.cell(dash, 1, 5, lastTxt, text_color = lastCol, text_size = size.small, bgcolor = bg)

// ─── Alerts ─────────────────────────────────────────────────
alertcondition(sellSig, "SELL — External Sweep", "Filtered external buy-side sweep (SELL).")
alertcondition(buySig,  "BUY — External Sweep",  "Filtered external sell-side sweep (BUY).")
alertcondition(buySig or sellSig, "Any External Sweep", "A filtered external liquidity sweep occurred.")
````
