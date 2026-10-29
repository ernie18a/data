Calculation: +DI = 100 × RMA(high change when it exceeds negative low change, otherwise 0) / true range
Calculation: -DI = 100 × RMA(negative low change when it exceeds high change, otherwise 0) / true range
Long: short-term EMA crosses above long-term EMA
Short: short-term EMA crosses below long-term EMA
Long: +DI > -DI on the chart timeframe OR on an aggregated timeframe higher or lower than the chart timeframe, using its last completed bar
Short: -DI > +DI on the chart timeframe OR on an aggregated timeframe higher or lower than the chart timeframe, using its last completed bar
Exit: long, low <= entry price × (1 − risk percentage / 100)
Exit: short, high >= entry price × (1 + risk percentage / 100)