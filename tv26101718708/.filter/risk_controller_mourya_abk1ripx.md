# Risk Controller | Mourya

- url: https://www.tradingview.com/script/abK1RipX-Risk-Controller-Mourya/
- type: indicator
- pine_id: PUB;9a300f0ebe164f2bb56be41296d14ec1
- version: 1.0

## Description

Risk Controller | Mourya - Complete Indicator Guide

Overview
Risk Controller | Mourya is an institutional-grade, real-time risk management matrix and position layout dashboard built directly onto your chart. Instead of forcing traders to context-switch between spreadsheets and their charting screen, this terminal brings complete mathematical clarity to active position-sizing, trailing stops, real-time tracking, and multi-tier target distributions. Designed for both professional execution and sleek workspace integration, it features absolute flexibility from pure cash or spot accounts to heavily leveraged derivative trades.

How to Use (Setup and Workflow)

* Apply the indicator to your chart and open the settings menu.
* Select your Position Type (Long or Short) and pick your preferred currency symbol from the dropdown menu.
* Enter the exact Quantity or Shares you are trading.
* Enter your Leverage multiplier. If you are using a standard spot or cash account without leverage, enter 0.
* Choose your Brokerage Fee type (Fixed Value or Percentage) and enter the corresponding fee amount so the dashboard can calculate your true net profits.
* Enter your total account balance into the Net Cash Available field to enable automatic account risk percentage tracking.
* Set your levels visually by clicking the price lines directly on your chart to wake up the TradingView drag handles, then drag your Entry, Stop Loss, and up to 4 Take Profit targets to your desired locations.
* If you prefer strict mathematical targets instead of dragging lines, type a value into the Percentage Overrides settings to automatically lock a Take Profit target to an exact asset percentage move.
* Customize your workspace by navigating to the Dashboard Settings to move the terminal to any corner of the screen, scale the overall size from tiny to huge, and select custom colors for the header background, header text, and chart lines.
* For a quick reset when scanning multiple tickers, open the settings menu, click the Defaults button in the bottom left corner, and select Reset Settings to wipe the board clean back to zero.

How it Works (Core Features)

* Interactive Chart Synchronization: Bypasses manual price typing by letting you drag and drop your target lines on the live chart. The dashboard matrix instantly recalculates all metrics the moment you release the line.
* Live P and L Tracking Module: A dedicated real-time row sits beneath your entry, constantly tracking your exact active Profit and Loss, tick distance, and live Return on Equity (ROE) as the market moves tick-by-tick.
* Trailing Stop Loss Support: The mathematical engine adapts instantly. If you drag your Stop Loss line past your Entry price into profit territory, the dashboard flips its internal logic, converting the red loss metrics into secured green profits.
* Percentage Overrides: Overrides your manual chart line placement, locking in exact percentage-based profit targets while keeping the Stop Loss manually adjustable.
* Dynamic Hide Logic: Automatically collapses and hides Take Profit rows 2, 3, and 4 on your dashboard if you leave their values at zero, keeping your screen clutter-free.
* Account Risk Diagnostics: Evaluates your Stop Loss distance against your Net Cash Available to show the exact percentage of your total account at risk. It also flashes a critical margin warning if your required margin exceeds your cash balance.
* Margin and Breakeven Engine: Identifies the actual cash margin required to open the position and calculates the exact asset price you need to hit to exit the trade at absolute zero after all entry and exit brokerage fees are deducted.
* True Return on Equity (ROE): Scales your return metrics accurately. If you input 0 leverage, it mirrors the raw asset movement. If you input leverage, it calculates the amplified return strictly on your invested margin.
* Risk-to-Reward (R:R) Tracking: Instantly evaluates the structural viability of your trade setup by calculating the ratio between your Stop Loss risk and Take Profit 1 potential.
* Wick-Sensitive Hit Engine: Mimics real broker limit fills by actively tracking live high and low wicks instead of waiting for a candle to close. The moment a price touches your Stop Loss or Take Profit, the dashboard row flashes in vivid solid colors (Institutional Green for TP, Red for SL) and the chart label flashes yellow.
* True Market Context Module: Calculates the exact percentage distance between the real-time live price and critical historical extremes. Includes today's High/Low, a mathematically pure 52-Week High/Low (calculated using exactly 252 trading days to account for weekends and holidays), and the All-Time High/Low.
* Context Toggles: Allows you to independently check or uncheck the Day, 52-Week, and All-Time context metrics to save screen space when you do not need them.
* Built-in Settings Tooltips: Every single input in the settings menu features an integrated guide next to the small info icon explaining its exact function and mathematical behavior.

## Source Code

````pine
//@version=6
indicator('Risk Controller | Mourya', overlay = true) 

// ==========================================
// 1. DASHBOARD & ACCOUNT SETTINGS
// ==========================================
grpDash = 'Dashboard Settings'
dashPosIn = input.string('Bottom Right', 'Dashboard Position', options = ['Top Right', 'Bottom Right', 'Top Left', 'Bottom Left', 'Top Center', 'Bottom Center'], group = grpDash, tooltip = 'Moves the visual dashboard to any corner of the screen so it doesn\'t block your candles.')
dashSizeIn = input.string('Small', 'Dashboard Scale (Size)', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge', 'Auto'], group = grpDash, tooltip = 'Scales the overall size of the dashboard text and layout.')

grpCurr = 'Position & Account'
curSym = input.string('$', 'Currency Symbol', options = ['$', '€', '£', '₹', '¥', '฿'], group = grpCurr, tooltip = 'Select the currency symbol used for your P&L calculations.')
netCash = input.float(0.0, 'Net Cash Available (0 = Ignore)', group = grpCurr, tooltip = 'Your total account balance. If entered, the dashboard calculates exactly what % of your account is at risk if SL is hit. Also triggers a warning if Margin exceeds this amount.')
shares = input.float(100.0, 'Quantity / Shares', group = grpCurr, tooltip = 'The number of shares, contracts, or lots you are buying/selling.')
lev = input.float(0.0, 'Leverage (0 = Cash Account)', group = grpCurr, tooltip = 'Enter your broker leverage (e.g., 10 for 10x). Enter 0 for a standard cash/spot account where leverage is not used.')
feeType = input.string('Percentage', 'Brokerage Fee Type', options = ['Fixed Value', 'Percentage'], group = grpCurr, tooltip = 'Fixed Value: A flat fee applied to the whole trade. \nPercentage: A percentage fee calculated on both the entry position value and exit position value.')
feeVal = input.float(0.0, 'Brokerage Value (Value or %)', group = grpCurr, tooltip = 'Enter the fee amount here based on the type selected above.')

// ==========================================
// 2. INTERACTIVE CHART LEVELS
// ==========================================
grp1 = 'Chart Levels (Double Click to Edit)'
posType = input.string('Long', 'Position Type', options = ['Long', 'Short'], group = grp1, tooltip = 'Select Long to profit from price going up. Select Short to profit from price going down.')
entryIn = input.price(0.0, 'Entry Price', group = grp1, tooltip = 'Your actual or planned entry price. Leave at 0 to dynamically use the live market price. Double click the chart line to move it easily.')
slP = input.price(0.0, 'Stop Loss', group = grp1, tooltip = 'The price where your position will be closed at a loss.')
tp1P = input.price(0.0, 'Take Profit 1', group = grp1, tooltip = 'First target to take profit. Also used to calculate your Risk-to-Reward (R:R) Ratio.')
tp2P = input.price(0.0, 'Take Profit 2', group = grp1, tooltip = 'Optional second profit target.')
tp3P = input.price(0.0, 'Take Profit 3', group = grp1, tooltip = 'Optional third profit target.')
tp4P = input.price(0.0, 'Take Profit 4', group = grp1, tooltip = 'Optional fourth profit target.')

grpPct = 'Percentage Overrides (Overrides Price if > 0)'
tp1Pct = input.float(0.0, 'TP1 Target Asset %', group = grpPct, tooltip = 'Type a percentage here (e.g., 5 for 5%) to auto-calculate the target price. This OVERRIDES the manual price line above.')
tp2Pct = input.float(0.0, 'TP2 Target Asset %', group = grpPct, tooltip = 'Overrides manual TP2 price line with an exact percentage move.')
tp3Pct = input.float(0.0, 'TP3 Target Asset %', group = grpPct, tooltip = 'Overrides manual TP3 price line with an exact percentage move.')
tp4Pct = input.float(0.0, 'TP4 Target Asset %', group = grpPct, tooltip = 'Overrides manual TP4 price line with an exact percentage move.')

// ==========================================
// 3. MARKET CONTEXT TOGGLES
// ==========================================
grpMark = 'Market Context Visibility'
showDay = input.bool(true, 'Show Day High / Low', group = grpMark, tooltip = 'Displays how far the current live price is from today\'s highest and lowest points.')
show52W = input.bool(true, 'Show 52W High / Low', group = grpMark, tooltip = 'Displays how far the current live price is from the 52-Week (1 Year / 252 Trading Days) highest and lowest points.')
showATH = input.bool(true, 'Show All-Time High / Low', group = grpMark, tooltip = 'Displays how far the current live price is from the all-time highest and lowest historical prices for this asset.')

// ==========================================
// 4. PRO-GRADE STYLING PALETTE
// ==========================================
grpStyle = 'Line & Brand Customization'
lineThick = input.int(2, 'Line Thickness', minval = 1, maxval = 4, group = grpStyle, tooltip = 'Thickness of the Entry, TP, and SL lines on your chart.')

c_bg = color.rgb(30, 34, 45)
c_border = color.rgb(67, 70, 81)
c_subhead = color.rgb(42, 46, 57)
c_text = color.rgb(209, 212, 220)
c_profit = color.rgb(8, 153, 129)
c_loss = color.rgb(242, 54, 69)

// Customizable Colors
headCol = input.color(color.rgb(41, 98, 255), 'Master Header Background', group = grpStyle, tooltip = 'Background color for the top dashboard title.')
headTxtCol = input.color(color.white, 'Master Header Text Color', group = grpStyle, tooltip = 'Text color for the top dashboard title.')
entryCol = input.color(color.rgb(41, 98, 255), 'Entry Line Color', group = grpStyle, tooltip = 'Color of the Entry line on the chart.')
tpCol = input.color(c_profit, 'Take Profit Color', group = grpStyle, tooltip = 'Color of the TP lines and text. Also used when targets are hit.')
slCol = input.color(c_loss, 'Stop Loss Color', group = grpStyle, tooltip = 'Color of the SL line and text. Also used when stop loss is hit.')

dSize = dashSizeIn == 'Tiny' ? size.tiny : dashSizeIn == 'Small' ? size.small : dashSizeIn == 'Normal' ? size.normal : dashSizeIn == 'Large' ? size.large : dashSizeIn == 'Huge' ? size.huge : size.auto
lSize = dSize

// ==========================================
// 5. BULLETPROOF MARKET DATA ENGINE
// ==========================================
f_52wl() =>
    float _h52 = high
    float _l52 = low
    int limit = math.min(bar_index, 251)
    for i = 0 to limit by 1
        _h52 := math.max(_h52, high[i])
        _l52 := math.min(_l52, low[i])
        _l52
    [_h52, _l52]

f_ath_atl() =>
    var float _ath = high
    var float _atl = low
    _ath := math.max(nz(_ath[1], high), high)
    _atl := math.min(nz(_atl[1], low), low)
    [_ath, _atl]

[sec_52h, sec_52l] = request.security(syminfo.tickerid, 'D', f_52wl())
[sec_ath, sec_atl] = request.security(syminfo.tickerid, 'D', f_ath_atl())
[sec_dh, sec_dl] = request.security(syminfo.tickerid, 'D', [high, low])

true_dh = math.max(nz(sec_dh, high), high)
true_dl = math.min(nz(sec_dl, low), low)
true_52h = math.max(nz(sec_52h, high), high)
true_52l = math.min(nz(sec_52l, low), low)
true_ath = math.max(nz(sec_ath, high), high)
true_atl = math.min(nz(sec_atl, low), low)

dist_dh = true_dh > 0 ? (close - true_dh) / true_dh * 100 : 0
dist_dl = true_dl > 0 ? (close - true_dl) / true_dl * 100 : 0
dist_52h = true_52h > 0 ? (close - true_52h) / true_52h * 100 : 0
dist_52l = true_52l > 0 ? (close - true_52l) / true_52l * 100 : 0
dist_ath = true_ath > 0 ? (close - true_ath) / true_ath * 100 : 0
dist_atl = true_atl > 0 ? (close - true_atl) / true_atl * 100 : 0

getDistVisuals(dist) =>
    signStr = dist > 0 ? '+' : ''
    col = dist > 0 ? c_profit : c_loss
    [signStr + str.tostring(dist, '#.##') + '%', col]

// ==========================================
// 6. P&L MATH & LOGIC
// ==========================================
isLong = posType == 'Long'
actualEntry = entryIn == 0 ? close : entryIn
activeLev = lev <= 0 ? 1.0 : lev
posValue = actualEntry * shares
margin = lev <= 0 ? posValue : posValue / activeLev
isOverleveraged = netCash > 0 and margin > netCash

bePrice = actualEntry
if feeType == 'Fixed Value' and shares > 0
    bePrice := isLong ? actualEntry + feeVal / shares : actualEntry - feeVal / shares
    bePrice
else if feeType == 'Percentage'
    bePrice := isLong ? actualEntry * (1 + feeVal / 100 * 2) : actualEntry * (1 - feeVal / 100 * 2)
    bePrice

calcTpPrice(manualPrice, pctOverride) =>
    finalPrice = manualPrice
    if pctOverride > 0
        finalPrice := isLong ? actualEntry * (1 + pctOverride / 100) : actualEntry * (1 - pctOverride / 100)
        finalPrice
    finalPrice

finalTp1 = calcTpPrice(tp1P, tp1Pct)
finalTp2 = calcTpPrice(tp2P, tp2Pct)
finalTp3 = calcTpPrice(tp3P, tp3Pct)
finalTp4 = calcTpPrice(tp4P, tp4Pct)

calcMetrics(targetPrice) =>
    if targetPrice == 0 or shares == 0 or actualEntry == 0
        [0.0, 0.0, 0.0, 0.0]
    else
        grossPnl = isLong ? (targetPrice - actualEntry) * shares : (actualEntry - targetPrice) * shares
        totalFee = feeType == 'Fixed Value' ? feeVal : posValue * (feeVal / 100) + targetPrice * shares * (feeVal / 100)
        netPnl = grossPnl - totalFee
        ticks = math.abs(targetPrice - actualEntry) / syminfo.mintick
        pct = math.abs(targetPrice - actualEntry) / actualEntry * 100
        roe = lev <= 0 ? pct : pct * activeLev
        [netPnl, ticks, pct, roe]

[slNet, slTicks, slPct, slRoe] = calcMetrics(slP)
[tp1Net, tp1Ticks, tp1PctOut, tp1Roe] = calcMetrics(finalTp1)
[tp2Net, tp2Ticks, tp2PctOut, tp2Roe] = calcMetrics(finalTp2)
[tp3Net, tp3Ticks, tp3PctOut, tp3Roe] = calcMetrics(finalTp3)
[tp4Net, tp4Ticks, tp4PctOut, tp4Roe] = calcMetrics(finalTp4)

rrRatio = slNet < 0 and finalTp1 > 0 ? math.abs(tp1Net / slNet) : 0.0
acctRisk = netCash > 0 and slNet < 0 ? math.abs(slNet) / netCash * 100 : 0.0

// ==========================================
// 7. REAL-TIME BLINK ENGINE (WICK-SENSITIVE)
// ==========================================
bool blink = second(timenow) % 2 == 0

hit_tp1 = finalTp1 > 0 and (isLong ? high >= finalTp1 : low <= finalTp1)
hit_tp2 = finalTp2 > 0 and (isLong ? high >= finalTp2 : low <= finalTp2)
hit_tp3 = finalTp3 > 0 and (isLong ? high >= finalTp3 : low <= finalTp3)
hit_tp4 = finalTp4 > 0 and (isLong ? high >= finalTp4 : low <= finalTp4)
hit_sl = slP > 0 and (isLong ? low <= slP : high >= slP)

bg_tp1 = hit_tp1 ? blink ? color.new(color.white, 0) : color.new(c_profit, 20) : color.new(c_profit, 85)
bg_tp2 = hit_tp2 ? blink ? color.new(color.white, 0) : color.new(c_profit, 20) : color.new(c_profit, 85)
bg_tp3 = hit_tp3 ? blink ? color.new(color.white, 0) : color.new(c_profit, 20) : color.new(c_profit, 85)
bg_tp4 = hit_tp4 ? blink ? color.new(color.white, 0) : color.new(c_profit, 20) : color.new(c_profit, 85)
bg_sl = hit_sl ? blink ? color.new(color.white, 0) : color.new(c_loss, 20) : color.new(c_loss, 85)

txt_tp1 = hit_tp1 ? blink ? color.black : color.white : c_profit
txt_tp2 = hit_tp2 ? blink ? color.black : color.white : c_profit
txt_tp3 = hit_tp3 ? blink ? color.black : color.white : c_profit
txt_tp4 = hit_tp4 ? blink ? color.black : color.white : c_profit
txt_sl = hit_sl ? blink ? color.black : color.white : c_loss

lblCol_tp1 = hit_tp1 and blink ? color.yellow : tpCol
lblCol_tp2 = hit_tp2 and blink ? color.yellow : tpCol
lblCol_tp3 = hit_tp3 and blink ? color.yellow : tpCol
lblCol_tp4 = hit_tp4 and blink ? color.yellow : tpCol
lblCol_sl = hit_sl and blink ? color.yellow : slCol

// ==========================================
// 8. DRAWING CHART LINES
// ==========================================
var line l_entry = line.new(na, na, na, na, extend = extend.right)
var line l_sl = line.new(na, na, na, na, extend = extend.right)
var line l_tp1 = line.new(na, na, na, na, extend = extend.right)
var line l_tp2 = line.new(na, na, na, na, extend = extend.right)
var line l_tp3 = line.new(na, na, na, na, extend = extend.right)
var line l_tp4 = line.new(na, na, na, na, extend = extend.right)

var label lbl_entry = label.new(na, na, style = label.style_none)
var label lbl_sl = label.new(na, na, style = label.style_none)
var label lbl_tp1 = label.new(na, na, style = label.style_none)
var label lbl_tp2 = label.new(na, na, style = label.style_none)
var label lbl_tp3 = label.new(na, na, style = label.style_none)
var label lbl_tp4 = label.new(na, na, style = label.style_none)

if barstate.islast
    if actualEntry > 0
        line.set_xy1(l_entry, bar_index, actualEntry)
        line.set_xy2(l_entry, bar_index + 5, actualEntry)
        line.set_color(l_entry, entryCol)
        line.set_width(l_entry, lineThick)
        label.set_xy(lbl_entry, bar_index + 10, actualEntry)
        label.set_text(lbl_entry, 'ENTRY: ' + str.tostring(actualEntry))
        label.set_textcolor(lbl_entry, entryCol)
        label.set_size(lbl_entry, lSize)
    if slP > 0
        line.set_xy1(l_sl, bar_index, slP)
        line.set_xy2(l_sl, bar_index + 5, slP)
        line.set_color(l_sl, slCol)
        line.set_width(l_sl, lineThick)
        label.set_xy(lbl_sl, bar_index + 10, slP)
        label.set_text(lbl_sl, 'SL: ' + curSym + str.tostring(slNet, '#.##'))
        label.set_textcolor(lbl_sl, lblCol_sl)
        label.set_size(lbl_sl, lSize)
    if finalTp1 > 0
        line.set_xy1(l_tp1, bar_index, finalTp1)
        line.set_xy2(l_tp1, bar_index + 5, finalTp1)
        line.set_color(l_tp1, tpCol)
        line.set_width(l_tp1, lineThick)
        label.set_xy(lbl_tp1, bar_index + 10, finalTp1)
        label.set_text(lbl_tp1, 'TP1: +' + curSym + str.tostring(tp1Net, '#.##'))
        label.set_textcolor(lbl_tp1, lblCol_tp1)
        label.set_size(lbl_tp1, lSize)
    if finalTp2 > 0
        line.set_xy1(l_tp2, bar_index, finalTp2)
        line.set_xy2(l_tp2, bar_index + 5, finalTp2)
        line.set_color(l_tp2, tpCol)
        line.set_width(l_tp2, lineThick)
        label.set_xy(lbl_tp2, bar_index + 10, finalTp2)
        label.set_text(lbl_tp2, 'TP2: +' + curSym + str.tostring(tp2Net, '#.##'))
        label.set_textcolor(lbl_tp2, lblCol_tp2)
        label.set_size(lbl_tp2, lSize)
    if finalTp3 > 0
        line.set_xy1(l_tp3, bar_index, finalTp3)
        line.set_xy2(l_tp3, bar_index + 5, finalTp3)
        line.set_color(l_tp3, tpCol)
        line.set_width(l_tp3, lineThick)
        label.set_xy(lbl_tp3, bar_index + 10, finalTp3)
        label.set_text(lbl_tp3, 'TP3: +' + curSym + str.tostring(tp3Net, '#.##'))
        label.set_textcolor(lbl_tp3, lblCol_tp3)
        label.set_size(lbl_tp3, lSize)
    if finalTp4 > 0
        line.set_xy1(l_tp4, bar_index, finalTp4)
        line.set_xy2(l_tp4, bar_index + 5, finalTp4)
        line.set_color(l_tp4, tpCol)
        line.set_width(l_tp4, lineThick)
        label.set_xy(lbl_tp4, bar_index + 10, finalTp4)
        label.set_text(lbl_tp4, 'TP4: +' + curSym + str.tostring(tp4Net, '#.##'))
        label.set_textcolor(lbl_tp4, lblCol_tp4)
        label.set_size(lbl_tp4, lSize)

// ==========================================
// 9. DYNAMIC PRO DASHBOARD
// ==========================================
getPos(posStr) =>
    posStr == 'Top Right' ? position.top_right : posStr == 'Top Left' ? position.top_left : posStr == 'Top Center' ? position.top_center : posStr == 'Bottom Right' ? position.bottom_right : posStr == 'Bottom Left' ? position.bottom_left : position.bottom_center

var table d = table.new(getPos(dashPosIn), 6, 15, border_width = 1, border_color = c_border, frame_width = 1, frame_color = c_border, bgcolor = c_bg)

fillCell(col, row, txt, bg, txtCol) =>
    table.cell(d, col, row, txt, bgcolor = bg, text_color = txtCol, text_size = dSize, text_halign = text.align_center)

if barstate.islast
    table.cell(d, 0, 0, 'RISK CONTROLLER | MOURYA', bgcolor = headCol, text_color = headTxtCol, text_size = dSize, text_halign = text.align_center)
    table.merge_cells(d, 0, 0, 5, 0)

    fillCell(0, 1, 'LEVEL', c_subhead, c_text)
    fillCell(1, 1, 'PRICE', c_subhead, c_text)
    fillCell(2, 1, 'TICKS', c_subhead, c_text)
    fillCell(3, 1, 'ASSET %', c_subhead, c_text)
    fillCell(4, 1, lev <= 0 ? 'MARGIN' : 'ROE %', c_subhead, c_text)
    fillCell(5, 1, 'NET P&L', c_subhead, c_text)

    int r = 2

    m_bg = isOverleveraged ? color.new(c_loss, 30) : c_bg
    m_txt = isOverleveraged ? '! MARGIN EXCEEDED !' : lev <= 0 ? 'Cost:' : 'Req:'

    fillCell(0, r, 'Entry (' + posType + ')', c_bg, c_text)
    fillCell(1, r, str.tostring(actualEntry, '#.##'), c_bg, c_text)
    fillCell(2, r, '-', c_bg, color.gray)
    fillCell(3, r, '-', c_bg, color.gray)
    fillCell(4, r, m_txt, m_bg, c_text)
    fillCell(5, r, curSym + str.tostring(margin, '#.##'), m_bg, c_text)
    r := r + 1

    if finalTp1 > 0
        fillCell(0, r, 'TP 1', bg_tp1, txt_tp1)
        fillCell(1, r, str.tostring(finalTp1, '#.##'), bg_tp1, txt_tp1)
        fillCell(2, r, str.tostring(tp1Ticks, '#'), bg_tp1, txt_tp1)
        fillCell(3, r, str.tostring(tp1PctOut, '#.##') + '%', bg_tp1, txt_tp1)
        fillCell(4, r, str.tostring(tp1Roe, '#.##') + '%', bg_tp1, txt_tp1)
        fillCell(5, r, '+' + curSym + str.tostring(tp1Net, '#.##'), bg_tp1, txt_tp1)
        r := r + 1
        r
    if finalTp2 > 0
        fillCell(0, r, 'TP 2', bg_tp2, txt_tp2)
        fillCell(1, r, str.tostring(finalTp2, '#.##'), bg_tp2, txt_tp2)
        fillCell(2, r, str.tostring(tp2Ticks, '#'), bg_tp2, txt_tp2)
        fillCell(3, r, str.tostring(tp2PctOut, '#.##') + '%', bg_tp2, txt_tp2)
        fillCell(4, r, str.tostring(tp2Roe, '#.##') + '%', bg_tp2, txt_tp2)
        fillCell(5, r, '+' + curSym + str.tostring(tp2Net, '#.##'), bg_tp2, txt_tp2)
        r := r + 1
        r
    if finalTp3 > 0
        fillCell(0, r, 'TP 3', bg_tp3, txt_tp3)
        fillCell(1, r, str.tostring(finalTp3, '#.##'), bg_tp3, txt_tp3)
        fillCell(2, r, str.tostring(tp3Ticks, '#'), bg_tp3, txt_tp3)
        fillCell(3, r, str.tostring(tp3PctOut, '#.##') + '%', bg_tp3, txt_tp3)
        fillCell(4, r, str.tostring(tp3Roe, '#.##') + '%', bg_tp3, txt_tp3)
        fillCell(5, r, '+' + curSym + str.tostring(tp3Net, '#.##'), bg_tp3, txt_tp3)
        r := r + 1
        r
    if finalTp4 > 0
        fillCell(0, r, 'TP 4', bg_tp4, txt_tp4)
        fillCell(1, r, str.tostring(finalTp4, '#.##'), bg_tp4, txt_tp4)
        fillCell(2, r, str.tostring(tp4Ticks, '#'), bg_tp4, txt_tp4)
        fillCell(3, r, str.tostring(tp4PctOut, '#.##') + '%', bg_tp4, txt_tp4)
        fillCell(4, r, str.tostring(tp4Roe, '#.##') + '%', bg_tp4, txt_tp4)
        fillCell(5, r, '+' + curSym + str.tostring(tp4Net, '#.##'), bg_tp4, txt_tp4)
        r := r + 1
        r
    if slP > 0
        fillCell(0, r, 'Stop Loss', bg_sl, txt_sl)
        fillCell(1, r, str.tostring(slP, '#.##'), bg_sl, txt_sl)
        fillCell(2, r, str.tostring(slTicks, '#'), bg_sl, txt_sl)
        fillCell(3, r, str.tostring(slPct, '#.##') + '%', bg_sl, txt_sl)
        fillCell(4, r, str.tostring(slRoe, '#.##') + '%', bg_sl, txt_sl)
        fillCell(5, r, '-' + curSym + str.tostring(math.abs(slNet), '#.##'), bg_sl, txt_sl)
        r := r + 1
        r

    sumBg = color.new(c_subhead, 30)
    fillCell(0, r, 'Breakeven', sumBg, c_text)
    fillCell(1, r, str.tostring(bePrice, '#.##'), sumBg, c_text)
    fillCell(2, r, 'R:R (TP1)', sumBg, c_text)
    fillCell(3, r, rrRatio > 0 ? '1 : ' + str.tostring(rrRatio, '#.##') : '-', sumBg, rrRatio >= 1.5 ? c_profit : c_text)
    fillCell(4, r, 'Acct Risk %', sumBg, c_text)
    fillCell(5, r, acctRisk > 0 ? str.tostring(acctRisk, '#.##') + '%' : '-', sumBg, acctRisk > 2.0 ? c_loss : c_text)
    r := r + 1

    if showDay or show52W or showATH
        table.cell(d, 0, r, 'MARKET CONTEXT (Vs Current Price)', bgcolor = c_subhead, text_color = color.gray, text_size = dSize, text_halign = text.align_center)
        table.merge_cells(d, 0, r, 5, r)
        r := r + 1

        if showDay
            [dh_t, dh_c] = getDistVisuals(dist_dh)
            [dl_t, dl_c] = getDistVisuals(dist_dl)
            fillCell(0, r, 'Day High', c_bg, c_text)
            fillCell(1, r, str.tostring(true_dh, '#.##'), c_bg, c_text)
            fillCell(2, r, dh_t, c_bg, dh_c)
            fillCell(3, r, 'Day Low', c_bg, c_text)
            fillCell(4, r, str.tostring(true_dl, '#.##'), c_bg, c_text)
            fillCell(5, r, dl_t, c_bg, dl_c)
            r := r + 1
            r

        if show52W
            [w52h_t, w52h_c] = getDistVisuals(dist_52h)
            [w52l_t, w52l_c] = getDistVisuals(dist_52l)
            fillCell(0, r, '52W High', c_bg, c_text)
            fillCell(1, r, str.tostring(true_52h, '#.##'), c_bg, c_text)
            fillCell(2, r, w52h_t, c_bg, w52h_c)
            fillCell(3, r, '52W Low', c_bg, c_text)
            fillCell(4, r, str.tostring(true_52l, '#.##'), c_bg, c_text)
            fillCell(5, r, w52l_t, c_bg, w52l_c)
            r := r + 1
            r

        if showATH
            [ath_t, ath_c] = getDistVisuals(dist_ath)
            [atl_t, atl_c] = getDistVisuals(dist_atl)
            fillCell(0, r, 'All-Time High', c_bg, c_text)
            fillCell(1, r, str.tostring(true_ath, '#.##'), c_bg, c_text)
            fillCell(2, r, ath_t, c_bg, ath_c)
            fillCell(3, r, 'All-Time Low', c_bg, c_text)
            fillCell(4, r, str.tostring(true_atl, '#.##'), c_bg, c_text)
            fillCell(5, r, atl_t, c_bg, atl_c)
````
