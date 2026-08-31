<!-- tradingview-pine-id: PUB;af319b985921457ea5940edecc23c849 -->
<!-- tradingviewscripts-format: 1 -->
# Probabilistic ICT Order Blocks [3D] (Heikin Ashi)

Source: https://www.tradingview.com/script/bGrx0hhS-KM-Probabilistic-ICT-Order-Blocks-3D-Heikin-Ashi/

## Description

[KM] Probabilistic ICT Order Blocks [3D] (Heikin Ashi)

PS: added just heikin ashi candles instead of normal candles, rest oof the indicator is same as its name and already available on trading view..

---

## Source Code

````pine
//@version=6
indicator("Probabilistic ICT Order Blocks [3D] (Heikin Ashi)", overlay=true, max_bars_back = 1500, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

import GainzAlgo/Arbor_Gradient_Boosting_GainzAlgo/1 as arbor

// Ui
string ICT_GRP = "ICT Order Block Settings"
int swing_length = input.int(5, "Swing Detection Length", minval=2, group=ICT_GRP)
int max_blocks   = input.int(4, "Max Displayed Blocks (Per Type)", minval=1, maxval=10, group=ICT_GRP)
bool delete_on_break = input.bool(true, "Delete OB on Full Invalidation", tooltip="Removes a block the moment price closes fully through it (loss). Frees up space so new blocks don't overlap stale ones.", group=ICT_GRP)

string AI_GRP  = "Arbor AI Engine"
int train_len   = input.int(200, "Machine Learning Training Lookback", minval=50, group=AI_GRP)
int retrain_f   = input.int(30, "Retrain Frequency (Bars)", minval=10, group=AI_GRP)

string VIS_GRP = "3D Rendering Visuals"
color bull_clr = input.color(#00e5ff, "Bullish OB Color", group=VIS_GRP)
color bear_clr = input.color(#ff1744, "Bearish OB Color", group=VIS_GRP)
int depth_shift = input.int(2, "3D Depth Shift (Bars)", minval=1, maxval=5, group=VIS_GRP)
int tick_shift  = input.int(3, "3D Depth Shift (Ticks)", minval=1, group=VIS_GRP)

string DASH_GRP = "Win Rate Dashboard"
bool show_dashboard = input.bool(true, "Show Dashboard", group=DASH_GRP)
string dash_pos = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=DASH_GRP)
string dash_size = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=DASH_GRP)
bool show_retest_signals = input.bool(true, "Show Win/Loss Markers on Chart", group=DASH_GRP)

string HA_GRP = "Heikin Ashi Display"
bool plot_ha_candles = input.bool(true, "Plot Heikin Ashi Candles", tooltip="Draws HA candles on the chart. TradingView cannot change the real candle series from a script, so also hide the chart's native candles: click the eye icon next to the symbol name (top-left of chart) or right-click the chart > Settings > Symbol and uncheck Body/Borders/Wick.", group=HA_GRP)
color ha_up_clr   = input.color(#26a69a, "HA Up Candle Color", group=HA_GRP)
color ha_dn_clr   = input.color(#ef5350, "HA Down Candle Color", group=HA_GRP)

// Heikin Ashi source data
// Pulls true Heikin Ashi OHLC (same timeframe) so all downstream logic - ML features,
// swing detection, order block boxes - is computed off HA candles instead of real ones.
haTicker = ticker.heikinashi(syminfo.tickerid)
[ha_open, ha_high, ha_low, ha_close] = request.security(haTicker, timeframe.period, [open, high, low, close], lookahead=barmerge.lookahead_off)
float ha_hlc3 = (ha_high + ha_low + ha_close) / 3

float ha_tr  = na(ha_close[1]) ? ha_high - ha_low : math.max(ha_high - ha_low, math.max(math.abs(ha_high - ha_close[1]), math.abs(ha_low - ha_close[1])))
float ha_atr = ta.rma(ha_tr, 14)

// Render the Heikin Ashi candles directly on the chart (overlay).
plotcandle(plot_ha_candles ? ha_open : na, plot_ha_candles ? ha_high : na, plot_ha_candles ? ha_low : na, plot_ha_candles ? ha_close : na,
  title="Heikin Ashi Candles",
  color = ha_close >= ha_open ? ha_up_clr : ha_dn_clr,
  wickcolor = ha_close >= ha_open ? ha_up_clr : ha_dn_clr,
  bordercolor = ha_close >= ha_open ? ha_up_clr : ha_dn_clr)

// Technicals (Heikin Ashi based)
float f1 = ta.rsi(ha_close, 14)
float f2 = ta.mfi(ha_hlc3, 14)
float f3 = ha_atr / (ha_close + 1e-6) * 100
float f4 = nz(volume) > 0 ? (volume - ta.sma(volume, 20)) / (ta.stdev(volume, 20) + 1e-6) : 0.0

bool features_ready = not (na(f1) or na(f2) or na(f3) or na(f4))

var arbor.GBM4 model = na
var float current_prob = 0.5
bool dynamic_retrain = bar_index % retrain_f == 0 and bar_index > train_len and features_ready and barstate.isconfirmed

if dynamic_retrain
    array<float> a1 = array.new<float>()
    array<float> a2 = array.new<float>()
    array<float> a3 = array.new<float>()
    array<float> a4 = array.new<float>()
    array<float> target = array.new<float>()

    for i = train_len to 5
        if not (na(f1[i]) or na(f2[i]) or na(f3[i]) or na(f4[i]))
            array.push(a1, f1[i])
            array.push(a2, f2[i])
            array.push(a3, f3[i])
            array.push(a4, f4[i])
            array.push(target, ha_close[i-5] > ha_close[i] ? 1.0 : 0.0)

    if array.size(target) >= 30
        model := arbor.gbm4_fit(a1, a2, a3, a4, target, n_rounds=15, lr=0.3, is_classifier=true, seed=42)

if not na(model) and features_ready
    current_prob := arbor.gbm4_predict(model, f1, f2, f3, f4)

// OB Arrays
var array<float> bull_ob_top    = array.new<float>()
var array<float> bull_ob_bot    = array.new<float>()
var array<int>   bull_ob_x      = array.new<int>()
var array<float> bull_ob_pr     = array.new<float>()
var array<bool>  bull_ob_tested = array.new<bool>()

var array<float> bear_ob_top    = array.new<float>()
var array<float> bear_ob_bot    = array.new<float>()
var array<int>   bear_ob_x      = array.new<int>()
var array<float> bear_ob_pr     = array.new<float>()
var array<bool>  bear_ob_tested = array.new<bool>()

var int bull_wins = 0
var int bull_losses = 0
var int bear_wins = 0
var int bear_losses = 0

// bar-scoped signal flags (reset every bar)
bool bull_win_signal = false
bool bull_loss_signal = false
bool bear_win_signal = false
bool bear_loss_signal = false


f_is_overlapping(array<float> tops, array<float> bots, float new_top, float new_bot) =>
    bool result = false
    if array.size(tops) > 0
        for i = 0 to array.size(tops) - 1
            float et = array.get(tops, i)
            float eb = array.get(bots, i)
            if new_top >= eb and new_bot <= et
                result := true
                break
    result

// Swings (Heikin Ashi based)
float high_lh = ta.highest(ha_high, swing_length)
float low_ll  = ta.lowest(ha_low, swing_length)

bool mss_bull = ta.crossover(ha_close, high_lh[1])
bool mss_bear = ta.crossunder(ha_close, low_ll[1])


if barstate.isconfirmed
    if array.size(bull_ob_top) > 0
        for i = array.size(bull_ob_top) - 1 to 0
            float top = array.get(bull_ob_top, i)
            float bot = array.get(bull_ob_bot, i)
            bool tested = array.get(bull_ob_tested, i)

            if not tested and ha_low <= top
                array.set(bull_ob_tested, i, true)
                tested := true

            bool resolved = false
            if tested and ha_close > top
                bull_wins += 1
                bull_win_signal := true
                resolved := true
            else if ha_close < bot
                bull_losses += 1
                bull_loss_signal := true
                resolved := true

            if resolved and delete_on_break
                array.remove(bull_ob_top, i)
                array.remove(bull_ob_bot, i)
                array.remove(bull_ob_x, i)
                array.remove(bull_ob_pr, i)
                array.remove(bull_ob_tested, i)

    if array.size(bear_ob_top) > 0
        for i = array.size(bear_ob_top) - 1 to 0
            float top = array.get(bear_ob_top, i)
            float bot = array.get(bear_ob_bot, i)
            bool tested = array.get(bear_ob_tested, i)

            if not tested and ha_high >= bot
                array.set(bear_ob_tested, i, true)
                tested := true

            bool resolved = false
            if tested and ha_close < bot
                bear_wins += 1
                bear_win_signal := true
                resolved := true
            else if ha_close > top
                bear_losses += 1
                bear_loss_signal := true
                resolved := true

            if resolved and delete_on_break
                array.remove(bear_ob_top, i)
                array.remove(bear_ob_bot, i)
                array.remove(bear_ob_x, i)
                array.remove(bear_ob_pr, i)
                array.remove(bear_ob_tested, i)
// Overlap check (Heikin Ashi based)
if mss_bull
    int lowest_idx = 1
    for i = 1 to swing_length * 2
        if ha_close[i] < ha_open[i] and ha_low[i] < ha_low[lowest_idx]
            lowest_idx := i

    float new_top = ha_high[lowest_idx]
    float new_bot = ha_low[lowest_idx]

    bool overlap = f_is_overlapping(bull_ob_top, bull_ob_bot, new_top, new_bot) or
                   f_is_overlapping(bear_ob_top, bear_ob_bot, new_top, new_bot)

    if not overlap
        array.unshift(bull_ob_top, new_top)
        array.unshift(bull_ob_bot, new_bot)
        array.unshift(bull_ob_x, bar_index - lowest_idx)
        array.unshift(bull_ob_pr, current_prob)
        array.unshift(bull_ob_tested, false)

        if array.size(bull_ob_top) > max_blocks
            array.pop(bull_ob_top), array.pop(bull_ob_bot), array.pop(bull_ob_x), array.pop(bull_ob_pr), array.pop(bull_ob_tested)

if mss_bear
    int highest_idx = 1
    for i = 1 to swing_length * 2
        if ha_close[i] > ha_open[i] and ha_high[i] > ha_high[highest_idx]
            highest_idx := i

    float new_top = ha_high[highest_idx]
    float new_bot = ha_low[highest_idx]

    bool overlap = f_is_overlapping(bear_ob_top, bear_ob_bot, new_top, new_bot) or
                   f_is_overlapping(bull_ob_top, bull_ob_bot, new_top, new_bot)

    if not overlap
        array.unshift(bear_ob_top, new_top)
        array.unshift(bear_ob_bot, new_bot)
        array.unshift(bear_ob_x, bar_index - highest_idx)
        array.unshift(bear_ob_pr, 1.0 - current_prob)
        array.unshift(bear_ob_tested, false)

        if array.size(bear_ob_top) > max_blocks
            array.pop(bear_ob_top), array.pop(bear_ob_bot), array.pop(bear_ob_x), array.pop(bear_ob_pr), array.pop(bear_ob_tested)

// mark wins and losses clearly on chart
plotshape(show_retest_signals and bull_win_signal, title="Bull OB Win", style=shape.triangleup, location=location.belowbar, color=bull_clr, size=size.tiny)
plotshape(show_retest_signals and bull_loss_signal, title="Bull OB Loss", style=shape.xcross, location=location.belowbar, color=color.new(bull_clr, 0), size=size.tiny)
plotshape(show_retest_signals and bear_win_signal, title="Bear OB Win", style=shape.triangledown, location=location.abovebar, color=bear_clr, size=size.tiny)
plotshape(show_retest_signals and bear_loss_signal, title="Bear OB Loss", style=shape.xcross, location=location.abovebar, color=color.new(bear_clr, 0), size=size.tiny)

// 3D blocks
var array<box> graphics_cache = array.new<box>()
var array<line> line_cache = array.new<line>()

if barstate.islast

    if array.size(graphics_cache) > 0
        for b in graphics_cache
            box.delete(b)
        array.clear(graphics_cache)

    if array.size(line_cache) > 0
        for l in line_cache
            line.delete(l)
        array.clear(line_cache)

    float t_shift = syminfo.mintick * tick_shift

    if array.size(bull_ob_top) > 0
        for i = 0 to array.size(bull_ob_top) - 1
            float top  = array.get(bull_ob_top, i)
            float bot  = array.get(bull_ob_bot, i)
            int   left = array.get(bull_ob_x, i)
            float prob = array.get(bull_ob_pr, i)

            box front = box.new(left, top, bar_index, bot,
              border_color=bull_clr, bgcolor=color.new(bull_clr, 85),
              text="Bullish OB (" + str.tostring(prob * 100, "#.#") + "%)",
              text_color=color.white, text_size=size.small)
            array.push(graphics_cache, front)

            box rear = box.new(left + depth_shift, top + t_shift, bar_index + depth_shift, bot + t_shift,
              border_color=color.new(bull_clr, 50), bgcolor=color.new(bull_clr, 94))
            array.push(graphics_cache, rear)

            array.push(line_cache, line.new(left, top, left + depth_shift, top + t_shift, color=color.new(bull_clr, 40), style=line.style_solid))
            array.push(line_cache, line.new(bar_index, top, bar_index + depth_shift, top + t_shift, color=color.new(bull_clr, 40), style=line.style_solid))
            array.push(line_cache, line.new(left, bot, left + depth_shift, bot + t_shift, color=color.new(bull_clr, 40), style=line.style_solid))
            array.push(line_cache, line.new(bar_index, bot, bar_index + depth_shift, bot + t_shift, color=color.new(bull_clr, 40), style=line.style_solid))

    if array.size(bear_ob_top) > 0
        for i = 0 to array.size(bear_ob_top) - 1
            float top  = array.get(bear_ob_top, i)
            float bot  = array.get(bear_ob_bot, i)
            int   left = array.get(bear_ob_x, i)
            float prob = array.get(bear_ob_pr, i)

            box front = box.new(left, top, bar_index, bot,
              border_color=bear_clr, bgcolor=color.new(bear_clr, 85),
              text="Bearish OB (" + str.tostring(prob * 100, "#.#") + "%)",
              text_color=color.white, text_size=size.small)
            array.push(graphics_cache, front)

            box rear = box.new(left + depth_shift, top + t_shift, bar_index + depth_shift, bot + t_shift,
              border_color=color.new(bear_clr, 50), bgcolor=color.new(bear_clr, 94))
            array.push(graphics_cache, rear)

            array.push(line_cache, line.new(left, top, left + depth_shift, top + t_shift, color=color.new(bear_clr, 40), style=line.style_solid))
            array.push(line_cache, line.new(bar_index, top, bar_index + depth_shift, top + t_shift, color=color.new(bear_clr, 40), style=line.style_solid))
            array.push(line_cache, line.new(left, bot, left + depth_shift, bot + t_shift, color=color.new(bear_clr, 40), style=line.style_solid))
            array.push(line_cache, line.new(bar_index, bot, bar_index + depth_shift, bot + t_shift, color=color.new(bear_clr, 40), style=line.style_solid))

// Stats and statstable
f_pos(string p) =>
    switch p
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_size(string s) =>
    switch s
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_wr(int wins, int losses) =>
    int total = wins + losses
    total > 0 ? str.tostring(wins / total * 100, "#.#") + "% (" + str.tostring(total) + ")" : "N/A"

var table dash = table.new(f_pos(dash_pos), 2, 4, border_width=1, border_color=color.gray, frame_width=1, frame_color=color.gray)

if show_dashboard and barstate.islast
    table.cell(dash, 0, 0, "Bull OB Win Rate", text_color=color.white, bgcolor=color.new(bull_clr, 70), text_size=f_size(dash_size))
    table.cell(dash, 1, 0, f_wr(bull_wins, bull_losses), text_color=color.white, bgcolor=color.new(color.black, 60), text_size=f_size(dash_size))

    table.cell(dash, 0, 1, "Bear OB Win Rate", text_color=color.white, bgcolor=color.new(bear_clr, 70), text_size=f_size(dash_size))
    table.cell(dash, 1, 1, f_wr(bear_wins, bear_losses), text_color=color.white, bgcolor=color.new(color.black, 60), text_size=f_size(dash_size))

    table.cell(dash, 0, 2, "Overall Win Rate", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=f_size(dash_size))
    table.cell(dash, 1, 2, f_wr(bull_wins + bear_wins, bull_losses + bear_losses), text_color=color.white, bgcolor=color.new(color.black, 60), text_size=f_size(dash_size))

    table.cell(dash, 0, 3, "ML Bull Probability", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=f_size(dash_size))
    table.cell(dash, 1, 3, str.tostring(current_prob * 100, "#.#") + "%", text_color=color.white, bgcolor=color.new(color.black, 60), text_size=f_size(dash_size))
````
