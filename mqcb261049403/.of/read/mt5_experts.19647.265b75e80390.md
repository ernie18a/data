Calculation: Fast line = shorter-lookback smoothed selected price divided by medium-lookback smoothed selected price, on the configured indicator timeframe (higher or lower than the chart timeframe), using completed bars; negate if the indicator’s reverse option is enabled
Calculation: Slow line = longer-lookback smoothed selected price divided by the same medium-lookback smoothed selected price, on the configured indicator timeframe (higher or lower than the chart timeframe), using completed bars; negate if the indicator’s reverse option is enabled
Long: Previous completed bar fast line <= slow line AND latest completed bar fast line > slow line
Short: Previous completed bar fast line >= slow line AND latest completed bar fast line < slow line
Exit: Long, latest completed bar fast line < slow line
Exit: Short, latest completed bar fast line > slow line