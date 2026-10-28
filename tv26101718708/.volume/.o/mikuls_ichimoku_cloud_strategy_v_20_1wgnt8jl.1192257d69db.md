Calculation: Conversion line = midpoint of the highest high and lowest low over its lookback
Calculation: Base line = midpoint of the highest high and lowest low over a longer lookback than the conversion line
Calculation: Leading span A = midpoint of the conversion line and base line
Calculation: Leading span B = midpoint of the highest high and lowest low over a lookback longer than the base line’s
Calculation: Current cloud boundaries = leading spans A and B shifted back by the cloud displacement minus one bar; upper boundary is span A and lower boundary is span B
Calculation: Far cloud boundaries = current cloud boundaries shifted back by one further cloud displacement
Calculation: Lagging span = close
Calculation: Trailing stop = for longs, either the selected source (lowest low over a lookback, close, or open) minus ATR times a multiplier, or that source multiplied by one minus a percentage; update only when the new stop is higher than the previous stop
Calculation: Take profit = entry price multiplied by one plus a percentage
Long: conversion line crosses above base line OR (close > close one displacement ago AND close > both current cloud boundaries AND close > open AND conversion line crosses above base line AND conversion line and base line are both above both current cloud boundaries) OR (close > both far cloud boundaries AND close > the high one displacement ago AND close > both current cloud boundaries AND close > open AND leading span A > leading span B AND conversion line > base line AND (prior close <= either prior current cloud boundary OR prior close <= prior high one displacement ago OR leading span A crossed above leading span B) AND (moving average filter is disabled OR close > the selected moving average))
Short: conversion line crosses below base line
Exit: Long, Ichimoku exit is enabled or selected AND (close crosses below the typical price from the cloud displacement ago OR base line crosses above conversion line AND close < leading span A)
Exit: Long, low <= trailing stop
Exit: Long, take profit is enabled AND high >= take profit