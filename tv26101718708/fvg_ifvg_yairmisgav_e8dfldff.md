# FVG & iFVG (Yair_Misgav)

- url: https://www.tradingview.com/script/e8DFlDff-FVG-iFVG-Yair-Misgav/
- type: indicator
- pine_id: PUB;772e86075f344054a63ed2979110b41d
- version: 1.0

## Description

This indicator provides automated identification, filtering, and management of Fair Value Gaps (FVG) and Inversion Fair Value Gaps (iFVG). It is designed for traders utilizing Smart Money Concepts (SMC) who require a systematic approach to identifying liquidity and structural imbalances.

Key Technical Features:

Algorithmic Detection: Identifies gaps in price action based on structural imbalances, with integrated filters for Volume SMA and Body-to-Range ratios to ensure only high-momentum zones are prioritized.

Dynamic Inversion Engine: Automatically transitions identified FVGs into iFVGs once price penetrates the zone, reclassifying support-turned-resistance (or vice versa) to maintain structural accuracy.

Symmetrical Projection (Measured Move): Calculates and projects target zones based on the structural swing origin. This feature includes an optional midline toggle for precise assessment of potential profit targets or reversal areas.

Configurable Visualization: Offers dual extension modes (Fixed vs. Dynamic to Last Bar) and customizable lookback periods to manage chart density and historical tracking.

Visual Logic: Provides clear, configurable styling options for borders, midlines, and labeling, allowing for seamless integration into existing technical chart setups.

Note: This tool is intended for structural analysis and should be used in conjunction with a robust risk management strategy.

## Source Code

````pine
//@version=6
indicator('FVG & iFVG (Yair_Misgav)', overlay = true, max_bars_back = 500, max_boxes_count = 500, max_lines_count = 500)

// --- Inputs ---
grp1 = 'Core Settings'
lookback = input.int(300, title = 'Lookback Period (Bars)', minval = 10, group = grp1, tooltip = 'The max number of historical bars an FVG area remains tracked and drawn on the chart.', display = display.none)
extType = input.string('Fixed', title = 'Extension Mode', options = ['Fixed', 'Dynamic to Last Bar'], group = grp1, tooltip = 'Determines whether zone boxes extend by a fixed length or dynamically track the current live bar.', display = display.none)
extendLength = input.int(50, title = 'Fixed Box Extension (Bars)', minval = 1, group = grp1, tooltip = 'Horizontal width of the drawn zone boxes when Fixed Extension Mode is active.', display = display.none)
extraRight = input.int(10, title = 'Additional Extension (Bars beyond last bar)', minval = 0, group = grp1, tooltip = 'How many extra bars to push the visual boxes past the live market bar when running Dynamic Extension Mode.', display = display.none)
useInversion = input.bool(true, title = 'Enable iFVG Flip Engine', group = grp1, tooltip = 'Enables the inversion system. Broken bullish FVGs flip to bearish resistance zones; broken bearish FVGs flip to bullish support zones.', display = display.none)

grp_proj = 'Symmetrical Projection (Measured Move)'
showProj = input.bool(false, title = 'Enable Symmetrical Projection (Strong FVGs)', group = grp_proj, tooltip = 'Projects an expanded target box mapped symmetrically from the validation area back to its structural trend swing origin.', display = display.none)
projCountMax = input.int(3, title = 'Max Last Projections to Show', minval = 1, group = grp_proj, tooltip = 'Limits the number of active projection target boxes displayed concurrently on your chart to reduce visual noise.', display = display.none)
swingLen = input.int(20, title = 'Swing Origin Lookback (Bars)', minval = 5, group = grp_proj, tooltip = 'The lookback period used by the engine to seek out true swing highs and lows for projection calculation.', display = display.none)
projColor = input.color(color.new(color.blue, 92), title = 'Projection Box Color', group = grp_proj, display = display.none)
showProjMidline = input.bool(true, title = 'Draw Projection Midline', group = grp_proj, display = display.none)

grp_str = 'Strength & Volume Settings'
useStrength = input.bool(true, title = 'Enable Volume/Body Strength Detection', group = grp_str, tooltip = 'Activates algorithmic multi-variable strength evaluation checking volume and candle metrics.', display = display.none)
volSmaLength = input.int(20, title = 'Volume SMA Length', minval = 1, group = grp_str, tooltip = 'The period size for the volume moving average filter used to confirm institutional speed.', display = display.none)
useBodyFilter = input.bool(true, title = 'Downgrade Low-Body (Doji) FVGs', group = grp_str, tooltip = 'Forces the indicator to audit displacement candle composure. Gaps with low physical body-to-wick distribution ratios are flagged as weak.', display = display.none)
bodyRatio = input.float(20.0, title = 'Body-to-Range Threshold (%)', minval = 1.0, maxval = 90.0, step = 1.0, group = grp_str, tooltip = 'The minimum body size percentage of a single candlestick range (High-Low) required to qualify as full institutional momentum.', display = display.none)

grp_logic = 'Advanced Algorithmic Filtering'
usePD = input.bool(false, title = 'Downgrade PD Discrepancies (Wrong Side of 50%)', group = grp_logic, tooltip = 'Filters out gaps validating on the premium/discount premium side of the local equilibrium.', display = display.none)
useExhaust = input.bool(false, title = 'Downgrade Trend Exhaustion (4th+ FVG)', group = grp_logic, tooltip = 'Downgrades consecutive gap clusters tracking a single swing run to filter out late trend entrapment.', display = display.none)

grp_lbl = 'Label Customization'
fontSize = input.string('Tiny', title = 'Label Font Size', options = ['Tiny', 'Small', 'Normal'], group = grp_lbl, display = display.none)
lblStrongFVG = input.string('', title = 'Strong FVG Label', group = grp_lbl, display = display.none)
lblWeakFVG = input.string('Weak', title = 'Weak FVG Label', group = grp_lbl, display = display.none)
tagVol = input.string('Vol', title = 'Weak (Vol) Tag', group = grp_lbl, display = display.none)
tagDoji = input.string('Doji', title = 'Weak (Doji) Tag', group = grp_lbl, display = display.none)
tagPD = input.string('PD', title = 'Weak (PD) Tag', group = grp_lbl, display = display.none)
tagExh = input.string('Exh', title = 'Weak (Exh) Tag', group = grp_lbl, display = display.none)
lbliFVG = input.string('iFVG', title = 'Strong iFVG Label', group = grp_lbl, display = display.none)
lblWeakiFVG = input.string('Weak iFVG', title = 'Weak iFVG Label', group = grp_lbl, display = display.none)

grp2 = 'Zone Colors (Strong / Standard)'
bullColorStr = input.color(color.new(color.green, 70), title = 'Strong Bull FVG', group = grp2, display = display.none)
bearColorStr = input.color(color.new(color.red, 70), title = 'Strong Bear FVG', group = grp2, display = display.none)
bullInvColorStr = input.color(color.new(color.blue, 70), title = 'Strong Bull iFVG', group = grp2, display = display.none)
bearInvColorStr = input.color(color.new(color.orange, 70), title = 'Strong Bear iFVG', group = grp2, display = display.none)

grp3 = 'Zone Colors (Weak / Filtered)'
bullColorWk = input.color(color.new(color.green, 90), title = 'Weak Bull FVG', group = grp3, display = display.none)
bearColorWk = input.color(color.new(color.red, 90), title = 'Weak Bear FVG', group = grp3, display = display.none)
bullInvColorWk = input.color(color.new(color.blue, 90), title = 'Weak Bull iFVG', group = grp3, display = display.none)
bearInvColorWk = input.color(color.new(color.orange, 90), title = 'Weak Bear iFVG', group = grp3, display = display.none)

grp4 = 'Styling & Borders'
borderWidth = input.int(1, title = 'Border Width', minval = 0, group = grp4, display = display.none)
borderColor = input.color(color.new(color.gray, 50), title = 'Standard Border Color', group = grp4, display = display.none)
ifvgBorderColor = input.color(color.new(color.white, 30), title = 'iFVG Border Color', group = grp4, display = display.none)
showMidline = input.bool(true, title = 'Draw Midline', group = grp4, display = display.none)
midlineColor = input.color(color.new(color.gray, 60), title = 'Midline Color', group = grp4, display = display.none)

// --- Definitions ---
type FVG_Zone
	box id
	line mid_line
	float top
	float bottom
	bool isBullish
	bool isInverted
	bool isStrong
	int startBar
	string weakness_reason

type ProjTarget
	box b
	line l

var array<FVG_Zone> active_fvgs = array.new<FVG_Zone>()
var array<ProjTarget> active_projections = array.new<ProjTarget>()
var array<label> debug_arrows = array.new<label>()
var int bull_swing_origin_bar = na
var int bull_fvg_count = 0
var int bear_swing_origin_bar = na
var int bear_fvg_count = 0

// --- Functions ---
get_right(start) =>
    extType == 'Dynamic to Last Bar' ? bar_index + extraRight : start + extendLength
getSize() =>
    fontSize == 'Tiny' ? size.tiny : fontSize == 'Small' ? size.small : size.normal

// --- Detection Logic ---
vol_sma = ta.sma(volume, volSmaLength)

global_low = ta.lowest(low, swingLen)
global_low_offset = ta.lowestbars(low, swingLen)
global_high = ta.highest(high, swingLen)
global_high_offset = ta.highestbars(high, swingLen)

bull_fvg = low > high[2] and close[1] > open[1]
bear_fvg = high < low[2] and close[1] < open[1]

if bull_fvg or bear_fvg
    float top_val = bull_fvg ? low : low[2]
    float bot_val = bull_fvg ? high[2] : high
    float mid = (top_val + bot_val) / 2
    float eq_val = (global_high[2] + global_low[2]) / 2

    bool vol_failed = useStrength and not(volume[1] > vol_sma[1])
    bool body_failed = useBodyFilter and math.abs(close[1] - open[1]) / (high[1] - low[1]) * 100 < bodyRatio
    bool pd_failed = usePD and (bull_fvg and mid > eq_val or bear_fvg and mid < eq_val)

    int structural_origin = na
    float swing_extreme = na
    if bull_fvg
        int offset = global_low_offset[2]
        int current_origin = bar_index[2] + offset
        structural_origin := current_origin
        swing_extreme := global_low[2]
        bull_fvg_count := na(bull_swing_origin_bar) or current_origin != bull_swing_origin_bar ? 1 : bull_fvg_count + 1
        bull_swing_origin_bar := current_origin
        bull_swing_origin_bar
    if bear_fvg
        int offset = global_high_offset[2]
        int current_origin = bar_index[2] + offset
        structural_origin := current_origin
        swing_extreme := global_high[2]
        bear_fvg_count := na(bear_swing_origin_bar) or current_origin != bear_swing_origin_bar ? 1 : bear_fvg_count + 1
        bear_swing_origin_bar := current_origin
        bear_swing_origin_bar

    bool exhaust_failed = useExhaust and (bull_fvg ? bull_fvg_count >= 4 : bear_fvg_count >= 4)
    bool strong_status = not(vol_failed or body_failed or pd_failed or exhaust_failed)

    string reason = vol_failed ? tagVol : body_failed ? tagDoji : pd_failed ? tagPD : exhaust_failed ? tagExh : ''
    string display_text = strong_status ? lblStrongFVG : lblWeakFVG + (reason != '' ? ' (' + reason + ')' : '')

    color col = bull_fvg ? strong_status ? bullColorStr : bullColorWk : strong_status ? bearColorStr : bearColorWk
    b_box = box.new(bar_index[2], top_val, bar_index[2] + extendLength, bot_val, bgcolor = col, border_color = borderColor, border_width = borderWidth)
    l_line = showMidline ? line.new(bar_index[2], mid, bar_index[2] + extendLength, mid, color = midlineColor, style = line.style_dashed) : na

    box.set_text(b_box, display_text)
    box.set_text_color(b_box, color.new(color.gray, 50))
    box.set_text_size(b_box, getSize())
    box.set_text_halign(b_box, text.align_right)

    if showProj and strong_status
        label d_arrow = label.new(x = structural_origin, y = swing_extreme, text = bull_fvg ? '▲' : '▼', style = label.style_none, textcolor = color.purple, size = size.normal, yloc = yloc.price)
        array.push(debug_arrows, d_arrow)
        if array.size(debug_arrows) > projCountMax
            label.delete(array.shift(debug_arrows))

        float vertical_half_dist = math.abs(mid - swing_extreme)
        float mirrored_target = bull_fvg ? mid + vertical_half_dist : mid - vertical_half_dist
        float macro_top = bull_fvg ? mirrored_target : swing_extreme
        float macro_bottom = bull_fvg ? swing_extreme : mirrored_target
        float macro_mid = (macro_top + macro_bottom) / 2

        box p_box = box.new(left = structural_origin, top = macro_top, right = bar_index[2] + extendLength, bottom = macro_bottom, bgcolor = projColor, border_color = color.new(color.blue, 40), border_style = line.style_solid, border_width = 1)

        line p_line = showProjMidline ? line.new(structural_origin, macro_mid, bar_index[2] + extendLength, macro_mid, color = color.new(color.blue, 50), style = line.style_dashed) : na

        box.set_text(p_box, 'Target')
        box.set_text_color(p_box, color.blue)
        box.set_text_size(p_box, getSize())
        box.set_text_halign(p_box, text.align_right)
        box.set_text_valign(p_box, bull_fvg ? text.align_top : text.align_bottom)

        array.push(active_projections, ProjTarget.new(p_box, p_line))
        if array.size(active_projections) > projCountMax
            removed = array.shift(active_projections)
            box.delete(removed.b)
            if not na(removed.l)
                line.delete(removed.l)

    array.push(active_fvgs, FVG_Zone.new(b_box, l_line, top_val, bot_val, bull_fvg, false, strong_status, bar_index[2], reason))

// --- Management Engine ---
if array.size(active_fvgs) > 0
    for i = array.size(active_fvgs) - 1 to 0 by 1
        current_zone = array.get(active_fvgs, i)
        box.set_right(current_zone.id, get_right(current_zone.startBar))
        if not na(current_zone.mid_line)
            line.set_x2(current_zone.mid_line, get_right(current_zone.startBar))

        if bar_index - current_zone.startBar > lookback
            box.delete(current_zone.id)
            line.delete(current_zone.mid_line)
            array.remove(active_fvgs, i)
            continue

        if useInversion and not current_zone.isInverted
            if current_zone.isBullish and close < current_zone.bottom or not current_zone.isBullish and close > current_zone.top
                current_zone.isInverted := true
                color inv_col = current_zone.isStrong ? current_zone.isBullish ? bearInvColorStr : bullInvColorStr : current_zone.isBullish ? bearInvColorWk : bullInvColorWk
                box.set_bgcolor(current_zone.id, inv_col)

                string dynamic_ifvg_lbl = current_zone.isStrong ? lbliFVG : lblWeakiFVG + (current_zone.weakness_reason != '' ? ' (' + current_zone.weakness_reason + ')' : '')
                box.set_text(current_zone.id, dynamic_ifvg_lbl)
                box.set_border_color(current_zone.id, ifvgBorderColor)

        else if useInversion and current_zone.isInverted
            if current_zone.isBullish and close > current_zone.top or not current_zone.isBullish and close < current_zone.bottom
                box.delete(current_zone.id)
                line.delete(current_zone.mid_line)
                array.remove(active_fvgs, i)

// Handle dynamic extension for independent projection boxes
if extType == 'Dynamic to Last Bar' and array.size(active_projections) > 0
    for i = 0 to array.size(active_projections) - 1 by 1
        curr = array.get(active_projections, i)
        box.set_right(curr.b, bar_index + extraRight)
        if not na(curr.l)
            line.set_x2(curr.l, bar_index + extraRight)
````
