# MapleStax CBC (Candle by Candle) for NQ and MNQ

- url: https://www.tradingview.com/script/qhgQCEn4-MapleStax-CBC-Candle-by-Candle-for-NQ-and-MNQ/
- type: indicator
- pine_id: PUB;d0e0177263504122993353049031694e
- version: 2.0

## Description

This open-source indicator is built for intraday futures traders who want a clear, repeatable way to read price control and context on NQ and MNQ. The core idea is simple: CBC tracks who is in control candle by candle, while the supporting tools explain whether that control shift is happening in a strong or weak location.

[b]Key terms (plain language)[/b]
[list]
[*] LTF (Low Timeframe): 3-minute chart — this is the execution timeframe where entries are evaluated.
[*] HTF (High Timeframe): 10-minute chart — this is the context timeframe used to confirm broader direction.
[*] Recommended setup for NQ/MNQ: LTF = 3m and HTF = 10m.
[*] BRSG Zone (“Buy Red Sell Green”): Two short horizontal dashes drawn on the last closed candle only. Many experienced traders watch this zone as a visual cue — for example, if the previous candle was red (bearish close) and the current forming candle is green but you have an active CBC sell signal, it can highlight a potential short-selling opportunity against the green candle. Use it only when other levels in the indicator also line up.
[*] YDH / YDL: Yesterday’s High and Yesterday’s Low — the high and low prices from the previous completed New York regular trading session (9:30 AM – 4:00 PM ET).
[*] PMH / PML: Premarket High and Premarket Low — the highest and lowest prices reached before the regular New York market open (pre-market session).
[*] VWAP (Volume Weighted Average Price): The average price at which the symbol has traded throughout the day, weighted by volume. Price trading above VWAP often gives bullish traders more confidence (favors longs), while price trading below VWAP gives bearish traders more confidence (favors shorts).
[*] ORB (Opening Range Break): The high and low of the Opening Range — the first 30 minutes after the New York market open. These levels are important because many traders watch for breakouts above the ORB high (bullish strength) or breakdowns below the ORB low (bearish strength), or reactions when price returns to the range.
[/list]

[b]What is original about this script[/b]
The script is not a collection of unrelated signals. It is a single price-action workflow centered on CBC state changes. CBC is the primary engine, and every other module is included for a specific reason: to qualify whether a CBC flip is occurring in favorable structure, favorable direction, and favorable location. The design goal is practical and educational — help traders read control shifts with fewer blind spots, not just generate more markers.

[b]How CBC works[/b]
[list]
[*] CBC flips bullish when the current candle closes above the high of the prior candle.
[*] CBC flips bearish when the current candle closes below the low of the prior candle.
[*] Once flipped, the state persists until the opposite break occurs (strict prior-bar breaks only).
[*] Triangles mark these state changes on the chart.
[*] Optional CBC Reversal highlights back-to-back flip behavior.
[/list]

[b]Why the supporting components are combined with CBC[/b]
The CBC engine alone is powerful, but the real edge comes from deliberately layering institutional reference levels and filters to create one cohesive decision-making framework:
[list]
[*] HTF CBC (10m): helps answer, “Is my 3m flip aligned with higher-timeframe control?”
[*] EMA 9/20 cloud: helps answer, “Is short-term trend structure supporting this flip?” (plus optional EMA20 touch dots). On the 3-minute chart, a green cloud shows a bullish trend — when price retraces back into the cloud it often offers a high-probability bullish entry. A red cloud shows a bearish trend — when price retraces into the cloud it can offer a bearish entry opportunity. The CBC direction plus where price sits relative to VWAP and the other levels adds extra confidence to these setups.
[*] VWAP and EMA 200: help answer, “Is price on the strong side or weak side of key mean/trend references?”
[*] Opening Range (NY/London/Asian sessions — also called ORB) and reference levels (YDH/YDL/YDC/PMH/PML): help answer, “Is this flip happening at a meaningful location?” Each reference level is fully customizable (individual color, width 1–4, style: solid/dashed/dotted).
[*] CBC Flip-level dashes (LTF + HTF): show the exact next price that would invalidate the current CBC state, giving a clear risk/invalidation reference.
[*] Optional LTF & HTF Pivot lines: persistent support/resistance at recent pivots until a new pivot forms.
[*] Optional Bill Breaker levels: five ratcheting levels for additional structure.
[*] Optional BRSG Zone: retracement zone on the last closed candle.
[*] Optional bar coloring: solid overlay when LTF and HTF CBC are in agreement.
[/list]

Together, these tools convert a raw flip into a structured decision process: control change → location → alignment → confirmation.

[b]How to use it (NQ/MNQ recommended workflow)[/b]
[list=1]
[*] Set chart to 3-minute and set HTF input to 10-minute.
[*] Wait for a new CBC flip on LTF.
[*] Check location: opening range (ORB) position and nearby YDH/YDL/YDC/PMH/PML.
[*] Check alignment: HTF CBC and EMA cloud direction.
[*] Check confirmation: price vs VWAP and EMA 200.
[*] Use CBC flip-level dash as your next-state/invalidation reference.
[/list]

[b]Ideal chart layout[/b]
[list]
[*] Side-by-side charts are recommended: one 3m chart and one 10m chart, both with this indicator.
[*] For publication screenshots, use a clean chart with only this indicator so outputs are easy to identify.
[/list]

[b]What this script is and is not[/b]
[list]
[*] This is an open-source visual decision-support framework.
[*] This is not an automated strategy and does not guarantee outcomes.
[*] Like all fast-reacting price-action tools, it can whipsaw in choppy conditions.
[/list]

[b]Session scope[/b]
The reference and opening-range logic uses America/New_York session timing. It is most relevant for instruments with strong NY participation, including NQ and MNQ.

[b]Disclaimer[/b]
For educational and analytical use only. Not investment advice.

## Source Code

````pine
// =====================================================================================
// MAPLESTAX_CBC v2.00
// By MapleStax / AsiaRoo. Enhanced by WildWex
//
// 04/12/2026: v1.30 - Initial release. Inc. CBC (HTF/LTF), EMA Cloud, Key Levels, VWAP, EMA(200), EMA20 touch, Reference levels, Opening Range, Reversal, Alerts.
// 04/23/2026: v1.65 — Added Bill Breaker, Opening Range Sessions, Updated CBC Agreement Bars, Added BRSG Zone, Fixed HTF Flags and Table
// 04/23/2026: v1.66 — HTF LONG/SHORT text labels: when chart TF equals HTF setting, anchor one bar left (prior bar) so labels align with the closed HTF candle; LTF relocate path unchanged.
// 04/23/2026: v1.67 — Reference levels (YDH/YDL/PMH/PML): per-level color, line width (1–4), and line style (Solid/Dashed/Dotted) inputs; line/label update when settings change.
// 04/23/2026: v1.68 — Bill Breaker: dedicated Settings group "Bill Breaker" (below Reference levels); main toggle renamed to "Show Bill Breaker".
// 04/23/2026: v1.69 — Reference levels: show "Width" label on each of the four per-level line width inputs.
// 04/26/2026: v1.70 — CBC: default prior-bar breaks are strict (< / >, original/HOS-style). Optional "CBC Inclusive Breaks" restores <= / >= (legacy ThinkScript-style touch flips). Applies to chart and HTF CBC.
// 04/27/2026: v1.71 — HTF + LTF pivot lines (both off by default). Inline single-row UI per timeframe (Pivot / N / H / L / Width / Style). N=1 default. Dashed thin red (resistance) / green (support) anchored at the pivot bar, extended one chart-bar past current. Replaced ONLY by a new same-type pivot in the same timeframe (no close-break removal). Uses ta.pivothigh / ta.pivotlow; HTF via request.security on htf_timeframe (lookahead_off); LTF chart-native. Zero plot()-budget impact (line.new only).
// 04/27/2026: v1.72 — CBC flip levels: per-line H/L color swatches (next flip at prior high vs prior low) for LTF and HTF; default LTF width 2, HTF width 4.
// 04/27/2026: v1.73 — Removed standalone "CBC" input group and "CBC Inclusive Breaks" toggle; chart and HTF CBC always use strict prior-bar breaks (close < low[1] / close > high[1]), matching original AsiaRoo / HOS-style logic.
// 04/27/2026: v1.74 — Status table: CBC LTF/HTF cells say "Bullish" / "Bearish" (was "Bulls" / "Bears") to match EMA cloud wording.
// 04/28/2026: v1.75 — Renamed FOBO to CBC Reversal across input text, comments, plot titles, and variable names.
// 04/28/2026: v1.81 — Reference levels: added YDC (Yesterday Close), OFF by default, with default gray dotted line (width 2).
// 05/03/2026: v1.86 — Version bump; canonical repo release tag.
// 05/03/2026: v1.87 — YDH/YDL/YDC: prior **completed** NY RTH (09:30–16:00, same as `is_regular`) via on-chart H/L/last close; removed D1 `request.security` (daily bar included ETH / full session, not RTH-only).
// 05/05/2026: v1.88 — Version bump for republish with updated compliant public description (no logic changes).
// 05/28/2026: v2.00 - Touch Dots added for VWAP and EMA(200). Better control of OpeningRange Coloring.
// ====================================================================================

//@version=6
indicator("MapleStax ⚡ CBC v2.00", overlay = true, behind_chart = false, max_labels_count = 500, max_lines_count = 500)

const string grp_or_sessions = "Opening Range (Sessions)"
const string grp_bill_breaker = "Bill Breaker"

enum RefLineStyle
    solid = "Solid"
    dashed = "Dashed"
    dotted = "Dotted"

f_ref_line_style(RefLineStyle s) =>
    switch s
        RefLineStyle.dashed => line.style_dashed
        RefLineStyle.dotted => line.style_dotted
        => line.style_solid

// Input
// show_background = input.bool(false, "Show Background Color", tooltip="Enable/disable background color highlighting for CBC changes")
show_reversal = input.bool(true, "Show CBC Reversal", inline="reversal", group="LTF Signals", tooltip="Highlight consecutive CBC flips as CBC Reversal signals. Off: Reversal bars use normal Bull/Bear colors.")
show_ema_touch_dots = input.bool(true, "EMA20 touch dots", inline="ema20t", group="LTF Signals", tooltip="Show dots when the bar range crosses EMA(20). Default white circles; width/color: Style tab → EMA20 Touch.")
show_vwap_touch_dots = input.bool(true, "VWAP touch dots", inline="vwapt", group="LTF Signals", tooltip="Show dots when the bar range crosses VWAP. Default pink circles; width/color: Style tab → VWAP Touch.")
show_ema200_touch_dots = input.bool(true, "EMA200 touch dots", inline="e200t", group="LTF Signals", tooltip="Show dots when the bar range crosses EMA(200). Default orange circles; width/color: Style tab → EMA200 Touch.")
show_brsg_zone = input.bool(false, "BRSG Zone", inline="brsg", group="LTF Signals", tooltip="Buy Red Sell Green retracement zone: two short horizontal dashes on the last closed candle only (same width as LTF flip). Upper = prior low + range × High; lower = prior low + range × Low.")
col_brsg_zone = input.color(color.gray, "", inline="brsg", group="LTF Signals")
brsg_high_mult = input.float(0.55, "High", inline="brsg", group="LTF Signals", minval = 0.0, maxval = 1.0, step = 0.01, tooltip="Upper line multiplier (fraction of prior bar range above prior low).")
brsg_low_mult = input.float(0.45, "Low", inline="brsg", group="LTF Signals", minval = 0.0, maxval = 1.0, step = 0.01, tooltip="Lower line multiplier (fraction of prior bar range above prior low).")
show_ltf_pivots = input.bool(false, "Pivot", inline="ltfpiv", group="LTF Signals", tooltip="Persistent dashed lines at the most recent LTF (chart-TF) pivot high (resistance) and pivot low (support) using ta.pivothigh/low(N,N) on the chart timeframe. Lines extend one chart-bar past the current bar; replaced ONLY by a new same-type LTF pivot.")
ltf_piv_n = input.int(1, "N", minval=1, maxval=20, inline="ltfpiv", group="LTF Signals", tooltip="Bars left and right of a chart bar that must be lower (high) or higher (low) for it to count as a pivot. N=1 = very fast/noisy. Confirmation lag = N chart bars.")
col_ltf_piv_res = input.color(color.red, "H", inline="ltfpiv", group="LTF Signals", tooltip="Resistance line color (LTF pivot high).")
col_ltf_piv_sup = input.color(color.green, "L", inline="ltfpiv", group="LTF Signals", tooltip="Support line color (LTF pivot low).")
ltf_piv_w = input.int(1, "Width", minval=1, maxval=4, inline="ltfpiv", group="LTF Signals", tooltip="LTF pivot line width.")
ltf_piv_style = input.enum(RefLineStyle.dashed, "Style", inline="ltfpiv", group="LTF Signals", tooltip="LTF pivot line pattern.")

show_htf_ema_cloud = input.bool(false, "HTF EMA cloud", group="HTF Signals", tooltip="Fill only: EMA 9/20 on HTF; uses same lookahead as HTF CBC so the cloud tracks the current HTF bar (not one bar late). Agreement colors at higher transparency. No EMA line borders.")
htf_enabled = input.bool(true, "", inline="HFT", group="HTF Signals")
htf_timeframe = input.timeframe("10", "Timeframe", tooltip="Higher timeframe to track CBC signals (default: 10 minutes)", inline="HFT", group="HTF Signals")
htf_label_size = input.string("normal", "Size", options=["tiny", "small", "normal", "large", "huge"], inline="HFT", group="HTF Signals")
show_htf_cbc_labels = input.bool(true, "HTF LONG/SHORT labels", group="HTF Signals", tooltip="Show/hide LONG and SHORT labels on HTF CBC flips after the HTF bar closes (last closed HTF only). Independent from HTF EMA cloud display.")
show_htf_pivots = input.bool(false, "Pivot", inline="htfpiv", group="HTF Signals", tooltip="Persistent dashed lines at the most recent HTF pivot high (resistance) and pivot low (support) using ta.pivothigh/low(N,N) on the HTF setting. Lines extend one chart-bar past the current bar; replaced ONLY by a new same-type HTF pivot.")
htf_piv_n = input.int(1, "N", minval=1, maxval=20, inline="htfpiv", group="HTF Signals", tooltip="Bars left and right of an HTF bar that must be lower (high) or higher (low) for it to count as a pivot. N=1 = very fast/noisy. Confirmation lag = N HTF bars.")
col_htf_piv_res = input.color(color.red, "H", inline="htfpiv", group="HTF Signals", tooltip="Resistance line color (HTF pivot high).")
col_htf_piv_sup = input.color(color.green, "L", inline="htfpiv", group="HTF Signals", tooltip="Support line color (HTF pivot low).")
htf_piv_w = input.int(2, "Width", minval=1, maxval=4, inline="htfpiv", group="HTF Signals", tooltip="HTF pivot line width.")
htf_piv_style = input.enum(RefLineStyle.dashed, "Style", inline="htfpiv", group="HTF Signals", tooltip="HTF pivot line pattern.")

show_bar_coloring = input.bool(false, "CBC agreement bar colors", group="CBC bar colors", tooltip="Solid plotcandle overlay on confirmed bars only (chart vs HTF CBC agreement). The forming bar is not painted. Style tab: Body/Wick/Border. Off: chart default candles only.\n\nNOTE:In Object Tree, drag this indicator above the Symbol.")

or_ny = input.bool(true, "New York", inline="ors_ny", group=grp_or_sessions, tooltip="Opening range: first N minutes after 9:30 AM ET.")
col_orb_ny_lbl = input.color(#ffeb3b, "", inline="ors_ny", group=grp_or_sessions, tooltip="ORB-H/L label text and Market cell tint for New York. OR line/fill colors: Style tab (per OR plot).")
col_orb_ny_fill = input.color(color.rgb(255, 235, 59, 90), "", inline="ors_ny", group=grp_or_sessions, tooltip="ORB-H/L label text and Market cell tint for New York. OR line/fill colors: Style tab (per OR plot).")
or_london = input.bool(false, "London", inline="ors_ln", group=grp_or_sessions, tooltip="Opening range: first N minutes after 3:00 AM ET.")
col_orb_ln_lbl = input.color(#9c27b0, "", inline="ors_ln", group=grp_or_sessions, tooltip="LN ORB-H/L label text and Market cell for London session.")
col_orb_ln_fill = input.color(color.rgb(155, 39, 176, 90), "", inline="ors_ln", group=grp_or_sessions, tooltip="ORB-H/L label text and Market cell tint for New York. OR line/fill colors: Style tab (per OR plot).")
or_asian = input.bool(false, "Asian", inline="ors_as", group=grp_or_sessions, tooltip="Opening range: first N minutes after 8:00 PM ET.")
col_orb_as_lbl = input.color(#e65100, "", inline="ors_as", group=grp_or_sessions, tooltip="AS ORB-H/L label text and Market cell for Asian session.")
col_orb_as_fill = input.color(color.rgb(230, 81, 0, 90), "", inline="ors_as", group=grp_or_sessions, tooltip="ORB-H/L label text and Market cell tint for New York. OR line/fill colors: Style tab (per OR plot).")
or_minutes = input.int(30, "Minutes", minval=1, maxval=390, inline="or", group=grp_or_sessions, tooltip="Length (minutes) of each enabled session’s opening range from that session’s ET open (NY 9:30, London 3:00, Asian 20:00). America/New_York.\n\nOR lines/fills: Style tab per plot. ORB label text: NY/London/Asian label swatches above.")
show_any_or = or_ny or or_london or or_asian

show_ydh = input.bool(true, "YDH", inline="ydh_lv", group="Reference levels", tooltip="High of the prior completed NY RTH session (09:30–16:00 America/New_York), same window as New York opening range and chart RTH session filter.")
col_ydh = input.color(#00FF00, "", inline="ydh_lv", group="Reference levels", tooltip="YDH line and label text color.")
ydh_width = input.int(2, "Width", minval=1, maxval=4, inline="ydh_lv", group="Reference levels", tooltip="YDH line width.")
ydh_line_style = input.enum(RefLineStyle.solid, "Style", inline="ydh_lv", group="Reference levels", tooltip="YDH line pattern.")
show_ydl = input.bool(true, "YDL", inline="ydl_lv", group="Reference levels", tooltip="Low of the prior completed NY RTH session (09:30–16:00 America/New_York).")
col_ydl = input.color(#FF0000, "", inline="ydl_lv", group="Reference levels", tooltip="YDL line and label text color.")
ydl_width = input.int(2, "Width", minval=1, maxval=4, inline="ydl_lv", group="Reference levels", tooltip="YDL line width.")
ydl_line_style = input.enum(RefLineStyle.solid, "Style", inline="ydl_lv", group="Reference levels", tooltip="YDL line pattern.")
show_ydc = input.bool(false, "YDC", inline="ydc_lv", group="Reference levels", tooltip="Last close of the prior completed NY RTH session (09:30–16:00 America/New_York).")
col_ydc = input.color(color.gray, "", inline="ydc_lv", group="Reference levels", tooltip="YDC line and label text color.")
ydc_width = input.int(2, "Width", minval=1, maxval=4, inline="ydc_lv", group="Reference levels", tooltip="YDC line width.")
ydc_line_style = input.enum(RefLineStyle.dotted, "Style", inline="ydc_lv", group="Reference levels", tooltip="YDC line pattern.")
show_pmh = input.bool(true, "PMH", inline="pmh_lv", group="Reference levels", tooltip="Premarket high (frozen at RTH open).")
col_pmh = input.color(#4CAF50, "", inline="pmh_lv", group="Reference levels", tooltip="PMH line and label text color.")
pmh_width = input.int(2, "Width", minval=1, maxval=4, inline="pmh_lv", group="Reference levels", tooltip="PMH line width.")
pmh_line_style = input.enum(RefLineStyle.dotted, "Style", inline="pmh_lv", group="Reference levels", tooltip="PMH line pattern.")
show_pml = input.bool(true, "PML", inline="pml_lv", group="Reference levels", tooltip="Premarket low (frozen at RTH open).")
col_pml = input.color(#EF5350, "", inline="pml_lv", group="Reference levels", tooltip="PML line and label text color.")
pml_width = input.int(2, "Width", minval=1, maxval=4, inline="pml_lv", group="Reference levels", tooltip="PML line width.")
pml_line_style = input.enum(RefLineStyle.dotted, "Style", inline="pml_lv", group="Reference levels", tooltip="PML line pattern.")
show_level_name = input.bool(true, "Show Level Name", tooltip="Display YDH, YDL, YDC, PMH, PML, ORB-H, ORB-L labels", inline="levels2", group="Reference levels")
show_level_price = input.bool(true, "Level Price", tooltip="Display price values on labels", inline="levels2", group="Reference levels")
extend_levels_bars = input.int(1, "Extend Levels (bars)", minval=0, maxval=500, group="Reference levels", tooltip="Right offset for optional name/price labels.")

show_bill_breaker = input.bool(false, "Show Bill Breaker", inline="bb", group=grp_bill_breaker, tooltip="On: plot five Bill Breaker levels. Off: hide.\nThinkScript parity: base ratchets ±1×multiplier only after close moves ±2×multiplier.")
col_bb = input.color(color.rgb(41, 98, 255), "", inline="bb", group=grp_bill_breaker, tooltip="Color for all five Bill Breaker level plots.")
bb_multiplier = input.int(100, "multiplier", minval=1, inline="bb", group=grp_bill_breaker, tooltip="Level spacing (e.g. 100 on MNQ → …27000, 27100…).")

show_status_table = input.bool(true, "Show", inline="st", group="Status table", tooltip="Compact Tier 1 dashboard: CBC, HTF, market, opening range, cloud, VWAP, EMA200 vs price.")
status_table_position = input.string("Top right", "", options=["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group="Status table", inline="st", tooltip="Where the table is anchored on the chart.")
status_table_text_size = input.string("Small", "Text", options=["Tiny", "Small", "Normal", "Large", "Huge"], inline="st", group="Status table", tooltip="Font size for all cells in the status table.")
status_table_header_newlines = input.int(0, "Header ↓", minval=0, maxval=5, inline="st_nl", group="Status table", tooltip="Leading newlines before the header title; pushes text down on mobile.")

show_cbc_flip_ltf = input.bool(true, "LTF flip", inline="ltf_fl", group="CBC flip levels", tooltip="Short dash on the last closed candle: next flip price. H = color when next flip is at prior high (bears to bulls); L = color when at prior low (bulls to bears).")
col_ltf_flip_h = input.color(#15FF00, "H", inline="ltf_fl", group="CBC flip levels", tooltip="LTF flip line when next close must take out the prior high.")
col_ltf_flip_l = input.color(#FF1500, "L", inline="ltf_fl", group="CBC flip levels", tooltip="LTF flip line when next close must take out the prior low.")
cbc_flip_ltf_width = input.int(2, "Width", minval=1, maxval=4, inline="ltf_fl", group="CBC flip levels", tooltip="LTF (Lower Timeframe e.g. 3min) CBC Flip - line width.")
show_cbc_flip_htf = input.bool(true, "HTF flip", inline="htf_fl", group="CBC flip levels", tooltip="Thicker dash on the last closed candle: HTF next flip price. H/L colors same meaning as LTF. Uses HTF setting above.")
col_htf_flip_h = input.color(#15FF00, "H", inline="htf_fl", group="CBC flip levels", tooltip="HTF flip line when next close must take out the prior HTF high.")
col_htf_flip_l = input.color(#FF1500, "L", inline="htf_fl", group="CBC flip levels", tooltip="HTF flip line when next close must take out the prior HTF low.")
cbc_flip_htf_width = input.int(4, "Width", minval=1, maxval=4, inline="htf_fl", group="CBC flip levels", tooltip="HTF (Higher Timeframe e.g. 10min) CBC Flip - line width.")

// Default colors (edit appearance per series in the indicator Style tab; Reversal color: LTF Signals inline next to Show Reversal). Flip-level line.new uses CBC flip levels H/L color inputs.
// OR plot/fill tints (const) — Style tab color pickers. ORB label + Market cell: col_orb_*_lbl inputs.
const color col_orb_ny = #ffeb3b
const color col_orb_ln = #9c27b0
const color col_orb_as = #e65100

const color col_cbc_long = #15FF00
const color col_cbc_short = #FF1500
const color col_htf_long = #00FF00
const color col_htf_short = #FF0000
// CBC agreement bar colors (opaque): darker cyan / darker orange vs neutral gray; agreement overlay + HTF cloud use this palette
const color col_cbc_bar_long = #007A8A
const color col_cbc_bar_short = #B34700
const color col_cbc_bar_neutral = #5A5A5A
const int col_cbc_bar_cloud_transp = 75

ny_tz = "America/New_York"

// ET clock slice for Market row: Asian 20:00–03:00, London 03:00–09:30, New York 09:30–20:00
f_market_session_et() =>
    int hm = hour(time, ny_tz) * 60 + minute(time, ny_tz)
    if hm >= 20 * 60 or hm < 3 * 60
        "Asian"
    else if hm < 9 * 60 + 30
        "London"
    else
        "New York"

// Asian OR anchor: 8 PM ET; bars after midnight before 3 AM use previous calendar day’s 8 PM open
f_asia_or_open_ms() =>
    int cand = timestamp(ny_tz, year(time, ny_tz), month(time, ny_tz), dayofmonth(time, ny_tz), 20, 0)
    hour(time, ny_tz) < 3 and time < cand ? cand - 86400000 : cand

// ===========================
// LTF EMA Cloud
// ===========================
ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema_bullish = ema9 >= ema20

// Plot EMA lines (OR-style: named args, title= last)
plotEMA20 = plot(ema20, color=#C8C8C8, linewidth=2, style=plot.style_line, title="EMA 20")
plotEMA9 = plot(ema9, color=#808080, linewidth=1, style=plot.style_line, title="EMA 9")

// Fill between the same two plots (no duplicate hidden series — avoids extra Style rows)
fill(plotEMA9, plotEMA20, color=ema_bullish ? color.new(color.green, 70) : color.new(color.red, 70), title="EMA Cloud")

// HTF EMA 9/20 cloud (fill only; plots hidden — agreement colors at 50% transparency)
[htf_ema9, htf_ema20] = request.security(ticker.standard(syminfo.tickerid), htf_timeframe, [ta.ema(close, 9), ta.ema(close, 20)], lookahead=barmerge.lookahead_on)
htf_ema_bullish = htf_ema9 >= htf_ema20
plotHTFEMA9 = plot(show_htf_ema_cloud ? htf_ema9 : na, title="HTF EMA 9", display=display.none)
plotHTFEMA20 = plot(show_htf_ema_cloud ? htf_ema20 : na, title="HTF EMA 20", display=display.none)
fill(plotHTFEMA9, plotHTFEMA20, color=show_htf_ema_cloud ? (htf_ema_bullish ? color.new(col_cbc_bar_long, col_cbc_bar_cloud_transp) : color.new(col_cbc_bar_short, col_cbc_bar_cloud_transp)) : na, title="HTF EMA Cloud")

// ===========================
// VWAP / EMA
// ===========================
vwap_value = ta.vwap(hlc3)
ema200 = ta.ema(close, 200)
plotVWAP = plot(vwap_value, color=#800080, linewidth=2, style=plot.style_line, linestyle=plot.linestyle_solid, title="VWAP")
plotEMA200 = plot(ema200, color=#ffeb3a, linewidth=3, style=plot.style_line, title="EMA 200")

// LTF touch dots — bar range crosses the level (same pattern as EMA20)
price_touches_ema20 = show_ema_touch_dots and (low <= ema20 and high >= ema20)
plotEMA20Touch = plot(price_touches_ema20 ? ema20 : na, color=#FFFFFF, linewidth=2, style=plot.style_circles, title="EMA20 Touch")
price_touches_vwap = show_vwap_touch_dots and (low <= vwap_value and high >= vwap_value)
plotVWAPTouch = plot(price_touches_vwap ? vwap_value : na, color=#FF69B4, linewidth=2, style=plot.style_circles, title="VWAP Touch")
price_touches_ema200 = show_ema200_touch_dots and (low <= ema200 and high >= ema200)
plotEMA200Touch = plot(price_touches_ema200 ? ema200 : na, color=#FF9800, linewidth=3, style=plot.style_circles, title="EMA200 Touch")

// ===========================
// Bill Breaker (ThinkScript MapleStax_BillBreaker parity: ratchet base, gap plot when base steps, five levels)
// ===========================
var float bb_base = na
if na(bb_base[1])
    bb_base := math.round(open / bb_multiplier) * bb_multiplier
else
    float bb_prev = bb_base[1]
    if close >= bb_prev + 2 * bb_multiplier
        bb_base := bb_prev + bb_multiplier
    else if close <= bb_prev - 2 * bb_multiplier
        bb_base := bb_prev - bb_multiplier
    else
        bb_base := bb_prev

bool bb_base_changed = not na(bb_base[1]) and bb_base != bb_base[1]
bool bb_plot_seg = show_bill_breaker and not bb_base_changed
float bb_l2 = bb_base - 2.0 * bb_multiplier
float bb_l1 = bb_base - bb_multiplier
float bb_m0 = bb_base
float bb_u1 = bb_base + bb_multiplier
float bb_u2 = bb_base + 2.0 * bb_multiplier

plot(bb_plot_seg ? bb_l2 : na, title="BB Lower 2", color=col_bb, linewidth=1, style=plot.style_steplinebr, linestyle = plot.linestyle_dotted)
plot(bb_plot_seg ? bb_l1 : na, title="BB Lower 1", color=col_bb, linewidth=1, style=plot.style_steplinebr, linestyle = plot.linestyle_dotted)
plot(bb_plot_seg ? bb_m0 : na, title="BB Base", color=col_bb, linewidth=1, style=plot.style_steplinebr, linestyle = plot.linestyle_dotted)
plot(bb_plot_seg ? bb_u1 : na, title="BB Upper 1", color=col_bb, linewidth=1, style=plot.style_steplinebr, linestyle = plot.linestyle_dotted)
plot(bb_plot_seg ? bb_u2 : na, title="BB Upper 2", color=col_bb, linewidth=1, style=plot.style_steplinebr, linestyle = plot.linestyle_dotted)

// ===========================
// Reference levels (YDH/YDL/YDC from prior completed NY RTH; PMH/PML from premarket) — MapleStax_Levels-style line.new
// ===========================
getLevelLabelText(level_name, level_price) =>
    string result = ""
    if show_level_name and show_level_price
        result := level_name + " " + str.tostring(level_price, "#.##")
    else if show_level_name
        result := level_name
    else if show_level_price
        result := str.tostring(level_price, "#.##")
    result

is_premarket = not na(time(timeframe.period, "1800-0929", ny_tz))
is_regular = not na(time(timeframe.period, "0930-1600", ny_tz))
new_day = is_regular and not is_regular[1]
premarket_start = is_premarket and not is_premarket[1]

// YDH/YDL/YDC: do not use D1 on `ticker.standard` — that daily is typically full ETH/Globex session, so high[1]/low[1] are not RTH-only. Track H/L/last close only while `is_regular`, commit when RTH block ends.
bool rth_enter = is_regular and not is_regular[1]
bool rth_exit = not is_regular and is_regular[1]
var float rth_run_hi = na
var float rth_run_lo = na
var float ydh_prev_rth = na
var float ydl_prev_rth = na
var float ydc_prev_rth = na
if rth_exit
    ydh_prev_rth := rth_run_hi
    ydl_prev_rth := rth_run_lo
    ydc_prev_rth := close[1]
if rth_enter
    rth_run_hi := high
    rth_run_lo := low
else if is_regular
    rth_run_hi := na(rth_run_hi) ? high : math.max(rth_run_hi, high)
    rth_run_lo := na(rth_run_lo) ? low : math.min(rth_run_lo, low)

float YDH = ydh_prev_rth
float YDL = ydl_prev_rth
float YDC = ydc_prev_rth

var float PMH = na
var float PML = na
var float current_pm_high = na
var float current_pm_low = na
var int day_start_t = na
var int pm_start_t = na
var int pmh_origin_t = na
var int pml_origin_t = na
var int prev_day_start_t = na

if premarket_start
    current_pm_high := high
    current_pm_low := low
    pm_start_t := time
    pmh_origin_t := time
    pml_origin_t := time

if is_premarket
    if na(current_pm_high) or high > current_pm_high
        current_pm_high := high
        pmh_origin_t := time
    if na(current_pm_low) or low < current_pm_low
        current_pm_low := low
        pml_origin_t := time

if new_day
    prev_day_start_t := day_start_t
    PMH := current_pm_high
    PML := current_pm_low
    day_start_t := time

if is_regular
    if na(day_start_t)
        day_start_t := time

var line ydh_line = na
var line ydl_line = na
var line ydc_line = na
var line pmh_line = na
var line pml_line = na
var label ydh_lbl = na
var label ydl_lbl = na
var label ydc_lbl = na
var label pmh_lbl = na
var label pml_lbl = na

if new_day
    line.delete(ydh_line)
    line.delete(ydl_line)
    line.delete(ydc_line)
    line.delete(pmh_line)
    line.delete(pml_line)
    label.delete(ydh_lbl)
    label.delete(ydl_lbl)
    label.delete(ydc_lbl)
    label.delete(pmh_lbl)
    label.delete(pml_lbl)
    ydh_line := na
    ydl_line := na
    ydc_line := na
    pmh_line := na
    pml_line := na
    ydh_lbl := na
    ydl_lbl := na
    ydc_lbl := na
    pmh_lbl := na
    pml_lbl := na

pmh_display = is_premarket ? current_pm_high : PMH
pml_display = is_premarket ? current_pm_low : PML

if not na(YDH)
    int lvl_bar_ms = int(timeframe.in_seconds(timeframe.period) * 1000)
    int lvl_line_t2 = time + extend_levels_bars * lvl_bar_ms
    int yd_line_t1 = int(nz(prev_day_start_t, nz(day_start_t, time)))
    int pmh_line_t1 = is_premarket ? int(nz(pm_start_t, time)) : int(nz(pmh_origin_t, nz(day_start_t, time)))
    int pml_line_t1 = is_premarket ? int(nz(pm_start_t, time)) : int(nz(pml_origin_t, nz(day_start_t, time)))
    if show_ydh
        if na(ydh_line)
            ydh_line := line.new(yd_line_t1, YDH, lvl_line_t2, YDH, xloc=xloc.bar_time, color=col_ydh, width=ydh_width, style=f_ref_line_style(ydh_line_style))
        else
            line.set_x1(ydh_line, yd_line_t1)
            line.set_y1(ydh_line, YDH)
            line.set_x2(ydh_line, lvl_line_t2)
            line.set_y2(ydh_line, YDH)
            line.set_color(ydh_line, col_ydh)
            line.set_width(ydh_line, ydh_width)
            line.set_style(ydh_line, f_ref_line_style(ydh_line_style))
        if show_level_name or show_level_price
            if na(ydh_lbl)
                ydh_lbl := label.new(lvl_line_t2, YDH, getLevelLabelText("YDH", YDH), xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_ydh, style=label.style_label_left, size=size.small)
            else
                label.set_x(ydh_lbl, lvl_line_t2)
                label.set_y(ydh_lbl, YDH)
                label.set_text(ydh_lbl, getLevelLabelText("YDH", YDH))
                label.set_textcolor(ydh_lbl, col_ydh)
    if show_ydl
        if na(ydl_line)
            ydl_line := line.new(yd_line_t1, YDL, lvl_line_t2, YDL, xloc=xloc.bar_time, color=col_ydl, width=ydl_width, style=f_ref_line_style(ydl_line_style))
        else
            line.set_x1(ydl_line, yd_line_t1)
            line.set_y1(ydl_line, YDL)
            line.set_x2(ydl_line, lvl_line_t2)
            line.set_y2(ydl_line, YDL)
            line.set_color(ydl_line, col_ydl)
            line.set_width(ydl_line, ydl_width)
            line.set_style(ydl_line, f_ref_line_style(ydl_line_style))
        if show_level_name or show_level_price
            if na(ydl_lbl)
                ydl_lbl := label.new(lvl_line_t2, YDL, getLevelLabelText("YDL", YDL), xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_ydl, style=label.style_label_left, size=size.small)
            else
                label.set_x(ydl_lbl, lvl_line_t2)
                label.set_y(ydl_lbl, YDL)
                label.set_text(ydl_lbl, getLevelLabelText("YDL", YDL))
                label.set_textcolor(ydl_lbl, col_ydl)
    if show_ydc
        if na(ydc_line)
            ydc_line := line.new(yd_line_t1, YDC, lvl_line_t2, YDC, xloc=xloc.bar_time, color=col_ydc, width=ydc_width, style=f_ref_line_style(ydc_line_style))
        else
            line.set_x1(ydc_line, yd_line_t1)
            line.set_y1(ydc_line, YDC)
            line.set_x2(ydc_line, lvl_line_t2)
            line.set_y2(ydc_line, YDC)
            line.set_color(ydc_line, col_ydc)
            line.set_width(ydc_line, ydc_width)
            line.set_style(ydc_line, f_ref_line_style(ydc_line_style))
        if show_level_name or show_level_price
            if na(ydc_lbl)
                ydc_lbl := label.new(lvl_line_t2, YDC, getLevelLabelText("YDC", YDC), xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_ydc, style=label.style_label_left, size=size.small)
            else
                label.set_x(ydc_lbl, lvl_line_t2)
                label.set_y(ydc_lbl, YDC)
                label.set_text(ydc_lbl, getLevelLabelText("YDC", YDC))
                label.set_textcolor(ydc_lbl, col_ydc)
    if show_pmh and not na(pmh_display)
        if na(pmh_line)
            pmh_line := line.new(pmh_line_t1, pmh_display, lvl_line_t2, pmh_display, xloc=xloc.bar_time, color=col_pmh, width=pmh_width, style=f_ref_line_style(pmh_line_style))
        else
            line.set_x1(pmh_line, pmh_line_t1)
            line.set_y1(pmh_line, pmh_display)
            line.set_x2(pmh_line, lvl_line_t2)
            line.set_y2(pmh_line, pmh_display)
            line.set_color(pmh_line, col_pmh)
            line.set_width(pmh_line, pmh_width)
            line.set_style(pmh_line, f_ref_line_style(pmh_line_style))
        if show_level_name or show_level_price
            if na(pmh_lbl)
                pmh_lbl := label.new(lvl_line_t2, pmh_display, getLevelLabelText("PMH", pmh_display), xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_pmh, style=label.style_label_left, size=size.small)
            else
                label.set_x(pmh_lbl, lvl_line_t2)
                label.set_y(pmh_lbl, pmh_display)
                label.set_text(pmh_lbl, getLevelLabelText("PMH", pmh_display))
                label.set_textcolor(pmh_lbl, col_pmh)
    if show_pml and not na(pml_display)
        if na(pml_line)
            pml_line := line.new(pml_line_t1, pml_display, lvl_line_t2, pml_display, xloc=xloc.bar_time, color=col_pml, width=pml_width, style=f_ref_line_style(pml_line_style))
        else
            line.set_x1(pml_line, pml_line_t1)
            line.set_y1(pml_line, pml_display)
            line.set_x2(pml_line, lvl_line_t2)
            line.set_y2(pml_line, pml_display)
            line.set_color(pml_line, col_pml)
            line.set_width(pml_line, pml_width)
            line.set_style(pml_line, f_ref_line_style(pml_line_style))
        if show_level_name or show_level_price
            if na(pml_lbl)
                pml_lbl := label.new(lvl_line_t2, pml_display, getLevelLabelText("PML", pml_display), xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_pml, style=label.style_label_left, size=size.small)
            else
                label.set_x(pml_lbl, lvl_line_t2)
                label.set_y(pml_lbl, pml_display)
                label.set_text(pml_lbl, getLevelLabelText("PML", pml_display))
                label.set_textcolor(pml_lbl, col_pml)

// ===========================
// Opening Range — ET session opens: NY 9:30, London 3:00, Asian 20:00; first or_minutes from each (HALO-style per session)
// ===========================
int or_ms = or_minutes * 60000
ny_or_open = timestamp(ny_tz, year(time, ny_tz), month(time, ny_tz), dayofmonth(time, ny_tz), 9, 30)
ny_or_close = ny_or_open + or_ms
ny_or_active = time >= ny_or_open and time < ny_or_close
ln_or_open = timestamp(ny_tz, year(time, ny_tz), month(time, ny_tz), dayofmonth(time, ny_tz), 3, 0)
ln_or_close = ln_or_open + or_ms
ln_or_active = time >= ln_or_open and time < ln_or_close
as_or_open = f_asia_or_open_ms()
as_or_close = as_or_open + or_ms
as_or_active = time >= as_or_open and time < as_or_close

var float ORHigh_NY = na
var float ORLow_NY = na
var float ORHigh_LN = na
var float ORLow_LN = na
var float ORHigh_AS = na
var float ORLow_AS = na

if or_ny and ny_or_active and not ny_or_active[1]
    ORHigh_NY := na
    ORLow_NY := na
if or_london and ln_or_active and not ln_or_active[1]
    ORHigh_LN := na
    ORLow_LN := na
if or_asian and as_or_active and not as_or_active[1]
    ORHigh_AS := na
    ORLow_AS := na

if or_ny and ny_or_active
    ORHigh_NY := na(ORHigh_NY) ? high : math.max(ORHigh_NY, high)
    ORLow_NY := na(ORLow_NY) ? low : math.min(ORLow_NY, low)
if or_london and ln_or_active
    ORHigh_LN := na(ORHigh_LN) ? high : math.max(ORHigh_LN, high)
    ORLow_LN := na(ORLow_LN) ? low : math.min(ORLow_LN, low)
if or_asian and as_or_active
    ORHigh_AS := na(ORHigh_AS) ? high : math.max(ORHigh_AS, high)
    ORLow_AS := na(ORLow_AS) ? low : math.min(ORLow_AS, low)

ny_done = or_ny and not ny_or_active and not na(ORHigh_NY)
ln_done = or_london and not ln_or_active and not na(ORHigh_LN)
as_done = or_asian and not as_or_active and not na(ORHigh_AS)

plotORNYH = plot(ny_done ? ORHigh_NY : na, color=col_orb_ny_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_solid, title="OR NY High")
plotORNYL = plot(ny_done ? ORLow_NY : na, color=col_orb_ny_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_solid, title="OR NY Low")
plotORLNH = plot(ln_done ? ORHigh_LN : na, color=col_orb_ln_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR London High")
plotORLNL = plot(ln_done ? ORLow_LN : na, color=col_orb_ln_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR London Low")
plotORASH = plot(as_done ? ORHigh_AS : na, color=col_orb_as_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR Asian High")
plotORASL = plot(as_done ? ORLow_AS : na, color=col_orb_as_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR Asian Low")
plotORNYActH = plot(or_ny and ny_or_active ? ORHigh_NY : na, color=col_orb_ny_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR NY Active High")
plotORNYActL = plot(or_ny and ny_or_active ? ORLow_NY : na, color=col_orb_ny_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR NY Active Low")
plotORLNActH = plot(or_london and ln_or_active ? ORHigh_LN : na, color=col_orb_ln_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR London Active High")
plotORLNActL = plot(or_london and ln_or_active ? ORLow_LN : na, color=col_orb_ln_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR London Active Low")
plotORASActH = plot(or_asian and as_or_active ? ORHigh_AS : na, color=col_orb_as_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR Asian Active High")
plotORASActL = plot(or_asian and as_or_active ? ORLow_AS : na, color=col_orb_as_lbl, linewidth=1, style=plot.style_steplinebr, linestyle=plot.linestyle_dotted, title="OR Asian Active Low")
fill(plotORNYActH, plotORNYActL, color=col_orb_ny_fill, title="OR NY Active Fill")
fill(plotORLNActH, plotORLNActL, color=col_orb_ln_fill, title="OR London Active Fill")
fill(plotORASActH, plotORASActL, color=col_orb_as_fill, title="OR Asian Active Fill")
fill(plotORNYH, plotORNYL, color=col_orb_ny_fill, title="OR NY Completed Fill")
fill(plotORLNH, plotORLNL, color=col_orb_ln_fill, title="OR London Completed Fill")
fill(plotORASH, plotORASL, color=col_orb_as_fill, title="OR Asian Completed Fill")

var label orb_ny_h_lbl = na
var label orb_ny_l_lbl = na
var label orb_ln_h_lbl = na
var label orb_ln_l_lbl = na
var label orb_as_h_lbl = na
var label orb_as_l_lbl = na
if not show_any_or
    if not na(orb_ny_h_lbl)
        label.delete(orb_ny_h_lbl)
        orb_ny_h_lbl := na
    if not na(orb_ny_l_lbl)
        label.delete(orb_ny_l_lbl)
        orb_ny_l_lbl := na
    if not na(orb_ln_h_lbl)
        label.delete(orb_ln_h_lbl)
        orb_ln_h_lbl := na
    if not na(orb_ln_l_lbl)
        label.delete(orb_ln_l_lbl)
        orb_ln_l_lbl := na
    if not na(orb_as_h_lbl)
        label.delete(orb_as_h_lbl)
        orb_as_h_lbl := na
    if not na(orb_as_l_lbl)
        label.delete(orb_as_l_lbl)
        orb_as_l_lbl := na
else
    int or_lbl_x = bar_index + extend_levels_bars
    // NY labels
    if not or_ny
        if not na(orb_ny_h_lbl)
            label.delete(orb_ny_h_lbl)
            orb_ny_h_lbl := na
        if not na(orb_ny_l_lbl)
            label.delete(orb_ny_l_lbl)
            orb_ny_l_lbl := na
    else
        float y_ny_h = (ny_or_active or ny_done) and not na(ORHigh_NY) ? ORHigh_NY : na
        float y_ny_l = (ny_or_active or ny_done) and not na(ORLow_NY) ? ORLow_NY : na
        if na(y_ny_h)
            if not na(orb_ny_h_lbl)
                label.delete(orb_ny_h_lbl)
                orb_ny_h_lbl := na
        else if show_level_name or show_level_price
            if na(orb_ny_h_lbl)
                orb_ny_h_lbl := label.new(or_lbl_x, y_ny_h, getLevelLabelText("NY ORB-H", y_ny_h), color=color.new(color.white, 100), textcolor=col_orb_ny_lbl, style=label.style_label_left, size=size.small)
            else
                label.set_x(orb_ny_h_lbl, or_lbl_x)
                label.set_y(orb_ny_h_lbl, y_ny_h)
                label.set_text(orb_ny_h_lbl, getLevelLabelText("NY ORB-H", y_ny_h))
        else
            if not na(orb_ny_h_lbl)
                label.delete(orb_ny_h_lbl)
                orb_ny_h_lbl := na
        if na(y_ny_l)
            if not na(orb_ny_l_lbl)
                label.delete(orb_ny_l_lbl)
                orb_ny_l_lbl := na
        else if show_level_name or show_level_price
            if na(orb_ny_l_lbl)
                orb_ny_l_lbl := label.new(or_lbl_x, y_ny_l, getLevelLabelText("NY ORB-L", y_ny_l), color=color.new(color.white, 100), textcolor=col_orb_ny_lbl, style=label.style_label_left, size=size.small)
            else
                label.set_x(orb_ny_l_lbl, or_lbl_x)
                label.set_y(orb_ny_l_lbl, y_ny_l)
                label.set_text(orb_ny_l_lbl, getLevelLabelText("NY ORB-L", y_ny_l))
        else
            if not na(orb_ny_l_lbl)
                label.delete(orb_ny_l_lbl)
                orb_ny_l_lbl := na
    // London labels
    if not or_london
        if not na(orb_ln_h_lbl)
            label.delete(orb_ln_h_lbl)
            orb_ln_h_lbl := na
        if not na(orb_ln_l_lbl)
            label.delete(orb_ln_l_lbl)
            orb_ln_l_lbl := na
    else
        float y_ln_h = (ln_or_active or ln_done) and not na(ORHigh_LN) ? ORHigh_LN : na
        float y_ln_l = (ln_or_active or ln_done) and not na(ORLow_LN) ? ORLow_LN : na
        if na(y_ln_h)
            if not na(orb_ln_h_lbl)
                label.delete(orb_ln_h_lbl)
                orb_ln_h_lbl := na
        else if show_level_name or show_level_price
            if na(orb_ln_h_lbl)
                orb_ln_h_lbl := label.new(or_lbl_x, y_ln_h, getLevelLabelText("LN ORB-H", y_ln_h), color=color.new(color.white, 100), textcolor=col_orb_ln_lbl, style=label.style_label_left, size=size.small)
            else
                label.set_x(orb_ln_h_lbl, or_lbl_x)
                label.set_y(orb_ln_h_lbl, y_ln_h)
                label.set_text(orb_ln_h_lbl, getLevelLabelText("LN ORB-H", y_ln_h))
        else
            if not na(orb_ln_h_lbl)
                label.delete(orb_ln_h_lbl)
                orb_ln_h_lbl := na
        if na(y_ln_l)
            if not na(orb_ln_l_lbl)
                label.delete(orb_ln_l_lbl)
                orb_ln_l_lbl := na
        else if show_level_name or show_level_price
            if na(orb_ln_l_lbl)
                orb_ln_l_lbl := label.new(or_lbl_x, y_ln_l, getLevelLabelText("LN ORB-L", y_ln_l), color=color.new(color.white, 100), textcolor=col_orb_ln_lbl, style=label.style_label_left, size=size.small)
            else
                label.set_x(orb_ln_l_lbl, or_lbl_x)
                label.set_y(orb_ln_l_lbl, y_ln_l)
                label.set_text(orb_ln_l_lbl, getLevelLabelText("LN ORB-L", y_ln_l))
        else
            if not na(orb_ln_l_lbl)
                label.delete(orb_ln_l_lbl)
                orb_ln_l_lbl := na
    // Asian labels
    if not or_asian
        if not na(orb_as_h_lbl)
            label.delete(orb_as_h_lbl)
            orb_as_h_lbl := na
        if not na(orb_as_l_lbl)
            label.delete(orb_as_l_lbl)
            orb_as_l_lbl := na
    else
        float y_as_h = (as_or_active or as_done) and not na(ORHigh_AS) ? ORHigh_AS : na
        float y_as_l = (as_or_active or as_done) and not na(ORLow_AS) ? ORLow_AS : na
        if na(y_as_h)
            if not na(orb_as_h_lbl)
                label.delete(orb_as_h_lbl)
                orb_as_h_lbl := na
        else if show_level_name or show_level_price
            if na(orb_as_h_lbl)
                orb_as_h_lbl := label.new(or_lbl_x, y_as_h, getLevelLabelText("AS ORB-H", y_as_h), color=color.new(color.white, 100), textcolor=col_orb_as_lbl, style=label.style_label_left, size=size.small)
            else
                label.set_x(orb_as_h_lbl, or_lbl_x)
                label.set_y(orb_as_h_lbl, y_as_h)
                label.set_text(orb_as_h_lbl, getLevelLabelText("AS ORB-H", y_as_h))
        else
            if not na(orb_as_h_lbl)
                label.delete(orb_as_h_lbl)
                orb_as_h_lbl := na
        if na(y_as_l)
            if not na(orb_as_l_lbl)
                label.delete(orb_as_l_lbl)
                orb_as_l_lbl := na
        else if show_level_name or show_level_price
            if na(orb_as_l_lbl)
                orb_as_l_lbl := label.new(or_lbl_x, y_as_l, getLevelLabelText("AS ORB-L", y_as_l), color=color.new(color.white, 100), textcolor=col_orb_as_lbl, style=label.style_label_left, size=size.small)
            else
                label.set_x(orb_as_l_lbl, or_lbl_x)
                label.set_y(orb_as_l_lbl, y_as_l)
                label.set_text(orb_as_l_lbl, getLevelLabelText("AS ORB-L", y_as_l))
        else
            if not na(orb_as_l_lbl)
                label.delete(orb_as_l_lbl)
                orb_as_l_lbl := na

// CBC state logic: strict prior-bar breaks only (AsiaRoo / HOS-style: close < low[1] / close > high[1]).
f_cbc_state() =>
    var bool state = false
    state := state[1]
    bool bear_flip_lvl = close < low[1]
    bool bull_flip_lvl = close > high[1]
    if state and bear_flip_lvl
        state := false
    if not state and bull_flip_lvl
        state := true
    state

// Current timeframe CBC logic
cbc = f_cbc_state()

// CBC flips (same as ThinkScript BullFlip / BearFlip)
bull_flip = cbc and not cbc[1]
bear_flip = not cbc and cbc[1]
any_flip = bull_flip or bear_flip
// CBC Reversal: prior bar flipped and this bar flips again (double-flip; highlight the second candle)
reversal = any_flip and any_flip[1]

// When Show Reversal is off, Reversal bars use normal Bear/Bull styling
bear_plain = bear_flip and (not reversal or not show_reversal)
bull_plain = bull_flip and (not reversal or not show_reversal)
bear_reversal_mk = show_reversal and bear_flip and reversal
bull_reversal_mk = show_reversal and bull_flip and reversal

// CBC triangles — constant #hex per row (Style tab).
plotshape(bear_plain, style=shape.triangledown, location=location.abovebar, color=col_cbc_short, size=size.tiny, display=display.all - display.status_line, title="Short")
plotshape(bull_plain, style=shape.triangleup, location=location.belowbar, color=col_cbc_long, size=size.tiny, display=display.all - display.status_line, title="Long")
plotshape(bear_reversal_mk, style=shape.triangledown, location=location.abovebar, color=#F9CB00, size=size.tiny, display=display.all - display.status_line, title="Short Reversal")
plotshape(bull_reversal_mk, style=shape.triangleup, location=location.belowbar, color=#F9CB00, size=size.tiny, display=display.all - display.status_line, title="Long Reversal")

// HTF label anchor on LTF: bar in completed HTF window whose low (LONG) or high (SHORT) is closest to HTF signal extreme; tie → larger offset (earlier bar).
f_htf_anchor_long(float sig_lo, int t_open, int t_close, int max_off) =>
    int best_off = 0
    float best_err = na
    bool found = false
    for off = 0 to max_off
        if bar_index >= off
            int ot = time[off]
            if not na(ot) and not na(t_open) and not na(t_close) and ot >= t_open and ot <= t_close
                float err = math.abs(low[off] - sig_lo)
                if not found or err < best_err or (err == best_err and off > best_off)
                    best_err := err
                    best_off := off
                    found := true
    int off_use = found ? best_off : 0
    [bar_index - off_use, low[off_use] - (high[off_use] - low[off_use]) * 0.3]

f_htf_anchor_short(float sig_hi, int t_open, int t_close, int max_off) =>
    int best_off = 0
    float best_err = na
    bool found = false
    for off = 0 to max_off
        if bar_index >= off
            int ot = time[off]
            if not na(ot) and not na(t_open) and not na(t_close) and ot >= t_open and ot <= t_close
                float err = math.abs(high[off] - sig_hi)
                if not found or err < best_err or (err == best_err and off > best_off)
                    best_err := err
                    best_off := off
                    found := true
    int off_use = found ? best_off : 0
    [bar_index - off_use, high[off_use] + (high[off_use] - low[off_use]) * 0.3]

// Background colour
// bgcolor(show_background ? (cbc and not cbc[1] ? color.rgb(255, 235, 59, 71)  : not cbc and cbc[1] ? color.rgb(5, 185, 240, 59) : na) : na) 

// Higher timeframe CBC logic (native HTF OHLC CBC state) + prior HTF bar high/low for flip-level dash
[htf_cbc, htf_hi1, htf_lo1] = request.security(ticker.standard(syminfo.tickerid), htf_timeframe, [f_cbc_state(), high[1], low[1]], lookahead=barmerge.lookahead_on)
htf_cbc_labels_f = request.security(ticker.standard(syminfo.tickerid), htf_timeframe, f_cbc_state()[1] ? 1.0 : 0.0, lookahead=barmerge.lookahead_off)
[sig_htf_lo, sig_htf_hi, sig_htf_t_open, sig_htf_t_close] = request.security(ticker.standard(syminfo.tickerid), htf_timeframe, [low[1], high[1], time[1], time_close[1]], lookahead=barmerge.lookahead_off)

// HTF + LTF pivot detection (ta.pivothigh/low: classical N-left N-right). Replace-only persistence: a line stays until a NEW same-type pivot prints in the same timeframe.
[htf_piv_hi_raw, htf_piv_lo_raw, htf_piv_bar_t] = request.security(ticker.standard(syminfo.tickerid), htf_timeframe, [ta.pivothigh(high, htf_piv_n, htf_piv_n), ta.pivotlow(low, htf_piv_n, htf_piv_n), time[htf_piv_n]], lookahead=barmerge.lookahead_off)
ltf_piv_hi_raw = ta.pivothigh(high, ltf_piv_n, ltf_piv_n)
ltf_piv_lo_raw = ta.pivotlow(low, ltf_piv_n, ltf_piv_n)
int ltf_piv_bar_t = time[ltf_piv_n]

var float h_last_hi = na
var int   h_last_hi_t = na
var float h_last_lo = na
var int   h_last_lo_t = na
var float l_last_hi = na
var int   l_last_hi_t = na
var float l_last_lo = na
var int   l_last_lo_t = na

if not na(htf_piv_hi_raw)
    h_last_hi := htf_piv_hi_raw
    h_last_hi_t := htf_piv_bar_t
if not na(htf_piv_lo_raw)
    h_last_lo := htf_piv_lo_raw
    h_last_lo_t := htf_piv_bar_t
if not na(ltf_piv_hi_raw)
    l_last_hi := ltf_piv_hi_raw
    l_last_hi_t := ltf_piv_bar_t
if not na(ltf_piv_lo_raw)
    l_last_lo := ltf_piv_lo_raw
    l_last_lo_t := ltf_piv_bar_t

int htf_sec_lbl = timeframe.in_seconds(htf_timeframe)
int ch_sec_lbl = timeframe.in_seconds(timeframe.period)
int max_htf_lbl_off = 32
if not na(htf_sec_lbl) and not na(ch_sec_lbl) and ch_sec_lbl > 0
    max_htf_lbl_off := int(math.ceil(htf_sec_lbl / ch_sec_lbl)) + 4
    max_htf_lbl_off := int(math.min(max_htf_lbl_off, 32))
ltf_relocate_htf_labels = not na(htf_sec_lbl) and not na(ch_sec_lbl) and ch_sec_lbl > 0 and ch_sec_lbl < htf_sec_lbl
bool htf_same_tf_chart = not na(htf_sec_lbl) and not na(ch_sec_lbl) and ch_sec_lbl == htf_sec_lbl

// Next flip prices (ThinkScript parity): bulls flip bear at prior low; bears flip bull at prior high (no offset)
ltf_flip_price = cbc[1] ? low[1] : high[1]
htf_flip_price = htf_cbc[1] ? htf_lo1 : htf_hi1

var line cbc_flip_ltf_line = na
var line cbc_flip_htf_line = na
var line brsg_line_top = na
var line brsg_line_bot = na
var line h_piv_hi_ln = na
var line h_piv_lo_ln = na
var line l_piv_hi_ln = na
var line l_piv_lo_ln = na
if barstate.islast
    if not na(cbc_flip_ltf_line)
        line.delete(cbc_flip_ltf_line)
        cbc_flip_ltf_line := na
    if not na(cbc_flip_htf_line)
        line.delete(cbc_flip_htf_line)
        cbc_flip_htf_line := na
    if not na(brsg_line_top)
        line.delete(brsg_line_top)
        brsg_line_top := na
    if not na(brsg_line_bot)
        line.delete(brsg_line_bot)
        brsg_line_bot := na
    if not na(h_piv_hi_ln)
        line.delete(h_piv_hi_ln)
        h_piv_hi_ln := na
    if not na(h_piv_lo_ln)
        line.delete(h_piv_lo_ln)
        h_piv_lo_ln := na
    if not na(l_piv_hi_ln)
        line.delete(l_piv_hi_ln)
        l_piv_hi_ln := na
    if not na(l_piv_lo_ln)
        line.delete(l_piv_lo_ln)
        l_piv_lo_ln := na
    if bar_index > 0 and not na(time[1]) and not na(time_close[1])
        if show_cbc_flip_ltf and not na(ltf_flip_price)
            cbc_flip_ltf_line := line.new(time[1], ltf_flip_price, time_close[1], ltf_flip_price, xloc=xloc.bar_time, color=cbc[1] ? col_ltf_flip_l : col_ltf_flip_h, width=cbc_flip_ltf_width, style=line.style_solid, extend=extend.none)
        if htf_enabled and show_cbc_flip_htf and not na(htf_flip_price)
            cbc_flip_htf_line := line.new(time[1], htf_flip_price, time_close[1], htf_flip_price, xloc=xloc.bar_time, color=htf_cbc[1] ? col_htf_flip_l : col_htf_flip_h, width=cbc_flip_htf_width, style=line.style_solid, extend=extend.none)
        if show_brsg_zone
            float brsg_rng = high[1] - low[1]
            if not na(brsg_rng)
                float y_brsg_top = low[1] + brsg_rng * brsg_high_mult
                float y_brsg_bot = low[1] + brsg_rng * brsg_low_mult
                brsg_line_top := line.new(time[1], y_brsg_top, time_close[1], y_brsg_top, xloc=xloc.bar_time, color=col_brsg_zone, width=cbc_flip_ltf_width, style=line.style_solid, extend=extend.none)
                brsg_line_bot := line.new(time[1], y_brsg_bot, time_close[1], y_brsg_bot, xloc=xloc.bar_time, color=col_brsg_zone, width=cbc_flip_ltf_width, style=line.style_solid, extend=extend.none)
    if not na(ch_sec_lbl) and ch_sec_lbl > 0
        int piv_t_right = time_close + ch_sec_lbl * 1000
        if show_htf_pivots and htf_enabled
            if not na(h_last_hi) and not na(h_last_hi_t)
                h_piv_hi_ln := line.new(h_last_hi_t, h_last_hi, piv_t_right, h_last_hi, xloc=xloc.bar_time, color=col_htf_piv_res, style=f_ref_line_style(htf_piv_style), width=htf_piv_w, extend=extend.none)
            if not na(h_last_lo) and not na(h_last_lo_t)
                h_piv_lo_ln := line.new(h_last_lo_t, h_last_lo, piv_t_right, h_last_lo, xloc=xloc.bar_time, color=col_htf_piv_sup, style=f_ref_line_style(htf_piv_style), width=htf_piv_w, extend=extend.none)
        if show_ltf_pivots
            if not na(l_last_hi) and not na(l_last_hi_t)
                l_piv_hi_ln := line.new(l_last_hi_t, l_last_hi, piv_t_right, l_last_hi, xloc=xloc.bar_time, color=col_ltf_piv_res, style=f_ref_line_style(ltf_piv_style), width=ltf_piv_w, extend=extend.none)
            if not na(l_last_lo) and not na(l_last_lo_t)
                l_piv_lo_ln := line.new(l_last_lo_t, l_last_lo, piv_t_right, l_last_lo, xloc=xloc.bar_time, color=col_ltf_piv_sup, style=f_ref_line_style(ltf_piv_style), width=ltf_piv_w, extend=extend.none)

// CBC agreement bars: chart vs HTF (optional). Single solid plotcandle — same color on body, wick, border (Style tab: Body/Wick/Border like v1.15). Confirmed bars only; no overlay on the forming bar.
both_cbc_long = cbc and htf_cbc
both_cbc_short = not cbc and not htf_cbc
cbc_in_agreement = both_cbc_long or both_cbc_short
cbc_bar_paint_color = cbc_in_agreement ? (both_cbc_long ? col_cbc_bar_long : col_cbc_bar_short) : col_cbc_bar_neutral
cbc_agreement_plot_on = show_bar_coloring and barstate.isconfirmed
cbc_bar_final_color = cbc_agreement_plot_on ? cbc_bar_paint_color : na
pc_ag_o = cbc_agreement_plot_on ? open : na
pc_ag_h = cbc_agreement_plot_on ? high : na
pc_ag_l = cbc_agreement_plot_on ? low : na
pc_ag_c = cbc_agreement_plot_on ? close : na
plotcandle(pc_ag_o, pc_ag_h, pc_ag_l, pc_ag_c, title="CBC agreement candle", color=cbc_bar_final_color, wickcolor=cbc_bar_final_color, bordercolor=cbc_bar_final_color, display=display.all - display.status_line)

// Detect HTF CBC change when last closed HTF state changes (no signal while current HTF bar is still forming). htf_cbc_labels_f: 1=bull, 0=bear, na=no HTF data yet.
htf_bull_change = htf_enabled and show_htf_cbc_labels and not na(htf_cbc_labels_f) and not na(htf_cbc_labels_f[1]) and htf_cbc_labels_f == 1.0 and htf_cbc_labels_f[1] == 0.0
htf_bear_change = htf_enabled and show_htf_cbc_labels and not na(htf_cbc_labels_f) and not na(htf_cbc_labels_f[1]) and htf_cbc_labels_f == 0.0 and htf_cbc_labels_f[1] == 1.0

// Draw labels for HTF changes (on LTF, x/y snap to LTF bar that best matches HTF signal low/high in the completed HTF window)
if htf_bull_change
    int bull_lbl_x = bar_index
    float bull_lbl_y = low - (high - low) * 0.3
    if ltf_relocate_htf_labels and not na(sig_htf_lo) and not na(sig_htf_t_open) and not na(sig_htf_t_close)
        [bull_anch_x, bull_anch_y] = f_htf_anchor_long(sig_htf_lo, sig_htf_t_open, sig_htf_t_close, max_htf_lbl_off)
        bull_lbl_x := bull_anch_x
        bull_lbl_y := bull_anch_y
    else if htf_same_tf_chart and bar_index > 0
        bull_lbl_x := bar_index - 1
        bull_lbl_y := low[1] - (high[1] - low[1]) * 0.3
    label.new(
         x=bull_lbl_x,
         y=bull_lbl_y,
         text="LONG",
         color=color.new(col_htf_long, 80),
         textcolor=col_htf_long,
         style=label.style_label_up,
         size=htf_label_size == "tiny" ? size.tiny : htf_label_size == "small" ? size.small : htf_label_size == "normal" ? size.normal : htf_label_size == "large" ? size.large : size.huge
     )

if htf_bear_change
    int bear_lbl_x = bar_index
    float bear_lbl_y = high + (high - low) * 0.3
    if ltf_relocate_htf_labels and not na(sig_htf_hi) and not na(sig_htf_t_open) and not na(sig_htf_t_close)
        [bear_anch_x, bear_anch_y] = f_htf_anchor_short(sig_htf_hi, sig_htf_t_open, sig_htf_t_close, max_htf_lbl_off)
        bear_lbl_x := bear_anch_x
        bear_lbl_y := bear_anch_y
    else if htf_same_tf_chart and bar_index > 0
        bear_lbl_x := bar_index - 1
        bear_lbl_y := high[1] + (high[1] - low[1]) * 0.3
    label.new(
         x=bear_lbl_x,
         y=bear_lbl_y,
         text="SHORT",
         color=color.new(col_htf_short, 80),
         textcolor=col_htf_short,
         style=label.style_label_down,
         size=htf_label_size == "tiny" ? size.tiny : htf_label_size == "small" ? size.small : htf_label_size == "normal" ? size.normal : htf_label_size == "large" ? size.large : size.huge
     )

// ===========================
// Status table (Tier 1, color-coded)
// ===========================
f_status_pos(string p) =>
    switch p
        "Top left" => position.top_left
        "Top center" => position.top_center
        "Top right" => position.top_right
        "Middle left" => position.middle_left
        "Middle center" => position.middle_center
        "Middle right" => position.middle_right
        "Bottom left" => position.bottom_left
        "Bottom center" => position.bottom_center
        "Bottom right" => position.bottom_right
        => position.top_right

chart_tf_disp() =>
    string r = timeframe.isminutes ? str.tostring(timeframe.multiplier) + "m" : timeframe.isseconds ? str.tostring(timeframe.multiplier) + "s" : timeframe.isdaily ? str.tostring(timeframe.multiplier) + "D" : timeframe.isweekly ? str.tostring(timeframe.multiplier) + "W" : timeframe.ismonthly ? str.tostring(timeframe.multiplier) + "M" : timeframe.period
    r

htf_tf_disp(string tf) =>
    int sec = timeframe.in_seconds(tf)
    string r = tf
    if not na(sec) and sec > 0
        if sec == 86400
            r := "1D"
        else if sec == 604800
            r := "1W"
        else if sec < 86400 and sec % 3600 == 0
            r := str.tostring(sec / 3600) + "H"
        else if sec < 86400 * 7 and sec % 60 == 0
            r := str.tostring(sec / 60) + "m"
        else
            r := tf
    r

f_table_text_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

var table status_tbl = na
var string status_tbl_pos_last = ""
tbl_label_bg = color.new(#1E293B, 0)
tbl_header_bg = color.new(#0C1222, 0)
tbl_border = color.new(#475569, 55)
tbl_frame = color.new(#64748B, 35)
st_bull = color.new(#047857, 12)
st_bear = color.new(#9B1C1C, 12)
st_neutral = color.new(#374151, 8)
st_or_in = color.new(#57534E, 10)
txt_on = color.new(#F8FAFC, 0)
txt_label = color.new(#94A3B8, 0)
txt_head = color.new(#CBD5E1, 0)
tbl_cbc_label_bg = color.new(#0A1628, 0)
txt_cbc_label = color.new(#93C5FD, 0)

if barstate.islast
    if not show_status_table
        if not na(status_tbl)
            table.delete(status_tbl)
            status_tbl := na
        status_tbl_pos_last := ""
    else
        if not na(status_tbl) and status_tbl_pos_last != status_table_position
            table.delete(status_tbl)
            status_tbl := na
        if na(status_tbl)
            status_tbl := table.new(f_status_pos(status_table_position), 2, 8, bgcolor=color.new(#020617, 0), border_color=tbl_border, border_width=1, frame_color=tbl_frame, frame_width=2)
            table.merge_cells(status_tbl, 0, 0, 1, 0)
            status_tbl_pos_last := status_table_position
        cloud_bull = ema_bullish
        vwap_bull = not na(vwap_value) and close > vwap_value
        ema200_bull = not na(ema200) and close > ema200
        string mkt_tbl = f_market_session_et()
        float or_f_hi = mkt_tbl == "Asian" ? ORHigh_AS : mkt_tbl == "London" ? ORHigh_LN : ORHigh_NY
        float or_f_lo = mkt_tbl == "Asian" ? ORLow_AS : mkt_tbl == "London" ? ORLow_LN : ORLow_NY
        bool or_f_on = (mkt_tbl == "Asian" and or_asian) or (mkt_tbl == "London" and or_london) or (mkt_tbl == "New York" and or_ny)
        int or_f_open = mkt_tbl == "Asian" ? as_or_open : mkt_tbl == "London" ? ln_or_open : ny_or_open
        or_right = st_neutral
        or_msg = "—"
        if not show_any_or
            or_msg := "Off"
        else if not or_f_on
            or_msg := "—"
        else if time < or_f_open
            or_msg := "Before open"
        else if na(or_f_hi) or na(or_f_lo)
            or_msg := "Pending"
        else if close > or_f_hi
            or_msg := "Above range"
            or_right := st_bull
        else if close < or_f_lo
            or_msg := "Below range"
            or_right := st_bear
        else
            or_msg := "Inside range"
            or_right := st_or_in
        cloud_right = cloud_bull ? st_bull : st_bear
        cloud_msg = cloud_bull ? "Bullish" : "Bearish"
        v_right = not na(vwap_value) ? (vwap_bull ? st_bull : st_bear) : st_neutral
        v_msg = not na(vwap_value) ? (vwap_bull ? "Above" : "Below") : "—"
        e200_right = not na(ema200) ? (ema200_bull ? st_bull : st_bear) : st_neutral
        e200_msg = not na(ema200) ? (ema200_bull ? "Above" : "Below") : "—"
        htf_right = not htf_enabled ? st_neutral : na(htf_cbc_labels_f) ? st_neutral : (htf_cbc_labels_f == 1.0 ? st_bull : st_bear)
        htf_msg = not htf_enabled ? "Off" : na(htf_cbc_labels_f) ? "—" : (htf_cbc_labels_f == 1.0 ? "Bullish" : "Bearish")
        ltf_right = cbc ? st_bull : st_bear
        ltf_msg = cbc ? "Bullish" : "Bearish"
        color mkt_session_bg = mkt_tbl == "Asian" ? col_orb_as_lbl : mkt_tbl == "London" ? col_orb_ln_lbl : col_orb_ny_lbl
        color mkt_session_txt = mkt_tbl == "New York" ? color.new(#0f172a, 0) : txt_on
        tbl_txt_sz = f_table_text_size(status_table_text_size)
        tbl_hdr_txt = str.repeat("\n", status_table_header_newlines) + "MapleStax CBC  ·  " + syminfo.ticker
        table.cell(status_tbl, 0, 0, tbl_hdr_txt, bgcolor=tbl_header_bg, text_color=txt_head, text_size=tbl_txt_sz, text_halign=text.align_center)
        table.cell(status_tbl, 0, 1, "Market", bgcolor=tbl_label_bg, text_color=txt_label, text_size=tbl_txt_sz, text_halign=text.align_left)
        table.cell(status_tbl, 1, 1, mkt_tbl, bgcolor=mkt_session_bg, text_color=mkt_session_txt, text_size=tbl_txt_sz, text_halign=text.align_right)
        table.cell(status_tbl, 0, 2, "CBC (" + chart_tf_disp() + ")", bgcolor=tbl_cbc_label_bg, text_color=txt_cbc_label, text_size=tbl_txt_sz, text_halign=text.align_left)
        table.cell(status_tbl, 1, 2, ltf_msg, bgcolor=ltf_right, text_color=txt_on, text_size=tbl_txt_sz, text_halign=text.align_right)
        table.cell(status_tbl, 0, 3, "CBC (" + htf_tf_disp(htf_timeframe) + ")", bgcolor=tbl_cbc_label_bg, text_color=txt_cbc_label, text_size=tbl_txt_sz, text_halign=text.align_left)
        table.cell(status_tbl, 1, 3, htf_msg, bgcolor=htf_right, text_color=txt_on, text_size=tbl_txt_sz, text_halign=text.align_right)
        table.cell(status_tbl, 0, 4, "Opening range", bgcolor=tbl_label_bg, text_color=txt_label, text_size=tbl_txt_sz, text_halign=text.align_left)
        table.cell(status_tbl, 1, 4, or_msg, bgcolor=or_right, text_color=txt_on, text_size=tbl_txt_sz, text_halign=text.align_right)
        table.cell(status_tbl, 0, 5, "EMA cloud", bgcolor=tbl_label_bg, text_color=txt_label, text_size=tbl_txt_sz, text_halign=text.align_left)
        table.cell(status_tbl, 1, 5, cloud_msg, bgcolor=cloud_right, text_color=txt_on, text_size=tbl_txt_sz, text_halign=text.align_right)
        table.cell(status_tbl, 0, 6, "VWAP", bgcolor=tbl_label_bg, text_color=txt_label, text_size=tbl_txt_sz, text_halign=text.align_left)
        table.cell(status_tbl, 1, 6, v_msg, bgcolor=v_right, text_color=txt_on, text_size=tbl_txt_sz, text_halign=text.align_right)
        table.cell(status_tbl, 0, 7, "EMA 200", bgcolor=tbl_label_bg, text_color=txt_label, text_size=tbl_txt_sz, text_halign=text.align_left)
        table.cell(status_tbl, 1, 7, e200_msg, bgcolor=e200_right, text_color=txt_on, text_size=tbl_txt_sz, text_halign=text.align_right)

// Alerts: alertcondition() removed v1.59 (each counts toward 64 plot budget; use chart/alerts elsewhere if needed).
````
