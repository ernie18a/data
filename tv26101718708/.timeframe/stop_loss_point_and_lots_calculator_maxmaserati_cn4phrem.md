# Stop Loss Point and Lots Calculator @MaxMaserati

- url: https://www.tradingview.com/script/Cn4phREM-Stop-Loss-Point-and-Lots-Calculator-MaxMaserati/
- type: indicator
- pine_id: PUB;1f9a47375a274997b996455476bf9b16
- version: 1.0

## Description

Stop Loss Point and Lots Calculator

A risk and level-mapping tool for order execution, built to work across any market. You set an entry price (live price, a past candle's open/high/low/close, or a manual override), and the script projects stop and target lines out from that price, converts each level into dollar risk, and calculates the contract or position size that matches your chosen dollar risk. Distances are read in whichever unit fits the instrument you're trading, detected automatically.

─── DISTANCE UNIT DETECTION ───
The script reads the symbol type and picks the correct measurement unit on its own: forex pairs use pips (0.0001, or 0.01 for JPY pairs), crypto uses ticks (the exchange's minimum price increment), and futures, stocks, indices, and metals use points (a full 1.0 price move). Metals are checked separately from other forex-type symbols, since gold and silver are often tagged as forex on this platform but are not traded in pips. Any of these can be overridden - force Points, Ticks, or Pips on any symbol regardless of what Auto would choose, or type an exact manual unit size if a symbol's auto-detected value doesn't match your broker.

─── POSITION SIZING ───
Contracts = Risk Amount divided by (Stop Distance in units times Dollar Value Per Unit). Example: a $2,000 risk amount with a 20-unit stop and a $20-per-unit instrument gives 5 contracts. Auto sizing recalculates this live from your Risk Amount input; Manual mode lets you fix the size yourself. Every line the script draws reads this size to show its dollar value.

─── ANCHOR AND STOP LEVELS ───
The anchor line is your entry price - live price, the prior candle's open/high/low/close, or a manual price for a limit order that hasn't filled yet. Tier 1 is your stop distance; Tier 2 is your target distance. Both draw as lines above and below the anchor with shaded zones between them, each labeled with distance, size, and dollar value.

─── ADVANCED LEVELS ───
Two optional extra tiers (3 and 4) extend further out for scaling targets or wider invalidation. A background grid can also plot every level at three step sizes (small, medium, big) between the anchor and your outermost active tier, so you can read the dollar cost of any price level on the chart, not just the tiers you defined.

─── SESSION HIGH AND LOW LINES ───
Optional lines for today's high/low and yesterday's high/low, each labeled with distance and dollar value from your anchor. Useful for checking whether your stop or target sits inside or beyond a level the market has already respected.

─── HOW TO USE ───
1. Set Distance Unit to Auto, or force Points, Ticks, or Pips if you trade a specific instrument type consistently.
2. Set Anchor Price to Manual Price Override and type in your limit order price, or leave it on Last Candle Open/Close to anchor off the most recent bar.
3. Set Tier 1 Distance to your stop - this becomes your stop-loss line.
4. Set Tier 2 Distance to your target - this becomes your take-profit line.
5. Read the label on each line for the exact size and dollar value at your chosen risk before placing the order.
6. If the anchor sits on or very close to today's or yesterday's high/low line, treat that as a level the market has already tested and reconsider distance or entry timing.

1- [image]https://www.tradingview.com/x/UHg6weqi/[/image]
2- [image]https://www.tradingview.com/x/nK9ApeWQ/[/image]
3- [image]https://www.tradingview.com/x/vDwbZfWV/[/image]

─── SETTINGS ───
Position Sizing - distance unit selection, direction (long/short/neutral sign display), auto vs manual sizing, risk dollar amount, stop distance for the sizing formula, and which fields show on line labels.
Anchor and Stop Levels - anchor price source, manual override price, anchor and Tier 1/2 line styling, and Tier 1/2 distances.
Advanced Levels - optional Tier 3/4 distances and styling, plus the background grid with three step sizes.
Session High and Low Lines - toggle and style today's and yesterday's high/low lines.
Display Settings - line position and length offset from the current bar, label text size, and a manual unit-size override for instruments the auto-detection misreads.

─── NOTES ───
Today's and yesterday's high/low lines use a security call with lookahead intentionally enabled, because a completed day's high and low are historical values, not a forward-looking projection - this does not repaint the tier or anchor lines, which are all drawn from the live or last-closed price you select. Works on forex, crypto, futures, stocks, indices, and metals; the unit and its dollar value are detected per symbol, with a manual override available for any instrument.

## Source Code

````pine
//@version=6
indicator("Stop Loss Point and Lots Calculator @MaxMaserati",'SL Points & Lots Calculator @MaxMaserati', overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════════════
// 1. 💰 POINT VALUE CALCULATOR & RIGHT-SIDE LABELS
// ══════════════════════════════════════════════════════════════════
grp_dollar = "1. 💰 Point Value & Right-Side Labels"
trade_dir                 = input.string("Buy (Long)", "Trade Direction (Signs)", options=["Buy (Long)", "Sell (Short)", "Neutral"], group=grp_dollar, tooltip="Buy = + above, - below. Sell = - above, + below. Neutral = No +/- signs.")
contracts                 = input.int(1, "Number Of Contracts", minval=1, group=grp_dollar)
dollar_per_point_override = input.float(0.0, "Manual $ / Point (0 = Auto)", group=grp_dollar, tooltip="Leave at 0 to use TradingView's built-in point value. Enter your own (e.g. 2 for MNQ, 5 for MES) to override.")
symbol_override           = input.string("", "Manual Symbol Text (blank = Auto)", group=grp_dollar)

show_right_labels = input.bool(true, "Master Toggle: Show Right-Side Labels", group=grp_dollar)

// Granular right-side label controls:
lbl_show_pts_num = input.bool(true, "Show Point Value (e.g. 20)", inline="lbl1", group=grp_dollar)
lbl_show_pts_txt = input.bool(true, "Show 'pts' text", inline="lbl1", group=grp_dollar)
lbl_show_sym     = input.bool(true, "Show Contract (e.g. 1 MNQ)", inline="lbl2", group=grp_dollar)
lbl_show_dol     = input.bool(true, "Show Dollar Value (e.g. $10)", inline="lbl2", group=grp_dollar)
lbl_show_prc     = input.bool(false, "Show Price (e.g. 29613.50)", inline="lbl3", group=grp_dollar) // Default OFF as requested

// ══════════════════════════════════════════════════════════════════
// 2. 📍 ANCHOR & REFERENCE CENTER
// ══════════════════════════════════════════════════════════════════
grp_anchor = "2. 📍 Anchor & Reference Center"
anchor_mode    = input.string("Live Price", "Anchor Source", options=["Live Price", "Last Closed: Close", "Last Closed: Open", "Last Closed: High", "Last Closed: Low"], group=grp_anchor)
use_manual     = input.bool(false, "Override With Manual Price", inline="am1", group=grp_anchor)
manual_price   = input.float(29505.00, "", inline="am1", group=grp_anchor)

anchor_color   = input.color(color.new(#d84315, 0), "Anchor Line Color", inline="a1", group=grp_anchor)
anc_width      = input.int(1, "W", inline="a1", group=grp_anchor, minval=1)
anc_style      = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="a1", group=grp_anchor)
anc_show_left  = input.bool(true, "Extend Left", inline="a2", group=grp_anchor)
anc_show_right = input.bool(true, "Extend Right", inline="a3", group=grp_anchor)
anc_right_len  = input.int(10, "By (Bars)", inline="a3", group=grp_anchor, minval=0)
anc_show_label = input.bool(true, "Show Anchor Price Label", group=grp_anchor)

// ══════════════════════════════════════════════════════════════════
// 3. 🎯 RISK PROJECTIONS — CORE TIERS (1 & 2)
// ══════════════════════════════════════════════════════════════════
grp_rul = "3. 🎯 Core Tiers (1 & 2)"
tier_1_dist  = input.float(20.0, "Tier 1 Distance (Pts)", inline="rg1", group=grp_rul)
tier_2_dist  = input.float(50.0, "Tier 2 Distance (Pts)", inline="rg1", group=grp_rul)

t1_color     = input.color(color.new(color.gray, 20), "Tier 1 (Line)", inline="t1", group=grp_rul)
t1_width     = input.int(1, "W", inline="t1", group=grp_rul, minval=1)
t1_style     = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="t1", group=grp_rul)
zone_color_1 = input.color(color.new(color.gray, 85), "Fill 1", inline="t1", group=grp_rul)

t2_color     = input.color(color.new(color.black, 20), "Tier 2 (Line)", inline="t2", group=grp_rul)
t2_width     = input.int(1, "W", inline="t2", group=grp_rul, minval=1)
t2_style     = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="t2", group=grp_rul)
zone_color_2 = input.color(color.new(color.black, 85), "Fill 2", inline="t2", group=grp_rul)

show_zone_fills  = input.bool(true, "Show Background Fills", inline="tx1", group=grp_rul)
show_tier_labels = input.bool(true, "Show Left-Side Point Labels", inline="tx1", group=grp_rul)
tier_show_left   = input.bool(false, "Extend Lines Left", inline="tx2", group=grp_rul)
tier_show_right  = input.bool(false, "Extend Lines Right", inline="tx3", group=grp_rul)
tier_right_len   = input.int(10, "By (Bars)", inline="tx3", group=grp_rul, minval=0)

// ══════════════════════════════════════════════════════════════════
// 4. 🧭 EXTENDED RANGE — TIERS 3 & 4
// ══════════════════════════════════════════════════════════════════
grp_ext = "4. 🧭 Extended Tiers (3 & 4)"
show_tier_3  = input.bool(false, "Enable Tier 3", inline="e1", group=grp_ext)
tier_3_dist  = input.float(100.0, "Distance", inline="e1", group=grp_ext)
t3_color     = input.color(color.new(color.blue, 40), "Line", inline="e2", group=grp_ext)
t3_width     = input.int(1, "W", inline="e2", group=grp_ext, minval=1)
t3_style     = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="e2", group=grp_ext)
zone_color_3 = input.color(color.new(color.blue, 90), "Fill", inline="e2", group=grp_ext)

show_tier_4  = input.bool(false, "Enable Tier 4", inline="e3", group=grp_ext)
tier_4_dist  = input.float(200.0, "Distance", inline="e3", group=grp_ext)
t4_color     = input.color(color.new(color.purple, 40), "Line", inline="e4", group=grp_ext)
t4_width     = input.int(1, "W", inline="e4", group=grp_ext, minval=1)
t4_style     = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], inline="e4", group=grp_ext)
zone_color_4 = input.color(color.new(color.purple, 90), "Fill", inline="e4", group=grp_ext)

// ══════════════════════════════════════════════════════════════════
// 5. 🔳 INTERNAL GRID LINES
// ══════════════════════════════════════════════════════════════════
grp_grid = "5. 🔳 Internal Grid Steps"
show_grid_labels = input.bool(true, "Show Grid Labels (Left)", inline="gl0", group=grp_grid)
show_grid_lines  = input.bool(false, "Show Grid Lines", inline="gl0", group=grp_grid)
grid_line_style  = input.string("Dotted", "Line Style", options=["Solid", "Dotted", "Dashed"], inline="g1", group=grp_grid)
grid_show_right  = input.bool(true, "Extend Right Labels", inline="gl1", group=grp_grid)
grid_right_len   = input.int(10, "By (Bars)", inline="gl1", group=grp_grid, minval=0)

minor_step    = input.float(10.0, "Step A (Minor)", minval=1.0, inline="g2", group=grp_grid)
col_minor_pts = input.color(color.new(color.gray, 60), "Color", inline="g2", group=grp_grid)

major_step    = input.float(20.0, "Step B (Major)", minval=1.0, inline="g3", group=grp_grid)
col_major_pts = input.color(color.new(color.black, 40), "Color", inline="g3", group=grp_grid)

ext_step      = input.float(50.0, "Step C (Extended)", minval=1.0, inline="g4", group=grp_grid)
col_ext_pts   = input.color(color.new(color.orange, 30), "Color", inline="g4", group=grp_grid)

// ══════════════════════════════════════════════════════════════════
// 6. 📊 DYNAMIC MACRO BOUNDS (HTF)
// ══════════════════════════════════════════════════════════════════
grp_macro = "6. 📊 Macro Targets (HTF)"
show_today_range    = input.bool(false, "Show Today's High/Low (HOD/LOD)", group=grp_macro)
show_prev_day_range = input.bool(false, "Show Previous Day High/Low (PDH/PDL)", group=grp_macro)

macro_col = input.color(color.new(#ffaa00, 20), "Line Color", inline="m3", group=grp_macro)
macro_sty = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], inline="m3", group=grp_macro)

macro_show_left  = input.bool(false, "Extend Left", inline="m4", group=grp_macro)
macro_show_right = input.bool(true, "Extend Right", inline="m5", group=grp_macro)
macro_right_len  = input.int(10, "By (Bars)", inline="m5", group=grp_macro, minval=0)

bool show_hod = show_today_range
bool show_lod = show_today_range
bool show_pdh = show_prev_day_range
bool show_pdl = show_prev_day_range

// ══════════════════════════════════════════════════════════════════
// 7. ⚙️ GLOBAL & LAYOUT SETTINGS
// ══════════════════════════════════════════════════════════════════
grp_core = "7. ⚙️ Layout & Global Settings"
grid_offset  = input.int(15, "Grid Offset (Bars)", inline="l1", group=grp_core)
grid_length  = input.int(4,  "Grid Length (Bars)", inline="l1", group=grp_core)
global_label_size = input.string("Small", "Global Label Size", options=["Tiny", "Small", "Normal", "Large"], inline="l2", group=grp_core)
point_override    = input.float(0.0, "Manual Point Override", step=0.01, group=grp_core, tooltip="Leave at 0 for automatic point detection based on symbol.")


// ─── Helpers ───
get_point_multiplier() =>
    string t = syminfo.ticker
    float  m = 1.0
    if syminfo.type == "forex"
        m := syminfo.mintick * 10
    else if str.contains(t, "CL") or str.contains(t, "NG") or str.contains(t, "WTI")
        m := 0.01
    else if str.contains(t, "GC") or str.contains(t, "SI") or str.contains(t, "XAU")
        m := 0.1
    else if syminfo.type == "crypto"
        m := syminfo.mintick * 10
    m

float pt = point_override > 0 ? point_override : get_point_multiplier()
string lbl_sz_str = global_label_size == "Tiny" ? size.tiny : global_label_size == "Small" ? size.small : global_label_size == "Normal" ? size.normal : size.large

f_get_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

f_overlaps_tier(float level, array<float> tiers, float tol) =>
    bool found = false
    for lvl in tiers
        if math.abs(level - lvl) < tol
            found := true
            break
    found

// ─── Variables for Formatting ───
float dollar_per_point = dollar_per_point_override > 0 ? dollar_per_point_override : syminfo.pointvalue
string sym_label       = symbol_override != "" ? symbol_override : syminfo.root

// ─── Math/Sign Helper based on Trade Direction ───
f_get_sign(float dist_pts) =>
    string s = ""
    if dist_pts != 0
        if trade_dir == "Buy (Long)"
            s := dist_pts > 0 ? "+" : "-"
        else if trade_dir == "Sell (Short)"
            s := dist_pts > 0 ? "-" : "+"
    s

// ─── Smart Label Builder (Right Side) ───
f_build_right_label(float dist_pts, float price_level) =>
    string[] parts = array.new_string()
    
    // 1. Points Value (+20 pts)
    if lbl_show_pts_num
        string sign = f_get_sign(dist_pts)
        string p_str = sign + str.tostring(math.abs(dist_pts), "#.##")
        if lbl_show_pts_txt
            p_str += " pts"
        array.push(parts, p_str)
        
    // 2. Symbol (1 MNQ)
    if lbl_show_sym
        array.push(parts, str.tostring(contracts) + " " + sym_label)
        
    // 3. Dollar Value ($10)
    if lbl_show_dol
        float dollars = math.abs(dist_pts) * dollar_per_point * contracts
        array.push(parts, "$" + str.tostring(dollars, "#.##"))
        
    // 4. Price Level (29613.50)
    if lbl_show_prc
        array.push(parts, str.tostring(price_level, format.mintick))
        
    // Return combined string
    if array.size(parts) > 0
        array.join(parts, " | ")
    else
        ""

// ─── Left Side Simple Point Text ───
f_point_text(float dist_pts) =>
    string sign = f_get_sign(dist_pts)
    sign + str.tostring(math.abs(dist_pts), "#.##")

// ─── Data Fetching ───
[dy_h, dy_l, p_dy_h, p_dy_l] = request.security(syminfo.tickerid, "D", [high, low, high[1], low[1]], lookahead=barmerge.lookahead_on)

// ─── Arrays for Drawing Management ───
var lines_arr  = array.new_line()
var labels_arr = array.new_label()
var boxes_arr  = array.new_box()

// ─── Core Logic ───
if barstate.islast
    while lines_arr.size() > 0
        line.delete(lines_arr.pop())
    while labels_arr.size() > 0
        label.delete(labels_arr.pop())
    while boxes_arr.size() > 0
        box.delete(boxes_arr.pop())

    float anchor_price = na
    int origin_bar = bar_index

    if use_manual
        anchor_price := manual_price
        origin_bar := bar_index
    else if anchor_mode == "Live Price"
        anchor_price := close
        origin_bar := bar_index
    else if anchor_mode == "Last Closed: Close"
        anchor_price := close[1]
        origin_bar := bar_index - 1
    else if anchor_mode == "Last Closed: Open"
        anchor_price := open[1]
        origin_bar := bar_index - 1
    else if anchor_mode == "Last Closed: High"
        anchor_price := high[1]
        origin_bar := bar_index - 1
    else if anchor_mode == "Last Closed: Low"
        anchor_price := low[1]
        origin_bar := bar_index - 1

    if not na(anchor_price)
        // Base X Coordinates
        int grid_startX = bar_index + grid_offset
        int grid_endX   = grid_startX + grid_length
        int grid_midX   = math.round(math.avg(grid_startX, grid_endX))
        int lbl_510_X   = grid_startX - 1

        // Independent Right Extensions
        int anc_right_endX   = grid_endX + anc_right_len
        int tier_right_endX  = grid_endX + tier_right_len
        int macro_right_endX = grid_endX + macro_right_len
        int grid_right_endX  = grid_endX + grid_right_len

        string internal_style = f_get_style(grid_line_style)

        // Base Boundaries
        float up_1 = anchor_price + (tier_1_dist * pt)
        float up_2 = anchor_price + (tier_2_dist * pt)
        float dn_1 = anchor_price - (tier_1_dist * pt)
        float dn_2 = anchor_price - (tier_2_dist * pt)

        // Extended Boundaries
        float up_3 = anchor_price + (tier_3_dist * pt)
        float dn_3 = anchor_price - (tier_3_dist * pt)
        float up_4 = anchor_price + (tier_4_dist * pt)
        float dn_4 = anchor_price - (tier_4_dist * pt)

        // -------------------------------------------------------------
        // DYNAMIC OUTER BOUNDS CALCULATION
        // -------------------------------------------------------------
        float max_up = show_tier_4 ? up_4 : show_tier_3 ? up_3 : up_2
        float max_dn = show_tier_4 ? dn_4 : show_tier_3 ? dn_3 : dn_2

        if show_hod and not na(dy_h) and dy_h > max_up
            max_up := dy_h
        if show_pdh and not na(p_dy_h) and p_dy_h > max_up
            max_up := p_dy_h
        if show_lod and not na(dy_l) and dy_l < max_dn
            max_dn := dy_l
        if show_pdl and not na(p_dy_l) and p_dy_l < max_dn
            max_dn := p_dy_l

        // Label Placements (Right Side)
        int anc_lbl_x   = anc_show_right ? anc_right_endX : grid_endX
        int tier_lbl_x  = tier_show_right ? tier_right_endX : grid_endX
        int macro_lbl_x = macro_show_right ? macro_right_endX : grid_endX
        int grid_lbl_x  = grid_show_right ? grid_right_endX : grid_endX

        // -------------------------------------------------------------
        // DRAW THE ANCHOR
        // -------------------------------------------------------------
        lines_arr.push(line.new(grid_startX, anchor_price, grid_endX, anchor_price, color=anchor_color, width=anc_width, style=f_get_style(anc_style)))
        if anc_show_left
            lines_arr.push(line.new(origin_bar, anchor_price, grid_startX, anchor_price, color=anchor_color, width=anc_width, style=f_get_style(anc_style)))
        if anc_show_right
            lines_arr.push(line.new(grid_endX, anchor_price, anc_right_endX, anchor_price, color=anchor_color, width=anc_width, style=f_get_style(anc_style)))

        labels_arr.push(label.new(grid_midX, anchor_price, "1", textcolor=anchor_color, style=label.style_none, size=lbl_sz_str))

        if anc_show_label
            labels_arr.push(label.new(anc_lbl_x, anchor_price, f_build_right_label(0.0, anchor_price), textcolor=anchor_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        // -------------------------------------------------------------
        // CORE TIERS (1 & 2)
        // -------------------------------------------------------------
        // UP 1
        lines_arr.push(line.new(grid_startX, up_1, grid_endX, up_1, color=t1_color, width=t1_width, style=f_get_style(t1_style)))
        if tier_show_left
            lines_arr.push(line.new(origin_bar, up_1, grid_startX, up_1, color=t1_color, width=t1_width, style=f_get_style(t1_style)))
        else if show_tier_labels
            labels_arr.push(label.new(lbl_510_X, up_1, f_point_text(tier_1_dist), textcolor=t1_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
        if tier_show_right
            lines_arr.push(line.new(grid_endX, up_1, tier_right_endX, up_1, color=t1_color, width=t1_width, style=f_get_style(t1_style)))
        if show_right_labels
            labels_arr.push(label.new(tier_lbl_x, up_1, f_build_right_label(tier_1_dist, up_1), textcolor=t1_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        // UP 2
        lines_arr.push(line.new(grid_startX, up_2, grid_endX, up_2, color=t2_color, width=t2_width, style=f_get_style(t2_style)))
        if tier_show_left
            lines_arr.push(line.new(origin_bar, up_2, grid_startX, up_2, color=t2_color, width=t2_width, style=f_get_style(t2_style)))
        else if show_tier_labels
            labels_arr.push(label.new(lbl_510_X, up_2, f_point_text(tier_2_dist), textcolor=t2_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
        if tier_show_right
            lines_arr.push(line.new(grid_endX, up_2, tier_right_endX, up_2, color=t2_color, width=t2_width, style=f_get_style(t2_style)))
        if show_right_labels
            labels_arr.push(label.new(tier_lbl_x, up_2, f_build_right_label(tier_2_dist, up_2), textcolor=t2_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        // DOWN 1
        lines_arr.push(line.new(grid_startX, dn_1, grid_endX, dn_1, color=t1_color, width=t1_width, style=f_get_style(t1_style)))
        if tier_show_left
            lines_arr.push(line.new(origin_bar, dn_1, grid_startX, dn_1, color=t1_color, width=t1_width, style=f_get_style(t1_style)))
        else if show_tier_labels
            labels_arr.push(label.new(lbl_510_X, dn_1, f_point_text(-tier_1_dist), textcolor=t1_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
        if tier_show_right
            lines_arr.push(line.new(grid_endX, dn_1, tier_right_endX, dn_1, color=t1_color, width=t1_width, style=f_get_style(t1_style)))
        if show_right_labels
            labels_arr.push(label.new(tier_lbl_x, dn_1, f_build_right_label(-tier_1_dist, dn_1), textcolor=t1_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        // DOWN 2
        lines_arr.push(line.new(grid_startX, dn_2, grid_endX, dn_2, color=t2_color, width=t2_width, style=f_get_style(t2_style)))
        if tier_show_left
            lines_arr.push(line.new(origin_bar, dn_2, grid_startX, dn_2, color=t2_color, width=t2_width, style=f_get_style(t2_style)))
        else if show_tier_labels
            labels_arr.push(label.new(lbl_510_X, dn_2, f_point_text(-tier_2_dist), textcolor=t2_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
        if tier_show_right
            lines_arr.push(line.new(grid_endX, dn_2, tier_right_endX, dn_2, color=t2_color, width=t2_width, style=f_get_style(t2_style)))
        if show_right_labels
            labels_arr.push(label.new(tier_lbl_x, dn_2, f_build_right_label(-tier_2_dist, dn_2), textcolor=t2_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        // -------------------------------------------------------------
        // EXTENDED TIERS (3 & 4)
        // -------------------------------------------------------------
        if show_tier_3
            lines_arr.push(line.new(grid_startX, up_3, grid_endX, up_3, color=t3_color, width=t3_width, style=f_get_style(t3_style)))
            lines_arr.push(line.new(grid_startX, dn_3, grid_endX, dn_3, color=t3_color, width=t3_width, style=f_get_style(t3_style)))
            if tier_show_left
                lines_arr.push(line.new(origin_bar, up_3, grid_startX, up_3, color=t3_color, width=t3_width, style=f_get_style(t3_style)))
                lines_arr.push(line.new(origin_bar, dn_3, grid_startX, dn_3, color=t3_color, width=t3_width, style=f_get_style(t3_style)))
            else if show_tier_labels
                labels_arr.push(label.new(lbl_510_X, up_3, f_point_text(tier_3_dist), textcolor=t3_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                labels_arr.push(label.new(lbl_510_X, dn_3, f_point_text(-tier_3_dist), textcolor=t3_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
            if tier_show_right
                lines_arr.push(line.new(grid_endX, up_3, tier_right_endX, up_3, color=t3_color, width=t3_width, style=f_get_style(t3_style)))
                lines_arr.push(line.new(grid_endX, dn_3, tier_right_endX, dn_3, color=t3_color, width=t3_width, style=f_get_style(t3_style)))
            if show_right_labels
                labels_arr.push(label.new(tier_lbl_x, up_3, f_build_right_label(tier_3_dist, up_3), textcolor=t3_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
                labels_arr.push(label.new(tier_lbl_x, dn_3, f_build_right_label(-tier_3_dist, dn_3), textcolor=t3_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        if show_tier_4
            lines_arr.push(line.new(grid_startX, up_4, grid_endX, up_4, color=t4_color, width=t4_width, style=f_get_style(t4_style)))
            lines_arr.push(line.new(grid_startX, dn_4, grid_endX, dn_4, color=t4_color, width=t4_width, style=f_get_style(t4_style)))
            if tier_show_left
                lines_arr.push(line.new(origin_bar, up_4, grid_startX, up_4, color=t4_color, width=t4_width, style=f_get_style(t4_style)))
                lines_arr.push(line.new(origin_bar, dn_4, grid_startX, dn_4, color=t4_color, width=t4_width, style=f_get_style(t4_style)))
            else if show_tier_labels
                labels_arr.push(label.new(lbl_510_X, up_4, f_point_text(tier_4_dist), textcolor=t4_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                labels_arr.push(label.new(lbl_510_X, dn_4, f_point_text(-tier_4_dist), textcolor=t4_color, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
            if tier_show_right
                lines_arr.push(line.new(grid_endX, up_4, tier_right_endX, up_4, color=t4_color, width=t4_width, style=f_get_style(t4_style)))
                lines_arr.push(line.new(grid_endX, dn_4, tier_right_endX, dn_4, color=t4_color, width=t4_width, style=f_get_style(t4_style)))
            if show_right_labels
                labels_arr.push(label.new(tier_lbl_x, up_4, f_build_right_label(tier_4_dist, up_4), textcolor=t4_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
                labels_arr.push(label.new(tier_lbl_x, dn_4, f_build_right_label(-tier_4_dist, dn_4), textcolor=t4_color, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        // -------------------------------------------------------------
        // BOX FILLS & MACRO EXTENSIONS
        // -------------------------------------------------------------
        if show_zone_fills
            boxes_arr.push(box.new(grid_startX, up_1, grid_endX, anchor_price, bgcolor=zone_color_1, border_color=na))
            boxes_arr.push(box.new(grid_startX, up_2, grid_endX, up_1, bgcolor=zone_color_2, border_color=na))
            boxes_arr.push(box.new(grid_startX, anchor_price, grid_endX, dn_1, bgcolor=zone_color_1, border_color=na))
            boxes_arr.push(box.new(grid_startX, dn_1, grid_endX, dn_2, bgcolor=zone_color_2, border_color=na))

            float current_top_box = up_2
            float current_bot_box = dn_2

            if show_tier_3
                boxes_arr.push(box.new(grid_startX, up_3, grid_endX, up_2, bgcolor=zone_color_3, border_color=na))
                boxes_arr.push(box.new(grid_startX, dn_2, grid_endX, dn_3, bgcolor=zone_color_3, border_color=na))
                current_top_box := up_3
                current_bot_box := dn_3
            if show_tier_4
                boxes_arr.push(box.new(grid_startX, up_4, grid_endX, current_top_box, bgcolor=zone_color_4, border_color=na))
                boxes_arr.push(box.new(grid_startX, current_bot_box, grid_endX, dn_4, bgcolor=zone_color_4, border_color=na))
                current_top_box := up_4
                current_bot_box := dn_4

            if max_up > current_top_box
                boxes_arr.push(box.new(grid_startX, max_up, grid_endX, current_top_box, bgcolor=color.new(color.gray, 92), border_color=na))
            if max_dn < current_bot_box
                boxes_arr.push(box.new(grid_startX, current_bot_box, grid_endX, max_dn, bgcolor=color.new(color.gray, 92), border_color=na))

        labels_arr.push(label.new(grid_midX, math.avg(anchor_price, up_1), str.tostring(tier_1_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))
        labels_arr.push(label.new(grid_midX, math.avg(up_1, up_2), str.tostring(tier_2_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))
        labels_arr.push(label.new(grid_midX, math.avg(anchor_price, dn_1), str.tostring(tier_1_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))
        labels_arr.push(label.new(grid_midX, math.avg(dn_1, dn_2), str.tostring(tier_2_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))
        if show_tier_3
            labels_arr.push(label.new(grid_midX, math.avg(up_2, up_3), str.tostring(tier_3_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))
            labels_arr.push(label.new(grid_midX, math.avg(dn_2, dn_3), str.tostring(tier_3_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))
        if show_tier_4
            labels_arr.push(label.new(grid_midX, math.avg(up_3, up_4), str.tostring(tier_4_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))
            labels_arr.push(label.new(grid_midX, math.avg(dn_3, dn_4), str.tostring(tier_4_dist), textcolor=color.gray, style=label.style_none, size=lbl_sz_str))

        // -------------------------------------------------------------
        // DYNAMIC MACRO TARGETS (HOD, LOD, PDH, PDL)
        // -------------------------------------------------------------
        var map<float, string> macros = map.new<float, string>()
        macros.clear()
        if show_hod and not na(dy_h)
            macros.put(dy_h, "HOD")
        if show_lod and not na(dy_l)
            macros.put(dy_l, "LOD")
        if show_pdh and not na(p_dy_h)
            macros.put(p_dy_h, "PDH")
        if show_pdl and not na(p_dy_l)
            macros.put(p_dy_l, "PDL")

        if macros.keys().size() > 0
            for mac_price in macros.keys()
                float pts_diff = (mac_price - anchor_price) / pt
                string raw_mac_lbl = f_build_right_label(pts_diff, mac_price)
                string mac_lbl = (raw_mac_lbl == "" ? "" : raw_mac_lbl + " ") + "[" + macros.get(mac_price) + "]"

                lines_arr.push(line.new(grid_startX, mac_price, grid_endX, mac_price, color=macro_col, width=1, style=f_get_style(macro_sty)))
                if macro_show_left
                    lines_arr.push(line.new(origin_bar, mac_price, grid_startX, mac_price, color=macro_col, width=1, style=f_get_style(macro_sty)))
                if macro_show_right
                    lines_arr.push(line.new(grid_endX, mac_price, macro_right_endX, mac_price, color=macro_col, width=1, style=f_get_style(macro_sty)))
                if show_right_labels
                    labels_arr.push(label.new(macro_lbl_x, mac_price, mac_lbl, textcolor=macro_col, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))

        // -------------------------------------------------------------
        // INTERNAL GRID LOOP
        // -------------------------------------------------------------
        float tolerance = pt * 0.1
        int   maj_pts    = math.round(major_step)
        int   ext_pts    = math.round(ext_step)

        array<float> active_tiers = array.new<float>()
        active_tiers.push(up_1)
        active_tiers.push(up_2)
        active_tiers.push(dn_1)
        active_tiers.push(dn_2)
        if show_tier_3
            active_tiers.push(up_3)
            active_tiers.push(dn_3)
        if show_tier_4
            active_tiers.push(up_4)
            active_tiers.push(dn_4)

        // ─── STEP A (tight spacing) ───
        float grid_minor_up = anchor_price + (minor_step * pt)
        while grid_minor_up < max_up
            int dist_pts = math.round((grid_minor_up - anchor_price) / pt)
            if (dist_pts % maj_pts) != 0 and (dist_pts % ext_pts) != 0 and not f_overlaps_tier(grid_minor_up, active_tiers, tolerance)
                if show_grid_lines
                    lines_arr.push(line.new(grid_startX, grid_minor_up, grid_endX, grid_minor_up, color=col_minor_pts, width=1, style=internal_style))
                if show_grid_labels
                    labels_arr.push(label.new(lbl_510_X, grid_minor_up, f_point_text(dist_pts), textcolor=col_minor_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                if show_right_labels
                    labels_arr.push(label.new(grid_lbl_x, grid_minor_up, f_build_right_label(dist_pts, grid_minor_up), textcolor=col_minor_pts, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            grid_minor_up += (minor_step * pt)

        float grid_minor_dn = anchor_price - (minor_step * pt)
        while grid_minor_dn > max_dn
            int dist_pts = math.round((grid_minor_dn - anchor_price) / pt)
            int abs_pts  = math.abs(dist_pts)
            if (abs_pts % maj_pts) != 0 and (abs_pts % ext_pts) != 0 and not f_overlaps_tier(grid_minor_dn, active_tiers, tolerance)
                if show_grid_lines
                    lines_arr.push(line.new(grid_startX, grid_minor_dn, grid_endX, grid_minor_dn, color=col_minor_pts, width=1, style=internal_style))
                if show_grid_labels
                    labels_arr.push(label.new(lbl_510_X, grid_minor_dn, f_point_text(dist_pts), textcolor=col_minor_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                if show_right_labels
                    labels_arr.push(label.new(grid_lbl_x, grid_minor_dn, f_build_right_label(dist_pts, grid_minor_dn), textcolor=col_minor_pts, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            grid_minor_dn -= (minor_step * pt)

        // ─── STEP B (medium spacing) ───
        float grid_major_up = anchor_price + (major_step * pt)
        while grid_major_up < max_up
            int dist_pts = math.round((grid_major_up - anchor_price) / pt)
            if (dist_pts % ext_pts) != 0 and not f_overlaps_tier(grid_major_up, active_tiers, tolerance)
                if show_grid_lines
                    lines_arr.push(line.new(grid_startX, grid_major_up, grid_endX, grid_major_up, color=col_major_pts, width=1, style=internal_style))
                if show_grid_labels
                    labels_arr.push(label.new(lbl_510_X, grid_major_up, f_point_text(dist_pts), textcolor=col_major_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                if show_right_labels
                    labels_arr.push(label.new(grid_lbl_x, grid_major_up, f_build_right_label(dist_pts, grid_major_up), textcolor=col_major_pts, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            grid_major_up += (major_step * pt)

        float grid_major_dn = anchor_price - (major_step * pt)
        while grid_major_dn > max_dn
            int dist_pts = math.round((grid_major_dn - anchor_price) / pt)
            int abs_pts  = math.abs(dist_pts)
            if (abs_pts % ext_pts) != 0 and not f_overlaps_tier(grid_major_dn, active_tiers, tolerance)
                if show_grid_lines
                    lines_arr.push(line.new(grid_startX, grid_major_dn, grid_endX, grid_major_dn, color=col_major_pts, width=1, style=internal_style))
                if show_grid_labels
                    labels_arr.push(label.new(lbl_510_X, grid_major_dn, f_point_text(dist_pts), textcolor=col_major_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                if show_right_labels
                    labels_arr.push(label.new(grid_lbl_x, grid_major_dn, f_build_right_label(dist_pts, grid_major_dn), textcolor=col_major_pts, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            grid_major_dn -= (major_step * pt)

        // ─── STEP C (wide spacing) ───
        float grid_ext_up = anchor_price + (ext_step * pt)
        while grid_ext_up < max_up
            int dist_pts = math.round((grid_ext_up - anchor_price) / pt)
            if not f_overlaps_tier(grid_ext_up, active_tiers, tolerance)
                if show_grid_lines
                    lines_arr.push(line.new(grid_startX, grid_ext_up, grid_endX, grid_ext_up, color=col_ext_pts, width=1, style=internal_style))
                if show_grid_labels
                    labels_arr.push(label.new(lbl_510_X, grid_ext_up, f_point_text(dist_pts), textcolor=col_ext_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                if show_right_labels
                    labels_arr.push(label.new(grid_lbl_x, grid_ext_up, f_build_right_label(dist_pts, grid_ext_up), textcolor=col_ext_pts, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            grid_ext_up += (ext_step * pt)

        float grid_ext_dn = anchor_price - (ext_step * pt)
        while grid_ext_dn > max_dn
            int dist_pts = math.round((grid_ext_dn - anchor_price) / pt)
            if not f_overlaps_tier(grid_ext_dn, active_tiers, tolerance)
                if show_grid_lines
                    lines_arr.push(line.new(grid_startX, grid_ext_dn, grid_endX, grid_ext_dn, color=col_ext_pts, width=1, style=internal_style))
                if show_grid_labels
                    labels_arr.push(label.new(lbl_510_X, grid_ext_dn, f_point_text(dist_pts), textcolor=col_ext_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))
                if show_right_labels
                    labels_arr.push(label.new(grid_lbl_x, grid_ext_dn, f_build_right_label(dist_pts, grid_ext_dn), textcolor=col_ext_pts, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            grid_ext_dn -= (ext_step * pt)
````
