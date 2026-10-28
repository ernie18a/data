# CandelaCharts - Distributed Volume Matrix

- url: https://www.tradingview.com/script/gEtRbSRQ-CandelaCharts-Distributed-Volume-Matrix/
- type: indicator
- pine_id: PUB;857ca5b0474d433395f1d86f9afeb45e
- version: 2.0

## Description

📝 [b]Overview[/b]

The [b]Distributed Volume Matrix[/b] is an advanced volume profiling tool designed to provide a highly visual and granular breakdown of price-volume dynamics over a specified lookback window. Unlike traditional volume profiles, this indicator renders a "heatmap matrix" alongside the chart, allowing traders to instantly identify critical liquidity zones, high-volume nodes, and the Point of Control (POC) with exceptional clarity.

📦 [b]Features[/b]

[list]
[*] [b]Bipolar Diverging Heatmap:[/b] Bins above the Point of Control are colored with a distinct warm palette, while bins below are colored with a cool palette. This immediately contextualizes price action relative to the highest volume node.
[*] [b]Heatmap Stepping:[/b] Toggle between a smooth color gradient or a quantized "stepped" heatmap. Stepping breaks volume intensity into distinct thresholds (Low, Medium, High, Extreme), providing a bolder, cleaner visual structure.
[*] [b]Value Area Calculation:[/b] Automatically calculates and displays the Value Area High (VAH) and Value Area Low (VAL) based on user-defined volume percentages (default 70%).
[*] [b]Dynamic Lookback Bounds:[/b] Clearly visualizes the exact high and low price bounds of the lookback period using beautifully styled dashed lines and semi-transparent bubbles.
[*] [b]Optimized Performance:[/b] Built using Pine Script's advanced array and user-defined type (UDT) capabilities to ensure lightning-fast rendering without graphical lag, automatically dynamically capping memory use to available chart history.
[*] [b]Big Order Bubbles:[/b] Dynamically highlights extraordinary trading volume directly on the price action. Bubbles are constrained precisely to the active matrix lookback window, scaling in size based on a customizable volume multiplier.
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]Length:[/b] The number of historical bars to include in the volume distribution calculation.
[*] [b]Number of Bins:[/b] The vertical resolution of the matrix. Higher values provide finer granularity.
[*] [b]Source:[/b] The price source used to determine the volume distribution across bins.
[*] [b]Value Area (%):[/b] The percentage of total volume to encompass within the Value Area (VAH to VAL).
[*] [b]Colors:[/b] Fully customizable color settings for the Value Area lines, Histogram (Above/Below POC), Point of Control (POC), and Gap Color (bins with 0 volume).
[*] [b]Use Heatmap Stepping:[/b] Enable this to quantize the heatmap into solid opacity steps rather than a continuous gradient.
[*] [b]Show Volume:[/b] Toggle the display of the formatted volume number on the left side of each histogram bin.
[*] [b]Show Volume Columns:[/b] Displays traditional vertical volume columns per bar under the horizontal matrix profile.
[*] [b]Bubbles (Big Order Bubbles):[/b] Toggle the display of volume bubbles on the chart and adjust the threshold multiplier. A higher multiplier requires significantly more volume (relative to the moving average) for a bubble to appear.
[/list]

⚡️ [b]Showcase[/b]

[i]Heatmap[/i]
https://www.tradingview.com/x/GNPvMRPv/

[i]Heatmap Stepping[/i]
https://www.tradingview.com/x/h6dzH7Z7/

[i]Volume[/i]
https://www.tradingview.com/x/cWQyGdTd/

[i]Gaps[/i]
https://www.tradingview.com/x/NAMHcirb/

[i]Big Order Bubbles[/i]
https://www.tradingview.com/x/zzT0viQ0/

💡 [b]Usage[/b]

Here are a few ways to utilize the Distributed Volume Matrix in your trading strategy:
[list]
[*] [b]Value Area Range Trading:[/b] Identify mean-reverting setups by fading moves that reject off the Value Area High (VAH) or Value Area Low (VAL), targeting the Point of Control (POC) or opposing side of the range.
https://www.tradingview.com/x/KLqM0cJx/
[*] [b]Trend Reversal at Extreme Liquidity Nodes:[/b] Spot sharp price reversals when the market interacts with a high-volume node identified by the brightest heatmap bins at the edge of the Value Area.
https://www.tradingview.com/x/2VpVywcG/
[*] [b]Big Order Tracking:[/b] Align Big Order Bubbles with significant Value Area (VAH/VAL) rejections or POC interactions. An extreme volume bubble appearing right as price leaves the Value Area heavily reinforces the move's momentum.
https://www.tradingview.com/x/4Qjbjxn2/
[/list]

🚨 [b]Alerts[/b]

This indicator is purely visual and does not feature built-in alert conditions.

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - Distributed Volume Matrix", shorttitle = "CandelaCharts - Distributed Volume Matrix", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)










// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

colors_black                        = color.black
colors_blue                         = color.blue
colors_aqua                         = color.aqua
colors_red                          = color.red
colors_gray                         = color.gray
colors_purple                       = color.purple
colors_teal                         = color.teal
colors_orange                       = color.orange

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font                        = input.string("Monospace", "Text                  ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                  = input.bool(false, "Hide Brand                   ", group = "General")

vdm_length_len                      = input.int(200, "Length", step = 50, group = "Settings")
vdm_bins_len                        = input.int(60, "Number of Bins", maxval = 500, step = 10, group = "Settings")
vdm_src                             = input.source(close, "Source", group = "Settings")
vdm_va_percent                      = input.int(70, "Value Area (%)   ", inline = "1.0", maxval = 100, minval = 1, step = 5, group = "Settings")
vdm_va_css                          = input.color(colors_black, "", inline = "1.0", group = "Settings")
vdm_bob_show                        = input.bool(true, "Bubbles     ", inline = "2.0", group = "Settings")
vdm_bob_mult                        = input.float(3.0, "", inline = "2.0", step = 0.5, group = "Settings")
vdm_bob_bull_css                    = input.color(colors_blue, "", inline = "2.0", group = "Settings")
vdm_bob_bear_css                    = input.color(colors_orange, "", inline = "2.0", group = "Settings")
vdm_above_poc_css                   = input.color(colors_teal, "Histogram          ", inline = "3.0", group = "Settings")
vdm_below_poc_css                   = input.color(colors_teal, "", inline = "3.0", group = "Settings")
vdm_poc_css                         = input.color(colors_black, "POC Color", group = "Settings")
vdm_gap_css                         = input.color(color.new(colors_purple, 100), "Gap Color", group = "Settings")
vdm_use_stepping                    = input.bool(false, "Use Heatmap Stepping", group = "Settings")
vdm_show_volume                     = input.bool(true, "Show Bin Volume", group = "Settings")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   UDT  |
// # ========================================================================= #

//#region

type UDT_Store
    array<box>  boxes
    line        high_l
    line        low_l
    label       lbl1
    label       lbl2
    label       poc_lbl
    line        vah_l
    line        val_l
    label       vah_lbl
    label       val_lbl

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Functions  |
// # ========================================================================= #

//#region

method text_size(string size) =>
    out = switch size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
    out

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

method get_value_area(array<float> a_freq, int bins_len, float max_vol, float va_percent, float lowest_price, float bin_size) =>
    int poc = -1
    float total_volume = 0
    for i = 0 to bins_len - 1
        float f = a_freq.get(i)
        total_volume += f
        if f == max_vol and poc == -1
            poc := i

    float target_va_vol = total_volume * (va_percent / 100.0)
    float current_va_vol = a_freq.get(poc)
    int upper_idx = poc
    int lower_idx = poc

    while current_va_vol < target_va_vol
        float vol_above = upper_idx < bins_len - 1 ? a_freq.get(upper_idx + 1) : -1.0
        float vol_below = lower_idx > 0 ? a_freq.get(lower_idx - 1) : -1.0

        if vol_above == -1.0 and vol_below == -1.0
            break

        if vol_above >= vol_below
            upper_idx += 1
            current_va_vol += vol_above
        else
            lower_idx -= 1
            current_va_vol += vol_below
    
    float val = lowest_price + lower_idx * bin_size
    float vah = lowest_price + upper_idx * bin_size + bin_size
    [poc, val, vah]

method draw_triangle_label(int x, float y, string txt, color css, string g_font, string g_text) =>
    label.new(x, y, "◄ " + txt + " " + str.tostring(y, "#.##"), style = label.style_label_left, color = color(na), textcolor = css, text_font_family = font_style(g_font), size = text_size(g_text))

method draw_diamond_label(int x, float y, color css) =>
    label.new(x, y, "", style = label.style_diamond, color = color.new(css, 50), size = size.small)

method draw_dashed_line(int start_x, int end_x, float price, color css) =>
    line.new(start_x, price, end_x, price, color = color.new(css, 50), style = line.style_dashed)

method get_bin_color(float frq, float max_vol, float min_vol, color base_css, bool use_step) =>
    color css = na
    if use_step
        float rel_vol = max_vol > 0 ? frq / max_vol : 0
        css := rel_vol > 0.80 ? color.new(base_css, 20) :
               rel_vol > 0.50 ? color.new(base_css, 50) :
               rel_vol > 0.20 ? color.new(base_css, 80) :
               color(na)
    else
        css := color.from_gradient(frq, min_vol, max_vol, color(na), color.new(base_css, 50))
    css

method format_vol(float vol) =>
    vol >= 1000000000 ? str.tostring(vol / 1000000000, "#.##") + "B" :
     vol >= 1000000 ? str.tostring(vol / 1000000, "#.##") + "M" :
     vol >= 1000 ? str.tostring(vol / 1000, "#.##") + "K" :
     str.tostring(vol, "#.##")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store store = UDT_Store.new(array.new<box>(), na, na, na, na, na, na, na, na, na)

method clean(UDT_Store s) =>
    if s.boxes.size() > 0
        for b in s.boxes
            b.delete()
        s.boxes.clear()
    
    if not na(s.high_l)
        s.high_l.delete()
    if not na(s.low_l)
        s.low_l.delete()
    if not na(s.lbl1)
        s.lbl1.delete()
    if not na(s.lbl2)
        s.lbl2.delete()
    if not na(s.poc_lbl)
        s.poc_lbl.delete()
    if not na(s.vah_l)
        s.vah_l.delete()
    if not na(s.val_l)
        s.val_l.delete()
    if not na(s.vah_lbl)
        s.vah_lbl.delete()
    if not na(s.val_lbl)
        s.val_lbl.delete()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Variables   |
// # ========================================================================= #

//#region

series float volume_avg             = ta.sma(volume, 50)

var array<float> freq               = array.new<float>()
var float highestPrice              = na
var float lowestPrice               = na
var int highest_bar_index           = na
var int lowest_bar_index            = na
var int poc_idx                     = -1
var float binSize                   = na
var float max_volume                = na
var float min_volume                = na
var float val_price                 = na
var float vah_price                 = na

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

if barstate.islast
    int actual_length = math.min(vdm_length_len, bar_index + 1)
    
    freq.clear()
    for i = 0 to vdm_bins_len - 1
        freq.push(0)

    array<float> highest            = array.new<float>(actual_length)
    array<float> lowest             = array.new<float>(actual_length)

    for j = 0 to actual_length - 1
        highest.set(j, high[j])
        lowest.set(j, low[j])

    highestPrice                   := highest.max()
    lowestPrice                    := lowest.min()
    highest_bar_index              := bar_index - highest.indexof(highestPrice)
    lowest_bar_index               := bar_index - lowest.indexof(lowestPrice)
    binSize                        := (highestPrice - lowestPrice) / vdm_bins_len

    for i = 0 to vdm_bins_len - 1
        float binLower              = lowestPrice + i * binSize
        float binUpper              = binLower + binSize

        for j = 0 to actual_length - 1
            if vdm_src[j] >= binLower and vdm_src[j] <= binUpper
                freq.set(i, freq.get(i) + volume_avg[j])
                
    max_volume                     := freq.max()
    min_volume                     := freq.min()

    // --- Value Area Calculation ---
    [p_idx, v_price, va_price] = freq.get_value_area(vdm_bins_len, max_volume, vdm_va_percent, lowestPrice, binSize)
    poc_idx := p_idx
    val_price := v_price
    vah_price := va_price
    // ------------------------------

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Plotting   |
// # ========================================================================= #

//#region

if barstate.islast
    int actual_length = math.min(vdm_length_len, bar_index + 1)
    int future_bar = bar_index + 20
    store.clean()

    store.high_l := draw_dashed_line(future_bar, bar_index - actual_length + 1, highestPrice, vdm_above_poc_css)
    store.low_l := draw_dashed_line(future_bar, bar_index - actual_length + 1, lowestPrice, vdm_below_poc_css)

    store.lbl1 := draw_diamond_label(highest_bar_index, highestPrice, vdm_above_poc_css)
    store.lbl2 := draw_diamond_label(lowest_bar_index, lowestPrice, vdm_below_poc_css)

    store.vah_l := line.new(future_bar, vah_price, bar_index - actual_length + 1, vah_price, color = vdm_va_css, style = line.style_solid)
    store.val_l := line.new(future_bar, val_price, bar_index - actual_length + 1, val_price, color = vdm_va_css, style = line.style_solid)
    store.vah_lbl := draw_triangle_label(future_bar, vah_price, "VAH", vdm_va_css, general_font, general_text)
    store.val_lbl := draw_triangle_label(future_bar, val_price, "VAL", vdm_va_css, general_font, general_text)

    for i = 0 to vdm_bins_len - 1
        float frq                   = freq.get(i)
        
        color base_color            = i > poc_idx ? vdm_above_poc_css : vdm_below_poc_css
        color css                   = frq == 0 ? vdm_gap_css : get_bin_color(frq, max_volume, min_volume, base_color, vdm_use_stepping)
        
        float binLower              = lowestPrice + i * binSize
        float binUpper              = binLower + binSize

        string txt                  = vdm_show_volume ? frq.format_vol() : ""
        box b = box.new(future_bar, binUpper, bar_index - actual_length + 1, binLower, na, bgcolor = css, text = txt, text_size = text_size(general_text), text_color = chart.fg_color, text_halign = text.align_left, text_valign = text.align_center, text_font_family = font_style(general_font))
        store.boxes.push(b)

        if max_volume == frq
            b.set_bgcolor(vdm_poc_css)
            b.set_text_color(color.white)
            float poc_price = math.avg(binLower, binUpper)
            store.poc_lbl := draw_triangle_label(future_bar, poc_price, "POC", vdm_poc_css, general_font, general_text)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Big Order Bubbles   |
// # ========================================================================= #

//#region

bool bob_bull = close > open
bool bob_bear = close < open
bool bob_in_range = (last_bar_index - bar_index) < vdm_length_len

bool bob_f1 = volume > volume_avg * (vdm_bob_mult * 2.0)
bool bob_f2 = volume > volume_avg * (vdm_bob_mult * 1.5)
bool bob_f3 = volume > volume_avg * (vdm_bob_mult * 1.0)
bool bob_f4 = volume > volume_avg * (vdm_bob_mult * 0.75)

if vdm_bob_show and bob_in_range
    string vol_str = "Volume: " + volume.format_vol()

    if bob_bull
        if bob_f1
            label.new(bar_index, close, style = label.style_circle, size = size.huge, color = color.new(vdm_bob_bull_css, 50), tooltip = vol_str)
        if bob_f2
            label.new(bar_index, close, style = label.style_circle, size = size.large, color = color.new(vdm_bob_bull_css, 50), tooltip = vol_str)
        if bob_f3
            label.new(bar_index, close, style = label.style_circle, size = size.normal, color = color.new(vdm_bob_bull_css, 50), tooltip = vol_str)
        if bob_f4
            label.new(bar_index, close, style = label.style_circle, size = size.small, color = color.new(vdm_bob_bull_css, 50), tooltip = vol_str)

    else if bob_bear
        if bob_f1
            label.new(bar_index, close, style = label.style_circle, size = size.huge, color = color.new(vdm_bob_bear_css, 50), tooltip = vol_str)
        if bob_f2
            label.new(bar_index, close, style = label.style_circle, size = size.large, color = color.new(vdm_bob_bear_css, 50), tooltip = vol_str)
        if bob_f3
            label.new(bar_index, close, style = label.style_circle, size = size.normal, color = color.new(vdm_bob_bear_css, 50), tooltip = vol_str)
        if bob_f4
            label.new(bar_index, close, style = label.style_circle, size = size.small, color = color.new(vdm_bob_bear_css, 50), tooltip = vol_str)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Brand   |
// # ========================================================================= #

//#region

if barstate.isfirst and not general_brand_show
    var table brand = table.new(position.bottom_right, 1, 1, bgcolor = chart.bg_color)
    table.cell(brand, 0, 0, "© CandelaCharts", text_color = colors_gray, text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
