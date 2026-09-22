<!-- tradingview-pine-id: PUB;3e2c43b32b92425382836b5b655f1eac -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# The Beast ICT SMC Master Engine

Source: https://www.tradingview.com/script/1nhJ8buW-The-Beast-ICT-SMC-Master-Engine/

## Description

The Beast — ICT SMC Master Engine
The Beast is a consolidated, all-in-one TradingView indicator that merges eleven separate ICT (Inner Circle Trader) and Smart Money Concepts tools into a single script. Every module can be switched on or off independently, so you can run the full suite or isolate just the pieces you need.
Core Modules
1. Real-Time Multi-Timeframe Standard Deviations
Tracks swing highs and lows across four independently configurable timeframes (default 2m, 15m, 1h, 4h) and projects standard deviation levels above and below each swing, using a customizable list of deviation multiples (e.g. 1.0, -1.0, -2.0, -3.0, etc.). Projections auto-invalidate when price breaks back through the origin swing.
2. Market Structure & Fibonacci OTE
Identifies major swing highs/lows and tags them as HH, HL, LH, or LL. Flags Break of Structure (BOS) and Change of Character (CHoCH) events, detects liquidity sweeps of prior swing highs/lows, and automatically draws an Optimal Trade Entry (OTE) box with individual Fibonacci retracement lines (.50, .62, .705, .786, .85) whenever structure breaks.
3. Benchmark Key Levels & Specific Entries
Plots Previous Day High/Low/Close, Previous Week High/Low, Previous Month High/Low, and Daily/Weekly/Monthly Opens. Also marks the Midnight Open (00:00) and 4:00 AM Open, two levels commonly used as intraday entry references in ICT-style trading.
4. Sessions: Asia, London, NY ORB & RTH
Shades and tracks the high, low, and midpoint of the Asia session, London session, and New York Opening Range (default first 15 minutes, 9:30–9:45). Also highlights Regular Trading Hours (9:30–16:00). All session windows and colors are configurable.
5. Supply & Demand Zones
Detects sharp expansion candles (large range relative to ATR, breaking the prior candle's high/low) and draws supply or demand zones from the candle before the expansion, with an optional open-price reaction line.
6. Order Blocks (Standalone)
Marks the last opposing candle before a structural break as an order block, extending only the closest N blocks (configurable) to live price to avoid clutter.
7. Breaker Blocks (Standalone)
Converts order blocks into breaker blocks once price closes back through them, changing their color scheme to reflect the shift in role, and again only extends the closest N to current price.
8. Master Fair Value Gap & Stacked Imbalance Engine
Detects 3-candle Fair Value Gaps (FVGs) on the execution timeframe, plots a Consequent Encroachment (50% CE) line through each gap, and removes gaps once they're mitigated to a configurable threshold (wick or close-based). Only the closest N active FVGs are extended live.
9. Quad Ehlers SuperSmoother Trend Suite
Four independently configurable SuperSmoother moving averages (fast/medium/slow/trend), each with its own length, timeframe, color, and width — a low-lag alternative to standard moving averages for gauging trend direction.
10. TDA Ladder Dashboard & Confluence
A multi-timeframe bias ladder (default Daily, 4H, 1H, 15m) showing bullish/bearish bias, premium/discount/equilibrium location, and a letter grade (A/B/C) per timeframe. Combines these into a weighted confluence score, and fires an "A+" triangle signal (with alert) when bias, price location, structure, and the lowest timeframe grade all align.
Right-Side Level Labels
All Key Levels and Session levels (module 3 and 4) are rendered together on the right edge of the chart. Each level — PDH, PDL, PDC, session highs/lows/midpoints, periodic opens, etc. — gets its own distinct label. If another level sits close by in price, the label automatically shifts above or below its line so the text stays readable instead of being obscured by thick lines. The vertical offset is adjustable via the "Right-Side Label Positioning" input group.
Alerts
Built-in alert conditions fire on:
Confluence Long A+ / Short A+ signals
Bullish and Bearish structure breaks (BOS/CHoCH)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 2026 jonathanbell1018 - The Beast ICT SMC Master Engine
// The Standard Deviations module is based on "IPDA Standard Deviations [DexterLab x TFO x toodegrees]"
// © toodegrees, tradeforopp (Mozilla Public License 2.0), modified and merged into this script.
// Standard Deviation module merged from IPDA Standard Deviations [DexterLab x TFO x toodegrees] (MPL 2.0)
//@version=6
indicator(
     "The Beast ICT SMC Master Engine",
     shorttitle       = "The Beast",
     overlay          = true,
     max_lines_count = 400,
     max_boxes_count = 300,
     max_labels_count= 400,
     calc_bars_count = 5000)

// ════════════════════
// 00 — MASTER MODULE TOGGLES (100% INDEPENDENT & SEPARATED)
// ════════════════════
string g_MOD = "00 — Master Modules"
enableSDev      = input.bool(true, "1. Multi-TF Standard Deviations (IPDA)", group = g_MOD, tooltip = "Turns the whole Standard Deviations module on/off. When off, none of the deviation ladders in group 01 will draw.")
enableStruct    = input.bool(true, "2. Market Structure & Fib OTE",             group = g_MOD, tooltip = "Turns the whole Market Structure module on/off (HH/HL/LH/LL tags, BOS/CHoCH labels, sweeps, and Fib OTE boxes in group 02).")
enableLevels    = input.bool(true, "3. Key Levels (Red PDH/PDL, Opens, Entries)", group = g_MOD, tooltip = "Turns the whole Key Levels module on/off (PDH/PDL, weekly/monthly highs & lows, daily/weekly/monthly opens, midnight & 4AM entries in group 03).")
enableSessions  = input.bool(true, "4. Sessions (Asia, London, NY ORB, RTH, Power Hour)", group = g_MOD, tooltip = "Turns the whole Sessions module on/off (Asia, London, NY ORB, RTH, and Power Hour boxes & levels in group 04).")
enableSD        = input.bool(true, "5. Supply & Demand Zones",                 group = g_MOD, tooltip = "Turns the whole Supply & Demand Zones module on/off (group 05).")
enableOB        = input.bool(true, "6. Order Blocks (Standalone)",              group = g_MOD, tooltip = "Turns the whole Order Blocks module on/off (group 06). Breaker Blocks are derived from Order Blocks, so this must be on for Breaker Blocks to form.")
enableBreakers  = input.bool(true, "7. Breaker Blocks (Standalone)",            group = g_MOD, tooltip = "Turns Breaker Block coloring/labeling on/off (group 07). An Order Block converts to a Breaker Block once price closes back through it.")
enableFVG       = input.bool(true, "8. Master Fair Value Gap & Stacked Engine", group = g_MOD, tooltip = "Turns the whole Fair Value Gap module on/off (group 08), including any extra timeframe FVGs.")
enableSmooth    = input.bool(true, "9. Quad Ehlers SuperSmoother MAs",          group = g_MOD, tooltip = "Turns the 4 SuperSmoother moving averages on/off (group 09).")
enableTDA       = input.bool(true, "10. TDA Ladder Dashboard & Confluence",     group = g_MOD, tooltip = "Turns the TDA multi-timeframe bias dashboard and A+ confluence triangles on/off (group 10).")
enableSweepTbl  = input.bool(true, "11. Key Level Sweep Status Table",          group = g_MOD, tooltip = "Turns the bottom-left table that tracks whether each key level has been touched today on/off (group 11).")
enableStdCandles = input.bool(true, "12. StDev Candles (colors + arrows)",      group = g_MOD, tooltip = "Turns the StDev Candles module on/off (group 12). Candles change color when they move unusually far compared with recent candles, and an arrow marks the big ones.")

// Helper: Line Style Converter
f_getLineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ════════════════════
// 01 — STANDARD DEVIATIONS (IPDA, ONE TOGGLE PER TIMEFRAME)
// ════════════════════
string g_SD = "Standard Deviations"
string g_TF = "Timeframe Toggles (tick to show, untick to hide)"
sdShow2m        = input.bool(false, "Enable 2m SD",  inline = "sd1", group = g_TF, tooltip = "Standard Deviation ladders built from each completed 2-minute window. Works on any chart timeframe.")
sdColor2m       = input.color(color.yellow, "",      inline = "sd1", group = g_TF)
sdShow5m        = input.bool(false, "Enable 5m SD",  inline = "sd2", group = g_TF)
sdColor5m       = input.color(color.lime, "",        inline = "sd2", group = g_TF)
sdShow15m       = input.bool(true,  "Enable 15m SD", inline = "sd3", group = g_TF)
sdColor15m      = input.color(color.orange, "",      inline = "sd3", group = g_TF)
sdShow30m       = input.bool(false, "Enable 30m SD", inline = "sd4", group = g_TF)
sdColor30m      = input.color(#ff6ec7, "",           inline = "sd4", group = g_TF)
sdShow1h        = input.bool(true,  "Enable 1h SD",  inline = "sd5", group = g_TF)
sdColor1h       = input.color(color.aqua, "",        inline = "sd5", group = g_TF)
sdShow4h        = input.bool(true,  "Enable 4h SD",  inline = "sd6", group = g_TF)
sdColor4h       = input.color(color.fuchsia, "",     inline = "sd6", group = g_TF)
sdShow1d        = input.bool(true,  "Enable 1D SD",  inline = "sd7", group = g_TF, tooltip = "Standard Deviation ladders built from each completed day (the day starts at midnight in the Timezone in group 03). Works on any chart timeframe.")
sdColor1d       = input.color(color.blue, "",        inline = "sd7", group = g_TF)

// Deviation levels: 12 separate slots. Tick the box to draw a level, type its number in the field beside it.
// The 1 and 0 anchor lines (the two ends of the swing) are always drawn, so they are not listed here.
// Negative numbers project beyond the 0 end; values between 0 and 1 sit inside the swing.
sdLv1On         = input.bool(true,  "Level 1",  inline = "lv1",  group = g_SD, tooltip = "Deviation level slots. Tick a box to draw that level and type its number in the field beside it (e.g. -2.5). The 1 and 0 anchor lines are always drawn. Negative numbers project beyond the 0 end.")
sdLv1           = input.float(-1.0,  "", step = 0.25, inline = "lv1",  group = g_SD)
sdLv2On         = input.bool(true,  "Level 2",  inline = "lv2",  group = g_SD)
sdLv2           = input.float(-1.5,  "", step = 0.25, inline = "lv2",  group = g_SD)
sdLv3On         = input.bool(true,  "Level 3",  inline = "lv3",  group = g_SD)
sdLv3           = input.float(-2.0,  "", step = 0.25, inline = "lv3",  group = g_SD)
sdLv4On         = input.bool(true,  "Level 4",  inline = "lv4",  group = g_SD)
sdLv4           = input.float(-2.5,  "", step = 0.25, inline = "lv4",  group = g_SD)
sdLv5On         = input.bool(true,  "Level 5",  inline = "lv5",  group = g_SD)
sdLv5           = input.float(-3.0,  "", step = 0.25, inline = "lv5",  group = g_SD)
sdLv6On         = input.bool(true,  "Level 6",  inline = "lv6",  group = g_SD)
sdLv6           = input.float(-3.25, "", step = 0.25, inline = "lv6",  group = g_SD)
sdLv7On         = input.bool(true,  "Level 7",  inline = "lv7",  group = g_SD)
sdLv7           = input.float(-4.0,  "", step = 0.25, inline = "lv7",  group = g_SD)
sdLv8On         = input.bool(true,  "Level 8",  inline = "lv8",  group = g_SD)
sdLv8           = input.float(-6.0,  "", step = 0.25, inline = "lv8",  group = g_SD)
sdLv9On         = input.bool(false, "Level 9",  inline = "lv9",  group = g_SD)
sdLv9           = input.float(0.5,   "", step = 0.25, inline = "lv9",  group = g_SD)
sdLv10On        = input.bool(false, "Level 10", inline = "lv10", group = g_SD)
sdLv10          = input.float(-5.0,  "", step = 0.25, inline = "lv10", group = g_SD)
sdLv11On        = input.bool(false, "Level 11", inline = "lv11", group = g_SD)
sdLv11          = input.float(-8.0,  "", step = 0.25, inline = "lv11", group = g_SD)
sdLv12On        = input.bool(false, "Level 12", inline = "lv12", group = g_SD)
sdLv12          = input.float(-10.0, "", step = 0.25, inline = "lv12", group = g_SD)

sdShowUp        = input.bool(true,  "Show Upward Projections (from the window low)", group = g_SD)
sdShowDown      = input.bool(true,  "Show Downward Projections (from the window high)", group = g_SD)
sdRemoveInvalidated = input.bool(true, "Remove Deviation Once Invalidated", group = g_SD)
sdLabelSizeIn   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_SD)
sdLabelPos      = input.string("At Live Candle", "Label Position", options = ["At Live Candle", "Staggered Right", "Both"], group = g_SD, tooltip = "At Live Candle: each label sits right next to the newest candle, on its level. Staggered Right: labels sit further right, spaced out by timeframe (the earlier layout). Both: show both sets.")
sdLabelShift    = input.int(-30, "Label Distance from Live Candle (bars, negative = left)", minval = -300, maxval = 50, group = g_SD, tooltip = "Moves every standard deviation label left (negative) or right (positive) of the live candle, measured in bars. Use a more negative number to move them further left, away from the key level and order block labels. Try -30, -45 or -60 until they no longer overlap.")
sdColorMode     = input.string("Dynamic Proximity", "Line Color Mode", options = ["Fixed", "Dynamic Proximity", "Inverted Background"], group = g_SD, tooltip = "Fixed: use the color set for each timeframe above. Dynamic Proximity: each ladder fades from the 'Far' color to the 'Near-Invalidation' color as price approaches its 1.0 anchor. Inverted Background: lines/labels use black or white to match your chart (this is how the original IPDA indicator looks).")
sdDynFarColor   = input.color(color.lime, "Dynamic Proximity: Far Color", group = g_SD)
sdDynNearColor  = input.color(color.black, "Dynamic Proximity: Near-Invalidation Color", group = g_SD)

sdAnchorWidth   = input.int(3, "Anchor Line Width (0 & 1)", minval = 1, maxval = 5, group = g_SD)
sdAnchorStyle   = input.string("Solid", "Anchor Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_SD)
sdProjWidth     = input.int(2, "Projection Line Width", minval = 1, maxval = 5, group = g_SD)
sdProjStyle     = input.string("Solid", "Projection Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_SD)
sdExtendMode    = input.string("Both", "Extend Lines", options = ["Both", "Right", "Off"], group = g_SD, tooltip = "Both: every deviation line runs all the way across the screen. Right: lines start at the swing and run to the right edge. Off: each line only spans the swing it was measured from (this is how the original IPDA indicator looks).")

// ════════════════════
// 02 — MARKET STRUCTURE & FIBONACCI OTE
// ════════════════════
string g_STR = "02 — Structure & Fib OTE"
fibAtrLen       = input.int(14, "ATR Length", minval = 1, group = g_STR, tooltip = "Number of bars used to calculate the ATR that sizes structure-related measurements.")
leftMajor       = input.int(5, "Major Pivot Left", minval = 1, group = g_STR, tooltip = "Bars required to the left of a swing point before it counts as a major high/low. Higher = fewer, more significant pivots.")
rightMajor      = input.int(2, "Major Pivot Right", minval = 1, group = g_STR, tooltip = "Bars required to the right of a swing point before it's confirmed as a major high/low.")
showStructureTags = input.bool(false, "Show HH / HL / LH / LL", group = g_STR, tooltip = "Label each confirmed major swing as Higher High, Higher Low, Lower High, or Lower Low.")
showBreakLabels = input.bool(false, "Show BOS / CHoCH", group = g_STR, tooltip = "Label a Break of Structure (trend continuation) or Change of Character (trend reversal) whenever price closes through the last major swing.")
showSweeps      = input.bool(false, "Show High/Low Sweeps", group = g_STR, tooltip = "Label bars where price wicks beyond a major swing high/low but closes back inside it (a liquidity sweep).")
showFibBoxes    = input.bool(false, "Show Fib Retracement OTE Boxes", group = g_STR, tooltip = "Draw the 62%-78.6% 'Optimal Trade Entry' retracement box after each BOS/CHoCH.")
color62         = input.color(color.blue, ".62 Line", group = g_STR, tooltip = "Color of the 62% retracement edge of the OTE box.")
color705        = input.color(color.lime, ".705 Line", group = g_STR, tooltip = "Fill color used inside the OTE box.")
oteBorderWidth  = input.int(1, "OTE Box Border Width", minval = 1, maxval = 5, group = g_STR, tooltip = "Border thickness of the OTE box.")

// ════════════════════
// 03 — BENCHMARK KEY LEVELS & SPECIFIC ENTRIES (STYLE & THICKNESS)
// ════════════════════
string g_LVL = "03 — Benchmark Key Levels & Specific Entries"
lvlLabelSize    = input.string("Small", "Key Level Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_LVL, tooltip = "Text size for every key level and session label drawn on the right side of the chart.")
lvlLabelOffset  = input.int(20, "Label Distance from Live Bar", minval = 0, maxval = 60, group = g_LVL, tooltip = "How many bars to the right of the live candle the key level labels sit.")
lvlLabelAutoContrast = input.bool(false, "Auto-Contrast Label Text (Black/White)", group = g_LVL, tooltip = "When on, key level and session label text automatically switches between black and white to match your chart's background, instead of always using white.")

showPD          = input.bool(true, "Show Red PDH & PDL (Right-Aligned)", group = g_LVL, tooltip = "Show yesterday's completed high and low as fixed lines. They lock in once the prior day is complete and no longer move.")
colorPD         = input.color(color.red, "Prev Day High/Low Color (RED)", group = g_LVL, tooltip = "Color of the PDH/PDL lines and labels.")
pdLineWidth     = input.int(2, "PDH / PDL Line Width", minval = 1, maxval = 5, group = g_LVL, tooltip = "Line thickness for PDH/PDL.")
pdLineStyle     = input.string("Solid", "PDH / PDL Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_LVL, tooltip = "Line style for PDH/PDL.")

showMidEntry    = input.bool(true, "Show Midnight Entry Line (00:00 Open)", group = g_LVL, tooltip = "Show a fixed line at the opening price of the 00:00 NY hour.")
colMidEntry     = input.color(color.teal, "Midnight Entry Color", group = g_LVL, tooltip = "Color of the Midnight Entry line and label.")
midLineWidth    = input.int(2, "Midnight Entry Line Width", minval = 1, maxval = 5, group = g_LVL, tooltip = "Line thickness for the Midnight Entry line.")
midLineStyle    = input.string("Solid", "Midnight Entry Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_LVL, tooltip = "Line style for the Midnight Entry line.")

show4amEntry    = input.bool(true, "Show 4:00 AM Entry Line (04:00 Open)", group = g_LVL, tooltip = "Show a fixed line at the opening price of the 04:00 NY hour.")
col4amEntry     = input.color(color.purple, "4:00 AM Entry Color", group = g_LVL, tooltip = "Color of the 4:00 AM Entry line and label.")
entry4amWidth   = input.int(2, "4:00 AM Entry Line Width", minval = 1, maxval = 5, group = g_LVL, tooltip = "Line thickness for the 4:00 AM Entry line.")
entry4amStyle   = input.string("Solid", "4:00 AM Entry Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_LVL, tooltip = "Line style for the 4:00 AM Entry line.")

showPW          = input.bool(true, "Show Previous Week Levels (PWH / PWL)", group = g_LVL, tooltip = "Show last week's completed high and low as fixed lines.")
colorPW         = input.color(#4caf50, "Prev Week Color", group = g_LVL, tooltip = "Color of the PWH/PWL lines and labels.")
pwLineWidth     = input.int(2, "PWH / PWL Line Width", minval = 1, maxval = 5, group = g_LVL, tooltip = "Line thickness for PWH/PWL.")
pwLineStyle     = input.string("Solid", "PWH / PWL Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_LVL, tooltip = "Line style for PWH/PWL.")

showPM          = input.bool(true, "Show Previous Month Levels (PMH / PML)", group = g_LVL, tooltip = "Show last month's completed high and low as fixed lines.")
colorPM         = input.color(#ab47bc, "Prev Month Color", group = g_LVL, tooltip = "Color of the PMH/PML lines and labels.")
pmLineWidth     = input.int(2, "PMH / PML Line Width", minval = 1, maxval = 5, group = g_LVL, tooltip = "Line thickness for PMH/PML.")
pmLineStyle     = input.string("Solid", "PMH / PML Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_LVL, tooltip = "Line style for PMH/PML.")

showDO          = input.bool(true, "Show Daily Open", group = g_LVL, tooltip = "Show today's opening price as a fixed line.")
showWO          = input.bool(true, "Show Weekly Open", group = g_LVL, tooltip = "Show this week's opening price as a fixed line.")
showMO          = input.bool(true, "Show Monthly Open", group = g_LVL, tooltip = "Show this month's opening price as a fixed line.")
openLineWidth   = input.int(2, "Periodic Opens Line Width", minval = 1, maxval = 5, group = g_LVL, tooltip = "Line thickness for the Daily/Weekly/Monthly Open lines.")
openLineStyle   = input.string("Solid", "Periodic Opens Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_LVL, tooltip = "Line style for the Daily/Weekly/Monthly Open lines.")
sessTZ          = input.string("America/New_York", "Timezone", group = g_LVL, tooltip = "Timezone used for every session, key level, and entry time calculation in this indicator (e.g. America/New_York, Europe/London).")

// ════════════════════
// 04 — SESSIONS & OPENING RANGE (STYLE & THICKNESS)
// ════════════════════
string g_KZ = "04 — Sessions: Asia, London, NY ORB, RTH & Power Hour"

// Asia
useAsia         = input.bool(true, "Asia Session (10:00 PM - Midnight NY)", group = g_KZ, tooltip = "Track the Asia session high/low/50% and enable the Asia High/Low/50% rows in the sweep table.")
showAsiaBox     = input.bool(true, "Show Asia Shading Box", group = g_KZ, tooltip = "Draw a shaded box behind the price action during the Asia session.")
colAsia         = input.color(#2962ff, "Asia Color", group = g_KZ, tooltip = "Color used for the Asia box, lines, and labels.")
asiaHlWidth     = input.int(2, "Asia High/Low Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the Asia High/Low lines.")
asiaHlStyle     = input.string("Solid", "Asia High/Low Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the Asia High/Low lines.")
asiaMidWidth    = input.int(2, "Asia 50% Mid Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the Asia 50% line.")
asiaMidStyle    = input.string("Solid", "Asia 50% Mid Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the Asia 50% line.")

// London
useLondon       = input.bool(true, "London Session (2:00 AM - 4:00 AM NY)", group = g_KZ, tooltip = "Track the London session high/low/50% and enable the London rows in the sweep table.")
showLondonBox   = input.bool(true, "Show London Shading Box", group = g_KZ, tooltip = "Draw a shaded box behind the price action during the London session.")
colLondon       = input.color(#ff9800, "London Color", group = g_KZ, tooltip = "Color used for the London box, lines, and labels.")
lonHlWidth      = input.int(2, "London High/Low Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the London High/Low lines.")
lonHlStyle      = input.string("Solid", "London High/Low Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the London High/Low lines.")
lonMidWidth     = input.int(2, "London 50% Mid Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the London 50% line.")
lonMidStyle     = input.string("Solid", "London 50% Mid Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the London 50% line.")

// NY ORB
useNYOrb        = input.bool(true, "New York ORB (9:30 AM - 9:45 AM NY)", group = g_KZ, tooltip = "Track the opening 15-minute range of the NY session and enable the ORB rows in the sweep table.")
showOrbBox      = input.bool(true, "Show NY ORB Shading Box", group = g_KZ, tooltip = "Draw a shaded box behind the price action during the NY opening range.")
colNYOrb        = input.color(color.red, "NY ORB Color (RED)", group = g_KZ, tooltip = "Color used for the NY ORB box, lines, and labels.")
nyOrbHlWidth    = input.int(2, "NY ORB High/Low Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the NY ORB High/Low lines.")
nyOrbHlStyle    = input.string("Solid", "NY ORB High/Low Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the NY ORB High/Low lines.")
nyOrbMidWidth   = input.int(2, "NY ORB 50% Mid Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the NY ORB 50% line.")
nyOrbMidStyle   = input.string("Solid", "NY ORB 50% Mid Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the NY ORB 50% line.")

useRTH          = input.bool(true, "RTH Session (9:30 AM - 4:00 PM NY)", group = g_KZ, tooltip = "Track the regular trading hours high/low/50% and enable the NY rows in the sweep table.")
showRTHBox      = input.bool(true, "Show RTH Shading Box", group = g_KZ, tooltip = "Draw a shaded box across the whole regular trading hours session.")
colRTH          = input.color(color.new(color.gray, 90), "RTH Shading Color", group = g_KZ, tooltip = "Fill color of the RTH shading box.")
colNY           = input.color(#8e24aa, "New York (RTH) High/Low/Mid Color", group = g_KZ, tooltip = "Color used for the New York High/Low/50% lines and labels.")
nyHlWidth       = input.int(2, "New York High/Low Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the New York High/Low lines.")
nyHlStyle       = input.string("Solid", "New York High/Low Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the New York High/Low lines.")
nyMidWidth      = input.int(2, "New York 50% Mid Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the New York 50% line.")
nyMidStyle      = input.string("Solid", "New York 50% Mid Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the New York 50% line.")

// Power Hour
usePowerHour       = input.bool(true, "Power Hour Session (3:00 PM - 4:00 PM NY)", group = g_KZ, tooltip = "Track the final hour of the regular session (3-4 PM NY) high/low/50% and enable the Power Hour rows in the sweep table.")
showPowerHourBox    = input.bool(true, "Show Power Hour Shading Box", group = g_KZ, tooltip = "Draw a shaded box behind the price action during Power Hour.")
colPowerHour        = input.color(#f81311, "Power Hour Color", group = g_KZ, tooltip = "Color used for the Power Hour box, lines, and labels.")
phHlWidth           = input.int(2, "Power Hour High/Low Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the Power Hour High/Low lines.")
phHlStyle           = input.string("Solid", "Power Hour High/Low Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the Power Hour High/Low lines.")
phMidWidth          = input.int(2, "Power Hour 50% Mid Width", minval = 1, maxval = 5, group = g_KZ, tooltip = "Line thickness for the Power Hour 50% line.")
phMidStyle          = input.string("Solid", "Power Hour 50% Mid Style", options = ["Solid", "Dashed", "Dotted"], group = g_KZ, tooltip = "Line style for the Power Hour 50% line.")

// ════════════════════
// 05 — SUPPLY & DEMAND ZONES (SEPARATED)
// ════════════════════
string g_SDZ = "05 — Supply & Demand Zones"
showSDOpenLine  = input.bool(true, "Show Base Candle Open Reaction Line", group = g_SDZ, tooltip = "Draw a line at the opening price of the base candle that the expansion move started from.")
sdOpenLineWidth = input.int(2, "SD Open Line Width", minval = 1, maxval = 5, group = g_SDZ, tooltip = "Line thickness for the base candle open line.")
sdOpenLineStyle = input.string("Dotted", "SD Open Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_SDZ, tooltip = "Line style for the base candle open line.")
sdBoxBorderW    = input.int(1, "SD Box Border Width", minval = 1, maxval = 5, group = g_SDZ, tooltip = "Border thickness for Supply/Demand zone boxes.")
maxSDCount      = input.int(3, "Max Active S/D Zones per Side", minval = 1, maxval = 5, group = g_SDZ, tooltip = "How many Supply zones and how many Demand zones to keep on the chart at once; older ones are removed first.")
sdSupplyColor   = input.color(color.new(color.blue, 80), "Supply Fill Color", group = g_SDZ, tooltip = "Fill color for Supply zone boxes.")
sdSupplyBorder  = input.color(color.new(color.maroon, 30), "Supply Border Color", group = g_SDZ, tooltip = "Border color for Supply zone boxes.")
sdDemandColor   = input.color(color.new(#10fa40, 80), "Demand Fill Color", group = g_SDZ, tooltip = "Fill color for Demand zone boxes.")
sdDemandBorder  = input.color(color.new(#10fa40, 30), "Demand Border Color", group = g_SDZ, tooltip = "Border color for Demand zone boxes.")

// ════════════════════
// 06 — ORDER BLOCKS (STANDALONE & SEPARATED)
// ════════════════════
string g_OB = "06 — Order Blocks (Standalone)"
closestOBCount  = input.int(1, "Extend Closest N Order Blocks to Current Price", minval = 1, maxval = 5, group = g_OB, tooltip = "Only the N Order Blocks nearest to the current price (above and below) are extended to the live candle; the rest stay in the past.")
obBorderWidth   = input.int(1, "OB Box Border Width", minval = 1, maxval = 5, group = g_OB, tooltip = "Border thickness for Order Block boxes.")
obMidLineWidth  = input.int(1, "OB Midline Width", minval = 1, maxval = 5, group = g_OB, tooltip = "Line thickness for the midline drawn through each Order Block.")
obMidLineStyle  = input.string("Dotted", "OB Midline Style", options = ["Solid", "Dashed", "Dotted"], group = g_OB, tooltip = "Line style for the Order Block midline.")
obMidLineCol    = input.color(color.gray, "OB Midline Color", group = g_OB, tooltip = "Color of the Order Block midline.")
obBullColor     = input.color(color.new(#169400, 75), "Bullish OB Fill Color", group = g_OB, tooltip = "Fill color for bullish Order Block boxes.")
obBullBorder    = input.color(color.new(color.gray, 70), "Bullish OB Border Color", group = g_OB, tooltip = "Border color for bullish Order Block boxes.")
obBearColor     = input.color(color.new(color.blue, 80), "Bearish OB Fill Color", group = g_OB, tooltip = "Fill color for bearish Order Block boxes.")
obBearBorder    = input.color(color.new(color.gray, 70), "Bearish OB Border Color", group = g_OB, tooltip = "Border color for bearish Order Block boxes.")
ignoreFirstOB   = input.int(0, "Ignore First N Bars (skip early Order Blocks)", minval = 0, group = g_OB, tooltip = "Order Blocks that would form within the first N bars of chart history are skipped. Useful for hiding clutter from the very start of a symbol's available data. Set to 0 to disable.")
showOBLabels    = input.bool(true, "Show Bias + Type Labels on OB/Breaker Blocks", group = g_OB, tooltip = "Label each box with its bias (Bullish/Bearish) and type (Order Block or Breaker Block), e.g. 'Bullish OB'.")
obLabelSize     = input.string("Small", "OB/Breaker Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_OB, tooltip = "Text size for the bias + type labels on Order Blocks and Breaker Blocks.")
obRightExt      = input.int(12, "Order Block / Breaker Column Position (bars right of live candle)", minval = 2, maxval = 60, group = g_OB, tooltip = "Order Block and Breaker Block boxes all end this many bars to the right of the live candle, and their text labels sit at that right edge, so together they form one column. Move it to keep the labels apart from the standard deviation labels (which sit on the left) and the key level labels (Label Distance from Live Bar in group 03). Example layout: standard deviations at -30, order blocks at 12, key levels at 20.")

// ════════════════════
// 07 — BREAKER BLOCKS (STANDALONE & SEPARATED)
// ════════════════════
string g_BB = "07 — Breaker Blocks (Standalone)"
closestBBCount  = input.int(1, "Extend Closest N Breaker Blocks to Current Price", minval = 1, maxval = 5, group = g_BB, tooltip = "Only the N Breaker Blocks nearest to the current price (above and below) are extended to the live candle; the rest stay in the past.")
breakerBorderW  = input.int(1, "Breaker Box Border Width", minval = 1, maxval = 5, group = g_BB, tooltip = "Border thickness for Breaker Block boxes.")
breakerMidWidth = input.int(2, "Breaker Midline Width", minval = 1, maxval = 5, group = g_BB, tooltip = "Line thickness for the midline drawn through each Breaker Block.")
breakerMidStyle = input.string("Dashed", "Breaker Midline Style", options = ["Solid", "Dashed", "Dotted"], group = g_BB, tooltip = "Line style for the Breaker Block midline.")
breakerMidCol   = input.color(color.gray, "Breaker Midline Color", group = g_BB, tooltip = "Color of the Breaker Block midline.")
breakerBullCol  = input.color(color.new(#0cb51a, 75), "Bullish Breaker Fill Color", group = g_BB, tooltip = "Fill color once a bearish Order Block breaks and converts to a bullish Breaker Block.")
breakerBullBrd  = input.color(color.new(#0cb51a, 20), "Bullish Breaker Border Color", group = g_BB, tooltip = "Border color for bullish Breaker Blocks.")
breakerBearCol  = input.color(color.new(color.blue, 75), "Bearish Breaker Fill Color", group = g_BB, tooltip = "Fill color once a bullish Order Block breaks and converts to a bearish Breaker Block.")
breakerBearBrd  = input.color(color.new(#ff5d00, 20), "Bearish Breaker Border Color", group = g_BB, tooltip = "Border color for bearish Breaker Blocks.")

// ════════════════════
// 08 — MASTER FAIR VALUE GAP & STACKED IMBALANCE ENGINE
// ════════════════════
string g_FVG = "08 — Fair Value Gaps (Current & Extra Timeframes)"
showCurrentFVG  = input.bool(true,  "Show Execution TF Fair Value Gaps", group = g_FVG, tooltip = "Plot Fair Value Gaps using the chart's own timeframe.")
closestFVGCount = input.int(1, "Extend Closest N FVGs to Current Price", minval = 1, maxval = 5, group = g_FVG, tooltip = "Only the N Fair Value Gaps nearest to the current price (above and below), per timeframe, are extended to the live candle; the rest stay in the past.")
fvgMitThreshold = input.float(25.0, "Mitigation Threshold % (25%, 50% CE, 100%)", minval = 10.0, maxval = 100.0, step = 5.0, group = g_FVG, tooltip = "How far price must trade back into a gap before it's considered filled/mitigated and removed. 50 = the 50% Consequent Encroachment level, 100 = fully filled.")
fvgMitMode      = input.string("Wick", "Mitigation Detection", options = ["Wick", "Close"], group = g_FVG, tooltip = "Wick: a gap is mitigated as soon as a wick reaches the threshold. Close: a gap is only mitigated once a candle closes past the threshold (more conservative).")
fvgBorderWidth  = input.int(1, "FVG Box Border Width", minval = 1, maxval = 5, group = g_FVG, tooltip = "Border thickness for Fair Value Gap boxes.")
ignoreFirstFVG  = input.int(0, "Ignore First N Bars (skip early FVGs)", minval = 0, group = g_FVG, tooltip = "Fair Value Gaps that would form within the first N bars of chart history are skipped. Useful for hiding clutter from the very start of a symbol's available data. Set to 0 to disable.")
showFVGLabels   = input.bool(true, "Show Bias + Type Labels on FVGs", group = g_FVG, tooltip = "Label each Fair Value Gap box with its bias (Bullish/Bearish), type (FVG), and which timeframe it came from.")

showCE          = input.bool(true, "Show Consequent Encroachment (50% CE) Line", group = g_FVG, tooltip = "Draw a line through the midpoint (50%) of every Fair Value Gap.")
ceLineWidth     = input.int(2, "50% CE Line Width", minval = 1, maxval = 5, group = g_FVG, tooltip = "Line thickness for the 50% CE line.")
ceLineStyle     = input.string("Solid", "50% CE Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_FVG, tooltip = "Line style for the 50% CE line.")
fvgBullColor    = input.color(color.new(#26a69a, 80), "Bullish FVG Fill", group = g_FVG, tooltip = "Fill color for bullish Fair Value Gaps.")
fvgBullBorder   = input.color(color.new(color.blue, 40), "Bullish FVG Border", group = g_FVG, tooltip = "Border color for bullish Fair Value Gaps.")
fvgBearColor    = input.color(color.new(#ef5350, 80), "Bearish FVG Fill", group = g_FVG, tooltip = "Fill color for bearish Fair Value Gaps.")
fvgBearBorder   = input.color(color.new(color.blue, 40), "Bearish FVG Border", group = g_FVG, tooltip = "Border color for bearish Fair Value Gaps.")
fvgStackedColor = input.color(color.new(#ab47bc, 65), "Stacked Overlap Fill", group = g_FVG, tooltip = "Fill color used where multiple Fair Value Gaps overlap (reserved for future stacking visuals).")

// Extra timeframe FVGs
showFVGTF2      = input.bool(false, "Show 2nd Timeframe FVGs", group = g_FVG, tooltip = "Also plot Fair Value Gaps built from a second, independent timeframe (chosen below).")
fvgTF2          = input.timeframe("15", "2nd Timeframe Source", group = g_FVG, tooltip = "Which timeframe to pull the 2nd set of Fair Value Gaps from, e.g. 2, 5, 15, 60, 240, D.")
showFVGTF3      = input.bool(false, "Show 3rd Timeframe FVGs", group = g_FVG, tooltip = "Also plot Fair Value Gaps built from a third, independent timeframe (chosen below).")
fvgTF3          = input.timeframe("60", "3rd Timeframe Source", group = g_FVG, tooltip = "Which timeframe to pull the 3rd set of Fair Value Gaps from, e.g. 2, 5, 15, 60, 240, D.")

// ════════════════════
// 09 — QUAD EHLERS SUPERSMOOTHER TREND SUITE
// ════════════════════
string g_MA = "09 — Quad Ehlers SuperSmoother MAs"
showStatusLine  = input.bool(false, "Show Values in Status Line", group = g_MA, tooltip = "When off, the SuperSmoother MA values are hidden from the indicator's status line / name label at the top of the chart pane (they still plot on the chart itself).")
showSS1         = input.bool(false,  "MA 1 (Fast)",    inline = "ss1", group = g_MA, tooltip = "Plot the fastest SuperSmoother MA.")
lenSS1          = input.int(10,     "",               inline = "ss1", group = g_MA, tooltip = "Length of MA 1.")
tfSS1           = input.timeframe("", "",             inline = "ss1", group = g_MA, tooltip = "Timeframe source for MA 1 (blank = chart's own timeframe).")
colSS1          = input.color(#ffd600, "",            inline = "ss1", group = g_MA, tooltip = "Color of MA 1.")
wSS1            = input.int(2,      "Width",          inline = "ss1", minval = 1, maxval = 5, group = g_MA, tooltip = "Line thickness of MA 1.")

showSS2         = input.bool(true,  "MA 2 (Medium)",  inline = "ss2", group = g_MA, tooltip = "Plot the medium-speed SuperSmoother MA.")
lenSS2          = input.int(20,     "",               inline = "ss2", group = g_MA, tooltip = "Length of MA 2.")
tfSS2           = input.timeframe("", "",             inline = "ss2", group = g_MA, tooltip = "Timeframe source for MA 2 (blank = chart's own timeframe).")
colSS2          = input.color(color.black, "",            inline = "ss2", group = g_MA, tooltip = "Color of MA 2.")
wSS2            = input.int(2,      "Width",          inline = "ss2", minval = 1, maxval = 5, group = g_MA, tooltip = "Line thickness of MA 2.")

showSS3         = input.bool(false,  "MA 3 (Slow)",    inline = "ss3", group = g_MA, tooltip = "Plot the slow SuperSmoother MA.")
lenSS3          = input.int(50,     "",               inline = "ss3", group = g_MA, tooltip = "Length of MA 3.")
tfSS3           = input.timeframe("", "",             inline = "ss3", group = g_MA, tooltip = "Timeframe source for MA 3 (blank = chart's own timeframe).")
colSS3          = input.color(#29b6f6, "",            inline = "ss3", group = g_MA, tooltip = "Color of MA 3.")
wSS3            = input.int(2,      "Width",          inline = "ss3", minval = 1, maxval = 5, group = g_MA, tooltip = "Line thickness of MA 3.")

showSS4         = input.bool(true,  "MA 4 (Trend)",   inline = "ss4", group = g_MA, tooltip = "Plot the slowest, trend-defining SuperSmoother MA.")
lenSS4          = input.int(200,    "",               inline = "ss4", group = g_MA, tooltip = "Length of MA 4.")
tfSS4           = input.timeframe("", "",             inline = "ss4", group = g_MA, tooltip = "Timeframe source for MA 4 (blank = chart's own timeframe).")
colSS4          = input.color(#4c4c4c, "",            inline = "ss4", group = g_MA, tooltip = "Color of MA 4.")
wSS4            = input.int(3,      "Width",          inline = "ss4", minval = 1, maxval = 5, group = g_MA, tooltip = "Line thickness of MA 4.")

// ════════════════════
// 10 — TDA LADDER DASHBOARD & CONFLUENCE
// ════════════════════
string g_TDA = "10 — TDA Dashboard & Confluence"
showTable       = input.bool(true, "Show TDA Status Dashboard", group = g_TDA, tooltip = "Show the multi-timeframe bias/location/grade table.")
tablePos        = input.string("Bottom Right", "Dashboard Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = g_TDA, tooltip = "Corner of the chart the TDA dashboard is anchored to.")
tdaTF1          = input.timeframe("D",   "Ladder TF 1", group = g_TDA, tooltip = "Highest-weighted timeframe in the confluence score.")
tdaTF2          = input.timeframe("240", "Ladder TF 2", group = g_TDA, tooltip = "Second-weighted timeframe in the confluence score.")
tdaTF3          = input.timeframe("60",  "Ladder TF 3", group = g_TDA, tooltip = "Third-weighted timeframe in the confluence score.")
tdaTF4          = input.timeframe("15",  "Ladder TF 4", group = g_TDA, tooltip = "Lowest-weighted timeframe in the confluence score; also gates the A+ signal grade.")
showSignals     = input.bool(true, "Show Confluence A+ Signal Triangles", group = g_TDA, tooltip = "Plot a triangle whenever all timeframes and structure align for a high-grade long or short setup.")

// ════════════════════
// 11 — KEY LEVEL SWEEP STATUS TABLE
// ════════════════════
string g_SWEEP = "11 — Key Level Sweep Status Table"
sweepTablePos      = input.string("Bottom Left", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = g_SWEEP, tooltip = "Corner of the chart the sweep status table is anchored to.")
sweepTableSize      = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_SWEEP, tooltip = "Text size for the sweep status table.")
sweepTouchedBg      = input.color(color.new(color.green, 65), "Touched Background", group = g_SWEEP, tooltip = "Row background color once a level has been touched today.")
sweepTouchedTxt     = input.color(#cecece, "Touched Text", group = g_SWEEP, tooltip = "Row text color once a level has been touched today.")
sweepNotTouchedBg   = input.color(color.new(color.gray, 85), "Not Touched Background", group = g_SWEEP, tooltip = "Row background color while a level has not yet been touched today.")
sweepNotTouchedTxt  = input.color(color.gray, "Not Touched Text", group = g_SWEEP, tooltip = "Row text color while a level has not yet been touched today.")
sweepResetHour1     = input.int(4, "Auto-Reset Hour 1 (NY Time, 0-23)", minval = 0, maxval = 23, group = g_SWEEP, tooltip = "First NY hour each day at which every level resets to 'Not Touched'. Defaults to 4 AM, right before your day session gets going.")
sweepResetHour2     = input.int(18, "Auto-Reset Hour 2 (NY Time, 0-23)", minval = 0, maxval = 23, group = g_SWEEP, tooltip = "Second NY hour each day at which every level resets to 'Not Touched'. Defaults to 6 PM, right after the New York session and Power Hour wrap up.")
sweepManualReset    = input.bool(false, "Manual Reset (check the box, then uncheck it)", group = g_SWEEP, tooltip = "Check this box and then uncheck it to immediately clear the table back to 'Not Touched' for every level, without waiting for the scheduled resets above.")

// ════════════════════
// 12 — STDEV CANDLES (COLORS + ARROWS)
// ════════════════════
string g_SC = "12 — StDev Candles"
scLen        = input.int(20, "SD Period", minval = 2, group = g_SC, tooltip = "How many candles are used to measure normal price dispersion. A shorter period reacts faster to recent price; a longer one is steadier.")
scSens       = input.float(1.0, "Sensitivity", minval = 0.1, maxval = 5.0, step = 0.1, group = g_SC, tooltip = "Higher = more candles get flagged. Lower = only the biggest moves get flagged. 1.0 = the original behavior. Scales all four thresholds below at once.")
scColors     = input.bool(true, "Color Candles by Move Size", group = g_SC, tooltip = "Color each candle by how far its move from the open to the high (up candles) or to the low (down candles) exceeds the thresholds below. Candles under the first threshold get the regular colors.")
scArrows     = input.bool(true, "Show Arrows on Big Candles", group = g_SC, tooltip = "Mark any candle that passes the first threshold with an arrow: up arrow under big up candles, down arrow above big down candles. This marks a big candle that has already printed; it does not predict the next one.")
scArrowStyle = input.string("Arrow", "Arrow Style", options = ["Arrow", "Triangle", "Label"], group = g_SC, tooltip = "Shape used for the arrows: Arrow, Triangle, or Label (a small bubble with a pointer).")
scArrowUpCol = input.color(#00c853, "Up Arrow Color", inline = "sca", group = g_SC, tooltip = "Color of the arrow under big up candles.")
scArrowDnCol = input.color(#ff1744, "Down Arrow Color", inline = "sca", group = g_SC, tooltip = "Color of the arrow above big down candles.")
scUpReg      = input.color(#10fa40, "Regular Up", inline = "scr", group = g_SC, tooltip = "Candle color for normal up candles that don't pass the first threshold.")
scDnReg      = input.color(color.black, "Regular Down", inline = "scr", group = g_SC, tooltip = "Candle color for normal down candles that don't pass the first threshold.")
scMult1      = input.float(1.5, "Level 1 (x SD)", step = 0.05, inline = "sc1", group = g_SC, tooltip = "First threshold, in standard deviations. A candle's move must exceed this to be flagged at all.")
scUp1        = input.color(#32bf8f, "Up", inline = "sc1", group = g_SC, tooltip = "Up candle color at Level 1.")
scDn1        = input.color(#ff2d70, "Down", inline = "sc1", group = g_SC, tooltip = "Down candle color at Level 1.")
scMult2      = input.float(2.0, "Level 2 (x SD)", step = 0.05, inline = "sc2", group = g_SC, tooltip = "Second threshold, in standard deviations.")
scUp2        = input.color(#6bd673, "Up", inline = "sc2", group = g_SC, tooltip = "Up candle color at Level 2.")
scDn2        = input.color(#ff0097, "Down", inline = "sc2", group = g_SC, tooltip = "Down candle color at Level 2.")
scMult3      = input.float(2.5, "Level 3 (x SD)", step = 0.05, inline = "sc3", group = g_SC, tooltip = "Third threshold, in standard deviations.")
scUp3        = input.color(#b0e749, "Up", inline = "sc3", group = g_SC, tooltip = "Up candle color at Level 3.")
scDn3        = input.color(#ff00c8, "Down", inline = "sc3", group = g_SC, tooltip = "Down candle color at Level 3.")
scMult4      = input.float(3.0, "Level 4 (x SD)", step = 0.05, inline = "sc4", group = g_SC, tooltip = "Fourth (strongest) threshold, in standard deviations.")
scUp4        = input.color(#fff000, "Up", inline = "sc4", group = g_SC, tooltip = "Up candle color at Level 4.")
scDn4        = input.color(#ff00ff, "Down", inline = "sc4", group = g_SC, tooltip = "Down candle color at Level 4.")

// ════════════════════
// COMMON HELPERS & UDTs
// ════════════════════
f_getSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

f_getTablePos(string p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Middle Right" ? position.middle_right :
     p == "Bottom Right" ? position.bottom_right :
     p == "Top Left"     ? position.top_left     : position.bottom_left

// Ehlers 2-pole SuperSmoother. Seeded with the source so long lengths don't start from zero.
f_superSmoother(series float src, simple int len) =>
    float a1 = math.exp(-1.414 * math.pi / len)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / len)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    float filt = src
    filt := c1 * (src + nz(src[1], src)) * 0.5 + c2 * nz(filt[1], src) + c3 * nz(filt[2], src)
    filt

// Auto-contrast helper: returns a color that stays readable against the
// current chart background when Inverted/Auto-Contrast modes are enabled.
f_contrastColor(bool useAuto, color fallback) =>
    useAuto ? chart.fg_color : fallback

// Global ATR (evaluated on all bars to avoid CW10002 inside conditional blocks)
float globalAtr14 = ta.atr(14)

// ════════════════════
// MODULE 1 — STANDARD DEVIATIONS (IPDA, one toggle per timeframe)
// ════════════════════
f_getSdExtend(string m) =>
    m == "Both" ? extend.both : m == "Right" ? extend.right : extend.none

string sdExt = f_getSdExtend(sdExtendMode)

// Collects every ticked level slot into one list
f_buildDevs() =>
    array<float> res = array.new_float()
    if sdLv1On
        array.push(res, sdLv1)
    if sdLv2On
        array.push(res, sdLv2)
    if sdLv3On
        array.push(res, sdLv3)
    if sdLv4On
        array.push(res, sdLv4)
    if sdLv5On
        array.push(res, sdLv5)
    if sdLv6On
        array.push(res, sdLv6)
    if sdLv7On
        array.push(res, sdLv7)
    if sdLv8On
        array.push(res, sdLv8)
    if sdLv9On
        array.push(res, sdLv9)
    if sdLv10On
        array.push(res, sdLv10)
    if sdLv11On
        array.push(res, sdLv11)
    if sdLv12On
        array.push(res, sdLv12)
    res

var array<float> parsedDevs = f_buildDevs()

f_maxAbsDev() =>
    float m = 1.0
    if array.size(parsedDevs) > 0
        for i = 0 to array.size(parsedDevs) - 1
            m := math.max(m, math.abs(array.get(parsedDevs, i)))
    m

var float sdMaxAbsDev = f_maxAbsDev()

var array<line>  sdvLines  = array.new_line()
var array<label> sdvLabels = array.new_label()

// ════════════════════
// ENGINE
// Each timeframe is measured from lower-timeframe data (1m for the 2m/5m windows, 5m for 15m and up).
// DOWN ladder: 1.0 = window high, 0.0 = swing low before it. UP ladder: 1.0 = window low, 0.0 = swing high before it.
// Only the last completed window per timeframe is kept, which keeps memory use low.
f_sdEngine(string tf, bool act, bool removeInv) =>
    var float swLoPx = na
    var int   swLoT  = na
    var float swHiPx = na
    var int   swHiT  = na
    var float cH   = na
    var int   cHT  = na
    var float cHS  = na
    var int   cHST = na
    var float cL   = na
    var int   cLT  = na
    var float cLS  = na
    var int   cLST = na
    var float h1   = na
    var int   h1T  = na
    var float hs1  = na
    var int   hs1T = na
    var bool  dw1  = false
    var float l1   = na
    var int   l1T  = na
    var float ls1  = na
    var int   ls1T = na
    var bool  up1  = false

    bool chg    = timeframe.change(tf)
    bool dayChg = hour(time, sessTZ) == 0 and hour(time[1], sessTZ) != 0
    bool newWin = tf == "D" ? dayChg : chg
    bool swLoNow = (low >= low[1] and low[1] < low[2]) or (low > low[1] and low[1] <= low[2])
    bool swHiNow = (high <= high[1] and high[1] > high[2]) or (high < high[1] and high[1] >= high[2])

    if act
        if swLoNow
            swLoPx := low[1]
            swLoT  := time[1]
        if swHiNow
            swHiPx := high[1]
            swHiT  := time[1]

        if newWin
            if not na(cH)
                h1 := cH
                h1T := cHT
                hs1 := cHS
                hs1T := cHST
                dw1 := not na(cHS)
                l1 := cL
                l1T := cLT
                ls1 := cLS
                ls1T := cLST
                up1 := not na(cLS)
            cH := high
            cHT := time
            cHS := na
            cHST := na
            cL := low
            cLT := time
            cLS := na
            cLST := na
        else if not na(cH)
            if high >= cH
                cH := high
                cHT := time
                if not na(swLoPx)
                    cHS := swLoPx
                    cHST := swLoT
            if low <= cL
                cL := low
                cLT := time
                if not na(swHiPx)
                    cLS := swHiPx
                    cLST := swHiT

        if removeInv
            if up1 and low < l1
                up1 := false
            if dw1 and high > h1
                dw1 := false

    // invalid or missing ladders come back as na
    [dw1 ? h1 : na, h1T, dw1 ? hs1 : na, hs1T, up1 ? l1 : na, l1T, up1 ? ls1 : na, ls1T]

// A timeframe that is switched off is requested at the chart's own timeframe, so it costs almost nothing.
[t2_h, t2_hT, t2_hs, t2_hsT, t2_l, t2_lT, t2_ls, t2_lsT] = request.security(syminfo.tickerid, (enableSDev and sdShow2m) ? "1" : timeframe.period, f_sdEngine("2", (enableSDev and sdShow2m), sdRemoveInvalidated))
[t5_h, t5_hT, t5_hs, t5_hsT, t5_l, t5_lT, t5_ls, t5_lsT] = request.security(syminfo.tickerid, (enableSDev and sdShow5m) ? "1" : timeframe.period, f_sdEngine("5", (enableSDev and sdShow5m), sdRemoveInvalidated))
[t15_h, t15_hT, t15_hs, t15_hsT, t15_l, t15_lT, t15_ls, t15_lsT] = request.security(syminfo.tickerid, (enableSDev and sdShow15m) ? "5" : timeframe.period, f_sdEngine("15", (enableSDev and sdShow15m), sdRemoveInvalidated))
[t30_h, t30_hT, t30_hs, t30_hsT, t30_l, t30_lT, t30_ls, t30_lsT] = request.security(syminfo.tickerid, (enableSDev and sdShow30m) ? "5" : timeframe.period, f_sdEngine("30", (enableSDev and sdShow30m), sdRemoveInvalidated))
[t60_h, t60_hT, t60_hs, t60_hsT, t60_l, t60_lT, t60_ls, t60_lsT] = request.security(syminfo.tickerid, (enableSDev and sdShow1h) ? "5" : timeframe.period, f_sdEngine("60", (enableSDev and sdShow1h), sdRemoveInvalidated))
[t240_h, t240_hT, t240_hs, t240_hsT, t240_l, t240_lT, t240_ls, t240_lsT] = request.security(syminfo.tickerid, (enableSDev and sdShow4h) ? "5" : timeframe.period, f_sdEngine("240", (enableSDev and sdShow4h), sdRemoveInvalidated))
[tD_h, tD_hT, tD_hs, tD_hsT, tD_l, tD_lT, tD_ls, tD_lsT] = request.security(syminfo.tickerid, (enableSDev and sdShow1d) ? "5" : timeframe.period, f_sdEngine("D", (enableSDev and sdShow1d), sdRemoveInvalidated))

// Drawing (last bar only)
f_sdColor(color baseCol, float invPx, float extremePx) =>
    color c = baseCol
    if sdColorMode == "Inverted Background"
        c := chart.fg_color
    else if sdColorMode == "Dynamic Proximity"
        float span  = math.abs(extremePx - invPx)
        float dist  = math.abs(close - invPx)
        float ratio = span > 0 ? math.max(0.0, math.min(1.0, 1.0 - (dist / span))) : 0.0
        c := color.from_gradient(ratio, 0.0, 1.0, sdDynFarColor, sdDynNearColor)
    c

f_sdOne(float px, string txt, color c, int wdt, string sty, int t1, int xEnd, int t2, bool segOnly, int lblOff) =>
    line ln = line.new(t1, px, xEnd, px, xloc.bar_time, sdExt, color = c, width = wdt, style = f_getLineStyle(sty))
    array.push(sdvLines, ln)
    if sdLabelPos != "At Live Candle"
        label lb = segOnly ? label.new(t2, px, txt, xloc.bar_time, yloc.price, color = color.new(color.black, 100), style = label.style_label_left, textcolor = c, size = f_getSize(sdLabelSizeIn)) : label.new(bar_index + lblOff + sdLabelShift, px, txt, xloc.bar_index, yloc.price, color = color.new(color.black, 100), style = label.style_label_left, textcolor = c, size = f_getSize(sdLabelSizeIn))
        array.push(sdvLabels, lb)
    if sdLabelPos != "Staggered Right"
        label lbNow = label.new(bar_index + 1 + sdLabelShift, px, txt, xloc.bar_index, yloc.price, color = color.new(color.black, 100), style = label.style_label_left, textcolor = c, size = f_getSize(sdLabelSizeIn))
        array.push(sdvLabels, lbNow)
    0

// anchor = the 1.0 level, zero = the 0.0 level. price(dev) = zero + (anchor - zero) * dev
f_drawSdLadder(bool isUp, float anchor, float zero, int t1, int t2, int idx, string tag, int slot, color baseCol) =>
    color col = f_sdColor(baseCol, anchor, zero - (anchor - zero) * sdMaxAbsDev)
    bool segOnly = sdExtendMode == "Off"
    int  xEnd    = segOnly ? t2 : time
    int  lblOff  = 3 + 5 * slot + 2 * (idx - 1)
    string pre   = tag + (idx > 1 ? "(" + str.tostring(idx) + ")" : "") + (isUp ? "▲ " : "▼ ")
    f_sdOne(anchor, pre + "1", col, sdAnchorWidth, sdAnchorStyle, t1, xEnd, t2, segOnly, lblOff)
    f_sdOne(zero,   pre + "0", color.new(col, 20), math.max(1, sdAnchorWidth - 1), sdAnchorStyle, t1, xEnd, t2, segOnly, lblOff)
    if array.size(parsedDevs) > 0
        for i = 0 to array.size(parsedDevs) - 1
            float d = array.get(parsedDevs, i)
            if d != 0.0 and d != 1.0
                float px = zero + (anchor - zero) * d
                f_sdOne(px, pre + str.tostring(d), color.new(col, 35), sdProjWidth, sdProjStyle, t1, xEnd, t2, segOnly, lblOff)
    0

// Draws the down and/or up ladder of one timeframe's last completed window
f_drawWin(string tag, int slot, color baseCol, float hPx, int hT, float hsPx, int hsT, float lPx, int lT, float lsPx, int lsT) =>
    if sdShowDown and not na(hPx) and not na(hsPx)
        f_drawSdLadder(false, hPx, hsPx, hsT, hT, 1, tag, slot, baseCol)
    if sdShowUp and not na(lPx) and not na(lsPx)
        f_drawSdLadder(true, lPx, lsPx, lsT, lT, 1, tag, slot, baseCol)
    0

if barstate.islast
    while array.size(sdvLines) > 0
        line.delete(array.pop(sdvLines))
    while array.size(sdvLabels) > 0
        label.delete(array.pop(sdvLabels))

    if (enableSDev and sdShow2m)
        f_drawWin("2m", 0, sdColor2m, t2_h, t2_hT, t2_hs, t2_hsT, t2_l, t2_lT, t2_ls, t2_lsT)
    if (enableSDev and sdShow5m)
        f_drawWin("5m", 1, sdColor5m, t5_h, t5_hT, t5_hs, t5_hsT, t5_l, t5_lT, t5_ls, t5_lsT)
    if (enableSDev and sdShow15m)
        f_drawWin("15m", 2, sdColor15m, t15_h, t15_hT, t15_hs, t15_hsT, t15_l, t15_lT, t15_ls, t15_lsT)
    if (enableSDev and sdShow30m)
        f_drawWin("30m", 3, sdColor30m, t30_h, t30_hT, t30_hs, t30_hsT, t30_l, t30_lT, t30_ls, t30_lsT)
    if (enableSDev and sdShow1h)
        f_drawWin("1h", 4, sdColor1h, t60_h, t60_hT, t60_hs, t60_hsT, t60_l, t60_lT, t60_ls, t60_lsT)
    if (enableSDev and sdShow4h)
        f_drawWin("4h", 5, sdColor4h, t240_h, t240_hT, t240_hs, t240_hsT, t240_l, t240_lT, t240_ls, t240_lsT)
    if (enableSDev and sdShow1d)
        f_drawWin("1D", 6, sdColor1d, tD_h, tD_hT, tD_hs, tD_hsT, tD_l, tD_lT, tD_ls, tD_lsT)

// ════════════════════
// MODULE 2 — MARKET STRUCTURE & FIBONACCI OTE
// ════════════════════
float sAtr = ta.atr(fibAtrLen)
float majPH = ta.pivothigh(high, leftMajor, rightMajor)
float majPL = ta.pivotlow(low, leftMajor, rightMajor)

var float lastMajHigh = na
var float lastMajLow  = na
var int   structBias  = 0
var box   oteBox      = na

if enableStruct and not na(majPH)
    int pBar = bar_index - rightMajor
    if showStructureTags
        string tag = not na(lastMajHigh) ? (majPH > lastMajHigh ? "HH" : "LH") : "H"
        label.new(pBar, majPH, tag, style = label.style_label_down, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)
    lastMajHigh := majPH

if enableStruct and not na(majPL)
    int pBar = bar_index - rightMajor
    if showStructureTags
        string tag = not na(lastMajLow) ? (majPL < lastMajLow ? "LL" : "HL") : "L"
        label.new(pBar, majPL, tag, style = label.style_label_up, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)
    lastMajLow := majPL

// A crossover against na is false, so no na() guard is needed. Calling ta.* directly
// (not behind "and") keeps it evaluated on every bar.
bool structBrokeUp = ta.crossover(close, lastMajHigh)
bool structBrokeDn = ta.crossunder(close, lastMajLow)

var int lastMajHighBar = na
var int lastMajLowBar  = na

if enableStruct and not na(majPH)
    lastMajHighBar := bar_index - rightMajor
if enableStruct and not na(majPL)
    lastMajLowBar  := bar_index - rightMajor

if enableStruct and structBrokeUp
    bool isChoch = structBias == -1
    structBias := 1
    if showBreakLabels
        label.new(bar_index, lastMajHigh, isChoch ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(isChoch ? color.orange : color.green, 20), textcolor = color.white, size = size.tiny)
    if showFibBoxes and not na(lastMajLow)
        float diff = lastMajHigh - lastMajLow
        float p62  = lastMajHigh - diff * 0.62
        float p786 = lastMajHigh - diff * 0.786
        box.delete(oteBox)
        int oteStart = na(lastMajLowBar) ? (bar_index - 10) : lastMajLowBar
        oteBox := box.new(oteStart, p62, bar_index + 15, p786, border_color = color.new(color62, 50), border_width = oteBorderWidth, bgcolor = color.new(color705, 85))

if enableStruct and structBrokeDn
    bool isChoch = structBias == 1
    structBias := -1
    if showBreakLabels
        label.new(bar_index, lastMajLow, isChoch ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(isChoch ? color.orange : color.red, 20), textcolor = color.white, size = size.tiny)
    if showFibBoxes and not na(lastMajHigh)
        float diff = lastMajHigh - lastMajLow
        float p62  = lastMajLow + diff * 0.62
        float p786 = lastMajLow + diff * 0.786
        box.delete(oteBox)
        int oteStart = na(lastMajHighBar) ? (bar_index - 10) : lastMajHighBar
        oteBox := box.new(oteStart, p786, bar_index + 15, p62, border_color = color.new(color62, 50), border_width = oteBorderWidth, bgcolor = color.new(color705, 85))

bool sweepHigh = not na(lastMajHigh) and high > lastMajHigh and close <= lastMajHigh
bool sweepLow  = not na(lastMajLow)  and low < lastMajLow  and close >= lastMajLow

if enableStruct and showSweeps
    if sweepHigh
        label.new(bar_index, high, "Sweep High", style = label.style_label_down, color = color.new(color.purple, 30), textcolor = color.white, size = size.tiny)
    if sweepLow
        label.new(bar_index, low, "Sweep Low", style = label.style_label_up, color = color.new(color.purple, 30), textcolor = color.white, size = size.tiny)

// ════════════════════
// MODULE 3 — BENCHMARK KEY LEVELS & SPECIFIC ENTRIES
// ════════════════════
[pdH, pdL, dOpen] = request.security(syminfo.tickerid, "D", [high[1], low[1], open], lookahead = barmerge.lookahead_on)
[pwH, pwL, wOpen] = request.security(syminfo.tickerid, "W", [high[1], low[1], open], lookahead = barmerge.lookahead_on)
[pmH, pmL, mOpen] = request.security(syminfo.tickerid, "M", [high[1], low[1], open], lookahead = barmerge.lookahead_on)


var float midEntryPx = na
var float entry4amPx = na

int nyHour = hour(time, sessTZ)
bool atMidnightNY = nyHour == 0
bool at4amNY       = nyHour == 4

if atMidnightNY and not atMidnightNY[1]
    midEntryPx := open

if at4amNY and not at4amNY[1]
    entry4amPx := open

// ════════════════════
// MODULE 04 — SESSIONS & OPENING RANGE (ASIA, LONDON, NY ORB, RTH, POWER HOUR)
// ════════════════════
f_inSession(string sess) =>
    not na(time(timeframe.period, sess, sessTZ))

tAsia      = f_inSession("2200-0000") // 10:00 PM to Midnight NY
tLondon    = f_inSession("0200-0400") // 2:00 AM to 4:00 AM NY
tNYOrb     = f_inSession("0930-0945") // 9:30 AM to 9:45 AM NY (15m ORB)
tRTH       = f_inSession("0930-1600") // 9:30 AM to 4:00 PM NY
tPowerHour = f_inSession("1500-1600") // 3:00 PM to 4:00 PM NY

type SessionTracker
    float hi
    float lo
    float mid
    box   bShade

var SessionTracker trAsia      = SessionTracker.new(na, na, na, na)
var SessionTracker trLondon    = SessionTracker.new(na, na, na, na)
var SessionTracker trNYOrb     = SessionTracker.new(na, na, na, na)
var SessionTracker trNY        = SessionTracker.new(na, na, na, na)
var SessionTracker trPowerHour = SessionTracker.new(na, na, na, na)

f_updateSessionData(bool inSess, bool wasInSess, SessionTracker tr, color col, bool showBox) =>
    if inSess
        if not wasInSess
            tr.hi := high
            tr.lo := low
            tr.mid := math.avg(high, low)
            box.delete(tr.bShade)
            if showBox
                tr.bShade := box.new(bar_index, high, bar_index + 1, low, bgcolor = color.new(col, 88), border_color = color.new(col, 50))
            float(na)
        else
            tr.hi := math.max(tr.hi, high)
            tr.lo := math.min(tr.lo, low)
            tr.mid := math.avg(tr.hi, tr.lo)
            if not na(tr.bShade)
                box.set_top(tr.bShade, tr.hi)
                box.set_bottom(tr.bShade, tr.lo)
                box.set_right(tr.bShade, bar_index)
            float(na)
    float(na)

if enableSessions
    if useAsia
        f_updateSessionData(tAsia,   tAsia[1],   trAsia,   colAsia,  showAsiaBox)
    if useLondon
        f_updateSessionData(tLondon, tLondon[1], trLondon, colLondon, showLondonBox)
    if useNYOrb
        f_updateSessionData(tNYOrb,  tNYOrb[1],  trNYOrb,  colNYOrb, showOrbBox)
    if useRTH
        f_updateSessionData(tRTH,    tRTH[1],    trNY,     colNY,    false)
    if usePowerHour
        f_updateSessionData(tPowerHour, tPowerHour[1], trPowerHour, colPowerHour, showPowerHourBox)

var box bRTH = na
if enableSessions and useRTH and showRTHBox
    if tRTH and not tRTH[1]
        bRTH := box.new(bar_index, high, bar_index + 1, low, bgcolor = colRTH, border_color = color.new(color.gray, 70), text = "RTH (9:30 - 16:00)", text_color = chart.fg_color, text_size = size.tiny)
        float(na)
    else if tRTH and not na(bRTH)
        box.set_top(bRTH, math.max(box.get_top(bRTH), high))
        box.set_bottom(bRTH, math.min(box.get_bottom(bRTH), low))
        box.set_right(bRTH, bar_index)
        float(na)

// ════════════════════
// MODULE 11 — KEY LEVEL SWEEP STATUS TABLE
// ════════════════════
bool atResetHour1  = hour(time, sessTZ) == sweepResetHour1
bool atResetHour2  = hour(time, sessTZ) == sweepResetHour2
bool newSweepDay1  = atResetHour1 and not atResetHour1[1]
bool newSweepDay2  = atResetHour2 and not atResetHour2[1]
bool manualResetFired = not sweepManualReset and sweepManualReset[1]
bool newSweepDay   = newSweepDay1 or newSweepDay2 or manualResetFired

var bool touchAsiaHi  = false
var bool touchAsiaLo  = false
var bool touchAsiaMid = false
var bool touchLonHi   = false
var bool touchLonLo   = false
var bool touchLonMid  = false
var bool touchOrbHi   = false
var bool touchOrbLo   = false
var bool touchOrbMid  = false
var bool touchPDH     = false
var bool touchPDL     = false
var bool touchNYHi    = false
var bool touchNYLo    = false
var bool touchNYMid   = false
var bool touchPHHi    = false
var bool touchPHLo    = false
var bool touchPHMid   = false

if newSweepDay
    touchAsiaHi  := false
    touchAsiaLo  := false
    touchAsiaMid := false
    touchLonHi   := false
    touchLonLo   := false
    touchLonMid  := false
    touchOrbHi   := false
    touchOrbLo   := false
    touchOrbMid  := false
    touchPDH     := false
    touchPDL     := false
    touchNYHi    := false
    touchNYLo    := false
    touchNYMid   := false
    touchPHHi    := false
    touchPHLo    := false
    touchPHMid   := false

f_touched(float lvl) =>
    not na(lvl) and high >= lvl and low <= lvl

if enableSweepTbl
    if useAsia
        touchAsiaHi  := touchAsiaHi  or f_touched(trAsia.hi)
        touchAsiaLo  := touchAsiaLo  or f_touched(trAsia.lo)
        touchAsiaMid := touchAsiaMid or f_touched(trAsia.mid)
    if useLondon
        touchLonHi   := touchLonHi   or f_touched(trLondon.hi)
        touchLonLo   := touchLonLo   or f_touched(trLondon.lo)
        touchLonMid  := touchLonMid  or f_touched(trLondon.mid)
    if useNYOrb
        touchOrbHi   := touchOrbHi   or f_touched(trNYOrb.hi)
        touchOrbLo   := touchOrbLo   or f_touched(trNYOrb.lo)
        touchOrbMid  := touchOrbMid  or f_touched(trNYOrb.mid)
    if useRTH
        touchNYHi    := touchNYHi    or f_touched(trNY.hi)
        touchNYLo    := touchNYLo    or f_touched(trNY.lo)
        touchNYMid   := touchNYMid   or f_touched(trNY.mid)
    if usePowerHour
        touchPHHi    := touchPHHi    or f_touched(trPowerHour.hi)
        touchPHLo    := touchPHLo    or f_touched(trPowerHour.lo)
        touchPHMid   := touchPHMid   or f_touched(trPowerHour.mid)
    touchPDH := touchPDH or f_touched(pdH)
    touchPDL := touchPDL or f_touched(pdL)

var table sweepTable = table.new(f_getTablePos(sweepTablePos), 2, 18, bgcolor = chart.bg_color, border_color = color.gray, border_width = 1, frame_color = chart.fg_color, frame_width = 1)

f_setSweepRow(table tbl, int r, string nm, bool touched, bool active) =>
    color bg  = not active ? color.new(color.gray, 92) : (touched ? sweepTouchedBg : sweepNotTouchedBg)
    color txC = not active ? color.gray : (touched ? sweepTouchedTxt : sweepNotTouchedTxt)
    table.cell(tbl, 0, r, nm, text_color = txC, text_size = f_getSize(sweepTableSize), bgcolor = bg)
    table.cell(tbl, 1, r, not active ? "n/a" : (touched ? "Touched" : "Not Touched"), text_color = txC, text_size = f_getSize(sweepTableSize), bgcolor = bg)

if barstate.islast and enableSweepTbl
    table.cell(sweepTable, 0, 0, "Level",  text_color = chart.fg_color, text_size = f_getSize(sweepTableSize), bgcolor = chart.bg_color)
    table.cell(sweepTable, 1, 0, "Status", text_color = chart.fg_color, text_size = f_getSize(sweepTableSize), bgcolor = chart.bg_color)

    f_setSweepRow(sweepTable, 1,  "Asia High",   touchAsiaHi,  useAsia)
    f_setSweepRow(sweepTable, 2,  "Asia Low",    touchAsiaLo,  useAsia)
    f_setSweepRow(sweepTable, 3,  "Asia 50%",    touchAsiaMid, useAsia)
    f_setSweepRow(sweepTable, 4,  "London High", touchLonHi,   useLondon)
    f_setSweepRow(sweepTable, 5,  "London Low",  touchLonLo,   useLondon)
    f_setSweepRow(sweepTable, 6,  "London 50%",  touchLonMid,  useLondon)
    f_setSweepRow(sweepTable, 7,  "ORB High",    touchOrbHi,   useNYOrb)
    f_setSweepRow(sweepTable, 8,  "ORB Low",     touchOrbLo,   useNYOrb)
    f_setSweepRow(sweepTable, 9,  "ORB 50%",     touchOrbMid,  useNYOrb)
    f_setSweepRow(sweepTable, 10, "PDH",         touchPDH,     showPD)
    f_setSweepRow(sweepTable, 11, "PDL",         touchPDL,     showPD)
    f_setSweepRow(sweepTable, 12, "NY High",     touchNYHi,    useRTH)
    f_setSweepRow(sweepTable, 13, "NY Low",      touchNYLo,    useRTH)
    f_setSweepRow(sweepTable, 14, "NY 50%",      touchNYMid,   useRTH)
    f_setSweepRow(sweepTable, 15, "Power Hour High", touchPHHi,  usePowerHour)
    f_setSweepRow(sweepTable, 16, "Power Hour Low",  touchPHLo,  usePowerHour)
    f_setSweepRow(sweepTable, 17, "Power Hour 50%",  touchPHMid, usePowerHour)

// ════════════════════
// MASTER DE-OVERLAP & CONFLUENCE LABEL RESOLVER (ZERO OVERLAPPING LABELS)
// ════════════════════
type RightLevel
    float  price
    string txt
    color  col
    int    width
    string styleStr

var line[]  dwmLines  = array.new_line()
var label[] dwmLabels = array.new_label()

if barstate.islast and (enableLevels or enableSessions)
    while array.size(dwmLines) > 0
        line.delete(array.pop(dwmLines))
    while array.size(dwmLabels) > 0
        label.delete(array.pop(dwmLabels))

    array<RightLevel> reg = array.new<RightLevel>()

    if enableLevels
        if showPD and not na(pdH)
            array.push(reg, RightLevel.new(pdH, "PDH", colorPD, pdLineWidth, pdLineStyle))
        if showPD and not na(pdL)
            array.push(reg, RightLevel.new(pdL, "PDL", colorPD, pdLineWidth, pdLineStyle))
        if showMidEntry and not na(midEntryPx)
            array.push(reg, RightLevel.new(midEntryPx, "Midnight Entry", colMidEntry, midLineWidth, midLineStyle))
        if show4amEntry and not na(entry4amPx)
            array.push(reg, RightLevel.new(entry4amPx, "4:00 AM Entry", col4amEntry, entry4amWidth, entry4amStyle))
        if showPW and not na(pwH)
            array.push(reg, RightLevel.new(pwH, "PWH", colorPW, pwLineWidth, pwLineStyle))
        if showPW and not na(pwL)
            array.push(reg, RightLevel.new(pwL, "PWL", colorPW, pwLineWidth, pwLineStyle))
        if showPM and not na(pmH)
            array.push(reg, RightLevel.new(pmH, "PMH", colorPM, pmLineWidth, pmLineStyle))
        if showPM and not na(pmL)
            array.push(reg, RightLevel.new(pmL, "PML", colorPM, pmLineWidth, pmLineStyle))
        if showDO and not na(dOpen)
            array.push(reg, RightLevel.new(dOpen, "D Open", color.blue, openLineWidth, openLineStyle))
        if showWO and not na(wOpen)
            array.push(reg, RightLevel.new(wOpen, "W Open", color.orange, openLineWidth, openLineStyle))
        if showMO and not na(mOpen)
            array.push(reg, RightLevel.new(mOpen, "M Open", color.purple, openLineWidth, openLineStyle))

    if enableSessions
        if useAsia and not na(trAsia.hi)
            array.push(reg, RightLevel.new(trAsia.hi,  "Asia High", colAsia, asiaHlWidth,  asiaHlStyle))
            array.push(reg, RightLevel.new(trAsia.lo,  "Asia Low",  colAsia, asiaHlWidth,  asiaHlStyle))
            array.push(reg, RightLevel.new(trAsia.mid, "Asia 50%",  colAsia, asiaMidWidth, asiaMidStyle))
        if useLondon and not na(trLondon.hi)
            array.push(reg, RightLevel.new(trLondon.hi,  "London High", colLondon, lonHlWidth,  lonHlStyle))
            array.push(reg, RightLevel.new(trLondon.lo,  "London Low",  colLondon, lonHlWidth,  lonHlStyle))
            array.push(reg, RightLevel.new(trLondon.mid, "London 50%",  colLondon, lonMidWidth, lonMidStyle))
        if useNYOrb and not na(trNYOrb.hi)
            array.push(reg, RightLevel.new(trNYOrb.hi,  "NY ORB High", colNYOrb, nyOrbHlWidth,  nyOrbHlStyle))
            array.push(reg, RightLevel.new(trNYOrb.lo,  "NY ORB Low",  colNYOrb, nyOrbHlWidth,  nyOrbHlStyle))
            array.push(reg, RightLevel.new(trNYOrb.mid, "NY ORB 50%",  colNYOrb, nyOrbMidWidth, nyOrbMidStyle))
        if useRTH and not na(trNY.hi)
            array.push(reg, RightLevel.new(trNY.hi,  "NY High", colNY, nyHlWidth,  nyHlStyle))
            array.push(reg, RightLevel.new(trNY.lo,  "NY Low",  colNY, nyHlWidth,  nyHlStyle))
            array.push(reg, RightLevel.new(trNY.mid, "NY 50%",  colNY, nyMidWidth, nyMidStyle))
        if usePowerHour and not na(trPowerHour.hi)
            array.push(reg, RightLevel.new(trPowerHour.hi,  "Power Hour High", colPowerHour, phHlWidth,  phHlStyle))
            array.push(reg, RightLevel.new(trPowerHour.lo,  "Power Hour Low",  colPowerHour, phHlWidth,  phHlStyle))
            array.push(reg, RightLevel.new(trPowerHour.mid, "Power Hour 50%",  colPowerHour, phMidWidth, phMidStyle))

    color lvlTextCol = f_contrastColor(lvlLabelAutoContrast, color.white)
    int nReg = array.size(reg)
    if nReg > 0
        for i = 0 to nReg - 1
            RightLevel baseL = array.get(reg, i)

            string labelTxt = baseL.txt + "  " + str.tostring(baseL.price, format.mintick)

            line l = line.new(bar_index - 10, baseL.price, bar_index + lvlLabelOffset, baseL.price, xloc.bar_index, extend.both, color = baseL.col, width = baseL.width, style = f_getLineStyle(baseL.styleStr))

            label lb = label.new(bar_index + lvlLabelOffset, baseL.price, labelTxt, xloc.bar_index, yloc.price, style = label.style_label_left, color = baseL.col, textcolor = lvlTextCol, size = f_getSize(lvlLabelSize))

            array.push(dwmLines, l)
            array.push(dwmLabels, lb)

// MODULE 05 — SUPPLY & DEMAND ZONES (STANDALONE)
// ════════════════════
var array<box>  sdBoxes = array.new_box()
var array<line> sdLines = array.new_line()

float sdAtr = ta.atr(14)
// Expansion candle = big-body candle that closes beyond the previous (base) candle.
// The zone is drawn on the base candle.
bool expUp = close > open and (close - open) > sdAtr and close[1] < open[1] and close > high[1]
bool expDn = open > close and (open - close) > sdAtr and close[1] > open[1] and close < low[1]

if enableSD
    if expUp
        box b = box.new(bar_index - 1, high[1], bar_index + 12, low[1], bgcolor = sdDemandColor, border_color = sdDemandBorder, border_width = sdBoxBorderW)
        array.push(sdBoxes, b)
        if showSDOpenLine
            line ol = line.new(bar_index - 1, open[1], bar_index + 12, open[1], color = color.teal, width = sdOpenLineWidth, style = f_getLineStyle(sdOpenLineStyle))
            array.push(sdLines, ol)
    if expDn
        box b = box.new(bar_index - 1, high[1], bar_index + 12, low[1], bgcolor = sdSupplyColor, border_color = sdSupplyBorder, border_width = sdBoxBorderW)
        array.push(sdBoxes, b)
        if showSDOpenLine
            line ol = line.new(bar_index - 1, open[1], bar_index + 12, open[1], color = color.maroon, width = sdOpenLineWidth, style = f_getLineStyle(sdOpenLineStyle))
            array.push(sdLines, ol)

    while array.size(sdBoxes) > maxSDCount * 2
        box.delete(array.shift(sdBoxes))
        if showSDOpenLine and array.size(sdLines) > 0
            line.delete(array.shift(sdLines))

// ════════════════════
// MODULE 06 — ORDER BLOCKS & MODULE 07 — BREAKER BLOCKS (STANDALONE)
// ════════════════════
type OBBlock
    box    b
    line   midL
    label  lbl
    float  top
    float  btm
    bool   isBull
    bool   breaker

var array<OBBlock> obList = array.new<OBBlock>()

float obSwingH = ta.pivothigh(high, 5, 2)
float obSwingL = ta.pivotlow(low, 5, 2)
var float obLastH = na
var float obLastL = na
if not na(obSwingH)
    obLastH := obSwingH
if not na(obSwingL)
    obLastL := obSwingL

bool obBrokeH = ta.crossover(close, obLastH)
bool obBrokeL = ta.crossunder(close, obLastL)

bool obPastIgnoreWindow = ignoreFirstOB <= 0 or (bar_index - 2) >= ignoreFirstOB

f_obLabelText(bool isBull, bool isBreaker) =>
    (isBull ? "Bullish " : "Bearish ") + (isBreaker ? "Breaker Block" : "Order Block")

if (enableOB or enableBreakers) and obPastIgnoreWindow
    if obBrokeH
        box b = box.new(bar_index - 2, high, bar_index + obRightExt, low, bgcolor = obBullColor, border_color = obBullBorder, border_width = obBorderWidth)
        line l = line.new(bar_index - 2, math.avg(high, low), bar_index + obRightExt, math.avg(high, low), color = obMidLineCol, width = obMidLineWidth, style = f_getLineStyle(obMidLineStyle))
        label lb = na
        if showOBLabels
            box.set_text(b, f_obLabelText(true, false))
            box.set_text_color(b, obBullBorder)
            box.set_text_size(b, f_getSize(obLabelSize))
            box.set_text_halign(b, text.align_right)
            box.set_text_valign(b, text.align_top)
        array.push(obList, OBBlock.new(b, l, lb, high, low, true, false))
        if array.size(obList) > 30
            OBBlock oldest = array.shift(obList)
            box.delete(oldest.b)
            line.delete(oldest.midL)
            label.delete(oldest.lbl)
    if obBrokeL
        box b = box.new(bar_index - 2, high, bar_index + obRightExt, low, bgcolor = obBearColor, border_color = obBearBorder, border_width = obBorderWidth)
        line l = line.new(bar_index - 2, math.avg(high, low), bar_index + obRightExt, math.avg(high, low), color = obMidLineCol, width = obMidLineWidth, style = f_getLineStyle(obMidLineStyle))
        label lb = na
        if showOBLabels
            box.set_text(b, f_obLabelText(false, false))
            box.set_text_color(b, obBearBorder)
            box.set_text_size(b, f_getSize(obLabelSize))
            box.set_text_halign(b, text.align_right)
            box.set_text_valign(b, text.align_top)
        array.push(obList, OBBlock.new(b, l, lb, high, low, false, false))
        if array.size(obList) > 30
            OBBlock oldest = array.shift(obList)
            box.delete(oldest.b)
            line.delete(oldest.midL)
            label.delete(oldest.lbl)

    if array.size(obList) > 0
        for i = array.size(obList) - 1 to 0
            OBBlock item = array.get(obList, i)
            if not item.breaker
                // A broken bullish OB becomes a BEARISH breaker (and vice versa).
                // item.isBull keeps the ORIGINAL bias so the invalidation logic below still works.
                if item.isBull and close < item.btm
                    item.breaker := true
                    box.set_bgcolor(item.b, breakerBearCol)
                    box.set_border_color(item.b, breakerBearBrd)
                    box.set_border_width(item.b, breakerBorderW)
                    line.set_color(item.midL, breakerMidCol)
                    line.set_style(item.midL, f_getLineStyle(breakerMidStyle))
                    line.set_width(item.midL, breakerMidWidth)
                    if showOBLabels
                        box.set_text(item.b, f_obLabelText(false, true))
                        box.set_text_color(item.b, breakerBearBrd)
                else if not item.isBull and close > item.top
                    item.breaker := true
                    box.set_bgcolor(item.b, breakerBullCol)
                    box.set_border_color(item.b, breakerBullBrd)
                    box.set_border_width(item.b, breakerBorderW)
                    line.set_color(item.midL, breakerMidCol)
                    line.set_style(item.midL, f_getLineStyle(breakerMidStyle))
                    line.set_width(item.midL, breakerMidWidth)
                    if showOBLabels
                        box.set_text(item.b, f_obLabelText(true, true))
                        box.set_text_color(item.b, breakerBullBrd)
            else
                if (item.isBull and close > item.top) or (not item.isBull and close < item.btm)
                    box.delete(item.b)
                    line.delete(item.midL)
                    label.delete(item.lbl)
                    array.remove(obList, i)

if (enableOB or enableBreakers) and barstate.islast and array.size(obList) > 0
    array<int> obAbove = array.new_int()
    array<int> obBelow = array.new_int()
    array<int> bbAbove = array.new_int()
    array<int> bbBelow = array.new_int()

    for i = 0 to array.size(obList) - 1
        OBBlock item = array.get(obList, i)
        float mid = math.avg(item.top, item.btm)
        if not item.breaker
            if mid >= close
                array.push(obAbove, i)
            else
                array.push(obBelow, i)
        else
            if mid >= close
                array.push(bbAbove, i)
            else
                array.push(bbBelow, i)

    for i = 0 to array.size(obList) - 1
        OBBlock item = array.get(obList, i)
        float mid = math.avg(item.top, item.btm)
        float myDist = math.abs(close - mid)
        int rank = 0
        bool showThis = false

        if not item.breaker
            if not enableOB
                box.delete(item.b)
                line.delete(item.midL)
                label.delete(item.lbl)
            else
                if mid >= close
                    for a = 0 to array.size(obAbove) - 1
                        int idx = array.get(obAbove, a)
                        if math.abs(close - math.avg(array.get(obList, idx).top, array.get(obList, idx).btm)) < myDist
                            rank += 1
                else
                    for b = 0 to array.size(obBelow) - 1
                        int idx = array.get(obBelow, b)
                        if math.abs(close - math.avg(array.get(obList, idx).top, array.get(obList, idx).btm)) < myDist
                            rank += 1
                if rank < closestOBCount
                    showThis := true
        else
            if not enableBreakers
                box.delete(item.b)
                line.delete(item.midL)
                label.delete(item.lbl)
            else
                if mid >= close
                    for a = 0 to array.size(bbAbove) - 1
                        int idx = array.get(bbAbove, a)
                        if math.abs(close - math.avg(array.get(obList, idx).top, array.get(obList, idx).btm)) < myDist
                            rank += 1
                else
                    for b = 0 to array.size(bbBelow) - 1
                        int idx = array.get(bbBelow, b)
                        if math.abs(close - math.avg(array.get(obList, idx).top, array.get(obList, idx).btm)) < myDist
                            rank += 1
                if rank < closestBBCount
                    showThis := true

        if showThis
            box.set_right(item.b, bar_index + obRightExt)
            line.set_x2(item.midL, bar_index + obRightExt)
            if not na(item.lbl)
                label.set_x(item.lbl, bar_index + obRightExt)
        else
            box.delete(item.b)
            line.delete(item.midL)
            label.delete(item.lbl)

// ════════════════════
// MODULE 08 — MASTER FAIR VALUE GAP ENGINE (STYLE & EXTENSION)
// ════════════════════
type FvgItem
    box   b
    line  ceLine
    label ceLbl
    label typeLbl
    float top
    float btm
    float ce
    bool  isBull
    int   leftBar
    string priority

var array<FvgItem> activeFvgs    = array.new<FvgItem>()
var array<FvgItem> activeFvgsTF2 = array.new<FvgItem>()
var array<FvgItem> activeFvgsTF3 = array.new<FvgItem>()

bool bullFvg = low  > high[2]
bool bearFvg = high < low[2]

method deleteFvg(FvgItem f) =>
    box.delete(f.b)
    line.delete(f.ceLine)
    label.delete(f.ceLbl)
    label.delete(f.typeLbl)

f_fvgTypeText(bool isBull, string tfTag) =>
    (isBull ? "Bullish FVG" : "Bearish FVG") + (tfTag == "" ? "" : " (" + tfTag + ")")

f_addFvgToArray(array<FvgItem> arr, int leftBar, float top, float btm, bool isBull, string prio, string tfTag, int rightExt) =>
    float ce = math.avg(top, btm)
    box b = box.new(leftBar, top, leftBar + rightExt, btm, bgcolor = isBull ? fvgBullColor : fvgBearColor, border_color = isBull ? fvgBullBorder : fvgBearBorder, border_width = fvgBorderWidth)
    line l = line.new(leftBar, ce, leftBar + rightExt, ce, color = isBull ? color.teal : color.maroon, width = ceLineWidth, style = f_getLineStyle(ceLineStyle))
    label lb = label.new(leftBar + rightExt, ce, prio + " CE", style = label.style_label_left, color = color.new(color.black, 100), textcolor = isBull ? color.teal : color.maroon, size = size.tiny)
    label tlb = na
    if showFVGLabels
        tlb := label.new(leftBar + rightExt, isBull ? btm : top, f_fvgTypeText(isBull, tfTag), style = isBull ? label.style_label_up : label.style_label_down, color = color.new(color.black, 100), textcolor = isBull ? fvgBullBorder : fvgBearBorder, size = size.tiny)
    array.push(arr, FvgItem.new(b, l, lb, tlb, top, btm, ce, isBull, leftBar, prio))

    while array.size(arr) > 15
        FvgItem old = array.shift(arr)
        old.deleteFvg()

bool fvgPastIgnoreWindow = ignoreFirstFVG <= 0 or (bar_index - 2) >= ignoreFirstFVG

if enableFVG and showCurrentFVG and fvgPastIgnoreWindow
    if bullFvg
        f_addFvgToArray(activeFvgs, bar_index - 2, low, high[2], true, "P3", "", 12)
    if bearFvg
        f_addFvgToArray(activeFvgs, bar_index - 2, low[2], high, false, "P3", "", 12)

f_pruneMitigated(array<FvgItem> arr) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            FvgItem item = array.get(arr, i)
            float gapHeight = item.top - item.btm
            float mitThresholdPx = item.isBull ? (item.top - gapHeight * (fvgMitThreshold / 100.0)) : (item.btm + gapHeight * (fvgMitThreshold / 100.0))

            bool mitigated = false
            if fvgMitMode == "Wick"
                mitigated := item.isBull ? (low <= mitThresholdPx) : (high >= mitThresholdPx)
            else
                mitigated := item.isBull ? (close <= mitThresholdPx) : (close >= mitThresholdPx)

            if mitigated
                item.deleteFvg()
                array.remove(arr, i)

if enableFVG
    f_pruneMitigated(activeFvgs)
    if showFVGTF2
        f_pruneMitigated(activeFvgsTF2)
    if showFVGTF3
        f_pruneMitigated(activeFvgsTF3)

f_extendClosest(array<FvgItem> arr, int rightExt) =>
    if array.size(arr) > 0
        array<int> above = array.new_int()
        array<int> below = array.new_int()
        for i = 0 to array.size(arr) - 1
            FvgItem item = array.get(arr, i)
            if item.ce >= close
                array.push(above, i)
            else
                array.push(below, i)

        for i = 0 to array.size(arr) - 1
            FvgItem item = array.get(arr, i)
            int rank = 0
            float myDist = math.abs(close - item.ce)
            if item.ce >= close
                for a = 0 to array.size(above) - 1
                    int idx = array.get(above, a)
                    if math.abs(close - array.get(arr, idx).ce) < myDist
                        rank += 1
            else
                for b = 0 to array.size(below) - 1
                    int idx = array.get(below, b)
                    if math.abs(close - array.get(arr, idx).ce) < myDist
                        rank += 1

            if rank < closestFVGCount
                box.set_right(item.b, bar_index + rightExt)
                line.set_x2(item.ceLine, bar_index + rightExt)
                label.set_x(item.ceLbl, bar_index + rightExt)
                if not na(item.typeLbl)
                    label.set_x(item.typeLbl, bar_index + rightExt)
            else
                box.delete(item.b)
                line.delete(item.ceLine)
                label.delete(item.ceLbl)
                label.delete(item.typeLbl)

if enableFVG and barstate.islast
    f_extendClosest(activeFvgs, 12)
    if showFVGTF2
        f_extendClosest(activeFvgsTF2, 12)
    if showFVGTF3
        f_extendClosest(activeFvgsTF3, 12)

// Higher-timeframe FVGs, non-repainting: read the LAST COMPLETED higher-timeframe bar
// (offset [1]) so a gap only appears once the three candles that form it have closed.
f_htfFvgData(simple string tf) =>
    [lo1, hi3, hi1, lo3, t1] = request.security(syminfo.tickerid, tf, [low[1], high[3], high[1], low[3], time[1]], lookahead = barmerge.lookahead_on)
    [lo1, hi3, hi1, lo3, t1]

[tf2Lo1, tf2Hi3, tf2Hi1, tf2Lo3, tf2T1] = f_htfFvgData(showFVGTF2 ? fvgTF2 : timeframe.period)
[tf3Lo1, tf3Hi3, tf3Hi1, tf3Lo3, tf3T1] = f_htfFvgData(showFVGTF3 ? fvgTF3 : timeframe.period)
bool tf2NewBar = tf2T1 != tf2T1[1]
bool tf3NewBar = tf3T1 != tf3T1[1]

if enableFVG and showFVGTF2 and tf2NewBar and fvgPastIgnoreWindow
    if tf2Lo1 > tf2Hi3
        f_addFvgToArray(activeFvgsTF2, bar_index, tf2Lo1, tf2Hi3, true, "P2", fvgTF2, 12)
    if tf2Hi1 < tf2Lo3
        f_addFvgToArray(activeFvgsTF2, bar_index, tf2Lo3, tf2Hi1, false, "P2", fvgTF2, 12)

if enableFVG and showFVGTF3 and tf3NewBar and fvgPastIgnoreWindow
    if tf3Lo1 > tf3Hi3
        f_addFvgToArray(activeFvgsTF3, bar_index, tf3Lo1, tf3Hi3, true, "P1", fvgTF3, 12)
    if tf3Hi1 < tf3Lo3
        f_addFvgToArray(activeFvgsTF3, bar_index, tf3Lo3, tf3Hi1, false, "P1", fvgTF3, 12)

// ════════════════════
// MODULE 09 — QUAD EHLERS SUPERSMOOTHER TREND SUITE
// ════════════════════
f_getSS(simple int len, simple string tf) =>
    request.security(syminfo.tickerid, tf == "" ? timeframe.period : tf, f_superSmoother(close, len))

ss1 = f_getSS(lenSS1, tfSS1)
ss2 = f_getSS(lenSS2, tfSS2)
ss3 = f_getSS(lenSS3, tfSS3)
ss4 = f_getSS(lenSS4, tfSS4)

ssDisplay = showStatusLine ? display.all : display.pane

plot(enableSmooth and showSS1 ? ss1 : na, "SuperSmoother 1", colSS1, wSS1, display = ssDisplay)
plot(enableSmooth and showSS2 ? ss2 : na, "SuperSmoother 2", colSS2, wSS2, display = ssDisplay)
plot(enableSmooth and showSS3 ? ss3 : na, "SuperSmoother 3", colSS3, wSS3, display = ssDisplay)
plot(enableSmooth and showSS4 ? ss4 : na, "SuperSmoother 4", colSS4, wSS4, display = ssDisplay)

// ════════════════════
// MODULE 10 — TDA LADDER DASHBOARD, CONFLUENCE & ALERTS
// ════════════════════
f_tdaState(int pvtLen) =>
    float ph = ta.pivothigh(high, pvtLen, pvtLen)
    float pl = ta.pivotlow(low, pvtLen, pvtLen)
    var float lph = na
    var float lpl = na
    var int bias = 0
    if not na(ph)
        lph := ph
    if not na(pl)
        lpl := pl
    if not na(lph) and close > lph
        bias := 1
    if not na(lpl) and close < lpl
        bias := -1
    float hi = ta.highest(high, 20)
    float lo = ta.lowest(low, 20)
    float rng = hi - lo
    float pos = rng > 0 ? (close - lo) / rng : 0.5
    string loc = pos < 0.45 ? "Disc" : pos > 0.55 ? "Prem" : "Eq"
    string grade = (bias == 1 and pos < 0.45) or (bias == -1 and pos > 0.55) ? "A" : (bias == 1 and pos > 0.55) or (bias == -1 and pos < 0.45) ? "C" : "B"
    [bias, loc, grade]

[b1, loc1, g1] = request.security(syminfo.tickerid, tdaTF1, f_tdaState(3))
[b2, loc2, g2] = request.security(syminfo.tickerid, tdaTF2, f_tdaState(4))
[b3, loc3, g3] = request.security(syminfo.tickerid, tdaTF3, f_tdaState(5))
[b4, loc4, g4] = request.security(syminfo.tickerid, tdaTF4, f_tdaState(5))

int tdaScore = (b1 * 4 + b2 * 3 + b3 * 2 + b4 * 1) * 10
string alignTxt = tdaScore >= 40 ? "ALIGNED LONG" : tdaScore <= -40 ? "ALIGNED SHORT" : "CONFLICTED"
color alignCol  = tdaScore >= 40 ? color.lime : tdaScore <= -40 ? color.red : color.gray

bool dayGateGreen = close > dOpen
bool dayGateRed   = close < dOpen

bool confLong  = tdaScore >= 40 and dayGateGreen and structBias == 1 and (g4 == "A" or g4 == "B")
bool confShort = tdaScore <= -40 and dayGateRed  and structBias == -1 and (g4 == "A" or g4 == "B")

plotshape(enableTDA and showSignals and confLong and not confLong[1], title = "Confluence Long A+", style = shape.triangleup, location = location.belowbar, color = color.lime, size = size.small, text = "A+ Long")
plotshape(enableTDA and showSignals and confShort and not confShort[1], title = "Confluence Short A+", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small, text = "A+ Short")

var table tdaTable = table.new(f_getTablePos(tablePos), 4, 6, bgcolor = chart.bg_color, border_color = color.gray, border_width = 1, frame_color = chart.fg_color, frame_width = 1)

f_setRow(table tbl, int r, string tf, int b, string loc, string g) =>
    table.cell(tbl, 0, r, tf, text_color = chart.fg_color, text_size = size.small)
    table.cell(tbl, 1, r, b == 1 ? "Bull" : b == -1 ? "Bear" : "-", text_color = b == 1 ? color.lime : b == -1 ? color.red : color.gray, text_size = size.small)
    table.cell(tbl, 2, r, loc, text_color = chart.fg_color, text_size = size.small)
    table.cell(tbl, 3, r, g, text_color = g == "A" ? color.rgb(9, 50, 30) : g == "B" ? color.orange : color.red, text_size = size.small)

if barstate.islast and enableTDA and showTable
    table.cell(tdaTable, 0, 0, "TF",    text_color = chart.fg_color, text_size = size.small)
    table.cell(tdaTable, 1, 0, "Bias",  text_color = chart.fg_color, text_size = size.small)
    table.cell(tdaTable, 2, 0, "Loc",   text_color = chart.fg_color, text_size = size.small)
    table.cell(tdaTable, 3, 0, "Grade", text_color = chart.fg_color, text_size = size.small)

    f_setRow(tdaTable, 1, tdaTF1, b1, loc1, g1)
    f_setRow(tdaTable, 2, tdaTF2, b2, loc2, g2)
    f_setRow(tdaTable, 3, tdaTF3, b3, loc3, g3)
    f_setRow(tdaTable, 4, tdaTF4, b4, loc4, g4)

    table.cell(tdaTable, 0, 5, str.tostring(tdaScore) + "%", text_color = alignCol, text_size = size.small)
    table.cell(tdaTable, 1, 5, alignTxt, text_color = alignCol, text_size = size.small)
    table.merge_cells(tdaTable, 1, 5, 3, 5)

// ════════════════════
// MODULE 12 — STDEV CANDLES (COLORS + ARROWS)
// Candles are measured against how far recent candles moved. A candle whose move from
// the open to its high (up candles) or to its low (down candles) is unusually large gets
// colored by how large it is, and an arrow marks it. This marks a big candle that has
// ALREADY printed on the bar; it is not a prediction. The current candle can change
// color/arrow until it closes.
// ════════════════════
bool scUp   = close > open
bool scDown = open > close

// Standard deviation of the open price over the lookback, scaled by Sensitivity
// (higher Sensitivity = smaller thresholds = more candles flagged)
float scSd     = ta.stdev(open, scLen) / scSens
float scUpMove = high - open
float scDnMove = open - low

float scT1  = scSd * scMult1
float scT2  = scSd * scMult2
float scT3  = scSd * scMult3
float scT4  = scSd * scMult4
float scMin = math.min(math.min(scT1, scT2), math.min(scT3, scT4))

bool scBigUp = scUp   and scUpMove >= scMin
bool scBigDn = scDown and scDnMove >= scMin

color scCandleCol = na
if enableStdCandles and scColors
    if scUp
        scCandleCol := scUpMove >= scT4 ? scUp4 : scUpMove >= scT3 ? scUp3 : scUpMove >= scT2 ? scUp2 : scUpMove >= scT1 ? scUp1 : scUpReg
    else if scDown
        scCandleCol := scDnMove >= scT4 ? scDn4 : scDnMove >= scT3 ? scDn3 : scDnMove >= scT2 ? scDn2 : scDnMove >= scT1 ? scDn1 : scDnReg

barcolor(scCandleCol, title = "StDev Candles")

bool scShowUp = enableStdCandles and scArrows and scBigUp
bool scShowDn = enableStdCandles and scArrows and scBigDn

plotshape(scShowUp and scArrowStyle == "Arrow",    title = "StDev Up Arrow",      style = shape.arrowup,      location = location.belowbar, color = scArrowUpCol, size = size.small)
plotshape(scShowDn and scArrowStyle == "Arrow",    title = "StDev Down Arrow",    style = shape.arrowdown,    location = location.abovebar, color = scArrowDnCol, size = size.small)
plotshape(scShowUp and scArrowStyle == "Triangle", title = "StDev Up Triangle",   style = shape.triangleup,   location = location.belowbar, color = scArrowUpCol, size = size.small)
plotshape(scShowDn and scArrowStyle == "Triangle", title = "StDev Down Triangle", style = shape.triangledown, location = location.abovebar, color = scArrowDnCol, size = size.small)
plotshape(scShowUp and scArrowStyle == "Label",    title = "StDev Up Label",      style = shape.labelup,      location = location.belowbar, color = scArrowUpCol, size = size.small)
plotshape(scShowDn and scArrowStyle == "Label",    title = "StDev Down Label",    style = shape.labeldown,    location = location.abovebar, color = scArrowDnCol, size = size.small)

// ════════════════════
// ALERTS
// ════════════════════
alertcondition(confLong and not confLong[1],   title = "Confluence Long A+",  message = "The Beast: All systems aligned LONG (A+)")
alertcondition(confShort and not confShort[1], title = "Confluence Short A+", message = "The Beast: All systems aligned SHORT (A+)")
alertcondition(structBrokeUp,                  title = "Bullish BOS/CHoCH",   message = "The Beast: Structure broke BULLISH")
alertcondition(structBrokeDn,                  title = "Bearish BOS/CHoCH",   message = "The Beast: Structure broke BEARISH")
alertcondition(enableStdCandles and (scBigUp or scBigDn), title = "StDev Candle Big Move", message = "The Beast: Unusually large candle (StDev Candles)")
````
