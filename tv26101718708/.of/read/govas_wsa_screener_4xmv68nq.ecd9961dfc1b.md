Calculation: Stage MA = simple moving average of close on a higher timeframe, using the last completed bar.
Calculation: MA slope % = (current Stage MA − Stage MA from a longer lookback ago) / Stage MA from that lookback ago × 100, using completed bars on the higher timeframe.
Long: close > Stage MA AND MA slope % > flat-slope threshold
Short: close < Stage MA AND MA slope % < −flat-slope threshold