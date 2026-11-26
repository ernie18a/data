# Global Position Sizing (R Based)

- url: https://www.tradingview.com/script/2t3ygSXz-Global-Position-Sizing-R-Based/
- type: indicator
- pine_id: PUB;72ec34e31f3a40d8a230e3ce89ddd3be
- version: 19.0

## Description

[b]Description:[/b]

Managing risk across different global markets, currencies, and timeframes can be a mathematical headache. The Global Position Sizing (R Based) indicator is designed to streamline this process, allowing you to focus on the trade setup rather than the calculator.

Built for traders who use fixed fractional risk (R-multiples), this open-source tool automatically calculates exactly how many shares you should buy based on your predefined risk, current exchange rates, and the specific stop-loss distance of your setup.

Whether you are trading US tech stocks, Indian equities, or Japanese indices, this indicator will automatically detect the active ticker's currency, pull live conversion rates, and seamlessly adjust your risk profile.

[image]https://www.tradingview.com/x/D57NSQh8/[/image]
[image]https://www.tradingview.com/x/fc0NZ8RH/[/image]
[image]https://www.tradingview.com/x/a0h0E6y7/[/image]
[image]https://www.tradingview.com/x/6cqUtePS/[/image]

[b]Key Features:[/b]

• [b]Auto-Currency Detection & Conversion: [/b]No manual input is needed when switching between international assets. The script reads the chart's native currency automatically and uses native request.currency_rate logic to instantly convert your Base Risk (USD) into the Target Currency.
• [b]Global Currency Support:[/b] The UI features custom symbol formatting for major markets, natively displaying USD (), CNY (¥), JPY (¥), KRW (₩), TWD (NT), and INR (₹). For all other global markets (such as EUR, GBP, AUD, CAD, etc.), the script features a smart fallback that simply displays the standard 3-letter currency code.
• [b]Dynamic Timeframe Multipliers:[/b] Automatically scales your risk based on the chart timeframe. By default, it applies a 1.0x multiplier for Daily setups and scales up to a 2.5x multiplier for higher-conviction Weekly or Monthly setups. You can also easily override this with a custom multiplier in the settings.
• [b]Smart Entry & Stop Loss Detection:[/b] If left at 0.0, the script automatically detects the current price (close) as your Entry and the current candle's low (low) as your Stop Loss. You can override these with specific manual price points for pending setups.
• [b]Volatility Warning System (SL vs. ATR):[/b] The script calculates your Stop Loss distance as a percentage and compares it against the Average True Range (ATR %) of the asset. If your proposed SL % is wider than the ATR %, the row will highlight RED, warning you that your risk parameter is unusually wide for the asset's current volatility. ATR length is fully customizable (default 14 days).
• [b]Modular & Clean UI:[/b] A highly customizable display widget that doesn't clutter your chart. • Toggle individual rows on or off (e.g., hide the exchange rate or ATR if you only want to see the final share count). • Anchor the widget to any of the 9 standard chart positions. • Adjust the custom "Margin Offset (%)" to push the widget away from the edges of your screen for a perfectly clean layout.

[b]How to Use:[/b]

1. Open the indicator settings and set your Daily R (Base USD). This is your standard risk unit per trade.
2. When evaluating a setup, either let the script auto-detect the current price/low, or enter your specific Entry and Stop Loss prices.
3. The widget will instantly calculate your risk in the local currency, compare your stop distance to the ATR, and output the exact number of shares to buy.

Note: This script is open-source and intended for educational and workflow optimization purposes. Always double-check position sizes and exchange rates before executing live trades.

## Source Code

````pine
//@version=6
indicator("Global Position Sizing (R Based)", overlay=true, precision=2)

// =========================================================================
// 1. INPUTS (Ordered top-to-bottom for the TV Settings Menu)
// =========================================================================

// --- Group Definitions ---
string groupRisk       = "Risk Management"
string groupEntry      = "Trade Entry Settings"
string groupSL         = "Stop Loss Settings"
string groupVol        = "Volatility Stop Settings (ATR/ADR)"
string groupMA         = "Moving Average Stop Settings (MA / Smart)"
string groupUiSettings = "Widget Layout"
string groupToggles    = "Display Toggles"
string groupColors     = "Colors & Styling"

// --- Risk Management (Base Risk) ---
int daily_r_dropdown = input.int(200, "Daily R Selection", options=[50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000], group=groupRisk)
int custom_daily_r   = input.int(0, "Custom Daily R (0 = Use Selection)", minval=0, group=groupRisk, tooltip="Enter a specific amount to manually override the predefined list. Leave it at 0 to use the dropdown selection above.")
float manual_mult    = input.float(0.0, "Custom R Multiplier (0 = Auto)", minval=0.0, step=0.1, group=groupRisk, tooltip="Set to 0 to auto-detect timeframe (Daily = 1.0x, Weekly/Monthly = 2.5x). Enter any other value to override.")
float r_tolerance    = input.float(0.0, "R Risk Tolerance (%)", minval=0.0, step=1.0, group=groupRisk, tooltip="The percentage by which the calculated manual R is allowed to exceed the defined R before triggering a warning.")

// --- Trade Entry Settings ---
string auto_entry_mode  = input.string("Current Close", "Entry Price Mode", options=["Current Close", "Current Bar High", "High of Day (HOD)", "Recent Swing High"], group=groupEntry, tooltip="Select the reference price for position sizing. While 'Current Close' is used for immediate market orders, other options are used for planning conditional stop orders (e.g., Buy Stop breakouts) so that your position sizing remains accurate to your R-rating if the breakout triggers.\n\nModes:\n- Current Close: Standard execution at active market price.\n- Current Bar High: For bar breakout entries.\n- High of Day (HOD): For daily session breakout entries.\n- Recent Swing High: For key structural resistance breakout entries.")
int swing_high_lookback = input.int(10, "Swing High Lookback (Bars)", minval=1, group=groupEntry, tooltip="Number of bars to look back for the 'Recent Swing High' Entry Price mode.")
float manual_entry      = input.float(0.0, "Manual Entry Price (0 = Auto)", minval=0.0, step=0.1, group=groupEntry, tooltip="Enter a specific price to manually override the Auto algorithm. Leave it at 0 to let the script automatically calculate the entry.")

// --- Stop Loss Settings ---
string auto_sl_mode = input.string("LOD or MA (Smart)", "Stop Loss Mode", options=["Current Bar Low", "Low of Day (LOD)", "Previous Candle Low", "Recent Swing Low", "MA", "LOD or MA (Smart)", "ATR%", "ADR%"], group=groupSL, tooltip="Current Bar Low: Low of the active candle.\nLow of Day (LOD): Daily low (intraday) or current bar low (daily+).\nPrevious Candle Low: Low of the previous candle (on Daily/Weekly/Monthly) or low of the previous day (on Intraday).\nRecent Swing Low: Lowest low within the lookback window.\nMA: Selected moving average (SMA/EMA of specified length).\nLOD or MA (Smart): Uses MA if it lies within the Tolerance % of LOD; otherwise defaults to LOD.\nATR%: Average True Range percentage (multiplier * ATR below entry price).\nADR%: Average Daily Range percentage (multiplier * ADR below entry price).")
int swing_lookback  = input.int(10, "Swing Low Lookback (Bars)", minval=1, group=groupSL, tooltip="Number of bars to look back for the 'Recent Swing Low' Auto SL mode.")
float manual_sl     = input.float(0.0, "Manual Stop Loss Price (0 = Auto)", minval=0.0, step=0.1, group=groupSL, tooltip="Enter a specific price to manually override the Auto algorithm. Leave it at 0 to let the script automatically calculate the SL.")

// --- Volatility Stop Settings (ATR/ADR) ---
int atr_length      = input.int(14, "ATR Length (Days)", minval=1, group=groupVol)
int adr_length      = input.int(20, "ADR Length (Days)", minval=1, group=groupVol)
float sl_vol_mult   = input.float(1.0, "ATR/ADR SL Multiplier", minval=0.1, step=0.1, group=groupVol, tooltip="Multiplier applied to ATR% or ADR% when calculating the stop loss (e.g., 1.5x ATR/ADR).")

// --- Moving Average Stop Settings (MA / Smart) ---
string sl_ma_type   = input.string("SMA", "Stop Loss MA Type", options=["SMA", "EMA"], group=groupMA, tooltip="Select whether to use a Simple Moving Average (SMA) or Exponential Moving Average (EMA) for the stop loss calculation.")
int sl_ma_length    = input.int(20, "Stop Loss MA Length", minval=1, group=groupMA, tooltip="The number of bars/candles to use for the selected moving average calculation.")
float smart_sl_pct  = input.float(2.0, "Smart SL Tolerance (%)", minval=0.0, step=0.1, group=groupMA, tooltip="If 'Smart' is selected, the selected MA is used if it sits within this percentage of the LOD. Otherwise, it defaults to LOD.")

// --- Widget Layout ---
bool show_widget = input.bool(true, "Show Calculator Widget", group=groupUiSettings)

string pos_input = input.string("Bottom Center", "Widget Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=groupUiSettings)
string text_size_input = input.string("Small", "Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=groupUiSettings)

// --- Display Toggles ---
bool show_chart_lines = input.bool(true, "Show Entry/SL Lines on Chart", group=groupToggles)
bool show_daily_r   = input.bool(true, "Show Daily R", group=groupToggles)
bool show_mult      = input.bool(true, "Show R Multiplier", group=groupToggles)
bool show_base_r    = input.bool(true, "Show Base Currency R", group=groupToggles)
bool show_target_r  = input.bool(true, "Show Target Currency R", group=groupToggles)
bool show_exch_rate = input.bool(true, "Show Exchange Rate", group=groupToggles)
bool show_entry     = input.bool(true, "Show Entry Price", group=groupToggles)
bool show_sl        = input.bool(true, "Show Stop Loss Price", group=groupToggles)
bool show_sl_pct    = input.bool(true, "Show SL %", group=groupToggles)
bool show_atr       = input.bool(true, "Show ATR %", group=groupToggles)
bool show_adr       = input.bool(true, "Show ADR %", group=groupToggles)
bool show_pos_shares= input.bool(true, "Show Position Size (# of Shares)", group=groupToggles)
bool show_pos_base  = input.bool(true, "Show Position Size (Base)", group=groupToggles)
bool show_pos_target= input.bool(true, "Show Position Size (Target)", group=groupToggles)
bool show_pos_050r  = input.bool(true, "Include 0.50R Position Sizing", group=groupToggles, tooltip="When enabled, displays 0.50R (Half Position) size inline alongside 1.00R.")
bool show_pos_025r  = input.bool(false, "Include 0.25R Position Sizing", group=groupToggles, tooltip="When enabled, displays 0.25R (Quarter Position) size inline alongside 1.00R.")


// --- Colors & Styling (Bottom) ---
color fg_color       = input.color(color.black, "Text", group=groupColors)
color bg_color       = input.color(color.white, "Background", group=groupColors)
color title_color    = input.color(color.new(color.yellow, 75), "Title", group=groupColors)
color body_color     = input.color(color.new(color.aqua, 85), "Body", group=groupColors)
color warn_bg_color  = input.color(color.new(color.red, 40), "Warning Background", group=groupColors)
color frame_color    = input.color(color.new(color.blue, 0), "Frame", group=groupColors)
int frame_width      = input.int(2, "Frame Width", minval=0, maxval=10, group=groupColors)
color border_color   = input.color(color.new(color.black, 0), "Border", group=groupColors)
int border_width     = input.int(1, "Border Width", minval=0, maxval=10, group=groupColors)
color entry_line_color = input.color(color.black, "Entry Line Color", group=groupColors)
color sl_line_color    = input.color(color.red, "Stop Loss Line Color", group=groupColors)

// =========================================================================
// 2. HELPERS & AUTO-CALCULATIONS
// =========================================================================

get_text_size(size_input) => switch size_input
    "Auto"   => size.auto
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

get_table_position(pos_in) => switch pos_in
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.bottom_center

get_symbol(curr) => switch curr
    "USD" => "$"
    "GBP" => "£"
    "EUR" => "€"
    "TRY" => "₺"
    "ILS" => "₪"
    "ILA" => "ag"
    "CAD" => "C$"
    "CNY" => "¥"
    "JPY" => "¥"
    "KRW" => "₩"
    "TWD" => "NT$"
    "INR" => "₹"
    => curr

// Multiplier & Risk Math
int daily_usd_r = custom_daily_r == 0 ? daily_r_dropdown : custom_daily_r

float auto_mult = timeframe.isdaily ? 1.0 : timeframe.isweekly or timeframe.ismonthly ? 2.5 : 1.0
string tf_label = manual_mult > 0.0 ? "Manual" : timeframe.isdaily ? "Daily" : timeframe.isweekly ? "Weekly" : timeframe.ismonthly ? "Monthly" : "Intraday"
float final_multiplier = manual_mult > 0.0 ? manual_mult : auto_mult
float effective_usd_risk = daily_usd_r * final_multiplier

// Track intraday daily session high/low dynamically to avoid request.security lag/lookahead bugs
var float intraday_lod = na
var float intraday_hod = na
if timeframe.isintraday
    bool is_new_day = ta.change(time("D")) != 0 or na(time("D")[1])
    intraday_lod := is_new_day ? low : math.min(low, nz(intraday_lod, low))
    intraday_hod := is_new_day ? high : math.max(high, nz(intraday_hod, high))

float lod_val = timeframe.isintraday ? intraday_lod : low
float hod_val = timeframe.isintraday ? intraday_hod : high

// Fetch exact previous daily low natively using lookahead=barmerge.lookahead_on to get the closed day's low
float prev_daily_low = nz(request.security(syminfo.tickerid, "D", low[1], lookahead = barmerge.lookahead_on), nz(low[1], low))

// Adaptive previous low calculation & label
float prev_low_val = timeframe.isintraday ? prev_daily_low : low[1]
string lopd_label = timeframe.isweekly ? "LOPW" : timeframe.ismonthly ? "LOPM" : "LOPD"
float sma_val = ta.sma(close, sl_ma_length)
float ema_val = ta.ema(close, sl_ma_length)
float sl_ma_val = sl_ma_type == "EMA" ? ema_val : sma_val
float swing_low = ta.lowest(low, swing_lookback)
float swing_high = ta.highest(high, swing_high_lookback)

// --- Volatility calculations ---
string atr_timeframe_label = timeframe.isdaily ? "D" : timeframe.isweekly ? "W" : timeframe.ismonthly ? "M" : "ID"
float atr_val = request.security(syminfo.tickerid, timeframe.period, ta.atr(atr_length))
float adr_pct_daily = request.security(syminfo.tickerid, "D", 100 * (ta.sma(high / low, adr_length) - 1))

// Detect Target Currency
string target_currency = syminfo.currency

// Dynamic Entry Logic & Display Tagging
float auto_entry_val = close
string auto_entry_str = "Close"

if auto_entry_mode == "Current Bar High"
    auto_entry_val := high
    auto_entry_str := "Bar High"
else if auto_entry_mode == "High of Day (HOD)"
    auto_entry_val := hod_val
    auto_entry_str := "HOD"
else if auto_entry_mode == "Recent Swing High"
    auto_entry_val := swing_high
    auto_entry_str := "Swing High (" + str.tostring(swing_high_lookback) + ")"

float entry_price = manual_entry == 0.0 ? auto_entry_val : manual_entry
string entry_source_label = manual_entry == 0.0 ? auto_entry_str : "Manual"

float atr_pct = entry_price > 0 ? (atr_val / entry_price) * 100 : 0.0
float adr_pct = adr_pct_daily
float adr_val = entry_price * (adr_pct / 100)

// Smart Auto SL Logic & Display Tagging
float auto_sl_val = low
string auto_sl_str = "Bar Low"

if auto_sl_mode == "Low of Day (LOD)"
    auto_sl_val := lod_val
    auto_sl_str := "LOD"
else if auto_sl_mode == "Previous Candle Low"
    auto_sl_val := prev_low_val
    auto_sl_str := lopd_label
else if auto_sl_mode == "Recent Swing Low"
    auto_sl_val := swing_low
    auto_sl_str := "Swing Low (" + str.tostring(swing_lookback) + ")"
else if auto_sl_mode == "MA"
    auto_sl_val := sl_ma_val
    auto_sl_str := str.tostring(sl_ma_length) + " " + sl_ma_type
else if auto_sl_mode == "LOD or MA (Smart)"
    float dist_pct = lod_val > 0 ? (math.abs(sl_ma_val - lod_val) / lod_val) * 100 : 100.0
    if dist_pct <= smart_sl_pct and sl_ma_val < lod_val
        auto_sl_val := sl_ma_val
        auto_sl_str := "Smart: " + str.tostring(sl_ma_length) + " " + sl_ma_type
    else
        auto_sl_val := lod_val
        auto_sl_str := "Smart: LOD"
else if auto_sl_mode == "ATR%"
    auto_sl_val := entry_price - (atr_val * sl_vol_mult)
    auto_sl_str := str.tostring(sl_vol_mult, "#.#") + "x ATR% (" + str.tostring(atr_pct * sl_vol_mult, "#.##") + "%)"
else if auto_sl_mode == "ADR%"
    auto_sl_val := entry_price - (adr_val * sl_vol_mult)
    auto_sl_str := str.tostring(sl_vol_mult, "#.#") + "x ADR% (" + str.tostring(adr_pct * sl_vol_mult, "#.##") + "%)"

float stop_loss = manual_sl == 0.0 ? auto_sl_val : manual_sl
string sl_source_label = manual_sl == 0.0 ? auto_sl_str : "Manual"

// Currency Conversion & ATR 
float conversion_rate = nz(request.currency_rate("USD", target_currency), 1.0)
float risk_in_target_currency = effective_usd_risk * conversion_rate
string target_sym = get_symbol(target_currency)

// --- Original vs New R Calculation ---
float auto_risk_per_share = math.abs(auto_entry_val - auto_sl_val)
float auto_shares = (auto_risk_per_share > 0 and auto_entry_val > 0) ? math.floor(risk_in_target_currency / auto_risk_per_share) : 0.0

float new_risk_target = risk_in_target_currency
float new_risk_usd = effective_usd_risk
float new_r_mult = final_multiplier

if manual_entry > 0.0 or manual_sl > 0.0
    float manual_risk_per_share = math.abs(entry_price - stop_loss)
    new_risk_target := auto_shares * manual_risk_per_share
    new_risk_usd := conversion_rate > 0 ? new_risk_target / conversion_rate : 0.0
    new_r_mult := daily_usd_r > 0 ? new_risk_usd / daily_usd_r : 0.0

// --- Stop Loss Deviation and Breach Logic ---
float sl_deviation_pct = (auto_sl_val > 0 and stop_loss < auto_sl_val) ? ((auto_sl_val - stop_loss) / auto_sl_val) * 100.0 : 0.0
float min_allowed_sl   = auto_sl_val * (1.0 - r_tolerance / 100.0)

bool show_final_r  = (manual_entry > 0.0 or manual_sl > 0.0) and (stop_loss < auto_sl_val)
bool is_r_breached = (manual_entry > 0.0 or manual_sl > 0.0) and (sl_deviation_pct > r_tolerance)

// --- Exceedance calculations ---
float exceed_risk_target = math.max(0.0, new_risk_target - risk_in_target_currency)
float extra_r_multiplier = math.max(0.0, new_r_mult - final_multiplier)

// Sector and Industry safeguards
string chart_sector = syminfo.sector == "" ? "N/A" : syminfo.sector
string chart_industry = syminfo.industry == "" ? "N/A" : syminfo.industry

// =========================================================================
// 3. DISPLAY TABLE & 4. CHART LINES
// =========================================================================
var table statusTable = table.new(
    position=get_table_position(pos_input),
    columns = 2,
    rows = 18, 
    bgcolor=bg_color,
    frame_color=frame_color,
    frame_width=frame_width,
    border_width=border_width, 
    border_color=border_color
)

set_table_cell(int column, int row, string txt="", color fg=color.black, color bg=color.white, string txt_fmt="normal") =>
    format_str = txt_fmt == "bold" ? text.format_bold : text.format_none
    table.cell(statusTable, column, row, txt, text_color=fg, bgcolor=bg, text_size=get_text_size(text_size_input), text_formatting=format_str)

// Persistent Line and Label Variables
var line entry_line = na
var line sl_line = na
var label entry_label = na
var label sl_label = na

if barstate.islast
    // Core Position Sizing Math
    float risk_per_share = math.abs(entry_price - stop_loss)
    float shares = (risk_per_share > 0 and entry_price > 0) ? risk_in_target_currency / risk_per_share : 0
    float sl_pct = entry_price > 0 ? (risk_per_share / entry_price) * 100 : 0.0
    
    // Position Value Math (Target and Base for 1.00R, 0.50R, 0.25R)
    float final_shares_100 = math.floor(shares)
    float final_shares_050 = math.floor(shares * 0.50)
    float final_shares_025 = math.floor(shares * 0.25)

    float pos_value_target_100 = final_shares_100 * entry_price
    float pos_value_target_050 = final_shares_050 * entry_price
    float pos_value_target_025 = final_shares_025 * entry_price

    float pos_value_base_100 = pos_value_target_100 / conversion_rate
    float pos_value_base_050 = pos_value_target_050 / conversion_rate
    float pos_value_base_025 = pos_value_target_025 / conversion_rate

    // --- Line & Label Drawing Logic ---
    if show_chart_lines
        string entry_text = "Entry: " + str.tostring(entry_price, format.mintick)
        string sl_text = "SL: " + str.tostring(stop_loss, format.mintick)

        if na(entry_line)
            entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color=entry_line_color, width=2, style=line.style_dashed, extend=extend.right)
            sl_line := line.new(bar_index, stop_loss, bar_index + 1, stop_loss, color=sl_line_color, width=2, style=line.style_dashed, extend=extend.right)
            
            entry_label := label.new(bar_index + 1, entry_price, text=entry_text, color=color.new(entry_line_color, 0), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
            sl_label := label.new(bar_index + 1, stop_loss, text=sl_text, color=color.new(sl_line_color, 0), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
        else
            line.set_xy1(entry_line, bar_index, entry_price)
            line.set_xy2(entry_line, bar_index + 1, entry_price)
            line.set_color(entry_line, entry_line_color)
            
            line.set_xy1(sl_line, bar_index, stop_loss)
            line.set_xy2(sl_line, bar_index + 1, stop_loss)
            line.set_color(sl_line, sl_line_color)

            label.set_xy(entry_label, bar_index + 1, entry_price)
            label.set_text(entry_label, entry_text)
            label.set_color(entry_label, color.new(entry_line_color, 0))
            label.set_textcolor(entry_label, color.white)

            label.set_xy(sl_label, bar_index + 1, stop_loss)
            label.set_text(sl_label, sl_text)
            label.set_color(sl_label, color.new(sl_line_color, 0))
            label.set_textcolor(sl_label, color.white)
    else
        if not na(entry_line)
            line.delete(entry_line)
            line.delete(sl_line)
            label.delete(entry_label)
            label.delete(sl_label)
            entry_line := na
            sl_line := na
            entry_label := na
            sl_label := na

    // --- Table Drawing Logic ---
    table.clear(statusTable, 0, 0, 1, 17)
    
    if show_widget
        int r = 0 // Dynamic row counter
        
        // Title (Always Show)
        set_table_cell(0, r, "Position Sizing", fg = fg_color, bg = title_color, txt_fmt = "bold")
        set_table_cell(1, r, syminfo.ticker, fg = fg_color, bg = title_color, txt_fmt = "bold")
        r += 1

        // Sector & Industry (Always Show)
        set_table_cell(0, r, chart_sector, fg = fg_color, bg = title_color, txt_fmt = "bold")
        set_table_cell(1, r, chart_industry, fg = fg_color, bg = title_color, txt_fmt = "bold")
        r += 1

        // Optional Rows
        if show_daily_r
            set_table_cell(0, r, "Daily R (USD)", bg = body_color, fg = fg_color)
            set_table_cell(1, r, "$" + str.tostring(daily_usd_r), bg = body_color, fg = fg_color)
            r += 1

        if show_mult
            set_table_cell(0, r, "R Multiplier (" + tf_label + ")", bg = body_color, fg = fg_color)
            set_table_cell(1, r, str.tostring(final_multiplier, "#.#") + "x", bg = body_color, fg = fg_color)
            r += 1

        if show_base_r
            set_table_cell(0, r, "Base Currency R (USD)", bg = body_color, fg = fg_color)
            set_table_cell(1, r, "$" + str.tostring(effective_usd_risk, "#.##"), bg = body_color, fg = fg_color)
            r += 1
            
        if show_target_r
            set_table_cell(0, r, "Target Currency R (" + target_currency + ")", bg = body_color, fg = fg_color)
            set_table_cell(1, r, target_sym + str.tostring(risk_in_target_currency, "#.##"), bg = body_color, fg = fg_color)
            r += 1
            
        if show_exch_rate
            set_table_cell(0, r, "Exchange Rate", bg = title_color, fg = fg_color, txt_fmt = "bold")
            set_table_cell(1, r, "1 USD = " + str.tostring(conversion_rate, "#.####") + " " + target_currency, bg = title_color, fg = fg_color, txt_fmt = "bold")
            r += 1

        if show_entry
            string entry_label_col = "Entry Price (" + entry_source_label + ")"
            set_table_cell(0, r, entry_label_col, bg = body_color, fg = fg_color)
            set_table_cell(1, r, str.tostring(entry_price, format.mintick), bg = body_color, fg = fg_color)
            r += 1

        if show_sl
            set_table_cell(0, r, "Stop Loss Price", bg = body_color, fg = fg_color)
            set_table_cell(1, r, str.tostring(stop_loss, format.mintick), bg = body_color, fg = fg_color)
            r += 1

        if show_sl_pct
            string sl_label_col = "SL % (" + sl_source_label + ")"
            string sl_display = str.tostring(sl_pct, "#.##") + "%"
            
            // Warning logic for wide stop losses
            color current_row_bg = sl_pct > atr_pct ? warn_bg_color : body_color
            color current_text_color = sl_pct > atr_pct ? color.white : fg_color 
            string current_txt_fmt = sl_pct > atr_pct ? "bold" : "normal"
            
            set_table_cell(0, r, sl_label_col, bg = current_row_bg, fg = current_text_color, txt_fmt = current_txt_fmt)
            set_table_cell(1, r, sl_display, bg = current_row_bg, fg = current_text_color, txt_fmt = current_txt_fmt)
            r += 1

        if show_atr
            string atr_display = str.tostring(atr_pct, "#.##") + "%"
            set_table_cell(0, r, "ATR % [" + str.tostring(atr_length) + atr_timeframe_label + "]", bg = body_color, fg = fg_color)
            set_table_cell(1, r, atr_display, bg = body_color, fg = fg_color)
            r += 1

        if show_adr
            string adr_display = str.tostring(adr_pct, "#.##") + "%"
            set_table_cell(0, r, "ADR % [" + str.tostring(adr_length) + "D]", bg = body_color, fg = fg_color)
            set_table_cell(1, r, adr_display, bg = body_color, fg = fg_color)
            r += 1

        string tag_suffix = ""
        if show_pos_050r and show_pos_025r
            tag_suffix := " [1R | 0.5R | 0.25R]"
        else if show_pos_050r
            tag_suffix := " [1R | 0.5R]"
        else if show_pos_025r
            tag_suffix := " [1R | 0.25R]"

        if show_pos_shares
            string pos_shares_label = "Position Size (# of Shares" + (tag_suffix != "" ? tag_suffix + ")" : ")")
            string pos_shares_val   = str.tostring(final_shares_100)
            if show_pos_050r
                pos_shares_val += " | " + str.tostring(final_shares_050)
            if show_pos_025r
                pos_shares_val += " | " + str.tostring(final_shares_025)
            set_table_cell(0, r, pos_shares_label, bg = title_color, fg = fg_color, txt_fmt = "bold")
            set_table_cell(1, r, pos_shares_val, bg = title_color, fg = fg_color, txt_fmt = "bold")
            r += 1
        
        if show_pos_base
            string pos_base_label = "Position Size (USD" + (tag_suffix != "" ? tag_suffix + ")" : ")")
            string pos_base_val   = "$" + str.tostring(pos_value_base_100, "#.##")
            if show_pos_050r
                pos_base_val += " | $" + str.tostring(pos_value_base_050, "#.##")
            if show_pos_025r
                pos_base_val += " | $" + str.tostring(pos_value_base_025, "#.##")
            set_table_cell(0, r, pos_base_label, bg = body_color, fg = fg_color)
            set_table_cell(1, r, pos_base_val, bg = body_color, fg = fg_color)
            r += 1

        if show_pos_target
            string pos_target_label = "Position Size (" + target_currency + (tag_suffix != "" ? tag_suffix + ")" : ")")
            string pos_target_val   = target_sym + str.tostring(pos_value_target_100, "#.##")
            if show_pos_050r
                pos_target_val += " | " + target_sym + str.tostring(pos_value_target_050, "#.##")
            if show_pos_025r
                pos_target_val += " | " + target_sym + str.tostring(pos_value_target_025, "#.##")
            set_table_cell(0, r, pos_target_label, bg = title_color, fg = fg_color, txt_fmt = "bold")
            set_table_cell(1, r, pos_target_val, bg = title_color, fg = fg_color, txt_fmt = "bold")
            r += 1

        // Display Final R Value row at all times
        if show_base_r
            string final_r_label = "Final R Value"
            string final_r_val = target_sym + str.tostring(new_risk_target, "#.##") + " (+" + target_sym + str.tostring(exceed_risk_target, "#.##") + " / +" + str.tostring(extra_r_multiplier, "#.##") + "x R)"
            color row_bg = is_r_breached ? warn_bg_color : body_color
            color row_fg = is_r_breached ? color.white : fg_color
            string row_fmt = is_r_breached ? "bold" : "normal"
            set_table_cell(0, r, final_r_label, bg = row_bg, fg = row_fg, txt_fmt = row_fmt)
            set_table_cell(1, r, final_r_val, bg = row_bg, fg = row_fg, txt_fmt = row_fmt)
            r += 1
````
