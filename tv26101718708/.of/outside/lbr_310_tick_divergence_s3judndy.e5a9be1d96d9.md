Signal-only countertrend divergence framework. It outputs a long signal or a short signal on the traded instrument, gated by an external breadth series: the NYSE TICK index, sampled on the chart's own timeframe with no lookahead. It defines no exit rule.

Inputs per bar:
- Momentum oscillator = simple moving average of close over a short length minus simple moving average of close over a longer length, both on the traded instrument.
- External TICK series. Use its bar low for long checks and its bar high for short checks.
- Swing lows and swing highs of the traded instrument. A swing low is a bar whose low is the lowest over a larger window of bars on its left and a small window on its right. A swing high is the mirror. The small right window means a pivot is confirmed only a few bars after it forms. Evaluate the signal at confirmation time and attribute it to the pivot bar. Read oscillator and TICK values at the pivot bar, not at the confirmation bar.

State: keep the most recent previous swing low with its price, oscillator value, TICK low and bar index. Keep the same for the most recent previous swing high with its TICK high. Each time a new swing of a type is confirmed, compare it to the stored previous one of that type. Then always replace the stored one with the new swing, whether or not a signal fired.

Long signal, evaluated when a new swing low is confirmed. All of the following must hold versus the previous swing low:
1. The bar distance between the two swing lows is at least a minimum and at most a maximum.
2. Price: the new swing low is lower than the previous one.
3. Oscillator: its value at the new pivot is higher than at the previous pivot.
4. Optional zero-side filter, on by default: the oscillator is below zero at both pivots.
5. TICK confirmation, toggleable: the TICK low at the new pivot is higher than at the previous pivot, and both values exist. If the toggle is off, skip this condition and treat the signal as a pure price plus oscillator divergence.

Short signal, the exact mirror, evaluated when a new swing high is confirmed:
1. The spacing between the two swing highs is within the same min/max window.
2. The new swing high is higher than the previous one.
3. The oscillator at the new pivot is lower than at the previous pivot.
4. If the zero-side filter is on, the oscillator is above zero at both pivots.
5. The TICK high at the new pivot is lower than at the previous pivot.

Long and short swing tracking are independent. Signals are non-repainting because they fire only on confirmed pivots. When all conditions hold, emit a long (bullish) or short (bearish) signal. Entry timing, stops, targets and exits are not part of the logic.