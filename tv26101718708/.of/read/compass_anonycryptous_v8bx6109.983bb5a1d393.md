Calculation: Stochastic RSI K = simple moving average of the stochastic oscillator applied to RSI; D = simple moving average of K.
Calculation: RSI pivot divergence = compare consecutive confirmed RSI pivot highs or lows, using the same number of chart bars on each side for confirmation; compare price high or low at those RSI pivot bars, without requiring price itself to form a pivot. Evaluate on the confirmation bar.
Calculation: Bullish fair value gap = low > high two bars ago AND low - high two bars ago > ATR multiplied by a width threshold AND previous close > high two bars ago AND low <= previous high AND previous low <= high two bars ago; its initial lower and upper boundaries are high two bars ago and current low. Bearish fair value gap = high < low two bars ago AND low two bars ago - high > ATR multiplied by the width threshold AND previous close < low two bars ago AND high >= previous low AND previous high >= low two bars ago; its initial upper and lower boundaries are low two bars ago and current high. Treat unavailable ATR as zero.
Calculation: Active fair value gap counts = track each newly formed gap and its remaining boundaries. For a bullish gap, when high > lower boundary AND low < upper boundary, remove it if low <= lower boundary; otherwise set the upper boundary to low. For a bearish gap, when low < upper boundary AND high > lower boundary, remove it if high >= upper boundary; otherwise set the lower boundary to high. Count remaining bullish and bearish gaps after updating on each bar.
Calculation: Psychological high and low = the running high and low of the most recent configured recurring higher-timeframe session, including the session still forming; retain the final values between sessions.
Long: Shorter-period EMA of the selected price source > longer-period EMA of the same source.
Short: Shorter-period EMA of the selected price source <= longer-period EMA of the same source.
Long: Close > long-term EMA of close.
Short: Close <= long-term EMA of close.
Long: Stochastic RSI K crosses above D AND (K < middle band OR D < middle band).
Short: Stochastic RSI K crosses below D AND (K > middle band OR D > middle band).
Long: Stochastic RSI K crosses above D AND (K < lower band OR D < lower band).
Short: Stochastic RSI K crosses below D AND (K > upper band OR D > upper band).
Long: Stochastic RSI K crosses above the lower band.
Short: Stochastic RSI K crosses below the upper band.
Long: Stochastic RSI K < lower band OR (K <= upper band AND K >= lower band AND K > middle band).
Short: Stochastic RSI K > upper band OR (K <= upper band AND K >= lower band AND K <= middle band).
Long: RSI >= its middle threshold.
Short: RSI < its middle threshold.
Long: A confirmed RSI pivot low is higher than the previous confirmed RSI pivot low AND its corresponding price low is lower than the price low at the previous RSI pivot low.
Short: A confirmed RSI pivot high is lower than the previous confirmed RSI pivot high AND its corresponding price high is higher than the price high at the previous RSI pivot high.
Long: Close >= open AND (volume >= a configurable multiple of its moving average OR volume multiplied by high minus low >= its highest value over a lookback).
Short: Close < open AND (volume >= a configurable multiple of its moving average OR volume multiplied by high minus low >= its highest value over a lookback).
Long: A bullish fair value gap forms.
Short: A bearish fair value gap forms.
Long: Active bullish fair value gap count > active bearish fair value gap count.
Short: Active bearish fair value gap count > active bullish fair value gap count.
Long: Close > psychological high.
Short: Close <= psychological high AND close < psychological low.
Long: Close > open of the higher-timeframe period containing the chart bar, using the bar still forming.
Short: Close <= open of the higher-timeframe period containing the chart bar, using the bar still forming.