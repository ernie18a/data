Calculation: Rolling VWAP and deviation = Using hlc3 and volume, calculate volume-weighted mean and standard deviation over the preceding lookback minus one bars, excluding the current bar; clamp negative variance to zero before taking its square root. Calculate on chart bars, or on higher-timeframe bars using either the still-forming or last completed higher-timeframe bar. Alternatively, approximate the higher timeframe on chart bars by multiplying the lookback by the ratio of higher to chart timeframe durations. Optionally apply three successive EMAs to each projected series on the chart timeframe, using the same smoothing length.
Calculation: Bands = For each successive deviation multiplier from the innermost through the outermost layer, calculate VWAP plus or minus the multiplier times deviation, or VWAP times exp of plus or minus the multiplier times deviation divided by VWAP; use zero for the ratio when VWAP is zero or unavailable.
Calculation: Regular RSI divergence = Confirm an RSI pivot using equal numbers of bars on each side. Compare it with the preceding confirmed pivot of the same type, subject to minimum and maximum pivot-separation limits. Bullish divergence requires a higher RSI pivot low and a lower price low at the respective pivot bars; bearish divergence requires a lower RSI pivot high and a higher price high at those bars. Recognize divergence on the confirmation bar.
Calculation: Deviation score = (close minus rolling VWAP) divided by deviation; use zero when VWAP or deviation is unavailable or deviation is zero.
Long: close > rolling VWAP
Short: close <= rolling VWAP
Long: close >= rolling VWAP
Short: close < rolling VWAP
Long: deviation score < negative overextension threshold OR (deviation score <= positive overextension threshold AND deviation score >= negative overextension threshold AND close >= rolling VWAP)
Short: deviation score > positive overextension threshold OR (deviation score <= positive overextension threshold AND deviation score >= negative overextension threshold AND close < rolling VWAP)
Long: RSI < midpoint
Short: RSI > midpoint
Long: RSI <= oversold threshold
Short: RSI >= overbought threshold
Long: close crosses above rolling VWAP
Short: close crosses below rolling VWAP
Long: RSI-filtered reversal mode AND ((low is within tolerance times deviation of any band or VWAP OR low <= any band or VWAP AND close > that same line OR extreme-bypass enabled AND close < outermost lower band) AND (RSI <= oversold threshold OR RSI crosses above oversold threshold OR divergence enabled AND bullish RSI divergence) occurred within the momentum lookback) AND the preceding bar did not satisfy this same location-and-momentum condition
Short: RSI-filtered reversal mode AND ((high is within tolerance times deviation of any band or VWAP OR high >= any band or VWAP AND close < that same line OR extreme-bypass enabled AND close > outermost upper band) AND (RSI >= overbought threshold OR RSI crosses below overbought threshold OR divergence enabled AND bearish RSI divergence) occurred within the momentum lookback) AND the preceding bar did not satisfy this same location-and-momentum condition
Long: RSI-filtered reversal mode disabled AND close crosses above any lower band from the second innermost through the outermost
Short: RSI-filtered reversal mode disabled AND close crosses below any upper band from the second innermost through the outermost