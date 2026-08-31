<!-- tradingview-pine-id: PUB;045b7aa26ee44e67bd2a304711d5120e -->
<!-- tradingviewscripts-format: 1 -->
# OBV - Volume Colored

Source: https://www.tradingview.com/script/usLb5Psn-OBV-Volume-Colored/

## Description

OBV with the source line colour coded to see whether volume on that day is above the 10 day average (green) or below (red)

The idea is that the pattern of red or green can indicate whether the OBV is moving with strong direction and volume or moving on weak direction and volume.

---

## Source Code

````pine
//@version=6
indicator("OBV - Volume Colored", shorttitle="OBV-VC", overlay=false)
// === Inputs ===
volMaLength = input.int(10, title="Volume MA Length", minval=1)
obvMaLength = input.int(20, title="OBV MA Length", minval=1)
obvMaType   = input.string("SMA", title="OBV MA Type", options=["SMA", "EMA"])
// === OBV Calculation ===
obv = ta.cum(math.sign(ta.change(close)) * volume)
// === OBV Moving Average ===
obvMA = obvMaType == "SMA" ? ta.sma(obv, obvMaLength) : ta.ema(obv, obvMaLength)
// === Relative Volume vs its Moving Average ===
volMA = ta.sma(volume, volMaLength)
// === Color Logic ===
// Green  = volume above its MA (high relative volume)
// Yellow = volume equal to its MA
// Red    = volume below its MA (low relative volume)
obvColor = volume > volMA ? color.new(color.green, 0) :
     volume < volMA ? color.new(color.red, 0) :
     color.new(color.yellow, 0)
plot(obv, title="OBV", color=obvColor, linewidth=2)
plot(obvMA, title="OBV MA", color=color.new(color.blue, 0), linewidth=1)
````
