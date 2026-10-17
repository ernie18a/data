# HAA TIP Momentum (Wouter Keller)

- url: https://www.tradingview.com/script/ezYlFKRd-HAA-TIP-Momentum-Wouter-Keller/
- type: indicator
- pine_id: PUB;f2d9699678454825b11ba40a4823837f
- version: 1.0

## Description

A monthly risk-on / risk-off regime indicator based on the TIPS momentum "canary" from Wouter Keller & Jan Willem Keuning's Hybrid Asset Allocation paper (SSRN 4346906).

[b]How it works[/b]
The indicator pulls monthly closes of TIP (iShares TIPS Bond ETF) and computes:

Momentum = average( 1-month, 3-month, 6-month, 12-month returns )

At each month-end close, the four lookback returns are calculated from confirmed monthly bars (no repaint), then simple-averaged into a single score:
[list]
[*]Momentum > 0 → RISK-ON (hold equities / TQQQ)
[*]Momentum ≤ 0 → RISK-OFF (rotate to SGOV, BTAL, or cash)
[/list]
The intuition: TIPS rally when investors flee to safety. When TIPS momentum is positive across all four lookbacks, the macro environment favors risk assets. When it turns negative, it's a flight-to-safety signal — historically appearing before the worst of equity drawdowns (e.g. 2022). Averaging four lookbacks instead of using a single one smooths out whipsaws and keeps the signal responsive to both fast shocks (1m/3m) and slower regime shifts (6m/12m).

[b]Features[/b]
[list]
[*]Monthly rebalance (configurable timeframe)
[*]No-repaint mode — signals confirm only on monthly bar close
[*]Histogram colored by regime, with optional background shading
[*]Current-signal label with momentum breakdown by lookback
[*]Built-in alerts for regime flips (risk-on crossover / risk-off crossunder)
[*]Optional overlay of the four component returns for debugging
[/list]

[b]How to use[/b]
[list]
[*]Add it to any chart (TQQQ, QQQ, SPY — the indicator fetches TIP itself). Check once a month at the monthly close:
[*]Green histogram / green background → stay in your risk asset (TQQQ, QQQ, SPY, etc.)
[*]Red histogram / red background → rotate to a defensive sleeve (SGOV for cash-like, BTAL for anti-beta hedge)
[/list]

One trade per regime flip — set the two alerts and you'll be notified the moment a monthly bar closes with the signal flipped.

## Source Code

````pine
//@version=6
// =============================================================================
//  HAA TIP Momentum — Wouter Keller's Hybrid Asset Allocation Canary Signal
// -----------------------------------------------------------------------------
//  Logic (per Keller/Finkelstein):
//    momentum = average( 1m, 3m, 6m, 12m total returns on TIP )
//      > 0  -> Risk-ON  (hold TQQQ / risk assets)
//      <= 0 -> Risk-OFF (hold SGOV / BTAL)
//    Evaluated at month-end close. Monthly rebalance.
//
//  Paper: Keller & Keuning, "Hybrid Asset Allocation" (SSRN 4346906)
// =============================================================================
indicator("HAA TIP Momentum (Keller)", shorttitle="HAA TIP Mom", overlay=false, precision=4)

// ---------- Inputs ---------------------------------------------------------
tipSym    = input.symbol("AMEX:TIP", "Canary symbol (TIPS ETF)", group="Signal")
useLog    = input.bool(false, "Use log returns", group="Signal")
rebalTF   = input.timeframe("M", "Rebalance timeframe", group="Signal", tooltip="Momentum is computed from this timeframe's closes. 'M' = monthly (as in the paper).")
useConf   = input.bool(true, "Use confirmed bar only (no repaint)", group="Signal", tooltip="When true, signals only update after the monthly bar closes.")

showHist  = input.bool(true,  "Show momentum histogram",      group="Display")
showComps = input.bool(false, "Show 1m/3m/6m/12m components", group="Display")
showBG    = input.bool(true,  "Shade background by regime",   group="Display")
showLabel = input.bool(true,  "Show current-signal label",    group="Display")

onColor  = input.color(color.new(#3fb950, 0), "Risk-ON color",  group="Display")
offColor = input.color(color.new(#f85149, 0), "Risk-OFF color", group="Display")

// ---------- Fetch TIP monthly closes --------------------------------------
// Need confirmed monthly closes so that at month t we have t, t-1, t-3, t-6, t-12.
lookaheadMode = useConf ? barmerge.lookahead_off : barmerge.lookahead_on

tipClose = request.security(tipSym, rebalTF, close, lookahead = lookaheadMode, gaps = barmerge.gaps_off)

// Helper: period return of TIP over n bars of the rebalance timeframe
f_ret(int n) =>
    prev = request.security(tipSym, rebalTF, close[n], lookahead = lookaheadMode, gaps = barmerge.gaps_off)
    r = useLog ? math.log(tipClose / prev) : (tipClose / prev) - 1.0
    r

r1  = f_ret(1)
r3  = f_ret(3)
r6  = f_ret(6)
r12 = f_ret(12)

momentum = (r1 + r3 + r6 + r12) / 4.0

// ---------- Signal --------------------------------------------------------
riskOn  = momentum > 0
riskOff = not riskOn

// ---------- Plots ---------------------------------------------------------
barCol = riskOn ? onColor : offColor

plot(showHist ? momentum : na, title="TIP Momentum (avg 1/3/6/12m)", color=barCol, style=plot.style_columns, linewidth=2)

// Zero line
hline(0, "Zero", color=color.new(color.gray, 40), linestyle=hline.style_dashed)

// Component plots (optional)
plot(showComps ? r1  : na, "1m return",  color=color.new(color.aqua,    0))
plot(showComps ? r3  : na, "3m return",  color=color.new(color.yellow,  0))
plot(showComps ? r6  : na, "6m return",  color=color.new(color.orange,  0))
plot(showComps ? r12 : na, "12m return", color=color.new(color.fuchsia, 0))

// Background regime shading
bgcolor(showBG ? (riskOn ? color.new(onColor, 85) : color.new(offColor, 85)) : na, title="Regime shade")

// ---------- Current signal label ------------------------------------------
var label sigLbl = na
if showLabel and barstate.islast
    txt = (riskOn ? "RISK-ON  →  TQQQ" : "RISK-OFF  →  SGOV / BTAL") + "\nMomentum: " + str.tostring(momentum * 100, "#.##") + "%" + "\n1m: " + str.tostring(r1 * 100, "#.##") + "%  3m: " + str.tostring(r3 * 100, "#.##") + "%" + "\n6m: " + str.tostring(r6 * 100, "#.##") + "%  12m: " + str.tostring(r12 * 100, "#.##") + "%"
    label.delete(sigLbl)
    sigLbl := label.new(bar_index, momentum, txt, style = label.style_label_left, color = riskOn ? onColor : offColor, textcolor = color.white, size = size.normal, yloc = yloc.price)

// ---------- Alerts --------------------------------------------------------
alertcondition(ta.crossover(momentum, 0),  title="HAA: Risk-ON  (TIP mom crosses above 0)", message="HAA signal flipped RISK-ON — rotate to TQQQ at next month-open.")
alertcondition(ta.crossunder(momentum, 0), title="HAA: Risk-OFF (TIP mom crosses below 0)", message="HAA signal flipped RISK-OFF — rotate to SGOV/BTAL at next month-open.")
````
