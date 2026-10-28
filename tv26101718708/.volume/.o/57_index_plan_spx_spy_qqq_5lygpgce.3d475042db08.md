Calculation: Trend alignment = close > 9-period EMA AND 9-period EMA >= 21-period EMA AND close >= session VWAP for long; reverse all comparisons for short
Calculation: Opening range high/low = highest high / lowest low during the configured opening interval of the current session
Long: On an eligible confirmed in-session bar after the configured minimum bars from open, close crosses above the configured bull trigger or bull confirmation level AND long trend alignment AND VIX < bear-confirmation threshold AND (opening-range filter disabled, range incomplete, or close >= opening-range low)
Long: On an eligible confirmed in-session bar, close crosses above the configured opening-range high AND close > pivot AND long trend alignment AND VIX < bear-confirmation threshold
Long: QQQ low <= configured hold level AND close > that level AND close > 9-period EMA AND VIX < bear-confirmation threshold
Short: On an eligible confirmed in-session bar, close crosses below the configured bear trigger AND short trend alignment AND VIX >= bear-confirmation threshold AND (opening-range filter disabled, range incomplete, or close <= opening-range high)
Short: On an eligible confirmed in-session bar, close crosses below the configured bear-warning level AND VIX >= bear-confirmation threshold
Short: On an eligible confirmed in-session bar, high > bull-confirmation level AND close < configured failure level AND VIX >= bear-confirmation threshold
Short: On an eligible confirmed in-session bar, high > pivot AND close < pivot AND VIX >= bear-confirmation threshold
Short: On an eligible confirmed in-session bar, close crosses below the configured opening-range low AND close < pivot AND short trend alignment AND VIX >= bear-confirmation threshold
Exit: No reproducible exit decision specified.