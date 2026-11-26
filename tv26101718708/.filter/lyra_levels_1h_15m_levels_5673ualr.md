# Lyra Levels 1h & 15m levels

- url: https://www.tradingview.com/script/5673UaLr-Lyra-Levels-1h-15m-levels/
- type: indicator
- pine_id: PUB;954280e05de9496c9fcf35fa2feca6e0
- version: 1.0

## Description

Marks out 1h and 15m levels where price may return to. id suggest tweaking the setting to fit how u like the pivots plotted on the chart but overall great for seeing liquidty sweeps and 15m and 1h levels of liquidity. It plots Midnight open aswell.

## Source Code

````pine
//@version=5
indicator("Lyra Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. 1H SETTINGS
// ==========================================
grp_1h      = "--- 1H Liquidity Settings ---"
left_1h     = input.int(3, "1H Pivot Left", group=grp_1h)
right_1h    = input.int(3, "1H Pivot Right", group=grp_1h)
lb_1h       = input.int(24, "1H Candle Lookback (Strict)", group=grp_1h)
txt_1h      = input.string("1H DOL", "1H Label Text", group=grp_1h)
col_1h_hi   = input.color(color.new(color.red, 30), "1H High Color", group=grp_1h)
col_1h_lo   = input.color(color.new(color.green, 30), "1H Low Color", group=grp_1h)
width_1h    = input.int(1, "1H Line Width", minval=1, group=grp_1h)
style_1h    = input.string("Dotted", "1H Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_1h)

// ==========================================
// 2. 15M SETTINGS
// ==========================================
grp_15m     = "--- 15M Liquidity Settings ---"
left_15m    = input.int(3, "15m Pivot Left", group=grp_15m)
right_15m   = input.int(3, "15m Pivot Right", group=grp_15m)
lb_15m      = input.int(48, "15m Candle Lookback (Strict)", group=grp_15m)
txt_15m     = input.string("15m DOL", "15m Label Text", group=grp_15m)
col_15m_hi  = input.color(color.new(color.orange, 30), "15m High Color", group=grp_15m)
col_15m_lo  = input.color(color.new(color.blue, 30), "15m Low Color", group=grp_15m)
width_15m   = input.int(1, "15m Line Width", minval=1, group=grp_15m)
style_15m   = input.string("Dashed", "15m Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_15m)

// ==========================================
// 3. SWEPT & ALIGNMENT SETTINGS
// ==========================================
grp_swp     = "--- Swept & Alignment Settings ---"
keep_swept  = input.bool(true, "Show 'Swept' State", group=grp_swp)
swept_txt   = input.string("Liquidity Swept", "Swept Label Text", group=grp_swp)
align_prox  = input.float(0.02, "Alignment Proximity (%)", step=0.01, group=grp_swp) / 100

// Midnight Open Settings
grp_mid     = "--- Midnight Open Settings ---"
show_mid    = input.bool(true, "Show Midnight Open (Current Session Only)", group=grp_mid)
mid_text    = input.string("Midnight Open", "Label Text", group=grp_mid)
col_mid_ln  = input.color(color.gray, "Line Color", group=grp_mid)
col_mid_tx  = input.color(color.white, "Text Color", group=grp_mid)
style_mid   = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_mid)
size_mid    = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_mid)

txt_col     = input.color(color.white, "All Label Text Color")

// Helper functions
get_style(s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
get_size(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

// ==========================================
// 4. DATA FETCHING
// ==========================================
[t1h, pHi1h, pLo1h] = request.security(syminfo.tickerid, "60", [time, ta.pivothigh(high, left_1h, right_1h), ta.pivotlow(low, left_1h, right_1h)], gaps=barmerge.gaps_off)
[t15m, pHi15m, pLo15m] = request.security(syminfo.tickerid, "15", [time, ta.pivothigh(high, left_15m, right_15m), ta.pivotlow(low, left_15m, right_15m)], gaps=barmerge.gaps_off)

cutoff1h  = time - (lb_1h * 3600000)
cutoff15m = time - (lb_15m * 900000)

var line[] hiLines = array.new_line(), var label[] hiLabels = array.new_label(), var float[] hiPrices = array.new_float(), var int[] hiStart = array.new_int(), var bool[] hiIs1h = array.new_bool(), var bool[] hiSwept = array.new_bool()
var line[] loLines = array.new_line(), var label[] loLabels = array.new_label(), var float[] loPrices = array.new_float(), var int[] loStart = array.new_int(), var bool[] loIs1h = array.new_bool(), var bool[] loSwept = array.new_bool()

// ==========================================
// 5. STORAGE & ALIGNMENT LOGIC
// ==========================================
check_alignment(price, is1h, prices, is1h_arr) =>
    aligned = false
    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            if array.get(is1h_arr, i) and not is1h
                if math.abs(price - array.get(prices, i)) <= (price * align_prox)
                    aligned := true
                    break
    aligned

// Highs
if not na(pHi1h) and t1h[right_1h] >= cutoff1h
    array.unshift(hiLines, line.new(t1h[right_1h], pHi1h, time, pHi1h, xloc=xloc.bar_time, color=col_1h_hi, width=width_1h, style=get_style(style_1h)))
    array.unshift(hiLabels, label.new(time, pHi1h, txt_1h, xloc=xloc.bar_time, color=color.new(col_1h_hi, 0), style=label.style_label_down, textcolor=txt_col, size=size.small))
    array.unshift(hiPrices, pHi1h), array.unshift(hiStart, t1h[right_1h]), array.unshift(hiIs1h, true), array.unshift(hiSwept, false)

if not na(pHi15m) and t15m[right_15m] >= cutoff15m and not check_alignment(pHi15m, false, hiPrices, hiIs1h)
    array.unshift(hiLines, line.new(t15m[right_15m], pHi15m, time, pHi15m, xloc=xloc.bar_time, color=col_15m_hi, width=width_15m, style=get_style(style_15m)))
    array.unshift(hiLabels, label.new(time, pHi15m, txt_15m, xloc=xloc.bar_time, color=color.new(col_15m_hi, 0), style=label.style_label_down, textcolor=txt_col, size=size.small))
    array.unshift(hiPrices, pHi15m), array.unshift(hiStart, t15m[right_15m]), array.unshift(hiIs1h, false), array.unshift(hiSwept, false)

// Lows
if not na(pLo1h) and t1h[right_1h] >= cutoff1h
    array.unshift(loLines, line.new(t1h[right_1h], pLo1h, time, pLo1h, xloc=xloc.bar_time, color=col_1h_lo, width=width_1h, style=get_style(style_1h)))
    array.unshift(loLabels, label.new(time, pLo1h, txt_1h, xloc=xloc.bar_time, color=color.new(col_1h_lo, 0), style=label.style_label_up, textcolor=txt_col, size=size.small))
    array.unshift(loPrices, pLo1h), array.unshift(loStart, t1h[right_1h]), array.unshift(loIs1h, true), array.unshift(loSwept, false)

if not na(pLo15m) and t15m[right_15m] >= cutoff15m and not check_alignment(pLo15m, false, loPrices, loIs1h)
    array.unshift(loLines, line.new(t15m[right_15m], pLo15m, time, pLo15m, xloc=xloc.bar_time, color=col_15m_lo, width=width_15m, style=get_style(style_15m)))
    array.unshift(loLabels, label.new(time, pLo15m, txt_15m, xloc=xloc.bar_time, color=color.new(col_15m_lo, 0), style=label.style_label_up, textcolor=txt_col, size=size.small))
    array.unshift(loPrices, pLo15m), array.unshift(loStart, t15m[right_15m]), array.unshift(loIs1h, false), array.unshift(loSwept, false)

// ==========================================
// 6. UPDATE & SWEPT LOOP
// ==========================================
process_liq(lns, lbs, pxs, sts, is1h, swp, isHigh) =>
    if array.size(lns) > 0
        for i = array.size(lns) - 1 to 0
            p = array.get(pxs, i), ln = array.get(lns, i), lb = array.get(lbs, i), s = array.get(sts, i), ctf = array.get(is1h, i) ? cutoff1h : cutoff15m
            is_swp = array.get(swp, i)
            
            if not is_swp
                line.set_x2(ln, time), label.set_x(lb, time)
                if (isHigh ? high >= p : low <= p)
                    if keep_swept
                        array.set(swp, i, true)
                        line.set_style(ln, line.style_dotted)
                        label.set_text(lb, swept_txt)
                    else
                        line.delete(ln), label.delete(lb)
                        array.remove(lns, i), array.remove(lbs, i), array.remove(pxs, i), array.remove(sts, i), array.remove(is1h, i), array.remove(swp, i)
            
            if s < ctf 
                line.delete(ln), label.delete(lb)
                array.remove(lns, i), array.remove(lbs, i), array.remove(pxs, i), array.remove(sts, i), array.remove(is1h, i), array.remove(swp, i)

process_liq(hiLines, hiLabels, hiPrices, hiStart, hiIs1h, hiSwept, true)
process_liq(loLines, loLabels, loPrices, loStart, loIs1h, loSwept, false)

// ==========================================
// 7. MIDNIGHT OPEN (CURRENT SESSION ONLY)
// ==========================================
var line midLine  = na
var label midLab  = na
var float midOpen = na

// Reset logic: Delete the old objects when a new day starts
if ta.change(time("D"))
    line.delete(midLine)
    label.delete(midLab)
    midLine := na
    midLab  := na
    
    if show_mid
        midOpen := open
        midLine := line.new(time, midOpen, time, midOpen, xloc=xloc.bar_time, color=col_mid_ln, style=get_style(style_mid), width=1)
        midLab  := label.new(time, midOpen, mid_text, xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=col_mid_tx, style=label.style_label_left, size=get_size(size_mid))

// Continuous update for the current session
if not na(midLine)
    if show_mid
        line.set_x2(midLine, time)
        label.set_x(midLab, time)
    else
        line.delete(midLine)
        label.delete(midLab)
        midLine := na
        midLab  := na
````
