# MA Suite

- url: https://www.tradingview.com/script/1nLP5TDf-MA-Suite/
- type: indicator
- pine_id: PUB;36a70691410d41099220e95b3ced9c11
- version: 1.0

## Description

MA Suite is a five-panel moving average system built for traders who don't want to give up flexibility for simplicity, or simplicity for flexibility. Each panel holds twelve fully independent moving average slots, and every slot can be switched on or off, retimed to Daily or Weekly, recolored, and set to any of six MA types including EMA, SMA, RMA, WMA, HMA, and LSMA. A single dropdown lets you jump between panels instantly, and every panel keeps its own settings saved underneath, so switching from one preset to another and back never loses your work.

The five panels cover very different trading styles. Panel 1 is a clean 9/21/55 trend template for traders who want three lines and nothing else. Panel 2 is a Fibonacci ladder running from 5 all the way out to 800, useful for seeing how price behaves against the full spread of Fibonacci-based lookbacks at once. Panel 3 is a classic Super Guppy, six short-term EMAs and six long-term EMAs in the traditional cyan-to-blue and amber-to-red gradient, built for reading trend strength and momentum compression the way GMMA traders always have. Panel 4 is a full twelve-step rainbow ribbon, EMAs stepping from 10 to 120, for a smooth visual read on how stacked or compressed the trend is across every timeframe in between. Panel 5 brings in the Cipher A ribbon, an 8-EMA system that automatically recolors itself blue when trend is bullish and gray when it turns bearish, complete with the full original signal set: long and short EMA circles, red crosses, blue triangles, red diamonds, blood diamonds, and the yellow cross confluence signal that combines WaveTrend, RSI, and RSI plus MFI into one confirmation.

Every line across every panel, active or not, can carry its own price-scale label. Labels sit at the end of a short dotted connector so they never crowd into the price action on the right edge of the chart, and each one can show the moving average's length and type automatically, or a custom name you set yourself. Label size, background transparency, connector length, and whether the connector or the price-scale box shows up at all are all adjustable from one place, so the whole system can look as clean or as detailed as you want it to.

Because only the active panel's twelve slots are ever calculated, the indicator stays light regardless of how many presets you have saved, and switching panels is instant. This is the same labeling engine from VWAP A BE BOP, brought over and simplified for a moving-average-only use case, so if you've used that indicator the labels here will already feel familiar.

## Source Code

````pine
//@version=6
indicator('MA Suite', overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────────── Settings ─────────────────────────────
g_set = 'Settings'
src = input.source(close, 'MA Source', group = g_set)
activePanel = input.string('Panel 1', 'Active Panel', options = ['Panel 1', 'Panel 2', 'Panel 3', 'Panel 4', 'Panel 5'], group = g_set, tooltip = 'Only the active panel\'s 12 MAs are calculated and plotted. All five panels stay saved below — scroll down to edit any of them at any time, whether active or not.')
ma_line_width = input.int(2, 'MA Line Width', minval = 1, maxval = 4, group = g_set)

f_ma(source, len, typ) =>
    typ == 'SMA' ? ta.sma(source, len) : typ == 'EMA' ? ta.ema(source, len) : typ == 'RMA' ? ta.rma(source, len) : typ == 'WMA' ? ta.wma(source, len) : typ == 'HMA' ? ta.hma(source, len) : ta.linreg(source, len, 0)

f_sel(a1, a2, a3, a4, a5) =>
    activePanel == 'Panel 1' ? a1 : activePanel == 'Panel 2' ? a2 : activePanel == 'Panel 3' ? a3 : activePanel == 'Panel 4' ? a4 : a5

// ───────────────────────────── Labels (Global) ─────────────────────────────
g_lbl = 'Labels'
show_labels = input.bool(true, 'Show Line Labels', group = g_lbl)
show_conn_lines = input.bool(true, 'Show Dotted Connector Lines', group = g_lbl)
label_size_str = input.string('Small', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = g_lbl)
gap_bars = input.int(5, 'Gap: Price Line to Connector (bars)', minval = 0, group = g_lbl, tooltip = 'Blank space between the current bar (end of the price line) and where the dotted connector line begins.')
conn_length = input.int(2, 'Connector Length (bars)', minval = 0, group = g_lbl, tooltip = 'Length of the dotted connector. The label sits at the end of it.')
lbl_transparency = input.int(96, 'Label Background Transparency', minval = 0, maxval = 100, group = g_lbl, tooltip = 'Higher = more see-through. Set to 100% to hide the background completely (text only).')
show_price = input.bool(false, 'Show Price', group = g_lbl)
show_pct = input.bool(false, 'Show % From Price', group = g_lbl, tooltip = 'Shows how far price currently is from each line, as a percentage: (line - price) / price. A line 1% below price reads -1%.')
show_price_scale = input.bool(true, 'Labels on Price Scale', group = g_lbl, tooltip = 'Matches the "Labels on price scale" checkbox on the Style tab.')

f_labelSize(s) =>
    s == 'Tiny' ? size.tiny : s == 'Small' ? size.small : s == 'Normal' ? size.normal : size.large

dispFlag = show_price_scale ? display.all : display.all - display.price_scale

f_hideDispFlag(hideLine) =>
    hideLine ? dispFlag - display.pane : dispFlag

f_pct(val) =>
    (val - close) / close * 100

f_buildText(baseTxt, val) =>
    txt = baseTxt
    if show_price
        txt := txt + ' (' + str.tostring(val, format.mintick) + ')'
    if show_pct
        txt := txt + ' (' + str.tostring(f_pct(val), '#.##') + '%)'
    txt

var label[] allLabels = array.new<label>(12, na)
var line[]  allConnLines = array.new<line>(12, na)

f_updateLabelLine(idx, show, val, col, baseTxt, connStartX, lblX, lblSz) =>
    if show and not na(val)
        txt = f_buildText(baseTxt, val)
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

// ───────────────────────────── Panel 1 (Simple 9/21/55) ─────────────────────────────
g_p1 = 'Panel 1 (Simple 9/21/55)'
p1_on1 = input.bool(true, 'MA 1', inline = 'p1r1', group = g_p1)
p1_len1 = input.int(9, '', minval = 1, inline = 'p1r1', group = g_p1)
p1_typ1 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r1', group = g_p1)
p1_tf1 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r1', group = g_p1)
p1_col1 = input.color(#ffeb3b, '', inline = 'p1r1', group = g_p1)
p1_hide1 = input.bool(false, 'Hide Line', inline = 'p1s1', group = g_p1)
p1_lbl1 = input.string('', 'Label Text (blank = auto)', inline = 'p1s1', group = g_p1)

p1_on2 = input.bool(true, 'MA 2', inline = 'p1r2', group = g_p1)
p1_len2 = input.int(21, '', minval = 1, inline = 'p1r2', group = g_p1)
p1_typ2 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r2', group = g_p1)
p1_tf2 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r2', group = g_p1)
p1_col2 = input.color(#ff9800, '', inline = 'p1r2', group = g_p1)
p1_hide2 = input.bool(false, 'Hide Line', inline = 'p1s2', group = g_p1)
p1_lbl2 = input.string('', 'Label Text (blank = auto)', inline = 'p1s2', group = g_p1)

p1_on3 = input.bool(true, 'MA 3', inline = 'p1r3', group = g_p1)
p1_len3 = input.int(55, '', minval = 1, inline = 'p1r3', group = g_p1)
p1_typ3 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r3', group = g_p1)
p1_tf3 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r3', group = g_p1)
p1_col3 = input.color(#f44336, '', inline = 'p1r3', group = g_p1)
p1_hide3 = input.bool(false, 'Hide Line', inline = 'p1s3', group = g_p1)
p1_lbl3 = input.string('', 'Label Text (blank = auto)', inline = 'p1s3', group = g_p1)

p1_on4 = input.bool(false, 'MA 4', inline = 'p1r4', group = g_p1)
p1_len4 = input.int(100, '', minval = 1, inline = 'p1r4', group = g_p1)
p1_typ4 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r4', group = g_p1)
p1_tf4 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r4', group = g_p1)
p1_col4 = input.color(#808080, '', inline = 'p1r4', group = g_p1)
p1_hide4 = input.bool(false, 'Hide Line', inline = 'p1s4', group = g_p1)
p1_lbl4 = input.string('', 'Label Text (blank = auto)', inline = 'p1s4', group = g_p1)

p1_on5 = input.bool(false, 'MA 5', inline = 'p1r5', group = g_p1)
p1_len5 = input.int(150, '', minval = 1, inline = 'p1r5', group = g_p1)
p1_typ5 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r5', group = g_p1)
p1_tf5 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r5', group = g_p1)
p1_col5 = input.color(#808080, '', inline = 'p1r5', group = g_p1)
p1_hide5 = input.bool(false, 'Hide Line', inline = 'p1s5', group = g_p1)
p1_lbl5 = input.string('', 'Label Text (blank = auto)', inline = 'p1s5', group = g_p1)

p1_on6 = input.bool(false, 'MA 6', inline = 'p1r6', group = g_p1)
p1_len6 = input.int(200, '', minval = 1, inline = 'p1r6', group = g_p1)
p1_typ6 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r6', group = g_p1)
p1_tf6 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r6', group = g_p1)
p1_col6 = input.color(#808080, '', inline = 'p1r6', group = g_p1)
p1_hide6 = input.bool(false, 'Hide Line', inline = 'p1s6', group = g_p1)
p1_lbl6 = input.string('', 'Label Text (blank = auto)', inline = 'p1s6', group = g_p1)

p1_on7 = input.bool(false, 'MA 7', inline = 'p1r7', group = g_p1)
p1_len7 = input.int(10, '', minval = 1, inline = 'p1r7', group = g_p1)
p1_typ7 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r7', group = g_p1)
p1_tf7 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r7', group = g_p1)
p1_col7 = input.color(#808080, '', inline = 'p1r7', group = g_p1)
p1_hide7 = input.bool(false, 'Hide Line', inline = 'p1s7', group = g_p1)
p1_lbl7 = input.string('', 'Label Text (blank = auto)', inline = 'p1s7', group = g_p1)

p1_on8 = input.bool(false, 'MA 8', inline = 'p1r8', group = g_p1)
p1_len8 = input.int(20, '', minval = 1, inline = 'p1r8', group = g_p1)
p1_typ8 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r8', group = g_p1)
p1_tf8 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r8', group = g_p1)
p1_col8 = input.color(#808080, '', inline = 'p1r8', group = g_p1)
p1_hide8 = input.bool(false, 'Hide Line', inline = 'p1s8', group = g_p1)
p1_lbl8 = input.string('', 'Label Text (blank = auto)', inline = 'p1s8', group = g_p1)

p1_on9 = input.bool(false, 'MA 9', inline = 'p1r9', group = g_p1)
p1_len9 = input.int(30, '', minval = 1, inline = 'p1r9', group = g_p1)
p1_typ9 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r9', group = g_p1)
p1_tf9 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r9', group = g_p1)
p1_col9 = input.color(#808080, '', inline = 'p1r9', group = g_p1)
p1_hide9 = input.bool(false, 'Hide Line', inline = 'p1s9', group = g_p1)
p1_lbl9 = input.string('', 'Label Text (blank = auto)', inline = 'p1s9', group = g_p1)

p1_on10 = input.bool(false, 'MA 10', inline = 'p1r10', group = g_p1)
p1_len10 = input.int(40, '', minval = 1, inline = 'p1r10', group = g_p1)
p1_typ10 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r10', group = g_p1)
p1_tf10 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r10', group = g_p1)
p1_col10 = input.color(#808080, '', inline = 'p1r10', group = g_p1)
p1_hide10 = input.bool(false, 'Hide Line', inline = 'p1s10', group = g_p1)
p1_lbl10 = input.string('', 'Label Text (blank = auto)', inline = 'p1s10', group = g_p1)

p1_on11 = input.bool(false, 'MA 11', inline = 'p1r11', group = g_p1)
p1_len11 = input.int(50, '', minval = 1, inline = 'p1r11', group = g_p1)
p1_typ11 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r11', group = g_p1)
p1_tf11 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r11', group = g_p1)
p1_col11 = input.color(#808080, '', inline = 'p1r11', group = g_p1)
p1_hide11 = input.bool(false, 'Hide Line', inline = 'p1s11', group = g_p1)
p1_lbl11 = input.string('', 'Label Text (blank = auto)', inline = 'p1s11', group = g_p1)

p1_on12 = input.bool(false, 'MA 12', inline = 'p1r12', group = g_p1)
p1_len12 = input.int(60, '', minval = 1, inline = 'p1r12', group = g_p1)
p1_typ12 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p1r12', group = g_p1)
p1_tf12 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p1r12', group = g_p1)
p1_col12 = input.color(#808080, '', inline = 'p1r12', group = g_p1)
p1_hide12 = input.bool(false, 'Hide Line', inline = 'p1s12', group = g_p1)
p1_lbl12 = input.string('', 'Label Text (blank = auto)', inline = 'p1s12', group = g_p1)

// ───────────────────────────── Panel 2 (Fibonacci Ladder) ─────────────────────────────
g_p2 = 'Panel 2 (Fibonacci Ladder)'
p2_on1 = input.bool(true, 'MA 1', inline = 'p2r1', group = g_p2)
p2_len1 = input.int(5, '', minval = 1, inline = 'p2r1', group = g_p2)
p2_typ1 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r1', group = g_p2)
p2_tf1 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r1', group = g_p2)
p2_col1 = input.color(#808080, '', inline = 'p2r1', group = g_p2)
p2_hide1 = input.bool(false, 'Hide Line', inline = 'p2s1', group = g_p2)
p2_lbl1 = input.string('', 'Label Text (blank = auto)', inline = 'p2s1', group = g_p2)

p2_on2 = input.bool(true, 'MA 2', inline = 'p2r2', group = g_p2)
p2_len2 = input.int(9, '', minval = 1, inline = 'p2r2', group = g_p2)
p2_typ2 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r2', group = g_p2)
p2_tf2 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r2', group = g_p2)
p2_col2 = input.color(#ff0000, '', inline = 'p2r2', group = g_p2)
p2_hide2 = input.bool(false, 'Hide Line', inline = 'p2s2', group = g_p2)
p2_lbl2 = input.string('', 'Label Text (blank = auto)', inline = 'p2s2', group = g_p2)

p2_on3 = input.bool(true, 'MA 3', inline = 'p2r3', group = g_p2)
p2_len3 = input.int(21, '', minval = 1, inline = 'p2r3', group = g_p2)
p2_typ3 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r3', group = g_p2)
p2_tf3 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r3', group = g_p2)
p2_col3 = input.color(#ffc107, '', inline = 'p2r3', group = g_p2)
p2_hide3 = input.bool(false, 'Hide Line', inline = 'p2s3', group = g_p2)
p2_lbl3 = input.string('', 'Label Text (blank = auto)', inline = 'p2s3', group = g_p2)

p2_on4 = input.bool(true, 'MA 4', inline = 'p2r4', group = g_p2)
p2_len4 = input.int(55, '', minval = 1, inline = 'p2r4', group = g_p2)
p2_typ4 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r4', group = g_p2)
p2_tf4 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r4', group = g_p2)
p2_col4 = input.color(#76ff03, '', inline = 'p2r4', group = g_p2)
p2_hide4 = input.bool(false, 'Hide Line', inline = 'p2s4', group = g_p2)
p2_lbl4 = input.string('', 'Label Text (blank = auto)', inline = 'p2s4', group = g_p2)

p2_on5 = input.bool(true, 'MA 5', inline = 'p2r5', group = g_p2)
p2_len5 = input.int(89, '', minval = 1, inline = 'p2r5', group = g_p2)
p2_typ5 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r5', group = g_p2)
p2_tf5 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r5', group = g_p2)
p2_col5 = input.color(#2e7d32, '', inline = 'p2r5', group = g_p2)
p2_hide5 = input.bool(false, 'Hide Line', inline = 'p2s5', group = g_p2)
p2_lbl5 = input.string('', 'Label Text (blank = auto)', inline = 'p2s5', group = g_p2)

p2_on6 = input.bool(true, 'MA 6', inline = 'p2r6', group = g_p2)
p2_len6 = input.int(144, '', minval = 1, inline = 'p2r6', group = g_p2)
p2_typ6 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r6', group = g_p2)
p2_tf6 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r6', group = g_p2)
p2_col6 = input.color(#26c6da, '', inline = 'p2r6', group = g_p2)
p2_hide6 = input.bool(false, 'Hide Line', inline = 'p2s6', group = g_p2)
p2_lbl6 = input.string('', 'Label Text (blank = auto)', inline = 'p2s6', group = g_p2)

p2_on7 = input.bool(true, 'MA 7', inline = 'p2r7', group = g_p2)
p2_len7 = input.int(200, '', minval = 1, inline = 'p2r7', group = g_p2)
p2_typ7 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r7', group = g_p2)
p2_tf7 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r7', group = g_p2)
p2_col7 = input.color(#2979ff, '', inline = 'p2r7', group = g_p2)
p2_hide7 = input.bool(false, 'Hide Line', inline = 'p2s7', group = g_p2)
p2_lbl7 = input.string('', 'Label Text (blank = auto)', inline = 'p2s7', group = g_p2)

p2_on8 = input.bool(true, 'MA 8', inline = 'p2r8', group = g_p2)
p2_len8 = input.int(377, '', minval = 1, inline = 'p2r8', group = g_p2)
p2_typ8 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r8', group = g_p2)
p2_tf8 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r8', group = g_p2)
p2_col8 = input.color(#9c27b0, '', inline = 'p2r8', group = g_p2)
p2_hide8 = input.bool(false, 'Hide Line', inline = 'p2s8', group = g_p2)
p2_lbl8 = input.string('', 'Label Text (blank = auto)', inline = 'p2s8', group = g_p2)

p2_on9 = input.bool(true, 'MA 9', inline = 'p2r9', group = g_p2)
p2_len9 = input.int(800, '', minval = 1, inline = 'p2r9', group = g_p2)
p2_typ9 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r9', group = g_p2)
p2_tf9 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r9', group = g_p2)
p2_col9 = input.color(#f5f5f5, '', inline = 'p2r9', group = g_p2)
p2_hide9 = input.bool(false, 'Hide Line', inline = 'p2s9', group = g_p2)
p2_lbl9 = input.string('', 'Label Text (blank = auto)', inline = 'p2s9', group = g_p2)

p2_on10 = input.bool(false, 'MA 10', inline = 'p2r10', group = g_p2)
p2_len10 = input.int(1000, '', minval = 1, inline = 'p2r10', group = g_p2)
p2_typ10 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r10', group = g_p2)
p2_tf10 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r10', group = g_p2)
p2_col10 = input.color(#808080, '', inline = 'p2r10', group = g_p2)
p2_hide10 = input.bool(false, 'Hide Line', inline = 'p2s10', group = g_p2)
p2_lbl10 = input.string('', 'Label Text (blank = auto)', inline = 'p2s10', group = g_p2)

p2_on11 = input.bool(false, 'MA 11', inline = 'p2r11', group = g_p2)
p2_len11 = input.int(1300, '', minval = 1, inline = 'p2r11', group = g_p2)
p2_typ11 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r11', group = g_p2)
p2_tf11 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r11', group = g_p2)
p2_col11 = input.color(#808080, '', inline = 'p2r11', group = g_p2)
p2_hide11 = input.bool(false, 'Hide Line', inline = 'p2s11', group = g_p2)
p2_lbl11 = input.string('', 'Label Text (blank = auto)', inline = 'p2s11', group = g_p2)

p2_on12 = input.bool(false, 'MA 12', inline = 'p2r12', group = g_p2)
p2_len12 = input.int(1600, '', minval = 1, inline = 'p2r12', group = g_p2)
p2_typ12 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p2r12', group = g_p2)
p2_tf12 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p2r12', group = g_p2)
p2_col12 = input.color(#808080, '', inline = 'p2r12', group = g_p2)
p2_hide12 = input.bool(false, 'Hide Line', inline = 'p2s12', group = g_p2)
p2_lbl12 = input.string('', 'Label Text (blank = auto)', inline = 'p2s12', group = g_p2)

// ───────────────────────────── Panel 3 (Super Guppy) ─────────────────────────────
g_p3 = 'Panel 3 (Super Guppy)'
p3_on1 = input.bool(true, 'MA 1', inline = 'p3r1', group = g_p3)
p3_len1 = input.int(3, '', minval = 1, inline = 'p3r1', group = g_p3)
p3_typ1 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r1', group = g_p3)
p3_tf1 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r1', group = g_p3)
p3_col1 = input.color(#00e5ff, '', inline = 'p3r1', group = g_p3)
p3_hide1 = input.bool(false, 'Hide Line', inline = 'p3s1', group = g_p3)
p3_lbl1 = input.string('', 'Label Text (blank = auto)', inline = 'p3s1', group = g_p3)

p3_on2 = input.bool(true, 'MA 2', inline = 'p3r2', group = g_p3)
p3_len2 = input.int(5, '', minval = 1, inline = 'p3r2', group = g_p3)
p3_typ2 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r2', group = g_p3)
p3_tf2 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r2', group = g_p3)
p3_col2 = input.color(#00b8d4, '', inline = 'p3r2', group = g_p3)
p3_hide2 = input.bool(false, 'Hide Line', inline = 'p3s2', group = g_p3)
p3_lbl2 = input.string('', 'Label Text (blank = auto)', inline = 'p3s2', group = g_p3)

p3_on3 = input.bool(true, 'MA 3', inline = 'p3r3', group = g_p3)
p3_len3 = input.int(8, '', minval = 1, inline = 'p3r3', group = g_p3)
p3_typ3 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r3', group = g_p3)
p3_tf3 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r3', group = g_p3)
p3_col3 = input.color(#0091ea, '', inline = 'p3r3', group = g_p3)
p3_hide3 = input.bool(false, 'Hide Line', inline = 'p3s3', group = g_p3)
p3_lbl3 = input.string('', 'Label Text (blank = auto)', inline = 'p3s3', group = g_p3)

p3_on4 = input.bool(true, 'MA 4', inline = 'p3r4', group = g_p3)
p3_len4 = input.int(10, '', minval = 1, inline = 'p3r4', group = g_p3)
p3_typ4 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r4', group = g_p3)
p3_tf4 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r4', group = g_p3)
p3_col4 = input.color(#0064b5, '', inline = 'p3r4', group = g_p3)
p3_hide4 = input.bool(false, 'Hide Line', inline = 'p3s4', group = g_p3)
p3_lbl4 = input.string('', 'Label Text (blank = auto)', inline = 'p3s4', group = g_p3)

p3_on5 = input.bool(true, 'MA 5', inline = 'p3r5', group = g_p3)
p3_len5 = input.int(12, '', minval = 1, inline = 'p3r5', group = g_p3)
p3_typ5 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r5', group = g_p3)
p3_tf5 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r5', group = g_p3)
p3_col5 = input.color(#0d47a1, '', inline = 'p3r5', group = g_p3)
p3_hide5 = input.bool(false, 'Hide Line', inline = 'p3s5', group = g_p3)
p3_lbl5 = input.string('', 'Label Text (blank = auto)', inline = 'p3s5', group = g_p3)

p3_on6 = input.bool(true, 'MA 6', inline = 'p3r6', group = g_p3)
p3_len6 = input.int(15, '', minval = 1, inline = 'p3r6', group = g_p3)
p3_typ6 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r6', group = g_p3)
p3_tf6 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r6', group = g_p3)
p3_col6 = input.color(#002171, '', inline = 'p3r6', group = g_p3)
p3_hide6 = input.bool(false, 'Hide Line', inline = 'p3s6', group = g_p3)
p3_lbl6 = input.string('', 'Label Text (blank = auto)', inline = 'p3s6', group = g_p3)

p3_on7 = input.bool(true, 'MA 7', inline = 'p3r7', group = g_p3)
p3_len7 = input.int(30, '', minval = 1, inline = 'p3r7', group = g_p3)
p3_typ7 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r7', group = g_p3)
p3_tf7 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r7', group = g_p3)
p3_col7 = input.color(#ffab00, '', inline = 'p3r7', group = g_p3)
p3_hide7 = input.bool(false, 'Hide Line', inline = 'p3s7', group = g_p3)
p3_lbl7 = input.string('', 'Label Text (blank = auto)', inline = 'p3s7', group = g_p3)

p3_on8 = input.bool(true, 'MA 8', inline = 'p3r8', group = g_p3)
p3_len8 = input.int(35, '', minval = 1, inline = 'p3r8', group = g_p3)
p3_typ8 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r8', group = g_p3)
p3_tf8 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r8', group = g_p3)
p3_col8 = input.color(#ff8f00, '', inline = 'p3r8', group = g_p3)
p3_hide8 = input.bool(false, 'Hide Line', inline = 'p3s8', group = g_p3)
p3_lbl8 = input.string('', 'Label Text (blank = auto)', inline = 'p3s8', group = g_p3)

p3_on9 = input.bool(true, 'MA 9', inline = 'p3r9', group = g_p3)
p3_len9 = input.int(40, '', minval = 1, inline = 'p3r9', group = g_p3)
p3_typ9 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r9', group = g_p3)
p3_tf9 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r9', group = g_p3)
p3_col9 = input.color(#ff6f00, '', inline = 'p3r9', group = g_p3)
p3_hide9 = input.bool(false, 'Hide Line', inline = 'p3s9', group = g_p3)
p3_lbl9 = input.string('', 'Label Text (blank = auto)', inline = 'p3s9', group = g_p3)

p3_on10 = input.bool(true, 'MA 10', inline = 'p3r10', group = g_p3)
p3_len10 = input.int(45, '', minval = 1, inline = 'p3r10', group = g_p3)
p3_typ10 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r10', group = g_p3)
p3_tf10 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r10', group = g_p3)
p3_col10 = input.color(#e65100, '', inline = 'p3r10', group = g_p3)
p3_hide10 = input.bool(false, 'Hide Line', inline = 'p3s10', group = g_p3)
p3_lbl10 = input.string('', 'Label Text (blank = auto)', inline = 'p3s10', group = g_p3)

p3_on11 = input.bool(true, 'MA 11', inline = 'p3r11', group = g_p3)
p3_len11 = input.int(50, '', minval = 1, inline = 'p3r11', group = g_p3)
p3_typ11 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r11', group = g_p3)
p3_tf11 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r11', group = g_p3)
p3_col11 = input.color(#bf360c, '', inline = 'p3r11', group = g_p3)
p3_hide11 = input.bool(false, 'Hide Line', inline = 'p3s11', group = g_p3)
p3_lbl11 = input.string('', 'Label Text (blank = auto)', inline = 'p3s11', group = g_p3)

p3_on12 = input.bool(true, 'MA 12', inline = 'p3r12', group = g_p3)
p3_len12 = input.int(60, '', minval = 1, inline = 'p3r12', group = g_p3)
p3_typ12 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p3r12', group = g_p3)
p3_tf12 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p3r12', group = g_p3)
p3_col12 = input.color(#870000, '', inline = 'p3r12', group = g_p3)
p3_hide12 = input.bool(false, 'Hide Line', inline = 'p3s12', group = g_p3)
p3_lbl12 = input.string('', 'Label Text (blank = auto)', inline = 'p3s12', group = g_p3)

// ───────────────────────────── Panel 4 (Rainbow) ─────────────────────────────
g_p4 = 'Panel 4 (Rainbow)'
p4_on1 = input.bool(true, 'MA 1', inline = 'p4r1', group = g_p4)
p4_len1 = input.int(10, '', minval = 1, inline = 'p4r1', group = g_p4)
p4_typ1 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r1', group = g_p4)
p4_tf1 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r1', group = g_p4)
p4_col1 = input.color(#ff0000, '', inline = 'p4r1', group = g_p4)
p4_hide1 = input.bool(false, 'Hide Line', inline = 'p4s1', group = g_p4)
p4_lbl1 = input.string('', 'Label Text (blank = auto)', inline = 'p4s1', group = g_p4)

p4_on2 = input.bool(true, 'MA 2', inline = 'p4r2', group = g_p4)
p4_len2 = input.int(20, '', minval = 1, inline = 'p4r2', group = g_p4)
p4_typ2 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r2', group = g_p4)
p4_tf2 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r2', group = g_p4)
p4_col2 = input.color(#ff7f00, '', inline = 'p4r2', group = g_p4)
p4_hide2 = input.bool(false, 'Hide Line', inline = 'p4s2', group = g_p4)
p4_lbl2 = input.string('', 'Label Text (blank = auto)', inline = 'p4s2', group = g_p4)

p4_on3 = input.bool(true, 'MA 3', inline = 'p4r3', group = g_p4)
p4_len3 = input.int(30, '', minval = 1, inline = 'p4r3', group = g_p4)
p4_typ3 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r3', group = g_p4)
p4_tf3 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r3', group = g_p4)
p4_col3 = input.color(#ffff00, '', inline = 'p4r3', group = g_p4)
p4_hide3 = input.bool(false, 'Hide Line', inline = 'p4s3', group = g_p4)
p4_lbl3 = input.string('', 'Label Text (blank = auto)', inline = 'p4s3', group = g_p4)

p4_on4 = input.bool(true, 'MA 4', inline = 'p4r4', group = g_p4)
p4_len4 = input.int(40, '', minval = 1, inline = 'p4r4', group = g_p4)
p4_typ4 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r4', group = g_p4)
p4_tf4 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r4', group = g_p4)
p4_col4 = input.color(#7fff00, '', inline = 'p4r4', group = g_p4)
p4_hide4 = input.bool(false, 'Hide Line', inline = 'p4s4', group = g_p4)
p4_lbl4 = input.string('', 'Label Text (blank = auto)', inline = 'p4s4', group = g_p4)

p4_on5 = input.bool(true, 'MA 5', inline = 'p4r5', group = g_p4)
p4_len5 = input.int(50, '', minval = 1, inline = 'p4r5', group = g_p4)
p4_typ5 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r5', group = g_p4)
p4_tf5 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r5', group = g_p4)
p4_col5 = input.color(#00ff00, '', inline = 'p4r5', group = g_p4)
p4_hide5 = input.bool(false, 'Hide Line', inline = 'p4s5', group = g_p4)
p4_lbl5 = input.string('', 'Label Text (blank = auto)', inline = 'p4s5', group = g_p4)

p4_on6 = input.bool(true, 'MA 6', inline = 'p4r6', group = g_p4)
p4_len6 = input.int(60, '', minval = 1, inline = 'p4r6', group = g_p4)
p4_typ6 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r6', group = g_p4)
p4_tf6 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r6', group = g_p4)
p4_col6 = input.color(#00ff7f, '', inline = 'p4r6', group = g_p4)
p4_hide6 = input.bool(false, 'Hide Line', inline = 'p4s6', group = g_p4)
p4_lbl6 = input.string('', 'Label Text (blank = auto)', inline = 'p4s6', group = g_p4)

p4_on7 = input.bool(true, 'MA 7', inline = 'p4r7', group = g_p4)
p4_len7 = input.int(70, '', minval = 1, inline = 'p4r7', group = g_p4)
p4_typ7 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r7', group = g_p4)
p4_tf7 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r7', group = g_p4)
p4_col7 = input.color(#00ffff, '', inline = 'p4r7', group = g_p4)
p4_hide7 = input.bool(false, 'Hide Line', inline = 'p4s7', group = g_p4)
p4_lbl7 = input.string('', 'Label Text (blank = auto)', inline = 'p4s7', group = g_p4)

p4_on8 = input.bool(true, 'MA 8', inline = 'p4r8', group = g_p4)
p4_len8 = input.int(80, '', minval = 1, inline = 'p4r8', group = g_p4)
p4_typ8 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r8', group = g_p4)
p4_tf8 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r8', group = g_p4)
p4_col8 = input.color(#007fff, '', inline = 'p4r8', group = g_p4)
p4_hide8 = input.bool(false, 'Hide Line', inline = 'p4s8', group = g_p4)
p4_lbl8 = input.string('', 'Label Text (blank = auto)', inline = 'p4s8', group = g_p4)

p4_on9 = input.bool(true, 'MA 9', inline = 'p4r9', group = g_p4)
p4_len9 = input.int(90, '', minval = 1, inline = 'p4r9', group = g_p4)
p4_typ9 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r9', group = g_p4)
p4_tf9 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r9', group = g_p4)
p4_col9 = input.color(#0000ff, '', inline = 'p4r9', group = g_p4)
p4_hide9 = input.bool(false, 'Hide Line', inline = 'p4s9', group = g_p4)
p4_lbl9 = input.string('', 'Label Text (blank = auto)', inline = 'p4s9', group = g_p4)

p4_on10 = input.bool(true, 'MA 10', inline = 'p4r10', group = g_p4)
p4_len10 = input.int(100, '', minval = 1, inline = 'p4r10', group = g_p4)
p4_typ10 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r10', group = g_p4)
p4_tf10 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r10', group = g_p4)
p4_col10 = input.color(#7f00ff, '', inline = 'p4r10', group = g_p4)
p4_hide10 = input.bool(false, 'Hide Line', inline = 'p4s10', group = g_p4)
p4_lbl10 = input.string('', 'Label Text (blank = auto)', inline = 'p4s10', group = g_p4)

p4_on11 = input.bool(true, 'MA 11', inline = 'p4r11', group = g_p4)
p4_len11 = input.int(110, '', minval = 1, inline = 'p4r11', group = g_p4)
p4_typ11 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r11', group = g_p4)
p4_tf11 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r11', group = g_p4)
p4_col11 = input.color(#ff00ff, '', inline = 'p4r11', group = g_p4)
p4_hide11 = input.bool(false, 'Hide Line', inline = 'p4s11', group = g_p4)
p4_lbl11 = input.string('', 'Label Text (blank = auto)', inline = 'p4s11', group = g_p4)

p4_on12 = input.bool(true, 'MA 12', inline = 'p4r12', group = g_p4)
p4_len12 = input.int(120, '', minval = 1, inline = 'p4r12', group = g_p4)
p4_typ12 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p4r12', group = g_p4)
p4_tf12 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p4r12', group = g_p4)
p4_col12 = input.color(#ff007f, '', inline = 'p4r12', group = g_p4)
p4_hide12 = input.bool(false, 'Hide Line', inline = 'p4s12', group = g_p4)
p4_lbl12 = input.string('', 'Label Text (blank = auto)', inline = 'p4s12', group = g_p4)

// ───────────────────────────── Panel 5 (Cipher A) ─────────────────────────────
g_p5 = 'Panel 5 (Cipher A)'
p5_on1 = input.bool(true, 'MA 1', inline = 'p5r1', group = g_p5)
p5_len1 = input.int(5, '', minval = 1, inline = 'p5r1', group = g_p5)
p5_typ1 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r1', group = g_p5)
p5_tf1 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r1', group = g_p5)
p5_col1 = input.color(#1573d4, '', inline = 'p5r1', group = g_p5)
p5_hide1 = input.bool(false, 'Hide Line', inline = 'p5s1', group = g_p5)
p5_lbl1 = input.string('', 'Label Text (blank = auto)', inline = 'p5s1', group = g_p5)

p5_on2 = input.bool(true, 'MA 2', inline = 'p5r2', group = g_p5)
p5_len2 = input.int(11, '', minval = 1, inline = 'p5r2', group = g_p5)
p5_typ2 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r2', group = g_p5)
p5_tf2 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r2', group = g_p5)
p5_col2 = input.color(#3096ff, '', inline = 'p5r2', group = g_p5)
p5_hide2 = input.bool(false, 'Hide Line', inline = 'p5s2', group = g_p5)
p5_lbl2 = input.string('', 'Label Text (blank = auto)', inline = 'p5s2', group = g_p5)

p5_on3 = input.bool(true, 'MA 3', inline = 'p5r3', group = g_p5)
p5_len3 = input.int(15, '', minval = 1, inline = 'p5r3', group = g_p5)
p5_typ3 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r3', group = g_p5)
p5_tf3 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r3', group = g_p5)
p5_col3 = input.color(#57abff, '', inline = 'p5r3', group = g_p5)
p5_hide3 = input.bool(false, 'Hide Line', inline = 'p5s3', group = g_p5)
p5_lbl3 = input.string('', 'Label Text (blank = auto)', inline = 'p5s3', group = g_p5)

p5_on4 = input.bool(true, 'MA 4', inline = 'p5r4', group = g_p5)
p5_len4 = input.int(18, '', minval = 1, inline = 'p5r4', group = g_p5)
p5_typ4 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r4', group = g_p5)
p5_tf4 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r4', group = g_p5)
p5_col4 = input.color(#85c2ff, '', inline = 'p5r4', group = g_p5)
p5_hide4 = input.bool(false, 'Hide Line', inline = 'p5s4', group = g_p5)
p5_lbl4 = input.string('', 'Label Text (blank = auto)', inline = 'p5s4', group = g_p5)

p5_on5 = input.bool(true, 'MA 5', inline = 'p5r5', group = g_p5)
p5_len5 = input.int(21, '', minval = 1, inline = 'p5r5', group = g_p5)
p5_typ5 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r5', group = g_p5)
p5_tf5 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r5', group = g_p5)
p5_col5 = input.color(#9bcdff, '', inline = 'p5r5', group = g_p5)
p5_hide5 = input.bool(false, 'Hide Line', inline = 'p5s5', group = g_p5)
p5_lbl5 = input.string('', 'Label Text (blank = auto)', inline = 'p5s5', group = g_p5)

p5_on6 = input.bool(true, 'MA 6', inline = 'p5r6', group = g_p5)
p5_len6 = input.int(24, '', minval = 1, inline = 'p5r6', group = g_p5)
p5_typ6 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r6', group = g_p5)
p5_tf6 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r6', group = g_p5)
p5_col6 = input.color(#b3d9ff, '', inline = 'p5r6', group = g_p5)
p5_hide6 = input.bool(false, 'Hide Line', inline = 'p5s6', group = g_p5)
p5_lbl6 = input.string('', 'Label Text (blank = auto)', inline = 'p5s6', group = g_p5)

p5_on7 = input.bool(true, 'MA 7', inline = 'p5r7', group = g_p5)
p5_len7 = input.int(28, '', minval = 1, inline = 'p5r7', group = g_p5)
p5_typ7 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r7', group = g_p5)
p5_tf7 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r7', group = g_p5)
p5_col7 = input.color(#c9e5ff, '', inline = 'p5r7', group = g_p5)
p5_hide7 = input.bool(false, 'Hide Line', inline = 'p5s7', group = g_p5)
p5_lbl7 = input.string('', 'Label Text (blank = auto)', inline = 'p5s7', group = g_p5)

p5_on8 = input.bool(true, 'MA 8', inline = 'p5r8', group = g_p5)
p5_len8 = input.int(34, '', minval = 1, inline = 'p5r8', group = g_p5)
p5_typ8 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r8', group = g_p5)
p5_tf8 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r8', group = g_p5)
p5_col8 = input.color(#dfecfb, '', inline = 'p5r8', group = g_p5)
p5_hide8 = input.bool(false, 'Hide Line', inline = 'p5s8', group = g_p5)
p5_lbl8 = input.string('', 'Label Text (blank = auto)', inline = 'p5s8', group = g_p5)

p5_on9 = input.bool(false, 'MA 9', inline = 'p5r9', group = g_p5)
p5_len9 = input.int(50, '', minval = 1, inline = 'p5r9', group = g_p5)
p5_typ9 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r9', group = g_p5)
p5_tf9 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r9', group = g_p5)
p5_col9 = input.color(#808080, '', inline = 'p5r9', group = g_p5)
p5_hide9 = input.bool(false, 'Hide Line', inline = 'p5s9', group = g_p5)
p5_lbl9 = input.string('', 'Label Text (blank = auto)', inline = 'p5s9', group = g_p5)

p5_on10 = input.bool(false, 'MA 10', inline = 'p5r10', group = g_p5)
p5_len10 = input.int(100, '', minval = 1, inline = 'p5r10', group = g_p5)
p5_typ10 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r10', group = g_p5)
p5_tf10 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r10', group = g_p5)
p5_col10 = input.color(#808080, '', inline = 'p5r10', group = g_p5)
p5_hide10 = input.bool(false, 'Hide Line', inline = 'p5s10', group = g_p5)
p5_lbl10 = input.string('', 'Label Text (blank = auto)', inline = 'p5s10', group = g_p5)

p5_on11 = input.bool(false, 'MA 11', inline = 'p5r11', group = g_p5)
p5_len11 = input.int(150, '', minval = 1, inline = 'p5r11', group = g_p5)
p5_typ11 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r11', group = g_p5)
p5_tf11 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r11', group = g_p5)
p5_col11 = input.color(#808080, '', inline = 'p5r11', group = g_p5)
p5_hide11 = input.bool(false, 'Hide Line', inline = 'p5s11', group = g_p5)
p5_lbl11 = input.string('', 'Label Text (blank = auto)', inline = 'p5s11', group = g_p5)

p5_on12 = input.bool(false, 'MA 12', inline = 'p5r12', group = g_p5)
p5_len12 = input.int(200, '', minval = 1, inline = 'p5r12', group = g_p5)
p5_typ12 = input.string('EMA', '', options = ['SMA', 'EMA', 'RMA', 'WMA', 'HMA', 'LSMA'], inline = 'p5r12', group = g_p5)
p5_tf12 = input.string('Chart', '', options = ['Chart', 'Daily', 'Weekly'], inline = 'p5r12', group = g_p5)
p5_col12 = input.color(#808080, '', inline = 'p5r12', group = g_p5)
p5_hide12 = input.bool(false, 'Hide Line', inline = 'p5s12', group = g_p5)
p5_lbl12 = input.string('', 'Label Text (blank = auto)', inline = 'p5s12', group = g_p5)

p5_bearColor = input.color(#787b86, 'Bearish Color (all 8 lines)', group = g_p5, tooltip = 'When Panel 5 is active, all 8 ribbon lines switch to this single color together whenever EMA 34 is not below EMA 11 (downtrend). Each line keeps its own color above during an uptrend.')

// ───────────────────────────── Panel 5 (Cipher A) Signals ─────────────────────────────
g_p5sig = 'Panel 5 (Cipher A) - Signals'
show_signals = input.bool(true, 'Show Signals (Diamonds, Crosses, Triangles)', group = g_p5sig, tooltip = 'Only drawn while Panel 5 is the active panel. Uses Panel 5\'s EMA 1/2/3/8 (lengths 5/11/15/34 by default) plus a WaveTrend + RSI+MFI filter, matching the original VuManChu Cipher A signals.')
wtChannelLen = input.int(9, 'WT Channel Length', group = g_p5sig)
wtAverageLen = input.int(13, 'WT Average Length', group = g_p5sig)
wtMASource = input.source(hlc3, 'WT MA Source', group = g_p5sig)
wtMALen = input.int(3, 'WT MA Length', group = g_p5sig)
osLevel3 = input.int(-80, 'WT Oversold Level 3', group = g_p5sig)
rsiSrc = input.source(close, 'RSI Source', group = g_p5sig)
rsiLen = input.int(14, 'RSI Length', group = g_p5sig)
rsiMFIperiod = input.int(60, 'RSI+MFI Period', group = g_p5sig)
rsiMFIMultiplier = input.int(150, 'RSI+MFI Area Multiplier', group = g_p5sig)

f_wavetrend(_src, _chlen, _avg, _malen) =>
    _esa = ta.ema(_src, _chlen)
    _de = ta.ema(math.abs(_src - _esa), _chlen)
    _ci = (_src - _esa) / (0.015 * _de)
    _tci = ta.ema(_ci, _avg)
    _wt1 = _tci
    _wt2 = ta.sma(_wt1, _malen)
    [_wt1, _wt2]

f_rsimfi(_period, _multiplier, _tf) =>
    request.security(syminfo.tickerid, _tf, ta.sma(((close - open) / (high - low)) * _multiplier, _period))

// ───────────────────────────── Active Panel Resolution ─────────────────────────────
// Only the 12 slots belonging to the active panel are calculated, plotted, and labeled.

on_1 = f_sel(p1_on1, p2_on1, p3_on1, p4_on1, p5_on1)
len_1 = f_sel(p1_len1, p2_len1, p3_len1, p4_len1, p5_len1)
typ_1 = f_sel(p1_typ1, p2_typ1, p3_typ1, p4_typ1, p5_typ1)
tf_1 = f_sel(p1_tf1, p2_tf1, p3_tf1, p4_tf1, p5_tf1)
col_1 = f_sel(p1_col1, p2_col1, p3_col1, p4_col1, p5_col1)
hide_1 = f_sel(p1_hide1, p2_hide1, p3_hide1, p4_hide1, p5_hide1)
lblCustom_1 = f_sel(p1_lbl1, p2_lbl1, p3_lbl1, p4_lbl1, p5_lbl1)

on_2 = f_sel(p1_on2, p2_on2, p3_on2, p4_on2, p5_on2)
len_2 = f_sel(p1_len2, p2_len2, p3_len2, p4_len2, p5_len2)
typ_2 = f_sel(p1_typ2, p2_typ2, p3_typ2, p4_typ2, p5_typ2)
tf_2 = f_sel(p1_tf2, p2_tf2, p3_tf2, p4_tf2, p5_tf2)
col_2 = f_sel(p1_col2, p2_col2, p3_col2, p4_col2, p5_col2)
hide_2 = f_sel(p1_hide2, p2_hide2, p3_hide2, p4_hide2, p5_hide2)
lblCustom_2 = f_sel(p1_lbl2, p2_lbl2, p3_lbl2, p4_lbl2, p5_lbl2)

on_3 = f_sel(p1_on3, p2_on3, p3_on3, p4_on3, p5_on3)
len_3 = f_sel(p1_len3, p2_len3, p3_len3, p4_len3, p5_len3)
typ_3 = f_sel(p1_typ3, p2_typ3, p3_typ3, p4_typ3, p5_typ3)
tf_3 = f_sel(p1_tf3, p2_tf3, p3_tf3, p4_tf3, p5_tf3)
col_3 = f_sel(p1_col3, p2_col3, p3_col3, p4_col3, p5_col3)
hide_3 = f_sel(p1_hide3, p2_hide3, p3_hide3, p4_hide3, p5_hide3)
lblCustom_3 = f_sel(p1_lbl3, p2_lbl3, p3_lbl3, p4_lbl3, p5_lbl3)

on_4 = f_sel(p1_on4, p2_on4, p3_on4, p4_on4, p5_on4)
len_4 = f_sel(p1_len4, p2_len4, p3_len4, p4_len4, p5_len4)
typ_4 = f_sel(p1_typ4, p2_typ4, p3_typ4, p4_typ4, p5_typ4)
tf_4 = f_sel(p1_tf4, p2_tf4, p3_tf4, p4_tf4, p5_tf4)
col_4 = f_sel(p1_col4, p2_col4, p3_col4, p4_col4, p5_col4)
hide_4 = f_sel(p1_hide4, p2_hide4, p3_hide4, p4_hide4, p5_hide4)
lblCustom_4 = f_sel(p1_lbl4, p2_lbl4, p3_lbl4, p4_lbl4, p5_lbl4)

on_5 = f_sel(p1_on5, p2_on5, p3_on5, p4_on5, p5_on5)
len_5 = f_sel(p1_len5, p2_len5, p3_len5, p4_len5, p5_len5)
typ_5 = f_sel(p1_typ5, p2_typ5, p3_typ5, p4_typ5, p5_typ5)
tf_5 = f_sel(p1_tf5, p2_tf5, p3_tf5, p4_tf5, p5_tf5)
col_5 = f_sel(p1_col5, p2_col5, p3_col5, p4_col5, p5_col5)
hide_5 = f_sel(p1_hide5, p2_hide5, p3_hide5, p4_hide5, p5_hide5)
lblCustom_5 = f_sel(p1_lbl5, p2_lbl5, p3_lbl5, p4_lbl5, p5_lbl5)

on_6 = f_sel(p1_on6, p2_on6, p3_on6, p4_on6, p5_on6)
len_6 = f_sel(p1_len6, p2_len6, p3_len6, p4_len6, p5_len6)
typ_6 = f_sel(p1_typ6, p2_typ6, p3_typ6, p4_typ6, p5_typ6)
tf_6 = f_sel(p1_tf6, p2_tf6, p3_tf6, p4_tf6, p5_tf6)
col_6 = f_sel(p1_col6, p2_col6, p3_col6, p4_col6, p5_col6)
hide_6 = f_sel(p1_hide6, p2_hide6, p3_hide6, p4_hide6, p5_hide6)
lblCustom_6 = f_sel(p1_lbl6, p2_lbl6, p3_lbl6, p4_lbl6, p5_lbl6)

on_7 = f_sel(p1_on7, p2_on7, p3_on7, p4_on7, p5_on7)
len_7 = f_sel(p1_len7, p2_len7, p3_len7, p4_len7, p5_len7)
typ_7 = f_sel(p1_typ7, p2_typ7, p3_typ7, p4_typ7, p5_typ7)
tf_7 = f_sel(p1_tf7, p2_tf7, p3_tf7, p4_tf7, p5_tf7)
col_7 = f_sel(p1_col7, p2_col7, p3_col7, p4_col7, p5_col7)
hide_7 = f_sel(p1_hide7, p2_hide7, p3_hide7, p4_hide7, p5_hide7)
lblCustom_7 = f_sel(p1_lbl7, p2_lbl7, p3_lbl7, p4_lbl7, p5_lbl7)

on_8 = f_sel(p1_on8, p2_on8, p3_on8, p4_on8, p5_on8)
len_8 = f_sel(p1_len8, p2_len8, p3_len8, p4_len8, p5_len8)
typ_8 = f_sel(p1_typ8, p2_typ8, p3_typ8, p4_typ8, p5_typ8)
tf_8 = f_sel(p1_tf8, p2_tf8, p3_tf8, p4_tf8, p5_tf8)
col_8 = f_sel(p1_col8, p2_col8, p3_col8, p4_col8, p5_col8)
hide_8 = f_sel(p1_hide8, p2_hide8, p3_hide8, p4_hide8, p5_hide8)
lblCustom_8 = f_sel(p1_lbl8, p2_lbl8, p3_lbl8, p4_lbl8, p5_lbl8)

on_9 = f_sel(p1_on9, p2_on9, p3_on9, p4_on9, p5_on9)
len_9 = f_sel(p1_len9, p2_len9, p3_len9, p4_len9, p5_len9)
typ_9 = f_sel(p1_typ9, p2_typ9, p3_typ9, p4_typ9, p5_typ9)
tf_9 = f_sel(p1_tf9, p2_tf9, p3_tf9, p4_tf9, p5_tf9)
col_9 = f_sel(p1_col9, p2_col9, p3_col9, p4_col9, p5_col9)
hide_9 = f_sel(p1_hide9, p2_hide9, p3_hide9, p4_hide9, p5_hide9)
lblCustom_9 = f_sel(p1_lbl9, p2_lbl9, p3_lbl9, p4_lbl9, p5_lbl9)

on_10 = f_sel(p1_on10, p2_on10, p3_on10, p4_on10, p5_on10)
len_10 = f_sel(p1_len10, p2_len10, p3_len10, p4_len10, p5_len10)
typ_10 = f_sel(p1_typ10, p2_typ10, p3_typ10, p4_typ10, p5_typ10)
tf_10 = f_sel(p1_tf10, p2_tf10, p3_tf10, p4_tf10, p5_tf10)
col_10 = f_sel(p1_col10, p2_col10, p3_col10, p4_col10, p5_col10)
hide_10 = f_sel(p1_hide10, p2_hide10, p3_hide10, p4_hide10, p5_hide10)
lblCustom_10 = f_sel(p1_lbl10, p2_lbl10, p3_lbl10, p4_lbl10, p5_lbl10)

on_11 = f_sel(p1_on11, p2_on11, p3_on11, p4_on11, p5_on11)
len_11 = f_sel(p1_len11, p2_len11, p3_len11, p4_len11, p5_len11)
typ_11 = f_sel(p1_typ11, p2_typ11, p3_typ11, p4_typ11, p5_typ11)
tf_11 = f_sel(p1_tf11, p2_tf11, p3_tf11, p4_tf11, p5_tf11)
col_11 = f_sel(p1_col11, p2_col11, p3_col11, p4_col11, p5_col11)
hide_11 = f_sel(p1_hide11, p2_hide11, p3_hide11, p4_hide11, p5_hide11)
lblCustom_11 = f_sel(p1_lbl11, p2_lbl11, p3_lbl11, p4_lbl11, p5_lbl11)

on_12 = f_sel(p1_on12, p2_on12, p3_on12, p4_on12, p5_on12)
len_12 = f_sel(p1_len12, p2_len12, p3_len12, p4_len12, p5_len12)
typ_12 = f_sel(p1_typ12, p2_typ12, p3_typ12, p4_typ12, p5_typ12)
tf_12 = f_sel(p1_tf12, p2_tf12, p3_tf12, p4_tf12, p5_tf12)
col_12 = f_sel(p1_col12, p2_col12, p3_col12, p4_col12, p5_col12)
hide_12 = f_sel(p1_hide12, p2_hide12, p3_hide12, p4_hide12, p5_hide12)
lblCustom_12 = f_sel(p1_lbl12, p2_lbl12, p3_lbl12, p4_lbl12, p5_lbl12)

// ───────────────────────────── MA Calculations ─────────────────────────────
chartMa_1 = f_ma(src, len_1, typ_1)
dailyMa_1 = request.security(syminfo.tickerid, 'D', f_ma(src, len_1, typ_1))
weeklyMa_1 = request.security(syminfo.tickerid, 'W', f_ma(src, len_1, typ_1))
finalMa_1 = tf_1 == 'Daily' ? dailyMa_1 : tf_1 == 'Weekly' ? weeklyMa_1 : chartMa_1
autoLbl_1 = str.tostring(len_1) + ' ' + typ_1 + (tf_1 == 'Daily' ? ' D' : tf_1 == 'Weekly' ? ' W' : '')
lbl_1 = lblCustom_1 == '' ? autoLbl_1 : lblCustom_1
dispFlag_1 = f_hideDispFlag(hide_1)

chartMa_2 = f_ma(src, len_2, typ_2)
dailyMa_2 = request.security(syminfo.tickerid, 'D', f_ma(src, len_2, typ_2))
weeklyMa_2 = request.security(syminfo.tickerid, 'W', f_ma(src, len_2, typ_2))
finalMa_2 = tf_2 == 'Daily' ? dailyMa_2 : tf_2 == 'Weekly' ? weeklyMa_2 : chartMa_2
autoLbl_2 = str.tostring(len_2) + ' ' + typ_2 + (tf_2 == 'Daily' ? ' D' : tf_2 == 'Weekly' ? ' W' : '')
lbl_2 = lblCustom_2 == '' ? autoLbl_2 : lblCustom_2
dispFlag_2 = f_hideDispFlag(hide_2)

chartMa_3 = f_ma(src, len_3, typ_3)
dailyMa_3 = request.security(syminfo.tickerid, 'D', f_ma(src, len_3, typ_3))
weeklyMa_3 = request.security(syminfo.tickerid, 'W', f_ma(src, len_3, typ_3))
finalMa_3 = tf_3 == 'Daily' ? dailyMa_3 : tf_3 == 'Weekly' ? weeklyMa_3 : chartMa_3
autoLbl_3 = str.tostring(len_3) + ' ' + typ_3 + (tf_3 == 'Daily' ? ' D' : tf_3 == 'Weekly' ? ' W' : '')
lbl_3 = lblCustom_3 == '' ? autoLbl_3 : lblCustom_3
dispFlag_3 = f_hideDispFlag(hide_3)

chartMa_4 = f_ma(src, len_4, typ_4)
dailyMa_4 = request.security(syminfo.tickerid, 'D', f_ma(src, len_4, typ_4))
weeklyMa_4 = request.security(syminfo.tickerid, 'W', f_ma(src, len_4, typ_4))
finalMa_4 = tf_4 == 'Daily' ? dailyMa_4 : tf_4 == 'Weekly' ? weeklyMa_4 : chartMa_4
autoLbl_4 = str.tostring(len_4) + ' ' + typ_4 + (tf_4 == 'Daily' ? ' D' : tf_4 == 'Weekly' ? ' W' : '')
lbl_4 = lblCustom_4 == '' ? autoLbl_4 : lblCustom_4
dispFlag_4 = f_hideDispFlag(hide_4)

chartMa_5 = f_ma(src, len_5, typ_5)
dailyMa_5 = request.security(syminfo.tickerid, 'D', f_ma(src, len_5, typ_5))
weeklyMa_5 = request.security(syminfo.tickerid, 'W', f_ma(src, len_5, typ_5))
finalMa_5 = tf_5 == 'Daily' ? dailyMa_5 : tf_5 == 'Weekly' ? weeklyMa_5 : chartMa_5
autoLbl_5 = str.tostring(len_5) + ' ' + typ_5 + (tf_5 == 'Daily' ? ' D' : tf_5 == 'Weekly' ? ' W' : '')
lbl_5 = lblCustom_5 == '' ? autoLbl_5 : lblCustom_5
dispFlag_5 = f_hideDispFlag(hide_5)

chartMa_6 = f_ma(src, len_6, typ_6)
dailyMa_6 = request.security(syminfo.tickerid, 'D', f_ma(src, len_6, typ_6))
weeklyMa_6 = request.security(syminfo.tickerid, 'W', f_ma(src, len_6, typ_6))
finalMa_6 = tf_6 == 'Daily' ? dailyMa_6 : tf_6 == 'Weekly' ? weeklyMa_6 : chartMa_6
autoLbl_6 = str.tostring(len_6) + ' ' + typ_6 + (tf_6 == 'Daily' ? ' D' : tf_6 == 'Weekly' ? ' W' : '')
lbl_6 = lblCustom_6 == '' ? autoLbl_6 : lblCustom_6
dispFlag_6 = f_hideDispFlag(hide_6)

chartMa_7 = f_ma(src, len_7, typ_7)
dailyMa_7 = request.security(syminfo.tickerid, 'D', f_ma(src, len_7, typ_7))
weeklyMa_7 = request.security(syminfo.tickerid, 'W', f_ma(src, len_7, typ_7))
finalMa_7 = tf_7 == 'Daily' ? dailyMa_7 : tf_7 == 'Weekly' ? weeklyMa_7 : chartMa_7
autoLbl_7 = str.tostring(len_7) + ' ' + typ_7 + (tf_7 == 'Daily' ? ' D' : tf_7 == 'Weekly' ? ' W' : '')
lbl_7 = lblCustom_7 == '' ? autoLbl_7 : lblCustom_7
dispFlag_7 = f_hideDispFlag(hide_7)

chartMa_8 = f_ma(src, len_8, typ_8)
dailyMa_8 = request.security(syminfo.tickerid, 'D', f_ma(src, len_8, typ_8))
weeklyMa_8 = request.security(syminfo.tickerid, 'W', f_ma(src, len_8, typ_8))
finalMa_8 = tf_8 == 'Daily' ? dailyMa_8 : tf_8 == 'Weekly' ? weeklyMa_8 : chartMa_8
autoLbl_8 = str.tostring(len_8) + ' ' + typ_8 + (tf_8 == 'Daily' ? ' D' : tf_8 == 'Weekly' ? ' W' : '')
lbl_8 = lblCustom_8 == '' ? autoLbl_8 : lblCustom_8
dispFlag_8 = f_hideDispFlag(hide_8)

chartMa_9 = f_ma(src, len_9, typ_9)
dailyMa_9 = request.security(syminfo.tickerid, 'D', f_ma(src, len_9, typ_9))
weeklyMa_9 = request.security(syminfo.tickerid, 'W', f_ma(src, len_9, typ_9))
finalMa_9 = tf_9 == 'Daily' ? dailyMa_9 : tf_9 == 'Weekly' ? weeklyMa_9 : chartMa_9
autoLbl_9 = str.tostring(len_9) + ' ' + typ_9 + (tf_9 == 'Daily' ? ' D' : tf_9 == 'Weekly' ? ' W' : '')
lbl_9 = lblCustom_9 == '' ? autoLbl_9 : lblCustom_9
dispFlag_9 = f_hideDispFlag(hide_9)

chartMa_10 = f_ma(src, len_10, typ_10)
dailyMa_10 = request.security(syminfo.tickerid, 'D', f_ma(src, len_10, typ_10))
weeklyMa_10 = request.security(syminfo.tickerid, 'W', f_ma(src, len_10, typ_10))
finalMa_10 = tf_10 == 'Daily' ? dailyMa_10 : tf_10 == 'Weekly' ? weeklyMa_10 : chartMa_10
autoLbl_10 = str.tostring(len_10) + ' ' + typ_10 + (tf_10 == 'Daily' ? ' D' : tf_10 == 'Weekly' ? ' W' : '')
lbl_10 = lblCustom_10 == '' ? autoLbl_10 : lblCustom_10
dispFlag_10 = f_hideDispFlag(hide_10)

chartMa_11 = f_ma(src, len_11, typ_11)
dailyMa_11 = request.security(syminfo.tickerid, 'D', f_ma(src, len_11, typ_11))
weeklyMa_11 = request.security(syminfo.tickerid, 'W', f_ma(src, len_11, typ_11))
finalMa_11 = tf_11 == 'Daily' ? dailyMa_11 : tf_11 == 'Weekly' ? weeklyMa_11 : chartMa_11
autoLbl_11 = str.tostring(len_11) + ' ' + typ_11 + (tf_11 == 'Daily' ? ' D' : tf_11 == 'Weekly' ? ' W' : '')
lbl_11 = lblCustom_11 == '' ? autoLbl_11 : lblCustom_11
dispFlag_11 = f_hideDispFlag(hide_11)

chartMa_12 = f_ma(src, len_12, typ_12)
dailyMa_12 = request.security(syminfo.tickerid, 'D', f_ma(src, len_12, typ_12))
weeklyMa_12 = request.security(syminfo.tickerid, 'W', f_ma(src, len_12, typ_12))
finalMa_12 = tf_12 == 'Daily' ? dailyMa_12 : tf_12 == 'Weekly' ? weeklyMa_12 : chartMa_12
autoLbl_12 = str.tostring(len_12) + ' ' + typ_12 + (tf_12 == 'Daily' ? ' D' : tf_12 == 'Weekly' ? ' W' : '')
lbl_12 = lblCustom_12 == '' ? autoLbl_12 : lblCustom_12
dispFlag_12 = f_hideDispFlag(hide_12)

// ───────────────────────────── Panel 5 (Cipher A) Dynamic Ribbon Coloring ─────────────────────────────
// Overrides the 8 ribbon colors together based on trend direction, only while Panel 5 is active.
ribbonDir5 = finalMa_8 < finalMa_2
col_1 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_1 : p5_bearColor) : col_1
col_2 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_2 : p5_bearColor) : col_2
col_3 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_3 : p5_bearColor) : col_3
col_4 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_4 : p5_bearColor) : col_4
col_5 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_5 : p5_bearColor) : col_5
col_6 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_6 : p5_bearColor) : col_6
col_7 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_7 : p5_bearColor) : col_7
col_8 := activePanel == 'Panel 5' ? (ribbonDir5 ? col_8 : p5_bearColor) : col_8

// ───────────────────────────── Panel 5 (Cipher A) Signal Conditions ─────────────────────────────
p5Active = activePanel == 'Panel 5'
[wt1, wt2] = f_wavetrend(wtMASource, wtChannelLen, wtAverageLen, wtMALen)
rsiVal = ta.rsi(rsiSrc, rsiLen)
rsiMFI = f_rsimfi(rsiMFIperiod, rsiMFIMultiplier, timeframe.period)
wtCross = ta.cross(wt1, wt2)
wtCrossDown = wt2 - wt1 >= 0
longEmaSig = ta.crossover(finalMa_2, finalMa_8)
shortEmaSig = ta.crossover(finalMa_8, finalMa_2)
redCrossSig = ta.crossunder(finalMa_1, finalMa_2)
blueTriSig = ta.crossover(finalMa_2, finalMa_3)
redDiamondSig = wtCross and wtCrossDown
bullCandleSig = open > finalMa_2 and open > finalMa_8 and close[1] > open[1] and close > open and not redDiamondSig and not redCrossSig
bloodDiamondSig = redDiamondSig and redCrossSig
yellowCrossSig = redDiamondSig and wt2 < 45 and wt2 > osLevel3 and rsiVal < 30 and rsiVal > 15 and rsiMFI < -5

// ───────────────────────────── Plots ─────────────────────────────
p5_plot1 = plot(on_1 ? finalMa_1 : na, 'MA 1', col_1, ma_line_width, style = plot.style_line, display = dispFlag_1)
p5_plot2 = plot(on_2 ? finalMa_2 : na, 'MA 2', col_2, ma_line_width, style = plot.style_line, display = dispFlag_2)
plot(on_3 ? finalMa_3 : na, 'MA 3', col_3, ma_line_width, style = plot.style_line, display = dispFlag_3)
plot(on_4 ? finalMa_4 : na, 'MA 4', col_4, ma_line_width, style = plot.style_line, display = dispFlag_4)
plot(on_5 ? finalMa_5 : na, 'MA 5', col_5, ma_line_width, style = plot.style_line, display = dispFlag_5)
plot(on_6 ? finalMa_6 : na, 'MA 6', col_6, ma_line_width, style = plot.style_line, display = dispFlag_6)
plot(on_7 ? finalMa_7 : na, 'MA 7', col_7, ma_line_width, style = plot.style_line, display = dispFlag_7)
p5_plot8 = plot(on_8 ? finalMa_8 : na, 'MA 8', col_8, ma_line_width, style = plot.style_line, display = dispFlag_8)
plot(on_9 ? finalMa_9 : na, 'MA 9', col_9, ma_line_width, style = plot.style_line, display = dispFlag_9)
plot(on_10 ? finalMa_10 : na, 'MA 10', col_10, ma_line_width, style = plot.style_line, display = dispFlag_10)
plot(on_11 ? finalMa_11 : na, 'MA 11', col_11, ma_line_width, style = plot.style_line, display = dispFlag_11)
plot(on_12 ? finalMa_12 : na, 'MA 12', col_12, ma_line_width, style = plot.style_line, display = dispFlag_12)

fill(p5_plot1, p5_plot2, color = activePanel == 'Panel 5' ? color.new(#1573d4, 85) : na, title = 'Cipher A Fill 1-2')
fill(p5_plot2, p5_plot8, color = activePanel == 'Panel 5' ? color.new(#363a45, 85) : na, title = 'Cipher A Fill 2-8')

// ───────────────────────────── Panel 5 (Cipher A) Signal Plots ─────────────────────────────
plotshape(show_signals and p5Active and longEmaSig, style = shape.circle, color = color.new(#00ff00, 50), location = location.abovebar, size = size.tiny, title = 'Long EMA Signal')
plotshape(show_signals and p5Active and shortEmaSig, style = shape.circle, color = color.new(#ff0000, 50), location = location.abovebar, size = size.tiny, title = 'Short EMA Signal')
plotshape(show_signals and p5Active and redCrossSig, style = shape.xcross, color = color.new(#ff0000, 50), location = location.abovebar, size = size.tiny, title = 'Red Cross')
plotshape(show_signals and p5Active and blueTriSig, style = shape.triangleup, color = color.new(#0064ff, 50), location = location.abovebar, size = size.small, title = 'Blue Triangle')
plotshape(show_signals and p5Active and redDiamondSig, style = shape.diamond, color = color.new(#ff0000, 25), location = location.abovebar, size = size.tiny, title = 'Red Diamond')
plotshape(show_signals and p5Active and bullCandleSig, style = shape.diamond, color = color.new(color.yellow, 75), location = location.abovebar, size = size.tiny, title = 'Bull Candle')
plotshape(show_signals and p5Active and bloodDiamondSig, style = shape.diamond, color = color.new(#ff0000, 15), location = location.abovebar, size = size.small, title = 'Blood Diamond')
plotshape(show_signals and p5Active and yellowCrossSig, style = shape.xcross, color = color.new(color.yellow, 25), location = location.abovebar, size = size.small, title = 'Yellow Cross')

alertcondition(redDiamondSig, 'Red Diamond', 'Red Diamond')
alertcondition(bloodDiamondSig, 'Blood Diamond', 'Blood Diamond')
alertcondition(yellowCrossSig, 'YellowX', 'YellowX')
alertcondition(redCrossSig, 'RedX', 'RedX')
alertcondition(longEmaSig, 'Long EMA', 'Long EMA')
alertcondition(blueTriSig, 'Blue Triangle', 'Blue Triangle')

// ───────────────────────────── Line Labels ─────────────────────────────
if barstate.islast
    connStart = bar_index + gap_bars
    lblX = connStart + conn_length
    lblSz = f_labelSize(label_size_str)

    f_updateLabelLine(0, show_labels and on_1, finalMa_1, col_1, lbl_1, connStart, lblX, lblSz)
    f_updateLabelLine(1, show_labels and on_2, finalMa_2, col_2, lbl_2, connStart, lblX, lblSz)
    f_updateLabelLine(2, show_labels and on_3, finalMa_3, col_3, lbl_3, connStart, lblX, lblSz)
    f_updateLabelLine(3, show_labels and on_4, finalMa_4, col_4, lbl_4, connStart, lblX, lblSz)
    f_updateLabelLine(4, show_labels and on_5, finalMa_5, col_5, lbl_5, connStart, lblX, lblSz)
    f_updateLabelLine(5, show_labels and on_6, finalMa_6, col_6, lbl_6, connStart, lblX, lblSz)
    f_updateLabelLine(6, show_labels and on_7, finalMa_7, col_7, lbl_7, connStart, lblX, lblSz)
    f_updateLabelLine(7, show_labels and on_8, finalMa_8, col_8, lbl_8, connStart, lblX, lblSz)
    f_updateLabelLine(8, show_labels and on_9, finalMa_9, col_9, lbl_9, connStart, lblX, lblSz)
    f_updateLabelLine(9, show_labels and on_10, finalMa_10, col_10, lbl_10, connStart, lblX, lblSz)
    f_updateLabelLine(10, show_labels and on_11, finalMa_11, col_11, lbl_11, connStart, lblX, lblSz)
    f_updateLabelLine(11, show_labels and on_12, finalMa_12, col_12, lbl_12, connStart, lblX, lblSz)
````
