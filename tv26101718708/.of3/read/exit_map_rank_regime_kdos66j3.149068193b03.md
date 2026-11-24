Calculation: Return(x, n) = log(x / x[n])
Calculation: Excluded = highest(abs(universe close / universe close[1] - 1) * 100, gate window) > gate threshold
Calculation: Members = 1 + count of universe members other than the traded instrument that are not Excluded and have defined Return(universe close, rank lookback)
Calculation: Universe count = count of universe members that are not Excluded and have defined Return(universe close, rank lookback)
Calculation: Rank = 1 + count of universe members other than the traded instrument that are not Excluded and have Return(universe close, rank lookback) > Return(close, rank lookback)
Calculation: Zone size = max(1, ceil(Members * zone percent / 100))
Calculation: IC = Spearman(Return(universe close[forward horizon], rank lookback), Return(universe close, forward horizon)) over universe members that are not Excluded and have both values defined, on bars whose index is a multiple of sampling step, if at least min members per IC such members exist; otherwise empty
Calculation: IC mean = mean of non-empty IC values so far
Calculation: IC count = count of non-empty IC values so far
Calculation: t-stat = IC mean / (population standard deviation of non-empty IC values so far / sqrt(IC count)) / sqrt(max(1, forward horizon / sampling step))
Long: IC mean >= min |IC| AND t-stat >= min |t| AND IC count >= min IC samples AND Universe count >= min universe size AND Rank <= Zone size
Long: IC mean <= -min |IC| AND t-stat <= -min |t| AND IC count >= min IC samples AND Universe count >= min universe size AND Rank > Members - Zone size
Short: IC mean >= min |IC| AND t-stat >= min |t| AND IC count >= min IC samples AND Universe count >= min universe size AND Rank > Members - Zone size
Short: IC mean <= -min |IC| AND t-stat <= -min |t| AND IC count >= min IC samples AND Universe count >= min universe size AND Rank <= Zone size