# Trado Moonbase SCALP-V4 retriever

- url: https://www.tradingview.com/script/HcftT35z-Trado-Moonbase-SCALP-V4-retriever/
- type: indicator
- pine_id: PUB;72c1c463cf0244eb9f9f66e160dc23ad
- version: 1.0

## Description

This is a script retrieving chart data with specific indicators

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// Trado Moonbase SCALP-V4 — LuxAlgo Signal Forwarder
// ═══════════════════════════════════════════════════════════════════════════════
// BARCODE:   90017
// WEBHOOK:   https://trado-backend-191750811110.europe-west1.run.app/v4/trading/luxalgo-webhook
//
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED INDICATORS ON CHART
// ═══════════════════════════════════════════════════════════════════════════════
//
//   1. LuxAlgo — OSCILLATOR        → provides: HyperWave, HyperWave Signal
//   2. LuxAlgo — SIGNALS & OVERLAYS → provides: Bar Color Value
//
// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — WHAT TO SELECT
// ═══════════════════════════════════════════════════════════════════════════════
//
//   Input 1: "🔵 OSCILLATOR: HyperWave"
//     → Click dropdown → find LuxAlgo Oscillator → pick "HyperWave"
//
//   Input 2: "🟠 OSCILLATOR: HyperWave Signal"
//     → Click dropdown → find LuxAlgo Oscillator → pick "HyperWave Signal"
//
//   Input 3: "🟢 S&O: Bar Color Value"
//     → Click dropdown → find LuxAlgo Signals & Overlays → pick "Bar Color Value"
//
//   Input 4: "⚡ TEST MODE"
//     → ON = fires every bar (for testing). OFF = fires only on crossover (production)
//
// ═══════════════════════════════════════════════════════════════════════════════
// ARCHITECTURE
// ═══════════════════════════════════════════════════════════════════════════════
//
//   Alert 1 (M1): HyperWave crossover events → server runs compute_signal_90017()
//   Alert 2 (M5): Bar Color gate refresh → server stores m5_bc
//
//   Server = pure executor. Same function as backtest.
//
// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS SETUP
// ═══════════════════════════════════════════════════════════════════════════════
//
//   Alert 1 (M1):
//     Condition: "Trado Moonbase SCALP-V4" → "Any alert() function call"
//     Timeframe: 1 minute
//     Trigger: Once per bar close
//     Webhook: https://trado-backend-191750811110.europe-west1.run.app/v4/trading/luxalgo-webhook
//     Message: {{message}}
//
//   Alert 2 (M5):
//     Same as above but Timeframe: 5 minutes
//
// ═══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Trado Moonbase SCALP-V4", overlay=true, max_bars_back=500)
// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Labels tell you EXACTLY which indicator and plot to pick
// ─────────────────────────────────────────────────────────────────────────────
hw_src  = input.source(close, "🔵 OSCILLATOR: HyperWave",
     tooltip="From LuxAlgo OSCILLATOR indicator → select 'HyperWave' plot. NOT close!")
hws_src = input.source(close, "🟠 OSCILLATOR: HyperWave Signal",
     tooltip="From LuxAlgo OSCILLATOR indicator → select 'HyperWave Signal' plot. NOT close!")
bc_src  = input.source(close, "🟢 S&O: Bar Color Value",
     tooltip="From LuxAlgo SIGNALS & OVERLAYS indicator → select 'Bar Color Value' plot. NOT close!")
test_mode = input.bool(false, "⚡ TEST MODE (fire every bar)",
     tooltip="ON = sends every bar for pipeline testing. Turn OFF for production trading!")
// ─────────────────────────────────────────────────────────────────────────────
// TIMEFRAME DETECTION
// ─────────────────────────────────────────────────────────────────────────────
is_m1 = (timeframe.period == "1")
is_m5 = (timeframe.period == "5")
// ─────────────────────────────────────────────────────────────────────────────
// ANTI-LOOKAHEAD SHIFTS (matches backtest lines 55-59)
// ─────────────────────────────────────────────────────────────────────────────
//
// Backtest:                    Pine:
//   hw[i-1]      (shift-1)  →  hw_src[1]   (last closed bar)
//   hw[i-2]      (shift-2)  →  hw_src[2]   (bar before that)
//   m5_bc[i-1]   (shift-1)  →  bc_src[1]   (last closed bar)
hw     = hw_src[1]
hw_sig = hws_src[1]
prev_hw     = hw_src[2]
prev_hw_sig = hws_src[2]
bc_val = bc_src[1]
// ── M5 BC on M1 chart (eliminates race condition with separate M5_BC alert) ──
// request.security fetches the last CONFIRMED M5 bar's BC value directly,
// so the M1_HW payload always carries the correct BC for compute_signal_90017().
// FIX F: Carry forward last confirmed M5 BC — eliminates NaN on non-boundary M1 bars
var float m5_bc_live = na
m5_bc_raw  = request.security(syminfo.tickerid, "5", bc_src[1], lookahead=barmerge.lookahead_off)
m5_bc_live := not na(m5_bc_raw) ? m5_bc_raw : m5_bc_live[1]
// ─────────────────────────────────────────────────────────────────────────────
// CROSSOVER DETECTION (matches strategy_kernel_90017.py lines 77-78)
// ─────────────────────────────────────────────────────────────────────────────
cross_up   = (hw > hw_sig) and (prev_hw <= prev_hw_sig)
cross_down = (hw < hw_sig) and (prev_hw >= prev_hw_sig)
has_cross  = cross_up or cross_down
// ─────────────────────────────────────────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────────────────────────────────────────
plot(is_m1 ? hw     : na, "HyperWave",        color=color.new(color.aqua, 0),   linewidth=2)
plot(is_m1 ? hw_sig : na, "HyperWave Signal", color=color.new(color.orange, 0), linewidth=2)
bgcolor(is_m5 and bc_val > 0 ? color.new(color.green, 88) : is_m5 and bc_val < 0 ? color.new(color.red, 88) : na, title="M5 Gate")
// Test mode — yellow tint so you know it's active
bgcolor(test_mode ? color.new(color.yellow, 95) : na, title="⚡ Test Mode Active")
plotshape(is_m1 and cross_up,   title="Cross Up",   style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 0),    size=size.small)
plotshape(is_m1 and cross_down, title="Cross Down",  style=shape.triangledown, location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.small)
// ─────────────────────────────────────────────────────────────────────────────
// WEBHOOKS
// ─────────────────────────────────────────────────────────────────────────────
//
// TEST MODE:  M1 fires every bar. M5 fires every bar.
// PRODUCTION: M1 fires only on crossover. M5 fires every bar.
// ─────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    // ── M1: HyperWave data ──
    bool should_send_m1 = is_m1 and not na(hw) and not na(hw_sig) and not na(prev_hw) and not na(prev_hw_sig)
    if should_send_m1 and (has_cross or test_mode)
        string cross_dir = cross_up ? "UP" : cross_down ? "DOWN" : "NONE"
        alert_msg = '{' +
             '"key":"scalp_v4_2026"' +
             ',"alert_type":"M1_HW"' +
             ',"ticker":"' + syminfo.tickerid + '"' +
             ',"interval":"1"' +
             ',"hw":' + str.tostring(hw, "#.########") +
             ',"hw_sig":' + str.tostring(hw_sig, "#.########") +
             ',"prev_hw":' + str.tostring(prev_hw, "#.########") +
             ',"prev_hw_sig":' + str.tostring(prev_hw_sig, "#.########") +
             ',"m5_bc":' + (na(m5_bc_live) ? "null" : str.tostring(m5_bc_live, "#.########")) +
             ',"cross":"' + cross_dir + '"' +
             ',"price":' + str.tostring(close) +
             ',"time":"' + str.format_time(time, "yyyy-MM-dd\'T\'HH:mm:ssZ", "UTC") + '"' +
             ',"test_mode":' + (test_mode ? "true" : "false") +
             ',"source":"tv_scalp_v4"' +
             '}'
        alert(alert_msg, alert.freq_once_per_bar)
    // ── M5: Bar Color gate ──
    if is_m5 and not na(bc_val)
        alert_msg = '{' +
             '"key":"scalp_v4_2026"' +
             ',"alert_type":"M5_BC"' +
             ',"ticker":"' + syminfo.tickerid + '"' +
             ',"interval":"5"' +
             ',"m5_bc":' + str.tostring(bc_val, "#.########") +
             ',"price":' + str.tostring(close) +
             ',"time":"' + str.format_time(time, "yyyy-MM-dd\'T\'HH:mm:ssZ", "UTC") + '"' +
             ',"test_mode":' + (test_mode ? "true" : "false") +
             ',"source":"tv_scalp_v4"' +
             '}'
        alert(alert_msg, alert.freq_once_per_bar)
````
