Risk-off / exit framework for a long equity-index position, driven only by external volatility data (VIX, VVIX, VIX3M daily closes), regardless of the traded symbol. The idea is that compressed volatility dispersion precedes volatility spikes. It never goes short on its own and only de-risks.

Inputs, evaluated on each daily bar: close of VIX, close of VVIX, close of VIX3M.

Derived measures:
1. VIX dispersion = population standard deviation (divide by N, not N-1) of the last N daily VIX closes around their simple mean. VVIX dispersion is computed the same way on VVIX closes.
2. VIX alert is true when VIX dispersion is at or below a low threshold, chosen near the 15th percentile of its history. VVIX alert is true when VVIX dispersion is at or below its own low threshold, with a separate, larger value.
3. Combined condition is true when both alerts are true on the same bar.
4. Keep a counter of bars since the combined condition was last true. It resets to 0 on any bar where the condition is true, and otherwise increments by 1 per bar. It starts large so the first signal is allowed.
5. Deduplicated combined signal fires only when the combined condition is true now and the previous bar's counter was at or above a minimum spacing. This suppresses repeats while the condition stays on or clusters.
6. Compound danger is a deduplicated combined signal where the current VIX close is also below a low absolute VIX level (a complacency level).
7. Term-structure spread = VIX3M close minus VIX close. Backwardation means the spread is negative. Extreme condition = the combined condition (not deduplicated) is true while backwardation holds.

Decision states, in order of severity:
- Risk on: neither alert is true. Keep or establish the normal long exposure.
- Caution: only the VIX alert is true. Tighten stops on the long position. It is a mild warning and does not force an exit.
- Warning: only the VVIX alert is true. Reduce long exposure.
- Tsunami alert: the deduplicated combined signal fires. Exit or sharply cut long exposure and raise cash.
- Compound danger: compound danger fires. This is the highest-risk state, so exit or hold the maximum cash level.
- Extreme: combined condition with backwardation. Treat it as the most severe warning and also exit or raise cash.

VVIX level above a high absolute level is stress context only, and a level above a medium level is a milder one. Neither triggers actions.

The signal is re-evaluated each day and holds while the conditions persist. Risk returns to normal once the alerts clear.