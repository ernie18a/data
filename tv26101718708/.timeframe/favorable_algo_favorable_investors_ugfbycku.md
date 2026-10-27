# Favorable Algo [Favorable Investors]

- url: https://www.tradingview.com/script/UgfbYCku-Favorable-Algo-Favorable-Investors/
- type: indicator
- pine_id: PUB;489859bd69784158b082c5b58bc40702
- version: 2.0

## Description

[symbol="AMEX:SPY"]AMEX:SPY[/symbol] [image]https://www.tradingview.com/x/fqw2cN7x/[/image]🎯 FAVORABLE ALGO V21.2 — by Favorable Investors

A serious HTF Supply/Demand ARM-and-TRIGGER engine with a closed-loop AI Adaptive Auto-Tuner that self-optimizes settings from live performance. No hype. No repainting tricks. No black box. Just real institutional-style logic, exposed and tunable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT IT ACTUALLY DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Maps real HTF Supply & Demand zones (Daily / 4H / 1H / current TF) using Order-Block detection — the last opposing candle before the impulse, wick + body included.

2. When price taps a zone, the engine ARMS that side (long or short) and watches LTF for a valid trigger:
   • Reversal/rejection candle
   • 5-pillar confluence stack
   • Oscillator extreme turn
   • HTF SuperTrend alignment

3. First valid trigger fires a 🟢 BUY or 🔴 SELL signal with full TP1 / TP2 / TP3 + SL.

4. ARMED state auto-expires intelligently:
   • Window timeout
   • Break-of-Structure through far face of zone
   • Run-away (price moved away too far, you missed the entry)
   • Regime flip (opposite zone tapped)
   • Opposite side fires

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 AI ADAPTIVE AUTO-TUNER (NEW)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Closed-loop, every N bars (default 100), reads:
   • Rolling Win Rate (last 50 trades)
   • Profit Factor
   • Sharpe Ratio
   • ATR ratio (volatility regime)
   • Discrete regime score (-2 to +2)

Then mutates EFFECTIVE TP / SL / Confluence / ARM Window / Proximity — never touching your raw inputs.

Decision logic:
   ❄️ FROZEN     — WR ≥ freeze threshold + Sharpe ≥ 1.0 → no changes (don't break what works)
   🛡️ DEFENSIVE  — Sharpe < 0 or WR < 50%  → tighten everything
   ⚠️ MILD TIGHT — WR < 60% or PF < 1.5    → +1 conf, smaller TP1
   💎 OPPORTUNIST — WR ≥ 75% + idle market → loosen for more signals
   🚀 TP3 RUN    — strong regime + WR ≥ 70% → push TP3 farther
   📈 VOL SCALE  — high vol → wider TP/SL, low vol → tighter

Anti-oscillation built in: bounded clamps, hard min-interval, single-step deltas, frozen-when-winning logic.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 FOUR WIN-RATE PROFILES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   • 🎯 Sniper — 5/5 confluence, tight TP, exit-at-TP1 (~85-90% WR target)
   • ⚖️ Balanced — 4/5 confluence, medium TP (~70-80% WR target)
   • 🔥 Aggressive — 3/5 confluence, larger TP, more signals
   • ⚙️ Custom — full manual control

PLUS a 🔓 Manual Override Layer that lets you dial TP / SL / Conf / Proximity from inside ANY profile without leaving Sniper or Balanced or Aggressive.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 WALK-FORWARD AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tracks Sniper / Balanced / Aggressive in parallel as virtual profiles and surfaces the best one by Sharpe / Win Rate / Profit Factor — so you can see in real time which profile this asset actually prefers.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 DASHBOARD (real signal, no clutter)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   • Live ARM/TRIGGER status + countdown
   • In-trade P&L, TP1/2/3 progress, trailing SL
   • Rolling WR · PF · Sharpe · streak
   • Walk-Forward profile leaderboard
   • 🤖 Tuner status: ACTIVE / FROZEN / WAITING + next-update countdown
   • Live effective TP/SL/Conf values being used right now
   • ADX, RSI, regime, HTF zones counter

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS (full coverage)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   • ARMED LONG / SHORT
   • ARM EXPIRE (timeout/BOS/runaway/flip)
   • BUY / SELL fire
   • TP1 / TP2 / TP3 hit
   • Trade Exit
   • Price At HTF Demand / Supply
   • AI Regime Changed
   • 🤖 Tuner Adjusted Parameters
   • ❄️ Tuner Frozen

All alert messages are webhook-ready for automation (BloFin, MT5 bridges, Discord webhooks, etc).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 PREMIUM VISUALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   • 4 themes — Neon Teal / Midnight Fire / Arctic Aurora / Ruby
   • HTF zones extend right (50-bar projection, configurable)
   • Armed zones glow + 🎯 ARMED label
   • Bar coloring during trades
   • Optional EMA ribbon
   • Clean trade markers + W/L tags

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️ WHO IT'S FOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Active discretionary and semi-quant traders who want institutional-style HTF S/D logic in code, with the option to either trust the AI tuner or fully manual-tune. Built by a real retail trader running this live in crypto + futures + equities.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ HONEST DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This is an indicator, not financial advice. Past performance never guarantees future results. The AI tuner reduces parameter-tuning friction, it does not eliminate market risk. Always size positions for the worst-case, not the dashboard.

Built by Derek Medina · Favorable Investors

## Source Code

````pine
//@version=6
// ============================================================================
// FAVORABLE ALGO V21.7  |  FAVORABLE INVESTORS  |  DEREK MEDINA
// ----------------------------------------------------------------------------
// HTF S/D ARM-AND-TRIGGER + AI ADAPTIVE TUNER + 🧬 DNA + 💰 PF GUARDIAN
// + 🎯 MULTI-TP + ⚡ ENTRY-TIME ATR + 🚀 MOMENTUM EXEMPT
// + 🧭 ZONE POLARITY LOCK + 🔁 RE-ARM PER TAP + 🪞 REACTION RELAX
// + 🧪 ADAPTIVE EMA + 🎚 CF AUTO-TUNE + 🌡 VOL-REGIME TP + 💀 SLEEPER SUPPRESS + 🎯 REALIZED-RR + 🔬 ASSET MEMORY
//
// NEW IN V21.7 — HYPER-ADAPTIVE PER-ASSET CALIBRATION:
//   🧪 ADAPTIVE EMA LENGTHS (DNA-class-driven)
//      • V21.6 used hard-coded EMAs (9/13/21/50/89/200) regardless of asset.
//      • V21.7 lets DNA class scale EMA periods: TRENDER → faster (5/8/13/34/55),
//        MOMENTUM → medium-fast (9/13/21/50/89), RANGER → default (9/13/21/50/89),
//        CHOPPER → slower (13/21/34/55/144), SLEEPER → slowest (21/34/55/89/233).
//      • Faster EMAs on TRENDER capture early breakouts; slower on SLEEPER
//        avoids whipsaw entries in dead chop.
//
//   🎚 PER-ASSET CF AUTO-TUNE (closed-loop CF threshold)
//      • Drives the 0–5 confluence floor up when realized PF<1 + WR<55%,
//        down when PF>1.8 + WR>70% — within bounded range so it can never
//        invert below user input.
//      • Decoupled from main tuner cycle so it reacts faster to per-asset rot.
//
//   🌡 VOLATILITY-REGIME TP MULTIPLIER
//      • atrPct < 0.20%: shrink TP ladder ×0.85 (low-vol assets need closer targets)
//      • atrPct 0.20–0.50%: neutral ×1.00
//      • atrPct 0.50–1.00%: expand ×1.10
//      • atrPct > 1.00%: expand ×1.25 (high-vol can ride bigger moves)
//      • ALL multipliers respect TP1 absolute floor (≥0.40%) + per-DNA floor.
//
//   💀 SLEEPER AUTO-SUPPRESS
//      • When DNA = SLEEPER and PF<1.0 over min trades → BLOCK new entries entirely.
//      • Frees the tuner from trying to fix unfix-able assets (AMZN-style chop).
//      • Auto-clears when DNA reclassifies away from SLEEPER OR PF recovers above 1.2.
//
//   🎯 REALIZED-RR FEEDBACK
//      • Tracks rolling avgWin% and avgLoss% from closed trades.
//      • If avgWin < avgLoss × 0.6 (we're losing 1.7× what we win), force-widen TP1
//        by +20% per cycle until ratio recovers.
//      • If avgWin > avgLoss × 2.0 (winning much more than losing), let TP3 run wider.
//
//   🔬 ASSET MEMORY (best-cal snapshot)
//      • When PF ≥ 2.0 + WR ≥ 70% + tTot ≥ minT → snapshots eff_tp1/tp2/tp3/conf/armW.
//      • If asset later degrades (PF<1.0), tuner can REVERT to last known good cal.
//      • Per-symbol via ticker.id() check.
//
//   📊 DASHBOARD ROWS 56–60
//      • 🧪 ADAPTIVE EMA — active EMA preset (TRENDER-FAST / DEFAULT / SLEEPER-SLOW)
//      • 🎚 CF AUTO-TUNE — current CF floor + last delta
//      • 🌡 VOL-REGIME    — atrPct bucket + active TP multiplier
//      • 💀 SLEEPER LOCK  — SLEEPER suppression status
//      • 🎯 REAL-RR       — avgWin/avgLoss + corrective action
//
// PRESERVED FROM V21.6 (no regressions):
//   🧭 Zone polarity lock | 🔁 Re-arm per zone-touch | 🪞 Reaction relax | 🚫 Wrong-side veto
// PRESERVED FROM V21.5:
//   🎯 Multi-TP plotting | ⚡ Entry-time ATR | 🚀 Momentum exempt | 🛡 Veto delta hysteresis
//
// PRIOR V21.6 INTRO:
// ----------------------------------------------------------------------------
// V21.6 — ZONE-POLARITY ENFORCEMENT + RE-ARM + REACTION CAPTURE:
//   🧭 ZONE POLARITY LOCK (kills BUY-at-supply / SELL-at-demand)
//
// (V21.6 details retained below for context)
// (skip-marker)
//      • STRICT polarity gate: BUY only when price is closer to demand than
//        supply (or only demand zone in proximity). SELL only when closer to
//        supply. Refuses to fire when price is mid-range or wrong side.
//      • Optional dist-ratio threshold (default 0.45) — price's distance to
//        demand vs supply. < 0.45 → buy-eligible, > 0.55 → sell-eligible.
//      • "WRONG-SIDE VETO" hard-blocks longs in upper third, shorts in lower.
//
//   🔁 RE-ARM PER ZONE-TOUCH (multiple signals per active zone)
//      • V21.5 fired ONE arm per zone life. V21.6 detects each FRESH TAP
//        (price exited the zone for N bars then returned) of an active,
//        un-broken zone and allows a new arm.
//      • Configurable min-bar gap between re-arms (default 8 bars) so we
//        don't double-fire on the same wick.
//      • Zone must still be ACTIVE (not broken via BOS) and HTF bias aligned.
//      • Per-zone tap counter (zoneTapCntL/S) feeds the dashboard.
//
//   🪞 REACTION RELAX (capture more clean zone respects)
//      • V21.5 missed valid bounces because revLong required strict pin-bar
//        geometry (wick > body × 0.5). V21.6 widens to FOUR rejection forms:
//          (a) Pin/hammer (lowWick > body × 0.4)  — looser than 0.5
//          (b) Bull engulfing of prior bar at zone
//          (c) Body bounce: 2-bar body close above zone top after wick in
//          (d) ATR-context: small-body close within zone + next bar bullish
//      • ANY of the four = valid rejection (was AND-of-strict-conditions).
//      • Symmetric for shorts at supply.
//      • Toggle: i_reactionRelax (default ON).
//
//   🚫 WRONG-SIDE VETO (separate from asset-level veto)
//      • Computes price's normalized position in the active HTF range
//        (0 = at demand, 1 = at supply).
//      • Long signals require pos ≤ i_wrongSideMaxL (default 0.40).
//      • Short signals require pos ≥ i_wrongSideMinS (default 0.60).
//      • Independent of momentum exemption — this is a structural sanity guard.
//
//   📊 DASHBOARD ROWS 52–55
//      • 🧭 ZONE POL  — polarity verdict (BUY-eligible / SELL-eligible / neutral)
//      • 🔁 RE-ARM    — zone tap counter + bars since last tap
//      • 🪞 REACTION  — which rejection form fired (or none)
//      • 🚫 WRONG-SIDE — normalized position + L/S eligibility
//
// PRESERVED FROM V21.5 (no regressions):
//   🎯 TP1/TP2/TP3 always plotted | ⚡ Entry-time ATR | 🚀 Momentum exempt
//   🛡 Veto delta hysteresis | All V21.4 features
//
// PRIOR V21.5 INTRO:
// ----------------------------------------------------------------------------
// V21.5 — TP VISIBILITY + ADAPTIVENESS + VETO/RUNAWAY SANITY:
//   🎯 TP1 / TP2 / TP3 ALWAYS PLOTTED (no more single "TP" label)
//      • All three TP horizontal lines drawn on every entry
//      • Distinct colored labels: TP1 (solid bright), TP2 (mid), TP3 (faint)
//      • Even in Exit@TP1 mode, TP2/TP3 shown as informational dashed lines
//      • You see the full ladder at the moment of entry, every time
//
//   ⚡ ENTRY-TIME ATR AUTOSCALE (no more "first trade gets stale 0.25%")
//      • ATR autoscaler now runs at ENTRY MOMENT, not just in tuner cycles
//      • Tuner blend bumped 30% → 50% per cycle for faster convergence
//      • Per-class TP floors: TRENDER/MOMENTUM ≥ 0.50%, RANGER ≥ 0.40%,
//        CHOPPER ≥ 0.30%, SLEEPER ≥ 0.25% — protects against micro-TPs
//      • TP1 minimum % floor (configurable, default 0.30%) hard-clamped
//      • Snapped (not blended) on first 3 tuner cycles for fast catch-up
//
//   🚀 MOMENTUM EXEMPTION (no more "strong breakout = ARM cancelled")
//      • If price runs away from zone with strong momentum (vol > 1.3× avg
//        AND ADX > 25 AND aligned trend), DO NOT cancel ARM as runaway
//      • Treats it as positive confluence — late-fire trigger allowed within
//        configurable bar window even after BOS/runaway condition
//      • Configurable: i_momentumExempt (true), i_momLateBars (5)
//
//   🛡 VETO RECOVERY FIX (no more permanent latch)
//      • Recovery now uses DELTA hysteresis: clear when WR ≥ vetoWR + i_vetoHyst
//        (default +10pts). So vetoWR=40 → clears at 50, not 60.
//      • Auto-clear after N bars with no trades (configurable, default 200)
//      • One-click manual override: i_vetoForceOff resets veto immediately
//
//   ⚖️  RR + TP-FLOOR DOUBLE GUARD
//      • RR floor (V21.4) PLUS new absolute TP1·% floor (V21.5)
//      • Both must pass — wider of the two wins, never accidentally tight
//
// PRESERVED FROM V21.4 (no regressions):
//   💰 PF GUARDIAN (fixes "high WR / negative PnL" disaster)
//   📏 ATR-AWARE TP AUTOSCALER (now applied at entry too)
//   📊 DEEPER ROLLING STATS (configurable window 50–500)
//   🛡 VETO HARDENING (idle clear, tTot=0 guard)
//
// PRIOR V21.4 INTRO:
// ----------------------------------------------------------------------------
// V21.4 — PROFIT FACTOR GUARDIAN + ATR-AWARE TP + DEEPER STATS:
//   💰 PF GUARDIAN (fixes "high WR / negative PnL" disaster)
//      • Detects WHEN: WR ≥ 60% but PF < 1.0 (wins too small vs losses)
//      • Action: WIDENS TP1 + tightens SL until math forces PF ≥ minRR
//      • Min Risk:Reward floor (default 1.2) so even 60% WR cannot bleed
//      • Independent of defensive/mild-tight branches (runs LAST, overrides)
//
//   📏 ATR-AWARE TP AUTOSCALER
//      • Computes asset's ATR-as-%-of-price baseline
//      • Auto-scales TP1/2/3 to atrPct × multiplier (so 0.25% TP becomes
//        0.6% on a 0.4% ATR ticker like ANET, 0.15% on a 0.1% ATR ticker)
//      • Eliminates the "fixed 0.25% TP across all assets" failure mode
//
//   📊 DEEPER ROLLING STATS (50 → user-selectable up to 500)
//      • Configurable rolling window so historical signal is stronger
//      • Separate short-term (last 20) vs long-term (last N) WR/PF
//      • Tuner uses long-term for stability, short-term for reactivity
//
//   🛡 VETO HARDENING
//      • Veto NEVER fires with tTot=0 (was a bug edge case)
//      • Auto-clears when tTot=0 (fresh chart) regardless of stale rollWR
//      • "Idle clear" after N bars without trades + tuner WAITING
//
//   🔬 PER-CLASS ATTRIBUTION
//      • New dashboard row: which DNA class produces best PF on THIS chart
//      • Helps decide if asset is fundamentally tradeable
//
// PRESERVED FROM V21.3:
//   • 🧬 Asset DNA Profiler (5 classes, score-based classification)
//   • 🎯 Auto-Calibrator (per-class baseline presets)
//   • 💀 Asset Veto + tuner acceleration
//   • Dashboard rows + alerts + chart label
//
// PRIOR V21.3 INTRO:
//   🧬 ASSET DNA PROFILER
//      • First N bars of history fingerprint the symbol:
//          - Trendiness (ADX mean, EMA stack persistence)
//          - Choppiness (range-bound vs directional move ratio)
//          - Volatility character (ATR/price)
//          - Mean-reversion vs momentum bias
//          - Zone-respect score (how often HTF zones hold)
//          - Average session range
//      • Classifies asset into one of 5 regimes:
//          TRENDER ↑ / RANGER ↔ / CHOPPER ⚡ / MOMENTUM 🚀 / SLEEPER 💤
//
//   🎯 AUTO-CALIBRATION (runs BEFORE tuner)
//      • Each asset gets its own baseline preset based on DNA, not a global default
//      • TRENDER  → Sniper-style: 5/5 conf, tight TP, exit@TP1, fresh-zones-only
//      • MOMENTUM → Aggressive: 3/5 conf, bigger TP3, trail SL
//      • RANGER   → Mean-reversion: 4/5 conf, smaller TPs, faster exits
//      • CHOPPER  → Defensive: 5/5 conf, wide SL, OB-only zones
//      • SLEEPER  → Tight TPs, no leverage scaling
//
//   💀 ASSET VETO
//      • If DNA flags asset as hostile (chop>thresh + zone-respect<thresh)
//        OR rolling WR < 40% after 8 trades → BLOCK new trades, show warning
//      • Veto auto-clears when WR recovers OR user manually toggles
//
//   🚀 TUNER ACCELERATION on bad assets
//      • If WR < 50% after 5 trades AND DNA = hostile → tuner runs every 25 bars
//        (vs default 100) and applies aggressive defensive mutations
//
// PRESERVED FROM V21.2:
//   • Manual Override Layer (Allow Manual TP/SL/Conf Override toggle)
//   • 🤖 AI Adaptive Auto-Tuner (closed-loop, frozen-when-winning)
//   • ARM → WATCH → FIRE state machine
//   • Order Block zones (last opposing candle, wick + body)
//   • Right-extending HTF zone boxes
//
// LEGACY FEATURES (V21.2 changelog):
//   🔓 MANUAL OVERRIDE LAYER
//      • "Allow Manual TP/SL/Conf Override" toggle lets your manual values
//        beat Sniper/Balanced/Aggressive presets without leaving the profile
//      • Per-category override flags (TP / SL / Conf+ARM / Proximity)
//      • No more locked TP — you can dial it from any profile
//
//   🤖 AI ADAPTIVE AUTO-TUNER (closed-loop self-optimization)
//      • Every N bars (default 100), evaluates rolling perf telemetry:
//          rolling Win Rate / Profit Factor / Sharpe / ATR-ratio / regime
//      • Mutates EFFECTIVE TP/SL/Conf/ARM-window/Proximity — never your inputs
//      • Decision logic:
//          DEFENSIVE   — Sharpe<0 or WR<50  → tighten conf/TP/SL hard
//          MILD TIGHT  — WR<60 or PF<1.5    → +1 conf, narrower ARM, smaller TP1
//          OPPORTUNIST — WR>=75 + idle      → -1 conf, wider TP2/TP3, bigger ARM
//          TP3 RUN     — strong regime + WR>=70 → push TP3 farther
//          VOL SCALE   — atrRatio>1.3 wider px+SL, <0.8 tighter px+SL
//      • FROZEN-WHEN-WINNING: WR ≥ freeze-threshold AND Sharpe ≥ 1.0 → no changes
//      • Anti-oscillation: bounded ranges, hard min-interval, single-step deltas
//      • Tuner Aggressiveness multiplier + per-scope toggle
//      • Decision labels on chart, dashboard rows, alert conditions
//
// PRESERVED FROM V21.1 (no regressions):
//   • ARM → WATCH → FIRE state machine with full per-side state vars
//   • Order-Block zones (last opposing candle before impulse, wick + body)
//   • Right-extending HTF zone boxes
//   • Multi-TF SMC zones (D / 4H / 1H / Current TF)
//   • Walk-Forward AI virtual profile tracking
//   • AI Regime engine + counter-trend block
//   • 5-pillar confluence + reversal/oscillator filters
//   • Profile presets (Sniper / Balanced / Aggressive / Custom)
//   • Full dashboard, themes, alerts, P&L tracking, streak meter
// ============================================================================
indicator("Favorable Algo V21.7 [Favorable Investors]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500, max_bars_back=1000)

// ============================================================================
// ——— INPUTS ———
// ============================================================================
var string GP  = "🎯 Win Rate Profile (Master Preset)"
var string GM  = "🎯 ARM / TRIGGER Engine"
var string GS  = "SMC Zone Settings"
var string GA  = "AI Auto-Optimization"
var string GAT = "🤖 AI Adaptive Tuner"
var string GDNA= "🧬 Asset DNA Auto-Calibrator"
var string GPF = "💰 PF Guardian + ATR Autoscale (V21.4)"
var string GV5 = "🚀 V21.5 — Multi-TP + Momentum + Veto Sanity"
var string GV6 = "🧭 V21.6 — Zone Polarity + Re-Arm + Reaction Relax"
var string GV7 = "🔬 V21.7 — Hyper-Adaptive Per-Asset Calibration"
var string GW  = "Walk-Forward Optimizer"
var string GC  = "Signal Confluence (Manual Override)"
var string GR  = "Risk Management"
var string GT  = "Take Profit Method"
var string GO  = "🔓 Manual Override"
var string GD  = "Display"

// ——— MASTER PRESET ———
i_winMode = input.string("Sniper (Max WR)", "Win Rate Mode", group=GP, options=["Sniper (Max WR)", "Balanced", "Aggressive (More Signals)", "Custom"], tooltip="Sniper = 5/5 confluence, tight TP, exit at TP1, ~85-90% WR target.\nBalanced = 4/5 confluence, medium TP, ~70-80% WR.\nAggressive = 3/5 confluence, larger TP, more signals ~50-60% WR.\nCustom = use your manual settings below.")

// ——— ARM / TRIGGER ENGINE ———
i_armOn       = input.bool(true,  "Enable ARM/TRIGGER Engine",         group=GM, tooltip="When ON: zone tap ARMS the system, then watches LTF for trigger. When OFF: legacy V20 single-bar signal mode.")
i_armWindow   = input.int(20,     "ARM Watch Window (bars)",           group=GM, minval=3, maxval=200, tooltip="How many bars after a zone tap the system stays ARMED waiting for a trigger. Auto-overridden by profile unless Custom.")
i_armRunAway  = input.float(2.0,  "Run-Away Cancel (ATR)",             group=GM, minval=0.5, maxval=10.0, step=0.25, tooltip="If price moves more than this ATR distance away from the zone in trade direction without firing, cancel the ARM (you missed the entry).")
i_armBOSBuf   = input.float(0.4,  "Zone-Break Buffer (ATR)",           group=GM, minval=0.05, maxval=2.0, step=0.05, tooltip="ATR buffer used to detect Break-Of-Structure through the far face of the zone (auto-disarm).")
i_armNeedRev  = input.bool(true,  "Trigger Needs Reversal Candle",     group=GM, tooltip="If ON, an armed state only fires when a reversal/rejection candle prints. If OFF, confluence alone can trigger.")
i_armNeedConf = input.int(3,      "Trigger Min Confluence (of 5)",     group=GM, minval=1, maxval=5, tooltip="Minimum confluence pillars required for an armed state to FIRE. Auto-overridden by profile unless Custom.")
i_armGlow     = input.bool(true,  "Glow Armed Zone",                   group=GM, tooltip="Brighten the zone border + thicken edges while armed.")

// ——— SMC Zones ———
i_swingLen   = input.int(10,   "Swing Length",                group=GS, minval=2,   maxval=50)
i_histKeep   = input.int(8,    "Zones To Keep / TF",          group=GS, minval=2,   maxval=20)
i_obLook     = input.int(5,    "Order Block Lookback (bars)", group=GS, minval=1,   maxval=15, tooltip="How many bars BEFORE the pivot to scan for the last opposing candle (the true order block).")
i_obMinBody  = input.float(0.0,"OB Min Body (ATR)",            group=GS, minval=0.0, maxval=3.0, step=0.05, tooltip="Skip tiny doji-like opposing candles. 0 = accept any.")
i_obFallback = input.bool(true,"Fallback to Pivot Wick if no OB", group=GS, tooltip="If no opposing candle found in window, use the pivot wick + ATR buffer (legacy behavior).")
i_zoneExt    = input.int(50,   "Zone Extend Right (bars)",    group=GS, minval=5,   maxval=500, tooltip="How far past the current bar to project zone boxes.")
i_boxWidth   = input.float(2.5,"Fallback Width (ATR mult)",   group=GS, minval=0.5, maxval=10.0, step=0.25, tooltip="Only used when fallback to pivot wick is active.")

i_showD      = input.bool(true,  "Daily Zones",   group=GS, inline="tf")
i_show4h     = input.bool(true,  "4H Zones",      group=GS, inline="tf")
i_show1h     = input.bool(true,  "1H Zones",      group=GS, inline="tf")
i_showCur    = input.bool(false, "Current TF",    group=GS, inline="tf")

i_dSupCol    = input.color(color.new(#FF4444, 60),  "D Supply",    group=GS, inline="d")
i_dDemCol    = input.color(color.new(#0088FF, 60),  "D Demand",    group=GS, inline="d")
i_h4SupCol   = input.color(color.new(#FF8800, 65),  "4H Supply",   group=GS, inline="h4")
i_h4DemCol   = input.color(color.new(#00CCFF, 65),  "4H Demand",   group=GS, inline="h4")
i_h1SupCol   = input.color(color.new(#FF6699, 70),  "1H Supply",   group=GS, inline="h1")
i_h1DemCol   = input.color(color.new(#00FFAA, 70),  "1H Demand",   group=GS, inline="h1")
i_curSupCol  = input.color(color.new(#EDEDED, 75),  "LTF Supply",  group=GS, inline="ltf")
i_curDemCol  = input.color(color.new(#00FFFF, 75),  "LTF Demand",  group=GS, inline="ltf")

// ——— AI Auto-Optimization ———
i_aiOn       = input.bool(true,  "Enable AI Regime Engine", group=GA, tooltip="Detects market regime and adjusts proximity buffer + counter-trend block.")
i_aiLook     = input.int(50,     "Regime Lookback",         group=GA, minval=20, maxval=200)
i_showRegime = input.bool(true,  "Show Regime Label",       group=GA)

// ——— 🔓 Manual Override (works even outside Custom profile) ———
i_manualOverride = input.bool(false, "Allow Manual TP/SL/Conf Override",  group=GO, tooltip="When ON, your manually set TP%, TP-ATR, SL ATR, Confluence, ARM Window values BELOW take priority over Sniper/Balanced/Aggressive presets. Lets you tune any profile without switching to Custom.")
i_overrideTP     = input.bool(true,  "Override TPs",                     group=GO)
i_overrideSL     = input.bool(true,  "Override SL",                      group=GO)
i_overrideConf   = input.bool(false, "Override Confluence + ARM",        group=GO)
i_overridePx     = input.bool(false, "Override Zone Proximity",          group=GO)

// ——— 🤖 AI Adaptive Tuner (closed-loop self-optimization) ———
i_tunerOn       = input.bool(true,  "Enable AI Adaptive Tuner",          group=GAT, tooltip="Closed-loop tuner: every N bars, mutates effective TP/SL/Conf/ARM/Proximity from rolling Win Rate, Profit Factor, Sharpe, ATR-ratio and regime. Never edits your raw inputs \u2014 only effective runtime values. Frozen-when-winning logic prevents oscillation.")
i_tunerBars     = input.int(100,    "Re-Tune Every N Bars",              group=GAT, minval=25, maxval=1000, tooltip="How often the tuner re-evaluates and may adjust effective parameters.")
i_tunerMinT     = input.int(10,     "Min Trades Before Tuning",          group=GAT, minval=3,  maxval=200, tooltip="Tuner stays neutral until enough closed trades are recorded.")
i_tunerFreezeWR = input.float(80.0, "Freeze When Win Rate ≥ (%)",        group=GAT, minval=50.0, maxval=100.0, step=1.0, tooltip="If rolling WR is above this AND Sharpe ≥ 1.0, the tuner stops changing settings. Don't fix what's working.")
i_tunerAggro    = input.float(1.0,  "Tuner Aggressiveness",              group=GAT, minval=0.25, maxval=2.5, step=0.25, tooltip="Multiplier on each adjustment step. <1 conservative, >1 aggressive.")
i_tunerScope    = input.string("All", "Tune Scope",                      group=GAT, options=["All","TP only","SL only","Conf only","Px only"], tooltip="Limit which params the tuner is allowed to mutate.")
i_tunerLog      = input.bool(true,  "Log Tuner Decisions to Chart",      group=GAT, tooltip="Print a small label every time the tuner mutates a parameter.")

// ——— 🧬 Asset DNA Auto-Calibrator (per-asset adaptation) ———
i_dnaOn         = input.bool(true,  "Enable Asset DNA Auto-Calibrator",  group=GDNA, tooltip="Fingerprints the symbol from history (trendiness, chop, vol, zone-respect) and picks an asset-specific baseline preset BEFORE trading. Different stocks need different settings \u2014 this is what makes that automatic.")
i_dnaWarmup     = input.int(300,    "DNA Warm-Up Bars",                  group=GDNA, minval=100, maxval=1000, tooltip="How many bars of history are analyzed to fingerprint the asset. 300 = ~3 days on 15m, ~30 days on 1h.")
i_dnaRefresh    = input.int(500,    "DNA Refresh Every N Bars",          group=GDNA, minval=100, maxval=5000, tooltip="Re-fingerprint periodically so settings adapt to regime drift over weeks/months.")
i_dnaForce      = input.string("Auto", "Force Asset Class",              group=GDNA, options=["Auto","Trender","Momentum","Ranger","Chopper","Sleeper"], tooltip="Auto = let DNA decide. Otherwise hard-pin a specific class (manual override of the calibrator).")
i_dnaShowLabel  = input.bool(true,  "Show DNA Verdict Label",            group=GDNA)

// ——— Asset Veto (hostile-asset block) ———
i_vetoOn        = input.bool(true,  "Enable Asset Veto on Hostile Symbols", group=GDNA, tooltip="Block new trades if DNA flags asset as hostile + recent perf is bad. Stops the indicator from bleeding money on assets it cannot trade.")
i_vetoWR        = input.float(40.0, "Veto Trigger: Win Rate Below (%)",  group=GDNA, minval=10.0, maxval=70.0, step=1.0)
i_vetoMinT      = input.int(8,      "Veto Trigger: Min Trades First",    group=GDNA, minval=3,    maxval=50)
i_vetoRecover   = input.float(60.0, "Veto Auto-Clear: WR Recovers To (%)", group=GDNA, minval=40.0, maxval=90.0, step=1.0)
i_vetoBypass    = input.bool(false, "Bypass Veto (force trading anyway)", group=GDNA, tooltip="Override the veto and keep trading despite the warning. Not recommended.")

// ——— V21.4: 💰 PF Guardian + 📏 ATR-Aware TP + 📊 Deeper Stats ———
i_pfGuardOn    = input.bool(true,  "Enable 💰 PF Guardian (fixes high-WR / neg-PnL)", group=GPF, tooltip="When rolling WR is decent (≥60%) but PF is bad (<1.0), wins are too small relative to losses. Guardian forces TP1 wider and SL tighter until math works again.")
i_pfMinPF      = input.float(1.10, "PF Guardian: Trigger When PF Below",            group=GPF, minval=0.5, maxval=2.0, step=0.05, tooltip="PF below this with WR≥60% triggers TP-widening + SL-tightening cycles.")
i_pfMinRR      = input.float(1.20, "Minimum Risk:Reward (TP1÷SL)",                 group=GPF, minval=0.5, maxval=3.0, step=0.05, tooltip="Hard floor: TP1 must be at least this many times the SL distance. Below 60% WR you need RR>1, above 80% you can run RR<1 — 1.2 is a safe default.")
i_pfWidenStep  = input.float(0.15, "PF Guardian: TP Widen per Cycle (×)",           group=GPF, minval=0.05, maxval=0.50, step=0.01, tooltip="How much to widen TP each tuner cycle when PF is broken. 0.15 = +15% per cycle.")
i_pfTightStep  = input.float(0.08, "PF Guardian: SL Tighten per Cycle (×)",         group=GPF, minval=0.02, maxval=0.30, step=0.01, tooltip="How much to tighten SL each cycle. Combined with TP widen pushes RR up fast.")

i_atrAutoOn    = input.bool(true,  "Enable 📏 ATR-Aware TP Autoscale",                group=GPF, tooltip="Auto-scales effective TP/SL to the asset's true volatility. ANET (0.4% ATR) gets ~0.6% TP, IWM (0.18% ATR) gets ~0.27% TP. No more fixed 0.25% across all assets.")
i_atrTPmult    = input.float(1.50, "ATR Autoscale: TP1 = ATR·%  × N",               group=GPF, minval=0.5, maxval=5.0, step=0.1, tooltip="TP1 percentage = (ATR/price×100) × this multiplier. 1.5 = TP1 sits at ~1.5 candles of average movement.")
i_atrSLmult    = input.float(1.20, "ATR Autoscale: SL = ATR·%  × N",                group=GPF, minval=0.5, maxval=5.0, step=0.1, tooltip="SL percentage on the same ATR·% basis. Combined with TP mult sets baseline RR.")
i_atrFloor     = input.float(0.10, "ATR Autoscale: TP1 Floor (%)",                 group=GPF, minval=0.05, maxval=2.00, step=0.05, tooltip="Hard minimum TP1% so super-low-vol tickers don't shrink to noise.")

i_rollLong     = input.int(150,    "📊 Long-Term Rolling Window (trades)",           group=GPF, minval=20, maxval=500, tooltip="Bigger window = more stable WR/PF stats for tuner decisions. 50 was V21.3 default; 150 gives 3x more historical signal.")
i_rollShort    = input.int(20,     "📊 Short-Term Rolling Window (trades)",          group=GPF, minval=5,  maxval=50,  tooltip="Reactive window for spotting recent regime breaks. Tuner accelerates when short-term WR collapses below long-term.")

// ——— V21.5: Multi-TP visibility + faster ATR + momentum exemption + veto sanity ———
i_alwaysShowAllTPs = input.bool(true, "🎯 Always Show TP1 / TP2 / TP3 Lines",      group=GV5, tooltip="Force render all three TP horizontal lines on every entry, even in Exit@TP1 mode (TP2/TP3 shown as informational dashed lines so you see the full ladder).")
i_atrSnapCycles    = input.int(3,    "⚡ ATR Autoscaler: SNAP for first N tuner cycles", group=GV5, minval=0, maxval=10, tooltip="For the first N tuner runs after a fresh chart, the ATR autoscaler snaps eff_tp1 directly to the ATR target (no smoothing) for fast catch-up. After that, it blends.")
i_atrBlendFast     = input.float(0.50, "⚡ ATR Autoscaler: Blend Per Cycle (0–1)",     group=GV5, minval=0.10, maxval=1.00, step=0.05, tooltip="How aggressively eff_tp1 moves toward ATR target each tuner cycle. V21.4 used 0.30 (slow). 0.50 = converges in ~3 cycles.")
i_atrEntryAuto     = input.bool(true, "⚡ Apply ATR Autoscaler at ENTRY (not just tuner)", group=GV5, tooltip="V21.4 only applied ATR autoscale on tuner cycles — first trade got stale TP. V21.5 applies it at entry moment so even the first trade has adaptive TP.")
i_tp1FloorPct      = input.float(0.40, "⚡ Hard Floor: TP1 ≥ % (Fixed-% mode)",         group=GV5, minval=0.05, maxval=2.00, step=0.05, tooltip="V21.7: Bumped to user-stated absolute minimum 0.40%. Stops the 0.21–0.25% micro-TP failure mode (PYPL/AMZN-style) regardless of ATR or class.")
i_perClassFloor    = input.bool(true, "⚡ Apply Per-DNA-Class TP1 Floors",            group=GV5, tooltip="TRENDER/MOMENTUM ≥ 0.50%, RANGER ≥ 0.40%, CHOPPER ≥ 0.30%, SLEEPER ≥ 0.25%. Layered on top of the absolute floor.")

i_momentumExempt   = input.bool(true,  "🚀 Momentum Exemption (skip ARM cancel on strong breakout)", group=GV5, tooltip="If price runs out of zone with strong momentum (vol > avg × N AND ADX > threshold AND aligned trend), DO NOT cancel the ARM as runaway. Late-fire still allowed for N bars.")
i_momVolMult       = input.float(1.30, "🚀 Momentum Exemption: Vol Multiple",          group=GV5, minval=1.00, maxval=3.00, step=0.05)
i_momADXmin        = input.float(25.0, "🚀 Momentum Exemption: Min ADX",                group=GV5, minval=15.0, maxval=50.0, step=1.0)
i_momLateBars      = input.int(5,      "🚀 Late-Fire Window (bars after BOS)",          group=GV5, minval=0,    maxval=20, tooltip="After a momentum-exempt BOS/runaway, allow trigger to fire for N more bars as long as direction stays aligned. 0 = no late fire.")

i_vetoHyst         = input.float(10.0, "🛡 Veto Recovery Hysteresis (+pts above vetoWR)", group=GV5, minval=2.0, maxval=30.0, step=1.0, tooltip="Veto clears when rolling WR ≥ i_vetoWR + this. Default +10 means vetoWR=40 → clears at 50, not the old 60.")
i_vetoIdleBars     = input.int(200,    "🛡 Veto Auto-Clear: Idle Bars (no new trade)",  group=GV5, minval=20, maxval=1000, tooltip="If no new trade has been recorded for N bars, clear the veto regardless of WR (regime may have changed silently).")
i_vetoForceOff     = input.bool(false, "🛡 FORCE Veto OFF (manual override)",            group=GV5, tooltip="One-click escape hatch. While true, veto can never latch and any active veto is cleared.")

// ——— V21.6: Zone Polarity Lock + Re-Arm + Reaction Relax + Wrong-Side Veto ———
i_zonePolarityLock = input.bool(true,  "🧭 Zone Polarity Lock (kill BUY-at-supply / SELL-at-demand)", group=GV6, tooltip="STRICT polarity gate. BUY only fires when price is structurally closer to demand than to supply (or only demand zone in proximity). SELL only fires when closer to supply.")
i_polarityRatioL   = input.float(0.45, "🧭 Polarity Ratio: BUY when distRatio ≤",        group=GV6, minval=0.10, maxval=0.50, step=0.01, tooltip="distRatio = distance-to-demand / (distance-to-demand + distance-to-supply). Lower = price closer to demand. BUY allowed when below this. 0.45 = mostly-on-demand-side.")
i_polarityRatioS   = input.float(0.55, "🧭 Polarity Ratio: SELL when distRatio ≥",       group=GV6, minval=0.50, maxval=0.90, step=0.01, tooltip="SELL allowed when distRatio above this. 0.55 = mostly-on-supply-side.")

i_reArmOn          = input.bool(true,  "🔁 Re-Arm Per Active-Zone Tap",                   group=GV6, tooltip="V21.5 fired ONE arm per zone life. V21.6 detects each FRESH TAP of the SAME un-broken zone and re-arms (subject to bar-gap and re-tap detection).")
i_reArmGap         = input.int(8,      "🔁 Re-Arm Min Bar Gap",                          group=GV6, minval=2,  maxval=50, tooltip="Minimum bars between successive re-arms on the same zone. Prevents same-wick double-fire.")
i_reArmExitBars    = input.int(3,      "🔁 Bars Outside Zone Before Re-Tap Counts",      group=GV6, minval=1, maxval=20, tooltip="Price must spend N bars outside the zone before a return tap registers as a fresh re-tap (not just oscillation inside).")
i_reArmMaxPerZone  = input.int(4,      "🔁 Max Re-Arms Per Active Zone",                  group=GV6, minval=1, maxval=20, tooltip="Cap re-arms per zone to avoid death-spiral if a zone gets repeatedly tagged but never trends.")

i_reactionRelax    = input.bool(true,  "🪞 Reaction Relax (4-form rejection capture)",     group=GV6, tooltip="V21.5 needed strict pin-bar geometry. V21.6 accepts ANY of: (a) loose pin/hammer, (b) engulfing-at-zone, (c) body-bounce, (d) small-body-in-zone + next-bar follow-through.")
i_reactWickRatio   = input.float(0.40, "🪞 Pin/Hammer wick × body min",                  group=GV6, minval=0.20, maxval=2.00, step=0.05, tooltip="V21.5 used 0.5. V21.6 default 0.4 is looser — catches more clean rejections.")

i_wrongSideOn      = input.bool(true,  "🚫 Wrong-Side Position Veto",                     group=GV6, tooltip="Independent structural guard. Refuses LONG signals when normalized HTF-range position is too high, refuses SHORT when too low.")
i_wrongSideMaxL    = input.float(0.40, "🚫 BUY allowed when range pos ≤",                group=GV6, minval=0.10, maxval=0.50, step=0.01, tooltip="0 = at active demand floor, 1 = at active supply ceiling. BUY blocked above this. 0.4 = bottom 40% of active range.")
i_wrongSideMinS    = input.float(0.60, "🚫 SELL allowed when range pos ≥",               group=GV6, minval=0.50, maxval=0.90, step=0.01, tooltip="SELL blocked below this. 0.6 = top 40% of active range.")

// ——— V21.7: 🔬 Hyper-Adaptive Per-Asset Calibration ———
i_v7Master         = input.bool(true,  "🔬 MASTER: Enable V21.7 Hyper-Adaptive Stack",      group=GV7, tooltip="Single switch to enable/disable ALL V21.7 features: Adaptive EMA, CF Auto-Tune, Vol-Regime TP, SLEEPER suppress, Realized-RR, Asset Memory.")

// 🧪 Adaptive EMA Lengths (DNA-class-driven)
i_adaptEmaOn       = input.bool(true,  "🧪 Adaptive EMA Lengths (per DNA class)",         group=GV7, tooltip="V21.6 used hard-coded EMAs (9/13/21/50/89). V21.7 scales them: TRENDER faster, SLEEPER slower. Activates only when DNA is ready and i_v7Master is on.")
i_emaScaleTrend    = input.float(0.65, "🧪 EMA scale: TRENDER multiplier",                  group=GV7, minval=0.30, maxval=1.00, step=0.05, tooltip="Multiplier on baseline EMA periods. <1 = faster. 0.65 = ~35% faster (9→6, 13→9, 21→14, 50→32, 89→58).")
i_emaScaleMom      = input.float(0.85, "🧪 EMA scale: MOMENTUM multiplier",                 group=GV7, minval=0.50, maxval=1.20, step=0.05)
i_emaScaleRange    = input.float(1.00, "🧪 EMA scale: RANGER multiplier (baseline)",        group=GV7, minval=0.70, maxval=1.50, step=0.05)
i_emaScaleChop     = input.float(1.30, "🧪 EMA scale: CHOPPER multiplier",                  group=GV7, minval=1.00, maxval=2.00, step=0.05, tooltip=">1 = slower. CHOPPER needs slower EMAs to ignore noise.")
i_emaScaleSleep    = input.float(1.50, "🧪 EMA scale: SLEEPER multiplier",                  group=GV7, minval=1.00, maxval=2.50, step=0.05, tooltip="Slowest EMAs for dead chop — reduces whipsaw entries.")

// 🎚 Per-Asset CF Auto-Tune
i_cfAutoOn         = input.bool(true,  "🎚 CF Auto-Tune (per-asset closed-loop)",          group=GV7, tooltip="Drives the 0–5 confluence floor up when realized PF<1+WR<55%, down when PF>1.8+WR>70%. Independent of main tuner cadence so it reacts faster to per-asset rot.")
i_cfAutoMinT       = input.int(8,      "🎚 CF Auto-Tune: Min Trades",                       group=GV7, minval=3,    maxval=50)
i_cfAutoFloor      = input.int(2,      "🎚 CF Auto-Tune: Floor (lowest CF)",                group=GV7, minval=1,    maxval=4,    tooltip="CF can never drop below this even on hot streaks.")
i_cfAutoCeil       = input.int(5,      "🎚 CF Auto-Tune: Ceiling (highest CF)",             group=GV7, minval=3,    maxval=5,    tooltip="CF can never rise above this even when bleeding.")
i_cfAutoUpPF       = input.float(1.0,  "🎚 Raise CF when PF below",                          group=GV7, minval=0.50, maxval=1.50, step=0.05)
i_cfAutoUpWR       = input.float(55.0, "🎚 Raise CF when WR% below",                         group=GV7, minval=30.0, maxval=70.0, step=1.0)
i_cfAutoDnPF       = input.float(1.8,  "🎚 Lower CF when PF above",                          group=GV7, minval=1.20, maxval=3.00, step=0.05)
i_cfAutoDnWR       = input.float(70.0, "🎚 Lower CF when WR% above",                         group=GV7, minval=55.0, maxval=90.0, step=1.0)

// 🌡 Volatility-Regime TP Multiplier
i_volRegimeOn      = input.bool(true,  "🌡 Volatility-Regime TP Multiplier",                group=GV7, tooltip="Scales the TP ladder by ATR percent-of-price. Low-vol assets shrink (closer to floor), high-vol expand. Always respects the absolute TP1 floor (≥0.40%).")
i_volMultLow       = input.float(0.85, "🌡 Mult: ATR% < 0.20 (very low vol)",              group=GV7, minval=0.50, maxval=1.20, step=0.05)
i_volMultMid       = input.float(1.00, "🌡 Mult: ATR% 0.20–0.50 (neutral)",               group=GV7, minval=0.70, maxval=1.30, step=0.05)
i_volMultHi        = input.float(1.10, "🌡 Mult: ATR% 0.50–1.00 (elevated)",              group=GV7, minval=0.80, maxval=1.50, step=0.05)
i_volMultUltra     = input.float(1.25, "🌡 Mult: ATR% > 1.00 (high)",                      group=GV7, minval=1.00, maxval=2.00, step=0.05)

// 💀 SLEEPER Auto-Suppress
i_sleeperBlockOn   = input.bool(true,  "💀 SLEEPER Auto-Suppress (block entries)",        group=GV7, tooltip="When DNA = SLEEPER and PF < threshold over min trades, block ALL new entries until DNA reclassifies or PF recovers. Skips the AMZN-style 35%/0.47-PF death spiral.")
i_sleeperPF        = input.float(1.00, "💀 Block when SLEEPER PF below",                    group=GV7, minval=0.50, maxval=1.50, step=0.05)
i_sleeperRecoverPF = input.float(1.20, "💀 Auto-clear when PF recovers above",            group=GV7, minval=1.00, maxval=2.00, step=0.05)
i_sleeperMinT      = input.int(10,     "💀 Min trades before SLEEPER block",                 group=GV7, minval=5,    maxval=50)

// 🎯 Realized-RR Feedback
i_realRRon         = input.bool(true,  "🎯 Realized-RR Feedback (avgWin vs avgLoss)",      group=GV7, tooltip="Tracks rolling avg win % and loss %. If avgWin < avgLoss × cutoff, force-widen TP1. If avgWin > avgLoss × expand-cutoff, expand TP3.")
i_realRRMinT       = input.int(8,      "🎯 Min trades for Real-RR feedback",                group=GV7, minval=4,    maxval=30)
i_realRRwidenAt    = input.float(0.60, "🎯 Widen TP1 when avgWin/avgLoss <",                group=GV7, minval=0.40, maxval=0.90, step=0.05)
i_realRRwidenStep  = input.float(0.20, "🎯 Widen step (TP1 × 1+x per cycle)",              group=GV7, minval=0.05, maxval=0.50, step=0.05)
i_realRRexpandAt   = input.float(2.00, "🎯 Expand TP3 when avgWin/avgLoss >",                group=GV7, minval=1.20, maxval=4.00, step=0.10)

// 🔬 Asset Memory
i_memOn            = input.bool(true,  "🔬 Asset Memory (snapshot best calibration)",      group=GV7, tooltip="When PF≥2.0 and WR≥70% over min trades, snapshots eff_tp1/tp2/tp3/conf/armW. If asset later degrades to PF<1, can revert to last known good cal.")
i_memSnapPF        = input.float(2.00, "🔬 Snapshot when PF ≥",                              group=GV7, minval=1.50, maxval=4.00, step=0.10)
i_memSnapWR        = input.float(70.0, "🔬 Snapshot when WR% ≥",                             group=GV7, minval=55.0, maxval=90.0, step=1.0)
i_memRevertPF      = input.float(1.00, "🔬 Revert to snapshot when PF ≤",                    group=GV7, minval=0.50, maxval=1.50, step=0.05)

// ——— Walk-Forward Optimizer ———
i_wfOn       = input.bool(true,  "Enable Walk-Forward AI",  group=GW, tooltip="Tracks Sniper/Balanced/Aggressive profiles in parallel, surfaces the best one by Sharpe / WR / PF.")
i_wfBars     = input.int(125,    "WF Update Frequency",     group=GW, minval=20,  maxval=500)
i_wfMinT     = input.int(8,      "WF Min Trades",           group=GW, minval=3,   maxval=50)
i_wfMetric   = input.string("Sharpe", "WF Metric",          group=GW, options=["Sharpe", "Win Rate", "Profit Factor"])

// ——— Manual Override ———
i_pxMult     = input.float(0.5,  "Zone Proximity (ATR)",        group=GC, minval=0.05, maxval=3.0, step=0.05)
i_htfReq     = input.int(2,      "HTF Bias Score (0=off)",      group=GC, minval=0, maxval=4)
i_confReq    = input.int(4,      "Confluences Needed (of 5)",   group=GC, minval=1, maxval=5)
i_freshOnly  = input.bool(true,  "Fresh Zones Only",            group=GC)
i_revReq     = input.bool(true,  "Require Reversal Candle",     group=GC)
i_oscReq     = input.bool(true,  "Require Oscillator Extreme",  group=GC)
i_stReq      = input.bool(false, "Require SuperTrend",          group=GC)
i_adxOn      = input.bool(true,  "ADX Anti-Chop Filter",        group=GC)
i_adxMin     = input.int(18,     "ADX Min",                     group=GC, minval=5, maxval=50)
i_cooldown   = input.int(3,      "Cooldown (bars)",             group=GC, minval=1, maxval=50)
i_lossCD     = input.int(8,      "Post-Loss Cooldown",          group=GC, minval=0, maxval=100)

i_lev        = input.int(1,    "Leverage",          group=GR, minval=1,  maxval=125)
i_exitTP1    = input.bool(true,"Exit Full @ TP1",   group=GR)
i_trail      = input.bool(true,"Trail SL After TP1",group=GR)
i_slZone     = input.bool(true,"SL At Zone Edge",   group=GR)
i_slATR      = input.float(0.7,"SL ATR Mult",       group=GR, minval=0.2, maxval=5.0, step=0.1)

// ——— TP method ———
i_tpMethod   = input.string("Fixed %", "TP Method",  group=GT, options=["Fixed %", "ATR Multiple", "Zone Edge"])
i_tp1Pct     = input.float(0.5, "TP1 (%)",          group=GT, minval=0.1, maxval=10.0, step=0.1)
i_tp2Pct     = input.float(1.0, "TP2 (%)",          group=GT, minval=0.2, maxval=20.0, step=0.1)
i_tp3Pct     = input.float(2.0, "TP3 (%)",          group=GT, minval=0.5, maxval=50.0, step=0.1)
i_tp1A       = input.float(0.5, "TP1 ATR",          group=GT, minval=0.2, maxval=8.0,  step=0.1)
i_tp2A       = input.float(1.0, "TP2 ATR",          group=GT, minval=0.4, maxval=15.0, step=0.1)
i_tp3A       = input.float(2.0, "TP3 ATR",          group=GT, minval=1.0, maxval=30.0, step=0.1)

i_theme      = input.string("Neon Teal","Theme",            group=GD, options=["Neon Teal","Midnight Fire","Arctic Aurora","Ruby"])
i_dash       = input.bool(true,  "Dashboard",               group=GD)
i_dPos       = input.string("Bottom Right","Dash Position", group=GD, options=["Bottom Right","Bottom Left","Top Right","Top Left"])
i_barCol     = input.bool(true,  "Color Bars In Trade",     group=GD)
i_ribbon     = input.bool(true,  "EMA Ribbon",              group=GD)

// ============================================================================
// ——— PROFILE PRESET RESOLUTION ———
// ============================================================================
bool isSniper  = i_winMode == "Sniper (Max WR)"
bool isBal     = i_winMode == "Balanced"
bool isAgg     = i_winMode == "Aggressive (More Signals)"
bool isCustom  = i_winMode == "Custom"

int   pConf    = isSniper ? 5 : isBal ? 4 : isAgg ? 3 : i_confReq
bool  pFresh   = isSniper ? true : isBal ? true : isAgg ? false : i_freshOnly
bool  pRev     = isSniper ? true : isBal ? true : isAgg ? false : i_revReq
bool  pOsc     = isSniper ? true : isBal ? false : isAgg ? false : i_oscReq
bool  pAdx     = isSniper ? true : isBal ? true : isAgg ? false : i_adxOn
int   pCD      = isSniper ? 5 : isBal ? 3 : isAgg ? 2 : i_cooldown
int   pLossCD  = isSniper ? 12 : isBal ? 8 : isAgg ? 5 : i_lossCD
int   pHtfReq  = isSniper ? 3 : isBal ? 2 : isAgg ? 1 : i_htfReq
bool  pExitTP1 = isSniper ? true : isBal ? true : isAgg ? false : i_exitTP1
float pTp1     = isSniper ? 0.5 : isBal ? 0.7 : isAgg ? 1.0 : i_tp1Pct
float pTp2     = isSniper ? 1.0 : isBal ? 1.5 : isAgg ? 2.0 : i_tp2Pct
float pTp3     = isSniper ? 2.0 : isBal ? 3.0 : isAgg ? 5.0 : i_tp3Pct
float pTp1A    = isSniper ? 0.5 : isBal ? 0.7 : isAgg ? 1.0 : i_tp1A
float pTp2A    = isSniper ? 1.0 : isBal ? 1.5 : isAgg ? 2.0 : i_tp2A
float pTp3A    = isSniper ? 2.0 : isBal ? 3.0 : isAgg ? 5.0 : i_tp3A

// ARM-engine profile presets
int   pArmWin  = isSniper ? 15 : isBal ? 20 : isAgg ? 30 : i_armWindow
int   pArmConf = isSniper ? 4 : isBal ? 3 : isAgg ? 2 : i_armNeedConf
bool  pArmRev  = isSniper ? true : isBal ? true : isAgg ? false : i_armNeedRev

// (Override layer + eff_* init relocated to after DNA engine — see below)


// ============================================================================
// ——— THEME ———
// ============================================================================
var color cBull = color.new(#00e5ff, 0)
var color cBear = color.new(#ff1744, 0)
var color cTP   = color.new(#00e676, 0)
var color cE1   = color.new(#00e5ff, 0)
var color cE2   = color.new(#ffeb3b, 0)
var color cArm  = color.new(#ffd600, 0)
if i_theme == "Midnight Fire"
    cBull := color.new(#ff6d00, 0)
    cBear := color.new(#b71c1c, 0)
    cTP   := color.new(#ffa726, 0)
    cE1   := color.new(#ff6d00, 0)
    cE2   := color.new(#bf360c, 0)
    cArm  := color.new(#ffeb3b, 0)
else if i_theme == "Arctic Aurora"
    cBull := color.new(#00e5ff, 0)
    cBear := color.new(#7c4dff, 0)
    cTP   := color.new(#00bcd4, 0)
    cE1   := color.new(#00e5ff, 0)
    cE2   := color.new(#7c4dff, 0)
    cArm  := color.new(#b388ff, 0)
else if i_theme == "Ruby"
    cBull := color.new(#ff4081, 0)
    cBear := color.new(#d50000, 0)
    cTP   := color.new(#f48fb1, 0)
    cE1   := color.new(#ff4081, 0)
    cE2   := color.new(#d50000, 0)
    cArm  := color.new(#ffab40, 0)

// ============================================================================
// ——— CORE TA ———
// ============================================================================
float atr14   = ta.atr(14)
float atr50   = ta.atr(50)
float vma20   = ta.sma(volume, 20)
float e9      = ta.ema(close, 9)
float e13     = ta.ema(close, 13)
float e21     = ta.ema(close, 21)
float e50     = ta.ema(close, 50)
float e55     = ta.ema(close, 55)
float e89     = ta.ema(close, 89)
float e200    = ta.ema(close, 200)
// V21.7: Pre-computed alternate EMAs for adaptive selection by DNA class.
// Pine v6 ‘ta.ema’ needs a simple int length, so we pre-compute a basket and switch.
float e6      = ta.ema(close, 6)     // TRENDER fast (≈9 × 0.65)
float e9b     = ta.ema(close, 9)
float e14     = ta.ema(close, 14)    // TRENDER fast (≈21 × 0.65)
float e32     = ta.ema(close, 32)    // TRENDER fast (≈50 × 0.65)
float e58     = ta.ema(close, 58)    // TRENDER fast (≈89 × 0.65)
float e8      = ta.ema(close, 8)     // MOM medium (≈9 × 0.85)
float e11     = ta.ema(close, 11)    // MOM medium (≈13 × 0.85)
float e18     = ta.ema(close, 18)    // MOM medium (≈21 × 0.85)
float e43     = ta.ema(close, 43)    // MOM medium (≈50 × 0.85)
float e76     = ta.ema(close, 76)    // MOM medium (≈89 × 0.85)
float e12     = ta.ema(close, 12)    // CHOP slow (≈9 × 1.30)
float e17     = ta.ema(close, 17)    // CHOP slow (≈13 × 1.30)
float e27     = ta.ema(close, 27)    // CHOP slow (≈21 × 1.30)
float e65     = ta.ema(close, 65)    // CHOP slow (≈50 × 1.30)
float e116    = ta.ema(close, 116)   // CHOP slow (≈89 × 1.30)
float e14b    = ta.ema(close, 14)    // SLEEPER slowest (≈9 × 1.50)
float e20     = ta.ema(close, 20)    // SLEEPER slowest (≈13 × 1.50)
float e32b    = ta.ema(close, 32)    // SLEEPER slowest (≈21 × 1.50)
float e75     = ta.ema(close, 75)    // SLEEPER slowest (≈50 × 1.50)
float e134    = ta.ema(close, 134)   // SLEEPER slowest (≈89 × 1.50)
float rsi14   = ta.rsi(close, 14)
float rsiSm   = ta.ema(rsi14, 5)
float stKraw  = ta.stoch(rsi14, rsi14, rsi14, 14)
float stKln   = ta.sma(stKraw, 3)
float stDln   = ta.sma(stKln, 3)
[mL, mS, mH]  = ta.macd(close, 12, 26, 9)
bool macdBull = mH > 0.0
bool macdBear = mH < 0.0
bool x9up     = ta.crossover(e9, e13)
bool x9dn     = ta.crossunder(e9, e13)
bool stKup    = ta.crossover(stKln, stDln)
bool stKdn    = ta.crossunder(stKln, stDln)

// ——— SuperTrend ———
float stAtr = ta.atr(10)
float stUpB = hl2 - 3.0 * stAtr
float stDnB = hl2 + 3.0 * stAtr
var float stUL = na
var float stDL = na
var int   stDr = 1
stUL := na(stUL[1]) ? stUpB : close[1] > stUL[1] ? math.max(stUpB, stUL[1]) : stUpB
stDL := na(stDL[1]) ? stDnB : close[1] < stDL[1] ? math.min(stDnB, stDL[1]) : stDnB
stDr := na(stDr[1]) ? 1 : stDr[1] == -1 and close > stDL[1] ? 1 : stDr[1] == 1 and close < stUL[1] ? -1 : stDr[1]
bool stBull = stDr ==  1
bool stBear = stDr == -1

// ——— ADX ———
float dmPr = math.max(high - high[1], 0.0)
float dmNr = math.max(low[1] - low,   0.0)
float dmPf = dmPr > dmNr ? dmPr : 0.0
float dmNf = dmNr > dmPr ? dmNr : 0.0
float trv  = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
float smTR = ta.rma(trv, 14)
float rmaPf = ta.rma(dmPf, 14)
float rmaNf = ta.rma(dmNf, 14)
float diP  = smTR > 0.0 ? rmaPf / smTR * 100.0 : 0.0
float diN  = smTR > 0.0 ? rmaNf / smTR * 100.0 : 0.0
float dxv  = (diP + diN) > 0.0 ? math.abs(diP - diN) / (diP + diN) * 100.0 : 0.0
float adxVal = ta.rma(dxv, 14)

// ============================================================================
// ——— 🧬 ASSET DNA PROFILER ———
// Fingerprints the symbol from history so each asset gets its own baseline.
// Why: AMZN choppy/ranging ≠ COP clean trend ≠ SPY mid-trend.
// Same global settings = some win 90%, others lose 67%. This fixes that.
// ============================================================================

// ---- Raw DNA inputs (computed every bar, smoothed via cumulative aggregation) ----
float dna_atrPct   = atr14 / math.max(close, 0.0001) * 100.0          // volatility character (% of price)
float dna_emaSpread= math.abs(e9 - e50) / math.max(atr14, 0.0001)     // trend strength via EMA spread
float dna_emaStack = (e9 > e21 and e21 > e50 and e50 > e200) or (e9 < e21 and e21 < e50 and e50 < e200) ? 1.0 : 0.0  // 1 if EMAs stacked
float dna_dirMove  = math.abs(close - close[20]) / math.max(ta.highest(high, 20) - ta.lowest(low, 20), 0.0001)  // directional efficiency 0-1
float dna_chopCnt  = (high - low) < atr14 * 0.6 ? 1.0 : 0.0           // small-range bar = chop indicator
float dna_bigBar   = math.abs(close - open) > atr14 * 1.5 ? 1.0 : 0.0 // momentum-bar count
float dna_revCnt   = ((close - close[1]) * (close[1] - close[2]) < 0.0) ? 1.0 : 0.0  // direction-flip count (mean-rev proxy)

// ---- Rolling DNA accumulators (over warmup window) ----
float dna_adxAvg   = ta.sma(adxVal,      i_dnaWarmup)
float dna_atrAvg   = ta.sma(dna_atrPct,  i_dnaWarmup)
float dna_spreadAvg= ta.sma(dna_emaSpread, i_dnaWarmup)
float dna_stackPct = ta.sma(dna_emaStack, i_dnaWarmup) * 100.0        // % of bars EMAs stacked
float dna_dirAvg   = ta.sma(dna_dirMove, i_dnaWarmup) * 100.0         // avg directional efficiency 0-100
float dna_chopPct  = ta.sma(dna_chopCnt, i_dnaWarmup) * 100.0         // % of bars are small-range chop
float dna_bigPct   = ta.sma(dna_bigBar,  i_dnaWarmup) * 100.0         // % of bars are momentum bars
float dna_revPct   = ta.sma(dna_revCnt,  i_dnaWarmup) * 100.0         // % of bars flip direction

// ---- Composite DNA scores (0-100 each) ----
float dna_trendScore = math.min(100.0, (dna_adxAvg * 2.0 + dna_stackPct + dna_dirAvg) / 4.0)
float dna_chopScore  = math.min(100.0, (dna_chopPct + dna_revPct + (100.0 - dna_dirAvg)) / 3.0)
float dna_volScore   = math.min(100.0, dna_atrAvg * 50.0)              // 2% ATR/price → 100 score
float dna_momScore   = math.min(100.0, (dna_bigPct * 2.0 + dna_dirAvg) / 2.0)
float dna_meanrevScore = dna_revPct                                    // already 0-100

// ---- Asset Classification ----
// Pick the dominant character. Order matters: most-specific first.
bool   dna_ready  = bar_index >= i_dnaWarmup and not na(dna_adxAvg)
string dna_class  = "WARMING UP"
string dna_emoji  = "⏳"
if dna_ready
    if dna_chopScore > 55.0 and dna_trendScore < 40.0
        dna_class := "CHOPPER"
        dna_emoji := "⚡"
    else if dna_momScore > 55.0 and dna_volScore > 50.0
        dna_class := "MOMENTUM"
        dna_emoji := "🚀"
    else if dna_trendScore > 55.0
        dna_class := "TRENDER"
        dna_emoji := "↑"
    else if dna_volScore < 25.0 and dna_trendScore < 40.0
        dna_class := "SLEEPER"
        dna_emoji := "💤"
    else
        dna_class := "RANGER"
        dna_emoji := "↔"

// ---- User force-override of class ----
string dna_classFinal = i_dnaForce == "Auto" ? dna_class : str.upper(i_dnaForce)
string dna_emojiFinal = i_dnaForce == "Auto" ? dna_emoji : (i_dnaForce == "Trender" ? "↑" : i_dnaForce == "Momentum" ? "🚀" : i_dnaForce == "Ranger" ? "↔" : i_dnaForce == "Chopper" ? "⚡" : i_dnaForce == "Sleeper" ? "💤" : "⏳")

bool dna_active   = i_dnaOn and dna_ready and dna_classFinal != "WARMING UP"
bool dna_isTrend  = dna_classFinal == "TRENDER"
bool dna_isMom    = dna_classFinal == "MOMENTUM"
bool dna_isRange  = dna_classFinal == "RANGER"
bool dna_isChop   = dna_classFinal == "CHOPPER"
bool dna_isSleep  = dna_classFinal == "SLEEPER"
bool dna_hostile  = dna_isChop or (dna_isSleep and dna_volScore < 15.0)

// ============================================================================
// V21.7 — 🧪 ADAPTIVE EMA SELECTOR (per DNA class)
// Pre-computed e* lengths above are switched here based on DNA class.
// When V21.7 master OFF or DNA not ready, falls back to baseline (9/13/21/50/89).
// All downstream code uses eEff9/13/21/50/89 — originals e9/e13/e21/e50/e89
// remain untouched for any legacy reference.
// ============================================================================
bool emaUseAdapt = i_v7Master and i_adaptEmaOn and dna_active
string emaPreset = not emaUseAdapt ? "DEFAULT (9/13/21/50/89)" : dna_isTrend ? "TRENDER-FAST (6/9/14/32/58)" : dna_isMom ? "MOM-MED (8/11/18/43/76)" : dna_isRange ? "RANGER (9/13/21/50/89)" : dna_isChop ? "CHOP-SLOW (12/17/27/65/116)" : dna_isSleep ? "SLEEPER-SLOW (14/20/32/75/134)" : "DEFAULT (9/13/21/50/89)"

float eEff9  = not emaUseAdapt ? e9  : dna_isTrend ? e6   : dna_isMom ? e8   : dna_isRange ? e9   : dna_isChop ? e12  : dna_isSleep ? e14b : e9
float eEff13 = not emaUseAdapt ? e13 : dna_isTrend ? e9b  : dna_isMom ? e11  : dna_isRange ? e13  : dna_isChop ? e17  : dna_isSleep ? e20  : e13
float eEff21 = not emaUseAdapt ? e21 : dna_isTrend ? e14  : dna_isMom ? e18  : dna_isRange ? e21  : dna_isChop ? e27  : dna_isSleep ? e32b : e21
float eEff50 = not emaUseAdapt ? e50 : dna_isTrend ? e32  : dna_isMom ? e43  : dna_isRange ? e50  : dna_isChop ? e65  : dna_isSleep ? e75  : e50
float eEff89 = not emaUseAdapt ? e89 : dna_isTrend ? e58  : dna_isMom ? e76  : dna_isRange ? e89  : dna_isChop ? e116 : dna_isSleep ? e134 : e89

// ============================================================================
// ——— 🎯 AUTO-CALIBRATED PROFILE (per-asset baseline) ———
// Maps DNA class → calibrated parameters. Each field falls back to user profile
// when DNA is off or still warming up. Volatility-scaled where appropriate.
// ============================================================================
float dna_volMult = math.max(0.6, math.min(2.0, dna_atrAvg / 1.0))   // baseline = 1% ATR/price; clamp 0.6x..2.0x

// Calibrated values per class (in % for tp1/2/3, ATR mult for tp1A etc.)
float cal_tp1   = pTp1
float cal_tp2   = pTp2
float cal_tp3   = pTp3
float cal_tp1A  = pTp1A
float cal_tp2A  = pTp2A
float cal_tp3A  = pTp3A
float cal_slA   = isSniper ? 0.7 : isBal ? 0.9 : isAgg ? 1.2 : i_slATR
int   cal_conf  = pConf
int   cal_armW  = pArmWin
int   cal_armC  = pArmConf
float cal_pxM   = i_pxMult

if dna_active
    if dna_isTrend
        // Clean trend, zones respected → Sniper-style with vol-scaled TPs
        cal_tp1  := math.max(0.3,  0.5 * dna_volMult)
        cal_tp2  := math.max(0.6,  1.0 * dna_volMult)
        cal_tp3  := math.max(1.2,  2.0 * dna_volMult)
        cal_tp1A := 0.5
        cal_tp2A := 1.0
        cal_tp3A := 2.5
        cal_slA  := 0.8
        cal_conf := 5
        cal_armW := 18
        cal_armC := 4
        cal_pxM  := 0.5
    else if dna_isMom
        // Big bars, strong directional moves → Aggressive with bigger TP3
        cal_tp1  := math.max(0.4,  0.7 * dna_volMult)
        cal_tp2  := math.max(0.9,  1.5 * dna_volMult)
        cal_tp3  := math.max(2.0,  4.0 * dna_volMult)
        cal_tp1A := 0.7
        cal_tp2A := 1.5
        cal_tp3A := 3.5
        cal_slA  := 1.2
        cal_conf := 3
        cal_armW := 25
        cal_armC := 3
        cal_pxM  := 0.6
    else if dna_isRange
        // Range-bound, mean-reverting → Tight TPs, exit fast, no chasing
        cal_tp1  := math.max(0.25, 0.4 * dna_volMult)
        cal_tp2  := math.max(0.5,  0.8 * dna_volMult)
        cal_tp3  := math.max(1.0,  1.5 * dna_volMult)
        cal_tp1A := 0.4
        cal_tp2A := 0.8
        cal_tp3A := 1.5
        cal_slA  := 0.7
        cal_conf := 4
        cal_armW := 12
        cal_armC := 4
        cal_pxM  := 0.4
    else if dna_isChop
        // Hostile chop → max defensive: 5/5 conf, tight TP1, wide SL, narrow ARM
        cal_tp1  := math.max(0.2,  0.3 * dna_volMult)
        cal_tp2  := math.max(0.4,  0.6 * dna_volMult)
        cal_tp3  := math.max(0.7,  1.0 * dna_volMult)
        cal_tp1A := 0.3
        cal_tp2A := 0.6
        cal_tp3A := 1.0
        cal_slA  := 1.5
        cal_conf := 5
        cal_armW := 8
        cal_armC := 5
        cal_pxM  := 0.3
    else if dna_isSleep
        // Low vol → very tight everything
        cal_tp1  := math.max(0.2,  0.35 * dna_volMult)
        cal_tp2  := math.max(0.4,  0.7  * dna_volMult)
        cal_tp3  := math.max(0.8,  1.2  * dna_volMult)
        cal_tp1A := 0.35
        cal_tp2A := 0.7
        cal_tp3A := 1.2
        cal_slA  := 0.6
        cal_conf := 4
        cal_armW := 15
        cal_armC := 4
        cal_pxM  := 0.35

// ============================================================================
// ——— MANUAL OVERRIDE LAYER ( DNA-Calibrated → User Override ) ———
// User override beats DNA. DNA beats raw profile. Profile is fallback.
// ============================================================================
bool ovOn   = i_manualOverride
bool ovTP   = ovOn and i_overrideTP
bool ovSL   = ovOn and i_overrideSL
bool ovCF   = ovOn and i_overrideConf
bool ovPx   = ovOn and i_overridePx

float ovTp1   = ovTP ? i_tp1Pct     : cal_tp1
float ovTp2   = ovTP ? i_tp2Pct     : cal_tp2
float ovTp3   = ovTP ? i_tp3Pct     : cal_tp3
float ovTp1A  = ovTP ? i_tp1A       : cal_tp1A
float ovTp2A  = ovTP ? i_tp2A       : cal_tp2A
float ovTp3A  = ovTP ? i_tp3A       : cal_tp3A
float ovSlA   = ovSL ? i_slATR      : cal_slA
int   ovConf  = ovCF ? i_confReq    : cal_conf
int   ovArmW  = ovCF ? i_armWindow  : cal_armW
int   ovArmC  = ovCF ? i_armNeedConf : cal_armC
float ovPxM   = ovPx ? i_pxMult     : cal_pxM

// ============================================================================
// ——— EFFECTIVE PARAM STATE (mutated by AI Adaptive Tuner) ———
// Bar 0 (or tuner OFF, or DNA refresh) → hard-sync to override layer.
// Otherwise tuner mutations persist via var.
// ============================================================================
var float eff_tp1    = na
var float eff_tp2    = na
var float eff_tp3    = na
var float eff_tp1A   = na
var float eff_tp2A   = na
var float eff_tp3A   = na
var float eff_slA    = na
var int   eff_conf   = 0
var int   eff_armW   = 0
var int   eff_armC   = 0
var float eff_pxM    = na
var bool  tuner_init = false
var int   dna_lastCal = -100000
// V21.5: hoisted tunerCount so entry-time ATR autoscale can read it before tuner block runs.
var int   tunerCount = 0

// V21.5: hoisted clamp helpers so entry-time ATR autoscale (line ~1370) can call them.
fClampF(float v, float lo, float hi) => math.max(lo, math.min(hi, v))
fClampI(int   v, int   lo, int   hi) => math.max(lo, math.min(hi, v))

// Detect class change (re-calibrate when DNA decides asset character shifted)
bool dna_classChanged = dna_ready and (dna_classFinal != dna_classFinal[1])
// Periodic refresh
bool dna_refresh = i_dnaOn and (bar_index - dna_lastCal) >= i_dnaRefresh

if barstate.isfirst or not i_tunerOn or not tuner_init or dna_classChanged or dna_refresh
    eff_tp1   := ovTp1
    eff_tp2   := ovTp2
    eff_tp3   := ovTp3
    eff_tp1A  := ovTp1A
    eff_tp2A  := ovTp2A
    eff_tp3A  := ovTp3A
    eff_slA   := ovSlA
    eff_conf  := ovConf
    eff_armW  := ovArmW
    eff_armC  := ovArmC
    eff_pxM   := ovPxM
    tuner_init := true
    if dna_classChanged or dna_refresh
        dna_lastCal := bar_index

// ============================================================================
// ——— 💀 ASSET VETO state (V21.3 — DNA-DRIVEN; computed later after stats) ———
// ============================================================================
// Forward-declared so goLong/goShort can reference. The actual latch logic
// runs AFTER rollWR / tTot are computed (post-trade-engine block).
var bool vetoLatched = false
bool vetoActive  = vetoLatched and not i_vetoBypass
bool vetoCleared = vetoLatched[1] and not vetoLatched

// ——— Candle Patterns + Reversal Wicks ———
float cbody  = math.abs(close - open)
float crange = high - low
float upWick = high - math.max(close, open)
float lowWick= math.min(close, open) - low
bool bEng    = close > open and close > high[1] and open < close[1] and cbody > atr14 * 0.3
bool bPin    = close > open and lowWick > cbody * 1.5 and lowWick > atr14 * 0.3
bool bDoji   = cbody < atr14 * 0.25 and crange > atr14 * 0.3
bool seEng   = close < open and close < low[1]  and open > close[1] and cbody > atr14 * 0.3
bool sePin   = close < open and upWick > cbody * 1.5 and upWick > atr14 * 0.3
bool seDoji  = cbody < atr14 * 0.25 and crange > atr14 * 0.3
bool volOK   = volume > vma20 * 0.8
bool exhB    = close > close[1] and close[1] > close[2] and (close - close[2]) > atr14 * 1.8
bool exhS    = close < close[1] and close[1] < close[2] and (close[2] - close) > atr14 * 1.8
// V21.7: ribbon-flatness now uses adaptive fast EMA; e55 stays baseline (mid-anchor).
bool ribFlat = math.abs(eEff9 - e55) < atr14 * 0.4

// ============================================================================
// ——— HTF BIAS ———
// ============================================================================
float dE21   = request.security(syminfo.tickerid, "D",   ta.ema(close, 21), lookahead=barmerge.lookahead_off)
float dE50   = request.security(syminfo.tickerid, "D",   ta.ema(close, 50), lookahead=barmerge.lookahead_off)
float dC     = request.security(syminfo.tickerid, "D",   close,             lookahead=barmerge.lookahead_off)
float h4E21  = request.security(syminfo.tickerid, "240", ta.ema(close, 21), lookahead=barmerge.lookahead_off)
float h4C    = request.security(syminfo.tickerid, "240", close,             lookahead=barmerge.lookahead_off)
float h1E21  = request.security(syminfo.tickerid, "60",  ta.ema(close, 21), lookahead=barmerge.lookahead_off)
float h1C    = request.security(syminfo.tickerid, "60",  close,             lookahead=barmerge.lookahead_off)
float m15E21 = request.security(syminfo.tickerid, "15",  ta.ema(close, 21), lookahead=barmerge.lookahead_off)
float m15C   = request.security(syminfo.tickerid, "15",  close,             lookahead=barmerge.lookahead_off)

bool dBull   = dC  > dE21  and dE21  > dE50
bool dBear   = dC  < dE21  and dE21  < dE50
bool h4Bull  = h4C > h4E21
bool h4Bear  = h4C < h4E21
bool h1Bull  = h1C > h1E21
bool h1Bear  = h1C < h1E21
bool m15Bull = m15C > m15E21
bool m15Bear = m15C < m15E21

int htfBC = (dBull?1:0)  + (h4Bull?1:0) + (h1Bull?1:0) + (m15Bull?1:0)
int htfSC = (dBear?1:0)  + (h4Bear?1:0) + (h1Bear?1:0) + (m15Bear?1:0)

// ============================================================================
// ——— AI REGIME ENGINE ———
// ============================================================================
float atrHist  = ta.sma(atr14, i_aiLook)
float atrRatio = atr14 / math.max(atrHist, 0.0001)
// V21.7: trend-slope reads adaptive EMAs so TRENDER assets register sharper slope earlier.
float slopeE21 = (eEff21 - eEff21[5])  / math.max(atr14 * 5.0, 0.0001)
float slopeE50 = (eEff50 - eEff50[10]) / math.max(atr14 * 10.0, 0.0001)
float swHigh   = ta.highest(high, i_aiLook)
float swLow    = ta.lowest(low,   i_aiLook)
float structQ  = (swHigh - swLow) / math.max(atr14 * float(i_aiLook), 0.0001)

float dirScore   = float(htfBC) - float(htfSC)
float trendScore = slopeE21 + slopeE50 * 0.5
float regScore   = dirScore + trendScore * 2.0

int regime = regScore >=  3.0 and structQ >= 1.5 ?  2 : regScore >=  1.5 ?  1 : regScore <= -3.0 and structQ >= 1.5 ? -2 : regScore <= -1.5 ? -1 : 0

bool highVol = atrRatio > 1.15
bool lowVol  = atrRatio < 0.85

float aiPx      = lowVol ? 0.7 : highVol ? 0.4 : 0.55
bool  aiAllowL  = regime != -2
bool  aiAllowS  = regime !=  2

// AI regime aiPx is layered. Tuner blends in via delta from baseline (i_pxMult).
float _tunedDelta = eff_pxM - i_pxMult
float usePx       = i_aiOn ? math.max(0.05, math.min(3.0, aiPx + _tunedDelta)) : eff_pxM
bool  blockLong   = i_aiOn ? not aiAllowL : false
bool  blockShort  = i_aiOn ? not aiAllowS : false

bool htfLong  = pHtfReq == 0 or htfBC >= pHtfReq
bool htfShort = pHtfReq == 0 or htfSC >= pHtfReq
bool adxOK    = not pAdx or adxVal >= float(i_adxMin)

string regStr = regime ==  2 ? "STRONG BULL" : regime ==  1 ? "BULL" : regime ==  0 ? "NEUTRAL" : regime == -1 ? "BEAR" : "STRONG BEAR"
color  regCol = regime >=  2 ? color.lime    : regime ==  1 ? color.new(#00e676, 20) : regime ==  0 ? color.yellow : regime == -1 ? color.orange : color.red

// ============================================================================
// ——— UNIVERSAL SMC ZONE ENGINE ———
// ============================================================================
var float[] dSt   = array.new<float>()
var float[] dSb   = array.new<float>()
var int[]   dSx   = array.new<int>()
var bool[]  dSf   = array.new<bool>()
var bool[]  dSa   = array.new<bool>()
var float[] dDt   = array.new<float>()
var float[] dDb   = array.new<float>()
var int[]   dDx   = array.new<int>()
var bool[]  dDf   = array.new<bool>()
var bool[]  dDa   = array.new<bool>()
var float[] h4St  = array.new<float>()
var float[] h4Sb  = array.new<float>()
var int[]   h4Sx  = array.new<int>()
var bool[]  h4Sf  = array.new<bool>()
var bool[]  h4Sa  = array.new<bool>()
var float[] h4Dt  = array.new<float>()
var float[] h4Db  = array.new<float>()
var int[]   h4Dx  = array.new<int>()
var bool[]  h4Df  = array.new<bool>()
var bool[]  h4Da  = array.new<bool>()
var float[] h1St  = array.new<float>()
var float[] h1Sb  = array.new<float>()
var int[]   h1Sx  = array.new<int>()
var bool[]  h1Sf  = array.new<bool>()
var bool[]  h1Sa  = array.new<bool>()
var float[] h1Dt  = array.new<float>()
var float[] h1Db  = array.new<float>()
var int[]   h1Dx  = array.new<int>()
var bool[]  h1Df  = array.new<bool>()
var bool[]  h1Da  = array.new<bool>()
var float[] cSt   = array.new<float>()
var float[] cSb   = array.new<float>()
var int[]   cSx   = array.new<int>()
var bool[]  cSf   = array.new<bool>()
var bool[]  cSa   = array.new<bool>()
var float[] cDt   = array.new<float>()
var float[] cDb   = array.new<float>()
var int[]   cDx   = array.new<int>()
var bool[]  cDf   = array.new<bool>()
var bool[]  cDa   = array.new<bool>()

var box[]   dSbx  = array.new<box>()
var box[]   dDbx  = array.new<box>()
var box[]   h4Sbx = array.new<box>()
var box[]   h4Dbx = array.new<box>()
var box[]   h1Sbx = array.new<box>()
var box[]   h1Dbx = array.new<box>()
var box[]   cSbx  = array.new<box>()
var box[]   cDbx  = array.new<box>()

fPush(float[] tops, float[] bots, int[] xs, bool[] fr, bool[] al, float zt, float zb, int bi, float dedup, int cap) =>
    bool dup = false
    int n = array.size(tops)
    if n > 0
        for i = 0 to n - 1
            float m1 = (array.get(tops, i) + array.get(bots, i)) / 2.0
            float m2 = (zt + zb) / 2.0
            if math.abs(m1 - m2) < dedup
                dup := true
    if not dup and zt > zb
        array.push(tops, zt)
        array.push(bots, zb)
        array.push(xs, bi)
        array.push(fr, true)
        array.push(al, true)
        if array.size(tops) > cap
            array.shift(tops)
            array.shift(bots)
            array.shift(xs)
            array.shift(fr)
            array.shift(al)
    dup

fManage(float[] tops, float[] bots, int[] xs, bool[] fr, bool[] al, bool isSup) =>
    int n = array.size(tops)
    if n > 0
        for i = 0 to n - 1
            if array.get(al, i)
                float zt = array.get(tops, i)
                float zb = array.get(bots, i)
                int   bi = array.get(xs, i)
                bool bos = isSup ? close > zt + atr14 * 0.3 : close < zb - atr14 * 0.3
                if bos
                    array.set(al, i, false)
                bool touched = isSup ? (high >= zb and low <= zt) : (low <= zt and high >= zb)
                if touched and bar_index > bi + 1
                    array.set(fr, i, false)
    n

// Draw zones — supports an "armed glow" override (brighter border + thicker width
// when the zone we currently care about is the one that armed the engine).
fDraw(float[] tops, float[] bots, int[] xs, bool[] fr, bool[] al, box[] bxArr, color cFresh, color cUsed, color brdr, int bw, string tag, bool isSup, float armZt, float armZb, bool armed, color glowCol) =>
    int oldN = array.size(bxArr)
    if oldN > 0
        for i = 0 to oldN - 1
            box.delete(array.get(bxArr, i))
    array.clear(bxArr)
    int n = array.size(tops)
    if n > 0
        for i = 0 to n - 1
            if array.get(al, i)
                float zt   = array.get(tops, i)
                float zb   = array.get(bots, i)
                int   zbi  = array.get(xs, i)
                bool  zfr  = array.get(fr, i)
                bool  isArmedZone = armed and not na(armZt) and not na(armZb) and math.abs(zt - armZt) < syminfo.mintick * 5.0 and math.abs(zb - armZb) < syminfo.mintick * 5.0
                color bg   = isArmedZone ? color.new(glowCol, 55) : (zfr ? cFresh : cUsed)
                color bdc  = isArmedZone ? color.new(glowCol, 0)  : brdr
                int   wbw  = isArmedZone ? math.max(bw + 2, 3) : bw
                string lbl = isArmedZone ? ("🎯 ARMED " + tag + " " + (isSup ? "SUPPLY" : "DEMAND")) : ((zfr ? "FRESH " : "") + tag + " " + (isSup ? "SUPPLY" : "DEMAND"))
                box nb = box.new(left=zbi, top=zt, right=bar_index + i_zoneExt, bottom=zb, border_color=bdc, bgcolor=bg, border_width=wbw, text=lbl, text_halign=text.align_center, text_valign=text.align_center, text_color=color.white, text_size=size.tiny, xloc=xloc.bar_index)
                array.push(bxArr, nb)
    n

fProx(float[] tops, float[] bots, bool[] al, bool[] fr, bool isSup, float buf) =>
    bool  hit   = false
    bool  hitFr = false
    float ht    = float(na)
    float hb    = float(na)
    int   cnt   = 0
    int n = array.size(tops)
    if n > 0
        for i = 0 to n - 1
            if array.get(al, i)
                float zt = array.get(tops, i)
                float zb = array.get(bots, i)
                bool touch = high >= zb - buf and low <= zt + buf
                if touch
                    cnt += 1
                    if not hit
                        hit   := true
                        hitFr := array.get(fr, i)
                        ht    := zt
                        hb    := zb
    [hit, hitFr, ht, hb, cnt]

// ============================================================================
// ——— ORDER BLOCK ZONE DETECTION ———
// ----------------------------------------------------------------------------
// True SMC order block logic:
//   • Pivot HIGH confirms (impulsive move down began here)
//       → walk backwards from the pivot bar up to i_obLook bars
//       → find the LAST BULLISH candle (close > open)
//       → that candle's [high, low] = the SUPPLY order block
//   • Pivot LOW confirms (impulsive move up began here)
//       → find the LAST BEARISH candle (close < open)
//       → its [high, low] = the DEMAND order block
//   • Wick + body included → naturally wider, fewer missed taps
//   • Fallback: if no opposing candle in window, use pivot wick + ATR buffer
// ============================================================================
int pv = 3

// fObSupply: at the moment a pivot-high is confirmed (pv bars ago), scan back
// from bar[pv] through bar[pv+i_obLook] looking for the last bullish candle.
// Returns [obTop, obBot, found].
fObSupply(int look, float minBodyAtr, float aRef) =>
    float obTop = na
    float obBot = na
    bool  found = false
    // Iterate from the pivot bar back through `look` bars
    for k = 0 to look - 1
        int off = pv + k
        float o = open[off]
        float c = close[off]
        float h = high[off]
        float l = low[off]
        bool isBull = c > o
        bool bigEnough = math.abs(c - o) >= minBodyAtr * aRef
        if not found and isBull and bigEnough
            obTop := h
            obBot := l
            found := true
    [obTop, obBot, found]

// fObDemand: at pivot-low confirmation, find last bearish candle in window.
fObDemand(int look, float minBodyAtr, float aRef) =>
    float obTop = na
    float obBot = na
    bool  found = false
    for k = 0 to look - 1
        int off = pv + k
        float o = open[off]
        float c = close[off]
        float h = high[off]
        float l = low[off]
        bool isBear = c < o
        bool bigEnough = math.abs(c - o) >= minBodyAtr * aRef
        if not found and isBear and bigEnough
            obTop := h
            obBot := l
            found := true
    [obTop, obBot, found]

// ——— HTF: Daily ———
dPH  = request.security(syminfo.tickerid, "D",   ta.pivothigh(high, pv, pv), lookahead=barmerge.lookahead_off)
dPL  = request.security(syminfo.tickerid, "D",   ta.pivotlow(low,   pv, pv), lookahead=barmerge.lookahead_off)
dA50 = request.security(syminfo.tickerid, "D",   ta.atr(50),                 lookahead=barmerge.lookahead_off)
dHpv = request.security(syminfo.tickerid, "D",   high[pv],                   lookahead=barmerge.lookahead_off)
dLpv = request.security(syminfo.tickerid, "D",   low[pv],                    lookahead=barmerge.lookahead_off)
[dObST, dObSB, dObSF] = request.security(syminfo.tickerid, "D", fObSupply(i_obLook, i_obMinBody, ta.atr(14)), lookahead=barmerge.lookahead_off)
[dObDT, dObDB, dObDF] = request.security(syminfo.tickerid, "D", fObDemand(i_obLook, i_obMinBody, ta.atr(14)), lookahead=barmerge.lookahead_off)

// ——— HTF: 4H ———
h4PH  = request.security(syminfo.tickerid, "240", ta.pivothigh(high, pv, pv), lookahead=barmerge.lookahead_off)
h4PL  = request.security(syminfo.tickerid, "240", ta.pivotlow(low,   pv, pv), lookahead=barmerge.lookahead_off)
h4A50 = request.security(syminfo.tickerid, "240", ta.atr(50),                 lookahead=barmerge.lookahead_off)
h4Hpv = request.security(syminfo.tickerid, "240", high[pv],                   lookahead=barmerge.lookahead_off)
h4Lpv = request.security(syminfo.tickerid, "240", low[pv],                    lookahead=barmerge.lookahead_off)
[h4ObST, h4ObSB, h4ObSF] = request.security(syminfo.tickerid, "240", fObSupply(i_obLook, i_obMinBody, ta.atr(14)), lookahead=barmerge.lookahead_off)
[h4ObDT, h4ObDB, h4ObDF] = request.security(syminfo.tickerid, "240", fObDemand(i_obLook, i_obMinBody, ta.atr(14)), lookahead=barmerge.lookahead_off)

// ——— HTF: 1H ———
h1PH  = request.security(syminfo.tickerid, "60", ta.pivothigh(high, pv, pv), lookahead=barmerge.lookahead_off)
h1PL  = request.security(syminfo.tickerid, "60", ta.pivotlow(low,   pv, pv), lookahead=barmerge.lookahead_off)
h1A50 = request.security(syminfo.tickerid, "60", ta.atr(50),                 lookahead=barmerge.lookahead_off)
h1Hpv = request.security(syminfo.tickerid, "60", high[pv],                   lookahead=barmerge.lookahead_off)
h1Lpv = request.security(syminfo.tickerid, "60", low[pv],                    lookahead=barmerge.lookahead_off)
[h1ObST, h1ObSB, h1ObSF] = request.security(syminfo.tickerid, "60", fObSupply(i_obLook, i_obMinBody, ta.atr(14)), lookahead=barmerge.lookahead_off)
[h1ObDT, h1ObDB, h1ObDF] = request.security(syminfo.tickerid, "60", fObDemand(i_obLook, i_obMinBody, ta.atr(14)), lookahead=barmerge.lookahead_off)

// ——— Current TF ———
float cPH = ta.pivothigh(high, i_swingLen, i_swingLen)
float cPL = ta.pivotlow(low,   i_swingLen, i_swingLen)
// Local OB scan (no security needed)
fLocalObSupply() =>
    float obT = na
    float obB = na
    bool  fnd = false
    for k = 0 to i_obLook - 1
        int off = i_swingLen + k
        if not fnd and close[off] > open[off] and math.abs(close[off] - open[off]) >= i_obMinBody * atr14
            obT := high[off]
            obB := low[off]
            fnd := true
    [obT, obB, fnd]
fLocalObDemand() =>
    float obT = na
    float obB = na
    bool  fnd = false
    for k = 0 to i_obLook - 1
        int off = i_swingLen + k
        if not fnd and close[off] < open[off] and math.abs(close[off] - open[off]) >= i_obMinBody * atr14
            obT := high[off]
            obB := low[off]
            fnd := true
    [obT, obB, fnd]
[cObST, cObSB, cObSF] = fLocalObSupply()
[cObDT, cObDB, cObDF] = fLocalObDemand()

// Fallback widths for when no OB found
float dBuf  = not na(dA50)  ? dA50  * (i_boxWidth / 10.0) : atr14 * 4.0
float h4Buf = not na(h4A50) ? h4A50 * (i_boxWidth / 10.0) : atr14 * 2.0
float h1Buf = not na(h1A50) ? h1A50 * (i_boxWidth / 10.0) : atr14 * 1.2
float cBuf  = atr50 * (i_boxWidth / 10.0)

// Resolve final zone top/bot per pivot — prefer OB, fallback to pivot wick
// Daily Supply
float dSt_t = na
float dSt_b = na
if not na(dPH) and not na(dHpv)
    if dObSF
        dSt_t := math.max(dObST, dHpv)
        dSt_b := dObSB
    else if i_obFallback
        dSt_t := dHpv
        dSt_b := dHpv - dBuf
// Daily Demand
float dDt_t = na
float dDt_b = na
if not na(dPL) and not na(dLpv)
    if dObDF
        dDt_t := dObDT
        dDt_b := math.min(dObDB, dLpv)
    else if i_obFallback
        dDt_t := dLpv + dBuf
        dDt_b := dLpv
// 4H Supply
float h4St_t = na
float h4St_b = na
if not na(h4PH) and not na(h4Hpv)
    if h4ObSF
        h4St_t := math.max(h4ObST, h4Hpv)
        h4St_b := h4ObSB
    else if i_obFallback
        h4St_t := h4Hpv
        h4St_b := h4Hpv - h4Buf
// 4H Demand
float h4Dt_t = na
float h4Dt_b = na
if not na(h4PL) and not na(h4Lpv)
    if h4ObDF
        h4Dt_t := h4ObDT
        h4Dt_b := math.min(h4ObDB, h4Lpv)
    else if i_obFallback
        h4Dt_t := h4Lpv + h4Buf
        h4Dt_b := h4Lpv
// 1H Supply
float h1St_t = na
float h1St_b = na
if not na(h1PH) and not na(h1Hpv)
    if h1ObSF
        h1St_t := math.max(h1ObST, h1Hpv)
        h1St_b := h1ObSB
    else if i_obFallback
        h1St_t := h1Hpv
        h1St_b := h1Hpv - h1Buf
// 1H Demand
float h1Dt_t = na
float h1Dt_b = na
if not na(h1PL) and not na(h1Lpv)
    if h1ObDF
        h1Dt_t := h1ObDT
        h1Dt_b := math.min(h1ObDB, h1Lpv)
    else if i_obFallback
        h1Dt_t := h1Lpv + h1Buf
        h1Dt_b := h1Lpv

// ——— Push zones into arrays ———
if i_showD
    if not na(dSt_t) and not na(dSt_b)
        fPush(dSt, dSb, dSx, dSf, dSa, dSt_t, dSt_b, bar_index, math.max(dBuf, (dSt_t - dSt_b)) * 1.5, i_histKeep)
    if not na(dDt_t) and not na(dDt_b)
        fPush(dDt, dDb, dDx, dDf, dDa, dDt_t, dDt_b, bar_index, math.max(dBuf, (dDt_t - dDt_b)) * 1.5, i_histKeep)
if i_show4h
    if not na(h4St_t) and not na(h4St_b)
        fPush(h4St, h4Sb, h4Sx, h4Sf, h4Sa, h4St_t, h4St_b, bar_index, math.max(h4Buf, (h4St_t - h4St_b)) * 1.5, i_histKeep)
    if not na(h4Dt_t) and not na(h4Dt_b)
        fPush(h4Dt, h4Db, h4Dx, h4Df, h4Da, h4Dt_t, h4Dt_b, bar_index, math.max(h4Buf, (h4Dt_t - h4Dt_b)) * 1.5, i_histKeep)
if i_show1h
    if not na(h1St_t) and not na(h1St_b)
        fPush(h1St, h1Sb, h1Sx, h1Sf, h1Sa, h1St_t, h1St_b, bar_index, math.max(h1Buf, (h1St_t - h1St_b)) * 1.5, i_histKeep)
    if not na(h1Dt_t) and not na(h1Dt_b)
        fPush(h1Dt, h1Db, h1Dx, h1Df, h1Da, h1Dt_t, h1Dt_b, bar_index, math.max(h1Buf, (h1Dt_t - h1Dt_b)) * 1.5, i_histKeep)
if i_showCur
    if not na(cPH)
        float cTop = cObSF ? math.max(cObST, high[i_swingLen]) : high[i_swingLen]
        float cBot_s = cObSF ? cObSB : (high[i_swingLen] - cBuf)
        fPush(cSt, cSb, cSx, cSf, cSa, cTop, cBot_s, bar_index[i_swingLen], math.max(cBuf, cTop - cBot_s) * 1.5, i_histKeep)
    if not na(cPL)
        float cBot = cObDF ? math.min(cObDB, low[i_swingLen]) : low[i_swingLen]
        float cTop_d = cObDF ? cObDT : (low[i_swingLen] + cBuf)
        fPush(cDt, cDb, cDx, cDf, cDa, cTop_d, cBot, bar_index[i_swingLen], math.max(cBuf, cTop_d - cBot) * 1.5, i_histKeep)

fManage(dSt,  dSb,  dSx,  dSf,  dSa,  true)
fManage(dDt,  dDb,  dDx,  dDf,  dDa,  false)
fManage(h4St, h4Sb, h4Sx, h4Sf, h4Sa, true)
fManage(h4Dt, h4Db, h4Dx, h4Df, h4Da, false)
fManage(h1St, h1Sb, h1Sx, h1Sf, h1Sa, true)
fManage(h1Dt, h1Db, h1Dx, h1Df, h1Da, false)
fManage(cSt,  cSb,  cSx,  cSf,  cSa,  true)
fManage(cDt,  cDb,  cDx,  cDf,  cDa,  false)

float pxBuf = math.max(atr14 * usePx, syminfo.mintick * 5.0)

[dDh,  dDfr,  dDzt, dDzb, dDcnt]   = fProx(dDt,  dDb,  dDa,  dDf,  false, pxBuf)
[h4Dh, h4Dfr, h4Dzt,h4Dzb,h4Dcnt]  = fProx(h4Dt, h4Db, h4Da, h4Df, false, pxBuf)
[h1Dh, h1Dfr, h1Dzt,h1Dzb,h1Dcnt]  = fProx(h1Dt, h1Db, h1Da, h1Df, false, pxBuf)
[dSh,  dSfr,  dSzt, dSzb, dScnt]   = fProx(dSt,  dSb,  dSa,  dSf,  true,  pxBuf)
[h4Sh, h4Sfr, h4Szt,h4Szb,h4Scnt]  = fProx(h4St, h4Sb, h4Sa, h4Sf, true,  pxBuf)
[h1Sh, h1Sfr, h1Szt,h1Szb,h1Scnt]  = fProx(h1St, h1Sb, h1Sa, h1Sf, true,  pxBuf)

bool   inHTFDem = dDh or h4Dh or h1Dh
bool   inHTFSup = dSh or h4Sh or h1Sh
string demTF    = dDh ? "D" : h4Dh ? "4H" : h1Dh ? "1H" : ""
string supTF    = dSh ? "D" : h4Sh ? "4H" : h1Sh ? "1H" : ""
bool   demFresh = dDh ? dDfr : h4Dh ? h4Dfr : h1Dfr
bool   supFresh = dSh ? dSfr : h4Sh ? h4Sfr : h1Sfr
float  demZBot  = dDh ? dDzb : h4Dh ? h4Dzb : h1Dzb
float  demZTop  = dDh ? dDzt : h4Dh ? h4Dzt : h1Dzt
float  supZTop  = dSh ? dSzt : h4Sh ? h4Szt : h1Szt
float  supZBot  = dSh ? dSzb : h4Sh ? h4Szb : h1Szb

// ============================================================================
// ——— V21.6: ZONE POLARITY + WRONG-SIDE + RE-ARM + REACTION RELAX ENGINE ———
// ============================================================================
// All four guardrails computed here so armGate can consume them downstream.

// ——— (1) ZONE POLARITY: distance ratio = dist-to-demand / (dist-to-demand + dist-to-supply)
// 0.0 = price sitting on demand. 1.0 = sitting on supply. 0.5 = mid-range.
float distToDem = (not na(demZTop) and not na(demZBot)) ? math.max(0.0, math.min(math.abs(close - demZTop), math.abs(close - demZBot))) : float(na)
float distToSup = (not na(supZTop) and not na(supZBot)) ? math.max(0.0, math.min(math.abs(close - supZTop), math.abs(close - supZBot))) : float(na)
float distRatio = (not na(distToDem) and not na(distToSup) and (distToDem + distToSup) > 0.0) ? distToDem / (distToDem + distToSup) : float(na)

// ——— (2) WRONG-SIDE position in active range
// rangePos: where price sits between active demand floor and active supply ceiling.
// 0.0 = at demand floor, 1.0 = at supply ceiling.
float rangeFloor   = not na(demZBot) ? demZBot : (not na(supZBot) ? supZBot - atr14 * 4.0 : close - atr14 * 4.0)
float rangeCeiling = not na(supZTop) ? supZTop : (not na(demZTop) ? demZTop + atr14 * 4.0 : close + atr14 * 4.0)
float rangeSpan    = rangeCeiling - rangeFloor
float rangePos     = rangeSpan > 0.0 ? math.max(0.0, math.min(1.0, (close - rangeFloor) / rangeSpan)) : 0.5

// ——— Polarity verdicts (final gates, fed into armGate downstream)
// PolarityOK_L: structurally legitimate to consider a LONG
bool polarityOK_L = not i_zonePolarityLock or (not na(distRatio) ? distRatio <= i_polarityRatioL : inHTFDem and not inHTFSup)
bool polarityOK_S = not i_zonePolarityLock or (not na(distRatio) ? distRatio >= i_polarityRatioS : inHTFSup and not inHTFDem)

// ——— Wrong-side position checks (independent structural sanity)
bool wrongSideOK_L = not i_wrongSideOn or rangePos <= i_wrongSideMaxL
bool wrongSideOK_S = not i_wrongSideOn or rangePos >= i_wrongSideMinS

// ——— (3) RE-ARM PER ZONE-TOUCH: track whether price has been outside the active zone
// long enough that a return tap counts as a fresh re-tap.
var int   barsOutsideDem = 1000
var int   barsOutsideSup = 1000
var float lastDemTopSeen = float(na)
var float lastSupBotSeen = float(na)
var int   zoneTapCntL    = 0   // re-arms triggered on current active demand zone
var int   zoneTapCntS    = 0
var int   lastReArmBarL  = -100000
var int   lastReArmBarS  = -100000

// Detect zone identity change (new zone replaced old) — reset tap counter
bool demZoneChanged = (not na(demZTop) and not na(lastDemTopSeen) and math.abs(demZTop - lastDemTopSeen) > syminfo.mintick * 5.0)
bool supZoneChanged = (not na(supZBot) and not na(lastSupBotSeen) and math.abs(supZBot - lastSupBotSeen) > syminfo.mintick * 5.0)
if demZoneChanged or na(lastDemTopSeen)
    zoneTapCntL := 0
if supZoneChanged or na(lastSupBotSeen)
    zoneTapCntS := 0
if not na(demZTop)
    lastDemTopSeen := demZTop
if not na(supZBot)
    lastSupBotSeen := supZBot

// Track bars-outside
if inHTFDem
    barsOutsideDem := 0
else
    barsOutsideDem := math.min(barsOutsideDem + 1, 100000)
if inHTFSup
    barsOutsideSup := 0
else
    barsOutsideSup := math.min(barsOutsideSup + 1, 100000)

// Fresh re-tap detection: just entered zone after spending ≥ reArmExitBars outside
bool freshReTapL = inHTFDem and not inHTFDem[1] and barsOutsideDem[1] >= i_reArmExitBars
bool freshReTapS = inHTFSup and not inHTFSup[1] and barsOutsideSup[1] >= i_reArmExitBars

// Re-arm eligibility: zone re-tapped, gap between re-arms passes, cap not exceeded
bool reArmEligibleL = i_reArmOn and freshReTapL and (bar_index - lastReArmBarL) >= i_reArmGap and zoneTapCntL < i_reArmMaxPerZone
bool reArmEligibleS = i_reArmOn and freshReTapS and (bar_index - lastReArmBarS) >= i_reArmGap and zoneTapCntS < i_reArmMaxPerZone

// ——— (4) REACTION RELAX: 4 forms of valid bullish/bearish rejection at zone
// (a) loose pin/hammer: looser wick:body ratio (default 0.40 vs V21.5's 0.50)
bool reactPinL  = inHTFDem and not na(demZBot) and low <= demZTop and lowWick > cbody * i_reactWickRatio and lowWick > atr14 * 0.25
bool reactPinS  = inHTFSup and not na(supZTop) and high >= supZBot and upWick  > cbody * i_reactWickRatio and upWick  > atr14 * 0.25
// (b) engulfing at zone
bool reactEngL  = inHTFDem and bEng  and low <= demZTop
bool reactEngS  = inHTFSup and seEng and high >= supZBot
// (c) body bounce: 2-bar body close above zone top after wick in (or below for shorts)
bool wickInDemL_prev = low[1] <= demZTop and close[1] >= demZBot
bool reactBodyL = inHTFDem and wickInDemL_prev and close > demZTop and close > open
bool wickInSupS_prev = high[1] >= supZBot and close[1] <= supZTop
bool reactBodyS = inHTFSup and wickInSupS_prev and close < supZBot and close < open
// (d) ATR context: small body still inside zone + prior bar set up the entry
bool reactCtxL  = inHTFDem and cbody < atr14 * 0.4 and close > demZBot and close < demZTop and close > close[1]
bool reactCtxS  = inHTFSup and cbody < atr14 * 0.4 and close < supZTop and close > supZBot and close < close[1]

// Final relaxed reaction signals (used as alternative to revLong/revShort downstream)
bool reactRelaxL = i_reactionRelax and (reactPinL or reactEngL or reactBodyL or reactCtxL)
bool reactRelaxS = i_reactionRelax and (reactPinS or reactEngS or reactBodyS or reactCtxS)

// String trace (dashboard) of which form fired
string reactWhichL = reactPinL ? "🪞 PIN" : reactEngL ? "🪞 ENGULF" : reactBodyL ? "🪞 BODY" : reactCtxL ? "🪞 CTX" : "—"
string reactWhichS = reactPinS ? "🪞 PIN" : reactEngS ? "🪞 ENGULF" : reactBodyS ? "🪞 BODY" : reactCtxS ? "🪞 CTX" : "—"
int    demStr   = (dDh?1:0) + (h4Dh?1:0) + (h1Dh?1:0)
int    supStr   = (dSh?1:0) + (h4Sh?1:0) + (h1Sh?1:0)

// ============================================================================
// ——— REVERSAL CANDLE LOGIC ———
// ============================================================================
bool revLong  = inHTFDem and not na(demZBot) and low <= demZTop and close > demZBot and close > open and lowWick > cbody * 0.5
bool revShort = inHTFSup and not na(supZTop) and high >= supZBot and close < supZTop and close < open and upWick  > cbody * 0.5

bool oscLong  = rsiSm < 35.0 or stKln < 25.0 or rsi14 < 30.0
bool oscShort = rsiSm > 65.0 or stKln > 75.0 or rsi14 > 70.0

// ============================================================================
// ——— 5-PILLAR CONFLUENCE ———
// ============================================================================
bool lP1 = bEng or bPin or bDoji or revLong
bool lP2 = (rsiSm > rsiSm[1] and rsiSm < 60.0) or (stKln < 45.0 and stKup) or oscLong
bool lP3 = volOK
// V21.7: confluence pillar P4 reads adaptive EMAs.
bool lP4 = eEff9 >= eEff13 or x9up or close > eEff21
bool lP5 = htfBC >= 1 or stBull or x9up or macdBull
int  cfL = (lP1?1:0) + (lP2?1:0) + (lP3?1:0) + (lP4?1:0) + (lP5?1:0)

bool sP1 = seEng or sePin or seDoji or revShort
bool sP2 = (rsiSm < rsiSm[1] and rsiSm > 40.0) or (stKln > 55.0 and stKdn) or oscShort
bool sP3 = volOK
bool sP4 = eEff9 <= eEff13 or x9dn or close < eEff21
bool sP5 = htfSC >= 1 or stBear or x9dn or macdBear
int  cfS = (sP1?1:0) + (sP2?1:0) + (sP3?1:0) + (sP4?1:0) + (sP5?1:0)

// ============================================================================
// ——— ARM / TRIGGER STATE MACHINE ———
// ----------------------------------------------------------------------------
//   STATE → IDLE | ARMED_LONG | ARMED_SHORT
//   transitions:
//     IDLE  + zoneTap (demand) + gates OK  → ARMED_LONG
//     IDLE  + zoneTap (supply) + gates OK  → ARMED_SHORT
//     ARMED + first valid trigger          → FIRE  → IDLE
//     ARMED + invalidation                 → EXPIRE → IDLE
// ============================================================================
var bool   armedL    = false
var bool   armedS    = false
var int    armBarL   = 0
var int    armBarS   = 0
var float  armZtL    = na
var float  armZbL    = na
var float  armZtS    = na
var float  armZbS    = na
var string armTFL    = ""
var string armTFS    = ""
var bool   armFreshL = false
var bool   armFreshS = false
var int    armCfL    = 0
var int    armCfS    = 0
var float  armRefPxL = na   // price at arm — used for run-away check
var float  armRefPxS = na

var int lastSigBar  = -999
var int lastLossBar = -999
bool cdOK   = (bar_index - lastSigBar)  >= pCD
bool lossOK = (bar_index - lastLossBar) >= pLossCD

bool extremeOS = rsiSm < 30.0 and stKln < 20.0
bool extremeOB = rsiSm > 70.0 and stKln > 80.0
bool longOK    = not blockLong  or extremeOS
bool shortOK   = not blockShort or extremeOB

// ——— ARM gates: minimum quality required to even arm a side ———
// V21.6: armGate now layered with polarityOK + wrongSideOK.
// Note: V21.6 ALSO accepts non-fresh zones when re-arm is active (re-arm replaces freshness).
bool armGateL = inHTFDem and htfLong  and not inHTFSup and (not pFresh or demFresh or i_reArmOn) and cdOK and lossOK and adxOK and longOK  and (not i_stReq or stBull) and polarityOK_L and wrongSideOK_L
bool armGateS = inHTFSup and htfShort and not inHTFDem and (not pFresh or supFresh or i_reArmOn) and cdOK and lossOK and adxOK and shortOK and (not i_stReq or stBear) and polarityOK_S and wrongSideOK_S

// ——— ARM event: fresh entry into the zone (was outside last bar, inside now) ———
// V21.6: also fires when re-arm is eligible (return-tap of same active zone).
bool armNowL_first = i_armOn and armGateL and not armedL and not armedS
bool armNowL_reArm = i_armOn and armGateL and not armedS and reArmEligibleL
bool armNowL = armNowL_first or armNowL_reArm
bool armNowS_first = i_armOn and armGateS and not armedS and not armedL
bool armNowS_reArm = i_armOn and armGateS and not armedL and reArmEligibleS
bool armNowS = armNowS_first or armNowS_reArm

if armNowL
    armedL    := true
    armBarL   := bar_index
    armZtL    := demZTop
    armZbL    := demZBot
    armTFL    := demTF
    armFreshL := demFresh
    armCfL    := cfL
    armRefPxL := close
    if armNowL_reArm
        zoneTapCntL := zoneTapCntL + 1
        lastReArmBarL := bar_index
    else
        zoneTapCntL := 1
        lastReArmBarL := bar_index

if armNowS
    armedS    := true
    armBarS   := bar_index
    armZtS    := supZTop
    armZbS    := supZBot
    armTFS    := supTF
    armFreshS := supFresh
    armCfS    := cfS
    armRefPxS := close
    if armNowS_reArm
        zoneTapCntS := zoneTapCntS + 1
        lastReArmBarS := bar_index
    else
        zoneTapCntS := 1
        lastReArmBarS := bar_index

// ——— V21.5: Momentum strength gate (used to exempt strong-breakout "runaway" cancels)
// Strong directional momentum = high volume + high ADX + aligned trend bias.
bool volStrong  = volume > vma20 * i_momVolMult
bool adxStrong  = adxVal > i_momADXmin
bool momStrongL = i_momentumExempt and volStrong and adxStrong and htfLong  and close > open
bool momStrongS = i_momentumExempt and volStrong and adxStrong and htfShort and close < open

// ——— ARM invalidation paths (per side) ———
// V21.5: BOS / RUNAWAY are EXEMPTED when momentum is strong in the trade direction.
// We still flag them (so dashboard / late-fire logic can react), but they don't kill the ARM.
bool expireL_window = armedL and (bar_index - armBarL) > eff_armW
bool expireL_bos_raw    = armedL and not na(armZbL) and close < armZbL - atr14 * i_armBOSBuf
bool expireL_runaway_raw= armedL and not na(armRefPxL) and (close - armRefPxL) > atr14 * i_armRunAway and not (low <= armZtL)
bool expireL_bos    = expireL_bos_raw     and not momStrongL
bool expireL_runaway= expireL_runaway_raw and not momStrongL
bool expireL_flip   = armedL and inHTFSup and not inHTFDem
bool expireL        = expireL_window or expireL_bos or expireL_runaway or expireL_flip

bool expireS_window = armedS and (bar_index - armBarS) > eff_armW
bool expireS_bos_raw    = armedS and not na(armZtS) and close > armZtS + atr14 * i_armBOSBuf
bool expireS_runaway_raw= armedS and not na(armRefPxS) and (armRefPxS - close) > atr14 * i_armRunAway and not (high >= armZbS)
bool expireS_bos    = expireS_bos_raw     and not momStrongS
bool expireS_runaway= expireS_runaway_raw and not momStrongS
bool expireS_flip   = armedS and inHTFDem and not inHTFSup
bool expireS        = expireS_window or expireS_bos or expireS_runaway or expireS_flip

// V21.5: Late-fire window tracking — when momentum exempts a BOS/runaway,
// remember the bar so we can still fire a late entry within i_momLateBars.
var int momExemptBarL = -10000
var int momExemptBarS = -10000
if armedL and (expireL_bos_raw or expireL_runaway_raw) and momStrongL
    momExemptBarL := bar_index
if armedS and (expireS_bos_raw or expireS_runaway_raw) and momStrongS
    momExemptBarS := bar_index
bool momLateActiveL = i_momentumExempt and i_momLateBars > 0 and (bar_index - momExemptBarL) <= i_momLateBars and armedL
bool momLateActiveS = i_momentumExempt and i_momLateBars > 0 and (bar_index - momExemptBarS) <= i_momLateBars and armedS

// ——— TRIGGER definition (the LTF reaction we wait for once armed) ———
//   • Reversal candle (preferred) OR
//   • Confluence ≥ pArmConf with HTF bias still aligned (oscillator if profile demands)
bool revOK_L   = not pRev or revLong
bool revOK_S   = not pRev or revShort
bool oscOK_L   = not pOsc or oscLong
bool oscOK_S   = not pOsc or oscShort

bool trigRevL  = pArmRev ? revLong  : (revLong  or cfL >= eff_armC)
bool trigRevS  = pArmRev ? revShort : (revShort or cfS >= eff_armC)
bool trigConfL = cfL >= eff_armC and oscOK_L
bool trigConfS = cfS >= eff_armC and oscOK_S
// V21.5: late-fire allowed when momLateActive (after momentum-exempt BOS/runaway).
// Direction must still be aligned with HTF bias and pass standard rev/conf check.
// V21.6: 🪞 reactRelaxL/S admitted as alternative trigger path (pin OR engulf OR body OR ctx).
// Polarity + wrong-side gates already enforced at armGate; reaction relax only fires inside an armed window.
bool triggerL  = armedL and (not expireL or momLateActiveL) and (trigRevL or trigConfL or reactRelaxL) and htfLong  and longOK  and polarityOK_L and wrongSideOK_L
bool triggerS  = armedS and (not expireS or momLateActiveS) and (trigRevS or trigConfS or reactRelaxS) and htfShort and shortOK and polarityOK_S and wrongSideOK_S

// ——— Legacy single-bar mode (when ARM engine OFF) ———
// V21.6: Legacy path also enforces 🧭 zone polarity + 🚫 wrong-side veto so non-ARM users still get the upgrade.
bool legacyL = not i_armOn and inHTFDem and htfLong  and cfL >= eff_conf and (not pFresh or demFresh) and not inHTFSup and cdOK and lossOK and adxOK and longOK  and revOK_L and oscOK_L and (not i_stReq or stBull) and polarityOK_L and wrongSideOK_L
bool legacyS = not i_armOn and inHTFSup and htfShort and cfS >= eff_conf and (not pFresh or supFresh) and not inHTFDem and cdOK and lossOK and adxOK and shortOK and revOK_S and oscOK_S and (not i_stReq or stBear) and not legacyL and polarityOK_S and wrongSideOK_S

// ——— Final fire signals ———
// V21.3: Asset Veto blocks new entries when DNA hostile or rolling WR collapses
bool _rawGoLong  = i_armOn ? triggerL : legacyL
bool _rawGoShort = i_armOn ? (triggerS and not triggerL) : legacyS
// V21.7: SLEEPER auto-suppress + vol-regime forward-declared here (computed post-trade-engine).
// Holds previous bar's value at this point in the bar — gates new entries on bar-fresh state.
var bool  sleeperBlocked = false
var float volRegMult     = 1.0
bool goLong  = _rawGoLong  and not vetoActive and not sleeperBlocked
bool goShort = _rawGoShort and not vetoActive and not sleeperBlocked
bool vetoBlockedL = _rawGoLong  and vetoActive
bool vetoBlockedS = _rawGoShort and vetoActive
bool sleeperBlockedL = _rawGoLong  and not vetoActive and sleeperBlocked
bool sleeperBlockedS = _rawGoShort and not vetoActive and sleeperBlocked

// ——— Disarm on fire / expire ———
if goLong or expireL
    armedL    := false
    armRefPxL := na
if goShort or expireS
    armedS    := false
    armRefPxS := na

// ——— If long fires while short is armed (or vice versa), cancel the other ———
if goLong and armedS
    armedS    := false
    armRefPxS := na
if goShort and armedL
    armedL    := false
    armRefPxL := na

if goLong or goShort
    lastSigBar := bar_index

// Bars remaining in window (for dashboard)
int armRemL = armedL ? math.max(0, eff_armW - (bar_index - armBarL)) : 0
int armRemS = armedS ? math.max(0, eff_armW - (bar_index - armBarS)) : 0

// ============================================================================
// ——— TRADE ENGINE — TIGHT TPs + EXIT-AT-TP1 ———
// ============================================================================
var bool  inLong  = false
var bool  inShort = false
var float entPx   = float(na)
var float stopPx  = float(na)
var float entAtr  = float(na)
var float tp1     = float(na)
var float tp2     = float(na)
var float tp3     = float(na)
var bool  hit1    = false
var bool  hit2    = false
var bool  hit3    = false
var int   entCF   = 0
var int   entBar  = 0

fComputeTPs(float ep, float a, bool isLong) =>
    float t1 = float(na)
    float t2 = float(na)
    float t3 = float(na)
    if i_tpMethod == "Fixed %"
        if isLong
            t1 := ep * (1.0 + eff_tp1 / 100.0)
            t2 := ep * (1.0 + eff_tp2 / 100.0)
            t3 := ep * (1.0 + eff_tp3 / 100.0)
        else
            t1 := ep * (1.0 - eff_tp1 / 100.0)
            t2 := ep * (1.0 - eff_tp2 / 100.0)
            t3 := ep * (1.0 - eff_tp3 / 100.0)
    else if i_tpMethod == "ATR Multiple"
        if isLong
            t1 := ep + eff_tp1A * a
            t2 := ep + eff_tp2A * a
            t3 := ep + eff_tp3A * a
        else
            t1 := ep - eff_tp1A * a
            t2 := ep - eff_tp2A * a
            t3 := ep - eff_tp3A * a
    else
        if isLong
            float opp = na(supZBot) ? ep + 2.0 * a : supZBot
            t1 := ep + 0.3 * a
            t2 := (ep + opp) / 2.0
            t3 := opp
        else
            float oppD = na(demZTop) ? ep - 2.0 * a : demZTop
            t1 := ep - 0.3 * a
            t2 := (ep + oppD) / 2.0
            t3 := oppD
    [t1, t2, t3]

fComputeSL(float ep, float a, bool isLong) =>
    float sl = float(na)
    if i_slZone
        if isLong
            float zb = not na(demZBot) ? demZBot : ep - eff_slA * a
            sl := zb - 0.3 * a
        else
            float zt = not na(supZTop) ? supZTop : ep + eff_slA * a
            sl := zt + 0.3 * a
    else
        sl := isLong ? ep - eff_slA * a : ep + eff_slA * a
    sl

// V21.5: ENTRY-TIME ATR autoscale + per-class TP floors + absolute TP1 floor.
// Applied to eff_tp1/eff_tp2/eff_tp3 (Fixed-% mode) BEFORE fComputeTPs runs at entry,
// so even the first trade gets adaptive TP. V21.4 only ran this in tuner cycles.
if (goLong or goShort) and i_atrEntryAuto and i_tpMethod == "Fixed %"
    float atrPctEntry  = close > 0.0 ? atr14 / close * 100.0 : 0.5
    float atrTPtargetE = math.max(i_atrFloor, atrPctEntry * i_atrTPmult)

    // Per-DNA-class minimums layered with absolute floor
    float classFloor = i_perClassFloor and dna_active ? (dna_isTrend ? 0.50 : dna_isMom ? 0.50 : dna_isRange ? 0.40 : dna_isChop ? 0.30 : dna_isSleep ? 0.25 : 0.30) : 0.0
    float floorTP1   = math.max(i_tp1FloorPct, classFloor)

    // Snap (not blend) until we've had enough tuner cycles to settle.
    // tunerCount is hoisted upstream as int.
    bool snapMode = tunerCount < i_atrSnapCycles
    // V21.7: layer Volatility-Regime multiplier on entry-time targets BEFORE floor.
    float volMultE = (i_v7Master and i_volRegimeOn) ? volRegMult : 1.0
    if snapMode
        eff_tp1 := fClampF(math.max(atrTPtargetE * volMultE,         floorTP1),       0.1, 10.0)
        eff_tp2 := fClampF(math.max(atrTPtargetE * 1.8 * volMultE,   floorTP1 * 1.8), 0.2, 20.0)
        eff_tp3 := fClampF(math.max(atrTPtargetE * 3.0 * volMultE,   floorTP1 * 3.0), 0.5, 50.0)
    else
        // Smaller blend at entry (don't dominate tuner). 0.25 = mild bias toward target.
        eff_tp1 := fClampF(math.max(eff_tp1 * 0.75 + atrTPtargetE * 0.25 * volMultE,         floorTP1),       0.1, 10.0)
        eff_tp2 := fClampF(math.max(eff_tp2 * 0.75 + atrTPtargetE * 1.8 * 0.25 * volMultE,   floorTP1 * 1.8), 0.2, 20.0)
        eff_tp3 := fClampF(math.max(eff_tp3 * 0.75 + atrTPtargetE * 3.0 * 0.25 * volMultE,   floorTP1 * 3.0), 0.5, 50.0)

if goLong
    entPx   := close
    entAtr  := atr14
    [t1L, t2L, t3L] = fComputeTPs(close, atr14, true)
    tp1     := t1L
    tp2     := t2L
    tp3     := t3L
    stopPx  := fComputeSL(close, atr14, true)
    inLong  := true
    inShort := false
    hit1    := false
    hit2    := false
    hit3    := false
    entCF   := cfL
    entBar  := bar_index

if goShort
    entPx   := close
    entAtr  := atr14
    [t1S, t2S, t3S] = fComputeTPs(close, atr14, false)
    tp1     := t1S
    tp2     := t2S
    tp3     := t3S
    stopPx  := fComputeSL(close, atr14, false)
    inShort := true
    inLong  := false
    hit1    := false
    hit2    := false
    hit3    := false
    entCF   := cfS
    entBar  := bar_index

if i_trail and not pExitTP1 and not na(stopPx) and not na(entPx)
    if inLong and hit1
        stopPx := math.max(stopPx, entPx)
        if hit2
            stopPx := math.max(stopPx, close - 1.5 * atr14)
    if inShort and hit1
        stopPx := math.min(stopPx, entPx)
        if hit2
            stopPx := math.min(stopPx, close + 1.5 * atr14)

bool lh1 = inLong  and not hit1 and not na(tp1) and high >= tp1
bool lh2 = inLong  and not hit2 and not na(tp2) and high >= tp2
bool lh3 = inLong  and not hit3 and not na(tp3) and high >= tp3
bool sh1 = inShort and not hit1 and not na(tp1) and low  <= tp1
bool sh2 = inShort and not hit2 and not na(tp2) and low  <= tp2
bool sh3 = inShort and not hit3 and not na(tp3) and low  <= tp3
bool aH1 = lh1 or sh1
bool aH2 = lh2 or sh2
bool aH3 = lh3 or sh3
if aH1
    hit1 := true
if aH2
    hit2 := true
if aH3
    hit3 := true

bool slL = inLong  and not na(stopPx) and low  <= stopPx
bool slS = inShort and not na(stopPx) and high >= stopPx
bool tpExitL = pExitTP1 and lh1
bool tpExitS = pExitTP1 and sh1
bool exL = inLong  and hit1 and x9dn and not pExitTP1
bool exS = inShort and hit1 and x9up and not pExitTP1
bool xL  = slL or tpExitL or exL or lh3
bool xS  = slS or tpExitS or exS or sh3

// ============================================================================
// ——— P&L TRACKING ———
// ============================================================================
// V21.4: Configurable long-term rolling buffer (was hard-coded 50)
var float[] wArr = array.new<float>(i_rollLong, 0.5)
var float[] rArr = array.new<float>(i_rollLong, 0.0)
var int   tIdx  = 0
var int   wArrCap = i_rollLong
var int   tTot  = 0
var int   tWin  = 0
var float cumPL = 0.0
var int   streak = 0
var int   bestStreak = 0
var int   worstStreak = 0

if xL and not na(entPx)
    float xp  = slL ? stopPx : tpExitL ? tp1 : close
    float pnl = (xp - entPx) / entPx * 100.0 * float(i_lev)
    cumPL    += pnl
    bool wL   = pnl > 0.0
    if wL
        tWin += 1
        streak := streak >= 0 ? streak + 1 : 1
        bestStreak := math.max(bestStreak, streak)
    else
        lastLossBar := bar_index
        streak := streak <= 0 ? streak - 1 : -1
        worstStreak := math.min(worstStreak, streak)
    array.set(wArr, tIdx % wArrCap, wL ? 1.0 : 0.0)
    array.set(rArr, tIdx % wArrCap, pnl)
    tIdx += 1
    tTot += 1
    label.new(bar_index, high + atr14, wL ? "W" : "L", color=wL ? color.new(color.lime, 5) : color.new(color.red, 5), textcolor=color.white, style=label.style_label_down, size=size.tiny)
    inLong  := false
    entPx   := float(na)
    stopPx  := float(na)

if xS and not na(entPx)
    float xp2 = slS ? stopPx : tpExitS ? tp1 : close
    float pns = (entPx - xp2) / entPx * 100.0 * float(i_lev)
    cumPL    += pns
    bool wS   = pns > 0.0
    if wS
        tWin += 1
        streak := streak >= 0 ? streak + 1 : 1
        bestStreak := math.max(bestStreak, streak)
    else
        lastLossBar := bar_index
        streak := streak <= 0 ? streak - 1 : -1
        worstStreak := math.min(worstStreak, streak)
    array.set(wArr, tIdx % wArrCap, wS ? 1.0 : 0.0)
    array.set(rArr, tIdx % wArrCap, pns)
    tIdx += 1
    tTot += 1
    label.new(bar_index, low - atr14, wS ? "W" : "L", color=wS ? color.new(color.lime, 5) : color.new(color.red, 5), textcolor=color.white, style=label.style_label_up, size=size.tiny)
    inShort := false
    entPx   := float(na)
    stopPx  := float(na)

float wr   = tTot > 0 ? float(tWin) / float(tTot) * 100.0 : 0.0

// V21.4: Long-term rolling stats (configurable window) + Short-term reactive stats
int   nRoll       = math.min(tTot, wArrCap)
int   nRollShort  = math.min(tTot, i_rollShort)
float rW = 0.0
float rR = 0.0
float rQ = 0.0
float rWins = 0.0
float rLosses = 0.0
float sW = 0.0    // short-window wins count
float sWins = 0.0 // short-window winning $
float sLoss = 0.0 // short-window losing $ (abs)
// V21.7: track win/loss COUNTS for realized-RR feedback (avgWin / avgLoss).
int   nWinR  = 0
int   nLossR = 0
if nRoll > 0
    for mi = 0 to nRoll - 1
        // walk most-recent first so short-window aggregation is guaranteed correct
        int idxRecent = (tIdx - 1 - mi + wArrCap * 10) % wArrCap
        float wv = array.get(wArr, idxRecent)
        float rv = array.get(rArr, idxRecent)
        rW += wv
        rR += rv
        rQ += rv * rv
        if rv > 0.0
            rWins += rv
            nWinR += 1
        else
            rLosses += math.abs(rv)
            if rv < 0.0
                nLossR += 1
        if mi < nRollShort
            sW += wv
            if rv > 0.0
                sWins += rv
            else
                sLoss += math.abs(rv)
// V21.7: avgWin% / avgLoss% — used by Realized-RR Feedback below to widen TP1 when needed.
float avgWinPct  = nWinR  > 0 ? rWins   / float(nWinR)  : 0.0
float avgLossPct = nLossR > 0 ? rLosses / float(nLossR) : 0.0
float realRRr    = avgLossPct > 0.0 ? avgWinPct / avgLossPct : (avgWinPct > 0.0 ? 99.0 : 0.0)
float rollWR    = nRoll > 0 ? rW / float(nRoll) * 100.0 : 0.0
float rMu       = nRoll > 0 ? rR / float(nRoll) : 0.0
float rVar      = nRoll > 0 ? math.max(0.0, rQ / float(nRoll) - rMu * rMu) : 0.0
float shrp      = math.sqrt(rVar) > 0.0 ? rMu / math.sqrt(rVar) : 0.0
float pf        = rLosses > 0.0 ? rWins / rLosses : (rWins > 0.0 ? 99.0 : 0.0)
float rollWR_S  = nRollShort > 0 ? sW / float(nRollShort) * 100.0 : 0.0
float pf_S      = sLoss > 0.0 ? sWins / sLoss : (sWins > 0.0 ? 99.0 : 0.0)
bool  shortBreak = nRollShort >= 5 and rollWR_S < rollWR - 15.0  // recent regime break

// ============================================================================
// V21.7 — 💀 SLEEPER AUTO-SUPPRESS
// Block ALL new entries when DNA = SLEEPER + PF below threshold + min trades met.
// Auto-clears when DNA reclassifies away from SLEEPER OR PF recovers.
// (sleeperBlocked is forward-declared upstream so goLong/goShort can read previous bar's state.)
// ============================================================================
bool sleeperBlockTrigger = i_v7Master and i_sleeperBlockOn and dna_active and dna_isSleep and pf < i_sleeperPF and tTot >= i_sleeperMinT
bool sleeperBlockClear   = (not dna_isSleep) or pf >= i_sleeperRecoverPF or not dna_active
if sleeperBlockTrigger and not sleeperBlocked
    sleeperBlocked := true
else if sleeperBlocked and sleeperBlockClear
    sleeperBlocked := false

// ============================================================================
// V21.7 — 🌡 VOLATILITY-REGIME TP MULTIPLIER (every-bar lookup)
// Computed every bar. Applied at entry-time and on tuner cycles below.
// Always respects absolute TP1 floor (≥0.40%) + per-DNA-class floor.
// (volRegMult is forward-declared upstream so entry-time tuner can read previous bar's value.)
// ============================================================================
float _atrPctV7 = close > 0.0 ? atr14 / close * 100.0 : 0.5
volRegMult := not (i_v7Master and i_volRegimeOn) ? 1.0 : (_atrPctV7 < 0.20 ? i_volMultLow : _atrPctV7 < 0.50 ? i_volMultMid : _atrPctV7 < 1.00 ? i_volMultHi : i_volMultUltra)
string volRegBucket = _atrPctV7 < 0.20 ? "VERY-LOW (<0.20%)" : _atrPctV7 < 0.50 ? "NEUTRAL (0.20–0.50%)" : _atrPctV7 < 1.00 ? "ELEVATED (0.50–1.00%)" : "HIGH (>1.00%)"

// ============================================================================
// V21.7 — 🎚 CF AUTO-TUNE (per-asset closed-loop, independent of main tuner cycle)
// Drives eff_conf up when realized PF<1+WR<55%, down when PF>1.8+WR>70%.
// Bounded by user-set floor/ceiling. Reacts every cycle there's a new closed trade.
// ============================================================================
var int cfAutoLastTrades = 0
var int cfAutoLastDelta  = 0
var int cfAutoCount      = 0
bool cfAutoEligible = i_v7Master and i_cfAutoOn and tTot >= i_cfAutoMinT and tTot != cfAutoLastTrades
if cfAutoEligible
    int cfDelta = 0
    if pf < i_cfAutoUpPF and rollWR < i_cfAutoUpWR and eff_conf < i_cfAutoCeil
        cfDelta := 1
    else if pf > i_cfAutoDnPF and rollWR > i_cfAutoDnWR and eff_conf > i_cfAutoFloor
        cfDelta := -1
    if cfDelta != 0
        eff_conf := fClampI(eff_conf + cfDelta, i_cfAutoFloor, i_cfAutoCeil)
        cfAutoLastDelta := cfDelta
        cfAutoCount     := cfAutoCount + 1
    cfAutoLastTrades := tTot

// ============================================================================
// V21.7 — 🔬 ASSET MEMORY (snapshot best calibration; revert when degraded)
// Stores eff_tp1/tp2/tp3/conf/armW snapshot when PF≥2.0 + WR≥70%.
// Reverts to snapshot when PF degrades below revert threshold.
// ============================================================================
var float memTp1   = na
var float memTp2   = na
var float memTp3   = na
var float memTp1A  = na
var float memTp2A  = na
var float memTp3A  = na
var float memSlA   = na
var int   memConf  = na
var int   memArmW  = na
var int   memSnaps = 0
var int   memReverts = 0
var bool  memHas   = false
var int   memLastTrades = 0
bool memEligible = i_v7Master and i_memOn and tTot >= i_tunerMinT and tTot != memLastTrades
if memEligible
    if pf >= i_memSnapPF and rollWR >= i_memSnapWR
        memTp1   := eff_tp1
        memTp2   := eff_tp2
        memTp3   := eff_tp3
        memTp1A  := eff_tp1A
        memTp2A  := eff_tp2A
        memTp3A  := eff_tp3A
        memSlA   := eff_slA
        memConf  := eff_conf
        memArmW  := eff_armW
        memHas   := true
        memSnaps := memSnaps + 1
    else if memHas and pf <= i_memRevertPF
        eff_tp1   := memTp1
        eff_tp2   := memTp2
        eff_tp3   := memTp3
        eff_tp1A  := memTp1A
        eff_tp2A  := memTp2A
        eff_tp3A  := memTp3A
        eff_slA   := memSlA
        eff_conf  := memConf
        eff_armW  := memArmW
        memReverts := memReverts + 1
    memLastTrades := tTot

// ============================================================================
// ——— 🤖 AI ADAPTIVE AUTO-TUNER (closed-loop self-optimization) ———
// Mutates effective TP / SL / Conf / ARM-window / Proximity every N bars based on:
//   • Rolling Win Rate, Profit Factor, Sharpe over last 50 trades
//   • ATR ratio (vol regime)
//   • Discrete regime score (-2..+2)
// Anti-oscillation: freeze when winning, hard min-interval, bounded ranges, single-step deltas.
// ============================================================================
var int   tunerLastBar  = -100000
var int   tunerLastTrades = 0
// tunerCount hoisted earlier (V21.5)
var string tunerLastAction = "INIT"
var float tunerLastWR   = 0.0
var int   tunerDir      = 0   // -1 tighten, 0 hold, +1 loosen — last decision

// Helpers — clamp helpers hoisted earlier (V21.5) for entry-time ATR autoscale access

// ——— V21.5: Asset Veto latch logic — HARDENED + DELTA HYSTERESIS + IDLE BARS + FORCE-OFF
// Hard guard: if no trades have been recorded yet, veto CANNOT fire (was a bug)
bool vetoTriggerDNA  = i_vetoOn and dna_active and dna_hostile and tTot >= i_vetoMinT and not i_vetoForceOff
bool vetoTriggerStat = i_vetoOn and tTot >= i_vetoMinT and rollWR < i_vetoWR and not i_vetoForceOff
bool vetoTriggerNow  = vetoTriggerDNA or vetoTriggerStat

// V21.5 last-trade-bar tracker for idle clear
var int vetoLastTradeBar = 0
if tTot != tTot[1]
    vetoLastTradeBar := bar_index

// Idle-clear: fresh chart load (tTot=0) or no trades for a long time should release veto
bool vetoIdleClear   = tTot == 0 or (tTot < i_vetoMinT) or (bar_index - vetoLastTradeBar) >= i_vetoIdleBars

// V21.5 DELTA hysteresis recover: clear at vetoWR + i_vetoHyst (was hard-coded i_vetoRecover, too wide)
float vetoRecoverEff = math.min(95.0, i_vetoWR + i_vetoHyst)
bool  vetoStatRecover = rollWR >= vetoRecoverEff and not dna_hostile

if i_vetoForceOff
    vetoLatched := false
else if vetoTriggerNow and not vetoLatched
    vetoLatched := true
else if vetoLatched and (vetoIdleClear or vetoStatRecover)
    vetoLatched := false

// ——— V21.3: Tuner Acceleration — when underwater + hostile DNA, re-tune ~4x faster
// V21.4: Tuner accelerates on hostile DNA OR short-term break OR PF<1
bool tunerAccel = i_tunerOn and tTot >= 5 and ((dna_active and dna_hostile and rollWR < 50.0) or shortBreak or (pf < 1.0 and tTot >= i_tunerMinT))
int  tunerBarsEff = tunerAccel ? math.max(15, i_tunerBars / 4) : i_tunerBars

bool tunerEligible = i_tunerOn and tTot >= i_tunerMinT and (bar_index - tunerLastBar) >= tunerBarsEff
bool tunerFreeze   = rollWR >= i_tunerFreezeWR and shrp >= 1.0
bool tunerNewTrade = tTot != tunerLastTrades

bool scopeAll  = i_tunerScope == "All"
bool scopeTP   = scopeAll or i_tunerScope == "TP only"
bool scopeSL   = scopeAll or i_tunerScope == "SL only"
bool scopeCF   = scopeAll or i_tunerScope == "Conf only"
bool scopePx   = scopeAll or i_tunerScope == "Px only"

// V21.4 ATR-aware baseline %: computed every bar so PF Guardian and tuner can scale to it
float atrPct = close > 0.0 ? atr14 / close * 100.0 : 0.5

// V21.4 PF Guardian active flag (hoisted to global scope so dashboard + alerts can read it)
bool pfGuardActiveNow = i_pfGuardOn and rollWR >= 60.0 and pf < i_pfMinPF and tTot >= i_tunerMinT

// Decision step (only fires when eligible AND not frozen)
if tunerEligible and not tunerFreeze and tunerNewTrade
    float kAg = i_tunerAggro
    string action = "HOLD"
    int    dir    = 0

    // ——— V21.4 PRIORITY 0: 💰 PF GUARDIAN ———
    // Trigger: WR is decent (≥60%) but PF is broken (<i_pfMinPF). Wins too small.
    // Fix: WIDEN TP1 + TIGHTEN SL until math forces RR ≥ i_pfMinRR.
    // This OVERRIDES the old "mild-tighten" path which was making it worse.
    bool pfBroken = i_pfGuardOn and rollWR >= 60.0 and pf < i_pfMinPF and tTot >= i_tunerMinT
    if pfBroken
        if scopeTP
            eff_tp1  := fClampF(eff_tp1  * (1.0 + i_pfWidenStep * kAg), 0.1, 10.0)
            eff_tp1A := fClampF(eff_tp1A * (1.0 + i_pfWidenStep * kAg), 0.2, 8.0)
            eff_tp2  := fClampF(eff_tp2  * (1.0 + i_pfWidenStep * kAg * 0.6), 0.2, 20.0)
            eff_tp2A := fClampF(eff_tp2A * (1.0 + i_pfWidenStep * kAg * 0.6), 0.4, 15.0)
        if scopeSL
            eff_slA  := fClampF(eff_slA  * (1.0 - i_pfTightStep * kAg), 0.2, 5.0)
        action := "💰 PF GUARDIAN → widen TP + tight SL"
        dir    := 1

    // ——— 1. Defensive mode: negative Sharpe → tighten everything aggressively
    else if shrp < 0.0 or (rollWR < 50.0 and tTot >= i_tunerMinT)
        if scopeCF
            eff_conf := fClampI(eff_conf + 1, 1, 5)
            eff_armC := fClampI(eff_armC + 1, 1, 5)
        if scopeTP
            // V21.4: only tighten TP if PF is healthy — if PF<1 we'd be making it worse
            if pf >= 1.0
                eff_tp1  := fClampF(eff_tp1  * (1.0 - 0.10 * kAg), 0.1, 10.0)
                eff_tp1A := fClampF(eff_tp1A * (1.0 - 0.10 * kAg), 0.2, 8.0)
        if scopeSL
            eff_slA  := fClampF(eff_slA  * (1.0 - 0.05 * kAg), 0.2, 5.0)
        action := "DEFENSIVE → tighten"
        dir    := -1

    // ——— 2. Underperforming (low WR AND low PF) → mild tighten
    // V21.4: condition tightened — only mild-tighten when BOTH WR<60 AND PF<1.5
    // Old logic fired on "OR" which mis-handled high-WR-low-PF assets like ANET.
    else if rollWR < 60.0 and pf < 1.5
        if scopeCF
            eff_conf := fClampI(eff_conf + 1, 1, 5)
            eff_armW := fClampI(eff_armW - 3, 5, 200)
        if scopeTP
            eff_tp1  := fClampF(eff_tp1  * (1.0 - 0.05 * kAg), 0.1, 10.0)
            eff_tp1A := fClampF(eff_tp1A * (1.0 - 0.05 * kAg), 0.2, 8.0)
        action := "MILD TIGHTEN"
        dir    := -1

    // ——— 3. Healthy WR (75-80%) but few signals → slight loosen
    else if rollWR >= 75.0 and rollWR < i_tunerFreezeWR and (bar_index - lastSigBar) > i_tunerBars / 2
        if scopeCF
            eff_conf := fClampI(eff_conf - 1, 1, 5)
            eff_armW := fClampI(eff_armW + 5, 5, 200)
        if scopeTP
            eff_tp2  := fClampF(eff_tp2  * (1.0 + 0.05 * kAg), 0.2, 20.0)
            eff_tp3  := fClampF(eff_tp3  * (1.0 + 0.05 * kAg), 0.5, 50.0)
            eff_tp2A := fClampF(eff_tp2A * (1.0 + 0.05 * kAg), 0.4, 15.0)
            eff_tp3A := fClampF(eff_tp3A * (1.0 + 0.05 * kAg), 1.0, 30.0)
        action := "OPPORTUNISTIC → loosen for more signals"
        dir    := 1

    // ——— 4. Strong regime + good WR → let TP3 run
    if math.abs(regime) >= 2 and rollWR >= 70.0 and scopeTP
        eff_tp3  := fClampF(eff_tp3  * (1.0 + 0.08 * kAg), 0.5, 50.0)
        eff_tp3A := fClampF(eff_tp3A * (1.0 + 0.08 * kAg), 1.0, 30.0)
        action := action + " + TP3 RUN"
        dir    := dir == 0 ? 1 : dir

    // ——— 5. Volatility scaling (always layered last)
    if atrRatio > 1.3 and scopePx
        eff_pxM := fClampF(eff_pxM + 0.05 * kAg, 0.05, 3.0)
        action := action + " + HIVOL px↑"
    else if atrRatio < 0.8 and scopePx
        eff_pxM := fClampF(eff_pxM - 0.05 * kAg, 0.05, 3.0)
        action := action + " + LOVOL px↓"

    if atrRatio > 1.3 and scopeSL
        eff_slA := fClampF(eff_slA * (1.0 + 0.05 * kAg), 0.2, 5.0)
    else if atrRatio < 0.8 and scopeSL
        eff_slA := fClampF(eff_slA * (1.0 - 0.05 * kAg), 0.2, 5.0)

    // ——— V21.5 📏 ATR-AWARE TP AUTOSCALER — FASTER (i_atrBlendFast, was 0.30)
    // Snaps eff_tp1 toward asset's ATR·%-of-price baseline so TP fits asset volatility.
    // Only when TP method is Fixed % (ATR-mode TPs already volatility-aware).
    // V21.5: also snaps for first i_atrSnapCycles tuner runs (no smoothing) for fast catch-up.
    if i_atrAutoOn and i_tpMethod == "Fixed %" and scopeTP
        float atrTPtarget = math.max(i_atrFloor, atrPct * i_atrTPmult)
        bool  tunerSnap   = tunerCount < i_atrSnapCycles
        float blendT      = tunerSnap ? 1.0 : i_atrBlendFast  // 1.0 = pure snap
        eff_tp1 := fClampF(eff_tp1 * (1.0 - blendT) + atrTPtarget       * blendT, 0.1, 10.0)
        eff_tp2 := fClampF(eff_tp2 * (1.0 - blendT) + atrTPtarget * 1.8 * blendT, 0.2, 20.0)
        eff_tp3 := fClampF(eff_tp3 * (1.0 - blendT) + atrTPtarget * 3.0 * blendT, 0.5, 50.0)

    // V21.7: 🌡 VOLATILITY-REGIME TP MULTIPLIER — layered before floor enforcement.
    // Multiplies eff_tp1/2/3 by volRegMult based on atrPct bucket.
    // Low-vol assets (AMZN-style 0.32%) shrink toward floor; high-vol (MU 1.13%) expand.
    if i_v7Master and i_volRegimeOn and i_tpMethod == "Fixed %" and scopeTP
        eff_tp1 := fClampF(eff_tp1 * volRegMult, 0.1, 10.0)
        eff_tp2 := fClampF(eff_tp2 * volRegMult, 0.2, 20.0)
        eff_tp3 := fClampF(eff_tp3 * volRegMult, 0.5, 50.0)
        action  := action + " + VOL-REG ×" + str.tostring(math.round(volRegMult*100)/100)
    if i_v7Master and i_volRegimeOn and i_tpMethod == "ATR Multiple" and scopeTP
        eff_tp1A := fClampF(eff_tp1A * volRegMult, 0.2, 8.0)
        eff_tp2A := fClampF(eff_tp2A * volRegMult, 0.4, 15.0)
        eff_tp3A := fClampF(eff_tp3A * volRegMult, 1.0, 30.0)
        action   := action + " + VOL-REG-A ×" + str.tostring(math.round(volRegMult*100)/100)

    // V21.7: 🎯 REALIZED-RR FEEDBACK — widen TP1 if avgWin too small vs avgLoss; expand TP3 if winning big.
    if i_v7Master and i_realRRon and tTot >= i_realRRMinT and avgLossPct > 0.0 and scopeTP
        if realRRr < i_realRRwidenAt
            eff_tp1  := fClampF(eff_tp1  * (1.0 + i_realRRwidenStep * kAg), 0.1, 10.0)
            eff_tp1A := fClampF(eff_tp1A * (1.0 + i_realRRwidenStep * kAg), 0.2, 8.0)
            action   := action + " + REAL-RR widen TP1 (" + str.tostring(math.round(realRRr*100)/100) + ")"
        else if realRRr > i_realRRexpandAt
            eff_tp3  := fClampF(eff_tp3  * (1.0 + 0.10 * kAg), 0.5, 50.0)
            eff_tp3A := fClampF(eff_tp3A * (1.0 + 0.10 * kAg), 1.0, 30.0)
            action   := action + " + REAL-RR expand TP3 (" + str.tostring(math.round(realRRr*100)/100) + ")"

    // V21.5: Per-class TP1 floor + absolute TP1 floor enforcement (Fixed-% mode)
    if i_atrAutoOn and i_tpMethod == "Fixed %" and scopeTP
        float classFloorT = i_perClassFloor and dna_active ? (dna_isTrend ? 0.50 : dna_isMom ? 0.50 : dna_isRange ? 0.40 : dna_isChop ? 0.30 : dna_isSleep ? 0.25 : 0.30) : 0.0
        // V21.7: absolute floor lifted to user-stated 0.40% (i_tp1FloorPct default).
        float floorT      = math.max(i_tp1FloorPct, classFloorT)
        if eff_tp1 < floorT
            eff_tp1 := fClampF(floorT, 0.1, 10.0)
            action  := action + " + V5-FLOOR"

    // ——— V21.4 RR FLOOR enforcement — final guard so TP1·% ≥ SL·% × minRR
    // SL·% ≈ eff_slA × atrPct (since SL = entry ± eff_slA × ATR → % distance ≈ eff_slA × ATR/price×100)
    if i_pfGuardOn and scopeTP
        float slPctEff = eff_slA * atrPct  // approximate SL distance in %
        float tpFloor  = slPctEff * i_pfMinRR
        if i_tpMethod == "Fixed %" and eff_tp1 < tpFloor
            eff_tp1 := fClampF(tpFloor, 0.1, 10.0)
            action := action + " + RR-FLOOR"
        // ATR-mode RR floor: ensure eff_tp1A ≥ eff_slA × minRR
        if i_tpMethod == "ATR Multiple" and eff_tp1A < eff_slA * i_pfMinRR
            eff_tp1A := fClampF(eff_slA * i_pfMinRR, 0.2, 8.0)
            action := action + " + RR-FLOOR(atr)"

    tunerLastBar     := bar_index
    tunerLastTrades  := tTot
    tunerCount       := tunerCount + 1
    tunerLastAction  := action
    tunerLastWR      := rollWR
    tunerDir         := dir

    if i_tunerLog
        color labCol = dir > 0 ? color.new(color.lime, 25) : dir < 0 ? color.new(color.red, 25) : color.new(color.gray, 30)
        label.new(bar_index, high + atr14 * 2.0, "🤖 TUNER #" + str.tostring(tunerCount) + "\n" + action + "\nWR " + str.tostring(math.round(rollWR*10.0)/10.0) + "% PF " + str.tostring(math.round(pf*100.0)/100.0) + " Sh " + str.tostring(math.round(shrp*100.0)/100.0), color=labCol, textcolor=color.white, style=label.style_label_down, size=size.tiny)

// Track frozen status for dashboard
bool tunerFrozenNow = i_tunerOn and tunerFreeze

// ============================================================================
// ——— WALK-FORWARD AI ———
// ============================================================================
int conf_S = 5
int conf_B = 4
int conf_A = 3

bool sigL_S = inHTFDem and htfLong  and cfL >= conf_S and demFresh and not inHTFSup and revLong  and oscLong
bool sigS_S = inHTFSup and htfShort and cfS >= conf_S and supFresh and not inHTFDem and revShort and oscShort
bool sigL_B = inHTFDem and htfLong  and cfL >= conf_B and not inHTFSup and revLong
bool sigS_B = inHTFSup and htfShort and cfS >= conf_B and not inHTFDem and revShort
bool sigL_A = inHTFDem and htfLong  and cfL >= conf_A and not inHTFSup
bool sigS_A = inHTFSup and htfShort and cfS >= conf_A and not inHTFDem

var float vPnl_S = 0.0
var float vPnl_B = 0.0
var float vPnl_A = 0.0
var int   vTot_S = 0
var int   vTot_B = 0
var int   vTot_A = 0
var int   vWin_S = 0
var int   vWin_B = 0
var int   vWin_A = 0
var float vSqr_S = 0.0
var float vSqr_B = 0.0
var float vSqr_A = 0.0

fSimulate(bool sigL, bool sigS) =>
    var bool inL = false
    var bool inS = false
    var float ep = float(na)
    float pnl = 0.0
    bool closed = false
    bool winF = false
    if not inL and not inS
        if sigL
            inL := true
            ep  := close
        else if sigS
            inS := true
            ep  := close
    else if inL and not na(ep)
        float tg = ep * 1.005
        float sl = ep * 0.993
        if high >= tg
            pnl    := 0.5
            closed := true
            winF   := true
            inL    := false
        else if low <= sl
            pnl    := -0.7
            closed := true
            winF   := false
            inL    := false
    else if inS and not na(ep)
        float tgS_loc = ep * 0.995
        float slS_loc = ep * 1.007
        if low <= tgS_loc
            pnl    := 0.5
            closed := true
            winF   := true
            inS    := false
        else if high >= slS_loc
            pnl    := -0.7
            closed := true
            winF   := false
            inS    := false
    [closed, winF, pnl]

[c_S, w_S, p_S] = fSimulate(sigL_S, sigS_S)
[c_B, w_B, p_B] = fSimulate(sigL_B, sigS_B)
[c_A, w_A, p_A] = fSimulate(sigL_A, sigS_A)

if c_S
    vPnl_S += p_S
    vSqr_S += p_S * p_S
    vTot_S += 1
    if w_S
        vWin_S += 1
if c_B
    vPnl_B += p_B
    vSqr_B += p_B * p_B
    vTot_B += 1
    if w_B
        vWin_B += 1
if c_A
    vPnl_A += p_A
    vSqr_A += p_A * p_A
    vTot_A += 1
    if w_A
        vWin_A += 1

float vWR_S = vTot_S > 0 ? float(vWin_S) / float(vTot_S) * 100.0 : 0.0
float vWR_B = vTot_B > 0 ? float(vWin_B) / float(vTot_B) * 100.0 : 0.0
float vWR_A = vTot_A > 0 ? float(vWin_A) / float(vTot_A) * 100.0 : 0.0

float vMu_S = vTot_S > 0 ? vPnl_S / float(vTot_S) : 0.0
float vMu_B = vTot_B > 0 ? vPnl_B / float(vTot_B) : 0.0
float vMu_A = vTot_A > 0 ? vPnl_A / float(vTot_A) : 0.0
float vSd_S = vTot_S > 0 ? math.sqrt(math.max(0.0, vSqr_S / float(vTot_S) - vMu_S * vMu_S)) : 0.0
float vSd_B = vTot_B > 0 ? math.sqrt(math.max(0.0, vSqr_B / float(vTot_B) - vMu_B * vMu_B)) : 0.0
float vSd_A = vTot_A > 0 ? math.sqrt(math.max(0.0, vSqr_A / float(vTot_A) - vMu_A * vMu_A)) : 0.0
float vSh_S = vSd_S > 0.0 ? vMu_S / vSd_S : 0.0
float vSh_B = vSd_B > 0.0 ? vMu_B / vSd_B : 0.0
float vSh_A = vSd_A > 0.0 ? vMu_A / vSd_A : 0.0

string wfBest = "Sniper"
float  wfBestScore = vSh_S
if i_wfMetric == "Win Rate"
    wfBest      := vWR_S >= vWR_B and vWR_S >= vWR_A ? "Sniper" : vWR_B >= vWR_A ? "Balanced" : "Aggressive"
    wfBestScore := math.max(vWR_S, math.max(vWR_B, vWR_A))
else if i_wfMetric == "Profit Factor"
    wfBest      := vPnl_S >= vPnl_B and vPnl_S >= vPnl_A ? "Sniper" : vPnl_B >= vPnl_A ? "Balanced" : "Aggressive"
    wfBestScore := math.max(vPnl_S, math.max(vPnl_B, vPnl_A))
else
    wfBest      := vSh_S >= vSh_B and vSh_S >= vSh_A ? "Sniper" : vSh_B >= vSh_A ? "Balanced" : "Aggressive"
    wfBestScore := math.max(vSh_S, math.max(vSh_B, vSh_A))

bool wfReady = math.min(vTot_S, math.min(vTot_B, vTot_A)) >= i_wfMinT

// ============================================================================
// ——— 🧬 DNA VERDICT LABEL (V21.3) ———
// ============================================================================
var label dnaLbl = na
if i_dnaShowLabel and i_dnaOn and barstate.islast
    label.delete(dnaLbl)
    string dnaLine1 = "🧬 " + dna_emojiFinal + " " + dna_classFinal
    string dnaLine2 = "T:" + str.tostring(math.round(dna_trendScore)) + "  C:" + str.tostring(math.round(dna_chopScore))
    string dnaLine3 = "V:" + str.tostring(math.round(dna_volScore))   + "  M:" + str.tostring(math.round(dna_momScore))
    string dnaLine4 = dna_active ? (dna_hostile ? "💀 HOSTILE" : "✅ TRADE-OK") : "⏳ WARMING"
    string dnaLine5 = vetoActive ? "\n🚫 VETO ACTIVE" : ""
    string dnaTxt   = dnaLine1 + "\n" + dnaLine2 + "\n" + dnaLine3 + "\n" + dnaLine4 + dnaLine5
    color dnaCol = dna_hostile ? color.new(#ff3344, 10) : dna_isTrend ? color.new(#00ff88, 10) : dna_isMom ? color.new(#ffaa00, 10) : dna_isRange ? color.new(#00bbff, 15) : dna_isSleep ? color.new(#888888, 20) : color.new(#444466, 20)
    dnaLbl := label.new(bar_index + 5, high + atr14 * 3.0, dnaTxt, color=dnaCol, textcolor=color.white, style=label.style_label_down, size=size.small, textalign=text.align_left)

// ============================================================================
// ——— ZONE DRAWING (with armed-glow override) ———
// ============================================================================
if barstate.islast
    // Long-arm zone snapshot for glow
    float gZtL = armedL ? armZtL : na
    float gZbL = armedL ? armZbL : na
    float gZtS = armedS ? armZtS : na
    float gZbS = armedS ? armZbS : na
    bool  glowOnL = armedL and i_armGlow
    bool  glowOnS = armedS and i_armGlow

    if i_showD
        fDraw(dSt, dSb, dSx, dSf, dSa, dSbx, color.new(i_dSupCol, 50), color.new(i_dSupCol, 75), color.new(#FF4444, 30), 2, "D",  true,  gZtS, gZbS, glowOnS, cArm)
        fDraw(dDt, dDb, dDx, dDf, dDa, dDbx, color.new(i_dDemCol, 50), color.new(i_dDemCol, 75), color.new(#0088FF, 30), 2, "D",  false, gZtL, gZbL, glowOnL, cArm)
    if i_show4h
        fDraw(h4St, h4Sb, h4Sx, h4Sf, h4Sa, h4Sbx, color.new(i_h4SupCol, 55), color.new(i_h4SupCol, 78), color.new(#FF8800, 35), 1, "4H", true,  gZtS, gZbS, glowOnS, cArm)
        fDraw(h4Dt, h4Db, h4Dx, h4Df, h4Da, h4Dbx, color.new(i_h4DemCol, 55), color.new(i_h4DemCol, 78), color.new(#00CCFF, 35), 1, "4H", false, gZtL, gZbL, glowOnL, cArm)
    if i_show1h
        fDraw(h1St, h1Sb, h1Sx, h1Sf, h1Sa, h1Sbx, color.new(i_h1SupCol, 60), color.new(i_h1SupCol, 80), color.new(#FF6699, 40), 1, "1H", true,  gZtS, gZbS, glowOnS, cArm)
        fDraw(h1Dt, h1Db, h1Dx, h1Df, h1Da, h1Dbx, color.new(i_h1DemCol, 60), color.new(i_h1DemCol, 80), color.new(#00FFAA, 40), 1, "1H", false, gZtL, gZbL, glowOnL, cArm)
    if i_showCur
        fDraw(cSt, cSb, cSx, cSf, cSa, cSbx, color.new(i_curSupCol, 65), color.new(i_curSupCol, 82), color.new(color.white, 50), 1, "LTF", true,  na, na, false, cArm)
        fDraw(cDt, cDb, cDx, cDf, cDa, cDbx, color.new(i_curDemCol, 65), color.new(i_curDemCol, 82), color.new(color.white, 50), 1, "LTF", false, na, na, false, cArm)

// ============================================================================
// ——— VISUALS ———
// ============================================================================
barcolor(i_barCol ? (inLong ? color.new(cBull, 25) : inShort ? color.new(cBear, 25) : armedL ? color.new(cArm, 60) : armedS ? color.new(cArm, 60) : na) : na)

// ARM markers
if armNowL
    label.new(bar_index, low - atr14 * 1.2, "🎯 ARMED LONG\n" + demTF + (demFresh?" FRESH":"") + "\nwin: " + str.tostring(eff_armW) + "b", color=color.new(cArm, 10), textcolor=color.black, style=label.style_label_up, size=size.small)
if armNowS
    label.new(bar_index, high + atr14 * 1.2, "🎯 ARMED SHORT\n" + supTF + (supFresh?" FRESH":"") + "\nwin: " + str.tostring(eff_armW) + "b", color=color.new(cArm, 10), textcolor=color.black, style=label.style_label_down, size=size.small)

// EXPIRE markers
if expireL
    string reasonL = expireL_window ? "TIMEOUT" : expireL_bos ? "BOS" : expireL_runaway ? "RAN AWAY" : "FLIP"
    label.new(bar_index, low - atr14 * 0.8, "⌛ " + reasonL, color=color.new(color.gray, 30), textcolor=color.white, style=label.style_label_up, size=size.tiny)
if expireS
    string reasonS = expireS_window ? "TIMEOUT" : expireS_bos ? "BOS" : expireS_runaway ? "RAN AWAY" : "FLIP"
    label.new(bar_index, high + atr14 * 0.8, "⌛ " + reasonS, color=color.new(color.gray, 30), textcolor=color.white, style=label.style_label_down, size=size.tiny)

// FIRE markers
if goLong
    string stk = demStr > 1 ? " [" + str.tostring(demStr) + "x]" : ""
    string fr  = demFresh ? " FRESH" : ""
    label.new(bar_index, low - atr14 * 1.5, "🟢 BUY [" + str.tostring(cfL) + "/5] " + demTF + fr + stk, color=color.new(cBull, 0), textcolor=color.black, style=label.style_label_up, size=size.normal)

if goShort
    string stk2 = supStr > 1 ? " [" + str.tostring(supStr) + "x]" : ""
    string fr2  = supFresh ? " FRESH" : ""
    label.new(bar_index, high + atr14 * 1.5, "🔴 SELL [" + str.tostring(cfS) + "/5] " + supTF + fr2 + stk2, color=color.new(cBear, 0), textcolor=color.white, style=label.style_label_down, size=size.normal)

// V21.3: Veto-blocked signal markers (visualize what veto saved you from)
if vetoBlockedL
    label.new(bar_index, low  - atr14 * 1.2, "🚫 BLOCKED\nveto active", color=color.new(#666666, 30), textcolor=color.new(color.white, 0), style=label.style_label_up,   size=size.tiny)
if vetoBlockedS
    label.new(bar_index, high + atr14 * 1.2, "🚫 BLOCKED\nveto active", color=color.new(#666666, 30), textcolor=color.new(color.white, 0), style=label.style_label_down, size=size.tiny)

if i_showRegime and i_aiOn and barstate.islast
    string regTxt = "AI: " + regStr + "  PROFILE: " + i_winMode + "  WF★: " + wfBest + (wfReady ? " ✓" : " ?")
    label.new(bar_index + 2, high * 1.002, regTxt, color=color.new(regCol, 15), textcolor=color.white, style=label.style_label_left, size=size.small)

var line lT1 = na
var line lT2 = na
var line lT3 = na
var line lSL = na
var line lEP = na
// V21.5: ALWAYS plot TP1/TP2/TP3 — even in Exit@TP1 mode (TP2/TP3 shown as informational dashed lines)
// User saw only "TP" before; now sees the full TP ladder at the moment of entry, every time.
if goLong or goShort
    line.delete(lT1)
    line.delete(lT2)
    line.delete(lT3)
    line.delete(lSL)
    line.delete(lEP)
    lEP := line.new(bar_index, close, bar_index + 1, close, color=color.new(#42a5f5, 20), width=1, style=line.style_dashed, extend=extend.right)
    bool drawAllTPs = i_alwaysShowAllTPs or not pExitTP1
    if not na(tp1)
        lT1 := line.new(bar_index, tp1, bar_index + 1, tp1, color=color.new(cTP, 0), width=2, style=line.style_solid, extend=extend.right)
    if drawAllTPs
        if not na(tp2)
            // In Exit@TP1 mode, TP2 is informational — dashed instead of dotted to differentiate
            lT2 := line.new(bar_index, tp2, bar_index + 1, tp2, color=color.new(cTP, 25), width=1, style=(pExitTP1 ? line.style_dashed : line.style_dotted), extend=extend.right)
        if not na(tp3)
            lT3 := line.new(bar_index, tp3, bar_index + 1, tp3, color=color.new(cTP, 45), width=1, style=(pExitTP1 ? line.style_dashed : line.style_dotted), extend=extend.right)
    if not na(stopPx)
        lSL := line.new(bar_index, stopPx, bar_index + 1, stopPx, color=color.new(cBear, 10), width=2, style=line.style_dashed, extend=extend.right)

// V21.5: distinct labels at entry moment so all three TPs are immediately visible.
// goLong/goShort guard ensures we only draw entry labels at entry, not every bar.
if (goLong or goShort) and not na(tp1)
    label.new(bar_index, tp1, "TP1", color=color.new(cTP, 0),  textcolor=color.black, style=label.style_label_left, size=size.small)
if (goLong or goShort) and (i_alwaysShowAllTPs or not pExitTP1) and not na(tp2)
    label.new(bar_index, tp2, "TP2", color=color.new(cTP, 20), textcolor=color.black, style=label.style_label_left, size=size.tiny)
if (goLong or goShort) and (i_alwaysShowAllTPs or not pExitTP1) and not na(tp3)
    label.new(bar_index, tp3, "TP3", color=color.new(cTP, 40), textcolor=color.black, style=label.style_label_left, size=size.tiny)

// V21.5: Hit labels (when TP is actually reached) — preserved from V21.4, retitled TP1 for clarity
if aH1 and not na(tp1)
    label.new(bar_index, tp1, "TP1 ✅", color=color.new(cTP, 5),  textcolor=color.black, style=label.style_label_down, size=size.tiny)
if aH2 and not na(tp2) and not pExitTP1
    label.new(bar_index, tp2, "TP2 ✅", color=color.new(cTP, 20), textcolor=color.black, style=label.style_label_down, size=size.tiny)
if aH3 and not na(tp3) and not pExitTP1
    label.new(bar_index, tp3, "TP3 ✅", color=color.new(cTP, 40), textcolor=color.black, style=label.style_label_down, size=size.tiny)

if exL or exS
    label.new(bar_index, close, "EMA EXIT", color=color.new(#ffd600, 5), textcolor=color.black, style=exL ? label.style_label_down : label.style_label_up, size=size.tiny)

// V21.7: ribbon visualization uses ADAPTIVE EMAs so what you see on chart matches what the engine uses.
rp1 = plot(i_ribbon ? eEff9  : na, "EMA fast (adaptive)",   color=color.new(cE1, 60), linewidth=1)
rp2 = plot(i_ribbon ? eEff13 : na, "EMA mid-fast (adaptive)", color=color.new(cE1, 45), linewidth=1)
rp3 = plot(i_ribbon ? eEff21 : na, "EMA mid (adaptive)",     color=color.new(cE1, 50), linewidth=2)
rp4 = plot(i_ribbon ? e55    : na, "EMA 55 (anchor)",        color=color.new(cE2, 55), linewidth=1)
rp5 = plot(i_ribbon ? eEff89 : na, "EMA slow (adaptive)",    color=color.new(cE2, 70), linewidth=1)
fill(rp1, rp5, color=eEff9 > eEff89 ? color.new(cE1, 92) : color.new(cBear, 92))

plot(stDr ==  1 ? stUL : na, "ST Bull", color=color.new(cBull, 20), linewidth=2, style=plot.style_linebr)
plot(stDr == -1 ? stDL : na, "ST Bear", color=color.new(cBear, 20), linewidth=2, style=plot.style_linebr)

var label eLbl = na
if barstate.islast and (inLong or inShort) and not na(entPx)
    label.delete(eLbl)
    eLbl := label.new(bar_index + 1, entPx, "E", color=color.new(#1565c0, 20), textcolor=color.new(#90caf9, 0), style=label.style_label_left, size=size.small)

// ============================================================================
// ——— DASHBOARD ———
// ============================================================================
var table dash = na
if i_dash and barstate.islast
    string dp = i_dPos == "Bottom Left" ? position.bottom_left : i_dPos == "Top Right" ? position.top_right : i_dPos == "Top Left" ? position.top_left : position.bottom_right
    table.delete(dash)
    dash := table.new(dp, 2, 63, bgcolor=color.new(#060714, 5), border_color=color.new(#1a1a3a, 0), border_width=1, frame_color=color.new(#12122a, 0), frame_width=2)

    // ARM/TRIGGER status row (TOP — most important)
    string dArmStat = (inLong or inShort) ? "🔥 IN TRADE" : armedL ? "🎯 ARMED LONG  " + str.tostring(armRemL) + "b" : armedS ? "🎯 ARMED SHORT  " + str.tostring(armRemS) + "b" : "👀 WATCHING"
    color  dArmCol  = (inLong or inShort) ? color.lime : armedL ? color.new(cArm, 5) : armedS ? color.new(cArm, 5) : color.new(color.silver, 30)

    string dStat  = (inLong or inShort) ? "IN TRADE" : "WATCHING"
    color  dStatC = (inLong or inShort) ? color.lime  : color.new(color.silver, 30)
    string dDir   = inLong ? "LONG" : inShort ? "SHORT" : "FLAT"
    color  dDirC  = inLong ? color.lime : inShort ? color.red : color.gray
    string dHTFv  = htfBC > htfSC ? "BULL " + str.tostring(htfBC) + "/4" : "BEAR " + str.tostring(htfSC) + "/4"
    color  dHTFC  = htfBC >= pHtfReq ? color.lime : htfSC >= pHtfReq ? color.red : color.orange
    string dBias  = "D:" + (dBull?"B":dBear?"S":"N") + " 4H:" + (h4Bull?"B":h4Bear?"S":"N") + " 1H:" + (h1Bull?"B":h1Bear?"S":"N") + " 15:" + (m15Bull?"B":m15Bear?"S":"N")
    string dZone  = inHTFDem ? "DEM " + demTF + (demFresh?" FRESH":"") + (demStr>1?" x"+str.tostring(demStr):"") : inHTFSup ? "SUP " + supTF + (supFresh?" FRESH":"") + (supStr>1?" x"+str.tostring(supStr):"") : "NO ZONE"
    color  dZoneC = inHTFDem ? color.lime : inHTFSup ? color.red : color.gray
    int    dCFv   = inLong ? entCF : inShort ? entCF : inHTFDem ? cfL : inHTFSup ? cfS : 0
    color  dCFC   = dCFv >= 5 ? color.lime : dCFv >= 4 ? color.new(#00e676, 20) : dCFv >= 3 ? color.yellow : color.gray
    color  dWRC   = wr >= 80.0 ? color.lime : wr >= 60.0 ? color.new(#00e676, 20) : wr >= 40.0 ? color.orange : color.red
    string dPnl   = (cumPL >= 0.0 ? "+" : "") + str.tostring(math.round(cumPL * 10.0) / 10.0) + "%"
    color  dPnlC  = cumPL >= 0.0 ? color.lime : color.red
    float  dUSD   = 1000.0 * cumPL / 100.0
    string dUSDv  = (dUSD >= 0.0 ? "+$" : "-$") + str.tostring(math.round(math.abs(dUSD) * 10.0) / 10.0)
    color  dUSDC  = dUSD >= 0.0 ? color.lime : color.red
    color  dShpC  = shrp >= 1.0 ? color.lime : shrp >= 0.0 ? color.orange : color.red
    string dStrk  = streak == 0 ? "—" : streak > 0 ? "W" + str.tostring(streak) : "L" + str.tostring(math.abs(streak))
    color  dStrkC = streak >= 3 ? color.lime : streak > 0 ? color.new(#00e676, 30) : streak == 0 ? color.gray : streak >= -2 ? color.orange : color.red

    string dWFv = wfBest + (wfReady ? "" : " (warming)")
    color  dWFc = wfBest == "Sniper" ? color.aqua : wfBest == "Balanced" ? color.yellow : color.fuchsia

    table.cell(dash, 0,  0, "FAV V21.7 🧬💰🚀🧭🔬",                          text_color=color.new(cBull,0), bgcolor=color.new(#0d0d2b,0), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1,  0, dArmStat,                                        text_color=dArmCol,            bgcolor=color.new(#0d0d2b,0), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 0,  1, "STATE",        text_color=color.gray, text_size=size.small)
    table.cell(dash, 1,  1, dStat,          text_color=dStatC,      text_size=size.small)
    table.cell(dash, 0,  2, "ARM WIN/CONF", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1,  2, str.tostring(pArmWin) + "b / " + str.tostring(pArmConf) + "/5" + (pArmRev ? " +Rev" : ""), text_color=cArm, text_size=size.tiny)
    table.cell(dash, 0,  3, "PROFILE",      text_color=color.gray, text_size=size.small)
    table.cell(dash, 1,  3, i_winMode,      text_color=color.aqua,  text_size=size.tiny)
    table.cell(dash, 0,  4, "WF★ BEST",     text_color=color.gray, text_size=size.small)
    table.cell(dash, 1,  4, dWFv,           text_color=dWFc,        text_size=size.tiny)
    table.cell(dash, 0,  5, "REGIME",       text_color=color.gray, text_size=size.small)
    table.cell(dash, 1,  5, regStr,         text_color=regCol,      text_size=size.small)
    table.cell(dash, 0,  6, "TRADE",        text_color=color.gray, text_size=size.small)
    table.cell(dash, 1,  6, dDir,           text_color=dDirC,       text_size=size.small)
    table.cell(dash, 0,  7, "STREAK",       text_color=color.gray, text_size=size.small)
    table.cell(dash, 1,  7, dStrk,          text_color=dStrkC,      text_size=size.small)
    table.cell(dash, 0,  8, "HTF GATE",     text_color=color.gray, text_size=size.small)
    table.cell(dash, 1,  8, dHTFv,          text_color=dHTFC,       text_size=size.small)
    table.cell(dash, 0,  9, "TF BIAS",      text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1,  9, dBias,          text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 10, "HTF ZONE",     text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 10, dZone,          text_color=dZoneC,      text_size=size.small)
    table.cell(dash, 0, 11, "CONF REQ",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 11, str.tostring(pConf) + "/5",                          text_color=dCFC,        text_size=size.small)
    table.cell(dash, 0, 12, "CONFLUENCE",   text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 12, str.tostring(dCFv) + "/5",                           text_color=dCFC,        text_size=size.small)
    table.cell(dash, 0, 13, "P1 CANDLE",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 13, inHTFDem?(lP1?"✅":"❌"):inHTFSup?(sP1?"✅":"❌"):"—", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 14, "P2 RSI/STOCH", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 14, inHTFDem?(lP2?"✅":"❌"):inHTFSup?(sP2?"✅":"❌"):"—", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 15, "P3 VOLUME",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 15, inHTFDem?(lP3?"✅":"❌"):inHTFSup?(sP3?"✅":"❌"):"—", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 16, "P4 EMA STR",   text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 16, inHTFDem?(lP4?"✅":"❌"):inHTFSup?(sP4?"✅":"❌"):"—", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 17, "P5 HTF/ST",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 17, inHTFDem?(lP5?"✅":"❌"):inHTFSup?(sP5?"✅":"❌"):"—", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 18, "REVERSAL",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 18, inHTFDem?(revLong?"✅":"❌"):inHTFSup?(revShort?"✅":"❌"):"—", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 19, "OSC EXTREME",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 19, inHTFDem?(oscLong?"✅":"❌"):inHTFSup?(oscShort?"✅":"❌"):"—", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 20, "WIN RATE",     text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 20, str.tostring(math.round(wr*10.0)/10.0) + "%",       text_color=dWRC,    text_size=size.small)
    table.cell(dash, 0, 21, "ROLL WR(50)",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 21, str.tostring(math.round(rollWR*10.0)/10.0) + "%",   text_color=dWRC,    text_size=size.small)
    table.cell(dash, 0, 22, "TOTAL TRADES", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 22, str.tostring(tTot),                        text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 23, "BEST/WORST",   text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 23, "W"+str.tostring(bestStreak)+" / L"+str.tostring(math.abs(worstStreak)), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 24, "PROFIT FACT",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 24, str.tostring(math.round(pf*100.0)/100.0),  text_color=pf>=2.0?color.lime:pf>=1.0?color.orange:color.red, text_size=size.tiny)
    table.cell(dash, 0, 25, "LEVERAGE",     text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 25, str.tostring(i_lev) + "x",                 text_color=color.yellow, text_size=size.small)
    table.cell(dash, 0, 26, "TOTAL P&L",    text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 26, dPnl,           text_color=dPnlC,           text_size=size.small)
    table.cell(dash, 0, 27, "PROFIT $1K",   text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 27, dUSDv,          text_color=dUSDC,           text_size=size.small)
    table.cell(dash, 0, 28, "SHARPE (50)",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 28, str.tostring(math.round(shrp*100.0)/100.0), text_color=dShpC, text_size=size.small)
    table.cell(dash, 0, 29, "WF SNIPER",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 29, str.tostring(vTot_S) + "T " + str.tostring(math.round(vWR_S)) + "% Sh:" + str.tostring(math.round(vSh_S*100.0)/100.0), text_color=color.aqua, text_size=size.tiny)
    table.cell(dash, 0, 30, "WF BALANCED",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 30, str.tostring(vTot_B) + "T " + str.tostring(math.round(vWR_B)) + "% Sh:" + str.tostring(math.round(vSh_B*100.0)/100.0), text_color=color.yellow, text_size=size.tiny)
    table.cell(dash, 0, 31, "WF AGGRO",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 31, str.tostring(vTot_A) + "T " + str.tostring(math.round(vWR_A)) + "% Sh:" + str.tostring(math.round(vSh_A*100.0)/100.0), text_color=color.fuchsia, text_size=size.tiny)
    table.cell(dash, 0, 32, "TP METHOD",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 32, i_tpMethod + " " + (pExitTP1?"(Exit@TP1)":"(Trail)"), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 33, "TP1 / SL",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 33, (i_tpMethod=="Fixed %"?str.tostring(math.round(eff_tp1*100.0)/100.0)+"%":str.tostring(math.round(eff_tp1A*100.0)/100.0)+"x") + " / " + (not na(stopPx)?str.tostring(math.round(stopPx*100.0)/100.0):"--"), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 34, "ADX",          text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 34, str.tostring(math.round(adxVal*10.0)/10.0) + (adxVal >= float(i_adxMin) ? " TR" : " WK"), text_color=adxVal>=float(i_adxMin)?color.lime:color.orange, text_size=size.tiny)
    table.cell(dash, 0, 35, "RSI",          text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 35, str.tostring(math.round(rsiSm*10.0)/10.0), text_color=rsiSm>70.0?color.red:rsiSm<30.0?color.lime:color.white, text_size=size.tiny)
    int    dDZ    = array.size(dDt)  + array.size(dSt)
    int    d4Z    = array.size(h4Dt) + array.size(h4St)
    int    d1Z    = array.size(h1Dt) + array.size(h1St)
    table.cell(dash, 0, 36, "HTF ZONES",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 36, "D:"+str.tostring(dDZ)+" 4H:"+str.tostring(d4Z)+" 1H:"+str.tostring(d1Z), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 37, "CHART TF",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 37, timeframe.period, text_color=color.white, text_size=size.tiny)

    // ——— 🤖 AI Adaptive Tuner status (rows 38–40)
    string tunerStat = not i_tunerOn ? "OFF" : tunerFrozenNow ? "❄️ FROZEN (winning)" : tTot < i_tunerMinT ? "WAITING (" + str.tostring(tTot) + "/" + str.tostring(i_tunerMinT) + ")" : "🤖 ACTIVE"
    color  tunerCol  = not i_tunerOn ? color.gray : tunerFrozenNow ? color.aqua : tTot < i_tunerMinT ? color.yellow : color.lime
    int    tunerNext = i_tunerOn ? math.max(0, i_tunerBars - (bar_index - tunerLastBar)) : 0
    table.cell(dash, 0, 38, "🤖 TUNER",     text_color=color.gray,  text_size=size.tiny)
    table.cell(dash, 1, 38, tunerStat + (i_tunerOn and not tunerFrozenNow and tTot >= i_tunerMinT ? "  next:" + str.tostring(tunerNext) + "b" : ""), text_color=tunerCol, text_size=size.tiny)
    table.cell(dash, 0, 39, "TUNED #",      text_color=color.gray, text_size=size.tiny)
    color tDirCol = tunerDir > 0 ? color.lime : tunerDir < 0 ? color.red : color.silver
    table.cell(dash, 1, 39, str.tostring(tunerCount) + "  " + (tunerDir>0?"↑loose":tunerDir<0?"↓tight":"—hold") + "  WR@last:" + str.tostring(math.round(tunerLastWR*10.0)/10.0) + "%", text_color=tDirCol, text_size=size.tiny)
    table.cell(dash, 0, 40, "EFF TP/SL/CF", text_color=color.gray, text_size=size.tiny)
    string effSummary = (i_tpMethod=="Fixed %"?str.tostring(math.round(eff_tp1*100.0)/100.0)+"%":str.tostring(math.round(eff_tp1A*100.0)/100.0)+"x") + " / " + str.tostring(math.round(eff_slA*100.0)/100.0) + "x / " + str.tostring(eff_conf) + "·" + str.tostring(eff_armC) + "  ARM:" + str.tostring(eff_armW) + "b"
    table.cell(dash, 1, 40, effSummary, text_color=color.new(color.aqua, 0), text_size=size.tiny)

    // ——— 🧬 V21.3 DNA + VETO ROWS (41-44)
    string dnaClassDisp = i_dnaOn ? (dna_emojiFinal + "  " + dna_classFinal + (i_dnaForce != "Auto" ? "  [FORCED]" : "")) : "— OFF—"
    color  dnaClassCol  = not i_dnaOn ? color.gray : dna_hostile ? color.red : dna_isTrend ? color.lime : dna_isMom ? color.orange : dna_isRange ? color.aqua : dna_isSleep ? color.silver : color.yellow
    table.cell(dash, 0, 41, "🧬 DNA CLASS",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 41, dnaClassDisp,    text_color=dnaClassCol, text_size=size.small)

    string dnaScoreDisp = "T:" + str.tostring(math.round(dna_trendScore)) + "  C:" + str.tostring(math.round(dna_chopScore)) + "  V:" + str.tostring(math.round(dna_volScore)) + "  M:" + str.tostring(math.round(dna_momScore))
    table.cell(dash, 0, 42, "DNA SCORES",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 42, dnaScoreDisp,    text_color=color.white, text_size=size.tiny)

    string calDisp = i_dnaOn and dna_active ? ("tp1:" + str.tostring(math.round(cal_tp1*100.0)/100.0) + "% sl:" + str.tostring(math.round(cal_slA*100.0)/100.0) + "x cf:" + str.tostring(cal_conf) + " arm:" + str.tostring(cal_armW) + "b") : "— fallback profile —"
    color  calCol  = i_dnaOn and dna_active ? color.new(#ff66ff, 0) : color.gray
    table.cell(dash, 0, 43, "🎯 CALIBRATION", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 43, calDisp,         text_color=calCol, text_size=size.tiny)

    string vetoDisp = i_vetoBypass ? "⚠️ BYPASSED" : not i_vetoOn ? "— OFF —" : vetoActive ? ("🚫 BLOCKING (WR " + str.tostring(math.round(rollWR*10.0)/10.0) + "%)") : (vetoLatched[1] and not vetoLatched ? "✅ RECENTLY CLEARED" : (tTot < i_vetoMinT ? "⏳ WAIT (" + str.tostring(tTot) + "/" + str.tostring(i_vetoMinT) + ")" : "✅ STANDBY"))
    color  vetoCol  = i_vetoBypass ? color.orange : not i_vetoOn ? color.gray : vetoActive ? color.red : tTot < i_vetoMinT ? color.yellow : color.lime
    table.cell(dash, 0, 44, "💀 VETO",        text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 44, vetoDisp,        text_color=vetoCol, text_size=size.tiny)

    // ——— 💰 V21.4 PF GUARDIAN + ATR + DEEP STATS ROWS (45-48)
    string pfGuardDisp = not i_pfGuardOn ? "— OFF —" : pfGuardActiveNow ? "💰 ACTIVE (widening TP)" : pf >= 1.5 ? "✅ PF healthy" : pf >= 1.0 ? "🟡 PF ok" : "🔴 PF " + str.tostring(math.round(pf*100.0)/100.0)
    color  pfGuardCol  = not i_pfGuardOn ? color.gray : pfGuardActiveNow ? color.new(#ff66ff,0) : pf >= 1.5 ? color.lime : pf >= 1.0 ? color.yellow : color.red
    table.cell(dash, 0, 45, "💰 PF GUARD",   text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 45, pfGuardDisp,    text_color=pfGuardCol, text_size=size.tiny)

    string atrDisp = i_atrAutoOn ? ("ATR " + str.tostring(math.round(atrPct*100.0)/100.0) + "% → TP " + str.tostring(math.round(math.max(i_atrFloor, atrPct*i_atrTPmult)*100.0)/100.0) + "%") : "— OFF —"
    color  atrCol  = i_atrAutoOn ? color.aqua : color.gray
    table.cell(dash, 0, 46, "📏 ATR-SCALE",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 46, atrDisp,        text_color=atrCol,    text_size=size.tiny)

    string rrDisp = "TP1: " + str.tostring(math.round(eff_tp1*100.0)/100.0) + "%  SL·%: " + str.tostring(math.round(eff_slA*atrPct*100.0)/100.0) + "%  RR: " + (eff_slA*atrPct > 0.0 ? str.tostring(math.round((eff_tp1/(eff_slA*atrPct))*100.0)/100.0) : "∞")
    color  rrCol  = (eff_slA*atrPct > 0.0 and eff_tp1 / (eff_slA*atrPct) >= i_pfMinRR) ? color.lime : color.orange
    table.cell(dash, 0, 47, "⚖️ LIVE RR",   text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 47, rrDisp,         text_color=rrCol,     text_size=size.tiny)

    string statsDisp = "L:" + str.tostring(nRoll) + "T " + str.tostring(math.round(rollWR*10.0)/10.0) + "% PF" + str.tostring(math.round(pf*100.0)/100.0) + "  S:" + str.tostring(nRollShort) + "T " + str.tostring(math.round(rollWR_S*10.0)/10.0) + "%" + (shortBreak ? " ⚠️BREAK" : "")
    color  statsCol  = shortBreak ? color.orange : (rollWR_S >= rollWR ? color.lime : color.aqua)
    table.cell(dash, 0, 48, "📊 DEEP STATS", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 48, statsDisp,      text_color=statsCol,  text_size=size.tiny)

    // V21.5: Multi-TP visibility status row
    string tpVisDisp = i_alwaysShowAllTPs ? "✅ TP1+TP2+TP3 ALL plotted" + (pExitTP1 ? " (TP2/3 = info dashed)" : "") : "⚠️ legacy single-TP"
    color  tpVisCol  = i_alwaysShowAllTPs ? color.lime : color.orange
    table.cell(dash, 0, 49, "🎯 TP LADDER",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 49, tpVisDisp,      text_color=tpVisCol,  text_size=size.tiny)

    // V21.5: Momentum exemption status row
    string momDisp = not i_momentumExempt ? "— OFF —" : (momLateActiveL or momLateActiveS) ? "🚀 LATE-FIRE ARMED " + str.tostring(math.max(0, i_momLateBars - math.min(bar_index - momExemptBarL, bar_index - momExemptBarS))) + "b" : (momStrongL or momStrongS) ? "🚀 MOMENTUM STRONG" : "✅ standby"
    color  momCol  = not i_momentumExempt ? color.gray : (momLateActiveL or momLateActiveS) ? color.new(#ff9100,0) : (momStrongL or momStrongS) ? color.aqua : color.silver
    table.cell(dash, 0, 50, "🚀 MOM EXEMPT", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 50, momDisp,        text_color=momCol,    text_size=size.tiny)

    // V21.5: Veto recovery status row
    string vetoRecDisp = i_vetoForceOff ? "🔓 FORCE OFF" : not i_vetoOn ? "— OFF —" : vetoLatched ? ("🔒 latched | recover ≥ " + str.tostring(math.round(vetoRecoverEff*10.0)/10.0) + "% (now " + str.tostring(math.round(rollWR*10.0)/10.0) + "%)") : "✅ standby | hyst +" + str.tostring(math.round(i_vetoHyst*10.0)/10.0) + "pts"
    color  vetoRecCol  = i_vetoForceOff ? color.new(#ff9100,0) : vetoLatched ? color.red : color.lime
    table.cell(dash, 0, 51, "🛡 VETO RECOV", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 51, vetoRecDisp,    text_color=vetoRecCol, text_size=size.tiny)

    // V21.6: 🧭 Zone polarity status — distRatio + L/S verdict
    string polDisp = not i_zonePolarityLock ? "— OFF —" : (na(distRatio) ? "⏳ no zone" : ("📏 " + str.tostring(math.round(distRatio*100)/100) + " | L:" + (polarityOK_L ? "✅" : "❌") + " S:" + (polarityOK_S ? "✅" : "❌")))
    color  polCol  = not i_zonePolarityLock ? color.gray : (na(distRatio) ? color.silver : (polarityOK_L or polarityOK_S) ? color.lime : color.red)
    table.cell(dash, 0, 52, "🧭 ZONE POL",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 52, polDisp,        text_color=polCol,    text_size=size.tiny)

    // V21.6: 🔁 Re-arm tap counter + bars since last tap
    int reArmBarsL = lastReArmBarL > 0 ? bar_index - lastReArmBarL : -1
    int reArmBarsS = lastReArmBarS > 0 ? bar_index - lastReArmBarS : -1
    string reArmDisp = not i_reArmOn ? "— OFF —" : ("L:" + str.tostring(zoneTapCntL) + "/" + str.tostring(i_reArmMaxPerZone) + (reArmBarsL >= 0 ? " (" + str.tostring(reArmBarsL) + "b)" : "") + "  S:" + str.tostring(zoneTapCntS) + "/" + str.tostring(i_reArmMaxPerZone) + (reArmBarsS >= 0 ? " (" + str.tostring(reArmBarsS) + "b)" : ""))
    color  reArmCol  = not i_reArmOn ? color.gray : (zoneTapCntL > 0 or zoneTapCntS > 0) ? color.aqua : color.silver
    table.cell(dash, 0, 53, "🔁 RE-ARM",    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 53, reArmDisp,      text_color=reArmCol,  text_size=size.tiny)

    // V21.6: 🪞 Reaction relax — which reaction form is active
    string reactDisp = not i_reactionRelax ? "— OFF —" : ("L:" + reactWhichL + "  S:" + reactWhichS)
    color  reactCol  = not i_reactionRelax ? color.gray : (reactRelaxL or reactRelaxS) ? color.new(#ff9100,0) : color.silver
    table.cell(dash, 0, 54, "🪞 REACTION",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 54, reactDisp,      text_color=reactCol,  text_size=size.tiny)

    // V21.6: 🚫 Wrong-side veto — rangePos + L/S eligibility
    string wsDisp = not i_wrongSideOn ? "— OFF —" : ("📌 " + (na(rangePos) ? "n/a" : str.tostring(math.round(rangePos*100)/100)) + " | L:" + (wrongSideOK_L ? "✅" : "🚫") + " S:" + (wrongSideOK_S ? "✅" : "🚫"))
    color  wsCol  = not i_wrongSideOn ? color.gray : (wrongSideOK_L or wrongSideOK_S) ? color.lime : color.red
    table.cell(dash, 0, 55, "🚫 WRONG-SIDE", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 55, wsDisp,         text_color=wsCol,     text_size=size.tiny)

    // V21.7: 🧪 Adaptive EMA preset
    string emaDisp = not (i_v7Master and i_adaptEmaOn) ? "— OFF —" : emaPreset
    color  emaCol  = not (i_v7Master and i_adaptEmaOn) ? color.gray : dna_isTrend ? color.lime : dna_isMom ? color.orange : dna_isRange ? color.aqua : dna_isChop ? color.red : dna_isSleep ? color.silver : color.yellow
    table.cell(dash, 0, 56, "🧪 ADAPTIVE EMA", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 56, emaDisp,        text_color=emaCol,    text_size=size.tiny)

    // V21.7: 🎚 CF Auto-Tune status
    string cfDispV7 = not (i_v7Master and i_cfAutoOn) ? "— OFF —" : ("floor:" + str.tostring(eff_conf) + "/5  #" + str.tostring(cfAutoCount) + " " + (cfAutoLastDelta>0 ? "↑" : cfAutoLastDelta<0 ? "↓" : "—"))
    color  cfColV7  = not (i_v7Master and i_cfAutoOn) ? color.gray : cfAutoLastDelta>0 ? color.red : cfAutoLastDelta<0 ? color.lime : color.silver
    table.cell(dash, 0, 57, "🎚 CF AUTO-TUNE",text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 57, cfDispV7,       text_color=cfColV7,   text_size=size.tiny)

    // V21.7: 🌡 Vol-Regime bucket + multiplier
    string volDispV7 = not (i_v7Master and i_volRegimeOn) ? "— OFF —" : (volRegBucket + " ×" + str.tostring(math.round(volRegMult*100)/100))
    color  volColV7  = not (i_v7Master and i_volRegimeOn) ? color.gray : _atrPctV7 < 0.20 ? color.silver : _atrPctV7 < 0.50 ? color.aqua : _atrPctV7 < 1.00 ? color.yellow : color.orange
    table.cell(dash, 0, 58, "🌡 VOL-REGIME", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 58, volDispV7,      text_color=volColV7,  text_size=size.tiny)

    // V21.7: 💀 SLEEPER suppression status
    string sleepDispV7 = not (i_v7Master and i_sleeperBlockOn) ? "— OFF —" : sleeperBlocked ? ("🔒 BLOCKED  PF " + str.tostring(math.round(pf*100)/100)) : (dna_isSleep ? ("💤 SLEEPER  PF " + str.tostring(math.round(pf*100)/100)) : "✅ standby")
    color  sleepColV7  = not (i_v7Master and i_sleeperBlockOn) ? color.gray : sleeperBlocked ? color.red : dna_isSleep ? color.orange : color.lime
    table.cell(dash, 0, 59, "💀 SLEEPER LOCK", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 59, sleepDispV7,    text_color=sleepColV7,text_size=size.tiny)

    // V21.7: 🎯 Realized-RR ratio + corrective
    string rrDispV7 = not (i_v7Master and i_realRRon) ? "— OFF —" : (tTot < i_realRRMinT ? ("warming " + str.tostring(tTot) + "/" + str.tostring(i_realRRMinT)) : ("W:" + str.tostring(math.round(avgWinPct*100)/100) + "% / L:" + str.tostring(math.round(avgLossPct*100)/100) + "%  R:" + str.tostring(math.round(realRRr*100)/100)))
    color  rrColV7  = not (i_v7Master and i_realRRon) ? color.gray : tTot < i_realRRMinT ? color.silver : realRRr < i_realRRwidenAt ? color.red : realRRr > i_realRRexpandAt ? color.lime : color.aqua
    table.cell(dash, 0, 60, "🎯 REAL-RR",   text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 60, rrDispV7,       text_color=rrColV7,   text_size=size.tiny)

    // V21.7: 🔬 Asset Memory snapshots
    string memDispV7 = not (i_v7Master and i_memOn) ? "— OFF —" : (memHas ? ("💾 snap#" + str.tostring(memSnaps) + " rev#" + str.tostring(memReverts) + "  TP1:" + str.tostring(math.round(memTp1*100)/100) + "%") : ("watching (need PF≥" + str.tostring(i_memSnapPF) + " + WR≥" + str.tostring(math.round(i_memSnapWR)) + "%)"))
    color  memColV7  = not (i_v7Master and i_memOn) ? color.gray : memHas ? color.lime : color.silver
    table.cell(dash, 0, 61, "🔬 ASSET MEM", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 61, memDispV7,      text_color=memColV7,  text_size=size.tiny)

// ============================================================================
// ——— ALERTS ———
// ============================================================================
alertcondition(armNowL,             "FAV ARMED LONG",    "🎯 ARMED LONG — HTF Demand tapped, watching for trigger")
alertcondition(armNowS,             "FAV ARMED SHORT",   "🎯 ARMED SHORT — HTF Supply tapped, watching for trigger")
alertcondition(expireL,             "FAV ARM EXPIRE L",  "⌛ Long ARM expired (timeout/BOS/runaway/flip)")
alertcondition(expireS,             "FAV ARM EXPIRE S",  "⌛ Short ARM expired (timeout/BOS/runaway/flip)")
alertcondition(goLong,              "FAV BUY",           "🟢 Favorable BUY — HTF Demand trigger fired")
alertcondition(goShort,             "FAV SELL",          "🔴 Favorable SELL — HTF Supply trigger fired")
alertcondition(aH1,                 "FAV TP1",           "TP1 Hit")
alertcondition(aH2,                 "FAV TP2",           "TP2 Hit")
alertcondition(aH3,                 "FAV TP3",           "TP3 Full Exit")
alertcondition(xL or xS,            "FAV EXIT",          "Trade Exit")
alertcondition(inHTFDem,            "FAV AT DEM",        "Price At HTF Demand Zone")
alertcondition(inHTFSup,            "FAV AT SUP",        "Price At HTF Supply Zone")
alertcondition(regime != regime[1], "FAV REGIME CHANGE", "AI Regime Changed")
alertcondition(tunerCount != tunerCount[1], "FAV TUNER ADJUSTED", "🤖 AI Adaptive Tuner mutated effective parameters")
alertcondition(tunerFrozenNow and not tunerFrozenNow[1], "FAV TUNER FROZEN", "❄️ AI Adaptive Tuner frozen — you're winning, don't fix it")

// V21.3 — DNA + VETO alerts
alertcondition(dna_classChanged,                                     "FAV DNA CLASS CHANGE", "🧬 Asset DNA reclassified — calibration baseline updated")
alertcondition(vetoActive and not vetoActive[1],                     "FAV ASSET VETO",       "💀 Asset Veto engaged — hostile DNA or rolling WR collapse, new entries blocked")
alertcondition(vetoCleared,                                          "FAV ASSET VETO CLEAR", "✅ Asset Veto cleared — conditions recovered, trading re-enabled")
alertcondition(vetoBlockedL or vetoBlockedS,                         "FAV VETO BLOCK",       "🚫 Trade signal suppressed by Asset Veto")

// V21.4 — PF Guardian + Short-term break alerts
alertcondition(pfGuardActiveNow and not pfGuardActiveNow[1],         "FAV PF GUARDIAN ON",   "💰 PF Guardian engaged — wins too small vs losses, widening TP and tightening SL")
alertcondition(not pfGuardActiveNow and pfGuardActiveNow[1],         "FAV PF GUARDIAN OFF",  "✅ PF Guardian disengaged — risk:reward back in line")
alertcondition(shortBreak and not shortBreak[1],                     "FAV SHORT-TERM BREAK", "⚠️ Short-term WR collapsed >15pts vs long-term — regime may be shifting")

// V21.5 — Momentum exemption + late-fire + veto recovery alerts
alertcondition((momStrongL and not momStrongL[1]) or (momStrongS and not momStrongS[1]), "FAV MOMENTUM STRONG", "🚀 Strong momentum detected (vol+ADX+trend) — ARM cancels exempted")
alertcondition((momLateActiveL and not momLateActiveL[1]) or (momLateActiveS and not momLateActiveS[1]), "FAV LATE-FIRE WINDOW", "🚀 Late-fire window active — trigger still allowed after momentum-exempt BOS/runaway")
alertcondition(vetoLatched[1] and not vetoLatched and (bar_index - vetoLastTradeBar) >= i_vetoIdleBars, "FAV VETO IDLE-CLEARED", "⏳✅ Veto auto-cleared after extended idle period — conditions may have shifted")

// V21.6 — 🧭 Zone polarity + 🔁 Re-arm + 🪞 Reaction relax + 🚫 Wrong-side veto
alertcondition((polarityOK_L and not polarityOK_L[1]) or (polarityOK_S and not polarityOK_S[1]), "FAV ZONE POLARITY",     "🧭 Zone polarity flipped favorable — price now aligned with HTF zone for armed direction")
alertcondition(armNowL_reArm or armNowS_reArm,                                                  "FAV ZONE RE-ARM",       "🔁 Same un-broken zone re-armed on fresh tap — multi-touch capture engaged")
alertcondition((reactRelaxL and armedL) or (reactRelaxS and armedS),                            "FAV REACTION CAPTURED", "🪞 Reaction relax captured (pin/engulf/body/ctx) inside armed window — trigger eligible")
alertcondition((not wrongSideOK_L and armGateL[1]) or (not wrongSideOK_S and armGateS[1]),      "FAV WRONG-SIDE BLOCK",  "🚫 Wrong-side veto blocked entry — price too close to opposite-polarity zone")

// V21.7 — 🧪 Adaptive EMA + 🎚 CF Auto-Tune + 🌡 Vol-Regime + 💀 SLEEPER + 🔬 Asset Memory
alertcondition(sleeperBlocked and not sleeperBlocked[1],         "FAV V7 SLEEPER BLOCK",  "💀 SLEEPER auto-suppress engaged — DNA hostile + PF<floor, entries blocked until reclassify or PF recovers")
alertcondition(cfAutoLastDelta != 0 and cfAutoLastDelta != cfAutoLastDelta[1], "FAV V7 CF AUTO-TUNE", "🎚 CF auto-tune mutated confluence floor — tightening on losers, loosening on winners")
alertcondition(volRegBucket != volRegBucket[1],                  "FAV V7 VOL-REGIME SHIFT","🌡 Volatility regime bucket changed — TP multiplier recalculated for new ATR regime")
alertcondition(memSnaps != memSnaps[1],                          "FAV V7 MEMORY SNAPSHOT", "🔬 Asset Memory snapshot taken — best calibration stored (PF≥target + WR≥target)")
alertcondition(memReverts != memReverts[1],                      "FAV V7 MEMORY REVERT",  "🔬 Asset Memory reverted to last known good calibration — performance regressed below revert threshold")
````
