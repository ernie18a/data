Long: Mayer Multiple(close(T1, current bar while forming, sampled on chart bars), price lookback in chart bars) < oversold threshold OR (trend color mode selected AND Mayer Multiple(close(T1, current bar while forming, sampled on chart bars), price lookback in chart bars) < SMA(Mayer Multiple(close(T1, current bar while forming, sampled on chart bars), price lookback in chart bars), multiple lookback in chart bars))
Short: Mayer Multiple(close(T1, current bar while forming, sampled on chart bars), price lookback in chart bars) > overbought threshold OR (trend color mode selected AND Mayer Multiple(close(T1, current bar while forming, sampled on chart bars), price lookback in chart bars) > SMA(Mayer Multiple(close(T1, current bar while forming, sampled on chart bars), price lookback in chart bars), multiple lookback in chart bars))
Calculation: Mayer Multiple = BTCUSD close on T1 / SMA(BTCUSD close on T1, price SMA length)
Long: Mayer Multiple < oversold threshold
Short: Mayer Multiple > overbought threshold
Long: Mayer Multiple > SMA(Mayer Multiple, multiple SMA length)
Short: Mayer Multiple < SMA(Mayer Multiple, multiple SMA length)