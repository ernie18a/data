Calculation: Smoothed TMEI score = weighted moving average of (100 × (1 − Shannon entropy of the five RSI states over a rolling lookback, normalized by maximum entropy) × the sign of the weighted bullish-minus-bearish state frequencies × a volume multiplier); the volume multiplier is reduced when 20-bar Chaikin Money Flow contradicts the directional sign.
Long: In CHOP, Smoothed TMEI score > bullish activation threshold OR Smoothed TMEI score crosses above bullish expansion threshold
Short: In CHOP, Smoothed TMEI score < bearish activation threshold OR Smoothed TMEI score crosses below bearish expansion threshold
Exit: long, Smoothed TMEI score < bullish activation threshold minus exit buffer
Exit: short, Smoothed TMEI score > bearish activation threshold plus exit buffer