<!-- tradingview-pine-id: PUB;31f1e5a35f204ec9aa0359fc86d30ae6 -->
<!-- tradingviewscripts-format: 1 -->
# Relative Strength Confluence - vs Benchmark

Source: https://www.tradingview.com/script/clmqYTlx/

## Description

RS Confluence - Dual Signal vs Benchmark

RS Confluence is a relative strength indicator designed to measure whether the current symbol is outperforming or underperforming a chosen benchmark (default: BTC), using two independent signals on the price ratio between the symbol and the benchmark.

How it works

The indicator calculates a ratio between the current symbol's close and the benchmark's close (Symbol / Benchmark), then evaluates it through two lenses:

Level — RSI applied directly to the ratio. Measures whether the symbol is currently trading strong or weak relative to the benchmark.

Momentum — RSI applied to the Rate-of-Change of the ratio. Measures whether relative performance is accelerating or decelerating.

Both signals are kept on the same 0-100 scale, allowing them to be plotted together and compared directly.

Confluence Scoring

Bullish signal — Level and Momentum both cross above the bullish threshold (default 55) → RS BULLISH 2/2.

Bearish signal — Level and Momentum both cross below the bearish threshold (default 45) → RS BEARISH 2/2.

Partial agreement (1/2) and neutral readings (0/2) are also tracked and displayed in the info table.

Features

- Configurable benchmark symbol (any ticker, default BTC)
- Dual confluence scoring (Level + Momentum)
- Background coloring on full confluence
- Triangle markers on the first bar of a new confluence signal
- Live info table showing ratio, level, momentum and confluence status
- Built-in warning when the chart symbol matches the selected benchmark
- TradingView alert conditions for bullish/bearish confluence and midline crosses
- Non-repainting (uses confirmed values on the current timeframe)

How to Read the Chart

Blue Line (Level) — RSI of the Symbol/Benchmark ratio. Shows whether the symbol is currently stronger or weaker than the benchmark.

Orange Line (Momentum) — RSI of the ratio's Rate-of-Change. Shows whether that relative strength is accelerating or fading.

Dashed Threshold Lines — The upper line is the bullish threshold, the lower line is the bearish threshold. Full confluence requires both Level and Momentum to be on the same side of their respective threshold at the same time.

Red Triangles (top, pointing down) — Mark the first bar of a new RS BEARISH 2/2 signal: both Level and Momentum dropped below the bearish threshold together.

Green Triangles (bottom, pointing up) — Mark the first bar of a new RS BULLISH 2/2 signal: both Level and Momentum rose above the bullish threshold together.

Background Shading — Highlights the full duration of an active confluence signal (not just the trigger bar), making it easy to see how long the symbol stayed in a bullish or bearish RS regime.

Suggested Interpretation

RS Confluence is intended as a context indicator, not a standalone trading signal. A coin can show a strong technical setup on its own chart, but if it is underperforming the benchmark (e.g. BTC), the setup carries less weight — and vice versa. Use this indicator to filter or confirm signals from other tools rather than trading it in isolation.

Important

Do not apply this indicator to a chart where the symbol is the same as (or economically equivalent to) the selected benchmark — the ratio becomes constant or near-constant, making the readings meaningless. The indicator detects an exact ticker match and displays a warning in the info table, but different tickers referencing the same underlying asset (e.g. the same coin on a different exchange or quote currency) are not automatically detected.

This is the third indicator in a related series, designed to work alongside Divergence Confluence 7 and Volume Surge - Dual Period as part of a broader confluence-based analysis approach.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AbaddonPL

//@version=6
indicator("Relative Strength Confluence - vs Benchmark", shorttitle="RS Confluence vs BTC", overlay=false)

// =============================================================================
// RELATIVE STRENGTH CONFLUENCE vs BENCHMARK
// Measures whether the current symbol is outperforming or underperforming a
// benchmark (default: BTC) using two independent signals on the price ratio:
//   1) LEVEL     - RSI applied to the ratio (Symbol / Benchmark)
//   2) MOMENTUM  - RSI applied to the Rate-of-Change of the ratio
// Both signals combine into a 0-2 confluence score, mirroring the scoring
// style of "Divergence Confluence 7" and "Volume Surge - Dual Period".
// =============================================================================

// ---------------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------------
g_bench = "Benchmark"
benchmarkSymbol = input.symbol("BINANCE:BTCUSDT", "Benchmark Symbol", group=g_bench,
     tooltip="Reference symbol used to measure relative strength (e.g. BTC). Works best when quoted in the same currency as the chart symbol.")

g_rs = "Relative Strength Settings"
levelLen  = input.int(14, "Level Length (RSI of Ratio)", minval=1, group=g_rs,
     tooltip="RSI period applied to the price ratio (Symbol/Benchmark). Measures whether the symbol is currently over- or under-performing the benchmark.")
rocLen    = input.int(10, "Momentum Length (ROC of Ratio)", minval=1, group=g_rs,
     tooltip="Lookback for the Rate-of-Change of the ratio, capturing acceleration or deceleration of relative performance.")
momSmooth = input.int(14, "Momentum Smoothing (RSI of ROC)", minval=1, group=g_rs,
     tooltip="RSI smoothing applied to the ROC series, keeping both lines on a comparable 0-100 scale.")

g_zone = "Zones"
bullLevelIn = input.int(55, "Bullish Threshold", minval=50, maxval=100, group=g_zone)
bearLevelIn = input.int(45, "Bearish Threshold", minval=0, maxval=50, group=g_zone)

g_vis = "Visuals"
showBg    = input.bool(true, "Show Background Coloring", group=g_vis)
showTable = input.bool(true, "Show Info Table", group=g_vis)
tablePos  = input.string("Top Right", "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=g_vis)

// ---------------------------------------------------------------------------
// DATA
// ---------------------------------------------------------------------------
benchmarkClose = request.security(benchmarkSymbol, timeframe.period, close,
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

isSameAsBenchmark = syminfo.tickerid == benchmarkSymbol

ratio = benchmarkClose != 0 ? close / benchmarkClose : na

levelLine    = ta.rsi(ratio, levelLen)
rocRaw       = ta.roc(ratio, rocLen)
momentumLine = ta.rsi(rocRaw, momSmooth)

bullLevel = levelLine > bullLevelIn
bearLevel = levelLine < bearLevelIn
bullMom   = momentumLine > bullLevelIn
bearMom   = momentumLine < bearLevelIn

score = (bullLevel ? 1 : 0) + (bullMom ? 1 : 0) - (bearLevel ? 1 : 0) - (bearMom ? 1 : 0)

bullConfluence = score == 2
bearConfluence = score == -2

// ---------------------------------------------------------------------------
// PLOTS
// ---------------------------------------------------------------------------
plot(levelLine, "RS Level (vs Benchmark)", color=color.new(color.blue, 0), linewidth=2)
plot(momentumLine, "RS Momentum", color=color.new(color.orange, 0), linewidth=2)

hline(bullLevelIn, "Bullish Threshold", color=color.new(color.green, 60), linestyle=hline.style_dashed)
hline(50, "Midline", color=color.new(color.gray, 70))
hline(bearLevelIn, "Bearish Threshold", color=color.new(color.red, 60), linestyle=hline.style_dashed)

bgColor = showBg ? (bullConfluence ? color.new(color.green, 85) : bearConfluence ? color.new(color.red, 85) : na) : na
bgcolor(bgColor)

plotshape(bullConfluence and not bullConfluence[1], title="Bullish RS Confluence", style=shape.triangleup, location=location.bottom, color=color.green, size=size.small)
plotshape(bearConfluence and not bearConfluence[1], title="Bearish RS Confluence", style=shape.triangledown, location=location.top, color=color.red, size=size.small)

// ---------------------------------------------------------------------------
// TABLE
// ---------------------------------------------------------------------------
getTablePosition(pos) =>
    switch pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

var table infoTable = table.new(getTablePosition(tablePos), 2, 6, border_width=1)

if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "Benchmark", text_color=color.white, bgcolor=color.gray)
    table.cell(infoTable, 1, 0, benchmarkSymbol, text_color=color.white, bgcolor=color.gray)

    table.cell(infoTable, 0, 1, "Ratio", text_color=color.white)
    table.cell(infoTable, 1, 1, str.tostring(ratio, "#.000000"), text_color=color.white)

    table.cell(infoTable, 0, 2, "Level (RSI)", text_color=color.white)
    table.cell(infoTable, 1, 2, str.tostring(levelLine, "#.00"),
         text_color = bullLevel ? color.green : bearLevel ? color.red : color.gray)

    table.cell(infoTable, 0, 3, "Momentum", text_color=color.white)
    table.cell(infoTable, 1, 3, str.tostring(momentumLine, "#.00"),
         text_color = bullMom ? color.green : bearMom ? color.red : color.gray)

    confluenceText  = bullConfluence ? "BULLISH 2/2" : bearConfluence ? "BEARISH 2/2" : score > 0 ? "BULLISH 1/2" : score < 0 ? "BEARISH 1/2" : "NEUTRAL 0/2"
    confluenceColor = bullConfluence ? color.green : bearConfluence ? color.red : color.gray
    table.cell(infoTable, 0, 4, "RS Confluence", text_color=color.white)
    table.cell(infoTable, 1, 4, confluenceText, text_color=confluenceColor)

    if isSameAsBenchmark
        table.cell(infoTable, 0, 5, "Note", text_color=color.white, bgcolor=color.orange)
        table.cell(infoTable, 1, 5, "Chart = Benchmark", text_color=color.white, bgcolor=color.orange)

// ---------------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------------
alertcondition(bullConfluence and not bullConfluence[1], "RS Bullish Confluence 2/2",
     "{{ticker}}: Relative Strength Bullish Confluence (2/2) vs benchmark")
alertcondition(bearConfluence and not bearConfluence[1], "RS Bearish Confluence 2/2",
     "{{ticker}}: Relative Strength Bearish Confluence (2/2) vs benchmark")
alertcondition(ta.crossover(levelLine, 50), "RS Level Cross Above 50",
     "{{ticker}}: Relative Strength Level crossed above 50 vs benchmark")
alertcondition(ta.crossunder(levelLine, 50), "RS Level Cross Below 50",
     "{{ticker}}: Relative Strength Level crossed below 50 vs benchmark")
````
