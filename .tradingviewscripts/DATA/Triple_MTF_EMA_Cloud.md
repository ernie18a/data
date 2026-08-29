<!-- tradingview-pine-id: PUB;24690bad1be6414b98f50d37b66e9fe3 -->
<!-- tradingviewscripts-format: 1 -->
# Triple MTF EMA Cloud

Source: https://www.tradingview.com/script/JN8SxQM1-Triple-MTF-EMA-Cloud/

## Description

Triple EMA Cloud that allows the user to place timeframes other than the charted timeframe on the chart. For example, screenshot shows 1min, 3min, and 5min EMA clouds on a 15minute chart. This can be used to overlay higher timeframe EMAs on lower timeframes as well. Good luck. Have fun trading!

---

## Source Code

````pine
//@version=6
indicator(
     title     = "Triple MTF EMA Cloud",
     shorttitle = "3x MTF EMA Cloud",
     overlay   = true
)

// ============================================================================
// GENERAL SETTINGS
// ============================================================================

showEmaEdges = input.bool(
     true,
     title = "Show EMA Boundary Lines",
     group = "General"
)

emaLineWidth = input.int(
     1,
     title  = "EMA Line Width",
     minval = 1,
     maxval = 4,
     group  = "General"
)

// ============================================================================
// CLOUD 1 SETTINGS
// Default: 1-minute 9/21 EMA cloud
// ============================================================================

cloud1Enabled = input.bool(
     true,
     title  = "Enable",
     group  = "Cloud 1",
     inline = "C1-TF"
)

cloud1Timeframe = input.timeframe(
     "1",
     title  = "Timeframe",
     group  = "Cloud 1",
     inline = "C1-TF"
)

cloud1FastLength = input.int(
     9,
     title  = "Fast EMA",
     minval = 1,
     group  = "Cloud 1",
     inline = "C1-LENGTH"
)

cloud1SlowLength = input.int(
     21,
     title  = "Slow EMA",
     minval = 1,
     group  = "Cloud 1",
     inline = "C1-LENGTH"
)

cloud1BullColor = input.color(
     color.rgb(0, 188, 212),
     title  = "Bullish",
     group  = "Cloud 1",
     inline = "C1-COLOR"
)

cloud1BearColor = input.color(
     color.rgb(239, 83, 80),
     title  = "Bearish",
     group  = "Cloud 1",
     inline = "C1-COLOR"
)

cloud1Transparency = input.int(
     82,
     title  = "Fill Transparency",
     minval = 0,
     maxval = 100,
     group  = "Cloud 1"
)

// ============================================================================
// CLOUD 2 SETTINGS
// Default: 3-minute 9/21 EMA cloud
// ============================================================================

cloud2Enabled = input.bool(
     true,
     title  = "Enable",
     group  = "Cloud 2",
     inline = "C2-TF"
)

cloud2Timeframe = input.timeframe(
     "3",
     title  = "Timeframe",
     group  = "Cloud 2",
     inline = "C2-TF"
)

cloud2FastLength = input.int(
     9,
     title  = "Fast EMA",
     minval = 1,
     group  = "Cloud 2",
     inline = "C2-LENGTH"
)

cloud2SlowLength = input.int(
     21,
     title  = "Slow EMA",
     minval = 1,
     group  = "Cloud 2",
     inline = "C2-LENGTH"
)

cloud2BullColor = input.color(
     color.rgb(33, 150, 243),
     title  = "Bullish",
     group  = "Cloud 2",
     inline = "C2-COLOR"
)

cloud2BearColor = input.color(
     color.rgb(255, 152, 0),
     title  = "Bearish",
     group  = "Cloud 2",
     inline = "C2-COLOR"
)

cloud2Transparency = input.int(
     85,
     title  = "Fill Transparency",
     minval = 0,
     maxval = 100,
     group  = "Cloud 2"
)

// ============================================================================
// CLOUD 3 SETTINGS
// Default: 5-minute 9/21 EMA cloud
// ============================================================================

cloud3Enabled = input.bool(
     true,
     title  = "Enable",
     group  = "Cloud 3",
     inline = "C3-TF"
)

cloud3Timeframe = input.timeframe(
     "5",
     title  = "Timeframe",
     group  = "Cloud 3",
     inline = "C3-TF"
)

cloud3FastLength = input.int(
     9,
     title  = "Fast EMA",
     minval = 1,
     group  = "Cloud 3",
     inline = "C3-LENGTH"
)

cloud3SlowLength = input.int(
     21,
     title  = "Slow EMA",
     minval = 1,
     group  = "Cloud 3",
     inline = "C3-LENGTH"
)

cloud3BullColor = input.color(
     color.rgb(156, 39, 176),
     title  = "Bullish",
     group  = "Cloud 3",
     inline = "C3-COLOR"
)

cloud3BearColor = input.color(
     color.rgb(233, 30, 99),
     title  = "Bearish",
     group  = "Cloud 3",
     inline = "C3-COLOR"
)

cloud3Transparency = input.int(
     88,
     title  = "Fill Transparency",
     minval = 0,
     maxval = 100,
     group  = "Cloud 3"
)

// ============================================================================
// MULTI-TIMEFRAME EMA CALCULATIONS
// ============================================================================

[cloud1FastEma, cloud1SlowEma] = request.security(
     syminfo.tickerid,
     cloud1Timeframe,
     [
          ta.ema(close, cloud1FastLength),
          ta.ema(close, cloud1SlowLength)
     ],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

[cloud2FastEma, cloud2SlowEma] = request.security(
     syminfo.tickerid,
     cloud2Timeframe,
     [
          ta.ema(close, cloud2FastLength),
          ta.ema(close, cloud2SlowLength)
     ],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

[cloud3FastEma, cloud3SlowEma] = request.security(
     syminfo.tickerid,
     cloud3Timeframe,
     [
          ta.ema(close, cloud3FastLength),
          ta.ema(close, cloud3SlowLength)
     ],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

// ============================================================================
// TREND COLORS
// ============================================================================

cloud1TrendColor = cloud1FastEma >= cloud1SlowEma
     ? cloud1BullColor
     : cloud1BearColor

cloud2TrendColor = cloud2FastEma >= cloud2SlowEma
     ? cloud2BullColor
     : cloud2BearColor

cloud3TrendColor = cloud3FastEma >= cloud3SlowEma
     ? cloud3BullColor
     : cloud3BearColor

// Boundary lines become completely transparent when disabled.
// The underlying plots remain active so the cloud fills still render.

cloud1FastLineColor = color.new(
     cloud1TrendColor,
     showEmaEdges ? 0 : 100
)

cloud1SlowLineColor = color.new(
     cloud1TrendColor,
     showEmaEdges ? 35 : 100
)

cloud2FastLineColor = color.new(
     cloud2TrendColor,
     showEmaEdges ? 0 : 100
)

cloud2SlowLineColor = color.new(
     cloud2TrendColor,
     showEmaEdges ? 35 : 100
)

cloud3FastLineColor = color.new(
     cloud3TrendColor,
     showEmaEdges ? 0 : 100
)

cloud3SlowLineColor = color.new(
     cloud3TrendColor,
     showEmaEdges ? 35 : 100
)

// ============================================================================
// CLOUD 1 PLOTS
// ============================================================================

cloud1FastPlot = plot(
     cloud1Enabled ? cloud1FastEma : na,
     title     = "Cloud 1 Fast EMA",
     color     = cloud1FastLineColor,
     linewidth = emaLineWidth
)

cloud1SlowPlot = plot(
     cloud1Enabled ? cloud1SlowEma : na,
     title     = "Cloud 1 Slow EMA",
     color     = cloud1SlowLineColor,
     linewidth = emaLineWidth
)

fill(
     cloud1FastPlot,
     cloud1SlowPlot,
     color = cloud1Enabled
          ? color.new(cloud1TrendColor, cloud1Transparency)
          : na,
     title    = "Cloud 1 Fill",
     fillgaps = true
)

// ============================================================================
// CLOUD 2 PLOTS
// ============================================================================

cloud2FastPlot = plot(
     cloud2Enabled ? cloud2FastEma : na,
     title     = "Cloud 2 Fast EMA",
     color     = cloud2FastLineColor,
     linewidth = emaLineWidth
)

cloud2SlowPlot = plot(
     cloud2Enabled ? cloud2SlowEma : na,
     title     = "Cloud 2 Slow EMA",
     color     = cloud2SlowLineColor,
     linewidth = emaLineWidth
)

fill(
     cloud2FastPlot,
     cloud2SlowPlot,
     color = cloud2Enabled
          ? color.new(cloud2TrendColor, cloud2Transparency)
          : na,
     title    = "Cloud 2 Fill",
     fillgaps = true
)

// ============================================================================
// CLOUD 3 PLOTS
// ============================================================================

cloud3FastPlot = plot(
     cloud3Enabled ? cloud3FastEma : na,
     title     = "Cloud 3 Fast EMA",
     color     = cloud3FastLineColor,
     linewidth = emaLineWidth
)

cloud3SlowPlot = plot(
     cloud3Enabled ? cloud3SlowEma : na,
     title     = "Cloud 3 Slow EMA",
     color     = cloud3SlowLineColor,
     linewidth = emaLineWidth
)

fill(
     cloud3FastPlot,
     cloud3SlowPlot,
     color = cloud3Enabled
          ? color.new(cloud3TrendColor, cloud3Transparency)
          : na,
     title    = "Cloud 3 Fill",
     fillgaps = true
)
````
