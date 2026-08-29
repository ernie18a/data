<!-- tradingview-pine-id: PUB;9874305055ee4244b9c0079a6a60a02d -->
<!-- tradingviewscripts-format: 1 -->
# Whale Absorption & Liquidity Zones

Source: https://www.tradingview.com/script/NL3DgDwg/

## Description

This indicator is designed to help traders identify institutional activity through Whale Absorption and Liquidity Zones. By analyzing volume anomalies and price action, it pinpoints where large players might be entering or defending positions.

Key Features:

Whale Absorption (Buy/Sell): Detects high-volume bars where price movement is restricted, suggesting that large orders are being absorbed.

Green Bar/Triangle: Institutional buying/absorption.
Red Bar/Triangle: Institutional selling/distribution.
Liquidity Zones: Automatically plots dashed lines at recent Pivot Highs and Lows (Buy/Sell Stops), showing where the "liquidity" (retail stop losses) is likely sitting.
Real-time Dashboard: A clean UI in the top-right corner monitors volume status and whale presence.

How to Trade:
Look for Whale Buy signals near Liquidity Buy Stops for potential high-probability reversals.
Use the dashboard to confirm if the current volume is "Normal" or "High" before entering a trade.

---

## Source Code

````pine
//@version=6
indicator("Whale Absorption & Liquidity Zones", overlay=true, max_labels_count=500)

// --- CONFIGURAÇÕES ---
vol_ma_length = input.int(20, "Média de Volume", minval=1)
vol_multiplier = input.float(1.5, "Multiplicador de Volume Whale", step=0.1)
lookback_liquidity = input.int(20, "Lookback de Liquidez (Pivot)", minval=5)

// --- LÓGICA DE VOLUME (WHALES) ---
avg_vol = ta.sma(volume, vol_ma_length)
is_high_vol = volume > avg_vol * vol_multiplier

// Absorção de Compra (Whale Buying): Volume alto + preço fechando longe da mínima
is_buy_absorption = is_high_vol and close > (low + (high - low) * 0.6) and close > open

// Absorção de Venda (Whale Selling): Volume alto + preço fechando longe da máxima
is_sell_absorption = is_high_vol and close < (low + (high - low) * 0.4) and close < open

// --- LÓGICA DE LIQUIDEZ ---
ph = ta.pivothigh(high, lookback_liquidity, 5)
pl = ta.pivotlow(low, lookback_liquidity, 5)

// --- VISUALIZAÇÃO ---

// Pintar barras de Whale Activity
barcolor(is_buy_absorption ? color.new(#00ff08, 0) : is_sell_absorption ? color.new(#ff0055, 0) : na)

// Plotar Sinais
plotshape(is_buy_absorption, title="Whale Buy", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="WHALE BUY")
plotshape(is_sell_absorption, title="Whale Sell", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="WHALE SELL")

// Plotar Zonas de Liquidez (Níveis de Stop)
if not na(ph)
    line.new(bar_index[5], ph, bar_index, ph, color=color.new(color.red, 50), width=1, style=line.style_dashed, extend=extend.right)
    label.new(bar_index, ph, "LIQUIDEZ (SELL STOPS)", color=color.new(color.red, 80), style=label.style_label_down, textcolor=color.white, size=size.tiny)

if not na(pl)
    line.new(bar_index[5], pl, bar_index, pl, color=color.new(color.green, 50), width=1, style=line.style_dashed, extend=extend.right)
    label.new(bar_index, pl, "LIQUIDEZ (BUY STOPS)", color=color.new(color.green, 80), style=label.style_label_up, textcolor=color.white, size=size.tiny)

// --- DASHBOARD ---
var table panel = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    table.cell(panel, 0, 0, "Volume Status:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 0, is_high_vol ? "HIGH" : "NORMAL", bgcolor=is_high_vol ? color.red : color.green, text_color=color.white, text_size=size.small)
    table.cell(panel, 0, 1, "Whale Presence:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 1, is_buy_absorption or is_sell_absorption ? "DETECTED" : "NONE", bgcolor=is_buy_absorption or is_sell_absorption ? color.orange : color.gray, text_color=color.white, text_size=size.small)
````
