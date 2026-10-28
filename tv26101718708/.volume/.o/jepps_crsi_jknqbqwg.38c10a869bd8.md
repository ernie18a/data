Calculation: cRSI = EMA of twice the smoothed RSI minus that RSI lagged by half the EMA smoothing length; RSI uses close changes smoothed with RMA over a lookback shorter than the band lookback
Calculation: Low band = lower percentile of cRSI over the band lookback + half the cRSI range over that lookback
Calculation: High band = upper percentile of cRSI over the band lookback − half the cRSI range over that lookback
Long: cRSI < Low band OR cRSI crosses above its moving average
Short: cRSI > High band OR cRSI crosses below its moving average