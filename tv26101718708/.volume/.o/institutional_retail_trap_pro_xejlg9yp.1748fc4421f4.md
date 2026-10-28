Calculation: Smart and retail indices = RSI of the EMA-smoothed flow and its inverse, respectively; flow = (buy pressure − sell pressure) × relative volume, where buy pressure = ((close − low) / max(high − low, minimum price increment)) × volume, sell pressure = ((high − close) / max(high − low, minimum price increment)) × volume, and relative volume = volume / average volume
Calculation: Displacement = abs(close − open) > average(high − low) × displacement multiplier
Long: Smart index crosses above retail index while smart index < 40 OR retail index < 30 AND smart index > 60 AND displacement AND close > open
Short: retail index > 70 AND smart index < 40 AND displacement AND close < open
Exit: long, smart index crosses below retail index while smart index > 60