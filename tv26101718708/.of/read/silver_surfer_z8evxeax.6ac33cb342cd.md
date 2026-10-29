Calculation: CISD trend state = Start Neutral; when close crosses above the open of the latest bearish non-inside bar, set Bullish; when close crosses below the open of the latest bullish non-inside bar, set Bearish; otherwise retain the prior state. An inside bar has high below the prior bar’s high and low above its low.
Calculation: Bullish FVG = current bar low > high two bars earlier
Calculation: Bearish FVG = current bar high < low two bars earlier
Long: higher-timeframe CISD trend state is Bullish AND chart-timeframe CISD trend state is Bullish AND Bullish FVG AND (BOS filter disabled OR current high > highest high of the prior 10 chart bars) AND position is flat
Short: higher-timeframe CISD trend state is Bearish AND chart-timeframe CISD trend state is Bearish AND Bearish FVG AND (BOS filter disabled OR current low < lowest low of the prior 10 chart bars) AND position is flat
Exit: long, current low <= current close - ATR × stop multiplier OR current high >= current close + ATR × stop multiplier × risk-reward ratio
Exit: short, current high >= current close + ATR × stop multiplier OR current low <= current close - ATR × stop multiplier × risk-reward ratio