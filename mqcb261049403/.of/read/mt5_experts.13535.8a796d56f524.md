Calculation: Fast CCI average = a shorter-period moving average of CCI of a selected price, calculated on a configurable timeframe that may be the chart timeframe, higher, or lower; use the last completed bar by default or the forming bar if configured.
Calculation: Slow CCI average = a longer-period moving average of the fast CCI average, using the same averaging method and timeframe.
Long: Fast CCI average > slow CCI average AND fast CCI average on the preceding indicator-timeframe bar <= slow CCI average on that bar.
Short: Fast CCI average < slow CCI average AND fast CCI average on the preceding indicator-timeframe bar >= slow CCI average on that bar.
Exit: long, fast CCI average < slow CCI average OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, fast CCI average > slow CCI average OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.