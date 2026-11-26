Calculation: Shared anchor(asset) = selected common anchor level; a T1 period open uses the still-forming T1 bar's open mapped to chart bars, prior close uses the previous completed T1 bar's close mapped to chart bars, and date or swing anchors use the selected chart bar's close
Calculation: Anchored percent change(asset) = 100 * (asset close / asset shared anchor - 1)
Calculation: OLS beta(asset, benchmark) = OLS slope of asset and benchmark one-bar returns (close / close[1] - 1) over L prior completed chart bars
Calculation: Anchored beta residual(asset, benchmark) = Anchored percent change(asset) - OLS beta(asset, benchmark) * Anchored percent change(benchmark)
Calculation: Anchored residual z-score(asset, benchmark) = Anchored beta residual(asset, benchmark) / (StDev(100 * (asset one-bar return - OLS beta(asset, benchmark) * benchmark one-bar return), L chart bars including the scored bar) * sqrt(max(bars since shared anchor, 1)))
Long: Anchored residual z-score(Nasdaq index, S&P 500 index) > divergence threshold
Short: Anchored residual z-score(Nasdaq index, S&P 500 index) < -divergence threshold
Long: Anchored residual z-score(traded instrument, Nasdaq index) > divergence threshold
Short: Anchored residual z-score(traded instrument, Nasdaq index) < -divergence threshold
Long: Anchored residual z-score(traded instrument, Nasdaq index) > divergence threshold AND traded instrument's anchored percent change is at its highest value since the shared anchor AND Nasdaq index's anchored percent change is below its highest value since the shared anchor
Long: Beta adjustment is disabled AND Nasdaq index anchored percent change >= S&P 500 index anchored percent change OR beta adjustment is enabled AND Anchored beta residual(Nasdaq index, S&P 500 index) >= 0