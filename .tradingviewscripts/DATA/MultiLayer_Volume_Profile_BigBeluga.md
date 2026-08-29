<!-- tradingview-pine-id: PUB;6373d74a197f4b6297f16edd72ab19c8 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Layer Volume Profile [BigBeluga]

Source: https://www.tradingview.com/script/5QtH3KYD-Multi-Layer-Volume-Profile-BigBeluga/

## Description

A powerful multi-resolution volume analysis tool that stacks multiple profiles of historical trading activity to reveal true market structure.  
This indicator breaks down total and delta volume distribution across time at four adjustable depths — enabling traders to spot major POCs, volume shelves, and zones of price acceptance or rejection with unmatched clarity.

🔵 KEY FEATURES  

[*] Multi-Layer Volume Profiles:  
   Up to 4 separate volume profiles are stacked on the chart:  
   - Profile 1: Full period  
   - Profile 2: Half-length  
   - Profile 3: Quarter-length  
   - Profile 4: One-eighth-length  
[image]https://www.tradingview.com/x/xPIxcejJ/[/image]
   This layering helps traders assess confluence across different time horizons.  

[*] Custom Bin Resolution:  
   Each profile uses a customizable number of bins to control visual precision.  
   More bins = higher granularity, fewer bins = smoother profile.  

[*] Precise POC Highlighting:  
   The price level with the maximum traded volume in each profile is highlighted with a thick blue POC line.  
   This key level shows the most accepted price for each period.  
[image]https://www.tradingview.com/x/fGQo6cOH/[/image]

[*] Total and Delta Volume Labels:  
   - Total Volume: Displays cumulative volume over the profile period at the top of the profile box.  
   - Delta Volume: The difference between bullish and bearish volume is labeled at the base, showing directional pressure.  
   Positive delta = buyer dominance, negative delta = seller dominance.  
[image]https://www.tradingview.com/x/C3cfqg4b/[/image]

[*] Range Levels:  
   Each profile includes horizontal reference lines showing its high, low, bounds.  
   These edges often align with price reaction zones and become future resistance/support.
[image]https://www.tradingview.com/x/qVDGlaY4/[/image]

🔵 HOW IT WORKS  

[*] For each active profile, the indicator:  
   - Collects price range (highs/lows) across the selected `length`  
   - Divides this range into equal bins  
   - Assigns volume into bins based on candle close location  
   - Aggregates volume per bin to form the profile (polylines) 

[*] Separately tracks:  
   - Total volume (sum of all candles in range)  
   - Delta volume (sum of candle volumes: positive for bullish, negative for bearish closes)  

[*] Highlights the bin with maximum volume (POC)  
   and marks it with a thick blue line.  

[*] Adds auxiliary lines for high/low of each profile box  
   and total/delta volume tags with tooltips.  

🔵 USAGE  

[*] Spot Acceptance Zones:  
   Thick, flat areas on the profile show where price stayed longest — ideal for building positions.  

[*] Identify Rejection Zones:  
   Thin volume areas signal price rejection and are often used for stop placement or entries.  

[*] Delta Confirmation:  
   Use strong positive/negative delta readings as directional bias confirmation for breakout trades.  

[*] Confluence Detection:  
   Watch for overlapping POCs between layers to identify extremely strong support/resistance zones.  

🔵 CONCLUSION  
Multi-Layer Volume Profile [BigBeluga] equips traders with a deeply layered market structure view.  
Whether you're scalping intraday levels or analyzing macro support zones, the ability to stack volume perspectives, visualize directional delta, and anchor POCs provides an edge in anticipating market moves.  
Use this tool to validate entries, confirm structure, and make more informed, volume-aware trading decisions.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Multi-Layer Volume Profile [BigBeluga]", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
len = input.int(300, "Period")
bins = input.int(100, "Resolution")

prf_col    = input.color(color.rgb(0, 187, 212, 60), "Profile")
poc_col    = input.color(color.blue, "PoC")

delta_col1 = input.color(color.aqua, "Delta+", inline = "1")
delta_col2 = input.color(color.red, "Delta-", inline = "1")

profile1 = input.bool(true, "VP1", inline = "vp")
profile2 = input.bool(true, "VP2", inline = "vp")
profile3 = input.bool(true, "VP3", inline = "vp")
profile4 = input.bool(true, "VP4", inline = "vp")

// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

profile(length, bins, poc_mult, style = true)=>
    values = array.new<float>()
    vol_bins = array.new<float>(bins)

    tot_vol = array.new<float>()
    delta_vol = array.new<float>()

    max_val = float(na)
    min_val = float(na)
    step = float(na)

    var bin_levels = array.new<line>()
    var bin_labels = array.new<label>()

    poly = array.new<chart.point>()

    if barstate.islast
        for i = 0 to length - 1
            values.push(high[i])
            values.push(low[i])


        max_val := values.max()
        min_val := values.min()

        step := (max_val-min_val)/bins

        
    if barstate.islast
        for i = 0 to bins - 1
            vol_bins.set(i, 0)

        for i = 0 to length - 1

            c_top   = math.max(close[i], open[i])
            c_low   = math.min(close[i], open[i])
            c       = close[i]
            o       = open[i]
            vol     = volume[i]

            tot_vol.push(vol)
            delta_vol.push(c > o ? vol : -vol)

            for j = 0 to bins - 1

                lower = min_val + step * j 
                upper = lower + step 
                mid = math.avg(lower, upper)

                if c <= upper + step*1.5 and c >= lower - step*1.5
                    vol_bins.set(j, vol_bins.get(j) + vol)

    
    if barstate.islast
        check = false
        if bin_levels.size() > 0
            for k = 0 to bin_levels.size() - 1
                line.delete(bin_levels.get(k))
                
        if bin_labels.size() > 0
            for k = 0 to bin_labels.size() - 1
                label.delete(bin_labels.get(k))

        for i = 0 to bins - 1

            lower = min_val + step * i
            upper = lower + step 
            mid = math.avg(upper, lower)

            vol = int(vol_bins.get(i) / vol_bins.max() * 25)

            start = bar_index - length 
            end = start +vol

            var midd = float(na)

            poly.push(chart.point.from_index(i == 0 ? start : i == bins - 1 ? start : end+1, mid))

            if vol_bins.get(i) == vol_bins.max() and not check
                check := true
                bin_labels.push(label.new(start, mid, str.tostring(vol_bins.get(i), format.volume), style = label.style_label_right, color = color.new(poc_col, 25), force_overlay = true))
                bin_levels.push(line.new(start, mid, start + int(length/poc_mult), mid, color = poc_col, force_overlay = true, width = 3))

                bin_levels.push(line.new(start, max_val, bar_index, max_val, color = chart.fg_color, style = style ? line.style_solid : line.style_dashed))
                bin_levels.push(line.new(start, min_val, bar_index, min_val, color = chart.fg_color, style = style ? line.style_solid : line.style_dashed))

                bin_levels.push(line.new(start, max_val, start, min_val, color = chart.fg_color, style = line.style_solid))
                bin_levels.push(line.new(start, max_val, start, min_val, color = chart.fg_color, style = line.style_solid))


                bin_labels.push(label.new(start, max_val, "Total\n" + str.tostring(tot_vol.sum(), format.volume), style = label.style_label_down, text_font_family = font.family_monospace, size = size.small, tooltip = "Total Volume over VolumeProfile period", color = color.blue))
                bin_labels.push(label.new(start, min_val,  str.tostring(delta_vol.sum(), format.volume) + "\nDelta", style = label.style_label_up, text_font_family = font.family_monospace, size = size.small, tooltip = "Delta Volume over VolumeProfile period", color = delta_vol.sum() < 0 ? delta_col2 : delta_col1))

        polyline.delete( polyline.new(poly, line_color = #00e67700, fill_color = prf_col)[1] )

if profile1
    profile(len, bins, 2)
if profile2
    profile(int(len/2), bins, 2, false)
if profile3
    profile(int(len/4), bins, 2, false)
if profile4
    profile(int(len/8), bins, 1, false)

// }
````
