# Historical Pattern Overlay Pro [ShigemiQuant]

- url: https://www.tradingview.com/script/BGMHkC1D-Historical-Pattern-Overlay-Pro-ShigemiQuant/
- type: indicator
- pine_id: PUB;18d67329da734d11b8c18a32b275969f
- version: 1.0

## Description

[b]Historical Pattern Overlay Pro[/b] searches the chart's own past — and, optionally, up to four other symbols — for the bar windows whose shape best resembles the most recent N bars, then redraws each historical window and the bars that came after it directly on the live price axis. It pairs this multi-analogue overlay with a confidence band, a long-run continuation statistic, an event-aware scan, an intraday session filter, and three confirmed-close alerts. It is a shape-similarity research tool, not a single extrapolated line and not a signal generator.

Most analogue overlays on TradingView either compress a matched window into one smoothed curve, or render an oscillator-style probability. This script does neither. It pins the actual historical shapes onto the present, optionally lets you draw the top 1 to 5 analogues at once, optionally pulls candidates from other symbols rebased to the current axis, optionally filters by intraday session and macro event dates, optionally wraps the projections in a per-bar mean ± k·sigma band, and reports a continuation rate computed only from the resolved snapshots this chart has produced. The visual and the statistic are independent by design — you read the shapes with your eyes, and you read the continuation evidence as a number.

──────────────────────────────────────────────

[b]Originality[/b]

[list]
[*][b]Multi-analogue overlay, Top N selectable 1 to 5.[/b] Most analogue tools commit to a single best match. This script lets you display the 1 to 5 nearest historical analogues simultaneously, each as a full bar-by-bar polyline rebased to the live axis, with per-candidate colours and a Min Gap deduplication so the picks are not stacked on the same centre. Default is Top 3 to make the fan of historical outcomes visible at a glance.
[*][b]Cross-symbol candidate pool (up to four symbols).[/b] When enabled, the search pool is extended with up to four user-defined symbols (defaults: BTCUSDT on Binance, NDX on NASDAQ, USDX on Vantage, plus one optional slot). Cross-symbol matches are rebased to the live chart's price axis so the analogue is readable in the same units as the present, and the labels carry a ticker prefix such as [i]Top1 [BTC] 87.5%[/i] to keep cross-asset analogues identifiable.
[*][b]Session-aware scan (intraday).[/b] An optional session filter restricts the scan to candidate windows whose right edge sits inside a user-defined session window (e.g. [i]0930-1600[/i] for the NY cash session, [i]0800-1700[/i] for Europe, or [i]1700-1700:23456[/i] for an overnight session). Timezone is selectable from a fixed list including [i]America/New_York[/i], [i]Europe/London[/i], [i]Asia/Tokyo[/i] and others, so DST is handled automatically. The filter auto-disables on Daily and higher timeframes with a visible warning label.
[*][b]Macro event exclusion (user-supplied dates).[/b] A comma-separated list of dates ([i]YYYY-MM-DD[/i]) can be entered to skip any candidate window that contains one of those dates. This is a user-maintained list because Pine has no built-in economic-calendar API; the input field is text-area so a dozen or so FOMC / NFP / CPI dates can be pasted in once and reused.
[*][b]Closed-polyline confidence band.[/b] When Top N is 2 or more, the script computes a per-bar mean and standard deviation across the selected projections and draws a single closed polyline forming a [i]mean ± k·sigma[/i] band behind the projection lines. Only same-symbol picks are aggregated into the band — cross-symbol picks are excluded from the band statistics because their rebase scales differ and would distort the standard-deviation units.
[*][b]Confirmed-close alert system, three conditions.[/b] Three alert conditions are exposed at the top level: high-similarity match on Top 1 (threshold configurable in percent), price touching the confidence band on the live bar, and bullish projection direction on Top 1. All three are gated by [i]barstate.isconfirmed and barstate.islast[/i], so a single alert fires once at the close of the current bar and is not retriggered on every intra-bar tick.
[/list]

──────────────────────────────────────────────

[b]Why this combination[/b]

A pure similarity search can find a past window that resembles the present, but the visual match alone does not tell you whether such matches have historically led anywhere. A pure rate statistic, on the other hand, hides the shape — you cannot tell whether the analogue is a clean impulse, a choppy range, or a failed breakout. And a single analogue can be misleading when several nearby candidates point in opposite directions — that fan-of-outcomes is itself information.

This script joins these layers because each one corrects the others' weaknesses:

[list]
[*]The Top N overlay shows you [b]what[/b] the closest historical analogues actually looked like, bar by bar, on the same axis as the live chart.
[*]The confidence band compresses the Top N projections into a per-bar [b]dispersion estimate[/b], so you can see at a glance whether the analogues agree on direction or fan out into a wide envelope.
[*]The Continuation Rate table reports [b]how often[/b], across all resolved Top 1 analogues this chart has produced, the projection direction agreed with the realised move.
[*]The session and event filters let you constrain the analogue pool to comparable regimes, instead of pulling matches from arbitrary market conditions.
[*]The cross-symbol option lets you ask the related question "has [i]any other[/i] market produced a shape like this one, and where did it go from there", without leaving the indicator.
[/list]

Together they form a self-contained read of "these are the closest historical analogues, here is the spread of their outcomes, here is the base rate for analogues like them, and here are the conditions under which the search was made".

──────────────────────────────────────────────

[b]What it does[/b]

[list]
[*]Takes the most recent [i]Lookback Window[/i] closes (default 200) and normalises them so the oldest bar of the window is 100. This removes the absolute price level and leaves the pure shape.
[*]Scans up to [i]History Scan Depth[/i] bars further back (default 3000, capped at 5000) for candidate windows on the chart's own symbol, optionally extended with candidates from up to four other symbols.
[*]Optionally filters candidates so that only windows starting inside the specified intraday session are eligible.
[*]Optionally rejects candidates whose window overlaps any of the user-supplied event dates.
[*]Ranks all eligible candidates by squared-distance to the reference window, applies the Min Gap deduplication, and selects the Top N (default 3, range 1 to 5).
[*]For each picked candidate, draws the full historical window as a thin polyline on the chart, rebased so its last close coincides with the current close.
[*]Extends each picked candidate to the right of the current bar by [i]Projection Length[/i] bars (default 50, capped at 50), using the actual bars that came after the historical match.
[*]When Top N is 2 or more, computes a per-bar mean and sigma across the same-symbol projections and draws a single closed polyline band of mean ± k·sigma behind the projection lines.
[*]Stamps a similarity label at the right edge of each projection ([i]Top1 87.5%[/i]); cross-symbol matches carry an extra ticker tag ([i]Top1 [BTC] 87.5%[/i]).
[*]On every confirmed bar, records a snapshot of the direction implied by the Top 1 same-symbol projection. After [i]Projection Length[/i] bars elapse, the snapshot resolves into a hit / miss, and the rolling statistic is reported in the Continuation Rate table.
[*]Exposes three top-level alert conditions, each gated to fire only once at the close of the current bar.
[/list]

──────────────────────────────────────────────

[b]How it does it[/b]

[list]
[*][b]Reference window.[/b] The most recent [i]Lookback Window[/i] closes are divided by the oldest close in the window and multiplied by 100, producing a normalised series whose first point is exactly 100.
[*][b]Distance metric.[/b] For every eligible candidate window in the scan range, the same normalisation is applied and a sum of squared differences (SSD) is computed bar-by-bar against the reference. The square root of the SSD is treated as the candidate's distance.
[*][b]Scan range.[/b] The most recent eligible candidate ends at [i]Lookback + Projection[/i] bars in the past, so the bars after the match exist and can be drawn forward. The oldest eligible candidate is [i]History Scan Depth[/i] bars further back, subject to the chart's available history and the Pine [i]max_bars_back[/i] limit of 5000.
[*][b]Session filter.[/b] When enabled and the chart timeframe is intraday, the [i]time(timeframe.period, session, timezone)[/i] built-in is evaluated at each candidate's right-edge offset. Candidates whose right-edge bar falls outside the session are skipped. On Daily and higher timeframes the filter is auto-disabled and a red warning label is drawn near the current bar.
[*][b]Event exclusion.[/b] The user-supplied date strings are parsed once on the first bar into integer [i]year*10000 + month*100 + day[/i] keys. For every bar, the chart's [i]year[/i], [i]month[/i], and [i]dayofmonth[/i] are combined into the same form, and a candidate window is rejected if any of its bars matches a listed date. A graceful guard skips the check beyond the [i]max_bars_back[/i] horizon so the scan still runs to its full depth.
[*][b]Cross-symbol pool.[/b] When enabled, up to four [i]request.security[/i] calls are issued with [i]lookahead = barmerge.lookahead_off[/i] and [i]ignore_invalid_symbol = true[/i], wrapped in [i]dynamic_requests = true[/i] so an empty or disabled slot does not trigger a request at all. The same distance and rebase logic is applied per symbol; only the parent chart's session-filter time-axis is consulted to keep the session decision unambiguous.
[*][b]Min Gap deduplication.[/b] When two candidates share the same symbol and their centre bars fall within [i]Min Gap[/i] bars of each other, the lower-ranked one is dropped. This prevents the Top N picks from collapsing onto a single cluster of nearly-identical neighbours.
[*][b]Rebase.[/b] For each picked candidate, the last close of the matched window is mapped to the live current close, and every other bar in the matched window and its projection is multiplied by the same scale factor. The shape is preserved exactly; only the vertical scale is shifted.
[*][b]Similarity score.[/b] The candidate's distance is converted to a percentage in the 0–100 range by [i]max(0, 100 − (distance / sqrt(Lookback)) × 5)[/i] and shown on the right edge of its projection.
[*][b]Confidence band.[/b] At each of the [i]Projection Length[/i] forward bars, the same-symbol picked projections are aggregated into a per-bar mean and sample variance, and the band's upper and lower edges are placed at [i]mean ± k·sigma[/i]. The band is rendered as a single closed polyline so the fill colour, edge colour, and z-order are stable; cross-symbol picks are deliberately excluded from this aggregation because their rebase scales differ and would inflate sigma artificially.
[*][b]Continuation Rate.[/b] On every confirmed bar, if the Top 1 pick is a same-symbol match, a snapshot stores the implied direction ([i]+1[/i] if the projection ends higher than current close, [i]−1[/i] if lower) and the implied magnitude. After [i]Projection Length[/i] confirmed bars have elapsed, the snapshot resolves: it compares the realised return against the implied direction, counts a hit if the signs agree, and the table reports the rolling resolved count, pending count, hit rate, mean realised return, and mean absolute error of the implied magnitude.
[*][b]Alerts.[/b] Three [i]alertcondition[/i] calls are placed at the top level, each guarded by [i]barstate.isconfirmed and barstate.islast[/i] so the condition fires at most once at the close of the current bar. Messages are kept fully constant; thresholds are referenced via "see indicator inputs" rather than embedded dynamically, which lets the alerts compile cleanly under Pine v6's [i]const string[/i] rule.
[*][b]No look-ahead.[/b] All heavy work — the past scan, the deduplication, the drawing, the band, the alerts — is gated by [i]barstate.islast[/i]. Snapshots are written only on confirmed bars, and resolutions only happen after a further [i]Projection Length[/i] confirmed bars have accumulated. There is no [i]lookahead_on[/i] anywhere; the cross-symbol [i]request.security[/i] calls use [i]lookahead = barmerge.lookahead_off[/i] explicitly.
[/list]

──────────────────────────────────────────────

[b]How to use[/b]

[list=1]
[*]Add the indicator to any chart and any timeframe. Defaults (Lookback 200, Projection 50, Scan Depth 3000, Top N 3) are a balanced starting point for swing and intraday work on liquid instruments.
[*]Let enough history load that the scan range is populated. On short charts the analogues sit close to the current bar; on long histories they can be far to the left of the screen.
[*]Read the overlay first. The thin coloured lines on the left half of the chart are the historical analogues; the thicker lines to the right of the current bar are the same analogues' [i]own[/i] subsequent bars, redrawn on the live axis.
[*]Read the [b]Top1 87.5%[/b] / [b]Top2 82.1%[/b] labels at the right edge of the projections. Values close to 100% mean the historical shape sits very close to the present shape in normalised-distance terms.
[*]If the projections fan out into clearly opposite directions, treat that fan as evidence of ambiguity rather than as a target zone. The wider the confidence band, the more disagreement there is across analogues.
[*]Open the [b]Continuation Rate[/b] table (top-right by default; six positions are selectable). Wait for the [i]Resolved[/i] count to reach [i]Min Resolved Samples[/i] (default 10) before reading the numeric rate; below that floor the table shows [i]Insufficient samples[/i] to discourage reading noise.
[*]Once enough samples exist, treat Continuation Rate ≥ 50% as the minimum threshold for "this chart's Top 1 analogues have continued in their projection's direction more often than not". Treat [i]Mean Return[/i] as the average realised move size and [i]MAE[/i] as the average absolute discrepancy between the implied magnitude and the realised one.
[*]Enable [b]Cross-Symbol Matching[/b] only when the cross symbols are economically related to the chart symbol (e.g. major FX pair vs DXY, US index vs another US index). Labels will gain a ticker tag so cross-asset analogues are visually identifiable.
[*]On intraday charts, enable [b]Session Filter[/b] if you want to compare like with like (e.g. only NY-cash-session analogues for a US-equity chart). Leave it off if you want every available analogue.
[*]Enable [b]Exclude Event Dates[/b] if you want to skip windows that contain known macro releases, and paste the relevant dates ([i]YYYY-MM-DD[/i], comma-separated) into the text area. The list is user-maintained because Pine has no built-in economic-calendar API.
[*]For alerts, tick the alert checkbox in the inputs, then add an alert from the chart UI on this indicator, select the corresponding condition, and set [b]Once Per Bar Close[/b]. The condition is already gated to confirmed-close-on-last-bar, but [i]Once Per Bar Close[/i] provides a second safety net.
[*]Use the overlay as context, not as a trigger. The projection is a redrawn historical sequence, not an order or a target. Always combine with your own entry method, position sizing, and stop placement.
[/list]

──────────────────────────────────────────────

[b]Inputs reference[/b]

[list]
[*][b]Lookback Window[/b] (default 200, range 10–300) — number of recent bars used as the reference shape.
[*][b]Projection Length[/b] (default 50, range 5–50) — number of bars drawn to the right of the current bar, taken from the bars that followed each historical match.
[*][b]History Scan Depth[/b] (default 3000, range 500–5000) — maximum number of historical bars to scan for candidate windows.
[*][b]Top N Matches[/b] (default 3, range 1–5) — number of best matches displayed. Confidence band requires N ≥ 2.
[*][b]Min Gap Between Matches[/b] (default 100, minimum 1) — minimum bar distance between selected match centres on the same symbol.
[*][b]Top1–Top5 Color[/b] — per-rank line colour for the analogues and their projections.
[*][b]Show Similarity Label[/b] (default On) — toggles the per-projection similarity label.
[*][b]Enable Cross-Symbol Matching[/b] (default Off) — when On, the search pool is extended with the four cross symbols below.
[*][b]Cross Symbol 1–4[/b] — user-selectable symbols. Leave a slot empty to disable it.
[*][b]Cross Bars per Request[/b] (default 2000, range 500–5000) — [i]calc_bars_count[/i] for the cross-symbol [i]request.security[/i] calls.
[*][b]Session Filter[/b] (default Off) — restricts the scan to candidates whose right-edge bar lies inside the session window. Auto-disabled on Daily+.
[*][b]Session window[/b] (default [i]0930-1600[/i]) — [i]HHMM-HHMM[/i] with optional [i]:1234567[/i] day suffix.
[*][b]Session Timezone[/b] (default [i]exch[/i]) — fixed list including [i]exch / UTC / America/New_York / America/Chicago / Europe/London / Asia/Tokyo / Australia/Sydney[/i].
[*][b]Exclude Event Dates[/b] (default Off) — when On, candidates whose window contains any of the listed dates are skipped.
[*][b]Event Dates[/b] (text area, [i]YYYY-MM-DD[/i] comma-separated).
[*][b]Show Confidence Band[/b] (default On).
[*][b]Band Width (sigma multiplier)[/b] (default 2.0, range 0.5–3.0 step 0.5).
[*][b]Band Fill / Band Edge[/b] — fill and outline colours of the band.
[*][b]Show Continuation Rate Table[/b] (default On).
[*][b]Table Position[/b] (default Top Right) — six positions selectable.
[*][b]History Size (snapshots)[/b] (default 100, range 10–500) — FIFO snapshot retention.
[*][b]Table Text Size[/b] (default Small) — Tiny / Small / Normal.
[*][b]Min Resolved Samples[/b] (default 10, range 5–50) — sample-count floor for numeric display.
[*][b]High Similarity Threshold (%)[/b] (default 80.0, range 50–99 step 1.0).
[*][b]Alert on High Similarity / Band Touch / Bullish Projection[/b] — three independent toggles, all gated to confirmed-close-on-last-bar.
[/list]

──────────────────────────────────────────────

[b]Reading the Continuation Rate table[/b]

[list]
[*][b]Resolved[/b] — number of Top 1 same-symbol snapshots whose [i]Projection Length[/i] follow-up window has fully elapsed.
[*][b]Pending[/b] — snapshots still inside their follow-up window.
[*][b]Continuation Rate[/b] — share of resolved snapshots where the projection's sign matched the realised return's sign. Green when ≥ 50%, orange when below, grey until enough samples accumulate.
[*][b]Mean Return[/b] — average realised return across the resolved follow-up windows.
[*][b]MAE[/b] — mean absolute error between the implied magnitude (projection's final return implied by the matched window) and the realised return.
[*][b]Disclaimer[/b] — [i]Retrospective only, no future guarantee.[/i]
[/list]

──────────────────────────────────────────────

[b]Limitations[/b]

[list]
[*]The shape search is based on squared distance over normalised closes. It does not consider volume, volatility regime, market microstructure, or any signal beyond price shape.
[*]Two windows can match very closely in shape while sitting in completely different market regimes; the session filter and event-exclusion list are partial mitigations, not guarantees.
[*]The Continuation Rate is computed from snapshots accumulated during the current chart session. Reloading the chart, switching timeframes, or changing inputs resets the snapshot history.
[*]Pine's [i]max_bars_back[/i] is 5000; the scan cannot reach past that horizon. Event-exclusion checks beyond the horizon are skipped gracefully.
[*]Cross-symbol [i]request.security[/i] calls are subject to TradingView plan limits on the number of security calls; the script uses up to four such calls plus the chart's own series.
[*]Rebase keeps the analogues readable on the live axis but does not adjust for volatility-scale differences between the historical period and now. The same vertical distance on the chart can correspond to very different percentage moves.
[*]A high similarity percentage means the shapes are close in normalised-distance terms only. It does not imply that the same outcome will repeat.
[/list]

──────────────────────────────────────────────

[b]No Repaint[/b]

All scan results, projections, the confidence band, the Continuation Rate table, and the alert conditions are computed under [i]barstate.islast[/i] and [i]barstate.isconfirmed[/i]. Snapshots are taken only on confirmed bars and resolved only when [i]Projection Length[/i] additional confirmed bars exist. Cross-symbol requests use [i]lookahead = barmerge.lookahead_off[/i]. No [i]lookahead_on[/i] anywhere.

──────────────────────────────────────────────

[b]Disclaimer[/b]

This indicator is a retrospective visualisation and statistic tool. It does not place orders, does not estimate future returns, and does not guarantee any outcome. The overlays show what the closest historical analogues on this chart actually did; the band shows the dispersion across those analogues; the table reports how often past Top 1 analogues continued in their projection's direction. Past behaviour does not indicate future results. Trade decisions, position sizing, and risk acceptance remain entirely the user's responsibility. Always combine with your own analysis and proper risk management.

By ShigemiQuant.

## Source Code

````pine
// @version=6
// Historical Pattern Overlay (HPO) - Pro v2.0 Phase 3 (Complete)
// Base: HPO_Pro_v2.0_phase2.pine (480 lines)
// Phase 3 changes: Cross-Symbol Matching / Event Date Exclusion / Alert Conditions
// Spec: dev/Historical_Pattern_Overlay/HPO_Pro_Spec_v2.md (internal reference; original filename in Japanese omitted for global publish)
// =============================================================================
// Historical Pattern Overlay (HPO) Pro v2.0 - Phase 3 (Complete, all 8 features)
// Created: 2026-05-17
// Change history (PMP v1.x -> HPO Pro v2.0):
//   v1.0   Initial MVP (formerly Pattern Match Overlay)
//   v1.0.1 hotfix: max_bars_back 5000 upper-bound constraint handling
//   v1.1   time-based drawing + past-match overlay (reverted in v1.2 due to runtime issues)
//   v1.2   Removed polyline; full rewrite to line + bar_index based drawing (ATR Plotter style)
//   v1.3   Past matches drawn thinner/lighter (width=1, alpha=60); Lookback default 30->100/max 100->300; past-side step decimation introduced
//   v1.4   Past matches drawn as a single polyline.new (xloc.bar_index) at full resolution; step decimation removed
//   v2.0 Phase 1  Renamed to HPO Pro. Top N opened up from 1 to 5; UI label "Forecast"->"Projection"; indicator() declaration extended
//   v2.0 Phase 2  Feature 4 Session Filter / Feature 6 Confidence Band / Feature 8 Continuation Rate Table
//   v2.0 Phase 3  Feature 3 Cross-Symbol (R1 recommended: request.security + UDT CrossBar + lookahead_off + calc_bars_count)
//                 Feature 5 Macro Event Exclusion (R1 plan A: text_area + str.split + M5 guard branching (a))
//                 Feature 7 Alerts (M2 redesign: single confirmed-fire on last bar + "Once Per Bar Close" guidance)
//   Hotfix1 (2026-05-17): CE10123 fix - alertcondition message converted to fully const string
//                         (Removed str.tostring(alertSimThr) concat from #1 High Similarity; #2/#3 were already const string, comments only)
//   Hotfix2 (2026-05-17): UDT na guard - fixed crash on .close access when cb1-4 were na under ignore_invalid_symbol/bar 0
//                         (cb1c-cb4c extraction changed to na(cb*) ? na : cb*.close; existing na guards in scan/draw paths auto-skip)
//   Hotfix3 (2026-05-17): runtime error 'step must be > 0' fix - for t = forecastLen to 1 by -1 -> removed "by -1" (in Pine v6 "by" must be positive; from>to auto-descends)
//   Hotfix4 (2026-05-17): Suppress TV UI "Invalid symbol" popup - getCross() switched to conditional invocation gated by crossSymOn + str.length(sym)>0 (supported in v6 under dynamic_requests=true)
//   Hotfix5 (2026-05-17): Invalid symbol root fix - crossSym3 default "FX:USDX" -> "VANTAGE:USDX" (FX:USDX is unavailable on some TV plans; VANTAGE:USDX is broadly accessible, confirmed on user device)
//   Hotfix6 (2026-05-17): User-requested adjustments - (1) Lookback default 100->200 / (2) Projection default 20->50 / (3) Added 6-position Table Position selector (including Middle Right) / (4) All input tooltips translated to English (TV global market standard, priority A feedback_tv_house_rules_compliance)
// Purpose: Top 1-5 historical-similarity pattern search across the chart symbol plus up to 4 cross symbols, with past-match overlay and future projection drawing,
//          a confidence band, continuation-rate statistics, and three confirmed-last-bar alerts.
// Phase 3 stage: cross symbols contribute only to the search pool. They are excluded from Stats/Band aggregation (M4).
// =============================================================================

// Pro v2.0 Phase 1: indicator() declaration updated (new title / max_polylines_count 50->100 / max_labels_count 50->100 / dynamic_requests explicit)
// Pro v2.0 Phase 4 (publish, 2026-05-22): Title changed to "Historical Pattern Overlay Pro [ShigemiQuant]" (to avoid duplicate-with-Lite-v1, per R4/R5 audit conclusion)
//                                          shorttitle "HPO" -> "HPO Pro" (legend readability when coexisting with Lite on the same chart, user-confirmed)
indicator("Historical Pattern Overlay Pro [ShigemiQuant]", "HPO Pro", overlay = true, max_lines_count = 500, max_labels_count = 100, max_polylines_count = 100, max_bars_back = 5000, dynamic_requests = true)  // R1 recommended: true is v6 default, but kept explicit for readability

// Pro v2.0 Phase 2: enum tz / UDT Snapshot must be declared at top level (not inside functions/blocks)
// R2 section 3.1: directly adopts the official enum example pattern
enum tz
    exch = ""                         // exchange default
    utc  = "UTC"
    ny   = "America/New_York"
    chi  = "America/Chicago"
    lon  = "Europe/London"
    tok  = "Asia/Tokyo"
    syd  = "Australia/Sydney"

// Pro v2.0 Phase 2: UDT Snapshot (for Feature 8 hit-rate tracking)
// R2 section 4.2 recommended field layout. Holds bar_index/close at anchor time and the resolved state after the target bar is reached.
type Snapshot
    int   anchorBarIndex
    float baselinePrice
    int   forecastDir      // +1 / -1 / 0
    float forecastMag      // Projection magnitude after forecastLen bars (baseline 1.0)
    int   targetBarIndex   // anchorBarIndex + forecastLen
    bool  resolved
    float actualReturn     // Realized return (valid only when resolved)

// Pro v2.0 Phase 3: UDT CrossBar (for Feature 3 Cross-Symbol)
// R1 recommended: bundling OHLC into a UDT in a single call avoids the 127-element tuple cap
// Currently only the close field is used (UDT wrapped to leave room for future OHLC expansion)
type CrossBar
    float close

// ---- Inputs --------------------------------------------------------------
// Compute load scales with Lookback * History Scan Depth, so maxima are kept conservative
// Hotfix6: Lookback default 100 -> 200 (user request)
lookback     = input.int(200,  "Lookback Window",         minval = 10,  maxval = 300,   tooltip = "Reference window length. The most recent N close-price bars are used as the pattern to compare against history.")
// Pro v2.0 Phase 1: UI label "Forecast Length" -> "Projection Length" (TV House Rules NIT10)
// Hotfix6: Projection default 20 -> 50 (user request)
forecastLen  = input.int(50,   "Projection Length",       minval = 5,   maxval = 50,    tooltip = "Number of bars to overlay after each historical match as a projection path to the right of the current bar.")
scanDepth    = input.int(3000, "History Scan Depth",      minval = 500, maxval = 5000,  tooltip = "Maximum number of historical bars to scan. Larger values improve precision but increase compute load.")
// Pro v2.0 Phase 1: Top N maxval 3 -> 5 opened up
topN         = input.int(3,    "Top N Matches",           minval = 1,   maxval = 5,     tooltip = "Number of top similarity matches to display (1-5).")
minGap       = input.int(100,  "Min Gap Between Matches", minval = 1,                   tooltip = "Duplicate-match exclusion gap. Any candidate within N bars of an already selected match center is skipped (a value close to Lookback is recommended).")

color1       = input.color(color.orange,  "Top1 Color")
color2       = input.color(color.aqua,    "Top2 Color")
color3       = input.color(color.yellow,  "Top3 Color")
// Pro v2.0 Phase 1: color4 / color5 added (Top N expansion). lime / fuchsia chosen so they remain distinguishable from the original v1.4 palette
color4       = input.color(color.lime,    "Top4 Color")
color5       = input.color(color.fuchsia, "Top5 Color")
showLabel    = input.bool(true, "Show Similarity Label", tooltip = "Show the similarity percentage label at the right edge of each projected match.")

// Pro v2.0 Phase 3: Cross-Symbol (Feature 3, R1 recommended)
// dynamic_requests=true + input.symbol x 4 + lookahead_off + calc_bars_count
// Empty string = unused (each slot is skipped individually). When useCrossSym=false, getCross() itself is still invoked for every cross
// (Pine v6 dynamic_requests does not short-circuit and always calls), but the result is not pushed into the candidate pool.
crossSymOn   = input.bool(false,                  "Enable Cross-Symbol Matching", group = "Cross-Symbol", tooltip = "Include historical patterns from other symbols in the search pool. Drawings are rebased onto the current chart's price axis.")
crossSym1    = input.symbol("BINANCE:BTCUSDT",    "Cross Symbol 1",               group = "Cross-Symbol")
crossSym2    = input.symbol("NASDAQ:NDX",         "Cross Symbol 2",               group = "Cross-Symbol")
crossSym3    = input.symbol("VANTAGE:USDX",       "Cross Symbol 3",               group = "Cross-Symbol")
crossSym4    = input.symbol("",                   "Cross Symbol 4 (optional)",    group = "Cross-Symbol", tooltip = "Leave empty to disable this slot.")
crossCalcBars = input.int(2000, "Cross Bars per Request", minval = 500, maxval = 5000, group = "Cross-Symbol", tooltip = "calc_bars_count for request.security. Smaller values are faster, larger values reach further into history.")

// Pro v2.0 Phase 2: Session Filter (Feature 4, R2 recommended)
// In the scan loop, each candidate bar offset e is skipped when time(timeframe.period, sessStr, sessTzStr)[e] is na
// (Phase 3 spec fix: the session filter is judged on the chart-symbol time only. Cross-symbol candidates follow the chart's time[e]:
//  while the chart is inside the session window, cross candidates are also eligible.)
sessFilterOn = input.bool(false,        "Session Filter",                      group = "Session Filter", tooltip = "When enabled, only patterns starting within the specified session window are scanned (chart symbol time basis).")
sessStr      = input.session("0930-1600", "Session window (HHMM-HHMM, optional :1234567 days)", group = "Session Filter", tooltip = "Examples: 0930-1600 / 0800-1700 / 1700-1700:23456 (overnight).")
sessTzEnum   = input.enum(tz.exch,      "Session Timezone",                    group = "Session Filter", tooltip = "Timezone used to interpret the session window (exch = exchange default).")

// Pro v2.0 Phase 3: Event Exclusion (Feature 5, R1 plan A: user manual input)
// Pine v6 has no dedicated economic-calendar event-date function (R1 section 1.2).
// request.economic() returns numeric time series and cannot capture e.g. "FOMC with no rate change", so the only reliable solution is manual user input.
eventFilterOn   = input.bool(false, "Exclude Event Dates", group = "Event Exclusion", tooltip = "When enabled, candidate windows that contain any of the specified dates are excluded from the scan.")
eventDatesCsv   = input.text_area("", "Event Dates (YYYY-MM-DD, comma)", group = "Event Exclusion", tooltip = "User-supplied. See TV Economic Calendar to populate. Example: 2026-06-18,2026-07-30")

// Pro v2.0 Phase 2: Confidence Band (Feature 6, R3 strongly recommended plan C-1)
showBand     = input.bool(true,                            "Show Confidence Band",                          group = "Confidence Band", tooltip = "Draw a semi-transparent blue band showing per-bar mean +/- k*sigma of the Top N projections (rendered behind the Top N lines).")
bandSigmaK   = input.float(2.0,                            "Band Width (sigma multiplier)",                 minval = 0.5, maxval = 3.0, step = 0.5, group = "Confidence Band", tooltip = "Half-width of the band = this multiplier x cross-match standard deviation (e.g. 2.0 = +/- 2 sigma).")
bandFillColor = input.color(color.new(color.blue, 85),     "Band Fill",                                     group = "Confidence Band", tooltip = "Fill color of the band interior (alpha 80-90 recommended).")
bandEdgeColor = input.color(color.new(color.blue, 60),     "Band Edge",                                     group = "Confidence Band", tooltip = "Color of the band outline.")

// Pro v2.0 Phase 2: Pattern Continuation Stats (Feature 8, R2 recommended plan B "Historical Pattern Continuation Rate")
// Hotfix6: statsTablePos input added (6-position selector, including Middle Right)
showStats        = input.bool(true,    "Show Continuation Rate Table",                       group = "Statistics", tooltip = "Show the historical Top 1 match continuation rate table on the chart.")
statsTablePos    = input.string("Top Right", "Table Position", options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = "Statistics", tooltip = "Position of the Continuation Rate table on the chart.")
statsHistorySize = input.int(100,      "History Size (snapshots)",   minval = 10, maxval = 500, group = "Statistics", tooltip = "Maximum number of Snapshot records retained in FIFO order.")
statsTableSize   = input.string("Small", "Table Text Size",          options = ["Tiny", "Small", "Normal"], group = "Statistics", tooltip = "Font size of the table text.")
minSamplesForStats = input.int(10,     "Min Resolved Samples",       minval = 5, maxval = 50, group = "Statistics", tooltip = "Until this many resolved samples accumulate, the table shows 'Insufficient samples' instead of a numeric value.")

// Pro v2.0 Phase 3: Alerts (Feature 7, M2 redesign)
// alertcondition must be placed at top level. The condition includes barstate.isconfirmed and barstate.islast to restrict firing to a single confirmed last-bar event.
// User guidance via description: "Set alert to 'Once Per Bar Close' to avoid intra-bar duplicate firing."
alertSimThr      = input.float(80.0, "High Similarity Threshold (%)", minval = 50.0, maxval = 99.0, step = 1.0, group = "Alerts", tooltip = "Threshold for the High Similarity alert. The alert fires when the Top 1 similarity is greater than or equal to this value.")
alertHighSimOn   = input.bool(false, "Alert on High Similarity",                                                   group = "Alerts", tooltip = "Fire an alert once at confirmed bar close on the last bar when the Top 1 similarity is greater than or equal to the threshold.")
alertBandTouchOn = input.bool(false, "Alert on Band Touch",                                                         group = "Alerts", tooltip = "Fire an alert once at confirmed bar close on the last bar when the current close is inside the confidence band (mean +/- k*sigma).")
alertBullishOn   = input.bool(false, "Alert on Bullish Projection",                                                 group = "Alerts", tooltip = "Fire an alert once at confirmed bar close on the last bar when the Top 1 projection direction is bullish.")

// Pro v2.0 Phase 2: enum -> string conversion (for passing to time())
sessTzStr = str.tostring(sessTzEnum)

// Pro v2.0 Phase 2: statsTableSize -> size.* map (NIT5; fits Pine v6 single-line constraint via a 3-way ternary)
tblTextSize = statsTableSize == "Tiny" ? size.tiny : statsTableSize == "Normal" ? size.normal : size.small

// Hotfix6: statsTablePos (string) -> position.* (series string) map
// Decision: Pine v6 local reference drawing_utility_functions.md L86 explicitly states
//   "table.new(position, ...) argument position (series string) table position"
// so case A (position accepts a series string) is adopted.
// Case B (pre-declaring 6 tables) is unnecessary; a single table handles dynamic switching.
// As a reinforcement against the "var table position is captured only on first construction" issue,
// table.set_position() is called every time inside barstate.islast
// (this guarantees runtime switching on input change; Pine v6 recompiles on input change, but this is belt-and-suspenders).
tblPositionConst = switch statsTablePos
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Middle Left"  => position.middle_left
    "Middle Right" => position.middle_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    =>                position.top_right  // fallback (options is constrained to 6 values, but kept as a safety net)

// Pro v2.0 Phase 2: Force session filter off on Daily or higher timeframes
// R2 sections 3.5 / 3.6 recommended: intraday session strings are meaningless on daily-or-higher timeframes
bool sessTfTooLarge = timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds("D")
bool sessFilterEffective = sessFilterOn and not sessTfTooLarge

// ---- Pro v2.0 Phase 3: Cross-Symbol series fetch (required at top level) ---------
// R1 recommended pattern: getCross(s) => request.security(s, tf, UDT.new(close), lookahead=barmerge.lookahead_off, calc_bars_count=N)
// lookahead = barmerge.lookahead_off is the default from v3 onward but is set explicitly here
// (this avoids the direct trigger for TV moderation hidden-script flagging; we have 6 prior incidents on record).
// ignore_invalid_symbol=true returns na when the symbol is unavailable (prevents accidents with empty cross slots).
// Hotfix4: Conditional request.* (supported in v6 under dynamic_requests=true) - when enable=false / empty sym, request.security itself is not called, suppressing the TV UI "Invalid symbol" popup.
// R1 section 1.4 excerpt: "Dynamic requests can: Execute within the local scopes of conditional structures, loops, and exported functions"
// if/else form is adopted (both branches return CrossBar so type inference holds; more readable than multi-line ternary, and sidesteps Pine v6 single-line ternary constraint).
getCross(simple string sym, simple bool enable) =>
    if enable and str.length(sym) > 0
        request.security(sym, timeframe.period, CrossBar.new(close), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true, calc_bars_count = crossCalcBars)
    else
        CrossBar.new(na)

// Fetch cross series for all 4 slots (Hotfix4: skips request.security entirely when crossSymOn=false; empty strings such as cross4="" are likewise skipped).
// Existing Hotfix2 guard (na(cb*) ? na : cb*.close) resolves cb*c=na via the CrossBar.new(na) pattern and continues to work.
CrossBar cb1 = getCross(crossSym1, crossSymOn)
CrossBar cb2 = getCross(crossSym2, crossSymOn)
CrossBar cb3 = getCross(crossSym3, crossSymOn)
CrossBar cb4 = getCross(crossSym4, crossSymOn)

// Extract cross close field into a separate series<float> so history-referencing ([]) is possible
// (UDT field [] access works in Pine v6, but a named top-level series improves readability).
// Hotfix2: UDT na guard - request.security(ignore_invalid_symbol=true) returns a fully-na UDT for invalid/empty symbols,
//          and the UDT can also be na on bar 0; direct .close access then crashes with "Cannot access field of na object".
//          A single-line ternary propagates na, and existing na(anchor)/na(c)/na(mc)/na(fc) guards in scan/draw paths auto-skip.
float cb1c = na(cb1) ? na : cb1.close
float cb2c = na(cb2) ? na : cb2.close
float cb3c = na(cb3) ? na : cb3.close
float cb4c = na(cb4) ? na : cb4.close

// ---- Pro v2.0 Phase 3: Event Exclusion (Feature 5, R1 plan A) -------------------
// Persistent var array<int> stores YMD as int "YYYY*10000 + MM*100 + DD" (built once at barstate.isfirst)
var array<int> exclYMD = array.new<int>()

if barstate.isfirst and eventFilterOn and str.length(eventDatesCsv) > 0
    array<string> parts = str.split(eventDatesCsv, ",")
    // "for s in parts" is read-only iteration in Pine v6; no mutation here so it would also work, but indexed loop is used.
    if array.size(parts) > 0
        for sIdx = 0 to array.size(parts) - 1
            string s = str.trim(array.get(parts, sIdx))
            if str.length(s) > 0
                array<string> ymd = str.split(s, "-")
                if array.size(ymd) == 3
                    float yF = str.tonumber(array.get(ymd, 0))
                    float mF = str.tonumber(array.get(ymd, 1))
                    float dF = str.tonumber(array.get(ymd, 2))
                    if not na(yF) and not na(mF) and not na(dF)
                        int yI = int(yF)
                        int mI = int(mF)
                        int dI = int(dF)
                        array.push(exclYMD, yI * 10000 + mI * 100 + dI)

// Per-bar "is this an excluded date?" flag (series bool)
// year/month/dayofmonth are chart-symbol-based built-ins evaluated every bar.
bool isExcludedBar = false
if eventFilterOn and array.size(exclYMD) > 0
    int curYMD = year * 10000 + month * 100 + dayofmonth
    for ymdIdx = 0 to array.size(exclYMD) - 1
        if array.get(exclYMD, ymdIdx) == curYMD
            isExcludedBar := true
            break

// ---- Persistent draw object containers (ATR Plotter style) -------------------
// var line[] / var polyline[] / var label[] pattern. bar_index based drawing follows vertical scale,
// drag, and zoom perfectly. Full deletion every bar, with regeneration at barstate.islast, avoids sticking artifacts.
var line[]     lineArr = array.new_line()
var polyline[] plArr   = array.new<polyline>()
var label[]    lblArr  = array.new_label()
// Pro v2.0 Phase 2: polyline array for the confidence band (Feature 6)
var polyline[] bandArr = array.new<polyline>()
// Pro v2.0 Phase 2: warning label for session TF (single, created only on Daily+ TF with sessFilterOn)
var label[]    warnArr = array.new_label()

// Pro v2.0 Phase 2: Snapshot FIFO + statistics table (Feature 8)
// Hotfix6: The "position" argument of var table is captured only on first construction, but Pine v6 recompiles on input change,
//          so from the user's perspective it behaves correctly. As a belt-and-suspenders measure, table.set_position(tblPositionConst)
//          is also called every bar inside barstate.islast for guaranteed runtime switching.
var array<Snapshot> snapshots = array.new<Snapshot>()
var table hitRateTable = table.new(tblPositionConst, 2, 7, border_width = 1)

// Pro v2.0 Phase 3: Persistent values for alerts (updated on confirmed last bar; referenced by top-level alertcondition)
var float top1Sim     = na     // Top1 similarity (%)
var int   top1DirVar  = 0      // Top1 projection direction (+1 / -1 / 0)
var bool  bandTouch   = false  // Is current close inside the band (mean +/- k*sigma)?

// ---- Helpers --------------------------------------------------------------
// Picks a color independently of topN in a single call (we avoid plot() since dynamic plot color expands draw counts).
pickColor(rank) =>
    switch rank
        0 => color1
        1 => color2
        2 => color3
        3 => color4
        4 => color5

// Pro v2.0 Phase 3: symLabel helper (cross-symbol id -> short ticker string for display)
// 0 = self, 1-4 = cross1-4. Exchange prefixes are not stripped (syminfo.tickerid-style processing skipped); the raw input string is used.
symLabel(symIdx) =>
    switch symIdx
        0 => syminfo.ticker
        1 => crossSym1
        2 => crossSym2
        3 => crossSym3
        4 => crossSym4
        => "?"

// ---- Main: heavy work only on the last bar --------------------------------
// Historical scan is O(Lookback * scanDepth) and expensive, so it is kept inside barstate.islast.
if barstate.islast
    // Delete all existing drawings (sticking prevention; same descending loop as ATR Plotter)
    if array.size(lineArr) > 0
        for i = array.size(lineArr) - 1 to 0
            line.delete(array.get(lineArr, i))
        array.clear(lineArr)
    if array.size(plArr) > 0
        for i = array.size(plArr) - 1 to 0
            polyline.delete(array.get(plArr, i))
        array.clear(plArr)
    if array.size(lblArr) > 0
        for i = array.size(lblArr) - 1 to 0
            label.delete(array.get(lblArr, i))
        array.clear(lblArr)
    // Pro v2.0 Phase 2: Delete band polylines / warning labels (same pattern)
    if array.size(bandArr) > 0
        for i = array.size(bandArr) - 1 to 0
            polyline.delete(array.get(bandArr, i))
        array.clear(bandArr)
    if array.size(warnArr) > 0
        for i = array.size(warnArr) - 1 to 0
            label.delete(array.get(warnArr, i))
        array.clear(warnArr)

    // Pro v2.0 Phase 2: Show warning label on Daily+ TF when sessFilterOn
    if sessFilterOn and sessTfTooLarge
        label warnLb = label.new(bar_index, high, text = "Session Filter disabled on Daily+ timeframes", style = label.style_label_lower_left, color = color.new(color.red, 30), textcolor = color.white, size = size.small)
        array.push(warnArr, warnLb)

    // ---- Reference window normalization (first day = 100) -------------------------------
    // 0 = newest bar, lookback-1 = oldest bar in the window. base[0]..base[lookback-1]
    float baseAnchor = close[lookback - 1]
    array<float> baseNorm = array.new<float>(lookback, na)
    if not na(baseAnchor) and baseAnchor != 0.0
        for i = 0 to lookback - 1
            array.set(baseNorm, i, close[i] / baseAnchor * 100.0)

    // ---- Historical scan ------------------------------------------------------
    // Each candidate window has right-edge offset = e, left-edge offset = e + lookback - 1.
    // To keep forecastLen future bars available to the left of e, the minimum e is lookback + forecastLen.
    int scanStart  = lookback + forecastLen           // Right-edge offset of the newest candidate
    int scanEndMax = scanStart + scanDepth - 1        // Right-edge offset of the oldest candidate
    int availableBars = bar_index                     // Available number of bars (0-indexed)
    int scanEnd    = math.min(scanEndMax, availableBars - (lookback - 1))

    // Pro v2.0 Phase 3 (M5 guard branching (a) adopted):
    // When eventFilterOn=true, isExcludedBar[e+i] access has the e+i <= 5000 constraint (max_bars_back),
    // so beyond e <= 5000 - lookback + 1, isExcludedBar cannot be safely referenced.
    int excludeScanEnd = eventFilterOn ? math.min(scanEnd, 5000 - lookback + 1) : scanEnd

    // Parallel arrays to accumulate candidates (offset, distance, symIdx)
    array<int>   candOffsets = array.new<int>()
    array<float> candDists   = array.new<float>()
    // Pro v2.0 Phase 3: candSymbolIdx parallel array (0 = self, 1-4 = cross)
    array<int>   candSymIdx  = array.new<int>()

    // ---- Self-symbol scan (Phase 1 existing logic + Phase 2 session + Phase 3 event exclusion) ----
    // Self-symbol is always scanned (even when cross is enabled, self remains in the search pool).
    bool canScanSelf = scanEnd >= scanStart and not na(baseAnchor) and baseAnchor != 0.0
    if canScanSelf
        // (a) Up to excludeScanEnd: range where isExcludedBar can be referenced.
        //     When eventFilterOn=false, excludeScanEnd == scanEnd, so this loop alone covers the full range.
        for e = scanStart to excludeScanEnd
            // Session filter (chart-symbol basis; even cross-symbol candidates use the chart's time[e] = spec 3.3 fixed policy)
            bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
            if not candInSession
                continue
            // Event exclusion (Pro v2.0 Phase 3): skip if any isExcludedBar=true bar lies inside the candidate window
            bool windowHasEvent = false
            if eventFilterOn
                for i = 0 to lookback - 1
                    if isExcludedBar[e + i]
                        windowHasEvent := true
                        break
            if windowHasEvent
                continue
            // Distance computation (Phase 1 existing)
            float anchor = close[e + lookback - 1]
            if not na(anchor) and anchor != 0.0
                float dsum = 0.0
                bool  ok   = true
                for i = 0 to lookback - 1
                    float c = close[e + i]
                    if na(c)
                        ok := false
                        break
                    float n = c / anchor * 100.0
                    float b = array.get(baseNorm, i)
                    float d = n - b
                    dsum += d * d
                if ok
                    array.push(candOffsets, e)
                    array.push(candDists,   math.sqrt(dsum))
                    array.push(candSymIdx,  0)
        // (b) Pro v2.0 Phase 3 (M5 guard branching): for e beyond excludeScanEnd, isExcludedBar cannot be referenced
        //     -> skip event-exclusion check (treat as false) and continue normal distance computation.
        if eventFilterOn and excludeScanEnd < scanEnd
            for e = excludeScanEnd + 1 to scanEnd
                bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                if not candInSession
                    continue
                // No isExcludedBar check (windowHasEvent treated as false)
                float anchor = close[e + lookback - 1]
                if not na(anchor) and anchor != 0.0
                    float dsum = 0.0
                    bool  ok   = true
                    for i = 0 to lookback - 1
                        float c = close[e + i]
                        if na(c)
                            ok := false
                            break
                        float n = c / anchor * 100.0
                        float b = array.get(baseNorm, i)
                        float d = n - b
                        dsum += d * d
                    if ok
                        array.push(candOffsets, e)
                        array.push(candDists,   math.sqrt(dsum))
                        array.push(candSymIdx,  0)

    // ---- Pro v2.0 Phase 3: Cross-symbol scan (Feature 3) ------------------
    // The same scan logic as self is inlined for the 4 cross slots (rather than passing series<float> into a Pine v6 function,
    // which requires extra live verification under dynamic_requests; inlining is the safer choice here).
    // Each cross symbol is compared against the self baseNorm (chart-symbol basis). Distance captures shape similarity only;
    // rebase scaling is applied at draw time.
    // If cross anchor fetch fails, the candidate is auto-skipped (na guard).
    // Session filter remains chart-symbol-basis only (spec 3.3 fixed; uses chart's time[e], not the cross symbol's time[e]
    // = simpler design).
    if crossSymOn and canScanSelf
        // cross1
        if str.length(crossSym1) > 0
            // (a) Up to excludeScanEnd
            for e = scanStart to excludeScanEnd
                bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                if not candInSession
                    continue
                bool windowHasEvent = false
                if eventFilterOn
                    for i = 0 to lookback - 1
                        if isExcludedBar[e + i]
                            windowHasEvent := true
                            break
                if windowHasEvent
                    continue
                float anchor = cb1c[e + lookback - 1]
                if not na(anchor) and anchor != 0.0
                    float dsum = 0.0
                    bool  ok   = true
                    for i = 0 to lookback - 1
                        float c = cb1c[e + i]
                        if na(c)
                            ok := false
                            break
                        float n = c / anchor * 100.0
                        float b = array.get(baseNorm, i)
                        float d = n - b
                        dsum += d * d
                    if ok
                        array.push(candOffsets, e)
                        array.push(candDists,   math.sqrt(dsum))
                        array.push(candSymIdx,  1)
            // (b) Beyond excludeScanEnd
            if eventFilterOn and excludeScanEnd < scanEnd
                for e = excludeScanEnd + 1 to scanEnd
                    bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                    if not candInSession
                        continue
                    float anchor = cb1c[e + lookback - 1]
                    if not na(anchor) and anchor != 0.0
                        float dsum = 0.0
                        bool  ok   = true
                        for i = 0 to lookback - 1
                            float c = cb1c[e + i]
                            if na(c)
                                ok := false
                                break
                            float n = c / anchor * 100.0
                            float b = array.get(baseNorm, i)
                            float d = n - b
                            dsum += d * d
                        if ok
                            array.push(candOffsets, e)
                            array.push(candDists,   math.sqrt(dsum))
                            array.push(candSymIdx,  1)
        // cross2
        if str.length(crossSym2) > 0
            for e = scanStart to excludeScanEnd
                bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                if not candInSession
                    continue
                bool windowHasEvent = false
                if eventFilterOn
                    for i = 0 to lookback - 1
                        if isExcludedBar[e + i]
                            windowHasEvent := true
                            break
                if windowHasEvent
                    continue
                float anchor = cb2c[e + lookback - 1]
                if not na(anchor) and anchor != 0.0
                    float dsum = 0.0
                    bool  ok   = true
                    for i = 0 to lookback - 1
                        float c = cb2c[e + i]
                        if na(c)
                            ok := false
                            break
                        float n = c / anchor * 100.0
                        float b = array.get(baseNorm, i)
                        float d = n - b
                        dsum += d * d
                    if ok
                        array.push(candOffsets, e)
                        array.push(candDists,   math.sqrt(dsum))
                        array.push(candSymIdx,  2)
            if eventFilterOn and excludeScanEnd < scanEnd
                for e = excludeScanEnd + 1 to scanEnd
                    bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                    if not candInSession
                        continue
                    float anchor = cb2c[e + lookback - 1]
                    if not na(anchor) and anchor != 0.0
                        float dsum = 0.0
                        bool  ok   = true
                        for i = 0 to lookback - 1
                            float c = cb2c[e + i]
                            if na(c)
                                ok := false
                                break
                            float n = c / anchor * 100.0
                            float b = array.get(baseNorm, i)
                            float d = n - b
                            dsum += d * d
                        if ok
                            array.push(candOffsets, e)
                            array.push(candDists,   math.sqrt(dsum))
                            array.push(candSymIdx,  2)
        // cross3
        if str.length(crossSym3) > 0
            for e = scanStart to excludeScanEnd
                bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                if not candInSession
                    continue
                bool windowHasEvent = false
                if eventFilterOn
                    for i = 0 to lookback - 1
                        if isExcludedBar[e + i]
                            windowHasEvent := true
                            break
                if windowHasEvent
                    continue
                float anchor = cb3c[e + lookback - 1]
                if not na(anchor) and anchor != 0.0
                    float dsum = 0.0
                    bool  ok   = true
                    for i = 0 to lookback - 1
                        float c = cb3c[e + i]
                        if na(c)
                            ok := false
                            break
                        float n = c / anchor * 100.0
                        float b = array.get(baseNorm, i)
                        float d = n - b
                        dsum += d * d
                    if ok
                        array.push(candOffsets, e)
                        array.push(candDists,   math.sqrt(dsum))
                        array.push(candSymIdx,  3)
            if eventFilterOn and excludeScanEnd < scanEnd
                for e = excludeScanEnd + 1 to scanEnd
                    bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                    if not candInSession
                        continue
                    float anchor = cb3c[e + lookback - 1]
                    if not na(anchor) and anchor != 0.0
                        float dsum = 0.0
                        bool  ok   = true
                        for i = 0 to lookback - 1
                            float c = cb3c[e + i]
                            if na(c)
                                ok := false
                                break
                            float n = c / anchor * 100.0
                            float b = array.get(baseNorm, i)
                            float d = n - b
                            dsum += d * d
                        if ok
                            array.push(candOffsets, e)
                            array.push(candDists,   math.sqrt(dsum))
                            array.push(candSymIdx,  3)
        // cross4 (optional; empty string = unused)
        if str.length(crossSym4) > 0
            for e = scanStart to excludeScanEnd
                bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                if not candInSession
                    continue
                bool windowHasEvent = false
                if eventFilterOn
                    for i = 0 to lookback - 1
                        if isExcludedBar[e + i]
                            windowHasEvent := true
                            break
                if windowHasEvent
                    continue
                float anchor = cb4c[e + lookback - 1]
                if not na(anchor) and anchor != 0.0
                    float dsum = 0.0
                    bool  ok   = true
                    for i = 0 to lookback - 1
                        float c = cb4c[e + i]
                        if na(c)
                            ok := false
                            break
                        float n = c / anchor * 100.0
                        float b = array.get(baseNorm, i)
                        float d = n - b
                        dsum += d * d
                    if ok
                        array.push(candOffsets, e)
                        array.push(candDists,   math.sqrt(dsum))
                        array.push(candSymIdx,  4)
            if eventFilterOn and excludeScanEnd < scanEnd
                for e = excludeScanEnd + 1 to scanEnd
                    bool candInSession = sessFilterEffective ? not na(time(timeframe.period, sessStr, sessTzStr)[e]) : true
                    if not candInSession
                        continue
                    float anchor = cb4c[e + lookback - 1]
                    if not na(anchor) and anchor != 0.0
                        float dsum = 0.0
                        bool  ok   = true
                        for i = 0 to lookback - 1
                            float c = cb4c[e + i]
                            if na(c)
                                ok := false
                                break
                            float n = c / anchor * 100.0
                            float b = array.get(baseNorm, i)
                            float d = n - b
                            dsum += d * d
                        if ok
                            array.push(candOffsets, e)
                            array.push(candDists,   math.sqrt(dsum))
                            array.push(candSymIdx,  4)

    // ---- Top N selection (dedup: within +/- minGap of an already-picked center, per symIdx) -
    // Build a distance-ascending index array for sorting.
    // Pro v2.0 Phase 3: Top N is extracted from the merged pool including cross candidates.
    // Dedup is judged within the same symIdx only (different symbols at the same offset are treated as separate patterns).
    int nCand = array.size(candOffsets)
    array<int>   picked       = array.new<int>()  // Picked offsets
    array<float> pickedDist   = array.new<float>()
    array<int>   pickedSymIdx = array.new<int>()  // Pro v2.0 Phase 3: 0=self, 1-4=cross

    if nCand > 0
        array<int> idxSorted = array.sort_indices(candDists, order.ascending)
        int taken = 0
        for k = 0 to array.size(idxSorted) - 1
            if taken >= topN
                break
            int ci = array.get(idxSorted, k)
            int eC = array.get(candOffsets, ci)
            int siC = array.get(candSymIdx, ci)
            int centerC = eC + lookback / 2
            // Conflict check against already-picked (within the same symIdx only)
            bool conflict = false
            if array.size(picked) > 0
                for j = 0 to array.size(picked) - 1
                    int siP = array.get(pickedSymIdx, j)
                    if siP != siC
                        continue
                    int eP = array.get(picked, j)
                    int centerP = eP + lookback / 2
                    if math.abs(centerC - centerP) <= minGap
                        conflict := true
                        break
            if not conflict
                array.push(picked,        eC)
                array.push(pickedDist,    array.get(candDists, ci))
                array.push(pickedSymIdx,  siC)  // Pro v2.0 Phase 3: store cross symIdx
                taken += 1

    int nPicked = array.size(picked)

    // ============================================================================
    // Pro v2.0 Phase 2: Confidence band (Feature 6, R3 plan C-1)
    // ============================================================================
    // (M4) Aggregate only when pickedSymIdx[r] == 0 (self only); skip cross.
    // Pro v2.0 Phase 3: with cross enabled, the M4 guard becomes functionally active (in Phase 2 all entries were 0).
    array<float> meanArr  = array.new<float>(forecastLen, na)
    array<float> sigmaArr = array.new<float>(forecastLen, na)
    if showBand and nPicked >= 2
        for t = 1 to forecastLen
            float sumY  = 0.0
            float sumY2 = 0.0
            int   cnt   = 0
            for r = 0 to nPicked - 1
                // (M4) Aggregate only self picks; skip cross
                if array.get(pickedSymIdx, r) != 0
                    continue
                int eC = array.get(picked, r)
                float matchLastClose = close[eC]
                float curClose = close
                if not na(matchLastClose) and matchLastClose != 0.0 and not na(curClose)
                    float scale = curClose / matchLastClose
                    int fOff = eC - t
                    if fOff >= 0
                        float fc = close[fOff]
                        if not na(fc)
                            float y = fc * scale
                            sumY  += y
                            sumY2 += y * y
                            cnt   += 1
            if cnt >= 2
                float meanV = sumY / cnt
                float varV  = math.max(0.0, sumY2 / cnt - meanV * meanV)
                array.set(meanArr,  t - 1, meanV)
                array.set(sigmaArr, t - 1, math.sqrt(varV))

        // Build band polyline (closed=true unifies outline + fill)
        // Upper side = forward t=1..forecastLen / Lower side = auto-descending t=forecastLen..1 (Pine v6: from>to auto-descends; "by" must be positive)
        // Hotfix3: In Pine v6 "by" must be positive; from>to triggers auto-descending execution (by -1 raises runtime error 'step must be > 0').
        array<chart.point> bandPts = array.new<chart.point>()
        for t = 1 to forecastLen
            float m = array.get(meanArr,  t - 1)
            float s = array.get(sigmaArr, t - 1)
            if not na(m) and not na(s)
                array.push(bandPts, chart.point.from_index(bar_index + t, m + bandSigmaK * s))
        for t = forecastLen to 1
            float m = array.get(meanArr,  t - 1)
            float s = array.get(sigmaArr, t - 1)
            if not na(m) and not na(s)
                array.push(bandPts, chart.point.from_index(bar_index + t, m - bandSigmaK * s))

        if array.size(bandPts) >= 3
            polyline band = polyline.new(bandPts, curved = false, closed = true, xloc = xloc.bar_index, line_color = bandEdgeColor, fill_color = bandFillColor, line_width = 1)
            array.push(bandArr, band)

    // ============================================================================
    // Drawing: past lookback bars (overlaid on the reference window) + future forecastLen bars
    // ============================================================================
    // Distance -> similarity% conversion: normalized by lookback. Treats a 1% average per-point deviation as penalty 1.
    // similarity = max(0, 100 - (d / sqrt(lookback)) * 5)
    //
    // Pro v2.0 Phase 3: cross picks get a [symLabel] prefix on the label for identification.
    //                   Drawing is rebased to the chart-symbol price axis (scale = curClose / matchLastClose_cross).
    if nPicked > 0
        for r = 0 to nPicked - 1
            int eC   = array.get(picked, r)
            float dC = array.get(pickedDist, r)
            int siC  = array.get(pickedSymIdx, r)  // Pro v2.0 Phase 3

            // Pro v2.0 Phase 3: match's last close is fetched from self / cross1-4 depending on symIdx
            float matchLastClose = switch siC
                0 => close[eC]
                1 => cb1c[eC]
                2 => cb2c[eC]
                3 => cb3c[eC]
                4 => cb4c[eC]
            float curClose = close
            if na(matchLastClose) or matchLastClose == 0.0 or na(curClose)
                continue

            // Rebase factor: scale so the match's last value coincides with the current close (cross is also rebased onto chart-symbol price axis)
            float scale = curClose / matchLastClose

            color col = pickColor(r)

            // ---- Past portion: single polyline (full resolution) ----
            // u = 0 -> oldest, u = lookback-1 -> current bar
            array<chart.point> pastPts = array.new<chart.point>()
            bool broke = false
            for u = 0 to lookback - 1
                int xCur = bar_index - (lookback - 1) + u
                int mOff = eC + (lookback - 1) - u
                // Pro v2.0 Phase 3: fetch close from self / cross1-4 depending on symIdx
                float mc = switch siC
                    0 => close[mOff]
                    1 => cb1c[mOff]
                    2 => cb2c[mOff]
                    3 => cb3c[mOff]
                    4 => cb4c[mOff]
                if na(mc)
                    broke := true
                    break
                float yCur = mc * scale
                array.push(pastPts, chart.point.from_index(xCur, yCur))

            // Create past polyline; carry final point over to "prev"
            float prevX = na
            float prevY = na
            bool  hasPrev = false
            if array.size(pastPts) >= 2
                polyline pl = polyline.new(pastPts, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(col, 60), line_width = 1)
                array.push(plArr, pl)
            if array.size(pastPts) > 0
                chart.point lastPastPt = array.get(pastPts, array.size(pastPts) - 1)
                prevX := lastPastPt.index
                prevY := lastPastPt.price
                hasPrev := true

            // ---- Future portion: to the right of the current bar ----
            float lastY = prevY
            int   lastX = int(prevX)
            if not broke
                for s = 1 to forecastLen
                    int fOff = eC - s
                    if fOff < 0
                        break
                    // Pro v2.0 Phase 3: fetch future close depending on symIdx
                    float fc = switch siC
                        0 => close[fOff]
                        1 => cb1c[fOff]
                        2 => cb2c[fOff]
                        3 => cb3c[fOff]
                        4 => cb4c[fOff]
                    if na(fc)
                        break
                    int xCur = bar_index + s
                    float yCur = fc * scale
                    if hasPrev
                        array.push(lineArr, line.new(int(prevX), prevY, xCur, yCur, color = col, width = 2))
                    prevX := xCur
                    prevY := yCur
                    hasPrev := true
                    lastX := xCur
                    lastY := yCur

            // ---- Label ----
            // Pro v2.0 Phase 3: cross picks get a ticker prefix ("Top1 [BTC] 87.5%")
            if showLabel and hasPrev
                float perPoint = dC / math.sqrt(lookback)
                float sim = math.max(0.0, 100.0 - perPoint * 5.0)
                string symTag = siC == 0 ? "" : " [" + symLabel(siC) + "]"
                string txt = "Top" + str.tostring(r + 1) + symTag + " " + str.tostring(sim, "#.0") + "%"
                label lb = label.new(lastX, lastY, text = txt, style = label.style_label_left, color = col, textcolor = color.black, size = size.small)
                array.push(lblArr, lb)

    // ============================================================================
    // Pro v2.0 Phase 3: Update alert-related persistent values (computed once on confirmed last bar)
    // ============================================================================
    // Persist Top1 sim / dir -> referenced by top-level alertcondition.
    // bandTouch is judged by whether the current close lies inside the immediate t=1 band region.
    if nPicked >= 1
        // Top1 sim
        float d1 = array.get(pickedDist, 0)
        float perPoint1 = d1 / math.sqrt(lookback)
        top1Sim := math.max(0.0, 100.0 - perPoint1 * 5.0)
        // Top1 dir: only meaningful for self picks (cross is collapsed to 0 because scale is not consistent)
        int siTop1 = array.get(pickedSymIdx, 0)
        if siTop1 == 0
            int eC0 = array.get(picked, 0)
            float matchLastClose0 = close[eC0]
            float curClose0 = close
            if not na(matchLastClose0) and matchLastClose0 != 0.0 and not na(curClose0)
                float scale0 = curClose0 / matchLastClose0
                int fOff0 = eC0 - forecastLen
                if fOff0 >= 0
                    float fc0 = close[fOff0]
                    if not na(fc0)
                        float forecastPxAlert  = fc0 * scale0
                        float forecastMagAlert = forecastPxAlert / curClose0
                        top1DirVar := forecastMagAlert > 1.0 ? 1 : (forecastMagAlert < 1.0 ? -1 : 0)
                    else
                        top1DirVar := 0
                else
                    top1DirVar := 0
            else
                top1DirVar := 0
        else
            // Skip dir computation for cross picks (keep previous value; bullish alert only fires for self)
            top1DirVar := 0
    // Band-in judgement (assumes showBand=true)
    if showBand and nPicked >= 2
        float mean1  = array.get(meanArr,  0)
        float sigma1 = array.get(sigmaArr, 0)
        if not na(mean1) and not na(sigma1)
            float upper = mean1 + bandSigmaK * sigma1
            float lower = mean1 - bandSigmaK * sigma1
            bandTouch := close <= upper and close >= lower
        else
            bandTouch := false
    else
        bandTouch := false

    // ============================================================================
    // Pro v2.0 Phase 2: Feature 8 hit-rate tracking (R2 recommended)
    // ============================================================================
    // Snapshot push: gated by barstate.isconfirmed to prevent realtime-tick duplication (R2 mandatory note).
    // self-only guard (M4): push only when pickedSymIdx[0] == 0 (becomes effective once Phase 3 cross expansion lands).
    if barstate.isconfirmed and nPicked >= 1
        if array.get(pickedSymIdx, 0) == 0
            int eC0 = array.get(picked, 0)
            float matchLastClose0 = close[eC0]
            float curClose0 = close
            if not na(matchLastClose0) and matchLastClose0 != 0.0 and not na(curClose0)
                float scale0 = curClose0 / matchLastClose0
                int fOff0 = eC0 - forecastLen
                if fOff0 >= 0
                    float fc0 = close[fOff0]
                    if not na(fc0)
                        float forecastPx0  = fc0 * scale0
                        float forecastMag0 = forecastPx0 / curClose0
                        int dir0 = forecastMag0 > 1.0 ? 1 : (forecastMag0 < 1.0 ? -1 : 0)
                        Snapshot sNew = Snapshot.new(anchorBarIndex = bar_index, baselinePrice = curClose0, forecastDir = dir0, forecastMag = forecastMag0, targetBarIndex = bar_index + forecastLen, resolved = false, actualReturn = na)
                        array.push(snapshots, sNew)
                        if array.size(snapshots) > statsHistorySize
                            array.shift(snapshots)  // FIFO

    // Snapshot resolve: finalize realized return after the target bar is reached.
    // Indexed loop + array.set write-back is required (priority B feedback_pine_udt_array_set; learned from 3 sessions of wasted time).
    if array.size(snapshots) > 0
        for i = 0 to array.size(snapshots) - 1
            Snapshot s = array.get(snapshots, i)
            if not s.resolved and bar_index >= s.targetBarIndex
                if not na(s.baselinePrice) and s.baselinePrice != 0.0
                    s.actualReturn := close / s.baselinePrice - 1.0
                    s.resolved := true
                    array.set(snapshots, i, s)  // * array.set is mandatory

    // Aggregation (post-resolve)
    int   totalResolved = 0
    int   hitCount      = 0
    float sumAbsErr     = 0.0
    float sumActual     = 0.0
    if array.size(snapshots) > 0
        for i = 0 to array.size(snapshots) - 1
            Snapshot s = array.get(snapshots, i)
            if s.resolved
                totalResolved += 1
                bool hit = (s.forecastDir == 1 and s.actualReturn > 0) or (s.forecastDir == -1 and s.actualReturn < 0)
                if hit
                    hitCount += 1
                sumAbsErr += math.abs((s.forecastMag - 1.0) - s.actualReturn)
                sumActual += s.actualReturn

    float contRate = totalResolved > 0 ? hitCount * 100.0 / totalResolved : na
    float mae      = totalResolved > 0 ? sumAbsErr * 100.0 / totalResolved : na
    float meanRet  = totalResolved > 0 ? sumActual * 100.0 / totalResolved : na
    int   pending  = array.size(snapshots) - totalResolved

    // Table rendering
    // Hotfix6: dynamic table-position switching (belt-and-suspenders set_position every bar against var table first-construction capture)
    if showStats
        table.set_position(hitRateTable, tblPositionConst)
        table.clear(hitRateTable, 0, 0, 1, 6)
        table.cell(hitRateTable, 0, 0, "Historical Pattern Continuation Rate", text_color = color.white, bgcolor = color.new(color.blue, 60), text_size = tblTextSize)
        table.merge_cells(hitRateTable, 0, 0, 1, 0)
        table.cell(hitRateTable, 0, 1, "Resolved",        text_color = color.silver, text_size = tblTextSize)
        table.cell(hitRateTable, 1, 1, str.tostring(totalResolved), text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 2, "Pending",         text_color = color.silver, text_size = tblTextSize)
        table.cell(hitRateTable, 1, 2, str.tostring(pending),       text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 3, "Continuation Rate", text_color = color.silver, text_size = tblTextSize)
        string rateText = totalResolved < minSamplesForStats ? "Insufficient samples (N<" + str.tostring(minSamplesForStats) + ")" : str.tostring(contRate, "#.0") + "%"
        color  rateColor = totalResolved < minSamplesForStats ? color.gray : (contRate >= 50.0 ? color.lime : color.orange)
        table.cell(hitRateTable, 1, 3, rateText, text_color = rateColor, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 4, "Mean Return",     text_color = color.silver, text_size = tblTextSize)
        string meanText = totalResolved < minSamplesForStats ? "-" : str.tostring(meanRet, "#.00") + "%"
        table.cell(hitRateTable, 1, 4, meanText, text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 5, "MAE",             text_color = color.silver, text_size = tblTextSize)
        string maeText = totalResolved < minSamplesForStats ? "-" : str.tostring(mae, "#.00") + "%"
        table.cell(hitRateTable, 1, 5, maeText, text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 6, "Retrospective only, no future guarantee.", text_color = color.gray, text_size = size.tiny)
        table.merge_cells(hitRateTable, 0, 6, 1, 6)

// ============================================================================
// Pro v2.0 Phase 3: Alerts (Feature 7, M2 redesign)
// ============================================================================
// alertcondition must be placed at top level (Pine v6 hard constraint).
// The condition includes barstate.isconfirmed and barstate.islast to restrict firing to a single confirmed last-bar event.
// User guidance via description (at TV publish): "Set alert to 'Once Per Bar Close' to avoid intra-bar duplicate firing."
//                                                 "Alerts fire only at confirmed bar close, not on historical replay."
// {{plot_0}} removed from message (this indicator does not use plot(); NIT11 addressed).
// Threshold value is statically embedded via str.tostring(alertSimThr) (dynamic sim value display has been dropped).

// 1. High Similarity: Top1 similarity at or above threshold
// Hotfix1: const string conversion (CE10123 fix) - removed str.tostring(alertSimThr) concat; threshold is delegated to indicator inputs.
bool highSimNow = alertHighSimOn and barstate.isconfirmed and barstate.islast and not na(top1Sim) and top1Sim >= alertSimThr
alertcondition(highSimNow, title = "HPO: High Similarity Match", message = "HPO: High similarity match on {{ticker}} {{interval}}. See indicator inputs for threshold.")

// 2. Band Touch: current close inside the band region
// Hotfix1: already const string (CE10123 fix) - never had dynamic concat; message is fully const.
bool bandTouchNow = alertBandTouchOn and barstate.isconfirmed and barstate.islast and bandTouch
alertcondition(bandTouchNow, title = "HPO: Band Touch", message = "HPO: Price touched confidence band edge on {{ticker}} {{interval}}")

// 3. Bullish Forecast: Top1 projection direction is up (meaningful only for self picks; top1DirVar is set to 0 for cross on the compute side)
// Hotfix1: already const string (CE10123 fix) - never had dynamic concat; message is fully const.
bool bullishNow = alertBullishOn and barstate.isconfirmed and barstate.islast and top1DirVar == 1
alertcondition(bullishNow, title = "HPO: Bullish Projection", message = "HPO: Bullish projection detected on {{ticker}} {{interval}}")
````
