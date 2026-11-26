# TM.KEYLEVELS [TradersMove]

- url: https://www.tradingview.com/script/OBekB71o/
- type: indicator
- pine_id: PUB;cf52bb95671c42e49e6f3c094c83e32d
- version: 1.0

## Description

[b]KEEP YOUR CHART CLEAN[/b]

[b]TM.KEYLEVELS[/b] is a [b]session and level map[/b] for TradingView that does not paint over your candles. Every level you would normally draw across the whole chart — Asia / London / New York Open, High, Low, Close, Opening Range, Killzone High / Low, previous Day / Week / Month High / Low, developing 1H / 4H / Daily / Weekly High / Low, Daily Open, Weekly Open, NY Midnight Open, NY 08:30 — is parked in [b]two lanes to the right of the last bar[/b]. Price stays readable. The levels stay one glance away.

On the chart itself you only get what has a time dimension: sessions as [b]Lines or Box[/b], Opening Range windows with history, and up to five time zones (Killzone / Avoid). Everything else lives in the lanes until you ask for it — or until [b]AUTO[/b] brings a nearby level to the last candle.

This is the [b]initial OpenSource release (v01)[/b]. Defaults are a starting point. Read the lane, session-chart and zone sections before you trade from the labels. If you find an error or something that does not look right, please report it — v01 is the first public build and we want every miss on the list.

Pine Script v6 · overlay · standalone (no library import) · every session in its own market time · OpenSource · Mozilla Public License 2.0.


[b]WHAT YOU SEE ON THE CHART[/b]

Two lanes, right of the last candle:
[list]
[*] [b]Session Box [SB][/b] — Asia, London, New York: Open, Close, High, Low, optional Equilibrium (EQ), Opening Range High / Low, optional Killzone High / Low. Labels sit [b]left[/b] of the box, in the session colour. Hover a line or label for name + price.
[*] [b]Keylevels Box [KB][/b] — TF1 / TF2 developing High / Low (default 1H and 4H), Daily and Weekly developing High / Low, previous Day / Week / Month High / Low, NY 08:30 open (own colour), Daily Open, Weekly Open, NY Midnight Open (00:00 New York). Labels sit [b]right[/b] of the box. [b]Extend left[/b] draws each lane level from the bar that created it to the box — not infinitely left.
[/list]

Both boxes size themselves to the enabled levels. Overlapping labels step sideways. Lanes exist on the last bar only — the script stays light.

On the candles:
[list]
[*] [b]Session Chart [SS][/b] — [b]Lines[/b] = Open / High / Low grow with the session, Close at the end. [b]Box[/b] (default) = High / Low rectangle. Per session: Frame colour, Frame style (default dotted), Background. History 1–20 (default 15) when Current session only is off. Chart label size is independent of the lane labels.
[*] [b]Opening Range[/b] — first N minutes (5 / 15 / 30 / custom) as a filled window, dotted ORH / ORL through the rest of the session, same levels in the Session Box. Windows repeat into history. Chart OR labels can be switched off under [SS]. Chart TF must be ≤ the OR minutes.
[*] [b]Time zones [ZN][/b] — up to five windows. [b]Killzone[/b] = solid border; High / Low can go into the Session Box (off by default). [b]Avoid[/b] = dashed border, and the Session Box border takes the zone colour while active — a quiet "not now".
[*] [b]AUTO — proximity[/b] (off by default, turn it on) — when price trades near a lane level that has no chart line of its own, a short dashed bridge appears from the last candle to the box. Far levels stay parked. Near levels come to you. Distance is ATR(14) or a percent of price. When price leaves the buffer, the bridge disappears. The chart stays empty until a level is actually in play.
[*] Optional [b]Chart[/b] lines for previous Day / Week / Month and the Opens — from the origin print to the last candle, same price as the box. Not a historical staircase.
[/list]


[b]WHY THIS IS DIFFERENT[/b]

[b]1. Lanes, not a grid.[/b]
Most key-level scripts draw PDH, NY open, 4H high and six session lines across the full width. After a week the chart is a fence. TM.KEYLEVELS puts those levels next to the current price and leaves the candles alone.

[b]2. AUTO — the level comes to you.[/b]
You do not paint every PDH and 4H High across the candles "just in case". Leave them in the lane. Switch [b]AUTO[/b] on. When price walks into a level (wick ± ATR or % buffer), a dashed bridge lights up from the last candle to that line in the box. Walk away, and it vanishes. No permanent grid. The chart tells you only when it matters.

[b]3. Sessions are levels, not background.[/b]
A session is Open, Close, High, Low — four reaction points. TM.KEYLEVELS treats them that way: as lines or boxes that grow live, as lane entries, as alert targets. Opening Range and Killzone High / Low follow the same rule.

[b]4. Every session in its own market time. No conversion, no DST drift.[/b]
London is 08:00–16:30 Europe/London. New York is 09:30–16:00 America/New_York. Tokyo is 09:00–18:00 Asia/Tokyo. The Killzones are in New York time, because that is how ICT defines them. You never translate a session into your local clock — and that matters more than it sounds: the US and Europe do not switch daylight saving on the same date. A New York session typed in Berlin time is one hour wrong for two to three weeks every spring and one week every autumn. Defined in New York time, it is right every day of the year, wherever you sit.

[b]What we ship vs what you change.[/b] Asia and London do not depend on the instrument — leave them. New York defaults to [b]NYSE cash[/b] 09:30–16:00 (15:30–22:00 on a Berlin clock while both sides are on DST). That is cash, not futures. Index and commodity futures, ICT models and the US data window usually want [b]08:30–16:00 New York[/b] — change only that one session. The [b]NY 08:30[/b] keylevel is already that print and does not follow the session window. Forex traders who want the full NY overlap can type 08:00–17:00 New York.

Two levels are pinned on purpose: [b]NY Midnight Open[/b] (00:00 America/New_York — the ICT "true day open") and [b]NY 08:30[/b] (US data releases / futures cash pre-open). They are New York facts, not session settings.

[b]5. System Timezone is a fallback, not a master switch.[/b]
The timezone at the top of the settings looks like the one clock everything follows. It is not. By default [b]nothing reads it[/b]. Asia, London, New York and the zone group each have their own timezone, already set to the market. The top picker is there for one job: when you [i]want[/i] a window in your own clock.

Set it to your zone (Exchange follows the symbol; Custom takes any IANA name, e.g. Europe/Zurich). Then, on the group you want local, switch Timezone to [b]System[/b] and type that window as you see it. Mix freely — London stays in London time, your lunch Avoid in Berlin time. Leave every group on its market zone and the top picker stays unused. That is the intended default, not a leftover.

The DST caveat from point 4 still applies to any window you type in local time. The script does not hide it.

[b]6. Readable labels.[/b]
Session labels left, key-level labels right. Every lane level carries a tooltip with name and exact price — lines included. Overlaps step outward. Session-chart and Opening Range labels have their own size under [SS]. Opening Range chart labels can be hidden.

[b]7. Alerts that name the level.[/b]
Level-touch alerts fire once when the bar reaches a level that [b]already existed[/b] before that bar — a developing High alerts on the retest, not while it is being made. Message: level names + price. Opening Range break fires on the close through ORH / ORL. Both via alert() plus named conditions in the alert dialog.

[b]8. Cheap to run.[/b]
Six request.security calls. Sessions on 1H+ charts come from one 60-minute request. Lanes are drawn on the last bar only.


[b]HOW TO USE IT[/b]

[b]Quick start[/b]
[list]
[*] 1. Add [b]TM.KEYLEVELS[/b] to an intraday chart (M1 – M15 is home).
[*] 2. Leave the timezones alone. Each session already runs in its own market time. Asia and London stay as shipped. New York is NYSE cash 09:30–16:00 — set it to 08:30–16:00 if you trade futures / ICT.
[*] 3. Leave the lanes at default. New York is already on the chart (Box layout, history kept). Turn Chart on for Asia / London if you want those sessions on the candles too.
[*] 4. Under [b][SS] Session Chart[/b] pick Lines or Box and set History / label size.
[*] 5. Turn on [b]Opening Range[/b] for the session you trade. Chart TF must be ≤ the OR minutes. Switch Opening Range labels off if the text gets in the way.
[*] 6. Turn on [b][DI] AUTO[/b]. Leave proximity on ATR. When price nears a lane level, the dashed bridge is your "this one is live" cue.
[/list]

[b]Reading the lanes[/b]
One question: [b]where are the reaction points relative to the current price?[/b] Close = in play. Far = context. A session High lining up with PDH or a 4H High across the two boxes is confluence you did not have to draw. [b]AUTO[/b] is that question answered on the candles: only the in-play level gets a bridge.

[b]Zones[/b]
Default zones are the ICT windows in New York time. [b]London KZ 02:00–05:00 ships on.[/b] NY AM KZ, NY Lunch (Avoid), NY PM KZ and Asia KZ ship off. Rename, move, or switch a slot to [b]Avoid[/b] for lunch, news, or your own no-trade windows. Killzone High / Low become lane levels only when Killzone H/L in Session Box is on. Keep the fill alpha high — the zone is a hint, not a wall.

[b]Alerts, first time[/b]
[list]
[*] 1. Enable the levels you trade (lane checkboxes).
[*] 2. In [b][AL] Alerts[/b] tick [b]Level touch[/b] (Session / Key) and [b]Opening Range break[/b].
[*] 3. Create alert → condition [b]Any alert() function call[/b].
[*] 4. Or pick a named condition for a dedicated webhook.
[/list]

[b]Local time, if you prefer it[/b]
You do not have to think in three clocks. To run everything in your own time:
[list]
[*] 1. [b]System → System Timezone[/b]: pick your zone. Not listed? Choose Custom and type the IANA name (e.g. Europe/Zurich). Exchange follows the symbol.
[*] 2. In [b]Asia / London / New York[/b] set Timezone to System and type the window as you see it on your clock (e.g. London 0900-1730 for Berlin).
[*] 3. In [b]Time Zones[/b] set Timezone to System and do the same for the five slots.
[/list]
Leave any group on its market zone if you only want [i]some[/i] windows local. Remember the DST caveat: a New York window typed in European time drifts for a few weeks each year. That is the price of local time; the script does not hide it.

[b]Timeframes[/b]
Intraday is home. On 1H+ sessions come from a 60-minute request and the Opening Range switches off. Midnight Open and NY 08:30 are intraday only. Daily / Weekly / Monthly levels work everywhere.


[b]EXAMPLES[/b]

[b]1. London Opening Range — window, history, dotted ORH / ORL[/b]
[image]https://www.tradingview.com/x/zXPUN2kl/[/image]

[b]2. Kill Zones active[/b]
[image]https://www.tradingview.com/x/BERxbE4j/[/image]

[b]3. Extend left — origin print to the box / last candle, same price as the lane[/b]
[image]https://www.tradingview.com/x/8wH4TzUY/[/image]

[b]4. AUTO proximity — dashed bridge when price is in play at a lane level[/b]
[image]https://www.tradingview.com/x/fRkuafBh/[/image]


[b]CONFLUENCE — USE TM.KEYLEVELS WITH SOMETHING THAT SEES REGIME[/b]

TM.KEYLEVELS is [b]location[/b]. It tells you where price may react, not which way.
[list]
[*] [b]Moving averages / trend[/b] — MEVO or your own MA stack. Trend says side; TM.KEYLEVELS says where the side is tested.
[*] [b]Market structure[/b] — BOS / CHOCH at a session High or PDH means more than in the middle of nowhere.
[*] [b]Order flow / SMC[/b] — a sweep of the Asia Low into the London Killzone is a setup; the same sweep at random is noise.
[*] [b]An oscillator[/b] — divergence at a lane level, not in a vacuum.
[/list]

Stack: [b]regime tool = side[/b], [b]TM.KEYLEVELS = where[/b], [b]your trigger = when[/b]. If price is not at a level, there is no trade to filter.


[b]WHO IT IS FOR[/b]
[list]
[*] Intraday traders who mark sessions, PDH / PDL and the opens every morning — and want the chart back.
[*] ICT / SMC traders who think in killzones, midnight open and session liquidity.
[*] Opening-range traders who want window, history, break and alert in one place.
[/list]

It is [b]not[/b] a signal pack and not a strategy. There are no arrows. A level is a place, not an instruction.


[b]INITIAL RELEASE[/b]

v01 is the first OpenSource build. Settings, defaults and edge cases (weekends, broker daily sessions, DST) are still being proven in the wild. Please report errors, wrong levels or unclear settings so they can be fixed in the next version.

[b]DISCLAIMER[/b]

TM.KEYLEVELS is a visual overlay. It does not place orders, manage risk, or guarantee results. Session and higher-timeframe levels depend on your data feed's session definition and on the session windows you set. Use on any market and timeframe at your own risk. This is not investment advice.

© TradersMove - 1% per day — your Move to Success

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradersMove / RenkCapital 2026 — TM.KEYLEVELS
//
// Invite-only release from BETA v06. Do not overwrite. OSS line stays in OPENSOURCE/.
// Session Box   = Asia / London / New York Open, Close, High, Low, EQ, Opening Range and Killzone High / Low.
// Keylevels Box = TF1 / TF2 / Daily / Weekly developing H/L, Prev Day / Week / Month H/L, NY 08:30, Daily / Weekly Open, NY Midnight Open.
// Chart         = sessions as Lines (O/H/L grow, Close at end) or Box (H/L rectangle), Opening Range windows
//                 with history, up to 5 time zones (Killzone / Avoid), optional Chart lines from the origin print,
//                 AUTO proximity lines (last candle → box).
// Alerts        = level touch (name + price in the message) and Opening Range break — alert() + alertcondition().
// Standalone — helpers are inlined (no TM_LIB import).
// Timezones    = every session runs in its own market zone (Asia/Tokyo, Europe/London, America/New_York), the zones in
//                 America/New_York (ICT). Each group can switch to the System zone if you prefer local times everywhere.
//                 NY 08:30 and NY Midnight Open are fixed to America/New_York.
// Boxes are drawn on the last bar only (barstate.islast); session lines and zones run on every bar.

ind_title       = 'TM.KEYLEVELS [TradersMove]'
ind_short_name  = 'TM.KEYLEVELS'
ind_version     = 'v01'
ind_shorttitle  = ind_short_name + '.' + ind_version
ind_date        = '10.10.2026'

//@version=6
indicator(title=ind_title, shorttitle=ind_shorttitle, max_lines_count=500, max_labels_count=500, max_boxes_count=500, explicit_plot_zorder=true, behind_chart=true, overlay=true)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ██  ██████  ██████  ███    ██ ███████
//+---    ██ ██      ██    ██ ████   ██ ██
//+---    ██ ██      ██    ██ ██ ██  ██ ███████
//+---    ██ ██      ██    ██ ██  ██ ██      ██
//+---    ██  ██████  ██████  ██   ████ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ICONS
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
// Ⓐ Ⓑ Ⓒ Ⓓ Ⓔ Ⓕ Ⓖ Ⓗ Ⓘ Ⓙ Ⓚ
// ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩
// ← ↑ → ↓ ⇠ ⇡ ⇢ ⇣ ⇦ ⇧ ⇨ ⇩
// 🔸 🔹 🔶 🔷 ◓ ◒ ⦿ ™
//
// ASCII GRAFICS:   https://patorjk.com/software/taag/#p=display&f=ANSI%20Regular&t=
// FONT:            ANSI REGULAR.  
//
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ████████  ██████   ██████  ██      ████████ ██ ██████  ███████
//+---       ██    ██    ██ ██    ██ ██         ██    ██ ██   ██ ██
//+---       ██    ██    ██ ██    ██ ██         ██    ██ ██████  ███████
//+---       ██    ██    ██ ██    ██ ██         ██    ██ ██           ██
//+---       ██     ██████   ██████  ███████    ██    ██ ██      ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    TOOLTIPS
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
string FO1           = 'Default'
string FO2           = 'Monospace'
tt_tz                = 'System zone. Only used by a session or zone group whose own Timezone is set to "System".\nBy default every session runs in its own market zone (Tokyo / London / New York) and the zones in New York time — DST is then correct for each market without touching this.\nCustom = fill in the IANA field.'
tt_tz_custom         = 'Only when Timezone = Custom. Exact IANA name, e.g. Europe/Zurich, Asia/Kolkata, Pacific/Auckland.'
tt_sess_tz           = 'Timezone of this session window. Default = the market\'s own zone, so the window is right in every DST phase wherever you sit.\nSystem = use the System timezone and type the window in your local time.'
tt_zn_tz             = 'Timezone for all five windows. Default America/New_York — ICT Killzones are defined in New York time.\nSystem = use the System timezone.'
tt_auto              = 'Draws disabled chart lines only when price trades near the level (wick ± buffer). Short bridge from the last candle to the box.'
tt_auto_unit         = 'ATR (recommended): multiple of ATR(14) — scales with instrument and timeframe.\n% Price: percent of price (e.g. 0.20 = 0.20 %).'
tt_box_gap           = 'Gap in bars from the last candle to the Session Box.'
tt_kb_gap            = 'Gap between Session Box and Keylevels Box.'
tt_padding           = 'Percent padding above/below both boxes so the frame does not cover the lines.'
tt_label             = '[Chart | Box] Label size on the chart and inside both boxes.'
tt_orb_len           = 'Minutes from session open. Used by every session that has Opening Range enabled.'
tt_kb_extend         = 'On: each Keylevels-Box line is drawn from the bar that created the level (PDH = yesterday\'s high bar, D Open = start of the day, NY 08:30 = that print, …) to the box. Not infinitely left.\nOff: lines stay inside the box.'
tt_kb_tf             = '[Box | Timeframe | Color] High/Low of the selected (developing) candle.'
tt_kb_cur            = '[Box | Color] Current (developing) period High/Low.'
tt_prev              = '[Box | Chart | Color] Box = level in the Keylevels Box. Chart = horizontal line from the bar that made the High/Low (EQ from the earlier of the two) to the last candle — same price as the box, not a historical stepline.'
tt_nyo               = '[Box | Color] Open of the first bar at or after 08:30 America/New_York (US data releases, futures cash pre-open). Fixed zone, independent of the NY session window. Intraday charts only.'
tt_open              = '[Box | Chart | Color] Open of the current period. Box = level in the Keylevels Box. Chart = horizontal line from that open print to the last candle.'
tt_mo                = '[Box | Chart | Color] Open of the first bar of the New York day (00:00 America/New_York, fixed — independent of every timezone setting). ICT "True Day Open". Intraday charts only.'
tt_zn                = '[On | Name | Color] then [Window | Type]. Window in the zone timezone above. Box bounded by the window High/Low, name inside.\nKillzone = solid border, H/L go into the Session Box.\nAvoid = dashed border, Session Box border takes the zone color while active. Set the alpha in the color picker.'
tt_zn_cur            = 'On: only today\'s zones. Off: keep the last 5 of each zone.'
tt_zn_lv             = 'Adds "<Name> High / Low" of every Killzone to the Session Box.'
tt_al                = 'alert() messages with level name and price. Create the alert with condition "Any alert() function call".\nSession levels = Open / Close / High / Low / EQ / OR / Killzone H/L of enabled sessions.\nKey levels = everything enabled in the Keylevels Box.\nA touch fires once when the bar range reaches a level that already existed before this bar (developing H/L do not fire while they are being made).'
tt_al_orb            = 'Close above ORH / below ORL after the Opening Range window, once per break, on bar close.'
tt_ny_sess           = 'Default 09:30–16:00 America/New_York = NYSE cash (15:30–22:00 Berlin while both sides are on DST).\nAsia (09:00–18:00 Tokyo) and London (08:00–16:30 London) stay the same on every instrument.\nFutures / ICT / US data: set this window to 08:30–16:00. The NY 08:30 keylevel is that print even if you leave the session at 09:30.\nForex NY overlap is often 08:00–17:00 New York — type that if you trade FX as the session.'
tt_sess_disp         = '[Box | Chart] Box = levels in the Session Box. Chart = lines on the chart from session open to session close.'
tt_sess_cur          = 'On: only the latest session on the chart. Off: keep the last N sessions from [SS] Session Chart → History.'
tt_sess_layout       = 'Lines = Open / High / Low grow with the session, Close at the end (current look).\nBox = High/Low rectangle from session open to the last in-session bar, like the time-zone windows.'
tt_sess_keep         = 'How many past sessions to keep on the chart when "Current session only" is off. Cap 20 — three sessions × lines + Opening Range would otherwise hit TradingView object limits.'
tt_sess_lbl          = 'Label size on session chart drawings (lines or boxes) and Opening Range labels. Independent of the lane-box label size under [BX].'
tt_orb_lbl           = 'Show AS / LO / NY OR High and OR Low labels on the chart Opening Range.\nOff = box and dotted ORH/ORL only. Session Box OR levels stay under [BX].'
tt_sess_bx           = '[Frame colour | Frame style | Background colour] Chart session box. Only used when [SS] Layout = Box.\nDefault frame style is dotted.\nLane "Box lines" stay the Session Box to the right of the chart — they do not change the chart box.'
tt_eq                = 'Midpoint between High and Low.'
tt_orb               = 'High/Low of the first N minutes after the session open. Fill on the chart, dotted ORH/ORL through the rest of the session, levels in the Session Box. Chart timeframe must be ≤ the OR minutes.'
tt_lines             = '[Color | Style | Width]'


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ████████ ██    ██ ██████  ███████ ███████
//+---       ██     ██  ██  ██   ██ ██      ██
//+---       ██      ████   ██████  █████   ███████
//+---       ██       ██    ██      ██           ██
//+---       ██       ██    ██      ███████ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    TYPES
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//

// One box level: line + visible label + invisible hit-zone label (Pine lines have no tooltip)
type LVL
	line  ln
	line  ext
	label lb
	label tip


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ███    ███ ███████ ████████ ██   ██  ██████  ██████  ███████
//+---    ████  ████ ██         ██    ██   ██ ██    ██ ██   ██ ██
//+---    ██ ████ ██ █████      ██    ███████ ██    ██ ██   ██ ███████
//+---    ██  ██  ██ ██         ██    ██   ██ ██    ██ ██   ██      ██
//+---    ██      ██ ███████    ██    ██   ██  ██████  ██████  ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    METHODS
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//

//==> Inputs → Pine constants
f_getFont(simple string font) =>
	font == FO2 ? font.family_monospace : font.family_default

f_getSize(simple string sz) =>
	switch sz
		'Tiny'  => size.tiny
		'Small' => size.small
		'Large' => size.large
		'Huge'  => size.huge
		=> size.normal

f_getLinestyle(simple string style) =>
	switch style
		'----' => line.style_dashed
		'····' => line.style_dotted
		=> line.style_solid

// Timezone picker → IANA string. 'System' = the System zone, 'Exchange' = symbol exchange zone.
f_tz(simple string sel, simple string sys) =>
	string z = sel == 'System' ? sys : sel == 'Exchange' ? syminfo.timezone : sel
	str.length(z) > 0 ? z : 'UTC'

// '60' → '1H', '240' → '4H', '15' → '15m', 'D' / 'W' / 'M' unchanged
f_tf_short(simple string tf) =>
	float n = str.tonumber(tf)
	na(n) ? tf : n >= 60 and n % 60 == 0 ? str.tostring(n / 60, '#') + 'H' : str.tostring(n, '#') + 'm'

//==> na-safe min / max
f_nmax(float a, float b) =>
	na(a) ? b : na(b) ? a : math.max(a, b)
f_nmin(float a, float b) =>
	na(a) ? b : na(b) ? a : math.min(a, b)

// Chart-line start: origin print, else period start, else last bar
f_ch_t(int origin, int fallback) =>
	na(origin) ? (na(fallback) ? time : fallback) : origin
f_eq_t(int a, int b, int fallback) =>
	f_ch_t(na(a) ? b : na(b) ? a : math.min(a, b), fallback)

//==> HTF levels: current (developing) High / Low / Open and previous (completed) High / Low in one request
f_htf5() =>
	[high, low, open, high[1], low[1]]
f_getHTF(simple string tf) =>
	request.security(syminfo.tickerid, tf, f_htf5(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

//==> Session run: reset only at session start, O/H/L/C persist after the session ends
f_sess_pack(simple string sess, simple string tz) =>
	bool in_now  = not na(time(timeframe.period, sess, tz))
	bool started = in_now and not in_now[1]
	bool ended   = not in_now and in_now[1]
	var float o = na
	var float c = na
	var float h = na
	var float l = na
	if started or (in_now and na(h))
		o := open
		c := close
		h := high
		l := low
	else if in_now
		h := math.max(h, high)
		l := math.min(l, low)
		c := close
	[in_now, started, ended, o, c, h, l]

// Three sessions in one request.security call (used on charts ≥ 1H), each in its own timezone
f_sess_pack3(simple string s1, simple string z1, simple string s2, simple string z2, simple string s3, simple string z3) =>
	[_, _, _, o1, c1, h1, l1] = f_sess_pack(s1, z1)
	[_, _, _, o2, c2, h2, l2] = f_sess_pack(s2, z2)
	[_, _, _, o3, c3, h3, l3] = f_sess_pack(s3, z3)
	[o1, c1, h1, l1, o2, c2, h2, l2, o3, c3, h3, l3]

//==> Opening Range: H/L of the first orb_ms after session start; t0 = open, t1 = range end, t2 = last in-session bar
f_orb_run(bool started, bool in_now, int orb_ms) =>
	var float h = na
	var float l = na
	var int t0 = na
	var int t1 = na
	var int t2 = na
	if started
		t0 := time
		t1 := time + orb_ms
		h := high
		l := low
	else if in_now and not na(t0) and time < t1
		h := math.max(h, high)
		l := math.min(l, low)
	if in_now
		t2 := time
	[h, l, t0, t1, t2]

//==> Opening Range break: close crosses ORH / ORL after the range window, inside the session
f_orb_brk(bool ok, bool in_now, int t1, float h, float l) =>
	bool up = ta.crossover(close, h)
	bool dn = ta.crossunder(close, l)
	bool go = ok and in_now and not na(t1) and time > t1
	[go and up, go and dn]

//==> Time zone (Killzone / Avoid): box from window start to the last in-window bar, bounded by the window H/L, name inside top-left.
//    var state lives per call site → one call per zone. Returns [in_now, h, l].
f_zone(bool on, simple string sess, simple string tz, string name, color col, bool is_kz, bool cur, string sz, string fam) =>
	var array<box>   bxs = array.new<box>()
	var array<label> lbs = array.new<label>()
	var box   bx = na
	var label lb = na
	var float h  = na
	var float l  = na
	bool in_now  = not na(time(timeframe.period, sess, tz))
	bool started = in_now and not in_now[1]
	int  keep    = cur ? 1 : 5
	if on and (started or (in_now and na(bx)))
		while array.size(bxs) > keep - 1
			box.delete(array.shift(bxs))
		while array.size(lbs) > keep - 1
			label.delete(array.shift(lbs))
		h  := high
		l  := low
		bx := box.new(time, h, time, l, xloc=xloc.bar_time, border_color=color.new(col, 40), border_style=is_kz ? line.style_solid : line.style_dashed, border_width=1, bgcolor=col)
		lb := label.new(time, h, name, xloc=xloc.bar_time, style=label.style_label_upper_left, color=color.new(col, 100), textcolor=color.new(col, 0), size=sz, text_font_family=fam)
		array.push(bxs, bx)
		array.push(lbs, lb)
	else if on and in_now and not na(bx)
		h := math.max(h, high)
		l := math.min(l, low)
		box.set_top(bx, h)
		box.set_bottom(bx, l)
		box.set_right(bx, time)
		label.set_xy(lb, box.get_left(bx), h)
	[in_now, h, l]

// Zone color while an Avoid window is active (na otherwise)
f_av(bool on, bool in_now, string typ, color col) =>
	color c = na
	if on and in_now and typ == 'Avoid'
		c := color.new(col, 0)
	c

//==> Alert helper: appends the level name when the bar range reaches a level that already existed before this bar
f_tch(string acc, bool on, float px, string nm) =>
	bool t   = not na(px) and high >= px and low <= px and px == px[1]
	bool hit = t and not t[1]
	on and hit ? acc + (acc == '' ? '' : ', ') + nm : acc

//==> Box extent of one session: only the levels that are actually shown
f_sess_ext(bool show, bool o_on, bool c_on, bool h_on, bool l_on, bool eq_on, bool or_on, float o, float c, float h, float l, float orh, float orl) =>
	float hi = na
	float lo = na
	if show
		if o_on
			hi := f_nmax(hi, o)
			lo := f_nmin(lo, o)
		if c_on
			hi := f_nmax(hi, c)
			lo := f_nmin(lo, c)
		if h_on or eq_on
			hi := f_nmax(hi, h)
			lo := f_nmin(lo, h)
		if l_on or eq_on
			hi := f_nmax(hi, l)
			lo := f_nmin(lo, l)
		if or_on
			hi := f_nmax(hi, orh)
			lo := f_nmin(lo, orl)
	[hi, lo]

//==> Session on the chart: Lines (O/H/L grow, Close at end) or Box (H/L rectangle). var state per call site.
f_sess_chart(bool on, bool started, bool in_now, bool ended, bool only_current, float o, float c, float h, float l, color col, string sty, int wdt, string tag, string sz, string fam, int keep_n, string layout, color frame, color fill, string bsty) =>
	var array<line>  lns    = array.new<line>()
	var array<label> lbs    = array.new<label>()
	var array<box>   bxs    = array.new<box>()
	var array<label> bx_lbs = array.new<label>()
	var line  ln_o = na
	var line  ln_h = na
	var line  ln_l = na
	var label lb_h = na
	var label lb_l = na
	var box   bx   = na
	var label bx_lb = na
	var int   t0   = na
	var float o0   = na
	int   keep    = only_current ? 1 : keep_n
	bool  use_box = layout == 'Box'
	color lb_bg   = color.new(col, 70)
	if on and started and not na(o) and not na(h) and not na(l)
		t0 := time
		o0 := o
		if use_box
			while array.size(bxs) > keep - 1
				box.delete(array.shift(bxs))
			while array.size(bx_lbs) > keep - 1
				label.delete(array.shift(bx_lbs))
			bx := box.new(time, h, time, l, xloc=xloc.bar_time, border_color=frame, border_style=bsty, border_width=1, bgcolor=fill)
			bx_lb := label.new(time, h, tag, xloc=xloc.bar_time, style=label.style_label_upper_left, color=color.new(col, 100), textcolor=col, size=sz, tooltip=tag + '\n' + str.tostring(h, format.mintick) + ' / ' + str.tostring(l, format.mintick), text_font_family=fam)
			array.push(bxs, bx)
			array.push(bx_lbs, bx_lb)
		else
			while array.size(lns) > (keep - 1) * 4
				line.delete(array.shift(lns))
			while array.size(lbs) > (keep - 1) * 4
				label.delete(array.shift(lbs))
			ln_o := line.new(time, o, time, o, xloc=xloc.bar_time, color=col, style=sty, width=wdt)
			ln_h := line.new(time, h, time, h, xloc=xloc.bar_time, color=col, style=sty, width=wdt)
			ln_l := line.new(time, l, time, l, xloc=xloc.bar_time, color=col, style=sty, width=wdt)
			lb_h := label.new(time, h, tag + ' High', xloc=xloc.bar_time, style=label.style_label_down, color=lb_bg, textcolor=col, size=sz, text_font_family=fam)
			lb_l := label.new(time, l, tag + ' Low',  xloc=xloc.bar_time, style=label.style_label_up,   color=lb_bg, textcolor=col, size=sz, text_font_family=fam)
			array.push(lns, ln_o)
			array.push(lns, ln_h)
			array.push(lns, ln_l)
			array.push(lbs, label.new(time, o, tag + ' Open', xloc=xloc.bar_time, style=label.style_label_down, color=lb_bg, textcolor=col, size=sz, tooltip=tag + ' Open\n' + str.tostring(o, format.mintick), text_font_family=fam))
			array.push(lbs, lb_h)
			array.push(lbs, lb_l)
	if on and not na(t0) and (in_now or ended)
		int x2 = ended ? time[1] : time
		if use_box and not na(bx)
			box.set_top(bx, h)
			box.set_bottom(bx, l)
			box.set_right(bx, x2)
			box.set_border_color(bx, frame)
			box.set_border_style(bx, bsty)
			box.set_bgcolor(bx, fill)
			label.set_xy(bx_lb, t0, h)
			label.set_tooltip(bx_lb, tag + '\n' + str.tostring(h, format.mintick) + ' / ' + str.tostring(l, format.mintick))
		else if not use_box and not na(ln_o)
			line.set_xy2(ln_o, x2, o0)
			line.set_xy1(ln_h, t0, h)
			line.set_xy2(ln_h, x2, h)
			line.set_xy1(ln_l, t0, l)
			line.set_xy2(ln_l, x2, l)
			label.set_xy(lb_h, t0, h)
			label.set_tooltip(lb_h, tag + ' High\n' + str.tostring(h, format.mintick))
			label.set_xy(lb_l, t0, l)
			label.set_tooltip(lb_l, tag + ' Low\n' + str.tostring(l, format.mintick))
			if ended and not na(c)
				array.push(lns, line.new(t0, c, x2, c, xloc=xloc.bar_time, color=col, style=sty, width=wdt))
				array.push(lbs, label.new(t0, c, tag + ' Close', xloc=xloc.bar_time, style=label.style_label_up, color=lb_bg, textcolor=col, size=sz, tooltip=tag + ' Close\n' + str.tostring(c, format.mintick), text_font_family=fam))
	0

//==> Opening Range on the chart — history, same keep as the session (every bar, not last-bar only)
f_orb_chart(bool on, bool started, bool in_now, float h, float l, int t0, int t1, int t2, color col, int wdt, string tag, string sz, string fam, int keep_n, bool only_current, bool show_lbl) =>
	var array<box>   bxs = array.new<box>()
	var array<label> lbs = array.new<label>()
	var array<line>  lns = array.new<line>()
	var box   bx  = na
	var label lbh = na
	var label lbl = na
	var line  lnh = na
	var line  lnl = na
	int k = only_current ? 1 : keep_n
	if not on
		while array.size(bxs) > 0
			box.delete(array.shift(bxs))
		while array.size(lbs) > 0
			label.delete(array.shift(lbs))
		while array.size(lns) > 0
			line.delete(array.shift(lns))
		bx := na
		lbh := na
		lbl := na
		lnh := na
		lnl := na
	else if not show_lbl
		while array.size(lbs) > 0
			label.delete(array.shift(lbs))
		lbh := na
		lbl := na
	if on and started and not na(t0) and not na(h) and not na(l)
		while array.size(bxs) > k - 1
			box.delete(array.shift(bxs))
		while array.size(lbs) > (k - 1) * 2
			label.delete(array.shift(lbs))
		while array.size(lns) > (k - 1) * 2
			line.delete(array.shift(lns))
		int t1u = na(t1) ? t0 : t1
		color bc = color.new(col, 45)
		color bg = color.new(col, 88)
		bx  := box.new(t0, h, t1u, l, xloc=xloc.bar_time, border_color=bc, border_width=1, bgcolor=bg)
		if show_lbl
			lbh := label.new(t1u, h, tag + ' OR High', xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col, 70), textcolor=col, size=sz, tooltip=tag + ' OR High\n' + str.tostring(h, format.mintick), text_font_family=fam)
			lbl := label.new(t1u, l, tag + ' OR Low',  xloc=xloc.bar_time, style=label.style_label_up,   color=color.new(col, 70), textcolor=col, size=sz, tooltip=tag + ' OR Low\n' + str.tostring(l, format.mintick), text_font_family=fam)
			array.push(lbs, lbh)
			array.push(lbs, lbl)
		else
			lbh := na
			lbl := na
		lnh := line.new(t1u, h, t1u, h, xloc=xloc.bar_time, color=col, style=line.style_dotted, width=wdt)
		lnl := line.new(t1u, l, t1u, l, xloc=xloc.bar_time, color=col, style=line.style_dotted, width=wdt)
		array.push(bxs, bx)
		array.push(lns, lnh)
		array.push(lns, lnl)
	else if on and in_now and not na(bx) and not na(t0)
		int t1u = na(t1) ? t0 : t1
		box.set_lefttop(bx, t0, h)
		box.set_rightbottom(bx, t1u, l)
		if show_lbl
			if na(lbh)
				lbh := label.new(t1u, h, tag + ' OR High', xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col, 70), textcolor=col, size=sz, tooltip=tag + ' OR High\n' + str.tostring(h, format.mintick), text_font_family=fam)
				lbl := label.new(t1u, l, tag + ' OR Low',  xloc=xloc.bar_time, style=label.style_label_up,   color=color.new(col, 70), textcolor=col, size=sz, tooltip=tag + ' OR Low\n' + str.tostring(l, format.mintick), text_font_family=fam)
				array.push(lbs, lbh)
				array.push(lbs, lbl)
			else
				label.set_xy(lbh, t1u, h)
				label.set_tooltip(lbh, tag + ' OR High\n' + str.tostring(h, format.mintick))
				label.set_xy(lbl, t1u, l)
				label.set_tooltip(lbl, tag + ' OR Low\n' + str.tostring(l, format.mintick))
		int t2u = na(t2) ? t1u : math.max(t2, t1u)
		line.set_xy1(lnh, t1u, h)
		line.set_xy2(lnh, t2u, h)
		line.set_xy1(lnl, t1u, l)
		line.set_xy2(lnl, t2u, l)
	0

//==> Generic drawing helpers (create / update / delete)
f_box(box b, bool on, int x1, float top, int x2, float btm, color bc, color bg, string xl) =>
	box nb = b
	if on and not na(x1) and not na(x2) and not na(top) and not na(btm)
		if na(nb)
			nb := box.new(x1, top, x2, btm, xloc=xl, border_color=bc, border_width=1, bgcolor=bg)
		else
			box.set_lefttop(nb, x1, top)
			box.set_rightbottom(nb, x2, btm)
			box.set_border_color(nb, bc)
			box.set_bgcolor(nb, bg)
	else if not na(nb)
		box.delete(nb)
		nb := na
	nb

f_ln(line ln, bool on, float px, int x1, int x2, color c, string sty, int wdt, bool ext_l, string xl) =>
	line nln = ln
	if on and not na(px) and not na(x1) and not na(x2)
		if na(nln)
			nln := line.new(x1, px, x2, px, xloc=xl, color=c, style=sty, width=wdt, extend=ext_l ? extend.left : extend.none)
		else
			line.set_xy1(nln, x1, px)
			line.set_xy2(nln, x2, px)
			line.set_extend(nln, ext_l ? extend.left : extend.none)
			line.set_color(nln, c)
	else if not na(nln)
		line.delete(nln)
		nln := na
	nln

// Box level: line inside the box (bar_index, always aligns with the box). Optional extend = origin time → last candle (bar_time).
// Labels stay at the box edge (txt_right: right of x2 = Keylevels, else left of x1 = Session).
f_lvl(LVL v, bool on, float px, int x1, int x2, color c, string sty, int wdt, bool ext_l, string txt, string sz, string fam, bool txt_right, int origin_t = na) =>
	if on and not na(px)
		int    ln_x1 = ext_l ? bar_index : x1
		int    xl    = txt_right ? x2 : x1
		int    xm    = int(math.round((x1 + x2) * 0.5))
		string tip   = txt + '\n' + str.tostring(px, format.mintick)
		color  hid   = color.new(color.black, 100)
		if na(v.ln)
			v.ln  := line.new(ln_x1, px, x2, px, xloc=xloc.bar_index, color=c, style=sty, width=wdt, extend=extend.none)
			v.lb  := label.new(xl, px, txt, xloc=xloc.bar_index, style=txt_right ? label.style_label_left : label.style_label_right, color=color.new(color.black, 20), textcolor=c, size=sz, tooltip=tip, text_font_family=fam)
			v.tip := label.new(xm, px, txt, xloc=xloc.bar_index, style=label.style_label_center, color=hid, textcolor=hid, size=size.large, tooltip=tip)
		else
			line.set_xy1(v.ln, ln_x1, px)
			line.set_xy2(v.ln, x2, px)
			line.set_extend(v.ln, extend.none)
			line.set_color(v.ln, c)
			label.set_xy(v.lb, xl, px)
			label.set_text(v.lb, txt)
			label.set_textcolor(v.lb, c)
			label.set_tooltip(v.lb, tip)
			label.set_xy(v.tip, xm, px)
			label.set_tooltip(v.tip, tip)
		v.ext := f_ln(v.ext, ext_l and not na(origin_t), px, origin_t, time, c, sty, wdt, false, xloc.bar_time)
	else if not na(v.ln)
		line.delete(v.ln)
		label.delete(v.lb)
		label.delete(v.tip)
		v.ln  := na
		v.lb  := na
		v.tip := na
		v.ext := f_ln(v.ext, false, na, na, na, c, sty, wdt, false, xloc.bar_time)
	0

// Opening Range chart label at the end of the range window
f_orb_lb(label lb, bool on, int x, float px, string txt, color c, string sz, string fam, bool is_hi) =>
	label nlb = lb
	if on and not na(x) and not na(px)
		string tip = txt + '\n' + str.tostring(px, format.mintick)
		if na(nlb)
			nlb := label.new(x, px, txt, xloc=xloc.bar_time, style=is_hi ? label.style_label_down : label.style_label_up, color=color.new(c, 70), textcolor=c, size=sz, tooltip=tip, text_font_family=fam)
		else
			label.set_xy(nlb, x, px)
			label.set_tooltip(nlb, tip)
	else if not na(nlb)
		label.delete(nlb)
		nlb := na
	nlb

// AUTO proximity line: dashed bridge from the last candle to the box (re-created each tick on the last bar)
f_auto(array<line> a, bool on, float px, int x2, color c) =>
	if on and not na(px)
		array.push(a, line.new(bar_index, px, x2, px, xloc=xloc.bar_index, color=c, style=line.style_dashed, width=1))
	0

f_px_near(float px, float buf) =>
	not na(px) and not na(buf) and high >= px - buf and low <= px + buf

//==> Label overlap: keep Y on the line, offset X only when two labels in the same slot collide (greedy, outward)
f_lb_push(array<label> a, array<float> p, label lb, float px) =>
	if not na(lb) and not na(px)
		array.push(a, lb)
		array.push(p, px)
	0

f_slot_sep(simple string sz, float atr) =>
	float m = sz == 'Tiny' ? 0.45 : sz == 'Small' ? 0.7 : sz == 'Large' ? 1.15 : 0.9
	nz(atr) * m

f_slot_in(array<label> lbs, array<float> pxs, int x0, int step, float sep, int max_slots, int dir) =>
	int n = array.size(lbs)
	if n >= 2 and sep > 0 and step > 0
		array<int> idx  = array.new<int>()
		array<int> slot = array.new<int>()
		for i = 0 to n - 1
			array.push(idx, i)
			array.push(slot, 0)
		for a = 0 to n - 2
			int min_i = a
			for b = a + 1 to n - 1
				if array.get(pxs, array.get(idx, b)) < array.get(pxs, array.get(idx, min_i))
					min_i := b
			if min_i != a
				int tmp = array.get(idx, a)
				array.set(idx, a, array.get(idx, min_i))
				array.set(idx, min_i, tmp)
		for k = 0 to n - 1
			int i = array.get(idx, k)
			int s = 0
			for att = 0 to max_slots
				bool hit = false
				if k > 0
					for j = 0 to k - 1
						int prev = array.get(idx, j)
						if array.get(slot, prev) == s
							if math.abs(array.get(pxs, i) - array.get(pxs, prev)) < sep
								hit := true
				if not hit
					array.set(slot, i, s)
					break
				s += 1
			if s > max_slots
				array.set(slot, i, max_slots)
		for i = 0 to n - 1
			int dx = array.get(slot, i)
			if dx > 0
				label.set_x(array.get(lbs, i), x0 + dir * dx * step)
	0


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---     ██████  ██████   ██████  ██    ██ ██████  ███████
//+---     ██       ██   ██ ██    ██ ██    ██ ██   ██ ██
//+---     ██   ███ ██████  ██    ██ ██    ██ ██████  ███████
//+---     ██    ██ ██   ██ ██    ██ ██    ██ ██           ██
//+---      ██████  ██   ██  ██████   ██████  ██      ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    GROUPS
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
sys_set              = '🔶🔸 [SY] SYSTEM' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
dis_set              = '🔶🔸 [DI] DISPLAY' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
bx_set               = '🔶🔸 [BX] BOXES' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
sb_set               = '🔶🔸 [SB] SESSION BOX' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
kb_set               = '🔶🔸 [KB] KEYLEVELS BOX' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
ss_set               = '🔶🔸 [SS] SESSION CHART' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
as_set               = '🔶🔸 [AS] ASIAN SESSION' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
ls_set               = '🔶🔸 [LO] LONDON SESSION' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
ny_set               = '🔶🔸 [NY] NEW YORK SESSION' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
zn_set               = '🔶🔸 [ZN] TIME ZONES' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
al_set               = '🔶🔸 [AL] ALERTS' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ███████ ██    ██ ███████ ████████ ███████ ███    ███
//+---    ██       ██  ██  ██         ██    ██      ████  ████
//+---    ███████   ████   ███████    ██    █████   ██ ████ ██
//+---         ██    ██         ██    ██    ██      ██  ██  ██
//+---    ███████    ██    ███████    ██    ███████ ██      ██
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    [SY] SYSTEM
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
// IANA: dropdown = common trading hubs. Custom = any zone, e.g. Europe/Zurich, America/Toronto, Asia/Kolkata.
// List: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
// The System zone is a fallback: sessions and zones use their own market zone unless their picker is set to 'System'.
tz_sel               = input.string      ('Europe/Berlin'              ,'System Timezone'                 ,inline='00'       ,group=sys_set, options=['Europe/Berlin','Europe/London','America/New_York','America/Chicago','America/Los_Angeles','Asia/Tokyo','Asia/Singapore','Asia/Hong_Kong','Asia/Dubai','Australia/Sydney','UTC','Exchange','Custom'], tooltip=tt_tz)
tz_custom            = input.string      (''                           ,'IANA'                            ,inline='00'       ,group=sys_set, tooltip=tt_tz_custom)
font_sel             = input.string      ('Monospace'                  ,'Font'                            ,inline='02'       ,group=sys_set, options=[FO1, FO2])

tz_pick              = tz_sel == 'Exchange' ? syminfo.timezone : tz_sel == 'Custom' ? tz_custom : tz_sel
tz_use               = str.length(tz_pick) > 0 ? tz_pick : 'UTC'
sys_font             = f_getFont(font_sel)

// Per-group timezone pickers (sessions / zones). 'System' = tz_use above.
string TZ_SYS        = 'System'
string TZ_NY         = 'America/New_York'


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ██████  ██ ███████ ██████  ██       █████  ██    ██
//+---    ██   ██ ██ ██      ██   ██ ██      ██   ██  ██  ██
//+---    ██   ██ ██ ███████ ██████  ██      ███████   ████
//+---    ██   ██ ██      ██ ██      ██      ██   ██    ██
//+---    ██████  ██ ███████ ██      ███████ ██   ██    ██
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    [DI] DISPLAY
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
show_sb              = input.bool        (true                         ,'[SB] Session Box'                ,inline='00'       ,group=dis_set)
show_kb              = input.bool        (true                         ,'[KB] Keylevels Box'              ,inline='02'       ,group=dis_set)
show_zn              = input.bool        (true                         ,'[ZN] Time Zones'                 ,inline='03'       ,group=dis_set)
show_auto            = input.bool        (false                        ,'[AUTO] Auto Chart Display'       ,inline='04'       ,group=dis_set, tooltip=tt_auto)
auto_unit            = input.string      ('ATR'                        ,'Proximity [Unit|Value]'          ,inline='06'       ,group=dis_set, options=['ATR', '% Price'], tooltip=tt_auto_unit)
auto_val             = input.float       (0.50                         ,''                                ,inline='06'       ,group=dis_set, minval=0.05, maxval=10.0, step=0.05)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ██████   ██████  ██   ██ ███████ ███████
//+---    ██   ██ ██    ██  ██ ██  ██      ██
//+---    ██████  ██    ██   ███   █████   ███████
//+---    ██   ██ ██    ██  ██ ██  ██           ██
//+---    ██████   ██████  ██   ██ ███████ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    [BX] BOXES (shared) · [SB] SESSION BOX · [KB] KEYLEVELS BOX
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
box_offset           = input.int         (25                           ,'Gap: Chart→Box'                  ,inline='00'       ,group=bx_set, minval=0, maxval=80, tooltip=tt_box_gap)
kb_gap               = input.int         (5                            ,'Box→Box'                         ,inline='00'       ,group=bx_set, minval=0, maxval=80, tooltip=tt_kb_gap)
box_padding_pct      = input.float       (3.0                          ,'Box padding %'                   ,inline='01'       ,group=bx_set, minval=0.0, maxval=20.0, step=0.5, tooltip=tt_padding)
lbl_chart_size       = input.string      ('Small'                      ,'Label [Chart|Box]'               ,inline='02'       ,group=bx_set, options=['Tiny', 'Small', 'Normal', 'Large'])
lbl_box_size         = input.string      ('Tiny'                       ,''                                ,inline='02'       ,group=bx_set, options=['Tiny', 'Small', 'Normal', 'Large'], tooltip=tt_label)
orb_preset           = input.string      ('15'                         ,'Opening Range [min]'             ,inline='03'       ,group=bx_set, options=['5', '15', '30', 'Custom'], tooltip=tt_orb_len)
orb_custom           = input.int         (15                           ,''                                ,inline='03'       ,group=bx_set, minval=1, maxval=240)

sb_width             = input.int         (10                           ,'Box [Width|Border|BG]'           ,inline='00'       ,group=sb_set, minval=4, maxval=80)
sb_col_border        = input.color       (color.new(color.white, 50) ,''                                ,inline='00'       ,group=sb_set)
sb_col_bg            = input.color       (color.new(color.gray, 80)  ,''                                ,inline='00'       ,group=sb_set)
kb_width             = input.int         (10                           ,'Box [Width|Border|BG]'           ,inline='00'       ,group=kb_set, minval=4, maxval=80)
kb_col_border        = input.color       (color.new(color.white, 50) ,''                                ,inline='00'       ,group=kb_set)
kb_col_bg            = input.color       (color.new(color.gray, 80)  ,''                                ,inline='00'       ,group=kb_set)
kb_extend            = input.bool        (false                        ,'Extend lines left'               ,inline='04'       ,group=kb_set, tooltip=tt_kb_extend)
kb_tf1_on            = input.bool        (true                         ,'TF1 ..........................'  ,inline='10'       ,group=kb_set)
kb_col_tf1           = input.color       (#ffaa00                    ,''                                ,inline='10'       ,group=kb_set, tooltip=tt_kb_tf)
kb_tf1               = input.timeframe   ('60'                         ,''                                ,inline='10'       ,group=kb_set)
kb_tf2_on            = input.bool        (true                         ,'TF2 ..........................'  ,inline='12'       ,group=kb_set)
kb_col_tf2           = input.color       (#cc66ff                    ,''                                ,inline='12'       ,group=kb_set, tooltip=tt_kb_tf)
kb_tf2               = input.timeframe   ('240'                        ,''                                ,inline='12'       ,group=kb_set)

kb_d_on              = input.bool        (true                         ,'Daily H/L .................'     ,inline='14'       ,group=kb_set)
kb_col_d             = input.color       (#ffffff                      ,''                                ,inline='14'       ,group=kb_set, tooltip=tt_kb_cur)

kb_w_on              = input.bool        (false                        ,'Weekly H/L ..............'       ,inline='16'       ,group=kb_set)
kb_col_w             = input.color       (#ffcc33                      ,''                                ,inline='16'       ,group=kb_set, tooltip=tt_kb_cur)

kb_pd_on             = input.bool        (true                         ,'Prev Day H/L ............'       ,inline='20'       ,group=kb_set)
kb_col_pd            = input.color       (#ff4444                      ,''                                ,inline='20'       ,group=kb_set, tooltip=tt_prev)
kb_pd_ch             = input.bool        (false                        ,'Chart'                           ,inline='20'       ,group=kb_set)

kb_pw_on             = input.bool        (false                        ,'Prev Week H/L .........'         ,inline='22'       ,group=kb_set)
kb_col_pw            = input.color       (#ff00e8                      ,''                                ,inline='22'       ,group=kb_set, tooltip=tt_prev)
kb_pw_ch             = input.bool        (false                        ,'Chart'                           ,inline='22'       ,group=kb_set)

kb_pm_on             = input.bool        (false                        ,'Prev Month H/L ........'         ,inline='24'       ,group=kb_set)
kb_col_pm            = input.color       (#00ffcc                      ,''                                ,inline='24'       ,group=kb_set, tooltip=tt_prev)
kb_pm_ch             = input.bool        (false                        ,'Chart'                           ,inline='24'       ,group=kb_set)

kb_nyo_on            = input.bool        (true                         ,'NY 8:30 Open ..........'        ,inline='30'       ,group=kb_set)
kb_col_nyo           = input.color       (#99ff00                      ,''                                ,inline='30'       ,group=kb_set, tooltip=tt_nyo)

kb_do_on             = input.bool        (true                         ,'Daily Open ................'     ,inline='32'       ,group=kb_set)
kb_col_do            = input.color       (#ffffff                      ,''                                ,inline='32'       ,group=kb_set, tooltip=tt_open)
kb_do_ch             = input.bool        (false                        ,'Chart'                           ,inline='32'       ,group=kb_set)

kb_wo_on             = input.bool        (false                        ,'Weekly Open ............'        ,inline='34'       ,group=kb_set)
kb_col_wo            = input.color       (#ffcc33                      ,''                                ,inline='34'       ,group=kb_set, tooltip=tt_open)
kb_wo_ch             = input.bool        (false                        ,'Chart'                           ,inline='34'       ,group=kb_set)

kb_mo_on             = input.bool        (true                         ,'NY Midnight Open ....'           ,inline='36'       ,group=kb_set)
kb_col_mo            = input.color       (#ff9900                      ,''                                ,inline='36'       ,group=kb_set, tooltip=tt_mo)
kb_mo_ch             = input.bool        (false                        ,'Chart'                           ,inline='36'       ,group=kb_set)


kb_line_style        = input.string      ('⎯⎯⎯'                      ,'Lines [Style|Width]'             ,inline='40'       ,group=kb_set, options=['⎯⎯⎯','----','····'])
kb_line_width        = input.int         (2                            ,''                                ,inline='40'       ,group=kb_set, minval=1, maxval=5)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    [SS] SESSION CHART — layout, history, labels (shared by AS / LO / NY)
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
sess_layout          = input.string      ('Box'                        ,'Chart layout'                    ,inline='00'       ,group=ss_set, options=['Lines', 'Box'], tooltip=tt_sess_layout)
sess_keep            = input.int         (15                           ,'History (max 20)'                ,inline='00'       ,group=ss_set, minval=1, maxval=20, tooltip=tt_sess_keep)
sess_lbl_size        = input.string      ('Small'                      ,'Chart label size'                ,inline='02'       ,group=ss_set, options=['Tiny', 'Small', 'Normal', 'Large'], tooltip=tt_sess_lbl)
sess_orb_lbl         = input.bool        (true                         ,'Opening Range labels'            ,inline='02'       ,group=ss_set, tooltip=tt_orb_lbl)

//+---    [AS] [LO] [NY] SESSIONS
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
//+--- ASIAN SESSION (Tokyo 09:00–18:00 Asia/Tokyo = 00:00–09:00 UTC)
as_session           = input.session     ('0900-1800'                  ,'Session'                         ,inline='00'       ,group=as_set, tooltip='Window in the session timezone below. Default 09:00–18:00 Asia/Tokyo (Tokyo forex session).')
as_tz                = input.string      ('Asia/Tokyo'                 ,'Timezone'                        ,inline='01'       ,group=as_set, options=[TZ_SYS,'Asia/Tokyo','Asia/Singapore','Asia/Hong_Kong','Australia/Sydney','Europe/London','Europe/Berlin',TZ_NY,'America/Chicago','UTC','Exchange'], tooltip=tt_sess_tz)
as_current           = input.bool        (true                         ,'Current session only'            ,inline='02'       ,group=as_set, tooltip=tt_sess_cur)
as_box               = input.bool        (true                        ,'Display [←Box|Chart→]'           ,inline='04'       ,group=as_set)
as_chart             = input.bool        (false                         ,''                                ,inline='04'       ,group=as_set, tooltip=tt_sess_disp)
as_o_on              = input.bool        (true                         ,'Open'                            ,inline='05'       ,group=as_set)
as_c_on              = input.bool        (true                         ,'Close'                           ,inline='05'       ,group=as_set)
as_h_on              = input.bool        (true                         ,'High'                            ,inline='05'       ,group=as_set)
as_l_on              = input.bool        (true                         ,'Low'                             ,inline='05'       ,group=as_set)
as_eq_on             = input.bool        (false                        ,'Equilibrium'                     ,inline='05'       ,group=as_set, tooltip=tt_eq)
as_orb               = input.bool        (false                        ,'Opening Range'                   ,inline='07'       ,group=as_set, tooltip=tt_orb)
as_col_chart         = input.color       (#ff0066                    ,'Chart lines '                    ,inline='06'       ,group=as_set)
as_sty_chart         = input.string      ('⎯⎯⎯'                      ,''                                ,inline='06'       ,group=as_set, options=['⎯⎯⎯','----','····'])
as_wid_chart         = input.int         (1                            ,''                                ,inline='06'       ,group=as_set, minval=1, maxval=5, tooltip=tt_lines)
as_col_box           = input.color       (#ff0066                    ,'Box lines   '                    ,inline='08'       ,group=as_set)
as_sty_box           = input.string      ('⎯⎯⎯'                      ,''                                ,inline='08'       ,group=as_set, options=['⎯⎯⎯','----','····'])
as_wid_box           = input.int         (2                            ,''                                ,inline='08'       ,group=as_set, minval=1, maxval=5, tooltip=tt_lines)
as_bx_frame          = input.color       (color.new(#ff0066, 40)     ,'Chart box  '                     ,inline='09'       ,group=as_set)
as_bx_sty            = input.string      ('····'                       ,''                                ,inline='09'       ,group=as_set, options=['⎯⎯⎯','----','····'])
as_bx_fill           = input.color       (color.new(#ff0066, 88)     ,''                                ,inline='09'       ,group=as_set, tooltip=tt_sess_bx)

//+--- LONDON SESSION (08:00–16:30 Europe/London = LSE cash hours)
ls_session           = input.session     ('0800-1630'                  ,'Session'                         ,inline='00'       ,group=ls_set, tooltip='Window in the session timezone below. Default 08:00–16:30 Europe/London (LSE cash hours).')
ls_tz                = input.string      ('Europe/London'              ,'Timezone'                        ,inline='01'       ,group=ls_set, options=[TZ_SYS,'Asia/Tokyo','Asia/Singapore','Asia/Hong_Kong','Australia/Sydney','Europe/London','Europe/Berlin',TZ_NY,'America/Chicago','UTC','Exchange'], tooltip=tt_sess_tz)
ls_current           = input.bool        (true                         ,'Current session only'            ,inline='02'       ,group=ls_set, tooltip=tt_sess_cur)
ls_box               = input.bool        (true                         ,'Display [←Box|Chart→]'             ,inline='04'       ,group=ls_set)
ls_chart             = input.bool        (false                        ,''                                ,inline='04'       ,group=ls_set, tooltip=tt_sess_disp)
ls_o_on              = input.bool        (true                         ,'Open'                            ,inline='05'       ,group=ls_set)
ls_c_on              = input.bool        (true                         ,'Close'                           ,inline='05'       ,group=ls_set)
ls_h_on              = input.bool        (true                         ,'High'                            ,inline='05'       ,group=ls_set)
ls_l_on              = input.bool        (true                         ,'Low'                             ,inline='05'       ,group=ls_set)
ls_eq_on             = input.bool        (false                        ,'Equilibrium'                     ,inline='05'       ,group=ls_set, tooltip=tt_eq)
ls_orb               = input.bool        (false                        ,'Opening Range'                   ,inline='07'       ,group=ls_set, tooltip=tt_orb)
ls_col_chart         = input.color       (#00bfff                    ,'Chart lines '                    ,inline='06'       ,group=ls_set)
ls_sty_chart         = input.string      ('⎯⎯⎯'                      ,''                                ,inline='06'       ,group=ls_set, options=['⎯⎯⎯','----','····'])
ls_wid_chart         = input.int         (1                            ,''                                ,inline='06'       ,group=ls_set, minval=1, maxval=5, tooltip=tt_lines)
ls_col_box           = input.color       (#00bfff                    ,'Box lines   '                    ,inline='08'       ,group=ls_set)
ls_sty_box           = input.string      ('⎯⎯⎯'                      ,''                                ,inline='08'       ,group=ls_set, options=['⎯⎯⎯','----','····'])
ls_wid_box           = input.int         (2                            ,''                                ,inline='08'       ,group=ls_set, minval=1, maxval=5, tooltip=tt_lines)
ls_bx_frame          = input.color       (color.new(#00bfff, 40)     ,'Chart box  '                     ,inline='09'       ,group=ls_set)
ls_bx_sty            = input.string      ('····'                       ,''                                ,inline='09'       ,group=ls_set, options=['⎯⎯⎯','----','····'])
ls_bx_fill           = input.color       (color.new(#00bfff, 88)     ,''                                ,inline='09'       ,group=ls_set, tooltip=tt_sess_bx)

//+--- NEW YORK SESSION (09:30–16:00 America/New_York = NYSE cash hours)
ny_session           = input.session     ('0930-1600'                  ,'Session'                         ,inline='00'       ,group=ny_set, tooltip=tt_ny_sess)
ny_tz                = input.string      (TZ_NY                        ,'Timezone'                        ,inline='01'       ,group=ny_set, options=[TZ_SYS,'Asia/Tokyo','Asia/Singapore','Asia/Hong_Kong','Australia/Sydney','Europe/London','Europe/Berlin',TZ_NY,'America/Chicago','UTC','Exchange'], tooltip=tt_sess_tz)
ny_current           = input.bool        (false                         ,'Current session only'            ,inline='02'       ,group=ny_set, tooltip=tt_sess_cur + '\n\nOutside NY hours the last completed NY session stays (e.g. during London: yesterday\'s NYH/NYL as key levels).')
ny_box               = input.bool        (true                         ,'Display [←Box|Chart→]'           ,inline='04'       ,group=ny_set)
ny_chart             = input.bool        (false                        ,''                                ,inline='04'       ,group=ny_set, tooltip=tt_sess_disp)
ny_o_on              = input.bool        (true                         ,'Open'                            ,inline='05'       ,group=ny_set)
ny_c_on              = input.bool        (true                         ,'Close'                           ,inline='05'       ,group=ny_set)
ny_h_on              = input.bool        (true                         ,'High'                            ,inline='05'       ,group=ny_set)
ny_l_on              = input.bool        (true                         ,'Low'                             ,inline='05'       ,group=ny_set)
ny_eq_on             = input.bool        (false                        ,'Equilibrium'                     ,inline='05'       ,group=ny_set, tooltip=tt_eq)
ny_orb               = input.bool        (false                        ,'Opening Range'                   ,inline='07'       ,group=ny_set, tooltip=tt_orb)
ny_col_chart         = input.color       (#99ff00                    ,'Chart lines '                    ,inline='06'       ,group=ny_set)
ny_sty_chart         = input.string      ('⎯⎯⎯'                      ,''                                ,inline='06'       ,group=ny_set, options=['⎯⎯⎯','----','····'])
ny_wid_chart         = input.int         (1                            ,''                                ,inline='06'       ,group=ny_set, minval=1, maxval=5, tooltip=tt_lines)
ny_col_box           = input.color       (#99ff00                    ,'Box lines   '                    ,inline='08'       ,group=ny_set)
ny_sty_box           = input.string      ('⎯⎯⎯'                      ,''                                ,inline='08'       ,group=ny_set, options=['⎯⎯⎯','----','····'])
ny_wid_box           = input.int         (2                            ,''                                ,inline='08'       ,group=ny_set, minval=1, maxval=5, tooltip=tt_lines)
ny_bx_frame          = input.color       (color.new(#99ff00, 40)     ,'Chart box  '                     ,inline='09'       ,group=ny_set)
ny_bx_sty            = input.string      ('····'                       ,''                                ,inline='09'       ,group=ny_set, options=['⎯⎯⎯','----','····'])
ny_bx_fill           = input.color       (color.new(#99ff00, 88)     ,''                                ,inline='09'       ,group=ny_set, tooltip=tt_sess_bx)



//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    [ZN] TIME ZONES — up to 5 windows, Killzone (levels) or Avoid (hint)
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
// Windows in zn_tz. Defaults = ICT Killzones in New York time: London 02:00–05:00, NY AM 08:30–11:00, Lunch 12:00–13:00, NY PM 13:30–16:00, Asia 20:00–00:00.
zn_tz                = input.string      (TZ_NY                        ,'Timezone'                        ,inline='00'       ,group=zn_set, options=[TZ_SYS,'Asia/Tokyo','Asia/Singapore','Asia/Hong_Kong','Australia/Sydney','Europe/London','Europe/Berlin',TZ_NY,'America/Chicago','UTC','Exchange'], tooltip=tt_zn_tz)
zn_cur               = input.bool        (true                         ,'Current day only'                ,inline='02'       ,group=zn_set, tooltip=tt_zn_cur)
zn_levels            = input.bool        (false                        ,'Killzone H/L in Session Box'     ,inline='04'       ,group=zn_set, tooltip=tt_zn_lv)
z1_on                = input.bool        (false                        ,'1 '                              ,inline='10'       ,group=zn_set)
z1_name              = input.string      ('London KZ'                  ,''                                ,inline='10'       ,group=zn_set)
z1_col               = input.color       (color.new(#00bfff, 90)       ,''                                ,inline='10'       ,group=zn_set)
z1_sess              = input.session     ('0200-0500'                  ,'Window'                          ,inline='11'       ,group=zn_set)
z1_type              = input.string      ('Killzone'                   ,''                                ,inline='11'       ,group=zn_set, options=['Killzone', 'Avoid'], tooltip=tt_zn)
z2_on                = input.bool        (false                        ,'2 '                              ,inline='12'       ,group=zn_set)
z2_name              = input.string      ('NY AM KZ'                   ,''                                ,inline='12'       ,group=zn_set)
z2_col               = input.color       (color.new(#99ff00, 90)       ,''                                ,inline='12'       ,group=zn_set)
z2_sess              = input.session     ('0830-1100'                  ,'Window'                          ,inline='13'       ,group=zn_set)
z2_type              = input.string      ('Killzone'                   ,''                                ,inline='13'       ,group=zn_set, options=['Killzone', 'Avoid'], tooltip=tt_zn)
z3_on                = input.bool        (false                        ,'3 '                              ,inline='14'       ,group=zn_set)
z3_name              = input.string      ('NY Lunch'                   ,''                                ,inline='14'       ,group=zn_set)
z3_col               = input.color       (color.new(#808080, 88)       ,''                                ,inline='14'       ,group=zn_set)
z3_sess              = input.session     ('1200-1300'                  ,'Window'                          ,inline='15'       ,group=zn_set)
z3_type              = input.string      ('Avoid'                      ,''                                ,inline='15'       ,group=zn_set, options=['Killzone', 'Avoid'], tooltip=tt_zn)
z4_on                = input.bool        (false                        ,'4 '                              ,inline='16'       ,group=zn_set)
z4_name              = input.string      ('NY PM KZ'                   ,''                                ,inline='16'       ,group=zn_set)
z4_col               = input.color       (color.new(#ffaa00, 90)       ,''                                ,inline='16'       ,group=zn_set)
z4_sess              = input.session     ('1330-1600'                  ,'Window'                          ,inline='17'       ,group=zn_set)
z4_type              = input.string      ('Killzone'                   ,''                                ,inline='17'       ,group=zn_set, options=['Killzone', 'Avoid'], tooltip=tt_zn)
z5_on                = input.bool        (false                        ,'5 '                              ,inline='18'       ,group=zn_set)
z5_name              = input.string      ('Asia KZ'                    ,''                                ,inline='18'       ,group=zn_set)
z5_col               = input.color       (color.new(#ff0066, 90)       ,''                                ,inline='18'       ,group=zn_set)
z5_sess              = input.session     ('2000-0000'                  ,'Window'                          ,inline='19'       ,group=zn_set)
z5_type              = input.string      ('Killzone'                   ,''                                ,inline='19'       ,group=zn_set, options=['Killzone', 'Avoid'], tooltip=tt_zn)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    [AL] ALERTS
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
al_sb                = input.bool        (false                        ,'Level touch [Session|Key]'       ,inline='00'       ,group=al_set)
al_kb                = input.bool        (false                        ,''                                ,inline='00'       ,group=al_set, tooltip=tt_al)
al_orb               = input.bool        (false                        ,'Opening Range break'             ,inline='02'       ,group=al_set, tooltip=tt_al_orb)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    CALC — sessions, opening range, HTF levels, opens, zones
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
sz_chart             = f_getSize(lbl_chart_size)
sz_box               = f_getSize(lbl_box_size)
sz_sess              = f_getSize(sess_lbl_size)
kb_sty               = f_getLinestyle(kb_line_style)
as_csty              = f_getLinestyle(as_sty_chart)
ls_csty              = f_getLinestyle(ls_sty_chart)
ny_csty              = f_getLinestyle(ny_sty_chart)
as_bsty              = f_getLinestyle(as_sty_box)
ls_bsty              = f_getLinestyle(ls_sty_box)
ny_bsty              = f_getLinestyle(ny_sty_box)
as_bxsty             = f_getLinestyle(as_bx_sty)
ls_bxsty             = f_getLinestyle(ls_bx_sty)
ny_bxsty             = f_getLinestyle(ny_bx_sty)
atr14                = ta.atr(14)
auto_buf             = auto_unit == 'ATR' ? nz(atr14) * auto_val : close * auto_val * 0.01

// Timezones: each session in its own market zone, zones in NY — or the System zone when the picker says so
as_tz_use            = f_tz(as_tz, tz_use)
ls_tz_use            = f_tz(ls_tz, tz_use)
ny_tz_use            = f_tz(ny_tz, tz_use)
zn_tz_use            = f_tz(zn_tz, tz_use)

// Sessions on the chart timeframe; on charts ≥ 1H the O/H/L/C come from a single 60-min request
use_60_tf            = timeframe.in_seconds() >= 3600
[as_in, as_start, as_end, as_o_ltf, as_c_ltf, as_h_ltf, as_l_ltf] = f_sess_pack(as_session, as_tz_use)
[ls_in, ls_start, ls_end, ls_o_ltf, ls_c_ltf, ls_h_ltf, ls_l_ltf] = f_sess_pack(ls_session, ls_tz_use)
[ny_in, ny_start, ny_end, ny_o_ltf, ny_c_ltf, ny_h_ltf, ny_l_ltf] = f_sess_pack(ny_session, ny_tz_use)
[as_o_60, as_c_60, as_h_60, as_l_60, ls_o_60, ls_c_60, ls_h_60, ls_l_60, ny_o_60, ny_c_60, ny_h_60, ny_l_60] = request.security(syminfo.tickerid, '60', f_sess_pack3(as_session, as_tz_use, ls_session, ls_tz_use, ny_session, ny_tz_use), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
as_o                 = use_60_tf ? as_o_60 : as_o_ltf
as_c                 = use_60_tf ? as_c_60 : as_c_ltf
as_h                 = use_60_tf ? as_h_60 : as_h_ltf
as_l                 = use_60_tf ? as_l_60 : as_l_ltf
ls_o                 = use_60_tf ? ls_o_60 : ls_o_ltf
ls_c                 = use_60_tf ? ls_c_60 : ls_c_ltf
ls_h                 = use_60_tf ? ls_h_60 : ls_h_ltf
ls_l                 = use_60_tf ? ls_l_60 : ls_l_ltf
ny_o                 = use_60_tf ? ny_o_60 : ny_o_ltf
ny_c                 = use_60_tf ? ny_c_60 : ny_c_ltf
ny_h                 = use_60_tf ? ny_h_60 : ny_h_ltf
ny_l                 = use_60_tf ? ny_l_60 : ny_l_ltf
as_eq                = (as_h + as_l) / 2.0
ls_eq                = (ls_h + ls_l) / 2.0
ny_eq                = (ny_h + ny_l) / 2.0

// Opening Range
orb_mins             = orb_preset == 'Custom' ? orb_custom : int(str.tonumber(orb_preset))
orb_ms               = orb_mins * 60 * 1000
orb_tf_ok            = timeframe.in_seconds() <= orb_mins * 60
[as_orh, as_orl, as_or_t0, as_or_t1, as_or_t2] = f_orb_run(as_start, as_in, orb_ms)
[ls_orh, ls_orl, ls_or_t0, ls_or_t1, ls_or_t2] = f_orb_run(ls_start, ls_in, orb_ms)
[ny_orh, ny_orl, ny_or_t0, ny_or_t1, ny_or_t2] = f_orb_run(ny_start, ny_in, orb_ms)
as_or_ok             = as_orb and orb_tf_ok and not na(as_orh) and not na(as_orl)
ls_or_ok             = ls_orb and orb_tf_ok and not na(ls_orh) and not na(ls_orl)
ny_or_ok             = ny_orb and orb_tf_ok and not na(ny_orh) and not na(ny_orl)

// HTF levels: [current H, current L, current Open, previous H, previous L]
[tf1_h, tf1_l, _, _, _]   = f_getHTF(kb_tf1)
[tf2_h, tf2_l, _, _, _]   = f_getHTF(kb_tf2)
[cd_h, cd_l, d_o, pd_h, pd_l] = f_getHTF('D')
[cw_h, cw_l, w_o, pw_h, pw_l] = f_getHTF('W')
[_, _, _, pm_h, pm_l]     = f_getHTF('M')
pd_eq                = (pd_h + pd_l) / 2.0
pw_eq                = (pw_h + pw_l) / 2.0
pm_eq                = (pm_h + pm_l) / 2.0
tf1_lbl              = f_tf_short(kb_tf1)
tf2_lbl              = f_tf_short(kb_tf2)

// NY Midnight Open: open of the first bar of a new New York calendar day (fixed America/New_York, intraday only)
ny_dom               = dayofmonth(time, TZ_NY)
ny_day_new           = ny_dom != nz(ny_dom[1], ny_dom)
mo_new               = timeframe.isintraday and ny_day_new
var float mo_px      = na
var int   mo_bar     = na
if mo_new
	mo_px := open
	mo_bar := time

// NY 08:30 Open: first bar at or after 08:30 America/New_York (fixed zone, independent of the NY session window)
ny_mod               = hour(time, TZ_NY) * 60 + minute(time, TZ_NY)
nyo_new              = timeframe.isintraday and ny_mod >= 510 and (nz(ny_mod[1], 0) < 510 or ny_day_new)
var float nyo_px     = na
var int   nyo_bar    = na
if nyo_new
	nyo_px := open
	nyo_bar := time

// Origin times for Keylevels "Extend lines left" (print that created the level)
bool tf1_new = timeframe.change(kb_tf1)
bool tf2_new = timeframe.change(kb_tf2)
bool d_new   = timeframe.change('D')
bool w_new   = timeframe.change('W')
bool m_new   = timeframe.change('M')
var float tf1_rh = na
var float tf1_rl = na
var int   tf1_hb = na
var int   tf1_lb = na
if tf1_new or na(tf1_rh)
	tf1_rh := high
	tf1_rl := low
	tf1_hb := time
	tf1_lb := time
else
	if high >= tf1_rh
		tf1_rh := high
		tf1_hb := time
	if low <= tf1_rl
		tf1_rl := low
		tf1_lb := time
var float tf2_rh = na
var float tf2_rl = na
var int   tf2_hb = na
var int   tf2_lb = na
if tf2_new or na(tf2_rh)
	tf2_rh := high
	tf2_rl := low
	tf2_hb := time
	tf2_lb := time
else
	if high >= tf2_rh
		tf2_rh := high
		tf2_hb := time
	if low <= tf2_rl
		tf2_rl := low
		tf2_lb := time
var float d_rh = na
var float d_rl = na
var int   d_hb = na
var int   d_lb = na
var int   d_ob = na
var int   pd_hb = na
var int   pd_lb = na
if d_new
	pd_hb := d_hb
	pd_lb := d_lb
	d_ob := time
if d_new or na(d_rh)
	d_rh := high
	d_rl := low
	d_hb := time
	d_lb := time
else
	if high >= d_rh
		d_rh := high
		d_hb := time
	if low <= d_rl
		d_rl := low
		d_lb := time
var float w_rh = na
var float w_rl = na
var int   w_hb = na
var int   w_lb = na
var int   w_ob = na
var int   pw_hb = na
var int   pw_lb = na
if w_new
	pw_hb := w_hb
	pw_lb := w_lb
	w_ob := time
if w_new or na(w_rh)
	w_rh := high
	w_rl := low
	w_hb := time
	w_lb := time
else
	if high >= w_rh
		w_rh := high
		w_hb := time
	if low <= w_rl
		w_rl := low
		w_lb := time
var float m_rh = na
var float m_rl = na
var int   m_hb = na
var int   m_lb = na
var int   pm_hb = na
var int   pm_lb = na
if m_new
	pm_hb := m_hb
	pm_lb := m_lb
if m_new or na(m_rh)
	m_rh := high
	m_rl := low
	m_hb := time
	m_lb := time
else
	if high >= m_rh
		m_rh := high
		m_hb := time
	if low <= m_rl
		m_rl := low
		m_lb := time


// Keylevels Box flags (top level — also used by the alerts)
kb_tf1_ok            = kb_tf1_on and not na(tf1_h) and not na(tf1_l)
kb_tf2_ok            = kb_tf2_on and not na(tf2_h) and not na(tf2_l)
kb_d_ok              = kb_d_on   and not na(cd_h)  and not na(cd_l)
kb_w_ok              = kb_w_on   and not na(cw_h)  and not na(cw_l)
kb_pd_ok             = kb_pd_on  and not na(pd_h)  and not na(pd_l)
kb_pw_ok             = kb_pw_on  and not na(pw_h)  and not na(pw_l)
kb_pm_ok             = kb_pm_on  and not na(pm_h)  and not na(pm_l)
kb_nyo_ok            = kb_nyo_on and not na(nyo_px)
kb_do_ok             = kb_do_on  and not na(d_o)
kb_wo_ok             = kb_wo_on  and not na(w_o)
kb_mo_ok             = kb_mo_on  and not na(mo_px)

// Time zones (every bar): boxes on the chart, H/L for the Session Box
[z1_in, z1_h, z1_l]  = f_zone(show_zn and z1_on, z1_sess, zn_tz_use, z1_name, z1_col, z1_type == 'Killzone', zn_cur, sz_chart, sys_font)
[z2_in, z2_h, z2_l]  = f_zone(show_zn and z2_on, z2_sess, zn_tz_use, z2_name, z2_col, z2_type == 'Killzone', zn_cur, sz_chart, sys_font)
[z3_in, z3_h, z3_l]  = f_zone(show_zn and z3_on, z3_sess, zn_tz_use, z3_name, z3_col, z3_type == 'Killzone', zn_cur, sz_chart, sys_font)
[z4_in, z4_h, z4_l]  = f_zone(show_zn and z4_on, z4_sess, zn_tz_use, z4_name, z4_col, z4_type == 'Killzone', zn_cur, sz_chart, sys_font)
[z5_in, z5_h, z5_l]  = f_zone(show_zn and z5_on, z5_sess, zn_tz_use, z5_name, z5_col, z5_type == 'Killzone', zn_cur, sz_chart, sys_font)
kz1_ok               = show_zn and zn_levels and z1_on and z1_type == 'Killzone' and not na(z1_h)
kz2_ok               = show_zn and zn_levels and z2_on and z2_type == 'Killzone' and not na(z2_h)
kz3_ok               = show_zn and zn_levels and z3_on and z3_type == 'Killzone' and not na(z3_h)
kz4_ok               = show_zn and zn_levels and z4_on and z4_type == 'Killzone' and not na(z4_h)
kz5_ok               = show_zn and zn_levels and z5_on and z5_type == 'Killzone' and not na(z5_h)
color av_col         = f_av(show_zn and z1_on, z1_in, z1_type, z1_col)
av_col              := na(av_col) ? f_av(show_zn and z2_on, z2_in, z2_type, z2_col) : av_col
av_col              := na(av_col) ? f_av(show_zn and z3_on, z3_in, z3_type, z3_col) : av_col
av_col              := na(av_col) ? f_av(show_zn and z4_on, z4_in, z4_type, z4_col) : av_col
av_col              := na(av_col) ? f_av(show_zn and z5_on, z5_in, z5_type, z5_col) : av_col


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    CHART — session lines (every bar)
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
f_sess_chart(as_chart, as_start, as_in, as_end, as_current, as_o, as_c, as_h, as_l, as_col_chart, as_csty, as_wid_chart, 'AS', sz_sess, sys_font, sess_keep, sess_layout, as_bx_frame, as_bx_fill, as_bxsty)
f_sess_chart(ls_chart, ls_start, ls_in, ls_end, ls_current, ls_o, ls_c, ls_h, ls_l, ls_col_chart, ls_csty, ls_wid_chart, 'LO', sz_sess, sys_font, sess_keep, sess_layout, ls_bx_frame, ls_bx_fill, ls_bxsty)
f_sess_chart(ny_chart, ny_start, ny_in, ny_end, ny_current, ny_o, ny_c, ny_h, ny_l, ny_col_chart, ny_csty, ny_wid_chart, 'NY', sz_sess, sys_font, sess_keep, sess_layout, ny_bx_frame, ny_bx_fill, ny_bxsty)
f_orb_chart(as_or_ok, as_start, as_in, as_orh, as_orl, as_or_t0, as_or_t1, as_or_t2, as_col_chart, as_wid_chart, 'AS', sz_sess, sys_font, sess_keep, as_current, sess_orb_lbl)
f_orb_chart(ls_or_ok, ls_start, ls_in, ls_orh, ls_orl, ls_or_t0, ls_or_t1, ls_or_t2, ls_col_chart, ls_wid_chart, 'LO', sz_sess, sys_font, sess_keep, ls_current, sess_orb_lbl)
f_orb_chart(ny_or_ok, ny_start, ny_in, ny_orh, ny_orl, ny_or_t0, ny_or_t1, ny_or_t2, ny_col_chart, ny_wid_chart, 'NY', sz_sess, sys_font, sess_keep, ny_current, sess_orb_lbl)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ALERTS — level touch (dynamic message) and Opening Range break (every bar)
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
as_use               = as_box or as_chart
ls_use               = ls_box or ls_chart
ny_use               = ny_box or ny_chart
string sb_msg        = ''
sb_msg              := f_tch(sb_msg, as_use and as_o_on,  as_o,   'AS Open')
sb_msg              := f_tch(sb_msg, as_use and as_c_on,  as_c,   'AS Close')
sb_msg              := f_tch(sb_msg, as_use and as_h_on,  as_h,   'AS High')
sb_msg              := f_tch(sb_msg, as_use and as_l_on,  as_l,   'AS Low')
sb_msg              := f_tch(sb_msg, as_use and as_eq_on, as_eq,  'AS EQ')
sb_msg              := f_tch(sb_msg, as_use and as_or_ok, as_orh, 'AS OR High')
sb_msg              := f_tch(sb_msg, as_use and as_or_ok, as_orl, 'AS OR Low')
sb_msg              := f_tch(sb_msg, ls_use and ls_o_on,  ls_o,   'LO Open')
sb_msg              := f_tch(sb_msg, ls_use and ls_c_on,  ls_c,   'LO Close')
sb_msg              := f_tch(sb_msg, ls_use and ls_h_on,  ls_h,   'LO High')
sb_msg              := f_tch(sb_msg, ls_use and ls_l_on,  ls_l,   'LO Low')
sb_msg              := f_tch(sb_msg, ls_use and ls_eq_on, ls_eq,  'LO EQ')
sb_msg              := f_tch(sb_msg, ls_use and ls_or_ok, ls_orh, 'LO OR High')
sb_msg              := f_tch(sb_msg, ls_use and ls_or_ok, ls_orl, 'LO OR Low')
sb_msg              := f_tch(sb_msg, ny_use and ny_o_on,  ny_o,   'NY Open')
sb_msg              := f_tch(sb_msg, ny_use and ny_c_on,  ny_c,   'NY Close')
sb_msg              := f_tch(sb_msg, ny_use and ny_h_on,  ny_h,   'NY High')
sb_msg              := f_tch(sb_msg, ny_use and ny_l_on,  ny_l,   'NY Low')
sb_msg              := f_tch(sb_msg, ny_use and ny_eq_on, ny_eq,  'NY EQ')
sb_msg              := f_tch(sb_msg, ny_use and ny_or_ok, ny_orh, 'NY OR High')
sb_msg              := f_tch(sb_msg, ny_use and ny_or_ok, ny_orl, 'NY OR Low')
sb_msg              := f_tch(sb_msg, kz1_ok, z1_h, z1_name + ' High')
sb_msg              := f_tch(sb_msg, kz1_ok, z1_l, z1_name + ' Low')
sb_msg              := f_tch(sb_msg, kz2_ok, z2_h, z2_name + ' High')
sb_msg              := f_tch(sb_msg, kz2_ok, z2_l, z2_name + ' Low')
sb_msg              := f_tch(sb_msg, kz3_ok, z3_h, z3_name + ' High')
sb_msg              := f_tch(sb_msg, kz3_ok, z3_l, z3_name + ' Low')
sb_msg              := f_tch(sb_msg, kz4_ok, z4_h, z4_name + ' High')
sb_msg              := f_tch(sb_msg, kz4_ok, z4_l, z4_name + ' Low')
sb_msg              := f_tch(sb_msg, kz5_ok, z5_h, z5_name + ' High')
sb_msg              := f_tch(sb_msg, kz5_ok, z5_l, z5_name + ' Low')
string kb_msg        = ''
kb_msg              := f_tch(kb_msg, kb_tf1_ok, tf1_h, tf1_lbl + ' High')
kb_msg              := f_tch(kb_msg, kb_tf1_ok, tf1_l, tf1_lbl + ' Low')
kb_msg              := f_tch(kb_msg, kb_tf2_ok, tf2_h, tf2_lbl + ' High')
kb_msg              := f_tch(kb_msg, kb_tf2_ok, tf2_l, tf2_lbl + ' Low')
kb_msg              := f_tch(kb_msg, kb_d_ok,   cd_h,  'D High')
kb_msg              := f_tch(kb_msg, kb_d_ok,   cd_l,  'D Low')
kb_msg              := f_tch(kb_msg, kb_w_ok,   cw_h,  'W High')
kb_msg              := f_tch(kb_msg, kb_w_ok,   cw_l,  'W Low')
kb_msg              := f_tch(kb_msg, kb_pd_ok,  pd_h,  'PDH')
kb_msg              := f_tch(kb_msg, kb_pd_ok,  pd_l,  'PDL')
kb_msg              := f_tch(kb_msg, kb_pw_ok,  pw_h,  'PWH')
kb_msg              := f_tch(kb_msg, kb_pw_ok,  pw_l,  'PWL')
kb_msg              := f_tch(kb_msg, kb_pm_ok,  pm_h,  'PMH')
kb_msg              := f_tch(kb_msg, kb_pm_ok,  pm_l,  'PML')
kb_msg              := f_tch(kb_msg, kb_nyo_ok, nyo_px, 'NY 8:30')
kb_msg              := f_tch(kb_msg, kb_do_ok,  d_o,   'D Open')
kb_msg              := f_tch(kb_msg, kb_wo_ok,  w_o,   'W Open')
kb_msg              := f_tch(kb_msg, kb_mo_ok,  mo_px, 'NY 00:00')
[as_bu, as_bd]       = f_orb_brk(as_or_ok, as_in, as_or_t1, as_orh, as_orl)
[ls_bu, ls_bd]       = f_orb_brk(ls_or_ok, ls_in, ls_or_t1, ls_orh, ls_orl)
[ny_bu, ny_bd]       = f_orb_brk(ny_or_ok, ny_in, ny_or_t1, ny_orh, ny_orl)
orb_up               = as_bu or ls_bu or ny_bu
orb_dn               = as_bd or ls_bd or ny_bd
string orb_msg       = as_bu ? 'AS ORB Break Up' : as_bd ? 'AS ORB Break Down' : ''
orb_msg             := orb_msg + (ls_bu ? (orb_msg == '' ? '' : ', ') + 'LO ORB Break Up' : ls_bd ? (orb_msg == '' ? '' : ', ') + 'LO ORB Break Down' : '')
orb_msg             := orb_msg + (ny_bu ? (orb_msg == '' ? '' : ', ') + 'NY ORB Break Up' : ny_bd ? (orb_msg == '' ? '' : ', ') + 'NY ORB Break Down' : '')
string al_px         = ' @ ' + str.tostring(close, format.mintick)
if al_sb and sb_msg != ''
	alert(syminfo.ticker + ' · Session level touch: ' + sb_msg + al_px, alert.freq_once_per_bar)
if al_kb and kb_msg != ''
	alert(syminfo.ticker + ' · Key level touch: ' + kb_msg + al_px, alert.freq_once_per_bar)
if al_orb and orb_msg != ''
	alert(syminfo.ticker + ' · ' + orb_msg + al_px, alert.freq_once_per_bar_close)
alertcondition(sb_msg != '', 'Session level touched', 'KEYLEVELS: session level touched')
alertcondition(kb_msg != '', 'Key level touched',     'KEYLEVELS: key level touched')
alertcondition(orb_up,       'ORB Break Up',          'KEYLEVELS: Opening Range break up')
alertcondition(orb_dn,       'ORB Break Down',        'KEYLEVELS: Opening Range break down')


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    LAST BAR — opening range window, session box, keylevels box, auto lines
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
if barstate.islast
	//==> [SB] Session Box — labels left of the box
	int sb_x1 = bar_index + box_offset
	int sb_x2 = sb_x1 + sb_width
	[as_hi, as_lo] = f_sess_ext(as_box, as_o_on, as_c_on, as_h_on, as_l_on, as_eq_on, as_or_ok, as_o, as_c, as_h, as_l, as_orh, as_orl)
	[ls_hi, ls_lo] = f_sess_ext(ls_box, ls_o_on, ls_c_on, ls_h_on, ls_l_on, ls_eq_on, ls_or_ok, ls_o, ls_c, ls_h, ls_l, ls_orh, ls_orl)
	[ny_hi, ny_lo] = f_sess_ext(ny_box, ny_o_on, ny_c_on, ny_h_on, ny_l_on, ny_eq_on, ny_or_ok, ny_o, ny_c, ny_h, ny_l, ny_orh, ny_orl)
	float sb_hi = f_nmax(f_nmax(as_hi, ls_hi), ny_hi)
	float sb_lo = f_nmin(f_nmin(as_lo, ls_lo), ny_lo)
	if kz1_ok
		sb_hi := f_nmax(sb_hi, z1_h)
		sb_lo := f_nmin(sb_lo, z1_l)
	if kz2_ok
		sb_hi := f_nmax(sb_hi, z2_h)
		sb_lo := f_nmin(sb_lo, z2_l)
	if kz3_ok
		sb_hi := f_nmax(sb_hi, z3_h)
		sb_lo := f_nmin(sb_lo, z3_l)
	if kz4_ok
		sb_hi := f_nmax(sb_hi, z4_h)
		sb_lo := f_nmin(sb_lo, z4_l)
	if kz5_ok
		sb_hi := f_nmax(sb_hi, z5_h)
		sb_lo := f_nmin(sb_lo, z5_l)
	bool  sb_draw = show_sb and not na(sb_hi)
	float sb_pad = math.max(sb_hi - sb_lo, syminfo.mintick) * (box_padding_pct / 100.0)
	color sb_bc  = na(av_col) ? sb_col_border : av_col
	var box sb_box = na
	sb_box := f_box(sb_box, sb_draw, sb_x1, sb_hi + sb_pad, sb_x2, sb_lo - sb_pad, sb_bc, sb_col_bg, xloc.bar_index)
	// Killzone High / Low (dotted, zone color)
	var LVL sb_z1h = LVL.new()
	var LVL sb_z1l = LVL.new()
	var LVL sb_z2h = LVL.new()
	var LVL sb_z2l = LVL.new()
	var LVL sb_z3h = LVL.new()
	var LVL sb_z3l = LVL.new()
	var LVL sb_z4h = LVL.new()
	var LVL sb_z4l = LVL.new()
	var LVL sb_z5h = LVL.new()
	var LVL sb_z5l = LVL.new()
	f_lvl(sb_z1h, sb_draw and kz1_ok, z1_h, sb_x1, sb_x2, color.new(z1_col, 0), line.style_dotted, 2, false, z1_name + ' High', sz_box, sys_font, false)
	f_lvl(sb_z1l, sb_draw and kz1_ok, z1_l, sb_x1, sb_x2, color.new(z1_col, 0), line.style_dotted, 2, false, z1_name + ' Low',  sz_box, sys_font, false)
	f_lvl(sb_z2h, sb_draw and kz2_ok, z2_h, sb_x1, sb_x2, color.new(z2_col, 0), line.style_dotted, 2, false, z2_name + ' High', sz_box, sys_font, false)
	f_lvl(sb_z2l, sb_draw and kz2_ok, z2_l, sb_x1, sb_x2, color.new(z2_col, 0), line.style_dotted, 2, false, z2_name + ' Low',  sz_box, sys_font, false)
	f_lvl(sb_z3h, sb_draw and kz3_ok, z3_h, sb_x1, sb_x2, color.new(z3_col, 0), line.style_dotted, 2, false, z3_name + ' High', sz_box, sys_font, false)
	f_lvl(sb_z3l, sb_draw and kz3_ok, z3_l, sb_x1, sb_x2, color.new(z3_col, 0), line.style_dotted, 2, false, z3_name + ' Low',  sz_box, sys_font, false)
	f_lvl(sb_z4h, sb_draw and kz4_ok, z4_h, sb_x1, sb_x2, color.new(z4_col, 0), line.style_dotted, 2, false, z4_name + ' High', sz_box, sys_font, false)
	f_lvl(sb_z4l, sb_draw and kz4_ok, z4_l, sb_x1, sb_x2, color.new(z4_col, 0), line.style_dotted, 2, false, z4_name + ' Low',  sz_box, sys_font, false)
	f_lvl(sb_z5h, sb_draw and kz5_ok, z5_h, sb_x1, sb_x2, color.new(z5_col, 0), line.style_dotted, 2, false, z5_name + ' High', sz_box, sys_font, false)
	f_lvl(sb_z5l, sb_draw and kz5_ok, z5_l, sb_x1, sb_x2, color.new(z5_col, 0), line.style_dotted, 2, false, z5_name + ' Low',  sz_box, sys_font, false)
	bool sb_as = sb_draw and as_box
	bool sb_ls = sb_draw and ls_box
	bool sb_ny = sb_draw and ny_box
	var LVL sb_as_o   = LVL.new()
	var LVL sb_as_c   = LVL.new()
	var LVL sb_as_h   = LVL.new()
	var LVL sb_as_l   = LVL.new()
	var LVL sb_as_eq  = LVL.new()
	var LVL sb_as_orh = LVL.new()
	var LVL sb_as_orl = LVL.new()
	var LVL sb_ls_o   = LVL.new()
	var LVL sb_ls_c   = LVL.new()
	var LVL sb_ls_h   = LVL.new()
	var LVL sb_ls_l   = LVL.new()
	var LVL sb_ls_eq  = LVL.new()
	var LVL sb_ls_orh = LVL.new()
	var LVL sb_ls_orl = LVL.new()
	var LVL sb_ny_o   = LVL.new()
	var LVL sb_ny_c   = LVL.new()
	var LVL sb_ny_h   = LVL.new()
	var LVL sb_ny_l   = LVL.new()
	var LVL sb_ny_eq  = LVL.new()
	var LVL sb_ny_orh = LVL.new()
	var LVL sb_ny_orl = LVL.new()
	f_lvl(sb_as_o,   sb_as and as_o_on,  as_o,   sb_x1, sb_x2, as_col_box, as_bsty, as_wid_box, false, 'AS Open',    sz_box, sys_font, false)
	f_lvl(sb_as_c,   sb_as and as_c_on,  as_c,   sb_x1, sb_x2, as_col_box, as_bsty, as_wid_box, false, 'AS Close',   sz_box, sys_font, false)
	f_lvl(sb_as_h,   sb_as and as_h_on,  as_h,   sb_x1, sb_x2, as_col_box, as_bsty, as_wid_box, false, 'AS High',    sz_box, sys_font, false)
	f_lvl(sb_as_l,   sb_as and as_l_on,  as_l,   sb_x1, sb_x2, as_col_box, as_bsty, as_wid_box, false, 'AS Low',     sz_box, sys_font, false)
	f_lvl(sb_as_eq,  sb_as and as_eq_on, as_eq,  sb_x1, sb_x2, as_col_box, as_bsty, as_wid_box, false, 'AS EQ',      sz_box, sys_font, false)
	f_lvl(sb_as_orh, sb_as and as_or_ok, as_orh, sb_x1, sb_x2, as_col_box, line.style_dashed, as_wid_box, false, 'AS OR High', sz_box, sys_font, false)
	f_lvl(sb_as_orl, sb_as and as_or_ok, as_orl, sb_x1, sb_x2, as_col_box, line.style_dashed, as_wid_box, false, 'AS OR Low',  sz_box, sys_font, false)
	f_lvl(sb_ls_o,   sb_ls and ls_o_on,  ls_o,   sb_x1, sb_x2, ls_col_box, ls_bsty, ls_wid_box, false, 'LO Open',    sz_box, sys_font, false)
	f_lvl(sb_ls_c,   sb_ls and ls_c_on,  ls_c,   sb_x1, sb_x2, ls_col_box, ls_bsty, ls_wid_box, false, 'LO Close',   sz_box, sys_font, false)
	f_lvl(sb_ls_h,   sb_ls and ls_h_on,  ls_h,   sb_x1, sb_x2, ls_col_box, ls_bsty, ls_wid_box, false, 'LO High',    sz_box, sys_font, false)
	f_lvl(sb_ls_l,   sb_ls and ls_l_on,  ls_l,   sb_x1, sb_x2, ls_col_box, ls_bsty, ls_wid_box, false, 'LO Low',     sz_box, sys_font, false)
	f_lvl(sb_ls_eq,  sb_ls and ls_eq_on, ls_eq,  sb_x1, sb_x2, ls_col_box, ls_bsty, ls_wid_box, false, 'LO EQ',      sz_box, sys_font, false)
	f_lvl(sb_ls_orh, sb_ls and ls_or_ok, ls_orh, sb_x1, sb_x2, ls_col_box, line.style_dashed, ls_wid_box, false, 'LO OR High', sz_box, sys_font, false)
	f_lvl(sb_ls_orl, sb_ls and ls_or_ok, ls_orl, sb_x1, sb_x2, ls_col_box, line.style_dashed, ls_wid_box, false, 'LO OR Low',  sz_box, sys_font, false)
	f_lvl(sb_ny_o,   sb_ny and ny_o_on,  ny_o,   sb_x1, sb_x2, ny_col_box, ny_bsty, ny_wid_box, false, 'NY Open',    sz_box, sys_font, false)
	f_lvl(sb_ny_c,   sb_ny and ny_c_on,  ny_c,   sb_x1, sb_x2, ny_col_box, ny_bsty, ny_wid_box, false, 'NY Close',   sz_box, sys_font, false)
	f_lvl(sb_ny_h,   sb_ny and ny_h_on,  ny_h,   sb_x1, sb_x2, ny_col_box, ny_bsty, ny_wid_box, false, 'NY High',    sz_box, sys_font, false)
	f_lvl(sb_ny_l,   sb_ny and ny_l_on,  ny_l,   sb_x1, sb_x2, ny_col_box, ny_bsty, ny_wid_box, false, 'NY Low',     sz_box, sys_font, false)
	f_lvl(sb_ny_eq,  sb_ny and ny_eq_on, ny_eq,  sb_x1, sb_x2, ny_col_box, ny_bsty, ny_wid_box, false, 'NY EQ',      sz_box, sys_font, false)
	f_lvl(sb_ny_orh, sb_ny and ny_or_ok, ny_orh, sb_x1, sb_x2, ny_col_box, line.style_dashed, ny_wid_box, false, 'NY OR High', sz_box, sys_font, false)
	f_lvl(sb_ny_orl, sb_ny and ny_or_ok, ny_orl, sb_x1, sb_x2, ny_col_box, line.style_dashed, ny_wid_box, false, 'NY OR Low',  sz_box, sys_font, false)
	array<label> sb_lbs = array.new<label>()
	array<float> sb_pxs = array.new<float>()
	f_lb_push(sb_lbs, sb_pxs, sb_as_o.lb,   as_o)
	f_lb_push(sb_lbs, sb_pxs, sb_as_c.lb,   as_c)
	f_lb_push(sb_lbs, sb_pxs, sb_as_h.lb,   as_h)
	f_lb_push(sb_lbs, sb_pxs, sb_as_l.lb,   as_l)
	f_lb_push(sb_lbs, sb_pxs, sb_as_eq.lb,  as_eq)
	f_lb_push(sb_lbs, sb_pxs, sb_as_orh.lb, as_orh)
	f_lb_push(sb_lbs, sb_pxs, sb_as_orl.lb, as_orl)
	f_lb_push(sb_lbs, sb_pxs, sb_ls_o.lb,   ls_o)
	f_lb_push(sb_lbs, sb_pxs, sb_ls_c.lb,   ls_c)
	f_lb_push(sb_lbs, sb_pxs, sb_ls_h.lb,   ls_h)
	f_lb_push(sb_lbs, sb_pxs, sb_ls_l.lb,   ls_l)
	f_lb_push(sb_lbs, sb_pxs, sb_ls_eq.lb,  ls_eq)
	f_lb_push(sb_lbs, sb_pxs, sb_ls_orh.lb, ls_orh)
	f_lb_push(sb_lbs, sb_pxs, sb_ls_orl.lb, ls_orl)
	f_lb_push(sb_lbs, sb_pxs, sb_ny_o.lb,   ny_o)
	f_lb_push(sb_lbs, sb_pxs, sb_ny_c.lb,   ny_c)
	f_lb_push(sb_lbs, sb_pxs, sb_ny_h.lb,   ny_h)
	f_lb_push(sb_lbs, sb_pxs, sb_ny_l.lb,   ny_l)
	f_lb_push(sb_lbs, sb_pxs, sb_ny_eq.lb,  ny_eq)
	f_lb_push(sb_lbs, sb_pxs, sb_ny_orh.lb, ny_orh)
	f_lb_push(sb_lbs, sb_pxs, sb_ny_orl.lb, ny_orl)
	f_lb_push(sb_lbs, sb_pxs, sb_z1h.lb, z1_h)
	f_lb_push(sb_lbs, sb_pxs, sb_z1l.lb, z1_l)
	f_lb_push(sb_lbs, sb_pxs, sb_z2h.lb, z2_h)
	f_lb_push(sb_lbs, sb_pxs, sb_z2l.lb, z2_l)
	f_lb_push(sb_lbs, sb_pxs, sb_z3h.lb, z3_h)
	f_lb_push(sb_lbs, sb_pxs, sb_z3l.lb, z3_l)
	f_lb_push(sb_lbs, sb_pxs, sb_z4h.lb, z4_h)
	f_lb_push(sb_lbs, sb_pxs, sb_z4l.lb, z4_l)
	f_lb_push(sb_lbs, sb_pxs, sb_z5h.lb, z5_h)
	f_lb_push(sb_lbs, sb_pxs, sb_z5l.lb, z5_l)
	f_slot_in(sb_lbs, sb_pxs, sb_x1, math.max(6, int(math.round(sb_width / 5.0))), f_slot_sep(lbl_box_size, atr14), 3, -1)

	//==> [KB] Keylevels Box — labels right of the box
	int kb_x1 = sb_draw ? sb_x2 + kb_gap : sb_x1
	int kb_x2 = kb_x1 + kb_width
	float kb_hi = na
	float kb_lo = na
	if kb_tf1_ok
		kb_hi := f_nmax(kb_hi, tf1_h)
		kb_lo := f_nmin(kb_lo, tf1_l)
	if kb_tf2_ok
		kb_hi := f_nmax(kb_hi, tf2_h)
		kb_lo := f_nmin(kb_lo, tf2_l)
	if kb_d_ok
		kb_hi := f_nmax(kb_hi, cd_h)
		kb_lo := f_nmin(kb_lo, cd_l)
	if kb_w_ok
		kb_hi := f_nmax(kb_hi, cw_h)
		kb_lo := f_nmin(kb_lo, cw_l)
	if kb_pd_ok
		kb_hi := f_nmax(kb_hi, pd_h)
		kb_lo := f_nmin(kb_lo, pd_l)
	if kb_pw_ok
		kb_hi := f_nmax(kb_hi, pw_h)
		kb_lo := f_nmin(kb_lo, pw_l)
	if kb_pm_ok
		kb_hi := f_nmax(kb_hi, pm_h)
		kb_lo := f_nmin(kb_lo, pm_l)
	if kb_nyo_ok
		kb_hi := f_nmax(kb_hi, nyo_px)
		kb_lo := f_nmin(kb_lo, nyo_px)
	if kb_do_ok
		kb_hi := f_nmax(kb_hi, d_o)
		kb_lo := f_nmin(kb_lo, d_o)
	if kb_wo_ok
		kb_hi := f_nmax(kb_hi, w_o)
		kb_lo := f_nmin(kb_lo, w_o)
	if kb_mo_ok
		kb_hi := f_nmax(kb_hi, mo_px)
		kb_lo := f_nmin(kb_lo, mo_px)
	bool  kb_draw = show_kb and not na(kb_hi)
	float kb_pad  = math.max(kb_hi - kb_lo, syminfo.mintick) * (box_padding_pct / 100.0)
	var box kb_box = na
	kb_box := f_box(kb_box, kb_draw, kb_x1, kb_hi + kb_pad, kb_x2, kb_lo - kb_pad, kb_col_border, kb_col_bg, xloc.bar_index)
	var LVL kb_tf1h = LVL.new()
	var LVL kb_tf1l = LVL.new()
	var LVL kb_tf2h = LVL.new()
	var LVL kb_tf2l = LVL.new()
	var LVL kb_dh   = LVL.new()
	var LVL kb_dl   = LVL.new()
	var LVL kb_wh   = LVL.new()
	var LVL kb_wl   = LVL.new()
	var LVL kb_pdh  = LVL.new()
	var LVL kb_pdl  = LVL.new()
	var LVL kb_pwh  = LVL.new()
	var LVL kb_pwl  = LVL.new()
	var LVL kb_pmh  = LVL.new()
	var LVL kb_pml  = LVL.new()
	var LVL kb_nyo  = LVL.new()
	var LVL kb_do   = LVL.new()
	var LVL kb_wo   = LVL.new()
	var LVL kb_mo   = LVL.new()
	f_lvl(kb_tf1h, kb_draw and kb_tf1_ok, tf1_h, kb_x1, kb_x2, kb_col_tf1, kb_sty, kb_line_width, kb_extend, tf1_lbl + ' High', sz_box, sys_font, true, tf1_hb)
	f_lvl(kb_tf1l, kb_draw and kb_tf1_ok, tf1_l, kb_x1, kb_x2, kb_col_tf1, kb_sty, kb_line_width, kb_extend, tf1_lbl + ' Low',  sz_box, sys_font, true, tf1_lb)
	f_lvl(kb_tf2h, kb_draw and kb_tf2_ok, tf2_h, kb_x1, kb_x2, kb_col_tf2, kb_sty, kb_line_width, kb_extend, tf2_lbl + ' High', sz_box, sys_font, true, tf2_hb)
	f_lvl(kb_tf2l, kb_draw and kb_tf2_ok, tf2_l, kb_x1, kb_x2, kb_col_tf2, kb_sty, kb_line_width, kb_extend, tf2_lbl + ' Low',  sz_box, sys_font, true, tf2_lb)
	f_lvl(kb_dh,   kb_draw and kb_d_ok,   cd_h,  kb_x1, kb_x2, kb_col_d,   kb_sty, kb_line_width, kb_extend, 'D High',  sz_box, sys_font, true, d_hb)
	f_lvl(kb_dl,   kb_draw and kb_d_ok,   cd_l,  kb_x1, kb_x2, kb_col_d,   kb_sty, kb_line_width, kb_extend, 'D Low',   sz_box, sys_font, true, d_lb)
	f_lvl(kb_wh,   kb_draw and kb_w_ok,   cw_h,  kb_x1, kb_x2, kb_col_w,   kb_sty, kb_line_width, kb_extend, 'W High',  sz_box, sys_font, true, w_hb)
	f_lvl(kb_wl,   kb_draw and kb_w_ok,   cw_l,  kb_x1, kb_x2, kb_col_w,   kb_sty, kb_line_width, kb_extend, 'W Low',   sz_box, sys_font, true, w_lb)
	f_lvl(kb_pdh,  kb_draw and kb_pd_ok,  pd_h,  kb_x1, kb_x2, kb_col_pd,  kb_sty, kb_line_width, kb_extend, 'PDH',     sz_box, sys_font, true, pd_hb)
	f_lvl(kb_pdl,  kb_draw and kb_pd_ok,  pd_l,  kb_x1, kb_x2, kb_col_pd,  kb_sty, kb_line_width, kb_extend, 'PDL',     sz_box, sys_font, true, pd_lb)
	f_lvl(kb_pwh,  kb_draw and kb_pw_ok,  pw_h,  kb_x1, kb_x2, kb_col_pw,  kb_sty, kb_line_width, kb_extend, 'PWH',     sz_box, sys_font, true, pw_hb)
	f_lvl(kb_pwl,  kb_draw and kb_pw_ok,  pw_l,  kb_x1, kb_x2, kb_col_pw,  kb_sty, kb_line_width, kb_extend, 'PWL',     sz_box, sys_font, true, pw_lb)
	f_lvl(kb_pmh,  kb_draw and kb_pm_ok,  pm_h,  kb_x1, kb_x2, kb_col_pm,  kb_sty, kb_line_width, kb_extend, 'PMH',     sz_box, sys_font, true, pm_hb)
	f_lvl(kb_pml,  kb_draw and kb_pm_ok,  pm_l,  kb_x1, kb_x2, kb_col_pm,  kb_sty, kb_line_width, kb_extend, 'PML',     sz_box, sys_font, true, pm_lb)
	f_lvl(kb_nyo,  kb_draw and kb_nyo_ok, nyo_px, kb_x1, kb_x2, kb_col_nyo, kb_sty, kb_line_width, kb_extend, 'NY 8:30', sz_box, sys_font, true, nyo_bar)
	f_lvl(kb_do,   kb_draw and kb_do_ok,  d_o,   kb_x1, kb_x2, kb_col_do,  kb_sty, kb_line_width, kb_extend, 'D Open',  sz_box, sys_font, true, d_ob)
	f_lvl(kb_wo,   kb_draw and kb_wo_ok,  w_o,   kb_x1, kb_x2, kb_col_wo,  kb_sty, kb_line_width, kb_extend, 'W Open',  sz_box, sys_font, true, w_ob)
	f_lvl(kb_mo,   kb_draw and kb_mo_ok,  mo_px, kb_x1, kb_x2, kb_col_mo,  kb_sty, kb_line_width, kb_extend, 'NY 00:00', sz_box, sys_font, true, mo_bar)
	array<label> kb_lbs = array.new<label>()
	array<float> kb_pxs = array.new<float>()
	f_lb_push(kb_lbs, kb_pxs, kb_tf1h.lb, tf1_h)
	f_lb_push(kb_lbs, kb_pxs, kb_tf1l.lb, tf1_l)
	f_lb_push(kb_lbs, kb_pxs, kb_tf2h.lb, tf2_h)
	f_lb_push(kb_lbs, kb_pxs, kb_tf2l.lb, tf2_l)
	f_lb_push(kb_lbs, kb_pxs, kb_dh.lb,   cd_h)
	f_lb_push(kb_lbs, kb_pxs, kb_dl.lb,   cd_l)
	f_lb_push(kb_lbs, kb_pxs, kb_wh.lb,   cw_h)
	f_lb_push(kb_lbs, kb_pxs, kb_wl.lb,   cw_l)
	f_lb_push(kb_lbs, kb_pxs, kb_pdh.lb,  pd_h)
	f_lb_push(kb_lbs, kb_pxs, kb_pdl.lb,  pd_l)
	f_lb_push(kb_lbs, kb_pxs, kb_pwh.lb,  pw_h)
	f_lb_push(kb_lbs, kb_pxs, kb_pwl.lb,  pw_l)
	f_lb_push(kb_lbs, kb_pxs, kb_pmh.lb,  pm_h)
	f_lb_push(kb_lbs, kb_pxs, kb_pml.lb,  pm_l)
	f_lb_push(kb_lbs, kb_pxs, kb_nyo.lb,  nyo_px)
	f_lb_push(kb_lbs, kb_pxs, kb_do.lb,   d_o)
	f_lb_push(kb_lbs, kb_pxs, kb_wo.lb,   w_o)
	f_lb_push(kb_lbs, kb_pxs, kb_mo.lb,   mo_px)
	f_slot_in(kb_lbs, kb_pxs, kb_x2, math.max(6, int(math.round(kb_width / 5.0))), f_slot_sep(lbl_box_size, atr14), 3, 1)

	//==> [AUTO] proximity lines: only for levels that have no chart line of their own
	var array<line> au = array.new<line>()
	for ln in au
		line.delete(ln)
	array.clear(au)
	bool auto_kb = show_auto and not kb_extend
	int  auto_x2 = kb_draw ? kb_x2 : sb_x1
	f_auto(au, auto_kb and kb_tf1_ok and f_px_near(tf1_h, auto_buf), tf1_h, auto_x2, kb_col_tf1)
	f_auto(au, auto_kb and kb_tf1_ok and f_px_near(tf1_l, auto_buf), tf1_l, auto_x2, kb_col_tf1)
	f_auto(au, auto_kb and kb_tf2_ok and f_px_near(tf2_h, auto_buf), tf2_h, auto_x2, kb_col_tf2)
	f_auto(au, auto_kb and kb_tf2_ok and f_px_near(tf2_l, auto_buf), tf2_l, auto_x2, kb_col_tf2)
	f_auto(au, auto_kb and kb_d_ok   and f_px_near(cd_h, auto_buf),  cd_h,  auto_x2, kb_col_d)
	f_auto(au, auto_kb and kb_d_ok   and f_px_near(cd_l, auto_buf),  cd_l,  auto_x2, kb_col_d)
	f_auto(au, auto_kb and kb_w_ok   and f_px_near(cw_h, auto_buf),  cw_h,  auto_x2, kb_col_w)
	f_auto(au, auto_kb and kb_w_ok   and f_px_near(cw_l, auto_buf),  cw_l,  auto_x2, kb_col_w)
	f_auto(au, auto_kb and kb_nyo_ok and f_px_near(nyo_px, auto_buf), nyo_px, auto_x2, kb_col_nyo)
	f_auto(au, auto_kb and kb_pd_ok and not kb_pd_ch and f_px_near(pd_h, auto_buf), pd_h, auto_x2, kb_col_pd)
	f_auto(au, auto_kb and kb_pd_ok and not kb_pd_ch and f_px_near(pd_l, auto_buf), pd_l, auto_x2, kb_col_pd)
	f_auto(au, auto_kb and kb_pw_ok and not kb_pw_ch and f_px_near(pw_h, auto_buf), pw_h, auto_x2, kb_col_pw)
	f_auto(au, auto_kb and kb_pw_ok and not kb_pw_ch and f_px_near(pw_l, auto_buf), pw_l, auto_x2, kb_col_pw)
	f_auto(au, auto_kb and kb_pm_ok and not kb_pm_ch and f_px_near(pm_h, auto_buf), pm_h, auto_x2, kb_col_pm)
	f_auto(au, auto_kb and kb_pm_ok and not kb_pm_ch and f_px_near(pm_l, auto_buf), pm_l, auto_x2, kb_col_pm)
	f_auto(au, auto_kb and kb_do_ok and not kb_do_ch and f_px_near(d_o, auto_buf),   d_o,   auto_x2, kb_col_do)
	f_auto(au, auto_kb and kb_wo_ok and not kb_wo_ch and f_px_near(w_o, auto_buf),   w_o,   auto_x2, kb_col_wo)
	f_auto(au, auto_kb and kb_mo_ok and not kb_mo_ch and f_px_near(mo_px, auto_buf), mo_px, auto_x2, kb_col_mo)
	f_auto(au, show_auto and sb_as and not as_chart and f_px_near(as_o, auto_buf), as_o, sb_x1, as_col_box)
	f_auto(au, show_auto and sb_as and not as_chart and f_px_near(as_c, auto_buf), as_c, sb_x1, as_col_box)
	f_auto(au, show_auto and sb_as and not as_chart and f_px_near(as_h, auto_buf), as_h, sb_x1, as_col_box)
	f_auto(au, show_auto and sb_as and not as_chart and f_px_near(as_l, auto_buf), as_l, sb_x1, as_col_box)
	f_auto(au, show_auto and sb_ls and not ls_chart and f_px_near(ls_o, auto_buf), ls_o, sb_x1, ls_col_box)
	f_auto(au, show_auto and sb_ls and not ls_chart and f_px_near(ls_c, auto_buf), ls_c, sb_x1, ls_col_box)
	f_auto(au, show_auto and sb_ls and not ls_chart and f_px_near(ls_h, auto_buf), ls_h, sb_x1, ls_col_box)
	f_auto(au, show_auto and sb_ls and not ls_chart and f_px_near(ls_l, auto_buf), ls_l, sb_x1, ls_col_box)
	f_auto(au, show_auto and sb_ny and not ny_chart and f_px_near(ny_o, auto_buf), ny_o, sb_x1, ny_col_box)
	f_auto(au, show_auto and sb_ny and not ny_chart and f_px_near(ny_c, auto_buf), ny_c, sb_x1, ny_col_box)
	f_auto(au, show_auto and sb_ny and not ny_chart and f_px_near(ny_h, auto_buf), ny_h, sb_x1, ny_col_box)
	f_auto(au, show_auto and sb_ny and not ny_chart and f_px_near(ny_l, auto_buf), ny_l, sb_x1, ny_col_box)

	//==> [CH] Keylevels on the chart: current PD/PW/PM/Open from origin print to last candle (same price as the box)
	var line ch_pdh = na
	var line ch_pdl = na
	var line ch_pde = na
	var line ch_pwh = na
	var line ch_pwl = na
	var line ch_pwe = na
	var line ch_pmh = na
	var line ch_pml = na
	var line ch_pme = na
	var line ch_do  = na
	var line ch_wo  = na
	var line ch_mo  = na
	int t_now = time
	ch_pdh := f_ln(ch_pdh, kb_pd_ch and not na(pd_h),  pd_h,  f_ch_t(pd_hb, d_ob), t_now, kb_col_pd, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_pdl := f_ln(ch_pdl, kb_pd_ch and not na(pd_l),  pd_l,  f_ch_t(pd_lb, d_ob), t_now, kb_col_pd, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_pde := f_ln(ch_pde, kb_pd_ch and not na(pd_eq), pd_eq, f_eq_t(pd_hb, pd_lb, d_ob), t_now, color.new(kb_col_pd, 50), kb_sty, 1, false, xloc.bar_time)
	ch_pwh := f_ln(ch_pwh, kb_pw_ch and not na(pw_h),  pw_h,  f_ch_t(pw_hb, w_ob), t_now, kb_col_pw, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_pwl := f_ln(ch_pwl, kb_pw_ch and not na(pw_l),  pw_l,  f_ch_t(pw_lb, w_ob), t_now, kb_col_pw, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_pwe := f_ln(ch_pwe, kb_pw_ch and not na(pw_eq), pw_eq, f_eq_t(pw_hb, pw_lb, w_ob), t_now, color.new(kb_col_pw, 50), kb_sty, 1, false, xloc.bar_time)
	ch_pmh := f_ln(ch_pmh, kb_pm_ch and not na(pm_h),  pm_h,  f_ch_t(pm_hb, na), t_now, kb_col_pm, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_pml := f_ln(ch_pml, kb_pm_ch and not na(pm_l),  pm_l,  f_ch_t(pm_lb, na), t_now, kb_col_pm, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_pme := f_ln(ch_pme, kb_pm_ch and not na(pm_eq), pm_eq, f_eq_t(pm_hb, pm_lb, na), t_now, color.new(kb_col_pm, 50), kb_sty, 1, false, xloc.bar_time)
	ch_do  := f_ln(ch_do,  kb_do_ch and not na(d_o),   d_o,   f_ch_t(d_ob, na), t_now, kb_col_do, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_wo  := f_ln(ch_wo,  kb_wo_ch and not na(w_o),   w_o,   f_ch_t(w_ob, na), t_now, kb_col_wo, kb_sty, kb_line_width, false, xloc.bar_time)
	ch_mo  := f_ln(ch_mo,  kb_mo_ch and not na(mo_px), mo_px, f_ch_t(mo_bar, na), t_now, kb_col_mo, kb_sty, kb_line_width, false, xloc.bar_time)
````
