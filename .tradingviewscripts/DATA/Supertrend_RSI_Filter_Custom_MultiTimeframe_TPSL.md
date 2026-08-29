<!-- tradingview-pine-id: PUB;fb32e12019bf4e8e8db346ee84e89334 -->
<!-- tradingviewscripts-format: 1 -->
# Supertrend + RSI Filter (Custom Multi-Timeframe TP/SL)

Source: https://www.tradingview.com/script/mRCQVL7F/

## Description

OverviewThe Supertrend + RSI Filter (Advanced TP/SL) is a comprehensive trend-following indicator designed for TradingView (Pine Script v5). It combines the trend-detection power of the Supertrend with a dynamic RSI Momentum Filter to eliminate low-probability setups in overbought or oversold conditions.Unlike standard indicators that clear historical lines upon new signals, this script implements a Pine Script v5 Custom Type & Array-based Position Management System. It tracks every trade independently, drawing dynamic Entry, Take Profit (TP), and Stop Loss (SL) lines with centered price labels. Position lines persist on the chart and are ONLY removed when price action officially hits the TP or SL level.
[https://www.tradingview.com/x/fOBEXYJd/](https://www.tradingview.com/x/fOBEXYJd/)
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
[https://www.tradingview.com/x/UB3l8bQq/](https://www.tradingview.com/x/UB3l8bQq/)
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

---

## Source Code

````pine
//@version=6
indicator('Supertrend + RSI Filter (Custom Multi-Timeframe TP/SL)', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ==========================================
// 1. INPUT PARAMETERS
// ==========================================
group_auto = '--- Auto Timeframe Settings ---'
autoAdapt = input.bool(true, 'Tự động đổi thông số theo M5, M15, M30, H1', group = group_auto, tooltip = 'Áp dụng cấu hình riêng cho M5, M15, M30, H1\n[14.0, 2.0, 1.5, 10.0] // M5\n[10.0, 1.0, 1.0, 10.0] // M15\n[10.0, 2.5, 2.5, 4.0]  // M30\n[10.0, 1.5, 2.5, 8.0]  // H1 (60 phút)') // M5\n[10.0, 1.0, 1.0, 10.0] // M15\n[10.0, 2.5, 2.5, 4.0]  // M30\n[10.0, 1.5, 2.5, 8.0]  // H1 (60 phút)")

group_st = '--- Manual Settings (Dùng khi tắt Auto) ---'
atrPeriod = input.int(14, 'ATR Length', group = group_st)
factor = input.float(3.0, 'Multiplier', group = group_st)
slAtrMult = input.float(1.5, 'SL (x ATR)', group = group_st)
tpAtrMult = input.float(3.0, 'TP (x ATR)', group = group_st)

group_rsi = '--- RSI Filter Settings (Giữ nguyên) ---'
useRSIFilter = input.bool(true, 'Enable RSI Filter', group = group_rsi)
rsiPeriod = input.int(14, 'RSI Period', group = group_rsi)
rsiOverbought = input.float(70.0, 'Avoid BUY when RSI >', group = group_rsi)
rsiOversold = input.float(30.0, 'Avoid SELL when RSI <', group = group_rsi)

group_dash = '--- Dashboard Settings ---'
showDashboard = input.bool(true, 'Show Statistics Dashboard', group = group_dash)

// ==========================================
// 1.5 CUSTOM 4 TIMEFRAMES LOGIC [ATR, Factor, SL, TP]
// ==========================================
// Xác định thông số theo đúng yêu cầu: M5, M15, M30, H1
// Định dạng: [ATR, Multiplier, SL, TP]
[autoAtr, autoFactor, autoSl, autoTp] = switch  // M5
    timeframe.isintraday and timeframe.multiplier == 5 => [14.0, 2.0, 1.5, 10.0]
    timeframe.isintraday and timeframe.multiplier == 15 => [10.0, 1.0, 1.0, 10.0] // M15
    timeframe.isintraday and timeframe.multiplier == 30 => [10.0, 2.5, 2.5, 4.0] // M30
    timeframe.isintraday and timeframe.multiplier == 60 => [10.0, 1.5, 2.5, 8.0] // H1 (60 phút)
    => [14, 3.0, 1.5, 3.0] // Mặc định cho khung khác

finalAtr = autoAdapt ? autoAtr : atrPeriod
finalFactor = autoAdapt ? autoFactor : factor
finalSlMult = autoAdapt ? autoSl : slAtrMult
finalTpMult = autoAdapt ? autoTp : tpAtrMult

// ==========================================
// 2. INDICATOR CALCULATIONS
// ==========================================
[stValue, stDirection] = ta.supertrend(finalFactor, int(finalAtr))
atrVal = ta.atr(int(finalAtr))
rsiVal = ta.rsi(close, rsiPeriod)

//plot(stDirection == -1 ? stValue : na, "Supertrend Up", color=color.green, linewidth=2)
//plot(stDirection == 1 ? stValue : na, "Supertrend Down", color=color.red, linewidth=2)

rawBuy = stDirection[1] == 1 and stDirection == -1
rawSell = stDirection[1] == -1 and stDirection == 1

rsiBuyCond = not useRSIFilter or rsiVal <= rsiOverbought
rsiSellCond = not useRSIFilter or rsiVal >= rsiOversold

buySignal = rawBuy and rsiBuyCond
sellSignal = rawSell and rsiSellCond

plotshape(buySignal, title = 'Buy Signal', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small)
plotshape(sellSignal, title = 'Sell Signal', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)

// ==========================================
// 3. TRADE LOGIC & POSITION MANAGEMENT
// ==========================================
type Position
	int dir
	float entryPrice
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

var float dailyProfitPoints = 0.0
var int currentDay = -1
int today = dayofmonth(time, 'UTC+7')

if today != currentDay
    dailyProfitPoints := 0.0
    currentDay := today
    currentDay

if buySignal
    float ePrice = close
    float sl = ePrice - finalSlMult * atrVal
    float tp = ePrice + finalTpMult * atrVal

    line le = line.new(bar_index, ePrice, bar_index, ePrice, color = color.gray, style = line.style_solid)
    line lt = line.new(bar_index, tp, bar_index, tp, color = color.green, style = line.style_dashed)
    line ls = line.new(bar_index, sl, bar_index, sl, color = color.red, style = line.style_dashed)

    string txtE = 'Entry: ' + str.tostring(ePrice, format.mintick)
    string txtT = 'TP: ' + str.tostring(tp, format.mintick)
    string txtS = 'SL: ' + str.tostring(sl, format.mintick)

    label lbe = label.new(bar_index, ePrice, txtE, style = label.style_none, textcolor = color.gray, size = size.large)
    label lbt = label.new(bar_index, tp, txtT, style = label.style_none, textcolor = color.green, size = size.large)
    label lbs = label.new(bar_index, sl, txtS, style = label.style_none, textcolor = color.red, size = size.large)

    float floatPips = (close - ePrice) / (syminfo.mintick * 10)
    bool isProf = floatPips >= 0
    string liveTxt = (isProf ? '+' : '') + str.tostring(floatPips, '#.#') + ' pip'
    color liveBgColor = isProf ? color.green : color.red
    label lbLive = label.new(bar_index + 1, close, liveTxt, color = liveBgColor, textcolor = color.white, style = label.style_label_left, size = size.large)

    array.push(activePositions, Position.new(1, ePrice, tp, sl, bar_index, le, lt, ls, lbe, lbt, lbs, lbLive))

else if sellSignal
    float ePrice = close
    float sl = ePrice + finalSlMult * atrVal
    float tp = ePrice - finalTpMult * atrVal

    line le = line.new(bar_index, ePrice, bar_index, ePrice, color = color.gray, style = line.style_solid)
    line lt = line.new(bar_index, tp, bar_index, tp, color = color.green, style = line.style_dashed)
    line ls = line.new(bar_index, sl, bar_index, sl, color = color.red, style = line.style_dashed)

    string txtE = 'Entry: ' + str.tostring(ePrice, format.mintick)
    string txtT = 'TP: ' + str.tostring(tp, format.mintick)
    string txtS = 'SL: ' + str.tostring(sl, format.mintick)

    label lbe = label.new(bar_index, ePrice, txtE, style = label.style_none, textcolor = color.gray, size = size.large)
    label lbt = label.new(bar_index, tp, txtT, style = label.style_none, textcolor = color.green, size = size.large)
    label lbs = label.new(bar_index, sl, txtS, style = label.style_none, textcolor = color.red, size = size.large)

    float floatPips = (ePrice - close) / (syminfo.mintick * 10)
    bool isProf = floatPips >= 0
    string liveTxt = (isProf ? '+' : '') + str.tostring(floatPips, '#.#') + ' pip'
    color liveBgColor = isProf ? color.green : color.red
    label lbLive = label.new(bar_index + 1, close, liveTxt, color = liveBgColor, textcolor = color.white, style = label.style_label_left, size = size.large)

    array.push(activePositions, Position.new(-1, ePrice, tp, sl, bar_index, le, lt, ls, lbe, lbt, lbs, lbLive))

if array.size(activePositions) > 0
    for i = array.size(activePositions) - 1 to 0 by 1
        Position p = array.get(activePositions, i)
        bool isClosed = false
        bool isWin = false
        float exitPrice = na
        float pnlPoints = 0.0

        if p.dir == 1
            if high >= p.tpPrice
                wins := wins + 1
                totalTrades := totalTrades + 1
                pnlPoints := p.tpPrice - p.entryPrice
                totalProfitPoints := totalProfitPoints + pnlPoints
                exitPrice := p.tpPrice
                isWin := true
                isClosed := true
                isClosed
            else if low <= p.slPrice
                losses := losses + 1
                totalTrades := totalTrades + 1
                pnlPoints := p.entryPrice - p.slPrice
                totalProfitPoints := totalProfitPoints - pnlPoints
                exitPrice := p.slPrice
                isWin := false
                isClosed := true
                isClosed

        else if p.dir == -1
            if low <= p.tpPrice
                wins := wins + 1
                totalTrades := totalTrades + 1
                pnlPoints := p.entryPrice - p.tpPrice
                totalProfitPoints := totalProfitPoints + pnlPoints
                exitPrice := p.tpPrice
                isWin := true
                isClosed := true
                isClosed
            else if high >= p.slPrice
                losses := losses + 1
                totalTrades := totalTrades + 1
                pnlPoints := p.slPrice - p.entryPrice
                totalProfitPoints := totalProfitPoints - pnlPoints
                exitPrice := p.slPrice
                isWin := false
                isClosed := true
                isClosed

        if isClosed
            dailyProfitPoints := dailyProfitPoints + pnlPoints

            float pipsVal = pnlPoints / (syminfo.mintick * 10)
            string pnlTxt = (isWin ? '+ ' : '- ') + str.tostring(pipsVal, '#.#') + ' pip'
            color pnlColor = isWin ? color.green : color.red

            label.new(p.startBar, exitPrice, pnlTxt, textcolor = pnlColor, style = label.style_none, size = size.large)
            line.new(x1 = p.startBar, y1 = exitPrice, x2 = bar_index, y2 = exitPrice, color = pnlColor, style = line.style_dotted, width = 2)

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
            string livePnlTxt = (isProfit ? '+' : '') + str.tostring(curPips, '#.#') + ' pip'
            color livePnlColor = isProfit ? color.green : color.red

            label.set_xy(p.lblLivePnL, bar_index + 1, close)
            label.set_text(p.lblLivePnL, livePnlTxt)
            label.set_color(p.lblLivePnL, livePnlColor)

// ==========================================
// 4. STATISTICS DASHBOARD
// ==========================================
var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(color.black, 20), border_color = color.gray, border_width = 1)

if showDashboard and barstate.islast
    winrate = totalTrades > 0 ? wins / totalTrades * 100.0 : 0.0
    totalPips = totalProfitPoints / (syminfo.mintick * 10)
    dailyPips = dailyProfitPoints / (syminfo.mintick * 10)

    table.cell(dash, 0, 0, 'Statistics', text_color = color.white, bgcolor = color.blue)
    table.cell(dash, 1, 0, 'Value', text_color = color.white, bgcolor = color.blue)

    table.cell(dash, 0, 1, 'Win Rate', text_color = color.white)
    table.cell(dash, 1, 1, str.tostring(winrate, '#.#') + '%', text_color = color.green)

    table.cell(dash, 0, 2, 'Total Trades', text_color = color.white)
    table.cell(dash, 1, 2, str.tostring(totalTrades), text_color = color.white)

    table.cell(dash, 0, 3, 'Winning Trades', text_color = color.white)
    table.cell(dash, 1, 3, str.tostring(wins), text_color = color.lime)

    table.cell(dash, 0, 4, 'Losing Trades', text_color = color.white)
    table.cell(dash, 1, 4, str.tostring(losses), text_color = color.red)

    table.cell(dash, 0, 5, 'Total Profit', text_color = color.white)
    table.cell(dash, 1, 5, str.tostring(totalPips, '#.#') + ' pip', text_color = totalPips >= 0 ? color.yellow : color.red)

    table.cell(dash, 0, 6, 'Today\'s Profit', text_color = color.white)
    table.cell(dash, 1, 6, str.tostring(dailyPips, '#.#') + ' pip', text_color = dailyPips >= 0 ? color.rgb(0, 255, 8) : color.red)

    table.cell(dash, 0, 7, 'Auto Settings', text_color = color.white)
    table.cell(dash, 1, 7, autoAdapt ? 'ON' : 'OFF', text_color = autoAdapt ? color.green : color.gray)

    table.cell(dash, 0, 8, 'RSI Filter', text_color = color.white)
    table.cell(dash, 1, 8, useRSIFilter ? 'ON' : 'OFF', text_color = useRSIFilter ? color.green : color.red)
````
