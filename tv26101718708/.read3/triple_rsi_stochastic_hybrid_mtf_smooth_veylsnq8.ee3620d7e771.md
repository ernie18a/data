Calculation: Osc_i(price) = RSI weight_i * RSI(price, RSI length_i) + (1 - RSI weight_i) * Stochastic %K(price, stochastic length_i, %K smoothing_i), with the raw stochastic set to 50 when highest high equals lowest low
Calculation: Sig_i(x) = EMA(MA(x, signal length_i, MA method_i), signal smoothing_i)
Calculation: MOsc_i(T) = MA(series, smoothing length_i, smoothing method_i) computed on chart bars, where series = Osc_i(price) computed on bars of T, taking the value of the last completed T bar on each chart bar
Long: Osc_1(price) crosses above Sig_1(Osc_1(price))
Short: Osc_1(price) crosses below Sig_1(Osc_1(price))
Long: MOsc_2(T1) crosses above Sig_2(MOsc_2(T1))
Short: MOsc_2(T1) crosses below Sig_2(MOsc_2(T1))
Long: MOsc_3(T2) crosses above Sig_3(MOsc_3(T2))
Short: MOsc_3(T2) crosses below Sig_3(MOsc_3(T2))
Long: Osc_1(price) crosses above Sig_1(Osc_1(price)) AND MOsc_2(shorter T1) > Sig_2(MOsc_2(shorter T1)) AND MOsc_3(longer T2) > Sig_3(MOsc_3(longer T2))
Short: Osc_1(price) crosses below Sig_1(Osc_1(price)) AND MOsc_2(shorter T1) < Sig_2(MOsc_2(shorter T1)) AND MOsc_3(longer T2) < Sig_3(MOsc_3(longer T2))