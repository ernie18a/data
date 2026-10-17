# Higher Timeframe Levels Toolkit

- url: https://www.tradingview.com/script/KdPJRJ8S-Higher-Timeframe-Levels-Toolkit/
- type: indicator
- pine_id: PUB;411faa46de304318b8fd514160031d74
- version: 1.0

## Description

Combines HTF EMA context, key daily/weekly levels, ADR, FVG/BPR (IFVG) zones, and structural swing/fib tracking in one indicator — terminology drawn from ICT/Smart Money Concepts, built for traders who read multiple timeframes without switching charts or stacking scripts. Every module below can be shown, hidden, and styled independently.

[b]📈 Higher-Timeframe EMAs (5m / 10m / 15m / 1h)[/b]
Up to three EMAs per timeframe, each with its own length, color, and toggle.
Historical Path plots the true HTF-calculated EMA through every bar of history — the real value, not a lower-timeframe approximation — so it steps at each HTF close exactly as it would look on that timeframe.

Smooth HTF EMAs replaces the stepped line with a provisional EMA that glides continuously between HTF closes while still landing on the exact true value at every close — no approximation error, just a cleaner line to read.

Independent line width, style, and right-extension per timeframe group.

[b]🗓️ Previous Day & Weekly OHLC[/b]
Previous day Open/High/Low/Close and Weekly Open/High/Low/(previous) Close, each individually toggleable with its own color. Line width, style, and extension (Right / Left / Both / None) are configurable per group.

[b]📏 Average Daily Range (ADR)[/b]
Plots an ADR band centered on the New York session open (9:30 AM ET, configurable timezone), built from a configurable lookback of prior daily ranges — a quick reference for how much of the day's typical range is left to play with.

[b]🔲 FVG & BPR / IFVG Engine (5m / 15m / 1h)[/b]
Independent Fair Value Gap detection on each timeframe, with:

Compact mode — boxes float at a fixed width on the chart's right edge instead of stretching back to their formation point, keeping price action clean

High-Probability filter — gates detection to FVGs above a minimum tick size where the middle candle's volume exceeds the first candle's, for a stricter signal

Balanced quotas — bullish and bearish zones each get their own max-count limit per timeframe, so a one-sided trend can't crowd out the opposite side's zones

BPR (IFVG) detection — automatically merges a new FVG into a Balanced Price Range when it overlaps an opposing FVG within a configurable candle window

Mitigation tracking — zones are removed once price fills a configurable percentage of them, on either a wick or close basis

Full color, transparency, and border control, split by timeframe and direction

[b]🎯 Swing Structure, Equilibrium & Fib Levels (5m / 15m / 1h)[/b]
Structural swing highs and lows — not a rolling highest/lowest window — confirmed only on closed candles and held until genuinely superseded, so unswept structure doesn't quietly age out from underneath you.

50% (EQ) and 0.786 Fib levels span the current swing range, with the anchor direction flipping automatically to track the more recent extreme

Incoming HH & LL shows the next unswept liquidity level beyond the current swing on both sides at once, with a minimum-gap filter so it always points at a meaningfully distinct level rather than a near-duplicate adjacent pivot

From Candle line mode anchors each level's line at the exact chart-timeframe candle that created it and stretches it precisely to its label — full visual provenance for every level on screen

[b]🏷️ Label System[/b]
Show Price on Labels appends the exact price to every level label
De-stacking automatically shifts overlapping labels sideways so nothing gets hidden behind another

On-Line Labels is an alternate style per group: larger text, no background, sitting directly on its line instead of floating beside it

All higher-timeframe data is pulled through non-repainting request.security calls with no lookahead, and every level updates only once its underlying candle is confirmed. This is a visual context and structure tool, not a signal generator — it doesn't predict direction or issue trade alerts. Use it alongside your own analysis and risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Higher Timeframe Levels and Fibs Toolkit

//@version=6
indicator("Higher Timeframe Levels and Fibs Toolkit", overlay=true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500,
     max_bars_back    = 500)

// ═══════════════════════════════════════════════════════
//  GROUP: Labels
// ═══════════════════════════════════════════════════════
showPriceLbl = input.bool(true, "Show Price on Labels", group="Labels",
     tooltip="Appends the level's price to every right-edge label (EMAs, Previous Day / Weekly OHLC, ADR, NY Open, Swing levels).")
lblDestack   = input.bool(true,  "De-stack Overlapping Labels", group="Labels",
     tooltip="When two or more labels land at nearly the same price, each additional label scoots right so all stay readable.")
lblThrTicks  = input.int(50, "Overlap Threshold (ticks)",  group="Labels", minval=1,
     tooltip="Labels within this many ticks of each other are treated as overlapping. Increase if labels still cover each other at your zoom level.")
lblStagger   = input.int(15,  "Stagger Offset (bars)",      group="Labels", minval=1, maxval=50,
     tooltip="How many bars to the right each overlapping label is shifted.")
lblNudgeF    = input.float(0.1, "On-Line Label Nudge (ATR ×)", group="Labels", minval=0.0, maxval=0.5, step=0.01,
     tooltip="Pulls On-Line style labels down toward their line to close the padding gap. Measured as a fraction of ATR(14) so it scales with the chart. Increase if the text floats too high, decrease if it overlaps the line.")

// ═══════════════════════════════════════════════════════
//  GROUP: EMA Smoothing
// ═══════════════════════════════════════════════════════
emaSmooth = input.bool(true, "Smooth HTF EMAs", group="EMA Smoothing",
     tooltip="Replaces the stepped HTF EMA values with an equivalent-length EMA calculated on the chart's own bars (e.g. a 1h EMA 50 on a 5m chart becomes a 600-length EMA on 5m closes). Converges to the same values at HTF closes but glides smoothly between them. Affects lines, labels, and historical paths. EMAs from a timeframe at or below the chart timeframe are unaffected.")

// ═══════════════════════════════════════════════════════
//  GROUP: 5-Minute EMAs
// ═══════════════════════════════════════════════════════
show5m       = input.bool(true, "Show All 5m EMAs",     group="5-Minute EMAs")
show5m_1     = input.bool(true, "Show 5m EMA 1",        group="5-Minute EMAs", inline="5m1")
ema5m_1_len  = input.int(9,      "Length",               group="5-Minute EMAs", minval=1, inline="5m1")
col5m_1      = input.color(color.new(#00BCD4, 0), "",    group="5-Minute EMAs", inline="5m1")
show5m_2     = input.bool(false, "Show 5m EMA 2",        group="5-Minute EMAs", inline="5m2")
ema5m_2_len  = input.int(21,     "Length",               group="5-Minute EMAs", minval=1, inline="5m2")
col5m_2      = input.color(color.new(#FF5722, 0), "",    group="5-Minute EMAs", inline="5m2")
show5m_3     = input.bool(false, "Show 5m EMA 3",        group="5-Minute EMAs", inline="5m3")
ema5m_3_len  = input.int(50,     "Length",               group="5-Minute EMAs", minval=1, inline="5m3")
col5m_3      = input.color(color.new(#9C27B0, 0), "",    group="5-Minute EMAs", inline="5m3")
ema5m_width  = input.int(1,       "Line Width",           group="5-Minute EMAs",  minval=1, maxval=4, inline="5mstyle")
ema5m_style  = input.string("Solid", "Line Style",        group="5-Minute EMAs",  inline="5mstyle", options=["Solid","Dashed","Dotted"])
ema5m_extend = input.bool(false,   "Extend Right",         group="5-Minute EMAs")
ema5m_path   = input.bool(true,  "Show Historical Path (plotted line)", group="5-Minute EMAs", tooltip="Plots the true HTF EMA value through every bar of history using the actual higher timeframe calculation — not a recalculated approximation. The line will appear stepped since it only updates when the HTF candle closes.")
lblStyle5m   = input.bool(false, "On-Line Labels", group="5-Minute EMAs",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: 10-Minute EMAs
// ═══════════════════════════════════════════════════════
show10m      = input.bool(false, "Show All 10m EMAs",    group="10-Minute EMAs")
show10m_1    = input.bool(false, "Show 10m EMA 1",       group="10-Minute EMAs", inline="10m1")
ema10m_1_len = input.int(8,      "Length",               group="10-Minute EMAs", minval=1, inline="10m1")
col10m_1     = input.color(color.new(#4FC3F7, 0), "",    group="10-Minute EMAs", inline="10m1")
show10m_2    = input.bool(false, "Show 10m EMA 2",       group="10-Minute EMAs", inline="10m2")
ema10m_2_len = input.int(21,     "Length",               group="10-Minute EMAs", minval=1, inline="10m2")
col10m_2     = input.color(color.new(#FFA726, 0), "",    group="10-Minute EMAs", inline="10m2")
show10m_3    = input.bool(false, "Show 10m EMA 3",       group="10-Minute EMAs", inline="10m3")
ema10m_3_len = input.int(50,     "Length",               group="10-Minute EMAs", minval=1, inline="10m3")
col10m_3     = input.color(color.new(#EC407A, 0), "",    group="10-Minute EMAs", inline="10m3")
ema10m_width  = input.int(1,      "Line Width",           group="10-Minute EMAs", minval=1, maxval=4, inline="10mstyle")
ema10m_style  = input.string("Solid", "Line Style",       group="10-Minute EMAs", inline="10mstyle", options=["Solid","Dashed","Dotted"])
ema10m_extend = input.bool(false,  "Extend Right",         group="10-Minute EMAs")
ema10m_path  = input.bool(true,  "Show Historical Path (plotted line)", group="10-Minute EMAs", tooltip="Plots the true HTF EMA value through every bar of history using the actual higher timeframe calculation — not a recalculated approximation. The line will appear stepped since it only updates when the HTF candle closes.")
lblStyle10m  = input.bool(false, "On-Line Labels", group="10-Minute EMAs",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: 15-Minute EMAs
// ═══════════════════════════════════════════════════════
show15m      = input.bool(true,  "Show All 15m EMAs",    group="15-Minute EMAs")
show15m_1    = input.bool(false, "Show 15m EMA 1",       group="15-Minute EMAs", inline="15m1")
ema15m_1_len = input.int(8,      "Length",               group="15-Minute EMAs", minval=1, inline="15m1")
col15m_1     = input.color(color.new(#00E5FF, 0), "",    group="15-Minute EMAs", inline="15m1")
show15m_2    = input.bool(false, "Show 15m EMA 2",       group="15-Minute EMAs", inline="15m2")
ema15m_2_len = input.int(21,     "Length",               group="15-Minute EMAs", minval=1, inline="15m2")
col15m_2     = input.color(color.new(#FF9800, 0), "",    group="15-Minute EMAs", inline="15m2")
show15m_3    = input.bool(true,  "Show 15m EMA 3",       group="15-Minute EMAs", inline="15m3")
ema15m_3_len = input.int(50,     "Length",               group="15-Minute EMAs", minval=1, inline="15m3")
col15m_3     = input.color(color.new(#F44336, 0), "",    group="15-Minute EMAs", inline="15m3")
ema15m_width  = input.int(1,      "Line Width",           group="15-Minute EMAs", minval=1, maxval=4, inline="15mstyle")
ema15m_style  = input.string("Solid", "Line Style",       group="15-Minute EMAs", inline="15mstyle", options=["Solid","Dashed","Dotted"])
ema15m_extend = input.bool(false,  "Extend Right",         group="15-Minute EMAs")
ema15m_path  = input.bool(true,  "Show Historical Path (plotted line)", group="15-Minute EMAs", tooltip="Plots the true HTF EMA value through every bar of history using the actual higher timeframe calculation — not a recalculated approximation. The line will appear stepped since it only updates when the HTF candle closes.")
lblStyle15m  = input.bool(false, "On-Line Labels", group="15-Minute EMAs",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: 1-Hour EMAs
// ═══════════════════════════════════════════════════════
show1h       = input.bool(true,  "Show All 1h EMAs",     group="1-Hour EMAs")
show1h_1     = input.bool(true,  "Show 1h EMA 1",        group="1-Hour EMAs", inline="1h1")
ema1h_1_len  = input.int(8,      "Length",               group="1-Hour EMAs", minval=1, inline="1h1")
col1h_1      = input.color(color.new(#69F0AE, 0), "",    group="1-Hour EMAs", inline="1h1")
show1h_2     = input.bool(false, "Show 1h EMA 2",        group="1-Hour EMAs", inline="1h2")
ema1h_2_len  = input.int(21,     "Length",               group="1-Hour EMAs", minval=1, inline="1h2")
col1h_2      = input.color(color.new(#E040FB, 0), "",    group="1-Hour EMAs", inline="1h2")
show1h_3     = input.bool(true,  "Show 1h EMA 3",        group="1-Hour EMAs", inline="1h3")
ema1h_3_len  = input.int(50,     "Length",               group="1-Hour EMAs", minval=1, inline="1h3")
col1h_3      = input.color(color.new(#FF5722, 0), "",    group="1-Hour EMAs", inline="1h3")
ema1h_width   = input.int(1,      "Line Width",           group="1-Hour EMAs",    minval=1, maxval=4, inline="1hstyle")
ema1h_style   = input.string("Solid", "Line Style",       group="1-Hour EMAs",    inline="1hstyle", options=["Solid","Dashed","Dotted"])
ema1h_extend  = input.bool(true,  "Extend Right",         group="1-Hour EMAs")
ema1h_path   = input.bool(true,  "Show Historical Path (plotted line)", group="1-Hour EMAs", tooltip="Plots the true HTF EMA value through every bar of history using the actual higher timeframe calculation — not a recalculated approximation. The line will appear stepped since it only updates when the HTF candle closes.")
lblStyle1h   = input.bool(false, "On-Line Labels", group="1-Hour EMAs",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: Previous Day Levels
// ═══════════════════════════════════════════════════════
showPD   = input.bool(true,  "Show Previous Day Levels", group="Previous Day OHLC")
showPDO  = input.bool(true,  "Show PDO",                 group="Previous Day OHLC")
showPDH  = input.bool(true, "Show PDH",                 group="Previous Day OHLC")
showPDL  = input.bool(true, "Show PDL",                 group="Previous Day OHLC")
showPDC  = input.bool(true,  "Show PDC",                 group="Previous Day OHLC")
colPDO   = input.color(color.new(#FFEB3B, 0), "PDO Color", group="Previous Day OHLC")
colPDH   = input.color(color.new(#E0E0E0, 0), "PDH Color", group="Previous Day OHLC")
colPDL   = input.color(color.new(#E0E0E0, 0), "PDL Color", group="Previous Day OHLC")
colPDC   = input.color(color.new(#BDBDBD, 0), "PDC Color", group="Previous Day OHLC")
widthPD  = input.int(1,      "PD Line Width",            group="Previous Day OHLC", minval=1, maxval=4)
stylePD  = input.string("Dashed", "PD Line Style",       group="Previous Day OHLC", options=["Solid", "Dashed", "Dotted"])
extendPD = input.string("Both", "Extend Lines",         group="Previous Day OHLC", options=["Right","Left","Both","None"])
lblStylePD   = input.bool(false, "On-Line Labels", group="Previous Day OHLC",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: Weekly Levels
// ═══════════════════════════════════════════════════════
showW   = input.bool(true, "Show Weekly Levels",        group="Weekly OHLC")
showWO  = input.bool(false, "Show Weekly Open",          group="Weekly OHLC")
showWH  = input.bool(true, "Show Weekly High",          group="Weekly OHLC")
showWL  = input.bool(true, "Show Weekly Low",           group="Weekly OHLC")
showWC  = input.bool(false, "Show Weekly Close",         group="Weekly OHLC")
colWO   = input.color(color.new(#FFD54F, 0), "Weekly Open Color",  group="Weekly OHLC")
colWH   = input.color(color.new(#66BB6A, 0), "Weekly High Color",  group="Weekly OHLC")
colWL   = input.color(color.new(#BDBDBD, 0), "Weekly Low Color",   group="Weekly OHLC")
colWC   = input.color(color.new(#90CAF9, 0), "Weekly Close Color", group="Weekly OHLC")
widthW  = input.int(1,      "Weekly Line Width",         group="Weekly OHLC", minval=1, maxval=4)
styleW  = input.string("Dashed", "Weekly Line Style",    group="Weekly OHLC", options=["Solid", "Dashed", "Dotted"])
extendW = input.string("Both", "Extend Lines",          group="Weekly OHLC", options=["Right","Left","Both","None"])
lblStyleW    = input.bool(false, "On-Line Labels", group="Weekly OHLC",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: Average Daily Range (ADR)
// ═══════════════════════════════════════════════════════
showADR      = input.bool(false,   "Show ADR Levels",          group="Average Daily Range")
adrLen       = input.int(14,      "ADR Lookback (days)",      group="Average Daily Range", minval=1, maxval=100)
colADRTop    = input.color(color.new(#FF6B6B, 0),  "ADR Top Color",    group="Average Daily Range")
colADRBtm    = input.color(color.new(#26A69A, 0),  "ADR Bottom Color", group="Average Daily Range")
colADRMid    = input.color(color.new(#BDBDBD, 40), "NY Open Color",    group="Average Daily Range")
widthADR     = input.int(1,       "ADR Line Width",           group="Average Daily Range", minval=1, maxval=4)
styleADR     = input.string("Dashed", "ADR Line Style",       group="Average Daily Range", options=["Solid","Dashed","Dotted"])
extendADR    = input.string("None", "Extend Lines",          group="Average Daily Range", options=["Right","Left","Both","None"])
adrTimezone  = input.string("America/New_York", "Timezone",  group="Average Daily Range")

// ═══════════════════════════════════════════════════════
//  GROUP: FVG / IFVG (BPR) Settings
// ═══════════════════════════════════════════════════════
show5mFVG    = input.bool(true,  "Show 5m FVGs & BPRs",  group="FVG / IFVG (BPR)")
show15mFVG   = input.bool(true,  "Show 15m FVGs & BPRs", group="FVG / IFVG (BPR)")
show1hFVG    = input.bool(false,  "Show 1h FVGs & BPRs",  group="FVG / IFVG (BPR)")
compactMode  = input.bool(true, "Compact Boxes (Float Right)",
     tooltip="When ON: FVG and BPR boxes are drawn as fixed-width boxes floating at the right edge of the chart, instead of stretching back to their formation point. Boxes slide right as new candles form.",
     group="FVG / IFVG (BPR)")
compactWidth = input.int(24, "Compact Box Width (candles)",
     tooltip="How many chart candles wide the floating boxes are when Compact Mode is on.",
     group="FVG / IFVG (BPR)", minval=2, maxval=50)
hpOnly       = input.bool(true, "High Probability FVGs Only", inline="hp",
     tooltip="Only detects FVGs that are at least the minimum size in ticks AND where the middle candle of the 3-candle pattern has higher volume than the first candle. Because this gates detection itself, BPRs will also only form from high-probability FVGs.",
     group="FVG / IFVG (BPR)")
hpMinTicks   = input.int(50,     "Min Ticks",            group="FVG / IFVG (BPR)", inline="hp", minval=1)
fvgCount     = input.int(3,      "Max FVGs per TF",      group="FVG / IFVG (BPR)", minval=1, maxval=10)
bprCount     = input.int(3,      "Max BPRs per TF",      group="FVG / IFVG (BPR)", minval=1, maxval=10)
balanceDirs  = input.bool(true,  "Balance Both Directions",
     tooltip="When ON (strict): each direction keeps its OWN quota — up to Max FVGs/BPRs bullish AND bearish per TF. A new zone can only replace the oldest zone of the SAME direction, so opposite-direction zones are never evicted and survive until mitigated, no matter how old.\nWhen OFF: one shared pool; the oldest zone overall is dropped when the limit is exceeded.",
     group="FVG / IFVG (BPR)")
bprWindow    = input.int(12,     "BPR Candle Window",
     tooltip="Max candles between the original FVG and an opposing FVG for a BPR to form. If the inversion happens after this many candles, the new FVG draws normally and the old FVG is left unchanged.",
     group="FVG / IFVG (BPR)", minval=1, maxval=100)
mitTypeWick  = input.string("Close", "Mitigation Type",   group="FVG / IFVG (BPR)", options=["Wick","Close"]) == "Wick"
mitPct       = input.int(90,     "Mitigation %",         group="FVG / IFVG (BPR)", minval=1, maxval=100, step=10)
// FVG appearance
fvgShowBg    = input.bool(true,   "FVG Background",                group="FVG / IFVG (BPR)", inline="fvgstyle")
fvgBgTransp  = input.int(85,      "Transparency",                  group="FVG / IFVG (BPR)", inline="fvgstyle", minval=0, maxval=100)
fvgShowBorder= input.bool(false,   "FVG Border",                    group="FVG / IFVG (BPR)", inline="fvgstyle")
fvgBorderStyle = input.string(line.style_dotted, "Border Style",   group="FVG / IFVG (BPR)", inline="fvgstyle", options=[line.style_solid, line.style_dotted, line.style_dashed])
// BPR appearance
bprShowBg    = input.bool(true,   "BPR Background",                group="FVG / IFVG (BPR)", inline="bprstyle")
bprBgTransp  = input.int(75,      "Transparency",                  group="FVG / IFVG (BPR)", inline="bprstyle", minval=0, maxval=100)
bprShowBorder= input.bool(true,   "BPR Border",                    group="FVG / IFVG (BPR)", inline="bprstyle")
bprBoxStyle  = input.string(line.style_solid,  "Border Style",     group="FVG / IFVG (BPR)", inline="bprstyle", options=[line.style_solid, line.style_dotted, line.style_dashed])
bull5mCol    = input.color(color.new(#26A69A, 30), "5m Bull FVG/BPR Color",  group="FVG / IFVG (BPR)")
bear5mCol    = input.color(color.new(#EF5350, 30), "5m Bear FVG/BPR Color",  group="FVG / IFVG (BPR)")
bull15mCol   = input.color(color.new(#26A69A, 50), "15m Bull FVG/BPR Color", group="FVG / IFVG (BPR)")
bear15mCol   = input.color(color.new(#EF5350, 50), "15m Bear FVG/BPR Color", group="FVG / IFVG (BPR)")
bull1hCol    = input.color(color.new(#26A69A, 70), "1h Bull FVG/BPR Color",  group="FVG / IFVG (BPR)")
bear1hCol    = input.color(color.new(#EF5350, 70), "1h Bear FVG/BPR Color",  group="FVG / IFVG (BPR)")

// ═══════════════════════════════════════════════════════
//  GROUP: 5-Minute Swings & Fibs
// ═══════════════════════════════════════════════════════
showSw5    = input.bool(true, "Show 5m Swing Levels",   group="5-Minute Swings & Fibs",
     tooltip="Tracks the most recent 5m swing high and swing low — candles whose high/low exceeds N candles on each side. Swings persist until a newer swing forms (they never age out). If price sweeps a swing, the level follows the new extreme until the new swing confirms.")
sw5Len     = input.int(3, "Swing Strength (bars each side)", group="5-Minute Swings & Fibs", minval=1,
     tooltip="How many 5m candles on each side a swing point must exceed. Higher = only larger, more significant swings.")
showSw5H   = input.bool(true,  "Swing High",             group="5-Minute Swings & Fibs", inline="sw5h")
colSw5H    = input.color(color.new(#4CAF50, 0), "",      group="5-Minute Swings & Fibs", inline="sw5h")
widSw5H    = input.int(1, "",                            group="5-Minute Swings & Fibs", inline="sw5h", minval=1, maxval=4)
stySw5H    = input.string("Solid", "",                  group="5-Minute Swings & Fibs", inline="sw5h", options=["Solid","Dashed","Dotted"])
showSw5L   = input.bool(true,  "Swing Low",              group="5-Minute Swings & Fibs", inline="sw5l")
colSw5L    = input.color(color.new(#F44336, 0), "",      group="5-Minute Swings & Fibs", inline="sw5l")
widSw5L    = input.int(1, "",                            group="5-Minute Swings & Fibs", inline="sw5l", minval=1, maxval=4)
stySw5L    = input.string("Solid", "",                  group="5-Minute Swings & Fibs", inline="sw5l", options=["Solid","Dashed","Dotted"])
showSw5EQ  = input.bool(false,  "50% (EQ)",               group="5-Minute Swings & Fibs", inline="sw5e")
colSw5EQ   = input.color(color.new(#FFC107, 0), "",      group="5-Minute Swings & Fibs", inline="sw5e")
widSw5EQ   = input.int(1, "",                            group="5-Minute Swings & Fibs", inline="sw5e", minval=1, maxval=4)
stySw5EQ   = input.string("Solid", "",                  group="5-Minute Swings & Fibs", inline="sw5e", options=["Solid","Dashed","Dotted"])
showSw5F   = input.bool(false,  "0.786 Fib",              group="5-Minute Swings & Fibs", inline="sw5f")
colSw5F    = input.color(color.new(#AB47BC, 0), "",      group="5-Minute Swings & Fibs", inline="sw5f")
widSw5F    = input.int(1, "",                            group="5-Minute Swings & Fibs", inline="sw5f", minval=1, maxval=4)
stySw5F    = input.string("Solid", "",                  group="5-Minute Swings & Fibs", inline="sw5f", options=["Solid","Dashed","Dotted"])
showSw5I  = input.bool(true, "Incoming HH & LL",       group="5-Minute Swings & Fibs", inline="sw5i", tooltip="Shows the NEXT unswept swing level beyond the current one on BOTH sides at once — the next HH overhead and the next LL underneath, regardless of which way price is currently breaking.")
colSw5I   = input.color(color.new(#FFA726, 0), "",      group="5-Minute Swings & Fibs", inline="sw5i")
widSw5I   = input.int(1, "",                            group="5-Minute Swings & Fibs", inline="sw5i", minval=1, maxval=4)
stySw5I   = input.string("Solid", "",                  group="5-Minute Swings & Fibs", inline="sw5i", options=["Solid","Dashed","Dotted"])
gapSw5I   = input.int(70, "Incoming Min Gap (ticks)",  group="5-Minute Swings & Fibs", minval=0,
     tooltip="The next unswept level must be at least this many ticks beyond the current swing to qualify as Incoming. Prevents a nearly-identical nearby pivot from being shown as the target — raise this if Incoming keeps landing right next to the current swing high/low.")
extendSw5  = input.string("Both", "Extend Lines",       group="5-Minute Swings & Fibs", options=["Right","Left","Both","None","From Candle"])
lblStyleSw5  = input.bool(true, "On-Line Labels", group="5-Minute Swings & Fibs",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: 15-Minute Swings & Fibs
// ═══════════════════════════════════════════════════════
showSw15   = input.bool(true, "Show 15m Swing Levels",  group="15-Minute Swings & Fibs",
     tooltip="Tracks the most recent 15m swing high and swing low — candles whose high/low exceeds N candles on each side. Swings persist until a newer swing forms (they never age out). If price sweeps a swing, the level follows the new extreme until the new swing confirms.")
sw15Len    = input.int(3, "Swing Strength (bars each side)", group="15-Minute Swings & Fibs", minval=1,
     tooltip="How many 15m candles on each side a swing point must exceed. Higher = only larger, more significant swings.")
showSw15H  = input.bool(true,  "Swing High",             group="15-Minute Swings & Fibs", inline="sw15h")
colSw15H   = input.color(color.new(#81C784, 0), "",      group="15-Minute Swings & Fibs", inline="sw15h")
widSw15H   = input.int(1, "",                            group="15-Minute Swings & Fibs", inline="sw15h", minval=1, maxval=4)
stySw15H   = input.string("Dotted", "",                  group="15-Minute Swings & Fibs", inline="sw15h", options=["Solid","Dashed","Dotted"])
showSw15L  = input.bool(true,  "Swing Low",              group="15-Minute Swings & Fibs", inline="sw15l")
colSw15L   = input.color(color.new(#E57373, 0), "",      group="15-Minute Swings & Fibs", inline="sw15l")
widSw15L   = input.int(1, "",                            group="15-Minute Swings & Fibs", inline="sw15l", minval=1, maxval=4)
stySw15L   = input.string("Dotted", "",                  group="15-Minute Swings & Fibs", inline="sw15l", options=["Solid","Dashed","Dotted"])
showSw15EQ = input.bool(false,  "50% (EQ)",               group="15-Minute Swings & Fibs", inline="sw15e")
colSw15EQ  = input.color(color.new(#FFD54F, 0), "",      group="15-Minute Swings & Fibs", inline="sw15e")
widSw15EQ  = input.int(1, "",                            group="15-Minute Swings & Fibs", inline="sw15e", minval=1, maxval=4)
stySw15EQ  = input.string("Dotted", "",                  group="15-Minute Swings & Fibs", inline="sw15e", options=["Solid","Dashed","Dotted"])
showSw15F  = input.bool(false,  "0.786 Fib",              group="15-Minute Swings & Fibs", inline="sw15f")
colSw15F   = input.color(color.new(#BA68C8, 0), "",      group="15-Minute Swings & Fibs", inline="sw15f")
widSw15F   = input.int(1, "",                            group="15-Minute Swings & Fibs", inline="sw15f", minval=1, maxval=4)
stySw15F   = input.string("Dotted", "",                  group="15-Minute Swings & Fibs", inline="sw15f", options=["Solid","Dashed","Dotted"])
showSw15I  = input.bool(true, "Incoming HH & LL",       group="15-Minute Swings & Fibs", inline="sw15i", tooltip="Shows the NEXT unswept swing level beyond the current one on BOTH sides at once — the next HH overhead and the next LL underneath, regardless of which way price is currently breaking.")
colSw15I   = input.color(color.new(#FFA726, 0), "",      group="15-Minute Swings & Fibs", inline="sw15i")
widSw15I   = input.int(1, "",                            group="15-Minute Swings & Fibs", inline="sw15i", minval=1, maxval=4)
stySw15I   = input.string("Dotted", "",                  group="15-Minute Swings & Fibs", inline="sw15i", options=["Solid","Dashed","Dotted"])
gapSw15I   = input.int(80, "Incoming Min Gap (ticks)",  group="15-Minute Swings & Fibs", minval=0,
     tooltip="The next unswept level must be at least this many ticks beyond the current swing to qualify as Incoming. Prevents a nearly-identical nearby pivot from being shown as the target — raise this if Incoming keeps landing right next to the current swing high/low.")
extendSw15 = input.string("Both", "Extend Lines",       group="15-Minute Swings & Fibs", options=["Right","Left","Both","None","From Candle"])
lblStyleSw15 = input.bool(true, "On-Line Labels", group="15-Minute Swings & Fibs",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  GROUP: 1-Hour Swings & Fibs
// ═══════════════════════════════════════════════════════
showSw1h   = input.bool(true, "Show 1h Swing Levels",   group="1-Hour Swings & Fibs",
     tooltip="Tracks the most recent 1h swing high and swing low — candles whose high/low exceeds N candles on each side. Swings persist until a newer swing forms (they never age out).")
sw1hLen    = input.int(3, "Swing Strength (bars each side)", group="1-Hour Swings & Fibs", minval=1,
     tooltip="How many 1h candles on each side a swing point must exceed. Higher = only larger, more significant swings.")
showSw1hH  = input.bool(true,  "Swing High",             group="1-Hour Swings & Fibs", inline="sw1hh")
colSw1hH   = input.color(color.new(#2E7D32, 0), "",      group="1-Hour Swings & Fibs", inline="sw1hh")
widSw1hH   = input.int(2, "",                            group="1-Hour Swings & Fibs", inline="sw1hh", minval=1, maxval=4)
stySw1hH   = input.string("Solid", "",                  group="1-Hour Swings & Fibs", inline="sw1hh", options=["Solid","Dashed","Dotted"])
showSw1hL  = input.bool(true,  "Swing Low",              group="1-Hour Swings & Fibs", inline="sw1hl")
colSw1hL   = input.color(color.new(#C62828, 0), "",      group="1-Hour Swings & Fibs", inline="sw1hl")
widSw1hL   = input.int(2, "",                            group="1-Hour Swings & Fibs", inline="sw1hl", minval=1, maxval=4)
stySw1hL   = input.string("Solid", "",                  group="1-Hour Swings & Fibs", inline="sw1hl", options=["Solid","Dashed","Dotted"])
showSw1hEQ = input.bool(true,  "50% (EQ)",               group="1-Hour Swings & Fibs", inline="sw1he")
colSw1hEQ  = input.color(color.new(#FF8F00, 0), "",      group="1-Hour Swings & Fibs", inline="sw1he")
widSw1hEQ  = input.int(1, "",                            group="1-Hour Swings & Fibs", inline="sw1he", minval=1, maxval=4)
stySw1hEQ  = input.string("Dotted", "",                  group="1-Hour Swings & Fibs", inline="sw1he", options=["Solid","Dashed","Dotted"])
showSw1hF  = input.bool(true,  "0.786 Fib",              group="1-Hour Swings & Fibs", inline="sw1hf")
colSw1hF   = input.color(color.new(#6A1B9A, 0), "",      group="1-Hour Swings & Fibs", inline="sw1hf")
widSw1hF   = input.int(1, "",                            group="1-Hour Swings & Fibs", inline="sw1hf", minval=1, maxval=4)
stySw1hF   = input.string("Dotted", "",                  group="1-Hour Swings & Fibs", inline="sw1hf", options=["Solid","Dashed","Dotted"])
showSw1hI  = input.bool(false, "Incoming HH & LL",       group="1-Hour Swings & Fibs", inline="sw1hi", tooltip="Shows the NEXT unswept swing level beyond the current one on BOTH sides at once — the next HH overhead and the next LL underneath, regardless of which way price is currently breaking.")
colSw1hI   = input.color(color.new(#FFA726, 0), "",      group="1-Hour Swings & Fibs", inline="sw1hi")
widSw1hI   = input.int(1, "",                            group="1-Hour Swings & Fibs", inline="sw1hi", minval=1, maxval=4)
stySw1hI   = input.string("Dotted", "",                  group="1-Hour Swings & Fibs", inline="sw1hi", options=["Solid","Dashed","Dotted"])
gapSw1hI   = input.int(100, "Incoming Min Gap (ticks)",  group="1-Hour Swings & Fibs", minval=0,
     tooltip="The next unswept level must be at least this many ticks beyond the current swing to qualify as Incoming. Prevents a nearly-identical nearby pivot from being shown as the target — raise this if Incoming keeps landing right next to the current swing high/low.")
extendSw1h = input.string("Both", "Extend Lines",       group="1-Hour Swings & Fibs", options=["Right","Left","Both","None","From Candle"])
lblStyleSw1h = input.bool(true, "On-Line Labels", group="1-Hour Swings & Fibs",
     tooltip="Alternative label style: no background bubble, larger text, and the label sits on top of its line. With Show Price on Labels enabled, the price stacks on a second line under the name.")

// ═══════════════════════════════════════════════════════
//  HELPERS — EMA / OHLC
// ═══════════════════════════════════════════════════════
lineStyleFromStr(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

extendFromStr(s) =>
    s == "Both" ? extend.both : s == "Left" ? extend.left : s == "Right" ? extend.right : extend.none

// ═══════════════════════════════════════════════════════
//  FETCH EMAs
// ═══════════════════════════════════════════════════════
e5_1  = request.security(syminfo.tickerid, "5",  ta.ema(close, ema5m_1_len),  lookahead=barmerge.lookahead_off)
e5_2  = request.security(syminfo.tickerid, "5",  ta.ema(close, ema5m_2_len),  lookahead=barmerge.lookahead_off)
e5_3  = request.security(syminfo.tickerid, "5",  ta.ema(close, ema5m_3_len),  lookahead=barmerge.lookahead_off)
e10_1 = request.security(syminfo.tickerid, "10", ta.ema(close, ema10m_1_len), lookahead=barmerge.lookahead_off)
e10_2 = request.security(syminfo.tickerid, "10", ta.ema(close, ema10m_2_len), lookahead=barmerge.lookahead_off)
e10_3 = request.security(syminfo.tickerid, "10", ta.ema(close, ema10m_3_len), lookahead=barmerge.lookahead_off)
e15_1 = request.security(syminfo.tickerid, "15", ta.ema(close, ema15m_1_len), lookahead=barmerge.lookahead_off)
e15_2 = request.security(syminfo.tickerid, "15", ta.ema(close, ema15m_2_len), lookahead=barmerge.lookahead_off)
e15_3 = request.security(syminfo.tickerid, "15", ta.ema(close, ema15m_3_len), lookahead=barmerge.lookahead_off)
e1h_1 = request.security(syminfo.tickerid, "60", ta.ema(close, ema1h_1_len),  lookahead=barmerge.lookahead_off)
e1h_2 = request.security(syminfo.tickerid, "60", ta.ema(close, ema1h_2_len),  lookahead=barmerge.lookahead_off)
e1h_3 = request.security(syminfo.tickerid, "60", ta.ema(close, ema1h_3_len),  lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════
//  SMOOTHED HTF EMAs — provisional method (exact)
//  pX = the HTF EMA of the LAST COMPLETED HTF candle,
//  fetched with the non-repainting [1] + lookahead_on
//  idiom. The smooth value on every chart bar is then
//      α·close + (1−α)·pX ,   α = 2/(len+1)
//  — i.e. what the HTF EMA would print if its candle
//  closed right now. Because the current chart close IS
//  the forming HTF close, this EQUALS the true HTF EMA at
//  every HTF close (zero approximation error) and glides
//  correctly between closes.
// ═══════════════════════════════════════════════════════
chartMinF = timeframe.in_seconds() / 60.0
sm5On  = emaSmooth and chartMinF <= 5
sm10On = emaSmooth and chartMinF <= 10
sm15On = emaSmooth and chartMinF <= 15
sm1hOn = emaSmooth and chartMinF <= 60

[p5_1, p5_2, p5_3]    = request.security(syminfo.tickerid, "5",  [ta.ema(close, ema5m_1_len)[1],  ta.ema(close, ema5m_2_len)[1],  ta.ema(close, ema5m_3_len)[1]],  lookahead=barmerge.lookahead_on)
[p10_1, p10_2, p10_3] = request.security(syminfo.tickerid, "10", [ta.ema(close, ema10m_1_len)[1], ta.ema(close, ema10m_2_len)[1], ta.ema(close, ema10m_3_len)[1]], lookahead=barmerge.lookahead_on)
[p15_1, p15_2, p15_3] = request.security(syminfo.tickerid, "15", [ta.ema(close, ema15m_1_len)[1], ta.ema(close, ema15m_2_len)[1], ta.ema(close, ema15m_3_len)[1]], lookahead=barmerge.lookahead_on)
[p1h_1, p1h_2, p1h_3] = request.security(syminfo.tickerid, "60", [ta.ema(close, ema1h_1_len)[1],  ta.ema(close, ema1h_2_len)[1],  ta.ema(close, ema1h_3_len)[1]],  lookahead=barmerge.lookahead_on)

prov(len, ePrev) =>
    a = 2.0 / (len + 1)
    na(ePrev) ? close : a * close + (1.0 - a) * ePrev

s5_1  = prov(ema5m_1_len,  p5_1)
s5_2  = prov(ema5m_2_len,  p5_2)
s5_3  = prov(ema5m_3_len,  p5_3)
s10_1 = prov(ema10m_1_len, p10_1)
s10_2 = prov(ema10m_2_len, p10_2)
s10_3 = prov(ema10m_3_len, p10_3)
s15_1 = prov(ema15m_1_len, p15_1)
s15_2 = prov(ema15m_2_len, p15_2)
s15_3 = prov(ema15m_3_len, p15_3)
s1h_1 = prov(ema1h_1_len,  p1h_1)
s1h_2 = prov(ema1h_2_len,  p1h_2)
s1h_3 = prov(ema1h_3_len,  p1h_3)

// Final EMA values used by lines, labels, and paths
e5_1f  = sm5On  ? s5_1  : e5_1
e5_2f  = sm5On  ? s5_2  : e5_2
e5_3f  = sm5On  ? s5_3  : e5_3
e10_1f = sm10On ? s10_1 : e10_1
e10_2f = sm10On ? s10_2 : e10_2
e10_3f = sm10On ? s10_3 : e10_3
e15_1f = sm15On ? s15_1 : e15_1
e15_2f = sm15On ? s15_2 : e15_2
e15_3f = sm15On ? s15_3 : e15_3
e1h_1f = sm1hOn ? s1h_1 : e1h_1
e1h_2f = sm1hOn ? s1h_2 : e1h_2
e1h_3f = sm1hOn ? s1h_3 : e1h_3

// ═══════════════════════════════════════════════════════
//  PLOT HISTORICAL EMA PATH
//  Raw mode: the true HTF value via request.security —
//  stepped, since it only updates at HTF closes.
//  Smooth mode: the equivalent-length chart-TF EMA drawn
//  as a continuous line.
// ═══════════════════════════════════════════════════════
plot(show5m  and show5m_1  and ema5m_path  and not sm5On  ? e5_1  : na, title="5m EMA 1 Path",  color=col5m_1,  linewidth=ema5m_width,  style=plot.style_stepline)
plot(show5m  and show5m_2  and ema5m_path  and not sm5On  ? e5_2  : na, title="5m EMA 2 Path",  color=col5m_2,  linewidth=ema5m_width,  style=plot.style_stepline)
plot(show5m  and show5m_3  and ema5m_path  and not sm5On  ? e5_3  : na, title="5m EMA 3 Path",  color=col5m_3,  linewidth=ema5m_width,  style=plot.style_stepline)
plot(show5m  and show5m_1  and ema5m_path  and sm5On      ? s5_1  : na, title="5m EMA 1 Smooth",  color=col5m_1,  linewidth=ema5m_width)
plot(show5m  and show5m_2  and ema5m_path  and sm5On      ? s5_2  : na, title="5m EMA 2 Smooth",  color=col5m_2,  linewidth=ema5m_width)
plot(show5m  and show5m_3  and ema5m_path  and sm5On      ? s5_3  : na, title="5m EMA 3 Smooth",  color=col5m_3,  linewidth=ema5m_width)

plot(show10m and show10m_1 and ema10m_path and not sm10On ? e10_1 : na, title="10m EMA 1 Path", color=col10m_1, linewidth=ema10m_width, style=plot.style_stepline)
plot(show10m and show10m_2 and ema10m_path and not sm10On ? e10_2 : na, title="10m EMA 2 Path", color=col10m_2, linewidth=ema10m_width, style=plot.style_stepline)
plot(show10m and show10m_3 and ema10m_path and not sm10On ? e10_3 : na, title="10m EMA 3 Path", color=col10m_3, linewidth=ema10m_width, style=plot.style_stepline)
plot(show10m and show10m_1 and ema10m_path and sm10On     ? s10_1 : na, title="10m EMA 1 Smooth", color=col10m_1, linewidth=ema10m_width)
plot(show10m and show10m_2 and ema10m_path and sm10On     ? s10_2 : na, title="10m EMA 2 Smooth", color=col10m_2, linewidth=ema10m_width)
plot(show10m and show10m_3 and ema10m_path and sm10On     ? s10_3 : na, title="10m EMA 3 Smooth", color=col10m_3, linewidth=ema10m_width)

plot(show15m and show15m_1 and ema15m_path and not sm15On ? e15_1 : na, title="15m EMA 1 Path", color=col15m_1, linewidth=ema15m_width, style=plot.style_stepline)
plot(show15m and show15m_2 and ema15m_path and not sm15On ? e15_2 : na, title="15m EMA 2 Path", color=col15m_2, linewidth=ema15m_width, style=plot.style_stepline)
plot(show15m and show15m_3 and ema15m_path and not sm15On ? e15_3 : na, title="15m EMA 3 Path", color=col15m_3, linewidth=ema15m_width, style=plot.style_stepline)
plot(show15m and show15m_1 and ema15m_path and sm15On     ? s15_1 : na, title="15m EMA 1 Smooth", color=col15m_1, linewidth=ema15m_width)
plot(show15m and show15m_2 and ema15m_path and sm15On     ? s15_2 : na, title="15m EMA 2 Smooth", color=col15m_2, linewidth=ema15m_width)
plot(show15m and show15m_3 and ema15m_path and sm15On     ? s15_3 : na, title="15m EMA 3 Smooth", color=col15m_3, linewidth=ema15m_width)

plot(show1h  and show1h_1  and ema1h_path  and not sm1hOn ? e1h_1 : na, title="1h EMA 1 Path",  color=col1h_1,  linewidth=ema1h_width,  style=plot.style_stepline)
plot(show1h  and show1h_2  and ema1h_path  and not sm1hOn ? e1h_2 : na, title="1h EMA 2 Path",  color=col1h_2,  linewidth=ema1h_width,  style=plot.style_stepline)
plot(show1h  and show1h_3  and ema1h_path  and not sm1hOn ? e1h_3 : na, title="1h EMA 3 Path",  color=col1h_3,  linewidth=ema1h_width,  style=plot.style_stepline)
plot(show1h  and show1h_1  and ema1h_path  and sm1hOn     ? s1h_1 : na, title="1h EMA 1 Smooth",  color=col1h_1,  linewidth=ema1h_width)
plot(show1h  and show1h_2  and ema1h_path  and sm1hOn     ? s1h_2 : na, title="1h EMA 2 Smooth",  color=col1h_2,  linewidth=ema1h_width)
plot(show1h  and show1h_3  and ema1h_path  and sm1hOn     ? s1h_3 : na, title="1h EMA 3 Smooth",  color=col1h_3,  linewidth=ema1h_width)


// ═══════════════════════════════════════════════════════
//  FETCH OHLC LEVELS
// ═══════════════════════════════════════════════════════
pd_o = request.security(syminfo.tickerid, "D", open[1],   lookahead=barmerge.lookahead_off)
pd_h = request.security(syminfo.tickerid, "D", high[1],   lookahead=barmerge.lookahead_off)
pd_l = request.security(syminfo.tickerid, "D", low[1],    lookahead=barmerge.lookahead_off)
pd_c = request.security(syminfo.tickerid, "D", close[1],  lookahead=barmerge.lookahead_off)
cw_o = request.security(syminfo.tickerid, "W", open,      lookahead=barmerge.lookahead_off)
cw_h = request.security(syminfo.tickerid, "W", high,      lookahead=barmerge.lookahead_off)
cw_l = request.security(syminfo.tickerid, "W", low,       lookahead=barmerge.lookahead_off)
cw_c = request.security(syminfo.tickerid, "W", close[1],  lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════
//  EMA & OHLC LABEL HANDLES  (created once, updated every bar)
// ═══════════════════════════════════════════════════════
var label lbl5_1  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl5_2  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl5_3  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl10_1 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl10_2 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl10_3 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl15_1 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl15_2 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl15_3 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl1h_1 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl1h_2 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lbl1h_3 = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)

// ═══════════════════════════════════════════════════════
//  EMA LINE HANDLES  (12 lines, one per EMA)
// ═══════════════════════════════════════════════════════
var line l5m_1  = na
var line l5m_2  = na
var line l5m_3  = na
var line l10m_1 = na
var line l10m_2 = na
var line l10m_3 = na
var line l15m_1 = na
var line l15m_2 = na
var line l15m_3 = na
var line l1h_1  = na
var line l1h_2  = na
var line l1h_3  = na
var label lblPDO  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblPDH  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblPDL  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblPDC  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblWO   = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblWH   = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblWL   = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblWC   = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)

// ═══════════════════════════════════════════════════════
//  OHLC LINE HANDLES
// ═══════════════════════════════════════════════════════
var line lPDO = na
var line lPDH = na
var line lPDL = na
var line lPDC = na
var line lWO  = na
var line lWH  = na
var line lWL  = na
var line lWC  = na


// ═══════════════════════════════════════════════════════
//  ADR LABEL & LINE HANDLES
// ═══════════════════════════════════════════════════════
var label lblADRTop = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblADRBtm = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblADRMid = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var line  lADRTop   = na
var line  lADRBtm   = na
var line  lADRMid   = na

// ═══════════════════════════════════════════════════════
//  HELPER: sync label to right edge every bar
//  above=true places the label above the line (used when a
//  line extends across the full horizontal plane so the
//  line doesn't run through the label text)
//  De-stacking: every placed label registers its price in
//  a per-bar list; labels landing within the overlap
//  threshold of already-placed ones scoot right by the
//  stagger offset (once per overlap).
// ═══════════════════════════════════════════════════════
var array<float> _lblYs = array.new<float>()
_lblNudge = ta.atr(14) * lblNudgeF   // downward nudge for On-Line labels, scales with chart

syncLabel(lbl, show, price, txt, col, above, online) =>
    int xOff = 2
    if show
        int stack = 0
        if lblDestack
            if _lblYs.size() > 0
                for i = 0 to _lblYs.size() - 1
                    if math.abs(_lblYs.get(i) - price) <= lblThrTicks * syminfo.mintick
                        stack += 1
            _lblYs.push(price)
        xOff := 2 + stack * lblStagger
        label.set_x(lbl, bar_index + xOff)
        // On-Line style: nudge down so the text visually rests on the line
        label.set_y(lbl, online ? price - _lblNudge : price)
        priceTxt = str.tostring(price, format.mintick)
        // On-Line style: price stacks on a second line; Default: appended inline
        label.set_text(lbl, showPriceLbl ? (online ? txt + "\n" + priceTxt : txt + " · " + priceTxt) : txt)
        label.set_textcolor(lbl, col)
        // On-Line style: no background bubble
        label.set_color(lbl, color.new(col, online ? 100 : 85))
        // On-Line style: larger text (normal ≈ half of huge)
        label.set_size(lbl, online ? size.normal : size.small)
        // On-Line style: anchor lower-left so the text sits ON TOP of the line
        label.set_style(lbl, online or above ? label.style_label_lower_left : label.style_label_left)
    else
        label.set_text(lbl, "")
        label.set_color(lbl, color.new(color.black, 100))
    xOff

// ═══════════════════════════════════════════════════════
//  HELPER: redraw OHLC line
// ═══════════════════════════════════════════════════════
redrawLine(oldLine, show, price, col, lw, ls, extMode) =>
    line result = oldLine
    if show
        if not na(oldLine)
            line.delete(oldLine)
        result := line.new(bar_index, price, bar_index + 1, price,
             color=col, width=lw, style=ls, extend=extMode)
    result

// ═══════════════════════════════════════════════════════
//  LABEL-ABOVE FLAGS — when a group's lines span the full
//  horizontal plane ("Both"), lift its labels above the line
// ═══════════════════════════════════════════════════════
pdAbove  = extendPD  == "Both"
wAbove   = extendW   == "Both"
adrAbove = extendADR == "Both"

// ═══════════════════════════════════════════════════════
//  UPDATE EMA LABELS
// ═══════════════════════════════════════════════════════
_lblYs.clear()  // reset the per-bar overlap registry before any labels place
syncLabel(lbl5_1,  show5m  and show5m_1,  e5_1f,  "5m EMA "  + str.tostring(ema5m_1_len),  col5m_1,  false, lblStyle5m)
syncLabel(lbl5_2,  show5m  and show5m_2,  e5_2f,  "5m EMA "  + str.tostring(ema5m_2_len),  col5m_2,  false, lblStyle5m)
syncLabel(lbl5_3,  show5m  and show5m_3,  e5_3f,  "5m EMA "  + str.tostring(ema5m_3_len),  col5m_3,  false, lblStyle5m)
syncLabel(lbl10_1, show10m and show10m_1, e10_1f, "10m EMA " + str.tostring(ema10m_1_len), col10m_1, false, lblStyle10m)
syncLabel(lbl10_2, show10m and show10m_2, e10_2f, "10m EMA " + str.tostring(ema10m_2_len), col10m_2, false, lblStyle10m)
syncLabel(lbl10_3, show10m and show10m_3, e10_3f, "10m EMA " + str.tostring(ema10m_3_len), col10m_3, false, lblStyle10m)
syncLabel(lbl15_1, show15m and show15m_1, e15_1f, "15m EMA " + str.tostring(ema15m_1_len), col15m_1, false, lblStyle15m)
syncLabel(lbl15_2, show15m and show15m_2, e15_2f, "15m EMA " + str.tostring(ema15m_2_len), col15m_2, false, lblStyle15m)
syncLabel(lbl15_3, show15m and show15m_3, e15_3f, "15m EMA " + str.tostring(ema15m_3_len), col15m_3, false, lblStyle15m)
syncLabel(lbl1h_1, show1h  and show1h_1,  e1h_1f, "1h EMA "  + str.tostring(ema1h_1_len),  col1h_1,  false, lblStyle1h)
syncLabel(lbl1h_2, show1h  and show1h_2,  e1h_2f, "1h EMA "  + str.tostring(ema1h_2_len),  col1h_2,  false, lblStyle1h)
syncLabel(lbl1h_3, show1h  and show1h_3,  e1h_3f, "1h EMA "  + str.tostring(ema1h_3_len),  col1h_3,  false, lblStyle1h)

// ═══════════════════════════════════════════════════════
//  UPDATE EMA LINES  (redraw each bar)
// ═══════════════════════════════════════════════════════
ls5m  = lineStyleFromStr(ema5m_style)
ls10m = lineStyleFromStr(ema10m_style)
ls15m = lineStyleFromStr(ema15m_style)
ls1h  = lineStyleFromStr(ema1h_style)

ext5m  = ema5m_extend  ? extend.right : extend.none
ext10m = ema10m_extend ? extend.right : extend.none
ext15m = ema15m_extend ? extend.right : extend.none
ext1h  = ema1h_extend  ? extend.right : extend.none

if show5m
    l5m_1  := redrawLine(l5m_1,  show5m_1,  e5_1f,  col5m_1,  ema5m_width,  ls5m,  ext5m)
    l5m_2  := redrawLine(l5m_2,  show5m_2,  e5_2f,  col5m_2,  ema5m_width,  ls5m,  ext5m)
    l5m_3  := redrawLine(l5m_3,  show5m_3,  e5_3f,  col5m_3,  ema5m_width,  ls5m,  ext5m)

if show10m
    l10m_1 := redrawLine(l10m_1, show10m_1, e10_1f, col10m_1, ema10m_width, ls10m, ext10m)
    l10m_2 := redrawLine(l10m_2, show10m_2, e10_2f, col10m_2, ema10m_width, ls10m, ext10m)
    l10m_3 := redrawLine(l10m_3, show10m_3, e10_3f, col10m_3, ema10m_width, ls10m, ext10m)

if show15m
    l15m_1 := redrawLine(l15m_1, show15m_1, e15_1f, col15m_1, ema15m_width, ls15m, ext15m)
    l15m_2 := redrawLine(l15m_2, show15m_2, e15_2f, col15m_2, ema15m_width, ls15m, ext15m)
    l15m_3 := redrawLine(l15m_3, show15m_3, e15_3f, col15m_3, ema15m_width, ls15m, ext15m)

if show1h
    l1h_1  := redrawLine(l1h_1,  show1h_1,  e1h_1f, col1h_1,  ema1h_width,  ls1h,  ext1h)
    l1h_2  := redrawLine(l1h_2,  show1h_2,  e1h_2f, col1h_2,  ema1h_width,  ls1h,  ext1h)
    l1h_3  := redrawLine(l1h_3,  show1h_3,  e1h_3f, col1h_3,  ema1h_width,  ls1h,  ext1h)

// ═══════════════════════════════════════════════════════
//  UPDATE OHLC LABELS & LINES
// ═══════════════════════════════════════════════════════
syncLabel(lblPDO, showPD and showPDO, pd_o, "PDO",         colPDO, pdAbove, lblStylePD)
syncLabel(lblPDH, showPD and showPDH, pd_h, "PDH",         colPDH, pdAbove, lblStylePD)
syncLabel(lblPDL, showPD and showPDL, pd_l, "PDL",         colPDL, pdAbove, lblStylePD)
syncLabel(lblPDC, showPD and showPDC, pd_c, "PDC",         colPDC, pdAbove, lblStylePD)
syncLabel(lblWO,  showW  and showWO,  cw_o, "W Open",      colWO,  wAbove, lblStyleW)
syncLabel(lblWH,  showW  and showWH,  cw_h, "W High",      colWH,  wAbove, lblStyleW)
syncLabel(lblWL,  showW  and showWL,  cw_l, "W Low",       colWL,  wAbove, lblStyleW)
syncLabel(lblWC,  showW  and showWC,  cw_c, "Prev W Close",colWC,  wAbove, lblStyleW)

pdLs  = lineStyleFromStr(stylePD)
wLs   = lineStyleFromStr(styleW)
pdExt = extendFromStr(extendPD)
wExt  = extendFromStr(extendW)

if showPD
    lPDO := redrawLine(lPDO, showPDO, pd_o, colPDO, widthPD, pdLs, pdExt)
    lPDH := redrawLine(lPDH, showPDH, pd_h, colPDH, widthPD, pdLs, pdExt)
    lPDL := redrawLine(lPDL, showPDL, pd_l, colPDL, widthPD, pdLs, pdExt)
    lPDC := redrawLine(lPDC, showPDC, pd_c, colPDC, widthPD, pdLs, pdExt)

if showW
    lWO := redrawLine(lWO, showWO, cw_o, colWO, widthW, wLs, wExt)
    lWH := redrawLine(lWH, showWH, cw_h, colWH, widthW, wLs, wExt)
    lWL := redrawLine(lWL, showWL, cw_l, colWL, widthW, wLs, wExt)
    lWC := redrawLine(lWC, showWC, cw_c, colWC, widthW, wLs, wExt)


// ═══════════════════════════════════════════════════════
//  AVERAGE DAILY RANGE (ADR)
//  Midpoint = today's NY Open (9:30 AM ET)
//  ADR Top  = NY Open + (avgDailyRange / 2)
//  ADR Btm  = NY Open - (avgDailyRange / 2)
// ═══════════════════════════════════════════════════════

// Average of daily high-low range over adrLen days (excluding today)
adrValue   = request.security(syminfo.tickerid, "D", ta.sma(high[1] - low[1], adrLen), lookahead=barmerge.lookahead_off)

// Detect the 9:30 AM NY Open bar on the current chart
nyHour    = 9
nyMinute  = 30
isNYOpen  = hour(time, adrTimezone) == nyHour and minute(time, adrTimezone) == nyMinute

// Track the NY open price for today — reset each day at 9:30
var float nyOpenPrice = na
if isNYOpen
    nyOpenPrice := open

adrTop = nyOpenPrice + adrValue / 2
adrBtm = nyOpenPrice - adrValue / 2
adrLs  = lineStyleFromStr(styleADR)

if showADR and not na(nyOpenPrice) and not na(adrValue)
    // Lines
    if not na(lADRTop)
        line.delete(lADRTop)
    if not na(lADRBtm)
        line.delete(lADRBtm)
    if not na(lADRMid)
        line.delete(lADRMid)
    extADR = extendFromStr(extendADR)
    lADRTop := line.new(bar_index, adrTop, bar_index + 1, adrTop, color=colADRTop, width=widthADR, style=adrLs, extend=extADR)
    lADRBtm := line.new(bar_index, adrBtm, bar_index + 1, adrBtm, color=colADRBtm, width=widthADR, style=adrLs, extend=extADR)
    lADRMid := line.new(bar_index, nyOpenPrice, bar_index + 1, nyOpenPrice, color=colADRMid, width=widthADR, style=line.style_dotted, extend=extADR)
    // Labels
    adrRangeStr = " (" + str.tostring(math.round(adrValue, 2)) + ")"
    syncLabel(lblADRTop, true, adrTop,        "ADR High" + adrRangeStr, colADRTop, adrAbove, false)
    syncLabel(lblADRBtm, true, adrBtm,        "ADR Low"  + adrRangeStr, colADRBtm, adrAbove, false)
    syncLabel(lblADRMid, true, nyOpenPrice,   "NY Open",                colADRMid, adrAbove, false)
else if not showADR
    syncLabel(lblADRTop, false, adrTop, "", colADRTop, false, false)
    syncLabel(lblADRBtm, false, adrBtm, "", colADRBtm, false, false)
    syncLabel(lblADRMid, false, nyOpenPrice, "", colADRMid, false, false)

// ═══════════════════════════════════════════════════════
//  FVG / IFVG (BPR) ENGINE
//
//  Each timeframe (5m, 15m, 1h) runs the same detection
//  logic via request.security, then manages its own
//  independent arrays of lines, labels, and BPR boxes.
// ═══════════════════════════════════════════════════════

// ── UDT ────────────────────────────────────────────────
type FVG
    int   ftype    = 0      // 1 = bull, -1 = bear
    float top      = na
    float btm      = na
    int   leftTime = na
    int   left2Time= na
    int   barIdx   = 0      // HTF bar index when FVG formed

// ── Detection function (runs inside request.security) ──
// volume[1] = middle candle of the 3-bar pattern
// volume[2] = first candle of the 3-bar pattern
getFVG() =>
    isBull = low > high[2] and close[1] > high[2]
    isBear = high < low[2] and close[1] < low[2]
    ftype  = isBull ? 1 : isBear ? -1 : 0
    ftop   = isBull ? low    : isBear ? low[2] : na
    fbtm   = isBull ? high[2]: isBear ? high   : na
    fleft  = isBull ? time   : isBear ? time[2]: na
    fleft2 = isBull ? time[2]: isBear ? time   : na
    [ftype, ftop, fbtm, fleft, fleft2, open, close, high, low, open[1], close[1], high[1], low[1], time, bar_index, volume[1], volume[2]]

// ── Fetch all three timeframes ──────────────────────────
[ft5,  top5,  btm5,  lft5,  lft25,  o5,  c5,  h5,  l5,  op5,  cp5,  hp5,  lp5,  t5,  bi5,  vm5,  vf5]  = request.security(syminfo.tickerid, "5",  getFVG(),  lookahead=barmerge.lookahead_off)
[ft15, top15, btm15, lft15, lft215, o15, c15, h15, l15, op15, cp15, hp15, lp15, t15, bi15, vm15, vf15] = request.security(syminfo.tickerid, "15", getFVG(), lookahead=barmerge.lookahead_off)
[ft1h, top1h, btm1h, lft1h, lft21h, o1h, c1h, h1h, l1h, op1h, cp1h, hp1h, lp1h, t1h, bi1h, vm1h, vf1h] = request.security(syminfo.tickerid, "60", getFVG(),  lookahead=barmerge.lookahead_off)

// ── Per-TF array storage ────────────────────────────────
// 5m
var array<FVG>   fvgArr5    = array.new<FVG>()
var array<bool>  fvgType5   = array.new<bool>()
var array<box>   fvgBox5    = array.new<box>()
var array<label> fvgLbl5    = array.new<label>()
var array<FVG>   bprArr5    = array.new<FVG>()
var array<box>   bprBox5    = array.new<box>()

// 15m
var array<FVG>   fvgArr15   = array.new<FVG>()
var array<bool>  fvgType15  = array.new<bool>()
var array<box>   fvgBox15   = array.new<box>()
var array<label> fvgLbl15   = array.new<label>()
var array<FVG>   bprArr15   = array.new<FVG>()
var array<box>   bprBox15   = array.new<box>()

// 1h
var array<FVG>   fvgArr1h   = array.new<FVG>()
var array<bool>  fvgType1h  = array.new<bool>()
var array<box>   fvgBox1h   = array.new<box>()
var array<label> fvgLbl1h   = array.new<label>()
var array<FVG>   bprArr1h   = array.new<FVG>()
var array<box>   bprBox1h   = array.new<box>()

// ── Core processing function ────────────────────────────
// Processes one TF's new FVG detection result against its arrays.
// show        - master toggle for this TF
// ftype       - 1/−1/0 from getFVG
// ftop/fbtm   - FVG boundaries
// fleft/fleft2- bar times for line anchors
// curBarIdx   - current HTF bar index (drives bprWindow aging)
// curT        - current HTF bar time (used to detect new bar)
// o_cur/c_cur/h_cur/l_cur   - current HTF OHLC (for mitigation test)
// addT        - time offset to extend lines/boxes rightward
// rightAnchor - absolute time for box right edge (chart-time based,
//               identical across TFs so compact boxes align)
// cmpW        - compact box width in ms (used when compactMode is on)
// vMid/vFirst - HTF volume of the middle and first pattern candles
// fArr / fTyp / fvgBoxArr / fLbl  - FVG arrays
// bArr / bBox                          - BPR arrays
processTF(show, ftype, ftop, fbtm, fleft, fleft2, curBarIdx,
          curT, o_cur, c_cur, h_cur, l_cur,
          addT, rightAnchor, cmpW, vMid, vFirst,
          bullCol, bearCol, tfLabel,
          fArr, fTyp, fvgBoxArr, fLbl,
          bArr, bBox) =>

    if show
        // Right edge: compact mode uses the shared chart-time anchor
        // so all TFs sit at the exact same spot; normal mode keeps
        // the original HTF-time based edge.
        rightT = compactMode ? rightAnchor : curT + addT

        bullMit  = mitTypeWick ? l_cur  : c_cur
        bearMit  = mitTypeWick ? h_cur  : c_cur

        // Extend existing FVG boxes & test mitigation (current bar)
        // Compact mode: keep boxes a fixed width floating at the right edge
        if fTyp.size() > 0
            i = 0
            while i < fTyp.size()
                isBull_ = fTyp.get(i)
                bx_     = fvgBoxArr.get(i)
                lbl_    = fLbl.get(i)
                lbl_.set_x(rightT)
                bx_.set_right(rightT)
                if compactMode
                    bx_.set_left(rightT - cmpW)
                mn  = bx_.get_bottom()
                mx  = bx_.get_top()
                mid = (mx - mn) * mitPct * 0.01
                mitigated = isBull_ ? bullMit < (mx - mid) : bearMit > (mn + mid)
                if mitigated
                    fvgBoxArr.remove(i).delete()
                    fLbl.remove(i).delete()
                    fTyp.remove(i)
                    i -= 1
                i += 1

        // Extend BPR boxes & test mitigation — matches original source direction
        if bArr.size() > 0
            i = 0
            while i < bArr.size()
                bfvg = bArr.get(i)
                bbx_ = bBox.get(i)
                bbx_.set_right(rightT)
                if compactMode
                    bbx_.set_left(rightT - cmpW)
                mn   = math.min(bfvg.top, bfvg.btm)
                mx   = math.max(bfvg.top, bfvg.btm)
                mid  = (mx - mn) * mitPct * 0.01
                mitigated = bfvg.ftype == 1 ? bullMit < (mx - mid) : bearMit > (mn + mid)
                if mitigated
                    bBox.remove(i).delete()
                    bArr.remove(i)
                    i -= 1
                i += 1

        // ── FVG store housekeeping ──────────────────────────
        // NOTE: store entries are NOT deleted on mitigation — an
        // inverted (traded-through) FVG is exactly the zone a BPR
        // pairs against, so purging on mitigation would prevent
        // nearly all BPRs from ever forming. Instead, entries live
        // for bprWindow HTF candles and are then aged out.
        if fArr.size() > 0
            i = 0
            while i < fArr.size()
                if curBarIdx - fArr.get(i).barIdx > bprWindow
                    fArr.remove(i)
                    i -= 1
                i += 1

        // ── High Probability filter ─────────────────────────
        // Size:   FVG must be at least hpMinTicks ticks tall
        // Volume: middle candle volume > first candle volume
        hpSizeOK = not na(ftop) and not na(fbtm) and (ftop - fbtm) / syminfo.mintick >= hpMinTicks
        hpVolOK  = not na(vMid) and not na(vFirst) and vMid > vFirst
        hpPass   = not hpOnly or (hpSizeOK and hpVolOK)

        // New FVG detected on this bar?
        if (ftype == 1 or ftype == -1) and hpPass
            isBPR = false
            // BPR check: new FVG must OVERLAP an OPPOSITE-direction
            // FVG that formed within the last bprWindow HTF candles
            if not na(ftop) and not na(fbtm) and fArr.size() > 0
                i = 0
                while i < fArr.size()
                    old = fArr.get(i)
                    opposite = old.ftype != ftype
                    inWindow = curBarIdx - old.barIdx <= bprWindow
                    c1 = ftop <= old.top and fbtm >= old.btm
                    c2 = ftop <= old.top and ftop >  old.btm and fbtm < old.btm
                    c3 = ftop >  old.top and fbtm >= old.btm and fbtm < old.top
                    c4 = ftop >= old.top and fbtm <= old.btm
                    if (c1 or c2 or c3 or c4) and opposite and inWindow
                        bTop = c2 ? ftop    : c3 ? old.top : c4 ? old.top : ftop
                        bBtm = c2 ? old.btm : c3 ? fbtm    : c4 ? old.btm : fbtm
                        isBPR := true
                        bprCol    = ftype == 1 ? bullCol : bearCol
                        bprBgCol  = bprShowBg     ? color.new(bprCol, bprBgTransp) : color.new(bprCol, 100)
                        bprBrdCol = bprShowBorder ? bprCol                          : color.new(bprCol, 100)
                        boxLeft   = compactMode ? rightT - cmpW : math.max(old.leftTime, curT - addT * 20)
                        bArr.unshift(FVG.new(ftype, bTop, bBtm, old.leftTime, fleft2, curBarIdx))
                        bBox.unshift(box.new(
                             boxLeft, bTop, rightT, bBtm,
                             border_color=bprBrdCol, bgcolor=bprBgCol,
                             xloc=xloc.bar_time, border_style=bprBoxStyle,
                             text=tfLabel + " BPR", text_size=size.small,
                             text_halign=text.align_right, text_color=bprCol))
                        // ── Trim BPRs (strict) ──────────────
                        // Balance ON: per-direction quota — only the
                        // oldest BPR of the SAME direction as the new
                        // one can be evicted. Opposite-direction BPRs
                        // persist until mitigated, regardless of age.
                        if balanceDirs
                            dirBPR = 0
                            for k = 0 to bArr.size() - 1
                                if bArr.get(k).ftype == ftype
                                    dirBPR += 1
                            if dirBPR > bprCount
                                for k = bArr.size() - 1 to 0
                                    if bArr.get(k).ftype == ftype
                                        bArr.remove(k)
                                        bBox.remove(k).delete()
                                        break
                        else
                            if bBox.size() > bprCount
                                bArr.pop()
                                bBox.pop().delete()
                    i += 1

            // Always store new FVG in detection array
            fArr.unshift(FVG.new(ftype, ftop, fbtm, fleft, fleft2, curBarIdx))

            // Draw as plain FVG only if it did not form a BPR
            if not isBPR
                fvgCol    = ftype == 1 ? bullCol : bearCol
                fvgBgCol  = fvgShowBg     ? color.new(fvgCol, fvgBgTransp) : color.new(fvgCol, 100)
                fvgBrdCol = fvgShowBorder ? fvgCol                          : color.new(fvgCol, 100)
                fvgLeft   = compactMode ? rightT - cmpW : fleft
                fTyp.unshift(ftype == 1)
                fvgBoxArr.unshift(box.new(
                     fvgLeft, ftop, rightT, fbtm,
                     border_color=fvgBrdCol, bgcolor=fvgBgCol,
                     xloc=xloc.bar_time, border_style=fvgBorderStyle))
                fLbl.unshift(label.new(
                     rightT, (ftop + fbtm) / 2,
                     color=#ff525200, xloc=xloc.bar_time,
                     style=label.style_label_right, size=size.small,
                     text=tfLabel + " FVG", textcolor=fvgCol))
                // ── Trim FVGs (strict) ──────────────────────
                // Balance ON: per-direction quota — a new FVG can
                // only evict the oldest FVG of its OWN direction.
                // Opposite-direction FVGs (e.g. old bullish zones
                // below price) persist until mitigated, no matter
                // how many days or weeks old they are.
                if balanceDirs
                    isBullNew = ftype == 1
                    dirFVG = 0
                    for k = 0 to fTyp.size() - 1
                        if fTyp.get(k) == isBullNew
                            dirFVG += 1
                    if dirFVG > fvgCount
                        for k = fTyp.size() - 1 to 0
                            if fTyp.get(k) == isBullNew
                                fTyp.remove(k)
                                fvgBoxArr.remove(k).delete()
                                fLbl.remove(k).delete()
                                break
                else
                    if fvgBoxArr.size() > fvgCount
                        fTyp.pop()
                        fvgBoxArr.pop().delete()
                        fLbl.pop().delete()

// ── Compact re-sync (runs every chart bar) ──────────────
// Keeps all floating boxes pinned to the same chart-time
// anchor between HTF closes so they never lag or drift.
syncCompact(show, fvgBoxArr, fLbl, bBox, rightAnchor, cmpW) =>
    if show and compactMode
        leftT = rightAnchor - cmpW
        if fvgBoxArr.size() > 0
            for i = 0 to fvgBoxArr.size() - 1
                fvgBoxArr.get(i).set_right(rightAnchor)
                fvgBoxArr.get(i).set_left(leftT)
                fLbl.get(i).set_x(rightAnchor)
        if bBox.size() > 0
            for i = 0 to bBox.size() - 1
                bBox.get(i).set_right(rightAnchor)
                bBox.get(i).set_left(leftT)

// ── Time offsets for label/box right edge ───────────────
// Use 3x the current chart bar width so labels sit just
// off the right edge on any timeframe. On a 1m chart a
// raw 1h offset would push labels far off screen.
// Floor each value at the HTF ms width so replay is safe.
ms5         = 5  * 60 * 1000
ms15        = 15 * 60 * 1000
ms1h        = 60 * 60 * 1000
chartBarMs  = time - time[1] > 0 ? time - time[1] : 60 * 1000
labelOffset = 3 * chartBarMs
addT5  = math.max(labelOffset, ms5)
addT15 = math.max(labelOffset, ms15)
addT1h = math.max(labelOffset, ms1h)

// Shared right-edge anchor for compact mode — based on the
// CHART's current bar time (not HTF bar time), so 5m, 15m,
// and 1h boxes all sit at the exact same x position.
rightAnchorT = time + labelOffset

// Compact mode box width (in chart candles)
cmpBoxMs = compactWidth * chartBarMs

// ── New-bar gate: fires when HTF open changes (confirmed closed bar)
// Matches original source behaviour — processes FVGs on the bar after close
newBar5  = o5  != o5[1]
newBar15 = o15 != o15[1]
newBar1h = o1h != o1h[1]

if newBar5 and barstate.isconfirmed
    processTF(show5mFVG,  ft5,  top5,  btm5,  lft5,  lft25,  bi5,
              t5,  o5,  c5,  h5,  l5,  addT5,  rightAnchorT, cmpBoxMs, vm5,  vf5,
              bull5mCol,  bear5mCol,  "5m",
              fvgArr5,  fvgType5,  fvgBox5,   fvgLbl5,  bprArr5,  bprBox5)

if newBar15 and barstate.isconfirmed
    processTF(show15mFVG, ft15, top15, btm15, lft15, lft215, bi15,
              t15, o15, c15, h15, l15, addT15, rightAnchorT, cmpBoxMs, vm15, vf15,
              bull15mCol, bear15mCol, "15m",
              fvgArr15, fvgType15, fvgBox15,  fvgLbl15, bprArr15, bprBox15)

if newBar1h and barstate.isconfirmed
    processTF(show1hFVG,  ft1h, top1h, btm1h, lft1h, lft21h, bi1h,
              t1h, o1h, c1h, h1h, l1h, addT1h, rightAnchorT, cmpBoxMs, vm1h, vf1h,
              bull1hCol,  bear1hCol,  "1h",
              fvgArr1h, fvgType1h, fvgBox1h,  fvgLbl1h, bprArr1h, bprBox1h)

// ── Pin compact boxes every chart bar (all TFs aligned) ──
syncCompact(show5mFVG,  fvgBox5,  fvgLbl5,  bprBox5,  rightAnchorT, cmpBoxMs)
syncCompact(show15mFVG, fvgBox15, fvgLbl15, bprBox15, rightAnchorT, cmpBoxMs)
syncCompact(show1hFVG,  fvgBox1h, fvgLbl1h, bprBox1h, rightAnchorT, cmpBoxMs)


// ═══════════════════════════════════════════════════════
//  5m / 15m / 1h SWING HIGH-LOW, EQUILIBRIUM & 0.786 FIB
//  Swing = a candle whose high/low exceeds N candles on
//  each side (structural pivot). The most recent swing is
//  held indefinitely — it never "ages out" of a window.
//
//  Closed-candle break tracking: when a candle CLOSES
//  having traded beyond the tracked swing, the swing
//  updates to that candle's extreme. The level never moves
//  intrabar — only completed candles can move it. During a
//  multi-candle run it steps up/down once per close,
//  riding the move with at most one candle of lag.
//
//  A confirmed pivot only replaces the tracked swing if it
//  is at least as recent, so a slow-confirming older pivot
//  can never downgrade a break extreme already tracked.
//
//  50% (EQ) and 0.786 span the swing range, anchored to
//  the direction of the most recent extreme.
// ═══════════════════════════════════════════════════════

getSwings(len, minGapTicks) =>
    ph = ta.pivothigh(high, len, len)
    pl = ta.pivotlow(low, len, len)
    var float swH  = na
    var float swL  = na
    var int   swHT = 0
    var int   swLT = 0
    // Rolling structure history for Incoming HH & LL (unswept levels only)
    var array<float> hHist  = array.new<float>()
    var array<int>   hHistT = array.new<int>()
    var array<float> lHist  = array.new<float>()
    var array<int>   lHistT = array.new<int>()
    // Prune swept levels — a closed candle beyond a stored level takes it out
    if hHist.size() > 0
        i = 0
        while i < hHist.size()
            if high[1] > hHist.get(i)
                hHist.remove(i)
                hHistT.remove(i)
                i -= 1
            i += 1
    if lHist.size() > 0
        i = 0
        while i < lHist.size()
            if low[1] < lHist.get(i)
                lHist.remove(i)
                lHistT.remove(i)
                i -= 1
            i += 1
    // Pivot confirmation — every confirmed pivot enters structure history;
    // it becomes the tracked swing only if at least as recent.
    // If the new pivot is on the PROTECTIVE side of the current swing
    // (e.g. a lower high forms while the old, higher high is still
    // unbroken), the old level is NOT demoted to Previous — it's still
    // live structure ahead of price, so it's left in the history and
    // surfaces automatically as Incoming instead. Previous is reserved
    // for levels that were genuinely exceeded.
    if not na(ph)
        hHist.unshift(ph)
        hHistT.unshift(time[len])
        if hHist.size() > 50
            hHist.pop()
            hHistT.pop()
        if time[len] >= swHT
            swH  := ph
            swHT := time[len]
    if not na(pl)
        lHist.unshift(pl)
        lHistT.unshift(time[len])
        if lHist.size() > 50
            lHist.pop()
            lHistT.pop()
        if time[len] >= swLT
            swL  := pl
            swLT := time[len]
    // Closed-candle break — the previous (fully closed) candle exceeded the level
    if not na(swH) and high[1] > swH
        swH  := high[1]
        swHT := time[1]
    if not na(swL) and low[1] < swL
        swL  := low[1]
        swLT := time[1]
    // Incoming = nearest unswept structure level BEYOND the current swing
    minGap = minGapTicks * syminfo.mintick
    float inH  = na
    int   inHT = 0
    if not na(swH) and hHist.size() > 0
        for i = 0 to hHist.size() - 1
            v = hHist.get(i)
            if v > swH and (v - swH) >= minGap and (na(inH) or v < inH)
                inH  := v
                inHT := hHistT.get(i)
    float inL  = na
    int   inLT = 0
    if not na(swL) and lHist.size() > 0
        for i = 0 to lHist.size() - 1
            v = lHist.get(i)
            if v < swL and (swL - v) >= minGap and (na(inL) or v > inL)
                inL  := v
                inLT := lHistT.get(i)
    [swH, swL, swHT, swLT, inH, inL, inHT, inLT]

[sw5H, sw5L, sw5HT, sw5LT, in5H, in5L, in5HT, in5LT]     = request.security(syminfo.tickerid, "5",  getSwings(sw5Len, gapSw5I),  lookahead=barmerge.lookahead_off)
[sw15H, sw15L, sw15HT, sw15LT, in15H, in15L, in15HT, in15LT] = request.security(syminfo.tickerid, "15", getSwings(sw15Len, gapSw15I), lookahead=barmerge.lookahead_off)
[sw1hH, sw1hL, sw1hHT, sw1hLT, in1hH, in1hL, in1hHT, in1hLT] = request.security(syminfo.tickerid, "60", getSwings(sw1hLen, gapSw1hI), lookahead=barmerge.lookahead_off)

// Direction: the more recent extreme defines the move
sw5Up   = sw5HT > sw5LT
sw5Rng  = sw5H - sw5L
sw5EQ   = (sw5H + sw5L) / 2
sw5Fib  = sw5Up ? sw5H - 0.786 * sw5Rng : sw5L + 0.786 * sw5Rng

sw15Up  = sw15HT > sw15LT
sw15Rng = sw15H - sw15L
sw15EQ  = (sw15H + sw15L) / 2
sw15Fib = sw15Up ? sw15H - 0.786 * sw15Rng : sw15L + 0.786 * sw15Rng

sw1hUp  = sw1hHT > sw1hLT
sw1hRng = sw1hH - sw1hL
sw1hEQ  = (sw1hH + sw1hL) / 2
sw1hFib = sw1hUp ? sw1hH - 0.786 * sw1hRng : sw1hL + 0.786 * sw1hRng

// ── Line & label handles ────────────────────────────────
var line lSw5H   = na
var line lSw5L   = na
var line lSw5EQ  = na
var line lSw5F   = na
var line lSw15H  = na
var line lSw15L  = na
var line lSw15EQ = na
var line lSw15F  = na
var line lSw1hH  = na
var line lSw1hL  = na
var line lSw1hEQ = na
var line lSw1hF  = na
var line lSw5IH  = na
var line lSw5IL  = na
var line lSw15IH = na
var line lSw15IL = na
var line lSw1hIH = na
var line lSw1hIL = na
var label lblSw5H   = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw5L   = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw5EQ  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw5F   = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw15H  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw15L  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw15EQ = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw15F  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw1hH  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw1hL  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw1hEQ = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw1hF  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw5IH  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw5IL  = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw15IH = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw15IL = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw1hIH = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)
var label lblSw1hIL = label.new(bar_index, close, "", style=label.style_label_left, size=size.small)

// ── Chart-TF origin resolution for "From Candle" ────────
// Finds the CHART bar that actually printed the swing
// extreme, scanning only within the swing's own HTF candle
// window, and caches it until the swing changes. Falls
// back to the HTF candle's open time if the origin lies
// beyond the 500-bar history limit.
findOrigin(swVal, swT, htfMs, isHigh) =>
    int result = na
    if not na(swVal)
        maxScan = math.min(499, math.max(0, int((time - swT) / chartBarMs) + 2))
        winEnd  = swT + htfMs
        for i = 0 to maxScan
            if time[i] < swT
                break
            if time[i] < winEnd
                v = isHigh ? high[i] : low[i]
                if math.abs(v - swVal) <= syminfo.mintick * 0.25
                    result := time[i]
                    break
    result

trackOrigin(swVal, swT, htfMs, isHigh) =>
    var int oT = na
    if not na(swVal) and (swVal != nz(swVal[1], -1.0) or swT != nz(swT[1], -1))
        found = findOrigin(swVal, swT, htfMs, isHigh)
        oT := na(found) ? swT : found
    oT

o5H  = trackOrigin(sw5H,  sw5HT,  ms5,  true)
o5L  = trackOrigin(sw5L,  sw5LT,  ms5,  false)
o15H = trackOrigin(sw15H, sw15HT, ms15, true)
o15L = trackOrigin(sw15L, sw15LT, ms15, false)
o1hH = trackOrigin(sw1hH, sw1hHT, ms1h, true)
o1hL = trackOrigin(sw1hL, sw1hLT, ms1h, false)
o5IH  = trackOrigin(in5H,  in5HT,  ms5,  true)
o5IL  = trackOrigin(in5L,  in5LT,  ms5,  false)
o15IH = trackOrigin(in15H, in15HT, ms15, true)
o15IL = trackOrigin(in15L, in15LT, ms15, false)
o1hIH = trackOrigin(in1hH, in1hHT, ms1h, true)
o1hIL = trackOrigin(in1hL, in1hLT, ms1h, false)

// ── Draw ────────────────────────────────────────────────
// From-Candle-aware redraw: "From Candle" anchors the line
// at the swing's own candle (time-based) and stretches it
// to the label area; other modes keep the standard
// right-edge line with the chosen extension.
redrawSw(oldLine, show, price, col, lw, ls, extStr, fromT, toOff) =>
    line result = oldLine
    if show
        if not na(oldLine)
            line.delete(oldLine)
        if extStr == "From Candle"
            // stretch from the creator candle to this level's label
            result := line.new(fromT, price, time + toOff * chartBarMs, price, xloc=xloc.bar_time, color=col, width=lw, style=ls, extend=extend.none)
        else
            result := line.new(bar_index, price, bar_index + 1, price, color=col, width=lw, style=ls, extend=extendFromStr(extStr))
    else
        // Explicitly clear — without this, a line whose "show" condition
        // goes false (e.g. Incoming flipping sides as direction changes)
        // stays frozen at its last position instead of disappearing,
        // which is what caused stale lines to sit far from price.
        if not na(oldLine)
            line.delete(oldLine)
        result := na
    result

sw5Abv  = extendSw5  == "Both"
sw15Abv = extendSw15 == "Both"
sw1hAbv = extendSw1h == "Both"
ok5     = not na(sw5H)  and not na(sw5L)
ok15    = not na(sw15H) and not na(sw15L)
ok1h    = not na(sw1hH) and not na(sw1hL)
okI5H   = not na(in5H)   // next unswept high beyond the current 5m swing high
okI5L   = not na(in5L)   // next unswept low beyond the current 5m swing low
okI15H  = not na(in15H)
okI15L  = not na(in15L)
okI1hH  = not na(in1hH)
okI1hL  = not na(in1hL)

// Labels first — their x offsets size the From-Candle lines
off5H    = syncLabel(lblSw5H,   showSw5  and showSw5H   and ok5,  sw5H,    "5m Swing High",  colSw5H,   sw5Abv, lblStyleSw5)
off5L    = syncLabel(lblSw5L,   showSw5  and showSw5L   and ok5,  sw5L,    "5m Swing Low",   colSw5L,   sw5Abv, lblStyleSw5)
off5EQ   = syncLabel(lblSw5EQ,  showSw5  and showSw5EQ  and ok5,  sw5EQ,   "5m EQ",          colSw5EQ,  sw5Abv, lblStyleSw5)
off5F    = syncLabel(lblSw5F,   showSw5  and showSw5F   and ok5,  sw5Fib,  "5m 0.786" + (sw5Up ? " ▲" : " ▼"),  colSw5F,  sw5Abv, lblStyleSw5)
off5IH   = syncLabel(lblSw5IH,  showSw5  and showSw5I  and okI5H,  in5H,  "5m Incoming HH",  colSw5I,  sw5Abv, lblStyleSw5)
off5IL   = syncLabel(lblSw5IL,  showSw5  and showSw5I  and okI5L,  in5L,  "5m Incoming LL",  colSw5I,  sw5Abv, lblStyleSw5)
off15H   = syncLabel(lblSw15H,  showSw15 and showSw15H  and ok15, sw15H,   "15m Swing High", colSw15H,  sw15Abv, lblStyleSw15)
off15L   = syncLabel(lblSw15L,  showSw15 and showSw15L  and ok15, sw15L,   "15m Swing Low",  colSw15L,  sw15Abv, lblStyleSw15)
off15EQ  = syncLabel(lblSw15EQ, showSw15 and showSw15EQ and ok15, sw15EQ,  "15m EQ",         colSw15EQ, sw15Abv, lblStyleSw15)
off15F   = syncLabel(lblSw15F,  showSw15 and showSw15F  and ok15, sw15Fib, "15m 0.786" + (sw15Up ? " ▲" : " ▼"), colSw15F, sw15Abv, lblStyleSw15)
off15IH  = syncLabel(lblSw15IH, showSw15 and showSw15I and okI15H, in15H, "15m Incoming HH", colSw15I, sw15Abv, lblStyleSw15)
off15IL  = syncLabel(lblSw15IL, showSw15 and showSw15I and okI15L, in15L, "15m Incoming LL", colSw15I, sw15Abv, lblStyleSw15)
off1hH   = syncLabel(lblSw1hH,  showSw1h and showSw1hH  and ok1h, sw1hH,   "1h Swing High",  colSw1hH,  sw1hAbv, lblStyleSw1h)
off1hL   = syncLabel(lblSw1hL,  showSw1h and showSw1hL  and ok1h, sw1hL,   "1h Swing Low",   colSw1hL,  sw1hAbv, lblStyleSw1h)
off1hEQ  = syncLabel(lblSw1hEQ, showSw1h and showSw1hEQ and ok1h, sw1hEQ,  "1h EQ",          colSw1hEQ, sw1hAbv, lblStyleSw1h)
off1hF   = syncLabel(lblSw1hF,  showSw1h and showSw1hF  and ok1h, sw1hFib, "1h 0.786" + (sw1hUp ? " ▲" : " ▼"), colSw1hF, sw1hAbv, lblStyleSw1h)
off1hIH  = syncLabel(lblSw1hIH, showSw1h and showSw1hI and okI1hH, in1hH, "1h Incoming HH",  colSw1hI, sw1hAbv, lblStyleSw1h)
off1hIL  = syncLabel(lblSw1hIL, showSw1h and showSw1hI and okI1hL, in1hL, "1h Incoming LL",  colSw1hI, sw1hAbv, lblStyleSw1h)

if showSw5
    lSw5H  := redrawSw(lSw5H,  showSw5H  and ok5, sw5H,   colSw5H, widSw5H, lineStyleFromStr(stySw5H), extendSw5, o5H, off5H)
    lSw5L  := redrawSw(lSw5L,  showSw5L  and ok5, sw5L,   colSw5L, widSw5L, lineStyleFromStr(stySw5L), extendSw5, o5L, off5L)
    lSw5EQ  := redrawSw(lSw5EQ,  showSw5EQ  and ok5, sw5EQ,   colSw5EQ, widSw5EQ, lineStyleFromStr(stySw5EQ), extendSw5, sw5HT >= sw5LT ? o5H : o5L, off5EQ)
    lSw5F  := redrawSw(lSw5F,  showSw5F  and ok5, sw5Fib,   colSw5F, widSw5F, lineStyleFromStr(stySw5F), extendSw5, sw5HT >= sw5LT ? o5H : o5L, off5F)
    lSw5IH := redrawSw(lSw5IH, showSw5I and okI5H, in5H, colSw5I, widSw5I, lineStyleFromStr(stySw5I), extendSw5, o5IH, off5IH)
    lSw5IL := redrawSw(lSw5IL, showSw5I and okI5L, in5L, colSw5I, widSw5I, lineStyleFromStr(stySw5I), extendSw5, o5IL, off5IL)

if showSw15
    lSw15H  := redrawSw(lSw15H,  showSw15H  and ok15, sw15H,   colSw15H, widSw15H, lineStyleFromStr(stySw15H), extendSw15, o15H, off15H)
    lSw15L  := redrawSw(lSw15L,  showSw15L  and ok15, sw15L,   colSw15L, widSw15L, lineStyleFromStr(stySw15L), extendSw15, o15L, off15L)
    lSw15EQ  := redrawSw(lSw15EQ,  showSw15EQ  and ok15, sw15EQ,   colSw15EQ, widSw15EQ, lineStyleFromStr(stySw15EQ), extendSw15, sw15HT >= sw15LT ? o15H : o15L, off15EQ)
    lSw15F  := redrawSw(lSw15F,  showSw15F  and ok15, sw15Fib,   colSw15F, widSw15F, lineStyleFromStr(stySw15F), extendSw15, sw15HT >= sw15LT ? o15H : o15L, off15F)
    lSw15IH := redrawSw(lSw15IH, showSw15I and okI15H, in15H, colSw15I, widSw15I, lineStyleFromStr(stySw15I), extendSw15, o15IH, off15IH)
    lSw15IL := redrawSw(lSw15IL, showSw15I and okI15L, in15L, colSw15I, widSw15I, lineStyleFromStr(stySw15I), extendSw15, o15IL, off15IL)

if showSw1h
    lSw1hH  := redrawSw(lSw1hH,  showSw1hH  and ok1h, sw1hH,   colSw1hH, widSw1hH, lineStyleFromStr(stySw1hH), extendSw1h, o1hH, off1hH)
    lSw1hL  := redrawSw(lSw1hL,  showSw1hL  and ok1h, sw1hL,   colSw1hL, widSw1hL, lineStyleFromStr(stySw1hL), extendSw1h, o1hL, off1hL)
    lSw1hEQ  := redrawSw(lSw1hEQ,  showSw1hEQ  and ok1h, sw1hEQ,   colSw1hEQ, widSw1hEQ, lineStyleFromStr(stySw1hEQ), extendSw1h, sw1hHT >= sw1hLT ? o1hH : o1hL, off1hEQ)
    lSw1hF  := redrawSw(lSw1hF,  showSw1hF  and ok1h, sw1hFib,   colSw1hF, widSw1hF, lineStyleFromStr(stySw1hF), extendSw1h, sw1hHT >= sw1hLT ? o1hH : o1hL, off1hF)
    lSw1hIH := redrawSw(lSw1hIH, showSw1hI and okI1hH, in1hH, colSw1hI, widSw1hI, lineStyleFromStr(stySw1hI), extendSw1h, o1hIH, off1hIH)
    lSw1hIL := redrawSw(lSw1hIL, showSw1hI and okI1hL, in1hL, colSw1hI, widSw1hI, lineStyleFromStr(stySw1hI), extendSw1h, o1hIL, off1hIL)
````
