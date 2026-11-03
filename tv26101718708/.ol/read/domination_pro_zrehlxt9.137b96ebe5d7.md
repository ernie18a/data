Calculation: Long-term moving average = SMA or EMA of open on the chart timeframe
Calculation: Short-term moving average = SMA or EMA of open on a lower timeframe
Calculation: ATR trend state = +1 when the prior state is -1 and open > prior lower trailing band, or when the prior state is +1 and open >= prior upper trailing band; otherwise -1 when the prior state is +1 and open < prior upper trailing band, or +1 when the prior state is -1 and open <= prior lower trailing band
Calculation: Upper trailing band = recursively updated open − ATR × multiplier; retain the greater of the current and prior band when prior open > prior upper trailing band
Calculation: Lower trailing band = recursively updated open + ATR × multiplier; retain the lesser of the current and prior band when prior open < prior lower trailing band
Long: ATR trend state = +1 AND prior ATR trend state = -1
Short: ATR trend state = -1 AND prior ATR trend state = +1
Long: open > long-term moving average AND open > short-term moving average OR open > long-term moving average AND open < short-term moving average
Short: open < long-term moving average AND open < short-term moving average OR open < long-term moving average AND open > short-term moving average