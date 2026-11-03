Calculation: Upper channel = highest high in a lookback window beginning a configurable number of bars before each bar, on the configured indicator timeframe (higher or lower than the chart timeframe), using completed bars
Calculation: Lower channel = lowest low in a lookback window beginning a configurable number of bars before each bar, on the configured indicator timeframe (higher or lower than the chart timeframe), using completed bars
Long: last completed bar close > its upper channel AND preceding completed bar close <= its upper channel
Short: last completed bar close < its lower channel AND preceding completed bar close >= its lower channel
Exit: short, last completed bar close > its upper channel AND preceding completed bar close <= its upper channel
Exit: long, last completed bar close < its lower channel AND preceding completed bar close >= its lower channel