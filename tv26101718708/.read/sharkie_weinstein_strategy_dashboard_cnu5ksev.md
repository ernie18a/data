# Sharkie Weinstein Strategy Dashboard

- url: https://www.tradingview.com/script/CNu5KSEv/
- type: indicator
- pine_id: PUB;19d701061c7d4c7291f047d98db13cdf
- version: 1.0

## Description

Strategische Mauer: Dieses Skript ist dein Türsteher. Wenn hier kein Leuchtgrün (Stage 2) erscheint, ist die Aktie für deine 0,5%-Taktik eigentlich nicht qualifiziert.

RS-Indikator: Die Mansfield-RS zeigt dir, ob die Aktie den Markt schlägt. Nur Gewinner-Aktien bringen dich zu deinen 5–10 R im Monat.

Positionierung: Ich habe es nach oben rechts (top_right) gesetzt. So hast du links die taktische B/S Ratio und rechts die strategische Weinstein-Phase im Blick.

## Source Code

````pine
//@version=6
indicator("Sharkie Weinstein Strategy Dashboard", overlay=true)

// --- 1. WEINSTEIN KOMPONENTEN ---
// Der 30-Wochen-MA (im Daily-Chart ca. 150 Tage)
float ma30w = ta.sma(close, 150)
bool priceAboveMA = close > ma30w
bool maRising = ta.rising(ma30w, 5)

// Relative Stärke (RS) Mansfield-Logik im Vergleich zum SPY
symbol_spy = "AMEX:SPY"
float spy_close = request.security(symbol_spy, timeframe.period, close)
float rs_ratio = close / spy_close
float rs_ma = ta.sma(rs_ratio, 50)
bool rs_positive = rs_ratio > rs_ma

// --- 2. STAGE DEFINITION ---
int stage = 0
color stageColor = color.gray
string stageDesc = ""

if not priceAboveMA and not maRising
    stage := 4
    stageDesc := "Stage 4: Kapitulation"
    stageColor := #ff0000 // Rot
else if not priceAboveMA and maRising
    stage := 1
    stageDesc := "Stage 1: Bodenbildung"
    stageColor := #90ee90 // Hellgrün
else if priceAboveMA and maRising and rs_positive
    stage := 2
    stageDesc := "Stage 2: Ausbruch / Trend"
    stageColor := #00ff00 // Leuchtendes Grün
else if priceAboveMA and not maRising
    stage := 3
    stageDesc := "Stage 3: Top-Bildung"
    stageColor := #ffa500 // Orange

// --- 3. DASHBOARD (RECHTS OBEN) ---
// Wir setzen es nach rechts oben, damit es nicht mit dem Gefechts-Display kollidiert
var table wTable = table.new(position.top_right, 1, 1, border_width = 2, border_color = color.black)

if barstate.islast
    string infoTxt = "【 WEINSTEIN ANALYSE 】\n" + 
                     stageDesc + "\n" +
                     "RS vs SPY: " + (rs_positive ? "STARK" : "SCHWACH") + "\n" +
                     "MA30W: " + (maRising ? "STEIGEND" : "FALLEND")

    table.cell(wTable, 0, 0, infoTxt, 
         bgcolor = stageColor, 
         text_color = color.black, 
         text_size = size.normal, 
         text_halign = text.align_left)
````
