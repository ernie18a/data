# Forex Power Gauge With GOLD [LEO MAGLENTE 2.0] - Expanded Gold

- url: https://www.tradingview.com/script/bCdumPat-Forex-Power-Gauge-With-GOLD-LEO-MAGLENTE-2-0-Expanded-Gold/
- type: indicator
- pine_id: PUB;eb3e93e7527541e5922c11649dbf129f
- version: 1.0

## Description

Power Gauge With GOLD [LEO MAGLENTE 2.0] trend sentiment  Currency Strength Aggregation
Dahil ang Forex ay by "pair," kinukuha natin ang net score ng isang currency laban sa lahat ng major partners nito.

Halimbawa sa USD:
Para makuha ang total score ng USD, pinagsasama-sama ng script ang resulta mula sa:

-(EURUSD score) + -(GBPUSD score) + -(AUDUSD score) + USDCAD score + USDJPY score.

Logic Note: Kapag ang EURUSD ay "Down" (-1), pabor iyon sa USD, kaya nagiging +1 ito sa total score ng USD.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LEO MAGLENTE

//@version=6
indicator("Forex Power Gauge With GOLD [LEO MAGLENTE 2.0] - Expanded Gold", overlay = false)

// --- Settings ---
display = input.string('Trailing Relative Strength', 'Display Mode', options = ['Trailing Relative Strength', 'Relative Strength Box Graph'])
freq    = input.timeframe('D', 'Reset Frequency')

// Currency Inputs
group_curr = 'Currencies'
currencyA = input.string('USD', 'A', inline = 'A', group = group_curr)
ACss      = input.color(#ff1100, '', inline = 'A', group = group_curr)

currencyB = input.string('EUR', 'B', inline = 'B', group = group_curr)
BCss      = input.color(#2157f3, '', inline = 'B', group = group_curr)

currencyC = input.string('GBP', 'C', inline = 'C', group = group_curr)
CCss      = input.color(#4caf50, '', inline = 'C', group = group_curr)

currencyD = input.string('JPY', 'D', inline = 'D', group = group_curr)
DCss      = input.color(#e91e63, '', inline = 'D', group = group_curr)

currencyE = input.string('AUD', 'E', inline = 'E', group = group_curr)
ECss      = input.color(#ff9800, '', inline = 'E', group = group_curr)

currencyF = input.string('CAD', 'F', inline = 'F', group = group_curr)
FCss      = input.color(#00bcd4, '', inline = 'F', group = group_curr)

currencyG = input.string('NZD', 'G', inline = 'G', group = group_curr)
GCss      = input.color(#9c27b0, '', inline = 'G', group = group_curr)

currencyH = input.string('CHF', 'H', inline = 'H', group = group_curr)
HCss      = input.color(#795548, '', inline = 'H', group = group_curr)

currencyI = input.string('XAU', 'I (Gold)', inline = 'I', group = group_curr)
ICss      = input.color(#ffd700, '', inline = 'I', group = group_curr)

// Meter Settings
group_meter = 'Strength Meter'
showDash   = input.bool(true, 'Show Strength Meter', group = group_meter)
resolution = input.int(20, 'Meter Resolution', minval = 5, group = group_meter)
dashLoc    = input.string('Top Right', 'Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = group_meter)
textSize   = input.string('Small', 'Size', options = ['Tiny', 'Small', 'Normal'], group = group_meter)

// Box Graph Settings
group_box = 'Box Graph'
boxRes       = input.int(20, 'Box Graph Resolution', maxval = 500, group = group_box)
boxStrong    = input.color(color.new(#089981, 80), 'Strong Zone', group = group_box)
boxImprove   = input.color(color.new(#5b9cf6, 80), 'Improving Zone', group = group_box)
boxWeakening = input.color(color.new(#ff9800, 80), 'Weakening Zone', group = group_box)
boxWeak      = input.color(color.new(#f23645, 80), 'Weak Zone', group = group_box)

// Trade Suggestions
group_trade = 'Trade Suggestions'
showTrades  = input.bool(true, 'Show Possible Trades', group = group_trade)
tradeColor  = input.color(#ffffff, 'Text Color', group = group_trade)

// --- Types ---
type currencyData
    string name
    float strength
    color css

type tradeGap
    string strong
    string weak
    float diff

// --- Functions ---
get_priority(curr) =>
    c = str.upper(curr)
    switch c
        'XAU' => 0
        'EUR' => 1
        'GBP' => 2
        'AUD' => 3
        'NZD' => 4
        'USD' => 5
        'CAD' => 6
        'CHF' => 7
        'JPY' => 8
        => 9

get_trade_signal(strong_c, weak_c) =>
    p_strong = get_priority(strong_c)
    p_weak   = get_priority(weak_c)
    if p_strong < p_weak
        "Buy " + strong_c + weak_c
    else
        "Sell " + weak_c + strong_c

set_meter(tb, col, strength, min_val, max_val, bg_css) =>
    scale = (strength - min_val) / math.max(1e-6, max_val - min_val) * (resolution - 1)
    table.clear(tb, col, 2, col, resolution + 1)
    for i = 0 to math.floor(scale)
        css = color.from_gradient(i, 0, scale, color.new(bg_css, 100), bg_css)
        table.cell(tb, col, resolution + 1 - i, bgcolor = css, height = 0.1)
    table.cell(tb, col, 1, str.format('{0}{1}', strength > 0 ? '+' : '', str.tostring(strength, '#.###')), bgcolor = bg_css, text_size = size.tiny, text_color = color.white, width = 2)

set_point(strength, prev_strength, min_val, max_val, css, name) =>
    var label lbl = label.new(na, na, '•', color = #00000000, style = label.style_label_center, textcolor = css, size = size.large)
    if barstate.islast
        scale_prev = (strength - prev_strength - min_val) / math.max(1e-6, max_val - min_val)
        label.set_x(lbl, bar_index + int(scale_prev * boxRes))
        label.set_y(lbl, strength)
        label.set_tooltip(lbl, name)

// --- Data Fetching ---
get_change(c1, c2) =>
    request.security(c1 + c2, timeframe.period, (close - open) / open * 100, ignore_invalid_symbol = true)

// Currency Matrix (8x8)
AB = get_change(currencyA, currencyB), AC = get_change(currencyA, currencyC), AD = get_change(currencyA, currencyD), AE = get_change(currencyA, currencyE), AF = get_change(currencyA, currencyF), AG = get_change(currencyA, currencyG), AH = get_change(currencyA, currencyH)
BC = get_change(currencyB, currencyC), BD = get_change(currencyB, currencyD), BE = get_change(currencyB, currencyE), BF = get_change(currencyB, currencyF), BG = get_change(currencyB, currencyG), BH = get_change(currencyB, currencyH)
CD = get_change(currencyC, currencyD), CE = get_change(currencyC, currencyE), CF = get_change(currencyC, currencyF), CG = get_change(currencyC, currencyG), CH = get_change(currencyC, currencyH)
DE = get_change(currencyD, currencyE), DF = get_change(currencyD, currencyF), DG = get_change(currencyD, currencyG), DH = get_change(currencyD, currencyH)
EF = get_change(currencyE, currencyF), EG = get_change(currencyE, currencyG), EH = get_change(currencyE, currencyH)
FG = get_change(currencyF, currencyG), FH = get_change(currencyF, currencyH)
GH = get_change(currencyG, currencyH)

BA = -AB, CA = -AC, DA = -AD, EA = -AE, FA = -AF, GA = -AG, HA = -AH
CB = -BC, DB = -BD, EB = -BE, FB = -BF, GB = -BG, HB = -BH
DC = -CD, EC = -CE, FC = -CF, GC = -CG, HC = -CH
ED = -DE, FD = -DF, GD = -DG, HD = -DH
FE = -EF, GE = -EG, HE = -EH
GF = -FG, HF = -FH
HG = -GH

// Gold Calculation (XAU vs Basket for Strength Meter, but only USD for Trades)
IA = get_change(currencyI, currencyA) // XAUUSD
IB = get_change(currencyI, currencyB) // XAUEUR
IC = get_change(currencyI, currencyC) // XAUGBP
ID = get_change(currencyI, currencyD) // XAUJPY
IE = get_change(currencyI, currencyE) // XAUAUD
IF = get_change(currencyI, currencyF) // XAUCAD
IG = get_change(currencyI, currencyG) // XAUNZD
IH = get_change(currencyI, currencyH) // XAUCHF

// --- Calculation ---
dt = timeframe.change(freq)

var float sumA = 0., var float prev_A = 0.
var float sumB = 0., var float prev_B = 0.
var float sumC = 0., var float prev_C = 0.
var float sumD = 0., var float prev_D = 0.
var float sumE = 0., var float prev_E = 0.
var float sumF = 0., var float prev_F = 0.
var float sumG = 0., var float prev_G = 0.
var float sumH = 0., var float prev_H = 0.
var float sumI = 0., var float prev_I = 0.

// Currencies use only their 8x8 matrix (7 pairs each) to maintain original accuracy
avgA = math.avg(AB, AC, AD, AE, AF, AG, AH)
avgB = math.avg(BA, BC, BD, BE, BF, BG, BH)
avgC = math.avg(CA, CB, CD, CE, CF, CG, CH)
avgD = math.avg(DA, DB, DC, DE, DF, DG, DH)
avgE = math.avg(EA, EB, EC, ED, EF, EG, EH)
avgF = math.avg(FA, FB, FC, FD, FE, FG, FH)
avgG = math.avg(GA, GB, GC, GD, GE, GF, GH)
avgH = math.avg(HA, HB, HC, HD, HE, HF, HG)
// Gold strength is its performance against all 8, keeping it on a comparable scale
avgI = math.avg(IA, IB, IC, ID, IE, IF, IG, IH)

if dt
    prev_A := sumA, prev_B := sumB, prev_C := sumC, prev_D := sumD, prev_E := sumE, prev_F := sumF, prev_G := sumG, prev_H := sumH, prev_I := sumI
    sumA := avgA, sumB := avgB, sumC := avgC, sumD := avgD, sumE := avgE, sumF := avgF, sumG := avgG, sumH := avgH, sumI := avgI
else
    sumA += avgA, sumB += avgB, sumC += avgC, sumD += avgD, sumE += avgE, sumF += avgF, sumG += avgG, sumH += avgH, sumI += avgI

// --- Visualization: Meter ---
var table_pos = dashLoc == 'Bottom Left' ? position.bottom_left : dashLoc == 'Top Right' ? position.top_right : position.bottom_right
var table_sz  = textSize == 'Tiny' ? size.tiny : textSize == 'Small' ? size.small : size.normal

var tb = table.new(table_pos, 19, resolution + 3, bgcolor = #1e222d, border_width = 1, frame_color = #373a46, frame_width = 1)

if barstate.isfirst and showDash
    table.cell(tb, 0, 0, str.format('Currency Relative Strength ({0})', freq), text_size = table_sz, text_color = color.white)
    table.merge_cells(tb, 0, 0, 18, 0)
    for i = 0 to 18 by 2
        table.cell(tb, i, 1, bgcolor = #1e222d, width = 0.1)
        table.merge_cells(tb, i, 1, i, resolution + 2)
    table.cell(tb, 1, resolution + 2, currencyA, text_color = color.white, text_size = table_sz, bgcolor = ACss)
    table.cell(tb, 3, resolution + 2, currencyB, text_color = color.white, text_size = table_sz, bgcolor = BCss)
    table.cell(tb, 5, resolution + 2, currencyC, text_color = color.white, text_size = table_sz, bgcolor = CCss)
    table.cell(tb, 7, resolution + 2, currencyD, text_color = color.white, text_size = table_sz, bgcolor = DCss)
    table.cell(tb, 9, resolution + 2, currencyE, text_color = color.white, text_size = table_sz, bgcolor = ECss)
    table.cell(tb, 11, resolution + 2, currencyF, text_color = color.white, text_size = table_sz, bgcolor = FCss)
    table.cell(tb, 13, resolution + 2, currencyG, text_color = color.white, text_size = table_sz, bgcolor = GCss)
    table.cell(tb, 15, resolution + 2, currencyH, text_color = color.white, text_size = table_sz, bgcolor = HCss)
    table.cell(tb, 17, resolution + 2, currencyI, text_color = color.white, text_size = table_sz, bgcolor = ICss)

if barstate.islast and showDash
    min_val_m = math.min(sumA, sumB, sumC, sumD, sumE, sumF, sumG, sumH, sumI)
    max_val_m = math.max(sumA, sumB, sumC, sumD, sumE, sumF, sumG, sumH, sumI)
    set_meter(tb, 1, sumA, min_val_m, max_val_m, ACss)
    set_meter(tb, 3, sumB, min_val_m, max_val_m, BCss)
    set_meter(tb, 5, sumC, min_val_m, max_val_m, CCss)
    set_meter(tb, 7, sumD, min_val_m, max_val_m, DCss)
    set_meter(tb, 9, sumE, min_val_m, max_val_m, ECss)
    set_meter(tb, 11, sumF, min_val_m, max_val_m, FCss)
    set_meter(tb, 13, sumG, min_val_m, max_val_m, GCss)
    set_meter(tb, 15, sumH, min_val_m, max_val_m, HCss)
    set_meter(tb, 17, sumI, min_val_m, max_val_m, ICss)

// --- Visualization: Box Plot ---
var bx_strong    = box.new(na, na, na, na, bgcolor = boxStrong, border_color = color.new(chart.fg_color, 80))
var bx_improve   = box.new(na, na, na, na, bgcolor = boxImprove, border_color = color.new(chart.fg_color, 80))
var bx_weakening = box.new(na, na, na, na, bgcolor = boxWeakening, border_color = color.new(chart.fg_color, 80))
var bx_weak      = box.new(na, na, na, na, bgcolor = boxWeak, border_color = color.new(chart.fg_color, 80))

var label x_label = label.new(na, na, 'Momentum (Strength Change)', style = label.style_label_up, color = #00000000, textcolor = chart.fg_color, size = size.small) 
var label y_label = label.new(na, na, 'Relative\nStrength', style = label.style_label_right, color = #00000000, textcolor = chart.fg_color, size = size.small) 

// Trade Suggestion Visuals
var label trade_label = label.new(na, na, '', style = label.style_label_left, color = #00000000, textcolor = tradeColor, size = size.normal)

if display == 'Relative Strength Box Graph'
    min_val = math.min(sumA, sumB, sumC, sumD, sumE, sumF, sumG, sumH, sumI)
    max_val = math.max(sumA, sumB, sumC, sumD, sumE, sumF, sumG, sumH, sumI)
    diffA = sumA - prev_A, diffB = sumB - prev_B, diffC = sumC - prev_C, diffD = sumD - prev_D, diffE = sumE - prev_E, diffF = sumF - prev_F, diffG = sumG - prev_G, diffH = sumH - prev_H, diffI = sumI - prev_I
    prev_min = math.min(diffA, diffB, diffC, diffD, diffE, diffF, diffG, diffH, diffI)
    prev_max = math.max(diffA, diffB, diffC, diffD, diffE, diffF, diffG, diffH, diffI)
    
    if barstate.islast
        box.set_lefttop(bx_strong, bar_index + int(boxRes / 2), max_val)
        box.set_rightbottom(bx_strong, bar_index + boxRes, 0)
        box.set_lefttop(bx_improve, bar_index, max_val)
        box.set_rightbottom(bx_improve, bar_index + int(boxRes / 2), 0)
        box.set_lefttop(bx_weakening, bar_index + int(boxRes / 2), 0)
        box.set_rightbottom(bx_weakening, bar_index + boxRes, min_val)
        box.set_lefttop(bx_weak, bar_index, 0)
        box.set_rightbottom(bx_weak, bar_index + int(boxRes / 2), min_val)
        label.set_xy(x_label, bar_index + int(boxRes / 2), min_val)
        label.set_xy(y_label, bar_index, 0)

        // Trade Logic
        if showTrades
            currencyData[] currs = array.new<currencyData>()
            currs.push(currencyData.new(currencyA, sumA, ACss))
            currs.push(currencyData.new(currencyB, sumB, BCss))
            currs.push(currencyData.new(currencyC, sumC, CCss))
            currs.push(currencyData.new(currencyD, sumD, DCss))
            currs.push(currencyData.new(currencyE, sumE, ECss))
            currs.push(currencyData.new(currencyF, sumF, FCss))
            currs.push(currencyData.new(currencyG, sumG, GCss))
            currs.push(currencyData.new(currencyH, sumH, HCss))

            // Calculate all currency-only gaps
            tradeGap[] gaps = array.new<tradeGap>()
            for i = 0 to currs.size() - 2
                for j = i + 1 to currs.size() - 1
                    c1 = currs.get(i)
                    c2 = currs.get(j)
                    if c1.strength > c2.strength
                        gaps.push(tradeGap.new(c1.name, c2.name, c1.strength - c2.strength))
                    else
                        gaps.push(tradeGap.new(c2.name, c1.name, c2.strength - c1.strength))
            
            // Explicitly add XAUUSD trade gap (Ignoring other gold crosses)
            gold_usd_gap = math.abs(sumI - sumA)
            if sumI > sumA
                gaps.push(tradeGap.new(currencyI, currencyA, gold_usd_gap))
            else
                gaps.push(tradeGap.new(currencyA, currencyI, gold_usd_gap))

            // Sort gaps (Descending)
            for i = 0 to gaps.size() - 2
                for j = i + 1 to gaps.size() - 1
                    if gaps.get(i).diff < gaps.get(j).diff
                        tradeGap temp = gaps.get(i)
                        gaps.set(i, gaps.get(j))
                        gaps.set(j, temp)

            trade_text = "Possible Trades (Top 3):\n"
            for i = 0 to math.min(2, gaps.size() - 1)
                g = gaps.get(i)
                trade_text += str.tostring(i + 1) + ". " + get_trade_signal(g.strong, g.weak) + "\n"
            
            label.set_xy(trade_label, bar_index + boxRes + 2, (max_val + min_val) / 2)
            label.set_text(trade_label, trade_text)
    
    set_point(sumA, prev_A, prev_min, prev_max, ACss, currencyA)
    set_point(sumB, prev_B, prev_min, prev_max, BCss, currencyB)
    set_point(sumC, prev_C, prev_min, prev_max, CCss, currencyC)
    set_point(sumD, prev_D, prev_min, prev_max, DCss, currencyD)
    set_point(sumE, prev_E, prev_min, prev_max, ECss, currencyE)
    set_point(sumF, prev_F, prev_min, prev_max, FCss, currencyF)
    set_point(sumG, prev_G, prev_min, prev_max, GCss, currencyG)
    set_point(sumH, prev_H, prev_min, prev_max, HCss, currencyH)
    set_point(sumI, prev_I, prev_min, prev_max, ICss, currencyI)
else
    label.set_text(trade_label, "")

// --- Plots ---
plot_A = plot(display == 'Trailing Relative Strength' ? sumA : na, 'USD Strength', color = dt ? na : ACss, linewidth = 2)
plot_B = plot(display == 'Trailing Relative Strength' ? sumB : na, 'EUR Strength', color = dt ? na : BCss, linewidth = 2)
plot_C = plot(display == 'Trailing Relative Strength' ? sumC : na, 'GBP Strength', color = dt ? na : CCss, linewidth = 2)
plot_D = plot(display == 'Trailing Relative Strength' ? sumD : na, 'JPY Strength', color = dt ? na : DCss, linewidth = 2)
plot_E = plot(display == 'Trailing Relative Strength' ? sumE : na, 'AUD Strength', color = dt ? na : ECss, linewidth = 2)
plot_F = plot(display == 'Trailing Relative Strength' ? sumF : na, 'CAD Strength', color = dt ? na : FCss, linewidth = 2)
plot_G = plot(display == 'Trailing Relative Strength' ? sumG : na, 'NZD Strength', color = dt ? na : GCss, linewidth = 2)
plot_H = plot(display == 'Trailing Relative Strength' ? sumH : na, 'CHF Strength', color = dt ? na : HCss, linewidth = 2)
plot_I = plot(display == 'Trailing Relative Strength' ? sumI : na, 'Gold Strength', color = dt ? na : ICss, linewidth = 2)

bgcolor(display == 'Trailing Relative Strength' and dt ? color.new(color.gray, 50) : na, title = "Period Separator")
````
