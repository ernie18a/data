Calculation: Relative volume = volume / average volume over a lookback
Calculation: Smart-money flow index = RSI of EMA of ((buying pressure − selling pressure) × relative volume), where buying pressure = ((close − low) / max(high − low, minimum price increment)) × volume and selling pressure = ((high − close) / max(high − low, minimum price increment)) × volume
Calculation: Retail flow index = RSI of EMA of the negative of ((buying pressure − selling pressure) × relative volume), using the same smoothing and RSI lookbacks as the smart-money flow index
Calculation: Displacement = absolute(close − open) > average(high − low) over a lookback × a multiplier
Long: Smart-money flow index crosses above retail flow index AND smart-money flow index < 40
Long: Retail flow index < 30 AND smart-money flow index > 60 AND displacement AND close > open
Short: Retail flow index > 70 AND smart-money flow index < 40 AND displacement AND close < open
Exit: long, smart-money flow index crosses below retail flow index AND smart-money flow index > 60