Calculation: Binned oscillator = the oscillator rounded down to its bin width; retain its previous bin when the oscillator is outside [0, 100), initializing the bin at zero.
Calculation: Relative volatility index = 100 times the EMA of standard deviation on bars where the source rises, divided by the sum of that EMA and the EMA of standard deviation on bars where the source does not rise; use the same standard-deviation lookback and EMA length for each instance.
Calculation: Smoothed balance of power = SMA of (100 × (close − open) / (high − low) + 50).
Calculation: General bottom = long-lookback binned RSI ≤ its lower threshold AND medium-lookback binned RSI < long-lookback binned RSI AND short-lookback binned RSI ≤ medium-lookback binned RSI AND long-lookback binned relative volatility index ≤ its lower threshold AND medium-lookback binned relative volatility index ≤ long-lookback binned relative volatility index AND short-lookback binned relative volatility index ≤ medium-lookback binned relative volatility index AND long-lookback binned MFI ≤ its lower threshold AND medium-lookback binned MFI ≤ long-lookback binned MFI AND short-lookback binned MFI ≤ medium-lookback binned MFI AND smoothed balance of power ≤ its lower threshold.
Calculation: General or critical market up = long-lookback binned RSI ≥ its upper threshold AND medium-lookback binned RSI > long-lookback binned RSI AND short-lookback binned RSI ≥ medium-lookback binned RSI AND long-lookback binned relative volatility index ≥ its upper threshold AND medium-lookback binned relative volatility index ≥ long-lookback binned relative volatility index AND short-lookback binned relative volatility index ≥ medium-lookback binned relative volatility index AND long-lookback binned MFI ≥ its upper threshold AND medium-lookback binned MFI ≥ long-lookback binned MFI AND short-lookback binned MFI ≥ medium-lookback binned MFI AND smoothed balance of power ≥ its upper threshold; use separate threshold sets for general and critical market ups.
Calculation: Critical bottom = the general-bottom comparisons with separate critical-bottom thresholds.
Calculation: Retained lower low = the rolling lowest low when that rolling lowest low falls; otherwise retain the previous retained lower low, initially the rolling lowest low.
Calculation: Lower-low reversal = retained lower low crossed low in either direction on the previous bar AND retained lower low fell on that bar AND retained lower low did not both cross low in either direction and fall on the current bar AND (open > close OR open two bars ago > current close).
Calculation: Uptrend supertrend average = SMA of supertrend values from bullish supertrend bars, ignoring missing values.
Calculation: Downtrend supertrend average = SMA of supertrend values from bearish supertrend bars, ignoring missing values; use the same supertrend and smoothing parameters as the uptrend supertrend average.
Long: Lower-low reversal AND position side is flat AND position side was flat throughout the preceding cooldown lookback AND datetime is within the configured trading window.
Long: General bottom was true on the previous bar AND general bottom is false AND low < entry price.
Long: Critical bottom AND low < entry price.
Long: SMA of the high-low midpoint is rising.
Long: (open > SMA of the selected price source OR close > SMA of the selected price source) AND open ≥ that SMA AND close ≥ that SMA.
Long: (open > parabolic SAR OR close > parabolic SAR) AND open ≥ parabolic SAR AND close ≥ parabolic SAR.
Long: (open > uptrend supertrend average OR close > uptrend supertrend average) AND open ≥ uptrend supertrend average AND close ≥ uptrend supertrend average.
Long: (open > downtrend supertrend average OR close > downtrend supertrend average) AND open ≥ downtrend supertrend average AND close ≥ downtrend supertrend average.
Long: ALMA of open is rising.
Short: General market up AND low > entry price × profit multiplier.
Short: Critical market up.
Short: open < SMA of the selected price source OR close < SMA of the selected price source.
Short: open < parabolic SAR OR close < parabolic SAR.
Short: open < uptrend supertrend average OR close < uptrend supertrend average.
Short: open < downtrend supertrend average OR close < downtrend supertrend average.
Short: ALMA of open is falling.