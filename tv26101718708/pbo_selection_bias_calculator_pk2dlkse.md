# PBO / Selection Bias Calculator

- url: https://www.tradingview.com/script/pk2dlkSe/
- type: indicator
- pine_id: PUB;cab3fd5f2b6749ea93596258e3c1d211
- version: 1.0

## Description

A calculator for selection bias in strategy backtests, based on the False Strategy Theorem. Enter the number of strategy variants you searched, the variance of their Sharpe ratios, and your single best variant's Sharpe; it returns the expected maximum Sharpe a no-edge search of that size would produce, and flags whether your best clears that screen.

How to read it
If your best Sharpe does not beat the expected maximum under the null, it is plausibly just the luckiest of many trials. Important: clearing the expected maximum is a screening threshold, not a statistical significance test.

Honest by design
- No buy/sell signals. It reads no price data; it is a pure analytics table computed from your inputs.
- Non-repainting by construction.

Open-source and MIT licensed. The underlying statistics (PSR, Deflated Sharpe, PBO via CSCV, Harvey-Liu haircut) follow the published papers cited in the code.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// PBO / Selection Bias Calculator
// Closed-form approximation E[max] ~= sd_trials * sqrt(2 ln N) for the
// expected maximum Sharpe across N trials under the false strategy
// theorem null. Pure analytics table. No signals, no chart overlay
// effect on price.
indicator("PBO / Selection Bias Calculator", overlay = false)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

nTrials = input.int(100, "Number of strategy variants (N)", minval = 2,
     group = "Inputs")
varSR   = input.float(0.04, "Variance of trial Sharpes",
     minval = 0.0001, step = 0.01,
     tooltip = "Sample variance of your trial Sharpe estimates.",
     group = "Inputs")
obsSR   = input.float(1.0, "Observed best Sharpe",
     step = 0.1,
     tooltip = "Sharpe of your single best in-sample variant.",
     group = "Inputs")

sdSR = math.sqrt(varSR)
expectedMax = sdSR * math.sqrt(2.0 * math.log(nTrials))
gap = obsSR - expectedMax
suspect = gap < 0.0

var table t = table.new(position.top_right, 2, 7, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Selection Bias",
         text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, "Trials N")
    table.cell(t, 1, 1, str.tostring(nTrials))
    table.cell(t, 0, 2, "SD of trial SRs")
    table.cell(t, 1, 2, str.tostring(sdSR, "#.####"))
    table.cell(t, 0, 3, "Expected max under null")
    table.cell(t, 1, 3, str.tostring(expectedMax, "#.####"))
    table.cell(t, 0, 4, "Your best Sharpe")
    table.cell(t, 1, 4, str.tostring(obsSR, "#.####"))
    table.cell(t, 0, 5, "Above E[max]?")
    table.cell(t, 1, 5, suspect ? "NO (below null max)" : "YES (screen only)",
         text_color = color.white,
         bgcolor = suspect ? color.new(color.red, 30) : color.new(color.green, 30))
    table.cell(t, 0, 6, "Note")
    table.cell(t, 1, 6, "above E[max] is a screen, not a significance test",
         text_color = color.gray)
````
