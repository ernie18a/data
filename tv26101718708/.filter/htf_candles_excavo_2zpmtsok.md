# HTF Candles [EXCAVO]

- url: https://www.tradingview.com/script/2ZpmtSoK-HTF-Candles-EXCAVO/
- type: indicator
- pine_id: PUB;37ab52f95a9f4fccb604d164b1a42b1a
- version: 1.0

## Description

Higher Timeframe Candles in a Panel to the Right of the Chart

The [i]HTF Candles[/i] indicator renders higher timeframe candles in a
dedicated panel to the right of all chart data. Each completed HTF candle
is drawn as a solid semi-transparent box (body) with color-matched wick
lines. The currently forming candle uses a dashed outline and updates in
real time. Nothing is drawn when the chart timeframe is equal to or higher
than the selected HTF.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator on a lower timeframe chart (e.g., 5m or
              15m). The HTF panel appears to the right of all candles.
[b]Step 2[/b]  →  Default HTF is 1H. Change it in settings to match the
              context you trade (4H, D, etc.).
[b]Step 3[/b]  →  Solid boxes are completed HTF candles. Blue = bullish,
              red = bearish.
[b]Step 4[/b]  →  The rightmost dashed box is the currently forming HTF
              candle - it updates live on every bar close.
[b]Step 5[/b]  →  Set alerts for HTF Bullish or Bearish Candle Close to be
              notified when the HTF period ends.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  HTF OHLC via Built-In Resampling[/b]
The indicator uses request.security() with lookahead_off to fetch the
current HTF candle's OHLC on every bar:

  [open, high, low, close] = request.security(ticker, htf, [open, high, low, close])

Without lookahead, these values reflect only confirmed data up to the
current bar - no future leaking.

[b]◆  Candle Completion Detection[/b]
A new HTF candle is detected using ta.change(time(htf_tf)). When the time
bucket changes, the previous candle is complete. At that moment:

  htf_o[1], htf_h[1], htf_l[1], htf_c[1] = OHLC of the completed candle

These are pushed to history arrays (up to History Count entries), and
the oldest entry is trimmed when the limit is reached.

[b]◆  Panel Positioning[/b]
All candles are drawn to the right of the last chart bar:

  x1 = bar_index + right_margin + i x (candle_width + gap)
  x2 = x1 + candle_width

Positions are recalculated on every barstate.islast update. Previous
drawing objects are deleted and rebuilt each bar so the panel always
aligns with the current last bar as new data arrives.

[b]◆  Completed Candle Rendering[/b]
Each completed candle is drawn as:
  - Body: box from max(open, close) to min(open, close)
  - Upper wick: line from high to body top (only if high > body top)
  - Lower wick: line from body bottom to low (only if low < body bottom)

[b]◆  Current Candle (Dashed)[/b]
The forming candle uses the same box for fill but replaces the solid
border with four dashed lines (top, bottom, left, right edges) and
dashed wick lines. The body color reflects the live direction -
bullish (blue) if close >= open, bearish (red) otherwise.

[b]◆  Timeframe Label Pinning[/b]
The HTF label above the panel is anchored to the highest candle in the
HTF panel (not the chart's overall high). This keeps the label stable
above the panel as price moves on the underlying chart.

[b]◆  Timeframe Guard[/b]
The indicator checks timeframe.in_seconds() < timeframe.in_seconds(htf).
If the chart timeframe is equal to or higher than the HTF, no panel is
drawn.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Panel to the Right - No Overlap[/b]
HTF candles are positioned past the last chart bar so they never cover
price action. The panel shifts automatically as new bars arrive.

[b]◆  Dashed Forming Candle[/b]
The current unfinished HTF candle is visually distinct (dashed outline)
so it is never confused with confirmed history.

[b]◆  Stable Timeframe Label[/b]
The HTF label is pinned to the highest candle inside the panel itself
rather than the chart's overall high. The label position stays consistent
relative to the HTF panel even when underlying chart prices spike outside
the panel range.

[b]◆  Non-Repainting OHLC[/b]
request.security() with lookahead_off ensures that completed candle
values are final before they are committed to history. No retrospective
changes occur to completed boxes.

[b]◆  Timeframe Guard[/b]
The indicator automatically disables itself when the chart timeframe is
greater than or equal to the selected HTF — no panel is drawn,
preventing meaningless output.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ LEGEND[/b]

Legend table (bottom left) explains the visual elements:

[list]
[*][b]▮ (blue)[/b] - Bullish completed HTF candle (solid outline)
[*][b]▮ (red)[/b] - Bearish completed HTF candle (solid outline)
[*][b]┅ (blue)[/b] - Currently forming HTF candle (dashed outline)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]HTF Settings[/b]
[list]
[*][b]HTF Timeframe[/b] - 60 (1H by default)
[*][b]History Count[/b] - 5 (completed HTF candles to keep visible)
[*][b]Show Current Candle[/b] - ON (show the forming candle with dashed outline)
[/list]

[b]Visualization[/b]
[list]
[*][b]Bullish Color[/b] - blue (customizable)
[*][b]Bearish Color[/b] - red (customizable)
[*][b]Candle Width (bars)[/b] - 5 (width of each candle box)
[*][b]Gap Between Candles[/b] - 2 (spacing between boxes)
[*][b]Right Margin (bars)[/b] - 10 (distance from last chart bar to panel)
[/list]

[b]Dashboard[/b]
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
[*][b]HTF Bullish Candle Close[/b] - HTF candle closed bullish (close >= open)
[*][b]HTF Bearish Candle Close[/b] - HTF candle closed bearish (close < open)
[*][b]HTF Candle Close[/b] - any HTF candle closed
[/list]

JSON payloads include direction, ticker, price, timeframe, htf, and indicator tag.

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
// HTF Candles [EXCAVO]
// -----------------------------------------------------------------------------
// Draws higher timeframe candles to the right of the chart as a panel.
// Completed candles are solid. The currently forming candle is dashed.
// Nothing is drawn when the chart timeframe >= HTF timeframe.
//
//@version=6
indicator("HTF Candles [EXCAVO]", "EXCAVO HTF Candles",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_HTF    = "HTF Settings"
string GRP_VIZ    = "Visualization"
string GRP_DASH   = "Dashboard"
string GRP_ALERTS = "Alert Settings"

string i_htf      = input.timeframe("60", "HTF Timeframe",      group = GRP_HTF,
     tooltip = "Higher timeframe candles to show. Must be higher than the current chart timeframe.")
int    i_count    = input.int(5,          "History Count",       minval = 1, maxval = 20, group = GRP_HTF,
     tooltip = "Number of completed HTF candles to display.")
bool   i_show_cur = input.bool(true,      "Show Current Candle", group = GRP_HTF,
     tooltip = "Show the currently forming HTF candle (drawn with dashed outline).")

color  C_BULL     = input.color(color.rgb(0, 60, 180),  "Bullish Color", group = GRP_VIZ,
     tooltip = "Color for bullish HTF candles (close >= open).")
color  C_BEAR     = input.color(color.rgb(200, 40, 40), "Bearish Color", group = GRP_VIZ,
     tooltip = "Color for bearish HTF candles (close < open).")
int    i_cw       = input.int(5,  "Candle Width (bars)",  minval = 2, maxval = 30, group = GRP_VIZ,
     tooltip = "Width of each HTF candle box in bars.")
int    i_gap      = input.int(2,  "Gap Between Candles",  minval = 0, maxval = 10, group = GRP_VIZ,
     tooltip = "Gap in bars between displayed HTF candles.")
int    i_margin   = input.int(10, "Right Margin (bars)",  minval = 1, maxval = 50, group = GRP_VIZ,
     tooltip = "Distance from the last chart bar to the first HTF candle.")

bool   i_show_lgnd = input.bool(true,       "Show Legend",         group = GRP_DASH,
     tooltip = "Toggle the legend panel.")

bool   i_repaint  = input.bool(false, "Allow Repainting", group = GRP_ALERTS,
     tooltip = "OFF = signals on bar close only (recommended). ON = real-time signals that may repaint.")
bool   i_json     = input.bool(false, "JSON Alerts",      group = GRP_ALERTS,
     tooltip = "Enable JSON-formatted alerts for bot integration.")

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_DASH_BG     = color.rgb(50, 53, 60)
color C_DASH_BORDER = color.rgb(80, 85, 95)
color C_DASH_BULL   = color.rgb(80, 140, 255)
color C_DASH_BEAR   = color.rgb(240, 70, 70)

int BODY_ALPHA = 75
int WICK_ALPHA = 30

//-----------------------------------------------------------------------------}
// Functions
//-----------------------------------------------------------------------------{
f_body_col(bool is_bull) => is_bull ? color.new(C_BULL, BODY_ALPHA) : color.new(C_BEAR, BODY_ALPHA)
f_bord_col(bool is_bull) => is_bull ? color.new(C_BULL, 10)         : color.new(C_BEAR, 10)
f_wick_col(bool is_bull) => is_bull ? color.new(C_BULL, WICK_ALPHA) : color.new(C_BEAR, WICK_ALPHA)

//-----------------------------------------------------------------------------}
// Core — HTF Data
//-----------------------------------------------------------------------------{

// Timeframe guard: show nothing on chart TF >= HTF
bool tf_valid = timeframe.in_seconds() < timeframe.in_seconds(i_htf)

// Current forming HTF candle OHLC (updates every bar via built-in resampling)
[htf_o, htf_h, htf_l, htf_c] = request.security(syminfo.tickerid, i_htf,
     [open, high, low, close], lookahead = barmerge.lookahead_off)

bool new_htf   = ta.change(time(i_htf)) != 0
bool confirmed = i_repaint ? true : barstate.isconfirmed

// Completed candle history (float arrays — no drawing objects stored here)
var array<float> hist_o = array.new<float>()
var array<float> hist_h = array.new<float>()
var array<float> hist_l = array.new<float>()
var array<float> hist_c = array.new<float>()

// Alert flags
var bool last_bull = false
var bool last_bear = false

last_bull := false
last_bear := false

if tf_valid and new_htf
    // htf_x[1] = OHLC of the just-completed HTF candle
    float co = htf_o[1], float ch = htf_h[1]
    float cl = htf_l[1], float cc = htf_c[1]
    if not na(co)
        hist_o.push(co), hist_h.push(ch)
        hist_l.push(cl), hist_c.push(cc)
        while hist_o.size() > i_count
            hist_o.shift(), hist_h.shift()
            hist_l.shift(), hist_c.shift()
        if confirmed
            last_bull := cc >= co
            last_bear := cc <  co

//-----------------------------------------------------------------------------}
// Display Panel — redrawn on every barstate.islast
//-----------------------------------------------------------------------------{

// Display object arrays (all deleted and rebuilt each barstate.islast)
var array<box>   disp_boxes = array.new<box>()
var array<line>  disp_lines = array.new<line>()
var array<label> disp_lbls  = array.new<label>()

if barstate.islast and tf_valid
    // ── Clear all previous display objects ───────────────────────────────
    while disp_boxes.size() > 0
        box.delete(disp_boxes.pop())
    while disp_lines.size() > 0
        line.delete(disp_lines.pop())
    while disp_lbls.size() > 0
        label.delete(disp_lbls.pop())

    int   cw  = i_cw
    int   gap = i_gap
    int   mg  = i_margin
    int   n   = hist_o.size()

    // ── Draw completed HTF candles (oldest left → newest right) ──────────
    if n > 0
        for i = 0 to n - 1
            float co      = hist_o.get(i), float ch = hist_h.get(i)
            float cl      = hist_l.get(i), float cc = hist_c.get(i)
            bool  is_bull = cc >= co
            float bt      = math.max(co, cc), float bb = math.min(co, cc)
            int   x1      = bar_index + mg + i * (cw + gap)
            int   x2      = x1 + cw
            int   xm      = x1 + cw / 2

            disp_boxes.push(box.new(x1, bt, x2, bb,
                 bgcolor      = f_body_col(is_bull),
                 border_color = f_bord_col(is_bull),
                 border_width = 1))
            if ch > bt
                disp_lines.push(line.new(xm, ch, xm, bt,
                     color = f_wick_col(is_bull), width = 1))
            if cl < bb
                disp_lines.push(line.new(xm, bb, xm, cl,
                     color = f_wick_col(is_bull), width = 1))

    // ── Draw current forming candle (dashed, rightmost position) ─────────
    if i_show_cur
        bool  ib  = htf_c >= htf_o
        float bt  = math.max(htf_o, htf_c), float bb = math.min(htf_o, htf_c)
        int   x1  = bar_index + mg + n * (cw + gap)
        int   x2  = x1 + cw
        int   xm  = x1 + cw / 2
        color bc  = f_bord_col(ib)
        color wc  = f_wick_col(ib)

        // Fill (no border — replaced by 4 dashed lines)
        disp_boxes.push(box.new(x1, bt, x2, bb,
             bgcolor      = f_body_col(ib),
             border_width = 0))

        // Dashed border outline
        disp_lines.push(line.new(x1, bt, x2, bt, color = bc, style = line.style_dashed))
        disp_lines.push(line.new(x1, bb, x2, bb, color = bc, style = line.style_dashed))
        disp_lines.push(line.new(x1, bt, x1, bb, color = bc, style = line.style_dashed))
        disp_lines.push(line.new(x2, bt, x2, bb, color = bc, style = line.style_dashed))

        // Dashed wicks
        if htf_h > bt
            disp_lines.push(line.new(xm, htf_h, xm, bt,
                 color = wc, width = 1, style = line.style_dashed))
        if htf_l < bb
            disp_lines.push(line.new(xm, bb, xm, htf_l,
                 color = wc, width = 1, style = line.style_dashed))

    // ── Separator line between chart and panel ────────────────────────────
    float sep_top = ta.highest(high, 50)
    float sep_bot = ta.lowest(low, 50)
    disp_lines.push(line.new(bar_index + mg - 1, sep_top, bar_index + mg - 1, sep_bot,
         color = color.rgb(80, 85, 95, 60), width = 1, style = line.style_dotted))

    // ── Timeframe label above panel ───────────────────────────────────────
    // Pin label to the highest HTF candle in the panel (not chart high — avoids jumping)
    float panel_top = float(na)
    if n > 0
        for i = 0 to n - 1
            panel_top := na(panel_top) ? hist_h.get(i) : math.max(panel_top, hist_h.get(i))
    if i_show_cur and not na(htf_h)
        panel_top := na(panel_top) ? htf_h : math.max(panel_top, htf_h)

    int   total_candles = n + (i_show_cur ? 1 : 0)
    int   lbl_x         = bar_index + mg + math.max(0, total_candles - 1) * (cw + gap) / 2 + cw / 2
    float lbl_y         = na(panel_top) ? sep_top : math.max(sep_top, panel_top)
    string htf_label    = i_htf == "60" ? "1H"  : i_htf == "240" ? "4H"  :
                          i_htf == "D"  ? "1D"  : i_htf == "W"   ? "1W"  :
                          i_htf == "M"  ? "1M"  : i_htf + "m"
    disp_lbls.push(label.new(lbl_x, lbl_y, htf_label,
         color     = color.new(C_DASH_BG, 20),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.small))

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
         text_color  = C_DASH_BULL, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "▮",
         text_color = C_DASH_BULL, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 1, "Bullish candle (solid)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 2, "▮",
         text_color = C_DASH_BEAR, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 2, "Bearish candle (solid)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 3, "┅",
         text_color = C_DASH_BULL, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 3, "Current candle (forming)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 4, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(last_bull, title = "HTF Bullish Candle Close",
     message = "EXCAVO HTF Candles: Bullish candle closed on {{ticker}} ({{interval}})")
alertcondition(last_bear, title = "HTF Bearish Candle Close",
     message = "EXCAVO HTF Candles: Bearish candle closed on {{ticker}} ({{interval}})")
alertcondition(last_bull or last_bear, title = "HTF Candle Close",
     message = "EXCAVO HTF Candles: Candle closed on {{ticker}} ({{interval}})")

if i_json and (last_bull or last_bear) and barstate.isconfirmed
    string _t   = syminfo.ticker
    string _p   = str.tostring(close, format.mintick)
    string _tf  = timeframe.period
    string _dir = last_bull ? "bullish" : "bearish"
    string _msg = '{"action":"candle_close","direction":"' + _dir + '","ticker":"' + _t + '","price":' + _p + ',"timeframe":"' + _tf + '","htf":"' + i_htf + '","indicator":"EXCAVO_HTF_Candles"}'
    alert(_msg, alert.freq_once_per_bar)
````
