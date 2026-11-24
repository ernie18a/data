Calculation: Vortex(period) = close + sin(bar index * rotation speed / period) * ATR(period) * (volume amplification enabled ? 1 + (volume / SMA(volume, volume lookback) - 1) * volume weight : 1)
Calculation: Trend strength = ABS(Hurst exponent(close, Hurst lookback) - Hurst midpoint) * trend strength scale
Long: (Hurst exponent(close, Hurst lookback) < mean-reversion Hurst threshold AND RSI(close, RSI lookback) < oversold RSI threshold) OR (Trend strength > trend-strength threshold AND Vortex(shorter signal lookback) > close AND Vortex(longer signal lookback) > close AND RSI(close, RSI lookback) < RSI ceiling)
Long: RSI(close, RSI lookback) < documented oversold threshold AND close < SMA(close, SMA lookback) AND Vortex(shorter signal lookback) > close AND Vortex(longer signal lookback) > close
Short: RSI(close, RSI lookback) > documented overbought threshold AND close > SMA(close, SMA lookback) AND Vortex(shorter signal lookback) < close AND Vortex(longer signal lookback) < close
Long: Hurst exponent(close, Hurst lookback) < code Hurst threshold AND close < SMA(close, SMA lookback) AND RSI(close, RSI lookback) < code RSI threshold AND Vortex(shorter signal lookback) > close AND Vortex(longer signal lookback) > close
Short: Hurst exponent(close, Hurst lookback) > code Hurst threshold AND close > SMA(close, SMA lookback) AND RSI(close, RSI lookback) > code RSI threshold AND Vortex(shorter signal lookback) < close AND Vortex(longer signal lookback) < close
Long: Any Vortex value at one of the five ordered plotted lookbacks > close
Short: Any Vortex value at one of the five ordered plotted lookbacks < close
Exit: long, Hurst exponent(close, Hurst lookback) crosses below exit Hurst threshold
Exit: short, Hurst exponent(close, Hurst lookback) crosses below exit Hurst threshold