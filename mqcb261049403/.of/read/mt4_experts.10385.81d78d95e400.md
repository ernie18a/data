Calculation: Indicator bars = bars on a configurable timeframe that may be higher than, lower than, or equal to the chart timeframe; forming means the bar still forming at the decision time, and completed means the last completed bar.
Calculation: Perceptron = the sum of four configurable weights times inputs at four configurable, increasing completed-bar offsets. Choose one input type for all four: close at the offset minus open at the next older offset, stochastic main line with EMA smoothing minus its midpoint, or CCI using a configurable price source. The close-minus-open variant uses a fifth, older offset.
Calculation: Direction score = a weighted sum of Accelerator Oscillator values at four configurable, increasing completed-bar offsets, with an independently configurable weight for each offset.
Calculation: MA trend = down when the forming-bar moving averages of close, weighted price, typical price, median price, and open are strictly descending in that order; otherwise up. All five use the same configurable moving-average method and lookback.
Calculation: CCI trailing level = for a long, start at the positive entry threshold minus a positive step; scan completed-bar CCI backward from the latest bar through and including the most recent bar that produced either CCI breakout entry, adding one step whenever the scanned CCI is greater than the current level plus two steps. For a short, start at the positive entry threshold plus the step and subtract one step whenever the scanned CCI is less than the current level minus two steps.
Long: On completed indicator bars, the short-lookback close EMA is above the long-lookback close EMA AND on the preceding indicator bar it was below the long-lookback EMA AND the long-lookback EMA is rising.
Short: On completed indicator bars, the short-lookback close EMA is below the long-lookback close EMA AND on the preceding indicator bar it was above the long-lookback EMA AND the long-lookback EMA is falling.
Exit: long, the completed indicator-bar short-lookback close EMA is below the long-lookback close EMA.
Exit: short, the completed indicator-bar short-lookback close EMA is above the long-lookback close EMA.
Long: Completed indicator-bar typical-price CCI is above a negative threshold AND the preceding indicator-bar CCI is below that threshold.
Short: Completed indicator-bar typical-price CCI is below a positive threshold AND the preceding indicator-bar CCI is above that threshold.
Exit: long, the most recent completed indicator-bar CCI reversal entry was short.
Exit: short, the most recent completed indicator-bar CCI reversal entry was long.
Long: On the forming indicator bar, short-, medium-, and long-lookback open EMAs are all rising AND short EMA > medium EMA AND medium EMA > long EMA AND the open-price MACD main line is rising AND is above a positive threshold.
Short: On the forming indicator bar, short-, medium-, and long-lookback open EMAs are all falling AND short EMA < medium EMA AND medium EMA < long EMA AND the open-price MACD main line is falling AND is below a negative threshold.
Exit: long, the last completed chart-bar close is below the forming indicator-bar medium-lookback open EMA.
Exit: short, the last completed chart-bar close is above the forming indicator-bar medium-lookback open EMA.
Long: Completed indicator-bar typical-price CCI is above a positive breakout threshold AND the preceding indicator-bar CCI is below it.
Short: Completed indicator-bar typical-price CCI is below the negative of the breakout threshold AND the preceding indicator-bar CCI is above it.
Exit: long, completed indicator-bar breakout CCI is below the long CCI trailing level.
Exit: short, completed indicator-bar breakout CCI is above the short CCI trailing level.
Long: Perceptron >= long entry threshold.
Short: Perceptron <= short entry threshold.
Exit: long, Perceptron <= long exit threshold.
Exit: short, Perceptron >= short exit threshold.
Long: Direction score >= long entry threshold.
Short: Direction score <= short entry threshold.
Exit: long, Direction score <= long exit threshold.
Exit: short, Direction score >= short exit threshold.
Long: MA trend is up AND the previously observed MA trend was down.
Short: MA trend is down AND the previously observed MA trend was up.