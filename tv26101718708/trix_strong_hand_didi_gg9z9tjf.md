# TRIX Strong Hand - Didi

- url: https://www.tradingview.com/script/Gg9z9tjF-TRIX-Strong-Hand-Didi/
- type: indicator
- pine_id: PUB;2bb03a9432c44b43a52905712bd999fe
- version: 3.0

## Description

**TRIX Strong Hand – Didi**

This indicator is a TRIX-based momentum tool configured according to the default parameters used in **Didi Aguiar’s CST (Cruzamento das Séries Temporais) trading system**.

The indicator plots the TRIX together with its moving average, making it easier to visualize changes in momentum and the relationship between the two lines.

### Default CST settings

The default parameters follow the configuration traditionally used in Didi Aguiar’s methodology:

- **TRIX Length:** 9
- **Moving Average:** 4 periods
- **Moving Average Type:** SMA

The moving average can optionally be changed from **SMA to EMA** in the indicator settings.

### How it works

The indicator displays:

- **TRIX line** – represents the momentum of price after triple exponential smoothing.
- **TRIX Moving Average** – provides a reference line for identifying changes in momentum.
- **Cross markers** – highlight points where the TRIX and its moving average cross.
- **Dynamic fill** – visually indicates which line is currently above the other.

By default, the TRIX is displayed in **blue** and its moving average in **yellow**, although both colors can be customized.

The fill between the two lines can also be enabled or disabled.

### Calculation

The TRIX is calculated using a triple exponential moving average of the logarithm of price and measuring its rate of change. The result is multiplied by 10,000 to improve visual readability.

### About the CST methodology

In Didi Aguiar’s CST trading system, the TRIX is one of the indicators used to evaluate market momentum and help identify the participation of the **“strong hand” (Mão Forte)** in conjunction with other elements of the methodology.

This indicator is intended to reproduce the TRIX configuration used within that framework. It should not be interpreted as a complete implementation of the CST trading system or as a standalone buy/sell signal.

**Disclaimer:** This script is an independent implementation for technical analysis and educational purposes and is not affiliated with or officially endorsed by Didi Aguiar.

## Source Code

````pine
//@version=6
indicator('TRIX Strong Hand - Didi', 'TRIX MF', format = format.price, timeframe = '', timeframe_gaps = true)

// Inputs
trixLen = input.int(9, title = 'TRIX Length', minval = 1)
maLen = input.int(4, title = 'Moving Average', minval = 1)
useEma = input.bool(false, title = 'Use Ema ?')
useFill = input.bool(true, title = 'Fill ?')

// Inputs Colors
colTrix = input.color(color.new(#5b9bf5, 0), 'TRIX Color', group = 'Colors Settings', inline = 'Color Settings')
colMa = input.color(color.new(#ffee58, 0), 'MA Color', group = 'Colors Settings', inline = 'Color Settings')

// Calculations
trix = 10000 * ta.change(ta.ema(ta.ema(ta.ema(math.log(close), trixLen), trixLen), trixLen))

ema = ta.ema(trix, maLen)
sma = ta.sma(trix, maLen)

ma = useEma ? ema : sma

// PLOTS
hline(0, color = #000000, title = 'Zero Line', display = display.none)

p1 = plot(trix, color = colTrix, title = 'TRIX')
p2 = plot(ma, 'MA Trix', color = colMa)
````
