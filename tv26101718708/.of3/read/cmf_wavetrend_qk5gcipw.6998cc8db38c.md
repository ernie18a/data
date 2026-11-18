Calculation: WaveTrend oscillator = WaveTrend(hlc3, channel lookback, average lookback)
Calculation: WaveTrend signal = SMA(WaveTrend oscillator, signal smoothing lookback)
Calculation: CMF = selected aggregation of money-flow volume over lookback divided by the same aggregation of weighted volume over lookback, where weighted volume = volume^(volume exponent / exponent scale) * (money-volume mode ? price source : 1), and money-flow volume = 0 if max(high, close[1]) equals min(low, close[1]), otherwise (2 * close - (max(high, close[1]) + min(low, close[1]))) / true range * weighted volume
Calculation: Exit CMF = percentage mode ? 50 * CMF + 50 : CMF
Long: WaveTrend oscillator crosses above oversold threshold AND WaveTrend oscillator > WaveTrend signal AND CMF < long CMF threshold
Short: WaveTrend oscillator crosses below overbought threshold AND WaveTrend signal < WaveTrend oscillator AND CMF > short CMF threshold
Exit: long, Exit CMF[1] crosses above long exit threshold OR stop/take-profit enabled AND (low <= open of most recent long-entry signal bar - stop distance OR high >= close of most recent long-entry signal bar + profit distance)
Exit: short, Exit CMF[1] crosses below short exit threshold OR stop/take-profit enabled AND (high >= open of most recent short-entry signal bar + stop distance OR low <= close of most recent short-entry signal bar - profit distance)