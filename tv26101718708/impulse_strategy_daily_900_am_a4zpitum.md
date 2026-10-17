# Impulse Strategy Daily 9:00 AM

- url: https://www.tradingview.com/script/A4zPITUM/
- type: indicator
- pine_id: PUB;bb643fd1f30a49088b004486d5fbadf6
- version: 1.0

## Description

Here is a clear and professional overview of the script in English that you can share with your friends:

📈 9:00 AM Daily Impulse Strategy (Pine Script v5)
This indicator is an automated script designed for TradingView that identifies high-probability breakout and reversal setups at the European market open (9:00 AM Paris time). It is purely based on market structure and price action, completely avoiding lagging indicators like RSI or MACD.

🔍 How It Works
The script analyzes the price action of the previous daily candlestick and confirms a directional momentum right before the 9:00 AM opening bell:

For a BUY Signal:

The previous daily candle must be bearish (Close < Open).

The current daily structure must show bullish validation (Current Close > Current Open AND Current Close > Previous Daily Close).

The trigger occurs precisely on the 9:00 AM candle.

For a SELL Signal:

The previous daily candle must be bullish (Close > Open).

The current daily structure must show bearish validation (Current Close < Current Open AND Current Close < Previous Daily Close).

The trigger occurs precisely on the 9:00 AM candle.

🛠️ Key Features
Multi-Timeframe Data Sourcing: It automatically fetches the required Higher Timeframe (Daily) data behind the scenes, so you don't have to switch charts.

Clean Visual Alerts: It plots explicit green "BUY" and red "SELL" labels directly on your chart at the exact execution time.

Candle Coloration: The specific 9:00 AM trigger candle changes color (Green/Red) to highlight the trade setup instantly.

💡 Recommendation for Users
To ensure the script triggers perfectly, it should be applied to intraday timeframes that have a candle opening exactly at 9:00 AM (such as the 15-minute, 30-minute, or 1-hour charts). It is highly optimized for volatile assets during the European open, including Gold, Silver, and major indices like the Dow Jones (Wall Street Cash).

## Source Code

````pine
//@version=6
indicator("Stratégie Impulsion Daily 9h00 - v6", overlay=true, max_labels_count=500)

// --- COLLECTE DES DONNÉES DAILY (SYNCHRONISATION V6 ACTIVE) ---
// On récupère les données de la bougie Daily précédente (clôturée)
dailyOpen  = request.security(syminfo.tickerid, "1D", open[1], barmerge.gaps_off, barmerge.lookahead_on)
dailyClose = request.security(syminfo.tickerid, "1D", close[1], barmerge.gaps_off, barmerge.lookahead_on)

// On récupère les données de la bougie Daily en cours 
currentDailyOpen  = request.security(syminfo.tickerid, "1D", open, barmerge.gaps_off, barmerge.lookahead_on)
currentDailyClose = request.security(syminfo.tickerid, "1D", close, barmerge.gaps_off, barmerge.lookahead_on)

// --- LOGIQUE DES SIGNAUX ---
JourPrecedentHaussier = (dailyClose > dailyOpen)
JourPrecedentBaissier = (dailyClose < dailyOpen)

ValidationVente = (currentDailyClose < currentDailyOpen) and (currentDailyClose < dailyClose)
ValidationAchat = (currentDailyClose > currentDailyOpen) and (currentDailyClose > dailyClose)

SignalVenteDaily = JourPrecedentHaussier and ValidationVente
SignalAchatDaily = JourPrecedentBaissier and ValidationAchat

// --- FILTRE HORAIRE STRICT (9h00) ---
// En v6, l'utilisation combinée de hour et minute est nettoyée pour éviter les faux déclenchements
Est9H00 = (hour == 9 and minute == 0)

// --- CONDITIONS FINALES ---
SignalAchat = SignalAchatDaily and Est9H00
SignalVente = SignalVenteDaily and Est9H00

// --- AFFICHAGE VISUEL SUR LE GRAPHIQUE ---
if SignalAchat
    label.new(bar_index, low, text="BUY", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.normal)

if SignalVente
    label.new(bar_index, high, text="SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)

// Coloration de la bougie de 9h00 en cas de signal
barcolor(SignalAchat ? color.green : SignalVente ? color.red : na)
````
