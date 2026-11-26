# Advanced Fear & Greed Cycle (Quant Model)

- url: https://www.tradingview.com/script/v0EPi2Tf/
- type: indicator
- pine_id: PUB;573c79ec604c4195bd0025269edd08e8
- version: 1.0

## Description

## Overview
The **Advanced Fear & Greed Cycle (Quant Model) v6** is a pure quantitative oscillator designed to decode market sentiment by measuring the architectural divergence between smart money accumulation and retail distribution. Fully upgraded to Pine Script v6, this script addresses standard oscillator limitations by implementing dynamic time-frequency normalization ($0-100$ fixed scale).

Unlike standard sentiment proxies, this model filters out price-action noise by isolating volume flows, directional volatility, and mean-reversion extensions simultaneously.

---

## Mathematical Architecture & Core Engines

### 1. Directional Volatility Engine
Standard models treat volatility expansions as pure panic. This algorithm isolates **Directional Volatility**:
- A 14-period Average True Range (ATR) is mathematically normalized over a dynamic 90-day rolling quarter (`lookback`).
- **Trend Filter:** Volatility is converted into the `vol_fear` metric **only** if the closing price is below its 14-period Simple Moving Average (`is_descending`). Upside expansions (bullish breakouts) are correctly filtered out to prevent false panic readings.

### 2. Normalized Volume & Flow Sentiment
Liquidity and order-flow tracking are computed via a three-layered matrix:
- Normalized Volume spikes relative to the quarterly window.
- Inside-candle Selling Pressure ([symbol="AMEX:HIGH"]AMEX:HIGH[/symbol] - Close$ versus the overall candle range).
- A normalized On-Balance Volume (OBV) structure to track mathematical capital inflows and outflows.

### 3. Boundary-Proof Macro Extension (Mayer Proxy)
To track cyclical overextensions, the script calculates the asset's percentage distance from its long-term moving average (SMA 200 on Daily, SMA 40 on Weekly charts). 
To solve the scale break-out issue (where different assets experience wildly different percentage extensions), a **MinMax Normalization** is applied. This compresses the structural extension into a bound $0-100\%$ scale (`extension_norm`) based on the rolling quarter's extremes.

---

## The Greed Score Synthesizer
The final plotting line is the **Greed Score**, a mathematically symmetric index calculated as:
$$\text{Greed Score} = \frac{(100 - \text{Fear Index}) + \text{Extension Norm}}{2}$$

This creates a fixed-bound oscillator ($0$ to $100$) that charts three distinct market phases:

- 🟢 **INSTITUTIONAL ACCUMULATION (Green Zone / < 20):** High systemic fear combined with compressed macro price extensions (< 25%). Smart money absorbs panicking retail order flow near historical value areas.
- ⚪ **NEUTRAL REGIME (Gray Line):** Symmetrical equilibrium where supply and demand are balanced.
- 🔴 **RETAIL FOMO / BUBBLE (Red Zone / > 80):** Zero systemic fear combined with extreme quarterly price overextensions. Retail traders buying the top driven by euphoria, highlighting distribution blocks.

---

## Display Dashboard & Custom Parameters
The top-right informational panel provides real-time diagnostic outputs of the quantitative data (Current Cycle State, Exact Greed Score, and Normalized Extension %). Traders can adjust the `Soglia Bolla Normalizzata` input to calibrate the macro-exhaustion scanner to specific asset classes (Equities, Forex, or Cryptocurrencies).

---
Disclaimer: This tool calculates mathematical probabilities based on normalized historical structures. It does not provide definitive buy/sell signals or financial advice. Always integrate sound risk management protocols.

## Source Code

````pine
//@version=6
indicator("Advanced Fear & Greed Cycle (Quant Model) v6", overlay=false)

// ==========================================
// 1. CONFIGURAZIONE LOOKBACK DINAMICO
// ==========================================
bar_duration = na(time[1]) ? 0 : time - time[1]
int three_months_ms = 90 * 24 * 60 * 60 * 1000
int lookback = bar_duration > 0 ? math.floor(three_months_ms / bar_duration) : 90
lookback := math.max(math.min(lookback, 5000), 20)

// ==========================================
// 2. MOTORE DI VOLATILITÀ E FLUSSO (NORMALIZZATO)
// ==========================================
// ATR Normalizzato
float shortcut_atr = ta.atr(14)
float max_atr = ta.highest(shortcut_atr, lookback)
float min_atr = ta.lowest(shortcut_atr, lookback)
float atr_norm = (max_atr - min_atr) > 0 ? (shortcut_atr - min_atr) / (max_atr - min_atr) : 0.0

// Direzione del trend a breve termine per qualificare la volatilità
bool is_descending = close < ta.sma(close, 14)

// La volatilità genera "Paura" solo se il trend è discendente, altrimenti è compressione o espansione sana
float vol_fear = is_descending ? atr_norm * 100.0 : 0.0

// Pressione di Vendita e Flusso Volumi
float max_vol = ta.highest(volume, lookback)
float min_vol = ta.lowest(volume, lookback)
float vol_norm = (max_vol - min_vol) > 0 ? (volume - min_vol) / (max_vol - min_vol) : 0.5

float range_val = high - low
float sell_pressure = range_val > 0 ? (high - close) / range_val : 0.5

// OBV con lisciatura per evitare picchi anomali
var float obv = 0.0
obv := nz(obv[1]) + (close > close[1] ? volume : close < close[1] ? -volume : 0.0)
float max_obv = ta.highest(obv, lookback)
float min_obv = ta.lowest(obv, lookback)
float obv_norm = (max_obv - min_obv) > 0 ? (obv - min_obv) / (max_obv - min_obv) : 0.5

// Flow Fear: se OBV è basso (vicino ai minimi), (1 - obv_norm) è alto -> aumenta la paura
float flow_fear = ((vol_norm * 0.35) + (sell_pressure * 0.45) + ((1.0 - obv_norm) * 0.20)) * 100.0

// Fear Index Finale (Ponderato)
float fear_index = (vol_fear * 0.4) + (flow_fear * 0.6)

// ==========================================
// 3. MOTORE DI ESTENSIONE MACRO (MAYER PROXY)
// ==========================================
int sma_len = timeframe.isweekly ? 40 : 200
float long_term_mean = ta.sma(close, sma_len)
float extension_pct = long_term_mean > 0 ? ((close - long_term_mean) / long_term_mean) * 100.0 : 0.0

// NORMALIZZAZIONE DELL'ESTENSIONE (Risolve il problema del break-out della scala)
float max_ext = ta.highest(extension_pct, lookback)
float min_ext = ta.lowest(extension_pct, lookback)
float extension_norm = (max_ext - min_ext) > 0 ? (extension_pct - min_ext) / (max_ext - min_ext) * 100.0 : 50.0

// ==========================================
// 4. CALCOLO SINTETICO DEL CICLO (GREED SCORE)
// ==========================================
// Ora entrambe le componenti sono 0-100. Il Greed Score è la perfetta antitesi simmetrica.
float greed_score = ((100.0 - fear_index) + extension_norm) / 2.0

// ==========================================
// 5. IDENTIFICAZIONE STRUTTURALE DELLE FASI
// ==========================================
// Soglie ottimizzate su base statistica normalizzata
int input_bubble_threshold = input.int(80, "Soglia Bolla Normalizzata", tooltip="Valore da 0 a 100 basato sull'estensione massima del trimestre", group="Soglie Quant")

bool is_instit_zone = fear_index > 65.0 and extension_norm < 25.0
bool is_retail_zone = greed_score > input_bubble_threshold and extension_norm > input_bubble_threshold

// Linea principale dell'oscillatore basata sul Greed Score (0 = Panico Totale, 100 = Euforia)
color cycle_color = is_instit_zone ? color.green : is_retail_zone ? color.red : color.gray
plot(greed_score, "Greed Score Ciclico", color=cycle_color, linewidth=2)

// Sfondi dinamici per i segnali operativi
bgcolor(is_instit_zone ? color.new(color.green, 85) : na, title="Accumulo Istituzionale")
bgcolor(is_retail_zone ? color.new(color.red, 85) : na, title="Distribuzione Retail / Bolla")

// Linee di Estremo dell'Oscillatore
hline(80, "Iper-Euforia (Retail FOMO)", color=color.red, linestyle=hline.style_dashed)
hline(50, "Equilibrio", color=color.gray, linestyle=hline.style_dotted)
hline(20, "Massimo Panico (Smart Money Entry)", color=color.green, linestyle=hline.style_dashed)

// ==========================================
// 6. PANNELLO INFORMATIVO
// ==========================================
if barstate.islast
    var table d_table = table.new(position.top_right, 2, 4, border_width=1, border_color=color.gray)
    string phase = is_instit_zone ? "ACCUMULO" : is_retail_zone ? "BOLLA / DISTRIBUZIONE" : "FASE NEUTRALE"
    color p_col = is_instit_zone ? color.green : is_retail_zone ? color.red : color.gray
    
    table.cell(d_table, 0, 0, "Stato Ciclo", bgcolor=color.black, text_color=color.white)
    table.cell(d_table, 1, 0, phase, bgcolor=p_col, text_color=color.white)
    
    table.cell(d_table, 0, 1, "Greed Score (0-100)", bgcolor=color.new(color.gray, 80))
    table.cell(d_table, 1, 1, str.tostring(greed_score, "#.##"), bgcolor=color.new(color.gray, 90))
    
    table.cell(d_table, 0, 2, "Estensione Norm.", bgcolor=color.new(color.gray, 80))
    table.cell(d_table, 1, 2, str.tostring(extension_norm, "#.##") + "%", bgcolor=color.new(color.gray, 90))
````
