# HTF Fractal Bars [Herman]

- url: https://www.tradingview.com/script/Z8uVypGa-HTF-Fractal-Bars-Herman/
- type: indicator
- pine_id: PUB;9a51132ab1474008a745ce0eca0befc4
- version: 1.0

## Description

[b]HTF Fractal Bars [Herman] [/b]shows up to three higher-timeframe (HTF) OHLC bar panels to the right of price, built directly from the chart's own bars. It adds a Fractal Agreement engine that classifies what each HTF's live bar is doing relative to the previous closed HTF bar, and scores how strongly the selected timeframes agree on direction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]█ WHAT IT DOES[/b]

 ▸ Draws compact OHLC panels for up to three higher timeframes (default 15m / 1h / 4h) next to the current price, so the higher-timeframe structure stays visible while you work on a lower-timeframe chart.
 ▸ Labels the last three HTF bars in each panel as C1, C2 and C3:
    C1 = two closed HTF bars ago
    C2 = the last closed HTF bar
    C3 = the live (still forming) HTF bar
 ▸ Marks sweeps (a bar trading beyond the previous bar's high or low and closing back inside it) and three-bar fair value gaps between HTF bars.
 ▸ Projects the HTF1 C1 / C2 / C3 highs and lows, the C3 open and optional period separators onto the main chart.
 ▸ Classifies the phase of each HTF's live bar and combines the three phases into one weighted agreement reading, shown in a table with a progress bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]█ HOW IT WORKS[/b]

▸ HTF bars from chart data
The script does not request data from another timeframe. Each HTF bar is aggregated from the chart's own bars: open, high, low and close, plus the exact chart bar on which the high and the low were made. Because of this, the HTF levels projected onto the chart start at the bar where each extreme actually formed, and the panels always show the same price data as your chart.

▸ Phase classification
For every enabled HTF, the live bar (C3) is compared with the last closed bar (C2):

 - Expansion ▲ / ▼ — C3 has traded beyond C2's high (low) and price is accepted beyond it
 - High swept ▼ — C3 has traded above C2's high, but price is back at or below it
 - Low swept ▲ — C3 has traded below C2's low, but price is back at or above it
 - Outside ▲ / ▼ / · — C3 has taken both sides of C2; the direction depends on whether price is above, below or inside C2's range
 - Inside · — C3 has not taken either side of C2 yet

"Accepted beyond" means price is past the level by at least the Acceptance buffer (in ticks, default 0).

▸ Agreement score
Each phase counts as bullish (+1), bearish (−1) or neutral (0). This value is multiplied by the timeframe's weight (default 1 / 2 / 3, so higher timeframes carry more weight). Agreement is the absolute weighted sum divided by the total weight of the active timeframes, shown as a percentage together with a direction. Neutral phases lower the agreement because they still count in the total weight.

Example with default weights: 15m High swept ▼ (bearish), 1h Inside (neutral), 4h Expansion ▼ (bearish). The weighted sum is −1 + 0 − 3 = −4 out of a total weight of 6, so the table reads Bearish, 67%.

At least two active timeframes are required; with fewer, the table shows "Need 2+ HTFs".

▸ Update modes
 - On chart-bar close (default): phases are evaluated with the last closed chart bar, so the table does not change while a chart bar is forming.
 - Live (every tick): phases follow the forming chart bar and can change until it closes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]█ WHAT YOU SEE[/b]

 ▸ HTF panels: classic OHLC bars (vertical line = high/low, left tick = open, right tick = close) with C1 / C2 / C3 tags, dotted high/low marks, sweep lines and grey FVG zones.
 ▸ Main chart: HTF1 C1 / C2 / C3 highs and lows, the C3 open, optional separators and an optional developing C3 range box.
 ▸ Table (bottom right by default):
    Bias — Bullish / Bearish / Conflict / Neutral
    Agreement — a shaded progress bar and the percentage
    Aligned — number of bullish, bearish and neutral timeframes
    Update — the active update mode
    HTF Phase — the current phase of each timeframe

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]█ HOW TO USE IT[/b]

 1. Use a standard intraday chart (for example 1m or 5m) and choose HTFs that are higher than, and exact multiples of, the chart timeframe.
 2. Read the panels first: where C3 is relative to C2, and whether a sweep or a gap is involved.
 3. Use the table as context. High agreement means the selected timeframes are in the same phase direction; Conflict means they are pulling in different directions.
 4. A common way to use it is as a filter: favour setups from your own method only when they point in the same direction as the HTF bias, and be more selective when agreement is low or in conflict.
 5. Adjust the weights to match your style. A weight of 0 keeps a timeframe visible in the table but removes it from the score.

The agreement reading describes the current state of the higher timeframes. It is not a buy or sell signal, and it should not be used on its own to make trading decisions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]
█ KEY SETTINGS[/b]

 ▸ HTF panels — three timeframes with on/off switches, number of bars shown (3–8), offset, spacing and gap between panels
 ▸ Markings — C1 / C2 / C3 tags, level marks, sweeps, FVG zones and main-chart structure for HTF1
 ▸ Style — every colour, transparency and line width
 ▸ Agreement Table — on/off, Dark / Light theme, size and position
 ▸ Fractal Agreement engine — update mode, acceptance buffer, per-timeframe weights and progress bar length

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]█ WHAT IS ORIGINAL[/b]

Displaying higher-timeframe bars on a lower-timeframe chart is not new. What this script adds:

 ▸ A phase classifier that reads each HTF's live bar in terms of range interaction with the previous closed bar (expansion, sweep and rejection, outside, inside), rather than trend indicators or moving averages.
 ▸ A weighted agreement score across up to three timeframes, with an optional bar-close update mode so the reading is stable inside a forming chart bar.
 ▸ HTF bars aggregated from chart data with the time of each extreme preserved, so the projected levels start where the high or low actually formed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]█ LIMITATIONS[/b]

 ▸ The panels are a visual display placed to the right of the last bar. They are not positioned in time.
 ▸ C3 is a live bar. Its high, low and close change until the HTF bar closes, so its phase, and any sweep or gap marks that involve C3, are provisional until then. Closed bars (C1, C2 and older) do not change.
 ▸ In Live mode the table can change on every tick. In the default bar-close mode it updates once per closed chart bar, so it lags the live price by up to one chart bar.
 ▸ Works on standard chart types only (not Heikin Ashi, Renko, Kagi, Point & Figure, Line Break or Range). Intraday HTFs must be exact multiples of the chart timeframe. If no selected HTF fits the chart, a notice is shown instead of the panels.
 ▸ History is limited to the bars loaded on the chart. The first HTF bar in the history is usually incomplete and is not used.
 ▸ The script does not measure or report the historical accuracy of the agreement reading. No performance of any kind is implied.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]
█ OPEN-SOURCE NOTES[/b]

The source code is published under the Mozilla Public License 2.0. The code is organised in commented sections (aggregation, agreement engine, rendering, table) so the logic described above can be checked directly. If you reuse parts of it, please follow the TradingView House Rules on open-source reuse and credit the original publication.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script is an analysis tool for studying higher-timeframe structure. It does not provide financial advice and does not predict future price movement.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © helmans13

//@version=6
indicator("HTF Fractal Bars [Herman]", shorttitle = "HTF Fractal Bars [Herman]", overlay = true, max_lines_count = 400, max_boxes_count = 150, max_labels_count = 150, max_bars_back = 500)

// ══════════════════════════════════════════════════════════════════════
//                                 ABOUT
// ══════════════════════════════════════════════════════════════════════
// v1.1
// Multi-timeframe OHLC panels aggregated from the chart's own bars (no request.security()).
// C1 = two closed HTF bars ago, C2 = last closed HTF bar, C3 = live HTF bar.
//
// Fractal Agreement engine
//   Each enabled HTF gets a phase: its live C3 compared with its C2 (last closed HTF bar).
//     Expansion ▲ / ▼    C3 took C2's high (low) and price is accepted beyond it
//     High swept ▼       C3 took C2's high but price is back at or below it
//     Low swept ▲        C3 took C2's low but price is back at or above it
//     Outside ▲ / ▼ / ·  C3 took both sides; direction from where price sits vs C2's range
//     Inside ·           C3 has not taken either side yet
//   Phases are weighted and combined into one agreement score (0-100 %) with a direction.
//
// Newer Pine features used
//   • input.*(active = ...)  (July 2025) — engine settings grey out while the table is off.
//     Fallback: delete the `active = ...` arguments; calculations do not change.
//   • `once` (August 2026) was evaluated and not used: `var` already covers the only
//     one-time initialisation this script needs.

// ══════════════════════════════════════════════════════════════════════
//                            INPUT GROUPS
// ══════════════════════════════════════════════════════════════════════
string G_PANELS = "01 | HTF panels"
string G_MARKS  = "02 | Markings"
string G_STYLE  = "03 | Style"
string G_TABLE  = "04 | Agreement Table"
string G_AGREE  = "05 | Fractal Agreement engine"

// ══════════════════════════════════════════════════════════════════════
//                               INPUTS
// ══════════════════════════════════════════════════════════════════════
bool showHTF1 = input.bool(true, "HTF1", inline = "h1", group = G_PANELS)
string htf1 = input.timeframe("15", "Timeframe", inline = "h1", group = G_PANELS)
bool showHTF2 = input.bool(true, "HTF2", inline = "h2", group = G_PANELS)
string htf2 = input.timeframe("60", "Timeframe", inline = "h2", group = G_PANELS)
bool showHTF3 = input.bool(true, "HTF3", inline = "h3", group = G_PANELS, tooltip = "Each HTF must be higher than the chart timeframe and an exact multiple of it (intraday). Invalid timeframes are skipped.")
string htf3 = input.timeframe("240", "Timeframe", inline = "h3", group = G_PANELS)

int barsShown = input.int(5, "Bars shown", minval = 3, maxval = 8, group = G_PANELS)
int panelOffset = input.int(12, "Right offset", minval = 3, maxval = 100, group = G_PANELS, tooltip = "Distance in chart bars between the last bar and the first panel. Panels are a visual display to the right of price, not placed in time.")
int barSpacing = input.int(6, "Bar spacing", minval = 4, maxval = 15, group = G_PANELS)
int tickWidth = input.int(2, "Open / close tick width", minval = 1, maxval = 4, group = G_PANELS)
int panelGap = input.int(8, "Gap between HTFs", minval = 2, maxval = 30, group = G_PANELS)
bool showHTFNames = input.bool(true, "Show HTF1 / HTF2 / HTF3 labels", group = G_PANELS)

bool showMarks = input.bool(true, "Mark C1 / C2 / C3", group = G_MARKS)
bool showPanelLevels = input.bool(true, "C1 / C2 / C3 dotted level marks", group = G_MARKS)
bool showSweeps = input.bool(true, "Subtle sweep lines", group = G_MARKS, tooltip = "Dotted line when a bar trades beyond the previous bar's high (low) and closes back inside it. On the live C3 this can appear and disappear until the HTF bar closes.")
bool showGaps = input.bool(true, "Grey FVG zones", group = G_MARKS)

bool showChartStructure = input.bool(true, "HTF1 structure on main chart", group = G_MARKS)
bool showSeparators = input.bool(true, "HTF1 subtle separators", group = G_MARKS)
int separatorCount = input.int(20, "HTF1 separators retained", minval = 1, maxval = 100, group = G_MARKS)
bool showC1 = input.bool(true, "HTF1 C1 high / low", group = G_MARKS)
bool showC2 = input.bool(true, "HTF1 C2 high / low", group = G_MARKS)
bool showC3 = input.bool(true, "HTF1 C3 high / low", group = G_MARKS)
bool showOpen = input.bool(true, "HTF1 C3 open", group = G_MARKS)
bool showRange = input.bool(false, "HTF1 developing C3 range box", group = G_MARKS)

color bullColor = input.color(#22c55e, "Bullish bar", inline = "bars", group = G_STYLE)
color bearColor = input.color(#ef4444, "Bearish bar", inline = "bars", group = G_STYLE)
color neutralColor = input.color(#9298a1, "Neutral", inline = "bars", group = G_STYLE)
color levelColor = input.color(#9298a1, "Levels / separators", group = G_STYLE)
color gapColor = input.color(#9399a2, "FVG grey", group = G_STYLE)
int gapOpacity = input.int(86, "FVG transparency", minval = 0, maxval = 100, group = G_STYLE)
int lineWidth = input.int(1, "OHLC bar line width", minval = 1, maxval = 3, group = G_STYLE)

showTable  = input.bool(true, "Show Table", group = G_TABLE)
tableTheme = input.string("Light", "Theme", options = ["Dark", "Light"], group = G_TABLE)
tableSize  = input.string("small", "Size", options = ["tiny", "small", "normal", "large"], group = G_TABLE)
tablePos   = input.string(position.bottom_right, "Position", options = [position.top_right, position.bottom_right, position.top_left, position.bottom_left], group = G_TABLE)

string agreeMode = input.string("On chart-bar close", "Update", options = ["On chart-bar close", "Live (every tick)"], group = G_AGREE, active = showTable, tooltip = "On chart-bar close: phases are evaluated with the last CLOSED chart bar, so the table does not change inside a forming bar. Live: phases follow every tick and can change until the chart bar closes.")
int accBufTicks = input.int(0, "Acceptance buffer (ticks)", minval = 0, maxval = 200, group = G_AGREE, active = showTable, tooltip = "How far beyond C2's high / low price must be to count as accepted outside the range. 0 = any price beyond the level. Measured in ticks of the chart symbol.")
int w1 = input.int(1, "Weight  HTF1", minval = 0, maxval = 10, inline = "w", group = G_AGREE, active = showTable)
int w2 = input.int(2, "HTF2", minval = 0, maxval = 10, inline = "w", group = G_AGREE, active = showTable)
int w3 = input.int(3, "HTF3", minval = 0, maxval = 10, inline = "w", group = G_AGREE, active = showTable, tooltip = "Weight of each timeframe in the agreement score. Default 1 / 2 / 3 gives higher timeframes more say. 0 = phase still shown, but ignored by the score.")
int barSegs = input.int(10, "Progress bar segments", minval = 5, maxval = 20, group = G_AGREE, active = showTable)

// ══════════════════════════════════════════════════════════════════════
//                          PALETTE (TABLE)
// ══════════════════════════════════════════════════════════════════════
var color c_green = na, var color c_red  = na
var color c_nbg   = na, var color c_ntxt = na
var color c_hdr   = na, var color c_dhdr = na
var color c_sep   = na

if tableTheme == "Dark"
    c_green := #29a071, c_red  := #e54b4b
    c_nbg   := #2a2e39, c_ntxt := #e0e0e0
    c_hdr   := #3c415e, c_dhdr := #525a81
    c_sep   := #454955
else
    c_green := #29a071, c_red  := #e54b4b
    c_nbg   := #f7f7f7, c_ntxt := #1e2025
    c_hdr   := #e5eef7, c_dhdr := #dfe2f144
    c_sep   := #e1e4e6

color nbg2 = color.new(c_nbg, 50)

// ══════════════════════════════════════════════════════════════════════
//                           TABLE HELPERS
// ══════════════════════════════════════════════════════════════════════
font_sz(sz) =>
    switch sz
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        =>           size.small

f_row(table t, int row, string lbl, string val, color bg, color valColor, string fsz, bool mono) =>
    table.cell(t, 0, row, lbl, bgcolor = bg, text_color = c_ntxt, text_size = fsz)
    if mono
        table.cell(t, 1, row, val, bgcolor = bg, text_color = valColor, text_size = fsz, text_font_family = font.family_monospace)
    else
        table.cell(t, 1, row, val, bgcolor = bg, text_color = valColor, text_size = fsz)

// ══════════════════════════════════════════════════════════════════════
//                             DATA MODEL
// ══════════════════════════════════════════════════════════════════════
type Candle
    int t
    int finish
    float o
    float h
    float l
    float c
    int highTime
    int lowTime
    int firstTime
    int lastTime
    int bars
    bool full

// Only the first candle in the chart's history can start mid-period, so only it is marked incomplete.
// A missing lower-timeframe bar inside a period does not make the HTF candle wrong.
f_newCandle(int t, int finish, bool isFirst) =>
    Candle.new(t, finish, open, high, low, close, time, time, time, time, 1, not isFirst and time_close <= finish)

method absorb(Candle a) =>
    if high > a.h
        a.h := high
        a.highTime := time
    if low < a.l
        a.l := low
        a.lowTime := time
    a.c := close
    a.lastTime := time
    a.bars := a.bars + 1
    if time_close > a.finish
        a.full := false

f_tfText(string tf) =>
    float sec = timeframe.in_seconds(tf)
    string result = tf
    if not na(sec)
        result := sec < 3600 ? str.tostring(sec / 60, "#") + "m" : sec < 86400 ? str.tostring(sec / 3600, "#.##") + "h" : tf
    result

f_isValidTf(string tf) =>
    float chartSec = timeframe.in_seconds()
    float tfSec = timeframe.in_seconds(tf)
    bool basic = chart.is_standard and not na(chartSec) and not na(tfSec) and tfSec >= chartSec
    bool aligned = not basic ? false : tfSec >= 86400 or tfSec % chartSec == 0
    basic and aligned

f_barColor(Candle a) =>
    a.c > a.o ? bullColor : a.c < a.o ? bearColor : neutralColor

// ══════════════════════════════════════════════════════════════════════
//                          HTF1 AGGREGATION
// ══════════════════════════════════════════════════════════════════════
bool valid1 = f_isValidTf(htf1)
int htf1Time = time(htf1)
int htf1End = time_close(htf1)
bool new1 = valid1 and not na(htf1Time[1]) and htf1Time != htf1Time[1]
var Candle current1 = na
var array<Candle> archive1 = array.new<Candle>()
var array<line> separators1 = array.new<line>()

if valid1
    if na(current1) or new1
        bool first1 = na(current1)
        if not first1
            if current1.full
                array.push(archive1, current1)
                if array.size(archive1) > 8
                    array.shift(archive1)
            else
                array.clear(archive1)
        current1 := f_newCandle(htf1Time, htf1End, first1)
        if showHTF1 and showChartStructure and showSeparators
            line sep = line.new(htf1Time, low, htf1Time, high + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = color.new(levelColor, 85), style = line.style_dotted)
            array.push(separators1, sep)
            if array.size(separators1) > separatorCount
                line.delete(array.shift(separators1))
    else
        current1.absorb()

// ══════════════════════════════════════════════════════════════════════
//                          HTF2 AGGREGATION
// ══════════════════════════════════════════════════════════════════════
bool valid2 = f_isValidTf(htf2)
int htf2Time = time(htf2)
int htf2End = time_close(htf2)
bool new2 = valid2 and not na(htf2Time[1]) and htf2Time != htf2Time[1]
var Candle current2 = na
var array<Candle> archive2 = array.new<Candle>()

if valid2
    if na(current2) or new2
        bool first2 = na(current2)
        if not first2
            if current2.full
                array.push(archive2, current2)
                if array.size(archive2) > 8
                    array.shift(archive2)
            else
                array.clear(archive2)
        current2 := f_newCandle(htf2Time, htf2End, first2)
    else
        current2.absorb()

// ══════════════════════════════════════════════════════════════════════
//                          HTF3 AGGREGATION
// ══════════════════════════════════════════════════════════════════════
bool valid3 = f_isValidTf(htf3)
int htf3Time = time(htf3)
int htf3End = time_close(htf3)
bool new3 = valid3 and not na(htf3Time[1]) and htf3Time != htf3Time[1]
var Candle current3 = na
var array<Candle> archive3 = array.new<Candle>()

if valid3
    if na(current3) or new3
        bool first3 = na(current3)
        if not first3
            if current3.full
                array.push(archive3, current3)
                if array.size(archive3) > 8
                    array.shift(archive3)
            else
                array.clear(archive3)
        current3 := f_newCandle(htf3Time, htf3End, first3)
    else
        current3.absorb()

// ══════════════════════════════════════════════════════════════════════
//                     FRACTAL AGREEMENT ENGINE
// ══════════════════════════════════════════════════════════════════════
// Phase codes
//   1 Expansion ▲   2 Low swept ▲    3 Outside ▲         (bullish)
//   4 Expansion ▼   5 High swept ▼   6 Outside ▼         (bearish)
//   7 Inside        8 Outside, price back inside C2      (neutral)
//   9 n/a (HTF off, invalid, or no closed C2 yet)
f_phase(array<Candle> past, Candle live, float px, float buf) =>
    int code = 9
    if not na(live) and array.size(past) > 0
        Candle prev = array.last(past)
        bool tookHigh = live.h > prev.h
        bool tookLow = live.l < prev.l
        bool above = px > prev.h + buf
        bool below = px < prev.l - buf
        if tookHigh and tookLow
            code := above ? 3 : below ? 6 : 8
        else if tookHigh
            code := above ? 1 : 5
        else if tookLow
            code := below ? 4 : 2
        else
            code := 7
    code

f_dir(int code) =>
    code >= 1 and code <= 3 ? 1 : code >= 4 and code <= 6 ? -1 : 0

f_phaseText(int code) =>
    switch code
        1 => "Expansion ▲"
        2 => "Low swept ▲"
        3 => "Outside ▲"
        4 => "Expansion ▼"
        5 => "High swept ▼"
        6 => "Outside ▼"
        7 => "Inside ·"
        8 => "Outside ·"
        =>   "n/a"

f_dirColor(int d) =>
    d > 0 ? c_green : d < 0 ? c_red : c_ntxt

f_bar(float pct, int segs) =>
    int filled = na(pct) ? 0 : math.round(pct / 100.0 * segs)
    str.repeat("█", filled) + str.repeat("░", segs - filled)

float accBuf = accBufTicks * syminfo.mintick

int ph1Live = valid1 ? f_phase(archive1, current1, close, accBuf) : 9
int ph2Live = valid2 ? f_phase(archive2, current2, close, accBuf) : 9
int ph3Live = valid3 ? f_phase(archive3, current3, close, accBuf) : 9

// Committed only on closed chart bars. On realtime ticks these roll back to the last closed bar's value.
var int ph1Conf = 9
var int ph2Conf = 9
var int ph3Conf = 9
if barstate.isconfirmed
    ph1Conf := ph1Live
    ph2Conf := ph2Live
    ph3Conf := ph3Live

bool liveMode = agreeMode == "Live (every tick)"
int ph1 = showHTF1 ? (liveMode ? ph1Live : ph1Conf) : 9
int ph2 = showHTF2 ? (liveMode ? ph2Live : ph2Conf) : 9
int ph3 = showHTF3 ? (liveMode ? ph3Live : ph3Conf) : 9

int d1 = f_dir(ph1)
int d2 = f_dir(ph2)
int d3 = f_dir(ph3)
int wt1 = ph1 == 9 ? 0 : w1
int wt2 = ph2 == 9 ? 0 : w2
int wt3 = ph3 == 9 ? 0 : w3
int wSum = wt1 + wt2 + wt3
int score = wt1 * d1 + wt2 * d2 + wt3 * d3
float agreePct = wSum > 0 ? 100.0 * math.abs(score) / wSum : na
int nActive = (ph1 != 9 ? 1 : 0) + (ph2 != 9 ? 1 : 0) + (ph3 != 9 ? 1 : 0)
int nBull = (d1 > 0 ? 1 : 0) + (d2 > 0 ? 1 : 0) + (d3 > 0 ? 1 : 0)
int nBear = (d1 < 0 ? 1 : 0) + (d2 < 0 ? 1 : 0) + (d3 < 0 ? 1 : 0)

// ══════════════════════════════════════════════════════════════════════
//                          DRAWING HELPERS
// ══════════════════════════════════════════════════════════════════════
var array<line> drawnLines = array.new<line>()
var array<box> drawnBoxes = array.new<box>()
var array<label> drawnLabels = array.new<label>()

f_clearDrawings() =>
    while array.size(drawnLines) > 0
        line.delete(array.pop(drawnLines))
    while array.size(drawnBoxes) > 0
        box.delete(array.pop(drawnBoxes))
    while array.size(drawnLabels) > 0
        label.delete(array.pop(drawnLabels))

f_line(int x1, float y1, int x2, float y2, color c, string xs, string style, int width) =>
    line id = line.new(x1, y1, x2, y2, xloc = xs, color = c, width = width, style = style)
    array.push(drawnLines, id)

f_box(int left, float top, int right, float bottom, color border, color fill, string xs) =>
    box id = box.new(left, top, right, bottom, xloc = xs, border_color = border, border_width = 1, bgcolor = fill)
    array.push(drawnBoxes, id)

f_label(int x, float y, string message, color textColour, string xs, string labelSize) =>
    label id = label.new(x, y, message, xloc = xs, style = label.style_none, textcolor = textColour, size = labelSize, textalign = text.align_center)
    array.push(drawnLabels, id)

f_panel(array<Candle> past, Candle live, int left, string panelName, string tf, float pad) =>
    if not na(live)
        int n = math.min(barsShown - 1, array.size(past))
        array<Candle> items = array.new<Candle>()
        if n > 0
            for k = array.size(past) - n to array.size(past) - 1
                array.push(items, array.get(past, k))
        array.push(items, live)

        // FVG zones first so the OHLC bars remain visible above them.
        if showGaps and array.size(items) >= 3
            for k = 2 to array.size(items) - 1
                Candle a = array.get(items, k)
                Candle old = array.get(items, k - 2)
                int x = left + k * barSpacing
                if a.l > old.h
                    f_box(x - barSpacing, a.l, x + tickWidth, old.h, color.new(gapColor, 65), color.new(gapColor, gapOpacity), xloc.bar_index)
                if a.h < old.l
                    f_box(x - barSpacing, old.l, x + tickWidth, a.h, color.new(gapColor, 65), color.new(gapColor, gapOpacity), xloc.bar_index)

        float panelHigh = na
        for k = 0 to array.size(items) - 1
            Candle a = array.get(items, k)
            int x = left + k * barSpacing
            color c = f_barColor(a)
            panelHigh := na(panelHigh) ? a.h : math.max(panelHigh, a.h)

            // Classic OHLC bar: stem = H/L, left tick = open, right tick = close.
            f_line(x, a.h, x, a.l, c, xloc.bar_index, line.style_solid, lineWidth)
            f_line(x - tickWidth, a.o, x, a.o, c, xloc.bar_index, line.style_solid, lineWidth)
            f_line(x, a.c, x + tickWidth, a.c, c, xloc.bar_index, line.style_solid, lineWidth)

            // Dotted high / low marks on C1, C2 and C3.
            if showPanelLevels and k >= n - 2
                f_line(x, a.h, x + tickWidth + 2, a.h, color.new(levelColor, 30), xloc.bar_index, line.style_dotted, 1)
                f_line(x, a.l, x + tickWidth + 2, a.l, color.new(levelColor, 30), xloc.bar_index, line.style_dotted, 1)

            string tag = k == n ? "C3" : k == n - 1 ? "C2" : k == n - 2 ? "C1" : ""
            if showMarks and tag != ""
                f_label(x, a.l - pad * 0.55, tag, k == n ? c : neutralColor, xloc.bar_index, size.tiny)

            // Sweep connections between adjacent HTF bars.
            if showSweeps and k > 0
                Candle prev = array.get(items, k - 1)
                int prevX = x - barSpacing
                if a.h > prev.h and a.c <= prev.h
                    f_line(prevX, prev.h, x, prev.h, color.new(levelColor, 45), xloc.bar_index, line.style_dotted, 1)
                if a.l < prev.l and a.c >= prev.l
                    f_line(prevX, prev.l, x, prev.l, color.new(levelColor, 45), xloc.bar_index, line.style_dotted, 1)

        if showHTFNames and not na(panelHigh)
            int centreX = left + int((array.size(items) - 1) * barSpacing / 2)
            f_label(centreX, panelHigh + pad * 0.65, panelName + "  " + f_tfText(tf), neutralColor, xloc.bar_index, size.tiny)

// ══════════════════════════════════════════════════════════════════════
//                               RENDER
// ══════════════════════════════════════════════════════════════════════
float chartATR = ta.atr(14)

if barstate.islast
    f_clearDrawings()

    // Notice when nothing can be drawn on this chart (e.g. default HTFs on a daily chart).
    bool anyEnabled = showHTF1 or showHTF2 or showHTF3
    bool anyValid = (showHTF1 and valid1) or (showHTF2 and valid2) or (showHTF3 and valid3)
    if anyEnabled and not anyValid
        string msg = chart.is_standard ? "HTF Fractal Bars: select timeframes higher than, and a multiple of, the chart timeframe." : "HTF Fractal Bars: standard chart types only."
        array.push(drawnLabels, label.new(bar_index, close, msg, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = size.small))

    float refRange = not na(current1) ? current1.h - current1.l : not na(current2) ? current2.h - current2.l : not na(current3) ? current3.h - current3.l : high - low
    float pad = math.max(nz(chartATR, refRange) * 0.10, syminfo.mintick * 10)

    // Main-chart C1 / C2 / C3 markings are tied to HTF1.
    if showHTF1 and valid1 and showChartStructure and not na(current1)
        int rightTime = time_close + int(timeframe.in_seconds() * 1000 * 2)

        if showRange
            f_box(current1.t, current1.h, time_close, current1.l, color.new(levelColor, 75), color.new(levelColor, 97), xloc.bar_time)
        if showOpen
            f_line(current1.t, current1.o, rightTime, current1.o, color.new(levelColor, 25), xloc.bar_time, line.style_dotted, 1)
        if showC3
            f_line(current1.highTime, current1.h, rightTime, current1.h, color.new(levelColor, 10), xloc.bar_time, line.style_dotted, 1)
            f_line(current1.lowTime, current1.l, rightTime, current1.l, color.new(levelColor, 10), xloc.bar_time, line.style_dotted, 1)

        if array.size(archive1) >= 1
            for k = 1 to math.min(2, array.size(archive1))
                Candle a = array.get(archive1, array.size(archive1) - k)
                if k == 1 ? showC2 : showC1
                    int opacity = k == 1 ? 40 : 65
                    f_line(a.highTime, a.h, rightTime, a.h, color.new(levelColor, opacity), xloc.bar_time, line.style_dotted, 1)
                    f_line(a.lowTime, a.l, rightTime, a.l, color.new(levelColor, opacity), xloc.bar_time, line.style_dotted, 1)
                if showMarks
                    f_label(int((a.firstTime + a.lastTime) / 2), a.l - pad * 0.55, k == 1 ? "C2" : "C1", neutralColor, xloc.bar_time, size.tiny)

        if showMarks
            f_label(int((current1.firstTime + current1.lastTime) / 2), current1.l - pad * 0.55, "C3", f_barColor(current1), xloc.bar_time, size.tiny)

    int nextLeft = bar_index + panelOffset
    int panelWidth = math.max(1, (barsShown - 1) * barSpacing + tickWidth * 2)

    if showHTF1 and valid1 and not na(current1)
        f_panel(archive1, current1, nextLeft, "HTF1", htf1, pad)
        nextLeft += panelWidth + panelGap

    if showHTF2 and valid2 and not na(current2)
        f_panel(archive2, current2, nextLeft, "HTF2", htf2, pad)
        nextLeft += panelWidth + panelGap

    if showHTF3 and valid3 and not na(current3)
        f_panel(archive3, current3, nextLeft, "HTF3", htf3, pad)

// ══════════════════════════════════════════════════════════════════════
//                         AGREEMENT TABLE
// ══════════════════════════════════════════════════════════════════════
var table tbl = na

if showTable and barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(tablePos, 2, 10, bgcolor = c_nbg, border_width = 1, frame_width = 1, border_color = c_sep, frame_color = c_sep)
    string fsz = font_sz(tableSize)
    int r = 0

    // Title
    table.cell(tbl, 0, r, "HTF Fractal Bars  [Herman]", text_color = c_ntxt, bgcolor = c_hdr, text_size = fsz)
    table.cell(tbl, 1, r, "", text_color = c_ntxt, bgcolor = c_hdr), r += 1

    // Section: agreement
    table.cell(tbl, 0, r, "Fractal Agreement", text_color = c_ntxt, bgcolor = c_dhdr, text_size = fsz)
    table.cell(tbl, 1, r, "", bgcolor = c_dhdr), r += 1

    int dirAll = score > 0 ? 1 : score < 0 ? -1 : 0
    bool enough = nActive >= 2 and wSum > 0
    string biasTxt = not enough ? "Need 2+ HTFs" : dirAll > 0 ? "Bullish" : dirAll < 0 ? "Bearish" : nBull > 0 and nBear > 0 ? "Conflict" : "Neutral"
    string agreeTxt = not enough ? "n/a" : f_bar(agreePct, barSegs) + "  " + str.tostring(agreePct, "#") + "%"
    string alignTxt = "▲ " + str.tostring(nBull) + "   ▼ " + str.tostring(nBear) + "   · " + str.tostring(nActive - nBull - nBear)

    f_row(tbl, r, "Bias", biasTxt, nbg2, enough ? f_dirColor(dirAll) : c_ntxt, fsz, false), r += 1
    f_row(tbl, r, "Agreement", agreeTxt, c_nbg, enough ? f_dirColor(dirAll) : c_ntxt, fsz, true), r += 1
    f_row(tbl, r, "Aligned", alignTxt, nbg2, c_ntxt, fsz, false), r += 1
    f_row(tbl, r, "Update", liveMode ? "Live" : "Bar close", c_nbg, c_ntxt, fsz, false), r += 1

    // Section: per-HTF phase
    table.cell(tbl, 0, r, "HTF Phase", text_color = c_ntxt, bgcolor = c_dhdr, text_size = fsz)
    table.cell(tbl, 1, r, "", bgcolor = c_dhdr), r += 1

    bool zebra = true
    if showHTF1
        f_row(tbl, r, "HTF1  " + f_tfText(htf1), valid1 ? f_phaseText(ph1) : "invalid TF", zebra ? nbg2 : c_nbg, f_dirColor(d1), fsz, false)
        r += 1
        zebra := not zebra
    if showHTF2
        f_row(tbl, r, "HTF2  " + f_tfText(htf2), valid2 ? f_phaseText(ph2) : "invalid TF", zebra ? nbg2 : c_nbg, f_dirColor(d2), fsz, false)
        r += 1
        zebra := not zebra
    if showHTF3
        f_row(tbl, r, "HTF3  " + f_tfText(htf3), valid3 ? f_phaseText(ph3) : "invalid TF", zebra ? nbg2 : c_nbg, f_dirColor(d3), fsz, false)
        r += 1
````
