# P/E & Forward P/E vs History

- url: https://www.tradingview.com/script/8kPWPiDO-P-E-Forward-P-E-vs-History/
- type: indicator
- pine_id: PUB;8d3850f8bce74d40b7ba038d157f7ab3
- version: 1.0

## Description

# P/E & Forward P/E vs History

## Overview

This indicator plots a stock's **trailing P/E** and an approximate **forward P/E** in a lower pane, then frames both against the stock's *own* valuation history using a mean line and standard-deviation bands. The goal is to answer a question a raw P/E number can't: not "is 22x expensive?" but "is this stock expensive **for itself**, relative to how the market has typically valued it?"

A P/E of 22 might be cheap for one company and rich for another. By comparing the current multiple to its historical mean and expressing the gap in standard deviations, the indicator turns an ambiguous absolute number into a relative, self-referential read.

## What it plots

- **Trailing P/E** (blue) — the real, reported multiple: price divided by trailing-twelve-month earnings per share.
- **Forward P/E** (orange) — a forward-looking estimate of the multiple. This is a proxy (see Limitations).
- **Mean P/E** (gray dashed) — the average trailing P/E over the chosen window.
- **±1σ band** (shaded) — one standard deviation above and below the mean. Roughly two-thirds of historical observations fall inside this zone.
- **±2σ lines** — two standard deviations out. Roughly 95% of history falls inside ±2σ; readings beyond it are statistically unusual for the stock.
- **Info table** — a corner readout of the current trailing P/E, forward P/E, mean, the live **z-score**, and a plain-English "Position" verdict (Cheap / Normal / Rich, etc.).

## How it's calculated

**Trailing P/E.** TTM earnings per share is pulled from TradingView's fundamental data, and the multiple is current price divided by that figure. You can choose diluted or basic EPS as the source. Bars where TTM EPS is zero or negative are left blank, since a P/E built on near-zero or negative earnings is not meaningful.

**Forward P/E.** Two proxy methods are offered:

1. *Analyst estimate (×4)* — the next-quarter analyst EPS estimate, annualized by multiplying by four.
2. *Growth assumption* — trailing TTM EPS grown forward by a user-set annual rate.

The forward multiple is then current price divided by the chosen forward EPS figure.

**Historical mean and bands.** Two windowing modes are available:

1. *All history* — a cumulative mean and standard deviation computed across every available bar, so the "normal" expands as more data accrues.
2. *Rolling lookback* — a moving mean and standard deviation over a fixed number of bars (default 252, about one trading year), which adapts to recent behavior.

**Z-score.** The current trailing P/E minus the mean, divided by the standard deviation. This single number says how many standard deviations above or below average the stock is trading right now. The "Position" label translates it: beyond +1σ reads as Rich, beyond −1σ as Cheap, beyond ±2σ as Very rich / Very cheap, and inside ±1σ as Normal.

## Settings

- **Trailing EPS source** — diluted (default) or basic. If one errors on a given ticker, switch to the other.
- **Show Forward P/E** — toggle the orange line.
- **Forward EPS method** — analyst-estimate (×4) or growth-assumption.
- **Assumed annual EPS growth %** — used only by the growth-assumption method.
- **Average window** — all-history or rolling lookback.
- **Rolling lookback (bars)** — window length when using rolling mode.
- **Show ±1σ / ±2σ bands** — toggle the bands.
- **Table position / text size** — placement and sizing of the info table.

## How to read it

Look at where the blue line sits relative to the shaded band rather than at its absolute level. Inside the band is ordinary. Pushing above +1σ means the market is paying more per dollar of trailing earnings than it usually does; dropping below −1σ means the opposite. The ±2σ lines mark the statistical extremes of the stock's own range. The z-score and Position label in the table give you the same read as a number and a word, so you don't have to eyeball it.

The gap between the orange and blue lines is also informative: a forward multiple well below the trailing one implies the market expects earnings to grow (a larger future denominator shrinks the multiple). If the average line is slowly drifting higher over time in all-history mode, the market has structurally re-rated the stock to a richer multiple — the definition of "normal" has moved.

## Limitations

**Forward P/E is an approximation, not a true consensus number.** Pine Script does not expose a forward twelve-month consensus EPS. The two proxy methods here are deliberate simplifications: the ×4 annualization ignores seasonality, and the growth method is only as good as the rate you assume. Treat the forward line as directional, not as a terminal-grade figure.

**Fundamental history depth is limited.** Available EPS history on the platform is finite and often spans only a handful of years, so the "all history" mean and bands cover only the data that exists — not a multi-decade record.

**Stocks only.** The indicator needs per-share earnings data. Indices, ETFs, forex, and crypto will show n/a.

**Earnings distortions.** When trailing EPS collapses toward zero around a loss quarter, the ratio can spike, go negative, or blank out. A dramatic move in the P/E line is sometimes an earnings artifact rather than a valuation event — check the earnings backdrop before reading too much into it.

## Disclaimer

This script is for research and educational purposes and is not financial advice. Fundamental data is provided as-is by the platform's data vendors and may contain gaps or errors. Always verify figures independently before making any decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tfox2791

//@version=6

//
//  P/E & Forward P/E vs History
//  - Trailing P/E:  close / TTM EPS            (real, from request.financial)
//  - Forward P/E:   close / estimated EPS      (APPROXIMATE - see notes below)
//  - Historical context: running mean + 1σ/2σ bands + live z-score
//
//  NOTES / LIMITATIONS:
//   * Works on individual stock tickers that have fundamental data.
//     Indices, forex, and crypto will show n/a.
//   * Forward P/E is a PROXY. TradingView does not expose a true forward
//     12-month consensus EPS to Pine. Two proxy methods are offered:
//        - "Analyst estimate (x4)": next-quarter analyst EPS estimate, crudely
//          annualized. Ignores seasonality. Closest to a "real" estimate.
//        - "Growth assumption":     trailing TTM EPS grown by an assumed rate.
//   * Fundamental history on TradingView is limited (often a handful of years),
//     so the "all history" mean only spans the available EPS data.
//   * If "EARNINGS_PER_SHARE_DILUTED" throws an error on a ticker, switch the
//     EPS source input to "EARNINGS_PER_SHARE_BASIC".
// ============================================================================

indicator("P/E & Forward P/E vs History", precision=2)

// ── Inputs ──────────────────────────────────────────────────────────────────
epsId     = input.string("EARNINGS_PER_SHARE_DILUTED", "Trailing EPS source",
             options=["EARNINGS_PER_SHARE_DILUTED", "EARNINGS_PER_SHARE_BASIC"])
showFwd   = input.bool(true, "Show Forward P/E")
fwdMode   = input.string("Analyst estimate (x4)", "Forward EPS method",
             options=["Analyst estimate (x4)", "Growth assumption"])
growthPct = input.float(8.0, "Assumed annual EPS growth % (growth mode)",
             minval=-50, maxval=300) / 100.0
lbMode    = input.string("All history", "Average window",
             options=["All history", "Rolling lookback"])
lookback  = input.int(252, "Rolling lookback (bars)", minval=10)
showBands = input.bool(true, "Show ±1σ / ±2σ bands")
showTable = input.bool(true, "Show info table")

// ── Trailing P/E ────────────────────────────────────────────────────────────
epsTTM = request.financial(syminfo.tickerid, epsId, "TTM")
pe = (not na(epsTTM) and epsTTM > 0) ? close / epsTTM : na
plot(pe, "Trailing P/E", color=color.new(#2962FF, 0), linewidth=2)

// ── Forward P/E (proxy) ─────────────────────────────────────────────────────
estQ = request.earnings(syminfo.tickerid, earnings.estimate, gaps=barmerge.gaps_off)
float fwdEPS = fwdMode == "Growth assumption"
     ? (na(epsTTM) ? na : epsTTM * (1 + growthPct))
     : (na(estQ)   ? na : estQ * 4)
fwdPE = (showFwd and not na(fwdEPS) and fwdEPS > 0) ? close / fwdEPS : na
plot(fwdPE, "Forward P/E", color=color.new(#FF6D00, 0), linewidth=2)

// ── Historical mean & dispersion ────────────────────────────────────────────
var float s1 = 0.0   // running sum of pe
var float s2 = 0.0   // running sum of pe^2
var int   n  = 0

float meanPE = na
float sdPE   = na

if lbMode == "All history"
    if not na(pe)
        s1 += pe
        s2 += pe * pe
        n  += 1
    meanPE := n > 0 ? s1 / n : na
    sdPE   := n > 1 ? math.sqrt(math.max(s2 / n - (s1 / n) * (s1 / n), 0)) : na
else
    meanPE := ta.sma(pe, lookback)
    sdPE   := ta.stdev(pe, lookback)

plot(meanPE, "Mean P/E", color=color.new(color.gray, 0), linewidth=1)

u1 = meanPE + sdPE
l1 = meanPE - sdPE
u2 = meanPE + 2 * sdPE
l2 = meanPE - 2 * sdPE

pu1 = plot(showBands ? u1 : na, "+1σ", color=color.new(color.gray, 55))
pl1 = plot(showBands ? l1 : na, "-1σ", color=color.new(color.gray, 55))
fill(pu1, pl1, color=color.new(color.gray, 90), title="±1σ zone")
plot(showBands ? u2 : na, "+2σ", color=color.new(color.red, 65))
plot(showBands ? l2 : na, "-2σ", color=color.new(color.green, 65))

// ── Info table ──────────────────────────────────────────────────────────────
posInput  = input.string("Top right", "Table position",
             options=["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"],
             group="Table")
sizeInput = input.string("Normal", "Table text size",
             options=["Tiny", "Small", "Normal", "Large"], group="Table")

tablePos = switch posInput
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    "Middle right" => position.middle_right
    => position.top_right

txtSize = switch sizeInput
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

zscore = (not na(pe) and not na(meanPE) and not na(sdPE) and sdPE > 0) ? (pe - meanPE) / sdPE : na

// Plain-English read of where current P/E sits vs its own history
verdict = na(zscore) ? "n/a" : zscore > 2 ? "Very rich" : zscore > 1 ? "Rich" : zscore < -2 ? "Very cheap" : zscore < -1 ? "Cheap" : "Normal"
vColor  = na(zscore) ? color.gray : zscore > 1 ? color.red : zscore < -1 ? color.green : color.gray

var table t = table.new(tablePos, 2, 6, border_width=1, frame_width=1,
     frame_color=color.new(color.gray, 40))
if showTable and barstate.islast
    hdrBg = color.new(color.gray, 10)   // solid-ish header so it pops on dark charts
    rowBg = color.new(color.gray, 85)   // faint fill behind data rows
    table.cell(t, 0, 0, "P/E vs history", text_color=color.white, bgcolor=hdrBg, text_size=txtSize)
    table.cell(t, 1, 0, "",               text_color=color.white, bgcolor=hdrBg, text_size=txtSize)
    table.cell(t, 0, 1, "Trailing P/E", text_color=color.gray, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 1, 1, na(pe) ? "n/a" : str.tostring(pe, "#.##"), text_color=#2962FF, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 0, 2, "Forward P/E", text_color=color.gray, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 1, 2, na(fwdPE) ? "n/a" : str.tostring(fwdPE, "#.##"), text_color=#FF6D00, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 0, 3, "Mean P/E", text_color=color.gray, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 1, 3, na(meanPE) ? "n/a" : str.tostring(meanPE, "#.##"), text_color=color.gray, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 0, 4, "Z-score", text_color=color.gray, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 1, 4, na(zscore) ? "n/a" : str.tostring(zscore, "0.00") + " sd", text_color=vColor, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 0, 5, "Position", text_color=color.gray, bgcolor=rowBg, text_size=txtSize)
    table.cell(t, 1, 5, verdict, text_color=vColor, bgcolor=rowBg, text_size=txtSize)
````
