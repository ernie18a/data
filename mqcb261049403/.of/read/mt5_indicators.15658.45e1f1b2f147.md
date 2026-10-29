Calculation: TSI = 100 × second-smoothed one-bar close change / second-smoothed absolute one-bar close change; apply the same first smoother and then the same second smoother to both the close changes and their absolute values. The regular indicator calculates on the chart timeframe; its higher-timeframe version calculates on a higher timeframe and uses the bar still forming.
Calculation: Trigger = TSI from the configured number of bars earlier on the calculation timeframe.
Long: TSI > Trigger
Short: TSI < Trigger