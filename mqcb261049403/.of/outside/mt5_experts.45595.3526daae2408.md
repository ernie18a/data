Multi-currency strength strategy that trades one forex pair using signals computed from a basket of other forex pairs.

STRENGTH MEASURE (from the basket, not from the traded pair alone)
1. Take a basket of N forex pairs that share one common currency. Per pair, use a smoothed price series (a moving average of an applied price; with period 1 and close price this is just the close).
2. Orient each pair relative to the common currency. If the common currency is the pair's quote/profit currency, use the price as is. If it is the base currency, use 1/price.
3. For each pair j, compute v_j = latest oriented value / previous oriented value, which is the one-bar change ratio. If a pair lacks the needed bars, reuse its nearest earlier value so v_j = 1. If data is missing entirely, skip the calculation and retry later.
4. Let S = 1 + sum of all v_j. The common currency strength is (N+1)/S. Each other currency's strength is v_j*(N+1)/S, attributed to that pair's non-common currency. The strengths sum to N+1, so the average is 1.0.

SIGNAL FOR THE TRADED PAIR (base currency B, quote currency Q)
- Evaluate only when all basket symbols' latest bars are time-synchronised, and only once per new time stamp (new bar). In bar mode, read the most recently completed bar; in tick mode, read the current one. On any other tick the signal is 0.
- Find the currency with the highest strength and the one with the lowest.
- If B is the strongest and Q is the weakest, the signal is +1.
- If Q is the strongest and B is the weakest, the signal is -1.
- Otherwise the signal is 0.
- Strategy mode BREAKOUT uses the signal as is. Mode PULLBACK negates it (+1 becomes -1 and vice versa).

TRADING RULES (one position at a time per traded pair)
- Optional trading-hours window (wrap-around supported). Outside the window, close any open position, do not enter, and do nothing else.
- No position and no previous trade: signal +1 opens a long, signal -1 opens a short, signal 0 does nothing.
- Position open and still alive:
  - Long with signal -1, or short with signal +1: close it (opposite-signal exit).
  - Otherwise hold. Fixed stop-loss and take-profit in points, set at entry, and an optional trailing stop that only moves the stop in the profitable direction, handle the other exits.
- Position just closed (by stop, take-profit, trailing stop or opposite signal), using the closed position's result and direction:
  - Current signal is 0 (martingale continuation):
    - If the previous trade's profit was >= 0, re-enter in the same direction with the base lot.
    - If it was a loss, re-enter in the opposite direction with a larger lot (previous lot times a factor, capped at a maximum; if the cap is exceeded, reset to the base lot).
  - Current signal is non-zero: enter in the signal's direction (+1 long, -1 short), with the base lot after a profit or the enlarged lot after a loss, using the same cap and reset rule.
- If there is not enough free margin for the enlarged lot, fall back to the base lot; if even that fails, skip entry. After a failed order, pause trading for a short timeout.