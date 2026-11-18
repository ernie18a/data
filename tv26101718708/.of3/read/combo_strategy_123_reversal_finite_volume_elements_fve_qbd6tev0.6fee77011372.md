Calculation: FVE line = prior FVE line (starting at zero) + ((signed volume / SMA(volume, FVE lookback)) / FVE lookback) × 100, where signed volume is volume if close - HL2 + HLC3 - HLC3[1] > FVE sensitivity × close / 100, -volume if it is < -FVE sensitivity × close / 100, and 0 otherwise
Calculation: reversal direction = long when close[reversal pattern lookback] < close[1] AND close > close[1] AND SMA(Stochastic Fast(close, high, low, reversal stochastic lookback), K smoothing) < SMA(SMA(Stochastic Fast(close, high, low, reversal stochastic lookback), K smoothing), D smoothing) AND SMA(Stochastic Fast(close, high, low, reversal stochastic lookback), K smoothing) > reversal level; short when close[reversal pattern lookback] > close[1] AND close < close[1] AND SMA(Stochastic Fast(close, high, low, reversal stochastic lookback), K smoothing) > SMA(SMA(Stochastic Fast(close, high, low, reversal stochastic lookback), K smoothing), D smoothing) AND SMA(Stochastic Fast(close, high, low, reversal stochastic lookback), K smoothing) < reversal level; otherwise its previous direction, starting neutral
Calculation: FVE direction = long when FVE line > FVE line[1] AND FVE line > FVE line[FVE confirmation lookback]; short when FVE line < FVE line[1] AND FVE line < FVE line[FVE confirmation lookback]; otherwise its previous direction, starting neutral
Long: close[k] > close[k+1] for every k from 0 through rising close lookback minus 1 AND Stochastic Slow(close, high, low, entry stochastic lookback) < entry stochastic threshold
Short: close[k] < close[k+1] for every k from 0 through falling close lookback minus 1 AND Stochastic Fast(close, high, low, entry stochastic lookback) > entry stochastic threshold
Long: reversal direction is long
Short: reversal direction is short
Long: FVE direction is long
Short: FVE direction is short
Long: reversal direction is long AND FVE direction is long
Short: reversal direction is short AND FVE direction is short