# Volatility Concentration Audit

- url: https://www.tradingview.com/script/o9CjjxM6-Volatility-Concentration-Audit/
- type: indicator
- pine_id: PUB;f81fe27876a2427ebaf5335a6cd0af4f
- version: 1.0

## Description

Purpose

A volatility reading can be driven by one unusually large return or by many ordinary returns. Those windows can have a similar average squared return but very different composition. Volatility Concentration Audit makes that distinction visible, then shows how much the root-mean-square (RMS) return changes when the single largest absolute return is excluded.

This is a descriptive research indicator. It provides no entry, exit, direction forecast or position-size recommendation.

What the chart shows

Orange: the largest squared log return as a percentage of all squared log returns in the window. A higher value means one observation dominates more of the measured movement.

Aqua: effective contributing returns divided by the window length, expressed as a percentage. This uses every observation's share, so it distinguishes a window dominated by a few large returns from one with broadly distributed contributions.

The table adds the equivalent contributor count, full-window RMS, RMS after excluding one largest return, the percentage of RMS retained, and the excluded return's signed value and age. Age zero means the latest confirmed return in the sample. The sample-close timestamp uses the symbol's exchange timezone. The table describes the latest confirmed window, even when the crosshair is over an older bar. Historical values are available in the Data Window.

Method

Choose N confirmed returns. The default is 50, with a supported range of 5 to 500. The default is an illustrative research window and was not optimized for trading results.

Each return is r = ln(close) - ln(previous close). The window contains exactly N consecutive chart returns, requiring N+1 positive closes. Define e = r squared, S = sum(e), and M = largest(e).

- Largest share = 100 * M / S.
- Effective contributors = S squared / sum(e squared).
- Aqua plot = 100 * effective contributors / N.
- Full RMS = 100 * sqrt(S / N).
- Ex-largest RMS = 100 * sqrt(sum of surviving e / (N-1)).
- RMS retained = 100 * ex-largest RMS / full RMS.

The RMS values and excluded return use log-return percentage units. They are per-chart-bar values, without annualization or subtraction of the mean. RMS therefore differs from centered standard deviation.

The implementation normalizes returns by the largest absolute return before squaring. It also sums the surviving observations directly, avoiding subtraction of nearly equal totals in the leave-one-out calculation. If several returns tie for the largest absolute value, it excludes the most recent one only. All-zero windows show RMS zero and undefined concentration fields. A missing or nonpositive close invalidates the affected window rather than being silently skipped.

How to interpret it

With equal nonzero return magnitudes, the largest share is 100/N, effective contributors equals N, and excluding one return leaves RMS unchanged. With only one nonzero return, the largest share is 100%, effective contributors equals one, and ex-largest RMS becomes zero.

For an arithmetic example, consider five log returns in percentage units: 1, 1, 1, 1 and 4. Their squared values sum to 20. The largest share is 80%, effective contributors is about 1.54 out of five, full RMS is 2%, and ex-largest RMS is 1%. RMS retained is 50%. This illustrates the calculation, not a market result.

Use the tool to inspect the observations behind a volatility summary before comparing different periods. A jump when an old large return leaves the rolling window can be a window-composition effect. The excluded return's age helps identify that mechanism. Removing an observation here is a sensitivity exercise: the large move remains part of the historical record and may be economically important.

What is distinct about this implementation

The concentration and RMS formulas are standard mathematics. This original Pine implementation applies them together to one exact, confirmed-return window and links three practical questions: how dominant is the largest observation, how broadly is squared movement distributed, and how sensitive is the RMS summary to that observation? The timestamp, exact-window validation, deterministic tie handling and excluded-return age make the calculation inspectable. No code was copied or imported from another author's script. It is separate from the author's breakout-event and elapsed-clock diagnostics because it studies the distribution of return magnitudes rather than event outcomes or elapsed time.

Timing and limitations

Calculations commit only when the chart bar closes. The open bar has no provisional plot point, and the table retains the last confirmed sample. There are no higher-timeframe requests, lookahead, future references or plots shifted into the past. Historical source-data corrections, adjustment settings and changes to the symbol, timeframe, session or inputs can still change recalculated results.

Use standard time-based charts. Synthetic chart types are suppressed with an explanatory table message. Session gaps and overnight moves are included in close-to-close returns. Bar durations can differ, particularly around session boundaries. Different feeds and adjustment settings can produce different readings. Ordinary floating-point rounding still applies.

Effective contributors is an equivalent count of equally energetic returns, not an estimate of statistically independent observations or a confidence level. RMS retention is mathematically determined by the largest share and N; it is an alternate sensitivity interpretation, not an independent confirmation signal. The tool uses closing prices and does not measure intrabar extremes, execution costs, liquidity or future risk. No universal good/bad threshold is implied.

Validation

The saved Pine v6 source was compiled and exercised on BTCUSD 1-minute and 1-hour charts and AAPL 1-hour and daily charts. Minimum and maximum windows and the Heikin Ashi guard were checked. Independent reference testing covered 37 cases, including 1,000 high-precision randomized comparisons. Exported TradingView values matched the reference across 499 reconstructible windows and eight outputs per window on BTCUSD 1-minute and AAPL daily data, within numerical rounding. These checks validate calculations and behavior, not predictive value or trading performance.

Free, open-source educational indicator.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0.
// Copyright (c) 2026 ZILLIONAIRE010
//@version=6
indicator("Volatility Concentration Audit", overlay=false, precision=2, max_bars_back=501)

// An original educational diagnostic of the composition of close-to-close
// squared log returns. The inverse-concentration formula is standard math;
// it measures equivalent contributors, not independent observations.
int length = input.int(50, "Confirmed returns in window", minval=5, maxval=500, tooltip="Uses exactly N consecutive chart returns and therefore N+1 positive closes. A missing or nonpositive close invalidates the window. Default 50 is illustrative, not optimized.")
bool showTable = input.bool(true, "Show audit table")
string tableCorner = input.string("Top right", "Table position", options=["Top right", "Top left", "Bottom right", "Bottom left"])

bool supported = chart.is_standard and (timeframe.isseconds or timeframe.isminutes or timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
bool validPrice = not na(close) and not na(close[1]) and close > 0 and close[1] > 0
// The difference of logs avoids overflow from forming a price ratio.
float logReturn = validPrice ? math.log(close) - math.log(close[1]) : na

var float largestShare = na
var float effectiveBars = na
var float effectiveFraction = na
var float fullRms = na
var float excludedRms = na
var float retainedRms = na
var float largestSignedReturn = na
var int largestAge = na
var int sampleCount = 0
var int sampleClose = na
var string status = "Waiting for confirmed data"

// No request.security, future references, retrospective labels or intrabar
// accumulation. Persistent values change only on a confirmed chart bar.
if barstate.isconfirmed
    largestShare := na
    effectiveBars := na
    effectiveFraction := na
    fullRms := na
    excludedRms := na
    retainedRms := na
    largestSignedReturn := na
    largestAge := na
    sampleCount := 0
    sampleClose := time_close
    status := supported ? "Insufficient valid returns" : "Use standard time-based chart"
    if supported
        float maxAbs = 0.0
        int maxIndex = 0
        // Scan newest to oldest; strict > gives ties to the most recent bar.
        for i = 0 to length - 1
            float r = logReturn[i]
            if not na(r)
                sampleCount += 1
                if math.abs(r) > maxAbs
                    maxAbs := math.abs(r)
                    maxIndex := i
        if sampleCount == length
            if maxAbs == 0.0
                fullRms := 0.0
                excludedRms := 0.0
                status := "All returns zero; shares undefined"
            else
                // Normalize before squaring to keep the sums well conditioned.
                // Sum survivors directly, not S-M, to avoid cancellation.
                float sumEnergy = 0.0
                float sumEnergySquared = 0.0
                float survivorEnergy = 0.0
                for i = 0 to length - 1
                    float relativeReturn = logReturn[i] / maxAbs
                    float energy = relativeReturn * relativeReturn
                    sumEnergy += energy
                    sumEnergySquared += energy * energy
                    if i != maxIndex
                        survivorEnergy += energy
                largestShare := 100.0 / sumEnergy
                effectiveBars := math.min(length, math.max(1.0, sumEnergy * sumEnergy / sumEnergySquared))
                effectiveFraction := 100.0 * effectiveBars / length
                fullRms := 100.0 * maxAbs * math.sqrt(sumEnergy / length)
                excludedRms := 100.0 * maxAbs * math.sqrt(survivorEnergy / (length - 1))
                retainedRms := 100.0 * math.sqrt((survivorEnergy / sumEnergy) * length / (length - 1))
                largestSignedReturn := 100.0 * logReturn[maxIndex]
                largestAge := maxIndex
                status := "Confirmed window"

// Do not display a provisional point on the open bar. The table retains the
// latest confirmed sample and explicitly timestamps it in the exchange zone.
bool plotReady = supported and barstate.isconfirmed
plot(plotReady ? largestShare : na, "Largest squared-return share (%)", color=color.orange, linewidth=2, style=plot.style_linebr)
plot(plotReady ? effectiveFraction : na, "Effective contributors / N (%)", color=color.aqua, linewidth=2, style=plot.style_linebr)
hline(0, "Zero", color=color.new(color.gray, 70))
hline(100, "100 percent", color=color.new(color.gray, 70))
plot(plotReady ? effectiveBars : na, "Effective contributing bars", display=display.data_window)
plot(plotReady ? fullRms : na, "Full RMS log return (% per bar)", display=display.data_window)
plot(plotReady ? excludedRms : na, "Ex-largest RMS log return (% per bar)", display=display.data_window)
plot(plotReady ? retainedRms : na, "RMS retained without largest (%)", display=display.data_window)
plot(plotReady ? largestSignedReturn : na, "Excluded log return (%)", display=display.data_window)
plot(plotReady ? largestAge : na, "Excluded return age (bars)", display=display.data_window)

formatNumber(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.####")
formatPercent(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

string panelPosition = switch tableCorner
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right
var table panel = table.new(panelPosition, 2, 11, bgcolor=color.new(color.black, 12), frame_color=color.new(color.gray, 50), frame_width=1)
writeRow(int row, string label, string value, color valueColor) =>
    table.cell(panel, 0, row, label, text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, row, value, text_color=valueColor, text_size=size.small, text_halign=text.align_right)

if barstate.islast
    if showTable
        writeRow(0, "VOLATILITY COMPOSITION", status, color.white)
        writeRow(1, "Valid returns / N", str.tostring(sampleCount) + " / " + str.tostring(length), color.white)
        writeRow(2, "Largest energy share", formatPercent(largestShare), color.orange)
        writeRow(3, "Effective contributors", formatNumber(effectiveBars) + " / " + str.tostring(length), color.aqua)
        writeRow(4, "Full RMS (% log / bar)", formatNumber(fullRms), color.white)
        writeRow(5, "Ex-largest RMS (% log / bar)", formatNumber(excludedRms), color.white)
        writeRow(6, "RMS retained", formatPercent(retainedRms), color.white)
        writeRow(7, "Excluded log return", formatPercent(largestSignedReturn), color.white)
        writeRow(8, "Age from sample close (bars)", na(largestAge) ? "n/a" : str.tostring(largestAge), color.white)
        writeRow(9, "Sample close (exchange zone)", na(sampleClose) ? "n/a" : str.format_time(sampleClose, "yyyy-MM-dd HH:mm", syminfo.timezone), color.white)
        writeRow(10, "Descriptive only", "No forecast / no trade signal", color.silver)
    else
        table.clear(panel, 0, 0, 1, 10)
````
