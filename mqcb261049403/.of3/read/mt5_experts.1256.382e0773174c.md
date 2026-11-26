Calculation: UltraFatl bullish score = score smoothing(count(i=0..increment count, price smoothing(applied price, base lookback + i × lookback increment, price-smoothing method, price phase)[0] > same series[1]), score lookback, score-smoothing method, score phase), calculated on T1 bars; [0] is still forming and [1] is last completed
Calculation: UltraFatl bearish score = score smoothing(count(i=0..increment count, price smoothing(applied price, base lookback + i × lookback increment, price-smoothing method, price phase)[0] <= same series[1]), score lookback, score-smoothing method, score phase), calculated on T1 bars; [0] is still forming and [1] is last completed
Long: UltraFatl bullish score > UltraFatl bearish score on a T1 bar
Short: UltraFatl bearish score > UltraFatl bullish score on a T1 bar
Long: UltraFatl bullish score[1] > UltraFatl bearish score[1] AND UltraFatl bearish score[0] > UltraFatl bullish score[0]
Short: UltraFatl bearish score[1] > UltraFatl bullish score[1] AND UltraFatl bullish score[0] > UltraFatl bearish score[0]
Exit: long, UltraFatl bearish score[1] > UltraFatl bullish score[1]
Exit: short, UltraFatl bullish score[1] > UltraFatl bearish score[1]