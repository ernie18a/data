Exit: long, low <= stop-loss price OR high >= take-profit price
Exit: short, high >= stop-loss price OR low <= take-profit price
Calculation: long stop-loss price = max(previous long stop-loss price, close - trailing distance) when trailing distance > 0 and close - entry price > trailing distance
Calculation: short stop-loss price = min(previous short stop-loss price, close + trailing distance) when trailing distance > 0 and entry price - close > trailing distance