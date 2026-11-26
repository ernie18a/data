# Kernel Regression Envelope with SMI Oscillator

- url: https://www.tradingview.com/script/WMt0guGu-Kernel-Regression-Envelope-with-SMI-Oscillator/
- type: strategy
- pine_id: PUB;a5ab85f918e142a9a704cc2e6eb302bc
- version: 1.0

## Description

This script combines the predictive capabilities of the **Nadaraya-Watson estimator**, implemented by the esteemed jdehorty (credit to him for his excellent work on the `KernelFunctions` library and the original Nadaraya-Watson Envelope indicator), with the confirmation strength of the **Stochastic Momentum Index (SMI)** to create a dynamic trend reversal strategy. The core idea is to identify potential overbought and oversold conditions using the Nadaraya-Watson Envelope and then confirm these signals with the SMI before entering a trade.

**Understanding the Nadaraya-Watson Envelope:**

The Nadaraya-Watson estimator is a non-parametric regression technique that essentially calculates a weighted average of past price data to estimate the current underlying trend. Unlike simple moving averages that give equal weight to all past data within a defined period, the Nadaraya-Watson estimator uses a **kernel function** (in this case, the Rational Quadratic Kernel) to assign weights. The key parameters influencing this estimation are:

*   **Lookback Window (h):** This determines how many historical bars are considered for the estimation. A larger window results in a smoother estimation, while a smaller window makes it more reactive to recent price changes.
*   **Relative Weighting (alpha):** This parameter controls the influence of different time frames in the estimation. Lower values emphasize longer-term price action, while higher values make the estimator more sensitive to shorter-term movements.
*   **Start Regression at Bar (x\_0):** This allows you to exclude the potentially volatile initial bars of a chart from the calculation, leading to a more stable estimation.

The script calculates the Nadaraya-Watson estimation for the closing price (`yhat_close`), as well as the highs (`yhat_high`) and lows (`yhat_low`). The `yhat_close` is then used as the central trend line.

**Dynamic Envelope Bands with ATR:**

To identify potential entry and exit points around the Nadaraya-Watson estimation, the script uses **Average True Range (ATR)** to create dynamic envelope bands. ATR measures the volatility of the price. By multiplying the ATR by different factors (`nearFactor` and `farFactor`), we create multiple bands:

*   **Near Bands:**  These are closer to the Nadaraya-Watson estimation and are intended to identify potential immediate overbought or oversold zones.
*   **Far Bands:** These are further away and can act as potential take-profit or stop-loss levels, representing more extreme price extensions.

The script calculates both near and far upper and lower bands, as well as an average between the near and far bands. This provides a nuanced view of potential support and resistance levels around the estimated trend.

**Confirming Reversals with the Stochastic Momentum Index (SMI):**

While the Nadaraya-Watson Envelope identifies potential overextended conditions, the **Stochastic Momentum Index (SMI)** is used to confirm a potential trend reversal. The SMI, unlike a traditional stochastic oscillator, oscillates around a zero line. It measures the location of the current closing price relative to the median of the high/low range over a specified period.

The script calculates the SMI on a **higher timeframe** (defined by the "Timeframe" input) to gain a broader perspective on the market momentum. This helps to filter out potential whipsaws and false signals that might occur on the current chart's timeframe. The SMI calculation involves:

*   **%K Length:** The lookback period for calculating the highest high and lowest low.
*   **%D Length:** The period for smoothing the relative range.
*   **EMA Length:** The period for smoothing the SMI itself.

The script uses a double EMA for smoothing within the SMI calculation for added smoothness.

**How the Indicators Work Together in the Strategy:**

The strategy enters a long position when:

1. The closing price crosses below the **near lower band** of the Nadaraya-Watson Envelope, suggesting a potential oversold condition.
2. The SMI crosses above its EMA, indicating positive momentum.
3. The SMI value is below -50, further supporting the oversold idea on the higher timeframe.

Conversely, the strategy enters a short position when:

1. The closing price crosses above the **near upper band** of the Nadaraya-Watson Envelope, suggesting a potential overbought condition.
2. The SMI crosses below its EMA, indicating negative momentum.
3. The SMI value is above 50, further supporting the overbought idea on the higher timeframe.

Trades are closed when the price crosses the **far band** in the opposite direction of the trade. A stop-loss is also implemented based on a fixed value.

**In essence:** The Nadaraya-Watson Envelope identifies areas where the price might be deviating significantly from its estimated trend. The SMI, calculated on a higher timeframe, then acts as a confirmation signal, suggesting that the momentum is shifting in the direction of a potential reversal. The ATR-based bands provide dynamic entry and exit points based on the current volatility.

**How to Use the Script:**

1. **Apply the script to your chart.**
2. **Adjust the "Kernel Settings":**
    *   **Lookback Window (h):** Experiment with different values to find the smoothness that best suits the asset and timeframe you are trading. Lower values make the envelope more reactive, while higher values make it smoother.
    *   **Relative Weighting (alpha):** Adjust to control the influence of different timeframes on the Nadaraya-Watson estimation.
    *   **Start Regression at Bar (x\_0):**  Increase this value if you want to exclude the initial, potentially volatile, bars from the calculation.
    *   **Stoploss:** Set your desired stop-loss value.
3. **Adjust the "SMI" settings:**
    *   **%K Length, %D Length, EMA Length:** These parameters control the sensitivity and smoothness of the SMI. Experiment to find settings that work well for your trading style.
    *   **Timeframe:** Select the higher timeframe you want to use for SMI confirmation.
4. **Adjust the "ATR Length" and "Near/Far ATR Factor":** These settings control the width and sensitivity of the envelope bands. Smaller ATR lengths make the bands more reactive to recent volatility.
5. **Customize the "Color Settings"** to your preference.
6. **Observe the plots:**
    *   The **Nadaraya-Watson Estimation (yhat)** line represents the estimated underlying trend.
    *   The **near and far upper and lower bands** visualize potential overbought and oversold zones based on the ATR.
    *   The **fill areas** highlight the regions between the near and far bands.
7. **Look for entry signals:**  A long entry is considered when the price touches or crosses below the lower near band and the SMI confirms upward momentum. A short entry is considered when the price touches or crosses above the upper near band and the SMI confirms downward momentum.
8. **Manage your trades:** The script provides exit signals when the price crosses the far band. The fixed stop-loss will also close trades if the price moves against your position.

**Justification for Combining Nadaraya-Watson Envelope and SMI:**

The combination of the Nadaraya-Watson Envelope and the SMI provides a more robust approach to identifying potential trend reversals compared to using either indicator in isolation. The Nadaraya-Watson Envelope excels at identifying potential areas where the price is overextended relative to its recent history. However, relying solely on the envelope can lead to false signals, especially in choppy or volatile markets. By incorporating the SMI as a confirmation tool, we add a momentum filter that helps to validate the potential reversals signaled by the envelope. The higher timeframe SMI further helps to filter out noise and focus on more significant shifts in momentum. The ATR-based bands add a dynamic element to the entry and exit points, adapting to the current market volatility. This mashup aims to leverage the strengths of each indicator to create a more reliable trading strategy.

## Source Code

````pine
//@version=5
// Credit: jdehorty's Nadaraya-Watson-Envelope indicators (great indicator!) (https://www.tradingview.com/script/WeLssFxl-Nadaraya-Watson-Envelope-Non-Repainting/)
import jdehorty/KernelFunctions/2 as kernels 
strategy(title="1.0", overlay=true)


// Helper Functions
getBounds(_atr, _Factor, _yhat) => 
    _upper = _yhat + _Factor*_atr
    _lower = _yhat - _Factor*_atr
    [_upper, _lower]

kernel_atr(length, _high, _low, _close) =>
    trueRange = na(_high[1])? _high-_low : math.max(math.max(_high - _low, math.abs(_high - _close[1])), math.abs(_low - _close[1]))
    ta.rma(trueRange, length)


ma(source, length, type) =>
    switch type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)



//SMI 
lengthK   = input.int(50, "%K Length",  minval = 1, maxval = 15000,group="SMI")
lengthD   = input.int(10,  "%D Length",  minval = 1, maxval = 4999,group="SMI")
lengthEMA = input.int(10,  "EMA Length", minval = 1, maxval = 4999,group="SMI")
tf = input.timeframe(title="Timeframe", defval="15",group="SMI")
emaEma(source, length) => ta.ema(ta.ema(source, length), length)
highestHigh = request.security(syminfo.tickerid, tf, ta.highest(lengthK), lookahead=barmerge.lookahead_off)
lowestLow = request.security(syminfo.tickerid, tf, ta.lowest(lengthK), lookahead=barmerge.lookahead_off)
highestLowestRange = highestHigh - lowestLow
relativeRange = close - (highestHigh + lowestLow) / 2
smi = 200 * (emaEma(relativeRange, lengthD) / emaEma(highestLowestRange, lengthD))
smi_ema = ta.ema(smi, lengthEMA)

// Kernel Settings
h = input.int(50, 'Lookback Window', tooltip='The number of bars used for the estimation. This is a sliding value that represents the most recent historical bars. Recommended range: 3-50', group='Kernel Settings')
alpha = input.float(1, 'Relative Weighting', step=0.25, tooltip='Relative weighting of time frames. As this value approaches zero, the longer time frames will exert more influence on the estimation. As this value approaches infinity, the behavior of the Rational Quadratic Kernel will become identical to the Gaussian kernel. Recommended range: 0.25-25', group='Kernel Settings')
x_0 = input.int(1000, "Start Regression at Bar", tooltip='Bar index on which to start regression. The first bars of a chart are often highly volatile, and omission of these initial bars often leads to a better overall fit. Recommended range: 5-25', group='Kernel Settings')
sl = input.int(750000,'Stoploss',group='Kernel Settings',step=5)

// Envelope Calculations
yhat_close = kernels.rationalQuadratic(close, h, alpha, x_0)
yhat_high = kernels.rationalQuadratic(high, h, alpha, x_0)
yhat_low = kernels.rationalQuadratic(low, h, alpha, x_0)
yhat = yhat_close
atr_length = input.int(50, 'ATR Length', minval=1, tooltip='The number of bars associated with the Average True Range (ATR).')
ktr = kernel_atr(atr_length, yhat_high, yhat_low, yhat_close)
Factor = input.float(5, 'ATR Factor', minval=0.5, step=0.25, tooltip='The factor by which to multiply the ATR to calculate the near bound of the envelope.')
[upper, lower] = getBounds(ktr, Factor, yhat_close)

// Colors
upper_color = input.color(color.new(color.red, 60), title='Upper Boundary Color', tooltip='The color of the farmost upper boundary of the envelope.', group='Color Settings')
yhat_green = input.color(color.new(color.green, 50), title='Bullish Estimator Color', tooltip='The Bullish color of the Nadaraya-Watson estimator.', group='Color Settings')
yhat_red = input.color(color.new(color.red, 50), title='Bearish Estimator Color', tooltip='The Bearish color of the Nadaraya-Watson estimator.', group='Color Settings')
lower_color = input.color(color.new(color.green, 60), title='Lower Boundary Color', tooltip='The color of the farmost lower boundary of the envelope.', group='Color Settings')

// Plots
p_upper = plot(upper, color=upper_color, title='Upper Boundary: Far')
p_yhat = plot(yhat_close, color=yhat > yhat[1] ? yhat_green : yhat_red, linewidth=2, title='Nadaraya-Watson Estimation')
p_lower = plot(lower, color=lower_color, title='Lower Boundary: Near')

// Fills
fill(p_upper, p_upper, color=upper_color, title='Upper Boundary')
fill(p_lower, p_lower, color=lower_color, title='Lower Boundaryn')


lastPriceEntry = strategy.opentrades.entry_price(strategy.opentrades - 1)
long_condition = (close < lower and ta.crossover(smi,smi_ema) and smi < -50)
short_condition = (close > upper and ta.crossunder(smi,smi_ema) and smi > 50)
long_closed_condition = ta.crossover(close,upper)
short_closed_condition = ta.crossunder(close,lower)
 

if (long_condition)
    strategy.entry('Long',strategy.long)
    strategy.exit('Exit long','Long',loss = sl)

if (long_closed_condition)
    strategy.close('Long')

if (short_condition)
    strategy.entry('Short',strategy.short)
    strategy.exit('Exit short','Short',loss = sl)

if (short_closed_condition)
    strategy.close('Short')
````
