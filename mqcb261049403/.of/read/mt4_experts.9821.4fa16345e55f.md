Calculation: Current daily open = open of the daily bar aggregated from chart-timeframe bars; the daily bar is higher than the chart timeframe and still forming
Calculation: Current daily low = lowest low so far in that higher-timeframe daily bar, which is still forming
Calculation: Current daily high = highest high so far in that higher-timeframe daily bar, which is still forming
Long: current price > current daily open AND current daily open - current daily low > a threshold in points AND no open orders AND current hour < 16
Short: current price < current daily open AND current daily high - current daily open > a threshold in points AND no open orders AND current hour < 16
Exit: long, current hour > configured market-close hour - 1
Exit: short, current hour > configured market-close hour - 1