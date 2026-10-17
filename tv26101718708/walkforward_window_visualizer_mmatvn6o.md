# Walk-Forward Window Visualizer

- url: https://www.tradingview.com/script/MMATVN6O/
- type: indicator
- pine_id: PUB;413e57f484e143658caa6faa6bb8f1ca
- version: 1.0

## Description

Visualises rolling or anchored walk-forward train/test windows over chart history at a fixed train-size + test-size cadence. It shades alternating training and out-of-sample test segments so you can see how an honest walk-forward evaluation would carve up your data. It does NOT generate buy or sell signals.

How to read it
Rolling mode steps a fixed train window then tests on the following block, repeatedly. Anchored mode keeps an expanding training prefix and tests on the contiguous out-of-sample region after it.

Honest by design
- No buy/sell signals. This is a layout/visualisation tool.
- Non-repainting: bands are a deterministic function of the bar index.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Walk-Forward Window Visualizer
// Show alternating train/test bands over chart history at a fixed
// train_size + test_size cadence. Anchored mode highlights a single
// long expanding training prefix instead. Pure analytics overlay.
// No signals, non-repainting.
indicator("Walk-Forward Window Visualizer", overlay = true)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

trainSize = input.int(252, "Train size (bars)", minval = 2, group = "Window")
testSize  = input.int(63, "Test size (bars)", minval = 1, group = "Window")
anchored  = input.bool(false, "Anchored (expanding) train", group = "Window")
trainCol  = input.color(color.new(color.blue, 88), "Train band tint",
     group = "Display")
testCol   = input.color(color.new(color.orange, 80), "Test band tint",
     group = "Display")

idx = bar_index
cycle = trainSize + testSize
posInCycle = idx % cycle

isTest = not anchored and posInCycle >= trainSize
isTrain = not anchored and posInCycle < trainSize

// Anchored mode: a fixed expanding training prefix, then a contiguous
// out-of-sample test region that grows as the anchor extends.
isAnchoredTrain = anchored and idx < trainSize
isAnchoredTest = anchored and idx >= trainSize

bandCol = isTest ? testCol : isTrain ? trainCol : isAnchoredTest ? testCol : isAnchoredTrain ? trainCol : na
bgcolor(bandCol)

if barstate.islast
    var label tag = na
    if not na(tag)
        label.delete(tag)
    txt = (anchored ? "Anchored " : "Rolling ") + "WF | train " +
         str.tostring(trainSize) + " | test " + str.tostring(testSize)
    tag := label.new(bar_index, high, txt,
         style = label.style_label_down,
         color = color.new(color.gray, 30),
         textcolor = color.white)
````
