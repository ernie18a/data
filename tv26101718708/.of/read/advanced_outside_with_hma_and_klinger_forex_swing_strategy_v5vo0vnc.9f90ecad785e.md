Calculation: Klinger Oscillator = EMA(signed volume, shorter lookback) − EMA(signed volume, longer lookback), where signed volume is volume when HLC3 is greater than or equal to its prior-bar value, and −volume otherwise
Long: high > prior-bar high AND low < prior-bar low AND close > open AND Klinger Oscillator > 0 AND close > Hull moving average of close
Short: high < prior-bar high AND low > prior-bar low AND close < open AND Klinger Oscillator < 0 AND close < Hull moving average of close
Exit: long, high ≥ entry price + close × take-profit percentage OR low ≤ entry price − close × stop-loss percentage
Exit: short, low ≤ entry price − close × take-profit percentage OR high ≥ entry price + close × stop-loss percentage