# Supertrend + RSI Filter (Advanced TP/SL)

- url: https://www.tradingview.com/script/mRCQVL7F/
- type: indicator
- pine_id: PUB;fb32e12019bf4e8e8db346ee84e89334
- version: 4.0

## Description

OverviewThe Supertrend + RSI Filter (Advanced TP/SL) is a comprehensive trend-following indicator designed for TradingView (Pine Script v5). It combines the trend-detection power of the Supertrend with a dynamic RSI Momentum Filter to eliminate low-probability setups in overbought or oversold conditions.Unlike standard indicators that clear historical lines upon new signals, this script implements a Pine Script v5 Custom Type & Array-based Position Management System. It tracks every trade independently, drawing dynamic Entry, Take Profit (TP), and Stop Loss (SL) lines with centered price labels. Position lines persist on the chart and are ONLY removed when price action officially hits the TP or SL level.
[url=https://www.tradingview.com/x/fOBEXYJd/]https://www.tradingview.com/x/fOBEXYJd/[/url]
Comprehensive Feature List
Supertrend Trend Detection:
Utilizes Average True Range (ATR) to measure volatility and establish dynamic trailing stop bands for precise trend-direction identification.

RSI Momentum Filtering:
- Buy Filter: Suppresses BUY signals when RSI exceeds the overbought threshold (Default: >70) to prevent buying at local tops.
- Sell Filter: Suppresses SELL signals when RSI drops below the oversold threshold (Default: <30) to prevent selling at local bottoms.
Can be toggled ON/OFF in the settings menu.

Multi-Position Tracking Arrays:
- Employs custom data structures () stored in an  to track multiple open trades concurrently. type Position array
- Persistent Lines: Entry (Solid Gray), Take Profit (Dashed Green), and Stop Loss (Dashed Red) lines remain on the chart through opposite trend changes until hit. - Centered Price Labels: Displays label text (, , ) dynamically anchored at the midpoint of each active position line. Entry: XTP: YSL: Z
- Individual Removal: When a specific trade hits its TP or SL target, its corresponding lines and labels are erased immediately without affecting other active trades.
On-Chart Performance Dashboard:
- Displays an updated summary table in the top-left corner of the chart.
- Metrics Included:
Win Rate (%): Percentage of closed trades hitting TP.
Total Trades: Total number of completed historical signals.
Winning & Losing Trades: Count of successful vs. failed setups.
Total Profit (Pips): Cumulative net profit/loss expressed in pips.
RSI Filter Status: Visual indicator showing whether the filter is active ( / ).ONOFF

Dynamic & Multi-Parameter Alert System:
Uses Pine Script’s  function to output real-time formatted text messages containing key execution metrics: alert()
Symbol / Ticker
Timeframe
Exact Entry Price
Target Take Profit Price
Target Stop Loss Price
including warnings. alertcondition()

Trading & Exit Logic
1. BUY Setup
Trigger: Supertrend flips from Bearish (Red) to Bullish (Green).
Filter Condition: $\text{RSI} \le \text{Overbought Threshold}$ (or RSI Filter disabled).
Entry: Closing price of the signal bar.
Stop Loss: $\text{Entry} - (\text{ATR} \times \text{SL Multiplier})$
Take Profit: $\text{Entry} + (\text{ATR} \times \text{TP Multiplier})$
2. SELL Setup
Trigger: Supertrend flips from Bullish (Green) to Bearish (Red).
Filter Condition: $\text{RSI} \ge \text{Oversold Threshold}$ (or RSI Filter disabled).
Entry: Closing price of the signal bar.
Stop Loss: $\text{Entry} + (\text{ATR} \times \text{SL Multiplier})$
Take Profit: $\text{Entry} - (\text{ATR} \times \text{TP Multiplier})$
3. Exit & Removal Logic
On every historical and real-time bar, the script checks if  or  crosses the target levels: High Low
BUY Hit TP: $\text{High} \ge \text{TP Price}$
BUY Hit SL: $\text{Low} \le \text{SL Price}$
SELL Hit TP: $\text{Low} \le \text{TP Price}$
SELL Hit SL: $\text{High} \ge \text{SL Price}$
Upon trigger, the specific position is logged into the performance table, and its lines/labels are deleted.

Settings & Inputs 
[url=https://www.tradingview.com/x/UB3l8bQq/]https://www.tradingview.com/x/UB3l8bQq/[/url]
How to Set Up Dynamic Alerts
Apply the indicator to your desired chart.
Click the Alerts icon (Clock) on TradingView $\rightarrow$ Create Alert.
Under Condition, select: .Supertrend + RSI Filter (Advanced TP/SL)
Select Any alert() function call in the dropdown menu.
Set the frequency to Once Per Bar Close.
Click Create. You will receive detailed alerts formatted like this:
🚀 BUY SIGNAL
Symbol: BTCUSDT
Timeframe: 15
Entry: 64250.50
TP: 65120.00
SL: 63815.25

Risk Disclosure & Limitations
Choppy / Ranging Markets: As a trend-following tool, Supertrend may produce consecutive false breakouts when the market moves sideways.

Backtest Statistics Notice: The statistics table measures theoretical performance based on bar high/low historical data. It does not account for slippage, spread, overnight funding fees, or broker commissions.

Repainting Disclaimer: Signals and position calculations are confirmed on bar close ( / ) to strictly avoid repainting. barstate. islastfreq_once_per_bar_close

Financial Disclaimer: This script is developed strictly for educational and analytical purposes. It does not constitute financial or investment advice. Always manage your risk responsibly.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 

//@version=6
indicator('Supertrend MTF Strategy & Dashboard (Flexible SL/TP)', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ==========================================
// 1. INPUT PARAMETERS
// ==========================================
group_st = '--- Supertrend Settings ---'
atrPeriod = input.int(11, 'ATR Length', group = group_st, minval = 1, tooltip = 'Used for Supertrend calculation and ATR calculations')
factor = input.float(1.0, 'Multiplier', group = group_st, minval = 0.1)

group_risk = '--- Stop Loss & Take Profit Config ---'
slMethod = input.string('ATR', 'Stop Loss Method', options = ['ATR', 'Swing (5 Candles)'], group = group_risk)
slAtrMult = input.float(3, 'SL Multiplier (if ATR SL used)', group = group_risk, minval = 0.1)
slLookback = input.int(5, 'Swing SL Lookback', group = group_risk, minval = 1, tooltip = 'Number of bars to look back for the highest/lowest price to set SL.')

tpMethod = input.string('ATR', 'Take Profit Method', options = ['ATR', 'Risk:Reward (RR)'], group = group_risk)
tpAtrMult = input.float(9, 'TP Multiplier (if ATR TP used)', group = group_risk, minval = 0.1)
rrRatio = input.float(30, 'Risk:Reward Ratio (if RR TP used)', group = group_risk, minval = 0.1)

exitOnReversal = input.bool(true, 'Exit on Reversal', group = group_risk, tooltip = 'Close current active trade when an opposite signal appears.')
maxTrades = input.int(5, 'Max Active Trades', group = group_risk, minval = 1, maxval = 20)

// ------------------------------------------
// MTF CHECKBOXES (TÙY CHỌN KHUNG THỜI GIAN)
// ------------------------------------------
group_mtf = '--- Multi-Timeframe (MTF) Filter ---'
useMTF = input.bool(true, 'Enable MTF Consensus Filtering', group = group_mtf, tooltip = 'If disabled, uses only current chart timeframe.')
useH4 = input.bool(true, 'Filter H4', group = group_mtf)
useH1 = input.bool(true, 'Filter H1', group = group_mtf)
useM30 = input.bool(true, 'Filter M30', group = group_mtf)
useM15 = input.bool(true, 'Filter M15', group = group_mtf)
useM5 = input.bool(true, 'Filter M5', group = group_mtf)
useM1 = input.bool(true, 'Filter M1', group = group_mtf)

group_dash = '--- Dashboard Settings ---'
showDashboard = input.bool(true, 'Show Statistics Dashboard', group = group_dash)

// ==========================================
// 2. INDICATOR & MTF CALCULATIONS
// ==========================================
[stValue, stDirection] = ta.supertrend(factor, atrPeriod)
atrVal = nz(ta.atr(atrPeriod), ta.tr)

plot(stDirection == -1 ? stValue : na, 'Supertrend Up', color = color.green, linewidth = 2)
plot(stDirection == 1 ? stValue : na, 'Supertrend Down', color = color.red, linewidth = 2)

dirH4 = request.security(syminfo.tickerid, '240', stDirection)
dirH1 = request.security(syminfo.tickerid, '60', stDirection)
dirM30 = request.security(syminfo.tickerid, '30', stDirection)
dirM15 = request.security(syminfo.tickerid, '15', stDirection)
dirM5 = request.security(syminfo.tickerid, '5', stDirection)
dirM1 = request.security(syminfo.tickerid, '1', stDirection)

// Logic: Bỏ qua kiểm tra nếu khung thời gian bị "bỏ tích" (false)
isAllUp = (not useH4 or dirH4 == -1) and (not useH1 or dirH1 == -1) and (not useM30 or dirM30 == -1) and (not useM15 or dirM15 == -1) and (not useM5 or dirM5 == -1) and (not useM1 or dirM1 == -1)
isAllDown = (not useH4 or dirH4 == 1) and (not useH1 or dirH1 == 1) and (not useM30 or dirM30 == 1) and (not useM15 or dirM15 == 1) and (not useM5 or dirM5 == 1) and (not useM1 or dirM1 == 1)

localBuy = stDirection[1] == 1 and stDirection == -1
localSell = stDirection[1] == -1 and stDirection == 1

buySignal = useMTF ? isAllUp and not isAllUp[1] : localBuy
sellSignal = useMTF ? isAllDown and not isAllDown[1] : localSell

plotshape(buySignal, title = 'Buy Signal', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small)
plotshape(sellSignal, title = 'Sell Signal', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)

lowestSL = nz(ta.lowest(low, slLookback), low)
highestSL = nz(ta.highest(high, slLookback), high)

// ==========================================
// 3. TRADE LOGIC & POSITION MANAGEMENT
// ==========================================
type Position
	int dir
	float entryPrice
	float eHigh
	float eLow
	float eAtr
	float tpPrice
	float slPrice
	int startBar
	line lineE
	line lineT
	line lineS
	label lblE
	label lblT
	label lblS
	label lblLivePnL

var activePositions = array.new<Position>()

var int totalTrades = 0
var int wins = 0
var int losses = 0
var float totalProfitPoints = 0.0
var float grossProfit = 0.0
var float grossLoss = 0.0

var float dailyProfitPoints = 0.0
var int currentDay = -1
int today = dayofmonth(time, 'UTC+7')

if today != currentDay
    dailyProfitPoints := 0.0
    currentDay := today
    currentDay

bool canEnterBuy = buySignal and array.size(activePositions) < maxTrades
bool canEnterSell = sellSignal and array.size(activePositions) < maxTrades

// ENTER BUY
if canEnterBuy
    float ePrice = close
    float sl = 0.0
    float tp = 0.0

    if slMethod == 'ATR'
        sl := ePrice - slAtrMult * atrVal
        sl
    else
        sl := lowestSL
        if sl >= ePrice
            sl := ePrice - atrVal * 0.5
            sl

    float riskDist = math.max(math.abs(ePrice - sl), syminfo.mintick)

    if tpMethod == 'ATR'
        tp := ePrice + tpAtrMult * atrVal
        tp
    else
        tp := ePrice + riskDist * rrRatio
        tp

    float slPips = math.abs(ePrice - sl) / (syminfo.mintick * 10)
    float tpPips = math.abs(tp - ePrice) / (syminfo.mintick * 10)

    line le = line.new(bar_index, ePrice, bar_index, ePrice, color = color.gray, style = line.style_solid)
    line lt = line.new(bar_index, tp, bar_index, tp, color = color.green, style = line.style_dashed)
    line ls = line.new(bar_index, sl, bar_index, sl, color = color.red, style = line.style_dashed)

    string txtE = 'Entry: ' + str.tostring(ePrice, format.mintick)
    string txtT = 'TP: ' + str.tostring(tp, format.mintick) + ' -- ' + str.tostring(tpPips, '#.#') + ' pips'
    string txtS = 'SL: ' + str.tostring(sl, format.mintick) + ' -- ' + str.tostring(slPips, '#.#') + ' pips'

    label lbe = label.new(bar_index, ePrice, txtE, style = label.style_none, textcolor = color.gray, size = size.small)
    label lbt = label.new(bar_index, tp, txtT, style = label.style_none, textcolor = color.green, size = size.small)
    label lbs = label.new(bar_index, sl, txtS, style = label.style_none, textcolor = color.red, size = size.small)

    float floatPips = (close - ePrice) / (syminfo.mintick * 10)
    bool isProf = floatPips >= 0
    string liveTxt = (isProf ? '+' : '') + str.tostring(floatPips, '#.#') + ' pips'
    color liveBgColor = isProf ? color.green : color.red
    label lbLive = label.new(bar_index + 1, close, liveTxt, color = liveBgColor, textcolor = color.white, style = label.style_label_left, size = size.small)

    array.push(activePositions, Position.new(1, ePrice, high, low, atrVal, tp, sl, bar_index, le, lt, ls, lbe, lbt, lbs, lbLive))

// ENTER SELL
else if canEnterSell
    float ePrice = close
    float sl = 0.0
    float tp = 0.0

    if slMethod == 'ATR'
        sl := ePrice + slAtrMult * atrVal
        sl
    else
        sl := highestSL
        if sl <= ePrice
            sl := ePrice + atrVal * 0.5
            sl

    float riskDist = math.max(math.abs(sl - ePrice), syminfo.mintick)

    if tpMethod == 'ATR'
        tp := ePrice - tpAtrMult * atrVal
        tp
    else
        tp := ePrice - riskDist * rrRatio
        tp

    float slPips = math.abs(sl - ePrice) / (syminfo.mintick * 10)
    float tpPips = math.abs(ePrice - tp) / (syminfo.mintick * 10)

    line le = line.new(bar_index, ePrice, bar_index, ePrice, color = color.gray, style = line.style_solid)
    line lt = line.new(bar_index, tp, bar_index, tp, color = color.green, style = line.style_dashed)
    line ls = line.new(bar_index, sl, bar_index, sl, color = color.red, style = line.style_dashed)

    string txtE = 'Entry: ' + str.tostring(ePrice, format.mintick)
    string txtT = 'TP: ' + str.tostring(tp, format.mintick) + ' -- ' + str.tostring(tpPips, '#.#') + ' pips'
    string txtS = 'SL: ' + str.tostring(sl, format.mintick) + ' -- ' + str.tostring(slPips, '#.#') + ' pips'

    label lbe = label.new(bar_index, ePrice, txtE, style = label.style_none, textcolor = color.gray, size = size.small)
    label lbt = label.new(bar_index, tp, txtT, style = label.style_none, textcolor = color.green, size = size.small)
    label lbs = label.new(bar_index, sl, txtS, style = label.style_none, textcolor = color.red, size = size.small)

    float floatPips = (ePrice - close) / (syminfo.mintick * 10)
    bool isProf = floatPips >= 0
    string liveTxt = (isProf ? '+' : '') + str.tostring(floatPips, '#.#') + ' pips'
    color liveBgColor = isProf ? color.green : color.red
    label lbLive = label.new(bar_index + 1, close, liveTxt, color = liveBgColor, textcolor = color.white, style = label.style_label_left, size = size.small)

    array.push(activePositions, Position.new(-1, ePrice, high, low, atrVal, tp, sl, bar_index, le, lt, ls, lbe, lbt, lbs, lbLive))

// MANAGE ACTIVE TRADES
if array.size(activePositions) > 0
    for i = array.size(activePositions) - 1 to 0 by 1
        Position p = array.get(activePositions, i)
        bool isClosed = false
        bool isWin = false
        float pnlPoints = 0.0

        if p.dir == 1
            if high >= p.tpPrice
                pnlPoints := p.tpPrice - p.entryPrice
                isWin := true
                isClosed := true
                isClosed
            else if low <= p.slPrice
                pnlPoints := p.slPrice - p.entryPrice
                isWin := false
                isClosed := true
                isClosed
            else if exitOnReversal and localSell
                pnlPoints := close - p.entryPrice
                isWin := pnlPoints >= 0
                isClosed := true
                isClosed

        else if p.dir == -1
            if low <= p.tpPrice
                pnlPoints := p.entryPrice - p.tpPrice
                isWin := true
                isClosed := true
                isClosed
            else if high >= p.slPrice
                pnlPoints := p.entryPrice - p.slPrice
                isWin := false
                isClosed := true
                isClosed
            else if exitOnReversal and localBuy
                pnlPoints := p.entryPrice - close
                isWin := pnlPoints >= 0
                isClosed := true
                isClosed

        if isClosed
            totalTrades := totalTrades + 1
            if isWin
                wins := wins + 1
                wins
            else
                losses := losses + 1
                losses

            totalProfitPoints := totalProfitPoints + pnlPoints
            dailyProfitPoints := dailyProfitPoints + pnlPoints

            if pnlPoints > 0
                grossProfit := grossProfit + pnlPoints
                grossProfit
            else if pnlPoints < 0
                grossLoss := grossLoss + math.abs(pnlPoints)
                grossLoss

            float pipsVal = pnlPoints / (syminfo.mintick * 10)

            string pnlTxt = (pipsVal > 0 ? '+' : '') + str.tostring(pipsVal, '#.#') + ' pips'
            color pnlColor = pipsVal >= 0 ? color.green : color.red

            float yPos = p.dir == 1 ? p.eLow - p.eAtr * 0.9 : p.eHigh + p.eAtr * 0.9
            label.new(p.startBar, yPos, pnlTxt, textcolor = pnlColor, style = label.style_none, size = size.small)

            line.delete(p.lineE)
            line.delete(p.lineT)
            line.delete(p.lineS)
            label.delete(p.lblE)
            label.delete(p.lblT)
            label.delete(p.lblS)
            label.delete(p.lblLivePnL)

            array.remove(activePositions, i)
        else
            int extBar = bar_index + 3
            int midBar = int((p.startBar + extBar) / 2)

            line.set_x2(p.lineE, extBar)
            line.set_x2(p.lineT, extBar)
            line.set_x2(p.lineS, extBar)

            label.set_x(p.lblE, midBar)
            label.set_x(p.lblT, midBar)
            label.set_x(p.lblS, midBar)

            float curPips = (p.dir == 1 ? close - p.entryPrice : p.entryPrice - close) / (syminfo.mintick * 10)
            bool isProfit = curPips >= 0
            string livePnlTxt = (isProfit ? '+' : '') + str.tostring(curPips, '#.#') + ' pips'
            color livePnlColor = isProfit ? color.green : color.red

            label.set_xy(p.lblLivePnL, bar_index + 1, close)
            label.set_text(p.lblLivePnL, livePnlTxt)
            label.set_color(p.lblLivePnL, livePnlColor)

// ==========================================
// 4. STATISTICS DASHBOARD
// ==========================================
var table dash = table.new(position.top_right, 2, 8, bgcolor = color.new(color.black, 20), border_color = color.gray, border_width = 1)

if showDashboard and barstate.islast
    winrate = totalTrades > 0 ? wins / totalTrades * 100.0 : 0.0
    totalPips = totalProfitPoints / (syminfo.mintick * 10)
    dailyPips = dailyProfitPoints / (syminfo.mintick * 10)
    pf = grossLoss > 0 ? grossProfit / grossLoss : grossProfit > 0 ? 99.99 : 0.0

    table.cell(dash, 0, 0, 'Statistics', text_color = color.white, bgcolor = color.blue)
    table.cell(dash, 1, 0, 'Value', text_color = color.white, bgcolor = color.blue)
    table.cell(dash, 0, 1, 'Win Rate', text_color = color.white)
    table.cell(dash, 1, 1, str.tostring(winrate, '#.#') + '%', text_color = color.green)
    table.cell(dash, 0, 2, 'Profit Factor', text_color = color.white)
    table.cell(dash, 1, 2, str.tostring(pf, '#.##'), text_color = pf >= 1.0 ? color.green : color.red)
    table.cell(dash, 0, 3, 'Total Trades', text_color = color.white)
    table.cell(dash, 1, 3, str.tostring(totalTrades), text_color = color.white)
    table.cell(dash, 0, 4, 'Winning Trades', text_color = color.white)
    table.cell(dash, 1, 4, str.tostring(wins), text_color = color.lime)
    table.cell(dash, 0, 5, 'Losing Trades', text_color = color.white)
    table.cell(dash, 1, 5, str.tostring(losses), text_color = color.red)
    table.cell(dash, 0, 6, 'Total Profit', text_color = color.white)
    table.cell(dash, 1, 6, str.tostring(totalPips, '#.#') + ' pips', text_color = totalPips >= 0 ? color.yellow : color.red)
    table.cell(dash, 0, 7, 'Today\'s Profit', text_color = color.white)
    table.cell(dash, 1, 7, str.tostring(dailyPips, '#.#') + ' pips', text_color = dailyPips >= 0 ? color.green : color.red)

// ==========================================
// 5. MTF SCANNER DASHBOARD (Bottom Right)
// ==========================================
var table mtfDash = table.new(position.bottom_right, 6, 1, bgcolor = color.new(color.black, 40), border_color = color.gray, border_width = 1)

if barstate.islast
    // Nếu khung bị tắt, hiển thị chữ màu xám, ngược lại hiển thị màu trend
    colH4 = not useH4 ? color.gray : dirH4 == -1 ? color.lime : color.red
    colH1 = not useH1 ? color.gray : dirH1 == -1 ? color.lime : color.red
    colM30 = not useM30 ? color.gray : dirM30 == -1 ? color.lime : color.red
    colM15 = not useM15 ? color.gray : dirM15 == -1 ? color.lime : color.red
    colM5 = not useM5 ? color.gray : dirM5 == -1 ? color.lime : color.red
    colM1 = not useM1 ? color.gray : dirM1 == -1 ? color.lime : color.red

    table.cell(mtfDash, 0, 0, 'H4', text_color = colH4, text_size = size.normal)
    table.cell(mtfDash, 1, 0, 'H1', text_color = colH1, text_size = size.normal)
    table.cell(mtfDash, 2, 0, 'M30', text_color = colM30, text_size = size.normal)
    table.cell(mtfDash, 3, 0, 'M15', text_color = colM15, text_size = size.normal)
    table.cell(mtfDash, 4, 0, 'M5', text_color = colM5, text_size = size.normal)
    table.cell(mtfDash, 5, 0, 'M1', text_color = colM1, text_size = size.normal)
````
