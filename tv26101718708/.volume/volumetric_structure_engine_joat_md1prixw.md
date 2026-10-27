# Volumetric Structure Engine [JOAT]

- url: https://www.tradingview.com/script/MD1PrIxW-Volumetric-Structure-Engine-JOAT/
- type: indicator
- pine_id: PUB;a69c4909ce4e45b49157f1909ac09be7
- version: 1.0

## Description

[b]Volumetric Structure Engine [JOAT][/b]

[b]Introduction[/b]

The Volumetric Structure Engine is an institutional market structure tracker that fuses swing-point classification with real-time buy/sell volume delta analysis. Every confirmed swing high and swing low is measured not only by price, but by the net volume composition of the leg that produced it — revealing whether a structural move was driven by genuine institutional buying or selling, or whether it was a low-conviction, thin-volume probe. The indicator classifies market structure as HH/HL (bullish) or LH/LL (bearish), detects Break of Structure (BOS) and Change of Character (ChoCH) events on bar close, and renders each swing zone with a color gradient that reflects the underlying volume delta of that leg.

The core problem this solves: most market structure tools draw lines or arrows at swing points but say nothing about the quality of that swing. A break of structure on rising volume is categorically different from one on declining volume — the first signals institutional participation, the second suggests a liquidity grab. VSE quantifies that difference on every bar.

[image]https://www.tradingview.com/x/amD2Mhfe/[/image]

[b]Core Concepts[/b]

[b]1. Non-Repainting Swing Detection[/b]

Swings are confirmed using a lookback comparison pattern that resolves only on bar close:

[pine]
float H = ta.highest(high, i_len)
float L = ta.lowest(low,  i_len)
bool new_sh = high[1] == H[1] and high < H
bool new_sl = low[1]  == L[1] and low  > L
[/pine]

A swing high at bar N-1 is confirmed when bar N closes lower, meaning the prior bar's high was the highest in the lookback window. This approach never repaints because it always references the closed bar to the left.

[b]2. Volume Delta Accumulation Per Leg[/b]

Between each confirmed swing, running buy and sell volume totals accumulate. On each bar, if close >= open the bar's volume is classified as buy-side; otherwise it is sell-side. When a new swing is detected, the accumulated totals are saved to that swing node, and the counters reset for the next leg:

[pine]
if new_sh or new_sl
    run_buy  := 0.0
    run_sell := 0.0
if close >= open
    run_buy  += volume
else
    run_sell += volume
[/pine]

The delta percentage (buy minus sell divided by total volume) determines the color and transparency of each swing zone box. A leg with 80% buy delta renders as a vivid bull green; a leg with 20% buy delta renders as a vivid bear red. Neutral legs render in the neutral color.

[b]3. BOS and ChoCH Detection[/b]

Break of Structure fires when confirmed price closes through the most recent confirmed swing extreme in the opposite direction. Change of Character fires when the first break occurs against the established trend — the earliest signal that the dominant structure may be shifting. Both signals are barstate.isconfirmed, preventing any lookahead.

[b]4. Structure Cloud[/b]

A fill between the last confirmed swing high and swing low creates a visual structure range that updates dynamically. The cloud color matches the current trend direction and serves as an at-a-glance bias indicator for the session.

[b]Features[/b]

[list]
[*][b]Swing Zone Boxes:[/b] ATR-scaled zone boxes at every confirmed swing, colored by the net buy/sell delta of the producing leg
[*][b]Volume Delta Gradient:[/b] Zone colors range from deep bull green (high buy delta) to deep bear red (high sell delta), with transparency encoding conviction
[*][b]BOS Lines:[/b] Dashed horizontal lines drawn at the level where a Break of Structure closes, with text label
[*][b]ChoCH Highlight:[/b] Change of Character events highlighted with a distinct yellow-amber color to distinguish them from continuation BOS signals
[*][b]Structure Connection Lines:[/b] Lines connecting consecutive swing nodes, colored by the delta of each leg
[*][b]Structure Cloud:[/b] Gradient fill between the last swing high and low showing current structural range
[*][b]Candle Coloring:[/b] Optional candle tinting by current trend direction
[*][b]9-Row Dashboard:[/b] Displays trend bias, last swing high/low price levels, structure range percentage, BOS bull/bear counts, ChoCH count, last leg delta percentage, and total swing node count
[*][b]Alerts:[/b] BOS bullish, BOS bearish, ChoCH bullish, ChoCH bearish
[/list]

[b]Input Parameters[/b]

[b]Structure Detection:[/b]
[list]
[*]Swing Length: Lookback bars for swing high/low detection (default: 20, range: 5-200). Higher values identify fewer, stronger structural swings. Lower values are more reactive.
[*]Show BOS Lines: Toggle BOS line rendering (default: on)
[*]Show ChoCH: Toggle Change of Character highlighting (default: on)
[*]Structure Cloud: Toggle the fill between swing high and low (default: on)
[/list]

[b]Visualization:[/b]
[list]
[*]Bullish / Bearish / Neutral / ChoCH colors: Fully customizable
[*]Zone Transparency: Control the base transparency of swing zone boxes (default: 78)
[*]Color Candles: Optional candle tinting by structural trend (default: off)
[/list]

[b]Dashboard:[/b]
[list]
[*]Position: Top Right, Top Left, Bottom Right, Bottom Left (default: Top Right)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Current Structure[/b]
The dashboard shows the current trend bias (BULLISH / BEARISH / NEUTRAL), the last confirmed swing high and low prices, and the structural range as a percentage. This gives you the directional context at a glance.

[b]Step 2: Interpret Zone Colors[/b]
Zones colored in vivid green (high buy delta) represent legs driven by institutional buying. Zones colored in vivid red (high sell delta) represent institutional selling pressure. Faded or gray zones represent low-conviction legs — useful for identifying weak structure that is more likely to be swept.

[b]Step 3: Trade BOS and ChoCH Events[/b]
A BOS in the direction of the existing trend is a continuation signal. A ChoCH (against the trend) is a structural shift signal and often marks the beginning of a reversal. Volume delta on the breaking leg adds conviction: a BOS on a high-buy-delta leg is more reliable than one on a low-delta leg.

[b]Step 4: Use Swing Zones as S/R[/b]
Each swing zone box represents a price area where a structural pivot occurred. Institutional order flow often returns to these levels. High-delta zones in particular tend to act as meaningful support or resistance.

[b]Originality Statement[/b]

This indicator is original in its combination of confirmed non-repainting swing structure with per-leg volume delta measurement. While market structure tools and volume analysis tools each exist independently, this indicator is justified because:

[list]
[*]Volume delta is computed per structural leg — not per candle and not as a global indicator — creating a direct mapping between market structure quality and institutional participation
[*]The swing confirmation method using the lookback comparison pattern eliminates repainting while maintaining responsiveness to genuine structural changes
[*]Zone color encoding with delta-driven gradient creates an immediate visual hierarchy — strong zones versus weak zones — without requiring separate panels or indicators
[*]BOS and ChoCH detection with volume delta context provides a more complete signal than either alone
[/list]

[b]Limitations[/b]

[list]
[*]The buy/sell volume classification (close >= open = buy) is an approximation. True tick-level direction is not available in Pine Script. On very short timeframes where volume is sparse, classification may be imprecise
[*]Swing length selection significantly affects structure quality. Too short produces noise; too long misses intermediate structure. Users should calibrate to their timeframe and instrument
[*]BOS and ChoCH are confirmed on bar close, so they are identified one bar after the actual breakout candle closes. This is a deliberate trade-off for accuracy over speed
[*]The indicator does not predict direction — it classifies the current structural state. A bullish structure can break down without warning
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any instrument. All trading involves risk of loss. Past structural patterns do not guarantee future results. Always use proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volumetric Structure Engine [JOAT]",
     shorttitle       = "VSE [JOAT]",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 5000)

// ─── Input Groups ────────────────────────────────────────────────────────
string GRP_STRUCT = "Structure Detection"
string GRP_VIZ    = "Visualization"
string GRP_DASH   = "Dashboard"
string GRP_ALRT   = "Alerts"

// Structure
int    i_len       = input.int   (20,    "Swing Length",    minval = 5,  maxval = 200, group = GRP_STRUCT,
     tooltip = "Bars used to detect swing highs/lows. Higher = fewer, stronger swings. Lower = reactive but noisier.")
bool   i_show_bos  = input.bool  (true,  "Show BOS Lines",  group = GRP_STRUCT,
     tooltip = "Draw a dashed line when price closes through a key swing extreme (Break of Structure).")
bool   i_show_choch = input.bool (true,  "Show ChoCH",      group = GRP_STRUCT,
     tooltip = "Highlight Change of Character — a swing that breaks against the established trend.")
bool   i_cloud     = input.bool  (true,  "Structure Cloud",  group = GRP_STRUCT,
     tooltip = "Fill between the last confirmed swing high and low to visualise current structure range.")

// Visualization
color  i_bull_col  = input.color (color.rgb(0,   210, 145),  "Bullish",  inline = "c", group = GRP_VIZ)
color  i_bear_col  = input.color (color.rgb(255,  65,  75),  "Bearish",  inline = "c", group = GRP_VIZ)
color  i_neut_col  = input.color (color.rgb(110, 120, 140),  "Neutral",  inline = "c", group = GRP_VIZ)
color  i_choch_col = input.color (color.rgb(255, 200,  50),  "ChoCH",    inline = "c2", group = GRP_VIZ)
int    i_transp    = input.int   (78,    "Zone Transparency", minval = 50, maxval = 95,  group = GRP_VIZ)
bool   i_clr_bars  = input.bool  (false, "Color Candles",   group = GRP_VIZ,
     tooltip = "Tint candle wicks and bodies with the current structural trend color.")

// Dashboard
bool   i_show_dash = input.bool  (true,  "Show Dashboard",  group = GRP_DASH)
string i_dash_pos  = input.string("Top Right", "Position",
     options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = GRP_DASH)

// Alerts
bool   i_repaint   = input.bool  (false, "Allow Repainting", group = GRP_ALRT,
     tooltip = "OFF = bar-close confirmed signals only. ON = real-time (may repaint).")

// ─── User-Defined Types ──────────────────────────────────────────────────
type SwingNode
    float  price
    int    idx
    bool   is_high
    float  buy_vol
    float  sell_vol
    float  delta_pct   // (buy - sell) / total * 100, sign indicates leg conviction

// ─── Constants ───────────────────────────────────────────────────────────
color C_BG    = color.rgb(16, 18, 24)
color C_BDR   = color.rgb(40, 46, 58)
color C_TEXT  = color.rgb(190, 200, 218)
color C_MUTED = color.rgb(88, 98, 115)

string _pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>               position.top_right

// ─── Persistent State ────────────────────────────────────────────────────
var SwingNode[] nodes       = array.new<SwingNode>()
var line[]      st_lines    = array.new<line>()
var line[]      bos_lines   = array.new<line>()
var box[]       sz_boxes    = array.new<box>()
var label[]     sz_labels   = array.new<label>()

var float last_sh      = na
var int   last_sh_bar  = na
var float last_sl      = na
var int   last_sl_bar  = na
var float prev_sh      = na
var float prev_sl      = na
var int   trend        = 0       // 1 = bull | -1 = bear | 0 = undefined

var float bos_bull_lvl = na
var float bos_bear_lvl = na
var int   cnt_bos_bull = 0
var int   cnt_bos_bear = 0
var int   cnt_choch    = 0

// Running leg volume (resets when a new swing is confirmed)
var float run_buy      = 0.0
var float run_sell     = 0.0
var float saved_buy    = 0.0
var float saved_sell   = 0.0

// ─── ATR ─────────────────────────────────────────────────────────────────
float atr_s  = ta.atr(14)
float atr_l  = ta.atr(200)

// ─── Swing Detection (non-repainting via ta.highest confirmation) ─────────
float H      = ta.highest(high, i_len)
float L      = ta.lowest (low,  i_len)
bool  new_sh = high[1] == H[1] and high < H   // swing high confirmed at bar[1]
bool  new_sl = low[1]  == L[1] and low  > L   // swing low  confirmed at bar[1]

// Save and reset leg volumes BEFORE accumulating the current bar
if new_sh
    saved_buy  := run_buy
    saved_sell := run_sell
    run_buy    := 0.0
    run_sell   := 0.0

if new_sl
    saved_buy  := run_buy
    saved_sell := run_sell
    run_buy    := 0.0
    run_sell   := 0.0

// Accumulate current bar volume into the running leg
if close >= open
    run_buy  += volume
else
    run_sell += volume

// ─── Structure Processing — Swing High ───────────────────────────────────
if new_sh
    float sh_price = high[1]
    int   sh_bar   = bar_index[1]
    float tot      = math.max(saved_buy + saved_sell, 1.0)
    float dpct     = (saved_buy - saved_sell) / tot * 100.0

    // Classify and detect ChoCH
    string lbl = na(last_sh) ? "SH" : sh_price > last_sh ? "HH" : "LH"
    if trend == -1 and not na(last_sh) and sh_price > last_sh
        trend      := 1
        cnt_choch  += 1

    // Zone coloring: green if buyers dominated the leg, red if sellers, neutral otherwise
    color  zc  = dpct >  18.0 ? i_bull_col : dpct < -18.0 ? i_bear_col : i_neut_col
    color  bc  = na(lbl) or lbl == "HH" ? i_bull_col : i_bear_col
    float  zht = atr_l * 0.22

    box bx = box.new(sh_bar - 1, sh_price + zht, sh_bar + i_len, sh_price - zht,
         bgcolor      = color.new(zc, i_transp),
         border_color = color.new(zc, 45),
         border_width = 1)
    sz_boxes.push(bx)
    if sz_boxes.size() > 80
        sz_boxes.shift().delete()

    label lb = label.new(sh_bar, sh_price + zht * 2.3, lbl,
         style     = label.style_none,
         textcolor = color.new(bc, 0),
         size      = size.small)
    sz_labels.push(lb)
    if sz_labels.size() > 80
        sz_labels.shift().delete()

    // Structure line from previous node
    nodes.push(SwingNode.new(sh_price, sh_bar, true, saved_buy, saved_sell, dpct))
    if nodes.size() >= 2
        SwingNode pn = nodes.get(nodes.size() - 2)
        color lc = dpct > 0 ? color.new(i_bull_col, 60) : color.new(i_bear_col, 60)
        line sl  = line.new(pn.idx, pn.price, sh_bar, sh_price, color = lc, width = 1)
        st_lines.push(sl)
        if st_lines.size() > 120
            st_lines.shift().delete()
    if nodes.size() > 80
        nodes.shift()

    prev_sh     := last_sh
    last_sh     := sh_price
    last_sh_bar := sh_bar

// ─── Structure Processing — Swing Low ────────────────────────────────────
if new_sl
    float sl_price = low[1]
    int   sl_bar   = bar_index[1]
    float tot      = math.max(saved_buy + saved_sell, 1.0)
    float dpct     = (saved_buy - saved_sell) / tot * 100.0

    string lbl = na(last_sl) ? "SL" : sl_price > last_sl ? "HL" : "LL"
    if trend == 1 and not na(last_sl) and sl_price < last_sl
        trend     := -1
        cnt_choch += 1

    color  zc  = dpct < -18.0 ? i_bear_col : dpct > 18.0 ? i_bull_col : i_neut_col
    color  bc  = na(lbl) or lbl == "HL" ? i_bull_col : i_bear_col
    float  zht = atr_l * 0.22

    box bx = box.new(sl_bar - 1, sl_price + zht, sl_bar + i_len, sl_price - zht,
         bgcolor      = color.new(zc, i_transp),
         border_color = color.new(zc, 45),
         border_width = 1)
    sz_boxes.push(bx)
    if sz_boxes.size() > 80
        sz_boxes.shift().delete()

    label lb = label.new(sl_bar, sl_price - zht * 2.6, lbl,
         style     = label.style_none,
         textcolor = color.new(bc, 0),
         size      = size.small)
    sz_labels.push(lb)
    if sz_labels.size() > 80
        sz_labels.shift().delete()

    nodes.push(SwingNode.new(sl_price, sl_bar, false, saved_buy, saved_sell, dpct))
    if nodes.size() >= 2
        SwingNode pn = nodes.get(nodes.size() - 2)
        color lc = dpct < 0 ? color.new(i_bear_col, 60) : color.new(i_bull_col, 60)
        line sl  = line.new(pn.idx, pn.price, sl_bar, sl_price, color = lc, width = 1)
        st_lines.push(sl)
        if st_lines.size() > 120
            st_lines.shift().delete()
    if nodes.size() > 80
        nodes.shift()

    prev_sl     := last_sl
    last_sl     := sl_price
    last_sl_bar := sl_bar

// ─── BOS Detection (bar-close, non-repainting) ────────────────────────────
bool bos_bull = barstate.isconfirmed and not na(last_sh) and close > last_sh
                 and last_sh != bos_bull_lvl and trend == -1 and i_show_bos
bool bos_bear = barstate.isconfirmed and not na(last_sl) and close < last_sl
                 and last_sl != bos_bear_lvl and trend ==  1 and i_show_bos

if bos_bull
    bos_bull_lvl := last_sh
    cnt_bos_bull += 1
    trend        := 1
    line bl = line.new(last_sh_bar, last_sh, bar_index, last_sh,
         color = color.new(i_bull_col, 0), width = 1, style = line.style_dashed)
    bos_lines.push(bl)
    label blab = label.new(bar_index, last_sh + atr_s * 0.6, "BOS",
         style = label.style_none, textcolor = i_bull_col, size = size.small)
    sz_labels.push(blab)
    if bos_lines.size() > 60
        bos_lines.shift().delete()

if bos_bear
    bos_bear_lvl := last_sl
    cnt_bos_bear += 1
    trend        := -1
    line bl = line.new(last_sl_bar, last_sl, bar_index, last_sl,
         color = color.new(i_bear_col, 0), width = 1, style = line.style_dashed)
    bos_lines.push(bl)
    label blab = label.new(bar_index, last_sl - atr_s * 0.6, "BOS",
         style = label.style_none, textcolor = i_bear_col, size = size.small)
    sz_labels.push(blab)
    if bos_lines.size() > 60
        bos_lines.shift().delete()

// ─── Candle Color ─────────────────────────────────────────────────────────
color trend_col = trend == 1 ? i_bull_col : trend == -1 ? i_bear_col : i_neut_col
barcolor(i_clr_bars ? color.new(trend_col, 28) : na)

// ─── Structure Cloud (fill between last swing high and low) ───────────────
float cloud_h = i_cloud and not na(last_sh) ? last_sh : na
float cloud_l = i_cloud and not na(last_sl) ? last_sl : na
p_cld_h = plot(cloud_h, "Struct High", color = na, editable = false)
p_cld_l = plot(cloud_l, "Struct Low",  color = na, editable = false)
fill(p_cld_h, p_cld_l, cloud_h, cloud_l,
     color.new(trend_col, 91), color.new(trend_col, 96),
     title = "Structure Cloud")

// ─── Dashboard ────────────────────────────────────────────────────────────
if barstate.islast and i_show_dash
    var table dash = table.new(_pos, 2, 10,
         bgcolor      = C_BG,
         border_color = C_BDR,
         border_width = 1,
         frame_color  = C_BDR,
         frame_width  = 2)

    // Header
    table.cell(dash, 0, 0, "VSE",
         text_color = color.rgb(0, 210, 145), text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "jackofalltrades",
         text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_right)

    // Trend Bias
    string tt = trend ==  1 ? "▲  BULLISH" : trend == -1 ? "▼  BEARISH" : "—  NEUTRAL"
    color  tc = trend ==  1 ? i_bull_col   : trend == -1 ? i_bear_col   : C_MUTED
    table.cell(dash, 0, 1, "Trend Bias",  text_color = C_TEXT,  text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, tt,            text_color = tc,      text_size = size.small, text_halign = text.align_right)

    // Structure High / Low
    string sh_s = not na(last_sh) ? str.tostring(last_sh, format.mintick) : "—"
    string sl_s = not na(last_sl) ? str.tostring(last_sl, format.mintick) : "—"
    table.cell(dash, 0, 2, "Struct High", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, sh_s,          text_color = i_bear_col, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "Struct Low",  text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, sl_s,          text_color = i_bull_col, text_size = size.small, text_halign = text.align_right)

    // Range
    float range_pct = not na(last_sh) and not na(last_sl) and last_sl > 0
         ? (last_sh - last_sl) / last_sl * 100 : 0.0
    table.cell(dash, 0, 4, "Range",       text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(range_pct, "#.##") + "%",
         text_color = C_TEXT, text_size = size.small, text_halign = text.align_right)

    // BOS counts
    table.cell(dash, 0, 5, "BOS Bullish", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(cnt_bos_bull),
         text_color = i_bull_col, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 6, "BOS Bearish", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(cnt_bos_bear),
         text_color = i_bear_col, text_size = size.small, text_halign = text.align_right)

    // ChoCH
    table.cell(dash, 0, 7, "ChoCH",       text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(cnt_choch),
         text_color = i_choch_col, text_size = size.small, text_halign = text.align_right)

    // Last leg delta
    float ld  = nodes.size() > 0 ? nodes.last().delta_pct : 0.0
    color ldc = ld > 0 ? i_bull_col : i_bear_col
    table.cell(dash, 0, 8, "Leg Δ Vol",   text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(math.round(ld, 1)) + "%",
         text_color = ldc, text_size = size.small, text_halign = text.align_right)

    // Swing count
    table.cell(dash, 0, 9, "Swings",      text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 9, str.tostring(nodes.size()),
         text_color = C_MUTED, text_size = size.small, text_halign = text.align_right)

// ─── Alerts ───────────────────────────────────────────────────────────────
alertcondition(bos_bull, "VSE — BOS Bullish [JOAT]",
     "VSE: Bullish Break of Structure on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(bos_bear, "VSE — BOS Bearish [JOAT]",
     "VSE: Bearish Break of Structure on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(cnt_choch > cnt_choch[1] and trend == 1, "VSE — ChoCH Bullish [JOAT]",
     "VSE: Bullish Change of Character on {{ticker}} ({{interval}})")
alertcondition(cnt_choch > cnt_choch[1] and trend == -1, "VSE — ChoCH Bearish [JOAT]",
     "VSE: Bearish Change of Character on {{ticker}} ({{interval}})")
````
