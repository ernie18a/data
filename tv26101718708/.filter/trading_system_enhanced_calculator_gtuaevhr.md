# Trading system Enhanced Calculator

- url: https://www.tradingview.com/script/GtUAEvHR-Trading-system-Enhanced-Calculator/
- type: indicator
- pine_id: PUB;47c5cb82e1a84d66a1fa85c614b6abb0
- version: 1.0

## Description

The Enhanced Calculator & Trend Analysis Suite is a comprehensive all-in-one professional trading toolkit designed for Pine Script v6. This script integrates risk management, trend validation, and fundamental context into a single, highly customizable overlay, eliminating the need for multiple indicators.


Key Components1. Professional Position Sizing & Risk ManagementThe core of the system is a dynamic calculator that follows professional risk management principles. Automatic Quantity Calculation: Enter your account value and Risk Per Trade (RPT%) to receive the exact quantity of shares to buy. Chandelier Trailing Stop: Features a built-in Chandelier Exit that automatically calculates your stop loss based on ATR volatility, with a manual override option for fixed-percentage stops. Real-Time Risk Metrics: The compact table displays your total investment value, actual risk in currency, and the risk as a total percentage of your account

## Source Code

````pine

//@version=6
indicator("Enhanced Calculator", "BuyEnhance", overlay=true)

// ================================================================
// TRADING SYSTEM - ENHANCED POSITION SIZE CALCULATOR
// Modified with compact table and additional indicators
// ================================================================

// ================== INPUT PARAMETERS ====================

// Account Settings
group_account = "📊 Account Settings"
account_value = input.float(2000000, title="Account Value (₹)", group=group_account, minval=1000, step=10000)
rpt_percent = input.float(1.0, title="Risk Per Trade (%)", group=group_account, minval=0.1, maxval=5.0, step=0.1)

// Stop Loss Settings
group_sl = "🛑 Stop Loss Settings"
manual_sl_enabled = input.bool(false, title="Use Manual SL%", group=group_sl)
manual_sl_percent = input.float(5.0, title="Manual SL (%)", group=group_sl, minval=0.5, maxval=20.0, step=0.5)

// Chandelier Exit Settings
group_chandelier = "📈 Chandelier Trailing Stop Settings"
chandelier_length = input.int(22, title="ATR Period", group=group_chandelier, minval=1)
chandelier_multiplier = input.float(3.0, title="ATR Multiplier", group=group_chandelier, minval=0.5, step=0.1)
use_close = input.bool(true, title="Use Close Price for Calculation", group=group_chandelier)

// Technical Indicators Settings
group_tech = "📊 Technical Indicators"
sma_length = input.int(200, title="SMA Period", group=group_tech, minval=1)
adx_length = input.int(14, title="ADX Period", group=group_tech, minval=1)

// Display Settings
group_display = "🎨 Display Settings"
table_position = input.string("top_right", title="Table Position", 
     options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", 
              "bottom_left", "bottom_center", "bottom_right"], group=group_display)
text_size = input.string("normal", title="Text Size", 
     options=["tiny", "small", "normal", "large"], group=group_display)
show_chandelier = input.bool(true, title="Show Chandelier Stop on Chart", group=group_display)

// Color Settings
group_colors = "🎨 Color Settings"
bullish_color = input.color(color.new(color.green, 20), title="Bullish Color", group=group_colors)
bearish_color = input.color(color.new(color.red, 20), title="Bearish Color", group=group_colors)
table_bg_color = input.color(color.new(color.white, 10), title="Table Background", group=group_colors)
header_color = input.color(color.new(color.blue, 20), title="Header Color", group=group_colors)

// ================== CALCULATIONS ====================

// ATR Calculation for Chandelier Stop
atr = ta.atr(chandelier_length)

// Chandelier Trailing Stop Calculation
var float chandelier_stop_long = na
var float chandelier_stop_short = na

// Calculate basic chandelier stops
basic_upper_stop = (use_close ? close : high) - chandelier_multiplier * atr
basic_lower_stop = (use_close ? close : low) + chandelier_multiplier * atr

// Trailing logic for long positions
chandelier_stop_long := close > chandelier_stop_long[1] ? math.max(basic_upper_stop, chandelier_stop_long[1]) : basic_upper_stop

// Trailing logic for short positions  
chandelier_stop_short := close < chandelier_stop_short[1] ? math.min(basic_lower_stop, chandelier_stop_short[1]) : basic_lower_stop

// Determine trend direction
is_uptrend = close > chandelier_stop_long
current_stop = is_uptrend ? chandelier_stop_long : chandelier_stop_short

// Calculate SL% based on current price and stop level
chandelier_sl_percent = is_uptrend ? 
     math.abs((close - chandelier_stop_long) / close) * 100 : 
     math.abs((chandelier_stop_short - close) / close) * 100

// Final SL% - manual takes precedence
final_sl_percent = manual_sl_enabled ? manual_sl_percent : chandelier_sl_percent
final_sl_price = is_uptrend ? close * (1 - final_sl_percent / 100) : close * (1 + final_sl_percent / 100)

// Position Size Calculations (TRADING SYSTEM Formulas)
rpt_value = account_value * rpt_percent / 100
position_size_percent = (rpt_percent / final_sl_percent) * 100
position_size_value = account_value * position_size_percent / 100
quantity_to_buy = math.floor(position_size_value / close)

// Risk-Reward Calculations
actual_investment = quantity_to_buy * close
actual_risk = quantity_to_buy * math.abs(close - final_sl_price)
risk_percent_of_account = (actual_risk / account_value) * 100

// ================== TECHNICAL INDICATORS ====================

// 200 SMA Calculation
sma_200 = ta.sma(close, sma_length)
sma_distance_percent = ((close - sma_200) / sma_200) * 100

// ADX Calculation
[diplus, diminus, adx] = ta.dmi(adx_length, adx_length)

// ================== PLOTTING ====================

// Plot Chandelier Stop on Chart
plot(show_chandelier and is_uptrend ? chandelier_stop_long : na, 
     title="Chandelier Stop Long", color=bullish_color, linewidth=2, style=plot.style_line)
plot(show_chandelier and not is_uptrend ? chandelier_stop_short : na, 
     title="Chandelier Stop Short", color=bearish_color, linewidth=2, style=plot.style_line)

// Plot Manual SL if enabled
plot(manual_sl_enabled ? final_sl_price : na, 
     title="Manual Stop Loss", color=color.gray, linewidth=2, style=plot.style_line)

// ================== TABLE DISPLAY ====================

// Convert position string to position type
table_pos = switch table_position
    "top_left" => position.top_left
    "top_center" => position.top_center
    "top_right" => position.top_right
    "middle_left" => position.middle_left
    "middle_center" => position.middle_center
    "middle_right" => position.middle_right
    "bottom_left" => position.bottom_left
    "bottom_center" => position.bottom_center
    "bottom_right" => position.bottom_right
    => position.top_right

// Convert text size string to size type
txt_size = switch text_size
    "tiny" => size.tiny
    "small" => size.small
    "normal" => size.normal
    "large" => size.large
    => size.normal

// Create and populate compact table
if barstate.islast
    var table info_table = table.new(table_pos, 2, 10, bgcolor=table_bg_color, border_width=2)

    // Header
    table.cell(info_table, 0, 0, "TRADING SYSTEM", text_color=color.black, bgcolor=header_color, text_size=txt_size, width=12)
    table.cell(info_table, 1, 0, "ENHANCED CALCULATOR", text_color=color.black, bgcolor=header_color, text_size=txt_size, width=12)

    // Account Information
    table.cell(info_table, 0, 1, "Account Value", text_color=color.black, bgcolor=color.new(color.gray, 80), text_size=txt_size)
    table.cell(info_table, 1, 1, "₹" + str.tostring(account_value, "#,###"), text_color=color.black, bgcolor=color.new(color.black, 50), text_size=txt_size)

    // Combined RPT % and Value (Space Saving)
    table.cell(info_table, 0, 2, "RPT % | Value", text_color=color.black, bgcolor=color.new(color.gray, 80), text_size=txt_size)
    rpt_combined = str.tostring(rpt_percent, "#.##") + "% | ₹" + str.tostring(rpt_value, "#,###")
    table.cell(info_table, 1, 2, rpt_combined, text_color=color.black, bgcolor=color.new(color.black, 50), text_size=txt_size)

    // Current Price
    table.cell(info_table, 0, 3, "Current Price", text_color=color.black, bgcolor=color.new(color.blue, 80), text_size=txt_size)
    table.cell(info_table, 1, 3, "₹" + str.tostring(close, "#.##"), text_color=color.black, bgcolor=color.new(color.blue, 60), text_size=txt_size)

    // Combined Stop Loss Price and % (Space Saving)
    table.cell(info_table, 0, 4, "SL Price | %", text_color=color.black, bgcolor=color.new(color.red, 80), text_size=txt_size)
    sl_source = manual_sl_enabled ? "(M)" : "(A)"
    sl_combined = "₹" + str.tostring(final_sl_price, "#.##") + " | " + str.tostring(final_sl_percent, "#.##") + "%" + sl_source
    table.cell(info_table, 1, 4, sl_combined, text_color=color.black, bgcolor=color.new(color.red, 60), text_size=txt_size)

    // Combined Position Size % and Value (Space Saving)
    table.cell(info_table, 0, 5, "PS % | Value", text_color=color.black, bgcolor=color.new(color.green, 80), text_size=txt_size)
    ps_combined = str.tostring(position_size_percent, "#.##") + "% | ₹" + str.tostring(position_size_value, "#,###")
    table.cell(info_table, 1, 5, ps_combined, text_color=color.black, bgcolor=color.new(color.green, 60), text_size=txt_size)

    // Quantity to Buy
    table.cell(info_table, 0, 6, "Quantity to Buy", text_color=color.black, bgcolor=color.new(color.green, 80), text_size=txt_size)
    table.cell(info_table, 1, 6, str.tostring(quantity_to_buy, "#,###") + " shares", text_color=color.black, bgcolor=color.new(color.green, 60), text_size=txt_size)

    // Distance from 200 SMA (NEW FEATURE)
    table.cell(info_table, 0, 7, "Distance from 200SMA", text_color=color.black, bgcolor=color.new(color.purple, 80), text_size=txt_size)
    sma_color = sma_distance_percent > 0 ? color.new(color.green, 60) : color.new(color.red, 60)
    sma_text_color = sma_distance_percent > 0 ? color.black : color.black
    sma_display = (sma_distance_percent > 0 ? "+" : "") + str.tostring(sma_distance_percent, "#.##") + "%"
    table.cell(info_table, 1, 7, sma_display, text_color=sma_text_color, bgcolor=sma_color, text_size=txt_size)

    // ADX Value (NEW FEATURE)
    table.cell(info_table, 0, 8, "ADX Strength", text_color=color.black, bgcolor=color.new(color.navy, 80), text_size=txt_size)
    adx_color = adx > 25 ? color.new(color.green, 60) : color.new(color.red, 60)
    adx_text_color = color.black
    adx_display = str.tostring(adx, "#.##") + (adx > 25 ? " (Strong)" : " (Weak)")
    table.cell(info_table, 1, 8, adx_display, text_color=adx_text_color, bgcolor=adx_color, text_size=txt_size)

    // Actual Risk (Verification)
    table.cell(info_table, 0, 9, "Actual Risk", text_color=color.black, bgcolor=color.new(color.orange, 80), text_size=txt_size)
    risk_display = "₹" + str.tostring(actual_risk, "#,###") + " (" + str.tostring(risk_percent_of_account, "#.##") + "%)"
    table.cell(info_table, 1, 9, risk_display, text_color=color.black, bgcolor=color.new(color.orange, 60), text_size=txt_size)



// ================== NOTES ====================
// Enhanced TRADING SYSTEM Features:
// 1. Compact table design with combined rows to save space
// 2. Real-time position sizing based on account value and risk percentage  
// 3. Chandelier Trailing Stop calculation with manual override option
// 4. Distance from 200SMA with color coding (green=above, red=below)
// 5. ADX strength indicator with color coding (green>25, red<25)
// 6. Professional table display with customizable position and size
// 7. Risk management calculations following Champion Trading principles
// 8. Visual stop loss plotting on chart
// 9. Enhanced alert system including technical indicator alerts
//
// Space-saving modifications:
// - RPT % and RPT Value combined in one row
// - Stop Loss Price and SL% combined in one row  
// - Position Size % and Value combined in one row
// - Added 200SMA distance percentage
// - Added ADX strength indicator
//
// Usage:
// 1. Set your account value and desired RPT%
// 2. Choose between automatic Chandelier stop or manual SL%
// 3. Monitor 200SMA distance for trend context
// 4. Check ADX for trend strength validation
// 5. Use the calculated quantity for your trades
// 6. Monitor the stop loss levels on chart
//
// The system ensures you never risk more than your specified RPT% per trade
// while providing additional technical context for better trade decisions.



///Mark Minervini Trend Template


position = input.string(position.bottom_left, 'Table \nPosition\n', options = [position.top_left, position.top_right, position.bottom_left, position.bottom_right, position.top_center, position.bottom_center], group = '--------------Table Properties--------------', inline = '1')
textcolor = input(color.white, 'Text Color', group = '--------------Table Properties--------------', inline = '1')

textsize = input.string(size.tiny, 'Text Size', options = [size.tiny, size.small, size.normal, size.large], group = '--------------Table Properties--------------', inline = '2')
panelbgcolor = input(color.gray, 'Background Color', group = '--------------Table Properties--------------', inline = '2')


//Moving Averages
type = input.string(defval = 'EMA', options = ['EMA', 'SMA'], title = 'Moving Average Type', tooltip = 'EMA / SMA?.', group = '--------------Moving Average Settings--------------')

// Table
var table1 = table.new(position, 3, 15, frame_color = color.rgb(49, 71, 131), border_width = 1, frame_width = 2, border_color = color.black)
table.merge_cells(table1, 0, 0, 2, 0)
table.cell(table1, 0, 0, 'Mark Minervini Template', bgcolor = color.rgb(88, 247, 114), text_size = textsize, text_color = color.black)


ma50 = ta.ema(close, 50)
ma150 = ta.ema(close, 150)
ma200 = ta.ema(close, 200)
ma200_22 = ma200[22]

if type == 'EMA'
    ma50 := ta.ema(close, 50)
    ma150 := ta.ema(close, 150)
    ma200 := ta.ema(close, 200)
    ma200

if type == 'SMA'
    ma50 := ta.sma(close, 50)
    ma150 := ta.sma(close, 150)
    ma200 := ta.sma(close, 200)
    ma200


bgcolor = panelbgcolor

// CMP > 50MA

close_greaterthan_50ma = close > ma50

close_greaterthan_50ma_color = color.gray
if not close_greaterthan_50ma
    close_greaterthan_50ma_color := color.red
    close_greaterthan_50ma_color

if na(ma50)
    close_greaterthan_50ma_color := color.gray
    close_greaterthan_50ma_color

isDaily = ta.change(time('D')) == 0

if timeframe.isdaily
    per50 = (1 - ma50 / close) * 100
    table.cell(table1, 0, 1, close_greaterthan_50ma ? '✓' : 'x', bgcolor = close_greaterthan_50ma_color, text_size = textsize, text_color = textcolor)
    table.cell(table1, 1, 1, str.tostring('CMP > 50MA'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
    table.cell(table1, 2, 1, str.tostring(ma50, '#.#') + ' (' + str.tostring(per50, '#.#') + ' %' + ')', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = '50 MA and % Distance from 50 MA')

// CMP > 150MA

close_greaterthan_150ma = close > ma150

close_greaterthan_150ma_color = color.gray
if not close_greaterthan_150ma
    close_greaterthan_150ma_color := color.red
    close_greaterthan_150ma_color

if na(ma150)
    close_greaterthan_150ma_color := color.gray
    close_greaterthan_150ma_color

if timeframe.isdaily
    per150 = (1 - ma150 / close) * 100
    table.cell(table1, 0, 2, close_greaterthan_150ma ? '✓' : 'x', bgcolor = close_greaterthan_150ma_color, text_size = textsize, text_color = textcolor)
    table.cell(table1, 1, 2, str.tostring('CMP > 150MA'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
    table.cell(table1, 2, 2, str.tostring(ma150, '#.#') + ' (' + str.tostring(per150, '#.#') + ' %' + ')', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = '150 MA and % Distance from 150 MA')

// CMP > 200MA

close_greaterthan_200ma = close > ma200

close_greaterthan_200ma_color = color.gray
if not close_greaterthan_200ma
    close_greaterthan_200ma_color := color.red
    close_greaterthan_200ma_color

if na(ma200)
    close_greaterthan_200ma_color := color.gray
    close_greaterthan_200ma_color

if timeframe.isdaily
    per200 = (1 - ma200 / close) * 100
    table.cell(table1, 0, 3, close_greaterthan_200ma ? '✓' : 'x', bgcolor = close_greaterthan_200ma_color, text_size = textsize, text_color = textcolor)
    table.cell(table1, 1, 3, str.tostring('CMP > 200MA'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
    table.cell(table1, 2, 3, str.tostring(ma200, '#.#') + ' (' + str.tostring(per200, '#.#') + ' %' + ')', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = '200 MA and % Distance from 200 MA')

// 50MA > 150MA

ma50_greaterthan_150ma = ma50 > ma150

ma50_greaterthan_150ma_color = color.gray
if not ma50_greaterthan_150ma
    ma50_greaterthan_150ma_color := color.red
    ma50_greaterthan_150ma_color

if na(ma50) or na(ma150)
    ma50_greaterthan_150ma_color := color.gray
    ma50_greaterthan_150ma_color

if timeframe.isdaily
    per50_150 = (1 - ma50 / ma150) * 100
    table.cell(table1, 0, 4, ma50_greaterthan_150ma ? '✓' : 'x', bgcolor = ma50_greaterthan_150ma_color, text_size = textsize, text_color = textcolor)
    table.cell(table1, 1, 4, str.tostring('50 MA > 150 MA'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
    table.cell(table1, 2, 4, str.tostring(per50_150, '#.#') + ' %', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = 'Distance between 50 & 150 MA')

// 50MA > 200MA

ma50_greaterthan_200ma = ma50 > ma200

ma50_greaterthan_200ma_color = color.gray
if not ma50_greaterthan_200ma
    ma50_greaterthan_200ma_color := color.red
    ma50_greaterthan_200ma_color

if na(ma50) or na(ma200)
    ma50_greaterthan_200ma_color := color.gray
    ma50_greaterthan_200ma_color

if timeframe.isdaily
    per50_200 = (1 - ma50 / ma200) * 100
    table.cell(table1, 0, 5, ma50_greaterthan_200ma ? '✓' : 'x', bgcolor = ma50_greaterthan_200ma_color, text_size = textsize, text_color = textcolor)
    table.cell(table1, 1, 5, str.tostring('50 MA > 200 MA'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
    table.cell(table1, 2, 5, str.tostring(per50_200, '#.#') + ' %', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = 'Distance between 50 & 200 MA')


// 150MA > 200MA

ma150_greaterthan_200ma = ma50 > ma200

ma150_greaterthan_200ma_color = color.gray
if not ma150_greaterthan_200ma
    ma150_greaterthan_200ma_color := color.red
    ma150_greaterthan_200ma_color

if na(ma150) or na(ma200)
    ma150_greaterthan_200ma_color := color.gray
    ma150_greaterthan_200ma_color

if timeframe.isdaily
    per150_200 = (1 - ma150 / ma200) * 100
    table.cell(table1, 0, 6, ma150_greaterthan_200ma ? '✓' : 'x', bgcolor = ma150_greaterthan_200ma_color, text_size = textsize, text_color = textcolor)
    table.cell(table1, 1, 6, str.tostring('150 MA > 200 MA'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
    table.cell(table1, 2, 6, str.tostring(per150_200, '#.#') + ' %', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = 'Distance between 150 & 200 MA')


//200MA trending up

ma200_uptrend = ma200 > ma200_22

ma200_uptrend_color = color.gray
if not ma200_uptrend
    ma200_uptrend_color := color.red
    ma200_uptrend_color

if na(ma200) or na(ma200_22)
    ma200_uptrend_color := color.gray
    ma200_uptrend_color

if timeframe.isdaily
    per200_22 = (1 - ma200 / close) * 100
    table.cell(table1, 0, 7, ma200_uptrend ? '✓' : 'x', bgcolor = ma200_uptrend_color, text_size = textsize, text_color = textcolor)
    table.cell(table1, 1, 7, str.tostring('200 MA trending up?'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
    table.cell(table1, 2, 7, str.tostring(per200_22, '#.#') + ' %', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = 'Distance from 200 MA')

// 52-week High
price_52wh = request.security(syminfo.tickerid, '1D', ta.highest(high, 252), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)

get_all_time_high() =>
    hi = 0.0
    hi := bar_index == 0 ? high : high > hi[1] ? high : hi[1]
    [hi]

[ath] = request.security(syminfo.tickerid, 'D', get_all_time_high())
if high > ath
    ath := high
    ath

if bar_index <= 252
    price_52wh := ath
    price_52wh

per_52wh = (1 - price_52wh / close) * 100

bgcolor52wh = color.red
per52 = 0
if per_52wh > -25
    per52 := 1
    bgcolor52wh := color.gray
    bgcolor52wh


table.cell(table1, 0, 8, bool(per52) ? '✓' : 'x', bgcolor = bgcolor52wh, text_size = textsize, text_color = textcolor)
table.cell(table1, 1, 8, str.tostring('Within 25% of 52-week High'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
table.cell(table1, 2, 8, str.tostring(price_52wh, '#.#') + ' (' + str.tostring(per_52wh, '#.#') + ' %' + ')', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = '52-week High and % Distance from 52-week High')


// 52-week Low
price_52wl = request.security(syminfo.tickerid, '1D', ta.lowest(low, 252), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)

get_all_time_low() =>
    lo = 0.0
    lo := bar_index == 0 ? low : low < lo[1] ? low : lo[1]
    [lo]

[atl] = request.security(syminfo.tickerid, 'D', get_all_time_low())
if low < atl
    atl := low
    atl

if bar_index <= 252
    price_52wl := atl
    price_52wl

per_52wl = (close / price_52wl - 1) * 100

bgcolor52wl = color.gray
per52l = 1
if per_52wl < 25
    per52l := 0
    bgcolor52wl := color.red
    bgcolor52wl

table.cell(table1, 0, 9, bool(per52l) ? '✓' : 'x', bgcolor = bgcolor52wl, text_size = textsize, text_color = textcolor)
table.cell(table1, 1, 9, str.tostring('>25% up from 52-week Low'), bgcolor = color.rgb(6, 192, 224), text_size = textsize, text_color = color.black)
table.cell(table1, 2, 9, str.tostring(price_52wl, '#.#') + ' (' + str.tostring(per_52wl, '#.#') + ' %' + ')', bgcolor = panelbgcolor, text_size = textsize, text_color = textcolor, tooltip = '52-week Low and % Distance from 52-week Low')


// Does it fulfil Mark Minervini's Criteria?

bgcolor_criteria = color.red
textcolor_satisfy = color.white
fulfil = 0
if close_greaterthan_50ma == bool(1) and close_greaterthan_150ma == bool(1) and close_greaterthan_200ma == bool(1) and ma50_greaterthan_150ma == bool(1) and ma50_greaterthan_200ma == bool(1) and ma150_greaterthan_200ma == bool(1) and ma200_uptrend == bool(1) and per52 == 1 and per52l == 1
    fulfil := 1
    bgcolor_criteria := color.rgb(88, 247, 114)
    textcolor_satisfy := color.black
    textcolor_satisfy

if timeframe.isdaily
    table.merge_cells(table1, 0, 10, 1, 10)
    table.cell(table1, 0, 10, str.tostring('Does it satisfy Minervini\'s criteria?'), bgcolor = bgcolor_criteria, text_size = textsize, text_color = textcolor_satisfy)
    table.cell(table1, 2, 10, bool(fulfil) ? '✓✓✓' : 'X', bgcolor = bgcolor_criteria, text_size = textsize, text_color = textcolor_satisfy)

//Dual Bollinger Moving Average -- DBMA
string GRP1             = "════════ Moving Average ═════════"
MA_length = input.int(title='', minval=1, maxval=1000, defval=20, inline='line 1', group=GRP1)
MA_type = input.string(title='', options=['SMA', 'EMA', 'WMA'], defval='SMA', inline='line 1', group=GRP1)
MA_source = input.source(title='', defval=close, inline='line 1', group=GRP1)
MA_color = input.color(title='', defval=color.green, inline='line 1', group=GRP1)
MA_width = input.int(title='MA line width', defval=1, minval=1, maxval=4, inline='line 2', group=GRP1)

string GRP2             = "════════ Bollinger Bands ═════════"
BB_show_upper = input.bool(title='Show Upper Bands', defval=true, inline='line 1', group=GRP2)
BB_show_lower = input.bool(title='Show Lower Bands', defval=false, inline='line 2', group=GRP2)

BB_stdev_near = input.float(title='Near Band', minval=0, maxval=3, defval=0.5, step = 0.5, inline='line 3', group=GRP2)
colorOrangeHalf = input.color(color.new(color.orange, 85), '', inline='line 3', group=GRP2)

BB_stdev_far = input.float(title='Far Band', minval=0, maxval=3, defval=1, step = 0.5, inline='line 4', group=GRP2)
colorOrangeOne = input.color(color.new(color.orange, 90), '', inline='line 4', group=GRP2)

string GRP3             = "════════ Squeeze ═════════"
toggleSQZColors = input.bool(title='Squeeze Colors', defval=true, inline='line 3', group=GRP3)
colorRed = input.color(color.red, 'High-compression Squeeze', group=GRP3)
colorOrange = input.color(color.orange, 'Mid-compression Squeeze', group=GRP3)
colorYellow = input.color(color.yellow, 'Low-compression Squeeze', group=GRP3)
colorGreen = input.color(color.green, 'Fired Squeeze', group=GRP3)
colorBlue = input.color(color.blue, 'No Squeeze', group=GRP3)


//--------BMA------

BMA = 0.0
BMA := MA_type == 'SMA' ? ta.sma(MA_source, MA_length) : MA_type == 'EMA' ? ta.ema(MA_source, MA_length) : MA_type == 'WMA' ? ta.vwma(MA_source, MA_length) : na

p1 = plot(BMA, title='Bollingerised Moving Average', color=MA_color, linewidth=MA_width)



//--------SQUEEZE------
// original concept from John Carter's book "Mastering the Trade"
// based on LazyBear's script (Squeeze Momentum Indicator) https://in.tradingview.com/script/nqQ1DT5a-Squeeze-Momentum-Indicator-LazyBear/


devBB = BB_stdev_far * ta.stdev(MA_source, MA_length)
devKC = ta.sma(ta.tr, MA_length)


//Bollinger 2x
upBB = BMA + devBB * 2
lowBB = BMA - devBB * 2

//Keltner 2x
upKCWide = BMA + devKC * 2
lowKCWide = BMA - devKC * 2

//Keltner 1.5x
upKCNormal = BMA + devKC * 1.5
lowKCNormal = BMA - devKC * 1.5

//Keltner 1x
upKCNarrow = BMA + devKC
lowKCNarrow = BMA - devKC

sqzOnWide = lowBB >= lowKCWide and upBB <= upKCWide  //Low-compression Squeeze: YELLOW
sqzOnNormal = lowBB >= lowKCNormal and upBB <= upKCNormal  //Mid-compression Squeeze: ORANGE
sqzOnNarrow = lowBB >= lowKCNarrow and upBB <= upKCNarrow  //High-compression Squeeze: RED
sqzOffWide = lowBB < lowKCWide and upBB > upKCWide  //Fired Squeeze: GREEN
noSqz = sqzOnWide == false and sqzOffWide == false  //No Squeeze: BLUE


sq_color = noSqz ? colorBlue : sqzOnNarrow ? colorRed : sqzOnNormal ? colorOrange : sqzOnWide ? colorYellow : colorGreen

bb_colorOne = toggleSQZColors ? color.new(sq_color, 80) : colorOrangeOne
bb_colorHalf = toggleSQZColors ? color.new(sq_color, 80) : colorOrangeHalf



//--------BOLLINGER BANDS------

upper = BMA + devBB
lower = BMA - devBB

p2 = plot(BB_show_upper ? upper : na, 'Upper Far Band', color=color.new(color.orange, 100))
p3 = plot(BB_show_lower ? lower : na, 'Lower Far Band', color=color.new(color.red, 100))
fill(p1, p2, title='BB Background', color=bb_colorOne)
fill(p1, p3, title='BB Background', color=bb_colorOne)

devhalf = BB_stdev_near * ta.stdev(close, 20)
upperhalf = BMA + devhalf
lowerhalf = BMA - devhalf

p4 = plot(BB_show_upper ? upperhalf : na, 'Upper Near Band', color=color.new(color.orange, 100))
p5 = plot(BB_show_lower ? lowerhalf : na, 'Lower Near Band', color=color.new(color.red, 100))
fill(p1, p4, title='BB Background', color=bb_colorHalf)
fill(p1, p5, title='BB Background', color=bb_colorHalf)



//MarketCap Category + Market Cap Value (Enhanced)
//────────────────────────────────────
// 1. USER INPUTS
//────────────────────────────────────
posInput      = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Centre Left", "Cenre Right", "Bottom Centre"])
fontSizeInput = input.string("Normal", "Font size", options = ["Tiny", "Small", "Normal", "Large", "Huge"])
fontSize      = fontSizeInput == "Tiny" ? size.tiny : fontSizeInput == "Small" ? size.small : fontSizeInput == "Large" ? size.large : fontSizeInput == "Huge" ? size.huge : size.normal

showSymbol     = input.bool(true,  "Show Symbol")
showSector     = input.bool(true,  "Show Sector")
showIndustry   = input.bool(true,  "Show Industry")
showCapCat     = input.bool(true,  "Show Market Cap Category")
showMcapValue  = input.bool(true,  "Show Market Cap (₹ Cr)")  // NEW

headerBgColor   = input.color(color.new(color.black, 85), "Header background")
headerTextColor = input.color(color.blue,                 "Header text color")
valueTextColor  = input.color(color.blue,                 "Value text color")
valueBgColor    = input.color(color.new(color.black, 85), "Value background")
borderColor     = input.color(color.new(color.black, 0),  "Border color")
borderWidth     = input.int(2, "Border width", minval = 0, maxval = 5)

tablePos =
     posInput == "Top Left" ? position.top_left :
     posInput == "Bottom Left" ? position.bottom_left :
     posInput == "Bottom Right" ? position.bottom_right :
     posInput == "Centre Left" ? position.middle_left :
     posInput == "Cenre Right" ? position.middle_right :
     posInput == "Bottom Centre" ? position.bottom_center :
     position.top_right

//────────────────────────────────────
// 2. BASIC INFO
//────────────────────────────────────
ticker   = syminfo.ticker
exchange = syminfo.prefix
sector   = syminfo.sector
industry = syminfo.industry

sector_text   = na(sector)   ? "N/A" : sector
industry_text = na(industry) ? "N/A" : industry

//────────────────────────────────────
// 3. MARKET CAP (INDIA) IN ₹ CRORES
//────────────────────────────────────
shares_outstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")
market_cap_raw     = na(shares_outstanding) ? na : shares_outstanding * close
market_cap_cr      = na(market_cap_raw) ? na : (market_cap_raw / 1e7)  // to Crores

// Format number with commas: 12345 → "12,345"
f_format_num(num) =>
    na(num) ? "N/A" : str.format("{0,number,#,###}", num)

// Final formatted text for table
market_cap_text = na(market_cap_cr) ? "N/A" : "₹ " + f_format_num(math.round(market_cap_cr)) + " Cr"

//────────────────────────────────────
// 4. MARKET CAP CATEGORY
//────────────────────────────────────
f_cap_category(mcap) =>
    if na(mcap)
        "N/A"
    else if mcap >= 20000
        "LARGE CAP"
    else if mcap >= 5000
        "MID CAP"
    else
        "SMALL CAP"

cap_category = f_cap_category(market_cap_cr)

//────────────────────────────────────
// 5. TABLE FUNCTIONS
//────────────────────────────────────
var info_table = table.new(tablePos, 11, 11)

f_put_row(_label, _value, _rowIndex) =>
    table.cell(info_table, 0, _rowIndex, _label,
         text_color=headerTextColor, text_size=fontSize, text_halign=text.align_left, bgcolor=headerBgColor)
    table.cell(info_table, 1, _rowIndex, _value,
         text_color=valueTextColor, text_size=fontSize, text_halign=text.align_left, bgcolor=valueBgColor)

//────────────────────────────────────
// 6. RENDER TABLE
//────────────────────────────────────
if barstate.islast
    table.set_position(info_table, tablePos)
    table.set_border_width(info_table, borderWidth)
    table.set_border_color(info_table, borderColor)
    table.clear(info_table, 0, 0, 10, 2)

    row = 0

    if showSymbol
        f_put_row("Symbol", exchange + ":" + ticker, row)
        row += 1

    if showSector
        f_put_row("Sector", sector_text, row)
        row += 1

    if showIndustry
        f_put_row("Industry", industry_text, row)
        row += 1

    if showCapCat
        f_put_row("Market Cap Cat", cap_category, row)
        row += 1

    if showMcapValue
        f_put_row("MCap (₹ Cr)", market_cap_text, row)
        row += 1
````
