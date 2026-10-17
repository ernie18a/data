# Adaptive SuperTrend -, Regime Filter & Buy/Sell Signals [LunqFX]

- url: https://www.tradingview.com/script/2bV26wI5-Adaptive-SuperTrend-Regime-Filter-Buy-Sell-Signals-LunqFX/
- type: indicator
- pine_id: PUB;4d55c847f4024f4f9141e5deed463e51
- version: 1.0

## Description

Adaptive SuperTrend is a self-tuning trend indicator for TradingView that fixes the biggest flaw of the classic SuperTrend: a fixed multiplier that whipsaws in choppy markets and lags in fast ones. This version makes the SuperTrend multiplier adaptive — it automatically widens in high volatility and tightens in low volatility — and layers a regime filter and a momentum filter on top to deliver clean, non-repainting Buy/Sell signals with an automatic take-profit / stop-loss ladder and live performance stats. It works on forex, crypto, stocks, indices, futures, gold (XAUUSD) and Bitcoin (BTCUSD), on any timeframe, for scalping, day trading and swing trading. Built in Pine Script v6. Keywords: adaptive supertrend, supertrend, trend, trend following, buy sell signals, regime filter, ATR trailing stop, volatility, momentum, take profit, stop loss, risk reward, trend reversal, no repaint, scalping, day trading, swing trading.

◆ WHY ADAPTIVE
A normal SuperTrend uses one fixed multiplier for every market and every condition, so it gets shaken out in volatile phases and reacts too slowly in calm ones. Adaptive SuperTrend ranks current volatility against its own recent history (0–100%) and maps that onto a multiplier range — wide when the market is wild, tight when it is calm — with zero manual tuning. The same settings behave sensibly on EURUSD, BTCUSD and the S&P 500.

◆ WHAT IT DOES

Adaptive trend line + fill — a volatility-adjusted trailing stop that flips turquoise (up) / magenta (down).
Filtered Buy/Sell signals — a trend flip only fires as a signal when two filters agree.
Auto TP/SL ladder — on every signal it draws the stop (on the trend line) and TP1 / TP2 / TP3 at 1R / 2R / 3R, so you get a complete trade plan instantly.
Conviction Score 0–100 — one number summarising how strong the current setup is.
Live win-rate stats — the script tracks its own past signals on the fly.
Neon trend candles + a clean live dashboard.

◆ HOW IT WORKS (the concepts)
[image]https://www.tradingview.com/x/cZQTipZH/[/image]

Adaptive multiplier: ATR is ranked by percentile over a lookback window; the percentile sets the SuperTrend multiplier between your min and max.
SuperTrend core: the standard trailing-stop formula, flipping direction when price closes beyond the band.
Regime filter (Kaufman Efficiency Ratio): directional travel divided by total path = how trending vs choppy the market is. Signals are blocked in low-efficiency (range) conditions to cut false signals.
Momentum check: a flip is only taken when price is on the matching side of its momentum EMA.
Conviction Score: a weighted blend of trend efficiency, momentum agreement and trend-line slope (0–100).
Live stats: each signal is tracked sequentially — a “win” = price reaches TP1 (1R) before the stop — with no lookahead.

◆ HOW TO USE IT

Take BUY / SELL labels in the direction of the new trend; the SL and TP1/2/3 ladder give you the exact plan and risk/reward.
Favour signals with a high Conviction Score and a TRENDING regime; stand aside when the dashboard shows RANGE.
Manage the trade to TP1/TP2/TP3 or trail with the adaptive line.
Tune Min/Max multiplier for tighter or looser stops and Efficiency threshold for how strict the range filter is.
Combine with your own support/resistance, structure or higher-timeframe bias for confluence.

◆ SETTINGS

Adaptive Trend: ATR length, min/max multiplier, volatility window.
Regime Filter: on/off, efficiency length, trend threshold.
Momentum Check: on/off, momentum EMA.
Visuals: trend fill, glow, neon candles, Buy/Sell labels.
Trade Levels & Stats: auto TP/SL ladder, live signal stats.
Panel: show/hide, position, background, accent.

◆ ALERTS

Buy signal · Sell signal · Trend flip up · Trend flip down.

◆ ORIGINALITY
The SuperTrend trailing-stop formula is a standard, public technique, implemented here from scratch. The adaptive volatility-percentile multiplier, the regime filter integration, the Conviction Score, the R-based TP/SL ladder and the live win-rate engine are my own original work. No third-party or copied code is used.

◆ LIMITATIONS

This is a trend/volatility tool, not a complete system — always confirm with price action and risk management.
Like all trend-following tools, it can chop in tight ranges; the regime filter reduces but cannot eliminate this.
The fixed-R stop in the ladder is a planning aid (constant 1R), separate from the trailing adaptive line — they are different stops by design.
The live win-rate is the indicator’s own TP1-vs-stop estimate; if a single bar tags both the stop and TP1 it is counted as a win, so treat the stat as indicative, not exact.
Past performance and live stats do not guarantee future results.

◆ NON-REPAINTING
Trend, regime, signals and stats are computed from confirmed bar data with no security() lookahead. A signal printed on a closed bar stays. As with any live tool, the forming bar updates in real time and settles on close.

Adaptive SuperTrend is an educational analysis tool, not financial advice. Always do your own research and manage risk. © LunqFX.

## Source Code

````pine
//@version=6
// ============================================================================
//  Adaptive SuperTrend - Trend, Regime Filter & Buy/Sell Signals [LunqFX]
// ----------------------------------------------------------------------------
//  A self-tuning trend engine. A classic fixed-multiplier SuperTrend whipsaws in
//  chop and lags in fast markets because its sensitivity never changes. This
//  version makes the multiplier ADAPTIVE: it widens when volatility is high (to
//  avoid being shaken out) and tightens when volatility is low (to react sooner)
//  - automatically, with no manual tuning - so it behaves on forex, crypto and
//  indices alike.
//
//  On top of the adaptive trend it adds two filters that kill false signals:
//      • REGIME FILTER  - an efficiency-ratio gauge that tells trend from range.
//                         Signals are only allowed when the market is actually
//                         trending, not chopping sideways.
//      • MOMENTUM CHECK - a flip is only taken as a Buy/Sell when momentum agrees
//                         with the new trend direction.
//
//  ORIGINAL WORK: the SuperTrend core is the standard public formula written from
//  scratch here; the adaptation (volatility-percentile multiplier), the regime
//  filter and the confluence logic are my own. No third-party code is used.
//
//  NON-REPAINTING: trend, regime and signals are computed from confirmed bar
//  data and evaluated on bar close. A signal printed on a closed bar stays.
// ============================================================================
indicator("Adaptive SuperTrend - Trend, Regime Filter & Buy/Sell Signals [LunqFX]", "Adaptive SuperTrend [LunqFX]", overlay = true, max_labels_count = 200)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (modern neon — turquoise = up, magenta = down)
// ─────────────────────────────────────────────────────────────────────────
TEAL_MID = #12B8A6
TEAL_HI  = #4DFCE6
PINK_MID = #FF2E63
PINK_HI  = #FF6FA3
GOLD     = #FFB938
INK      = #0B0E14
MUTE     = #5C6675
INKHI    = #EAEEF6

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gT      = "Adaptive Trend"
atrLen  = input.int(10,  "ATR length",            minval = 2, group = gT, tooltip = "Lookback for the volatility (ATR) the trend stop is built on.")
multMin = input.float(1.5,"Min multiplier (calm)", minval = 0.5, step = 0.1, group = gT, tooltip = "Sensitivity in LOW volatility — smaller = reacts sooner.")
multMax = input.float(4.0,"Max multiplier (wild)", minval = 1.0, step = 0.1, group = gT, tooltip = "Sensitivity in HIGH volatility — larger = avoids whipsaw.")
volLen  = input.int(100, "Volatility window",     minval = 20, group = gT, tooltip = "Window used to rank current volatility (drives the adaptive multiplier).")

gR      = "Regime Filter"
useReg  = input.bool(true, "Only signal in trending regime", group = gR, tooltip = "Suppresses Buy/Sell while the market is ranging/choppy.")
erLen   = input.int(14,  "Efficiency length",     minval = 3, group = gR, tooltip = "Kaufman efficiency-ratio lookback: directional travel vs total path.")
erThr   = input.float(0.30,"Trend threshold",     minval = 0.05, maxval = 0.9, step = 0.05, group = gR, tooltip = "Above this = trending (signals allowed). Below = range.")

gM      = "Momentum Check"
useMom  = input.bool(true, "Require momentum agreement", group = gM)
momLen  = input.int(20,  "Momentum EMA",          minval = 2, group = gM)

gV      = "Visuals"
showFill= input.bool(true, "Trend fill",          group = gV)
glow    = input.bool(true, "Glow line",           group = gV)
neonOn  = input.bool(true, "Neon trend candles",  group = gV, tooltip = "Colour candles by the adaptive trend (turquoise up / magenta down).")
showSig = input.bool(true, "Buy/Sell labels",     group = gV)

gTr     = "Trade Levels & Stats"
showLad = input.bool(true, "Auto TP/SL ladder (R:R)", group = gTr, tooltip = "Draws stop (on the trend line) and TP1/TP2/TP3 at 1R/2R/3R for the latest signal.")
showStat= input.bool(true, "Live signal stats",       group = gTr, tooltip = "Tracks past signals on the fly: win rate = share that reached TP1 (1R) before the stop. No lookahead.")

gP      = "Panel"
showHUD = input.bool(true, "Show dashboard",      group = gP)
hudPos  = input.string("Top Right","Position",    options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#0C0F16, "Background",      group = gP)
accent  = input.color(TEAL_MID, "Accent",        group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// ─────────────────────────────────────────────────────────────────────────
//  ADAPTIVE MULTIPLIER  (my own method: rank current volatility 0..1 and map it
//  onto the [min,max] multiplier range — high vol -> wider stop, low vol -> tighter)
// ─────────────────────────────────────────────────────────────────────────
atr   = ta.atr(atrLen)
volPr = ta.percentrank(atr, volLen) / 100.0      // 0..1 position of current ATR
mult  = multMin + (multMax - multMin) * volPr

// ─────────────────────────────────────────────────────────────────────────
//  SUPERTREND CORE  (standard public formula, implemented from scratch with a
//  series multiplier so it adapts every bar)
// ─────────────────────────────────────────────────────────────────────────
src     = hl2
upBasic = src + mult * atr
loBasic = src - mult * atr

var float upperB = na
var float lowerB = na
var int   dir    = 1

upperB := (upBasic < nz(upperB[1]) or close[1] > nz(upperB[1])) ? upBasic : nz(upperB[1])
lowerB := (loBasic > nz(lowerB[1]) or close[1] < nz(lowerB[1])) ? loBasic : nz(lowerB[1])
dir    := close > nz(upperB[1]) ? 1 : close < nz(lowerB[1]) ? -1 : nz(dir[1], 1)
st      = dir == 1 ? lowerB : upperB

up   = dir == 1
flipUp = dir == 1 and dir[1] == -1
flipDn = dir == -1 and dir[1] == 1

// ─────────────────────────────────────────────────────────────────────────
//  REGIME FILTER  (Kaufman efficiency ratio: directional move / total path)
// ─────────────────────────────────────────────────────────────────────────
netMove = math.abs(close - close[erLen])
path    = math.sum(math.abs(close - close[1]), erLen)
er      = path != 0 ? netMove / path : 0.0
trending = er >= erThr
regimeOK = not useReg or trending

// ─────────────────────────────────────────────────────────────────────────
//  MOMENTUM CHECK
// ─────────────────────────────────────────────────────────────────────────
emaM  = ta.ema(close, momLen)
momUp = close >= emaM
momOK_long  = not useMom or momUp
momOK_short = not useMom or not momUp

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS  (filtered, evaluated on close — no repaint)
// ─────────────────────────────────────────────────────────────────────────
buy  = flipUp and regimeOK and momOK_long
sell = flipDn and regimeOK and momOK_short

// ─────────────────────────────────────────────────────────────────────────
//  CONVICTION SCORE 0..100  (synthesised edge of the current setup)
//  blend of: trend efficiency + momentum agreement + trend-line slope
// ─────────────────────────────────────────────────────────────────────────
erComp   = math.min(1.0, er / 0.5)
momComp  = atr > 0 ? math.min(1.0, math.abs(close - emaM) / (atr * 2.0)) : 0.0
momAlign = (close >= emaM) == up ? momComp : 0.0
slopeComp= atr > 0 ? math.min(1.0, math.abs(st - st[5]) / atr) : 0.0
conv     = math.round(100 * (0.45 * erComp + 0.35 * momAlign + 0.20 * slopeComp))

// ─────────────────────────────────────────────────────────────────────────
//  TRADE STATE + LIVE STATS  (sequential, no lookahead)
//  SL = trend line at entry; TP1/2/3 = 1R/2R/3R. Win = TP1 reached before SL.
// ─────────────────────────────────────────────────────────────────────────
var float tEntry = na
var float tSL = na
var float tT1 = na
var float tT2 = na
var float tT3 = na
var int   tDir = 0
var bool  tOpen = false
var int   wins = 0
var int   losses = 0

// resolve an open trade with this bar's range
if tOpen
    if tDir == 1
        if high >= tT1
            wins += 1
            tOpen := false
        else if low <= tSL
            losses += 1
            tOpen := false
    else
        if low <= tT1
            wins += 1
            tOpen := false
        else if high >= tSL
            losses += 1
            tOpen := false

sig = buy or sell
if sig
    if tOpen                       // flip closed a still-open trade -> counts as a stop
        losses += 1
        tOpen := false
    tDir   := buy ? 1 : -1
    tEntry := close
    tSL    := st
    rr      = math.abs(tEntry - tSL)
    tT1    := buy ? tEntry + rr       : tEntry - rr
    tT2    := buy ? tEntry + 2.0 * rr : tEntry - 2.0 * rr
    tT3    := buy ? tEntry + 3.0 * rr : tEntry - 3.0 * rr
    tOpen  := true

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  AUTO TP/SL LADDER  (latest signal, extended right)
// ─────────────────────────────────────────────────────────────────────────
var line  lnS = na
var line  ln1 = na
var line  ln2 = na
var line  ln3 = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_setLad(line ln, label lb, float price, string txt, color c) =>
    line.set_xy1(ln, bar_index, price)
    line.set_xy2(ln, bar_index + 8, price)
    line.set_color(ln, c)
    label.set_xy(lb, bar_index + 8, price)
    label.set_text(lb, txt)
    label.set_color(lb, color.new(c, 0))

if showLad and sig
    if na(lnS)
        lnS := line.new(bar_index, tSL, bar_index + 8, tSL, color = PINK_MID, width = 1, style = line.style_dashed)
        ln1 := line.new(bar_index, tT1, bar_index + 8, tT1, color = TEAL_MID, width = 1)
        ln2 := line.new(bar_index, tT2, bar_index + 8, tT2, color = TEAL_MID, width = 1)
        ln3 := line.new(bar_index, tT3, bar_index + 8, tT3, color = TEAL_MID, width = 1)
        lbS := label.new(bar_index + 8, tSL, "", style = label.style_label_left, textcolor = INK, size = size.normal)
        lb1 := label.new(bar_index + 8, tT1, "", style = label.style_label_left, textcolor = INK, size = size.normal)
        lb2 := label.new(bar_index + 8, tT2, "", style = label.style_label_left, textcolor = INK, size = size.normal)
        lb3 := label.new(bar_index + 8, tT3, "", style = label.style_label_left, textcolor = INK, size = size.normal)
    f_setLad(lnS, lbS, tSL, " SL ", PINK_MID)
    f_setLad(ln1, lb1, tT1, " TP1 · 1R ", TEAL_MID)
    f_setLad(ln2, lb2, tT2, " TP2 · 2R ", TEAL_MID)
    f_setLad(ln3, lb3, tT3, " TP3 · 3R ", GOLD)

// show the ladder only while the trade is OPEN; remove it once SL/TP resolves
if showLad and not na(lnS)
    if tOpen
        if barstate.islast
            line.set_x2(lnS, bar_index + 8)
            line.set_x2(ln1, bar_index + 8)
            line.set_x2(ln2, bar_index + 8)
            line.set_x2(ln3, bar_index + 8)
            label.set_x(lbS, bar_index + 8)
            label.set_x(lb1, bar_index + 8)
            label.set_x(lb2, bar_index + 8)
            label.set_x(lb3, bar_index + 8)
    else
        line.delete(lnS)
        line.delete(ln1)
        line.delete(ln2)
        line.delete(ln3)
        label.delete(lbS)
        label.delete(lb1)
        label.delete(lb2)
        label.delete(lb3)
        lnS := na
        ln1 := na
        ln2 := na
        ln3 := na
        lbS := na
        lb1 := na
        lb2 := na
        lb3 := na

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────────────────────────────────
lineCol = up ? TEAL_MID : PINK_MID
edgeCol = up ? TEAL_HI : PINK_HI

stPlot = plot(st, "Adaptive SuperTrend", color = lineCol, linewidth = 2)
plot(glow ? st : na, "Glow", color = color.new(edgeCol, 70), linewidth = 6)
srcPlot = plot(showFill ? close : na, "", color = na, display = display.none)
fill(stPlot, srcPlot, color = showFill ? color.new(lineCol, 88) : na, title = "Trend fill")

// neon trend candles
bodyC = up ? color.from_gradient(volPr, 0, 1, TEAL_MID, TEAL_HI) : color.from_gradient(volPr, 0, 1, PINK_MID, PINK_HI)
plotcandle(neonOn ? open : na, high, low, close, "Neon", color = bodyC, wickcolor = edgeCol, bordercolor = edgeCol)

// signals
plotshape(showSig and buy,  "Buy",  style = shape.labelup,   location = location.belowbar, color = TEAL_MID, textcolor = INK, text = "BUY",  size = size.small)
plotshape(showSig and sell, "Sell", style = shape.labeldown, location = location.abovebar, color = PINK_MID, textcolor = INK, text = "SELL", size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudPosition(hudPos), 2, 8, bgcolor = color.new(hudBg, 0), border_width = 0, frame_color = color.new(#222A38, 0), frame_width = 1)

    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #1A2130), 0)
    teal  = accent

    trC = up ? TEAL_MID : PINK_MID
    trT = up ? "UP" : "DOWN"

    regT = trending ? "TRENDING" : "RANGE"
    regC = trending ? teal : GOLD

    // adaptive sensitivity meter (how wide the stop currently is)
    segN  = 10
    fillN = math.round(volPr * segN)
    sbar  = ""
    for i = 1 to segN
        sbar := sbar + (i <= fillN ? "▰" : "▱")

    momT = momUp ? "Bullish" : "Bearish"
    momC = momUp ? TEAL_MID : PINK_MID

    sigT = buy ? "BUY ▲" : sell ? "SELL ▼" : not regimeOK ? "Stand aside (range)" : up ? "Hold long" : "Hold short"
    sigC = buy ? TEAL_HI : sell ? PINK_HI : not regimeOK ? GOLD : up ? TEAL_MID : PINK_MID

    // conviction 0..100 with a neon meter
    cFill = math.round(conv / 100.0 * 10)
    cbar  = ""
    for i = 1 to 10
        cbar := cbar + (i <= cFill ? "▰" : "▱")
    convC = conv >= 66 ? TEAL_HI : conv >= 33 ? GOLD : MUTE

    // live stats
    statTxt = not showStat ? "off" : na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? TEAL_MID : winRate <= 45 ? PINK_MID : GOLD

    table.cell(hud, 0, 0, "  ADAPTIVE SUPERTREND", text_color = INKHI, text_size = size.normal, text_halign = text.align_left,  bgcolor = HEADR)
    table.cell(hud, 1, 0, "LunqFX  ",              text_color = teal,  text_size = size.normal, text_halign = text.align_right, bgcolor = HEADR)

    table.cell(hud, 0, 1, "  Trend", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 1, trT + "  ", text_color = trC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 2, "  Conviction", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 2, cbar + " " + str.tostring(conv) + "  ", text_color = convC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 3, "  Regime", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 3, regT + "  ", text_color = regC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 4, "  Sensitivity", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 4, sbar + "  ", text_color = teal, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 5, "  Momentum", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 5, momT + "  ", text_color = momC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 6, "  Signal", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 6, sigT + "  ", text_color = sigC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 7, "  Win rate (TP1)", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = HEADR)
    table.cell(hud, 1, 7, statTxt + "  ", text_color = statC, text_size = size.normal, text_halign = text.align_right, bgcolor = HEADR)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy signal",  "Adaptive SuperTrend flipped up with regime + momentum confirmation")
alertcondition(sell, "Sell signal", "Adaptive SuperTrend flipped down with regime + momentum confirmation")
alertcondition(flipUp,  "Trend flip up",   "Adaptive SuperTrend flipped up")
alertcondition(flipDn,  "Trend flip down", "Adaptive SuperTrend flipped down")
````
