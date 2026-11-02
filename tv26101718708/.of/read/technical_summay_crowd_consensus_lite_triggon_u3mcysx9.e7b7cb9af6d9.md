Calculation: Input bars = chart bars, or bars from a selectable higher or lower timeframe mapped to chart bars before indicator calculations. For a higher timeframe, use its last completed bar; for a lower timeframe, use its last completed intrabar within the chart bar. Calculate indicators on the resulting chart-bar series.
Calculation: Stochastic RSI = RSI normalized over its rolling RSI range, with a midpoint value when the range is zero; smooth it with an SMA to obtain K, then smooth K with another SMA to obtain D.
Calculation: Consensus = the greater of the enabled bullish and bearish vote counts divided by the total enabled bullish, bearish, and neutral votes; use a denominator of one if the total is zero. Each oscillator decision below contributes one vote; each separately enabled moving average contributes one vote. A vote is neutral when neither directional condition holds.
Calculation: Phase = on intraday input timeframes, reset to undefined at the start of each day; on each confirmed chart bar, retain the previous phase when consensus is below the neutral threshold, otherwise set it to bullish when bullish votes are at least bearish votes and bearish when bearish votes exceed bullish votes. Setting an undefined phase is not a flip.
Long: RSI is at or below its lower threshold OR RSI is above its midpoint AND below its upper threshold.
Short: RSI is at or above its upper threshold OR RSI is below its midpoint AND above its lower threshold.
Long: Smoothed stochastic K is at or below its lower threshold OR K is strictly between its lower and upper thresholds AND K is above its SMA signal D.
Short: Smoothed stochastic K is at or above its upper threshold OR K is strictly between its lower and upper thresholds AND K is below its SMA signal D.
Long: CCI of typical price is above zero.
Short: CCI of typical price is below zero.
Long: MACD line is above its signal line.
Short: MACD line is below its signal line.
Long: Awesome Oscillator is above zero.
Short: Awesome Oscillator is below zero.
Long: Close is above the close a selected lookback ago.
Short: Close is below the close a selected lookback ago.
Long: Williams %R is at or below its lower threshold OR Williams %R is above its midpoint AND below its upper threshold; use the midpoint when its price range is zero.
Short: Williams %R is at or above its upper threshold OR Williams %R is below its midpoint AND above its lower threshold; use the midpoint when its price range is zero.
Long: Stochastic RSI K is at or below its lower threshold OR K is strictly between its lower and upper thresholds AND K is above D.
Short: Stochastic RSI K is at or above its upper threshold OR K is strictly between its lower and upper thresholds AND K is below D.
Long: Ultimate Oscillator is at or below its lower threshold OR it is above its midpoint AND below its upper threshold; use a midpoint ratio for any lookback whose true-range sum is zero.
Short: Ultimate Oscillator is at or above its upper threshold OR it is below its midpoint AND above its lower threshold; use a midpoint ratio for any lookback whose true-range sum is zero.
Long: Close is above its EMA.
Short: Close is below its EMA.
Long: Close is above an enabled EMA or SMA at any of five progressively longer paired lookbacks, or above an enabled VWMA or HMA; the VWMA uses the second-shortest paired lookback and the HMA uses a shorter lookback than the shortest pair.
Short: Close is below an enabled EMA or SMA at any of five progressively longer paired lookbacks, or below an enabled VWMA or HMA; the VWMA uses the second-shortest paired lookback and the HMA uses a shorter lookback than the shortest pair.
Long: Consensus is at least the neutral threshold AND bullish votes are at least bearish votes AND (contrarian mode is disabled OR consensus is below the strong threshold) OR contrarian mode is enabled AND consensus is at least the strong threshold AND bearish votes exceed bullish votes.
Short: Consensus is at least the neutral threshold AND bearish votes exceed bullish votes AND (contrarian mode is disabled OR consensus is below the strong threshold) OR contrarian mode is enabled AND consensus is at least the strong threshold AND bullish votes are at least bearish votes.
Long: Phase flips from bearish to bullish on a confirmed chart bar.
Short: Phase flips from bullish to bearish on a confirmed chart bar.
Long: Phase flips from bearish to bullish on a confirmed chart bar AND consensus meets the selected minimum or maximum entry threshold AND (EMA filter is disabled OR input low is above the EMA of the selected input price source).
Short: Phase flips from bullish to bearish on a confirmed chart bar AND consensus meets the selected minimum or maximum entry threshold AND (EMA filter is disabled OR input high is below the EMA of the selected input price source).
Exit: long, phase flips from bullish to bearish on a confirmed chart bar AND consensus meets the selected minimum or maximum entry threshold AND (EMA filter is disabled OR input high is below the EMA of the selected input price source).
Exit: short, phase flips from bearish to bullish on a confirmed chart bar AND consensus meets the selected minimum or maximum entry threshold AND (EMA filter is disabled OR input low is above the EMA of the selected input price source).