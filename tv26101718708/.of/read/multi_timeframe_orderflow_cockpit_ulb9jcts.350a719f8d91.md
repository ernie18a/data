Calculation: Buy and sell volume = sum classified volume over completed lower-timeframe bars within each chart or higher-timeframe bar, including those available in the still-forming higher-timeframe bar. In binary mode, allocate all volume to buy when close >= open and otherwise to sell. In weighted mode, allocate volume × (close − low) / (high − low) to buy and the remainder to sell; when high = low, use the binary allocation.
Calculation: Delta bias = (total buy volume − total sell volume) / (total buy volume + total sell volume) over a panel's configured number of completed bars plus its still-forming bar.
Calculation: Toxicity = moving average of absolute per-bar buy-minus-sell volume divided by moving average of per-bar buy-plus-sell volume, on the panel's timeframe; use the still-forming bar for a higher-timeframe panel.
Calculation: Structure state = initially neutral; set bullish when close exceeds the most recent unbroken confirmed pivot high and bearish when close falls below the most recent unbroken confirmed pivot low. A pivot is confirmed after the same number of bars used on each side of it; discard a pivot after it is broken. Use the still-forming bar for a higher-timeframe panel.
Calculation: Panel probability = logistic transform of fusion gain × ((1 − structure weight) × delta bias + structure weight × structure state), where bullish, bearish and neutral structure states are +1, −1 and 0. Multiply the score by a damping factor when nonneutral structure and delta bias disagree, and optionally by 0.5 + min(toxicity, 1). Exclude panels with no classified volume.
Calculation: Combined probability = logistic transform of the correlation discount × weighted mean of enabled panel probability logits. Panel weights are either equal or proportional to the square root of their timeframe durations. Use the chart timeframe and enabled higher timeframes, with the higher-timeframe bars still forming.
Calculation: Range position = (close − lowest low) / (highest high − lowest low) over the reversion lookback; use 0.5 when the range is zero.
Calculation: Delta z-score = the z-score of the rolling sum of chart-bar buy-minus-sell volume over the reversion lookback, using a longer lookback for its mean and standard deviation; use zero when the standard deviation is zero.
Long: Chart or higher-timeframe structure state = bullish.
Short: Chart or higher-timeframe structure state = bearish.
Long: Chart or higher-timeframe panel probability > its neutral midpoint.
Short: Chart or higher-timeframe panel probability < its neutral midpoint.
Long: Combined probability > its neutral midpoint.
Short: Combined probability < its neutral midpoint.
Long: Combined probability > an upper bullish threshold.
Short: Combined probability < a lower bearish threshold.
Long: Range position <= the lower extreme threshold AND delta z-score > the negative delta-confirmation threshold.
Short: Range position >= the upper extreme threshold AND delta z-score < the positive delta-confirmation threshold.
Long: Range position <= the lower extreme threshold AND delta z-score > the negative delta-confirmation threshold AND, if the optional toxicity filter is enabled, chart-timeframe toxicity > its moving average × the toxicity multiplier.
Short: Range position >= the upper extreme threshold AND delta z-score < the positive delta-confirmation threshold AND, if the optional toxicity filter is enabled, chart-timeframe toxicity > its moving average × the toxicity multiplier.