# Gap Fill Tracker

- url: https://www.tradingview.com/script/vSVfMiwy/
- type: indicator
- pine_id: PUB;6260b0f9379c4606856689c5d04c7fd2
- version: 1.0

## Description

Gap Fill Tracker
 
The Gap Fill Tracker is an overlay indicator that automatically detects, tracks, and measures the fill rate of price gaps — defined as the difference between the previous candle's close and the current candle's open. It counts a gap as filled when price reaches the 50% midpoint of the gap range, and provides a live statistics panel including total gaps detected, fill rate percentage, open gaps, and the average time gaps take to fill expressed in human-readable time units adapted to the current chart timeframe.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IS A GAP?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
A gap occurs when a candle opens at a different price than the previous candle's close, leaving an unfilled zone on the chart. Bullish gaps open above the prior close. Bearish gaps open below the prior close. Gaps can occur on any timeframe and any instrument, and they represent price imbalances — zones where no trading occurred, which the market tends to revisit.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FILL CONDITION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
A gap is considered filled when price touches the 50% midpoint of the gap range — not necessarily the full extent. This is a more conservative and statistically accurate measure than requiring a full gap fill, as it captures the point at which the market has revisited the center of the imbalance. The midpoint is marked on the chart as a dashed line through the middle of each open gap zone.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPONENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
1. Gap Zones (boxes)
   Each detected gap is visualized as a colored rectangle spanning from the gap's lower boundary to its upper boundary, starting at the bar where the gap occurred and extending to the right. Bullish gaps are displayed in teal. Bearish gaps are displayed in pink. Zones disappear silently when the fill condition is met — no confirmation markers are left on the chart, keeping it clean.
 
2. Midpoint Line (dashed)
   A dashed horizontal line runs through the center of each open gap zone, marking the exact price level that constitutes a fill. This is the target level the indicator monitors.
 
3. Gap Labels
   Small labels mark the bar where each gap was detected, indicating direction (GAP ↑ for bullish, GAP ↓ for bearish).
 
4. Statistics Table (top right)
   A compact panel displays four key metrics updated in real time:
   - Detected: total number of gaps found in the chart's history
   - Filled: number of gaps that reached the 50% midpoint, with fill rate percentage
   - Open: number of gaps still unfilled, with open rate percentage
   - Avg fill time: average time gaps take to reach the 50% midpoint, expressed automatically in minutes, hours, days, or weeks depending on the chart timeframe
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
• Minimum gap (%): The minimum size of a gap expressed as a percentage of the prior close, to filter out micro-gaps caused by spread or rounding. Default is 0.5%. Lower values detect more gaps; higher values focus only on significant gaps.
 
• Max open gaps visible: Controls how many of the most recent unfilled gaps are displayed on the chart. Older open gaps continue to count in the statistics but are hidden visually to keep the chart readable. Default is 10.
 
• Show open zones: Toggle the visual display of open gap zones on or off. Statistics continue to update regardless.
 
• Bull/Bear gap colors: Customize the colors for bullish and bearish gap zones independently.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO INTERPRET IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
FILL RATE
The fill rate shown in the statistics panel tells you what percentage of historical gaps on this instrument and timeframe have been filled. A fill rate above 95% confirms that gap fills are a near-certain statistical event for this market. A lower fill rate suggests that the instrument or timeframe has structural tendencies that prevent consistent gap fills — for example, strongly trending markets on higher timeframes.
 
OPEN GAPS
Each visible zone on the chart represents an active price target — a level where the market has a strong statistical tendency to return. The more open gaps accumulated above or below current price, the stronger the magnetic pull toward those levels.
 
MIDPOINT LINE
The dashed line through each zone is the exact fill target. Price touching this level — even with a wick — constitutes a fill and removes the zone from the chart.
 
AVERAGE FILL TIME
This is the most operationally useful metric. It tells you how long gaps on this instrument and timeframe typically take to fill, expressed in real time units. If the average fill time on a 4-hour chart is 1.1 weeks, that means most gaps are filled within approximately 1 to 2 weeks of forming. This information can be used to time entries — rather than entering immediately after a gap forms, waiting until price approaches the average fill window increases the probability of catching the fill move at the right moment.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
1. CHECK THE FILL RATE FIRST
   Load the indicator on your instrument and timeframe of choice. Check the fill rate in the statistics panel. If it is above 95%, gap fills are a reliable statistical edge on that market. If it is significantly lower, adjust the minimum gap size or consider a different timeframe.
 
2. IDENTIFY OPEN GAPS AS PRICE TARGETS
   The visible zones on the chart are active price targets. Open gaps above current price are upside targets. Open gaps below current price are downside targets. The midpoint line is the specific price level to watch.
 
3. USE THE AVERAGE FILL TIME FOR ENTRY TIMING
   Note the average fill time displayed in the table. After a gap forms, use this as a reference for when to start looking for an entry toward the fill. If the average fill time is 1 week on a daily chart, the highest probability entry window is typically in the days surrounding that average, not immediately after the gap opens.
 
4. MANAGE THE TRADE
   The target is the midpoint of the gap. Once price touches the midpoint, the zone disappears automatically. Position sizing, stop placement, and exit management are left to the trader's discretion and should be based on their own risk framework.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
• Works on any instrument and any timeframe. Fill rates and average fill times vary by market and timeframe — always verify the statistics panel before trading.
• The average fill time automatically adapts to the chart's timeframe: it displays in minutes on intraday charts, hours on hourly charts, days on daily charts, and weeks on weekly charts.
• Filled gaps disappear silently without leaving markers on the chart, ensuring a clean visual at all times.
• The statistics counter covers the full available chart history, not just the visible bars on screen.
• For instruments that trade 24/5 (forex) or 24/7 (crypto), the average fill time reflects calendar time based on bar count times timeframe minutes. For instruments with trading sessions (equities, futures), the actual calendar time will be longer since no bars are generated outside market hours.

## Source Code

````pine
//@version=6
indicator("Gap Fill Tracker", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
min_gap_pct  = input.float(0.5, "Minimum gap (%)",           minval=0.01, step=0.01)
max_open     = input.int(10,    "Max open gaps visible",     minval=1, maxval=50)
show_zones   = input.bool(true, "Show open zones")
bull_col     = input.color(color.teal,                       "Bull gap color")
bear_col     = input.color(color.rgb(255, 102, 178),         "Bear gap color")

// ─── PRECARGA DE HISTORIAL ────────────────────────────────────────────────────
var float _ph = ta.highest(high, 500)
var float _pl = ta.lowest(low,   500)
var float _pc = nz(close[1])

// ─── TIMEFRAME EN MINUTOS ─────────────────────────────────────────────────────
float tf_minutes = timeframe.isseconds  ? timeframe.multiplier / 60.0
                 : timeframe.isintraday ? float(timeframe.multiplier)
                 : timeframe.isdaily    ? timeframe.multiplier * 1440.0
                 : timeframe.isweekly   ? timeframe.multiplier * 10080.0
                 : timeframe.ismonthly  ? timeframe.multiplier * 43200.0
                 : float(timeframe.multiplier)

// ─── GAP DETECTION ────────────────────────────────────────────────────────────
float prev_close   = nz(close[1])
float gap_pct_up   = prev_close > 0 and open > prev_close ? (open - prev_close) / prev_close * 100 : 0.0
float gap_pct_down = prev_close > 0 and open < prev_close ? (prev_close - open) / prev_close * 100 : 0.0

bool is_gap_up   = gap_pct_up   >= min_gap_pct
bool is_gap_down = gap_pct_down >= min_gap_pct

// ─── ARRAYS ───────────────────────────────────────────────────────────────────
var array<float> g_tops  = array.new_float()
var array<float> g_bots  = array.new_float()
var array<float> g_mids  = array.new_float()
var array<bool>  g_up    = array.new_bool()
var array<int>   g_bars  = array.new_int()
var array<box>   g_boxes = array.new_box()
var array<line>  g_lines = array.new_line()

var int   total_gaps   = 0
var int   filled_gaps  = 0
var int   open_gaps    = 0
var float total_bars_to_fill = 0.0  // acumula barras hasta fill

// ─── REGISTER GAP ─────────────────────────────────────────────────────────────
if (is_gap_up or is_gap_down) and barstate.isconfirmed
    bool  bull = is_gap_up
    float gt   = bull ? open       : prev_close
    float gb   = bull ? prev_close : open
    float gm   = (gt + gb) / 2

    array.push(g_tops,  gt)
    array.push(g_bots,  gb)
    array.push(g_mids,  gm)
    array.push(g_up,    bull)
    array.push(g_bars,  bar_index)
    total_gaps += 1
    open_gaps  += 1

    array.push(g_boxes, box.new(bar_index, close, bar_index, close, border_color=color.new(color.white, 100)))
    array.push(g_lines, line.new(bar_index, close, bar_index, close, color=color.new(color.white, 100)))

    label.new(bar_index, bull ? gb : gt,
         text      = bull ? "GAP ↑" : "GAP ↓",
         color     = bull ? color.new(bull_col, 20) : color.new(bear_col, 20),
         textcolor = color.white,
         style     = bull ? label.style_label_down : label.style_label_up,
         size      = size.tiny)

// ─── FILL CHECK (50% midpoint) ────────────────────────────────────────────────
if array.size(g_tops) > 0
    int i = 0
    while i < array.size(g_tops)
        float gm    = array.get(g_mids, i)
        int   g_bar = array.get(g_bars, i)
        bool  bull  = array.get(g_up,   i)

        if bar_index > g_bar
            bool filled = bull ? low <= gm : high >= gm
            if filled
                box.delete(array.get(g_boxes, i))
                line.delete(array.get(g_lines, i))
                total_bars_to_fill += float(bar_index - g_bar)
                array.remove(g_tops,  i)
                array.remove(g_bots,  i)
                array.remove(g_mids,  i)
                array.remove(g_up,    i)
                array.remove(g_bars,  i)
                array.remove(g_boxes, i)
                array.remove(g_lines, i)
                filled_gaps += 1
                open_gaps   -= 1
            else
                i += 1
        else
            i += 1

// ─── DRAW ONLY N MOST RECENT OPEN GAPS ───────────────────────────────────────
if (barstate.isconfirmed or barstate.islast) and show_zones
    int total_open = array.size(g_tops)

    if total_open > 0
        int start_idx = math.max(0, total_open - max_open)

        for i = 0 to total_open - 1
            box.delete(array.get(g_boxes, i))
            line.delete(array.get(g_lines, i))

        for i = start_idx to total_open - 1
            float gt   = array.get(g_tops, i)
            float gb   = array.get(g_bots, i)
            float gm   = array.get(g_mids, i)
            bool  bull = array.get(g_up,   i)
            int   gbar = array.get(g_bars, i)

            array.set(g_boxes, i, box.new(gbar, gt, bar_index + 50, gb,
                 border_color = bull ? color.new(bull_col, 40) : color.new(bear_col, 40),
                 bgcolor      = bull ? color.new(bull_col, 80) : color.new(bear_col, 80)))
            array.set(g_lines, i, line.new(gbar, gm, bar_index + 50, gm,
                 color = bull ? color.new(bull_col, 30) : color.new(bear_col, 30),
                 width = 1,
                 style = line.style_dashed))

// ─── STATS TABLE ──────────────────────────────────────────────────────────────
float pct_filled  = total_gaps  > 0 ? filled_gaps / total_gaps * 100 : 0.0
float pct_open    = total_gaps  > 0 ? open_gaps   / total_gaps * 100 : 0.0
float avg_bars    = filled_gaps > 0 ? total_bars_to_fill / filled_gaps : 0.0
float avg_minutes = avg_bars * tf_minutes

// Formatear tiempo legible
string avg_time_str = ""
if avg_minutes < 60
    avg_time_str := str.tostring(math.round(avg_minutes)) + " min"
else if avg_minutes < 1440
    avg_time_str := str.tostring(math.round(avg_minutes / 60, 1)) + " h"
else if avg_minutes < 10080
    avg_time_str := str.tostring(math.round(avg_minutes / 1440, 1)) + " d"
else
    avg_time_str := str.tostring(math.round(avg_minutes / 10080, 1)) + " w"

var table panel = table.new(position.top_right, 2, 5, border_width=1)

if barstate.islast
    table.cell(panel, 0, 0, "GAP FILL TRACKER", text_color=color.white, bgcolor=color.gray,                   text_size=size.small)
    table.cell(panel, 1, 0, "TOTAL / %",         text_color=color.white, bgcolor=color.gray,                   text_size=size.small)
    table.cell(panel, 0, 1, "Detected",          text_color=color.white, bgcolor=color.new(color.gray,   40),  text_size=size.small)
    table.cell(panel, 1, 1, str.tostring(total_gaps), text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.small)
    table.cell(panel, 0, 2, "Filled",            text_color=color.white, bgcolor=color.new(color.teal,   20),  text_size=size.small)
    table.cell(panel, 1, 2, str.tostring(filled_gaps) + "  " + str.tostring(math.round(pct_filled, 2)) + "%", text_color=color.white, bgcolor=color.new(color.teal, 20), text_size=size.small)
    table.cell(panel, 0, 3, "Open",              text_color=color.white, bgcolor=color.new(color.orange, 20),  text_size=size.small)
    table.cell(panel, 1, 3, str.tostring(open_gaps) + "  " + str.tostring(math.round(pct_open, 2)) + "%", text_color=color.white, bgcolor=color.new(color.orange, 20), text_size=size.small)
    table.cell(panel, 0, 4, "Avg fill time",     text_color=color.white, bgcolor=color.new(color.blue,  40),  text_size=size.small)
    table.cell(panel, 1, 4, avg_time_str,         text_color=color.white, bgcolor=color.new(color.blue,  40),  text_size=size.small)
````
