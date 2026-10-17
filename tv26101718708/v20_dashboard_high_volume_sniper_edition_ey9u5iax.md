# V20 Dashboard (High Volume Sniper Edition)

- url: https://www.tradingview.com/script/ey9u5IaX-V20-Dashboard-High-Volume-Sniper-Edition/
- type: indicator
- pine_id: PUB;4aeede7740484f5687760067be0e3df6
- version: 3.0

## Description

Overview
The V20 Dashboard is a mathematically driven Trap Filter and Signal Management system. Designed for high-volume traders, it abandons traditional "indicator stacking" methods that often lure retail traders into market maker traps. Instead, it measures raw oscillator exhaustion and momentum extension to surgically filter out low-probability trades and highlight high-probability "Sniper" entries.

While it is heavily optimized to work alongside custom volume or momentum oscillators and signal algorithms, its input architecture allows it to use any user-defined data sources.

⚙️ The Core Mechanisms
The script relies on three primary calculations to evaluate market safety in real-time. It reads the raw data lines on your chart and converts them into actionable "Safe" or "Trap" evaluations.

1. The Exhaustion Filter (Volume/Oscillator Size Cap)
When momentum spikes too violently in a single candle, the move is often exhausted. Market makers use these massive spikes to trap breakout traders before aggressively reversing the price.

Mechanism: The script measures the exact physical body size of your input source (e.g., Primary Oscillator Open to Close). If that size exceeds your Size Cap, it immediately flags the setup as an Exhaustion Trap and warns you to skip the trade.

2. The Rubber Band Filter (Distance Cap)
Price and momentum act like a rubber band attached to a baseline. If the data stretches too far away from its baseline, it is destined to snap back violently, hitting tight stop losses.

Mechanism: The script measures the absolute distance between your primary data source (Primary Oscillator Close) and a secondary moving average (Confirmation Line). If this distance exceeds your Distance Cap, it flags the setup as an Overextended Trap.

3. The Master Key (Zero-Trap State Alignment)

Mechanism: The script checks if the physical direction of the current oscillator candle (Bullish/Bearish) perfectly matches the direction of your Buy/Sell signal. When these dynamically align while remaining under the size/distance caps, the dashboard upgrades your signal to a 🔥 SNIPER ENTRY.

📊 Understanding the Dashboard UI
The on-chart table provides a complete, top-to-bottom view of market safety:

Live Metrics (Rows 1-3): Displays the raw mathematical data for Oscillator Size, Distance, and the Current State (Bullish/Bearish). Metrics turn green if safe, and red if a limit is breached.

LIVE ⚡ (Row 4): Evaluates the exact current moment.

🔥 SNIPER ENTRY: Size and Distance are safe, and the state alignment is perfect.

🟢 STANDARD ENTRY: Size and Distance are safe, but state alignment is neutral. (Safe to trade).

🚨 TRAP LIMIT BREACHED: A size or distance cap is broken. High risk of immediate reversal.

1-BAR AGO ⏪ (Row 5): Displays the exact dashboard state from one candle ago. Highly useful for evaluating signals that fired exactly on the previous close.

5-BAR AVG 📊 (Row 6): Prevents fakes from single erratic candles by calculating momentum over the last 5 bars. It averages the size, averages the distance, and uses a "Majority Vote" to determine the smoothed trend direction.

LAST SIGNAL 🎯 (Row 7): The "Memory Lock." When your custom Buy/Sell signal actually fires, the dashboard freezes the exact market conditions at that exact second. It allows you to look back at the chart and see precisely why a previous trade was skipped or taken.

🔧 Settings & Configuration Guide
1. Data Sources
Connect the script to your chart data here.

Select Primary Oscillator (Open/Close): Route this to your primary volume, delta, or momentum indicator.

Select Confirmation Line (MA): Route this to your specific baseline or moving average trend indicator.

2. Signal Triggers
The universal checkbox system. Check the boxes (Buy 1, Sell 1, etc.) and link them to your external signal provider. The "LAST SIGNAL" memory lock will stay asleep until one of these inputs triggers.

3. V20 Trap Limits

Max Size (Exhaustion Trap Limit): The absolute maximum oscillator body size allowed before a trade is considered exhausted. (Default: 2.80).

Max Distance (Rubber Band Trap Limit): The maximum distance allowed between your primary oscillator and your confirmation line. (Default: 16.0).

4. UI Settings
Customize the position (Top Right, Bottom Left, etc.) and the text size of the dashboard to fit your screen perfectly.

5. Alert Settings
Instead of alerting you on useless line crosses, the alerts are actionable and tier-based:

Alert on 🔥 SNIPER ENTRY: Pings when a perfect alignment, zero-trap setup appears.

Alert on 🟢 STANDARD ENTRY: Pings when a safe, high-probability trade fires.

Alert on 🚨 TRAP BREACH: Pings when a signal fires but limits are breached (useful for actively monitoring avoided losses).

⚠️ Risk Disclaimer
Please Note: This indicator is intended strictly as an analytical guide and educational tool. It does not constitute financial or investment advice. Trading financial markets carries a high level of inherent risk, and no mathematical filter or indicator can guarantee future results or eliminate losses. The risk of trading is entirely your own, and you are solely responsible for your own trading decisions, entries, exits, and risk management. Always manage your capital responsibly.

## Source Code

````pine
//@version=6
indicator("V20 Dashboard (High Volume Sniper Edition)", overlay=true)

// =========================================================================
// 1. DATA INPUTS & SOURCES
// =========================================================================
grp_src = "1. Data Sources"
float cd_open  = input.source(open, title="Select Primary Oscillator (Open)", group=grp_src)
float cd_close = input.source(close, title="Select Primary Oscillator (Close)", group=grp_src)
float conf_src = input.source(close, title="Select Confirmation Line (MA)", group=grp_src)

// =========================================================================
// 2. SIGNAL TRIGGERS (UNIVERSAL CHECKBOX SYSTEM)
// =========================================================================
grp_trig = "2. Signal Triggers"
bool use_b1 = input.bool(false, title="Use Buy 1", group=grp_trig, inline="b1")
float buy_sig1  = input.source(close, title="", group=grp_trig, inline="b1")

bool use_b2 = input.bool(false, title="Use Buy 2", group=grp_trig, inline="b2")
float buy_sig2  = input.source(close, title="", group=grp_trig, inline="b2")

bool use_s1 = input.bool(false, title="Use Sell 1", group=grp_trig, inline="s1")
float sell_sig1 = input.source(close, title="", group=grp_trig, inline="s1")

bool use_s2 = input.bool(false, title="Use Sell 2", group=grp_trig, inline="s2")
float sell_sig2 = input.source(close, title="", group=grp_trig, inline="s2")

// =========================================================================
// 3. V20 LIMITS & UI SETTINGS
// =========================================================================
grp_caps = "3. V20 Trap Limits"
float size_cap = input.float(2.80, title="Max Size (Exhaustion Trap Limit)", group=grp_caps)
float dist_cap = input.float(16.0, title="Max Distance (Rubber Band Trap Limit)", group=grp_caps)

grp_ui = "4. UI Settings"
string pos_input  = input.string("Bottom Right", title="Position", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left", "Middle Right"], group=grp_ui)
string size_input = input.string("Small", title="Text Size", options=["Tiny", "Small", "Normal"], group=grp_ui)

dash_pos = pos_input == "Top Right" ? position.top_right : pos_input == "Bottom Right" ? position.bottom_right : pos_input == "Bottom Left" ? position.bottom_left : pos_input == "Top Left" ? position.top_left : position.middle_right
txt_size = size_input == "Tiny" ? size.tiny : size_input == "Small" ? size.small : size.normal

color bg_table = color.rgb(0, 0, 0, 0)
color bg_cell  = color.rgb(18, 18, 18, 0) 
color bg_base  = color.rgb(28, 28, 28, 0) 
color bg_head  = color.rgb(31, 73, 125, 0)

// =========================================================================
// 4. TRAP FILTERS & ZERO-TRAP MATH
// =========================================================================
cd_body = (cd_close - cd_open) * 10000
current_size = math.abs(cd_body)
current_dist = math.abs(cd_close - conf_src) * 10000

is_cd_bull = cd_body > 0
is_cd_bear = cd_body < 0

// Trap Limits
is_exhausted    = current_size > size_cap
is_overextended = current_dist > dist_cap
is_fakeout      = is_exhausted or is_overextended

// Signal Evaluation (With Edge Detection to prevent Alert Spam)
buy_raw  = (use_b1 and not na(buy_sig1) and buy_sig1 != 0) or (use_b2 and not na(buy_sig2) and buy_sig2 != 0)
sell_raw = (use_s1 and not na(sell_sig1) and sell_sig1 != 0) or (use_s2 and not na(sell_sig2) and sell_sig2 != 0)

is_buy_active  = buy_raw and not buy_raw[1]
is_sell_active = sell_raw and not sell_raw[1]
signal_firing  = is_buy_active or is_sell_active

// ZERO-TRAP STATE
is_zero_trap_state = (is_buy_active and is_cd_bull) or (is_sell_active and is_cd_bear)

// --- NEW MATH: 1-BAR AGO STATUS ---
is_fakeout_1 = is_fakeout[1]
is_cd_bull_1 = is_cd_bull[1]
is_zero_trap_state_1 = is_zero_trap_state[1]

// --- NEW MATH: 5-BAR AVERAGE STATUS ---
avg_size_5 = (current_size + nz(current_size[1]) + nz(current_size[2]) + nz(current_size[3]) + nz(current_size[4])) / 5
avg_dist_5 = (current_dist + nz(current_dist[1]) + nz(current_dist[2]) + nz(current_dist[3]) + nz(current_dist[4])) / 5

// Majority vote for direction over the last 5 bars
bull_count = (is_cd_bull ? 1 : 0) + nz(is_cd_bull[1] ? 1 : 0) + nz(is_cd_bull[2] ? 1 : 0) + nz(is_cd_bull[3] ? 1 : 0) + nz(is_cd_bull[4] ? 1 : 0)
is_avg_bull = bull_count >= 3
is_avg_bear = not is_avg_bull

is_avg_fakeout = (avg_size_5 > size_cap) or (avg_dist_5 > dist_cap)
is_avg_zero_trap = (is_buy_active and is_avg_bull) or (is_sell_active and is_avg_bear)

// =========================================================================
// 5. UNIVERSAL SIGNAL MEMORY LOGIC
// =========================================================================
bars_since  = ta.barssince(signal_firing)
mem_dir     = ta.valuewhen(signal_firing, is_buy_active ? 1 : -1, 0)
mem_fakeout = ta.valuewhen(signal_firing, is_fakeout, 0)
mem_zero    = ta.valuewhen(signal_firing, is_zero_trap_state, 0)

// =========================================================================
// 6. THE UI RENDER (RUNS ON LAST BAR ONLY)
// =========================================================================
var table dash = na
if na(dash)
    // 8 rows total
    dash := table.new(dash_pos, 3, 8, border_width=1, border_color=color.rgb(100, 100, 100, 0), bgcolor=bg_table)
    table.merge_cells(dash, 0, 0, 2, 0) 

if barstate.islast
    // Core Limits (Rows 1-3)
    size_col = is_exhausted ? color.red : color.lime
    table.cell(dash, 0, 1, "Live Volume Size:", text_color=color.white, bgcolor=bg_cell, text_halign=text.align_left, text_size=txt_size)
    table.cell(dash, 1, 1, str.tostring(current_size, "#.##"), text_color=size_col, bgcolor=bg_cell, text_halign=text.align_right, text_size=txt_size)
    table.cell(dash, 2, 1, is_exhausted ? "Exhausted (Danger)" : "Safe (Healthy)", text_color=size_col, bgcolor=bg_cell, text_halign=text.align_right, text_size=txt_size)

    dist_col = is_overextended ? color.red : color.lime
    table.cell(dash, 0, 2, "Live Distance:", text_color=color.white, bgcolor=bg_cell, text_halign=text.align_left, text_size=txt_size)
    table.cell(dash, 1, 2, str.tostring(current_dist, "#.##"), text_color=dist_col, bgcolor=bg_cell, text_halign=text.align_right, text_size=txt_size)
    table.cell(dash, 2, 2, is_overextended ? "Overextended (Danger)" : "Safe (Healthy)", text_color=dist_col, bgcolor=bg_cell, text_halign=text.align_right, text_size=txt_size)

    state_col = is_cd_bull ? color.lime : color.red
    table.cell(dash, 0, 3, "Oscillator State:", text_color=color.white, bgcolor=bg_cell, text_halign=text.align_left, text_size=txt_size)
    table.cell(dash, 1, 3, is_cd_bull ? "Bullish" : "Bearish", text_color=state_col, bgcolor=bg_cell, text_halign=text.align_right, text_size=txt_size)
    table.cell(dash, 2, 3, "Master Key", text_color=color.gray, bgcolor=bg_cell, text_halign=text.align_right, text_size=txt_size)

    // Header Setup
    table.cell(dash, 0, 0, "V20 TRADE FILTER", text_color=color.white, bgcolor=bg_head, text_halign=text.align_center, text_size=txt_size)

    // --- ROW 4: LIVE STATE ---
    live_dir_str = is_cd_bull ? "BUY" : "SELL"
    live_dir_bg = is_cd_bull ? color.rgb(0, 255, 0, 0) : color.rgb(255, 0, 0, 0) 
    live_prob_str = is_fakeout ? "🚨 TRAP LIMIT BREACHED (SKIP)" : is_zero_trap_state ? "🔥 SNIPER ENTRY (ZERO TRAPS)" : "🟢 STANDARD ENTRY (SAFE)"
    live_prob_bg = is_fakeout ? color.rgb(80, 80, 80, 0) : is_zero_trap_state ? color.rgb(255, 69, 0, 0) : color.rgb(0, 128, 128, 0)
    
    table.cell(dash, 0, 4, "LIVE ⚡", text_color=color.white, bgcolor=bg_head, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 1, 4, live_dir_str, text_color=color.white, bgcolor=live_dir_bg, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 2, 4, live_prob_str, text_color=color.white, bgcolor=live_prob_bg, text_halign=text.align_center, text_size=txt_size)

    // --- ROW 5: 1-BAR AGO STATUS ---
    dir_str_1 = is_cd_bull_1 ? "BUY" : "SELL"
    dir_bg_1 = is_cd_bull_1 ? color.rgb(0, 255, 0, 0) : color.rgb(255, 0, 0, 0) 
    prob_str_1 = is_fakeout_1 ? "🚨 TRAP LIMIT BREACHED (SKIP)" : is_zero_trap_state_1 ? "🔥 SNIPER ENTRY (ZERO TRAPS)" : "🟢 STANDARD ENTRY (SAFE)"
    prob_bg_1 = is_fakeout_1 ? color.rgb(80, 80, 80, 0) : is_zero_trap_state_1 ? color.rgb(255, 69, 0, 0) : color.rgb(0, 128, 128, 0)

    table.cell(dash, 0, 5, "1-BAR AGO ⏪", text_color=color.white, bgcolor=bg_head, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 1, 5, dir_str_1, text_color=color.white, bgcolor=dir_bg_1, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 2, 5, prob_str_1, text_color=color.white, bgcolor=prob_bg_1, text_halign=text.align_center, text_size=txt_size)

    // --- ROW 6: 5-BAR AVG STATUS ---
    dir_str_5 = is_avg_bull ? "BUY" : "SELL"
    dir_bg_5 = is_avg_bull ? color.rgb(0, 255, 0, 0) : color.rgb(255, 0, 0, 0) 
    prob_str_5 = is_avg_fakeout ? "🚨 TRAP LIMIT BREACHED (SKIP)" : is_avg_zero_trap ? "🔥 SNIPER ENTRY (ZERO TRAPS)" : "🟢 STANDARD ENTRY (SAFE)"
    prob_bg_5 = is_avg_fakeout ? color.rgb(80, 80, 80, 0) : is_avg_zero_trap ? color.rgb(255, 69, 0, 0) : color.rgb(0, 128, 128, 0)

    table.cell(dash, 0, 6, "5-BAR AVG 📊", text_color=color.white, bgcolor=bg_head, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 1, 6, dir_str_5, text_color=color.white, bgcolor=dir_bg_5, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 2, 6, prob_str_5, text_color=color.white, bgcolor=prob_bg_5, text_halign=text.align_center, text_size=txt_size)

    // --- ROW 7: LOCKED SIGNAL MEMORY ---
    string lock_dir_str = "-"
    color lock_dir_bg = color.rgb(40, 40, 40, 0)
    string lock_prob_str = "WAITING FOR SIGNAL..."
    color lock_prob_bg = color.rgb(40, 40, 40, 0)
    string display_prob = "WAITING..."

    if not na(bars_since)
        is_mem_bull = mem_dir == 1
        lock_dir_str := is_mem_bull ? "BUY" : "SELL"
        lock_dir_bg := is_mem_bull ? color.rgb(0, 255, 0, 0) : color.rgb(255, 0, 0, 0)
        lock_prob_str := mem_fakeout ? "🚨 TRAP LIMIT BREACHED (SKIPPED)" : mem_zero ? "🔥 SNIPER ENTRY (TAKEN)" : "🟢 STANDARD ENTRY (TAKEN)"
        lock_prob_bg := mem_fakeout ? color.rgb(80, 80, 80, 0) : mem_zero ? color.rgb(255, 69, 0, 0) : color.rgb(0, 128, 128, 0)
        display_prob := lock_prob_str + " (" + str.tostring(bars_since) + " Bars Ago)"

    table.cell(dash, 0, 7, "LAST SIGNAL 🎯", text_color=color.white, bgcolor=bg_head, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 1, 7, lock_dir_str, text_color=color.white, bgcolor=lock_dir_bg, text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 2, 7, display_prob, text_color=color.white, bgcolor=lock_prob_bg, text_halign=text.align_center, text_size=txt_size)

// =========================================================================
// 7. DYNAMIC ALERTS (ACTION-BASED TOGGLES)
// =========================================================================
grp_alerts = "5. Alert Settings"
bool alert_fire = input.bool(true,  title="Alert on 🔥 SNIPER ENTRY", group=grp_alerts)
bool alert_safe = input.bool(true,  title="Alert on 🟢 STANDARD ENTRY", group=grp_alerts)
bool alert_trap = input.bool(false, title="Alert on 🚨 TRAP BREACH (Skipped Trades)", group=grp_alerts)

if signal_firing
    bool is_tier_trap = is_fakeout
    bool is_tier_fire = not is_fakeout and is_zero_trap_state
    bool is_tier_safe = not is_fakeout and not is_zero_trap_state

    bool trigger_alert = (is_tier_trap and alert_trap) or (is_tier_safe and alert_safe) or (is_tier_fire and alert_fire)

    if trigger_alert
        string alert_dir  = is_buy_active ? "BUY" : "SELL"
        string alert_tier = is_tier_trap ? "TRAP 🚨 (SKIP)" : is_tier_fire ? "SNIPER 🔥 (TAKE IT)" : "STANDARD 🟢 (TAKE IT)"
        
        string msg = "V20 " + alert_dir + " | " + alert_tier + " | Size: " + str.tostring(current_size, "#.##") + " | Dist: " + str.tostring(current_dist, "#.##")
        alert(msg, alert.freq_once_per_bar_close)
````
