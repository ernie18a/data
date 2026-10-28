# GBR MTF Adaptive Channel [Ghost Lines]

- url: https://www.tradingview.com/script/SoEV0Nd0-GBR-MTF-Adaptive-Channel-Ghost-Lines/
- type: indicator
- pine_id: PUB;b02dd00464934fb7ae46a7a592c91aa0
- version: 1.0

## Description

The GBR MTF Adaptive Channel solves the biggest problem day traders face: tunnel vision. When you are hyper-focused on the 1m or 5m chart, it is easy to miss that you are driving straight into a massive 4H resistance wall.

This indicator projects Higher Timeframe (HTF) volatility channels directly onto your execution chart without any of the visual clutter.

🔥 Core Features:

Triple Threat (MTF): Simultaneously plots the adaptive ATR/Keltner channel for your current timeframe, a Medium HTF (e.g., 1H), and a Macro HTF (e.g., 4H).

Ghost Lines: No distracting fills or blinding colors. The higher timeframe channels are rendered at 75% transparency using sleek Cyan and Purple, acting as silent guardrails in the background.

Dynamic Floating Labels: You never have to guess which line is which. Clean text labels float gracefully on the right side of the chart, clearly identifying the exact timeframe and level (e.g., "4H Resistance").

Institutional Adaptability: The default ATR multiplier is set wider (3.0) to filter out market noise and only highlight true structural extremes. Fully customizable in the settings.

🎯 How to use:
Keep this running in the background while using your primary execution setups. Use the Macro (Purple) and Medium (Cyan) outer bands as absolute hard stops or ultimate take-profit targets.

## Source Code

````pine
//@version=6
indicator("GBR MTF Adaptive Channel", overlay=true, max_labels_count=50)

// ==========================================
// 1. SETTINGS (UI)
// ==========================================
grp1 = "Channel Settings (Adaptability)"
length = input.int(20, title="Lookback Period", group=grp1)
mult   = input.float(3.0, title="Channel Width (ATR Multiplier)", step=0.5, group=grp1, tooltip="Növeld ezt az értéket, ha túl szűk a csatorna!")

grp2 = "Multi-Timeframe Setup"
tf1      = input.timeframe("60", title="HTF 1 (Medium Trend)", group=grp2)
tf1_name = input.string("1H", title="HTF 1 Label Name", group=grp2)

tf2      = input.timeframe("240", title="HTF 2 (Macro Trend)", group=grp2)
tf2_name = input.string("4H", title="HTF 2 Label Name", group=grp2)

// ==========================================
// 2. GBR FAINT COLORS (Új, elkülönített színek)
// ==========================================
colChart = color.new(color.gray, 80)   // Micro (Aktuális)
colTf1   = color.new(#00E5FF, 75)      // Medium (Cián / Türkiz)
colTf2   = color.new(#B200FF, 75)      // Macro (Cyberpunk Lila)

// ==========================================
// 3. ADAPTIVE CHANNEL LOGIC (Keltner/ATR)
// ==========================================
get_channel() =>
    basis = ta.ema(close, length)
    dev   = ta.atr(length) * mult
    upper = basis + dev
    lower = basis - dev
    [upper, lower]

// Idősíkok lekérése
[up_c, dn_c] = get_channel()
[up_1, dn_1] = request.security(syminfo.tickerid, tf1, get_channel())
[up_2, dn_2] = request.security(syminfo.tickerid, tf2, get_channel())

// ==========================================
// 4. DRAWING FAINT LINES
// ==========================================
plot(up_c, color=colChart, title="Micro Top")
plot(dn_c, color=colChart, title="Micro Bottom")

plot(up_1, color=colTf1, title="Medium Top", linewidth=2)
plot(dn_1, color=colTf1, title="Medium Bottom", linewidth=2)

plot(up_2, color=colTf2, title="Macro Top", linewidth=2)
plot(dn_2, color=colTf2, title="Macro Bottom", linewidth=2)

// ==========================================
// 5. DYNAMIC LABELS ON THE RIGHT
// ==========================================
var label lbl_up1 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=colTf1, size=size.small)
var label lbl_dn1 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=colTf1, size=size.small)

var label lbl_up2 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=colTf2, size=size.small)
var label lbl_dn2 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=colTf2, size=size.small)

if barstate.islast
    // Medium TF Feliratok
    label.set_xy(lbl_up1, bar_index + 3, up_1)
    label.set_text(lbl_up1, tf1_name + " Resistance")
    
    label.set_xy(lbl_dn1, bar_index + 3, dn_1)
    label.set_text(lbl_dn1, tf1_name + " Support")

    // Macro TF Feliratok
    label.set_xy(lbl_up2, bar_index + 3, up_2)
    label.set_text(lbl_up2, tf2_name + " Resistance")
    
    label.set_xy(lbl_dn2, bar_index + 3, dn_2)
    label.set_text(lbl_dn2, tf2_name + " Support")
````
