Instrument: BTC, daily timeframe. Decisions use external on-chain data (realized cap and circulating supply), not BTC's own price history alone.

Inputs: daily realized cap and circulating supply from on-chain feeds, each with a fallback feed. If supply is unavailable, derive it as market cap divided by price. Also use the BTC daily close.

Derived values:
- Realized price = realized cap / supply.
- MVRV = BTC close / realized price. Alternatively, MVRV = market cap / realized cap.
- Treat MVRV as valid only if realized price and MVRV are both positive and non-missing. Otherwise emit no signals. Cross detection also requires a valid MVRV on the previous bar.
- If the realized cap feed has not changed for more than several days, flag the data as stale and treat signals as unreliable.

Thresholds (user-adjustable, strictly ascending): deep-buy < buy (cost-basis parity, where price equals realized price) < sell < euphoria. Between buy and sell is fair value, with no action.

Signals, evaluated on each daily close by comparing the current MVRV to the previous bar's MVRV:
1. LONG entry (accumulate): MVRV crosses downward through the buy threshold. The previous MVRV was at or above it and the current is below it.
2. STRONG LONG / deep value (add to the long): MVRV crosses downward through the deep-buy threshold, by the same rule.
3. LONG confirmation (bottom confirmed): MVRV crosses upward through the buy threshold. The previous MVRV was at or below it and the current is above it, meaning price reclaims the cost basis. This confirms or maintains the long.
4. EXIT long / SHORT bias (distribution): MVRV crosses upward through the sell threshold. The previous MVRV was at or below it and the current is above it.
5. STRONG EXIT / top risk (full exit or strongest short bias): MVRV crosses upward through the euphoria threshold, by the same rule.

No signal fires while MVRV stays inside a zone without crossing a threshold. Signals are event-based on crossings only. No stop-loss, take-profit, or sizing rules exist. The logic is a slow, structural, multi-week-to-month valuation read.