Long: the required number of directional signal sources confirm bullish direction AND Prism flow does not contradict the Livermore chart setup.
Short: the required number of directional signal sources confirm bearish direction AND Prism flow does not contradict the Livermore chart setup.
Long: an active setup allows long AND the bar is in the configured regular session and confirmed AND the cooldown since the last signal has elapsed AND (close crosses above the long trigger level OR close crosses above the confirmation level) AND each enabled filter passes; the VWAP filter requires close > VWAP(hlc3), the EMA filter requires close > EMA(close, shorter lookback) AND EMA(close, shorter lookback) >= EMA(close, longer lookback), and the relative-volume filter requires SMA(volume, lookback) > 0 AND volume / SMA(volume, lookback) >= minimum relative volume.
Short: an active setup allows short AND the bar is in the configured regular session and confirmed AND the cooldown since the last signal has elapsed AND (close crosses below the short trigger level OR close crosses below the confirmation level) AND each enabled filter passes; the VWAP filter requires close < VWAP(hlc3), the EMA filter requires close < EMA(close, shorter lookback) AND EMA(close, shorter lookback) <= EMA(close, longer lookback), and the relative-volume filter requires SMA(volume, lookback) > 0 AND volume / SMA(volume, lookback) >= minimum relative volume.
Long: an active long-only setup AND close >= the hard invalidation level AND close >= the invalidation level AND close >= the confirmation level.
Long: an active long-only setup AND close >= the hard invalidation level AND close >= the invalidation level AND close < the confirmation level AND close >= the long trigger level.
Short: an active short-only setup AND close <= the hard invalidation level AND close <= the invalidation level AND close <= the confirmation level.
Short: an active short-only setup AND close <= the hard invalidation level AND close <= the invalidation level AND close > the confirmation level AND close <= the short trigger level.
Long: an active two-way setup AND close >= the long trigger level.
Short: an active two-way setup AND close < the long trigger level AND close <= the short trigger level.
Exit: long, an active long-only setup AND close < the hard invalidation level.
Exit: long, an active long-only setup AND close >= the hard invalidation level AND close < the invalidation level.
Exit: short, an active short-only setup AND close > the hard invalidation level.
Exit: short, an active short-only setup AND close <= the hard invalidation level AND close > the invalidation level.
Exit: long, an active long-only setup AND the bar is in the configured regular session and confirmed AND (high crosses above target 1 OR high crosses above target 2 OR high crosses above target 3).
Exit: short, an active short-only setup AND the bar is in the configured regular session and confirmed AND (low crosses below target 1 OR low crosses below target 2 OR low crosses below target 3).
Exit: either side, an active two-way setup AND the bar is in the configured regular session and confirmed AND (high crosses above any target level OR low crosses below any target level).
Long: on a gap-up setup, the first post-open chart bar whose range intersects the gap zone.
Option: buy call, the long-entry condition is met.
Option: buy put, the short-entry condition is met.
Option: buy call, the first pullback after opening consolidation touches VWAP(hlc3) or EMA(close, pullback lookback) and closes above the touched value.
Option: buy call, close is above the entry level AND VWAP(hlc3) > VWAP(hlc3)[1].
Option: buy call, close crosses above the breakout level AND volume > volume[1].
Option: buy call, the first post-open chart bar whose range intersects the gap zone.
Option: buy call, price retests the support zone and closes above it.
Option: buy put, close crosses below the failure level.
Option: buy put, the small-cap index price crosses below its weakness level while the broad-market index price holds near its support level.
Option: buy put, the small-cap index price crosses below its deeper warning level AND the broad-market index price rolls over.