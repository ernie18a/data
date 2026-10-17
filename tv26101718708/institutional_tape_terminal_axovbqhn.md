# Institutional Tape Terminal

- url: https://www.tradingview.com/script/AXoVbqhN-Institutional-Tape-Terminal/
- type: indicator
- pine_id: PUB;71e7e55b7dba41988b40051ce96fbbcf
- version: 1.0

## Description

[b]INSTITUTIONAL TAPE TERMINAL: THE DEFINITIVE DOCUMENTATION[/b]
The Institutional Tape Terminal [i][ZOM][/i] is not just an indicator; it is a high-frequency data synthesis engine. It was built to solve a specific problem on TradingView: the lack of a professional-grade, real-time Time & Sales terminal that filters market noise through institutional-grade mathematics.

By leveraging the varip persistence engine, this terminal processes every single price tick within a candle, allowing you to see the "[i]hidden[/i]" war between retail, professional, and institutional players. It converts the chaotic flow of the tape into actionable intelligence via five core analytical modules.

[b]I. THE MATHEMATICS OF THE TAPE ENGINE[/b]
The terminal’s core logic operates on the principle of Intra-Bar Differentials. Because the standard data feed only provides cumulative bar volume, the terminal must derive individual order data manually.

[b]1. DERIVED ORDER SIZE (S)[/b]
The script captures the volume at the exact millisecond of a price update and compares it to the previous known volume state.

Order_Size = Current_Total_Volume - Previous_Update_Volume

[b]2. AGGRESSOR SIDE ASSIGNMENT (SIDE)[/b]
We define aggression not by the side of the book (Bid/Ask), but by the direction of price displacement caused by the market order.


If Current_Price > Previous_Price: Side = +1 (Aggressive Buyer)
If Current_Price < Previous_Price: Side = -1 (Aggressive Seller)
If Current_Price = Previous_Price: Side = 0 (Absorption/Neutral)

[b]3. ACCUMULATIVE BAR DELTA (D)[/b]
The net difference between aggressive buying and aggressive selling volume for the current candle.

Delta = Sum(Order_Size * Side)*

[b]II. ADVANCED INSTITUTIONAL MODULES[/b]

[b]1. ADAPTIVE WHALE LOGIC (VOLATILITY-ADJUSTED THRESHOLDING)[/b]
Static thresholds fail during sessions like the Asia Open or NFP releases because "[i]normal[/i]" volume changes. Our adaptive engine uses a dynamic baseline to identify outliers.


Baseline_Size = SMA(Bar_Volume, 20) / SMA(Bar_Tick_Count, 20)
Whale_Threshold = Baseline_Size * Adaptive_Sensitivity
Application: A "Gold Whale" is triggered only when an order is significantly larger (e.g., 5.0x) than the current average order size in the local market environment.*

[b]2. TICKS PER SECOND (TPS) - THE SPEED OF TAPE[/b]
TPS is the ultimate lead indicator for algorithmic activity. It measures the frequency of trade execution regardless of size.


Time_Delta = Current_Time_Milliseconds - Time_at_N_Ticks_Ago
TPS = (Sample_Window_Size * 1000) / Time_Delta
Application: If TPS jumps from 1.5 to 10.0, high-frequency algorithms have entered the market, usually preceding a massive price expansion.*

[b]3. TAPE VWAP (MICRO-TREND COST BASIS)[/b]
Standard VWAP covers the whole day. Tape VWAP calculates the Volume Weighted Average Price for only the orders currently scrolling in your tape depth (the last N orders).

Tape_VWAP = Sum(Order_Price * Order_Size) / Sum(Order_Size)
Application: This represents the average price paid by the "Active Participants." If price is below Tape VWAP, the aggressive buyers on your screen are losing money.*

[b]4. VOLUME DISTRIBUTION MATRIX (RETAIL VS. INSTITUTION)[/b]
We segment every order into three liquidity tiers to reveal who is in control of the trend.

Retail % = (Sum of Small Orders / Total Bar Volume) * 100
Pro % = (Sum of Medium Orders / Total Bar Volume) * 100
Institutional % = (Sum of Whale Orders / Total Bar Volume) * 100
Application: A rally driven by 80% Retail is a "Trap." A rally driven by 80% Institutional is a "Trend."*

[b]5. SLIPPAGE TRACKING (SLIP)[/b]
Detects liquidity vacuums by measuring price gaps between trades.

Slippage = Abs(Current_Price - Previous_Price) - 1_Tick
Application: High slippage indicates thin liquidity. If SLIP is high, expect "Violent" price moves as the market hunts for the next available order block.

[b]III. THE VISUAL INTERFACE & PSYCHOLOGY[/b]

[b]TOP-DOWN INTELLIGENCE (INVERTED LAYOUT)[/b]
The terminal is designed with a Bottom-Up Inversion model.

Summary Metrics (The Brain): Placed at the very top for immediate situational awareness (TPS, VWAP, Delta, Matrix).
The Live Stream (The Heart): New orders print at the bottom of the table and scroll upwards. This allows the trader's eye to stay fixed on the junction between the live print and the summary data.

[b]WHALE CLUSTER DEFENSE LINES[/b]
Institutional players often defend their entry prices. When a Gold Whale prints, the script maps that price to a horizontal dashed line:

Defense_Line_Y = Price_of_Whale_Order
Visual: These lines act as real-time Support/Resistance levels. A cluster of 3 lines in a tight range indicates a "Wall" that institutions are protecting.

[b]THE 9 SPECIALIZED COLORWAYS[/b]
Visual psychology is critical for order flow. 9 themes are provided:

Gold Rush: Optimized for high-contrast visibility of "Big Money."
Synthwave: Neon indigo/fuchsia for high-energy sessions.
Deep Sea: Bioluminescent teals for low eye-strain in dark rooms.
Carbon: Stealth/Slate for minimal distractions.
Emerald / Red Planet: Environment-specific heat-mapping for directional bias.
and more

[b]IV. TRADING STRATEGIES WITH THE TERMINAL[/b]

[b]1. THE ABSORPTION FLIP[/b]
Watch the ABSORB metric. If you see price hitting a resistance level, the Tape is printing massive Green orders, but price is NOT moving ($Side = 0$), the ABSORB value will spike. This means a Large Seller is sitting there with a massive Limit Order, "Absorbing" all the buyers. Once the buyers are exhausted, price will collapse.

[b]2. ALGORITHMIC SQUEEZE[/b]
Look for confluence:

TPS > 8.0 (Algorithms are active)
Institutional Distribution > 50% (Big Money is buying)
Price > Tape VWAP (Buyers are in profit)
Result: High-probability long entry.

[b]3. THE WHALE REJECTION[/b]
Identify a Whale Cluster (Defense Lines). When price returns to a Gold-Dashed line and you see a Red Whale print at that exact level with high TPS, it confirms the institution is defending their position. This is a "[i]Sniper[/i]" entry point.

[b]INPUT CONFIGURATION SUMMARY[/b]
Adaptive Whale Logic: Automatically tunes the Whale threshold based on recent volatility.
Adaptive Sensitivity: Higher values make the Gold Whale signal more exclusive.
Auto-Hide Noise: Removes the "Retail clutter" from the tape to focus only on big orders.
PO3 Matrix: Shows trend alignment (Bulls vs Bears) across 3 custom timeframes (5m, 15m, 1h).
Right Side Offset: Floats the table away from the price scale for a cleaner UI.

[i][b]This is the most mathematically complete and visually advanced Tape Terminal ever released on TradingView. Trade with institutional transparency.[/b][/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Institutional Tape Terminal", shorttitle="ZOM Tape Terminal", overlay=true, max_bars_back=500)

theme_choice = input.string("Gold Rush", "Visual Colorway", options=["Gold Rush", "Cyberpunk", "Classic", "Monochrome", "Synthwave", "Deep Sea", "Carbon", "Red Planet", "Emerald"], group="Styling", tooltip="Choose a specialized visual theme. Each colorway is tuned for different lighting environments and trader psychology.")

auto_whale     = input.bool(true, "Adaptive Whale Logic", group="Adaptive Logic", tooltip="Enables AI-like thresholding. The script calculates the average order size in real-time and defines 'Whales' as outliers relative to current market conditions. Vital for high-volatility sessions.")
auto_sens      = input.float(5.0, "Adaptive Sensitivity", minval=1.0, step=0.5, group="Adaptive Logic", tooltip="Multiplier for the 'Whale' threshold. A value of 5.0 means an order must be 5x larger than the recent average to trigger a Gold Whale signal.")
hide_noise     = input.bool(false, "Auto-Hide Noise", group="Adaptive Logic", tooltip="Cleans the interface by hiding orders smaller than the current average. Use this during high-frequency 'Stop Runs' to see only the orders that matter.")

retail_max    = input.float(10.0, "Retail Cap (Small)", minval=0.1, group="Tiers", tooltip="Manual limit: Orders below this are tagged as 'Retail' in the distribution matrix.")
pro_min       = input.float(10.0, "Pro Min (Medium)", minval=0.1, group="Tiers", tooltip="Manual limit: Orders between Retail Cap and Whale Threshold.")
whale_min_in  = input.float(100.0, "Static Whale Threshold", minval=0.1, group="Tiers", tooltip="Manual limit: Absolute volume size required to trigger a Whale signal.")

tape_depth     = input.int(25, "Tape Depth", minval=1, maxval=50, group="Engine", tooltip="Determines how many order rows are visible in the scrolling tape. Higher depth provides more historical context but uses more screen real-estate.")
cluster_count  = input.int(5, "Defense Clusters", minval=0, maxval=10, group="Engine", tooltip="Tracks the price levels of the most recent Whales and draws them as horizontal dashed lines. These often act as institutional Support/Resistance.")
tps_window     = input.int(10, "TPS Sample Size", minval=2, maxval=20, group="Engine", tooltip="The number of recent prints used to calculate Ticks-Per-Second (TPS). A smaller window is faster; a larger window is more stable.")

tf_1 = input.timeframe("5",  "Bubble 1 (Fast)", group="PO3 Matrix", tooltip="The lowest timeframe for trend alignment analysis. Represents immediate momentum.")
tf_2 = input.timeframe("15", "Bubble 2 (Mid)", group="PO3 Matrix", tooltip="The medium timeframe for trend alignment analysis. Confirms short-term trend stability.")
tf_3 = input.timeframe("60", "Bubble 3 (Slow)", group="PO3 Matrix", tooltip="The anchor timeframe. Alignment with this bubble suggests high-probability trend continuation.")

h_offset       = input.int(1, "Right Side Offset", minval=0, maxval=5, group="Visuals", tooltip="Adds horizontal padding to the right of the table. Use this to prevent the tape from overlapping with the price scale or order entry buttons.")
t_size         = input.string(size.small, "Font Size", options=[size.tiny, size.small, size.normal, size.large], group="Visuals", tooltip="Scales the text of the entire terminal. Useful for high-resolution monitors or multi-chart layouts.")

var color bull_c  = na
var color bear_c  = na
var color whale_c = #FFD700 
var color neut_c  = #808080

switch theme_choice
    "Gold Rush" =>
        bull_c := #00ffbb, bear_c := #ff4444, whale_c := #FFD700, neut_c := #888888
    "Cyberpunk" =>
        bull_c := #00ff00, bear_c := #ff00ff, whale_c := #FFD700, neut_c := #666666
    "Classic" =>
        bull_c := #089981, bear_c := #f23645, whale_c := #FFD700, neut_c := #cccccc
    "Monochrome" =>
        bull_c := #ffffff, bear_c := #555555, whale_c := #FFD700, neut_c := #888888
    "Synthwave" =>
        bull_c := #3d5afe, bear_c := #f50057, whale_c := #f3e5f5, neut_c := #9c27b0
    "Deep Sea" =>
        bull_c := #1de9b6, bear_c := #2979ff, whale_c := #ffd600, neut_c := #006064
    "Carbon" =>
        bull_c := #90a4ae, bear_c := #455a64, whale_c := #ffa726, neut_c := #263238
    "Red Planet" =>
        bull_c := #ffab40, bear_c := #bf360c, whale_c := #ffff00, neut_c := #3e2723
    "Emerald" =>
        bull_c := #00e676, bear_c := #388e3c, whale_c := #ffea00, neut_c := #1b5e20

bubble_sym(int s) => 
    s == 1 ? "●" : (s == -1 ? "●" : "○")

bubble_col(int s, color b, color r, color n) => 
    s == 1 ? b : (s == -1 ? r : n)

f_get_tf_data(string _tf) =>
    [o, c] = request.security(syminfo.tickerid, _tf, [open, close])
    delta = c - o
    [delta, delta > 0 ? 1 : (delta < 0 ? -1 : 0)]

varip float[] price_h = array.new_float()
varip float[] size_h  = array.new_float()
varip int[]   time_h  = array.new_int()
varip int[]   side_h  = array.new_int() 

varip float delta_bar    = 0.0
varip float absorb_bar   = 0.0
varip float retail_v     = 0.0
varip float pro_v        = 0.0
varip float inst_v       = 0.0
varip float slip_sum     = 0.0
varip int   ticks_in_bar = 0
varip float last_vol     = 0.0
varip float last_px      = na

varip float[] whale_levels = array.new_float()
var line[] whale_lines = array.new_line()

avg_bar_vol    = ta.sma(volume, 20)
varip int prev_ticks = 100 
if barstate.isnew
    prev_ticks := ticks_in_bar > 0 ? ticks_in_bar : prev_ticks
avg_ticks      = ta.sma(prev_ticks, 20)
baseline_size  = avg_bar_vol / math.max(1, avg_ticks)
active_whale_min = auto_whale ? baseline_size * auto_sens : whale_min_in

if barstate.isnew
    last_vol     := 0.0
    absorb_bar   := 0.0
    retail_v     := 0.0
    pro_v        := 0.0
    inst_v       := 0.0
    slip_sum     := 0.0
    ticks_in_bar := 0

current_vol = nz(volume)
order_vol   = current_vol - last_vol
current_px  = close

bool is_whale_tick = false
bool pass_filter = not hide_noise or order_vol >= baseline_size

if barstate.isrealtime and order_vol > 0 and pass_filter
    int side = 0
    if not na(last_px)
        float gap = math.abs(current_px - last_px)
        if gap > syminfo.mintick
            slip_sum += gap
        side := current_px > last_px ? 1 : (current_px < last_px ? -1 : 0)
        if side == 0
            absorb_bar += order_vol
    
    if order_vol < (auto_whale ? baseline_size : retail_max)
        retail_v += order_vol
    else if order_vol < active_whale_min
        pro_v += order_vol
    else
        inst_v += order_vol
        is_whale_tick := true
        array.unshift(whale_levels, current_px)
        if array.size(whale_levels) > cluster_count
            array.pop(whale_levels)

    delta_bar    += (order_vol * side)
    ticks_in_bar += 1
    
    array.unshift(price_h, current_px)
    array.unshift(size_h,  order_vol)
    array.unshift(time_h,  timenow)
    array.unshift(side_h,  side)
    
    if array.size(price_h) > tape_depth
        array.pop(price_h), array.pop(size_h), array.pop(time_h), array.pop(side_h)
    
    last_px  := current_px
    last_vol := current_vol

float current_tps = 0.0
if array.size(time_h) >= tps_window
    int diff_t = array.get(time_h, 0) - array.get(time_h, tps_window - 1)
    if diff_t > 0
        current_tps := (tps_window * 1000.0) / diff_t

float tape_vwap_sum_pv = 0.0, float tape_vwap_sum_v  = 0.0
if array.size(price_h) > 0
    for i = 0 to array.size(price_h) - 1
        v = array.get(size_h, i)
        tape_vwap_sum_pv += array.get(price_h, i) * v
        tape_vwap_sum_v  += v
float tape_vwap = tape_vwap_sum_v > 0 ? tape_vwap_sum_pv / tape_vwap_sum_v : na

[d1, s1] = f_get_tf_data(tf_1)
[d2, s2] = f_get_tf_data(tf_2)
[d3, s3] = f_get_tf_data(tf_3)

if barstate.isrealtime
    if array.size(whale_lines) > 0
        for l in whale_lines
            line.delete(l)
        array.clear(whale_lines)
    if array.size(whale_levels) > 0
        for i = 0 to array.size(whale_levels) - 1
            l = line.new(bar_index - 50, array.get(whale_levels, i), bar_index + 10, array.get(whale_levels, i), color=color.new(whale_c, 50), style=line.style_dashed)
            array.push(whale_lines, l)

int cols = 3 + h_offset
var ui = table.new(position.middle_right, cols, tape_depth + 35, border_width=0)

if barstate.isrealtime
    table.clear(ui, 0, 0, cols - 1, tape_depth + 34)
    
    int r = 0
    table.cell(ui, 0, r, "TPS", text_color=neut_c, text_size=t_size), table.cell(ui, 1, r, str.tostring(current_tps, "#.##"), text_color=chart.fg_color, text_size=t_size, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1
    table.cell(ui, 0, r, "T-VWAP", text_color=neut_c, text_size=t_size), table.cell(ui, 1, r, str.tostring(tape_vwap, "#.##"), text_color=chart.fg_color, text_size=t_size, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1
    table.cell(ui, 0, r, "Σ DELTA", text_color=neut_c, text_size=t_size), table.cell(ui, 1, r, str.tostring(delta_bar, "#.#"), text_color=delta_bar >= 0 ? bull_c : bear_c, text_size=t_size, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1
    table.cell(ui, 0, r, "ABSORB", text_color=neut_c, text_size=t_size), table.cell(ui, 1, r, str.tostring(absorb_bar, "#.#"), text_color=whale_c, text_size=t_size, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1
    table.cell(ui, 0, r, "THRESH", text_color=neut_c, text_size=t_size), table.cell(ui, 1, r, str.tostring(active_whale_min, "#.#"), text_color=neut_c, text_size=t_size, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1

    float total_v = retail_v + pro_v + inst_v
    r := r + 1
    table.cell(ui, 0, r, "DISTRIBUTION", text_color=neut_c, text_size=size.tiny), table.merge_cells(ui, 0, r, 2, r), r := r + 1
    if total_v > 0
        table.cell(ui, 0, r, "RETAIL", text_color=neut_c, text_size=size.tiny), table.cell(ui, 1, r, str.tostring(retail_v/total_v*100, "0")+"%", text_color=neut_c, text_size=size.tiny, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1
        table.cell(ui, 0, r, "PRO", text_color=neut_c, text_size=size.tiny), table.cell(ui, 1, r, str.tostring(pro_v/total_v*100, "0")+"%", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1
        table.cell(ui, 0, r, "INSTIT.", text_color=neut_c, text_size=size.tiny), table.cell(ui, 1, r, str.tostring(inst_v/total_v*100, "0")+"%", text_color=whale_c, text_size=size.tiny, text_halign=text.align_right), table.merge_cells(ui, 1, r, 2, r), r := r + 1

    r := r + 1
    table.cell(ui, 0, r, "PO3 MATRIX", text_color=neut_c, text_size=size.tiny), table.merge_cells(ui, 0, r, 2, r), r := r + 1
    table.cell(ui, 0, r, tf_1, text_color=neut_c, text_size=size.tiny), table.cell(ui, 1, r, bubble_sym(s1), text_color=bubble_col(s1, bull_c, bear_c, neut_c), text_size=size.normal), table.merge_cells(ui, 1, r, 2, r), r := r + 1
    table.cell(ui, 0, r, tf_2, text_color=neut_c, text_size=size.tiny), table.cell(ui, 1, r, bubble_sym(s2), text_color=bubble_col(s2, bull_c, bear_c, neut_c), text_size=size.normal), table.merge_cells(ui, 1, r, 2, r), r := r + 1
    table.cell(ui, 0, r, tf_3, text_color=neut_c, text_size=size.tiny), table.cell(ui, 1, r, bubble_sym(s3), text_color=bubble_col(s3, bull_c, bear_c, neut_c), text_size=size.normal), table.merge_cells(ui, 1, r, 2, r), r := r + 2

    int tape_start_row = r
    if array.size(price_h) > 0
        for i = 0 to array.size(price_h) - 1
            float px   = array.get(price_h, i)
            float sz   = array.get(size_h, i)
            int   tm   = array.get(time_h, i)
            int   side = array.get(side_h, i)
            
            bool is_w = sz >= active_whale_min
            color txt = side == 1 ? bull_c : (side == -1 ? bear_c : neut_c)
            color bg  = is_w ? whale_c : color.new(chart.bg_color, 100)
            color ftxt = is_w ? color.black : txt
            
            int target_row = tape_start_row + (array.size(price_h) - 1) - i
            
            table.cell(ui, 0, target_row, str.format_time(tm, "HH:mm:ss"), text_color=ftxt, bgcolor=bg, text_size=t_size)
            table.cell(ui, 1, target_row, str.tostring(px, "#.####"), text_color=ftxt, bgcolor=bg, text_size=t_size, text_halign=text.align_right)
            table.cell(ui, 2, target_row, str.tostring(sz, "#.#") + (is_w ? " 🐋" : ""), text_color=ftxt, bgcolor=bg, text_size=t_size, text_halign=text.align_right)

plotshape(barstate.isrealtime and is_whale_tick, "Whale Activity", shape.circle, location.abovebar, whale_c, size=size.tiny)
````
