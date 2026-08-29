<!-- tradingview-pine-id: PUB;752bce0780674ce69e4e70dea9130320 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Heatmap & Sweep Detector

Source: https://www.tradingview.com/script/qU2R6emS-Time-Price-Volume-Heatmap-with-Liquidity-Sweeps/

## Description

What it does

Most volume tools compress everything into a single vertical profile, so you can see at which price volume traded, but not when. This script splits the lookback window into a grid of time columns × price rows and paints each cell by how much volume was actually traded inside it — producing a time-and-price heatmap of where activity concentrated as the market moved.

On top of that map it tracks the resting liquidity pools that price left behind, and flags the exact bar where each pool is taken.

How it is calculated

The heatmap

The lookback window (default 300 bars) is divided into Time Resolution columns (default 16) and Price Resolution rows (default 26), built between the highest high and lowest low of the window.
For every bar, its volume is distributed evenly across all price rows its high-low range covers. A bar spanning 5 rows adds one fifth of its volume to each. This approximates where inside the candle the activity sat, rather than assigning it all to the close.
Each cell is normalised against the busiest cell in the grid and coloured on a 3-stop gradient. Transparency scales with intensity, so cold zones stay faint and hot zones glow. Cells below Min Intensity are not drawn at all — this keeps the chart readable and stays inside the 500-object limit.

Point of Control Rows are summed across all columns; the heaviest row is drawn as the POC line. The panel also shows POC Density — that row's share of total mapped volume. A high number means volume is concentrated on one shelf; a low number means it is spread out.

Liquidity pools Confirmed pivot highs and lows (Pivot Strength, default 8) mark levels where stop orders typically rest. Each is drawn as a dotted line extending right, labelled with its price. When price trades through a level it is re-drawn solid grey and marked SWEPT, and the sweep counter increments. Levels older than Level Max Age are removed automatically.

Volume bursts Volume is converted to a z-score over Volume Window bars. Two dot sizes mark bars above the strong (2σ) and extreme (3.5σ) thresholds — useful for spotting which bar actually did the damage at a level.

Volume Pressure Volume of up-closes minus volume of down-closes across the window, expressed as a percentage of total. A rough directional bias for the mapped period.

How to read it
Hot zones = price spent time and volume there. They tend to act as magnets and as friction; moves through them are usually slower.
Cold gaps = thin areas. Price often travels through them quickly.
A sweep followed by an immediate move back inside the previous range is the classic liquidity-grab pattern. The sweep marker plus an extreme volume dot on the same bar is the strongest version of it.
POC as reference: the panel tells you whether price is above or below the heaviest shelf.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//   L I Q U I D I T Y   H E A T M A P   &   S W E E P   D E T E C T O R
//   Build: HM-1.0   |   Pine Script v6
//
//   A time-and-price volume heatmap for TradingView charts.
//   It maps WHERE volume was actually traded across time and price, then
//   marks the resting liquidity pools above and below price and flags the
//   exact bar where they get swept.
// ══════════════════════════════════════════════════════════════════════════════

indicator(
     title            = "Liquidity Heatmap & Sweep Detector",
     shorttitle       = "LIQ HEATMAP",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 1000,
     calc_bars_count  = 2000)

// ══════════════════════════════════════════════════════════════════════════════
//  GROUPS
// ══════════════════════════════════════════════════════════════════════════════
string G_HM   = "① الخريطة الحرارية · Heatmap"
string G_LIQ  = "② مناطق السيولة · Liquidity Pools"
string G_VOL  = "③ انفجار الحجم · Volume Bursts"
string G_DASH = "④ اللوحة · Dashboard"
string G_VIS  = "⑤ الألوان · Colors"

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
i_showHM   = input.bool(true, "إظهار الخريطة الحرارية · Show Heatmap", group = G_HM)
i_look     = input.int(300, "عدد الشموع · Lookback Bars", minval = 50, maxval = 500, step = 10, group = G_HM)
i_bins     = input.int(26, "دقة السعر · Price Resolution", minval = 10, maxval = 40, group = G_HM, tooltip = "عدد الطبقات السعرية · Number of price rows")
i_cols     = input.int(16, "دقة الوقت · Time Resolution", minval = 4, maxval = 30, group = G_HM, tooltip = "عدد الأعمدة الزمنية · Number of time columns")
i_minInt   = input.float(0.06, "أدنى شدة للعرض · Min Intensity", minval = 0.01, maxval = 0.50, step = 0.01, group = G_HM)
i_transpLo = input.int(93, "شفافية المناطق الباردة · Cold Transparency", minval = 60, maxval = 99, group = G_HM)
i_transpHi = input.int(30, "شفافية المناطق الساخنة · Hot Transparency", minval = 0, maxval = 80, group = G_HM)
i_palette  = input.string("Bookmap", "لوحة الألوان · Palette", options = ["Bookmap", "Inferno", "Ice", "Gold"], group = G_HM)
i_barClose = input.bool(true, "تحديث عند إغلاق الشمعة · Redraw on Bar Close Only", group = G_HM, tooltip = "يخلي الشارت خفيف · Keeps the chart fast")
i_showPOC  = input.bool(true, "خط أعلى تركيز · Show POC Line", group = G_HM)

i_showLiq  = input.bool(true, "إظهار مناطق السيولة · Show Liquidity Pools", group = G_LIQ)
i_pvLen    = input.int(8, "قوة القمة/القاع · Pivot Strength", minval = 2, maxval = 30, group = G_LIQ)
i_maxLiq   = input.int(6, "أقصى عدد لكل جهة · Max Levels per Side", minval = 1, maxval = 15, group = G_LIQ)
i_liqAge   = input.int(250, "عمر المستوى (شمعة) · Level Max Age", minval = 20, maxval = 500, group = G_LIQ)
i_ext      = input.int(12, "تمديد الخط · Extend Bars", minval = 0, maxval = 60, group = G_LIQ)
i_showSwp  = input.bool(true, "تعليم الاجتياح · Mark Sweeps", group = G_LIQ)

i_showVol  = input.bool(true, "إظهار انفجار الحجم · Show Volume Bursts", group = G_VOL)
i_volLen   = input.int(50, "نافذة الحجم · Volume Window", minval = 10, maxval = 300, group = G_VOL)
i_burst1   = input.float(2.0, "عتبة قوية (σ) · Strong Threshold", minval = 0.5, maxval = 6.0, step = 0.1, group = G_VOL)
i_burst2   = input.float(3.5, "عتبة استثنائية (σ) · Extreme Threshold", minval = 1.0, maxval = 10.0, step = 0.1, group = G_VOL)

i_showDash = input.bool(true, "إظهار اللوحة · Show Dashboard", group = G_DASH)
i_lang     = input.string("English", "اللغة · Language", options = ["العربية", "English"], group = G_DASH)
i_dashPos  = input.string("Top Right", "الموضع · Position", options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = G_DASH)
i_dashSize = input.string("small", "حجم الخط · Text Size", options = ["tiny", "small", "normal", "large"], group = G_DASH)
i_signature = input.string("", "التوقيع · Signature", group = G_DASH, tooltip = "نص حر يظهر أسفل اللوحة · Optional free text shown in the panel footer")
i_showWM   = input.bool(false, "العلامة المائية · Watermark", group = G_DASH)

i_colAbove = input.color(#FF5252, "سيولة فوق السعر · Liquidity Above", group = G_VIS)
i_colBelow = input.color(#00E676, "سيولة تحت السعر · Liquidity Below", group = G_VIS)
i_colSwept = input.color(#9E9E9E, "بعد الاجتياح · Swept", group = G_VIS)
i_colPOC   = input.color(#FFEB3B, "لون POC", group = G_VIS)
i_colBurst = input.color(#40E0D0, "لون انفجار الحجم · Burst", group = G_VIS)

// ══════════════════════════════════════════════════════════════════════════════
//  THEME
// ══════════════════════════════════════════════════════════════════════════════
bool isDark = color.r(chart.bg_color) < 128

color C_TXT   = isDark ? color.rgb(226, 226, 226) : color.rgb(26, 26, 26)
color C_MUTED = isDark ? color.rgb(148, 148, 148) : color.rgb(108, 108, 108)
color C_PANEL = isDark ? color.new(color.rgb(10, 13, 20), 6) : color.new(color.rgb(255, 255, 255), 6)
color C_FRAME = isDark ? color.new(color.rgb(120, 92, 20), 20) : color.new(color.rgb(190, 190, 190), 20)
color C_ROW_A = isDark ? color.new(color.rgb(16, 20, 28), 8) : color.new(color.rgb(246, 248, 252), 8)
color C_ROW_B = isDark ? color.new(color.rgb(23, 28, 38), 8) : color.new(color.rgb(234, 238, 245), 8)
color C_HDRBG = color.new(color.rgb(140, 100, 8), 0)
color C_HDRTX = color.rgb(255, 228, 150)
color C_GOLD  = color.rgb(255, 196, 60)

// Heatmap palette stops
color HM_LO = switch i_palette
    "Bookmap" => color.rgb(6, 18, 70)
    "Inferno" => color.rgb(20, 0, 35)
    "Ice"     => color.rgb(0, 20, 45)
    =>           color.rgb(28, 18, 0)

color HM_MID = switch i_palette
    "Bookmap" => color.rgb(0, 190, 190)
    "Inferno" => color.rgb(190, 40, 60)
    "Ice"     => color.rgb(0, 150, 220)
    =>           color.rgb(200, 140, 10)

color HM_HI = switch i_palette
    "Bookmap" => color.rgb(255, 235, 60)
    "Inferno" => color.rgb(255, 190, 40)
    "Ice"     => color.rgb(190, 240, 255)
    =>           color.rgb(255, 240, 170)

// ══════════════════════════════════════════════════════════════════════════════
//  TYPES
// ══════════════════════════════════════════════════════════════════════════════
type Liq
    float px
    int   b0
    bool  swept
    line  ln
    label lb

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_div(float num, float den, float fallback) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

L(string ar, string en) =>
    i_lang == "العربية" ? ar : en

f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Middle Left"  => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left"  => position.bottom_left
        =>                position.bottom_right

f_heat(float r) =>
    color base = r < 0.5 ? color.from_gradient(r, 0.0, 0.5, HM_LO, HM_MID) : color.from_gradient(r, 0.5, 1.0, HM_MID, HM_HI)
    int tr = int(math.round(i_transpLo - r * (i_transpLo - i_transpHi)))
    color.new(base, math.max(0, math.min(99, tr)))

// ══════════════════════════════════════════════════════════════════════════════
//  GLOBAL CALCULATIONS  (no ta.* inside conditional blocks)
// ══════════════════════════════════════════════════════════════════════════════
float rangeHi = ta.highest(high, i_look)
float rangeLo = ta.lowest(low, i_look)

float vAvg = ta.sma(volume, i_volLen)
float vSd  = ta.stdev(volume, i_volLen)
float volZ = f_div(nz(volume, 0.0) - nz(vAvg, 0.0), nz(vSd, 0.0), 0.0)

float buyV  = math.sum(close > open ? nz(volume, 0.0) : 0.0, i_look)
float sellV = math.sum(close < open ? nz(volume, 0.0) : 0.0, i_look)
float deltaPct = f_div(buyV - sellV, buyV + sellV, 0.0) * 100.0

float pvHigh = ta.pivothigh(high, i_pvLen, i_pvLen)
float pvLow  = ta.pivotlow(low, i_pvLen, i_pvLen)

// ══════════════════════════════════════════════════════════════════════════════
//  HEATMAP ENGINE
// ══════════════════════════════════════════════════════════════════════════════
var array<box> hmBoxes  = array.new<box>()
var line       pocLine  = na
var label      pocLabel = na
var int        lastDraw = na
var float      pocPrice = na
var float      hotRatio = na

bool doDraw = i_showHM and barstate.islast and bar_index > i_look + 5 and (not i_barClose or na(lastDraw) or lastDraw != bar_index)

if doDraw
    lastDraw := bar_index

    if array.size(hmBoxes) > 0
        for b in hmBoxes
            box.delete(b)
        array.clear(hmBoxes)
    line.delete(pocLine)
    label.delete(pocLabel)

    float rng = rangeHi - rangeLo
    if rng > 0
        int   nb      = i_bins
        int   nc      = i_cols
        float binH    = rng / nb
        int   colBars = math.max(1, i_look / nc)

        array<float> cells = array.new<float>(nb * nc, 0.0)
        array<float> rows  = array.new<float>(nb, 0.0)

        for c = 0 to nc - 1
            for k = 0 to colBars - 1
                int i = c * colBars + k
                if i < i_look
                    float hi = high[i]
                    float lo = low[i]
                    float v  = nz(volume[i], 1.0)
                    v := v <= 0 ? 1.0 : v
                    int b1 = math.max(0, math.min(nb - 1, int((lo - rangeLo) / binH)))
                    int b2 = math.max(0, math.min(nb - 1, int((hi - rangeLo) / binH)))
                    float share = v / (b2 - b1 + 1)
                    for b = b1 to b2
                        int idx = c * nb + b
                        array.set(cells, idx, array.get(cells, idx) + share)
                        array.set(rows, b, array.get(rows, b) + share)

        float mx = array.max(cells)

        // Point of Control (heaviest price row across the whole window)
        float rowMax = array.max(rows)
        int   pocIdx = 0
        for b = 0 to nb - 1
            if array.get(rows, b) == rowMax
                pocIdx := b
                break
        pocPrice := rangeLo + pocIdx * binH + binH * 0.5
        hotRatio := f_div(rowMax, array.sum(rows), 0.0) * 100.0

        // Paint the map
        if mx > 0
            int budget = 470
            for c = 0 to nc - 1
                int xr = bar_index - c * colBars
                int xl = math.max(0, xr - colBars + 1)
                for b = 0 to nb - 1
                    if budget > 0
                        float ratio = array.get(cells, c * nb + b) / mx
                        if ratio >= i_minInt
                            float topP = rangeLo + (b + 1) * binH
                            float botP = rangeLo + b * binH
                            box hb = box.new(xl, topP, xr, botP, border_color = color.new(color.black, 100), border_width = 0, bgcolor = f_heat(ratio))
                            array.push(hmBoxes, hb)
                            budget -= 1

        if i_showPOC
            pocLine  := line.new(math.max(0, bar_index - i_look), pocPrice, bar_index + i_ext, pocPrice, color = i_colPOC, width = 2)
            pocLabel := label.new(bar_index + i_ext, pocPrice, "POC " + str.tostring(pocPrice, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = i_colPOC, size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
//  RESTING LIQUIDITY POOLS  +  SWEEP DETECTION
// ══════════════════════════════════════════════════════════════════════════════
var array<Liq> poolsUp = array.new<Liq>()
var array<Liq> poolsDn = array.new<Liq>()
var int sweepUp = 0
var int sweepDn = 0

if i_showLiq and not na(pvHigh)
    line  nl = line.new(bar_index - i_pvLen, pvHigh, bar_index + i_ext, pvHigh, color = color.new(i_colAbove, 35), width = 1, style = line.style_dotted)
    label nlb = label.new(bar_index + i_ext, pvHigh, "≡ " + str.tostring(pvHigh, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(i_colAbove, 20), size = size.tiny)
    array.push(poolsUp, Liq.new(pvHigh, bar_index, false, nl, nlb))
    while array.size(poolsUp) > i_maxLiq
        Liq old = array.shift(poolsUp)
        line.delete(old.ln)
        label.delete(old.lb)

if i_showLiq and not na(pvLow)
    line  nl = line.new(bar_index - i_pvLen, pvLow, bar_index + i_ext, pvLow, color = color.new(i_colBelow, 35), width = 1, style = line.style_dotted)
    label nlb = label.new(bar_index + i_ext, pvLow, "≡ " + str.tostring(pvLow, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(i_colBelow, 20), size = size.tiny)
    array.push(poolsDn, Liq.new(pvLow, bar_index, false, nl, nlb))
    while array.size(poolsDn) > i_maxLiq
        Liq old = array.shift(poolsDn)
        line.delete(old.ln)
        label.delete(old.lb)

var bool sweptUpNow = false
var bool sweptDnNow = false
sweptUpNow := false
sweptDnNow := false

if i_showLiq and barstate.isconfirmed
    if array.size(poolsUp) > 0
        for i = array.size(poolsUp) - 1 to 0
            Liq lv = array.get(poolsUp, i)
            if bar_index - lv.b0 > i_liqAge
                line.delete(lv.ln)
                label.delete(lv.lb)
                array.remove(poolsUp, i)
            else if not lv.swept and high > lv.px
                lv.swept := true
                sweepUp += 1
                sweptUpNow := true
                if i_showSwp
                    line.set_color(lv.ln, color.new(i_colSwept, 25))
                    line.set_style(lv.ln, line.style_solid)
                    label.set_text(lv.lb, "✕ " + L("مجتاحة", "SWEPT"))
                    label.set_textcolor(lv.lb, i_colSwept)
                else
                    line.delete(lv.ln)
                    label.delete(lv.lb)
                    array.remove(poolsUp, i)
            else if not lv.swept
                line.set_x2(lv.ln, bar_index + i_ext)
                label.set_x(lv.lb, bar_index + i_ext)

    if array.size(poolsDn) > 0
        for i = array.size(poolsDn) - 1 to 0
            Liq lv = array.get(poolsDn, i)
            if bar_index - lv.b0 > i_liqAge
                line.delete(lv.ln)
                label.delete(lv.lb)
                array.remove(poolsDn, i)
            else if not lv.swept and low < lv.px
                lv.swept := true
                sweepDn += 1
                sweptDnNow := true
                if i_showSwp
                    line.set_color(lv.ln, color.new(i_colSwept, 25))
                    line.set_style(lv.ln, line.style_solid)
                    label.set_text(lv.lb, "✕ " + L("مجتاحة", "SWEPT"))
                    label.set_textcolor(lv.lb, i_colSwept)
                else
                    line.delete(lv.ln)
                    label.delete(lv.lb)
                    array.remove(poolsDn, i)
            else if not lv.swept
                line.set_x2(lv.ln, bar_index + i_ext)
                label.set_x(lv.lb, bar_index + i_ext)

// ══════════════════════════════════════════════════════════════════════════════
//  VOLUME BURSTS
// ══════════════════════════════════════════════════════════════════════════════
bool burstStrong  = i_showVol and volZ >= i_burst1 and volZ < i_burst2
bool burstExtreme = i_showVol and volZ >= i_burst2

plotshape(burstStrong, title = "Strong Volume", style = shape.circle, location = location.belowbar, color = color.new(i_colBurst, 45), size = size.tiny)
plotshape(burstExtreme, title = "Extreme Volume", style = shape.circle, location = location.belowbar, color = i_colBurst, size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
f_head(table t, int r, string a, string b) =>
    table.cell(t, 0, r, a, text_color = C_HDRTX, bgcolor = C_HDRBG, text_size = i_dashSize, text_halign = text.align_left)
    table.cell(t, 1, r, b, text_color = C_HDRTX, bgcolor = C_HDRBG, text_size = i_dashSize, text_halign = text.align_right)

f_row(table t, int r, string k, string v, color vc, bool alt) =>
    color bg = alt ? C_ROW_A : C_ROW_B
    table.cell(t, 0, r, k, text_color = C_MUTED, bgcolor = bg, text_size = i_dashSize, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = vc, bgcolor = bg, text_size = i_dashSize, text_halign = text.align_right)

if i_showDash and barstate.islast
    var table dash = table.new(f_pos(i_dashPos), 2, 12, bgcolor = C_PANEL, border_color = C_FRAME, border_width = 1, frame_color = C_FRAME, frame_width = 1)

    float nearUp = na
    float nearDn = na
    if array.size(poolsUp) > 0
        for i = 0 to array.size(poolsUp) - 1
            Liq lv = array.get(poolsUp, i)
            if not lv.swept and lv.px > close
                nearUp := na(nearUp) ? lv.px : math.min(nearUp, lv.px)
    if array.size(poolsDn) > 0
        for i = 0 to array.size(poolsDn) - 1
            Liq lv = array.get(poolsDn, i)
            if not lv.swept and lv.px < close
                nearDn := na(nearDn) ? lv.px : math.max(nearDn, lv.px)

    string pocTxt = na(pocPrice) ? "—" : str.tostring(pocPrice, format.mintick)
    string zoneTxt = na(pocPrice) ? "—" : close > pocPrice ? L("فوق التركيز ▲", "ABOVE POC ▲") : L("تحت التركيز ▼", "BELOW POC ▼")
    color  zoneCol = na(pocPrice) ? C_MUTED : close > pocPrice ? i_colBelow : i_colAbove
    string volTxt  = str.tostring(volZ, "#.0") + "σ"
    color  volCol  = volZ >= i_burst2 ? i_colBurst : volZ >= i_burst1 ? C_GOLD : C_TXT
    string dTxt    = (deltaPct >= 0 ? "+" : "") + str.tostring(deltaPct, "#.0") + "%"
    color  dCol    = deltaPct >= 0 ? i_colBelow : i_colAbove

    int r = 0
    f_head(dash, r, "◆ " + L("خريطة السيولة", "LIQUIDITY HEATMAP"), "v1.0")
    r += 1
    f_row(dash, r, syminfo.ticker + " · " + timeframe.period, str.tostring(i_look) + L(" شمعة", " bars"), C_TXT, true)
    r += 1
    f_row(dash, r, L("أعلى تركيز (POC)", "Point of Control"), pocTxt, i_colPOC, false)
    r += 1
    f_row(dash, r, L("موقع السعر", "Price Position"), zoneTxt, zoneCol, true)
    r += 1
    f_row(dash, r, L("كثافة التركيز", "POC Density"), na(hotRatio) ? "—" : str.tostring(hotRatio, "#.0") + "%", C_GOLD, false)
    r += 1
    f_row(dash, r, L("سيولة فوق", "Liquidity Above"), na(nearUp) ? "—" : str.tostring(nearUp, format.mintick), i_colAbove, true)
    r += 1
    f_row(dash, r, L("سيولة تحت", "Liquidity Below"), na(nearDn) ? "—" : str.tostring(nearDn, format.mintick), i_colBelow, false)
    r += 1
    f_row(dash, r, L("الاجتياحات ↑ / ↓", "Sweeps ↑ / ↓"), str.tostring(sweepUp) + " / " + str.tostring(sweepDn), C_TXT, true)
    r += 1
    f_row(dash, r, L("ضغط الحجم", "Volume Pressure"), dTxt, dCol, false)
    r += 1
    f_row(dash, r, L("الحجم الحالي", "Current Volume"), volTxt, volCol, true)
    r += 1
    f_head(dash, r, i_signature == "" ? L("خريطة السيولة", "Liquidity Heatmap") : i_signature, "HM-1.0")

// ══════════════════════════════════════════════════════════════════════════════
//  WATERMARK
// ══════════════════════════════════════════════════════════════════════════════
if i_showWM and barstate.islast
    var table wm = table.new(position.bottom_center, 1, 1, bgcolor = color.new(color.black, 100), border_width = 0, frame_width = 0)
    table.cell(wm, 0, 0, i_signature == "" ? "LIQUIDITY HEATMAP" : i_signature, text_color = isDark ? color.new(color.white, 84) : color.new(color.black, 84), text_size = size.normal, text_halign = text.align_center, bgcolor = color.new(color.black, 100))

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(sweptUpNow, title = "Liquidity Swept — Upside", message = "Liquidity Heatmap: buy-side liquidity swept above on {{ticker}} ({{interval}})")
alertcondition(sweptDnNow, title = "Liquidity Swept — Downside", message = "Liquidity Heatmap: sell-side liquidity swept below on {{ticker}} ({{interval}})")
alertcondition(burstExtreme, title = "Extreme Volume Burst", message = "Liquidity Heatmap: extreme volume burst on {{ticker}} ({{interval}})")
````
