# VWAP A BE BOP

- url: https://www.tradingview.com/script/HOa7YVFX-VWAP-A-BE-BOP/
- type: indicator
- pine_id: PUB;8155818607cc420e9ee9da8d9fd1fa39
- version: 9.0

## Description

VWAP A BE BOP — Every Anchor You'll Ever Need, One Indicator

VWAP A BE BOP consolidates the anchored VWAP toolkit that traders normally piece together from three or four separate scripts into a single, clean overlay. Instead of hunting for daily VWAP here, a weekly anchor there, and a rolling previous-day reference somewhere else, every timeframe you actually trade around lives in one place — fully customizable, fully synced.

Five calendar-anchored VWAPs — Daily, Weekly, Monthly, Quarterly, and Yearly — give you the institutional reference levels that price consistently reacts to, each with its own toggle and color so you can build exactly the confluence stack your strategy calls for. Layer a fast Daily VWAP against a slower Monthly or Quarterly anchor to instantly see whether you're trading with or against the higher-timeframe flow.

Daily and Previous Day deviation bands bring statistical context to the mix. Three independently adjustable standard-deviation multipliers (defaulting to 1, 2, and 2.5) mark the zones where price has statistically stretched from fair value — classic mean-reversion and breakout-confirmation territory, without cluttering your chart with bands on every single line.

A true Previous Day VWAP, anchored precisely at session open with zero configuration required, plus optional rolling lines going back a full week — perfect for spotting how current price stacks up against where the market was trading 2, 3, or even 7 sessions ago.

Fully adjustable labels turn a wall of colored lines into an instantly readable chart. Rename any line to whatever shorthand you like — "pDay," "M," "Q" — and control label size and horizontal offset so the tags sit exactly where you want them, whether you're on a widescreen monitor or a cramped mobile chart.

Built for traders who live and die by mean reversion, fair value, and institutional order flow, VWAP A BE BOP strips away the noise of over-engineered multi-panel scripts and gives you a single, elegant, endlessly configurable VWAP suite — the last VWAP indicator you'll need to add to your chart.

For educational and informational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mikey369

indicator('VWAP A BE BOP', overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────────── Quick Setup ─────────────────────────────
g_qs = 'Quick Setup'
fam_vwap = input.bool(true, 'VWAPs (D, W, M, Q2, Y + Previous)', group = g_qs, tooltip = 'Master switch for every anchored VWAP: Daily, Previous Day, Weekly, Previous Week, Monthly, Previous Month, Q2, Yearly and 2 Days Ago. When OFF they all hide, even if individually checked. When ON, only the ones checked in their own group show.')
fam_roll = input.bool(true, 'Rolling VWAPs', group = g_qs, tooltip = 'Master switch for both Rolling VWAPs. When OFF they hide, even if individually checked.')
fam_custom = input.bool(true, 'Custom VWAPs', group = g_qs, tooltip = 'Master switch for both Custom (ATH / ATL) VWAPs. When OFF they hide, even if individually checked.')
show_hl = input.bool(true, 'Previous Period High/Low', group = g_qs, tooltip = 'Master switch for the Previous Day/Week/Month highs and lows (lines, labels, price-scale tags). When OFF they all hide, even if individually checked. When ON, only the ones checked in their own group show.')
fam_ema = input.bool(true, 'EMAs (Daily + Weekly)', group = g_qs, tooltip = 'Master switch for the 50/200 daily and weekly EMAs. When OFF they hide, even if individually checked.')
scale_mode = input.string('Custom', 'Labels on Price Scale', options = ['Custom', 'All On', 'All Off'], group = g_qs, tooltip = 'Custom: use the individual price-scale checkboxes (Labels group, and the deviation groups). All On / All Off: override all of them at once.')
price_mode = input.string('Custom', 'Price in Label', options = ['Custom', 'All On', 'All Off'], group = g_qs, tooltip = 'Custom: use the Show Price checkboxes in the Labels group. All On / All Off: override them both at once.')
mono = input.bool(false, 'Monochrome', group = g_qs, tooltip = 'Draws every VWAP, EMA and high/low line and label in one color (below) for a clean, uniform look. The deviation bands keep their own colors.')
mono_col = input.color(#d1d4dc, 'Monochrome Color', group = g_qs)

// ───────────────────────────── Shared tooltips ─────────────────────────────
tt_hide = 'Hides the line itself but keeps the label and the price-scale tag, so you still see where the level is without the extra line on your chart.'
tt_tier = 'Which label column this level uses. Tier 1 sits right next to the price. Tier 2 sits further out to the right (see Tier 2 Extra Gap in the Labels group).'
tt_label = 'The name shown in the chart label for this level. Change it to anything you like.'
tt_dev = 'Draws a band this many standard deviations above and below the VWAP. Shows only when Show Bands (Preset) is ticked for this VWAP.'
tt_devscale = 'Also shows the deviation band prices on the right-hand price scale.'

lineWidth = 1

// ───────────────────────────── Labels (Global) ─────────────────────────────
g_lbl = 'Labels'
show_labels = input.bool(true, 'Show Line Labels', group = g_lbl, tooltip = 'Master switch for every label on the chart. Turn off for lines only.')
show_conn_lines = input.bool(true, 'Show Dotted Connector Lines', group = g_lbl, tooltip = 'The dotted line that joins the end of each level to its label.')
label_size_str = input.string('Small', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = g_lbl, tooltip = 'Text size of every label.')
gap_bars = input.int(0, 'Gap: Price Line to Connector (bars)', minval = 0, group = g_lbl, tooltip = 'Blank space between the current bar (end of the price line) and where the dotted connector line begins. Applies to both tiers.')
conn_length1 = input.int(6, 'Tier 1 Connector Length (bars)', minval = 0, group = g_lbl, tooltip = 'Length of the dotted connector for Tier 1 levels (Daily/Weekly/Prev Day VWAP, PDH/PDL/PWH/PWL/PMH/PML). The label sits at the end of it.')
tier2_gap = input.int(30, 'Tier 2 Extra Gap (bars)', minval = 0, group = g_lbl, tooltip = 'Extra blank space after the Tier 1 labels before the Tier 2 connectors begin, so Tier 2 stays tucked further back (e.g. behind the price scale).')
conn_length2 = input.int(6, 'Tier 2 Connector Length (bars)', minval = 0, group = g_lbl, tooltip = 'Length of the dotted connector for Tier 2 levels. Every level below now has its own "Label Tier" option, so this applies to whichever ones are set to Tier 2.')

f_tierPos(tier, cs1, lx1, cs2, lx2) =>
    [tier == 'Tier 2' ? cs2 : cs1, tier == 'Tier 2' ? lx2 : lx1]

// Same tier-position logic as f_tierPos above, but anchored off a level's own
// effective bar (barEff) instead of the shared, always-live bar_index. Used
// only by the Previous Period High/Low labels so a frozen level's connector
// and label stay anchored at the bar it was mitigated on, rather than
// floating away from where its line actually ends.
f_hlTierPos(tier, barEff) =>
    cs1 = barEff + gap_bars
    lx1 = cs1 + conn_length1
    cs2 = lx1 + tier2_gap
    lx2 = cs2 + conn_length2
    [tier == 'Tier 2' ? cs2 : cs1, tier == 'Tier 2' ? lx2 : lx1]
lbl_transparency = input.int(100, 'Label Background Transparency', minval = 0, maxval = 100, group = g_lbl, tooltip = 'Higher = more see-through. Set to 100% to hide the background completely (text only).')
show_price_in = input.bool(false, 'Show Price (Tier 1)', group = g_lbl, tooltip = 'Adds the level price to the label text, for Tier 1 labels.')
show_price = price_mode == 'All On' ? true : price_mode == 'All Off' ? false : show_price_in
show_price_t2_in = input.bool(true, 'Show Price (Tier 2)', group = g_lbl, tooltip = 'Same as "Show Price" above, but only for labels set to Tier 2.')
show_price_t2 = price_mode == 'All On' ? true : price_mode == 'All Off' ? false : show_price_t2_in
show_pct = input.bool(false, 'Show % From Price', group = g_lbl, tooltip = 'Shows how far price currently is from each line, as a percentage: (line - price) / price. A line 1% below price reads -1%. Applies to both tiers.')
show_price_scale_in = input.bool(true, 'Labels on Price Scale (Tier 1)', group = g_lbl, tooltip = 'Matches the "Labels on price scale" checkbox on the Style tab, for Tier 1 levels only.')
show_price_scale = scale_mode == 'All On' ? true : scale_mode == 'All Off' ? false : show_price_scale_in
show_price_scale_t2_in = input.bool(false, 'Labels on Price Scale (Tier 2)', group = g_lbl, tooltip = 'Same as above, but only for labels set to Tier 2. Off by default to keep the price scale uncluttered.')
show_price_scale_t2 = scale_mode == 'All On' ? true : scale_mode == 'All Off' ? false : show_price_scale_t2_in

f_labelSize(s) =>
    s == 'Tiny' ? size.tiny : s == 'Small' ? size.small : s == 'Normal' ? size.normal : size.large

f_lineStyle(s) =>
    s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid

dispFlag = show_price_scale ? display.all : display.all - display.price_scale
combine_labels = input.bool(true, 'Combine Overlapping Labels', group = g_lbl, tooltip = 'When two or more levels sit in the same label column and within the threshold below, they share one label, e.g. PDH/pD VWAP. Levels in different columns (Tier 1 vs Tier 2, or a frozen level anchored at its mitigation bar) never combine.')
overlap_pct = input.float(0.1, 'Combine Threshold (%)', minval = 0.0, step = 0.05, group = g_lbl, tooltip = 'Levels within this percentage of the first level in a label are merged into it.')
priceOnlyDispFlag = show_price_scale ? display.price_scale + display.status_line : display.status_line
dispFlagT2 = show_price_scale_t2 ? display.all : display.all - display.price_scale
priceOnlyDispFlagT2 = show_price_scale_t2 ? display.price_scale + display.status_line : display.status_line

f_pct(val) =>
    (val - close) / close * 100

f_buildText(baseTxt, val, isTier2) =>
    txt = baseTxt
    priceOn = isTier2 ? show_price_t2 : show_price
    if priceOn
        txt := txt + ' (' + str.tostring(val, format.mintick) + ')'
    if show_pct
        txt := txt + ' (' + str.tostring(f_pct(val), '#.##') + '%)'
    txt

var label[] allLabels = array.new<label>(26, na)
var line[]  allConnLines = array.new<line>(26, na)

var float[]  cVal  = array.new<float>()
var string[] cTxt  = array.new<string>()
var color[]  cCol  = array.new<color>()
var int[]    cCs   = array.new<int>()
var int[]    cLx   = array.new<int>()
var bool[]   cT2   = array.new<bool>()
var bool[]   cUsed = array.new<bool>()

f_near(a, b) =>
    b != 0 and math.abs(a - b) / math.abs(b) * 100 < overlap_pct

f_collect(show, val, col, baseTxt, cs, lx, isTier2) =>
    if show and not na(val)
        array.push(cVal, val)
        array.push(cTxt, baseTxt)
        array.push(cCol, col)
        array.push(cCs, cs)
        array.push(cLx, lx)
        array.push(cT2, isTier2)
        array.push(cUsed, false)

f_clearSlot(idx) =>
    l = array.get(allLabels, idx)
    if not na(l)
        label.delete(l)
        array.set(allLabels, idx, na)
    ln = array.get(allConnLines, idx)
    if not na(ln)
        line.delete(ln)
        array.set(allConnLines, idx, na)


f_updateLabelLine(idx, show, val, col, baseTxt, connStartX, lblX, lblSz, isTier2) =>
    if show and not na(val)
        txt = f_buildText(baseTxt, val, isTier2)
        bgCol = color.new(col, lbl_transparency)
        existingLbl = array.get(allLabels, idx)
        if na(existingLbl)
            newLbl = label.new(lblX, val, txt, xloc.bar_index, yloc.price, color = bgCol, style = label.style_label_left, textcolor = col, size = lblSz)
            array.set(allLabels, idx, newLbl)
        else
            label.set_xy(existingLbl, lblX, val)
            label.set_text(existingLbl, txt)
            label.set_color(existingLbl, bgCol)
            label.set_textcolor(existingLbl, col)
            label.set_size(existingLbl, lblSz)
        if show_conn_lines
            existingLine = array.get(allConnLines, idx)
            if na(existingLine)
                newLine = line.new(connStartX, val, lblX, val, xloc.bar_index, color = col, style = line.style_dotted, width = 1)
                array.set(allConnLines, idx, newLine)
            else
                line.set_xy1(existingLine, connStartX, val)
                line.set_xy2(existingLine, lblX, val)
        else
            existingLineOff = array.get(allConnLines, idx)
            if not na(existingLineOff)
                line.delete(existingLineOff)
                array.set(allConnLines, idx, na)
    else
        existingLbl2 = array.get(allLabels, idx)
        if not na(existingLbl2)
            label.delete(existingLbl2)
            array.set(allLabels, idx, na)
        existingLine2 = array.get(allConnLines, idx)
        if not na(existingLine2)
            line.delete(existingLine2)
            array.set(allConnLines, idx, na)

presetTT = 'Master switch for this group. When OFF, none of the deviation bands below will display, even if individually checked. When ON, only the bands checked below will show. Use this to pre-configure your bands with the preset off, then flip this on to reveal them all at once.'

// ───────────────────────────── Daily ─────────────────────────────
g_d = 'Daily VWAP'
show_daily_in = input.bool(true, 'Show Daily VWAP', group = g_d)
show_daily = fam_vwap and show_daily_in
col_daily_in = input.color(#00ffdd, 'Daily VWAP Color', group = g_d)
col_daily = mono ? mono_col : col_daily_in
lbl_daily = input.string('D VWAP', 'Label Text', group = g_d, tooltip = tt_label)
hide_daily_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'dstyle', group = g_d, tooltip = tt_hide)
tier_daily = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'dstyle', group = g_d, tooltip = tt_tier)
showDailyBands = input.bool(false, 'Show Bands (Preset)', group = g_d, tooltip = presetTT)
show_d1 = input.bool(true,  'Deviation 1', inline = 'd1', group = g_d, tooltip = tt_dev)
dev_d1 = input.float(1.0, '', inline = 'd1', group = g_d)
col_d1 = input.color(color.new(#4a4a4a, 40), 'Dev 1 Color', group = g_d)
show_d2 = input.bool(true,  'Deviation 2', inline = 'd2', group = g_d, tooltip = tt_dev)
dev_d2 = input.float(2.0, '', inline = 'd2', group = g_d)
col_d2 = input.color(color.new(#4a4a4a, 40), 'Dev 2 Color', group = g_d)
show_d3 = input.bool(true,  'Deviation 3', inline = 'd3', group = g_d, tooltip = tt_dev)
dev_d3 = input.float(2.5, '', inline = 'd3', group = g_d)
col_d3 = input.color(color.new(#4a4a4a, 40), 'Dev 3 Color', group = g_d)
show_d_dev_pricescale_in = input.bool(false, 'Deviation Labels on Price Scale', group = g_d, tooltip = tt_devscale)
show_d_dev_pricescale = scale_mode == 'All On' ? true : scale_mode == 'All Off' ? false : show_d_dev_pricescale_in
dDevDispFlag = show_d_dev_pricescale ? display.all : display.all - display.price_scale

// ───────────────────────────── Previous Day VWAP (lives under Daily VWAP) ─────────────────────────────
g_rd = g_d
show_prevday_in = input.bool(true, 'Show Previous Day VWAP', group = g_rd)
show_prevday = fam_vwap and show_prevday_in
col_prevday_in = input.color(#90bff9, 'Prev Day VWAP Color', group = g_rd)
col_prevday = mono ? mono_col : col_prevday_in
lbl_prevday = input.string('pD VWAP', 'Prev Day Label Text', group = g_rd, tooltip = tt_label)
hide_prevday_line = input.bool(false, 'Hide Prev Day Line (Price Only)', inline = 'pdvstyle', group = g_rd, tooltip = tt_hide)
tier_prevday = input.string('Tier 1', 'Prev Day Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'pdvstyle', group = g_rd, tooltip = tt_tier)
showPDBands = input.bool(false, 'Show Prev Day Bands (Preset)', group = g_rd, tooltip = presetTT)
show_p1 = input.bool(true,  'Prev Day Deviation 1', inline = 'p1', group = g_rd, tooltip = tt_dev)
dev_p1 = input.float(1.0, '', inline = 'p1', group = g_rd)
col_p1 = input.color(color.new(#4a4a4a, 40), 'Prev Day Dev 1 Color', group = g_rd)
show_p2 = input.bool(true,  'Prev Day Deviation 2', inline = 'p2', group = g_rd, tooltip = tt_dev)
dev_p2 = input.float(2.0, '', inline = 'p2', group = g_rd)
col_p2 = input.color(color.new(#4a4a4a, 40), 'Prev Day Dev 2 Color', group = g_rd)
show_p3 = input.bool(true,  'Prev Day Deviation 3', inline = 'p3', group = g_rd, tooltip = tt_dev)
dev_p3 = input.float(2.5, '', inline = 'p3', group = g_rd)
col_p3 = input.color(color.new(#4a4a4a, 40), 'Prev Day Dev 3 Color', group = g_rd)
show_p_dev_pricescale_in = input.bool(false, 'Prev Day Deviation Labels on Price Scale', group = g_rd, tooltip = tt_devscale)
show_p_dev_pricescale = scale_mode == 'All On' ? true : scale_mode == 'All Off' ? false : show_p_dev_pricescale_in
pDevDispFlag = show_p_dev_pricescale ? display.all : display.all - display.price_scale

// ───────────────────────────── Weekly ─────────────────────────────
g_w = 'Weekly VWAP'
show_weekly_in = input.bool(true, 'Show Weekly VWAP', group = g_w)
show_weekly = fam_vwap and show_weekly_in
col_weekly_in = input.color(#dbdbdb, 'Weekly VWAP Color', group = g_w)
col_weekly = mono ? mono_col : col_weekly_in
lbl_weekly = input.string('W VWAP', 'Label Text', group = g_w, tooltip = tt_label)
hide_weekly_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'wstyle', group = g_w, tooltip = tt_hide)
tier_weekly = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'wstyle', group = g_w, tooltip = tt_tier)

// ───────────────────────────── Previous Week VWAP (lives under Weekly VWAP) ─────────────────────────────
g_pw = g_w
show_prevweek_in = input.bool(true, 'Show Previous Week VWAP', group = g_pw)
show_prevweek = fam_vwap and show_prevweek_in
col_prevweek_in = input.color(#ffffff, 'Prev Week VWAP Color', group = g_pw)
col_prevweek = mono ? mono_col : col_prevweek_in
lbl_prevweek = input.string('pW VWAP', 'Prev Week Label Text', group = g_pw, tooltip = tt_label)
hide_prevweek_line = input.bool(true, 'Hide Prev Week Line (Price Only)', inline = 'pwvstyle', group = g_pw, tooltip = tt_hide)
tier_prevweek = input.string('Tier 2', 'Prev Week Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'pwvstyle', group = g_pw, tooltip = tt_tier)

// ───────────────────────────── Monthly ─────────────────────────────
g_m = 'Monthly VWAP'
show_monthly_in = input.bool(true, 'Show Monthly VWAP', group = g_m)
show_monthly = fam_vwap and show_monthly_in
col_monthly_in = input.color(#ae4ce6, 'Monthly VWAP Color', group = g_m)
col_monthly = mono ? mono_col : col_monthly_in
lbl_monthly = input.string('M VWAP', 'Label Text', group = g_m, tooltip = tt_label)
hide_monthly_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'mstyle', group = g_m, tooltip = tt_hide)
tier_monthly = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'mstyle', group = g_m, tooltip = tt_tier)

// ───────────────────────────── Previous Month VWAP (lives under Monthly VWAP) ─────────────────────────────
g_pm = g_m
show_prevmonth_in = input.bool(true, 'Show Previous Month VWAP', group = g_pm)
show_prevmonth = fam_vwap and show_prevmonth_in
col_prevmonth_in = input.color(#ae4ce6, 'Prev Month VWAP Color', group = g_pm)
col_prevmonth = mono ? mono_col : col_prevmonth_in
lbl_prevmonth = input.string('pM VWAP', 'Prev Month Label Text', group = g_pm, tooltip = tt_label)
hide_prevmonth_line = input.bool(true, 'Hide Prev Month Line (Price Only)', inline = 'pmvstyle', group = g_pm, tooltip = tt_hide)
tier_prevmonth = input.string('Tier 2', 'Prev Month Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'pmvstyle', group = g_pm, tooltip = tt_tier)

// ───────────────────────────── Q2 VWAP ─────────────────────────────
g_q2 = 'Q2 VWAP'
show_q2_in = input.bool(true, 'Show Q2 VWAP', group = g_q2)
show_q2 = fam_vwap and show_q2_in
col_q2_in = input.color(#08993c, 'Q2 VWAP Color', group = g_q2)
col_q2 = mono ? mono_col : col_q2_in
lbl_q2 = input.string('Q2 VWAP', 'Label Text', group = g_q2, tooltip = tt_label)
hide_q2_line = input.bool(true, 'Hide Line (Show Price Only)', inline = 'q2style', group = g_q2, tooltip = tt_hide)
tier_q2 = input.string('Tier 2', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'q2style', group = g_q2, tooltip = tt_tier)

// ───────────────────────────── Yearly ─────────────────────────────
g_y = 'Yearly VWAP'
show_yearly_in = input.bool(true, 'Show Yearly VWAP', group = g_y)
show_yearly = fam_vwap and show_yearly_in
col_yearly_in = input.color(#fbc02d, 'Yearly VWAP Color', group = g_y)
col_yearly = mono ? mono_col : col_yearly_in
lbl_yearly = input.string('Y VWAP', 'Label Text', group = g_y, tooltip = tt_label)
hide_yearly_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'ystyle', group = g_y, tooltip = tt_hide)
tier_yearly = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'ystyle', group = g_y, tooltip = tt_tier)

// ───────────────────────────── Rolling Day (2 Days Ago) ─────────────────────────────
g_day2 = 'Rolling Day (2 Days Ago)'
show_day2_in = input.bool(false, 'Show 2 Days Ago VWAP', group = g_day2)
show_day2 = fam_vwap and show_day2_in
col_day2_in = input.color(#90bff9, '2 Days Ago Color', group = g_day2)
col_day2 = mono ? mono_col : col_day2_in
lbl_day2 = input.string('ppD VWAP', 'Label Text', group = g_day2, tooltip = tt_label)
hide_day2_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'day2style', group = g_day2, tooltip = tt_hide)
tier_day2 = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'day2style', group = g_day2, tooltip = tt_tier)

// ───────────────────────────── Rolling VWAPs (sliding window, adjustable) ─────────────────────────────
g_roll = 'Rolling VWAPs'
show_rvwap1_in = input.bool(false, 'Show Rolling VWAP 1', group = g_roll)
show_rvwap1 = fam_roll and show_rvwap1_in
days_rvwap1 = input.int(30, 'Lookback (Days)', minval = 1, group = g_roll, tooltip = 'How many days back this Rolling VWAP looks. It slides forward with every bar instead of resetting.')
col_rvwap1_in = input.color(#26c6da, 'Rolling VWAP 1 Color', group = g_roll)
col_rvwap1 = mono ? mono_col : col_rvwap1_in
lbl_rvwap1_custom = input.string('', 'Label Text (blank = auto)', group = g_roll, tooltip = 'Leave blank for automatic text such as 30d rVWAP, or type your own.')
hide_rvwap1_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'rv1style', group = g_roll, tooltip = tt_hide)
tier_rvwap1 = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'rv1style', group = g_roll, tooltip = tt_tier)

show_rvwap2_in = input.bool(true, 'Show Rolling VWAP 2', group = g_roll)
show_rvwap2 = fam_roll and show_rvwap2_in
days_rvwap2 = input.int(365, 'Lookback (Days)', minval = 1, group = g_roll, tooltip = 'How many days back this Rolling VWAP looks. It slides forward with every bar instead of resetting.')
col_rvwap2_in = input.color(#ff5252, 'Rolling VWAP 2 Color', group = g_roll)
col_rvwap2 = mono ? mono_col : col_rvwap2_in
lbl_rvwap2_custom = input.string('', 'Label Text (blank = auto)', group = g_roll, tooltip = 'Leave blank for automatic text such as 365d rVWAP, or type your own.')
hide_rvwap2_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'rv2style', group = g_roll, tooltip = tt_hide)
tier_rvwap2 = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'rv2style', group = g_roll, tooltip = tt_tier)

// ───────────────────────────── Custom VWAPs ─────────────────────────────
g_custom = 'Custom VWAPs'
show_custom1_in = input.bool(true, 'Custom VWAP 1 (ATH)', group = g_custom)
show_custom1 = fam_custom and show_custom1_in
custom1_date = input.time(timestamp('2025-10-06T14:00:00-04:00'), 'Anchor Date/Time #1', group = g_custom, tooltip = 'This VWAP starts calculating from this date and time. Pick the swing high, low or event you want to anchor to.')
col_custom1_in = input.color(#ff0000, 'Custom 1 Color', group = g_custom)
col_custom1 = mono ? mono_col : col_custom1_in
lbl_custom1 = input.string('ATH VWAP', 'Label Text #1', group = g_custom, tooltip = tt_label)
hide_custom1_line = input.bool(true, 'Hide Line (Show Price Only)', inline = 'c1style', group = g_custom, tooltip = tt_hide)
tier_custom1 = input.string('Tier 2', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'c1style', group = g_custom, tooltip = tt_tier)

show_custom2_in = input.bool(true, 'Custom VWAP 2 (ATL)', group = g_custom)
show_custom2 = fam_custom and show_custom2_in
custom2_date = input.time(timestamp('2026-06-30T21:00:00-04:00'), 'Anchor Date/Time #2', group = g_custom, tooltip = 'This VWAP starts calculating from this date and time. Pick the swing high, low or event you want to anchor to.')
col_custom2_in = input.color(#ff0000, 'Custom 2 Color', group = g_custom)
col_custom2 = mono ? mono_col : col_custom2_in
lbl_custom2 = input.string('ATL VWAP', 'Label Text #2', group = g_custom, tooltip = tt_label)
hide_custom2_line = input.bool(true, 'Hide Line (Show Price Only)', inline = 'c2style', group = g_custom, tooltip = tt_hide)
tier_custom2 = input.string('Tier 2', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'c2style', group = g_custom, tooltip = tt_tier)

// ───────────────────────────── Previous Period High/Low (wick-anchored rays) ─────────────────────────────
g_hl = 'Previous Period High/Low'
show_pdh_in = input.bool(true, 'Previous Day High', group = g_hl)
show_pdl_in = input.bool(true, 'Previous Day Low', group = g_hl)
col_pd_in = input.color(#808080, 'Prev Day High/Low Color', group = g_hl)
col_pd = mono ? mono_col : col_pd_in
hide_pd_lines = input.bool(false, 'Hide Line (Show Price Only)', group = g_hl, inline = 'pdstyle', tooltip = tt_hide)
style_pd = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_hl, inline = 'pdstyle')
tier_pd = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], group = g_hl, inline = 'pdstyle', tooltip = tt_tier)

show_wh_in = input.bool(true, 'Previous Week High', group = g_hl)
show_wl_in = input.bool(true, 'Previous Week Low', group = g_hl)
col_pw_in = input.color(#808080, 'Prev Week High/Low Color', group = g_hl)
col_pw = mono ? mono_col : col_pw_in
hide_pw_lines = input.bool(false, 'Hide Line (Show Price Only)', group = g_hl, inline = 'pwstyle', tooltip = tt_hide)
style_pw = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_hl, inline = 'pwstyle')
tier_pw = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], group = g_hl, inline = 'pwstyle', tooltip = tt_tier)

show_mh_in = input.bool(true, 'Previous Month High', group = g_hl)
show_ml_in = input.bool(true, 'Previous Month Low', group = g_hl)
col_pm_hl_in = input.color(#808080, 'Prev Month High/Low Color', group = g_hl)
col_pm_hl = mono ? mono_col : col_pm_hl_in
hide_pm_lines = input.bool(false, 'Hide Line (Show Price Only)', group = g_hl, inline = 'pmstyle', tooltip = tt_hide)
style_pm = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_hl, inline = 'pmstyle')
tier_pm = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], group = g_hl, inline = 'pmstyle', tooltip = tt_tier)

lbl_pdh = input.string('PDH', 'Label Text (Prev Day High)', group = g_hl, tooltip = tt_label)
lbl_pdl = input.string('PDL', 'Label Text (Prev Day Low)', group = g_hl, tooltip = tt_label)
lbl_wh = input.string('PWH', 'Label Text (Prev Week High)', group = g_hl, tooltip = tt_label)
lbl_wl = input.string('PWL', 'Label Text (Prev Week Low)', group = g_hl, tooltip = tt_label)
lbl_mh = input.string('PMH', 'Label Text (Prev Month High)', group = g_hl, tooltip = tt_label)
lbl_ml = input.string('PML', 'Label Text (Prev Month Low)', group = g_hl, tooltip = tt_label)

show_pdh = show_hl and show_pdh_in
show_pdl = show_hl and show_pdl_in
show_wh = show_hl and show_wh_in
show_wl = show_hl and show_wl_in
show_mh = show_hl and show_mh_in
show_ml = show_hl and show_ml_in

mitigationMode = input.string('Freeze Line', 'On Mitigation', options = ['Keep Extending', 'Freeze Line', 'Remove Level'], group = g_hl, tooltip = 'Keep Extending: lines behave as before. Freeze Line: once price trades through a level, its line and label stop extending and stay fixed where mitigation happened, and its price-scale tag is removed. Remove Level: the line, label, and price-scale tag all disappear once mitigated.')

// ───────────────────────────── EMAs ─────────────────────────────
g_ema = 'EMAs (Daily Timeframe)'
show_ema50_in = input.bool(true, 'Show 50 EMA', group = g_ema)
show_ema50 = fam_ema and show_ema50_in
col_ema50_in = input.color(#3fff00, '50 EMA Color', group = g_ema)
col_ema50 = mono ? mono_col : col_ema50_in
hide_ema50_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'e50style', group = g_ema, tooltip = tt_hide)
tier_ema50 = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'e50style', group = g_ema, tooltip = tt_tier)
lbl_ema50 = input.string('50d EMA', 'Label Text (50 EMA)', group = g_ema, tooltip = tt_label)

show_ema200_in = input.bool(true, 'Show 200 EMA', group = g_ema)
show_ema200 = fam_ema and show_ema200_in
col_ema200_in = input.color(#2962ff, '200 EMA Color', group = g_ema)
col_ema200 = mono ? mono_col : col_ema200_in
hide_ema200_line = input.bool(false, 'Hide Line (Show Price Only)', inline = 'e200style', group = g_ema, tooltip = tt_hide)
tier_ema200 = input.string('Tier 1', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'e200style', group = g_ema, tooltip = tt_tier)
lbl_ema200 = input.string('200d EMA', 'Label Text (200 EMA)', group = g_ema, tooltip = tt_label)

g_emaw = 'EMAs (Weekly Timeframe)'
show_ema50w_in = input.bool(true, 'Show 50 EMA (Weekly)', group = g_emaw)
show_ema50w = fam_ema and show_ema50w_in
col_ema50w_in = input.color(#22ab94, '50w EMA Color', group = g_emaw)
col_ema50w = mono ? mono_col : col_ema50w_in
hide_ema50w_line = input.bool(true, 'Hide Line (Show Price Only)', inline = 'e50wstyle', group = g_emaw, tooltip = tt_hide)
tier_ema50w = input.string('Tier 2', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'e50wstyle', group = g_emaw, tooltip = tt_tier)
lbl_ema50w = input.string('50w EMA', 'Label Text (50w EMA)', group = g_emaw, tooltip = tt_label)

show_ema200w_in = input.bool(true, 'Show 200 EMA (Weekly)', group = g_emaw)
show_ema200w = fam_ema and show_ema200w_in
col_ema200w_in = input.color(#5b9cf6, '200w EMA Color', group = g_emaw)
col_ema200w = mono ? mono_col : col_ema200w_in
hide_ema200w_line = input.bool(true, 'Hide Line (Show Price Only)', inline = 'e200wstyle', group = g_emaw, tooltip = tt_hide)
tier_ema200w = input.string('Tier 2', 'Label Tier', options = ['Tier 1', 'Tier 2'], inline = 'e200wstyle', group = g_emaw, tooltip = tt_tier)
lbl_ema200w = input.string('200w EMA', 'Label Text (200w EMA)', group = g_emaw, tooltip = tt_label)

// ───────────────────────────── Settings ─────────────────────────────
g_set = 'Settings'
zone = input.string('GMT', title = 'Timezone', options = ['GMT-11', 'GMT-10', 'GMT-9', 'GMT-8', 'GMT-7', 'GMT-6', 'GMT-5', 'GMT-4', 'GMT-3', 'GMT-2', 'GMT-1', 'GMT', 'GMT+1', 'GMT+2', 'GMT+3', 'GMT+330', 'GMT+4', 'GMT+430', 'GMT+5', 'GMT+530', 'GMT+6', 'GMT+7', 'GMT+8', 'GMT+9', 'GMT+10', 'GMT+11', 'GMT+12'], group = g_set, tooltip = 'Timezone used for the Weekly, Monthly, Q2 and Yearly resets. The Daily VWAP always resets at 8 PM New York time.')
vwap_source = input.source(hlc3, 'VWAP Source', group = g_set, tooltip = 'The price every VWAP is calculated from. hlc3 (the average of high, low and close) is the usual choice.')
show_hist = input.bool(false, 'Show Historical Periods?', group = g_set, tooltip = 'Ticked shows all historical anchor resets. Unticked shows only the most recent period.')

// Each level's own "Label Tier" input now also decides which price-scale flag (Tier 1's
// show_price_scale, or Tier 2's show_price_scale_t2) it draws from, so the two checkboxes in the
// Labels group can blank Tier 1 and Tier 2 off the price scale independently.
f_hideDispFlag(hideLine, isTier2) =>
    base = isTier2 ? dispFlagT2 : dispFlag
    hideLine ? base - display.pane : base

ema50DispFlag = f_hideDispFlag(hide_ema50_line, tier_ema50 == 'Tier 2')
ema200DispFlag = f_hideDispFlag(hide_ema200_line, tier_ema200 == 'Tier 2')
ema50wDispFlag = f_hideDispFlag(hide_ema50w_line, tier_ema50w == 'Tier 2')
ema200wDispFlag = f_hideDispFlag(hide_ema200w_line, tier_ema200w == 'Tier 2')

dailyDispFlag = f_hideDispFlag(hide_daily_line, tier_daily == 'Tier 2')
weeklyDispFlag = f_hideDispFlag(hide_weekly_line, tier_weekly == 'Tier 2')
monthlyDispFlag = f_hideDispFlag(hide_monthly_line, tier_monthly == 'Tier 2')
q2DispFlag = f_hideDispFlag(hide_q2_line, tier_q2 == 'Tier 2')
yearlyDispFlag = f_hideDispFlag(hide_yearly_line, tier_yearly == 'Tier 2')
prevdayVwapDispFlag = f_hideDispFlag(hide_prevday_line, tier_prevday == 'Tier 2')
prevweekDispFlag = f_hideDispFlag(hide_prevweek_line, tier_prevweek == 'Tier 2')
prevmonthDispFlag = f_hideDispFlag(hide_prevmonth_line, tier_prevmonth == 'Tier 2')
day2DispFlag = f_hideDispFlag(hide_day2_line, tier_day2 == 'Tier 2')
rvwap1DispFlag = f_hideDispFlag(hide_rvwap1_line, tier_rvwap1 == 'Tier 2')
rvwap2DispFlag = f_hideDispFlag(hide_rvwap2_line, tier_rvwap2 == 'Tier 2')
custom1DispFlag = f_hideDispFlag(hide_custom1_line, tier_custom1 == 'Tier 2')
custom2DispFlag = f_hideDispFlag(hide_custom2_line, tier_custom2 == 'Tier 2')

f_priceOnlyTier(isTier2) =>
    isTier2 ? priceOnlyDispFlagT2 : priceOnlyDispFlag

// ───────────────────────────── Rolling Day 1 & 2 Anchors ─────────────────────────────
// Daily anchors to 8:00 PM New York time (start of the Asia session), not to midnight in
// the user-selected `zone`. This is a fixed New-York-time boundary independent of `zone`,
// which is still used for week/month/quarter/year anchors below.
sessionHourFinal = 0
sessionMinuteFinal = 0

msPerDay = 86400000
todayY = year(timenow, zone)
todayM = month(timenow, zone)
todayD = dayofmonth(timenow, zone)
startOfToday = timestamp(zone, todayY, todayM, todayD, sessionHourFinal, sessionMinuteFinal, 0)

nyZone = 'America/New_York'

f_sessionStart(t) =>
    y = year(t, nyZone)
    m = month(t, nyZone)
    d = dayofmonth(t, nyZone)
    anchor = timestamp(nyZone, y, m, d, 20, 0, 0)
    t >= anchor ? anchor : anchor - msPerDay

dailySessionStart = f_sessionStart(timenow)
currentDayAnchor = time >= dailySessionStart and time[1] < dailySessionStart

autoDate1 = dailySessionStart - 1 * msPerDay
prevDayStart = time >= autoDate1 and time[1] < autoDate1

autoDate2 = dailySessionStart - 2 * msPerDay
day2Start = time >= autoDate2 and time[1] < autoDate2

// ───────────────────────────── Previous Week / Month Anchors ─────────────────────────────
nowDow = dayofweek(timenow, zone)
daysSinceMonday = (nowDow - 2 + 7) % 7
thisWeekMonday = startOfToday - daysSinceMonday * msPerDay
prevWeekStart = thisWeekMonday - 7 * msPerDay

prevMonthY = todayM == 1 ? todayY - 1 : todayY
prevMonthM = todayM == 1 ? 12 : todayM - 1
prevMonthStart = timestamp(zone, prevMonthY, prevMonthM, 1, 0, 0, 0)
thisMonthStart = timestamp(zone, todayY, todayM, 1, 0, 0, 0)

prevWeekAnchor = time >= prevWeekStart and time[1] < prevWeekStart
prevMonthAnchor = time >= prevMonthStart and time[1] < prevMonthStart
currentWeekAnchor = time >= thisWeekMonday and time[1] < thisWeekMonday
currentMonthAnchor = time >= thisMonthStart and time[1] < thisMonthStart

custom1Start = time >= custom1_date and time[1] < custom1_date
custom2Start = time >= custom2_date and time[1] < custom2_date

// ───────────────────────────── Previous-Period-Only Anchors (for "unchecked" freeze) ─────────────────────────────
// When "Show Historical Periods" is off, the anchor should fire EXACTLY ONCE — at the start of the last
// COMPLETED period — and never again. That blanks everything before that point (so older history doesn't
// show, matching "shows only the most recent period") and, critically, does NOT re-fire at the start of the
// still-forming current period, so the line just keeps accumulating through it instead of snapping to a
// fresh anchor. This reuses the exact anchor points your Previous Day/Week/Month VWAP levels already use,
// so e.g. Monthly VWAP (unticked) will track Previous Month VWAP for the rest of the current month — they
// share the same anchor by construction, re-syncing together at each new month/week/etc.
prevYearStart = timestamp(zone, todayY - 1, 1, 1, 0, 0, 0)
prevYearOnlyAnchor = time >= prevYearStart and time[1] < prevYearStart
thisYearStart = timestamp(zone, todayY, 1, 1, 0, 0, 0)
currentYearAnchor = time >= thisYearStart and time[1] < thisYearStart

currentQ2Y = todayM >= 4 ? todayY : todayY - 1
prevQ2Y = currentQ2Y - 1
prevQ2Start = timestamp(zone, prevQ2Y, 4, 1, 0, 0, 0)
prevQ2OnlyAnchor = time >= prevQ2Start and time[1] < prevQ2Start
thisQ2Start = timestamp(zone, currentQ2Y, 4, 1, 0, 0, 0)
currentQ2Anchor = time >= thisQ2Start and time[1] < thisQ2Start

// ───────────────────────────── Anchor Change Detection ─────────────────────────────
year_change_raw = year(time, zone) != year(time[1], zone)
year_change = show_hist ? year_change_raw : currentYearAnchor

q2_raw = month(time, zone) == 4 and month(time[1], zone) == 3
q2_change = show_hist ? q2_raw : currentQ2Anchor

month_change_raw = month(time, zone) != month(time[1], zone)
month_change = show_hist ? month_change_raw : currentMonthAnchor

week_change_raw = dayofweek(time, zone) == 2 and dayofweek(time[1], zone) == 1
week_change = show_hist ? week_change_raw : currentWeekAnchor

day_change_raw = f_sessionStart(time) != f_sessionStart(time[1])
day_change = show_hist ? day_change_raw : currentDayAnchor

// ───────────────────────────── VWAP Calculations ─────────────────────────────
[daily_vwap, daily_up1, daily_lo1] = ta.vwap(show_daily ? vwap_source : na, day_change, dev_d1)
[_, daily_up2, daily_lo2] = ta.vwap(show_daily ? vwap_source : na, day_change, dev_d2)
[_, daily_up3, daily_lo3] = ta.vwap(show_daily ? vwap_source : na, day_change, dev_d3)

[weekly_vwap, _, _] = ta.vwap(show_weekly ? vwap_source : na, week_change, 1)
[monthly_vwap, _, _] = ta.vwap(show_monthly ? vwap_source : na, month_change, 1)
[q2_vwap, _, _] = ta.vwap(show_q2 ? vwap_source : na, q2_change, 1)
[yearly_vwap, _, _] = ta.vwap(show_yearly ? vwap_source : na, year_change, 1)

[prevday_vwap, prevday_up1, prevday_lo1] = ta.vwap(show_prevday ? vwap_source : na, prevDayStart, dev_p1)
[_, prevday_up2, prevday_lo2] = ta.vwap(show_prevday ? vwap_source : na, prevDayStart, dev_p2)
[_, prevday_up3, prevday_lo3] = ta.vwap(show_prevday ? vwap_source : na, prevDayStart, dev_p3)

[prevweek_vwap, _, _] = ta.vwap(show_prevweek ? vwap_source : na, prevWeekAnchor, 1)
[prevmonth_vwap, _, _] = ta.vwap(show_prevmonth ? vwap_source : na, prevMonthAnchor, 1)

[day2_vwap, _, _] = ta.vwap(show_day2 ? vwap_source : na, day2Start, 1)

[custom1_vwap, _, _] = ta.vwap(show_custom1 ? vwap_source : na, custom1Start, 1)
[custom2_vwap, _, _] = ta.vwap(show_custom2 ? vwap_source : na, custom2Start, 1)


// ───────────────────────────── Rolling (Sliding Window) VWAPs ─────────────────────────────
f_rollingVWAP(days) =>
    secPerBar = timeframe.in_seconds()
    barsPerDay = secPerBar > 0 ? 86400.0 / secPerBar : 1440.0
    lenBars = int(math.min(4999, math.max(1, math.round(days * barsPerDay))))
    math.sum(vwap_source * volume, lenBars) / math.sum(volume, lenBars)

rvwap1 = f_rollingVWAP(days_rvwap1)
rvwap2 = f_rollingVWAP(days_rvwap2)
lbl_rvwap1 = lbl_rvwap1_custom == '' ? str.tostring(days_rvwap1) + 'd rVWAP' : lbl_rvwap1_custom
lbl_rvwap2 = lbl_rvwap2_custom == '' ? str.tostring(days_rvwap2) + 'd rVWAP' : lbl_rvwap2_custom

// ───────────────────────────── True Daily / Weekly EMAs ─────────────────────────────
ema50_daily = request.security(syminfo.tickerid, 'D', ta.ema(close, 50))
ema200_daily = request.security(syminfo.tickerid, 'D', ta.ema(close, 200))
ema50_weekly = request.security(syminfo.tickerid, 'W', ta.ema(close, 50))
ema200_weekly = request.security(syminfo.tickerid, 'W', ta.ema(close, 200))

var float ema50d_hold = na
var float ema200d_hold = na
var float ema50w_hold = na
var float ema200w_hold = na
if not na(ema50_daily)
    ema50d_hold := ema50_daily
if not na(ema200_daily)
    ema200d_hold := ema200_daily
if not na(ema50_weekly)
    ema50w_hold := ema50_weekly
if not na(ema200_weekly)
    ema200w_hold := ema200_weekly

// ───────────────────────────── Previous Period High/Low (wick-anchored rays) ─────────────────────────────
// Tracks the actual high/low bar as it forms, then locks it in at the period
// boundary — the ray starts from the literal bar where the wick printed.
newDay = timeframe.change('D')
newWeek = timeframe.change('W')
newMonth = timeframe.change('M')

var float dayHigh = na
var float dayLow = na
var int dayHighBar = na
var int dayLowBar = na
var float pDayHigh = na
var float pDayLow = na
var int pDayHighBar = na
var int pDayLowBar = na

if newDay
    pDayHigh := dayHigh
    pDayLow := dayLow
    pDayHighBar := dayHighBar
    pDayLowBar := dayLowBar
    dayHigh := high
    dayLow := low
    dayHighBar := bar_index
    dayLowBar := bar_index
else
    if high > dayHigh
        dayHigh := high
        dayHighBar := bar_index
    if low < dayLow
        dayLow := low
        dayLowBar := bar_index

var float weekHigh = na
var float weekLow = na
var int weekHighBar = na
var int weekLowBar = na
var float pWeekHigh = na
var float pWeekLow = na
var int pWeekHighBar = na
var int pWeekLowBar = na

if newWeek
    pWeekHigh := weekHigh
    pWeekLow := weekLow
    pWeekHighBar := weekHighBar
    pWeekLowBar := weekLowBar
    weekHigh := high
    weekLow := low
    weekHighBar := bar_index
    weekLowBar := bar_index
else
    if high > weekHigh
        weekHigh := high
        weekHighBar := bar_index
    if low < weekLow
        weekLow := low
        weekLowBar := bar_index

var float monthHigh = na
var float monthLow = na
var int monthHighBar = na
var int monthLowBar = na
var float pMonthHigh = na
var float pMonthLow = na
var int pMonthHighBar = na
var int pMonthLowBar = na

if newMonth
    pMonthHigh := monthHigh
    pMonthLow := monthLow
    pMonthHighBar := monthHighBar
    pMonthLowBar := monthLowBar
    monthHigh := high
    monthLow := low
    monthHighBar := bar_index
    monthLowBar := bar_index
else
    if high > monthHigh
        monthHigh := high
        monthHighBar := bar_index
    if low < monthLow
        monthLow := low
        monthLowBar := bar_index


// Note: plot()'s display= argument must be a compile-time constant. PDH/PDL keep a single plot keyed off
// the static tier_pd. PWH/PWL/PMH/PML use ONE plot each with a combined display flag (price scale on if
// EITHER tier's "Labels on Price Scale" box is on); the per-bar value fed to it is na unless the box for
// that level's own tier is checked, which reproduces per-tier on/off without a second plot.
pdPriceOnlyFlag = f_priceOnlyTier(tier_pd == 'Tier 2') - display.pane
priceOnlyCombinedFlag = (show_price_scale or show_price_scale_t2 ? display.price_scale + display.status_line : display.status_line) - display.pane

var line pdhLine = na
var line pdlLine = na
var line whLine = na
var line wlLine = na
var line mhLine = na
var line mlLine = na

// Mitigation tracking: these levels are mainly used as targets, so once
// price has traded through one it's no longer useful to the strategy.
// "Freeze Line" stops that level's line/label from extending any further
// once mitigated — it stays fixed at the bar where price reached it —
// and "Remove Level" deletes the line, label, and price-scale tag outright.
// MitBar records that bar so a frozen line/label can anchor there instead
// of chasing the live bar.
var bool pdhMit = false
var bool pdlMit = false
var bool whMit  = false
var bool wlMit  = false
var bool mhMit  = false
var bool mlMit  = false

var int pdhMitBar = na
var int pdlMitBar = na
var int whMitBar  = na
var int wlMitBar  = na
var int mhMitBar  = na
var int mlMitBar  = na

if newDay
    line.delete(pdhLine)
    line.delete(pdlLine)
    pdhMit := false
    pdlMit := false
    pdhMitBar := na
    pdlMitBar := na
    pdhLine := show_pdh and not hide_pd_lines and not na(pDayHigh) ? line.new(pDayHighBar, pDayHigh, bar_index, pDayHigh, xloc.bar_index, color = col_pd, style = f_lineStyle(style_pd), width = lineWidth) : na
    pdlLine := show_pdl and not hide_pd_lines and not na(pDayLow) ? line.new(pDayLowBar, pDayLow, bar_index, pDayLow, xloc.bar_index, color = col_pd, style = f_lineStyle(style_pd), width = lineWidth) : na
else
    if not pdhMit and not na(pDayHigh) and high >= pDayHigh
        pdhMit := true
        pdhMitBar := bar_index
    if not pdlMit and not na(pDayLow) and low <= pDayLow
        pdlMit := true
        pdlMitBar := bar_index

    if not na(pdhLine)
        if mitigationMode == 'Remove Level' and pdhMit
            line.delete(pdhLine)
            pdhLine := na
        else if mitigationMode == 'Keep Extending' or not pdhMit
            line.set_xy2(pdhLine, bar_index, pDayHigh)
    if not na(pdlLine)
        if mitigationMode == 'Remove Level' and pdlMit
            line.delete(pdlLine)
            pdlLine := na
        else if mitigationMode == 'Keep Extending' or not pdlMit
            line.set_xy2(pdlLine, bar_index, pDayLow)

if newWeek
    line.delete(whLine)
    line.delete(wlLine)
    whMit := false
    wlMit := false
    whMitBar := na
    wlMitBar := na
    whLine := show_wh and not hide_pw_lines and not na(pWeekHigh) ? line.new(pWeekHighBar, pWeekHigh, bar_index, pWeekHigh, xloc.bar_index, color = col_pw, style = f_lineStyle(style_pw), width = lineWidth) : na
    wlLine := show_wl and not hide_pw_lines and not na(pWeekLow) ? line.new(pWeekLowBar, pWeekLow, bar_index, pWeekLow, xloc.bar_index, color = col_pw, style = f_lineStyle(style_pw), width = lineWidth) : na
else
    if not whMit and not na(pWeekHigh) and high >= pWeekHigh
        whMit := true
        whMitBar := bar_index
    if not wlMit and not na(pWeekLow) and low <= pWeekLow
        wlMit := true
        wlMitBar := bar_index

    if not na(whLine)
        if mitigationMode == 'Remove Level' and whMit
            line.delete(whLine)
            whLine := na
        else if mitigationMode == 'Keep Extending' or not whMit
            line.set_xy2(whLine, bar_index, pWeekHigh)
    if not na(wlLine)
        if mitigationMode == 'Remove Level' and wlMit
            line.delete(wlLine)
            wlLine := na
        else if mitigationMode == 'Keep Extending' or not wlMit
            line.set_xy2(wlLine, bar_index, pWeekLow)

if newMonth
    line.delete(mhLine)
    line.delete(mlLine)
    mhMit := false
    mlMit := false
    mhMitBar := na
    mlMitBar := na
    mhLine := show_mh and not hide_pm_lines and not na(pMonthHigh) ? line.new(pMonthHighBar, pMonthHigh, bar_index, pMonthHigh, xloc.bar_index, color = col_pm_hl, style = f_lineStyle(style_pm), width = lineWidth) : na
    mlLine := show_ml and not hide_pm_lines and not na(pMonthLow) ? line.new(pMonthLowBar, pMonthLow, bar_index, pMonthLow, xloc.bar_index, color = col_pm_hl, style = f_lineStyle(style_pm), width = lineWidth) : na
else
    if not mhMit and not na(pMonthHigh) and high >= pMonthHigh
        mhMit := true
        mhMitBar := bar_index
    if not mlMit and not na(pMonthLow) and low <= pMonthLow
        mlMit := true
        mlMitBar := bar_index

    if not na(mhLine)
        if mitigationMode == 'Remove Level' and mhMit
            line.delete(mhLine)
            mhLine := na
        else if mitigationMode == 'Keep Extending' or not mhMit
            line.set_xy2(mhLine, bar_index, pMonthHigh)
    if not na(mlLine)
        if mitigationMode == 'Remove Level' and mlMit
            line.delete(mlLine)
            mlLine := na
        else if mitigationMode == 'Keep Extending' or not mlMit
            line.set_xy2(mlLine, bar_index, pMonthLow)

// ───────────────────────────── Plots ─────────────────────────────
plot(show_daily and showDailyBands and show_d1 ? daily_up1 : na, 'Daily Dev 1 Upper', col_d1, lineWidth, style = plot.style_line, display = dDevDispFlag)
plot(show_daily and showDailyBands and show_d1 ? daily_lo1 : na, 'Daily Dev 1 Lower', col_d1, lineWidth, style = plot.style_line, display = dDevDispFlag)
plot(show_daily and showDailyBands and show_d2 ? daily_up2 : na, 'Daily Dev 2 Upper', col_d2, lineWidth, style = plot.style_line, display = dDevDispFlag)
plot(show_daily and showDailyBands and show_d2 ? daily_lo2 : na, 'Daily Dev 2 Lower', col_d2, lineWidth, style = plot.style_line, display = dDevDispFlag)
plot(show_daily and showDailyBands and show_d3 ? daily_up3 : na, 'Daily Dev 3 Upper', col_d3, lineWidth, style = plot.style_line, display = dDevDispFlag)
plot(show_daily and showDailyBands and show_d3 ? daily_lo3 : na, 'Daily Dev 3 Lower', col_d3, lineWidth, style = plot.style_line, display = dDevDispFlag)

plot(show_prevday and showPDBands and show_p1 ? prevday_up1 : na, 'Prev Day Dev 1 Upper', col_p1, lineWidth, style = plot.style_line, display = pDevDispFlag)
plot(show_prevday and showPDBands and show_p1 ? prevday_lo1 : na, 'Prev Day Dev 1 Lower', col_p1, lineWidth, style = plot.style_line, display = pDevDispFlag)
plot(show_prevday and showPDBands and show_p2 ? prevday_up2 : na, 'Prev Day Dev 2 Upper', col_p2, lineWidth, style = plot.style_line, display = pDevDispFlag)
plot(show_prevday and showPDBands and show_p2 ? prevday_lo2 : na, 'Prev Day Dev 2 Lower', col_p2, lineWidth, style = plot.style_line, display = pDevDispFlag)
plot(show_prevday and showPDBands and show_p3 ? prevday_up3 : na, 'Prev Day Dev 3 Upper', col_p3, lineWidth, style = plot.style_line, display = pDevDispFlag)
plot(show_prevday and showPDBands and show_p3 ? prevday_lo3 : na, 'Prev Day Dev 3 Lower', col_p3, lineWidth, style = plot.style_line, display = pDevDispFlag)

plot(show_daily ? daily_vwap : na, 'Daily VWAP', col_daily, lineWidth, style = plot.style_line, display = dailyDispFlag)
plot(show_weekly ? weekly_vwap : na, 'Weekly VWAP', col_weekly, lineWidth, style = plot.style_line, display = weeklyDispFlag)
plot(show_monthly ? monthly_vwap : na, 'Monthly VWAP', col_monthly, lineWidth, style = plot.style_line, display = monthlyDispFlag)
plot(show_q2 ? q2_vwap : na, 'Q2 VWAP', col_q2, lineWidth, style = plot.style_line, display = q2DispFlag)
plot(show_yearly ? yearly_vwap : na, 'Yearly VWAP', col_yearly, lineWidth, style = plot.style_line, display = yearlyDispFlag)

plot(show_prevday ? prevday_vwap : na, 'Previous Day VWAP', col_prevday, lineWidth, style = plot.style_line, display = prevdayVwapDispFlag)
plot(show_prevweek ? prevweek_vwap : na, 'Prev Week VWAP', col_prevweek, lineWidth, style = plot.style_line, display = prevweekDispFlag)
plot(show_prevmonth ? prevmonth_vwap : na, 'Prev Month VWAP', col_prevmonth, lineWidth, style = plot.style_line, display = prevmonthDispFlag)

plot(show_day2 ? day2_vwap : na, 'ppD VWAP', col_day2, lineWidth, style = plot.style_line, display = day2DispFlag)

plot(show_rvwap1 ? rvwap1 : na, 'Rolling VWAP 1', col_rvwap1, lineWidth, style = plot.style_line, display = rvwap1DispFlag)
plot(show_rvwap2 ? rvwap2 : na, 'Rolling VWAP 2', col_rvwap2, lineWidth, style = plot.style_line, display = rvwap2DispFlag)

plot(show_custom1 ? custom1_vwap : na, 'Custom VWAP 1 (ATH)', col_custom1, lineWidth, style = plot.style_line, display = custom1DispFlag)
plot(show_custom2 ? custom2_vwap : na, 'Custom VWAP 2 (ATL)', col_custom2, lineWidth, style = plot.style_line, display = custom2DispFlag)

plot(show_ema50 ? ema50_daily : na, '50 EMA', col_ema50, 1, style = plot.style_line, display = ema50DispFlag)
plot(show_ema200 ? ema200_daily : na, '200 EMA', col_ema200, 1, style = plot.style_line, display = ema200DispFlag)
plot(show_ema50w ? ema50_weekly : na, '50w EMA', col_ema50w, 1, style = plot.style_line, display = ema50wDispFlag)
plot(show_ema200w ? ema200_weekly : na, '200w EMA', col_ema200w, 1, style = plot.style_line, display = ema200wDispFlag)

plot(show_pdh and not (mitigationMode != 'Keep Extending' and pdhMit) ? pDayHigh : na, 'PDH', color.gray, 1, style = plot.style_line, display = pdPriceOnlyFlag)
plot(show_pdl and not (mitigationMode != 'Keep Extending' and pdlMit) ? pDayLow : na, 'PDL', color.gray, 1, style = plot.style_line, display = pdPriceOnlyFlag)

pwScaleOn = tier_pw == 'Tier 2' ? show_price_scale_t2 : show_price_scale
pmScaleOn = tier_pm == 'Tier 2' ? show_price_scale_t2 : show_price_scale

whVal = show_wh and pwScaleOn and not (mitigationMode != 'Keep Extending' and whMit) ? pWeekHigh : na
wlVal = show_wl and pwScaleOn and not (mitigationMode != 'Keep Extending' and wlMit) ? pWeekLow : na
mhVal = show_mh and pmScaleOn and not (mitigationMode != 'Keep Extending' and mhMit) ? pMonthHigh : na
mlVal = show_ml and pmScaleOn and not (mitigationMode != 'Keep Extending' and mlMit) ? pMonthLow : na

plot(whVal, 'PWH', color.gray, 1, style = plot.style_line, display = priceOnlyCombinedFlag)
plot(wlVal, 'PWL', color.gray, 1, style = plot.style_line, display = priceOnlyCombinedFlag)
plot(mhVal, 'PMH', color.gray, 1, style = plot.style_line, display = priceOnlyCombinedFlag)
plot(mlVal, 'PML', color.gray, 1, style = plot.style_line, display = priceOnlyCombinedFlag)

// ───────────────────────────── Line Labels ─────────────────────────────
if barstate.islast
    array.clear(cVal)
    array.clear(cTxt)
    array.clear(cCol)
    array.clear(cCs)
    array.clear(cLx)
    array.clear(cT2)
    array.clear(cUsed)
    // Tier 1: price line ends at bar_index → gap_bars blank → conn_length1 dotted connector → label
    connStart1 = bar_index + gap_bars
    lblX1 = connStart1 + conn_length1
    // Tier 2: starts tier2_gap bars after the Tier 1 label → conn_length2 dotted connector → label
    connStart2 = lblX1 + tier2_gap
    lblX2 = connStart2 + conn_length2
    lblSz = f_labelSize(label_size_str)

    // Every level below picks its own Tier 1 / Tier 2 position via its own "Label Tier" input.
    [csDaily, lxDaily] = f_tierPos(tier_daily, connStart1, lblX1, connStart2, lblX2)
    [csWeekly, lxWeekly] = f_tierPos(tier_weekly, connStart1, lblX1, connStart2, lblX2)
    [csMonthly, lxMonthly] = f_tierPos(tier_monthly, connStart1, lblX1, connStart2, lblX2)
    [csQ2, lxQ2] = f_tierPos(tier_q2, connStart1, lblX1, connStart2, lblX2)
    [csYearly, lxYearly] = f_tierPos(tier_yearly, connStart1, lblX1, connStart2, lblX2)
    [csPrevday, lxPrevday] = f_tierPos(tier_prevday, connStart1, lblX1, connStart2, lblX2)
    [csPrevweek, lxPrevweek] = f_tierPos(tier_prevweek, connStart1, lblX1, connStart2, lblX2)
    [csPrevmonth, lxPrevmonth] = f_tierPos(tier_prevmonth, connStart1, lblX1, connStart2, lblX2)
    [csDay2, lxDay2] = f_tierPos(tier_day2, connStart1, lblX1, connStart2, lblX2)
    [csRvwap1, lxRvwap1] = f_tierPos(tier_rvwap1, connStart1, lblX1, connStart2, lblX2)
    [csRvwap2, lxRvwap2] = f_tierPos(tier_rvwap2, connStart1, lblX1, connStart2, lblX2)
    [csCustom1, lxCustom1] = f_tierPos(tier_custom1, connStart1, lblX1, connStart2, lblX2)
    [csCustom2, lxCustom2] = f_tierPos(tier_custom2, connStart1, lblX1, connStart2, lblX2)
    // Previous Period High/Low mitigation bookkeeping — a level frozen on
    // mitigation anchors its own label/connector at the bar it was
    // mitigated on instead of chasing the live bar, and a removed level's
    // label is hidden outright.
    pdhBarEff = mitigationMode == 'Freeze Line' and pdhMit and not na(pdhMitBar) ? pdhMitBar : bar_index
    pdlBarEff = mitigationMode == 'Freeze Line' and pdlMit and not na(pdlMitBar) ? pdlMitBar : bar_index
    whBarEff  = mitigationMode == 'Freeze Line' and whMit  and not na(whMitBar)  ? whMitBar  : bar_index
    wlBarEff  = mitigationMode == 'Freeze Line' and wlMit  and not na(wlMitBar)  ? wlMitBar  : bar_index
    mhBarEff  = mitigationMode == 'Freeze Line' and mhMit  and not na(mhMitBar)  ? mhMitBar  : bar_index
    mlBarEff  = mitigationMode == 'Freeze Line' and mlMit  and not na(mlMitBar)  ? mlMitBar  : bar_index

    pdhRemoved = mitigationMode == 'Remove Level' and pdhMit
    pdlRemoved = mitigationMode == 'Remove Level' and pdlMit
    whRemoved  = mitigationMode == 'Remove Level' and whMit
    wlRemoved  = mitigationMode == 'Remove Level' and wlMit
    mhRemoved  = mitigationMode == 'Remove Level' and mhMit
    mlRemoved  = mitigationMode == 'Remove Level' and mlMit

    [csPdh, lxPdh] = f_hlTierPos(tier_pd, pdhBarEff)
    [csPdl, lxPdl] = f_hlTierPos(tier_pd, pdlBarEff)
    [csWh, lxWh] = f_hlTierPos(tier_pw, whBarEff)
    [csWl, lxWl] = f_hlTierPos(tier_pw, wlBarEff)
    [csMh, lxMh] = f_hlTierPos(tier_pm, mhBarEff)
    [csMl, lxMl] = f_hlTierPos(tier_pm, mlBarEff)
    [csEma50, lxEma50] = f_tierPos(tier_ema50, connStart1, lblX1, connStart2, lblX2)
    [csEma200, lxEma200] = f_tierPos(tier_ema200, connStart1, lblX1, connStart2, lblX2)
    [csEma50w, lxEma50w] = f_tierPos(tier_ema50w, connStart1, lblX1, connStart2, lblX2)
    [csEma200w, lxEma200w] = f_tierPos(tier_ema200w, connStart1, lblX1, connStart2, lblX2)

    f_collect(show_labels and show_daily, daily_vwap, col_daily, lbl_daily, csDaily, lxDaily, tier_daily == 'Tier 2')
    f_collect(show_labels and show_weekly, weekly_vwap, col_weekly, lbl_weekly, csWeekly, lxWeekly, tier_weekly == 'Tier 2')
    f_collect(show_labels and show_monthly, monthly_vwap, col_monthly, lbl_monthly, csMonthly, lxMonthly, tier_monthly == 'Tier 2')
    f_collect(show_labels and show_q2, q2_vwap, col_q2, lbl_q2, csQ2, lxQ2, tier_q2 == 'Tier 2')
    f_collect(show_labels and show_yearly, yearly_vwap, col_yearly, lbl_yearly, csYearly, lxYearly, tier_yearly == 'Tier 2')
    f_collect(show_labels and show_prevday, prevday_vwap, col_prevday, lbl_prevday, csPrevday, lxPrevday, tier_prevday == 'Tier 2')
    f_collect(show_labels and show_prevweek, prevweek_vwap, col_prevweek, lbl_prevweek, csPrevweek, lxPrevweek, tier_prevweek == 'Tier 2')
    f_collect(show_labels and show_prevmonth, prevmonth_vwap, col_prevmonth, lbl_prevmonth, csPrevmonth, lxPrevmonth, tier_prevmonth == 'Tier 2')
    f_collect(show_labels and show_day2, day2_vwap, col_day2, lbl_day2, csDay2, lxDay2, tier_day2 == 'Tier 2')
    f_collect(show_labels and show_rvwap1, rvwap1, col_rvwap1, lbl_rvwap1, csRvwap1, lxRvwap1, tier_rvwap1 == 'Tier 2')
    f_collect(show_labels and show_rvwap2, rvwap2, col_rvwap2, lbl_rvwap2, csRvwap2, lxRvwap2, tier_rvwap2 == 'Tier 2')
    f_collect(show_labels and show_custom1, custom1_vwap, col_custom1, lbl_custom1, csCustom1, lxCustom1, tier_custom1 == 'Tier 2')
    f_collect(show_labels and show_custom2, custom2_vwap, col_custom2, lbl_custom2, csCustom2, lxCustom2, tier_custom2 == 'Tier 2')
    f_collect(show_labels and show_ema50, ema50d_hold, col_ema50, lbl_ema50, csEma50, lxEma50, tier_ema50 == 'Tier 2')
    f_collect(show_labels and show_ema200, ema200d_hold, col_ema200, lbl_ema200, csEma200, lxEma200, tier_ema200 == 'Tier 2')
    f_collect(show_labels and show_ema50w, ema50w_hold, col_ema50w, lbl_ema50w, csEma50w, lxEma50w, tier_ema50w == 'Tier 2')
    f_collect(show_labels and show_ema200w, ema200w_hold, col_ema200w, lbl_ema200w, csEma200w, lxEma200w, tier_ema200w == 'Tier 2')
    f_collect(show_labels and show_pdh and not pdhRemoved, pDayHigh, col_pd, lbl_pdh, csPdh, lxPdh, tier_pd == 'Tier 2')
    f_collect(show_labels and show_pdl and not pdlRemoved, pDayLow, col_pd, lbl_pdl, csPdl, lxPdl, tier_pd == 'Tier 2')
    f_collect(show_labels and show_wh and not whRemoved, pWeekHigh, col_pw, lbl_wh, csWh, lxWh, tier_pw == 'Tier 2')
    f_collect(show_labels and show_wl and not wlRemoved, pWeekLow, col_pw, lbl_wl, csWl, lxWl, tier_pw == 'Tier 2')
    f_collect(show_labels and show_mh and not mhRemoved, pMonthHigh, col_pm_hl, lbl_mh, csMh, lxMh, tier_pm == 'Tier 2')
    f_collect(show_labels and show_ml and not mlRemoved, pMonthLow, col_pm_hl, lbl_ml, csMl, lxMl, tier_pm == 'Tier 2')

    // Cluster collected levels: same column (same label x + tier) and within the threshold of the
    // cluster's first level share one label; each cluster gets one persistent label/connector slot.
    n = array.size(cVal)
    slot = 0
    if n > 0
        for i = 0 to n - 1
            if not array.get(cUsed, i)
                array.set(cUsed, i, true)
                joined = array.get(cTxt, i)
                if combine_labels and i < n - 1
                    for j = i + 1 to n - 1
                        if not array.get(cUsed, j) and array.get(cLx, j) == array.get(cLx, i) and array.get(cT2, j) == array.get(cT2, i) and f_near(array.get(cVal, j), array.get(cVal, i))
                            array.set(cUsed, j, true)
                            joined := joined + ' / ' + array.get(cTxt, j)
                f_updateLabelLine(slot, true, array.get(cVal, i), array.get(cCol, i), joined, array.get(cCs, i), array.get(cLx, i), lblSz, array.get(cT2, i))
                slot += 1
    if slot < array.size(allLabels)
        for k = slot to array.size(allLabels) - 1
            f_clearSlot(k)
````
