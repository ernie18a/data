Calculation: Opening-range high, low, and anchor = high, low, and open of the most recent intraday chart bar whose opening time is 09:30 America/New_York; retain them until the next such bar.
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2.
Calculation: Lower wick = min(open, close) - low; upper wick = high - max(open, close); candle range = high - low.
Calculation: Bullish rejection block = candle range > 0 AND lower wick / candle range >= wick-fraction parameter AND lower wick > upper wick × wick-dominance parameter.
Calculation: Bearish rejection block = candle range > 0 AND upper wick / candle range >= wick-fraction parameter AND upper wick > lower wick × wick-dominance parameter.
Calculation: Bullish order block = close > open AND close - open > ATR × displacement parameter AND previous bar's open > previous bar's close.
Calculation: Bearish order block = open > close AND open - close > ATR × displacement parameter AND previous bar's open < previous bar's close.
Calculation: Bullish fair value gap = low > high two bars ago AND previous bar's close > previous bar's open.
Calculation: Bearish fair value gap = high < low two bars ago AND previous bar's open > previous bar's close.
Calculation: OTE zone = let swing high and swing low be the highest high and lowest low over a lookback including the current bar, and let range = swing high - swing low; if close > swing low + range × midpoint parameter, the zone is from swing low + range × lower retracement parameter to swing low + range × higher retracement parameter; otherwise it is from swing high - range × higher retracement parameter to swing high - range × lower retracement parameter.
Calculation: Standard-deviation bands = opening-range anchor ± rolling standard deviation of close × band multiplier; the rolling window includes the current bar.
Long: Bullish order block.
Short: Bearish order block.
Long: Bullish rejection block.
Short: Bearish rejection block.
Long: Bullish fair value gap.
Short: Bearish fair value gap.
Long: (low < lowest low over the preceding liquidity lookback AND close > that lowest low) OR (low < opening-range low AND close > opening-range low).
Short: ((high > highest high over the preceding liquidity lookback AND close < that highest high) OR (high > opening-range high AND close < opening-range high)) AND NOT ((low < lowest low over the preceding liquidity lookback AND close > that lowest low) OR (low < opening-range low AND close > opening-range low)).
Long: Chart bar opens during the America/New_York regular session AND ((low < lowest low over the preceding liquidity lookback AND close > that lowest low) OR (low < opening-range low AND close > opening-range low)) AND close > opening-range low AND (previous bar's bullish order block OR previous bar's bullish fair value gap OR previous bar's bullish rejection block OR abs(close - opening-range midpoint) < ATR × opening-range proximity parameter OR abs(close - opening-range low) < ATR × opening-range proximity parameter OR close within the OTE zone inclusive OR abs(close - lower standard-deviation band) < ATR × standard-deviation proximity parameter).
Short: Chart bar opens during the America/New_York regular session AND ((high > highest high over the preceding liquidity lookback AND close < that highest high) OR (high > opening-range high AND close < opening-range high)) AND close < opening-range high AND (previous bar's bearish order block OR previous bar's bearish fair value gap OR previous bar's bearish rejection block OR abs(close - opening-range midpoint) < ATR × opening-range proximity parameter OR abs(close - opening-range high) < ATR × opening-range proximity parameter OR close within the OTE zone inclusive OR abs(close - upper standard-deviation band) < ATR × standard-deviation proximity parameter).