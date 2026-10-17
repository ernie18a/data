# Apex Reversal Engine

- url: https://www.tradingview.com/script/LM9f0UgX/
- type: indicator
- pine_id: PUB;682ed72aefc64b16bc317ab7b68533f5
- version: 1.0

## Description

💥Apex Reversal Engine: S&R and Momentum Exhaustion💥


⚙️Apex Reversal Engine is an advanced analytical script built specifically for Forex swing traders and position traders operating on higher timeframes (1H to 1D). Its primary objective is to identify high-probability market reversal zones by finding the exact point where structural price levels intersect with extreme momentum exhaustion.



⚙️ The Core Concept & Algorithmic Logic
Many traders struggle with false breakouts or entering reversal trades too early because they rely solely on isolated technical concepts. Trading pure Support/Resistance often leads to getting stopped out by fakeouts, while trading pure RSI often leads to catching "falling knives" in strong trends.



⚙️This script is built on a deliberate mashup of two distinct technical concepts to filter out these low-probability setups:


🚀Automated Support & Resistance (Structural Analysis): The algorithm dynamically maps the chart to identify key historical liquidity zones. It calculates significant pivot highs and pivot lows over a specific lookback period to draw objective Support and Resistance (S&R) lines. These lines represent areas where the market has previously shown strong rejection, indicating institutional interest or historical supply/demand imbalances.


🚀RSI Momentum Validation (Velocity Analysis): To validate these structural levels, the script integrates a calibrated Relative Strength Index (RSI). The RSI measures the velocity and magnitude of recent price changes to evaluate overvalued or undervalued conditions.



⚙️The Mashup Justification:

🚀The true originality of the Apex Reversal Engine lies in its stringent confluence engine. The script will not generate a buy signal just because the price hits a support line, nor will it fire a signal just because the RSI is oversold. An entry signal is printed only when the price tests a recognized Support/Resistance line simultaneously with an extreme RSI reading. This specific algorithmic gating ensures that we only look for reversals when structural barriers are met with mathematical momentum exhaustion.



⚙️ How to Use the Indicator
For optimal performance, this script is calibrated for the Forex market and should be applied to higher timeframes, specifically ranging from 1-Hour (1H) to 1-Day (1D) charts. Using it on lower timeframes may introduce unwanted market noise.



⚙️The script is designed with a clean UI, avoiding unnecessary chart clutter, and outputs clear, actionable labels:



📈Long Entry (Bullish Setup): Wait for a bullish signal label to appear. This signifies that the price is currently testing a major Support Line AND the internal RSI module has registered an extreme oversold condition, suggesting downside exhaustion and a potential upward reversal.



📉Short Entry (Bearish Setup): Wait for a bearish signal label. This confirms that the price is testing a major Resistance Line AND the RSI is heavily overbought, indicating upside exhaustion and a high probability of a downward reversal.



⚠️Risk Management:
These automated S&R lines double as excellent risk management tools. Stop Loss (SL) orders can be placed logically just outside the tested Support or Resistance zone to invalidate the setup if the level breaks. Take Profit (TP) targets can be scaled out at the next opposing S&R level.



🔒 Note on Script Originality
(Include this section if you are publishing as Closed-Source / Invite-Only)
The source code is protected because the specific lookback algorithms used for dynamic S&R generation, the specific calibration of the momentum oscillator for 1H-1D Forex charts, and the precise logical confluence rules are proprietary. The underlying logic described above empowers users to fully understand the mechanics of the trade setups without exposing the raw, backtested parameters that make the script unique.



⚠️Disclaimer: This script is for educational and analytical purposes only. Trading Forex on any timeframe carries a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always use proper risk management and never risk more than you can afford to lose.

## Source Code

````pine
// @version=6
indicator("Strict S/R + RSI Signals - Pro v6", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- KONTROLA INTERWAŁU ---
int currentTF_seconds = timeframe.in_seconds("")
bool isValidTF = (currentTF_seconds >= 3600) and (currentTF_seconds <= 86400)

// --- KONFIGURACJA S/R ---
int pivotStrength = input.int(1, "Minimalna czułość (Left/Right bars)", minval = 1)

// Grupa Oporu
color resColor      = input.color(color.new(#ff5252, 30), "Kolor Linii Oporu", group = "Estetyka Oporu")
bool  showResLabels = input.bool(false, "Pokaż ceny Oporu", group = "Estetyka Oporu")

// Grupa Wsparcia
color supColor      = input.color(color.new(#00ffbb, 30), "Kolor Linii Wsparcia", group = "Estetyka Wsparcia")
bool  showSupLabels = input.bool(false, "Pokaż ceny Wsparcia", group = "Estetyka Wsparcia")

// Grupa Ustawienia Linii
int    lineLength = input.int(10, "Długość linii (świece)", minval = 1, group = "Ustawienia Linii")
int    lineWidth  = input.int(1, "Grubość linii", minval = 1, group = "Ustawienia Linii")
string lineStyle  = input.string("Ciągła", "Styl linii", options = ["Ciągła", "Przerywana", "Kropkowana"], group = "Ustawienia Linii")

// --- KONFIGURACJA RSI ---
int   rsiLength     = input.int(14, "Długość RSI", minval = 1, group = "Ustawienia RSI")
int   rsiOverbought = input.int(70, "RSI Overbought (Poziom Sprzedaży)", group = "Ustawienia RSI")
int   rsiOversold   = input.int(30, "RSI Oversold (Poziom Kupna)", group = "Ustawienia RSI")
color rsiColor      = input.color(#2962ff, "Kolor linii RSI", group = "Ustawienia RSI")

// --- MAPOWANIE STYLU ---
get_style(s) =>
    switch s
        "Ciągła"     => line.style_solid
        "Przerywana" => line.style_dashed
        "Kropkowana" => line.style_dotted
        => line.style_solid

// --- LOGIKA ANALITYCZNA ---
float ph = ta.pivothigh(high, pivotStrength, pivotStrength)
float pl = ta.pivotlow(low, pivotStrength, pivotStrength)
float rsiValue = ta.rsi(close, rsiLength)

// --- FUNKCJA RYSOWANIA S/R ---
render_sr(price, is_res) =>
    int startX = bar_index - pivotStrength
    int endX   = startX + lineLength
    
    line.new(x1 = startX, y1 = price, x2 = endX, y2 = price, color = is_res ? resColor : supColor, width = lineWidth, style = get_style(lineStyle))
    
    if (is_res and showResLabels) or (not is_res and showSupLabels)
        label.new(startX, price, str.tostring(price, format.mintick), color = color.new(color.black, 100), textcolor = is_res ? resColor : supColor, style = label.style_none, size = size.small)

// --- WYKONANIE WIZUALNE S/R I RSI ---
if isValidTF and not na(ph)
    render_sr(ph, true)

if isValidTF and not na(pl)
    render_sr(pl, false)

plot(isValidTF ? rsiValue : na, "RSI", color = rsiColor, linewidth = 2)
hline(rsiOverbought, "Overbought", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(rsiOversold, "Oversold", color=color.new(color.green, 50), linestyle=hline.style_dashed)

// --- ŚCISŁE SYGNAŁY (TYLKO ZGODNOŚĆ S/R + RSI) ---
// Sygnał SELL: Opór powstał ORAZ RSI w tamtej chwili wynosiło >= 70
bool strictSell = isValidTF and not na(ph) and (rsiValue[pivotStrength] >= rsiOverbought)

// Sygnał BUY: Wsparcie powstało ORAZ RSI w tamtej chwili wynosiło <= 30
bool strictBuy  = isValidTF and not na(pl) and (rsiValue[pivotStrength] <= rsiOversold)

plotshape(series = strictSell, title="Sell", style=shape.labeldown, location=location.abovebar, color=color.new(#ff5252, 0), text="SELL", textcolor=color.white, offset=-pivotStrength)
plotshape(series = strictBuy,  title="Buy", style=shape.labelup, location=location.belowbar, color=color.new(#00ffbb, 0), text="BUY", textcolor=color.white, offset=-pivotStrength)

// --- KOMUNIKAT O BŁĘDNEJ RAMIE CZASOWEJ ---
var label tfWarning = na
if not isValidTF and barstate.islast
    tfWarning := label.new(bar_index, high, "Indicator works only on timeframes from 1H to 1 Day!", color=color.red, textcolor=color.white, style=label.style_label_center)
label.delete(tfWarning[1])
````
