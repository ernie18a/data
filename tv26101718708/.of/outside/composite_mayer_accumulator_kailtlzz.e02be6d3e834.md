Evaluate once per daily bar, on the close. Inputs come from outside the chart instrument: a reference equity index (default QQQ) and a volatility index (VIX). The signals apply to the traded instrument. From the index, compute: (a) a z-score, meaning (close - long SMA) / rolling stdev over the same long window; (b) a Mayer multiple, meaning close / long SMA; (c) a short-period RSI; (d) a fast EMA (about 10 periods).

LONG (buy) signals fire on any of three tiers:
1. Mild capitulation: either (RSI oversold AND z-score at or below a clearly negative level), or (RSI mildly oversold AND z-score somewhat less negative AND VIX at a high panic level).
2. Severe capitulation: either (z-score extremely negative AND VIX at a high panic level), or (z-score clearly negative AND VIX at an extreme level, higher than the panic level).
3. Mayer deep value: Mayer multiple at or below a deep-value threshold below 1. The threshold is relaxed by a small amount when VIX is at the panic level.

EXIT / SHORT (top) signals all require a rollover trigger: the index close crosses under its fast EMA on the current bar. The tiers are:
1. Mild euphoria: the trigger fires, and within the last few bars (including the current one) RSI was overbought AND z-score was strongly positive.
2. Severe euphoria: the trigger fires on the same bar that z-score is very high AND VIX is at a complacent low level.
3. Mayer top: the trigger fires, and within the last few bars the Mayer multiple was at or above a euphoria threshold above 1.

Deduplication: each of the six signals has its own lockout. A signal is suppressed if the same signal fired within the last few bars (about 5). Different tiers do not block each other. A buy tier means go or add long, or cover a short. A top tier means exit the long or go short.