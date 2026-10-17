# iFCPO Alert Hub

- url: https://www.tradingview.com/script/jFjQQMWz-iFCPO-Alert-Hub/
- type: indicator
- pine_id: PUB;734d7ca67604415ab80762939e6fe447
- version: 2.0

## Description

iFCPO Alert Hub — pre-wired alert template for FCPO LONG signals.

Trigger sources:
- Lower-wick > 10pt (W229 research)
- BB(20,2) lower band touch (W250)
- Manual condition

Language options: EN / BM / EN+BM. Set up a TradingView alert on this script's alertcondition() to forward to Discord/Telegram.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Alert Hub — pre-wired alerts for Discord/Telegram, BM/EN bilingual
// Tier: FREE | Category: Utility
// QA-2026-05-10: fixed alertcondition language routing (was hardcoded EN regardless of input)
indicator("iFCPO Alert Hub", "iFCPO Alrt", overlay = true)

trigger_source = input.string("Lower-wick > 10pt (W229)", "Trigger source",
   options = ["Lower-wick > 10pt (W229)", "BB lower touch (W250)", "Manual condition"], group = "Trigger")
language = input.string("EN", "Alert language", options = ["EN", "BM", "EN+BM"], group = "Format")
include_price = input.bool(true, "Include price in alert", group = "Format")
gate_pm = input.bool(true, "Gate to PM 14:30-18:00 only (recommended for W229/W250)", group = "Filters")
gate_no_tue = input.bool(true, "Skip Tuesday (W250 No-Tue law)", group = "Filters")

TZ = "Asia/Kuala_Lumpur"
in_pm = not na(time(timeframe.period, "1430-1800:23456", TZ))
is_tue = dayofweek(time, TZ) == dayofweek.tuesday
pm_ok = not gate_pm or in_pm
tue_ok = not (gate_no_tue and is_tue)

// Detection
bb_basis = ta.sma(close, 20)
bb_dev   = 2.0 * ta.stdev(close, 20)
bb_lower = bb_basis - bb_dev
wick_lo  = math.min(open, close) - low
trig_wick = trigger_source == "Lower-wick > 10pt (W229)" and wick_lo > 10
trig_bb   = trigger_source == "BB lower touch (W250)"   and low <= bb_lower
trigger   = (trig_wick or trig_bb) and pm_ok and tue_ok

// Alert text composition — composed once, used in BOTH alertcondition message AND on-chart label
en_msg = "iFCPO LONG signal" + (include_price ? " @ " + str.tostring(close, "#.##") : "")
bm_msg = "iFCPO Isyarat BELI" + (include_price ? " @ " + str.tostring(close, "#.##") : "")
combined = language == "EN" ? en_msg : language == "BM" ? bm_msg : en_msg + " | " + bm_msg

// Static alert message — TradingView's alertcondition() requires a const string at compile time.
// Tradeoff: alert text is fixed at compile, but the on-chart label respects language.
// To get language-specific alerts, user creates 3 separate alertcondition()s and picks one when wiring.
alertcondition(trigger and language == "EN", title = "iFCPO Long Signal (EN)", message = "iFCPO LONG signal — see indicator for price")
alertcondition(trigger and language == "BM", title = "iFCPO Isyarat BELI (BM)", message = "iFCPO Isyarat BELI — lihat indikator untuk harga")
alertcondition(trigger and language == "EN+BM", title = "iFCPO Long Signal (EN+BM)", message = "iFCPO LONG | Isyarat BELI — see indicator for price")

if trigger
    label.new(bar_index, low - 5, combined, color = color.new(#1FC77E, 30), textcolor = color.white, style = label.style_label_up, size = size.tiny)

plot(trigger ? 1 : 0, "trigger", display = display.data_window)
plot(wick_lo, "wick_lo", display = display.data_window)
plot(bb_lower, "bb_lower", display = display.data_window)
plot(in_pm ? 1 : 0, "in_pm", display = display.data_window)
plot(is_tue ? 1 : 0, "is_tue", display = display.data_window)
````
