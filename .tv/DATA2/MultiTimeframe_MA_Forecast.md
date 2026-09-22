<!-- tradingview-pine-id: PUB;df10d83fa32d40c886bf1db5adf11166 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Timeframe MA Forecast

Source: https://www.tradingview.com/script/A2tQnlxC-Multi-Timeframe-MA-Forecast/

## Description

Multi-Timeframe MA Forecast

This indicator combines two things that other MA tools don't: it plots a moving average from any timeframe onto your chart using proper multi-timeframe handling, and it projects that average forward under a simple assumption, that price holds at the current value while the calculation window rolls ahead. The result is a forward view of where the MA is headed if price goes nowhere, which is a different and useful question from where the MA has been.

Why forecast a moving average

An MA's slope isn't entirely driven by "recent price action" in the vague sense traders usually mean. At any given bar, the slope is set by one comparison: the price entering the average versus the price leaving it. A rising 50-day SMA can flatten or roll over not because anything new happened today, but because the price from 50 days ago, now dropping out of the window, was unusually high or low. That effect is knowable in advance since it depends on price action that already happened.

This matters because many systematic and algorithmic strategies key off MA slope and MA crossovers as regime filters. If you can see that a large gap is about to roll out of a 200-period window, you can anticipate a slope change before it shows up on the indicator itself, rather than reacting to it after the fact.

The forecast is not a price prediction. It answers a narrower, mechanical question: given the prices already in the pipeline, what does this average do next if price simply holds still.

Why MA slope matters for support and resistance

Slope changes the character of an MA:

- Price above a rising MA: the MA tends to act as support
- Price below a rising MA: the MA tends to act as a magnet, pulling price back up toward it
- Price below a falling MA: the MA tends to act as resistance
- Price above a falling MA: the MA tends to act as a magnet, pulling price back down toward it

A forecasted slope flip is an early signal that the MA's role relative to price may be about to change.

How the timeframe handling works

Set the Timeframe higher, lower, or equal to your chart's. The average is calculated on that timeframe using TradingView's multi-timeframe request functions, so the current bar always reflects the true live value of the higher-timeframe average, including the period still forming.

When the Timeframe is higher than the chart, history is drawn as a stairstep: once a higher-timeframe period closes, its final value is drawn back across the bars of that period. This is retroactive, the value shown mid-period was not knowable until that period actually closed, and it gives the clean, stepped look most MTF overlays use. When the Timeframe is the same as or lower than the chart, there's no period to wait for, so the line simply reflects the true value on every bar as it happens.

Either way, the forecast always starts from the current, fully up-to-date value of the average.

Forecast styling is separate from the MA's

The moving average uses its own Line Thickness and MA Line Style inputs, and the forecast has a matching, independently-set Forecast Line Style. These are exposed as inputs rather than through the native Style tab because the forecast is built from a drawing object rather than a plotted series, and drawing objects can't be styled from that tab. Giving the MA its own matching inputs, rather than mixing native Style-tab controls with input-based ones, keeps both fully and consistently customizable.

Supported MA types

SMA (simple), EMA (exponential), WMA (weighted), and HMA (Hull) are supported, each forecast using that type's own real recurrence rather than a shared approximation. EMA and SMA are the cheapest to compute; WMA and HMA require tracking the full calculation window at every forecast step.

Memory limitations on extreme timeframe ratios

Pulling multi-timeframe history through TradingView's request functions has a memory cost that scales with the ratio between the chart timeframe and MA timeframe, particularly when the MA timeframe is much lower than the chart's. In practice:

- EMA has no meaningful limit, since it doesn't require historical window data
- SMA can handle roughly double the timeframe ratio or MA length that WMA and HMA can, before hitting TradingView's memory ceiling
- Very extreme combinations, for example a 1-hour MA on a weekly chart with a long length, can hit a runtime memory error

If you see a memory error, try a coarser MA timeframe, a shorter MA length, switching to EMA or SMA, or lowering the Forecast % input, all of which reduce the amount of historical data the script needs to hold.

---

Every request.security() call in this script that uses barmerge.lookahead_on does so only on a history-offset expression, per TradingView's documented pattern for retrieving higher-timeframe data without lookahead bias. No un-offset higher-timeframe value is ever requested with lookahead_on.

---

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe MA Forecast", shorttitle="MTF MA Forecast", overlay=true, max_polylines_count=4, max_labels_count=2)

ma_len     = input.int(50,  "MA Length",      minval=2,  group="MA Settings", tooltip="Number of periods in the moving average on the Timeframe below.")
ma_type    = input.string("SMA", "MA Type", options=["SMA", "EMA", "WMA", "HMA"], group="MA Settings", tooltip="SMA — simple\nEMA — exponential\nWMA — linearly weighted\nHMA — Hull")
src        = input.source(close, "Source", group="MA Settings", display=display.data_window, tooltip="Price series the average is built from.")
tf         = input.timeframe("", "Timeframe", group="MA Settings", tooltip="Timeframe the moving average is calculated on.\n\nHigher than the chart draws a stepped line, holding each period's value until it closes.\n\nLower than the chart is sampled once per bar.")

forecast    = input.int(70, "Forecast % of MA Length", minval=0, maxval=100, step=5, group="Forecast", display=display.data_window, tooltip="How far ahead to project, as a percentage of MA Length. At 70% a 50-period average projects 35 periods forward.\n\nThe projection holds price flat at the current Source value and rolls the window forward, so it shows where the average goes if price stops moving — not a price prediction. Set to 0 to hide the forecast.")
label_size  = input.string("Off", "Forecast Label Size", options=["Off", "Tiny", "Small", "Normal", "Large", "Huge"], group="Forecast", display=display.data_window, tooltip="Prints the projected value at the end of the forecast.")

ma_color    = input.color(color.blue, "MA Color", group="MA Style", display=display.data_window, tooltip="Color of the moving average line.")
fc_color    = input.color(color.new(color.blue,40), "Forecast Color", group="MA Style", display=display.data_window, tooltip="Color of the forecast line.")
ma_width    = input.int(2, "Line Thickness", options=[1, 2, 3, 4], group="MA Style", display=display.data_window, tooltip="Line thickness.")
ma_style_in = input.string("Solid", "MA Line Style", options=["Solid", "Dashed", "Dotted"], group="MA Style", display=display.data_window, tooltip="Style of the moving average line.")
fc_style_in = input.string("Solid", "Forecast Line Style", options=["Solid", "Dashed", "Dotted"], group="MA Style", display=display.data_window, tooltip="Style of the forecast line.")

ma_plot_style = ma_style_in == "Solid" ? plot.linestyle_solid : ma_style_in == "Dashed" ? plot.linestyle_dashed : plot.linestyle_dotted
ma_line_style = ma_style_in == "Solid" ? line.style_solid : ma_style_in == "Dashed" ? line.style_dashed : line.style_dotted
fc_line_style = fc_style_in == "Solid" ? line.style_solid : fc_style_in == "Dashed" ? line.style_dashed : line.style_dotted

tf_eff = tf == "" ? timeframe.period : tf

hma_half_len = math.floor(ma_len / 2)
hma_sqrt_len = math.floor(math.sqrt(ma_len))

tf_seconds    = timeframe.in_seconds(tf_eff)
chart_seconds = timeframe.in_seconds(timeframe.period)
is_coarser    = tf_seconds > chart_seconds
is_finer      = tf_seconds < chart_seconds

int fc_steps = math.max(0, math.min(ma_len - 1, int(ma_len * forecast / 100)))

f_hist(val, len) =>
    var arr = array.new_float(0)
    array.unshift(arr, val)
    if array.size(arr) > len
        array.pop(arr)
    arr

f_wma_arr(arr, len) =>
    float sum  = 0.0
    float wsum = 0.0
    for i = 0 to len - 1
        w = len - i
        sum  += array.get(arr, i) * w
        wsum += w
    sum / wsum

f_labelSize(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

f_medianInt(arr) =>
    int n = array.size(arr)
    int r = na
    if n > 0
        c = array.copy(arr)
        array.sort(c)
        r := array.get(c, int(n / 2))
    r

f_step(work_src, work_raw, work_drop, proj, c) =>
    float new_proj = proj
    if ma_type == "SMA"
        float dropped = array.size(work_drop) > 0 ? array.pop(work_drop) : c
        new_proj := proj + (c - dropped) / ma_len
    else if ma_type == "EMA"
        float alpha = 2.0 / (ma_len + 1)
        new_proj := alpha * c + (1 - alpha) * proj
    else if ma_type == "WMA"
        array.unshift(work_src, c)
        if array.size(work_src) > ma_len + 4
            array.pop(work_src)
        new_proj := f_wma_arr(work_src, ma_len)
    else
        array.unshift(work_src, c)
        float wma1 = f_wma_arr(work_src, hma_half_len)
        float wma2 = f_wma_arr(work_src, ma_len)
        float raw  = 2 * wma1 - wma2
        array.unshift(work_raw, raw)
        new_proj := f_wma_arr(work_raw, hma_sqrt_len)
        if array.size(work_src) > ma_len + hma_sqrt_len + 4
            array.pop(work_src)
        if array.size(work_raw) > hma_sqrt_len + 4
            array.pop(work_raw)
    new_proj

ma_expr = ma_type == "SMA" ? ta.sma(src, ma_len) : ma_type == "EMA" ? ta.ema(src, ma_len) : ma_type == "WMA" ? ta.wma(src, ma_len) : ta.hma(src, ma_len)
raw_val = 2 * ta.wma(src, hma_half_len) - ta.wma(src, ma_len)

src_hist_e  = f_hist(src[1], ma_len + hma_sqrt_len + 5)
raw_hist_e  = f_hist(raw_val[1], hma_sqrt_len + 5)
drop_hist_e = f_hist(src[ma_len - fc_steps], fc_steps)

array<float> src_hist_raw  = na
array<float> raw_hist_raw  = na
array<float> drop_hist_raw = na

if ma_type == "SMA"
    drop_hist_raw := request.security(syminfo.tickerid, tf, drop_hist_e, lookahead = barmerge.lookahead_on)
else if ma_type == "WMA"
    src_hist_raw  := request.security(syminfo.tickerid, tf, src_hist_e, lookahead = barmerge.lookahead_on)
else if ma_type == "HMA"
    src_hist_raw  := request.security(syminfo.tickerid, tf, src_hist_e, lookahead = barmerge.lookahead_on)
    raw_hist_raw  := request.security(syminfo.tickerid, tf, raw_hist_e, lookahead = barmerge.lookahead_on)

src_hist  = na(src_hist_raw)  ? array.new_float(0) : src_hist_raw
raw_hist  = na(raw_hist_raw)  ? array.new_float(0) : raw_hist_raw
drop_hist = na(drop_hist_raw) ? array.new_float(0) : drop_hist_raw

ma_conf = request.security(syminfo.tickerid, tf, ma_expr[1], lookahead = barmerge.lookahead_on)

float ma_live = na

if ma_type == "SMA"
    oldC = request.security(syminfo.tickerid, tf, src[ma_len], lookahead = barmerge.lookahead_on)
    ma_live := ma_conf + (src - oldC) / ma_len
else if ma_type == "EMA"
    float alpha = 2.0 / (ma_len + 1)
    ma_live := alpha * src + (1 - alpha) * ma_conf
else if ma_type == "WMA"
    smaC = request.security(syminfo.tickerid, tf, ta.sma(src, ma_len)[1], lookahead = barmerge.lookahead_on)
    float W = ma_len * (ma_len + 1) / 2.0
    ma_live := (ma_len * src + W * ma_conf - ma_len * smaC) / W
else
    w = array.copy(src_hist)
    array.unshift(w, src)
    if array.size(w) >= ma_len + hma_sqrt_len
        rw = array.new_float(0)
        for i = 0 to hma_sqrt_len - 1
            sub = array.new_float(0)
            for j = 0 to ma_len - 1
                array.push(sub, array.get(w, i + j))
            array.push(rw, 2 * f_wma_arr(sub, hma_half_len) - f_wma_arr(sub, ma_len))
        ma_live := f_wma_arr(rw, hma_sqrt_len)

bool new_period = timeframe.change(tf_eff)

var int   per_start_time = na
var array<int>   hs_t = array.new_int(0)
var array<int>   he_t = array.new_int(0)
var array<float> hv   = array.new_float(0)

var int cur_period_bars         = 0
var array<int> period_bars_hist = array.new_int(0)

if is_coarser
    if new_period
        if cur_period_bars > 0
            array.push(period_bars_hist, cur_period_bars)
            if array.size(period_bars_hist) > 40
                array.shift(period_bars_hist)
        if not na(per_start_time) and not na(ma_conf)
            array.push(hs_t, per_start_time)
            array.push(he_t, time[1])
            array.push(hv, ma_conf)
            if array.size(hs_t) > 5000
                array.shift(hs_t)
                array.shift(he_t)
                array.shift(hv)
        per_start_time := time
        cur_period_bars := 1
    else
        cur_period_bars += 1
    if na(per_start_time)
        per_start_time := time

int med_period_bars = f_medianInt(period_bars_hist)
int period_bars = na(med_period_bars) ? int(math.max(1, math.round(tf_seconds / chart_seconds))) : math.max(1, med_period_bars)

// History is always the confirmed-steps stairstep for coarser MA timeframes — a period's
// final value drawn back across the bars of that period once it closes. Same/finer
// timeframes have no "period to wait for," so ma_live already IS the current, fully
// up-to-date value there and this flag is simply false.
bool draw_steps = is_coarser

// MA Line Style applies here — the plot() path, active whenever draw_steps is false
// (any same/finer timeframe).
plot(draw_steps ? na : ma_live, title="MA", color=ma_color, linewidth=ma_width, style=plot.style_line, display=display.pane, linestyle=ma_plot_style)

float status_val = draw_steps ? (barstate.islast ? ma_live : ma_conf) : ma_live
plot(status_val, title="MA status", color=ma_color, display=display.data_window + display.status_line)

var polyline hist_pl    = na
var polyline fc_pl_time = na    // coarser forecast — real future bars are sparse
                                  // relative to chart bars, so bar_index would overrun
                                  // the 500-bars-forward limit; bar_time is required.
var polyline fc_pl_idx  = na    // same/finer-timeframe forecast — at most fc_steps
                                  // (capped at ma_len-1) bars ahead, so bar_index is
                                  // exact and needs no calendar-gap guessing at all.

if barstate.islast
    if not na(hist_pl)
        polyline.delete(hist_pl)
    if not na(fc_pl_time)
        polyline.delete(fc_pl_time)
    if not na(fc_pl_idx)
        polyline.delete(fc_pl_idx)

    // ---- retroactive history — xloc.bar_time, unbounded past range ----
    // MA Line Style applies here too, so history looks identical regardless of which
    // draw path (plot vs. polyline) is active for the current timeframe relationship.
    if draw_steps and array.size(hs_t) > 0
        pts = array.new<chart.point>()
        int n = array.size(hs_t)

        for i = 0 to n - 1
            array.push(pts, chart.point.from_time(array.get(hs_t, i), array.get(hv, i)))
            array.push(pts, chart.point.from_time(array.get(he_t, i), array.get(hv, i)))

        if not na(per_start_time) and not na(ma_live)
            array.push(pts, chart.point.from_time(array.get(he_t, n - 1), array.get(hv, n - 1)))
            array.push(pts, chart.point.from_time(per_start_time, ma_live))
            array.push(pts, chart.point.from_time(time, ma_live))

        if array.size(pts) > 1
            hist_pl := polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_time, line_color = ma_color, line_width = ma_width, line_style = ma_line_style)

    // ---- forecast ----
    // Forecast Line Style applies to every polyline created below, regardless of
    // which of the three forecast branches (bar_index common case, bar_time extreme
    // ratio fallback, same/finer timeframe) actually runs.
    if fc_steps > 0 and not na(ma_live)
        float c = src

        work_src  = array.copy(src_hist)
        work_drop = array.copy(drop_hist)
        work_raw  = array.copy(raw_hist)

        if ma_type == "WMA" or ma_type == "HMA"
            array.unshift(work_src, c)

        if ma_type == "HMA"
            float rc = 2 * f_wma_arr(work_src, hma_half_len) - f_wma_arr(work_src, ma_len)
            array.unshift(work_raw, rc)

        float y1   = ma_live
        float proj = ma_live

        int steps_per_bar = is_finer ? int(math.max(1, math.round(chart_seconds / tf_seconds))) : 1
        int rendered_bars = 0

        int bars_until_boundary = math.max(1, period_bars - cur_period_bars + 1)

        if is_coarser
            int est_total_bars = fc_steps * math.max(1, period_bars)

            if est_total_bars < 480
                // Fits comfortably under the 500-bars-forward limit. Stays on
                // bar_index — the SAME coordinate system history renders in — so
                // there's no seam between session-compressed history and an
                // uncompressed future axis. This is the common case.
                fpts_i = array.new<chart.point>()
                array.push(fpts_i, chart.point.from_index(bar_index, ma_live))

                int bbars = bar_index

                for f = 1 to fc_steps
                    proj := f_step(work_src, work_raw, work_drop, proj, c)

                    int this_step_bars = f == 1 ? bars_until_boundary : period_bars
                    bbars := bbars + this_step_bars

                    array.push(fpts_i, chart.point.from_index(bbars - 1, y1))
                    array.push(fpts_i, chart.point.from_index(bbars, proj))

                    y1 := proj

                if array.size(fpts_i) > 1
                    fc_pl_idx := polyline.new(fpts_i, curved = false, closed = false, xloc = xloc.bar_index, line_color = fc_color, line_width = ma_width, line_style = fc_line_style)

                if label_size != "Off"
                    label.new(bbars, proj,
                              text = "Forecast MA\n" + str.tostring(proj, "#.####"),
                              xloc = xloc.bar_index,
                              color = fc_color,
                              textcolor = color.white,
                              style = label.style_label_left,
                              size = f_labelSize(label_size))
            else
                // Extreme ratio (e.g. weekly-on-1-minute) — projected bars exceed the
                // 500-bar-forward cap, so bar_index isn't usable at all. Falls back to
                // exact calendar boundaries via bar_time. This can show a rendering
                // seam right after the last historical bar, where TradingView's
                // session-compressed history axis meets its uncompressed future axis —
                // a platform limitation, not an approximation error.
                fpts_t = array.new<chart.point>()
                array.push(fpts_t, chart.point.from_time(time, ma_live))

                int next_boundary = per_start_time + tf_seconds * 1000
                int chart_bar_ms  = chart_seconds * 1000

                for f = 1 to fc_steps
                    proj := f_step(work_src, work_raw, work_drop, proj, c)

                    array.push(fpts_t, chart.point.from_time(next_boundary - chart_bar_ms, y1))
                    array.push(fpts_t, chart.point.from_time(next_boundary, proj))

                    y1 := proj
                    next_boundary += tf_seconds * 1000

                if array.size(fpts_t) > 1
                    fc_pl_time := polyline.new(fpts_t, curved = false, closed = false, xloc = xloc.bar_time, line_color = fc_color, line_width = ma_width, line_style = fc_line_style)

                if label_size != "Off"
                    label.new(next_boundary - tf_seconds * 1000, proj,
                              text = "Forecast MA\n" + str.tostring(proj, "#.####"),
                              xloc = xloc.bar_time,
                              color = fc_color,
                              textcolor = color.white,
                              style = label.style_label_left,
                              size = f_labelSize(label_size))
        else
            // Same/finer timeframe: at most fc_steps (capped at ma_len-1) chart bars
            // ahead. bar_index is exact here — no calendar gap to approximate, and it
            // matches the historical MA plot's own spacing on session-compressed
            // charts, which bar_time cannot do since it has no real bar to align to.
            fpts_i = array.new<chart.point>()
            array.push(fpts_i, chart.point.from_index(bar_index, ma_live))

            for f = 1 to fc_steps
                proj := f_step(work_src, work_raw, work_drop, proj, c)

                if f % steps_per_bar == 0 or f == fc_steps
                    rendered_bars += 1
                    array.push(fpts_i, chart.point.from_index(bar_index + rendered_bars, proj))
                    y1 := proj

            if array.size(fpts_i) > 1
                fc_pl_idx := polyline.new(fpts_i, curved = false, closed = false, xloc = xloc.bar_index, line_color = fc_color, line_width = ma_width, line_style = fc_line_style)

            if label_size != "Off"
                label.new(bar_index + rendered_bars, y1,
                          text = "Forecast MA\n" + str.tostring(y1, "#.####"),
                          xloc = xloc.bar_index,
                          color = fc_color,
                          textcolor = color.white,
                          style = label.style_label_left,
                          size = f_labelSize(label_size))
````
