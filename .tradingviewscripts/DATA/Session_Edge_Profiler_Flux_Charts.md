<!-- tradingview-pine-id: PUB;74d7271fe8b94ddf8ea8c8f59315d370 -->
<!-- tradingviewscripts-format: 1 -->
# Session Edge Profiler | Flux Charts

Source: https://www.tradingview.com/script/T1V41Bl5-Session-Edge-Profiler-Flux-Charts/

## Description

GENERAL OVERVIEW:
The Session Edge Profiler is a statistical dashboard indicator that profiles up to five configurable trading sessions (Asia, London, NY AM, NY Lunch, NY PM by default) across the available completed trading days loaded on the chart. The indicator records each session's range, volume, directional outcome, and smart money structure (Fair Value Gaps, swing breaks, higher highs, lower lows) on every completed day, then surfaces the resulting statistics in a configurable on-chart dashboard with progress bars and best value markers.

For every metric, the indicator filters history by the selected weekdays. Range-based metrics are normalized against the previous daily ATR for cross-volatility comparison, while volume, directional, extreme, and structure metrics are calculated directly from completed session records. The indicator also computes percentile rankings of the current session range against its historical distribution. Session boxes can be plotted for visual reference, and a live label tracks the active session's running range against its historical average and percentile rank in real time. The indicator is statistical, session based, dashboard driven, and includes one alert condition for sessions exceeding the 90th percentile of their historical range distribution.

https://www.tradingview.com/x/mfFkg0IT/ [Screenshot: Full chart view showing the indicator deployed end to end. Dashboard table anchored in a corner with all metric rows visible]

WHAT IS THE THEORY BEHIND THE INDICATOR?:
Markets do not move uniformly across the day. Each trading session carries different participant types, different volume profiles, and different structural behaviors. The Asia session tends to be range bound and accumulative. The London session frequently sweeps overnight liquidity. NY AM often produces the largest expansions of the day. NY Lunch is typically the lowest volume window. NY PM frequently reverses or extends NY AM moves into the close.

These tendencies are widely cited but rarely measured per instrument. The Session Edge Profiler quantifies them. By recording per session statistics across the historical window available on the chart, and by filtering by selected weekdays, the indicator builds an empirical profile of how each session has actually behaved on a specific symbol rather than relying on generalized assumptions. The result is a session level statistical profile that can be compared against the current session in real time, identifying when a given session is behaving unusually large, unusually quiet, or consistent with its historical edge.

https://www.tradingview.com/x/KYStX7u4/  [Screenshot: Close up of session range boxes]

SESSION EDGE PROFILER FEATURES:
◇ Session tracking with customizable times, names, and colors
◇ Statistical dashboard with up to thirteen configurable metrics
◇ ATR normalized range comparison across sessions
◇ Today percentile ranking of the live session range
◇ Daily extremes tracking (HOD %, LOD %)
◇ Directional statistics (Bull %, Continuation %)
◇ Volume profiling (Vol Share %, Avg Vol)
◇ Smart money structure analytics (FVGs, Swing Breaks, FVG Survival, HH, LL)
◇ Active session live label with real time percentile and average comparison
◇ Session range boxes with current and historical display
◇ Weekday filtering applied uniformly across all statistics
◇ Dashboard theming (Dark or Light), nine position options, and five text sizes
◇ High percentile range alert

SESSION TRACKING AND RANGE BOXES:
🔹What is Session Tracking?
Session Tracking is the foundation of the indicator. Five configurable session windows are monitored on every bar. When price enters a session window, the indicator opens an active tracking object that records the session's high, low, open price, total volume, and structural events. When price leaves the session window, the active object is closed and its values are committed to the historical record for that session.

🔹Why is Session Tracking important?
Every statistic computed by the indicator depends on accurately segmenting the trading day into sessions. Without a reliable session lifecycle, range comparisons, HOD/LOD attribution, volume share, and structure counts would be inconsistent. The session lifecycle also defines what gets drawn on the chart: the live range box for the current session and, optionally, persistent boxes for historical sessions.

🔹How is Session Tracking detected and calculated?
Every bar is checked against the configured session time windows in New York time. The moment price enters a session window, a new session opens: the session's high, low, open, and volume start fresh, and the FVG, swing break, HH, and LL counters reset to zero. While the session is active, the high updates to the running maximum, the low updates to the running minimum, and volume accumulates with each new bar. When price leaves the session window, the session is closed: the final high, low, open, close, and volume are committed and the session is marked complete for the day.

A trading day boundary is determined by shifting time forward by 6 hours and comparing the resulting calendar date in New York time. This shift causes a new day to register at 18:00 NY time, aligning the trading day with the start of the Asia session at 19:00 NY. When a new trading day begins, the completed session statistics from the previous day are added to each session's history along with the weekday they were recorded on, the daily fields reset, and a new tracking cycle begins.

🔹Settings: Sessions Group
◇ Enable Toggle: Turns the session on or off. Disabled sessions are excluded from the dashboard, the live label, and all calculations.
◇ Session Name: Custom label used in the dashboard column header, on the session box, and in the active session label. Defaults: Asia, London, NY AM, NY Lunch, NY PM.
◇ Session Time: The session window in NY time using HHMM,HHMM format. Defaults: Asia 1900,0200, London 0200,0830, NY AM 0830,1200, NY Lunch 1200,1330, NY PM 1330,1600.
◇ Session Color: Color applied to the dashboard column header (when active), the session box border and background, and the active session label.

🔹Customization
Display Group
◇ Show Session Ranges: When enabled, plots a translucent box around the current session showing its running high and low, with the session name labeled in the top left corner. Historical session boxes are also retained on the chart for visual reference.
◇ Show Active Session Stats: When enabled, plots a live label next to the most recent bar of the active session displaying the session name, current range, current range as a percentage of historical average, and current percentile rank.
◇ Label Size: Sets the text size of the active session label. Options: Tiny, Small, Normal, Large, Huge.

STATISTICAL DASHBOARD:
🔹What is the Statistical Dashboard?
The Statistical Dashboard is a configurable table that summarizes the historical statistical profile of every enabled session. Rows correspond to metrics. Columns correspond to sessions. Each cell shows the metric value for that session, optionally rendered with a unicode progress bar and a star marker (★) for the session with the highest value on metrics where "highest" is the meaningful target.

🔹Why is the Statistical Dashboard important?
The dashboard is where the indicator's measurements surface. Rather than requiring a trader to scroll through chart history and visually estimate session behavior, the dashboard reduces the entire weekday filtered history of every session to a compact table of directly comparable numbers. The header line shows the active weekday filter and the maximum number of historical days used in any cell, providing immediate context for the statistical sample size.

🔹How is the Statistical Dashboard calculated?
On the most recent bar of the chart, the indicator reviews each enabled session's stored history. For every past session, it checks whether the weekday it was recorded on is included in the selected weekday filter. If yes, the session contributes to the running totals: range sums, volume sums, HOD/LOD counts, bull counts, continuation counts, FVG counts, swing break counts, HH counts, LL counts, and volume share. After the review, totals are converted to averages or percentages and written to the dashboard cells.

Best value markers are computed by tracking the maximum value across all enabled sessions for the metrics where "highest" is the intended target: Avg Range, HOD %, LOD %, Avg FVGs, and FVG Survival %. For metrics where directional bias matters (Bull %, Continuation %) or where higher is not strictly better (Vol Share %, Avg Swing Breaks, Avg HH, Avg LL), no best marker is shown.

https://www.tradingview.com/x/Kdrw1vcg/ [Screenshot: Full dashboard table screenshot in Dark Mode with every metric row enabled. Header line showing the active weekday filter and sample size, column headers in each session's color, progress bars rendered in percentage cells, and the SMART MONEY divider row visible separating the structural metrics from the range and directional metrics above.

https://www.tradingview.com/x/koRBC2gY/ [Screenshot: Same dashboard with progressbar enabled]

🔹Settings: Dashboard Group
◇ Show Dashboard: Master toggle for the entire dashboard. When disabled, no table is rendered.
◇ Theme: Dark Mode or Light Mode. Controls background, row, header, and text colors. The best value highlight cell uses a deeper accent color on the selected theme.
◇ Position: Table placement on the chart. Options cover all nine combinations of vertical (Top, Middle, Bottom) and horizontal (Left, Center, Right) anchoring.
◇ Text Size: Tiny, Small, Normal, Large, Huge. Affects every cell.
◇ Show Progress Bars: When enabled, percentage and percentile cells render an 8 segment unicode bar alongside the numeric value, scaling from 0% to 100%. When disabled, only the numeric value is shown.

🔹Customization
Metric Toggles
Each of the following dashboard rows can be independently shown or hidden:
◇ Avg Range (ATR%)
◇ Vol Share %
◇ Avg Vol
◇ HOD %
◇ LOD %
◇ Bull %
◇ Continuation %
◇ Today Percentile
◇ Avg FVGs
◇ Avg Swing Breaks
◇ FVG Survival %
◇ Avg HH
◇ Avg LL

🔹Signal Colors
◇ High: Color applied to high tier values (Today Percentile at or above 75, FVG Survival at or above 70). Default: green.
◇ Mid: Color applied to mid tier values (Today Percentile between 25 and 75, FVG Survival between 40 and 70). Default: orange.
◇ Low: Color applied to low tier values (Today Percentile at or below 25, FVG Survival below 40). Default: red.

ATR NORMALIZED RANGE STATISTICS:
🔹What is ATR Normalized Range?
The Avg Range (ATR%) metric expresses each session's average range as a percentage of the daily Average True Range. A value of 45% means the session, on average, covered 45% of a full day's ATR.

🔹Why is ATR Normalized Range important?
Raw range values cannot be compared across instruments or across volatility regimes. A 200 point range means very different things in calm versus volatile markets. Normalizing by daily ATR removes that distortion: the resulting percentage is directly comparable between sessions, between symbols, and between months of history.

🔹How is ATR Normalized Range calculated?
For each completed session, the raw range (session high minus session low) is divided by the daily ATR value of the previous completed day. The daily ATR uses a configurable length (default 14) and is always read from the previous daily bar, which means the value is fixed for the entire current trading day and never repaints. The session's normalized range is stored alongside its weekday in the history. When the dashboard renders, the indicator averages all normalized ranges from sessions whose weekday passes the filter, then multiplies by 100 to produce the displayed percentage.

🔹What is Today Percentile?
Today Percentile expresses where the current session's live range sits within the historical distribution of that same session's past ranges. The comparison stays within the session: today's London is compared only against past Londons, today's NY AM only against past NY AMs, and so on, all filtered by the selected weekdays. A value of 80 means the live range is larger than 80% of past occurrences of the same session on those weekdays.

🔹How is Today Percentile calculated?
For each enabled session, the indicator computes the current normalized range (current session range divided by daily ATR). It then walks through that session's own past history, counting how many past sessions have a normalized range less than or equal to the current value, while skipping any past session whose weekday is not enabled in the filter. The percentile is the percentage of qualifying past sessions at or below the current value.

The cell color reflects the tier: at or above 75 uses the High color, at or below 25 uses the Low color, otherwise the Mid color. The numeric value is rendered with an ordinal suffix (1st, 2nd, 3rd, 4th, and so on) for readability, and the progress bar segments scale from 0 to 100.

https://www.tradingview.com/x/DkvxIOlQ/ [screenshot: Dashboard zoomed to show the Avg Range (ATR%) row and the Today Percentile row across all five sessions.]

🔹Settings:Filters Group
◇ ATR Length: Lookback for the daily ATR used in normalization. Range: 5 to 50. Default: 14.

DAILY EXTREMES TRACKING:
🔹What are HOD % and LOD %?
HOD % measures how often a given session contained the day's highest price. LOD % measures how often it contained the day's lowest price. Both are expressed as a percentage of the total weekday filtered days in history.

🔹Why are HOD/LOD statistics important?
Knowing which session historically sets the daily extreme on a given instrument helps frame intraday liquidity expectations. A session with a high HOD % is the session that most frequently posts the day's selling extreme. A session with a high LOD % most frequently posts the day's buying extreme. On many instruments NY AM dominates both, but the ratio shifts by symbol and by weekday, which is why measuring rather than assuming is useful.

🔹How are HOD % and LOD % calculated?
While the trading day is in progress, the indicator continuously tracks the day's running high and running low across all bars, not just within session windows. When a new trading day begins, every completed session from the previous day is checked: if the session's recorded high matches the day's high, that session is tagged as the HOD session; if its low matches the day's low, it is tagged as the LOD session. These tags are stored with the session in history. When the dashboard renders, it counts how many sessions in the weekday filtered history carry each tag and converts those counts to percentages. The session with the highest HOD % across all enabled sessions receives a star marker, and the same applies to LOD %.

https://www.tradingview.com/x/lY58T5s1/ [Screenshot: A chart showing one full trading day with all session range boxes plotted, with HOD and LOD Printing sessions highlighted]

DIRECTIONAL STATISTICS:
🔹What are Bull % and Continuation %?
Bull % is the percentage of historical sessions that closed higher than they opened. Continuation % is the percentage of historical sessions whose direction matched the previous occurrence of the same session.

🔹Why are directional statistics important?
Bull % captures the session's directional skew. A session with Bull % consistently above 60% on a particular instrument and weekday set has a measurable upward tendency. Continuation % captures the session's persistence: a high continuation rate means the session frequently extends the previous day's same session direction, while a low rate suggests the session tends to reverse the prior day's bias.

https://www.tradingview.com/x/DDRP9qWO/ [Screenshot: Dashboard showing the Bull % and Continuation % rows across all five sessions.]

🔹How are Bull % and Continuation % calculated?
For each completed session, Bull is true when the session's close (the chart close at the bar where the session ended) exceeds its open. Continuation is true when the previous occurrence of the same session was bullish in the same direction (both bullish or both bearish). The very first occurrence in history has no previous reference and is excluded from the continuation calculation. The dashboard divides the bullish session count by the total session count for Bull %, and the matched continuation count by the continuation eligible count for Continuation %.
No best value marker is shown for either metric, since "highest" is not inherently better: directional bias and continuation are interpretive measurements rather than competitive ones across sessions.

VOLUME PROFILING:
🔹What is Volume Profiling?
The indicator tracks two volume metrics per session: Vol Share % (the session's average share of total daily volume) and Avg Vol (the session's average absolute volume).

🔹Why is Volume Profiling important?
Volume distribution across the day reveals participant activity. Sessions that historically account for a disproportionate share of daily volume are the sessions where flow is most concentrated. Sessions with low volume share (typically NY Lunch) are statistical low conviction windows where moves are more likely to be lower quality.

🔹How is Volume Profiling calculated?
While each session is active, the indicator accumulates bar volume into the session's running total. When the trading day rolls over, total day volume is computed as the sum of all completed session volumes for that day. Each session's Vol Share is then computed as its session volume divided by total day volume, multiplied by 100, and saved into the session's history alongside the absolute volume. When the dashboard renders, Avg Vol is the simple weekday filtered mean of recorded session volumes, and Vol Share % is averaged across the weekday filtered history.

https://www.tradingview.com/x/SdkfvBNZ/  [Screenshot: Dashboard showing the Vol Share % and Avg Vol rows across all five sessions.]

SMART MONEY STRUCTURE ANALYTICS:
🔹What are the Smart Money metrics?
The Smart Money section of the dashboard surfaces four structural counters per session:
◇ Avg FVGs: average number of Fair Value Gaps formed during the session.
◇ Avg Swing Breaks: average instances where the close pierces a previously confirmed pivot high or pivot low.
◇ FVG Survival %: percentage of FVGs that were not invalidated within the same session in which they formed.
◇ Avg HH and Avg LL: average count of new higher highs and lower lows in pivot structure during the session.

🔹Why are Smart Money metrics important?
These metrics quantify the structural activity of each session. High FVG counts indicate aggressive displacement and gap creation. High Swing Break counts indicate liquidity sweeps and structural inflection. FVG Survival measures how often gaps formed during the session are respected (not immediately filled in the opposite direction), giving a session level reliability score for the FVG concept. HH and LL counts profile each session's tendency to extend structure in one direction versus the other.

🔹How are Smart Money metrics calculated?
A Fair Value Gap is detected as a 3 bar pattern: a bullish FVG forms when the current bar's low sits above the high from two bars ago, and a bearish FVG forms when the current bar's high sits below the low from two bars ago. Whenever an FVG forms during an active session, the session's FVG counter increments and the gap level (the high from two bars ago for a bullish FVG, the low from two bars ago for a bearish FVG) is added to a list of active gaps for that session, along with its direction.

On every later bar within the same session, the indicator checks each active gap. If price closes below a bullish FVG's level, or closes above a bearish FVG's level, the gap is treated as invalidated and removed from the active list, and the session's invalidation counter increments. At the end of the session, FVG Survival % is computed as the count of total FVGs minus invalidated FVGs, divided by total FVGs, expressed as a percentage. The cell is color coded by tier: at or above 70 uses High, at or above 40 uses Mid, otherwise Low.

Swing breaks use a configurable pivot strength (default 5 bars on each side). When a pivot high confirms and price subsequently closes above that pivot level, a bullish swing break fires and the pivot is consumed (cleared from active tracking). The same applies symmetrically for pivot lows. Each break increments the active session's Swing Break counter.

HH and LL counts use the same pivot detection. When a new pivot high confirms with a level greater than the session's previous tracked pivot high, the session's HH counter increments. When a new pivot low confirms with a level less than the session's previous tracked pivot low, the LL counter increments.

https://www.tradingview.com/x/hJymO62Y/ [Screenshot:: Session range box showing visible structural activity: with Swing Breaks and Survived FVG]

🔹Settings: Filters Group
◇ Pivot Strength: Bars on each side required to confirm a pivot high or pivot low for the swing break and HH/LL calculations. Range: 2 to 20. Default: 5. Higher values produce fewer, more significant pivots; lower values produce more frequent, noisier pivots.

ACTIVE SESSION LIVE LABEL:
🔹What is the Active Session Live Label?
A floating label that appears next to the most recent bar of the active session, displaying live statistics for the session currently in progress.

🔹Why is the Active Session Live Label important?
The dashboard summarizes completed historical sessions. The live label answers a different question: how does the session that is currently developing compare to history, right now? It allows a trader to see, mid session, whether the current session is tracking above, near, or below its average range and what percentile it currently occupies, without waiting for the session to close.

🔹How is the Active Session Live Label calculated?
The label content includes the session name, the live range (current session high minus current session low), the ratio of the live normalized range to the historical average normalized range expressed as a percentage, and the current percentile. The percentile is computed by iterating the session's weekday filtered history and counting how many records have a normalized range at or below the live value.

The label position updates every bar to track the right edge of the current session at its current high. When the session ends, the label is deleted.

https://www.tradingview.com/x/yWU2X6Kt/ [screenshot: Active session in progress on the chart with the floating live label attached to the right edge of the current session at its current high. The label content should clearly show the session name, the live range value, the "vs Avg" percentage, and the current percentile rank, demonstrating the real time positional context the label provides while the session is still developing.]

🔹Settings
◇ Show Active Session Stats: Toggle for the label.
◇ Label Size: Sets text size. Options: Tiny, Small, Normal, Large, Huge.

WEEKDAY FILTERING:
🔹What is Weekday Filtering?
A set of seven toggles (Sunday through Saturday) that determines which weekdays contribute to every statistic on the dashboard, the live label, and the alert condition.

🔹Why is Weekday Filtering important?
Session behavior is not uniform across the week. Monday open behavior differs from midweek behavior. Friday afternoon often shows reduced participation. By filtering history to only the selected weekdays, traders can profile each session under conditions that match the current trading day, rather than averaging in unrelated days.

🔹How is Weekday Filtering applied?
Each session in history is tagged with the weekday it was recorded on. Every calculation in the dashboard, the live label, and the alert checks that weekday against the user's selection and skips any session whose weekday is not enabled. The dashboard header line displays a compact label of the active filter: "All" when every weekday is enabled, "Weekdays" when only Monday through Friday are enabled, or a custom combination such as "M/Tu/W" otherwise. The header also shows the largest number of sessions any column was able to use after filtering, which serves as the sample size indicator.

🔹Settings: Filters Group
◇ Sun, Mon, Tue, Wed, Thu, Fri, Sat: Individual toggles. Defaults: Mon, Tue, Wed, Thu, Fri enabled; Sun and Sat disabled.
https://www.tradingview.com/x/HkxFbk4k/ [Screenshot: Two dashboards side by side from the same chart and instrument: one with all weekdays enabled (header shows "All"), and one with only Monday enabled (header shows "M")]

ALERTS:
🔹What alerts are available?
A single alert condition is provided:
◇ Range > 90th Percentile: Fires when an active session's current normalized range exceeds the 90th percentile of its weekday filtered historical normalized range distribution.

🔹When does it fire?
On every bar where at least one enabled, active session has a current normalized range above which 90% of its history sits. The alert fires once per qualifying bar, allowing traders to be notified when a session is in the process of becoming statistically large relative to its own history.

IMPORTANT NOTES:
◇ All session times are evaluated in New York time regardless of the chart's display timezone. Adjust session times if profiling instruments where session timing conventions differ from the defaults.
◇ Trading day boundaries are anchored to 18:00 NY time (the 6 hour shift before midnight) so that the Asia session opens at the start of each new trading day. This is the convention used for HOD/LOD attribution and for pushing completed session records to history.
◇ Daily ATR is always read from the previous completed daily bar. This means the value used for normalization is fixed for the current trading day and does not repaint as new bars print, while still giving the live percentile calculations a stable reference.
◇ The session history for each session is built progressively as the chart loads. Sessions on the very first day on the chart cannot contribute to continuation statistics because no earlier occurrence of the same session exists to compare against.
◇ Best value markers (★) are shown only on metrics where "highest" is the meaningful target: Avg Range, HOD %, LOD %, Avg FVGs, and FVG Survival %. Other metrics intentionally omit the marker.
◇ FVG Survival counts gaps that survive to the end of the session in which they formed. A gap that survives the session but is invalidated on a later day is still counted as survived for the session that created it.

UNIQUENESS:
The Session Edge Profiler distinguishes itself from common session indicators in several ways. Most session tools plot boxes and stop there, while this indicator extends session tracking into a full statistical profile with thirteen configurable metrics per session, reducing the entire history of every session to a single, scannable table. Range comparisons use ATR normalization rather than raw point values, making the dashboard meaningful across volatility regimes and instruments without per chart recalibration, and percentile ranking of the live session against history provides a single number answer to a question many traders ask intuitively: is this session unusually large or unusually small for this time and this weekday? FVG and swing break tracking are integrated into the session profile rather than treated as separate indicators, allowing direct comparison of which session produces the most structural activity and how reliable that structure tends to be on a given instrument. FVG Survival % quantifies a concept that is rarely measured anywhere else: how often each session's FVGs actually hold within their own session, converting a qualitative idea into a session level reliability score. Weekday filtering applies uniformly to every statistic on the dashboard, the live label, and the alert, allowing traders to profile sessions only on days that match the current trading day rather than diluting the sample with unrelated weekdays. Best value markers and progress bars make the dashboard scannable at a glance, with the strongest session per metric immediately visible without parsing numbers. Finally, the active session live label provides real time positional context that complements the historical dashboard: the dashboard answers what a session usually does, while the label answers what the session is doing right now, with both views driven by the same underlying statistical model.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fluxchart

//@version=6
indicator("Session Edge Profiler | Flux Charts", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 5000)

//#region Constants

const string GP_SESS = "Sessions"
const string GP_FILT = "Filters"
const string GP_DASH = "Dashboard"
const string GP_DISP = "Display"

const color ORANGE   = #FF6D00
const color BLUE     = #2962FF
const color GREEN    = #00C853
const color PURPLE   = #AA00FF
const color RED      = #FF1744
const color YELLOW   = #FFC107
const color GRAY     = #808080

// Intensity Colors
const color BULL_COLOR = #089981
const color BEAR_COLOR = #f23645
const color MID_COLOR  = color.orange

// Dashboard Theme Colors
const color BG_DARK_DARK       = color.rgb(30, 30, 30)
const color BG_DARK_LIGHT      = color.rgb(245, 245, 245)
const color BG_HEADER_DARK     = color.rgb(30, 30, 40)
const color BG_HEADER_LIGHT    = color.rgb(230, 230, 240)
const color BG_ROW_DARK        = #1a2332
const color BG_ROW_LIGHT       = #e8edf5
const color BG_BEST_DARK       = #1a5276
const color BG_BEST_LIGHT      = #c8ddf0
const color TEXT_DARK          = color.rgb(210, 210, 210)
const color TEXT_LIGHT         = color.rgb(30, 30, 30)

//#endregion Constants

//#region Input

enAsia       = input.bool(true,          "",               inline = "s1",  group = GP_SESS, display = display.none)
nameAsia     = input.string("Asia",     "",                inline = "s1",  group = GP_SESS, display = display.none)
asiaTime     = input.session("1900-0200", "",              inline = "s1",  group = GP_SESS, display = display.none)
colAsia      = input.color(ORANGE,      "",                inline = "s1",  group = GP_SESS, display = display.none)

enLondon     = input.bool(true,          "",               inline = "s2",  group = GP_SESS, display = display.none)
nameLondon   = input.string("London",   "",                inline = "s2",  group = GP_SESS, display = display.none)
londonTime   = input.session("0200-0830", "",              inline = "s2",  group = GP_SESS, display = display.none)
colLondon    = input.color(BLUE,        "",                inline = "s2",  group = GP_SESS, display = display.none)

enNYAM       = input.bool(true,          "",               inline = "s3",  group = GP_SESS, display = display.none)
nameNYAM     = input.string("NY AM",    "",                inline = "s3",  group = GP_SESS, display = display.none)
nyamTime     = input.session("0830-1200", "",              inline = "s3",  group = GP_SESS, display = display.none)
colNYAM      = input.color(GREEN,       "",                inline = "s3",  group = GP_SESS, display = display.none)

enLunch      = input.bool(true,          "",               inline = "s4",  group = GP_SESS, display = display.none)
nameLunch    = input.string("NY Lunch", "",                inline = "s4",  group = GP_SESS, display = display.none)
lunchTime    = input.session("1200-1330", "",              inline = "s4",  group = GP_SESS, display = display.none)
colLunch     = input.color(PURPLE,      "",                inline = "s4",  group = GP_SESS, display = display.none)

enNYPM       = input.bool(true,          "",               inline = "s5",  group = GP_SESS, display = display.none)
nameNYPM     = input.string("NY PM",    "",                inline = "s5",  group = GP_SESS, display = display.none)
nypmTime     = input.session("1330-1600", "",              inline = "s5",  group = GP_SESS, display = display.none)
colNYPM      = input.color(RED,         "",                inline = "s5",  group = GP_SESS, display = display.none)

wdSun        = input.bool(false,         "Sun",            inline = "wd",  group = GP_FILT, display = display.none)
wdMon        = input.bool(true,          "Mon",            inline = "wd",  group = GP_FILT, display = display.none)
wdTue        = input.bool(true,          "Tue",            inline = "wd",  group = GP_FILT, display = display.none)
wdWed        = input.bool(true,          "Wed",            inline = "wd",  group = GP_FILT, display = display.none)
wdThu        = input.bool(true,          "Thu",            inline = "wd",  group = GP_FILT, display = display.none)
wdFri        = input.bool(true,          "Fri",            inline = "wd",  group = GP_FILT, display = display.none)
wdSat        = input.bool(false,         "Sat",            inline = "wd",  group = GP_FILT, display = display.none)
atrLen       = input.int(14,             "ATR Length",     minval = 5,     maxval = 50,     group = GP_FILT, display = display.none)
pivotLen     = input.int(5,              "Pivot Strength", minval = 2,     maxval = 20,     group = GP_FILT, display = display.none)

showDash     = input.bool(true,          "Show Dashboard",                                                      group = GP_DASH, display = display.none)
dashTheme    = input.string("Dark Mode", "Theme",           options = ["Dark Mode", "Light Mode"],                  group = GP_DASH, display = display.none)
dashPos      = input.string("Top Right", "Position",        options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = GP_DASH, display = display.none)
dashSize     = input.string("Small",     "Text Size",       options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GP_DASH, display = display.none)
showBars     = input.bool(true,          "Show Progress Bars",                                                      group = GP_DASH, display = display.none)

showAvgRange = input.bool(true,          "Avg Range (ATR%)",        inline = "mt1", group = GP_DASH, display = display.none)
showVolShare = input.bool(true,          "Vol Share %",      inline = "mt1", group = GP_DASH, display = display.none)
showAvgVol   = input.bool(false,         "Avg Vol",          inline = "mt1", group = GP_DASH, display = display.none)
showHOD      = input.bool(true,          "HOD %",            inline = "mt2", group = GP_DASH, display = display.none)
showLOD      = input.bool(true,          "LOD %",            inline = "mt2", group = GP_DASH, display = display.none)
showBull     = input.bool(true,          "Bull %",           inline = "mt2", group = GP_DASH, display = display.none)
showCont     = input.bool(true,          "Continuation %",   inline = "mt3", group = GP_DASH, display = display.none)
showPctl     = input.bool(true,          "Today Percentile", inline = "mt3", group = GP_DASH, display = display.none)
showFVGs     = input.bool(true,          "Avg FVGs",         inline = "mt4", group = GP_DASH, display = display.none)
showOBs      = input.bool(true,          "Avg Swing Breaks", inline = "mt4", group = GP_DASH, display = display.none)
showSurv     = input.bool(true,          "FVG Survival %",   inline = "mt4", group = GP_DASH, display = display.none)
showHH       = input.bool(false,         "Avg HH",           inline = "mt5", group = GP_DASH, display = display.none)
showLL       = input.bool(false,         "Avg LL",           inline = "mt5", group = GP_DASH, display = display.none)
colHigh      = input.color(BULL_COLOR,   "High",             inline = "sig", group = GP_DASH, display = display.none)
colMid       = input.color(MID_COLOR,     "Mid",             inline = "sig", group = GP_DASH, display = display.none)
colLow       = input.color(BEAR_COLOR,   "Low",              inline = "sig", group = GP_DASH, display = display.none)

showBoxes    = input.bool(false,         "Show Session Ranges",   inline = "showRange",         group = GP_DISP, display = display.none)
showHist     = true and showBoxes//input.bool(false,         " Historical",           inline = "showRange",         group = GP_DISP, display = display.none, active = showBoxes)
showLabel    = input.bool(true,          "Show Active Session Stats",                                                     inline = "lbl", group = GP_DISP, display = display.none)
labelSize    = input.string("Small",     "",                options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "lbl", group = GP_DISP, display = display.none)

//#endregion Input

//#region Declarations

type Pivot
    float level
    int   bar
    float extreme

type Rec
    int   wkday
    float normRng
    float rawRng
    bool  isHOD
    bool  isLOD
    bool  isBull
    bool  isCont
    bool  contOk
    int   fvgCount
    int   ifvgCount
    int   obCount
    int   hhCount
    int   llCount
    float vol
    float volShare

type Sess
    string name
    color  col
    bool   on
    array<Rec> hist
    float  cHi
    float  cLo
    float  cOpen
    int    cBar
    bool   act
    float  dHi
    float  dLo
    float  dOpen
    float  dClose
    bool   dDone
    bool   prevBull
    bool   hasPrev
    box    bx
    label  lbl
    int    cFvgs
    int    cIfvgs
    int    cOBs
    int    cHHs
    int    cLLs
    float  cSwingHi
    float  cSwingLo
    array<float> cFvgLevels
    array<bool>  cFvgIsBull
    float  cVol
    float  dVol
    int    dFvgs
    int    dIfvgs
    int    dOBs
    int    dHHs
    int    dLLs

//#endregion Declarations

//#region Functions

// ─── Formatters ─────────────────────────────────────────────────────────────

mkSess(string n, color c, bool en) =>
    Sess.new(n, c, en, array.new<Rec>(), na, na, na, na, false, na, na, na, na, false, false, false, na, na, 0, 0, 0, 0, 0, na, na, array.new<float>(), array.new<bool>(), 0.0, 0.0, 0, 0, 0, 0, 0)

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

wdLabel() =>
    all = wdSun and wdMon and wdTue and wdWed and wdThu and wdFri and wdSat
    weekdays = wdMon and wdTue and wdWed and wdThu and wdFri and not wdSun and not wdSat
    if all
        "All"
    else if weekdays
        "Weekdays"
    else
        r = ""
        if wdSun
            r += "Su"
        if wdMon
            r += (r == "" ? "" : "/") + "M"
        if wdTue
            r += (r == "" ? "" : "/") + "Tu"
        if wdWed
            r += (r == "" ? "" : "/") + "W"
        if wdThu
            r += (r == "" ? "" : "/") + "Th"
        if wdFri
            r += (r == "" ? "" : "/") + "F"
        if wdSat
            r += (r == "" ? "" : "/") + "Sa"
        r == "" ? "None" : r

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

toSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

pBar(float pct) =>
    w = 8
    filled = math.round(math.max(math.min(pct, 100), 0) / 100 * w)
    r = ""
    for k = 0 to w - 1
        r += k < filled ? "█" : "░"
    r

fmtPct(float v, float best) =>
    if na(v)
        "—"
    else
        t = (showBars ? pBar(v) + " " : "") + str.tostring(v, "#") + "%"
        t += not na(best) and v == best ? " ★" : "    "
        t

fmtPctNoBest(float v) =>
    na(v) ? "—" : (showBars ? pBar(v) + " " : "") + str.tostring(v, "#") + "%" + "    "

fmtCount(float v, float best) =>
    if na(v)
        "—"
    else
        t = str.tostring(v, "#.#")
        t += not na(best) and v == best ? " ★" : "    "
        t

fmtCountNoBest(float v) =>
    (na(v) ? "—" : str.tostring(v, "#.#")) + "    "

fmtRaw(float v) =>
    (na(v) ? "—" : str.tostring(v, "#")) + "    "

ordinal(float n) =>
    v = int(n)
    mod10  = v % 10
    mod100 = v % 100
    suffix = (mod100 >= 11 and mod100 <= 13) ? "th" : mod10 == 1 ? "st" : mod10 == 2 ? "nd" : mod10 == 3 ? "rd" : "th"
    str.tostring(v) + suffix

fmtPctl(float v) =>
    (na(v) ? "—" : (showBars ? pBar(v) + " " : "") + ordinal(v)) + "    "

pctlColor(float v, color defCol) =>
    na(v) ? defCol : v >= 75 ? colHigh : v <= 25 ? colLow : colMid

survColor(float v, color defCol) =>
    na(v) ? defCol : v >= 70 ? colHigh : v >= 40 ? colMid : colLow

isBest(float v, float best) =>
    not na(v) and not na(best) and v == best

// ─── Session Lifecycle ──────────────────────────────────────────────────────

method reset(Sess s) =>
    s.cHi        := high
    s.cLo        := low
    s.cOpen      := open
    s.cBar       := bar_index
    s.act        := true
    s.cFvgs      := 0
    s.cIfvgs     := 0
    s.cOBs       := 0
    s.cHHs       := 0
    s.cLLs       := 0
    s.cVol       := volume
    s.cSwingHi   := na
    s.cSwingLo   := na
    s.cFvgLevels.clear()
    s.cFvgIsBull.clear()

method close(Sess s) =>
    s.dHi        := s.cHi
    s.dLo        := s.cLo
    s.dOpen      := s.cOpen
    s.dClose     := close[1]
    s.dDone      := true
    s.act        := false
    s.dVol       := s.cVol
    s.dFvgs      := s.cFvgs
    s.dIfvgs     := s.cIfvgs
    s.dOBs       := s.cOBs
    s.dHHs       := s.cHHs
    s.dLLs       := s.cLLs

method resetDay(Sess s) =>
    s.dHi        := na
    s.dLo        := na
    s.dOpen      := na
    s.dClose     := na
    s.dDone      := false
    s.dFvgs      := 0
    s.dIfvgs     := 0
    s.dOBs       := 0
    s.dHHs       := 0
    s.dLLs       := 0
    s.dVol       := 0.0

method checkIFVGs(Sess s) =>
    if s.cFvgLevels.size() > 0
        for j = s.cFvgLevels.size() - 1 to 0
            isBull = s.cFvgIsBull.get(j)
            lvl    = s.cFvgLevels.get(j)
            if isBull ? close < lvl : close > lvl
                s.cIfvgs += 1
                s.cFvgLevels.remove(j)
                s.cFvgIsBull.remove(j)

method checkHHLL(Sess s, bool pivHi3, bool pivLo3) =>
    if pivHi3
        if not na(s.cSwingHi) and high[1] > s.cSwingHi
            s.cHHs += 1
        s.cSwingHi := high[1]
    if pivLo3
        if not na(s.cSwingLo) and low[1] < s.cSwingLo
            s.cLLs += 1
        s.cSwingLo := low[1]

method drawHistBox(Sess s) =>
    if not na(s.bx)
        s.bx.delete()
        s.bx := na
    if showHist
        box.new(s.cBar, s.cHi, bar_index - 1, s.cLo,
             border_color = color.new(s.col, 50), bgcolor = color.new(s.col, 93),
             text = s.name, text_color = color.new(s.col, 70), text_size = size.normal,
             text_halign = text.align_left, text_valign = text.align_top)

// ─── Dashboard Row Helper ───────────────────────────────────────────────────

method dashRow(table tbl, int row, string label, string tip, array<float> vals, float best, color txtCol, string sz, color hBg, color rBg, color bBg, bool isPct, bool hasBest, array<Sess> sessions) =>
    tbl.cell( 0, row, label, text_color = txtCol, text_size = sz, bgcolor = hBg, text_halign = text.align_left, tooltip = tip)
    c = 1
    for i = 0 to 4
        if not sessions.get(i).on
            continue
        v = vals.get(i)
        bg = hasBest and isBest(v, best) ? bBg : rBg
        t = isPct ? (hasBest ? fmtPct(v, best) : fmtPctNoBest(v)) : (hasBest ? fmtCount(v, best) : fmtCountNoBest(v))
        tbl.cell( c, row, t, text_color = txtCol, text_size = sz, bgcolor = bg, text_halign = text.align_center)
        c += 1

//#endregion Functions

//#region Calculations

// ─── Global ─────────────────────────────────────────────────────────────────

atr = ta.atr(atrLen)
dATR = request.security(syminfo.tickerid, "D", atr[1], lookahead = barmerge.lookahead_on)

tdShift = 6 * 3600 * 1000
tdDate  = 10000 * year(time + tdShift, "America/New_York") + 100 * month(time + tdShift, "America/New_York") + dayofmonth(time + tdShift, "America/New_York")
tdWk    = dayofweek(time + tdShift, "America/New_York")

// ─── Swing Pivots for OB Detection ─────────────────────────────────────────

pivHi = ta.pivothigh(high, pivotLen, pivotLen)
pivLo = ta.pivotlow(low, pivotLen, pivotLen)

var swingHi = Pivot.new(na, na, na)
var swingLo = Pivot.new(na, na, na)

if not na(pivHi)
    swingHi.level   := pivHi
    swingHi.bar     := bar_index - pivotLen
    swingHi.extreme := low

if not na(pivLo)
    swingLo.level   := pivLo
    swingLo.bar     := bar_index - pivotLen
    swingLo.extreme := high

if not na(swingHi.level)
    swingHi.extreme := math.min(nz(swingHi.extreme, low), low)
if not na(swingLo.level)
    swingLo.extreme := math.max(nz(swingLo.extreme, high), high)

bullOB = not na(swingHi.level) and close > swingHi.level and close[1] <= swingHi.level
bearOB = not na(swingLo.level) and close < swingLo.level and close[1] >= swingLo.level

if bullOB
    swingHi.level := na
if bearOB
    swingLo.level := na

// ─── Session Initialization ────────────────────────────────────────────────

var Sess s0 = mkSess(nameAsia,   colAsia,   enAsia)
var Sess s1 = mkSess(nameLondon, colLondon, enLondon)
var Sess s2 = mkSess(nameNYAM,   colNYAM,   enNYAM)
var Sess s3 = mkSess(nameLunch,  colLunch,  enLunch)
var Sess s4 = mkSess(nameNYPM,   colNYPM,   enNYPM)

var ss = array.new<Sess>()
if barstate.isfirst
    ss.push(s0)
    ss.push(s1)
    ss.push(s2)
    ss.push(s3)
    ss.push(s4)

// ─── Session Detection ─────────────────────────────────────────────────────

in0 = enAsia   and not na(time(timeframe.period, asiaTime,   "America/New_York"))
in1 = enLondon and not na(time(timeframe.period, londonTime, "America/New_York"))
in2 = enNYAM   and not na(time(timeframe.period, nyamTime,   "America/New_York"))
in3 = enLunch  and not na(time(timeframe.period, lunchTime,  "America/New_York"))
in4 = enNYPM   and not na(time(timeframe.period, nypmTime,   "America/New_York"))

isIn(int i) =>
    switch i
        0 => in0
        1 => in1
        2 => in2
        3 => in3
        => in4

// ─── Session Tracking + Structure Detection ─────────────────────────────────

isBullFVG = low > high[2]
isBearFVG = high < low[2]
isPivHi3  = high[1] > high[2] and high[1] > high
isPivLo3  = low[1] < low[2] and low[1] < low

for i = 0 to 4
    Sess s = ss.get(i)
    if not s.on
        continue

    inn = isIn(i)

    if inn and not s.act
        s.reset()

    else if inn and s.act
        s.cHi  := math.max(s.cHi, high)
        s.cLo  := math.min(s.cLo, low)
        s.cVol += volume

        if isBullFVG or isBearFVG
            s.cFvgs += 1
            s.cFvgLevels.push(isBullFVG ? high[2] : low[2])
            s.cFvgIsBull.push(isBullFVG)

        s.checkIFVGs()

        if bullOB
            s.cOBs += 1
        if bearOB
            s.cOBs += 1

        s.checkHHLL(isPivHi3, isPivLo3)

    else if not inn and s.act
        s.close()
        s.drawHistBox()

// ─── Trading Day Finalization ───────────────────────────────────────────────

var int   pTdDate = na
var int   pTdWk   = na
var float dayHigh = na
var float dayLow  = na
isNewDay = false

if na(pTdDate)
    pTdDate := tdDate
    pTdWk   := tdWk
    dayHigh := high
    dayLow  := low
else if tdDate != pTdDate
    isNewDay := true

    dayVol = 0.0
    for i = 0 to 4
        Sess s = ss.get(i)
        if s.dDone
            dayVol += s.dVol

    for i = 0 to 4
        Sess s = ss.get(i)
        if s.dDone
            rng  = s.dHi - s.dLo
            nRng = not na(dATR) and dATR > 0 ? rng / dATR : 0.0
            hod  = not na(dayHigh) and s.dHi == dayHigh
            lod  = not na(dayLow) and s.dLo == dayLow
            bull = s.dClose > s.dOpen
            cont = s.hasPrev ? (s.prevBull == bull) : false
            cOk  = s.hasPrev
            vShr = dayVol > 0 ? s.dVol / dayVol * 100 : 0.0

            s.hist.push(Rec.new(pTdWk, nRng, rng, hod, lod, bull, cont, cOk, s.dFvgs, s.dIfvgs, s.dOBs, s.dHHs, s.dLLs, s.dVol, vShr))
            s.prevBull := bull
            s.hasPrev  := true

        if not s.act
            s.resetDay()

    if not showHist
        for i = 0 to 4
            Sess s = ss.get(i)
            if not na(s.bx)
                s.bx.delete()
                s.bx := na

    pTdDate := tdDate
    pTdWk   := tdWk
    dayHigh := high
    dayLow  := low
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow  := na(dayLow)  ? low  : math.min(dayLow, low)

//#endregion Calculations

//#region Visualizations

// ─── Session Boxes ──────────────────────────────────────────────────────────

if showBoxes or showHist
    for i = 0 to 4
        Sess s = ss.get(i)
        if not s.on or not s.act
            continue
        if na(s.bx)
            s.bx := box.new(s.cBar, s.cHi, bar_index, s.cLo,
                 border_color = color.new(s.col, 60), bgcolor = color.new(s.col, 92),
                 text = s.name, text_color = s.col, text_size = size.tiny,
                 text_halign = text.align_left, text_valign = text.align_top)
        else
            s.bx.set_top(s.cHi)
            s.bx.set_bottom(s.cLo)
            s.bx.set_right(bar_index)
else
    for i = 0 to 4
        Sess s = ss.get(i)
        if not na(s.bx)
            s.bx.delete()
            s.bx := na

// ─── Active Session Label ───────────────────────────────────────────────────

if showLabel
    for i = 0 to 4
        Sess s = ss.get(i)
        if not s.on
            continue

        if s.act
            curRng  = s.cHi - s.cLo
            curNorm = not na(dATR) and dATR > 0 ? curRng / dATR : na

            sumN  = 0.0
            below = 0
            total = 0
            if s.hist.size() > 0
                for j = 0 to s.hist.size() - 1
                    Rec r = s.hist.get(j)
                    if not wdPass(r.wkday)
                        continue
                    total += 1
                    sumN  += r.normRng
                    if not na(curNorm) and r.normRng <= curNorm
                        below += 1

            avgN  = total > 0 ? sumN / total : na
            pctl  = total > 0 and not na(curNorm) ? math.round(below * 100.0 / total) : na
            vsAvg = not na(avgN) and avgN > 0 and not na(curNorm) ? math.round(curNorm / avgN * 100) : na

            txt = s.name
            txt += " | Rng: " + str.tostring(curRng, format.mintick)
            txt += " | vs Avg: " + (not na(vsAvg) ? str.tostring(vsAvg, "#") + "%" : "—")
            txt += " | Percentile: " + (not na(pctl) ? str.tostring(pctl, "#") : "—")

            if na(s.lbl)
                s.lbl := label.new(bar_index + 3, s.cHi, txt, style = label.style_label_down,
                     color = color.new(s.col, 80), textcolor = s.col, size = toSize(labelSize))
            else
                s.lbl.set_x(bar_index + 3)
                s.lbl.set_y(s.cHi)
                s.lbl.set_text(txt)
        else
            if not na(s.lbl)
                s.lbl.delete()
                s.lbl := na

// ─── Dashboard ──────────────────────────────────────────────────────────────

var table dash = na

if showDash and barstate.islast
    if not na(dash)
        dash.delete()

    sz = toSize(dashSize)

    nEn = 0
    for i = 0 to 4
        if ss.get(i).on
            nEn += 1

    if nEn > 0
        nC = 1 + nEn
        hasStructure = showFVGs or showOBs or showSurv or showHH or showLL
        nR = 2 + (showAvgRange ? 1 : 0) + (showVolShare ? 1 : 0) + (showHOD ? 1 : 0) + (showLOD ? 1 : 0) + (showBull ? 1 : 0) + (showCont ? 1 : 0) + (showPctl ? 1 : 0) + (hasStructure ? 1 : 0) + (showFVGs ? 1 : 0) + (showOBs ? 1 : 0) + (showSurv ? 1 : 0) + (showHH ? 1 : 0) + (showLL ? 1 : 0) + (showAvgVol ? 1 : 0)

        isDark = dashTheme == "Dark Mode"
        hBg    = isDark ? BG_HEADER_DARK : BG_HEADER_LIGHT
        rBg    = isDark ? BG_DARK_DARK : BG_DARK_LIGHT
        bBg    = isDark ? BG_BEST_DARK : BG_BEST_LIGHT
        txtCol = isDark ? TEXT_DARK : TEXT_LIGHT

        dash := table.new(tblPos(), nC, nR, border_width = 1,
             border_color = color.new(GRAY, 60), frame_width = 2,
             frame_color = color.new(GRAY, 40))

        // Compute stats per session
        arV = array.new<float>(5, na)
        hdV = array.new<float>(5, na)
        ldV = array.new<float>(5, na)
        blV = array.new<float>(5, na)
        ctV = array.new<float>(5, na)
        tpV = array.new<float>(5, na)
        fvV = array.new<float>(5, na)
        obV = array.new<float>(5, na)
        svV = array.new<float>(5, na)
        hhV = array.new<float>(5, na)
        llV = array.new<float>(5, na)
        vsV = array.new<float>(5, na)
        avV = array.new<float>(5, na)
        maxDays = 0

        for i = 0 to 4
            Sess s = ss.get(i)
            if not s.on
                continue

            sumN    = 0.0
            hodC    = 0
            lodC    = 0
            bullC   = 0
            contC   = 0
            contT   = 0
            tot     = 0
            sumFvg  = 0.0
            sumIfvg = 0.0
            sumOb   = 0.0
            sumHH   = 0.0
            sumLL   = 0.0
            sumVol  = 0.0
            sumVShr = 0.0

            if s.hist.size() > 0
                for j = 0 to s.hist.size() - 1
                    Rec r = s.hist.get(j)
                    if not wdPass(r.wkday)
                        continue
                    tot     += 1
                    sumN    += r.normRng
                    hodC    += r.isHOD ? 1 : 0
                    lodC    += r.isLOD ? 1 : 0
                    bullC   += r.isBull ? 1 : 0
                    sumFvg  += r.fvgCount
                    sumIfvg += r.ifvgCount
                    sumOb   += r.obCount
                    sumHH   += r.hhCount
                    sumLL   += r.llCount
                    sumVol  += r.vol
                    sumVShr += r.volShare
                    if r.contOk
                        contT += 1
                        contC += r.isCont ? 1 : 0

            if tot > 0
                arV.set(i, math.round(sumN / tot * 100))
                hdV.set(i, math.round(hodC * 100.0 / tot))
                ldV.set(i, math.round(lodC * 100.0 / tot))
                blV.set(i, math.round(bullC * 100.0 / tot))
                ctV.set(i, contT > 0 ? math.round(contC * 100.0 / contT) : na)
                fvV.set(i, math.round(sumFvg * 10.0 / tot) / 10)
                obV.set(i, math.round(sumOb * 10.0 / tot) / 10)
                svV.set(i, sumFvg > 0 ? math.round((sumFvg - sumIfvg) * 100.0 / sumFvg) : na)
                hhV.set(i, math.round(sumHH * 10.0 / tot) / 10)
                llV.set(i, math.round(sumLL * 10.0 / tot) / 10)
                vsV.set(i, math.floor(sumVShr / tot))
                avV.set(i, math.round(sumVol / tot))
                if tot > maxDays
                    maxDays := tot

            curNorm = float(na)
            if s.act
                curNorm := not na(dATR) and dATR > 0 ? (s.cHi - s.cLo) / dATR : na
            else if s.dDone
                curNorm := not na(dATR) and dATR > 0 ? (s.dHi - s.dLo) / dATR : na

            if not na(curNorm) and s.hist.size() > 0
                bel  = 0
                ptot = 0
                for j = 0 to s.hist.size() - 1
                    Rec r = s.hist.get(j)
                    if not wdPass(r.wkday)
                        continue
                    ptot += 1
                    if r.normRng <= curNorm
                        bel += 1
                tpV.set(i, ptot > 0 ? math.round(bel * 100.0 / ptot) : na)

        // Find best values
        bestAR = float(na)
        bestHD = float(na)
        bestLD = float(na)
        bestFV = float(na)
        bestSV = float(na)

        for i = 0 to 4
            if not ss.get(i).on
                continue
            ar = arV.get(i)
            hd = hdV.get(i)
            ld = ldV.get(i)
            fv = fvV.get(i)
            sv = svV.get(i)
            if not na(ar) and (na(bestAR) or ar > bestAR)
                bestAR := ar
            if not na(hd) and (na(bestHD) or hd > bestHD)
                bestHD := hd
            if not na(ld) and (na(bestLD) or ld > bestLD)
                bestLD := ld
            if not na(fv) and (na(bestFV) or fv > bestFV)
                bestFV := fv
            if not na(sv) and (na(bestSV) or sv > bestSV)
                bestSV := sv

        // Title + column headers
        title = "SESSION EDGE PROFILER | " + wdLabel() + " | " + str.tostring(maxDays) + "d"
        dash.cell( 0, 0, title, text_color = txtCol, text_size = sz, bgcolor = hBg, text_halign = text.align_center)
        dash.merge_cells( 0, 0, nC - 1, 0)

        dash.cell( 0, 1, "Metric", text_color = txtCol, text_size = sz, bgcolor = hBg, text_halign = text.align_center)
        hCol = 1
        for i = 0 to 4
            Sess s = ss.get(i)
            if not s.on
                continue
            cBg = s.act and isDark ? color.new(s.col, 85) : hBg
            dash.cell( hCol, 1, s.name, text_color = s.col, text_size = sz, bgcolor = cBg, text_halign = text.align_center)
            hCol += 1

        // Metric rows
        row = 2

        if showAvgRange
            dash.dashRow(row, "Avg Range (ATR%)", "Average session range as a percentage of the daily ATR.", arV, bestAR, txtCol, sz, hBg, rBg, bBg, true, true, ss)
            row += 1

        if showVolShare
            dash.dashRow(row, "Vol Share %", "This session's average share of total daily volume.", vsV, na, txtCol, sz, hBg, rBg, bBg, true, false, ss)
            row += 1

        if showAvgVol
            dash.cell( 0, row, "Avg Vol", text_color = txtCol, text_size = sz, bgcolor = hBg, text_halign = text.align_left, tooltip = "Average total volume during this session.")
            c = 1
            for i = 0 to 4
                if not ss.get(i).on
                    continue
                v = avV.get(i)
                dash.cell( c, row, fmtRaw(v), text_color = txtCol, text_size = sz, bgcolor = rBg, text_halign = text.align_center)
                c += 1
            row += 1

        if showHOD
            dash.dashRow(row, "HOD %", "Percentage of days where this session set the day's highest price.", hdV, bestHD, txtCol, sz, hBg, rBg, bBg, true, true, ss)
            row += 1

        if showLOD
            dash.dashRow(row, "LOD %", "Percentage of days where this session set the day's lowest price.", ldV, bestLD, txtCol, sz, hBg, rBg, bBg, true, true, ss)
            row += 1

        if showBull
            dash.dashRow(row, "Bull %", "Percentage of sessions that closed higher than they opened.", blV, na, txtCol, sz, hBg, rBg, bBg, true, false, ss)
            row += 1

        if showCont
            dash.dashRow(row, "Continuation %", "Continuation — how often this session closes in the same direction as its previous occurrence.", ctV, na, txtCol, sz, hBg, rBg, bBg, true, false, ss)
            row += 1

        if showPctl
            dash.cell( 0, row, "Today Percentile", text_color = txtCol, text_size = sz, bgcolor = hBg, text_halign = text.align_left, tooltip = "Where today's session range sits vs history. Green (>75th) = unusually large. Red (<25th) = unusually small.")
            c = 1
            for i = 0 to 4
                if not ss.get(i).on
                    continue
                v = tpV.get(i)
                dash.cell( c, row, fmtPctl(v), text_color = pctlColor(v, txtCol), text_size = sz, bgcolor = rBg, text_halign = text.align_center)
                c += 1
            row += 1

        if hasStructure
            dash.cell( 0, row, "SMART MONEY", text_color = txtCol, text_size = sz, bgcolor = hBg, text_halign = text.align_center)
            dash.merge_cells( 0, row, nC - 1, row)
            row += 1

        if showFVGs
            dash.dashRow(row, "Avg FVGs", "Average Fair Value Gaps formed per session.", fvV, bestFV, txtCol, sz, hBg, rBg, bBg, false, true, ss)
            row += 1

        if showOBs
            dash.dashRow(row, "Avg Swing Breaks", "Average swing breaks per session — instances where price closes beyond a pivot high or low.", obV, na, txtCol, sz, hBg, rBg, bBg, false, false, ss)
            row += 1

        if showSurv
            dash.cell( 0, row, "FVG Survival %", text_color = txtCol, text_size = sz, bgcolor = hBg, text_halign = text.align_left, tooltip = "FVG Survival Rate — percentage of FVGs NOT invalidated within the same session. Higher = more reliable.")
            c = 1
            for i = 0 to 4
                if not ss.get(i).on
                    continue
                v = svV.get(i)
                bg = isBest(v, bestSV) ? bBg : rBg
                dash.cell( c, row, fmtPct(v, bestSV), text_color = survColor(v, txtCol), text_size = sz, bgcolor = bg, text_halign = text.align_center)
                c += 1
            row += 1

        if showHH
            dash.dashRow(row, "Avg HH", "Average Higher Highs per session — bullish structure breaks.", hhV, na, txtCol, sz, hBg, rBg, bBg, false, false, ss)
            row += 1

        if showLL
            dash.dashRow(row, "Avg LL", "Average Lower Lows per session — bearish structure breaks.", llV, na, txtCol, sz, hBg, rBg, bBg, false, false, ss)
            row += 1

// ─── Alerts ─────────────────────────────────────────────────────────────────

highPctlAlert = false

for i = 0 to 4
    Sess s = ss.get(i)
    if not s.on or not s.act
        continue
    curN = not na(dATR) and dATR > 0 ? (s.cHi - s.cLo) / dATR : na
    if na(curN) or s.hist.size() == 0
        continue
    bel = 0
    tot = 0
    for j = 0 to s.hist.size() - 1
        Rec r = s.hist.get(j)
        if not wdPass(r.wkday)
            continue
        tot += 1
        if r.normRng <= curN
            bel += 1
    if tot > 0 and bel * 100.0 / tot >= 90
        highPctlAlert := true

alertcondition(highPctlAlert, "Range > 90th Percentile", "Active session range exceeds 90th percentile on {{ticker}} {{interval}}")

//#endregion Visualizations
````
