# Liquidation Tracker Pro v7 - Ultimate Portfolio & Risk Dashboard

- url: https://www.tradingview.com/script/Bv9ELHPA-Liquidation-Tracker-Pro-v7-Ultimate-Portfolio-Risk-Dashboard/
- type: indicator
- pine_id: PUB;bd8b66f31cf346a78376cb85da0f379a
- version: 2.0

## Description

Liquidation Tracker Pro v7 - Ultimate Portfolio & Risk Dashboard

Description:

Managing multiple leveraged positions across different assets can be chaotic. The Liquidation Tracker Pro v7 is designed to be your all-in-one on-chart command center. Whether you are scalping or managing long-term swing trades, this tool brings your entire portfolio's risk profile directly to your active chart.

Instead of constantly checking your exchange app, this indicator visualizes your entries, breakeven points, PnL, and exact liquidation levels (both Isolated and Cross margin) in real-time.

🌟 Key Features

Comprehensive Risk Dashboard: A highly optimized, customizable "Card-Format" UI that displays your account balance, margin utilization (%), and total PnL. It neatly organizes up to 6 manual positions.

Advanced Liquidation & Breakeven Math: Calculates precise Breakeven prices and Liquidation levels by factoring in your specific exchange's Maker/Taker fees and Maintenance Margin Rates (MMR). Includes built-in presets for Binance, Bybit, MEXC, OKX, and LBank.

Cross & Isolated Margin Tracking: Automatically calculates your liquidation points depending on whether your risk is isolated to the trade or shared across your account balance.

Unique Auto-Ladder Simulation: Planning to DCA (Dollar Cost Average) into a losing position? The built-in laddering feature lets you input a percentage to automatically calculate your newly diluted entry price and updated PnL, allowing you to visualize "saving" a trade before actually placing the orders.

On-Chart Visuals: Plots clean, dynamic lines and labels directly on your chart for Breakeven, Isolated Liquidation, and Cross Liquidation levels so you know exactly where your risk zones are.

Proximity Alerts: Set a custom safety threshold (e.g., 5%). If price action gets too close to your liquidation level, the indicator will fire an alert to warn you before the exchange does.

⚙️ How to Use

Configure General Settings: Enter your total account balance and select your exchange from the dropdown to ensure accurate fee calculations.

Input Your Positions: Open the indicator settings and input your current trades (up to 6). Toggle them "On" and input the Ticker, Long/Short direction, Leverage, Entry Price, and Margin used.

Customize the UI: Adjust the table position, text size, and background opacity to fit your chart layout. If you are tracking many positions, enable Landscape Mode to split the dashboard into dual tables and save vertical screen space.

💡 Who is this for?

This tool is perfect for multi-asset day traders, swing traders, and risk managers who need a crystal-clear, centralized view of their exposure and liquidation risks without leaving their TradingView charts.

Disclaimer: This indicator is for informational and educational purposes only. Always verify your actual liquidation prices and margin requirements directly with your exchange, as API data and fast-moving markets can result in slight discrepancies.

## Source Code

````pine
//@version=6
indicator("Liquidation Tracker Pro v7", shorttitle="LTP7-Reg_W", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=100)

// === TYPE DEFINITION ===
type Pos
    string sym
    bool is_long
    float lev
    float entry
    float margin
    float ladder_pct 
    bool isolate_ladder 
    float size_usd
    float init_fee

// === POSITIONS & DATA STRUCTURE ===
var positions = array.new<Pos>()

f_add_pos_manual(enable, sym, long, lev, entry, margin, ladder, isolate, taker_rate, exchange) =>
    if enable and str.length(sym) > 0 and margin > 0.001
        float size_usd = margin * lev
        float initial_fee = taker_rate * size_usd 
        array.push(positions, Pos.new(exchange + ":" + sym, long, lev, entry, margin, ladder, isolate, size_usd, initial_fee))

// === GENERAL SETTINGS ===
group_gen = "General"
enable_dashboard = input.bool(true, "Enable Dashboard", group=group_gen, inline="gen1")
realtime = input.bool(true, "Real-Time Updates", group=group_gen, inline="gen1")
account_balance = input.float(10000.0, "Account Size ($)", minval=1.0, group=group_gen, inline="gen2")
exchange = input.string("MEXC", "Exchange", options=["Bybit", "Binance", "MEXC", "OKX", "LBank"], group=group_gen, inline="gen2")
alert_liq_threshold = input.float(5.0, "Alert if Liq Dist < %", minval=0.1, maxval=50, group=group_gen)
landscape_mode = input.bool(false, "Landscape Mode (Split Tables)", group=group_gen)

// Fee presets
mmr_rate = switch exchange
    "Bybit"   => 0.005
    "Binance" => 0.005
    "MEXC"    => 0.005
    "OKX"     => 0.005
    "LBank"   => 0.005
    => 0.005

taker_rate = switch exchange
    "Bybit"   => 0.00055
    "Binance" => 0.0004
    "MEXC"    => 0.0005
    "OKX"     => 0.0005
    "LBank"   => 0.0006
    => 0.0005

// === DISPLAY & VISUALS ===
group_disp = "Display & Formatting"
table_pos_input = input.string("top_right", "Table Position", options=["top_left", "top_right", "middle_right", "bottom_right"], group=group_disp, inline="disp1")
text_size = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=group_disp, inline="disp1") 
input_show_title = input.bool(true, "Show Indicator Title", group=group_disp, inline="disp2")
input_show_summary = input.bool(true, "Show Summary Row", group=group_disp, inline="disp2")

// --- COLORS ---
group_colors = "Colors & Opacity"
main_bg_color = input.color(color.new(color.black, 0), "Base BG", group=group_colors, inline="col1")
dynamic_bg_opacity = input.int(15, "Dyn. BG Opacity (%)", minval=0, maxval=100, step=5, group=group_colors, inline="col1")

title_bg_color = input.color(color.new(#3498DB, 70), "Title BG", group=group_colors, inline="col2")
pos_header_bg_color = input.color(color.new(#34495E, 50), "Pos Header BG", group=group_colors, inline="col2")

pnl_pos_bg_base = input.color(color.new(color.green, 100), "Pos PnL Base", group=group_colors, inline="col3") 
pnl_neg_bg_base = input.color(color.new(color.red, 100), "Neg PnL Base", group=group_colors, inline="col3") 
liq_warn_bg_base = input.color(color.new(color.red, 100), "Liq Warn Base", group=group_colors, inline="col3") 

pnl_pos_text_color = input.color(color.green, "Pos PnL Text", group=group_colors, inline="col4")
pnl_neg_text_color = input.color(color.red, "Neg PnL Text", group=group_colors, inline="col4")

// --- ON-CHART PLOTS ---
group_plots = "On-Chart Plots"
plot_lines = input.bool(true, "Show BE/Liq Lines", group=group_plots, inline="plt1")
input_show_labels = input.bool(true, "Show Labels", group=group_plots, inline="plt1")
be_line_color = input.color(color.new(color.yellow, 20), "BE Color", group=group_plots, inline="plt2")
liq_i_color = input.color(color.new(color.red, 20), "Liq (Iso) Color", group=group_plots, inline="plt2")
liq_c_color = input.color(color.new(color.orange, 20), "Liq (Cross) Color", group=group_plots, inline="plt2")
label_bg_color = input.color(color.new(color.black, 50), "Label BG", group=group_plots, inline="plt3")
decimals = input.int(9, "Decimals (Low Prices)", minval=2, maxval=10, group=group_plots, inline="plt3")

ts = switch text_size
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.large

dyn_decimals(p) =>
    if na(p) or p <= 0
        decimals
    else if p >= 100
        2
    else if p >= 1
        4
    else if p >= 0.0001
        6
    else
        decimals

f_format(p) =>
    if na(p)
        "N/A"
    else if p <= 0
        str.tostring(p, "#.#########")
    else
        str.tostring(p, "#." + str.repeat("#", dyn_decimals(p)))

// --- COMPACT POSITION INPUT BLOCKS ---
// Position 1
group1 = "Position 1"
enable1 = input.bool(true, "Enable", group=group1, inline="p1a")
sym1 = input.string("BTCUSDT.P", "Sym", group=group1, inline="p1a")
long1 = input.bool(true, "Long?", group=group1, inline="p1a")
lev1 = input.float(10.0, "Lev", minval=1.0, group=group1, inline="p1a")
entry1 = input.float(60000, "Entry $", minval=1e-10, group=group1, inline="p1b")
margin1 = input.float(100, "Margin $", minval=0.01, group=group1, inline="p1b")
ladder1 = input.float(100.0, "Auto-Ladder %", minval=0, maxval=1000, group=group1, inline="p1c") / 100
isolate1 = input.bool(false, "Isolate Ladder to this Pos", group=group1, inline="p1c")

// Position 2
group2 = "Position 2"
enable2 = input.bool(true, "Enable", group=group2, inline="p2a")
sym2 = input.string("ETHUSDT.P", "Sym", group=group2, inline="p2a")
long2 = input.bool(true, "Long?", group=group2, inline="p2a")
lev2 = input.float(10.0, "Lev", minval=1.0, group=group2, inline="p2a")
entry2 = input.float(2000, "Entry $", minval=1e-10, group=group2, inline="p2b")
margin2 = input.float(100, "Margin $", minval=0.01, group=group2, inline="p2b")
ladder2 = input.float(0.0, "Auto-Ladder %", minval=0, maxval=1000, group=group2, inline="p2c") / 100
isolate2 = input.bool(false, "Isolate Ladder to this Pos", group=group2, inline="p2c")

// Position 3
group3 = "Position 3"
enable3 = input.bool(true, "Enable", group=group3, inline="p3a")
sym3 = input.string("SOLUSDT", "Sym", group=group3, inline="p3a")
long3 = input.bool(true, "Long?", group=group3, inline="p3a")
lev3 = input.float(50.0, "Lev", minval=1.0, group=group3, inline="p3a")
entry3 = input.float(90.0, "Entry $", minval=1e-10, group=group3, inline="p3b")
margin3 = input.float(50.0, "Margin $", minval=0.01, group=group3, inline="p3b")
ladder3 = input.float(1.0, "Auto-Ladder %", minval=0, maxval=1000, group=group3, inline="p3c") / 100
isolate3 = input.bool(true, "Isolate Ladder to this Pos", group=group3, inline="p3c") 

// Position 4
group4 = "Position 4"
enable4 = input.bool(true, "Enable", group=group4, inline="p4a")
sym4 = input.string("PEPEUSDT", "Sym", group=group4, inline="p4a")
long4 = input.bool(true, "Long?", group=group4, inline="p4a")
lev4 = input.float(200, "Lev", minval=1.0, group=group4, inline="p4a")
entry4 = input.float(0.00001, "Entry $", minval=1e-10, group=group4, inline="p4b")
margin4 = input.float(10.0, "Margin $", minval=0.01, group=group4, inline="p4b")
ladder4 = input.float(1.0, "Auto-Ladder %", minval=0, maxval=1000, group=group4, inline="p4c") / 100
isolate4 = input.bool(false, "Isolate Ladder to this Pos", group=group4, inline="p4c")

// Position 5
group5 = "Position 5"
enable5 = input.bool(true, "Enable", group=group5, inline="p5a")
sym5 = input.string("WLFIUSDT", "Sym", group=group5, inline="p5a")
long5 = input.bool(false, "Long?", group=group5, inline="p5a")
lev5 = input.float(100.0, "Lev", minval=1.0, group=group5, inline="p5a")
entry5 = input.float(10.0, "Entry $", minval=1e-10, group=group5, inline="p5b")
margin5 = input.float(10.0, "Margin $", minval=0.01, group=group5, inline="p5b")
ladder5 = input.float(1.0, "Auto-Ladder %", minval=0, group=group5, inline="p5c") / 100
isolate5 = input.bool(false, "Isolate Ladder", group=group5, inline="p5c")

// Position 6
group6 = "Position 6"
enable6 = input.bool(false, "Enable", group=group6, inline="p6a")
sym6 = input.string("P", "Sym", group=group6, inline="p6a")
long6 = input.bool(true, "Long?", group=group6, inline="p6a")
lev6 = input.float(1.0, "Lev", minval=1.0, group=group6, inline="p6a")
entry6 = input.float(1.0, "Entry $", minval=1e-10, group=group6, inline="p6b")
margin6 = input.float(1.0, "Margin $", minval=0.01, group=group6, inline="p6b")
ladder6 = input.float(1.0, "Auto-Ladder %", minval=0, group=group6, inline="p6c") / 100
isolate6 = input.bool(false, "Isolate Ladder", group=group6, inline="p6c")

// Build positions array on first bar
var prices = array.new<float>()
if barstate.isfirst
    array.clear(positions)
    f_add_pos_manual(enable1, sym1, long1, lev1, entry1, margin1, ladder1, isolate1, taker_rate, exchange)
    f_add_pos_manual(enable2, sym2, long2, lev2, entry2, margin2, ladder2, isolate2, taker_rate, exchange)
    f_add_pos_manual(enable3, sym3, long3, lev3, entry3, margin3, ladder3, isolate3, taker_rate, exchange)
    f_add_pos_manual(enable4, sym4, long4, lev4, entry4, margin4, ladder4, isolate4, taker_rate, exchange)
    f_add_pos_manual(enable5, sym5, long5, lev5, entry5, margin5, ladder5, isolate5, taker_rate, exchange)
    f_add_pos_manual(enable6, sym6, long6, lev6, entry6, margin6, ladder6, isolate6, taker_rate, exchange)
    prices := array.new<float>(array.size(positions), na)


update = realtime or barstate.isconfirmed
if update and array.size(positions) > 0
    for i = 0 to array.size(positions) - 1
        p = array.get(positions, i)
        float price = request.security(p.sym, timeframe.period, close, ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
        if not na(price) and price > 0
            array.set(prices, i, price)

liq_iso(p, curr) =>
    float adj = (1 / p.lev) + mmr_rate + taker_rate
    p.is_long ? p.entry * (1 - adj) : p.entry * (1 + adj)

be_price(p) =>
    float rt_fee = 2 * taker_rate
    p.is_long ? p.entry * (1 + rt_fee) : p.entry * (1 - rt_fee)

clean_sym(s) => str.replace(str.replace(s, exchange + ":", ""), "USDT.P", "")

// --- Central Ladder Isolation Logic ---
var int isolated_index = -1
if array.size(positions) > 0
    isolated_index := -1
    for i = 0 to array.size(positions) - 1
        p = array.get(positions, i)
        if p.isolate_ladder
            isolated_index := i
            break 
            
// --- HYBRID CALCULATION FUNCTION ---
f_calculate_totals(is_optimistic, isolated_idx) =>
    float total_pnl = 0.0
    float total_margin = 0.0
    float total_virtual_margin = 0.0
    float total_mm = 0.0
    float total_size = 0.0
    
    for i = 0 to array.size(positions) - 1
        p = array.get(positions, i)
        float curr = array.get(prices, i)
        
        total_margin += p.margin
        total_size += p.size_usd
        total_mm += mmr_rate * p.size_usd
        
        float pnl = na(curr) or curr <= 0 ? 0.0 : (p.is_long ? p.size_usd * (curr / p.entry - 1) : p.size_usd * (1 - curr / p.entry))
        total_pnl += pnl
        
        float effective_ladder_pct = is_optimistic ? 0.0 : (isolated_idx >= 0 ? (i == isolated_idx ? p.ladder_pct : 0.0) : p.ladder_pct)
            
        if effective_ladder_pct > 0
            float ladder_margin = math.abs(pnl) * effective_ladder_pct
            total_virtual_margin += ladder_margin
            float ladder_size = ladder_margin * p.lev
            total_mm += mmr_rate * ladder_size
            total_size += ladder_size
            
    float total_all_margin = total_margin + total_virtual_margin
    float used_pct = account_balance > 0 ? total_all_margin / account_balance * 100 : 0
    float effective_mm = total_mm + 2 * taker_rate * total_size
    float pnl_to_liq = effective_mm - account_balance
    
    [total_pnl, total_all_margin, total_size, effective_mm, pnl_to_liq, used_pct]

[risk_total_pnl, risk_total_all_margin, risk_total_size, risk_effective_mm, risk_pnl_to_liq, risk_used_pct] = f_calculate_totals(false, isolated_index)
[display_total_pnl, display_total_all_margin, display_total_size, display_effective_mm, display_pnl_to_liq, display_used_pct] = f_calculate_totals(true, -1) 

liq_cross(p, curr, this_pnl, risk_pnl_to_liq) =>
    float other_pnl = risk_total_pnl - this_pnl 
    float req_this = risk_pnl_to_liq - other_pnl
    float liq_pct = p.size_usd > 0 ? req_this / p.size_usd : 0.0
    p.is_long ? p.entry * (1 + liq_pct) : p.entry * (1 - liq_pct)

// --- ON-CHART PLOTS DATA ASSIGNMENT ---
var float liq_iso_plot_val = na   
var float be_plot_val = na        
var float liq_cross_plot_val = na
var float plot_cross_liq_final = na 

if plot_lines and enable_dashboard
    string chart_ticker_base = clean_sym(syminfo.ticker)
    for i = 0 to array.size(positions) - 1
        pos = array.get(positions, i)
        if clean_sym(pos.sym) == chart_ticker_base
            float curr_price = close
            float current_pnl = pos.is_long ? pos.size_usd * (curr_price / pos.entry - 1) : pos.size_usd * (1 - curr_price / pos.entry)
            liq_iso_plot_val := liq_iso(pos, curr_price)
            liq_cross_plot_val := liq_cross(pos, curr_price, current_pnl, risk_pnl_to_liq)
            be_plot_val := be_price(pos)
            break
        else
            liq_iso_plot_val := na
            liq_cross_plot_val := na
            be_plot_val := na

plot_cross_liq_final := liq_cross_plot_val > 0 and not na(liq_cross_plot_val) ? liq_cross_plot_val : na

plot(nz(be_plot_val), title="Breakeven", color=be_line_color, style=plot.style_line, display=plot_lines ? display.all : display.none)
plot(nz(liq_iso_plot_val), title="Liq Isolated", color=liq_i_color, style=plot.style_line, trackprice=true, display=plot_lines ? display.all : display.none)
plot(nz(plot_cross_liq_final), title="Liq Cross", color=liq_c_color, style=plot.style_line, trackprice=true, display=plot_lines ? display.all : display.none)

if barstate.islast and enable_dashboard and input_show_labels
    if not na(be_plot_val)
        label.new(bar_index, be_plot_val, text="BE: " + f_format(be_plot_val), color=label_bg_color, textcolor=be_line_color, style=label.style_label_right, size=ts, yloc=yloc.price)
    if not na(liq_iso_plot_val)
        label.new(bar_index, liq_iso_plot_val, text="Liq I: " + f_format(liq_iso_plot_val), color=label_bg_color, textcolor=liq_i_color, style=label.style_label_right, size=ts, yloc=yloc.price)
    if not na(plot_cross_liq_final)
        label.new(bar_index, plot_cross_liq_final, text="Liq C: " + f_format(plot_cross_liq_final), color=label_bg_color, textcolor=liq_c_color, style=label.style_label_right, size=ts, yloc=yloc.price)

// --- TABLE GENERATION (OPTIMIZED CARD FORMAT) ---
int opacity_val = 100 - dynamic_bg_opacity
int table_a_cols = 1
int table_b_cols = landscape_mode ? 1 : 0 

// FIXED: Separated the switch evaluation from the ternary operator
table_position_a_base = switch table_pos_input
    "top_left"     => position.top_left
    "top_right"    => position.top_right
    "middle_right" => position.middle_right
    "bottom_right" => position.bottom_right
    => position.bottom_right
        
table_position_a = landscape_mode ? position.bottom_right : table_position_a_base
table_position_b = landscape_mode ? position.bottom_left : position.bottom_right 

// Max rows dramatically reduced due to card format (Header + 1 Detail Row per position)
int max_rows = 2 + (array.size(positions) * 2) 
var info_table_a = table.new(table_position_a, table_a_cols, max_rows, bgcolor=main_bg_color, border_width=1)
var info_table_b = table.new(table_position_b, table_b_cols, max_rows, bgcolor=main_bg_color, border_width=1) 

if barstate.islast and enable_dashboard and array.size(positions) > 0
    table.clear(info_table_a, 0, 0, table_a_cols - 1, max_rows - 1)
    if landscape_mode and table_b_cols > 0
        table.clear(info_table_b, 0, 0, table_b_cols - 1, max_rows - 1)
        
    int row_a = 0
    int row_b = 0
    
    color summary_pnl_text_dynamic = display_total_pnl >= 0 ? pnl_pos_text_color : pnl_neg_text_color
    color summary_bg_dynamic = color.new(display_total_pnl >= 0 ? pnl_pos_bg_base : pnl_neg_bg_base, opacity_val)

    if input_show_title
        table.cell(info_table_a, 0, row_a, "Liquidation Tracker Pro v7", bgcolor=title_bg_color, text_color=color.white, text_size=ts, text_halign=text.align_center)
        row_a += 1
        if landscape_mode
            table.cell(info_table_b, 0, row_b, "Liquidation Tracker Pro v7 Cont.", bgcolor=title_bg_color, text_color=color.white, text_size=ts, text_halign=text.align_center)
            row_b += 1
        
    if input_show_summary
        string sum_text = str.format("Bal: {0,number,#} | Used: {1,number,#.#}% | PnL: {2,number,#.##}", account_balance, display_used_pct, display_total_pnl)
        if landscape_mode
            table.cell(info_table_a, 0, row_a, str.format("Bal: {0,number,#} | Used: {1,number,#.#}%", account_balance, display_used_pct), bgcolor=summary_bg_dynamic, text_color=summary_pnl_text_dynamic, text_size=ts)
            table.cell(info_table_b, 0, row_b, str.format("PnL: {0,number,#.##}", display_total_pnl), bgcolor=summary_bg_dynamic, text_color=summary_pnl_text_dynamic, text_size=ts)
            row_a += 1
            row_b += 1
        else
            table.cell(info_table_a, 0, row_a, sum_text, bgcolor=summary_bg_dynamic, text_color=summary_pnl_text_dynamic, text_size=ts, text_halign=text.align_center)
            row_a += 1
    
    // Process positions
    for i = 0 to array.size(positions) - 1
        p = array.get(positions, i)
        float curr = array.get(prices, i)
        bool valid_price = not na(curr) and curr > 0
        
        table table_ref = info_table_a
        int current_row = row_a
        bool is_table_a = true
        
        if landscape_mode and i >= math.ceil(float(array.size(positions)) / 2.0)
            table_ref := info_table_b
            current_row := row_b
            is_table_a := false
            
        float this_pnl = valid_price ? (p.is_long ? p.size_usd * (curr / p.entry - 1) : p.size_usd * (1 - curr / p.entry)) : na
        float pnl_pct = valid_price and p.size_usd > 0 ? this_pnl / p.size_usd * 100 : na
        
        color pos_pnl_text_col = valid_price ? (this_pnl >= 0 ? pnl_pos_text_color : pnl_neg_text_color) : color.white
        color entry_pnl_bg_dynamic = color.new(valid_price and this_pnl >= 0 ? pnl_pos_bg_base : pnl_neg_bg_base, opacity_val)

        float liq_i = valid_price ? liq_iso(p, curr) : na
        float dist_i = valid_price ? math.abs((curr - liq_i) / curr * 100) : na
        bool liq_is_warning = valid_price and dist_i < alert_liq_threshold
        color liq_bg_final = liq_is_warning ? color.new(liq_warn_bg_base, opacity_val) : entry_pnl_bg_dynamic

        // Card Header (Row 1)
        string clean_name = clean_sym(p.sym) + " " + str.tostring(math.round(p.lev)) + "x " + (p.is_long ? "(Long)" : "(Short)")
        table.cell(table_ref, 0, current_row, clean_name, bgcolor=pos_header_bg_color, text_color=color.white, text_size=ts, text_halign=text.align_center, text_formatting=text.format_bold)
        current_row += 1
        
        // Card Body (Row 2)
        if valid_price
            float be = be_price(p)
            float move_need = (be - curr) / curr * 100
            float liq_c = liq_cross(p, curr, this_pnl, risk_pnl_to_liq) 
            string liq_c_text = na(liq_c) or liq_c <= 0 ? "Zero" : f_format(liq_c)
            
            string card_text = str.format("Entry: {0} | PnL: {1,number,#.##} ({2,number,#.##}%)\n", f_format(p.entry), this_pnl, pnl_pct) +
                               str.format("BE: {0} | Req: {1,number,#.##}%\n", f_format(be), move_need) +
                               str.format("Liq C/I: {0} / {1} | Dist: {2,number,#.##}%", liq_c_text, f_format(liq_i), dist_i)
                               
            float eff_ladder_pct = isolated_index >= 0 ? (i == isolated_index ? p.ladder_pct : 0.0) : p.ladder_pct
            float ladder_margin = math.abs(this_pnl) * eff_ladder_pct 
            
            if ladder_margin > 0
                float ladder_size = ladder_margin * p.lev
                float dil_e = (p.size_usd + ladder_size) / ((p.size_usd / p.entry) + (ladder_size / curr)) 
                float dil_pct = (p.size_usd + ladder_size) > 0 ? (p.is_long ? (curr / dil_e - 1) : (1 - curr / dil_e)) * 100 : 0.0
                card_text += str.format("\nLadder: {0} | {1,number,#.##}%", f_format(dil_e), dil_pct)

            table.cell(table_ref, 0, current_row, card_text, bgcolor=liq_bg_final, text_color=pos_pnl_text_col, text_size=ts, text_halign=text.align_center)
            current_row += 1
            
        if is_table_a
            row_a := current_row
        else
            row_b := current_row

    // Alerts
    for i = 0 to array.size(positions) - 1
        p = array.get(positions, i)
        float curr = array.get(prices, i)
        if not na(curr) and curr > 0
            float dist = math.abs((curr - liq_iso(p, curr)) / curr * 100)
            if dist < alert_liq_threshold
                alert("⚠️ Liq Risk on " + clean_sym(p.sym) + ": " + f_format(curr) + " (Dist: " + str.tostring(dist, "#.#") + "%)", alert.freq_once_per_bar_close)

// ==========================================
// BRANDING / WATERMARK
// ==========================================
// Created as a non-var table to ensure it refreshes correctly with the dashboard
var table reggie_watermark = table.new(position.middle_left, 1, 1)

if barstate.islast
    // Use a specific text_size and a slightly more opaque color
    table.cell(reggie_watermark, 0, 0, "© Reggie_W", 
         text_size  = size.normal, 
         text_color = color.new(color.white, 60),
         bgcolor    = color.new(color.black, 100)) // 100 = Transparent BG
````
