# True Order Blocks & Liquidity Levels

- url: https://www.tradingview.com/script/fCsxiy1a-true-order-blocks-liquidity-levels/
- type: indicator
- pine_id: PUB;953b97f73a06447fa1f12faaf4b65153
- version: 2.0

## Description

[b]True Order Blocks & Liquidity Levels[/b] — a comprehensive price action toolkit for market structure analysis, liquidity mapping, and institutional zone detection across any instrument and timeframe.

The logic behind order blocks, imbalances, and internal pullbacks is built in strict accordance with the inside bar methodology — one of the most precise approaches to identifying institutional points of interest. Every module accounts for whether a bar is an inside bar, which significantly improves signal quality and eliminates false zones that commonly appear with traditional approaches.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]MODULES[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[b]▸ Internal Pullbacks[/b]

Displays market structure as lines connecting sequential pivot highs and lows. Inside bars are ignored during structure building, keeping pullback lines clean and noise-free. The last open line redraws in real time as price develops.

[list]
[*]Adjustable number of visible lines
[*]Color, style (solid / dashed / dotted) and width customization
[/list]

[b]▸ Internal Liquidity[/b]

Horizontal lines automatically placed at each confirmed pivot high and low. A line persists until price crosses it — at that moment the line is removed and an alert fires. These levels mark clusters of stop orders and serve as potential targets for liquidity sweeps.

[list]
[*]Independent limit on the number of visible levels
[*]Color and style customization
[*]Alert on level breach
[/list]

[b]▸ Imbalance (FVG)[/b]

Fair Value Gap detector built on three consecutive [i]non-inside[/i] bars. The algorithm steps over inside bars when searching for the FVG — this means the gap can span more than 3 candles visually if inside bars appear in between, which is intentional and produces cleaner zones. Open-price gaps are handled by clipping FVG boundaries to the body of the middle candle.

[list]
[*]Separate colors for bullish and bearish FVG zones
[*]Maximum number of displayed zones
[*]Midline drawn inside each zone for easier reference
[/list]

[b]▸ Order Blocks[/b]

Institutional interest zones formed by a strict algorithm: an order block is drawn only when the bar preceding a FVG performed a liquidity sweep — meaning it broke the high or low of the prior significant pivot. The block is placed on the candle immediately preceding the impulsive move. If an absorption candle stands between the OB candidate and the FVG, the candidate is reset — preventing false blocks from forming on overly aggressive moves.

[list]
[*]Automatic mitigation tracking: when price touches the zone, the block changes to a "mitigated" color
[*]Option to hide mitigated blocks entirely
[*]Separate colors for bullish, bearish, and mitigated blocks
[*]Adjustable history depth
[*]Alerts on new block formation and on mitigation
[/list]

[b]▸ Inside Bars[/b]

Highlights bars that fit entirely within the range of the previous mother candle. A series of consecutive inside bars signals compression and accumulation ahead of a directional move.

[list]
[*]Barcolor highlight with customizable color
[*]Adjustable lookback depth
[/list]

[b]▸ Absorption[/b]

Marks candles that fully engulf the range of the previous mother candle (high > mother high [i]and[/i] low < mother low). These candles often indicate absorption of accumulated positions and a short-term shift in intent.

[list]
[*]Separate highlight color independent of Inside Bars
[*]Alert on absorption candle formation
[/list]

[b]▸ PDH / PDL — Previous Day High & Low[/b]

Displays high and low levels from previous trading days (up to 7 days). Levels that have been fully engulfed by price are automatically hidden. Each level is labeled: the most recent is marked "PDH" / "PDL", older ones show the date in month/day format.

[list]
[*]Adjustable number of days displayed
[*]Unified color for all PDH/PDL levels
[*]Alert when price crosses a level
[/list]

[b]▸ Market Sessions[/b]

Draws session boxes for each trading session over the last N days. Five fully independent sessions are supported — defaults are Asia, Frankfurt, London, New York, and one custom user-defined session.

[list]
[*]Custom name, start and end time (UTC), and background color per session
[*]Optional horizontal border lines showing session high and low
[*]Border style and width customization
[*]Adjustable display depth (number of days)
[*]Alerts when price crosses the high or low of a closed session
[/list]

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]TREND FILTER[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

Colors the chart background based on WaveTrend oscillator alignment across up to three independent timeframes. When all selected timeframes show WT above zero simultaneously — bullish background. When all show WT below zero — bearish background. When timeframes disagree — no background, signalling an unclear or transitional market state.

[b]How WaveTrend is calculated:[/b] WT is built as a double-smoothed normalized channel index on HLC3. The first EMA measures the average deviation of price from its mean; the result is normalized and smoothed again to produce the final oscillator value. Values above zero indicate bullish bias, below zero — bearish.

[list]
[*][b]Show trend filter[/b] — master on/off switch
[*][b]WT Channel Length[/b] — EMA length for channel calculation. Shorter = more reactive
[*][b]WT Average Length[/b] — smoothing EMA applied on top. Larger = calmer signal
[*][b]TF 1 / TF 2 / TF 3[/b] — each row has an enable toggle and a timeframe selector. Defaults: 15m, 1h, 4h. A disabled timeframe is treated as neutral and excluded from alignment check
[*][b]Confirm trend on bar close[/b] — when enabled, background and alerts only react to values from the last [i]closed[/i] HTF bar, eliminating intra-bar repainting. When disabled, the background updates in real time as the HTF bar forms
[*][b]Bullish / Bearish background colors[/b] — customizable with transparency
[*][b]Trend Changed alert[/b] — fires on bar close on any of the six possible state transitions: uptrend ↔ neutral ↔ downtrend and direct flip. Alert message specifies the exact transition
[/list]

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]DASHBOARD[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

A compact table showing WaveTrend values for each enabled timeframe. Only enabled timeframes are displayed — from one to three rows.

[list]
[*]Column 1: timeframe label (15m, 1h, 4h etc.)
[*]Column 2: current WT value rounded to one decimal. Cell background reflects signal strength: neutral grey (−10 to +10), weak green/red (±10 to ±40), saturated green/red (beyond ±40)
[*][b]Position[/b] — 9 placement options across the chart
[*][b]Text size[/b] — Tiny / Small / Normal / Large
[/list]

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]ALERTS[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

Every module has its own independent alert toggle. All messages can optionally be prefixed with the instrument ticker — useful when monitoring multiple charts simultaneously.

[list]
[*]Liquidity level breached
[*]Absorption candle formed
[*]New order block created
[*]Order block mitigated
[*]Session high or low crossed
[*]PDH / PDL level crossed
[*]Trend changed (WaveTrend multi-TF)
[/list]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6

indicator("True Order Blocks & Liquidity Levels", overlay = true, max_lines_count = 500, max_boxes_count = 1500)


// ============================================================
// INPUTS — Internal Pullbacks
// ============================================================
pullback_show = input.bool(true,  "Show Internal Pullbacks", group="Internal Pullbacks")
lines_count   = input.int(100,    "Lines count",  minval=1, maxval=500, group="Internal Pullbacks", inline="pb_color")
line_color    = input.color(color.new(color.gray,0), "", group="Internal Pullbacks", inline="pb_color")
line_style_s  = input.string("Solid", "Line style", options=["Solid","Dashed","Dotted"], group="Internal Pullbacks")
line_width    = input.int(1, "Line width", minval=1, maxval=4, group="Internal Pullbacks")

il_show       = input.bool(true,  "Show Internal Liquidity", group="Internal Pullbacks", inline="il_show")
il_color      = input.color(color.new(#787b86, 50), "", group="Internal Pullbacks", inline="il_show")
il_style_s    = input.string("Dotted", "Liquidity line style", options=["Solid","Dashed","Dotted"], group="Internal Pullbacks")
il_count      = input.int(50, "Liquidity lines count", minval=1, maxval=500, group="Internal Pullbacks")

// ============================================================
// INPUTS — Inside Bars
// ============================================================
ib_show     = input.bool(true,  "Show Inside Bars",  group="Inside Bars", inline="ib_show")
ib_color    = input.color(color.new(#787b86, 70), "", group="Inside Bars", inline="ib_show")
ib_lookback = input.int(500,    "Lookback bars",     minval=1, maxval=5000, group="Inside Bars")

// ============================================================
// INPUTS — Absorption
// ============================================================
abs_show  = input.bool(true,  "Show Absorption",  group="Absorption", inline="abs_show")
abs_color = input.color(color.new(#ffeb3b, 60), "", group="Absorption", inline="abs_show")

// ============================================================
// INPUTS — Imbalance (FVG)
// ============================================================
fvg_show       = input.bool(true,  "Show FVG",          group="Imbalance")
fvg_max        = input.int(100,    "Max FVG to display", minval=1, maxval=500, group="Imbalance")
fvg_bull_color = input.color(color.new(#089981, 80), "Bullish FVG", group="Imbalance")
fvg_bear_color = input.color(color.new(#f23645, 80), "Bearish FVG", group="Imbalance")

// ============================================================
// INPUTS — Order Blocks
// ============================================================
ob_show         = input.bool(true,  "Show Order Blocks",      group="Order Blocks")
ob_bull_color   = input.color(color.new(#089981, 75), "Bullish OB",    group="Order Blocks")
ob_bear_color   = input.color(color.new(#f23645, 75), "Bearish OB",    group="Order Blocks")
ob_mit_color    = input.color(color.new(#4a90b8, 75), "Mitigated OB",  group="Order Blocks")
ob_history      = input.int(500,    "History bars",  minval=1, maxval=5000, group="Order Blocks")
ob_extend_mit   = input.bool(false, "Extend mitigated until fully covered",
     tooltip="When enabled, a mitigated block continues to extend right until price fully covers the entire zone (accumulated high >= block top AND accumulated low <= block bottom). Has no effect when \"Hide mitigated\" is enabled, as the block is deleted on first touch.",
     group="Order Blocks")
ob_hide_mit     = input.bool(false, "Hide mitigated",          group="Order Blocks")
ob_hide_full    = input.bool(false, "Hide fully covered",
     tooltip="When enabled, a block is deleted as soon as it becomes fully covered by price. Has no effect when \"Hide mitigated\" is enabled, as the block is already deleted on first touch.",
     group="Order Blocks")


// ============================================================
// INPUTS — Market Sessions
// ============================================================
sess_show     = input.bool(true,  "Show Sessions", group="Market Sessions", inline="sess_show")
sess_days     = input.int(3, "Days", minval=1, maxval=7, group="Market Sessions", inline="sess_show")
sess_a_show   = input.bool(true,  "A",  group="Market Sessions", inline="sess_row")
sess_f_show   = input.bool(true,  "F",  group="Market Sessions", inline="sess_row")
sess_l_show   = input.bool(true,  "L",  group="Market Sessions", inline="sess_row")
sess_ny_show  = input.bool(true,  "NY", group="Market Sessions", inline="sess_row")
sess_5_show   = input.bool(false, "№5", group="Market Sessions", inline="sess_row")

sess_border_show    = input.bool(true,   "Borders",    group="Market Sessions", inline="sess_border")
sess_border_style_s = input.string("Solid", "",        group="Market Sessions", inline="sess_border", options=["Solid","Dashed","Dotted"])
sess_border_width   = input.int(1,        "",          group="Market Sessions", inline="sess_border", minval=1, maxval=4)

sess_a_label  = input.string("Asia",  "Name",  group="Market Sessions", inline="sess_a")
sess_a_start  = input.string("00:00", "Start", group="Market Sessions", inline="sess_a")
sess_a_end    = input.string("05:00", "End",   group="Market Sessions", inline="sess_a")
sess_a_color  = input.color(color.new(#e91e8c, 90), "", group="Market Sessions", inline="sess_a")

sess_f_label  = input.string("F",     "Name",  group="Market Sessions", inline="sess_f")
sess_f_start  = input.string("06:00", "Start", group="Market Sessions", inline="sess_f")
sess_f_end    = input.string("07:00", "End",   group="Market Sessions", inline="sess_f")
sess_f_color  = input.color(color.new(#787b86, 90), "", group="Market Sessions", inline="sess_f")

sess_l_label  = input.string("L",     "Name",  group="Market Sessions", inline="sess_l")
sess_l_start  = input.string("07:00", "Start", group="Market Sessions", inline="sess_l")
sess_l_end    = input.string("10:00", "End",   group="Market Sessions", inline="sess_l")
sess_l_color  = input.color(color.new(#787b86, 90), "", group="Market Sessions", inline="sess_l")

sess_ny_label = input.string("NY",    "Name",  group="Market Sessions", inline="sess_ny")
sess_ny_start = input.string("12:00", "Start", group="Market Sessions", inline="sess_ny")
sess_ny_end   = input.string("16:00", "End",   group="Market Sessions", inline="sess_ny")
sess_ny_color = input.color(color.new(#787b86, 90), "", group="Market Sessions", inline="sess_ny")

sess_5_label  = input.string("№5",   "Name",  group="Market Sessions", inline="sess_5")
sess_5_start  = input.string("21:00", "Start", group="Market Sessions", inline="sess_5")
sess_5_end    = input.string("22:00", "End",   group="Market Sessions", inline="sess_5")
sess_5_color  = input.color(color.new(#9c27b0, 90), "", group="Market Sessions", inline="sess_5")

// ============================================================
// INPUTS — PDH/PDL
// ============================================================
pdhl_show       = input.bool(true,   "Show PDH/PDL",  group="PDH/PDL", inline="pdhl_show")
pdhl_color      = input.color(color.new(#2962ff, 0), "", group="PDH/PDL", inline="pdhl_show")
pdhl_days       = input.int(3, "Days", minval=1, maxval=7, group="PDH/PDL")

// ============================================================
// INPUTS — Open Day
// ============================================================
od_show  = input.bool(true,  "Show Open Day", group="Open Day", inline="od_show")
od_color = input.color(color.new(#ff9800, 0), "", group="Open Day", inline="od_show")
od_time  = input.string("00:00", "Time (UTC)",
     tooltip="UTC time at which the Open Day level is fixed. Uses the open price of the first bar that reaches or passes this time.",
     group="Open Day")

// ============================================================
// INPUTS — Trend Filter
// ============================================================
tf_show       = input.bool(true,  "Show trend filter",
     tooltip="Enable/disable the entire Trend Filter module. When enabled, background is colored based on WaveTrend alignment across selected timeframes.",
     group="Trend Filter")

// WaveTrend oscillator parameters
tf_wt_ch_len  = input.int(9,  "WT Channel Length",
     minval=1,
     tooltip="Length of the EMA used to compute the WaveTrend channel. Smaller values make the oscillator more reactive.",
     group="Trend Filter")
tf_wt_avg_len = input.int(12, "WT Average Length",
     minval=1,
     tooltip="Length of the smoothing EMA applied to the channel index. Larger values produce a smoother WaveTrend line.",
     group="Trend Filter")

// Timeframe 1
tf_1_enable   = input.bool(true, "TF 1",
     tooltip="Include this timeframe in the trend alignment check. When disabled, the timeframe is treated as neutral.",
     group="Trend Filter", inline="tf1")
tf_1          = input.timeframe("15", "",
     group="Trend Filter", inline="tf1")

// Timeframe 2
tf_2_enable   = input.bool(true, "TF 2",
     tooltip="Include this timeframe in the trend alignment check. When disabled, the timeframe is treated as neutral.",
     group="Trend Filter", inline="tf2")
tf_2          = input.timeframe("60", "",
     group="Trend Filter", inline="tf2")

// Timeframe 3
tf_3_enable   = input.bool(true, "TF 3",
     tooltip="Include this timeframe in the trend alignment check. When disabled, the timeframe is treated as neutral.",
     group="Trend Filter", inline="tf3")
tf_3          = input.timeframe("240", "",
     group="Trend Filter", inline="tf3")

// Background colors
tf_confirm    = input.bool(false, "Confirm trend on bar close",
     tooltip="When enabled, the background and alerts only react to WaveTrend values from the last CLOSED bar of each selected timeframe. Eliminates repainting — the signal will not appear or disappear before the HTF bar closes. When disabled, the background updates in real time as the HTF bar forms.",
     group="Trend Filter")

tf_bull_color = input.color(color.new(color.green, 90), "Bullish background",
     tooltip="Background color shown when ALL enabled timeframes have WaveTrend > 0 (full bullish alignment).",
     group="Trend Filter")
tf_bear_color = input.color(color.new(color.red,   90), "Bearish background",
     tooltip="Background color shown when ALL enabled timeframes have WaveTrend < 0 (full bearish alignment).",
     group="Trend Filter")



// ============================================================
// INPUTS — Dashboard
// ============================================================
db_show      = input.bool(true, "Show Dashboard",
     tooltip="Show a compact table with WaveTrend values for each enabled timeframe. Only enabled timeframes are displayed",
     group="Dashboard")

db_position  = input.string("Bottom Right", "Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     tooltip="Corner of the chart where the dashboard table will be anchored.",
     group="Dashboard")

db_text_size = input.string("Small", "Text size",
     options=["Tiny","Small","Normal","Large"],
     tooltip="Font size used inside the dashboard table.",
     group="Dashboard")



// ============================================================
// INPUTS — Alerts
// ============================================================
alert_absorption = input.bool(true,  "Absorption",          group="Alerts")
alert_new_ob     = input.bool(true,  "New order block",     group="Alerts")
alert_mit_ob     = input.bool(true,  "Mitigate order block",group="Alerts")
alert_sessions   = input.bool(true,  "Market sessions",     group="Alerts")
alert_pdhl       = input.bool(true,  "PDH/PDL",             group="Alerts")
alert_trend      = input.bool(true,  "Trend changed",       group="Alerts")
alert_ticker     = input.bool(true,  "Include ticker in alert message", group="Alerts")

// ============================================================
// STYLE HELPERS
// ============================================================
line_style        = line_style_s == "Dashed" ? line.style_dashed : line_style_s == "Dotted" ? line.style_dotted : line.style_solid
il_style          = il_style_s   == "Dashed" ? line.style_dashed : il_style_s   == "Dotted" ? line.style_dotted : line.style_solid
sess_border_style = sess_border_style_s == "Dashed" ? line.style_dashed : sess_border_style_s == "Dotted" ? line.style_dotted : line.style_solid
alert_prefix      = alert_ticker ? syminfo.tickerid + ": " : ""


// ============================================================
// INTERNAL PULLBACKS — STATE
// ============================================================
var bool  goingUp        = false
var float pivotHigh      = 0.0
var float pivotLow       = 0.0
var int   pivotHighTime  = 0
var int   pivotLowTime   = 0
var float prevPivotVal   = 0.0
var int   prevPivotTime  = 0
var bool  initialized    = false
var float refHigh        = 0.0
var float refLow         = 0.0
var int   pivotHighBarIdx = 0
var int   pivotLowBarIdx  = 0
var line[] allLines      = array.new_line()
var line   lastOpenLine  = na
var line[] il_lines      = array.new_line()
var int[]  il_created    = array.new_int()


// ============================================================
// INTERNAL PULLBACKS — LOGIC
// ============================================================
bool isInside = high <= refHigh and low >= refLow

newIntLine(t1, v1, t2, v2) =>
    if pullback_show
        ln = line.new(t1, v1, t2, v2, xloc=xloc.bar_time, color=line_color, width=line_width, style=line_style)
        array.push(allLines, ln)
        while array.size(allLines) > lines_count
            line.delete(array.shift(allLines))



// Add internal liquidity horizontal line at pivot level
il_add(int pivot_bar, float val) =>
    if il_show
        // Don't add if a line at this level already exists
        bool exists = false
        if array.size(il_lines) > 0
            for k = 0 to array.size(il_lines) - 1
                if math.abs(line.get_y1(array.get(il_lines, k)) - val) < syminfo.mintick
                    exists := true
                    break
        if not exists
            ln = line.new(pivot_bar, val, pivot_bar + 1, val,
                 color=il_color, width=1, style=il_style, extend=extend.right)
            array.push(il_lines,   ln)
            array.push(il_created, bar_index)
            while array.size(il_lines) > il_count
                line.delete(array.shift(il_lines))
                array.shift(il_created)

if not initialized and not isInside
    initialized      := true
    goingUp          := close >= open
    pivotHigh        := high
    pivotLow         := low
    pivotHighTime    := time
    pivotLowTime     := time
    pivotHighBarIdx  := bar_index
    pivotLowBarIdx   := bar_index
    prevPivotVal     := goingUp ? low : high
    prevPivotTime    := time
    refHigh          := high
    refLow           := low

else if initialized and not isInside
    bool breakHigh = high > refHigh
    bool breakLow  = low  < refLow

    if goingUp
        if breakHigh and breakLow
            if high > pivotHigh
                pivotHigh        := high
                pivotHighTime    := time
                pivotHighBarIdx  := bar_index
            newIntLine(prevPivotTime, prevPivotVal, pivotHighTime, pivotHigh)
            il_add(pivotHighBarIdx, pivotHigh)
            prevPivotVal     := pivotHigh
            prevPivotTime    := pivotHighTime
            pivotLow         := low
            pivotLowTime     := time
            pivotLowBarIdx   := bar_index
            pivotHigh        := high
            pivotHighTime    := time
            pivotHighBarIdx  := bar_index
            goingUp          := false

        else if breakHigh
            if high >= pivotHigh
                pivotHigh       := high
                pivotHighTime   := time
                pivotHighBarIdx := bar_index
                pivotLow        := low
                pivotLowTime    := time
                pivotLowBarIdx  := bar_index

        else if breakLow
            if low < pivotLow
                newIntLine(prevPivotTime, prevPivotVal, pivotHighTime, pivotHigh)
                il_add(pivotHighBarIdx, pivotHigh)
                prevPivotVal     := pivotHigh
                prevPivotTime    := pivotHighTime
                pivotLow         := low
                pivotLowTime     := time
                pivotLowBarIdx   := bar_index
                pivotHigh        := high
                pivotHighTime    := time
                pivotHighBarIdx  := bar_index
                goingUp          := false

    else
        if breakHigh and breakLow
            if low < pivotLow
                pivotLow       := low
                pivotLowTime   := time
                pivotLowBarIdx := bar_index
            newIntLine(prevPivotTime, prevPivotVal, pivotLowTime, pivotLow)
            il_add(pivotLowBarIdx, pivotLow)
            prevPivotVal     := pivotLow
            prevPivotTime    := pivotLowTime
            pivotHigh        := high
            pivotHighTime    := time
            pivotHighBarIdx  := bar_index
            pivotLow         := low
            pivotLowTime     := time
            pivotLowBarIdx   := bar_index
            goingUp          := true

        else if breakLow
            if low <= pivotLow
                pivotLow       := low
                pivotLowTime   := time
                pivotLowBarIdx := bar_index
                pivotHigh      := high
                pivotHighTime  := time
                pivotHighBarIdx := bar_index

        else if breakHigh
            if high > pivotHigh
                newIntLine(prevPivotTime, prevPivotVal, pivotLowTime, pivotLow)
                il_add(pivotLowBarIdx, pivotLow)
                prevPivotVal     := pivotLow
                prevPivotTime    := pivotLowTime
                pivotHigh        := high
                pivotHighTime    := time
                pivotHighBarIdx  := bar_index
                pivotLow         := low
                pivotLowTime     := time
                pivotLowBarIdx   := bar_index
                goingUp          := true

    refHigh := high
    refLow  := low

// Last open internal line (live, redrawn every tick)
if barstate.islast and initialized
    if pullback_show
        line.delete(lastOpenLine)
        lastOpenLine := line.new(prevPivotTime, prevPivotVal,
             goingUp ? pivotHighTime : pivotLowTime,
             goingUp ? pivotHigh : pivotLow,
             xloc=xloc.bar_time, color=line_color, width=line_width, style=line_style)

// ============================================================
// INTERNAL LIQUIDITY — horizontal lines at pivot highs/lows
// ============================================================
// Extend lines right and remove mitigated ones each bar
if il_show and array.size(il_lines) > 0
    int i = 0
    while i < array.size(il_lines)
        ln = array.get(il_lines, i)
        int  created_at = array.get(il_created, i)
        float val = line.get_y1(ln)
        bool crossed = bar_index > created_at and low < val and high > val
        if crossed
            line.delete(ln)
            array.remove(il_lines, i)
            array.remove(il_created, i)
            alert(alert_prefix + "Liquidity level mitigated", alert.freq_once_per_bar)
        else
            i += 1

// ============================================================
// INSIDE BARS & ABSORPTION — LOGIC
// ============================================================
var float ib_mother_high = na
var float ib_mother_low  = na
var bool  ib_had_inside  = false  // true if at least one inside bar followed the mother

bool is_inside_bar = false
bool is_absorption = false

if not na(ib_mother_high)
    if high <= ib_mother_high and low >= ib_mother_low
        // Inside the mother bar
        is_inside_bar  := true
        ib_had_inside  := true
    else
        // Broke out of the mother bar
        // Absorption: engulfs the mother entirely.
        // Works both after a series of inside bars AND on a plain engulfing bar
        // (when ib_had_inside=false, mother = previous bar, so it's a simple engulf).
        if high > ib_mother_high and low < ib_mother_low
            is_absorption := true
        // Current bar becomes the new mother
        ib_mother_high := high
        ib_mother_low  := low
        ib_had_inside  := false
else
    ib_mother_high := high
    ib_mother_low  := low
    ib_had_inside  := false

bool in_lookback = last_bar_index - bar_index < ib_lookback

barcolor(ib_show  and in_lookback and is_inside_bar ? ib_color  : na, title="Inside Bar")
barcolor(abs_show and in_lookback and is_absorption  ? abs_color : na, title="Absorption")

if alert_absorption and in_lookback and is_absorption and barstate.isconfirmed
    alert(alert_prefix + "Absorption candle formed", alert.freq_once_per_bar_close)

// ============================================================
// IMBALANCE (FVG) — LOGIC
// ============================================================
// Queue of last 4 non-inside candles (need 4th to check liquidity sweep for OB).

var float[] fvg_q_high     = array.new_float()
var float[] fvg_q_low      = array.new_float()
var int[]   fvg_q_idx      = array.new_int()
// For OB: physical prev bar (bar_index-1) at the moment each candle entered the queue
var float[] fvg_q_prev_high = array.new_float()
var float[] fvg_q_prev_low  = array.new_float()
var box[]   fvg_boxes      = array.new_box()
var line[]  fvg_lines      = array.new_line()

fvg_add(box b, float top, float bot, color col) =>
    array.push(fvg_boxes, b)
    float mid = (top + bot) / 2
    ln = line.new(box.get_left(b), mid, box.get_right(b), mid,
         color=color.new(col, 0), width=1, style=line.style_solid)
    array.push(fvg_lines, ln)
    while array.size(fvg_boxes) > fvg_max
        box.delete(array.shift(fvg_boxes))
        line.delete(array.shift(fvg_lines))

// ============================================================
// ORDER BLOCKS — STATE
// ============================================================
type OBBlock
    box   b
    bool  is_bull
    bool  mitigated
    float top
    float bot
    int   start_idx
    int   created_bar
    bool  fully_covered
    float run_high
    float run_low

var OBBlock[] ob_blocks = array.new<OBBlock>()
var bool  ob_bull_cand = false
var bool  ob_bear_cand = false

ob_add(int idx, float h, float l, bool is_bull) =>
    if last_bar_index - idx < ob_history
        col = is_bull ? ob_bull_color : ob_bear_color
        b = box.new(idx, h, bar_index, l,
             border_color=na, bgcolor=col, extend=extend.none)
        array.push(ob_blocks, OBBlock.new(b, is_bull, false, h, l, idx, bar_index, false, na, na))
        if alert_new_ob and barstate.isconfirmed
            alert(alert_prefix + "New " + (is_bull ? "bullish" : "bearish") + " order block"), alert.freq_once_per_bar_close

// ============================================================
// FVG + OB DETECTION — runs on every non-inside bar
// ============================================================
var float last_non_inside_high = na
var float last_non_inside_low  = na

if not is_inside_bar and barstate.isconfirmed
    array.push(fvg_q_high,      high)
    array.push(fvg_q_low,       low)
    array.push(fvg_q_idx,       bar_index)
    array.push(fvg_q_prev_high, last_non_inside_high)
    array.push(fvg_q_prev_low,  last_non_inside_low)
    last_non_inside_high := high
    last_non_inside_low  := low
    while array.size(fvg_q_high) > 3
        array.shift(fvg_q_high)
        array.shift(fvg_q_low)
        array.shift(fvg_q_idx)
        array.shift(fvg_q_prev_high)
        array.shift(fvg_q_prev_low)

    if array.size(fvg_q_high) == 3
        int sz = 3

        float h_c1   = array.get(fvg_q_high,      0)
        float l_c1   = array.get(fvg_q_low,       0)
        int   i_c1   = array.get(fvg_q_idx,       0)
        float h_prev = array.get(fvg_q_prev_high, 0)
        float l_prev = array.get(fvg_q_prev_low,  0)
        float h_c2   = array.get(fvg_q_high,      1)
        float l_c2   = array.get(fvg_q_low,       1)
        int   i_c2   = array.get(fvg_q_idx,       1)
        float h_c3   = array.get(fvg_q_high,      2)
        float l_c3   = array.get(fvg_q_low,       2)
        int   i_c3   = array.get(fvg_q_idx,       2)

        bool bull_fvg = l_c3 > h_c1
        bool bear_fvg = h_c3 < l_c1

        // Exclude gaps: if there's a gap between c1-c2 or c2-c3, clip FVG to c2 body
        // Bullish: gap between c1 and c2 means real FVG top is l_c2 (not h_c1)
        //          gap between c2 and c3 means real FVG bottom is h_c2 (not l_c3)
        float bull_fvg_top = l_c2 > h_c1 ? l_c2 : h_c1   // clip top if gap between c1-c2
        float bull_fvg_bot = l_c3 > h_c2 ? h_c2 : l_c3   // clip bot if gap between c2-c3
        bool  bull_fvg_real = bull_fvg and bull_fvg_bot > bull_fvg_top

        float bear_fvg_bot = h_c2 < l_c1 ? h_c2 : l_c1   // clip bot if gap between c1-c2
        float bear_fvg_top = h_c3 < l_c2 ? l_c2 : h_c3   // clip top if gap between c2-c3
        bool  bear_fvg_real = bear_fvg and bear_fvg_bot > bear_fvg_top

        // Draw FVG if enabled
        if fvg_show
            if bull_fvg_real
                b = box.new(i_c1, bull_fvg_bot, i_c3, bull_fvg_top,
                     border_color=na, bgcolor=fvg_bull_color, extend=extend.none)
                fvg_add(b, bull_fvg_bot, bull_fvg_top, fvg_bull_color)
            else if bear_fvg_real
                b = box.new(i_c1, bear_fvg_bot, i_c3, bear_fvg_top,
                     border_color=na, bgcolor=fvg_bear_color, extend=extend.none)
                fvg_add(b, bear_fvg_bot, bear_fvg_top, fvg_bear_color)

        // OB detection
        if ob_show
            bool c1_swept_bull = not na(l_prev) and l_c1 < l_prev
            bool c1_swept_bear = not na(h_prev) and h_c1 > h_prev
            bool c2_swept_bull = l_c2 < l_c1
            bool c2_swept_bear = h_c2 > h_c1
            bool ob_just_drawn = false

            bool c2_is_absorption = c2_swept_bull and c2_swept_bear

            // Step 1: check FVG against active candidates
            if bull_fvg_real and ob_bull_cand
                if c2_is_absorption
                    // c2 absorbed c1 — cancel, absorption will launch its own candidate as c1
                    ob_bull_cand := false
                    ob_bear_cand := false
                else if c2_swept_bull and c1_swept_bull
                    ob_add(i_c2, h_c2, l_c2, true)
                    ob_bull_cand := false
                    ob_bear_cand := false
                    ob_just_drawn := true
                else
                    ob_add(i_c1, h_c1, l_c1, true)
                    ob_bull_cand := false
                    ob_bear_cand := false
                    ob_just_drawn := true

            else if bear_fvg_real and ob_bear_cand
                if c2_is_absorption
                    ob_bull_cand := false
                    ob_bear_cand := false
                else if c2_swept_bear and c1_swept_bear
                    ob_add(i_c2, h_c2, l_c2, false)
                    ob_bull_cand := false
                    ob_bear_cand := false
                    ob_just_drawn := true
                else
                    ob_add(i_c1, h_c1, l_c1, false)
                    ob_bull_cand := false
                    ob_bear_cand := false
                    ob_just_drawn := true

            // Step 2: update candidates from sweeps on c1 and c2
            // Skip if OB was just drawn this iteration
            if not ob_just_drawn
                if c1_swept_bull
                    ob_bull_cand := true
                if c1_swept_bear
                    ob_bear_cand := true
                // Also check c2 sweep — so when c2 becomes c1 of next trio, candidate is ready
                bool c2_prev_bull = not na(l_prev) and l_c2 < l_c1
                bool c2_prev_bear = not na(h_prev) and h_c2 > h_c1
                if c2_prev_bull
                    ob_bull_cand := true
                if c2_prev_bear
                    ob_bear_cand := true

// Every bar: extend active OB boxes, check mitigation
if ob_show and array.size(ob_blocks) > 0
    for i = 0 to array.size(ob_blocks) - 1
        OBBlock ob = array.get(ob_blocks, i)
        if bar_index > ob.created_bar
            if not ob.mitigated
                // Active block — extend right and check for first touch
                box.set_right(ob.b, bar_index)
                bool mit = ob.is_bull ? low <= ob.top : high >= ob.bot
                if mit
                    ob.mitigated  := true
                    ob.run_high   := high
                    ob.run_low    := low
                    // Check if single bar already fully covers the zone
                    if ob.run_high >= ob.top and ob.run_low <= ob.bot
                        ob.fully_covered := true
                    if ob_hide_mit
                        box.delete(ob.b)
                    else
                        box.set_bgcolor(ob.b, ob_mit_color)
                        if ob.fully_covered and ob_hide_full
                            box.delete(ob.b)
                    if alert_mit_ob
                        alert(alert_prefix + "Order block mitigated", alert.freq_once_per_bar)
            else if not ob.fully_covered and ob_extend_mit and not ob_hide_mit
                // Mitigated but not fully covered — keep extending while accumulating range
                box.set_right(ob.b, bar_index)
                ob.run_high := math.max(ob.run_high, high)
                ob.run_low  := math.min(ob.run_low,  low)
                if ob.run_high >= ob.top and ob.run_low <= ob.bot
                    ob.fully_covered := true
                    if ob_hide_full
                        box.delete(ob.b)

// ============================================================
// PDH / PDL
// ============================================================
// Pre-fetch daily data for up to 30 days (max setting)
float[] pdhl_d_high = array.from(
     request.security(syminfo.tickerid, "D", high[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[2],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[3],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[4],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[5],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[6],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[7],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[8],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[9],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", high[10], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on))

float[] pdhl_d_low = array.from(
     request.security(syminfo.tickerid, "D", low[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[2],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[3],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[4],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[5],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[6],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[7],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[8],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[9],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", low[10], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on))

int[] pdhl_d_time = array.from(
     request.security(syminfo.tickerid, "D", time[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[2],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[3],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[4],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[5],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[6],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[7],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[8],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[9],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on),
     request.security(syminfo.tickerid, "D", time[10], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on))

var label[] pdhl_labels = array.new_label()

// Track running high/low since each day boundary
// _ph[0] = max high since start of today, _ph[1] = since start of yesterday, etc.
var float pdhl_ph0 = na
var float pdhl_ph1 = na
var float pdhl_ph2 = na
var float pdhl_ph3 = na
var float pdhl_ph4 = na
var float pdhl_ph5 = na
var float pdhl_ph6 = na
var float pdhl_ph7 = na
var float pdhl_ph8 = na
var float pdhl_ph9 = na
var float pdhl_pl0 = na
var float pdhl_pl1 = na
var float pdhl_pl2 = na
var float pdhl_pl3 = na
var float pdhl_pl4 = na
var float pdhl_pl5 = na
var float pdhl_pl6 = na
var float pdhl_pl7 = na
var float pdhl_pl8 = na
var float pdhl_pl9 = na

bool _pdhl_new_day = ta.change(time("D")) != 0

if _pdhl_new_day
    pdhl_ph9 := pdhl_ph8
    pdhl_ph8 := pdhl_ph7
    pdhl_ph7 := pdhl_ph6
    pdhl_ph6 := pdhl_ph5
    pdhl_ph5 := pdhl_ph4
    pdhl_ph4 := pdhl_ph3
    pdhl_ph3 := pdhl_ph2
    pdhl_ph2 := pdhl_ph1
    pdhl_ph1 := pdhl_ph0
    pdhl_ph0 := high
    pdhl_pl9 := pdhl_pl8
    pdhl_pl8 := pdhl_pl7
    pdhl_pl7 := pdhl_pl6
    pdhl_pl6 := pdhl_pl5
    pdhl_pl5 := pdhl_pl4
    pdhl_pl4 := pdhl_pl3
    pdhl_pl3 := pdhl_pl2
    pdhl_pl2 := pdhl_pl1
    pdhl_pl1 := pdhl_pl0
    pdhl_pl0 := low
else
    pdhl_ph0 := na(pdhl_ph0) ? high : math.max(pdhl_ph0, high)
    pdhl_pl0 := na(pdhl_pl0) ? low  : math.min(pdhl_pl0, low)

// Accumulate: each older bucket includes all newer ones too
// ph1 should be max(today, yesterday) for full lookback since day 1 ended
float pdhl_cum_h0 = pdhl_ph0
float pdhl_cum_h1 = math.max(nz(pdhl_ph0), nz(pdhl_ph1))
float pdhl_cum_h2 = math.max(pdhl_cum_h1, nz(pdhl_ph2))
float pdhl_cum_h3 = math.max(pdhl_cum_h2, nz(pdhl_ph3))
float pdhl_cum_h4 = math.max(pdhl_cum_h3, nz(pdhl_ph4))
float pdhl_cum_h5 = math.max(pdhl_cum_h4, nz(pdhl_ph5))
float pdhl_cum_h6 = math.max(pdhl_cum_h5, nz(pdhl_ph6))
float pdhl_cum_h7 = math.max(pdhl_cum_h6, nz(pdhl_ph7))
float pdhl_cum_h8 = math.max(pdhl_cum_h7, nz(pdhl_ph8))
float pdhl_cum_h9 = math.max(pdhl_cum_h8, nz(pdhl_ph9))

float pdhl_cum_l0 = pdhl_pl0
float pdhl_cum_l1 = math.min(nz(pdhl_pl0, 1e10), nz(pdhl_pl1, 1e10))
float pdhl_cum_l2 = math.min(pdhl_cum_l1, nz(pdhl_pl2, 1e10))
float pdhl_cum_l3 = math.min(pdhl_cum_l2, nz(pdhl_pl3, 1e10))
float pdhl_cum_l4 = math.min(pdhl_cum_l3, nz(pdhl_pl4, 1e10))
float pdhl_cum_l5 = math.min(pdhl_cum_l4, nz(pdhl_pl5, 1e10))
float pdhl_cum_l6 = math.min(pdhl_cum_l5, nz(pdhl_pl6, 1e10))
float pdhl_cum_l7 = math.min(pdhl_cum_l6, nz(pdhl_pl7, 1e10))
float pdhl_cum_l8 = math.min(pdhl_cum_l7, nz(pdhl_pl8, 1e10))
float pdhl_cum_l9 = math.min(pdhl_cum_l8, nz(pdhl_pl9, 1e10))

float[] pdhl_cum_highs = array.from(pdhl_cum_h0, pdhl_cum_h1, pdhl_cum_h2, pdhl_cum_h3, pdhl_cum_h4,
     pdhl_cum_h5, pdhl_cum_h6, pdhl_cum_h7, pdhl_cum_h8, pdhl_cum_h9)
float[] pdhl_cum_lows  = array.from(pdhl_cum_l0, pdhl_cum_l1, pdhl_cum_l2, pdhl_cum_l3, pdhl_cum_l4,
     pdhl_cum_l5, pdhl_cum_l6, pdhl_cum_l7, pdhl_cum_l8, pdhl_cum_l9)

if alert_pdhl
    int days_a = math.min(pdhl_days, 10)
    for d = 0 to days_a - 1
        float d_high = array.get(pdhl_d_high, d)
        float d_low  = array.get(pdhl_d_low,  d)
        float cum_h  = array.get(pdhl_cum_highs, d)
        float cum_l  = array.get(pdhl_cum_lows,  d)
        // Only alert if level is NOT already mitigated (same check as display)
        bool high_mit = cum_h >= d_high and cum_l <= d_high
        bool low_mit  = cum_h >= d_low  and cum_l <= d_low
        if not na(d_high) and not high_mit and low < d_high and high > d_high
            alert(alert_prefix + "PDH level crossed", alert.freq_once_per_bar)
        if not na(d_low) and not low_mit and low < d_low and high > d_low
            alert(alert_prefix + "PDL level crossed", alert.freq_once_per_bar)

if pdhl_show and barstate.islast
    for lb in pdhl_labels
        label.delete(lb)
    array.clear(pdhl_labels)

    int days = math.min(pdhl_days, 10)
    for d = 0 to days - 1
        float d_high = array.get(pdhl_d_high, d)
        float d_low  = array.get(pdhl_d_low,  d)
        int   d_time = array.get(pdhl_d_time,  d)

        if na(d_high) or na(d_low)
            continue

        float cum_h = array.get(pdhl_cum_highs, d)
        float cum_l = array.get(pdhl_cum_lows,  d)

        bool high_mit = cum_h >= d_high and cum_l <= d_high
        bool low_mit  = cum_h >= d_low  and cum_l <= d_low

        string h_text = d == 0 ? "— PDH" : "— " + str.tostring(month(d_time + 43200000, syminfo.timezone)) + "/" + str.tostring(dayofmonth(d_time + 43200000, syminfo.timezone))
        string l_text = d == 0 ? "— PDL" : "— " + str.tostring(month(d_time + 43200000, syminfo.timezone)) + "/" + str.tostring(dayofmonth(d_time + 43200000, syminfo.timezone))

        if not high_mit
            lbl = label.new(bar_index, d_high, h_text,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=color.new(color.white, 100), textcolor=pdhl_color,
                 style=label.style_label_left, size=size.small)
            array.push(pdhl_labels, lbl)

        if not low_mit
            lbl = label.new(bar_index, d_low, l_text,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=color.new(color.white, 100), textcolor=pdhl_color,
                 style=label.style_label_left, size=size.small)
            array.push(pdhl_labels, lbl)

// ============================================================
// MARKET SESSIONS
// ============================================================
sess_hhmm_to_minutes(string hhmm) =>
    int colonPos = str.pos(hhmm, ":")
    int h = 0
    int m = 0
    if colonPos >= 0
        h := int(str.tonumber(str.substring(hhmm, 0, colonPos)))
        m := int(str.tonumber(str.substring(hhmm, colonPos + 1)))
    else
        float val = str.tonumber(hhmm)
        h := int(math.floor(val / 100))
        m := int(val) - h * 100
    h * 60 + m

sess_bar_minutes() =>
    int h = hour(time, "UTC")
    int m = minute(time, "UTC")
    h * 60 + m

sess_in_range(int barMin, int startMin, int endMin) =>
    endMin >= startMin ? barMin >= startMin and barMin <= endMin : barMin >= startMin or barMin <= endMin

// ============================================================
// OPEN DAY — STATE & LOGIC
// ============================================================
var float od_level           = na
var bool  od_triggered_today = false
var label od_label           = na

// Reset trigger on UTC midnight (not broker day boundary)
bool _od_new_day = ta.change(dayofmonth(time, "UTC")) != 0
if _od_new_day
    od_triggered_today := false

// Fix the OD level at the configured UTC time
if od_show
    int od_target_min = sess_hhmm_to_minutes(od_time)
    int od_bar_min    = sess_bar_minutes()
    if not od_triggered_today and od_bar_min >= od_target_min
        od_level           := open
        od_triggered_today := true

// Draw label on last bar only (single label, always replaced)
if od_show and barstate.islast and not na(od_level)
    if not na(od_label)
        label.delete(od_label)
    od_label := label.new(bar_index, od_level, "— OD",
         xloc=xloc.bar_index, yloc=yloc.price,
         color=color.new(color.white, 100), textcolor=od_color,
         style=label.style_label_left, size=size.small)

type SessBox
    box   b
    label lbl
    line  top_ln
    line  bot_ln
    int   startTime
    float hi
    float lo
    bool  hi_alerted
    bool  lo_alerted
    line  top_line
    line  bot_line

// Each session stores an array of boxes (one per day, up to sess_days)
var SessBox[] sess_a_boxes  = array.new<SessBox>()
var SessBox[] sess_f_boxes  = array.new<SessBox>()
var SessBox[] sess_l_boxes  = array.new<SessBox>()
var SessBox[] sess_ny_boxes = array.new<SessBox>()
var SessBox[] sess_5_boxes  = array.new<SessBox>()

// Keep backward compat for alert function
var SessBox sess_a_box  = na
var SessBox sess_f_box  = na
var SessBox sess_l_box  = na
var SessBox sess_ny_box = na
var SessBox sess_5_box  = na

sess_update_multi(SessBox[] sbs, bool enabled, bool inSession, color col, string lbl_text) =>
    SessBox cur = array.size(sbs) > 0 ? array.get(sbs, array.size(sbs) - 1) : na
    if enabled and sess_show
        if inSession
            int today = math.floor(time / 86400000)
            if na(cur) or cur.startTime != today
                // New session day — create new box (no border) + two border lines
                box  newBox = box.new(time, high, time, low,
                     border_color=na,
                     bgcolor=col, extend=extend.none, xloc=xloc.bar_time)
                label newLbl = label.new(time, high, lbl_text,
                     xloc=xloc.bar_time, yloc=yloc.price,
                     color=color.new(color.white, 100), textcolor=color.new(col, 0),
                     style=label.style_none, size=size.small)
                line top_ln = sess_border_show ? line.new(time, high, time, high,
                     xloc=xloc.bar_time, color=color.new(col, 0),
                     width=sess_border_width, style=sess_border_style) : na
                line bot_ln = sess_border_show ? line.new(time, low, time, low,
                     xloc=xloc.bar_time, color=color.new(col, 0),
                     width=sess_border_width, style=sess_border_style) : na
                SessBox newSb = SessBox.new(newBox, newLbl, top_ln, bot_ln, today, high, low, false, false)
                array.push(sbs, newSb)
                while array.size(sbs) > sess_days
                    SessBox old = array.shift(sbs)
                    box.delete(old.b)
                    label.delete(old.lbl)
                    if not na(old.top_ln)
                        line.delete(old.top_ln)
                    if not na(old.bot_ln)
                        line.delete(old.bot_ln)
            else
                // Update current day box
                float newHi = math.max(cur.hi, high)
                float newLo = math.min(cur.lo, low)
                cur.hi := newHi
                cur.lo := newLo
                box.set_top(cur.b, newHi)
                box.set_bottom(cur.b, newLo)
                box.set_right(cur.b, time)
                int leftT = box.get_left(cur.b)
                int midT  = math.round((leftT + time) / 2)
                label.set_x(cur.lbl, midT)
                label.set_y(cur.lbl, newHi)
                // Update border lines
                if not na(cur.top_ln)
                    line.set_x2(cur.top_ln, time)
                    line.set_y1(cur.top_ln, newHi)
                    line.set_y2(cur.top_ln, newHi)
                if not na(cur.bot_ln)
                    line.set_x2(cur.bot_ln, time)
                    line.set_y1(cur.bot_ln, newLo)
                    line.set_y2(cur.bot_ln, newLo)
    // Return current box for alert compatibility
    array.size(sbs) > 0 ? array.get(sbs, array.size(sbs) - 1) : na

if sess_show
    int barMin = sess_bar_minutes()

    int sess_a_s  = sess_hhmm_to_minutes(sess_a_start)
    int sess_a_e  = sess_hhmm_to_minutes(sess_a_end)
    int sess_f_s  = sess_hhmm_to_minutes(sess_f_start)
    int sess_f_e  = sess_hhmm_to_minutes(sess_f_end)
    int sess_l_s  = sess_hhmm_to_minutes(sess_l_start)
    int sess_l_e  = sess_hhmm_to_minutes(sess_l_end)
    int sess_ny_s = sess_hhmm_to_minutes(sess_ny_start)
    int sess_ny_e = sess_hhmm_to_minutes(sess_ny_end)
    int sess_5_s  = sess_hhmm_to_minutes(sess_5_start)
    int sess_5_e  = sess_hhmm_to_minutes(sess_5_end)

    sess_a_box  := sess_update_multi(sess_a_boxes,  sess_a_show,  sess_in_range(barMin, sess_a_s,  sess_a_e),  sess_a_color,  sess_a_label)
    sess_f_box  := sess_update_multi(sess_f_boxes,  sess_f_show,  sess_in_range(barMin, sess_f_s,  sess_f_e),  sess_f_color,  sess_f_label)
    sess_l_box  := sess_update_multi(sess_l_boxes,  sess_l_show,  sess_in_range(barMin, sess_l_s,  sess_l_e),  sess_l_color,  sess_l_label)
    sess_ny_box := sess_update_multi(sess_ny_boxes, sess_ny_show, sess_in_range(barMin, sess_ny_s, sess_ny_e), sess_ny_color, sess_ny_label)
    sess_5_box  := sess_update_multi(sess_5_boxes,  sess_5_show,  sess_in_range(barMin, sess_5_s,  sess_5_e),  sess_5_color,  sess_5_label)

// Session alerts — only for closed sessions (not currently active)
sess_check_alert(SessBox sb, string name, bool enabled, bool inSess) =>
    if alert_sessions and enabled and not inSess and not na(sb)
        if not na(sb.hi) and not sb.hi_alerted and high >= sb.hi and low <= sb.hi
            alert(alert_prefix + name + " session high crossed", alert.freq_once_per_bar)
            sb.hi_alerted := true
        if not na(sb.lo) and not sb.lo_alerted and high >= sb.lo and low <= sb.lo
            alert(alert_prefix + name + " session low crossed",  alert.freq_once_per_bar)
            sb.lo_alerted := true

if sess_show
    int barMin2 = sess_bar_minutes()
    int sa_s = sess_hhmm_to_minutes(sess_a_start)
    int sa_e = sess_hhmm_to_minutes(sess_a_end)
    int sf_s = sess_hhmm_to_minutes(sess_f_start)
    int sf_e = sess_hhmm_to_minutes(sess_f_end)
    int sl_s = sess_hhmm_to_minutes(sess_l_start)
    int sl_e = sess_hhmm_to_minutes(sess_l_end)
    int sn_s = sess_hhmm_to_minutes(sess_ny_start)
    int sn_e = sess_hhmm_to_minutes(sess_ny_end)
    int s5_s = sess_hhmm_to_minutes(sess_5_start)
    int s5_e = sess_hhmm_to_minutes(sess_5_end)
    sess_check_alert(sess_a_box,  sess_a_label,  sess_a_show,  sess_in_range(barMin2, sa_s, sa_e))
    sess_check_alert(sess_f_box,  sess_f_label,  sess_f_show,  sess_in_range(barMin2, sf_s, sf_e))
    sess_check_alert(sess_l_box,  sess_l_label,  sess_l_show,  sess_in_range(barMin2, sl_s, sl_e))
    sess_check_alert(sess_ny_box, sess_ny_label, sess_ny_show, sess_in_range(barMin2, sn_s, sn_e))
    sess_check_alert(sess_5_box,  sess_5_label,  sess_5_show,  sess_in_range(barMin2, s5_s, s5_e))

// ============================================================
// TREND FILTER
// ============================================================

// WaveTrend oscillator function
// Computes WT1: EMA of a normalised channel index built on HLC3
f_tf_wt1(int chlen, int avglen) =>
    float src = hlc3
    float esa = ta.ema(src, chlen)
    float de  = ta.ema(math.abs(src - esa), chlen)
    float ci  = (src - esa) / (0.015 * de)
    ta.ema(ci, avglen)

// Combined function: returns [WT realtime, WT confirmed (prev closed bar)]
// Allows a single request.security() call per TF instead of two separate ones
f_tf_combo(int chlen, int avglen) =>
    float wt  = f_tf_wt1(chlen, avglen)
    float wtc = wt[1]
    [wt, wtc]

// Request WT1 from each selected timeframe.
// lookahead_off: value updates only when the HTF bar closes.
// This is correct for trading decisions — no future data leak.
// History in the simulator matches real-time behaviour exactly.
// One request.security() per TF returns [WT realtime, WT confirmed]
// Reduces total security() calls from 6 to 3 for this block
[tf_wt1_1, tf_wt1_1c] = request.security(syminfo.tickerid, tf_1, f_tf_combo(tf_wt_ch_len, tf_wt_avg_len), lookahead=barmerge.lookahead_off)
[tf_wt1_2, tf_wt1_2c] = request.security(syminfo.tickerid, tf_2, f_tf_combo(tf_wt_ch_len, tf_wt_avg_len), lookahead=barmerge.lookahead_off)
[tf_wt1_3, tf_wt1_3c] = request.security(syminfo.tickerid, tf_3, f_tf_combo(tf_wt_ch_len, tf_wt_avg_len), lookahead=barmerge.lookahead_off)

// Active WT values: confirmed (no repaint) or real-time based on tf_confirm setting
float wt1 = tf_confirm ? tf_wt1_1c : tf_wt1_1
float wt2 = tf_confirm ? tf_wt1_2c : tf_wt1_2
float wt3 = tf_confirm ? tf_wt1_3c : tf_wt1_3

// A disabled timeframe is treated as neutral (does not block alignment)
bool tf_bull1 = not tf_1_enable or wt1 > 0
bool tf_bull2 = not tf_2_enable or wt2 > 0
bool tf_bull3 = not tf_3_enable or wt3 > 0

bool tf_bear1 = not tf_1_enable or wt1 < 0
bool tf_bear2 = not tf_2_enable or wt2 < 0
bool tf_bear3 = not tf_3_enable or wt3 < 0

// At least one timeframe must be enabled for a signal to fire
bool tf_any_enabled = tf_1_enable or tf_2_enable or tf_3_enable

bool tf_all_bull = tf_show and tf_any_enabled and tf_bull1 and tf_bull2 and tf_bull3
bool tf_all_bear = tf_show and tf_any_enabled and tf_bear1 and tf_bear2 and tf_bear3

// Paint background: green on full bullish alignment, red on full bearish, transparent otherwise
bgcolor(tf_all_bull ? tf_bull_color : tf_all_bear ? tf_bear_color : na, title="Trend Filter Background")


// Trend alert — fires on bar close whenever the background state changes
// Covers all six transitions: uptrend <-> neutral <-> downtrend and direct flip
//
// IMPORTANT: tf_all_bull/bear are derived from request.security values that step
// only when the higher TF bar closes. Using [1] on the current chart bar would
// compare two consecutive chart bars that carry the same HTF value — causing
// missed or spurious alerts. Instead we store the last CONFIRMED state in a
// var and compare against it explicitly.
int tf_state = tf_all_bull ? 1 : tf_all_bear ? -1 : 0

var int tf_state_confirmed = 0  // last state seen on a confirmed bar

tf_state_str(int s) =>
    s == 1 ? "uptrend" : s == -1 ? "downtrend" : "neutral"

if barstate.isconfirmed
    if alert_trend and tf_state != tf_state_confirmed
        string msg = alert_prefix + "Trend changed: " + tf_state_str(tf_state_confirmed) + " -> " + tf_state_str(tf_state)
        alert(msg, alert.freq_once_per_bar_close)
    tf_state_confirmed := tf_state


// ============================================================
// DASHBOARD

// ============================================================
// DASHBOARD
// ============================================================

// Convert position string to Pine table position constant
db_pos_val() =>
    switch db_position
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

// Convert text size string to Pine size constant
db_size_val() =>
    switch db_text_size
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        =>         size.small

// Cell background colour for a WT value:
//   -10..+10  → neutral light grey
//   ±10..±40  → weak green / weak red (readable on white background)
//   beyond ±40 → saturated green / red
db_wt_bg(float wt) =>
    float abs_wt = math.abs(wt)
    if abs_wt <= 10
        color.new(color.gray, 75)
    else if abs_wt <= 40
        wt > 0 ? color.new(color.green, 60) : color.new(color.red, 60)
    else
        wt > 0 ? color.new(color.green, 30) : color.new(color.red, 30)



// Human-readable label for common timeframe strings
db_tf_label(string tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1h"
        "120" => "2h"
        "180" => "3h"
        "240" => "4h"
        "360" => "6h"
        "480" => "8h"
        "720" => "12h"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => tf

var table db_tbl = na

if db_show and barstate.islast
    // Count visible rows: one per enabled TF
    int rows = 1
    if tf_1_enable
        rows := rows + 1
    if tf_2_enable
        rows := rows + 1
    if tf_3_enable
        rows := rows + 1

    // Delete and recreate so row count stays correct after settings change
    if not na(db_tbl)
        table.delete(db_tbl)

    db_tbl := table.new(
         db_pos_val(), 3, rows,
         bgcolor      = color.white,
         border_color = color.new(color.gray, 60),
         border_width = 1,
         frame_color  = color.new(color.gray, 40),
         frame_width  = 1)

    string sz    = db_size_val()
    color  white = color.white
    color  black = color.black
    int    r     = 0

    // Fill one WaveTrend row inline
    if tf_1_enable
        string v1 = str.tostring(math.round(wt1, 1))
        table.cell(db_tbl, 0, r, db_tf_label(tf_1), text_color=black, text_size=sz, bgcolor=white)
        table.cell(db_tbl, 1, r, v1,                text_color=black, text_halign=text.align_right, text_size=sz, bgcolor=db_wt_bg(wt1))
        r := r + 1

    if tf_2_enable
        string v2 = str.tostring(math.round(wt2, 1))
        table.cell(db_tbl, 0, r, db_tf_label(tf_2), text_color=black, text_size=sz, bgcolor=white)
        table.cell(db_tbl, 1, r, v2,                text_color=black, text_halign=text.align_right, text_size=sz, bgcolor=db_wt_bg(wt2))
        r := r + 1

    if tf_3_enable
        string v3 = str.tostring(math.round(wt3, 1))
        table.cell(db_tbl, 0, r, db_tf_label(tf_3), text_color=black, text_size=sz, bgcolor=white)
        table.cell(db_tbl, 1, r, v3,                text_color=black, text_halign=text.align_right, text_size=sz, bgcolor=db_wt_bg(wt3))
        r := r + 1
````
