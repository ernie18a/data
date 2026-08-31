<!-- tradingview-pine-id: PUB;55206f45dfee40df875b08d361d49de7 -->
<!-- tradingviewscripts-format: 1 -->
# Trend & Structure Matrix

Source: https://www.tradingview.com/script/7iL5NWIR-Trend-Structure-Matrix/

## Description

Trend & Structure Matrix: The Ultimate Breakout Filter

Tired of getting caught in fakeouts when trading breakouts? The Trend & Structure Matrix is designed to solve exactly that. Instead of cluttering your chart with traditional moving averages, this tool translates raw price action into pure momentum and market structure levels. It gives you a crystal-clear visual of when a breakout is actually backed by the broader trend, keeping you on the right side of the market.

☕ If this indicator helps you optimize your charts and catch better trades, consider supporting my work! Buy me a coffee here: https://ko-fi.com/tradeguru/
(Need a custom indicator tailored to your specific trading plan? Send me a direct message for custom Pine Script development!)

🧠 The Logic Behind the Matrix
This indicator removes the standard MA jargon to force your focus onto what truly matters: Structure and Momentum. We've replaced standard lengths and timeframes with Sensitivity Levels and Ranges to keep your analysis strictly focused on price behavior.

Level 1 & Level 2 (Momentum Cloud): These levels track the fast and slow momentum. The dynamic cloud between them shifts from green to red, providing immediate visual confirmation of the current trend direction.

Level 3 (Market Structure): This is your ultimate filter. While the cloud captures the immediate momentum, Level 3 defines the overarching market structure. When the price breaks and closes above or below this level, it signals a high-probability structural breakout rather than a temporary fakeout.

📈 Ideal Use Cases
This setup is incredibly powerful for short-term breakout plans, such as morning breakout strategies on volatile assets like Gold. By aligning the fast intraday momentum (Ranges 1 & 2) with the Daily market structure (Range 3), you can easily filter out the noise and only execute trades when the micro-trend perfectly aligns with the macro-structure.

⚙️ Key Features
Proprietary Range Settings: Choose from Range 1 through 5 to seamlessly blend lower and higher timeframe data without the hassle of manual timeframe inputs.

All-in-One Space Saver: Free TradingView users are limited to just 3 indicators per chart. This script bundles three distinct, multi-timeframe structural levels and a dynamic momentum cloud into a single slot!

Built-in Alerts: Never miss a valid setup. The script includes automated alert conditions for when the price officially breaks out (Up) or breaks down (Down) through the Level 3 Market Structure.

---

## Source Code

````pine
// © jan80hansen

//@version=6
indicator("Trend & Structure Matrix", overlay = true)

// -----------------------------------------------------------------------------
// RANGE CONVERTER FUNCTION
// Gjør om tekstvalgene til faktiske tidsrammer som TradingView forstår
// -----------------------------------------------------------------------------
get_range_tf(range_val) =>
    string tf = "60" // Default til 1H
    if range_val == "Range 1"
        tf := "60"
    else if range_val == "Range 2"
        tf := "240"
    else if range_val == "Range 3"
        tf := "D"
    else if range_val == "Range 4"
        tf := "W"
    else if range_val == "Range 5"
        tf := "M"
    tf

// -----------------------------------------------------------------------------
// INPUTS
// -----------------------------------------------------------------------------

// -- Linje 1 (Rask Breakout / Momentum) --
gp1      = "Level 1 (Fast Momentum)"
sens1    = input.int(3, title="Sensitivity Level", minval=1, group=gp1)
range1   = input.string("Range 1", title="Range", options=["Range 1", "Range 2", "Range 3", "Range 4", "Range 5"], group=gp1)
col1     = input.color(color.new(color.green, 50), title="Line Color", group=gp1)
thick1   = input.int(1, title="Thickness", minval=1, maxval=5, group=gp1)

// -- Linje 2 (Treg Breakout / Momentum) --
gp2      = "Level 2 (Slow Momentum)"
sens2    = input.int(5, title="Sensitivity Level", minval=1, group=gp2)
range2   = input.string("Range 2", title="Range", options=["Range 1", "Range 2", "Range 3", "Range 4", "Range 5"], group=gp2)
col2     = input.color(color.new(color.red, 50), title="Line Color", group=gp2)
thick2   = input.int(1, title="Thickness", minval=1, maxval=5, group=gp2)

// -- Linje 3 (Markedsstruktur) --
gp3      = "Level 3 (Market Structure)"
sens3    = input.int(3, title="Sensitivity Level", minval=1, group=gp3)
range3   = input.string("Range 3", title="Range", options=["Range 1", "Range 2", "Range 3", "Range 4", "Range 5"], group=gp3)
col3     = input.color(color.new(color.yellow, 50), title="Line Color", group=gp3)
thick3   = input.int(1, title="Thickness", minval=1, maxval=5, group=gp3)

// -- Sky / Cloud --
gp_cloud = "Momentum Cloud Settings"
show_cloud = input.bool(true, title="Show Momentum Cloud", group=gp_cloud)
col_bull = input.color(color.new(color.green, 85), title="Bullish Cloud", group=gp_cloud)
col_bear = input.color(color.new(color.red, 85), title="Bearish Cloud", group=gp_cloud)

// -----------------------------------------------------------------------------
// CALCULATIONS
// Henter data basert på usynlige EMA-kalkulasjoner med lukking (close)
// -----------------------------------------------------------------------------
tf1 = get_range_tf(range1)
tf2 = get_range_tf(range2)
tf3 = get_range_tf(range3)

// request.security henter tidsrammen, ta.ema kjører matematikken under panseret
val1 = request.security(syminfo.tickerid, tf1, ta.ema(close, sens1))
val2 = request.security(syminfo.tickerid, tf2, ta.ema(close, sens2))
val3 = request.security(syminfo.tickerid, tf3, ta.ema(close, sens3))

// -----------------------------------------------------------------------------
// PLOTTING
// -----------------------------------------------------------------------------
p1 = plot(val1, title="Level 1", color=col1, linewidth=thick1)
p2 = plot(val2, title="Level 2", color=col2, linewidth=thick2)
p3 = plot(val3, title="Structure Level", color=col3, linewidth=thick3)

// Fyller skyen mellom Level 1 og Level 2 dynamisk
fill_color = val1 > val2 ? col_bull : col_bear
fill(p1, p2, title="Momentum Cloud", color=show_cloud ? fill_color : na)

// -----------------------------------------------------------------------------
// ALERTS (Valgfritt)
// -----------------------------------------------------------------------------
alertcondition(ta.crossover(close, val3), title="Structure Breakout (Up)", message="Price closed above Market Structure!")
alertcondition(ta.crossunder(close, val3), title="Structure Breakdown (Down)", message="Price closed below Market Structure!")
````
