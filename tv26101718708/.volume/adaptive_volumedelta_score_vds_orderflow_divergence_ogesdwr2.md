# Adaptive Volume-Delta Score (VDS) | Order-Flow & Divergence

- url: https://www.tradingview.com/script/oGESdwR2/
- type: indicator
- pine_id: PUB;abdc2feb28e44caa99effaa383c7dd4d
- version: 2.0

## Description

The Adaptive Volume-Delta Score (VDS) is a technical analysis tool for the statistical classification of volume-delta activity. It utilizes an Adaptive-Switch Logic that toggles between historical bar reconstruction (request.security_lower_tf) and a real-time Rolling-Window Live-Tracker.

🛠 Core Functionality
1. The VDS Engine (Statistical Mapping)

    Wick-Weighted Delta: The calculation is based on wick-weighting: (close-open)/range * volume. This weights the delta according to price displacement within the bar.

Symmetrical Mapping (-4.5 to 4.5): Raw values are statistically categorized via ta.percentrank and mapped onto a fixed scale.

    +4.5 (100% Rank): The absolute maximum within the chosen lookback period.
    +2.25 (75% Rank): Significant activity relative to the period.
    0 (Median): The statistical midpoint (50% Rank).
    -4.5 (0% Rank / Min.): The absolute floor of activity for the period.

Visualization Logic: This mapping is primarily used to plot volume activity and delta aggression within the same visual space, providing a consistent reference frame for comparing relative dominance.
Context Dependency: Signals are not absolute recommendations. The significance depends heavily on the Lookback Period, Thresholds, and the specific market environment.

2. Adaptive Logic & Data Integrity

    Signal-Bridge: On lower timeframes (LTF), the indicator simulates the behavior of the Main Timeframe (Main-TF) using a rolling window. This allows for the observation of delta development while the bar is still forming.

🛡️ Integrity Dashboard: Visualizes the statistical consistency between live data and the historical baseline. Deviations (e.g., due to Pine Script's 5000-bar limit) are displayed transparently as warnings.

3. Dynamic Alert System

    Automation: Alerts utilize the alert() function with the "Any function call" setting.
    Intelligence: Messages are fully dynamic, reporting the mode (Live vs. History), signal type, safeguard status, and data integrity.

🚀 Quick Calibration Guide

    Sensitivity: A longer Lookback Period stabilizes the statistics; a shorter period makes the score more reactive to short-term volume spikes.

Threshold Setup: Calibrate the Dominance Threshold (default 3.0) to isolate extreme aggression. Use the Volume Threshold to ensure a minimum level of market participation.
Visual Match: Activate the Price Chart Overlays and adjust your thresholds until the markers (Diamonds) correspond with your individual market interpretation.
Dashboard Check: Monitor the Confidence Score. If red warning values appear, consider adjusting your Lookback or Timeframe to maintain a stable statistical foundation.

🎨 Visual Guide: Understanding the Scale

    Navy/Blue Columns: Standard activity within the selected statistical window.
    Gray Columns: Phases below the Low Volume Threshold, indicating low relative market participation.
    Lime/Fuchsia (Dominance): Occurs when volume and delta simultaneously exceed the defined thresholds (Aggression).
    Olive/Maroon (Divergence): Period delta is positive/negative while price action is opposite (Decoupling/Absorption).
    Diamonds: Optional projection of oscillator signals directly onto the candles in the price chart.

⚠️ Important Technical Notifications

    The "Signal Bridge" (Rolling vs. Fixed Window):
        HTF-Request Mode (Fixed): Measures delta starting from the candle open (e.g., 12:00 PM).
        Live-Transfer Mode (Rolling): Analyzes a sliding window (e.g., the last 120 minutes). This provides a Lead-Time Advantage, detecting aggression as it happens regardless of the HTF clock. Both modes converge at the HTF bar close.

Data Integrity & Anomalies:

    Session Gaps: High Main-TFs (like D1) can be affected by irregular session hours (e.g., Forex Sunday). Always monitor the Confidence Score (🛡️).

Replay Mode:

    Displays "No Stat. Control" if historical LTF data is unavailable. We prioritize data honesty over estimated data.

🔔 How to set Alerts (Smart Signals)

    Preparation: Open the VDS settings. Under "Alert Settings", choose which signals should trigger: Dominance, Divergence, or both.
    Condition: Select "Adaptive Volume-Delta Score...".
    Trigger Logic: Change setting to "Any alert() function call".
    Frequency: Managed by the script (once_per_bar_close) to ensure statistical honesty.
    Timeframe Choice: Use the Main-TF for final confirmed signals, or a Lower-Timeframe for Live-Tracker early warnings.

📊 Statistical Transparency (Data Window)
Raw metrics are displayed exclusively in the TradingView Data Window to keep the chart clean:

    Runtime-Safe LTF: The analysis interval currently in use.
    Max Safe Lookback: The mathematical limit for your current setup (5,000-bar ceiling).
    Active Bar Limit: The actual usable data foundation.
    Converted Sum of LTF Request Bars: The historical baseline used as an anchor for the Live-Tracker.
    Relative Live-Data Size: Numerical basis of the Confidence Score (100% = Perfect Integrity).
    Overall Requested Bars: Total data points analyzed within your Lookback Period.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © arnipoer


//@version=6
// @description Pct-Ranked Intra-Bar Volume Delta with adaptive Lower Timeframe Tracking.
//  Part of the [Adaptive Suite] | [IAI Link](https://tradingview.com/script/OjktEsmn/) | Profile: [arnipoer](https://tradingview.com/u/arnipoer/)

// --- VDS ENGINE UPDATE v1.1 ---
// Optimized for linear aggression scaling.
// Original volume-weighting is kept as a comment for documentation purposes.

indicator(title="Adaptive Volume-Delta Score (VDS) | Order-Flow & Divergence", shorttitle="VDS", overlay=false, dynamic_requests=true)

LongCandle(bool is_ltf_view, int current_chart_ratio) =>
    is_ltf_view ?  open[current_chart_ratio] < close : open < close
ShortCandle(bool is_ltf_view, int current_chart_ratio) =>
    is_ltf_view ? open[current_chart_ratio] >= close : open >= close
    

// --- BASIC SETTINGS ---
tf_main = input.timeframe('120', title = 'Main Timeframe', group = 'BASIC SETTINGS', 
     tooltip = 'The reference timeframe for trend and activity analysis. The script reconstructs historical data based on this period using a lower_tf_request.')

tf_lookback = input.int(50, maxval = 4900, title = 'Lookback Period', group = 'BASIC SETTINGS', 
     tooltip = 'Number of bars used for the PercentRank calculation. Higher values create more stable, long-term statistical averages.')

ltf = input.timeframe('10', title = 'Lower Timeframe', group = 'BASIC SETTINGS', 
     tooltip = 'The sub-interval used for the lower_tf_request. \n\nNote: If this value is larger than your current chart, the script automatically switches to the chart timeframe to prevent errors. Check "Runtime-Safe LTF" in the Data Window for the active setting.')

lt_deviation_tresh = input.float(15.0, step=0.5, title = '% Warning-Treshold for LiveTracker Deviation', group = 'BASIC SETTINGS', 
     tooltip = 'Defines the tolerance for the "Relative Live-Data Size". If the deviation between the live stream and the actual lower_tf_request baseline exceeds this percentage, the dashboard turns red to warn about potential data inconsistency.')


/// --- THRESHOLDS (Lookback-weighted Scoring) ---
volume_delta_Tresh = input.float(3.0, step=0.1, title = 'Dominance Threshold', group = 'Thresholds', 
     tooltip = 'Relative Dominance intensity. This maps the statistical PercentRank (0-100%) to our scale (0 to 4.5). 4.5 represents the period high, 0 is the median. Adjust this to isolate top-tier aggression events (e.g., 3.0 targets the top ~83%).')

VolumeTresh = input.float(0.0, step=0.1, title = 'High Volume Threshold', group = 'Thresholds', 
     tooltip = 'Minimum score for high volume engagement. Maps PercentRank to our scale: 4.5 is the period high, 0 the median. Ensures that signals only trigger when institutional interest is significantly above the historical average.')

low_VolumeTresh = input.float(-2.0, step=0.1, title = 'Low Volume Threshold', group = 'Thresholds', 
     tooltip = "Score for 'Dry Volume' phases. Maps PercentRank to our scale: -4.5 represents the period low, 0 the median. Use this to identify and gray-out phases with a lack of institutional interest (Gray Bars).")////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


calc_ib_metrics(string tf_main, string ltf, int lookback) =>
    // Max possible intra-bars based on user input
    int max_intrabars = timeframe.in_seconds(tf_main) / timeframe.in_seconds(ltf)
    
    // Safety Fallback: Prevents runtime errors by ensuring LTF is not larger than the current chart
    active_ltf = timeframe.in_seconds(ltf) <= timeframe.in_seconds() ? ltf : timeframe.period
    
    // The actually used ratio to prevent execution errors and maintain stability
    int max_intrabars_active = timeframe.in_seconds(tf_main) / timeframe.in_seconds(active_ltf)

    float pct_req_volume = ta.percentrank(volume, lookback)
    
    // Mapping percentile to -4.5 to +4.5 equivalent score    
    float scored_req_volume = 0.09 * pct_req_volume - 4.5
    pct_req_volume_wight = 0.01 * pct_req_volume // Use volume as weight, transform percentile into values (0 to 1)

    // --- Wick-Weighted Delta calculation --- 
    float _range = math.max(high - low, syminfo.mintick)
    float volume_delta = (nz((close - open) / (_range) * volume, 0)) // Dojis result in low volume delta
    
    //-------------------------------------- IB-REQUEST LOGIC (History) -----------------------------------------//
    // Batched data requests for historical intra-bar reconstruction
    arr_ltf_delta = request.security_lower_tf(syminfo.tickerid, active_ltf, volume_delta)

    int ib_request_sample_size = array.size(arr_ltf_delta) // Current number of LTF candles within the MainTF bar

    // Aggregate request data (Totals)
    float ib_request_volDelta_total = array.size(arr_ltf_delta) > 0 ? array.sum(arr_ltf_delta) : volume_delta

    // 1. Calculate absolute aggression magnitude
    float abs_ib_request_volDelta_total = math.abs(ib_request_volDelta_total)
    
    // 2. Rank magnitude against all historical aggression events (Long & Short)
    float pct_abs_req_volDelta = ta.percentrank(abs_ib_request_volDelta_total, lookback)
    
    // 3. Transformation & Directional mapping
    // Retaining the original sign to determine direction
    float direction = math.sign(ib_request_volDelta_total)
    
    // 4. Final weighted score (Mapping to -4.5 to +4.5 around zero)
    // Scaling percentile (0-100) to (0 to 4.5), then multiplying by direction and volume weight
    // OPTION: Multiplier * pct_req_volume_wight removed in v1.1 for better lead-time.
    float scored_req_volDelta = (0.045 * pct_abs_req_volDelta) * direction //* pct_req_volume_wight
    
   
    //-------------------------------------- LIVE-TRANSFER LOGIC (Real-Time Bridge) -----------------------------//
    // Determine how many chart bars represent one main bar interval
    int current_chart_ratio = (timeframe.in_seconds(tf_main) >= timeframe.in_seconds(timeframe.period)) ? 
         int(math.min((timeframe.in_seconds(tf_main) / timeframe.in_seconds(timeframe.period)), 4900)) : 1

    // Adjust lookback to maintain statistical consistency across different data densities
    int safe_lookback = math.min(lookback * current_chart_ratio, 4900)

    float live_volume_total = nz(math.sum(volume, current_chart_ratio), 0)
    float pct_live_volume = ta.percentrank(live_volume_total, safe_lookback)
    
    // Mapping percentile to -4.5 to +4.5 equivalent score
    float scr_live_volume = 0.09 * pct_live_volume - 4.5 
    live_volume_wight = 0.01 * pct_live_volume // Use volume as weight, transform percentile into values (0 to 1) 

    // Aggregate live delta_volume (Totals)
    float live_volume_delta_total = math.sum(volume_delta, current_chart_ratio)
    
    // 1. Calculate absolute aggression magnitude for live data
    float abs_live_volume_delta_total = math.abs(live_volume_delta_total)
    
    // 2. Rank magnitude against the period
    float pct_abs_live_volume_delta = ta.percentrank(abs_live_volume_delta_total, lookback)
    
    // 3. Transformation & Directional mapping
    float direction_live = math.sign(live_volume_delta_total)
    
    // 4. Final weighted live score (Mapping to -4.5 to +4.5 around zero)
    // OPTION: Multiplier * live_volume_wight removed in v1.1 for better lead-time.
    float scr_live_volume_delta = (0.045 * pct_abs_live_volume_delta) * direction_live //* live_volume_wight 

    [scr_live_volume_delta, scr_live_volume, scored_req_volDelta, scored_req_volume,
         current_chart_ratio, max_intrabars, active_ltf, max_intrabars_active, ib_request_sample_size[1]] // why ib_request_sample_size[1]? : To validate Live-Tracker values, we retrieve the number of LTF data points from the last closed HTF bar. [1]
      
// --- Function Call and Variable Assignment ---
[live_volume_delta, live_volume, req_volume_delta, req_volume, current_chart_ratio, max_intrabars, act_ltf, act_intrabars_active, req_sample_size] 
     = calc_ib_metrics(tf_main, ltf, tf_lookback)

   
get_ib_sample_stats() => // This function monitors the "reconstructed intra-bar baseline" by archiving the exact number of LTF samples per Main-TF bar. 
    [_, _, _, _, _, _, _, _, req_size_current] = calc_ib_metrics(tf_main, ltf, tf_lookback)
    
    // Buffer to store individual samples from each main bar
    var int[] ib_sample_buffer = array.new_int(0)
    array.push(ib_sample_buffer, req_size_current)
    
    // Maintain buffer size according to the lookback period
    if array.size(ib_sample_buffer) > tf_lookback
        array.remove(ib_sample_buffer, 0)
    
    // Total sum of all intra-bars within the lookback period
    int ib_sum_lookback = array.sum(ib_sample_buffer)
    
    [req_size_current, ib_sum_lookback]

// Executing this as a HTF-request ensures that the statistical sample pool is built on the stable Main-TF timeline, which is essential for a valid Confidence Score.
[last_ib_number, ib_sum_lookback] = request.security(syminfo.tickerid, tf_main, get_ib_sample_stats())

// --- DATA INTEGRITY ANALYSIS ---
float theoretical_bar_count = current_chart_ratio * tf_lookback                // 1. Theoretical sample goal based on lookback and ratio
float max_safe_lookback = 4900.0 / current_chart_ratio                // 2. Calculate the 'Blind Spot': At which lookback does the chart exceed the 5000 bar limit?

bool is_data_clipped = tf_lookback > max_safe_lookback                // 3. Status check: Is the requested lookback technically possible on this timeframe?

float active_bar_limit = math.min(theoretical_bar_count, 4900)              // 4. Active technical limit (Pine Script's hard 5000 bar ceiling)
float convert_ib_sum_lb = ib_sum_lookback * (current_chart_ratio / max_intrabars)      // 5. Converting ib_sum_lookback into current chart units for direct comparison
float livetracker_dev_pct = (active_bar_limit / convert_ib_sum_lb) * 100        // 6. Confidence Check: Calculate deviation between Live-Tracker and IB-Request data basis

bool live_data_warning = livetracker_dev_pct > 100 + lt_deviation_tresh or livetracker_dev_pct < 100 - lt_deviation_tresh

// --- STATISTICAL TRANSPARENCY (Data Window) ---
plot(timeframe.in_seconds(act_ltf) / 60, title = "Runtime-Safe LTF", color = ltf == act_ltf ? color.green : color.red, display = display.data_window, precision = 0)
plot(max_safe_lookback, title = "Max Safe Lookback for this TF", display = display.data_window)
plot(theoretical_bar_count, title = "Max. Possible Intrabars", display = display.data_window, precision = 0)
plot(active_bar_limit, title = "Active Bar Limit (Max 4900)", display = display.data_window, precision = 0, color = is_data_clipped ? color.red : color.green)
plot(convert_ib_sum_lb, title = "Converted Sum of LTF Request Bars", display = display.data_window, precision = 0)
plot(livetracker_dev_pct, title = "Relative Live-Data Size", display = display.data_window, precision = 0, color = live_data_warning ? color.red : color.green)
plot(ib_sum_lookback, title = "Overall Requested Bars", display = display.data_window, precision = 0)
plot(ib_sum_lookback / tf_lookback, title = "Avg Requested Intrabars", display = display.data_window, precision = 2)
plot(last_ib_number, title = "Last Requested Intrabars", display = display.data_window, precision = 2)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     --- ADAPTIVE OBSERVATION LOGIC ---                                          //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var float observed_volume_delta    = na , var float observed_volume  = na

// Check if we are viewing a timeframe smaller than the main analysis timeframe
is_ltf_view = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(tf_main)

if not is_ltf_view 
    // Context: HTF Chart (e.g., H2) -> Use reconstructed Intra-Bar Request data
    observed_volume_delta   := req_volume_delta, observed_volume := req_volume
else
    // Context: LTF Chart (e.g., M10) -> Use the Live-Transfer (Bridge) to simulate HTF behavior
    observed_volume_delta  := live_volume_delta, observed_volume := live_volume


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            --- SIGNAL ENGINE ---                                                //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Core threshold evaluations
bool is_high_volume   = observed_volume > VolumeTresh
bool is_low_volume    = observed_volume < low_VolumeTresh

// Delta Volume Signals - Basic Direction & Thresholds
bool bull_volume_delta = observed_volume_delta > volume_delta_Tresh
bool bear_volume_delta = observed_volume_delta < -1 * volume_delta_Tresh
bool bulls_advantage   = observed_volume_delta > 0
bool bears_advantage   = observed_volume_delta < 0

// 1. Dominance: High Volume + High Aggression (The "Push")
bool sig_bull_volume_delta = is_high_volume and bull_volume_delta
bool sig_bear_volume_delta = is_high_volume and bear_volume_delta

// 2. Trap-Divergence (Delta-Price Decoupling):
// Olive: Positive Delta accumulation occurs while price action remains bearish for the observed window.
bool bull_delta_div = is_high_volume and bulls_advantage and ShortCandle(is_ltf_view, current_chart_ratio)

// Maroon: Negative Delta accumulation occurs while price action remains bullish for the observed window.
bool bear_delta_div = is_high_volume and bears_advantage and LongCandle(is_ltf_view, current_chart_ratio)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            --- VISUALIZATION ---                                                //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// --- VISUALIZATION: OSCILLATOR ---

color vol_color = (not is_low_volume) ? color.new(color.navy, is_high_volume ? 10 : 50) : color.new(color.gray, 70)

// Volume Bars (Background)
plot(observed_volume, title='Volume Percentile', style=plot.style_columns, histbase=-4.5,
     color=vol_color, linewidth=2)

// --- Volume Delta Color Logic ---
color volume_deltaColor = color.gray 
volume_deltaColor := switch
    is_low_volume         => color.new(color.gray, 100) 
    sig_bull_volume_delta => color.lime                
    sig_bear_volume_delta => color.fuchsia           
    bull_delta_div        => color.olive               
    bear_delta_div        => color.maroon
    bulls_advantage       => color.new(color.green, is_high_volume ? 0 : 50)
    bears_advantage       => color.new(color.red, is_high_volume ? 0 : 50)
    => color.gray

// Volume Delta Bars
plot(observed_volume_delta, title = 'Observed Volume Delta', color = volume_deltaColor, style = plot.style_columns, linewidth = 2)

// --- LEVEL REFERENCES (Percentile Scale) ---
hline(0, title = 'Delta_Baseline', color = color.new(color.white, 50), linestyle = hline.style_dashed)
hline(4.5, title = 'Maximum', color = color.white, linewidth = 1)
hline(-4.5, title = 'Minimum', color = color.white, linewidth = 1)
hline(VolumeTresh, title = 'Volume Threshold', color = color.purple, linestyle = hline.style_dashed)
hline(volume_delta_Tresh,   title = 'Sig Bull Delta Threshold', color = color.lime, linestyle = hline.style_dashed)
hline(volume_delta_Tresh * -1,   title = 'Sig Bear Delta Threshold', color = color.fuchsia, linestyle = hline.style_dashed)

// Dynamic separator for Main-Timeframe boundaries
if timeframe.change(tf_main) and not (timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds(tf_main))
    line.new(bar_index, -4.5, bar_index, 4.5, color=color.new(color.white, 0), style=line.style_dotted)


// --- PRICE CHART OVERLAYS ---
string G_VIS = "Visual Settings - Price Chart"

show_divergence = input.bool(false, "Show Divergence Signals", group=G_VIS, 
     tooltip="Displays diamond shapes when volume-delta and price action decouple (e.g., bullish delta in a bearish candle/window).")

show_delta_sig = input.bool(false, "Show Dominance Signals", group=G_VIS, 
     tooltip="Displays diamond shapes when volume and delta aggression exceed the defined dominance thresholds.")

// Divergence Diamonds 
plotshape(show_divergence and bull_delta_div, title = 'Bullish Divergence', color = color.olive, style = shape.diamond, size = size.tiny, location = location.belowbar, force_overlay = true)
plotshape(show_divergence and bear_delta_div, title = 'Bearish Divergence', color = color.maroon, style = shape.diamond, size = size.tiny, location = location.abovebar, force_overlay = true)

// Dominance Diamonds
plotshape(show_delta_sig and sig_bull_volume_delta, title = 'Bulls Dominance', color = color.lime, style = shape.diamond, size = size.tiny, location = location.belowbar, force_overlay = true)
plotshape(show_delta_sig and sig_bear_volume_delta, title = 'Bears Dominance', color = color.fuchsia, style = shape.diamond, size = size.tiny, location = location.abovebar, force_overlay = true)


// --- STATUS DASHBOARD ---
printStatusDashboard(string position, bool is_ltf_mode) =>
    // Create a 1-column table with 4 rows for status and integrity metrics
    var table status_tab = table.new(position, 1, 4, border_color = color.silver, border_width = 1)
    
    // Row 0: Operation Mode (IB-REQUEST vs. LIVE-TRANSFER) 
    bool is_safeguard_active = ltf != act_ltf
    string safeguard_info = is_safeguard_active ? " ⚠️ (Safe-TF: M" + str.tostring(timeframe.in_seconds(act_ltf)/60, "#") + ")" : ""

    string mode_label = not is_ltf_mode ? 
     "IB-REQUEST (M" + str.tostring(timeframe.in_seconds(tf_main)/ 60, "#") +")" : 
     "LIVE-TRANSFER (M" + str.tostring(timeframe.in_seconds(timeframe.period)/ 60, "#") + ")" + safeguard_info

    color mode_bg = not is_ltf_mode ? color.aqua : (is_safeguard_active ? color.red : color.orange)

    table.cell(status_tab, 0, 0, text = mode_label, bgcolor = mode_bg, text_color = color.white, text_size = size.small)
    
    // Row 1: Data Density & Clipping Status
    string density_text = not is_ltf_mode ? "IB Bars - avg: " + str.tostring(ib_sum_lookback/tf_lookback,"#.0") + " / max: " + str.tostring(max_intrabars) : 
         not is_data_clipped ? "active bars off curr.tf: " + str.tostring(int(active_bar_limit)) : "curr.act.tf_bars ltd. to " + str.tostring(int(active_bar_limit)) + "!"
    color density_bg = not is_ltf_mode ? color.aqua : not is_data_clipped ? color.orange : color.red
    table.cell(status_tab, 0, 1, text = density_text, bgcolor = density_bg, text_color = color.white, text_size = size.small)

    // Row 2 & 3: Integrity & Confidence 
    if is_ltf_mode
        bool has_baseline = not na(convert_ib_sum_lb) and convert_ib_sum_lb > 0
        
        // Row 2: Baseline Check
        string equiv_text = has_baseline ? "convert. sum of req.intrabars: " + str.tostring(int(convert_ib_sum_lb)) : "ltf_request na for this part of replayed hist."
        color equiv_bg    = not has_baseline ? color.gray : (live_data_warning ? color.red : color.orange)
        table.cell(status_tab, 0, 2, text = equiv_text, bgcolor = equiv_bg, text_color = color.white, text_size = size.small)
        
     // Row 3: Confidence Check 
        string integrity_symbol = (livetracker_dev_pct >= 100 - lt_deviation_tresh) ? "🛡️ " : "⚠️ "
        string conf_text  = has_baseline ? integrity_symbol + "Data Integrity: " + str.tostring(livetracker_dev_pct, "#.0") + "%" : "No Stat.Control (Replay Gap)"
        color conf_bg     = not has_baseline ? color.blue : (live_data_warning ? color.maroon : color.green)
        table.cell(status_tab, 0, 3, text = conf_text, bgcolor = conf_bg, text_color = color.white, text_size = size.small)
    else
        table.cell(status_tab, 0, 2, text = "", bgcolor = na)
        table.cell(status_tab, 0, 3, text = "", bgcolor = na)
// --- EXECUTE DASHBOARD ---
if barstate.islast
    printStatusDashboard(position.middle_left, is_ltf_view)

/// --- DYNAMIC SIGNAL ALERTS ---
string G_Alert = "Alert Settings"

alert_dom = input.bool(true, "Alert on Dominance (Lime/Fuchsia)", group=G_Alert, 
     tooltip="Enables alerts for high-aggression signals where volume and delta exceed dominance thresholds.")

alert_div = input.bool(true, "Alert on Divergence (Olive/Maroon)", group=G_Alert, 
     tooltip="Enables alerts for decoupling signals where volume-delta diverges from price action.")

/// Check if the current signal is enabled for alerts by the user
bool is_dom_signal = (sig_bull_volume_delta or sig_bear_volume_delta) and alert_dom
bool is_div_signal = (bull_delta_div or bear_delta_div) and alert_div

if is_dom_signal or is_div_signal
    // 1. Safeguard & Integrity Status
    bool is_safeguard_active = ltf != act_ltf
    string safe_info = is_safeguard_active ? " [SAFEGUARD M" + str.tostring(timeframe.in_seconds(act_ltf)/60, "#") + "]" : ""
    string alert_mode = is_ltf_view ? "LIVE-TRANSFER" : "IB-REQUEST"
    string integrity_info = is_ltf_view and live_data_warning ? " (Low Integrity!)" : " (Verified)"

    // 2. Signal Type Identification
    string signal_type = sig_bull_volume_delta ? "BULL DOMINANCE (Lime)" :
                         sig_bear_volume_delta ? "BEAR DOMINANCE (Fuchsia)" :
                         bull_delta_div        ? "BULL DIVERGENCE (Olive)" :
                         bear_delta_div        ? "BEAR DIVERGENCE (Maroon)" : ""

    // 3. Final Message Assembly
    string alert_msg = "VDS " + alert_mode + safe_info + ": " + signal_type + " on " + syminfo.ticker + " [" + timeframe.period + "]" + integrity_info
    
    alert(alert_msg, alert.freq_once_per_bar_close)
````
