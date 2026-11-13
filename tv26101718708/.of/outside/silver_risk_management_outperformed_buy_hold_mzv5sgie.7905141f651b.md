Long-only, single-instrument (silver) daily strategy, fully invested when long. All conditions are evaluated on a bar's close, and orders fill at that close. External series are aligned to the same timeframe with no look-ahead. The default state is long. The strategy steps aside when risk builds and re-enters when conditions calm.

Inputs:
- Silver's own OHLC.
- A slow EMA of silver's close.
- A shorter recovery EMA of silver's close.
- An ATR of silver.
- External US10Y yield OHLC (primary macro filter, enabled).
- Optionally, external DXY OHLC (same logic as US10Y, disabled by default).

Definitions:
1. Silver trend weak: silver's close is below its slow EMA, optionally reduced by a small buffer percentage.
2. External stress, per enabled external series. It is true on a bar only when all three hold:
   - The external close is above its own EMA.
   - The percentage distance of the close above that EMA exceeds a threshold.
   - The external close is above the highest high of its previous N bars, excluding the current bar.
   Macro stress now is true if any enabled external series is stressed.
3. Macro stress persistent: macro stress now is true on each of the last M consecutive bars, including the current bar.
4. External calm, per enabled external series: the external close is at or below its EMA, or its percentage above the EMA is at or below the threshold. Macro calm now is true when all enabled series are calm. Macro calm persistent means macro calm now has held for the last K consecutive bars, including the current bar.
5. Flush shock now is true if any of these hold:
   - Silver's one-bar close-to-close percentage change is at or below the negative one-day flush threshold.
   - Silver's two-bar close-to-close percentage change is at or below the negative two-day flush threshold.
   - ATR shock: the bar range (high-low) as a percentage of close exceeds the ATR as a percentage of close times a multiplier, and the bar is bearish (close below open).
6. Flush recently: the number of bars since the last flush shock, with the current bar counting as 0, is at or below a cooldown length.
7. Volatility calm now: the bar range percentage is at or below ATR percentage times the same multiplier. Volatility calm persistent means this has held for the last J consecutive bars.
8. Flush recovery ready: true if there was no flush recently. Otherwise it requires silver's close above the recovery EMA and volatility calm persistent.

Exit rule: while long, close the position when any of these is true:
- Silver trend weak.
- Macro stress persistent.
- Flush shock now.

Entry rule: go long when all of these hold:
- Currently flat.
- Silver trend is not weak.
- Macro calm persistent.
- Flush recovery ready.
Exit takes precedence on a bar where an exit condition fires.

There is no short side. There is only one position, with no pyramiding, and sizing is 100% of equity. Trading is only allowed from a configured start date.