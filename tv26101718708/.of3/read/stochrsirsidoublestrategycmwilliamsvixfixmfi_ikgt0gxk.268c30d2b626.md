Calculation: Stochastic %K = SMA(Stochastic(close, high, low, stochastic lookback), stochastic K smoothing)
Calculation: Stochastic RSI %K = SMA(Stochastic(RSI(close, RSI lookback), RSI(close, RSI lookback), RSI(close, RSI lookback), stochastic lookback), stochastic K smoothing)
Calculation: Stochastic RSI %D = SMA(Stochastic RSI %K, stochastic D smoothing)
Long: Stochastic %K crosses above Stochastic RSI %D AND Stochastic RSI %K < stochastic oversold parameter AND RSI(close, RSI lookback) crosses above RSI oversold parameter
Short: Stochastic %K crosses below Stochastic RSI %D AND Stochastic %K > stochastic overbought parameter AND RSI(close, RSI lookback) crosses below RSI overbought parameter
Calculation: Williams Vix Fix = (highest(close, Vix Fix lookback) - low) / highest(close, Vix Fix lookback) * 100
Long: Williams Vix Fix >= Bollinger upper band(Williams Vix Fix, band lookback, standard deviation multiplier) OR Williams Vix Fix >= highest(Williams Vix Fix, percentile lookback) * percentile factor