# Stochastic Divergence | Regular & Hidden Divergences

- url: https://www.tradingview.com/script/yeurMSzT-Stochastic-Divergence-Regular-Hidden-Divergences/
- type: indicator
- pine_id: PUB;a9db8d47ec3d4bf888ea475bd0d40602
- version: 2.0

## Description

Stochastic Divergence Pro | Regular & Hidden Divergences

This indicator detects regular and hidden divergences between price action and the Stochastic oscillator.

It is designed as a visual confirmation tool for traders who use Stochastic divergence as part of a broader discretionary trading process. The script does not generate buy or sell recommendations and should not be used as a standalone trading system.

Main features:

- Stochastic %K and %D plotting
- Regular bullish divergence detection
- Regular bearish divergence detection
- Hidden bullish divergence detection
- Hidden bearish divergence detection
- Configurable pivot sensitivity
- Configurable lookback period
- Optional overbought / oversold zone filter
- Optional divergence lines
- Optional divergence labels
- Alert conditions for each divergence type
- Alert condition for any divergence

Default settings:

- K Period: 5
- Slowing: 3
- D Period: 3
- Pivot Left: 2
- Pivot Right: 2
- Lookback Period: 50
- Oversold Level: 20
- Overbought Level: 80
- OB/OS Filter: Enabled
- Zone Tolerance: 5

Divergence logic:

Regular Bullish Divergence:
Price forms a lower low while Stochastic forms a higher low.
This may indicate weakening bearish momentum and potential bullish reversal conditions.

Hidden Bullish Divergence:
Price forms a higher low while Stochastic forms a lower low.
This may indicate bullish continuation conditions.

Regular Bearish Divergence:
Price forms a higher high while Stochastic forms a lower high.
This may indicate weakening bullish momentum and potential bearish reversal conditions.

Hidden Bearish Divergence:
Price forms a lower high while Stochastic forms a higher high.
This may indicate bearish continuation conditions.

Overbought / Oversold filter:

When enabled, bullish divergences are shown only when at least one of the two Stochastic pivot lows is near the oversold area.

Bearish divergences are shown only when at least one of the two Stochastic pivot highs is near the overbought area.

This helps reduce noise and avoid highlighting divergences that occur in the middle of the oscillator range.

Visual output:

- Yellow solid line: Regular Bullish Divergence
- Yellow dashed line: Hidden Bullish Divergence
- Red solid line: Regular Bearish Divergence
- Red dashed line: Hidden Bearish Divergence

Labels:

- Reg Bull
- Hid Bull
- Reg Bear
- Hid Bear

Alerts included:

- Regular Bullish Stochastic Divergence
- Hidden Bullish Stochastic Divergence
- Regular Bearish Stochastic Divergence
- Hidden Bearish Stochastic Divergence
- Any Stochastic Divergence

Suggested interpretation:

- Regular Bullish Divergence can support reversal buy analysis
- Regular Bearish Divergence can support reversal sell analysis
- Hidden Bullish Divergence can support continuation buy analysis
- Hidden Bearish Divergence can support continuation sell analysis

Important note:

This indicator is a technical analysis tool, not a trading system.

A divergence should be treated only as a potential confirmation signal. Before taking any trade, traders should independently assess:

- market structure
- trend direction
- support and resistance
- higher timeframe context
- volatility
- risk-to-reward ratio
- liquidity and spread
- relevant news events
- personal risk management rules

No signal from this indicator guarantees future price movement.

## Source Code

````pine
//@version=6
indicator("Stochastic Hidden/Regular Divergence v3.0", overlay=false, precision=2, max_lines_count=500, max_labels_count=500)

// =========================
// Inputs
// =========================

kPeriod = input.int(5, "K Period", minval=1)
slowing = input.int(3, "Slowing", minval=1)
dPeriod = input.int(3, "D Period", minval=1)

pivotLeft = input.int(2, "Pivot Left", minval=1, maxval=10)
pivotRight = input.int(2, "Pivot Right", minval=1, maxval=10)

lookback = input.int(50, "Lookback Period", minval=5, maxval=500)

levelLow = input.float(20.0, "Oversold Level")
levelHigh = input.float(80.0, "Overbought Level")

useExtremeFilter = input.bool(true, "Use OB/OS Filter")
zoneTolerance = input.float(5.0, "OB/OS Zone Tolerance", minval=0.0, maxval=20.0)

showRegular = input.bool(true, "Show Regular Divergences")
showHidden = input.bool(true, "Show Hidden Divergences")

showLines = input.bool(true, "Show Divergence Lines")
showLabels = input.bool(true, "Show Labels")

// =========================
// Stochastic Calculation
// =========================

rawK = ta.stoch(close, high, low, kPeriod)
stoK = ta.sma(rawK, slowing)
stoD = ta.sma(stoK, dPeriod)

// =========================
// Plot Stochastic
// =========================

plot(stoK, "Stochastic %K", color=color.rgb(30, 144, 255), linewidth=1)
plot(stoD, "Stochastic %D", color=color.red, linewidth=1)

hline(levelLow, "Oversold", color=color.gray, linestyle=hline.style_dashed)
hline(levelHigh, "Overbought", color=color.gray, linestyle=hline.style_dashed)
hline(50, "Midline", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// =========================
// Pivot Detection
// =========================

pivotLow = ta.pivotlow(stoK, pivotLeft, pivotRight)
pivotHigh = ta.pivothigh(stoK, pivotLeft, pivotRight)

// =========================
// Divergence Flags
// =========================

regularBullish = false
hiddenBullish = false
regularBearish = false
hiddenBearish = false

// =========================
// Bullish Divergence Logic
// =========================

if not na(pivotLow)
    currStoL = pivotLow
    currPriceL = low[pivotRight]
    currBarL = bar_index[pivotRight]

    for i = pivotRight + 1 to lookback
        prevStoL = pivotLow[i - pivotRight]

        if not na(prevStoL)
            prevPriceL = low[i]
            prevBarL = bar_index[i]

            bullishExtremeOk =
                 not useExtremeFilter or
                 currStoL <= levelLow + zoneTolerance or
                 prevStoL <= levelLow + zoneTolerance

            regularBullishCondition =
                 showRegular and
                 bullishExtremeOk and
                 currStoL > prevStoL and
                 currPriceL < prevPriceL

            hiddenBullishCondition =
                 showHidden and
                 bullishExtremeOk and
                 currStoL < prevStoL and
                 currPriceL > prevPriceL

            if regularBullishCondition
                regularBullish := true

                if showLines
                    line.new(
                         prevBarL,
                         prevStoL,
                         currBarL,
                         currStoL,
                         color=color.yellow,
                         width=1
                    )

                if showLabels
                    label.new(
                         currBarL,
                         currStoL,
                         "Reg Bull",
                         style=label.style_label_up,
                         color=color.yellow,
                         textcolor=color.black,
                         size=size.tiny,
                         yloc=yloc.price
                    )

                break

            else if hiddenBullishCondition
                hiddenBullish := true

                if showLines
                    line.new(
                         prevBarL,
                         prevStoL,
                         currBarL,
                         currStoL,
                         color=color.new(color.yellow, 0),
                         style=line.style_dashed,
                         width=1
                    )

                if showLabels
                    label.new(
                         currBarL,
                         currStoL,
                         "Hid Bull",
                         style=label.style_label_up,
                         color=color.new(color.yellow, 20),
                         textcolor=color.black,
                         size=size.tiny,
                         yloc=yloc.price
                    )

                break

// =========================
// Bearish Divergence Logic
// =========================

if not na(pivotHigh)
    currStoH = pivotHigh
    currPriceH = high[pivotRight]
    currBarH = bar_index[pivotRight]

    for i = pivotRight + 1 to lookback
        prevStoH = pivotHigh[i - pivotRight]

        if not na(prevStoH)
            prevPriceH = high[i]
            prevBarH = bar_index[i]

            bearishExtremeOk =
                 not useExtremeFilter or
                 currStoH >= levelHigh - zoneTolerance or
                 prevStoH >= levelHigh - zoneTolerance

            regularBearishCondition =
                 showRegular and
                 bearishExtremeOk and
                 currStoH < prevStoH and
                 currPriceH > prevPriceH

            hiddenBearishCondition =
                 showHidden and
                 bearishExtremeOk and
                 currStoH > prevStoH and
                 currPriceH < prevPriceH

            if regularBearishCondition
                regularBearish := true

                if showLines
                    line.new(
                         prevBarH,
                         prevStoH,
                         currBarH,
                         currStoH,
                         color=color.red,
                         width=1
                    )

                if showLabels
                    label.new(
                         currBarH,
                         currStoH,
                         "Reg Bear",
                         style=label.style_label_down,
                         color=color.red,
                         textcolor=color.white,
                         size=size.tiny,
                         yloc=yloc.price
                    )

                break

            else if hiddenBearishCondition
                hiddenBearish := true

                if showLines
                    line.new(
                         prevBarH,
                         prevStoH,
                         currBarH,
                         currStoH,
                         color=color.new(color.red, 0),
                         style=line.style_dashed,
                         width=1
                    )

                if showLabels
                    label.new(
                         currBarH,
                         currStoH,
                         "Hid Bear",
                         style=label.style_label_down,
                         color=color.new(color.red, 20),
                         textcolor=color.white,
                         size=size.tiny,
                         yloc=yloc.price
                    )

                break

// =========================
// Alerts
// =========================

alertcondition(
     regularBullish,
     title="Regular Bullish Stochastic Divergence",
     message="Regular Bullish Stochastic Divergence detected on {{ticker}} {{interval}}."
)

alertcondition(
     hiddenBullish,
     title="Hidden Bullish Stochastic Divergence",
     message="Hidden Bullish Stochastic Divergence detected on {{ticker}} {{interval}}."
)

alertcondition(
     regularBearish,
     title="Regular Bearish Stochastic Divergence",
     message="Regular Bearish Stochastic Divergence detected on {{ticker}} {{interval}}."
)

alertcondition(
     hiddenBearish,
     title="Hidden Bearish Stochastic Divergence",
     message="Hidden Bearish Stochastic Divergence detected on {{ticker}} {{interval}}."
)

alertcondition(
     regularBullish or hiddenBullish or regularBearish or hiddenBearish,
     title="Any Stochastic Divergence",
     message="Stochastic Divergence detected on {{ticker}} {{interval}}."
)
````
