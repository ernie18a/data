Smart-money-technique (SMT) divergence between the traded instrument and a correlated comparison instrument (gold is traded, silver is the comparison). The logic is evaluated on every bar of the chart timeframe, which is intended to be intraday.

Inputs per bar:
- For each instrument, the high and low of the previous completed 1-hour bar. This is the reference level and stays fixed within the current hour.
- For each instrument, the highest high and lowest low over a short recent window of chart bars, including the current bar.

Definitions:
- Traded instrument high-break: its recent-window highest high is strictly above its own previous-hour high.
- Comparison instrument high-break: its recent-window highest high is strictly above its own previous-hour high.
- Traded instrument low-break: its recent-window lowest low is strictly below its own previous-hour low.
- Comparison instrument low-break: its recent-window lowest low is strictly below its own previous-hour low.

Signals:
- Bearish (short) signal: the traded instrument has a high-break and the comparison instrument does not have a high-break. The traded instrument swept the prior-hour high without confirmation from the comparison instrument, so expect a reversal down.
- Bullish (long) signal: the traded instrument has a low-break and the comparison instrument does not have a low-break. The traded instrument swept the prior-hour low without confirmation from the comparison instrument, so expect a reversal up.

The two signals are independent. Both can be active on the same bar, and each is re-evaluated every bar, so a signal can persist across consecutive bars while the condition holds.

There is no explicit exit rule, stop or target. Exits are left to the implementer, for example closing when the opposite signal appears. The other levels shown (previous day, week and 4-hour highs and lows) are display only and take no part in the decisions.