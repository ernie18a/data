Calculation: Range normalization = 100 × (value − lowest value over lookback) / (highest value over lookback − lowest value over lookback); use 50 when the range is zero.
Calculation: Oscillator values = RSI of close; stochastic %K; range-normalized CCI of close using twice its CCI lookback; MFI of typical price; Williams %R + 100; range-normalized ROC of close using twice its ROC lookback; Ultimate Oscillator with shorter, middle, and longer lookbacks; range-normalized MACD histogram of close using twice the slower MACD EMA lookback; 100 × DI+ / (DI+ + DI−), or 50 when the sum is zero; and Aroon balance.
Calculation: Aroon balance = (Aroon up − Aroon down + 100) / 2, where each Aroon component is 100 × (lookback − signed offset of the corresponding highest high or lowest low over lookback + 1 bars) / lookback; the current bar has offset 0 and earlier bars have negative offsets.
Calculation: Bull votes = count of oscillator values greater than or equal to the bullish threshold; bear votes = count of oscillator values less than or equal to the bearish threshold. The bullish threshold is higher than the bearish threshold.
Calculation: Bull regime = bull votes greater than or equal to the consensus threshold; bear regime = bull regime is false AND bear votes greater than or equal to the same consensus threshold.
Calculation: Agreement = 100 × max(bull votes, bear votes) / number of oscillators.
Long: Bull regime is true.
Short: Bear regime is true.
Long: Bull regime is true AND previous bar's bull regime is false.
Short: Bear regime is true AND previous bar's bear regime is false.
Long: Agreement is greater than or equal to the extreme threshold AND previous bar's agreement is below the extreme threshold AND bull votes are greater than or equal to bear votes.
Short: Agreement is greater than or equal to the extreme threshold AND previous bar's agreement is below the extreme threshold AND bear votes are greater than bull votes.
Exit: long, bear regime is true AND previous bar's bull regime is true.
Exit: short, bull regime is true AND previous bar's bear regime is true.