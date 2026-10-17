# Day Type Radar [BullByte]

- url: https://www.tradingview.com/script/16q2Ciox-Day-Type-Radar-BullByte/
- type: indicator
- pine_id: PUB;ebf42efdd3634e1e85a623310805d67c
- version: 1.0

## Description

[b]Day Type Radar[/b] is an intraday session classifier. It builds the Initial Balance (IB) and names the session as it develops: [b]Balance, Drive, Trend or Churn[/b].

The IB is the opening range of the session. The script reads what price does around that range and classifies six event types: [b]Drive, Probe-Reject, Accepted Break, Trap, Rotation and Late Expansion.[/b]

Made for intraday charts from 1 minute to 4 hours, with the methodology designed around 1 to 15 minutes, across futures, indices, crypto, forex, stocks, ETFs, CFDs and commodities such as gold and oil.

[b]It is a market-reading tool. It does not place orders and it is not a strategy.[/b]

---

[b]Purpose[/b]

The first question of an intraday session is whether the range edges are holding, or whether a break is developing. Price can change character several times during the same session.

Day Type Radar uses explicit, visible rules to keep that changing context connected. It shows what has happened so far in the session, names the current day type, and keeps a historical ledger of how the script's own event references behaved on the bars loaded on your chart.

---

[b]Why It May Be Useful[/b]

• One glance at the Radar Card shows the current day type and plain-language reading.
• The same event definitions are applied consistently across supported markets. ATR and IB-width normalization scale the measurements to the instrument and session, while Sensitivity changes selected ATR-based distance and size thresholds.
• An Accepted Break is not created by a single outside close. Price must continue closing beyond the IB buffer for the required elapsed time.
• Repeated failed breaks can lock the session as Churn instead of continuing to print break-related events.
• You can review how each event class behaved on your own loaded history.

---

[b]Why It Was Built[/b]

Intraday price can move from an opening drive to an accepted break, from a failed break to rotation, or from repeated failures to churn. The difficulty is not seeing individual events; it is understanding how those events change the character of the session.

Day Type Radar was built around that problem: connect the sequence, keep the developing state visible, and turn changing price behaviour into one readable day-type story.

[image]https://www.tradingview.com/x/jz0GlmlG/[/image]

---

[b]Is This a Mashup? No[/b]

This is one script with one integrated engine. It does not import an external library or merge separate indicators. Standard Pine functions are used for session timing, ATR normalization, rolling price ranges, state tracking and chart presentation.

The event classes share the same session range and session state. The script uses three operating phases, Initial Balance, Balance and Trend, together with a separate Churn lock that can change which events are allowed.

• An Accepted Break changes the session to Trend in that direction.
• Failed breaks are counted and can lock the session as Churn.
• While Churn is locked, new break attempts, Probes, Rotation and Late Expansion are disabled.
• A Drive can establish the directional opening state before the IB is complete.
• The event classes are therefore parts of one connected session model, not separate indicators placed together.

The event rules and state transitions are this script's own implementation of that connected model.

---

[b]What Makes It Different[/b]

• [b]Day naming comes from the sequence of events, not from one signal.[/b] The Radar Card can show a chain such as IB > Drive up > Probe down > Accept up.
• [b]Elapsed-time acceptance.[/b] Acceptance and Trap windows are measured in elapsed minutes and evaluated only on closed bars. The rule is expressed in real time across supported timeframes, while the exact confirmation bar still depends on chart resolution.
• [b]Churn lock.[/b] Repeated failures can change the reading of the whole session instead of producing an unlimited sequence of break events.
• [b]Deterministic session definition.[/b] Session boundaries are determined by the symbol type and your settings. They do not change simply because more historical bars are loaded.
• [b]Adaptive timing with explicit limits.[/b] Some automatic timing values use the longest qualifying measured session length available to the script, with a fallback until a session has been measured. Chart-bar resolution can affect the exact effective timing on higher timeframes.
• [b]Separate event-outcome milestones.[/b] The ledger always keeps [b]Reached 1R[/b] separate from the last outcome measurement. The first outcome column is always 1R. The [b]Outcome to measure (R)[/b] setting changes the last column to Reached 1R, Reached 2R, Reached 3R or Average R.
• [b]Conservative ledger.[/b] Events still open at session end are counted as Observed, not Resolved. If price touches a target milestone and the reference boundary on the same bar, the boundary is treated as first.

When [b]Average R[/b] is selected, the last column shows the average resolved outcome using the 2R reference target: +2R when the target is reached first and -1R when the reference boundary is reached first. The 1R milestone column remains independent.

[b]Background:[/b] "Initial Balance" and day-type concepts are long-standing ideas associated with Market Profile literature. This script uses that vocabulary but does not calculate TPO or volume profiles.

[b]Methodology note:[/b] the Initial Balance, opening-drive, range-extension and day-type concepts come from the broader Market Profile framework. The exact percentages, ATR multipliers, timing rules and event thresholds used here are implementation choices intended to make the framework explicit and consistent across different session lengths and chart resolutions. They are not presented as universal Market Profile rules.

---

[b]How It Works[/b]

[b]1 - Session[/b]

Stocks, funds and indices use the exchange session when Exchange mode is active. In Auto mode, markets configured as anchored markets use a fixed day anchor.

The default Auto anchors are:

• [b]Crypto:[/b] UTC full day.
• [b]Forex and EUREX / ICE Europe symbols:[/b] London 08:00-16:30.
• [b]Other anchored markets, including US index futures, WTI, gold, other futures, commodities and CFDs:[/b] New York 09:30-16:00.

You can force another session mode or anchor in the settings. Custom windows can also be supplied with a selected timezone.

The first loaded session is skipped because it may be partial.

[b]2 - Initial Balance (IB)[/b]

The IB is the high-low range of the first part of the session.

Automatic IB timing targets about 16% of the session, with a nominal 120-minute maximum, a minimum of 3 chart bars and additional chart-bar and session constraints. On the New York anchor this is normally about 60 minutes. On the UTC full-day anchor the nominal automatic IB is 120 minutes.

[b]3 - The six events[/b]

Every event is evaluated only on a confirmed bar.

• [b]Drive.[/b] One evaluation occurs at the Drive checkpoint, targeting about 4% of the session with a nominal 30-minute maximum before chart-bar constraints. A Drive requires sufficient session range in ATR, an opening position near one end of the range and a closing position near the opposite end.

• [b]Probe-Reject.[/b] Price pokes beyond an IB edge by the required minimum distance without closing beyond the full break buffer. The event direction points away from the tested edge. A cooldown prevents immediate repeated probes.

• [b]Accepted Break.[/b] Price closes beyond the IB edge plus the break buffer and continues closing beyond that condition for the configured elapsed time. The default acceptance time is 15 minutes, measured from the first outside close. A registered Accepted Break changes the session to Trend in that direction.

• [b]Trap.[/b] A break attempt closes back to or inside the IB edge within the configured Trap window. The event direction points opposite to the failed break. The default Trap window is 40 minutes from the first outside close.

• [b]Rotation.[/b] While the session is balanced and there is no active break attempt, price reaches one IB edge zone and later reaches the opposite edge zone. The event points back across the IB.

• [b]Late Expansion.[/b] After 60% of the session, the script looks for a compressed base followed by a tall expansion bar. The base must be within the configured fraction of the IB range, the expansion bar must meet the ATR size requirement, the close must finish near the bar's extreme and, when enabled, the close must also exceed the session high or low established before that breakout bar.

[b]4 - Churn lock[/b]

Each failed break increases the failure counter. A failure after an Accepted Break counts double.

At the configured limit, 2 by default, the session locks as [b]Churn[/b]. While locked, new break attempts, Probe-Reject, Rotation and Late Expansion events are disabled.

A decisive close beyond an IB edge by the configured release distance can free the session and reset the failure counter.

[b]5 - Day type name[/b]

Priority is:

[b]Churn > Trend > Drive > Balance[/b]

• [b]Developing:[/b] IB is still forming.
• [b]Open drive:[/b] a Drive has occurred before the IB is complete.
• [b]Balance day:[/b] IB is complete, with no current accepted break or Drive state.
• [b]Drive day:[/b] a Drive has occurred without a current accepted break.
• [b]Trend day up or down:[/b] an Accepted Break is active.
• [b]Churn:[/b] the session is locked.

A failed accepted break removes the Trend state. The session then falls back to its remaining state, such as Drive or Balance.

[b]6 - Limits on new events[/b]

By default, each event class is registered once per session. A final percentage of the session is also used as a cutoff that suppresses new event registration near the session end.

---

[b]How to Read the Chart[/b]

• [b]Shaded zone with two lines:[/b] the Initial Balance. The lines are lighter while the IB is forming and become solid when it is set.
• [b]Zone colour:[/b] amber for IB, grey for Balance, green for Trend up, red for Trend down and magenta for Churn.
• [b]Thin line:[/b] session open price.
• [b]Dotted session box:[/b] surrounds the session and can show the day type, recent event chain, range in ATR, session open time and IB length.
• [b]Text labels:[/b] Drive, Accept, Trap and Late identify events. Up events are placed below their bars and down events above them. Hover for event details.
• [b]Small triangles:[/b] Probe-Reject and Rotation when the minor-event display is set to Dots.
• [b]Colour strip at the bottom:[/b] shows the phase bar by bar.
• [b]Dotted vertical lines:[/b] session start and end lines. UTC full-day mode shows day-start lines only.
• [b]Optional:[/b] IB +/-1x extensions and Churn Lock / Free markers.

---

[b]The Radar Card[/b]

• [b]Title row:[/b] Live, History or Session closed, plus the number of currently unresolved events.
• [b]Large row:[/b] current day type.
• [b]Next row:[/b] the same reading in plain language.
• [b]Info row:[/b] symbol, timeframe, asset type, session mode or anchor and session open time.
• [b]IB row:[/b] IB low-high, IB width in ATR and session range in ATR.
• [b]Chain row:[/b] the last six state/event steps.
• [b]Last row:[/b] the most recent event and its time.
• [b]Event table:[/b] one row per event class.

  [b]Today[/b] = whether this event class fired in the current session in Desktop layout.

  [b]Observed[/b] = registered historical events included in the loaded history. An event still open at session end counts as Observed but not Resolved.

  [b]Resolved[/b] = events for which the selected target or reference boundary was reached first.

  [b]Reached 1R[/b] = percentage of resolved events that reached the first 1R milestone before the reference boundary.

  [b]Last outcome column[/b] = controlled by [b]Outcome to measure (R)[/b]. It can show Reached 1R, Reached 2R, Reached 3R or Average R.

  When a reach option is selected, it shows the percentage of resolved events that reached that target before the reference boundary.

  When [b]Average R[/b] is selected, it shows the average resolved outcome using the 2R reference target.

  The first Reached 1R column is always 1R and does not change with the setting.

  An asterisk and dim text indicate fewer than N resolved events, where N is the configured low-sample threshold. Treat those rows as low-sample observations.

  The [b]All events[/b] row shows totals. Its Today cell is the number of registered events in the current session.

If an event toggle is turned off, that event's row remains visible as off while its chart output, reference levels, ledger counts and alerts are muted. The underlying event logic remains part of the session model.

---

[b]Reference Levels and the Ledger[/b]

For each registered event the script can draw illustrative reference geometry:

• [b]Event price:[/b] the close of the bar that created the event.
• [b]Reference boundary:[/b] the structural level behind the event, such as the IB edge for an Accepted Break. The reference distance is never smaller than the configured ATR floor or 2 ticks.
• [b]R ladder:[/b] the ladder starts at 1R and uses the configured outcome target. The target can be 1R, 2R or 3R. When Average R is selected, the reference geometry remains at 2R.

The ledger evaluates subsequent bars to determine which reference condition was reached first:

• An event cannot resolve on its own bar.
• If a bar touches the reference boundary and a target milestone on the same bar, the boundary is treated as first.
• [b]Reached 1R[/b] is counted only when 1R is reached before the reference boundary.
• [b]Reached selected R[/b] is counted only when the selected target is reached before the reference boundary.
• [b]Average R[/b], when selected, uses the resolved 2R outcome: +2R if the 2R target is reached first, or -1R if the reference boundary is reached first.
• An event still open at session end counts as Observed only and is not counted as Resolved.
• There is no fee, slippage or position-size model. The event price is the signal-bar close.

These are not trade instructions and not strategy results. They describe how the script's own illustrative reference levels behaved on the bars loaded on your chart. They depend on the available historical data and do not predict future results.

[b]Day-Type Stats[/b] are off by default. When enabled, the table measures what happened from each recorded day-type read through the end of that session.

• [b]Remaining range:[/b] the high-low movement recorded from the read bar to session close, expressed in ATR.
• [b]Close beyond IB:[/b] percentage of recorded reads whose session closed outside the IB.
• [b]Follow-through:[/b] for directional reads, percentage where the session close finished on the read's side.
• [b]Extension x IB:[/b] the maximum extension beyond the IB, expressed in IB widths.

Reads can overlap within a session.

On Mobile layout, the Day-Type Stats table is shortened to keep the dashboard compact and omits Follow-through and Extension x IB.

---

[b]Worked Example (Illustrative Numbers, Not a Real Trade)[/b]

Index future, 5-minute chart, New York anchor, Balanced sensitivity, ATR = 6 points.

• [b]09:30-10:30:[/b] the automatic IB forms. IB high 5030, IB low 5000, giving a 30-point range or 5 ATR.

• [b]Edge buffer:[/b] the smaller of 0.25 ATR (1.5) and 12% of the IB (3.6), with the configured 2-tick floor also applied. The effective buffer is 1.5 points, so a close above 5031.5 qualifies as outside.

• A bar closing at 10:50 finishes at 5032. This begins an upside break attempt.

• Price continues closing above the required buffer. The bar closing at 11:05 is 15 minutes after the first outside close, so the break is accepted. An [b]Accept up[/b] event is registered at that close.

• [b]Reference boundary:[/b] IB high at 5030. With a 5036 event price and a 6-point reference distance, the 2R reference level is 5048.

• If 5048 is reached before 5030, the event is counted as Reached 2R. If 5030 is reached first, it is resolved at the reference boundary. If neither is reached before session end, the event remains Observed only.

[b]Alternative path:[/b] if the 10:50 close at 5032 is followed by a close at or below 5030 within the Trap window, the upside break attempt has failed and the resulting event points down as [b]Trap down[/b]. One failure is counted; repeated failures can eventually lock the session as Churn.

---

[b]Real Chart Example[/b]

[b]1. Bitcoin / U.S. Dollar (BTCUSD)[/b], 5-minute chart, Crypto, UTC 00:00 day anchor.

The session establishes its Initial Balance first. Price then closes above the IB high and remains outside for the required acceptance time, creating an [b]Accept up[/b] event. Later, a downside break attempt fails and price closes back inside the IB, creating a [b]Trap up[/b] event.

The chart shows the event's illustrative reference geometry and the current level reached. The Radar Card records the current [b]Balance day[/b] reading, IB and session information, and the event chain. The Event Ledger shows the current session alongside historical observed and resolved event results, while the Day-Type Stats panel shows how previous day-type reads behaved through their session closes.

[image]https://www.tradingview.com/x/LjQ7YzUx/[/image]

[b]2. S&P 500 E-mini Futures (ES1!)[/b], 15-minute chart, Futures, New York 09:30 session.

One session begins with a [b]Drive down[/b], followed by an [b]Accept down[/b], producing a Trend-down read. Repeated failures can then contribute to a [b]Churn / Lock[/b] state. Another session shows [b]Probe-Reject and Rotation[/b] around the IB without an accepted break. The session text and event chain show how these events build the day-type story, while the Day-Type Stats panel records how historical reads behaved through session close.

[image]https://www.tradingview.com/x/CuIg9Non/[/image]

---

[b]Recommended Timeframes and Markets[/b]

• [b]Best fit:[/b] 5m and 15m. These provide enough chart bars for the IB and elapsed-time acceptance rules without the density of very low timeframes.
• [b]1m and 3m:[/b] supported, but naturally produce more chart bars and can appear noisier. Calm sensitivity can be used when fewer events are preferred.
• [b]30m, 1H and 4H:[/b] supported, but there are fewer bars per session, so many event classes will occur less often.
• [b]Markets:[/b] index and commodity futures, indices, stocks and ETFs, crypto, forex and CFDs.
• [b]Standard chart types only:[/b] Candles, Bars, Line and Area. Heikin Ashi, Renko, Kagi, Line Break, Range and Point & Figure are blocked because they use synthetic or transformed price data.

---

[b]Settings[/b]

[b]1 - Session and timing[/b]

• [b]Session mode:[/b] Auto, Exchange session, Day anchor or Custom window.
• [b]Day anchor:[/b] UTC 00:00, Tokyo 09:00, London 08:00 or New York 09:30. Used when the anchor mode is active.
• [b]Custom window and timezone:[/b] define a session window and choose Exchange or UTC for the window timezone.
• [b]Display time zone:[/b] changes displayed times without changing the session logic.
• [b]Initial Balance minutes:[/b] 0 uses automatic timing. Manual values are still constrained by chart-bar and Drive-window rules so the IB cannot collide with the Drive checkpoint.

[b]2 - Sensitivity:[/b] Calm, Balanced or Active. Calm uses 1.5x selected ATR-based distance and size thresholds, Balanced uses 1.0x, and Active uses 0.7x. Time windows and the other structural limits are unchanged.

[b]2b - Event toggles:[/b] individually enable or mute Drive, Probe-Reject, Accepted Break, Trap, Rotation and Late Expansion in the chart output, reference levels, ledger and alerts. The underlying event logic remains connected to the session model.

[b]3 - Event rules:[/b] Accepted Break time, Trap window, Probe distance, break buffer, Drive size and edge tolerance, Rotation edge zone and minimum IB size, Late Expansion compression and bar size, ATR length, Churn lock and release thresholds, final session cutoff, Late Expansion extreme requirement and one-event-per-class behaviour.

[b]4 - Event ledger:[/b] [b]Outcome to measure (R)[/b] can be 1R, 2R, 3R or Average R. The first Radar Card outcome column remains Reached 1R. The last column follows this setting. Average R uses the 2R reference target. Also includes minimum reference distance in ATR, low-sample threshold and optional outcome markers.

[b]5 - Reference levels:[/b] show or hide live reference geometry, show only the latest live event or all unresolved events, and control label distance.

[b]6 - Dashboards:[/b] Desktop or Mobile layout, Radar Card on or off, position and text size, Day-Type Stats on or off, position and text size.

[b]7 - Visuals:[/b] event labels, label size, Probe and Rotation display style, session box and text, Initial Balance zone, session open line, IB extensions, phase ribbon, Churn markers, session start/end lines and colours.

[b]8 - Alerts:[/b] All events or Major only, plus Text or JSON message format.

---

[b]Alerts[/b]

Create one alert on this script and choose the condition [b]Any alert() function call[/b].

Alerts are generated once per confirmed bar when an enabled event is registered.

[b]Text alerts[/b] include the symbol, timeframe, event, direction, day type, event price, reference boundary and the configured R reference level.

[b]JSON alerts[/b] include the symbol, timeframe, event, direction, event price, reference boundary and reference level.

When the outcome setting is [b]Average R[/b], the reference level reported by the alert remains the 2R reference level used by that measurement.

In [b]Major only[/b] mode, Probe-Reject and Rotation alerts are skipped.

JSON format is intended for webhook use.

---

[b]Limitations[/b]

• Events are evaluated on closed bars only. Once registered, event labels are not moved or rewritten. The Radar Card, session box and unresolved reference levels can continue updating as confirmed bars arrive.
• There is built-in confirmation time. Drive is evaluated at its checkpoint, while an Accepted Break requires the configured elapsed time. Nothing here is a prediction.
• On anchored markets, only the selected anchor window is analyzed. For example, with gold on the New York anchor, movement outside 09:30-16:00 New York is not part of that session's reading.
• The ledger and Day-Type Stats depend on the amount of historical bar data loaded on the chart and the plan's available history.
• The first loaded session is skipped. In Exchange or Custom mode, the first analyzed session uses a 390-minute timing fallback until a qualifying session length has been measured.
• Automatic Drive and IB timing is converted to whole chart bars, so the exact effective checkpoint can differ from the nominal percentage or minute description on higher timeframes.
• With extended hours disabled on stocks and indices, there may be no bar outside the regular session for displaying a session-end line or Session closed state. The next session still settles prior open observations.
• Late Expansion measures its compression base from bars immediately preceding the breakout bar. On an early session check, that lookback can therefore include bars from before the current session began.
• TradingView drawing limits can remove older drawings when platform limits are reached. Historical statistics are maintained separately from chart drawings.
• Event toggles can mute chart output, reference levels, ledger counts and alerts for an event class while the underlying event logic remains part of the session model.
• Behaviour changes with timeframe, session definition and Sensitivity. Test the settings on your own markets and data.

---

[b]Disclaimer[/b]

Day Type Radar is an educational market-analysis tool. It is not financial advice and is not a recommendation to buy or sell anything. It does not place orders.

Reference levels, outcome markers and ledger numbers are illustrative calculations based on historical bars. They include no fees, slippage or position sizing, and they do not predict future results.

Trading involves risk of loss. You are responsible for your own decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte

//@version=6
indicator("Day Type Radar [BullByte]", "DTR [BullByte]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ═══════════════════════════════════════════════════════════════════════════════
//  DAY TYPE RADAR  |  Author: BullByte
//
//  IDEA
//  Every session tells a story: the opening move, the Initial Balance (IB),
//  an automatically sized opening range, and what price does at its edges.
//  This tool reads that story live and names the day: Balance, Drive, Trend or Churn.
//
//  CONCEPT
//  A session state machine with three phases (IB > Balance > Trend) and six
//  event classes:
//    Drive           Strong one-way open. Open at one end of the range, close at the other.
//    Probe-Reject    Poke beyond an IB edge without a close outside, then rejection.
//    Accepted Break  Enough closes outside IB + buffer. The break is accepted.
//    Trap            A break that closes back inside the IB within the trap window.
//    Rotation        Edge-to-edge traverse of the IB while balanced.
//    Late Expansion  Late, tall breakout bar from a compressed base.
//  Repeated failed breaks lock the day as "Churn" until a decisive close releases it.
//  Math: all distances are normalised by ATR and by the IB range, so the same
//  rules scale across symbols and volatility regimes. Timings scale with the
//  session length and the chart timeframe.
//
//  HOW TO READ
//  Radar card = day type + event chain. Labels = events. Shaded zone = IB.
//  Event ledger = historical observations and resolved reference-level outcomes from the bars loaded on your chart.
//
//  EVENT CONFIRMATION
//  Event conditions are evaluated only on confirmed bars. Once an event is registered,
//  its label is not moved or rewritten. The live session box, dashboard state and
//  unresolved reference levels are intentionally dynamic. TradingView may remove the oldest drawings when the platform drawing limit is reached.
//
//  LIMITS
//  Intraday 1m–4h standard charts only (built for 1m–15m). Statistics depend on how
//  many bars are loaded. Sessions: stocks, funds, indices use the exchange session.
//  Crypto, forex, CFDs, futures and commodities use a fixed day anchor.
//
//  DISCLAIMER
//  Educational market-analysis tool. Not financial advice and not a trading recommendation.
//  It does not place orders. Event outcome markers and reference R levels are illustrative
//  calculations based on the signal-bar close and bar-range resolution. No fees or slippage
//  are included, and a bar touching both boundaries is handled conservatively. Historical
//  observations do not predict future results. You are responsible for your decisions.
// ═══════════════════════════════════════════════════════════════════════════════

// ───────────────────────────── 1. ENUMS ─────────────────────────────
enum Phase
    closed  = "Closed"
    ib      = "Initial Balance"
    balance = "Balance"
    trend   = "Trend"
enum SigClass
    drive    = "Drive"
    probe    = "Probe-Reject"
    accepted = "Accepted Break"
    trap     = "Trap"
    rotation = "Rotation"
    lateExp  = "Late Expansion"
// ───────────────────────────── 2. TYPES ─────────────────────────────

// One classified event. Created once, never edited except mfe (best excursion in R).
type Signal
    SigClass cls
    int      dir
    int      bi
    float    entry
    float    stop
    float    target
    float    risk
    float    mfe = 0.0

// All per-session state.
type Day
    int    startT       = na
    float  sOpen        = na
    float  sHi          = na
    float  sLo          = na
    float  ibHi         = na
    float  ibLo         = na
    bool   ibDone       = false
    bool   driveChecked = false
    int    driveSide    = 0
    int    acceptedSide = 0
    int    exSide       = 0
    int    exStartT     = na
    float  exExt        = na
    bool   exAcc        = false
    int    lastZone     = 0
    bool   lateFired    = false
    int    nSig         = 0
    int    fails        = 0
    bool   churn        = false
    int    probeT       = na
    string fired        = ""
    Phase  phase

// Observed and resolved event counts per class (feeds the Radar card event ledger).
// Reached 1R and reached selected target are stored separately.
// sumR stores the average resolved outcome when Average R is selected.
type Ledger
    array<int>   observed
    array<int>   resolved
    array<int>   reached1
    array<int>   reached
    array<float> sumR
    array<Signal> live
type ReadRec
    int   kind
    int   dir
    float px
    float atr
    float ibHi
    float ibLo
    float hi
    float lo

// Aggregated session-read observations (feeds the Day-Type Stats table).
type Stats
    array<int>     n
    array<float>   sumRem
    array<int>     beyond
    array<int>     dirN
    array<int>     follow
    array<float>   sumExt
    array<ReadRec> live

// ───────────────────────────── 3. INPUTS ─────────────────────────────
const string G_SES = "1 - Session and timing"
const string G_SEN = "2 - Sensitivity"
const string G_TOG = "2b - Event toggles"
const string G_CLS = "3 - Event rules (advanced)"
const string G_LED = "4 - Event ledger"
const string G_RL  = "5 - Reference levels"
const string G_DB  = "6 - Dashboards"
const string G_VIS = "7 - Visuals"
const string G_AL  = "8 - Alerts"

// 1 · Session and timing
sessMode   = input.string("Auto", "Session mode", options = ["Auto", "Exchange session", "Day anchor", "Custom window"], group = G_SES, tooltip = "Auto: stocks, funds and indices use the exchange session. Crypto, forex, CFDs, futures and commodities (near 24h markets) use a fixed day anchor, so the 'day' is identical on every chart load. The other options force that choice. Exchange session needs a market with a daily break. It is blocked on crypto and spot forex. On other 24h markets it follows the exchange's own session breaks.", display = display.data_window)
anchor24   = input.string("Auto", "Day anchor (24h markets)", options = ["Auto", "UTC 00:00", "Tokyo 09:00", "London 08:00", "New York 09:30"], group = G_SES, tooltip = "Used only when the day anchor is active. Auto: crypto = UTC full day. Forex and EUREX / ICE Europe products (e.g. Brent) = London 08:00. Everything else (US index futures, WTI, gold, other commodities and CFDs) = New York 09:30. Pick manually to use another open.", display = display.data_window)
customSess = input.session("0930-1600", "Custom session window", group = G_SES, tooltip = "Used only in Custom window mode.", display = display.data_window)
customTz   = input.string("Exchange", "Custom window timezone", options = ["Exchange", "UTC"], group = G_SES, tooltip = "Timezone used to read the custom window.", display = display.data_window)
dispTzIn   = input.string("Exchange", "Display time zone", options = ["Exchange", "UTC", "America/New_York", "America/Chicago", "Europe/London", "Europe/Berlin", "Asia/Kolkata", "Asia/Dubai", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Tokyo", "Australia/Sydney"], group = G_SES, tooltip = "Changes only the times shown on the card and under the box. Signal logic never changes.", display = display.data_window)
ibOverride = input.int(0, "Initial Balance minutes (0 = automatic)", minval = 0, group = G_SES, tooltip = "0 = automatic, nominally about 16% of the session and capped at 120 min before chart-bar constraints. Manual values are raised to at least one chart bar and at least the Drive window plus one chart bar.", display = display.data_window)

// 2 · Sensitivity
sens       = input.string("Balanced", "Sensitivity", options = ["Calm", "Balanced", "Active"], group = G_SEN, tooltip = "Calm = tighter ATR-based Drive, Probe, Break-buffer and Late-Expansion size thresholds. Active = looser. Time windows and other structural limits are unchanged.", display = display.data_window)

// 2b · Event toggles
onDrive  = input.bool(true, "Drive", group = G_TOG, tooltip = "Each toggle mutes that event's chart label, reference levels, ledger counts and alerts. The event is still evaluated inside the engine, so the day type, chain and Churn lock can remain consistent. The ledger row is shown as off.")
onProbe  = input.bool(true, "Probe-Reject", group = G_TOG)
onAccept = input.bool(true, "Accepted Break", group = G_TOG)
onTrap   = input.bool(true, "Trap", group = G_TOG)
onRot    = input.bool(true, "Rotation", group = G_TOG)
onLate   = input.bool(true, "Late Expansion", group = G_TOG)

// 3 · Signal rules
acceptMin   = input.int(15, "Accepted Break: minutes outside IB", minval = 5, group = G_CLS, tooltip = "How long price must keep closing outside the IB (beyond the buffer) before the break counts as accepted.", display = display.data_window)
trapMin     = input.int(40, "Trap window (minutes)", minval = 10, group = G_CLS, tooltip = "A break that closes back inside the IB within this time from its first close outside is called a Trap.", display = display.data_window)
pokeATR     = input.float(0.25, "Probe minimum poke (ATR)", minval = 0.0, step = 0.05, group = G_CLS, tooltip = "How far beyond an IB edge price must poke, without closing outside, to count as a probe.", display = display.data_window)
bufATR      = input.float(0.25, "Break buffer beyond IB edge (ATR)", minval = 0.0, step = 0.05, group = G_CLS, tooltip = "A close must be this far beyond the IB edge to count as outside. Filters noise at the edge.", display = display.data_window)
driveATR    = input.float(1.0, "Drive minimum range (ATR)", minval = 0.1, step = 0.1, group = G_CLS, tooltip = "Minimum session range at the Drive checkpoint.", display = display.data_window)
driveEdge   = input.float(0.20, "Drive edge tolerance (fraction)", minval = 0.05, maxval = 0.4, step = 0.05, group = G_CLS, tooltip = "The open must sit in this outer fraction of the range at one end, and the close in the same fraction at the other end.", display = display.data_window)
edgePct     = input.float(0.25, "Rotation edge zone (fraction of IB)", minval = 0.1, maxval = 0.4, step = 0.05, group = G_CLS, tooltip = "Width of the IB edge zones used to detect an edge-to-edge rotation.", display = display.data_window)
minIBATR    = input.float(1.5, "Rotation: minimum IB range (ATR)", minval = 0.5, step = 0.25, group = G_CLS, tooltip = "Rotation is ignored when the IB is narrower than this.", display = display.data_window)
compFrac    = input.float(0.5, "Late Exp: max compression (fraction of IB)", minval = 0.1, step = 0.05, group = G_CLS, tooltip = "The range just before the breakout bar must be tighter than this fraction of the IB.", display = display.data_window)
expATR      = input.float(1.5, "Late Exp: min expansion bar (ATR)", minval = 0.5, step = 0.25, group = G_CLS, tooltip = "The breakout bar must be at least this many ATR tall.", display = display.data_window)
atrLen      = input.int(14, "ATR length", minval = 2, group = G_CLS, tooltip = "ATR length used to normalise every distance.", display = display.data_window)
maxFails    = input.int(2, "Churn lock: failed breaks before lock", minval = 1, group = G_CLS, tooltip = "This many failed breaks lock the day as Churn. A failure after an accepted break counts double.", display = display.data_window)
unlockATR   = input.float(1.0, "Churn release: close beyond edge (ATR)", minval = 0.5, step = 0.25, group = G_CLS, tooltip = "A close this far beyond an IB edge releases the Churn lock.", display = display.data_window)
endCut      = input.int(8, "No new events in last (% of session)", minval = 0, maxval = 30, group = G_CLS, tooltip = "Stops new events near the session end. 0 = off.", display = display.data_window)
lateExtreme = input.bool(true, "Late Exp: must close beyond session high / low", group = G_CLS, tooltip = "Late Expansion must close beyond the session high or low set before the breakout bar.")
oneAndDone  = input.bool(true, "One event per class per session", group = G_CLS, tooltip = "Each class prints once per session. The day type still updates on every state change. The event chain lists printed events plus state markers (IB, Lock, Free).")

// 4 · Ledger

// Controls the measurement shown in the last Radar Card outcome column.
// 1R, 2R and 3R show target-reach percentages. Average R restores the
// average resolved outcome. When Average R is selected, reference geometry
// remains based on 2R so the event still has a concrete resolution target.
outcomeMeasure = input.string("2R", "Outcome to measure (R)", options = ["1R", "2R", "3R", "Average R"], group = G_LED, tooltip = "Changes the last Radar Card outcome column. 1R, 2R or 3R show the percentage of resolved events that reached that target before the reference boundary. Average R shows the average resolved outcome using the 2R reference target. The first Reached 1R column is always 1R. This setting changes only the measurement shown in the last Radar Card column; it does not change event detection.", display = display.data_window)

// Numeric target used by event reference geometry and the selectable reach column.
// Average R uses 2R geometry so its resolved result remains comparable to the
// original Average R measurement.
int finalR = outcomeMeasure == "1R" ? 1 : outcomeMeasure == "3R" ? 3 : 2
float targetR = finalR
bool measureAverage = outcomeMeasure == "Average R"
minRiskATR  = input.float(0.5, "Minimum reference distance (ATR)", minval = 0.1, step = 0.1, group = G_LED, tooltip = "The reference boundary distance is never smaller than this ATR multiple and never smaller than 2 ticks.", display = display.data_window)
minSample   = input.int(20, "Low-sample notice below N", minval = 1, group = G_LED, tooltip = "Rows with fewer resolved events are dimmed and marked with an asterisk.", display = display.data_window)
showOutcome = input.bool(false, "Show outcome markers", group = G_LED, tooltip = "Marks where a completed event reached its reference target or reference boundary first.")

// 5 · R levels
showLadder  = input.bool(true, "Show R levels for live events", group = G_RL, tooltip = "Draws event price, reference boundary and R reference levels for unresolved events. Informational only.")
ladderMode  = input.string("Latest only", "Levels shown for", options = ["Latest only", "All live"], group = G_RL, tooltip = "Latest only keeps the chart clean.", display = display.data_window)
labelOffset = input.int(6, "Label distance from last bar (bars)", minval = 2, maxval = 30, group = G_RL, tooltip = "How far right of the last bar the level labels sit.", display = display.data_window)

// 6 · Dashboards
layout     = input.string("Desktop", "Layout", options = ["Desktop", "Mobile"], group = G_DB, tooltip = "Mobile uses a compact five-column historical outcome table.", display = display.data_window)
showDash1  = input.bool(true, "Radar card", group = G_DB, tooltip = "Day type, event chain, observed events and historical reference-level outcomes.")
d1Pos      = input.string("Top Right", "Radar card position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_DB, display = display.data_window)
d1Size     = input.string("Auto", "Radar card text size", options = ["Auto", "Tiny", "Small", "Normal", "Large"], group = G_DB, display = display.data_window)
showDash2  = input.bool(false, "Day-Type Stats", group = G_DB, tooltip = "Historical observations from each read to the session close. Off by default to keep the chart clean.")
d2Pos      = input.string("Bottom Left", "Day-Type Stats position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_DB, tooltip = "Do not use the same position as the Radar card, or the tables overlap.", display = display.data_window)
d2Size     = input.string("Auto", "Day-Type Stats text size", options = ["Auto", "Tiny", "Small", "Normal", "Large"], group = G_DB, display = display.data_window)

// 7 · Visuals
showLabels     = input.bool(true, "Event labels", group = G_VIS)
lblSize        = input.string(size.small, "Label size", options = [size.tiny, size.small, size.normal], group = G_VIS, display = display.data_window)
minorMode      = input.string("Dots", "Probe and Rotation labels", options = ["Dots", "Text"], group = G_VIS, tooltip = "Dots keep minor events quiet.", display = display.data_window)
showBox        = input.bool(true, "Session box + text under it", group = G_VIS)
narrStyle      = input.string("Story + stats", "Text under the box", options = ["Story + stats", "Tag only", "Off"], group = G_VIS, display = display.data_window)
showIB         = input.bool(true, "Initial Balance zone", group = G_VIS)
showOpen       = input.bool(true, "Session open line", group = G_VIS)
showExt        = input.bool(false, "IB +/-1x extensions", group = G_VIS, tooltip = "Projects the IB range one IB-width above and below.")
showRibbon     = input.bool(true, "Phase ribbon (bottom)", group = G_VIS, tooltip = "Colour strip: IB, Balance, Trend up/down, Churn.")
showChurnMarks = input.bool(false, "Churn lock / free markers", group = G_VIS)
showSessLines  = input.bool(true, "Session start / end lines", group = G_VIS, tooltip = "Thin dotted vertical lines at the session open and close. 24h markets on the UTC full-day anchor show start lines only (one day ends where the next begins). The first loaded session is skipped.")
cSessLine      = input.color(color.new(#9E9E9E, 55), "Session line colour", group = G_VIS)
cDrive  = input.color(#FB8C00, "Drive",          group = G_VIS, inline = "c1")
cProbe  = input.color(#8E24AA, "Probe-Reject",   group = G_VIS, inline = "c1")
cAccept = input.color(#00897B, "Accepted Break", group = G_VIS, inline = "c2")
cTrap   = input.color(#E53935, "Trap",           group = G_VIS, inline = "c2")
cRot    = input.color(#1E88E5, "Rotation",       group = G_VIS, inline = "c3")
cLate   = input.color(#FDD835, "Late Expansion", group = G_VIS, inline = "c3")
cIB     = input.color(#FFB300, "Phase: IB",      group = G_VIS, inline = "p1")
cBal    = input.color(#78909C, "Balance",        group = G_VIS, inline = "p1")
cUp     = input.color(#26A69A, "Trend up",       group = G_VIS, inline = "p2")
cDn     = input.color(#EF5350, "Trend down",     group = G_VIS, inline = "p2")
cChurn  = input.color(#E040FB, "Churn",          group = G_VIS, inline = "p3")

// 8 · Alerts
alertFilter = input.string("All events", "Alert on", options = ["All events", "Major only"], group = G_AL, tooltip = "Major only skips Probe-Reject and Rotation. Create one alert using Day Type Radar > Any alert() function call. Events are emitted on confirmed bar closes.", display = display.data_window)
alertFmt    = input.string("Text", "Alert message format", options = ["Text", "JSON"], group = G_AL, tooltip = "Text for notifications. JSON for webhooks. Both contain symbol, timeframe, event, direction, event price, reference boundary and R reference level.", display = display.data_window)

// ───────────────────────────── 4. CONSTANTS / LOOKUPS ─────────────────────────────
const int N_CLS      = 6
const int MIN_TF_SEC = 60
const int MAX_TF_SEC = 14400
var array<string> NAMES  = array.from("Drive", "Probe-Reject", "Accepted Break", "Trap", "Rotation", "Late Expansion")
var array<string> SHORT  = array.from("Drive", "Probe", "Accept", "Trap", "Rotate", "Late")
var array<color>  COLS   = array.from(cDrive, cProbe, cAccept, cTrap, cRot, cLate)
var array<bool>   ON     = array.from(onDrive, onProbe, onAccept, onTrap, onRot, onLate)
var array<string> RNAMES = array.from("Balance read", "Drive read", "Trend read", "Churn read")
var array<color>  RCOLS  = array.from(cBal, cDrive, cAccept, cChurn)
float sMul   = sens == "Calm" ? 1.5 : sens == "Active" ? 0.7 : 1.0
bool  mobile = layout == "Mobile"

// ───────────────────────────── 5. HELPERS ─────────────────────────────
classIdx(SigClass c) =>
    switch c
        SigClass.drive    => 0
        SigClass.probe    => 1
        SigClass.accepted => 2
        SigClass.trap     => 3
        SigClass.rotation => 4
        SigClass.lateExp  => 5
        => -1

// Readable text colour on any background (luma).
txtCol(color c) =>
    (color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114) > 150 ? color.black : color.white
getPos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right
szOf(string s, bool mob) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => mob ? size.normal : size.small
pct(int a, int b) =>
    b > 0 ? str.tostring(a * 100.0 / b, "0") + "%" : "-"

// Formats the Average R result used by the Radar Card when Average R is selected.
fmtR(float v) =>
    na(v) ? "-" : (v > 0 ? "+" : "") + str.tostring(v, "0.00")

// Builds an event with reference geometry. The boundary is structural, floored at
// minRiskATR * ATR and at 2 ticks. Every level is rounded to the tick, then
// validated: event price, reference boundary and R reference level must be different prices.
// Returns na (event dropped) if the geometry is invalid.
mk(SigClass c, int dir, float stopRaw, float px, float a) =>
    Signal out = na
    float minRisk = math.max(minRiskATR * a, 2 * syminfo.mintick)
    float rawRisk = math.max(math.abs(px - stopRaw), minRisk)
    float stopP   = math.round_to_mintick(px - dir * rawRisk)
    float risk    = math.abs(px - stopP)
    float tgtP    = math.round_to_mintick(px + dir * risk * targetR)
    bool  ok      = not na(risk) and risk >= syminfo.mintick and stopP != px and tgtP != px and tgtP != stopP
    if ok
        out := Signal.new(cls = c, dir = dir, bi = bar_index, entry = px, stop = stopP, target = tgtP, risk = risk)
    out
dayName(Day x) =>
    string out = "Developing"
    if x.ibDone
        if x.churn
            out := "Churn"
        else if x.acceptedSide != 0
            out := "Trend day " + (x.acceptedSide == 1 ? "up" : "down")
        else if x.driveSide != 0
            out := "Drive day " + (x.driveSide == 1 ? "up" : "down")
        else
            out := "Balance day"
    else if x.driveSide != 0
        out := "Open drive " + (x.driveSide == 1 ? "up" : "down")
    out
dayRead(Day x, float ibPct) =>
    string out = "Initial Balance forming | " + str.tostring(ibPct, "0") + "% done"
    if x.ibDone
        if x.churn
            out := "Breakouts failed repeatedly | IB edges are not holding"
        else if x.acceptedSide != 0
            out := "Closes held outside the IB | break accepted"
        else if x.driveSide != 0
            out := "Strong open drive | no active accepted break"
        else
            out := "Price rotating inside the IB | no accepted break"
    else if x.driveSide != 0
        out := "Open drive seen | IB forming | " + str.tostring(ibPct, "0") + "% done"
    out
dayTag(Day x) =>
    string out = "Developing"
    if x.ibDone
        if x.churn
            out := "Churn"
        else if x.acceptedSide != 0
            out := "Trend " + (x.acceptedSide == 1 ? "up" : "down")
        else if x.driveSide != 0
            out := "Drive " + (x.driveSide == 1 ? "up" : "down")
        else
            out := "Balance"
    else if x.driveSide != 0
        out := "Open drive " + (x.driveSide == 1 ? "up" : "down")
    out
phaseCol(Day x) =>
    not x.ibDone ? cIB : x.churn ? cChurn : x.phase == Phase.trend ? (x.acceptedSide == 1 ? cUp : cDn) : cBal
cel(table t, int c, int r, string txt, color tc, color bgc, string ha, string sz) =>
    table.cell(t, c, r, txt, text_color = tc, bgcolor = bgc, text_halign = ha, text_size = sz)

// ───────────────────────────── 6. METHODS ─────────────────────────────

// Start a fresh session.
method reset(Day this, int t, float o, float h, float l) =>
    this.startT       := t
    this.sOpen        := o
    this.sHi          := h
    this.sLo          := l
    this.ibHi         := h
    this.ibLo         := l
    this.ibDone       := false
    this.driveChecked := false
    this.driveSide    := 0
    this.acceptedSide := 0
    this.exSide       := 0
    this.exStartT     := na
    this.exExt        := na
    this.exAcc        := false
    this.lastZone     := 0
    this.lateFired    := false
    this.nSig         := 0
    this.fails        := 0
    this.churn        := false
    this.probeT       := na
    this.fired        := ""
    this.phase        := Phase.ib

// A break attempt begins at the first confirmed close outside the IB buffer. Clears the stale rotation zone.
method begin(Day this, int side, float h, float l, int t) =>
    this.exSide    := side
    this.exStartT  := t
    this.exExt    := side == 1 ? h : l
    this.exAcc    := false
    this.lastZone := 0

// A break attempt ends (failed). Back to Balance. Clears the stale rotation zone.
method finish(Day this) =>
    this.exSide       := 0
    this.exStartT     := na
    this.exAcc        := false
    this.acceptedSide := 0
    this.lastZone     := 0
    if this.phase == Phase.trend
        this.phase := Phase.balance
// Record an event in the historical observation ledger.
// Observed includes events whose observation window ends at session close.
// Resolved includes only events where the reference target or boundary was reached first.
// Reached 1R records the first R milestone; reached records the selected outcome target.
// sumR stores the resolved result used by the Average R dashboard measurement.
method settle(Ledger this, Signal s, bool isResolved, bool didReach1, bool didReach, float resultR) =>
    int k = classIdx(s.cls)
    this.observed.set(k, this.observed.get(k) + 1)
    if isResolved
        this.resolved.set(k, this.resolved.get(k) + 1)
        if didReach1
            this.reached1.set(k, this.reached1.get(k) + 1)
        if didReach
            this.reached.set(k, this.reached.get(k) + 1)
        this.sumR.set(k, this.sumR.get(k) + resultR)

method advance(Ledger this, float h, float l, bool markers, int bi) =>
    int i = this.live.size() - 1
    while i >= 0
        Signal s = this.live.get(i)
        bool alreadyR1 = s.mfe >= 1.0
        float fav = (s.dir == 1 ? h - s.entry : s.entry - l) / s.risk
        s.mfe := math.max(s.mfe, fav)
        bool hitS = s.dir == 1 ? l <= s.stop : h >= s.stop
        bool hitR1 = s.dir == 1 ? h >= s.entry + s.risk : l <= s.entry - s.risk
        bool hitT = s.dir == 1 ? h >= s.target : l <= s.target
        if hitS or hitT
            bool didReach1 = alreadyR1 or (hitR1 and not hitS)
            bool didReach = hitT and not hitS
            float resultR = didReach ? math.abs(s.target - s.entry) / s.risk : -1.0
            this.settle(s, true, didReach1, didReach, resultR)
            if markers
                label.new(bi, didReach ? s.target : s.stop, didReach ? "Target reached" : "Reference boundary", style = label.style_none, textcolor = didReach ? color.teal : color.red, size = size.small)
            this.live.remove(i)
        i -= 1

// Session ended with an event still open: count it as observed but not resolved.
method expire(Ledger this, float px) =>
    while this.live.size() > 0
        Signal s = this.live.pop()
        this.settle(s, false, false, false, 0.0)
method startRead(Stats this, int kind, int dir, float px, float a, float ibHi, float ibLo) =>
    this.live.push(ReadRec.new(kind = kind, dir = dir, px = px, atr = a, ibHi = ibHi, ibLo = ibLo, hi = px, lo = px))
method track(Stats this, float h, float l) =>
    for r in this.live
        r.hi := math.max(r.hi, h)
        r.lo := math.min(r.lo, l)

// At session end, score every open read against the final close.
method settleAll(Stats this, float fc) =>
    while this.live.size() > 0
        ReadRec r = this.live.pop()
        int k = r.kind
        float ibR = math.max(r.ibHi - r.ibLo, syminfo.mintick)
        this.n.set(k, this.n.get(k) + 1)
        this.sumRem.set(k, this.sumRem.get(k) + (r.hi - r.lo) / math.max(r.atr, syminfo.mintick))
        if fc > r.ibHi or fc < r.ibLo
            this.beyond.set(k, this.beyond.get(k) + 1)
        if r.dir != 0
            this.dirN.set(k, this.dirN.get(k) + 1)
            if r.dir * (fc - r.px) > 0
                this.follow.set(k, this.follow.get(k) + 1)
        float ext = r.dir == 1 ? r.hi - r.ibHi : r.dir == -1 ? r.ibLo - r.lo : math.max(r.hi - r.ibHi, r.ibLo - r.lo)
        this.sumExt.set(k, this.sumExt.get(k) + math.max(ext, 0.0) / ibR)

// ───────────────────────────── 7. STATE ─────────────────────────────
var Day d = Day.new(phase = Phase.closed)
var Ledger led = Ledger.new(observed = array.new<int>(N_CLS, 0), resolved = array.new<int>(N_CLS, 0), reached1 = array.new<int>(N_CLS, 0), reached = array.new<int>(N_CLS, 0), sumR = array.new<float>(N_CLS, 0.0), live = array.new<Signal>())
var Stats stats = Stats.new(n = array.new<int>(4, 0), sumRem = array.new<float>(4, 0.0), beyond = array.new<int>(4, 0), dirN = array.new<int>(4, 0), follow = array.new<int>(4, 0), sumExt = array.new<float>(4, 0.0), live = array.new<ReadRec>())
var array<string> story = array.new<string>()
var array<string> beats = array.new<string>()
var color ribbonCol  = na
var box   sBox       = na
var label sLbl       = na
var float lastSessMin = na
var bool  armed      = false
var int   lastConfT  = na
var float sessAtr    = na

// ───────────────────────────── 8. CHART GUARDS ─────────────────────────────

// Synthetic chart types change the prices, so levels and statistics would be wrong.
if not chart.is_standard
    runtime.error("Day Type Radar needs a standard chart type (Candles, Bars, Line, Area). Heikin Ashi, Renko, Kagi, Line Break, Range and Point & Figure change the prices.")
if not timeframe.isintraday or timeframe.in_seconds() < MIN_TF_SEC or timeframe.in_seconds() > MAX_TF_SEC
    runtime.error("Day Type Radar supports intraday charts from 1 minute to 4 hours.")

// ───────────────────────────── 9. ASSET + SESSION RESOLUTION ─────────────────────────────

// The session rule depends only on symbol type and inputs, never on how much history is loaded.
int    tfSec = timeframe.in_seconds()
float  tfMin = tfSec / 60.0
string exTz  = syminfo.timezone
string stype = syminfo.type
string assetName = switch stype
    "stock"     => "Stock"
    "fund"      => "Fund / ETF"
    "dr"        => "Depositary receipt"
    "index"     => "Index"
    "futures"   => "Futures"
    "forex"     => "Forex"
    "crypto"    => "Crypto"
    "cfd"       => "CFD"
    "commodity" => "Commodity"
    => "Other"
bool isMarket24 = stype == "crypto" or stype == "forex" or stype == "cfd" or stype == "futures" or stype == "commodity"
bool euro       = syminfo.prefix == "EUREX" or syminfo.prefix == "ICEEUR"
string anchorKey = anchor24 != "Auto" ? anchor24 : stype == "crypto" ? "UTC 00:00" : (stype == "forex" or euro) ? "London 08:00" : "New York 09:30"
string aSess = switch anchorKey
    "UTC 00:00"    => "0000-2359"
    "Tokyo 09:00"  => "0900-1700"
    "London 08:00" => "0800-1630"
    => "0930-1600"
string aTz = switch anchorKey
    "UTC 00:00"    => "UTC"
    "Tokyo 09:00"  => "Asia/Tokyo"
    "London 08:00" => "Europe/London"
    => "America/New_York"
int aLenMin = switch anchorKey
    "UTC 00:00"    => 1440
    "Tokyo 09:00"  => 480
    "London 08:00" => 510
    => 390
string modeName = sessMode == "Custom window" ? "Custom" : sessMode == "Day anchor" ? "Anchor" : sessMode == "Exchange session" ? "Exchange" : isMarket24 ? "Anchor" : "Exchange"
string tzUse    = modeName == "Custom" ? (customTz == "UTC" ? "UTC" : exTz) : modeName == "Anchor" ? aTz : exTz
string sessStr  = modeName == "Custom" ? customSess : aSess
string dispTz   = dispTzIn == "Exchange" ? exTz : dispTzIn
if modeName == "Exchange" and (stype == "crypto" or stype == "forex")
    runtime.error("Exchange session mode does not work on 24h crypto or spot forex (no daily session break). Use Auto or Day anchor.")

// UTC anchor = a true 24h day: no session string (avoids losing the 23:59 bar). Days split on the date change.
bool fullDay = modeName == "Anchor" and anchorKey == "UTC 00:00"
int sessT = time(timeframe.period, sessStr, tzUse)
bool inSess = modeName == "Exchange" ? session.ismarket : fullDay ? true : not na(sessT)
int dayKey = year(time, tzUse) * 10000 + month(time, tzUse) * 100 + dayofmonth(time, tzUse)
bool newSess = fullDay ? inSess and (not inSess[1] or dayKey != dayKey[1]) : modeName == "Exchange" ? session.isfirstbar_regular : inSess and not inSess[1]
bool sessEnd = fullDay ? false : modeName == "Exchange" ? not inSess and session.islastbar_regular[1] : not inSess and inSess[1]

// ───────────────────────────── 10. ADAPTIVE TIMING + ATR ─────────────────────────────
// Anchor timing is fixed by the selected anchor. Exchange and Custom modes use the longest
// qualifying measured session length so far, with a 390-minute fallback until one is measured.
float fallbackMin = modeName == "Anchor" ? float(aLenMin) : 390.0
float sessMin     = modeName == "Anchor" ? float(aLenMin) : (na(lastSessMin) ? fallbackMin : lastSessMin)

// Drive window targets about 4% of the session, nominally capped at 30 min before chart-bar constraints.
float drvBars = math.max(1.0, math.round(math.min(30.0, sessMin * 0.04) / tfMin))
float drvMin  = drvBars * tfMin

// IB targets about 16% of the session, nominally capped at 120 min before chart-bar constraints,
// with a minimum of 3 bars, a 40% session cap and at least one bar beyond the Drive window.
// and never shorter than the Drive window + 1 bar (so Drive and IB events can never collide).
float ibBarsAuto = math.max(3.0, math.round(math.min(120.0, sessMin * 0.16) / tfMin))
float ibBarsCap  = math.max(1.0, math.floor(sessMin * 0.4 / tfMin))
float ibBars     = math.min(ibBarsAuto, ibBarsCap)
float ibWant     = ibOverride > 0 ? math.max(float(ibOverride), tfMin) : ibBars * tfMin
float ibMin      = math.max(ibWant, drvMin + tfMin)
float lateMin = sessMin * 0.6
int trapMs = int(trapMin * 60000)
int acceptMs = int(acceptMin * 60000)
int ibMs   = int(ibMin * 60000)
int drvMs  = int(drvMin * 60000)
int lateMs = int(lateMin * 60000)
float atrRaw = ta.atr(atrLen)
float trV    = ta.tr(true)
float atrV   = na(atrRaw) ? trV : atrRaw
int   compN  = math.max(2, math.round(ibMin * 60.0 / tfSec))
float cHi    = ta.highest(high, compN)[1]
float cLo    = ta.lowest(low, compN)[1]
chap(string txt) =>
    str.format_time(time_close, "HH:mm", dispTz) + " " + txt

// ───────────────────────────── 11. ENGINE (closed bars only) ─────────────────────────────
Signal sig = na
if barstate.isconfirmed
    // The first loaded session may be partial. Skip it, start from the next full one.
    if newSess and not barstate.isfirst
        armed := true
    // Session boundary: learn session length, settle open signals and reads.
    if sessEnd or newSess
        if d.phase != Phase.closed and not na(d.startT)
            float cand = (time_close[1] - d.startT) / 60000.0
            if cand > 0
                lastSessMin := na(lastSessMin) ? cand : math.max(lastSessMin, cand)
        led.expire(close[1])
        stats.settleAll(close[1])
    if sessEnd
        d.phase := Phase.closed
    if newSess and armed
        d.reset(time, open, high, low)
        story.clear()
        beats.clear()
        if showBox
            sBox := box.new(bar_index, high, bar_index, low, border_color = color.new(cIB, 40), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(chart.fg_color, 95))
            sLbl := label.new(bar_index, low, "", style = label.style_label_upper_left, textalign = text.align_left, textcolor = color.new(chart.fg_color, 25), color = color(na), size = size.small)
    if showSessLines and armed and newSess
        line.new(bar_index, low, bar_index, math.max(high, low + syminfo.mintick), extend = extend.both, color = cSessLine, style = line.style_dotted, width = 1)
    if showSessLines and armed and sessEnd and not fullDay
        line.new(bar_index - 1, low[1], bar_index - 1, math.max(high[1], low[1] + syminfo.mintick), extend = extend.both, color = cSessLine, style = line.style_dotted, width = 1)
    if inSess and armed
        sessAtr := atrV
        led.advance(high, low, showOutcome, bar_index)
        stats.track(high, low)
        float preHi = d.sHi
        float preLo = d.sLo
        d.sHi := math.max(d.sHi, high)
        d.sLo := math.min(d.sLo, low)
        int elapsed = time_close - d.startT
        // ── 1. DRIVE: one evaluation at the checkpoint. Open at one end, close at the other.
        if not d.driveChecked and elapsed >= drvMs
            d.driveChecked := true
            float r = d.sHi - d.sLo
            if r > 0 and r >= driveATR * sMul * atrV
                float pos  = (close - d.sLo) / r
                float oPos = (d.sOpen - d.sLo) / r
                if pos >= 1.0 - driveEdge and oPos <= driveEdge
                    sig := mk(SigClass.drive, 1, d.sLo + 0.5 * r, close, atrV)
                else if pos <= driveEdge and oPos >= 1.0 - driveEdge
                    sig := mk(SigClass.drive, -1, d.sLo + 0.5 * r, close, atrV)
        if not d.ibDone
            d.ibHi := math.max(d.ibHi, high)
            d.ibLo := math.min(d.ibLo, low)
            if elapsed >= ibMs
                d.ibDone := true
                d.phase  := Phase.balance
                story.push(chap("IB set " + str.tostring(d.ibLo, format.mintick) + " - " + str.tostring(d.ibHi, format.mintick)))
                beats.push("IB")
                stats.startRead(d.driveSide != 0 ? 1 : 0, d.driveSide, close, atrV, d.ibHi, d.ibLo)
        else
            float ibR  = d.ibHi - d.ibLo
            float buf  = math.max(2 * syminfo.mintick, math.min(bufATR * sMul * atrV, 0.12 * ibR))
            float poke = math.max(2 * syminfo.mintick, math.min(pokeATR * sMul * atrV, 0.15 * ibR))
            bool  upC  = close > d.ibHi + buf
            bool  dnC  = close < d.ibLo - buf
            bool  upP  = not upC and high >= d.ibHi + poke
            bool  dnP  = not dnC and low <= d.ibLo - poke
            // A decisive close far beyond an IB edge releases the churn lock.
            if d.churn and (close > d.ibHi + unlockATR * atrV or close < d.ibLo - unlockATR * atrV)
                d.churn := false
                d.fails := 0
                beats.push("Free")
                if showChurnMarks
                    label.new(bar_index, close, "Free", style = label.style_label_left, color = color.new(cChurn, 20), textcolor = color.white, size = size.tiny)
            // ── 2/3/4. PROBE-REJECT, ACCEPTED BREAK, TRAP
            if d.exSide == 0
                if not d.churn
                    bool probeOK = na(d.probeT) or time_close - d.probeT > trapMs
                    if upC or dnC
                        d.begin(upC ? 1 : -1, high, low, time_close)
                    else if upP and not dnP and probeOK
                        sig := mk(SigClass.probe, -1, high, close, atrV)
                        d.probeT := time_close
                    else if dnP and not upP and probeOK
                        sig := mk(SigClass.probe, 1, low, close, atrV)
                        d.probeT := time_close
            else
                d.exExt := d.exSide == 1 ? math.max(d.exExt, high) : math.min(d.exExt, low)
                bool beyond = d.exSide == 1 ? upC : dnC
                bool failed = d.exSide == 1 ? close <= d.ibHi : close >= d.ibLo
                if beyond
                    if not d.exAcc and not na(d.exStartT) and time_close - d.exStartT >= acceptMs
                        d.exAcc        := true
                        d.acceptedSide := d.exSide
                        d.phase        := Phase.trend
                        sig := mk(SigClass.accepted, d.exSide, d.exSide == 1 ? d.ibHi : d.ibLo, close, atrV)
                        stats.startRead(2, d.exSide, close, atrV, d.ibHi, d.ibLo)
                else if failed
                    if not na(d.exStartT) and time_close - d.exStartT <= trapMs
                        sig := mk(SigClass.trap, -d.exSide, d.exExt, close, atrV)
                    d.fails += d.exAcc ? 2 : 1
                    if d.fails >= maxFails and not d.churn
                        d.churn := true
                        beats.push("Lock")
                        stats.startRead(3, 0, close, atrV, d.ibHi, d.ibLo)
                        if showChurnMarks
                            label.new(bar_index, low, "Lock", style = label.style_label_up, color = color.new(cChurn, 20), textcolor = color.white, size = size.tiny)
                    d.finish()
                    if not d.churn and (upC or dnC)
                        d.begin(upC ? 1 : -1, high, low, time_close)
                else if not d.exAcc
                    // A pre-acceptance break must keep closing beyond the buffer.
                    // A close back into the buffer cancels that attempt and allows a fresh break to start.
                    d.finish()
            // ── 6. LATE EXPANSION: once per session. Tight base, then a tall bar closing near its extreme.
            if na(sig) and not d.churn and not d.lateFired and elapsed >= lateMs and not na(cHi)
                float lr    = high - low
                float lpos  = lr > 0 ? (close - low) / lr : 0.5
                bool  lbase = (cHi - cLo) <= compFrac * ibR and lr >= expATR * sMul * atrV
                bool  lUp   = lbase and close > cHi and lpos >= 0.75 and (not lateExtreme or close > preHi)
                bool  lDn   = lbase and close < cLo and lpos <= 0.25 and (not lateExtreme or close < preLo)
                if lUp
                    sig := mk(SigClass.lateExp, 1, cHi, close, atrV)
                else if lDn
                    sig := mk(SigClass.lateExp, -1, cLo, close, atrV)
                if not na(sig)
                    d.lateFired := true
            // ── 5. ROTATION: edge-to-edge traverse while balanced.
            int zone = 0
            if not d.churn and d.exSide == 0 and d.phase == Phase.balance and ibR >= minIBATR * atrV
                if close <= d.ibHi and close >= d.ibHi - edgePct * ibR
                    zone := 1
                else if close >= d.ibLo and close <= d.ibLo + edgePct * ibR
                    zone := -1
            if zone != 0
                if d.lastZone == -zone and na(sig)
                    sig := mk(SigClass.rotation, -zone, zone == 1 ? d.ibHi + 0.25 * atrV : d.ibLo - 0.25 * atrV, close, atrV)
                d.lastZone := zone
        // ── GATES: end-of-session cutoff, then one event per class per session.
        if not na(sig) and endCut > 0 and elapsed >= int(sessMin * (1.0 - endCut / 100.0) * 60000)
            sig := na
        if not na(sig)
            int kk = classIdx(sig.cls)
            string fk = "|" + str.tostring(kk) + "|"
            bool seen = str.contains(d.fired, fk)
            if seen and oneAndDone
                sig := na
            else if not seen
                d.fired := d.fired + fk
        // ── REGISTER: events are appended once and never edited.
        if not na(sig)
            int k = classIdx(sig.cls)
            if ON.get(k)
                led.live.push(sig)
                d.nSig += 1
            if sig.cls == SigClass.drive
                d.driveSide := sig.dir
            story.push(chap(NAMES.get(k) + (sig.dir == 1 ? " up" : " down")))
            beats.push(SHORT.get(k) + (sig.dir == 1 ? " up" : " down"))
            // Universal alert: one alert() call, fires once per bar close.
            if ON.get(k) and (alertFilter == "All events" or (k != 1 and k != 4))
                string dirTxt = sig.dir == 1 ? "up" : "down"
                string aTail  = "event price " + str.tostring(sig.entry, format.mintick) + " | reference boundary " + str.tostring(sig.stop, format.mintick) + " | " + str.tostring(finalR) + "R reference level " + str.tostring(sig.target, format.mintick)
                string aText  = "Day Type Radar | " + syminfo.ticker + " | " + timeframe.period + " | " + NAMES.get(k) + " " + dirTxt + " | day type: " + dayTag(d) + " | " + aTail + " | illustrative only"
                string aJson = "{\"indicator\":\"Day Type Radar\",\"symbol\":\"" + syminfo.ticker + "\",\"tf\":\"" + timeframe.period + "\",\"event\":\"" + NAMES.get(k) + "\",\"dir\":\"" + dirTxt + "\",\"eventPrice\":" + str.tostring(sig.entry, format.mintick) + ",\"referenceBoundary\":" + str.tostring(sig.stop, format.mintick) + ",\"referenceLevel\":" + str.tostring(sig.target, format.mintick) + "}"
                alert(alertFmt == "JSON" ? aJson : aText, alert.freq_once_per_bar_close)
            if showLabels and ON.get(k)
                color c = COLS.get(k)
                string tip = NAMES.get(k) + (sig.dir == 1 ? " up event" : " down event") + "\nEvent price (bar close): " + str.tostring(sig.entry, format.mintick) + "\nReference boundary: " + str.tostring(sig.stop, format.mintick) + "\nR reference level (" + str.tostring(targetR, "0.##") + "R): " + str.tostring(sig.target, format.mintick) + "\nIllustrative levels, not a trade instruction."
                bool dotOnly = (k == 1 or k == 4) and minorMode == "Dots"
                string lt = dotOnly ? "" : SHORT.get(k) + (sig.dir == 1 ? " up" : " down")
                label.new(bar_index, sig.dir == 1 ? low : high, lt, style = dotOnly ? (sig.dir == 1 ? label.style_triangleup : label.style_triangledown) : (sig.dir == 1 ? label.style_label_up : label.style_label_down), color = c, textcolor = txtCol(c), size = dotOnly ? size.tiny : lblSize, tooltip = tip)
        // ── SESSION BOX + TEXT UNDER IT (live until the session closes, then frozen).
        if showBox and not na(sBox)
            int bn = beats.size()
            string l1 = dayTag(d)
            if narrStyle == "Story + stats" and bn > 0
                l1 := l1 + " | " + array.join(array.slice(beats, math.max(0, bn - 4), bn), " > ")
            string l2 = "Range " + str.tostring((d.sHi - d.sLo) / sessAtr, "0.0") + " ATR | opens " + str.format_time(d.startT, "HH:mm", dispTz) + " | IB " + str.tostring(ibMin, "0") + "m"
            string wm = narrStyle == "Off" ? "" : narrStyle == "Tag only" ? l1 : l1 + "\n" + l2
            box.set_right(sBox, bar_index)
            box.set_top(sBox, d.sHi)
            box.set_bottom(sBox, d.sLo)
            box.set_border_color(sBox, color.new(phaseCol(d), 45))
            label.set_y(sLbl, d.sLo - sessAtr)
            label.set_text(sLbl, wm)
    ribbonCol := not (inSess and armed) ? na : d.churn ? cChurn : d.phase == Phase.ib ? cIB : d.phase == Phase.trend ? (d.acceptedSide == 1 ? cUp : cDn) : cBal
    lastConfT := time_close

// ───────────────────────────── 12. VISUALS ─────────────────────────────

// Hidden on the first bar of each session: no slanted line from yesterday's level,
// and no stale state on the forming bar.
bool  valid   = inSess and armed and not newSess
color baseCol = not d.ibDone ? cIB : d.churn ? cChurn : d.phase == Phase.trend ? (d.acceptedSide == 1 ? cUp : cDn) : cBal
pHi = plot(showIB and valid ? d.ibHi : na, "IB High", color = d.ibDone ? baseCol : color.new(baseCol, 45), linewidth = 2, style = plot.style_linebr, display = display.pane)
pLo = plot(showIB and valid ? d.ibLo : na, "IB Low", color = d.ibDone ? baseCol : color.new(baseCol, 45), linewidth = 2, style = plot.style_linebr, display = display.pane)
fill(pHi, pLo, color = color.new(baseCol, 88), title = "IB zone")
plot(showOpen and valid ? d.sOpen : na, "Session open", color = color.new(chart.fg_color, 60), style = plot.style_linebr, display = display.pane)
plot(showExt and valid and d.ibDone ? d.ibHi + (d.ibHi - d.ibLo) : na, "IB +1x", color = color.new(baseCol, 60), style = plot.style_linebr, display = display.pane)
plot(showExt and valid and d.ibDone ? d.ibLo - (d.ibHi - d.ibLo) : na, "IB -1x", color = color.new(baseCol, 60), style = plot.style_linebr, display = display.pane)
plotshape(showRibbon and valid and not na(ribbonCol), "Phase ribbon", shape.square, location.bottom, ribbonCol, size = size.tiny, display = display.pane)

// ───────────────────────────── 13. DASHBOARDS ─────────────────────────────
// Every row is a single line (multi-line text inside merged cells caused overlap).
// Status comes from chart data only, never from the real clock (safe in Replay).

var table t1 = showDash1 ? table.new(getPos(d1Pos), mobile ? 5 : 6, 17, bgcolor = color.new(chart.bg_color, 3), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 88), border_width = 1) : na
int c1 = mobile ? 4 : 5
var table t2 = showDash2 ? table.new(getPos(d2Pos), mobile ? 4 : 6, 9, bgcolor = color.new(chart.bg_color, 3), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 88), border_width = 1) : na
int c2 = mobile ? 3 : 5

if barstate.isfirst and showDash1
    for r = 0 to 6
        table.merge_cells(t1, 0, r, c1, r)
    table.merge_cells(t1, 0, 15, c1, 15)
    table.merge_cells(t1, 0, 16, c1, 16)

if barstate.isfirst and showDash2
    table.merge_cells(t2, 0, 0, c2, 0)
    table.merge_cells(t2, 0, 1, c2, 1)
    table.merge_cells(t2, 0, 7, c2, 7)
    table.merge_cells(t2, 0, 8, c2, 8)

if barstate.islast
    color fg = chart.fg_color
    color dim = color.new(chart.fg_color, 45)
    color bg = color.new(chart.bg_color, 3)
    color pc = phaseCol(d)
    bool hasD = not na(d.startT)
    bool closedNow = d.phase == Phase.closed
    string status = closedNow ? "Session closed" : barstate.isrealtime ? "Live" : "History"

    if showDash1
        string s1 = szOf(d1Size, mobile)
        float ibPct = hasD ? (d.ibDone ? 100.0 : math.min(99.0, (lastConfT - d.startT) * 100.0 / ibMs)) : 0.0
        string liveTxt = led.live.size() > 0 ? " | " + str.tostring(led.live.size()) + " live" : ""
        string opens = hasD ? str.format_time(d.startT, "HH\:mm", dispTz) : "-"
        string info = syminfo.ticker + " | " + timeframe.period + " | " + assetName + " | " + (modeName == "Anchor" ? anchorKey : modeName) + " | " + opens
        string lvl = "Waiting for the open"

        if hasD
            lvl := (d.ibDone ? "IB " : "IB forming ") + str.tostring(d.ibLo, format.mintick) + "-" + str.tostring(d.ibHi, format.mintick) + " | " + str.tostring((d.ibHi - d.ibLo) / sessAtr, "0.0") + " ATR | R " + str.tostring((d.sHi - d.sLo) / sessAtr, "0.0") + " ATR"

        int bn1 = beats.size()
        string chain = bn1 > 0 ? array.join(array.slice(beats, math.max(0, bn1 - 6), bn1), " > ") : "Waiting for open"
        string lastTxt = story.size() > 0 ? "Last: " + story.get(story.size() - 1) : "No event yet"
        string outcomeHeader = measureAverage ? "Average\nR" : "Reached " + str.tostring(finalR) + "R"

        cel(t1, 0, 0, "Day Type Radar | " + status + liveTxt, txtCol(pc), color.new(pc, 25), text.align_center, s1)
        cel(t1, 0, 1, dayName(d), fg, color.new(pc, 72), text.align_center, size.large)
        cel(t1, 0, 2, dayRead(d, ibPct), fg, bg, text.align_center, s1)
        cel(t1, 0, 3, info, dim, bg, text.align_center, s1)
        cel(t1, 0, 4, lvl, fg, bg, text.align_center, s1)
        cel(t1, 0, 5, chain, fg, bg, text.align_center, s1)
        cel(t1, 0, 6, lastTxt, dim, bg, text.align_center, s1)

        array<string> h1 = mobile ? array.from("Event", "Observed", "Resolved", "Reached 1R", outcomeHeader) : array.from("Event", "Today", "Observed", "Resolved", "Reached 1R", outcomeHeader)

        for c = 0 to c1
            cel(t1, c, 7, h1.get(c), dim, bg, c == 0 ? text.align_left : text.align_center, s1)

        int tObserved = 0
        int tResolved = 0
        int tReached1 = 0
        int tReached = 0
        float tSumR = 0.0

        for k = 0 to N_CLS - 1
            int observed = led.observed.get(k)
            int resolved = led.resolved.get(k)
            int reached1 = led.reached1.get(k)
            int reached = led.reached.get(k)
            float avgR = resolved > 0 ? led.sumR.get(k) / resolved : na
            color tc = resolved < minSample ? dim : fg
            bool fired = str.contains(d.fired, "|" + str.tostring(k) + "|")

            tObserved += observed
            tResolved += resolved
            tReached1 += reached1
            tReached += reached
            tSumR += led.sumR.get(k)

            cel(t1, 0, 8 + k, (resolved < minSample ? "* " : "") + NAMES.get(k), COLS.get(k), bg, text.align_left, s1)

            if mobile
                cel(t1, 1, 8 + k, str.tostring(observed), tc, bg, text.align_center, s1)
                cel(t1, 2, 8 + k, str.tostring(resolved), tc, bg, text.align_center, s1)
                cel(t1, 3, 8 + k, resolved > 0 ? pct(reached1, resolved) : "-", tc, bg, text.align_center, s1)
                cel(t1, 4, 8 + k, measureAverage ? (resolved > 0 ? fmtR(avgR) : "-") : (resolved > 0 ? pct(reached, resolved) : "-"), tc, bg, text.align_center, s1)
            else
                cel(t1, 1, 8 + k, fired ? "Yes" : "-", fired ? COLS.get(k) : dim, bg, text.align_center, s1)
                cel(t1, 2, 8 + k, str.tostring(observed), tc, bg, text.align_center, s1)
                cel(t1, 3, 8 + k, str.tostring(resolved), tc, bg, text.align_center, s1)
                cel(t1, 4, 8 + k, resolved > 0 ? pct(reached1, resolved) : "-", tc, bg, text.align_center, s1)
                cel(t1, 5, 8 + k, measureAverage ? (resolved > 0 ? fmtR(avgR) : "-") : (resolved > 0 ? pct(reached, resolved) : "-"), tc, bg, text.align_center, s1)

            if not ON.get(k)
                cel(t1, 0, 8 + k, NAMES.get(k) + " (off)", dim, bg, text.align_left, s1)
                for c = 1 to c1
                    cel(t1, c, 8 + k, "-", dim, bg, text.align_center, s1)

        color ba = color.new(fg, 90)

        cel(t1, 0, 14, "All events", fg, ba, text.align_left, s1)

        if mobile
            cel(t1, 1, 14, str.tostring(tObserved), fg, ba, text.align_center, s1)
            cel(t1, 2, 14, str.tostring(tResolved), fg, ba, text.align_center, s1)
            cel(t1, 3, 14, tResolved > 0 ? pct(tReached1, tResolved) : "-", fg, ba, text.align_center, s1)
            cel(t1, 4, 14, measureAverage ? (tResolved > 0 ? fmtR(tSumR / tResolved) : "-") : (tResolved > 0 ? pct(tReached, tResolved) : "-"), fg, ba, text.align_center, s1)
        else
            cel(t1, 1, 14, str.tostring(d.nSig), fg, ba, text.align_center, s1)
            cel(t1, 2, 14, str.tostring(tObserved), fg, ba, text.align_center, s1)
            cel(t1, 3, 14, str.tostring(tResolved), fg, ba, text.align_center, s1)
            cel(t1, 4, 14, tResolved > 0 ? pct(tReached1, tResolved) : "-", fg, ba, text.align_center, s1)
            cel(t1, 5, 14, measureAverage ? (tResolved > 0 ? fmtR(tSumR / tResolved) : "-") : (tResolved > 0 ? pct(tReached, tResolved) : "-"), fg, ba, text.align_center, s1)

        // No explicit width overrides: TradingView auto-sizes the columns from their actual content.
        // This preserves the original dashboard proportions and prevents one outcome column from distorting the table.

        cel(t1, 0, 15, "Illustrative reference levels. Not a backtest or advice.", dim, bg, text.align_left, s1)
        cel(t1, 0, 16, measureAverage ? "Average R = average resolved outcome | Reached 1R = first R milestone | Resolved only | * N < " + str.tostring(minSample) : "Reached 1R = first R milestone | selected R = chosen target | Resolved only | * N < " + str.tostring(minSample), dim, bg, text.align_left, s1)

    if showDash2
        string s2 = szOf(d2Size, mobile)
        int nowKind = (not d.ibDone or closedNow) ? -1 : d.churn ? 3 : d.acceptedSide != 0 ? 2 : d.driveSide != 0 ? 1 : 0

        cel(t2, 0, 0, "Day-Type Stats | Historical observations after each read", fg, color.new(fg, 85), text.align_center, s2)
        cel(t2, 0, 1, "From the read bar to the session close", dim, bg, text.align_center, s2)

        array<string> h2 = array.from("Read", "N", "Remaining range", "Close beyond IB", "Follow-through", "Extension x IB")

        for c = 0 to c2
            cel(t2, c, 2, h2.get(c), dim, bg, c == 0 ? text.align_left : text.align_center, s2)

        for k = 0 to 3
            int n = stats.n.get(k)
            color tc = n < minSample ? dim : fg

            cel(t2, 0, 3 + k, (nowKind == k ? "> " : "") + RNAMES.get(k), RCOLS.get(k), bg, text.align_left, s2)
            cel(t2, 1, 3 + k, str.tostring(n), tc, bg, text.align_center, s2)
            cel(t2, 2, 3 + k, n > 0 ? str.tostring(stats.sumRem.get(k) / n, "0.0") + " ATR" : "-", tc, bg, text.align_center, s2)
            cel(t2, 3, 3 + k, pct(stats.beyond.get(k), n), tc, bg, text.align_center, s2)

            if not mobile
                cel(t2, 4, 3 + k, stats.dirN.get(k) > 0 ? pct(stats.follow.get(k), stats.dirN.get(k)) : "-", tc, bg, text.align_center, s2)
                cel(t2, 5, 3 + k, n > 0 ? str.tostring(stats.sumExt.get(k) / n, "0.00") + "x" : "-", tc, bg, text.align_center, s2)

        cel(t2, 0, 7, "> Current read | reads may overlap within a session", dim, bg, text.align_left, s2)
        cel(t2, 0, 8, "* N < " + str.tostring(minSample) + " | Historical observation, not prediction", dim, bg, text.align_left, s2)

// ───────────────────────────── 14. R LEVELS (informational, unresolved events only) ─────────────────────────────

// Redrawn from scratch on the last bar. Visibility depends on chart data only.
var array<line>  ladLines = array.new<line>()
var array<label> ladLbls  = array.new<label>()
var array<box>   ladBoxes = array.new<box>()
if barstate.islast
    while ladLines.size() > 0
        line.delete(ladLines.pop())
    while ladLbls.size() > 0
        label.delete(ladLbls.pop())
    while ladBoxes.size() > 0
        box.delete(ladBoxes.pop())
    int nLive = led.live.size()
    if showLadder and nLive > 0
        int i0 = ladderMode == "All live" ? 0 : nLive - 1
        for i = i0 to nLive - 1
            Signal ls = led.live.get(i)
            color lc  = COLS.get(classIdx(ls.cls))
            color rc2 = #EF5350
            int   xr  = bar_index + labelOffset
            int   got = math.min(finalR, int(math.floor(ls.mfe + 0.000001)))
            float topP  = ls.entry + ls.dir * ls.risk * finalR
            float riskP = ls.stop
            ladBoxes.push(box.new(ls.bi, math.max(ls.entry, topP), bar_index, math.min(ls.entry, topP), border_color = na, bgcolor = color.new(lc, 90)))
            ladBoxes.push(box.new(ls.bi, math.max(ls.entry, riskP), bar_index, math.min(ls.entry, riskP), border_color = na, bgcolor = color.new(rc2, 90)))
            ladLines.push(line.new(ls.bi, ls.entry, xr, ls.entry, color = lc, width = 1))
            ladLbls.push(label.new(xr, ls.entry, " " + SHORT.get(classIdx(ls.cls)) + (ls.dir == 1 ? " up " : " down ") + str.tostring(ls.entry, format.mintick), style = label.style_label_left, color = lc, textcolor = txtCol(lc), size = size.small))
            ladLines.push(line.new(ls.bi, riskP, xr, riskP, color = rc2, width = 1))
            ladLbls.push(label.new(xr, riskP, "Reference boundary " + str.tostring(riskP, format.mintick), style = label.style_label_left, color = color.new(rc2, 15), textcolor = color.white, size = size.small))
            for rg = 1 to finalR
                float lp  = ls.entry + ls.dir * ls.risk * rg
                bool  hit = rg <= got
                ladLines.push(line.new(ls.bi, lp, xr, lp, color = color.new(lc, hit ? 0 : 35), style = line.style_dashed, width = 1))
                ladLbls.push(label.new(xr, lp, (hit ? "Reached " : "") + "R" + str.tostring(rg) + " " + str.tostring(lp, format.mintick), style = label.style_label_left, color = color.new(lc, hit ? 0 : 55), textcolor = hit ? txtCol(lc) : chart.fg_color, size = size.small))
````
