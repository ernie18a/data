# Delta Position Sizer - 1:3 RR Dashboard ALM

- url: https://www.tradingview.com/script/xa6qCFLl-Delta-Position-Sizer-1-3-RR-Dashboard-ALM/
- type: indicator
- pine_id: PUB;e1e7ea9bfb6b407e940f84a116d7d663
- version: 1.0

## Description

This dashboard is only for position sizing. it will calculate the stoploss and target and leverage . just we have to place the entry price and the loss percentage

## Source Code

````pine
//@version=6
indicator('Delta Position Sizer - 1:3 RR Dashboard', overlay = true)

// --- INTERACTIVE PROMPT INPUTS ---
entry_price = input.float(0.0, title = 'Type Your Entry Price', confirm = true, tooltip = 'Enter your exact manual entry price level here.')
sl_pct = input.float(0.75, title = 'Stop Loss Percentage (%)', confirm = true, tooltip = 'Type your custom stop loss percentage for this trade (e.g., 0.50 or 0.75).')
trade_dir = input.string('Long', title = 'Trade Direction', options = ['Long', 'Short'], confirm = true)
theme_mode = input.string('Dark', title = 'Dashboard Style Theme', options = ['Dark', 'Light'])

// --- FIXED ACCOUNT PROFILE ---
var float capital = 581.41
var float risk_pct = 2.0
var float rr_multiplier = 3.0 // UPDATED: Ratio scaled up from 2.0 to 3.0
var float fee_pct = 0.05

// --- AUTOMATIC DELTA CONTRACT MULTIPLIER ---
get_multiplier() =>
    if syminfo.basecurrency == 'BTC'
        0.001
    else if syminfo.basecurrency == 'ETH'
        0.01
    else
        1.0

// --- FIXED MATHEMATICS ENGINE ---
multiplier = get_multiplier()

sl_factor = sl_pct / 100.0
tp_factor = sl_pct * rr_multiplier / 100.0

// Calculate Target Figures dynamically based on your custom stop loss percentage
target_sl = trade_dir == 'Long' ? entry_price * (1.0 - sl_factor) : entry_price * (1.0 + sl_factor)
target_tp = trade_dir == 'Long' ? entry_price * (1.0 + tp_factor) : entry_price * (1.0 - tp_factor)

// Total Position Size Matrix (Includes 2x Fees)
total_loss_pct = sl_factor + 2.0 * (fee_pct / 100.0)
max_risk_usd = capital * (risk_pct / 100.0)
target_win_usd = max_risk_usd * rr_multiplier

// Dynamic Position footprint calculations based on your custom inputs
position_size = entry_price > 0.0 and total_loss_pct > 0.0 ? max_risk_usd / total_loss_pct : 0.0
delta_contracts = position_size > 0.0 and entry_price > 0.0 ? position_size / (entry_price * multiplier) : 0.0

// Leverage calculation formula
required_leverage = position_size / capital

// --- DYNAMIC ON-CHART VISUAL TRACKING LINES ---
var line entry_ln = line.new(na, na, na, na, color = color.blue, width = 2, style = line.style_dashed)
var line sl_ln = line.new(na, na, na, na, color = color.red, width = 2, style = line.style_solid)
var line tp_ln = line.new(na, na, na, na, color = color.green, width = 2, style = line.style_solid)

// --- HIGH-VISIBILITY ACCENT TEXT LABELS ---
var label entry_lbl = label.new(na, na, '', color = color.blue, textcolor = color.white, style = label.style_label_left, size = size.small)
var label sl_lbl = label.new(na, na, '', color = color.red, textcolor = color.white, style = label.style_label_left, size = size.small)
var label tp_lbl = label.new(na, na, '', color = color.green, textcolor = color.white, style = label.style_label_left, size = size.small)

if barstate.islast and entry_price > 0.0
    // Project tracking lines forward into empty future canvas space
    line.set_xy1(entry_ln, bar_index - 40, entry_price)
    line.set_xy2(entry_ln, bar_index + 15, entry_price)

    line.set_xy1(sl_ln, bar_index - 40, target_sl)
    line.set_xy2(sl_ln, bar_index + 15, target_sl)

    line.set_xy1(tp_ln, bar_index - 40, target_tp)
    line.set_xy2(tp_ln, bar_index + 15, target_tp)

    // Plant text markers directly next to the line right-side end points
    label.set_xy(entry_lbl, bar_index + 16, entry_price)
    label.set_text(entry_lbl, 'Entry: ' + str.tostring(entry_price, '0.00'))

    label.set_xy(sl_lbl, bar_index + 16, target_sl)
    label.set_text(sl_lbl, 'SL (' + str.tostring(sl_pct, '0.00') + '%): ' + str.tostring(target_sl, '0.00'))

    label.set_xy(tp_lbl, bar_index + 16, target_tp)
    label.set_text(tp_lbl, 'TP (' + str.tostring(sl_pct * rr_multiplier, '0.00') + '%): ' + str.tostring(target_tp, '0.00'))

// --- THEME COLOR SELECTION SYSTEM ---
box_bg = theme_mode == 'Dark' ? color.new(color.black, 15) : color.new(color.white, 5)
text_main = theme_mode == 'Dark' ? color.white : color.black
header_bg = theme_mode == 'Dark' ? color.blue : color.navy

// --- UI HUD DASHBOARD BOX ---
var table info_box = table.new(position.top_right, 2, 9, bgcolor = box_bg, border_color = color.gray, border_width = 1)

if barstate.islast
    // Header Row
    table.cell(info_box, 0, 0, 'Delta Custom Setup', bgcolor = header_bg, text_color = color.white, text_size = size.small)
    table.cell(info_box, 1, 0, syminfo.ticker + ' (' + trade_dir + ')', bgcolor = header_bg, text_color = color.white, text_size = size.small)

    // Total Capital Row
    table.cell(info_box, 0, 1, 'Total Capital:', bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 1, '$' + str.tostring(capital, '0.00'), bgcolor = box_bg, text_color = color.green, text_size = size.small, text_halign = text.align_right)

    // Manual Input Verification Row
    table.cell(info_box, 0, 2, 'Your Manual Entry:', bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 2, entry_price > 0.0 ? str.tostring(entry_price, '0.00') : 'Type Price', bgcolor = box_bg, text_color = color.blue, text_size = size.small, text_halign = text.align_right)

    // Risk Details
    table.cell(info_box, 0, 3, 'Max Risk (Fees Inc):', bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 3, '$' + str.tostring(max_risk_usd, '0.00'), bgcolor = box_bg, text_color = color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(info_box, 0, 4, 'Target Profit (1:3):', bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 4, '$' + str.tostring(target_win_usd, '0.00'), bgcolor = box_bg, text_color = color.green, text_size = size.small, text_halign = text.align_right)

    // Calculated Price Levels
    table.cell(info_box, 0, 5, 'Stop Loss Price:', bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 5, entry_price > 0.0 ? str.tostring(target_sl, '0.00') : 'Waiting...', bgcolor = box_bg, text_color = color.orange, text_size = size.small, text_halign = text.align_right)

    table.cell(info_box, 0, 6, 'Take Profit Price:', bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 6, entry_price > 0.0 ? str.tostring(target_tp, '0.00') : 'Waiting...', bgcolor = box_bg, text_color = color.purple, text_size = size.small, text_halign = text.align_right)

    // Position Allocation & Required Leverage combined into a single row
    pos_text_format = position_size > 0.0 ? '$' + str.tostring(position_size, '0.00') + ' (' + str.tostring(required_leverage, '0.00') + 'x)' : '$0.00 (0.00x)'
    table.cell(info_box, 0, 7, 'Total Position Size:', bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 7, pos_text_format, bgcolor = box_bg, text_color = text_main, text_size = size.small, text_halign = text.align_right)

    // DELTA TICKET FIELD COPY FIELD
    table.cell(info_box, 0, 8, 'Delta Order Qty:', bgcolor = color.green, text_color = color.black, text_size = size.small, text_halign = text.align_left)
    table.cell(info_box, 1, 8, delta_contracts > 0.0 ? str.tostring(delta_contracts, '0.000') + ' Lots' : '0.000 Lots', bgcolor = color.green, text_color = color.black, text_size = size.small, text_halign = text.align_right)
````
