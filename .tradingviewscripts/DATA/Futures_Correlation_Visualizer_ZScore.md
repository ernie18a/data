<!-- tradingview-pine-id: PUB;6d2445b2637c4baca0d5f69edf9ebe59 -->
<!-- tradingviewscripts-format: 1 -->
# Futures Correlation Visualizer (Z-Score)

Source: https://www.tradingview.com/script/WU32bTzr-Market-Correlation-Visualizer-Z-Score/

## Description

Market Correlation Visualizer (Z-Score & % Var)

OVERVIEW
The Market Correlation Visualizer is a multi-asset analysis tool designed for intraday traders and quant analysts. Instead of relying on static correlation tables, this script plots real-time relative performance across up to 8 benchmark assets (Indices, Volatility, Commodities, Bonds, and Crypto) directly on your chart panel.

By standardizing assets through either Z-Score (Standard Deviations) or Percentage Change, you can instantly spot institutional imbalances, intermarket divergences, and statistical overextensions before they manifest on price action alone.

KEY FEATURES

Dual Engine Calculation:
Z-Score Normalization scales price movements based on rolling standard deviation. It identifies when an asset is statistically overbought/oversold relative to its peers.
Daily % Change Anchor normalizes performance from a customizable anchor time (e.g. Daily Open) to track pure percentage strength or weakness throughout the session.

Smart Right-Hand Labels:
Clean, dynamic labels automatically lock onto the right boundary of the indicator panel, displaying the ticker name and exact current reading. No need to memorize line colors.

Statistical Excess Zones (+/- 2.0 SD):
Visual upper and lower threshold bands immediately highlight extreme mean-reversion zones when using Z-Score mode.

Selective Visibility Filters:
Toggle up to 8 custom symbols on or off directly from the settings menu to keep your workspace uncluttered.

Error-Handled Security Fetching:
Built with robust fallback logic to ensure smooth performance across various brokers without breaking the chart panel if a specific ticker fails to load.

HOW TO USE FOR INTRADAY TRADING

Spotting SMT / Intermarket Divergences:
Watch key correlated pairs (e.g. ES vs NQ). If one index makes a new high while the visualizer line on the other fails to confirm, a liquidity sweep or SMT divergence is in play.

Mean-Reversion & Arbitrage:
When an asset crosses outside the +/- 2.0 Standard Deviation band while others remain neutral, it indicates an overextended asset prone to snapping back toward the zero-line.

Volatility Confirmation:
Track VIX against equity futures (ES, NQ). If ES hits a new low but the VIX line fails to push upward, the selling momentum lacks institutional backing.

DEFAULT TICKERS INCLUDED

Asset 1: TVC:VIX (Volatility)

Asset 2: CME_MINI:ES1! (S&P 500)

Asset 3: CME_MINI:NQ1! (Nasdaq 100)

Asset 4: COMEX:GC1! (Gold)

Assets 5 to 8 (Optional): NYMEX:CL1! (Crude Oil), CBOT:ZB1! (30Y Bonds), CME_MINI:RTY1! (Russell 2000), BINANCE:BTCUSDT (Bitcoin).

All inputs can be fully customized in the script settings.

---

## Source Code

````pine
//@version=6
indicator("Futures Correlation Visualizer (Z-Score)", overlay=false)

// --- Inputs Tickers ---
g_sym = "Sélection des Tickers"
sym1 = input.symbol("TVC:VIX", "Ticker 1", group=g_sym)
sym2 = input.symbol("CME_MINI:ES1!", "Ticker 2", group=g_sym)
sym3 = input.symbol("CME_MINI:NQ1!", "Ticker 3", group=g_sym)
sym4 = input.symbol("COMEX:GC1!", "Ticker 4", group=g_sym)
sym5 = input.symbol("NYMEX:CL1!", "Ticker 5", group=g_sym)
sym6 = input.symbol("CBOT:ZB1!", "Ticker 6", group=g_sym)
sym7 = input.symbol("CME_MINI:RTY1!", "Ticker 7", group=g_sym)
sym8 = input.symbol("BINANCE:BTCUSDT", "Ticker 8", group=g_sym)

g_sett = "Paramètres de Calcul"
calcMode = input.string("Z-Score", "Mode de Calcul", options=["Z-Score", "% Variation Daily"], group=g_sett)
length = input.int(20, "Période Z-Score (Lookback)", minval=2, group=g_sett)
anchorTF = input.timeframe("D", "Point d'ancrage (% Var)", group=g_sett)

g_vis = "Affichage / Visibilité"
show1 = input.bool(true, "Afficher Ticker 1", group=g_vis)
show2 = input.bool(true, "Afficher Ticker 2", group=g_vis)
show3 = input.bool(true, "Afficher Ticker 3", group=g_vis)
show4 = input.bool(true, "Afficher Ticker 4", group=g_vis)
show5 = input.bool(false, "Afficher Ticker 5", group=g_vis)
show6 = input.bool(false, "Afficher Ticker 6", group=g_vis)
show7 = input.bool(false, "Afficher Ticker 7", group=g_vis)
show8 = input.bool(false, "Afficher Ticker 8", group=g_vis)

// --- Fonctions de Calcul ---
f_zscore(sym, len) =>
    c = request.security(sym, timeframe.period, close, ignore_invalid_symbol=true)
    mean = ta.sma(c, len)
    stdev = ta.stdev(c, len)
    not na(c) and not na(mean) and stdev != 0 ? (c - mean) / stdev : na

f_pctChange(sym, tf) =>
    o = request.security(sym, tf, open, ignore_invalid_symbol=true)
    c = request.security(sym, timeframe.period, close, ignore_invalid_symbol=true)
    not na(o) and not na(c) and o != 0 ? ((c - o) / o) * 100 : na

f_getVal(sym) =>
    calcMode == "Z-Score" ? f_zscore(sym, length) : f_pctChange(sym, anchorTF)

// --- Calculs ---
val1 = show1 ? f_getVal(sym1) : na
val2 = show2 ? f_getVal(sym2) : na
val3 = show3 ? f_getVal(sym3) : na
val4 = show4 ? f_getVal(sym4) : na
val5 = show5 ? f_getVal(sym5) : na
val6 = show6 ? f_getVal(sym6) : na
val7 = show7 ? f_getVal(sym7) : na
val8 = show8 ? f_getVal(sym8) : na

// --- Couleurs ---
c1 = #FFD700, c2 = #00BFFF, c3 = #E06666, c4 = #FF9900
c5 = #8E44AD, c6 = #2ECC71, c7 = #1ABC9C, c8 = #E91E63

// --- Tracés des Lignes ---
plot(val1, color=c1, title="1", linewidth=2)
plot(val2, color=c2, title="2", linewidth=1)
plot(val3, color=c3, title="3", linewidth=1)
plot(val4, color=c4, title="4", linewidth=1)
plot(val5, color=c5, title="5", linewidth=1)
plot(val6, color=c6, title="6", linewidth=1)
plot(val7, color=c7, title="7", linewidth=1)
plot(val8, color=c8, title="8", linewidth=1)

// --- Fonction de Gestion des Étiquettes Droites ---
f_drawRightLabel(show, val, sym, col) =>
    var label lbl = na
    if show and barstate.islast and not na(val)
        label.delete(lbl)
        // Extrait uniquement le nom court de l'actif (ex: ES1! au lieu de CME_MINI:ES1!)
        cleanName = str.split(sym, ":").get(str.split(sym, ":").size() - 1)
        txt = cleanName + " (" + str.tostring(val, "#.##") + ")"
        lbl := label.new(bar_index + 2, val, text=txt, color=col, textcolor=color.black, style=label.style_label_left, size=size.small)

// --- Affichage des Étiquettes ---
f_drawRightLabel(show1, val1, sym1, c1)
f_drawRightLabel(show2, val2, sym2, c2)
f_drawRightLabel(show3, val3, sym3, c3)
f_drawRightLabel(show4, val4, sym4, c4)
f_drawRightLabel(show5, val5, sym5, c5)
f_drawRightLabel(show6, val6, sym6, c6)
f_drawRightLabel(show7, val7, sym7, c7)
f_drawRightLabel(show8, val8, sym8, c8)

// --- Niveaux de Référence ---
hline(0, "Ligne Zéro", color=color.gray, linestyle=hline.style_dashed)
h_upper = hline(2.0, "Zone d'Excès Haut (+2 SD)", color=color.new(color.red, 50), linestyle=hline.style_dotted)
h_lower = hline(-2.0, "Zone d'Excès Bas (-2 SD)", color=color.new(color.green, 50), linestyle=hline.style_dotted)
fill(h_upper, h_lower, color=color.new(color.gray, 95), title="Zone Neutre")
````
