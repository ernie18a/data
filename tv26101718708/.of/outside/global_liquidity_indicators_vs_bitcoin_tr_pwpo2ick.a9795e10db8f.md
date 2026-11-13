Trade the Bitcoin spot index (long or short) using a relative-momentum vote between Bitcoin and a synthetic global-liquidity series, evaluated on every bar at the chart timeframe using closing values.

Inputs:
1. Bitcoin: the Bitcoin/USD index close.
2. Liquidity: a synthetic series built as (China 10-year yield / US dollar index / US high-yield credit spread) multiplied by the sum of four central-bank balance-sheet terms converted to USD: US central bank balance sheet, plus Japan central bank assets divided by USDJPY, plus China central bank balance sheet divided by USDCNY, plus ECB assets divided by USDEUR.

Momentum measures: compute up to five oscillators (rate of change, CCI, RSI, money flow index, Chande momentum oscillator) on each of the two series. Each series has its own lookback length; the liquidity lookback is shorter than Bitcoin's by default. A user can enable any subset of the five. By default only rate of change is enabled.

Lag: shift every oscillator value back in time by a per-series number of bars. Bitcoin's lag is zero by default. Liquidity's lag is large, about 100 bars, so that old liquidity momentum is compared with current Bitcoin momentum.

Voting: for each enabled oscillator, compare the lagged Bitcoin value with the lagged Liquidity value. If Bitcoin is strictly greater, the vote is +1. Otherwise (smaller or equal) the vote is -1. Disabled oscillators do not vote. Sum the votes, divide by the number of enabled oscillators, and multiply by 100 to get a consensus score from -100 to +100. If no oscillator is enabled, the score is 0.

Decision:
- Score > 0 (a majority favors Bitcoin momentum over liquidity momentum): be long Bitcoin.
- Score < 0 (a majority favors liquidity momentum): be short Bitcoin.
- Score = 0 (votes tie, or nothing is enabled): neutral, so exit or stay flat.

The position is state-based and follows the sign of the score on each bar. Flip from long to short, or the reverse, when the sign changes. Exit to flat when the score is exactly zero. There are no separate stops or targets.