# Silver Surfer

- url: https://www.tradingview.com/script/Z8eVxEaX/
- type: strategy
- pine_id: PUB;caae97f7b32e479dabae6bfd71d40f2b
- version: 1.0

## Description

Silver Surfer — MTF Smart Money Concept Strategy
Version: 6 | Overlay: Ja | Timeframe-Empfehlung: 15m (H1 als Trend-Anchor)
🎯 Strategie-Philosophie
Silver Surfer ist eine strukturbasierte Trading-Strategie, die klassische Smart Money Concepts (SMC) mit einer proprietären Trenddetektionslogik verbindet. Die Idee: Statt auf einzelne Indikatoren zu setzen, nutzt das System Multi-Timeframe-Konfluenz (MTF), Fair Value Gaps (FVG) als Momentum-Trigger und eine eigene CISD-Strukturerkennung zur Trendbestimmung. Das Ergebnis ist ein diszipliniertes, regelbasiertes Setup für Scalping und kurzfristiges Swing-Trading mit klar definiertem Risk-Management.
⚙️ Kernkomponenten
1. CISD — Custom Inside Structure Detection
Die interne Trendlogik identifiziert Trendwenden durch das Verhalten von Inside-Bars und nachfolgende Breaks.
Ein bullisher Trend wird aktiviert, wenn der Close über dem Open einer vorangegangenen strukturellen Kerze breakt.
Ein bearisher Trend wird aktiviert, wenn der Close unter dem Open einer strukturellen Kerze fällt.
Die Logik filtert reine Inside-Bars heraus, um Noise zu reduzieren.
2. MTF Alignment — Multi-Timeframe Konfluenz
Die Strategie fragt den Trendzustand aus dem höheren Timeframe (Standard: H1) ab und vergleicht ihn mit dem aktuellen Chart-Timeframe.
Long-Einstieg: Nur wenn H1 und aktueller TF bullisch sind.
Short-Einstieg: Nur wenn H1 und aktueller TF bearisch sind.
Dies verhindert Gegen-Trend-Trades in strukturell schwachen Zonen.
3. FVG — Fair Value Gap (Primärer Entry-Trigger)
FVGs repräsentieren Imbalancen im Orderflow. Die Strategie nutzt sie als primären Auslöser:
Bullish FVG: low > high[2] — eine Lücke nach unten, die auf Käufer-Druck hindeutet.
Bearish FVG: high < low[2] — eine Lücke nach oben, die auf Verkäufer-Druck hindeutet.
4. BOS — Break of Structure (Optionaler Filter)
Ein zuschaltbarer LuxAlgo-kompatibler Filter zur weiteren Trendbestätigung:
Bullish BOS: high > highest(high, 10)[1]
Bearish BOS: low < lowest(low, 10)[1]
Wenn aktiviert, muss zusätzlich zum FVG ein BOS vorliegen — ideal für ruhigere Märkte.
📊 Execution & Risk Management
Einstieg: MTF-Alignment + FVG (+ optional BOS). Es wird nur eine Position zur Zeit gehalten.
Stop Loss: Dynamisch basierend auf ATR(14) × 1.5 — an die aktuelle Volatilität angepasst.
Take Profit: Festes Risk-Reward Ratio (Standard: 1.5:1), basierend auf der gleichen ATR-Distanz.
Kommission & Slippage: Im Backtest berücksichtigt (0.04% / 1 Tick) für realistischere Ergebnisse.
🎨 Visualisierung
Grüne Dreiecke (▼): Bullish FVGs unter der Kerze.
Orange Dreiecke (▲): Bearish FVGs über der Kerze.
Hintergrund-Färbung: Dezente grüne/rote Flächen bei MTF-Alignment (90% Transparenz).
🔧 Einstellbare Parameter
Table
Parameter	Standard	Beschreibung
Trend TF (H1)	60	Höherer Timeframe für die Trendrichtung (z.B. 60 für H1, 240 für H4).
Risk-Reward Ratio	1.5	Verhältnis von Take-Profit zu Stop-Loss (basierend auf ATR).
Require BOS Filter?	false	Schaltet den Break-of-Structure Filter zu/aus.
⚠️ Wichtige Hinweise & Disclaimer
Diese Strategie wurde für Pine Script v6 entwickelt und erfordert einen aktuellen TradingView-Account.
Backtests zeigen historische Performance; zukünftige Ergebnisse können davon abweichen.
Die Strategie nutzt request.security() für MTF-Daten — mögliche Repainting-Effekte bei nicht bestätigten Higher-TF-Kerzen sollten beim Forward-Test beachtet werden.
Keine Anlageberatung. Nutzung auf eigenes Risiko. Teste die Strategie ausgiebig im Paper-Trading, bevor du echtes Kapital einsetzt.
📈 Empfohlene Märkte & Timeframes
Forex: EUR/USD, GBP/USD, XAG/USD (Silver — daher der Name 😉)
Crypto: BTC/USDT, ETH/USDT
Timeframe: 15m Chart mit H1 als Trend-Anchor (anpassbar)
Happy Surfing! 🌊🥈

## Source Code

````pine
//@version=6
strategy(title="Silver Surfer", overlay=true, initial_capital=10000, 
     commission_type=strategy.commission.percent, commission_value=0.04, slippage=1)

// ==========================================
// 1. SETTINGS
// ==========================================
string tf_high = input.timeframe("60", title="Trend TF (H1)")
float rr_ratio = input.float(1.5, title="Risk-Reward Ratio")
bool use_bos   = input.bool(false, title="Require BOS Filter?") 

// ==========================================
// 2. CORE LOGIC: CISD
// ==========================================
f_cisd() =>
    var float bull_t = na
    var float bear_t = na
    var string state = "Neutral"
    bool is_inside = high < high[1] and low > low[1]
    
    if not na(bull_t) and ta.crossover(close, bull_t)
        state := "Bullish"
    if not na(bear_t) and ta.crossunder(close, bear_t)
        state := "Bearish"
        
    if close < open and not is_inside
        bull_t := open
    if close > open and not is_inside
        bear_t := open
    state

// MTF Fetching
state_h = request.security(syminfo.tickerid, tf_high, f_cisd())
state_l = f_cisd() // Current 15m TF

// Simplified 2-TF alignment for more activity
bool aligned_bull = state_h == "Bullish" and state_l == "Bullish"
bool aligned_bear = state_h == "Bearish" and state_l == "Bearish"

// ==========================================
// 3. LUXALGO FILTERS (PAC)
// ==========================================
// BOS Logic
bool bos_bull = high > ta.highest(high, 10)[1]
bool bos_bear = low < ta.lowest(low, 10)[1]

// FVG Logic (Primary Entry Trigger)
bool fvg_bull = low > high[2]
bool fvg_bear = high < low[2]

// ==========================================
// 4. EXECUTION
// ==========================================
// Entry: MTF aligned + FVG momentum (+ optional BOS)
if aligned_bull and (not use_bos or bos_bull) and fvg_bull and strategy.position_size == 0
    strategy.entry("Long", strategy.long)

if aligned_bear and (not use_bos or bos_bear) and fvg_bear and strategy.position_size == 0
    strategy.entry("Short", strategy.short)

// Standard ATR-based Exit for Scalping
float atr = ta.atr(14)
if strategy.position_size != 0
    float sl_dist = atr * 1.5
    if strategy.position_size > 0
        strategy.exit("LE", "Long", stop=close - sl_dist, limit=close + (sl_dist * rr_ratio))
    else
        strategy.exit("SE", "Short", stop=close + sl_dist, limit=close - (sl_dist * rr_ratio))

// Visuals
plotshape(fvg_bull, "FVG Bull", shape.triangleup, location.belowbar, color.teal, size=size.tiny)
plotshape(fvg_bear, "FVG Bear", shape.triangledown, location.abovebar, color.orange, size=size.tiny)
bgcolor(aligned_bull ? color.new(color.green, 90) : aligned_bear ? color.new(color.red, 90) : na)
````
