# TJR Swing High/Low + BOS

- url: https://www.tradingview.com/script/tl0c4fN9-TJR-Swing-High-Low-BOS/
- type: indicator
- pine_id: PUB;5428ea94b82a424290c7c89958722c75
- version: 4.0

## Description

TJR Swing High/Low + BOS
Version 1.0.0

Marks swing highs, swing lows and Breaks of Structure using TJR's 2-candle method, so you can see how market structure is forming and where the trend shifts.

WHAT IT DRAWS
• Swing highs and lows: read from the stream of real candles. A colour flip from bull to bear marks a swing high at the higher of the two paired candle highs; a colour flip from bear to bull marks a swing low at the lower of the two paired candle lows. Each line sits on whichever paired candle holds the extreme, one candle wide.
• Historical swings: the current swing plus up to two previous swings per type are kept, so up to three swing high lines and three swing low lines can show at once. Older lines hold their price and restyle to a shared historical look. Two depth dropdowns, one for highs and one for lows, choose how many are shown: current only, current plus one, or current plus two.
• Break of Structure: one horizontal line at the broken swing's price, from that swing's origin to one bar past the break. Only the most recent break is shown. It is drawn solid on the break, then once the break candle plus one further candle have closed it restyles to the chosen historical style, which defaults to dotted.

HOW IT WORKS
• Doji handling: a doji, defined as a candle whose close equals its open, is ignored entirely and the real candles on either side of it are compared directly.
• Break of Structure logic: a trend state machine is driven by the current swing high and low. From a cold start a close beyond either current swing sets the trend. Once a trend is set, only the opposite swing is watched, so in a bullish trend a close below the current swing low is a bearish break, and in a bearish trend a close above the current swing high is a bullish break.
• Repaint-safe: the indicator acts only on confirmed, closed bars, so lines do not flicker or repaint on the live forming bar. It uses no external data requests, no alerts and no tables.

WHAT IT RUNS ON
Standard Japanese candlestick charts only. Heikin Ashi, Renko, Kagi, Point and Figure and Range charts are refused, because on those chart types the candle open, high, low and close are synthetic and the structure they imply would be misleading. On any of those the indicator stops with a message and draws nothing.

INPUTS
• Swing High: history depth, colour, opacity, line style and thickness.
• Swing Low: history depth, colour, opacity, line style and thickness.
• Historical Swings: colour, opacity, line style and thickness, shared by all aged tiers.
• Break of Structure: thickness and the historical style applied once the break has aged.

HOW TO USE
Add it to any standard candlestick chart. Use the swing highs and lows to see where structure is forming, and the Break of Structure line to see when a swing has been broken and the trend has shifted.

FEEDBACK
Please let me know if you experience any issues, or have feedback for improvements or additions in the comments below. Thank you, Tom

## Source Code

````pine
//@version=6
// =============================================================================
// TJR SWING HIGH/LOW + BOS
// =============================================================================
// Author:       Tom Brown
// Version:      1.3.1-dev
// Description:  Marks swing highs and swing lows using TJR's 2-candle method, plus Break of
//               Structure.
//
//               A colour flip from bull to bear (on the stream of real candles) is a swing
//               high; bear to bull is a swing low. Doji candles are ignored entirely and the
//               real candles either side are paired.
//
//               Only the current swing high and swing low are drawn; each new swing of a type
//               replaces the previous tab.
// Date:         2026-08-24
// =============================================================================

indicator('TJR Swing High/Low + BOS', overlay = true, max_lines_count = 500)

// --- non-standard chart guard -------------------------------------------------
// Swings and BOS read raw candle OHLC; on Heikin Ashi / Renko / Kagi / P&F / Range
// the OHLC is synthetic and the structure would be misleading. Refuse those charts.
if chart.is_heikinashi or chart.is_renko or chart.is_kagi or chart.is_pnf or chart.is_range
    runtime.error("This indicator only works on standard Japanese candlestick charts.")

// --- input group headers (define-once; two-tier: heavy parents, light children) --
grp_swings = "════════ MOST RECENT SWING HIGH & LOW ════════"
grp_sh     = "━━━ Swing High ━━━"
grp_sl     = "━━━ Swing Low ━━━"
grp_bos_p  = "════════ BREAK OF STRUCTURE ════════"
grp_bos    = "━━━ Most Recent BOS ━━━"
grp_bos1   = "━━━ BOS -1 Ago ━━━"
grp_ext_p  = "════════ SWING HIGH/LOW EXTENSION + TRIGGER LINE ════════"
grp_ext    = "━━━ Swing High/Low Extension + Trigger Line ━━━"
grp_pbos   = "━━━ Potential BOS Line ━━━"

// --- inputs: swings (parent banner anchored by the master Show Swings toggle) ----
// show_swings anchors the MOST RECENT SWING HIGH & LOW banner AND gates the tab draw.
show_swings = input.bool(true, "Show Swings", group = grp_swings, tooltip = "Shows or hides the swing high and\nswing low tabs.\n\nHiding is display only:\n\n- swing detection keeps running\n- the Break of Structure engine still\n  reads the levels")
sh_col   = input.color(color.red, "Colour", group = grp_sh, tooltip = "Colour of the swing high line.")
sh_op    = input.int(100, "Opacity (100 = fully visible)", minval = 0, maxval = 100, group = grp_sh, tooltip = "Opacity of the swing high line.\n\n- 100 = fully visible\n- 0 = invisible")
sh_style = input.string("Solid", "Line style", options = ["Solid", "Dotted", "Dashed"], group = grp_sh, tooltip = "Line style for the swing high line.\n\n- Solid\n- Dotted\n- Dashed")
sh_width = input.int(2, "Thickness", minval = 1, group = grp_sh, tooltip = "Thickness of the swing high line,\nin pixels.")
sl_col   = input.color(color.red, "Colour", group = grp_sl, tooltip = "Colour of the swing low line.")
sl_op    = input.int(100, "Opacity (100 = fully visible)", minval = 0, maxval = 100, group = grp_sl, tooltip = "Opacity of the swing low line.\n\n- 100 = fully visible\n- 0 = invisible")
sl_style = input.string("Solid", "Line style", options = ["Solid", "Dotted", "Dashed"], group = grp_sl, tooltip = "Line style for the swing low line.\n\n- Solid\n- Dotted\n- Dashed")
sl_width = input.int(2, "Thickness", minval = 1, group = grp_sl, tooltip = "Thickness of the swing low line,\nin pixels.")

// --- inputs: break of structure (parent banner anchored by the master Show BOS toggle) --
// show_bos anchors the BREAK OF STRUCTURE banner AND gates both BOS line draws.
show_bos = input.bool(true, "Show BOS", group = grp_bos_p, tooltip = "Shows or hides the Break of Structure\nlines.\n\nHiding is display only:\n\n- trend detection keeps running\n- the levels stay tracked\n\nTwo BOS lines are kept:\n\n1. Most Recent BOS\n2. BOS -1 Ago, which the most recent\n   line demotes to when a new break\n   forms")
// Most recent BOS: its own full styling, drawn solid and never aged. Each BOS line
// carries its own "Extend past BOS candle" value.
bos_col        = input.color(color.red, "Colour", group = grp_bos, tooltip = "Colour of the Most Recent BOS line.")
bos_op         = input.int(100, "Opacity (100 = fully visible)", minval = 0, maxval = 100, group = grp_bos, tooltip = "Opacity of the Most Recent BOS line.\n\n- 100 = fully visible\n- 0 = invisible")
bos_style      = input.string("Solid", "Line style", options = ["Solid", "Dotted", "Dashed"], group = grp_bos, tooltip = "Line style for the Most Recent BOS\nline.\n\n- Solid\n- Dotted\n- Dashed")
bos_width      = input.int(1, "Thickness", minval = 1, group = grp_bos, tooltip = "Thickness of the Most Recent BOS line,\nin pixels.")
bos_extend_str = input.string("2", "Extend past BOS candle (bars)", options = ["1", "2", "3"], group = grp_bos, tooltip = "How many candles the Most Recent BOS\nline runs to the right past the break\ncandle.\n\n- 1\n- 2\n- 3")
bos_extend     = bos_extend_str == "1" ? 1 : bos_extend_str == "3" ? 3 : 2
// BOS -1 (the one break before the latest): its own fully-independent styling and
// its own extend value. Type-agnostic: it holds whatever the prior BOS broke.
bos1_col        = input.color(color.gray, "Colour", group = grp_bos1, tooltip = "Colour of the BOS -1 Ago line.")
bos1_op         = input.int(50, "Opacity (100 = fully visible)", minval = 0, maxval = 100, group = grp_bos1, tooltip = "Opacity of the BOS -1 Ago line.\n\n- 100 = fully visible\n- 0 = invisible")
bos1_style      = input.string("Solid", "Line style", options = ["Solid", "Dotted", "Dashed"], group = grp_bos1, tooltip = "Line style for the BOS -1 Ago line.\n\n- Solid\n- Dotted\n- Dashed")
bos1_width      = input.int(1, "Thickness", minval = 1, group = grp_bos1, tooltip = "Thickness of the BOS -1 Ago line,\nin pixels.")
bos1_extend_str = input.string("2", "Extend past BOS candle (bars)", options = ["1", "2", "3"], group = grp_bos1, tooltip = "How many candles the BOS -1 Ago line\nruns to the right past the break\ncandle.\n\n- 1\n- 2\n- 3")
bos1_extend     = bos1_extend_str == "1" ? 1 : bos1_extend_str == "3" ? 3 : 2

// --- inputs: swing high/low extension + trigger line (parent banner anchored by its own master toggle) --
// show_ext anchors the SWING HIGH/LOW EXTENSION + TRIGGER LINE banner AND gates the line draw.
show_ext = input.bool(true, "Show Extension + Trigger Line", group = grp_ext_p, tooltip = "Shows or hides a live line that runs\nfrom the currently-watched swing level\nout to the current candle.\n\nThe extension line is always drawn in\nits own resting style, set below.\n\nWhile the current (still-forming)\ncandle's price is beyond the level, a\nseparate Potential BOS line is drawn\nover it, in its own colour, opacity,\nstyle and thickness. That happens\nbefore the candle has closed and\nconfirmed a Break of Structure.")
ext_col   = input.color(color.orange, "Colour", group = grp_ext, tooltip = "Colour of the extension/trigger line.")
ext_op    = input.int(100, "Opacity (100 = fully visible)", minval = 0, maxval = 100, group = grp_ext, tooltip = "Opacity of the extension/trigger line.\n\n- 100 = fully visible\n- 0 = invisible")
ext_style = input.string("Dotted", "Line style", options = ["Solid", "Dotted", "Dashed"], group = grp_ext, tooltip = "Resting line style for the\nextension/trigger line.\n\nThe extension line is always drawn in\nthis style. When price goes beyond the\nlevel, the separate Potential BOS line\nis drawn over it in its own style.\n\n- Solid\n- Dotted\n- Dashed")
ext_width = input.int(1, "Thickness", minval = 1, group = grp_ext, tooltip = "Thickness of the extension/trigger\nline, in pixels.")
ext_extend_str = input.string("2", "Extend past current candle (bars)", options = ["1", "2", "3"], group = grp_ext, tooltip = "How many candles the extension/trigger\nline runs to the right past the current\ncandle.\n\n- 1\n- 2\n- 3")
ext_extend     = ext_extend_str == "1" ? 1 : ext_extend_str == "3" ? 3 : 2
ext_lbl_col    = input.color(color.orange, "Countdown Text Colour", group = grp_ext, tooltip = "Colour of the time-to-close countdown\ntext at the right-hand end of the\nextension/trigger line.\n\nHigher units are dropped while they are\nzero:\n\n- 47s\n- 04m 47s\n- 19h 54m 00s\n\nThe countdown shows whenever that swing\nlevel is being watched, whether or not\nthe Potential BOS line is currently\ndrawn over the extension line.\n\nDrawn on 1h charts and below only.")
// Potential BOS Line: a separate line, own full styling, drawn ONLY while the live
// (still-forming) candle's price is beyond the watched level — before it has closed
// and actually confirmed a Break of Structure. Shares the extension line's own
// origin/position and the same "Extend past current candle (bars)" reach (ext_extend).
pbos_col   = input.color(color.orange, "Colour", group = grp_pbos, tooltip = "Colour of the Potential BOS line.")
pbos_op    = input.int(100, "Opacity (100 = fully visible)", minval = 0, maxval = 100, group = grp_pbos, tooltip = "Opacity of the Potential BOS line.\n\n- 100 = fully visible\n- 0 = invisible")
pbos_style = input.string("Solid", "Line style", options = ["Solid", "Dotted", "Dashed"], group = grp_pbos, tooltip = "Line style for the Potential BOS line.\n\n- Solid\n- Dotted\n- Dashed")
pbos_width = input.int(2, "Thickness", minval = 1, group = grp_pbos, tooltip = "Thickness of the Potential BOS line,\nin pixels.")

// --- helpers ------------------------------------------------------------------
// House opacity convention: true-opacity where 100 = fully visible.
// color.new wants transparency (100 = invisible), so we invert.
with_opacity(color col, int opacity) =>
    color.new(col, 100 - opacity)

// Map the style dropdown to a Pine line-style constant.
style_of(string name) =>
    name == "Solid" ? line.style_solid : name == "Dashed" ? line.style_dashed : line.style_dotted

// Re-style an existing tier line in place (position is left untouched — an aged
// line keeps the bar/price it was drawn at). na-guarded for early history where
// a tier may not exist yet.
restyle(line ln, color col, string stl, int wid) =>
    if not na(ln)
        line.set_color(ln, col)
        line.set_style(ln, style_of(stl))
        line.set_width(ln, wid)

// Live tracking line for one watched swing level: delete-and-recreate every call so
// it always reflects the current bar's price and position. `active` gates whether
// this instance draws at all this bar (na when not). Reused for both the resting
// extension/trigger line and the Potential BOS line — the caller passes the styling
// and the activation condition each represents.
f_track_line(bool active, int origin_bar, float lvl, int extend, color col, int op, string stl, int wid, line existing) =>
    line result = existing
    if not na(result)
        line.delete(result)
        result := na
    if active
        result := line.new(x1 = origin_bar, y1 = lvl, x2 = bar_index + extend, y2 = lvl, color = with_opacity(col, op), style = style_of(stl), width = wid)
    result

// Time left until target_ts as unit-lettered text, dropping the higher units while
// they are zero: "47s", "04m 47s", "19h 54m 00s". Every unit shown is padded to two
// digits. math.max(0, ...) clamps so an already-passed target reads "00s" rather
// than counting negative, and the total
// is int()-ed once so h/m/s all round off the same number.
// Realtime-only: timenow is frozen on historical bars, so callers gate on barstate.islast.
f_countdown_hms(int target_ts = time_close) =>
    int total = int(math.max(0, (target_ts - timenow) / 1000.0))
    int h = math.floor(total / 3600)
    int m = math.floor((total % 3600) / 60)
    int s = total % 60
    h > 0 ? str.tostring(h, "00") + "h " + str.tostring(m, "00") + "m " + str.tostring(s, "00") + "s" : m > 0 ? str.tostring(m, "00") + "m " + str.tostring(s, "00") + "s" : str.tostring(s, "00") + "s"

// --- state: the "previous real candle" and the single swing line handles ------
// We track only the immediately preceding NON-DOJI candle. Doji bars leave this
// state untouched, which is exactly what "drop dojis from the sequence" means.
var bool  has_prev     = false   // have we seen a real (non-doji) candle yet?
var bool  prev_is_bull = false   // direction of the last real candle (true = bull)
var float prev_high    = na      // that candle's high
var float prev_low     = na      // that candle's low
var int   prev_bar_idx = na      // its bar_index, for line placement

// One handle per swing type. When a new swing forms the old handle is deleted and
// a fresh one-candle-wide tab is drawn; there is no swing history.
var line sh_cur = na
var line sl_cur = na

// --- state: Break of Structure (trend machine + current tier-0 swing levels) ---
// The BOS engine is driven entirely by the CURRENT (tier-0) swing high/low. We
// persist those two levels (price + origin bar) as vars so the check can read
// them on every bar; they trail to the latest swing as new swings are detected.
var int   trend        = 0    // 0 = cold start (no trend), 1 = bullish, -1 = bearish
var float cur_sh_price = na   // current swing HIGH price ...
var int   cur_sh_bar   = na   // ... and its origin bar (the ext_idx it was drawn at)
var float cur_sl_price = na   // current swing LOW price ...
var int   cur_sl_bar   = na   // ... and its origin bar (the ext_idx it was drawn at)
var line  bos_line     = na   // most recent BOS line (drawn once, own full styling)
var line  bos_prev     = na   // the ONE BOS before the latest (type-agnostic, own styling)
var int   bos_bar      = na   // bar_index the current BOS line was drawn on
var int   bos_prev_bar = na   // bar_index the demoted BOS line was drawn on (for its extend)
var line  ext_sh_line  = na   // live extension/trigger line while the swing HIGH side is watched
var line  ext_sl_line  = na   // live extension/trigger line while the swing LOW side is watched
var line  pbos_sh_line = na   // Potential BOS line while the swing HIGH side is live-triggered
var line  pbos_sl_line = na   // Potential BOS line while the swing LOW side is live-triggered
var label cd_sh_lbl    = na   // time-to-close countdown at the tip of the swing HIGH extension line
var label cd_sl_lbl    = na   // time-to-close countdown at the tip of the swing LOW extension line

// --- candle classification (current bar) --------------------------------------
is_doji = close == open
is_bull = close > open           // dojis are neither bull nor bear

// Repaint gate: only act on CONFIRMED (closed) bars. The colour flip is only
// known once the flip candle has closed, so gating on barstate.isconfirmed stops
// the live forming bar from prematurely printing or flickering a swing.
// NOT A BUG — do not re-flag. The doji gate covers the BOS state machine as well
// as the swing sequence, DELIBERATELY: a doji is transparent to this tool, so it
// neither pairs into the sequence nor confirms a break. Ruled intended behaviour
// by Tom, 2026-08-24, when a publish audit raised it as unintended coupling.
if barstate.isconfirmed and not is_doji
    // --- BREAK OF STRUCTURE (trend state machine) -----------------------------
    // Evaluated BEFORE the swing-detection block below, so the cur_sh_*/cur_sl_*
    // levels read here are the current swings as they stood on PRIOR bars — a
    // candle can never break a swing it forms on this very same bar.
    bull_bos = false
    bear_bos = false
    if trend == 0
        // Cold start: no trend yet. Bullish checked FIRST — the tiebreak for the
        // vanishingly rare bar that closes beyond BOTH the current high and low.
        if not na(cur_sh_price) and close > cur_sh_price
            bull_bos := true
        else if not na(cur_sl_price) and close < cur_sl_price
            bear_bos := true
    else if trend == 1
        // Bullish trend: watch ONLY the swing low. A close below it flips bearish.
        if not na(cur_sl_price) and close < cur_sl_price
            bear_bos := true
    else if trend == -1
        // Bearish trend: watch ONLY the swing high. A close above it flips bullish.
        if not na(cur_sh_price) and close > cur_sh_price
            bull_bos := true
    // The trend state machine (above) always runs; only the DRAWING is gated on show_bos.
    if bull_bos
        // Bullish BOS breaks the swing HIGH, drawn in the Most Recent BOS styling.
        trend := 1
        if show_bos
            // Demote: drop the oldest, slide the current latest down to bos_prev, draw
            // the new break, then restyle the demoted line to the BOS -1 group and
            // recompute its extend (position x1/y1/y2 untouched).
            if not na(bos_prev)
                line.delete(bos_prev)
            bos_prev     := bos_line
            bos_prev_bar := bos_bar
            bos_line := line.new(x1 = cur_sh_bar, y1 = cur_sh_price, x2 = bar_index + bos_extend, y2 = cur_sh_price, color = with_opacity(bos_col, bos_op), style = style_of(bos_style), width = bos_width)
            bos_bar  := bar_index
            restyle(bos_prev, with_opacity(bos1_col, bos1_op), bos1_style, bos1_width)
            if not na(bos_prev)
                line.set_x2(bos_prev, bos_prev_bar + bos1_extend)
    else if bear_bos
        // Bearish BOS breaks the swing LOW, drawn in the Most Recent BOS styling.
        trend := -1
        if show_bos
            // Demote: drop the oldest, slide the current latest down to bos_prev, draw
            // the new break, then restyle the demoted line to the BOS -1 group and
            // recompute its extend (position x1/y1/y2 untouched).
            if not na(bos_prev)
                line.delete(bos_prev)
            bos_prev     := bos_line
            bos_prev_bar := bos_bar
            bos_line := line.new(x1 = cur_sl_bar, y1 = cur_sl_price, x2 = bar_index + bos_extend, y2 = cur_sl_price, color = with_opacity(bos_col, bos_op), style = style_of(bos_style), width = bos_width)
            bos_bar  := bar_index
            restyle(bos_prev, with_opacity(bos1_col, bos1_op), bos1_style, bos1_width)
            if not na(bos_prev)
                line.set_x2(bos_prev, bos_prev_bar + bos1_extend)
    // Compare this real candle to the previous real candle (dojis already skipped).
    if has_prev
        if prev_is_bull and not is_bull
            // BULL -> BEAR colour flip => SWING HIGH at the max of the two highs.
            level = math.max(prev_high, high)
            // Line drawn FROM whichever paired candle holds the higher high,
            // one candle wide (origin bar -> origin bar + 1).
            ext_idx = prev_high >= high ? prev_bar_idx : bar_index
            // Trail the current swing HIGH for the BOS engine. Assigned ALWAYS,
            // outside the show gate, so the engine always has a level to read.
            cur_sh_price := level
            cur_sh_bar   := ext_idx
            // Draw the tab (gated): delete the old handle, draw a fresh one.
            if show_swings
                if not na(sh_cur)
                    line.delete(sh_cur)
                sh_cur := line.new(x1 = ext_idx, y1 = level, x2 = ext_idx + 1, y2 = level, color = with_opacity(sh_col, sh_op), style = style_of(sh_style), width = sh_width)
        else if not prev_is_bull and is_bull
            // BEAR -> BULL colour flip => SWING LOW at the min of the two lows.
            level = math.min(prev_low, low)
            // Line drawn FROM whichever paired candle holds the lower low,
            // one candle wide (origin bar -> origin bar + 1).
            ext_idx = prev_low <= low ? prev_bar_idx : bar_index
            // Trail the current swing LOW for the BOS engine. Assigned ALWAYS,
            // outside the show gate, so the engine always has a level to read.
            cur_sl_price := level
            cur_sl_bar   := ext_idx
            // Draw the tab (gated): delete the old handle, draw a fresh one.
            if show_swings
                if not na(sl_cur)
                    line.delete(sl_cur)
                sl_cur := line.new(x1 = ext_idx, y1 = level, x2 = ext_idx + 1, y2 = level, color = with_opacity(sl_col, sl_op), style = style_of(sl_style), width = sl_width)
    // This real candle becomes the "previous real candle" for the next comparison.
    has_prev     := true
    prev_is_bull := is_bull
    prev_high    := high
    prev_low     := low
    prev_bar_idx := bar_index

// --- SWING HIGH/LOW EXTENSION + TRIGGER LINE (live, every bar) ----------------
// Deliberately OUTSIDE the barstate.isconfirmed gate above: both lines below must
// reflect the CURRENT live price so the Potential BOS line can appear in real time
// as price crosses the watched level, ahead of that candle actually closing and the
// confirmed BOS block above drawing its tag. "Watched" mirrors the BOS engine's own
// trend check exactly (cold start watches both sides; trending watches only the
// side that would flip it) so these lines only ever track a level that could
// actually become the next BOS. On the very bar a break confirms, trend has already
// flipped above, so the side that just broke stops being watched and both its lines
// are deleted here on the same bar the official BOS tag is drawn — a clean handoff,
// no separate reset needed.
watched_sh   = trend != 1 and not na(cur_sh_price)
watched_sl   = trend != -1 and not na(cur_sl_price)
triggered_sh = watched_sh and close > cur_sh_price
triggered_sl = watched_sl and close < cur_sl_price

if show_ext
    ext_sh_line  := f_track_line(watched_sh, cur_sh_bar, cur_sh_price, ext_extend, ext_col, ext_op, ext_style, ext_width, ext_sh_line)
    ext_sl_line  := f_track_line(watched_sl, cur_sl_bar, cur_sl_price, ext_extend, ext_col, ext_op, ext_style, ext_width, ext_sl_line)
    // Potential BOS Line: own styling, drawn only while triggered (live price beyond
    // the level, candle not yet closed). Same origin/reach as the extension line above.
    pbos_sh_line := f_track_line(triggered_sh, cur_sh_bar, cur_sh_price, ext_extend, pbos_col, pbos_op, pbos_style, pbos_width, pbos_sh_line)
    pbos_sl_line := f_track_line(triggered_sl, cur_sl_bar, cur_sl_price, ext_extend, pbos_col, pbos_op, pbos_style, pbos_width, pbos_sl_line)
    // Time-to-close countdown at the tip of each watched line. Stays in play
    // across the dotted <-> Potential BOS flip, since both share the same tip.
    // Realtime-only: timenow is frozen on historical bars, so this is gated on
    // barstate.islast and only updates meaningfully on the live last bar.
    // Drawn on 1h charts and below only. Above that the countdown spans hours
    // and stops being useful as a timer.
    cd_tf_ok = timeframe.isintraday and timeframe.in_seconds() <= 3600
    if barstate.islast
        cd_txt = f_countdown_hms(time_close)
        if not na(cd_sh_lbl)
            label.delete(cd_sh_lbl)
            cd_sh_lbl := na
        if watched_sh and cd_tf_ok
            cd_sh_lbl := label.new(x = bar_index + ext_extend, y = cur_sh_price, text = cd_txt, style = label.style_label_left, color = color.new(color.white, 100), textcolor = ext_lbl_col, size = size.small)
        if not na(cd_sl_lbl)
            label.delete(cd_sl_lbl)
            cd_sl_lbl := na
        if watched_sl and cd_tf_ok
            cd_sl_lbl := label.new(x = bar_index + ext_extend, y = cur_sl_price, text = cd_txt, style = label.style_label_left, color = color.new(color.white, 100), textcolor = ext_lbl_col, size = size.small)
else
    if not na(ext_sh_line)
        line.delete(ext_sh_line)
        ext_sh_line := na
    if not na(ext_sl_line)
        line.delete(ext_sl_line)
        ext_sl_line := na
    if not na(cd_sh_lbl)
        label.delete(cd_sh_lbl)
        cd_sh_lbl := na
    if not na(cd_sl_lbl)
        label.delete(cd_sl_lbl)
        cd_sl_lbl := na
    if not na(pbos_sh_line)
        line.delete(pbos_sh_line)
        pbos_sh_line := na
    if not na(pbos_sl_line)
        line.delete(pbos_sl_line)
        pbos_sl_line := na
````
