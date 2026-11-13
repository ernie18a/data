Trade the chart instrument (gold) using DXY, the US Dollar Index, as an external, inversely correlated driver. Use DXY on the same timeframe as the chart. Each bar, compute three gold-bias components from DXY and gold prices, add them into bull and bear scores, and turn the scores into a long, short or flat bias.

1. DXY trend. DXY close above its EMA is DXY-bull, which counts toward gold bear. DXY close below its EMA is DXY-bear, which counts toward gold bull.

2. Pivot divergence. A pivot is a swing high or low confirmed by an equal number of lower highs or higher lows on each side. Keep the last two swing highs and last two swing lows of DXY and of gold, each with a timestamp.
- Bullish-gold divergence fires on a bar when all of these hold:
  - A new DXY swing high or a new gold swing low was just confirmed.
  - The latest DXY swing high is above the previous DXY swing high (higher high).
  - The latest gold swing low is above the previous gold swing low (higher low).
  - The timestamps of the latest DXY swing high and latest gold swing low are within a maximum time separation.
  - DXY is in the bull trend state.
  - Push filter: DXY close is above the highest DXY high of the prior N bars, excluding the current bar. This filter is on in the balanced and conservative profiles and off in the responsive one.
  - More than a minimum number of bars have passed since the previous bullish divergence event (cooldown).
- Bearish-gold divergence is the mirror image:
  - A new DXY swing low or a new gold swing high was just confirmed.
  - The DXY lower low and the gold lower high both hold.
  - The two timestamps are aligned.
  - DXY is in the bear trend state.
  - Push filter: DXY close is below the lowest DXY low of the prior N bars.
  - The cooldown has passed.
- After an event, the divergence stays active for a fixed number of bars.

3. DXY lead. DXY moves first while gold has not yet followed.
- DXY bar range must exceed a fraction or multiple of its smoothed average range (impulse).
- Bull lead: the impulse holds, DXY close breaks below the lowest DXY low of the prior L bars, and gold close is still above the lowest gold low of the prior L bars.
- Bear lead: the impulse holds, DXY close breaks above the highest DXY high of the prior L bars, and gold close is still below the highest gold high of the prior L bars.
- If both leads are true at once, treat the lead as none.

4. Scoring. Bull score is the count of true items among DXY-bear trend, bullish divergence active, and bull lead. Bear score is the count among DXY-bull trend, bearish divergence active, and bear lead.

5. Decision, checked in this order:
- Strong long: bull score is at least 2 and bear score is 0.
- Long: bull score is greater than bear score.
- Strong short: bear score is at least 2 and bull score is 0.
- Short: bear score is greater than bull score.
- Otherwise the bias is mixed, so stay flat or do not trade.

Hold long while the bias is long or strong long, and hold short while the bias is short or strong short. Exit when the bias returns to mixed or flips to the opposite side.