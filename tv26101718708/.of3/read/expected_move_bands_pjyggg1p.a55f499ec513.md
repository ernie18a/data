Calculation: Daily RV(series) = STDEV(log(series close / prior close), RV lookback parameter, T2 bars including the current T2 bar) × sqrt(RV annualization) × 100
Calculation: RV annualization = annualization-factor input when overridden, otherwise the asset-class annualization parameter
Calculation: Primary IV = EMA(selected direct IV series close from T2, IV-smoothing parameter) evaluated on chart bars using T2 values, including the current T2 bar
Calculation: Derived IV = EMA(reference IV series close from T2, IV-smoothing parameter) evaluated on chart bars using T2 values, including the current T2 bar, × min(Daily RV(current underlying) / Daily RV(reference underlying), ratio-cap parameter)
Calculation: Selected IV = Primary IV when available, otherwise Derived IV when derivation is enabled and its inputs are available, otherwise unavailable
Calculation: Horizon days = explicit horizon-days input when positive, otherwise the week, month, day, or fallback horizon-days parameter selected by T1
Calculation: Anchor move = first chart-bar open of each T1 period × Selected IV on that bar / 100 × sqrt(Horizon days / calendar-days-per-year parameter), retained until the next T1 period
Calculation: Upper band(sigma multiple) = anchor open + sigma multiple × anchor move
Calculation: Lower band(sigma multiple) = anchor open − sigma multiple × anchor move
Long: crosses above(chart close, Upper band(first sigma-multiple parameter)) OR crosses above(chart close, Upper band(tail sigma-multiple parameter))
Short: crosses below(chart close, Lower band(first sigma-multiple parameter)) OR crosses below(chart close, Lower band(tail sigma-multiple parameter))