# Momentum Pressure Index [Trading_Box]

- url: https://www.tradingview.com/script/Pk36PS6z-Momentum-Pressure-Index-Trading-Box/
- type: indicator
- pine_id: PUB;c9e90493a73745c2b72b88980348e055
- version: 1.0

## Description

[b]Momentum Pressure Index (MPI)[/b]
Momentum Pressure Index (MPI) is a momentum oscillator designed to measure the strength and direction of current market pressure by combining price momentum, RSI-based momentum, and ATR-normalized price movement. The components are combined into a composite pressure value and statistically normalized using a rolling mean and standard deviation.

[b]How MPI Works [/b]
1. Price Momentum — 40% MPI uses Rate of Change (ROC) to measure percentage price movement over the selected momentum period.

2. RSI Momentum — 35% RSI is centered around zero by subtracting 50. Positive values represent bullish momentum and negative values represent bearish momentum.

3. ATR-Normalized Momentum — 25% Price movement over the momentum period is divided by ATR, helping normalize movement according to current market volatility.

4. Composite Pressure The three components are combined using weighted contributions: Price Momentum × 40% + RSI Momentum × 35% + ATR Momentum × 25%. The result is smoothed with an EMA.

5. Statistical Normalization MPI is calculated from the difference between pressure and its rolling mean, divided by the rolling standard deviation. The final value is constrained between -3 and +3.

[b]Color Interpretation [/b]
Red → strong negative momentum.
Purple → neutral or transitional momentum.
Teal → strong positive momentum.

Signal Levels MPI uses +2 and -2 as extreme momentum zones. Below -2 indicates potentially strong negative pressure, while above +2 indicates potentially strong positive pressure.

Buy signal: MPI crosses above -2.
Sell signal: MPI crosses below +2.

[b]Inputs [/b]

Momentum Length: Controls the period used for price momentum, RSI momentum, and ATR-normalized movement.

Smooth Length: Controls EMA smoothing applied to the combined pressure calculation.
Normalization Length: Controls the rolling statistical window used to calculate the mean and standard deviation.

Practical Use MPI can help identify momentum expansion, momentum weakening, strong bullish or bearish pressure, extreme momentum conditions, and potential momentum reversals. It is best used with price structure, trend analysis, support/resistance, or other confirmation tools.

Important Note MPI measures momentum and market pressure. It does not guarantee future price direction and should not be treated as a standalone trading system.

## Source Code

````pine
//@version=6
indicator("Momentum Pressure Index [Trading_Box]", overlay = false)

momentumLength = input.int(14, "Momentum Length", minval = 1)
smoothLength = input.int(5, "Smooth Length", minval = 1)
normalizationLength = input.int(50, "Normalization Length", minval = 10)

priceMomentum = ta.roc(close, momentumLength)

rsiMomentum = ta.rsi(close, momentumLength) - 50

atrValue = ta.atr(14)
atrMomentum = atrValue != 0 ? (close - close[momentumLength]) / atrValue : 0

rawPressure = priceMomentum * 0.40 +
              rsiMomentum * 0.35 +
              atrMomentum * 0.25

pressure = ta.ema(rawPressure, smoothLength)

pressureMean = ta.sma(pressure, normalizationLength)
pressureDev = ta.stdev(pressure, normalizationLength)

mpi = pressureDev != 0 ?
      (pressure - pressureMean) / pressureDev :
      0

mpi := math.max(-3.0, math.min(3.0, mpi))

mpiColor = mpi < 0 ?
     color.from_gradient(mpi, -3, 0, color.red, color.purple) :
     color.from_gradient(mpi, 0, 3, color.purple, color.teal)

m = plot(mpi, "MPI", color = mpiColor, linewidth = 2)

hline(0, "Zero", color = color.gray)
h = plot(2, "Upper", color = color.new(color.teal, 60))
l = plot(-2, "Lower", color = color.new(color.red, 60))


buy_signal = ta.crossover(mpi, -2)
sell_signal = ta.crossunder(mpi, 2)


plotshape(buy_signal, title="", style=shape.triangleup, location=location.bottom, color=color.green, text="", textcolor=color.white, size=size.tiny)
plotshape(sell_signal, title="", style=shape.triangledown, location=location.top, color=color.red, text="", textcolor=color.white, size=size.tiny)

//────────────────────────────────────
// FILLS
//────────────────────────────────────
//fill(plot1, plot2, top_value, bottom_value, top_color, bottom_color, title, display, fillgaps, editable) → void
fill(
     m,
     h,
     mpi,
     2,
     color.new(color.red, 80),
     na
)

fill(
     m,
     l,
     mpi,
     -2,
     color.new(color.teal, 80),
     na
)
````
