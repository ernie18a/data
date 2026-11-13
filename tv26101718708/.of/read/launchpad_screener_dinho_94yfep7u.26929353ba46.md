Calculation: fast/mid/slow SMA = simple moving averages of close with fast < mid < slow lengths
Calculation: ma_max, ma_min, ma_avg = max, min and mean of the fast, mid and slow SMA
Calculation: ma_range_pct = (ma_max - ma_min) / close * 100
Calculation: price_vs_ma = abs(close - ma_avg) / close * 100
Calculation: flat(X, n) = stdev(X, n) / SMA(X, n) * 100; avg_flat = mean of flat(fast SMA, w) and flat(mid SMA, w); flat_slow = flat(slow SMA, w2) with w2 > w
Calculation: vol_ma = SMA(volume, n); vol_ratio = volume / vol_ma
Calculation: atr_roc = (ATR - ATR k bars ago) / ATR k bars ago * 100
Calculation: score = max(0, 30*(1 - ma_range_pct/Tc)) + max(0, 10*(1 - price_vs_ma/Tp)) + max(0, 10*(1 - avg_flat/Ts)) + max(0, 10*(1 - flat_slow/Tf)) + (volume < vol_ma ? 25 : max(0, 25*(1 - (vol_ratio - 1)/0.5))) + (atr_roc < 0 ? 15 : max(0, 15*(1 + atr_roc/20))), where Tc, Tp, Ts, Tf are thresholds
Calculation: setup = (count of true among [ma_range_pct < Tc, price_vs_ma < Tp, avg_flat < Ts, flat_slow < Tf, volume < vol_ma, atr_roc < 0]) >= 4 AND score >= min_score
Calculation: setup_days = consecutive count of bars (including current) where setup is true, 0 when setup is false
Long: setup_days on previous bar >= min_days AND close > ma_max of previous bar AND volume >= vol_ma of previous bar * activation_multiple