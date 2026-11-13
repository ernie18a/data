Rotation framework between a base asset (XRP) and several alt-coins, all quoted in the same fiat on the same exchange and timeframe. It uses only data from instruments other than the one being held. For each alt, compute a relative-strength ratio: alt close divided by base close, on every bar (undefined if the base price is not positive). Compute the relative-strength change as the percentage change of that ratio from the previous bar, treating missing values as zero. Evaluate on the latest bar only. Each alt has its own rule and its own tuned threshold, and the thresholds differ by asset.

Exit rules (rotate out of the alt and back into the base asset, locking in more base units):
- For the first alt (RWA token), the second major alt (SOL) and the AI token (FET), signal exit/take-profit when the ratio change rises above that asset's positive threshold, meaning the alt has outperformed the base in one bar. Otherwise hold. The first alt and SOL are labelled 'rotate to base' and FET 'take profit'. FET's threshold is the highest and SOL's the lowest.

Entry rules (rotate from the base asset into the alt, a long on the alt versus the base):
- For the L1 alt (SUI), signal buy when the ratio change falls below a negative threshold, meaning the alt has underperformed the base in one bar. Otherwise wait.
- For the payments alt (HBAR), signal buy-bounce when the ratio change falls below a deeper negative threshold. Otherwise hold.
- For the LUNA-type alt, flag an extreme dip when the ratio change falls below an even deeper negative threshold. Otherwise steady. This is an informational dip flag with no stated trade.

NEAR and ETH have no conditional trade rule; they show only a static label.

A 'magnet' status exists for each alt except LUNA. It is a manually entered liquidation-cluster price level per alt, where zero or unset means no data. If the level is above the alt's current price, the status is short squeeze (upward pull). If it is at or below the price, the status is long flush (downward risk). This status is only displayed and does not gate or change any of the buy or exit signals above, although the description says it should confirm them. Entries are meant to be partial slices of the base holding, and exits swap back to the base.