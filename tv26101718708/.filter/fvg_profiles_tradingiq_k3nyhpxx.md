# FVG Profiles [TradingIQ]

- url: https://www.tradingview.com/script/k3NYHPxX-FVG-Profiles-TradingIQ/
- type: indicator
- pine_id: PUB;fd462151022d41039a014cccc926474b
- version: 1.0

## Description

Hello Traders!

🔹[b]FVG Profiles [TradingIQ][/b]

FVG Profiles is a [b]fair value gap analysis tool[/b] designed to go beyond simply drawing FVG boxes on the chart.

Instead of treating every fair value gap the same, this indicator evaluates each FVG using:

[list]
[*]gap size
[*]volume behind the gap
[*]time-of-day context
[*]remaining unfilled volume
[*]active FVG clustering
[*]bullish vs bearish FVG dominance
[*]master histogram structure
[*]local maxima gap zones
[/list]

It focuses on answering a deeper question:

[b]Where are the most important active imbalance zones on the chart?[/b]

And more importantly:

[i]Which gaps still have meaningful volume left behind them?[/i]


🔹[b]What the indicator shows[/b]

🔸[b]Bullish & Bearish Fair Value Gaps[/b]

The indicator detects both bullish and bearish fair value gaps directly on the chart.

A bullish FVG is detected when price leaves an upside imbalance.

A bearish FVG is detected when price leaves a downside imbalance.

These gaps are then tracked as active zones until they are mitigated, expired, or fully consumed by later price action.

This allows you to see:

[list]
[*]where bullish imbalances formed
[*]where bearish imbalances formed
[*]which FVGs are still active
[*]which FVGs have been partially filled
[*]which FVGs have been fully mitigated
[/list]


🔸[b]Time-of-Day Filtering[/b]

One of the most important parts of this indicator is that it does not only ask:

[i]“Did a fair value gap form?”[/i]

It also asks:

[i]“Was this fair value gap meaningful compared to what normally happens at this time of day?”[/i]

The script tracks rolling time-of-day statistics for both:

[list]
[*]volume
[*]gap height
[/list]

This helps compare the current FVG against historical activity from the same time of day.

The goal is to avoid treating normal market noise the same as statistically meaningful imbalance.


🔸[b]Gap Strictness & Volume Strictness[/b]

The indicator includes strictness filters for both gap size and volume.

These filters use z-score style thresholds to determine whether a new FVG is significant enough to display.

Available strictness levels include:

[list]
[*]None
[*]Low
[*]Medium
[*]High
[*]Extreme
[/list]

Higher strictness means fewer gaps will qualify.

Lower strictness means more gaps will be shown.

This allows you to choose whether you want a broader view of market imbalance or only the most statistically significant FVGs.


🔸[b]Remaining FVG Volume[/b]

Each detected FVG begins with an initial volume value.

As future candles trade back into the FVG zone, the script estimates how much of that gap volume has been consumed.

This allows each FVG to behave more like a living zone instead of a static box.

The indicator tracks:

[list]
[*]initial FVG volume
[*]remaining FVG volume
[*]partial mitigation
[*]full mitigation
[*]bullish remaining volume
[*]bearish remaining volume
[/list]

As price overlaps the FVG, the remaining volume is reduced proportionally.

This helps show whether a gap is still meaningful or whether it has already been mostly consumed.


🔸[b]FVG Box Visualization[/b]

Active fair value gaps are displayed directly on the chart.

The FVG boxes update as the gap is mitigated.

When volume remains inside the zone, the box continues to show the active imbalance area.

When the FVG is fully mitigated or expires, it is removed from the chart.

Optional volume text can also be displayed inside the FVG box.

This helps you quickly see:

[list]
[*]how much volume remains in the gap
[*]which gaps are still active
[*]which zones are being consumed
[*]where price is interacting with imbalance
[/list]


🔸[b]Master FVG Histogram[/b]

The Master Histogram is the main profile-style visualization.

Instead of only looking at individual FVGs, the indicator aggregates all active FVG zones into a single histogram.

This histogram shows where active bullish and bearish FVG volume is clustered across price.

It helps answer:

[b]Where is active imbalance volume concentrated right now?[/b]

The histogram is drawn to the right of price and can be customized with:

[list]
[*]number of bins
[*]histogram offset
[*]maximum width
[*]KDE smoothing bandwidth
[*]transparency
[*]bullish colors
[*]bearish colors
[/list]


🔸[b]Bullish vs Bearish FVG Dominance[/b]

The Master Histogram separates bullish and bearish FVG volume.

Each price bin is colored based on whether bullish or bearish FVG volume is dominant at that level.

This allows you to quickly identify:

[list]
[*]bullish imbalance clusters
[*]bearish imbalance clusters
[*]zones where one side dominates
[*]areas where active FVG volume is concentrated
[/list]

Instead of asking only:

[i]“Where is the nearest fair value gap?”[/i]

you can ask:

[i]“Where are active FVGs clustering across the chart?”[/i]


🔸[b]KDE Smoothing[/b]

The histogram includes optional smoothing using an Epanechnikov Kernel Density Estimation model.

This helps reduce noisy, blocky histogram behavior and creates a smoother profile of active FVG concentration.

Higher bandwidth creates a smoother histogram.

Lower bandwidth keeps the histogram closer to the raw FVG volume distribution.

This is useful when you want the histogram to behave more like a profile instead of a fragmented set of isolated bins.


🔸[b]Gap Zones / Local Maxima[/b]

The indicator can also detect local maxima inside the Master Histogram.

These are price areas where active FVG volume is locally concentrated compared to nearby bins.

When enabled, the indicator projects these levels left across the chart as Gap Zone lines.

This helps highlight:

[list]
[*]major active imbalance clusters
[*]high-concentration FVG zones
[*]potential reaction areas
[*]levels where multiple active gaps may overlap
[/list]

The Gap Zone Percentile setting controls how selective these lines are.

A higher percentile shows fewer, more significant zones.

A lower percentile shows more potential gap zones.


🔹[b]How to read it[/b]

Each FVG box represents an active imbalance.

The Master Histogram shows where active FVG volume is concentrated across all currently tracked gaps.

The Gap Zone lines highlight local peaks in the active FVG volume profile.

Together, these views help shift your thinking from:

[i]“There is a fair value gap here.”[/i]

to:

[i]“This is where active imbalance volume is still concentrated.”[/i]


🔹[b]Example interpretations[/b]

[list]
[*]large bullish FVG + high remaining volume → active upside imbalance still present
[*]bearish FVG cluster above price → potential overhead imbalance zone
[*]histogram peak near current price → price is trading into concentrated active gap volume
[*]gap zone line aligns with structure → possible high-interest reaction area
[*]FVG box fading or disappearing → gap has been consumed, mitigated, or expired
[*]many active gaps clustered together → imbalance zone may be more important than a single isolated FVG
[/list]


🔹[b]Why this indicator is useful[/b]

FVG Profiles gives you a structured way to analyze fair value gaps as dynamic volume zones.

It helps you see:

[list]
[*]which FVGs are still active
[*]which gaps have meaningful volume behind them
[*]where FVG volume is clustering
[*]whether bullish or bearish imbalance dominates a zone
[*]how price is consuming active gaps over time
[*]where local maxima gap zones appear
[/list]

Instead of only drawing static FVG boxes, this tool attempts to quantify and profile the active imbalance still remaining in the market.


🔹[b]Best use cases[/b]

[list]
[*]tracking active fair value gaps
[*]finding clustered imbalance zones
[*]filtering out insignificant gaps
[*]studying FVG mitigation
[*]identifying potential reaction levels
[*]combining FVG analysis with market structure
[*]enhancing liquidity, imbalance, or price-action models
[/list]


🔹[b]Inputs you can customize[/b]

[list]
[*]Master Profile Bins
[*]Histogram Right Offset
[*]Histogram Max Width
[*]KDE Smoothing Bandwidth
[*]Max FVGs
[*]Max FVG Age
[*]Gap Strictness
[*]Volume Strictness
[*]Time-of-Day Memory Length
[*]Show FVG Boxes
[*]Show Master Histogram
[*]Show Gap Zones
[*]Gap Zone Percentile
[*]Show FVG Volume Text
[*]Master Alpha
[*]bullish and bearish histogram colors
[*]gap zone color
[/list]


🔹[b]Important note[/b]

This script uses volume, gap size, and time-of-day statistics to evaluate fair value gaps.

This means:

[list]
[*]FVG significance depends on the selected strictness settings
[*]time-of-day averages depend on the available chart history
[*]volume behavior can vary between symbols and sessions
[*]the Master Histogram only represents currently active tracked FVGs
[*]gap zones are analytical reference levels, not predictive signals
[/list]

This indicator is not a trading system by itself.

It is a framework for analyzing where active fair value gap volume remains and how those imbalances cluster across price.


[b]Closing Notes[/b]

FVG Profiles is built to turn fair value gaps from static boxes into a more complete imbalance profile.

It helps you see not only where gaps formed, but where active FVG volume still remains.

As always, thank you TradingView!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingIQ

//@version=6
indicator("FVG Profiles [TradingIQ]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// HEAD {

// }

// ---------------------------------------------------- CONSTANTS --------------------------------------------------- {
string G_SET = "Settings"
string G_FIL = "Filters"
string G_AES = "Aesthetics"


string TT_BIN = """Number of horizontal bins used to calculate the volume profile histogram."""
string TT_OFF = """How many bars to the right of the current price the histogram will be drawn."""
string TT_KDE = """The Epanechnikov Kernel Density Estimation bandwidth. Higher values produce a smoother histogram."""
string TT_MAX = """The maximum number of active FVG boxes that will be rendered on the chart at any time."""
string TT_AGE = """The maximum age (in bars) an FVG can reach before it is forcibly expired."""
string TT_GAP = """The statistical significance required for an FVG gap height compared to the time-of-day average."""
string TT_VOL = """The statistical significance required for an FVG's volume compared to the time-of-day average."""
string TT_TOD = """The memory length for the rolling Time-of-Day aggregation array."""
string TT_BOX = """Toggles the visibility of the FVG zones."""
string TT_HST = """Toggles the visibility of the Master Histogram."""
string TT_GZN = """Toggles the visibility of the Local Maxima Gap Zone lines."""
string TT_GZP = """The percentile threshold (0-100) required for a local maxima peak to cast a Gap Zone line."""
string TT_FVT = """Toggles the numerical volume text inside the FVG boxes."""

enum Event
    bullish_fvg = "Bullish FVG"
    bearish_fvg = "Bearish FVG"
    NAE = "NOT AN EVENT"

enum Strictness
    none = "None"
    low = "Low"
    medium = "Medium"
    high = "High"
    extreme = "Extreme"

method to_z(Strictness self)=>
    switch self
        Strictness.extreme => 2.0
        Strictness.high => 1.0
        Strictness.medium => 0.5
        Strictness.low => 0.0
        => -99.0
// }

// ----------------------------------------------------- HELPERS ---------------------------------------------------- {
method scale_alpha(float self, float alpha = 80)=>
    float invert = 100 - alpha
    self * invert / 100

method new_alpha(color self, float alpha = 80)=>
    color.new(self, alpha + color.t(self).scale_alpha(alpha))

epanechnikov_kernel(float centered_index, float bandwidth) =>
    float ratio = centered_index / bandwidth
    switch math.abs(ratio) <= 1
        true => 0.75 * (1 - math.pow(ratio, 2))
        false => 0.0

method apply_kde(float[] arr, float bandwidth)=>
    float[] res = array.new<float>(arr.size(), 0.0)
    if bandwidth <= 0
        for i = 0 to arr.size() - 1
            res.set(i, arr.get(i))
    else
        for i = 0 to arr.size() - 1
            float sum = 0.0
            float weight_sum = 0.0
            int w = math.round(math.max(1, bandwidth))
            for j = math.max(0, i - w) to math.min(arr.size() - 1, i + w)
                float weight = epanechnikov_kernel(j - i, bandwidth)
                sum += arr.get(j) * weight
                weight_sum += weight
            res.set(i, weight_sum > 0 ? sum / weight_sum : 0.0)
    res
// }

// --------------------------------------------------- BASE TYPES --------------------------------------------------- {
type Key
    int m = minute
    int h = hour

type Vec
    float[] values

type DataArray
    Vec[] data
    bool[] valid

method maintain(float[] self, int length)=>
    if length > 0 and self.size() >= length
        self.pop()

method add_pop(float[] self, float value, int length)=>
    self.maintain(length)
    self.unshift(value)

init_data()=>
    var int size = 1440 / timeframe.multiplier
    var const Vec[] data = array.new<Vec>(size)
    var const bool[] valid = array.new<bool>(size, false)
    DataArray.new(data, valid)

key_to_hash(Key key)=>
    int hash = int((key.h * 60 + key.m) / timeframe.multiplier)
    hash

hash_now()=> 
    key_to_hash(Key.new())

method add_element(DataArray self, float source, int length)=>
    Vec[] data = self.data
    bool[] valid = self.valid
    int idx = hash_now()
    if not na(source)
        if valid.get(idx)
            data.get(idx).values.add_pop(source, length)
        else
            data.set(idx, Vec.new(array.from(source)))
            valid.set(idx, true)

method get_average(DataArray self, Key key)=>
    float result = na
    int idx = key_to_hash(key)
    if self.valid.get(idx)
        result := self.data.get(idx).values.avg()
    result
// }



// ----------------------------------------------------- CONFIG ----------------------------------------------------- {
type Config
    int num_bins
    int hist_offset
    int hist_max_width
    float hist_bandwidth
    int max_fvgs
    int max_age
    float gap_z_thresh
    float vol_z_thresh
    int tod_len
    bool show_boxes
    bool show_hist
    bool show_gap_zones
    float gap_zone_percentile
    bool show_fvg_vol
    int master_alpha
    color gap_zone_color
    color bull_max_col
    color bull_min_col
    color bear_max_col
    color bear_min_col
// }

// ---------------------------------------------------- VISUALS ----------------------------------------------------- {
type FVGVisuals
    box fvg_box

method update(FVGVisuals self, float top, float bottom, float rem, float initial_vol, Event event_type, Config config)=>
    self.fvg_box.set_right(bar_index)
    float ratio = initial_vol > 0 ? (rem / initial_vol) : 0
    color base_color = event_type == Event.bullish_fvg ? config.bull_max_col : config.bear_max_col
    
    color bg = config.show_boxes ? color.new(base_color, (1.0 - ratio) * 50 + 50) : na
    color bd = config.show_boxes ? color.new(base_color, 50) : na
    
    self.fvg_box.set_bgcolor(bg)
    self.fvg_box.set_border_color(bd)
    self.fvg_box.set_top(top)
    self.fvg_box.set_bottom(bottom)
    
    if config.show_fvg_vol and rem > 0
        self.fvg_box.set_text(str.tostring(rem, format.volume))
        self.fvg_box.set_text_color(color.new(base_color, 0))
        self.fvg_box.set_text_size(size.small)
        self.fvg_box.set_text_halign(text.align_right)

method delete(FVGVisuals self)=>
    if not na(self.fvg_box)
        self.fvg_box.delete()


type HistogramVisuals
    box[] drawn_boxes
    line[] gap_zone_lines
    polyline[] border_lines

method clear(HistogramVisuals self)=>
    while self.drawn_boxes.size() > 0
        box b = self.drawn_boxes.pop()
        b.delete()
        
    while self.gap_zone_lines.size() > 0
        line l = self.gap_zone_lines.pop()
        l.delete()
        
    while self.border_lines.size() > 0
        polyline p = self.border_lines.pop()
        p.delete()
// }

// ----------------------------------------------------- DOMAIN ----------------------------------------------------- {
type FVGProfile
    float initial_top
    float initial_bottom
    float top
    float bottom
    int start_time
    float initial_vol
    int snapshot_bar
    int start_bar
    Event event_type
    bool active
    float total_bull_vol
    float total_bear_vol
    float snap_bull_vol
    float snap_bear_vol
    FVGVisuals visuals

method total_remaining(FVGProfile self)=>
    self.total_bull_vol + self.total_bear_vol

method eat_volume(FVGProfile self, float c_high, float c_low, float c_vol)=>
    if self.snapshot_bar != bar_index
        self.snap_bull_vol := self.total_bull_vol
        self.snap_bear_vol := self.total_bear_vol
        self.snapshot_bar := bar_index
    
    self.total_bull_vol := self.snap_bull_vol
    self.total_bear_vol := self.snap_bear_vol
    
    float c_overlap_top = math.min(c_high, self.top)
    float c_overlap_bot = math.max(c_low, self.bottom)
    float c_overlap_h = math.max(0, c_overlap_top - c_overlap_bot)
    
    if c_overlap_h > 0
        float fvg_h = self.top - self.bottom
        if fvg_h > 0
            float c_h = math.max(syminfo.mintick, c_high - c_low)
            float v_eaten = c_vol * (c_overlap_h / c_h)
            
            float curr_total = self.total_bull_vol + self.total_bear_vol
            if curr_total > 0
                float bull_ratio = self.total_bull_vol / curr_total
                float bear_ratio = self.total_bear_vol / curr_total
                
                self.total_bull_vol := math.max(0, self.total_bull_vol - (v_eaten * bull_ratio))
                self.total_bear_vol := math.max(0, self.total_bear_vol - (v_eaten * bear_ratio))
                
        if self.event_type == Event.bullish_fvg
            self.top := math.min(self.top, c_low)
        else if self.event_type == Event.bearish_fvg
            self.bottom := math.max(self.bottom, c_high)
            
    if self.top <= self.bottom or (self.total_bull_vol + self.total_bear_vol) <= 1e-6
        self.active := false

method mitigate_check(FVGProfile self, float c_high, float c_low)=>
    if self.event_type == Event.bullish_fvg
        if c_low < self.initial_bottom
            self.active := false
    else if self.event_type == Event.bearish_fvg
        if c_high > self.initial_top
            self.active := false

method update_visuals(FVGProfile self, Config config)=>
    if self.active
        self.visuals.update(self.top, self.bottom, self.total_remaining(), self.initial_vol, self.event_type, config)
    else
        self.visuals.delete()

method pop_for(FVGProfile[] self, int min_size = 0, int max_size = 0)=>
    if self.size() > max_size
        while self.size() > min_size
            FVGProfile p = self.pop()
            p.visuals.delete()
// }

// ---------------------------------------------------- PIPELINE ---------------------------------------------------- {
update_tod_statistics(DataArray vol_data, DataArray gap_data, Config config)=>
    float chart_gap_h = (low > high[2]) ? low - high[2] : (high < low[2]) ? low[2] - high : 0
    vol_data.add_element(volume, config.tod_len)

    if chart_gap_h > 0 and barstate.isconfirmed
        gap_data.add_element(chart_gap_h, config.tod_len)

evaluate_new_fvg(FVGProfile[] profiles, DataArray gap_data, DataArray vol_data, Config config)=>
    bool is_bull = low > high[2]
    bool is_bear = high < low[2]
    
    if barstate.isconfirmed and (is_bull or is_bear)
        float top = is_bull ? low : is_bear ? low[2] : na
        float bottom = is_bull ? high[2] : is_bear ? high : na
        float f_gap_h = top - bottom
        
        float c_h = math.max(syminfo.mintick, high[1] - low[1])
        float f_c_vol = volume[1]
        int f_time = time[1]
        
        float expected_vol = 0
        float expected_gap = 0
        float aggregated_stdev = 0
        float vol_stdev = 0
        
        Key k = Key.new(minute(f_time), hour(f_time))
        expected_vol := nz(vol_data.get_average(k))
        expected_gap := nz(gap_data.get_average(k))
        
        int hash = key_to_hash(k)
        if gap_data.valid.get(hash)
            aggregated_stdev := gap_data.data.get(hash).values.stdev()
        if vol_data.valid.get(hash)
            vol_stdev := vol_data.data.get(hash).values.stdev()
        
        float vol_z = vol_stdev > 0 ? (f_c_vol - expected_vol) / vol_stdev : 0
        bool vol_pass = config.vol_z_thresh < -10.0 or (f_c_vol > 0 and vol_z >= config.vol_z_thresh)
        
        float z_score = aggregated_stdev > 0 ? (f_gap_h - expected_gap) / aggregated_stdev : 0
        bool gap_pass = config.gap_z_thresh < -10.0 or (f_gap_h > 0 and z_score >= config.gap_z_thresh)
        
        if vol_pass and gap_pass
            Event e = is_bull ? Event.bullish_fvg : Event.bearish_fvg
            int left_x = bar_index - 1
            
            color base_c = is_bull ? config.bull_max_col : config.bear_max_col
            color bg = config.show_boxes ? color.new(base_c, 10) : na
            color bd = config.show_boxes ? color.new(base_c, 50) : na
            box b = box.new(left_x, top, bar_index, bottom, border_color=bd, bgcolor=bg)
            FVGVisuals visuals = FVGVisuals.new(b)
            
            float total_bull = is_bull ? f_c_vol : 0
            float total_bear = is_bear ? f_c_vol : 0

            FVGProfile p = FVGProfile.new(top, bottom, top, bottom, f_time, f_c_vol, bar_index, bar_index, e, true, total_bull, total_bear, total_bull, total_bear, visuals)
            
            profiles.unshift(p)
            profiles.pop_for(config.max_fvgs, config.max_fvgs + 2) 


mitigate_active_fvgs(FVGProfile[] profiles, Config config)=>
    if profiles.size() > 0
        for i = profiles.size() - 1 to 0
            FVGProfile p = profiles.get(i)
            if p.active
                if bar_index - p.start_bar >= config.max_age
                    p.active := false
                else
                    p.eat_volume(high, low, volume)
                    p.mitigate_check(high, low)
                
                p.update_visuals(config)
                
                if not p.active
                    p.visuals.delete()
                    profiles.remove(i)

render_histogram(HistogramVisuals hist_vis, FVGProfile[] profiles, Config config)=>
    hist_vis.clear()
    
    if config.show_hist and profiles.size() > 0
        float global_top = na
        float global_bottom = na
        
        for p in profiles
            if p.active
                global_top := na(global_top) ? p.initial_top : math.max(global_top, p.initial_top)
                global_bottom := na(global_bottom) ? p.initial_bottom : math.min(global_bottom, p.initial_bottom)
        
        if not na(global_top) and not na(global_bottom)
            float step = (global_top - global_bottom) / config.num_bins
            float[] bull_vols = array.new<float>(config.num_bins, 0.0)
            float[] bear_vols = array.new<float>(config.num_bins, 0.0)
            
            for p in profiles
                if p.active
                    float l_bull = p.total_bull_vol
                    float l_bear = p.total_bear_vol
                    float l_vol = l_bull + l_bear
                    
                    if l_vol > 0
                        float fvg_h = p.top - p.bottom
                        if fvg_h > 0
                            for i = 0 to config.num_bins - 1
                                float bin_bot = global_bottom + (i * step)
                                float bin_top = bin_bot + step
                                
                                float overlap_top = math.min(p.top, bin_top)
                                float overlap_bot = math.max(p.bottom, bin_bot)
                                float overlap = math.max(0, overlap_top - overlap_bot)
                                
                                if overlap > 0
                                    float ratio = overlap / fvg_h
                                    bull_vols.set(i, bull_vols.get(i) + (l_bull * ratio))
                                    bear_vols.set(i, bear_vols.get(i) + (l_bear * ratio))
            
            bull_vols := bull_vols.apply_kde(config.hist_bandwidth)
            bear_vols := bear_vols.apply_kde(config.hist_bandwidth)
            
            float max_bull_vol = bull_vols.max()
            float max_bear_vol = bear_vols.max()
            float max_total_vol = math.max(max_bull_vol, max_bear_vol)
            
            int anchor_x = bar_index + config.hist_offset + config.hist_max_width
            
            float[] total_vols = array.new<float>(config.num_bins, 0.0)
            for i = 0 to config.num_bins - 1
                total_vols.set(i, bull_vols.get(i) + bear_vols.get(i))
                
            float[] sorted_vols = total_vols.copy()
            sorted_vols.sort()
            int p_index = math.round((config.num_bins - 1) * (config.gap_zone_percentile / 100.0))
            float vol_threshold = sorted_vols.get(p_index)
            
            bool in_island = false
            float island_top = na
            array<chart.point> island_points = na
                
            for i = 0 to config.num_bins - 1
                float bin_bot = global_bottom + (i * step)
                float bin_top = bin_bot + step
                float bull_v = bull_vols.get(i)
                float bear_v = bear_vols.get(i)
                float total_v = total_vols.get(i)
                
                if total_v > 0
                    int box_width_bars = max_total_vol > 0 ? math.round(config.hist_max_width * (total_v / max_total_vol)) : 0
                    box_width_bars := math.max(1, box_width_bars)
                    
                    int right_x = anchor_x
                    int left_x = anchor_x - box_width_bars
                    
                    bool is_bull_dom = bull_v >= bear_v
                    color max_c = is_bull_dom ? config.bull_max_col : config.bear_max_col
                    color min_c = is_bull_dom ? config.bull_min_col : config.bear_min_col
                    float dom_v = is_bull_dom ? bull_v : bear_v
                    float max_dom_vol = is_bull_dom ? max_bull_vol : max_bear_vol
                    
                    float ratio = max_dom_vol > 0 ? (dom_v / max_dom_vol) : 0
                    color base_c = color.from_gradient(ratio, 0, 1, min_c, max_c)
                    color final_c = color.new(base_c, config.master_alpha)
                    
                    box b = box.new(left_x, bin_top, right_x, bin_bot, border_color=na, bgcolor=final_c)
                    hist_vis.drawn_boxes.push(b)
                    
                    if not in_island
                        in_island := true
                        island_points := array.new<chart.point>()
                        island_points.push(chart.point.from_index(anchor_x, bin_bot))
                        
                    island_points.push(chart.point.from_index(left_x, bin_bot))
                    island_points.push(chart.point.from_index(left_x, bin_top))
                    island_top := bin_top
                    
                    if config.show_gap_zones and total_v >= vol_threshold
                        bool is_peak = true
                        if i > 0 and total_vols.get(i-1) >= total_v
                            is_peak := false
                        if i < config.num_bins - 1 and total_vols.get(i+1) > total_v
                            is_peak := false
                            
                        if is_peak
                            float bin_mid = (bin_bot + bin_top) / 2
                            
                            line l3 = line.new(anchor_x - 1, bin_mid, anchor_x, bin_mid, color=config.gap_zone_color.new_alpha(85), style=line.style_solid, width=5, extend=extend.left)
                            line l2 = line.new(anchor_x - 1, bin_mid, anchor_x, bin_mid, color=config.gap_zone_color.new_alpha(75), style=line.style_solid, width=3, extend=extend.left)
                            line l1 = line.new(anchor_x - 1, bin_mid, anchor_x, bin_mid, color=config.gap_zone_color, style=line.style_solid, width=1, extend=extend.left)
                            
                            hist_vis.gap_zone_lines.push(l3)
                            hist_vis.gap_zone_lines.push(l2)
                            hist_vis.gap_zone_lines.push(l1)

                if (total_v == 0 or i == config.num_bins - 1) and in_island
                    in_island := false
                    island_points.push(chart.point.from_index(anchor_x, island_top))
                    polyline p = polyline.new(island_points, closed=true, line_color=color.black, line_width=4)
                    hist_vis.border_lines.push(p)

// }

// ---------------------------------------------------- EXECUTOR ---------------------------------------------------- {
main(Config config) =>
    var DataArray vol_data = init_data()
    var DataArray gap_data = init_data()
    var FVGProfile[] profiles = array.new<FVGProfile>()
    var HistogramVisuals hist_vis = HistogramVisuals.new(array.new<box>(), array.new<line>(), array.new<polyline>())
    
    update_tod_statistics(vol_data, gap_data, config)
    evaluate_new_fvg(profiles, gap_data, vol_data, config)
    mitigate_active_fvgs(profiles, config)
    
    if barstate.islast
        render_histogram(hist_vis, profiles, config)
// }


// ------------------------------------------------- INDICATOR INPUTS ----------------------------------------------- {
int i_num_bins = input.int(50, "Master Profile Bins", minval=1, group = G_SET, tooltip = TT_BIN)
int i_hist_offset = input.int(1, "Histogram Right Offset (Bars)", minval=1, group = G_SET, tooltip = TT_OFF)
int i_hist_max_width = input.int(20, "Histogram Max Width (Bars)", minval=1, group = G_SET)
float i_hist_bandwidth = input.float(2.5, "KDE Smoothing Bandwidth", minval=0.0, step=0.5, group = G_SET, tooltip = TT_KDE)
int i_max_fvgs = input.int(20, "Max FVGs", minval=1, group = G_SET, tooltip = TT_MAX)
int i_max_age = input.int(500, "Max FVG Age (Bars)", minval=1, group = G_SET, tooltip = TT_AGE)

Strictness i_gap_strict = input.enum(Strictness.low, "Gap Strictness (Z-Score)", group=G_FIL, tooltip = TT_GAP)
Strictness i_vol_strict = input.enum(Strictness.low, "Volume Strictness (Z-Score)", group=G_FIL, tooltip = TT_VOL)
int i_tod_len = input.int(5, "Time-of-Day Memory Length", group = G_FIL, tooltip = TT_TOD)

bool i_show_boxes = input.bool(true, "Show FVG Boxes", group = G_AES, tooltip = TT_BOX)
bool i_show_hist = input.bool(true, "Show Master Histogram", group = G_AES, tooltip = TT_HST)
bool i_show_gap_zones = input.bool(true, "Show Gap Zones (Local Maxima)", group = G_AES, tooltip = TT_GZN)
float i_gap_zone_percentile = input.float(80.0, "Gap Zone Percentile", minval=0.0, maxval=100.0, step=5.0, group = G_AES, tooltip = TT_GZP)
bool i_show_fvg_vol = input.bool(true, "Show FVG Volume Text", group = G_AES, tooltip = TT_FVT)
int i_master_alpha = input.int(20, "Master Alpha", minval=0, maxval=100, group = G_AES)

color i_gap_zone_color = input.color(#ffffff, "Gap Zone Color", group = G_AES)
color i_bull_max_col = input.color(#4fb1ff, "Bullish Max Vol Color", group = G_AES)
color i_bull_min_col = input.color(#b7dfff, "Bullish Min Vol Color", group = G_AES)
color i_bear_max_col = input.color(#8167f8, "Bearish Max Vol Color", group = G_AES)
color i_bear_min_col = input.color(#d8d0fe, "Bearish Min Vol Color", group = G_AES)

float p_gap_thresh = i_gap_strict.to_z()
float p_vol_thresh = i_vol_strict.to_z()

Config config = Config.new(
       i_num_bins
     , i_hist_offset
     , i_hist_max_width
     , i_hist_bandwidth
     , i_max_fvgs
     , i_max_age
     , p_gap_thresh
     , p_vol_thresh
     , i_tod_len
     , i_show_boxes
     , i_show_hist
     , i_show_gap_zones
     , i_gap_zone_percentile
     , i_show_fvg_vol
     , i_master_alpha
     , i_gap_zone_color
     , i_bull_max_col
     , i_bull_min_col
     , i_bear_max_col
     , i_bear_min_col
     )
// }

// ------------------------------------------------------- RUN ------------------------------------------------------ {
main(config)
// }
````
