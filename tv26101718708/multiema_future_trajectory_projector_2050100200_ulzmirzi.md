# Multi-EMA Future Trajectory Projector [20/50/100/200]

- url: https://www.tradingview.com/script/ULzMirzI-Multi-EMA-Future-Trajectory-Projector-20-50-100-200/
- type: indicator
- pine_id: PUB;8fae00fc0a9846a1a59a650cdfce1b72
- version: 1.0

## Description

Multi-EMA Future Trajectory Projector [20/50/100/200]DescriptionThe [b]Multi-EMA Future Trajectory Projector[/b] solves a fundamental limitation of traditional moving averages: lag. Because Exponential Moving Averages (EMAs) are backward-looking mathematical averages, traders are often left guessing how long or how far a price must move before a trend crossover occurs.

This script eliminates the guesswork by calculating the exact mathematical decay of the [b]20, 50, 100, and 200 EMAs[/b] into the unprinted, blank future space of your chart. Rather than predicting where the market will go, this tool acts as a [b]"What-If" simulator[/b], plotting the precise trajectory curves the EMAs will take based on your own expected price targets.

Unlike standard indicators, this script gives you complete visual control over the lookahead vectors directly inside the [b]Inputs[/b] tab, allowing you to custom-style your future projection lines.


How it Works (The Math)

An EMA weighs the most recent price closing data heavier using a fixed smoothing multiplier:[i]Multiplier = 2 / (Length + 1)[/i]

Because future price bars do not exist yet, this indicator runs a recursive loop algorithm starting from the real-time live price bar. It uses a chain-link calculation where every forward step is derived from the previous step’s projected EMA value using your selected price source as the fixed focal target.

Core Features & Settings
[list]
[*] [b]Custom Lookahead Depth:[/b] Adjust the [i]Number of Extensions[/i] to project anywhere from 1 to 500 bars into the future blank space.[] [b]Simulate Multiple Scenarios:[/b] Change the [i]Price Source[/i] input to simulate different environments. For example, setting it to [i]Close[/i] calculates the path if the price completely flatlines.
[*] [b]Complete Input Styling:[/b] TradingView natively restricts code-generated future lines from appearing in the "Style" tab. This script bypasses that limitation by moving all color, thickness, and line style (Solid, Dashed, Dotted) settings directly into the [b]Inputs[/b] panel for individual EMAs.
[/list]

How to Use This in Your Trading
1. Anticipating Trend Crossovers (EMA Crosses)Instead of waiting hours or days for a 20/50 EMA cross to print historically, look at the projected slopes. If the 20 EMA trajectory curve is bending aggressively toward the 50 EMA, you can visually measure exactly how many bars are required at the current price level for a crossover to trigger.

2. Identifying Extensions & Mean Reversion Shorter moving averages (like the 20 EMA) react rapidly to spot prices and curve sharply, while longer ones (like the 200 EMA) plot flat trajectories. Use the gap between the short-term and long-term future lines to judge if an asset is overextended and likely to experience a mean-reversion pullback.

3. Support & Resistance Confluence Projected curves map out where key historical moving averages will form dynamic support or resistance on upcoming bars. Use the future line coordinates to plan precise, front-run take-profit limits or stop-loss placements.

## Source Code

````pine
//@version=6
indicator("Fully Customizable Multi-EMA Projector v6", overlay=true)

// ==========================================
// 1. PROJECTION SETTINGS
// ==========================================
extLength   = input.int(10, title="Number of Extensions (Bars Ahead)", minval=1, maxval=500, group="Projection Settings")
priceSource = input.source(close, title="Price Source (Hypothetical Target)", group="Projection Settings")

// ==========================================
// 2. COLOR & STYLE INPUTS (Edit everything here!)
// ==========================================
color20  = input.color(color.blue,   title="EMA 20 Color",   group="EMA 20 Style")
style20  = input.string("Dashed",    title="EMA 20 Future Style", options=["Solid", "Dashed", "Dotted"], group="EMA 20 Style")
width20  = input.int(2,              title="EMA 20 Future Width", minval=1, maxval=5, group="EMA 20 Style")

color50  = input.color(color.yellow, title="EMA 50 Color",   group="EMA 50 Style")
style50  = input.string("Dashed",    title="EMA 50 Future Style", options=["Solid", "Dashed", "Dotted"], group="EMA 50 Style")
width50  = input.int(2,              title="EMA 50 Future Width", minval=1, maxval=5, group="EMA 50 Style")

color100 = input.color(color.orange, title="EMA 100 Color",  group="EMA 100 Style")
style100 = input.string("Dashed",    title="EMA 100 Future Style", options=["Solid", "Dashed", "Dotted"], group="EMA 100 Style")
width100 = input.int(2,              title="EMA 100 Future Width", minval=1, maxval=5, group="EMA 100 Style")

color200 = input.color(color.purple, title="EMA 200 Color",  group="EMA 200 Style")
style200 = input.string("Dashed",    title="EMA 200 Future Style", options=["Solid", "Dashed", "Dotted"], group="EMA 200 Style")
width200 = input.int(2,              title="EMA 200 Future Width", minval=1, maxval=5, group="EMA 200 Style")

// Helper function to convert text dropdown selection to Pine Script line styles
getLineStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

// ==========================================
// 3. CALCULATION & HISTORICAL PLOTS
// ==========================================
ema20  = ta.ema(priceSource, 20)
ema50  = ta.ema(priceSource, 50)
ema100 = ta.ema(priceSource, 100)
ema200 = ta.ema(priceSource, 200)

// Plot historical lines using the colors defined in the Inputs tab
plot(ema20,  color=color20,  title="EMA 20 Line",  linewidth=1)
plot(ema50,  color=color50,  title="EMA 50 Line",  linewidth=1)
plot(ema100, color=color100, title="EMA 100 Line", linewidth=1)
plot(ema200, color=color200, title="EMA 200 Line", linewidth=1)

// ==========================================
// 4. FUTURE PROJECTION LOGIC
// ==========================================
var line[] projLines = array.new_line()

// Clear previous projected lines on every new real-time price tick
if barstate.islast
    if array.size(projLines) > 0
        for i = 0 to array.size(projLines) - 1 by 1
            line.delete(array.get(projLines, i))
        array.clear(projLines)

    // Loop through all 4 EMA profiles
    for i = 0 to 3 by 1
        int period = na
        color col  = na
        int pWidth = na
        string pStyleStr = na
        float currentEmaVal = na
        
        // Dynamically assign variables based on current loop index
        if i == 0
            period := 20
            col := color20
            pWidth := width20
            pStyleStr := style20
            currentEmaVal := ema20
        else if i == 1
            period := 50
            col := color50
            pWidth := width50
            pStyleStr := style50
            currentEmaVal := ema50
        else if i == 2
            period := 100
            col := color100
            pWidth := width100
            pStyleStr := style100
            currentEmaVal := ema100
        else
            period := 200
            col := color200
            pWidth := width200
            pStyleStr := style200
            currentEmaVal := ema200
            
        float multiplier = 2 / (period + 1)
        actualLineStyle = getLineStyle(pStyleStr)
        
        // Project the line segments forward into the blank space
        float baseEma = currentEmaVal
        for step = 1 to extLength by 1
            float nextEmaProjected = (priceSource * multiplier) + (baseEma * (1 - multiplier))
            
            line segment = line.new(
                 x1 = bar_index + step - 1, 
                 y1 = baseEma,
                 x2 = bar_index + step, 
                 y2 = nextEmaProjected,
                 color = col,
                 width = pWidth,
                 style = actualLineStyle
                 )
                 
            array.push(projLines, segment)
            baseEma := nextEmaProjected
````
