# Risk Management [odnac]

- url: https://www.tradingview.com/script/u2WmXRWS/
- type: indicator
- pine_id: PUB;681c3493430d41bb9e3db89b799d2577
- version: 2.0

## Description

📌 Overview
This indicator helps you visually manage risk — the most critical aspect of trading. By entering your total capital, risk percentage, and leverage, it automatically calculates the optimal position size, required margin, and risk-to-reward ratio (R:R), and displays everything directly on the chart.

⚙️ Key Features
[list]
[*]Automatic Position Size Calculation — Calculates the optimal entry size based on your configured risk % and stop loss distance.
[*]R:R Visualization — Displays entry, stop loss, and take profit levels on the chart with colored fill zones and ratio labels at the center.
[*]Real-time PnL Tracking — Shows live profit/loss (% and amount) with leverage applied in the info table after entry.
[*]Market/Limit Entry Detection — Automatically displays B/S signals and triggers alerts when price reaches the entry level.
[*]Multi-Currency Support — Choose from 15 currency symbols including USD, EUR, JPY, and BTC.
[*]UI Customization — Freely adjust line colors, table position, and transparency to match your chart theme.[/list]

📋 Input Parameters
[quote]Total Capital            Total trading capital
Risk %                      Maximum loss allowed per trade
Leverage                 Leverage multiplier
Entry / Stop / TP     Set prices by clicking directly on the chart[/quote]

💡 Tips
[list=1]
[*]Set your levels in order: Entry → Stop Loss → Take Profit by clicking on the chart.
[*]It is recommended to only consider trades where R:R is at least 1:2 or higher.
[*]Always check the position size and required margin to avoid over-leveraging.
[*]Enable the B/S Signal alert condition to receive notifications at entry and exit points.[/list]

⚠️ Important Notes
Please review the entry detection logic below before using this indicator.

1. Entry signals are triggered by high/low touch, not by candle close.
If the entry price falls within the high-to-low range of the current forming candle, a signal may fire even if the closing price has not yet reached the entry level. Always verify actual order fills manually.

2. A ⚠️ Market Entry warning is shown when a market order is detected.
If the following conditions are met, the indicator assumes a market entry has likely already occurred and displays a warning on the entry label.

[list]
[*]Long position — The current candle opened below the entry price
[*]Short position — The current candle opened above the entry price[/list]

B/S signals are not displayed when a market entry is detected. Additionally, the actual fill price may differ from the configured entry price, so always confirm directly.
[image]https://www.tradingview.com/x/fI7E5h4H/[/image]

3. B/S Signal Label Behavior
B (Buy) or S (Sell) signals are only displayed on the chart when limit entry conditions are met. When the indicator detects a market entry (Warning state), it considers the position already entered and therefore no B/S signal label is generated.

🛠️ How to Set Up
[list=1]
[*]Capital & Risk — Enter your total capital and the risk percentage you are willing to accept per trade.
[*]Position Settings — Click on the chart in order: Entry Price → Stop Loss → Take Profit to define your range, then confirm.
[*]UI & Colors — Adjust colors and table position to match your personal chart theme.[/list]

## Source Code

````pine
//@version=6
indicator('Risk Management [odnac]', overlay = true, max_bars_back = 5000)

// ─── Inputs: Capital & Risk ───────────────────────────
var g1 = '💰 Capital & Risk'
total_capital  = input.float(10000, 'Total Capital', group = g1, display = display.all - display.status_line)
risk_percent   = input.float(1.0, 'Risk %', group = g1, step = 0.1, display = display.all - display.status_line)

// Currency dropdown → auto-mapped to symbol
currency_input = input.string('USD', 'Currency', group = g1,
     options = ['USD', 'EUR', 'JPY', 'GBP', 'KRW', 'CNY', 'CHF', 'AUD', 'CAD', 'HKD', 'SGD', 'INR', 'BTC', 'ETH', 'USDT'], display = display.all - display.status_line)

currency_sym = currency_input == 'USD'  ? '$'  :
               currency_input == 'EUR'  ? '€'  :
               currency_input == 'JPY'  ? '¥'  :
               currency_input == 'GBP'  ? '£'  :
               currency_input == 'KRW'  ? '₩'  :
               currency_input == 'CNY'  ? '¥'  :
               currency_input == 'CHF'  ? '₣'  :
               currency_input == 'AUD'  ? 'A$' :
               currency_input == 'CAD'  ? 'C$' :
               currency_input == 'HKD'  ? 'HK$':
               currency_input == 'SGD'  ? 'S$' :
               currency_input == 'INR'  ? '₹'  :
               currency_input == 'BTC'  ? '₿'  :
               currency_input == 'ETH'  ? 'Ξ'  :
               currency_input == 'USDT' ? '₮'  : '$'

// ─── Inputs: Position Settings ────────────────────────
var g2 = '📐 Position Settings'
leverage   = input.int(25, 'Leverage', group = g2, minval = 1, maxval = 125, display = display.all - display.status_line)
entry_p    = input.price(0, '1. Select Entry Price', group = g2, confirm = true, display = display.all - display.status_line)
stop_p     = input.price(0, '2. Select Stop Price', group = g2, confirm = true, display = display.all - display.status_line)
tp_p       = input.price(0, '3. Select Take Profit', group = g2, confirm = true, display = display.all - display.status_line)

// ─── Inputs: Colors & Display ─────────────────────────
var g3 = '🎨 UI & Chart Colors'
c_entry   = input.color(#4da6ff, 'Entry Line', group = g3, display = display.all - display.status_line)
c_stop    = input.color(#ff4d6d, 'Stop Loss Line', group = g3, display = display.all - display.status_line)
c_tp      = input.color(#00c88a, 'Take Profit Line', group = g3, display = display.all - display.status_line)
c_amber   = input.color(#ffb347, 'Warning Color', group = g3, display = display.all - display.status_line)
c_tp_fill = input.color(#00c88a, 'TP Fill Color', group = g3, display = display.all - display.status_line)
c_sl_fill = input.color(#ff4d6d, 'SL Fill Color', group = g3, display = display.all - display.status_line)
c_bg      = input.color(#111118, 'Table Background', group = g3, display = display.all - display.status_line)
c_label   = input.color(#9090b0, 'Table Label Text', group = g3, display = display.all - display.status_line)
c_text    = input.color(#e2e2f0, 'Table Value Text', group = g3, display = display.all - display.status_line)

// ─── Transparency Settings ────────────────────────────
var g_trans = '💡 Transparency Settings'
use_trans   = input.bool(true, 'Enable Transparency (Labels & Lines)', group = g_trans, display = display.all - display.status_line)
all_trans   = input.int(0, 'Transparency (0~100)', minval = 0, maxval = 100, group = g_trans, display = display.all - display.status_line)

// ─── Display Position ─────────────────────────────────
var g4 = '📊 Display Position'
tbl_pos_input = input.string('Top Right', 'Table Position', options = ['Top Right', 'Bottom Right', 'Top Left', 'Bottom Left'], group = g4, display = display.all - display.status_line)

// ─── Calculations ─────────────────────────────────────
sl_pct = entry_p != 0 ? math.abs(entry_p - stop_p) / entry_p * 100 : 0
tp_pct = entry_p != 0 ? math.abs(entry_p - tp_p) / entry_p * 100 : 0

risk_amt   = total_capital * (risk_percent / 100)
pos_size   = sl_pct > 0 ? risk_amt / (sl_pct / 100) : 0
req_margin = pos_size / leverage

sl_dist    = math.abs(entry_p - stop_p)
tp_dist    = math.abs(entry_p - tp_p)
current_rr = sl_dist > 0 ? tp_dist / sl_dist : 0
reward_amt = risk_amt * current_rr

// ─── State Variables ──────────────────────────────────
var int   entry_idx   = na
var int   end_idx     = na
var bool  fired_entry = false
var bool  fired_exit  = false

bool is_long = tp_p > entry_p

// Record the bar index when the indicator first loads in realtime
if barstate.isrealtime and na(entry_idx) and entry_p != 0
    entry_idx := bar_index

// Detect when price hits TP or SL and record exit bar
if not na(entry_idx) and na(end_idx) and entry_p != 0
    bool hit_tp = is_long ? high >= tp_p : low <= tp_p
    bool hit_sl = is_long ? low <= stop_p : high >= stop_p
    if hit_tp or hit_sl
        end_idx := bar_index

// Handle edge case where entry and exit occur on the same bar
bool is_instant_exit = not na(entry_idx) and not na(end_idx) and entry_idx == end_idx
int draw_start = na(entry_idx) ? na : (is_instant_exit ? entry_idx - 1 : entry_idx)
int draw_end   = na(end_idx) ? bar_index + 1 : (is_instant_exit ? end_idx + 1 : end_idx)

// ─── Entry / Exit Signal Logic ────────────────────────
bool after_entry_idx = not na(entry_idx) and bar_index >= entry_idx

// Warn if price has not reached the entry level yet
bool warn_long  = after_entry_idx and is_long     and entry_p != 0 and high < entry_p and not fired_entry
bool warn_short = after_entry_idx and not is_long and entry_p != 0 and low  > entry_p and not fired_entry

var bool warned = false
if (warn_long or warn_short) and not fired_entry
    warned := true

// Store the close price at the moment the market-entry warning fires
var float market_entry_price = na
if warned and na(market_entry_price)
    market_entry_price := close

bool has_warn    = warned
bool before_exit = na(end_idx) or bar_index <= end_idx

// Detect when price crosses the entry level
bool crossed_entry    = entry_p != 0 and ((close[1] < entry_p and close >= entry_p) or (close[1] > entry_p and close <= entry_p))
bool cond_entry_touch = after_entry_idx and not fired_entry and entry_p != 0 and ((low <= entry_p and high >= entry_p) or crossed_entry)

var bool entry_shown  = false
bool show_long_entry  = false
bool show_short_entry = false

if cond_entry_touch and not has_warn
    fired_entry  := true
    entry_shown  := true
    if is_long
        show_long_entry := true
    else
        show_short_entry := true

// Detect when price reaches TP or SL after entry
bool touch_tp = is_long ? high >= tp_p : low <= tp_p
bool touch_sl = is_long ? low <= stop_p : high >= stop_p
bool cond_exit_touch = after_entry_idx and fired_entry and entry_shown and not fired_exit and before_exit and entry_p != 0 and (touch_tp or touch_sl)

bool show_long_exit  = false
bool show_short_exit = false
if cond_exit_touch
    fired_exit := true
    if is_long
        show_long_exit := true
    else
        show_short_exit := true

// ─── PnL Calculation ──────────────────────────────────
bool  in_position  = (fired_entry and entry_shown) or has_warn
float actual_entry = has_warn and not na(market_entry_price) ? market_entry_price : entry_p

var float last_pnl_pct = na
var float last_pnl_amt = na
var bool  is_closed    = false

if fired_exit
    is_closed := true

bool pnl_update_allowed = in_position and not is_closed and (not has_warn or before_exit)

if pnl_update_allowed and actual_entry != 0
    float raw_pnl_pct = is_long ? (close - actual_entry) / actual_entry * 100 : (actual_entry - close) / actual_entry * 100
    last_pnl_pct := raw_pnl_pct * leverage
    last_pnl_amt := pos_size * (raw_pnl_pct / 100)

// ─── Alert ────────────────────────────────────────────
// Pine v6 requires alertcondition message to be a const string,
// so all four signal types are merged into a single condition.
bool any_signal = show_long_entry or show_short_entry or show_long_exit or show_short_exit
alertcondition(any_signal, 'B/S Signal', 'Risk Management [odnac]: Entry or Exit Signal Triggered')

// ─── Signal Shapes ────────────────────────────────────
plotshape(show_long_entry,  'Long Entry',  shape.labelup,   location.belowbar, color.green, textcolor=color.white, text='B', size=size.tiny, display = display.all - display.status_line)
plotshape(show_short_entry, 'Short Entry', shape.labeldown, location.abovebar, color.red,   textcolor=color.white, text='S', size=size.tiny, display = display.all - display.status_line)
plotshape(show_long_exit,   'Long Exit',   shape.labeldown, location.abovebar, color.red,   textcolor=color.white, text='S', size=size.tiny, display = display.all - display.status_line)
plotshape(show_short_exit,  'Short Exit',  shape.labelup,   location.belowbar, color.green, textcolor=color.white, text='B', size=size.tiny, display = display.all - display.status_line)

// ─── Chart Drawing ────────────────────────────────────
var line l_entry = na, var line l_stop = na, var line l_tp = na
var label lbl_entry = na, var label lbl_stop = na, var label lbl_tp = na
var linefill f_profit = na, var linefill f_loss = na

if barstate.islast
    // Clear previous drawings before redrawing
    line.delete(l_entry), line.delete(l_stop), line.delete(l_tp)
    label.delete(lbl_entry), label.delete(lbl_stop), label.delete(lbl_tp)
    linefill.delete(f_profit), linefill.delete(f_loss)

    if not na(draw_start)
        int center_idx       = math.round((draw_start + draw_end) / 2)
        int label_idx        = na(end_idx) ? bar_index + 2 : center_idx
        label_style          = na(end_idx) ? label.style_label_left : label.style_label_center
        int final_trans      = use_trans ? all_trans : 0
        int fixed_fill_alpha = 85

        // Draw entry, TP, and SL horizontal lines
        color entry_line_c = has_warn ? color.new(c_amber, final_trans) : color.new(c_entry, final_trans)
        l_entry := line.new(draw_start, entry_p, draw_end, entry_p, color=entry_line_c)
        l_tp    := line.new(draw_start, tp_p,    draw_end, tp_p,    color=color.new(c_tp, final_trans))
        l_stop  := line.new(draw_start, stop_p,  draw_end, stop_p,  color=color.new(c_stop, final_trans))

        // Fill zones between entry-TP (profit) and entry-SL (loss)
        f_profit := linefill.new(l_entry, l_tp,   color.new(c_tp_fill, fixed_fill_alpha))
        f_loss   := linefill.new(l_entry, l_stop, color.new(c_sl_fill, fixed_fill_alpha))

        // Format label text values
        formatted_reward    = str.format('{0,number,#,###.0}', reward_amt)
        formatted_risk      = str.format('{0,number,#,###.0}', risk_amt)
        string entry_label_text = (has_warn ? '⚠️ Market Entry\n' : '') + 'RR : ' + str.tostring(current_rr, '#.##')

        color entry_label_bg  = color.new(has_warn ? c_amber : c_entry, final_trans)
        color entry_label_txt = color.new(has_warn ? #111118 : color.white, final_trans)
        color tp_label_bg     = color.new(c_tp, final_trans)
        color sl_label_bg     = color.new(c_stop, final_trans)
        color white_trans     = color.new(color.white, final_trans)

        // Place labels at the midpoint of the drawn range
        lbl_entry := label.new(label_idx, entry_p, entry_label_text, color=entry_label_bg, textcolor=entry_label_txt, style=label_style, size=size.small)
        lbl_tp    := label.new(label_idx, tp_p,    str.tostring(tp_pct, '#.##') + '%\n+ ' + currency_sym + ' ' + formatted_reward, color=tp_label_bg, textcolor=white_trans, style=label_style, size=size.small)
        lbl_stop  := label.new(label_idx, stop_p,  str.tostring(sl_pct, '#.##') + '%\n- ' + currency_sym + ' ' + formatted_risk, color=sl_label_bg, textcolor=white_trans, style=label_style, size=size.small)

// ─── Info Table (11 rows: 0 ~ 10) ────────────────────
// row  0 : Total Capital
// row  1 : Risk %
// row  2 : Leverage
// row  3 : Stop Loss
// row  4 : Current R:R
// row  5 : Position Size
// row  6 : Required Margin
// row  7 : Watermark (merged)
// row  8 : Entry Price
// row  9 : Current Price
// row 10 : PnL
var string tbl_pos = tbl_pos_input == 'Top Right' ? position.top_right : tbl_pos_input == 'Bottom Right' ? position.bottom_right : tbl_pos_input == 'Top Left' ? position.top_left : position.bottom_left
var table T = table.new(tbl_pos, 2, 11, bgcolor=c_bg, border_width=1, border_color=#252535, frame_width=1, frame_color=#252535)

if barstate.islast
    // ── Static Info Rows ──
    table.cell(T, 0, 0, 'Total Capital', text_color=c_label, text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 0, currency_sym + ' ' + str.format('{0,number,#,###}', total_capital), text_color=c_text, text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 1, 'Risk ' + str.tostring(risk_percent, '#.##') + '%', text_color=c_label, text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 1, currency_sym + ' ' + str.format('{0,number,#,###.0}', risk_amt), text_color=c_stop, text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 2, 'Leverage', text_color=c_label, text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 2, 'x' + str.tostring(leverage), text_color=c_entry, text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 3, 'Stop Loss', text_color=c_label, text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 3, sl_pct > 0 ? str.tostring(sl_pct, '#.##') + '%' : '0', text_color=c_amber, text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 4, 'Current R:R', text_color=c_label, text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 4, '1 : ' + str.tostring(current_rr, '#.#'), text_color=c_tp, text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 5, 'POSITION SIZE', text_color=c_label, text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 5, pos_size > 0 ? str.format('{0,number,#,###.0}', pos_size) : '0', text_color=c_tp, text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 6, 'REQUIRED MARGIN', text_color=c_label, text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 6, req_margin > 0 ? str.format('{0,number,#,###.0}', req_margin) : '0', text_color=c_entry, text_size=size.small, text_halign=text.align_right)

    // ── Row 7: Watermark (merged across both columns) ──
    table.cell(T, 0, 7, 'odnac', text_color=color.new(#9090b0, 60), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(T, 0, 7, 1, 7)

    // ── Rows 8~10: Live PnL Section ──
    bool show_pnl_section = in_position or is_closed

    if show_pnl_section
        string entry_prefix = has_warn ? '≈ ' : ''
        string entry_label  = has_warn ? 'Entry (Market)' : 'Entry (Limit)'
        string entry_val    = actual_entry != 0 ? entry_prefix + str.tostring(actual_entry, '#.##') : '0'
        color  entry_val_c  = has_warn ? c_amber : c_entry

        table.cell(T, 0, 8, entry_label, text_color=c_label, text_size=size.small, text_halign=text.align_left)
        table.cell(T, 1, 8, entry_val,   text_color=entry_val_c, text_size=size.small, text_halign=text.align_right)

        table.cell(T, 0, 9, 'Current Price', text_color=c_label, text_size=size.small, text_halign=text.align_left)
        table.cell(T, 1, 9, is_closed ? str.tostring(close, '#.##') + ' ✓' : str.tostring(close, '#.##'), text_color=is_closed ? c_label : c_text, text_size=size.small, text_halign=text.align_right)

        if not na(last_pnl_pct)
            bool   is_profit   = last_pnl_pct >= 0
            color  pnl_color   = is_closed ? c_label : (is_profit ? c_tp : c_stop)
            string pnl_sign    = is_profit ? '+' : ''
            string pnl_pct_str = pnl_sign + str.tostring(last_pnl_pct, '#.##') + '%'
            string pnl_amt_str = pnl_sign + currency_sym + ' ' + str.format('{0,number,#,###.0}', last_pnl_amt)
            string closed_tag  = is_closed ? ' [closed]' : ''
            string pnl_display = pnl_pct_str + '  (' + pnl_amt_str + ')' + closed_tag

            table.cell(T, 0, 10, 'PnL (x' + str.tostring(leverage) + ')', text_color=c_label, text_size=size.small, text_halign=text.align_left)
            table.cell(T, 1, 10, pnl_display, text_color=pnl_color, text_size=size.small, text_halign=text.align_right)
        else
            table.cell(T, 0, 10, 'PnL (x' + str.tostring(leverage) + ')', text_color=c_label, text_size=size.small, text_halign=text.align_left)
            table.cell(T, 1, 10, '0', text_color=c_text, text_size=size.small, text_halign=text.align_right)
    else
        // Default state before any position is active
        table.cell(T, 0, 8,  'Entry', text_color=c_label, text_size=size.small, text_halign=text.align_left)
        table.cell(T, 1, 8,  '0', text_color=c_text, text_size=size.small, text_halign=text.align_right)
        table.cell(T, 0, 9,  'Current Price', text_color=c_label, text_size=size.small, text_halign=text.align_left)
        table.cell(T, 1, 9,  str.tostring(close, '#.##'), text_color=c_text, text_size=size.small, text_halign=text.align_right)
        table.cell(T, 0, 10, 'PnL (x' + str.tostring(leverage) + ')', text_color=c_label, text_size=size.small, text_halign=text.align_left)
        table.cell(T, 1, 10, '0', text_color=c_text, text_size=size.small, text_halign=text.align_right)
````
