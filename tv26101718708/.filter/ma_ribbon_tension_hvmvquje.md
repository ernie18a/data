# MA Ribbon Tension

- url: https://www.tradingview.com/script/HVMvqujE-MA-Ribbon-Tension/
- type: indicator
- pine_id: PUB;805c9cd1dae7433889f17ded036279d9
- version: 1.0

## Description

█ OVERVIEW
MA Ribbon Tension is a tool for analyzing the state of a trend, based on a ribbon of six moving averages (MA ribbon). It does not tell you when to buy or sell. Instead, it helps you understand the character of the move: whether a trend exists at all, how strong it is, whether it is only just gaining momentum, whether it is already maturing and losing impetus, or whether the market is transitioning into a consolidation phase.

The core of the indicator is a multi-layer ribbon tension histogram. Each layer represents the gap between adjacent moving averages. Only gaps aligned with the direction of the trend are included in the tension. The trend direction is defined by the position of the fastest moving average (MA 1) relative to the slowest (MA 6). The height of the histogram therefore reflects the width of the ordered ribbon, while its structure shows which part of the ribbon is driving the move.

The picture is completed by: an assessment of the ordering of the moving averages (alignment), a pace profile (young or mature trend), the dynamics phase of the layers, and two-level compression detection. Optionally, divergences between price and tension as well as volume confirmation can be added. A status table continuously gathers all readings in one place. The indicator can also draw the ribbon on the price chart, color candles according to the state of the ribbon, and mark compression with the panel background.

█ CONCEPTS
The indicator combines ribbon analysis of moving averages, gap normalization, pace profile, compression, and optional divergences. The mere arrangement of the moving averages does not create a signal – what matters is their relative layout, width, and the dynamics of changes.

Ribbon structure
The ribbon consists of six moving averages of increasing lengths (by default the Fibonacci sequence 8–13–21–34–55–89). All moving averages are of the same type (EMA, SMA, WMA, RMA, or VWMA).
The direction of the ribbon is determined by the position of MA 1 relative to MA 6:
• MA 1 above MA 6 → bullish direction (histogram above zero),
• MA 1 below MA 6 → bearish direction (histogram below zero).
Alignment is the number of adjacent moving-average pairs (out of five) ordered in the direction of the ribbon. A value of 5/5 means a clean, fully formed ribbon. Lower values indicate a forming trend, a pullback, or tangled moving averages.

Ribbon tension
The gaps between adjacent moving averages are normalized (ATR, % of price, or price units) and accumulated only when the pair is ordered in the direction of the trend. A reversed pair has zero thickness – a tangled ribbon does not inflate the tension.
Layers are drawn from the slowest (next to the zero line) to the fastest (on the outside). Total tension corresponds to the height of the histogram. Rising tension means the ribbon is widening; falling tension means it is contracting.

Ribbon profile
The profile compares the pace read from the fast moving averages (MA 1–3) with the pace read from the slow ones (MA 4–6). Values are scaled so that in a steady trend the profile is approximately 1.0× regardless of the type and length of the moving averages.
• > 1.0× – the fast layers are widening faster than the underlying trend (young or accelerating trend),
• < 1.0× – the trend is carried mainly by the slow averages (mature or slowing),
• within the neutral zone – the profile is stable.
The profile is not rated when tension is too low relative to its average – on a nearly flat ribbon the ratio of the layers carries no information.

Compression
The indicator detects two levels of compression. The width of the ribbon (the sum of the distances between adjacent moving averages, regardless of their order) is compared with percentiles from a selected historical window. Additionally, the moving averages must be tangled – a tight but orderly ribbon indicates a calm trend, not consolidation.
• Local compression – the fast moving averages (MA 1–4) are close together and tangled. This usually indicates consolidation or a flag within an ongoing trend. It appears earlier than full compression.
• Full compression – the entire ribbon (including the slowest moving averages) is tight and tangled. This indicates a mature base after an extended trendless period.
Compression has hysteresis – separate entry and exit thresholds limit signal flickering. It ends when the width exceeds the exit percentile or when the moving averages become fully aligned with the direction. A minimum number of bars can also be set, below which compression is not taken into account. The panel background changes color during active compression (full takes precedence over local).

Trend phase
The indicator classifies the current dynamics of the layers:
• Full expansion – all gaps are widening (impulse phase),
• Momentum fading – fast layers are narrowing while slow layers continue to widen (typical of a fading impulse),
• Widening – total tension is rising,
• Contracting – total tension is falling.

Divergences
An optional module detects regular and hidden divergences between price extremes and the peaks of the tension histogram. Only peaks from the same trend leg are compared, and they must not be more than the set number of bars apart.
• Regular divergence (Bear / Bull) – a sign of a weakening trend. Price makes a higher high while the tension of a bullish ribbon makes a lower one (or a lower low while the tension of a bearish ribbon is smaller).
• Hidden divergence (hBull / hBear) – a continuation signal. Price makes a lower high in an uptrend while tension makes a higher one (or a higher low in a downtrend while tension rises).
Regular divergences are enabled by default; hidden ones are disabled. Labels appear on the confirming bar. Peaks lower than a set multiple of the average tension are ignored.

Volume
A widening ribbon shows that price is moving, but not whether the market is behind the move – an expansion backed by rising participation is more likely to continue than one that happens on thin volume. Optional volume confirmation therefore dims histogram layers that are widening while relative volume is below the threshold. RVOL is calculated as current volume divided by the average and smoothed with an EMA. On instruments without volume data the filter has no effect.

Status table
The diagnostic table continuously shows:
• type and length range of the moving averages,
• ribbon direction,
• alignment (0–5),
• total tension with the normalization unit,
• profile (value and rating: young/accelerating, mature/slowing, stable),
• dynamics phase,
• compression state and its length,
• relative volume (RVOL).
Each row has a tooltip with an explanation.
Candle coloring and ribbon on the price chart
Candles can be colored according to direction, strength (alignment + change in tension), or trend phase. During compression they can take the compression background color. Optionally, candles are additionally dimmed on weak volume.
The moving-average ribbon can be drawn on the price chart with fill between the layers. Layer colors match the histogram (full color when widening with volume, dimmed when there is no volume or when narrowing).

█ FEATURES
• Ribbon of six moving averages (EMA, SMA, WMA, RMA, VWMA) with configurable lengths.
• Tension histogram composed of five layers (gaps between adjacent moving averages).
• Gap normalization: ATR, percent of price, or price units.
• Trend direction based on MA 1 vs MA 6.
• Alignment – number of pairs ordered in the direction (0–5).
• Ribbon profile (ratio of the pace of fast to slow layers) with ratings young/accelerating, mature/slowing, stable.
• Two levels of compression: local (MA 1–4) and full (entire ribbon) with percentiles, a tangled-averages condition, hysteresis, and a minimum length.
• Dynamics phase: Full expansion, Momentum fading, Widening, Contracting.
• Optional regular divergences (Bear/Bull) and hidden divergences (hBull/hBear) between tension and price.
• Filtering of divergence peaks by height relative to average tension.
• Volume confirmation (RVOL) that dims layers without volume participation.
• Status table with direction, alignment, tension, profile, phase, compression, and RVOL.
• Optional moving-average ribbon on the price chart with layer fills.
• Candle coloring by direction, strength, or trend phase, with an option for compression color and dimming on weak volume.
• Configurable layer colors (separately for bullish and bearish order).
• Panel background during compression (local or full).
• Alerts: full expansion (with and without volume), start/end of local and full compression, profile change (at alignment ≥ 4/5), momentum fading, regular divergences, divergences confirmed by declining volume, and hidden divergences.

█ APPLICATIONS
Analysis of trend strength and maturity
Tension and the profile make it possible to distinguish a young, accelerating trend from a mature one that is losing impetus. Alignment shows whether the ribbon is clean or the moving averages have become tangled. The “Momentum fading” phase often appears before a more pronounced slowdown.

Identification of consolidation
Local and full compression highlight periods in which the moving averages are converging. Local compression with wide slow layers usually indicates a flag or consolidation within a trend. Full compression indicates a mature base.

Assessment of move quality
Dimming of layers at low RVOL helps separate moves supported by volume from those without market participation. The table allows you to quickly check whether the current state of the ribbon meets your own quality criteria.

Divergences as a warning
A regular tension divergence relative to price can signal a weakening of the trend before the moving averages reverse. Hidden divergences can confirm continuation after a pullback. The indicator compares only peaks from the same trend leg, which limits false signals.

Example of use
MA Ribbon Tension is best treated as a tool that describes the trend environment rather than as an entry-signal generator. Before making a decision it is worth taking into account:
• alignment and total tension,
• the profile (whether the trend is young or maturing),
• the dynamics phase of the layers,
• the presence and type of compression,
• relative volume,
• any divergences,
• the broader price context and higher timeframes.

The status table allows you to continuously assess the state of the ribbon without having to interpret the histogram itself.

█ NOTES
• Moving-average lengths must increase from MA 1 to MA 6 – otherwise the indicator reports an error.
• Divergences are confirmed with a delay equal to the pivot length (the label appears on the confirming bar).
• When the minimum compression length is greater than 1, the background appears on the confirming bar (N−1 bars after the actual start of the compression). The indicator does not repaint history.
• The profile is not rated when tension is too low.
• Candle coloring overrides the colors set on the chart – when disabled, the default colors return.
• Dimming of layers and candles on weak volume does not work on instruments without volume data; VWMA then behaves like an SMA.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("MA Ribbon Tension", shorttitle = "MA Tension", overlay = false, precision = 2, max_lines_count = 200, max_labels_count = 200)

// Settings
src  = input.source(close, "Source",
     tooltip = "Price series used to calculate all moving averages. Close is the standard choice; hl2 or hlc3 reduce the impact of individual wicks.")

GRP_LEN = "Moving averages (fastest first)"
maType = input.string("EMA", "MA type", options = ["EMA", "SMA", "WMA", "RMA (SMMA)", "VWMA"], group = GRP_LEN,
     tooltip = "Type of moving average forming the ribbon – one type for all six.\nEMA: the standard, fast response.\nSMA: equal weights; the ribbon is more jagged as old bars drop out of the window.\nWMA: faster than an EMA of the same length.\nRMA (SMMA): much slower – RMA(L) ≈ EMA(2L−1); consider shorter lengths.\nVWMA: volume-weighted; behaves like an SMA when no volume data is available.\nProfile, compression and divergences work with every type without changing the settings.")
l1   = input.int(8,  "MA 1", minval = 1, group = GRP_LEN,
     tooltip = "Fastest moving average of the ribbon. Lengths must increase from MA 1 to MA 6.\nThe default set (8–89) is a Fibonacci sequence, well suited to timeframes from 1H to 1D.")
l2   = input.int(13, "MA 2", minval = 1, group = GRP_LEN,
     tooltip = "The MA 1–MA 2 pair forms the outer, fastest-reacting layer of the histogram.")
l3   = input.int(21, "MA 3", minval = 1, group = GRP_LEN,
     tooltip = "MA 1–3 form the fast part of the ribbon, from which the ribbon profile reads the current trend pace.")
l4   = input.int(34, "MA 4", minval = 1, group = GRP_LEN,
     tooltip = "Boundary between the fast and the slow part of the ribbon. Local compression covers MA 1–4.")
l5   = input.int(55, "MA 5", minval = 1, group = GRP_LEN,
     tooltip = "MA 4–6 form the slow part of the ribbon, which describes the underlying trend in the ribbon profile.")
l6   = input.int(89, "MA 6", minval = 1, group = GRP_LEN,
     tooltip = "Slowest moving average – the anchor of the ribbon. Trend direction is defined by the position of MA 1 relative to MA 6.")

normMode   = input.string("ATR", "Normalization", options = ["ATR", "% of price", "None"], group = "Display",
     tooltip = "Unit in which the gaps between moving averages are expressed.\nATR: in volatility units – values are comparable across instruments and periods with different volatility.\n% of price: as a percentage of price – useful for comparing instruments with different price levels.\nNone: in price units – meaningful only within a single instrument.")
atrLen     = input.int(100,"ATR length", minval = 1, group = "Display",
     tooltip = "Period of the ATR used for normalization. A short ATR quickly adapts the scale to current volatility; a longer one (e.g. 100) gives a more stable scale and more comparable histogram peaks.")

// Layer colors: left = pair in bullish order, right = pair in bearish order
GRP_COL = "Layer colors (up | down)"
upC1 = input.color(#a5d6a7, "Layer 1 · MA 1–2", group = GRP_COL, inline = "k1")
dnC1 = input.color(#ef9a9a, "",                 group = GRP_COL, inline = "k1",
     tooltip = "Fastest, outer layer of the histogram. Left color – pair in bullish order, right – in bearish order.")
upC2 = input.color(#66bb6a, "Layer 2 · MA 2–3", group = GRP_COL, inline = "k2")
dnC2 = input.color(#ef5350, "",                 group = GRP_COL, inline = "k2")
upC3 = input.color(#43a047, "Layer 3 · MA 3–4", group = GRP_COL, inline = "k3")
dnC3 = input.color(#e53935, "",                 group = GRP_COL, inline = "k3",
     tooltip = "Layer 3 colors also set the direction color in the status table and the base candle color.")
upC4 = input.color(#2e7d32, "Layer 4 · MA 4–5", group = GRP_COL, inline = "k4")
dnC4 = input.color(#c62828, "",                 group = GRP_COL, inline = "k4")
upC5 = input.color(#1b5e20, "Layer 5 · MA 5–6", group = GRP_COL, inline = "k5")
dnC5 = input.color(#b71c1c, "",                 group = GRP_COL, inline = "k5",
     tooltip = "Slowest layer, next to the zero line. This color is also used to draw MA 6 on the price chart.")

useVol     = input.bool(true, "Volume confirmation", group = "Volume",
     tooltip = "Expansion bars formed while relative volume is below the threshold are shown partially dimmed – a move without participation is less reliable.\nHas no effect on instruments without volume data.")
rvLen      = input.int(20, "Volume average length", minval = 2, group = "Volume",
     tooltip = "Number of bars in the average that current volume is compared with (RVOL = volume ÷ average volume).")
rvMin      = input.float(1.0, "Min. relative volume (RVOL)", minval = 0.1, step = 0.1, group = "Volume",
     tooltip = "Relative volume threshold (smoothed with EMA 3) that confirms an expansion.\n1.0 = at least average volume; 1.5 = clearly elevated.")

showSqzL   = input.bool(true, "Show local compression (MA 1–4)", group = "Compression",
     tooltip = "Highlights the background when the fast moving averages (MA 1–4) are tight and tangled. The signal appears 2–3× earlier than full compression.\nIf the slow layers remain wide at the same time, this is usually a consolidation or a flag within an ongoing trend.")
sqzColL    = input.color(color.silver, "Background color – local", group = "Compression", inline = "sqzL")
sqzTrL     = input.int(85, "Transparency (%)", minval = 0, maxval = 100, group = "Compression", inline = "sqzL",
     tooltip = "Background color and transparency during local compression.")
showSqzF   = input.bool(true, "Show full compression (entire ribbon)", group = "Compression",
     tooltip = "Highlights the background when the entire ribbon – including the slowest moving averages – is tight and tangled. Indicates a mature base after an extended trendless period, from which stronger moves often start.\nA late signal by design: the slowest moving average needs several dozen bars to converge with price.\nWhen both compressions are active, the background shows the full one.")
sqzColF    = input.color(color.gray, "Background color – full", group = "Compression", inline = "sqzF")
sqzTrF     = input.int(85, "Transparency (%)", minval = 0, maxval = 100, group = "Compression", inline = "sqzF",
     tooltip = "Background color and transparency during full compression.")
sqzLen     = input.int(100, "Lookback (bars)", minval = 10, group = "Compression",
     tooltip = "Number of historical bars against which the current ribbon width is evaluated. A longer lookback means the squeeze must be exceptional relative to a longer period.")
sqzPct     = input.float(15, "Entry percentile", minval = 1, maxval = 50, step = 1, group = "Compression",
     tooltip = "Compression starts when the ribbon width falls into the lowest X% of values in the lookback.\nWidth is the sum of distances between adjacent moving averages regardless of their order – compression measures how close the averages are, not their direction.")
sqzExit    = input.float(30, "Exit percentile", minval = 1, maxval = 80, step = 1, group = "Compression",
     tooltip = "An active compression ends when the width rises above this percentile, or – when the alignment condition is enabled – when the moving averages become fully aligned with the direction. The gap between the entry and exit thresholds prevents the signal from flickering at the boundary.\nShould be higher than the entry percentile.")
sqzAlignL  = input.int(2, "Max. alignment – local (0–3)", minval = 0, maxval = 3, group = "Compression",
     tooltip = "How many of the 3 fast moving-average pairs may be aligned with the direction for the state to count as compression. Tight but orderly fast averages indicate a calm trend, not a consolidation ahead of a breakout.\n3 = condition disabled.")
sqzAlignF  = input.int(3, "Max. alignment – full (0–5)", minval = 0, maxval = 5, group = "Compression",
     tooltip = "How many of the 5 moving-average pairs may be aligned with the direction for the state to count as full compression.\n5 = condition disabled.")
sqzMin     = input.int(1, "Min. compression length (bars)", minval = 1, group = "Compression",
     tooltip = "Compressions shorter than this number of bars are not displayed, reported in the table or alerted – this removes single-bar signals.\nThe background appears on the confirmation bar, i.e. N−1 bars after the actual start of the compression; the indicator does not repaint history. 1 = no delay.")

profBand   = input.float(25, "Profile neutral zone (±%)", minval = 0, maxval = 100, step = 5, group = "Ribbon profile",
     tooltip = "The profile compares the trend pace read from the fast moving averages (MA 1–3) with the pace read from the slow ones (MA 4–6). Values are scaled so that in a steady trend the profile is about 1.0, regardless of MA lengths and type.\n> 1: fast layers widen faster than the underlying trend – the trend is young or accelerating.\n< 1: the trend is carried mainly by the slow averages – mature or slowing.\nWithin ±X% around 1.0 the profile is rated as stable.")
profMinRel = input.float(0.3, "Min. tension to rate profile (× average)", minval = 0.0, step = 0.1, group = "Ribbon profile",
     tooltip = "The profile is not rated when ribbon tension is below this multiple of the 100-bar average tension. On a nearly flat ribbon the ratio of fast to slow layers carries no information and takes random, extreme values.")

showDiv    = input.bool(true, "Show tension/price divergences", group = "Divergences",
     tooltip = "Regular divergence – a sign of a weakening trend.\nBear: price makes a higher high while the tension of a bullish ribbon makes a lower one.\nBull: price makes a lower low while the tension of a bearish ribbon is smaller.\nOnly peaks from the same trend leg are compared. The label appears on the confirmation bar.")
showHid    = input.bool(false, "Show hidden divergences (continuation)", group = "Divergences",
     tooltip = "Hidden divergence – a trend continuation signal.\nhBull: in an uptrend price makes a lower high while tension makes a higher one – the trend strengthens despite the price pullback.\nhBear: in a downtrend price makes a higher low while tension rises – selling pressure is building.\nDrawn with a dashed line.")
pvLen      = input.int(2, "Pivot length (bars left and right)", minval = 1, group = "Divergences",
     tooltip = "A histogram peak must be the highest within this many bars on each side. Larger values give fewer but more significant peaks.\nA divergence is confirmed this many bars after the peak – this is also the signal delay.")
maxGap     = input.int(80, "Max. distance between pivots", minval = 5, group = "Divergences",
     tooltip = "Maximum number of bars between the two compared peaks. A divergence stretched over too long a span loses relevance for the current move.")
lblSizeS   = input.string("tiny", "Label size", options = ["tiny", "small", "normal"], group = "Divergences",
     tooltip = "Size of the Bear / Bull / hBull / hBear labels in the indicator pane.")
minRel     = input.float(0.5, "Min. peak height (× average tension)", minval = 0.0, step = 0.1, group = "Divergences",
     tooltip = "Histogram peaks lower than this multiple of the 100-bar average tension are ignored – this filters out minor fluctuations on a flat ribbon. Works the same with every normalization. 0 = filter disabled.")
divBullC   = input.color(#43a047, "Bull color", group = "Divergences", inline = "dc")
divBearC   = input.color(#e53935, "Bear",       group = "Divergences", inline = "dc",
     tooltip = "Line and label colors of regular divergences. The label text color (black / white) is chosen automatically based on background brightness.")
hidBullC   = input.color(#43a047, "hBull color", group = "Divergences", inline = "dh")
hidBearC   = input.color(#e53935, "hBear",       group = "Divergences", inline = "dh",
     tooltip = "Line (dashed) and label colors of hidden divergences.")

showTbl    = input.bool(true, "Show status table", group = "Table",
     tooltip = "Table with the current ribbon state: MA type, direction, alignment, tension, profile, phase, compression and relative volume.")
tblPos     = input.string("Top right", "Position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Table",
     tooltip = "Corner of the pane in which the table is displayed.")
tblSizeS   = input.string("small", "Table size", options = ["tiny", "small", "normal"], group = "Table",
     tooltip = "Text size in the table.")

ovEma      = input.bool(true, "MA ribbon on price chart", group = "Price chart",
     tooltip = "Draws the 6 moving averages on the price chart in colors matching the histogram layers: up / down color = order of the given pair, half-dimmed = layer widening without volume confirmation, dimmed = layer narrowing.\nThe histogram pane remains visible regardless of this option.")
ovFill     = input.bool(true, "Fill between moving averages", group = "Price chart", inline = "ovf")
ovFillTr   = input.int(65, "Transparency (%)", minval = 0, maxval = 100, group = "Price chart", inline = "ovf",
     tooltip = "Fill of the space between adjacent moving averages on the price chart and its transparency.")

GRP_CNDL   = "Candle coloring"
cndlOn     = input.bool(true, "Color candles", group = GRP_CNDL,
     tooltip = "Colors the price chart candles according to the ribbon state. The base color is the direction color (layer 3: up / down).\nOverrides the candle colors set in the chart – when disabled, the default colors return.")
cndlMode   = input.string("Direction + strength", "Mode", options = ["Direction", "Direction + strength", "Trend phase"], group = GRP_CNDL,
     tooltip = "Direction: full up or down color based on the position of MA 1 relative to MA 6.\nDirection + strength: full color with a clean ribbon (5/5) and rising tension; slightly dimmed at 3–4/5 alignment, or at 5/5 with falling tension; strongly dimmed when the moving averages are tangled (0–2/5).\nTrend phase: full color in full expansion, orange when momentum is fading, slightly dimmed while widening, strongly dimmed while contracting – matching the “Phase” row in the table.")
cndlSqz    = input.bool(true, "Compression color during compression", group = GRP_CNDL,
     tooltip = "During compression, candles take the compression background color (local or full, without transparency), clearly separating consolidation from trend. Full compression takes precedence.")
cndlVol    = input.bool(false, "Dim on weak volume", group = GRP_CNDL,
     tooltip = "Additionally dims candles when relative volume is below the threshold from the “Volume” section. Has no effect on instruments without volume data.")

// Dimming strength for a narrowing layer (0 = full color, 1 = background color)
FADE = 0.70

toSize(string s) =>
    switch s
        "tiny"   => size.tiny
        "normal" => size.normal
        => size.small

lblSize = toSize(lblSizeS)
tblSize = toSize(tblSizeS)

// Readable text color on a given background (black on light, white on dark)
textOn(color c) =>
    lum = 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
    lum > 150 ? color.black : color.white

// Validation
if barstate.isfirst and not (l1 < l2 and l2 < l3 and l3 < l4 and l4 < l5 and l5 < l6)
    runtime.error("MA Tension: moving average lengths must increase (MA1 < MA2 < MA3 < MA4 < MA5 < MA6).")

// Calculations
// Moving average of the selected type. maType is an input constant, so the same branch runs on every bar.
// Zero-lag types (HMA, DEMA, TEMA, ZLEMA) are intentionally excluded – in a trend they converge on price and the ribbon loses its meaning.
ma(float s, int len) =>
    switch maType
        "SMA"        => ta.sma(s, len)
        "WMA"        => ta.wma(s, len)
        "RMA (SMMA)" => ta.rma(s, len)
        "VWMA"       => nz(ta.vwma(s, len), ta.sma(s, len))   // without volume data – same as SMA
        => ta.ema(s, len)

e1 = ma(src, l1)
e2 = ma(src, l2)
e3 = ma(src, l3)
e4 = ma(src, l4)
e5 = ma(src, l5)
e6 = ma(src, l6)

normRaw = switch normMode
    "ATR"        => ta.atr(atrLen)
    "% of price" => src / 100.0
    => 1.0
norm = normRaw > 0 ? normRaw : syminfo.mintick   // guard against division by zero

// Gaps between adjacent moving averages (positive = faster MA above slower MA)
g1 = (e1 - e2) / norm
g2 = (e2 - e3) / norm
g3 = (e3 - e4) / norm
g4 = (e4 - e5) / norm
g5 = (e5 - e6) / norm

// Ribbon direction: MA 1 relative to MA 6
dir = e1 >= e6 ? 1.0 : -1.0

// Alignment: number of MA pairs (out of 5) ordered in the ribbon direction
align = (g1 * dir > 0 ? 1 : 0) + (g2 * dir > 0 ? 1 : 0) + (g3 * dir > 0 ? 1 : 0) + (g4 * dir > 0 ? 1 : 0) + (g5 * dir > 0 ? 1 : 0)

// Layer thickness: only pairs ordered in the ribbon direction count.
// A reversed pair has zero thickness, so a tangled ribbon does not inflate tension.
contrib(float g) =>
    math.max(g * dir, 0.0)

d1 = contrib(g1)
d2 = contrib(g2)
d3 = contrib(g3)
d4 = contrib(g4)
d5 = contrib(g5)

// Cumulative layers: slowest pair next to the zero line, fastest on the outside
c1 = d5
c2 = c1 + d4
c3 = c2 + d3
c4 = c3 + d2
c5 = c4 + d1   // total ribbon tension

c5Avg = ta.sma(c5, 100)   // average tension – reference level for the profile and divergence filters

// Ribbon profile
// In a linear trend the lag of a moving average of length L is k·(L−1) bars
// (k = ½ for EMA/SMA/VWMA, ⅓ for WMA, 1 for RMA), so the MA(a)–MA(b) gap ≈ slope × k·(b−a).
// Dividing layer thickness by (b−a)/2 gives the slope seen separately by the fast and the slow averages;
// k is common to the whole ribbon and cancels out in the ratio, so the profile works for every MA type.
fastSlope = (d1 + d2) / ((l3 - l1) / 2.0)
slowSlope = (d4 + d5) / ((l6 - l4) / 2.0)
prof      = slowSlope > 0 ? fastSlope / slowSlope : na
profHi    = 1.0 + profBand / 100.0
profLo    = 1.0 / profHi
// With negligible tension the layer ratio is not meaningful – the profile is not rated
profValid = c5 > 0 and c5 >= profMinRel * nz(c5Avg)
// 1 = young / accelerating, -1 = mature / slowing, 0 = stable or not rated
profState = not profValid ? 0 : slowSlope <= 0 ? 1 : prof > profHi ? 1 : prof < profLo ? -1 : 0

// Compression (two-level)
// Physical width: sum of absolute gaps – measures how close the averages are regardless of their order.
wLoc  = math.abs(g1) + math.abs(g2) + math.abs(g3)     // MA 1–4
wFull = wLoc + math.abs(g4) + math.abs(g5)             // entire ribbon

// Alignment of the fast part measured against its own direction (MA 1 relative to MA 4)
dirF   = e1 >= e4 ? 1.0 : -1.0
alignF = (g1 * dirF > 0 ? 1 : 0) + (g2 * dirF > 0 ? 1 : 0) + (g3 * dirF > 0 ? 1 : 0)

// Compression state with hysteresis: entry below the entry percentile with tangled averages,
// exit above the exit percentile or on full alignment.
// Returns [active, bar count]. Each call keeps its own state.
sqzState(float w, int al, int alMax, int alAll) =>
    thrIn  = ta.percentile_linear_interpolation(w, sqzLen, sqzPct)
    thrOut = ta.percentile_linear_interpolation(w, sqzLen, math.max(sqzExit, sqzPct))
    var bool on = false
    var int  n  = 0
    if not on
        on := w <= thrIn and al <= alMax
    else if w > thrOut or (alMax < alAll and al == alAll)
        on := false
    n := on ? n + 1 : 0
    [on, n]

[sqzLocRaw,  locBars]  = sqzState(wLoc,  alignF, sqzAlignL, 3)
[sqzFullRaw, fullBars] = sqzState(wFull, align,  sqzAlignF, 5)

// Compression is recognized only after reaching the minimum length
sqzLoc  = sqzLocRaw  and locBars  >= sqzMin
sqzFull = sqzFullRaw and fullBars >= sqzMin

locStart  = sqzLocRaw  and locBars  == sqzMin
locEnd    = not sqzLocRaw  and nz(locBars[1])  >= sqzMin
fullStart = sqzFullRaw and fullBars == sqzMin
fullEnd   = not sqzFullRaw and nz(fullBars[1]) >= sqzMin

// Volume
volAvail = ta.cum(nz(volume)) > 0
volSma   = ta.sma(nz(volume), rvLen)
rvol     = volSma > 0 ? nz(volume) / volSma : 1.0
rvolS    = ta.ema(rvol, 3)
volOk    = not useVol or not volAvail or rvolS >= rvMin

// Colors
// Dimming by blending with the background color (instead of transparency), so overlapping columns keep their hue.
mixBg(color c, float t) =>
    bg = chart.bg_color
    color.rgb(color.r(c) + (color.r(bg) - color.r(c)) * t,
              color.g(c) + (color.g(bg) - color.g(c)) * t,
              color.b(c) + (color.b(bg) - color.b(c)) * t)

// Full color: layer widening with volume confirmation.
// Half dimming: layer widening without volume confirmation. Full dimming: layer narrowing.
layerCol(float g, float d, color up, color dn) =>
    base      = g >= 0 ? up : dn
    expanding = d > nz(d[1])
    expanding ? (volOk ? base : mixBg(base, FADE / 2.0)) : mixBg(base, FADE)

col1 = layerCol(g1, d1, upC1, dnC1)   // fastest layer (outer)
col2 = layerCol(g2, d2, upC2, dnC2)
col3 = layerCol(g3, d3, upC3, dnC3)
col4 = layerCol(g4, d4, upC4, dnC4)
col5 = layerCol(g5, d5, upC5, dnC5)   // slowest layer (next to the zero line)

// Histogram (from the highest cumulative layer to the lowest)
// Histogram above zero in an uptrend, below zero in a downtrend
plot(c5 * dir, "Tension · layer MA 1–2", col1, style = plot.style_columns)
plot(c4 * dir, "Tension · layer MA 2–3", col2, style = plot.style_columns)
plot(c3 * dir, "Tension · layer MA 3–4", col3, style = plot.style_columns)
plot(c2 * dir, "Tension · layer MA 4–5", col4, style = plot.style_columns)
plot(c1 * dir, "Tension · layer MA 5–6", col5, style = plot.style_columns)

plot(align, "Alignment (0–5)", display = display.data_window)
plot(profValid ? prof : na, "Profile (fast ÷ slow)", display = display.data_window)

hline(0, "Zero", color.gray, hline.style_dotted)

// Pane background during compression; full compression takes precedence over local
sqzBg = showSqzF and sqzFull ? color.new(sqzColF, sqzTrF) : showSqzL and sqzLoc ? color.new(sqzColL, sqzTrL) : na
bgcolor(sqzBg, title = "Compression background")

// Ribbon on the price chart
// Drawn on the price chart via force_overlay; visibility controlled by the display parameter and color.
ovDisp = ovEma ? display.all : display.none
ovFillCol(color c) =>
    ovEma and ovFill ? color.new(c, ovFillTr) : na

pe1 = plot(e1, "Price: MA 1", color = col1, linewidth = 1, force_overlay = true, display = ovDisp)
pe2 = plot(e2, "Price: MA 2", color = col2, linewidth = 1, force_overlay = true, display = ovDisp)
pe3 = plot(e3, "Price: MA 3", color = col3, linewidth = 1, force_overlay = true, display = ovDisp)
pe4 = plot(e4, "Price: MA 4", color = col4, linewidth = 1, force_overlay = true, display = ovDisp)
pe5 = plot(e5, "Price: MA 5", color = col5, linewidth = 1, force_overlay = true, display = ovDisp)
pe6 = plot(e6, "Price: MA 6", color = col5, linewidth = 2, force_overlay = true, display = ovDisp)

fill(pe1, pe2, ovFillCol(col1), title = "Price: layer 1")
fill(pe2, pe3, ovFillCol(col2), title = "Price: layer 2")
fill(pe3, pe4, ovFillCol(col3), title = "Price: layer 3")
fill(pe4, pe5, ovFillCol(col4), title = "Price: layer 4")
fill(pe5, pe6, ovFillCol(col5), title = "Price: layer 5")

// Trend phase
allExpand = d1 > d1[1] and d2 > d2[1] and d3 > d3[1] and d4 > d4[1] and d5 > d5[1]
// Fast layers (1–2) narrowing while slow layers (4–5) keep widening
outerFade = d1 < d1[1] and d2 < d2[1] and d4 > d4[1] and d5 > d5[1]

expStart  = allExpand and not allExpand[1]
fadeStart = outerFade and not outerFade[1]

// Calculated on every bar so that references to historical values stay consistent
phase = allExpand ? "Full expansion" : outerFade ? "Momentum fading" : c5 > nz(c5[1]) ? "Widening" : "Contracting"

// Candle coloring
// Base color = direction color (layer 3); signal strength expressed by dimming toward the chart background.
CNDL_MID  = 0.35   // light dimming
tensUp    = c5 > nz(c5[1])
cndlBase  = dir > 0 ? upC3 : dnC3

cndlTrend = switch cndlMode
    "Direction"   => cndlBase
    "Trend phase" => allExpand ? cndlBase : outerFade ? color.orange : tensUp ? mixBg(cndlBase, CNDL_MID) : mixBg(cndlBase, FADE)
    => align == 5 and tensUp ? cndlBase : align >= 3 ? mixBg(cndlBase, CNDL_MID) : mixBg(cndlBase, FADE)

// Optional additional dimming when volume is below the threshold
cndlVolCol = cndlVol and volAvail and rvolS < rvMin ? mixBg(cndlTrend, CNDL_MID) : cndlTrend

// Compression overrides the trend color (full compression takes precedence)
cndlSqzCol = not cndlSqz ? na : sqzFull ? color.new(sqzColF, 0) : sqzLoc ? color.new(sqzColL, 0) : na

cndlCol = not cndlOn ? na : not na(cndlSqzCol) ? cndlSqzCol : cndlVolCol
barcolor(cndlCol, title = "Candle color")

// Tension/price divergences
// Peaks are detected on the histogram (c5), so the lines connect the actual column tops.
// Price is read as the extreme within a window around the peak – tension reacts with a slight delay relative to price.
win    = 2 * pvLen + 1
tpRaw  = ta.pivothigh(c5, pvLen, pvLen)         // histogram peak
tp     = not na(tpRaw) and tpRaw >= minRel * nz(c5Avg[pvLen]) ? tpRaw : na   // minor peak filter
pxHi   = ta.highest(high, win)                  // highest price around the peak
pxLo   = ta.lowest(low, win)                    // lowest price around the peak
volWin = math.sum(nz(volume), win) / win        // average volume around the peak
pivDir = dir[pvLen]
pivBar = bar_index - pvLen

// Counter of ribbon direction changes – only peaks from the same trend leg are compared
flipCnt = ta.cum(dir != nz(dir[1], dir) ? 1 : 0)
pivFlip = flipCnt[pvLen]

// Previous peak in an uptrend (u*) and downtrend (s*): price, tension, volume, bar, trend leg
var float uP  = na
var float uT  = na
var float uV  = na
var int   uB  = na
var float uF  = na
var float sP  = na
var float sT  = na
var float sV  = na
var int   sB  = na
var float sF  = na

// Label on the confirmation bar: above a positive column, below a negative one; text in a contrasting color
divLabel(string txt, color c) =>
    y = c5 * dir
    label.new(bar_index, y, txt, xloc.bar_index, yloc.price, c,
         y >= 0 ? label.style_label_down : label.style_label_up, textOn(c), lblSize)

bearDiv = false
bearVol = false
bullDiv = false
bullVol = false
hidBull = false
hidBear = false

if not na(tp)
    if pivDir > 0
        sameLeg = not na(uP) and pivFlip == uF and pivBar - uB <= maxGap
        if sameLeg and pxHi > uP and tp < uT
            bearDiv := true
            bearVol := volAvail and volWin < uV
            if showDiv
                line.new(uB, uT * pivDir, pivBar, tp * pivDir, color = divBearC, width = 1)
                divLabel("Bear", divBearC)
        else if sameLeg and pxHi < uP and tp > uT
            hidBull := true
            if showHid
                line.new(uB, uT * pivDir, pivBar, tp * pivDir, color = hidBullC, width = 1, style = line.style_dashed)
                divLabel("hBull", hidBullC)
        uP  := pxHi
        uT  := tp
        uV  := volWin
        uB  := pivBar
        uF  := pivFlip
    else
        sameLeg = not na(sP) and pivFlip == sF and pivBar - sB <= maxGap
        if sameLeg and pxLo < sP and tp < sT
            bullDiv := true
            bullVol := volAvail and volWin < sV
            if showDiv
                line.new(sB, sT * pivDir, pivBar, tp * pivDir, color = divBullC, width = 1)
                divLabel("Bull", divBullC)
        else if sameLeg and pxLo > sP and tp > sT
            hidBear := true
            if showHid
                line.new(sB, sT * pivDir, pivBar, tp * pivDir, color = hidBearC, width = 1, style = line.style_dashed)
                divLabel("hBear", hidBearC)
        sP  := pxLo
        sT  := tp
        sV  := volWin
        sB  := pivBar
        sF  := pivFlip

// Status table
tPos = switch tblPos
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    => position.bottom_left

var table tbl = table.new(tPos, 2, 8, bgcolor = chart.bg_color, frame_color = color.gray, frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if showTbl and barstate.islast
    fg       = chart.fg_color
    unit     = normMode == "ATR" ? " ATR" : normMode == "% of price" ? " %" : ""
    maName   = maType == "RMA (SMMA)" ? "RMA" : maType
    maTxt    = maName + " " + str.tostring(l1) + "–" + str.tostring(l6)
    dirCol   = dir > 0 ? upC3 : dnC3
    alignCol = align == 5 ? color.green : align >= 3 ? color.orange : color.gray
    phaseCol = allExpand ? color.teal : outerFade ? color.orange : fg
    rvTxt    = volAvail ? str.tostring(rvolS, "0.00") : "n/a"
    rvCol    = not volAvail ? color.gray : rvolS >= rvMin ? color.green : color.gray
    profName = profState == 1 ? "young · accelerating" : profState == -1 ? "mature · slowing" : "stable"
    profNum  = na(prof) or prof > 5 ? "> 5×" : str.tostring(prof, "0.00") + "×"
    profTxt  = not profValid ? "— · tension too low" : profNum + " · " + profName
    profCol  = not profValid ? color.gray : profState == 1 ? color.teal : profState == -1 ? color.orange : fg
    sqzTxt   = sqzFull ? "full · " + str.tostring(fullBars) + " bars" : sqzLoc ? "local · " + str.tostring(locBars) + " bars" : "no"
    sqzTCol  = sqzFull ? sqzColF : sqzLoc ? sqzColL : color.gray

    // Descriptions shown when hovering over a table row
    ttMa    = "Type and length range of the moving averages forming the ribbon (fastest–slowest)."
    ttDir   = "Ribbon direction defined by the position of the fastest moving average (MA 1) relative to the slowest (MA 6).\nBullish: MA 1 above MA 6 – histogram above zero.\nBearish: MA 1 below MA 6 – histogram below zero."
    ttAlign = "Number of adjacent moving-average pairs (out of 5) ordered in the ribbon direction.\n5/5 (green): clean ribbon – fully formed trend.\n3–4/5 (orange): trend forming or in a pullback.\n0–2/5 (gray): moving averages tangled – no clear trend."
    ttTens  = "Total ribbon tension: sum of the gaps between adjacent moving averages ordered in the ribbon direction, expressed in the normalization unit (ATR, % of price or price).\nEquals the histogram height. Higher value = wider ribbon and stronger trend."
    ttProf  = "Ratio of the trend pace read from the fast moving averages (MA 1–3) to the pace read from the slow ones (MA 4–6). In a steady trend it is about 1.0×.\nYoung · accelerating (teal): fast layers are outpacing the underlying trend.\nMature · slowing (orange): the trend is carried mainly by the slow averages.\nStable: value within the neutral zone.\nThe profile is not rated when tension is too low."
    ttPhase = "Current dynamics of the ribbon layers.\nFull expansion: all gaps are widening – impulse phase.\nMomentum fading: fast layers narrowing while slow layers are still widening – a typical sign of a fading impulse.\nWidening: total tension is rising.\nContracting: total tension is falling."
    ttSqz   = "Ribbon compression state and its duration in bars.\nLocal: fast moving averages (MA 1–4) tight and tangled – usually a consolidation or a flag within a trend.\nFull: entire ribbon tight – a mature base ahead of a potentially stronger move.\nNo: no compression."
    ttRvol  = "Relative volume: current volume ÷ average volume, smoothed with EMA 3.\nGreen: volume at or above the confirmation threshold.\nGray: volume below the threshold.\n“n/a”: the instrument does not provide volume data."

    table.cell(tbl, 0, 0, "MAs",         text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttMa)
    table.cell(tbl, 1, 0, maTxt,         text_color = fg, text_size = tblSize, tooltip = ttMa)
    table.cell(tbl, 0, 1, "Direction",   text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttDir)
    table.cell(tbl, 1, 1, dir > 0 ? "Bullish" : "Bearish", text_color = dirCol, text_size = tblSize, tooltip = ttDir)
    table.cell(tbl, 0, 2, "Alignment",   text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttAlign)
    table.cell(tbl, 1, 2, str.tostring(align) + "/5", text_color = alignCol, text_size = tblSize, tooltip = ttAlign)
    table.cell(tbl, 0, 3, "Tension",     text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttTens)
    table.cell(tbl, 1, 3, str.tostring(c5, "0.00") + unit, text_color = fg, text_size = tblSize, tooltip = ttTens)
    table.cell(tbl, 0, 4, "Profile",     text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttProf)
    table.cell(tbl, 1, 4, profTxt,       text_color = profCol, text_size = tblSize, tooltip = ttProf)
    table.cell(tbl, 0, 5, "Phase",       text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttPhase)
    table.cell(tbl, 1, 5, phase,         text_color = phaseCol, text_size = tblSize, tooltip = ttPhase)
    table.cell(tbl, 0, 6, "Compression", text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttSqz)
    table.cell(tbl, 1, 6, sqzTxt,        text_color = sqzTCol, text_size = tblSize, tooltip = ttSqz)
    table.cell(tbl, 0, 7, "RVOL",        text_color = fg, text_size = tblSize, text_halign = text.align_left, tooltip = ttRvol)
    table.cell(tbl, 1, 7, rvTxt,         text_color = rvCol, text_size = tblSize, tooltip = ttRvol)
else if not showTbl and barstate.islast
    table.clear(tbl, 0, 0, 1, 7)

// Alerts (confirmed bars only)
conf   = barstate.isconfirmed
expVol = allExpand and volOk

alertcondition(conf and expStart,                 "Full expansion",                "MA Tension: all gaps are widening")
alertcondition(conf and expVol and not expVol[1], "Full expansion with volume",    "MA Tension: all gaps are widening on elevated volume")
alertcondition(conf and locStart,                 "Local compression – start",     "MA Tension: fast moving averages (MA 1–4) tight and tangled")
alertcondition(conf and locEnd,                   "Local compression – end",       "MA Tension: local compression ended – fast moving averages are diverging")
alertcondition(conf and fullStart,                "Full compression – start",      "MA Tension: entire ribbon tight and tangled")
alertcondition(conf and fullEnd,                  "Full compression – end",        "MA Tension: full compression ended – the ribbon is starting to open")
alertcondition(conf and align >= 4 and profState == 1 and profState[1] != 1,   "Trend accelerating", "MA Tension: ribbon profile changed to 'young / accelerating'")
alertcondition(conf and align >= 4 and profState == -1 and profState[1] != -1, "Trend maturing",     "MA Tension: ribbon profile changed to 'mature / slowing'")
alertcondition(conf and fadeStart,                "Momentum fading",               "MA Tension: fast layers narrowing, slow layers still widening")
alertcondition(conf and (bearDiv or bullDiv),     "Tension divergence",            "MA Tension: ribbon tension/price divergence (Bull / Bear)")
alertcondition(conf and (bearVol or bullVol),     "Tension divergence + volume",   "MA Tension: tension divergence confirmed by declining volume")
alertcondition(conf and (hidBull or hidBear),     "Hidden divergence",             "MA Tension: hidden divergence – trend continuation signal (hBull / hBear)")
````
