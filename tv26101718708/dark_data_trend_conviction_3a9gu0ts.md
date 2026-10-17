# [Dark Data] Trend Conviction

- url: https://www.tradingview.com/script/3A9GU0tS-Dark-Data-Trend-Conviction/
- type: indicator
- pine_id: PUB;36474da219d54643bd50623cf86125ea
- version: 1.0

## Description

[b]Objective[/b]
Quantifies directional efficiency by means of penalizing adverse price extension.

[b]Theory[/b]
Price movement with little opposition indicates a trend with conviction. High directional efficiency and low adverse pressure typically result in continued directional bias across lower timeframes.

[b]How To Use[/b]
Trend Conviction is best used for directional bias on timeframes higher than your execution timeframe.
The output ranges from 1 to -1, where 1 is a perfect uptrend and -1 is a perfect downtrend.
Increasing Penalty Power filters out trends with significant opposing price activity.

[b]Nuanced Info/Warnings[/b]
Different assets naturally tolerate varying degrees of counter-trend extension within a healthy trend, so a higher Penalty Power is not always better.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DarkData_Official

//@version=6
indicator("[Dark Data] Trend Conviction", shorttitle="Trend Conviction", overlay=false, precision=3)

//==================================================================//
// INPUTS
//==================================================================//
grpCore     = "Core Settings"
periodBars  = input.int(20, "Period", minval=1, group=grpCore)
penaltyGain = input.float(1.0, "Penalty Power", minval=0.0, step=0.1, group=grpCore,
     tooltip="Controls how aggressively opposing price extensions dampen conviction.\n\n0 = No dampening\n1 = Mild dampening (linear)\n2 = Strong dampening (squared)\n3+ = Very aggressive dampening")

// Visuals (FILL ONLY — does NOT change conviction output)
grpVis        = "Visuals"
colorRangeAbs = input.float(0.50, "Color Gradient Range", minval=0.01, step=0.01, group=grpVis,
     tooltip="Absolute value for max color (e.g. 0.5 will have max green at 0.5, and max red at -0.5).")

//==================================================================//
// CONSTANTS
//==================================================================//
eps = 1e-12

//==================================================================//
// PER-BAR COMPONENTS
//==================================================================//
closeChange = close - close[1]
upExt       = math.max(high - close[1], 0.0)
downExt     = math.max(close[1] - low, 0.0)

//==================================================================//
// CORE CALCULATION (UNCHANGED)
//==================================================================//
float conviction = 0.0

if bar_index < 1
    conviction := 0.0
else
    int   len  = bar_index < periodBars ? bar_index : periodBars
    float wSum = len * (len + 1) * 0.5

    // Run 1: weighted close-to-close change (newer bars get higher weight)
    float wClose = 0.0
    for i = 0 to len - 1
        float wgt = float(len - i) / wSum
        wClose += closeChange[i] * wgt

    int trendSign = wClose > 0.0 ? 1 : wClose < 0.0 ? -1 : 0

    if trendSign == 0
        conviction := 0.0
    else
        // Run 2: weighted trend-direction extension
        float wTrendExt = 0.0
        for i = 0 to len - 1
            float wgt = float(len - i) / wSum
            wTrendExt += (trendSign > 0 ? upExt[i] : downExt[i]) * wgt

        if wTrendExt <= eps
            conviction := 0.0
        else
            float base = wClose / wTrendExt

            if penaltyGain <= 0.0
                conviction := base
            else
                // Run 3: multiplicative damping
                float factor = 1.0
                for i = 0 to len - 1
                    if factor > eps
                        float wgt = float(len - i) / wSum

                        float oppExt  = trendSign > 0 ? downExt[i] : upExt[i]
                        float r       = oppExt / wTrendExt
                        float penalty = (math.pow(1.0 + r, penaltyGain) - 1.0) * wgt

                        factor *= math.exp(-penalty)

                conviction := base * (factor <= eps ? 0.0 : factor)

//==================================================================//
// PLOTS + RSI-STYLE GRADIENT FILL (NO OVERSHOOT)
//==================================================================//
float rangeAbs = math.max(colorRangeAbs, eps)

convPlot    = plot(conviction, "Trend Conviction", color=color.new(color.black, 70), linewidth=1)
midLinePlot = plot(0.0, color=na, editable=false, display=display.none)

hline(0.0, "Zero", color=color.new(#787B86, 50), linestyle=hline.style_dotted)

// Green gradient above zero (opaque near +rangeAbs, fades toward 0)
fill(convPlot, midLinePlot, rangeAbs, 0.0,
     top_color = color.new(color.rgb(0, 230, 80), 0),
     bottom_color = color.new(color.rgb(0, 230, 80), 100),
     title = "Positive Gradient Fill")

// Red gradient below zero (opaque near -rangeAbs, fades toward 0)
fill(convPlot, midLinePlot, 0.0, -rangeAbs,
     top_color = color.new(color.rgb(255, 30, 60), 100),
     bottom_color = color.new(color.rgb(255, 30, 60), 0),
     title = "Negative Gradient Fill")
````
