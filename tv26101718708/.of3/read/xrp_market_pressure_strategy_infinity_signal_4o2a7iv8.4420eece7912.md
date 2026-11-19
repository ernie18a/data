Calculation: Buy score = count of true enabled components: RSI(close, RSI lookback, T1 current bar sampled on chart bars) <= buy RSI threshold; Stochastic RSI(close, RSI lookback, stochastic lookback, smoothing lookback, T1 current bar sampled on chart bars) <= buy Stochastic RSI threshold; MFI(hlc3, MFI lookback, T1 current bar sampled on chart bars) <= buy MFI threshold; manual sentiment is at the extreme-fear setting
Calculation: Sell score = count of true enabled components: RSI(close, RSI lookback, T1 current bar sampled on chart bars) >= sell RSI threshold; Stochastic RSI(close, RSI lookback, stochastic lookback, smoothing lookback, T1 current bar sampled on chart bars) >= sell Stochastic RSI threshold; MFI(hlc3, MFI lookback, T1 current bar sampled on chart bars) >= sell MFI threshold; manual sentiment is at the extreme-greed setting
Calculation: Required score = strict mode ? number of enabled components : max(number of enabled components - 1, minimum score)
Calculation: Accumulation zone = Buy score >= minimum zone score AND Buy score > Sell score
Calculation: Risk-reduction zone = Sell score >= minimum zone score AND Sell score > Buy score
Long: Buy score >= Required score
Long: Accumulation zone
Long: Accumulation zone AND NOT Accumulation zone[1]
Exit: long, Sell score >= Required score
Exit: long, Risk-reduction zone
Exit: long, Risk-reduction zone AND NOT Risk-reduction zone[1]