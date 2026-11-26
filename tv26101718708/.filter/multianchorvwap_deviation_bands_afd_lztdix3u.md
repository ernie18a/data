# Multi-Anchor_VWAP & Deviation Bands [AFD]

- url: https://www.tradingview.com/script/LZtdiX3u-Multi-Anchor-VWAP-Deviation-Bands-AFD/
- type: indicator
- pine_id: PUB;773db4edc7f24b10bb4f6205e59e27f2
- version: 1.0

## Description

[image]https://www.tradingview.com/x/DubTpblF/[/image]

Three anchored VWAPs on one chart, with the price zones where they agree shaded in for you.

[b]WHAT IT IS[/b]
An anchored VWAP shows the average price everyone has paid since a moment you pick - the gap open, the earnings bar, the swing low that started the move. That is where buyers from that moment sit at break-even, which is why price keeps coming back to it.

One anchor answers one question, so most traders end up dropping three or four by hand and dropping them again every session. This runs three at once: each anchors where you want, each carries its own deviation bands, and the script shades the zones where two of them line up.

[b]THE CONFLUENCE SHADING[/b]
[image]https://www.tradingview.com/x/72JXV6CX/[/image]

[image]https://www.tradingview.com/x/0FvCl2N6/[/image]

Look at this first. It does work you would otherwise do by eye.

When your session VWAP and your weekly VWAP arrive at the same price, that price is being watched by two different groups at once. Those levels tend to matter more than either line alone, and with three curves running they are easy to miss.

The script shades between any two layers that come within your tolerance of each other - on by default at 8 points, and it checks all three pairings, 1 to 2, 1 to 3 and 2 to 3.

Set the tolerance in ticks, points, currency, or percent of price. Trading more than one instrument, use percent: it is the only one you never have to re-tune when you change symbol.

[b]THE ANCHORS[/b]
Ten per layer, mixed freely.

[*][b]Set and forget[/b] - Session, Week, Month, Quarter, Year. Re-anchors itself every new period.
[*][b]Pick the bar yourself[/b] - Manual timestamp. Type a date and time. This is the one for an earnings bar, a Fed day, a gap.
[*][b]Let the chart find it[/b] - prior-session high or low, confirmed swing high or low. These follow structure so you are not re-anchoring by hand.

Defaults are session and week, the pairing most intraday traders want.

Two things about the structure anchors look broken if nobody warns you:

[*][b]The curve shows up late.[/b] A swing is not a swing until enough bars print after it. At swing length 10 the line appears 10 bars after the pivot, then draws itself back to the pivot where it belongs.

[*][b]It never rewrites history.[/b] When a newer pivot confirms, the layer re-anchors from there forward. Everything already drawn stays put.

[b]THE BANDS[/b]
[image]https://www.tradingview.com/x/sZptC11G/[/image]

Up to three per layer, each with its own multiple from 0.0 to 10.0. They tell you how stretched price is from that anchored average. Four ways to measure the stretch:

[*][b]Standard deviation[/b] (default) - how far price usually strays from this average. The classic VWAP band.
[*][b]ATR[/b] - sized by recent range instead, so the envelope opens up in fast markets.
[*][b]Percent of VWAP[/b] - a fixed percentage. Same shape on any instrument.
[*][b]Standard error[/b] - starts wide on a fresh anchor and tightens as the window fills.

Type the multiples in, or load a Fibonacci preset: 0.382 / 0.618 / 1.0 for the inner set, 1.0 / 1.618 / 2.618 for the outer.

[b]IT TELLS YOU WHEN IT CANNOT DO ITS JOB[/b]
An anchored VWAP can quietly stop being volume-weighted, or stop covering the window you think it does. This one writes it on the layer's own label, and these notes cannot be switched off - they show even with line labels turned off:

[*][b]"UNWEIGHTED (no volume)"[/b] or [b]"N bars unweighted"[/b] - the feed gives no usable volume, so this is a plain average, not a VWAP. Most indices and some spot forex. This is the one that matters.
[*][b]"one bar per session" / "two-bar window"[/b] - a prior-session anchor on a daily or higher chart, where it can only ever span two bars.
[*][b]"clipped to the draw depth"[/b] or [b]"segment past the 5,000-bar buffer, not drawn"[/b] - the line starts in mid-air because it hit a drawing limit, instead of pretending it reaches further back than it does.
[*][b]"(retro)"[/b] - a structure anchor, found after the fact. [b]"RTH"[/b] - regular hours only, which changes what the average is.

A clean chart carries none of these. One showing up means something you could not otherwise see has happened.

[b]SETTING IT UP[/b]
[*]Add it. Layer 1 takes the session, layer 2 the week, and the shading marks where they agree.
[*]Want one clean line? Switch layer 2 off. Want a third timeframe? Switch layer 3 on.
[*]Anchoring to an event: Manual timestamp, then the bar's date and time. Anchoring to structure: a confirmed swing or a prior-session extreme.
[*]Running two or three layers, turn on "Show anchor" - once bands overlap, a label naming its starting bar beats one that just says "L2".

84 inputs in seven groups, and anything that does not apply greys itself out.

[b]ALERTS[/b]
One alert: VWAP crosses, band crosses, both, or off. Create it in TradingView with "Any alert() function call". It only fires when a bar closes, never mid-bar, so you are not woken up by a wick that gets taken back.

[b]WORTH KNOWING BEFORE YOU USE IT[/b]
[*]Structure anchors draw late. That is the trade for anchoring to something only confirmable in hindsight.
[*]History runs 5,000 bars, and draw depth caps how far a line reaches. Hit either and the label says so instead of the line quietly stopping short.
[*]On "Regular hours only" the ATR bands still measure across every bar on the chart, so they use a wider set of bars than the average does.
[*]"Current window only" hides older curves once a repeating anchor has cluttered things up. Fills, the prior-window level and the confluence shading switch off in that mode.
[*]These bands are this script's own definition, not a claim of equivalence with anyone else's bands of the same name.
[*]Not usable in the Pine Screener - the manual anchor needs a time input, and the Screener substitutes its default instead of reading it, so it would anchor from the wrong bar without telling you.
[*]One symbol, one timeframe. No higher-timeframe or cross-symbol requests.

[b]WHAT MAKES IT DIFFERENT[/b]
[*]Three genuinely independent anchors - own anchor, own source, own colours, own bands. Not one anchor with presets.
[*]Confluence shading across all three pairings, in four choices of unit.
[*]It anchors to bars it can only recognise after the fact - prior-session extremes and confirmed swings - and back-fills the curve to them. A running-total VWAP cannot reach backwards like that without starting over.
[*]It states its own failure modes on the chart instead of returning a number that is not what its name says.
[*]Four band bases behind one band definition, and Fibonacci ratios as presets on the levels you already have rather than as extra clutter.

Open source under the Mozilla Public License 2.0.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry LLC

//@version=6
indicator(title = "Multi-Anchor_VWAP & Deviation Bands [AFD]", shorttitle = "Multi-AVWP [AFD]",
     overlay = true, max_polylines_count = 100, max_labels_count = 100, max_bars_back = 5000)

// ═══════════════════════════════════════════════════════════════════════════════
// Multi-Anchor_VWAP & Deviation Bands [AFD]
//
// Volume-weighted average price from up to three independently chosen anchors,
// with volume-weighted deviation bands around each.
//
// Anchors come in two kinds, and the difference is visible on the chart.
//
// FORWARD anchors — Session, Week, Month, Quarter, Year, Manual timestamp — are
// known the moment they occur, and the curve starts there.
//
// RETRO anchors — prior-session high and low, confirmed swing high and low — name a
// bar that can only be identified after it has passed. The curve appears at the
// confirming bar and extends back to the anchor bar. It draws late; it does not
// redraw. Nothing already on the chart moves, and when a newer anchor confirms, the
// layer re-anchors from that bar onward.
//
// Free and open source under the Mozilla Public License 2.0.
// ═══════════════════════════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════════════════════════
// Constants
// ═══════════════════════════════════════════════════════════════════════════════

// Settings-dialog sections, in the order Pine renders them.
const string GRP_LAYER1  = "📈 Layer 1"
const string GRP_LAYER2  = "📈 Layer 2"
const string GRP_LAYER3  = "📈 Layer 3"
const string GRP_ENGINE  = "⚙️ Engine"
const string GRP_LINES   = "🎨 Lines & fills"
const string GRP_LABELS  = "🏷️ Line labels"
const string GRP_ALERTS  = "🔔 Alerts"

const string SRC_HLC3  = "HLC3"
const string SRC_CLOSE = "Close"
const string SRC_HL2   = "HL2"

const string ANC_SESSION    = "Session"
const string ANC_WEEK       = "Week"
const string ANC_MONTH      = "Month"
const string ANC_QUARTER    = "Quarter"
const string ANC_YEAR       = "Year"
const string ANC_MANUAL     = "Manual timestamp"
const string ANC_PS_HIGH    = "Prior-session high"
const string ANC_PS_LOW     = "Prior-session low"
const string ANC_SWING_HIGH = "Confirmed swing high"
const string ANC_SWING_LOW  = "Confirmed swing low"

const string ALERT_OFF  = "Off"
const string ALERT_VWAP = "VWAP cross"
const string ALERT_BAND = "Band cross"
const string ALERT_BOTH = "VWAP or band cross"

// Histogram, Columns and Area are not offered: all three render from a zero
// baseline, so on a price overlay they would fill the pane from $0 up to the curve.
const string STYLE_LINE     = "Line"
const string STYLE_LINEBR   = "Line with breaks"
const string STYLE_STEP     = "Step line"
const string STYLE_STEPDIAM = "Step line with diamonds"
const string STYLE_CIRCLES  = "Circles"
const string STYLE_CROSS    = "Cross"

// `linestyle` takes effect only for the styles that draw lines, so the dash inputs
// grey out for Circles and Cross. The polylines take the same choice through
// line.style_*, so a dashed curve is dashed on both rendering paths.
const string DASH_SOLID  = "Solid"
const string DASH_DASHED = "Dashed"
const string DASH_DOTTED = "Dotted"

// All three placements are LEFT JUSTIFIED — every label's text begins at the same x
// and only the height differs, which is why the first reads "On the line" rather
// than "Right of the line".
//
// The label.style_label_* constants that deliver this are named for the direction the
// POINTER faces, not for where the text lands: style_label_left points left and puts
// the body to the RIGHT of the point. Reading them the other way round puts every
// label on the wrong side of its line.
const string LBL_ON    = "On the line"
const string LBL_ABOVE = "Above the line"
const string LBL_BELOW = "Below the line"

// The historical buffer, claimed in full by max_bars_back = 5000 on the declaration
// above, so offsets are valid over 0..4999. Every history read in this file is checked
// against it first. A retro anchor that would reach past it is DISCLOSED on that
// layer's label, never silently clamped and never returned as a bare na.
const int MAX_LOOKBACK = 4999

// Which bars the average is allowed to include.
const string SESSION_ALL = "Regular + extended hours"
const string SESSION_RTH = "Regular hours only"

// What the band multiples are multiples OF. Every band is `vwap ± mult × halfWidth`
// under all four; only what `halfWidth` is made of changes.
const string BASIS_SD      = "Standard deviation"
const string BASIS_ATR     = "ATR"
const string BASIS_PERCENT = "Percent of VWAP"
const string BASIS_SE      = "Standard error"

// What the confluence tolerance is measured IN.
const string UNIT_TICKS    = "Ticks"
const string UNIT_POINTS   = "Points"
const string UNIT_CURRENCY = "Currency"
const string UNIT_PERCENT  = "Percent of price"

// Where the three band multiples come from. A preset supplies all three at once;
// Manual leaves the three floats as set. The standard Fibonacci ratios: 0.382 and
// 0.618 retracement, 1.618 and 2.618 extension.
//
// A preset is per layer. The band basis is deliberately global, because two layers
// measuring by different rules put two incomparable envelopes on one price scale.
const string PRESET_MANUAL  = "Manual"
const string PRESET_FIB_IN  = "Fibonacci inner"
const string PRESET_FIB_OUT = "Fibonacci outer"


// ═══════════════════════════════════════════════════════════════════════════════
// Inputs
// ═══════════════════════════════════════════════════════════════════════════════

// Every control in a layer group is greyed out while that layer is off.

// ─── Layer 1 ───
l1EnabledInput     = input.bool(true, "Layer 1 enabled", group = GRP_LAYER1, display = display.none,
     tooltip = "Draw this anchored VWAP layer.\n\n• Layers 1 and 2 are on by default; layer 3 is off\n• The rest of this group is greyed out while this is off")
l1AnchorInput      = input.string(ANC_SESSION, "Anchor", group = GRP_LAYER1, display = display.none,
     active = l1EnabledInput,
     options = ["Session", "Week", "Month", "Quarter", "Year", "Manual timestamp",
     "Prior-session high", "Prior-session low", "Confirmed swing high", "Confirmed swing low"],
     tooltip = "Which bar the average starts from.\n\nForward anchors — Session, Week, Month, Quarter, Year, Manual timestamp:\n• Known at the moment they occur\n\nRetro anchors — Prior-session high/low, Confirmed swing high/low:\n• Identified only after their bar has passed\n• The curve appears at confirmation and extends back to the anchor bar\n• It draws late; it does not redraw\n• Nothing already on the chart moves")
l1SourceInput      = input.string(SRC_CLOSE, "Source price", group = GRP_LAYER1, display = display.none,
     active = l1EnabledInput, options = ["HLC3", "Close", "HL2"],
     tooltip = "The per-bar price the average is taken over.\n\n• Close is the default\n• HLC3 is what TradingView's own VWAP uses, which keeps a like-for-like comparison meaningful")
// input.time's defval must be a `const int`, and only the single-argument overload of
// timestamp() returns one. The zone offset is written into the string so the default
// is one instant rather than a different instant per exchange.
l1ManualTimeInput  = input.time(timestamp("1 Jan 2026 00:00 +0000"), "Manual anchor time", group = GRP_LAYER1,
     display = display.none, active = l1EnabledInput and l1AnchorInput == ANC_MANUAL,
     tooltip = "Used only when Anchor is 'Manual timestamp'.\n\n• The layer anchors to the first bar at or after this time\n• The Pine Screener substitutes the default for time inputs rather than reading this value, so this script is not Screener-eligible")
l1SwingLengthInput = input.int(10, "Swing length (bars)", group = GRP_LAYER1, minval = 2, maxval = 100,
     display = display.none,
     active = l1EnabledInput and (l1AnchorInput == ANC_SWING_HIGH or l1AnchorInput == ANC_SWING_LOW),
     tooltip = "Used only by the confirmed-swing anchors.\n\n• Bars required either side of a pivot before it is confirmed\n• A pivot confirms this many bars after it prints\n• The layer anchors to the newest confirmed pivot")
l1ColorInput       = input.color(#FFEB3B, "Color", group = GRP_LAYER1, display = display.none,
     active = l1EnabledInput,
     tooltip = "Sets this layer's VWAP line, and its band lines and fills unless the override below takes them.\n\n• Band and fill transparency are set once for all layers, under Lines & fills\n• Label text follows this color too, unless 'Override text color' below is on — then the two text colors take over")
l1BandColorOnInput = input.bool(false, "Override band color", group = GRP_LAYER1,
     display = display.none, active = l1EnabledInput,
     tooltip = "Give THIS layer's bands a color of their own instead of the Color above.\n\n• Off, the band lines, their fills and their label text all follow the layer Color\n• On, all three follow the color below — the fill moves with the lines deliberately, because a fill left on the old color would sit between band lines it no longer matches\n• The VWAP line and its label are never affected either way\n• Every layer has its own switch, so one layer's bands can be pushed back without touching another's")
l1BandColorInput   = input.color(#FFF59D, "Band line color", group = GRP_LAYER1,
     display = display.none, active = l1EnabledInput and l1BandColorOnInput,
     tooltip = "The color this layer's band LINES draw in, and the color their fills and label text are taken from.\n\n• Transparency is not picked here — the lines take 'Band transparency' and the fills take 'Fill transparency', both under Lines & fills\n• The prior-window level follows it too, because that level is drawn in the band's color and width\n• Band LABEL text can still be set exactly, ignoring this, with 'Override text color' below")
l1OverrideInput    = input.bool(false, "Override text color", group = GRP_LAYER1,
     display = display.none, active = l1EnabledInput,
     tooltip = "Stop THIS layer's label text taking the colors its lines take, and use the two colors below instead.\n\n• Off, the VWAP label is written in this layer's Color and the band labels in whatever color their lines are on, lightened by 30\n• On, each color is applied exactly as picked, transparency included\n• Every layer has its own switch, so one layer's text can be made readable without touching another's")
l1VwapTextInput    = input.color(color.white, "VWAP text", group = GRP_LAYER1, inline = "l1txt",
     display = display.none, active = l1EnabledInput and l1OverrideInput)
l1BandTextInput    = input.color(color.silver, "band text", group = GRP_LAYER1, inline = "l1txt",
     display = display.none, active = l1EnabledInput and l1OverrideInput,
     tooltip = "The writing on this layer's labels — left swatch the VWAP label, right swatch the band labels.\n\n• Neither swatch touches a LINE. This is not the band lines, which follow 'Band line color' above while its override is on and the layer Color while it is off, at the transparency set under Lines & fills\n• The VWAP line always takes the layer Color\n• Both are used exactly as picked, so 'band text' at full opacity is expressible here and nowhere else")
l1PresetInput      = input.string(PRESET_MANUAL, "Band multiples", group = GRP_LAYER1,
     display = display.none, active = l1EnabledInput,
     options = ["Manual", "Fibonacci inner", "Fibonacci outer"],
     tooltip = "Where this layer's three multiples come from.\n\n• Manual — the three values below, set by hand. The default, and nothing about the bands changes while it is selected\n• Fibonacci inner — 0.382, 0.618 and 1.000, so all three levels sit at or inside one unit of the basis\n• Fibonacci outer — 0.618, 1.618 and 2.618, which puts band 1 inside that unit and bands 2 and 3 beyond it\n• A preset greys the three multiples out rather than quietly overriding them, so the chart always shows what the dialog shows\n• Each layer has its own setting")
l1Band1OnInput     = input.bool(true, "Band 1", group = GRP_LAYER1, inline = "l1b1", display = display.none,
     active = l1EnabledInput,
     tooltip = "Draw this deviation band, at the multiple beside it.\n\n• Each band switch is also its label switch\n• A band that is off gets no line, no label and no fill\n• The multiple is greyed out while a Fibonacci preset supplies it")
l1Band1MultInput   = input.float(1.0, "x multiple", group = GRP_LAYER1, inline = "l1b1", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l1EnabledInput and l1Band1OnInput and l1PresetInput == PRESET_MANUAL)
l1Band2OnInput     = input.bool(false, "Band 2", group = GRP_LAYER1, inline = "l1b2", display = display.none,
     active = l1EnabledInput)
l1Band2MultInput   = input.float(2.0, "x multiple", group = GRP_LAYER1, inline = "l1b2", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l1EnabledInput and l1Band2OnInput and l1PresetInput == PRESET_MANUAL)
l1Band3OnInput     = input.bool(false, "Band 3", group = GRP_LAYER1, inline = "l1b3", display = display.none,
     active = l1EnabledInput)
l1Band3MultInput   = input.float(3.0, "x multiple", group = GRP_LAYER1, inline = "l1b3", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l1EnabledInput and l1Band3OnInput and l1PresetInput == PRESET_MANUAL)

// ─── Layer 2 ───
l2EnabledInput     = input.bool(true, "Layer 2 enabled", group = GRP_LAYER2, display = display.none,
     tooltip = "Draw this anchored VWAP layer.\n\n• The rest of this group is greyed out while this is off")
l2AnchorInput      = input.string(ANC_WEEK, "Anchor", group = GRP_LAYER2, display = display.none,
     active = l2EnabledInput,
     options = ["Session", "Week", "Month", "Quarter", "Year", "Manual timestamp",
     "Prior-session high", "Prior-session low", "Confirmed swing high", "Confirmed swing low"],
     tooltip = "Which bar the average starts from.\n\n• Retro anchors draw late and do not redraw — see the Layer 1 tooltip")
l2SourceInput      = input.string(SRC_CLOSE, "Source price", group = GRP_LAYER2, display = display.none,
     active = l2EnabledInput, options = ["HLC3", "Close", "HL2"],
     tooltip = "The per-bar price the average is taken over.\n\n• Close is the default; HLC3 is what TradingView's own VWAP uses")
l2ManualTimeInput  = input.time(timestamp("1 Jan 2026 00:00 +0000"), "Manual anchor time", group = GRP_LAYER2,
     display = display.none, active = l2EnabledInput and l2AnchorInput == ANC_MANUAL,
     tooltip = "The instant this layer anchors to.\n\n• Used only when Anchor is 'Manual timestamp'\n• The layer anchors to the first bar at or after this time")
l2SwingLengthInput = input.int(10, "Swing length (bars)", group = GRP_LAYER2, minval = 2, maxval = 100,
     display = display.none,
     active = l2EnabledInput and (l2AnchorInput == ANC_SWING_HIGH or l2AnchorInput == ANC_SWING_LOW),
     tooltip = "Used only by the confirmed-swing anchors.\n\n• Bars required either side of a pivot before it is confirmed\n• The layer anchors to the newest confirmed pivot")
l2ColorInput       = input.color(#00E5FF, "Color", group = GRP_LAYER2, display = display.none,
     active = l2EnabledInput,
     tooltip = "Sets this layer's VWAP line, and its band lines and fills unless the override below takes them.\n\n• Label text follows it too, unless 'Override text color' below is on\n• Band and fill transparency are set once for all layers, under Lines & fills")
l2BandColorOnInput = input.bool(false, "Override band color", group = GRP_LAYER2,
     display = display.none, active = l2EnabledInput,
     tooltip = "Give THIS layer's bands a color of their own instead of the Color above.\n\n• The band lines, their fills and their label text all move together\n• The VWAP line and its label are never affected\n• Every layer has its own switch")
l2BandColorInput   = input.color(#80DEEA, "Band line color", group = GRP_LAYER2,
     display = display.none, active = l2EnabledInput and l2BandColorOnInput,
     tooltip = "The color this layer's band LINES draw in, and the color their fills and label text are taken from.\n\n• Transparency is not picked here — the lines take 'Band transparency' and the fills take 'Fill transparency', both under Lines & fills\n• The prior-window level follows it too")
l2OverrideInput    = input.bool(false, "Override text color", group = GRP_LAYER2,
     display = display.none, active = l2EnabledInput,
     tooltip = "Stop THIS layer's label text taking the colors its lines take, and use the two colors below instead.\n\n• Off, the VWAP label takes this layer's Color and the band labels take their line color, lightened by 30\n• On, each color is applied exactly as picked, transparency included\n• Every layer has its own switch")
l2VwapTextInput    = input.color(color.white, "VWAP text", group = GRP_LAYER2, inline = "l2txt",
     display = display.none, active = l2EnabledInput and l2OverrideInput)
l2BandTextInput    = input.color(color.silver, "band text", group = GRP_LAYER2, inline = "l2txt",
     display = display.none, active = l2EnabledInput and l2OverrideInput,
     tooltip = "The writing on this layer's labels — left swatch the VWAP label, right swatch the band labels.\n\n• Neither swatch touches a LINE. This is not the band lines, which follow 'Band line color' above while its override is on and the layer Color while it is off\n• Both are used exactly as picked, transparency included")
l2PresetInput      = input.string(PRESET_MANUAL, "Band multiples", group = GRP_LAYER2,
     display = display.none, active = l2EnabledInput,
     options = ["Manual", "Fibonacci inner", "Fibonacci outer"],
     tooltip = "Where this layer's three multiples come from.\n\n• Manual — the three values below, set by hand. The default\n• Fibonacci inner — 0.382, 0.618 and 1.000\n• Fibonacci outer — 0.618, 1.618 and 2.618\n• A preset greys the three multiples out rather than quietly overriding them")
l2Band1OnInput     = input.bool(true, "Band 1", group = GRP_LAYER2, inline = "l2b1", display = display.none,
     active = l2EnabledInput,
     tooltip = "Draw this deviation band, at the multiple beside it.\n\n• Each band switch is also its label switch\n• A band that is off gets no line, no label and no fill")
l2Band1MultInput   = input.float(1.0, "x multiple", group = GRP_LAYER2, inline = "l2b1", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l2EnabledInput and l2Band1OnInput and l2PresetInput == PRESET_MANUAL)
l2Band2OnInput     = input.bool(false, "Band 2", group = GRP_LAYER2, inline = "l2b2", display = display.none,
     active = l2EnabledInput)
l2Band2MultInput   = input.float(2.0, "x multiple", group = GRP_LAYER2, inline = "l2b2", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l2EnabledInput and l2Band2OnInput and l2PresetInput == PRESET_MANUAL)
l2Band3OnInput     = input.bool(false, "Band 3", group = GRP_LAYER2, inline = "l2b3", display = display.none,
     active = l2EnabledInput)
l2Band3MultInput   = input.float(3.0, "x multiple", group = GRP_LAYER2, inline = "l2b3", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l2EnabledInput and l2Band3OnInput and l2PresetInput == PRESET_MANUAL)

// ─── Layer 3 ───
l3EnabledInput     = input.bool(false, "Layer 3 enabled", group = GRP_LAYER3, display = display.none,
     tooltip = "Draw this anchored VWAP layer.\n\n• The rest of this group is greyed out while this is off")
l3AnchorInput      = input.string(ANC_MONTH, "Anchor", group = GRP_LAYER3, display = display.none,
     active = l3EnabledInput,
     options = ["Session", "Week", "Month", "Quarter", "Year", "Manual timestamp",
     "Prior-session high", "Prior-session low", "Confirmed swing high", "Confirmed swing low"],
     tooltip = "Which bar the average starts from.\n\n• Retro anchors draw late and do not redraw — see the Layer 1 tooltip")
l3SourceInput      = input.string(SRC_CLOSE, "Source price", group = GRP_LAYER3, display = display.none,
     active = l3EnabledInput, options = ["HLC3", "Close", "HL2"],
     tooltip = "The per-bar price the average is taken over.\n\n• Close is the default; HLC3 is what TradingView's own VWAP uses")
l3ManualTimeInput  = input.time(timestamp("1 Jan 2026 00:00 +0000"), "Manual anchor time", group = GRP_LAYER3,
     display = display.none, active = l3EnabledInput and l3AnchorInput == ANC_MANUAL,
     tooltip = "The instant this layer anchors to.\n\n• Used only when Anchor is 'Manual timestamp'\n• The layer anchors to the first bar at or after this time")
l3SwingLengthInput = input.int(10, "Swing length (bars)", group = GRP_LAYER3, minval = 2, maxval = 100,
     display = display.none,
     active = l3EnabledInput and (l3AnchorInput == ANC_SWING_HIGH or l3AnchorInput == ANC_SWING_LOW),
     tooltip = "Used only by the confirmed-swing anchors.\n\n• Bars required either side of a pivot before it is confirmed\n• The layer anchors to the newest confirmed pivot")
l3ColorInput       = input.color(#AA00FF, "Color", group = GRP_LAYER3, display = display.none,
     active = l3EnabledInput,
     tooltip = "Sets this layer's VWAP line, and its band lines and fills unless the override below takes them.\n\n• Label text follows it too, unless 'Override text color' below is on\n• Band and fill transparency are set once for all layers, under Lines & fills")
l3BandColorOnInput = input.bool(false, "Override band color", group = GRP_LAYER3,
     display = display.none, active = l3EnabledInput,
     tooltip = "Give THIS layer's bands a color of their own instead of the Color above.\n\n• The band lines, their fills and their label text all move together\n• The VWAP line and its label are never affected\n• Every layer has its own switch")
l3BandColorInput   = input.color(#EA80FC, "Band line color", group = GRP_LAYER3,
     display = display.none, active = l3EnabledInput and l3BandColorOnInput,
     tooltip = "The color this layer's band LINES draw in, and the color their fills and label text are taken from.\n\n• Transparency is not picked here — the lines take 'Band transparency' and the fills take 'Fill transparency', both under Lines & fills\n• The prior-window level follows it too")
l3OverrideInput    = input.bool(false, "Override text color", group = GRP_LAYER3,
     display = display.none, active = l3EnabledInput,
     tooltip = "Stop THIS layer's label text taking the colors its lines take, and use the two colors below instead.\n\n• Off, the VWAP label takes this layer's Color and the band labels take their line color, lightened by 30\n• On, each color is applied exactly as picked, transparency included\n• Every layer has its own switch")
l3VwapTextInput    = input.color(color.white, "VWAP text", group = GRP_LAYER3, inline = "l3txt",
     display = display.none, active = l3EnabledInput and l3OverrideInput)
l3BandTextInput    = input.color(color.silver, "band text", group = GRP_LAYER3, inline = "l3txt",
     display = display.none, active = l3EnabledInput and l3OverrideInput,
     tooltip = "The writing on this layer's labels — left swatch the VWAP label, right swatch the band labels.\n\n• Neither swatch touches a LINE. This is not the band lines, which follow 'Band line color' above while its override is on and the layer Color while it is off\n• Both are used exactly as picked, transparency included")
l3PresetInput      = input.string(PRESET_MANUAL, "Band multiples", group = GRP_LAYER3,
     display = display.none, active = l3EnabledInput,
     options = ["Manual", "Fibonacci inner", "Fibonacci outer"],
     tooltip = "Where this layer's three multiples come from.\n\n• Manual — the three values below, set by hand. The default\n• Fibonacci inner — 0.382, 0.618 and 1.000\n• Fibonacci outer — 0.618, 1.618 and 2.618\n• A preset greys the three multiples out rather than quietly overriding them")
l3Band1OnInput     = input.bool(true, "Band 1", group = GRP_LAYER3, inline = "l3b1", display = display.none,
     active = l3EnabledInput,
     tooltip = "Draw this deviation band, at the multiple beside it.\n\n• Each band switch is also its label switch\n• A band that is off gets no line, no label and no fill")
l3Band1MultInput   = input.float(1.0, "x multiple", group = GRP_LAYER3, inline = "l3b1", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l3EnabledInput and l3Band1OnInput and l3PresetInput == PRESET_MANUAL)
l3Band2OnInput     = input.bool(false, "Band 2", group = GRP_LAYER3, inline = "l3b2", display = display.none,
     active = l3EnabledInput)
l3Band2MultInput   = input.float(2.0, "x multiple", group = GRP_LAYER3, inline = "l3b2", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l3EnabledInput and l3Band2OnInput and l3PresetInput == PRESET_MANUAL)
l3Band3OnInput     = input.bool(false, "Band 3", group = GRP_LAYER3, inline = "l3b3", display = display.none,
     active = l3EnabledInput)
l3Band3MultInput   = input.float(3.0, "x multiple", group = GRP_LAYER3, inline = "l3b3", minval = 0.0,
     maxval = 10.0, step = 0.1, display = display.none,
     active = l3EnabledInput and l3Band3OnInput and l3PresetInput == PRESET_MANUAL)

// ─── Engine ───
sessionFilterInput = input.string(SESSION_ALL, "Bars included", group = GRP_ENGINE, display = display.none,
     options = ["Regular + extended hours", "Regular hours only"],
     tooltip = "Which bars contribute to the average, and to the prior-session extremes.\n\nRegular + extended hours (default):\n• Every bar the chart shows\n• What TradingView's own VWAP does, which keeps a like-for-like comparison meaningful\n• Labelled RTH+ETH\n\nRegular hours only:\n• Excludes pre-market and post-market bars\n• Also changes what a session IS, so the Session and Prior-session anchors move to the regular open and the regular session's extremes\n• Labelled RTH\n\nTwo cases where it does nothing, both disclosed rather than absorbed:\n• If the chart's own 'Extended trading hours' setting is off there are no extended bars to exclude\n• On futures, electronic hours ARE the exchange's regular session\n• Above 1D it does nothing at all, and the label says so\n\nWhere the label appears:\n• On each layer's VWAP label, because it changes what that average IS\n• RTH survives 'Label the lines' being switched off; RTH+ETH does not, because a restriction the user cannot see is the only one that has to be shown")
currentWindowOnlyInput = input.bool(false, "Current window only", group = GRP_ENGINE, display = display.none,
     tooltip = "Keep only the newest curve per layer — from its latest anchor to now — and hide every earlier period.\n\n• Use it when a repeating anchor, Session or Week, has filled the chart with old curves\n• How far back it reaches is capped by 'Draw depth' below\n• Every value stays in the Data Window on every bar\n\nThree features are unavailable in this mode, and each greys out while it is on:\n• The three fill zones\n• Prior window's closing VWAP\n• Shade layer confluence\n\nWhy:\n• All three need the plotted path, and this mode DRAWS its curves instead — Pine can only fill between plots\n• Circles and Cross are unreachable here for the same reason, so a curve in this mode stays a continuous line")
retroDepthInput = input.int(1000, "Draw depth (bars)", group = GRP_ENGINE, minval = 50, maxval = 5000,
     step = 50, display = display.none,
     tooltip = "The longest segment this script will draw, in bars.\n\n• Most of a curve is PLOTTED, and plotting is not affected by this\n\nTwo things have to be DRAWN instead, and this caps both:\n• 'Current window only' above — how far back from now the visible curve can reach. At 1000, a Session anchor on a 5-minute chart is never near the cap; a Year anchor is\n• A retro anchor's catch-up segment — the stretch from the anchor bar back-filled once the anchor is confirmed\n\n• Lower it if the script feels slow on a long history\n• A segment too long to draw in full is reported on that layer's label, not trimmed silently")
bandBasisInput = input.string(BASIS_SD, "Band basis", group = GRP_ENGINE, display = display.none,
     options = ["Standard deviation", "ATR", "Percent of VWAP", "Standard error"],
     tooltip = "What each layer's band multiples are multiples OF.\n\nStandard deviation (default):\n• How far price spread around the anchored average over the window itself\n• The band widens when participation was dispersed and narrows when it was concentrated\n\nATR:\n• The average true range over the last N bars, so a multiple is a multiple of recent bar size\n• Measured over EVERY chart bar, including bars 'Bars included' excludes from the average — so under 'Regular hours only' the bands are built from a wider set of bars than the VWAP is\n\nPercent of VWAP:\n• A multiple is a percent of the average itself, so the band scales with price and nothing else\n\nStandard error:\n• The same deviation, divided by the square root of the number of bars in the window\n• The envelope therefore starts wide at the anchor and tightens as bars accumulate, where the other three do not narrow for that reason alone\n• The bar count is a plain count of included bars, not a volume-weighted effective count, so on a window whose volume is concentrated in a few bars this is an approximation and is named here as one\n• Nothing follows from a narrow band. It describes how many bars the average has been measured over, and no more\n\n• Only the standard-deviation path is covered by the reference oracle's precision figures")
atrLengthInput = input.int(14, "ATR length", group = GRP_ENGINE, minval = 1, maxval = 500,
     display = display.none, active = bandBasisInput == BASIS_ATR,
     tooltip = "Bars in the ATR average.\n\n• Used only when 'Band basis' is ATR\n• Measured over every chart bar, whatever 'Bars included' is set to")

// ─── Lines & fills ───
//
// ONE TOOLTIP PER INLINE ROW, ON THE RIGHTMOST INPUT. When inputs share a line via
// `inline`, the dialog shows the LAST `tooltip` in the row and ignores the others, so
// a tooltip on any but the last input is dead text.
vwapStyleInput  = input.string(STYLE_LINE, "VWAP line", group = GRP_LINES, inline = "vwap",
     display = display.none,
     options = ["Line", "Line with breaks", "Step line", "Step line with diamonds", "Circles", "Cross"])
vwapDashInput   = input.string(DASH_DOTTED, "dash", group = GRP_LINES, inline = "vwap",
     display = display.none, options = ["Solid", "Dashed", "Dotted"],
     active = vwapStyleInput != STYLE_CIRCLES and vwapStyleInput != STYLE_CROSS)
vwapWidthInput  = input.int(1, "width", group = GRP_LINES, inline = "vwap", minval = 1, maxval = 10,
     display = display.none,
     tooltip = "How the VWAP curves are drawn — style, dash and width.\n\n• Three of the six styles look alike on an anchored average: Line, Line with breaks and Step line all draw a continuous curve that moves a tick or two a bar, so the staircase is sub-pixel and there is no gap for a break to open\n• Step line with diamonds, Circles and Cross are the three that visibly differ\n• Histogram, Columns and Area are not offered: all three render from a zero baseline, so on a price overlay they would fill the pane from $0 up to the curve\n• Circles and Cross apply to the plotted curve only — a segment that has to be DRAWN, which is any retro anchor and everything under 'Current window only', has no marker styles available and stays a continuous line\n• The dash pattern is greyed out for Circles and Cross, which draw per-bar markers rather than a line for a pattern to apply to\n• All three controls apply to every layer; color stays per-layer")
bandStyleInput  = input.string(STYLE_LINE, "Band lines", group = GRP_LINES, inline = "band",
     display = display.none,
     options = ["Line", "Line with breaks", "Step line", "Step line with diamonds", "Circles", "Cross"])
bandDashInput   = input.string(DASH_DOTTED, "dash", group = GRP_LINES, inline = "band",
     display = display.none, options = ["Solid", "Dashed", "Dotted"],
     active = bandStyleInput != STYLE_CIRCLES and bandStyleInput != STYLE_CROSS)
bandWidthInput  = input.int(1, "width", group = GRP_LINES, inline = "band", minval = 1, maxval = 10,
     display = display.none,
     tooltip = "How the deviation bands are drawn — style, dash and width.\n\n• The same six styles the VWAP row offers, set independently of it\n• Line, Line with breaks and Step line look alike on a band with no gaps in it; Step line with diamonds, Circles and Cross are the three that visibly differ\n• Line with breaks is the one worth knowing: it leaves a gap wherever a band is undefined instead of bridging across it\n• Circles and Cross apply to the plotted curve only, exactly as on the VWAP row — any retro anchor, and everything under 'Current window only', has no marker styles available and stays a continuous line\n• The dash pattern is greyed out for Circles and Cross, which draw per-bar markers rather than a line for a pattern to apply to")
bandTranspInput = input.int(55, "Band transparency", group = GRP_LINES, minval = 0,
     maxval = 100, display = display.none,
     tooltip = "0 is opaque, 100 is invisible.\n\n• Applies to the band LINES\n• Band text is held at 30 regardless: a line at 55 reads as subordinate, but text at 55 reads as unreadable")
// Three independent switches rather than one dropdown, so the zones compose.
fillBand1Input  = input.bool(false, "Fill inside band 1", group = GRP_LINES, inline = "fillz",
     display = display.none, active = not currentWindowOnlyInput,
     tooltip = "Shades the area between a layer's curves, in that layer's own color.\n\n• The three switches are independent — any combination of zones\n• A zone whose band is switched off is not filled, because it has no edge to fill to\n• All three are unavailable while 'Current window only' is on: that mode draws its curves instead of plotting them, and Pine can only fill between plots")
fill1To2Input   = input.bool(false, "band 1 to 2", group = GRP_LINES, inline = "fillz",
     display = display.none, active = not currentWindowOnlyInput)
fill2To3Input   = input.bool(false, "band 2 to 3", group = GRP_LINES, inline = "fillz",
     display = display.none, active = not currentWindowOnlyInput)
fillTranspInput = input.int(85, "Fill transparency", group = GRP_LINES, minval = 0, maxval = 100,
     display = display.none,
     active = (fillBand1Input or fill1To2Input or fill2To3Input) and not currentWindowOnlyInput)
showPriorInput = input.bool(false, "Prior window's closing VWAP", group = GRP_LINES,
     display = display.none, active = not currentWindowOnlyInput,
     tooltip = "Draws the value each layer's average had at the last bar of its PREVIOUS window, as a dotted step.\n\n• A weekly layer shows last week's closing VWAP; a session layer shows yesterday's\n• It holds flat through the current window and steps at each new anchor\n• Nothing before the first completed window, and nothing at all for a retro anchor until its first window has closed\n• Unavailable while 'Current window only' is on")
// Descriptive arithmetic about two observed averages: it states that they are close
// and makes no claim about what follows from that.
showConfluenceInput  = input.bool(true, "Shade layer confluence", group = GRP_LINES,
     display = display.none, active = not currentWindowOnlyInput,
     tooltip = "Shades the gap between two enabled layers wherever their anchored averages are within the tolerance below.\n\n• All three pairs are tested — layers 1-2, 1-3 and 2-3 — and a pair with either layer disabled is never shaded\n• Descriptive only: it marks where two averages agree, and says nothing about what happens next\n• Unavailable while 'Current window only' is on, for the same reason the fills are")
confluenceTolInput   = input.float(8.0, "within", group = GRP_LINES, inline = "conf",
     minval = 0.01, maxval = 1000.0, step = 0.1, display = display.none,
     active = showConfluenceInput and not currentWindowOnlyInput)
confluenceUnitInput  = input.string(UNIT_POINTS, "", group = GRP_LINES, inline = "conf",
     display = display.none, active = showConfluenceInput and not currentWindowOnlyInput,
     options = ["Ticks", "Points", "Currency", "Percent of price"])
confluenceColorInput = input.color(color.new(#FFFFFF, 82), "shade", group = GRP_LINES, inline = "conf",
     display = display.none, active = showConfluenceInput and not currentWindowOnlyInput,
     tooltip = "The tolerance, its unit, and the shade for layer confluence.\n\n• Ticks — the instrument's own minimum increment\n• Points — the price scale directly, so 0.5 is half a dollar on a dollar-quoted symbol\n• Currency — a cash amount, converted through the instrument's point value. On an instrument whose point value is 1, which is most stocks and indices, this reads the same as Points\n• Percent of price — a fraction of the midpoint between the two averages being compared, and the only one of the four that needs no re-tuning when you change symbol\n• The shade is applied exactly as picked, transparency included. Set the opacity here rather than expecting the fill transparency above to reach it — that one belongs to the band zones")

// ─── Line labels ───
showLabelsInput      = input.bool(true, "Label the lines", group = GRP_LABELS, display = display.none,
     tooltip = "Write each curve's name at its right-hand end.\n\n• One label per enabled curve: the VWAP and every enabled band\n• A band with its own switch off gets no label\n• The rest of this group is greyed out while this is off")
labelPlacementInput  = input.string(LBL_ON, "Placement", group = GRP_LABELS, display = display.none,
     active = showLabelsInput, options = ["On the line", "Above the line", "Below the line"],
     tooltip = "Where each label sits relative to its curve.\n\n• Every label is left justified — the text starts one 'Offset (bars)' right of the last bar and runs rightward, whatever its length\n• Only the height changes between these three\n• On the line — centred on the curve's price\n• Above / Below — clear of the curve, so a label cannot cover the line it names when several run close together")
labelOffsetInput     = input.int(10, "Offset (bars)", group = GRP_LABELS, minval = 0, maxval = 500,
     display = display.none, active = showLabelsInput,
     tooltip = "How far to the right of the last bar the labels start.\n\n• Every label's text begins at this x and runs rightward, so the offset sets the left edge they all share\n• 0 starts them on the last bar\n• 500 is the furthest into the future Pine will place a label")
labelShowAnchorInput = input.bool(false, "Show anchor", group = GRP_LABELS, display = display.none,
     active = showLabelsInput,
     tooltip = "Adds the anchor's resolved date and time — 2026-07-28 09:30 — to every label in the layer, band labels included.\n\n• This is the bar the curve starts from, not the name of the setting that chose it, so the line can be checked against the chart\n• Off by default: with one layer up, the layer tag alone is enough\n• Worth turning on when two layers are running and their bands interleave\n• Reads 'not resolved' until the anchor has fired, which a retro anchor does only once its bar is confirmed")
labelShowBandInput   = input.bool(true, "Show deviation band", group = GRP_LABELS, display = display.none,
     active = showLabelsInput,
     tooltip = "Adds the band's multiple, as STD +1 or STD −1.\n\n• Up to three decimals, and trailing zeros are dropped: a whole multiple reads +1 and a Fibonacci preset's 0.618 band reads +0.618\n• Never rounded to one decimal, which would label that 0.618 band as 0.6 and name a level that is not on the chart\n• Off with 'Show anchor' and 'Show price' also off leaves a band label with nothing in it but the layer tag, and that label is not drawn at all — the band lines keep their colour and lose their text\n• Off with either of those on, the band labels stay and carry what is left")
labelShowPriceInput  = input.bool(false, "Show price", group = GRP_LABELS, display = display.none,
     active = showLabelsInput,
     tooltip = "Adds the curve's current value at the last bar.\n\n• Off by default: every layer's VWAP is already in the Data Window")
labelShowBarSetInput = input.bool(true, "Show bar set", group = GRP_LABELS, display = display.none,
     active = showLabelsInput,
     tooltip = "Adds which bars went into the average — RTH+ETH — to each layer's VWAP label.\n\n• Written on the VWAP label only, never on a band label\n• This switch governs the ordinary case, where 'Bars included' is at its default and every bar counts\n• It does NOT govern the restricted case. With 'Bars included' set to 'Regular hours only', the label reads RTH whatever this is set to, because that one is a disclosure: an average built from part of the day is not the average the curve's name implies, and a user who cannot see the restriction cannot check the number\n• Above 1D the restricted case reads 'RTH (no effect above 1D)', since the filter admits every bar there")
labelShowPriorInput  = input.bool(false, "Show change vs prior window", group = GRP_LABELS,
     display = display.none, active = showLabelsInput and showPriorInput,
     tooltip = "Adds how far this layer's average has moved from the value its previous window closed at.\n\n• Written on the VWAP label only, as 'vs prior +4.12'\n• Needs 'Prior window's closing VWAP' under Lines & fills, which is the switch that computes it\n• Nothing is written until that layer has completed a window")
// Each layer's text-color override is declared in that layer's own block, because
// `active` cannot name a symbol declared below it.

// ─── Alerts ───
alertModeInput = input.string(ALERT_BOTH, "Alert on", group = GRP_ALERTS, display = display.none,
     options = ["VWAP or band cross", "VWAP cross", "Band cross", "Off"],
     tooltip = "What the script's alert() call reports.\n\n• Fires only when a realtime bar closes, never inside an unconfirmed bar\n• Create the alert in TradingView with 'Any alert() function call'\n• The message names the layer, its anchor, and what was crossed")


// ═══════════════════════════════════════════════════════════════════════════════
// Functions
// ═══════════════════════════════════════════════════════════════════════════════

// The per-bar price the average is taken over.
//
// The arm with no case label is the shipped default, so a value the dialog cannot
// produce lands on that rather than on na. cumPriceOf() and cumPriceSqOf() carry the
// same arms and all three must agree.
sourcePriceOf(string source) =>
    switch source
        SRC_HLC3 => hlc3
        SRC_HL2  => hl2
        => close

// Whether this bar's volume can be used as a weight at all.
weightIsVolume() =>
    not na(volume) and volume > 0.0

// The per-bar weight: volume when usable, otherwise 1.0.
//
// Applied PER BAR, so one zero-volume bar cannot make a whole window unweighted. The
// layer's label names the EFFECTIVE weighting, and that note has no off switch.
barWeightOf() =>
    weightIsVolume() ? volume : 1.0

// ─── The engine ───
//
// One definition, used by the plots, the labels, the alert and the retro polyline pass
// alike. Two anchor classes, one engine, two snapshot mechanisms.

// The single division in the engine, and its single guard. Every window quantity below
// derives from this one. A value check rather than an appeal to the weight sum being
// structurally positive, because in Pine na is not 0.0 and na / na does not raise.
windowMeanOf(float windowWeight, float windowPrice) =>
    bool usable = not na(windowWeight) and not na(windowPrice) and windowWeight > 0.0
    usable ? windowPrice / windowWeight : na

// VWAP over the window. `reference` is added back after the mean is taken: the
// accumulators hold (price - reference), and the mean of a shifted series is the
// shifted mean.
avwapOf(float windowWeight, float windowPrice, float reference) =>
    float mean = windowMeanOf(windowWeight, windowPrice)
    na(mean) ? na : reference + mean

// Volume-weighted POPULATION standard deviation over the window, by the computational
// formula E[d^2] - (E[d])^2 where d = price - reference. Variance is
// translation-invariant, so the rebasing shift cancels and needs no correction.
//
// Two rules are load-bearing. POPULATION, not sample — there is no (n - 1) correction.
// And the variance is CLAMPED AT ZERO before the square root, because the formula
// subtracts two nearly equal quantities and can return a small negative on a window
// whose prices barely moved.
//
// A third is honoured by absence: sigma is never compared to zero for equality. The
// engine has a resolution floor near 5.5e-07 price units, so a one-bar window returns
// that rather than 0.0, and smallness is tested against a tick-scaled threshold.
sigmaOf(float windowWeight, float windowPrice, float windowPriceSq) =>
    float mean     = windowMeanOf(windowWeight, windowPrice)
    float variance = na(mean) or na(windowPriceSq) ? na : windowPriceSq / windowWeight - mean * mean
    na(variance) ? na : math.sqrt(math.max(0.0, variance))

// ONE substitution, at ONE point in the arithmetic: every band is `vwap ± mult ×
// halfWidth` and only this changes when the basis does.
//
// The ATR arrives as a PARAMETER rather than from a ta.atr() call here. The drawn path
// calls this from inside a loop inside a conditional, and a ta.* call in that position
// does not have a value on every bar.
//
// `bars` — the count of included bars — arrives as a parameter for the same reason: the
// drawn path has to hand in the value that bar had. A basis reading a global here would
// build the drawn half of a curve from the newest window length and the plotted half
// from each bar's own, stepping in the middle of a curve that is otherwise correct.
halfWidthOf(float vwap, float sigma, float atr, float bars) =>
    switch bandBasisInput
        BASIS_ATR     => atr
        BASIS_PERCENT => na(vwap) ? na : vwap / 100.0
        BASIS_SE      => na(sigma) or na(bars) or bars < 1.0 ? na : sigma / math.sqrt(bars)
        => sigma

// The confluence tolerance converted into price units, so the comparison at the call
// site stays `math.abs(a - b) <= gap` under every unit.
//
// It takes BOTH levels because Percent needs a denominator, and the only defensible one
// is the pair's own midpoint — reading a single layer's average would give the 1-to-2
// and 1-to-3 pairs different denominators from the same setting.
//
// Currency divides by the point value. On an instrument whose point value is 1, most
// stocks and indices, that is the identity and Currency reads the same as Points.
//
// POINTS is the FALLBACK arm rather than a named one, the same idiom as
// sourcePriceOf(): the unlabelled arm is the shipped default. Changing the default
// means moving the arms with it.
confluenceGapOf(float levelA, float levelB) =>
    float pointValue = syminfo.pointvalue
    float midpoint   = na(levelA) or na(levelB) ? na : (levelA + levelB) / 2.0
    switch confluenceUnitInput
        UNIT_TICKS    => confluenceTolInput * syminfo.mintick
        UNIT_PERCENT  => na(midpoint) ? na : math.abs(midpoint) * confluenceTolInput / 100.0
        UNIT_CURRENCY => na(pointValue) or pointValue <= 0.0 ? na : confluenceTolInput / pointValue
        => confluenceTolInput

// Which multiple a band level actually uses. Manual returns the float the user set, so
// under the shipped default this is the identity.
//
// The preset and the manual value arrive as PARAMETERS rather than from either layer's
// globals: a shared function reading l1PresetInput would silently give layers 2 and 3
// layer 1's multiples, and every number on the chart would still look consistent.
//
// `level` is 1, 2 or 3. There is no fourth — the plot-count budget is at 60 of 64 and a
// fourth band level costs twelve counts.
presetMultOf(string preset, int level, float manualMult) =>
    switch preset
        PRESET_FIB_IN  => level == 1 ? 0.382 : level == 2 ? 0.618 : 1.000
        PRESET_FIB_OUT => level == 1 ? 0.618 : level == 2 ? 1.618 : 2.618
        => manualMult

// Whether an anchor names a bar identified only after it passed. Retro layers are the
// only ones that need a polyline and the only ones bound by the historical buffer.
isRetroAnchor(string mode) =>
    mode == ANC_PS_HIGH or mode == ANC_PS_LOW or mode == ANC_SWING_HIGH or mode == ANC_SWING_LOW

// Two-digit zero padding for the resolved anchor timestamp.
pad2(int value) =>
    value < 10 ? "0" + str.tostring(value) : str.tostring(value)

// The anchor's resolved date and time in the exchange's own time zone. An anchor is
// identified by THE BAR IT STARTS ON, not by the input that selected it.
formatBarTime(int barTime) =>
    string out = "not resolved"
    if not na(barTime)
        out := str.tostring(year(barTime)) + "-" + pad2(month(barTime)) + "-" + pad2(dayofmonth(barTime)) +
         " " + pad2(hour(barTime)) + ":" + pad2(minute(barTime))
    out

// Did price cross this level on this bar? EVERY previous-bar value is passed in, so
// this reaches into no history and holds no state.
//
// That is a requirement. The alert section calls this from inside conditional blocks,
// so the call runs on an unpredictable subset of bars, and Pine commits a call's time
// series only on the bars it actually runs. A function reading close[1] internally
// would there be reading the close of the previous bar THE CALL RAN ON — comparing
// against a stale close and reporting a crossing that never happened.
crossedLevel(float level, float previousLevel, float previousClose) =>
    bool usable = not na(level) and not na(previousLevel) and not na(previousClose)
    usable and ((close > level and previousClose <= previousLevel) or
     (close < level and previousClose >= previousLevel))

// "" when nothing was crossed, otherwise the clause naming what was crossed and in
// which direction. Descriptive only: no probability, target or action language.
crossPhrase(float level, float previousLevel, float previousClose, string levelName) =>
    crossedLevel(level, previousLevel, previousClose) ?
     (close > level ? "crossed above " : "crossed below ") + levelName : ""

// The basis these multiples are multiples of, in one word for the label and in prose
// for the alert. Read from the input at each call, because a global would be read
// above the line that declares it.
basisTag() =>
    switch bandBasisInput
        BASIS_ATR     => "ATR"
        BASIS_PERCENT => "%"
        BASIS_SE      => "SE"
        => "STD"

basisWord() =>
    switch bandBasisInput
        BASIS_ATR     => "ATR"
        BASIS_PERCENT => "percent-of-VWAP"
        BASIS_SE      => "standard-error"
        => "sigma"

// Which bars went into the average: RTH for the regular session, ETH for the extended
// one. Three strings rather than two, because above 1D the filter genuinely does
// nothing and a bare "RTH" there would name a restriction that is not in force.
sessionTag() =>
    sessionFilterInput == SESSION_RTH ?
     (timeframe.isintraday ? "RTH" : "RTH (no effect above 1D)") : "RTH+ETH"

// A band's name in alert copy. It follows the basis for the same reason the label does:
// an alert saying "the +1.0 sigma band" while the band was built from ATR is a false
// statement about what was crossed.
//
// UP TO three decimals, never one. `"0.0"` renders 0.618 as "0.6", naming a band that
// is not on the chart. In `"0.###"` the `#` prints a digit or nothing, so 0.618 stays
// and a whole multiple loses its trailing zeros.
bandName(float mult, bool upper) =>
    (upper ? "the +" : "the -") + str.tostring(mult, "0.###") + " " + basisWord() + " band"

// ─── Line-label composition ───
//
// Each switch controls exactly the element it names. The layer tag is not one of them:
// it is the label's identity, and a label that could lose it would let two layers print
// the same text at two different prices.

// The band element, "STD +1", and "" when switched off, which the composer reads as
// "omit this element". The format string is bandName()'s and has to be: a label reading
// "STD +1" beside an alert reading "the +1.000 sigma band" describes two bands.
bandTag(float mult, bool upper) =>
    labelShowBandInput ? basisTag() + " " + (upper ? "+" : "−") + str.tostring(mult, "0.###") : ""

// tag · anchor · kind · price, with the middle three omitted when off or empty. `kind`
// is "VWAP" for a VWAP curve and a bandTag() for a band, so the VWAP keeps its name
// even when the band element is off.
//
// `anchorStamp` is the anchor's RESOLVED DATE AND TIME, never the mode name the input
// selected — "Session" names the rule that picked the bar rather than the bar itself,
// so a label carrying it cannot be checked against the chart.
labelText(string tag, string anchorStamp, string kind, float value) =>
    string out = tag
    if labelShowAnchorInput
        out := out + " · " + anchorStamp
    if kind != ""
        out := out + " · " + kind
    if labelShowPriceInput and not na(value)
        out := out + " · " + str.tostring(value, format.mintick)
    out

// Three LEFT-anchored styles, so every label's text starts at the same x. The centring
// styles leave a ragged left edge, because a long label and a short one at the same
// offset begin in two different places and the eye reads the left edge.
//
// These constants are named for the direction the POINTER faces, so each of them puts
// the body to the right of the point. The body is drawn fully transparent at the call
// site, so they render as bare text rather than as a bubble with a tail.
labelStyleOf(string placement) =>
    switch placement
        LBL_ABOVE => label.style_label_lower_left
        LBL_BELOW => label.style_label_upper_left
        => label.style_label_left

// ─── Disclosure notes ───
//
// Each note is EMPTY when there is nothing to say, so a note appearing means something
// the user cannot otherwise see has happened.
//
// NONE OF THEM HAS AN OFF SWITCH. A user who cannot see that an average is unweighted,
// or that a curve was clipped, cannot check the number. The labels obey the label
// switches; the notes do not, and labelLayer() draws a layer's VWAP label even with
// labels off when that layer owes one.

// Accumulate note parts without a separator on either end.
joinNote(string acc, string part) =>
    part == "" ? acc : acc == "" ? part : acc + " · " + part

// How this particular anchor is behaving right now.
//
// ORDER MATTERS. The degeneracy test must not sit behind `else if isRetro`: the two
// anchors that need it most are Prior-session high and low, which are retro, would take
// the retro branch, and would report nothing unusual while producing a permanent
// two-bar average. On a chart whose bars are a day or longer, every bar both closes a
// session and opens one, so the prior session's extreme is always the previous bar.
anchorNote(string mode, bool isRetro, bool beyondBuffer, bool degenerate) =>
    string out = ""
    if beyondBuffer
        out := "⚠ beyond buffer"
    else if degenerate and mode == ANC_SESSION
        out := "⚠ one bar per session"
    else if degenerate and (mode == ANC_PS_HIGH or mode == ANC_PS_LOW)
        out := "⚠ two-bar window"
    else if isRetro
        out := "(retro)"
    out

// The weighting rule actually in force, and "" when it is the volume weighting the name
// VWAP promises. Silence means the average is what it claims to be.
weightingNote(float windowBars, float fallbackBars) =>
    string out = ""
    if not na(windowBars) and not na(fallbackBars) and windowBars > 0.0
        if fallbackBars >= windowBars
            out := "⚠ UNWEIGHTED (no volume)"
        else if fallbackBars > 0.0
            out := "⚠ " + str.tostring(fallbackBars, "0") + " bars unweighted"
    out

// Everything one layer owes the user, joined into one string.
//
// THIS BRANCH IS THE NON-DEFAULT CASE ONLY, and that is what keeps it a disclosure.
// Nothing here has an off switch, so a clause that fired on every chart would be a
// permanent label nobody could remove. The default bar set is named in labelLayer()
// instead, where the label switch governs it. The two halves are deliberately on two
// paths; see the join there.
layerNote(string mode, bool isRetro, bool beyondBuffer, bool degenerate,
     float windowBars, float fallbackBars, bool reachFailed, bool clipped) =>
    string out = joinNote("", anchorNote(mode, isRetro, beyondBuffer, degenerate))
    out := joinNote(out, weightingNote(windowBars, fallbackBars))
    if sessionFilterInput == SESSION_RTH
        out := joinNote(out, sessionTag())
    if reachFailed
        out := joinNote(out, "⚠ segment past the 5,000-bar buffer, not drawn")
    if clipped
        out := joinNote(out, "⚠ clipped to the draw depth")
    out


// ═══════════════════════════════════════════════════════════════════════════════
// Calculations
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Rendering choices, resolved once ───
//
// The dialog speaks in words; plot() and polyline.new() speak in constants. Translating
// once here keeps the plotted path and the drawn path from rendering the same curve two
// different ways. No explicit type keyword: `plot_style`, `plot_linestyle` and
// `line_style` are not types a Pine declaration can name.

vwapPlotStyle = vwapStyleInput == STYLE_LINEBR ? plot.style_linebr :
     vwapStyleInput == STYLE_STEP ? plot.style_stepline :
     vwapStyleInput == STYLE_STEPDIAM ? plot.style_stepline_diamond :
     vwapStyleInput == STYLE_CIRCLES ? plot.style_circles :
     vwapStyleInput == STYLE_CROSS ? plot.style_cross : plot.style_line
bandPlotStyle = bandStyleInput == STYLE_LINEBR ? plot.style_linebr :
     bandStyleInput == STYLE_STEP ? plot.style_stepline :
     bandStyleInput == STYLE_STEPDIAM ? plot.style_stepline_diamond :
     bandStyleInput == STYLE_CIRCLES ? plot.style_circles :
     bandStyleInput == STYLE_CROSS ? plot.style_cross : plot.style_line
// Same idiom as sourcePriceOf(): the arm with no test is the shipped default.
vwapDashStyle = vwapDashInput == DASH_DASHED ? plot.linestyle_dashed :
     vwapDashInput == DASH_SOLID ? plot.linestyle_solid : plot.linestyle_dotted
bandDashStyle = bandDashInput == DASH_DASHED ? plot.linestyle_dashed :
     bandDashInput == DASH_SOLID ? plot.linestyle_solid : plot.linestyle_dotted

// The same two choices for the drawn path. polyline.new() takes line.style_* rather
// than plot's own constants, so the mapping is written twice and means once.
//
// DASH crosses to the drawn path; STYLE cannot. A polyline has line_style and
// line_width and nothing else, so a retro segment — and every curve under 'Current
// window only' — stays a continuous line whatever the style dropdown says.
vwapPolyStyle = vwapDashInput == DASH_DASHED ? line.style_dashed :
     vwapDashInput == DASH_SOLID ? line.style_solid : line.style_dotted
bandPolyStyle = bandDashInput == DASH_DASHED ? line.style_dashed :
     bandDashInput == DASH_SOLID ? line.style_solid : line.style_dotted

// ─── The ATR the ATR basis reads ───
//
// Computed on EVERY bar whether or not the ATR basis is selected, which keeps the
// series CONTINUOUS: drawSegment reads bandAtr[back] at an arbitrary offset, and a ta.*
// series evaluated on only some bars has no value at the others.
//
// It is measured over every chart bar, INCLUDING bars 'Bars included' excludes from the
// average, so under 'Regular hours only' the bands are built from a wider set of bars
// than the VWAP is. Disclosed in the basis tooltip rather than absorbed.
float bandAtr = ta.atr(atrLengthInput)

// Where a line label's text sits, and the fully transparent body that carries it. The
// same transparent color hides a plot without removing its value — see the plots.
curveLabelStyle = labelStyleOf(labelPlacementInput)
color invisibleTone = color.new(color.black, 100)

// ─── Which bars count, and what a session IS ───
//
// Declared here, above the accumulators that read it, because Pine resolves names in
// declaration order. One switch, two consequences, and they have to move together.
//
// session.ismarket is documented as always true on 1D and above, so the intraday test
// is belt and braces rather than a second rule.
bool barIsRegular = session.ismarket
bool barIncluded  = sessionFilterInput == SESSION_ALL or not timeframe.isintraday or barIsRegular

// A SESSION starts on the first bar the filter admits: session.isfirstbar_regular under
// 'Regular hours only', session.isfirstbar — the first bar of the day INCLUDING
// pre-market — otherwise.
//
// USING isfirstbar_regular UNCONDITIONALLY IS A DEFECT while extended-hours bars are
// still being accumulated. Pre-market bars then arrive before the session roll and
// update the extremes of a session that has not ended, so a bar in TOMORROW's
// pre-market can become "the prior session's high".
bool newSessionBar = not timeframe.isintraday ? true :
     sessionFilterInput == SESSION_RTH ? session.isfirstbar_regular : session.isfirstbar

// ─── Running prefix sums, never reset ───
//
// After a bar is processed each accumulator holds the total over bars 0..i inclusive. A
// window [a, n] is the total at n minus the total at a - 1, and the total at a - 1 is
// accumulator[n - a + 1]. Writing `back` for n - a, EVERY anchor snapshot in this file
// is taken at [back + 1] — forward anchors included, where back = 0. That uniformity is
// the point: the two anchor classes differ only in the offset they difference against.

var float referencePrice = na

// One weight and bar-count prefix; price prefixes per source, because the source is a
// per-layer choice and three layers may make three different ones.
var float cumWeight       = 0.0
var float cumBars         = 0.0
var float cumFallbackBars = 0.0
var float cumPriceHlc3    = 0.0
var float cumPriceSqHlc3  = 0.0
var float cumPriceClose   = 0.0
var float cumPriceSqClose = 0.0
var float cumPriceHl2     = 0.0
var float cumPriceSqHl2   = 0.0

// Taken from the first INCLUDED bar, so a filtered-out pre-market bar cannot set the
// constant every later price is rebased against.
if na(referencePrice) and not na(hlc3) and barIncluded
    referencePrice := hlc3

float barWeight = barWeightOf()

// (price - reference): the rebased quantity that is actually accumulated. DO NOT REMOVE
// THE REBASING. Without it the bands reach a full tick of error at a $1,000,000 price
// level, and BRK.A trades near $740,000 quoted in cents. Rebasing moves that boundary
// to about $10^13 and costs one subtraction per bar.
float shiftedHlc3  = sourcePriceOf(SRC_HLC3) - referencePrice
float shiftedClose = sourcePriceOf(SRC_CLOSE) - referencePrice
float shiftedHl2   = sourcePriceOf(SRC_HL2) - referencePrice

// An excluded bar advances no accumulator, so every prefix holds its value across it and
// the window differencing skips it with no special case.
if not na(referencePrice) and barIncluded
    cumWeight       += barWeight
    cumBars         += 1.0
    cumFallbackBars += weightIsVolume() ? 0.0 : 1.0
    cumPriceHlc3    += shiftedHlc3 * barWeight
    cumPriceSqHlc3  += shiftedHlc3 * shiftedHlc3 * barWeight
    cumPriceClose   += shiftedClose * barWeight
    cumPriceSqClose += shiftedClose * shiftedClose * barWeight
    cumPriceHl2     += shiftedHl2 * barWeight
    cumPriceSqHl2   += shiftedHl2 * shiftedHl2 * barWeight

// ─── Point arrays for the retro pass ───
//
// Seven arrays, one per curve, filled in a single pass and cleared as each polyline is
// emitted. Peak is 35,000 chart.point objects at the 5,000-bar maximum, against a
// 100,000 cap. polyline.new() SNAPSHOTS its points array rather than holding a
// reference, which is what makes clearing and refilling safe.
var array<chart.point> retroVwapPoints = array.new<chart.point>()
var array<chart.point> retroUp1Points  = array.new<chart.point>()
var array<chart.point> retroDn1Points  = array.new<chart.point>()
var array<chart.point> retroUp2Points  = array.new<chart.point>()
var array<chart.point> retroDn2Points  = array.new<chart.point>()
var array<chart.point> retroUp3Points  = array.new<chart.point>()
var array<chart.point> retroDn3Points  = array.new<chart.point>()
var array<polyline>    retroPolylines  = array.new<polyline>()

// The line labels, kept the same way and deleted the same way. At most 21 exist at
// once: three layers by one VWAP and six band edges.
var array<label>       curveLabels     = array.new<label>()

// ─── Period boundaries ───
//
// On a chart whose bars are a day or longer every bar is its own session, so a session
// anchor spans exactly one bar. Correct, meaningless, and DISCLOSED on the label.
bool sessionAnchorDegenerate = not timeframe.isintraday

bool newWeekBar    = timeframe.change("1W")
bool newMonthBar   = timeframe.change("1M")
bool newQuarterBar = timeframe.change("3M")
bool newYearBar    = timeframe.change("12M")

// ─── Prior-session extremes ───
//
// Tracked forward once, globally. The roll happens on the session's first bar and before
// any anchor resolves below, so a layer anchoring to the prior session's high reads a
// completed session rather than a partial one.
var float currentSessionHigh    = na
var int   currentSessionHighIdx = na
var float currentSessionLow     = na
var int   currentSessionLowIdx  = na
var int   priorSessionHighIdx   = na
var int   priorSessionLowIdx    = na

if newSessionBar
    priorSessionHighIdx   := currentSessionHighIdx
    priorSessionLowIdx    := currentSessionLowIdx
    currentSessionHigh    := high
    currentSessionHighIdx := bar_index
    currentSessionLow     := low
    currentSessionLowIdx  := bar_index
else if barIncluded
    // `barIncluded` and not merely `else`: an excluded bar must not move the extremes
    // of a session it is not part of.
    if na(currentSessionHigh) or high > currentSessionHigh
        currentSessionHigh    := high
        currentSessionHighIdx := bar_index
    if na(currentSessionLow) or low < currentSessionLow
        currentSessionLow     := low
        currentSessionLowIdx  := bar_index

// ─── Pivot confirmation, per layer ───
//
// ta.pivothigh(n, n) returns a value on the bar that CONFIRMS a pivot, n bars after the
// pivot bar itself, and na everywhere else. Called unconditionally, once per layer.
float l1PivotHigh = ta.pivothigh(l1SwingLengthInput, l1SwingLengthInput)
float l1PivotLow  = ta.pivotlow(l1SwingLengthInput, l1SwingLengthInput)
float l2PivotHigh = ta.pivothigh(l2SwingLengthInput, l2SwingLengthInput)
float l2PivotLow  = ta.pivotlow(l2SwingLengthInput, l2SwingLengthInput)
float l3PivotHigh = ta.pivothigh(l3SwingLengthInput, l3SwingLengthInput)
float l3PivotLow  = ta.pivotlow(l3SwingLengthInput, l3SwingLengthInput)

// ─── Manual anchor arming, per layer ───
//
// A direct time comparison. Nothing here derives a bar step from time - time[1]: that
// delta is the overnight gap on a session's first bar. The polyline pass addresses bars
// by index for the same reason.
var bool l1ManualArmed = false
var bool l2ManualArmed = false
var bool l3ManualArmed = false

bool l1ManualHit = not l1ManualArmed and time >= l1ManualTimeInput
bool l2ManualHit = not l2ManualArmed and time >= l2ManualTimeInput
bool l3ManualHit = not l3ManualArmed and time >= l3ManualTimeInput

if l1ManualHit
    l1ManualArmed := true
if l2ManualHit
    l2ManualArmed := true
if l3ManualHit
    l3ManualArmed := true

// ═══ DEPARTURE FROM THE STYLE-GUIDE SECTION ORDER ═══
//
// The style guide places every function declaration before the calculations. The
// functions below read module-level engine state — the accumulators, the point arrays,
// the period booleans, the prior-session indices — and Pine resolves names in
// declaration order, so they cannot be declared before the state they read. Passing it
// all in instead would give drawSegment about twenty-six positional arguments across
// three near-identical call sites. Nothing else departs from the section order.
// ═══════════════════════════════════════════════════════════════════════════════

// Which prefix series a layer's source points at. These SELECT; they do not reach into
// history, and that distinction is the whole design.
//
// A function using the history operator must be called on every bar, because Pine
// commits a call's time series only on the bars it runs. A pair that took a `back`
// argument and returned cumPriceClose[back] would make every use inside the retro loop
// a history-dependent call made a data-dependent number of times per bar. Selecting
// here and taking history LATER moves the read to global scope.
cumPriceOf(string source) =>
    switch source
        SRC_HLC3 => cumPriceHlc3
        SRC_HL2  => cumPriceHl2
        => cumPriceClose

cumPriceSqOf(string source) =>
    switch source
        SRC_HLC3 => cumPriceSqHlc3
        SRC_HL2  => cumPriceSqHl2
        => cumPriceSqClose

// Does this bar start a new window for the given anchor mode?
anchorFires(string mode, bool manualHit, float pivotHigh, float pivotLow) =>
    switch mode
        ANC_SESSION    => newSessionBar
        ANC_WEEK       => newWeekBar
        ANC_MONTH      => newMonthBar
        ANC_QUARTER    => newQuarterBar
        ANC_YEAR       => newYearBar
        ANC_MANUAL     => manualHit
        ANC_PS_HIGH    => newSessionBar and not na(priorSessionHighIdx)
        ANC_PS_LOW     => newSessionBar and not na(priorSessionLowIdx)
        ANC_SWING_HIGH => not na(pivotHigh)
        ANC_SWING_LOW  => not na(pivotLow)
        => false

// How many bars back the anchor bar sits from the bar that resolved it. Zero for
// every forward anchor — that is what makes them forward anchors.
anchorBarsBack(string mode, int swingLength) =>
    switch mode
        ANC_PS_HIGH    => bar_index - priorSessionHighIdx
        ANC_PS_LOW     => bar_index - priorSessionLowIdx
        ANC_SWING_HIGH => swingLength
        ANC_SWING_LOW  => swingLength
        => 0

emitCurve(array<chart.point> points, color curveColor, int curveWidth, string curveStyle) =>
    if array.size(points) > 1
        array.push(retroPolylines, polyline.new(points, xloc = xloc.bar_index, line_color = curveColor,
             line_width = curveWidth, line_style = curveStyle))
    array.clear(points)

// Draws one layer's curve between two bar indices, for the two cases plot() cannot
// serve. Called once per layer on every bar; draws on one of them.
//
// CASE 1, the retro segment: the span between a retro anchor's bar and the bar that
// confirmed it. Pine cannot rewrite a past bar's plot value, so those bars are
// unreachable by plot() and this adds exactly what is missing.
//
// CASE 2, 'Current window only': the whole span from the anchor to the last bar.
// Whether a bar belongs to the FINAL window is not knowable while that bar is being
// processed, so no plot() can be fed the right value on the historical pass. The plots
// stay live and carry every value to the Data Window; they are simply drawn fully
// transparent, and this draws what the user sees.
//
// Returns true when there was a segment to draw and it could not be reached, so the
// layer's label can say a curve was left undrawn rather than let a user read a missing
// one as an absent anchor.
//
// `shouldDraw` is an ARGUMENT rather than an `if` around the call site. This function
// reaches into the history of its own parameters, so it has to be called on every bar:
// a call made only on barstate.islast would have a parameter history one bar deep. The
// gate moves inside, where it still confines the loop to the single bar that draws.

// Is there a segment to draw at all? Everything except WHEN the draw runs — the label
// needs this answer on every bar, the draw only on the last one.
drawableSegment(bool enabled, bool wanted, int anchorIdx, int endIdx) =>
    enabled and wanted and not na(anchorIdx) and not na(endIdx) and endIdx > anchorIdx

// The bar a drawn segment actually STARTS at, once the draw depth has been applied, so
// `segStartOf(...) != anchorIdx` IS the definition of clipped.
//
// ONE definition, two readers: drawSegment clamps its loop with it and the disclosure
// note decides with it. Two readers each doing their own arithmetic disagree — and a
// retro segment, whose window ends at its confirmation bar rather than at the current
// bar, is then clipped in silence.
segStartOf(int anchorIdx, int endIdx, int depth) =>
    int earliest = endIdx - depth
    anchorIdx > earliest ? anchorIdx : earliest

drawSegment(bool shouldDraw, bool enabled, bool wanted, int anchorIdx, int endIdx, float anchorWeight,
     float anchorPrice, float anchorPriceSq, float anchorBars, float cumPrice, float cumPriceSq,
     color layerColor,
     color bandColor, bool band1On, float band1Mult, bool band2On, float band2Mult, bool band3On,
     float band3Mult, int depth) =>
    bool drawable = shouldDraw and drawableSegment(enabled, wanted, anchorIdx, endIdx)
    int  segStart = not drawable ? na : segStartOf(anchorIdx, endIdx, depth)
    int  oldest   = drawable ? bar_index - segStart : na
    bool reachable = drawable and oldest <= MAX_LOOKBACK and oldest <= bar_index
    if reachable
        for b = segStart to endIdx
            int   back          = bar_index - b
            float windowWeight  = cumWeight[back] - anchorWeight
            float windowPrice   = cumPrice[back] - anchorPrice
            float windowPriceSq = cumPriceSq[back] - anchorPriceSq
            float windowBars    = cumBars[back] - anchorBars
            float pointVwap     = avwapOf(windowWeight, windowPrice, referencePrice)
            float pointSigma    = sigmaOf(windowWeight, windowPrice, windowPriceSq)
            // The basis has to reach the drawn path too. It changes VALUES rather
            // than appearance, but the visible failure is a step in the middle of a
            // curve that is drawing correctly on both sides.
            float pointHalf     = halfWidthOf(pointVwap, pointSigma, bandAtr[back], windowBars)
            if not na(pointVwap) and not na(pointHalf)
                array.push(retroVwapPoints, chart.point.from_index(b, pointVwap))
                if band1On
                    array.push(retroUp1Points, chart.point.from_index(b, pointVwap + band1Mult * pointHalf))
                    array.push(retroDn1Points, chart.point.from_index(b, pointVwap - band1Mult * pointHalf))
                if band2On
                    array.push(retroUp2Points, chart.point.from_index(b, pointVwap + band2Mult * pointHalf))
                    array.push(retroDn2Points, chart.point.from_index(b, pointVwap - band2Mult * pointHalf))
                if band3On
                    array.push(retroUp3Points, chart.point.from_index(b, pointVwap + band3Mult * pointHalf))
                    array.push(retroDn3Points, chart.point.from_index(b, pointVwap - band3Mult * pointHalf))
        emitCurve(retroVwapPoints, layerColor, vwapWidthInput, vwapPolyStyle)
        emitCurve(retroUp1Points, bandColor, bandWidthInput, bandPolyStyle)
        emitCurve(retroDn1Points, bandColor, bandWidthInput, bandPolyStyle)
        emitCurve(retroUp2Points, bandColor, bandWidthInput, bandPolyStyle)
        emitCurve(retroDn2Points, bandColor, bandWidthInput, bandPolyStyle)
        emitCurve(retroUp3Points, bandColor, bandWidthInput, bandPolyStyle)
        emitCurve(retroDn3Points, bandColor, bandWidthInput, bandPolyStyle)
    drawable and not reachable

// One band edge's label, and the rule that a label with nothing in it is not drawn.
//
// Section-order departure, the same one labelLayer() takes: this is in the calculations
// section because it writes to `curveLabels`, which is module-level state declared
// above. The label helpers in the functions section only read inputs and compose
// strings.
//
// Every element of a band label is switchable, and with all three off the text collapses
// to the layer tag alone — two labels reading "L1" at two prices. So the comparison is
// against `tag`, not against the empty string. Only band labels come through here; the
// VWAP label keeps its own rule, because it carries the disclosure note.
pushBandLabel(int labelX, string tag, string anchorStamp, string kind, float price, color tone) =>
    string body = labelText(tag, anchorStamp, kind, price)
    if body != tag
        array.push(curveLabels, label.new(labelX, price, body,
             style = curveLabelStyle, color = invisibleTone, textcolor = tone,
             size = size.small, textalign = text.align_left))

// Writes one layer's curve names at the right-hand end of its lines. Takes every value
// as a parameter and reaches into no history, so unlike drawSegment it can be called
// from anywhere. A band with its own switch off gets no label.
//
// `note` is this layer's disclosure string and it OVERRIDES the label switch: a layer
// that owes one is labelled even with 'Label the lines' off.
//
// Every color arrives as a PARAMETER. They are per-layer inputs, and one shared function
// reading l1VwapTextInput would render three call sites in layer 1's colors while every
// number stayed right.
labelLayer(bool shouldDraw, bool enabled, string tag, string anchorStamp, string note, float vwap,
     float priorVwap, color tone, color bandLineColor, color vwapTextColor, color bandTextColor,
     bool overrideText, bool band1On, float band1Mult, float band1Upper, float band1Lower,
     bool band2On, float band2Mult, float band2Upper, float band2Lower,
     bool band3On, float band3Mult, float band3Upper, float band3Lower) =>
    // Band text is held at 30 whatever the lines do: a line at 55 reads as
    // subordinate, text at 55 reads as unreadable. Derived from `bandLineColor` and
    // not from `tone`, which is why that parameter exists — a layer whose bands have
    // their own color would otherwise be labelled in the color they used to be.
    //
    // Under the override the picked color is used EXACTLY as picked.
    color vwapTone = overrideText ? vwapTextColor : tone
    color bandTone = overrideText ? bandTextColor : color.new(bandLineColor, 30)
    // One x for every label in the layer. The 500-bar ceiling is enforced on the
    // input's maxval, so a clamp here would only disagree with the input.
    int    labelX    = bar_index + labelOffsetInput
    // How far this layer has moved from the value its previous window closed at.
    // This is DATA and it has a switch; the note beside it is DISCLOSURE and does
    // not. They compose into the same string and must not be confused.
    string priorTag  = labelShowPriorInput and not na(priorVwap) and not na(vwap) ?
         "vs prior " + (vwap >= priorVwap ? "+" : "−") +
         str.tostring(math.abs(vwap - priorVwap), format.mintick) : ""
    // Which bars went into this average — and EMPTY on the filtered case, which is
    // why this reads the input rather than calling sessionTag() outright. layerNote()
    // already carries the filtered case and has to, because that one is a disclosure
    // and survives the label switch being off.
    //
    // `labelShowBarSetInput` gates THIS half only. The filtered case takes no switch
    // and must never be given one.
    string barSetTag = labelShowBarSetInput and sessionFilterInput == SESSION_ALL ?
         sessionTag() : ""
    string vwapLine  = showLabelsInput ?
         joinNote(joinNote(joinNote(labelText(tag, anchorStamp, "VWAP", vwap), barSetTag),
         priorTag), note) :
         joinNote(tag, note)
    bool   layerReady = shouldDraw and enabled and not na(vwap)
    if layerReady and (showLabelsInput or note != "")
        array.push(curveLabels, label.new(labelX, vwap, vwapLine,
             style = curveLabelStyle, color = invisibleTone, textcolor = vwapTone, size = size.small,
             textalign = text.align_left))
    if layerReady and showLabelsInput
        if band1On and not na(band1Upper) and not na(band1Lower)
            pushBandLabel(labelX, tag, anchorStamp, bandTag(band1Mult, true),  band1Upper, bandTone)
            pushBandLabel(labelX, tag, anchorStamp, bandTag(band1Mult, false), band1Lower, bandTone)
        if band2On and not na(band2Upper) and not na(band2Lower)
            pushBandLabel(labelX, tag, anchorStamp, bandTag(band2Mult, true),  band2Upper, bandTone)
            pushBandLabel(labelX, tag, anchorStamp, bandTag(band2Mult, false), band2Lower, bandTone)
        if band3On and not na(band3Upper) and not na(band3Lower)
            pushBandLabel(labelX, tag, anchorStamp, bandTag(band3Mult, true),  band3Upper, bandTone)
            pushBandLabel(labelX, tag, anchorStamp, bandTag(band3Mult, false), band3Lower, bandTone)

// ─── One layer's prior-window level, drawn rather than plotted ───
//
// A line and not a plot, for budget: a plot() costs two of the 64 plot counts when its
// color is not a compile-time constant, so three user-colored levels would cost six.
// line.new() generates no plot count and line objects are capped at 500.
//
// A horizontal segment is also what the value honestly is — the average the previous
// window closed at, held flat across the window in progress.
//
// Two things are given up: only the current window is drawn, and a line publishes no
// value to the Data Window. The delta against the current average survives in the label.
//
// One line per layer for the life of the script, repositioned in place.
drawPriorLevel(line target, bool wanted, int anchorIdx, float level, color tone, int width) =>
    if wanted and not na(level) and not na(anchorIdx)
        line.set_xy1(target, anchorIdx, level)
        line.set_xy2(target, bar_index, level)
        line.set_color(target, tone)
        line.set_width(target, width)
    else
        line.set_color(target, invisibleTone)

// ─── The prefix series each layer is reading ───
//
// Resolved once per bar, at global scope, unconditionally. Everything below takes
// history of THESE rather than of a function call made inside an `if` or a `for`.
float l1CumPrice   = cumPriceOf(l1SourceInput)
float l1CumPriceSq = cumPriceSqOf(l1SourceInput)
float l2CumPrice   = cumPriceOf(l2SourceInput)
float l2CumPriceSq = cumPriceSqOf(l2SourceInput)
float l3CumPrice   = cumPriceOf(l3SourceInput)
float l3CumPriceSq = cumPriceSqOf(l3SourceInput)

// ─── Layer 1 resolution and value ───

var float l1AnchorWeight   = na
var float l1AnchorPrice    = na
var float l1AnchorPriceSq  = na
var float l1AnchorBars     = na
var float l1AnchorFallback = na
var int   l1AnchorIdx      = na
var int   l1AnchorTime     = na
var int   l1ConfirmIdx     = na
var bool  l1BeyondBuffer   = false

bool l1IsRetro = isRetroAnchor(l1AnchorInput)
bool l1Fires   = l1EnabledInput and anchorFires(l1AnchorInput, l1ManualHit, l1PivotHigh, l1PivotLow)
int  l1Back    = l1Fires ? anchorBarsBack(l1AnchorInput, l1SwingLengthInput) : 0

if l1Fires
    if na(l1Back) or l1Back + 1 > MAX_LOOKBACK or l1Back > bar_index
        // Disclosed, never silently clamped. The previous anchor is left in place
        // so the chart does not blank, and the label says what happened.
        l1BeyondBuffer := true
    else
        l1BeyondBuffer   := false
        l1AnchorIdx      := bar_index - l1Back
        l1AnchorTime     := time[l1Back]
        l1ConfirmIdx     := bar_index
        l1AnchorWeight   := nz(cumWeight[l1Back + 1], 0.0)
        l1AnchorPrice    := nz(l1CumPrice[l1Back + 1], 0.0)
        l1AnchorPriceSq  := nz(l1CumPriceSq[l1Back + 1], 0.0)
        l1AnchorBars     := nz(cumBars[l1Back + 1], 0.0)
        l1AnchorFallback := nz(cumFallbackBars[l1Back + 1], 0.0)

float l1WindowWeight   = cumWeight - l1AnchorWeight
float l1WindowPrice    = l1CumPrice - l1AnchorPrice
float l1WindowPriceSq  = l1CumPriceSq - l1AnchorPriceSq
float l1WindowBars     = cumBars - l1AnchorBars
float l1WindowFallback = cumFallbackBars - l1AnchorFallback
float l1Vwap           = l1EnabledInput ? avwapOf(l1WindowWeight, l1WindowPrice, referencePrice) : na
float l1Sigma          = l1EnabledInput ? sigmaOf(l1WindowWeight, l1WindowPrice, l1WindowPriceSq) : na
float l1HalfWidth      = halfWidthOf(l1Vwap, l1Sigma, bandAtr, l1WindowBars)

// What this layer's average was worth at the last bar of its PREVIOUS window.
//
// THE HISTORY READ IS UNCONDITIONAL AND THE ASSIGNMENT IS NOT. On the bar an anchor
// fires the accumulators have already been rebased, so `l1Vwap[1]` is the old window's
// last value. Reading it INSIDE the `if` would make `[1]` mean the previous bar THIS
// RAN ON rather than the previous bar.
float l1VwapPrev       = l1Vwap[1]
var float l1PriorVwap  = na
if l1Fires and not na(l1VwapPrev)
    l1PriorVwap := l1VwapPrev

// ─── Layer 2 resolution and value ───

var float l2AnchorWeight   = na
var float l2AnchorPrice    = na
var float l2AnchorPriceSq  = na
var float l2AnchorBars     = na
var float l2AnchorFallback = na
var int   l2AnchorIdx      = na
var int   l2AnchorTime     = na
var int   l2ConfirmIdx     = na
var bool  l2BeyondBuffer   = false

bool l2IsRetro = isRetroAnchor(l2AnchorInput)
bool l2Fires   = l2EnabledInput and anchorFires(l2AnchorInput, l2ManualHit, l2PivotHigh, l2PivotLow)
int  l2Back    = l2Fires ? anchorBarsBack(l2AnchorInput, l2SwingLengthInput) : 0

if l2Fires
    if na(l2Back) or l2Back + 1 > MAX_LOOKBACK or l2Back > bar_index
        l2BeyondBuffer := true
    else
        l2BeyondBuffer   := false
        l2AnchorIdx      := bar_index - l2Back
        l2AnchorTime     := time[l2Back]
        l2ConfirmIdx     := bar_index
        l2AnchorWeight   := nz(cumWeight[l2Back + 1], 0.0)
        l2AnchorPrice    := nz(l2CumPrice[l2Back + 1], 0.0)
        l2AnchorPriceSq  := nz(l2CumPriceSq[l2Back + 1], 0.0)
        l2AnchorBars     := nz(cumBars[l2Back + 1], 0.0)
        l2AnchorFallback := nz(cumFallbackBars[l2Back + 1], 0.0)

float l2WindowWeight   = cumWeight - l2AnchorWeight
float l2WindowPrice    = l2CumPrice - l2AnchorPrice
float l2WindowPriceSq  = l2CumPriceSq - l2AnchorPriceSq
float l2WindowBars     = cumBars - l2AnchorBars
float l2WindowFallback = cumFallbackBars - l2AnchorFallback
float l2Vwap           = l2EnabledInput ? avwapOf(l2WindowWeight, l2WindowPrice, referencePrice) : na
float l2Sigma          = l2EnabledInput ? sigmaOf(l2WindowWeight, l2WindowPrice, l2WindowPriceSq) : na
float l2HalfWidth      = halfWidthOf(l2Vwap, l2Sigma, bandAtr, l2WindowBars)
float l2VwapPrev       = l2Vwap[1]
var float l2PriorVwap  = na
if l2Fires and not na(l2VwapPrev)
    l2PriorVwap := l2VwapPrev

// ─── Layer 3 resolution and value ───

var float l3AnchorWeight   = na
var float l3AnchorPrice    = na
var float l3AnchorPriceSq  = na
var float l3AnchorBars     = na
var float l3AnchorFallback = na
var int   l3AnchorIdx      = na
var int   l3AnchorTime     = na
var int   l3ConfirmIdx     = na
var bool  l3BeyondBuffer   = false

bool l3IsRetro = isRetroAnchor(l3AnchorInput)
bool l3Fires   = l3EnabledInput and anchorFires(l3AnchorInput, l3ManualHit, l3PivotHigh, l3PivotLow)
int  l3Back    = l3Fires ? anchorBarsBack(l3AnchorInput, l3SwingLengthInput) : 0

if l3Fires
    if na(l3Back) or l3Back + 1 > MAX_LOOKBACK or l3Back > bar_index
        l3BeyondBuffer := true
    else
        l3BeyondBuffer   := false
        l3AnchorIdx      := bar_index - l3Back
        l3AnchorTime     := time[l3Back]
        l3ConfirmIdx     := bar_index
        l3AnchorWeight   := nz(cumWeight[l3Back + 1], 0.0)
        l3AnchorPrice    := nz(l3CumPrice[l3Back + 1], 0.0)
        l3AnchorPriceSq  := nz(l3CumPriceSq[l3Back + 1], 0.0)
        l3AnchorBars     := nz(cumBars[l3Back + 1], 0.0)
        l3AnchorFallback := nz(cumFallbackBars[l3Back + 1], 0.0)

float l3WindowWeight   = cumWeight - l3AnchorWeight
float l3WindowPrice    = l3CumPrice - l3AnchorPrice
float l3WindowPriceSq  = l3CumPriceSq - l3AnchorPriceSq
float l3WindowBars     = cumBars - l3AnchorBars
float l3WindowFallback = cumFallbackBars - l3AnchorFallback
float l3Vwap           = l3EnabledInput ? avwapOf(l3WindowWeight, l3WindowPrice, referencePrice) : na
float l3Sigma          = l3EnabledInput ? sigmaOf(l3WindowWeight, l3WindowPrice, l3WindowPriceSq) : na
float l3HalfWidth      = halfWidthOf(l3Vwap, l3Sigma, bandAtr, l3WindowBars)
float l3VwapPrev       = l3Vwap[1]
var float l3PriorVwap  = na
if l3Fires and not na(l3VwapPrev)
    l3PriorVwap := l3VwapPrev


// The nine multiples the bands are built from, resolved once — here rather than at each
// of the four places a multiple is read: the edge, the drawn path, the label and the
// alert. A preset reaching three of those four would put a line on the chart at 0.618
// and an alert naming the 1.0 band.

float l1Band1Mult = presetMultOf(l1PresetInput, 1, l1Band1MultInput)
float l1Band2Mult = presetMultOf(l1PresetInput, 2, l1Band2MultInput)
float l1Band3Mult = presetMultOf(l1PresetInput, 3, l1Band3MultInput)

float l2Band1Mult = presetMultOf(l2PresetInput, 1, l2Band1MultInput)
float l2Band2Mult = presetMultOf(l2PresetInput, 2, l2Band2MultInput)
float l2Band3Mult = presetMultOf(l2PresetInput, 3, l2Band3MultInput)

float l3Band1Mult = presetMultOf(l3PresetInput, 1, l3Band1MultInput)
float l3Band2Mult = presetMultOf(l3PresetInput, 2, l3Band2MultInput)
float l3Band3Mult = presetMultOf(l3PresetInput, 3, l3Band3MultInput)

// ─── Band edges ───
//
// Named series rather than expressions inlined into plot(), because the alert section
// needs each level's previous-bar value and Pine takes history of a named series, not of
// an arbitrary expression. These eighteen are the single point where the basis is used.
float l1Band1Upper = l1Band1OnInput ? l1Vwap + l1Band1Mult * l1HalfWidth : na
float l1Band1Lower = l1Band1OnInput ? l1Vwap - l1Band1Mult * l1HalfWidth : na
float l1Band2Upper = l1Band2OnInput ? l1Vwap + l1Band2Mult * l1HalfWidth : na
float l1Band2Lower = l1Band2OnInput ? l1Vwap - l1Band2Mult * l1HalfWidth : na
float l1Band3Upper = l1Band3OnInput ? l1Vwap + l1Band3Mult * l1HalfWidth : na
float l1Band3Lower = l1Band3OnInput ? l1Vwap - l1Band3Mult * l1HalfWidth : na

float l2Band1Upper = l2Band1OnInput ? l2Vwap + l2Band1Mult * l2HalfWidth : na
float l2Band1Lower = l2Band1OnInput ? l2Vwap - l2Band1Mult * l2HalfWidth : na
float l2Band2Upper = l2Band2OnInput ? l2Vwap + l2Band2Mult * l2HalfWidth : na
float l2Band2Lower = l2Band2OnInput ? l2Vwap - l2Band2Mult * l2HalfWidth : na
float l2Band3Upper = l2Band3OnInput ? l2Vwap + l2Band3Mult * l2HalfWidth : na
float l2Band3Lower = l2Band3OnInput ? l2Vwap - l2Band3Mult * l2HalfWidth : na

float l3Band1Upper = l3Band1OnInput ? l3Vwap + l3Band1Mult * l3HalfWidth : na
float l3Band1Lower = l3Band1OnInput ? l3Vwap - l3Band1Mult * l3HalfWidth : na
float l3Band2Upper = l3Band2OnInput ? l3Vwap + l3Band2Mult * l3HalfWidth : na
float l3Band2Lower = l3Band2OnInput ? l3Vwap - l3Band2Mult * l3HalfWidth : na
float l3Band3Upper = l3Band3OnInput ? l3Vwap + l3Band3Mult * l3HalfWidth : na
float l3Band3Lower = l3Band3OnInput ? l3Vwap - l3Band3Mult * l3HalfWidth : na

// ─── Curve colors, and the one trick 'Current window only' rests on ───
//
// The drawn path takes the real colors. The plotted path takes them too, unless 'Current
// window only' is on — then the plots go FULLY TRANSPARENT and the polylines carry the
// visible curve. Invisible rather than absent: a transparent plot still reports its
// value to the status line, the price scale and the Data Window, so the script keeps its
// readable state. Feeding the plots na would hide the same pixels and take that with it.
//
// EVERY COLOR HERE IS BUILT FROM INPUTS, AND THAT IS NOT FREE. A plot() is charged a
// SECOND plot count whenever its color is not a compile-time constant, so twenty-one
// user-colored curves cost forty-two counts, not twenty-one.

// ─── Which color each layer's bands are on ───
//
// The layer Color unless that layer's band override is on. FOUR surfaces read it and
// none may disagree: the band lines, the band fills, the retro path's band polylines,
// and the writing on the band labels. A fill still wearing the layer color while its own
// edge lines had moved would read as a rendering fault rather than as a setting.
//
// The VWAP line is deliberately not among the four — an override that repainted the
// average too would leave nothing to tell the two apart.
color l1BandBase     = l1BandColorOnInput ? l1BandColorInput : l1ColorInput
color l2BandBase     = l2BandColorOnInput ? l2BandColorInput : l2ColorInput
color l3BandBase     = l3BandColorOnInput ? l3BandColorInput : l3ColorInput

color l1BandColor    = color.new(l1BandBase, bandTranspInput)
color l2BandColor    = color.new(l2BandBase, bandTranspInput)
color l3BandColor    = color.new(l3BandBase, bandTranspInput)
color l1VwapPlotTone = currentWindowOnlyInput ? invisibleTone : l1ColorInput
color l2VwapPlotTone = currentWindowOnlyInput ? invisibleTone : l2ColorInput
color l3VwapPlotTone = currentWindowOnlyInput ? invisibleTone : l3ColorInput
color l1BandPlotTone = currentWindowOnlyInput ? invisibleTone : l1BandColor
color l2BandPlotTone = currentWindowOnlyInput ? invisibleTone : l2BandColor
color l3BandPlotTone = currentWindowOnlyInput ? invisibleTone : l3BandColor

// Invisible unless asked for, and unconditionally invisible under 'Current window only'.
// The input is greyed out in that mode, but a greyed input keeps whatever value it was
// left holding, so the mode is tested here rather than trusted to the dialog.
bool priorWanted = showPriorInput and not currentWindowOnlyInput

// ─── Which zones are filled ───
//
// A fill() is charged a plot count when its color is series-form, and an input-derived
// color counts: all fifteen of these cost one each, as do the three confluence fills.
//
// A zone whose band is switched off needs no test — that band's edge series is already
// na, and fill() bridges nothing across na unless asked to.
bool fillWantsBand1 = fillBand1Input and not currentWindowOnlyInput
bool fillWants1To2  = fill1To2Input and not currentWindowOnlyInput
bool fillWants2To3  = fill2To3Input and not currentWindowOnlyInput

// Built from the band base rather than the layer color: these zones are bounded by band
// lines, so they follow the bands when those are given a color of their own.
color l1FillBand1 = fillWantsBand1 ? color.new(l1BandBase, fillTranspInput) : invisibleTone
color l2FillBand1 = fillWantsBand1 ? color.new(l2BandBase, fillTranspInput) : invisibleTone
color l3FillBand1 = fillWantsBand1 ? color.new(l3BandBase, fillTranspInput) : invisibleTone
color l1Fill1To2  = fillWants1To2 ? color.new(l1BandBase, fillTranspInput) : invisibleTone
color l2Fill1To2  = fillWants1To2 ? color.new(l2BandBase, fillTranspInput) : invisibleTone
color l3Fill1To2  = fillWants1To2 ? color.new(l3BandBase, fillTranspInput) : invisibleTone
color l1Fill2To3  = fillWants2To3 ? color.new(l1BandBase, fillTranspInput) : invisibleTone
color l2Fill2To3  = fillWants2To3 ? color.new(l2BandBase, fillTranspInput) : invisibleTone
color l3Fill2To3  = fillWants2To3 ? color.new(l3BandBase, fillTranspInput) : invisibleTone

// ─── Cross-layer confluence ───
//
// Where two enabled layers' anchored averages sit within a tolerance of each other.
// Descriptive arithmetic about two observed numbers: it states that they are close, and
// makes no claim about what follows.
//
// The tolerance is converted to price units once per PAIR rather than once for the
// chart, because Percent needs the pair's own midpoint as its denominator. Ticks, Points
// and Currency return the same figure for all three pairs; Percent does not, and that is
// correct — two averages near $600 and two near $60 are not the same distance apart for
// being the same number of cents apart.
//
// The comparison stays `<=` and is never an equality test. A gap that came back na —
// which Currency does on a feed reporting no point value — shades nothing.
bool confluenceWanted = showConfluenceInput and not currentWindowOnlyInput
float gap1To2 = confluenceGapOf(l1Vwap, l2Vwap)
float gap1To3 = confluenceGapOf(l1Vwap, l3Vwap)
float gap2To3 = confluenceGapOf(l2Vwap, l3Vwap)
bool near1To2 = confluenceWanted and l1EnabledInput and l2EnabledInput and
     not na(l1Vwap) and not na(l2Vwap) and not na(gap1To2) and math.abs(l1Vwap - l2Vwap) <= gap1To2
bool near1To3 = confluenceWanted and l1EnabledInput and l3EnabledInput and
     not na(l1Vwap) and not na(l3Vwap) and not na(gap1To3) and math.abs(l1Vwap - l3Vwap) <= gap1To3
bool near2To3 = confluenceWanted and l2EnabledInput and l3EnabledInput and
     not na(l2Vwap) and not na(l3Vwap) and not na(gap2To3) and math.abs(l2Vwap - l3Vwap) <= gap2To3
color conf1To2 = near1To2 ? confluenceColorInput : invisibleTone
color conf1To3 = near1To3 ? confluenceColorInput : invisibleTone
color conf2To3 = near2To3 ? confluenceColorInput : invisibleTone


// ═══════════════════════════════════════════════════════════════════════════════
// Visuals
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Plots ───
//
// Twenty-one plot() calls, declared unconditionally and always — including for retro
// layers and under 'Current window only' — so every value is readable on every bar its
// anchor is known for. Do not collapse this into a drawing-only design, and do not
// "optimise" the transparent mode into feeding na.
//
// Every plot is scoped to `display.pane + display.data_window`. `.pane` is what keeps
// the line on the chart: `display` governs where a plot APPEARS, not only where its
// value is printed, so `display.data_window` alone would delete all 21 curves and still
// compile. `.status_line` and `.price_scale` are deliberately absent, so the status line
// carries the indicator's name rather than 21 values.
//
// ─── The plot-count budget ───
//
//     21 plot() x 2 (each carries a non-constant color)   = 42
//     18 fill()  x 1 (input-derived colors are charged)   = 18
//                                                           ---
//                                                            60 of 64
//
// A plot() is charged once for the series it draws and again for every parameter fed
// something that is not a compile-time constant, so the true unit of cost is TWO counts
// per curve. Headroom is four counts: two more user-colored curves, or four more fills.
// Exceeding the cap is a RUNTIME error — the script compiles and then refuses to run.
//
// hline(), line.new(), label.new(), table.new() and box.new() generate no plot count,
// which is why the three prior-window levels below are line.new() and not plots.

// Every plot keeps its ID. fill() takes plot IDs, so shading the gap between two
// layers' averages needs both of them named.

l1VwapPlot = plot(l1Vwap, "L1 VWAP", color = l1VwapPlotTone, linewidth = vwapWidthInput,
     style = vwapPlotStyle, linestyle = vwapDashStyle,
     display = display.pane + display.data_window)
l1Band1UpperPlot = plot(l1Band1Upper, "L1 B1 Upper", color = l1BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l1Band1LowerPlot = plot(l1Band1Lower, "L1 B1 Lower", color = l1BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l1Band2UpperPlot = plot(l1Band2Upper, "L1 B2 Upper", color = l1BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l1Band2LowerPlot = plot(l1Band2Lower, "L1 B2 Lower", color = l1BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l1Band3UpperPlot = plot(l1Band3Upper, "L1 B3 Upper", color = l1BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l1Band3LowerPlot = plot(l1Band3Lower, "L1 B3 Lower", color = l1BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)

l2VwapPlot = plot(l2Vwap, "L2 VWAP", color = l2VwapPlotTone, linewidth = vwapWidthInput,
     style = vwapPlotStyle, linestyle = vwapDashStyle,
     display = display.pane + display.data_window)
l2Band1UpperPlot = plot(l2Band1Upper, "L2 B1 Upper", color = l2BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l2Band1LowerPlot = plot(l2Band1Lower, "L2 B1 Lower", color = l2BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l2Band2UpperPlot = plot(l2Band2Upper, "L2 B2 Upper", color = l2BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l2Band2LowerPlot = plot(l2Band2Lower, "L2 B2 Lower", color = l2BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l2Band3UpperPlot = plot(l2Band3Upper, "L2 B3 Upper", color = l2BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l2Band3LowerPlot = plot(l2Band3Lower, "L2 B3 Lower", color = l2BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)

l3VwapPlot = plot(l3Vwap, "L3 VWAP", color = l3VwapPlotTone, linewidth = vwapWidthInput,
     style = vwapPlotStyle, linestyle = vwapDashStyle,
     display = display.pane + display.data_window)
l3Band1UpperPlot = plot(l3Band1Upper, "L3 B1 Upper", color = l3BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l3Band1LowerPlot = plot(l3Band1Lower, "L3 B1 Lower", color = l3BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l3Band2UpperPlot = plot(l3Band2Upper, "L3 B2 Upper", color = l3BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l3Band2LowerPlot = plot(l3Band2Lower, "L3 B2 Lower", color = l3BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l3Band3UpperPlot = plot(l3Band3Upper, "L3 B3 Upper", color = l3BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)
l3Band3LowerPlot = plot(l3Band3Lower, "L3 B3 Lower", color = l3BandPlotTone,
     linewidth = bandWidthInput, style = bandPlotStyle, linestyle = bandDashStyle,
     display = display.pane + display.data_window)

// ─── Fills ───
//
// Written out per layer rather than looped: fill() takes plot IDs, which no loop can
// produce.

fill(l1Band1UpperPlot, l1Band1LowerPlot, color = l1FillBand1, title = "L1 band 1 zone")
fill(l1Band1UpperPlot, l1Band2UpperPlot, color = l1Fill1To2, title = "L1 band 1 to 2 upper")
fill(l1Band1LowerPlot, l1Band2LowerPlot, color = l1Fill1To2, title = "L1 band 1 to 2 lower")
fill(l1Band2UpperPlot, l1Band3UpperPlot, color = l1Fill2To3, title = "L1 band 2 to 3 upper")
fill(l1Band2LowerPlot, l1Band3LowerPlot, color = l1Fill2To3, title = "L1 band 2 to 3 lower")

fill(l2Band1UpperPlot, l2Band1LowerPlot, color = l2FillBand1, title = "L2 band 1 zone")
fill(l2Band1UpperPlot, l2Band2UpperPlot, color = l2Fill1To2, title = "L2 band 1 to 2 upper")
fill(l2Band1LowerPlot, l2Band2LowerPlot, color = l2Fill1To2, title = "L2 band 1 to 2 lower")
fill(l2Band2UpperPlot, l2Band3UpperPlot, color = l2Fill2To3, title = "L2 band 2 to 3 upper")
fill(l2Band2LowerPlot, l2Band3LowerPlot, color = l2Fill2To3, title = "L2 band 2 to 3 lower")

fill(l3Band1UpperPlot, l3Band1LowerPlot, color = l3FillBand1, title = "L3 band 1 zone")
fill(l3Band1UpperPlot, l3Band2UpperPlot, color = l3Fill1To2, title = "L3 band 1 to 2 upper")
fill(l3Band1LowerPlot, l3Band2LowerPlot, color = l3Fill1To2, title = "L3 band 1 to 2 lower")
fill(l3Band2UpperPlot, l3Band3UpperPlot, color = l3Fill2To3, title = "L3 band 2 to 3 upper")
fill(l3Band2LowerPlot, l3Band3LowerPlot, color = l3Fill2To3, title = "L3 band 2 to 3 lower")

// Between VWAP plots rather than band plots: the statement is that the AVERAGES agree,
// and two wide bands can overlap while their averages are far apart.
fill(l1VwapPlot, l2VwapPlot, color = conf1To2, title = "L1 to L2 confluence")
fill(l1VwapPlot, l3VwapPlot, color = conf1To3, title = "L1 to L3 confluence")
fill(l2VwapPlot, l3VwapPlot, color = conf2To3, title = "L2 to L3 confluence")

// ─── Prior-window levels ───
//
// Created on the first bar and repositioned in place afterwards.
var line l1PriorLine = line.new(0, 0.0, 0, 0.0, xloc = xloc.bar_index,
     style = line.style_dotted, color = invisibleTone)
var line l2PriorLine = line.new(0, 0.0, 0, 0.0, xloc = xloc.bar_index,
     style = line.style_dotted, color = invisibleTone)
var line l3PriorLine = line.new(0, 0.0, 0, 0.0, xloc = xloc.bar_index,
     style = line.style_dotted, color = invisibleTone)

drawPriorLevel(l1PriorLine, priorWanted, l1AnchorIdx, l1PriorVwap, l1BandColor, bandWidthInput)
drawPriorLevel(l2PriorLine, priorWanted, l2AnchorIdx, l2PriorVwap, l2BandColor, bandWidthInput)
drawPriorLevel(l3PriorLine, priorWanted, l3AnchorIdx, l3PriorVwap, l3BandColor, bandWidthInput)

// ─── Retro segment rendering ───

// Deleted explicitly rather than left to the garbage collector: the default polyline
// allowance is about 50, lower than the 100 this script declares, and a budget that
// depends on which of the two is in force is not understood. At most 21 exist at once.
//
// This may stay inside a conditional because it calls only built-ins holding no per-call
// history. The three calls below hold history in their parameters and so sit at global
// scope, taking barstate.islast as an argument instead.
if barstate.islast and array.size(retroPolylines) > 0
    for i = 0 to array.size(retroPolylines) - 1
        polyline.delete(array.get(retroPolylines, i))
    array.clear(retroPolylines)

// Under 'Current window only' every enabled layer wants its whole current window and the
// segment ends at the last bar; otherwise only a retro layer wants anything, and its
// segment ends at the bar that confirmed the anchor.
bool l1SegWanted = currentWindowOnlyInput or l1IsRetro
bool l2SegWanted = currentWindowOnlyInput or l2IsRetro
bool l3SegWanted = currentWindowOnlyInput or l3IsRetro
int  l1SegEnd    = currentWindowOnlyInput ? bar_index : l1ConfirmIdx
int  l2SegEnd    = currentWindowOnlyInput ? bar_index : l2ConfirmIdx
int  l3SegEnd    = currentWindowOnlyInput ? bar_index : l3ConfirmIdx

// A window longer than the draw depth is CLIPPED, which looks like a curve starting in
// mid-air. Detected here so the layer's label can say it happened.
//
// Asked with the SAME two functions the draw clamps itself with, and given each layer's
// own segment end rather than the current bar — measuring from bar_index instead makes a
// clipped retro back-fill undetectable by construction.
bool l1Clipped = drawableSegment(l1EnabledInput, l1SegWanted, l1AnchorIdx, l1SegEnd) and
     segStartOf(l1AnchorIdx, l1SegEnd, retroDepthInput) != l1AnchorIdx
bool l2Clipped = drawableSegment(l2EnabledInput, l2SegWanted, l2AnchorIdx, l2SegEnd) and
     segStartOf(l2AnchorIdx, l2SegEnd, retroDepthInput) != l2AnchorIdx
bool l3Clipped = drawableSegment(l3EnabledInput, l3SegWanted, l3AnchorIdx, l3SegEnd) and
     segStartOf(l3AnchorIdx, l3SegEnd, retroDepthInput) != l3AnchorIdx

bool l1ReachFailed = drawSegment(barstate.islast, l1EnabledInput, l1SegWanted, l1AnchorIdx, l1SegEnd,
     l1AnchorWeight, l1AnchorPrice, l1AnchorPriceSq, l1AnchorBars, l1CumPrice,
     l1CumPriceSq, l1ColorInput, l1BandColor,
     l1Band1OnInput, l1Band1Mult, l1Band2OnInput, l1Band2Mult, l1Band3OnInput, l1Band3Mult,
     retroDepthInput)
bool l2ReachFailed = drawSegment(barstate.islast, l2EnabledInput, l2SegWanted, l2AnchorIdx, l2SegEnd,
     l2AnchorWeight, l2AnchorPrice, l2AnchorPriceSq, l2AnchorBars, l2CumPrice,
     l2CumPriceSq, l2ColorInput, l2BandColor,
     l2Band1OnInput, l2Band1Mult, l2Band2OnInput, l2Band2Mult, l2Band3OnInput, l2Band3Mult,
     retroDepthInput)
bool l3ReachFailed = drawSegment(barstate.islast, l3EnabledInput, l3SegWanted, l3AnchorIdx, l3SegEnd,
     l3AnchorWeight, l3AnchorPrice, l3AnchorPriceSq, l3AnchorBars, l3CumPrice,
     l3CumPriceSq, l3ColorInput, l3BandColor,
     l3Band1OnInput, l3Band1Mult, l3Band2OnInput, l3Band2Mult, l3Band3OnInput, l3Band3Mult,
     retroDepthInput)

// ─── Disclosure notes, one per layer ───
//
// Four things nothing else on the chart carries: how this anchor is behaving, whether the
// average is actually volume-weighted, which bars the filter let in, and whether a curve
// was clipped or left undrawn. Each line reads one layer and no other.
string l1Note = layerNote(l1AnchorInput, l1IsRetro, l1BeyondBuffer, sessionAnchorDegenerate,
     l1WindowBars, l1WindowFallback, l1ReachFailed, l1Clipped)
string l2Note = layerNote(l2AnchorInput, l2IsRetro, l2BeyondBuffer, sessionAnchorDegenerate,
     l2WindowBars, l2WindowFallback, l2ReachFailed, l2Clipped)
string l3Note = layerNote(l3AnchorInput, l3IsRetro, l3BeyondBuffer, sessionAnchorDegenerate,
     l3WindowBars, l3WindowFallback, l3ReachFailed, l3Clipped)

// ─── Line labels ───
//
// One call per layer rather than one loop with a layer index: the loop version needs
// three-deep nested ternaries to pick each band's switch, edge and multiple.

if barstate.islast
    if array.size(curveLabels) > 0
        for i = 0 to array.size(curveLabels) - 1
            label.delete(array.get(curveLabels, i))
        array.clear(curveLabels)

labelLayer(barstate.islast, l1EnabledInput, "L1", formatBarTime(l1AnchorTime), l1Note, l1Vwap, l1PriorVwap,
     l1ColorInput, l1BandBase, l1VwapTextInput, l1BandTextInput, l1OverrideInput,
     l1Band1OnInput, l1Band1Mult, l1Band1Upper, l1Band1Lower,
     l1Band2OnInput, l1Band2Mult, l1Band2Upper, l1Band2Lower,
     l1Band3OnInput, l1Band3Mult, l1Band3Upper, l1Band3Lower)
labelLayer(barstate.islast, l2EnabledInput, "L2", formatBarTime(l2AnchorTime), l2Note, l2Vwap, l2PriorVwap,
     l2ColorInput, l2BandBase, l2VwapTextInput, l2BandTextInput, l2OverrideInput,
     l2Band1OnInput, l2Band1Mult, l2Band1Upper, l2Band1Lower,
     l2Band2OnInput, l2Band2Mult, l2Band2Upper, l2Band2Lower,
     l2Band3OnInput, l2Band3Mult, l2Band3Upper, l2Band3Lower)
labelLayer(barstate.islast, l3EnabledInput, "L3", formatBarTime(l3AnchorTime), l3Note, l3Vwap, l3PriorVwap,
     l3ColorInput, l3BandBase, l3VwapTextInput, l3BandTextInput, l3OverrideInput,
     l3Band1OnInput, l3Band1Mult, l3Band1Upper, l3Band1Lower,
     l3Band2OnInput, l3Band2Mult, l3Band2Upper, l3Band2Lower,
     l3Band3OnInput, l3Band3Mult, l3Band3Upper, l3Band3Lower)

// ═══════════════════════════════════════════════════════════════════════════════
// Alerts
// ═══════════════════════════════════════════════════════════════════════════════
//
// One dynamic alert() call carrying a composed message that names the layer, its anchor,
// and what was crossed. alert() may sit inside a conditional block, unlike
// alertcondition(), which is why one call serves all three layers.
//
// freq IS PASSED EXPLICITLY. The default is alert.freq_once_per_bar, which fires on the
// first call within a realtime bar — before that bar closes. Accepting the default would
// fire on an unconfirmed value.
//
// Alerts trigger only on realtime bars, so no alert may be cited as evidence of a
// historical event.

bool alertWantsVwap = alertModeInput == ALERT_VWAP or alertModeInput == ALERT_BOTH
bool alertWantsBand = alertModeInput == ALERT_BAND or alertModeInput == ALERT_BOTH

// Read once, here, on every bar. The crossing tests below run inside conditional blocks;
// taking this history there would take it on only the bars those conditions were true
// on. See crossedLevel().
float previousClose = close[1]

string l1Cross = ""
if l1EnabledInput and alertModeInput != ALERT_OFF
    if alertWantsVwap
        l1Cross := crossPhrase(l1Vwap, l1Vwap[1], previousClose, "the VWAP")
    if l1Cross == "" and alertWantsBand and l1Band1OnInput
        l1Cross := crossPhrase(l1Band1Upper, l1Band1Upper[1], previousClose, bandName(l1Band1Mult, true))
    if l1Cross == "" and alertWantsBand and l1Band1OnInput
        l1Cross := crossPhrase(l1Band1Lower, l1Band1Lower[1], previousClose, bandName(l1Band1Mult,
             false))
    if l1Cross == "" and alertWantsBand and l1Band2OnInput
        l1Cross := crossPhrase(l1Band2Upper, l1Band2Upper[1], previousClose, bandName(l1Band2Mult, true))
    if l1Cross == "" and alertWantsBand and l1Band2OnInput
        l1Cross := crossPhrase(l1Band2Lower, l1Band2Lower[1], previousClose, bandName(l1Band2Mult,
             false))
    if l1Cross == "" and alertWantsBand and l1Band3OnInput
        l1Cross := crossPhrase(l1Band3Upper, l1Band3Upper[1], previousClose, bandName(l1Band3Mult, true))
    if l1Cross == "" and alertWantsBand and l1Band3OnInput
        l1Cross := crossPhrase(l1Band3Lower, l1Band3Lower[1], previousClose, bandName(l1Band3Mult,
             false))

string l2Cross = ""
if l2EnabledInput and alertModeInput != ALERT_OFF
    if alertWantsVwap
        l2Cross := crossPhrase(l2Vwap, l2Vwap[1], previousClose, "the VWAP")
    if l2Cross == "" and alertWantsBand and l2Band1OnInput
        l2Cross := crossPhrase(l2Band1Upper, l2Band1Upper[1], previousClose, bandName(l2Band1Mult, true))
    if l2Cross == "" and alertWantsBand and l2Band1OnInput
        l2Cross := crossPhrase(l2Band1Lower, l2Band1Lower[1], previousClose, bandName(l2Band1Mult,
             false))
    if l2Cross == "" and alertWantsBand and l2Band2OnInput
        l2Cross := crossPhrase(l2Band2Upper, l2Band2Upper[1], previousClose, bandName(l2Band2Mult, true))
    if l2Cross == "" and alertWantsBand and l2Band2OnInput
        l2Cross := crossPhrase(l2Band2Lower, l2Band2Lower[1], previousClose, bandName(l2Band2Mult,
             false))
    if l2Cross == "" and alertWantsBand and l2Band3OnInput
        l2Cross := crossPhrase(l2Band3Upper, l2Band3Upper[1], previousClose, bandName(l2Band3Mult, true))
    if l2Cross == "" and alertWantsBand and l2Band3OnInput
        l2Cross := crossPhrase(l2Band3Lower, l2Band3Lower[1], previousClose, bandName(l2Band3Mult,
             false))

string l3Cross = ""
if l3EnabledInput and alertModeInput != ALERT_OFF
    if alertWantsVwap
        l3Cross := crossPhrase(l3Vwap, l3Vwap[1], previousClose, "the VWAP")
    if l3Cross == "" and alertWantsBand and l3Band1OnInput
        l3Cross := crossPhrase(l3Band1Upper, l3Band1Upper[1], previousClose, bandName(l3Band1Mult, true))
    if l3Cross == "" and alertWantsBand and l3Band1OnInput
        l3Cross := crossPhrase(l3Band1Lower, l3Band1Lower[1], previousClose, bandName(l3Band1Mult,
             false))
    if l3Cross == "" and alertWantsBand and l3Band2OnInput
        l3Cross := crossPhrase(l3Band2Upper, l3Band2Upper[1], previousClose, bandName(l3Band2Mult, true))
    if l3Cross == "" and alertWantsBand and l3Band2OnInput
        l3Cross := crossPhrase(l3Band2Lower, l3Band2Lower[1], previousClose, bandName(l3Band2Mult,
             false))
    if l3Cross == "" and alertWantsBand and l3Band3OnInput
        l3Cross := crossPhrase(l3Band3Upper, l3Band3Upper[1], previousClose, bandName(l3Band3Mult, true))
    if l3Cross == "" and alertWantsBand and l3Band3OnInput
        l3Cross := crossPhrase(l3Band3Lower, l3Band3Lower[1], previousClose, bandName(l3Band3Mult,
             false))

if alertModeInput != ALERT_OFF
    string alertText = ""
    if l1Cross != ""
        alertText := syminfo.ticker + " " + timeframe.period + ": Layer 1 (" + l1AnchorInput + ", anchored " +
         formatBarTime(l1AnchorTime) + ") - price " + l1Cross + "."
    else if l2Cross != ""
        alertText := syminfo.ticker + " " + timeframe.period + ": Layer 2 (" + l2AnchorInput + ", anchored " +
         formatBarTime(l2AnchorTime) + ") - price " + l2Cross + "."
    else if l3Cross != ""
        alertText := syminfo.ticker + " " + timeframe.period + ": Layer 3 (" + l3AnchorInput + ", anchored " +
         formatBarTime(l3AnchorTime) + ") - price " + l3Cross + "."
    if alertText != ""
        alert(alertText, alert.freq_once_per_bar_close)
````
