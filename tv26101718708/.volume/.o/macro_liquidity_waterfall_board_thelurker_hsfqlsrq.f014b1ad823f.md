Calculation: Global liquidity = Fed balance sheet − reverse repo − Treasury General Account (+ optional M2), using the last completed selected-timeframe bar.
Calculation: Global-liquidity change = percentage change from the last completed selected-timeframe bar to the completed bar `lookback` selected-timeframe bars earlier.
Calculation: Crypto change = percentage change in total crypto market capitalization over the same selected-timeframe bars as global-liquidity change.
Calculation: Regime = neutral if either change’s absolute value is below the deadband; otherwise expansion if both changes are positive, lagging if global-liquidity change is positive and crypto change is negative, unsupported if global-liquidity change is negative and crypto change is positive, or contraction if both changes are negative.
Long: Regime = expansion AND regime differs from the previous bar’s regime.
Short: Regime = contraction AND regime differs from the previous bar’s regime.