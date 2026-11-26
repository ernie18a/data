# Aquila Reale Gold/DXY Correlation v1.4 by giua64

- url: https://www.tradingview.com/script/ix2Kfa4U/
- type: indicator
- pine_id: PUB;2c8f47d4684e4457b7905d1c0d232cd7
- version: 2.0

## Description

🦅  Aquila Reale Gold/DXY Correlation — by giua64

WHAT IT DOES

This indicator measures the rolling inverse correlation between Gold and the US Dollar in real time. Gold and the Dollar normally move in opposite directions — when that relationship holds, the Dollar is the driver and you can trust it. When the relationship breaks, something else is pushing Gold (real yields, safe-haven flows, fear). Spotting that break is the real edge.
HOW TO READ IT

The correlation is inverted so the chart is intuitive:

Line HIGH and GREEN = strong inverse link (healthy). Gold and Dollar move opposite as they should.
Line YELLOW = the link is weakening.
Line LOW and RED (below zero) = the link is broken. Gold and Dollar are moving the same way — anomaly. Gold is running on its own, not on Dollar weakness.

The midline (zero) is the key reference: above it the inverse relationship is still alive, below it the relationship has flipped.
WHY USDX AND NOT DXY

By default you can use any Dollar symbol in the input. I personally use USDX instead of TVC:DXY because USDX carries volume data, while the TVC Dollar index does not. Correlation is symmetrical (corr A,B = corr B,A), so you only need this indicator on ONE chart — Gold or Dollar, it reads the same link from either side. Using USDX simply lets you keep volume on the Dollar panel.

SETTINGS

Gold symbol and Dollar symbol: fully editable.
Length mode: Auto (preset per timeframe) or Manual. Auto adapts the lookback to the chart TF: 5m=14, 15m=16, 30m=18, 1h=20, 4h=24.
Healthy-link threshold: the level above which the inverse link is considered strong. Suggested sets — Scalping 0.4, Intraday 0.5, Swing 0.6.

ALERTS

Link BROKEN (correlation drops below threshold)
Link RESTORED (correlation back above threshold)
ANOMALY (correlation turns negative — moving together)

DISCLAIMER

This script is for educational and informational purposes only. It is not financial advice. Trading involves risk; always do your own analysis and manage your risk.

🦅  Royal Eagles — born to fly, born to dare!

🦅  Aquile Reali — Be Stable. Be Strong.

## Source Code

````pine
//@version=6
indicator("Aquila Reale Gold/DXY Correlation v1.4 by giua64", overlay=false, precision=2)

sym_gold   = input.symbol("OANDA:XAUUSD", "Simbolo Oro")
sym_dollar = input.symbol("TVC:DXY",      "Simbolo Dollaro")

modo = input.string("Auto (preset per TF)", "Lunghezza correlazione", options=["Auto (preset per TF)","Manuale"])
len_manuale = input.int(20, "Candele (solo modo Manuale)", minval=2)
soglia = input.float(0.5, "Soglia legame sano", minval=0, maxval=1, step=0.05)
len_ma = input.int(20, "Media mobile dollaro (per LONG/SHORT)", minval=2)

tf_min = timeframe.in_seconds() / 60
len_auto = tf_min <= 5 ? 14 : tf_min <= 15 ? 16 : tf_min <= 30 ? 18 : tf_min <= 60 ? 20 : tf_min <= 240 ? 24 : 20
len_corr = modo == "Manuale" ? len_manuale : len_auto

gold   = request.security(sym_gold,   timeframe.period, close)
dollar = request.security(sym_dollar, timeframe.period, close)

bgcolor(color.new(color.black, 0))

corr = -ta.correlation(gold, dollar, len_corr)
col = corr >= soglia ? color.rgb(0, 255, 140) : corr > 0 ? color.rgb(255, 200, 0) : color.rgb(255, 60, 60)
plot(corr, "Correlazione", col, linewidth=2)

hline(0,      "Zero",              color.new(color.gray, 30),  hline.style_dashed)
hline(soglia, "Soglia legame",     color.new(color.rgb(0,255,140), 40), hline.style_dotted)
hline(0.8,    "Inversa fortissima",color.new(color.rgb(0,255,140), 70), hline.style_dotted)
hline(-0.5,   "Anomalia",          color.new(color.rgb(255,60,60), 60), hline.style_dotted)

ma_dollar = ta.sma(dollar, len_ma)
segnale = dollar < ma_dollar ? "LONG" : dollar > ma_dollar ? "SHORT" : "NEUTRO"
seg_col = dollar < ma_dollar ? color.rgb(0, 255, 140) : dollar > ma_dollar ? color.rgb(255, 60, 60) : color.gray

var label lbl = na
if barstate.islast
    lbl := label.new(bar_index, corr, segnale, textcolor=color.white, color=color.new(seg_col, 10), style=label.style_label_right, size=size.tiny)
    label.delete(lbl[1])

alertcondition(ta.crossunder(dollar, ma_dollar), title="LONG oro",  message="Dollaro sotto la media - LONG oro")
alertcondition(ta.crossover(dollar, ma_dollar),  title="SHORT oro", message="Dollaro sopra la media - SHORT oro")
````
