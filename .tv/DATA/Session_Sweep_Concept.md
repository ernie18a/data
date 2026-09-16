<!-- tradingview-pine-id: PUB;cad103d248fb421d9294790cd6e4f6aa -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Session Sweep Concept

Source: https://www.tradingview.com/script/KBPImUAs-Session-Sweep-Concept-Achira-Meegasthanne/

## Description

Session Sweep Concept

Session Sweep Concept is a price-action and liquidity-based indicator designed to help traders visualize session ranges, identify liquidity sweeps, and monitor potential market-structure shifts.

The indicator focuses on the relationship between a Start Session and an End Session, using the previous session's high and low as important liquidity reference levels.

🔹 KEY FEATURES

Session Range Detection

Automatically identifies and displays the selected Start Session and End Session ranges.

You can customize:
• Start Session
• End Session
• Session ranges
• Session timezone
• Session colors

💧 Liquidity Sweep Detection

The indicator monitors previous session highs and lows for potential liquidity sweeps.

It can identify situations where price:
• Takes the previous session high
• Takes the previous session low
• Sweeps liquidity with a wick
• Breaks a level and later retests it

This allows traders to visually study how price interacts with previously established liquidity levels.

📊 Market Structure & BoS

After a session liquidity sweep, the indicator can monitor subsequent market structure and identify potential Break of Structure (BoS) events.

BoS markings help visualize a possible shift in short-term price structure following a liquidity event.

📈 Optional Trend Filter

An optional trend filter uses EMA and ATR-based slope calculations to determine whether the market is showing bullish, bearish, or neutral conditions.

The trend filter can be enabled or disabled from the settings.

🎯 Swing & Liquidity Visualization

The indicator can display:
• Session Highs
• Session Lows
• Swing Points
• Liquidity Sweep Areas
• Break of Structure
• Bullish/Bearish Structure
• Session-Based Bar Coloring

Liquidity sweeps can be configured using:
• Only Wicks
• Only Outbreaks & Retest
• Wicks + Outbreaks & Retest

⚙️ CUSTOMIZATION

The indicator provides multiple controls, including:

• Session visibility
• Swing-point visibility
• Market-structure visibility
• BoS visibility
• Session timezone
• Session colors
• Swing colors
• Structure colors
• Liquidity sweep mode
• Trend filter
• Session-end trade cutoff
• Debug information

🧠 HOW THE CONCEPT WORKS

1. Define the Start Session
The indicator establishes the session high and low.

2. Monitor the End Session
Price is observed as it interacts with the previous session's range.

3. Identify Liquidity Sweeps
A move above the previous high or below the previous low can indicate that liquidity has been taken.

4. Monitor Market Structure
Following the sweep, the indicator looks for a potential structure shift.

5. Identify BoS
A confirmed structure break is marked on the chart for further analysis.

The overall framework is:

Session Liquidity → Sweep → Market Structure → BoS Confirmation

⚠️ IMPORTANT DISCLAIMER

This indicator is an analytical and educational tool and does not guarantee profitable trading results.

Liquidity sweeps and Break of Structure signals can occur in many market conditions and should not be treated as standalone buy or sell signals.

Always perform your own analysis, use proper risk management, and test the indicator on historical and real-time market data before relying on it for live trading.

Use this tool to understand price behavior — not to predict the market with certainty.

---

## Source Code

````pine
//@version=6
indicator('Session Sweep Concept', overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// Input settings
show_asian = input.bool(true, 'Show Start Session', group = 'Visual Settings')
show_london = input.bool(true, 'Show End Session', group = 'Visual Settings')
show_swing_points = input.bool(true, 'Show End Swing Points', group = 'Visual Settings')
show_market_structure = input.bool(true, 'Show Market Structure', group = 'Visual Settings')
show_bos = input.bool(true, 'Show Break of Structure', group = 'Visual Settings')

//london / New_York
//asian_session = input.session("0300-0800", "London Session", group="Session Times")
//london_session = input.session("0800-1700", "New York Session", group="Session Times")

startsession = input.string('London', 'Start Session               ', group = 'Session Times', inline = '64')
asian_session = input.session('0300-0800', 'Start Session Range   ', group = 'Session Times', inline = '3')
endsession = input.string('NewYork', 'End Session                 ', group = 'Session Times', inline = '65')
london_session = input.session('0800-1700', 'End Session Range     ', group = 'Session Times', inline = '4')
session_timezone = input.string('America/New_York', 'Session Timezone       ', options = ['America/New_York', 'UTC-4', 'UTC', 'GMT'], group = 'Session Times', inline = '6')

force_london_close = input.bool(true, 'Force Close at End Session End', group = 'Entry Management')
cutoff_minutes = input.int(60, 'Minutes Before Session End to Stop New Trades', minval = 0, maxval = 300, group = 'Entry Management')
show_debug = input.bool(false, 'Show Debug Info', group = 'Entry Management')


asian_color = input.color(color.new(#871ee9, 0), 'Start Session Color', group = 'Arts')
london_color = input.color(color.new(#0df1c6, 0), 'End Session Color', group = 'Arts')
swing_high_color = input.color(color.new(#871ee9, 0), 'Swing High Color', group = 'Arts')
swing_low_color = input.color(color.new(#0df1c6, 0), 'Swing Low Color', group = 'Arts')
bullish_structure_color = input.color(color.new(#0df1c6, 0), 'Bullish Structure Color', group = 'Arts')
bearish_structure_color = input.color(color.new(#871ee9, 0), 'Bearish Structure Color', group = 'Arts')
bos_color = input.color(color.gray, 'Break of Structure Color', group = 'Arts')

line_width = 1 //input.int(1, "Line Width", minval=1, maxval=5, group="Arts")

// === Trend Conditions ===
groupEnhance = 'Trend Conditions'
tFilt = input.bool(false, 'Trend Filter      ', inline = '5', group = groupEnhance, display = display.none)
tFiltSen = input.int(150, '', inline = '5', group = groupEnhance, display = display.none)
tFiltatr = input.float(0.25, '', inline = '5', group = groupEnhance, display = display.none)

y1 = low - ta.atr(30) * 2
y2 = high + ta.atr(30) * 2

ma = ta.ema(close, tFiltSen)
TrendThreshold = tFiltatr
atrMa = ta.atr(tFiltSen)
slope = (ma - ma[1]) / (0.1 * atrMa)

isUpMa = slope > TrendThreshold
isDownMa = slope < -TrendThreshold
isNeutral = not isUpMa and not isDownMa

var dir = 0
dir := isUpMa ? 1 : isDownMa ? -1 : dir

// === Session Active Flags ===
asian_active = not na(time(timeframe.period, asian_session))
london_active = not na(time(timeframe.period, london_session))

// === Session Start/End Detection ===
asian_start = ta.change(asian_active) and asian_active
asian_end = ta.change(asian_active) and not asian_active
london_start = ta.change(london_active) and london_active
london_end = ta.change(london_active) and not london_active

// === Get Session Start/End Hour ===
var int asian_start_hour = na
var int asian_end_hour = na

if asian_start
    asian_start_hour := hour(time(timeframe.period, asian_session))
    asian_start_hour
if asian_end
    asian_end_hour := hour(time(timeframe.period, asian_session))
    asian_end_hour

var box asian_session_box = na
var label asian_session_name = na
var box london_session_box = na
var label london_session_name = na

var label hb = na
var label lb = na

if show_asian and asian_start
    asian_session_box := box.new(bar_index, high, bar_index + 1, low, border_color = asian_color, bgcolor = color.new(asian_color, 90), border_width = 1, border_style = line.style_dotted)
    asian_session_name := label.new(bar_index + 2, high, startsession, textcolor = asian_color, style = label.style_label_down, color = color.new(color.white, 100), size = size.tiny)
    asian_session_name

asian_session_length = asian_active and not na(asian_session_box) ? bar_index - box.get_left(asian_session_box) + 1 : 1

current_asian_high = ta.highest(high, asian_session_length)
current_asian_low = ta.lowest(low, asian_session_length)

if show_asian and asian_active and not na(asian_session_box)
    box.set_right(asian_session_box, bar_index)
    box.set_top(asian_session_box, current_asian_high)
    box.set_bottom(asian_session_box, current_asian_low)
    label.set_y(asian_session_name, current_asian_high)

if show_london and london_start
    london_session_box := box.new(bar_index, high, bar_index + 1, low, border_color = london_color, bgcolor = color.new(london_color, 90), border_width = 1, border_style = line.style_dotted)

    london_session_name := label.new(bar_index + 2, high, endsession, textcolor = london_color, style = label.style_label_down, color = color.new(color.white, 100), size = size.tiny)
    london_session_name
london_session_length = london_active and not na(london_session_box) ? bar_index - box.get_left(london_session_box) + 1 : 1

current_london_high = ta.highest(high, london_session_length)
current_london_low = ta.lowest(low, london_session_length)

if show_london and london_active and not na(london_session_box)
    box.set_right(london_session_box, bar_index)
    box.set_top(london_session_box, current_london_high)
    box.set_bottom(london_session_box, current_london_low)
    label.set_y(london_session_name, current_london_high)

// === Asian / London High Low Tracking ===
var float asian_session_high = na
var float asian_session_low = na
var int asian_high_bar = na
var int asian_low_bar = na

var float asian_absolute_high = na
var float asian_absolute_low = na
var line asian_high_line = na
var line asian_low_line = na
var label asian_high_label = na
var label asian_low_label = na
var bool high_broken = false
var bool low_broken = false

var float london_session_high = na
var float london_session_low = na

var string breakout_direction = na
var float last_hh_level = na
var float last_hl_level = na
var float last_ll_level = na
var float last_lh_level = na
var int structure_count = 0
var string last_structure_type = na

var float last_swing_high = na
var float last_swing_low = na
var int last_high_bar = na
var int last_low_bar = na

var float pending_high = na
var float pending_low = na
var int pending_high_bar = na
var int pending_low_bar = na
var bool waiting_for_confirmation = false

var float most_recent_hl = na
var float most_recent_lh = na
var int most_recent_hl_bar = na
var int most_recent_lh_bar = na
var bool bos_detected = false

var bool trade_taken = false

// === Build Asian Range ===
if asian_active and show_swing_points
    if na(asian_absolute_high) or high > asian_absolute_high
        asian_absolute_high := high
        asian_absolute_high

    if na(asian_absolute_low) or low < asian_absolute_low
        asian_absolute_low := low
        asian_absolute_low

    if na(asian_session_high) or high > asian_session_high
        asian_session_high := high
        asian_high_bar := bar_index
        asian_high_bar

    if na(asian_session_low) or low < asian_session_low
        asian_session_low := low
        asian_low_bar := bar_index
        asian_low_bar

// === Build London Range ===
if london_active
    if na(london_session_high) or high > london_session_high
        london_session_high := high
        london_session_high

    if na(london_session_low) or low < london_session_low
        london_session_low := low
        london_session_low

// === Draw Asian High / Low After Session End ===
if asian_end and show_swing_points
    if not na(asian_session_high) and not na(asian_high_bar)
        //asian_high_line := line.new(asian_high_bar, asian_session_high,bar_index + 200, asian_session_high,color=swing_high_color,width=1,style=line.style_dashed,extend=extend.right)
        asian_high_label := label.new(bar_index + 5, asian_session_high, startsession + ' High: ' + str.tostring(asian_session_high, '#.####'), style = label.style_label_left, color = color.new(swing_high_color, 50), textcolor = color.white, size = size.small)
        asian_high_label

    if not na(asian_session_low) and not na(asian_low_bar)
        //asian_low_line := line.new(asian_low_bar, asian_session_low,bar_index + 200, asian_session_low,color=swing_low_color,width=1,style=line.style_dashed,extend=extend.right)
        asian_low_label := label.new(bar_index + 5, asian_session_low, startsession + 'Low: ' + str.tostring(asian_session_low, '#.####'), style = label.style_label_left, color = color.new(swing_low_color, 50), textcolor = color.white, size = size.small)
        asian_low_label

    high_broken := false
    low_broken := false
    low_broken

// === London Sweep Detection ===
if london_active and show_swing_points and not na(asian_session_high) and not na(asian_session_low)

    if not high_broken and not low_broken and high > asian_session_high
        high_broken := true

        if not na(asian_high_line)
            line.set_x2(asian_high_line, bar_index)
            line.set_extend(asian_high_line, extend.none)

        if not na(asian_low_line)
            line.delete(asian_low_line)
        if not na(asian_low_label)
            label.delete(asian_low_label)

        if dir == -1
            hb := label.new(bar_index, y2, 'S', style = label.style_label_down, color = color.new(color.red, 50), textcolor = color.white, size = size.small)
            hb

        breakout_direction := 'bullish'
        last_swing_high := asian_session_high
        last_swing_low := asian_session_low
        last_high_bar := bar_index
        structure_count := 0
        structure_count

    if not low_broken and not high_broken and low < asian_session_low
        low_broken := true

        if not na(asian_low_line)
            line.set_x2(asian_low_line, bar_index)
            line.set_extend(asian_low_line, extend.none)

        if not na(asian_high_line)
            line.delete(asian_high_line)
        if not na(asian_high_label)
            label.delete(asian_high_label)

        if dir == 1
            lb := label.new(bar_index, y1, 'B', style = label.style_label_up, color = color.new(color.teal, 50), textcolor = color.white, size = size.small)
            lb

        breakout_direction := 'bearish'
        last_swing_high := asian_session_high
        last_swing_low := asian_session_low
        last_low_bar := bar_index
        structure_count := 0
        structure_count

// === Market Structure + BoS (UNCHANGED LOGIC) ===
if show_market_structure and not na(breakout_direction) and london_active and not bos_detected and not trade_taken

    if breakout_direction == 'bullish' and not na(most_recent_hl)
        if close < most_recent_hl and bar_index - most_recent_hl_bar >= 4
            line.new(most_recent_hl_bar, most_recent_hl, bar_index, most_recent_hl, color = bos_color, width = 1, style = line.style_dotted)
            label.new(bar_index, most_recent_hl, 'BoS', textcolor = bos_color, style = label.style_none)

            trade_taken := true
            bos_detected := true
            bos_detected

    if breakout_direction == 'bearish' and not na(most_recent_lh)
        if close > most_recent_lh and bar_index - most_recent_lh_bar >= 4
            line.new(most_recent_lh_bar, most_recent_lh, bar_index, most_recent_lh, color = bos_color, width = 1, style = line.style_dotted)
            label.new(bar_index, most_recent_lh, 'BoS', textcolor = bos_color, style = label.style_none)

            trade_taken := true
            bos_detected := true
            bos_detected

// === Reset Everything at New Asian Session ===
if asian_start and show_swing_points
    asian_session_high := na
    asian_session_low := na
    asian_high_bar := na
    asian_low_bar := na

    asian_absolute_high := na
    asian_absolute_low := na
    asian_high_line := na
    asian_low_line := na
    asian_high_label := na
    asian_low_label := na

    high_broken := false
    low_broken := false

    london_session_high := na
    london_session_low := na

    breakout_direction := na
    last_hh_level := na
    last_hl_level := na
    last_ll_level := na
    last_lh_level := na
    last_swing_high := na
    last_swing_low := na
    last_high_bar := na
    last_low_bar := na
    structure_count := 0
    last_structure_type := na

    pending_high := na
    pending_low := na
    pending_high_bar := na
    pending_low_bar := na
    waiting_for_confirmation := false

    most_recent_hl := na
    most_recent_lh := na
    most_recent_hl_bar := na
    most_recent_lh_bar := na
    bos_detected := false
    trade_taken := false
    trade_taken

// === Bar Coloring ===
barcolor(london_active ? london_color : asian_active ? asian_color : color.gray)
barcolor(tFilt ? dir == 1 ? color.teal : color.red : na)

// === Debug Table ===
if show_debug
    var table debug_table = table.new(position.top_right, 2, 3, bgcolor = color.white, border_width = 1)
    if barstate.islast
        table.cell(debug_table, 0, 0, 'Current Hour', text_color = color.black)
        table.cell(debug_table, 1, 0, str.tostring(hour(time, session_timezone)), text_color = color.black)
        table.cell(debug_table, 0, 1, startsession + ' Active', text_color = color.black)
        table.cell(debug_table, 1, 1, str.tostring(asian_active), text_color = color.black)
        table.cell(debug_table, 0, 2, endsession + ' Active', text_color = color.black)
        table.cell(debug_table, 1, 2, str.tostring(london_active), text_color = color.black)

//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
len = input.int(5, 'Swings', minval = 1, group = 'Liquidity Sweeps')
opt = input.string('Only Wicks', 'options', options = ['Only Wicks', 'Only Outbreaks & Retest', 'Wicks + Outbreaks & Retest'], group = 'Liquidity Sweeps')

colBl = london_active ? #089981 : color.new(#089981, 80)
colBr = london_active ? #f23645 : color.new(#f23645, 80)
colBl2 = london_active ? #08998180 : color.new(#08998180, 80)
colBr2 = london_active ? #f2364580 : color.new(#f2364580, 80)

extend = true //input.bool(true, 'Extend', group='Sweep Area') 
maxB = 300 //nput.int(300, 'Max bars', minval=1, maxval=5000, group='Sweep Area')
colBl3 = london_active ? #08998141 : color.new(#08998141, 80)
colBr3 = london_active ? #f2364541 : color.new(#f2364541, 80)

oW = opt == 'Only Wicks'
oO = opt == 'Only Outbreaks & Retest'
WO = opt == 'Wicks + Outbreaks & Retest'

n = bar_index

//-----------------------------------------------------------------------------}      
//UDT's
//-----------------------------------------------------------------------------{
type piv
	float prc // price
	int bix // bar_index
	bool brk // broken
	bool mit // mitigated
	bool tak // taken
	bool wic // wick
	line lin

type boxBr
	box bx
	line ln
	bool br
	int dr

//-----------------------------------------------------------------------------}      
//Variables
//-----------------------------------------------------------------------------{
var array<piv> aPivH = array.new<piv>(1, piv.new())
var array<piv> aPivL = array.new<piv>(1, piv.new())
var array<boxBr> aBoxBr = array.new<boxBr>(1, boxBr.new())

//-----------------------------------------------------------------------------}      
//Methods - functions
//-----------------------------------------------------------------------------{
method n(float piv) =>
    bool out = not na(piv)
    out

method p(piv piv, float val) =>
    float out = 100 / piv.prc * val - 100
    out

method l(piv get, color c, string s = 'sd') =>
    style = switch s
        'dt' => line.style_dotted
        'ds' => line.style_dashed
        => line.style_solid
    line.new(get.bix, get.prc, n, get.prc, color = c, style = style)

method br(piv get, color c3, color c, int d) =>
    y1 = d == 1 ? high : get.prc
    y2 = d == 1 ? get.prc : low
    boxBr.new(box.new(n - 1, y1, n + 1, y2, border_color = color.new(na, na), bgcolor = c3), line.new(n, y1, n, y2, color = c, width = 3), false, d)

lnDot(y, c) =>
    line.new(n, y, n + 3, y, color = c, style = line.style_dotted)

//-----------------------------------------------------------------------------}      
//Execution
//-----------------------------------------------------------------------------{
ph = ta.pivothigh(len, len)
pl = ta.pivotlow(len, len)

if ph.n()
    aPivH.unshift(piv.new(ph, n - len, false, false, false, false))

if pl.n()
    aPivL.unshift(piv.new(pl, n - len, false, false, false, false))

for i = aPivH.size() - 1 to 0 by 1
    get = aPivH.get(i)
    if not get.mit
        if not get.brk
            if close > get.prc
                if not oW
                    get.brk := true
                    get.brk
                else
                    get.mit := true
                    get.mit
            if not oO and not get.wic
                if high > get.prc and close < get.prc
                    aBoxBr.unshift(get.br(colBr3, colBr, 1))
                    get.l(colBr2, 'dt')
                    lnDot(low, colBr)
                    get.wic := true
                    get.wic
        else
            if close < get.prc
                get.mit := true
                get.mit
            if not oW and low < get.prc and close > get.prc
                aBoxBr.unshift(get.br(colBl3, colBl, -1))
                get.l(colBl2, 'ds')
                lnDot(high, colBl)
                get.tak := true
                get.tak

    if n - get.bix > 2000 or get.mit or get.tak
        aPivH.remove(i).lin.delete()

for i = aPivL.size() - 1 to 0 by 1
    get = aPivL.get(i)
    if not get.mit
        if not get.brk
            if close < get.prc
                if not oW
                    get.brk := true
                    get.brk
                else
                    get.mit := true
                    get.mit
            if not oO and not get.wic
                if low < get.prc and close > get.prc
                    aBoxBr.unshift(get.br(colBl3, colBl, -1))
                    get.l(colBl2, 'dt')
                    lnDot(high, colBl)
                    get.wic := true
                    get.wic
        else
            if close > get.prc
                get.mit := true
                get.mit
            if not oW and high > get.prc and close < get.prc
                aBoxBr.unshift(get.br(colBr3, colBr, 1))
                get.l(colBr2, 'ds')
                lnDot(low, colBr)
                get.tak := true
                get.tak

    if n - get.bix > 2000 or get.mit or get.tak
        aPivL.remove(i).lin.delete()

if extend
    for bx in aBoxBr
        if not bx.br and n - bx.bx.get_left() - 1 <= maxB
            bx.bx.set_right(bar_index)
            if bx.dr == -1 and close < bx.bx.get_bottom()
                bx.br := true
                bx.br
            if bx.dr == 1 and close > bx.bx.get_top()
                bx.br := true
                bx.br

//-----------------------------------------------------------------------------}
````
