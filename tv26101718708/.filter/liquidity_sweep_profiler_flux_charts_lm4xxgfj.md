# Liquidity Sweep Profiler | Flux Charts

- url: https://www.tradingview.com/script/LM4xxgfj-Liquidity-Sweep-Profiler-Flux-Charts/
- type: indicator
- pine_id: PUB;af6fdcb148c64299bc0e7763c58a891a
- version: 1.0

## Description

[b]GENERAL OVERVIEW:[/b]
The Liquidity Sweep Profiler is a multi-source liquidity tracking and outcome statistics indicator. It automatically identifies key liquidity levels across three categories (intraday sessions, higher timeframe key levels, and chart structure), monitors each level for sweep events (wick pierces with rejection), and then tracks what happens after each sweep over a configurable watch window. Every resolved sweep is recorded in an internal history that powers a dashboard showing, by liquidity type, the average reversal magnitude, average breach magnitude, and an Edge ratio between the two. The dashboard highlights the liquidity type with the strongest historical edge on the current chart and instrument.
The indicator plots session high/low lines (Asia, London, NY AM, NY Lunch, NY PM), previous-period highs and lows (PDH/PDL, PWH/PWL, PMH/PML), and chart structure liquidity (Swing Highs/Lows, EQH/EQL clusters). When a level is swept, it draws a Sweep Zone box marking the rejection range and an x marker at the wick extreme. An Active Sweep Tracker label shows the live performance of the most recent unresolved sweep against its historical baseline. The indicator is multi-timeframe, session-based, statistical, and rules-based. Optional quality filters let the user restrict the statistics to sweeps that meet specific volume, wick, or delta thresholds.
https://www.tradingview.com/x/Ehqzcg3u/ Screenshot: a hero shot showing session, key level, and structure liquidity lines on one chart with several Sweep Zones marked, plus the dashboard visible in a corner.

[b]WHAT IS THE THEORY BEHIND THE INDICATOR?[/b]
In intraday and swing trading, certain price levels function as "liquidity pools", areas where a critical mass of resting orders (stop losses, breakout buy/sell orders, and pending entries) tends to accumulate. The high of yesterday, the low of last week, the high of the London session, and a recent swing high are all examples of such levels. When price reaches these levels, the resting orders get triggered, which can produce one of two outcomes: a sustained breakout where the order flow continues past the level, or a sweep where price briefly pierces the level, triggers the orders, and then reverses back through it. The sweep outcome is what this indicator is designed to detect and study.

Different liquidity types behave differently. On some instruments, swept session highs and lows tend to reverse cleanly. On others, sweeps of weekly or monthly extremes are more reliable. On yet others, sweeps of equal highs and lows (clustered pivots) outperform sweeps of standalone swing points. The behavioral pattern can also vary by day of the week and by whether the sweep candle showed strong rejection characteristics (high relative volume, large rejection wick, strong intrabar volume imbalance toward the rejection direction). The Liquidity Sweep Profiler treats every sweep as a data point, records the recovery and breach magnitudes that followed it, and aggregates the data by liquidity type to surface which type has shown the strongest reversal tendency on the specific chart and instrument the trader is using.
This is a statistical profile, not a prediction. The dashboard reports what has happened historically on the current chart. The trader uses that profile to focus attention on the liquidity types with the strongest empirical edge, while remaining aware that future behavior can deviate from past behavior. Every sweep is treated as evidence to be aggregated, and the indicator surfaces the resulting profile for the trader to interpret.

[b]FEATURES:[/b]
◇ Multi-source liquidity detection (sessions, higher timeframe key levels, structure)
◇ Sweep detection with configurable confirmation window
◇ Sweep Zone boxes and x markers
◇ Outcome tracking (recovery and breach magnitudes over a watch window)
◇ Statistics dashboard with per-type sweep counts, averages, and Edge ratios
◇ Best-Edge banner highlighting the top-performing liquidity type
◇ Active Sweep Tracker for live monitoring of the most recent sweep
◇ Quality filters (relative volume, wick %, intrabar delta %)
◇ Trading-day filter (per-weekday inclusion)
◇ Display unit selector (ATR, Price, Pips, Ticks)
◇ Configurable label, line, zone, and theme styling
◇ Built-in alerts for new sweeps and high-edge sweeps
https://www.tradingview.com/x/r0TZPoMq/ Screenshot: a clean overview showing one example from each liquidity category (a session line, a PDH, EQL/EQL line) with their distinct color coding visible.

[b]LIQUIDITY LEVEL DETECTION[/b]
🔹 What are liquidity levels?
A liquidity level is a price where resting orders tend to accumulate. The Liquidity Sweep Profiler tracks three categories:
◇ Session liquidity: the high and low formed during each defined intraday session (Asia, London, NY AM, NY Lunch, NY PM). Each session is a configurable time window.
◇ Key levels: the high and low of the previous completed day (PDH/PDL), week (PWH/PWL), and month (PMH/PML).
◇ Structure liquidity: pivot-based swing highs and lows detected on the current chart, plus EQH/EQL clusters where two or more recent pivots formed at approximately the same price.

🔹 Why do these levels matter?
Each category captures a different participant base. Session highs and lows matter to intraday traders working specific market hours. Daily, weekly, and monthly extremes matter to swing traders and institutional desks that operate on those reference points. Swing pivots and equal highs/lows matter to participants who place orders relative to recent chart structure. By tracking all three in one indicator, the trader can observe which category produces the most reliable sweep behavior on the specific instrument.

🔹 How are levels detected?
Session levels are tracked in real time during each session window. The session detector evaluates whether the current bar's New York time falls inside the session's start-end string. While the session is active, the indicator maintains a running high and low, updating both the level and the bar index of each extreme on every new high or low. When the session window closes (the next bar is outside the session), both the final high and the final low are stored as liquidity levels, with the bar index of the actual extreme preserved as the level's anchor bar.
Previous-period levels are fetched from the daily, weekly, and monthly timeframes. The indicator requests the prior period's high and low (offset by one period, so the value is stable and never references the still-developing current period). Each time the fetched value changes (which happens once per new day, week, or month), the new level is added to tracking.
Structure liquidity uses standard pivot detection with a configurable lookback length (default 5 bars on each side). When a new pivot high or pivot low forms, it is checked against the most recent prior pivots in the same direction: if it falls within an ATR-based threshold (default 0.1 x ATR) of one of the last three same-side pivots, it is classified as an EQH or EQL. Otherwise it is recorded as a standalone Swing High or Swing Low.

For each category, a Track Last input controls how many of the most recent levels of each type are kept on the chart simultaneously. When a new level of a given type is added, the oldest level of that same type is trimmed from the tracking array if the count exceeds the limit.
https://www.tradingview.com/x/SqKF3t2p/ Screenshot: showing session-derived levels (dashed lines), HTF key levels (solid lines), and structure levels (dotted lines) 

🔹 Settings
◇ Session enable toggles, names, time windows (in New York timezone), and per-session colors for all five sessions.
◇ Track Last (Sessions): how many days of session highs and lows to keep tracked. Default 1.
◇ Enable PDH/PDL, PWH/PWL, PMH/PML with individual color pickers.
◇ Track Last (Previous Periods): number of previous periods kept per type (days for PDH/PDL, weeks for PWH/PWL, months for PMH/PML). Default 1.
◇ Pivot Length: number of bars on each side used for pivot detection. Default 5.
◇ EQH/EQL Threshold (ATR): two pivots within this multiple of ATR distance count as equal. Default 0.1.
◇ Track Last (Structure): number of structure levels kept per type. Default 5.

🔹 Customization
◇ Per-category visibility toggles under Visual Overlays (Session Liq, PDH/PDL, PWH/PWL, PMH/PML, Swings, EQH/EQL).
◇ Day Suffix toggle: appends (Today), (Yest), or (-Nd) to session labels when tracking more than one day of session liquidity.
◇ Boxes toggle: optionally renders the live session range as a translucent box while the session is active.

[b]SWEEP DETECTION[/b]
🔹 What is a sweep?
A sweep occurs when price reaches a tracked liquidity level, briefly trades beyond it with its wick, and then closes back through it within a defined confirmation window. The wick pierces the level (triggering the resting orders), but the candle body closes back on the original side, indicating that the move past the level was rejected. This is the canonical stop-run-and-reverse pattern.

🔹 Why does the confirmation window matter?
A pure same-bar sweep requires the same candle to both pierce the level with its wick and close back through it. This is the strictest definition and captures the cleanest rejections. Allowing one or more additional bars for the close to come back through captures sweeps that take a slightly longer time to resolve, at the cost of including weaker rejections. The trader picks the trade-off they prefer using the Sweep Confirmation Window input.

🔹 How are sweeps detected?
Each tracked level carries two state flags: pierced and taken. On every new bar, the indicator walks the list of untaken levels and evaluates two conditions per level:
◇ Wick-through: for a high-side level, the bar's high exceeds the level. For a low-side level, the bar's low falls below the level.
◇ Closed-back: for a high-side level, the bar's close is below the level. For a low-side level, the close is above it.
The flow is:
◇ If the level is not yet pierced and the wick-through condition is true on this bar, the level is marked pierced, the piercing bar index is stored, and the wick extreme is recorded. If the closed-back condition is also true on the same bar, the level is immediately marked taken (a same-bar sweep).
◇ If the level was already pierced on a previous bar, the indicator first updates the wick extreme if the current bar exceeded the previous extreme. It then checks how many bars have elapsed since the pierce. If the elapsed count exceeds the confirmation window, the level is marked taken with the broken flag set (clean breakout, no rejection). Otherwise, if closed-back is true on the current bar, the level is marked taken with broken cleared (confirmed sweep).
When a sweep confirms (taken, broken = false), the indicator captures a snapshot of the sweep candle's context:
◇ Relative volume: current bar's volume divided by the 20-bar simple moving average of volume.
◇ Wick percentage: the rejection wick's share of the candle's total range. For a high sweep, this is (high − max(open, close)) / (high − low) x 100. For a low sweep, (min(open, close) − low) / (high − low) x 100.
◇ Intrabar volume delta: the share of lower-timeframe volume on the rejecting side. The indicator requests lower-timeframe up-volume (close > open) and down-volume (close < open) for the bar, sums both, and computes the rejecting side's share. For a high sweep, that's down-volume / total. For a low sweep, up-volume / total.
These three values are stored on the sweep record and become the basis for the optional quality filters.

🔹 Bullish Example (low sweep)
A Swing Low at 1.0850 sits on the chart. Price drops to 1.0840 on a single candle (wick extreme), then closes at 1.0855, back above the original level. The level is marked as swept (low sweep), a green Sweep Zone box is drawn from the wick extreme up to the level, and an x marker is plotted at 1.0840.

🔹 Bearish Example (high sweep)
A PDH sits at 1.0950. Price rallies to 1.0965 on the wick, then closes at 1.0945, back below the original level. The level is marked as swept (high sweep), a red Sweep Zone box is drawn from the level up to the wick extreme, and an x marker is plotted at 1.0965.
https://www.tradingview.com/x/y2c4DobT/ Screenshot: bullish low sweep and one bearish high sweep visible on the same chart, both with their Sweep Zone boxes and x markers rendered.

🔹 Settings
◇ Sweep Confirmation Window: number of additional bars allowed after the wick pierce for the close to come back through. 0 = same-bar rejection only. 1 = same-bar or next bar. Default 0.

🔹 Customization
◇ Show Sweep Zones: toggle Sweep Zone box rendering.
◇ High Sweep Zone Color / Low Sweep Zone Color: customize the fill color for high-sweep and low-sweep zones.
◇ Show Sweep x Mark: toggle the x marker plotted at the wick extreme of each confirmed sweep.

[b]OUTCOME TRACKING[/b]
🔹 What is outcome tracking?
Detecting that a sweep occurred is only half the picture. To know whether a particular liquidity type tends to produce reversals worth trading, the indicator also needs to measure what happened after the sweep. Outcome tracking does this by monitoring each confirmed sweep for a fixed number of bars and recording two values:
◇ Recovery: the maximum favorable excursion away from the swept level (in the rejecting direction). For a high sweep, this is how far price fell below the sweep candle's close. For a low sweep, how far the price rose above it.
◇ Breach: the maximum adverse excursion past the swept level (in the original sweep direction). For a high sweep, how far price went above the sweep candle's close. For a low sweep, how far the price went below it.

🔹 Why measure both?
Recovery alone could mislead. A liquidity type might produce large reversals on average but also large breaches when the sweep fails, which is information the trader needs. Tracking both Recovery and Breach, and then computing their ratio as an Edge value (Recovery / Breach), captures the full risk-reward profile of sweeps on that level type. An Edge above 1 indicates the type tends to deliver more reversal magnitude than breach magnitude on average.

🔹 How is outcome tracking calculated?
When a sweep confirms, the indicator stores the sweep candle's close price, the ATR value at that moment (using the configured ATR length, default 14), and the other metadata snapshot. From the next bar onward, for the configured Outcome Watch Window (default 20 bars), it computes two per-bar values:
◇ Recovery on the current bar = (sweep_close − low) / sweep_ATR for high sweeps, or (high − sweep_close) / sweep_ATR for low sweeps.
◇ Breach on the current bar = (high − sweep_close) / sweep_ATR for high sweeps, or (sweep_close − low) / sweep_ATR for low sweeps.
The running maximum of each is updated bar by bar. When the watch window expires (bars since sweep ≥ watch window), the sweep is marked completed and its final maxRecovery, maxBreach, and metadata snapshot are pushed into the indicator's history array along with the resolution day's weekday. This history is what powers the dashboard.
If the level was classified as broken instead of swept (the confirmation window expired without a close-back-through), the record is not added to the history, since the indicator only counts confirmed sweep outcomes.
Recovery and Breach are stored in the history as ATR multiples to keep them comparable across different volatility regimes. The dashboard's Display Unit input converts them to ATR multiples, Price, Pips, or Ticks for display at render time. Pip conversion uses mintick x 10 (or x 100 for JPY pairs), and Tick conversion uses raw mintick.
https://www.tradingview.com/x/eES9xYQp/ Screenshot: A swept level showing two arrows. One marks how far price moved back (Recovery). The other marks how far price moved past the level (Breach). 

🔹 Settings
◇ Outcome Watch Window: number of bars to track each sweep for measuring Recovery and Breach. Default 20.
◇ ATR Length: ATR period used for the volatility snapshot at sweep time. Default 14.

[b]STATISTICS DASHBOARD[/b]
🔹 What is the dashboard?
The dashboard is the analytic output of the indicator. It aggregates every completed sweep in the history array and displays per-type statistics in a table grouped by category. The columns are:
◇ Type: the liquidity type (Asia High, PDH, Swing Low, etc.).
◇ Total Sweeps: number of completed sweep records for that type that passed all active filters.
◇ Avg Recovery: average maximum favorable excursion, in the selected Display Unit.
◇ Avg Breach: average maximum adverse excursion, in the selected Display Unit.
◇ Edge: Avg Recovery / Avg Breach. A value above 1 means recovery has typically exceeded breach on that type.
The row with the highest Edge (subject to a minimum sample count of 5) is highlighted, and a Best Edge banner above the table calls out the winning type explicitly. Types with fewer than 5 samples can appear in the table but are excluded from the Best Edge competition.

🔹 Why aggregate by type?
The whole point of the indicator is to surface which liquidity types behave reliably on the current chart. A flat list of every sweep is not actionable. Grouping by type and computing aggregate statistics turns the raw sweep records into a usable trading profile.

🔹 How are statistics calculated?
For each liquidity type, the indicator walks the history array and filters by the active toggles (trading-day filter, relative volume filter, wick % filter, delta % filter). For records that pass all filters, it converts each stored ATR-multiple to the current Display Unit and sums the Recovery and Breach values. Avg Recovery and Avg Breach are computed by dividing the running sums by the filtered count. Edge is the ratio of the resulting averages.
To pick the Best Edge across all categories, the indicator runs the same aggregation for every active liquidity type (sessions, key levels, structure), filters out types with fewer than 5 samples, and selects the one with the highest Edge. The selection is independent of category, so a Swing High can win over an Asia Low if its Edge is higher and its sample count qualifies.
In the table itself, Avg Recovery is colored green when it exceeds Avg Breach for that row. Avg Breach is colored red when it exceeds Avg Recovery. The Edge cell is colored green at 1.5 or above, neutral between 1.0 and 1.5, and red below 1.0. The Best Edge row gets a green background and a star marker.
https://www.tradingview.com/x/fHFc8g07/ Screenshot: a close-up of the dashboard table showing all three category sections (Sessions, Key Levels, Structure) populated with realistic data, with the Best Edge banner visible and one row highlighted as the winner.

🔹 Settings
◇ Show Dashboard: master toggle.
◇ Theme: Dark Mode or Light Mode.
https://www.tradingview.com/x/ZAoCTcq1/ Screenshot: Showing Light Mode Theme
◇ Position: nine-position selector for table placement (Top Left, Top Center, Top Right, Middle Left, Middle Center, Middle Right, Bottom Left, Bottom Center, Bottom Right).
◇ Text Size: Tiny, Small, Normal, Large, Huge.
◇ Display Unit: ATR (volatility-normalized multiples), Price (raw price excursion), Pips (mintick x 10 for forex, x 100 for JPY pairs), Ticks (mintick units).
https://www.tradingview.com/x/egVs44Ne/ Screenshot: the dashboard configured to show only the liquidity types the user enabled. Sessions section shows only London High and London Low. Key Levels shows only PDH and PDL. Structure shows only EQH and EQL. Disabled types are filtered out of the table entirely.

[b]QUALITY FILTERS[/b]
🔹 What are quality filters?
Quality filters restrict the sweeps that get counted in the dashboard statistics. Each one is independently togglable, and any combination can be active at once.
◇ Volume Spike Multiplier: the sweep candle's volume must be at least this multiple of its 20-bar volume average. Default 1.5x.
◇ Sweep Wick %: the rejection wick must be at least this percent of the candle's total range. Default 50%.
◇ Sweep Delta %: the rejecting side's intrabar volume share must be at least this percent of total intrabar volume. The lower timeframe used to compute delta is configurable (default 1 minute).

🔹 Why filter quality?
Not every sweep is equal. A sweep that occurs on heavy volume, with a long rejection wick, and with the rejecting side dominating intrabar volume is a fundamentally stronger rejection than one without those characteristics. By filtering the dashboard to only count high-quality sweeps, the trader can see whether quality-filtered sweeps produce a meaningfully different Edge than the unfiltered set. This is useful both for refining a setup definition and for evaluating which characteristics matter on the current instrument.

🔹 How do filters interact with the dashboard?
The total sweeps count shown in the dashboard title reflects the filtered count. The Best Edge banner and per-row statistics are also computed against the filtered set. Toggling any filter on or off triggers an immediate recomputation of the dashboard. 
https://www.tradingview.com/x/RhTzTD75/ Screenshot: a before-and-after dashboard pair showing how the statistics change when quality filters are applied

🔹 Settings
◇ Volume Spike Multiplier: enable toggle and threshold (default 1.5x).
◇ Sweep Wick %: enable toggle and minimum percent (default 50).
◇ Sweep Delta %: enable toggle, minimum percent (default 60), and intrabar timeframe (default 1 minute).

[b]TRADING DAY FILTER[/b]
🔹 What is the Trading Day Filter?
A row of seven weekday checkboxes that controls which days of the week are included in the dashboard statistics. Each sweep's resolution day is stored with the record. The filter excludes records whose weekday is unchecked.

🔹 Why filter by weekday?
Sweep behavior frequently varies by day of the week. Monday opens often produce different patterns than Wednesday midweek sessions or Friday closes. Letting the trader exclude specific weekdays makes it possible to test whether the Edge values on each liquidity type are weekday-dependent.

🔹 Settings
◇ Sun, Mon, Tue, Wed, Thu, Fri, Sat: each is an independent on/off toggle. Defaults: Mon through Fri on, Sat and Sun off.

[b]ACTIVE SWEEP TRACKER[/b]
🔹 What is the Active Sweep Tracker?
A floating label rendered near the current bar that shows the live performance of the most recent unresolved sweep. It updates each bar while the watch window is still open. The label displays:
◇ The liquidity type that was swept.
◇ Bars elapsed since the sweep, against the watch window total.
◇ Current Recovery and Breach magnitudes (running max plus current-bar excursion).
◇ The historical average Recovery, Breach, and Edge for that type, if there are at least 5 samples for that type.

🔹 Why does it matter?
The dashboard shows aggregate historical statistics, but during a live setup the trader wants to know how the current move is tracking against the baseline. The Active Sweep Tracker makes this comparison explicit on the chart: at any moment, the trader can see whether the active sweep is matching, exceeding, or underperforming what that type has typically delivered.

🔹 How is the tracker calculated?
On the last bar of the chart, the indicator scans the levels array for any level that is taken, has broken = false, and is not yet completed. Among those, it picks the one with the highest takenBar (the most recent unresolved sweep). For that sweep, it computes the current-bar Recovery and Breach using the same formulas as outcome tracking, takes the maximum of the running max and the current-bar value (so the displayed value reflects either the historical peak or the live excursion, whichever is larger), and pulls the historical stats for that sweep type using the same filter pipeline as the dashboard.

The label's background color reflects which side is winning in real time. Bull color when the higher of the two excursions is on the Recovery side, bear color otherwise.
https://www.tradingview.com/x/bVu8tUib/ Screenshot: a chart with an active unresolved sweep, the Sweep Zone visible, and the Active Sweep Tracker label rendered near the current bar showing the live Bar x / Y count, current excursion values, and historical baseline comparison.

🔹 Settings
◇ Show Active Sweep Tracker: master toggle.
◇ Text Size: Tiny, Small, Normal, Large, Huge.

[b]DISPLAY AND STYLING[/b]
🔹 Label and line styling
Liquidity levels render as horizontal lines extended to the right. Each category uses a distinct line style: solid for key levels, dashed for session levels, dotted for structure levels. Each type has its own color, customizable from the Sessions, Previous Periods, and Structure input groups. Labels render at the right edge with the type name and an optional day suffix for session levels when tracking more than one day.

🔹 Hide-on-Swept behavior
By default, swept levels remain drawn on the chart. With Hide on Swept enabled, swept levels are removed from the chart after a configurable grace period (Keep Swept Levels For). The grace period is measured in bars from when the level resolved (either taken or broken). This is useful for keeping the chart focused on the active liquidity once the historical sweep map becomes dense.

🔹 Settings
◇ Extend Right: number of bars to extend liquidity lines past the current bar. Default 3.
◇ Label Size: Tiny, Small, Normal, Large, Huge.
◇ Hide on Swept: toggle removal of swept levels.
◇ Keep Swept Levels For: grace period in bars before removal (applies when Hide on Swept is enabled). Default 5.

[b]ALERTS[/b]
🔹 New Sweep
Fires when any tracked liquidity level is freshly swept on the current bar (taken status set this bar, broken = false). The alert message includes ticker and timeframe.

🔹 High-Edge Sweep
Fires when a new sweep occurs on a liquidity type whose historical Edge meets or exceeds the High-Edge Alert Threshold, provided that type has at least 5 historical samples. The Edge value is computed using the same filter pipeline as the dashboard, so any active quality filters and weekday filters are respected when evaluating whether the alert qualifies.

🔹 Settings
◇ High-Edge Alert Threshold: Edge value at or above which the High-Edge alert qualifies. Default 1.5.

[b]IMPORTANT NOTES:[/b]
◇ The Sweep Delta % filter relies on lower-timeframe volume data, which may be unavailable for some instruments (forex pairs with no native volume, certain crypto exchanges, etc.). On those instruments, the delta filter can be left disabled.
◇ Statistics displayed in the dashboard reflect the sweeps visible in the historical data the chart has access to. Loading more historical bars (by scrolling left on lower timeframes or increasing the chart's bar limit) will increase the sample size and may shift the Edge rankings.
◇ The Best Edge banner requires a minimum of 5 sweeps per type to qualify. Types with fewer sweeps are shown in the dashboard but do not compete for the banner.
◇ Past sweep behavior on a given liquidity type does not guarantee future sweep behavior. The dashboard provides a statistical profile of historical sweeps; trade decisions remain the user's responsibility.
◇ Session times are interpreted in the America/New_York timezone regardless of the chart's session timezone. The default windows correspond to common Asia / London / NY conventions but can be edited freely.

[b]UNIQUENESS:[/b]
The Liquidity Sweep Profiler is built around a feedback loop that most liquidity-tracking indicators do not provide. It detects liquidity levels, monitors them for sweeps, measures what happened after each sweep, and aggregates the results into a per-type statistical profile on the current chart. The trader sees not just where liquidity sits, but which categories of liquidity have actually produced clean reversals on the specific instrument and timeframe in question. Most competing tools stop at plotting the levels and flagging sweeps, leaving the trader to estimate behavior by eye. The Sweep Profiler turns this into structured data with sample counts, average magnitudes, and an Edge ratio that captures the recovery-to-breach trade-off.
The indicator also combines several feature categories that are usually distributed across multiple tools: intraday session tracking, higher timeframe key levels, chart-structure liquidity (swings and equal highs/lows), volume and delta quality filters, weekday filtering, and a live Active Sweep Tracker that compares the current unresolved sweep to its historical baseline in real time. All of this is unified into one dashboard with a Best Edge banner that surfaces the strongest-performing liquidity type at a glance. Display values can be expressed in ATR, raw price, pips, or ticks, so the same indicator reads naturally on indices, forex, futures, and crypto without manual conversion. Sweep detection itself is configurable from strict same-bar rejection to multi-bar close-back-through, letting the trader tune the detection logic to match the rejection style they actually trade.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fluxchart

//@version=6
indicator("Liquidity Sweep Profiler | Flux Charts", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000)

//#region Constants

GP_GEN     = "General"
GP_SESS    = "Sessions"
GP_PERIOD  = "Previous Periods"
GP_STRUCT  = "Structure"
GP_FILT    = "Trading Day Filter"
GP_QUAL    = "Quality Filters"
GP_DISP    = "Visual Overlays"
GP_DASH    = "Dashboard"
GP_ALERT   = "Alerts"

// Per-session colors
ASIA_COLOR   = #FF6D00
LON_COLOR    = #2962FF
NYAM_COLOR   = #00C853
LUNCH_COLOR  = #AA00FF
NYPM_COLOR   = #F50057

// HTF colors (purple gradient — daily lighter, monthly darker)
PD_COLOR     = #CE93D8
PW_COLOR     = #AB47BC
PM_COLOR     = #6A1B9A

// Structure colors
SWING_COLOR  = #FF8F00
EQ_COLOR     = #FFD600

// Sweep zone colors
BULL_COLOR   = #089981
BEAR_COLOR   = #f23645
GRAY_COLOR   = color.gray

// Dashboard theme colors
BG_DARK_DARK    = color.rgb(30, 30, 30)
BG_DARK_LIGHT   = color.rgb(245, 245, 245)
BG_TITLE_DARK   = color.rgb(30, 30, 40)
BG_TITLE_LIGHT  = color.rgb(230, 230, 240)
BG_HEADER_DARK  = color.rgb(35, 38, 48)
BG_HEADER_LIGHT = color.rgb(232, 234, 240)
TEXT_DARK       = color.rgb(220, 222, 230)
TEXT_LIGHT      = color.rgb(30, 33, 40)
SUBTEXT_DARK    = color.rgb(140, 145, 160)
SUBTEXT_LIGHT   = color.rgb(110, 115, 130)

// Static type names (key levels + structure)
T_PDH      = "PDH"
T_PDL      = "PDL"
T_PWH      = "PWH"
T_PWL      = "PWL"
T_PMH      = "PMH"
T_PML      = "PML"
T_SWING_H  = "Swing High"
T_SWING_L  = "Swing Low"
T_EQH      = "EQH"
T_EQL      = "EQL"

CAT_SESS   = "Session"
CAT_KEY    = "Key Level"
CAT_STRUCT = "Structure"

//#endregion Constants

//#region Input

// General
atrLen        = input.int(14,    "ATR Length", minval = 5, maxval = 50, group = GP_GEN, display = display.none)
sweepWindow   = input.int(0,     "Sweep Confirmation Window", minval = 0, maxval = 5, group = GP_GEN, tooltip = "After wick pierces a level, allow this many additional bars for close to come back through. 0 = same-bar rejection only. 1 = same-bar or next bar. Etc.", display = display.none)
watchBars     = input.int(20,    "Outcome Watch Window", minval = 5, maxval = 100, group = GP_GEN, tooltip = "Bars to track each sweep for measuring recovery and continuation magnitude", display = display.none)

// Sessions
enableAsia    = input.bool(true,           "",         inline = "asia",   group = GP_SESS, display = display.none)
asiaName      = input.string("Asia",       "",         inline = "asia",   group = GP_SESS, display = display.none)
asiaTime      = input.session("1900-0200", "",         inline = "asia",   group = GP_SESS, display = display.none)
asiaCol       = input.color(ASIA_COLOR,    "",         inline = "asia",   group = GP_SESS, display = display.none)

enableLondon  = input.bool(true,           "",         inline = "london", group = GP_SESS, display = display.none)
londonName    = input.string("London",     "",         inline = "london", group = GP_SESS, display = display.none)
londonTime    = input.session("0200-0830", "",         inline = "london", group = GP_SESS, display = display.none)
londonCol     = input.color(LON_COLOR,     "",         inline = "london", group = GP_SESS, display = display.none)

enableNYAM    = input.bool(true,           "",         inline = "nyam",   group = GP_SESS, display = display.none)
nyamName      = input.string("NY AM",      "",         inline = "nyam",   group = GP_SESS, display = display.none)
nyamTime      = input.session("0830-1200", "",         inline = "nyam",   group = GP_SESS, display = display.none)
nyamCol       = input.color(NYAM_COLOR,    "",         inline = "nyam",   group = GP_SESS, display = display.none)

enableLunch   = input.bool(true,           "",         inline = "lunch",  group = GP_SESS, display = display.none)
lunchName     = input.string("NY Lunch",   "",         inline = "lunch",  group = GP_SESS, display = display.none)
lunchTime     = input.session("1200-1330", "",         inline = "lunch",  group = GP_SESS, display = display.none)
lunchCol      = input.color(LUNCH_COLOR,   "",         inline = "lunch",  group = GP_SESS, display = display.none)

enableNYPM    = input.bool(true,           "",         inline = "nypm",   group = GP_SESS, display = display.none)
nypmName      = input.string("NY PM",      "",         inline = "nypm",   group = GP_SESS, display = display.none)
nypmTime      = input.session("1330-1600", "",         inline = "nypm",   group = GP_SESS, display = display.none)
nypmCol       = input.color(NYPM_COLOR,    "",         inline = "nypm",   group = GP_SESS, display = display.none)

// Derived session type identifiers + chart-label texts (depend on user-edited names above)
T_ASIA_H    = asiaName   + " High"
T_ASIA_L    = asiaName   + " Low"
T_LON_H     = londonName + " High"
T_LON_L     = londonName + " Low"
T_NYAM_H    = nyamName   + " High"
T_NYAM_L    = nyamName   + " Low"
T_LUNCH_H   = lunchName  + " High"
T_LUNCH_L   = lunchName  + " Low"
T_NYPM_H    = nypmName   + " High"
T_NYPM_L    = nypmName   + " Low"

TEXT_ASIA_H  = asiaName   + " H"
TEXT_ASIA_L  = asiaName   + " L"
TEXT_LON_H   = londonName + " H"
TEXT_LON_L   = londonName + " L"
TEXT_NYAM_H  = nyamName   + " H"
TEXT_NYAM_L  = nyamName   + " L"
TEXT_LUNCH_H = lunchName  + " H"
TEXT_LUNCH_L = lunchName  + " L"
TEXT_NYPM_H  = nypmName   + " H"
TEXT_NYPM_L  = nypmName   + " L"

sessLookback  = input.int(1,               "Track Last", minval = 1, maxval = 30, group = GP_SESS, tooltip = "How many days of session highs/lows to track", display = display.none)

// Previous Periods
enablePDLiq   = input.bool(true,  "Enable PDH/PDL", inline = "pdw", group = GP_PERIOD, display = display.none)
pdCol         = input.color(PD_COLOR, "",           inline = "pdw", group = GP_PERIOD, display = display.none)
enablePWLiq   = input.bool(true,  "Enable PWH/PWL", inline = "pdw", group = GP_PERIOD, display = display.none)
pwCol         = input.color(PW_COLOR, "",           inline = "pdw", group = GP_PERIOD, display = display.none)
enablePMLiq   = input.bool(false, "Enable PMH/PML", inline = "pm",  group = GP_PERIOD, display = display.none)
pmCol         = input.color(PM_COLOR, "",           inline = "pm",  group = GP_PERIOD, display = display.none)
keepPeriod    = input.int(1,      "Track Last",     minval = 1, maxval = 30, group = GP_PERIOD, tooltip = "Number of previous periods to track per type (days for PDH/PDL, weeks for PWH/PWL, months for PMH/PML)", display = display.none)

// Structure
enableSwingLiq = input.bool(true,  "Enable Swing Liquidity", inline = "swe", group = GP_STRUCT, display = display.none)
swingCol       = input.color(SWING_COLOR, "",                inline = "swe", group = GP_STRUCT, display = display.none)
enableEqLiq    = input.bool(true,  "Enable EQH/EQL",         inline = "swe", group = GP_STRUCT, display = display.none)
eqCol          = input.color(EQ_COLOR, "",                   inline = "swe", group = GP_STRUCT, display = display.none)
pivotLen       = input.int(5,      "Swing Length", minval = 2, maxval = 20, group = GP_STRUCT, display = display.none)
eqhThresh      = input.float(0.1,  "EQH/EQL Threshold (ATR)", minval = 0.01, maxval = 1.0, step = 0.05, group = GP_STRUCT, tooltip = "Two pivots within this ATR distance count as equal", display = display.none)
keepStruct     = input.int(5,      "Track Last", minval = 1, maxval = 50, group = GP_STRUCT, tooltip = "Track last N of each structure type (Swing H, Swing L, EQH, EQL)", display = display.none)

// Quality Filters
useRvolFilter  = input.bool(false, "Volume Spike Multiplier", inline = "rv", group = GP_QUAL, display = display.none)
minRvol        = input.float(1.5,  "",                        inline = "rv", group = GP_QUAL, minval = 0.5, maxval = 5.0, step = 0.1, tooltip = "Only count sweeps where the sweep candle's volume is at least this multiplier × the 20-bar volume average", display = display.none)
useWickFilter  = input.bool(false, "Sweep Wick %",            inline = "wk", group = GP_QUAL, display = display.none)
minWickPct     = input.float(50,   "",                        inline = "wk", group = GP_QUAL, minval = 0,   maxval = 100, step = 5,   tooltip = "Only count sweeps where the rejection wick (the wick rejecting from the swept level) is at least this percent of the candle's full range", display = display.none)
useDeltaFilter = input.bool(false, "Sweep Delta %",           inline = "dl", group = GP_QUAL, display = display.none)
minDeltaPct    = input.float(60,   "",                        inline = "dl", group = GP_QUAL, minval = 0,   maxval = 100, step = 5,   display = display.none)
deltaLtf       = input.timeframe("1", "",                     inline = "dl", group = GP_QUAL, tooltip = "Only count sweeps where the share of intrabar volume on the rejection side (sellers for high sweeps, buyers for low sweeps) is at least the threshold percent. The timeframe controls the resolution used to compute intrabar volume delta — smaller = more accurate but heavier. May be unavailable on instruments without lower-TF data.", display = display.none)

// Trading Day Filter
wdSun         = input.bool(false, "Sun", inline = "wd", group = GP_FILT, display = display.none)
wdMon         = input.bool(true,  "Mon", inline = "wd", group = GP_FILT, display = display.none)
wdTue         = input.bool(true,  "Tue", inline = "wd", group = GP_FILT, display = display.none)
wdWed         = input.bool(true,  "Wed", inline = "wd", group = GP_FILT, display = display.none)
wdThu         = input.bool(true,  "Thu", inline = "wd", group = GP_FILT, display = display.none)
wdFri         = input.bool(true,  "Fri", inline = "wd", group = GP_FILT, display = display.none)
wdSat         = input.bool(false, "Sat", inline = "wd", group = GP_FILT, display = display.none)

// Dashboard
showDash       = input.bool(true,           "Show Dashboard",                                                                              group = GP_DASH, display = display.none)
dashTheme      = input.string("Dark Mode",  "Theme",            options = ["Dark Mode", "Light Mode"],                                       group = GP_DASH, display = display.none)
dashPos        = input.string("Top Right",  "Position",         options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = GP_DASH, display = display.none)
dashSize       = input.string("Small",      "Text Size",        options = ["Tiny", "Small", "Normal", "Large", "Huge"],                      group = GP_DASH, display = display.none)
unitDisplay    = input.string("ATR",        "Display Unit",     options = ["ATR", "Price", "Pips", "Ticks"],                                  group = GP_DASH, tooltip = "Unit for Recovery/Breach values in the dashboard. ATR = volatility-normalized multiples. Price = raw price excursion. Pips = mintick × 10 (forex convention). Ticks = mintick units.", display = display.none)
minSamples = 5

// Visual Overlays
showSessLiq   = input.bool(true,  "Session Liq",     inline = "sess", group = GP_DISP, display = display.none)
showSessBoxes = input.bool(false, "Boxes",           inline = "sess", group = GP_DISP, display = display.none)
showDaySuffix = input.bool(true,  "Day Suffix",      inline = "sess", group = GP_DISP, tooltip = "Append (Today) / (Yest) / (-Nd) to session labels when keeping > 1 day of liquidity", display = display.none)
showPDLiq     = input.bool(true,  "PDH/PDL",         inline = "key",  group = GP_DISP, display = display.none)
showPWLiq     = input.bool(true,  "PWH/PWL",         inline = "key",  group = GP_DISP, display = display.none)
showPMLiq     = input.bool(false, "PMH/PML",         inline = "key",  group = GP_DISP, display = display.none)
showSwingLiq  = input.bool(true,  "Swings",          inline = "str",  group = GP_DISP, display = display.none)
showEqLiq     = input.bool(true,  "EQH/EQL",         inline = "str",  group = GP_DISP, display = display.none)
extendBars    = input.int(3,           "Extend Right", minval = 0, maxval = 50,                           group = GP_DISP, display = display.none)
labelSize     = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"],     group = GP_DISP, display = display.none)
hideOnSwept   = input.bool(false,      "Hide on Swept",                                                          group = GP_DISP, tooltip = "When enabled, swept levels are removed after the grace period set below. When disabled, swept levels stay drawn indefinitely.", display = display.none)
sweptGrace    = input.int(5,           "Keep Swept Levels for", minval = 0, maxval = 50,                         group = GP_DISP, tooltip = "After a level's outcome resolves, keep it drawn for this many bars before removing (only applies when Hide on Swept is enabled)", display = display.none)
showSweepZone = input.bool(true,       "Show Sweep Zones",     inline = "sw", group = GP_DISP, display = display.none)
highSweepZoneCol   = input.color(BEAR_COLOR, "",         inline = "sw", group = GP_DISP, display = display.none)
lowSweepZoneCol   = input.color(BULL_COLOR, "",         inline = "sw", group = GP_DISP, tooltip = "Sweep zone colors. First swatch = HIGH-sweep zone (expecting reversal down). Second swatch = LOW-sweep zone (expecting reversal up).", display = display.none)
showSweepX    = input.bool(true,       "Show Sweep X Mark",                                                       group = GP_DISP, tooltip = "Draw an X mark at the wick extreme of every confirmed sweep candle. Color matches the sweep direction (high sweep = bull-sweep zone color, low sweep = bear-sweep zone color).", display = display.none)
showActive    = input.bool(true,    "Show Active Sweep Tracker",                                                                                inline = "act", group = GP_DISP, display = display.none)
activeSize    = input.string("Small", "",            options = ["Tiny", "Small", "Normal", "Large", "Huge"],                                    inline = "act", group = GP_DISP, display = display.none)


// Alerts
alertHighEdge = input.float(1.5, "High-Edge Alert Threshold", minval = 0.5, maxval = 5.0, step = 0.1, group = GP_ALERT, tooltip = "Fire 'High-Edge Sweep' alert when a new sweep occurs on a type with historical edge >= this threshold (min samples required)", display = display.none)

//#endregion Input

//#region Declarations

type Liq
    float  level
    int    bar
    int    createdAt
    string sweepType
    string category
    color  col
    bool   isHigh
    bool   pierced
    int    piercedBar
    float  wickExtreme
    bool   taken
    bool   broken
    int    takenBar
    int    takenTime
    float  takenClose
    float  takenAtr
    float  rvol
    float  wickPct
    float  delta
    bool   completed
    int    completedBar
    float  maxRecovery
    float  maxContin
    line   ln
    label  lbl
    box    zone
    label  verdict
    label  sweepX

type SessBox
    box bx
    int createdAt

type Rec
    string sweepType
    float  recovery
    float  contin
    float  takenAtr
    float  rvol
    float  wickPct
    float  delta
    int    weekday

type Stats
    int    total
    float  avgRec
    float  avgContin
    float  edge

type Sess
    string typeH
    string typeL
    color  col
    float  hi
    float  lo
    int    hiBar
    int    loBar
    int    openTime
    bool   wasIn
    box    bx

//#endregion Declarations

//#region Functions

typeCategory(string t) =>
    if t == T_ASIA_H or t == T_ASIA_L or t == T_LON_H or t == T_LON_L or t == T_NYAM_H or t == T_NYAM_L or t == T_LUNCH_H or t == T_LUNCH_L or t == T_NYPM_H or t == T_NYPM_L
        CAT_SESS
    else if t == T_PDH or t == T_PDL or t == T_PWH or t == T_PWL or t == T_PMH or t == T_PML
        CAT_KEY
    else
        CAT_STRUCT

typeColor(string t) =>
    if t == T_ASIA_H or t == T_ASIA_L
        asiaCol
    else if t == T_LON_H or t == T_LON_L
        londonCol
    else if t == T_NYAM_H or t == T_NYAM_L
        nyamCol
    else if t == T_LUNCH_H or t == T_LUNCH_L
        lunchCol
    else if t == T_NYPM_H or t == T_NYPM_L
        nypmCol
    else if t == T_PDH or t == T_PDL
        pdCol
    else if t == T_PWH or t == T_PWL
        pwCol
    else if t == T_PMH or t == T_PML
        pmCol
    else if t == T_SWING_H or t == T_SWING_L
        swingCol
    else if t == T_EQH or t == T_EQL
        eqCol
    else
        color.gray

labelText(string t) =>
    switch t
        T_ASIA_H => TEXT_ASIA_H
        T_ASIA_L => TEXT_ASIA_L
        T_LON_H  => TEXT_LON_H
        T_LON_L  => TEXT_LON_L
        T_NYAM_H => TEXT_NYAM_H
        T_NYAM_L => TEXT_NYAM_L
        T_LUNCH_H => TEXT_LUNCH_H
        T_LUNCH_L => TEXT_LUNCH_L
        T_NYPM_H => TEXT_NYPM_H
        T_NYPM_L => TEXT_NYPM_L
        => t

lineStyle(string cat) =>
    switch cat
        CAT_KEY    => line.style_solid
        CAT_SESS   => line.style_dashed
        => line.style_dotted

toSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

wdPass(int wd) =>
    switch wd
        1 => wdSun
        2 => wdMon
        3 => wdTue
        4 => wdWed
        5 => wdThu
        6 => wdFri
        7 => wdSat
        => false

tblPos() =>
    switch dashPos
        "Top Right"      => position.top_right
        "Top Center"     => position.top_center
        "Top Left"       => position.top_left
        "Middle Right"   => position.middle_right
        "Middle Center"  => position.middle_center
        "Middle Left"    => position.middle_left
        "Bottom Right"   => position.bottom_right
        "Bottom Center"  => position.bottom_center
        => position.bottom_left

fmtCount(int v) =>
    str.tostring(v) + "    "

getPipSize() =>
    syminfo.mintick * (str.contains(syminfo.ticker, "JPY") ? 100 : 10)

unitConvert(float atrMultiple, float takenAtr) =>
    switch unitDisplay
        "ATR"   => atrMultiple
        "Price" => atrMultiple * takenAtr
        "Pips"  => atrMultiple * takenAtr / getPipSize()
        "Ticks" => atrMultiple * takenAtr / syminfo.mintick
        => atrMultiple

unitFormat() =>
    switch unitDisplay
        "ATR"   => "0.0"
        "Price" => format.mintick
        "Pips"  => "0.0"
        "Ticks" => "0"
        => "0.0"

fmtATR(float v) =>
    (na(v) ? "—" : str.tostring(v, unitFormat())) + "    "

isBest(float v, float best) =>
    not na(v) and not na(best) and v == best

method computeStats(array<Rec> hist, string typeName) =>
    tot = 0
    sumRec = 0.0
    sumContin = 0.0
    if hist.size() > 0
        for j = 0 to hist.size() - 1
            Rec r = hist.get(j)
            if r.sweepType != typeName
                continue
            if not wdPass(r.weekday)
                continue
            if useRvolFilter and (na(r.rvol) or r.rvol < minRvol)
                continue
            if useWickFilter and (na(r.wickPct) or r.wickPct < minWickPct)
                continue
            if useDeltaFilter and (na(r.delta) or r.delta < minDeltaPct)
                continue
            tot += 1
            sumRec += unitConvert(r.recovery, r.takenAtr)
            sumContin += unitConvert(r.contin, r.takenAtr)
    avgR = tot > 0 ? sumRec / tot : float(na)
    avgC = tot > 0 ? sumContin / tot : float(na)
    edge = tot > 0 and avgC > 0 ? avgR / avgC : float(na)
    Stats.new(tot, avgR, avgC, edge)

method findBest(array<Rec> hist, array<string> types, string curType, float curEdge, int curN) =>
    bt = curType
    be = curEdge
    bn = curN
    if types.size() > 0
        for k = 0 to types.size() - 1
            t = types.get(k)
            st = hist.computeStats(t)
            if not na(st.edge) and st.total >= minSamples and (na(be) or st.edge > be)
                be := st.edge
                bt := t
                bn := st.total
    [bt, be, bn]

method renderGroup(table tbl, array<Rec> hist, int startRow, string groupName, array<string> types, color rowBg, color tCol, color sCol, string s, float bestEdge) =>
    tbl.cell(0, startRow, groupName, text_color = color.white, text_size = s, bgcolor = #1a2332, text_halign = text.align_center)
    tbl.merge_cells(0, startRow, 4, startRow)
    r = startRow + 1
    if types.size() > 0
        for k = 0 to types.size() - 1
            t = types.get(k)
            st = hist.computeStats(t)
            isB = isBest(st.edge, bestEdge) and st.total >= minSamples
            edgeTxt = na(st.edge) ? "—" : str.tostring(st.edge, "0.00")
            if isB
                edgeTxt += " ★"
            else
                edgeTxt += "    "
            tbl.cell(0, r, "  " + t, text_color = tCol, text_size = s, bgcolor = rowBg, text_halign = text.align_left)
            tbl.cell(1, r, fmtCount(st.total), text_color = st.total < minSamples ? sCol : tCol, text_size = s, bgcolor = rowBg, text_halign = text.align_center)
            tbl.cell(2, r, fmtATR(st.avgRec), text_color = st.avgRec > st.avgContin ? BULL_COLOR : tCol, text_size = s, bgcolor = rowBg, text_halign = text.align_center)
            tbl.cell(3, r, fmtATR(st.avgContin), text_color = st.avgContin > st.avgRec ? BEAR_COLOR : tCol, text_size = s, bgcolor = rowBg, text_halign = text.align_center)
            tbl.cell(4, r, edgeTxt, text_color = isB ? color.white : (na(st.edge) ? sCol : st.edge >= 1.5 ? BULL_COLOR : st.edge >= 1.0 ? tCol : BEAR_COLOR), text_size = s, bgcolor = isB ? BULL_COLOR : rowBg, text_halign = text.align_center)
            r += 1
    r

delAll(n) =>
    if not na(n)
        n.delete()

mkLiq(float lvl, int b, int ct, string t, bool isHi) =>
    Liq.new(lvl, b, ct, t, typeCategory(t), typeColor(t), isHi, false, na, na, false, false, na, na, na, na, na, na, na, false, na, 0.0, 0.0, na, na, na, na, na)

categoryEnabled(string cat, string t) =>
    if cat == CAT_SESS
        showSessLiq
    else if cat == CAT_STRUCT
        if t == T_EQH or t == T_EQL
            showEqLiq
        else
            showSwingLiq
    else
        if t == T_PDH or t == T_PDL
            showPDLiq
        else if t == T_PWH or t == T_PWL
            showPWLiq
        else
            showPMLiq

//#endregion Functions

//#region Calculations

atr = ta.atr(atrLen)
volSma = ta.sma(volume, 20)

[upVolArr, dnVolArr] = request.security_lower_tf(syminfo.tickerid, deltaLtf, [close > open ? volume : 0.0, close < open ? volume : 0.0])

float upVol = 0.0
float dnVol = 0.0
if not na(upVolArr) and upVolArr.size() > 0
    for v in upVolArr
        upVol += v
if not na(dnVolArr) and dnVolArr.size() > 0
    for v in dnVolArr
        dnVol += v
totVol = upVol + dnVol

method markTaken(Liq lv, bool isBroken) =>
    lv.taken     := true
    lv.broken    := isBroken
    lv.takenBar  := bar_index
    lv.takenTime := time
    lv.takenClose := close
    lv.takenAtr  := atr
    rng = high - low
    lv.rvol    := (na(volSma) or volSma <= 0) ? na : volume / volSma
    lv.wickPct := rng > 0 ? (lv.isHigh ? (high - math.max(open, close)) / rng * 100 : (math.min(open, close) - low) / rng * 100) : na
    lv.delta   := totVol > 0 ? (lv.isHigh ? dnVol / totVol * 100 : upVol / totVol * 100) : na

// Pivot detection
pivHi = ta.pivothigh(high, pivotLen, pivotLen)
pivLo = ta.pivotlow(low, pivotLen, pivotLen)

// HTF references
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

var float prevPdh = na
var float prevPdl = na
var float prevPwh = na
var float prevPwl = na
var float prevPmh = na
var float prevPml = na

// State
var levels      = array.new<Liq>()
var sessBoxes   = array.new<SessBox>()
var history     = array.new<Rec>()
var recentPivHi = array.new<float>()
var recentPivLo = array.new<float>()


// Session detection
inAsia   = enableAsia   and not na(time(timeframe.period, asiaTime,   "America/New_York"))
inLondon = enableLondon and not na(time(timeframe.period, londonTime, "America/New_York"))
inNYAM   = enableNYAM   and not na(time(timeframe.period, nyamTime,   "America/New_York"))
inLunch  = enableLunch  and not na(time(timeframe.period, lunchTime,  "America/New_York"))
inNYPM   = enableNYPM   and not na(time(timeframe.period, nypmTime,   "America/New_York"))

method addLevel(array<Liq> arr, float lvl, int b, int ct, string t, bool isHi) =>
    arr.push(mkLiq(lvl, b, ct, t, isHi))

method track(Sess s, bool inSess) =>
    if inSess and not s.wasIn
        s.hi := high
        s.lo := low
        s.hiBar := bar_index
        s.loBar := bar_index
        s.openTime := time
        if showSessBoxes
            s.bx := box.new(bar_index, high, bar_index, low, border_color = color.new(s.col, 50), bgcolor = color.new(s.col, 90), border_width = 1)
            sessBoxes.push(SessBox.new(s.bx, time))
    else if inSess and s.wasIn
        if high > s.hi
            s.hi := high
            s.hiBar := bar_index
        if low < s.lo
            s.lo := low
            s.loBar := bar_index
        if showSessBoxes and not na(s.bx)
            s.bx.set_top(s.hi)
            s.bx.set_bottom(s.lo)
            s.bx.set_right(bar_index)
    else if not inSess and s.wasIn
        levels.addLevel(s.hi, s.hiBar, s.openTime, s.typeH, true)
        levels.addLevel(s.lo, s.loBar, s.openTime, s.typeL, false)
        s.bx := na
    s.wasIn := inSess

findExactBar(float target, bool isHigh, int maxLookback) =>
    result = bar_index
    limit = math.min(math.min(maxLookback, bar_index - 1), 4000)
    if limit > 0
        for i = 1 to limit
            v = isHigh ? high[i] : low[i]
            if v == target
                result := bar_index - i
                break
    result

method trimType(array<Liq> arr, string t, int keepN) =>
    count = 0
    for k = 0 to arr.size() - 1
        if arr.get(k).sweepType == t
            count += 1
    while count > keepN
        oldestIdx = -1
        for k = 0 to arr.size() - 1
            if arr.get(k).sweepType == t
                oldestIdx := k
                break
        if oldestIdx < 0
            break
        Liq oldest = arr.get(oldestIdx)
        delAll(oldest.ln)
        delAll(oldest.lbl)
        delAll(oldest.zone)
        delAll(oldest.verdict)
        delAll(oldest.sweepX)
        arr.remove(oldestIdx)
        count -= 1

// ─── Pivot → Swing/EQH/EQL ────────────────────────────────────────────────

if not na(pivHi)
    pivBar = bar_index - pivotLen
    isEQH = false
    if recentPivHi.size() > 0 and not na(atr) and atr > 0
        thresh = eqhThresh * atr
        for k = 0 to math.min(2, recentPivHi.size() - 1)
            if math.abs(pivHi - recentPivHi.get(recentPivHi.size() - 1 - k)) <= thresh
                isEQH := true
                break
    pivType = isEQH ? T_EQH : T_SWING_H
    if (isEQH and enableEqLiq) or (not isEQH and enableSwingLiq)
        levels.addLevel(pivHi, pivBar, time, pivType, true)
        levels.trimType(pivType, keepStruct)
    recentPivHi.push(pivHi)
    while recentPivHi.size() > 5
        recentPivHi.shift()

if not na(pivLo)
    pivBar = bar_index - pivotLen
    isEQL = false
    if recentPivLo.size() > 0 and not na(atr) and atr > 0
        thresh = eqhThresh * atr
        for k = 0 to math.min(2, recentPivLo.size() - 1)
            if math.abs(pivLo - recentPivLo.get(recentPivLo.size() - 1 - k)) <= thresh
                isEQL := true
                break
    pivType = isEQL ? T_EQL : T_SWING_L
    if (isEQL and enableEqLiq) or (not isEQL and enableSwingLiq)
        levels.addLevel(pivLo, pivBar, time, pivType, false)
        levels.trimType(pivType, keepStruct)
    recentPivLo.push(pivLo)
    while recentPivLo.size() > 5
        recentPivLo.shift()

// ─── HTF level liquidity ──────────────────────────────────────────────────

barsPerDay = math.max(1, math.floor(86400 / timeframe.in_seconds()))

if enablePDLiq and not na(pdh) and (na(prevPdh) or pdh != prevPdh)
    levels.addLevel(pdh, findExactBar(pdh, true, 2 * barsPerDay), time, T_PDH, true)
    levels.trimType(T_PDH, keepPeriod)
    prevPdh := pdh
if enablePDLiq and not na(pdl) and (na(prevPdl) or pdl != prevPdl)
    levels.addLevel(pdl, findExactBar(pdl, false, 2 * barsPerDay), time, T_PDL, false)
    levels.trimType(T_PDL, keepPeriod)
    prevPdl := pdl
if enablePWLiq and not na(pwh) and (na(prevPwh) or pwh != prevPwh)
    levels.addLevel(pwh, findExactBar(pwh, true, 8 * barsPerDay), time, T_PWH, true)
    levels.trimType(T_PWH, keepPeriod)
    prevPwh := pwh
if enablePWLiq and not na(pwl) and (na(prevPwl) or pwl != prevPwl)
    levels.addLevel(pwl, findExactBar(pwl, false, 8 * barsPerDay), time, T_PWL, false)
    levels.trimType(T_PWL, keepPeriod)
    prevPwl := pwl
if enablePMLiq and not na(pmh) and (na(prevPmh) or pmh != prevPmh)
    levels.addLevel(pmh, findExactBar(pmh, true, 32 * barsPerDay), time, T_PMH, true)
    levels.trimType(T_PMH, keepPeriod)
    prevPmh := pmh
if enablePMLiq and not na(pml) and (na(prevPml) or pml != prevPml)
    levels.addLevel(pml, findExactBar(pml, false, 32 * barsPerDay), time, T_PML, false)
    levels.trimType(T_PML, keepPeriod)
    prevPml := pml

// ─── Per-session H/L ──────────────────────────────────────────────────────

var Sess asia   = Sess.new(T_ASIA_H,  T_ASIA_L,  asiaCol,   na, na, na, na, na, false, na)
var Sess london = Sess.new(T_LON_H,   T_LON_L,   londonCol, na, na, na, na, na, false, na)
var Sess nyam   = Sess.new(T_NYAM_H,  T_NYAM_L,  nyamCol,   na, na, na, na, na, false, na)
var Sess lunch  = Sess.new(T_LUNCH_H, T_LUNCH_L, lunchCol,  na, na, na, na, na, false, na)
var Sess nypm   = Sess.new(T_NYPM_H,  T_NYPM_L,  nypmCol,   na, na, na, na, na, false, na)

asia.track(inAsia)
london.track(inLondon)
nyam.track(inNYAM)
lunch.track(inLunch)
nypm.track(inNYPM)

// ─── Session box lookback cleanup ─────────────────────────────────────────

if sessBoxes.size() > 0
    for k = sessBoxes.size() - 1 to 0
        SessBox sb = sessBoxes.get(k)
        if (time - sb.createdAt) > sessLookback * 86400000
            delAll(sb.bx)
            sessBoxes.remove(k)

// ─── Sweep detection: wick pierce + close-back-through within window ────

if levels.size() > 0
    for k = levels.size() - 1 to 0
        Liq lv = levels.get(k)
        if lv.taken
            continue
        if bar_index - lv.bar > 4900
            continue

        wickThrough = lv.isHigh ? high > lv.level : low < lv.level
        closedBack  = lv.isHigh ? close < lv.level : close > lv.level

        if not lv.pierced
            if wickThrough
                lv.pierced := true
                lv.piercedBar := bar_index
                lv.wickExtreme := lv.isHigh ? high : low
                if closedBack
                    lv.markTaken(false)
        else
            if lv.isHigh and high > lv.wickExtreme
                lv.wickExtreme := high
            else if not lv.isHigh and low < lv.wickExtreme
                lv.wickExtreme := low
            if (bar_index - lv.piercedBar) > sweepWindow
                lv.markTaken(true)
            else if closedBack
                lv.markTaken(false)


// ─── Outcome tracking: track ATR magnitudes for X bars after sweep ──────

if levels.size() > 0
    for k = 0 to levels.size() - 1
        Liq lv = levels.get(k)
        if not lv.taken or lv.completed
            continue

        if lv.broken
            lv.completed := true
            lv.completedBar := lv.takenBar
            continue

        if bar_index <= lv.takenBar
            continue

        if not na(lv.takenAtr) and lv.takenAtr > 0
            recovery = lv.isHigh ? (lv.takenClose - low)  / lv.takenAtr : (high - lv.takenClose) / lv.takenAtr
            contin   = lv.isHigh ? (high - lv.takenClose) / lv.takenAtr : (lv.takenClose - low)  / lv.takenAtr
            if recovery > lv.maxRecovery
                lv.maxRecovery := recovery
            if contin > lv.maxContin
                lv.maxContin := contin

        barsSince = bar_index - lv.takenBar
        if barsSince >= watchBars
            lv.completed := true
            lv.completedBar := bar_index
            tdTime = time + 6 * 3600 * 1000
            wdNow = dayofweek(tdTime, "America/New_York")
            history.push(Rec.new(lv.sweepType, lv.maxRecovery, lv.maxContin, lv.takenAtr, lv.rvol, lv.wickPct, lv.delta, wdNow))



// ─── Remove levels after outcome resolves + grace period ─────────────────

if hideOnSwept and levels.size() > 0
    for k = levels.size() - 1 to 0
        Liq lv = levels.get(k)
        readyToRemove = lv.broken ? (bar_index - lv.takenBar) > sweptGrace : (lv.completed and (bar_index - lv.completedBar) > sweptGrace)
        if lv.taken and readyToRemove
            delAll(lv.ln)
            delAll(lv.lbl)
            delAll(lv.zone)
            delAll(lv.verdict)
            delAll(lv.sweepX)
            levels.remove(k)

//#endregion Calculations

//#region Visualizations

// ─── Liquidity level lines  ────────────────────────────────────────

if levels.size() > 0
    for k = levels.size() - 1 to 0
        Liq lv = levels.get(k)
        enabled = categoryEnabled(lv.category, lv.sweepType)

        if lv.category == CAT_SESS and (time - lv.createdAt) > sessLookback * 86400000
            delAll(lv.ln)
            delAll(lv.lbl)
            delAll(lv.zone)
            delAll(lv.verdict)
            delAll(lv.sweepX)
            levels.remove(k)
            continue

        if not enabled
            delAll(lv.ln)
            lv.ln := na
            continue

        if bar_index - lv.bar > 4900
            continue

        if na(lv.ln)
            lv.ln := line.new(lv.bar, lv.level, bar_index + extendBars, lv.level,
                 color = lv.col,
                 style = lineStyle(lv.category),
                 width = 1)
        else if not lv.taken
            lv.ln.set_x2(bar_index + extendBars)

if barstate.islast and levels.size() > 0
    for k = 0 to levels.size() - 1
        Liq lv = levels.get(k)
        delAll(lv.lbl)
        lv.lbl := na
        delAll(lv.zone)
        lv.zone := na
        delAll(lv.sweepX)
        lv.sweepX := na
        if not categoryEnabled(lv.category, lv.sweepType)
            continue
        if lv.category == CAT_SESS and (time - lv.createdAt) > sessLookback * 86400000
            continue
        if bar_index - lv.bar > 4900
            continue
        suffix = ""
        if showDaySuffix and lv.category == CAT_SESS and sessLookback > 1
            daysAgo = math.floor((time - lv.createdAt) / 86400000)
            if daysAgo == 0
                suffix := " (Today)"
            else if daysAgo == 1
                suffix := " (Yest)"
            else
                suffix := " (-" + str.tostring(daysAgo) + "d)"
        tfMs   = timeframe.in_seconds() * 1000
        labelX = lv.taken ? lv.takenTime + extendBars * tfMs : time + extendBars * tfMs
        lv.lbl := label.new(labelX, lv.level, " " + labelText(lv.sweepType) + suffix + " ",
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = color.new(lv.col, 70),
             textcolor = chart.fg_color,
             size = toSize(labelSize))

        if lv.taken and not lv.broken
            if showSweepZone
                zCol = lv.isHigh ? highSweepZoneCol : lowSweepZoneCol
                yTop = lv.isHigh ? lv.wickExtreme : lv.level
                yBot = lv.isHigh ? lv.level : lv.wickExtreme
                lv.zone := box.new(lv.bar, yTop, lv.takenBar, yBot,
                     bgcolor = color.new(zCol, 80),
                     border_color = color.new(zCol, 100))
            if showSweepX
                xCol = lv.isHigh ? highSweepZoneCol : lowSweepZoneCol
                lv.sweepX := label.new(lv.takenBar, lv.wickExtreme, "",
                     style = label.style_xcross,
                     color = xCol,
                     size = 4)

// ─── Dashboard ───────────────────────────────────────────────────────────

var table dash = na

if showDash and barstate.islast
    if not na(dash)
        dash.delete()

    sz = toSize(dashSize)

    isDark = dashTheme == "Dark Mode"
    bgRow  = isDark ? BG_DARK_DARK   : BG_DARK_LIGHT
    bgHdr  = isDark ? BG_HEADER_DARK : BG_HEADER_LIGHT
    bgTitle = isDark ? BG_TITLE_DARK : BG_TITLE_LIGHT
    txtCol = isDark ? TEXT_DARK      : TEXT_LIGHT
    subCol = isDark ? SUBTEXT_DARK   : SUBTEXT_LIGHT

    sessTypes = array.new<string>()
    if enableAsia
        sessTypes.push(T_ASIA_H)
        sessTypes.push(T_ASIA_L)
    if enableLondon
        sessTypes.push(T_LON_H)
        sessTypes.push(T_LON_L)
    if enableNYAM
        sessTypes.push(T_NYAM_H)
        sessTypes.push(T_NYAM_L)
    if enableLunch
        sessTypes.push(T_LUNCH_H)
        sessTypes.push(T_LUNCH_L)
    if enableNYPM
        sessTypes.push(T_NYPM_H)
        sessTypes.push(T_NYPM_L)

    keyTypes = array.new<string>()
    if enablePDLiq
        keyTypes.push(T_PDH)
        keyTypes.push(T_PDL)
    if enablePWLiq
        keyTypes.push(T_PWH)
        keyTypes.push(T_PWL)
    if enablePMLiq
        keyTypes.push(T_PMH)
        keyTypes.push(T_PML)

    structTypes = array.new<string>()
    if enableSwingLiq
        structTypes.push(T_SWING_H)
        structTypes.push(T_SWING_L)
    if enableEqLiq
        structTypes.push(T_EQH)
        structTypes.push(T_EQL)

    bestType = ""
    bestEdge = float(na)
    bestN = 0
    [bt1, be1, bn1] = history.findBest(sessTypes, bestType, bestEdge, bestN)
    bestType := bt1
    bestEdge := be1
    bestN := bn1
    [bt2, be2, bn2] = history.findBest(keyTypes, bestType, bestEdge, bestN)
    bestType := bt2
    bestEdge := be2
    bestN := bn2
    [bt3, be3, bn3] = history.findBest(structTypes, bestType, bestEdge, bestN)
    bestType := bt3
    bestEdge := be3
    bestN := bn3

    nC = 5
    rowCount = 2
    if not na(bestEdge)
        rowCount += 1
    if sessTypes.size() > 0
        rowCount += 1 + sessTypes.size()
    if keyTypes.size() > 0
        rowCount += 1 + keyTypes.size()
    if structTypes.size() > 0
        rowCount += 1 + structTypes.size()

    dash := table.new(tblPos(), nC, rowCount, bgcolor = bgRow, border_width = 1, border_color = #3d3d3d, frame_width = 1, frame_color = #3d3d3d)

    row = 0

    filteredCount = 0
    if history.size() > 0
        for j = 0 to history.size() - 1
            Rec r = history.get(j)
            if not wdPass(r.weekday)
                continue
            if useRvolFilter and (na(r.rvol) or r.rvol < minRvol)
                continue
            if useWickFilter and (na(r.wickPct) or r.wickPct < minWickPct)
                continue
            if useDeltaFilter and (na(r.delta) or r.delta < minDeltaPct)
                continue
            filteredCount += 1

    title = "  LIQUIDITY SWEEP PROFILER  ·  " + str.tostring(filteredCount) + " sweeps  "
    dash.cell(0, row, title, text_color = txtCol, text_size = sz, bgcolor = bgTitle, text_halign = text.align_center)
    dash.merge_cells(0, row, nC - 1, row)
    row += 1

    if not na(bestEdge)
        bannerTxt = "★ BEST EDGE: " + bestType + " · " + str.tostring(bestEdge, "0.00") + " (" + str.tostring(bestN) + " sweeps)"
        dash.cell(0, row, bannerTxt, text_color = color.white, text_size = sz, bgcolor = BULL_COLOR, text_halign = text.align_center)
        dash.merge_cells(0, row, nC - 1, row)
        row += 1

    dash.cell(0, row, "Type",     text_color = chart.fg_color, text_size = sz, bgcolor = bgHdr, text_halign = text.align_left,   tooltip = "Liquidity type swept")
    dash.cell(1, row, "Total\nSweeps", text_color = chart.fg_color, text_size = sz, bgcolor = bgHdr, text_halign = text.align_center, tooltip = "Total resolved sweeps (window expired)")
    dash.cell(2, row, "Avg. " + unitDisplay + "\nRecovery",     text_color = chart.fg_color, text_size = sz, bgcolor = bgHdr, text_halign = text.align_center, tooltip = "Average favorable excursion (recovery from sweep close), expressed in the selected display unit")
    dash.cell(3, row, "Avg. " + unitDisplay + "\nBreach", text_color = chart.fg_color, text_size = sz, bgcolor = bgHdr, text_halign = text.align_center, tooltip = "Average adverse excursion (how far price breached past the swept level), expressed in the selected display unit")
    dash.cell(4, row, "Edge",     text_color = chart.fg_color, text_size = sz, bgcolor = bgHdr, text_halign = text.align_center, tooltip = "Avg Recovery / Avg Breach. > 1 = type tends to deliver more reversal than breach")
    row += 1

    if sessTypes.size() > 0
        row := dash.renderGroup(history, row, "SESSIONS", sessTypes, bgRow, txtCol, subCol, sz, bestEdge)
    if keyTypes.size() > 0
        row := dash.renderGroup(history, row, "KEY LEVELS", keyTypes, bgRow, txtCol, subCol, sz, bestEdge)
    if structTypes.size() > 0
        row := dash.renderGroup(history, row, "STRUCTURE", structTypes, bgRow, txtCol, subCol, sz, bestEdge)

// ─── Active Sweep Tracker ────────────────────────────────────────────────

var label activeLbl = na

if showActive and barstate.islast
    if not na(activeLbl)
        activeLbl.delete()
        activeLbl := na

    Liq mostRecent = na
    int mrBar = -1
    if levels.size() > 0
        for k = 0 to levels.size() - 1
            Liq lv = levels.get(k)
            if lv.taken and not lv.broken and not lv.completed
                if lv.takenBar > mrBar
                    mrBar := lv.takenBar
                    mostRecent := lv

    if not na(mostRecent)
        float curRec  = na
        float curCont = na
        if not na(mostRecent.takenAtr) and mostRecent.takenAtr > 0
            curRec := mostRecent.isHigh ? (mostRecent.takenClose - low) / mostRecent.takenAtr : (high - mostRecent.takenClose) / mostRecent.takenAtr
            curCont := mostRecent.isHigh ? (high - mostRecent.takenClose) / mostRecent.takenAtr : (mostRecent.takenClose - low) / mostRecent.takenAtr
        useRec = math.max(mostRecent.maxRecovery, na(curRec) ? 0.0 : curRec)
        useCont = math.max(mostRecent.maxContin, na(curCont) ? 0.0 : curCont)

        barsIn = bar_index - mostRecent.takenBar

        hStats = history.computeStats(mostRecent.sweepType)

        actTxt = "● ACTIVE: " + labelText(mostRecent.sweepType) + "\n"
        actTxt += "Bar " + str.tostring(barsIn) + " / " + str.tostring(watchBars) + "\n"
        actTxt += "Now: +" + str.tostring(unitConvert(useRec, mostRecent.takenAtr), unitFormat()) + " / -" + str.tostring(unitConvert(useCont, mostRecent.takenAtr), unitFormat()) + "\n"
        if not na(hStats.avgRec) and hStats.total >= minSamples
            actTxt += "Hist: +" + str.tostring(hStats.avgRec, unitFormat()) + " / -" + str.tostring(hStats.avgContin, unitFormat())
            if not na(hStats.edge)
                actTxt += " · Edge " + str.tostring(hStats.edge, "0.00")
        else
            actTxt += "Hist: insufficient data"

        actCol = useRec > useCont ? BULL_COLOR : BEAR_COLOR
        activeLbl := label.new(bar_index + 5, close, actTxt,
             style = label.style_label_left,
             color = color.new(actCol, 75),
             textcolor = color.white,
             size = toSize(activeSize))
else if not showActive
    if not na(activeLbl)
        activeLbl.delete()
        activeLbl := na

// ─── Alerts ──────────────────────────────────────────────────────────────

newSweepFired = false
highEdgeFired = false
alertedType = ""
alertedEdge = 0.0

if levels.size() > 0
    for k = 0 to levels.size() - 1
        Liq lv = levels.get(k)
        if lv.taken and not lv.broken and lv.takenBar == bar_index
            newSweepFired := true
            alertedType := lv.sweepType
            hs = history.computeStats(lv.sweepType)
            if not na(hs.edge) and hs.total >= minSamples and hs.edge >= alertHighEdge
                highEdgeFired := true
                alertedEdge := hs.edge

alertcondition(newSweepFired, "New Sweep",      "New liquidity sweep detected on {{ticker}} {{interval}}")
alertcondition(highEdgeFired, "High-Edge Sweep", "Sweep on a high-edge liquidity type detected on {{ticker}} {{interval}}")

//#endregion Visualizations
````
