# Fibonacci Retracement [AFD]

- url: https://www.tradingview.com/script/AUtiWghc-Fibonacci-Retracement-AFD/
- type: indicator
- pine_id: PUB;89f5660726e446a89e2ea6063f73717f
- version: 1.0

## Description

Fibonacci levels that find their own two points, and keep finding them.

[b]THE PROBLEM WITH DRAWING THEM BY HAND[/b]

A retracement is two clicks and a judgement call. The judgement is the hard part - which high, which low, and whether the leg you just measured is one move or two glued together. Then the session rolls over and the answer changes, so you do it again.

This draws the grid from the chart's own data instead. You tell it which range matters and it finds the two points itself, every bar, forever. Come back after the open and it has already re-anchored to the new day.

[b]PICKING THE RANGE[/b]

Four choices, and they are all self-maintaining.

[b]Current Day[/b] is the default and it is the one most intraday traders want - today's high and low, re-anchoring at each session open. [b]Previous Day[/b] is yesterday's, and it draws from yesterday's start rather than today's, so the geometry sits over the data it came from. [b]Current Week[/b] is the same idea one period up.

[image]https://www.tradingview.com/x/AAY9blYe/[/image]

[b]Latest Swing[/b] is the interesting one. It takes the last confirmed swing high and low, and it insists they alternate.

That insistence matters more than it sounds. ta.pivothigh() and ta.pivotlow() are independent detectors, and a real chart prints two, three, four highs in a row with no qualifying low between them. Take the most recent of each and you get a "leg" whose high end is simply the latest high, not the highest one in the span - so the grid measures a move that never happened as a single push, and 0.618 lands somewhere with no relationship to anything. Here, a pivot on the same side as the last one replaces it only if it is more extreme, and a pivot on the opposite side starts the next leg. On clean impulses this changes nothing at all. On ragged ones it pulls the anchor back to the extreme the leg actually reached.

Swing Strength sets how many bars have to print either side of a pivot before it counts. Higher means fewer and more significant swings, and a longer wait.

[b]WHICH WAY THE LEG RUNS[/b]

Fib Direction is Auto, Long or Short, and it is the one control that stays live no matter what else you switch off - because it governs both grids, not just the near one.

Auto works out the direction from the range you actually chose. It looks at the two extremes that range uses and puts 0.00 at whichever one printed later, on the reasoning that the more recent extreme is the one the move ended on. So on Current Day, a day that made its low at 10:15 and its high at 15:50 gets 0.00 at the high and a grid you read downwards. Force it with Long or Short when you disagree.

[b]THE MINUS SIGN, AND WHY THE EXTENSIONS HAVE ONE[/b]

[image]https://www.tradingview.com/x/HjG7Fs4H/[/image]

Everything on this chart is numbered from the leg end. 0.00 sits at the recent extreme that finished the move, 1.00 at the point it started from. That way the number you read is retracement depth, and it means the same thing whichever direction the leg ran.

The extensions continue that same line past 0.00, which is why they are negative. -0.618 sits 0.618 of the leg's range beyond the 0.00 line, in the direction the leg was travelling - exactly the way 0.618 sits 0.618 of the range on the other side of it. One ruler, and the sign tells you which side of the origin you are on.

If that looks unfamiliar, put TradingView's own Fib Retracement tool on the same two points. Its tags read the same: -0.618, not 1.618. The 1.618 reading belongs to the Trend-Based Fib Extension tool, which measures from the leg origin instead - a perfectly good convention, but putting both on one chart gives you two rulers running opposite directions from the same 1.00 line, and sooner or later you read the wrong one.

Six ratios are on offer - -0.272, -0.414, -0.618, -1.00, -1.618, -3.236 - and they ship switched off. [b]They are levels, not targets.[/b] They are arithmetic on the leg. This script says nothing about whether price gets to one, marks no entry or exit, and has no alerts of any kind.

[b]THE SECOND GRID[/b]

[image]https://www.tradingview.com/x/RCKa55MX/[/image]

Switch on Show HTF Context and a second grid draws behind the first, anchored to the latest confirmed swing on a higher timeframe and dimmed so it stays context rather than competing for your attention. It ships off, so a fresh add gives you one clean grid.

HTF Mode is where this differs from most higher-timeframe overlays. [b]Adaptive[/b], the default, does not hold a fixed interval - it takes the next one up from whatever chart you are on. A 5-minute chart anchors to the 15-minute swing, a 1-hour chart to the 4-hour. Change timeframe and it follows you, and because it always resolves to something strictly higher, it cannot silently resolve to nothing.

[b]Custom[/b] lets you name the timeframe instead, which is what you want when a specific one matters - the 4-hour swing while you scalp the 5, say. The catch is that it has to be strictly higher than the chart. Set Custom to 240 and drop to a 4-hour chart and the grid disappears with no warning label, because 240 is not higher than 240.

Both grids keep their own level checkboxes, line width, label size and text colour, so you can make the context layer as quiet as you like. The extension ratios are the exception: which ratios get drawn is shared by both grids, while which grids draw them is not. Each layer has its own extension toggle. The tooltips say which is which, because a control that looks global and is not is worse than one that plainly is.

[b]THE SETTINGS ACTUALLY WORTH YOUR TIME[/b]

Most of the 63 inputs are the ordinary colour-and-width kind. These are the ones that change how the thing reads.

[b]Color Mode[/b] defaults to Gradient, and it is doing real work. Each level takes its colour from its own ratio, so hue states depth - the shallow end and the deep end are different colours, and the 0.618-0.786 span reads as a region instead of two more identical lines. There are five presets plus Custom. Single Color reverts to one colour per grid if you prefer the classic look, and either way whatever transparency you pick in the colour picker is the transparency you get.

[b]Enable Glow[/b] draws every level twice - a wide, near-transparent halo under a thin bright core. It costs nothing but line objects and it is the difference between a grid you can see on a busy chart and a set of hairlines you lose against the candles. Turn it off when the chart is crowded.

[b]Fill Between Levels[/b] shades the intervals. OTE Band, the default, shades only 0.618-0.786. All Bands shades everything, Custom Bands lets you pick, and Off is off. The fills are independent of the line checkboxes, so you can shade a band whose boundary lines are hidden.

[b]Highlight Golden Zone at Price[/b] is the one piece of reactive styling here. While the last close is between the 0.618 and 0.786 prices, that band draws more opaque and lifts off the chart. It creates nothing new - no box, no zone object, no centre line, no label - it just restyles the band the fill control already drew, and Highlight Strength sets by how much. It is arithmetic on two numbers already on your screen.

[b]HTF Layer Dimming[/b] adds transparency to the whole context grid on top of whatever its colours already carry, which is how the second grid stays behind the first instead of doubling the clutter.

[b]Extension Fade[/b] fades each extension a little further as it travels away from the leg, so the near ones read as more prominent than the far ones. It counts only the extensions you actually enabled, not their slot in the ladder - so if you turn on just the far ones, the nearest of them is still drawn at full strength rather than arriving pre-dimmed.

[b]Ratio Label Format[/b] switches the tags between decimal and percent - 0.618 or 61.8%, minus signs intact either way. [b]Show Price Labels[/b] adds the actual price beside each ratio; it is off by default because eight prices is a lot of text.

[b]Line Extension Left/Right[/b] and [b]Label Right Offset[/b] control how far the grid reaches and how far past it the tags sit. The defaults keep the tags in the empty margin, clear of both the candles and the price scale.

One last thing: [b]any control that cannot do anything greys itself out.[/b] Switch the context grid off and its settings dim. Switch to Gradient and the single-colour pickers dim. There is no control in this script that looks live, takes a value, and quietly does nothing.

[b]GETTING STARTED[/b]

[*]Add it. You get one grid on today's range, gradient-coloured, golden zone shaded.
[*]Want a different range? Anchor Range. Leave Fib Direction on Auto until it tells you something you disagree with.
[*]Want context from above? Show HTF Context, and leave HTF Mode on Adaptive unless a specific timeframe matters to you.
[*]Want the extensions? Turn them on for whichever grid you want them on, then pick your ratios.
[*]Too busy? Glow off, Fill Between Levels off. You are back to plain lines.

[b]THINGS THAT WILL LOOK LIKE BUGS AND ARE NOT[/b]

[*][b]Swing anchors arrive late.[/b] A pivot is not a pivot until Swing Strength bars have printed after it, so on Latest Swing and on the context grid you are always looking at the last confirmed pivot, not the bar in front of you. When a newer one confirms, the anchor moves. That is the price of anchoring to something you can only recognise in hindsight, and it is the same trade every swing-based tool makes.
[*][b]The day and week ranges are live.[/b] Current Day and Current Week use the period's running high and low, so the grid re-scales when the session makes a new extreme. It is showing you the range as it stands, not a finished one.
[*][b]It draws one grid, not a history of them.[/b] You get the current grid, redrawn as things move. There is no trail of old ones behind you.
[*][b]Higher-timeframe data uses the documented confirmed-value form[/b] - the expression is offset by one bar and the request passes barmerge.lookahead_on. Together, that is the pattern the Pine Script documentation gives for reading a higher timeframe without pulling unclosed data into historical bars. The source is open, so you can read the call rather than take my word for it.
[*][b]Custom HTF at or below the chart timeframe draws nothing at all[/b], and says nothing about it. Worth remembering before you conclude the context layer is broken.
[*][b]A 12-month chart draws no context grid.[/b] 12M is the top of TradingView's interval list, so Adaptive has nothing left to step up to. 3-month and 6-month charts both work.
[*][b]Prices come from standard OHLC[/b] via ticker.standard(), so your levels are the same on Heikin Ashi, Renko, Kagi, Line Break and Point and Figure as they are on candles. The synthetic geometry of those chart types can still put the lines somewhere you would not expect.

[b]WHAT IT DELIBERATELY DOES NOT DO[/b]

No alerts. No signals. No scores, ratings or probabilities. No zones, no nested zones, no centre line. It draws Fibonacci levels, labels them honestly, and stops. If you want something that tells you when to act, this is not it.

[b]WHY IT IS DIFFERENT[/b]

Four self-maintaining ranges instead of a two-point drag you place today and replace tomorrow. Two independently configured grids on one continuous number line, with the higher one dimmed to sit behind rather than on top. Extensions numbered on the same ruler as the retracements, matching the tags TradingView's own tool gives those prices, rather than a second scale running the other way. A swing range that is genuinely one leg, because the pivot pair is kept alternating. And colour that carries information - a level's hue states its depth - instead of a palette applied to identical lines.

Open source under the Mozilla Public License 2.0.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry LLC

//@version=6
indicator(title="Fibonacci Retracement [AFD]", shorttitle="FIB [AFD]", overlay=true, max_lines_count=70, max_labels_count=40, max_boxes_count=30, max_bars_back=4000)

// The level math and direction logic were extracted from Liquidity Suite [AFD], another
// Auction Foundry LLC product carrying this same MPL 2.0 license, when Fibonacci
// retracement was split out and released standalone. No third-party code is included.
//
// Naming: this file uses snake_case identifiers and f_ function prefixes, where the
// official Pine style guide calls for camelCase and no prefix. That is a deliberate
// file-wide departure, not an oversight, and new code matches it — mixing two
// conventions mid-file would cost more to read than either one alone.

// ══════════════════════════════════════════════════════════════════════════════
// Phase 1 — Constants
// ══════════════════════════════════════════════════════════════════════════════
// Sized to match max_bars_back on the indicator declaration: the anchor leg can
// originate this many bars back, so the historical buffer must reach it.
const int MAX_DRAW_LOOKBACK = 4000

// Transparency is a 0–100 scale on which 0 is fully opaque and 100 is invisible.
// f_shift() clamps to these so no styling layer can drive an element out of sight —
// the official colors page: "cap minimum and maximum transparency levels so your
// visual elements remain visible".
const int TRANSP_MIN = 0
const int TRANSP_MAX = 100

// The golden zone is the 0.618–0.786 span, which is fill bands 4 and 5. Named here so
// the reactive-emphasis test and the "OTE Band" fill mode read from one definition.
const int GOLD_BAND_LO = 4
const int GOLD_BAND_HI = 5

const string GRP_FIB    = "🌀 Fibonacci"
const string GRP_ENGINE = "⚙️ Engine"
const string GRP_HTF    = "🧭 Higher-Timeframe Context"
const string GRP_COLOR  = "🎨 Colors & Gradients"
const string GRP_FILL   = "🌈 Fills & Zones"
const string GRP_GLOW   = "✨ Glow & Emphasis"
const string GRP_GEO    = "📐 Geometry"
const string GRP_EXT    = "📏 Extensions"
const string GRP_LABEL  = "🏷️ Labels"

// ══════════════════════════════════════════════════════════════════════════════
// Phase 2 — Inputs
// ══════════════════════════════════════════════════════════════════════════════
// Show Primary Fibonacci and Show HTF Context sit at the head of their groups because
// declaration order is what makes an active = gate legal: Pine resolves names in the
// order they are declared, so every gate below must reference a control declared above
// it. Reordering these inputs breaks the gating, not just the layout.

show_primary_fib = input.bool(true, "Show Primary Fibonacci", group=GRP_FIB, tooltip="The chart-timeframe Fibonacci layer. On by default, so the initial view shows the grid anchored to the chart's own data using the Anchor Range selector and the level checkboxes below. While it is off, every control that only affects this layer is dimmed.", display=display.none)
fib_anchor  = input.string("Current Day", "Anchor Range", group=GRP_FIB, options=["Latest Swing","Current Day","Previous Day","Current Week"], tooltip="Which high/low pair defines the 0–1 range.\n\nLatest Swing: the last confirmed swing high and low, taken as a consecutive alternating pair so the two bound a single leg. Current Day, Previous Day, Current Week: that period's high ↔ low.\n\nEvery option is derived from the chart's own data, so the grid re-anchors on its own as the period advances and there is nothing to place or maintain by hand.", display=display.none, active=show_primary_fib)
// Fib Direction is deliberately NOT gated on show_primary_fib. It governs the leg on
// BOTH layers, so dimming it with the primary layer off would misrepresent a control
// that is still live on the HTF grid.
fib_dir     = input.string("Auto", "Fib Direction", group=GRP_FIB, options=["Auto","Long","Short"], tooltip="Direction of the impulse leg the retracement is measured against. Applies to both the primary and HTF grids, so it stays available when the primary layer is off.\n\nAuto: infers the leg from the recency of the two extremes the selected anchor actually uses — the swing pivots for Latest Swing, the period's own high and low for Current Day, Previous Day and Current Week, and whichever HTF extreme printed later on the HTF grid. Long: leg low→high. Short: leg high→low.", display=display.none)
fib_l236    = input.bool(true, "0.236", group=GRP_FIB, inline="fibrow1", display=display.none, active=show_primary_fib)
fib_l382    = input.bool(true, "0.382", group=GRP_FIB, inline="fibrow1", display=display.none, active=show_primary_fib)
fib_l5      = input.bool(true, "0.50",  group=GRP_FIB, inline="fibrow2", display=display.none, active=show_primary_fib)
fib_l618    = input.bool(true, "0.618", group=GRP_FIB, inline="fibrow2", display=display.none, active=show_primary_fib)
fib_l705    = input.bool(true, "0.705", group=GRP_FIB, inline="fibrow3", display=display.none, active=show_primary_fib)
fib_l786    = input.bool(true, "0.786", group=GRP_FIB, inline="fibrow3", display=display.none, active=show_primary_fib)
// Extension levels lie BEYOND the 0.00 end of the leg, so their ratio is negative under
// this file's convention of 0 at the leg end and 1 at the leg origin — and that negative
// value is exactly what TradingView's own Fib Retracement tool calls the same price, so
// it is what gets printed. Which ratios are drawn is chosen once in the 📏 Extensions
// group, shared by both layers.
show_ext    = input.bool(false, "Show Extension Levels", group=GRP_FIB, tooltip="Draws the Fibonacci levels that lie beyond the 0.00 end of the leg on the primary grid, using the ratios selected in the 📏 Extensions group.\n\nThey are tagged with negative ratios, on one continuous scale with the retracement levels and matching what TradingView's own Fib Retracement tool calls the same prices: -0.618 sits 0.618 of the leg's range past the 0.00 line, in the direction the leg travelled, the same way 0.618 sits 0.618 of the range on the other side of it.\n\nThese are levels, not targets. The indicator makes no statement about whether price reaches one.", display=display.none, active=show_primary_fib)

swing_strength = input.int(5, "Swing Strength (bars)", group=GRP_ENGINE, minval=1, maxval=50, tooltip="Pivot lookback/lookforward used to confirm the swing high and low that anchor the 'Latest Swing' range and the higher-timeframe range. Higher = fewer, more significant swings. A pivot confirms this many bars after it prints.\n\nThe high and the low are always taken as a consecutive alternating pair, so the range they define is one leg: where two highs confirm with no intervening low, the higher of them is kept, and likewise for lows.", display=display.none)

show_htf = input.bool(false, "Show HTF Context", group=GRP_HTF, tooltip="Optional higher-timeframe Fibonacci grid, anchored to the latest confirmed swing on the effective higher timeframe. Off by default, so the initial view shows the chart-timeframe grid alone. Turn it on to overlay the higher-timeframe context behind it; with the default HTF Mode it draws on every chart interval below 12 months.", display=display.none)
// Adaptive is the default rather than Custom. Custom HTF is 240, which is not STRICTLY
// higher than a 4-hour chart, so a Custom default suppresses this grid on any 4H, daily
// or weekly chart — silently, since suppression draws nothing and says nothing. Adaptive
// walks the ladder below, which always returns a timeframe strictly higher than the
// chart except at its terminal rung, so that silent blank is unreachable at any interval
// under 12 months.
htf_mode = input.string("Adaptive", "HTF Mode", options=["Adaptive", "Custom"], group=GRP_HTF, tooltip="Which higher timeframe the grid is calculated on.\n\nAdaptive (default) selects the next interval up from the chart, so it always resolves to something strictly higher and the grid never blanks. Custom uses the Custom HTF below, which must be strictly higher than the chart timeframe — at or below it, the grid is suppressed.", display=display.none, active=show_htf)
custom_htf = input.timeframe("240", "Custom HTF", group=GRP_HTF, tooltip="The custom timeframe must be strictly higher than the chart timeframe. At or below it, the HTF grid is suppressed.", display=display.none, active=show_htf and htf_mode == "Custom")
// Per-level toggles for the HTF grid. These are separate from the six checkboxes in
// 🌀 Fibonacci, which gate the primary layer only — each layer owns its own level
// visibility. 0.00 and 1.00 are always drawn on both layers and have no checkbox.
htf_l236 = input.bool(true, "0.236", group=GRP_HTF, inline="htfrow1", display=display.none, active=show_htf)
htf_l382 = input.bool(true, "0.382", group=GRP_HTF, inline="htfrow1", display=display.none, active=show_htf)
htf_l5   = input.bool(true, "0.50",  group=GRP_HTF, inline="htfrow2", display=display.none, active=show_htf)
htf_l618 = input.bool(true, "0.618", group=GRP_HTF, inline="htfrow2", display=display.none, active=show_htf)
htf_l705 = input.bool(true, "0.705", group=GRP_HTF, inline="htfrow3", display=display.none, active=show_htf)
htf_l786 = input.bool(true, "0.786", group=GRP_HTF, inline="htfrow3", display=display.none, active=show_htf)
htf_show_ext = input.bool(false, "Show HTF Extension Levels", group=GRP_HTF, tooltip="Draws the extension levels on the higher-timeframe grid, using the same ratios selected in the 📏 Extensions group. Independent of the primary layer's own extension toggle.\n\nTagged with negative ratios, beyond the 0.00 end of the HTF leg.", display=display.none, active=show_htf)

color_mode = input.string("Gradient", "Color Mode", options=["Gradient", "Single Color"], group=GRP_COLOR, tooltip="Gradient (default) colors every level by its own ratio, so the shallow end of the retracement, the golden zone, and the leg origin are distinguishable at a glance. Single Color reproduces the older behaviour: one color for the whole primary grid and one for the whole HTF grid.", display=display.none)
color_theme = input.string("Auction Gold", "Gradient Theme", options=["Auction Gold", "Neon", "Ember", "Ice", "Mono", "Custom"], group=GRP_COLOR, tooltip="Preset endpoint pairs for the gradient. The ramp runs from the 0.00 end of the leg to the 1.00 end, so a level's color states its retracement depth. Choose Custom to set both endpoints yourself.", display=display.none, active=color_mode == "Gradient")
grad_low_color = input.color(#00b0ff, "Gradient Low (0.00 End)", group=GRP_COLOR, tooltip="Color at ratio 0.00, the recent extreme that ends the impulse leg. The transparency you set here is carried through to the drawn line, not replaced.", display=display.none, active=color_mode == "Gradient" and color_theme == "Custom")
grad_high_color = input.color(#ffb300, "Gradient High (1.00 End)", group=GRP_COLOR, tooltip="Color at ratio 1.00, the origin of the impulse leg. The transparency you set here is carried through to the drawn line, not replaced.", display=display.none, active=color_mode == "Gradient" and color_theme == "Custom")
fib_color   = input.color(color.new(color.gray, 20), "Fib Line Color", group=GRP_COLOR, tooltip="Single-color mode only: the color of every primary Fibonacci level. Its transparency is used exactly as you set it.", display=display.none, active=color_mode == "Single Color" and show_primary_fib)
htf_line_color = input.color(color.new(color.yellow, 0), "HTF Fib Line Color", group=GRP_COLOR, tooltip="Single-color mode only: the color of every HTF Fibonacci level. Its transparency is used exactly as you set it — before 2026-07-31 this picker's transparency was silently overwritten and the slider appeared to do nothing.", display=display.none, active=color_mode == "Single Color" and show_htf)
htf_dim = input.int(20, "HTF Layer Dimming", group=GRP_COLOR, minval=0, maxval=90, step=5, tooltip="Extra transparency added to the HTF grid on top of whatever its color already carries, so the context layer sits behind the primary one instead of competing with it. 0 = no extra dimming.", display=display.none, active=show_htf)

fib_fill_mode = input.string("OTE Band", "Fill Between Levels", options=["Off", "All Bands", "OTE Band", "Custom Bands"], group=GRP_FILL, tooltip="Shading between adjacent Fibonacci levels on every visible Fibonacci layer. All Bands shades every interval. OTE Band shades 0.618–0.786. Custom Bands uses the individual band checkboxes below. Fills are independent of the line visibility checkboxes.", display=display.none)
fill_shift = input.int(72, "Fill Transparency", group=GRP_FILL, minval=0, maxval=100, step=2, tooltip="Transparency of the shaded bands in Gradient mode. Higher is fainter. In Single Color mode the transparency comes from the Fib Fill Color picker instead.", display=display.none, active=fib_fill_mode != "Off" and color_mode == "Gradient")
fib_fill_color = input.color(color.new(color.gray, 90), "Fib Fill Color", group=GRP_FILL, tooltip="Single-color mode only: the color used for every shaded band. Its transparency is used exactly as you set it.", display=display.none, active=fib_fill_mode != "Off" and color_mode == "Single Color")
fib_fill_0_236 = input.bool(true, "0.00–0.236", group=GRP_FILL, inline="fillrow1", display=display.none, active=fib_fill_mode == "Custom Bands")
fib_fill_236_382 = input.bool(true, "0.236–0.382", group=GRP_FILL, inline="fillrow1", display=display.none, active=fib_fill_mode == "Custom Bands")
fib_fill_382_50 = input.bool(true, "0.382–0.50", group=GRP_FILL, inline="fillrow2", display=display.none, active=fib_fill_mode == "Custom Bands")
fib_fill_50_618 = input.bool(true, "0.50–0.618", group=GRP_FILL, inline="fillrow2", display=display.none, active=fib_fill_mode == "Custom Bands")
fib_fill_618_705 = input.bool(true, "0.618–0.705", group=GRP_FILL, inline="fillrow3", display=display.none, active=fib_fill_mode == "Custom Bands")
fib_fill_705_786 = input.bool(true, "0.705–0.786", group=GRP_FILL, inline="fillrow3", display=display.none, active=fib_fill_mode == "Custom Bands")
fib_fill_786_100 = input.bool(true, "0.786–1.00", group=GRP_FILL, inline="fillrow4", display=display.none, active=fib_fill_mode == "Custom Bands")
// Recolors the existing 0.618–0.786 band while price trades inside it. This is styling
// applied to a band the Fill Between Levels control already draws — no drawing object,
// no nested zone, no centre line and no label is created, so it costs nothing against
// the drawing budget and disappears entirely when the fill mode excludes that band.
ote_reactive = input.bool(true, "Highlight Golden Zone at Price", group=GRP_FILL, tooltip="While price is trading inside the 0.618–0.786 band, that band is drawn more opaque so it stands out. Requires a fill mode that includes the band — OTE Band, All Bands, or Custom Bands with 0.618–0.705 and 0.705–0.786 selected.", display=display.none)
ote_boost = input.int(28, "Highlight Strength", group=GRP_FILL, minval=0, maxval=90, step=2, tooltip="How much transparency is removed from the golden-zone band while price is inside it. Higher is more emphatic.", display=display.none, active=ote_reactive)

glow_enabled = input.bool(true, "Enable Glow", group=GRP_GLOW, tooltip="Draws each Fibonacci level twice — a wide, near-transparent halo beneath a thin bright core — so the grid reads as lit rather than as hairlines. Doubles the number of line objects the script draws; the declared line budget covers the worst case.", display=display.none)
glow_width = input.int(4, "Glow Width", group=GRP_GLOW, minval=1, maxval=8, tooltip="Extra width of the halo beyond the core line, in pixels.", display=display.none, active=glow_enabled)
glow_shift = input.int(58, "Glow Transparency", group=GRP_GLOW, minval=0, maxval=95, step=2, tooltip="Transparency added to the halo on top of the core line's own. Higher is a softer glow.", display=display.none, active=glow_enabled)

line_style_name = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=GRP_GEO, tooltip="Style of the Fibonacci level lines on both layers.", display=display.none)
fib_line_width = input.int(1, "Fib Line Width", group=GRP_GEO, minval=1, maxval=4, display=display.none, active=show_primary_fib)
htf_line_width = input.int(1, "HTF Line Width", group=GRP_GEO, minval=1, maxval=4, display=display.none, active=show_htf)
line_left_bars = input.int(40, "Line Extension Left (bars)", group=GRP_GEO, minval=0, maxval=4000, tooltip="Extends Fib lines left from the earlier anchor point. Default is 40 bars.", display=display.none)
line_right_bars = input.int(30, "Line Extension Right (bars)", group=GRP_GEO, minval=0, maxval=200, tooltip="Extends Fib lines right past the current bar. Default is 30 bars.", display=display.none)
label_offset = input.int(10, "Label Right Offset (bars)", group=GRP_GEO, minval=0, maxval=200, tooltip="Pushes the level tags this many bars into the empty right margin so they sit clear of the latest candles and the price scale. Default is 10 bars; 0 = pinned to the line's right edge.", display=display.none)

// Which extension ratios are drawn. Genuinely shared by BOTH layers — unlike the six
// level checkboxes above, which are per-layer. A control that looks global and is not is
// worse than one that is, so these say which they are in their own tooltips and are
// gated on EITHER layer's extension toggle rather than on one of them. Both toggles they
// reference are declared above, which is what makes the active = gate legal.
ext_m272  = input.bool(false, "-0.272", group=GRP_EXT, inline="extrow1", tooltip="Extension ratios, drawn on whichever layers have their extension toggle on. Negative because they lie beyond the 0.00 end of the leg, on the far side of it from the retracement levels — the same names TradingView's own Fib Retracement tool gives these prices. -0.618 sits 0.618 of the leg's range past the 0.00 line, in the direction the leg travelled.\n\nThese checkboxes are shared by the primary and higher-timeframe grids. The 0.236–0.786 checkboxes in the other two groups are per-layer; these are not.", display=display.none, active=show_ext or htf_show_ext)
ext_m414  = input.bool(false, "-0.414", group=GRP_EXT, inline="extrow1", display=display.none, active=show_ext or htf_show_ext)
ext_m618  = input.bool(true,  "-0.618", group=GRP_EXT, inline="extrow2", display=display.none, active=show_ext or htf_show_ext)
ext_m1000 = input.bool(false, "-1.00",  group=GRP_EXT, inline="extrow2", display=display.none, active=show_ext or htf_show_ext)
ext_m1618 = input.bool(true,  "-1.618", group=GRP_EXT, inline="extrow3", display=display.none, active=show_ext or htf_show_ext)
ext_m3236 = input.bool(false, "-3.236", group=GRP_EXT, inline="extrow3", display=display.none, active=show_ext or htf_show_ext)
ext_fade  = input.int(10, "Extension Fade (per level)", group=GRP_EXT, minval=0, maxval=30, tooltip="Transparency added per step as the extensions travel away from the leg, so the nearer ones read as more prominent than the far ones. In Gradient mode every extension starts from the ramp's 0.00-end color; the retracement ramp itself is unaffected. 0 = every extension drawn at the same strength.", display=display.none, active=show_ext or htf_show_ext)

show_level_prices = input.bool(false, "Show Price Labels", group=GRP_LABEL, tooltip="Show or hide the numeric price beside each Fibonacci ratio label. Applies to both the primary and HTF Fibonacci grids. Default is off.", display=display.none)
ratio_label_format = input.string("Decimal", "Ratio Label Format", options=["Decimal", "Percent"], group=GRP_LABEL, tooltip="Controls the ratio text shown beside each Fibonacci line. Decimal displays values such as 0.00, 0.50, 0.236, and 1.00 — always at least two decimal places, and a third only where the ratio needs it. Percent displays the same levels as 0%, 50%, 23.6%, and 100% — trailing zeros are not padded.\n\nExtension levels carry their minus sign in both formats: -0.618 and -61.8%.", display=display.none)
label_bg_shift = input.int(58, "Label Background Transparency", group=GRP_LABEL, minval=0, maxval=100, step=2, tooltip="Transparency added to a level tag's background on top of its line color's own, so the tag reads as a quieter version of the line it belongs to.", display=display.none)
fib_label_size_name = input.string("Small", "Fib Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=GRP_LABEL, display=display.none, active=show_primary_fib)
fib_label_text_color = input.color(color.white, "Fib Label Text Color", group=GRP_LABEL, display=display.none, active=show_primary_fib)
htf_label_size_name = input.string("Small", "HTF Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=GRP_LABEL, display=display.none, active=show_htf)
htf_label_text_color = input.color(color.white, "HTF Label Text Color", group=GRP_LABEL, display=display.none, active=show_htf)

// There is deliberately no hand-placed anchor. All four Anchor Range options are derived
// from the chart's own data and need no maintenance, and none of them uses input.price()
// or input.time() — which matters because input.price() takes a CONSTANT default, so no
// two-point default lands on-chart across instruments, and the Pine Screener substitutes
// an input.time() default rather than reading it.

// ══════════════════════════════════════════════════════════════════════════════
// Phase 3 — Global state
// ══════════════════════════════════════════════════════════════════════════════
var float last_sh     = na
var float last_sl     = na
var int   last_sh_bar = na
var int   last_sl_bar = na
// Which side the most recently ACCEPTED pivot sat on: 1 = high, -1 = low, 0 = none yet.
// This is the whole of what makes last_sh and last_sl one leg rather than two unrelated
// extremes — see the alternation rule in Phase 6.
var int   leg_side    = 0

var array<line>  fib_lines = array.new<line>()
var array<label> fib_lbls  = array.new<label>()
var array<box>   fib_fills = array.new<box>()

// ══════════════════════════════════════════════════════════════════════════════
// Phase 4 — Helpers
// ══════════════════════════════════════════════════════════════════════════════
method px(float p) =>
    str.tostring(p, format.mintick)

// The ratio is printed verbatim, negatives included. Do not convert a negative ratio to
// 1.0 - N on the way out: that prints an extension as "1.618" on the Trend-Based Fib
// Extension scale, which measures from the leg ORIGIN, while every other tag on the
// chart measures from the leg END. Two scales running opposite ways from 1.00 is what
// that produces. One scale, and the sign says which side of the 0.00 line a level is on.
f_ratio_text(float lvl) =>
    ratio_label_format == "Percent" ? str.tostring(lvl * 100.0, "0.##") + "%" : str.tostring(lvl, "0.00#")

// Moves a color's transparency by delta, preserving whatever the color already carries.
// color.new() REPLACES transparency, so wrapping a user's picked color in it silently
// discards the alpha they chose from the picker, and their transparency slider then does
// nothing at all with no error to show for it. Every styling layer below — dimming,
// glow, label backgrounds, the golden-zone highlight — shifts relative to the user's own
// value through this helper instead of overwriting it.
f_shift(color c, int delta) =>
    color.new(c, math.max(TRANSP_MIN, math.min(TRANSP_MAX, int(color.t(c)) + delta)))

// Endpoints of the gradient ramp. Custom falls through to the two color inputs.
// Deliberately two scalar functions rather than one returning a tuple: Pine restricts
// where a tuple may be declared, and these are read from inside local scopes below.
f_theme_lo() =>
    color lo = grad_low_color
    if color_theme == "Auction Gold"
        lo := #00b0ff
    else if color_theme == "Neon"
        lo := #00e5ff
    else if color_theme == "Ember"
        lo := #ffd54f
    else if color_theme == "Ice"
        lo := #80d8ff
    else if color_theme == "Mono"
        lo := #eceff1
    lo

f_theme_hi() =>
    color hi = grad_high_color
    if color_theme == "Auction Gold"
        hi := #ffb300
    else if color_theme == "Neon"
        hi := #ff2ec4
    else if color_theme == "Ember"
        hi := #e53935
    else if color_theme == "Ice"
        hi := #1e5fd9
    else if color_theme == "Mono"
        hi := #607d8b
    hi

f_line_style() =>
    line_style_name == "Dashed" ? line.style_dashed : line_style_name == "Dotted" ? line.style_dotted : line.style_solid

f_label_size(string name) =>
    name == "Tiny" ? size.tiny : name == "Small" ? size.small : name == "Normal" ? size.normal : name == "Large" ? size.large : size.huge

// The single definition of a level's price, and it must stay single. The leg convention
// it encodes — 0 at the leg END (the recent extreme), 1 at the leg origin — is read by
// the lines, the tags, the fill bands and the extensions alike. Inlining it at any of
// those call sites puts the convention in more than one place, and an edit to the
// obvious ones silently mirrors the fill bands away from their own boundary lines.
f_level_price(float rhi, float rlo, float rng, int leg, float lvl) =>
    leg == 1 ? rhi - rng * lvl : rlo + rng * lvl

// A level's color. In Gradient mode the ratio itself drives the ramp, so a level's hue
// states its retracement depth; in Single Color mode the user's picked color is used
// verbatim. dim is added afterwards for the HTF layer. The official colors page notes
// color.from_gradient() is linear between the bounds, clamps outside them, and always
// returns a series color — fine here, because this script has no plot() needing a const.
f_level_color(float lvl, color base, int dim) =>
    color c = base
    if color_mode == "Gradient"
        c := color.from_gradient(lvl, 0.0, 1.0, f_theme_lo(), f_theme_hi())
    f_shift(c, dim)

// An extension level's color. Extensions cannot go through f_level_color(): their ratio
// is negative and the official colors page states color.from_gradient() clamps —
// "whenever the series is outside the bottom_value and top_value limits, the colors used
// for bottom_color and top_color will apply" — so every extension would come back as the
// exact 0.00-end color, indistinguishable from the 0.00 line and from each other.
// Widening the ramp's domain instead would have recolored the whole retracement grid the
// moment extensions were switched on, so the domain stays [0, 1] and the extensions get
// their own rule: start at the 0.00 end and fade by rank, which reads as distance from
// the leg. rank is the 0-based position among the extensions ACTUALLY DRAWN, not the slot
// in the six-ratio ladder. Rank by slot instead and an unchecked ratio still spends a
// fade step, so the nearest enabled level arrives pre-dimmed and its label pill washes
// out to bare text — worst with only the far ratios selected.
f_ext_color(int rank, color base, int dim) =>
    color c = color_mode == "Gradient" ? f_theme_lo() : base
    f_shift(c, dim + ext_fade * rank)

f_fill_selected(int band) =>
    bool custom_on = band == 0 ? fib_fill_0_236 : band == 1 ? fib_fill_236_382 : band == 2 ? fib_fill_382_50 : band == 3 ? fib_fill_50_618 : band == 4 ? fib_fill_618_705 : band == 5 ? fib_fill_705_786 : fib_fill_786_100
    fib_fill_mode == "All Bands" or (fib_fill_mode == "OTE Band" and (band == GOLD_BAND_LO or band == GOLD_BAND_HI)) or (fib_fill_mode == "Custom Bands" and custom_on)

// Color of one shaded band. In Gradient mode the band takes the ramp at its own
// midpoint, so it sits chromatically between the two lines that bound it. gold_live is
// the reactive emphasis: while price trades inside 0.618–0.786 that band loses
// transparency and lifts off the chart.
f_band_color(int band, float lvl_a, float lvl_b, int dim, bool gold_live) =>
    color c = fib_fill_color
    if color_mode == "Gradient"
        c := color.new(color.from_gradient((lvl_a + lvl_b) * 0.5, 0.0, 1.0, f_theme_lo(), f_theme_hi()), fill_shift)
    bool is_gold = band == GOLD_BAND_LO or band == GOLD_BAND_HI
    f_shift(c, dim - (is_gold and gold_live ? ote_boost : 0))

f_fill_band(array<box> arr, bool on, float p1, float p2, int x1, int x2, color col) =>
    if on and not na(p1) and not na(p2) and p1 != p2
        array.push(arr, box.new(left=x1, top=math.max(p1, p2), right=x2, bottom=math.min(p1, p2), xloc=xloc.bar_index, bgcolor=col, border_color=na))

f_fill_band_time(array<box> arr, bool on, float p1, float p2, int x1, int x2, color col) =>
    if on and not na(p1) and not na(p2) and p1 != p2
        array.push(arr, box.new(left=x1, top=math.max(p1, p2), right=x2, bottom=math.min(p1, p2), xloc=xloc.bar_time, bgcolor=col, border_color=na))

// draw one fib level, bar-index path (global scope; px is method-callable here)
// Root cause of the bool return: Pine v6 disallows mutating a global scalar
// (int/float/bool/string) from inside a function — only reference types may be mutated
// that way. Returns whether it drew instead of touching any counter directly.
// The halo is pushed BEFORE the core line so the core draws over it: drawing objects
// are painted in creation order.
f_fib(array<line> arr, array<label> lbls, float lvl, bool on, float rhi, float rlo, float rng, int leg, int x1, int x2, color col, int width, string label_size_name, color label_text_color) =>
    bool drew = false
    if on
        float p = f_level_price(rhi, rlo, rng, leg, lvl)
        string level_text = show_level_prices ? f_ratio_text(lvl) + "  " + px(p) : f_ratio_text(lvl)
        if glow_enabled
            array.push(arr, line.new(x1, p, x2, p, extend=extend.none, color=f_shift(col, glow_shift), style=line.style_solid, width=width + glow_width))
        array.push(arr, line.new(x1, p, x2, p, extend=extend.none, color=col, style=f_line_style(), width=width))
        array.push(lbls, label.new(x2 + label_offset, p, level_text, style=label.style_label_left, color=f_shift(col, label_bg_shift), textcolor=label_text_color, size=f_label_size(label_size_name)))
        drew := true
    drew

// draw one fib level, bar-time path
f_fib_time(array<line> arr, array<label> lbls, float lvl, bool on, float rhi, float rlo, float rng, int leg, int x1, int x2, int label_x, color col, int width, string label_size_name, color label_text_color) =>
    bool drew = false
    if on
        float p = f_level_price(rhi, rlo, rng, leg, lvl)
        string level_text = show_level_prices ? f_ratio_text(lvl) + "  " + px(p) : f_ratio_text(lvl)
        if glow_enabled
            array.push(arr, line.new(x1, p, x2, p, xloc=xloc.bar_time, extend=extend.none, color=f_shift(col, glow_shift), style=line.style_solid, width=width + glow_width))
        array.push(arr, line.new(x1, p, x2, p, xloc=xloc.bar_time, extend=extend.none, color=col, style=f_line_style(), width=width))
        array.push(lbls, label.new(label_x, p, level_text, xloc=xloc.bar_time, style=label.style_label_left, color=f_shift(col, label_bg_shift), textcolor=label_text_color, size=f_label_size(label_size_name)))
        drew := true
    drew

f_adaptive_htf() =>
    float chart_seconds = timeframe.in_seconds()
    string result = "1"
    if na(chart_seconds)
        result := "1"
    else if chart_seconds < 60
        result := "1"
    else if chart_seconds <= 60
        result := "5"
    else if chart_seconds <= 300
        result := "15"
    else if chart_seconds <= 900
        result := "60"
    else if chart_seconds <= 3600
        result := "240"
    else if chart_seconds <= 14400
        result := "1D"
    else if chart_seconds <= 86400
        result := "1W"
    else if chart_seconds <= 604800
        result := "1M"
    else if chart_seconds <= timeframe.in_seconds("1M")
        result := "3M"
    else
        // Terminal rung. TradingView has no interval above 12M to ladder to, so a 12M
        // chart resolves to its own timeframe, htf_is_higher is false, and the HTF grid
        // is suppressed there. It is the one interval where this ladder cannot return
        // something strictly higher; 3M and 6M charts both resolve to 12M and draw.
        result := "12M"
    result

// The latest confirmed swing PAIR on whichever timeframe this is evaluated in, kept
// alternating by the same rule as the chart-timeframe block in Phase 6. Taking the latest
// pivot high and the latest pivot low independently is not equivalent: on a ranging
// higher timeframe it pairs a high with a low separated by several same-side swings, and
// the "leg" that results is not one move.
//
// The trailing [1] on each returned value is load-bearing. It is the historical-offset
// half of the documented higher-timeframe idiom, and the call site supplies the other
// half with barmerge.lookahead_on. Removing either one leaves a form the Pine
// documentation does not sanction; they only work as a pair.
f_htf_state() =>
    float h = ta.pivothigh(high, swing_strength, swing_strength)
    float l = ta.pivotlow(low, swing_strength, swing_strength)
    var float zig_hi      = na
    var float zig_lo      = na
    var int   zig_hi_time = na
    var int   zig_lo_time = na
    var int   zig_side    = 0
    if not na(h) and (zig_side != 1 or na(zig_hi) or h >= zig_hi)
        zig_hi      := h
        zig_hi_time := time[swing_strength]
        zig_side    := 1
    if not na(l) and (zig_side != -1 or na(zig_lo) or l <= zig_lo)
        zig_lo      := l
        zig_lo_time := time[swing_strength]
        zig_side    := -1
    [zig_hi[1], zig_lo[1], zig_hi_time[1], zig_lo_time[1]]

// ══════════════════════════════════════════════════════════════════════════════
// Phase 5 — Per-bar reads (read-only, no state mutation)
// ══════════════════════════════════════════════════════════════════════════════
string standard_ticker = ticker.standard(syminfo.tickerid)
[std_ph, std_pl, std_close] = request.security(standard_ticker, timeframe.period, [ta.pivothigh(high, swing_strength, swing_strength), ta.pivotlow(low, swing_strength, swing_strength), close], lookahead=barmerge.lookahead_off)

// Anchor ranges. These run on every bar whichever anchor is selected: Pine evaluates
// every request.*() call regardless of the scope it sits in, so there is no way to skip
// the unused pulls and no saving to be had by moving them inside the branch that reads
// them.
[cdh, cdl, fdh, fdl] = request.security(standard_ticker, "D", [high, low, high[1], low[1]], lookahead=barmerge.lookahead_off)
[cwh, cwl] = request.security(standard_ticker, "W", [high, low], lookahead=barmerge.lookahead_off)

// Period-start anchors and the bar on which each period extreme was last set. These bars
// exist so Fib Direction's Auto case can resolve each anchor's leg from the two extremes
// THAT anchor uses. Resolving it from the latest swing pivots instead — values unrelated
// to the range being drawn — inverts the grid on the day and week anchors. Tracking the
// bar on which each requested extreme last changed costs no extra request.*() call and is
// consistent by construction with the price it accompanies.
var int start_d      = na
var int prev_start_d = na
var int start_w      = na
var int cdh_bar      = na
var int cdl_bar      = na
var int fdh_bar      = na
var int fdl_bar      = na
var int cwh_bar      = na
var int cwl_bar      = na
bool new_day  = nz(ta.change(time("D")), 0) != 0
bool new_week = nz(ta.change(time("W")), 0) != 0
// Every ta.change() is evaluated HERE, at global scope, and only its bool result is read
// inside a branch below. Do not move one back into a branch. ta.change() keeps a time
// series of its own and commits a value only on the bars it actually runs on, so a call
// placed inside an else branch compares against the last bar that branch was TAKEN rather
// than against the last bar. The compiler flags this as warning CW10003.
//
// Concretely, and this raises nothing at runtime while returning plausible numbers: on
// the second bar of a session, ta.change(cdh) inside the else would compare the new day's
// running high against YESTERDAY's finished high. Those differ on almost every day, so
// the change test fires spuriously and re-stamps cdh_bar — and cdl_bar with it — to bar 2
// of the session whether or not either extreme moved. Both stamps landing on the same bar
// makes Fib Direction's Auto case resolve rHiBar >= rLoBar as LONG on the Current Day
// anchor for every day whose high and low were both set early, drawing the grid upside
// down. The equilibrium fallback never catches it, because the bars are not na — they are
// wrong. The weekly pair has the identical shape one period up, and bars after the second
// are unaffected, so it presents as an intermittent direction fault rather than as a
// broken anchor.
bool cdh_changed = nz(ta.change(cdh), 0) != 0
bool cdl_changed = nz(ta.change(cdl), 0) != 0
bool cwh_changed = nz(ta.change(cwh), 0) != 0
bool cwl_changed = nz(ta.change(cwl), 0) != 0
if new_day
    // Yesterday's extremes and their bars become the Previous Day anchor. Its left edge
    // must be the PREVIOUS day's start: take the current day's start instead and the
    // grid's geometry and its data describe different days.
    prev_start_d := start_d
    fdh_bar      := cdh_bar
    fdl_bar      := cdl_bar
    start_d      := bar_index
    cdh_bar      := bar_index
    cdl_bar      := bar_index
else
    if cdh_changed
        cdh_bar := bar_index
    if cdl_changed
        cdl_bar := bar_index
if new_week
    start_w := bar_index
    cwh_bar := bar_index
    cwl_bar := bar_index
else
    if cwh_changed
        cwh_bar := bar_index
    if cwl_changed
        cwl_bar := bar_index

string adaptive_htf = f_adaptive_htf()
string requested_htf = htf_mode == "Adaptive" ? adaptive_htf : custom_htf
float chart_seconds = timeframe.in_seconds()
float requested_seconds = timeframe.in_seconds(requested_htf)
bool htf_is_higher = na(chart_seconds) ? requested_seconds > 0 : requested_seconds > chart_seconds
bool htf_request_valid = show_htf and htf_is_higher
string safe_htf = htf_is_higher ? requested_htf : timeframe.period
[htf_high, htf_low, htf_high_time, htf_low_time] = request.security(standard_ticker, safe_htf, f_htf_state(), lookahead=barmerge.lookahead_on)

// ══════════════════════════════════════════════════════════════════════════════
// Phase 6 — Confirmed-bar state mutation
// ══════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed
    // A pivot confirms swing_strength bars after it printed — stamp the true pivot bar.
    //
    // The pair is kept ALTERNATING. ta.pivothigh() and ta.pivotlow() are independent
    // detectors, so a chart can print several highs in a row with no qualifying low
    // between them. Taking the latest of each gives a "leg" whose high end is the most
    // RECENT high rather than the HIGHEST one in the span, so the grid describes an
    // impulse that never happened as a single move. The rule below is the standard zigzag
    // one: a pivot on the same side as the last accepted pivot replaces it only when it is
    // more extreme; a pivot on the opposite side always begins the next leg. Where pivots
    // already alternate — the ordinary case, and every clean impulse — this is a no-op.
    // Only the ragged cases move, and they move toward the extreme the leg reached.
    if not na(std_ph) and (leg_side != 1 or na(last_sh) or std_ph >= last_sh)
        last_sh     := std_ph
        last_sh_bar := bar_index - swing_strength
        leg_side    := 1
    if not na(std_pl) and (leg_side != -1 or na(last_sl) or std_pl <= last_sl)
        last_sl     := std_pl
        last_sl_bar := bar_index - swing_strength
        leg_side    := -1

// ══════════════════════════════════════════════════════════════════════════════
// Phase 7 — Drawing pass (delete-then-redraw)
// ══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    for ln in fib_lines
        line.delete(ln)
    array.clear(fib_lines)
    for lb in fib_lbls
        label.delete(lb)
    array.clear(fib_lbls)
    for bx in fib_fills
        box.delete(bx)
    array.clear(fib_fills)

    // Bars-to-milliseconds step for the HTF layer's xloc.bar_time drawing, which is the
    // only bar_time path in the script. Taken from timeframe.in_seconds(), NOT from
    // time - time[1]: this pass runs on the last bar, which is the FIRST bar of the
    // session whenever the market has just opened, and there time - time[1] is the
    // overnight gap rather than the bar step. On a 5-minute US equity chart that gap is
    // about 17h35m — some 211x the true step — so every line extension and label offset
    // below would be multiplied by 211 at each session open. Mid-session the two
    // expressions agree, which is why the fault is invisible in ordinary testing. The old
    // expression survives only as the fallback for charts where in_seconds() returns na.
    int bar_step_ms = math.max(na(chart_seconds) ? nz(time - time[1], 1) : int(chart_seconds * 1000), 1)

    float rHi = na
    float rLo = na
    int   rX1 = bar_index
    // Bars of the two extremes the SELECTED anchor actually uses. Fib Direction's Auto
    // case reads these, so every anchor resolves its leg from its own range.
    int   rHiBar = na
    int   rLoBar = na
    // Every option on Anchor Range is named here and there is NO trailing bare else, so
    // an unrecognised value draws nothing rather than silently adopting another anchor's
    // range. That is not hypothetical tidiness: a bare else at the end of a selector chain
    // adopts every state its named branches miss, which draws a full, plausible grid under
    // a label naming an anchor it did not come from. Any option added to the list later
    // gets its own branch or gets nothing.
    if fib_anchor == "Latest Swing"
        rHi := last_sh
        rLo := last_sl
        rX1 := math.min(nz(last_sh_bar, bar_index), nz(last_sl_bar, bar_index))
        rHiBar := last_sh_bar
        rLoBar := last_sl_bar
    else if fib_anchor == "Current Day"
        rHi := cdh
        rLo := cdl
        rX1 := nz(start_d, bar_index)
        rHiBar := cdh_bar
        rLoBar := cdl_bar
    else if fib_anchor == "Previous Day"
        rHi := fdh
        rLo := fdl
        rX1 := nz(prev_start_d, nz(start_d, bar_index))
        rHiBar := fdh_bar
        rLoBar := fdl_bar
    else if fib_anchor == "Current Week"
        rHi := cwh
        rLo := cwl
        rX1 := nz(start_w, bar_index)
        rHiBar := cwh_bar
        rLoBar := cwl_bar
    rX1 := math.max(rX1, bar_index - MAX_DRAW_LOOKBACK)
    int draw_left = math.max(bar_index - MAX_DRAW_LOOKBACK, rX1 - line_left_bars)
    int draw_right = bar_index + line_right_bars
    if not na(rHi) and not na(rLo) and rHi > rLo
        float rng = rHi - rLo
        // impulse-leg direction: 1 = long leg (low→high, retrace down), -1 = short leg.
        // Auto resolves by the recency of the two extremes THIS anchor uses. Price versus
        // the range midpoint is the fallback, and it is reached only when both extreme
        // bars are unknown.
        int fleg = fib_dir == "Long" ? 1 : fib_dir == "Short" ? -1 : not na(rHiBar) and not na(rLoBar) ? (rHiBar >= rLoBar ? 1 : -1) : std_close >= (rHi + rLo) * 0.5 ? 1 : -1
        // Reactive golden-zone test, evaluated once for both layers' primary use below.
        float gold_a = f_level_price(rHi, rLo, rng, fleg, 0.618)
        float gold_b = f_level_price(rHi, rLo, rng, fleg, 0.786)
        bool gold_live = ote_reactive and close >= math.min(gold_a, gold_b) and close <= math.max(gold_a, gold_b)
        if show_primary_fib
            array<float> _fib_lvl = array.from(0.0,  0.236,    0.382,    0.5,    0.618,    0.705,    0.786,    1.0)
            array<bool>  _fib_on  = array.from(true, fib_l236, fib_l382, fib_l5, fib_l618, fib_l705, fib_l786, true)
            if array.size(_fib_lvl) > 0
                for _fi = 0 to array.size(_fib_lvl) - 1
                    float _lvl = array.get(_fib_lvl, _fi)
                    color _col = f_level_color(_lvl, fib_color, 0)
                    f_fib(fib_lines, fib_lbls, _lvl, array.get(_fib_on, _fi), rHi, rLo, rng, fleg, draw_left, draw_right, _col, fib_line_width, fib_label_size_name, fib_label_text_color)
                if fib_fill_mode != "Off"
                    for _fi = 0 to array.size(_fib_lvl) - 2
                        float _lvl_a = array.get(_fib_lvl, _fi)
                        float _lvl_b = array.get(_fib_lvl, _fi + 1)
                        float _pa = f_level_price(rHi, rLo, rng, fleg, _lvl_a)
                        float _pb = f_level_price(rHi, rLo, rng, fleg, _lvl_b)
                        color _bcol = f_band_color(_fi, _lvl_a, _lvl_b, 0, gold_live)
                        f_fill_band(fib_fills, f_fill_selected(_fi), _pa, _pb, draw_left, draw_right, _bcol)
            // Extensions, drawn by the same helpers on the same x-extent. The ladder is the
            // literal ratio in every case, so f_level_price() needs no special path: at
            // lvl = -0.618 and a long leg it returns rhi + 0.618 * rng, and at a short leg
            // rlo - 0.618 * rng. Both are 0.618 of the range past the 0.00 line, on the
            // side the leg was travelling.
            // No fill band is drawn between extensions. A shaded span between two of them
            // would be a zone, and this indicator draws levels, not zones.
            // _erank counts the extensions actually DRAWN, not the ladder slot, so the
            // nearest enabled one is always at full strength.
            if show_ext
                array<float> _ext_lvl = array.from(-0.272,   -0.414,   -0.618,   -1.0,      -1.618,    -3.236)
                array<bool>  _ext_on  = array.from(ext_m272, ext_m414, ext_m618, ext_m1000, ext_m1618, ext_m3236)
                int _erank = 0
                if array.size(_ext_lvl) > 0
                    for _ei = 0 to array.size(_ext_lvl) - 1
                        float _elvl = array.get(_ext_lvl, _ei)
                        bool _eon = array.get(_ext_on, _ei)
                        color _ecol = f_ext_color(_erank, fib_color, 0)
                        f_fib(fib_lines, fib_lbls, _elvl, _eon, rHi, rLo, rng, fleg, draw_left, draw_right, _ecol, fib_line_width, fib_label_size_name, fib_label_text_color)
                        if _eon
                            _erank += 1

    // The HTF grid is always the latest confirmed swing on the effective higher
    // timeframe; it has no anchor selector of its own. This is the only layer that draws
    // on xloc.bar_time, and the only caller of f_fib_time() and f_fill_band_time() — it
    // has to, because its pivots are located by HTF timestamp rather than by a bar index
    // that exists on this chart.
    bool htf_has_range = htf_request_valid and not na(htf_high) and not na(htf_low) and htf_high > htf_low and not na(htf_high_time) and not na(htf_low_time)
    if htf_has_range
        float htf_range = htf_high - htf_low
        // Honours Fib Direction, same as the primary layer. Auto keeps the previous
        // rule: whichever extreme printed later ends the leg.
        int htf_leg = fib_dir == "Long" ? 1 : fib_dir == "Short" ? -1 : htf_high_time >= htf_low_time ? 1 : -1
        int htf_draw_left_time = math.min(htf_high_time, htf_low_time) - bar_step_ms * line_left_bars
        // Measured from the CURRENT BAR, matching the primary layer's draw_right. Measure
        // it from the swing instead and on a Custom HTF whose pivots are days old the
        // grid's right edge lands behind the current bar and off the left of the viewport,
        // which reads on the chart as the HTF layer having stopped working.
        int htf_draw_right_time = time + bar_step_ms * line_right_bars
        int htf_label_time = htf_draw_right_time + bar_step_ms * label_offset
        float htf_gold_a = f_level_price(htf_high, htf_low, htf_range, htf_leg, 0.618)
        float htf_gold_b = f_level_price(htf_high, htf_low, htf_range, htf_leg, 0.786)
        bool htf_gold_live = ote_reactive and close >= math.min(htf_gold_a, htf_gold_b) and close <= math.max(htf_gold_a, htf_gold_b)
        array<float> _htf_lvl = array.from(0.0,  0.236,    0.382,    0.5,    0.618,    0.705,    0.786,    1.0)
        array<bool>  _htf_on  = array.from(true, htf_l236, htf_l382, htf_l5, htf_l618, htf_l705, htf_l786, true)
        for _hi = 0 to array.size(_htf_lvl) - 1
            float _hlvl = array.get(_htf_lvl, _hi)
            f_fib_time(fib_lines, fib_lbls, _hlvl, array.get(_htf_on, _hi), htf_high, htf_low, htf_range, htf_leg, htf_draw_left_time, htf_draw_right_time, htf_label_time, f_level_color(_hlvl, htf_line_color, htf_dim), htf_line_width, htf_label_size_name, htf_label_text_color)
        if fib_fill_mode != "Off"
            for _hi = 0 to array.size(_htf_lvl) - 2
                float _lvl_a = array.get(_htf_lvl, _hi)
                float _lvl_b = array.get(_htf_lvl, _hi + 1)
                float _pa = f_level_price(htf_high, htf_low, htf_range, htf_leg, _lvl_a)
                float _pb = f_level_price(htf_high, htf_low, htf_range, htf_leg, _lvl_b)
                f_fill_band_time(fib_fills, f_fill_selected(_hi), _pa, _pb, htf_draw_left_time, htf_draw_right_time, f_band_color(_hi, _lvl_a, _lvl_b, htf_dim, htf_gold_live))
        // HTF extensions. Same ratio ladder as the primary layer, carrying htf_dim so
        // they stay behind the primary grid like every other HTF element. Gated on this
        // layer's own toggle: which RATIOS are drawn is shared, which LAYERS draw them
        // is not.
        // _herank counts drawn extensions, not ladder slots — same rule as the primary
        // layer above, and it matters more here because htf_dim is already added on top.
        if htf_show_ext
            array<float> _hext_lvl = array.from(-0.272,   -0.414,   -0.618,   -1.0,      -1.618,    -3.236)
            array<bool>  _hext_on  = array.from(ext_m272, ext_m414, ext_m618, ext_m1000, ext_m1618, ext_m3236)
            int _herank = 0
            if array.size(_hext_lvl) > 0
                for _hei = 0 to array.size(_hext_lvl) - 1
                    float _helvl = array.get(_hext_lvl, _hei)
                    bool _heon = array.get(_hext_on, _hei)
                    f_fib_time(fib_lines, fib_lbls, _helvl, _heon, htf_high, htf_low, htf_range, htf_leg, htf_draw_left_time, htf_draw_right_time, htf_label_time, f_ext_color(_herank, htf_line_color, htf_dim), htf_line_width, htf_label_size_name, htf_label_text_color)
                    if _heon
                        _herank += 1
````
