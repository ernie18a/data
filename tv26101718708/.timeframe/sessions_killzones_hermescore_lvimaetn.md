# Sessions + Killzones [HermesCore]

- url: https://www.tradingview.com/script/lViMaetn-Sessions-Killzones-HermesCore/
- type: indicator
- pine_id: PUB;09d92d74e5fc456da11951a98de66cc2
- version: 1.0

## Description

[b]WHAT THIS INDICATOR DOES[/b]

[i]Sessions + Killzones [/i] tracks the three desk sessions: Asia, London and New York, plus an optional custom window. While a session is open you see it as a live box. When it closes, its high and low become levels. Each level gets a simple 0 to 6 quality score, and from then on the script tracks what price does with it: swept, run, or held.

Every outcome feeds a statistics engine. It answers the core question of this script: what does the next session usually do with the levels of the previous one? Measured on your own chart, with sample sizes shown.

Killzones are the windows where institutional activity concentrates, around the desk opens. They render as background shading, set in New York time per ICT convention (Inner Circle Trader, the school this session vocabulary comes from). The dashboard shows which session and which killzone are active right now, each with a countdown. It also covers the daily window where nothing is open. I gave that window a name: the Dead Zone.

[b]WHY IT IS DIFFERENT[/b]

Most session indicators draw boxes and stop. The few that score sessions usually hide how the score works. My rules are:

- A level gets its score at birth and the score never changes. It is built only from facts about how the session formed: range, volume, how clean the extreme was, and confluence with key levels. What happens later is shown by the lifecycle markings, not by changing the score.
- A sweep and a run are two different events. A wick beyond the level that closes back inside is a sweep. That is information: stops were taken and price came back. A close beyond the level plus a 0.1 ATR buffer (Average True Range, a standard volatility measure) is a run. The level is consumed.
- The statistics are counted honestly. A pair like "AS.H in LDN" only counts what happens while London is actually open. Levels that die before their judging session opens are not counted at all. The dashboard shows the n for every pair, so you always see how much evidence sits behind a percentage.
- Sessions are boxes, because their range matters: it becomes levels. Killzones are background shading, because only their timing matters. Two layers, two visual languages.
- Everything updates on confirmed bars only. No intrabar flicker. No levels that appear and disappear within the same candle.

[b]HOW TO READ THE CHART[/b]

- Live session box: bright, thick border, session tag in the corner. Closed boxes fade into quiet history.
- Session levels: horizontal lines starting at the bar that set the extreme. A label like "LDN.H A S:5" reads: London session high, grade A, score 5. The abbreviations: AS is Asia, LDN is London, NY is New York, .H is the high, .L is the low.
- Gold color with a soft glow and larger text: the grade is A or S. Those are the premium sessions.
- Thick border on a level: it was swept. The label gets a "swept" suffix.
- Grey line without text: the level was run. It stays as quiet history, or you can have runs deleted.
- Levels expire when the next session of the same type closes. Yesterday's Asia high stops mattering once today's Asia delivers a fresh one.
- Killzone shading: vertical background bands for Asia, London, NY AM, and optionally London Close. All set in New York time.
- Dotted horizontal line: the midnight open at 00:00 New York.
- Dotted vertical lines to the right of price: the projected next open of each session, in session color. The chart version of the dashboard countdown. They respect the Weekdays Only filter.
- Neutral horizontal lines: previous day high and low (PDH, PDL) and previous week high and low (PWH, PWL), always from the last completed day and week. When a daily and a weekly level are equal they merge into one line with a combined label.
- Session midlines (CE, consequent encroachment, simply the middle of the range): dotted at the middle of each closed session, turning solid gold with a label like "AS CE" on the first touch. On by default.
- Killzone range lines: when a killzone closes, its high and low freeze as dashed lines in the killzone color. They carry no score, no lifecycle and no statistics. They are pure context and expire when the next killzone of the same type closes. On by default.

[b]THE SCORE[/b]

Every component is measured at session close against the average of the last 20 sessions of the same type. Asia is always compared with Asia, London with London.

- Range: the session range is more than 1.2x its own average, +2
- Volume: the session volume is above its own average, +2
- Clean extreme: the high or low was set in the first half of the session and never revisited within 0.1 ATR, +1
- Key confluence: the level lies within 0.25 ATR of PDH, PDL, PWH or PWL, +1

Grades: S (6), A (5), B (4), C (3), D (0 to 2). There is no strength filter on purpose. A day produces at most six levels, which is scarce enough to show them all and let the grade speak.

[b]SEQUENCE STATISTICS[/b]

Six pairs, following the natural hand-off: Asia levels are judged by London, London levels by New York, New York levels by the next Asia. For each pair the dashboard shows the swept share, run share, held share, and n, the number of judged levels behind those percentages. Held means the judging session closed without resolving the level. The optional custom session gets the full level lifecycle but stays out of these statistics.

This is regime information. If "AS.H in LDN" shows 36 percent swept while the lifetime base is 45, London is currently respecting Asia highs more than usual. An alert can warn you when a pair crosses 70 percent swept.

[b]THE DEAD ZONE[/b]

Between the New York close and the Asia open, nothing is open. I named that window the Dead Zone, and it does real work here. Liquidity is thinnest there. A New York level that gets run inside the Dead Zone disappears before Asia ever gets to judge it. That is why the New York pairs always show a smaller n: n only counts levels that survived until their judging session opened. The dashboard names the Dead Zone when you are in it and counts down to the next open. Neutral shading, on by default, makes it visible on the chart. It is defined as "no session live", so it stays correct through every daylight saving (DST) change, and with Weekdays Only on, the whole weekend becomes one long Dead Zone.

[b]DASHBOARD[/b]

Session now with a closing countdown, or Dead Zone with an opening countdown. Range and volume of each session against its own average, live sessions marked. The six pairs with percentages and n. Active level count, the lifetime swept versus run ratio, and Killzone now with its own countdown. Heat bars are proportional everywhere.

[b]HOW I USE IT[/b]

My preferred timeframes, in order:

- 15m is the home base. Sessions are 30 plus bars wide, so the clean extreme component means something. The 09:30 New York open lands exactly on a bar. And the chart loads the most history, which gives the statistics their highest n.
- 5m is the execution frame. Sweeps and runs resolve on bar closes, so 5m shows the fight around a level in finer detail, and killzones become readable blocks. The cost is sample size: the statistics run on roughly a third of the history, so I treat those percentages as indicative and keep the regime read on 15m.
- 1h works but is the edge case. Hourly bars cut off the 09:30 New York open, and a six bar session makes the score coarse. Above 1h the script draws nothing on purpose.

On 15m I read the dashboard first: which session is live, how its range compares with average, and what the pair stats say about the current regime. Levels graded A or S from a session that expanded on volume are the ones I treat as real liquidity references, especially with key confluence. Then I watch how the next session treats them. A sweep, thick border, stops taken and price rejected, is a different trade than a clean run. I drop to 5m for execution around those levels and during killzones. I do not use this above 1h, and the script will tell you the same.

The way I think about it: session highs and lows are liquidity pools with a clock attached. Equal highs can form anywhere, but a session extreme tells you which desk made the level, when it stops being defended, and, through the statistics, what usually happens to it next.

[b]SETTINGS THAT MATTER[/b]

- Sessions: four windows, each with its own IANA timezone (Asia/Tokyo, Europe/London, America/New_York by default). These are real timezone names, not UTC offsets, so daylight saving is handled automatically. The sessions simply follow their local clocks.
- Weekdays Only: off by default. Crypto trades the weekend, and weekend sessions usually grade D by themselves on thin range and volume. Turn this on and everything restricts to Monday through Friday: the weekend becomes one long Dead Zone, Friday New York levels wait for Monday Asia, and the countdown switches to a days format.
- Max Session Boxes: 42 keeps two weeks of session history for a zoomed-out view, 6 keeps two days for intraday focus.
- Run Levels Become: greyed history or deleted. Your choice of how loud the past is.
- Focus Fade: levels more than 6 ATR away from price render dimmed, gold glow included, so your eye goes to what is in play.
- Killzones: four windows in New York time, each with its own color. London Close is off by default. Killzone Range Lines adds the frozen high and low of each completed killzone as dashed lines.
- Timeframe guard: above 60 minutes the script draws nothing and says why. This is an intraday tool, and pretending otherwise would only produce misleading levels.

[b]ALERTS[/b]

Session Opened, Session Closed, New A/S Session Level, Session Level Swept, Session Level Run, Killzone Started, Session Midline Tapped, Sweep Rate Threshold (a pair crossing 70 percent swept with n of at least 10).

[b]CALCULATION DETAILS[/b]

- All state changes happen on confirmed bars. Sweeps, runs and statistics never repaint within a bar.
- Sessions use Pine session strings with full IANA timezone support. Without a day filter, Pine fires sessions on all seven days. That is correct for 24/7 markets, and it is what the Weekdays Only toggle changes.
- The rolling averages for range and volume use the last 20 completed sessions of the same type, calculated before the current session is added. A session is never compared with itself.
- A sweep needs a wick beyond the level with the close back inside the 0.1 ATR buffer. A run needs a close beyond the level plus the buffer. A first sweep marks the level, a later run still resolves it.
- Outcomes are only recorded while the judging session is open. A level that survives its judge counts as held at the judge's close.
- The statistics are computed from the bars your chart loads. They reload per chart timeframe. 15m loads the most history and gives the highest n. On 5m the same engine runs on roughly a third of the sample, treat those percentages as indicative.

[b]HONEST LIMITATIONS[/b]

- The statistics describe the past, they do not predict. They tell you what this chart did over the loaded history, not what it will do next.
- n differs per pair by design. Levels run inside the Dead Zone leave the population before their judging session opens, which is why the New York pairs carry a smaller n. That is honest counting, not a bug.
- Statistics depend on the chart timeframe and the loaded history, so two timeframes show different percentages. Neither is wrong, they measure different samples.
- With Weekdays Only off, weekend sessions are part of the statistics. With it on, both n and the percentages change, because you measure a different market. Neither setting is the truth, they answer different questions.
- Scores compare a session with its own rolling history, so the first 20 sessions of each type on a fresh chart carry less reliable scores while the averages fill up.
- On 1h charts bar alignment can cut off session opens (there is no 09:30 bar on an hourly chart). That is part of why the timeframe guard sits at 60 minutes.

[b]ORIGINALITY[/b]

The session and killzone concepts come from the public ICT vocabulary and from years of session-based intraday trading. Every line of code, the scoring system, the sweep versus run grammar, the judged-while-open statistics engine, the Dead Zone concept and the visual language are my own work.

Questions and suggestions are welcome in the comments. If the stats surprise you on your market, that is usually the most interesting place to start reading.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) HermesCore
//@version=6
indicator("Sessions + Killzones [HermesCore]", "SES-HC", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// The fifth pillar: the companion scripts answer WHERE, this one answers WHEN.
// Session highs and lows are liquidity pools with a clock: at session close
// they graduate to levels with the full sweep versus run lifecycle, and the
// engine counts its own resolved outcomes per session pair (Asia judged by
// London, London by New York, New York by the next Asia). Every statistic is
// a frequency over deterministic lifecycle events with the sample size shown.

// Inputs
group_main = "01 Main"
tfLimit = input.timeframe("60", "Timeframe Limit", group=group_main, tooltip="Session logic is designed for intraday charts. Above this timeframe the script draws nothing and shows a quiet note instead.")
extendBars = input.int(40, "Level Extension", minval=5, maxval=300, group=group_main)
maxLevels = input.int(24, "Max Active Levels", minval=4, maxval=100, group=group_main)
maxSesBoxes = input.int(42, "Max Session Boxes", minval=2, maxval=60, group=group_main, tooltip="How many session boxes stay on the chart. 3 per day: 6 keeps two days for intraday focus, 42 keeps two weeks for a zoomed-out regime view.")
weekdaysOnly = input.bool(false, "Weekdays Only (Mon-Fri)", group=group_main, tooltip="Pine sessions fire on all seven days, so on 24/7 markets Saturday and Sunday get full sessions, levels and stats. Weekend sessions are thin and usually grade D on their own. Turn this on to restrict everything to Monday-Friday: the weekend becomes one long Dead Zone, Friday New York levels wait for Monday Asia to be judged, and levels run during the weekend leave the population.")
showSesBoxes = input.bool(true, "Show Session Boxes", group=group_main)
showKeyLevels = input.bool(true, "Show Key Levels (PDH/PDL/PWH/PWL)", group=group_main, tooltip="Previous completed day and week high/low, drawn at the right edge and used for the confluence score component.")

group_ses = "02 Sessions"
asOn = input.bool(true, "Asia", inline="as", group=group_ses)
asSes = input.session("0900-1800", "", inline="as", group=group_ses)
asTz = input.string("Asia/Tokyo", "", inline="as", group=group_ses, tooltip="Session window in its home IANA timezone. Daylight saving is handled by the platform, not by a manual toggle.")
ldOn = input.bool(true, "London", inline="ld", group=group_ses)
ldSes = input.session("0800-1630", "", inline="ld", group=group_ses)
ldTz = input.string("Europe/London", "", inline="ld", group=group_ses)
nyOn = input.bool(true, "New York", inline="ny", group=group_ses)
nySes = input.session("0930-1600", "", inline="ny", group=group_ses)
nyTz = input.string("America/New_York", "", inline="ny", group=group_ses)
cuOn = input.bool(false, "Custom", inline="cu", group=group_ses)
cuSes = input.session("0000-0600", "", inline="cu", group=group_ses)
cuTz = input.string("Etc/UTC", "", inline="cu", group=group_ses, tooltip="A fourth session slot. Excluded from the sequence statistics, its levels still get the full lifecycle.")

group_kz = "03 Killzones"
showKZ = input.bool(true, "Show Killzone Shading", group=group_kz, tooltip="ICT killzones as background shading, defined in America/New_York so daylight saving never shifts them. Pure context: no logic depends on them.")
kzAsOn = input.bool(true, "Asia KZ", inline="k1", group=group_kz)
kzAsSes = input.session("2000-0000", "", inline="k1", group=group_kz)
kzAsCol = input.color(color.new(color.blue, 88), "", inline="k1", group=group_kz)
kzLdOn = input.bool(true, "London KZ", inline="k2", group=group_kz)
kzLdSes = input.session("0200-0500", "", inline="k2", group=group_kz)
kzLdCol = input.color(color.new(color.red, 88), "", inline="k2", group=group_kz)
kzNaOn = input.bool(true, "NY AM KZ", inline="k3", group=group_kz)
kzNaSes = input.session("0830-1100", "", inline="k3", group=group_kz)
kzNaCol = input.color(color.new(color.teal, 88), "", inline="k3", group=group_kz)
kzLcOn = input.bool(false, "London Close KZ", inline="k4", group=group_kz)
kzLcSes = input.session("1000-1200", "", inline="k4", group=group_kz)
kzLcCol = input.color(color.new(color.orange, 88), "", inline="k4", group=group_kz)
showKzLevels = input.bool(true, "Killzone Range Lines", group=group_kz, tooltip="At each killzone close its high and low freeze as dashed reference lines in the killzone color. Deliberately scoped: no score, no sweep or run lifecycle, no participation in the statistics. They expire when the next killzone of the same type closes. Session levels keep the full lifecycle, these are pure context.")

group_logic = "04 Logic"
runBufMult = input.float(0.1, "Run Break Buffer (ATR mult)", minval=0.0, maxval=1.0, step=0.05, group=group_logic, tooltip="Run requires a close beyond the level plus this buffer, the same buffer Strict Market Structure uses. A wick beyond with the close still inside the buffer is a SWEEP, not a run. This resolves the hair-breach edge case deterministically.")
keyTol = input.float(0.25, "Key Level Tolerance (ATR mult)", minval=0.05, maxval=2.0, step=0.05, group=group_logic)
statLen = input.int(20, "Same-Type Stat Window (sessions)", minval=3, maxval=100, group=group_logic, tooltip="Range and volume are judged against the rolling average of the SAME session type: Asia against Asia, London against London.")
runMode = input.string("Greyed History", "Run Levels Become", options=["Greyed History", "Deleted"], group=group_logic)
maxLevelAge = input.int(600, "Max Level Age (bars)", minval=50, maxval=5000, group=group_logic)
showMidline = input.bool(true, "Session Midline (CE)", group=group_logic, tooltip="Dotted line at the midpoint of the closed session range, turning solid gold on first tap. The same CE grammar as the companion FVG script.")

group_score = "05 Strength Score"
atrLen = input.int(14, "ATR Length", minval=1, group=group_score)
useRangeScore = input.bool(true, "Use Range Expansion", group=group_score)
useVolScore = input.bool(true, "Use Participation (Volume)", group=group_score)
useCleanScore = input.bool(true, "Use Clean Extreme", group=group_score)
useKeyScore = input.bool(true, "Use Key Level Confluence", group=group_score)

group_visual = "06 Visuals"
showLabels = input.bool(true, "Show Level Labels", group=group_visual)
showDashboard = input.bool(true, "Show Dashboard", group=group_visual)
showGlow = input.bool(true, "Show Premium Glow (A/S levels)", group=group_visual)
showDeadZone = input.bool(true, "Shade Dead Zone", group=group_visual, tooltip="Shades the daily window where no session is open, between the New York close and the Asia open. Liquidity is thinnest here and New York levels that get run in this window leave the population before Asia can judge them.")
showFocusFade = input.bool(true, "Focus Fade", group=group_visual, tooltip="Levels farther than 6 ATR from current price render dimmed, so attention goes to what is in play. Pure styling, the logic is untouched.")
showMidnightOpen = input.bool(true, "Show Midnight Open (00:00 NY)", group=group_visual)
showSesOpens = input.bool(true, "Show Session Open Lines", group=group_visual)
showNextOpens = input.bool(true, "Show Next Session Opens", group=group_visual, tooltip="Dotted vertical at the projected next open of each enabled session, in session color. The chart version of the dashboard countdown: it shows where the next hand-off lands. Respects Weekdays Only and skips opens more than 480 bars ahead.")
labelSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=group_visual, tooltip="Size of all labels and the dashboard. A or S graded levels render one size larger.")

group_colors = "07 Colors"
bullColor = input.color(color.rgb(0, 220, 170), "Low Level Color", group=group_colors)
bearColor = input.color(color.rgb(255, 70, 110), "High Level Color", group=group_colors)
goldColor = input.color(color.rgb(245, 190, 80), "High Score Color", group=group_colors)
neutralColor = input.color(color.rgb(190, 190, 190), "Neutral Color", group=group_colors)
asColor = input.color(color.rgb(80, 140, 255), "Asia", inline="sc", group=group_colors)
ldColor = input.color(color.rgb(230, 90, 90), "London", inline="sc", group=group_colors)
nyColor = input.color(color.rgb(60, 200, 160), "New York", inline="sc", group=group_colors)
cuColor = input.color(color.rgb(180, 140, 220), "Custom", inline="sc", group=group_colors)

// Series (global so ta.* state updates every bar)
atrSeries = ta.atr(atrLen)

// Previous COMPLETED day and week: standard non-repainting pattern
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

// Timeframe guard: an intraday tool by definition
bool tfOK = timeframe.in_seconds() <= timeframe.in_seconds(tfLimit)

// Weekday filter: Pine session strings default to all seven days (1234567),
// so on 24/7 markets sessions also fire on Saturday and Sunday. Weekdays Only
// appends :23456 unless a string already carries its own day filter.
string daySfx = weekdaysOnly ? ":23456" : ""
string asSesX = na(str.pos(asSes, ":")) ? asSes + daySfx : asSes
string ldSesX = na(str.pos(ldSes, ":")) ? ldSes + daySfx : ldSes
string nySesX = na(str.pos(nySes, ":")) ? nySes + daySfx : nySes
string cuSesX = na(str.pos(cuSes, ":")) ? cuSes + daySfx : cuSes
string kzAsSesX = na(str.pos(kzAsSes, ":")) ? kzAsSes + daySfx : kzAsSes
string kzLdSesX = na(str.pos(kzLdSes, ":")) ? kzLdSes + daySfx : kzLdSes
string kzNaSesX = na(str.pos(kzNaSes, ":")) ? kzNaSes + daySfx : kzNaSes
string kzLcSesX = na(str.pos(kzLcSes, ":")) ? kzLcSes + daySfx : kzLcSes

// Session membership, computed at global scope (time() needs simple strings)
bool inAS = tfOK and asOn and not na(time(timeframe.period, asSesX, asTz))
bool inLD = tfOK and ldOn and not na(time(timeframe.period, ldSesX, ldTz))
bool inNY = tfOK and nyOn and not na(time(timeframe.period, nySesX, nyTz))
bool inCU = tfOK and cuOn and not na(time(timeframe.period, cuSesX, cuTz))

// Killzones, all defined in New York time per ICT convention
bool kzAsRaw = tfOK and kzAsOn and not na(time(timeframe.period, kzAsSesX, "America/New_York"))
bool kzLdRaw = tfOK and kzLdOn and not na(time(timeframe.period, kzLdSesX, "America/New_York"))
bool kzNaRaw = tfOK and kzNaOn and not na(time(timeframe.period, kzNaSesX, "America/New_York"))
bool kzLcRaw = tfOK and kzLcOn and not na(time(timeframe.period, kzLcSesX, "America/New_York"))
bool inKzAs = showKZ and kzAsRaw
bool inKzLd = showKZ and kzLdRaw
bool inKzNa = showKZ and kzNaRaw
bool inKzLc = showKZ and kzLcRaw

bgcolor(inKzAs ? kzAsCol : na, title="Asia Killzone")
bgcolor(inKzLd ? kzLdCol : na, title="London Killzone")
bgcolor(inKzNa ? kzNaCol : na, title="NY AM Killzone")
bgcolor(inKzLc ? kzLcCol : na, title="London Close Killzone")
bgcolor(showDeadZone and tfOK and not (inAS or inLD or inNY or inCU) ? color.new(neutralColor, 91) : na, title="Dead Zone")

bool kzStarted = (kzAsRaw and not kzAsRaw[1]) or (kzLdRaw and not kzLdRaw[1]) or (kzNaRaw and not kzNaRaw[1]) or (kzLcRaw and not kzLcRaw[1])

// Midnight open (00:00 New York): one line for the current day
bool midnightTick = tfOK and showMidnightOpen and not na(time(timeframe.period, "0000-0001", "America/New_York"))

// Per-session live state, index 0=Asia 1=London 2=NY 3=Custom.
// All state mutations on confirmed bars only: no intrabar flicker.
var float[] sHigh = array.new_float(4, na)
var float[] sLow = array.new_float(4, na)
var int[] sHighBar = array.new_int(4, 0)
var int[] sLowBar = array.new_int(4, 0)
var int[] sStartBar = array.new_int(4, 0)
var int[] sBars = array.new_int(4, 0)
var float[] sVol = array.new_float(4, 0.0)
var bool[] sPrevIn = array.new_bool(4, false)
var bool[] sRevH = array.new_bool(4, false)
var bool[] sRevL = array.new_bool(4, false)
var float[] sOpenPx = array.new_float(4, na)
var box[] sLiveBox = array.new_box(4, na)
var line[] sOpenLn = array.new_line(4, na)

// Same-type rolling history: range and volume per session type
var float[] rngH0 = array.new_float()
var float[] rngH1 = array.new_float()
var float[] rngH2 = array.new_float()
var float[] rngH3 = array.new_float()
var float[] volH0 = array.new_float()
var float[] volH1 = array.new_float()
var float[] volH2 = array.new_float()
var float[] volH3 = array.new_float()

// Closed session boxes (visual history, capped)
var box[] sesBoxes = array.new_box()

// Levels: parallel arrays, always kept in sync
var box[] levBox = array.new_box()
var box[] levGlow = array.new_box()
var float[] levPrice = array.new_float()
var bool[] levIsHigh = array.new_bool()
var int[] levSes = array.new_int()
var int[] levScore = array.new_int()
var bool[] levSwept = array.new_bool()
var bool[] levJudged = array.new_bool()
var int[] levBirth = array.new_int()

// Session midlines (CE)
var line[] midLn = array.new_line()
var float[] midPrice = array.new_float()
var int[] midSes = array.new_int()
var bool[] midTouched = array.new_bool()
var int[] midBirth = array.new_int()
var label[] midLb = array.new_label()

// Sequence statistics: pair k = srcSession*2 + (isHigh ? 0 : 1), src 0..2.
// k0 AS.H in LDN, k1 AS.L in LDN, k2 LDN.H in NY, k3 LDN.L in NY,
// k4 NY.H in AS, k5 NY.L in AS. Lifetime counters, n always shown.
var int[] seqSwept = array.new_int(6, 0)
var int[] seqRun = array.new_int(6, 0)
var int[] seqHeld = array.new_int(6, 0)
var float[] seqPrevShare = array.new_float(6, na)

// Lifetime totals: 0 levels created, 1 swept, 2 run, 3 held
var int[] tot = array.new_int(4, 0)

// Most recently opened session, for the dashboard current row
var int[] curOpenA = array.new_int(1, -1)

// Midnight open drawing refs
var line[] mnLn = array.new_line(1, na)
var label[] mnLb = array.new_label(1, na)

// Per-bar event flags (array so functions can set them)
// 0 sesOpened, 1 sesClosed, 2 newLevelAS, 3 levelSwept, 4 levelRun,
// 5 midTouched, 6 seqThreshold
var bool[] evt = array.new_bool(7, false)
array.fill(evt, false)

// Helpers
f_grade(int score) =>
    score >= 6 ? "S" : score >= 5 ? "A" : score >= 4 ? "B" : score >= 3 ? "C" : "D"

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_size_up(string s) =>
    s == "Tiny" ? size.small : s == "Normal" ? size.large : size.normal

// proportional heat bar for the dashboard: 1..5 blocks of the reference
f_heat(int v, int ref) =>
    str.repeat("█", math.max(1, math.min(5, int(math.ceil(v * 5.0 / math.max(ref, 1))))))

f_ses_name(int s) =>
    s == 0 ? "AS" : s == 1 ? "LDN" : s == 2 ? "NY" : "CST"

f_ses_color(int s) =>
    s == 0 ? asColor : s == 1 ? ldColor : s == 2 ? nyColor : cuColor

f_judge_of(int s) =>
    s == 0 ? 1 : s == 1 ? 2 : s == 2 ? 0 : -1

f_judge_active(int j) =>
    j == 0 ? inAS : j == 1 ? inLD : j == 2 ? inNY : false

f_rng_hist(int s) =>
    s == 0 ? rngH0 : s == 1 ? rngH1 : s == 2 ? rngH2 : rngH3

f_vol_hist(int s) =>
    s == 0 ? volH0 : s == 1 ? volH1 : s == 2 ? volH2 : volH3

f_lev_color(bool isHigh, int score) =>
    score >= 5 ? goldColor : isHigh ? bearColor : bullColor

f_lev_label(int s, bool isHigh, int score, bool swept) =>
    string base = f_ses_name(s) + (isHigh ? ".H " : ".L ")
    showLabels ? base + f_grade(score) + "  S:" + str.tostring(score) + (swept ? "  swept" : "") : ""

// Countdown helper: minutes until the session string's end time in its
// timezone. Sessions crossing midnight handled by the modulo.
f_closes_in(string ses, string tz) =>
    int cpos = str.pos(ses, ":")
    string baseStr = na(cpos) ? ses : str.substring(ses, 0, cpos)
    int dpos = str.pos(baseStr, "-")
    string endStr = str.substring(baseStr, dpos + 1)
    int endMin = int(str.tonumber(str.substring(endStr, 0, 2))) * 60 + int(str.tonumber(str.substring(endStr, 2, 4)))
    int nowMin = hour(timenow, tz) * 60 + minute(timenow, tz)
    int rem = (endMin - nowMin + 1440) % 1440
    str.tostring(int(rem / 60)) + "h " + str.tostring(rem % 60) + "m"

// Countdown helper: minutes until the session string's start time in its
// timezone, for the next-open readout during the dead zone.
f_opens_in(string ses, string tz) =>
    int cpos = str.pos(ses, ":")
    string baseStr = na(cpos) ? ses : str.substring(ses, 0, cpos)
    int dpos = str.pos(baseStr, "-")
    string stStr = str.substring(baseStr, 0, dpos)
    int stMin = int(str.tonumber(str.substring(stStr, 0, 2))) * 60 + int(str.tonumber(str.substring(stStr, 2, 4)))
    int nowMin = hour(timenow, tz) * 60 + minute(timenow, tz)
    int dowNow = dayofweek(timenow, tz)
    int best = -1
    for d = 0 to 7
        int cd = (dowNow - 1 + d) % 7 + 1
        bool dayOK = not weekdaysOnly or (cd >= dayofweek.monday and cd <= dayofweek.friday)
        int cand = d * 1440 + stMin - nowMin
        if best < 0 and dayOK and cand > 0
            best := cand
    best

// Remove a level by index (drawings handled by caller where styling differs)
f_drop_level(int i) =>
    array.remove(levBox, i)
    array.remove(levGlow, i)
    array.remove(levPrice, i)
    array.remove(levIsHigh, i)
    array.remove(levSes, i)
    array.remove(levScore, i)
    array.remove(levSwept, i)
    array.remove(levJudged, i)
    array.remove(levBirth, i)

// Spawn one graduated level, anchored at the bar that set the extreme
f_spawn_level(int s, bool isHigh, float v, int score, int anchorBar) =>
    color c = f_lev_color(isHigh, score)
    box gl = na
    if showGlow and score >= 5
        gl := box.new(anchorBar, v + atrSeries * 0.06, bar_index + extendBars, v - atrSeries * 0.06, bgcolor=color.new(goldColor, 85), border_color=color.new(goldColor, 72))
    box b = box.new(anchorBar, v, bar_index + extendBars, v,
         bgcolor=color.new(c, 75),
         border_color=color.new(c, 0),
         border_width=2,
         text=f_lev_label(s, isHigh, score, false),
         text_color=c,
         text_size=score >= 5 ? f_size_up(labelSize) : f_size(labelSize),
         text_halign=text.align_right)
    array.push(levBox, b)
    array.push(levGlow, gl)
    array.push(levPrice, v)
    array.push(levIsHigh, isHigh)
    array.push(levSes, s)
    array.push(levScore, score)
    array.push(levSwept, false)
    array.push(levJudged, false)
    array.push(levBirth, bar_index)
    array.set(tot, 0, array.get(tot, 0) + 1)
    if score >= 5
        array.set(evt, 2, true)
    if array.size(levBox) > maxLevels
        box.delete(array.get(levBox, 0))
        box.delete(array.get(levGlow, 0))
        f_drop_level(0)

// Sequence stat bookkeeping with the threshold alert (swept share crossing
// 70 percent with at least 10 judged events)
f_seq_count(int k, int kind) =>
    if k >= 0 and k <= 5
        if kind == 0
            array.set(seqSwept, k, array.get(seqSwept, k) + 1)
        else if kind == 1
            array.set(seqRun, k, array.get(seqRun, k) + 1)
        else
            array.set(seqHeld, k, array.get(seqHeld, k) + 1)
        int n = array.get(seqSwept, k) + array.get(seqRun, k) + array.get(seqHeld, k)
        float share = n > 0 ? array.get(seqSwept, k) * 100.0 / n : na
        float prev = array.get(seqPrevShare, k)
        if n >= 10 and not na(prev) and prev < 70 and share >= 70
            array.set(evt, 6, true)
        array.set(seqPrevShare, k, share)

// Session tracking: open, in-session updates, close with graduation.
// Mutates only array contents, so it can live in a function.
f_track(int s, bool inSes, bool enabled) =>
    bool prevIn = array.get(sPrevIn, s)
    color sc = f_ses_color(s)

    // open
    if enabled and inSes and not prevIn
        array.set(sHigh, s, high)
        array.set(sLow, s, low)
        array.set(sHighBar, s, bar_index)
        array.set(sLowBar, s, bar_index)
        array.set(sStartBar, s, bar_index)
        array.set(sBars, s, 1)
        array.set(sVol, s, volume)
        array.set(sRevH, s, false)
        array.set(sRevL, s, false)
        array.set(sOpenPx, s, open)
        array.set(curOpenA, 0, s)
        array.set(evt, 0, true)
        if showSesBoxes
            array.set(sLiveBox, s, box.new(bar_index, high, bar_index, low, bgcolor=color.new(sc, 82), border_color=color.new(sc, 20), border_width=3, text=f_ses_name(s), text_color=color.new(sc, 10), text_size=size.small, text_halign=text.align_left, text_valign=text.align_top))
        if showSesOpens
            array.set(sOpenLn, s, line.new(bar_index, open, bar_index + 1, open, color=color.new(sc, 50), style=line.style_dotted, width=1))

    // in session
    else if enabled and inSes and prevIn
        float h0 = array.get(sHigh, s)
        float l0 = array.get(sLow, s)
        float tol = atrSeries * 0.1
        if high > h0
            array.set(sHigh, s, high)
            array.set(sHighBar, s, bar_index)
            array.set(sRevH, s, false)
        else if high >= h0 - tol
            array.set(sRevH, s, true)
        if low < l0
            array.set(sLow, s, low)
            array.set(sLowBar, s, bar_index)
            array.set(sRevL, s, false)
        else if low <= l0 + tol
            array.set(sRevL, s, true)
        array.set(sBars, s, array.get(sBars, s) + 1)
        array.set(sVol, s, array.get(sVol, s) + volume)
        box lb = array.get(sLiveBox, s)
        if not na(lb)
            box.set_right(lb, bar_index)
            box.set_top(lb, array.get(sHigh, s))
            box.set_bottom(lb, array.get(sLow, s))
        line ol = array.get(sOpenLn, s)
        if not na(ol)
            line.set_x2(ol, bar_index)

    // close: graduate the extremes into levels
    else if enabled and not inSes and prevIn
        array.set(evt, 1, true)
        float hi = array.get(sHigh, s)
        float lo = array.get(sLow, s)
        float rng = hi - lo
        float vol = array.get(sVol, s)
        int bars = array.get(sBars, s)
        int startBar = array.get(sStartBar, s)

        // same-type rolling baselines, computed BEFORE pushing this session
        float[] rh = f_rng_hist(s)
        float[] vh = f_vol_hist(s)
        float avgR = array.size(rh) > 0 ? array.avg(rh) : na
        float avgV = array.size(vh) > 0 ? array.avg(vh) : na
        int basePts = 0
        if useRangeScore and not na(avgR) and rng > 1.2 * avgR
            basePts += 2
        if useVolScore and not na(avgV) and vol > avgV
            basePts += 2
        array.push(rh, rng)
        array.push(vh, vol)
        if array.size(rh) > statLen
            array.shift(rh)
        if array.size(vh) > statLen
            array.shift(vh)

        // held bookkeeping: levels judged by THIS session that survived it
        int j = array.size(levJudged) - 1
        while j >= 0
            if not array.get(levJudged, j) and f_judge_of(array.get(levSes, j)) == s
                array.set(levJudged, j, true)
                array.set(tot, 3, array.get(tot, 3) + 1)
                int src = array.get(levSes, j)
                if src >= 0 and src <= 2
                    f_seq_count(src * 2 + (array.get(levIsHigh, j) ? 0 : 1), 2)
            j -= 1

        // expiry: previous levels of this type retire as the fresh ones arrive
        j := array.size(levSes) - 1
        while j >= 0
            if array.get(levSes, j) == s
                box.delete(array.get(levBox, j))
                box.delete(array.get(levGlow, j))
                f_drop_level(j)
            j -= 1
        j := array.size(midSes) - 1
        while j >= 0
            if array.get(midSes, j) == s
                line.delete(array.get(midLn, j))
                label.delete(array.get(midLb, j))
                array.remove(midLn, j)
                array.remove(midPrice, j)
                array.remove(midSes, j)
                array.remove(midTouched, j)
                array.remove(midBirth, j)
                array.remove(midLb, j)
            j -= 1

        // graduate high and low
        float tolK = atrSeries * keyTol
        bool cleanH = (array.get(sHighBar, s) - startBar) * 2 <= bars and not array.get(sRevH, s)
        bool keyH = math.abs(hi - pdh) <= tolK or math.abs(hi - pwh) <= tolK
        int scoreH = basePts + (useCleanScore and cleanH ? 1 : 0) + (useKeyScore and keyH ? 1 : 0)
        f_spawn_level(s, true, hi, scoreH, array.get(sHighBar, s))

        bool cleanL = (array.get(sLowBar, s) - startBar) * 2 <= bars and not array.get(sRevL, s)
        bool keyL = math.abs(lo - pdl) <= tolK or math.abs(lo - pwl) <= tolK
        int scoreL = basePts + (useCleanScore and cleanL ? 1 : 0) + (useKeyScore and keyL ? 1 : 0)
        f_spawn_level(s, false, lo, scoreL, array.get(sLowBar, s))

        // midline (CE): dotted until tapped, then solid gold, once
        if showMidline
            float mid = math.avg(hi, lo)
            line ml = line.new(startBar, mid, bar_index + extendBars, mid, color=color.new(f_ses_color(s), 20), style=line.style_dotted, width=2)
            array.push(midLn, ml)
            array.push(midPrice, mid)
            array.push(midSes, s)
            array.push(midTouched, false)
            array.push(midBirth, bar_index)
            array.push(midLb, label(na))

        // freeze the session box
        box lb2 = array.get(sLiveBox, s)
        if not na(lb2)
            box.set_right(lb2, bar_index)
            box.set_bgcolor(lb2, color.new(sc, 90))
            box.set_border_color(lb2, color.new(sc, 45))
            box.set_border_width(lb2, 1)
            box.set_text_color(lb2, color.new(sc, 40))
            array.push(sesBoxes, lb2)
            array.set(sLiveBox, s, na)
            if array.size(sesBoxes) > maxSesBoxes
                box.delete(array.shift(sesBoxes))
        line ol2 = array.get(sOpenLn, s)
        if not na(ol2)
            line.delete(ol2)
            array.set(sOpenLn, s, na)

    array.set(sPrevIn, s, enabled and inSes)

// Drive the four sessions on confirmed bars only
if barstate.isconfirmed and tfOK
    f_track(0, inAS, asOn)
    f_track(1, inLD, ldOn)
    f_track(2, inNY, nyOn)
    f_track(3, inCU, cuOn)

// Level lifecycle: RUN = close beyond the level plus the break buffer.
// SWEEP = wick beyond with the close still at or inside the buffer, once.
// Stats count only while the level's judging session is actually open.
if barstate.isconfirmed and tfOK
    float buf = atrSeries * runBufMult
    int i = array.size(levBox) - 1
    while i >= 0
        bool isHigh = array.get(levIsHigh, i)
        float p = array.get(levPrice, i)
        int src = array.get(levSes, i)
        int judge = f_judge_of(src)
        int k = src >= 0 and src <= 2 ? src * 2 + (isHigh ? 0 : 1) : -1
        bool judgeOpen = f_judge_active(judge)
        box b = array.get(levBox, i)

        bool runHit = isHigh ? close > p + buf : close < p - buf
        bool wickBeyond = isHigh ? high > p : low < p

        if bar_index - array.get(levBirth, i) > maxLevelAge
            box.delete(b)
            box.delete(array.get(levGlow, i))
            f_drop_level(i)
        else if runHit
            array.set(evt, 4, true)
            array.set(tot, 2, array.get(tot, 2) + 1)
            if judgeOpen and not array.get(levJudged, i)
                f_seq_count(k, 1)
            box.delete(array.get(levGlow, i))
            if runMode == "Greyed History"
                box.set_bgcolor(b, color.new(neutralColor, 96))
                box.set_border_color(b, color.new(neutralColor, 65))
                box.set_border_width(b, 1)
                box.set_text(b, "")
                box.set_right(b, bar_index)
            else
                box.delete(b)
            f_drop_level(i)
        else
            if wickBeyond and not array.get(levSwept, i)
                array.set(levSwept, i, true)
                array.set(evt, 3, true)
                array.set(tot, 1, array.get(tot, 1) + 1)
                if judgeOpen and not array.get(levJudged, i)
                    array.set(levJudged, i, true)
                    f_seq_count(k, 0)
                box.set_border_width(b, 3)
                box.set_text(b, f_lev_label(src, isHigh, array.get(levScore, i), true))
            box.set_right(b, bar_index + extendBars)
            box gl = array.get(levGlow, i)
            if not na(gl)
                box.set_right(gl, bar_index + extendBars)
        i -= 1

// Midline lifecycle: first tap turns it solid gold, once
if barstate.isconfirmed and tfOK and showMidline
    int i = array.size(midLn) - 1
    while i >= 0
        float m = array.get(midPrice, i)
        line ml = array.get(midLn, i)
        if bar_index - array.get(midBirth, i) > maxLevelAge
            line.delete(ml)
            label.delete(array.get(midLb, i))
            array.remove(midLn, i)
            array.remove(midPrice, i)
            array.remove(midSes, i)
            array.remove(midTouched, i)
            array.remove(midBirth, i)
            array.remove(midLb, i)
        else
            if not array.get(midTouched, i) and low <= m and high >= m
                array.set(midTouched, i, true)
                array.set(evt, 5, true)
                line.set_color(ml, goldColor)
                line.set_style(ml, line.style_solid)
                array.set(midLb, i, label.new(bar_index, m, f_ses_name(array.get(midSes, i)) + " CE", style=label.style_label_left, color=color.new(color.black, 100), textcolor=goldColor, size=f_size(labelSize)))
            line.set_x2(ml, bar_index + extendBars)
        i -= 1

// Midnight open (00:00 New York): one line for the current day
if barstate.isconfirmed and midnightTick and not midnightTick[1]
    line.delete(array.get(mnLn, 0))
    label.delete(array.get(mnLb, 0))
    array.set(mnLn, 0, line.new(bar_index, open, bar_index + 1, open, color=color.new(neutralColor, 25), style=line.style_dotted, width=2))
    array.set(mnLb, 0, label.new(bar_index + 1, open, "00:00 NY", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(neutralColor, 30), size=f_size(labelSize)))
if barstate.isconfirmed and not na(array.get(mnLn, 0))
    line.set_x2(array.get(mnLn, 0), bar_index + 5)
    label.set_x(array.get(mnLb, 0), bar_index + 5)

// Next session opens: dotted verticals projected into the future, the one
// job only a vertical line can do. Reuses the day-aware f_opens_in, so the
// Weekdays Only filter and DST are handled by construction.
var line[] nxLn = array.new_line(4)
var label[] nxLb = array.new_label(4)
if barstate.islast and tfOK
    if na(array.get(nxLn, 0))
        int s0 = 0
        while s0 <= 3
            array.set(nxLn, s0, line.new(bar_index, close, bar_index, close + syminfo.mintick, extend=extend.both, color=color.new(color.black, 100), style=line.style_dotted, width=2))
            array.set(nxLb, s0, label.new(bar_index, close, "", style=label.style_none, textcolor=color.new(color.black, 100), size=f_size(labelSize)))
            s0 += 1
    int tfMin = math.max(1, int(timeframe.in_seconds() / 60))
    int s1 = 0
    while s1 <= 3
        line nl = array.get(nxLn, s1)
        label nb = array.get(nxLb, s1)
        bool on = showNextOpens and (s1 == 0 ? asOn : s1 == 1 ? ldOn : s1 == 2 ? nyOn : cuOn)
        int mins = on ? f_opens_in(s1 == 0 ? asSes : s1 == 1 ? ldSes : s1 == 2 ? nySes : cuSes, s1 == 0 ? asTz : s1 == 1 ? ldTz : s1 == 2 ? nyTz : cuTz) : -1
        int bAhead = mins > 0 ? int(math.ceil(mins * 1.0 / tfMin)) : -1
        if on and bAhead > 0 and bAhead <= 480
            int nx = bar_index + bAhead
            line.set_xy1(nl, nx, close)
            line.set_xy2(nl, nx, close + syminfo.mintick)
            line.set_color(nl, color.new(f_ses_color(s1), 30))
            label.set_xy(nb, nx, close)
            label.set_text(nb, f_ses_name(s1) + " opens")
            label.set_textcolor(nb, color.new(f_ses_color(s1), 15))
        else
            line.set_color(nl, color.new(color.black, 100))
            label.set_text(nb, "")
        s1 += 1

// Killzone range lines: high and low freeze at killzone close as dashed
// reference lines. No score, no lifecycle, no stats: sessions keep that
// monopoly. Previous same-type lines expire at the next close.
var float[] kzH = array.new_float(4, na)
var float[] kzL = array.new_float(4, na)
var int[] kzStartB = array.new_int(4, 0)
var bool[] kzPrev = array.new_bool(4, false)
var line[] kzHL = array.new_line(4)
var line[] kzLL = array.new_line(4)
var label[] kzHLb = array.new_label(4)
var label[] kzLLb = array.new_label(4)

f_kz_name(int k) =>
    k == 0 ? "Asia KZ" : k == 1 ? "London KZ" : k == 2 ? "NY AM KZ" : "LDN Close KZ"

f_kz_col(int k) =>
    k == 0 ? kzAsCol : k == 1 ? kzLdCol : k == 2 ? kzNaCol : kzLcCol

f_kz_track(int k, bool inK) =>
    bool prev = array.get(kzPrev, k)
    if inK and not prev
        array.set(kzH, k, high)
        array.set(kzL, k, low)
        array.set(kzStartB, k, bar_index)
    else if inK and prev
        array.set(kzH, k, math.max(array.get(kzH, k), high))
        array.set(kzL, k, math.min(array.get(kzL, k), low))
    else if not inK and prev and showKzLevels
        line.delete(array.get(kzHL, k))
        line.delete(array.get(kzLL, k))
        label.delete(array.get(kzHLb, k))
        label.delete(array.get(kzLLb, k))
        color kc = color.new(f_kz_col(k), 25)
        int kx = array.get(kzStartB, k)
        float kh = array.get(kzH, k)
        float kl = array.get(kzL, k)
        array.set(kzHL, k, line.new(kx, kh, bar_index + extendBars, kh, color=kc, style=line.style_dashed, width=1))
        array.set(kzLL, k, line.new(kx, kl, bar_index + extendBars, kl, color=kc, style=line.style_dashed, width=1))
        array.set(kzHLb, k, label.new(bar_index + extendBars, kh, f_kz_name(k) + " H", style=label.style_none, textcolor=kc, size=f_size(labelSize)))
        array.set(kzLLb, k, label.new(bar_index + extendBars, kl, f_kz_name(k) + " L", style=label.style_none, textcolor=kc, size=f_size(labelSize)))
    array.set(kzPrev, k, inK)

if barstate.isconfirmed and tfOK
    f_kz_track(0, kzAsRaw)
    f_kz_track(1, kzLdRaw)
    f_kz_track(2, kzNaRaw)
    f_kz_track(3, kzLcRaw)

// Focus Fade: levels in play stay vivid, distant ones recede. Styling only,
// recomputed on the last bar, the lifecycle logic is untouched.
if barstate.islast and tfOK and showFocusFade
    float focusBand = atrSeries * 6
    int f = array.size(levBox) - 1
    while f >= 0
        box pb = array.get(levBox, f)
        bool far = math.abs(close - array.get(levPrice, f)) > focusBand
        color c = f_lev_color(array.get(levIsHigh, f), array.get(levScore, f))
        box.set_border_color(pb, color.new(c, far ? 40 : 0))
        box.set_bgcolor(pb, color.new(c, far ? 90 : 75))
        box.set_text_color(pb, color.new(c, far ? 30 : 0))
        box gl = array.get(levGlow, f)
        if not na(gl)
            box.set_bgcolor(gl, color.new(goldColor, far ? 93 : 85))
            box.set_border_color(gl, color.new(goldColor, far ? 86 : 72))
        f -= 1

// Key levels: previous completed day and week high/low, redrawn on the last
// bar only. PDH/PWH that coincide merge to one line and one combined label.
var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na

if barstate.islast and tfOK
    if na(pwhLine)
        pwhLine := line.new(bar_index, close, bar_index, close, color=color.new(neutralColor, 5), style=line.style_solid, width=3)
        pwlLine := line.new(bar_index, close, bar_index, close, color=color.new(neutralColor, 5), style=line.style_solid, width=3)
        pdhLine := line.new(bar_index, close, bar_index, close, color=color.new(neutralColor, 20), style=line.style_solid, width=2)
        pdlLine := line.new(bar_index, close, bar_index, close, color=color.new(neutralColor, 20), style=line.style_solid, width=2)
        pwhLabel := label.new(bar_index, close, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=neutralColor, size=f_size(labelSize))
        pwlLabel := label.new(bar_index, close, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=neutralColor, size=f_size(labelSize))
        pdhLabel := label.new(bar_index, close, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=neutralColor, size=f_size(labelSize))
        pdlLabel := label.new(bar_index, close, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=neutralColor, size=f_size(labelSize))
    int kx1 = bar_index - 20
    int kx2 = bar_index + extendBars
    bool eqHigh = math.abs(pwh - pdh) <= syminfo.mintick * 0.5
    bool eqLow = math.abs(pwl - pdl) <= syminfo.mintick * 0.5
    line.set_xy1(pwhLine, kx1, pwh)
    line.set_xy2(pwhLine, kx2, pwh)
    line.set_color(pwhLine, color.new(neutralColor, showKeyLevels ? 5 : 100))
    label.set_xy(pwhLabel, kx2, pwh)
    label.set_text(pwhLabel, showKeyLevels ? (eqHigh ? "PWH/PDH" : "PWH") : "")
    line.set_xy1(pwlLine, kx1, pwl)
    line.set_xy2(pwlLine, kx2, pwl)
    line.set_color(pwlLine, color.new(neutralColor, showKeyLevels ? 5 : 100))
    label.set_xy(pwlLabel, kx2, pwl)
    label.set_text(pwlLabel, showKeyLevels ? (eqLow ? "PWL/PDL" : "PWL") : "")
    line.set_xy1(pdhLine, kx1, pdh)
    line.set_xy2(pdhLine, kx2, pdh)
    line.set_color(pdhLine, color.new(neutralColor, showKeyLevels and not eqHigh ? 20 : 100))
    label.set_xy(pdhLabel, kx2, pdh)
    label.set_text(pdhLabel, showKeyLevels and not eqHigh ? "PDH" : "")
    line.set_xy1(pdlLine, kx1, pdl)
    line.set_xy2(pdlLine, kx2, pdl)
    line.set_color(pdlLine, color.new(neutralColor, showKeyLevels and not eqLow ? 20 : 100))
    label.set_xy(pdlLabel, kx2, pdl)
    label.set_text(pdlLabel, showKeyLevels and not eqLow ? "PDL" : "")

// Above the timeframe limit: one quiet note, nothing misleading
var table note = table.new(position.bottom_right, 1, 1, bgcolor=color.new(color.black, 40))
if barstate.islast and not tfOK
    table.cell(note, 0, 0, "SES-HC: session logic is designed for timeframes up to " + tfLimit, text_color=neutralColor, text_size=f_size(labelSize))

// Dashboard
var table dash = table.new(
     position.top_right,
     3,
     14,
     bgcolor=color.new(color.black, 12),
     border_color=color.new(color.gray, 65),
     border_width=1)

f_range_row(int row, int s, bool enabled) =>
    string nm = f_ses_name(s)
    color sc = f_ses_color(s)
    if not enabled
        table.cell(dash, 0, row, nm + " range", text_color=color.new(sc, 50), text_size=f_size(labelSize))
        table.cell(dash, 1, row, "off", text_color=color.new(neutralColor, 50), text_size=f_size(labelSize))
        table.cell(dash, 2, row, "", text_size=f_size(labelSize))
    else
        float[] rh = f_rng_hist(s)
        float avgR = array.size(rh) > 0 ? array.avg(rh) : na
        bool live = s == 0 ? inAS : s == 1 ? inLD : s == 2 ? inNY : inCU
        float cur = live ? array.get(sHigh, s) - array.get(sLow, s) : array.size(rh) > 0 ? array.get(rh, array.size(rh) - 1) : na
        string valTxt = na(cur) ? "warming up" : str.tostring(cur, format.mintick) + (na(avgR) ? "" : " / " + str.tostring(avgR, format.mintick))
        int pct = na(cur) or na(avgR) or avgR == 0 ? 0 : int(math.round(cur * 100.0 / avgR))
        table.cell(dash, 0, row, nm + " range" + (live ? " ●" : ""), text_color=sc, text_size=f_size(labelSize))
        table.cell(dash, 1, row, valTxt, text_color=color.white, text_size=f_size(labelSize))
        table.cell(dash, 2, row, na(avgR) ? "" : f_heat(pct, 100), text_color=pct > 120 ? goldColor : sc, text_size=f_size(labelSize))

f_pair_row(int row, int k, string nameTxt) =>
    int sw = array.get(seqSwept, k)
    int rn = array.get(seqRun, k)
    int hd = array.get(seqHeld, k)
    int n = sw + rn + hd
    string valTxt = n == 0 ? "no data yet" : str.tostring(int(math.round(sw * 100.0 / n))) + "% S  " + str.tostring(int(math.round(rn * 100.0 / n))) + "% R  " + str.tostring(int(math.round(hd * 100.0 / n))) + "% H  (n=" + str.tostring(n) + ")"
    table.cell(dash, 0, row, nameTxt, text_color=color.white, text_size=f_size(labelSize))
    table.cell(dash, 1, row, valTxt, text_color=n == 0 ? color.new(neutralColor, 40) : goldColor, text_size=f_size(labelSize))
    table.cell(dash, 2, row, n == 0 ? "" : f_heat(sw, n), text_color=goldColor, text_size=f_size(labelSize))

if showDashboard and barstate.islast and tfOK
    table.cell(dash, 0, 0, "Sessions + Killzones", text_color=color.white, text_size=f_size_up(labelSize))
    table.cell(dash, 1, 0, "Value", text_color=color.white, text_size=f_size_up(labelSize))
    table.cell(dash, 2, 0, "Heat", text_color=color.white, text_size=f_size_up(labelSize))

    int cs = array.get(curOpenA, 0)
    bool csLive = cs == 0 ? inAS : cs == 1 ? inLD : cs == 2 ? inNY : cs == 3 ? inCU : false
    string csName = cs >= 0 and csLive ? f_ses_name(cs) : "Dead Zone"
    string csCd = ""
    if csLive
        csCd := "closes " + (cs == 0 ? f_closes_in(asSes, asTz) : cs == 1 ? f_closes_in(ldSes, ldTz) : cs == 2 ? f_closes_in(nySes, nyTz) : f_closes_in(cuSes, cuTz))
    else
        int bestMin = 100000
        int bestS = -1
        if asOn
            int mA = f_opens_in(asSes, asTz)
            if mA < bestMin
                bestMin := mA
                bestS := 0
        if ldOn
            int mL = f_opens_in(ldSes, ldTz)
            if mL < bestMin
                bestMin := mL
                bestS := 1
        if nyOn
            int mN = f_opens_in(nySes, nyTz)
            if mN < bestMin
                bestMin := mN
                bestS := 2
        if cuOn
            int mC = f_opens_in(cuSes, cuTz)
            if mC < bestMin
                bestMin := mC
                bestS := 3
        if bestS >= 0
            csCd := f_ses_name(bestS) + " opens " + (bestMin >= 1440 ? str.tostring(int(bestMin / 1440)) + "d " + str.tostring(int(bestMin % 1440 / 60)) + "h" : str.tostring(int(bestMin / 60)) + "h " + str.tostring(bestMin % 60) + "m")
    table.cell(dash, 0, 1, "Session now", text_color=color.white, text_size=f_size(labelSize))
    table.cell(dash, 1, 1, csName + (csCd != "" ? "  " + csCd : ""), text_color=cs >= 0 and csLive ? f_ses_color(cs) : neutralColor, text_size=f_size(labelSize))
    table.cell(dash, 2, 1, csLive ? "█" : "", text_color=cs >= 0 ? f_ses_color(cs) : neutralColor, text_size=f_size(labelSize))

    f_range_row(2, 0, asOn)
    f_range_row(3, 1, ldOn)
    f_range_row(4, 2, nyOn)

    f_pair_row(5, 0, "AS.H in LDN")
    f_pair_row(6, 1, "AS.L in LDN")
    f_pair_row(7, 2, "LDN.H in NY")
    f_pair_row(8, 3, "LDN.L in NY")
    f_pair_row(9, 4, "NY.H in AS")
    f_pair_row(10, 5, "NY.L in AS")

    table.cell(dash, 0, 11, "Levels active", text_color=color.white, text_size=f_size(labelSize))
    table.cell(dash, 1, 11, str.tostring(array.size(levBox)), text_color=color.white, text_size=f_size(labelSize))
    table.cell(dash, 2, 11, f_heat(array.size(levBox), maxLevels), text_color=neutralColor, text_size=f_size(labelSize))

    int swT = array.get(tot, 1)
    int rnT = array.get(tot, 2)
    int ratio = swT + rnT > 0 ? int(math.round(swT * 100.0 / (swT + rnT))) : 50
    color ratioColor = color.from_gradient(ratio, 0, 100, bullColor, bearColor)
    table.cell(dash, 0, 12, "Swept vs run", text_color=color.white, text_size=f_size(labelSize))
    table.cell(dash, 1, 12, str.tostring(swT) + " / " + str.tostring(rnT) + "  (" + str.tostring(ratio) + "%)", text_color=ratioColor, text_size=f_size(labelSize))
    table.cell(dash, 2, 12, str.repeat("█", math.max(1, int(math.ceil(ratio / 20.0)))), text_color=ratioColor, text_size=f_size(labelSize))

    string kzName = ""
    string kzCd = ""
    color kzColor = neutralColor
    if kzAsRaw
        kzName := "Asia KZ"
        kzCd := f_closes_in(kzAsSes, "America/New_York")
        kzColor := color.new(kzAsCol, 0)
    if kzLdRaw
        kzName := kzName == "" ? "London KZ" : kzName + " + London KZ"
        if kzCd == ""
            kzCd := f_closes_in(kzLdSes, "America/New_York")
            kzColor := color.new(kzLdCol, 0)
    if kzNaRaw
        kzName := kzName == "" ? "NY AM KZ" : kzName + " + NY AM KZ"
        if kzCd == ""
            kzCd := f_closes_in(kzNaSes, "America/New_York")
            kzColor := color.new(kzNaCol, 0)
    if kzLcRaw
        kzName := kzName == "" ? "London Close KZ" : kzName + " + London Close KZ"
        if kzCd == ""
            kzCd := f_closes_in(kzLcSes, "America/New_York")
            kzColor := color.new(kzLcCol, 0)
    table.cell(dash, 0, 13, "Killzone now", text_color=color.white, text_size=f_size(labelSize))
    table.cell(dash, 1, 13, kzName == "" ? "none" : kzName + "  ends " + kzCd, text_color=kzName == "" ? neutralColor : kzColor, text_size=f_size(labelSize))
    table.cell(dash, 2, 13, kzName == "" ? "" : "█", text_color=kzColor, text_size=f_size(labelSize))

// Alerts: level events fire once per level, session events once per session
alertcondition(array.get(evt, 0), "Session Opened", "A session opened")
alertcondition(array.get(evt, 1), "Session Closed", "A session closed: its high and low are now live levels")
alertcondition(array.get(evt, 2), "New A/S Session Level", "A session level graduated with grade A or S")
alertcondition(array.get(evt, 3), "Session Level Swept", "A session level was swept: wick beyond, close back (first sweep)")
alertcondition(array.get(evt, 4), "Session Level Run", "A session level was consumed: close beyond the level plus the break buffer")
alertcondition(kzStarted, "Killzone Started", "A killzone window opened")
alertcondition(array.get(evt, 5), "Session Midline Tapped", "A session CE midline was tapped for the first time")
alertcondition(array.get(evt, 6), "Sweep Rate Threshold", "A session pair's swept share crossed 70 percent (n at least 10)")
````
