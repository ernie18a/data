# HTF Power of Three Pro

- url: https://www.tradingview.com/script/dWeooXlh-HTF-Power-of-Three-Pro/
- type: indicator
- pine_id: PUB;7fbccb838a8f4fbbb7902455fc7a98ea
- version: 1.0

## Description

[b]HTF Power of Three Pro[/b]

[b]Overview[/b]

Power of Three (PO3) is a Smart Money Concepts framework developed by ICT / Inner Circle Trader. It models every higher-timeframe candle as a three-stage institutional campaign: [i]Accumulation[/i] (price consolidates near the open), [i]Manipulation[/i] (a liquidity sweep in one direction), and [i]Distribution[/i] (expansion and close in the opposite direction). Recognising this structure on higher timeframes gives traders a narrative for where price has been and where it is likely to go within the current candle.

This indicator renders the HTF PO3 candle directly on your lower-timeframe chart as a body box with full wicks, a live countdown timer, and a projection panel to the right of price. Beyond the basic candle, it integrates real footprint delta data from `request.footprint()` to flag whether the net order flow inside each candle supports its directional move — separating candles with genuine institutional conviction from those that closed in a direction without confirming buy or sell pressure.

[b]How It Works[/b]

The indicator requests OHLC and time data from a user-selected higher timeframe using `request.security()` with `lookahead_on` so the open is always known at the start of each HTF candle. On each lower-timeframe bar, it accumulates the running high, low, close, and footprint delta. When the HTF candle closes, the completed candle is drawn as a body box with wick lines and a delta label. A live box redraws on every tick to show the in-progress candle.

For footprint data, each lower-timeframe bar requests a `footprint` object via `request.footprint()`. The indicator sums all row deltas to obtain the bar's net delta, then classifies each bar as belonging to the lower or upper half of the current HTF range based on bar midpoint vs. HTF midpoint:

[pine]
footprint fp = request.footprint(i_fpTicks, i_fpVa, i_fpImb)
float barDelta = na
float barLHD   = na   // lower-half delta accumulator
float barUHD   = na   // upper-half delta accumulator

if not na(fp)
    array<volume_row> rows = fp.rows()
    float totalD = 0.0
    for row in rows
        totalD += row.delta()
    barDelta := totalD
    htfMid = (htfH + htfL) / 2.0
    barMid = (high  + low)  / 2.0
    if barMid < htfMid
        barLHD := totalD
        barUHD := 0.0
    else
        barLHD := 0.0
        barUHD := totalD
[/pine]

At the end of each HTF candle, the indicator tests for [i]Volume Concentration Conviction[/i]: for a bullish candle, the indicator checks whether a configurable percentage of delta came from bars in the lower half of the range (smart money accumulating below before distributing up). For a bearish candle, it checks whether the majority of sell delta came from the upper half. Candles that pass this test receive a glow halo and a highlighted border, and their delta label is stamped with a concentration percentage badge.

[b]Colour Coding[/b]

[list]
[*][b]Body box — bullish[/b]: configurable fill (default semi-transparent green) with grey border.
[*][b]Body box — bearish[/b]: configurable fill (default semi-transparent red) with black border.
[*][b]Conviction highlight — bull[/b]: cyan glow halo and border (default #00e5ff) indicating buy delta concentrated in the lower half of range.
[*][b]Conviction highlight — bear[/b]: amber glow halo and border (default #ff9800) indicating sell delta concentrated in the upper half of range.
[*][b]Delta label — positive[/b]: lime green text showing net buy delta.
[*][b]Delta label — negative[/b]: red text showing net sell delta.
[*][b]Macro windows[/b]: yellow fill boxes marking 20-minute ICT macro windows around hourly pivots (EST).
[*][b]Session boxes[/b]: user-defined colour fills for up to three intraday sessions.
[/list]

[b]Inputs[/b]

[b]PO3 Settings[/b]

[list=1]
[*][b]Timeframe[/b] — the higher timeframe whose candle the indicator models. Must be strictly above the chart timeframe; a runtime error fires otherwise. Default: 180 (3-hour).
[*][b]Use NY Midnight[/b] — replaces the regular session open with the 00:00 EST candle open for Daily and Weekly timeframes, aligning with ICT's NY Midnight concept. Default: off.
[/list]

[b]HTF PO3 Appearance[/b]

[list=1]
[*][b]Body (Bull / Bear)[/b] — fill colours for bullish and bearish HTF candle bodies. Default: semi-transparent green / red.
[*][b]Border (Bull / Bear)[/b] — border colours for the body box. Default: grey / black.
[*][b]Wick (Bull / Bear)[/b] — wick line colours. Default: semi-transparent grey for both.
[/list]

[b]Projection Panel[/b]

[list=1]
[*][b]Show Projection Panel[/b] — toggles the mini-panel drawn to the right of the last bar showing the live candle alongside recent closed candles. Default: on.
[*][b]Candles to Show[/b] — number of historical HTF candles to display in the panel, not counting the live candle. Range: 1–10. Default: 3.
[*][b]Right Offset (Bars)[/b] — gap in bars between the last chart bar and the left edge of the panel. Increase this if labels overlap price. Default: 15.
[*][b]Candle Width[/b] — width in bars of each panel candle slot. Range: 2–30. Default: 6.
[*][b]Gap[/b] — spacing in bars between candle slots. Range: 1–30. Default: 10.
[*][b]Show OHLC Labels[/b] — prints O/H/L/C price labels to the right of each panel candle. Default: on.
[*][b]Show Delta Labels[/b] — prints the net delta below each panel candle, with a conviction badge where applicable. Default: on.
[/list]

[b]LTF Projections (Live PO3)[/b]

[list=1]
[*][b]OHLC Price[/b] — shows O/H/L/C price labels beside the live HTF candle on the main chart. Toggle and colour configurable. Default: on, silver.
[*][b]Mode[/b] — switches OHLC labels between absolute price and percentage of the current HTF range. "% Range" is useful on instruments with large nominal prices. Default: Normal.
[*][b]Open Line[/b] — draws a dashed line at the HTF open price extending 50 bars to the right. Toggle, colour, and width configurable. Default: on, grey, width 1.
[*][b]L/H Lines[/b] — draws dashed lines at the running HTF high and low extending to the right. Toggle, colour, and width configurable. Default: on, teal, width 1.
[*][b]Label & Text Size[/b] — governs the size of all labels and table text. Options: Auto, Tiny, Small, Normal, Large, Huge. Default: Small.
[/list]

[b]LTF Projections (Previous PO3)[/b]

[list=1]
[*][b]Show Previous PO3[/b] — draws the prior HTF candle's open, high, low, and equilibrium (midpoint) as persistent lines across the chart. Default: on.
[*][b]Prev Open Style / Colour / Width[/b] — line style, colour, and width for the previous candle's open level. Default: Dashed, orange, width 1.
[*][b]Prev H/L Style / Colour / Width[/b] — line style, colour, and width for the previous candle's high and low. Default: Dashed, yellow, width 1.
[*][b]Prev EQ Style / Colour / Width[/b] — line style, colour, and width for the previous candle's equilibrium (50% level). Default: Dotted, semi-transparent white, width 1.
[*][b]Extend Previous Opens[/b] — projects the open price of up to 10 past HTF candles as faded dotted lines across the chart, useful for identifying historical open-price magnets. Default: off.
[/list]

[b]Dealing Range[/b]

[list=1]
[*][b]Show Dealing Range[/b] — draws the four premium/discount quadrant levels of the live HTF candle: High, Q3 (75%), EQ (50%), Q1 (25%), Low. Default: off.
[*][b]H/L Style / Colour / Width[/b] — appearance of the High and Low boundary lines. Default: Solid, white, width 1.
[*][b]EQ Style / Colour / Width[/b] — appearance of the 50% equilibrium line. Default: Dashed, semi-transparent white, width 1.
[*][b]Q1/Q3 Style / Colour / Width[/b] — appearance of the 25% and 75% quartile lines. Default: Dotted, semi-transparent grey, width 1.
[*][b]Show Level Labels[/b] — annotates each dealing range line with its name (DR High, Q3 75%, etc.). Default: on.
[/list]

[b]Weekly Profile[/b]

[list=1]
[*][b]Show Weekly Profile[/b] — when the HTF timeframe is set to W, draws individual daily candle body boxes inside the weekly range, coloured by day of week. Best used alongside a Weekly timeframe setting. Default: off.
[*][b]Mon / Tue / Wed / Thu / Fri[/b] — fill colours for each day's body box in the weekly profile. Defaults: blue, purple, orange, teal, red (all semi-transparent).
[/list]

[b]Time & Price[/b]

[list=1]
[*][b]Mode[/b] — selects the time-and-price overlay. [i]Off[/i]: no overlay. [i]Macros[/i]: draws 8 ICT 20-minute macro windows around hourly EST pivots as coloured boxes. [i]Session[/i]: draws up to 3 user-defined intraday sessions as coloured boxes. [i]Day of Week[/i]: groups weekdays into two PO3-style candles (Group A: Mon–N, Group B: remaining days). Default: Off.
[*][b]Macro Color / Border[/b] — fill and border colours for ICT macro window boxes. Default: semi-transparent yellow fill, solid yellow border.
[*][b]Session 1 / 2 / 3[/b] — enable toggle, start time (HH:MM, 24h, exchange timezone), end time, and fill colour for each session. Sessions may cross midnight. Defaults: Session 1 08:30–12:00 blue; Session 2 12:00–16:00 green; Session 3 disabled.
[*][b]Group A: Days 1–N[/b] — the number of weekdays (counting from Monday) that form Group A in Day of Week mode. Range: 1–4. For example, 4 groups Mon–Thu together; Friday becomes Group B alone. Default: 4.
[*][b]Group A / Group B Colour[/b] — fill colours for the two day-of-week candle groups. Default: blue / red (semi-transparent).
[/list]

[b]Footprint Delta[/b]

[list=1]
[*][b]HTF Delta Labels[/b] — prints net delta text below each completed HTF candle drawn on the main chart. Default: on.
[*][b]Live Delta Label[/b] — prints the running net delta below the live HTF candle, updating on every tick. Default: on.
[*][b]Ticks per Row[/b] — the price range of each footprint row passed to `request.footprint()`. Smaller values (e.g. 1–2) produce finer row granularity; larger values (e.g. 10+) produce coarser rows and faster execution. Match this to your instrument's typical tick structure. Default: 4.
[*][b]VA Percent[/b] — the Value Area percentage passed to `request.footprint()` for POC/VA calculations. Range: 1–100. Default: 70.
[*][b]Imbalance %[/b] — the ask/bid ratio threshold passed to `request.footprint()` for identifying imbalanced rows. Default: 300.
[*][b]Positive / Negative Delta Colour[/b] — text colours for positive and negative delta labels. Default: lime / red.
[/list]

[b]Volume Concentration[/b]

[list=1]
[*][b]Show Conviction Highlight[/b] — enables the glow halo and border highlight on candles where delta is concentrated in the directionally correct half of the HTF range. Disable to suppress all conviction visuals without changing other settings. Default: on.
[*][b]Concentration Threshold %[/b] — the minimum percentage of total half-range delta that must come from the conviction zone to qualify a candle. At 51% any slight lean qualifies; at 80%+ only strongly concentrated candles qualify. Range: 51–100. Default: 60.
[*][b]Bull Conviction / Bear Conviction Colour[/b] — glow and border colours for bullish and bearish conviction candles. Default: cyan (#00e5ff) / amber (#ff9800).
[*][b]Highlight Border Width[/b] — border width of the conviction glow box and body border. Range: 1–4. Default: 2.
[/list]

[b]PO3 Info Table[/b]

[list=1]
[*][b]Range[/b] — sets whether the range row in the info table displays as a price difference or as a tick count. Default: Price.
[*][b]Position[/b] — vertical (top / middle / bottom) and horizontal (left / center / right) position of the info table. Default: middle right.
[*][b]Label / Text Colour[/b] — background colour for label cells and text colour for value cells. Default: semi-transparent grey labels, white text.
[/list]

[b]Usage Notes[/b]

[list]
[*]Set the timeframe to one step above your trading chart. On a 15-minute chart, a 3-hour or 4-hour HTF candle gives you the PO3 campaign context most traders use for intraday bias.
[*]Use the conviction highlight to filter entries. A bullish HTF candle with a cyan glow means buy delta was concentrated in the lower range half — consistent with institutional accumulation. A candle that closes bullish without conviction may be a manipulation leg rather than a genuine distribution.
[*]The Dealing Range levels (H, Q3, EQ, Q1, L) provide premium and discount zones for the current HTF candle. Entering long below EQ and short above EQ aligns with the PO3 distribution model.
[*]Enable Extend Previous Opens to track historical HTF open prices as potential support and resistance. Price frequently returns to prior HTF opens before continuing.
[*]In Macros mode, the 8 ICT windows mark the 20-minute periods where London and New York session pivots are typically formed. These are common manipulation windows within the daily PO3 cycle.
[*]The Ticks per Row input should match your instrument's structure. For index futures (e.g. ES, NQ), 4–10 ticks per row is typical. For forex pairs with 5-digit pricing, 1–2 ticks may be more appropriate.
[*]The indicator requires a higher timeframe than the chart. Setting the timeframe equal to or below the chart timeframe triggers a runtime error by design.
[*]Footprint data requires a TradingView plan that includes volume footprint access. If `request.footprint()` returns `na` consistently, check your plan level and confirm the symbol provides tick data.
[/list]

[b]Recommended Pairings[/b]

[list]
[*]Works well alongside an order block or fair value gap indicator to confirm that PO3 manipulation legs are sweeping known liquidity zones.
[*]Pair with a session VWAP indicator to see how the HTF open relates to volume-weighted price — divergence between the HTF open and VWAP is a common manipulation signal.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © jabez4jc
// Original concept by ICT / Inner Circle Trader

//@version=6
indicator("HTF Power of Three° Pro", "PO3° Pro", overlay = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
//  CONCEPT
//  Power of Three (PO3) models every candle as a 3-stage Smart Money campaign:
//    Accumulation  →  price consolidates near the Open
//    Manipulation  →  liquidity sweep (stop hunt) in one direction
//    Distribution  →  expansion and close in the opposite direction
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  USER-DEFINED TYPE  — HTF candle snapshot for projection panel history
// ══════════════════════════════════════════════════════════════════════════════

type HTFSnap
    float o
    float h
    float l
    float c
    float d
    bool  conv  // volume concentration conviction flag

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ── PO3 Settings ─────────────────────────────────────────────────────────────
i_tf    = input.timeframe("180",  "Timeframe",       group = "PO3 SETTINGS")
i_nyMid = input.bool    (false,   "Use NY Midnight", group = "PO3 SETTINGS",
     tooltip = "Use NY Midnight (00:00 EST) as the Daily/Weekly candle Open instead of the regular session open.")

// ── HTF PO3 Appearance ───────────────────────────────────────────────────────
i_bullBody = input.color(color.new(color.green, 70), "Body",    group = "HTF PO3 APPEARANCE", inline = "body")
i_bearBody = input.color(color.new(color.red,   70), "",        group = "HTF PO3 APPEARANCE", inline = "body")
i_bullBord = input.color(color.new(color.gray,   0), "Border",  group = "HTF PO3 APPEARANCE", inline = "bord")
i_bearBord = input.color(color.black,               "",        group = "HTF PO3 APPEARANCE", inline = "bord")
i_bullWick = input.color(color.new(color.gray,  40), "Wick",    group = "HTF PO3 APPEARANCE", inline = "wick")
i_bearWick = input.color(color.new(color.gray,  40), "",        group = "HTF PO3 APPEARANCE", inline = "wick")

// ── Projection Panel ──────────────────────────────────────────────────────────
i_showProj   = input.bool  (true,  "Show Projection Panel",  group = "PROJECTION PANEL",
     tooltip = "Plots the live HTF candle + selected number of prior candles to the right of the chart.")
i_projCount  = input.int   (3,     "Candles to Show",        group = "PROJECTION PANEL", minval = 1, maxval = 10)
i_projOff    = input.int   (15,    "Right Offset (Bars)",    group = "PROJECTION PANEL", minval = 5)
i_projW      = input.int   (6,     "Candle Width",           group = "PROJECTION PANEL", minval = 2, maxval = 30, inline = "pdim")
i_projGap    = input.int   (10,    "Gap",                    group = "PROJECTION PANEL", minval = 1, maxval = 30, inline = "pdim")
i_projLabels = input.bool  (true,  "Show OHLC Labels",       group = "PROJECTION PANEL")
i_projDelta  = input.bool  (true,  "Show Delta Labels",      group = "PROJECTION PANEL")

// ── LTF Projections (Live PO3°) ──────────────────────────────────────────────
i_showOHLC = input.bool  (true,         "OHLC Price",        group = "LTF PROJECTIONS (Live PO3°)", inline = "ohlc")
i_ohlcCol  = input.color (color.silver, "",                  group = "LTF PROJECTIONS (Live PO3°)", inline = "ohlc")
i_ohlcMode = input.string("Normal",     "",                  group = "LTF PROJECTIONS (Live PO3°)", inline = "ohlc",
     options = ["Normal", "% Range"])
i_showOpen = input.bool  (true,         "Open Line",         group = "LTF PROJECTIONS (Live PO3°)", inline = "openl")
i_openCol  = input.color (color.gray,   "",                  group = "LTF PROJECTIONS (Live PO3°)", inline = "openl")
i_openW    = input.int   (1,            "Width",             group = "LTF PROJECTIONS (Live PO3°)", inline = "openl",
     minval = 1, maxval = 4)
i_showLH   = input.bool  (true,         "L/H Lines",         group = "LTF PROJECTIONS (Live PO3°)", inline = "lh")
i_lhCol    = input.color (color.teal,   "",                  group = "LTF PROJECTIONS (Live PO3°)", inline = "lh")
i_lhW      = input.int   (1,            "Width",             group = "LTF PROJECTIONS (Live PO3°)", inline = "lh",
     minval = 1, maxval = 4)
i_lblSize  = input.string("Small",      "Label & Text Size", group = "LTF PROJECTIONS (Live PO3°)",
     options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"])

// ── LTF Projections (Previous PO3°) ─────────────────────────────────────────
i_showPrev    = input.bool  (true,                             "Show Previous PO3",   group = "LTF PROJECTIONS (Previous PO3°)")
i_prevOpenSty = input.string("Dashed",                         "Prev Open Style",     group = "LTF PROJECTIONS (Previous PO3°)", inline = "popen",
     options = ["Solid", "Dashed", "Dotted"])
i_prevOpenCol = input.color (color.new(color.orange,  0),      "",                    group = "LTF PROJECTIONS (Previous PO3°)", inline = "popen")
i_prevOpenW   = input.int   (1,                                "Width",               group = "LTF PROJECTIONS (Previous PO3°)", inline = "popen",
     minval = 1, maxval = 4)
i_prevHLSty   = input.string("Dashed",                         "Prev H/L Style",      group = "LTF PROJECTIONS (Previous PO3°)", inline = "phl",
     options = ["Solid", "Dashed", "Dotted"])
i_prevHLCol   = input.color (color.new(color.yellow,  0),      "",                    group = "LTF PROJECTIONS (Previous PO3°)", inline = "phl")
i_prevHLW     = input.int   (1,                                "Width",               group = "LTF PROJECTIONS (Previous PO3°)", inline = "phl",
     minval = 1, maxval = 4)
i_prevEQSty   = input.string("Dotted",                         "Prev EQ Style",       group = "LTF PROJECTIONS (Previous PO3°)", inline = "peq",
     options = ["Solid", "Dashed", "Dotted"])
i_prevEQCol   = input.color (color.new(color.white,  40),      "",                    group = "LTF PROJECTIONS (Previous PO3°)", inline = "peq")
i_prevEQW     = input.int   (1,                                "Width",               group = "LTF PROJECTIONS (Previous PO3°)", inline = "peq",
     minval = 1, maxval = 4)
i_extPrevOpen = input.bool  (false,                            "Extend Previous Opens", group = "LTF PROJECTIONS (Previous PO3°)",
     tooltip = "Projects the Open price of up to 10 past HTF candles as dotted lines across the chart.")

// ── Dealing Range ─────────────────────────────────────────────────────────────
i_showDR    = input.bool  (false,                       "Show Dealing Range",  group = "DEALING RANGE (Monster Lab)")
i_drHLSty   = input.string("Solid",                     "H/L Style",          group = "DEALING RANGE (Monster Lab)", inline = "drhl",
     options = ["Solid", "Dashed", "Dotted"])
i_drHLCol   = input.color (color.white,                 "",                   group = "DEALING RANGE (Monster Lab)", inline = "drhl")
i_drHLW     = input.int   (1,                           "Width",              group = "DEALING RANGE (Monster Lab)", inline = "drhl",
     minval = 1, maxval = 4)
i_drEQSty   = input.string("Dashed",                    "EQ Style",           group = "DEALING RANGE (Monster Lab)", inline = "dreq",
     options = ["Solid", "Dashed", "Dotted"])
i_drEQCol   = input.color (color.new(color.white, 40),  "",                   group = "DEALING RANGE (Monster Lab)", inline = "dreq")
i_drEQW     = input.int   (1,                           "Width",              group = "DEALING RANGE (Monster Lab)", inline = "dreq",
     minval = 1, maxval = 4)
i_drQSty    = input.string("Dotted",                    "Q1/Q3 Style",        group = "DEALING RANGE (Monster Lab)", inline = "drq",
     options = ["Solid", "Dashed", "Dotted"])
i_drQCol    = input.color (color.new(color.gray, 30),   "",                   group = "DEALING RANGE (Monster Lab)", inline = "drq")
i_drQW      = input.int   (1,                           "Width",              group = "DEALING RANGE (Monster Lab)", inline = "drq",
     minval = 1, maxval = 4)
i_drLabels  = input.bool  (true,                        "Show Level Labels",  group = "DEALING RANGE (Monster Lab)")

// ── Weekly Profile ────────────────────────────────────────────────────────────
i_showWP  = input.bool  (false,                          "Show Weekly Profile", group = "WEEKLY PROFILE",
     tooltip = "Segments the weekly candle into individual daily ranges. Best used when Timeframe = W.")
i_wpMon   = input.color (color.new(color.blue,   75),   "Mon",  group = "WEEKLY PROFILE", inline = "wpd1")
i_wpTue   = input.color (color.new(color.purple, 75),   "Tue",  group = "WEEKLY PROFILE", inline = "wpd1")
i_wpWed   = input.color (color.new(color.orange, 75),   "Wed",  group = "WEEKLY PROFILE", inline = "wpd1")
i_wpThu   = input.color (color.new(color.teal,   75),   "Thu",  group = "WEEKLY PROFILE", inline = "wpd2")
i_wpFri   = input.color (color.new(color.red,    75),   "Fri",  group = "WEEKLY PROFILE", inline = "wpd2")

// ── Time & Price ──────────────────────────────────────────────────────────────
i_tpMode = input.string("Off", "Mode", group = "TIME & PRICE",
     options = ["Off", "Macros", "Session", "Day of Week"],
     tooltip = "Macros: ICT 20-min windows around hourly pivots (EST). Session: up to 3 custom intraday windows. Day of Week: groups weekdays into 2 PO3 candles.")

// Macros appearance
i_macroBody = input.color(color.new(color.yellow, 80), "Macro Color",  group = "TIME & PRICE", inline = "mac")
i_macroBord = input.color(color.new(color.yellow,  0), "Border",       group = "TIME & PRICE", inline = "mac")

// Session inputs — times in exchange timezone (HH:MM)
i_s1En = input.bool  (true,    "Session 1 ", group = "TIME & PRICE", inline = "s1")
i_s1St = input.string("08:30", "",           group = "TIME & PRICE", inline = "s1",
     tooltip = "Start time in exchange timezone (HH:MM, 24h)")
i_s1Et = input.string("12:00", "–",          group = "TIME & PRICE", inline = "s1")
i_s1Co = input.color (color.new(color.blue,  75), "", group = "TIME & PRICE", inline = "s1")

i_s2En = input.bool  (true,    "Session 2 ", group = "TIME & PRICE", inline = "s2")
i_s2St = input.string("12:00", "",           group = "TIME & PRICE", inline = "s2")
i_s2Et = input.string("16:00", "–",          group = "TIME & PRICE", inline = "s2")
i_s2Co = input.color (color.new(color.green, 75), "", group = "TIME & PRICE", inline = "s2")

i_s3En = input.bool  (false,   "Session 3 ", group = "TIME & PRICE", inline = "s3")
i_s3St = input.string("20:00", "",           group = "TIME & PRICE", inline = "s3")
i_s3Et = input.string("00:00", "–",          group = "TIME & PRICE", inline = "s3")
i_s3Co = input.color (color.new(color.purple,75), "", group = "TIME & PRICE", inline = "s3")

// Day of Week
i_dowSplit = input.int   (4,                          "Group A: Days 1–N (Mon=1…Fri=5)", group = "TIME & PRICE",
     minval = 1, maxval = 4,
     tooltip = "Days Mon through N form Group A (e.g. 4 = Mon–Thu). Remaining days form Group B.")
i_dowColA  = input.color (color.new(color.blue, 75), "Group A",  group = "TIME & PRICE", inline = "dowc")
i_dowColB  = input.color (color.new(color.red,  75), "Group B",  group = "TIME & PRICE", inline = "dowc")

// ── Footprint Delta Labels ────────────────────────────────────────────────────
i_showDeltaHist = input.bool  (true,        "HTF Delta Labels", group = "FOOTPRINT DELTA")
i_showDeltaLive = input.bool  (true,        "Live Delta Label", group = "FOOTPRINT DELTA")
i_fpTicks       = input.int   (4,           "Ticks per Row",    group = "FOOTPRINT DELTA", minval = 1)
i_fpVa          = input.int   (70,          "VA Percent",       group = "FOOTPRINT DELTA", minval = 1, maxval = 100)
i_fpImb         = input.int   (300,         "Imbalance %",      group = "FOOTPRINT DELTA", minval = 1)
i_deltaPosCol   = input.color (color.lime,  "Positive",         group = "FOOTPRINT DELTA", inline = "dcol")
i_deltaNegCol   = input.color (color.red,   "Negative",         group = "FOOTPRINT DELTA", inline = "dcol")

// ── Volume Concentration ──────────────────────────────────────────────────────
i_showConc    = input.bool  (true,                              "Show Conviction Highlight", group = "VOLUME CONCENTRATION",
     tooltip  = "Highlights HTF candles where delta was concentrated in the 'correct' half of the range.\nBull: majority of buy delta in lower 50% of range.\nBear: majority of sell delta in upper 50% of range.")
i_concThresh  = input.int   (60,                                "Concentration Threshold %", group = "VOLUME CONCENTRATION",
     minval   = 51, maxval = 100,
     tooltip  = "Minimum % of total delta that must come from the conviction zone to trigger a highlight.")
i_concBullCol = input.color (color.new(#00e5ff, 0),             "Bull Conviction",           group = "VOLUME CONCENTRATION", inline = "cconv")
i_concBearCol = input.color (color.new(#ff9800, 0),             "Bear Conviction",           group = "VOLUME CONCENTRATION", inline = "cconv")
i_concBordW   = input.int   (2,                                 "Highlight Border Width",    group = "VOLUME CONCENTRATION",
     minval   = 1, maxval = 4)

// ── PO3 Info Table ───────────────────────────────────────────────────────────
i_range  = input.string("Price",   "Range",  group = "PO3 INFO TABLE", options = ["Price", "Ticks"])
i_tblY   = input.string("middle",  "",       group = "PO3 INFO TABLE", inline = "tpos",
     options = ["top", "middle", "bottom"])
i_tblX   = input.string("right",   "",       group = "PO3 INFO TABLE", inline = "tpos",
     options = ["left", "center", "right"])
i_lblCol = input.color(color.new(color.gray, 60), "Label", group = "PO3 INFO TABLE", inline = "tcol")
i_txtCol = input.color(color.white,               "Text",  group = "PO3 INFO TABLE", inline = "tcol")

// ══════════════════════════════════════════════════════════════════════════════
//  VALIDATION
// ══════════════════════════════════════════════════════════════════════════════

if timeframe.in_seconds(i_tf) <= timeframe.in_seconds(timeframe.period)
    runtime.error("⚠ PO3° — Timeframe must be HIGHER than the chart timeframe.")

// ══════════════════════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

pad2(n) => (n < 10 ? "0" : "") + str.tostring(n)

fmtOHLC(v, lo, hi, mode) =>
    rng = hi - lo
    if mode == "Normal"
        str.tostring(v, format.mintick)
    else
        pct = rng > 0 ? (v - lo) / rng * 100.0 : 0.0
        str.tostring(math.round(pct, 1)) + "%"

getPos() =>
    switch i_tblY + "_" + i_tblX
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        =>                 position.middle_right

getSize() =>
    switch i_lblSize
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

getStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_dashed

// Parse "HH:MM" → total minutes from midnight
parseTime(t) =>
    int result = 0
    if str.length(t) >= 5
        h = int(nz(str.tonumber(str.substring(t, 0, 2)), 0))
        m = int(nz(str.tonumber(str.substring(t, 3, 5)), 0))
        result := h * 60 + m
    result

// Current bar minutes from midnight in exchange timezone
barMins() => hour * 60 + minute

// Current bar minutes in EST
barMinsEST() => hour(time, "America/New_York") * 60 + minute(time, "America/New_York")

// ══════════════════════════════════════════════════════════════════════════════
//  HTF DATA REQUEST
// ══════════════════════════════════════════════════════════════════════════════

[htfO, htfH, htfL, htfC, htfT] = request.security(
     syminfo.tickerid, i_tf, [open, high, low, close, time],
     barmerge.gaps_off, barmerge.lookahead_on)

// Daily data — used for Weekly Profile and Day of Week mode
[dO, dH, dL, dC, dT, dDow] = request.security(
     syminfo.tickerid, "D", [open, high, low, close, time, dayofweek],
     barmerge.gaps_off, barmerge.lookahead_on)

// ══════════════════════════════════════════════════════════════════════════════
//  FOOTPRINT DATA
//  barDelta = net delta for this LTF bar (all rows summed)
//  barLHD   = bar delta when bar midpoint is in the LOWER half of HTF range
//  barUHD   = bar delta when bar midpoint is in the UPPER half of HTF range
//
//  Note: volume_row exposes delta/volume/bid_vol/ask_vol only — no low/high.
//  We classify each LTF bar as lower-half or upper-half using the bar's own
//  price midpoint vs the HTF range midpoint. This is accurate and idiomatic.
// ══════════════════════════════════════════════════════════════════════════════

footprint fp = request.footprint(i_fpTicks, i_fpVa, i_fpImb)
float barDelta = na
float barLHD   = na
float barUHD   = na

if not na(fp)
    array<volume_row> rows = fp.rows()
    float totalD = 0.0
    for row in rows
        totalD += row.delta()
    barDelta := totalD
    // HTF midpoint from request.security (available here; cH/cL not yet declared)
    htfMid = (htfH + htfL) / 2.0
    barMid = (high  + low)  / 2.0
    if barMid < htfMid
        barLHD := totalD
        barUHD := 0.0
    else
        barLHD := 0.0
        barUHD := totalD

// ══════════════════════════════════════════════════════════════════════════════
//  NY MIDNIGHT OPEN
// ══════════════════════════════════════════════════════════════════════════════

var float _nyOpen = na
if i_nyMid
    if hour(time, "America/New_York") == 0 and minute(time, "America/New_York") == 0
        _nyOpen := open

isTFD      = i_tf == "D" or i_tf == "1440"
isTFW      = i_tf == "W" or i_tf == "10080"
htfOpenEff = i_nyMid and (isTFD or isTFW) and not na(_nyOpen) ? _nyOpen : htfO

// ══════════════════════════════════════════════════════════════════════════════
//  CURRENT + PREVIOUS HTF CANDLE STATE
// ══════════════════════════════════════════════════════════════════════════════

var float cO  = na   // current: effective Open
var float cH  = na   // current: running High
var float cL  = na   // current: running Low
var float cC  = na   // current: running Close
var float cD  = na   // current: running Delta
var float cLH = 0.0  // current: running lower-half delta
var float cUH = 0.0  // current: running upper-half delta
var int   cS  = na   // current: start bar_index

var float pO = na   // previous: Open
var float pH = na   // previous: High
var float pL = na   // previous: Low
var int   pS = na   // previous: start bar_index

// Projection panel history  (newest at index 0, max 10 entries)
var array<HTFSnap> htfHist = array.new<HTFSnap>()

// Ring buffer of past opens for "Extend Previous Opens"
MAX_EXT = 10
var array<float> extOpens = array.new<float>()
var array<int>   extBars  = array.new<int>  ()

isNewHTF = ta.change(htfT) != 0

// ══════════════════════════════════════════════════════════════════════════════
//  DRAW COMPLETED HTF CANDLE  (body box + wick lines + delta label)
// ══════════════════════════════════════════════════════════════════════════════

// Format delta value with K/M suffix (used in projection panel)
formatDelta(v) =>
    sign   = v >= 0 ? "+" : ""
    absVal = math.abs(v)
    string result = ""
    if absVal >= 1000000
        result := sign + str.format("{0,number,#.#}M", v / 1000000)
    else if absVal >= 1000
        result := sign + str.format("{0,number,#.#}K", v / 1000)
    else
        result := sign + str.tostring(math.round(v))
    result

// Compute conviction flag from accumulated half-deltas
//   Bull conviction: buy delta concentrated in lower half
//   Bear conviction: sell delta concentrated in upper half
isConviction(o, c, lhd, uhd) =>
    bull     = c >= o
    total    = math.abs(nz(lhd, 0)) + math.abs(nz(uhd, 0))
    if total == 0 or not i_showConc
        false
    else if bull
        // For bull candle: we want positive (buy) delta dominant in lower half
        lhd > 0 and (lhd / total) * 100 >= i_concThresh
    else
        // For bear candle: we want negative (sell) delta dominant in upper half
        uhd < 0 and (math.abs(uhd) / total) * 100 >= i_concThresh

drawCandle(o, h, l, c, d, lhd, uhd, s, e) =>
    bull  = c >= o
    top   = math.max(o, c)
    bot   = math.min(o, c)
    mid   = math.round((s + e) / 2)
    bC    = bull ? i_bullBody : i_bearBody
    bordC = bull ? i_bullBord : i_bearBord
    wC    = bull ? i_bullWick : i_bearWick
    pad   = math.max((h - l) * 0.08, syminfo.mintick * 10)
    delC  = d >= 0 ? i_deltaPosCol : i_deltaNegCol
    conv  = isConviction(o, c, lhd, uhd)
    // Conviction candles: glow box behind body + highlighted border
    if conv
        hlCol = bull ? i_concBullCol : i_concBearCol
        box.new(s - 1, top + pad * 0.3, e + 1, bot - pad * 0.3,
             border_color = color.new(hlCol, 60),
             bgcolor      = color.new(hlCol, 88),
             border_width = i_concBordW)
    box.new(s, top, e, bot,
         border_color = conv ? (bull ? i_concBullCol : i_concBearCol) : bordC,
         bgcolor      = bC,
         border_width = conv ? i_concBordW : 1)
    if h > top
        line.new(mid, h,   mid, top, color = wC, width = 1)
    if l < bot
        line.new(mid, bot, mid, l,   color = wC, width = 1)
    if i_showDeltaHist and not na(d)
        // Conviction candles: append concentration badge to delta label
        dLabel = str.tostring(d, format.volume)
        if conv
            pctZone = bull ?
                 (nz(lhd, 0) / (math.abs(nz(lhd, 0)) + math.abs(nz(uhd, 0)))) * 100 :
                 (math.abs(nz(uhd, 0)) / (math.abs(nz(lhd, 0)) + math.abs(nz(uhd, 0)))) * 100
            dLabel += "\n▲ " + str.tostring(math.round(pctZone)) + "% conc."
        label.new(mid, l - pad, dLabel,
             color     = color.new(color.black, 100),
             textcolor = conv ? (bull ? i_concBullCol : i_concBearCol) : delC,
             style     = label.style_label_up, size = getSize())

// ══════════════════════════════════════════════════════════════════════════════
//  STATE UPDATES
// ══════════════════════════════════════════════════════════════════════════════

if isNewHTF
    if not na(cO)
        drawCandle(cO, cH, cL, cC, cD, cLH, cUH, cS, bar_index - 1)
        pO := cO
        pH := cH
        pL := cL
        pS := cS
        // Push snapshot for projection panel (newest first, capped at 10)
        array.unshift(htfHist, HTFSnap.new(cO, cH, cL, cC, nz(cD, 0), isConviction(cO, cC, cLH, cUH)))
        if array.size(htfHist) > 10
            array.pop(htfHist)
        if i_extPrevOpen
            array.push(extOpens, cO)
            array.push(extBars,  cS)
            if array.size(extOpens) > MAX_EXT
                array.shift(extOpens)
                array.shift(extBars)
    cO  := htfOpenEff
    cH  := htfH
    cL  := htfL
    cC  := htfC
    cD  := nz(barDelta, 0)
    cLH := nz(barLHD, 0)
    cUH := nz(barUHD, 0)
    cS  := bar_index
else if na(cO)
    cO  := htfOpenEff
    cH  := htfH
    cL  := htfL
    cC  := htfC
    cD  := nz(barDelta, 0)
    cLH := nz(barLHD, 0)
    cUH := nz(barUHD, 0)
    cS  := bar_index
else
    cH  := math.max(cH, high)
    cL  := math.min(cL, low)
    cC  := close
    cD  := nz(cD, 0)  + nz(barDelta, 0)
    cLH := nz(cLH, 0) + nz(barLHD,   0)
    cUH := nz(cUH, 0) + nz(barUHD,   0)

// ══════════════════════════════════════════════════════════════════════════════
//  LIVE BOX  (current open HTF candle — redrawn on each tick)
// ══════════════════════════════════════════════════════════════════════════════

var box   lvBox  = na
var box   lvGlow = na
var line  lvUW   = na
var line  lvLW   = na
var label lvDL   = na

if barstate.islast and not na(cO)
    box.delete(lvBox)
    box.delete(lvGlow)
    line.delete(lvUW)
    line.delete(lvLW)
    label.delete(lvDL)

    bull  = close >= cO
    top   = math.max(cO, close)
    bot   = math.min(cO, close)
    sB    = nz(cS, bar_index)
    eB    = bar_index
    mid   = math.round((sB + eB) / 2)
    pad   = math.max((htfH - htfL) * 0.08, syminfo.mintick * 10)
    conv  = isConviction(cO, close, cLH, cUH)
    hlCol = bull ? i_concBullCol : i_concBearCol

    // Glow halo for conviction
    if conv
        lvGlow := box.new(sB - 1, top + pad * 0.3, eB + 1, bot - pad * 0.3,
             border_color = color.new(hlCol, 60),
             bgcolor      = color.new(hlCol, 88),
             border_width = i_concBordW)

    lvBox := box.new(sB, top, eB, bot,
         border_color = conv ? hlCol : (bull ? i_bullBord : i_bearBord),
         bgcolor      = bull ? i_bullBody : i_bearBody,
         border_width = conv ? i_concBordW : 1)

    if htfH > top
        lvUW := line.new(mid, htfH, mid, top,  color = bull ? i_bullWick : i_bearWick, width = 1)
    if htfL < bot
        lvLW := line.new(mid, bot,  mid, htfL, color = bull ? i_bullWick : i_bearWick, width = 1)

    if i_showDeltaLive and not na(cD)
        total  = math.abs(nz(cLH, 0)) + math.abs(nz(cUH, 0))
        pctZone = total > 0 ? (bull ?
             (nz(cLH, 0) / total) * 100 :
             (math.abs(nz(cUH, 0)) / total) * 100) : 0.0
        dTxt  = str.tostring(cD, format.volume)
        if conv
            dTxt += "\n▲ " + str.tostring(math.round(pctZone)) + "% conc."
        lvDL := label.new(mid, htfL - pad, dTxt,
             color     = color.new(color.black, 100),
             textcolor = conv ? hlCol : (cD >= 0 ? i_deltaPosCol : i_deltaNegCol),
             style     = label.style_label_up, size = getSize())

// ══════════════════════════════════════════════════════════════════════════════
//  LIVE PROJECTION LINES  (Open / High / Low)
// ══════════════════════════════════════════════════════════════════════════════

var line lnO = na
var line lnH = na
var line lnL = na

if barstate.islast
    line.delete(lnO)
    line.delete(lnH)
    line.delete(lnL)
    sB = nz(cS, bar_index)
    eB = bar_index + 50
    if i_showOpen and not na(cO)
        lnO := line.new(sB, cO,   eB, cO,   color = i_openCol, width = i_openW, style = line.style_dashed)
    if i_showLH
        lnH := line.new(sB, htfH, eB, htfH, color = i_lhCol,   width = i_lhW,   style = line.style_dashed)
        lnL := line.new(sB, htfL, eB, htfL, color = i_lhCol,   width = i_lhW,   style = line.style_dashed)

// ══════════════════════════════════════════════════════════════════════════════
//  PREVIOUS PO3 PROJECTION LINES  (Open / High / Low / EQ)
// ══════════════════════════════════════════════════════════════════════════════

var line pvO  = na
var line pvH  = na
var line pvL  = na
var line pvEQ = na

if barstate.islast and i_showPrev and not na(pO)
    line.delete(pvO)
    line.delete(pvH)
    line.delete(pvL)
    line.delete(pvEQ)

    pEQ = (pH + pL) / 2
    sB  = nz(pS, bar_index)
    eB  = bar_index + 50

    pvO  := line.new(sB, pO,  eB, pO,  color = i_prevOpenCol, width = i_prevOpenW, style = getStyle(i_prevOpenSty))
    pvH  := line.new(sB, pH,  eB, pH,  color = i_prevHLCol,   width = i_prevHLW,   style = getStyle(i_prevHLSty))
    pvL  := line.new(sB, pL,  eB, pL,  color = i_prevHLCol,   width = i_prevHLW,   style = getStyle(i_prevHLSty))
    pvEQ := line.new(sB, pEQ, eB, pEQ, color = i_prevEQCol,   width = i_prevEQW,   style = getStyle(i_prevEQSty))

// ══════════════════════════════════════════════════════════════════════════════
//  EXTENDED PREVIOUS OPENS  (dotted lines for up to 10 historical HTF opens)
// ══════════════════════════════════════════════════════════════════════════════

var array<line> extLines = array.new<line>()

if barstate.islast and i_extPrevOpen
    for ln in extLines
        line.delete(ln)
    array.clear(extLines)
    n = array.size(extOpens)
    for i = 0 to n - 1
        o  = array.get(extOpens, i)
        sb = array.get(extBars,  i)
        ln = line.new(sb, o, bar_index + 50, o,
             color = color.new(i_prevOpenCol, 50),
             width = 1, style = line.style_dotted)
        array.push(extLines, ln)

// ══════════════════════════════════════════════════════════════════════════════
//  DEALING RANGE  (High · Q3 75% · EQ 50% · Q1 25% · Low of live HTF candle)
// ══════════════════════════════════════════════════════════════════════════════

var line  drH   = na
var line  drL   = na
var line  drEQ  = na
var line  drQ1  = na
var line  drQ3  = na
var label drLbH = na
var label drLbL = na
var label drLbE = na
var label drLb1 = na
var label drLb3 = na

if barstate.islast and i_showDR and not na(cO)
    line.delete(drH)
    line.delete(drL)
    line.delete(drEQ)
    line.delete(drQ1)
    line.delete(drQ3)
    label.delete(drLbH)
    label.delete(drLbL)
    label.delete(drLbE)
    label.delete(drLb1)
    label.delete(drLb3)

    rng  = htfH - htfL
    eq   = htfL + rng * 0.50
    q1   = htfL + rng * 0.25
    q3   = htfL + rng * 0.75
    sB   = nz(cS, bar_index)
    eB   = bar_index + 50
    lbX  = bar_index + 52
    trn  = color.new(color.white, 100)
    sz   = getSize()

    drH  := line.new(sB, htfH, eB, htfH, color = i_drHLCol, width = i_drHLW, style = getStyle(i_drHLSty))
    drL  := line.new(sB, htfL, eB, htfL, color = i_drHLCol, width = i_drHLW, style = getStyle(i_drHLSty))
    drEQ := line.new(sB, eq,   eB, eq,   color = i_drEQCol, width = i_drEQW, style = getStyle(i_drEQSty))
    drQ1 := line.new(sB, q1,   eB, q1,   color = i_drQCol,  width = i_drQW,  style = getStyle(i_drQSty))
    drQ3 := line.new(sB, q3,   eB, q3,   color = i_drQCol,  width = i_drQW,  style = getStyle(i_drQSty))

    if i_drLabels
        drLbH := label.new(lbX, htfH, "DR High",  color = trn, textcolor = i_drHLCol, style = label.style_label_left, size = sz)
        drLbL := label.new(lbX, htfL, "DR Low",   color = trn, textcolor = i_drHLCol, style = label.style_label_left, size = sz)
        drLbE := label.new(lbX, eq,   "EQ  50%",  color = trn, textcolor = i_drEQCol, style = label.style_label_left, size = sz)
        drLb1 := label.new(lbX, q1,   "Q1  25%",  color = trn, textcolor = i_drQCol,  style = label.style_label_left, size = sz)
        drLb3 := label.new(lbX, q3,   "Q3  75%",  color = trn, textcolor = i_drQCol,  style = label.style_label_left, size = sz)

// ══════════════════════════════════════════════════════════════════════════════
//  OHLC PRICE LABELS
// ══════════════════════════════════════════════════════════════════════════════

var label lbO = na
var label lbH = na
var label lbL = na
var label lbC = na

if barstate.islast and i_showOHLC and not na(cO)
    label.delete(lbO)
    label.delete(lbH)
    label.delete(lbL)
    label.delete(lbC)
    x  = bar_index + 2
    trn = color.new(color.white, 100)
    sz  = getSize()
    lo  = htfL
    hi  = htfH
    m   = i_ohlcMode
    lbO := label.new(x, cO,    "O: " + fmtOHLC(cO,    lo, hi, m), color = trn, textcolor = i_ohlcCol, style = label.style_label_left, size = sz)
    lbH := label.new(x, htfH,  "H: " + fmtOHLC(htfH,  lo, hi, m), color = trn, textcolor = i_ohlcCol, style = label.style_label_left, size = sz)
    lbL := label.new(x, htfL,  "L: " + fmtOHLC(htfL,  lo, hi, m), color = trn, textcolor = i_ohlcCol, style = label.style_label_left, size = sz)
    lbC := label.new(x, close, "C: " + fmtOHLC(close, lo, hi, m), color = trn, textcolor = i_ohlcCol, style = label.style_label_left, size = sz)

// ══════════════════════════════════════════════════════════════════════════════
//  WEEKLY PROFILE
//  Tracks each daily candle and draws a body box inside the weekly range.
//  dayofweek: 1=Sun  2=Mon  3=Tue  4=Wed  5=Thu  6=Fri  7=Sat
// ══════════════════════════════════════════════════════════════════════════════

var float wdO   = na
var float wdH   = na
var float wdL   = na
var float wdC   = na
var int   wdS   = na
var int   wdDow = na

isNewDay = ta.change(dT) != 0

if i_showWP
    if isNewDay and not na(wdO)
        // Finalise completed day
        dow    = nz(wdDow, 2)
        dayCol = switch dow
            2 => i_wpMon
            3 => i_wpTue
            4 => i_wpWed
            5 => i_wpThu
            6 => i_wpFri
            => color.new(color.gray, 75)
        top = math.max(wdO, wdC)
        bot = math.min(wdO, wdC)
        box.new(wdS, top, bar_index - 1, bot,
             bgcolor = dayCol, border_color = color.new(dayCol, 20), border_width = 1)

    if isNewDay or na(wdO)
        wdO   := dO
        wdH   := dH
        wdL   := dL
        wdC   := dC
        wdS   := bar_index
        wdDow := dDow
    else
        wdH := math.max(wdH, high)
        wdL := math.min(wdL, low)
        wdC := close

// ══════════════════════════════════════════════════════════════════════════════
//  TIME & PRICE — MACROS
//  ICT macro windows in EST. Each window is a 20-min candle around an hourly
//  boundary: the :50–:10 region. Classic 8 windows used by ICT practitioners.
//  Logic: track state inside a function — Pine inlines each call site so each
//  invocation has its own independent var variables.
// ══════════════════════════════════════════════════════════════════════════════

// startMin / endMin are total minutes from midnight in EST
macroTrack(startMin, endMin) =>
    var float _O   = na
    var float _H   = na
    var float _L   = na
    var int   _S   = na
    var bool  _was = false

    bm    = barMinsEST()
    inWin = bm >= startMin and bm < endMin

    // Entering window
    if inWin and not _was
        _O   := open
        _H   := high
        _L   := low
        _S   := bar_index
        _was := true

    // Inside window — update running H/L
    if inWin and _was
        _H := math.max(_H, high)
        _L := math.min(_L, low)

    // Window just closed — draw the macro candle
    if not inWin and _was
        if not na(_O) and i_tpMode == "Macros"
            top = math.max(_O, close[1])
            bot = math.min(_O, close[1])
            mid = math.round((_S + bar_index - 1) / 2)
            box.new(_S, top, bar_index - 1, bot,
                 bgcolor      = i_macroBody,
                 border_color = i_macroBord,
                 border_width = 1)
            if _H > top
                line.new(mid, _H, mid, top, color = i_macroBord, width = 1)
            if _L < bot
                line.new(mid, bot, mid, _L, color = i_macroBord, width = 1)
        _O   := na
        _H   := na
        _L   := na
        _S   := na
        _was := false

// Always call — each call site has independent var state
macroTrack(153, 170)   // 02:33 – 02:50
macroTrack(243, 260)   // 04:03 – 04:20
macroTrack(530, 550)   // 08:50 – 09:10
macroTrack(590, 610)   // 09:50 – 10:10
macroTrack(650, 670)   // 10:50 – 11:10
macroTrack(710, 730)   // 11:50 – 12:10
macroTrack(790, 830)   // 13:10 – 13:50
macroTrack(915, 945)   // 15:15 – 15:45

// ══════════════════════════════════════════════════════════════════════════════
//  TIME & PRICE — SESSION
//  Up to 3 user-defined intraday sessions (exchange timezone, HH:MM format).
//  Each session is tracked with its own var state via function inlining.
// ══════════════════════════════════════════════════════════════════════════════

// startMin / endMin in exchange timezone minutes from midnight
sessionTrack(en, startMin, endMin, col) =>
    var float _O   = na
    var float _H   = na
    var float _L   = na
    var int   _S   = na
    var bool  _was = false

    if en and i_tpMode == "Session"
        bm    = barMins()
        // Handle midnight-crossing sessions (e.g. 20:00 – 00:00)
        inWin = endMin > startMin ?
             (bm >= startMin and bm < endMin) :
             (bm >= startMin or  bm < endMin)

        // Entering window
        if inWin and not _was
            _O   := open
            _H   := high
            _L   := low
            _S   := bar_index
            _was := true

        // Inside window — update running H/L
        if inWin and _was
            _H := math.max(_H, high)
            _L := math.min(_L, low)

        // Window just closed — draw session candle
        if not inWin and _was
            if not na(_O)
                top = math.max(_O, close[1])
                bot = math.min(_O, close[1])
                mid = math.round((_S + bar_index - 1) / 2)
                box.new(_S, top, bar_index - 1, bot,
                     bgcolor      = col,
                     border_color = color.new(col, 10),
                     border_width = 1)
                if _H > top
                    line.new(mid, _H, mid, top, color = color.new(col, 10), width = 1)
                if _L < bot
                    line.new(mid, bot, mid, _L, color = color.new(col, 10), width = 1)
            _O   := na
            _H   := na
            _L   := na
            _S   := na
            _was := false

// Always call — var state is per call site
sessionTrack(i_s1En, parseTime(i_s1St), parseTime(i_s1Et), i_s1Co)
sessionTrack(i_s2En, parseTime(i_s2St), parseTime(i_s2Et), i_s2Co)
sessionTrack(i_s3En, parseTime(i_s3St), parseTime(i_s3Et), i_s3Co)

// ══════════════════════════════════════════════════════════════════════════════
//  TIME & PRICE — DAY OF WEEK
//  Groups Mon–Fri into Group A (days 1..N) and Group B (days N+1..5).
//  Draws two distinct PO3-style candle boxes within the current week.
//  dayofweek: Sun=1 Mon=2 Tue=3 Wed=4 Thu=5 Fri=6 Sat=7
//  Trading day index: Mon=1 Tue=2 Wed=3 Thu=4 Fri=5  →  dow - 1
// ══════════════════════════════════════════════════════════════════════════════

dowGroup(dow) =>
    td = dow - 1  // trading day 1-5
    td <= i_dowSplit ? 1 : 2

// Helper — draws a completed DOW group candle (must be at global scope)
finaliseGroup(o, h, l, s, col) =>
    if not na(o) and not na(s)
        top = math.max(o, close[1])
        bot = math.min(o, close[1])
        mid = math.round((s + bar_index - 1) / 2)
        box.new(s, top, bar_index - 1, bot,
             bgcolor      = col,
             border_color = color.new(col, 10),
             border_width = 1)
        if h > top
            line.new(mid, h, mid, top, color = color.new(col, 10), width = 1)
        if l < bot
            line.new(mid, bot, mid, l, color = color.new(col, 10), width = 1)

var float dowO_A     = na
var float dowH_A     = na
var float dowL_A     = na
var int   dowS_A     = na
var float dowO_B     = na
var float dowH_B     = na
var float dowL_B     = na
var int   dowS_B     = na
var int   lastDowGroup = na

if i_tpMode == "Day of Week"
    curGroup  = dowGroup(dayofweek)
    isNewWeek = ta.change(time("W")) != 0
    grpChange = ta.change(curGroup)  != 0

    if isNewWeek
        finaliseGroup(dowO_A, dowH_A, dowL_A, dowS_A, i_dowColA)
        finaliseGroup(dowO_B, dowH_B, dowL_B, dowS_B, i_dowColB)
        dowO_A := na
        dowH_A := na
        dowL_A := na
        dowS_A := na
        dowO_B := na
        dowH_B := na
        dowL_B := na
        dowS_B := na

    if grpChange and not isNewWeek and not na(lastDowGroup)
        if lastDowGroup == 1
            finaliseGroup(dowO_A, dowH_A, dowL_A, dowS_A, i_dowColA)
            dowO_A := na
            dowH_A := na
            dowL_A := na
            dowS_A := na
        else
            finaliseGroup(dowO_B, dowH_B, dowL_B, dowS_B, i_dowColB)
            dowO_B := na
            dowH_B := na
            dowL_B := na
            dowS_B := na

    if curGroup == 1
        if na(dowO_A)
            dowO_A := open
            dowH_A := high
            dowL_A := low
            dowS_A := bar_index
        else
            dowH_A := math.max(dowH_A, high)
            dowL_A := math.min(dowL_A, low)
    else
        if na(dowO_B)
            dowO_B := open
            dowH_B := high
            dowL_B := low
            dowS_B := bar_index
        else
            dowH_B := math.max(dowH_B, high)
            dowL_B := math.min(dowL_B, low)

    lastDowGroup := curGroup

// ══════════════════════════════════════════════════════════════════════════════
//  PROJECTION PANEL  (HTF candles plotted to the right of the last LTF bar)
//
//  Layout:  [oldest] ← prev2 ← prev1 ← prev0 ← [LIVE]  (right-most = live)
//  Each slot = i_projW bars wide, separated by i_projGap bars.
//  Historical candles are faded; the live candle is full-brightness.
//  Connector dashed lines link the live LTF price origin to the panel.
// ══════════════════════════════════════════════════════════════════════════════

var array<box>   projBoxes  = array.new<box>()
var array<line>  projLines  = array.new<line>()
var array<label> projLabels = array.new<label>()

if barstate.islast and i_showProj and not na(cO)
    // ── Clean up previous render ──────────────────────────────────────────────
    for b  in projBoxes
        box.delete(b)
    for ln in projLines
        line.delete(ln)
    for lb in projLabels
        label.delete(lb)
    array.clear(projBoxes)
    array.clear(projLines)
    array.clear(projLabels)

    cW  = i_projW
    cG  = i_projGap
    trn = color.new(color.white, 100)
    sz  = getSize()

    // TF header string  (e.g. "3H", "1D", "30m")
    tfMins = timeframe.in_seconds(i_tf) / 60
    tfHdr  = tfMins >= 1440 ? str.tostring(int(tfMins / 1440)) + "D" :
             tfMins >= 60   ? str.tostring(int(tfMins / 60))   + "H" :
                              str.tostring(int(tfMins))         + "m"

    // ── Render each slot — p=0 oldest, p=i_projCount-1 live ──────────────────
    for p = 0 to i_projCount - 1
        bool isLive = p == i_projCount - 1

        float sO    = na
        float sH    = na
        float sL    = na
        float sC    = na
        float sD    = na
        bool  sConv_ = false

        if isLive
            sO    := cO
            sH    := htfH
            sL    := htfL
            sC    := close
            sD    := nz(cD, 0)
            sConv_ := isConviction(cO, close, cLH, cUH)
        else
            histIdx = (i_projCount - 2) - p
            if array.size(htfHist) > histIdx
                snap   = array.get(htfHist, histIdx)
                sO    := snap.o
                sH    := snap.h
                sL    := snap.l
                sC    := snap.c
                sD    := snap.d
                sConv_ := snap.conv

        if not na(sO)
            startIdx = last_bar_index + i_projOff + p * (cW + cG)
            endIdx   = startIdx + cW
            midIdx   = math.round((startIdx + endIdx) / 2)
            labelIdx = endIdx + 1

            bull = sC >= sO
            top  = math.max(sO, sC)
            bot  = math.min(sO, sC)

            // Base colors — faded for historical slots
            color bodyC = bull ? i_bullBody : i_bearBody
            color bordC = bull ? i_bullBord : i_bearBord
            color wickC = bull ? i_bullWick : i_bearWick
            if not isLive
                bodyC := color.new(bodyC, 85)
                bordC := color.new(bordC, 60)
                wickC := color.new(wickC, 60)

            // Conviction highlight color
            color hlCol = bull ? i_concBullCol : i_concBearCol
            if not isLive
                hlCol := color.new(hlCol, 50)

            // ── Glow halo (conviction only) ────────────────────────────────────
            if sConv_ and i_showConc
                glw = box.new(startIdx - 1, top, endIdx + 1, bot,
                     border_color = color.new(hlCol, 60),
                     bgcolor      = color.new(hlCol, 88),
                     border_width = i_concBordW)
                array.push(projBoxes, glw)

            // ── Candle body ───────────────────────────────────────────────────
            bx = box.new(startIdx, top, endIdx, bot,
                 bgcolor      = bodyC,
                 border_color = sConv_ and i_showConc ? hlCol : bordC,
                 border_width = sConv_ and i_showConc ? i_concBordW : 1)
            array.push(projBoxes, bx)

            // ── Wicks ─────────────────────────────────────────────────────────
            if sH > top
                wU = line.new(midIdx, sH, midIdx, top, color = wickC, width = 2)
                array.push(projLines, wU)
            if sL < bot
                wD = line.new(midIdx, bot, midIdx, sL, color = wickC, width = 2)
                array.push(projLines, wD)

            // ── Connector lines (live candle only) ────────────────────────────
            if isLive
                dimC  = color.new(bordC, 50)
                oConn = line.new(nz(cS, bar_index), sO, startIdx, sO,
                     color = color.new(color.gray, 50), style = line.style_dashed, width = 1)
                hConn = line.new(bar_index, sH, midIdx, sH,
                     color = dimC, style = line.style_dashed, width = 1)
                lConn = line.new(bar_index, sL, midIdx, sL,
                     color = dimC, style = line.style_dashed, width = 1)
                cConn = line.new(bar_index, sC, endIdx, sC,
                     color = dimC, style = line.style_dashed, width = 1)
                array.push(projLines, oConn)
                array.push(projLines, hConn)
                array.push(projLines, lConn)
                array.push(projLines, cConn)

            // ── TF header label ───────────────────────────────────────────────
            headStr    = isLive ? tfHdr + "\n▶ LIVE" : tfHdr
            color hdrC = isLive ? bordC : color.new(color.gray, 50)
            tLbl = label.new(midIdx, sH, headStr,
                 color = trn, textcolor = hdrC,
                 style = label.style_label_down, size = sz)
            array.push(projLabels, tLbl)

            // ── OHLC price labels ─────────────────────────────────────────────
            if i_projLabels
                color baseC = isLive ? bordC : color.new(bordC, 60)
                color neutC = isLive ? color.silver : color.new(color.silver, 60)
                oLbl = label.new(labelIdx, sO,
                     "O: " + str.tostring(sO, format.mintick),
                     color = trn, textcolor = neutC,
                     style = label.style_label_left, size = sz)
                hLbl = label.new(labelIdx, sH,
                     "H: " + str.tostring(sH, format.mintick),
                     color = trn, textcolor = baseC,
                     style = label.style_label_left, size = sz)
                lLbl = label.new(labelIdx, sL,
                     "L: " + str.tostring(sL, format.mintick),
                     color = trn, textcolor = baseC,
                     style = label.style_label_left, size = sz)
                cLbl = label.new(labelIdx, sC,
                     "C: " + str.tostring(sC, format.mintick),
                     color = trn, textcolor = baseC,
                     style = label.style_label_left, size = sz)
                array.push(projLabels, oLbl)
                array.push(projLabels, hLbl)
                array.push(projLabels, lLbl)
                array.push(projLabels, cLbl)

            // ── Delta label with conviction badge ─────────────────────────────
            if i_projDelta
                color dltC = sD >= 0 ? i_deltaPosCol : i_deltaNegCol
                if not isLive
                    dltC := color.new(dltC, 60)
                if sConv_ and i_showConc
                    dltC := hlCol
                dTxt = "Δ " + formatDelta(sD)
                if sConv_ and i_showConc
                    dTxt += "\n▲ Conviction"
                projPad = math.max((sH - sL) * 0.05, syminfo.mintick * 5)
                dLbl = label.new(midIdx, sL - projPad, dTxt,
                     color = trn, textcolor = dltC,
                     style = label.style_label_up, size = sz)
                array.push(projLabels, dLbl)

// ══════════════════════════════════════════════════════════════════════════════
//  INFO TABLE  (Range · Countdown · O/H/L)
// ══════════════════════════════════════════════════════════════════════════════

var table tbl = table.new(getPos(), 2, 6,
     bgcolor      = color.new(color.black, 85),
     border_color = color.new(color.gray,  50),
     border_width = 1,
     frame_color  = color.new(color.gray,  50),
     frame_width  = 1)

if barstate.islast and not na(cO)
    rng    = htfH - htfL
    rngStr = i_range == "Price" ?
         str.tostring(rng, format.mintick) :
         str.tostring(math.round(rng / syminfo.mintick))

    tfSec   = timeframe.in_seconds(i_tf)
    elapsed = math.max(0.0, (time - htfT) / 1000.0)
    secsL   = math.max(0.0, tfSec - elapsed)
    hh      = math.floor(secsL / 3600)
    mm      = math.floor(secsL % 3600 / 60)
    ss      = math.floor(secsL % 60)
    cdStr   = tfSec < 86400 ?
         pad2(int(hh)) + ":" + pad2(int(mm)) + ":" + pad2(int(ss)) : "—"

    bull   = close >= cO
    dirCol = bull ? color.new(color.green, 0) : color.new(color.red, 0)
    bg2    = color.new(color.black, 70)
    sz     = getSize()

    table.cell(tbl, 0, 0, "PO3°",     text_color = i_txtCol, bgcolor = i_lblCol, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 1, 0, i_tf,       text_color = dirCol,   bgcolor = i_lblCol, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 0, 1, "Range",    text_color = i_txtCol, bgcolor = i_lblCol, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 1, 1, rngStr,     text_color = i_txtCol, bgcolor = bg2,      text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 0, 2, "Close In", text_color = i_txtCol, bgcolor = i_lblCol, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 1, 2, cdStr,      text_color = i_txtCol, bgcolor = bg2,      text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 0, 3, "Open",     text_color = i_txtCol, bgcolor = i_lblCol, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 1, 3, str.tostring(cO,   format.mintick), text_color = i_txtCol, bgcolor = bg2, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 0, 4, "High",     text_color = i_txtCol, bgcolor = i_lblCol, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 1, 4, str.tostring(htfH, format.mintick), text_color = i_txtCol, bgcolor = bg2, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 0, 5, "Low",      text_color = i_txtCol, bgcolor = i_lblCol, text_size = sz, text_halign = text.align_center)
    table.cell(tbl, 1, 5, str.tostring(htfL, format.mintick), text_color = i_txtCol, bgcolor = bg2, text_size = sz, text_halign = text.align_center)
````
