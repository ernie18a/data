# Dow Theory Market Structure [Levels]

- url: https://www.tradingview.com/script/xMdfOV5t-dow-theory-market-structure-levels/
- type: indicator
- pine_id: PUB;0a44b81ce1a049dc87df6d721280aaa0
- version: 1.0

## Description

[b]Theory and User Guide for "Dow Theory Market Structure [Levels]" Indicator[/b]
Theoretical Background
The indicator applies the core principles of Dow Theory in a modern context, suitable for any market (stocks, indices, crypto, forex). Developed by Charles Dow in the late 19th century, Dow Theory is the foundation of trend analysis. Its key tenets implemented in the indicator are:

1. Trend Defined by Successive Peaks and Troughs
Bullish Uptrend – each new high is higher than the previous one (Higher High, HH), and each new low is higher than the previous (Higher Low, HL).

Bearish Downtrend – each new high is lower (Lower High, LH), and each new low is lower (Lower Low, LL).

A violation of this structure signals a potential trend reversal.

2. Support and Resistance Levels
Previous significant highs and lows become future support (former highs after breakout) and resistance (former lows after breakout). The indicator automatically draws horizontal lines from each confirmed pivot and extends them until price closes beyond the level.

3. Volume Confirmation
Volume should expand in the direction of the primary trend and contract during corrections. The indicator uses directional volume:

In an uptrend, average volume on up‑bars (close > open) must exceed average volume on down‑bars.

In a downtrend, down‑bar volume must exceed up‑bar volume.

4. Inter‑Market Confirmation
Two key indices (e.g., Industrials and Transports) must confirm each other. The indicator allows selecting a confirming asset (an index or correlated instrument). The trend is considered confirmed when the confirming asset’s trend direction matches the main chart.

5. BOS (Break of Structure) and CHoCH (Change of Character)
Modern interpretation of Dow’s reversal signals:

BOS – continuation of the current trend when an extreme is renewed in its direction.

CHoCH – first reversal signal when price breaks the last opposing extreme (e.g., a new high after a series of lower highs). For strict Dow compliance, the indicator offers Strict Dow CHoCH: the signal appears only when both index and volume confirmations are satisfied (if active).

User Guide
Purpose
Visualize Dow market structure, auto‑plot key levels, determine the current trend, and generate continuation/reversal signals with optional strict confirmation.

Main Chart Elements
HH / HL / LH / LL Labels at each confirmed pivot.

Horizontal Levels – lines drawn from HH (resistance), HL (support), LH (resistance), LL (support). Levels are automatically deleted when price closes beyond them (or on a wick touch, depending on settings).

ZigZag Lines connecting consecutive highs and lows.

BOS ▲ / BOS ▼ Labels – trend continuation.

CHoCH ▲ / CHoCH ▼ Labels – potential reversal.

Info Panel (bottom‑right) – shows current trend, number of active levels, index and volume confirmation status.

Settings
Organized into functional groups:

⚙️ Main Parameters

Swing Length (bars) – number of bars left/right to confirm an extreme. Smaller values give micro‑structure; larger values capture the main trend.

📐 Levels (Horizontal Lines)

Customize visibility, color, line style, width, and break conditions (close vs. wick).

Limit the maximum number of displayed levels per type.

〰️ ZigZag

Color and thickness for up and down segments.

🏷️ HH/HL/LH/LL Labels

Size, color of labels and text.

🔔 BOS / CHoCH

Toggle BOS/CHoCH display, colors, label size.

📊 Confirmation (Dow Theory)

Use Confirming Asset – enable inter‑market confirmation.

Confirming Asset Symbol – ticker of the confirming instrument.

Confirming Swing Length – swing period for the confirming asset.

Confirming Asset Timeframe – timeframe (empty = current).

Volume Confirms Trend – enable directional volume check.

Volume Lookback Period – averaging period for volume.

Strict Dow CHoCH (require confirmations) – when on, a CHoCH appears only if the index trend matches and volume supports the new direction (when those confirmations are active).

Signal Interpretation
Trend Identification:

Check the info panel («Trend: ▲ Bullish Uptrend» or «▼ Bearish Downtrend»).

Visually: rising price makes HH and HL; falling price makes LH and LL.

Levels:

Use horizontal lines as potential support/resistance zones.

When a level is broken, it disappears – price “confirms” beyond it.

BOS:

BOS ▲ – price makes a new high in an uptrend, signaling strength.

BOS ▼ – new low in a downtrend, continuation of weakness.

CHoCH:

CHoCH ▲ – price exceeds the previous high after a series of lower highs (LH). Possible upward reversal.

CHoCH ▼ – price breaks the previous low after a series of higher lows (HL). Possible downward reversal.

When Strict Dow CHoCH is active, the signal will only appear if the index trend already aligns and volume supports the new direction.

Index Confirmation:

The panel shows «✓ Confirmed» – trends align; «✗ Divergence» – discrepancy (caution); «Waiting…» – not enough data.

Volume Confirmation:

«✓ Volume confirms» – directional volume agrees with the trend.

«✗ Volume weak» – volume does not support the move (potential weakness).

Usage Recommendations
Start with default settings. For long‑term analysis, increase Swing Length to 20–50.

For strict Dow Theory compliance, activate both confirmations and enable «Strict Dow CHoCH».

Choose a confirming asset correlated with the main chart (e.g., SPX for stocks, TOTAL for crypto).

Note: with strict filtering, CHoCH signals will be rare but more reliable.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © roadking1984

//@version=6
indicator("Dow Theory Market Structure [Levels]", shorttitle="Dow Levels", overlay=true, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════
//  INPUT GROUPS
// ══════════════════════════════════════════════════════════════
grp_main      = "⚙️ Main Parameters"
grp_levels    = "📐 Levels (Horizontal Lines)"
grp_zigzag    = "〰️ ZigZag"
grp_labels    = "🏷️ HH / HL / LH / LL Labels"
grp_bos       = "🔔 BOS / CHoCH"
grp_confirm   = "📊 Confirmation (Dow Theory)"
grp_info      = "ℹ️ Info Panel"

// ── Main ──────────────────────────────────────────────────────
swing_len = input.int(10, "Swing Length (bars)", group=grp_main, minval=2, maxval=50,
     tooltip="Number of bars to the left and right to confirm an extreme.\nHigher = global structure, lower = micro-structure.")

// ── Levels ────────────────────────────────────────────────────
show_levels     = input.bool(true,  "Show Horizontal Levels", group=grp_levels)
levels_extend   = input.bool(true,  "Extend Levels to the Right (until broken)", group=grp_levels)
levels_delete   = input.bool(true,  "Remove Level When Price Breaks It", group=grp_levels)
confirm_break   = input.bool(true,  "Confirm Break with Candle Close", group=grp_levels,
     tooltip="When enabled, a level is removed only when the candle closes beyond it.\nWhen disabled, a wick touch is enough.")
level_width     = input.int(1, "Level Thickness", group=grp_levels, minval=1, maxval=4)
col_hh_lvl      = input.color(color.new(color.teal,  20), "HH Level Color", group=grp_levels)
col_hl_lvl      = input.color(color.new(color.teal,  50), "HL Level Color", group=grp_levels)
col_lh_lvl      = input.color(color.new(color.red,   50), "LH Level Color", group=grp_levels)
col_ll_lvl      = input.color(color.new(color.red,   20), "LL Level Color", group=grp_levels)
style_hh_lvl    = input.string("Solid",  "HH/LL Line Style", options=["Solid","Dashed","Dotted"], group=grp_levels)
style_hl_lvl    = input.string("Dashed", "HL/LH Line Style", options=["Solid","Dashed","Dotted"], group=grp_levels)
max_levels      = input.int(30, "Max Active Levels (per type)", group=grp_levels, minval=5, maxval=100,
     tooltip="Limits the number of simultaneously displayed levels for each type (HH, HL, LH, LL).")

// ── ZigZag ────────────────────────────────────────────────────
show_zigzag    = input.bool(true, "Show ZigZag", group=grp_zigzag)
col_zz_up      = input.color(color.new(color.teal, 0), "ZigZag Color (Up)", group=grp_zigzag)
col_zz_dn      = input.color(color.new(color.red,  0), "ZigZag Color (Down)", group=grp_zigzag)
zz_width       = input.int(2, "ZigZag Thickness", group=grp_zigzag, minval=1, maxval=5)

// ── Labels ─────────────────────────────────────────────────────
show_labels    = input.bool(true, "Show HH/HL/LH/LL Labels", group=grp_labels)
lbl_size       = input.string(size.small, "Label Size",
     options=[size.tiny, size.small, size.normal, size.large], group=grp_labels)
col_hh_lbl     = input.color(color.new(color.teal, 0), "HH Label Color", group=grp_labels)
col_hl_lbl     = input.color(color.new(color.teal, 0), "HL Label Color", group=grp_labels)
col_lh_lbl     = input.color(color.new(color.red,  0), "LH Label Color", group=grp_labels)
col_ll_lbl     = input.color(color.new(color.red,  0), "LL Label Color", group=grp_labels)
lbl_text_col   = input.color(color.white, "Label Text Color", group=grp_labels)

// ── BOS / CHoCH ───────────────────────────────────────────────
show_bos       = input.bool(true, "Show BOS / CHoCH", group=grp_bos)
col_bos        = input.color(color.new(color.black , 0),  "BOS Color",   group=grp_bos)
col_choch      = input.color(color.new(color.blue, 0),  "CHoCH Color", group=grp_bos)
bos_lbl_size   = input.string(size.tiny, "BOS/CHoCH Label Size",
     options=[size.tiny, size.small, size.normal], group=grp_bos)

// ── Confirmation (Dow Theory) ────────────────────────────────
use_confirm_symbol  = input.bool(false, "Use Confirming Asset", group=grp_confirm,
     tooltip="Enable to check trend alignment with a related asset (e.g., an index or transportation sector).")

confirm_symbol      = input.symbol("CAPITALCOM:SPX500", "Confirming Asset Symbol", group=grp_confirm,
     tooltip="Enter the ticker (e.g., AAPL, SPX, BTCUSDT).")
confirm_swing_len   = input.int(10, "Confirming Swing Length", group=grp_confirm, minval=2, maxval=50)
confirm_tf          = input.timeframe("", "Confirming Asset Timeframe", group=grp_confirm,
     tooltip="Leave empty to use the current timeframe.")

use_volume_confirm  = input.bool(false, "Volume Confirms Trend", group=grp_confirm,
     tooltip="Directional volume check: in an uptrend, up-bar volume must exceed down-bar volume; in a downtrend, down-bar volume must be higher.")
vol_lookback        = input.int(20, "Volume Lookback Period", group=grp_confirm, minval=5,
     tooltip="Number of bars for averaging up-volume and down-volume.")

strict_choch        = input.bool(false, "Strict Dow CHoCH (require confirmations)", group=grp_confirm,
     tooltip="CHoCH signals appear only when the confirming asset trend agrees AND volume confirms (if those confirmations are active).")

// ── Info Panel ───────────────────────────────────────────────
show_table     = input.bool(true, "Show Info Panel", group=grp_info)

// ══════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════

// Convert style string to line.style_* constant
f_line_style(s) =>
    if s == "Dashed"
        line.style_dashed
    else if s == "Dotted"
        line.style_dotted
    else
        line.style_solid

// Add a line to an array and remove the oldest if the limit is exceeded
f_add_line(arr, ln) =>
    array.push(arr, ln)
    if array.size(arr) > max_levels
        old = array.shift(arr)
        if not na(old)
            line.delete(old)

// Remove broken levels from an array
// zone_type: 1 = resistance level (High), -1 = support level (Low)
f_remove_broken(arr, zone_type) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            ln = array.get(arr, i)
            if not na(ln)
                lvl = line.get_y1(ln)
                broken = false
                if zone_type == 1
                    if confirm_break
                        broken := close > lvl
                    else
                        broken := high > lvl
                else
                    if confirm_break
                        broken := close < lvl
                    else
                        broken := low < lvl
                if broken
                    line.delete(ln)
                    array.remove(arr, i)

// Determine trend direction from swing points (reusable function)
f_get_trend_dir(ph_series, pl_series, ph_bar_series, pl_bar_series, len) =>
    var float last_ph_val  = na
    var float last_pl_val  = na
    var int   last_sw_type = na
    var int   dir          = na

    float ph = ta.pivothigh(ph_series, len, len)
    float pl = ta.pivotlow(pl_series, len, len)

    if not na(ph)
        if not na(last_ph_val) and ph > last_ph_val
            if dir == -1
                dir := 1   // CHoCH
            else
                dir := 1   // continuation or first detection
        else if na(dir)
            dir := 1
        last_ph_val := ph
        last_sw_type := 1

    if not na(pl)
        if not na(last_pl_val) and pl < last_pl_val
            if dir == 1
                dir := -1
            else
                dir := -1
        else if na(dir)
            dir := -1
        last_pl_val := pl
        last_sw_type := -1

    dir

// ══════════════════════════════════════════════════════════════
//  STATE VARIABLES
// ══════════════════════════════════════════════════════════════
var int   last_ph_bar  = na
var float last_ph_val  = na
var int   last_pl_bar  = na
var float last_pl_val  = na
var int   last_sw_type = na   // 1 = last was High, -1 = last was Low
var int   trend_dir    = na   // 1 = Uptrend, -1 = Downtrend, na = undefined

// Arrays of active horizontal levels
var array<line> hh_lines = array.new<line>()
var array<line> hl_lines = array.new<line>()
var array<line> lh_lines = array.new<line>()
var array<line> ll_lines = array.new<line>()

// ══════════════════════════════════════════════════════════════
//  DIRECTIONAL VOLUME CALCULATION (if volume confirmation active)
// ══════════════════════════════════════════════════════════════
float up_vol   = close > open ? volume : 0.0
float down_vol = close < open ? volume : 0.0
float avg_up   = ta.sma(up_vol, vol_lookback)
float avg_down = ta.sma(down_vol, vol_lookback)


// ══════════════════════════════════════════════════════════════
//  INDEX CONFIRMATION (Inter-market)
// ══════════════════════════════════════════════════════════════
float confirm_high = request.security(confirm_symbol, confirm_tf, high, ignore_invalid_symbol=true)
float confirm_low  = request.security(confirm_symbol, confirm_tf, low, ignore_invalid_symbol=true)

var int   confirm_trend_dir = na
string confirm_status = "Not active"

if use_confirm_symbol and confirm_symbol != ""
    confirm_trend_dir := f_get_trend_dir(confirm_high, confirm_low, bar_index, bar_index, confirm_swing_len)
    
    if na(trend_dir) or na(confirm_trend_dir)
        confirm_status := "Waiting..."
    else if trend_dir == confirm_trend_dir
        confirm_status := "✓ Confirmed"
    else
        confirm_status := "✗ Divergence"
else
    confirm_trend_dir := na
    confirm_status := "Off"

// ══════════════════════════════════════════════════════════════
//  SWING DETECTION
// ══════════════════════════════════════════════════════════════
float ph = ta.pivothigh(high, swing_len, swing_len)
float pl = ta.pivotlow(low,  swing_len, swing_len)

int   ph_bar = bar_index[swing_len]
int   pl_bar = bar_index[swing_len]

// ── Swing High Handling ───────────────────────────────────────
if not na(ph)
    // Classification
    bool is_hh = na(last_ph_val) or ph > last_ph_val
    string lbl_txt  = is_hh ? "HH" : "LH"
    color  lbl_col  = is_hh ? col_hh_lbl : col_lh_lbl
    color  lvl_col  = is_hh ? col_hh_lvl : col_lh_lvl
    string lvl_style = is_hh ? style_hh_lvl : style_hl_lvl

    // ── Label ─────────────────────────────────────────────────
    if show_labels
        label.new(ph_bar, ph, lbl_txt,
             color=lbl_col, textcolor=lbl_text_col,
             style=label.style_label_down, size=lbl_size)

    // ── Horizontal Level ──────────────────────────────────────
    if show_levels
        ext = levels_extend ? extend.right : extend.none
        ln = line.new(ph_bar, ph, ph_bar + 1, ph,
             color=lvl_col, width=level_width,
             style=f_line_style(lvl_style), extend=ext)
        if is_hh
            f_add_line(hh_lines, ln)
        else
            f_add_line(lh_lines, ln)

    // ── ZigZag ────────────────────────────────────────────────
    if show_zigzag and not na(last_pl_val) and last_sw_type == -1
        zz_col = na(trend_dir) ? col_zz_up : (trend_dir == 1 ? col_zz_up : col_zz_dn)
        line.new(last_pl_bar, last_pl_val, ph_bar, ph,
             color=zz_col, width=zz_width)

    // ── BOS / CHoCH ───────────────────────────────────────────
    if not na(last_ph_val) and ph > last_ph_val
        bool is_choch = trend_dir == -1
        bool is_bos   = trend_dir == 1

        // Determine if confirmations allow the CHoCH signal
        bool choch_allowed = true
        if is_choch and strict_choch
            // Index confirmation check
            if use_confirm_symbol and confirm_symbol != ""
                // For bullish CHoCH, confirm asset trend must be 1
                choch_allowed := not na(confirm_trend_dir) and confirm_trend_dir == 1
            // Volume confirmation check
            if choch_allowed and use_volume_confirm
                // Bullish CHoCH requires avg_up > avg_down (volume supporting uptrend)
                choch_allowed := avg_up > avg_down

        if show_bos
            if is_choch and choch_allowed
                // CHoCH: bearish trend broken to the upside
                line.new(last_ph_bar, last_ph_val, ph_bar, last_ph_val,
                     color=col_choch, style=line.style_dashed, width=1)
                label.new(math.round((last_ph_bar + ph_bar) / 2), last_ph_val, "CHoCH ▲",
                     color=color.new(col_choch, 85), textcolor=col_choch,
                     style=label.style_label_up, size=bos_lbl_size)
                trend_dir := 1
            else if is_choch and not choch_allowed
                // Suppressed CHoCH – still update trend direction internally but no visual
                trend_dir := 1
            else if is_bos
                // BOS: bullish trend continues
                line.new(last_ph_bar, last_ph_val, ph_bar, last_ph_val,
                     color=col_bos, style=line.style_dashed, width=1)
                label.new(math.round((last_ph_bar + ph_bar) / 2), last_ph_val, "BOS ▲",
                     color=color.new(col_bos, 85), textcolor=col_bos,
                     style=label.style_label_up, size=bos_lbl_size)
                trend_dir := 1
            else
                trend_dir := 1
        else
            if is_choch or is_bos
                trend_dir := 1

    last_ph_val  := ph
    last_ph_bar  := ph_bar
    last_sw_type := 1

// ── Swing Low Handling ────────────────────────────────────────
if not na(pl)
    // Classification
    bool is_hl = na(last_pl_val) or pl >= last_pl_val
    string lbl_txt  = is_hl ? "HL" : "LL"
    color  lbl_col  = is_hl ? col_hl_lbl : col_ll_lbl
    color  lvl_col  = is_hl ? col_hl_lvl : col_ll_lvl
    string lvl_style = is_hl ? style_hl_lvl : style_hh_lvl

    // ── Label ─────────────────────────────────────────────────
    if show_labels
        label.new(pl_bar, pl, lbl_txt,
             color=lbl_col, textcolor=lbl_text_col,
             style=label.style_label_up, size=lbl_size)

    // ── Horizontal Level ──────────────────────────────────────
    if show_levels
        ext = levels_extend ? extend.right : extend.none
        ln = line.new(pl_bar, pl, pl_bar + 1, pl,
             color=lvl_col, width=level_width,
             style=f_line_style(lvl_style), extend=ext)
        if is_hl
            f_add_line(hl_lines, ln)
        else
            f_add_line(ll_lines, ln)

    // ── ZigZag ────────────────────────────────────────────────
    if show_zigzag and not na(last_ph_val) and last_sw_type == 1
        zz_col = na(trend_dir) ? col_zz_dn : (trend_dir == 1 ? col_zz_up : col_zz_dn)
        line.new(last_ph_bar, last_ph_val, pl_bar, pl,
             color=zz_col, width=zz_width)

    // ── BOS / CHoCH ───────────────────────────────────────────
    if not na(last_pl_val) and pl < last_pl_val
        bool is_choch = trend_dir == 1
        bool is_bos   = trend_dir == -1

        // Determine if confirmations allow the CHoCH signal
        bool choch_allowed = true
        if is_choch and strict_choch
            if use_confirm_symbol and confirm_symbol != ""
                // For bearish CHoCH, confirm asset trend must be -1
                choch_allowed := not na(confirm_trend_dir) and confirm_trend_dir == -1
            if choch_allowed and use_volume_confirm
                // Bearish CHoCH requires avg_down > avg_up (volume supporting downtrend)
                choch_allowed := avg_down > avg_up

        if show_bos
            if is_choch and choch_allowed
                // CHoCH: bullish trend broken to the downside
                line.new(last_pl_bar, last_pl_val, pl_bar, last_pl_val,
                     color=col_choch, style=line.style_dashed, width=1)
                label.new(math.round((last_pl_bar + pl_bar) / 2), last_pl_val, "CHoCH ▼",
                     color=color.new(col_choch, 85), textcolor=col_choch,
                     style=label.style_label_down, size=bos_lbl_size)
                trend_dir := -1
            else if is_choch and not choch_allowed
                trend_dir := -1
            else if is_bos
                // BOS: bearish trend continues
                line.new(last_pl_bar, last_pl_val, pl_bar, last_pl_val,
                     color=col_bos, style=line.style_dashed, width=1)
                label.new(math.round((last_pl_bar + pl_bar) / 2), last_pl_val, "BOS ▼",
                     color=color.new(col_bos, 85), textcolor=col_bos,
                     style=label.style_label_down, size=bos_lbl_size)
                trend_dir := -1
            else
                trend_dir := -1
        else
            if is_choch or is_bos
                trend_dir := -1

    last_pl_val  := pl
    last_pl_bar  := pl_bar
    last_sw_type := -1

// ══════════════════════════════════════════════════════════════
//  REMOVE BROKEN LEVELS (every bar)
// ══════════════════════════════════════════════════════════════
if show_levels and levels_delete
    f_remove_broken(hh_lines,  1)
    f_remove_broken(lh_lines,  1)
    f_remove_broken(hl_lines, -1)
    f_remove_broken(ll_lines, -1)



// ══════════════════════════════════════════════════════════════
//  VOLUME CONFIRMATION (Directional)
// ══════════════════════════════════════════════════════════════
string volume_status = "Not active"

if use_volume_confirm
    if na(trend_dir)
        volume_status := "No trend"
    else if trend_dir == 1
        // Uptrend: up-volume must exceed down-volume
        if avg_up > avg_down
            volume_status := "✓ Volume confirms"
        else
            volume_status := "✗ Volume weak"
    else if trend_dir == -1
        // Downtrend: down-volume must exceed up-volume
        if avg_down > avg_up
            volume_status := "✓ Volume confirms"
        else
            volume_status := "✗ Volume weak"
else
    volume_status := "Off"

// ══════════════════════════════════════════════════════════════
//  INFO PANEL
// ══════════════════════════════════════════════════════════════
if barstate.islast and show_table
    var table tbl = table.new(position.bottom_right, 2, 8,
         bgcolor=color.new(color.black, 75),
         border_width=1, border_color=color.new(color.gray, 50))

    // Title
    table.cell(tbl, 0, 0, "Dow Theory Structure", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 60))

    // Trend
    trend_txt = "Neutral / Undefined"
    trend_col = color.gray
    if trend_dir == 1
        trend_txt := "▲  Bullish Uptrend"
        trend_col := color.teal
    else if trend_dir == -1
        trend_txt := "▼  Bearish Downtrend"
        trend_col := color.red
    table.cell(tbl, 0, 1, "Trend:", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 1, trend_txt, text_color=trend_col, text_size=size.small)

    // Active levels
    table.cell(tbl, 0, 2, "HH levels:", text_color=col_hh_lvl, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(array.size(hh_lines)), text_color=col_hh_lvl, text_size=size.small)

    table.cell(tbl, 0, 3, "HL levels:", text_color=col_hl_lvl, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(array.size(hl_lines)), text_color=col_hl_lvl, text_size=size.small)

    table.cell(tbl, 0, 4, "LH / LL:", text_color=col_lh_lvl, text_size=size.small)
    table.cell(tbl, 1, 4,
         str.tostring(array.size(lh_lines)) + " / " + str.tostring(array.size(ll_lines)),
         text_color=col_ll_lvl, text_size=size.small)

    // Index confirmation
    color confirm_col = color.gray
    if confirm_status == "✓ Confirmed"
        confirm_col := color.teal
    else if confirm_status == "✗ Divergence"
        confirm_col := color.red
    else if confirm_status == "Waiting..."
        confirm_col := color.orange
    table.cell(tbl, 0, 5, "Index Confirm:", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 5, confirm_status, text_color=confirm_col, text_size=size.small)

    // Volume confirmation
    color vol_col = color.gray
    if str.contains(volume_status, "confirms")
        vol_col := color.teal
    else if str.contains(volume_status, "weak")
        vol_col := color.red
    else if volume_status == "No trend"
        vol_col := color.orange
    table.cell(tbl, 0, 6, "Volume Confirm:", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 6, volume_status, text_color=vol_col, text_size=size.small)
````
