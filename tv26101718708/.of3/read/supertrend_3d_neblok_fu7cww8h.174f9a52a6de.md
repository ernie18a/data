Calculation: volatility scale = IF adaptive multiplier enabled THEN adaptive min scale + (adaptive max scale - adaptive min scale) * PercentRank(ATR(atr lookback, atr smoothing), adaptive lookback) / 100 ELSE 1
Calculation: band width = multiplier * volatility scale * ATR(atr lookback, atr smoothing)
Calculation: SuperTrend lower band = IF close[1] > SuperTrend lower band[1] THEN MAX(SuperTrend lower band[1], source - band width) ELSE source - band width
Calculation: SuperTrend upper band = IF close[1] < SuperTrend upper band[1] THEN MIN(SuperTrend upper band[1], source + band width) ELSE source + band width
Calculation: SuperTrend trend = long IF SuperTrend trend[1] = short AND (IF flip trigger = Wick THEN high ELSE close) > SuperTrend upper band[1]; short IF SuperTrend trend[1] = long AND (IF flip trigger = Wick THEN low ELSE close) < SuperTrend lower band[1]; otherwise SuperTrend trend[1]
Calculation: HTF band width (T1 bars) = multiplier * ATR(atr lookback, RMA)
Calculation: HTF SuperTrend lower band (T1 bars) = IF close[1] > HTF SuperTrend lower band[1] THEN MAX(HTF SuperTrend lower band[1], source - HTF band width) ELSE source - HTF band width
Calculation: HTF SuperTrend upper band (T1 bars) = IF close[1] < HTF SuperTrend upper band[1] THEN MIN(HTF SuperTrend upper band[1], source + HTF band width) ELSE source + HTF band width
Calculation: HTF SuperTrend trend (T1 bars) = long IF HTF SuperTrend trend[1] = short AND close > HTF SuperTrend upper band[1]; short IF HTF SuperTrend trend[1] = long AND close < HTF SuperTrend lower band[1]; otherwise HTF SuperTrend trend[1]
Calculation: relative volume = IF SMA(volume, volume lookback) > 0 THEN volume / SMA(volume, volume lookback) ELSE 1
Calculation: enabled checks = number of true among (ADX check enabled, volume check enabled, conviction check enabled, HTF check enabled)
Calculation: long points = number of true among (ADX check enabled AND ADX(ADX lookback) >= ADX threshold, volume check enabled AND relative volume >= volume multiple, conviction check enabled AND (close - SuperTrend upper band[1]) / ATR(atr lookback, atr smoothing) >= conviction threshold, HTF check enabled AND HTF SuperTrend trend (T1, last completed bar) = long)
Calculation: short points = number of true among (ADX check enabled AND ADX(ADX lookback) >= ADX threshold, volume check enabled AND relative volume >= volume multiple, conviction check enabled AND (SuperTrend lower band[1] - close) / ATR(atr lookback, atr smoothing) >= conviction threshold, HTF check enabled AND HTF SuperTrend trend (T1, last completed bar) = short)
Long: SuperTrend trend = long
Long: SuperTrend trend = long AND SuperTrend trend[1] = short
Long: SuperTrend trend = long AND SuperTrend trend[1] = short AND long points >= MIN(minimum points, enabled checks)
Short: SuperTrend trend = short
Short: SuperTrend trend = short AND SuperTrend trend[1] = long
Short: SuperTrend trend = short AND SuperTrend trend[1] = long AND short points >= MIN(minimum points, enabled checks)