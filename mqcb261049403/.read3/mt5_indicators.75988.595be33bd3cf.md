Calculation: Market open = trade mode is not disabled AND a latest tick exists AND current time − latest tick time <= tick recency limit
Calculation: Spread points = (ask − bid) / point size
Calculation: Bullish breakout = bid > Highest(high, channel lookback, chart timeframe, last completed bars) + breakout buffer points × point size
Calculation: Bearish breakout = bid < Lowest(low, channel lookback, chart timeframe, last completed bars) − breakout buffer points × point size
Calculation: Bullish votes = count of chart timeframe trend bullish, T1 trend bullish (bar still forming, sampled on chart bars), RSI(close, RSI lookback, chart timeframe, bar still forming) > RSI bias threshold, and bullish breakout
Calculation: Bearish votes = count of chart timeframe trend bearish, T1 trend bearish (bar still forming, sampled on chart bars), RSI(close, RSI lookback, chart timeframe, bar still forming) < RSI bias threshold, and bearish breakout
Calculation: ADR used (%) = 100 × (high(T2, bar still forming) − low(T2, bar still forming)) / Average(high − low, ADR lookback, T2, last completed bars)
Long: chart timeframe trend is bullish
Short: chart timeframe trend is bearish
Long: T1 trend is bullish (bar still forming, sampled on chart bars)
Short: T1 trend is bearish (bar still forming, sampled on chart bars)
Long: bullish breakout
Short: bearish breakout
Long: Market open AND bullish votes >= minimum vote count AND (RSI(close, RSI lookback, chart timeframe, bar still forming) < overbought threshold OR bullish votes <= bearish votes)
Short: Market open AND bearish votes >= minimum vote count AND (RSI(close, RSI lookback, chart timeframe, bar still forming) > oversold threshold OR bearish votes <= bullish votes)
Long: T1 trend is bullish (bar still forming, sampled on chart bars) AND bullish breakout AND RSI(close, RSI lookback, chart timeframe, bar still forming) < overbought threshold AND volatility status is normal or high AND Market open AND bullish votes >= minimum vote count AND Spread points <= normal spread limit AND (ADR used <= ADR exhaustion limit OR close(T2, bar still forming) <= open(T2, bar still forming))
Short: T1 trend is bearish (bar still forming, sampled on chart bars) AND bearish breakout AND RSI(close, RSI lookback, chart timeframe, bar still forming) > oversold threshold AND volatility status is normal or high AND Market open AND bearish votes >= minimum vote count AND Spread points <= normal spread limit AND (ADR used <= ADR exhaustion limit OR close(T2, bar still forming) >= open(T2, bar still forming))
Long: chart timeframe trend is bullish AND T1 trend is bullish (bar still forming, sampled on chart bars) AND RSI(close, RSI lookback, chart timeframe, bar still forming) <= oversold threshold