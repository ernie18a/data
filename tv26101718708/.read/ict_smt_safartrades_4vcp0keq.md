# ICT SMT @Safartrades

- url: https://www.tradingview.com/script/4VCp0KEQ-ICT-SMT-Safartrades/
- type: indicator
- pine_id: PUB;4706bc88eb6f4c7f879f0e4a260916b7
- version: 1.0

## Description

[b]ICT SMT [/b]

ICT SMT Pro is a Smart Money Technique (SMT) divergence framework designed to automatically compare correlated markets and identify divergence between their respective swing structures.

SMT divergence is commonly used by ICT traders to evaluate whether correlated assets are confirming or contradicting each other's price action. Rather than manually comparing multiple charts, the indicator continuously analyzes the selected markets and highlights qualifying SMT relationships directly on the active chart.
[image]https://www.tradingview.com/x/SjXJo6FZ/[/image]
[b]Correlated Market Analysis[/b]
[image]https://www.tradingview.com/x/BORVHEv4/[/image]
The indicator allows traders to compare two correlated assets while remaining on a single chart.

Typical market combinations include:

[list]
[*]NQ ↔ ES
[*]ES ↔ YM
[*]NQ ↔ YM
[/list]

Users can configure one or more comparison assets depending on their preferred market relationships.

As new swing highs and lows develop, the indicator evaluates both markets and identifies qualifying SMT divergences whenever one market confirms a new swing while the correlated market fails to do so.
[b]SMT Detection Engine[/b]
[image]https://www.tradingview.com/x/1kfzFfV8/[/image]
The divergence engine automatically evaluates swing structure using configurable swing detection settings.

Users can adjust:

[list]
[*]Swing lookback length
[*]Swing detection source
[*]Signal history
[*]Asset inversion
[*]Divergence visualization
[/list]

This allows the detection engine to be adapted to different trading styles while maintaining a consistent SMT identification process.
[b]Invalidation Tracking[/b]
[image]https://www.tradingview.com/x/HteTVhPA/[/image]
Market structure evolves continuously, and previously identified SMT relationships may later become invalid.

To help traders maintain accurate chart context, the indicator includes an optional SMT invalidation system.

Users can configure:

[list]
[*]Invalidation level source
[*]Invalidation trigger method
[*]Visibility of invalidated SMTs
[/list]

This allows completed and invalidated SMT structures to be managed without requiring manual cleanup.
[b]Customization[/b]
[image]https://www.tradingview.com/x/lw1sYzH2/[/image]
Every component of the framework can be individually configured, including:

[list]
[*]Correlated asset selection
[*]Asset inversion
[*]Swing detection settings
[*]SMT history
[*]Divergence line styling
[*]Label visibility
[*]Label size and positioning
[*]Text colors
[*]Invalidation behavior
[*]
[/list][b]Intended Use[/b]

ICT SMT Pro is designed for traders who incorporate Smart Money Technique (SMT) divergence into their market analysis.

By continuously monitoring correlated markets and automatically identifying qualifying divergence, the indicator reduces the need for manual multi-chart comparison while helping traders maintain awareness of evolving intermarket relationships during execution.

## Source Code

````pine
//@version=6
indicator("Smart Money Technique (SMT) Divergence Pro", shorttitle="ICT SMT", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================================================================
// 1. User Inputs & Configuration Groups
// =========================================================================

// Preset Symbol Configurations group
grp_symbol = "Correlated Asset Configuration"
enable_sec_1 = input.bool(true, "", group=grp_symbol, inline="Asset 1")
sec_symbol_1 = input.symbol("CME_MINI:ES1!", "Asset 1", group=grp_symbol, inline="Asset 1")
invert_sec_1 = input.bool(false, "Invert", group=grp_symbol, inline="Asset 1")

enable_sec_2 = input.bool(false, "", group=grp_symbol, inline="Asset 2")
sec_symbol_2 = input.symbol("CBOT:YM1!", "Asset 2", group=grp_symbol, inline="Asset 2")
invert_sec_2 = input.bool(false, "Invert", group=grp_symbol, inline="Asset 2")

// Divergence Engine Settings
grp_engine = "SMT Divergence Engine Settings"
swing_n = input.int(5, "Swing Lookback Length", minval=1, group=grp_engine, tooltip="Number of bars on each side required to confirm a swing high/low.")
swing_source = input.string("High/Low", "Swing Detection Source", options=["High/Low", "Close"], group=grp_engine, tooltip="High/Low uses wick highs and lows. Close uses candle body closes.")
max_signals_to_keep = input.int(50, "Max Signal History on Chart", minval=5, maxval=200, group=grp_engine, tooltip="Limits the number of lines and labels drawn on the chart to prevent clutter.")

// Visual & Styling Settings
grp_style = "Visual & Styling Settings"
smt_color = input.color(#ff1744, "SMT Color", group=grp_style, tooltip="Global color for all SMT divergence lines.")
line_width = input.int(2, "Divergence Line Width", minval=1, maxval=5, group=grp_style)

// Label Styling Settings
grp_lbl = "Label Styling Settings"
show_labels = input.bool(true, "Show SMT Labels", group=grp_lbl)
lbl_pos = input.string("Center of Line", "Label Position", options=["Pivot Point", "Center of Line"], group=grp_lbl)
lbl_size = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_lbl)
lbl_text_color = input.color(#ff1744, "Label Text Color", group=grp_lbl, tooltip="Global text color for all SMT labels.")

// SMT Invalidation Settings
grp_inval = "SMT Invalidation Settings"
show_invalidated = input.bool(true, "Show Invalidated SMTs", group=grp_inval, tooltip="If checked, SMT lines will turn dashed and faded when price breaches their invalidation level. If unchecked, they are deleted.")
inval_level_type = input.string("Highest/Lowest of the Swings", "Invalidation Level Source", options=["Highest/Lowest of the Swings", "Second Swing Point Only"], group=grp_inval, tooltip="Determine which level must be crossed for invalidation.")
inval_source = input.string("Close", "Invalidation Trigger", options=["Close", "High/Low"], group=grp_inval, tooltip="Close requires a candle body close past the level. High/Low requires any wick touch.")

// =========================================================================
// 2. Types & Data Structures
// =========================================================================

// Custom User-Defined Type (UDT) to represent a swing point and its drawing references
type SwingPoint
    int bar_idx
    int time_val
    float price
    float sec_price
    line swing_line
    label div_label
    bool is_invalidated
    float inv_level

// Global arrays to maintain historical swing point UDTs
var SwingPoint[] prim_highs_1 = array.new<SwingPoint>()
var SwingPoint[] prim_lows_1 = array.new<SwingPoint>()
var SwingPoint[] prim_highs_2 = array.new<SwingPoint>()
var SwingPoint[] prim_lows_2 = array.new<SwingPoint>()

// =========================================================================
// 3. Data Acquisition (Secondary Asset)
// =========================================================================

// Fetch secondary assets OHLC with standard settings (lookahead off to prevent repainting)
sec_high_1 = request.security(sec_symbol_1, timeframe.period, high, barmerge.gaps_off, barmerge.lookahead_off)
sec_low_1 = request.security(sec_symbol_1, timeframe.period, low, barmerge.gaps_off, barmerge.lookahead_off)
sec_close_1 = request.security(sec_symbol_1, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

sec_high_2 = request.security(sec_symbol_2, timeframe.period, high, barmerge.gaps_off, barmerge.lookahead_off)
sec_low_2 = request.security(sec_symbol_2, timeframe.period, low, barmerge.gaps_off, barmerge.lookahead_off)
sec_close_2 = request.security(sec_symbol_2, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

// Resolve swing detection source based on user input
high_src = swing_source == "High/Low" ? high : close
low_src = swing_source == "High/Low" ? low : close

sec_high_src_1 = swing_source == "High/Low" ? (invert_sec_1 ? -sec_low_1 : sec_high_1) : (invert_sec_1 ? -sec_close_1 : sec_close_1)
sec_low_src_1  = swing_source == "High/Low" ? (invert_sec_1 ? -sec_high_1 : sec_low_1) : (invert_sec_1 ? -sec_close_1 : sec_close_1)

sec_high_src_2 = swing_source == "High/Low" ? (invert_sec_2 ? -sec_low_2 : sec_high_2) : (invert_sec_2 ? -sec_close_2 : sec_close_2)
sec_low_src_2  = swing_source == "High/Low" ? (invert_sec_2 ? -sec_high_2 : sec_low_2) : (invert_sec_2 ? -sec_close_2 : sec_close_2)

// Pre-calculate historical values at the pivot offset to avoid inside-block history-referencing issues
sec_high_at_pivot_1 = sec_high_src_1[swing_n]
sec_low_at_pivot_1 = sec_low_src_1[swing_n]

sec_high_at_pivot_2 = sec_high_src_2[swing_n]
sec_low_at_pivot_2 = sec_low_src_2[swing_n]

time_at_pivot = time[swing_n]


// =========================================================================
// 4. Helper Functions
// =========================================================================

// Resolve label size configuration to standard size variables
f_get_lbl_size(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// Helper to extract short form of the symbol (removes exchange prefix)
f_get_short_symbol(string sym) =>
    parts = str.split(sym, ":")
    array.get(parts, array.size(parts) - 1)

// Helper functions to process invalidations on SwingPoint arrays
f_process_high_invalidations(SwingPoint[] arr, float check_val, bool show_inval, color smt_c, color lbl_c) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            SwingPoint sp = array.get(arr, i)
            if not na(sp.swing_line) and not sp.is_invalidated
                if check_val > sp.inv_level
                    sp.is_invalidated := true
                    if show_inval
                        line.set_style(sp.swing_line, line.style_dashed)
                        line.set_color(sp.swing_line, color.new(smt_c, 75))
                        if not na(sp.div_label)
                            label.set_textcolor(sp.div_label, color.new(lbl_c, 75))
                    if not show_inval
                        line.delete(sp.swing_line)
                        sp.swing_line := na
                        if not na(sp.div_label)
                            label.delete(sp.div_label)
                            sp.div_label := na

f_process_low_invalidations(SwingPoint[] arr, float check_val, bool show_inval, color smt_c, color lbl_c) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            SwingPoint sp = array.get(arr, i)
            if not na(sp.swing_line) and not sp.is_invalidated
                if check_val < sp.inv_level
                    sp.is_invalidated := true
                    if show_inval
                        line.set_style(sp.swing_line, line.style_dashed)
                        line.set_color(sp.swing_line, color.new(smt_c, 75))
                        if not na(sp.div_label)
                            label.set_textcolor(sp.div_label, color.new(lbl_c, 75))
                    if not show_inval
                        line.delete(sp.swing_line)
                        sp.swing_line := na
                        if not na(sp.div_label)
                            label.delete(sp.div_label)
                            sp.div_label := na

// =========================================================================
// 5. Swing Point Detection Engine
// =========================================================================

// Using optimized built-in pivot functions for maximum performance and accuracy
ph = ta.pivothigh(high_src, swing_n, swing_n)
pl = ta.pivotlow(low_src, swing_n, swing_n)

// Dynamic ATR for clean offsets
atr_val = ta.atr(14)

// =========================================================================
// 6. SMT Divergence Logic & Drawing
// =========================================================================

// Check Swing Highs (Bearish SMT)
if not na(ph)
    // Check Asset 1
    if enable_sec_1
        new_sp_1 = SwingPoint.new(bar_index - swing_n, time_at_pivot, ph, sec_high_at_pivot_1, na, na, false, na)
        if array.size(prim_highs_1) > 0
            SwingPoint sp_prev = array.get(prim_highs_1, array.size(prim_highs_1) - 1)
            prim_diff = ph - sp_prev.price
            sec_diff = new_sp_1.sec_price - sp_prev.sec_price
            is_divergent = (prim_diff > 0 and sec_diff <= 0) or (prim_diff < 0 and sec_diff >= 0) or (prim_diff == 0 and sec_diff != 0)
            if is_divergent and not na(sp_prev.sec_price) and not na(new_sp_1.sec_price)
                new_sp_1.inv_level := inval_level_type == "Highest/Lowest of the Swings" ? math.max(sp_prev.price, new_sp_1.price) : new_sp_1.price
                new_sp_1.swing_line := line.new(x1=sp_prev.time_val, y1=sp_prev.price, x2=new_sp_1.time_val, y2=new_sp_1.price, xloc=xloc.bar_time, color=smt_color, width=line_width, style=line.style_solid)
                if show_labels
                    lbl_text = "SMT:" + f_get_short_symbol(sec_symbol_1)
                    lbl_x = lbl_pos == "Center of Line" ? math.round((sp_prev.time_val + new_sp_1.time_val) / 2) : new_sp_1.time_val
                    offset = atr_val * 0.3
                    lbl_y = lbl_pos == "Center of Line" ? ((sp_prev.price + new_sp_1.price) / 2) + offset : new_sp_1.price + offset
                    new_sp_1.div_label := label.new(x=lbl_x, y=lbl_y, text=lbl_text, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=lbl_text_color, style=label.style_none, size=f_get_lbl_size(lbl_size))
                alert("Bearish SMT Divergence: " + syminfo.ticker + " vs " + sec_symbol_1, alert.freq_once_per_bar_close)
        array.push(prim_highs_1, new_sp_1)
        if array.size(prim_highs_1) > max_signals_to_keep
            SwingPoint oldest = array.shift(prim_highs_1)
            if not na(oldest.swing_line)
                line.delete(oldest.swing_line)
            if not na(oldest.div_label)
                label.delete(oldest.div_label)

    // Check Asset 2
    if enable_sec_2
        new_sp_2 = SwingPoint.new(bar_index - swing_n, time_at_pivot, ph, sec_high_at_pivot_2, na, na, false, na)
        if array.size(prim_highs_2) > 0
            SwingPoint sp_prev = array.get(prim_highs_2, array.size(prim_highs_2) - 1)
            prim_diff = ph - sp_prev.price
            sec_diff = new_sp_2.sec_price - sp_prev.sec_price
            is_divergent = (prim_diff > 0 and sec_diff <= 0) or (prim_diff < 0 and sec_diff >= 0) or (prim_diff == 0 and sec_diff != 0)
            if is_divergent and not na(sp_prev.sec_price) and not na(new_sp_2.sec_price)
                new_sp_2.inv_level := inval_level_type == "Highest/Lowest of the Swings" ? math.max(sp_prev.price, new_sp_2.price) : new_sp_2.price
                new_sp_2.swing_line := line.new(x1=sp_prev.time_val, y1=sp_prev.price, x2=new_sp_2.time_val, y2=new_sp_2.price, xloc=xloc.bar_time, color=smt_color, width=line_width, style=line.style_solid)
                if show_labels
                    lbl_text = "SMT:" + f_get_short_symbol(sec_symbol_2)
                    lbl_x = lbl_pos == "Center of Line" ? math.round((sp_prev.time_val + new_sp_2.time_val) / 2) : new_sp_2.time_val
                    offset = atr_val * 0.3
                    lbl_y = lbl_pos == "Center of Line" ? ((sp_prev.price + new_sp_2.price) / 2) + offset : new_sp_2.price + offset
                    new_sp_2.div_label := label.new(x=lbl_x, y=lbl_y, text=lbl_text, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=lbl_text_color, style=label.style_none, size=f_get_lbl_size(lbl_size))
                alert("Bearish SMT Divergence: " + syminfo.ticker + " vs " + sec_symbol_2, alert.freq_once_per_bar_close)
        array.push(prim_highs_2, new_sp_2)
        if array.size(prim_highs_2) > max_signals_to_keep
            SwingPoint oldest = array.shift(prim_highs_2)
            if not na(oldest.swing_line)
                line.delete(oldest.swing_line)
            if not na(oldest.div_label)
                label.delete(oldest.div_label)

// Check Swing Lows (Bullish SMT)
if not na(pl)
    // Check Asset 1
    if enable_sec_1
        new_sp_1 = SwingPoint.new(bar_index - swing_n, time_at_pivot, pl, sec_low_at_pivot_1, na, na, false, na)
        if array.size(prim_lows_1) > 0
            SwingPoint sp_prev = array.get(prim_lows_1, array.size(prim_lows_1) - 1)
            prim_diff = pl - sp_prev.price
            sec_diff = new_sp_1.sec_price - sp_prev.sec_price
            is_divergent = (prim_diff > 0 and sec_diff <= 0) or (prim_diff < 0 and sec_diff >= 0) or (prim_diff == 0 and sec_diff != 0)
            if is_divergent and not na(sp_prev.sec_price) and not na(new_sp_1.sec_price)
                new_sp_1.inv_level := inval_level_type == "Highest/Lowest of the Swings" ? math.min(sp_prev.price, new_sp_1.price) : new_sp_1.price
                new_sp_1.swing_line := line.new(x1=sp_prev.time_val, y1=sp_prev.price, x2=new_sp_1.time_val, y2=new_sp_1.price, xloc=xloc.bar_time, color=smt_color, width=line_width, style=line.style_solid)
                if show_labels
                    lbl_text = "SMT:" + f_get_short_symbol(sec_symbol_1)
                    lbl_x = lbl_pos == "Center of Line" ? math.round((sp_prev.time_val + new_sp_1.time_val) / 2) : new_sp_1.time_val
                    offset = atr_val * 0.3
                    lbl_y = lbl_pos == "Center of Line" ? ((sp_prev.price + new_sp_1.price) / 2) - offset : new_sp_1.price - offset
                    new_sp_1.div_label := label.new(x=lbl_x, y=lbl_y, text=lbl_text, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=lbl_text_color, style=label.style_none, size=f_get_lbl_size(lbl_size))
                alert("Bullish SMT Divergence: " + syminfo.ticker + " vs " + sec_symbol_1, alert.freq_once_per_bar_close)
        array.push(prim_lows_1, new_sp_1)
        if array.size(prim_lows_1) > max_signals_to_keep
            SwingPoint oldest = array.shift(prim_lows_1)
            if not na(oldest.swing_line)
                line.delete(oldest.swing_line)
            if not na(oldest.div_label)
                label.delete(oldest.div_label)

    // Check Asset 2
    if enable_sec_2
        new_sp_2 = SwingPoint.new(bar_index - swing_n, time_at_pivot, pl, sec_low_at_pivot_2, na, na, false, na)
        if array.size(prim_lows_2) > 0
            SwingPoint sp_prev = array.get(prim_lows_2, array.size(prim_lows_2) - 1)
            prim_diff = pl - sp_prev.price
            sec_diff = new_sp_2.sec_price - sp_prev.sec_price
            is_divergent = (prim_diff > 0 and sec_diff <= 0) or (prim_diff < 0 and sec_diff >= 0) or (prim_diff == 0 and sec_diff != 0)
            if is_divergent and not na(sp_prev.sec_price) and not na(new_sp_2.sec_price)
                new_sp_2.inv_level := inval_level_type == "Highest/Lowest of the Swings" ? math.min(sp_prev.price, new_sp_2.price) : new_sp_2.price
                new_sp_2.swing_line := line.new(x1=sp_prev.time_val, y1=sp_prev.price, x2=new_sp_2.time_val, y2=new_sp_2.price, xloc=xloc.bar_time, color=smt_color, width=line_width, style=line.style_solid)
                if show_labels
                    lbl_text = "SMT:" + f_get_short_symbol(sec_symbol_2)
                    lbl_x = lbl_pos == "Center of Line" ? math.round((sp_prev.time_val + new_sp_2.time_val) / 2) : new_sp_2.time_val
                    offset = atr_val * 0.3
                    lbl_y = lbl_pos == "Center of Line" ? ((sp_prev.price + new_sp_2.price) / 2) - offset : new_sp_2.price - offset
                    new_sp_2.div_label := label.new(x=lbl_x, y=lbl_y, text=lbl_text, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=lbl_text_color, style=label.style_none, size=f_get_lbl_size(lbl_size))
                alert("Bullish SMT Divergence: " + syminfo.ticker + " vs " + sec_symbol_2, alert.freq_once_per_bar_close)
        array.push(prim_lows_2, new_sp_2)
        if array.size(prim_lows_2) > max_signals_to_keep
            SwingPoint oldest = array.shift(prim_lows_2)
            if not na(oldest.swing_line)
                line.delete(oldest.swing_line)
            if not na(oldest.div_label)
                label.delete(oldest.div_label)

// =========================================================================
// 7. SMT Invalidation Engine
// =========================================================================

// Resolve price values used for invalidation check based on trigger settings
inval_check_val_high = inval_source == "Close" ? close : high
inval_check_val_low  = inval_source == "Close" ? close : low

// Process invalidations for both assets using our helpers
f_process_high_invalidations(prim_highs_1, inval_check_val_high, show_invalidated, smt_color, lbl_text_color)
f_process_high_invalidations(prim_highs_2, inval_check_val_high, show_invalidated, smt_color, lbl_text_color)

f_process_low_invalidations(prim_lows_1, inval_check_val_low, show_invalidated, smt_color, lbl_text_color)
f_process_low_invalidations(prim_lows_2, inval_check_val_low, show_invalidated, smt_color, lbl_text_color)
````
