# BB Breakout Range Tracker[WR]

- url: https://www.tradingview.com/script/02TMxRfk/
- type: indicator
- pine_id: PUB;fcdd2e7474cc4ea49de0a7a854582586
- version: 1.0

## Description

■ Overview
The BB Breakout Range Tracker is a technical analysis tool designed to identify and track price breakouts beyond standard Bollinger Bands. Unlike traditional indicators that only signal a cross, this script locks and visualizes the exact High-Low range of the breakout candle, keeping historical key levels on your chart as structured support/resistance zones.

■ Key Features

Directional Breakout Locking: Intelligently tracks alternative breakout signals (Upper vs. Lower), preventing repetitive noise in a single-direction trend.

Historical Range Accumulation: Automatically freezes prior breakout ranges in a clean, secondary color (grey) while maintaining active zones in vibrant real-time colors.

Contextual Volume Analysis: Displays the breakout candle's volume as a percentage relative to either the prior opposite breakout momentum or a 20-bar moving average to filter out false spikes.

■ How to Use

Breakout Validation: Look for high-volume breakouts (above 100% on the label) that close firmly outside the range lines to confirm strong trend continuation.

SR Zone Trading: Use the persistent historical grey channels as dynamic support and resistance zones for potential retests or stop-loss placements.

2. 블로그 초안용 한국어 가이드 (KOR)
■ 지표 개요

볼린저 밴드 돌파 매매의 단점인 '잦은 가짜 돌파(Fakeout)'와 '돌파 후 지지/저항 라인 파악의 어려움'을 해결하기 위해 개발된 지표입니다. 밴드를 돌파한 캔들의 고가와 저가를 하나의 '박스권(Range)'으로 시각화하여, 향후 주가의 지지·저항 역할을 할 기준선을 차트에 영구적으로 누적해 줍니다.

■ 주요 핵심 기능

추세 방향성 잠금 (Directional Lock): 상단 돌파 후 연이어 발생하는 상단 돌파는 무시하며, 반드시 하단 돌파가 나와야 신호가 전환되므로 추세 추종 시 노이즈를 대폭 줄여줍니다.

과거 매물대 누적 표시: 새로운 돌파가 발생하면 이전의 돌파 영역은 회색(Past Range)으로 변환되어 차트에 그대로 남습니다. 이는 강력한 과거의 지지/저항 매물대로 작용합니다.

돌파 거래량 직관적 비교: 돌파 캔들의 거래량이 '이전 반대편 돌파 거래량' 또는 '20이평 거래량' 대비 몇 %나 터졌는지 숫자로 표시해 주어, 신뢰도 높은 진짜 돌파를 선별할 수 있습니다.

■ 매매 활용 팁

돌파 확인 매매: 돌파 캔들에 표시된 거래량 비율이 100% 이상으로 높고, 밴드 밖에서 확정 캔들이 마감될 때 진입하는 것이 유리합니다.

풀백(Pullback) 및 타점: 돌파 후 주가가 밀리더라도, 차트에 남아있는 회색 과거 매물대 구역(Past Range)이나 현재 활성화된 지지 라인에서 지지받고 반등할 때 손익비 좋은 눌림목 타점을 잡을 수 있습니다.

## Source Code

````pine
//@version=6
indicator("BB Breakout Range Tracker", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================
// INPUTS
// ============================================================
src    = input.source(close, "Source")
length = input.int(20, "BB Length", minval = 1)
mult   = input.float(2.0, "Outer Band StdDev", minval = 0.001, maxval = 50, step = 0.1)

show_range_lines = input.bool(true, "Show Breakout Range Lines", group = "Breakout Range")
line_style_input = input.string("Dotted", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Breakout Range")
fill_transparency = input.int(70, "Range Fill Transparency", minval = 0, maxval = 100, group = "Breakout Range")

up_color   = input.color(color.new(color.blue, 0), "Upper Breakout Range Color", group = "Colors")
dn_color   = input.color(color.new(color.fuchsia, 0), "Lower Breakout Range Color", group = "Colors")
past_color = input.color(color.new(color.gray, 0), "Past Range Color", group = "Colors")
basis_color = input.color(color.new(color.black, 80), "Basis Color", group = "Colors")
band_color = input.color(color.new(color.black, 50), "Band Color", group = "Colors")

show_volume_label = input.bool(true, "Show Volume % Label at Breakout", group = "Volume Label")
volume_compare_mode = input.string("Opposite Breakout", "Compare Volume Against", options = ["Opposite Breakout", "20-Bar Average"], group = "Volume Label", tooltip = "Opposite Breakout: % of the last opposite-direction breakout candle's volume.\n20-Bar Average: % of the average volume over the prior 20 bars.")
volume_avg_length = input.int(20, "Average Length (bars)", minval = 1, group = "Volume Label")
volume_label_size = input.string("small", "Volume Label Size", options = ["tiny", "small", "normal", "large"], group = "Volume Label")
label_offset_atr_mult = input.float(0.5, "Label Vertical Offset (x ATR)", minval = 0, step = 0.1, group = "Volume Label", tooltip = "Distance between the candle and the label, expressed as a multiple of ATR(14). Increase if labels overlap candles or markers.")

// ============================================================
// BOLLINGER BAND CALCULATION
// ============================================================
basis = ta.sma(src, length)
dev   = mult * ta.stdev(src, length)

upper = basis + dev
lower = basis - dev

// ============================================================
// PLOTS
// ============================================================
p_basis = plot(basis, "Basis", color = basis_color, linewidth = 1)
p_upper = plot(upper, "Upper Band", color = band_color, linewidth = 1)
p_lower = plot(lower, "Lower Band", color = band_color, linewidth = 1)

// ============================================================
// BREAKOUT DETECTION (outer band)
// breakout_dir locks the direction once a breakout occurs: after an upper
// breakout, further upper crosses are ignored until a lower breakout fires
// (and vice versa). This prevents repeated re-breakouts in the same
// direction from being treated as new signals.
// ============================================================
var int breakout_dir = 0

bool raw_broke_up = ta.crossover(close, upper)
bool raw_broke_dn = ta.crossunder(close, lower)

bool broke_up = raw_broke_up and breakout_dir != 1
bool broke_dn = raw_broke_dn and breakout_dir != -1

if broke_up
    breakout_dir := 1
if broke_dn
    breakout_dir := -1

// ============================================================
// BREAKOUT RANGE TRACKING
// On the bar right after a breakout is confirmed, lock in the breakout candle's
// high/low as the range. ta.valuewhen holds that value until the next breakout
// of the same direction occurs, which is what makes the range line extend
// to the right across all the bars in between.
// ============================================================
var int last_up_index = na
var int last_dn_index = na

if broke_up
    last_up_index := bar_index
if broke_dn
    last_dn_index := bar_index

// Lock in high/low of the breakout bar itself (the bar where the cross happened)
up_range_hi = ta.valuewhen(broke_up, high, 0)
up_range_lo = ta.valuewhen(broke_up, low, 0)
dn_range_hi = ta.valuewhen(broke_dn, high, 0)
dn_range_lo = ta.valuewhen(broke_dn, low, 0)

get_line_style(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// ============================================================
// DRAW RANGE LINES
// Active range lines/fill are extended every bar in the live color (up_color /
// dn_color). When a new breakout of that same direction fires, the line/fill
// that was active is NOT deleted -- it is recolored grey (past_color) and left
// in place permanently, then a fresh pair of lines is started in the live
// color for the new breakout. This way, all prior breakout ranges accumulate
// on the chart in grey instead of disappearing.
// ============================================================
var line up_hi_line = na
var line up_lo_line = na
var line dn_hi_line = na
var line dn_lo_line = na

var linefill up_fill = na
var linefill dn_fill = na

if show_range_lines
    line_style = get_line_style(line_style_input)

    if broke_up
        // Freeze the previous active up-range as a permanent grey record
        if not na(up_hi_line)
            line.set_color(up_hi_line, past_color)
            line.set_color(up_lo_line, past_color)
            linefill.set_color(up_fill, color.new(past_color, fill_transparency))
        // Start a fresh pair of lines at the breakout bar's high/low
        up_hi_line := line.new(bar_index, up_range_hi, bar_index, up_range_hi, color = up_color, style = line_style, width = 2)
        up_lo_line := line.new(bar_index, up_range_lo, bar_index, up_range_lo, color = up_color, style = line_style, width = 2)
        up_fill := linefill.new(up_hi_line, up_lo_line, color = color.new(up_color, fill_transparency))
    else if not na(last_up_index)
        // Extend the existing active pair to the current bar
        if not na(up_hi_line)
            line.set_xy2(up_hi_line, bar_index, up_range_hi)
            line.set_xy2(up_lo_line, bar_index, up_range_lo)

    if broke_dn
        // Freeze the previous active down-range as a permanent grey record
        if not na(dn_hi_line)
            line.set_color(dn_hi_line, past_color)
            line.set_color(dn_lo_line, past_color)
            linefill.set_color(dn_fill, color.new(past_color, fill_transparency))
        dn_hi_line := line.new(bar_index, dn_range_hi, bar_index, dn_range_hi, color = dn_color, style = line_style, width = 2)
        dn_lo_line := line.new(bar_index, dn_range_lo, bar_index, dn_range_lo, color = dn_color, style = line_style, width = 2)
        dn_fill := linefill.new(dn_hi_line, dn_lo_line, color = color.new(dn_color, fill_transparency))
    else if not na(last_dn_index)
        if not na(dn_hi_line)
            line.set_xy2(dn_hi_line, bar_index, dn_range_hi)
            line.set_xy2(dn_lo_line, bar_index, dn_range_lo)

// ============================================================
// BREAKOUT MARKERS
// ============================================================
plotshape(broke_up, title = "Upper Breakout Marker", style = shape.triangleup, location = location.belowbar, color = up_color, size = size.small)
plotshape(broke_dn, title = "Lower Breakout Marker", style = shape.triangledown, location = location.abovebar, color = dn_color, size = size.small)

// ============================================================
// VOLUME COMPARISON LABEL
// On each breakout, show this breakout candle's volume as a percentage of a
// baseline, in one of two modes (set via volume_compare_mode):
//   - "Opposite Breakout": baseline is the volume of the most recent
//     breakout candle in the OPPOSITE direction (momentum comparison).
//   - "20-Bar Average": baseline is the average volume over the prior N
//     bars, excluding the breakout bar itself (anomaly/spike detection).
// ta.valuewhen holds the previous opposite-direction breakout's volume so it
// survives until the next cross of that direction.
// ============================================================
prev_up_volume = ta.valuewhen(broke_up, volume, 0)
prev_dn_volume = ta.valuewhen(broke_dn, volume, 0)
avg_volume = ta.sma(volume, volume_avg_length)[1]  // average of the N bars before the breakout bar, excludes the breakout bar itself

label_offset = ta.atr(14) * label_offset_atr_mult

get_label_size(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : size.large

if show_volume_label
    lbl_size = get_label_size(volume_label_size)
    bool use_avg_mode = volume_compare_mode == "20-Bar Average"

    // Short breakout marker sits abovebar -> place label further above it
    bool dn_has_baseline = use_avg_mode ? (avg_volume != 0) : (not na(prev_up_volume) and prev_up_volume != 0)
    if broke_dn and dn_has_baseline
        pct_dn = use_avg_mode ? volume / avg_volume * 100 : volume / prev_up_volume * 100
        label.new(bar_index, high + label_offset, str.tostring(pct_dn, "#.#") + "%", style = label.style_label_down, color = color.new(dn_color, 0), textcolor = color.white, size = lbl_size, yloc = yloc.price)

    // Long breakout marker sits belowbar -> place label further below it
    bool up_has_baseline = use_avg_mode ? (avg_volume != 0) : (not na(prev_dn_volume) and prev_dn_volume != 0)
    if broke_up and up_has_baseline
        pct_up = use_avg_mode ? volume / avg_volume * 100 : volume / prev_dn_volume * 100
        label.new(bar_index, low - label_offset, str.tostring(pct_up, "#.#") + "%", style = label.style_label_up, color = color.new(up_color, 0), textcolor = color.white, size = lbl_size, yloc = yloc.price)

alertcondition(broke_up, "Price Broke Above Upper Band", "Price crossed above the upper Bollinger Band.")
alertcondition(broke_dn, "Price Broke Below Lower Band", "Price crossed below the lower Bollinger Band.")
````
