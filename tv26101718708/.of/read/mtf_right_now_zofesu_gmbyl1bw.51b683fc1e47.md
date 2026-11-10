Calculation: Higher-timeframe delta = volume × (2 × close − high − low) / (high − low), or 0 when high equals low; use the last completed higher-timeframe bar on historical chart bars and the still-forming higher-timeframe bar in real time.
Calculation: Higher-timeframe delta trend = Hull moving average of higher-timeframe delta; use the last completed higher-timeframe bar on historical chart bars and the still-forming higher-timeframe bar in real time.
Calculation: Higher-timeframe average close-location ratio = simple moving average of (close − low) / (high − low), using 0.5 when high equals low; use the last completed higher-timeframe bar on historical chart bars and the still-forming higher-timeframe bar in real time.
Long: Higher-timeframe delta > 0.
Short: Higher-timeframe delta <= 0.
Long: Higher-timeframe delta trend > its value on the preceding higher-timeframe bar.
Short: Higher-timeframe delta trend < its value on the preceding higher-timeframe bar.
Long: Higher-timeframe average close-location ratio > upper threshold.
Short: Higher-timeframe average close-location ratio < lower threshold.