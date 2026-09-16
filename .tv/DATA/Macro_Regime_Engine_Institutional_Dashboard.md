<!-- tradingview-pine-id: PUB;dbbd6e939003488dbcbc9e2da12d9ac3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Macro Regime Engine - Institutional Dashboard

Source: https://www.tradingview.com/script/r4XpSxTc-Macro-Regime-Engine-Institutional-Dashboard/

## Description

English Description:

The "Macro Regime Engine" is an institutional-grade quantitative tool designed to identify market regimes using cross-asset intermarket dynamics. 

Rather than relying on traditional lagging technical indicators, this dashboard evaluates the Volatility-Adjusted Momentum Score (VAMS) across six key financial pillars: Equity Markets, Crypto Assets, Energy/Commodities, the US Dollar, Volatility, and Interest Rates.

** How It Works:

The engine applies a non-repainting VAMS calculation across six major intermarket assets:
1. **S&P 500 (SPX)** - Equity Growth
2. **Bitcoin (BTCUSDT)** - High-Beta / Liquidity Appetite
3. **WTI Crude Oil (USOIL)** - Inflationary Pressures / Demand
4. **US Dollar Index (DXY)** - Global Liquidity & Dollar Strength
5. **CBOE Volatility Index (VIX)** - Market Risk Perception
6. **10-Year Treasury Yield (US10Y)** - Cost of Capital & Rates Environment

Based on a voting mechanism, the indicator classifies the market into 4 primary economic regimes:

- Goldilocks (Green): Stable growth, low volatility. Optimal environment for equities and long positions.
- Reflation (Blue): Economic expansion with moderate price increases. Bullish bias.
- Inflation (Orange): Rising commodity and yields pressure. Caution and position reduction recommended.
- Deflation (Red): Spiking volatility and broader market contraction. Risk-off regime.

** Key Features:

- Non-Repainting Logic: Uses closed-bar data (`close[1]`) for intermarket requests to ensure historical accuracy without lookahead bias.
- **Regime Confirmation Filter:** Implements a confirmation threshold to filter out short-term market noise (whipsaws).
- **Customizable Dashboard:** Fully customizable visual table overlay and background regime highlighting.

** Best Uses:

Optimized as a top-down contextual filter for S&P 500 Futures (ES1!), SPY, NQ1!, and BTC. Use this dashboard to align your tactical short-term setups with the broader macro regime.

---

## Source Code

````pine
//@version=6
indicator("Macro Regime Engine - Institutional Dashboard",
     overlay=true)

// ==========================
// INPUTS
// ==========================
lookback    = input.int(90,  title="Momentum Lookback", group="Configuración Macro")
volLength   = input.int(90,  title="Volatility Length", group="Configuración Macro")
threshold   = input.float(0.5, title="VAMS Threshold", group="Configuración Macro")
confirmBars = input.int(5,   title="Regime Confirmation Bars", group="Configuración Macro")

showBg      = input.bool(true, title="Color de fondo según Régimen", group="Visualización")
showTable   = input.bool(true, title="Mostrar Tabla Dashboard", group="Visualización")
tablePos    = input.string("Arriba Derecha", title="Posición del Dashboard", 
              options=["Arriba Derecha", "Arriba Izquierda", "Abajo Derecha", "Abajo Izquierda", "Centro Derecha"], group="Visualización")

// ==========================
// HELPER: POSICIÓN DE TABLA
// ==========================
get_table_pos(string pos) =>
    switch pos
        "Arriba Derecha"   => position.top_right
        "Arriba Izquierda" => position.top_left
        "Abajo Derecha"    => position.bottom_right
        "Abajo Izquierda"  => position.bottom_left
        => position.middle_right

// ==========================
// FUNCTION: VAMS
// ==========================
f_vams(_src) =>
    ret = math.log(_src / _src[lookback])
    vol = ta.stdev(math.log(_src / _src[1]), volLength)
    vol == 0 ? 0 : ret / vol

bull(x) => x > threshold
bear(x) => x < -threshold

// ==========================
// MACRO DATA (NON-REPAINT V6)
// ==========================
spx   = request.security("SP:SPX", timeframe.period, close[1], ignore_invalid_symbol=true)
btc   = request.security("BINANCE:BTCUSDT", timeframe.period, close[1], ignore_invalid_symbol=true)
oil   = request.security("TVC:USOIL", timeframe.period, close[1], ignore_invalid_symbol=true)
dxy   = request.security("TVC:DXY", timeframe.period, close[1], ignore_invalid_symbol=true)
vix   = request.security("CBOE:VIX", timeframe.period, close[1], ignore_invalid_symbol=true)
us10y = request.security("TVC:US10Y", timeframe.period, close[1], ignore_invalid_symbol=true)

// ==========================
// CALCULATE VAMS
// ==========================
spx_v   = f_vams(spx)
btc_v   = f_vams(btc)
oil_v   = f_vams(oil)
dxy_v   = f_vams(dxy)
vix_v   = f_vams(vix)
us10y_v = f_vams(us10y)

// ==========================
// VOTING SYSTEM
// ==========================
int gold = 0
int refl = 0
int infl = 0
int defl = 0

// Growth
if bull(spx_v)
    gold += 1
    refl += 1
if bear(spx_v)
    infl += 1
    defl += 1

if bull(btc_v)
    gold += 1
    refl += 1
if bear(btc_v)
    infl += 1
    defl += 1

// Commodities
if bull(oil_v)
    refl += 1
    infl += 1
if bear(oil_v)
    gold += 1
    defl += 1

// Dollar
if bull(dxy_v)
    defl += 1
    infl += 1
if bear(dxy_v)
    gold += 1
    refl += 1

// Volatility
if bull(vix_v)
    infl += 1
    defl += 1
if bear(vix_v)
    gold += 1
    refl += 1

// Rates
if bull(us10y_v)
    refl += 1
    infl += 1
if bear(us10y_v)
    gold += 1
    defl += 1

// ==========================
// DETERMINE REGIME + STRENGTH
// ==========================
maxVotes = math.max(math.max(gold, refl), math.max(infl, defl))
secondVotes = math.max(
     gold != maxVotes ? gold : 0,
     math.max(refl != maxVotes ? refl : 0,
     math.max(infl != maxVotes ? infl : 0,
              defl != maxVotes ? defl : 0)))

regimeStrength = maxVotes - secondVotes

// 1: Goldilocks, 2: Reflation, 3: Inflation, 4: Deflation
regime = gold == maxVotes ? 1 : refl == maxVotes ? 2 : infl == maxVotes ? 3 : 4

// ==========================
// CONFIRMATION FILTER
// ==========================
var int regimeCount = 0
var int activeRegime = 0

regimeCount := regime == regime[1] ? regimeCount[1] + 1 : 1
activeRegime := regimeCount >= confirmBars ? regime : activeRegime[1]

// ==========================
// VISUAL OUTPUTS
// ==========================
color colorGold   = color.rgb(76, 175, 80, 85)   // Verde (Goldilocks / Risk-On)
color colorRefl   = color.rgb(33, 150, 243, 85)  // Azul (Reflación)
color colorInfl   = color.rgb(255, 152, 0, 85)   // Naranja (Inflación)
color colorDefl   = color.rgb(244, 67, 54, 85)   // Rojo (Deflación / Risk-Off)

color currentBg = activeRegime == 1 ? colorGold :
                  activeRegime == 2 ? colorRefl :
                  activeRegime == 3 ? colorInfl : colorDefl

bgcolor(showBg ? currentBg : na, title="Color Fondo Régimen Macro")

// ==========================
// DASHBOARD TABLE
// ==========================
var table regimeTable = table.new(get_table_pos(tablePos), 2, 7, bgcolor=color.new(color.black, 20), border_width=1)

if barstate.islast and showTable
    table.set_position(regimeTable, get_table_pos(tablePos))

    string regimeName = ""
    color activeColor = color.white

    if activeRegime == 1
        regimeName  := "Goldilocks (Risk-On)"
        activeColor := color.green
    else if activeRegime == 2
        regimeName  := "Reflation (Bullish)"
        activeColor := color.blue
    else if activeRegime == 3
        regimeName  := "Inflation (Caution)"
        activeColor := color.orange
    else
        regimeName  := "Deflation (Risk-Off)"
        activeColor := color.red

    table.cell(regimeTable, 0, 0, "Métrica Macro", text_color=color.gray, text_size=size.small)
    table.cell(regimeTable, 1, 0, "Votos", text_color=color.gray, text_size=size.small)

    table.cell(regimeTable, 0, 1, "Goldilocks", text_color=color.white)
    table.cell(regimeTable, 1, 1, str.tostring(gold), text_color=color.white)

    table.cell(regimeTable, 0, 2, "Reflación", text_color=color.white)
    table.cell(regimeTable, 1, 2, str.tostring(refl), text_color=color.white)

    table.cell(regimeTable, 0, 3, "Inflación", text_color=color.white)
    table.cell(regimeTable, 1, 3, str.tostring(infl), text_color=color.white)

    table.cell(regimeTable, 0, 4, "Deflación", text_color=color.white)
    table.cell(regimeTable, 1, 4, str.tostring(defl), text_color=color.white)

    table.cell(regimeTable, 0, 5, "Fuerza Señal", text_color=color.white)
    table.cell(regimeTable, 1, 5, str.tostring(regimeStrength), text_color=color.white)

    table.cell(regimeTable, 0, 6, "Régimen Activo", text_color=activeColor)
    table.cell(regimeTable, 1, 6, regimeName, text_color=activeColor)
````
