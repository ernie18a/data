<!-- tradingview-pine-id: PUB;70e2a98e61344d91b4bb9e65b2bb21b8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dealer Gamma Regime Proxy

Source: https://www.tradingview.com/script/q7T7jDH1-Dealer-Gamma-Regime-Proxy/

## Description

** Overview:

The "Dealer Gamma Regime Proxy" provides a quantitative estimation of Market Maker / Dealer Gamma Exposure (GEX) dynamics by evaluating structural volatility compression and expansion cycles.

In options markets, Dealer Gamma position dictates how market makers hedge their underlying Delta:

- Long Gamma (+GEX): Dealers trade *against* the trend (buying dips, selling rallies), suppressing market volatility and creating mean-reverting environments.

- Short Gamma (-GEX): Dealers trade *with* the trend (selling into drops, buying into rallies), accelerating price moves and increasing volatility.

** Key Features & Methodology:

1. Volatility Ratio Proxy:

- Compares short-term ATR (14) against its long-term baseline SMA (50).
- Long Gamma Regime (Green Overlay): ATR is below baseline. Indicates volatility suppression, tight consolidations, or steady upward grinds.
- Short Gamma Regime (Red Overlay): ATR spikes above baseline. Indicates market maker delta-hedging acceleration, breakout potential, or heightened risk of sharp liquidations.

2. Integrated VWAP Bands:

- Plots Session VWAP alongside standard deviation bands to serve as high-probability mean-reversion targets during Long Gamma regimes.

3. Institutional Real-Time Dashboard:

- Displays current regime status, volatility ratio, and tactical execution environment directly on your chart overlay.

** Practical Applications:

- Long Gamma Environments (Green): Favor mean-reversion setups, grid trading, and buying VWAP band bounces.
- Short Gamma Environments (Red): Favor trend-following breakouts, momentum trades, and wider stop-losses due to increased volatility.
- Asset Compatibility: Highly effective for options-heavy assets including S&P 500 (ES1! / SPY), Nasdaq 100 (NQ1! / QQQ), and Mega-Cap Equities (AAPL, TSLA, NVDA).

---

## Source Code

````pine
//@version=6
indicator("Dealer Gamma Regime Proxy", 
     overlay=true, 
     shorttitle="Gamma_Proxy")

// ==============================================================================
// 1. INPUTS & CONFIGURATION
// ==============================================================================
group_gamma = "Gamma Proxy Parameters"
atrLen      = input.int(14, "ATR Length", group=group_gamma)
atrMaLen    = input.int(50, "ATR Baseline MA Length", group=group_gamma)

group_vwap  = "VWAP Levels"
showVwap    = input.bool(true, "Show Session VWAP & Bands", group=group_vwap)

group_vis   = "Visual Settings"
tablePos    = input.string("Arriba Derecha", "Dashboard Position", 
              options=["Arriba Derecha", "Arriba Izquierda", "Abajo Derecha", "Abajo Izquierda"], group=group_vis)

// Position Mapping
get_pos(string p) =>
    switch p
        "Arriba Derecha"   => position.top_right
        "Arriba Izquierda" => position.top_left
        "Abajo Derecha"    => position.bottom_right
        "Abajo Izquierda"  => position.bottom_left
        => position.top_right

// ==============================================================================
// 2. CALCULATIONS
// ==============================================================================
// VWAP & Bands
vwapVal = ta.vwap
stdev   = ta.stdev(close, 20)
upperB  = vwapVal + stdev
lowerB  = vwapVal - stdev

// ATR Volatility Dynamics (Gamma Proxy)
atrVal  = ta.atr(atrLen)
atrMA   = ta.sma(atrVal, atrMaLen)

// Volatility Ratio (Proxy for Gamma Strength)
gammaRatio = atrMA != 0 ? atrVal / atrMA : 1.0

bool longGamma  = atrVal < atrMA  // Low Volatility / Volatility Suppression
bool shortGamma = atrVal > atrMA  // High Volatility / Volatility Expansion

// ==============================================================================
// 3. VISUAL OUTPUTS
// ==============================================================================
// Plot VWAP
plot(showVwap ? vwapVal : na, "Session VWAP", color=color.blue, linewidth=2)
plot(showVwap ? upperB : na, "VWAP Upper Band", color=color.new(color.blue, 60))
plot(showVwap ? lowerB : na, "VWAP Lower Band", color=color.new(color.blue, 60))

// Background Highlight
color bgCol = shortGamma ? color.new(color.red, 88) : longGamma ? color.new(color.green, 88) : na
bgcolor(bgCol, title="Gamma Regime Background")

// ==============================================================================
// 4. DASHBOARD TABLE
// ==============================================================================
var table dash = table.new(get_pos(tablePos), 2, 4, bgcolor=color.new(color.black, 20), border_width=1)

if barstate.islast
    table.set_position(dash, get_pos(tablePos))
    
    string regimeTitle = longGamma ? "LONG GAMMA (Estable)" : "SHORT GAMMA (Volátil)"
    color  regimeColor = longGamma ? color.green : color.red
    string environment = longGamma ? "Mean Reversion / Buy Dips" : "Directional Expansion / Breakouts"

    table.cell(dash, 0, 0, "GAMMA REGIME PROXY", bgcolor=color.blue, text_color=color.white)
    table.cell(dash, 1, 0, "Métrica", bgcolor=color.blue, text_color=color.white)

    table.cell(dash, 0, 1, "Régimen Dealer", text_color=color.white)
    table.cell(dash, 1, 1, regimeTitle, bgcolor=regimeColor, text_color=color.white)

    table.cell(dash, 0, 2, "Ratio Volatilidad", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(gammaRatio, "#.##"), text_color=color.white)

    table.cell(dash, 0, 3, "Entorno Sugerido", text_color=color.white)
    table.cell(dash, 1, 3, environment, text_color=color.yellow)
````
