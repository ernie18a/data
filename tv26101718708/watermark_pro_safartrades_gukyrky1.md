# Watermark Pro @SafarTrades

- url: https://www.tradingview.com/script/GUKyRky1-Watermark-Pro-SafarTrades/
- type: indicator
- pine_id: PUB;54af394bcfbc4951a2a794efddf2eaa5
- version: 1.0

## Description

[b]Watermark Pro[/b]

Watermark Pro is a customizable branding and metadata overlay for TradingView charts. It helps create a clean, professional workspace while keeping important chart information consistently visible.
[image]https://www.tradingview.com/x/YLBCVT1Y/[/image]
The indicator combines customizable branding, chart metadata, and account status badges into a single configurable layout, making it suitable for personal trading, screenshots, educational content, and social media publishing.

[b]Branding Panel[/b]
[image]https://www.tradingview.com/x/SD6ZqHYD/[/image]
Display a fully customizable title and subtitle with flexible positioning to maintain a consistent visual identity across all charts.

[b]Account Status Badge[/b]
[image]https://www.tradingview.com/x/KIo4Ugw5/[/image]
Display a customizable status badge (e.g., Live Account, Demo Account, Funded Account, Backtesting) with multiple styling options to clearly identify the chart environment.

[b]Chart Metadata[/b]
[image]https://www.tradingview.com/x/JQm8YRbf/[/image]
Optionally display the current date, trading symbol, and timeframe in a dedicated information panel that updates automatically as charts change.

[b]Customization[/b]
Every component can be customized independently, allowing you to configure the layout to match your personal workflow and visual preferences.
[image]https://www.tradingview.com/x/DvQFIsJD/[/image]
[list]
[*]Theme presets
[*]Branding panel
[*]Account status badge
[*]Chart metadata panel
[*]Flexible positioning
[*]Color and typography controls
[*]Badge styling options
[/list]

[b]Intended Use[/b]

Watermark Pro is suitable for traders, educators, analysts, and content creators who want consistent chart branding and a clean presentation for trading, analysis, screenshots, and educational content.

## Source Code

````pine
//@version=6
indicator("Watermark Pro", overlay=true)

// © 2026 SafarTrades
// All Rights Reserved
//
// This indicator is proprietary software.
// Unauthorized copying, redistribution,
// resale, modification, or republication
// is prohibited without written permission.

// =========================================================================
// 1. Inputs & Configuration Groups
// =========================================================================

var string G_THEME   = "1. THEME PRESETS"
var string G_BRAND   = "2. BRANDING PANEL"
var string G_ACCOUNT = "3. ACCOUNT STATUS BADGE"
var string G_INFO    = "4. CHART METADATA PANEL"
var string G_CUSTOM  = "5. CUSTOM STYLE OVERRIDES"

// =========================================================================
// 1. Theme Presets
// =========================================================================
theme_selection = input.string("Classic Glass", "Theme Presets", options=["Custom", "Gold", "Midnight Stealth", "Orange", "Classic Glass"], group=G_THEME, tooltip="Select a preset theme style or choose 'Custom' to manually adjust style settings below.")

// =========================================================================
// 2. Branding Panel Settings
// =========================================================================
show_branding   = input.bool(true, "Show Branding Panel", group=G_BRAND)
brand_title     = input.string("SafarTrades", "Title Text", group=G_BRAND)
brand_subtitle  = input.string("Discipline | Patience | Execution", "Subtitle Text", group=G_BRAND)
brand_v_pos     = input.string("Top", "Position V", options=["Top", "Middle", "Bottom"], group=G_BRAND, inline="brand_pos")
brand_h_pos     = input.string("Center", "H", options=["Left", "Center", "Right"], group=G_BRAND, inline="brand_pos")

// =========================================================================
// 3. Account Status Badge Settings
// =========================================================================
show_badge      = input.bool(true, "Show Status Badge", group=G_ACCOUNT, tooltip="Used to display prop firm account numbers, custom codes, status tags, etc.")
badge_text      = input.string("LIVE ACCOUNT", "Badge Status Text", group=G_ACCOUNT)
badge_style     = input.string("Filled", "Badge Style", options=["Filled", "Border Only"], group=G_ACCOUNT)

// =========================================================================
// 4. Chart Info Panel Settings
// =========================================================================
show_info       = input.bool(true, "Show Info Panel", group=G_INFO)
info_show_date  = input.bool(true, "Show Date", group=G_INFO, inline="info_toggles")
info_show_sym   = input.bool(true, "Show Symbol", group=G_INFO, inline="info_toggles")
info_show_tf    = input.bool(true, "Show Timeframe", group=G_INFO, inline="info_toggles")
info_separator  = input.string("|", "Divider Character", group=G_INFO)
info_v_pos      = input.string("Bottom", "Position V", options=["Top", "Middle", "Bottom"], group=G_INFO, inline="info_pos")
info_h_pos      = input.string("Center", "H", options=["Left", "Center", "Right"], group=G_INFO, inline="info_pos")

// =========================================================================
// 5. Custom Color & Size Overrides
// =========================================================================
color_bg        = input.color(color.new(color.black, 100), "Card Background", group=G_CUSTOM, tooltip="Used as the card backing background color.")
color_title     = input.color(#636363, "Title Text Color", group=G_CUSTOM, inline="custom_title", tooltip="Custom color and size for Title.")
size_title      = input.string("Large", "", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_CUSTOM, inline="custom_title")
color_sub       = input.color(#636363, "Subtitle Color", group=G_CUSTOM, inline="custom_sub", tooltip="Custom color and size for Subtitle.")
size_sub        = input.string("Normal", "", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_CUSTOM, inline="custom_sub")
color_metadata  = input.color(#636363, "Metadata Color", group=G_CUSTOM, inline="custom_meta", tooltip="Custom color and size for Metadata (Symbol/TF/Date).")
size_metadata   = input.string("Normal", "", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_CUSTOM, inline="custom_meta")
badge_color     = input.color(#00e676, "Badge Styling Color", group=G_CUSTOM, inline="custom_badge", tooltip="Custom color and size for the Account Status Badge.")
badge_size      = input.string("Normal", "", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_CUSTOM, inline="custom_badge")


// =========================================================================
// 2. Custom Helper Functions
// =========================================================================

// Resolve font sizes into native TradingView size constants
f_get_font_size(string size_str) =>
    switch size_str
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

// Resolve vertical and horizontal inputs into Pine table position constant
f_get_table_pos(string y_pos, string x_pos) =>
    y_pos == "Top" ? (x_pos == "Left" ? position.top_left : x_pos == "Center" ? position.top_center : position.top_right) : 
     y_pos == "Middle" ? (x_pos == "Left" ? position.middle_left : x_pos == "Center" ? position.middle_center : position.middle_right) : 
     (x_pos == "Left" ? position.bottom_left : x_pos == "Center" ? position.bottom_center : position.bottom_right)

// Format the timeframe dynamically into a readable label representation
f_get_timeframe() =>
    if timeframe.isminutes
        mult = timeframe.multiplier
        mult % 60 == 0 ? str.tostring(int(mult / 60)) + "H" : str.tostring(mult) + "m"
    else if timeframe.isdaily
        timeframe.multiplier == 1 ? "Daily" : str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        timeframe.multiplier == 1 ? "Weekly" : str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        timeframe.multiplier == 1 ? "Monthly" : str.tostring(timeframe.multiplier) + "M"
    else
        timeframe.period

// Format current date into a dd/mm/yyyy formatted string with zero padding
f_pad_zero(int val) =>
    val < 10 ? "0" + str.tostring(val) : str.tostring(val)

f_format_date() =>
    f_pad_zero(dayofmonth) + "/" + f_pad_zero(month) + "/" + str.tostring(year)


// =========================================================================
// 3. Theme Resolution Engine
// =========================================================================

// Resolve colors and background based on theme selection
var color theme_title_col = na
var color theme_sub_col   = na
var color theme_meta_col  = na
var color theme_badge_col = na
var color theme_bg_col    = na

if theme_selection == "Gold"
    theme_title_col := #FFD700
    theme_sub_col   := #C5A059
    theme_meta_col  := #C5A059
    theme_badge_col := #FFD700
    theme_bg_col    := color.new(#1a1a1a, 20)
else if theme_selection == "Midnight Stealth"
    theme_title_col := #8a8a8a
    theme_sub_col   := #5c5c5c
    theme_meta_col  := #5c5c5c
    theme_badge_col := #707070
    theme_bg_col    := color.new(color.black, 60)
else if theme_selection == "Orange"
    theme_title_col := #FF6600
    theme_sub_col   := #FF9955
    theme_meta_col  := #FF9955
    theme_badge_col := #FF6600
    theme_bg_col    := color.new(#0d0d0d, 15)
else if theme_selection == "Classic Glass"
    theme_title_col := #131722
    theme_sub_col   := #4c525e
    theme_meta_col  := #4c525e
    theme_badge_col := #2962ff
    theme_bg_col    := color.new(#f0f3fa, 80)
else // "Custom"
    theme_title_col := color_title
    theme_sub_col   := color_sub
    theme_meta_col  := color_metadata
    theme_badge_col := badge_color
    theme_bg_col    := color_bg


// =========================================================================
// 4. Execution & Drawing Logic
// =========================================================================

var table brand_table = na
var table info_table  = na

if barstate.islast
    // Render Branding Panel (Top Table)
    if show_branding
        brand_rows = 2 + (show_badge ? 1 : 0)
        brand_table := table.new(
             position     = f_get_table_pos(brand_v_pos, brand_h_pos),
             columns      = 1,
             rows         = brand_rows,
             bgcolor      = color.new(color.black, 100),
             border_width = 0,
             frame_width  = 0)
             
        table.cell(brand_table, 0, 0,
             text        = brand_title,
             text_color  = theme_title_col,
             text_size   = f_get_font_size(size_title),
             text_halign = text.align_center,
             bgcolor     = theme_bg_col)
             
        table.cell(brand_table, 0, 1,
             text        = brand_subtitle,
             text_color  = theme_sub_col,
             text_size   = f_get_font_size(size_sub),
             text_halign = text.align_center,
             bgcolor     = theme_bg_col)
             
        if show_badge
            cell_text = badge_style == "Border Only" ? "[ " + badge_text + " ]" : badge_text
            cell_bg   = badge_style == "Filled" ? color.new(theme_badge_col, 20) : theme_bg_col
            
            // Dynamically calculate luminance to decide white vs black text on filled badges
            badge_lum = color.r(theme_badge_col) * 0.299 + color.g(theme_badge_col) * 0.587 + color.b(theme_badge_col) * 0.114
            cell_txt_col = badge_style == "Filled" ? (badge_lum > 128 ? color.black : color.white) : theme_badge_col
            
            table.cell(brand_table, 0, 2,
                 text        = cell_text,
                 text_color  = cell_txt_col,
                 text_size   = f_get_font_size(badge_size),
                 text_halign = text.align_center,
                 bgcolor     = cell_bg)

    // Render Chart Metadata Panel (Bottom Table)
    if show_info
        info_elements = array.new_string(0)
        if info_show_sym
            array.push(info_elements, syminfo.ticker)
        if info_show_tf
            array.push(info_elements, f_get_timeframe())
            
        spaced_separator = " " + info_separator + " "
        joined_info_text = array.join(info_elements, spaced_separator)
        
        has_row0 = info_show_date
        has_row1 = info_show_sym or info_show_tf
        total_rows = (has_row0 ? 1 : 0) + (has_row1 ? 1 : 0)
        total_rows := math.max(total_rows, 1)
        
        info_table := table.new(
             position     = f_get_table_pos(info_v_pos, info_h_pos),
             columns      = 1,
             rows         = total_rows,
             bgcolor      = color.new(color.black, 100),
             border_width = 0,
             frame_width  = 0)
             
        row_counter = 0
        if has_row0
            table.cell(info_table, 0, row_counter,
                 text        = f_format_date(),
                 text_color  = theme_meta_col,
                 text_size   = f_get_font_size(size_metadata),
                 text_halign = text.align_center,
                 bgcolor     = theme_bg_col)
            row_counter := row_counter + 1
            
        if has_row1
            table.cell(info_table, 0, row_counter,
                 text        = joined_info_text,
                 text_color  = theme_meta_col,
                 text_size   = f_get_font_size(size_metadata),
                 text_halign = text.align_center,
                 bgcolor     = theme_bg_col)
````
