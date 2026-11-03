Calculation: Stablecoin market-cap ROC = percentage change in combined stablecoin market capitalization over a lookback.
Calculation: USDC ROC = percentage change in USDC market capitalization over a lookback.
Calculation: USDT ROC = percentage change in USDT market capitalization over a lookback.
Calculation: Stablecoin lower low = current market capitalization < the lowest market capitalization in the prior lookback bars AND its ROC < 0.
Calculation: BTC below long-term moving average = BTC close < its long-term moving average, calculated from the last completed bars of a higher timeframe.
Short: Stablecoin market-cap ROC < growth-slowing threshold AND Stablecoin market-cap ROC >= contraction threshold AND Stablecoin lower low is false
Short: Stablecoin market-cap ROC < contraction threshold AND Stablecoin lower low is false
Short: Stablecoin lower low
Short: USDC lower low AND NOT USDT lower low
Short: USDC ROC < contraction threshold
Short: Stablecoin lower low AND BTC below long-term moving average