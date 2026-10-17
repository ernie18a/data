# $SPY Levels For Tomorrow: (used on 5/15min)

- url: https://www.tradingview.com/script/eF60ecOl-SPY-Levels-For-Tomorrow-used-on-5-15min/
- type: indicator
- pine_id: PUB;e6bc026b3ea14f1ea6994f4a2f4f65a1
- version: 1.0

## Description

plots daily levels for SPY  (used on 5/15min)
plug in the levels manually to update

## Source Code

````pine
//@version=6
indicator('$SPY Levels For Tomorrow: (used on 5/15min)', overlay = true, max_lines_count = 100, max_labels_count = 100)

// ============================================================
// INSTRUCTIONS:
// - White levels = Key Pivots
// - Red levels = Supply & Demand around pivots
// - To update daily: just change the numbers below, save, done!
// - Set unused levels to 0 to hide them
// ============================================================

// ===== DISPLAY SETTINGS =====
showLabels = input.bool(true, 'Show Price Labels', group = 'Display')
labelOffset = input.int(5, 'Label Offset (bars)', group = 'Display')
pivotWidth = input.int(2, 'Pivot Line Thickness', minval = 1, maxval = 4, group = 'Display')
sdWidth = input.int(1, 'S/D Line Thickness', minval = 1, maxval = 4, group = 'Display')
lineStyle = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Display')

// ===== LABEL SIZE =====
labelSizeStr = input.string('Small', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = 'Label Size')

// ===== COLOR CUSTOMIZATION =====
pivotLineColor = input.color(color.white, 'Pivot Line Color', group = '🎨 Colors - Pivot Lines & Labels')
pivotLabelBg = input.color(color.white, 'Pivot Label Background', group = '🎨 Colors - Pivot Lines & Labels')
pivotLabelText = input.color(color.black, 'Pivot Label Text Color', group = '🎨 Colors - Pivot Lines & Labels')

sdLineColor = input.color(color.red, 'S/D Line Color', group = '🎨 Colors - S/D Lines & Labels')
sdLabelBg = input.color(color.red, 'S/D Label Background', group = '🎨 Colors - S/D Lines & Labels')
sdLabelText = input.color(color.white, 'S/D Label Text Color', group = '🎨 Colors - S/D Lines & Labels')

// ===== WHITE LEVELS — KEY PIVOTS =====
p1 = input.float(715.76, 'Pivot 1', group = '⚪ Pivots - Key Levels')
p2 = input.float(712.42, 'Pivot 2', group = '⚪ Pivots - Key Levels')
p3 = input.float(707.33, 'Pivot 3', group = '⚪ Pivots - Key Levels')
p4 = input.float(702.70, 'Pivot 4', group = '⚪ Pivots - Key Levels')
p5 = input.float(697.99, 'Pivot 5', group = '⚪ Pivots - Key Levels')
p6 = input.float(694.02, 'Pivot 6', group = '⚪ Pivots - Key Levels')
p7 = input.float(689.49, 'Pivot 7', group = '⚪ Pivots - Key Levels')
p8 = input.float(0, 'Pivot 8 (extra)', group = '⚪ Pivots - Key Levels')
p9 = input.float(0, 'Pivot 9 (extra)', group = '⚪ Pivots - Key Levels')

// ===== RED LEVELS — SUPPLY & DEMAND =====
r1 = input.float(717.82, 'S/D 1', group = '🔴 Supply/Demand Levels')
r2 = input.float(714.85, 'S/D 2', group = '🔴 Supply/Demand Levels')
r3 = input.float(712.99, 'S/D 3', group = '🔴 Supply/Demand Levels')
r4 = input.float(711.28, 'S/D 4', group = '🔴 Supply/Demand Levels')
r5 = input.float(708.70, 'S/D 5', group = '🔴 Supply/Demand Levels')
r6 = input.float(705.84, 'S/D 6', group = '🔴 Supply/Demand Levels')
r7 = input.float(704.30, 'S/D 7', group = '🔴 Supply/Demand Levels')
r8 = input.float(701.38, 'S/D 8', group = '🔴 Supply/Demand Levels')
r9 = input.float(699.47, 'S/D 9', group = '🔴 Supply/Demand Levels')
r10 = input.float(696.38, 'S/D 10', group = '🔴 Supply/Demand Levels')
r11 = input.float(695.01, 'S/D 11', group = '🔴 Supply/Demand Levels')
r12 = input.float(692.41, 'S/D 12', group = '🔴 Supply/Demand Levels')
r13 = input.float(690.98, 'S/D 13', group = '🔴 Supply/Demand Levels')
r14 = input.float(0, 'S/D 14 (extra)', group = '🔴 Supply/Demand Levels')
r15 = input.float(0, 'S/D 15 (extra)', group = '🔴 Supply/Demand Levels')
r16 = input.float(0, 'S/D 16 (extra)', group = '🔴 Supply/Demand Levels')

// ===== STYLE & SIZE LOGIC =====
getLineStyle() =>
    lineStyle == 'Dashed' ? line.style_dashed : lineStyle == 'Dotted' ? line.style_dotted : line.style_solid

getLabelSize() =>
    labelSizeStr == 'Tiny' ? size.tiny : labelSizeStr == 'Small' ? size.small : labelSizeStr == 'Normal' ? size.normal : labelSizeStr == 'Large' ? size.large : size.huge

// ===== DRAW FUNCTION =====
f_drawLevel(price, lineCol, labelBg, labelTxt, width) =>
    if price > 0 and barstate.islast
        line.new(bar_index - 500, price, bar_index + labelOffset, price, color = lineCol, width = width, style = getLineStyle(), extend = extend.right)
        if showLabels
            label.new(bar_index + labelOffset, price, str.tostring(price, '#.##'), color = labelBg, textcolor = labelTxt, style = label.style_label_left, size = getLabelSize())

// ===== EXECUTE DRAWS =====
if barstate.islast
    // Clear previous lines/labels each update
    for ln in line.all
        line.delete(ln)
    for lb in label.all
        label.delete(lb)

    // Pivots
    f_drawLevel(p1, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p2, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p3, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p4, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p5, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p6, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p7, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p8, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)
    f_drawLevel(p9, pivotLineColor, pivotLabelBg, pivotLabelText, pivotWidth)

    // Supply/Demand
    f_drawLevel(r1, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r2, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r3, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r4, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r5, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r6, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r7, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r8, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r9, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r10, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r11, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r12, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r13, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r14, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r15, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
    f_drawLevel(r16, sdLineColor, sdLabelBg, sdLabelText, sdWidth)
````
