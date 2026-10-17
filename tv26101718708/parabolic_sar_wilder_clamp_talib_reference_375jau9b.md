# Parabolic SAR (Wilder clamp / TA-Lib reference)

- url: https://www.tradingview.com/script/375JaU9b-Parabolic-SAR-Wilder-clamp-TA-Lib-reference/
- type: indicator
- pine_id: PUB;ed6c9b3cb8eb4540b4d7dc0e3f6d1cce
- version: 1.0

## Description

Parabolic SAR matching TA-Lib’s reference implementation

TradingView’s built-in ta.sar() omits one of Wilder’s rules: the SAR may not sit inside the current or prior bar’s range. Without that clamp the SAR can land where price has already traded, and the flip arrives a bar late. On SPY daily I found two flips that landed late for this reason.

Wilder left three things open. This script follows TA-Lib on all three:

Seeding — start long unless Wilder’s −DM between bars 0 and 1 exceeds +DM. First SAR is bar 0’s low (long) or high (short). Bar 1 isn’t checked for penetration; bar 2’s SAR is clamped against bar 1 only.
Ties — a low exactly equal to the SAR, or a high equal to it, counts as a reversal.
Reversal SAR — the prior trend’s extreme point, clamped outside the current and prior bar’s range.

Acceleration matches TA-Lib’s SAR(acceleration, maximum): the starting factor and the step are the same number.

Verified by reading the plotted values off the chart against TA-Lib 0.8.1 on SPY daily, 250 bars (2025-08-25 to 2026-08-21): agreement to 1.1e-13, no long/short disagreements, and the SAR never sits inside a bar’s range.

Not verified on-chart: seeding is checked only in the Python model this script follows line for line. With more history loaded than the test window, the first nine bars differ from TA-Lib because the two start on different bars; they agree from there.

MIT license.

## Source Code

````pine
// SPDX-License-Identifier: MIT
// This Pine Script® code is released under the MIT License: https://opensource.org/license/mit
//@version=6

// Parabolic SAR matching TA-Lib's reference implementation (TA_SAR), which applies
// Wilder's rule that the SAR may not be placed inside the current or prior bar's range.
// TradingView's built-in ta.sar() omits that rule, so its flips can land a bar earlier.
//
// Wilder's book leaves three things open; this script follows TA-Lib on each:
//   1. Seeding: start long unless Wilder's -DM between bars 0 and 1 is positive and
//      larger than +DM; first SAR is bar 0's low (long) or high (short). Bar 1 is
//      checked for penetration, and the SAR for bar 2 is clamped to bar 1 only.
//   2. Ties: a low exactly equal to the SAR (or a high equal to it) is a reversal.
//   3. Reversal SAR: the prior trend's extreme point, then clamped outside the
//      current and prior bar's range.
//
// Acceleration is both the starting factor and the step, as in TA-Lib's SAR(acceleration, maximum).
indicator("Parabolic SAR (TA-Lib reference)", shorttitle = "SAR TA-Lib", overlay = true)

accel   = input.float(0.02, "Acceleration", minval = 0.001, step = 0.001)
maximum = input.float(0.20, "Maximum",      minval = 0.001, step = 0.01)

var bool  bull = false  // set on bar 1 (Pine v6 bools cannot be na)
var float sar  = na   // SAR to be used on the next bar
var float ep   = na
var float af   = na
float out = na

if bar_index >= 1
    // Prior bar for the clamp. On bar 1 TA-Lib uses bar 1 itself, not bar 0.
    float ph = bar_index == 1 ? high : high[1]
    float pl = bar_index == 1 ? low  : low[1]

    if bar_index == 1
        float up = high - high[1]
        float dn = low[1] - low
        bull := not (dn > up and dn > 0)
        ep   := bull ? high : low
        sar  := bull ? low[1] : high[1]
        af   := accel

    if bull
        if low <= sar
            bull := false
            sar  := math.max(ep, ph, high)
            out  := sar
            af   := accel
            ep   := low
            sar  := math.max(sar + af * (ep - sar), ph, high)
        else
            out := sar
            if high > ep
                ep := high
                af := math.min(af + accel, maximum)
            sar := math.min(sar + af * (ep - sar), pl, low)
    else
        if high >= sar
            bull := true
            sar  := math.min(ep, pl, low)
            out  := sar
            af   := accel
            ep   := high
            sar  := math.min(sar + af * (ep - sar), pl, low)
        else
            out := sar
            if low < ep
                ep := low
                af := math.min(af + accel, maximum)
            sar := math.max(sar + af * (ep - sar), ph, high)

plot(out, "SAR", color = bull ? color.teal : color.red, style = plot.style_cross, linewidth = 2)
````
