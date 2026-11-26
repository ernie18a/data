# Fibonacci MA Trend Gap V1

- url: https://www.tradingview.com/script/l7erV7F1-Fibonacci-MA-Trend-Gap-V1/
- type: indicator
- pine_id: PUB;dcd603d4367948d9839c8aa5a8b1a833
- version: 1.0

## Description

Overview
The Smart Fibonacci Trend Gap is a comprehensive momentum and mean-reversion oscillator designed to identify when price action has overextended relative to its Fibonacci-weighted trend. By calculating the squared variance between the current price and a composite average of 17 Fibonacci lengths, this tool highlights high-probability reversal zones and trend exhaustion points.

Key Features
📐 Multi-Fibonacci Core: Calculates an aggregate mean from up to 17 different Fibonacci moving average lengths (2 to 4181), providing a much "smoother" and more reliable trend baseline than a single MA.

🔍 Auto-Divergence Detection: Automatically identifies and draws Regular and Hidden bullish/bearish divergences directly on the oscillator. Solid lines indicate Regular divergence; dashed lines indicate Hidden.

⚡ Dual Signal Lines: Includes a Fast (Red) and Slow (Green) signal crossover system for confirming momentum shifts and trend changes.

🌈 Visual Sentiment: The background dynamically shifts color based on the Signal Line crossover, providing an instant "at-a-glance" read on the current trend bias.

🛠 Fully Customizable: Choose from 7 different MA types (SMA, EMA, WMA, HMA, VWMA, SMMA, DEMA) and toggle exactly how many Fibonacci lengths to include in the calculation.

How to Use
Mean Reversion: When the cyan oscillator line reaches extreme peaks or valleys away from the zero line, look for Regular Divergence (Triangles) to signal a potential snap-back to the mean.

Trend Following: Use the background color and Signal Line crossovers (Red/Green) to stay on the right side of the macro trend.

Hidden Divergence: Use dashed-line signals to identify trend continuation opportunities during pullbacks.

Settings
MA Type: Change the underlying math of the trend (HMA for speed, EMA for standard trend following).

Number of MAs: Scale the sensitivity by including more or fewer Fibonacci lengths.

Divergence Lookback: Fine-tune how sensitive the pivot detection is to fit your specific timeframe.

## Source Code

````pine
//@version=6
indicator("Fibonacci MA Trend Deviation", overlay = false)

// --- General Inputs ---
maTypeInput = input.string("SMA", "MA Type", options = ["SMA", "EMA", "WMA", "HMA", "VWMA", "SMMA", "DEMA"])
maSrce      = input.source(close, "Source")
showOnly    = input.int(17, "Number of MAs", minval = 1, maxval = 17)

// --- Signal Line Inputs ---
gSig = "Signal Settings"
fastSigLen = input.int(13, "Fast Signal (Red)", minval=1, group=gSig)
slowSigLen = input.int(89, "Slow Signal (Green)", minval=1, group=gSig)

// --- MA Length Inputs ---
g1 = "MA Length Settings"
f1=input.int(2,"MA 1",group=g1,inline="1"),   f2=input.int(3,"MA 2",group=g1,inline="1")
f3=input.int(5,"MA 3",group=g1,inline="2"),   f4=input.int(8,"MA 4",group=g1,inline="2")
f5=input.int(13,"MA 5",group=g1,inline="3"),  f6=input.int(21,"MA 6",group=g1,inline="3")
f7=input.int(34,"MA 7",group=g1,inline="4"),  f8=input.int(55,"MA 8",group=g1,inline="4")
f9=input.int(89,"MA 9",group=g1,inline="5"),  f10=input.int(144,"MA 10",group=g1,inline="5")
f11=input.int(233,"MA 11",group=g1,inline="6"), f12=input.int(377,"MA 12",group=g1,inline="6")
f13=input.int(610,"MA 13",group=g1,inline="7"), f14=input.int(987,"MA 14",group=g1,inline="7")
f15=input.int(1597,"MA 15",group=g1,inline="8"), f16=input.int(2584,"MA 16",group=g1,inline="8")
f17=input.int(4181,"MA 17",group=g1,inline="9")

// --- Divergence Settings ---
g2 = "Divergence Settings"
lbP = input.int(5, "Left Lookback", group=g2)
rbP = input.int(5, "Right Lookback", group=g2)

// --- MA Wrapper ---
getMA(type, src, len) =>
    type == "SMA"  ? ta.sma(src, len)  :
     type == "EMA"  ? ta.ema(src, len)  :
     type == "WMA"  ? ta.wma(src, len)  :
     type == "HMA"  ? ta.hma(src, len)  :
     type == "VWMA" ? ta.vwma(src, len) :
     type == "SMMA" ? ta.rma(src, len)  :
     type == "DEMA" ? (2 * ta.ema(src, len) - ta.ema(ta.ema(src, len), len)) : na

// --- Calculation ---
m01=showOnly>=1?getMA(maTypeInput,maSrce,f1):na, m02=showOnly>=2?getMA(maTypeInput,maSrce,f2):na
m03=showOnly>=3?getMA(maTypeInput,maSrce,f3):na, m04=showOnly>=4?getMA(maTypeInput,maSrce,f4):na
m05=showOnly>=5?getMA(maTypeInput,maSrce,f5):na, m06=showOnly>=6?getMA(maTypeInput,maSrce,f6):na
m07=showOnly>=7?getMA(maTypeInput,maSrce,f7):na, m08=showOnly>=8?getMA(maTypeInput,maSrce,f8):na
m09=showOnly>=9?getMA(maTypeInput,maSrce,f9):na, m10=showOnly>=10?getMA(maTypeInput,maSrce,f10):na
m11=showOnly>=11?getMA(maTypeInput,maSrce,f11):na, m12=showOnly>=12?getMA(maTypeInput,maSrce,f12):na
m13=showOnly>=13?getMA(maTypeInput,maSrce,f13):na, m14=showOnly>=14?getMA(maTypeInput,maSrce,f14):na
m15=showOnly>=15?getMA(maTypeInput,maSrce,f15):na, m16=showOnly>=16?getMA(maTypeInput,maSrce,f16):na
m17=showOnly>=17?getMA(maTypeInput,maSrce,f17):na

sumMAs = nz(m01)+nz(m02)+nz(m03)+nz(m04)+nz(m05)+nz(m06)+nz(m07)+nz(m08)+nz(m09)+nz(m10)+nz(m11)+nz(m12)+nz(m13)+nz(m14)+nz(m15)+nz(m16)+nz(m17)
avgFibMA = sumMAs / showOnly
diff = avgFibMA != 0 ? (math.pow(close, 2) - math.pow(avgFibMA, 2)) / math.pow(avgFibMA, 2) : na
diffMAHi = ta.sma(diff, fastSigLen)
diffMALow = ta.sma(diff, slowSigLen)

// --- Divergence Logic ---
ph = ta.pivothigh(diff, lbP, rbP)
pl = ta.pivotlow(diff, lbP, rbP)

// Indices and Values
phBar = ta.valuewhen(not na(ph), bar_index[rbP], 0)
prevPhBar = ta.valuewhen(not na(ph), bar_index[rbP], 1)
phVal = ta.valuewhen(not na(ph), diff[rbP], 0)
prevPhVal = ta.valuewhen(not na(ph), diff[rbP], 1)

plBar = ta.valuewhen(not na(pl), bar_index[rbP], 0)
prevPlBar = ta.valuewhen(not na(pl), bar_index[rbP], 1)
plVal = ta.valuewhen(not na(pl), diff[rbP], 0)
prevPlVal = ta.valuewhen(not na(pl), diff[rbP], 1)

highVal = ta.valuewhen(not na(ph), high[rbP], 0)
prevHighVal = ta.valuewhen(not na(ph), high[rbP], 1)
lowVal = ta.valuewhen(not na(pl), low[rbP], 0)
prevLowVal = ta.valuewhen(not na(pl), low[rbP], 1)

// Divergence Conditions
regBear = not na(ph) and phVal < prevPhVal and highVal > prevHighVal
hidBear = not na(ph) and phVal > prevPhVal and highVal < prevHighVal
regBull = not na(pl) and plVal > prevPlVal and lowVal < prevLowVal
hidBull = not na(pl) and plVal < prevPlVal and lowVal > prevLowVal

// --- Global Plotting ---
plot(diff, "Oscillator", color=#21c9f3, linewidth=2)
plot(diffMAHi, "Signal Fast (Red)", color=color.red, linewidth=2)
plot(diffMALow, "Signal Slow (Green)", color=color.green, linewidth=2)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// Triangles (Plotshape must be in global scope)
plotshape(regBear or hidBear ? diff[rbP] : na, title="Bear Triangle", style=shape.triangledown, location=location.absolute, color=color.red, size=size.small, offset=-rbP)
plotshape(regBull or hidBull ? diff[rbP] : na, title="Bull Triangle", style=shape.triangleup, location=location.absolute, color=color.green, size=size.small, offset=-rbP)

// --- Bridge Lines and Text ---
if regBear or hidBear
    lStyle = regBear ? line.style_solid : line.style_dashed
    line.new(prevPhBar, prevPhVal, phBar, phVal, color=color.red, style=lStyle)
    label.new(phBar, phVal, text=(regBear ? "Reg" : "Hid"), color=color.new(color.white, 100), textcolor=color.blue, style=label.style_label_down, size=size.small)

if regBull or hidBull
    lStyle = regBull ? line.style_solid : line.style_dashed
    line.new(prevPlBar, prevPlVal, plBar, plVal, color=color.green, style=lStyle)
    label.new(plBar, plVal, text=(regBull ? "Reg" : "Hid"), color=color.new(color.white, 100), textcolor=color.blue, style=label.style_label_up, size=size.small)

bgcolor(diffMAHi > diffMALow ? color.new(color.green, 92) : color.new(color.red, 92))
````
