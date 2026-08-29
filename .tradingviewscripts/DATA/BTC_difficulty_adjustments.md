<!-- tradingview-pine-id: PUB;if2xIrb5W3KsQwBDI5gfprP8lEVtB1e5 -->
<!-- tradingviewscripts-format: 1 -->
# BTC difficulty adjustments

Source: https://www.tradingview.com/script/WP434CPG-BTC-difficulty-adjustments/

## Description

Draws background columns indicating BTC difficulty adjustments

Green = positive adjustments
Red = negative adjustments

Use Threshold mode and Threshold to look for adjustments larger or equal to Threshold value

Use on DAILY timeframe

---

## Source Code

````pine
//@version=4
study("BTC difficulty adjustments", overlay=true)

thresholdMode = input(false, title="Threshold mode")
threshold = input(10.0, title="Threshold %")

difficulty = security("QUANDL:BCHAIN/DIFF","D",close)


equal = difficulty == difficulty[1]
higher = difficulty > difficulty[1]
lower = difficulty < difficulty[1]

changed = not equal

change() =>
    r = 0.0
    if (equal and changed[1])
        for i = 1 to 3
            if (equal[i])
                r := ((difficulty[i] - difficulty) / difficulty[i]) * 100
                break
    r

// double bg column for zoomed out charts
bgcolor(thresholdMode and abs(change()) >= threshold and change() < 0 ? color.green : na, offset=-2, transp=0, title="Threshold mode positive adjustment column 1")
bgcolor(thresholdMode and abs(change()) >= threshold and change() > 0 ? color.red : na, offset=-2, transp=0, title="Threshold mode negative adjustment column 1")
bgcolor(thresholdMode and abs(change()) >= threshold and change() < 0 ? color.green : na, offset=-3, transp=0, title="Threshold mode positive adjustment column 2")
bgcolor(thresholdMode and abs(change()) >= threshold and change() > 0 ? color.red : na, offset=-3, transp=0, title="Threshold mode negative adjustment column 2")

// double bg column for zoomed out charts
bgcolor(higher and not thresholdMode ? color.green : na, offset=-1, transp=0, title="Positive adjustment column 1")
bgcolor(lower and not thresholdMode ? color.red : na, offset=-1, transp=0, title="Negative adjustment column 1")
bgcolor(higher and not thresholdMode ? color.green : na, offset=-2, transp=0, title="Positive adjustment column 2")
bgcolor(lower and not thresholdMode ? color.red : na, offset=-2, transp=0, title="Negative adjustment column 2")
````
