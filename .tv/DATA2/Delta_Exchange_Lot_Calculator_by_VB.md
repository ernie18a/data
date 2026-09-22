<!-- tradingview-pine-id: PUB;d40e6955a3e64f41b25548a852d198f9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Delta Exchange Lot Calculator by VB

Source: https://www.tradingview.com/script/ZoJOf6Pv-Delta-Exchange-Lot-Calculator/

## Description

No more worries about lot size calculations.

================================================================================
Delta Exchange Calculator — Script Description & Publication Guide
================================================================================

Delta Exchange Calculator is an all-in-one position sizing and risk management
script built specifically for crypto derivatives traders on Delta Exchange. It
calculates your exact contract/lot size, required margin buffer, and real-time
liquidation price directly on your chart while fully accounting for maker/taker
fees and Indian GST (18%).

Currently, the indicator supports lot calculations for over 219 pairs, with new
trading pair specifications continuously added in future updates.

--------------------------------------------------------------------------------
1. WHY USE THIS INDICATOR?
--------------------------------------------------------------------------------
Trading crypto futures with static lot sizes or rough mental math often leads to
unexpected losses due to order fees, contract multipliers, and sudden liquidations.
This indicator eliminates manual calculations, ensuring your target dollar risk
remains precise and consistent on every single setup.

--------------------------------------------------------------------------------
2. HOW TO USE (INTERACTIVE LEVEL SELECTION)
--------------------------------------------------------------------------------
Step 1: Add to Chart
• Apply the indicator to your desired Delta Exchange trading pair.

Step 2: Set Trade Levels Directly on the Chart
• When prompted upon loading (or by reopening settings), click 3 points on your chart:
1. 1st Click: Target Entry Price (Blue line)
2. 2nd Click: Invalidation / Stop Loss Price (Red line)
3. 3rd Click: Target Take Profit Price (Green line)
• The script automatically identifies whether the trade is LONG or SHORT based on
the relationship between your Entry and Stop Loss levels.

Step 3: Configure Your Account & Risk
• Account Size ($): Enter your current equity (e.g., $500).
• Risk %: Enter how much of your account you want to risk on the trade (e.g., 1% = $5.00 max loss).
• Margin Mode & Leverage: Select Isolated or Cross Margin and choose your target leverage
(automatically capped to the pair's maximum allowed limit).
• Order Types & GST: Choose Maker/Taker for entry and exit, and toggle the 18% GST fee buffer.

Step 4: Place Your Order
• Look at the on-screen dashboard and enter the calculated Normal Lot Size
(or Scalper Lot Size) directly into the Delta Exchange order form.

--------------------------------------------------------------------------------
3. CORE LOGIC & FEATURES
--------------------------------------------------------------------------------
• 219+ Supported Pairs & Future Updates:
Native support for over 219 Delta Exchange pairs. Newly listed pairs and contract
specification updates are continuously integrated via the shared library.

• Fee & GST-Inclusive Risk Sizing:
Standard calculators only measure price difference. This script factors in:
Total Loss = Price Distance Loss + Entry Fee + Exit Fee + 18% GST
This ensures your actual realized loss matches your exact cash risk when Stop Loss is hit.

• Auto Contract Spec Detection:
Fetches contract multipliers, maintenance margin rates, and pair leverage caps
directly from the contract library.

• Dual Lot Sizing Options:
- Normal Lot Size: Formulated for standard swing positions and default fee tiers.
- Scalper Lot Size: Calibrated for active intraday scalpers using Delta Exchange discounted fee structures.

• Smart Liquidation Warning:
Calculates real-time liquidation for Isolated and Cross margin modes. If high leverage causes
your liquidation price to hit BEFORE your Stop Loss, the dashboard flags the metric in bright
red with an alert tooltip.

• Dynamic Leverage Ceiling:
Automatically caps user leverage to the pair's maximum allowed exchange limit.

--------------------------------------------------------------------------------
4. DASHBOARD METRICS EXPLAINED
--------------------------------------------------------------------------------
• Margin & Leverage : Active margin mode and effective leverage vs. exchange maximum cap.
• Contract Scale : Underlying coin multiplier per 1 exchange contract lot.
• Funds Required : Total initial margin needed plus a buffer for order fees.
• Cash at Risk (SL Hit) : Exact dollar amount lost if Stop Loss triggers (fees included).
• Liquidation Price ⚠️ : Estimated liquidation price (highlighted in red if SL is unprotected).
• Scalper / Normal Lots : Final calculated lot count to enter on the exchange order form.

================================================================================

---

## Source Code

````pine
//@version=6
//@author : V-i-c-k-y
indicator('Delta Exchange Lot Calculator by VB', overlay = true,shorttitle ="DC" )

// Import the dedicated contract library (replace 'V-i-c-k-y' with your TradingView account name if needed)
import V-i-c-k-y/Public_DeltaExchange_ContractSpecs_by_VB/4 as delta

// ==========================================
// 1. INPUT SETTINGS
// ==========================================
var G_ACC = 'Account & Risk Settings'
margin_mode     = input.string('Isolated Margin', 'Margin Mode', options = ['Isolated Margin', 'Cross Margin'], group = G_ACC)
account_size    = input.float(10000.0, 'Account Size ($)', minval = 1.0, group = G_ACC)
risk_perc       = input.float(1.0, 'Risk % (Target Cash to lose at SL)', minval = 0.01, step = 0.1, group = G_ACC)
leverage_select = input.string('100x', 'Target Leverage', options = ['10x', '20x', '25x', '50x', '100x', '150x', '200x'], tooltip = 'Select desired leverage. If the active pair has a lower exchange ceiling (e.g. 50x or 20x), the calculator automatically caps the effective leverage to that pair\'s maximum allowed limit.', group = G_ACC)

var G_UI = 'Dashboard Table Appearance & Position'
table_pos_in  = input.string('Top Right', 'Table Position', options = ['Top Right', 'Middle Right', 'Bottom Right', 'Top Left', 'Middle Left', 'Bottom Left', 'Top Center', 'Bottom Center'], group = G_UI)
table_size_in = input.string('Small', 'Table Text Size', options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = G_UI)

var G_EXC = 'Order Types & Fee Settings'
entry_order_type = input.string('Maker', 'Entry Order Type', options = ['Maker', 'Taker'], group = G_EXC)
exit_order_type  = input.string('Taker', 'SL Exit Order Type', options = ['Maker', 'Taker'], group = G_EXC)
apply_gst        = input.bool(true, 'Include 18% GST on Fees?', group = G_EXC)

var G_POINTS = 'Trade Levels (Interactive Chart Points)'
price_entry_in = input.price(0.0, '1. Entry Price (Click on Chart)', confirm = true, group = G_POINTS)
price_sl_in    = input.price(0.0, '2. Stop Loss Price (Click on Chart)', confirm = true, group = G_POINTS)
price_tp_in    = input.price(0.0, '3. Take Profit Price (Click on Chart)', confirm = true, group = G_POINTS)

// Snap clicked coordinates strictly to chart tick precision
float price_entry = math.round_to_mintick(price_entry_in == 0.0 ? close : price_entry_in)
float price_sl    = math.round_to_mintick(price_sl_in == 0.0 ? close * 0.99 : price_sl_in)
float price_tp    = math.round_to_mintick(price_tp_in == 0.0 ? close * 1.02 : price_tp_in)

// Parse integer value from leverage dropdown string
int parsed_user_lev = leverage_select == '10x' ? 10 : leverage_select == '20x' ? 20 : leverage_select == '25x' ? 25 : leverage_select == '50x' ? 50 : leverage_select == '100x' ? 100 : leverage_select == '150x' ? 150 : 200

// Parse UI Position and Size
string table_position = table_pos_in == 'Top Left' ? position.top_left : table_pos_in == 'Middle Left' ? position.middle_left : table_pos_in == 'Bottom Left' ? position.bottom_left : table_pos_in == 'Top Center' ? position.top_center : table_pos_in == 'Bottom Center' ? position.bottom_center : table_pos_in == 'Middle Right' ? position.middle_right : table_pos_in == 'Bottom Right' ? position.bottom_right : position.top_right
string table_text_size = table_size_in == 'Tiny' ? size.tiny : table_size_in == 'Small' ? size.small : table_size_in == 'Normal' ? size.normal : table_size_in == 'Large' ? size.large : table_size_in == 'Huge' ? size.huge : size.auto

// ==========================================
// 2. RETRIEVE FROM LIBRARY (AUTO DETECT)
// ==========================================
delta.ContractSpec spec = delta.get_spec('Auto Detect (From Chart)', syminfo.ticker, 1.0, 0.005, 0.02, 0.05, 0.01)

bool is_supported         = spec.is_found
float contract_multiplier = spec.multiplier
float mm_rate             = spec.mm_rate
float norm_maker_input    = spec.norm_maker
float norm_taker_input    = spec.norm_taker
float scalp_maker_input   = spec.scalp_maker
float scalp_taker_input   = spec.scalp_taker
int max_allowed_lev       = spec.max_lev
string asset_name         = spec.asset_name

// Apply dynamic leverage ceiling
int leverage = math.min(parsed_user_lev, max_allowed_lev)

// ==========================================
// 3. EXACT RISK & LOT MATH
// ==========================================
is_long  = price_entry > price_sl
is_short = price_entry < price_sl

// Target cash risk ($)
cash_at_risk = account_size * (risk_perc / 100.0)

// Price distances
sl_distance = math.abs(price_entry - price_sl)
tp_distance = math.abs(price_tp - price_entry)

// GST Multiplier
float gst_mult = apply_gst ? 1.18 : 1.0

// --- 1. Standard / Normal Fee Rates ---
float norm_maker_rate = norm_maker_input / 100.0
float norm_taker_rate = norm_taker_input / 100.0

float norm_entry_rate = (entry_order_type == 'Maker' ? norm_maker_rate : norm_taker_rate) * gst_mult
float norm_exit_rate  = (exit_order_type == 'Maker' ? norm_maker_rate : norm_taker_rate) * gst_mult

float norm_loss_per_coin = sl_distance + price_entry * norm_entry_rate + price_sl * norm_exit_rate
float norm_target_coins  = sl_distance > 0 and norm_loss_per_coin > 0 ? cash_at_risk / norm_loss_per_coin : 0.0
int norm_lots            = contract_multiplier > 0 ? math.round(norm_target_coins / contract_multiplier) : 0
float norm_actual_coins  = norm_lots * contract_multiplier
float norm_exact_sl_loss = norm_actual_coins * sl_distance + norm_actual_coins * price_entry * norm_entry_rate + norm_actual_coins * price_sl * norm_exit_rate

// --- 2. Scalper Offer Fee Rates ---
float scalp_maker_rate = scalp_maker_input / 100.0
float scalp_taker_rate = scalp_taker_input / 100.0

float scalp_entry_rate = (entry_order_type == 'Maker' ? scalp_maker_rate : scalp_taker_rate) * gst_mult
float scalp_exit_rate  = (exit_order_type == 'Maker' ? scalp_maker_rate : scalp_taker_rate) * gst_mult

float scalp_loss_per_coin = sl_distance + price_entry * scalp_entry_rate + price_sl * scalp_exit_rate
float scalp_target_coins  = sl_distance > 0 and scalp_loss_per_coin > 0 ? cash_at_risk / scalp_loss_per_coin : 0.0
int scalp_lots            = contract_multiplier > 0 ? math.round(scalp_target_coins / contract_multiplier) : 0
float scalp_actual_coins  = scalp_lots * contract_multiplier

// Notional Order Value & Delta Exact Funds Required (Margin + Fee Buffer)
float notional_value   = norm_actual_coins * price_entry
float order_fee_buffer = notional_value * norm_taker_rate * 2.0
float funds_required   = leverage > 0 ? notional_value / leverage + order_fee_buffer : 0.0

// ==========================================
// 4. LIQUIDATION PRICE CALCULATION
// ==========================================
var float liq_price = na

if margin_mode == 'Isolated Margin'
    if is_long
        liq_price := math.round_to_mintick(price_entry * (1.0 - 1.0 / leverage + mm_rate))
    else if is_short
        liq_price := math.round_to_mintick(price_entry * (1.0 + 1.0 / leverage - mm_rate))
else
    if norm_actual_coins > 0
        if is_long
            float raw_liq = (price_entry * norm_actual_coins - account_size) / (norm_actual_coins * (1.0 - mm_rate))
            liq_price := math.round_to_mintick(math.max(0.0, raw_liq))
        else if is_short
            float raw_liq = (price_entry * norm_actual_coins + account_size) / (norm_actual_coins * (1.0 + mm_rate))
            liq_price := math.round_to_mintick(raw_liq)

// ==========================================
// 5. CHART VISUALIZATION (LINES & LABELS)
// ==========================================
var line line_entry = na
var line line_sl    = na
var line line_tp    = na
var line line_liq   = na

var label lbl_entry = na
var label lbl_sl    = na
var label lbl_tp    = na
var label lbl_liq   = na
var label lbl_err   = na

if barstate.islast
    line.delete(line_entry)
    line.delete(line_sl)
    line.delete(line_tp)
    line.delete(line_liq)

    label.delete(lbl_entry)
    label.delete(lbl_sl)
    label.delete(lbl_tp)
    label.delete(lbl_liq)
    label.delete(lbl_err)

    int x1 = bar_index - 25
    int x2 = bar_index + 10

    if is_supported
        // Horizontal Lines
        line_entry := line.new(x1, price_entry, x2, price_entry, color = color.blue, width = 2, style = line.style_solid)
        line_sl    := line.new(x1, price_sl, x2, price_sl, color = color.red, width = 2, style = line.style_solid)
        line_tp    := line.new(x1, price_tp, x2, price_tp, color = color.green, width = 2, style = line.style_solid)

        if not na(liq_price) and liq_price > 0
            line_liq := line.new(x1, liq_price, x2, liq_price, color = color.orange, width = 1, style = line.style_dashed)
            lbl_liq  := label.new(x2, liq_price, 'Liq: ' + str.tostring(liq_price, format.mintick), color = color.orange, textcolor = color.black, style = label.style_label_left, size = size.small)

        // Right-aligned Price Tags
        lbl_entry := label.new(x2, price_entry, 'Entry: ' + str.tostring(price_entry, format.mintick), color = color.blue, textcolor = color.white, style = label.style_label_left, size = size.small)
        lbl_sl    := label.new(x2, price_sl, 'SL: ' + str.tostring(price_sl, format.mintick), color = color.red, textcolor = color.white, style = label.style_label_left, size = size.small)
        lbl_tp    := label.new(x2, price_tp, 'TP: ' + str.tostring(price_tp, format.mintick), color = color.green, textcolor = color.white, style = label.style_label_left, size = size.small)
    else
        // Direct Chart Error Label
        lbl_err := label.new(bar_index, close, '⚠️ Pair Not Supported, Only Works On Delta Exchange Broker pairs', color = color.red, textcolor = color.white, style = label.style_label_center, size = size.normal)

// ==========================================
// 6. DASHBOARD TABLE
// ==========================================
var table dash = table.new(position = table_position, columns = 2, rows = 10, bgcolor = color.new(#1e222d, 10), border_width = 1, border_color = color.gray)

if barstate.islast
    table.clear(dash, 0, 0, 1, 9)

    if not is_supported
        // Error Box
        table.cell(dash, 0, 0, '⚠️ Delta Exchange Error', text_color = color.white, text_size = table_text_size, text_halign = text.align_left, bgcolor = color.maroon)
        table.cell(dash, 1, 0, 'Unsupported Pair', text_color = color.yellow, text_size = table_text_size, text_halign = text.align_right, bgcolor = color.maroon)

        table.cell(dash, 0, 1, 'Ticker', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 1, syminfo.ticker, text_color = color.white, text_size = table_text_size, text_halign = text.align_right)

        table.cell(dash, 0, 2, 'Status', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 2, 'Not Found in Library', text_color = color.red, text_size = table_text_size, text_halign = text.align_right)

        table.cell(dash, 0, 3, 'Action', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 3, 'Add spec to Library v4', text_color = color.yellow, text_size = table_text_size, text_halign = text.align_right)
    else
        // Header
        table.cell(dash, 0, 0, 'Delta Exchange (' + asset_name + 'USD)', text_color = color.white, text_size = table_text_size, text_halign = text.align_left, bgcolor = #7c21f3b3)
        table.cell(dash, 1, 0, 'Metrics', text_color = color.white, text_size = table_text_size, text_halign = text.align_right, bgcolor = #7c21f3b3)

        // Row 1: Account Size
        table.cell(dash, 0, 1, 'Account Size', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 1, '$' + str.tostring(account_size, '#,###.##'), text_color = color.white, text_size = table_text_size, text_halign = text.align_right)

        // Row 2: Risk %
        table.cell(dash, 0, 2, 'Risk %', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 2, str.tostring(risk_perc, '#.##') + '%', text_color = color.yellow, text_size = table_text_size, text_halign = text.align_right)

        // Row 3: Margin & Leverage
        string mode_short = margin_mode == 'Cross Margin' ? 'Cross' : 'Iso'
        table.cell(dash, 0, 3, 'Margin & Leverage', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 3, mode_short + ' | ' + str.tostring(leverage) + 'x / ' + str.tostring(max_allowed_lev) + 'x', text_color = color.aqua, text_size = table_text_size, text_halign = text.align_right)

        // Row 4: Contract Specification
        table.cell(dash, 0, 4, 'Contract Scale', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 4, '1 Lot = ' + str.tostring(contract_multiplier) + ' ' + asset_name, text_color = color.white, text_size = table_text_size, text_halign = text.align_right)

        // Row 5: Funds Required
        color margin_color = funds_required > account_size ? color.red : color.white
        table.cell(dash, 0, 5, 'Funds Required', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 5, '$' + str.tostring(funds_required, '#,###.##'), text_color = margin_color, text_size = table_text_size, text_halign = text.align_right)

        // Row 6: Cash at Risk
        table.cell(dash, 0, 6, 'Cash at Risk (SL Hit)', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left)
        table.cell(dash, 1, 6, '$' + str.tostring(norm_exact_sl_loss, '#,###.##'), text_color = color.red, text_size = table_text_size, text_halign = text.align_right)

        // Row 7: Liquidation Price (With Warning Tooltip)
        bool is_liq_hit_first = (is_long and liq_price >= price_sl) or (is_short and liq_price <= price_sl)
        color liq_color = is_liq_hit_first ? color.red : color.orange
        string liq_text = liq_price <= 0 or na(liq_price) ? 'No Liq (< $0)' : '$' + str.tostring(liq_price, format.mintick)
        
        string liq_tooltip = is_liq_hit_first 
          ? '⚠️ CRITICAL: Liquidation triggers BEFORE your Stop Loss!\n• Your capital will be liquidated before SL executes.\n• Reduce leverage immediately to push liquidation behind your SL.' 
          : 'Liquidation is safely behind your Stop Loss.\n• Tip: Always keep leverage low enough so your SL protects your margin before liquidation triggers.'

        table.cell(dash, 0, 7, 'Liquidation Price⚠️', text_color = color.silver, text_size = table_text_size, text_halign = text.align_left, tooltip = liq_tooltip)
        table.cell(dash, 1, 7, liq_text, text_color = liq_color, text_size = table_text_size, text_halign = text.align_right, tooltip = liq_tooltip)

        // Row 8: Scalper Active Lot Size (With Explanation Tooltip)
        string scalp_tooltip = 'Scalper Lot Size:\n• Sized using Delta Exchange discounted/scalp tier fees.\n• Best for intraday scalps with tighter spreads and lower fee structures.'
        table.cell(dash, 0, 8, 'Scalper Active Lot Size', text_color = color.white, text_size = table_text_size, text_halign = text.align_left, bgcolor = color.new(color.green, 60), tooltip = scalp_tooltip)
        table.cell(dash, 1, 8, str.tostring(scalp_lots, '#,###') + ' Lots', text_color = color.lime, text_size = table_text_size, text_halign = text.align_right, bgcolor = color.new(color.green, 60), tooltip = scalp_tooltip)

        // Row 9: Normal Lot Size (With Explanation Tooltip)
        string norm_tooltip = 'Normal Lot Size:\n• Sized using standard default maker/taker fee rates + 18% GST.\n• Best for swing trades and standard positions to ensure fee buffer accuracy.'
        table.cell(dash, 0, 9, 'Normal Lot Size', text_color = color.white, text_size = table_text_size, text_halign = text.align_left, bgcolor = color.new(color.navy, 30), tooltip = norm_tooltip)
        table.cell(dash, 1, 9, str.tostring(norm_lots, '#,###') + ' Lots', text_color = color.white, text_size = table_text_size, text_halign = text.align_right, bgcolor = color.new(color.navy, 30), tooltip = norm_tooltip)
````
