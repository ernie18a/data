Calculation: RSI = Relative Strength Index on the selected indicator-timeframe bar; uses the forming bar in LiveBar mode or the last completed bar in NewBar mode. The timeframe’s relation to the chart timeframe is unspecified.
Calculation: Bollinger Bands = standard upper and lower bands on the selected indicator-timeframe bar; uses the forming bar in LiveBar mode or the last completed bar in NewBar mode. The timeframe’s relation to the chart timeframe is unspecified.
Exit: long, current bid > upper Bollinger Band AND RSI > 70 AND current bid > entry price
Exit: short, current ask < lower Bollinger Band AND RSI < 30 AND current ask < entry price
Exit: long or short, CloseAll > 0 AND account profit at initialization > CloseAll