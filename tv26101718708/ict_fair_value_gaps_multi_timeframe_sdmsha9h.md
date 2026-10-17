# ICT - Fair Value Gaps (multi timeframe)

- url: https://www.tradingview.com/script/Sdmsha9H-ICT-Fair-Value-Gaps-multi-timeframe/
- type: indicator
- pine_id: PUB;e22836bd088e4786b64243a6e4997427
- version: 10.0

## Description

MTF FVG + Volume Imbalance
Overview
This indicator automatically identifies and draws Fair Value Gaps (FVGs) and Volume Imbalances (VIs) across 9 timeframes (1m, 3m, 5m, 15m, 1h, 3h, 4h, 1d, 1w) directly on your TradingView chart, eliminating the need to manually switch timeframes.

Fair Value Gap (FVG)
A 3-candle imbalance where a gap exists between the wick of candle 1 and the wick of candle 3. These zones often act as areas where price may return before continuing in its original direction.

Bullish FVG — low of candle 3 is above high of candle 1
Bearish FVG — high of candle 3 is below low of candle 1

Volume Imbalance (VI)
When a body gap exists between adjacent candles within the FVG pattern, the indicator automatically extends the FVG box to include the imbalance zone, giving a more complete picture of the area of interest.

Mitigation
A box is automatically removed when price closes beyond the gap boundary — keeping your chart clean with only active unmitigated zones visible.

Key Settings
Per Timeframe:

Show/hide toggle
Project to lower timeframes — disabled by default. When enabled, FVGs from that timeframe are visible on all lower timeframe charts. FVGs can never project upward.
Bullish/bearish colour pickers — assign unique colours per timeframe to distinguish zones when multiple timeframes are projected onto the same chart

Lookback Periods — FVGs are restricted to a configurable lookback window to keep the chart focused on recent price action:
GroupTimeframesDefaultIntraday1m, 3m, 5m, 15m5 daysHourly1h, 3h, 4h14 daysDaily1d30 daysWeekly1w140 days
Box Extension — boxes extend to the chart edge by default, updating in real time. Alternatively set a fixed N bar extension in the settings.

For analytical purposes only. Always combine with your own analysis and risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © MTF Fair Value Gap Indicator with Volume Imbalance Extension
// ─────────────────────────────────────────────────────────────────
// MTF FVG Indicator v1.12
//
// v1.12 (2026-10-11):
//   1. HIDDEN FVGs NO LONGER SQUASH THE CHART. The Proximity Filter
//      hid zones by making them fully transparent, but TradingView's
//      auto-scale still fitted the price axis to every drawing, so far
//      away hidden zones stretched the scale and squashed the candles
//      (seen on MNQ1! 1m: candles 31,163-31,240, price axis to ~31,600).
//      FvgZone now stores each zone's true top, bottom and left edge;
//      a hidden zone's box, 50% line and label collapse to a point at
//      the current close on the zone's right edge (the live bar or the
//      projection space past it; still transparent), so they add no price
//      extent even when the chart is scrolled back. A shown zone gets
//      its geometry back from the stored values, and a zone mitigated
//      while hidden gets its true bounds back before it becomes an
//      outline. Mitigation and the filter's distances read the stored
//      bounds, never the box, so nothing about WHICH zones exist, show
//      or mitigate changes.
//   2. Colour section headers drop their timeframe lists. TradingView
//      prints headers in capitals, so "(1m, 3m ...)" read as months
//      ("1M, 3M"). Header text only: no input moved, saved settings
//      are unaffected.
//   3. Projection spacing default 8 -> 6 bars (user ruling). Charts
//      that already run the indicator keep their saved value.
//
// v1.11 (2026-10-11):
//   1. SETTINGS RE-ORDERED for a first-time user (user ruling: the
//      saved-settings break is accepted). Order is now: Proximity
//      Filter, Visibility & Projection (2h moved into its rank slot
//      between 90m and 3h), Session Gaps, Mitigated FVGs, Max FVGs
//      Displayed, Right Edge Offset, Timeframe Label, 50%
//      Line, Box Borders, Colours (2h colours moved into Hourly). The
//      separate "2h FVGs" section is gone. Because TradingView keys
//      saved inputs by POSITION, charts that ran v1.10 will show
//      shifted settings: remove and re-add the indicator (or Reset
//      Settings) to start from the new defaults.
//   2. ANTI-CLUTTER DEFAULTS (the publisher's own chart settings):
//      Proximity Filter ON with X = 1; 3m and 5m projected to 1m;
//      projection spacing 8 bars; 50% line OFF. Every other default
//      is unchanged.
//   3. TOOLTIPS added to Show/Project, Mitigated, Max FVGs and Right
//      Edge Offset; the projection tooltip no longer calls a
//      blank list the default.
//   4. LOOKBACK INPUTS REMOVED (8 inputs, 125 -> 117). They never
//      limited anything: bi and c1_bi come from the same
//      request.security tuple (bar_index and bar_index[3]), so the
//      gate c1_bi >= bi - lookback reduced to lookback >= 3. History
//      was, and is, bounded by the Max FVGs caps and mitigation.
//      cutoff_* is now 0, which keeps the gate's only live effect
//      (skipping a window while c1_bi is still na). Nothing drawn
//      changes at any lookback of 3 or more. Apart from the inputs
//      block and that cutoff section, every line is byte-identical
//      to v1.10.
//
// v1.10 (2026-09-17):
//   1. PROXIMITY FILTER IS NOW PER TIMEFRAME (user ruling after running
//      v1.9 live on MNQ1! 1m: the pooled-global cap let the dense low
//      timeframes monopolise every slot — all nine live 1h projections
//      sat hidden while 1m/5m/15m zones hugging price took the 3 nearest
//      on both sides). X now keeps the X nearest un-mitigated zones
//      above price and X below FOR EACH enabled/projected timeframe, so
//      every timeframe stays represented: X = 1 shows the single nearest
//      zone per side per timeframe. Straddling zones still always show
//      and consume no slot; ties at a threshold still all show. The
//      pooled near_collect()/global threshold pass is gone — one
//      near_filter() call per timeframe now collects, sorts and applies
//      locally. Input title and tooltip updated (text only; the two
//      v1.9 inputs keep their position, type and defaults, so saved
//      settings survive). Everything else about the filter is unchanged
//      from v1.9: default OFF, visibility-only, live bar only, nothing
//      deleted, mitigated outlines untouched.
//
// v1.9 (2026-09-17):
//   1. PROXIMITY FILTER — "Display X live FVGs on either side of price"
//      (default OFF; nothing renders differently until enabled). When ON,
//      only the X nearest un-mitigated zones ABOVE current price and the X
//      nearest BELOW stay visible, pooled across ALL enabled timeframes;
//      a zone STRADDLING price is always visible and consumes no slot.
//      Inspired by the per-side cap in the CISD Model+ indicator, but
//      keyed to distance from price rather than recency.
//      It is a VISIBILITY layer only: zones are never deleted by it, keep
//      tracking mitigation, and re-appear as price approaches them. The
//      per-group retention caps below are unchanged and still bound
//      memory. Hiding sets the box/border/50%-line/label colours fully
//      transparent; showing restores them from the inputs. Runs on the
//      live bar only (two passes over at most 218 zones): pass 1 sorts
//      nearest-edge distances per side and takes the X-th smallest as the
//      threshold, pass 2 applies it per timeframe. Zones tied exactly at
//      the threshold all show, so a side can briefly exceed X (accepted;
//      no tie-break bookkeeping). Mitigated outlines are not filtered —
//      they already
//      render as outlines only and are governed by their own toggle.
//      New inputs are appended after every existing input (position rule,
//      see the v1.6 note below), so no saved chart setting moves.
//
// v1.8 (2026-09-13):
//   1. RIGHT-EDGE LOOKUP ONLY FOR VISIBLE ROWS (second agent pass on v1.7).
//      f_right_time() ran for all 18 rows before `if visible`: 36 future
//      time() lookups per bar, 34 of them wasted at default settings, with
//      an undocumented cost on long 1m charts against TradingView's
//      execution time limit. It now runs inside `if visible` (fixed on bar
//      0, so a row looks up on every bar or never), and the second lookup
//      is skipped when the offset is a whole number of bars. Nothing drawn
//      changes.
//   2. DEAD STATE REMOVED: FvgZone.roff and make_fvg_zone()'s right_offset
//      parameter were written but never read after v1.7.
//   3. COMMENTS CORRECTED (second agent pass): the right-edge fallback no
//      longer claims time() returns na on tick or price-based charts, and
//      the 499-bar cap is disclosed; the ranking comments match the seconds
//      ladder; "24M" is gone (TradingView charts run 1M to 12M); the
//      request note allows for identical requests counting once; the v1.7
//      and v1.6 entries below now say offsets COULD fall into a close, the
//      ladder also re-ranks long daily charts, and the upward leak predates
//      v1.2.
//
// v1.7 (2026-09-13):
//   1. RIGHT-EDGE STAGGER NO LONGER COLLAPSES AT A CLOSE (bug since v1.2).
//      f_right_time() turned N bars into time + N * bar length. From a bar
//      just before a close (e.g. Friday's last bar) offsets could fall
//      inside the closed period, where TradingView drew them on the next
//      session's first bar, so native and projected labels stacked (all
//      rows on 1m at a CME weekday close; most rows on 90m-4h over a
//      weekend; none from 15m up at a weekday close; v1.8 pass figures;
//      seen on MNQ1! 2h over a weekend: the 2h and 12h right edges
//      were stored at different times but drawn together). The timestamp
//      N bars ahead now comes from time(timeframe.period, bars_back = -N),
//      TradingView's expected future bar time (series int, 0..-499 used);
//      a fractional offset interpolates between two bars, and the old
//      arithmetic is the fallback if time() returns na. Computed once per
//      timeframe per bar in process_tf(), not once per zone.
//   2. MEMORY: NO REQUEST BELOW THE CHART TIMEFRAME. v1.6 raised "Memory
//      limits exceeded" on an MNQ1! 2h chart. The likely cause: each
//      request.security for a timeframe below the chart loads up to 200K
//      lower-timeframe bars (7 of the 18 calls on 2h, 11 on 12h), yet such
//      a timeframe can never draw, because FVGs never project upward.
//      f_req_tf() requests the chart's own timeframe for them instead, and
//      identical requests reuse one data set. Nothing drawn changes.
//   3. CHART RANK LADDER ENDS WITH TRADINGVIEW'S OWN 1M, 3M AND 12M SECOND
//      COUNTS, replacing v1.6's f_month_rank(). Every unmatched chart TF
//      (2M, 6M, 5W, 45D, ...) now ranks by the same seconds f_req_tf()
//      compares, so a row is never drawn from data it did not request.
//      Without it 5W+ weekly and 31D+ daily charts ranked below 1M and
//      projected 1M FVGs leaked UP onto them.
//
// v1.6 (2026-09-13):
//   1. 2h TIMEFRAME ADDED: 18 TFs / 18 request.security calls (limit 40).
//      2h ("120") ranks between 90m and 3h; ranks 3h..12M shift up one.
//      2h shares the Hourly cap, lookback and border. Its own inputs
//      (Show / Project / list, Bull / Bear colour) are APPENDED after
//      every existing input as a separate "2h FVGs" section. TV keys a
//      chart's saved inputs by POSITION, so inserting them beside 90m
//      would have scrambled saved settings on every chart running the
//      script. Existing inputs keep their order; only input titles
//      (Hourly cap and lookback gain 2h, see 5) and the projection
//      tooltip text changed.
//   2. SESSION-GAP FILTER NO LONGER BLANKS WHOLE TIMEFRAMES. v1.5 skipped
//      any FVG whose 3 candles spanned a close, gapped or not. Where a
//      session holds only 1-2 bars of a TF, every window spans one: on
//      MNQ1! v1.5 drew ZERO 12h FVGs (2 bars per session) while 7h (4
//      bars) still drew 6, and RTH stocks lose all of 4h/7h/12h by
//      construction. A close only fakes an FVG when PRICE jumps across
//      it, so a wick FVG is now skipped only when the candle after the
//      close OPENED beyond the previous candle's extreme in the zone's
//      direction (bull: above its high, bear: below its low). A C1->C2
//      body gap across a close lies inside the close-to-open jump, so it
//      never qualifies a VI-only zone, and neither VI box extension is
//      applied across a close. A "close" is any gap in bar time, so a
//      bar with no trades on a thin symbol counts too.
//      Measured on NQ 1m 2022-26 rebuilt as TV bars (Scripts/
//      mtf_fvg_gap_rule_check.py), zones skipped v1.5 -> v1.6: 1m 0.4%
//      -> 0.3%, 15m 3.6 -> 2.2, 2h 15.9 -> 6.2, 4h 35.8 -> 10.2, 12h 100
//      -> 15.6. A "gap window stays open" variant drew more, but far more
//      of the wick FVGs it kept were mostly reopen jump (1m 21% vs 6%),
//      so the open test stands.
//   3. "HIDE SESSION-GAP FVGs" TOGGLE, default ON, in its own "Session
//      Gaps" section (appended after the v1.5 inputs, before 2h, so no
//      saved setting moves). OFF gates both break flags, so detection
//      reverts to no gap filter at all. For symbols with long overnight
//      closes: on an RTH-only NQ slice the overnight jump forms most
//      higher-TF FVGs, and v1.6 skips 38% of 1h, 67% of 4h, 81% of 12h.
//   4. MONTHLY-MULTIPLE CHART RANK FIXED (leak present since v1.1; v1.2
//      narrowed it to charts longer than 1W). 2M, 4M, 6M etc. charts are
//      not in the string switch and fell to the seconds ladder, which
//      ended at 1W, so they ranked just above 1W and BELOW 1M: projected
//      1M FVGs leaked UP onto a 2M chart, and 1M and 3M FVGs onto a 6M
//      chart. f_month_rank() ranked them by timeframe.multiplier (replaced
//      in v1.7).
//   5. Em dashes in the 11 cap and lookback input titles replaced by
//      colons (title text only; positions unchanged).
//
// v1.5 (2026-08-28):
//   1. SESSION-GAP FILTER REWRITTEN — the v1.4 filter was DEAD CODE.
//      in_gap_window() tested wall-clock hours that hold no bars on
//      CME futures (the maintenance break IS 17:00-18:00 ET, so no
//      bar is ever stamped hour 17; likewise Fri>=17, Sat, Sun<18).
//      Measured on 1,639,337 NQ 1m bars (2022+): all four windows
//      matched ZERO bars. Only the spans_weekend fallback ever fired,
//      which catches NWOG but by construction can never catch NDOG
//      (the 16:59 and 18:00 bars share a calendar day, so d1 == d3).
//      Replaced by straddles_gap(), a bar-TIME discontinuity test.
//      t2 > tc1 (next bar opens after the previous one closed) is the
//      exact condition and also covers 90m/3h/4h/7h/12h, where the
//      truncated last bar of a session makes the elapsed test read
//      exactly one TF; the elapsed test is kept as a backstop. This
//      catches NDOG, NWOG, holidays and halts on any instrument with
//      no hard-coded session hours.
//   2. FILTER NOW KEYS ON THE FVG'S OWN TIMEFRAME, not the chart's.
//      v1.4 gated on `current_rank <= 11`, so on a 5m chart the 1D/
//      3D/1W/1M/3M/12M FVGs were run through the filter too, against
//      the stated intent ("Daily and above are never filtered").
//      tf_ms_of() returns 0 for 1D and above, which disables the test
//      for those timeframes whatever the chart is on.
//   3. time_close[3] / time_close[2] added to the request.security
//      tuple (17 -> 19 elements). request.security call count is
//      UNCHANGED at 17 / 40.
//
// v1.4 (2026-07-24):
//   1. 30m TIMEFRAME ADDED — now 17 TFs / 17 request.security calls
//      (limit 40). 30m ranks between 15m and 1h; ranks 1h..12M shift up
//      one. Grouped with Intraday for colour / border / lookback.
//   2. PER-GROUP DISPLAY CAP — keeps only the N most-recent un-mitigated
//      FVGs per timeframe (oldest deleted). Defaults: Intraday 20,
//      Hourly 10, Higher-TF 8. Stops a dense low-TF from starving the
//      500-object pools and evicting HTF projections.
//   3. MITIGATED CAP — a single global "Max mitigated FVGs" (default
//      100, most-recent). Bounds the mitigated-outline pool so it can't
//      grow unbounded when "Show Mitigated FVGs" is on.
//      Worst-case boxes: 208 live + 100 mitigated = 308 / 500.
//
// v1.3 (2026-07-24):
//   1. RIGHT EDGE TRACKS THE LIVE BAR — every un-mitigated FVG now
//      extends to current bar + its offset (native +3, HTF projections
//      a further `spacing` beyond that), instead of freezing near its
//      creation bar. The old "only newest extends" cap is removed.
//   2. MITIGATED OUTLINE IS INDEPENDENT — "Show Mitigated FVGs" now
//      draws its own outline (dedicated colour/width) regardless of the
//      live border toggle, and no longer prints the timeframe label.
//   3. DEFAULTS — borders off by default; border 787b86 @ 80% transp;
//      label dbdbdb @ 40%; 50% line 787b86 @ 40%.
//
// v1.2 (2026-07-24):
//   1. UPWARD-LEAK FIX — the chart-TF rank is now a FLOAT. Known
//      timeframes still use the exact string switch; any unranked TF
//      (10m, 30m, 2h, 6h, 8h, 2D, custom …) interpolates a fractional
//      rank from timeframe.in_seconds() against the known TF ladder.
//      Previously such TFs ranked 0, which silently defeated the
//      "FVGs never project upward" guard (current_rank > this_rank)
//      and the 1m guard (current_rank <= 1), so projected/1m FVGs
//      leaked onto e.g. a 30m chart. Now closed for every timeframe.
//   2. RIGHT-EDGE OFFSET MODEL — replaces "Chart Edge"/"N Bars". The
//      current (native) TF's newest FVG tracks current bar + native
//      offset (default +3). Each higher TF currently PROJECTED onto
//      the chart is staggered a further `spacing` bars to the right
//      (default +3), ordered by ascending timeframe. Offset depends on
//      the NUMBER/position of live projections, not the specific TF.
//      Both offsets are float inputs.
//   3. LABELS OUTSIDE THE BOX — the TF label now renders to the RIGHT
//      of the box's right edge (style_label_left) with a transparent
//      background, so the 50% line no longer cuts through the text.
//      Font defaults to proportional (better readability) with a
//      Default/Monospace dropdown; size/colour still configurable.
//   4. BORDER CONTROLS — one master border (show / colour / width) per
//      colour group: Intraday, Hourly, Higher-TF. Fill stays per-TF.
//
// v1.1 (2026-07-19): closure-confirmed detection; per-TF projection
//   lists; mitigation gated to own-TF close; true time anchoring;
//   TF label + 50% line inside box; FvgZone UDT.
// v1.0: "MTF FVG script 04.05.26" + VI-only C3 validity check.
// ─────────────────────────────────────────────────────────────────

//@version=6
indicator(title="MTF FVG + Volume Imbalance", shorttitle="MTF FVG", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS (re-ordered in v1.11, see header). TradingView keys saved
// input values by POSITION: from here on, append new inputs at the
// END of this block so published charts keep their settings.
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// INPUTS — PROXIMITY FILTER (anti-clutter, top since v1.11)
// ═══════════════════════════════════════════════════════════════

grp_near      = "Proximity Filter"
tip_near      = "For EACH enabled or projected timeframe, shows only the X nearest " +
     "un-mitigated FVGs above current price and the X nearest below. " +
     "X = 1 shows the single nearest FVG per side per timeframe. An FVG " +
     "straddling current price is always shown and does not use a slot.\n\n" +
     "Hidden FVGs are not deleted: they keep tracking mitigation and " +
     "re-appear as price moves toward them, so boxes will pop in and out " +
     "as price travels. The 'Max FVGs Displayed' caps still bound how " +
     "many zones are retained per timeframe underneath this filter.\n\n" +
     "Distance is measured to the zone's NEAR edge (bottom of a zone " +
     "above price, top of a zone below)."
near_filter_on = input.bool(true, title="Display X live FVGs on either side of price (per TF)", inline="near", group=grp_near, tooltip=tip_near)
near_cap       = input.int(1, title="", minval=1, maxval=50, inline="near", group=grp_near)

// ═══════════════════════════════════════════════════════════════
// INPUTS — VISIBILITY & PROJECTION
//
// Each row: Show | Project | Project-to list
// ═══════════════════════════════════════════════════════════════

tip_show = "Show draws a timeframe's FVGs on a chart of that same " +
     "timeframe (1m FVGs also draw on seconds charts). To see a higher " +
     "timeframe's FVGs on a lower chart (e.g. 5m FVGs on a 1m chart), " +
     "also tick Project on that timeframe's row.\n\n" +
     "Untick Show to switch a timeframe off everywhere."

tip_proj = "Which lower timeframes this FVG projects to.\n\n" +
     "BLANK  = project to ALL lower timeframes.\n" +
     "FILLED = project ONLY to the timeframes listed here.\n\n" +
     "Separate with a comma or semicolon, e.g.  5m, 15m, 1h\n\n" +
     "Accepted: 1m 3m 5m 15m 30m 90m 1h 2h 3h 4h 7h 12h 1D 3D 1W\n" +
     "(also raw Pine codes: 1 3 5 15 30 60 90 120 180 240 420 720)\n\n" +
     "CASE MATTERS on the M suffix: lowercase m = MINUTES, " +
     "uppercase M = MONTHS. So 3m = 3 minutes, 3M = 3 months.\n\n" +
     "Entries at or above this FVG's own timeframe are ignored " +
     "(FVGs never project upward), as are unrecognised entries. " +
     "This field does nothing unless Project is ticked."

grp_vis   = "Visibility & Projection"
show_1m   = input.bool(true,  title="Show 1m FVGs",  inline="1m",  group=grp_vis, tooltip=tip_show)
show_3m   = input.bool(true,  title="Show 3m FVGs",  inline="3m",  group=grp_vis)
proj_3m   = input.bool(true,  title="Project",       inline="3m",  group=grp_vis)
projtf_3m = input.string("1m", title="→",           inline="3m",  group=grp_vis, tooltip=tip_proj)
show_5m   = input.bool(true,  title="Show 5m FVGs",  inline="5m",  group=grp_vis)
proj_5m   = input.bool(true,  title="Project",       inline="5m",  group=grp_vis)
projtf_5m = input.string("1m", title="→",           inline="5m",  group=grp_vis, tooltip=tip_proj)
show_15m  = input.bool(true,  title="Show 15m FVGs", inline="15m", group=grp_vis)
proj_15m  = input.bool(false, title="Project",       inline="15m", group=grp_vis)
projtf_15m = input.string("",   title="→",           inline="15m", group=grp_vis, tooltip=tip_proj)
show_30m  = input.bool(true,  title="Show 30m FVGs", inline="30m", group=grp_vis)
proj_30m  = input.bool(false, title="Project",       inline="30m", group=grp_vis)
projtf_30m = input.string("",   title="→",           inline="30m", group=grp_vis, tooltip=tip_proj)
show_1h   = input.bool(true,  title="Show 1h FVGs",  inline="1h",  group=grp_vis)
proj_1h   = input.bool(false, title="Project",       inline="1h",  group=grp_vis)
projtf_1h = input.string("",   title="→",           inline="1h",  group=grp_vis, tooltip=tip_proj)
show_90m  = input.bool(true,  title="Show 90m FVGs", inline="90m", group=grp_vis)
proj_90m  = input.bool(false, title="Project",       inline="90m", group=grp_vis)
projtf_90m = input.string("",   title="→",           inline="90m", group=grp_vis, tooltip=tip_proj)
show_2h   = input.bool(true,  title="Show 2h FVGs",  inline="2h",  group=grp_vis)
proj_2h   = input.bool(false, title="Project",       inline="2h",  group=grp_vis)
projtf_2h = input.string("",   title="→",           inline="2h",  group=grp_vis, tooltip=tip_proj)
show_3h   = input.bool(true,  title="Show 3h FVGs",  inline="3h",  group=grp_vis)
proj_3h   = input.bool(false, title="Project",       inline="3h",  group=grp_vis)
projtf_3h = input.string("",   title="→",           inline="3h",  group=grp_vis, tooltip=tip_proj)
show_4h   = input.bool(true,  title="Show 4h FVGs",  inline="4h",  group=grp_vis)
proj_4h   = input.bool(false, title="Project",       inline="4h",  group=grp_vis)
projtf_4h = input.string("",   title="→",           inline="4h",  group=grp_vis, tooltip=tip_proj)
show_7h   = input.bool(true,  title="Show 7h FVGs",  inline="7h",  group=grp_vis)
proj_7h   = input.bool(false, title="Project",       inline="7h",  group=grp_vis)
projtf_7h = input.string("",   title="→",           inline="7h",  group=grp_vis, tooltip=tip_proj)
show_12h  = input.bool(true,  title="Show 12h FVGs", inline="12h", group=grp_vis)
proj_12h  = input.bool(false, title="Project",       inline="12h", group=grp_vis)
projtf_12h = input.string("",   title="→",           inline="12h", group=grp_vis, tooltip=tip_proj)
show_1d   = input.bool(true,  title="Show 1d FVGs",  inline="1d",  group=grp_vis)
proj_1d   = input.bool(false, title="Project",       inline="1d",  group=grp_vis)
projtf_1d = input.string("",   title="→",           inline="1d",  group=grp_vis, tooltip=tip_proj)
show_3d   = input.bool(true,  title="Show 3D FVGs",  inline="3d",  group=grp_vis)
proj_3d   = input.bool(false, title="Project",       inline="3d",  group=grp_vis)
projtf_3d = input.string("",   title="→",           inline="3d",  group=grp_vis, tooltip=tip_proj)
show_1w   = input.bool(true,  title="Show 1w FVGs",  inline="1w",  group=grp_vis)
proj_1w   = input.bool(false, title="Project",       inline="1w",  group=grp_vis)
projtf_1w = input.string("",   title="→",           inline="1w",  group=grp_vis, tooltip=tip_proj)
show_1M   = input.bool(true,  title="Show 1M FVGs",  inline="1M",  group=grp_vis)
proj_1M   = input.bool(false, title="Project",       inline="1M",  group=grp_vis)
projtf_1M = input.string("",   title="→",           inline="1M",  group=grp_vis, tooltip=tip_proj)
show_3M   = input.bool(true,  title="Show 3M FVGs",  inline="3M",  group=grp_vis)
proj_3M   = input.bool(false, title="Project",       inline="3M",  group=grp_vis)
projtf_3M = input.string("",   title="→",           inline="3M",  group=grp_vis, tooltip=tip_proj)
show_12M  = input.bool(true,  title="Show 12M FVGs", inline="12M", group=grp_vis)
proj_12M  = input.bool(false, title="Project",       inline="12M", group=grp_vis)
projtf_12M = input.string("",   title="→",           inline="12M", group=grp_vis, tooltip=tip_proj)

// ═══════════════════════════════════════════════════════════════
// INPUTS: SESSION GAPS (added v1.6)
//
// OFF gates both break flags in process_tf(), so detection reverts to
// no gap filter at all.
// ═══════════════════════════════════════════════════════════════

grp_gap       = "Session Gaps"
tip_gap       = "Skips FVGs made by the market closing and reopening: the daily " +
     "reopen gap (NDOG), the weekend reopen gap (NWOG), holidays and halts. " +
     "A close is any gap between candles, so on thinly traded symbols a " +
     "bar with no trades counts too.\n\n" +
     "An FVG across a close is skipped when price reopened beyond the " +
     "previous candle's high (bullish) or low (bearish), so the jump itself " +
     "opens the gap. A volume imbalance across a close is always ignored. " +
     "Applies to 1m-12h FVGs; daily and higher are never filtered.\n\n" +
     "Turn OFF to draw every FVG, e.g. on stocks with regular hours only, " +
     "where the overnight jump forms many higher-timeframe FVGs."
hide_gap_fvgs = input.bool(true, title="Hide session-gap FVGs (NDOG / NWOG)", group=grp_gap, tooltip=tip_gap)

// ═══════════════════════════════════════════════════════════════
// INPUTS — MITIGATED FVGs
// ═══════════════════════════════════════════════════════════════

grp_mit = "Mitigated FVGs"
tip_mit = "An FVG is mitigated when a candle of its OWN timeframe closes " +
     "beyond the far side of the zone (below a bullish FVG, above a bearish " +
     "one). It then stops extending.\n\n" +
     "ON keeps mitigated FVGs as a faint outline, no fill and no label. " +
     "OFF removes them from the chart."
show_mitigated = input.bool(false, title="Show Mitigated FVGs (outline only)", group=grp_mit, tooltip=tip_mit)
mit_border_col = input.color(color.new(#787b86, 80), title="Outline colour", inline="mit", group=grp_mit)
mit_border_w   = input.int(1, title="Width", minval=1, maxval=4, inline="mit", group=grp_mit)
mit_cap        = input.int(100, title="Max mitigated FVGs (most recent, global)", minval=1, group=grp_mit)

// ═══════════════════════════════════════════════════════════════
// INPUTS — MAX FVGs DISPLAYED (per group, most recent)
//
// Keeps only the N most-recent un-mitigated FVGs per timeframe; older
// ones are deleted. Prevents a dense low timeframe from exhausting the
// 500 box/line/label pools and evicting HTF projections.
// ═══════════════════════════════════════════════════════════════

grp_cap      = "Max FVGs Displayed (most recent)"
tip_cap      = "The most recent un-mitigated FVGs kept PER TIMEFRAME in each " +
     "group; older ones are deleted. Applies before the Proximity Filter, " +
     "which then picks the nearest of the FVGs kept here."
cap_intraday = input.int(20, title="Intraday: 1m, 3m, 5m, 15m, 30m",        minval=1, group=grp_cap, tooltip=tip_cap)
cap_hourly   = input.int(10, title="Hourly: 1h, 90m, 2h, 3h, 4h, 7h, 12h", minval=1, group=grp_cap)
cap_htf      = input.int(8,  title="Higher TF: 1D, 3D, 1W, 1M, 3M, 12M",     minval=1, group=grp_cap)

// ═══════════════════════════════════════════════════════════════
// INPUTS — RIGHT-EDGE OFFSET (bars)
//
// native_offset — the current (native) TF's newest FVG right edge
//                 sits this many bars to the right of the live bar.
// proj_spacing  — each higher TF currently projected onto the chart
//                 steps this many further bars right, so labels never
//                 collide. Ordering is by ascending timeframe among
//                 the projections that are live RIGHT NOW; the step
//                 depends on how many projections there are, not on
//                 which specific timeframes they are.
//
//   Right edge (bars ahead of live bar) = native_offset + spacing * k
//     k = 0  → native (current-TF) FVGs
//     k = 1  → 1st (lowest) projected higher TF
//     k = 2  → 2nd projected higher TF … etc.
//
//   e.g. defaults (3 / 6), 3m + 5m projected onto 1m:
//        1m native +3 · 3m +9 · 5m +15
// ═══════════════════════════════════════════════════════════════

grp_off       = "Right Edge Offset (bars)"
tip_off       = "How far right of the live bar the FVG boxes end, in bars. " +
     "Native = FVGs of the chart's own timeframe. Each projected higher " +
     "timeframe ends a further 'spacing' bars to the right, so the " +
     "timeframe labels sit side by side instead of on top of each other."
native_offset = input.float(3.0, title="Native offset (current TF)",   minval=0.0, step=0.5, group=grp_off, tooltip=tip_off)
proj_spacing  = input.float(6.0, title="Projection spacing (per HTF)", minval=0.0, step=0.5, group=grp_off)

// ═══════════════════════════════════════════════════════════════
// INPUTS — TF LABEL (renders OUTSIDE, to the right of the box)
// ═══════════════════════════════════════════════════════════════

grp_lbl       = "FVG Timeframe Label"
show_tf_label = input.bool(true, title="Show timeframe label", group=grp_lbl)
lbl_size_str  = input.string("Small", title="Text Size", options=["Tiny", "Small", "Normal", "Large"], inline="lbl", group=grp_lbl)
lbl_col       = input.color(color.new(#dbdbdb, 40), title="Colour", inline="lbl", group=grp_lbl)
lbl_font_str  = input.string("Default", title="Font", options=["Default", "Monospace"], group=grp_lbl)

// ═══════════════════════════════════════════════════════════════
// INPUTS — 50% LINE
// ═══════════════════════════════════════════════════════════════

grp_mid       = "50% Line"
show_mid      = input.bool(false, title="Show 50% line inside FVG", group=grp_mid)
mid_col       = input.color(color.new(#787b86, 40), title="Colour", inline="mid", group=grp_mid)
mid_style_str = input.string("Dotted", title="Style", options=["Dotted", "Dashed", "Solid"], inline="mid", group=grp_mid)
mid_width     = input.int(1, title="Width", minval=1, maxval=4, inline="mid", group=grp_mid)

// ═══════════════════════════════════════════════════════════════
// INPUTS — BOX BORDERS (one master control per colour group)
// ═══════════════════════════════════════════════════════════════

grp_bord      = "Box Borders"
show_bord_id  = input.bool(false, title="Intraday",  inline="bid",  group=grp_bord)
bord_col_id   = input.color(color.new(#787b86, 80), title="", inline="bid",  group=grp_bord)
bord_w_id     = input.int(1, title="W", minval=1, maxval=4, inline="bid",  group=grp_bord)
show_bord_h   = input.bool(false, title="Hourly",    inline="bh",   group=grp_bord)
bord_col_h    = input.color(color.new(#787b86, 80), title="", inline="bh",   group=grp_bord)
bord_w_h      = input.int(1, title="W", minval=1, maxval=4, inline="bh",   group=grp_bord)
show_bord_htf = input.bool(false, title="Higher TF", inline="bhtf", group=grp_bord)
bord_col_htf  = input.color(color.new(#787b86, 80), title="", inline="bhtf", group=grp_bord)
bord_w_htf    = input.int(1, title="W", minval=1, maxval=4, inline="bhtf", group=grp_bord)

// ═══════════════════════════════════════════════════════════════
// INPUTS — INTRADAY COLOURS (1m, 3m, 5m, 15m, 30m)
// ═══════════════════════════════════════════════════════════════

grp_col_id = "Intraday Colours"
bull_col_1m  = input.color(color.new(color.green, 95), title="1m  Bull", inline="c1m",  group=grp_col_id)
bear_col_1m  = input.color(color.new(color.red,   95), title="Bear",     inline="c1m",  group=grp_col_id)
bull_col_3m  = input.color(color.new(color.green, 95), title="3m  Bull", inline="c3m",  group=grp_col_id)
bear_col_3m  = input.color(color.new(color.red,   95), title="Bear",     inline="c3m",  group=grp_col_id)
bull_col_5m  = input.color(color.new(#00bcd4,     95), title="5m  Bull", inline="c5m",  group=grp_col_id)
bear_col_5m  = input.color(color.new(#ffeb3b,     95), title="Bear",     inline="c5m",  group=grp_col_id)
bull_col_15m = input.color(color.new(color.green, 95), title="15m Bull", inline="c15m", group=grp_col_id)
bear_col_15m = input.color(color.new(color.red,   95), title="Bear",     inline="c15m", group=grp_col_id)
bull_col_30m = input.color(color.new(color.green, 95), title="30m Bull", inline="c30m", group=grp_col_id)
bear_col_30m = input.color(color.new(color.red,   95), title="Bear",     inline="c30m", group=grp_col_id)

// ═══════════════════════════════════════════════════════════════
// INPUTS — HOURLY COLOURS (1h, 90m, 2h, 3h, 4h, 7h, 12h)
// ═══════════════════════════════════════════════════════════════

grp_col_h = "Hourly Colours"
bull_col_1h  = input.color(color.new(color.green, 95), title="1h  Bull", inline="c1h",  group=grp_col_h)
bear_col_1h  = input.color(color.new(color.red,   95), title="Bear",     inline="c1h",  group=grp_col_h)
bull_col_90m = input.color(color.new(color.green, 95), title="90m Bull", inline="c90m", group=grp_col_h)
bear_col_90m = input.color(color.new(color.red,   95), title="Bear",     inline="c90m", group=grp_col_h)
bull_col_2h = input.color(color.new(color.green, 95), title="2h  Bull", inline="c2h", group=grp_col_h)
bear_col_2h = input.color(color.new(color.red,   95), title="Bear",     inline="c2h", group=grp_col_h)
bull_col_3h  = input.color(color.new(color.green, 95), title="3h  Bull", inline="c3h",  group=grp_col_h)
bear_col_3h  = input.color(color.new(color.red,   95), title="Bear",     inline="c3h",  group=grp_col_h)
bull_col_4h  = input.color(color.new(color.green, 95), title="4h  Bull", inline="c4h",  group=grp_col_h)
bear_col_4h  = input.color(color.new(color.red,   95), title="Bear",     inline="c4h",  group=grp_col_h)
bull_col_7h  = input.color(color.new(color.green, 95), title="7h  Bull", inline="c7h",  group=grp_col_h)
bear_col_7h  = input.color(color.new(color.red,   95), title="Bear",     inline="c7h",  group=grp_col_h)
bull_col_12h = input.color(color.new(color.green, 95), title="12h Bull", inline="c12h", group=grp_col_h)
bear_col_12h = input.color(color.new(color.red,   95), title="Bear",     inline="c12h", group=grp_col_h)

// ═══════════════════════════════════════════════════════════════
// INPUTS — HIGHER TF COLOURS (1d, 3D, 1w, 1M, 3M, 12M)
// ═══════════════════════════════════════════════════════════════

grp_col_htf = "Higher TF Colours"
bull_col_1d  = input.color(color.new(color.green, 95), title="1d  Bull", inline="c1d",  group=grp_col_htf)
bear_col_1d  = input.color(color.new(color.red,   95), title="Bear",     inline="c1d",  group=grp_col_htf)
bull_col_3d  = input.color(color.new(color.green, 95), title="3D  Bull", inline="c3d",  group=grp_col_htf)
bear_col_3d  = input.color(color.new(color.red,   95), title="Bear",     inline="c3d",  group=grp_col_htf)
bull_col_1w  = input.color(color.new(color.green, 95), title="1w  Bull", inline="c1w",  group=grp_col_htf)
bear_col_1w  = input.color(color.new(color.red,   95), title="Bear",     inline="c1w",  group=grp_col_htf)
bull_col_1M  = input.color(color.new(color.green, 95), title="1M  Bull", inline="c1M",  group=grp_col_htf)
bear_col_1M  = input.color(color.new(color.red,   95), title="Bear",     inline="c1M",  group=grp_col_htf)
bull_col_3M  = input.color(color.new(color.green, 95), title="3M  Bull", inline="c3M",  group=grp_col_htf)
bear_col_3M  = input.color(color.new(color.red,   95), title="Bear",     inline="c3M",  group=grp_col_htf)
bull_col_12M = input.color(color.new(color.green, 95), title="12M Bull", inline="c12M", group=grp_col_htf)
bear_col_12M = input.color(color.new(color.red,   95), title="Bear",     inline="c12M", group=grp_col_htf)

// ═══════════════════════════════════════════════════════════════
// STYLE HELPERS
// ═══════════════════════════════════════════════════════════════

f_label_size(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_line_style(string st) =>
    switch st
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        "Solid"  => line.style_solid
        => line.style_dotted

f_font(string f) =>
    f == "Monospace" ? font.family_monospace : font.family_default

// ═══════════════════════════════════════════════════════════════
// TIMEFRAME RANKING: 18 FVG TIMEFRAMES
//
// String-based matching: tf_rank returns the integer rank of an FVG's
// OWN timeframe, and each of its 18 codes maps exactly. (The chart-rank
// fallback below does compare timeframe.in_seconds(), including
// TradingView's own 1M/3M/12M counts since v1.7, because only the
// ordering matters there.)
// 30m ("30") sits at rank 5 (v1.4) and 2h ("120") at rank 8 (v1.6);
// every rank above each insertion shifted +1.
// ═══════════════════════════════════════════════════════════════

tf_rank(string tf) =>
    switch tf
        "1"   => 1
        "3"   => 2
        "5"   => 3
        "15"  => 4
        "30"  => 5
        "60"  => 6
        "90"  => 7
        "120" => 8
        "180" => 9
        "240" => 10
        "420" => 11
        "720" => 12
        "1D"  => 13
        "3D"  => 14
        "1W"  => 15
        "1M"  => 16
        "3M"  => 17
        "12M" => 18
        => 0

// ═══════════════════════════════════════════════════════════════
// CHART-TF RANK — FLOAT, WITH SECONDS FALLBACK
//
// Known chart timeframes use the exact string switch. Anything else
// (10m, 45m, 6h, 8h, 2D, custom …) ranks 0 there, which used to
// defeat the upward-projection guard. We interpolate a FRACTIONAL
// rank from seconds against the seconds ladder below, e.g. a 45m chart
// falls between 30m (rank 5) and 1h (rank 6) → 5.5. The fallback only
// fires for unmatched TFs. v1.7: the ladder ends with TradingView's own
// 1M, 3M and 12M second counts, so every unmatched chart (2M, 6M, 5W,
// etc.) ranks by the same seconds that f_req_tf() compares.
// Ladder indices map to ranks 1..18 (1m … 12M); 7200 (2h) added v1.6.
// ═══════════════════════════════════════════════════════════════

var float[] tf_bounds = array.from(60.0, 180.0, 300.0, 900.0, 1800.0, 3600.0, 5400.0, 7200.0, 10800.0, 14400.0, 25200.0, 43200.0, 86400.0, 259200.0, 604800.0, float(timeframe.in_seconds("1M")), float(timeframe.in_seconds("3M")), float(timeframe.in_seconds("12M")))

f_seconds_rank(float s) =>
    float r = 0.5
    for i = 0 to array.size(tf_bounds) - 1
        float b = array.get(tf_bounds, i)
        if s >= b
            r := s == b ? float(i + 1) : (i + 1) + 0.5
    r

// Non-standard MONTHLY, long WEEKLY and long DAILY charts (2M, 6M, 5W,
// 45D, etc.) are not in the string switch. Before v1.6 they ranked below
// 1M and projected 1M FVGs leaked UP onto them; v1.6 ranked monthly ones
// by multiplier; v1.7 lets the extended ladder rank them all by seconds
// (2M, 5W and 45D all fall between 1M and 3M), which keeps rank and
// f_req_tf() in agreement.
_cur_exact   = tf_rank(timeframe.period)
current_rank = _cur_exact > 0 ? float(_cur_exact) : f_seconds_rank(timeframe.in_seconds())

// ═══════════════════════════════════════════════════════════════
// PROJECTION LIST PARSING
//
// Ambiguity note: Pine uses "1M" for 1 MONTH and "1" for 1 MINUTE.
// A user typing "1m" almost certainly means 1 minute. So the three
// genuinely ambiguous tokens (1M / 3M / 12M) are matched CASE-
// SENSITIVELY as months first; everything else falls through to a
// case-insensitive match where a trailing M reads as minutes.
// Unrecognised tokens return 0 and are silently ignored.
// ═══════════════════════════════════════════════════════════════

tf_token_rank(string tok) =>
    string s = str.replace_all(str.replace_all(tok, " ", ""), "\t", "")
    int r = 0
    if s == "1M"
        r := 16
    else if s == "3M"
        r := 17
    else if s == "12M"
        r := 18
    else
        string u = str.upper(s)
        if u == "1" or u == "1M" or u == "1MIN"
            r := 1
        else if u == "3" or u == "3M" or u == "3MIN"
            r := 2
        else if u == "5" or u == "5M" or u == "5MIN"
            r := 3
        else if u == "15" or u == "15M" or u == "15MIN"
            r := 4
        else if u == "30" or u == "30M" or u == "30MIN"
            r := 5
        else if u == "60" or u == "60M" or u == "1H"
            r := 6
        else if u == "90" or u == "90M"
            r := 7
        else if u == "120" or u == "120M" or u == "2H"
            r := 8
        else if u == "180" or u == "180M" or u == "3H"
            r := 9
        else if u == "240" or u == "240M" or u == "4H"
            r := 10
        else if u == "420" or u == "420M" or u == "7H"
            r := 11
        else if u == "720" or u == "720M" or u == "12H"
            r := 12
        else if u == "1D" or u == "D"
            r := 13
        else if u == "3D"
            r := 14
        else if u == "1W" or u == "W"
            r := 15
        else
            r := 0
    r

// rank is a float so the fractional current_rank (unmatched chart TFs)
// simply never matches an integer token rank — the correct behaviour,
// since a projection list can only name known timeframes.
tf_list_has(string csv, float rank) =>
    bool found = false
    string cleaned = str.replace_all(csv, ";", ",")
    string[] parts = str.split(cleaned, ",")
    if array.size(parts) > 0
        for i = 0 to array.size(parts) - 1
            if tf_token_rank(array.get(parts, i)) == rank
                found := true
    found

// show      — master on/off for this timeframe
// project   — allow display on lower chart timeframes
// proj_list — blank = all lower TFs; filled = only those listed
can_show(bool show, bool project, string proj_list, string tf_str) =>
    int    this_rank = tf_rank(tf_str)
    // Strip separators too, so a field holding only "," or ";" still
    // counts as blank rather than as an unmatchable list.
    string stripped  = str.replace_all(str.replace_all(proj_list, " ", ""), ";", "")
    string cleaned   = str.replace_all(stripped, ",", "")
    bool   result    = false
    if not show
        result := false
    else if current_rank == this_rank
        result := true
    else if current_rank > this_rank
        result := false
    else if not project
        result := false
    else if str.length(cleaned) == 0
        result := true
    else
        result := tf_list_has(proj_list, current_rank)
    result

// Evaluated once on bar 0 — every argument is a constant input, so the
// string parsing never repeats. Avoids str.split() churn on every bar.
var bool can_show_1m  = show_1m and current_rank <= 1
var bool can_show_3m  = can_show(show_3m,  proj_3m,  projtf_3m,  "3")
var bool can_show_5m  = can_show(show_5m,  proj_5m,  projtf_5m,  "5")
var bool can_show_15m = can_show(show_15m, proj_15m, projtf_15m, "15")
var bool can_show_30m = can_show(show_30m, proj_30m, projtf_30m, "30")
var bool can_show_1h  = can_show(show_1h,  proj_1h,  projtf_1h,  "60")
var bool can_show_90m = can_show(show_90m, proj_90m, projtf_90m, "90")
var bool can_show_2h  = can_show(show_2h,  proj_2h,  projtf_2h,  "120")
var bool can_show_3h  = can_show(show_3h,  proj_3h,  projtf_3h,  "180")
var bool can_show_4h  = can_show(show_4h,  proj_4h,  projtf_4h,  "240")
var bool can_show_7h  = can_show(show_7h,  proj_7h,  projtf_7h,  "420")
var bool can_show_12h = can_show(show_12h, proj_12h, projtf_12h, "720")
var bool can_show_1d  = can_show(show_1d,  proj_1d,  projtf_1d,  "1D")
var bool can_show_3d  = can_show(show_3d,  proj_3d,  projtf_3d,  "3D")
var bool can_show_1w  = can_show(show_1w,  proj_1w,  projtf_1w,  "1W")
var bool can_show_1M  = can_show(show_1M,  proj_1M,  projtf_1M,  "1M")
var bool can_show_3M  = can_show(show_3M,  proj_3M,  projtf_3M,  "3M")
var bool can_show_12M = can_show(show_12M, proj_12M, projtf_12M, "12M")

// ═══════════════════════════════════════════════════════════════
// PROJECTION STAGGER — RIGHT-EDGE OFFSET PER TIMEFRAME
//
// shown_ranks = the ranks actually drawn on this chart (native +
// every live projection). A TF's stagger index k is its position
// among those, so the spacing tracks the NUMBER/position of live
// projections, never a specific timeframe. Native TF → k = 0.
// ═══════════════════════════════════════════════════════════════

build_shown() =>
    int[] s = array.new<int>()
    if can_show_1m
        array.push(s, 1)
    if can_show_3m
        array.push(s, 2)
    if can_show_5m
        array.push(s, 3)
    if can_show_15m
        array.push(s, 4)
    if can_show_30m
        array.push(s, 5)
    if can_show_1h
        array.push(s, 6)
    if can_show_90m
        array.push(s, 7)
    if can_show_2h
        array.push(s, 8)
    if can_show_3h
        array.push(s, 9)
    if can_show_4h
        array.push(s, 10)
    if can_show_7h
        array.push(s, 11)
    if can_show_12h
        array.push(s, 12)
    if can_show_1d
        array.push(s, 13)
    if can_show_3d
        array.push(s, 14)
    if can_show_1w
        array.push(s, 15)
    if can_show_1M
        array.push(s, 16)
    if can_show_3M
        array.push(s, 17)
    if can_show_12M
        array.push(s, 18)
    s

var int[] shown_ranks = build_shown()

// k for a given TF: 0 if it is the native (current) TF, otherwise
// 1 + how many OTHER live projections sit below it in timeframe.
proj_index(int this_rank) =>
    int idx = 0
    if this_rank > current_rank
        idx := 1
        if array.size(shown_ranks) > 0
            for i = 0 to array.size(shown_ranks) - 1
                int x = array.get(shown_ranks, i)
                if x > current_rank and x < this_rank
                    idx += 1
    idx

// Right-edge offset in chart bars, computed once per timeframe.
var float roff_1m  = native_offset + proj_spacing * proj_index(1)
var float roff_3m  = native_offset + proj_spacing * proj_index(2)
var float roff_5m  = native_offset + proj_spacing * proj_index(3)
var float roff_15m = native_offset + proj_spacing * proj_index(4)
var float roff_30m = native_offset + proj_spacing * proj_index(5)
var float roff_1h  = native_offset + proj_spacing * proj_index(6)
var float roff_90m = native_offset + proj_spacing * proj_index(7)
var float roff_2h  = native_offset + proj_spacing * proj_index(8)
var float roff_3h  = native_offset + proj_spacing * proj_index(9)
var float roff_4h  = native_offset + proj_spacing * proj_index(10)
var float roff_7h  = native_offset + proj_spacing * proj_index(11)
var float roff_12h = native_offset + proj_spacing * proj_index(12)
var float roff_1d  = native_offset + proj_spacing * proj_index(13)
var float roff_3d  = native_offset + proj_spacing * proj_index(14)
var float roff_1w  = native_offset + proj_spacing * proj_index(15)
var float roff_1M  = native_offset + proj_spacing * proj_index(16)
var float roff_3M  = native_offset + proj_spacing * proj_index(17)
var float roff_12M = native_offset + proj_spacing * proj_index(18)

// ═══════════════════════════════════════════════════════════════
// SESSION GAP FILTER — NDOG & NWOG
//
// A New Day / New Week Opening Gap is not a Fair Value Gap: the
// "imbalance" is simply time the market was shut.
//
// STEP 1, find the close: a discontinuity in BAR TIME at a junction
// of the 3-candle window (C1->C2, C2->C3), never a wall-clock window
// (the v1.4 windows matched ZERO bars on CME futures). Either signal:
//   a. t_next > tc_prev: the next candle opens AFTER the previous one
//      closed. Exact, and on 90m/2h/3h/4h/7h/12h the only one that sees
//      the CME weekday close, where the truncated last bar of a session
//      leaves an elapsed time of one TF or less across the break.
//   b. elapsed > tf_ms: fires on longer closes (weekends, holidays, the
//      RTH overnight) and on any feed whose time_close is not truncated.
// Any missing bar counts, so a bar with no trades on a thin symbol is a
// "close" too.
//
// STEP 2 (v1.6), only a PRICE jump across the close is an artefact.
// v1.5 skipped every window that spanned a close; on a TF with 1-2
// bars per session that is every window (v1.5 drew ZERO 12h FVGs on
// MNQ1!). A wick FVG is now skipped only when the candle after the
// close OPENED beyond the previous candle's extreme in the zone's
// direction; a C1->C2 body gap across a close never qualifies a VI-only
// zone, and VI box extensions are not applied across a close. Applied
// in process_tf() and make_fvg_zone(), only while "Hide session-gap
// FVGs" is on.
//
// Keyed on the FVG's OWN timeframe via tf_ms_of(), which returns 0
// for 1D and above so daily+ is never filtered whatever the chart TF.
// ═══════════════════════════════════════════════════════════════

tf_ms_of(string tf_text) =>
    switch tf_text
        "1m"  => 60000
        "3m"  => 180000
        "5m"  => 300000
        "15m" => 900000
        "30m" => 1800000
        "1h"  => 3600000
        "90m" => 5400000
        "2h"  => 7200000
        "3h"  => 10800000
        "4h"  => 14400000
        "7h"  => 25200000
        "12h" => 43200000
        => 0

// True when bar time jumps between two consecutive candles: a market
// close, or on a thin symbol a bar with no trades.
session_break(int t_prev, int tc_prev, int t_next, int tf_ms) =>
    tf_ms > 0 and (t_next > tc_prev or (t_next - t_prev) > tf_ms)

// ═══════════════════════════════════════════════════════════════
// PATTERN HELPERS
// ═══════════════════════════════════════════════════════════════

body_top(float o, float c)    => math.max(o, c)
body_bottom(float o, float c) => math.min(o, c)

is_bull_fvg(float h1, float l3) => l3 > h1
is_bear_fvg(float l1, float h3) => h3 < l1

vi_gap_exists(float top_of_lower_body, float bottom_of_upper_body) =>
    bottom_of_upper_body > top_of_lower_body

// ═══════════════════════════════════════════════════════════════
// FVG ZONE TYPE
//
// One object owns its box, 50% line and TF label so that creation,
// right-edge extension and deletion always stay in sync. (v1.8: the
// unused roff field is gone; process_tf() passes each timeframe's right
// edge in directly.)
// ═══════════════════════════════════════════════════════════════

type FvgZone
    box   b
    line  mid
    label lbl
    bool  bull
    float top      // true zone bounds (v1.12): the box may be collapsed
    float bottom   // while hidden by the Proximity Filter
    int   left     // true left edge (C1 open time), same reason

var FvgZone[] zones_1m  = array.new<FvgZone>()
var FvgZone[] zones_3m  = array.new<FvgZone>()
var FvgZone[] zones_5m  = array.new<FvgZone>()
var FvgZone[] zones_15m = array.new<FvgZone>()
var FvgZone[] zones_30m = array.new<FvgZone>()
var FvgZone[] zones_1h  = array.new<FvgZone>()
var FvgZone[] zones_90m = array.new<FvgZone>()
var FvgZone[] zones_2h  = array.new<FvgZone>()
var FvgZone[] zones_3h  = array.new<FvgZone>()
var FvgZone[] zones_4h  = array.new<FvgZone>()
var FvgZone[] zones_7h  = array.new<FvgZone>()
var FvgZone[] zones_12h = array.new<FvgZone>()
var FvgZone[] zones_1d  = array.new<FvgZone>()
var FvgZone[] zones_3d  = array.new<FvgZone>()
var FvgZone[] zones_1w  = array.new<FvgZone>()
var FvgZone[] zones_1M  = array.new<FvgZone>()
var FvgZone[] zones_3M  = array.new<FvgZone>()
var FvgZone[] zones_12M = array.new<FvgZone>()

// Shared bucket for mitigated outlines (show_mitigated on). Kept
// separate from the live arrays so it can be capped independently and
// its members never re-extend. Boxes only — line/label already deleted.
var FvgZone[] mitigated_zones = array.new<FvgZone>()

// ═══════════════════════════════════════════════════════════════
// HTF DATA — ONE request.security() PER TIMEFRAME
//
// Returns candles [3], [2], [1] (C1, C2, C3 of the pattern) — note
// [0], the still-forming HTF bar, is deliberately NOT used. That is
// what makes detection closure-confirmed.
//
// bar_index and time_close are folded into the same tuple,
// removing separate calls. 19 elements; one request.security call
// per timeframe (18 since 2h was added in v1.6). A timeframe below the
// chart requests the chart's own timeframe instead (v1.7, f_req_tf()),
// and identical requests count once toward TradingView's limit of 40.
// ═══════════════════════════════════════════════════════════════

// A timeframe below the chart can never draw (FVGs never project upward),
// but requesting it loaded up to 200K lower-timeframe bars per call. Ask
// for the chart's own timeframe instead: identical requests share data,
// and process_tf() ignores the result because that row's can_show_* is
// false. Seconds on both sides match the extended rank ladder.
f_req_tf(string tf) =>
    timeframe.in_seconds() > timeframe.in_seconds(tf) ? timeframe.period : tf

get_candles() =>
    [open[3], high[3], low[3], close[3], time[3], time_close[3],
     open[2], high[2], low[2], close[2], time[2], time_close[2],
     open[1], high[1], low[1], close[1], time[1],
     bar_index, bar_index[3]]

[o1m_1,  h1m_1,  l1m_1,  c1m_1,  t1m_1, tc1m_1,  o1m_2,  h1m_2,  l1m_2,  c1m_2,  t1m_2, tc1m_2,  o1m_3,  h1m_3,  l1m_3,  c1m_3,  t1m_3,  bi1m,  bi1m_c1]  = request.security(syminfo.tickerid, f_req_tf("1"),   get_candles(), lookahead=barmerge.lookahead_off)
[o3m_1,  h3m_1,  l3m_1,  c3m_1,  t3m_1, tc3m_1,  o3m_2,  h3m_2,  l3m_2,  c3m_2,  t3m_2, tc3m_2,  o3m_3,  h3m_3,  l3m_3,  c3m_3,  t3m_3,  bi3m,  bi3m_c1]  = request.security(syminfo.tickerid, f_req_tf("3"),   get_candles(), lookahead=barmerge.lookahead_off)
[o5m_1,  h5m_1,  l5m_1,  c5m_1,  t5m_1, tc5m_1,  o5m_2,  h5m_2,  l5m_2,  c5m_2,  t5m_2, tc5m_2,  o5m_3,  h5m_3,  l5m_3,  c5m_3,  t5m_3,  bi5m,  bi5m_c1]  = request.security(syminfo.tickerid, f_req_tf("5"),   get_candles(), lookahead=barmerge.lookahead_off)
[o15m_1, h15m_1, l15m_1, c15m_1, t15m_1, tc15m_1, o15m_2, h15m_2, l15m_2, c15m_2, t15m_2, tc15m_2, o15m_3, h15m_3, l15m_3, c15m_3, t15m_3, bi15m, bi15m_c1] = request.security(syminfo.tickerid, f_req_tf("15"),  get_candles(), lookahead=barmerge.lookahead_off)
[o30m_1, h30m_1, l30m_1, c30m_1, t30m_1, tc30m_1, o30m_2, h30m_2, l30m_2, c30m_2, t30m_2, tc30m_2, o30m_3, h30m_3, l30m_3, c30m_3, t30m_3, bi30m, bi30m_c1] = request.security(syminfo.tickerid, f_req_tf("30"),  get_candles(), lookahead=barmerge.lookahead_off)
[o1h_1,  h1h_1,  l1h_1,  c1h_1,  t1h_1, tc1h_1,  o1h_2,  h1h_2,  l1h_2,  c1h_2,  t1h_2, tc1h_2,  o1h_3,  h1h_3,  l1h_3,  c1h_3,  t1h_3,  bi1h,  bi1h_c1]  = request.security(syminfo.tickerid, f_req_tf("60"),  get_candles(), lookahead=barmerge.lookahead_off)
[o90m_1, h90m_1, l90m_1, c90m_1, t90m_1, tc90m_1, o90m_2, h90m_2, l90m_2, c90m_2, t90m_2, tc90m_2, o90m_3, h90m_3, l90m_3, c90m_3, t90m_3, bi90m, bi90m_c1] = request.security(syminfo.tickerid, f_req_tf("90"),  get_candles(), lookahead=barmerge.lookahead_off)
[o2h_1,  h2h_1,  l2h_1,  c2h_1,  t2h_1, tc2h_1,  o2h_2,  h2h_2,  l2h_2,  c2h_2,  t2h_2, tc2h_2,  o2h_3,  h2h_3,  l2h_3,  c2h_3,  t2h_3,  bi2h,  bi2h_c1]  = request.security(syminfo.tickerid, f_req_tf("120"), get_candles(), lookahead=barmerge.lookahead_off)
[o3h_1,  h3h_1,  l3h_1,  c3h_1,  t3h_1, tc3h_1,  o3h_2,  h3h_2,  l3h_2,  c3h_2,  t3h_2, tc3h_2,  o3h_3,  h3h_3,  l3h_3,  c3h_3,  t3h_3,  bi3h,  bi3h_c1]  = request.security(syminfo.tickerid, f_req_tf("180"), get_candles(), lookahead=barmerge.lookahead_off)
[o4h_1,  h4h_1,  l4h_1,  c4h_1,  t4h_1, tc4h_1,  o4h_2,  h4h_2,  l4h_2,  c4h_2,  t4h_2, tc4h_2,  o4h_3,  h4h_3,  l4h_3,  c4h_3,  t4h_3,  bi4h,  bi4h_c1]  = request.security(syminfo.tickerid, f_req_tf("240"), get_candles(), lookahead=barmerge.lookahead_off)
[o7h_1,  h7h_1,  l7h_1,  c7h_1,  t7h_1, tc7h_1,  o7h_2,  h7h_2,  l7h_2,  c7h_2,  t7h_2, tc7h_2,  o7h_3,  h7h_3,  l7h_3,  c7h_3,  t7h_3,  bi7h,  bi7h_c1]  = request.security(syminfo.tickerid, f_req_tf("420"), get_candles(), lookahead=barmerge.lookahead_off)
[o12h_1, h12h_1, l12h_1, c12h_1, t12h_1, tc12h_1, o12h_2, h12h_2, l12h_2, c12h_2, t12h_2, tc12h_2, o12h_3, h12h_3, l12h_3, c12h_3, t12h_3, bi12h, bi12h_c1] = request.security(syminfo.tickerid, f_req_tf("720"), get_candles(), lookahead=barmerge.lookahead_off)
[o1d_1,  h1d_1,  l1d_1,  c1d_1,  t1d_1, tc1d_1,  o1d_2,  h1d_2,  l1d_2,  c1d_2,  t1d_2, tc1d_2,  o1d_3,  h1d_3,  l1d_3,  c1d_3,  t1d_3,  bi1d,  bi1d_c1]  = request.security(syminfo.tickerid, f_req_tf("1D"),  get_candles(), lookahead=barmerge.lookahead_off)
[o3d_1,  h3d_1,  l3d_1,  c3d_1,  t3d_1, tc3d_1,  o3d_2,  h3d_2,  l3d_2,  c3d_2,  t3d_2, tc3d_2,  o3d_3,  h3d_3,  l3d_3,  c3d_3,  t3d_3,  bi3d,  bi3d_c1]  = request.security(syminfo.tickerid, f_req_tf("3D"),  get_candles(), lookahead=barmerge.lookahead_off)
[o1w_1,  h1w_1,  l1w_1,  c1w_1,  t1w_1, tc1w_1,  o1w_2,  h1w_2,  l1w_2,  c1w_2,  t1w_2, tc1w_2,  o1w_3,  h1w_3,  l1w_3,  c1w_3,  t1w_3,  bi1w,  bi1w_c1]  = request.security(syminfo.tickerid, f_req_tf("1W"),  get_candles(), lookahead=barmerge.lookahead_off)
[o1M_1,  h1M_1,  l1M_1,  c1M_1,  t1M_1, tc1M_1,  o1M_2,  h1M_2,  l1M_2,  c1M_2,  t1M_2, tc1M_2,  o1M_3,  h1M_3,  l1M_3,  c1M_3,  t1M_3,  bi1M,  bi1M_c1]  = request.security(syminfo.tickerid, f_req_tf("1M"),  get_candles(), lookahead=barmerge.lookahead_off)
[o3M_1,  h3M_1,  l3M_1,  c3M_1,  t3M_1, tc3M_1,  o3M_2,  h3M_2,  l3M_2,  c3M_2,  t3M_2, tc3M_2,  o3M_3,  h3M_3,  l3M_3,  c3M_3,  t3M_3,  bi3M,  bi3M_c1]  = request.security(syminfo.tickerid, f_req_tf("3M"),  get_candles(), lookahead=barmerge.lookahead_off)
[o12M_1, h12M_1, l12M_1, c12M_1, t12M_1, tc12M_1, o12M_2, h12M_2, l12M_2, c12M_2, t12M_2, tc12M_2, o12M_3, h12M_3, l12M_3, c12M_3, t12M_3, bi12M, bi12M_c1] = request.security(syminfo.tickerid, f_req_tf("12M"), get_candles(), lookahead=barmerge.lookahead_off)

// A new HTF bar has opened — equivalently, C3 has just closed.
is_new_1m_bar  = ta.change(t1m_3)  != 0
is_new_3m_bar  = ta.change(t3m_3)  != 0
is_new_5m_bar  = ta.change(t5m_3)  != 0
is_new_15m_bar = ta.change(t15m_3) != 0
is_new_30m_bar = ta.change(t30m_3) != 0
is_new_1h_bar  = ta.change(t1h_3)  != 0
is_new_90m_bar = ta.change(t90m_3) != 0
is_new_2h_bar  = ta.change(t2h_3)  != 0
is_new_3h_bar  = ta.change(t3h_3)  != 0
is_new_4h_bar  = ta.change(t4h_3)  != 0
is_new_7h_bar  = ta.change(t7h_3)  != 0
is_new_12h_bar = ta.change(t12h_3) != 0
is_new_1d_bar  = ta.change(t1d_3)  != 0
is_new_3d_bar  = ta.change(t3d_3)  != 0
is_new_1w_bar  = ta.change(t1w_3)  != 0
is_new_1M_bar  = ta.change(t1M_3)  != 0
is_new_3M_bar  = ta.change(t3M_3)  != 0
is_new_12M_bar = ta.change(t12M_3) != 0

// ═══════════════════════════════════════════════════════════════
// DETECTION GATE (v1.11: Lookback inputs removed, see header item 4)
//
// process_tf() keeps its `c1_bi >= cutoff` gate. With cutoff 0 it only
// skips a window while c1_bi (bar_index[3] of that timeframe) is na,
// which is exactly what the v1.10 gate did at any lookback >= 3.
// ═══════════════════════════════════════════════════════════════

int cutoff_1m  = 0
int cutoff_3m  = 0
int cutoff_5m  = 0
int cutoff_15m = 0
int cutoff_30m = 0
int cutoff_1h  = 0
int cutoff_90m = 0
int cutoff_2h  = 0
int cutoff_3h  = 0
int cutoff_4h  = 0
int cutoff_7h  = 0
int cutoff_12h = 0
int cutoff_1d  = 0
int cutoff_3d  = 0
int cutoff_1w  = 0
int cutoff_1M  = 0
int cutoff_3M  = 0
int cutoff_12M = 0

// ═══════════════════════════════════════════════════════════════
// RIGHT EDGE: TIME BASED
//
// All drawings use xloc.bar_time. A zone's right edge is its
// timeframe's offset (chart bars) projected forward from the live
// bar (per-zone offsets were removed in v1.8). v1.7: the
// timestamp N bars ahead is time(timeframe.period, bars_back = -N),
// TradingView's expected time of that future bar, not time + N * bar
// length. From a bar just before a close (Friday's last bar) that
// arithmetic could put offsets inside the closed period, where they
// render on the next session's first bar, so native and projected
// labels stacked. Whole bars are looked up (0..-499), a fractional
// offset interpolates between two (v1.8: the second lookup is skipped
// for a whole-bar offset), and offsets are capped at 499 bars, so rows
// set beyond that share one edge. If time() returns na the old
// arithmetic is the fallback; the docs only warn that future times on
// tick or price-based charts may be inaccurate, not that they are na.
// ═══════════════════════════════════════════════════════════════

f_right_time(float offset_bars) =>
    float off = math.min(math.max(offset_bars, 0.0), 499.0)
    int   k   = math.floor(off)
    float fr  = off - k
    int   t0  = time(timeframe.period, bars_back = -k)
    int   t1  = fr == 0.0 ? t0 : time(timeframe.period, bars_back = -(k + 1))
    int   tb  = int(time + off * timeframe.in_seconds() * 1000)
    na(t0) or na(t1) ? tb : int(t0 + fr * (t1 - t0))

// ═══════════════════════════════════════════════════════════════
// RIGHT EDGE UPDATE
// EVERY un-mitigated zone tracks the live bar + its timeframe's
// offset, so the box runs from its creation candle to current bar + N.
// Box, 50% line and label all move together. Mitigated zones are
// removed from the array, so they stop here and freeze in place.
// Every zone in one array shares its timeframe's offset, so process_tf()
// computes rt once per timeframe per bar, and only for a visible row
// (v1.7, v1.8).
// ═══════════════════════════════════════════════════════════════

update_right_edges(FvgZone[] arr, int rt) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            FvgZone z  = array.get(arr, i)
            box.set_right(z.b, rt)
            if not na(z.mid)
                line.set_x2(z.mid, rt)
            if not na(z.lbl)
                label.set_x(z.lbl, rt)

// ═══════════════════════════════════════════════════════════════
// DISPLAY CAP — KEEP THE N MOST-RECENT UN-MITIGATED ZONES
// New zones are pushed to the end, so the oldest sit at the front.
// Deleting from the front keeps the newest N and frees box / line /
// label slots for the shared 500-object pools.
// ═══════════════════════════════════════════════════════════════

trim_zones(FvgZone[] arr, int cap) =>
    while array.size(arr) > cap
        FvgZone z = array.shift(arr)
        box.delete(z.b)
        if not na(z.mid)
            line.delete(z.mid)
        if not na(z.lbl)
            label.delete(z.lbl)

// ═══════════════════════════════════════════════════════════════
// FVG ZONE BUILDER WITH VI EXTENSION
//
// left_time = C1's actual open timestamp, so the box starts at the
// correct candle regardless of the chart timeframe it is projected
// onto. right_time = this timeframe's future-bar right edge, computed
// once per bar in process_tf().
// The TF label renders OUTSIDE, to the right of the box's right edge
// (style_label_left) with a transparent background, so the 50% line
// never cuts through the text.
// ═══════════════════════════════════════════════════════════════

make_fvg_zone(
     bool   bull,
     float  o1, float h1, float l1, float c1,
     float  o2, float h2, float l2, float c2,
     float  o3, float h3, float l3, float c3,
     bool   ext_12, bool ext_23,
     int    left_time,
     color  col,
     bool   show_border, color border_col, int border_w,
     int    right_time,
     string tf_text) =>

    float box_top    = bull ? l3 : l1
    float box_bottom = bull ? h1 : h3

    float bt1 = body_top(o1, c1)
    float bb1 = body_bottom(o1, c1)
    float bt2 = body_top(o2, c2)
    float bb2 = body_bottom(o2, c2)
    float bt3 = body_top(o3, c3)
    float bb3 = body_bottom(o3, c3)

    // VI between C1 and C2. ext_12 / ext_23 are false when a close sits
    // at that junction and "Hide session-gap FVGs" is on (v1.6): a body
    // gap across a close is the close-to-open jump, not an imbalance, so
    // it never widens a box.
    if ext_12
        if bull
            if vi_gap_exists(bt1, bb2)
                box_bottom := math.min(box_bottom, bt1)
        else
            if vi_gap_exists(bt2, bb1)
                box_top := math.max(box_top, bb1)

    // VI between C2 and C3
    if ext_23
        if bull
            if vi_gap_exists(bt2, bb3)
                box_top := math.max(box_top, bb3)
        else
            if vi_gap_exists(bt3, bb2)
                box_bottom := math.min(box_bottom, bt3)

    float mid_price  = (box_top + box_bottom) / 2.0

    box zb = box.new(
         left         = left_time,
         top          = box_top,
         right        = right_time,
         bottom       = box_bottom,
         bgcolor      = col,
         border_color = show_border ? border_col : color.new(color.white, 100),
         border_width = show_border ? border_w : 0,
         xloc         = xloc.bar_time,
         extend       = extend.none)

    line zl = na
    if show_mid
        zl := line.new(
             x1    = left_time,
             y1    = mid_price,
             x2    = right_time,
             y2    = mid_price,
             xloc  = xloc.bar_time,
             color = mid_col,
             style = f_line_style(mid_style_str),
             width = mid_width)

    // Anchored at the box's RIGHT edge with style_label_left, so the
    // pointer sits on the box edge and the text body renders to the
    // RIGHT — outside the box. Transparent background (na fill) leaves
    // just the text. The staggered right edges keep labels from
    // colliding across timeframes.
    label zt = na
    if show_tf_label
        zt := label.new(
             x                = right_time,
             y                = mid_price,
             text             = tf_text,
             xloc             = xloc.bar_time,
             color            = color.new(color.white, 100),
             textcolor        = lbl_col,
             style            = label.style_label_left,
             size             = f_label_size(lbl_size_str),
             text_font_family = f_font(lbl_font_str))

    FvgZone.new(zb, zl, zt, bull, box_top, box_bottom, left_time)

// ═══════════════════════════════════════════════════════════════
// MITIGATION CHECK — GATED TO THE ZONE'S OWN TIMEFRAME CLOSE
//
// htf_close is the close of the HTF bar that has just closed, so a
// 12h FVG is only ever mitigated by a 12h close — never by a 5m
// close on a 5m chart. Callers gate this on is_new_bar.
// ═══════════════════════════════════════════════════════════════

check_mitigation(FvgZone[] arr, float htf_close) =>
    if array.size(arr) > 0
        int i = array.size(arr) - 1
        while i >= 0
            FvgZone z         = array.get(arr, i)
            bool    mitigated = z.bull ? htf_close < z.bottom : htf_close > z.top
            if mitigated
                // The 50% line and TF label are no longer actionable.
                if not na(z.mid)
                    line.delete(z.mid)
                if not na(z.lbl)
                    label.delete(z.lbl)
                if show_mitigated
                    // Outline is drawn with its own dedicated colour and
                    // width, independent of the live per-group border
                    // toggle — so it always shows even with borders off.
                    // Restore the true bounds first: the Proximity
                    // Filter may have collapsed this box while hidden.
                    box.set_top(z.b, z.top)
                    box.set_bottom(z.b, z.bottom)
                    box.set_left(z.b, z.left)
                    box.set_bgcolor(z.b, color.new(color.white, 100))
                    box.set_border_color(z.b, mit_border_col)
                    box.set_border_width(z.b, mit_border_w)
                    // Move into the shared mitigated bucket and cap it to
                    // the newest mit_cap outlines (oldest deleted).
                    array.push(mitigated_zones, z)
                    while array.size(mitigated_zones) > mit_cap
                        FvgZone m = array.shift(mitigated_zones)
                        box.delete(m.b)
                else
                    box.delete(z.b)
                // Removed from the array, so its right edge stops
                // extending — the box now ends where it was mitigated.
                array.remove(arr, i)
            i -= 1

// ═══════════════════════════════════════════════════════════════
// PROCESS ONE TIMEFRAME
//
// Candle roles: (o1..) = HTF bar [3] = C1
//               (o2..) = HTF bar [2] = C2
//               (o3..) = HTF bar [1] = C3, JUST CLOSED
// ═══════════════════════════════════════════════════════════════

process_tf(
     bool      visible,
     bool      is_new_bar,
     int       cutoff,
     int       c1_bi,
     float     o1, float h1, float l1, float c1, int t1, int tc1,
     float     o2, float h2, float l2, float c2, int t2, int tc2,
     float     o3, float h3, float l3, float c3, int t3,
     FvgZone[] zones,
     color     bull_col,
     color     bear_col,
     bool      show_border, color border_col, int border_w,
     float     right_offset,
     int       cap,
     string    tf_text) =>

    if visible
        // Right edge for this timeframe, shared by every zone. `visible` is
        // fixed on bar 0, so a row looks it up on every bar or never (v1.8:
        // hidden rows no longer pay for two future time() lookups per bar).
        int rt = f_right_time(right_offset)
        update_right_edges(zones, rt)
        if is_new_bar
            // Mitigation first, so a zone created on this same bar is
            // never tested against its own C3 close.
            check_mitigation(zones, c3)
            if c1_bi >= cutoff
                int  tf_ms    = tf_ms_of(tf_text)
                // With "Hide session-gap FVGs" OFF no close is ever seen,
                // so nothing below filters: plain unfiltered detection.
                bool break_12 = hide_gap_fvgs and session_break(t1, tc1, t2, tf_ms)
                bool break_23 = hide_gap_fvgs and session_break(t2, tc2, t3, tf_ms)
                // Session-gap artefact (v1.6): the candle after a close
                // OPENED beyond the previous candle's extreme in the
                // zone's direction, so the jump itself would form the gap.
                bool bull_gap = (break_12 and o2 > h1) or (break_23 and o3 > h2)
                bool bear_gap = (break_12 and o2 < l1) or (break_23 and o3 < l2)
                float bt1 = body_top(o1, c1)
                float bb1 = body_bottom(o1, c1)
                float bb2 = body_bottom(o2, c2)
                float bt2 = body_top(o2, c2)
                // VI-only gate: a body gap alone qualifies, but C3 must
                // not have traded back through it. A C1->C2 body gap
                // across a close lies inside the close-to-open jump, so
                // it cannot qualify a zone on its own (v1.6).
                bool bull_vi_valid = vi_gap_exists(bt1, bb2) and l3 > bb2 and not break_12
                bool bear_vi_valid = vi_gap_exists(bt2, bb1) and h3 < bt2 and not break_12
                if not bull_gap and (is_bull_fvg(h1, l3) or bull_vi_valid)
                    array.push(zones, make_fvg_zone(true, o1, h1, l1, c1, o2, h2, l2, c2, o3, h3, l3, c3, not break_12, not break_23, t1, bull_col, show_border, border_col, border_w, rt, tf_text))
                if not bear_gap and (is_bear_fvg(l1, h3) or bear_vi_valid)
                    array.push(zones, make_fvg_zone(false, o1, h1, l1, c1, o2, h2, l2, c2, o3, h3, l3, c3, not break_12, not break_23, t1, bear_col, show_border, border_col, border_w, rt, tf_text))
            // Enforce the per-group display cap after any new pushes.
            trim_zones(zones, cap)

// ═══════════════════════════════════════════════════════════════
// MAIN EXECUTION
// ═══════════════════════════════════════════════════════════════

process_tf(can_show_1m,  is_new_1m_bar,  cutoff_1m,  int(bi1m_c1),  o1m_1,  h1m_1,  l1m_1,  c1m_1,  t1m_1, tc1m_1,  o1m_2,  h1m_2,  l1m_2,  c1m_2,  t1m_2, tc1m_2,  o1m_3,  h1m_3,  l1m_3,  c1m_3,  t1m_3,  zones_1m,  bull_col_1m,  bear_col_1m,  show_bord_id,  bord_col_id,  bord_w_id,  roff_1m,  cap_intraday, "1m")
process_tf(can_show_3m,  is_new_3m_bar,  cutoff_3m,  int(bi3m_c1),  o3m_1,  h3m_1,  l3m_1,  c3m_1,  t3m_1, tc3m_1,  o3m_2,  h3m_2,  l3m_2,  c3m_2,  t3m_2, tc3m_2,  o3m_3,  h3m_3,  l3m_3,  c3m_3,  t3m_3,  zones_3m,  bull_col_3m,  bear_col_3m,  show_bord_id,  bord_col_id,  bord_w_id,  roff_3m,  cap_intraday, "3m")
process_tf(can_show_5m,  is_new_5m_bar,  cutoff_5m,  int(bi5m_c1),  o5m_1,  h5m_1,  l5m_1,  c5m_1,  t5m_1, tc5m_1,  o5m_2,  h5m_2,  l5m_2,  c5m_2,  t5m_2, tc5m_2,  o5m_3,  h5m_3,  l5m_3,  c5m_3,  t5m_3,  zones_5m,  bull_col_5m,  bear_col_5m,  show_bord_id,  bord_col_id,  bord_w_id,  roff_5m,  cap_intraday, "5m")
process_tf(can_show_15m, is_new_15m_bar, cutoff_15m, int(bi15m_c1), o15m_1, h15m_1, l15m_1, c15m_1, t15m_1, tc15m_1, o15m_2, h15m_2, l15m_2, c15m_2, t15m_2, tc15m_2, o15m_3, h15m_3, l15m_3, c15m_3, t15m_3, zones_15m, bull_col_15m, bear_col_15m, show_bord_id,  bord_col_id,  bord_w_id,  roff_15m, cap_intraday, "15m")
process_tf(can_show_30m, is_new_30m_bar, cutoff_30m, int(bi30m_c1), o30m_1, h30m_1, l30m_1, c30m_1, t30m_1, tc30m_1, o30m_2, h30m_2, l30m_2, c30m_2, t30m_2, tc30m_2, o30m_3, h30m_3, l30m_3, c30m_3, t30m_3, zones_30m, bull_col_30m, bear_col_30m, show_bord_id,  bord_col_id,  bord_w_id,  roff_30m, cap_intraday, "30m")
process_tf(can_show_1h,  is_new_1h_bar,  cutoff_1h,  int(bi1h_c1),  o1h_1,  h1h_1,  l1h_1,  c1h_1,  t1h_1, tc1h_1,  o1h_2,  h1h_2,  l1h_2,  c1h_2,  t1h_2, tc1h_2,  o1h_3,  h1h_3,  l1h_3,  c1h_3,  t1h_3,  zones_1h,  bull_col_1h,  bear_col_1h,  show_bord_h,   bord_col_h,   bord_w_h,   roff_1h,  cap_hourly,   "1h")
process_tf(can_show_90m, is_new_90m_bar, cutoff_90m, int(bi90m_c1), o90m_1, h90m_1, l90m_1, c90m_1, t90m_1, tc90m_1, o90m_2, h90m_2, l90m_2, c90m_2, t90m_2, tc90m_2, o90m_3, h90m_3, l90m_3, c90m_3, t90m_3, zones_90m, bull_col_90m, bear_col_90m, show_bord_h,   bord_col_h,   bord_w_h,   roff_90m, cap_hourly,   "90m")
process_tf(can_show_2h,  is_new_2h_bar,  cutoff_2h,  int(bi2h_c1),  o2h_1,  h2h_1,  l2h_1,  c2h_1,  t2h_1, tc2h_1,  o2h_2,  h2h_2,  l2h_2,  c2h_2,  t2h_2, tc2h_2,  o2h_3,  h2h_3,  l2h_3,  c2h_3,  t2h_3,  zones_2h,  bull_col_2h,  bear_col_2h,  show_bord_h,   bord_col_h,   bord_w_h,   roff_2h,  cap_hourly,   "2h")
process_tf(can_show_3h,  is_new_3h_bar,  cutoff_3h,  int(bi3h_c1),  o3h_1,  h3h_1,  l3h_1,  c3h_1,  t3h_1, tc3h_1,  o3h_2,  h3h_2,  l3h_2,  c3h_2,  t3h_2, tc3h_2,  o3h_3,  h3h_3,  l3h_3,  c3h_3,  t3h_3,  zones_3h,  bull_col_3h,  bear_col_3h,  show_bord_h,   bord_col_h,   bord_w_h,   roff_3h,  cap_hourly,   "3h")
process_tf(can_show_4h,  is_new_4h_bar,  cutoff_4h,  int(bi4h_c1),  o4h_1,  h4h_1,  l4h_1,  c4h_1,  t4h_1, tc4h_1,  o4h_2,  h4h_2,  l4h_2,  c4h_2,  t4h_2, tc4h_2,  o4h_3,  h4h_3,  l4h_3,  c4h_3,  t4h_3,  zones_4h,  bull_col_4h,  bear_col_4h,  show_bord_h,   bord_col_h,   bord_w_h,   roff_4h,  cap_hourly,   "4h")
process_tf(can_show_7h,  is_new_7h_bar,  cutoff_7h,  int(bi7h_c1),  o7h_1,  h7h_1,  l7h_1,  c7h_1,  t7h_1, tc7h_1,  o7h_2,  h7h_2,  l7h_2,  c7h_2,  t7h_2, tc7h_2,  o7h_3,  h7h_3,  l7h_3,  c7h_3,  t7h_3,  zones_7h,  bull_col_7h,  bear_col_7h,  show_bord_h,   bord_col_h,   bord_w_h,   roff_7h,  cap_hourly,   "7h")
process_tf(can_show_12h, is_new_12h_bar, cutoff_12h, int(bi12h_c1), o12h_1, h12h_1, l12h_1, c12h_1, t12h_1, tc12h_1, o12h_2, h12h_2, l12h_2, c12h_2, t12h_2, tc12h_2, o12h_3, h12h_3, l12h_3, c12h_3, t12h_3, zones_12h, bull_col_12h, bear_col_12h, show_bord_h,   bord_col_h,   bord_w_h,   roff_12h, cap_hourly,   "12h")
process_tf(can_show_1d,  is_new_1d_bar,  cutoff_1d,  int(bi1d_c1),  o1d_1,  h1d_1,  l1d_1,  c1d_1,  t1d_1, tc1d_1,  o1d_2,  h1d_2,  l1d_2,  c1d_2,  t1d_2, tc1d_2,  o1d_3,  h1d_3,  l1d_3,  c1d_3,  t1d_3,  zones_1d,  bull_col_1d,  bear_col_1d,  show_bord_htf, bord_col_htf, bord_w_htf, roff_1d,  cap_htf,      "1D")
process_tf(can_show_3d,  is_new_3d_bar,  cutoff_3d,  int(bi3d_c1),  o3d_1,  h3d_1,  l3d_1,  c3d_1,  t3d_1, tc3d_1,  o3d_2,  h3d_2,  l3d_2,  c3d_2,  t3d_2, tc3d_2,  o3d_3,  h3d_3,  l3d_3,  c3d_3,  t3d_3,  zones_3d,  bull_col_3d,  bear_col_3d,  show_bord_htf, bord_col_htf, bord_w_htf, roff_3d,  cap_htf,      "3D")
process_tf(can_show_1w,  is_new_1w_bar,  cutoff_1w,  int(bi1w_c1),  o1w_1,  h1w_1,  l1w_1,  c1w_1,  t1w_1, tc1w_1,  o1w_2,  h1w_2,  l1w_2,  c1w_2,  t1w_2, tc1w_2,  o1w_3,  h1w_3,  l1w_3,  c1w_3,  t1w_3,  zones_1w,  bull_col_1w,  bear_col_1w,  show_bord_htf, bord_col_htf, bord_w_htf, roff_1w,  cap_htf,      "1W")
process_tf(can_show_1M,  is_new_1M_bar,  cutoff_1M,  int(bi1M_c1),  o1M_1,  h1M_1,  l1M_1,  c1M_1,  t1M_1, tc1M_1,  o1M_2,  h1M_2,  l1M_2,  c1M_2,  t1M_2, tc1M_2,  o1M_3,  h1M_3,  l1M_3,  c1M_3,  t1M_3,  zones_1M,  bull_col_1M,  bear_col_1M,  show_bord_htf, bord_col_htf, bord_w_htf, roff_1M,  cap_htf,      "1M")
process_tf(can_show_3M,  is_new_3M_bar,  cutoff_3M,  int(bi3M_c1),  o3M_1,  h3M_1,  l3M_1,  c3M_1,  t3M_1, tc3M_1,  o3M_2,  h3M_2,  l3M_2,  c3M_2,  t3M_2, tc3M_2,  o3M_3,  h3M_3,  l3M_3,  c3M_3,  t3M_3,  zones_3M,  bull_col_3M,  bear_col_3M,  show_bord_htf, bord_col_htf, bord_w_htf, roff_3M,  cap_htf,      "3M")
process_tf(can_show_12M, is_new_12M_bar, cutoff_12M, int(bi12M_c1), o12M_1, h12M_1, l12M_1, c12M_1, t12M_1, tc12M_1, o12M_2, h12M_2, l12M_2, c12M_2, t12M_2, tc12M_2, o12M_3, h12M_3, l12M_3, c12M_3, t12M_3, zones_12M, bull_col_12M, bear_col_12M, show_bord_htf, bord_col_htf, bord_w_htf, roff_12M, cap_htf,      "12M")

// ═══════════════════════════════════════════════════════════════
// PROXIMITY FILTER (v1.9, PER TIMEFRAME SINCE v1.10) — X NEAREST
// LIVE FVGs PER SIDE OF PRICE, FOR EACH TIMEFRAME
//
// Visibility layer only, applied AFTER the process_tf() calls so a
// zone created this bar is filtered the same bar. Runs on the live
// bar only: historical bars need no filtering because only the final
// state of a drawing renders, and the last bar always runs this.
//
// near_filter() handles ONE timeframe's array end to end, with that
// row's colours in scope at the call site:
//   1. Collect the nearest-edge distance of every un-mitigated zone
//      into an above-price and a below-price list. A zone straddling
//      price joins neither list — it is always shown, no slot used.
//   2. Threshold per side: the near_cap-th smallest distance, or na
//      when that side holds near_cap or fewer zones (na = show all).
//      Zones tied exactly at the threshold all show, so a side can
//      briefly exceed X (accepted; no tie-break bookkeeping).
//   3. Apply: within threshold restores the input colours and the
//      stored geometry; outside sets box fill, border, 50% line and
//      label fully transparent AND collapses them to zero height at
//      close and to a point on the right edge (v1.12), so hidden
//      zones do not stretch the auto-scale.
// Nothing is deleted: hidden zones keep tracking mitigation and
// their right edges, and re-appear as price approaches. Border WIDTH
// is never touched (0 when the group border is off, per
// make_fvg_zone()). Mitigated outlines are not filtered (own toggle,
// outline only). v1.9 pooled all timeframes into one global
// threshold, which let the dense low timeframes take every slot and
// hide all higher-timeframe projections; per-timeframe replaces it.
// ═══════════════════════════════════════════════════════════════

color COL_NEAR_HIDE = color.new(color.white, 100)

near_filter(FvgZone[] arr, color b_col, color s_col, bool show_border, color border_col) =>
    if array.size(arr) > 0
        float[] above = array.new<float>()
        float[] below = array.new<float>()
        for i = 0 to array.size(arr) - 1
            FvgZone z = array.get(arr, i)
            float zb = z.bottom
            float zt = z.top
            if zb > close
                array.push(above, zb - close)
            else if zt < close
                array.push(below, close - zt)
        array.sort(above, order.ascending)
        array.sort(below, order.ascending)
        float thr_above = array.size(above) > near_cap ? array.get(above, near_cap - 1) : na
        float thr_below = array.size(below) > near_cap ? array.get(below, near_cap - 1) : na
        for i = 0 to array.size(arr) - 1
            FvgZone z = array.get(arr, i)
            float zb = z.bottom
            float zt = z.top
            bool shown = true
            if zb > close
                shown := na(thr_above) or zb - close <= thr_above
            else if zt < close
                shown := na(thr_below) or close - zt <= thr_below
            // v1.12: a hidden zone collapses to a point at close on its
            // right edge (in the future space past the live bar), so it
            // cannot stretch the price axis, even when scrolled back; a
            // shown one is restored from the stored bounds. Set both
            // ways on every run.
            float y_top = shown ? zt : close
            float y_bot = shown ? zb : close
            float y_mid = shown ? (zt + zb) / 2.0 : close
            int   x_lft = shown ? z.left : box.get_right(z.b)
            box.set_top(z.b, y_top)
            box.set_bottom(z.b, y_bot)
            box.set_left(z.b, x_lft)
            box.set_bgcolor(z.b, shown ? (z.bull ? b_col : s_col) : COL_NEAR_HIDE)
            box.set_border_color(z.b, shown and show_border ? border_col : COL_NEAR_HIDE)
            if not na(z.mid)
                line.set_x1(z.mid, x_lft)
                line.set_y1(z.mid, y_mid)
                line.set_y2(z.mid, y_mid)
                line.set_color(z.mid, shown ? mid_col : COL_NEAR_HIDE)
            if not na(z.lbl)
                label.set_y(z.lbl, y_mid)
                label.set_textcolor(z.lbl, shown ? lbl_col : COL_NEAR_HIDE)

if near_filter_on and barstate.islast
    near_filter(zones_1m,  bull_col_1m,  bear_col_1m,  show_bord_id,  bord_col_id)
    near_filter(zones_3m,  bull_col_3m,  bear_col_3m,  show_bord_id,  bord_col_id)
    near_filter(zones_5m,  bull_col_5m,  bear_col_5m,  show_bord_id,  bord_col_id)
    near_filter(zones_15m, bull_col_15m, bear_col_15m, show_bord_id,  bord_col_id)
    near_filter(zones_30m, bull_col_30m, bear_col_30m, show_bord_id,  bord_col_id)
    near_filter(zones_1h,  bull_col_1h,  bear_col_1h,  show_bord_h,   bord_col_h)
    near_filter(zones_90m, bull_col_90m, bear_col_90m, show_bord_h,   bord_col_h)
    near_filter(zones_2h,  bull_col_2h,  bear_col_2h,  show_bord_h,   bord_col_h)
    near_filter(zones_3h,  bull_col_3h,  bear_col_3h,  show_bord_h,   bord_col_h)
    near_filter(zones_4h,  bull_col_4h,  bear_col_4h,  show_bord_h,   bord_col_h)
    near_filter(zones_7h,  bull_col_7h,  bear_col_7h,  show_bord_h,   bord_col_h)
    near_filter(zones_12h, bull_col_12h, bear_col_12h, show_bord_h,   bord_col_h)
    near_filter(zones_1d,  bull_col_1d,  bear_col_1d,  show_bord_htf, bord_col_htf)
    near_filter(zones_3d,  bull_col_3d,  bear_col_3d,  show_bord_htf, bord_col_htf)
    near_filter(zones_1w,  bull_col_1w,  bear_col_1w,  show_bord_htf, bord_col_htf)
    near_filter(zones_1M,  bull_col_1M,  bear_col_1M,  show_bord_htf, bord_col_htf)
    near_filter(zones_3M,  bull_col_3M,  bear_col_3M,  show_bord_htf, bord_col_htf)
    near_filter(zones_12M, bull_col_12M, bear_col_12M, show_bord_htf, bord_col_htf)
````
