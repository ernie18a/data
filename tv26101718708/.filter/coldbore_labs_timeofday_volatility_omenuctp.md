# Coldbore Labs - Time-of-Day Volatility

- url: https://www.tradingview.com/script/OmenUcTP-Coldbore-Labs-Time-of-Day-Volatility/
- type: indicator
- pine_id: PUB;59335621d3db4a7db9b291f295fed24f
- version: 1.0

## Description

[b]Time-of-Day Volatility[/b] answers a question a standard ATR cannot: is this bar actually unusual, or is it simply normal for this hour? It builds a profile of what range, participation and direction look like at each specific time of day on this instrument, then shows you live how the current moment compares.

[b]THE PROBLEM[/b]
On an actively traded instrument, a 2-minute bar with a 40-cent range is a non-event at 09:34 and an outlier at 12:40. Every standard volatility measure, ATR included, blends dead overnight tape into the same lookback as the opening drive. The result is an ATR that is understated at the open, so stops sit too tight exactly when they need to be widest, and overstated at midday, so targets sit too far exactly when the tape cannot reach them. This script corrects for that by conditioning every measurement on the clock.

[b]WHAT IT MEASURES[/b]
[list]
[*][b]Expected bar range[/b] for the current time slot, with a percentile band showing the normal spread of outcomes rather than a single number.
[*][b]Cumulative relative volume[/b] — total session volume so far against what this instrument normally trades by this point in the day.
[*][b]Range still to come[/b] between now and the session close.
[*][b]A session-open projection[/b] of the day's likely high and low.
[*][b]Directional lean[/b] for the current time slot.
[/list]

[b]HOW IT WORKS[/b]
[b]1. Time buckets.[/b] Every bar is assigned to a bucket by its clock time. Bucket width auto-sizes from the chart timeframe: 5 minutes on charts up to 5 minutes, 15 up to 15, 30 up to 30, 60 above that. A bucket narrower than the chart timeframe cannot be populated, so it is clamped.

[b]2. Rolling pools.[/b] Each bucket stores the range, volume, cumulative session volume and direction of every confirmed bar that has fallen into it, keeping roughly the most recent 20 days and overwriting the oldest.

[b]3. Medians, not means.[/b] Statistics are read as medians. One halt, one gap or one unusual print can drag a mean out of line for weeks, and range distributions are heavily right-skewed. The 25th and 75th percentiles are read from the same pool to form the normal-range band. The expectation is read [i]before[/i] the current bar is written into its pool, so no bar is ever measured against a number it helped create.

[b]4. The comparison.[/b] The current bar's range divided by the expected range is the ratio the script is built around: 1.0 is perfectly normal for this time of day, 2.0 is double, 0.4 is unusually quiet. The band tells you whether that number is genuinely remarkable — a bar at 1.4x is ordinary if the 75th percentile sits at 1.6x.

[b]5. Relative volume.[/b] Because each bucket also stores the running session volume at that point, today's cumulative volume can be compared against what is normal by the same moment in the session, rather than against a rolling average that ignores the time of day entirely.

[b]6. Range still to come.[/b] This is not the median day range minus what has been spent, which becomes nonsense late in the session. At every session close the script records how much additional range each bucket actually saw between that point and the bell, then reports the median of those observations. The figure therefore falls naturally toward zero as the close approaches.

[b]7. The session-open projection.[/b] At the open the script combines the median session range with the median position of the open inside that range to project a likely high and low for the day. It is a statistical frame for the session, not a forecast.

[b]8. Sample hygiene.[/b] Shortened sessions around holidays distort both the afternoon buckets and the daily statistics, so sessions with materially fewer bars than normal are excluded from the day-level numbers by default. Optionally, days whose range far exceeds the running median can also be excluded so a single event day does not skew the budget for weeks.

[b]HOW TO USE IT[/b]
[list]
[*][b]Size stops and targets by the clock.[/b] Read the Normal bar row and scale from it. If a normal bar is 1.20 at 09:35 and 0.30 at 12:30, a stop sized for one is wrong for the other.
[*][b]Treat expansion in quiet hours as information.[/b] A bar breaching its expected range at 12:45 means participation arrived when there normally is none. A large candle at 09:32 that stays within expectation is just the open behaving like the open.
[*][b]Check whether participation backs the move.[/b] Range expanding while relative volume sits below 1.0 is a different proposition from both expanding together.
[*][b]Let the range budget choose your approach.[/b] Early in the session with little of a normal range spent, there is room for continuation ideas to work. Well past a full normal day's range, continuation is working against the instrument's own distribution. Treat it as context for which approach fits, not as a signal.
[*][b]Watch compression in normally active slots.[/b] Sustained readings well under expectation during a time that is usually busy indicate contraction. It says nothing about direction.
[*][b]Use the open briefing to frame the day.[/b] The expected range and projected high and low give you a starting picture before the session develops.
[*][b]Check the sample before trusting anything.[/b] On a freshly loaded chart, or after changing timeframe, buckets need history before their numbers mean anything.
[/list]
This is a context tool. It does not generate entries or exits and says nothing about direction on its own.

[b]WHAT MAKES IT DIFFERENT[/b]
Time-conditioned relative volume is well-established, and this script implements a solid version of it. The distinguishing work is on the volatility side and in what the two together enable.
[list]
[*][b]Volatility conditioned on the clock, with a distribution.[/b] Most volatility tools give one blended number. This gives an expected range for the specific minute of the session plus the percentile band around it, so "unusual" is measured against the real spread of outcomes rather than a single average.
[*][b]A session-corrected ATR you can export.[/b] The expected bar range is published as a plot that any script with a source input can select, so volatility scaling elsewhere in your setup can be corrected for time of day instead of inheriting the blended error.
[*][b]A multiplier that quantifies the error.[/b] The time-of-day expectation divided by a deliberately naive all-session baseline tells you exactly how far a conventional ATR is off at this moment.
[*][b]Forward-looking range projection.[/b] Because the remaining-range statistic is built retroactively from what actually happened after each bucket on past sessions, it is a genuine estimate of what is left rather than arithmetic on a daily average.
[*][b]Median-based throughout, with sample transparency.[/b] Percentiles and medians rather than means, thin buckets greyed out and excluded from alerts, and holiday sessions filtered from the day statistics.
[*][b]Optional weekday profiles.[/b] Separate histories per day of the week, with the sample cost stated plainly rather than hidden.
[/list]

[b]INPUTS[/b]
[b]Market and sessions[/b]: market preset (US equities, futures, forex, 24-hour crypto or custom); timezone, including an option to follow the exchange; custom session windows; session tinting and colours.
[b]Profile[/b]: bucket width (Auto or fixed); days in the sample (default 20); separate profile per weekday (default off); naive baseline period; minimum sample to trust a bucket; exclude shortened sessions (default on); exclude outlier days with a multiplier (default off).
[b]Display[/b]: what to show (Range, Volume, Ratio to expected, Relative volume); columns, expected line, normal-range band, expansion threshold line; ratio smoothing; colours for above expectation, within expectation, the expected line and insufficient sample.
[b]Exports[/b]: draw the session-corrected ATR; draw the volatility multiplier.
[b]Dashboard[/b]: show, position, size, blank rows above the card; optional rows for the session projection, sample size, per-bar participation, volatility multiplier, day range detail, bucket rank and directional drift.
[b]Alerts[/b]: expansion and contraction thresholds; relative volume threshold; range budget warning level; individual alert toggles; message format and custom tag.

[b]VISUALS[/b]
[list]
[*]Columns: the current measure, coloured above or within expectation. Grey means the bucket has insufficient history.
[*]Line: the expected value for this time of day.
[*]Shaded band: the 25th to 75th percentile of this bucket's history.
[*]Background tint: which session each bar belongs to, so the daily shape is visible at a glance.
[*]Dashboard: five core rows (time bucket, normal bar with its band, this bar and its ratio, relative volume, range left with percentage spent), plus the session projection and six optional diagnostic rows.
[/list]

[b]ALERTS[/b]
Create an alert on the indicator and select "Any alert() function call" to receive messages with live figures. Message format can be Detailed, Plain text or JSON for webhooks, with an optional custom tag. Available events: range expansion, range contraction, unusual relative volume, range budget warning, range budget spent, and the session-open briefing carrying the expected range and projected high and low. Matching fixed alert conditions are also available. All bar-level conditions are evaluated on bar close.

[b]LIMITATIONS AND GOTCHAS[/b]
[list]
[*][b]It needs history before it means anything.[/b] Buckets start empty and fill as the chart loads. The range-left figure requires at least one fully completed session, because it is written retroactively at the close.
[*][b]Sample is counted in bar observations, not days.[/b] On a chart where several bars fall in each bucket, the count rises faster than the number of days behind it.
[*][b]Weekday profiles divide the sample by five.[/b] Pool depth is also capped tighter in that mode to stay within Pine's memory limits. Raise the history setting and watch the sample readout.
[*][b]Relative volume needs real volume.[/b] Symbols without reliable volume data, such as some indices or tick-volume forex feeds, will produce a meaningless or empty reading on that row.
[*][b]The projection is a frame, not a forecast.[/b] It is built from median statistics and will be wrong on trend days and event days, which is precisely when it matters most that you treat it as context.
[*][b]During a forming bar the ratio rises as the bar develops[/b], since range can only grow. Alerts are gated to bar close for this reason; the dashboard is live.
[*][b]Directional drift is easy to over-read.[/b] On a small sample it is noise. It is descriptive, not predictive.
[*][b]Holiday filtering is heuristic.[/b] Shortened sessions are detected by bar count relative to normal, which works for scheduled half days but cannot know why a session was short.
[*][b]Session and timezone settings matter.[/b] If the windows do not match the instrument, every bucket is mislabelled. Check the preset before relying on the output.
[*][b]Exports are data-window plots[/b] so they never distort the pane scale. Enable the draw options if you want to see them plotted.
[*]Intraday charts only. Use standard candles or bars; Heikin Ashi, Renko and other non-standard types distort range and volume.
[*]Past behaviour at a given time of day does not guarantee future behaviour.
[/list]

This script is intended for analysis and education and is not financial advice.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  Coldbore Labs - Time-of-Day Volatility  (v2.0)
//
//  Shows what normal volatility and participation look like at each specific
//  time of day on this instrument, and how right now compares — so you can
//  tell whether a move is genuinely unusual or simply typical for the hour.
//
//  THE PROBLEM IT SOLVES.
//  On a heavily day-traded instrument, a 2-minute bar with a 40-cent range is
//  a non-event at 09:34 and a screaming outlier at 12:40. Almost no indicator
//  knows the difference, because every standard volatility measure — ATR
//  included — blends dead overnight tape into the same lookback as the
//  opening drive. The result is an ATR badly UNDERSTATED at the open, so
//  stops sit too tight exactly when they need to be widest, and OVERSTATED
//  at lunch, so targets sit too far exactly when the tape cannot reach them.
//
//  WHAT IT MEASURES.
//   • Expected bar range for this exact time of day, with a percentile band
//     showing the normal spread of outcomes rather than a single number.
//   • Cumulative relative volume: total session volume so far against what
//     this instrument normally trades by this point in the day.
//   • Expected range still to come between now and the session close.
//   • A session-open projection of the day's likely high and low.
//   • Directional lean for the current time slot.
//
//  THE SAMPLE.
//  Each time bucket keeps a rolling pool of recent observations and reports
//  the MEDIAN, not the mean. One halt, one earnings gap, one 09:30 print can
//  drag a mean far enough to make a profile useless, and range distributions
//  are violently right-skewed. Sample size is available at all times, because
//  a profile built from three days is a guess. Nothing is ever computed from
//  the current bar before that bar is measured against the profile, so no bar
//  helps predict itself.
//
//  SAMPLE HYGIENE.
//  Shortened sessions — the half days around Thanksgiving, Christmas Eve,
//  July 3rd — distort both the afternoon buckets and the daily budget, so
//  sessions materially shorter than normal are excluded from the day-level
//  statistics by default. Optionally, days whose range exceeds a multiple of
//  the running median can also be excluded, so a single event day does not
//  skew the budget for a month.
//
//  WEEKDAY PROFILES (optional, off).
//  Monday's open after a weekend of news is not Wednesday's, and Friday
//  afternoon is its own animal. Enabling weekday profiles keeps a separate
//  history for each day of the week. The honest cost is that every bucket's
//  sample divides by five, so raise the history setting when using it and
//  watch the sample readout.
//
//  SESSION-CORRECTED ATR — THE EXPORT.
//  The expected bar range for the current bucket is a session-corrected ATR,
//  published as a plot named "Session ATR (export)". Any script with a source
//  input can select it. A "Volatility multiplier (export)" is published
//  alongside — the time-of-day expectation divided by a naive all-session
//  baseline, so a reading of 2.4 at 09:32 says plainly that a conventional
//  ATR is understating the moment by well over half. Both exports are
//  data-window only so they never affect the pane's scale; separate visible
//  plots exist for when you want to see them drawn.
//
//  TIME-AWARE RANGE PROJECTION.
//  "Range left" is not the day's median range minus what has been spent —
//  that number is nonsense at 15:50. Instead, at every session close the
//  script records how much additional range each time bucket actually saw
//  between that point and the bell. The median of those observations is what
//  it reports, so the figure falls naturally toward zero as the close
//  approaches, and reflects what this instrument really does from here.
//
//  BUCKET WIDTH.
//  Auto-sizes from the chart timeframe: 5-minute buckets on charts up to 5
//  minutes, 15 up to 15, 30 up to 30, 60 above that. A bucket narrower than
//  the chart timeframe cannot be populated, so it is clamped.
//
//  WHERE IT LIVES.
//  A Pine script only draws into its own pane, so this one runs in a separate
//  pane. That is also why the session-open projection is delivered as numbers
//  and an alert rather than as lines on price — a pane indicator cannot draw
//  on the price chart.
// ═══════════════════════════════════════════════════════════════════════════
indicator("Coldbore Labs - Time-of-Day Volatility", shorttitle="Coldbore Time-of-Day Volatility", overlay=false, max_labels_count=100)

// ════════════ INPUTS ════════════
grpS = "Market and sessions"
preset  = input.string("US equities", "Market preset", options=["US equities", "Futures (Globex)", "Forex", "Crypto (24h)", "Custom"], group=grpS, tooltip="Sets all three session windows at once. US equities uses the 04:00 / 09:30 / 16:00 / 20:00 structure. Futures uses the Globex overnight into the cash open. Forex centres on the London and New York windows. Crypto treats the whole day as one continuous session. Choose Custom to set the windows yourself below.")
tzIn    = input.string("America/New_York", "Timezone", options=["Exchange", "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "UTC"], group=grpS, tooltip="Exchange follows the symbol's own timezone, which is usually what you want on non-US instruments. Everything else pins the clock to a fixed zone so buckets stay aligned across daylight-saving changes in other regions.")
pmCust  = input.session("0400-0930", "Custom pre-market",    group=grpS)
rthCust = input.session("0930-1600", "Custom regular hours", group=grpS, tooltip="The session all day-level statistics are measured on: cumulative volume, day range, range projection and the open briefing.")
postCust= input.session("1600-2000", "Custom post-market",   group=grpS)
shadeSess = input.bool(true, "Tint the pane by session", group=grpS, tooltip="Colours the pane background so each bucket is visibly attributable to its session — the fastest way to watch the daily shape form.")
colPM    = input.color(color.new(#b58900, 88), "Pre-market",  group=grpS, inline="t1")
colRTH   = input.color(color.new(#000000, 100), "Regular",    group=grpS, inline="t1")
colPost  = input.color(color.new(#2962ff, 90), "Post-market", group=grpS, inline="t2")
colNight = input.color(color.new(#9c27b0, 90), "Overnight",   group=grpS, inline="t2")

grpB = "Profile"
bucketMode = input.string("Auto", "Bucket width", options=["Auto", "5 minutes", "15 minutes", "30 minutes", "60 minutes"], group=grpB, tooltip="How finely the day is sliced. Auto sizes from the chart timeframe and is almost always right. Coarser buckets give each one a denser sample at the cost of resolution across the open, which is where resolution matters most.")
sampleDays = input.int(20, "Days in the sample", minval=3, maxval=60, group=grpB, tooltip="How many days of history each bucket remembers. Longer is more stable but slower to acknowledge a change in the instrument's character. After a split, an earnings reset or an index inclusion, shorten it for a while.")
dowMode    = input.bool(false, "Separate profile for each weekday", group=grpB, tooltip="Keeps an independent history per day of the week, capturing real effects like Monday opens and Friday afternoons. Every bucket's sample divides by five, so raise the history setting and watch the sample readout before trusting it.")
baseLen    = input.int(500, "Naive baseline period", minval=50, group=grpB, tooltip="Length of the blended all-session range measure the volatility multiplier is compared against. This is deliberately the number a conventional ATR produces — the multiplier exists to say how wrong it is.")
minSample  = input.int(5, "Minimum sample to trust a bucket", minval=1, maxval=30, group=grpB, tooltip="Buckets with fewer observations are greyed and excluded from alerts rather than presented as if they meant something. Counted in bar observations, not days.")
excShort   = input.bool(true, "Exclude shortened sessions", group=grpB, tooltip="Half days around holidays close early, which distorts both the afternoon buckets and the daily range statistics. Sessions with materially fewer bars than normal are left out of the day-level numbers.")
excOutlier = input.bool(false, "Exclude outlier days", group=grpB, inline="ex", tooltip="Leaves out days whose range far exceeds the running median, so a single event day does not inflate the budget for weeks. Off by default, because event days are real and sometimes you want them counted.")
outMult    = input.float(2.5, "×", minval=1.5, step=0.5, group=grpB, inline="ex")

grpD = "Display"
plotMode  = input.string("Range", "Show", options=["Range", "Volume", "Ratio to expected", "Relative volume"], group=grpD, tooltip="Range: actual bar range as columns against the expected line. Volume: the same for per-bar participation. Ratio: both collapsed into one normalised series where 1.0 is a perfectly normal bar. Relative volume: cumulative session volume against what is normally traded by this point in the day.")
showCols  = input.bool(true,  "Show actual as columns", group=grpD)
showExp   = input.bool(true,  "Show expected line",     group=grpD)
showBand  = input.bool(true,  "Show normal range band", group=grpD, tooltip="Shades between the 25th and 75th percentile of this bucket's history. The median alone tells you the midpoint; the band tells you whether the current bar is actually unusual. A bar at 1.4× the median is ordinary if the 75th percentile sits at 1.6×.")
showThresh= input.bool(false, "Show expansion threshold line", group=grpD)
smoothLen = input.int(1, "Smooth the ratio over (bars)", minval=1, maxval=10, group=grpD, tooltip="1 leaves the comparison raw. Two or three smooths the bar-to-bar noise and makes sustained expansion easier to see, at the cost of reacting a bar later.")
colHot    = input.color(#ff6d00, "Above expectation", group=grpD, inline="c1")
colCool   = input.color(#2962ff, "Within expectation", group=grpD, inline="c1")
colExp    = input.color(#b2b5be, "Expected line",     group=grpD, inline="c2")
colThin   = input.color(#4f5966, "Insufficient sample", group=grpD, inline="c2")

grpE = "Exports"
plotSessAtr = input.bool(false, "Draw the session-corrected ATR", group=grpE, tooltip="The expected bar range for the current bucket. Whether or not it is drawn here, it is always published to other scripts as 'Session ATR (export)', which any script with a source input can select.")
plotVolMult = input.bool(false, "Draw the volatility multiplier", group=grpE, tooltip="Time-of-day expectation divided by the naive all-session baseline. Above 1 means a conventional ATR is understating volatility right now; below 1 means it is overstating it.")

grpT = "Dashboard"
showDash = input.bool(true, "Show dashboard", group=grpT, tooltip="The core card is deliberately small: the time bucket, what a normal bar looks like now, how the current bar compares, relative volume, and how much range is still expected. Everything below is diagnostic and off by default.")
dashPos  = input.string("Middle right", "Position", options=["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"], group=grpT, tooltip="Middle right by default, which keeps the card clear of TradingView's pane toolbar in the top-right corner. Use a top corner with the blank-row setting below if you prefer it up there.")
dashSize = input.string("Small", "Size", options=["Tiny", "Small", "Normal", "Large"], group=grpT)
padTop   = input.int(1, "Blank rows above the card", minval=0, maxval=3, group=grpT, tooltip="TradingView pins its pane toolbar to the top-right corner, where it covers anything drawn underneath. These blank rows push the card down so the buttons sit over empty space instead of your data. Only applied when the card is in a top corner; move the card to the middle or bottom right and you will not need it.")
showProj   = input.bool(true,  "Show the session projection", group=grpT, tooltip="The projected high and low for the session, built at the open from the median day range and where the open typically sits within it. A starting frame for the day, not a forecast.")
showSample = input.bool(false, "Show sample size", group=grpT, tooltip="How many past observations stand behind the current bucket. Worth switching on when you first load the script or change timeframe.")
showPart   = input.bool(false, "Show per-bar participation", group=grpT, tooltip="Normal volume for this time slot and how the current bar compares. The cumulative relative volume on the core card is the more reliable read; this is the bar-by-bar version.")
showMult   = input.bool(false, "Show volatility multiplier", group=grpT, tooltip="How far a conventional all-session ATR is off right now. Diagnostic — the expected range already carries the correction.")
showBudget = input.bool(false, "Show day range detail", group=grpT, tooltip="The median full-session range and how many qualifying days it is drawn from.")
showRank   = input.bool(false, "Show bucket rank", group=grpT, tooltip="Where the current time slot sits in the day's activity ranking, for example 4th busiest of 78. Turns the raw numbers into something you can say out loud.")
showDrift  = input.bool(false, "Show directional drift", group=grpT, tooltip="The share of past observations in this bucket that closed higher than they opened, expressed as a lean from -100 to +100. A persistent lean at a specific time is one of the few genuinely exploitable time-of-day effects, and one of the easiest to fool yourself with on a small sample.")

grpAL = "Alerts"
expThresh  = input.float(2.0, "Expansion threshold (× expected)", minval=1.1, step=0.1, group=grpAL, tooltip="Fires when a bar's range reaches this multiple of normal for its time of day. In a quiet midday bucket this catches genuine initiations that a fixed ATR filter sleeps through entirely.")
conThresh  = input.float(0.4, "Contraction threshold (× expected)", minval=0.05, maxval=0.95, step=0.05, group=grpAL, tooltip="Fires when a bar is unusually dead for its time of day. Useful as a compression signal in buckets that are normally active.")
rvolThresh = input.float(2.0, "Relative volume threshold (×)", minval=1.1, step=0.1, group=grpAL, tooltip="Fires when cumulative session volume reaches this multiple of what is normally traded by this point in the day. Fires once per session.")
warnPct    = input.int(80, "Range budget warning at (%)", minval=25, maxval=99, group=grpAL, tooltip="An early warning before the session has covered a full normal day's range, rather than a notification after the fact.")
alertExp   = input.bool(true,  "Alert on range expansion",   group=grpAL)
alertCon   = input.bool(false, "Alert on range contraction", group=grpAL)
alertRvol  = input.bool(true,  "Alert on unusual relative volume", group=grpAL)
alertBudget= input.bool(true,  "Alert on range budget warning and completion", group=grpAL)
alertBrief = input.bool(true,  "Alert with the session-open briefing", group=grpAL, tooltip="At the session open, sends the expected range for the day and the projected high and low. Because this script lives in its own pane it cannot draw those levels on price, so the alert and the dashboard are how you get them.")
alertFmt   = input.string("Detailed", "Message format", options=["Detailed", "Plain text", "JSON (webhook)"], group=grpAL, tooltip="Detailed: multi-line, best for phone and Discord. Plain text: single line, no unicode, for SMS. JSON: machine-readable payload for webhooks and broker bridges.")
alertTag   = input.string("", "Custom tag (optional)", group=grpAL, tooltip="Prepended to every message — useful when the script runs on several charts or accounts.")

// ════════════ SESSION RESOLUTION ════════════
string tzUse = tzIn == "Exchange" ? syminfo.timezone : tzIn

string pmUse   = preset == "Custom" ? pmCust   : preset == "Futures (Globex)" ? "1800-0930" : preset == "Forex" ? "0200-0800" : preset == "Crypto (24h)" ? "0000-0001" : "0400-0930"
string rthUse  = preset == "Custom" ? rthCust  : preset == "Futures (Globex)" ? "0930-1600" : preset == "Forex" ? "0800-1700" : preset == "Crypto (24h)" ? "0000-2359" : "0930-1600"
string postUse = preset == "Custom" ? postCust : preset == "Futures (Globex)" ? "1600-1700" : preset == "Forex" ? "1700-2000" : preset == "Crypto (24h)" ? "2358-2359" : "1600-2000"

spec(string s) =>
    str.contains(s, ":") ? s : s + ":1234567"

pad2(int v) =>
    (v < 10 ? "0" : "") + str.tostring(v)

inPM   = not na(time(timeframe.period, spec(pmUse),   tzUse))
inRTH  = not na(time(timeframe.period, spec(rthUse),  tzUse))
inPost = not na(time(timeframe.period, spec(postUse), tzUse))
int sid = inRTH ? 2 : inPM ? 1 : inPost ? 3 : 0
sessName = sid == 2 ? "Regular" : sid == 1 ? "Pre-market" : sid == 3 ? "Post-market" : "Overnight"

// ════════════ BUCKET GEOMETRY ════════════
int chartMinRaw = timeframe.in_seconds(timeframe.period) / 60
int chartMin = chartMinRaw < 1 ? 1 : chartMinRaw
int autoB    = chartMin <= 5 ? 5 : chartMin <= 15 ? 15 : chartMin <= 30 ? 30 : 60
int pickB    = bucketMode == "Auto" ? autoB : bucketMode == "5 minutes" ? 5 : bucketMode == "15 minutes" ? 15 : bucketMode == "30 minutes" ? 30 : 60
int bucketMin = pickB < chartMin ? (chartMin <= 5 ? 5 : chartMin <= 15 ? 15 : chartMin <= 30 ? 30 : 60) : pickB
int barsPerBRaw = bucketMin / chartMin
int barsPerB  = barsPerBRaw < 1 ? 1 : barsPerBRaw

// Weekday profiles need seven times the rows, so the per-bucket pools are
// capped tighter in that mode to stay inside Pine's matrix element limit.
int nRows    = dowMode ? 2016 : 288
int poolCap  = dowMode ? 40 : 240
int poolRaw  = sampleDays * barsPerB
int poolCols = poolRaw > poolCap ? poolCap : poolRaw
int remCols  = dowMode ? (sampleDays > 40 ? 40 : sampleDays) : sampleDays

// Per-bar pools, one row per time bucket (per weekday when enabled).
var matrix<float> mRange = matrix.new<float>(nRows, poolCols, na)
var matrix<float> mVol   = matrix.new<float>(nRows, poolCols, na)
var matrix<float> mCum   = matrix.new<float>(nRows, poolCols, na)
var matrix<float> mDrift = matrix.new<float>(nRows, poolCols, na)
var array<int>    ptr    = array.new<int>(nRows, 0)

// Per-session pool: how much additional range each bucket actually saw
// between that point and the close. Written retroactively at session end,
// because the answer is not knowable until the session finishes.
var matrix<float> mRem = matrix.new<float>(nRows, remCols, na)
var array<int>    ptrR = array.new<int>(nRows, 0)
var array<float>  todayCum = array.new<float>(nRows, na)

// ════════════ POOL READS ════════════
// One pass builds the row's live observations; every statistic is taken from
// that array so the matrix is walked once, not once per statistic.
rowPool(matrix<float> m, int r, int cols) =>
    array<float> a = array.new<float>()
    if r >= 0 and r < matrix.rows(m)
        for c = 0 to cols - 1
            float v = matrix.get(m, r, c)
            if not na(v)
                array.push(a, v)
    a

int mod_ = hour(time, tzUse) * 60 + minute(time, tzUse)
int bRaw = int(mod_ / bucketMin)
int bIdx = bRaw < 0 ? 0 : bRaw > 287 ? 287 : bRaw
int dowOff = dowMode ? (dayofweek(time, tzUse) - 1) * 288 : 0
int rIdx = bIdx + dowOff

// Read before writing, so no bar contributes to the expectation it is judged against.
array<float> pR = rowPool(mRange, rIdx, poolCols)
int   nRange   = array.size(pR)
float expRange = nRange > 0 ? array.median(pR) : na
float bandLo   = nRange >= 4 ? array.percentile_linear_interpolation(pR, 25) : na
float bandHi   = nRange >= 4 ? array.percentile_linear_interpolation(pR, 75) : na

array<float> pV = rowPool(mVol, rIdx, poolCols)
float expVol = array.size(pV) > 0 ? array.median(pV) : na

array<float> pC = rowPool(mCum, rIdx, poolCols)
float expCumVol = array.size(pC) > 0 ? array.median(pC) : na

array<float> pD = rowPool(mDrift, rIdx, poolCols)
float expDrift = array.size(pD) > 0 ? array.avg(pD) : na

array<float> pRm = rowPool(mRem, rIdx, remCols)
float expRemain = array.size(pRm) > 0 ? array.median(pRm) : na

float barRange = high - low
bool enoughSample = nRange >= minSample

// ════════════ SESSION TRACKING ════════════
rthOpen = inRTH and not inRTH[1]
rthShut = not inRTH and inRTH[1]

var float rthHi    = na
var float rthLo    = na
var float rthOpenP = na
var float cumVol   = 0.0
var int   rthBars  = 0

float vNow = nz(volume)
if rthOpen
    rthHi    := high
    rthLo    := low
    rthOpenP := open
    cumVol   := vNow
    rthBars  := 1
    array.fill(todayCum, float(na))
else if inRTH
    rthHi   := na(rthHi) ? high : math.max(rthHi, high)
    rthLo   := na(rthLo) ? low  : math.min(rthLo, low)
    cumVol  += vNow
    rthBars += 1

float spentToday = (inRTH and not na(rthHi) and not na(rthLo)) ? rthHi - rthLo : na

// ════════════ POOL WRITES ════════════
if barstate.isconfirmed
    int p = array.get(ptr, rIdx)
    matrix.set(mRange, rIdx, p % poolCols, barRange)
    matrix.set(mVol,   rIdx, p % poolCols, vNow)
    matrix.set(mCum,   rIdx, p % poolCols, inRTH ? cumVol : na)
    matrix.set(mDrift, rIdx, p % poolCols, close > open ? 1.0 : close < open ? -1.0 : 0.0)
    array.set(ptr, rIdx, p + 1)
    if inRTH and not na(spentToday)
        array.set(todayCum, rIdx, spentToday)

// ════════════ DAY-LEVEL STATISTICS ════════════
var array<float> dayRanges = array.new<float>()
var array<float> upShares  = array.new<float>()
var array<float> sessBars  = array.new<float>()

float expDayRange = array.size(dayRanges) > 0 ? array.median(dayRanges) : na
float expUpShare  = array.size(upShares)  > 0 ? array.median(upShares)  : 0.5

if rthShut and not na(rthHi) and not na(rthLo)
    float finalRange = rthHi - rthLo
    array.push(sessBars, float(rthBars))
    if array.size(sessBars) > sampleDays
        array.shift(sessBars)

    // A session qualifies unless it was cut short or, optionally, was an
    // outlier. Both tests need a baseline before they can mean anything.
    float medBars = array.size(sessBars) > 0 ? array.median(sessBars) : na
    bool okLength = not excShort or array.size(sessBars) < 5 or na(medBars) or rthBars >= medBars * 0.75
    bool okSize   = not excOutlier or array.size(dayRanges) < 5 or na(expDayRange) or finalRange <= expDayRange * outMult

    if okLength and okSize and finalRange > 0
        array.push(dayRanges, finalRange)
        if array.size(dayRanges) > sampleDays
            array.shift(dayRanges)
        if not na(rthOpenP)
            array.push(upShares, (rthHi - rthOpenP) / finalRange)
            if array.size(upShares) > sampleDays
                array.shift(upShares)

        // Retroactively file how much range was still to come from each
        // bucket this session touched.
        for r = 0 to nRows - 1
            float cumAt = array.get(todayCum, r)
            if not na(cumAt)
                int q = array.get(ptrR, r)
                matrix.set(mRem, r, q % remCols, math.max(0, finalRange - cumAt))
                array.set(ptrR, r, q + 1)

    array.fill(todayCum, float(na))

float spentPct = (na(expDayRange) or expDayRange <= 0 or na(spentToday)) ? na : 100.0 * spentToday / expDayRange

// Session-open projection, fixed at the open for the rest of the session.
var float projHi = na
var float projLo = na
if rthOpen and not na(expDayRange) and not na(rthOpenP)
    projHi := rthOpenP + expDayRange * expUpShare
    projLo := projHi - expDayRange

// ════════════ DERIVED MEASURES ════════════
float baseRange = ta.percentile_linear_interpolation(high - low, baseLen, 50)
float volMult   = (na(expRange) or na(baseRange) or baseRange <= 0) ? na : expRange / baseRange
float ratioRaw  = (na(expRange) or expRange <= 0) ? na : barRange / expRange
float ratio     = smoothLen > 1 ? ta.sma(ratioRaw, smoothLen) : ratioRaw
float volRatio  = (na(expVol) or expVol <= 0) ? na : volume / expVol
float rvol      = (na(expCumVol) or expCumVol <= 0 or not inRTH) ? na : cumVol / expCumVol

// ════════════ PLOTS ════════════
float actualSeries = plotMode == "Volume" ? volume : plotMode == "Ratio to expected" ? ratio : plotMode == "Relative volume" ? rvol : barRange
float expSeries    = plotMode == "Volume" ? expVol : plotMode == "Ratio to expected" ? 1.0 : plotMode == "Relative volume" ? 1.0 : expRange
float refRatio     = plotMode == "Volume" ? volRatio : plotMode == "Relative volume" ? rvol : ratio
float plotBandLo   = plotMode == "Range" ? bandLo : plotMode == "Ratio to expected" ? (na(expRange) or expRange <= 0 ? na : bandLo / expRange) : na
float plotBandHi   = plotMode == "Range" ? bandHi : plotMode == "Ratio to expected" ? (na(expRange) or expRange <= 0 ? na : bandHi / expRange) : na

color colBar = not enoughSample ? colThin : (na(refRatio) ? colThin : refRatio >= 1.0 ? colHot : colCool)

pLo = plot(showBand ? plotBandLo : na, "Normal range low",  color=color.new(colExp, 80), linewidth=1)
pHi = plot(showBand ? plotBandHi : na, "Normal range high", color=color.new(colExp, 80), linewidth=1)
fill(pLo, pHi, color=color.new(colExp, 92), title="Normal range band")

plot(showCols ? actualSeries : na, "Actual", color=colBar, style=plot.style_columns, linewidth=1)
plot(showExp  ? expSeries    : na, "Expected", color=color.new(colExp, enoughSample ? 0 : 60), style=plot.style_line, linewidth=2)
plot(showThresh ? ((plotMode == "Ratio to expected" or plotMode == "Relative volume") ? expThresh : expSeries * expThresh) : na, "Expansion threshold", color=color.new(colHot, 55), linewidth=1)

// Exports are data-window only so they never influence the pane's scale.
// Separate visible plots exist for when you actually want them drawn.
plot(expRange, "Session ATR (export)", display=display.data_window)
plot(volMult,  "Volatility multiplier (export)", display=display.data_window)
plot(plotSessAtr ? expRange : na, "Session ATR", color=#089981, linewidth=1)
plot(plotVolMult ? volMult  : na, "Volatility multiplier", color=#f23645, linewidth=1)

bgcolor(shadeSess ? (sid == 2 ? colRTH : sid == 1 ? colPM : sid == 3 ? colPost : colNight) : na, title="Session tint")

// ════════════ ALERTS ════════════
msgEvent(string ev, string detail) =>
    string pfx = alertTag == "" ? "" : alertTag + " "
    string out = ""
    if alertFmt == "JSON (webhook)"
        out := '{"tag":"' + alertTag + '","symbol":"' + syminfo.ticker + '","event":"' + ev + '","session":"' + sessName + '","bar_range":' + str.tostring(barRange, "#.####") + ',"expected":' + str.tostring(expRange, "#.####") + ',"ratio":' + str.tostring(ratio, "#.##") + ',"rvol":' + str.tostring(rvol, "#.##") + ',"sample":' + str.tostring(nRange) + ',"time":' + str.tostring(time) + '}'
    else if alertFmt == "Plain text"
        out := pfx + syminfo.ticker + " " + ev + " " + detail + " (" + sessName + ", n=" + str.tostring(nRange) + ")"
    else
        out := pfx + syminfo.ticker + " - " + ev + "\n" + detail + "\nSession: " + sessName + "\nSample: " + str.tostring(nRange) + " observations"
    out

msgBrief() =>
    string pfx = alertTag == "" ? "" : alertTag + " "
    if alertFmt == "JSON (webhook)"
        '{"tag":"' + alertTag + '","symbol":"' + syminfo.ticker + '","event":"SESSION OPEN","open":' + str.tostring(rthOpenP, format.mintick) + ',"expected_range":' + str.tostring(expDayRange, format.mintick) + ',"projected_high":' + str.tostring(projHi, format.mintick) + ',"projected_low":' + str.tostring(projLo, format.mintick) + ',"days":' + str.tostring(array.size(dayRanges)) + ',"time":' + str.tostring(time) + '}'
    else if alertFmt == "Plain text"
        pfx + syminfo.ticker + " SESSION OPEN expected range " + str.tostring(expDayRange, format.mintick) + " projected " + str.tostring(projLo, format.mintick) + "-" + str.tostring(projHi, format.mintick)
    else
        pfx + syminfo.ticker + " - SESSION OPEN BRIEFING\nExpected range: " + str.tostring(expDayRange, format.mintick) + "\nProjected high: " + str.tostring(projHi, format.mintick) + "\nProjected low: " + str.tostring(projLo, format.mintick) + "\nBased on " + str.tostring(array.size(dayRanges)) + " qualifying sessions"

// Every bar-level condition is gated to bar close. Without this, contraction
// would fire at the start of every bar, when a freshly opened bar has almost
// no range yet.
bool expansionNow   = barstate.isconfirmed and enoughSample and not na(ratio) and ratio >= expThresh
bool contractionNow = barstate.isconfirmed and enoughSample and not na(ratio) and ratio <= conThresh

var bool budgetWarned = false
var bool budgetFired  = false
var bool rvolFired    = false
if rthOpen
    budgetWarned := false
    budgetFired  := false
    rvolFired    := false

bool warnNow   = barstate.isconfirmed and inRTH and not budgetWarned and not na(spentPct) and spentPct >= warnPct and spentPct < 100.0
bool budgetNow = barstate.isconfirmed and inRTH and not budgetFired and not na(spentPct) and spentPct >= 100.0
bool rvolNow   = barstate.isconfirmed and inRTH and not rvolFired and not na(rvol) and rvol >= rvolThresh
bool briefNow  = rthOpen and not na(projHi) and not na(projLo)

if warnNow
    budgetWarned := true
if budgetNow
    budgetWarned := true
    budgetFired  := true
if rvolNow
    rvolFired := true

if alertExp and expansionNow
    alert(msgEvent("RANGE EXPANSION", str.tostring(ratio, "#.#") + "x normal for this time of day"), alert.freq_once_per_bar)
if alertCon and contractionNow
    alert(msgEvent("RANGE CONTRACTION", str.tostring(ratio, "#.##") + "x normal for this time of day"), alert.freq_once_per_bar)
if alertRvol and rvolNow
    alert(msgEvent("UNUSUAL VOLUME", "Session volume is " + str.tostring(rvol, "#.##") + "x normal for this point in the day"), alert.freq_once_per_bar)
if alertBudget and warnNow
    alert(msgEvent("RANGE BUDGET WARNING", "Session has covered " + str.tostring(spentPct, "#") + "% of a normal day's range"), alert.freq_once_per_bar)
if alertBudget and budgetNow
    alert(msgEvent("RANGE BUDGET SPENT", "Session has covered a full normal day's range (" + str.tostring(spentToday, "#.##") + " vs " + str.tostring(expDayRange, "#.##") + ")"), alert.freq_once_per_bar)
if alertBrief and briefNow
    alert(msgBrief(), alert.freq_once_per_bar)

alertcondition(expansionNow,   "Range expansion",       "Coldbore Time-of-Day Volatility: bar range is unusually large for this time of day.")
alertcondition(contractionNow, "Range contraction",     "Coldbore Time-of-Day Volatility: bar range is unusually small for this time of day.")
alertcondition(rvolNow,        "Unusual relative volume","Coldbore Time-of-Day Volatility: session volume is well above normal for this point in the day.")
alertcondition(warnNow,        "Range budget warning",  "Coldbore Time-of-Day Volatility: the session is approaching a full normal day's range.")
alertcondition(budgetNow,      "Range budget spent",    "Coldbore Time-of-Day Volatility: the session has covered a full normal day's range.")
alertcondition(briefNow,       "Session open briefing", "Coldbore Time-of-Day Volatility: a new session opened with a projected range.")

// ════════════ DASHBOARD ════════════
// Five core rows answer what a trade needs: what is normal right now, how
// this bar compares, whether participation is unusual, and how much range is
// still expected. Everything else is opt-in.
var table dash = na
if showDash and barstate.islast
    pos = dashPos == "Middle right" ? position.middle_right : dashPos == "Bottom right" ? position.bottom_right : dashPos == "Top left" ? position.top_left : dashPos == "Bottom left" ? position.bottom_left : position.top_right
    txtSz = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small

    int padRows = (dashPos == "Top right" or dashPos == "Top left") ? padTop : 0
    int rows = padRows + 5 + (showProj ? 1 : 0) + (showSample ? 1 : 0) + (showPart ? 1 : 0) + (showMult ? 1 : 0) + (showBudget ? 1 : 0) + (showRank ? 1 : 0) + (showDrift ? 1 : 0)
    if not na(dash)
        table.delete(dash)
    dash := table.new(pos, 3, rows, bgcolor=color.new(color.black, 40), border_width=1, border_color=color.new(color.gray, 70))

    // Pine returns a float from integer division, so the hour must be floored
    // explicitly or the label prints as 18.0833:05.
    int bStart = bIdx * bucketMin
    int bEnd   = bStart + bucketMin
    string bLbl = pad2(int(math.floor(bStart / 60))) + ":" + pad2(bStart % 60) + "-" + pad2(int(math.floor(bEnd / 60)) % 24) + ":" + pad2(bEnd % 60)

    table.cell(dash, 0, padRows + 0, "Time-of-Day Vol", text_color=color.white, text_size=txtSz)
    table.cell(dash, 1, padRows + 0, bLbl, text_color=color.white, text_size=txtSz)
    table.cell(dash, 2, padRows + 0, dowMode ? sessName + " · dow" : sessName, text_color=sid == 2 ? #089981 : color.gray, text_size=txtSz)

    table.cell(dash, 0, padRows + 1, "Normal bar", text_color=color.gray, text_size=txtSz)
    table.cell(dash, 1, padRows + 1, na(expRange) ? "—" : str.tostring(expRange, format.mintick), text_color=enoughSample ? color.white : colThin, text_size=txtSz)
    table.cell(dash, 2, padRows + 1, enoughSample ? (na(bandLo) ? "this bucket" : str.tostring(bandLo, format.mintick) + "-" + str.tostring(bandHi, format.mintick)) : "thin sample", text_color=enoughSample ? color.gray : #f23645, text_size=txtSz)

    table.cell(dash, 0, padRows + 2, "This bar", text_color=color.gray, text_size=txtSz)
    table.cell(dash, 1, padRows + 2, str.tostring(barRange, format.mintick), text_color=color.white, text_size=txtSz)
    table.cell(dash, 2, padRows + 2, na(ratio) ? "—" : str.tostring(ratio, "#.##") + "x", text_color=na(ratio) ? color.gray : ratio >= expThresh ? colHot : ratio <= conThresh ? colCool : color.white, text_size=txtSz)

    table.cell(dash, 0, padRows + 3, "Rel volume", text_color=color.gray, text_size=txtSz)
    table.cell(dash, 1, padRows + 3, na(rvol) ? "—" : str.tostring(rvol, "#.##") + "x", text_color=na(rvol) ? color.gray : rvol >= rvolThresh ? colHot : rvol >= 1.0 ? color.white : colCool, text_size=txtSz)
    table.cell(dash, 2, padRows + 3, inRTH ? "vs normal by now" : "outside session", text_color=color.gray, text_size=txtSz)

    table.cell(dash, 0, padRows + 4, "Range left", text_color=color.gray, text_size=txtSz)
    table.cell(dash, 1, padRows + 4, na(expRemain) ? "—" : str.tostring(expRemain, format.mintick), text_color=color.white, text_size=txtSz)
    table.cell(dash, 2, padRows + 4, na(spentPct) ? (inRTH ? "—" : "outside session") : str.tostring(spentPct, "#") + "% spent", text_color=na(spentPct) ? color.gray : spentPct >= 100 ? colHot : #089981, text_size=txtSz)

    int r = padRows + 5
    if showProj
        table.cell(dash, 0, r, "Projected", text_color=color.gray, text_size=txtSz)
        table.cell(dash, 1, r, na(projHi) ? "—" : str.tostring(projHi, format.mintick), text_color=#f23645, text_size=txtSz)
        table.cell(dash, 2, r, na(projLo) ? "" : str.tostring(projLo, format.mintick), text_color=#089981, text_size=txtSz)
        r += 1
    if showSample
        table.cell(dash, 0, r, "Sample", text_color=color.gray, text_size=txtSz)
        table.cell(dash, 1, r, str.tostring(nRange) + " bars", text_color=enoughSample ? color.white : #f23645, text_size=txtSz)
        table.cell(dash, 2, r, enoughSample ? "ok" : "thin", text_color=enoughSample ? color.gray : #f23645, text_size=txtSz)
        r += 1
    if showPart
        table.cell(dash, 0, r, "Bar volume", text_color=color.gray, text_size=txtSz)
        table.cell(dash, 1, r, na(expVol) ? "—" : str.tostring(expVol, "#"), text_color=color.white, text_size=txtSz)
        table.cell(dash, 2, r, na(volRatio) ? "—" : str.tostring(volRatio, "#.##") + "x", text_color=na(volRatio) ? color.gray : volRatio >= 1.5 ? colHot : color.white, text_size=txtSz)
        r += 1
    if showMult
        table.cell(dash, 0, r, "Vol multiplier", text_color=color.gray, text_size=txtSz)
        table.cell(dash, 1, r, na(volMult) ? "—" : str.tostring(volMult, "#.##") + "x", text_color=na(volMult) ? color.gray : volMult >= 1.0 ? colHot : colCool, text_size=txtSz)
        table.cell(dash, 2, r, "vs naive ATR", text_color=color.gray, text_size=txtSz)
        r += 1
    if showBudget
        table.cell(dash, 0, r, "Normal day", text_color=color.gray, text_size=txtSz)
        table.cell(dash, 1, r, na(expDayRange) ? "—" : str.tostring(expDayRange, format.mintick), text_color=color.white, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(array.size(dayRanges)) + " days", text_color=color.gray, text_size=txtSz)
        r += 1
    if showRank
        // Rank this bucket among the day's buckets by expected range. Walked
        // once, on the last bar only.
        int better = 0
        int scored = 0
        for b = 0 to 287
            array<float> pb = rowPool(mRange, b + dowOff, poolCols)
            if array.size(pb) >= minSample
                scored += 1
                float mv = array.median(pb)
                if not na(expRange) and mv > expRange
                    better += 1
        table.cell(dash, 0, r, "Bucket rank", text_color=color.gray, text_size=txtSz)
        table.cell(dash, 1, r, scored == 0 or na(expRange) ? "—" : "#" + str.tostring(better + 1), text_color=color.white, text_size=txtSz)
        table.cell(dash, 2, r, scored == 0 ? "" : "of " + str.tostring(scored) + " buckets", text_color=color.gray, text_size=txtSz)
        r += 1
    if showDrift
        float driftPct = na(expDrift) ? na : expDrift * 100.0
        table.cell(dash, 0, r, "Drift", text_color=color.gray, text_size=txtSz)
        table.cell(dash, 1, r, na(driftPct) ? "—" : (driftPct > 0 ? "+" : "") + str.tostring(driftPct, "#"), text_color=na(driftPct) ? color.gray : driftPct > 0 ? #089981 : driftPct < 0 ? #f23645 : color.white, text_size=txtSz)
        table.cell(dash, 2, r, "lean this bucket", text_color=color.gray, text_size=txtSz)
````
