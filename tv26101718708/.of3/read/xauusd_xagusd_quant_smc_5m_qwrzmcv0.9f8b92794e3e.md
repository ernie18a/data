Calculation: Higher-timeframe bias = on chart bars using current, possibly forming T1 and T2 bars; bullish when close(T1) > EMA(close, EMA lookback, T1) and close(T2) > EMA(close, EMA lookback, T2); bearish when both closes are <= their EMAs; aligned when both are bullish or both are bearish
Calculation: BOS state = on chart bars using current, possibly forming T3 values; bullish after close(T3) crosses above the prior chart bar's highest(high, rolling lookback, T3) while bias is bullish; bearish after close(T3) crosses below the prior chart bar's lowest(low, rolling lookback, T3) while bias is not bullish; reset on trend change, daily boundary, or entry
Calculation: BOS range = at each BOS, highest(high, rolling lookback, T3) and lowest(low, rolling lookback, T3), using the current T3 bar; retain until reset or the next BOS
Calculation: Bullish retracement = BOS high - (BOS high - BOS low) × retracement fraction
Calculation: Bearish retracement = BOS low + (BOS high - BOS low) × retracement fraction
Calculation: Bullish target = BOS high + (BOS high - BOS low) × target extension fraction
Calculation: Bearish target = BOS low - (BOS high - BOS low) × target extension fraction
Calculation: Daily closed-trade P&L = sum of closed-trade profits as a percentage of initial capital since the daily boundary
Calculation: Weekly closed-trade P&L = sum of closed-trade profits as a percentage of initial capital since the weekly boundary
Long: bias is bullish AND BOS state is bullish AND low crosses below bullish retracement AND chart-bar hour >= session start parameter AND chart-bar hour < session end parameter AND daily closed-trade P&L > daily loss-limit parameter AND weekly closed-trade P&L > weekly loss-limit parameter AND weekly closed-trade P&L < weekly profit-cap parameter AND entries since daily boundary < daily entry-cap parameter
Short: bias is bearish AND BOS state is bearish AND high crosses above bearish retracement AND chart-bar hour >= session start parameter AND chart-bar hour < session end parameter AND daily closed-trade P&L > daily loss-limit parameter AND weekly closed-trade P&L > weekly loss-limit parameter AND weekly closed-trade P&L < weekly profit-cap parameter AND entries since daily boundary < daily entry-cap parameter
Exit: long, low <= BOS low OR high >= bullish target
Exit: short, high >= BOS high OR low <= bearish target