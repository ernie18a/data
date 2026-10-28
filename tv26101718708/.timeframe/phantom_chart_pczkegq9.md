# Phantom Chart

- url: https://www.tradingview.com/script/pczkEGQ9-Phantom-Chart/
- type: indicator
- pine_id: PUB;60590fcd7d8c40fc872b744be19bbc16
- version: 5.0

## Description

[b]Phantom Chart — Overlay Any Chart Style While Keeping Real Prices[/b]

Phantom Chart draws an alternative chart visualization on top of your existing chart — without changing the real prices your other indicators depend on. Most indicators and drawing tools read the chart's Open, High, Low, and Close, so switching your base chart to Heikin Ashi or another modified style quietly feeds them altered values instead of real ones.

Phantom Chart solves this: keep your base chart on [b]Bars[/b] or standard [b]Candles[/b] so everything else still reads true prices, then let Phantom Chart render whatever view you actually want to look at on top — Heikin Ashi, a clean line, an area, a baseline, a histogram, and more. You get the visual you read best, and your stops, targets, Fib tools, and other indicators all keep working off real prices.

[b]Available Chart Styles[/b]
[list]
[*]Candles
[*]Bars
[*]Heikin Ashi
[*]Line
[*]Step Line
[*]Area
[*]Baseline
[*]Line with Markers
[*]Columns
[*]Histogram
[/list]

[b]Heikin Ashi Enhancements[/b]
HA is the headline use, so it gets dedicated tools:
[list]
[*][b]Double Smooth[/b] — runs the Heikin Ashi calculation a second time for an even cleaner trend read with almost no noise. Flips are rarer but more reliable.
[*][b]Strong Candles[/b] — highlights candles with no lower wick (strong bullish) or no upper wick (strong bearish), the candles that mark the heart of a trending move.
[*][b]Flip Markers[/b] — a triangle whenever the candle color changes direction, so you never miss a turn.
[*][b]Streak Counter[/b] — a live count of consecutive same-direction candles for gauging trend strength at a glance.
[/list]

[b]Candle Patterns (Candles / Bars)[/b]
[list]
[*][b]Inside Bars[/b] — marks compression bars sitting fully inside the prior bar's range, which often precede an expansion.
[*][b]Engulfing[/b] — marks bars whose body fully engulfs the previous bar in the opposite direction. Bull engulfing below the bar, bear engulfing above.
[/list]

[b]Baseline Tools[/b]
[list]
[*][b]Crossover Markers[/b] — triangles at each cross of the baseline reference, the core baseline signal.
[*][b]Fill To Baseline[/b] — shades green above the baseline, red below, so price position is obvious instantly.
[/list]

[b]Coloring Modes[/b]
[list]
[*][b]Direction[/b] — each bar colored by close versus its own open.
[*][b]Momentum[/b] — each bar colored by close versus the previous close, regardless of the bar's own direction.
[*][b]Trend[/b] — colored by whether price is above or below its moving average, with an optional trend line.
[*][b]Single Color[/b] — one color everywhere.
[/list]

[b]More Controls[/b]
[list]
[*][b]Multi-Timeframe[/b] — render any higher timeframe on your chart, with an optional setting to show only fully-closed bars.
[*][b]Volume-Weighted Opacity[/b] — fades low-volume bars and keeps high-volume bars solid so the heavy bars stand out.
[*][b]Source Smoothing[/b] — optional moving average on the line-style sources.
[*][b]Inverse Chart[/b] — flip the chart vertically for an objectivity check: would you take this trade if it moved the other way?
[*][b]OHLC Labels[/b] — optional last-bar price labels.
[*]Fully customizable colors, widths, wick visibility, and label styling throughout. Every enhancement is an independent toggle, off-by-default where it adds clutter.
[/list]

[b]Recommended Setup[/b]
For accurate visuals, keep your base chart on a standard type (Candles or Bars) and use Phantom Chart for the alternative view. If your base chart itself is set to Heikin Ashi or another transformed type, the overlay will reflect those transformed values rather than real prices — a built-in warning label appears when this is detected.

[b]Tip[/b]
You can add Phantom Chart more than once to layer multiple views — for example a Heikin Ashi read alongside a clean line of real closes — each instance with its own settings.

[i]This script is open-source under the Mozilla Public License 2.0.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © missingmarsupial

//@version=6
indicator("Phantom Chart", "PhanCha", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// GENERAL
// ═══════════════════════════════════════════════════════════════════════════
gG = "General"
enabled   = input.bool(true, "Enabled", inline="g1", group=gG)
chartType = input.string("Heikin Ashi", "", inline="g1", group=gG,
     options=["Candles", "Bars", "Heikin Ashi", "Line", "Step Line", "Area",
              "Baseline", "Line with Markers", "Columns", "Histogram"])
srcType   = input.string("close", "Source", inline="g2", group=gG,
     options=["close", "open", "hl2", "hlc3", "ohlc4"],
     active=chartType != "Candles" and chartType != "Bars" and chartType != "Heikin Ashi",
     tooltip="Sets which price the line, area, baseline, and histogram styles are drawn from. Ignored for Candles, Bars, and Heikin Ashi.")
lineWidth    = input.int(2, "Width", inline="g2", minval=1, maxval=4, group=gG)
show_ha_warning = input.bool(true, "Heikin Ashi Warning", group=gG,
     tooltip="Show a label on the chart when a Heikin Ashi base chart is detected, warning that this overlay reflects modified candle values rather than real prices. Use a standard candle chart as the base for accurate visuals.")
show_info = input.bool(true, "Overlay Info Tag", group=gG,
     tooltip="Small bottom-left note naming what the overlay is currently showing — chart type, higher timeframe, double-smoothing, source smoothing, inversion. An overlay that replaces the chart is easy to misread after a settings change or in a screenshot; this keeps it honest at a glance.")

// ═══════════════════════════════════════════════════════════════════════════
// MULTI-TIMEFRAME
// ═══════════════════════════════════════════════════════════════════════════
gM = "Multi-Timeframe"
useMTF       = input.bool(false, "Use HTF", inline="m1", group=gM)
htf          = input.timeframe("60", "", inline="m1", group=gM, active=useMTF)
mtfConfirmed = input.bool(false, "Wait for HTF Bar Close (non-repaint)", group=gM, active=useMTF,
     tooltip="OFF (default): shows the still-forming higher-timeframe bar. It updates live, so its shape can keep changing until the bar closes. ON: shows only the last fully-closed higher-timeframe bar — its shape is final and won't change, but it arrives one bar later.")

// ═══════════════════════════════════════════════════════════════════════════
// COLORING
// ═══════════════════════════════════════════════════════════════════════════
gC = "Coloring"
colorMode   = input.string("Direction", "Mode", group=gC,
     options=["Direction", "Momentum", "Trend (EMA)", "Single Color"],
     tooltip="Direction: each bar is colored by whether it closed above or below its own open. Momentum: each bar is colored by whether it closed higher or lower than the previous bar, no matter which way the bar itself went. Trend: colored by whether price is above or below its moving average. Single: one color everywhere.")
upColor     = input.color(#26a69a, "Up",   inline="c1", group=gC, active=colorMode != "Single Color")
downColor   = input.color(#ef5350, "Down", inline="c1", group=gC, active=colorMode != "Single Color")
soloColor   = input.color(color.new(color.blue, 0), "Single Color", group=gC, active=colorMode == "Single Color")
trendSource = input.string("Chart TF", "Trend Source", group=gC,
     options=["Chart TF", "Overlay TF"], active=colorMode == "Trend (EMA)",
     tooltip="Chart TF: the trend line is built from the chart's own closing prices. Overlay TF: the trend line is built from whatever this overlay is showing — the higher timeframe when that option is on, and Heikin Ashi closes when the chart type is Heikin Ashi. Best when you want the trend to match exactly what you're looking at.")
trendLen    = input.int(50, "Length", inline="c2", minval=1, group=gC, active=colorMode == "Trend (EMA)")
showTrend   = input.bool(false, "Show Line", inline="c2", group=gC, active=colorMode == "Trend (EMA)")
trendCol    = input.color(color.new(color.yellow, 30), "", inline="c2", group=gC,
     active=colorMode == "Trend (EMA)" and showTrend)
trendStyle  = input.string("Dashed", "Trend Line Style", options=["Solid", "Dashed", "Dotted"],
     group=gC, active=colorMode == "Trend (EMA)" and showTrend)

// ═══════════════════════════════════════════════════════════════════════════
// HEIKIN ASHI ENHANCEMENTS
// ═══════════════════════════════════════════════════════════════════════════
gHA = "Heikin Ashi"
ha_double      = input.bool(false, "Double Smooth",  group=gHA, active=chartType=="Heikin Ashi",
     tooltip="Applies the Heikin Ashi calculation a second time to the already-smoothed HA values. Produces an even cleaner trend picture with almost no noise — flips are rarer but more reliable. Adds some lag compared to standard HA.")
ha_no_wick_on  = input.bool(true,  "Strong Candles", group=gHA, inline="ha_nw", active=chartType=="Heikin Ashi",
     tooltip="Highlight candles with no lower wick (bullish — buyers held the full bar range) or no upper wick (bearish — sellers held the full range). These are the strongest candles in HA analysis and often signal the heart of a trending move.")
ha_no_wick_col = input.color(color.new(color.white, 0), "", group=gHA, inline="ha_nw", active=chartType=="Heikin Ashi")
ha_flip_on     = input.bool(true,  "Flip Markers",   group=gHA, inline="ha_fl",  active=chartType=="Heikin Ashi",
     tooltip="Show a marker when the HA candle color changes direction. Triangle below the bar = flip to bullish. Triangle above = flip to bearish.")
ha_flip_size   = input.string("small", "",            group=gHA, inline="ha_fl",  active=chartType=="Heikin Ashi", options=["tiny","small","normal"])
ha_flip_up_col = input.color(#26a69a, "↑",            group=gHA, inline="ha_fl2", active=chartType=="Heikin Ashi")
ha_flip_dn_col = input.color(#ef5350, "↓",            group=gHA, inline="ha_fl2", active=chartType=="Heikin Ashi")
ha_streak_on   = input.bool(false, "Streak Counter",  group=gHA, inline="ha_st",  active=chartType=="Heikin Ashi",
     tooltip="Show a running count of consecutive same-direction HA candles at the right edge of the chart. Useful for gauging trend momentum — a higher number means a more established, uninterrupted trend.")
ha_streak_col  = input.color(color.new(color.white, 20), "", group=gHA, inline="ha_st", active=chartType=="Heikin Ashi")

// ═══════════════════════════════════════════════════════════════════════════
// CANDLESTICK PATTERNS
// Works on any chart type. On a Heikin Ashi base, choose the detection source:
//   • Standard OHLC  → real candlestick patterns (true open/high/low/close)
//   • Displayed      → patterns on the HA-shaped candles you actually see
// The Standard Candle Overlay can redraw the real candle(s) on top of HA so
// you can SEE the true pattern shape (per the "replace HA candle" request).
// ═══════════════════════════════════════════════════════════════════════════
gCP = "Candlestick Patterns"
cs_on        = input.bool(false, "Enable", inline="cp0", group=gCP)
cs_src       = input.string("Standard OHLC", "Detect On", inline="cp0", group=gCP,
     options=["Standard OHLC", "Displayed Candles"],
     tooltip="Standard OHLC reads the real open/high/low/close from the base chart, so patterns reflect true candles even while you view the Heikin Ashi overlay. Accurate when the base chart is a standard type (Bars/Candles) — the recommended setup. Displayed Candles detects on the HA-shaped candles the overlay draws instead (and respects inversion).")
cs_stdCandle = input.string("On Pattern", "Standard Candle Overlay", group=gCP,
     options=["Off", "On Pattern", "All Bars"],
     tooltip="Draw the REAL standard candles so you can see true candle shapes while viewing the Heikin Ashi overlay. 'On Pattern' draws them only on detected pattern bars (replaces the HA candle right where the pattern is); 'All Bars' draws them everywhere as a real-candle overlay on top. 'On Pattern' is chart-timeframe only — with Use HTF on, pattern labels still appear but the redraw is skipped.")
cs_confirm   = input.bool(false, "Confirm on Bar Close", group=gCP, active=cs_on,
     tooltip="When ON, pattern markers only appear once the bar has fully closed, so a marker never shows up and then vanishes while the bar is still forming. When OFF (default), markers appear live on the forming bar.")
cs_bullCol   = input.color(#26a69a, "Bull", inline="cpc", group=gCP, active=cs_on)
cs_bearCol   = input.color(#ef5350, "Bear", inline="cpc", group=gCP, active=cs_on)
cs_neutCol   = input.color(color.new(color.yellow, 0), "Neutral", inline="cpc", group=gCP, active=cs_on)
cs_dojiThr   = input.float(0.1, "Doji Body %", minval=0.01, maxval=0.5, step=0.01, group=gCP, active=cs_on,
     tooltip="Maximum body size as a fraction of the candle's full range for it to count as a Doji.")
cs_trendLen  = input.int(10, "Trend Context Len", minval=1, group=gCP, active=cs_on,
     tooltip="EMA length used to judge up/down context for context-dependent patterns (Hammer vs Hanging Man, Inverted Hammer vs Shooting Star).")
cs_doji   = input.bool(true,  "Doji",            inline="r1", group=gCP, active=cs_on)
cs_inside = input.bool(true,  "Inside Bar",      inline="r1", group=gCP, active=cs_on,
     tooltip="Bar whose entire range sits inside the previous bar's range (an 'inside day' on the daily timeframe) — a compression signal that often precedes expansion.")
cs_hammer = input.bool(true,  "Hammer",          inline="r2", group=gCP, active=cs_on)
cs_hang   = input.bool(true,  "Hanging Man",     inline="r2", group=gCP, active=cs_on)
cs_invham = input.bool(true,  "Inverted Hammer", inline="r3", group=gCP, active=cs_on)
cs_shoot  = input.bool(true,  "Shooting Star",   inline="r3", group=gCP, active=cs_on)
cs_bulleng= input.bool(true,  "Bull Engulfing",  inline="r4", group=gCP, active=cs_on)
cs_beareng= input.bool(true,  "Bear Engulfing",  inline="r4", group=gCP, active=cs_on)
cs_bullhar= input.bool(false, "Bull Harami",     inline="r5", group=gCP, active=cs_on)
cs_bearhar= input.bool(false, "Bear Harami",     inline="r5", group=gCP, active=cs_on)
cs_morning= input.bool(true,  "Morning Star",    inline="r6", group=gCP, active=cs_on)
cs_evening= input.bool(true,  "Evening Star",    inline="r6", group=gCP, active=cs_on)
cs_3ws    = input.bool(false, "3 White Soldiers", inline="r7", group=gCP, active=cs_on)
cs_3bc    = input.bool(false, "3 Black Crows",    inline="r7", group=gCP, active=cs_on)
cs_pierce = input.bool(false, "Piercing Line",   inline="r8", group=gCP, active=cs_on)
cs_dcc    = input.bool(false, "Dark Cloud Cover", inline="r8", group=gCP, active=cs_on)
cs_dfly   = input.bool(false, "Dragonfly Doji",  inline="r9", group=gCP, active=cs_on,
     tooltip="Doji with a long lower shadow and almost no upper shadow — sellers pushed price down but buyers reclaimed the whole move by the close. Bullish, strongest after a decline. Gravestone is the mirror image (bearish). When one of these fires, the plain Doji marker is suppressed for that bar.")
cs_grave  = input.bool(false, "Gravestone Doji", inline="r9", group=gCP, active=cs_on)
cs_tweez  = input.bool(false, "Tweezers",        inline="r10", group=gCP, active=cs_on,
     tooltip="Two consecutive bars holding the same level: Tweezer Bottom (bullish) — a down bar then an up bar with matching lows; Tweezer Top (bearish) — an up bar then a down bar with matching highs. 'Matching' allows a small tolerance so near-identical wicks still count.")
cs_maru   = input.bool(false, "Marubozu",        inline="r10", group=gCP, active=cs_on,
     tooltip="A candle that is almost all body with no meaningful shadows — one side controlled the entire bar from open to close. Marked bullish or bearish by its direction.")

// ═══════════════════════════════════════════════════════════════════════════
// DIVERGENCE
// Regular and hidden bull/bear divergence between price and an oscillator.
// Detected on confirmed pivots (repaints within the right-bars window, like
// all pivot-based divergence). Drawn on the price pane (overlay) between the
// two pivots. Uses real price by default so the signal is independent of HA.
// ═══════════════════════════════════════════════════════════════════════════
gD = "Divergence"
div_on       = input.bool(false, "Enable", inline="d0", group=gD)
div_osc      = input.string("RSI", "Oscillator", inline="d0", group=gD,
     options=["RSI", "MACD", "Stochastic", "CCI", "MFI"], active=div_on)
div_len      = input.int(14, "Osc Length", inline="d1", minval=1, group=gD, active=div_on)
div_pivL     = input.int(5, "Pivot Left",  inline="d2", minval=1, group=gD, active=div_on)
div_pivR     = input.int(5, "Pivot Right", inline="d2", minval=1, group=gD, active=div_on,
     tooltip="Bars required on each side of a pivot for it to confirm. Larger = fewer, more significant pivots, but a longer confirmation delay.")
div_reg      = input.bool(true,  "Regular", inline="d3", group=gD, active=div_on,
     tooltip="Regular divergence — momentum failing to confirm price extremes. Bull: price lower low, oscillator higher low. Bear: price higher high, oscillator lower high. A reversal signal.")
div_hid      = input.bool(false, "Hidden",  inline="d3", group=gD, active=div_on,
     tooltip="Hidden divergence — continuation. Bull: price higher low, oscillator lower low. Bear: price lower high, oscillator higher high.")
div_priceStd = input.bool(true, "Use Standard Price", group=gD, active=div_on,
     tooltip="Run divergence on real OHLC (recommended) rather than the displayed Heikin Ashi values, so the signal reflects true price.")
div_lines    = input.bool(true, "Connect Pivots", group=gD, inline="d4", active=div_on)
div_bullCol  = input.color(#26a69a, "Bull", inline="d5", group=gD, active=div_on)
div_bearCol  = input.color(#ef5350, "Bear", inline="d5", group=gD, active=div_on)

// ═══════════════════════════════════════════════════════════════════════════
// VOLUME-WEIGHTED OPACITY
// ═══════════════════════════════════════════════════════════════════════════
gV = "Volume-Weighted Opacity"
volOp         = input.bool(false, "Enable", inline="v1", group=gV,
     tooltip="Makes higher-volume bars more solid and lower-volume bars more faded, so heavy-volume bars stand out. Overrides any transparency set in the color pickers.")
volLookback   = input.int(50, "Lookback", inline="v1", minval=2, group=gV, active=volOp)
volMinOpacity = input.int(30, "Min Opacity %", minval=0, maxval=100, group=gV, active=volOp,
     tooltip="How visible the lowest-volume bars stay. Higher-volume bars are always fully solid.")

// ═══════════════════════════════════════════════════════════════════════════
// SOURCE SMOOTHING (line family)
// ═══════════════════════════════════════════════════════════════════════════
gS = "Source Smoothing"
smoothOn   = input.bool(false, "Enable", inline="s1", group=gS,
     tooltip="Smooths the Source with a moving average before drawing the line, area, baseline, and histogram styles.")
smoothType = input.string("EMA", "", inline="s1", options=["SMA", "EMA", "WMA", "RMA"], group=gS, active=smoothOn)
smoothLen  = input.int(9, "Length", inline="s1", minval=1, group=gS, active=smoothOn)

// ═══════════════════════════════════════════════════════════════════════════
// STYLE
// ═══════════════════════════════════════════════════════════════════════════
gSt = "Style"
lineColor   = input.color(color.new(color.blue, 0), "Line / Area Color", group=gSt,
     tooltip="Color used for the line, area, baseline, and histogram styles when Mode is set to Single Color.")
borderUpCol = input.color(#26a69a, "Up Border",   inline="st1", group=gSt)
borderDnCol = input.color(#ef5350, "Down Border", inline="st1", group=gSt)
showWicks   = input.bool(true, "Show Wicks", inline="st2", group=gSt)
wickCol     = input.color(color.new(color.gray, 30), "", inline="st2", group=gSt, active=showWicks)

// ═══════════════════════════════════════════════════════════════════════════
// BASELINE / HISTOGRAM BASE
// ═══════════════════════════════════════════════════════════════════════════
gB = "Baseline / Histogram"
isBaseType   = chartType == "Baseline"
isHistType   = chartType == "Columns" or chartType == "Histogram"
baselineMode = input.string("Auto (first bar HL2)", "Baseline Ref",
     options=["Auto (first bar HL2)", "Manual"], group=gB, active=isBaseType)
baselineVal  = input.float(0.0, "Manual Value", group=gB,
     active=isBaseType and baselineMode == "Manual")
baseCrossOn  = input.bool(true, "Crossover Markers", group=gB, inline="bx", active=isBaseType,
     tooltip="Mark each bar where price crosses the baseline reference. Up triangle = cross above (bullish), down triangle = cross below (bearish). The cross itself is the core baseline signal.")
baseCrossUp  = input.color(#26a69a, "↑", group=gB, inline="bx", active=isBaseType)
baseCrossDn  = input.color(#ef5350, "↓", group=gB, inline="bx", active=isBaseType)
baseFillOn   = input.bool(false, "Fill To Baseline", group=gB, active=isBaseType,
     tooltip="Shade the area between price and the baseline reference — green when price is above it, red when below. Makes it obvious at a glance which side of the baseline price is on.")
histBase     = input.float(0.0, "Histogram Base", group=gB, active=isHistType,
     tooltip="The price level that columns and histogram bars are measured from. Default 0 draws them up from zero — fine for crypto and indices with low prices, but on a high-priced stock set this to the bottom of the visible range so the bars aren't oversized. Not affected by Invert Chart.")

// ═══════════════════════════════════════════════════════════════════════════
// INVERSE CHART
// ═══════════════════════════════════════════════════════════════════════════
gI = "Inverse Chart"
invertOn  = input.bool(false, "Invert", inline="i1", group=gI,
     tooltip="Flips prices vertically around the pivot. Useful for objectivity checks (would I trade this if it moved the other way?).")
pivotMode = input.string("Auto (first bar HL2)", "Pivot", inline="i1",
     options=["Auto (first bar HL2)", "Manual"], group=gI, active=invertOn)
pivotVal  = input.float(0.0, "Manual Pivot Value", group=gI,
     active=invertOn and pivotMode == "Manual")

// ═══════════════════════════════════════════════════════════════════════════
// OHLC LABELS
// ═══════════════════════════════════════════════════════════════════════════
gL = "OHLC Labels"
showLabels  = input.bool(false, "Show Last Bar OHLC", inline="l1", group=gL)
labelOffset = input.int(5, "Offset", inline="l1", minval=0, group=gL, active=showLabels)
labelSize   = input.string("small", "Size", options=["tiny", "small", "normal", "large"], group=gL, active=showLabels)
labelBold   = input.bool(true, "Bold", group=gL, active=showLabels)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
gA = "Alerts"
alert_on = input.bool(false, "All-Events Alert Stream", group=gA,
     tooltip='When ON, every enabled signal fires a detailed alert message — HA flips, strong candles, streak milestones, baseline crosses, candlestick patterns, and divergences.\n\nTo arm: right-click the chart → Add alert → set Condition to this indicator → choose "Any alert() function call".\n\nFor targeted alerts instead, leave this OFF and pick a specific Condition from the dropdown — every signal type has its own entry (HA Flip Up/Down, Strong HA Candle, Streak Milestone, Baseline Cross Up/Down, Bullish/Bearish/Neutral Pattern, Bullish/Bearish Divergence). The two modes can run side-by-side.')
streak_alert_len = input.int(5, "Streak Milestone", minval=2, group=gA,
     tooltip="The Streak Milestone alert fires when the count of consecutive same-direction Heikin Ashi candles reaches this number.")

// ═══════════════════════════════════════════════════════════════════════════
// DATA RESOLUTION (MTF)
// ───────────────────────────────────────────────────────────────────────────
// DESIGN NOTE — recommended use:
//   Set your BASE chart to a standard type (Candles or Bars) and use Phantom
//   Chart to overlay alternative visualizations (Heikin Ashi, Line, Area,
//   Histogram, etc.). This is the "use complex chart as a base, easy chart
//   as the overlay" pattern — except in Pine v6, the cleanest way to access
//   real OHLC is to just READ the chart's open/high/low/close directly,
//   which only equals real OHLC when the base is standard.
//
//   Pine v6's request.security at the chart's own timeframe is unreliable
//   for stripping chart-type modifiers — ticker.standard() and manual ticker
//   construction both have edge-case failures (mirror the base, or collapse
//   to single-value). Until TradingView resolves this, the script reads
//   chart context directly on chart-TF and uses security only for HTF.
//
//   Practical implication: if the base chart is on HA/Renko/Kagi/etc., the
//   overlay will reflect those transformed values (overlay "Candles" on an
//   HA base will look like HA). The reverse direction works perfectly —
//   any chart type as overlay on a standard base.
// ═══════════════════════════════════════════════════════════════════════════
tf = useMTF ? htf : timeframe.period
useConfirmed = mtfConfirmed and useMTF

cleanTicker = ticker.standard(syminfo.tickerid)

// Each request only runs for the mode that actually consumes it. With Use HTF
// off, chart context is read directly and both calls were pure per-bar waste.
[devO, devH, devL, devC, devV] = if useMTF and not mtfConfirmed
    request.security(cleanTicker, tf, [open, high, low, close, volume], barmerge.gaps_off, barmerge.lookahead_off)
else
    [float(na), float(na), float(na), float(na), float(na)]
[conO, conH, conL, conC, conV] = if useConfirmed
    request.security(cleanTicker, tf, [open[1], high[1], low[1], close[1], volume[1]], barmerge.gaps_off, barmerge.lookahead_on)
else
    [float(na), float(na), float(na), float(na), float(na)]

mO = useMTF ? (useConfirmed ? conO : devO) : open
mH = useMTF ? (useConfirmed ? conH : devH) : high
mL = useMTF ? (useConfirmed ? conL : devL) : low
mC = useMTF ? (useConfirmed ? conC : devC) : close
mV = useMTF ? (useConfirmed ? conV : devV) : volume

// True on the first chart bar of each displayed (higher-timeframe) bar —
// simply every bar when Use HTF is off. All sequential math below (the HA
// recursion, streak counter, pattern lookbacks, fire-once latches) advances
// on this flag instead of once per chart bar, which is what keeps HTF mode
// honest: an HTF bar repeats across many chart bars.
htfNew = useMTF ? timeframe.change(tf) : true

// Heikin Ashi computed at script level from real OHLC.
// Script-level `var` reliably persists across bars (unlike inside a function
// inside request.security, which collapses the recursive formula).
// The open only advances on htfNew: previously the recursion re-applied on
// every chart bar, so with Use HTF on the HA open drifted toward the close
// inside each repeated HTF bar. The close stays live so the forming bar
// still updates tick by tick.
var float ha_O = na
ha_C = (mO + mH + mL + mC) / 4
if htfNew or na(ha_O)
    ha_O := na(ha_O) ? (mO + mC) / 2 : (ha_O + ha_C[1]) / 2
ha_H = math.max(mH, math.max(ha_O, ha_C))
ha_L = math.min(mL, math.min(ha_O, ha_C))

hO = ha_O
hH = ha_H
hL = ha_L
hC = ha_C

// Double-smooth HA — apply HA formula a second time to the first-pass values.
var float sha_O = na
sha_C  = (hO + hH + hL + hC) / 4
if htfNew or na(sha_O)
    sha_O := na(sha_O) ? (hO + hC) / 2 : (sha_O + sha_C[1]) / 2
sha_H  = math.max(hH, math.max(sha_O, sha_C))
sha_L  = math.min(hL, math.min(sha_O, sha_C))

// Rendered HA — single or double smooth
rHaO = chartType == "Heikin Ashi" and ha_double ? sha_O : hO
rHaC = chartType == "Heikin Ashi" and ha_double ? sha_C : hC
rHaH = chartType == "Heikin Ashi" and ha_double ? sha_H : hH
rHaL = chartType == "Heikin Ashi" and ha_double ? sha_L : hL

// ═══════════════════════════════════════════════════════════════════════════
// SOURCE & SMOOTHING
// ═══════════════════════════════════════════════════════════════════════════
srcRaw = switch srcType
    "open"  => mO
    "hl2"   => (mH + mL) / 2
    "hlc3"  => (mH + mL + mC) / 3
    "ohlc4" => (mO + mH + mL + mC) / 4
    =>         mC

srcSmoothed = switch smoothType
    "SMA" => ta.sma(srcRaw, smoothLen)
    "WMA" => ta.wma(srcRaw, smoothLen)
    "RMA" => ta.rma(srcRaw, smoothLen)
    =>       ta.ema(srcRaw, smoothLen)

src = smoothOn ? srcSmoothed : srcRaw

// ═══════════════════════════════════════════════════════════════════════════
// TREND EMA — Chart TF or Overlay TF (HA-aware when chart type = Heikin Ashi)
// ═══════════════════════════════════════════════════════════════════════════
// The security call only runs when the Trend color mode actually reads the
// overlay-TF EMA on a non-HA chart type — otherwise it was a wasted request.
_trendSecNeeded = colorMode == "Trend (EMA)" and trendSource == "Overlay TF" and chartType != "Heikin Ashi"
trendEmaSec = if _trendSecNeeded
    request.security(cleanTicker, tf, ta.ema(close, trendLen), barmerge.gaps_off, barmerge.lookahead_off)
else
    float(na)
trendEmaOverlay = chartType == "Heikin Ashi" ? ta.ema(rHaC, trendLen) : trendEmaSec
trendEmaChart   = ta.ema(close, trendLen)
trendEma        = trendSource == "Overlay TF" ? trendEmaOverlay : trendEmaChart

trendBase = trendSource == "Overlay TF" ? (chartType == "Heikin Ashi" ? rHaC : mC) : close
trendIsUp = invertOn ? trendBase < trendEma : trendBase > trendEma

// ═══════════════════════════════════════════════════════════════════════════
// INVERSE PIVOT
// ═══════════════════════════════════════════════════════════════════════════
var float autoPivot = na
if barstate.isfirst
    autoPivot := hl2
pivot = pivotMode == "Manual" ? pivotVal : autoPivot

inv(v) => invertOn ? 2 * pivot - v : v

iO   = inv(mO)
iC   = inv(mC)
iH   = invertOn ? inv(mL) : mH
iL   = invertOn ? inv(mH) : mL
iHaO = inv(rHaO)
iHaC = inv(rHaC)
iHaH = invertOn ? inv(rHaL) : rHaH
iHaL = invertOn ? inv(rHaH) : rHaL
iSrc = inv(src)

// ═══════════════════════════════════════════════════════════════════════════
// BASELINE & HISTOGRAM BASE
// ═══════════════════════════════════════════════════════════════════════════
var float autoBaseline = na
if barstate.isfirst
    autoBaseline := hl2
baseline = baselineMode == "Manual" ? baselineVal : autoBaseline
iBaseline = inv(baseline)

// ═══════════════════════════════════════════════════════════════════════════
// COLOR RESOLUTION
// ═══════════════════════════════════════════════════════════════════════════
candleIsUp = iC   >= iO
haIsUp     = iHaC >= iHaO
lineIsUp   = iSrc >= nz(iSrc[1], iSrc)
candleSlopeUp = iC   >= nz(iC[1], iC)
haSlopeUp     = iHaC >= nz(iHaC[1], iHaC)

dirColor(dirUp, slopeUp) =>
    colorMode == "Trend (EMA)"    ? (trendIsUp ? upColor : downColor)
     : colorMode == "Single Color" ? soloColor
     : colorMode == "Momentum"     ? (slopeUp ? upColor : downColor)
     :                                (dirUp ? upColor : downColor)

candleCol    = dirColor(candleIsUp, candleSlopeUp)
haCol        = dirColor(haIsUp, haSlopeUp)
lineCol      = colorMode == "Single Color" ? lineColor : dirColor(lineIsUp, lineIsUp)
borderCandle = candleIsUp ? borderUpCol : borderDnCol
borderHA     = haIsUp     ? borderUpCol : borderDnCol

// HA enhancements — strong candle, flip, streak
_htick        = syminfo.mintick * 0.5
haNoLowerWick = math.abs(iHaL - math.min(iHaO, iHaC)) < _htick
haNoUpperWick = math.abs(iHaH - math.max(iHaO, iHaC)) < _htick
haStrongCandle = ha_no_wick_on and ((haIsUp and haNoLowerWick) or (not haIsUp and haNoUpperWick))

// Raw flips are tracked separately from the marker toggle so the streak
// counter (and streak alerts) keep working even with Flip Markers off.
_prevHaIsUp  = bar_index == 0 ? haIsUp : haIsUp[1]
_haFlipRawUp = haIsUp and not _prevHaIsUp
_haFlipRawDn = not haIsUp and _prevHaIsUp
haFlipToBull = ha_flip_on and _haFlipRawUp
haFlipToBear = ha_flip_on and _haFlipRawDn

// Streak counts DISPLAYED bars: a flip resets it, and it only increments when
// a new (higher-timeframe) bar starts — previously HTF mode inflated the
// count by one per chart bar inside every HTF bar.
var int _haStreak = 1
if _haFlipRawUp or _haFlipRawDn
    _haStreak := 1
else if htfNew and bar_index > 0
    _haStreak := _haStreak + 1

// ═══════════════════════════════════════════════════════════════════════════
// VOLUME-WEIGHTED OPACITY
// ═══════════════════════════════════════════════════════════════════════════
volMA      = ta.sma(mV, volLookback)
// Guard: symbols without volume data (many indices) return na — treat as full
// opacity instead of letting na wipe the bar colors entirely.
volRatio   = volOp and not na(mV) and not na(volMA) ? math.min(mV / math.max(volMA, 1e-9), 1.0) : 1.0
volOpacity = volMinOpacity + (100 - volMinOpacity) * volRatio
volTransp  = volOp ? math.round(100 - volOpacity) : 0

withVolOp(c) => volOp ? color.new(c, volTransp) : c

// ═══════════════════════════════════════════════════════════════════════════
// FLAGS
// ═══════════════════════════════════════════════════════════════════════════
on          = enabled
showCandles = on and chartType == "Candles"
showBars    = on and chartType == "Bars"
showHA      = on and chartType == "Heikin Ashi"
showLine    = on and chartType == "Line"
showStep    = on and chartType == "Step Line"
showArea    = on and chartType == "Area"
showBase    = on and chartType == "Baseline"
showMarkers = on and chartType == "Line with Markers"
showCol     = on and chartType == "Columns"
showHist    = on and chartType == "Histogram"

wickFinal = showWicks ? wickCol : color.new(color.white, 100)

// ═══════════════════════════════════════════════════════════════════════════
// PLOTS — OHLC FAMILY
// ═══════════════════════════════════════════════════════════════════════════
plotcandle(showCandles ? iO : na, showCandles ? iH : na, showCandles ? iL : na, showCandles ? iC : na,
     "Candles",
     color       = withVolOp(candleCol),
     bordercolor = withVolOp(borderCandle),
     wickcolor   = wickFinal)

plotbar(showBars ? iO : na, showBars ? iH : na, showBars ? iL : na, showBars ? iC : na,
     "Bars",
     color = withVolOp(candleCol))

// ─── CANDLESTICK PATTERN DETECTION ──────────────────────────────────────────
// Source: real standard OHLC, or the displayed (possibly inverted/HA) candles.
csA       = cs_on and enabled
useStdPat = cs_src == "Standard OHLC"
// Displayed geometry: the HA candle when the overlay renders HA, else the
// (possibly inverted) raw OHLC the user is looking at.
dispIsHA = chartType == "Heikin Ashi"
dpO = dispIsHA ? iHaO : iO
dpH = dispIsHA ? iHaH : iH
dpL = dispIsHA ? iHaL : iL
dpC = dispIsHA ? iHaC : iC
// mO/mH/mL/mC are the real OHLC read directly from chart context (and respect
// HTF), so on a standard base — Bars/Candles, the recommended setup — they ARE
// true OHLC without the unreliable ticker.standard round-trip.
pO = useStdPat ? mO : dpO
pH = useStdPat ? mH : dpH
pL = useStdPat ? mL : dpL
pC = useStdPat ? mC : dpC

pRng  = pH - pL
pBody = math.abs(pC - pO)
pUp   = pC > pO
pDn   = pC < pO
pUw   = pH - math.max(pO, pC)          // upper wick
pLw   = math.min(pO, pC) - pL          // lower wick
// Context EMA runs on chart bars; with Use HTF it smooths the repeated HTF
// values (slower but directionally identical), which is fine for context.
pCtx  = ta.ema(pC, cs_trendLen)
pDownCtx = pC < pCtx
pUpCtx   = pC > pCtx
_vRng = pRng > 0

// One- and two-bars-back values of the DISPLAYED series. On the chart TF
// these are plain [1]/[2] lookbacks; with Use HTF they are snapshots captured
// each time the HTF bar rolls, so multi-bar patterns compare real consecutive
// HTF bars instead of an HTF bar against its own chart-bar repeats.
var float _qO1 = na
var float _qH1 = na
var float _qL1 = na
var float _qC1 = na
var float _qO2 = na
var float _qC2 = na
if useMTF and htfNew
    _qO2 := _qO1
    _qC2 := _qC1
    _qO1 := pO[1]
    _qH1 := pH[1]
    _qL1 := pL[1]
    _qC1 := pC[1]
pO1 = useMTF ? _qO1 : pO[1]
pH1 = useMTF ? _qH1 : pH[1]
pL1 = useMTF ? _qL1 : pL[1]
pC1 = useMTF ? _qC1 : pC[1]
pO2 = useMTF ? _qO2 : pO[2]
pC2 = useMTF ? _qC2 : pC[2]
pUp1 = pC1 > pO1
pDn1 = pC1 < pO1
pUp2 = pC2 > pO2
pDn2 = pC2 < pO2
pBody1 = math.abs(pC1 - pO1)

_longLower = pLw >= pBody * 2 and pBody > 0
_longUpper = pUw >= pBody * 2 and pBody > 0
_smallUp   = pUw <= pBody
_smallLow  = pLw <= pBody
_body2 = math.abs(pC2 - pO2)
_mid2  = (pO2 + pC2) / 2
_twzTol = math.max(syminfo.mintick, pRng * 0.05)

isDfly     = cs_dfly  and _vRng and pBody <= pRng * cs_dojiThr and pLw >= pRng * 0.6 and pUw <= pRng * 0.1
isGrave    = cs_grave and _vRng and pBody <= pRng * cs_dojiThr and pUw >= pRng * 0.6 and pLw <= pRng * 0.1
isDoji     = cs_doji   and _vRng and pBody <= pRng * cs_dojiThr and not isDfly and not isGrave
isInside   = cs_inside and pH < pH1 and pL > pL1
isHammer   = cs_hammer and _vRng and _longLower and _smallUp  and pDownCtx
isHang     = cs_hang   and _vRng and _longLower and _smallUp  and pUpCtx
isInvHam   = cs_invham and _vRng and _longUpper and _smallLow and pDownCtx
isShoot    = cs_shoot  and _vRng and _longUpper and _smallLow and pUpCtx
isMaruBull = cs_maru and _vRng and pUp and pBody >= pRng * 0.95
isMaruBear = cs_maru and _vRng and pDn and pBody >= pRng * 0.95
isTwzBot   = cs_tweez and pDn1 and pUp and math.abs(pL - pL1) <= _twzTol
isTwzTop   = cs_tweez and pUp1 and pDn and math.abs(pH - pH1) <= _twzTol
isBullEng  = cs_bulleng and pUp and pDn1 and pC >= pO1 and pO <= pC1
isBearEng  = cs_beareng and pDn and pUp1 and pO >= pC1 and pC <= pO1
isBullHar  = cs_bullhar and pDn1 and pUp and pO >= pC1 and pC <= pO1 and pBody < pBody1
isBearHar  = cs_bearhar and pUp1 and pDn and pO <= pC1 and pC >= pO1 and pBody < pBody1
isMorning  = cs_morning and pDn2 and pBody1 < _body2 * 0.5 and pUp and pC > _mid2
isEvening  = cs_evening and pUp2 and pBody1 < _body2 * 0.5 and pDn and pC < _mid2
isThreeWS  = cs_3ws and pUp and pUp1 and pUp2 and pC > pC1 and pC1 > pC2 and pO < pC1 and pO > pO1 and pO1 < pC2 and pO1 > pO2
isThreeBC  = cs_3bc and pDn and pDn1 and pDn2 and pC < pC1 and pC1 < pC2 and pO > pC1 and pO < pO1 and pO1 > pC2 and pO1 < pO2
isPiercing = cs_pierce and pDn1 and pUp and pO < pC1 and pC > (pO1+pC1)/2 and pC < pO1
isDarkCloud= cs_dcc and pUp1 and pDn and pO > pC1 and pC < (pO1+pC1)/2 and pC > pO1

// Pattern markers are LABELS, not plotshapes — TradingView caps a script at 64
// plot outputs, so 16 plotshapes would blow the budget. Labels use the separate
// max_labels_count pool (500). All patterns firing on one bar are merged into a
// single label per direction: 🟢 bullish (below bar), 🔴 bearish / 🟡 neutral (above).
_bullTxt = (isHammer ? "H " : "") + (isInvHam ? "IH " : "") + (isDfly ? "DD " : "") + (isTwzBot ? "TwB " : "") + (isMaruBull ? "MZ " : "") + (isBullEng ? "BuE " : "") + (isBullHar ? "BuH " : "") + (isMorning ? "MS " : "") + (isThreeWS ? "3WS " : "") + (isPiercing ? "PL " : "")
_bearTxt = (isHang ? "HM " : "") + (isShoot ? "SS " : "") + (isGrave ? "GD " : "") + (isTwzTop ? "TwT " : "") + (isMaruBear ? "MZ " : "") + (isBearEng ? "BeE " : "") + (isBearHar ? "BeH " : "") + (isEvening ? "ES " : "") + (isThreeBC ? "3BC " : "") + (isDarkCloud ? "DCC " : "")
_neutTxt = (isDoji ? "D " : "") + (isInside ? "IB " : "")

// Fire-once latches: with Use HTF a detection stays true for every chart bar
// of the HTF period — these make each label (and its alert) fire once per
// displayed bar instead of once per chart bar. On the chart TF the latches
// reset every bar, so behavior there is unchanged. The Confirm on Bar Close
// toggle additionally holds fire until the bar is final.
var bool _bullDone = false
var bool _bearDone = false
var bool _neutDone = false
if htfNew
    _bullDone := false
    _bearDone := false
    _neutDone := false
_csClosed = not cs_confirm or barstate.isconfirmed
_bullFire = csA and _csClosed and _bullTxt != "" and not _bullDone
_bearFire = csA and _csClosed and _bearTxt != "" and not _bearDone
_neutFire = csA and _csClosed and _neutTxt != "" and not _neutDone

if _bullFire
    _bullDone := true
    label.new(bar_index, low, "🟢 " + _bullTxt, xloc=xloc.bar_index, yloc=yloc.belowbar,
         color=color.new(color.gray, 100), style=label.style_label_up, textcolor=cs_bullCol, size=size.small)
if _bearFire
    _bearDone := true
    label.new(bar_index, high, "🔴 " + _bearTxt, xloc=xloc.bar_index, yloc=yloc.abovebar,
         color=color.new(color.gray, 100), style=label.style_label_down, textcolor=cs_bearCol, size=size.small)
if _neutFire
    _neutDone := true
    label.new(bar_index, high, "🟡 " + _neutTxt, xloc=xloc.bar_index, yloc=yloc.abovebar,
         color=color.new(color.gray, 100), style=label.style_label_down, textcolor=cs_neutCol, size=size.small)

plotcandle(showHA ? iHaO : na, showHA ? iHaH : na, showHA ? iHaL : na, showHA ? iHaC : na,
     "Heikin Ashi",
     color       = showHA and haStrongCandle ? withVolOp(ha_no_wick_col) : withVolOp(haCol),
     bordercolor = showHA and haStrongCandle ? withVolOp(ha_no_wick_col) : withVolOp(borderHA),
     wickcolor   = wickFinal)

// Standard-candle overlay — show the REAL candles of a detected pattern (the whole
// formation, e.g. all three bars of a Morning Star) so the true shape is visible
// even while viewing the Heikin Ashi overlay. plotcandle can't redraw past bars,
// so the composing bars are drawn as line-based candles (wick + thick body line).
drawStdCandle(int bi, float o, float h, float l, float c) =>
    cc = c >= o ? upColor : downColor
    line.new(bi, h, bi, l, xloc.bar_index, color=cc, width=1)                            // wick
    line.new(bi, math.max(o, c), bi, math.min(o, c), xloc.bar_index, color=cc, width=4)  // body

anyPat = isDoji or isDfly or isGrave or isInside or isHammer or isInvHam or isMaruBull or isMaruBear or isTwzBot or isTwzTop or isBullEng or isBullHar or isMorning or isThreeWS or isPiercing or isHang or isShoot or isBearEng or isBearHar or isEvening or isThreeBC or isDarkCloud
// Bars that make up the detected pattern, so the whole formation is drawn.
patLen = (isMorning or isEvening or isThreeWS or isThreeBC) ? 3
     : (isBullEng or isBearEng or isBullHar or isBearHar or isPiercing or isDarkCloud or isInside or isTwzBot or isTwzTop) ? 2
     : anyPat ? 1 : 0

// All Bars: real-candle overlay on every bar (drawn last so it sits on top).
stdAll = csA and cs_stdCandle == "All Bars"
plotcandle(stdAll ? mO : na, stdAll ? mH : na, stdAll ? mL : na, stdAll ? mC : na,
     "Standard Candle Overlay",
     color       = mC >= mO ? upColor : downColor,
     bordercolor = mC >= mO ? borderUpCol : borderDnCol,
     wickcolor   = wickFinal)

// On Pattern: draw the real candles only for the bars composing each detection.
// Chart-TF only — with Use HTF the k-bars-back chart offsets would just redraw
// the same repeated HTF values in the wrong places.
if csA and cs_stdCandle == "On Pattern" and patLen > 0 and not useMTF and _csClosed
    for k = 0 to patLen - 1
        drawStdCandle(bar_index - k, mO[k], mH[k], mL[k], mC[k])

// Flip markers are LABELS, not plotshapes — alertcondition() calls share the
// same 64-slot budget as plots, and the six size-gated plotshapes this used
// to need pushed the script over it. Labels draw from their own 500-object
// pool (shared with pattern markers; only the oldest markers fade on very
// long charts) and take a dynamic size directly.
_flipSzRes = ha_flip_size == "tiny" ? size.tiny : ha_flip_size == "normal" ? size.normal : size.small
if showHA and haFlipToBull
    label.new(bar_index, iHaL, "▲", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_up, ha_flip_up_col, _flipSzRes)
if showHA and haFlipToBear
    label.new(bar_index, iHaH, "▼", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_down, ha_flip_dn_col, _flipSzRes)

var label _haStreakLbl = na
if barstate.islast
    label.delete(_haStreakLbl)
    if showHA and ha_streak_on and enabled
        _haStreakLbl := label.new(bar_index + 1, iHaC, str.tostring(_haStreak),
             xloc.bar_index, yloc.price, color.new(color.black, 100),
             label.style_label_left, ha_streak_col, size.normal)

// ═══════════════════════════════════════════════════════════════════════════
// PLOTS — LINE FAMILY
// ═══════════════════════════════════════════════════════════════════════════
// The "Line with Markers" style reuses this same line plot (one fewer plot
// slot); its dot markers come from the plotshape below.
plot(showLine or showMarkers ? iSrc : na, "Line", color=withVolOp(lineCol), linewidth=lineWidth, style=plot.style_line, display=display.pane + display.price_scale)
plot(showStep ? iSrc : na, "Step Line", color=withVolOp(lineCol), linewidth=lineWidth, style=plot.style_stepline, display=display.pane + display.price_scale)
plot(showArea ? iSrc : na, "Area",      color=withVolOp(lineCol), linewidth=lineWidth, style=plot.style_area,     display=display.pane + display.price_scale)

baseCol = colorMode == "Single Color" ? lineColor : (iSrc >= iBaseline ? upColor : downColor)
pBaseSrc = plot(showBase ? iSrc      : na, "Baseline",     color=withVolOp(baseCol),        linewidth=lineWidth, style=plot.style_line, display=display.pane + display.price_scale)
pBaseRef = plot(showBase ? iBaseline : na, "Baseline Ref", color=color.new(color.gray, 50), linewidth=1,         style=plot.style_line, linestyle=plot.linestyle_dashed, display=display.pane)
fill(pBaseSrc, pBaseRef, color = showBase and baseFillOn ? (iSrc >= iBaseline ? color.new(upColor, 80) : color.new(downColor, 80)) : na, title="Baseline Fill")

_baseXUp = ta.crossover(iSrc, iBaseline)
_baseXDn = ta.crossunder(iSrc, iBaseline)
baseCrossUpHit = showBase and baseCrossOn and _baseXUp
baseCrossDnHit = showBase and baseCrossOn and _baseXDn
// Labels rather than plotshapes — see the flip-marker note (64-plot budget).
if baseCrossUpHit
    label.new(bar_index, iBaseline, "▲", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_up, baseCrossUp, size.tiny)
if baseCrossDnHit
    label.new(bar_index, iBaseline, "▼", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_down, baseCrossDn, size.tiny)

plotshape(showMarkers ? iSrc : na, "Markers",
     style=shape.circle, location=location.absolute, color=withVolOp(lineCol), size=size.tiny, display=display.pane)

plot(showCol  ? iSrc : na, "Columns",   color=withVolOp(lineCol), style=plot.style_columns,   histbase=histBase, display=display.pane + display.price_scale)
plot(showHist ? iSrc : na, "Histogram", color=withVolOp(lineCol), style=plot.style_histogram, histbase=histBase, display=display.pane + display.price_scale)

// ═══════════════════════════════════════════════════════════════════════════
// TREND EMA REFERENCE LINE
// ═══════════════════════════════════════════════════════════════════════════
trendLinestyle = trendStyle == "Solid"  ? plot.linestyle_solid
              : trendStyle == "Dotted" ? plot.linestyle_dotted
              :                          plot.linestyle_dashed
iTrendEma = inv(trendEma)
plot(showTrend and enabled and colorMode == "Trend (EMA)" ? iTrendEma : na,
     "Trend EMA", color=trendCol, linewidth=1, style=plot.style_line, linestyle=trendLinestyle, display=display.pane)

// ═══════════════════════════════════════════════════════════════════════════
// OHLC LABELS (last bar)
// ═══════════════════════════════════════════════════════════════════════════
isOhlcType = chartType == "Candles" or chartType == "Bars"
isHaType   = chartType == "Heikin Ashi"

dispO = isOhlcType ? iO : isHaType ? iHaO : na
dispH = isOhlcType ? iH : isHaType ? iHaH : na
dispL = isOhlcType ? iL : isHaType ? iHaL : na
dispC = isOhlcType ? iC : isHaType ? iHaC : iSrc

labelSizeRes = labelSize == "tiny"   ? size.tiny
             : labelSize == "small"  ? size.small
             : labelSize == "large"  ? size.large
             :                          size.normal
labelFmt = labelBold ? text.format_bold : text.format_none

var label lO = na
var label lH = na
var label lL = na
var label lC = na

if barstate.islast
    label.delete(lO)
    label.delete(lH)
    label.delete(lL)
    label.delete(lC)
    if showLabels and enabled
        x = bar_index + labelOffset
        bg = color.new(color.gray, 80)
        if not na(dispO)
            lO := label.new(x, dispO, "O " + str.tostring(dispO, format.mintick), color=bg, textcolor=upColor,   style=label.style_label_left, size=labelSizeRes, text_formatting=labelFmt)
        if not na(dispH)
            lH := label.new(x, dispH, "H " + str.tostring(dispH, format.mintick), color=bg, textcolor=upColor,   style=label.style_label_left, size=labelSizeRes, text_formatting=labelFmt)
        if not na(dispL)
            lL := label.new(x, dispL, "L " + str.tostring(dispL, format.mintick), color=bg, textcolor=downColor, style=label.style_label_left, size=labelSizeRes, text_formatting=labelFmt)
        if not na(dispC)
            cTxtCol = dispC >= nz(dispO, dispC) ? upColor : downColor
            lC := label.new(x, dispC, "C " + str.tostring(dispC, format.mintick), color=bg, textcolor=cTxtCol, style=label.style_label_left, size=labelSizeRes, text_formatting=labelFmt)

// ═══════════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION & DRAWING
// ═══════════════════════════════════════════════════════════════════════════
divA      = div_on and enabled
divClose  = div_priceStd ? mC : iC
divHi     = div_priceStd ? mH : iH
divLo     = div_priceStd ? mL : iL
divHlc3   = (divHi + divLo + divClose) / 3
[_macdLine, _macdSig, _macdHist] = ta.macd(divClose, 12, 26, 9)
osc = switch div_osc
    "MACD"       => _macdLine
    "Stochastic" => ta.stoch(divClose, divHi, divLo, div_len)
    "CCI"        => ta.cci(divHlc3, div_len)
    "MFI"        => ta.mfi(divHlc3, div_len)
    =>              ta.rsi(divClose, div_len)

pvtHi = ta.pivothigh(osc, div_pivL, div_pivR)
pvtLo = ta.pivotlow(osc, div_pivL, div_pivR)
loF = not na(pvtLo)
hiF = not na(pvtHi)

oscLoCurr   = ta.valuewhen(loF, osc[div_pivR],       0)
oscLoPrev   = ta.valuewhen(loF, osc[div_pivR],       1)
priceLoCurr = ta.valuewhen(loF, divLo[div_pivR],     0)
priceLoPrev = ta.valuewhen(loF, divLo[div_pivR],     1)
barLoPrev   = ta.valuewhen(loF, bar_index[div_pivR], 1)

oscHiCurr   = ta.valuewhen(hiF, osc[div_pivR],       0)
oscHiPrev   = ta.valuewhen(hiF, osc[div_pivR],       1)
priceHiCurr = ta.valuewhen(hiF, divHi[div_pivR],     0)
priceHiPrev = ta.valuewhen(hiF, divHi[div_pivR],     1)
barHiPrev   = ta.valuewhen(hiF, bar_index[div_pivR], 1)

bullReg = divA and div_reg and loF and oscLoCurr > oscLoPrev and priceLoCurr < priceLoPrev
bullHid = divA and div_hid and loF and oscLoCurr < oscLoPrev and priceLoCurr > priceLoPrev
bearReg = divA and div_reg and hiF and oscHiCurr < oscHiPrev and priceHiCurr > priceHiPrev
bearHid = divA and div_hid and hiF and oscHiCurr > oscHiPrev and priceHiCurr < priceHiPrev

curPivBar = bar_index - div_pivR

if bullReg or bullHid
    label.new(curPivBar, divLo[div_pivR], bullHid ? "H.Bull" : "Bull",
         xloc=xloc.bar_index, yloc=yloc.belowbar, color=color.new(div_bullCol, 80),
         style=label.style_label_up, textcolor=div_bullCol, size=size.tiny)
    if div_lines and not na(barLoPrev)
        line.new(int(barLoPrev), priceLoPrev, curPivBar, divLo[div_pivR],
             xloc=xloc.bar_index, color=div_bullCol, style=line.style_solid, width=1)

if bearReg or bearHid
    label.new(curPivBar, divHi[div_pivR], bearHid ? "H.Bear" : "Bear",
         xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(div_bearCol, 80),
         style=label.style_label_down, textcolor=div_bearCol, size=size.tiny)
    if div_lines and not na(barHiPrev)
        line.new(int(barHiPrev), priceHiPrev, curPivBar, divHi[div_pivR],
             xloc=xloc.bar_index, color=div_bearCol, style=line.style_solid, width=1)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// Edge-triggered conditions for the alert dialog's Condition dropdown, plus
// an optional detailed alert() stream (arm with "Any alert() function call").
// Pattern and divergence conditions reuse the fire-once flags above, so one
// event fires exactly one alert even in HTF mode.
// ═══════════════════════════════════════════════════════════════════════════
_alFlipUp  = showHA and haFlipToBull
_alFlipDn  = showHA and haFlipToBear
_alStrong  = showHA and haStrongCandle and not haStrongCandle[1]
_alStreak  = showHA and _haStreak >= streak_alert_len and _haStreak[1] < streak_alert_len
_alBullDiv = bullReg or bullHid
_alBearDiv = bearReg or bearHid

alertcondition(_alFlipUp,      title="HA Flip Up",          message="Heikin Ashi flipped bullish on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_alFlipDn,      title="HA Flip Down",        message="Heikin Ashi flipped bearish on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_alStrong,      title="Strong HA Candle",    message="Strong Heikin Ashi candle on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_alStreak,      title="Streak Milestone",    message="Heikin Ashi streak milestone reached on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(baseCrossUpHit, title="Baseline Cross Up",   message="Price crossed above the baseline on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(baseCrossDnHit, title="Baseline Cross Down", message="Price crossed below the baseline on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_bullFire,      title="Bullish Pattern",     message="Bullish candlestick pattern on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_bearFire,      title="Bearish Pattern",     message="Bearish candlestick pattern on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_neutFire,      title="Neutral Pattern",     message="Neutral candlestick pattern (doji / inside bar) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_alBullDiv,     title="Bullish Divergence",  message="Bullish divergence on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(_alBearDiv,     title="Bearish Divergence",  message="Bearish divergence on {{ticker}} ({{interval}}) at {{close}}")

if alert_on
    if _alFlipUp
        alert("HA Flip Up on " + syminfo.ticker, alert.freq_once_per_bar)
    if _alFlipDn
        alert("HA Flip Down on " + syminfo.ticker, alert.freq_once_per_bar)
    if _alStrong
        alert("Strong HA Candle (" + (haIsUp ? "Bull" : "Bear") + ") on " + syminfo.ticker, alert.freq_once_per_bar)
    if _alStreak
        alert("HA Streak reached " + str.tostring(streak_alert_len) + " on " + syminfo.ticker, alert.freq_once_per_bar)
    if baseCrossUpHit
        alert("Baseline Cross Up on " + syminfo.ticker, alert.freq_once_per_bar)
    if baseCrossDnHit
        alert("Baseline Cross Down on " + syminfo.ticker, alert.freq_once_per_bar)
    if _bullFire
        alert("Bullish pattern " + _bullTxt + "on " + syminfo.ticker, alert.freq_once_per_bar)
    if _bearFire
        alert("Bearish pattern " + _bearTxt + "on " + syminfo.ticker, alert.freq_once_per_bar)
    if _neutFire
        alert("Neutral pattern " + _neutTxt + "on " + syminfo.ticker, alert.freq_once_per_bar)
    if _alBullDiv
        alert((bullHid ? "Hidden bullish" : "Bullish") + " divergence on " + syminfo.ticker, alert.freq_once_per_bar)
    if _alBearDiv
        alert((bearHid ? "Hidden bearish" : "Bearish") + " divergence on " + syminfo.ticker, alert.freq_once_per_bar)

// ═══════════════════════════════════════════════════════════════════════════
// OVERLAY INFO TAG
// Tiny bottom-left note naming what the overlay is showing right now.
// ═══════════════════════════════════════════════════════════════════════════
prettyTF(_tf) =>
    _s = _tf == "" ? timeframe.in_seconds() : timeframe.in_seconds(_tf)
    _s < 60 ? str.tostring(_s) + "s" : _s < 3600 ? str.tostring(int(_s / 60)) + "m" : _s < 86400 ? str.tostring(int(_s / 3600)) + "h" : _s < 604800 ? str.tostring(int(_s / 86400)) + "D" : _s < 2592000 ? str.tostring(int(_s / 604800)) + "W" : str.tostring(int(_s / 2592000)) + "M"

var table _infoTbl = show_info ? table.new(position.bottom_left, 1, 1) : na
if barstate.islast and not na(_infoTbl)
    if enabled
        string _infoTxt = chartType
        if useMTF
            _infoTxt := _infoTxt + " · " + prettyTF(htf) + (useConfirmed ? " (closed bars)" : "")
        if chartType == "Heikin Ashi" and ha_double
            _infoTxt := _infoTxt + " · 2×"
        if smoothOn and not (chartType == "Candles" or chartType == "Bars" or chartType == "Heikin Ashi")
            _infoTxt := _infoTxt + " · " + smoothType + " " + str.tostring(smoothLen)
        if invertOn
            _infoTxt := _infoTxt + " · INVERTED"
        table.cell(_infoTbl, 0, 0, _infoTxt, text_color=color.new(color.white, 35), text_size=size.small, bgcolor=color.new(#1e222d, 40))
    else
        table.clear(_infoTbl, 0, 0)

// ═══════════════════════════════════════════════════════════════════════════
// NON-STANDARD CHART WARNING
// Detect Heikin Ashi: HA defines open[t] = (HA_open[t-1] + HA_close[t-1]) / 2 exactly.
// On real candles this equality only holds by coincidence. Three consecutive matching
// bars gives high confidence with no extra request.security call.
// ═══════════════════════════════════════════════════════════════════════════
_isHABar = not na(open[1]) and not na(close[1]) and open == (open[1] + close[1]) / 2
var int _haRunLen = 0
_haRunLen := _isHABar ? _haRunLen + 1 : 0

var label _haWarningLabel = na
if barstate.islast
    label.delete(_haWarningLabel)
    _haWarningLabel := na
    if _haRunLen >= 3 and show_ha_warning
        _haWarningLabel := label.new(
             bar_index, na,
             'Heikin Ashi chart detected\nThis overlay reads from the base chart.\nOn HA, open and close are modified values,\nnot real prices. For accurate visuals,\nuse a standard candle chart as your base.',
             xloc.bar_index, yloc.abovebar,
             color     = color.new(color.orange, 10),
             textcolor = color.white,
             style     = label.style_label_down,
             size      = size.small)
````
