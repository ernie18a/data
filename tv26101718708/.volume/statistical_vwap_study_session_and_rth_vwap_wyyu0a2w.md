# Statistical VWAP study: Session and RTH VWAP

- url: https://www.tradingview.com/script/Wyyu0A2w-Statistical-VWAP-study-Session-and-RTH-VWAP/
- type: indicator
- pine_id: PUB;38a5058e9b9b4b86ae1c8fdaeaecdf3b
- version: 1.0

## Description

Session & RTH VWAP — Statistical VWAP Study

This indicator plots two independently calculated Volume Weighted Average Price lines — one anchored to a user-defined pre-market or custom session, and one anchored to the Regular Trading Hours (RTH) open — and combines them into a statistical study that tracks the relationship between the two lines over time. Beyond the two VWAP lines themselves, the indicator calculates a set of statistical deviation bands derived from the midpoint between both VWAPs, maintains a live stats table that tracks retest and crossover behaviour with timing data, and records win/loss statistics based on the directional relationship between the two lines at the close of each RTH session.

The indicator is designed for equity futures traders and anyone who trades instruments with a defined RTH session, though it will function on any market where session times can be configured. It is most useful on intraday timeframes, particularly 1-minute through 15-minute charts, where the two VWAP lines are meaningfully separated and the statistical bands have enough bar data to fill in during the session.


─────────────────────────────────────────────
HOW THE TWO VWAPs WORK
─────────────────────────────────────────────

The Session VWAP anchors to the start of a configurable pre-market or custom session each day and recalculates bar by bar from that anchor using the standard cumulative price-times-volume divided by cumulative volume formula. Because it anchors before the RTH open on most configurations, it captures the overnight sentiment and carry-forward context that the RTH VWAP does not see. The line resets each day at the session start and, uniquely, reanchors dynamically if price makes a new session high — meaning the anchor always sits at the highest point reached during the session rather than being fixed at the first bar. This makes the Session VWAP a high-anchored VWAP that tracks where the average transaction has occurred relative to the session's developing high.

The RTH VWAP anchors to the first bar of the Regular Trading Hours session each day — defaulting to 09:30 EST — and calculates forward from that point. It is a straightforward daily VWAP in the conventional sense, widely used by institutional participants as an execution benchmark. It resets at the RTH open every day regardless of overnight price action.

Both VWAPs have independent price source inputs, so you can, for example, run the Session VWAP on HLC3 and the RTH VWAP on the close, or set both to the same source. Both default to HLC3. Previous session VWAP lines can be displayed on chart for historical context, with the number of retained sessions configurable up to 100.


─────────────────────────────────────────────
THE ANCHOR AND DEVIATION BANDS
─────────────────────────────────────────────

Once both VWAPs are active during the RTH session, the indicator calculates a midpoint anchor on each bar as the simple average of the two VWAP values at that moment. This anchor represents an equilibrium level between the two measures — a price around which both institutional benchmarks are balanced. The anchor can be plotted as a standalone line if desired.

All statistical bands are then derived as offsets from this anchor, calculated from the distribution of bar-by-bar deviations of the price source from the anchor during the current RTH session. Each bar inside the RTH session contributes a deviation value (price minus anchor) and an absolute deviation value to a running intraday dataset that the band calculations draw from. Every band type resets at the RTH open and builds from scratch each session, meaning the bands are always describing the current day's price behaviour relative to the anchor rather than any historical average.

Symmetric Standard Deviation Bands (± 1σ and ± 2σ)

These are calculated using the volume-weighted variance of all bar deviations from the anchor during the session. The formula weights each bar's squared deviation by its volume, so high-volume bars contribute proportionally more to the width of the bands than low-volume bars. The result is a proper volume-weighted standard deviation, not a simple statistical standard deviation. The ± 1σ bands mark the range within which approximately 68% of volume-weighted price activity has occurred relative to the anchor, and ± 2σ marks roughly 95%. On a well-behaved session these bands will tend to expand gradually and consistently as the day progresses. A sudden widening indicates a volatile push away from the anchor with significant volume behind it.

Asymmetric Standard Deviation Bands

Rather than computing a single standard deviation across all deviations, the asymmetric bands split the deviation dataset into two groups: bars where price was above the anchor and bars where price was below the anchor. A separate volume-weighted variance is computed for each group, yielding an upper sigma and a lower sigma. The upper band sits at anchor plus the upper sigma, and the lower band sits at anchor minus the lower sigma. When the upper band is wider than the lower band, the session's upside volatility has been greater than its downside volatility — the distribution is stretched to the upside. The reverse indicates downside skew. This is a more honest representation of intraday volatility than symmetric bands when the session has a directional bias, since symmetric bands will always produce identical upper and lower widths regardless of where price has actually been spending its time.

Median Absolute Deviation Bands (MAD)

The MAD bands are calculated from the median of all absolute deviation values collected during the session. Rather than squaring deviations as standard deviation does, MAD takes the median of their absolute values, making it substantially more resistant to outlier bars. A single spike bar with a large deviation will pull the standard deviation bands outward significantly, but will have very little impact on the MAD bands if the majority of bars have remained close to the anchor. In practice, if the MAD bands are noticeably narrower than the ± 1σ bands, it suggests the session has had one or more sharp but brief excursions from the anchor while most activity has been tightly contained. If the two are similar in width, price volatility has been more evenly distributed throughout the session.

Percentile Bands (10th, 25th, 75th, 90th)

These bands are calculated by sorting the full array of per-bar deviations accumulated during the session and finding the deviation at each percentile using linear interpolation between adjacent values. The result is added to the anchor to produce the plotted level. The 25th and 75th percentile bands define the interquartile range — the zone within which the middle 50% of bars have traded relative to the anchor. The 10th and 90th percentile bands mark the outer boundaries that only 10% of bars have exceeded on each side. Unlike standard deviation bands, percentile bands make no assumption about the shape of the deviation distribution. They are purely empirical — they describe exactly where price has been during the session without any statistical model underlying them. On a trending session the percentile bands will be visibly asymmetric, sitting closer together on one side of the anchor and more spread on the other, directly reflecting the directional distribution of bars.

VWAP of Deviations

This is a single line calculated as the volume-weighted mean of all bar deviations from the anchor during the session. It is plotted as an offset from the anchor — if the line is above the anchor, it means that volume has been transacting above the anchor on a net basis throughout the day. If it is below, the heavier volume has been printing below the anchor. At the very start of the RTH session when both VWAPs are close to each other the line will be near the anchor, and it will drift in the direction where the heavier volume has been occurring as the session progresses. It functions as a volume-weighted bias indicator — a reading consistently above the anchor suggests buyers have been more active on a volume basis, and vice versa.


─────────────────────────────────────────────
CONFIGURATION — SESSIONS SETTINGS
─────────────────────────────────────────────

Time Zone sets the timezone used to interpret the Session window. The tooltip reminds you that GMT and UTC are equivalent. Match this to the timezone shown in the bottom right of your TradingView chart. The default is GMT-4, which corresponds to US Eastern Daylight Time.

Session defines the start and end time of the window within which the Session VWAP is active and accumulating. The default is 0600-0900, representing the pre-market period from 6am to 9am Eastern. You can change this to any time window that suits your instrument and trading style. On instruments without an extended pre-market you might set this to your own session open or any other meaningful anchor time.

Highlight Session enables a background colour fill on bars that fall within the session window, making it easy to see which bars are contributing to the Session VWAP. The colour is configurable next to the toggle and defaults to a faint aqua.


─────────────────────────────────────────────
CONFIGURATION — ANCHOR SESSION VWAP SETTINGS
─────────────────────────────────────────────

VWAP Source sets the price input used for the Session VWAP calculation. The default is HLC3 (the average of high, low, and close), which is the conventional choice for VWAP calculations. Other available options include close, open, HL2, OHLC4, and HLCC4. Changing this will affect both the VWAP line itself and the deviation values used in the band calculations, since the bands use vsrc as their price input.

Session VWAP enables or disables the Session VWAP line on the chart. The colour and line width are set using the colour picker and width field next to the toggle.

Show Previous Session VWAPs enables the display of completed Session VWAP lines from prior days, drawn in the same colour as the live line. These give you a visual history of where previous sessions' VWAPs settled and how the current session compares.

Number of Previous Sessions controls how many prior session VWAP lines are retained on the chart. The range is 1 to 100, defaulting to 50. Higher values provide more historical context but may create visual clutter on longer lookback charts.


─────────────────────────────────────────────
CONFIGURATION — RTH VWAP SETTINGS
─────────────────────────────────────────────

Show RTH VWAP enables or disables the RTH VWAP line. The colour and width are set using the adjacent controls. The RTH VWAP defaults to purple at width 2, making it visually distinct from the thinner Session VWAP.

RTH Session Time (EST) sets the start and end of the RTH window using a session string in the format HHMM-HHMM, interpreted in the America/New_York timezone. The default is 0930-1600, representing the standard US equity market session. Change this for futures instruments that have different session boundaries, or for non-US markets where you want to define a custom RTH equivalent.

RTH VWAP Source sets the price input used specifically for the RTH VWAP calculation, independently of the Session VWAP source. It defaults to HLC3. Having separate source inputs means you can experiment with different price inputs on each line — for example running the RTH VWAP on the close while keeping the Session VWAP on HLC3 — or simply keep both on the same source for consistency.


─────────────────────────────────────────────
CONFIGURATION — STATS TABLE
─────────────────────────────────────────────

Show Stats Table enables or disables the on-chart statistics table.

Position sets where the table appears on the chart. Options cover all eight corners and edge-centre positions. The default is Top Right.

Text Size controls the font size used throughout the table. Options are Tiny, Small, and Normal. Small is the default and suits most screen configurations.

Max Days to Track sets the maximum number of completed RTH sessions the indicator retains in its historical arrays for statistical calculations. The range is 10 to 500, defaulting to 100. Increasing this provides more statistically stable averages but increases memory usage. All statistics in the table — win rate, retest averages, timing distributions, hourly breakdowns — are computed across however many sessions have been recorded up to this limit.


─────────────────────────────────────────────
CONFIGURATION — BAND LEVELS
─────────────────────────────────────────────

Each band type has a checkbox to enable it and one or more colour pickers to control how it appears. All bands are off by default. Each is described in detail in the statistical bands section above. The controls are:

Anchor (midpoint) — enables the midpoint line between the two VWAPs, with a single colour picker. Useful as a reference when evaluating the bands.

± 1σ (symmetric) — enables the symmetric ± 1 standard deviation bands, with a single shared colour applied to both the upper and lower line.

± 2σ (symmetric) — enables the symmetric ± 2 standard deviation bands, with a single shared colour.

Asymmetric σ (upper/lower) — enables the asymmetric bands with separate colour pickers for the upper and lower line, allowing you to visually distinguish upside from downside volatility.

MAD (± median abs dev) — enables the MAD bands with a single shared colour.

Percentile bands (10/25/75/90) — enables all four percentile bands with separate colour pickers for the inner pair (25th/75th) and the outer pair (10th/90th).

VWAP of deviations — enables the volume-weighted mean deviation line with a single colour picker.


─────────────────────────────────────────────
THE STATS TABLE — WHAT IT SHOWS AND HOW TO READ IT
─────────────────────────────────────────────

The table is divided into four sections. A yellow header row at the very top shows the total number of completed RTH sessions recorded and the maximum days setting, so you always know the sample size behind the statistics.

Sessions Coverage

The coverage row reads as "SESSIONS: X days | max tracked: Y". X is the number of completed RTH sessions the indicator has observed and recorded since being applied to the chart. Y is the Max Days to Track setting. Once X equals Y the oldest sessions begin dropping off as new ones are added, keeping a rolling window. On a 1-minute chart with 100 max days, the indicator will typically reach the maximum within the first few weeks of chart data.

Win / Loss

This section tracks whether the relative position of the two VWAPs at the end of the RTH session correctly predicted the directional close for that day.

The TODAY row shows the current live state: whether the RTH VWAP is currently above or below the Session VWAP (RTH ABOVE or RTH BELOW), and whether price is currently above or below the RTH open (BULL or BEAR). If the RTH session has not yet started, it shows AWAITING.

WIN RATE shows the percentage of completed sessions in which the end-of-day RTH VWAP position correctly predicted the directional close. A session is counted as a win when the RTH VWAP finished above the Session VWAP and price closed above the RTH open (a bullish alignment), or when the RTH VWAP finished below the Session VWAP and price closed below the RTH open (a bearish alignment). The detail column shows the raw count as wins over total sessions.

BULL/BEAR shows the breakdown of winning sessions by direction — how many of the wins were in the bullish alignment versus the bearish alignment. This helps identify whether the signal has directional asymmetry on your instrument.

STREAK shows whether the current streak is a run of wins or losses and how many consecutive sessions it has lasted.

Retests & Crossovers

This section measures two types of intraday behaviour: VWAP retests and VWAP crossovers.

A retest is recorded when a bar's wick crosses through one of the VWAPs but the bar's close remains on the same side it was on before the wick. In other words, price touches or briefly pierces the VWAP level but the candle does not close through it, indicating the level held. RTH RETEST counts retests of the RTH VWAP and SESS RETEST counts retests of the Session VWAP. The mean and median columns show the average and median number of these events per day across the recorded session history. A mean of 3.2 for RTH retests, for example, means the RTH VWAP is typically touched and rejected roughly three times per session.

A crossover is recorded when the RTH VWAP crosses above or below the Session VWAP on a confirmed bar. This is a stronger event than a retest because it means the two benchmarks have swapped relative positions. CROSSOVERS shows the average and median number of such crosses per day. On low-volatility days in a clearly directional instrument the crossover count may be zero or one. On ranging or volatile days it may be several.

Event Timing

This section answers the question of when during the RTH session these events tend to happen. For each of the three event types — RTH retest, Session retest, and crossover — it shows the average time, the median time, and the peak hour, all in EST.

The average time is the mean of the fractional hour at which each event has occurred across the full history, converted to a HH:MM display. The median time is the 50th percentile of that same distribution. The peak hour is whichever one-hour bucket between 09:00 and 15:00 has accumulated the most events in total across the session history.

If the median RTH retest time is 10:08 and the peak hour is 10h, that tells you retests of the RTH VWAP have historically been most concentrated in the first hour after the open. If the average and median are separated — say average is 11:30 but median is 10:45 — it suggests there is a tail of late-session events pulling the mean later, but most activity happens earlier.

Hourly Event Count

This section gives you the raw breakdown of event counts by hour, running from the 09:00 hour through to the 15:00 hour. Each row represents one hour and shows the total number of RTH retests, Session retests, and crossovers that have occurred during that hour across all recorded sessions. This is the full distribution from which the peak hour in the timing section is derived, and it lets you see the shape of that distribution rather than just the peak. An instrument where the hourly counts are spread fairly evenly across all hours behaves very differently to one where most events are concentrated in the 09:00 and 15:00 hours, and that pattern is immediately visible here.


─────────────────────────────────────────────
TIPS FOR EFFECTIVE USE
─────────────────────────────────────────────

Start with the two VWAP lines alone and observe how often the RTH VWAP and Session VWAP converge, diverge, and cross during your instrument's typical session. The relative position of the two lines at the open versus at midday and close is the core input to the win/loss tracking, so developing an intuition for how they interact on your specific instrument before enabling the bands is worthwhile.

The win rate statistic is a measure of historical alignment between the two VWAPs and the daily directional close — it is not a prediction of tomorrow's outcome. Its value is in telling you whether the two-VWAP relationship has had directional relevance on this instrument historically. A win rate significantly above 50% suggests the configuration carries predictive information worth paying attention to; near 50% suggests it has been essentially random.

For the statistical bands, start by enabling the symmetric ± 1σ and ± 2σ bands alongside the anchor line to get a baseline feel for the session's deviation range. Then enable the asymmetric bands on a few sessions where you noticed a strong directional bias to see how the upper and lower widths diverge. The MAD bands are most informative when compared directly against the ± 1σ bands — if MAD is substantially tighter it means the session has had outlier bars inflating the standard deviation that most of the session's activity did not participate in.

The VWAP of deviations line is a useful real-time bias read once you are familiar with it. In a session where the line has been consistently positive (above the anchor) since the open and has not reversed, the weight of volume is behind the bullish side of the anchor. A line that has drifted from positive to negative mid-session suggests a shift in volume-weighted participation, which often precedes or accompanies meaningful directional moves.

The timing data in the table is most useful when you have accumulated 50 or more sessions of history and are trading an instrument with a consistent intraday rhythm. Instruments with predictable open-range activity and a defined close pattern will show clear concentrations in the hourly breakdown. Instruments that are event-driven or highly macro-sensitive will tend to show flatter distributions.

The Max Days to Track setting has a meaningful effect on all statistics. A smaller value — say 20 or 30 — will make the statistics more responsive to recent conditions but noisier. A larger value — 200 or 500 — will produce more stable averages but may lag if the instrument's behaviour has changed regime. For most use cases 50 to 100 days strikes a reasonable balance.

On instruments where the pre-market session is not meaningful or does not exist, set the Session time window to a custom anchor of your choice — for example the overnight high or the globex open — and the Session VWAP will anchor from that point instead. The statistical framework operates identically regardless of what the session window represents.


─────────────────────────────────────────────
DISCLAIMER
─────────────────────────────────────────────

This indicator is provided for informational and educational purposes only. It does not constitute financial advice, investment advice, or a trading recommendation of any kind. All statistical outputs — win rates, retest averages, timing distributions — are derived from historical data and are not indicative of future results. The user assumes full responsibility for any trading decisions made using this tool. Always apply your own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © npg

//@version=5
indicator("Session & RTH VWAP", shorttitle = 'SV+RTH', overlay = true, max_bars_back = 5000)

var g0      = 'Sessions Settings'
tz          = input.string("GMT-4", "Time Zone", tooltip = "GMT and UTC is the same thing \nMatch this setting to bottom right time", options = ["GMT-10", "GMT-9", "GMT-8", "GMT-7", "GMT-6", "GMT-5", "GMT-4", "GMT-3", "GMT+0", "GMT+1", "GMT+2", "GMT+3", "GMT+4", "GMT+5", "GMT+6", "GMT+7", "GMT+8", "GMT+9", "GMT+10", "GMT+10:30", "GMT+11", "GMT+12", "GMT+13", "GMT+13:45"], group = g0)
sessionTime = input.session('0600-0900', 'Session', group = g0)
highlight   = input.bool(false, 'Highlight Session', inline = '1', group = g0)
hCol        = input.color(color.new(color.aqua,90), '', inline = '1', group = g0)

var g1      = 'Anchor Session VWAP Settings'
vsrc        = input.source(hlc3, 'VWAP Source', group = g1)
showHigh    = input.bool(true, 'Show Session VWAP', inline = '1', group = g1)
highCol     = input.color(color.blue, '', inline = '1', group = g1)
highW       = input.int(1, '', inline = '1', group = g1)
showOld     = input.bool(true, 'Show Previous Session VWAP\'s', group = g1)
numSessions = input.int(50, 'Number of Previous Sessions', minval = 1, maxval = 100, group = g1)

var g2      = 'RTH VWAP Settings'
rth_vsrc    = input.source(hlc3, 'RTH VWAP Source', group = g2)
showRTH     = input.bool(true, 'Show RTH VWAP', inline = '1', group = g2)
rthCol      = input.color(color.new(color.purple, 30), '', inline = '1', group = g2)
rthW        = input.int(2, '', inline = '1', group = g2)
input_rth   = input.session("0930-1600", "RTH Session Time (EST)", group = g2)


var g3      = 'Stats Table'
showTable   = input.bool(true, 'Show Stats Table', group = g3)
tblPos      = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Top Center', 'Bottom Right', 'Bottom Left', 'Bottom Center', 'Middle Right', 'Middle Left'], group = g3)
tblSize     = input.string('Small', 'Text Size', options = ['Tiny', 'Small', 'Normal'], group = g3)
maxDays     = input.int(100, 'Max Days to Track', minval = 10, maxval = 500, group = g3)

// ─── Band Levels inputs ───────────────────────────────────────────────────────
// Anchor = midpoint of RTH VWAP and Session VWAP each bar.
// All bands are offsets from that anchor, calculated from the intraday
// distribution of (price - anchor) deviations, volume-weighted where noted.

var g4        = 'Band Levels'

// Anchor line
showAnchor    = input.bool(false, 'Anchor (midpoint)',     inline = 'anc',  group = g4)
anchorCol     = input.color(color.new(color.black, 30),  '',               inline = 'anc',  group = g4)

// Symmetric stdev
show1s        = input.bool(false, '± 1σ  (symmetric)',    inline = 's1',   group = g4)
col1s         = input.color(color.new(color.yellow, 50), '',               inline = 's1',   group = g4)
show2s        = input.bool(false, '± 2σ  (symmetric)',    inline = 's2',   group = g4)
col2s         = input.color(color.new(color.yellow, 65), '',               inline = 's2',   group = g4)

// Asymmetric stdev (upper/lower computed separately)
showAsym      = input.bool(false, 'Asymmetric σ (upper/lower)', inline = 'asy', group = g4)
colAsymHi     = input.color(color.new(color.orange, 50), '',               inline = 'asy',  group = g4)
colAsymLo     = input.color(color.new(color.orange, 50), '',               inline = 'asy',  group = g4)

// MAD
showMAD       = input.bool(false, 'MAD  (± median abs dev)', inline = 'mad', group = g4)
colMAD        = input.color(color.new(color.teal, 40),   '',               inline = 'mad',  group = g4)

// Percentile bands — 10th/25th/75th/90th of deviation distribution
showPct       = input.bool(false, 'Percentile bands (10/25/75/90)', inline = 'pct', group = g4)
colPct25      = input.color(color.new(color.blue, 50),   '',               inline = 'pct',  group = g4)
colPct75      = input.color(color.new(color.blue, 50),   '',               inline = 'pct',  group = g4)
colPct10      = input.color(color.new(color.blue, 65),   '',               inline = 'pct',  group = g4)
colPct90      = input.color(color.new(color.blue, 65),   '',               inline = 'pct',  group = g4)

// VWAP of deviations — volume-weighted mean deviation line
showVWD       = input.bool(false, 'VWAP of deviations',   inline = 'vwd',  group = g4)
colVWD        = input.color(color.new(color.fuchsia, 40),'',               inline = 'vwd',  group = g4)

// ─── Helpers ──────────────────────────────────────────────────────────────────
f_pos() =>
    switch tblPos
        'Top Right'     => position.top_right
        'Top Left'      => position.top_left
        'Top Center'    => position.top_center
        'Bottom Right'  => position.bottom_right
        'Bottom Left'   => position.bottom_left
        'Bottom Center' => position.bottom_center
        'Middle Right'  => position.middle_right
        'Middle Left'   => position.middle_left
        => position.top_right

f_size() =>
    switch tblSize
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        => size.small

f_pad(string s, int w) =>
    out = s
    extra = w - str.length(s)
    if extra > 0
        for i = 1 to extra
            out := out + ' '
    out

f_price(float p) =>
    na(p) ? 'n/a' : str.tostring(p, format.mintick)

f_sess_start() =>
    str.substring(sessionTime, 0, 2) + ':' + str.substring(sessionTime, 2, 4)

f_rth_start() =>
    str.substring(input_rth, 0, 2) + ':' + str.substring(input_rth, 2, 4)

f_round2(float v) =>
    str.tostring(math.round(v, 2))

// Convert fractional hour (e.g. 10.75) to HH:MM string
f_hhmm(float fh) =>
    if na(fh)
        'n/a'
    else
        int h   = int(fh)
        int m   = int(math.round((fh - h) * 60))
        string hs = h < 10 ? '0' + str.tostring(h) : str.tostring(h)
        string ms = m < 10 ? '0' + str.tostring(m) : str.tostring(m)
        hs + ':' + ms

// Current bar time as fractional hour in EST (for intraday event tagging)
f_bar_hour_frac() =>
    float t_mins = (hour(time, "America/New_York") * 60 + minute(time, "America/New_York"))
    t_mins / 60.0

// Median of a float array (sorts a copy)
f_median(array<float> arr) =>
    float result = na
    if arr.size() > 0
        sorted = arr.copy()
        sorted.sort()
        int n = sorted.size()
        result := n % 2 == 1 ? sorted.get(n / 2) : (sorted.get(n / 2 - 1) + sorted.get(n / 2)) / 2
    result

// Quartiles
f_q1(array<float> arr) =>
    float result = na
    if arr.size() >= 4
        sorted = arr.copy()
        sorted.sort()
        int n = sorted.size()
        int mid = n / 2
        lower = sorted.slice(0, mid)
        result := f_median(lower)
    result

f_q3(array<float> arr) =>
    float result = na
    if arr.size() >= 4
        sorted = arr.copy()
        sorted.sort()
        int n = sorted.size()
        int mid = n % 2 == 1 ? n / 2 + 1 : n / 2
        upper = sorted.slice(mid, n)
        result := f_median(upper)
    result

// ─── Table cell helpers ───────────────────────────────────────────────────────
var table _tbl = na

f_header(row, txt) =>
    table.cell(_tbl, 0, row, txt, text_color = color.white, text_size = f_size(), bgcolor = color.new(color.black, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.merge_cells(_tbl, 0, row, 2, row)

f_subhead(row, c0, c1, c2) =>
    table.cell(_tbl, 0, row, f_pad(' ' + c0, 14), text_color = color.white, text_size = f_size(), bgcolor = color.new(color.black, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(_tbl, 1, row, f_pad(' ' + c1, 14), text_color = color.white, text_size = f_size(), bgcolor = color.new(color.black, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(_tbl, 2, row, f_pad(' ' + c2, 16), text_color = color.white, text_size = f_size(), bgcolor = color.new(color.black, 0), text_halign = text.align_left, text_font_family = font.family_monospace)

f_row(row, lbl, val, detail) =>
    table.cell(_tbl, 0, row, f_pad(' ' + lbl,    14), text_color = color.black, text_size = f_size(), bgcolor = color.white, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(_tbl, 1, row, f_pad(' ' + val,    14), text_color = color.black, text_size = f_size(), bgcolor = color.white, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(_tbl, 2, row, f_pad(' ' + detail, 16), text_color = color.black, text_size = f_size(), bgcolor = color.white, text_halign = text.align_left, text_font_family = font.family_monospace)

// ─── Session & VWAP logic ─────────────────────────────────────────────────────
session      = time(timeframe.period, sessionTime, tz)
startSession = not na(session) and na(session[1])
newDay       = ta.change(dayofweek) != 0

type vwapData
    float [] vol
    float [] pv
    float [] vwaps
    float hl
    int startBar
    chart.point fbs
    chart.point [] cps
    polyline vwapLine
    bool ended

method popper(array<vwapData> this) =>
    if showOld
        if this.size() > numSessions + 1
            this.last().vwapLine.delete()
            this.pop()
    else
        if this.size() > 1
            this.last().vwapLine.delete()
            this.pop()

method vwapper(array<vwapData> this, lineCol, lineW) =>
    if newDay and this.size() > 0
        for i = 0 to this.size() - 1
            tempSession = this.get(i)
            tempSession.ended := true
    if this.size() > 0
        s = this.first()
        if bar_index > s.startBar and not s.ended
            s.vol.push(s.vol.get(0) + volume)
            s.vol.shift()
            s.pv.push(s.pv.get(0) + vsrc * volume)
            s.pv.shift()
            s.vwaps.unshift(s.pv.get(0) / s.vol.get(0))
            s.cps.clear()
            for i = 0 to s.vwaps.size() - 1
                s.cps.push(chart.point.from_index(bar_index[i], s.vwaps.get(i)))
            s.cps.push(s.fbs)
            s.vwapLine.delete()
            s.vwapLine := polyline.new(s.cps, line_color = lineCol, line_width = lineW)
        if this.size() > 1 and showOld
            s2 = this.last()
            if bar_index > s2.startBar and not s2.ended
                s2.vol.push(s2.vol.get(0) + volume)
                s2.vol.shift()
                s2.pv.push(s2.pv.get(0) + vsrc * volume)
                s2.pv.shift()
                s2.vwaps.unshift(s2.pv.get(0) / s2.vol.get(0))
                s2.cps.clear()
                for i = 0 to s2.vwaps.size() - 1
                    s2.cps.push(chart.point.from_index(bar_index[i], s2.vwaps.get(i)))
                s2.cps.push(s2.fbs)
                s2.vwapLine.delete()
                s2.vwapLine := polyline.new(s2.cps, line_color = lineCol, line_width = lineW)

method hlReset(array<vwapData> this, h) =>
    if this.size() > 0
        s = this.first()
        if h
            if not na(session) and high > s.hl
                s.vwapLine.delete()
                s.vwapLine := na
                this.shift()
                this.unshift(vwapData.new(array.new<float>(1, volume), array.new<float>(1, volume * vsrc), array.new<float>(), high, bar_index, chart.point.from_index(bar_index, (volume * vsrc) / volume), array.new<chart.point>(), na, false))
        else
            if not na(session) and low < s.hl
                s.vwapLine.delete()
                s.vwapLine := na
                this.shift()
                this.unshift(vwapData.new(array.new<float>(1, volume), array.new<float>(1, volume * vsrc), array.new<float>(), low, bar_index, chart.point.from_index(bar_index, (volume * vsrc) / volume), array.new<chart.point>(), na, false))

var startArr = array.new<vwapData>()
var highArr  = array.new<vwapData>()
var lowArr   = array.new<vwapData>()

if startSession
    if showHigh
        highArr.unshift(vwapData.new(array.new<float>(1, volume), array.new<float>(1, volume * vsrc), array.new<float>(), high, bar_index, chart.point.from_index(bar_index, (volume * vsrc) / volume), array.new<chart.point>(), na, false))
        highArr.popper()

if showHigh
    highArr.vwapper(highCol, highW)
    highArr.hlReset(true)

// ─── RTH VWAP ─────────────────────────────────────────────────────────────────
rth_session = time("1440", str.format("{0}:23456", input_rth), "America/New_York")

var float rth_vwap       = na
var float rth_p          = na
var float rth_vol        = na
var float rth_anchor_val = na

if rth_session
    if not rth_session[1]
        rth_anchor_val := rth_vsrc
        rth_p          := rth_vsrc * volume
        rth_vol        := volume
        rth_vwap       := rth_vsrc
    else
        rth_p    := rth_p[1] + rth_vsrc * volume
        rth_vol  := rth_vol[1] + volume
        rth_vwap := rth_p / rth_vol
else
    rth_vwap := na

// ─── Live session VWAP value ──────────────────────────────────────────────────
var float sess_vwap_live = na
if highArr.size() > 0
    s = highArr.first()
    if s.vwaps.size() > 0
        sess_vwap_live := s.vwaps.get(0)

// ─── Crossover & Retest Detection (confirmed bars only) ───────────────────────
var int   day_rth_retests  = 0
var int   day_sess_retests = 0
var int   day_crossovers   = 0
var float prev_rth_side    = na
var float prev_sess_side   = na
var bool  prev_rth_above   = na

// Arrays to accumulate per-day counts
var array<float> arr_rth_retests  = array.new<float>()
var array<float> arr_sess_retests = array.new<float>()
var array<float> arr_crossovers   = array.new<float>()

// ─── Timing arrays (fractional hour in EST, one entry per event) ──────────────
// All-time event times — used for mean/median across entire history
var array<float> arr_rth_retest_times  = array.new<float>()
var array<float> arr_sess_retest_times = array.new<float>()
var array<float> arr_crossover_times   = array.new<float>()

// Per-hour bucket accumulators (9 buckets: 09, 10, 11, 12, 13, 14, 15, and one each for pre/post)
// Indices 0-6 = hours 9–15 EST, index 7 = other (shouldn't normally fire during RTH)
var array<int> bucket_rth_ret  = array.new<int>(8, 0)
var array<int> bucket_sess_ret = array.new<int>(8, 0)
var array<int> bucket_cross    = array.new<int>(8, 0)

f_bucket(float fh) =>
    int h = int(fh)
    h >= 9 and h <= 15 ? h - 9 : 7

f_bucket_label(int idx) =>
    switch idx
        0 => '09'
        1 => '10'
        2 => '11'
        3 => '12'
        4 => '13'
        5 => '14'
        6 => '15'
        => 'oth'

// Find the peak hour bucket across an array
f_peak_bucket(array<int> arr) =>
    int best_idx = 0
    int best_val = 0
    for i = 0 to arr.size() - 1
        v = arr.get(i)
        if v > best_val
            best_val := v
            best_idx := i
    best_idx

// Stats arrays
var int  stat_wins        = 0
var int  stat_bullish     = 0
var int  stat_bearish     = 0
var int  stat_total       = 0
var int  stat_streak      = 0
var bool stat_streak_win  = true

var float snap_rth_vwap   = na
var float snap_sess_vwap  = na
var float snap_open       = na

// RTH return distribution
var array<float> arr_returns = array.new<float>()

rthEnd = not na(rth_session[1]) and na(rth_session)

// Track open at RTH start
if rth_session and not rth_session[1]
    snap_open      := open
    prev_rth_side  := na
    prev_sess_side := na
    prev_rth_above := na
    day_rth_retests  := 0
    day_sess_retests := 0
    day_crossovers   := 0

// Intraday detection on confirmed bars (use [1] values to avoid repaint)
if rth_session and not na(rth_vwap[1]) and not na(sess_vwap_live[1]) and barstate.isconfirmed
    float c    = close[1]
    float h    = high[1]
    float l    = low[1]
    float rv   = rth_vwap[1]
    float sv   = sess_vwap_live[1]

    // Use [1] bar time for event tagging (confirmed bar)
    float evt_fh = float(hour(time[1], "America/New_York")) + float(minute(time[1], "America/New_York")) / 60.0

    // RTH VWAP retest
    float cur_rth_side = c > rv ? 1 : c < rv ? -1 : 0
    if not na(prev_rth_side) and cur_rth_side == prev_rth_side
        if (prev_rth_side > 0 and l < rv) or (prev_rth_side < 0 and h > rv)
            day_rth_retests += 1
            arr_rth_retest_times.unshift(evt_fh)
            if arr_rth_retest_times.size() > maxDays * 10
                arr_rth_retest_times.pop()
            int bk = f_bucket(evt_fh)
            bucket_rth_ret.set(bk, bucket_rth_ret.get(bk) + 1)
    prev_rth_side := cur_rth_side

    // Session VWAP retest
    float cur_sess_side = c > sv ? 1 : c < sv ? -1 : 0
    if not na(prev_sess_side) and cur_sess_side == prev_sess_side
        if (prev_sess_side > 0 and l < sv) or (prev_sess_side < 0 and h > sv)
            day_sess_retests += 1
            arr_sess_retest_times.unshift(evt_fh)
            if arr_sess_retest_times.size() > maxDays * 10
                arr_sess_retest_times.pop()
            int bk = f_bucket(evt_fh)
            bucket_sess_ret.set(bk, bucket_sess_ret.get(bk) + 1)
    prev_sess_side := cur_sess_side

    // RTH vs Session VWAP crossover
    bool cur_rth_above = rv > sv
    if not na(prev_rth_above) and cur_rth_above != prev_rth_above
        day_crossovers += 1
        arr_crossover_times.unshift(evt_fh)
        if arr_crossover_times.size() > maxDays * 10
            arr_crossover_times.pop()
        int bk = f_bucket(evt_fh)
        bucket_cross.set(bk, bucket_cross.get(bk) + 1)
    prev_rth_above := cur_rth_above

if rth_session
    snap_rth_vwap  := rth_vwap
    snap_sess_vwap := sess_vwap_live

// At RTH end: commit all stats for the day
if rthEnd and not na(snap_rth_vwap) and not na(snap_sess_vwap) and stat_total < maxDays
    bool rth_above   = snap_rth_vwap > snap_sess_vwap
    bool closed_bull = close > snap_open
    bool is_win      = (rth_above and closed_bull) or (not rth_above and not closed_bull)

    stat_total += 1
    if is_win
        stat_wins += 1
        if rth_above
            stat_bullish += 1
        else
            stat_bearish += 1
        if stat_streak_win
            stat_streak += 1
        else
            stat_streak     := 1
            stat_streak_win := true
    else
        if not stat_streak_win
            stat_streak += 1
        else
            stat_streak     := 1
            stat_streak_win := false

    if not na(snap_open) and snap_open != 0
        float ret = (close - snap_open) / snap_open * 100
        arr_returns.unshift(ret)
        if arr_returns.size() > maxDays
            arr_returns.pop()

    arr_rth_retests.unshift(day_rth_retests)
    arr_sess_retests.unshift(day_sess_retests)
    arr_crossovers.unshift(day_crossovers)
    if arr_rth_retests.size()  > maxDays
        arr_rth_retests.pop()
    if arr_sess_retests.size() > maxDays
        arr_sess_retests.pop()
    if arr_crossovers.size()   > maxDays
        arr_crossovers.pop()

// ─── Distribution Stats (for table counts) ───────────────────────────────────
float rth_ret_mean  = arr_rth_retests.size()  > 0 ? arr_rth_retests.avg()  : na
float sess_ret_mean = arr_sess_retests.size()  > 0 ? arr_sess_retests.avg() : na
float cross_mean    = arr_crossovers.size()    > 0 ? arr_crossovers.avg()   : na
float rth_ret_med   = f_median(arr_rth_retests)
float sess_ret_med  = f_median(arr_sess_retests)
float cross_med     = f_median(arr_crossovers)

// ─── Timing Stats ─────────────────────────────────────────────────────────────
float rth_ret_time_mean   = arr_rth_retest_times.size()  > 0 ? arr_rth_retest_times.avg()  : na
float sess_ret_time_mean  = arr_sess_retest_times.size() > 0 ? arr_sess_retest_times.avg() : na
float cross_time_mean     = arr_crossover_times.size()   > 0 ? arr_crossover_times.avg()   : na
float rth_ret_time_med    = f_median(arr_rth_retest_times)
float sess_ret_time_med   = f_median(arr_sess_retest_times)
float cross_time_med      = f_median(arr_crossover_times)

int pk_rth_ret  = f_peak_bucket(bucket_rth_ret)
int pk_sess_ret = f_peak_bucket(bucket_sess_ret)
int pk_cross    = f_peak_bucket(bucket_cross)


// These run bar-by-bar inside the RTH session to build the deviation
// distribution from which all bands are derived.

var float band_vol_sum   = 0.0   // Σ vol
var float band_pvv_sum   = 0.0   // Σ vol×dev²            → weighted variance
var float band_pvv_hi    = 0.0   // Σ vol×dev² (dev > 0)  → upper variance
var float band_pvv_lo    = 0.0   // Σ vol×dev² (dev < 0)  → lower variance
var float band_vol_hi    = 0.0   // Σ vol where dev > 0
var float band_vol_lo    = 0.0   // Σ vol where dev < 0
var float band_vwd_num   = 0.0   // Σ vol×dev             → VWAP of deviations
var array<float> band_devs    = array.new<float>()   // per-bar deviations
var array<float> band_abs_dev = array.new<float>()   // per-bar |deviation|

// Anchor: midpoint of the two live VWAPs
float band_anchor = not na(rth_vwap) and not na(sess_vwap_live) ? (rth_vwap + sess_vwap_live) / 2 : na

// Reset at RTH open
if rth_session and not rth_session[1]
    band_vol_sum  := 0.0
    band_pvv_sum  := 0.0
    band_pvv_hi   := 0.0
    band_pvv_lo   := 0.0
    band_vol_hi   := 0.0
    band_vol_lo   := 0.0
    band_vwd_num  := 0.0
    band_devs.clear()
    band_abs_dev.clear()

// Accumulate each bar inside RTH
if rth_session and not na(band_anchor)
    float dev  = vsrc - band_anchor
    float adev = math.abs(dev)
    band_vol_sum  += volume
    band_pvv_sum  += volume * dev * dev
    band_vwd_num  += volume * dev
    band_devs.push(dev)
    band_abs_dev.push(adev)
    if dev > 0
        band_pvv_hi += volume * dev * dev
        band_vol_hi += volume
    else if dev < 0
        band_pvv_lo += volume * dev * dev
        band_vol_lo += volume

// ─── Percentile helper (linear interpolation) ────────────────────────────────
f_pct(array<float> arr, float p) =>
    // p in [0,100]
    float result = na
    int n = arr.size()
    if n >= 2
        sorted = arr.copy()
        sorted.sort()
        float idx = p / 100.0 * (n - 1)
        int   lo  = int(idx)
        int   hi  = math.min(lo + 1, n - 1)
        float frac = idx - lo
        result := sorted.get(lo) * (1 - frac) + sorted.get(hi) * frac
    result

// ─── Band Level Calculation ───────────────────────────────────────────────────
// Symmetric stdev
float b_stdev     = band_vol_sum > 0 ? math.sqrt(band_pvv_sum / band_vol_sum) : na
float b_1s_hi     = show1s and not na(band_anchor) and not na(b_stdev) ? band_anchor + b_stdev       : na
float b_1s_lo     = show1s and not na(band_anchor) and not na(b_stdev) ? band_anchor - b_stdev       : na
float b_2s_hi     = show2s and not na(band_anchor) and not na(b_stdev) ? band_anchor + 2 * b_stdev   : na
float b_2s_lo     = show2s and not na(band_anchor) and not na(b_stdev) ? band_anchor - 2 * b_stdev   : na

// Asymmetric stdev
float b_stdev_hi  = band_vol_hi > 0 ? math.sqrt(band_pvv_hi / band_vol_hi) : na
float b_stdev_lo  = band_vol_lo > 0 ? math.sqrt(band_pvv_lo / band_vol_lo) : na
float b_asym_hi   = showAsym and not na(band_anchor) and not na(b_stdev_hi) ? band_anchor + b_stdev_hi : na
float b_asym_lo   = showAsym and not na(band_anchor) and not na(b_stdev_lo) ? band_anchor - b_stdev_lo : na

// MAD (median of absolute deviations)
float b_mad       = f_median(band_abs_dev)
float b_mad_hi    = showMAD and not na(band_anchor) and not na(b_mad) ? band_anchor + b_mad : na
float b_mad_lo    = showMAD and not na(band_anchor) and not na(b_mad) ? band_anchor - b_mad : na

// Percentile bands (offsets added to anchor)
float b_pct10     = showPct and not na(band_anchor) ? band_anchor + f_pct(band_devs, 10) : na
float b_pct25     = showPct and not na(band_anchor) ? band_anchor + f_pct(band_devs, 25) : na
float b_pct75     = showPct and not na(band_anchor) ? band_anchor + f_pct(band_devs, 75) : na
float b_pct90     = showPct and not na(band_anchor) ? band_anchor + f_pct(band_devs, 90) : na

// VWAP of deviations (volume-weighted mean deviation, offset from anchor)
float b_vwd_raw   = band_vol_sum > 0 ? band_vwd_num / band_vol_sum : na
float b_vwd       = showVWD and not na(band_anchor) and not na(b_vwd_raw) ? band_anchor + b_vwd_raw : na

// ─── Live status ──────────────────────────────────────────────────────────────
bool today_rth_active = not na(rth_vwap)
bool today_rth_above  = today_rth_active and not na(sess_vwap_live) and rth_vwap > sess_vwap_live
bool today_bull       = not na(snap_open) and close > snap_open

// ─── Stats Table ──────────────────────────────────────────────────────────────
if showTable and barstate.islast
    if not na(_tbl)
        _tbl.delete()

    // Rows: 0 = coverage info, 1 = spacer/header W/L, 2 subhead, 3-6 W/L rows,
    //       7 = header retests, 8 subhead, 9-11 count rows,
    //       12 = header timing, 13 subhead, 14-16 timing rows,
    //       17 = header hourly, 18 subhead, 19-25 hourly rows  → 26 rows total
    _tbl := table.new(f_pos(), 3, 26,
         bgcolor      = color.new(color.black, 0),
         border_width = 1,
         border_color = color.new(color.gray, 50),
         frame_width  = 1,
         frame_color  = color.new(color.gray, 50))

    // ── Row 0: Coverage info ──────────────────────────────────────────────
    string cov_txt = ' SESSIONS: ' + str.tostring(stat_total) + ' days  |  max tracked: ' + str.tostring(maxDays)
    table.cell(_tbl, 0, 0, cov_txt, text_color = color.yellow, text_size = f_size(), bgcolor = color.new(color.black, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.merge_cells(_tbl, 0, 0, 2, 0)

    // ── Section 1: Win/Loss Stats ─────────────────────────────────────────
    f_header(1, ' WIN / LOSS')
    f_subhead(2, 'METRIC', 'VALUE', 'DETAIL')

    string today_pos = today_rth_active ? (today_rth_above ? 'RTH ABOVE' : 'RTH BELOW') : 'AWAITING'
    string today_dir = today_rth_active ? (today_bull      ? 'BULL'      : 'BEAR')      : '-'
    f_row(3, 'TODAY', today_pos, today_dir)

    float  wr     = stat_total > 0 ? (stat_wins / stat_total) * 100 : 0.0
    f_row(4, 'WIN RATE', f_round2(wr) + '%', str.tostring(stat_wins) + '/' + str.tostring(stat_total) + ' days')
    f_row(5, 'BULL/BEAR', str.tostring(stat_bullish) + 'B / ' + str.tostring(stat_bearish) + 'b', 'confirmed')

    string sk_dir = stat_streak_win ? 'WIN' : 'LOSS'
    f_row(6, 'STREAK', sk_dir, str.tostring(stat_streak) + (stat_streak == 1 ? ' day' : ' days'))

    // ── Section 2: Retests & Crossovers (counts) ──────────────────────────
    f_header(7, ' RETESTS & CROSSOVERS')
    f_subhead(8, 'METRIC', 'MEAN/DAY', 'MED/DAY')
    f_row(9,  'RTH RETEST',  na(rth_ret_mean)  ? 'n/a' : f_round2(rth_ret_mean),  na(rth_ret_med)  ? 'n/a' : f_round2(rth_ret_med))
    f_row(10, 'SESS RETEST', na(sess_ret_mean) ? 'n/a' : f_round2(sess_ret_mean), na(sess_ret_med) ? 'n/a' : f_round2(sess_ret_med))
    f_row(11, 'CROSSOVERS',  na(cross_mean)    ? 'n/a' : f_round2(cross_mean),    na(cross_med)    ? 'n/a' : f_round2(cross_med))

    // ── Section 3: Event Timing ───────────────────────────────────────────
    f_header(12, ' EVENT TIMING (EST)')
    f_subhead(13, 'EVENT', 'AVG TIME', 'MED / PEAK HR')
    f_row(14, 'RTH RETEST',
         na(rth_ret_time_mean) ? 'n/a' : f_hhmm(rth_ret_time_mean),
         (na(rth_ret_time_med) ? 'n/a' : f_hhmm(rth_ret_time_med)) + ' / ' + f_bucket_label(pk_rth_ret) + 'h')
    f_row(15, 'SESS RETEST',
         na(sess_ret_time_mean) ? 'n/a' : f_hhmm(sess_ret_time_mean),
         (na(sess_ret_time_med) ? 'n/a' : f_hhmm(sess_ret_time_med)) + ' / ' + f_bucket_label(pk_sess_ret) + 'h')
    f_row(16, 'CROSSOVER',
         na(cross_time_mean) ? 'n/a' : f_hhmm(cross_time_mean),
         (na(cross_time_med) ? 'n/a' : f_hhmm(cross_time_med)) + ' / ' + f_bucket_label(pk_cross) + 'h')

    // ── Section 4: Hourly Breakdown ───────────────────────────────────────
    f_header(17, ' HOURLY EVENT COUNT')
    f_subhead(18, 'HOUR', 'RTH RET', 'SESS RET / CROSS')
    for i = 0 to 6
        f_row(19 + i,
             f_bucket_label(i) + ':00',
             str.tostring(bucket_rth_ret.get(i)),
             str.tostring(bucket_sess_ret.get(i)) + ' / ' + str.tostring(bucket_cross.get(i)))

// ─── Band Plots ───────────────────────────────────────────────────────────────
plot(showAnchor ? band_anchor : na, title = 'Anchor (midpoint)',  color = anchorCol, linewidth = 1, style = plot.style_linebr)

plot(b_1s_hi,   title = '+1σ',            color = col1s,    linewidth = 1, style = plot.style_linebr)
plot(b_1s_lo,   title = '-1σ',            color = col1s,    linewidth = 1, style = plot.style_linebr)
plot(b_2s_hi,   title = '+2σ',            color = col2s,    linewidth = 1, style = plot.style_linebr)
plot(b_2s_lo,   title = '-2σ',            color = col2s,    linewidth = 1, style = plot.style_linebr)

plot(b_asym_hi, title = 'Asym σ upper',   color = colAsymHi, linewidth = 1, style = plot.style_linebr)
plot(b_asym_lo, title = 'Asym σ lower',   color = colAsymLo, linewidth = 1, style = plot.style_linebr)

plot(b_mad_hi,  title = 'MAD upper',      color = colMAD,   linewidth = 1, style = plot.style_linebr)
plot(b_mad_lo,  title = 'MAD lower',      color = colMAD,   linewidth = 1, style = plot.style_linebr)

plot(b_pct90,   title = '90th pct',       color = colPct90, linewidth = 1, style = plot.style_linebr)
plot(b_pct75,   title = '75th pct',       color = colPct75, linewidth = 1, style = plot.style_linebr)
plot(b_pct25,   title = '25th pct',       color = colPct25, linewidth = 1, style = plot.style_linebr)
plot(b_pct10,   title = '10th pct',       color = colPct10, linewidth = 1, style = plot.style_linebr)

plot(b_vwd,     title = 'VWAP of devs',   color = colVWD,   linewidth = 1, style = plot.style_linebr)

// ─── Plots ────────────────────────────────────────────────────────────────────
bgcolor(not na(session) and highlight ? hCol : na)
plot(showRTH and rth_session ? rth_vwap : na, title = "RTH VWAP", color = rthCol, linewidth = rthW, style = plot.style_linebr)
````
