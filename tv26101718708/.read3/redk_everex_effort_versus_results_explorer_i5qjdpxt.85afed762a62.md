Calculation: Step(x, a) = lvl_i for the smallest i with x / a > thr_i, else lvl_8, with thr_1 > ... > thr_7 and lvl_1 ... lvl_8 as parameters
Calculation: Scaled(x) = Step(|x|, MA(|x|, norm_len, norm_ma)) * 100 * sign(x)
Calculation: VolScore = 100 * Step(volume, MA(volume, norm_len, norm_ma))
Calculation: PriceScore = (2 * (close - low) / (high - low) * 100 - 100 + (close - open) / (high - low) * 100 + Scaled(close - open) + 2 * (close - lowest(low, 2)) / (highest(high, 2) - lowest(low, 2)) * 100 - 100 + (close - close[1]) / (highest(high, 2) - lowest(low, 2)) * 100 + Scaled(close - close[1])) / 6
Calculation: Score = PriceScore * VolScore / 100
Calculation: Osc(f, n, t) = 100 * (B - S) / (B + S), with B = MA(max(f, 0), n, t) and S = MA(max(-f, 0), n, t)
Calculation: Line = WMA(Osc(Score, flow_len, flow_ma), flow_smooth)
Calculation: BiasLine = WMA(Osc(Score, bias_len, bias_ma), flow_smooth)
Calculation: Rel = 100 * |PriceScore| / VolScore
Long: Line crosses above 0
Short: Line crosses below 0
Long: Line >= 0
Short: Line < 0
Long: BiasLine >= 0
Short: BiasLine < 0
Long: Score > 0
Short: Score <= 0
Long: Rel >= ease_thr AND (PriceScore < mega_thr OR VolScore < mega_thr) AND PriceScore > 0
Short: Rel >= ease_thr AND (PriceScore > -mega_thr OR VolScore < mega_thr) AND PriceScore <= 0
Long: PriceScore >= mega_thr AND VolScore >= mega_thr
Short: PriceScore <= -mega_thr AND VolScore >= mega_thr
Long: Rel <= comp_thr AND PriceScore > 0
Short: Rel <= comp_thr AND PriceScore <= 0