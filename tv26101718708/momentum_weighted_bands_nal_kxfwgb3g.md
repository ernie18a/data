# Momentum Weighted Bands | NAL

- url: https://www.tradingview.com/script/KXfWgB3g-Momentum-Weighted-Bands-NAL/
- type: indicator
- pine_id: PUB;b3c58649e25a4e8bb91f08d49aa0cb44
- version: 1.0

## Description

[b]1. Overview
[/b]
[i]Momentum Weighted Bands | NAL[/i] is an adaptive trend indicator utilizing volatility bands that follow momentum. Instead of using one fixed band multiplier at all times, it studies the current momentum environment and adjusts the bands tightness dynamically.

[b]2. Calculation
[/b]
The indicator starts by calculating RSI as its momentum engine. It then subtracts an EMA of that RSI to create a momentum residual, showing whether momentum is stronger or weaker than its own recent average.

That residual is ranked using percent rank. The stronger the momentum residual is compared to recent history, the more the band multiplier shifts between the minimum and maximum values.

The final bands are built as:

[pine]base    = ta.ema(src, len_base)
sd_base = ta.stdev(base, sdl_base)
mul     = min_base + (max_base - min_base) * rank_res

upper   = base + sd_base * mul
lower   = base - sd_base * mul[/pine]
A bullish state triggers when price closes above the upper band. A bearish state triggers when price closes below the lower band.

[b]3. Key Features
[/b][list]
[*]Volatility bands adaptive to momentum conditions.
[*]Filters noise through confluence.
[*]Clean trend-state visualization with visual options.
[/list]
[b]4. Use
[/b]
Use it to quickly identify when price is escaping its normal momentum-adjusted range. Above the upper band suggests bullish expansion, below the lower band suggests bearish expansion, and movement inside the bands means price has not yet confirmed a new directional regime.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sewwman

//@version=6
indicator("Momentum Weighted Bands | NAL", shorttitle = "Momentum Weighted Bands", precision = 2, overlay = true)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals & Tooltips ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard"  => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"    => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

mom_tp  = "Determines how many bars back the indicator looks to determine the percentage of how many previous values were less than or equal to the current value of momentum."
mul1_tp = "Sets the maximum possible multiple which can be set through by the momentum engine."
mul2_tp = "Sets the minimum possible multiple which can be set through by the momentum engine."

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

//Momentum
G                = "Momentum Core"
len_rsi          = input.int(20, "Momentum Length", group = G)
loo_mom          = input.int(50, "Momentum Rank Lookback", group = G, tooltip = mom_tp)

//Baseline
G2               = "Baseline Core"
len_base         = input.int(20, "EMA Base Length", group = G2)
sdl_base         = input.int(30, "Volatility Length", group = G2)
max_base         = input.float(2.5, "Max Multiple", group = G2, step = 0.1, tooltip = mul1_tp)
min_base         = input.float(1.5, "Min Multiple", group = G2, step = 0.1, tooltip = mul2_tp)
src              = input.source(close, "Source")

// ══════════════════════════════════════ ◈ Logic ◈ ══════════════════════════════════════

//Momentum Calculations
momentum    = ta.rsi(src, len_rsi)
momentum_ma = ta.ema(momentum,len_rsi)
residual    = ta.ema(momentum - momentum_ma, len_rsi)
rank_res    = ta.percentrank(residual, loo_mom) / 100.0

mul         = min_base + (max_base - min_base) * rank_res

//Baseline Calculations
base        = ta.ema(src, len_base)
sd_base     = ta.stdev(base, sdl_base)

//Bands
upper   = base + sd_base * mul
lower   = base - sd_base * mul

//Signal
Long_mom  = close > upper
Short_mom = close < lower

var NAL = 0

if Long_mom and not Short_mom
    NAL := 1
    NAL

if Short_mom
    NAL := -1
    NAL

// ══════════════════════════════════════ ◈ Plots & Trend Definition ◈ ══════════════════════════════════════

color col = col_nu
col := close > upper ? col_up : close < lower ? col_dn : col[1]

mid = math.avg(upper, lower)
u = plot(upper,color = col, display = display.status_line)
l = plot(lower,color = col, display = display.status_line)
m = plot(mid ,color = color.white, display = display.none)

//Fills
fill(u, m, upper, mid,  color.new(col, 30), color.new(col, 100))
fill(l, m, lower, mid,  color.new(col, 30), color.new(col, 100))

plotcandle(open, high, low, close, "Bar Color", col, col, bordercolor = col, display = display.pane)
````
