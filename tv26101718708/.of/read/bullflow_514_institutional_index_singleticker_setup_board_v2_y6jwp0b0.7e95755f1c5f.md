Calculation: Relative volume = current volume / simple moving average of volume, including the current bar.
Calculation: Signal cooldown = bars since the most recent regular-session, completed-bar trigger, confirmation, invalidation, hard invalidation, or target event; if none has occurred, the cooldown passes. Invalidation and target events reset the cooldown even when it has not passed.
Long: Completed bar in the configured regular session AND long or two-way setup AND close crosses above the configured long trigger OR confirmation level AND signal cooldown >= configured minimum AND (VWAP filter disabled OR close > session VWAP of typical price) AND (EMA filter disabled OR close > shorter EMA of close AND shorter EMA >= longer EMA of close) AND (relative-volume filter disabled OR relative volume >= configured minimum).
Short: Completed bar in the configured regular session AND short or two-way setup AND close crosses below the configured short trigger OR confirmation level AND signal cooldown >= configured minimum AND (VWAP filter disabled OR close < session VWAP of typical price) AND (EMA filter disabled OR close < shorter EMA of close AND shorter EMA <= longer EMA of close) AND (relative-volume filter disabled OR relative volume >= configured minimum).
Long: Long-only setup AND close >= configured confirmation level OR long trigger AND close >= invalidation level AND close >= hard invalidation level.
Short: Short-only setup AND close <= configured confirmation level OR short trigger AND close <= invalidation level AND close <= hard invalidation level.
Long: Two-way setup AND close >= configured long trigger.
Short: Two-way setup AND close < configured long trigger AND close <= configured short trigger.
Exit: long, long-only setup AND close < configured invalidation level OR hard invalidation level.
Exit: short, short-only setup AND close > configured invalidation level OR hard invalidation level.
Exit: long, completed bar in the configured regular session AND long-only setup AND high crosses above any configured target.
Exit: short, completed bar in the configured regular session AND short-only setup AND low crosses below any configured target.
Exit: long or short, completed bar in the configured regular session AND two-way setup AND (high crosses above any configured target OR low crosses below any configured target).