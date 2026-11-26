# Volatility Table [Enhanced]

- url: https://www.tradingview.com/script/ymmCYKpU/
- type: indicator
- pine_id: PUB;c7147af59e534107b3ea255006bd2a97
- version: 1.0

## Description

📌 Based on original work by Loxx:
https://ar.tradingview.com/script/fSTqdHYh-JCFBaux-Volatility-Loxx/

🤖 Developed with AI assistance (Claude & Perplexity AI)

✨ Enhancements:
• جدول متعدد الأطر الزمنية (10 TFs)
• تحويل تلقائي لأسماء الأطر الزمنية
• ملخص الاتجاه العام 
• تنبيهات لكل إطار زمني + تنبيه زخم قوي 7+/10
• تحكم كامل في عرض الجدول

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════
// CREDITS & LICENSE
// ══════════════════════════════════════════════════════════════════
// Original Script : JCFBaux Volatility by Loxx
// Original Source : https://ar.tradingview.com/script/fSTqdHYh-JCFBaux-Volatility-Loxx/
// Enhanced by     : مرعي
// AI Assistance   : Claude (Anthropic) & Perplexity AI
//
// Enhancements:
//   • Multi-timeframe volatility table (10 TFs)
//   • Dynamic TF label conversion for any timeframe
//   • Overall bias summary (Rising / Falling / Neutral)
//   • Cross alerts per TF + Strong bias alerts (7+/10)
//   • Customizable table position, size, and visibility
//
// License: Mozilla Public License 2.0
// This script is based on open-source work. Credits to the original author.
// ══════════════════════════════════════════════════════════════════

// © Loxx — Enhanced by مرعي
//@version=6
indicator('Volatility Table [Enhanced]', shorttitle = 'VolTable', overlay = true, dynamic_requests = true)


// ════════════════════════════════════════════════════════════════
// IMPORT
// ════════════════════════════════════════════════════════════════
import loxx/loxxjuriktools/1 as jf


// ════════════════════════════════════════════════════════════════
// CALCULATION SETTINGS
// ════════════════════════════════════════════════════════════════
src     = input.source(close, 'Source',       group = '⚙️ Calculation Settings')
depth   = input.int(15,       'Depth',         group = '⚙️ Calculation Settings', minval = 1)
lensmdd = input.int(300,      'Signal Period', group = '⚙️ Calculation Settings', minval = 1)
phase   = input.float(0,      'Jurik Phase',   group = '⚙️ Calculation Settings')


// ════════════════════════════════════════════════════════════════
// TABLE SETTINGS
// ════════════════════════════════════════════════════════════════
tblPosInput  = input.string('Bottom Right', 'Table Position', options = ['Top Left', 'Top Right', 'Middle Left', 'Middle Right', 'Bottom Left', 'Bottom Right'], group = '⚙️ Table Settings')
tblSizeInput = input.string('Small', 'Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = '⚙️ Table Settings')
showHeader  = input.bool(true, 'Show Header Row',    group = '⚙️ Table Settings')
showTF      = input.bool(true, 'Show TF Column',     group = '⚙️ Table Settings')
showValue   = input.bool(true, 'Show Value Column',  group = '⚙️ Table Settings')
showTrend   = input.bool(true, 'Show Trend Column',  group = '⚙️ Table Settings')
showSignal  = input.bool(true, 'Show Signal Column', group = '⚙️ Table Settings')
showSummary = input.bool(true, 'Show Summary Row',   group = '⚙️ Table Settings')
showSymbol  = input.bool(true, 'Show Symbol Row',    group = '⚙️ Table Settings')


tblPos  = tblPosInput == 'Top Left' ? position.top_left : tblPosInput == 'Top Right' ? position.top_right : tblPosInput == 'Middle Left' ? position.middle_left : tblPosInput == 'Middle Right' ? position.middle_right : tblPosInput == 'Bottom Left' ? position.bottom_left : position.bottom_right
txtSize = tblSizeInput == 'Tiny' ? size.tiny : tblSizeInput == 'Small' ? size.small : tblSizeInput == 'Normal' ? size.normal : size.large


// ════════════════════════════════════════════════════════════════
// TIMEFRAME VISIBILITY
// ════════════════════════════════════════════════════════════════
useMTF1  = input.bool(true, 'TF 1  (5m)',  group = '👁 Show / Hide Timeframes')
useMTF2  = input.bool(true, 'TF 2  (15m)', group = '👁 Show / Hide Timeframes')
useMTF3  = input.bool(true, 'TF 3  (30m)', group = '👁 Show / Hide Timeframes')
useMTF4  = input.bool(true, 'TF 4  (1H)',  group = '👁 Show / Hide Timeframes')
useMTF5  = input.bool(true, 'TF 5  (2H)',  group = '👁 Show / Hide Timeframes')
useMTF6  = input.bool(true, 'TF 6  (4H)',  group = '👁 Show / Hide Timeframes')
useMTF7  = input.bool(true, 'TF 7  (D)',   group = '👁 Show / Hide Timeframes')
useMTF8  = input.bool(true, 'TF 8  (W)',   group = '👁 Show / Hide Timeframes')
useMTF9  = input.bool(true, 'TF 9  (M)',   group = '👁 Show / Hide Timeframes')
useMTF10 = input.bool(true, 'TF 10 (3M)',  group = '👁 Show / Hide Timeframes')


// ════════════════════════════════════════════════════════════════
// TIMEFRAME INPUTS
// ════════════════════════════════════════════════════════════════
mtf1  = input.timeframe('5',   'TF 1',  group = '🕐 Timeframes')
mtf2  = input.timeframe('15',  'TF 2',  group = '🕐 Timeframes')
mtf3  = input.timeframe('30',  'TF 3',  group = '🕐 Timeframes')
mtf4  = input.timeframe('60',  'TF 4',  group = '🕐 Timeframes')
mtf5  = input.timeframe('120', 'TF 5',  group = '🕐 Timeframes')
mtf6  = input.timeframe('240', 'TF 6',  group = '🕐 Timeframes')
mtf7  = input.timeframe('D',   'TF 7',  group = '🕐 Timeframes')
mtf8  = input.timeframe('W',   'TF 8',  group = '🕐 Timeframes')
mtf9  = input.timeframe('M',   'TF 9',  group = '🕐 Timeframes')
mtf10 = input.timeframe('3M',  'TF 10', group = '🕐 Timeframes')


// ════════════════════════════════════════════════════════════════
// COLORS
// ════════════════════════════════════════════════════════════════
colBuy    = #2DD204
colSell   = #D2042D
colWait   = color.yellow
colText   = color.white
colHeader = color.rgb(30, 30, 30)
colBG     = color.rgb(12, 12, 12)
colRowA   = color.rgb(18, 18, 18)
colRowB   = color.rgb(24, 24, 24)
colBuyBG  = color.rgb(8, 40, 8)
colSellBG = color.rgb(40, 8, 8)


// ════════════════════════════════════════════════════════════════
// TF LABEL HELPER — تحويل ديناميكي لأي إطار زمني
// ════════════════════════════════════════════════════════════════
tfLabel(tf) =>
    secs = timeframe.in_seconds(tf)
    mins = secs / 60
    mins < 60 ? str.tostring(int(mins)) + 'm' : mins < 1440 ? str.tostring(int(mins / 60)) + 'H' : mins < 10080 ? str.tostring(int(mins / 1440)) + 'D' : mins < 43200 ? str.tostring(int(mins / 10080)) + 'W' : str.tostring(int(mins / 43200)) + 'M'


// ════════════════════════════════════════════════════════════════
// TABLE — declared at top level
// ════════════════════════════════════════════════════════════════
var table t = na


// ════════════════════════════════════════════════════════════════
// CELL HELPER — must be at top level, not inside if block
// ════════════════════════════════════════════════════════════════
_c(col, row, txt, bg, fg) =>
    table.cell(t, col, row, txt, bgcolor = bg, text_color = fg, text_size = txtSize, text_halign = text.align_center)


// ════════════════════════════════════════════════════════════════
// ROW FILL HELPER — must be at top level
// ════════════════════════════════════════════════════════════════
fillRow(row, tfName, j, s, cross, rowIdx) =>
    isRising = j >= s
    rowBG    = rowIdx % 2 == 0 ? colRowA : colRowB
    col = 0
    if showTF
        _c(col, row, ' ' + tfName + ' ', colHeader, colText)
        col := col + 1
    if showValue
        _c(col, row, str.tostring(j, '#.#####'), rowBG, colText)
        col := col + 1
    if showTrend
        _c(col, row, isRising ? '  ▲ Volatility ' : '  ▼ Volatility  ', isRising ? colBuyBG : colSellBG, isRising ? colBuy : colSell)
        col := col + 1
    if showSignal
        _c(col, row, cross ? '  ▲ Cross  ' : '', cross ? color.new(color.yellow, 80) : rowBG, cross ? color.yellow : colText)


// ════════════════════════════════════════════════════════════════
// CORE FUNCTION
// ════════════════════════════════════════════════════════════════
f_jcf(tf) =>
    j     = request.security(syminfo.tickerid, tf, jf.jcfbaux(src, depth))
    s     = request.security(syminfo.tickerid, tf, jf.jurik_filt(jf.jcfbaux(src, depth), lensmdd, phase))
    cross = ta.crossover(j, s)
    [j, s, cross]


// ════════════════════════════════════════════════════════════════
// DATA
// ════════════════════════════════════════════════════════════════
[j1,  s1,  c1 ] = f_jcf(mtf1)
[j2,  s2,  c2 ] = f_jcf(mtf2)
[j3,  s3,  c3 ] = f_jcf(mtf3)
[j4,  s4,  c4 ] = f_jcf(mtf4)
[j5,  s5,  c5 ] = f_jcf(mtf5)
[j6,  s6,  c6 ] = f_jcf(mtf6)
[j7,  s7,  c7 ] = f_jcf(mtf7)
[j8,  s8,  c8 ] = f_jcf(mtf8)
[j9,  s9,  c9 ] = f_jcf(mtf9)
[j10, s10, c10] = f_jcf(mtf10)


// ════════════════════════════════════════════════════════════════
// COUNTS — one variable per line
// ════════════════════════════════════════════════════════════════
r1  = useMTF1  and j1  >= s1  ? 1 : 0
r2  = useMTF2  and j2  >= s2  ? 1 : 0
r3  = useMTF3  and j3  >= s3  ? 1 : 0
r4  = useMTF4  and j4  >= s4  ? 1 : 0
r5  = useMTF5  and j5  >= s5  ? 1 : 0
r6  = useMTF6  and j6  >= s6  ? 1 : 0
r7  = useMTF7  and j7  >= s7  ? 1 : 0
r8  = useMTF8  and j8  >= s8  ? 1 : 0
r9  = useMTF9  and j9  >= s9  ? 1 : 0
r10 = useMTF10 and j10 >= s10 ? 1 : 0
rising_count = r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + r10

fa1  = useMTF1  and j1  < s1  ? 1 : 0
fa2  = useMTF2  and j2  < s2  ? 1 : 0
fa3  = useMTF3  and j3  < s3  ? 1 : 0
fa4  = useMTF4  and j4  < s4  ? 1 : 0
fa5  = useMTF5  and j5  < s5  ? 1 : 0
fa6  = useMTF6  and j6  < s6  ? 1 : 0
fa7  = useMTF7  and j7  < s7  ? 1 : 0
fa8  = useMTF8  and j8  < s8  ? 1 : 0
fa9  = useMTF9  and j9  < s9  ? 1 : 0
fa10 = useMTF10 and j10 < s10 ? 1 : 0
falling_count = fa1 + fa2 + fa3 + fa4 + fa5 + fa6 + fa7 + fa8 + fa9 + fa10

x1  = useMTF1  and c1  ? 1 : 0
x2  = useMTF2  and c2  ? 1 : 0
x3  = useMTF3  and c3  ? 1 : 0
x4  = useMTF4  and c4  ? 1 : 0
x5  = useMTF5  and c5  ? 1 : 0
x6  = useMTF6  and c6  ? 1 : 0
x7  = useMTF7  and c7  ? 1 : 0
x8  = useMTF8  and c8  ? 1 : 0
x9  = useMTF9  and c9  ? 1 : 0
x10 = useMTF10 and c10 ? 1 : 0
cross_count = x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10

vis1  = useMTF1  ? 1 : 0
vis2  = useMTF2  ? 1 : 0
vis3  = useMTF3  ? 1 : 0
vis4  = useMTF4  ? 1 : 0
vis5  = useMTF5  ? 1 : 0
vis6  = useMTF6  ? 1 : 0
vis7  = useMTF7  ? 1 : 0
vis8  = useMTF8  ? 1 : 0
vis9  = useMTF9  ? 1 : 0
vis10 = useMTF10 ? 1 : 0
total_vis = vis1 + vis2 + vis3 + vis4 + vis5 + vis6 + vis7 + vis8 + vis9 + vis10


// ════════════════════════════════════════════════════════════════
// OVERALL BIAS
// ════════════════════════════════════════════════════════════════
overall_bull  = rising_count > falling_count
overall_bear  = falling_count > rising_count
overall_color = overall_bull ? colBuy : overall_bear ? colSell : colWait
ov_r = str.tostring(rising_count)  + '/' + str.tostring(total_vis)
ov_f = str.tostring(falling_count) + '/' + str.tostring(total_vis)
ov_n = str.tostring(total_vis)     + '/' + str.tostring(total_vis)
overall_text = overall_bull ? '▲ Volatility ' + ov_r : overall_bear ? '▼ Volatility ' + ov_f : '◆ NEUTRAL ' + ov_n


// ════════════════════════════════════════════════════════════════
// TABLE SIZE
// ════════════════════════════════════════════════════════════════
cols_n     = (showTF ? 1 : 0) + (showValue ? 1 : 0) + (showTrend ? 1 : 0) + (showSignal ? 1 : 0)
cols       = math.max(cols_n, 1)
vis_rows   = vis1 + vis2 + vis3 + vis4 + vis5 + vis6 + vis7 + vis8 + vis9 + vis10
extra_r    = (showHeader ? 1 : 0) + (showSummary ? 2 : 0) + (showSymbol ? 1 : 0)
total_rows = math.max(vis_rows + extra_r, 1)


// ════════════════════════════════════════════════════════════════
// DRAW TABLE
// ════════════════════════════════════════════════════════════════
if barstate.islast
    t := table.new(tblPos, cols, total_rows, bgcolor = colBG, border_width = 1, border_color = color.rgb(50, 50, 50), frame_width = 2, frame_color = color.rgb(70, 70, 70))

    // ── Header ────────────────────────────────────────────────
    cur_row = 0
    if showHeader
        col = 0
        if showTF
            _c(col, cur_row, ' TF ', colHeader, colText)
            col := col + 1
        if showValue
            _c(col, cur_row, ' Value ', colHeader, colText)
            col := col + 1
        if showTrend
            _c(col, cur_row, ' Trend ', colHeader, colText)
            col := col + 1
        if showSignal
            _c(col, cur_row, ' Signal ', colHeader, colText)
        cur_row := cur_row + 1

    // ── Data rows ─────────────────────────────────────────────
    rowIdx = 0
    if useMTF1
        fillRow(cur_row, tfLabel(mtf1), j1, s1, c1, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF2
        fillRow(cur_row, tfLabel(mtf2), j2, s2, c2, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF3
        fillRow(cur_row, tfLabel(mtf3), j3, s3, c3, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF4
        fillRow(cur_row, tfLabel(mtf4), j4, s4, c4, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF5
        fillRow(cur_row, tfLabel(mtf5), j5, s5, c5, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF6
        fillRow(cur_row, tfLabel(mtf6), j6, s6, c6, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF7
        fillRow(cur_row, tfLabel(mtf7), j7, s7, c7, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF8
        fillRow(cur_row, tfLabel(mtf8), j8, s8, c8, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF9
        fillRow(cur_row, tfLabel(mtf9), j9, s9, c9, rowIdx)
        cur_row := cur_row + 1
        rowIdx  := rowIdx  + 1
    if useMTF10
        fillRow(cur_row, tfLabel(mtf10), j10, s10, c10, rowIdx)
        cur_row := cur_row + 1

    // ── Summary ───────────────────────────────────────────────
    if showSummary
        for dc = 0 to cols - 1
            table.cell(t, dc, cur_row, '─────────', text_color = color.rgb(60, 60, 60), text_size = size.tiny, bgcolor = colBG, text_halign = text.align_center)
        cur_row := cur_row + 1
        col = 0
        if showTF
            _c(col, cur_row, '', colBG, colText)
            col := col + 1
        if showValue
            _c(col, cur_row, '🟢 ' + str.tostring(rising_count) + '  🔴 ' + str.tostring(falling_count) + '  ⚡ ' + str.tostring(cross_count), colBG, color.white)
            col := col + 1
        if showTrend
            _c(col, cur_row, '  ' + overall_text + '  ', colBG, overall_color)
            col := col + 1
        if showSignal
            _c(col, cur_row, '', colBG, colText)
        cur_row := cur_row + 1

    // ── Symbol / Time ─────────────────────────────────────────
    if showSymbol
        dimGray = color.rgb(90, 90, 90)
        col = 0
        if showTF
            _c(col, cur_row, syminfo.ticker + ' • ' + timeframe.period, colBG, dimGray)
            col := col + 1
        if showValue
            _c(col, cur_row, str.format_time(timenow, 'HH:mm:ss', syminfo.timezone), colBG, dimGray)
            col := col + 1
        if showTrend
            _c(col, cur_row, '', colBG, colText)
            col := col + 1
        if showSignal
            _c(col, cur_row, '', colBG, colText)


// ════════════════════════════════════════════════════════════════


// ════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════
alertcondition(c1,  'Cross — TF1',  '{{ticker}} — JCFBaux crossover on TF1')
alertcondition(c2,  'Cross — TF2',  '{{ticker}} — JCFBaux crossover on TF2')
alertcondition(c3,  'Cross — TF3',  '{{ticker}} — JCFBaux crossover on TF3')
alertcondition(c4,  'Cross — TF4',  '{{ticker}} — JCFBaux crossover on TF4')
alertcondition(c5,  'Cross — TF5',  '{{ticker}} — JCFBaux crossover on TF5')
alertcondition(c6,  'Cross — TF6',  '{{ticker}} — JCFBaux crossover on TF6')
alertcondition(c7,  'Cross — TF7',  '{{ticker}} — JCFBaux crossover on TF7')
alertcondition(c8,  'Cross — TF8',  '{{ticker}} — JCFBaux crossover on TF8')
alertcondition(c9,  'Cross — TF9',  '{{ticker}} — JCFBaux crossover on TF9')
alertcondition(c10, 'Cross — TF10', '{{ticker}} — JCFBaux crossover on TF10')
alertcondition(rising_count  >= 7, 'Strong RISING (7+/10)',  '{{ticker}} — Strong Rising: 7 or more TFs bullish')
alertcondition(falling_count >= 7, 'Strong FALLING (7+/10)', '{{ticker}} — Strong Falling: 7 or more TFs bearish')
````
