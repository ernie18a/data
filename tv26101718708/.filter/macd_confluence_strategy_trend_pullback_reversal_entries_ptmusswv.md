# MACD Confluence Strategy | Trend, Pullback & Reversal Entries

- url: https://www.tradingview.com/script/PtmuSsWV-MACD-Confluence-Strategy-Trend-Pullback-Reversal-Entries/
- type: strategy
- pine_id: PUB;1c20606db61c434db6e5c6e8a8a6ae54
- version: 1.0

## Description

[b]What it is[/b]

MACD Confluence Strategy uses MACD for timing and a slow ATR channel plus a higher-timeframe check to decide whether a trade is allowed. MACD alone fires constantly in chop, so most of the logic here filters when its signals are allowed to trade.

[b]How it works[/b]

1. Regime filter. An entry is considered only when all of these agree:

Price is on the right side of a 200 EMA channel, and that EMA is sloping the same way.
ADX is above a minimum (18 by default), and DI+ or DI- confirms the direction.
The higher-timeframe MACD histogram (4h by default) points the same way. It reads the last completed higher-timeframe bar, so it does not repaint.
Price is not already stretched too far from the channel basis.

2. Three entry types

T (trend cross): MACD crosses its signal line in the direction of the regime. An optional setting only takes crosses that follow a pullback.
P (pullback): the histogram dips at least 25% from its recent peak, then turns back up with the trend.
R (reversal): price tags an outer channel band, the histogram turns, and a confirming candle closes. This is a counter-trend entry and ignores the higher-timeframe filter.

3. Exits and risk

[list]
[*]Stop at 2x ATR and target at 3R, both adjustable.
[*]At +1R the stop moves to break-even, then a chandelier trail takes over.
[*]Optional exit on an opposite MACD cross, and an optional time stop.
[*]Position size risks a fixed percentage of equity (1% by default) based on stop distance, with a cap on total notional.
[/list]

[b]Features[/b]
[list]
[*]ATR-normalized MACD pane: lines and histogram are scaled by ATR and squashed smoothly into a -100 to +100 range, so readings are comparable across symbols and timeframes.
[*]Four-shade histogram, a cloud between MACD and signal, and the higher-timeframe histogram as a step line.
[*]ATR channel on the price chart with the outer reversal bands highlighted.
[*]T / P / R entry markers, plus stop and target lines while a trade is open.
[*]Bars tinted green or red when the regime is bullish or bearish.
[*]Live stats table: regime, ADX, position, trades, win rate, profit factor and net P/L.
[*]Direction control (both, long only, short only), and each entry type can be switched off.
[/list]

[b]Tips[/b]
[list]
[*]Start with the defaults, then change one setting at a time. Test on several symbols and timeframes, not just the one that looks best.
[*]For a pure trend system, turn off R. For fewer, higher-quality trades, turn on “T only after pullback” and raise the minimum ADX.
[*]Pick a higher timeframe at least 4 to 6 times your chart timeframe.
[*]On choppy or range-bound markets, raise the minimum ADX or lengthen the cooldown between entries.
[*]Adjust commission and slippage in the strategy properties to match your broker.
[/list]

[b]Warnings[/b]
[list]
[*]This is an educational tool, not financial advice. Past performance does not predict future results.
[*]Backtests can be misleading. Results depend heavily on the symbol, timeframe, date range, and fee and slippage assumptions.
[*]Exits are simulated on historical bar data, so real fills, gaps and slippage can differ from the backtest.
[*]Reversal (R) entries trade against the trend and can lose repeatedly in strong moves.
[*]Check that the backtest has a meaningful number of trades before drawing any conclusion from it.
[*]Risk per trade and the notional cap limit exposure but do not remove the risk of loss.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blitz_locked

//@version=6
strategy("MACD Confluence Strategy", shorttitle="MCS",
     overlay=false,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     commission_type=strategy.commission.percent,
     commission_value=0.05,
     slippage=2,
     pyramiding=0,
     max_labels_count=100)

// =====================================================================================
// MACD CONFLUENCE STRATEGY
//
// Idea: MACD decides WHEN, the channel + higher timeframe decide WHETHER.
//
//  Regime   : price vs. slow EMA (200) with ATR-spaced bands, ADX/DI strength, and the
//             sign of the NON-REPAINTING higher-timeframe MACD histogram.
//  Entries  : T  = trend cross      (MACD/Signal cross with the regime)
//             P  = pullback         (histogram dips, then re-accelerates with the regime)
//             R  = reversal         (price tags an outer band, histogram turns, candle confirms)
//  Exits    : ATR stop, R-multiple target, break-even + chandelier trail once +1R is hit,
//             optional opposite MACD cross, optional time stop.
//  Sizing   : fixed % of equity risked per trade, based on stop distance.
//  Visuals  : ATR-normalized MACD pane (smooth squash to -100..+100), HTF histogram step
//             line, channel bands on the price chart, entry markers, regime bar colors,
//             and a live stats table.
//
// Educational tool, not financial advice. Backtests are not predictions.
// =====================================================================================

// ---------- Inputs ----------
string G1 = "MACD"
int fastLen = input.int(12, "Fast", minval=1, group=G1)
int slowLen = input.int(26, "Slow", minval=2, group=G1)
int sigLen  = input.int(9,  "Signal", minval=1, group=G1)
float gain  = input.float(1.2, "Normalization gain", minval=0.1, step=0.1, group=G1,
     tooltip="MACD / ATR is passed through a smooth tanh-style squash into -100..+100. Higher gain = fills the pane faster.")

string G2 = "Regime"
int chLen = input.int(200, "Channel EMA length", minval=20, group=G2)
float chMult = input.float(1.5, "Band spacing (x smoothed ATR)", minval=0.2, step=0.1, group=G2)
float maxExt = input.float(3.0, "Max extension for trend entries (bands)", minval=0.5, step=0.5, group=G2,
     tooltip="Trend/pullback entries are skipped when price is already this many bands from the channel basis.")
float minAdx = input.float(18.0, "Min ADX for trend / pullback", minval=0, group=G2)
bool useHtf = input.bool(true, "Require HTF MACD agreement", group=G2)
string htfInput = input.timeframe("240", "Higher timeframe", group=G2)

string G3 = "Entries"
string dirMode = input.string("Both", "Direction", options=["Both", "Long only", "Short only"], group=G3)
bool useTrendX = input.bool(true, "T: trend cross", group=G3)
bool crossPullbackOnly = input.bool(false, "  T only after pullback (MACD on far side of zero)", group=G3)
bool usePullback = input.bool(true, "P: pullback re-acceleration", group=G3)
float pbDepth = input.float(0.25, "  P: min histogram dip (fraction of peak)", minval=0.05, maxval=0.95, step=0.05, group=G3)
bool useRev = input.bool(true, "R: outer-band reversal", group=G3)
int revLevel = input.int(3, "  R: band level touched", minval=2, maxval=5, group=G3)
int cooldown = input.int(5, "Bars between entries", minval=0, group=G3)

string G4 = "Risk & exits"
float riskPct = input.float(1.0, "Risk per trade (% equity)", minval=0.1, step=0.1, group=G4)
float maxLev = input.float(2.0, "Max notional (x equity)", minval=0.1, step=0.1, group=G4)
int atrLen = input.int(14, "ATR length", minval=1, group=G4)
float slMult = input.float(2.0, "Stop (x ATR)", minval=0.5, step=0.25, group=G4)
float tpR = input.float(3.0, "Target (R multiple)", minval=0.5, step=0.25, group=G4)
float beR = input.float(1.0, "Arm break-even / trail at (R)", minval=0.25, step=0.25, group=G4)
bool useTrail = input.bool(true, "Chandelier trail after arming", group=G4)
float trailMult = input.float(2.5, "  Trail (x ATR)", minval=0.5, step=0.25, group=G4)
bool momoExit = input.bool(true, "Exit on opposite MACD cross", group=G4)
int minHold = input.int(3, "  Min bars held before cross exit", minval=0, group=G4)
int maxBars = input.int(0, "Time stop in bars (0 = off)", minval=0, group=G4)

string G5 = "Display"
bool showChannel = input.bool(true, "Channel on price chart", group=G5)
bool showHtfLine = input.bool(true, "HTF histogram step line", group=G5)
bool showMarks   = input.bool(true, "Entry markers", group=G5)
bool tintBars    = input.bool(true, "Tint bars by regime", group=G5)
bool showTable   = input.bool(true, "Stats table", group=G5)

// ---------- Palette ----------
color cTeal   = #14b8a6
color cTealLt = #99f6e4
color cRose   = #fb7185
color cRoseLt = #fecdd3
color cViolet = #a78bfa
color cAmber  = #fbbf24
color cSlate  = #94a3b8

// ---------- Helpers ----------
squash(float x, float g) =>
    float v = math.max(-20.0,math.min(20.0, x*g))
    float e = math.exp(2.0*v)
    100.0 * (e-1.0) / (e + 1.0)


// Runs inside request.security on the HTF. [1] + lookahead_on = last COMPLETED HTF bar (no repaint).
htfCalc() =>
    float m = ta.ema(close, fastLen) - ta.ema(close, slowLen)
    float sg = ta.ema(m, sigLen)
    float h = m - sg
    float a = ta.atr(atrLen)
    float nh = a > 0 ? squash(h / a, gain) : na
    nh[1]


// ---------- Core calculations ----------
float atr = ta.atr(atrLen)
[macdL,sigL,hist]=ta.macd(close,fastLen,slowLen,sigLen)

float nM = atr > 0 ? squash(macdL / atr, gain) : na
float nS = atr > 0 ? squash(sigL / atr, gain) : na
float nH = atr > 0 ? squash(hist / atr, gain) : na

bool crossUp = ta.crossover(macdL,sigL)
bool crossDn = ta.crossunder(macdL, sigL)

float basis = ta.ema(close, chLen)
float step  = ta.ema(ta.atr(21), 12) * chMult
float z = step > 0 ? (close - basis) / step : 0.0
[diP, diM, adx] = ta.dmi(14, 14)

string htfTf = timeframe.in_seconds(htfInput) <= timeframe.in_seconds() ? timeframe.period : htfInput
float htfHist = request.security(syminfo.tickerid, htfTf, htfCalc(), lookahead=barmerge.lookahead_off)

bool htfOkL = not useHtf or htfHist > 0
bool htfOkS = not useHtf or htfHist < 0

bool trendUp = close > basis and basis > basis[10]
bool trendDn = close < basis and basis < basis[10]
bool strongOk = adx >= minAdx

// ---------- Signal logic ----------
float peakH   = ta.highest(hist, 12)
float troughH = ta.lowest(hist, 12)
float dipLow  = ta.lowest(hist, 4)
float dipHigh = ta.highest(hist, 4)
float depthL = peakH > 0 ? (peakH - dipLow) / peakH : 0.0
float depthS = troughH < 0 ? (dipHigh - troughH) / math.abs(troughH) : 0.0

// Reversal: outer band tagged within the last 3 bars
bool tagLow = ta.barssince(low <= basis - step * revLevel) <= 3
bool tagHigh = ta.barssince(high >= basis + step * revLevel) <= 3

bool histTurnUp = hist > hist[1] and hist[1] <= hist[2]
bool histTurnDn = hist < hist[1] and hist[1] >= hist[2]

bool allowLong  = dirMode != "Short only"
bool allowShort = dirMode != "Long only"

var int lastEntryBar = na
bool canTrade = na(lastEntryBar) or bar_index - lastEntryBar > cooldown

bool trendOkL = trendUp and htfOkL and strongOk and diP > diM and z < maxExt
bool trendOkS = trendDn and htfOkS and strongOk and diM > diP and z > -maxExt

bool rawLA = useTrendX and crossDn and trendOkS and (not crossPullbackOnly or macdL<0)
bool rawLB = usePullback and trendOkL and hist > 0 and hist > hist[1] and hist[1] <= hist[2] and depthL >= pbDepth and close > open
bool rawLC = useRev and tagLow and histTurnUp and close > open and close > close[1]

bool rawSA = useTrendX and crossDn and trendOkS and (not crossPullbackOnly or macdL > 0)
bool rawSB = usePullback and trendOkS and hist < 0 and hist < hist[1] and hist[1] >= hist[2] and depthS >= pbDepth and close < open
bool rawSC = useRev and tagHigh and histTurnDn and close < open and close < close[1]

bool gateL = allowLong and canTrade
bool gateS = allowShort and canTrade

bool longA = gateL and rawLA
bool longB = gateL and rawLB and not longA
bool longC = gateL and rawLC and not longA and not longB
bool longSig = longA or longB or longC

bool shortA = gateS and rawSA and not longSig
bool shortB = gateS and rawSB and not longSig and not shortA
bool shortC = gateS and rawSC and not longSig and not shortA and not shortB
bool shortSig = shortA or shortB or shortC

// ---------- Orders ----------
float riskDistSig = slMult * atr
float qty = riskDistSig > 0 ? math.min(strategy.equity * riskPct / 100.0 / riskDistSig, strategy.equity * maxLev / close) : na

if longSig and strategy.position_size <=0 and not na(qty) and qty > 0
    strategy.entry("Long", strategy.long,qty=qty)
    lastEntryBar := bar_index

if shortSig and strategy.position_size >= 0 and not na(qty) and qty > 0
    strategy.entry("Short", strategy.short, qty=qty)
    lastEntryBar := bar_index

// ---------- Trade management ----------
var float entryPx = na
var float riskD = na
var float stopL = na
var float tpL = na
var float stopS = na
var float tpS = na
var bool armed = false
var int entryBar = na

float trailL = ta.highest(high, 3) - trailMult * atr
float trailS = ta.lowest(low, 3) + trailMult * atr

bool justLong  = strategy.position_size > 0 and strategy.position_size[1] <= 0
bool justShort = strategy.position_size < 0 and strategy.position_size[1] >= 0

if justLong or justShort
    entryPx  := strategy.position_avg_price
    riskD    := slMult * atr[1]
    armed    := false
    entryBar := bar_index
    if justLong
        stopL := entryPx - riskD
        tpL   := entryPx + riskD * tpR
    if justShort
        stopS := entryPx + riskD
        tpS   := entryPx - riskD * tpR

if strategy.position_size > 0
    if not armed and high >= entryPx + riskD * beR
        armed := true
        stopL := math.max(stopL, entryPx)
    if armed and useTrail
        stopL := math.max(stopL, trailL)
    strategy.exit("Long Exit", "Long", stop=stopL, limit=tpL)

if strategy.position_size < 0
    if not armed and low <= entryPx - riskD * beR
        armed := true
        stopS := math.min(stopS, entryPx)
    if armed and useTrail
        stopS := math.min(stopS, trailS)
    strategy.exit("Short Exit", "Short", stop=stopS, limit=tpS)

bool held = not na(entryBar) and bar_index - entryBar >= minHold
if momoExit and held
    if strategy.position_size > 0 and crossDn
        strategy.close("Long", comment="MACD X")
    if strategy.position_size < 0 and crossUp
        strategy.close("Short", comment="MACD X")

if maxBars > 0 and strategy.position_size != 0 and not na(entryBar) and bar_index - entryBar >= maxBars
    strategy.close_all(comment="Time stop")

// =====================================================================================
// VISUALS
// =====================================================================================

// ---- Oscillator pane (normalized -100..+100) ----
hline(0, "Zero", color=color.new(cSlate, 60), linestyle=hline.style_dotted)
hline(34, "+34", color=color.new(cSlate, 85), linestyle=hline.style_dotted)
hline(-34, "-34", color=color.new(cSlate, 85), linestyle=hline.style_dotted)
hline(75, "+75", color=color.new(cSlate, 88), linestyle=hline.style_dotted)
hline(-75, "-75", color=color.new(cSlate, 88), linestyle=hline.style_dotted)

color histCol = hist >= 0 ? (hist >= hist[1] ? cTeal : color.new(cTealLt, 20)) : (hist <= hist[1] ? cRose : color.new(cRoseLt, 20))
plot(nH, "MACD Histogram", style=plot.style_columns, color=histCol)

pM = plot(nM, "MACD", color=cViolet, linewidth=2)
pS = plot(nS, "Signal", color=cAmber, linewidth=1)
fill(pM, pS, color=nM >= nS ? color.new(cTeal, 85) : color.new(cRose, 85), title="MACD cloud")

plot(showHtfLine ? htfHist : na, "HTF Histogram (completed bar)", style=plot.style_stepline,
     color=htfHist >= 0 ? color.new(cTeal, 25) : color.new(cRose, 25), linewidth=2)

plotshape(crossUp ? nS : na, "Cross up", style=shape.circle, location=location.absolute, color=cTealLt, size=size.tiny)
plotshape(crossDn ? nS : na, "Cross down", style=shape.circle, location=location.absolute, color=cRoseLt, size=size.tiny)

// ---- Channel on the price chart ----
float bandAlpha = 100
plot(showChannel ? basis : na, "Basis", color=color.new(cViolet, 10), linewidth=2, force_overlay=true)
pu1 = plot(showChannel ? basis + step : na, "Upper 1", color=color.new(cTeal, 60), force_overlay=true)
plot(showChannel ? basis + step * 2 : na, "Upper 2", color=color.new(cTeal, 72), force_overlay=true)
plot(showChannel ? basis + step * revLevel : na, "Upper reversal band", color=color.new(cTeal, 35), linewidth=2, force_overlay=true)
pl1 = plot(showChannel ? basis - step : na, "Lower 1", color=color.new(cRose, 60), force_overlay=true)
plot(showChannel ? basis - step * 2 : na, "Lower 2", color=color.new(cRose, 72), force_overlay=true)
plot(showChannel ? basis - step * revLevel : na, "Lower reversal band", color=color.new(cRose, 35), linewidth=2, force_overlay=true)
pb = plot(showChannel ? basis : na, "Basis (fill anchor)", color=color.new(cViolet, 100), force_overlay=true)
fill(pb, pu1, color=color.new(cTeal, 94), title="Upper inner fill")
fill(pb, pl1, color=color.new(cRose, 94), title="Lower inner fill")

// ---- Entry markers ----
plotshape(showMarks and longA, "Long T", style=shape.triangleup, location=location.belowbar, color=cTeal, size=size.small, text="T", textcolor=cTeal, force_overlay=true)
plotshape(showMarks and longB, "Long P", style=shape.triangleup, location=location.belowbar, color=cTealLt, size=size.tiny, text="P", textcolor=cTealLt, force_overlay=true)
plotshape(showMarks and longC, "Long R", style=shape.diamond, location=location.belowbar, color=cTeal, size=size.small, text="R", textcolor=cTeal, force_overlay=true)
plotshape(showMarks and shortA, "Short T", style=shape.triangledown, location=location.abovebar, color=cRose, size=size.small, text="T", textcolor=cRose, force_overlay=true)
plotshape(showMarks and shortB, "Short P", style=shape.triangledown, location=location.abovebar, color=cRoseLt, size=size.tiny, text="P", textcolor=cRoseLt, force_overlay=true)
plotshape(showMarks and shortC, "Short R", style=shape.diamond, location=location.abovebar, color=cRose, size=size.small, text="R", textcolor=cRose, force_overlay=true)

// ---- Active stop / target lines while in a trade ----
plot(strategy.position_size > 0 ? stopL : strategy.position_size < 0 ? stopS : na, "Stop", style=plot.style_linebr, color=color.new(cRose, 30), linewidth=1, force_overlay=true)
plot(strategy.position_size > 0 ? tpL : strategy.position_size < 0 ? tpS : na, "Target", style=plot.style_linebr, color=color.new(cTeal, 30), linewidth=1, force_overlay=true)

// ---- Regime bar tint ----
bool bullRegime = trendUp and htfHist > 0
bool bearRegime = trendDn and htfHist < 0
barcolor(tintBars ? (bullRegime ? color.new(cTeal, 20) : bearRegime ? color.new(cRose, 20) : na) : na)

// ---- Stats table ----
var table tbl = table.new(position.top_right, 2, 8, bgcolor=color.new(#0f172a, 15), border_width=1, border_color=color.new(cSlate, 70))
if showTable and barstate.islast
    int closed = strategy.closedtrades
    float pf = strategy.grossloss != 0 ? strategy.grossprofit / math.abs(strategy.grossloss) : na
    float winPct = closed > 0 ? 100.0 * strategy.wintrades / closed : na
    string regimeTxt = bullRegime ? "BULL" : bearRegime ? "BEAR" : "MIXED"
    color regimeCol = bullRegime ? cTeal : bearRegime ? cRose : cSlate
    string posTxt = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"

    table.cell(tbl, 0, 0, "Regime", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 0, regimeTxt, text_color=regimeCol, text_size=size.small)
    table.cell(tbl, 0, 1, "HTF (" + htfTf + ")", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 1, na(htfHist) ? "n/a" : str.tostring(htfHist, "#.0"), text_color=htfHist >= 0 ? cTeal : cRose, text_size=size.small)
    table.cell(tbl, 0, 2, "ADX", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(adx, "#.0"), text_color=strongOk ? cTeal : cSlate, text_size=size.small)
    table.cell(tbl, 0, 3, "Position", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 3, posTxt, text_color=strategy.position_size > 0 ? cTeal : strategy.position_size < 0 ? cRose : cSlate, text_size=size.small)
    table.cell(tbl, 0, 4, "Trades", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(closed), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 5, "Win %", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 5, na(winPct) ? "n/a" : str.tostring(winPct, "#.0") + "%", text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 6, "Profit factor", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 6, na(pf) ? "n/a" : str.tostring(pf, "#.00"), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 7, "Net P/L", text_color=cSlate, text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(strategy.netprofit, "#.00"), text_color=strategy.netprofit >= 0 ? cTeal : cRose, text_size=size.small)
````
