Calculation: Position age = consecutive chart bars in the current long position, counting the first bar as 1
Long: short-term EMA > long-term EMA AND close > open AND close > session VWAP AND open > session VWAP AND RSI on at least one of the configured number of prior completed chart bars < configured buy threshold
Long: position age > 2 AND close ≤ close from (position age − 1) chart bars ago AND RSI > RSI from (position age + 1) chart bars ago AND close > open AND close > session VWAP
Exit: long, RSI crosses down through configured sell threshold
Exit: long, close < average entry price × (1 − configured stop-loss percentage)