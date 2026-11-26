# Intra-Bar Activity Index (IAI) [Adaptive Volume & Volatility]

- url: https://www.tradingview.com/script/OjktEsmn/
- type: indicator
- pine_id: PUB;2a88e92b68664747b16f16d2ae82d4e9
- version: 2.0

## Description

… is an adaptive percentrank-based analysis of Volume and Volatility (true-range). It dynamically toggles between request.lower_tf-reconstruction and cumulative lower_tf chart data (simulating continual ltf_request).

Core Features: 
1. The Formula for True Activity
The IAI doesn't just measure price action; it calculates the energetic density behind every bar.
    • Volume + Volatility = Activity: You have full control over how these metrics are weighted via individual thresholds. You can set a pure volume signal, a pure volatility signal, or any mix to your liking. Institutional engagement only becomes visible once your calibrated thresholds are breached.
    • Individual Calibration: Through the ltf_request and percentrank, you define your own statistical benchmark and how "exclusive" a signal should be.
2. Adaptive Live-Mode (The Signal Bridge)
The system seamlessly switches to Live-Transfer mode as soon as you zoom into lower timeframes.
    • Early Warning System: The Live-Tracker detects signals while the higher timeframe (HTF) bar is still forming.
    • Hidden Signals: It uncovers activity spikes that would be "smoothed out" if you only looked at the final close of the HTF bar (e.g., H2).
3. Dashboard for Data Integrity (Data Honesty)
We visualize technical limits instead of hiding them.
    • 🛡️ Verified: Live data matches the „historical baseline“.
    • ⚠️ Warning: The Live-Tracker deviates statistically (e.g., due to Pine Script's 4900-bar limit).
    • No Stat. Control: Transparent notification in Replay Mode when no historical reference data is available for your setup.
4. Intelligent Alert System
    • In Live-Mode, you receive alerts as soon as a lower-timeframe interval (e.g., M10) completes with high energy, providing a lead-time advantage over the final HTF bar close
    • Context-Sensitive: The message informs you directly about the current mode (HTF-Request vs. Live-Transfer) and the data status.

🚀 Quick Calibration Tips
    1. Sensitivity: Increase the Lookback Period for more stable, long-term statistics; decrease it for a more reactive, fast-paced Index.
    2. Threshold Setup: Start with 85% for both Volatility and Volume.
    3. The Visual Check: Open the settings menu and activate the Price Chart Dots. Calibrate your Thresholds by observing the position of the dots until they match your market interpretation.
    4. Dashboard Check: Always keep an eye on the Confidence Score. If it drops or turns red, consider adjusting your Timeframe or Lookback to maintain full Data Integrity.

🎨 Visual Guide: How to Read the Index
    • Navy Bars (Normal Engagement): The market is healthy and active, but hasn’t reached "exceptional" levels yet. This represents standard participation.
    • Gray Bars (Low Interest): Market is in a "Dry Volume" phase. Volume is below your Low Volume Threshold. Institutional interest is currently negligible.
    • Silver/Orange Area (Volatility): This background area represents the Volatility Percentile. Even if volume is low, you can instantly see if the price activity (True Range) is expanding.
    • Orange Bars (IAI Active): The "High Energy" phase. These appear only when both Volatility and Volume cross your individual thresholds simultaneously. (The bar height continues to represent the Volume Percentrank).
    • Price Chart Dots (IAI Anchor): Optional orange circles that appear directly on your candles (High/Low). They provide a quick visual link between the oscillator's momentum and the specific price action.


⚠️ Important Technical Notifications

1. The "Signal Bridge" Logic (Rolling vs. Fixed Window)
    • HTF-Request Mode (Fixed Window): On a H2 chart, the index measures activity starting from the candle open (e.g., 12:00 PM). At 12:40 PM, the calculation only includes the first 40 minutes of data. It grows as the bar progresses.
    • Live-Transfer Mode (Rolling Window): On a M10 chart, the IAI simulates the H2 energy by always analyzing the last 120 minutes. At 12:40 PM, it processes the window from 10:40 AM to 12:40 PM.
    • Early Detection: This provides a significant lead-time advantage. You detect institutional spikes as they happen, regardless of the official HTF clock. Both modes converge at the close of the H2 candle (e.g., at 02:00 PM).
2. Data Integrity & Timeframe Anomalies
The 5000-bar limit is not the only factor for "Data Honesty".
    • Session Gaps: Using D1 as the Main-TF can be tricky in Forex markets, where Sunday sessions often only last a few hours. Such irregularities can cause statistical shifts depending on your Lookback Period.
    • Action: Always monitor the Confidence Score (🛡️). If it drops, consider adjusting your Timeframe or Lookback to maintain a solid statistical baseline. 
3. Replay Mode & Historical Gaps
    • The IAI transparently displays "No Stat. Control" during Bar Replay if historical lower-timeframe data is unavailable for that specific segment. We prioritize data honesty over showing "estimated" or faked data.
4. How to set Alerts (Smart Signals)
To activate the IAI early warning system, follow these steps in the TradingView Alert Menu:
    1. Condition (1st Box): Select "pct_IAI".
    2. Trigger Logic (2nd Box): Change the setting to "Any function call"
    3. Frequency / Timeframe:
    • The alert frequency is automatically managed by the script (once_per_bar_close) to ensure data honesty and prevent repainting.
    • The type of signal depends on your chart: Use the Main-TF (e.g., H2) for final HTF-signals, or a Lower-Timeframe (e.g., M10) to receive the Live-Tracker early warnings.
      Intelligence: You don’t need to type a message. The alert is fully dynamic—it automatically reports the Mode (Live vs. HTF), the Safeguard-Status, and the Data Integrity (Verified vs. Low Integrity) directly to your device.

📊 Understanding the Data Window (Statistical Transparency)
The IAI performs complex statistical comparisons under the hood. To keep the chart clean, these raw metrics are not plotted visually but are displayed exclusively in the TradingView Data Window (right sidebar). They provide full transparency:
    • Runtime-Safe LTF: Displays the analysis interval currently in use. If this value is red, the script automatically adjusted the interval to prevent a runtime error (e.g., if your chart timeframe is larger than your selected LTF).
    • Max Safe Lookback for this TF: The mathematical limit for your current setup. It calculates at which point your Lookback Period exceeds Pine Script's technical 5,000-bar limit.
    • Active Bar Limit: The actual usable data foundation. If this value turns red, your selected lookback is statistically "clipped" because not enough historical data points can be retrieved.
    • Converted Sum of LTF Request Bars: This converts the historical baseline (HTF-Request) into current chart units. It serves as the anchor point for the comparison with the Live-Tracker.
    • Relative Live-Data Size: The numerical basis of your Confidence Score. It shows the ratio between the real-time data stream and the historical expectation. A value near 100% indicates absolute statistical integrity.
    • Overall Requested Bars: The total number of individual data points analyzed within your selected Lookback Period.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © arnipoer

//@version=6

/// @description This script provides an adaptive percentrank-based analysis of Volume and Volatility (true-range).
/// It dynamically toggles between request.lower_tf-reconstruction and cumulative lower_tf chart data (simulating continual ltf_request).

///@link https://www.tradingview.com/script/8Y3LEclz-The-Werkstatt-OMSF/ - THE WERKSTATT #Proj 01: Save Cumulative Activity as Zones on Chart

indicator(title="Intra-Bar Activity Index (IAI) [Adaptive Volume & Volatility]", shorttitle="IAI", overlay=false, dynamic_requests=true)

LongCandle(bool is_ltf, int current_time_faktor) =>
    is_ltf ?  open[current_time_faktor] < close : open < close
ShortCandle(bool is_ltf, int current_time_faktor) =>
    is_ltf ? open[current_time_faktor] >= close : open >= close
    

// --- BASIC SETTINGS ---
tf_main = input.timeframe('120', title = 'Main Timeframe', group = 'BASIC SETTINGS', 
     tooltip = 'The reference timeframe for trend and activity analysis. The script reconstructs historical data based on this period using a lower_tf_request.')

tf_lookback = input.int(50, maxval = 4900, title = 'Lookback Period', group = 'BASIC SETTINGS', 
     tooltip = 'Number of bars used for the PercentRank calculation. Higher values create more stable, long-term statistical averages.')

ltf = input.timeframe('10', title = 'Lower Timeframe', group = 'BASIC SETTINGS', 
     tooltip = 'The sub-interval used for the lower_tf_request. \n\nNote: If this value is larger than your current chart, the script automatically switches to the chart timeframe to prevent errors. Check "Runtime-Safe LTF" in the Data Window for the active setting.')

lt_devation_tresh = input.float(15.0, step=0.5, title = 'max % LiveTracker Deviation', group = 'BASIC SETTINGS', 
     tooltip = 'Defines the tolerance for the "Relative Live-Data Size". If the deviation between the live stream and the actual lower_tf_request baseline exceeds this percentage, the dashboard turns red to warn about potential data inconsistency.')
// --- THRESHOLDS ---
VolumeTresh = input.float(85.0, step=1.0, title = 'Volume Threshold (%)', group = 'Thresholds', 
     tooltip = 'Defines the minimum percentile for volume engagement. \n\nExample: 85.0 means the current volume must be higher than 85% of all bars in your lookback period to be considered significant.')

VolaTresh = input.float(85.0, step=1.0, title = 'Volatility Threshold (%)', group = 'Thresholds', 
     tooltip = 'Defines the minimum percentile for price activity (True Range). \n\nExample: 85.0 means the current volatility must be higher than 85% of all bars in your lookback period. High volatility combined with high volume triggers the Activity Index (IAI).')

low_VolumeTresh = input.float(25.0, step=1.0, title = 'Low Volume Threshold (%)', group = 'Thresholds', 
     tooltip = 'Defines the percentile for "Dry Volume" phases. \n\nExample: 25.0 means the current volume is among the lowest 25% of all bars in your lookback period. Used to identify a lack of institutional interest (Gray Bars).')

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////PercentRank Volatility & Volume Confirm////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

calc_ib_metrics(string tf_main, string ltf, int lookback) =>
    // max possible intra-bars based on user input
    int max_intrabars = timeframe.in_seconds(tf_main) / timeframe.in_seconds(ltf)
    
    // Safety Fallback: Prevents runtime errors by ensuring LTF is not larger than the current chart
    active_ltf = timeframe.in_seconds(ltf) <= timeframe.in_seconds() ? ltf : timeframe.period
    
    // The actually used ratio to prevent execution errors and maintain stability
    int max_intrabars_active = timeframe.in_seconds(tf_main) / timeframe.in_seconds(active_ltf)
    
    
    //-------------------------------------- IB-REQUEST LOGIC (History) -----------------------------------------//
    // Batched data requests for historical intra-bar reconstruction
    
    arr_ltf_vola  = request.security_lower_tf(syminfo.tickerid, active_ltf, ta.tr(true))
    float vola_fallback = ta.atr(max_intrabars)

    int ib_request_sample_size = array.size(arr_ltf_vola) // Contains the current number of LTF candles within the current MainTF bar

    // Aggregate request data (Totals)
    float ib_request_vola_total     = array.size(arr_ltf_vola) > 0  ? array.sum(arr_ltf_vola)  : vola_fallback
    
    float pct_req_vola   = ta.percentrank(ib_request_vola_total, lookback)
    float pct_req_volume = ta.percentrank(volume, lookback)
     
    float ib_request_vola   = pct_req_vola
    float ib_request_volume = pct_req_volume
    
   
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                             --- LIVE-TRANSFER LOGIK (Real-Time Bridge) ---                                      //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Determine how many chart bars represent one main bar interval
    int current_chart_ratio = (timeframe.in_seconds(tf_main) >= timeframe.in_seconds(timeframe.period)) ? 
         int(math.min((timeframe.in_seconds(tf_main) / timeframe.in_seconds(timeframe.period)), 4900)) : 1

    // Aggregate live data (Totals)
    float live_transfer_vola_total   = math.sum(ta.tr(true), current_chart_ratio)
    float live_transfer_volume_total = nz(math.sum(volume, current_chart_ratio), 0)
   
    // Adjust lookback to maintain statistical consistency across different data densities
    int safe_lookback = math.min(lookback * current_chart_ratio, 4900)
    
    // PercentRank-Transformation (Live-Transfer)
    float pct_live_vola   = ta.percentrank(live_transfer_vola_total, safe_lookback)
    float pct_live_volume = ta.percentrank(live_transfer_volume_total, safe_lookback)
    
    float live_transfer_vola   = pct_live_vola
    float live_transfer_volume = pct_live_volume
    
    [live_transfer_vola, live_transfer_volume, ib_request_vola, ib_request_volume,
         current_chart_ratio, max_intrabars, active_ltf, max_intrabars_active, ib_request_sample_size[1]] // why ib_request_sample_size[1]? : To validate Live-Tracker values, we retrieve the number of LTF data points from the last closed HTF bar. [1]
      
// --- Function Call and Variable Assignment ---
[live_vola, live_volume, req_vola, req_volume, current_chart_ratio, max_intrabars, act_ltf, act_intrabars_active, req_sample_size] 
     = calc_ib_metrics(tf_main, ltf, tf_lookback)


/////////////////////////////////////////////////////////////////////////////////////
//////////////   get_ib_sample_stats                                ////////////////
///////////////////////////////////////////////////////////////////////////////////
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

bool live_data_warning = livetracker_dev_pct > 100 + lt_devation_tresh or livetracker_dev_pct < 100 - lt_devation_tresh

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
var float observed_vola    = na , var float observed_volume  = na

// Check if we are viewing a timeframe smaller than the main analysis timeframe
is_ltf_view = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(tf_main)

if not is_ltf_view 
    // Context: HTF Chart (e.g., H2) -> Use reconstructed Intra-Bar Request data
    observed_vola   := req_vola, observed_volume := req_volume
else
    // Context: LTF Chart (e.g., M10) -> Use the Live-Transfer (Bridge) to simulate HTF behavior
    observed_vola   := live_vola, observed_volume := live_volume

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            --- SIGNAL ENGINE ---                                                //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Core threshold evaluations
bool is_high_volume   = observed_volume > VolumeTresh
bool is_low_volume    = observed_volume < low_VolumeTresh
bool is_high_vola     = observed_vola > VolaTresh

// 3. IAI Logic (High Activity & Engagement)
bool is_iai = is_high_volume and is_high_vola

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            --- VISUALIZATION ---                                                //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// --- VISUALIZATION: OSCILLATOR ---

color vol_color = is_iai ? color.new(color.orange, 30) : 
      (not is_low_volume ? color.new(color.navy, is_high_volume ? 10 : 50) : color.new(color.gray, 70))
// Volume Histogram (Background)
plot(observed_volume, title='Volume Percentile', style=plot.style_columns, histbase=0, 
     color=vol_color, linewidth=2)

// Volatility Area
plot(observed_vola, title='Volatility Percentile', style=plot.style_area, histbase=0, 
     color=is_high_vola ? color.new(color.orange, 75) : color.new(color.silver, 80), linewidth=2)

// --- LEVEL REFERENCES (Percentile Scale) ---
hline(50, title = 'Median (50%)', color = color.new(color.white, 50), linestyle = hline.style_dashed)
hline(100, title = 'Maximum', color = color.white, linewidth = 1)
hline(VolumeTresh, title = 'Volume Threshold', color = color.purple, linestyle = hline.style_dashed)
hline(VolaTresh,   title = 'Volatility Threshold', color = color.orange, linestyle = hline.style_dashed)

// Dynamic separator for Main-Timeframe boundaries
if timeframe.change(tf_main) and not (timeframe.period == tf_main)
    line.new(bar_index, 0, bar_index, 100, color=color.new(color.white, 0), style=line.style_dotted)


// --- VISUAL SETTINGS (Price Chart Overlays) ---
G_VIS = "Visual Settings - Price Chart"
show_IAI = input.bool(false, "Show IAI Dots", group=G_VIS, 
     tooltip="Displays orange circles when both Volatility and Volume exceed your defined thresholds (Institutional Activity).")
// IAI Dots
plotshape(show_IAI and is_iai and ShortCandle(is_ltf_view, current_chart_ratio), title='IAI Short', display = display.pane, color=color.orange, style=shape.circle, location=location.abovebar, size=size.tiny, force_overlay=true)
plotshape(show_IAI and is_iai and LongCandle(is_ltf_view, current_chart_ratio),  title='IAI Long', display = display.pane, color=color.orange, style=shape.circle, location=location.belowbar, size=size.tiny, force_overlay=true)


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
        string integrity_symbol = (livetracker_dev_pct >= 100 - lt_devation_tresh) ? "🛡️ " : "⚠️ "
        string conf_text  = has_baseline ? integrity_symbol + "Data Integrity: " + str.tostring(livetracker_dev_pct, "#.0") + "%" : "No Stat.Control (Replay Gap)"
        color conf_bg     = not has_baseline ? color.blue : (live_data_warning ? color.maroon : color.green)
        table.cell(status_tab, 0, 3, text = conf_text, bgcolor = conf_bg, text_color = color.white, text_size = size.small)
    else
        table.cell(status_tab, 0, 2, text = "", bgcolor = na)
        table.cell(status_tab, 0, 3, text = "", bgcolor = na)
// --- EXECUTE DASHBOARD ---
if barstate.islast
    printStatusDashboard(position.middle_left, is_ltf_view)


// --- DYNAMIC SIGNAL ALERTS ---
if is_iai
    // 1. Safeguard-Status prüfen
    bool is_safeguard_active = ltf != act_ltf
    string safe_info = is_safeguard_active ? " [SAFEGUARD M" + str.tostring(timeframe.in_seconds(act_ltf)/60, "#") + "]" : ""
    
    // 2. Modus und Integrität bestimmen
    string alert_mode = is_ltf_view ? "LIVE-TRANSFER" : "HTF-REQUEST"
    string integrity_info = is_ltf_view and live_data_warning ? " (Low Integrity!)" : " (Verified)"
    
    // 3. Finale Nachricht zusammenbauen
    string alert_msg = "IAI " + alert_mode + safe_info + ": High Energy on " + syminfo.ticker + " [" + timeframe.period + "]" + integrity_info
    
    // Alert absenden
    alert(alert_msg, alert.freq_once_per_bar_close)
````
