Calculation: Cumulative delta volume = cumulative sum of volume × (2 × close − high − low) / (high − low), using zero when high equals low.
Calculation: AlphaTrend = on the last completed higher-timeframe bar, use max(low − ATR × multiplier, previous AlphaTrend) when MFI is at or above its midpoint; otherwise use min(high + ATR × multiplier, previous AlphaTrend). Initialize the previous AlphaTrend to zero when unavailable.
Long: Shorter-period EMA of cumulative delta volume > longer-period SMA of cumulative delta volume.
Short: Shorter-period EMA of cumulative delta volume <= longer-period SMA of cumulative delta volume.
Long: Close > AlphaTrend.
Short: Close <= AlphaTrend.