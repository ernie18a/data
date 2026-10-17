# Trendlines with Breaks [EXCAVO]

- url: https://www.tradingview.com/script/J49l5VTa-Trendlines-with-Breaks-EXCAVO/
- type: indicator
- pine_id: PUB;464aa7e1a7544872b25fa95b102aa4cb
- version: 2.0

## Description

[b]Trendlines with Breaks [EXCAVO][/b]

Dynamic Trendlines from Swing Pivots with Breakout Detection

The [i]Trendlines with Breaks[/i] indicator draws trendlines by connecting
consecutive swing highs and lows. Each new pivot creates a new trendline
through the two most recent pivots of the same type. If a new pivot aligns
with the active line (within ATR tolerance), the line is extended through
three or more pivots instead of creating a duplicate. Historical trendlines
validated by three or more pivot touches are preserved as dashed lines.

Resistance lines connect swing highs (red). Support lines connect swing
lows (blue). Lines that are broken by subsequent price action are
automatically removed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. Trendlines appear connecting consecutive
              swing pivots - blue for support, red for resistance.
[b]Step 2[/b]  →  Solid lines are the most recent active trendlines.
              Dashed lines are previous trendlines still validated by
              three or more pivot touches.
[b]Step 3[/b]  →  When price breaks through a trendline, the broken line
              is automatically removed from the chart.
[b]Step 4[/b]  →  Check the dashboard for active line counts per direction.
[b]Step 5[/b]  →  Adjust Swing Lookback for different pivot sensitivity.
              Adjust Merge Tolerance to control when aligned pivots
              extend the same line instead of creating a new one.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Pivot Detection[/b]
Swing highs and lows are detected using ta.pivothigh() and ta.pivotlow()
with a configurable lookback (default 14 bars each side). Up to 50
pivots of each type are stored in a rolling buffer for trendline
construction and validation.

[b]◆  Trendline Construction[/b]
When a new swing pivot is confirmed, a line is drawn from the previous
pivot of the same type through the new pivot:

  slope = (price_new - price_prev) / (bar_new - bar_prev)

This connects the two most recent swing highs (resistance) or swing
lows (support). The slope is determined entirely by the pivot geometry.

[b]◆  Merge Logic[/b]
Before creating a new line, the indicator checks whether the new pivot
falls on the projection of the existing active trendline. If the
distance between the new pivot and the projected line is within the
Merge Tolerance (default 1.0 x ATR), the active line is extended
through the new pivot instead of creating a duplicate. This produces
one longer line spanning three or more pivots.

[b]◆  Historical Validation[/b]
When a trendline is demoted (replaced by a newer line), it is checked
for pivot touches. Lines with three or more pivot touches within ATR
tolerance are preserved as dashed historical trendlines. Lines with
fewer touches are removed. Additionally, all pairs of pivots in the
buffer are scanned for validated lines (3+ touches) where no pivot
crosses to the wrong side of the line.

[b]◆  Breakout Detection and Cleanup[/b]
On each confirmed bar, all historical trendlines are checked against
the current close. Resistance lines where close is above the projection
are broken and removed. Support lines where close is below the
projection are broken and removed. Lines whose projection goes
negative or diverges more than 15 x ATR from the current price are
also removed.

[b]◆  Extension and Scaling[/b]
Lines do not use extend.right to avoid affecting the chart Y-axis
auto-scaling. Instead, the three most recent lines per direction
(active + two previous) are manually extended forward by 30 bars on
the last bar, with price clamped to within 10 x ATR of the close.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Pivot-to-Pivot Geometry[/b]
Trendlines are drawn directly through detected swing pivots. The slope
is determined by the actual price structure, not by ATR or other
volatility proxies.

[b]◆  Merge Instead of Duplicate[/b]
When consecutive pivots align with the active trendline, the line is
extended rather than duplicated. This avoids overlapping lines from
the same starting point.

[b]◆  Validated Historical Lines[/b]
Historical trendlines are only shown if three or more pivots touch
the line within ATR tolerance and no pivot crosses to the wrong side.
This filters out noise and keeps only structurally significant lines.

[b]◆  Scale-Safe Extension[/b]
Lines are extended with price clamping instead of extend.right, so
the chart Y-axis is never compressed by extreme projections on any
timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ LEGEND[/b]

Legend table (bottom left) explains every visual element on the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Calculation[/b]
[list]
[*][b]Swing Lookback[/b] - 14 (bars each side for pivot detection)
[*][b]Max Lines per Side[/b] - 8 (maximum trendlines per direction)
[*][b]Merge Tolerance (xATR)[/b] - 1.0 (threshold for extending vs creating new line)
[*][b]Max Slope (xATR/bar)[/b] - 0.5 (steepness filter for old dashed lines)
[/list]

[b]Visualization[/b]
[list]
[*][b]Support Color[/b] - blue (customizable)
[*][b]Resistance Color[/b] - red (customizable)
[/list]

[b]Legend[/b]
[list]
[*][b]Show Legend[/b] - ON
[/list]

[b]Alert Settings[/b]
[list]
[*][b]Allow Repainting[/b] - OFF
[*][b]JSON Alerts[/b] - OFF
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Bullish Break[/b] - price closed above resistance trendline
[*][b]Bearish Break[/b] - price closed below support trendline
[*][b]Any Break[/b] - either direction
[/list]

JSON payloads include direction, ticker, price, and timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis tool
and does not constitute financial advice, investment recommendations, or a
guarantee of future results. Past indicator behavior does not guarantee future
performance. Always use proper risk management and your own judgment.
[/quote]

## Source Code

````pine
// (c) EXCAVO
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//
// Trendlines with Breaks [EXCAVO]
// -----------------------------------------------------------------------------
// Dynamic trendlines connecting consecutive swing pivots with breakout detection.
// Lines extend without affecting Y-axis scale. Broken lines auto-removed.
//
//@version=6
indicator("Trendlines with Breaks [EXCAVO]", "EXCAVO Trendlines with Breaks",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 500)

//-----------------------------------------------------------------------------}
// Types
//-----------------------------------------------------------------------------{
type TL
    line  ln
    int   b1
    float p1
    int   b2
    float slope

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_CALC   = "Calculation"
string GRP_VIZ    = "Visualization"
string GRP_DASH   = "Dashboard"
string GRP_ALERTS = "Alert Settings"

int    i_len       = input.int(14,    "Swing Lookback",        minval = 5, maxval = 50, group = GRP_CALC,
     tooltip = "Bars on each side to detect swing pivots.")
int    i_max_lines = input.int(8,     "Max Lines per Side",    minval = 1, maxval = 20, group = GRP_CALC,
     tooltip = "How many trendlines to keep visible per direction. Oldest are removed first.")
float  i_merge_tol = input.float(1.0, "Merge Tolerance (xATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = GRP_CALC,
     tooltip = "If a new pivot is within this ATR distance from the active line projection, extend instead of creating a new line.")
float  i_max_slope = input.float(0.5, "Max Slope (xATR/bar)",  minval = 0.05, maxval = 3.0, step = 0.05, group = GRP_CALC,
     tooltip = "Old dashed lines steeper than this are trimmed. Lower = more horizontal lines only.")

color  C_BULL     = input.color(color.rgb(0, 60, 180),  "Support Color",    group = GRP_VIZ,
     tooltip = "Color for support trendlines.")
color  C_BEAR     = input.color(color.rgb(200, 40, 40), "Resistance Color", group = GRP_VIZ,
     tooltip = "Color for resistance trendlines.")

bool   i_show_lgnd = input.bool(true, "Show Legend",       group = GRP_DASH,
     tooltip = "Toggle legend panel.")

bool   i_repaint = input.bool(false, "Allow Repainting",   group = GRP_ALERTS,
     tooltip = "OFF = detections on bar close only (recommended). ON = real-time signals that may repaint.")
bool   i_json    = input.bool(false, "JSON Alerts",        group = GRP_ALERTS,
     tooltip = "Enable JSON-formatted alerts for bot integration.")

//-----------------------------------------------------------------------------}
// Functions
//-----------------------------------------------------------------------------{
f_touches(array<float> prices, array<int> bars, int b1, float p1, float slope, float tol) =>
    int count = 0
    if prices.size() > 0
        for j = 0 to prices.size() - 1
            float proj = p1 + slope * (bars.get(j) - b1)
            if math.abs(prices.get(j) - proj) <= tol
                count += 1
    count

f_valid_res(array<float> prices, array<int> bars, int b1, float p1, float slope, float tol) =>
    bool valid = true
    if prices.size() > 0
        for j = 0 to prices.size() - 1
            if valid
                float proj = p1 + slope * (bars.get(j) - b1)
                if prices.get(j) > proj + tol
                    valid := false
    valid

f_valid_sup(array<float> prices, array<int> bars, int b1, float p1, float slope, float tol) =>
    bool valid = true
    if prices.size() > 0
        for j = 0 to prices.size() - 1
            if valid
                float proj = p1 + slope * (bars.get(j) - b1)
                if prices.get(j) < proj - tol
                    valid := false
    valid

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80, 80, 100)
color C_DASH_BG     = color.rgb(50, 53, 60)
color C_DASH_BORDER = color.rgb(80, 85, 95)
color C_DASH_BULL   = color.rgb(80, 140, 255)
color C_DASH_BEAR   = color.rgb(240, 70, 70)

//-----------------------------------------------------------------------------}
// Pivot Detection
//-----------------------------------------------------------------------------{
bool confirmed = i_repaint or barstate.isconfirmed

float ph = ta.pivothigh(i_len, i_len)
float pl = ta.pivotlow(i_len, i_len)

var array<float> hi_prices = array.new<float>()
var array<int>   hi_bars   = array.new<int>()
var array<float> lo_prices = array.new<float>()
var array<int>   lo_bars   = array.new<int>()

if not na(ph) and confirmed
    hi_prices.push(ph)
    hi_bars.push(bar_index - i_len)
    if hi_prices.size() > 30
        hi_prices.shift()
        hi_bars.shift()

if not na(pl) and confirmed
    lo_prices.push(pl)
    lo_bars.push(bar_index - i_len)
    if lo_prices.size() > 30
        lo_prices.shift()
        lo_bars.shift()

//-----------------------------------------------------------------------------}
// Trendline Drawing
//-----------------------------------------------------------------------------{
var array<TL> res_tls = array.new<TL>()
var array<TL> sup_tls = array.new<TL>()

var float active_res_slope = 0.0
var float active_res_price = 0.0
var int   active_res_bar   = 0
var float active_res_p1    = 0.0
var int   active_res_b1    = 0
var float active_sup_slope = 0.0
var float active_sup_price = 0.0
var int   active_sup_bar   = 0
var float active_sup_p1    = 0.0
var int   active_sup_b1    = 0

float atr_val   = ta.atr(14)
float touch_tol = atr_val * i_merge_tol

// Resistance — new swing high
if not na(ph) and confirmed and hi_prices.size() >= 2
    int   sz    = hi_prices.size()
    float p_new = hi_prices.get(sz - 1)
    int   b_new = hi_bars.get(sz - 1)

    bool do_merge = false
    if active_res_bar > 0 and b_new > active_res_b1
        float projected = active_res_p1 + active_res_slope * (b_new - active_res_b1)
        if math.abs(p_new - projected) <= touch_tol
            do_merge := true

    if do_merge and res_tls.size() > 0
        TL act = res_tls.get(res_tls.size() - 1)
        line.set_xy2(act.ln, b_new, p_new)
        float new_slope = (p_new - act.p1) / (b_new - act.b1)
        act.slope := new_slope
        act.b2    := b_new
        active_res_slope := new_slope
        active_res_price := p_new
        active_res_bar   := b_new
    else
        if res_tls.size() > 0
            for i = res_tls.size() - 1 to 0
                TL t = res_tls.get(i)
                int tch = f_touches(hi_prices, hi_bars, t.b1, t.p1, t.slope, touch_tol)
                if tch >= 3
                    line.set_style(t.ln, line.style_dashed)
                    line.set_width(t.ln, 1)
                else
                    line.delete(t.ln)
                    res_tls.remove(i)

        float p1 = hi_prices.get(sz - 2)
        int   b1 = hi_bars.get(sz - 2)

        if b_new > b1
            float slope = (p_new - p1) / (b_new - b1)
            line ln = line.new(b1, p1, b_new, p_new, color = C_BEAR, width = 2)
            res_tls.push(TL.new(ln, b1, p1, b_new, slope))

            active_res_slope := slope
            active_res_price := p_new
            active_res_bar   := b_new
            active_res_p1    := p1
            active_res_b1    := b1

            while res_tls.size() > i_max_lines
                line.delete(res_tls.shift().ln)

// Support — new swing low
if not na(pl) and confirmed and lo_prices.size() >= 2
    int   sz    = lo_prices.size()
    float p_new = lo_prices.get(sz - 1)
    int   b_new = lo_bars.get(sz - 1)

    bool do_merge = false
    if active_sup_bar > 0 and b_new > active_sup_b1
        float projected = active_sup_p1 + active_sup_slope * (b_new - active_sup_b1)
        if math.abs(p_new - projected) <= touch_tol
            do_merge := true

    if do_merge and sup_tls.size() > 0
        TL act = sup_tls.get(sup_tls.size() - 1)
        line.set_xy2(act.ln, b_new, p_new)
        float new_slope = (p_new - act.p1) / (b_new - act.b1)
        act.slope := new_slope
        act.b2    := b_new
        active_sup_slope := new_slope
        active_sup_price := p_new
        active_sup_bar   := b_new
    else
        if sup_tls.size() > 0
            for i = sup_tls.size() - 1 to 0
                TL t = sup_tls.get(i)
                int tch = f_touches(lo_prices, lo_bars, t.b1, t.p1, t.slope, touch_tol)
                if tch >= 3
                    line.set_style(t.ln, line.style_dashed)
                    line.set_width(t.ln, 1)
                else
                    line.delete(t.ln)
                    sup_tls.remove(i)

        float p1 = lo_prices.get(sz - 2)
        int   b1 = lo_bars.get(sz - 2)

        if b_new > b1
            float slope = (p_new - p1) / (b_new - b1)
            line ln = line.new(b1, p1, b_new, p_new, color = C_BULL, width = 2)
            sup_tls.push(TL.new(ln, b1, p1, b_new, slope))

            active_sup_slope := slope
            active_sup_price := p_new
            active_sup_bar   := b_new
            active_sup_p1    := p1
            active_sup_b1    := b1

            while sup_tls.size() > i_max_lines
                line.delete(sup_tls.shift().ln)

//-----------------------------------------------------------------------------}
// Line Extension (barstate.islast)
//-----------------------------------------------------------------------------{
// No extend.right — manually project forward with price clamping.
// Active + 2 most recent dashed: extend to bar_index + 30 (clamped).
// Older dashed: stay at their last pivot.

if barstate.islast
    int   ext_bars = 30
    float max_dist = atr_val * 10

    if res_tls.size() > 0
        int last_idx = res_tls.size() - 1
        for i = 0 to res_tls.size() - 1
            TL t = res_tls.get(i)
            if i >= last_idx - 2
                float proj = t.p1 + t.slope * (bar_index + ext_bars - t.b1)
                float clamped = math.max(math.min(proj, close + max_dist), close - max_dist)
                int target_bar = bar_index + ext_bars
                if math.abs(proj - clamped) > 0.01 and math.abs(t.slope) > 1e-6
                    target_bar := t.b1 + math.round((clamped - t.p1) / t.slope)
                    target_bar := math.max(t.b2, math.min(target_bar, bar_index + ext_bars))
                line.set_xy2(t.ln, target_bar, clamped)

    if sup_tls.size() > 0
        int last_idx = sup_tls.size() - 1
        for i = 0 to sup_tls.size() - 1
            TL t = sup_tls.get(i)
            if i >= last_idx - 2
                float proj = t.p1 + t.slope * (bar_index + ext_bars - t.b1)
                float clamped = math.max(math.min(proj, close + max_dist), close - max_dist)
                int target_bar = bar_index + ext_bars
                if math.abs(proj - clamped) > 0.01 and math.abs(t.slope) > 1e-6
                    target_bar := t.b1 + math.round((clamped - t.p1) / t.slope)
                    target_bar := math.max(t.b2, math.min(target_bar, bar_index + ext_bars))
                line.set_xy2(t.ln, target_bar, clamped)

//-----------------------------------------------------------------------------}
// Historical Validated Trendlines
//-----------------------------------------------------------------------------{
// Scan pivot pairs for lines with 3+ touches that don't pass through candles.
// Runs ONLY when the pivot pool changes (dirty flag), not on every live tick.
// This is O(n^3) work in the worst case — running it every tick was the cause
// of runtime timeouts on long chart histories.

var array<line> hist_lines = array.new<line>()
var int         hi_size_prev = -1
var int         lo_size_prev = -1
var int         active_res_b1_prev = -1
var int         active_sup_b1_prev = -1

bool hist_dirty = hi_prices.size() != hi_size_prev or
     lo_prices.size() != lo_size_prev or
     active_res_b1    != active_res_b1_prev or
     active_sup_b1    != active_sup_b1_prev

if barstate.islast and hist_dirty
    hi_size_prev       := hi_prices.size()
    lo_size_prev       := lo_prices.size()
    active_res_b1_prev := active_res_b1
    active_sup_b1_prev := active_sup_b1

    for l in hist_lines
        line.delete(l)
    hist_lines.clear()

    int   max_hist    = 10
    int   max_pair_gap = 15    // do not test pivot pairs further than this apart in the pool
    float slope_limit = atr_val * i_max_slope / 3

    var array<int> used_starts = array.new<int>()
    used_starts.clear()

    // Resistance: best partner per start pivot
    if hi_prices.size() >= 3
        int found_res = 0
        for a = 0 to hi_prices.size() - 3
            if found_res >= max_hist
                break
            int   ba = hi_bars.get(a)
            float pa = hi_prices.get(a)
            if ba == active_res_b1
                continue
            int   best_b   = -1
            int   best_tch = 0
            float best_sl  = 0.0
            int   b_end    = math.min(a + max_pair_gap, hi_prices.size() - 1)
            for b = a + 2 to b_end
                int   bb = hi_bars.get(b)
                float pb = hi_prices.get(b)
                if bb > ba
                    float sl = (pb - pa) / (bb - ba)
                    if math.abs(sl) <= slope_limit
                        int tch = f_touches(hi_prices, hi_bars, ba, pa, sl, touch_tol)
                        if tch > best_tch
                            if f_valid_res(hi_prices, hi_bars, ba, pa, sl, touch_tol)
                                float proj_now = pa + sl * (bar_index - ba)
                                if proj_now > close
                                    best_tch := tch
                                    best_b   := b
                                    best_sl  := sl
            if best_b >= 0 and best_tch >= 3
                int   bb = hi_bars.get(best_b)
                float pb = hi_prices.get(best_b)
                bool dup = false
                if used_starts.size() > 0
                    for u = 0 to used_starts.size() - 1
                        if used_starts.get(u) == ba or used_starts.get(u) == bb
                            dup := true
                if not dup
                    hist_lines.push(line.new(ba, pa, bb, pb,
                         color = C_BEAR, width = 1, style = line.style_dashed))
                    used_starts.push(ba)
                    used_starts.push(bb)
                    found_res += 1

    // Support: best partner per start pivot
    used_starts.clear()
    if lo_prices.size() >= 3
        int found_sup = 0
        for a = 0 to lo_prices.size() - 3
            if found_sup >= max_hist
                break
            int   ba = lo_bars.get(a)
            float pa = lo_prices.get(a)
            if ba == active_sup_b1
                continue
            int   best_b   = -1
            int   best_tch = 0
            float best_sl  = 0.0
            int   b_end    = math.min(a + max_pair_gap, lo_prices.size() - 1)
            for b = a + 2 to b_end
                int   bb = lo_bars.get(b)
                float pb = lo_prices.get(b)
                if bb > ba
                    float sl = (pb - pa) / (bb - ba)
                    if math.abs(sl) <= slope_limit
                        int tch = f_touches(lo_prices, lo_bars, ba, pa, sl, touch_tol)
                        if tch > best_tch
                            if f_valid_sup(lo_prices, lo_bars, ba, pa, sl, touch_tol)
                                float proj_now = pa + sl * (bar_index - ba)
                                if proj_now < close
                                    best_tch := tch
                                    best_b   := b
                                    best_sl  := sl
            if best_b >= 0 and best_tch >= 3
                int   bb = lo_bars.get(best_b)
                float pb = lo_prices.get(best_b)
                bool dup = false
                if used_starts.size() > 0
                    for u = 0 to used_starts.size() - 1
                        if used_starts.get(u) == ba or used_starts.get(u) == bb
                            dup := true
                if not dup
                    hist_lines.push(line.new(ba, pa, bb, pb,
                         color = C_BULL, width = 1, style = line.style_dashed))
                    used_starts.push(ba)
                    used_starts.push(bb)
                    found_sup += 1

//-----------------------------------------------------------------------------}
// Cleanup — remove broken trendlines
//-----------------------------------------------------------------------------{
if confirmed
    float kill_dist = atr_val * 15

    if res_tls.size() > 1
        for i = res_tls.size() - 2 to 0
            TL t = res_tls.get(i)
            if bar_index > t.b2
                float proj = t.p1 + t.slope * (bar_index - t.b1)
                if close > proj or proj <= 0 or math.abs(proj - close) > kill_dist
                    line.delete(t.ln)
                    res_tls.remove(i)

    if sup_tls.size() > 1
        for i = sup_tls.size() - 2 to 0
            TL t = sup_tls.get(i)
            if bar_index > t.b2
                float proj = t.p1 + t.slope * (bar_index - t.b1)
                if close < proj or proj <= 0 or math.abs(proj - close) > kill_dist
                    line.delete(t.ln)
                    sup_tls.remove(i)

//-----------------------------------------------------------------------------}
// Breakout Detection
//-----------------------------------------------------------------------------{
bool bull_brk = false
bool bear_brk = false

if active_res_bar > 0 and confirmed
    float res_now  = active_res_price + active_res_slope * (bar_index - active_res_bar)
    float res_prev = active_res_price + active_res_slope * (bar_index - 1 - active_res_bar)
    if close > res_now and close[1] <= res_prev
        bull_brk := true

if active_sup_bar > 0 and confirmed
    float sup_now  = active_sup_price + active_sup_slope * (bar_index - active_sup_bar)
    float sup_prev = active_sup_price + active_sup_slope * (bar_index - 1 - active_sup_bar)
    if close < sup_now and close[1] >= sup_prev
        bear_brk := true

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if barstate.islast and i_show_lgnd
    var table leg = table.new(position.bottom_left, 2, 5,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 1,
         frame_color  = C_DASH_BORDER,
         frame_width  = 1)

    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "━",
         text_color = C_DASH_BULL, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 1, "Support trendline (swing lows)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 2, "━",
         text_color = C_DASH_BEAR, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 2, "Resistance trendline (swing highs)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 3, "┅",
         text_color = C_NEUTRAL, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 3, "Previous trendline (validated, unbroken)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    // Spacer for TradingView logo
    table.cell(leg, 0, 4, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(bull_brk, title = "Bullish Break",
     message = "EXCAVO Trendlines with Breaks: Bullish breakout on {{ticker}} ({{interval}})")
alertcondition(bear_brk, title = "Bearish Break",
     message = "EXCAVO Trendlines with Breaks: Bearish breakout on {{ticker}} ({{interval}})")
alertcondition(bull_brk or bear_brk, title = "Any Break",
     message = "EXCAVO Trendlines with Breaks: Breakout on {{ticker}} ({{interval}})")

if i_json and barstate.isconfirmed
    string _t  = syminfo.ticker
    string _p  = str.tostring(close, format.mintick)
    string _tf = timeframe.period
    if bull_brk
        alert('{"action":"breakout","direction":"bullish","ticker":"' + _t +
              '","price":"' + _p + '","timeframe":"' + _tf +
              '","indicator":"EXCAVO_Trendlines_With_Breaks"}', alert.freq_once_per_bar)
    if bear_brk
        alert('{"action":"breakout","direction":"bearish","ticker":"' + _t +
              '","price":"' + _p + '","timeframe":"' + _tf +
              '","indicator":"EXCAVO_Trendlines_With_Breaks"}', alert.freq_once_per_bar)
````
