# Percent Gainer - Multi-Timeframe FVG Layers

- url: https://www.tradingview.com/script/5wJkzYkP-Percent-Gainer-Multi-Timeframe-FVG-Layers/
- type: indicator
- pine_id: PUB;a3e60199016444e595b53e13a7db9cda
- version: 1.0

## Description

This indicator draws fair value gaps (FVGs) from up to three timeframes at once, each as its own color-coded layer. You can see a higher-timeframe gap and the current chart's gaps on the same chart, without repainting and without lookahead.

What counts as a fair value gap here

An FVG is a three-candle pattern. Candle 1 is the first candle, candle 2 is the middle candle, and candle 3 is the candle that completes the gap. This script uses a stricter rule than the basic gap definition.

Bullish gap (potential support)

Candle 3's low is above candle 1's high, which leaves the gap.
Candle 2 opens at or below candle 1's high.
Candle 3's low trades at or below candle 2's close.
The zone runs from candle 1's high (bottom) to candle 3's low (top).

Bearish gap (potential resistance)

Candle 3's high is below candle 1's low, which leaves the gap.
Candle 2 opens at or above candle 1's low.
Candle 3's high trades at or above candle 2's close.
The zone runs from candle 3's high (bottom) to candle 1's low (top).

Each layer has one color. Colors identify the timeframe, not the direction. A gap below current price is usually a bullish gap, and one above it is usually bearish. The color tells you which timeframe it came from.

How the timeframe layers work

Each layer has its own Timeframe setting. Leave it blank to use the chart timeframe. Default timeframes are Layer 1 = 60 minutes, Layer 2 = 15 minutes and Layer 3 = chart timeframe.

A layer only draws when its timeframe is the same as or higher than the chart's timeframe:

Higher than the chart (shown). A 4H layer (240) on a 1H chart draws every 4H gap on your 1H chart. This is the main use: higher-timeframe gaps as context while you trade a lower timeframe.
Same as the chart (shown). A 1H layer on a 1H chart draws that chart's own gaps, the same as leaving the field blank.
Lower than the chart (hidden). A 5-minute layer on a 1H chart is skipped. A 1H candle contains twelve 5-minute candles, and a 1H chart can't read each one, so most 5-minute gaps would be missed and the rest would be incomplete. Rather than show partial data, the layer draws nothing.

Hidden layers come back automatically when you switch to a chart at or below their timeframe. For example, with layers at 240, 15 and blank:

1H chart: the 4H gaps and the 1H gaps (blank layer) are shown. The 15-minute layer is hidden.
5-minute chart: all three are shown: 4H gaps, 15-minute gaps and 5-minute gaps.
Daily chart: only the blank layer (daily gaps) is shown. Both the 4H and 15-minute layers are hidden.

Layers are drawn in order, so Layer 1 appears on top of Layer 2, which appears on top of Layer 3.

When a zone appears

A gap only exists once its third candle has closed on that layer's timeframe. The box is drawn starting on the first chart bar after that close, then extends right while the gap stays open. A higher-timeframe gap therefore appears later than a chart-timeframe gap. A 4H gap shows up when its third 4H candle closes, not while that candle is still forming.

Mitigation (when a gap is considered filled)

Mitigation is checked once per completed candle of that layer's timeframe, using that candle's high, low and close. A 4H gap is judged by 4H candles, even when you're viewing a 1-minute chart. Price can trade into a 4H gap mid-candle, but the gap is only marked filled if the finished 4H candle meets the rule.

Mitigate on: Wick fills the gap when the candle's high or low reaches the threshold level. Close fills it only when the candle closes at or through the level.
Mitigation threshold: Tap (proximal edge) uses the edge price meets first. Midpoint (50%) uses the gap's middle. Full (distal edge) uses the far edge, so the gap must be completely filled.
Keep mitigated gaps: when on, a filled gap stays on the chart, frozen where it was filled, as a record of the level. When off, it's removed.
Mark mitigated gaps: when on, open gaps have a dashed border and filled gaps a solid one, so you can tell them apart at a glance.
Show FVG centerline / Centerline color: a dashed line at each gap's 50% level.

Per-layer settings

Show FVG 1 / 2 / 3: turns each layer on or off.
Timeframe: the timeframe that layer's gaps are detected on (see the rules above).
Color: that layer's box color.
Show last N gaps: how many gaps that layer keeps (up to 150). Once exceeded, the oldest gap is removed, whether it was filled or not.
Filter by time / Time window: when on, a gap is only drawn if its third candle opened inside this window, measured on that layer's timeframe.
Time window timezone (shared): the timezone for all three windows. The default is America/New_York (adjusts for daylight saving automatically). Use America/Chicago for Central time or Exchange for the symbol's own exchange time.

Non-repainting design

Every gap, time-window check and mitigation decision is read from a closed candle of that layer's timeframe, using request.security with lookahead turned off. Nothing is decided on the developing candle, so zones appear and get filled at the same point live as they do in history.

Limitations

Higher-timeframe gaps appear only after their candle closes, so they always lag the chart timeframe.
Gaps are only checked for mitigation at each layer candle's close. A 4H gap can look filled on a lower chart for several hours before it's marked filled.
Layers set lower than the chart timeframe are hidden by design (see above).
Box borders and centerlines share TradingView's drawing limits. Each layer is capped at 150 gaps, so up to 450 in total.
Use standard candles. On Heikin Ashi or other non-standard chart types, gaps are calculated from synthetic prices, not real ones.
This indicator is for educational and analytical purposes only. It is not financial advice, and past gap behavior does not guarantee future reactions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Straight Line Trades Inc. & Percent Gainers

//@version=6
indicator("Percent Gainer - Multi-Timeframe FVG Layers", shorttitle="PG FVG MTF", overlay=true, max_lines_count=500, max_boxes_count=500)

//────────────────────────────── Layer inputs ──────────────────────────────
groupMulti = "Multi-TF FVG Layers"
tfTip = "Timeframe this layer's gaps are detected on. Blank = chart timeframe.\n\nA layer only draws when its timeframe is the SAME as or HIGHER than the chart's:\n• 4H layer on a 1H chart = shown (higher timeframe gaps on a lower chart)\n• 5-minute layer on a 1H chart = hidden\n\nWhy: one 1H candle contains twelve 5-minute candles, and a 1H chart cannot read each of them, so most 5-minute gaps would be missed and the ones shown would be incomplete. Rather than show partial data, the layer is skipped.\n\nThe layer reappears automatically when you switch to a chart at or below its timeframe."

en4H  = input.bool(true,  "Show FVG 1", tooltip=tfTip,               group=groupMulti)
ft4H  = input.bool(false, "filter by time", group=groupMulti)
fs4H  = input.session("0800-1000", "  time window", group=groupMulti)

tf4H  = input.timeframe("240", "  Timeframe",        group=groupMulti)
col4H = input.color(color.new(color.yellow, 90), "  Color", group=groupMulti)
max4H = input.int(50, "    show last N gaps", minval=1, maxval=150, group=groupMulti)

en1H  = input.bool(true,  "Show FVG 2", tooltip=tfTip,              group=groupMulti)
ft1H  = input.bool(false, "filter by time", group=groupMulti)
fs1H  = input.session("0800-1000", "  time window", group=groupMulti)

tf1H  = input.timeframe("60",  "  Timeframe",        group=groupMulti)
col1H = input.color(color.new(color.red, 90),  "  Color", group=groupMulti)
max1H = input.int(50, "  show last N gaps", minval=1, maxval=150, group=groupMulti)

en15  = input.bool(true,  "Show FVG 3", tooltip=tfTip,             group=groupMulti)
ft15  = input.bool(false, "filter by time", group=groupMulti)
fs15  = input.session("0800-1000", "  time window", group=groupMulti)

tf15  = input.timeframe("15",  "  Timeframe",       group=groupMulti)
col15 = input.color(color.new(color.blue, 90), "  Color", group=groupMulti)
max15 = input.int(150, "  show last N gaps", minval=1, maxval=150, group=groupMulti)

// Shared timezone for all three time-window filters
tzFilter = input.string("America/New_York", "  Time window timezone", group=groupMulti, tooltip="Eastern time (auto EST/EDT). Use America/Chicago for CT, or Exchange for the symbol's exchange time.")

//────────────────────────────── Mitigation & display ──────────────────────────────
groupMit = "Mitigation & Display"

mitTrigger = input.string("Close", "  Mitigate on",
             options=["Wick", "Close"], group=groupMit,
             tooltip="Wick = the HTF candle's high/low reaching the level. Close = the HTF candle closing at/through it.")
mitDepth   = input.string("Full (distal edge)", "  Mitigation threshold",
             options=["Tap (proximal edge)", "Midpoint (50%)", "Full (distal edge)"], group=groupMit,
             tooltip="How far price must travel into the gap before it's considered mitigated and removed.")
showMid    = input.bool(true, "Show FVG centerline", group=groupMit)
colMid     = input.color(color.new(color.gray, 40), "  Centerline color", group=groupMit)
keepMitigated = input.bool(true,  "Keep mitigated gaps (show history)", group=groupMit, tooltip="On: a gap that closes through stays on the chart as a record of the level, frozen at its mitigation point, instead of being deleted. Off: original behaviour (removed on fill).")
markMit       = input.bool(true,  "Mark mitigated gaps (solid border)", group=groupMit, tooltip="Give filled gaps a solid border so they read differently from live (dashed) gaps at a glance.")

useWick = mitTrigger == "Wick"

//────────────────────────────── Zone type ──────────────────────────────
type fvgZone
    box   bx
    line  ml       // centerline (na when hidden)
    float top
    float bot
    float mid
    int   dir      // 1 = bullish gap (support), -1 = bearish gap (resistance)
    bool  mitigated = false   // true once price has closed/wicked through to the chosen depth
//────────────────────────────── State (separate arrays per layer) ──────────────────────────────
var array<fvgZone> zones4H = array.new<fvgZone>()
var array<fvgZone> zones1H = array.new<fvgZone>()
var array<fvgZone> zones15 = array.new<fvgZone>()

//────────────────────────────── Helpers ──────────────────────────────
// The price level that must be reached for mitigation, per threshold + direction.
f_mitLevel(z) =>
    prox = z.dir == 1 ? z.top : z.bot   // edge nearest returning price
    dist = z.dir == 1 ? z.bot : z.top   // far edge (full fill)
    switch mitDepth
        "Tap (proximal edge)" => prox
        "Midpoint (50%)"      => z.mid
        => dist

// Has the completed HTF candle (hi/lo/cl) mitigated this zone to the chosen depth?
f_isMitigated(z, hi, lo, cl) =>
    lvl = f_mitLevel(z)
    z.dir == 1 ? (useWick ? lo <= lvl : cl <= lvl) : (useWick ? hi >= lvl : cl >= lvl)

// Delete a zone's drawings.
f_kill(z) =>
    box.delete(z.bx)
    if not na(z.ml)
        line.delete(z.ml)

//────────────────────────────── Layer engine ──────────────────────────────
f_layer(tf, enabled, maxCount, boxCol, useTime, sess, _zones) =>
    // Lower-than-chart timeframes are skipped: request.security would only return the last intrabar and miss gaps
    bool tfOk = tf == "" or timeframe.in_seconds(tf) >= timeframe.in_seconds(timeframe.period)
    if enabled and tfOk
        // First bar of a new HTF candle on the current chart
        newTFbar = ta.change(time(tf)) != 0

        // In-window flag for creation (per-layer filter, shared timezone).
        // When the filter is off, this is always true.
        // Window is tested on the gap's 3rd candle (read with [1] at creation, exactly like the gap itself)
        bool gapInSess = request.security(syminfo.tickerid, tf, not na(time(timeframe.period, sess, tzFilter)), barmerge.gaps_off, barmerge.lookahead_off)
        inWindow = not useTime or gapInSess[1]

        // ── Detection (HTF-native, evaluated on closed values) ──
        top_pattern = request.security(syminfo.tickerid, tf, low[2] <= open[1] and high >= close[1], barmerge.gaps_off, barmerge.lookahead_off)
        bot_pattern = request.security(syminfo.tickerid, tf, high[2] >= open[1] and low  <= close[1], barmerge.gaps_off, barmerge.lookahead_off)
        top_sizeok  = request.security(syminfo.tickerid, tf, (low[2] - high)     > 0, barmerge.gaps_off, barmerge.lookahead_off)
        bot_sizeok  = request.security(syminfo.tickerid, tf, (low     - high[2]) > 0, barmerge.gaps_off, barmerge.lookahead_off)
        top_sig = top_pattern and top_sizeok
        bot_sig = bot_pattern and bot_sizeok

        // Gap boundaries (fixed at TF close)
        top_up = request.security(syminfo.tickerid, tf, low[2],  barmerge.gaps_off, barmerge.lookahead_off) // bearish gap upper
        top_lo = request.security(syminfo.tickerid, tf, high,    barmerge.gaps_off, barmerge.lookahead_off) // bearish gap lower
        bot_up = request.security(syminfo.tickerid, tf, low,     barmerge.gaps_off, barmerge.lookahead_off) // bullish gap upper
        bot_lo = request.security(syminfo.tickerid, tf, high[2], barmerge.gaps_off, barmerge.lookahead_off) // bullish gap lower

        // ── Mitigation reference: this layer's own H/L/C (non-repaint) ──
        [mHigh, mLow, mClose] = request.security(syminfo.tickerid, tf, [high, low, close], barmerge.gaps_off, barmerge.lookahead_off)

        // On each completed HTF candle: mitigate first, then create new gaps
        if newTFbar
            // 1) Mitigation pass on existing zones (uses the just-closed HTF candle)
            if array.size(_zones) > 0
                for i = array.size(_zones) - 1 to 0 by 1
                    z = array.get(_zones, i)
                    if not z.mitigated and f_isMitigated(z, mHigh[1], mLow[1], mClose[1])
                        if keepMitigated
                            z.mitigated := true
                            box.set_right(z.bx, bar_index)   // freeze the gap at its mitigation point
                            if markMit
                                box.set_border_style(z.bx, line.style_solid)
                            if not na(z.ml)
                                line.set_x2(z.ml, bar_index)
                        else
                            f_kill(z)
                            array.remove(_zones, i)

            // 2) Creation (a zone born this bar is skipped by the pass above)
            if top_sig[1] and inWindow
                topP = top_up[1]
                botP = top_lo[1]
                midP = math.avg(topP, botP)
                b  = box.new(bar_index, topP, bar_index, botP, bgcolor=boxCol, border_color=color.new(boxCol, 0), border_style=line.style_dashed)
                ml = showMid ? line.new(bar_index, midP, bar_index, midP, color=colMid, style=line.style_dashed) : na
                if array.size(_zones) >= maxCount
                    f_kill(array.shift(_zones))
                array.push(_zones, fvgZone.new(b, ml, topP, botP, midP, -1))
            if bot_sig[1] and inWindow
                topP = bot_up[1]
                botP = bot_lo[1]
                midP = math.avg(topP, botP)
                b  = box.new(bar_index, topP, bar_index, botP, bgcolor=boxCol, border_color=color.new(boxCol, 0), border_style=line.style_dashed)
                ml = showMid ? line.new(bar_index, midP, bar_index, midP, color=colMid, style=line.style_dashed) : na
                if array.size(_zones) >= maxCount
                    f_kill(array.shift(_zones))
                array.push(_zones, fvgZone.new(b, ml, topP, botP, midP, 1))

        // ── Extend live (unmitigated) zones to the current bar ──
        if array.size(_zones) > 0
            for i = 0 to array.size(_zones) - 1
                z = array.get(_zones, i)
                if not z.mitigated
                    box.set_right(z.bx, bar_index)
                    if not na(z.ml)
                        line.set_x2(z.ml, bar_index)

//────────────────────────────── Run layers (lowest TF first, so higher TFs paint on top) ──────────────────────────────
f_layer(tf15, en15, max15, col15, ft15, fs15, zones15)
f_layer(tf1H, en1H, max1H, col1H, ft1H, fs1H, zones1H)
f_layer(tf4H, en4H, max4H, col4H, ft4H, fs4H, zones4H)
````
