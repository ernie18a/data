# 16-Apr Entry Test

- url: https://www.tradingview.com/script/7Z3SlUc6-16-Apr-Entry-Test/
- type: indicator
- pine_id: PUB;d5cec12de8f4404a963069a0b2dd3f1d
- version: 1.0

## Description

this is not of much use. I was looking at DMA x over on 16 Apr and in how many the SL is hit. found it to be 4:14

## Source Code

````pine
//@version=6
indicator("16-Apr Entry Test", overlay=true)

targetDate = timestamp(2026, 4, 16, 0, 0)

isTargetBar = time >= targetDate and time[1] < targetDate

if isTargetBar
    entryPrice = high
    stopPrice  = high * 0.90

    // Vertical line
    line.new(
         bar_index, low * 0.95,
         bar_index, high * 1.05,
         color=color.blue,
         width=2)

    // Entry line
    line.new(
         bar_index, entryPrice,
         bar_index + 45, entryPrice,
         color=color.green,
         width=2)

    // Stop-loss line
    line.new(
         bar_index, stopPrice,
         bar_index + 45, stopPrice,
         color=color.red,
         width=2)
````
