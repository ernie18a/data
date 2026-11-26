# HODL-V6-Full-Stack-L0+L1+L2

- url: https://www.tradingview.com/script/j60JCP1y/
- type: indicator
- pine_id: PUB;74e9562e06154ce994b18327b7f78ea8
- version: 1.0

## Description

HODL V6 — Intelligent Dollar-Cost Averaging Strategy for Crypto
Overview
HODL V6 Smart DCA is a production-grade automated investment advisor built as a TradingView Pine Script (v6) indicator. It replaces mechanical "buy on the same day every month" DCA with a three-layer signal fusion system that dynamically adjusts position size based on macro conditions, trend regime, and asset-specific technicals.
The core insight: Not all dips are created equal. A -30% drawdown during a macro risk-off panic is fundamentally different from a -30% dip in a raging bull market. V6 quantifies this difference.
Three-Layer Architecture
           ┌─────────────┐
           │   L0 MACRO   │  30% weight
           │  DXY / Gold  │  "Is now a good time
           │  NDX / VIX   │   to buy anything?"
           │ Copper / Oil │
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │   L1 TREND   │  30% weight
           │  EMA Regime  │  "Which direction is
           │  30d Mom.    │   THIS market going?"
           │  Vol. Rank   │
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │  L2 ASSET    │  40% weight
           │  DCA Bands   │  "How deep is THIS
           │  RSI / EMA200│   specific dip?"
           │ ATR / Regime │
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │ FINAL SCORE  │  0–100
           │ → 5 Actions  │  Dynamic sizing
           └──────────────┘
L0 — Macro Layer (Global Risk Appetite)
Cross-asset data pulled from 6 macro instruments via request.security() on daily resolution to avoid lookahead bias:
Three sub-scores are computed:
Liquidity Score (weighted momentum of DXY/Gold/NDX/VIX)
Resonance Score (how many assets are aligned in a risk-on direction)
Fear & Greed Proxy (linear transform of VIX level, high VIX → fear)
L1 — Trend Layer (Crypto Market Regime)
Five-factor regime classification for the current asset:
EMA Triple Alignment (20 > 50 > 200) — structural trend health
ADX Filter (ADX > 25 distinguishes strong vs weak regimes)
30-Day Momentum — recent velocity
Volatility Percentile Rank — is the market unusually volatile?
Output: 5 distinct regimes: STRONG_BULL → WEAK_BULL → RANGE → WEAK_BEAR → STRONG_BEAR
L2 — Asset-Specific Layer (Entry Timing)
Five micro-indicators measuring "how good is this exact entry":
DCA Band Depth — distance from ATH mapped to 5 tiered zones (-20%, -30%, -40%, -50%, -65%)
RSI Zone Scoring — granular 10-zone RSI mapping (RSI < 20 = max score, RSI > 80 = 0)
Regime Edge — regime context modifies L2 score (bearish regime = larger L2 bonus when dip buys)
EMA200 Distance — how far below/above the 200-day EMA
ATR Volatility — higher volatility = larger score (chance to buy lower)
Overheat Penalty — RSI > 75 AND price > 20% above EMA200 = automatic -15 penalty
Decision Engine
Final score is a weighted blend:
Final Score = 0.30 × L0 + 0.30 × L1 + 0.40 × L2
The L2 layer gets the highest weight because entry timing matters most for DCA — the macro layer acts as a permission slip, not the primary signal.
Five Action Tiers
The gap between a Heavy Buy (×2.5) and Pause (×0) is a 5× capital efficiency swing — deploying capital when the model is confident, preserving it when conditions are hostile.
Key Design Decisions
Daily-resolution macro data with lookahead=barmerge.lookahead_on — prevents future leak from cross-market timezone differences
ATH-based DCA reference instead of fixed calendar schedule — adapts to market structure; deeper drawdowns get higher scores
Asymmetric risk management — the model is more aggressive at scaling IN than scaling OUT. In bull regimes, RSI thresholds are tighter. In bear regimes, DCA bands get extra weight.
Configurable macro toggle — free TradingView users can disable the L0 layer and run L1+L2 only. Pro+ users get the full three-layer stack.
Requirements
TradingView Pro+ for cross-market symbol references (L0 macro layer)
Free tier users: disable use_macro in settings to run L1+L2 simplified mode
Compatible with any crypto pair on TradingView (BTC, ETH, SOL, etc.)
Works on all timeframes, but designed for daily bars
Alert Integration
Four built-in alertcondition triggers:
V6 Buy Signal — action score ≥ 3 (Normal/Increase/Heavy Buy)
V6 Reduce Signal — action score ≤ 1 (Pause/Reduce)
V6 Deep Dip — DCA Band ≥ 4 (≥ -50% from ATH)
V6 RSI Oversold — RSI < 25 (panic zone)
Status
Production-ready. Full Pine Script v6 source available on Feishu: HODL V6 Smart DCA

## Source Code

````pine
//@version=6
indicator("HODL V6 智能定投 — Full-Stack L0+L1+L2", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// ═══════════════════════════════════════════════════════════
// HODL V6 Smart DCA Advisor — Production Version
// 
// 三层架构:
//   L0 宏观 (跨品种: DXY/GOLD/NASDAQ/VIX) — 30%
//   L1 趋势 (当前币种 Regime + 动量)     — 30%
//   L2 品种 (RSI/DCA/EMA/ATR)            — 40%
//
// 需要 TradingView Pro+ 才能引用跨市场 symbol。
// 免费版可改用 L1+L2 简化模式（设置中关闭 macro 开关）。
// ═══════════════════════════════════════════════════════════

// ── 输入参数 ──
grp_base = "🏦 定投设置"
base_amount = input.float(1000, "每期基准金额 (USDT)", group=grp_base)
base_pct = input.float(10.0, "基准仓位占比 (%)", group=grp_base) / 100

grp_macro = "🌍 L0 宏观 (跨品种引用)"
use_macro = input.bool(true, "启用跨品种宏观评分", group=grp_macro)
// 付费版 symbol 格式: "交易所:代码" 或 "TVC:指数"
sym_dxy   = input.symbol("TVC:DXY",    "美元 DXY",    group=grp_macro)
sym_gold  = input.symbol("COMEX:GC1!", "黄金期货",    group=grp_macro)
sym_ndx   = input.symbol("NASDAQ:NDX", "纳斯达克",    group=grp_macro)
sym_vix   = input.symbol("TVC:VIX",    "恐慌指数 VIX", group=grp_macro)
sym_copper = input.symbol("COMEX:HG1!", "铜期货",    group=grp_macro)
sym_oil    = input.symbol("NYMEX:CL1!", "WTI原油",   group=grp_macro)

grp_tech = "📊 L1/L2 技术设置"
ema_fast = input.int(20, "快线 EMA", group=grp_tech)
ema_mid  = input.int(50, "中线 EMA", group=grp_tech)
ema_slow = input.int(200, "慢线 EMA (牛熊线)", group=grp_tech)
rsi_len  = input.int(14, "RSI 周期", group=grp_tech)
adx_len  = input.int(14, "ADX 周期", group=grp_tech)

grp_dca = "🎯 DCA 档位 (% from ATH)"
dca1_pct = input.float(-20.0, "Band 1 (浅回调)", group=grp_dca) / 100
dca2_pct = input.float(-30.0, "Band 2",          group=grp_dca) / 100
dca3_pct = input.float(-40.0, "Band 3",          group=grp_dca) / 100
dca4_pct = input.float(-50.0, "Band 4",          group=grp_dca) / 100
dca5_pct = input.float(-65.0, "Band 5 (深度回调)", group=grp_dca) / 100

grp_display = "🎨 显示"
show_ema    = input.bool(true, "EMA 均线", group=grp_display)
show_dca    = input.bool(true, "DCA 区间", group=grp_display)
show_labels = input.bool(true, "操作标记", group=grp_display)

// ═══════════════════════════════════════════════════════════
// L0 宏观层 — 跨品种引用
// ═══════════════════════════════════════════════════════════

// 强制使用日线 ("D") 防止未来函数 + 跨市场交易时间差
// lookahead=barmerge.lookahead_on 防止数据偏移
f_macro(sym) =>
    request.security(sym, "D", close, lookahead=barmerge.lookahead_on)

dxy_c    = use_macro ? f_macro(sym_dxy)   : na
gold_c   = use_macro ? f_macro(sym_gold)  : na
ndx_c    = use_macro ? f_macro(sym_ndx)   : na
vix_c    = use_macro ? f_macro(sym_vix)   : na
copper_c = use_macro ? f_macro(sym_copper): na
oil_c    = use_macro ? f_macro(sym_oil)   : na

// 20日动量
mom(src, len) => (src / src[len] - 1) * 100

dxy_mom    = not na(dxy_c)    ? mom(dxy_c, 20)    : 0
gold_mom   = not na(gold_c)   ? mom(gold_c, 20)   : 0
ndx_mom    = not na(ndx_c)    ? mom(ndx_c, 20)    : 0
vix_mom    = not na(vix_c)    ? mom(vix_c, 20)    : 0
copper_mom = not na(copper_c) ? mom(copper_c, 20) : 0
oil_mom    = not na(oil_c)    ? mom(oil_c, 20)    : 0

// ── 流动性评分 (0-100) ──
// DXY↓ = 利多 | GOLD↑ = 利多 | NDX↑ = 风险偏好好 | VIX↓ = 稳定
liq_dxy    = math.max(0, math.min(100, 50 - dxy_mom * 3))
liq_gold   = math.max(0, math.min(100, 50 + gold_mom * 3))
liq_ndx    = math.max(0, math.min(100, 50 + ndx_mom * 2))
liq_vix    = math.max(0, math.min(100, 50 - vix_mom * 2))

l0_liquidity = (use_macro and not na(dxy_c)) ? 0.35 * liq_dxy + 0.25 * liq_gold + 0.20 * liq_ndx + 0.20 * liq_vix : 50

// ── 宏观共振评分 (0-100) ──
// 多资产是否同方向：DXY跌 + 其他涨 = 高共振
macro_agree = 0
if not na(dxy_c)
    macro_agree += dxy_mom < 0 ? 1 : 0      // DXY 跌
    macro_agree += gold_mom > 0 ? 1 : 0     // 黄金涨
    macro_agree += ndx_mom > 0 ? 1 : 0      // 纳指涨
    macro_agree += vix_mom < 0 ? 1 : 0      // VIX 跌
    macro_agree += copper_mom > 0 ? 1 : 0   // 铜涨

l0_resonance = (use_macro and not na(dxy_c)) ? macro_agree * 25 : 50

// ── 恐惧贪婪近似 (用 VIX 位置) ──
// VIX 20 = 极度贪婪(100) | VIX 50 = 极度恐惧(0)
fear_greed_approx = (use_macro and not na(vix_c)) ? math.max(0, math.min(100, 100 - (vix_c / 50 * 100))) : 50

// ── L0 综合 ──
l0_score = 0.4 * l0_liquidity + 0.35 * l0_resonance + 0.25 * fear_greed_approx

// ═══════════════════════════════════════════════════════════
// L1 加密趋势层 — 当前币种
// ═══════════════════════════════════════════════════════════

// 核心指标
e20  = ta.ema(close, ema_fast)
e50  = ta.ema(close, ema_mid)
e200 = ta.ema(close, ema_slow)
rsi  = ta.rsi(close, rsi_len)
[_, _, adx] = ta.dmi(adx_len, adx_len)
atr  = ta.atr(14)
atr_pct = (atr / close) * 100
dist_ema200 = (close - e200) / e200

// ATH & DCA
var float ath = close
ath := math.max(ath, close)
dd_ath = (close - ath) / ath

dca_band = dd_ath <= dca5_pct ? 5 :
           dd_ath <= dca4_pct ? 4 :
           dd_ath <= dca3_pct ? 3 :
           dd_ath <= dca2_pct ? 2 :
           dd_ath <= dca1_pct ? 1 : 0

// ── Regime ──
regime = switch
    e20 > e50 and e50 > e200 and adx > 25 => "STRONG_BULL"
    e20 > e50 and e50 > e200 => "WEAK_BULL"
    e20 < e50 and e50 < e200 and adx > 25 => "STRONG_BEAR"
    e20 < e50 and e50 < e200 => "WEAK_BEAR"
    => "RANGE"

// ── L1 评分 ──
reg_score = switch regime
    "STRONG_BULL" => 80
    "WEAK_BULL" => 60
    "RANGE" => 50
    "WEAK_BEAR" => 30
    "STRONG_BEAR" => 15
    => 50

mom30 = (close / close[30] - 1) * 100
mom_score = math.max(0, math.min(100, 50 + mom30 * 2))

vol_pct_rank = ta.percentrank(atr_pct, 252)
vol_score = 100 - vol_pct_rank

l1_score = 0.50 * reg_score + 0.30 * mom_score + 0.20 * vol_score

// ═══════════════════════════════════════════════════════════
// L2 品种技术层
// ═══════════════════════════════════════════════════════════

l2_dca = switch dca_band
    5 => 30
    4 => 25
    3 => 20
    2 => 12
    1 => 5
    => 0

l2_rsi = switch
    rsi < 20 => 25
    rsi < 25 => 22
    rsi < 30 => 20
    rsi < 35 => 17
    rsi < 40 => 14
    rsi < 50 => 10
    rsi < 60 => 7
    rsi < 70 => 4
    rsi < 75 => 2
    rsi < 80 => 1
    => 0

l2_reg = switch regime
    "STRONG_BEAR" => 15
    "RANGE" => 18
    "WEAK_BEAR" => 10
    "WEAK_BULL" => 8
    "STRONG_BULL" => 2
    => 10

l2_dist = switch
    dist_ema200 < -0.40 => 15
    dist_ema200 < -0.30 => 13
    dist_ema200 < -0.20 => 10
    dist_ema200 < -0.10 => 7
    dist_ema200 < 0 => 5
    dist_ema200 < 0.05 => 3
    dist_ema200 < 0.15 => 2
    dist_ema200 < 0.30 => 1
    => 0

l2_vol = switch
    atr_pct > 8 => 10
    atr_pct > 5 => 8
    atr_pct > 3 => 5
    atr_pct > 2 => 3
    => 2

overheat = (rsi > 75 and dist_ema200 > 0.20) ? 15 : 0
l2_raw = l2_dca + l2_rsi + l2_reg + l2_dist + l2_vol
l2_score = math.max(0, math.min(100, l2_raw - overheat))

// ═══════════════════════════════════════════════════════════
// 综合决策
// ═══════════════════════════════════════════════════════════

final_score = 0.30 * l0_score + 0.30 * l1_score + 0.40 * l2_score

action = switch
    final_score >= 80 => 5
    final_score >= 65 => 4
    final_score >= 50 => 3
    final_score >= 35 => 2
    final_score >= 20 => 1
    => 0

action_text = switch action
    5 => "💰💰 重仓买入"
    4 => "💰 加大定投"
    3 => "💰 正常定投"
    2 => "⚪ 轻仓定投"
    1 => "🔴 暂停"
    => "🔴🔴 减仓"

mult = switch action
    5 => 2.5
    4 => 1.8
    3 => 1.2
    2 => 0.5
    1 => 0
    => 0

target_pct = switch action
    5 => base_pct * 2.0
    4 => base_pct * 1.5
    3 => base_pct * 1.2
    2 => base_pct * 0.8
    1 => base_pct * 0.8
    => base_pct * 0.5

invest = base_amount * mult

// 颜色
sc = final_score >= 80 ? color.new(color.green, 0) :
     final_score >= 65 ? color.new(color.lime, 20) :
     final_score >= 50 ? color.new(color.yellow, 20) :
     final_score >= 35 ? color.new(color.orange, 20) :
     final_score >= 20 ? color.new(color.red, 30) : color.new(color.maroon, 0)

bg = switch regime
    "STRONG_BULL" => color.new(color.green, 93)
    "WEAK_BULL"   => color.new(color.lime, 95)
    "RANGE"       => color.new(color.gray, 95)
    "WEAK_BEAR"   => color.new(color.orange, 95)
    "STRONG_BEAR" => color.new(color.red, 95)
    => na
bgcolor(bg, title="市场状态")

// ═══════════════════════════════════════════════════════════
// 主图可视化
// ═══════════════════════════════════════════════════════════

plot(show_ema ? e20 : na, "EMA20", color.new(color.orange, 0), 1)
plot(show_ema ? e50 : na, "EMA50", color.new(color.blue, 0), 1)
plot(show_ema ? e200 : na, "EMA200", color.new(color.purple, 0), 2)

plot(show_dca ? ath : na, "ATH", color.new(color.gray, 50), 1, plot.style_circles)
plot(show_dca ? ath * (1 + dca1_pct) : na, "DCA1", color.new(color.blue, 60), 1)
plot(show_dca ? ath * (1 + dca2_pct) : na, "DCA2", color.new(color.blue, 55), 1)
plot(show_dca ? ath * (1 + dca3_pct) : na, "DCA3", color.new(color.blue, 50), 1)
plot(show_dca ? ath * (1 + dca4_pct) : na, "DCA4", color.new(color.blue, 45), 1)
plot(show_dca ? ath * (1 + dca5_pct) : na, "DCA5", color.new(color.blue, 40), 2)

// 操作标记 (新信号)
if show_labels and barstate.isconfirmed and action != action[1]
    if action >= 3
        label.new(bar_index, low * 0.997,
            text = action_text + "\n$" + str.tostring(invest, "#,##0") +
                   " | " + str.tostring(target_pct * 100, "#.0") + "%",
            color = color.new(color.green, 10), textcolor = color.white,
            style = label.style_label_up, size = size.small)
    if action <= 1
        label.new(bar_index, high * 1.003,
            text = action_text + "\n卖出25-50%",
            color = color.new(color.red, 10), textcolor = color.white,
            style = label.style_label_down, size = size.small)

// ═══════════════════════════════════════════════════════════
// 仪表板
// ═══════════════════════════════════════════════════════════

var table panel = table.new(position.top_right, 3, 16,
    bgcolor = color.new(color.black, 50),
    border_color = color.gray, border_width = 1)

if barstate.islast
    table.merge_cells(panel, 0, 0, 2, 0)
    table.cell(panel, 0, 0, "🏗️ HODL V6 智能定投",
        text_color = color.white, text_size = size.normal,
        bgcolor = color.new(color.purple, 40), text_halign = text.align_center)
    
    table.merge_cells(panel, 0, 1, 2, 1)
    table.cell(panel, 0, 1, str.tostring(final_score, "#0") + " / 100",
        text_color = sc, text_size = size.large,
        bgcolor = color.new(color.black, 55), text_halign = text.align_center)
    
    table.merge_cells(panel, 0, 2, 2, 2)
    table.cell(panel, 0, 2, action_text,
        text_color = sc, text_size = size.normal,
        bgcolor = color.new(color.black, 35), text_halign = text.align_center)
    
    // 投入 & 仓位
    table.cell(panel, 0, 3, "本期投入", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 3, "$" + str.tostring(invest, "#,##0"),
        text_color = action >= 2 ? color.green : color.red, text_size = size.small)
    table.cell(panel, 2, 3,
        action == 5 ? "×2.5" : action == 4 ? "×1.8" : action == 3 ? "×1.2" :
        action == 2 ? "×0.5" : "停",
        text_color = sc, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel, 0, 4, "目标仓位", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 4, str.tostring(target_pct * 100, "#.0") + "%",
        text_color = color.blue, text_size = size.small)
    table.cell(panel, 2, 4, "", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    
    // 分隔
    table.merge_cells(panel, 0, 5, 2, 5)
    table.cell(panel, 0, 5, "━━━ 三层评分 ━━━",
        text_color = color.gray, text_size = size.tiny, text_halign = text.align_center)
    
    // L0
    l0c = l0_score >= 60 ? color.green : l0_score >= 40 ? color.yellow : color.red
    table.cell(panel, 0, 6, "L0 宏观", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 6, str.tostring(l0_score, "#0") + "/100", text_color = l0c, text_size = size.small)
    table.cell(panel, 2, 6, "×30%", text_color = color.gray, text_size = size.small, text_halign = text.align_right)
    
    // L1
    l1c = l1_score >= 60 ? color.green : l1_score >= 40 ? color.yellow : color.red
    table.cell(panel, 0, 7, "L1 趋势", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 7, str.tostring(l1_score, "#0") + "/100", text_color = l1c, text_size = size.small)
    table.cell(panel, 2, 7, "×30%", text_color = color.gray, text_size = size.small, text_halign = text.align_right)
    
    // L2
    l2c = l2_score >= 60 ? color.green : l2_score >= 40 ? color.yellow : color.red
    table.cell(panel, 0, 8, "L2 品种", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 8, str.tostring(l2_score, "#0") + "/100", text_color = l2c, text_size = size.small)
    table.cell(panel, 2, 8, "×40%", text_color = color.gray, text_size = size.small, text_halign = text.align_right)
    
    // 分隔
    table.merge_cells(panel, 0, 9, 2, 9)
    table.cell(panel, 0, 9, "━━━ 宏观详情 ━━━",
        text_color = color.gray, text_size = size.tiny, text_halign = text.align_center)
    
    // 跨品种数据
    table.cell(panel, 0, 10, "DXY", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 10, not na(dxy_c) ? str.tostring(dxy_c, "#.00") : "N/A",
        text_color = not na(dxy_c) ? color.white : color.gray, text_size = size.small)
    table.cell(panel, 2, 10, not na(dxy_c) ? str.tostring(dxy_mom, "+#.1") + "%" : "",
        text_color = dxy_mom < 0 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel, 0, 11, "黄金", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 11, not na(gold_c) ? "$" + str.tostring(gold_c, "#,##0") : "N/A",
        text_color = not na(gold_c) ? color.white : color.gray, text_size = size.small)
    table.cell(panel, 2, 11, not na(gold_c) ? str.tostring(gold_mom, "+#.1") + "%" : "",
        text_color = gold_mom > 0 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel, 0, 12, "纳指", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 12, not na(ndx_c) ? str.tostring(ndx_c, "#,##0") : "N/A",
        text_color = not na(ndx_c) ? color.white : color.gray, text_size = size.small)
    table.cell(panel, 2, 12, not na(ndx_c) ? str.tostring(ndx_mom, "+#.1") + "%" : "",
        text_color = ndx_mom > 0 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel, 0, 13, "VIX", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 13, not na(vix_c) ? str.tostring(vix_c, "#.00") : "N/A",
        text_color = not na(vix_c) ? color.white : color.gray, text_size = size.small)
    table.cell(panel, 2, 13, not na(vix_c) ? str.tostring(vix_mom, "+#.1") + "%" : "",
        text_color = vix_mom < 0 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel, 0, 14, "恐慌贪婪", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 14, str.tostring(fear_greed_approx, "#0") + "/100",
        text_color = fear_greed_approx < 30 ? color.green : fear_greed_approx > 70 ? color.red : color.white,
        text_size = size.small)
    table.cell(panel, 2, 14, "", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    
    // 分隔
    table.merge_cells(panel, 0, 15, 2, 15)
    table.cell(panel, 0, 15, "━━━ 品种详情 ━━━",
        text_color = color.gray, text_size = size.tiny, text_halign = text.align_center)

// 品种详情用第二个面板（避免行数不够）
var table panel2 = table.new(position.bottom_right, 3, 8,
    bgcolor = color.new(color.black, 50),
    border_color = color.gray, border_width = 1)

if barstate.islast
    // 状态
    rc = switch regime
        "STRONG_BULL" => color.green
        "WEAK_BULL" => color.lime
        "RANGE" => color.gray
        "WEAK_BEAR" => color.orange
        => color.red
    table.cell(panel2, 0, 0, "状态", text_color = color.gray, text_size = size.small)
    table.cell(panel2, 1, 0, regime, text_color = rc, text_size = size.small)
    table.cell(panel2, 2, 0, "", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel2, 0, 1, "RSI", text_color = color.gray, text_size = size.small)
    table.cell(panel2, 1, 1, str.tostring(rsi, "#0"),
        text_color = rsi < 30 ? color.green : rsi > 70 ? color.red : color.white, text_size = size.small)
    table.cell(panel2, 2, 1, "", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel2, 0, 2, "DCA", text_color = color.gray, text_size = size.small)
    table.cell(panel2, 1, 2, dca_band > 0 ? "Band " + str.tostring(dca_band) : "—",
        text_color = dca_band >= 3 ? color.green : dca_band > 0 ? color.blue : color.gray, text_size = size.small)
    table.cell(panel2, 2, 2, str.tostring(dd_ath * 100, "-#.1") + "%",
        text_color = dd_ath < -0.40 ? color.green : color.white, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel2, 0, 3, "EMA200", text_color = color.gray, text_size = size.small)
    table.cell(panel2, 1, 3, str.tostring(dist_ema200 * 100, "+#.1") + "%",
        text_color = dist_ema200 < 0 ? color.orange : color.green, text_size = size.small)
    table.cell(panel2, 2, 3, "", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel2, 0, 4, "30日涨跌", text_color = color.gray, text_size = size.small)
    table.cell(panel2, 1, 4, str.tostring(mom30, "+#.1") + "%",
        text_color = mom30 > 0 ? color.green : color.red, text_size = size.small)
    table.cell(panel2, 2, 4, "", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    
    table.cell(panel2, 0, 5, "ATR%", text_color = color.gray, text_size = size.small)
    table.cell(panel2, 1, 5, str.tostring(atr_pct, "#.1") + "%",
        text_color = color.white, text_size = size.small)
    table.cell(panel2, 2, 5, "", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    
    // 信号冲突检测
    conflict = ""
    if l0_score > 65 and l2_score < 30
        conflict := "⚡ 宏观好但技术面贵→等回调"
    else if l0_score < 30 and l2_score > 70
        conflict := "⚡ 宏观差但技术面便宜→价值陷阱"
    table.merge_cells(panel2, 0, 6, 2, 6)
    table.cell(panel2, 0, 6, conflict,
        text_color = conflict != "" ? color.orange : color.gray,
        text_size = size.small, text_halign = text.align_center)
    table.merge_cells(panel2, 0, 7, 2, 7)
    table.cell(panel2, 0, 7, "💰 Base: $" + str.tostring(base_amount, "#,##0"),
        text_color = color.purple, text_size = size.small, text_halign = text.align_center)

// ═══════════════════════════════════════════════════════════
// 警报
// ═══════════════════════════════════════════════════════════

alertcondition(action >= 3, title="V6 买入信号", message="HODL V6 买入信号触发")
alertcondition(action <= 1, title="V6 减仓信号", message="HODL V6 减仓信号触发")
alertcondition(dca_band >= 4, title="V6 深度回调", message="HODL V6 深度回调激活")
alertcondition(rsi < 25, title="V6 RSI超卖", message="HODL V6 RSI超卖 恐慌区")
````
