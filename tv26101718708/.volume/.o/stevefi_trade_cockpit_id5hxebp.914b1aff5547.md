Calculation: Price confirmed = the latest confirmed pivot low is higher than the preceding confirmed pivot low AND close > fast EMA AND close > open AND close > prior bar high
Calculation: MR stretched = close is more than the configured extended ATR limit above the fast EMA
Calculation: Invalidated = close < the low of the detected impulse
Calculation: AGG = weighted aggregate score of CANSLIM, relative strength, price, trend, pivot, 52-week-high distance, EWave, volume, mean reversion, accumulation, stochastic, invalidation, and target
Long: AGG >= configured buy-trigger threshold AND Price confirmed AND NOT Invalidated AND NOT MR stretched AND (CANSLIM filter disabled OR CANSLIM score >= its configured minimum AND 52-week-high distance >= its configured minimum AND (relative strength is strong OR relative-strength line is at a new high))
Long: AGG >= configured buy-watch threshold AND AGG < configured buy-trigger threshold AND NOT Invalidated
Exit: Long, Invalidated OR (AGG >= configured caution threshold AND (stochastic rolled over OR MR stretched))