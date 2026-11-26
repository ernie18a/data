# Sessions Flow [Cartel Console]

- url: https://www.tradingview.com/script/GSmLdCby-Sessions-Flow-Cartel-Console/
- type: indicator
- pine_id: PUB;ecd0e659cc944e52a6096887dd2325fa
- version: 1.0

## Description

Sessions Flow [Cartel Console]

# Overview

Sessions Flow [Cartel Console] is a session-based market activity visualization tool designed to provide a detailed view of how trading volume is distributed throughout the major global forex and index trading sessions.

Rather than displaying volume as a single aggregated value, the indicator breaks each session into multiple price levels and visualizes where trading activity was concentrated during that session. This allows traders to study session structure, identify high-participation and low-participation areas, and compare how different sessions interact with price.

The indicator automatically tracks and analyzes the four major trading sessions:

• Sydney Session
• Tokyo Session
• London Session
• New York Session

Each session is processed independently and displayed directly on the chart using volume distribution heatmaps, volume profiles, Point of Control calculations, and Value Area measurements.

---

# Core Features

## Session Detection

The indicator automatically identifies the start and end of each selected trading session and creates a dedicated session structure on the chart.

Users can enable or disable individual sessions and customize session times according to their preferences.

Supported sessions include:

• Sydney
• Tokyo
• London
• New York

---

### Session Heatmap

Each session contains a heatmap that displays the relative distribution of trading activity throughout the session range.

The heatmap highlights:

• Areas with greater participation
• Areas with moderate participation
• Areas with lower participation

This provides a quick visual overview of where the market spent the most and least volume during a session.

Heatmap density and transparency settings can be fully customized.

---

### Session Volume Profile

For every session, the indicator constructs a volume profile based on price distribution inside the session range.

The profile is displayed as a side histogram showing how activity was distributed vertically across different price levels.

This can help traders observe:

• High-volume areas
• Low-volume areas
• Session acceptance regions
• Session rejection regions

The profile width and display settings are adjustable.

---

## Point of Control (POC)

The Point of Control represents the price level that accumulated the highest amount of volume during a session.

The indicator automatically calculates and plots the POC for each completed session.

POC levels often serve as useful reference points when reviewing historical session activity and market structure.

---

### Value Area Analysis

The indicator calculates a configurable Value Area based on the percentage of session volume selected by the user.

Displayed levels include:

• Value Area High (VAH)
• Value Area Low (VAL)

These levels help visualize the region where the majority of session activity occurred.

The default setting uses a 70% Value Area, but users may customize this value.

---

### Historical Session Management

To maintain chart performance, the indicator includes controls for:

• Maximum detailed sessions displayed
• Historical session lookback period
• Simplified rendering of older sessions

Recent sessions can retain full heatmap and profile information while older sessions transition into lightweight background structures.

This allows extensive historical analysis without excessive chart clutter.

---

### Active Session Dashboard

A built-in dashboard displays the currently active trading sessions in real time.

The dashboard provides:

• Active session names
• Live session status indicators

This makes it easy to determine which global markets are currently open without leaving the chart.

---

## Customization Options

The indicator includes a wide range of configurable settings:

### Session Settings

• Individual session visibility
• Custom session times

### Heatmap Settings

• Heatmap resolution
• Number of price bins
• Density visualization controls

### Volume Profile Settings

• Histogram width
• Detailed session limits

### Value Area Settings

• Value Area percentage
• VA visibility controls

### Styling Settings

• Session colors
• Border transparency
• Historical session appearance
• Dashboard position

---

## Intended Usage

Sessions Flow is designed for traders who want to study how market activity develops during different trading sessions.

It can be used for:

• Session analysis
• Market structure observation
• Historical session review
• Volume distribution study
• Contextual chart analysis

The indicator focuses on visualization and analysis rather than signal generation.

---

## Disclaimer

This indicator is intended for educational and analytical purposes only. It does not provide financial advice, trading recommendations, or guaranteed outcomes. Trading involves risk, and users should perform their own analysis before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CartelConsole

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
//@version=6
indicator("Sessions Flow [Cartel Console]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Colors ---
color TOKYO_COLOR  = color.rgb(255, 217, 0) // Gold
color SYDNEY_COLOR = color.rgb(0, 230, 119, 1) // Green
color LONDON_COLOR = color.rgb(0, 174, 255, 2) // Blue
color NY_COLOR     = color.rgb(255, 145, 0, 1) // Orange

// --- Inputs ---
group_sessions = "Sessions (Timezone: UTC)"
show_tokyo     = input.bool(true, "Tokyo", inline = "t", group = group_sessions)
tokyo_sess     = input.session("0000-0900", "", inline = "t", group = group_sessions)

show_sydney    = input.bool(true, "Sydney", inline = "s", group = group_sessions)
sydney_sess    = input.session("2100-0600", "", inline = "s", group = group_sessions)

show_london    = input.bool(true, "London", inline = "l", group = group_sessions)
london_sess    = input.session("0800-1700", "", inline = "l", group = group_sessions)

show_ny        = input.bool(true, "New York", inline = "n", group = group_sessions)
ny_sess        = input.session("1300-2200", "", inline = "n", group = group_sessions)

group_heatmap = "Heatmap & Volume Profile Settings"
num_bins      = input.int(25, "Heatmap Bins", minval = 5, maxval = 100, group = group_heatmap, tooltip = "Number of price levels. Lower values allow more historical sessions to be shown.")
va_perc       = input.int(70, "Value Area (%)", minval = 0, maxval = 100, group = group_heatmap)
max_detailed  = input.int(20, "Max Detailed Sessions", minval = 1, maxval = 50, group = group_heatmap, tooltip = "Number of recent sessions to display Heatmap and VP. Default 20 is approx 5 days of 4 sessions.")
lookback_days = input.int(5, "Lookback Days for Heatmap", minval = 1, maxval = 30, group = group_heatmap, tooltip = "Sessions older than this will only show a background fill.")

group_filters = "Heatmap Density Filters (Transparency)"
low_transp    = input.int(90, "Low Density Transp.", minval = 0, maxval = 100, group = group_filters, tooltip = "Transparency for low volume areas (0% to 33% of max volume)")
mid_transp    = input.int(95, "Mid Density Transp.", minval = 0, maxval = 100, group = group_filters, tooltip = "Transparency for mid volume areas (33% to 66% of max volume)")
high_transp   = input.int(99, "High Density Transp.", minval = 0, maxval = 100, group = group_filters, tooltip = "Transparency for high volume areas (66% to 100% of max volume)")

group_style = "Style"
outline_transp = input.int(70, "Session Outline Transp.", minval = 0, maxval = 100, group = group_style, tooltip = "Transparency for the session box border. Lower values make it more visible.")
poc_width   = input.int(1, "POC Line Width", minval = 1, maxval = 5, group = group_style)
show_va     = input.bool(true, "Show Value Area Lines", group = group_style)
show_vp     = input.bool(true, "Show Side Histogram (VP)", group = group_style)
vp_width    = input.int(8, "VP Width (%)", minval = 1, maxval = 100, group = group_style)
old_bg_transp = input.int(90, "Old Session BG Transp.", minval = 0, maxval = 100, group = group_style, tooltip = "Background transparency for sessions older than the detailed limit.")

group_dash = "Dashboard Settings"
show_dash  = input.bool(true, "Show Dashboard", group = group_dash)
dash_pos   = input.string("top_right", "Position", options = ["top_right", "bottom_right", "top_left", "bottom_left"], group = group_dash)

// --- Types ---
type SessionData
    string  name
    int     start_bar
    int     start_time
    color   clr
    float   high
    float   low
    float[] h_arr
    float[] l_arr
    float[] v_arr
    float   total_vol
    box     main_box
    line    poc_line
    line    vah_line
    line    val_line
    line[]  vp_lines
    box[]   heat_boxes
    label   name_label

// --- Global Variables ---
var SessionData[] all_sessions = array.new<SessionData>()
var string[] active_session_names = array.new_string()

// --- Functions ---
method update(SessionData self, float h, float l, float v) =>
    self.high := math.max(self.high, h)
    self.low  := math.min(self.low, l)
    self.h_arr.push(h)
    self.l_arr.push(l)
    self.v_arr.push(v)
    self.total_vol += v
    0

method cleanup(SessionData self) =>
    if not na(self.vp_lines)
        while self.vp_lines.size() > 0
            self.vp_lines.shift().delete()
    if not na(self.heat_boxes)
        while self.heat_boxes.size() > 0
            self.heat_boxes.shift().delete()
    0

method demote(SessionData self) =>
    self.cleanup()
    if not na(self.poc_line)
        self.poc_line.delete()
        self.poc_line := na
    if not na(self.vah_line)
        self.vah_line.delete()
        self.vah_line := na
    if not na(self.val_line)
        self.val_line.delete()
        self.val_line := na
    box.set_bgcolor(self.main_box, color.new(self.clr, old_bg_transp))
    0

get_heat_color(ratio, clr) =>
    int transp = ratio > 0.66 ? high_transp : (ratio > 0.33 ? mid_transp : low_transp)
    color.new(clr, transp)

method render(SessionData self, int end_bar, color clr) =>
    self.cleanup()
    
    // Update Main Border Box
    box.set_lefttop(self.main_box, self.start_bar, self.high)
    box.set_rightbottom(self.main_box, end_bar, self.low)
    
    // Calculate Bins
    float[] vol_bins = array.new_float(num_bins, 0.0)
    float bin_size = (self.high - self.low) / num_bins
    
    if bin_size > 0
        for i = 0 to self.h_arr.size() - 1
            float bh = self.h_arr.get(i)
            float bl = self.l_arr.get(i)
            float bv = self.v_arr.get(i)
            
            for b = 0 to num_bins - 1
                float bin_low  = self.low + (b * bin_size)
                float bin_high = bin_low + bin_size
                float overlap_h = math.min(bh, bin_high)
                float overlap_l = math.max(bl, bin_low)
                
                if overlap_h > overlap_l
                    float overlap_perc = (overlap_h - overlap_l) / math.max(syminfo.mintick, bh - bl)
                    vol_bins.set(b, vol_bins.get(b) + (bv * overlap_perc))
                else if bh == bl and bh >= bin_low and bh <= bin_high
                    vol_bins.set(b, vol_bins.get(b) + bv)
        
        float max_vol = vol_bins.max()
        int poc_idx = vol_bins.indexof(max_vol)
        
        // Render Heatmap
        if max_vol > 0
            for i = 0 to num_bins - 1
                float v = vol_bins.get(i)
                float bin_low  = self.low + (i * bin_size)
                float bin_high = bin_low + bin_size
                float vol_ratio = v / max_vol
                color heat_col = get_heat_color(vol_ratio, clr)
                self.heat_boxes.push(box.new(self.start_bar, bin_high, end_bar, bin_low, bgcolor = heat_col, border_color = color.new(clr, 100)))

            // Side Histogram
            if show_vp
                int sess_len = end_bar - self.start_bar
                int max_w = math.round(sess_len * (vp_width / 100.0))
                for i = 0 to num_bins - 1
                    float v = vol_bins.get(i)
                    if v > 0
                        int w = math.round((v / max_vol) * max_w)
                        float y = self.low + (i * bin_size) + (bin_size / 2)
                        self.vp_lines.push(line.new(self.start_bar, y, self.start_bar + w, y, color = color.new(clr, 60), width = 1))
            
            // POC
            float poc_y = self.low + (poc_idx * bin_size) + (bin_size / 2)
            if na(self.poc_line)
                self.poc_line := line.new(self.start_bar, poc_y, end_bar, poc_y, color = clr, width = poc_width)
            else
                line.set_xy1(self.poc_line, self.start_bar, poc_y)
                line.set_xy2(self.poc_line, end_bar, poc_y)
                
            // Value Area
            if show_va
                float va_goal = self.total_vol * (va_perc / 100.0)
                float current_va_vol = max_vol
                int up_idx = poc_idx
                int dn_idx = poc_idx
                
                while current_va_vol < va_goal and (up_idx < num_bins - 1 or dn_idx > 0)
                    float up_vol = up_idx < num_bins - 1 ? vol_bins.get(up_idx + 1) : 0
                    float dn_vol = dn_idx > 0 ? vol_bins.get(dn_idx - 1) : 0
                    
                    if up_vol >= dn_vol and up_idx < num_bins - 1
                        up_idx += 1
                        current_va_vol += up_vol
                    else if dn_idx > 0
                        dn_idx -= 1
                        current_va_vol += dn_vol
                    else
                        break
                
                float vah_y = self.low + ((up_idx + 1) * bin_size)
                float val_y = self.low + (dn_idx * bin_size)
                
                if na(self.vah_line)
                    self.vah_line := line.new(self.start_bar, vah_y, end_bar, vah_y, color = clr, style = line.style_dashed)
                    self.val_line := line.new(self.start_bar, val_y, end_bar, val_y, color = clr, style = line.style_dashed)
                else
                    line.set_xy1(self.vah_line, self.start_bar, vah_y)
                    line.set_xy2(self.vah_line, end_bar, vah_y)
                    line.set_xy1(self.val_line, self.start_bar, val_y)
                    line.set_xy2(self.val_line, end_bar, val_y)
    0

// --- Logic ---
var SessionData[] active_sessions = array.new<SessionData>()

process(spec, name, clr) =>
    in_sess = not na(time(timeframe.period, spec, "UTC"))
    is_start = in_sess and not in_sess[1]
    is_end   = not in_sess and in_sess[1]
    
    if is_start
        new_sess = SessionData.new(name, bar_index, time, clr, high, low, array.new_float(), array.new_float(), array.new_float(), 0.0, na, na, na, na, array.new_line(), array.new_box(), na)
        new_sess.main_box := box.new(bar_index, high, bar_index, low, border_color = color.new(clr, outline_transp), bgcolor = color.new(clr, 100))
        new_sess.name_label := label.new(bar_index, high, "", color = #00000000, textcolor = clr, style = label.style_label_left, size = size.small)
        active_sessions.push(new_sess)
        all_sessions.push(new_sess)
        active_session_names.push(str.upper(name))
        
        // Handle Demotion (converting detailed sessions to simple background boxes)
        if all_sessions.size() > 1
            for i = 0 to all_sessions.size() - 1
                SessionData s = all_sessions.get(i)
                bool too_old = (timenow - s.start_time) > (lookback_days * 86400000)
                bool too_many = (all_sessions.size() - i) > max_detailed
                
                // Only demote if it hasn't been demoted yet (check for presence of heatmap boxes or lines)
                if (too_old or too_many) and (s.heat_boxes.size() > 0 or not na(s.poc_line))
                    // Ensure we don't demote active sessions
                    isActive = false
                    for act in active_sessions
                        if act.start_time == s.start_time
                            isActive := true
                            break
                    if not isActive
                        s.demote()
        
        // Cap the total history tracked to avoid performance issues
        if all_sessions.size() > 100
            all_sessions.shift()
        0
    
    if active_sessions.size() > 0
        for i = active_sessions.size() - 1 to 0
            SessionData s = active_sessions.get(i)
            if s.name == name
                if in_sess
                    s.update(high, low, nz(volume))
                    s.render(bar_index, clr)
                    label.set_xy(s.name_label, s.start_bar, s.high)
                if is_end
                    label.set_text(s.name_label, str.upper(name))
                    active_sessions.remove(i)
                    int name_idx = active_session_names.indexof(str.upper(name))
                    if name_idx != -1
                        active_session_names.remove(name_idx)
                break
        0
    0

// Execute logic
if show_tokyo
    process(tokyo_sess, "Tokyo", TOKYO_COLOR)
if show_sydney
    process(sydney_sess, "Sydney", SYDNEY_COLOR)
if show_london
    process(london_sess, "London", LONDON_COLOR)
if show_ny
    process(ny_sess, "New York", NY_COLOR)

// --- Dashboard ---
var table dash_table = table.new(dash_pos, 2, 6, bgcolor = #1e222d, border_color = chart.fg_color, border_width = 1)

if show_dash and barstate.islast
    table.clear(dash_table, 0, 0, 1, 5)
    table.cell(dash_table, 0, 0, "Active Sessions", text_color = chart.fg_color, text_size = size.small, bgcolor = #2a2e39)
    table.cell(dash_table, 1, 0, "Status", text_color = chart.fg_color, text_size = size.small, bgcolor = #2a2e39)
    
    if active_session_names.size() > 0
        for i = 0 to active_session_names.size() - 1
            table.cell(dash_table, 0, i + 1, active_session_names.get(i), text_color = chart.fg_color, text_size = size.small)
            table.cell(dash_table, 1, i + 1, "● LIVE", text_color = #089981, text_size = size.small)
    else
        table.cell(dash_table, 0, 1, "No Active Sessions", text_color = chart.fg_color, text_size = size.small)
        table.cell(dash_table, 1, 1, "-", text_color = chart.fg_color, text_size = size.small)
````
