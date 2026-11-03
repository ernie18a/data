Calculation: Inside candle = a higher-timeframe bar whose high is below the prior higher-timeframe bar’s high and whose low is above the prior bar’s low; use the last completed bars.
Long: close > high of the latest inside candle AND bar time < detection bar time + one higher-timeframe interval
Short: close < low of the latest inside candle AND bar time < detection bar time + one higher-timeframe interval
Exit: Long, low <= low of the inside candle used for entry OR high >= entry price + (entry price - low of that inside candle) × risk-reward ratio
Exit: Short, high >= high of the inside candle used for entry OR low <= entry price - (high of that inside candle - entry price) × risk-reward ratio