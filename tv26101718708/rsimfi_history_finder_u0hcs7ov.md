# RSI-MFI History Finder

- url: https://www.tradingview.com/script/U0Hcs7oV-RSI-MFI-History-Finder/
- type: indicator
- pine_id: PUB;36a61f21ad4641e2833070197ecdd026
- version: 1.0

## Description

[b]Description:[/b]
This indicator replicates the original [b]RSI-MFI (Money Flow wave/band)[/b] found in popular systems like Market Cipher B and VuManChu (VMC), enhancing it with a unique historical search engine. It is built specifically for traders who rely on contextual market analysis, pattern matching, and backtesting identical historical setups.

The indicator automatically scans the chart's history to find the most recent candle where the Money Flow index reached an extremity identical to (or deeper than) the current level (or a manually specified target), helping you instantly cross-reference the current setup with historical precedents.

[b]Key Features:[/b]

[list][b]Original VMC Math:[/b] Fully complies with the original formula calculating RSI-MFI based on the smoothed ratio of candle bodies to their wicks. The values perfectly match classical sub-window oscillators.
[b]Smart Directional Search:[/b] The algorithm automatically adapts to the sign of your target value:
[i]- If the RSI-MFI target is negative (oversold conditions), the script searches for the closest historical bar where the value was equal to or lower than the target (matching similar or deeper exhaustion).[/i]
[i]- If the RSI-MFI target is positive (overbought conditions), the script looks for a bar where the value was equal to or higher than the target (matching similar or stronger momentum).[/i]
[b]Local Noise Filter (Skip Recent Bars):[/b] A fully customizable setting allows you to exclude the N most recent bars from the search. This prevents the script from catching candles within the current consolidation or immediate market move, forcing it to look back into previous isolated market cycles.
[b]Perfect Independent Scaling:[/b] Operating in a dedicated sub-window (overlay=false) with a fixed range from -100 to +100 and static boundary lines (0, ±50), the oscillator remains perfectly readable and will never get flattened by the absolute price of the asset.
[*][b]Instant Candle Navigation:[/b] The script pushes the exact date and time of the matched historical point directly to the Pine Logs panel, allowing you to copy it with a single click.
[/list]

[b]How to Use:[/b]
[list=1]Open the [b]Pine Logs[/b] tab at the bottom of TradingView (located next to the Pine Editor and Strategy Tester).
Once the indicator identifies a match, an orange dashed vertical line and a label will appear in the sub-window, and a log entry will generate: [b]GO-TO DATE: YYYY-MM-DD HH:MM[/b].
Highlight and copy ([b]Ctrl+C[/b] / [b]Cmd+C[/b]) this date from the logs.
Press [b]Alt + G[/b] (or [b]Option + G[/b] on Mac) to bring up TradingView's native "Go to" navigation window, paste the copied date ([b]Ctrl+V[/b]), and hit Enter. The chart will instantly snap to that precise historical candle.
[*]If you want to simulate the price action from that point forward, press [b]Alt + B[/b] to activate the [b]Bar Replay[/b] tool and click right on the highlighted candle to cut the chart there.
[/list]

[b]Inputs & Settings:[/b]
[list][b]What to look for?[/b] – Switch between tracking the live closing value of the oscillator (Current Value) or looking for a custom predefined level (Manual Input Value).
[b]Skip Recent Bars[/b] – Number of recent candles excluded from the scan (default is 7). Protects against triggering within the current market impulse.
[b]Historical Search Depth[/b] – Max number of bars to scan backwards (supports up to 5000 bars with automated memory buffer extension).
[b]Original RSI-MFI Settings[/b] – Core period, multiplier, and offset variables to keep the oscillator aligned with your existing trading strategy.
[/list]

## Source Code

````pine
//@version=6
indicator("RSI-MFI History Finder", overlay=false, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// --- Search Settings ---
string  src_type        = input.string("Current Value", "What to look for?", options=["Current Value", "Manual Input"], group="Search Logic")
float   manual_val      = input.float(0.0, "Manual Input Value", group="Search Logic")
int     skip_bars       = input.int(7, "Skip Recent Bars", minval=0, maxval=500, group="Search Logic", tooltip="Excludes the most recent bars from the search.")
int     max_search_depth= input.int(3000, "Historical Search Depth", minval=10, maxval=5000, group="Search Logic")

// --- Original RSI-MFI Formula (from VuManChu / Market Cipher B) ---
int     rsiMFIperiod     = input.int(60, "RSI-MFI Period", group="Original RSI-MFI Settings")
float   rsiMFIMultiplier = input.float(150.0, "RSI-MFI Multiplier", group="Original RSI-MFI Settings")
float   rsiMFIPosY       = input.float(2.5, "RSI-MFI Y Offset", group="Original RSI-MFI Settings")

// Calculations
float   candle_range     = (high - low) == 0 ? 0.00001 : (high - low)
float   raw_rsi_mfi      = ta.sma(((close - open) / candle_range) * rsiMFIMultiplier, rsiMFIperiod) - rsiMFIPosY

// --- Oscillator Visualization (Sub-window) ---
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
// Beautiful area plot (green/red)
plot(raw_rsi_mfi, title="RSI-MFI Area", color=raw_rsi_mfi >= 0 ? color.new(#26a69a, 75) : color.new(#ef5350, 75), style=plot.style_area, histbase=0)
// Main oscillator trendline
plot(raw_rsi_mfi, title="RSI-MFI Line", color=raw_rsi_mfi >= 0 ? #26a69a : #ef5350, linewidth=2)

// Lock the target value
var float target_value = na
if barstate.islast
    target_value := (src_type == "Current Value") ? raw_rsi_mfi : manual_val

var int   found_bar_index = na
var float found_value     = na
var int   found_time      = na
var bool  match_found     = false

// Historical search loop
if barstate.islast
    match_found := false
    int start_index = (src_type == "Current Value") ? skip_bars + 1 : skip_bars
    int end_index   = math.min(bar_index, max_search_depth)
    
    if start_index <= end_index
        for i = start_index to end_index
            if na(raw_rsi_mfi[i])
                continue
                
            bool is_match = false
            if target_value >= 0
                is_match := raw_rsi_mfi[i] >= target_value
            else
                is_match := raw_rsi_mfi[i] <= target_value
                
            if is_match
                found_bar_index := bar_index - i
                found_value     := raw_rsi_mfi[i]
                found_time      := time[i]
                match_found     := true
                break

// --- UI Table, Lines and Labels ---
var line  v_line     = na
var label info_label = na
var table info_table = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    line.delete(v_line)
    label.delete(info_label)
    
    string op_sign = target_value >= 0 ? ">= " : "<= "
    
    table.cell(info_table, 0, 0, "Current RSI-MFI:", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 0, str.tostring(math.round(raw_rsi_mfi, 1)), text_color=color.yellow, text_size=size.small)
    
    table.cell(info_table, 0, 1, "Target Value:", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 1, str.tostring(math.round(target_value, 1)), text_color=color.aqua, text_size=size.small)
    
    table.cell(info_table, 0, 2, "Search Condition:", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 2, op_sign + str.tostring(math.round(target_value, 1)), text_color=color.gray, text_size=size.small)
    
    table.cell(info_table, 0, 3, "Bars Skipped:", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 3, str.tostring(skip_bars), text_color=color.gray, text_size=size.small)
    
    table.cell(info_table, 0, 4, "Search Status:", text_color=color.white, text_size=size.small)
    
    if match_found
        int bars_ago = bar_index - found_bar_index
        string match_time = str.format("{0,date,yyyy-MM-dd HH:mm}", found_time)
        
        table.cell(info_table, 1, 4, "FOUND", text_color=color.green, text_size=size.small)
        table.cell(info_table, 0, 5, "Copy Date From Logs 👇", text_color=color.orange, text_size=size.small)
        
        log.info("GO-TO DATE: " + match_time)
        
        // Vertical pointer line inside the sub-window
        v_line := line.new(x1=found_bar_index, y1=-50, x2=found_bar_index, y2=50, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.orange, 30), width=2, style=line.style_dashed)
        
        // Label pinned directly to the historical oscillator wave
        info_label := label.new(x=found_bar_index, y=raw_rsi_mfi[bars_ago], text="Match: " + str.tostring(math.round(found_value, 1)) + "\n" + str.tostring(bars_ago) + " bars ago", xloc=xloc.bar_index, color=color.orange, textcolor=color.white, style=label.style_label_down)
    else
        table.cell(info_table, 1, 4, "NOT FOUND", text_color=color.red, text_size=size.small)
        table.cell(info_table, 0, 5, "Bars Checked:", text_color=color.white, text_size=size.small)
        table.cell(info_table, 1, 5, str.tostring(max_search_depth), text_color=color.gray, text_size=size.small)
````
