Calculation: Smoothed price = 5-bar simple moving average of HLC3
Calculation: Overbought state value = 85 if none of the last 5 closes is below the 10-bar highest value of Smoothed price; otherwise 0
Calculation: Oversold state value = 15 if each of the last 5 closes is below the 10-bar lowest value of Smoothed price; otherwise 0
Long: Oversold state value on the prior chart-timeframe bar = 15 AND Oversold state value on the current chart-timeframe bar = 0
Long: On a lower chart timeframe, the still-forming higher-timeframe Oversold state value = 15 OR it changed from 15 on the prior completed higher-timeframe bar to 0 on the still-forming higher-timeframe bar
Long: Current low > high two bars earlier AND (current low - high two bars earlier) / current close × 100 ≥ minimum gap percentage
Short: Overbought state value on the prior chart-timeframe bar = 85 AND Overbought state value on the current chart-timeframe bar = 0
Short: On a lower chart timeframe, the still-forming higher-timeframe Overbought state value = 85 OR it changed from 85 on the prior completed higher-timeframe bar to 0 on the still-forming higher-timeframe bar
Short: Current high < low two bars earlier AND (low two bars earlier - current high) / current close × 100 ≥ minimum gap percentage