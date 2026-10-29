Calculation: VIX change % = 100 × (current chart-timeframe VIX close − previous completed daily VIX close) / previous completed daily VIX close; use the last completed bar of the higher daily timeframe.
Calculation: VIX ROC % = percentage change in VIX close over a shorter lookback on the chart timeframe.
Long: (VIX change % ≥ spike threshold OR VIX ROC % ≥ fast-spike threshold) AND current chart-timeframe VIX close ≥ minimum floor AND (vol-curve filter disabled OR current chart-timeframe VIX9D close > current chart-timeframe VIX close) AND flat AND cooldown elapsed AND within enabled entry-time filters.
Short: VIX change % ≤ negative crush threshold AND NOT (VIX change % ≥ spike threshold OR VIX ROC % ≥ fast-spike threshold) AND flat AND cooldown elapsed AND within enabled entry-time filters.
Exit: long, entry price × (1 − stop percentage) ≥ bar low.
Exit: long, entry price × (1 + target percentage) ≤ bar high.
Exit: short, entry price × (1 + stop percentage) ≤ bar high.
Exit: short, entry price × (1 − target percentage) ≥ bar low.
Exit: long, VIX change % ≤ full-reversion threshold.
Exit: long, VIX change % ≤ first scale-out threshold AND no prior scale-out in this trade AND position size is at least two units; close floor(position size / 2).
Exit: long, bars since entry ≥ maximum holding period.
Exit: short, bars since entry ≥ maximum holding period OR VIX change % ≥ spike threshold OR VIX ROC % ≥ fast-spike threshold.