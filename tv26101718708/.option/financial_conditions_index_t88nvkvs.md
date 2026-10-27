# Financial Conditions Index

- url: https://www.tradingview.com/script/t88nVKvs-Financial-Conditions-Index/
- type: indicator
- pine_id: PUB;73b714b9b38a40f2b3f880443bdd3c24
- version: 1.0

## Description

# Financial Conditions Index — Real Yields + Credit + Dollar + Vol

## What it does

This indicator condenses the four pillars of market financial conditions into a single, readable composite: **are conditions tight or loose right now versus their recent norm — and which factor is driving it?**

It takes four inputs that each tighten or loosen the screws on risk assets — the real yield, high-yield credit spreads, the dollar, and equity volatility — standardizes them onto a common scale, and combines them. A single number tells you the regime; a breakdown table tells you the cause.

## What it plots

The composite plots as **zero-centered columns**:

- **Red, above the band** — conditions TIGHTER than their rolling norm (a risk-off lean).
- **Green, below the band** — conditions LOOSER than normal (a risk-on lean).
- **Faint grey, inside the band** — neutral / near the norm.

Zero is the rolling-window average, so the indicator reads *relative tightness*, not an absolute level. The dotted lines mark the status band.

## The four components

Each is pulled from public data, z-scored over a rolling window, and sign-aligned so that **positive always means tighter**:

- **Real Yield** — the 10-year TIPS real yield (FRED: DFII10). Higher real rates = tighter.
- **Credit (HY)** — the high-yield option-adjusted spread (FRED: BAMLH0A0HYM2). Wider spreads = tighter.
- **Dollar** — the US Dollar Index (TVC: DXY). A stronger dollar = tighter global conditions.
- **Equity Vol** — the VIX (TVC: VIX). Higher vol = tighter.

The composite is an equal-weighted average of these by default, and the weights are inputs you can change.

## The table ("FIN CONDITIONS")

- **FCI** — the headline composite z-score and its status: TIGHT (risk-off), LOOSE (risk-on), or NEUTRAL.
- **Real Yield / Credit (HY) / Dollar / Equity Vol** — each component's own z-score and whether it is currently *tightening*, *easing*, or *neutral*.

This breakdown is the point of the tool. A one-line conditions index can only say "tight" or "loose"; this one shows you *why*. A reading driven by real yields and the dollar is a very different animal from one driven by credit spreads and volatility blowing out — the first is often a benign, rates-led tightening, the second is genuine market stress. Reading the components keeps you from mistaking one for the other.

## How to use it

1. **Read the composite as the regime.** Above the band = a tighter-than-normal backdrop that tends to pressure risk; below = a looser, more supportive one.
2. **Always check the breakdown.** When the composite flags tight, look at which components are carrying it. Rates/dollar tightness while credit and vol stay loose is a different signal than a broad-based tightening across all four.
3. **Watch for divergence within the components.** When one factor pulls hard against the others, that disagreement is information — it often marks transitions and tells you what the market is actually reacting to.
4. **Pair it with your chart.** Add it beneath any asset to gauge the macro backdrop your instrument is trading into.

## Settings

- **Z-Score Window** — rolling lookback for standardizing each component (default 252 ≈ one year). Longer windows (504/756) anchor to a broader norm and better capture persistent regimes, at the cost of responsiveness.
- **Status Band** — how far from zero (in z units) a reading must be to flag TIGHT/LOOSE rather than NEUTRAL (default 0.5).
- **Component Weights** — equal (1.0 each) by default; raise or lower any factor's influence without touching the code.

## Methodology and honest limitations

- **This is a transparent, equal-weight z-score composite — not a regression- or PCA-estimated index** like the Chicago Fed NFCI or the Goldman Sachs FCI. It's an honest "tight vs loose versus the recent norm" read built from public series, not an econometrically weighted institutional index. Treat the equal weighting as a sensible default, not an optimized one.
- **The rolling window has a tradeoff baked in.** A regime that stays tight for a long stretch slowly normalizes toward zero, because it becomes the new "normal." That is the nature of a rolling z-score; lengthen the window if you would rather it keep flagging a persistent regime.
- **It is asset- and timeframe-independent by construction.** Every component is pulled at its own daily resolution and standardized there, so the window is measured in the components' (business-day) bars — not your chart's. It reads the same whether you place it under a 24/7 asset or a regular-hours one; you never need to retune the window per symbol.
- **History is bounded** by the 10-year real-yield series (begins 2003) plus the window's warm-up period; earlier bars read n/a.

## Data

All series are pulled live via `request.security`: FRED DFII10 (10-year TIPS real yield), FRED BAMLH0A0HYM2 (high-yield OAS), TVC DXY (US Dollar Index), and TVC VIX (equity volatility). Nothing is hard-coded — the composite and every table value are computed from these public sources.

## Disclaimer

For educational and informational purposes only. This is not investment advice or a recommendation to buy or sell any asset. Markets involve risk; do your own research.

## Source Code

````pine
//@version=6
indicator("Financial Conditions Index", overlay=false, precision=2)

// ─────────────────────────────────────────────────────────────────────────────
// A multi-factor financial conditions composite: four inputs, each z-scored over a
// rolling window and sign-aligned so POSITIVE = tighter-than-normal (risk-off lean),
// NEGATIVE = looser-than-normal (risk-on lean).
//   • Real yield   — FRED:DFII10        (up = tighter)
//   • Credit       — FRED:BAMLH0A0HYM2  (HY OAS; up = tighter)
//   • Dollar       — TVC:DXY            (up = tighter)
//   • Equity vol   — TVC:VIX            (up = tighter)
// Equal-weight by default (weights are inputs). The table breaks out each factor's
// z-score so you can see WHICH input is driving the composite.
//
// This reads the LEVEL of conditions (tight vs loose vs their recent norm). For the
// tightening/easing MOMENTUM read, use the Macro Risk Regime indicator — kept separate.
//
// Transparent equal-weight z-score composite — NOT a regression-/PCA-estimated index
// like the Chicago Fed NFCI or GS FCI.
//
// ASSET-CALENDAR NOTE: every component is pulled at its own DAILY ("D") resolution and
// the z-score is computed there, so the window is in the components' (business-day)
// bars — not the chart's. It reads the same on a 24/7 asset (BTC) or a regular-hours
// one (SPX). No need to change the window per asset.
// ─────────────────────────────────────────────────────────────────────────────

// ─── INPUTS ───
grp = "Composite"
z_window = input.int(252, "Z-Score Window (trading days)", minval=20, group=grp, tooltip="Rolling lookback for each component's z-score, in the components' daily (business-day) bars. 252 ≈ 1 year. Longer (504/756) anchors to a broader norm and better captures persistent regimes, at the cost of responsiveness. Independent of the chart's asset/timeframe.")
z_band = input.float(0.5, "Status Band (z)", minval=0.0, group=grp, tooltip="How far from zero (z units) a reading must be to flag TIGHT / LOOSE rather than NEUTRAL — for the composite and each component.")

grp_w = "Component Weights"
w_ry     = input.float(1.0, "Real Yield (DFII10)", minval=0.0, group=grp_w)
w_credit = input.float(1.0, "Credit (HY OAS)",     minval=0.0, group=grp_w)
w_dxy    = input.float(1.0, "Dollar (DXY)",        minval=0.0, group=grp_w)
w_vix    = input.float(1.0, "Equity Vol (VIX)",    minval=0.0, group=grp_w)

// ─── DATA: rolling z-score of each component (computed on its own daily bars) ───
f_zscore(simple string sym) =>
    request.security(sym, "D", ta.stdev(close, z_window) == 0 ? na : (close - ta.sma(close, z_window)) / ta.stdev(close, z_window))

z_ry     = f_zscore("FRED:DFII10")        // 10Y real yield      — up = tighter
z_credit = f_zscore("FRED:BAMLH0A0HYM2")  // HY OAS credit spread — up = tighter
z_dxy    = f_zscore("TVC:DXY")            // US dollar index      — up = tighter
z_vix    = f_zscore("TVC:VIX")            // equity volatility    — up = tighter

// ─── COMPOSITE (weighted average of available components) ───
zwsum = (na(z_ry) ? 0.0 : w_ry * z_ry) + (na(z_credit) ? 0.0 : w_credit * z_credit) + (na(z_dxy) ? 0.0 : w_dxy * z_dxy) + (na(z_vix) ? 0.0 : w_vix * z_vix)
wsum  = (na(z_ry) ? 0.0 : w_ry)        + (na(z_credit) ? 0.0 : w_credit)            + (na(z_dxy) ? 0.0 : w_dxy)         + (na(z_vix) ? 0.0 : w_vix)
fci = wsum > 0 ? zwsum / wsum : na

// ─── COLORS / STATUS HELPERS (red = tight / risk-off, green = loose / risk-on) ───
col_good = color.new(#00E676, 0)
col_bad  = color.new(#FF1744, 0)
col_mid  = color.new(#FFEB3B, 0)
col_na   = color.new(#FFFFFF, 45)

f_signed(v) => na(v) ? "n/a" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##")
f_comp_status(z) => na(z) ? "n/a"  : z >  z_band ? "tightening" : z < -z_band ? "easing" : "neutral"
f_comp_color(z)  => na(z) ? col_na : z >  z_band ? col_bad      : z < -z_band ? col_good : col_mid

// ─── PLOT: COMPOSITE ───
// Zero-centered columns. Red above the band = tight (risk-off), green below = loose (risk-on),
// faint grey inside the band = neutral.
fci_col = na(fci) ? na : fci > z_band ? color.new(#FF1744, 15) : fci < -z_band ? color.new(#00E676, 15) : color.new(#9E9E9E, 45)
plot(fci, "FCI (z)", color=fci_col, style=plot.style_columns)
hline(0.0, "Neutral", color=color.new(#FFFFFF, 70), linestyle=hline.style_solid)
hline(z_band,  "Tight band", color=color.new(#FF1744, 80), linestyle=hline.style_dotted)
hline(-z_band, "Loose band", color=color.new(#00E676, 80), linestyle=hline.style_dotted)

// ─── TABLE ───
var table panel = table.new(position.top_right, 3, 6, bgcolor=color.new(#1a1a2e, 10), border_width=1, border_color=color.new(#FFFFFF, 80))

if barstate.islast
    table.cell(panel, 0, 0, "FIN CONDITIONS", text_color=color.new(#FF9800, 0), text_size=size.normal, bgcolor=color.new(#16213e, 0))
    table.cell(panel, 1, 0, "z", text_color=color.white, text_size=size.normal, bgcolor=color.new(#16213e, 0))
    table.cell(panel, 2, 0, "Status", text_color=color.white, text_size=size.normal, bgcolor=color.new(#16213e, 0))

    // Composite (headline)
    fci_txt = na(fci) ? "n/a" : fci > z_band ? "TIGHT - risk-off" : fci < -z_band ? "LOOSE - risk-on" : "NEUTRAL"
    fci_tcol = na(fci) ? col_na : fci > z_band ? col_bad : fci < -z_band ? col_good : col_mid
    table.cell(panel, 0, 1, "FCI", text_color=color.white, text_size=size.normal)
    table.cell(panel, 1, 1, f_signed(fci), text_color=fci_tcol, text_size=size.normal)
    table.cell(panel, 2, 1, fci_txt, text_color=fci_tcol, text_size=size.normal)

    // Component contributions (raw z-score; + = adding tightness)
    table.cell(panel, 0, 2, "Real Yield", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 2, f_signed(z_ry), text_color=f_comp_color(z_ry), text_size=size.normal)
    table.cell(panel, 2, 2, f_comp_status(z_ry), text_color=f_comp_color(z_ry), text_size=size.normal)

    table.cell(panel, 0, 3, "Credit (HY)", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 3, f_signed(z_credit), text_color=f_comp_color(z_credit), text_size=size.normal)
    table.cell(panel, 2, 3, f_comp_status(z_credit), text_color=f_comp_color(z_credit), text_size=size.normal)

    table.cell(panel, 0, 4, "Dollar", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 4, f_signed(z_dxy), text_color=f_comp_color(z_dxy), text_size=size.normal)
    table.cell(panel, 2, 4, f_comp_status(z_dxy), text_color=f_comp_color(z_dxy), text_size=size.normal)

    table.cell(panel, 0, 5, "Equity Vol", text_color=color.new(#FFFFFF, 20), text_size=size.normal)
    table.cell(panel, 1, 5, f_signed(z_vix), text_color=f_comp_color(z_vix), text_size=size.normal)
    table.cell(panel, 2, 5, f_comp_status(z_vix), text_color=f_comp_color(z_vix), text_size=size.normal)
````
