<!-- tradingview-pine-id: PUB;b72515f6e8794a188305698fa3510e8a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Levels

Source: https://www.tradingview.com/script/fPh1mr3r-Liquidity-Levels/

## Description

Liquidity Levels finds confirmed swing pivots on your chart and merges nearby ones into clusters. Each cluster is drawn as a horizontal line, and the label tells you how many separate pivots landed there.

The core idea: a level that price has rejected seven times is not the same as a level price touched once. The indicator makes that difference visible at a glance.

How to read the chart
The label is the signal. The x number is the touch count.

Label	Meaning	Conviction
x7 cluster	Seven pivots merged	Wall — highest conviction
x3 cluster	Three pivots merged	Solid, tradeable
(no label)	Single pivot	Thin — low conviction
Line weight and opacity scale with touch count. Thick and opaque = many touches. Thin and dashed = one. You should be able to read the chart's hierarchy without reading a single number.

Colour: Orange = resistance (pivot highs). Blue = support (pivot lows).

The two inputs that matter
Length (default 10) — Bars required either side to confirm a pivot. Higher = fewer, more significant swings. Lower = more levels, more noise.

This is deliberately set to 10 to match Turtle Soup PRO's mssOffset, so both indicators agree on what counts as a swing. If you change one, change the other — otherwise Turtle Soup can sweep a level this indicator never drew, and you'll see signals "at nothing."

Volume Filter — A ratio vs the 20-bar SMA, not a percentage. 1.0 means the pivot bar's volume must exceed the 20-bar average.

⚠️ Thin-session warning. On Sunday reopen, holidays, or the 16:00–16:30 window, volume is erratic and the 20-bar average gets dragged up by the open burst. A 1.0 filter can starve the script and draw nothing at all. Blank chart ≠ broken script — check this input first.

How to use it
1. Mark the walls first. Find the highest touch counts. Those are your structural levels for the session — targets and invalidation points.

2. Measure the distance. A wall 20+ points away is a target. A level 3 points away is a decision point you're about to hit.

3. Ignore single touches unless price is reacting to one right now.

4. Use it as a map, not a trigger. This indicator has no directional opinion by design. It never tells you to buy or sell. It tells you where the liquidity sits — the trigger comes from your entry system.

Using it with Turtle Soup PRO
Liquidity Levels is the map. Turtle Soup PRO is the trigger.

Question	Indicator
WHERE is the liquidity?	Liquidity Levels
WHEN did it get swept?	Turtle Soup PRO
The workflow:

Mark the walls (Liquidity Levels)
Read the backdrop (Turtle Soup dashboard — trend is context, not trigger)
Wait for a sweep at a level that matters
Take Turtle Soup's entry / SL / TP
Manage into the next cluster
The golden rule: a sweep at a 7-touch wall is the best setup on the chart. A sweep at a single touch is noise. The map is what separates them.

Common mistakes
Taking every sweep. Sweeps happen constantly. Only the ones at high-count clusters matter.

Treating it as a signal. It draws levels. It does not generate entries.

Forgetting the volume filter on thin sessions. Blank chart → check the filter before assuming the script broke.

Changing len without changing Turtle Soup's mssOffset. The two must stay aligned or they'll disagree about structure.

Under the hood (for the script-minded)
Pivot detection uses ta.pivothigh / ta.pivotlow with the len input
Clustering merges pivots within a tolerance band, incrementing the touch count
History buffers are explicitly declared via max_bars_back(...) on reassigned series variables (volSeries, hlc3Series, closeSeries, openSeries), and every dynamic-index site references those declared variables — not the built-ins. This is the defensive pattern that prevents runtime errors if the lookback is ever deepened.
⚠️ Educational, not financial advice — size to your own risk tolerance.

---

## Source Code

````pine
// author, Midniteblade inspired by BigBeluga

//@version=6
indicator('Liquidity Levels', overlay = true, max_labels_count = 500, calc_bars_count = 1000, max_lines_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
int len = input.int(10, 'Length', minval = 1, inline = 'levels', tooltip = 'Bars either side required to confirm a pivot. Match this to Turtle Soup PRO mssOffset (10) so both indicators agree on what counts as a swing.')
float filter = input.float(1.0, 'Volume Filter', step = 0.1, minval = 0, maxval = 10, inline = 'levels', tooltip = 'Minimum pivot-bar volume as a multiple of the 20-bar average volume. 1.0 = average volume, 1.5 = 50% above average.')
bool sweep = input.bool(true, 'Liquidity sweep', tooltip = 'Display check marks where liquidity was swept.')
float cluster_tol = input.float(0.15, 'Cluster Tolerance %', step = 0.05, minval = 0, maxval = 5, inline = 'levels', tooltip = 'If a new pivot forms within this % of an existing level, merge them into a cluster instead of drawing a new line. The existing line thickens with each touch.')

color col_up = input.color(color.blue, '⤓', inline = 'color', group = 'Color')
color col_dn = input.color(color.orange, '⤒', inline = 'color', group = 'Color')

int max_width = input.int(4, 'Max Line Width', minval = 1, maxval = 5, group = 'Dynamic Intensity')
int min_transp = input.int(0, 'Min Transparency (Intense)', minval = 0, maxval = 100, group = 'Dynamic Intensity')
int max_transp = input.int(60, 'Max Transparency (Faded)', minval = 0, maxval = 100, group = 'Dynamic Intensity')
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// History buffers — Pine rejects built-in series as the first max_bars_back arg,
// so reassign to user-declared series first (same pattern as Turtle Soup PRO).
volSeries = volume
hlc3Series = hlc3
closeSeries = close
openSeries = open
max_bars_back(volSeries, 5000)
max_bars_back(hlc3Series, 5000)
max_bars_back(closeSeries, 5000)
max_bars_back(openSeries, 5000)

float vol_avg = ta.sma(volume, 20)
bool pivot_low = not na(ta.pivotlow(len, len)) and volSeries[len] >= vol_avg[len] * filter
bool pivot_high = not na(ta.pivothigh(len, len)) and volSeries[len] >= vol_avg[len] * filter

type level
    line ln
    label lb
    bool is_support // true if pivot low (supports), false if pivot high (resistances)
    int touches
    color base_col

var level[] levels = array.new<level>()

update_levels() =>
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0 by 1
            level lv = array.get(levels, i)
            float price = lv.ln.get_y2()
            
            lv.ln.set_x2(bar_index + 25)
            
            lv.lb.set_x(bar_index + 25)
            
            // Sweep Logic
            bool low_sweep = lv.is_support and low < price and close > price
            bool high_sweep = not lv.is_support and high > price and close < price
            
            if sweep and (low_sweep or high_sweep) and barstate.isconfirmed
                label.new(bar_index, low_sweep ? low : high, '✔', style = low_sweep ? label.style_label_up : label.style_label_down, color = color(na), textcolor = low_sweep ? col_up : col_dn, tooltip = "Liquidity Sweep")

            // Break Logic
            bool line_break = high > price and low < price and barstate.isconfirmed
            if line_break
                lv.ln.set_extend(extend.none)
                lv.ln.set_x2(bar_index)
                lv.ln.set_style(line.style_dotted)
                if not na(lv.lb)
                    lv.lb.delete()
                array.remove(levels, i)

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
float vol_ratio_now = vol_avg[len] > 0 ? volSeries[len] / vol_avg[len] : 1.0
float vr_min = ta.lowest(vol_ratio_now, 100)
float vr_max = ta.highest(vol_ratio_now, 100)

if last_bar_index - bar_index < 2000
    float vol_factor = vr_max > vr_min ? (vol_ratio_now - vr_min) / (vr_max - vr_min) : 0.5
    int dynamic_width  = math.round(1 + (max_width - 1) * vol_factor)
    int dynamic_transp = math.round(max_transp + (min_transp - max_transp) * vol_factor)

    if pivot_low or pivot_high
        float price = pivot_low ? low[len] : high[len]
        color c = pivot_low ? col_up : col_dn

        int match_idx = -1
        if array.size(levels) > 0
            for i = 0 to array.size(levels) - 1
                level lv = array.get(levels, i)
                if lv.is_support == pivot_low
                    float lv_price = lv.ln.get_y2()
                    if lv_price > 0 and math.abs(price - lv_price) / lv_price * 100 <= cluster_tol
                        match_idx := i
                        break

        if match_idx >= 0
            level lv = array.get(levels, match_idx)
            lv.touches += 1
            float new_w = math.min(max_width + 2, 1 + (max_width - 1) * vol_factor + (lv.touches - 1))
            lv.ln.set_width(int(new_w))
            lv.ln.set_color(color.new(c, dynamic_transp))
            lv.ln.set_x2(bar_index + 25)
            if not na(lv.lb)
                lv.lb.set_x(bar_index + 25)
                lv.lb.set_text(str.tostring(math.round(lv.ln.get_y2(), 1)) + '  x' + str.tostring(lv.touches))
        else
            line ln = line.new(bar_index - len, price, bar_index + 5, price, color = color.new(c, dynamic_transp), width = dynamic_width)
            label lb = label.new(bar_index, price, str.tostring(math.round(price, 1)), style = label.style_label_lower_left, color = c, textcolor = color.white, size = size.small)
            array.push(levels, level.new(ln, lb, pivot_low, 1, c))

    update_levels()
````
