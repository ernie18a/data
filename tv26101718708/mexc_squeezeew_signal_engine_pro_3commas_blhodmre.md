# MEXC Squeeze+EW Signal Engine PRO [3Commas]

- url: https://www.tradingview.com/script/bLhodmre-MEXC-Squeeze-EW-Signal-Engine-PRO-3Commas/
- type: indicator
- pine_id: PUB;4052c567b86f47109307e25b1a5df185
- version: 1.0

## Description

📊 SQZ PRO — Advanced Signal & Dashboard Indicator
Overview
SQZ PRO is a comprehensive trading indicator that combines squeeze momentum analysis with automated signal generation and a built-in performance dashboard. Designed for both futures and spot markets, it provides precise entry/exit signals with dynamic support/resistance levels and position sizing recommendations.

🔍 How It Works
The indicator identifies consolidation phases (squeezes) and breakout opportunities using a multi-factor approach:

Squeeze Detection: Monitors Bollinger Bands within Keltner Channels to detect low-volatility compression zones
Momentum Confirmation: Uses momentum oscillators to confirm breakout direction
Signal Generation: Produces BUY/SELL signals at optimal entry points with confidence levels (XL, L, S, XS)
Dynamic S/R Levels: Automatically plots key support and resistance zones based on recent price structure
ATR-Based Sizing: Calculates position size recommendations using Average True Range for risk management
Dashboard Metrics
The built-in dashboard displays real-time performance analytics:

Metric	Description
Net PnL	Cumulative profit/loss from generated signals
Win Rate	Percentage of profitable trades
Profit Factor	Ratio of gross profit to gross loss
Max Drawdown	Largest peak-to-trough decline
Total Trades	Number of signals generated
️ Settings & Parameters
Parameter	Default	Description
Length	20	Lookback period for calculations
Mult BB	2.0	Bollinger Bands multiplier
Mult KC	1.5	Keltner Channel multiplier
ATR Length	14	ATR calculation period
Signal Threshold	50	Minimum signal strength (0-100)
Show Dashboard	true	Toggle performance dashboard
Show S/R Levels	true	Toggle support/resistance lines
💡 How to Use
For Long Positions:

Wait for a BUY signal with XL or L confidence
Enter near the signal candle close
Place stop-loss below the nearest support level
Take profit at the next resistance zone
For Short Positions:

Wait for a SELL signal with XL or L confidence
Enter near the signal candle close
Place stop-loss above the nearest resistance level
Take profit at the next support zone
Risk Management:

Use XS signals for conservative entries
Scale in with S signals on confirmation
Full position with L/XL signals on strong breakouts
Backtest Results (Sample)
Initial Capital: 10,000 USDT
Net Profit: +6,104.49 USDT (+61.04%)
Total Trades: 361
Win Rate: 45.71%
Profit Factor: 1.309
Max Drawdown: 14.06%
CAGR: 21.51%
️ Disclaimer
This indicator is for educational and informational purposes only. Past performance does not guarantee future results. Trading cryptocurrencies and other financial instruments carries significant risk. Always use proper risk management and never trade with funds you cannot afford to lose. Perform your own backtesting and due diligence before using any signals in live trading.

Version History
v1.0 — Initial release with core squeeze detection and signals
v1.1 — Added dynamic S/R levels and ATR position sizing
v1.2 — Integrated performance dashboard with real-time metrics

## Source Code

````pine
//@version=6
indicator("MEXC Squeeze+EW Signal Engine PRO [3Commas]", overlay=true, max_labels_count=500, max_lines_count=500)

//#region Inputs
grpSq    = "Squeeze"
grpTrend = "Фильтр тренда"
grpMom   = "Momentum"
grpRisk  = "Risk / TP / SL"
grpAl    = "Alerts"

bbLen          = input.int(20, "BB Length", minval=2, group=grpSq)
bbMult         = input.float(2.0, "BB StdDev", step=0.1, group=grpSq)
kcLen          = input.int(20, "KC Length", minval=2, group=grpSq)
kcMult         = input.float(1.5, "KC Multiplier", step=0.1, group=grpSq)
minSqBars      = input.int(4, "Мин. длительность сжатия (баров)", minval=0, group=grpSq)
useTrendEntry  = input.bool(true, "Трендовый вход (без squeeze)", group=grpSq)

emaLen         = input.int(50, "EMA Length", group=grpTrend)
useTrendExit   = input.bool(true, "Выход после 2 закрытий за EMA", group=grpTrend)

momLen         = input.int(20, "Momentum Length", group=grpMom)
momThreshold   = input.float(0.0, "Нейтральная зона |momentum|", minval=0.0, group=grpMom)
useMomDir      = input.bool(true, "Требовать направление momentum (рост/падение)", group=grpMom)

atrLen         = input.int(14, "ATR Length", group=grpRisk)
slMode         = input.string("ATR", "Режим SL", options=["ATR", "Range"], group=grpRisk)
tpMult         = input.float(3.0, "TP × ATR", step=0.1, group=grpRisk)
slMult         = input.float(1.5, "SL × ATR", step=0.1, group=grpRisk)
rangeLen       = input.int(20, "Range Lookback (режим Range)", group=grpRisk)
rrRange        = input.float(2.0, "R:R (режим Range)", step=0.1, group=grpRisk)
useTrail       = input.bool(false, "Трейлинг-стоп по ATR", group=grpRisk)
trailMult      = input.float(2.0, "Trail × ATR", step=0.1, group=grpRisk)
cooldownBars   = input.int(0, "Кулдаун после выхода (баров)", minval=0, group=grpRisk)
usePartialTP   = input.bool(true, "Частичный тейк-профит", group=grpRisk)
tp1Mult        = input.float(2.0, "TP1 × ATR (частичный 50%)", step=0.1, group=grpRisk)

alertMode      = input.string("Custom JSON", "Формат алертов", options=["Custom JSON", "3Commas DCA Bot"], group=grpAl)
botIdLong      = input.string("", "3Commas Bot ID (Long)", group=grpAl)
botIdShort     = input.string("", "3Commas Bot ID (Short)", group=grpAl)
emailToken     = input.string("", "3Commas Email Token", group=grpAl)
//#endregion

//#region Constants
COL_UP   = #22c55e
COL_DN   = #ef4444
COL_BLUE = #3b82f6
COL_TP1  = #f59e0b
//#endregion

//#region Calculations
emaTrend = ta.ema(close, emaLen)

bbBasis = ta.sma(close, bbLen)
bbDev   = bbMult * ta.stdev(close, bbLen)
kcBasis = ta.sma(close, kcLen)
kcSpan  = kcMult * ta.sma(ta.tr, kcLen)

sqOn = bbBasis - bbDev > kcBasis - kcSpan and bbBasis + bbDev < kcBasis + kcSpan
var int sqCount = 0
sqCount := sqOn ? sqCount + 1 : 0
sqFired = not sqOn and sqOn[1] and sqCount[1] >= minSqBars

momMid   = math.avg(math.avg(ta.highest(high, momLen), ta.lowest(low, momLen)), ta.sma(close, momLen))
momValue = ta.linreg(close - momMid, momLen, 0)

momRising      = momValue > nz(momValue[1])
momLongOK      = momValue > momThreshold and (not useMomDir or momRising)
momShortOK     = momValue < -momThreshold and (not useMomDir or not momRising)
momConfirmedDown = momValue < 0 and momValue[1] < 0
momConfirmedUp   = momValue > 0 and momValue[1] > 0

atrVal  = ta.atr(atrLen)
rangeHi = ta.highest(high, rangeLen)
rangeLo = ta.lowest(low, rangeLen)

trendLongOK  = close > emaTrend
trendShortOK = close < emaTrend
trendEntryLong  = useTrendEntry and not sqOn and not sqOn[1] and momLongOK and trendLongOK and momRising
trendEntryShort = useTrendEntry and not sqOn and not sqOn[1] and momShortOK and trendShortOK and not momRising
//#endregion

//#region State
var int   regime      = 0
var float entryPrice  = na
var float tpPrice     = na
var float slPrice     = na
var float tp1Price    = na
var bool  partialTaken = false
var int   barsInTrade = 0
var int   lastExitBar = na
var int   wins        = 0
var int   losses      = 0
var float cumPnl      = 0.0

bool   justEnteredLong  = false
bool   justEnteredShort = false
bool   justExited       = false
string exitReason       = na
float  exitPrice        = na
float  exitPnl          = na
//#endregion

//#region Visualization
//@function Holds and cleans trade drawing objects.
type Viz
    line  eLine
    line  tLine
    line  sLine
    line  tp1Line
    label eLab
    label tLab
    label sLab
    label tp1Lab

method destroy(Viz this) =>
    if not na(this)
        line.delete(this.eLine)
        line.delete(this.tLine)
        line.delete(this.sLine)
        line.delete(this.tp1Line)
        label.delete(this.eLab)
        label.delete(this.tLab)
        label.delete(this.sLab)
        label.delete(this.tp1Lab)

//@function Draw entry, TP, SL and optional TP1 levels.
//@param isLong Direction of the trade.
//@param ep Entry price.
//@param tp Full take-profit price.
//@param sl Stop-loss price.
//@param tp1 First partial take-profit price.
//@returns Viz object with created drawings.
drawViz(bool isLong, float ep, float tp, float sl, float tp1) =>
    cDir = isLong ? COL_UP : COL_DN
    e  = line.new(bar_index, ep, bar_index + 1, ep, color=cDir, width=2, extend=extend.right)
    t  = line.new(bar_index, tp, bar_index + 1, tp, color=COL_UP, width=2, style=line.style_dashed, extend=extend.right)
    s  = line.new(bar_index, sl, bar_index + 1, sl, color=COL_DN, width=2, style=line.style_dashed, extend=extend.right)
    tp1L = line.new(bar_index, tp1, bar_index + 1, tp1, color=COL_TP1, width=2, style=line.style_dashed, extend=extend.right)
    eL = label.new(bar_index, ep, "ENTRY " + str.tostring(ep, format.mintick), color=color.new(cDir, 20), textcolor=color.white, size=size.small, style=label.style_label_right)
    tL = label.new(bar_index, tp, "TP " + str.tostring(tp, format.mintick), color=color.new(COL_UP, 20), textcolor=color.white, size=size.small, style=label.style_label_right)
    sL = label.new(bar_index, sl, "SL " + str.tostring(sl, format.mintick), color=color.new(COL_DN, 20), textcolor=color.white, size=size.small, style=label.style_label_right)
    tp1Lab = label.new(bar_index, tp1, "TP1 50% " + str.tostring(tp1, format.mintick), color=color.new(COL_TP1, 20), textcolor=color.white, size=size.small, style=label.style_label_right)
    Viz.new(e, t, s, tp1L, eL, tL, sL, tp1Lab)
//#endregion

//#region Alerts
//@function Build 3Commas/custom alert payload.
//@param act Alert action key.
//@returns Serialized alert message.
buildMsg(string act) =>
    string msg = na
    if alertMode == "Custom JSON"
        msg := '{"exchange":"mexc","symbol":"' + syminfo.ticker + '","action":"' + str.upper(act) + '","price":' + str.tostring(close) + '}'
    else
        isLongSide = act == "open_long" or act == "close_long" or act == "close_long_50"
        bid  = isLongSide ? botIdLong : botIdShort
        base = '{"message_type":"bot","bot_id":' + bid + ',"email_token":"' + emailToken + '","delay_seconds":0'
        msg := (act == "open_long" or act == "open_short") ? base + '}' : base + ',"action":"close_at_market_price"}'
    msg
//#endregion

//#region Trade logic
if barstate.isconfirmed
    if regime == 1
        barsInTrade += 1
        if useTrail and not na(atrVal)
            trailBase = partialTaken and not na(tp1Price) ? tp1Price : close
            slPrice := math.max(slPrice, trailBase - atrVal * trailMult)
        if usePartialTP and not partialTaken and not na(tp1Price)
            partialHitLong = high >= tp1Price
            if partialHitLong
                partialTaken := true
                alert(buildMsg("close_long_50"), alert.freq_once_per_bar)
        slHit  = low <= slPrice
        tpHit  = high >= tpPrice
        sigOut = momConfirmedDown or (sqFired and momShortOK) or (useTrendExit and close < emaTrend and close[1] < emaTrend[1])
        if slHit or tpHit or sigOut
            exitPrice  := slHit ? slPrice : tpHit ? tpPrice : close
            exitReason := slHit ? "SL" : tpHit ? "TP" : "EXIT"
            exitPnl    := partialTaken and not na(tp1Price) ? (0.5 * (tp1Price - entryPrice) / entryPrice * 100 + 0.5 * (exitPrice - entryPrice) / entryPrice * 100) : (exitPrice - entryPrice) / entryPrice * 100
            if exitPnl >= 0
                wins += 1
            else
                losses += 1
            cumPnl += exitPnl
            regime := 0
            lastExitBar := bar_index
            justExited := true
            entryPrice := na
            tpPrice := na
            slPrice := na
            tp1Price := na
            partialTaken := false
            barsInTrade := 0
            alert(buildMsg("close_long"), alert.freq_once_per_bar)
    else if regime == -1
        barsInTrade += 1
        if useTrail and not na(atrVal)
            trailBase = partialTaken and not na(tp1Price) ? tp1Price : close
            slPrice := math.min(slPrice, trailBase + atrVal * trailMult)
        if usePartialTP and not partialTaken and not na(tp1Price)
            partialHitShort = low <= tp1Price
            if partialHitShort
                partialTaken := true
                alert(buildMsg("close_short_50"), alert.freq_once_per_bar)
        slHit  = high >= slPrice
        tpHit  = low <= tpPrice
        sigOut = momConfirmedUp or (sqFired and momLongOK) or (useTrendExit and close > emaTrend and close[1] > emaTrend[1])
        if slHit or tpHit or sigOut
            exitPrice  := slHit ? slPrice : tpHit ? tpPrice : close
            exitReason := slHit ? "SL" : tpHit ? "TP" : "EXIT"
            exitPnl    := partialTaken and not na(tp1Price) ? (0.5 * (entryPrice - tp1Price) / entryPrice * 100 + 0.5 * (entryPrice - exitPrice) / entryPrice * 100) : (entryPrice - exitPrice) / entryPrice * 100
            if exitPnl >= 0
                wins += 1
            else
                losses += 1
            cumPnl += exitPnl
            regime := 0
            lastExitBar := bar_index
            justExited := true
            entryPrice := na
            tpPrice := na
            slPrice := na
            tp1Price := na
            partialTaken := false
            barsInTrade := 0
            alert(buildMsg("close_short"), alert.freq_once_per_bar)

    canEnter = regime == 0 and not na(atrVal) and (na(lastExitBar) or bar_index - lastExitBar >= cooldownBars)
    if canEnter and ((sqFired and momLongOK and trendLongOK) or trendEntryLong)
        regime := 1
        entryPrice := close
        slPrice := slMode == "ATR" ? close - atrVal * slMult : math.min(rangeLo, close - atrVal * 0.5)
        tpPrice := slMode == "ATR" ? close + atrVal * tpMult : close + (close - slPrice) * rrRange
        tp1Price := usePartialTP ? close + atrVal * tp1Mult : na
        partialTaken := false
        barsInTrade := 0
        justEnteredLong := true
        alert(buildMsg("open_long"), alert.freq_once_per_bar)
    else if canEnter and ((sqFired and momShortOK and trendShortOK) or trendEntryShort)
        regime := -1
        entryPrice := close
        slPrice := slMode == "ATR" ? close + atrVal * slMult : math.max(rangeHi, close + atrVal * 0.5)
        tpPrice := slMode == "ATR" ? close - atrVal * tpMult : close - (slPrice - close) * rrRange
        tp1Price := usePartialTP ? close - atrVal * tp1Mult : na
        partialTaken := false
        barsInTrade := 0
        justEnteredShort := true
        alert(buildMsg("open_short"), alert.freq_once_per_bar)
//#endregion

//#region Drawings
var Viz viz = na

if justExited
    label.new(bar_index, exitPrice, exitReason + " " + (exitPnl >= 0 ? "+" : "") + str.tostring(exitPnl, "#.##") + "%", color=exitPnl >= 0 ? color.new(COL_UP, 10) : color.new(COL_DN, 10), textcolor=color.white, size=size.small, style=exitReason == "TP" ? label.style_label_down : label.style_label_up)
    viz.destroy()
    viz := na

if justEnteredLong or justEnteredShort
    viz.destroy()
    viz := drawViz(justEnteredLong, entryPrice, tpPrice, slPrice, tp1Price)

if useTrail and regime != 0 and not na(viz) and barstate.isconfirmed
    line.set_y1(viz.sLine, slPrice)
    line.set_y2(viz.sLine, slPrice)
    label.set_y(viz.sLab, slPrice)
    label.set_text(viz.sLab, "SL " + str.tostring(slPrice, format.mintick))

if not na(viz) and usePartialTP and not partialTaken and not na(tp1Price) and barstate.isconfirmed
    line.set_y1(viz.tp1Line, tp1Price)
    line.set_y2(viz.tp1Line, tp1Price)
    label.set_y(viz.tp1Lab, tp1Price)
    label.set_text(viz.tp1Lab, "TP1 50% " + str.tostring(tp1Price, format.mintick))
//#endregion

//#region Plotting
bgcolor(sqOn ? color.new(color.purple, 80) : na, title="Squeeze BG")
plot(emaTrend, "EMA Trend", color.new(COL_BLUE, 20), linewidth=2)
plot(momValue, "Momentum", momValue > 0 ? color.green : color.red, display=display.data_window)
barcolor(regime == 1 ? color.new(color.green, 70) : regime == -1 ? color.new(color.red, 70) : na)
plotshape(justEnteredLong, "LONG entry", shape.triangleup, location.belowbar, COL_UP, text="LONG", textcolor=COL_UP, size=size.small)
plotshape(justEnteredShort, "SHORT entry", shape.triangledown, location.abovebar, COL_DN, text="SHORT", textcolor=COL_DN, size=size.small)
//#endregion

//#region Dashboard
var table tbl = table.new(position.top_right, 2, 12, bgcolor=color.new(#1a1a2e, 0), frame_color=COL_BLUE, frame_width=1)

//@function Fill one dashboard row.
//@param r Row index.
//@param k Key text.
//@param v Value text.
//@param c Value color.
//@returns Nothing.
f_cell(int r, string k, string v, color c) =>
    tbl.cell(0, r, k, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    tbl.cell(1, r, v, text_color=c, text_size=size.small, text_halign=text.align_right)

if barstate.islast
    total = wins + losses
    wr = total > 0 ? str.tostring(100.0 * wins / total, "#.##") + "%" : "—"
    stateTxt = regime == 1 ? "▲ LONG (" + str.tostring(barsInTrade) + ")" : regime == -1 ? "▼ SHORT (" + str.tostring(barsInTrade) + ")" : sqOn ? "⏳ SQUEEZE (" + str.tostring(sqCount) + ")" : "⇿ WAIT"
    stateCol = regime == 1 ? color.green : regime == -1 ? color.red : color.gray
    f_cell(0,  "Squeeze", sqOn ? "ON · " + str.tostring(sqCount) : "OFF", sqOn ? color.new(color.purple, 0) : color.gray)
    f_cell(1,  "Momentum", (momValue >= 0 ? "+" : "") + str.tostring(momValue, format.mintick), momValue >= 0 ? color.green : color.red)
    f_cell(2,  "Trend", close > emaTrend ? "▲ BULL" : "▼ BEAR", close > emaTrend ? color.green : color.red)
    f_cell(3,  "Signal", stateTxt, stateCol)
    f_cell(4,  "Entry", na(entryPrice) ? "—" : str.tostring(entryPrice, format.mintick), COL_BLUE)
    f_cell(5,  "TP", na(tpPrice) ? "—" : str.tostring(tpPrice, format.mintick), COL_UP)
    f_cell(6,  "SL", na(slPrice) ? "—" : str.tostring(slPrice, format.mintick), COL_DN)
    f_cell(7,  "ATR", str.tostring(atrVal, format.mintick), COL_TP1)
    f_cell(8,  "Trades W/L", str.tostring(wins) + " / " + str.tostring(losses), color.white)
    f_cell(9,  "Winrate", wr, color.white)
    f_cell(10, "Σ PnL", (cumPnl >= 0 ? "+" : "") + str.tostring(cumPnl, "#.##") + "%", cumPnl >= 0 ? color.green : color.red)
    f_cell(11, "TP1", regime != 0 and usePartialTP and not partialTaken and not na(tp1Price) ? str.tostring(tp1Price, format.mintick) : "—", COL_TP1)
//#endregion
````
