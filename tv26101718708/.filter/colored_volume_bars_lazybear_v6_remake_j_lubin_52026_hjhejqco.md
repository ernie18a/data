# Colored Volume Bars [LazyBear] v6 [Remake J. Lubin 5/2026]

- url: https://www.tradingview.com/script/hjHEjQcO-Colored-Volume-Bars-LazyBear-v6-Remake-J-Lubin-5-2026/
- type: indicator
- pine_id: PUB;db41290eca974d50ae424df15c617223
- version: 1.0

## Description

A modernized Pine Script v6 rebuild of LazyBear's classic *Colored Volume Bars* indicator, with new themes, a multi-type volume moving average, and built-in alerts.

The script colors each volume bar based on the relationship between the **current bar and a lookback bar** — comparing both price direction and volume change — to make accumulation, distribution, exhaustion, and stealth moves visually obvious at a glance.

**Color logic**
- **Price Up + Volume Up** → strong bullish (real buying pressure)
- **Price Up + Volume Down** → weak bullish (rally on thin volume)
- **Price Down + Volume Up** → strong bearish (active selling)
- **Price Down + Volume Down** → weak bearish (fading sellers)
- **Neutral** → no clear direction

**Features**
- Pine Script v6, lightweight and fast
- 4 visual themes + fully customizable colors:
  - Classic LazyBear
  - Futuristic Neon
  - Modern Professional
  - Minimal Clean
  - Custom
- Optional volume moving average with **5 MA types**: SMA, EMA, RMA, WMA, TEMA (true triple-EMA formula)
- Adjustable lookback, bar transparency, and MA line width
- Built-in alerts:
  - Bullish confirmation (price up + volume up)
  - Bearish confirmation (price down + volume up)
  - Volume expansion
  - Volume contraction

**How to use**
Add it to any chart and any timeframe. Use it as a confirmation tool alongside price action, trend, or breakout strategies — green/strong-color bars confirm conviction behind a move; weak-color bars warn that momentum may be fading.

**Credits**
Original concept by **LazyBear**. This version is a full v6 rewrite with theming, MA flexibility, and alerts added — original color logic preserved exactly under the "Classic LazyBear" theme.

## Source Code

````pine
//@version=6
indicator("Colored Volume Bars [LazyBear] v6", shorttitle="CVOLB v6", format=format.volume, precision=0)

// ===== GENERAL SETTINGS =====
g_gen     = "General Settings"
lookback  = input.int(10, "Lookback Length", minval=1, maxval=500, group=g_gen, tooltip="Bars back used to compare current price/volume against prior price/volume.")
barTransp = input.int(15, "Bar Transparency", minval=0, maxval=100, group=g_gen, tooltip="0 = solid, 100 = invisible.")

// ===== MOVING AVERAGE SETTINGS =====
g_ma     = "Moving Average Settings"
showMA   = input.bool(false, "Show Volume MA", group=g_ma)
lengthMA = input.int(20, "MA Length", minval=1, maxval=1000, group=g_ma)
maType   = input.string("SMA", "MA Type", options=["SMA", "EMA", "RMA", "WMA", "TEMA"], group=g_ma)
maColor  = input.color(#ffb74d, "MA Color", group=g_ma)
maWidth  = input.int(2, "MA Line Width", minval=1, maxval=5, group=g_ma)

// ===== VISUAL THEME =====
g_theme = "Visual Theme"
theme   = input.string("Modern Professional", "Theme", options=["Classic LazyBear", "Futuristic Neon", "Modern Professional", "Minimal Clean", "Custom"], group=g_theme, tooltip="Pick a preset palette, or choose Custom to apply the colors below.")

custUpUp = input.color(#26a69a, "Custom: Price Up + Volume Up",     group=g_theme)
custUpDn = input.color(#80cbc4, "Custom: Price Up + Volume Down",   group=g_theme)
custDnDn = input.color(#ef9a9a, "Custom: Price Down + Volume Down", group=g_theme)
custDnUp = input.color(#ef5350, "Custom: Price Down + Volume Up",   group=g_theme)
custNeut = input.color(#9e9e9e, "Custom: Neutral",                  group=g_theme)

[cUpUp, cUpDn, cDnDn, cDnUp, cNeut] = switch theme
    "Classic LazyBear"    => [color.green, color.blue, color.orange, color.red, color.gray]
    "Futuristic Neon"     => [#00ff9c, #00e1ff, #ff7a00, #ff2bd6, #6c6c6c]
    "Modern Professional" => [#26a69a, #80cbc4, #ef9a9a, #ef5350, #b0bec5]
    "Minimal Clean"       => [#2e7d32, #a5d6a7, #ef9a9a, #c62828, #cfd8dc]
    => [custUpUp, custUpDn, custDnDn, custDnUp, custNeut]

// ===== CORE LOGIC =====
p2 = close
v2 = volume
p1 = close[lookback]
v1 = volume[lookback]

priceUp = p2 > p1
priceDn = p2 < p1
volUp   = v2 > v1
volDn   = v2 < v1

baseColor = priceUp and volUp ? cUpUp : priceUp and volDn ? cUpDn : priceDn and volDn ? cDnDn : priceDn and volUp ? cDnUp : cNeut
barCol    = color.new(baseColor, barTransp)

// ===== VOLUME MOVING AVERAGE =====
sma_v  = ta.sma(volume, lengthMA)
ema_v  = ta.ema(volume, lengthMA)
rma_v  = ta.rma(volume, lengthMA)
wma_v  = ta.wma(volume, lengthMA)
ema1   = ema_v
ema2   = ta.ema(ema1, lengthMA)
ema3   = ta.ema(ema2, lengthMA)
tema_v = 3 * (ema1 - ema2) + ema3

maVal = switch maType
    "SMA"  => sma_v
    "EMA"  => ema_v
    "RMA"  => rma_v
    "WMA"  => wma_v
    "TEMA" => tema_v
    => sma_v

// ===== PLOTS =====
plot(volume, title="Volume", style=plot.style_columns, color=barCol)
plot(showMA ? maVal : na, title="Volume MA", color=maColor, linewidth=maWidth)

// ===== ALERTS =====
bullConfirm = priceUp and volUp
bearConfirm = priceDn and volUp
volExpand   = volUp
volContract = volDn

alertcondition(bullConfirm, title="Bullish Confirmation (Price Up + Volume Up)", message="CVOLB: Bullish confirmation - price and volume both up vs lookback.")
alertcondition(bearConfirm, title="Bearish Confirmation (Price Down + Volume Up)", message="CVOLB: Bearish confirmation - price down, volume up vs lookback.")
alertcondition(volExpand,   title="Volume Expansion",   message="CVOLB: Volume expanding vs lookback bar.")
alertcondition(volContract, title="Volume Contraction", message="CVOLB: Volume contracting vs lookback bar.")
````
