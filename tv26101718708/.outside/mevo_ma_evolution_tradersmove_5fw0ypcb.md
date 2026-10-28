# MEVO - MA EVOLUTION [TradersMove]

- url: https://www.tradingview.com/script/5fW0yPcb/
- type: indicator
- pine_id: PUB;9efe0db586f24da6b4f40b3595c1250a
- version: 2.0

## Description

[b]Think Moving Averages don't work anymore? Think again. Here is how to turn standard MAs into a powerful trading framework.[/b]

[b]MEVO - MA EVOLUTION[/b] is an open-source [b]moving-average ensemble[/b] for TradingView. It is not a single MA with extra cosmetics. It is a full MA workbench: a two-line Impulse / Lead cloud, a Momentum line, a MainTrend line, session VWAP, higher-timeframe copies of the cloud, and three AND-based Trenders that turn those layers into a readable regime filter.

If you already think in moving averages — crossover, stack, slope, price vs MA, VWAP — MEVO puts every serious MA type, every common colour rule, and a multi-timeframe engine on one overlay. One indicator instead of a pile of copies.

This is the first public version ([b]v01[/b]). Defaults are a starting point, not a finished strategy. Read the paint, Trender and confluence sections before you trade from the colours.

Pine Script v6 · overlay · standalone (no library import) · Mozilla Public License 2.0.


[b]WHAT YOU SEE ON THE CHART[/b]

Four layers, each with a job:

[list]
[*] [b]Impulse (IM)[/b] — the fast MA. Reacts first. Default factory preset is EHMA 20.
[*] [b]Lead (LE)[/b] — the slow MA of the pair. Holds the structure. Default EHMA 28.
[/list]

Together they form the [b]cloud[/b]: fill between Impulse and Lead on the chart timeframe, and a second fill between Impulse HTF and Lead HTF. Layout can be [b]Band[/b] (filled cloud) or [b]Lines[/b] (classic MA overlay).

[list]
[*] [b]Momentum (MO)[/b] — the swing MA. Default EMA 50, with its own timeframe picker (chart / HTF 1 / HTF 2). This is the “is the move still alive?” line. Presets never overwrite it.
[*] [b]MainTrend (MT)[/b] — the regime MA. Default EMA 150, also with its own timeframe picker. This is the “which side of the market am I on?” line. Presets never overwrite it.
[*] [b]VWAP[/b] — session VWAP as its own module, not as an MA type in the dropdown. Volume-weighted fair value for the session. Default colour rule is price vs VWAP.
[/list]

Turn layers on and off in [b]Display[/b]. BarColor can paint candles from the theme or from Trender 1 / 2 / 3. [b]Trender 1 is on by default[/b] (top of the pane). Trender 2 (bottom) and Trender 3 (background tint only) stay off until you turn them on.


[b]WHY THIS IS DIFFERENT[/b]

Most MA indicators give you one formula and one colour mode. MEVO is built as a [b]compendium[/b]:

[b]1. Fourteen moving-average types, one engine.[/b]
EMA, SMA, SMMA (RMA), DEMA, TMA, WMA, VWMA, ZLEMA, TEMA, HMA, EHMA, THMA, T3, HEMA.

Notable formulas, so you know what you are selecting:
[list]
[*] [b]DEMA[/b] — 2·EMA − EMA(EMA). Faster than EMA, less lag, still an EMA-family line.
[*] [b]ZLEMA[/b] — Ehlers zero-lag EMA: the source is de-lagged by (length−1)/2 before the EMA. This is not a renamed DEMA.
[*] [b]HMA / EHMA / THMA[/b] — Hull family (WMA-based HMA, EMA-based EHMA, Triangular Hull). Fast ribbons without the usual SMA smear.
[*] [b]T3[/b] — Tillson T3 (GD cascade, alpha 0.7). Very smooth, still responsive.
[*] [b]HEMA[/b] — EMA on Heikin Ashi open, computed inside the function so higher-timeframe HEMA sees HTF OHLC, not a chart-level HA series.
[*] [b]VWMA[/b] — volume-weighted MA (window), distinct from session VWAP.
[/list]

Every line (Impulse, Lead, Momentum, MainTrend, and the HTF cloud pair) can use a different type and length. Mix EHMA cloud with EMA Momentum and SMA MainTrend if that is your language. The engine is inlined — the script does not depend on a hidden library.

[b]2. Paint is a rule, not a palette.[/b]
Colour [i]theme[/i] (Theme / Manual / Mono) is separate from [i]paint[/i] (how bull / bear / neither is decided). That sounds small. It is the feature that makes the rest of the indicator consistent.

Lines and VWAP:
[list]
[*] [b]Slope[/b] (default on MAs) — rising vs falling. Classic MA colouring.
[*] [b]Price[/b] (default on VWAP) — close above vs below the line.
[*] [b]Uni[/b] — one colour, no direction.
[/list]

Cloud fill (Impulse vs Lead, and the HTF pair):
[list]
[*] [b]Slope[/b] (default) — both lines rising / both falling. Same idea as CLOUDS “Direction”. Mixed slopes go [b]neutral[/b].
[*] [b]Stack[/b] — Impulse above / below Lead. Same idea as CLOUDS “Position”.
[*] [b]Price[/b] — close above [b]both[/b] lines / below [b]both[/b]. In between: neutral.
[*] [b]Uni[/b] — one fill colour (theme Neutral).
[/list]

The Trender uses [b]the same paint rule[/b] as the line it is reading. If Impulse is on Price, Trender Impulse is “close vs Impulse”, not slope. [b]If a source is Uni, it never vetoes the AND (the checkbox stays on, the vote is skipped). Uni is a visual placeholder, not a silent short.[/b]

This split — palette vs rule — is what most MA packs get wrong. They mix “make it green” with “what does green mean?”. In MEVO those are two different questions.

[b]3. Factory presets plus three user slots.[/b]
P1–P14 are factory Impulse / Lead pairs (type + length). They do [b]not[/b] touch Momentum or MainTrend.
[list]
[*] P8 (default) — EHMA 20 / 28
[*] P1 — SMA 50 / 200 (Golden Cross)
[*] P6 — EMA 8 / 21
[*] P7 — EMA 9 / VWMA 20 (price vs volume)
[*] P12 — RMA 14 / EMA 50
[*] P13 — EHMA 20 / THMA 50 (Hull mix)
[*] P14 — HEMA 5 / 21 (Heikin Ashi EMA)
[*] plus MACD EMA 12/26, swing EMA 20/50, SMA 20/50, HMA 9/21, ZLEMA 13/34, DEMA 9/21, T3 8/21
[/list]

[b]U1, U2, U3[/b] are selected in the same Preset dropdown, but you [b]edit[/b] them in [b][UPRE] User Presets[/b] — a separate settings group so factory P1–P14 stay uncluttered. Each slot is two rows:
[list]
[*] [b]Fast | Type[/b] — Impulse length and MA type, side by side.
[*] [b]Slow | Type[/b] — Lead length and MA type, side by side.
[/list]

TradingView remembers the slots with the chart template. Factory presets stay available. You are not forced to park your favourite pair in Manual and lose it when you try P8.

[b]4. A real higher-timeframe engine.[/b]
HTF 1 and HTF 2 are mapped from the chart timeframe in [b][TF] Timeframes[/b] — nine chart slots from [b]1 minute through daily[/b] (1, 2, 3, 5, 15, 30, 60, 240, 1D), each with its own HTF 1 / HTF 2 pair. There are no seconds-chart rows. If your chart TF is not in the table, HTF 1 / HTF 2 stay empty until you add a matching [CHART] row. The cloud can be drawn as IMH / LEH on HTF 1 or HTF 2. Momentum and MainTrend can sit on CTF, HTF 1, or HTF 2 independently.

Three calculation modes (same idea as a serious oscillator HTF, not a naïve security dump):
[list]
[*] [b]Scaled[/b] (default) — lengths are scaled by the HTF factor. EMA-family uses an alpha-equivalent length so inner smoothing matches the HTF EMA; window MAs (SMA, Hull family, …) scale linearly. Smooth lines, no extra request.security for the cloud values. Slight amplitude drift vs a true HTF.
[*] [b]Security (stepped)[/b] — original lengths evaluated on the HTF. Mathematically the HTF MA. Steps on HTF bar close.
[*] [b]Security (smooth)[/b] — security values plus EMA smoothing (length = factor). Steps are rounded off; slight extra lag; amplitude stays true to the HTF.
[/list]

Trend (rising / falling) on HTF still uses request.security in the HTF context, so [1] means the previous [b]HTF[/b] bar, not the previous chart bar. That is the usual Pine trap. MEVO does not walk into it.

[b]5. Three Trenders, one AND language.[/b]
A Trender is not a new oscillator. It is a [b]confluence gate[/b]: every checked source must agree, or the state is not bull and not bear.

Sources: Impulse, Lead, Momentum, MainTrend, Impulse HTF, Lead HTF, VWAP.
[list]
[*] [b]Trender 1[/b] — trendbar at the top (triangles / square), optional background.
[*] [b]Trender 2[/b] — same logic, bottom of the pane. Use it as a slower or stricter twin (e.g. Lead + Lead HTF).
[*] [b]Trender 3[/b] — [b]background only[/b]. No shapes, no InfoBoard. Same AND sources. Intended as atmosphere: you feel the regime without another row of markers.
[/list]

Consensus is the point. A single MA flip is noise. Lead + Lead HTF + MainTrend agreeing is a regime. You choose how strict that is.

The optional [b]InfoBoard[/b] (Trender 1 / 2) shows the active gate, the preset, and the HTF labels as a compact table — useful when you present the chart or when you jump timeframes. Impulse / Lead cells follow [b]cloud paint[/b] (bull / bear / neutral). Momentum, MainTrend and VWAP cells follow each line’s own paint vote.

[b]6. Alerts that match the chart, not a second logic.[/b]
Alerts fire on the [b]same votes[/b] you already see: Trender AND-flips, cloud paint flips, Momentum / MainTrend / VWAP paint flips. There is no hidden signal engine.

Two ways to subscribe:
[list]
[*] [b]One alert, many events.[/b] Create a TradingView alert with condition [b]Any alert() function call[/b]. In [b][AL] Alerts[/b], tick the events you want. Script settings at the moment you create the alert are saved. Frequency: [b]Once per bar close[/b] (confirmed, default) or [b]Once per bar[/b] (may fire intrabar). Message includes TF and price, plus the Trender source list.
[*] [b]One condition per event.[/b] The alert dialog also lists individual conditions ([TR1] LONG, [CL] SHORT, …). Those fire even if the matching checkbox in [AL] is off. Use them when you want a dedicated webhook or a single event.
[/list]

[b]7. Signal streams (Data Window) for other scripts.[/b]
MEVO publishes directional streams in TradingView’s Data Window so a hub (Confluence, a second overlay, a strategy) can pick them via input.source. Values follow the family pattern: [b]+N[/b] bullish, [b]−N[/b] bearish, [b]na[/b] mixed / Uni / inactive.


[b]HOW TO USE IT[/b]

[b]Quick start[/b]
[list]
[*] 1. Add [b]MEVO[/b] to an overlay chart.
[*] 2. Leave [b]Preset P8[/b] (EHMA 20 / 28), layout [b]Band[/b], cloud paint [b]Slope[/b].
[*] 3. Keep Momentum EMA 50 and MainTrend EMA 150 on the chart timeframe.
[*] 4. Watch three questions, in this order:
[/list]

Does [b]MainTrend[/b] slope with the move? That is the regime.
Is [b]price holding the cloud[/b] (or reclaiming it) in the direction of MainTrend? That is location.
Is [b]Momentum[/b] still agreeing, or has it rolled over? That is timing.


[b]EXAMPLES & PAINT MODES[/b]

[b]1. Stack Paint Mode (Ribbon / Position)[/b]
[image]https://www.tradingview.com/x/tEOTIWlm/[/image]

[b]2. Price Paint Mode (Neutral inside cloud)[/b]
[image]https://www.tradingview.com/x/kuJUuWki/[/image]

[b]3. Trender 1 & Trender 2 & Background Atmosphere (Trender 3)[/b]
[image]https://www.tradingview.com/x/pp9xxTFr/[/image]


[b]CONFLUENCE — USE MEVO WITH SOMETHING THAT SEES LOCATION[/b]

MEVO answers [b]regime and timing on moving averages[/b]. It does not see structure. A green cloud is not a reason to buy the high of a range, and a Trender flip is not a fill.

Use MEVO as [b]permission[/b], then wait for a location model you already trust:
[list]
[*] [b]Price action[/b] — break, retest, failure swing, inside-bar / engulfing at a level you marked without the indicator.
[*] [b]Market structure[/b] — swing high/low, BOS / CHOCH, range vs trend.
[*] [b]Smart-money / ICT-style location[/b] — FVG, order block, liquidity sweep, session pool, PDH/PDL.
[*] [b]Another indicator as a second vote[/b] — an oscillator (WaveTrend, RSI), or a higher-timeframe bias tool.
[/list]


[b]WHO IT IS FOR[/b]

[list]
[*] Traders who already use two or three MAs and are tired of stacking five indicators to get Hull + EMA + VWAP + HTF.
[*] People who want a cloud that can mean stack, slope, or price — matching the filter at the top of the pane.
[*] System builders who need a stable MA vocabulary.
[*] Anyone who wants the MA list in one open-source script they can read, fork, and audit.
[/list]

It is [b]not[/b] a buy/sell signal pack, not a strategy, and not an oscillator. You still need a location model (structure, levels, session) and risk management.


[b]OPEN SOURCE & DISCLAIMER[/b]

Mozilla Public License 2.0. The moving-average engine and helpers are inlined in this script.

MEVO is a visual and analytical overlay. It does not place orders, manage risk, or guarantee results. Moving averages lag. Past colour on a chart is not a forecast. Use on any market and timeframe at your own risk. This is not investment advice.

© TradersMove - To optimize your next trading move. — MPL 2.0

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradersMove / RenkCapital 2026 — TM.MEVO (open source)
//
// Open-source MEVO: Impulse / Lead cloud + Momentum + MainTrend + Trender.
// HTF calculation modes match TM.OSCILLATOR: Scaled, Security (stepped), Security (smooth).
// Paint: palette (Theme/Manual/Mono) vs rule (Uni/Slope/Stack/Price). User slots U1–U3.
// Standalone — MA engine and helpers are inlined (no TM_LIB import).
// v02: Lines layout uses the Line width inputs (Lead no longer stuck at 2). P14 = HEMA 20/28. U1 = TEMA 9/21.
//      Trender IM / LE / IMH / LEH vote each line's Paint (not the cloud fill). Empty AND stays flat.

ind_title       = 'MEVO - MA EVOLUTION [TradersMove]'
ind_short_name  = 'MEVO'
ind_version     = '.v02'
ind_shorttitle  = ind_short_name + ' ' + ind_version
ind_date        = '13.10.2026'

//@version=6
indicator(title=ind_title, shorttitle=ind_shorttitle, max_lines_count=500, max_labels_count=500, explicit_plot_zorder=true, behind_chart=true, overlay=true)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ██  ██████  ██████  ███    ██ ███████
//+---    ██ ██      ██    ██ ████   ██ ██
//+---    ██ ██      ██    ██ ██ ██  ██ ███████
//+---    ██ ██      ██    ██ ██  ██ ██      ██
//+---    ██  ██████  ██████  ██   ████ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ICONS
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
// Ⓐ Ⓑ Ⓒ Ⓓ Ⓔ Ⓕ Ⓖ Ⓗ Ⓘ Ⓙ Ⓚ
// ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩
// ➀ ➁ ➂ ➃ ➄ ➅ ➆ ➇ ➈ ➉
// ➊ ➋ ➌ ➍ ➎ ➏ ➐ ➑ ➒ ➓
// ← ↑ → ↓ ⇠ ⇡ ⇢ ⇣ ⇦ ⇧ ⇨ ⇩
// ⊕ ⊖ 🔜
// 🔸 🔹 🔶 🔷
// ◓ ◒ ⦿
// ™
//  
// ASCII GRAFICS:   https://patorjk.com/software/taag/#p=display&f=ANSI%20Regular&t=
// FONT:            ANSI REGULAR
//
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ████████  ██████   ██████  ██      ████████ ██ ██████  ███████
//+---       ██    ██    ██ ██    ██ ██         ██    ██ ██   ██ ██
//+---       ██    ██    ██ ██    ██ ██         ██    ██ ██████  ███████
//+---       ██    ██    ██ ██    ██ ██         ██    ██ ██           ██
//+---       ██     ██████   ██████  ███████    ██    ██ ██      ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    TOOLTIPS
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
tt_dlb               = '\n\n' // Double Linebreak
tt_lb                = '\n'   // Linebreak
string FO1           = 'Default'
string FO2           = 'Monospace'
tt_color             = '[Bull | Bear | Neutral]'
tt_ma_color          = '[Bull | Bear | Mono]'
tt_color_theme       = '[Bull | Bear | Neutral | TXT Bull | TXT Bear]'
tt_line              = '[Transparency | Width]\n\nTransparency: 0 = solid, 100 = invisible.\n\nWidth: 1–5.'
tt_candles           = 'When BARCOLOR is on, this selects which source colors the candles. Trender 3 colors candles from its AND vote; the TR3 background can stay off.'
tt_tv                = 'Enable when using TradingView Basic (max. 2 indicators).'
tt_calc_mode         = 'Scaled = lengths scaled by the HTF factor (EMA-family alpha-equivalent, window MAs linear). Smooth lines, slight amplitude drift vs a true HTF.\n\nSecurity (stepped) = request.security with original lengths in the HTF context. Mathematically exact, but stepped (value changes only on HTF bar close).\n\nSecurity (smooth) = request.security plus EMA smoothing with length = factor. Steps are smoothed, slight lag, amplitude stays true to the HTF.'
tt_tr3               = 'Trender 3 colors the chart background only. No shapes, no InfoBoard. Source checkboxes (AND) match TR1/TR2: IM, LE, MO, MT, IM HTF, LE HTF, MO HTF, VW.'
string HTF_MODE_SCALED  = 'Scaled'
string HTF_MODE_STEPPED = 'Security (stepped)'
string HTF_MODE_SMOOTH  = 'Security (smooth)'
string PAINT_UNI        = 'Uni'
string PAINT_SLOPE      = 'Slope'
string PAINT_STACK      = 'Stack'
string PAINT_PRICE      = 'Price'
tt_paint_line        = 'Uni = one color, no direction. Trender never vetoes.\n\nSlope = rising / falling.\n\nPrice = close above / below the line.\n\nTrender uses this rule for every ticked source (IM, LE, IMH, LEH, MO, MT, VW). Cloud paint colours the fill only.'
tt_paint_cloud       = 'Fill colour for Impulse vs Lead (same idea as CLOUDS I). Does not drive the Trender IM / LE checkboxes — those follow each line\'s Paint.\n\nUni = one fill color.\n\nSlope = both lines rising / both falling (CLOUDS Direction). Else neutral.\n\nStack = Impulse above / below Lead (CLOUDS Position).\n\nPrice = close above both / below both. Else neutral.'
tt_user_slot         = 'User slots U1–U3 live in [UPRE]. Each slot is two rows: Fast (Impulse) length | type, then Slow (Lead) length | type. Select U1, U2 or U3 in Preset to apply them. Factory P1–P14 stay available.'
tt_ib_col            = '[Frame | Text | Background]'
tt_ib_pos1           = 'TR1 InfoBoard: top edge, horizontal position.'
tt_ib_pos2           = 'TR2 InfoBoard: bottom edge, horizontal position.'
tt_alert             = 'Create one TradingView alert with condition «Any alert() function call». Tick the events you want. Settings at the moment you create the alert are saved.\n\nOnce per bar close = confirmed. Once per bar = may fire intrabar.'

//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ████████ ██    ██ ██████  ███████ ███████
//+---       ██     ██  ██  ██   ██ ██      ██
//+---       ██      ████   ██████  █████   ███████
//+---       ██       ██    ██      ██           ██
//+---       ██       ██    ██      ███████ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    TYPES
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//

type SYSTEM
	string  name
	string  version
	string  ticker
	string  ha_ticker
	float   src
	string  price
	float   close
	string  font
	string  tf_num
	string  tf_txt
	string  tf_full
	string  tf_short
	int		ctf_seconds


type DISPLAY
	string  mode
	bool    bc     // BarColor
	bool    im	   // Impulse
	bool    le	   // Lead
	bool    mo     // Momentum (ex SubTrend)
	bool    mt     // MainTrend
	bool    imh	   // Impulse HTF
	bool    leh	   // Lead HTF
	bool    vw     // Session VWAP
	bool    tr1    // Trender I
	bool    tr2    // Trender II
	bool    tr3    // Trender III (background only)
	bool    ib     // InfoBoard (legacy)
	bool    ib1    // Info table Trender I
	bool    ib2    // Info table Trender II
	bool    tb     // Trendinfo Board
	bool    ai     // AccountInfo
	bool    mx_ht1
	bool    mx_ht2
	bool    mx_ht3

type THEME
	string  mode
	string  bar_type
	color   bar
	string  title_a
	color   bull_a
	color   bear_a
	color   bullish_a
	color   bearish_a
	color   neutral_a
	color   txt_bull_a
	color   txt_bear_a
	string  title_b
	color   bull_b
	color   bear_b
	color   bullish_b
	color   bearish_b
	color   neutral_b
	color   txt_bull_b
	color   txt_bear_b
	string  title_c
	color   bull_c
	color   bear_c
	color   bullish_c
	color   bearish_c
	color   neutral_c
	color   txt_bull_c
	color   txt_bear_c
	color   bull
	color   bear
	color   bullish
	color   bearish
	color   neutral
	string  txt_title
	color   txt_light
	color   txt_dark
	color   txt_bull
	color   txt_bear
	color   trans           = #ffffff00
	color   darkgrey        = #323232
	color   midgrey         = #646464
	color   lightgrey       = #969696
	color   white           = #ffffff
	color   lightgreen      = #6aff00
	color   yellow          = #d9ff00
	//==> Theme colors
	color   grellgruen      = #99ff00
	color   grellpink       = #ff00e8
	color   tmblau          = #00bfff
	color   tmrot           = #ff0066
	color   sysgray         = #787b86 	// color.gray

type PRESET
	bool    active
	bool    bias
	bool    biascol
	string  biastype
	string  type
    string  layout
	string  content
	string  tf
	int     len_im
	string  type_im
	int     len_le
	string  type_le
	int     len_mt
	string  type_mt
	int     len_ma
	string  type_ma
	string  strat
	bool    basic

type MA
	string  set
	float   source
	string  len
	string  mode
	string  type
	string  layout
	bool    smoo
	string  smoo_len
	string  smoo_type
	string  col_mode
	string  paint
	color   col
	color   col_bull_i
	color   col_bull
	color   col_bear_i
	color   col_bear
	color   col_bullish_i
	color   col_bullish
	color   col_bearish_i
	color   col_bearish
	color   col_mono
	string  col_txt_bull_i
	color   col_txt_bull
	string  col_txt_bear_i
	color   col_txt_bear
	int     line_trans
	int     line_width
	int     label_dist
	float   out
	float   out_ma_high
	float   out_ma_low
	float   out_ma
	float   out_hi
	float   out_lo
	string  info

type ALERT
	bool il       = false
	bool le       = false
	bool mo       = false
	bool st       = false
	bool mt       = false
	bool tr1      = false
	bool tr2      = false



//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ███    ███ ███████ ████████ ██   ██  ██████  ██████  ███████
//+---    ████  ████ ██         ██    ██   ██ ██    ██ ██   ██ ██
//+---    ██ ████ ██ █████      ██    ███████ ██    ██ ██   ██ ███████
//+---    ██  ██  ██ ██         ██    ██   ██ ██    ██ ██   ██      ██
//+---    ██      ██ ███████    ██    ██   ██  ██████  ██████  ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    METHODS
//+---------------------+-------------------+----------------------------------+---------------------------------------+------------------+----------------+--------------+//

// Moving-average engine (inlined from TM_LIB so this script is standalone).
f_ma_ema(src, length) =>
	alpha = 2 / (length + 1)
	sum = 0.0
	sum := na(sum[1]) ? src : alpha * src + (1 - alpha) * nz(sum[1])
	sum

f_ma_sma(source, length) =>
	sum = 0.0
	for i = 0 to length - 1
		sum += source[i] / length
	sum

f_ma_wma(source, length) =>
	norm = 0.0
	sum = 0.0
	for i = 0 to length - 1
		weight = (length - i) * length
		norm := norm + weight
		sum := sum + source[i] * weight
	sum / norm

f_ma_rma(source, length) =>
	alpha = 1 / length
	sum = 0.0
	sum := na(sum[1]) ? f_ma_sma(source, length) : alpha * source + (1 - alpha) * nz(sum[1])

f_ma_gd(src, length, alpha) =>
	float result = f_ma_ema(src, length) * (1 + alpha) - f_ma_ema(f_ma_ema(src, length), length) * alpha

f_ma_t3(src, length, alpha = 0.7) =>
	float result = f_ma_gd(f_ma_gd(f_ma_gd(src, length, alpha), length, alpha), length, alpha)

f_ma_dema(src, length) =>
	float ema1 = f_ma_ema(src, length)
	float ema2 = f_ma_ema(ema1, length)
	2 * ema1 - ema2

f_ma_tema(src, length) =>
	float ema1 = f_ma_ema(src, length)
	float ema2 = f_ma_ema(ema1, length)
	float ema3 = f_ma_ema(ema2, length)
	3 * (ema1 - ema2) + ema3

f_ma_zlema(src, length) =>
	lag = math.max(0, math.round((length - 1) / 2.0))
	f_ma_ema(src + (src - src[lag]), length)

f_ma_hema(len) =>
	float hac = (open + high + low + close) / 4
	var float hao = na
	hao := na(hao[1]) ? (open + close) / 2 : (nz(hao[1]) + nz(hac[1])) / 2
	f_ma_ema(hao, len)

// HEMA uses Heikin Ashi open (same as TM_LIB). Computed inside the function so
// request.security sees HTF OHLC rather than a chart-level HA series.
f_ma(string type, float src, int len, float alphaInput = 0.7) =>
	switch type
		'EMA'        => f_ma_ema(src, len)
		'SMA'        => f_ma_sma(src, len)
		'SMMA (RMA)' => f_ma_rma(src, len)
		'TMA'        => f_ma_sma(f_ma_sma(src, math.ceil(len / 2)), math.floor(len / 2) + 1)
		'WMA'        => f_ma_wma(src, len)
		'VWMA'       => ta.vwma(src, len)
		'ZLEMA'      => f_ma_zlema(src, len)
		'ZEMA'       => f_ma_zlema(src, len)
		'TEMA'       => (3 * f_ma_ema(src, len)) - (3 * f_ma_ema(f_ma_ema(src, len), len)) + f_ma_ema(f_ma_ema(f_ma_ema(src, len), len), len)
		'HMA'        => f_ma_wma(2 * f_ma_wma(src, len / 2) - f_ma_wma(src, len), math.round(math.sqrt(len)))
		'HMA3'       => f_ma_wma(f_ma_wma(src, (len / 2) / 3) * 3 - f_ma_wma(src, (len / 2) / 2) - f_ma_wma(src, (len / 2)), (len / 2))
		'EHMA'       => f_ma_ema(2 * f_ma_ema(src, len / 2) - f_ma_ema(src, len), math.round(math.sqrt(len)))
		'THMA'       => f_ma_wma(f_ma_wma(src, len / 3) * 3 - f_ma_wma(src, len / 2) - f_ma_wma(src, len), len)
		'DEMA'       => f_ma_dema(src, len)
		'TEMA2'      => f_ma_tema(src, len)
		'T3'         => f_ma_t3(src, len, alphaInput)
		'HEMA'       => f_ma_hema(len)
		=>
			e1 = f_ma_ema(src, len)
			e2 = f_ma_ema(e1, len)
			2 * e1 - e2

f_getTrend(float src) =>
	t_isBullish       = src > src[1]
	t_isBearish       = src < src[1]
	t_wasBullish      = src[1] > src[2]
	t_wasBearish      = src[1] < src[2]
	t_isBullishChange = t_isBullish and t_wasBearish
	t_isBearishChange = t_isBearish and t_wasBullish
	t_CondIni = 0
	t_CondIni := t_isBullishChange ? 1 : t_isBearishChange ? -1 : t_CondIni[1]
	t_long  = t_isBullishChange and t_CondIni[1] == -1
	t_short = t_isBearishChange and t_CondIni[1] == 1
	[t_isBullish, t_isBearish, t_wasBullish, t_wasBearish, t_long, t_short]

// Line paint → bull/bear used for color and Trender.
f_paint_line(string rule, float ma, bool slopeBull, bool slopeBear) =>
	bool isBull = rule == PAINT_UNI ? false : rule == PAINT_PRICE ? close > ma : slopeBull
	bool isBear = rule == PAINT_UNI ? false : rule == PAINT_PRICE ? close < ma : slopeBear
	[isBull, isBear]

f_line_col(string rule, bool isBull, bool isBear, color cBull, color cBear, color cUni) =>
	rule == PAINT_UNI ? cUni : isBull ? cBull : isBear ? cBear : cUni

// Cloud fill paint (Impulse vs Lead). Slope uses the raw rising/falling flags.
f_paint_cloud(string rule, float fast, float slow, bool fBull, bool fBear, bool sBull, bool sBear) =>
	bool isBull = rule == PAINT_STACK ? fast > slow : rule == PAINT_PRICE ? close > fast and close > slow : rule == PAINT_SLOPE ? fBull and sBull : false
	bool isBear = rule == PAINT_STACK ? fast < slow : rule == PAINT_PRICE ? close < fast and close < slow : rule == PAINT_SLOPE ? fBear and sBear : false
	[isBull, isBear]

f_getFont(simple string font) =>
	switch font
		'Default'    => font.family_default
		'Standard'   => font.family_default
		'Monospace'  => font.family_monospace
		=> font.family_default

f_getSize(simple string sz) =>
	switch sz
		'Mini'       => size.tiny
		'Tiny'       => size.tiny
		'Small'      => size.small
		'Klein'      => size.small
		'Normal'     => size.normal
		'Large'      => size.large
		'Groß'       => size.large
		'Huge'       => size.huge
		'Sehr Groß'  => size.huge
		=> size.small

f_ib_cell(table t, int cidx, string cell_txt, color txt, color bg, string sz, string fam) =>
	table.cell(t, cidx, 0, cell_txt, text_color=txt, text_halign=text.align_center, text_size=sz, bgcolor=bg, text_font_family=fam)
	cidx + 1

f_getTimeframeNum() =>
	if timeframe.isminutes
		if str.tonumber(timeframe.period) % 60 == 0
			str.tostring(str.tonumber(timeframe.period) / 60)
		else
			timeframe.period
	else
		timeframe.period

f_getTimeframeUnit() =>
	if timeframe.isminutes
		if str.tonumber(timeframe.period) % 60 == 0
			'H'
		else
			'm'
	else
		na

// Helper for scaled HTF trend lines (MO/MT):
//   Alpha-equivalent length correction for EMA-family MAs:
//     EMA(N) on CTF with factor f becomes EMA(N_ctf) so (1-α_ctf)^f = (1-α_htf).
//     Inner smoothing then matches EMA(N) on the HTF.
//   SMA/WMA/window MAs are scaled linearly (exact for SMA).
//   HMA/EHMA/THMA are WMA-based internally → linear.
//   T3 is an EMA cascade → alpha-equivalent.
f_ema_equiv_len(int baseLen, float factor) =>
	f = math.max(1.0, factor)
	if f <= 1
		baseLen
	else if baseLen <= 1
		math.max(1, math.round(baseLen * f))
	else
		r = math.pow((baseLen - 1.0) / (baseLen + 1.0), 1.0 / f)
		math.max(1, math.round((r + 1.0) / (1.0 - r)))

// MA family for the scaling strategy. EMA family is alpha-recursive,
// others are window-based (linear scale).
f_is_alpha_family(string ma_type) =>
	ma_type == 'EMA' or ma_type == 'SMMA (RMA)' or ma_type == 'TEMA' or
	  ma_type == 'DEMA' or ma_type == 'ZLEMA' or ma_type == 'ZEMA' or
	  ma_type == 'HEMA' or ma_type == 'T3'

f_scale_len(string ma_type, int baseLen, float factor) =>
	if factor <= 1
		baseLen
	else if f_is_alpha_family(ma_type)
		f_ema_equiv_len(baseLen, factor)
	else
		math.max(1, math.round(baseLen * factor))

// Manual EMA with a series length — ta.ema needs a simple int and cannot take TF-dependent factors.
f_ema_manual(series float src, series int len) =>
	float alpha = 2.0 / (math.max(1, len) + 1)
	var float ema_val = na
	if not na(src)
		ema_val := na(ema_val[1]) ? src : alpha * src + (1 - alpha) * nz(ema_val[1])
	ema_val

// MA evaluated on HTF close (used inside request.security).
f_htf_ma2(string t_im, int l_im, string t_le, int l_le) =>
	[f_ma(t_im, close, l_im), f_ma(t_le, close, l_le)]

// Pack function for MO/MT trend values.
// Called via request.security in the target TF context (CTF or HTF).
// Trend booleans are computed INSIDE the function so `[1]` on HTF
// refers to the previous HTF bar, not the previous CTF bar.
f_st_pack(string ma_type, int len1) =>
	ma_raw_v = f_ma(ma_type, close, len1)
	[isB, isBe, wasB, wasBe, longS, shortS] = f_getTrend(ma_raw_v)
	[ma_raw_v, isB, isBe, wasB, wasBe, longS, shortS]


f_getTF_label(_tf) =>
	string output = ''
	[tfperiod, tfmult, tfsec, tfmin, tfd, tfw, tfm]  = request.security('',_tf,[timeframe.period,timeframe.multiplier,timeframe.isseconds,timeframe.isminutes,timeframe.isdaily,timeframe.isweekly,timeframe.ismonthly])

	if(tfsec)
		output := str.tostring(tfmult) + "s"
	else if(tfmin)
		if(tfmult < 59)
			output := tfperiod + "m"
		else
			output := str.tostring(tfmult / 60) + "h"
	else if(tfd)
		//if(tfmult < 2 or _tf == '1D' or _tf == 'D')
		//	output := "1D"
		//else
		output := tfperiod
	else if(tfw)
		if(tfmult == 1 or _tf == '1W')
			output := "1W"
		else
			output := tfperiod
	else if(tfm)
		if(tfmult == 1)
			output := "1M"
		else
			output := tfperiod
	output

//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---     ██████  ██████   ██████  ██    ██ ██████  ███████
//+---     ██       ██   ██ ██    ██ ██    ██ ██   ██ ██
//+---     ██   ███ ██████  ██    ██ ██    ██ ██████  ███████
//+---     ██    ██ ██   ██ ██    ██ ██    ██ ██           ██
//+---      ██████  ██   ██  ██████   ██████  ██      ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    SYSTEM
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//

dis_set              = '🔶🔸 [DI] DISPLAY' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
th_set               = '🔶🔸 [TH] THEME' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
pre_set              = '🔶🔸 [PRE] PRESETS' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
upre_set             = '🔶🔸 [UPRE] USER PRESETS' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
im_set               = '🔶🔸 [IM] IMPULSE' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
le_set               = '🔶🔸 [LE] LEAD' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
mo_set               = '🔶🔸 [MO] MOMENTUM' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
mt_set               = '🔶🔸 [MT] MAINTREND' +  ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
vw_set               = '🔶🔸 [VW] VWAP' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
mtf_set              = '🔶🔸 [TF] TIMEFRAMES' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
htf_set              = '🔶🔸 [HTF] HTF SETTINGS' +  ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
tr1_set              = '🔶🔸 [TR] TRENDER' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
tb_set               = '🔶🔸 [TB] TRENDBOARD' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
ib_set               = '🔶🔸 [IB] INFOBOARD' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
al_set               = '🔶🔸 [AL] ALERTS' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
in_set               = '🔶🔸 [IN] INFO' + ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ██████  ██████  ███████ ███████ ███████ ████████ ███████
//+---    ██   ██ ██   ██ ██      ██      ██         ██    ██
//+---    ██████  ██████  █████   ███████ █████      ██    ███████
//+---    ██      ██   ██ ██           ██ ██         ██         ██
//+---    ██      ██   ██ ███████ ███████ ███████    ██    ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    PRESETS
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
PRESET pre           = PRESET.new()

string PT0           = 'Manual'
string PTU1          = 'U1'
string PTU2          = 'U2'
string PTU3          = 'U3'
string PT1           = 'P1'
string PT2           = 'P2'
string PT3           = 'P3'
string PT4           = 'P4'
string PT5           = 'P5'
string PT6           = 'P6'
string PT7           = 'P7'
string PT8           = 'P8'
string PT9           = 'P9'
string PT10          = 'P10'
string PT11          = 'P11'
string PT12          = 'P12'
string PT13          = 'P13'
string PT14          = 'P14'

string tt_prtitle    = 'Presets:' + tt_dlb + 'Manual | U1–U3 = your slots | P1–P14 = factory'
string tt_pt1        = 'P1 ⇨ IM.SMA.50 | LE.SMA.200 — Golden Cross'
string tt_pt2        = 'P2 ⇨ IM.EMA.12 | LE.EMA.26 — MACD pair'
string tt_pt3        = 'P3 ⇨ IM.EMA.20 | LE.EMA.50 — Swing EMA'
string tt_pt4        = 'P4 ⇨ IM.SMA.20 | LE.SMA.50 — Mid SMA'
string tt_pt5        = 'P5 ⇨ IM.HMA.9 | LE.HMA.21 — Hull band'
string tt_pt6        = 'P6 ⇨ IM.EMA.8 | LE.EMA.21 — Fibonacci EMA'
string tt_pt7        = 'P7 ⇨ IM.EMA.9 | LE.VWMA.20 — Price vs volume'
string tt_pt8        = 'P8 ⇨ IM.EHMA.20 | LE.EHMA.28 — EHMA Standard'
string tt_pt9        = 'P9 ⇨ IM.ZLEMA.13 | LE.ZLEMA.34 — Zero lag'
string tt_pt10       = 'P10 ⇨ IM.DEMA.9 | LE.DEMA.21 — Double EMA'
string tt_pt11       = 'P11 ⇨ IM.T3.8 | LE.T3.21 — Smooth T3'
string tt_pt12       = 'P12 ⇨ IM.RMA.14 | LE.EMA.50 — SMMA vs EMA'
string tt_pt13       = 'P13 ⇨ IM.EHMA.20 | LE.THMA.50 — Hull mix'
string tt_pt14       = 'P14 ⇨ IM.HEMA.20 | LE.HEMA.28 — Heikin Ashi EMA'

string tt_pr         = tt_prtitle + tt_lb + tt_pt1 + tt_lb + tt_pt2 + tt_lb + tt_pt3 + tt_lb + tt_pt4 + tt_lb + tt_pt5 + tt_lb + tt_pt6 + tt_lb + tt_pt7 + tt_lb + tt_pt8 + tt_lb + tt_pt9 + tt_lb + tt_pt10 + tt_lb + tt_pt11 + tt_lb + tt_pt12 + tt_lb + tt_pt13 + tt_lb + tt_pt14

string ST0          = 'Manual'
string ST1          = 'Strat-3-5'
string ST2          = 'Strat-5-10'
string ST3          = 'Strat-5-15'

string tt_strat_01  = 'Strategy presets:' + tt_lb
string tt_strat_02  = 'Defines timeframes via multipliers,' + tt_lb
string tt_strat_03  = 'Strat-3-5 => HTF1 = chart TF (CTF) x 3 | HTF 2 = chart TF (CTF) x 5' + tt_lb
string tt_strat     = tt_strat_01 + tt_strat_02 + tt_strat_03



pre.type			 := input.string      (PT14                        ,'Preset:'                         ,inline='02'      ,group=pre_set    ,options=[PT0,PTU1,PTU2,PTU3,PT1,PT2,PT3,PT4,PT5,PT6,PT7,PT8,PT9,PT10,PT11,PT12,PT13,PT14],tooltip=tt_pr)
pre.layout           := input.string      ('Lines'                    ,'Layout'                           ,inline='04'      ,group=pre_set    ,options=['Band', 'Lines'])
int  band_trans      = input.int          (85                          ,'Band transparency'                ,inline='04'      ,group=pre_set    ,minval=50, maxval=98, step=1, tooltip='Band fill transparency (50=strong, 98=very faint)')
cloud_paint          = input.string       (PAINT_SLOPE                 ,'Cloud paint'                      ,inline='05'      ,group=pre_set    ,options=[PAINT_UNI, PAINT_SLOPE, PAINT_STACK, PAINT_PRICE], tooltip=tt_paint_cloud)

u1_im_len            = input.int          (9                           ,'U1 Fast | Type'                  ,inline='u1f'     ,group=upre_set   ,minval=1, tooltip=tt_user_slot)
u1_im_type           = input.string       ('TEMA'                      ,''                                 ,inline='u1f'     ,group=upre_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])
u1_le_len            = input.int          (21                          ,'U1 Slow | Type'                  ,inline='u1s'     ,group=upre_set   ,minval=1)
u1_le_type           = input.string       ('TEMA'                      ,''                                 ,inline='u1s'     ,group=upre_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])
u2_im_len            = input.int          (8                           ,'U2 Fast | Type'                  ,inline='u2f'     ,group=upre_set   ,minval=1)
u2_im_type           = input.string       ('EMA'                       ,''                                 ,inline='u2f'     ,group=upre_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])
u2_le_len            = input.int          (21                          ,'U2 Slow | Type'                  ,inline='u2s'     ,group=upre_set   ,minval=1)
u2_le_type           = input.string       ('EMA'                       ,''                                 ,inline='u2s'     ,group=upre_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])
u3_im_len            = input.int          (50                          ,'U3 Fast | Type'                  ,inline='u3f'     ,group=upre_set   ,minval=1)
u3_im_type           = input.string       ('EMA'                       ,''                                 ,inline='u3f'     ,group=upre_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])
u3_le_len            = input.int          (200                         ,'U3 Slow | Type'                  ,inline='u3s'     ,group=upre_set   ,minval=1)
u3_le_type           = input.string       ('EMA'                       ,''                                 ,inline='u3s'     ,group=upre_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])

pre.strat            := 'Manual'//input.string      ('Manual'                   ,'Strategy'                       ,inline='10'      ,group=pre_set     ,options=[ST0,ST1,ST2,ST3]           ,tooltip=tt_strat)
//pre.basic	         := input.bool       (false                        ,'TradingView Basic'               ,inline='12'       ,group=pre_set    ,tooltip = tt_tv)
pre.active           := pre.type != PT0 ? true : false

if pre.active
	switch pre.type
		PTU1 =>
			pre.len_im   := u1_im_len
			pre.type_im  := u1_im_type
			pre.len_le   := u1_le_len
			pre.type_le  := u1_le_type
			pre.content  := 'U1'
		PTU2 =>
			pre.len_im   := u2_im_len
			pre.type_im  := u2_im_type
			pre.len_le   := u2_le_len
			pre.type_le  := u2_le_type
			pre.content  := 'U2'
		PTU3 =>
			pre.len_im   := u3_im_len
			pre.type_im  := u3_im_type
			pre.len_le   := u3_le_len
			pre.type_le  := u3_le_type
			pre.content  := 'U3'
		PT1 =>
			pre.len_im   := 50
			pre.type_im  := 'SMA'
			pre.len_le   := 200
			pre.type_le  := 'SMA'
			pre.content  := tt_pt1
		PT2 =>
			pre.len_im   := 12
			pre.type_im  := 'EMA'
			pre.len_le   := 26
			pre.type_le  := 'EMA'
			pre.content  := tt_pt2
		PT3 =>
			pre.len_im   := 20
			pre.type_im  := 'EMA'
			pre.len_le   := 50
			pre.type_le  := 'EMA'
			pre.content  := tt_pt3
		PT4 =>
			pre.len_im   := 20
			pre.type_im  := 'SMA'
			pre.len_le   := 50
			pre.type_le  := 'SMA'
			pre.content  := tt_pt4
		PT5 =>
			pre.len_im   := 9
			pre.type_im  := 'HMA'
			pre.len_le   := 21
			pre.type_le  := 'HMA'
			pre.content  := tt_pt5
		PT6 =>
			pre.len_im   := 8
			pre.type_im  := 'EMA'
			pre.len_le   := 21
			pre.type_le  := 'EMA'
			pre.content  := tt_pt6
		PT7 =>
			pre.len_im   := 9
			pre.type_im  := 'EMA'
			pre.len_le   := 20
			pre.type_le  := 'VWMA'
			pre.content  := tt_pt7
		PT8 =>
			pre.len_im   := 20
			pre.type_im  := 'EHMA'
			pre.len_le   := 28
			pre.type_le  := 'EHMA'
			pre.content  := tt_pt8
		PT9 =>
			pre.len_im   := 13
			pre.type_im  := 'ZLEMA'
			pre.len_le   := 34
			pre.type_le  := 'ZLEMA'
			pre.content  := tt_pt9
		PT10 =>
			pre.len_im   := 9
			pre.type_im  := 'DEMA'
			pre.len_le   := 21
			pre.type_le  := 'DEMA'
			pre.content  := tt_pt10
		PT11 =>
			pre.len_im   := 8
			pre.type_im  := 'T3'
			pre.len_le   := 21
			pre.type_le  := 'T3'
			pre.content  := tt_pt11
		PT12 =>
			pre.len_im   := 14
			pre.type_im  := 'SMMA (RMA)'
			pre.len_le   := 50
			pre.type_le  := 'EMA'
			pre.content  := tt_pt12
		PT13 =>
			pre.len_im   := 20
			pre.type_im  := 'EHMA'
			pre.len_le   := 50
			pre.type_le  := 'THMA'
			pre.content  := tt_pt13
		PT14 =>
			pre.len_im   := 20
			pre.type_im  := 'HEMA'
			pre.len_le   := 28
			pre.type_le  := 'HEMA'
			pre.content  := tt_pt14


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
DISPLAY show         = DISPLAY.new()

show.bc              := input.bool       (false                        ,'[BC] BarColor '                  ,inline='02'       ,group=dis_set)
show.im              := input.bool       (true                         ,'[IM] Impulse............'        ,inline='04'       ,group=dis_set)
show.imh             := input.bool       (true                         ,'[IMH] Impulse HTF'               ,inline='04'       ,group=dis_set)
show.le              := input.bool       (true                         ,'[LE] Lead.................'      ,inline='06'       ,group=dis_set)
show.leh             := input.bool       (true                         ,'[LEH] Lead HTF'                  ,inline='06'       ,group=dis_set)
show.mo              := input.bool       (false                        ,'[MO] Momentum'                   ,inline='08'       ,group=dis_set)
show.mt              := input.bool       (false                        ,'[MT] MainTrend'                  ,inline='10'       ,group=dis_set)
show.vw              := input.bool       (false                        ,'[VW] VWAP'                       ,inline='14'       ,group=dis_set)



show.tr1             := input.bool       (true                         ,'[TR I]....Trender 1'             ,inline='24'       ,group=dis_set)
show.ib1             := input.bool       (true                         ,'Info'                            ,inline='24'       ,group=dis_set, tooltip=tt_ib_pos1)
show.tr2             := input.bool       (true                         ,'[TR II]...Trender 2'             ,inline='26'       ,group=dis_set)
show.ib2             := input.bool       (true                         ,'Info'                            ,inline='26'       ,group=dis_set, tooltip=tt_ib_pos2)
show.tr3             := input.bool       (false                        ,'[TR III]..Trender 3'             ,inline='28'       ,group=dis_set, tooltip=tt_tr3)
show.ai              := input.bool       (false                        ,'[AI] Account Info'               ,inline='34'       ,group=dis_set)

ib_col_frame         = input.color       (#000000                      ,'Frame | Text | Background'       ,inline='40'       ,group=ib_set)
ib_col_txt           = input.color       (#000000                      ,''                                ,inline='40'       ,group=ib_set)
ib_col_bg            = input.color       (#d1d4dc                      ,''                                ,inline='40'       ,group=ib_set, tooltip=tt_ib_col)
ib_size_i            = input.string      ('Small'                      ,'Size'                            ,inline='44'       ,group=ib_set, options=['Mini', 'Small', 'Normal', 'Large', 'Huge'])
ib_hide_frame        = input.bool        (false                        ,'Hide frame?'                     ,inline='44'       ,group=ib_set)
ib1_h_pos            = input.string      ('Center'                     ,'[IB1] Horizontal'                ,inline='46'       ,group=ib_set, options=['Left', 'Center', 'Right'], tooltip=tt_ib_pos1)
ib2_h_pos            = input.string      ('Center'                     ,'[IB2] Horizontal'                ,inline='46'       ,group=ib_set, options=['Left', 'Center', 'Right'], tooltip=tt_ib_pos2)

ib_txt_size          = f_getSize(ib_size_i)
ib1_tbl_position     = ib1_h_pos == 'Left' ? position.top_left : ib1_h_pos == 'Center' ? position.top_center : position.top_right
ib2_tbl_position     = ib2_h_pos == 'Left' ? position.bottom_left : ib2_h_pos == 'Center' ? position.bottom_center : position.bottom_right


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ████████ ██   ██ ███████ ███    ███ ███████
//+---       ██    ██   ██ ██      ████  ████ ██
//+---       ██    ███████ █████   ██ ████ ██ █████
//+---       ██    ██   ██ ██      ██  ██  ██ ██
//+---       ██    ██   ██ ███████ ██      ██ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    THEME
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
THEME col            = THEME.new()

string TH1           = 'A'
string TH2           = 'B'
string TH3           = 'C'
// Bar Types
string BT1           = '[TH] Theme'
string BT2           = '[SP] Swing Points'
string BT3           = '[TR1] Trender 1'
string BT4           = '[TR2] Trender 2'
string BT5           = '[TR3] Trender 3'

col.mode             :=input.string      ('A'                          ,'Theme'                             ,group=th_set       ,inline='02'     ,options=[TH1,TH2,TH3])
col_font_tmp         = input.string      ('Monospace'                  ,'Font'                              ,group=th_set       ,inline='02'     ,options=[FO1,FO2])

col.bull_a           :=input.color       (color.rgb(0, 255, 255)     ,'A   '                              ,group=th_set       ,inline='04')
col.bear_a           :=input.color       (color.rgb(255, 0, 102)     ,''                                  ,group=th_set       ,inline='04')
col.neutral_a        :=input.color       (color.rgb(178, 181, 190)   ,''                                  ,group=th_set       ,inline='04')
col.txt_bull_a       :=input.color       (color.rgb(48, 50, 50)      ,''                                  ,group=th_set       ,inline='04')
col.txt_bear_a       :=input.color       (color.rgb(255, 255, 255)   ,''                                  ,group=th_set       ,inline='04'      ,tooltip=tt_color_theme)

col.bull_b           :=input.color       (color.rgb(155, 255, 0)     ,'B   '                              ,group=th_set       ,inline='08')
col.bear_b           :=input.color       (color.rgb(255, 0, 255)     ,''                                  ,group=th_set       ,inline='08')
col.neutral_b        :=input.color       (color.rgb(178, 181, 190)   ,''                                  ,group=th_set       ,inline='08')
col.txt_bull_b       :=input.color       (color.rgb(48, 50, 50)      ,''                                  ,group=th_set       ,inline='08')
col.txt_bear_b       :=input.color       (color.rgb(255, 255, 255)   ,''                                  ,group=th_set       ,inline='08'       ,tooltip=tt_color_theme)

col.bull_c           :=input.color       (color.green                ,'C   '                              ,group=th_set       ,inline='12')
col.bear_c           :=input.color       (color.red                  ,''                                  ,group=th_set       ,inline='12')
col.neutral_c        :=input.color       (color.gray                 ,''                                  ,group=th_set       ,inline='12')
col.txt_bull_c       :=input.color       (color.rgb(255, 255, 255)   ,''                                  ,group=th_set       ,inline='12')
col.txt_bear_c       :=input.color       (color.rgb(255, 255, 255)   ,''                                  ,group=th_set       ,inline='12'      ,tooltip=tt_color_theme)

col.bar_type         :=input.string      (BT1                          ,'Candles'                           ,group=th_set       ,inline='20'    ,options=[BT1,BT3,BT4,BT5], tooltip=tt_candles)





//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    ███████ ███████ ████████ ██    ██ ██████
//+---    ██      ██         ██    ██    ██ ██   ██
//+---    ███████ █████      ██    ██    ██ ██████
//+---         ██ ██         ██    ██    ██ ██
//+---    ███████ ███████    ██     ██████  ██
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    SETUP
//+---               input               def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//

//+--- SYSTEM
SYSTEM sys           = SYSTEM.new()
sys.name             := ind_title
sys.version          := ind_version
sys.ticker           := syminfo.tickerid
sys.ha_ticker        := ticker.heikinashi(syminfo.tickerid)
sys.src              := close
sys.font             := f_getFont(col_font_tmp)
sys.ctf_seconds      := timeframe.in_seconds(timeframe.period)
sys.tf_num           := f_getTimeframeNum()
sys.tf_txt           := f_getTimeframeUnit()
sys.tf_full          := sys.tf_num + sys.tf_txt + " TIMEFRAME"
sys.tf_short         := sys.tf_num + sys.tf_txt

//+--- THEME
col.bull             :=		col.mode == 'A' ? col.bull_a       : col.mode == 'B' ? col.bull_b      : col.bull_c
col.bear             :=		col.mode == 'A' ? col.bear_a       : col.mode == 'B' ? col.bear_b      : col.bear_c
col.neutral          :=		col.mode == 'A' ? col.neutral_a    : col.mode == 'B' ? col.neutral_b   : col.neutral_c
col.txt_bull         :=		col.mode == 'A' ? col.txt_bull_a   : col.mode == 'B' ? col.txt_bull_b  : col.txt_bull_c
col.txt_bear         :=		col.mode == 'A' ? col.txt_bear_a   : col.mode == 'B' ? col.txt_bear_b  : col.txt_bear_c
col.bar              :=		close > open ? col.bull : close < open ? col.bear : col.neutral

//+--- ALERTS
ALERT     bull_al     		= ALERT.new()
ALERT     bear_al     		= ALERT.new()


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ████████ ██ ███    ███ ███████ ███████ ██████   █████  ███    ███ ███████ ███████
//+---      ██    ██ ████  ████ ██      ██      ██   ██ ██   ██ ████  ████ ██      ██
//+---      ██    ██ ██ ████ ██ █████   █████   ██████  ███████ ██ ████ ██ █████   ███████
//+---      ██    ██ ██  ██  ██ ██      ██      ██   ██ ██   ██ ██  ██  ██ ██           ██
//+---      ██    ██ ██      ██ ███████ ██      ██   ██ ██   ██ ██      ██ ███████ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   TIMEFRAMES
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//

mx_tf1               = input.timeframe   ('1'                          ,'01 🔸 [CHART]'                   ,inline='00',       group=mtf_set)
mx_tf1_htf1          = input.timeframe   ('5'                          ,'      [HTF 1] '                  ,inline='04',       group=mtf_set)
mx_tf1_htf2          = input.timeframe   ('15'                         ,'[HTF 2] '                        ,inline='04',       group=mtf_set)

mx_tf2               = input.timeframe   ('2'                          ,'02 🔸 [CHART]'                   ,inline='10',       group=mtf_set)
mx_tf2_htf1          = input.timeframe   ('5'                          ,'      [HTF 1] '                  ,inline='14',       group=mtf_set)
mx_tf2_htf2          = input.timeframe   ('15'                         ,'[HTF 2] '                        ,inline='14',       group=mtf_set)

mx_tf3               = input.timeframe   ('3'                          ,'03 🔸 [CHART]'                   ,inline='20',       group=mtf_set)
mx_tf3_htf1          = input.timeframe   ('9'                          ,'      [HTF 1] '                  ,inline='24',       group=mtf_set)
mx_tf3_htf2          = input.timeframe   ('30'                         ,'[HTF 2] '                        ,inline='24',       group=mtf_set)

mx_tf4               = input.timeframe   ('5'                          ,'04 🔸 [CHART]'                   ,inline='30',       group=mtf_set)
mx_tf4_htf1          = input.timeframe   ('15'                         ,'      [HTF 1] '                  ,inline='34',       group=mtf_set)
mx_tf4_htf2          = input.timeframe   ('60'                         ,'[HTF 2] '                        ,inline='34',       group=mtf_set)

mx_tf5               = input.timeframe   ('15'                         ,'05 🔸 [CHART]'                   ,inline='40',       group=mtf_set)
mx_tf5_htf1          = input.timeframe   ('60'                         ,'      [HTF 1] '                  ,inline='44',       group=mtf_set)
mx_tf5_htf2          = input.timeframe   ('240'                        ,'[HTF 2] '                        ,inline='44',       group=mtf_set)

mx_tf6               = input.timeframe   ('30'                         ,'06 🔸 [CHART]'                   ,inline='50',       group=mtf_set)
mx_tf6_htf1          = input.timeframe   ('120'                        ,'      [HTF 1] '                  ,inline='54',       group=mtf_set)
mx_tf6_htf2          = input.timeframe   ('480'                        ,'[HTF 2] '                        ,inline='54',       group=mtf_set)

mx_tf7               = input.timeframe   ('60'                         ,'07 🔸 [CHART]'                   ,inline='60',       group=mtf_set)
mx_tf7_htf1          = input.timeframe   ('240'                        ,'      [HTF 1] '                  ,inline='64',       group=mtf_set)
mx_tf7_htf2          = input.timeframe   ('1D'                         ,'[HTF 2] '                        ,inline='64',       group=mtf_set)

mx_tf8               = input.timeframe   ('240'                        ,'08 🔸 [CHART]'                   ,inline='70',       group=mtf_set)
mx_tf8_htf1          = input.timeframe   ('1D'                         ,'      [HTF 1] '                  ,inline='74',       group=mtf_set)
mx_tf8_htf2          = input.timeframe   ('3D'                         ,'[HTF 2] '                        ,inline='74',       group=mtf_set)

mx_tf9               = input.timeframe   ('1D'                         ,'09 🔸 [CHART]'                   ,inline='80',       group=mtf_set)
mx_tf9_htf1          = input.timeframe   ('3D'                         ,'      [HTF 1] '                  ,inline='84',       group=mtf_set)
mx_tf9_htf2          = input.timeframe   ('1W'                         ,'[HTF 2] '                        ,inline='84',       group=mtf_set)


var mx_htf1         = ''
var mx_htf2         = ''

timeframes 	        = array.from(mx_tf1, mx_tf2, mx_tf3, mx_tf4, mx_tf5, mx_tf6, mx_tf7, mx_tf8, mx_tf9)
htf1_values         = array.from(mx_tf1_htf1, mx_tf2_htf1, mx_tf3_htf1, mx_tf4_htf1, mx_tf5_htf1, mx_tf6_htf1, mx_tf7_htf1, mx_tf8_htf1, mx_tf9_htf1)
htf2_values         = array.from(mx_tf1_htf2, mx_tf2_htf2, mx_tf3_htf2, mx_tf4_htf2, mx_tf5_htf2, mx_tf6_htf2, mx_tf7_htf2, mx_tf8_htf2, mx_tf9_htf2)
// Loop with early exit
var tf_found = false
for i = 0 to array.size(timeframes) - 1
	if not tf_found and timeframe.in_seconds(array.get(timeframes, i)) == sys.ctf_seconds
		mx_htf1 := array.get(htf1_values, i)
		mx_htf2 := array.get(htf2_values, i)
		tf_found := true  // stop further iterations


// HTF factors — how many CTF bars fit into one HTF bar.
//      Used to scale HTF line lengths.
htf1_factor         = math.max(1, math.round(timeframe.in_seconds(mx_htf1) / math.max(1, sys.ctf_seconds)))
htf2_factor         = math.max(1, math.round(timeframe.in_seconds(mx_htf2) / math.max(1, sys.ctf_seconds)))
label_htf1          = f_getTF_label(mx_htf1)
label_htf2          = f_getTF_label(mx_htf2)




//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ██ ███    ███ ██████  ██    ██ ██      ███████
//+---   ██ ████  ████ ██   ██ ██    ██ ██      ██
//+---   ██ ██ ████ ██ ██████  ██    ██ ██      ███████
//+---   ██ ██  ██  ██ ██      ██    ██ ██           ██
//+---   ██ ██      ██ ██       ██████  ███████ ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   IMPULSE
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
MA im                = MA.new()

im.source            := close
im_len               = input.int        (20                            ,'Length | Type'            ,inline='02'       ,group=im_set   ,minval=1)
im.type              := input.string    ('EMA'                         ,''                               ,inline='02'       ,group=im_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])

im.col_mode          := input.string    ('Theme'                       ,'Color mode'                      ,inline='06'       ,group=im_set   ,options=['Theme', 'Manual', 'Mono'])
im.col_bull_i        :=input.color      (color.rgb(76, 175, 80)        ,''                               ,inline='06'       ,group=im_set)
im.col_bear_i        :=input.color      (color.rgb(242, 54, 69)        ,''                               ,inline='06'       ,group=im_set)
im.col_mono          :=input.color      (color.rgb(178, 181, 190)      ,''                               ,inline='06'       ,group=im_set   ,tooltip=tt_ma_color)
im.paint             := input.string    (PAINT_SLOPE                   ,'Paint'                           ,inline='07'       ,group=im_set   ,options=[PAINT_UNI, PAINT_SLOPE, PAINT_PRICE], tooltip=tt_paint_line)

im.line_trans        :=input.int        (0                             ,'Line'   ,inline='10'       ,group=im_set   ,minval=0, maxval=100, step=1, tooltip=tt_line)
im_line_width        = input.int        (1                             ,''                               ,inline='10'       ,group=im_set   ,options=[1,2,3,4,5])

im_len_active        = pre.active ? pre.len_im : im_len
im.out_ma            := pre.active ? f_ma(pre.type_im, im.source, pre.len_im) : f_ma(im.type, im.source, im_len)

[im_slope_bull, im_slope_bear, im_wasBullish, im_wasBearish, im_long, im_short] = f_getTrend(im.out_ma)
[im_isBullish, im_isBearish] = f_paint_line(im.paint, im.out_ma, im_slope_bull, im_slope_bear)

im.col_bull          := im.col_mode == 'Mono' ? color.new(im.col_mono, im.line_trans) : im.col_mode == 'Manual' ? color.new(im.col_bull_i,im.line_trans)    : color.new(col.bull,im.line_trans)
im.col_bear          := im.col_mode == 'Mono' ? color.new(im.col_mono, im.line_trans) : im.col_mode == 'Manual' ? color.new(im.col_bear_i,im.line_trans)    : color.new(col.bear,im.line_trans)
color im_col_uni      = im.col_mode == 'Mono' ? color.new(im.col_mono, im.line_trans) : im.col_mode == 'Manual' ? color.new(im.col_bull_i,im.line_trans)    : color.new(col.neutral,im.line_trans)

im.col               := f_line_col(im.paint, im_isBullish, im_isBearish, im.col_bull, im.col_bear, im_col_uni)
im_txt_color         = im_isBullish ? im.col_txt_bull : im_isBearish ? im.col_txt_bear : col.neutral







//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ██      ███████  █████  ██████
//+---   ██      ██      ██   ██ ██   ██
//+---   ██      █████   ███████ ██   ██
//+---   ██      ██      ██   ██ ██   ██
//+---   ███████ ███████ ██   ██ ██████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   LEAD
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
MA le                = MA.new()

le.source            := close
le_len               = input.int        (28                            ,'Length | Type'            ,inline='02'       ,group=le_set   ,minval=1)
le.type              := input.string    ('EMA'                         ,''                               ,inline='02'       ,group=le_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])

le.col_mode          := input.string    ('Theme'                       ,'Color mode'                      ,inline='06'       ,group=le_set   ,options=['Theme', 'Manual', 'Mono'])
le.col_bull_i        :=input.color      (color.rgb(76, 175, 80)      ,''                               ,inline='06'       ,group=le_set)
le.col_bear_i        :=input.color      (color.rgb(242, 54, 69)      ,''                               ,inline='06'       ,group=le_set)
le.col_mono          :=input.color      (color.rgb(178, 181, 190)    ,''                               ,inline='06'       ,group=le_set   ,tooltip=tt_ma_color)
le.paint             := input.string    (PAINT_SLOPE                   ,'Paint'                           ,inline='07'       ,group=le_set   ,options=[PAINT_UNI, PAINT_SLOPE, PAINT_PRICE], tooltip=tt_paint_line)

le.line_trans        :=input.int        (0                             ,'Line'   ,inline='10'       ,group=le_set   ,minval=0, maxval=100, step=1, tooltip=tt_line)
le_line_width        = input.int        (1                             ,''                               ,inline='10'       ,group=le_set   ,options=[1,2,3,4,5])

le_len_active        = pre.active ? pre.len_le : le_len
le.out_ma            := pre.active ? f_ma(pre.type_le, le.source, pre.len_le) : f_ma(le.type, le.source, le_len)

[le_slope_bull, le_slope_bear, le_wasBullish, le_wasBearish, le_long, le_short] = f_getTrend(le.out_ma)
[le_isBullish, le_isBearish] = f_paint_line(le.paint, le.out_ma, le_slope_bull, le_slope_bear)

le.col_bull          := le.col_mode == 'Mono' ? color.new(le.col_mono, le.line_trans) : le.col_mode == 'Manual' ? color.new(le.col_bull_i,le.line_trans)    : color.new(col.bull,le.line_trans)
le.col_bear          := le.col_mode == 'Mono' ? color.new(le.col_mono, le.line_trans) : le.col_mode == 'Manual' ? color.new(le.col_bear_i,le.line_trans)    : color.new(col.bear,le.line_trans)
color le_col_uni      = le.col_mode == 'Mono' ? color.new(le.col_mono, le.line_trans) : le.col_mode == 'Manual' ? color.new(le.col_bull_i,le.line_trans)    : color.new(col.neutral,le.line_trans)

le.col               := f_line_col(le.paint, le_isBullish, le_isBearish, le.col_bull, le.col_bear, le_col_uni)
le_txt_color         = le_isBullish ? le.col_txt_bull : le_isBearish ? le.col_txt_bear : col.neutral


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   LEAD HTF
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//




//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ██   ██ ████████ ███████     ███████ ███████ ████████ ████████ ██ ███    ██  ██████  ███████ 
//+---   ██   ██    ██    ██          ██      ██         ██       ██    ██ ████   ██ ██       ██      
//+---   ███████    ██    █████       ███████ █████      ██       ██    ██ ██ ██  ██ ██   ███ ███████ 
//+---   ██   ██    ██    ██               ██ ██         ██       ██    ██ ██  ██ ██ ██    ██      ██ 
//+---   ██   ██    ██    ██          ███████ ███████    ██       ██    ██ ██   ████  ██████  ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   HTF SETTINGS
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//

htf_tf               = input.string      ('HTF 1'                      ,'HTF'                            ,inline='04'       ,group=htf_set   ,options=['HTF 1','HTF 2'] )
htf_calc_mode        = input.string      (HTF_MODE_SCALED              ,'Calculation'                    ,inline='05'       ,group=htf_set   ,options=[HTF_MODE_SCALED, HTF_MODE_STEPPED, HTF_MODE_SMOOTH], tooltip=tt_calc_mode)
MA htf               = MA.new()
htf.col_mode         := input.string    ('Theme'                       ,'Color mode'                      ,inline='06'       ,group=htf_set   ,options=['Theme', 'Manual', 'Mono'])
htf.col_bull_i       :=input.color      (color.rgb(76, 175, 80)      ,''                               ,inline='06'       ,group=htf_set)
htf.col_bear_i       :=input.color      (color.rgb(242, 54, 69)      ,''                               ,inline='06'       ,group=htf_set)
htf.col_mono         :=input.color      (color.rgb(178, 181, 190)    ,''                               ,inline='06'       ,group=htf_set   ,tooltip=tt_ma_color)
htf.paint            := input.string    (PAINT_SLOPE                   ,'Paint'                           ,inline='07'       ,group=htf_set   ,options=[PAINT_UNI, PAINT_SLOPE, PAINT_PRICE], tooltip=tt_paint_line)

htf.line_trans        :=input.int        (0                             ,'Line'   ,inline='10'       ,group=htf_set   ,minval=0, maxval=100, step=1, tooltip=tt_line)
htf_line_width        = input.int        (1                             ,''                               ,inline='10'       ,group=htf_set   ,options=[1,2,3,4,5])

htf.col_bull          := htf.col_mode == 'Mono' ? color.new(htf.col_mono, htf.line_trans) : htf.col_mode == 'Manual' ? color.new(htf.col_bull_i,htf.line_trans)    : color.new(col.bull,htf.line_trans)
htf.col_bear          := htf.col_mode == 'Mono' ? color.new(htf.col_mono, htf.line_trans) : htf.col_mode == 'Manual' ? color.new(htf.col_bear_i,htf.line_trans)    : color.new(col.bear,htf.line_trans)

htf_factor            = htf_tf == 'HTF 1' ? htf1_factor : htf2_factor
htf_tf_value          = htf_tf == 'HTF 1' ? mx_htf1     : mx_htf2

imh_type_a            = pre.active ? pre.type_im : im.type
leh_type_a            = pre.active ? pre.type_le : le.type
imh_len_a             = pre.active ? pre.len_im  : im_len
leh_len_a             = pre.active ? pre.len_le  : le_len

imh_len_scaled        = f_scale_len(imh_type_a, imh_len_a, htf_factor)
leh_len_scaled        = f_scale_len(leh_type_a, leh_len_a, htf_factor)

float imh_out_ma_scaled = f_ma(imh_type_a, im.source, imh_len_scaled)
float leh_out_ma_scaled = f_ma(leh_type_a, le.source, leh_len_scaled)

float imh_out_ma_sec = na
float leh_out_ma_sec = na
if htf_calc_mode != HTF_MODE_SCALED
	[_imh_s, _leh_s] = request.security(syminfo.tickerid, htf_tf_value, f_htf_ma2(imh_type_a, imh_len_a, leh_type_a, leh_len_a), lookahead=barmerge.lookahead_off)
	imh_out_ma_sec := _imh_s
	leh_out_ma_sec := _leh_s

htf_smooth_len          = math.max(2, math.round(htf_factor))
float imh_out_ma_smooth = f_ema_manual(imh_out_ma_sec, htf_smooth_len)
float leh_out_ma_smooth = f_ema_manual(leh_out_ma_sec, htf_smooth_len)

float imh_out_ma = htf_calc_mode == HTF_MODE_SCALED ? imh_out_ma_scaled : htf_calc_mode == HTF_MODE_STEPPED ? imh_out_ma_sec : imh_out_ma_smooth
float leh_out_ma = htf_calc_mode == HTF_MODE_SCALED ? leh_out_ma_scaled : htf_calc_mode == HTF_MODE_STEPPED ? leh_out_ma_sec : leh_out_ma_smooth

[imh_slope_bull, imh_slope_bear, imh_wasBullish, imh_wasBearish, imh_long, imh_short] = f_getTrend(imh_out_ma)
[leh_slope_bull, leh_slope_bear, leh_wasBullish, leh_wasBearish, leh_long, leh_short] = f_getTrend(leh_out_ma)
[imh_isBullish, imh_isBearish] = f_paint_line(htf.paint, imh_out_ma, imh_slope_bull, imh_slope_bear)
[leh_isBullish, leh_isBearish] = f_paint_line(htf.paint, leh_out_ma, leh_slope_bull, leh_slope_bear)

color htf_col_uni     = htf.col_mode == 'Mono' ? color.new(htf.col_mono, htf.line_trans) : htf.col_mode == 'Manual' ? color.new(htf.col_bull_i,htf.line_trans) : color.new(col.neutral,htf.line_trans)
imh_col              = f_line_col(htf.paint, imh_isBullish, imh_isBearish, htf.col_bull, htf.col_bear, htf_col_uni)
leh_col              = f_line_col(htf.paint, leh_isBullish, leh_isBearish, htf.col_bull, htf.col_bear, htf_col_uni)

htf_label            = htf_tf == 'HTF 1' ? label_htf1 : label_htf2

[cloud_bull, cloud_bear] = f_paint_cloud(cloud_paint, im.out_ma, le.out_ma, im_slope_bull, im_slope_bear, le_slope_bull, le_slope_bear)
[hcloud_bull, hcloud_bear] = f_paint_cloud(cloud_paint, imh_out_ma, leh_out_ma, imh_slope_bull, imh_slope_bear, leh_slope_bull, leh_slope_bear)



//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ███    ███  ██████  ███    ███ ███████ ███    ██ ████████ ██    ██ ███    ███ 
//+---   ████  ████ ██    ██ ████  ████ ██      ████   ██    ██    ██    ██ ████  ████ 
//+---   ██ ████ ██ ██    ██ ██ ████ ██ █████   ██ ██  ██    ██    ██    ██ ██ ████ ██ 
//+---   ██  ██  ██ ██    ██ ██  ██  ██ ██      ██  ██ ██    ██    ██    ██ ██  ██  ██ 
//+---   ██      ██  ██████  ██      ██ ███████ ██   ████    ██     ██████  ██      ██
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   MOMENTUM  (ex SubTrend — same logic as MainTrend, default length: 50)
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
MA mo                = MA.new()

mo.source            := close
mo_len               = input.int        (50                            ,'Length | Type'            ,inline='02'       ,group=mo_set   ,minval=1)
mo.type              := input.string    ('EMA'                         ,''                               ,inline='02'       ,group=mo_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])

mo.col_mode          := input.string    ('Theme'                       ,'Color mode'                      ,inline='06'       ,group=mo_set   ,options=['Theme', 'Manual', 'Mono'])
mo.col_bull_i        :=input.color      (color.rgb(76, 175, 80)      ,''                               ,inline='06'       ,group=mo_set)
mo.col_bear_i        :=input.color      (color.rgb(242, 54, 69)      ,''                               ,inline='06'       ,group=mo_set)
mo.col_mono          :=input.color      (color.rgb(178, 181, 190)    ,''                               ,inline='06'       ,group=mo_set   ,tooltip=tt_ma_color)
mo.paint             := input.string    (PAINT_SLOPE                   ,'Paint'                           ,inline='07'       ,group=mo_set   ,options=[PAINT_UNI, PAINT_SLOPE, PAINT_PRICE], tooltip=tt_paint_line)

mo.line_trans        :=input.int        (0                             ,'Line'   ,inline='10'       ,group=mo_set   ,minval=0, maxval=100, step=1, tooltip=tt_line)
mo_line_width        = input.int        (3                             ,''                               ,inline='10'       ,group=mo_set   ,options=[1,2,3,4,5])

string mo_tt_tf      = 'Timeframe used for this line.\n\nCTF = chart TF.\n\nHTF 1 / HTF 2 = line follows the HTF calculation mode (Scaled / Security stepped / Security smooth). Trend (rising/falling) still comes from request.security on the real HTF.'
mo_tf                = input.string     ('CTF'                         ,'TF'                              ,inline='03'       ,group=mo_set    ,options=['CTF','HTF 1','HTF 2'], tooltip=mo_tt_tf)

mo_len_active        = mo_len
mo_factor            = mo_tf == 'HTF 1' ? htf1_factor : mo_tf == 'HTF 2' ? htf2_factor : 1
mo_tf_value          = mo_tf == 'HTF 1' ? mx_htf1     : mo_tf == 'HTF 2' ? mx_htf2     : timeframe.period
mo_use_htf           = mo_tf != 'CTF'

[mo_out_ma_htf, mo_slope_bull, mo_slope_bear, mo_wasBullish, mo_wasBearish, mo_long, mo_short] =
	  request.security(syminfo.tickerid, mo_tf_value, f_st_pack(mo.type, mo_len_active), lookahead=barmerge.lookahead_off)

mo_len_line           = f_scale_len(mo.type, mo_len_active, mo_factor)
float mo_out_ma_line  = f_ma(mo.type, mo.source, mo_len_line)
mo_smooth_len           = math.max(2, math.round(mo_factor))
float mo_out_ma_smooth  = f_ema_manual(mo_out_ma_htf, mo_smooth_len)
mo.out_ma               := not mo_use_htf or htf_calc_mode == HTF_MODE_SCALED ? mo_out_ma_line : htf_calc_mode == HTF_MODE_STEPPED ? mo_out_ma_htf : mo_out_ma_smooth
[mo_isBullish, mo_isBearish] = f_paint_line(mo.paint, mo.out_ma, mo_slope_bull, mo_slope_bear)

mo.col_bull          := mo.col_mode == 'Mono' ? color.new(mo.col_mono, mo.line_trans) : mo.col_mode == 'Manual' ? color.new(mo.col_bull_i,mo.line_trans)    : color.new(col.bull,mo.line_trans)
mo.col_bear          := mo.col_mode == 'Mono' ? color.new(mo.col_mono, mo.line_trans) : mo.col_mode == 'Manual' ? color.new(mo.col_bear_i,mo.line_trans)    : color.new(col.bear,mo.line_trans)
color mo_col_uni      = mo.col_mode == 'Mono' ? color.new(mo.col_mono, mo.line_trans) : mo.col_mode == 'Manual' ? color.new(mo.col_bull_i,mo.line_trans)    : color.new(col.neutral,mo.line_trans)
mo.col               := f_line_col(mo.paint, mo_isBullish, mo_isBearish, mo.col_bull, mo.col_bear, mo_col_uni)
mo_txt_color         = mo_isBullish ? mo.col_txt_bull : mo_isBearish ? mo.col_txt_bear : col.neutral

// Momentum HTF — same type/length/paint as MO, evaluated on the selected HTF (for Trender AND).
moh_len_scaled        = f_scale_len(mo.type, mo_len, htf_factor)
float moh_out_ma_scaled = f_ma(mo.type, mo.source, moh_len_scaled)
float moh_out_ma_sec = na
if htf_calc_mode != HTF_MODE_SCALED
	moh_out_ma_sec := request.security(syminfo.tickerid, htf_tf_value, f_ma(mo.type, close, mo_len), lookahead=barmerge.lookahead_off)
float moh_out_ma_smooth = f_ema_manual(moh_out_ma_sec, htf_smooth_len)
float moh_out_ma = htf_calc_mode == HTF_MODE_SCALED ? moh_out_ma_scaled : htf_calc_mode == HTF_MODE_STEPPED ? moh_out_ma_sec : moh_out_ma_smooth
[moh_slope_bull, moh_slope_bear, moh_wasBullish, moh_wasBearish, moh_long, moh_short] = f_getTrend(moh_out_ma)
[moh_isBullish, moh_isBearish] = f_paint_line(mo.paint, moh_out_ma, moh_slope_bull, moh_slope_bear)



//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ███    ███  █████  ██ ███    ██ ████████ ██████  ███████ ███    ██ ██████
//+---   ████  ████ ██   ██ ██ ████   ██    ██    ██   ██ ██      ████   ██ ██   ██
//+---   ██ ████ ██ ███████ ██ ██ ██  ██    ██    ██████  █████   ██ ██  ██ ██   ██
//+---   ██  ██  ██ ██   ██ ██ ██  ██ ██    ██    ██   ██ ██      ██  ██ ██ ██   ██
//+---   ██      ██ ██   ██ ██ ██   ████    ██    ██   ██ ███████ ██   ████ ██████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   MAINTREND
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
MA mt                = MA.new()

mt.source            := close
mt_len               = input.int        (150                           ,'Length | Type'            ,inline='02'       ,group=mt_set   ,minval=1)
mt.type              := input.string    ('EMA'                         ,''                               ,inline='02'       ,group=mt_set   ,options=['EMA','SMA','SMMA (RMA)','DEMA','TMA','WMA','VWMA','ZLEMA','TEMA','HMA','EHMA','THMA','T3','HEMA'])

mt.col_mode          := input.string    ('Theme'                       ,'Color mode'                      ,inline='06'       ,group=mt_set   ,options=['Theme', 'Manual', 'Mono'])
mt.col_bull_i        :=input.color      (color.rgb(76, 175, 80)      ,''                               ,inline='06'       ,group=mt_set)
mt.col_bear_i        :=input.color      (color.rgb(242, 54, 69)      ,''                               ,inline='06'       ,group=mt_set)
mt.col_mono          :=input.color      (color.rgb(178, 181, 190)    ,''                               ,inline='06'       ,group=mt_set   ,tooltip=tt_ma_color)
mt.paint             := input.string    (PAINT_SLOPE                   ,'Paint'                           ,inline='07'       ,group=mt_set   ,options=[PAINT_UNI, PAINT_SLOPE, PAINT_PRICE], tooltip=tt_paint_line)

mt.line_trans        :=input.int        (0                             ,'Line'   ,inline='10'       ,group=mt_set   ,minval=0, maxval=100, step=1, tooltip=tt_line)
mt_line_width        = input.int        (3                             ,''                               ,inline='10'       ,group=mt_set   ,options=[1,2,3,4,5])

string mt_tt_tf      = 'Timeframe used for this line.\n\nCTF = chart TF.\n\nHTF 1 / HTF 2 = line follows the HTF calculation mode (Scaled / Security stepped / Security smooth). Trend (rising/falling) still comes from request.security on the real HTF.'
mt_tf                = input.string     ('CTF'                         ,'TF'                              ,inline='03'       ,group=mt_set    ,options=['CTF','HTF 1','HTF 2'], tooltip=mt_tt_tf)

mt_len_active        = mt_len
mt_factor            = mt_tf == 'HTF 1' ? htf1_factor : mt_tf == 'HTF 2' ? htf2_factor : 1
mt_tf_value          = mt_tf == 'HTF 1' ? mx_htf1     : mt_tf == 'HTF 2' ? mx_htf2     : timeframe.period
mt_use_htf           = mt_tf != 'CTF'

[mt_out_ma_htf, mt_slope_bull, mt_slope_bear, mt_wasBullish, mt_wasBearish, mt_long, mt_short] =
	  request.security(syminfo.tickerid, mt_tf_value, f_st_pack(mt.type, mt_len_active), lookahead=barmerge.lookahead_off)

mt_len_line           = f_scale_len(mt.type, mt_len_active, mt_factor)
float mt_out_ma_line  = f_ma(mt.type, mt.source, mt_len_line)
mt_smooth_len           = math.max(2, math.round(mt_factor))
float mt_out_ma_smooth  = f_ema_manual(mt_out_ma_htf, mt_smooth_len)
mt.out_ma               := not mt_use_htf or htf_calc_mode == HTF_MODE_SCALED ? mt_out_ma_line : htf_calc_mode == HTF_MODE_STEPPED ? mt_out_ma_htf : mt_out_ma_smooth
[mt_isBullish, mt_isBearish] = f_paint_line(mt.paint, mt.out_ma, mt_slope_bull, mt_slope_bear)

mt.col_bull          := mt.col_mode == 'Mono' ? color.new(mt.col_mono, mt.line_trans) : mt.col_mode == 'Manual' ? color.new(mt.col_bull_i,mt.line_trans)    : color.new(col.bull,mt.line_trans)
mt.col_bear          := mt.col_mode == 'Mono' ? color.new(mt.col_mono, mt.line_trans) : mt.col_mode == 'Manual' ? color.new(mt.col_bear_i,mt.line_trans)    : color.new(col.bear,mt.line_trans)
color mt_col_uni      = mt.col_mode == 'Mono' ? color.new(mt.col_mono, mt.line_trans) : mt.col_mode == 'Manual' ? color.new(mt.col_bull_i,mt.line_trans)    : color.new(col.neutral,mt.line_trans)
mt.col               := f_line_col(mt.paint, mt_isBullish, mt_isBearish, mt.col_bull, mt.col_bear, mt_col_uni)
mt_txt_color         = mt_isBullish ? mt.col_txt_bull : mt_isBearish ? mt.col_txt_bear : col.neutral




//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   VWAP  (session location — not an MA type)
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
string tt_vwap       = 'Session VWAP (volume-weighted average price). Not a moving average. Default paint = Price (close above / below VWAP).'

MA vw                = MA.new()
vw.source            := hlc3
vw.col_mode          := input.string    ('Theme'                       ,'Color mode'                      ,inline='06'       ,group=vw_set   ,options=['Theme', 'Manual', 'Mono'], tooltip=tt_vwap)
vw.col_bull_i        :=input.color      (color.rgb(76, 175, 80)      ,''                               ,inline='06'       ,group=vw_set)
vw.col_bear_i        :=input.color      (color.rgb(242, 54, 69)      ,''                               ,inline='06'       ,group=vw_set)
vw.col_mono          :=input.color      (color.rgb(178, 181, 190)    ,''                               ,inline='06'       ,group=vw_set   ,tooltip=tt_ma_color)
vw.paint             := input.string    (PAINT_PRICE                   ,'Paint'                           ,inline='07'       ,group=vw_set   ,options=[PAINT_UNI, PAINT_SLOPE, PAINT_PRICE], tooltip=tt_paint_line)

vw.line_trans        :=input.int        (0                             ,'Line'   ,inline='10'       ,group=vw_set   ,minval=0, maxval=100, step=1, tooltip=tt_line)
vw_line_width        = input.int        (2                             ,''                               ,inline='10'       ,group=vw_set   ,options=[1,2,3,4,5])

float vw_out         = ta.vwap(vw.source)
[vw_slope_bull, vw_slope_bear, vw_wasBullish, vw_wasBearish, vw_long, vw_short] = f_getTrend(vw_out)
[vw_isBullish, vw_isBearish] = f_paint_line(vw.paint, vw_out, vw_slope_bull, vw_slope_bear)

vw.col_bull          := vw.col_mode == 'Mono' ? color.new(vw.col_mono, vw.line_trans) : vw.col_mode == 'Manual' ? color.new(vw.col_bull_i, vw.line_trans) : color.new(col.bull, vw.line_trans)
vw.col_bear          := vw.col_mode == 'Mono' ? color.new(vw.col_mono, vw.line_trans) : vw.col_mode == 'Manual' ? color.new(vw.col_bear_i, vw.line_trans) : color.new(col.bear, vw.line_trans)
color vw_col_uni      = vw.col_mode == 'Mono' ? color.new(vw.col_mono, vw.line_trans) : vw.col_mode == 'Manual' ? color.new(vw.col_bull_i, vw.line_trans) : color.new(col.neutral, vw.line_trans)
vw.col               := f_line_col(vw.paint, vw_isBullish, vw_isBearish, vw.col_bull, vw.col_bear, vw_col_uni)


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ████████ ██████  ███████ ███    ██ ██████  ███████ ██████      ██       ██ ██       ██ ██ ██ 
//+---      ██    ██   ██ ██      ████   ██ ██   ██ ██      ██   ██     ██       ██ ██       ██ ██ ██ 
//+---      ██    ██████  █████   ██ ██  ██ ██   ██ █████   ██████      ██ █████ ██ ██ █████ ██ ██ ██ 
//+---      ██    ██   ██ ██      ██  ██ ██ ██   ██ ██      ██   ██     ██       ██ ██       ██ ██ ██ 
//+---      ██    ██   ██ ███████ ██   ████ ██████  ███████ ██   ██     ██       ██ ██       ██ ██ ██ 
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   [TR1/TR2/TR3] TRENDER I + II + III (TR3 background only)
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//
string tr1_t1         = "Trendbar"
string tr1_t2         = "Background [BG]"
string tr1_t3         = "Trendbar & background [BG]"

tr1_dis_type          = input.string      (tr1_t1                      ,'🔸[TR1] Display'                   ,inline='02'       ,group=tr1_set   ,options=[tr1_t1,tr1_t2,tr1_t3])

tr1_col_mode          = input.string      ('Theme'                     ,'🔸[TR1] Color mode [Bull|Bear]'     ,inline='04'       ,group=tr1_set   ,options=['Theme', 'Manual'])
tr1_col_bull_i        = input.color       (color.green               ,''                                 ,inline='04'       ,group=tr1_set)
tr1_col_bear_i        = input.color       (color.red                 ,''                                 ,inline='04'       ,group=tr1_set)

tr1_trans             = input.int         (0                           ,'🔸[TR1] Trans. [Trendbar|BG]'      ,inline='06'       ,group=tr1_set  ,minval=0  ,maxval=100,  step=1)
tr1_trans_bg          = input.int         (95                          ,''                                 ,inline='06'       ,group=tr1_set  ,minval=0  ,maxval=100,  step=1)

tr2_dis_type          = input.string      (tr1_t1                      ,'🔹[TR2] Display'                   ,inline='10'       ,group=tr1_set   ,options=[tr1_t1,tr1_t2,tr1_t3])

tr2_col_mode          = input.string      ('Theme'                     ,'🔹[TR2] Color mode [Bull|Bear]'     ,inline='12'       ,group=tr1_set   ,options=['Theme', 'Manual'])
tr2_col_bull_i        = input.color       (color.green               ,''                                 ,inline='12'       ,group=tr1_set)
tr2_col_bear_i        = input.color       (color.red                 ,''                                 ,inline='12'       ,group=tr1_set)

tr2_trans             = input.int         (0                           ,'🔹[TR2] Trans. [Trendbar|BG]'      ,inline='14'       ,group=tr1_set  ,minval=0  ,maxval=100,  step=1)
tr2_trans_bg          = input.int         (95                          ,''                                 ,inline='14'       ,group=tr1_set  ,minval=0  ,maxval=100,  step=1)

tr3_col_mode          = input.string      ('Theme'                     ,'🔺[TR3] Color mode [Bull|Bear]'     ,inline='16'       ,group=tr1_set   ,options=['Theme', 'Manual'], tooltip=tt_tr3)
tr3_col_bull_i        = input.color       (color.green               ,''                                 ,inline='16'       ,group=tr1_set)
tr3_col_bear_i        = input.color       (color.red                 ,''                                 ,inline='16'       ,group=tr1_set)
tr3_trans_bg          = input.int         (92                          ,'🔺[TR3] Trans. BG'                 ,inline='18'       ,group=tr1_set  ,minval=0  ,maxval=100,  step=1)


tr1_col_bg_bull       = tr1_col_mode == 'Manual' ? color.new(tr1_col_bull_i, tr1_trans_bg) : color.new(col.bull, tr1_trans_bg)
tr1_col_bg_bear       = tr1_col_mode == 'Manual' ? color.new(tr1_col_bear_i, tr1_trans_bg) : color.new(col.bear, tr1_trans_bg)
tr1_col_bar_bull      = tr1_col_mode == 'Manual' ? color.new(tr1_col_bull_i, tr1_trans) : color.new(col.bull, tr1_trans)
tr1_col_bar_bear      = tr1_col_mode == 'Manual' ? color.new(tr1_col_bear_i, tr1_trans) : color.new(col.bear, tr1_trans)

tr2_col_bg_bull       = tr2_col_mode == 'Manual' ? color.new(tr2_col_bull_i, tr2_trans_bg) : color.new(col.bull, tr2_trans_bg)
tr2_col_bg_bear       = tr2_col_mode == 'Manual' ? color.new(tr2_col_bear_i, tr2_trans_bg) : color.new(col.bear, tr2_trans_bg)
tr2_col_bar_bull      = tr2_col_mode == 'Manual' ? color.new(tr2_col_bull_i, tr2_trans) : color.new(col.bull, tr2_trans)
tr2_col_bar_bear      = tr2_col_mode == 'Manual' ? color.new(tr2_col_bear_i, tr2_trans) : color.new(col.bear, tr2_trans)

tr3_col_bg_bull       = tr3_col_mode == 'Manual' ? color.new(tr3_col_bull_i, tr3_trans_bg) : color.new(col.bull, tr3_trans_bg)
tr3_col_bg_bear       = tr3_col_mode == 'Manual' ? color.new(tr3_col_bear_i, tr3_trans_bg) : color.new(col.bear, tr3_trans_bg)
tr3_col_bar_bull      = tr3_col_mode == 'Manual' ? color.new(tr3_col_bull_i, 0) : color.new(col.bull, 0)
tr3_col_bar_bear      = tr3_col_mode == 'Manual' ? color.new(tr3_col_bear_i, 0) : color.new(col.bear, 0)

//tr1_position          = tr1_position_i == 'Bottom' ? location.bottom : location.top


tr1_im                = input.bool        (false                       ,''                                             ,inline='26'        ,group=tr1_set)
tr2_im                = input.bool        (false                       ,''                                             ,inline='26'        ,group=tr1_set)
tr3_im                = input.bool        (false                       ,'[TR1|TR2|TR3] => [IM] Impulse'                 ,inline='26'        ,group=tr1_set)

tr1_le                = input.bool       (true                         ,''                                             ,inline='28'        ,group=tr1_set)
tr2_le                = input.bool       (true                         ,''                                             ,inline='28'        ,group=tr1_set)
tr3_le                = input.bool       (false                        ,'[TR1|TR2|TR3] => [LE] Lead'                    ,inline='28'        ,group=tr1_set)

tr1_mo                = input.bool       (true                         ,''                                             ,inline='30'        ,group=tr1_set)
tr2_mo                = input.bool       (true                         ,''                                             ,inline='30'        ,group=tr1_set)
tr3_mo                = input.bool       (false                        ,'[TR1|TR2|TR3] => [MO] Momentum'                ,inline='30'        ,group=tr1_set)

tr1_mt                = input.bool       (false                        ,''                                             ,inline='32'        ,group=tr1_set)
tr2_mt                = input.bool       (false                        ,''                                             ,inline='32'        ,group=tr1_set)
tr3_mt                = input.bool       (false                        ,'[TR1|TR2|TR3] => [MT] MainTrend'                ,inline='32'        ,group=tr1_set)

tr1_imh               = input.bool        (false                       ,''                                             ,inline='34'        ,group=tr1_set)
tr2_imh               = input.bool        (false                       ,''                                             ,inline='34'        ,group=tr1_set)
tr3_imh               = input.bool        (false                       ,'[TR1|TR2|TR3] => [IM HTF] Impulse HTF'          ,inline='34'        ,group=tr1_set)

tr1_leh               = input.bool       (false                        ,''                                             ,inline='36'        ,group=tr1_set)
tr2_leh               = input.bool       (true                         ,''                                             ,inline='36'        ,group=tr1_set)
tr3_leh               = input.bool       (false                        ,'[TR1|TR2|TR3] => [LE HTF] Lead HTF'            ,inline='36'        ,group=tr1_set)

tr1_moh               = input.bool       (false                        ,''                                             ,inline='38'        ,group=tr1_set)
tr2_moh               = input.bool       (true                         ,''                                             ,inline='38'        ,group=tr1_set)
tr3_moh               = input.bool       (false                        ,'[TR1|TR2|TR3] => [MO HTF] Momentum HTF'        ,inline='38'        ,group=tr1_set)

tr1_vw                = input.bool       (false                        ,''                                             ,inline='40'        ,group=tr1_set)
tr2_vw                = input.bool       (false                        ,''                                             ,inline='40'        ,group=tr1_set)
tr3_vw                = input.bool       (false                        ,'[TR1|TR2|TR3] => [VW] Price vs VWAP'           ,inline='40'        ,group=tr1_set)


//tr1_mt_htf            = input.bool       (false                        ,''                                             ,inline='40'        ,group=tr1_set)
//tr2_mt_htf            = input.bool       (false                        ,'[TR1|TR2] => [MT HTF] MainTrend HTF'          ,inline='40'        ,group=tr1_set)


bool placeholder      = true
bool im_tr            = im.paint   != PAINT_UNI
bool le_tr            = le.paint   != PAINT_UNI
bool htf_tr           = htf.paint  != PAINT_UNI
bool mo_tr            = mo.paint   != PAINT_UNI
bool mt_tr            = mt.paint   != PAINT_UNI
bool vw_tr            = vw.paint   != PAINT_UNI

bool tr1_live           = (tr1_im and im_tr) or (tr1_le and le_tr) or (tr1_mo and mo_tr) or (tr1_mt and mt_tr) or (tr1_imh and htf_tr) or (tr1_leh and htf_tr) or (tr1_moh and mo_tr) or (tr1_vw and vw_tr)
bool tr2_live           = (tr2_im and im_tr) or (tr2_le and le_tr) or (tr2_mo and mo_tr) or (tr2_mt and mt_tr) or (tr2_imh and htf_tr) or (tr2_leh and htf_tr) or (tr2_moh and mo_tr) or (tr2_vw and vw_tr)
bool tr3_live           = (tr3_im and im_tr) or (tr3_le and le_tr) or (tr3_mo and mo_tr) or (tr3_mt and mt_tr) or (tr3_imh and htf_tr) or (tr3_leh and htf_tr) or (tr3_moh and mo_tr) or (tr3_vw and vw_tr)

tr1_isBullish_i         = 	tr1_live and
							  (tr1_im and im_tr   ? im_isBullish     : placeholder) and
							  (tr1_le and le_tr   ? le_isBullish     : placeholder) and
							  (tr1_mo and mo_tr   ? mo_isBullish     : placeholder) and
							  (tr1_mt and mt_tr   ? mt_isBullish     : placeholder) and
							  (tr1_imh and htf_tr ? imh_isBullish    : placeholder) and
							  (tr1_leh and htf_tr ? leh_isBullish    : placeholder) and
							  (tr1_moh and mo_tr  ? moh_isBullish    : placeholder) and
							  (tr1_vw and vw_tr   ? vw_isBullish     : placeholder)

tr1_isBearish_i         = 	tr1_live and
							  (tr1_im and im_tr   ? im_isBearish     : placeholder) and
							  (tr1_le and le_tr   ? le_isBearish     : placeholder) and
							  (tr1_mo and mo_tr   ? mo_isBearish     : placeholder) and
							  (tr1_mt and mt_tr   ? mt_isBearish     : placeholder) and
							  (tr1_imh and htf_tr ? imh_isBearish    : placeholder) and
							  (tr1_leh and htf_tr ? leh_isBearish    : placeholder) and
							  (tr1_moh and mo_tr  ? moh_isBearish    : placeholder) and
							  (tr1_vw and vw_tr   ? vw_isBearish     : placeholder)

// TF suffix for MO/MT based on each line's selected TF.
_mo_suffix              = mo_tf == 'HTF 1' ? ' ['+label_htf1+']' : mo_tf == 'HTF 2' ? ' ['+label_htf2+']' : ''
_mt_suffix              = mt_tf == 'HTF 1' ? ' ['+label_htf1+']' : mt_tf == 'HTF 2' ? ' ['+label_htf2+']' : ''

tr1_txt                  = 'TR 1 -'
tr1_txt                 := tr1_txt + (tr1_im        ? 'IM ' : '')
tr1_txt                 := tr1_txt + (tr1_le        ? 'LE ' : '')
tr1_txt                 := tr1_txt + (tr1_mo        ? 'MO'+_mo_suffix+' ' : '')
tr1_txt                 := tr1_txt + (tr1_mt        ? 'MT'+_mt_suffix+' ' : '')
tr1_txt                 := tr1_txt + (tr1_imh       ? 'IM '+'['+htf_label+']' : '')
tr1_txt                 := tr1_txt + (tr1_leh       ? 'LE '+'['+htf_label+']' : '')
tr1_txt                 := tr1_txt + (tr1_moh       ? 'MO '+'['+htf_label+']' : '')
tr1_txt                 := tr1_txt + (tr1_vw        ? 'VW ' : '')


tr2_isBullish_i         = 	tr2_live and
							  (tr2_im and im_tr   ? im_isBullish     : placeholder) and
							  (tr2_le and le_tr   ? le_isBullish     : placeholder) and
							  (tr2_mo and mo_tr   ? mo_isBullish     : placeholder) and
							  (tr2_mt and mt_tr   ? mt_isBullish     : placeholder) and
							  (tr2_imh and htf_tr ? imh_isBullish    : placeholder) and
							  (tr2_leh and htf_tr ? leh_isBullish    : placeholder) and
							  (tr2_moh and mo_tr  ? moh_isBullish    : placeholder) and
							  (tr2_vw and vw_tr   ? vw_isBullish     : placeholder)

tr2_isBearish_i         = 	tr2_live and
							  (tr2_im and im_tr   ? im_isBearish     : placeholder) and
							  (tr2_le and le_tr   ? le_isBearish     : placeholder) and
							  (tr2_mo and mo_tr   ? mo_isBearish     : placeholder) and
							  (tr2_mt and mt_tr   ? mt_isBearish     : placeholder) and
							  (tr2_imh and htf_tr ? imh_isBearish    : placeholder) and
							  (tr2_leh and htf_tr ? leh_isBearish    : placeholder) and
							  (tr2_moh and mo_tr  ? moh_isBearish    : placeholder) and
							  (tr2_vw and vw_tr   ? vw_isBearish     : placeholder)


tr2_txt                  = 'TR 2 -'
tr2_txt                 := tr2_txt + (tr2_im        ? 'IM ' : '')
tr2_txt                 := tr2_txt + (tr2_le        ? 'LE ' : '')
tr2_txt                 := tr2_txt + (tr2_mo        ? 'MO'+_mo_suffix+' ' : '')
tr2_txt                 := tr2_txt + (tr2_mt        ? 'MT'+_mt_suffix+' ' : '')
tr2_txt                 := tr2_txt + (tr2_imh       ? 'IM '+'['+htf_label+']' : '')
tr2_txt                 := tr2_txt + (tr2_leh       ? 'LE '+'['+htf_label+']' : '')
tr2_txt                 := tr2_txt + (tr2_moh       ? 'MO '+'['+htf_label+']' : '')
tr2_txt                 := tr2_txt + (tr2_vw        ? 'VW ' : '')

tr3_txt                  = 'TR 3 -'
tr3_txt                 := tr3_txt + (tr3_im        ? 'IM ' : '')
tr3_txt                 := tr3_txt + (tr3_le        ? 'LE ' : '')
tr3_txt                 := tr3_txt + (tr3_mo        ? 'MO'+_mo_suffix+' ' : '')
tr3_txt                 := tr3_txt + (tr3_mt        ? 'MT'+_mt_suffix+' ' : '')
tr3_txt                 := tr3_txt + (tr3_imh       ? 'IM '+'['+htf_label+']' : '')
tr3_txt                 := tr3_txt + (tr3_leh       ? 'LE '+'['+htf_label+']' : '')
tr3_txt                 := tr3_txt + (tr3_moh       ? 'MO '+'['+htf_label+']' : '')
tr3_txt                 := tr3_txt + (tr3_vw        ? 'VW ' : '')

tr3_isBullish_i         = 	tr3_live and
							  (tr3_im and im_tr   ? im_isBullish     : placeholder) and
							  (tr3_le and le_tr   ? le_isBullish     : placeholder) and
							  (tr3_mo and mo_tr   ? mo_isBullish     : placeholder) and
							  (tr3_mt and mt_tr   ? mt_isBullish     : placeholder) and
							  (tr3_imh and htf_tr ? imh_isBullish    : placeholder) and
							  (tr3_leh and htf_tr ? leh_isBullish    : placeholder) and
							  (tr3_moh and mo_tr  ? moh_isBullish    : placeholder) and
							  (tr3_vw and vw_tr   ? vw_isBullish     : placeholder)

tr3_isBearish_i         = 	tr3_live and
							  (tr3_im and im_tr   ? im_isBearish     : placeholder) and
							  (tr3_le and le_tr   ? le_isBearish     : placeholder) and
							  (tr3_mo and mo_tr   ? mo_isBearish     : placeholder) and
							  (tr3_mt and mt_tr   ? mt_isBearish     : placeholder) and
							  (tr3_imh and htf_tr ? imh_isBearish    : placeholder) and
							  (tr3_leh and htf_tr ? leh_isBearish    : placeholder) and
							  (tr3_moh and mo_tr  ? moh_isBearish    : placeholder) and
							  (tr3_vw and vw_tr   ? vw_isBearish     : placeholder)


tr1_noTrend             = tr1_isBullish_i == false and tr1_isBearish_i == false
tr2_noTrend             = tr2_isBullish_i == false and tr2_isBearish_i == false

tr1_col                 = col.trans
tr1_txt_col             = col.trans
tr1_col_bg              = col.trans
tr1_barcolor            = col.trans

if  (tr1_im or tr1_le or tr1_mo or tr1_mt or tr1_imh or tr1_leh or tr1_moh or tr1_vw) and show.tr1
	tr1_col             := tr1_isBullish_i ? tr1_col_bar_bull : tr1_isBearish_i ? tr1_col_bar_bear : col.neutral
	tr1_txt_col         := tr1_isBullish_i ? col.txt_bull     : tr1_isBearish_i ? col.txt_bear     : col.white
	tr1_col_bg          := tr1_isBullish_i ? tr1_col_bg_bull  : tr1_isBearish_i ? tr1_col_bg_bear  : col.trans
	tr1_barcolor        := tr1_col

// alerts()
tr1_long                = tr1_isBullish_i and ( tr1_noTrend[1] or tr1_isBearish_i[1] )
tr1_short               = tr1_isBearish_i and ( tr1_noTrend[1] or tr1_isBullish_i[1] )


tr2_col                 = col.trans
tr2_txt_col             = col.trans
tr2_col_bg              = col.trans
tr2_barcolor            = col.trans

if  (tr2_im or tr2_le or tr2_mo or tr2_mt or tr2_imh or tr2_leh or tr2_moh or tr2_vw) and show.tr2
	tr2_col             := tr2_isBullish_i ? tr2_col_bar_bull : tr2_isBearish_i ? tr2_col_bar_bear : col.neutral
	tr2_txt_col         := tr2_isBullish_i ? col.txt_bull     : tr2_isBearish_i ? col.txt_bear     : col.white
	tr2_col_bg          := tr2_isBullish_i ? tr2_col_bg_bull  : tr2_isBearish_i ? tr2_col_bg_bear  : col.trans
	tr2_barcolor        := tr2_col

// alerts()
tr2_long                = tr2_isBullish_i and ( tr2_noTrend[1] or tr2_isBearish_i[1] )
tr2_short               = tr2_isBearish_i and ( tr2_noTrend[1] or tr2_isBullish_i[1] )

tr3_col_bg              = col.trans
tr3_barcolor            = col.trans
if  (tr3_im or tr3_le or tr3_mo or tr3_mt or tr3_imh or tr3_leh or tr3_moh or tr3_vw)
	tr3_barcolor        := tr3_isBullish_i ? tr3_col_bar_bull : tr3_isBearish_i ? tr3_col_bar_bear : col.neutral
if  (tr3_im or tr3_le or tr3_mo or tr3_mt or tr3_imh or tr3_leh or tr3_moh or tr3_vw) and show.tr3
	tr3_col_bg          := tr3_isBullish_i ? tr3_col_bg_bull : tr3_isBearish_i ? tr3_col_bg_bear : col.trans

tr3_noTrend             = tr3_isBullish_i == false and tr3_isBearish_i == false
tr3_long                = tr3_isBullish_i and ( tr3_noTrend[1] or tr3_isBearish_i[1] )
tr3_short               = tr3_isBearish_i and ( tr3_noTrend[1] or tr3_isBullish_i[1] )

cloud_long              = cloud_bull  and not cloud_bull[1]
cloud_short             = cloud_bear  and not cloud_bear[1]
hcloud_long             = hcloud_bull and not hcloud_bull[1]
hcloud_short            = hcloud_bear and not hcloud_bear[1]
mo_al_long              = mo_isBullish and not mo_isBullish[1]
mo_al_short             = mo_isBearish and not mo_isBearish[1]
mt_al_long              = mt_isBullish and not mt_isBullish[1]
mt_al_short             = mt_isBearish and not mt_isBearish[1]
vw_al_long              = vw_isBullish and not vw_isBullish[1]
vw_al_short             = vw_isBearish and not vw_isBearish[1]

// ═══════════════════════════════════════════════════════════════
// SIGNAL OUTPUT — 6-value series (for TM.TRENDER signal hub)
//   +600/-600  TR1 Trender Signal (persistent)
//   +620/-620  TR2 Trender Signal (persistent)
//   +640/-640  IM Impulse trend
//   +660/-660  LE Lead Trend
//   +680/-680  MO Momentum Trend
// ═══════════════════════════════════════════════════════════════

// TR1: persistent +600/-600
var int sig_tr1 = 0
if tr1_long
	sig_tr1 := 600
if tr1_short
	sig_tr1 := -600

// TR2: persistent +620/-620
var int sig_tr2 = 0
if tr2_long
	sig_tr2 := 620
if tr2_short
	sig_tr2 := -620

// Individual MAs: live trend (not persistent)
int sig_im = im_isBullish ? 640 : im_isBearish ? -640 : 0
int sig_le = le_isBullish ? 660 : le_isBearish ? -660 : 0
int sig_mo = mo_isBullish ? 680 : mo_isBearish ? -680 : 0

plot(sig_tr1, "🔸🔷 TR1 -600-", display=display.status_line)
plot(sig_tr2, "🔸🔷 TR2 -620-", display=display.status_line)
plot(sig_im,  "🔸🔷 IM -640-",  display=display.none)
plot(sig_le,  "🔸🔷 LE -660-",  display=display.none)
plot(sig_mo,  "🔸🔷 MO -680-",  display=display.none)







//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ███████  ██       ██████  ████████ ███████
//+---   ██    ██ ██      ██    ██    ██    ██
//+---   ██████   ██      ██    ██    ██    ███████
//+---   ██       ██      ██    ██    ██         ██
//+---   ██       ███████  ██████     ██    ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   PLOTS
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//

// ═══════════════════════════════════════════════════════════════
// Layout
//   'Band'  = fill between IM↔LE and IMH↔LEH
//             lines 100% transparent
//   'Lines' = classic MA lines without fill
//   band_trans = central fill transparency
// ═══════════════════════════════════════════════════════════════
bool _isBand = pre.layout == 'Band'
int  _bt     = band_trans      // fill transparency shortcut
int  _bt2    = math.min(98, band_trans + 5) // HTF slightly fainter

//+--- CTF: Impulse / Lead cloud
color _im_col = _isBand ? color.new(im.col, 100) : im.col
color _le_col = _isBand ? color.new(le.col, 100) : le.col

p_im = plot(_isBand and show.im ? im.out_ma : na, title="[IM] Impulse",    color=_im_col, linewidth=im_line_width)
p_le = plot(_isBand and show.le ? le.out_ma : na, title="[LE] Lead",      color=_le_col, linewidth=le_line_width)

plot(not _isBand and show.im ? im.out_ma : na, title="[IM] Impulse Line",   color=im.col, linewidth=im_line_width)
plot(not _isBand and show.le ? le.out_ma : na, title="[LE] Lead Line",     color=le.col, linewidth=le_line_width)

//+--- HTF: Impulse / Lead cloud
color _imh_col = _isBand ? color.new(imh_col, 100) : imh_col
color _leh_col = _isBand ? color.new(leh_col, 100) : leh_col

p_imh = plot(_isBand and show.imh ? imh_out_ma : na, title="[IMH] Impulse HTF",   color=_imh_col, linewidth=htf_line_width)
p_leh = plot(_isBand and show.leh ? leh_out_ma : na, title="[LEH] Lead HTF",     color=_leh_col, linewidth=htf_line_width)

plot(not _isBand and show.imh ? imh_out_ma : na, title="[IMH] Impulse HTF Line",   color=imh_col, linewidth=htf_line_width)
plot(not _isBand and show.leh ? leh_out_ma : na, title="[LEH] Lead HTF Line",     color=leh_col, linewidth=htf_line_width)

color _fill_im_le = _isBand and show.im and show.le ? (cloud_bull ? color.new(col.bull, _bt) : cloud_bear ? color.new(col.bear, _bt) : color.new(col.neutral, _bt)) : na
fill(p_im, p_le, _fill_im_le, title="Fill IM↔LE")

color _fill_imh_leh = _isBand and show.imh and show.leh ? (hcloud_bull ? color.new(col.bull, _bt2) : hcloud_bear ? color.new(col.bear, _bt2) : color.new(col.neutral, _bt2)) : na
fill(p_imh, p_leh, _fill_imh_leh, title="Fill IMH↔LEH")

//+--- Momentum / MainTrend (own layout, independent of Band/Lines)
plot(show.mo ? mo.out_ma : na, title="[MO] MOMENTUM",  color=mo.col, linewidth=mo_line_width)
plot(show.mt ? mt.out_ma : na, title="[MT] MAINTREND", color=mt.col, linewidth=mt_line_width)
plot(show.vw ? vw_out : na,    title="[VW] VWAP",      color=vw.col, linewidth=vw_line_width)

f_bar_color(type) =>
	switch type
		'[TH] Theme'       => show.bc ? col.bar : na
		'[TR1] Trender 1'  => show.bc ? tr1_barcolor : na
		'[TR2] Trender 2'  => show.bc ? tr2_barcolor : na
		'[TR3] Trender 3'  => show.bc ? tr3_barcolor : na

barcolor(color = f_bar_color(col.bar_type), editable=false)

// ═══════════════════════════════════════════════════════════════
// TRENDER I (top) + TRENDER II (bottom) + TRENDER III (background only)
// ═══════════════════════════════════════════════════════════════

bool _tr1_active = (tr1_im or tr1_le or tr1_mo or tr1_mt or tr1_imh or tr1_leh or tr1_moh or tr1_vw) and show.tr1
bool _tr2_active = (tr2_im or tr2_le or tr2_mo or tr2_mt or tr2_imh or tr2_leh or tr2_moh or tr2_vw) and show.tr2
bool _tr3_active = (tr3_im or tr3_le or tr3_mo or tr3_mt or tr3_imh or tr3_leh or tr3_moh or tr3_vw) and show.tr3

//+--- TR1: BG
bgcolor(_tr1_active and (tr1_dis_type == 'Background [BG]' or tr1_dis_type == 'Trendbar & background [BG]') ? tr1_col_bg : col.trans)

//+--- TR1: trendbar at top (same as TM.ALGO)
plotshape(_tr1_active and not (tr1_dis_type == 'Background [BG]') and tr1_long                       ? close : na, style=shape.triangleup,   title='Trender 1', location=location.top, color=tr1_col, editable=true, size=size.tiny)
plotshape(_tr1_active and not (tr1_dis_type == 'Background [BG]') and tr1_short                      ? close : na, style=shape.triangledown, title='Trender 1', location=location.top, color=tr1_col, editable=true, size=size.tiny)
plotshape(_tr1_active and not (tr1_dis_type == 'Background [BG]') and not tr1_long and not tr1_short ? close : na, style=shape.square,       title='Trender 1', location=location.top, color=tr1_col, editable=true)

//+--- TR2: BG
bgcolor(_tr2_active and (tr2_dis_type == 'Background [BG]' or tr2_dis_type == 'Trendbar & background [BG]') ? tr2_col_bg : col.trans)

//+--- TR2: trendbar at bottom (same as TM.ALGO)
plotshape(_tr2_active and not (tr2_dis_type == 'Background [BG]') and tr2_long                       ? close : na, style=shape.triangleup,   title='Trender 2', location=location.bottom, color=tr2_col, editable=true, size=size.tiny)
plotshape(_tr2_active and not (tr2_dis_type == 'Background [BG]') and tr2_short                      ? close : na, style=shape.triangledown, title='Trender 2', location=location.bottom, color=tr2_col, editable=true, size=size.tiny)
plotshape(_tr2_active and not (tr2_dis_type == 'Background [BG]') and not tr2_long and not tr2_short ? close : na, style=shape.square,       title='Trender 2', location=location.bottom, color=tr2_col, editable=true)

//+--- TR3: background only (no shapes, no InfoBoard)
bgcolor(_tr3_active ? tr3_col_bg : col.trans)



// ═══════════════════════════════════════════════════════════════
// INFOBOARD — like TM.ALGO: horizontal tables, colored cells
// TR1 top, TR2 bottom, preset + HTF as labels
// ═══════════════════════════════════════════════════════════════

string _ib_htf_label = htf_label
// TF suffix for ST/MT cells uses _mo_suffix / _mt_suffix
//       from the TR block above (same values).

var table ib1 = table.new(ib1_tbl_position, columns=12, rows=1, bgcolor=ib_col_bg, frame_color=ib_col_frame, frame_width=ib_hide_frame ? 0 : 1)
var table ib2 = table.new(ib2_tbl_position, columns=12, rows=1, bgcolor=ib_col_bg, frame_color=ib_col_frame, frame_width=ib_hide_frame ? 0 : 1)

if barstate.islast
	bool _ib1_on = show.ib1
	bool _ib2_on = show.ib2
	table.set_position(ib1, ib1_tbl_position)
	table.set_position(ib2, ib2_tbl_position)
	table.set_bgcolor(ib1, _ib1_on ? ib_col_bg : #00000000)
	table.set_bgcolor(ib2, _ib2_on ? ib_col_bg : #00000000)
	table.set_frame_color(ib1, ib_col_frame)
	table.set_frame_color(ib2, ib_col_frame)
	table.set_frame_width(ib1, _ib1_on and not ib_hide_frame ? 1 : 0)
	table.set_frame_width(ib2, _ib2_on and not ib_hide_frame ? 1 : 0)
	table.clear(ib1, 0, 0, 11, 0)
	table.clear(ib2, 0, 0, 11, 0)

	if _ib1_on
		int _c = 0
		table.cell(ib1, _c, 0, 'TR1', text_color=tr1_txt_col, text_halign=text.align_center, text_size=ib_txt_size, bgcolor=tr1_col, text_font_family=sys.font, text_formatting=text.format_bold)
		_c += 1
		_c := f_ib_cell(ib1, _c, pre.type, ib_col_txt, ib_col_bg, ib_txt_size, sys.font)
		if tr1_im
			_c := f_ib_cell(ib1, _c, 'IM', im_isBullish ? col.txt_bull : im_isBearish ? col.txt_bear : col.white, im_isBullish ? col.bull : im_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr1_le
			_c := f_ib_cell(ib1, _c, 'LE', le_isBullish ? col.txt_bull : le_isBearish ? col.txt_bear : col.white, le_isBullish ? col.bull : le_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr1_mo
			_c := f_ib_cell(ib1, _c, 'MO'+_mo_suffix, mo_isBullish ? col.txt_bull : col.txt_bear, mo_isBullish ? col.bull : col.bear, ib_txt_size, sys.font)
		if tr1_mt
			_c := f_ib_cell(ib1, _c, 'MT'+_mt_suffix, mt_isBullish ? col.txt_bull : col.txt_bear, mt_isBullish ? col.bull : col.bear, ib_txt_size, sys.font)
		if tr1_imh
			_c := f_ib_cell(ib1, _c, 'IM ['+_ib_htf_label+']', imh_isBullish ? col.txt_bull : imh_isBearish ? col.txt_bear : col.white, imh_isBullish ? col.bull : imh_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr1_leh
			_c := f_ib_cell(ib1, _c, 'LE ['+_ib_htf_label+']', leh_isBullish ? col.txt_bull : leh_isBearish ? col.txt_bear : col.white, leh_isBullish ? col.bull : leh_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr1_moh
			_c := f_ib_cell(ib1, _c, 'MO ['+_ib_htf_label+']', moh_isBullish ? col.txt_bull : moh_isBearish ? col.txt_bear : col.white, moh_isBullish ? col.bull : moh_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr1_vw
			_c := f_ib_cell(ib1, _c, 'VW', vw_isBullish ? col.txt_bull : col.txt_bear, vw_isBullish ? col.bull : col.bear, ib_txt_size, sys.font)

	if _ib2_on
		int _c2 = 0
		table.cell(ib2, _c2, 0, 'TR2', text_color=tr2_txt_col, text_halign=text.align_center, text_size=ib_txt_size, bgcolor=tr2_col, text_font_family=sys.font, text_formatting=text.format_bold)
		_c2 += 1
		_c2 := f_ib_cell(ib2, _c2, pre.type, ib_col_txt, ib_col_bg, ib_txt_size, sys.font)
		if tr2_im
			_c2 := f_ib_cell(ib2, _c2, 'IM', im_isBullish ? col.txt_bull : im_isBearish ? col.txt_bear : col.white, im_isBullish ? col.bull : im_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr2_le
			_c2 := f_ib_cell(ib2, _c2, 'LE', le_isBullish ? col.txt_bull : le_isBearish ? col.txt_bear : col.white, le_isBullish ? col.bull : le_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr2_mo
			_c2 := f_ib_cell(ib2, _c2, 'MO'+_mo_suffix, mo_isBullish ? col.txt_bull : col.txt_bear, mo_isBullish ? col.bull : col.bear, ib_txt_size, sys.font)
		if tr2_mt
			_c2 := f_ib_cell(ib2, _c2, 'MT'+_mt_suffix, mt_isBullish ? col.txt_bull : col.txt_bear, mt_isBullish ? col.bull : col.bear, ib_txt_size, sys.font)
		if tr2_imh
			_c2 := f_ib_cell(ib2, _c2, 'IM ['+_ib_htf_label+']', imh_isBullish ? col.txt_bull : imh_isBearish ? col.txt_bear : col.white, imh_isBullish ? col.bull : imh_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr2_leh
			_c2 := f_ib_cell(ib2, _c2, 'LE ['+_ib_htf_label+']', leh_isBullish ? col.txt_bull : leh_isBearish ? col.txt_bear : col.white, leh_isBullish ? col.bull : leh_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr2_moh
			_c2 := f_ib_cell(ib2, _c2, 'MO ['+_ib_htf_label+']', moh_isBullish ? col.txt_bull : moh_isBearish ? col.txt_bear : col.white, moh_isBullish ? col.bull : moh_isBearish ? col.bear : col.neutral, ib_txt_size, sys.font)
		if tr2_vw
			_c2 := f_ib_cell(ib2, _c2, 'VW', vw_isBullish ? col.txt_bull : col.txt_bear, vw_isBullish ? col.bull : col.bear, ib_txt_size, sys.font)






//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---    █████  ██      ███████ ██████  ████████ ███████ 
//+---   ██   ██ ██      ██      ██   ██    ██    ██      
//+---   ███████ ██      █████   ██████     ██    ███████ 
//+---   ██   ██ ██      ██      ██   ██    ██         ██ 
//+---   ██   ██ ███████ ███████ ██   ██    ██    ███████
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   ALERTS
//+---                input              def_val                       title                              inline             group            opt/tooltips/etc.        ---+//
//+------------------+-------------------+-----------------------------+----------------------------------+------------------+----------------+---------------------------+//

string AL_CLOSE      = 'Once per bar close'
string AL_BAR        = 'Once per bar'
al_mode_i            = input.string      (AL_CLOSE                     ,'Alert mode'                      ,inline='00',      group=al_set   ,options=[AL_CLOSE, AL_BAR], tooltip=tt_alert)
al_mode              = al_mode_i == AL_BAR ? alert.freq_once_per_bar : alert.freq_once_per_bar_close

al_tr1               = input.bool        (false                        ,'[TR1] Trender 1'                 ,inline='10',      group=al_set)
al_tr2               = input.bool        (true                         ,'[TR2] Trender 2'                 ,inline='12',      group=al_set)
al_tr3               = input.bool        (false                        ,'[TR3] Trender 3'                 ,inline='14',      group=al_set)
al_cloud             = input.bool        (false                        ,'[CL] Cloud'                      ,inline='20',      group=al_set)
al_hcloud            = input.bool        (false                        ,'[CLH] Cloud HTF'                 ,inline='22',      group=al_set)
al_mo                = input.bool        (false                        ,'[MO] Momentum'                   ,inline='30',      group=al_set)
al_mt                = input.bool        (false                        ,'[MT] MainTrend'                  ,inline='32',      group=al_set)
al_vw                = input.bool        (false                        ,'[VW] VWAP'                       ,inline='34',      group=al_set)

f_Alert(cond, txt, alert_mode) =>
	if cond
		alert(txt + ' | TF: ' + sys.tf_short + ' | Price: ' + str.tostring(close), alert_mode)

f_Alert(tr1_long     and al_tr1,    '🟢 [TR1] LONG ▲ ' + tr1_txt,  al_mode)
f_Alert(tr1_short    and al_tr1,    '🔴 [TR1] SHORT ▼ ' + tr1_txt, al_mode)
f_Alert(tr2_long     and al_tr2,    '🟢 [TR2] LONG ▲ ' + tr2_txt,  al_mode)
f_Alert(tr2_short    and al_tr2,    '🔴 [TR2] SHORT ▼ ' + tr2_txt, al_mode)
f_Alert(tr3_long     and al_tr3,    '🟢 [TR3] LONG ▲ ' + tr3_txt,  al_mode)
f_Alert(tr3_short    and al_tr3,    '🔴 [TR3] SHORT ▼ ' + tr3_txt, al_mode)
f_Alert(cloud_long   and al_cloud,  '🟢 [CL] LONG ▲',              al_mode)
f_Alert(cloud_short  and al_cloud,  '🔴 [CL] SHORT ▼',             al_mode)
f_Alert(hcloud_long  and al_hcloud, '🟢 [CLH] LONG ▲',             al_mode)
f_Alert(hcloud_short and al_hcloud, '🔴 [CLH] SHORT ▼',            al_mode)
f_Alert(mo_al_long   and al_mo,     '🟢 [MO] LONG ▲',              al_mode)
f_Alert(mo_al_short  and al_mo,     '🔴 [MO] SHORT ▼',             al_mode)
f_Alert(mt_al_long   and al_mt,     '🟢 [MT] LONG ▲',              al_mode)
f_Alert(mt_al_short  and al_mt,     '🔴 [MT] SHORT ▼',             al_mode)
f_Alert(vw_al_long   and al_vw,     '🟢 [VW] LONG ▲',              al_mode)
f_Alert(vw_al_short  and al_vw,     '🔴 [VW] SHORT ▼',             al_mode)

alertcondition(tr1_long,     title='🟢 [TR1] LONG ▲',  message='🟢 [TR1] LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(tr1_short,    title='🔴 [TR1] SHORT ▼', message='🔴 [TR1] SHORT ▼ | TF: {{interval}} | Price: {{close}}')
alertcondition(tr2_long,     title='🟢 [TR2] LONG ▲',  message='🟢 [TR2] LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(tr2_short,    title='🔴 [TR2] SHORT ▼', message='🔴 [TR2] SHORT ▼ | TF: {{interval}} | Price: {{close}}')
alertcondition(tr3_long,     title='🟢 [TR3] LONG ▲',  message='🟢 [TR3] LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(tr3_short,    title='🔴 [TR3] SHORT ▼', message='🔴 [TR3] SHORT ▼ | TF: {{interval}} | Price: {{close}}')
alertcondition(cloud_long,   title='🟢 [CL] LONG ▲',   message='🟢 [CL] Cloud LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(cloud_short,  title='🔴 [CL] SHORT ▼',  message='🔴 [CL] Cloud SHORT ▼ | TF: {{interval}} | Price: {{close}}')
alertcondition(hcloud_long,  title='🟢 [CLH] LONG ▲',  message='🟢 [CLH] Cloud HTF LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(hcloud_short, title='🔴 [CLH] SHORT ▼', message='🔴 [CLH] Cloud HTF SHORT ▼ | TF: {{interval}} | Price: {{close}}')
alertcondition(mo_al_long,   title='🟢 [MO] LONG ▲',   message='🟢 [MO] Momentum LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(mo_al_short,  title='🔴 [MO] SHORT ▼',  message='🔴 [MO] Momentum SHORT ▼ | TF: {{interval}} | Price: {{close}}')
alertcondition(mt_al_long,   title='🟢 [MT] LONG ▲',   message='🟢 [MT] MainTrend LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(mt_al_short,  title='🔴 [MT] SHORT ▼',  message='🔴 [MT] MainTrend SHORT ▼ | TF: {{interval}} | Price: {{close}}')
alertcondition(vw_al_long,   title='🟢 [VW] LONG ▲',   message='🟢 [VW] VWAP LONG ▲ | TF: {{interval}} | Price: {{close}}')
alertcondition(vw_al_short,  title='🔴 [VW] SHORT ▼',  message='🔴 [VW] VWAP SHORT ▼ | TF: {{interval}} | Price: {{close}}')


//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
//+---   SCRIPT END
//+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+//
````
