<!-- tradingview-pine-id: PUB;9be305b24a4648ff8b918ab2797ddcf9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Funding Stress — SOFR vs EFFR & IORB

Source: https://www.tradingview.com/script/7Abp03kH-Funding-Stress-SOFR-vs-EFFR-IORB/

## Description

**Funding Stress**

This indicator is designed to monitor stress developing in the plumbing of the US financial system, particularly the Treasury repo market.

It tracks two overnight funding spreads:

**SOFR − EFFR** — The primary signal. This measures the difference between the Secured Overnight Financing Rate (SOFR) and the Effective Federal Funds Rate (EFFR). A widening spread can indicate that borrowing cash against Treasury collateral is becoming unusually expensive relative to broader overnight funding conditions.

**SOFR − IORB** — A secondary confirmation signal. This compares SOFR with the Interest Rate on Reserve Balances (IORB), the rate banks can earn on reserves held at the Federal Reserve. A widening spread can provide additional evidence of pressure within repo markets.

Both spreads are displayed in **basis points (bps)**.

Visual reference levels are included at **5, 10 and 20 bps** to make changes in funding conditions easier to identify. These should be treated as guides rather than fixed definitions of financial stress.

The key signal to watch is not necessarily the absolute level, but a **rapid and persistent widening of the spreads**, particularly when both measures move higher together.

Short-lived spikes can occur around month-end, quarter-end and year-end as dealer balance-sheet capacity becomes temporarily constrained, so these should not automatically be interpreted as systemic stress.

**In simple terms:** when SOFR begins rising materially relative to other overnight rates, something may be tightening in the financial system's plumbing. Persistent or accelerating moves can provide an early warning of broader liquidity stress.

---

## Source Code

````pine
//@version=6
indicator("Funding Stress — SOFR vs EFFR & IORB", overlay=false)

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────

sofr = request.security("FRED:SOFR", "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
effr = request.security("FRED:EFFR", "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
iorb = request.security("FRED:IORB", "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
// SPREADS — BASIS POINTS
// ─────────────────────────────────────────────

// Main funding-plumbing indicator
sofr_effr_bps = (sofr - effr) * 100.0

// Secondary confirmation
sofr_iorb_bps = (sofr - iorb) * 100.0

// ─────────────────────────────────────────────
// COLOUR MAIN SIGNAL BY STRESS
// ─────────────────────────────────────────────

mainColor = sofr_effr_bps >= 20 ? color.red : sofr_effr_bps >= 10 ? color.orange : sofr_effr_bps >= 5 ? color.yellow : color.aqua

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────

plot(sofr_effr_bps, title="SOFR - EFFR (bps)", color=mainColor, linewidth=2)
plot(sofr_iorb_bps, title="SOFR - IORB (bps)", color=color.new(color.blue, 45), linewidth=1)

// ─────────────────────────────────────────────
// REFERENCE LEVELS
// ─────────────────────────────────────────────

hline(0, "0 bps", color=color.gray)
hline(5, "5 bps — Watch", color=color.new(color.yellow, 55))
hline(10, "10 bps — Elevated", color=color.new(color.orange, 45))
hline(20, "20 bps — Stress", color=color.new(color.red, 35))

// Highlight elevated funding stress
bgColor = sofr_effr_bps >= 20 ? color.new(color.red, 88) : sofr_effr_bps >= 10 ? color.new(color.orange, 92) : na
bgcolor(bgColor)

// ─────────────────────────────────────────────
// CURRENT VALUES
// ─────────────────────────────────────────────

var table stats = table.new(position.top_right, 2, 3, border_width=1)

if barstate.islast
    table.cell(stats, 0, 0, "Spread", text_color=color.white)
    table.cell(stats, 1, 0, "Current", text_color=color.white)

    table.cell(stats, 0, 1, "SOFR - EFFR", text_color=color.white)
    table.cell(stats, 1, 1, str.tostring(sofr_effr_bps, "#.00") + " bps", text_color=mainColor)

    table.cell(stats, 0, 2, "SOFR - IORB", text_color=color.white)
    table.cell(stats, 1, 2, str.tostring(sofr_iorb_bps, "#.00") + " bps", text_color=color.blue)
````
