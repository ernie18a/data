# RichmondHillCM - Liquidity Stress Index V 1.2

- url: https://www.tradingview.com/script/diDiF60y-RichmondHillCM-Liquidity-Stress-Index-V-1-2/
- type: indicator
- pine_id: PUB;5e21fac0ccda425b8d6175377b43ce66
- version: 1.0

## Description

[b]RichmondHillCM - Liquidity Stress Index V 1.2[/b]

The LSI tracks the spread between SOFR (Secured Overnight Financing Rate — the cost of borrowing cash overnight against Treasuries in the repo market) and IORB (Interest on Reserve Balances — the risk-free rate the Fed pays banks on reserves held at the Fed), expressed in basis points.

[b]Why it matters[/b]
IORB acts as a soft floor for money-market rates: a bank has little incentive to lend cash below what it can earn risk-free at the Fed. So the position of SOFR relative to IORB is a direct read on how scarce cash is in the funding system.

[b]LSI below 0 (aqua): [/b]SOFR trades under the IORB floor. Reserves are abundant, repo plumbing is easy, funding conditions are comfortable.
[b]LSI above 0 (red): [/b]SOFR is bid above the floor. Cash is getting scarce, balance-sheet and repo capacity are starting to bind, and reserves are sliding from "abundant" toward "scarce."

Sustained positive prints are a classic early-warning signal of funding stress — the September 2019 repo blow-up being the textbook example. Watching this spread helps anticipate when the Fed's reserve backdrop is tightening enough to force a policy response (standing repo facility usage, balance-sheet adjustments, or an end to QT).

[b]How to read it[/b]

Zero line = the IORB floor.
Dashed line = a configurable stress threshold (default 5 bps). When LSI breaks above it, the background shades red to flag an elevated-stress regime.
The further and longer LSI stays positive, the more acute the funding pressure.

[b]Inputs[/b]

Smoothing (SMA length): 1 = raw daily spread; raise to filter day-to-day noise.
Stress threshold (bps): the level above which funding stress is flagged.

[b]Notes[/b]
SOFR and IORB are sourced from FRED and published daily, with IORB stepping only on FOMC decisions — so on intraday charts the daily values hold flat. The daily timeframe is the honest resolution for this gauge. Each leg is requested separately and differenced in-script for robust alignment rather than relying on a spread symbol.

[i]Original concept credit: @gstoyanov. Released under the Mozilla Public License 2.0.[/i]

## Source Code

````pine

//@version=6
// Original concept: @gstoyanov - compares SOFR (Secured Overnight Financing Rate)
// with IORB (Interest on Reserve Balances) to gauge funding/liquidity stress.
indicator("RichmondHillCM - Liquidity Stress Index V 1.2", shorttitle="RichmondHillCM - Liquidity Stress Index V1.2", overlay=false, precision=2)

// ============================================================================
// WHAT THIS MEASURES
// LSI = SOFR - IORB, shown in basis points.
//   SOFR : cost of overnight cash borrowed against Treasuries (repo market)
//   IORB : risk-free rate the Fed pays banks on reserves parked at the Fed
//
// IORB is a soft FLOOR for money-market rates: a bank has little reason to lend
// cash below what it earns risk-free at the Fed. So when SOFR trades ABOVE IORB
// (LSI > 0), cash has become scarce in the funding market - reserves are sliding
// from "abundant" toward "scarce" and balance-sheet / repo capacity is binding.
// Sustained positive prints are a classic early warning of funding stress
// (e.g. the Sep 2019 repo blow-up). Negative prints = ample reserves, easy plumbing.
// ============================================================================

// ----- Inputs ---------------------------------------------------------------
smoothLen = input.int(1, "Smoothing (SMA length)", minval=1, tooltip="1 = raw spread; raise to smooth daily noise")
stressBp  = input.float(5.0, "Stress threshold (bps)", tooltip="LSI above this is flagged as elevated funding stress")

// ----- Data -----------------------------------------------------------------
// Pull each leg separately (robust alignment / na-handling) instead of relying
// on a single spread-symbol string like "FRED:SOFR-FRED:IORB".
sofr = request.security("FRED:SOFR", timeframe.period, close)
iorb = request.security("FRED:IORB", timeframe.period, close)

// FRED publishes these as percentages, so multiply the gap by 100 to get bps.
spreadBp = (sofr - iorb) * 100.0
lsi = ta.sma(spreadBp, smoothLen)

// ----- Plot -----------------------------------------------------------------
// Line color flips with regime: red above the floor (stress), aqua below (calm).
lsiColor = lsi >= 0 ? #ef233c : color.aqua
lsiPlot  = plot(lsi, "LSI (bps)", color=lsiColor, linewidth=2)

// Hidden zero baseline used as the fill anchor (fill needs two plot ids).
zeroPlot = plot(0, "Zero baseline", color=color.new(color.gray, 100), editable=false, display=display.none)

// Two transparency-toggled fills; na switches the inactive one off each bar.
fill(lsiPlot, zeroPlot, color = lsi >= 0 ? color.new(#ef233c, 82) : na, title="Stress fill")
fill(lsiPlot, zeroPlot, color = lsi <  0 ? color.new(color.aqua, 82) : na, title="Calm fill")

// ----- Reference levels -----------------------------------------------------
hline(0, "IORB floor", color=color.gray, linestyle=hline.style_dotted)
hline(stressBp, "Stress threshold", color=color.new(#ef233c, 50), linestyle=hline.style_dashed)

// Shade the background while the spread sits above the stress threshold.
bgcolor(lsi >= stressBp ? color.new(#ef233c, 90) : na, title="Stress regime")
````
