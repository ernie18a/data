Calculation: Prior liquidity high = highest high over the liquidity lookback, excluding the current bar; this lookback is longer than the BOS lookback
Calculation: Prior liquidity low = lowest low over the liquidity lookback, excluding the current bar
Calculation: Bullish BOS level = highest high over the BOS lookback, excluding the current bar
Calculation: Bearish BOS level = lowest low over the BOS lookback, excluding the current bar
Calculation: Daily ATR = ATR calculated from daily bars, using the last completed daily bar
Calculation: Session valid = current bar is within any enabled Asian, London, or New York session
Long: low < Prior liquidity low AND close > Prior liquidity low AND (min(open, close) - low) / max(high - low, minimum tick size) >= minimum wick ratio AND close > Bullish BOS level AND close >= VWAP AND Prior liquidity low - low >= Daily ATR * 0.30 * minimum sweep fraction AND Session valid
Short: high > Prior liquidity high AND close < Prior liquidity high AND (high - max(open, close)) / max(high - low, minimum tick size) >= minimum wick ratio AND close < Bearish BOS level AND close <= VWAP AND high - Prior liquidity high >= Daily ATR * 0.30 * minimum sweep fraction AND Session valid