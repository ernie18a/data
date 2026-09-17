<!-- tradingview-pine-id: PUB;c9001cd9ba4e42a08712b54f9279b4c4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CRT Engine [vault]

Source: https://www.tradingview.com/script/cxsWjhzc-CRT-Engine-vault/

## Description

CRT Engine [vault]

CRT Engine [vault] is a complete Candle Range Theory toolkit built around one idea: the higher timeframe candle sets the range, the lower timeframe shows you how that range gets manipulated and delivered. The script tracks the HTF range, detects sweeps of the previous high or low, confirms the shift with an order block or a CISD, and follows the model until it either reaches its target or gets invalidated. Around that core it adds HTF fair value gaps, previous period highs and lows, SMT divergence, multi timeframe moving averages and a compact dashboard, all sharing one color palette so the chart stays readable.

HOW THE CRT MODEL WORKS

Every new HTF candle opens a new range. Its high and low are tracked live on the chart timeframe. When the HTF candle closes, the script compares it to the previous HTF candle:

• Sweep of the high: the candle traded above the previous high and closed back below it. Bias flips to bearish, the previous low becomes the target.
• Sweep of the low: the candle traded below the previous low and closed back above it. Bias flips to bullish, the previous high becomes the target.
• Double purge: both sides were taken in the same candle. Bias is decided by the candle direction (bullish close = bullish bias) and the sweep is labeled D-Purge.

From that point the model is Active. It becomes Success when price reaches the target side of the previous range and Invalidated when price breaks back through the swept level. Status is reflected on the range box border and on the HTF candle panel.

MODEL 1 VS MODEL 2

Model 1 is the faster version. The sweep is detected in real time on the chart timeframe, not only at HTF close. As soon as price breaches the previous high or low and closes back inside, the sweep line, the target line and an order block line are drawn. The order block is the low of the candle that set the swept high (or the high of the candle that set the swept low). If price later trades through the sweep level, everything is cleared and the model resets.

Model 2 is the confirmation version. After the sweep candle closes, the script looks back through the consecutive same-direction candles that built the manipulation leg and stores the opening price of that series. A CISD (change in state of delivery) prints when a chart timeframe candle closes through that level. The sweep candle is labeled C1 and the CISD candle is labeled C3, matching the classic three candle CRT structure.

A bias filter lets you run the model long only, short only, or neutral.

TIMEFRAME PAIRING

Auto mode picks the HTF from the chart timeframe: 1m to 15m, 3m to 30m, 5m to 1H, 15m to 4H, 1H to 1D, 4H to 1W, 1D to 1M. Presets are available for 1H-1D, 4H-1W, 1D-1M and 1W-3M, and a custom HTF can be set for anything else. The script validates that the HTF is higher than the chart timeframe and stays idle otherwise.

HTF CANDLE PANEL

On the right side of the chart the script draws the last few HTF candles as mini candles with wicks. Above them sits the HTF label with a live countdown to the next close, below them the current model bias. Sweeps between panel candles are marked with a small line and a sweep label, and the candle borders change color with the model status (neutral while active, bull color on success, bear color on invalidation). Offset, spacing, width and candle count are adjustable.

HTF FAIR VALUE GAPS

Fair value gaps are detected on a higher timeframe, either automatically chosen from the chart timeframe or set manually. Each gap is drawn as a box that starts at the close of the first candle of the three candle pattern, which is where the imbalance actually forms, and extends to the right with an optional midline and a label showing the HTF. A gap is removed once the HTF candle closes through it. You can cap how many gaps stay on the chart.

HTF LEVELS

Previous day, week, month, quarter and year highs and lows, with the previous open as an optional third line. Lines start at the bar where the level was formed and stop exactly where price first touches them, so a mitigated level is still visible but no longer projected forward. Labels use the PDH / PDL / PWH / PWL convention. Line style, width and label size are shared across all timeframes.

SMT DIVERGENCE

The script compares the chart symbol with a correlated instrument and flags divergence in two ways: at HTF close (one symbol made a higher high while the other did not, with a matching candle direction) and on chart timeframe pivots (a new higher high on the chart while the paired symbol printed a lower high, or the mirror for lows). Divergence is drawn as a line between the two swing points with the pair name as a label. Auto pairing covers index futures (NQ, ES, YM, RTY and their micros), CFD indices, major and cross forex pairs, currency futures, gold, silver, oil products and BTC/ETH. A manual pair can be set for anything else. Optionally only the latest bullish and bearish SMT are kept.

MOVING AVERAGES

Five configurable moving averages (SMA, EMA, RMA, WMA, HMA, VWMA), each with its own length and timeframe. Lines are hidden by default and can be toggled with one switch. When enabled, all lines automatically hide once the chart timeframe is higher than the highest MA timeframe in use, so a 15m EMA never gets drawn on a daily chart. The dashboard trend rows keep reading the first three MAs whether the lines are visible or not.

DASHBOARD

A small table showing the chart and HTF pairing, the active model and bias filter, the current bias, an aggregated MA trend (bullish, bearish or mixed) with per-MA arrows, the SMT pair in use and the date. Position and text size are configurable.

COLOR SCHEMES

Seven schemes, each defining the bull, bear, neutral, text and accent colors that every element on the chart uses:

• Vault Dark: teal and rose on a dark background, the default
• Light: near black text and lines with blue and red accents, made for white charts
• Midnight: blue and pink
• Neon: bright green and magenta
• Ember: orange and red
• Mono: greyscale
• Custom: set all five colors yourself

Box transparency is controlled with a single slider.

ALERTS

• Model formed: a new HTF candle closed and the model state was evaluated
• Sweep: a sweep of the previous high or low was detected
• Double purge: both sides of the previous range were taken
• Model success: the target was reached
• Model invalidated: the sweep level was broken

NOTES

The model logic does not repaint. HTF data is requested without lookahead and the Model 1 real time sweep is confirmed on candle close. Drawings such as the panel, the labels and the level extensions are repositioned on the last bar for display only.

The script is a context and structure tool. It does not generate trade signals and nothing in it should be treated as financial advice.

---

## Source Code

````pine
//@version=6
indicator("CRT Engine [vault]", shorttitle = "CRT [vault]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000)

// ─────────────────────────────────────────────────────────────────────────────
//  THEME
// ─────────────────────────────────────────────────────────────────────────────
G_THEME = "Theme"
themeSel   = input.string("Vault Dark", "Color Scheme", options = ["Vault Dark", "Light", "Midnight", "Neon", "Ember", "Mono", "Custom"], group = G_THEME)
c_bull_in  = input.color(#2dd4bf, "Bull", inline = "t1", group = G_THEME)
c_bear_in  = input.color(#f43f5e, "Bear", inline = "t1", group = G_THEME)
c_neut_in  = input.color(#7c8394, "Neutral", inline = "t2", group = G_THEME)
c_text_in  = input.color(#e5e7eb, "Text", inline = "t2", group = G_THEME)
c_acc_in   = input.color(#fbbf24, "Accent", inline = "t3", group = G_THEME, tooltip = "Custom colors are only used when Color Scheme = Custom")
boxAlpha   = input.int(88, "Box Transparency", minval = 50, maxval = 98, group = G_THEME)

f_theme(string t) =>
    color b = na
    color s = na
    color n = na
    color tx = na
    color ac = na
    color pn = #0b0e14
    switch t
        "Vault Dark" =>
            b := #2dd4bf
            s := #f43f5e
            n := #7c8394
            tx := #e5e7eb
            ac := #fbbf24
        "Light" =>
            b := #2962ff
            s := #f23645
            n := #787b86
            tx := #131722
            ac := #ff6d00
            pn := #ffffff
        "Midnight" =>
            b := #60a5fa
            s := #f472b6
            n := #64748b
            tx := #dbeafe
            ac := #a78bfa
        "Neon" =>
            b := #39ff14
            s := #ff2079
            n := #6b7280
            tx := #f5f5f5
            ac := #00e5ff
        "Ember" =>
            b := #fb923c
            s := #ef4444
            n := #78716c
            tx := #fafaf9
            ac := #fde047
        "Mono" =>
            b := #f5f5f5
            s := #9ca3af
            n := #4b5563
            tx := #e5e5e5
            ac := #d4d4d4
        =>
            b := c_bull_in
            s := c_bear_in
            n := c_neut_in
            tx := c_text_in
            ac := c_acc_in
    [b, s, n, tx, ac, pn]

[C_BULL, C_BEAR, C_NEUT, C_TEXT, C_ACC, C_PANEL] = f_theme(themeSel)
C_NONE  = color.new(color.white, 100)
C_MUTED = color.new(C_TEXT, 45)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS - HTF LEVELS
// ─────────────────────────────────────────────────────────────────────────────
G_LVL = "HTF Levels"
lv_d  = input.bool(true,  "Day      ", inline = "l1", group = G_LVL)
lv_w  = input.bool(false, "Week     ", inline = "l1", group = G_LVL)
lv_m  = input.bool(false, "Month    ", inline = "l1", group = G_LVL)
lv_q  = input.bool(false, "Quarter  ", inline = "l2", group = G_LVL)
lv_y  = input.bool(false, "Year     ", inline = "l2", group = G_LVL)
lv_open = input.bool(false, "Open line", inline = "l2", group = G_LVL)
lv_lblSize = input.string("Small", "Label", options = ["Hide", "Tiny", "Small", "Normal", "Large"], inline = "l3", group = G_LVL)
lv_style   = input.string("····", "Style", options = ["⎯⎯⎯", "----", "····"], inline = "l3", group = G_LVL)
lv_width   = input.int(1, "Width", minval = 1, maxval = 4, inline = "l3", group = G_LVL)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS - HTF FVG
// ─────────────────────────────────────────────────────────────────────────────
G_FVG = "HTF FVG"
fvg_auto   = input.bool(true, "Auto HTF", inline = "f1", group = G_FVG)
fvg_manual = input.timeframe("D", "Manual", inline = "f1", group = G_FVG)
fvg_bull   = input.bool(true, "Bullish ", inline = "f2", group = G_FVG)
fvg_bear   = input.bool(true, "Bearish ", inline = "f2", group = G_FVG)
fvg_mid    = input.bool(true, "Midline ", inline = "f2", group = G_FVG)
fvg_labels = input.bool(true, "Labels", inline = "f3", group = G_FVG)
fvg_lblSize = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "f3", group = G_FVG)
fvg_max    = input.int(2, "Max FVGs kept", minval = 1, maxval = 50, group = G_FVG)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS - CRT MODEL
// ─────────────────────────────────────────────────────────────────────────────
G_CRT = "CRT Model"
modelMode   = input.string("Model 1", "Mode", options = ["Model 1", "Model 2"], inline = "m1", group = G_CRT, tooltip = "Model 1 = sweep + order block, Model 2 = sweep + C1/C3 + CISD")
biasFilter  = input.string("Neutral", "Bias", options = ["Neutral", "Bullish", "Bearish"], inline = "m1", group = G_CRT)
tf_preset   = input.string("Auto", "Pairing", options = ["Auto", "1H - 1D", "4H - 1W", "1D - 1M", "1W - 3M", "Custom"], inline = "m2", group = G_CRT)
custom_htf  = input.timeframe("1W", "Custom", inline = "m2", group = G_CRT)
histLook    = input.int(2, "History", minval = 1, maxval = 100, inline = "m3", group = G_CRT)
maxPanel    = input.int(4, "Panel candles", minval = 1, maxval = 30, inline = "m3", group = G_CRT)

show_boxes  = input.bool(false, "CRT boxes", inline = "b1", group = G_CRT)
box_by_bias = input.bool(true,  "Color by bias", inline = "b1", group = G_CRT)
show_sep    = input.bool(true,  "Separators", inline = "b1", group = G_CRT)
show_sweep  = input.bool(true,  "Sweep lines", inline = "b2", group = G_CRT)
show_dpurge = input.bool(true,  "D-Purge", inline = "b2", group = G_CRT)
show_lbls   = input.bool(true,  "Labels", inline = "b2", group = G_CRT)
lblSize     = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = G_CRT)

G_OB = "Order Block (Model 1)"
show_ob     = input.bool(true, "Show OB after sweep", group = G_OB)
ob_max      = input.int(1, "Max OB lines", minval = 1, maxval = 20, inline = "o1", group = G_OB)
ob_extend   = input.int(8, "Extend", minval = 1, maxval = 100, inline = "o1", group = G_OB)

G_CISD = "CISD (Model 2)"
show_cisd   = input.bool(true, "Show CISD", group = G_CISD)
cisd_look   = input.int(50, "Series lookback", minval = 5, maxval = 300, group = G_CISD)
show_model_lbls = input.bool(true, "C1 / C3 labels", group = G_CISD)

G_PANEL = "HTF Candle Panel"
show_panel  = input.bool(true, "Show panel", inline = "p1", group = G_PANEL)
show_bigTF  = input.bool(true, "TF + countdown", inline = "p1", group = G_PANEL)
show_biasTx = input.bool(true, "Bias text", inline = "p1", group = G_PANEL)
panel_off   = input.int(15, "Offset", minval = 1, inline = "p2", group = G_PANEL)
panel_gap   = input.int(1, "Gap", minval = 1, maxval = 4, inline = "p2", group = G_PANEL)
panel_w     = input.int(1, "Width", minval = 1, maxval = 4, inline = "p2", group = G_PANEL) * 2
sync_panel  = input.bool(true, "Sync borders with model status", group = G_PANEL)

G_SMT = "SMT"
smt_on     = input.bool(true, "Enable SMT", inline = "s1", group = G_SMT)
smt_auto   = input.bool(true, "Auto pair", inline = "s1", group = G_SMT)
smt_manual = input.symbol("", "Manual pair", group = G_SMT)
smt_latest = input.bool(true, "Keep only latest", group = G_SMT)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS - MOVING AVERAGES
// ─────────────────────────────────────────────────────────────────────────────
G_MA = "Moving Averages"
ma_master = input.bool(false, "Show MA lines", group = G_MA, tooltip = "Lines auto-hide once chart TF is above the highest MA TF. Dashboard trend keeps working.")
ma1_on = input.bool(true,  "MA 1", inline = "a1", group = G_MA)
ma1_t  = input.string("EMA", "", options = ["SMA", "EMA", "RMA", "WMA", "HMA", "VWMA"], inline = "a1", group = G_MA)
ma1_l  = input.int(50, "", minval = 1, inline = "a1", group = G_MA)
ma1_tf = input.timeframe("15", "", inline = "a1", group = G_MA)
ma2_on = input.bool(true,  "MA 2", inline = "a2", group = G_MA)
ma2_t  = input.string("SMA", "", options = ["SMA", "EMA", "RMA", "WMA", "HMA", "VWMA"], inline = "a2", group = G_MA)
ma2_l  = input.int(50, "", minval = 1, inline = "a2", group = G_MA)
ma2_tf = input.timeframe("30", "", inline = "a2", group = G_MA)
ma3_on = input.bool(true,  "MA 3", inline = "a3", group = G_MA)
ma3_t  = input.string("SMA", "", options = ["SMA", "EMA", "RMA", "WMA", "HMA", "VWMA"], inline = "a3", group = G_MA)
ma3_l  = input.int(50, "", minval = 1, inline = "a3", group = G_MA)
ma3_tf = input.timeframe("60", "", inline = "a3", group = G_MA)
ma4_on = input.bool(false, "MA 4", inline = "a4", group = G_MA)
ma4_t  = input.string("EMA", "", options = ["SMA", "EMA", "RMA", "WMA", "HMA", "VWMA"], inline = "a4", group = G_MA)
ma4_l  = input.int(200, "", minval = 1, inline = "a4", group = G_MA)
ma4_tf = input.timeframe("", "", inline = "a4", group = G_MA)
ma5_on = input.bool(false, "MA 5", inline = "a5", group = G_MA)
ma5_t  = input.string("EMA", "", options = ["SMA", "EMA", "RMA", "WMA", "HMA", "VWMA"], inline = "a5", group = G_MA)
ma5_l  = input.int(21, "", minval = 1, inline = "a5", group = G_MA)
ma5_tf = input.timeframe("", "", inline = "a5", group = G_MA)

G_DASH = "Dashboard"
show_dash = input.bool(true, "Show", inline = "d1", group = G_DASH)
dash_pos  = input.string("Top Right", "", options = ["Top Right", "Top Center", "Top Left", "Bottom Right", "Bottom Center", "Bottom Left"], inline = "d1", group = G_DASH)
dash_size = input.string("Small", "", options = ["Tiny", "Small", "Normal"], inline = "d1", group = G_DASH)
dash_trend = input.bool(true, "MA trend rows", group = G_DASH)

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_lstyle(string s) =>
    switch s
        "⎯⎯⎯" => line.style_solid
        "----"  => line.style_dashed
        => line.style_dotted

f_pos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        => position.bottom_left

f_tfName(string tf) =>
    s = timeframe.in_seconds(tf)
    s < 60 ? str.tostring(s) + "s" :
      s < 3600 ? str.tostring(s / 60) + "m" :
      s < 86400 ? str.tostring(math.round(s / 3600)) + "H" :
      s < 604800 ? str.tostring(math.round(s / 86400)) + "D" :
      s < 2592000 ? str.tostring(math.round(s / 604800)) + "W" :
      s < 31536000 ? str.tostring(math.round(s / 2592000)) + "M" : str.tostring(math.round(s / 31536000)) + "Y"

f_countdown(string tf) =>
    string txt = "n/a"
    tc = time_close(tf)
    if not na(tc)
        rem = (tc - timenow) / 1000
        if rem > 0
            d = int(rem / 86400)
            h = int((rem % 86400) / 3600)
            m = int((rem % 3600) / 60)
            s = int(rem % 60)
            txt := (d > 0 ? str.tostring(d) + "D " : "") + (d > 0 or h > 0 ? str.tostring(h, "00") + ":" : "") + str.tostring(m, "00") + ":" + str.tostring(s, "00")
    txt

f_lbl(int x, float y, string txt, string style, color col, string sz, bool byTime = false) =>
    label.new(x, y, txt, xloc = byTime ? xloc.bar_time : xloc.bar_index, color = C_NONE, textcolor = col, style = style, size = sz, text_font_family = font.family_monospace)

f_isBullCandle(float c, float o, float h, float l) =>
    c == o ? math.abs(o - h) < math.abs(o - l) : c > o

// ─────────────────────────────────────────────────────────────────────────────
//  TYPES
// ─────────────────────────────────────────────────────────────────────────────
type HTFBar
    float o
    float c
    float h
    float l
    int ot
    int ct
    int ht
    int lt
    int hTouch = na
    int lTouch = na
    int oTouch = na

type FVG
    box   bx
    line mid
    label lb
    float top
    float bot
    bool  bull

type PanelCandle
    float o
    float c
    float h
    float l
    int   idx
    box   body
    line wUp
    line wDn
    label sweepLb

type CRTModel
    box   rangeBox
    line sep
    line  sweepLn
    label sweepLb
    line targetLn
    label targetLb
    line  cisdLn
    label cisdLb
    label c1Lb
    label c3Lb
    string bias = "Neutral"
    string status = "Formation"
    float h = na
    float l = na
    float o = na
    float c = na
    int  startBar = na
    int endBar = na
    int hBar = na
    int lBar = na
    float manipOpen = na
    int manipBar = na
    bool sweptHigh = false
    bool sweptLow = false
    bool dpurge = false
    bool cisdDone = false

type RTState
    bool  highBreached = false
    bool lowBreached = false
    bool  sweptHigh = false
    bool sweptLow = false
    float sweepHighLvl = na
    float sweepLowLvl = na
    line  obLn = na
    label obLb = na

type SMT
    string kind
    string pair
    float p1
    float p2
    int   t1
    int t2
    int   bar
    line  ln

// ─────────────────────────────────────────────────────────────────────────────
//  HTF LEVELS
// ─────────────────────────────────────────────────────────────────────────────
var line[]  lvlLines  = array.new<line>()
var label[] lvlLabels = array.new<label>()

f_trackHTF(HTFBar[] bars, string tf) =>
    if ta.change(time(tf)) != 0 or bars.size() == 0
        bars.unshift(HTFBar.new(open, close, high, low, time, time, time, time))
        if bars.size() > 2
            bars.pop()
    else
        b = bars.first()
        b.c := close
        b.ct := time
        if high > b.h
            b.h := high
            b.ht := time
        if low < b.l
            b.l := low
            b.lt := time
    if bars.size() == 2
        p = bars.get(1)
        if na(p.hTouch) and high >= p.h
            p.hTouch := time
        if na(p.lTouch) and low <= p.l
            p.lTouch := time
        if na(p.oTouch) and low <= p.o and high >= p.o
            p.oTouch := time
    bars

f_lvlLine(int x1, int x2, float y, string tag, string tfTag, color col, bool touched) =>
    lvlLines.push(line.new(x1, y, x2, y, xloc = xloc.bar_time, color = col, style = f_lstyle(lv_style), width = lv_width))
    if lv_lblSize != "Hide"
        int lx = touched ? x2 - timeframe.in_seconds() * 3000 : x2
        lvlLabels.push(f_lbl(lx, y, "P" + tfTag + tag, touched ? label.style_label_up : label.style_label_left, col, f_size(lv_lblSize), true))

f_drawLevels(HTFBar[] bars, string tfTag) =>
    if bars.size() == 2
        p = bars.get(1)
        ext = time + timeframe.in_seconds() * 2000
        f_lvlLine(p.ht, na(p.hTouch) ? ext : p.hTouch, p.h, "H", tfTag, C_MUTED, not na(p.hTouch))
        f_lvlLine(p.lt, na(p.lTouch) ? ext : p.lTouch, p.l, "L", tfTag, C_MUTED, not na(p.lTouch))
        if lv_open
            f_lvlLine(p.ot, na(p.oTouch) ? ext : p.oTouch, p.o, "O", tfTag, C_ACC, not na(p.oTouch))

for ln in lvlLines
    ln.delete()
for lb in lvlLabels
    lb.delete()
lvlLines.clear()
lvlLabels.clear()

var HTFBar[] barsD = array.new<HTFBar>()
var HTFBar[] barsW = array.new<HTFBar>()
var HTFBar[] barsM = array.new<HTFBar>()
var HTFBar[] barsQ = array.new<HTFBar>()
var HTFBar[] barsY = array.new<HTFBar>()
if lv_d
    f_trackHTF(barsD, "D")
    f_drawLevels(barsD, "D")
if lv_w
    f_trackHTF(barsW, "W")
    if barstate.islast
        f_drawLevels(barsW, "W")
if lv_m
    f_trackHTF(barsM, "M")
    if barstate.islast
        f_drawLevels(barsM, "M")
if lv_q
    f_trackHTF(barsQ, "3M")
    if barstate.islast
        f_drawLevels(barsQ, "Q")
if lv_y
    f_trackHTF(barsY, "12M")
    if barstate.islast
        f_drawLevels(barsY, "Y")

// ─────────────────────────────────────────────────────────────────────────────
//  HTF FVG  (box starts at the close of the first HTF candle of the pattern)
// ─────────────────────────────────────────────────────────────────────────────
f_autoFvgTF() =>
    s = timeframe.in_seconds()
    s <= 60 ? "15" : s <= 300 ? "60" : s <= 900 ? "240" : s <= 3600 ? "D" : s <= 14400 ? "W" : s <= 86400 ? "15D" : "M"

f_fvgScan() =>
    bearGap = high < low[2]
    bullGap = low > high[2]
    [bearGap, bullGap, high, low[2], high[2], low, time_close[2]]

fvgTF = fvg_auto ? f_autoFvgTF() : fvg_manual
fvgNew = ta.change(time(fvgTF)) != 0
[hBear, hBull, bearBot, bearTop, bullBot, bullTop, hClose2] = request.security(syminfo.tickerid, fvgTF, f_fvgScan(), lookahead = barmerge.lookahead_off)
htfClose = request.security(syminfo.tickerid, fvgTF, close, lookahead = barmerge.lookahead_off)

var FVG[] fvgs = array.new<FVG>()

f_fvgExists(float top, float bot, bool bull) =>
    bool r = false
    for f in fvgs
        if f.bull == bull and f.top == top and f.bot == bot
            r := true
            break
    r

f_fvgDelete(FVG f) =>
    box.delete(f.bx)
    line.delete(f.mid)
    label.delete(f.lb)

f_fvgAdd(float top, float bot, bool bull) =>
    if not f_fvgExists(top, bot, bull)
        int x1 = na(hClose2) ? time : math.min(hClose2, time)
        color base = bull ? C_BULL : C_BEAR
        float midP = (top + bot) / 2
        FVG f = FVG.new(bull = bull, top = top, bot = bot)
        f.bx := box.new(x1, top, time, bot, xloc = xloc.bar_time, bgcolor = color.new(base, boxAlpha), border_color = C_NONE)
        if fvg_mid
            f.mid := line.new(x1, midP, time, midP, xloc = xloc.bar_time, color = color.new(base, 40), style = line.style_dotted)
        if fvg_labels
            f.lb := f_lbl(time, midP, (bull ? "FVG+ " : "FVG- ") + f_tfName(fvgTF), label.style_label_right, C_MUTED, f_size(fvg_lblSize), true)
        fvgs.push(f)

if fvgNew
    if fvg_bear and hBear and not na(bearTop)
        f_fvgAdd(bearTop, bearBot, false)
    if fvg_bull and hBull and not na(bullTop)
        f_fvgAdd(bullTop, bullBot, true)

    if fvgs.size() > 0
        for i = fvgs.size() - 1 to 0
            FVG f = fvgs.get(i)
            if f.bull ? htfClose < f.bot : htfClose > f.top
                f_fvgDelete(f)
                fvgs.remove(i)

while fvgs.size() > fvg_max
    f_fvgDelete(fvgs.shift())

for f in fvgs
    box.set_right(f.bx, time)
    if not na(f.mid)
        line.set_x2(f.mid, time)
    if not na(f.lb)
        label.set_x(f.lb, time)

// ─────────────────────────────────────────────────────────────────────────────
//  CRT - TIMEFRAME
// ─────────────────────────────────────────────────────────────────────────────
f_autoCrtTF() =>
    s = timeframe.in_seconds()
    s <= 60 ? "15" : s <= 180 ? "30" : s <= 300 ? "60" : s <= 900 ? "240" : s <= 3600 ? "D" : s <= 28800 ? "W" : s <= 86400 ? "M" : "W"

htf = tf_preset == "Auto" ? f_autoCrtTF() :
      tf_preset == "1H - 1D" ? "D" : tf_preset == "4H - 1W" ? "W" :
      tf_preset == "1D - 1M" ? "M" : tf_preset == "1W - 3M" ? "3M" : custom_htf

validTF  = timeframe.in_seconds(htf) > timeframe.in_seconds()
isNewHTF = ta.change(time(htf)) != 0

// ─────────────────────────────────────────────────────────────────────────────
//  CRT - PANEL (mini HTF candles on the right)
// ─────────────────────────────────────────────────────────────────────────────
var PanelCandle[] panel = array.new<PanelCandle>()
var line[] panelSweeps  = array.new<line>()
var label tfLabel   = na
var label biasLabel = na

f_panelDelete(PanelCandle p) =>
    box.delete(p.body)
    line.delete(p.wUp)
    line.delete(p.wDn)
    label.delete(p.sweepLb)

f_panelUpdate() =>
    if isNewHTF
        PanelCandle p = PanelCandle.new(open, close, high, low, bar_index)
        bull = close > open
        col  = bull ? C_BULL : C_BEAR
        p.body := box.new(bar_index, math.max(open, close), bar_index + 2, math.min(open, close), border_color = col, bgcolor = color.new(col, bull ? 20 : 0))
        p.wUp  := line.new(bar_index, high, bar_index, math.max(open, close), color = col)
        p.wDn  := line.new(bar_index, math.min(open, close), bar_index, low, color = col)
        panel.unshift(p)
        if panel.size() > maxPanel
            f_panelDelete(panel.pop())
    if panel.size() > 0
        PanelCandle p = panel.first()
        p.h := math.max(high, p.h)
        p.l := math.min(low, p.l)
        p.c := close
        bull = p.c > p.o
        col  = bull ? C_BULL : C_BEAR
        box.set_top(p.body, math.max(p.o, p.c))
        box.set_bottom(p.body, math.min(p.o, p.c))
        box.set_bgcolor(p.body, color.new(col, bull ? 20 : 0))
        line.set_y1(p.wUp, p.h)
        line.set_y2(p.wUp, math.max(p.o, p.c))
        line.set_y1(p.wDn, p.l)
        line.set_y2(p.wDn, math.min(p.o, p.c))

f_panelReorder() =>
    n = panel.size()
    for i = 0 to math.max(n - 1, 0)
        if n == 0
            break
        PanelCandle p = panel.get(i)
        posX = bar_index + panel_off + (panel_w + panel_gap) * (n - i - 1)
        midX = posX + panel_w / 2
        box.set_left(p.body, posX)
        box.set_right(p.body, posX + panel_w)
        line.set_x1(p.wUp, midX)
        line.set_x2(p.wUp, midX)
        line.set_x1(p.wDn, midX)
        line.set_x2(p.wDn, midX)
        if not na(p.sweepLb)
            label.set_x(p.sweepLb, midX)
    for ln in panelSweeps
        ln.delete()
    panelSweeps.clear()
    if n > 1
        for i = 0 to n - 2
            PanelCandle cur = panel.get(i)
            PanelCandle prv = panel.get(i + 1)
            pl = box.get_left(prv.body) + panel_w / 2
            cr = box.get_right(cur.body)
            if cur.h > prv.h and cur.c < prv.h
                panelSweeps.push(line.new(pl, prv.h, cr, prv.h, color = color.new(C_BEAR, 30)))
            if cur.l < prv.l and cur.c > prv.l
                panelSweeps.push(line.new(pl, prv.l, cr, prv.l, color = color.new(C_BULL, 30)))

f_panelSync(int startBar, color borderCol, bool isSweep, bool isHigh) =>
    for p in panel
        if p.idx == startBar
            box.set_border_color(p.body, borderCol)
            label.delete(p.sweepLb)
            p.sweepLb := na
            if isSweep and show_lbls
                midX = int(box.get_left(p.body) + panel_w / 2)
                p.sweepLb := f_lbl(midX, isHigh ? p.h : p.l, "sweep", isHigh ? label.style_label_down : label.style_label_up, isHigh ? C_BEAR : C_BULL, size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
//  CRT - MODEL LOGIC
// ─────────────────────────────────────────────────────────────────────────────
var CRTModel cur  = CRTModel.new()
var CRTModel prev = CRTModel.new()
var CRTModel[] history = array.new<CRTModel>()
var RTState rt = RTState.new()
var line[]  obLines  = array.new<line>()
var label[] obLabels = array.new<label>()
var string globalBias = "Neutral"

bool aFormed = false
bool aSuccess = false
bool aInvalid = false
bool aSweep = false
bool aDpurge = false

f_modelDelete(CRTModel m) =>
    box.delete(m.rangeBox)
    line.delete(m.sep)
    line.delete(m.sweepLn)
    label.delete(m.sweepLb)
    line.delete(m.targetLn)
    label.delete(m.targetLb)
    line.delete(m.cisdLn)
    label.delete(m.cisdLb)
    label.delete(m.c1Lb)
    label.delete(m.c3Lb)

f_modelClearSweep(CRTModel m) =>
    line.delete(m.sweepLn)
    label.delete(m.sweepLb)
    line.delete(m.targetLn)
    label.delete(m.targetLb)
    m.sweepLn := na
    m.sweepLb := na
    m.targetLn := na
    m.targetLb := na

f_obClear() =>
    for ln in obLines
        ln.delete()
    for lb in obLabels
        lb.delete()
    obLines.clear()
    obLabels.clear()
    line.delete(rt.obLn)
    label.delete(rt.obLb)
    rt.obLn := na
    rt.obLb := na

f_obDraw(bool bull, float lvl, int startBar) =>
    col = bull ? C_BULL : C_BEAR
    endBar = bar_index + ob_extend
    ln = line.new(startBar, lvl, endBar, lvl, color = col, width = 1)
    lb = f_lbl(endBar, lvl, bull ? "OB ▲" : "OB ▼", label.style_label_left, col, f_size(lblSize))
    [ln, lb]

f_obPush(bool bull, float lvl, int startBar) =>
    [ln, lb] = f_obDraw(bull, lvl, startBar)
    obLines.push(ln)
    obLabels.push(lb)
    if obLines.size() > ob_max
        line.delete(obLines.shift())
        label.delete(obLabels.shift())

f_sweepDraw(CRTModel m, bool isHigh, int x2, bool dp) =>
    col = dp ? C_ACC : isHigh ? C_BEAR : C_BULL
    float sLvl = isHigh ? prev.h : prev.l
    float tLvl = isHigh ? prev.l : prev.h
    int   sBar = isHigh ? prev.hBar : prev.lBar
    int tBar = isHigh ? prev.lBar : prev.hBar
    m.sweepLn  := line.new(sBar, sLvl, x2, sLvl, color = col)
    m.targetLn := line.new(tBar, tLvl, x2, tLvl, color = col)
    if show_lbls
        m.sweepLb  := f_lbl(x2, sLvl, dp and show_dpurge ? "D-Purge" : isHigh ? "CRT H" : "CRT L", isHigh ? label.style_label_down : label.style_label_up, col, f_size(lblSize))
        m.targetLb := f_lbl(x2, tLvl, isHigh ? "CRT L" : "CRT H", isHigh ? label.style_label_up : label.style_label_down, col, f_size(lblSize))

// invalidation of a live sweep in one place instead of two copy-pasted blocks
f_rtInvalidate(bool isHigh) =>
    f_modelClearSweep(cur)
    f_modelClearSweep(prev)
    f_obClear()
    if isHigh
        rt.sweptHigh := false
        rt.highBreached := false
        rt.sweepHighLvl := na
        cur.sweptHigh := false
        prev.sweptHigh := false
    else
        rt.sweptLow := false
        rt.lowBreached := false
        rt.sweepLowLvl := na
        cur.sweptLow := false
        prev.sweptLow := false

f_cisdLevel(int extremeBar, bool wasHigh) =>
    off0 = bar_index - extremeBar
    float bHi = math.max(open[off0], close[off0])
    float bLo = math.min(open[off0], close[off0])
    int origin = extremeBar
    for i = 1 to cisd_look
        off = off0 + i
        if off > bar_index
            break
        bullI = close[off] > open[off]
        if wasHigh ? bullI : not bullI
            bHi := math.max(bHi, math.max(open[off], close[off]))
            bLo := math.min(bLo, math.min(open[off], close[off]))
            origin := bar_index - off
        else
            break
    [wasHigh ? bLo : bHi, origin]

f_newModel() =>
    CRTModel m = CRTModel.new(o = open, h = high, l = low, c = close, startBar = bar_index, endBar = bar_index, hBar = bar_index, lBar = bar_index)
    m.rangeBox := box.new(bar_index, high, bar_index, low, border_color = C_NONE, bgcolor = show_boxes ? color.new(C_NEUT, boxAlpha) : C_NONE)
    if show_sep and not show_boxes
        m.sep := line.new(bar_index, low, bar_index, high, color = color.new(C_NEUT, 55), extend = extend.both)
    m

if validTF
    if isNewHTF
        // close the model that just finished
        f_modelClearSweep(cur)
        f_obClear()
        rt := RTState.new()

        if not na(cur.rangeBox)
            cur.endBar := bar_index - 1
            box.set_right(cur.rangeBox, cur.endBar)

            if not na(prev.rangeBox)
                cur.sweptHigh := cur.h > prev.h and cur.c < prev.h and biasFilter != "Bullish"
                cur.sweptLow  := cur.l < prev.l and cur.c > prev.l and biasFilter != "Bearish"
                cur.dpurge    := cur.sweptHigh and cur.sweptLow
                cur.bias      := cur.dpurge ? (cur.c > cur.o ? "Bullish" : "Bearish") : cur.sweptHigh ? "Bearish" : cur.sweptLow ? "Bullish" : "Neutral"
                swept          = cur.sweptHigh or cur.sweptLow
                cur.status    := swept ? "Active" : "Formation"
                globalBias    := cur.bias

                color fill = cur.bias == "Bullish" ? C_BULL : cur.bias == "Bearish" ? C_BEAR : C_NEUT
                if show_boxes
                    box.set_bgcolor(cur.rangeBox, color.new(box_by_bias ? fill : C_NEUT, boxAlpha))
                    box.set_border_color(cur.rangeBox, swept ? color.new(C_NEUT, 40) : C_NONE)

                if swept
                    [lvl, oBar] = f_cisdLevel(cur.sweptHigh ? cur.hBar : cur.lBar, cur.sweptHigh)
                    cur.manipOpen := lvl
                    cur.manipBar := oBar
                    if show_sweep
                        f_sweepDraw(cur, cur.sweptHigh, cur.endBar, cur.dpurge)
                        aSweep := true
                        aDpurge := cur.dpurge
                    if modelMode == "Model 2" and show_model_lbls
                        cur.c1Lb := f_lbl(cur.sweptHigh ? cur.hBar : cur.lBar, cur.sweptHigh ? cur.h : cur.l, "C1", cur.sweptHigh ? label.style_label_down : label.style_label_up, cur.sweptHigh ? C_BEAR : C_BULL, f_size(lblSize))
                    if modelMode == "Model 1" and show_ob
                        if cur.sweptHigh
                            f_obPush(false, low[bar_index - cur.hBar], cur.hBar)
                        if cur.sweptLow
                            f_obPush(true, high[bar_index - cur.lBar], cur.lBar)

                if sync_panel
                    f_panelSync(cur.startBar, swept ? C_NEUT : (cur.c > cur.o ? C_BULL : C_BEAR), swept, cur.sweptHigh)
                aFormed := true

            history.push(cur)
            prev := cur
            while history.size() > histLook
                f_modelDelete(history.shift())

        cur := f_newModel()

    else
        if high > cur.h
            cur.h := high
            cur.hBar := bar_index
        if low < cur.l
            cur.l := low
            cur.lBar := bar_index
        cur.c := close
        if not na(cur.rangeBox)
            box.set_top(cur.rangeBox, cur.h)
            box.set_bottom(cur.rangeBox, cur.l)
            box.set_right(cur.rangeBox, bar_index)

        // MODEL 1: live sweep detection + OB
        if modelMode == "Model 1" and not na(prev.h)
            bearLvl = na(rt.sweepHighLvl) ? prev.h : rt.sweepHighLvl
            if (rt.sweptHigh or cur.sweptHigh or prev.sweptHigh) and high >= bearLvl
                f_rtInvalidate(true)
            bullLvl = na(rt.sweepLowLvl) ? prev.l : rt.sweepLowLvl
            if (rt.sweptLow or cur.sweptLow or prev.sweptLow) and low <= bullLvl
                f_rtInvalidate(false)

            if high > prev.h and biasFilter != "Bullish"
                rt.highBreached := true
            if low < prev.l and biasFilter != "Bearish"
                rt.lowBreached := true

            if rt.highBreached and not rt.sweptHigh and close < prev.h
                rt.sweptHigh := true
                rt.sweepHighLvl := cur.h
                if show_sweep
                    f_sweepDraw(cur, true, bar_index, false)
                if show_ob
                    line.delete(rt.obLn)
                    label.delete(rt.obLb)
                    [ln, lb] = f_obDraw(false, low[bar_index - cur.hBar], cur.hBar)
                    rt.obLn := ln
                    rt.obLb := lb
                aSweep := true

            if rt.lowBreached and not rt.sweptLow and close > prev.l
                rt.sweptLow := true
                rt.sweepLowLvl := cur.l
                if show_sweep
                    f_sweepDraw(cur, false, bar_index, false)
                if show_ob
                    line.delete(rt.obLn)
                    label.delete(rt.obLb)
                    [ln, lb] = f_obDraw(true, high[bar_index - cur.lBar], cur.lBar)
                    rt.obLn := ln
                    rt.obLb := lb
                aSweep := true

        // MODEL 2: CISD after the sweep candle
        if modelMode == "Model 2" and show_cisd and not cur.cisdDone and not na(prev.manipOpen) and (prev.sweptHigh or prev.sweptLow)
            bool bearCisd = prev.sweptHigh and close < prev.manipOpen
            bool bullCisd = prev.sweptLow and close > prev.manipOpen
            if bearCisd or bullCisd
                col = bearCisd ? C_BEAR : C_BULL
                cur.cisdDone := true
                cur.cisdLn := line.new(prev.manipBar, prev.manipOpen, bar_index, prev.manipOpen, color = col)
                cur.cisdLb := f_lbl(bar_index, prev.manipOpen, bearCisd ? "CISD ▼" : "CISD ▲", label.style_label_left, col, f_size(lblSize))
                if show_model_lbls
                    cur.c3Lb := f_lbl(bar_index, close, "C3", bearCisd ? label.style_label_down : label.style_label_up, col, f_size(lblSize))

        // status of the previous model
        if not na(prev.rangeBox) and prev.status != "Success" and prev.status != "Invalidated"
            bool inval = (prev.bias == "Bearish" and high > prev.h) or (prev.bias == "Bullish" and low < prev.l)
            bool succ  = not inval and ((prev.bias == "Bearish" and low <= prev.l) or (prev.bias == "Bullish" and high >= prev.h))
            if inval or succ
                prev.status := inval ? "Invalidated" : "Success"
                col = inval ? C_BEAR : C_BULL
                aInvalid := inval
                aSuccess := succ
                if show_boxes
                    box.set_border_color(prev.rangeBox, col)
                if sync_panel
                    f_panelSync(prev.startBar, col, false, false)

    if show_panel
        f_panelUpdate()
        if barstate.islast
            f_panelReorder()

// ─────────────────────────────────────────────────────────────────────────────
//  SMT
// ─────────────────────────────────────────────────────────────────────────────
f_smtPair() =>
    t = syminfo.ticker
    if str.contains(t, "MNQ")
        "CME_MINI:MES1!"
    else if str.contains(t, "MES")
        "CME_MINI:MNQ1!"
    else if str.contains(t, "MYM")
        "CME_MINI:MNQ1!"
    else if str.contains(t, "NQ")
        "CME_MINI:ES1!"
    else if str.contains(t, "NDX")
        "CME_MINI:ES1!"
    else if str.contains(t, "QQQ")
        "CME_MINI:ES1!"
    else if str.contains(t, "ES")
        "CME_MINI:NQ1!"
    else if str.contains(t, "SPX")
        "CME_MINI:NQ1!"
    else if str.contains(t, "SPY")
        "CME_MINI:NQ1!"
    else if str.contains(t, "YM")
        "CME_MINI:NQ1!"
    else if str.contains(t, "RTY")
        "CBOT:YM1!"
    else if str.contains(t, "NAS100")
        "SPX500"
    else if str.contains(t, "SPX500")
        "NAS100"
    else if str.contains(t, "US30")
        "NAS100"
    else if str.contains(t, "EURUSD")
        "GBPUSD"
    else if str.contains(t, "GBPUSD")
        "EURUSD"
    else if str.contains(t, "AUDUSD")
        "NZDUSD"
    else if str.contains(t, "NZDUSD")
        "AUDUSD"
    else if str.contains(t, "EURJPY")
        "GBPJPY"
    else if str.contains(t, "GBPJPY")
        "EURJPY"
    else if str.contains(t, "USDJPY")
        "EURJPY"
    else if str.contains(t, "USDCAD")
        "EURCAD"
    else if str.contains(t, "USDCHF")
        "EURCHF"
    else if str.contains(t, "EURCHF")
        "GBPCHF"
    else if str.contains(t, "GBPCHF")
        "EURCHF"
    else if str.contains(t, "EURCAD")
        "GBPCAD"
    else if str.contains(t, "GBPCAD")
        "EURCAD"
    else if str.contains(t, "EURAUD")
        "GBPAUD"
    else if str.contains(t, "GBPAUD")
        "EURAUD"
    else if str.contains(t, "EURNZD")
        "GBPNZD"
    else if str.contains(t, "GBPNZD")
        "EURNZD"
    else if str.contains(t, "6E")
        "CME:6B1!"
    else if str.contains(t, "6B")
        "CME:6E1!"
    else if str.contains(t, "6A")
        "CME:6N1!"
    else if str.contains(t, "6N")
        "CME:6A1!"
    else if str.contains(t, "XAUUSD")
        "XAGUSD"
    else if str.contains(t, "XAGUSD")
        "XAUUSD"
    else if str.contains(t, "GC")
        "XAGUSD"
    else if str.contains(t, "SI")
        "XAUUSD"
    else if str.contains(t, "CL")
        "NYMEX:RB1!"
    else if str.contains(t, "RB")
        "NYMEX:HO1!"
    else if str.contains(t, "HO")
        "NYMEX:CL1!"
    else if str.contains(t, "MBT")
        "CME:MET1!"
    else if str.contains(t, "MET")
        "CME:MBT1!"
    else if str.contains(t, "BTC")
        "ETHUSDT"
    else if str.contains(t, "ETH")
        "BTCUSDT"
    else
        "CME_MINI:ES1!"

f_cleanSym(string s) =>
    string r = s
    if str.contains(r, ":")
        parts = str.split(r, ":")
        r := parts.get(parts.size() - 1)
    str.replace_all(str.replace_all(r, ".P", ""), "1!", "")

var SMT[] smts = array.new<SMT>()
var label[] smtLabels = array.new<label>()
var float pivH = na
var int pivHT = na
var float pivL = na
var int pivLT = na
var float pPivH = na
var int pPivHT = na
var float pPivL = na
var int pPivLT = na
var float sPivH = na
var float sPivL = na
var float pSPivH = na
var float pSPivL = na
var float prevCH = na
var int prevCHT = na
var float curCH = na
var int curCHT = na
var float prevCL = na
var int prevCLT = na
var float curCL = na
var int curCLT = na

smtPair = smt_on ? (smt_auto ? f_smtPair() : str.tostring(smt_manual)) : ""
smtActive = smt_on and validTF and smtPair != "" and bar_index > last_bar_index - 4500

f_smtHTF() =>
    [high, low, high[1], low[1], close, open]

[sH, sL, sH1, sL1, sC, sO] = request.security(smtPair == "" ? syminfo.tickerid : smtPair, htf, f_smtHTF(), lookahead = barmerge.lookahead_off)
[sPH, sPL] = request.security(smtPair == "" ? syminfo.tickerid : smtPair, timeframe.period, [high[3], low[3]], lookahead = barmerge.lookahead_off)
[cH, cL, cH1, cL1, cC, cO] = request.security(syminfo.tickerid, htf, f_smtHTF(), lookahead = barmerge.lookahead_off)

pivDir = not na(ta.pivothigh(3, 3)) ? 1 : not na(ta.pivotlow(3, 3)) ? -1 : 0

if smtActive
    bearD = cC < cO and cH < cH1 and sH > sH1
    bullD = cC > cO and cL > cL1 and sL < sL1

    if na(curCH) or high >= curCH
        curCH := high
        curCHT := time
    if na(curCL) or low <= curCL
        curCL := low
        curCLT := time

    if isNewHTF
        if bearD[1]
            smts.push(SMT.new("BEAR", smtPair, prevCH, curCH, prevCHT, curCHT, bar_index))
        if bullD[1]
            smts.push(SMT.new("BULL", smtPair, prevCL, curCL, prevCLT, curCLT, bar_index))
        prevCH := curCH
        prevCHT := curCHT
        prevCL := curCL
        prevCLT := curCLT
        curCH := high
        curCHT := time
        curCL := low
        curCLT := time

    if pivDir == 1
        pPivH := pivH
        pPivHT := pivHT
        pivH := high[3]
        pivHT := time[3]
        pSPivH := sPivH
        sPivH := sPH
        if not na(pPivH) and pivH > pPivH and sPivH < pSPivH
            smts.push(SMT.new("BEAR", smtPair, pPivH, pivH, pPivHT, pivHT, bar_index))
    if pivDir == -1
        pPivL := pivL
        pPivLT := pivLT
        pivL := low[3]
        pivLT := time[3]
        pSPivL := sPivL
        sPivL := sPL
        if not na(pPivL) and pivL < pPivL and sPivL > pSPivL
            smts.push(SMT.new("BULL", smtPair, pPivL, pivL, pPivLT, pivLT, bar_index))

    if barstate.islast
        if smt_latest and smts.size() > 1
            int lastBear = -1
            int lastBull = -1
            for i = 0 to smts.size() - 1
                s = smts.get(i)
                if s.kind == "BEAR"
                    lastBear := i
                else
                    lastBull := i
            for i = smts.size() - 1 to 0
                if i != lastBear and i != lastBull
                    line.delete(smts.remove(i).ln)

        for lb in smtLabels
            lb.delete()
        smtLabels.clear()

        for i = math.max(smts.size() - 1, 0) to 0
            if smts.size() == 0
                break
            s = smts.get(i)
            if bar_index - s.bar > 2500
                line.delete(smts.remove(i).ln)
                continue
            if na(s.t1) or na(s.t2)
                continue
            if na(s.ln)
                s.ln := line.new(s.t1, s.p1, s.t2, s.p2, xloc = xloc.bar_time, color = C_ACC)
            else
                line.set_xy1(s.ln, s.t1, s.p1)
                line.set_xy2(s.ln, s.t2, s.p2)
            if show_lbls
                smtLabels.push(f_lbl((s.t1 + s.t2) / 2, (s.p1 + s.p2) / 2, "smt " + f_cleanSym(s.pair), s.kind == "BEAR" ? label.style_label_down : label.style_label_up, C_ACC, f_size(lblSize), true))

// ─────────────────────────────────────────────────────────────────────────────
//  PANEL TEXT
// ─────────────────────────────────────────────────────────────────────────────
if validTF and show_panel and barstate.islast
    n = panel.size()
    float hi = na
    float lo = na
    for p in panel
        hi := na(hi) ? p.h : math.max(hi, p.h)
        lo := na(lo) ? p.l : math.min(lo, p.l)
    hi := na(hi) ? high : hi
    lo := na(lo) ? low : lo
    cx = bar_index + panel_off + int((panel_w + panel_gap) * math.max(n - 1, 0) / 2) + panel_w / 2
    biasCol = globalBias == "Bullish" ? C_BULL : globalBias == "Bearish" ? C_BEAR : C_NEUT

    if show_bigTF
        txt = f_tfName(htf) + "\n" + f_countdown(htf)
        if na(tfLabel)
            tfLabel := f_lbl(cx, hi, txt, label.style_label_down, C_TEXT, size.normal)
        else
            label.set_xy(tfLabel, cx, hi)
            label.set_text(tfLabel, txt)
    if show_biasTx
        if na(biasLabel)
            biasLabel := f_lbl(cx, lo, "bias " + str.lower(globalBias), label.style_label_up, biasCol, size.small)
        else
            label.set_xy(biasLabel, cx, lo)
            label.set_text(biasLabel, "bias " + str.lower(globalBias))
            label.set_textcolor(biasLabel, biasCol)

// ─────────────────────────────────────────────────────────────────────────────
//  MOVING AVERAGES
// ─────────────────────────────────────────────────────────────────────────────
f_ma(float src, int len, string t) =>
    switch t
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "RMA"  => ta.rma(src, len)
        "WMA"  => ta.wma(src, len)
        "HMA"  => ta.hma(src, math.max(len, 2))
        => ta.vwma(src, len)

f_maSecs(bool on, string tf) =>
    on and tf != "" ? timeframe.in_seconds(tf) : 0

ma1 = ma1_on ? request.security(syminfo.tickerid, ma1_tf, f_ma(close, ma1_l, ma1_t), lookahead = barmerge.lookahead_off) : na
ma2 = ma2_on ? request.security(syminfo.tickerid, ma2_tf, f_ma(close, ma2_l, ma2_t), lookahead = barmerge.lookahead_off) : na
ma3 = ma3_on ? request.security(syminfo.tickerid, ma3_tf, f_ma(close, ma3_l, ma3_t), lookahead = barmerge.lookahead_off) : na
ma4 = ma4_on ? request.security(syminfo.tickerid, ma4_tf, f_ma(close, ma4_l, ma4_t), lookahead = barmerge.lookahead_off) : na
ma5 = ma5_on ? request.security(syminfo.tickerid, ma5_tf, f_ma(close, ma5_l, ma5_t), lookahead = barmerge.lookahead_off) : na

maxMaSecs = math.max(f_maSecs(ma1_on, ma1_tf), f_maSecs(ma2_on, ma2_tf), f_maSecs(ma3_on, ma3_tf), f_maSecs(ma4_on, ma4_tf), f_maSecs(ma5_on, ma5_tf))
maShow    = ma_master and (maxMaSecs == 0 or timeframe.in_seconds() <= maxMaSecs)

plot(maShow ? ma1 : na, "MA 1", C_ACC, 1)
plot(maShow ? ma2 : na, "MA 2", C_BULL, 1)
plot(maShow ? ma3 : na, "MA 3", C_BEAR, 1)
plot(maShow ? ma4 : na, "MA 4", C_TEXT, 1)
plot(maShow ? ma5 : na, "MA 5", C_NEUT, 1)

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
f_maState(float v) => na(v) ? 0 : close > v ? 1 : close < v ? -1 : 0
f_maArrow(int s)   => s == 1 ? "▲" : s == -1 ? "▼" : "–"
f_maTag(string tf) => tf == "" ? "chart" : f_tfName(tf)

st1 = f_maState(ma1)
st2 = f_maState(ma2)
st3 = f_maState(ma3)
activeMAs = (st1 != 0 ? 1 : 0) + (st2 != 0 ? 1 : 0) + (st3 != 0 ? 1 : 0)
bullMAs   = (st1 == 1 ? 1 : 0) + (st2 == 1 ? 1 : 0) + (st3 == 1 ? 1 : 0)
bearMAs   = (st1 == -1 ? 1 : 0) + (st2 == -1 ? 1 : 0) + (st3 == -1 ? 1 : 0)
maTrend   = activeMAs == 0 ? "n/a" : bullMAs == activeMAs ? "bullish" : bearMAs == activeMAs ? "bearish" : "mixed"
maTrendCol = maTrend == "bullish" ? C_BULL : maTrend == "bearish" ? C_BEAR : C_NEUT

var table dash = table.new(f_pos(dash_pos), 1, 7, bgcolor = C_PANEL, border_width = 1, border_color = color.new(C_TEXT, 85), frame_width = 1, frame_color = color.new(C_TEXT, 70))

f_cell(int r, string txt, color col, string sz, color bg) =>
    table.cell(dash, 0, r, txt, text_size = sz, text_color = col, bgcolor = bg, text_font_family = font.family_monospace)

if show_dash and barstate.islast
    sz = f_size(dash_size)
    biasCol = globalBias == "Bullish" ? C_BULL : globalBias == "Bearish" ? C_BEAR : C_NEUT
    string maRow = ""
    if ma1_on
        maRow += f_maTag(ma1_tf) + " " + f_maArrow(st1)
    if ma2_on
        maRow += (maRow == "" ? "" : "  ") + f_maTag(ma2_tf) + " " + f_maArrow(st2)
    if ma3_on
        maRow += (maRow == "" ? "" : "  ") + f_maTag(ma3_tf) + " " + f_maArrow(st3)
    if maRow == ""
        maRow := "no ma enabled"

    int r = 0
    f_cell(r, "CRT [vault]  " + f_tfName(timeframe.period) + " / " + f_tfName(htf), C_TEXT, sz, color.new(C_ACC, 85))
    r += 1
    f_cell(r, str.lower(modelMode) + "  ·  filter " + str.lower(biasFilter), C_MUTED, sz, C_PANEL)
    r += 1
    f_cell(r, "bias  " + str.lower(globalBias), biasCol, sz, C_PANEL)
    r += 1
    if dash_trend
        f_cell(r, "trend  " + maTrend, maTrendCol, sz, C_PANEL)
        r += 1
        f_cell(r, maRow, C_TEXT, sz, C_PANEL)
        r += 1
    f_cell(r, smtPair == "" ? syminfo.ticker : syminfo.ticker + " / " + f_cleanSym(smtPair), C_MUTED, sz, C_PANEL)
    r += 1
    f_cell(r, str.format("{0,date,d MMM yyyy}", timenow), C_MUTED, sz, C_PANEL)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(aFormed,  "CRT model formed",       "CRT [vault] model formed - {{ticker}} {{interval}}")
alertcondition(aSweep,   "CRT sweep",              "CRT [vault] sweep - {{ticker}} {{interval}}")
alertcondition(aDpurge,  "CRT double purge",       "CRT [vault] double purge - {{ticker}} {{interval}}")
alertcondition(aSuccess, "CRT model success",      "CRT [vault] model hit target - {{ticker}} {{interval}}")
alertcondition(aInvalid, "CRT model invalidated",  "CRT [vault] model invalidated - {{ticker}} {{interval}}")
````
