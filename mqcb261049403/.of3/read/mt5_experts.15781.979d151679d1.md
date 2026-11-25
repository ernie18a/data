Calculation: Stochastic = Stochastic(high, low, close, K lookback, D lookback, slowing, method, price field) on T1 bars at the selected signal-bar offset (forming at offset zero; completed at positive offsets)
Long: Stochastic crosses above the lower level on the selected T1 bar
Short: Stochastic crosses below the upper level on the selected T1 bar
Exit: long, neither Stochastic crosses above the lower level nor crosses below the upper level on the selected T1 bar AND Stochastic crossed below the upper level on an earlier T1 bar
Exit: short, neither Stochastic crosses above the lower level nor crosses below the upper level on the selected T1 bar AND Stochastic crossed above the lower level on an earlier T1 bar