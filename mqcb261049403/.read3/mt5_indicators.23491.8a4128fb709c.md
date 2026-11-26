Calculation: NonLagMA direction = on each chart bar, set to long when NonLagMA(applied price, lookback) − NonLagMA(applied price, lookback)[1] > direction threshold; set to short when that change ≤ −direction threshold or when direction threshold > 0 and the change equals direction threshold; otherwise retain the prior direction
Calculation: Direction threshold = PctFilter × standard deviation over the lookback bars of each bar’s absolute one-bar NonLagMA change minus its trailing lookback-bar average
Long: NonLagMA direction = long
Short: NonLagMA direction = short