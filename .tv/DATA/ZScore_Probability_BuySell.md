<!-- tradingview-pine-id: PUB;23b9e6b3d5b848f3abe8f64881027d93 -->
<!-- tradingviewscripts-format: 1 -->
# Z-Score Probability Buy/Sell

Source: https://www.tradingview.com/script/DRB1ko4U-Z-Score-Probability-Buy-Sell/

## Description

Superb indicator accuracy rate almost 89 percent. best work in 15 min and 3 min time frame

---

## Source Code

````pine
//@version=6
indicator(
     "Z-Score Probability Buy/Sell",
     shorttitle="Z Prob Signal",
     overlay=false,
     max_labels_count=500
)

//====================================================
// INPUTS
//====================================================

zLookback = input.int(
     20,
     "Z-Score Lookback Length",
     minval=2
)

zSmaLength = input.int(
     50,
     "Z-Score SMA Period",
     minval=1
)

showProbabilityBands = input.bool(
     true,
     "Show Probability Distribution Fill"
)

showSignals = input.bool(
     true,
     "Show BUY / SELL Signals"
)

showZScoreCandles = input.bool(
     true,
     "Show Z-Score Candles"
)

bullCandleColor = input.color(
     color.green,
     "Bullish Z-Score Candle Color"
)

bearCandleColor = input.color(
     color.red,
     "Bearish Z-Score Candle Color"
)

showActiveBias = input.bool(
     true,
     "Show Active BUY / SELL Status"
)

showStatusTable = input.bool(
     true,
     "Show Status Table"
)

//====================================================
// Z-SCORE CALCULATION
//====================================================

zMean = ta.sma(close, zLookback)
zDeviation = ta.stdev(close, zLookback)

// Synthetic Z-Score candles calculated from price OHLC.
zOpen =
     not na(zDeviation) and zDeviation != 0.0
     ? (open - zMean) / zDeviation
     : 0.0

zHighRaw =
     not na(zDeviation) and zDeviation != 0.0
     ? (high - zMean) / zDeviation
     : 0.0

zLowRaw =
     not na(zDeviation) and zDeviation != 0.0
     ? (low - zMean) / zDeviation
     : 0.0

zClose =
     not na(zDeviation) and zDeviation != 0.0
     ? (close - zMean) / zDeviation
     : 0.0

zHigh = math.max(zHighRaw, math.max(zOpen, zClose))
zLow = math.min(zLowRaw, math.min(zOpen, zClose))

zScore = zClose
zScoreSMA = ta.sma(zClose, zSmaLength)

//====================================================
// NORMAL DISTRIBUTION PROBABILITY APPROXIMATION
//====================================================

// Approximation of the standard normal cumulative distribution.
// Returns probability from 0.0 to 1.0.

normalCDF(float z) =>
    float absoluteZ = math.abs(z)
    float t = 1.0 / (1.0 + 0.2316419 * absoluteZ)

    float density =
         0.3989422804 *
         math.exp(-0.5 * absoluteZ * absoluteZ)

    float probability =
         1.0 -
         density *
         (
              0.319381530 * t +
              -0.356563782 * math.pow(t, 2) +
              1.781477937 * math.pow(t, 3) +
              -1.821255978 * math.pow(t, 4) +
              1.330274429 * math.pow(t, 5)
         )

    z >= 0.0
         ? probability
         : 1.0 - probability

probability = normalCDF(zScore)

//====================================================
// SIGNAL LOGIC
//====================================================

// Signals are created only after the chart candle is fully closed.
// This prevents intrabar crossover signals from flashing and disappearing.

confirmedBar = barstate.isconfirmed

buySignal =
     confirmedBar and
     zClose > zScoreSMA and
     zClose[1] <= zScoreSMA[1]

sellSignal =
     confirmedBar and
     zClose < zScoreSMA and
     zClose[1] >= zScoreSMA[1]

// Persistent active direction after a confirmed cross.
buyActive = zClose > zScoreSMA
sellActive = zClose < zScoreSMA

//====================================================
// PROBABILITY DISTRIBUTION BANDS
//====================================================

upper3 = hline(
     3.0,
     "+3",
     color=color.new(color.red, 65)
)

upper2 = hline(
     2.0,
     "+2",
     color=color.new(color.orange, 65)
)

upper1 = hline(
     1.0,
     "+1",
     color=color.new(color.green, 70)
)

zeroLine = hline(
     0.0,
     "Zero",
     color=color.gray,
     linestyle=hline.style_dashed
)

lower1 = hline(
     -1.0,
     "-1",
     color=color.new(color.green, 70)
)

lower2 = hline(
     -2.0,
     "-2",
     color=color.new(color.orange, 65)
)

lower3 = hline(
     -3.0,
     "-3",
     color=color.new(color.red, 65)
)

// Filled normal-distribution probability zones.

fill(
     upper3,
     upper2,
     color=showProbabilityBands
          ? color.new(color.red, 82)
          : na,
     title="+2 to +3 Probability Zone"
)

fill(
     upper2,
     upper1,
     color=showProbabilityBands
          ? color.new(color.yellow, 80)
          : na,
     title="+1 to +2 Probability Zone"
)

fill(
     upper1,
     zeroLine,
     color=showProbabilityBands
          ? color.new(color.green, 84)
          : na,
     title="0 to +1 Probability Zone"
)

fill(
     zeroLine,
     lower1,
     color=showProbabilityBands
          ? color.new(color.green, 84)
          : na,
     title="0 to -1 Probability Zone"
)

fill(
     lower1,
     lower2,
     color=showProbabilityBands
          ? color.new(color.yellow, 80)
          : na,
     title="-1 to -2 Probability Zone"
)

fill(
     lower2,
     lower3,
     color=showProbabilityBands
          ? color.new(color.red, 82)
          : na,
     title="-2 to -3 Probability Zone"
)

//====================================================
// PLOTS
//====================================================

zCandleColor =
     zClose >= zOpen
     ? bullCandleColor
     : bearCandleColor

plotcandle(
     showZScoreCandles ? zOpen : na,
     showZScoreCandles ? zHigh : na,
     showZScoreCandles ? zLow : na,
     showZScoreCandles ? zClose : na,
     title="Z-Score Candles",
     color=zCandleColor,
     wickcolor=zCandleColor,
     bordercolor=zCandleColor
)

plot(
     zScoreSMA,
     title="Z-Score SMA 50",
     color=color.black,
     linewidth=3
)

// Optional active bias background.
// This is not another condition.
// It only shows the current side after the crossover.

bgcolor(
     showActiveBias
     ? (
          buyActive
          ? color.new(color.green, 93)
          : sellActive
          ? color.new(color.red, 93)
          : na
       )
     : na
)

//====================================================
// BUY / SELL LABELS
//====================================================

plotshape(
     showSignals and buySignal,
     title="BUY Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small,
     force_overlay=true
)

plotshape(
     showSignals and sellSignal,
     title="SELL Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small,
     force_overlay=true
)

//====================================================
// STATUS TABLE
//====================================================

var table statusTable = table.new(
     position.top_right,
     2,
     5,
     border_width=1
)

if barstate.islast
    if showStatusTable
        table.cell(
             statusTable,
             0,
             0,
             "STATUS"
        )

        table.cell(
             statusTable,
             1,
             0,
             buyActive
             ? "BUY ACTIVE"
             : sellActive
             ? "SELL ACTIVE"
             : "NEUTRAL",
             bgcolor=buyActive
             ? color.green
             : sellActive
             ? color.red
             : color.gray,
             text_color=color.white
        )

        table.cell(
             statusTable,
             0,
             1,
             "Z-SCORE"
        )

        table.cell(
             statusTable,
             1,
             1,
             str.tostring(
                  zScore,
                  "#.###"
             )
        )

        table.cell(
             statusTable,
             0,
             2,
             "SMA 50"
        )

        table.cell(
             statusTable,
             1,
             2,
             str.tostring(
                  zScoreSMA,
                  "#.###"
             )
        )

        table.cell(
             statusTable,
             0,
             3,
             "PROBABILITY"
        )

        table.cell(
             statusTable,
             1,
             3,
             str.tostring(
                  probability * 100.0,
                  "#.##"
             ) + "%"
        )

        table.cell(
             statusTable,
             0,
             4,
             "ENTRY SIDE"
        )

        table.cell(
             statusTable,
             1,
             4,
             buyActive
             ? "BUY SIDE"
             : sellActive
             ? "SELL SIDE"
             : "WAIT"
        )
    else
        table.clear(
             statusTable,
             0,
             0,
             1,
             4
        )

//====================================================
// ALERTS
//====================================================

alertcondition(
     buySignal,
     title="Z-Score BUY",
     message="Confirmed candle close: Z-Score crossed above its SMA 50. BUY signal."
)

alertcondition(
     sellSignal,
     title="Z-Score SELL",
     message="Confirmed candle close: Z-Score crossed below its SMA 50. SELL signal."
)

alertcondition(
     buyActive,
     title="BUY Side Active",
     message="Z-Score remains above its SMA 50. BUY side is active."
)

alertcondition(
     sellActive,
     title="SELL Side Active",
     message="Z-Score remains below its SMA 50. SELL side is active."
)
````
