Calculation: Fast MA = selected moving average of close using a shorter lookback than the slow MA
Calculation: Slow MA = the same selected moving average of close using a longer lookback than the fast MA
Calculation: CVD = cumulative sum of volume × ((close − low) − (high − close)) / (high − low), with zero delta when high = low
Calculation: ATR volatility filter = current ATR is greater than the simple moving average of ATR over the same lookback
Long: Fast MA crosses above slow MA AND CVD is higher than on the previous bar AND the ATR volatility filter passes AND the cooldown since the previous signal has elapsed
Long: ADX is at or above the chop threshold AND fast MA is above slow MA
Long: SuperTrend direction is bullish
Short: Fast MA crosses below slow MA AND CVD is not higher than on the previous bar AND the ATR volatility filter passes AND the cooldown since the previous signal has elapsed
Short: ADX is at or above the chop threshold AND fast MA is at or below slow MA
Short: SuperTrend direction is bearish