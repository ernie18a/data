# Cloud Institutional Bands | Rainbow Matrix

- url: https://www.tradingview.com/script/gINwFBEf-Cloud-Institutional-Bands-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;a581de35e55c496f8b32729d586efede
- version: 3.0

## Description

GENERAL OVERVIEW
The Cloud Institutional Bands is a statistical price-envelope indicator that maps institutional accumulation and exhaustion zones using deviation channels built on a Log-Normal regression anchored to a dynamic VWAP. Instead of treating the chart as a series of fixed support and resistance levels, the indicator continuously classifies the current price into one of four statistical regimes — and colors the chart accordingly.

The main goal of this indicator is to give traders a clean, automatic read on how stretched price is relative to its own statistical baseline — without having to manually identify trend strength, overextension, or exhaustion zones bar by bar. Every band you see on the chart represents a specific deviation from the volume-weighted regression base, and every color tells you which statistical zone is currently active.

It plots four pairs of deviation bands (eight bands in total: four above the regression base and four below), each calibrated to a Fibonacci-proportioned sigma multiplier. Combined with the dynamic VWAP and the Zone Info Panel, the indicator gives a complete read on directional bias, statistical position, and proximity to extreme zones — all from a single visual.

This indicator was developed for traders who already understand band-based indicators (Bollinger, Keltner, Donchian) and want a statistically corrected envelope that handles asymmetric price distributions properly, particularly during volatility expansion phases.

[image]https://www.tradingview.com/x/2EjNVKER/[/image]

WHAT IS THE THEORY BEHIND THIS INDICATOR?
Most envelope indicators on TradingView — Bollinger Bands, Keltner Channels, and their derivatives — share a common architectural choice: they apply standard deviation directly to the price series, using a Simple Moving Average (or similar linear estimator) as the central tendency. This treats price as a symmetric variable.

The problem: price is not symmetric. Price has a hard floor at zero and unbounded upside. Its returns follow a log-normal distribution, not a normal one. Applying linear statistics to asymmetric data introduces a systematic bias — bands that are too wide on one side and too narrow on the other, especially during volatility expansion. This bias becomes most visible at exactly the moments traders need accuracy most: trend climaxes, blow-off tops, capitulation lows.

This indicator addresses that bias by performing the regression in log space. The price series is first transformed via the natural logarithm, the linear regression is fitted on the log-prices, the standard deviation of the residuals is computed, and the resulting deviation bands are exponentiated back to price space. The math is standard — what makes it useful is applying it to a series that actually follows the underlying distribution it assumes.

Why traders use it: each band represents a probabilistic boundary. When price sits between the regression base and the first deviation band, it is statistically inside its normal operating range — equilibrium. When price crosses into the second band, the move has crossed into directional territory. The third band marks the threshold beyond which most of the impulse has already happened — exhaustion. The fourth band marks the tail of the distribution — a Black Swan event in Taleb's sense — where less than 1% of candles reach under normal conditions.

The dynamic VWAP overlay adds a second dimension: directional bias. While the regression bands tell you how stretched price is, the VWAP tells you whether the volume-weighted average favors buyers or sellers. Together they give a two-axis read on every bar: directional bias plus statistical zone.

CLOUD INSTITUTIONAL BANDS FEATURES

The indicator includes 6 main features:
Log-Normal Regression Engine
Fibonacci-Proportioned Deviation Bands
Dynamic VWAP with Glow
Rainbow Zone Fills
Zone Info Panel (HUD)
Black Swan Alerts

Multilingual interface and full customization across all visual layers.

LOG-NORMAL REGRESSION ENGINE
🔹 What It Does
The core of the indicator. Every bar, the engine performs four operations:
◇ Transforms the price series (hlc3) into log space via the natural logarithm.
◇ Fits a linear regression through the log-prices over the configured lookback window.
◇ Computes the standard deviation of the residuals — the gap between actual log-price and the regression line.
◇ Exponentiates the regression line and the deviation bands back to price space.

The result is a statistical baseline (the Base Line) and four pairs of deviation bands that respect the asymmetric nature of price distribution.

🔹 Method
The regression base is calculated using a standard linear regression on the log-price series. This is the classic least-squares fit — every bar in the lookback window contributes equally. The result is a baseline that represents where the market would be statistically if it were tracking its own trend perfectly.

🔹 Period
The Band Period input sets the rolling lookback window for both the regression and the standard deviation calculation. Larger values produce smoother, wider bands that respond slowly to new price action. Smaller values produce tighter, more reactive bands that follow recent volatility more closely. The default is 200 bars, calibrated for the 223-minute Bitcoin chart. For other instruments and timeframes, the period should be adjusted to match the natural cycle length of the asset.

FIBONACCI-PROPORTIONED DEVIATION BANDS
🔹 The Four Sigma Multipliers
Instead of plotting bands at integer multiples of the standard deviation (1σ, 2σ, 3σ), this indicator uses Fibonacci-inspired proportions:
◇ ±1.50σ — Breathing Zone (yellow above, green below)
◇ ±1.85σ — Alert Zone (orange above, teal below)
◇ ±2.75σ — Exhaustion Zone (red above, blue below)
◇ ±3.85σ — Black Swan Zone (purple above, aqua below)

Each multiplier corresponds to a different probabilistic regime:
◇ Breathing Zone: equilibrium. Most candles operate inside this range. Low conviction, no signal.
◇ Alert Zone: directional move in progress. Trend is asserting itself. Watch for follow-through.
◇ Exhaustion Zone: most of the impulse has already happened. Pullback probability rising. New entries in trend direction have unfavorable risk-reward.
◇ Black Swan Zone: statistical extreme. Less than 1% of candles reach this band under normal market conditions. Elevated probability of either mean reversion or volatility regime change.

[SCREENSHOT: Chart annotated with the four zones, showing price moving through Breathing → Alert → Exhaustion → Black Swan]
snapshot

DYNAMIC VWAP WITH GLOW
🔹 What It Does
A Volume-Weighted Moving Average is plotted alongside the regression bands, using the same lookback window. The VWAP renders in teal when price trades above it (bullish bias) and in red when price trades below (bearish bias).

🔹 Glow Effect
The VWAP line carries a proximity-based glow: the closer price gets to the VWAP, the more intense the glow becomes. This visual cue prepares the eye for proximity to a high-liquidity zone, where reactions often occur.

🔹 Why It Matters
The regression bands tell you how stretched price is. The VWAP tells you what bias the volume-weighted average favors. Together they give a complete read on every bar:
◇ Price above VWAP and inside Breathing Zone: healthy uptrend.
◇ Price above VWAP and at +2.75σ: uptrend in exhaustion.
◇ Price below VWAP and at -3.85σ: capitulation or imminent reversal.

RAINBOW ZONE FILLS
🔹 What They Show
The space between adjacent deviation bands is filled with a semi-transparent color matching the zone palette. This makes the current zone immediately visible without having to read the Z-Score number — the chart background tells you the regime at a glance.

🔹 Toggleable
Fills can be turned off for traders who prefer to see only the band lines themselves. The lines alone (with the Base Line and VWAP) still provide all the information; the fills are a visual aid to make zone identification faster.

ZONE INFO PANEL (HUD)
🔹 What It Shows
A compact corner panel reports three live values:
◇ ZONE — the name of the currently active zone (e.g., "ALERT — HIGH RISK ZONE", "EQUILIBRIUM — BASE LINE")
◇ DEV. — the current Z-Score, expressed in standard deviations (e.g., "+2.44σ")
◇ VWAP — the current position relative to the dynamic VWAP ("VWAP: BUY ZONE" or "VWAP: SELL ZONE")

🔹 Why It Helps
The HUD removes the need to interpret colors and band positions visually. It tells you in plain language where price is, how stretched it is, and which direction the volume-weighted bias is leaning. Useful for live trading where decisions need to happen quickly.

🔹 Customization
The HUD can be positioned in any of the four chart corners and rendered in any of five font sizes. The display language is controlled by the System Language input.

[SCREENSHOT: Zone Info Panel close-up showing the three live values during a Black Swan touch]
snapshot

BLACK SWAN ALERTS
🔹 What Triggers
The indicator fires an alert when price touches the ±3.85σ band — the Black Swan zone. Two separate alerts are available: one for the upper extreme (potential capitulation top), one for the lower extreme (potential capitulation bottom).

🔹 How They Fire
Alerts are gated by barstate.isconfirmed, which means they only trigger on the close of the bar that touched the band — not intra-bar. This prevents false signals from wicks that get rejected before the bar closes.

🔹 Frequency
Each alert uses alert.freq_once_per_bar, ensuring no duplicate firings on the same candle.

MULTILINGUAL INTERFACE
The indicator supports five languages for the HUD display and alert messages: English (default), Português, Español, Русский, and 中文 (Chinese). Code, comments, and configuration tooltips remain in English regardless of the selected language.

For reference, the English text of all multilingual UI strings used in the HUD and alerts:
◇ BLACK SWAN — EXTREME HIGH / BLACK SWAN — EXTREME LOW
◇ BUYING EXHAUSTION / SELLING EXHAUSTION
◇ ALERT — HIGH RISK ZONE / ALERT — LOW RISK ZONE
◇ INSTITUTIONAL BREATHING ZONE
◇ EQUILIBRIUM — BASE LINE
◇ VWAP: BUY ZONE / VWAP: SELL ZONE
◇ ZONE: / DEV.: / VWAP:
◇ Black Swan Alert High: "Price at 4th standard deviation — EXTREME HIGH. High probability of severe reversal."
◇ Black Swan Alert Low: "Price at 4th standard deviation — EXTREME LOW. High probability of explosive reversal."

HOW TO USE
This indicator is not a signal generator. It is a state classifier: it tells you which statistical zone the current price is in, and how that zone relates to the volume-weighted bias.

🔹 Reading the Chart
◇ Identify the current Z-Score from the Zone Info Panel.
◇ Note the active zone color in the panel and on the chart fills.
◇ Combine with VWAP position for directional context.

🔹 Tactical Reading
◇ Z-Score between -1.50 and +1.50: market is in equilibrium. Mean-reversion strategies have higher edge than breakout strategies.
◇ Z-Score crossing ±1.85: breakout in progress. Trend-following entries have higher edge than fade entries.
◇ Z-Score at ±2.75: trend is mature. Trailing stops should be tightened. New entries in trend direction have unfavorable risk-reward.
◇ Z-Score touching ±3.85: Black Swan touch. Statistically the tail. Mean reversion has elevated probability — but Black Swans can also indicate regime change, where volatility expands and a new range opens. Use the Black Swan Alert to catch these events.

🔹 Multi-Timeframe Reading
◇ On lower timeframes (1m, 5m, 15m), the bands react to micro-trends and serve as dynamic support and resistance.
◇ On higher timeframes (1h, 4h, daily), the bands map macro regime — the outer bands at higher timeframes represent multi-day exhaustion zones.

INPUTS EXPLAINED
🔹 System Language
Display language for the HUD and alert messages. Options: English (default), Português, Español, Русский, 中文 (Chinese).

🔹 Band Period (bars)
Rolling lookback for the Log-Normal regression and the VWAP. Range 50–500, default 200. Higher values produce smoother, wider bands; lower values produce tighter, more reactive bands.

🔹 Show Thermal Zone Fills
Toggle for the semi-transparent rainbow fills between adjacent bands.

🔹 Show Black Swan Glow (4th Std Dev)
Toggle for the glow effect on the outermost ±3.85σ bands. The glow intensifies as price approaches the band.

🔹 Show Base Line (Gravitational Center)
Toggle for the regression central line — the statistical baseline around which the bands are computed.

🔹 Show Dynamic VWAP (Macro)
Toggle for the volume-weighted reference line with proximity glow.

🔹 Show Zone Info Panel
Toggle for the corner HUD reporting current zone, Z-Score, and VWAP position.

🔹 Panel Position
Position of the HUD on the chart. Four corners available: Top Right (default), Top Left, Bottom Right, Bottom Left.

🔹 Font Size
HUD font size. Options: Tiny (default), Small, Normal, Large, Huge.

🔹 Black Swan Alert (4th Std Dev touch)
Toggle for the alerts that fire when price touches the ±3.85σ band. Two alerts: one for the upper extreme, one for the lower extreme.

IMPORTANT NOTES
The Cloud Institutional Bands works on any timeframe. The Band Period default of 200 is calibrated for the 223-minute chart and may need adjustment for other timeframes — a good rule of thumb is to set the period to approximately one full daily cycle for the chart timeframe (e.g., 288 bars for 5-minute charts, 96 bars for 15-minute charts).

The indicator works best on instruments with reliable volume data: crypto perpetual contracts, large-cap equities, major forex pairs. On low-volume instruments, the dynamic VWAP component becomes less reliable, though the regression bands continue to function correctly.

Alerts fire once per confirmed bar. Historical bars never repaint after they close. The live bar updates intra-bar as expected for a real-time indicator.

The four sigma multipliers (1.50, 1.85, 2.75, 3.85) are intentionally non-standard. They are Fibonacci-inspired proportions, not arbitrary choices, and they map to four behavioral regimes derived from observation rather than to integer statistical thresholds.

Pine Script v6. Open-source under Mozilla Public License 2.0.

UNIQUENESS
The Cloud Institutional Bands is unique in three ways. First, it performs the regression in log space, addressing the asymmetric nature of price distribution that linear estimators (such as the Simple Moving Average used by Bollinger Bands) fail to account for. This produces bands that behave correctly during volatility expansion phases, where standard envelopes show systematic bias. Second, it uses Fibonacci-proportioned sigma multipliers (1.50, 1.85, 2.75, 3.85) instead of integer steps, mapping the bands to four behavioral regimes — breathing, alert, exhaustion, and Black Swan — that correspond to observable phases of institutional order flow rather than to arbitrary thresholds. Third, it integrates a dynamic VWAP overlay with proximity-based glow alongside the regression bands, giving traders a two-axis read on every bar: how stretched price is statistically, and which direction the volume-weighted bias favors. The combination of log-space regression, Fibonacci sigma calibration, and integrated VWAP context produces a statistical envelope that behaves differently from standard band-based indicators, particularly at trend climaxes and capitulation events where standard envelopes are least reliable.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//
// ════════════════════════════════════════════════════════════════════════════════
// CLOUD INSTITUTIONAL BANDS | RAINBOW MATRIX
//
// A statistical price-envelope indicator that maps institutional accumulation
// and exhaustion zones using Log-Normal regression-based deviation channels,
// overlaid with two complementary volume-weighted references: a rolling
// Volume-Weighted Moving Average (VWMA) and anchored VWAPs (D/W/M).
//
// METHOD:
//   1. Computes a Log-Normal linear regression of price (math.log(hlc3) ->
//      ta.linreg -> math.exp back to price space) as the central tendency.
//      Rationale: price action follows a log-normal (asymmetric) distribution,
//      not a normal one — applying standard deviation directly to linear prices
//      (as Bollinger Bands do) is technically incorrect for asymmetric data.
//   2. Computes the rolling standard deviation of the log-residuals over the
//      same lookback window.
//   3. Plots four deviation bands on each side of the regression base, using
//      Fibonacci-proportioned sigma multipliers (1.50, 1.85, 2.75, 3.85)
//      mapped to a thermal Rainbow palette.
//   4. The outermost band (3.85sigma) marks Black Swan extremes — statistically
//      rare events with elevated probability of mean reversion.
//   5. Overlays the rolling VWMA (Volume-Weighted Moving Average over the band
//      period) as a dynamic volume-bias reference. The VWMA itself is then
//      classified by the same Rainbow zone logic that classifies price —
//      surfacing whether the volume-weighted consensus is sitting in a
//      breathing, alert, exhaustion, or Black Swan zone.
//   6. Overlays up to three simultaneous Anchored VWAPs (Volume-Weighted
//      Average Price) — Daily, Weekly and Monthly anchors — each with an
//      independent visibility toggle, color picker and proximity glow.
//      Unlike the rolling-window VWMA, each anchored line accumulates from
//      its anchor reset forward (midnight UTC / Monday / 1st of the month).
//   7. The band engine (regression + VWMA) can be computed on an overridden
//      timeframe and/or symbol (empty = chart, default). A different-asset
//      override can be Ghost-reprojected onto the chart's price scale from
//      a shared period anchor — the reference asset's institutional
//      structure drawn where it would sit if the chart symbol had made the
//      same percentage moves (Ghost Bars projection pattern). The anchored
//      VWAPs always track the CHART symbol (the asset being traded).
//
// ORIGINALITY (LOG-NORMAL OVER BOLLINGER BANDS):
//   Standard Bollinger Bands apply standard deviation directly to the price
//   series using a Simple Moving Average as the central tendency. This treats
//   price as a symmetric variable, which it is not — price has a hard floor at
//   zero and unbounded upside. By taking the regression in log space and
//   exponentiating back, this indicator captures the true asymmetric character
//   of price movement, producing bands that respond proportionally to the
//   instrument's actual volatility regime.
//
// HOW TO USE:
//   - Price between base and 1.50sigma: equilibrium — low conviction, no signal.
//   - Price at 1.85sigma: Alert zone — trend in motion, watch for follow-through.
//   - Price at 2.75sigma: Exhaustion zone — elevated probability of pullback.
//   - Price touching 3.85sigma (purple/aqua bands): Black Swan event —
//     statistically rare extreme, elevated probability of mean reversion.
//   - VWMA's own rainbow zone (HUD Row 3): where the volume-weighted consensus
//     itself is sitting in the cloud. Reads the macro volumetric bias.
//   - Price vs AVWAP and VWMA (HUD Row 2): split into two independently-colored
//     cells. When both cells share the same color (both green or both red), the
//     two volume-weighted references are in agreement — confluence signal. When
//     the cells display different colors, the two references diverge — the
//     market is in transition between regimes.
//
// INPUTS EXPLAINED:
//   - System Language: HUD/alert text language (EN/PT/ES/RU/ZH).
//   - Band Period: rolling lookback for the Log-Normal regression and the VWMA.
//   - Show Thermal Zone Fills: color the bands between deviation levels.
//   - Show Black Swan Glow: render the outermost 3.85sigma bands with glow.
//   - Show Base Line: render the regression central line (gravitational center).
//   - Show Dynamic VWMA: render the rolling volume-weighted moving average.
//   - Anchored VWAPs: three independent lines (Daily ON by default; Weekly
//     and Monthly opt-in), each with color and proximity glow.
//   - Show Info Panel: render the corner HUD with the 4-row state readout.
//   - Black Swan Alert: fires when price touches the 3.85sigma extreme.
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Cloud Institutional Bands | Rainbow Matrix", overlay=true, max_bars_back=500, max_labels_count=50, max_lines_count=100)

// ========================================================================================================
// COLORS — RAINBOW PALETTE
// ========================================================================================================
c_up_4 = color.purple
c_up_3 = color.red
c_up_2 = color.orange
c_up_1 = color.yellow
c_dn_1 = color.green
c_dn_2 = color.teal
c_dn_3 = color.blue
c_dn_4 = color.aqua
c_neutral = color.gray
c_bull   = c_dn_2
c_bear   = c_up_3
c_base   = c_dn_1

// ========================================================================================================
// SYSTEM LANGUAGE
// ========================================================================================================
g_lang = "GLOBAL SETTINGS"
language = input.string("English", "System Language",
     options=["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group=g_lang,
     tooltip="Select the display language for all on-screen labels and alerts.")
string _l = language == "Português" ? "PT" : language == "Español" ? "ES" : language == "Русский" ? "RU" : language == "中文 (Chinese)" ? "ZH" : "EN"

// ── Multilingual strings (per §3.11) ──
var string s_bs_high   = _l=="PT"?"🦢 CISNE NEGRO — TOPO EXTREMO"    :_l=="ES"?"🦢 CISNE NEGRO — TECHO EXTREMO"    :_l=="RU"?"🦢 ЧЁРНЫЙ ЛЕБЕДЬ — ВЕРХ"          :_l=="ZH"?"🦢 黑天鹅 — 极端顶部"   :"🦢 BLACK SWAN — EXTREME HIGH"
var string s_bs_low    = _l=="PT"?"🦢 CISNE NEGRO — FUNDO EXTREMO"   :_l=="ES"?"🦢 CISNE NEGRO — FONDO EXTREMO"   :_l=="RU"?"🦢 ЧЁРНЫЙ ЛЕБЕДЬ — НИЗ"          :_l=="ZH"?"🦢 黑天鹅 — 极端底部"   :"🦢 BLACK SWAN — EXTREME LOW"
var string s_z_exh_h   = _l=="PT"?"⚠️ EXAUSTÃO COMPRADORA"           :_l=="ES"?"⚠️ AGOTAMIENTO COMPRADOR"          :_l=="RU"?"⚠️ ИСТОЩЕНИЕ ПОКУПАТЕЛЕЙ"        :_l=="ZH"?"⚠️ 买方衰竭"            :"⚠️ BUYING EXHAUSTION"
var string s_z_exh_l   = _l=="PT"?"⚠️ EXAUSTÃO VENDEDORA"            :_l=="ES"?"⚠️ AGOTAMIENTO VENDEDOR"           :_l=="RU"?"⚠️ ИСТОЩЕНИЕ ПРОДАВЦОВ"          :_l=="ZH"?"⚠️ 卖方衰竭"            :"⚠️ SELLING EXHAUSTION"
var string s_z_alert_h = _l=="PT"?"🔶 ALERTA — SOBRECOMPRADO"       :_l=="ES"?"🔶 ALERTA — SOBRECOMPRADO"       :_l=="RU"?"🔶 ПЕРЕКУПЛЕННОСТЬ"           :_l=="ZH"?"🔶 警报 — 超买"          :"🔶 ALERT — OVERBOUGHT"
var string s_z_alert_l = _l=="PT"?"🔷 ALERTA — SOBREVENDIDO"        :_l=="ES"?"🔷 ALERTA — SOBREVENDIDO"        :_l=="RU"?"🔷 ПЕРЕПРОДАННОСТЬ"           :_l=="ZH"?"🔷 警报 — 超卖"          :"🔷 ALERT — OVERSOLD"
var string s_z_breathe = _l=="PT"?"💚 ZONA DE RESPIRO INSTITUCIONAL"  :_l=="ES"?"💚 ZONA DE RESPIRO INSTITUCIONAL" :_l=="RU"?"💚 ИНСТИТУЦИОНАЛЬНЫЙ ОТКАТ"      :_l=="ZH"?"💚 机构回调区域"          :"💚 INSTITUTIONAL BREATHING ZONE"
var string s_z_equil   = _l=="PT"?"⚖️ EQUILÍBRIO — LINHA BASE"        :_l=="ES"?"⚖️ EQUILIBRIO — LÍNEA BASE"       :_l=="RU"?"⚖️ РАВНОВЕСИЕ — БАЗОВАЯ ЛИНИЯ"  :_l=="ZH"?"⚖️ 均衡 — 基准线"        :"⚖️ EQUILIBRIUM — BASE LINE"
// --- Position labels (Price vs VWMA, Price vs Anchored VWAP) ---
var string s_lbl_price   = _l=="PT"?"PREÇO:"         :_l=="ES"?"PRECIO:"          :_l=="RU"?"ЦЕНА:"           :_l=="ZH"?"价格:"     :"PRICE:"
var string s_lbl_vwma    = _l=="PT"?"VWMA:"          :_l=="ES"?"VWMA:"            :_l=="RU"?"VWMA:"           :_l=="ZH"?"VWMA:"     :"VWMA:"
// --- Position indicators (symbolic, language-agnostic) ---
var string s_above_vwma  = "▲ VWMA"
var string s_below_vwma  = "▼ VWMA"
var string s_above_avwap = "▲ AVWAP"
var string s_below_avwap = "▼ AVWAP"
var string s_avwap_off   = "(off)"
var string s_lbl_zone  = _l=="PT"?"ZONA:"                              :_l=="ES"?"ZONA:"                             :_l=="RU"?"ЗОНА:"                          :_l=="ZH"?"区域:"                  :"ZONE:"
var string s_al_bs_h   = _l=="PT"?"🦢 [CISNE NEGRO] Preço atingiu o 4.º desvio padrão — TOPO EXTREMO. Alta probabilidade de reversão severa." :_l=="ES"?"🦢 [CISNE NEGRO] Precio en el 4.º desvío estándar — TECHO EXTREMO. Alta probabilidad de reversión severa." :_l=="RU"?"🦢 [ЧЁРН. ЛЕБЕДЬ] Цена на 4-м станд. отклонении — ЭКСТРЕМАЛЬНЫЙ ВЕРХ. Высокая вероятность разворота." :_l=="ZH"?"🦢 [黑天鹅] 价格达到第4标准差 — 极端顶部。高度可能严重反转。" :"🦢 [BLACK SWAN] Price at 4th standard deviation — EXTREME HIGH. High probability of severe reversal."
var string s_al_bs_l   = _l=="PT"?"🦢 [CISNE NEGRO] Preço atingiu o 4.º desvio padrão — FUNDO EXTREMO. Alta probabilidade de reversão explosiva." :_l=="ES"?"🦢 [CISNE NEGRO] Precio en el 4.º desvío estándar — FONDO EXTREMO. Alta probabilidad de reversión explosiva." :_l=="RU"?"🦢 [ЧЁРН. ЛЕБЕДЬ] Цена на 4-м станд. отклонении — ЭКСТРЕМАЛЬНОЕ ДНО. Высокая вероятность взрывного разворота." :_l=="ZH"?"🦢 [黑天鹅] 价格达到第4标准差 — 极端底部。高度可能爆发性反转。" :"🦢 [BLACK SWAN] Price at 4th standard deviation — EXTREME LOW. High probability of explosive reversal."
var string s_al_glow_on_h  = _l=="PT"?"🦢 [CISNE NEGRO] Glow do TOPO ACESO — preço na zona de aproximação do 4.º desvio padrão superior (ou além dele)." :_l=="ES"?"🦢 [CISNE NEGRO] Glow del TECHO ENCENDIDO — precio en la zona de aproximación del 4.º desvío estándar superior (o más allá)." :_l=="RU"?"🦢 [ЧЁРН. ЛЕБЕДЬ] Свечение ВЕРХА ЗАЖГЛОСЬ — цена в зоне 4-го станд. отклонения (верх) или за ним." :_l=="ZH"?"🦢 [黑天鹅] 顶部光晕点亮 — 价格进入第4标准差上轨附近或已越过。" :"🦢 [BLACK SWAN] HIGH glow LIT — price inside the approach zone of the 4th standard deviation high (or beyond it)."
var string s_al_glow_off_h = _l=="PT"?"🌑 [CISNE NEGRO] Glow do TOPO APAGADO — preço se afastou do 4.º desvio padrão superior; episódio extremo esvaindo." :_l=="ES"?"🌑 [CISNE NEGRO] Glow del TECHO APAGADO — precio se alejó del 4.º desvío estándar superior; episodio extremo desvaneciéndose." :_l=="RU"?"🌑 [ЧЁРН. ЛЕБЕДЬ] Свечение ВЕРХА ПОГАСЛО — цена отошла от 4-го станд. отклонения (верх); экстремальный эпизод угасает." :_l=="ZH"?"🌑 [黑天鹅] 顶部光晕熄灭 — 价格远离第4标准差上轨；极端事件消退。" :"🌑 [BLACK SWAN] HIGH glow EXTINGUISHED — price pulled away from the 4th standard deviation high; extreme episode fading."
var string s_al_glow_on_l  = _l=="PT"?"🦢 [CISNE NEGRO] Glow do FUNDO ACESO — preço na zona de aproximação do 4.º desvio padrão inferior (ou além dele)." :_l=="ES"?"🦢 [CISNE NEGRO] Glow del FONDO ENCENDIDO — precio en la zona de aproximación del 4.º desvío estándar inferior (o más allá)." :_l=="RU"?"🦢 [ЧЁРН. ЛЕБЕДЬ] Свечение НИЗА ЗАЖГЛОСЬ — цена в зоне 4-го станд. отклонения (низ) или за ним." :_l=="ZH"?"🦢 [黑天鹅] 底部光晕点亮 — 价格进入第4标准差下轨附近或已越过。" :"🦢 [BLACK SWAN] LOW glow LIT — price inside the approach zone of the 4th standard deviation low (or beyond it)."
var string s_al_glow_off_l = _l=="PT"?"🌑 [CISNE NEGRO] Glow do FUNDO APAGADO — preço se afastou do 4.º desvio padrão inferior; episódio extremo esvaindo." :_l=="ES"?"🌑 [CISNE NEGRO] Glow del FONDO APAGADO — precio se alejó del 4.º desvío estándar inferior; episodio extremo desvaneciéndose." :_l=="RU"?"🌑 [ЧЁРН. ЛЕБЕДЬ] Свечение НИЗА ПОГАСЛО — цена отошла от 4-го станд. отклонения (низ); экстремальный эпизод угасает." :_l=="ZH"?"🌑 [黑天鹅] 底部光晕熄灭 — 价格远离第4标准差下轨；极端事件消退。" :"🌑 [BLACK SWAN] LOW glow EXTINGUISHED — price pulled away from the 4th standard deviation low; extreme episode fading."

// ========================================================================================================
// INPUTS
// ========================================================================================================
g_cloud = "RAINBOW CLOUD"
band_period = input.int(200, "Band Period (bars)", minval=50, maxval=500, group=g_cloud,
     tooltip="The lookback window for the Log-Normal regression. Higher = smoother, wider bands. Lower = more reactive to recent price action. Default 200 is calibrated for the 223-minute chart.")
bands_tf = input.timeframe("", "Bands Timeframe (empty = chart)", group=g_cloud,
     tooltip="Timeframe on which the whole band engine (Log-Normal regression + VWMA) is computed. Empty = the chart's timeframe (default, previous behavior). Set a fixed resolution — e.g. 223 — to render that timeframe's institutional structure on any chart. Anti-repaint (lookahead_off): on a slower bands timeframe, values update once per closed bar of that timeframe.")
bands_symbol = input.symbol("", "Bands Symbol (empty = chart)", group=g_cloud,
     tooltip="Symbol on which the band engine is computed. Empty = the chart's symbol (default). DIRECT use (Ghost Reprojection OFF) only makes sense for feeds of the SAME asset — e.g. compute on the liquid spot feed while trading the perpetual; a different asset would render off the chart's price scale. For a DIFFERENT asset (e.g. BTC structure while trading an altcoin), keep Ghost Reprojection ON below.")
ghost_reproject = input.bool(true, "Ghost Reprojection (different asset)", group=g_cloud,
     tooltip="Only active when a Bands Symbol override is set. Rescales the override symbol's bands onto the chart's price scale from a shared period anchor: band_ghost = chart_anchor_open x (band / symbol_anchor_open) — the reference asset's institutional structure drawn where it would sit if the chart symbol had made the same percentage moves since the anchor. Same multiplicative projection as the Ghost Bars indicator. Disable only when the override symbol shares the chart's price scale (same asset, different feed).")
ghost_anchor_tf = input.timeframe("D", "Ghost Anchor Reset", group=g_cloud,
     tooltip="Period whose open re-anchors the Ghost Reprojection (both the chart symbol's and the override symbol's baselines). Default D — daily re-attach, matching the Ghost Bars default. Only used when a Bands Symbol override is set and Ghost Reprojection is ON.")
show_fills   = input.bool(true,  "Show Thermal Zone Fills", group=g_cloud,
     tooltip="Toggle the colored fills between the deviation bands. When enabled, each zone is shaded at the user-controlled transparency (see Rainbow Cloud Transparency below). Disable for a minimal line-only chart.")
fills_transp = input.int(88, "Rainbow Cloud Transparency", minval=50, maxval=99, group=g_cloud,
     tooltip="Base transparency for the thermal zone fills. Lower = more visible and saturated; higher = more subtle and transparent. The hierarchy between outer (exhaustion) and inner (breathing) bands is preserved — inner bands are always slightly more transparent than outer bands. Default 88 matches the original aesthetic (outer 88 / middle 90 / inner 93).")
show_bs_glow = input.bool(true,  "Show Black Swan Glow (4th Std Dev)", group=g_cloud,
     tooltip="The outermost lines (Purple/Aqua) glow when price enters the 4th standard deviation — a statistical extreme occurring in less than 1% of candles.")
show_midline = input.bool(true,  "Show Base Line (Gravitational Center)", group=g_cloud,
     tooltip="Toggle the Log-Normal regression base line — the central tendency around which all rainbow zones are measured. Plotted with proximity glow that intensifies as price approaches.")

g_vwma = "VWMA SETTINGS"
show_vwma_macro = input.bool(true,  "Show Dynamic VWMA (Macro)", group=g_vwma,
     tooltip="Volume-Weighted Moving Average over the band period. The Glow effect intensifies as price approaches — preparing your eye for the impact.")
show_avwap_d = input.bool(true,  "Anchored VWAP — Daily", group=g_vwma, inline="avd",
     tooltip="Daily Anchored VWAP — Volume-Weighted Average Price accumulated from each daily open (midnight UTC), rendered with proximity glow. Unlike the Dynamic VWMA (rolling window), the Anchored VWAP accumulates from the anchor forward. The Info Panel's AVWAP row tracks THIS line. Color configurable beside the toggle.")
col_avwap_d  = input.color(color.white, "", group=g_vwma, inline="avd", tooltip="Daily Anchored VWAP color.")
show_avwap_w = input.bool(false, "Anchored VWAP — Weekly", group=g_vwma, inline="avw",
     tooltip="Weekly Anchored VWAP — accumulates from each Monday open. Default OFF; enable for swing context alongside the daily anchor. Proximity glow included; color configurable beside the toggle.")
col_avwap_w  = input.color(color.silver, "", group=g_vwma, inline="avw", tooltip="Weekly Anchored VWAP color.")
show_avwap_m = input.bool(false, "Anchored VWAP — Monthly", group=g_vwma, inline="avm",
     tooltip="Monthly Anchored VWAP — accumulates from the 1st of each month. Default OFF; the slowest institutional anchor. Proximity glow included; color configurable beside the toggle.")
col_avwap_m  = input.color(color.gray, "", group=g_vwma, inline="avm", tooltip="Monthly Anchored VWAP color.")

g_info = "INFO PANEL"
show_panel = input.bool(true, "Show Zone Info Panel", group=g_info,
     tooltip="Displays the 4-row state panel: brand and Z-Score header, price's rainbow zone, price-position vs AVWAP and VWMA (split into independently-colored cells so divergence is visually immediate), and the VWMA's own rainbow zone classification.")
panel_pos  = input.string("Bottom Left", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=g_info,
     tooltip="Anchor position for the Zone Info Panel on the chart. The panel renders fixed in one of the four corners regardless of zoom or scroll.")
i_text_size = input.string("Tiny", "Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_info,
     tooltip="Font size for the Zone Info Panel. Tiny is recommended for cluttered charts; Huge is recommended for streaming or screen-share. Scales all panel cells proportionally.")
font_size   = i_text_size == "Tiny" ? size.tiny : i_text_size == "Small" ? size.small : i_text_size == "Normal" ? size.normal : i_text_size == "Large" ? size.large : size.huge

g_al = "ALERTS"
al_black_swan = input.bool(true, "Black Swan Alert (4th Std Dev touch)", group=g_al,
     tooltip="Enables the Black Swan alert — fires once per bar when price touches the 4th standard deviation band, a statistical extreme occurring in less than 1% of candles. To activate the alert in TradingView, create an alert with 'Any alert() function call' as the condition. The alert message is localized to the selected System Language.")
al_bs_glow_on = input.bool(true, "Black Swan Glow LIT Alert", group=g_al,
     tooltip="Fires once when the Black Swan glow LIGHTS — price entered the approach zone of the 4th standard deviation band (or crossed beyond it; the glow now stays fully lit while price remains beyond the line). Hysteresis prevents flicker: the glow counts as LIT at transparency <= 70 and EXTINGUISHED at >= 90. One alert per episode, on the confirmed bar. Localized to the selected System Language.")
al_bs_glow_off = input.bool(true, "Black Swan Glow EXTINGUISHED Alert", group=g_al,
     tooltip="Fires once when the Black Swan glow EXTINGUISHES — price pulled away from the 4th standard deviation band after having lit it. Companion reads: touch alert = extreme reached; glow-lit = extreme approaching; glow-off = extreme episode fading. Same hysteresis and once-per-episode behavior. Localized to the selected System Language.")

// ========================================================================================================
// DEVIATION CALCULATION — FIBONACCI CALIBRATION
// ========================================================================================================
anticipation_factor   = 0.95
dev_short  = 1.50 * anticipation_factor   // ±1.50σ — Breathing Zone
dev_medium  = 1.85 * anticipation_factor   // ±1.85σ — Alert Zone
dev_long  = 2.75 * anticipation_factor   // ±2.75σ — Exhaustion Zone
dev_super  = 3.85 * anticipation_factor   // ±3.85σ — Black Swan Zone

// ========================================================================================================
// MATH ENGINE: LOG-NORMAL REGRESSION
// ========================================================================================================
// Why Log-Normal instead of Bollinger?
// Price follows a log-normal (asymmetric) distribution, not a normal (linear) one.
// Bollinger Bands apply standard deviation over a linear mean — technically incorrect.
// The Rainbow Cloud applies deviation over log(price) then converts back via exp(),
// capturing the true asymmetry of institutional moves.
// v1.5.b — the engine runs inside a security context so both the timeframe and the symbol can be
// overridden (empty inputs = chart symbol on chart TF = bit-exact previous behavior).
f_band_engine() =>
    float src      = hlc3 > 0 ? math.log(hlc3) : na
    float base_log = ta.linreg(src, band_period, 0)
    float residual = src - base_log
    float dev      = math.max(ta.stdev(residual, band_period), 0.000001)
    [math.exp(base_log),
     math.exp(base_log + dev * dev_short), math.exp(base_log + dev * dev_medium),
     math.exp(base_log + dev * dev_long),  math.exp(base_log + dev * dev_super),
     math.exp(base_log - dev * dev_short), math.exp(base_log - dev * dev_medium),
     math.exp(base_log - dev * dev_long),  math.exp(base_log - dev * dev_super),
     ta.vwma(hlc3, band_period)]

string bands_tf_eff  = bands_tf == "" ? timeframe.period : bands_tf
string bands_sym_eff = bands_symbol != "" ? bands_symbol : syminfo.tickerid
bool   bands_locked  = bands_symbol != ""

[raw_base, raw_up1, raw_up2, raw_up3, raw_up4, raw_dn1, raw_dn2, raw_dn3, raw_dn4, raw_vwma] = request.security(bands_sym_eff, bands_tf_eff, f_band_engine(), lookahead = barmerge.lookahead_off)

// v1.5.c — Ghost Reprojection (only when a symbol override is set and the toggle is ON):
// band_ghost = chart_anchor_open x (band / symbol_anchor_open) — the reference asset's structure
// rescaled onto the chart's price region from a shared period anchor (Ghost Bars pattern).
float gb_open = request.security(bands_sym_eff, timeframe.period, open, lookahead = barmerge.lookahead_off)
bool  gb_new_anchor = ta.change(time(ghost_anchor_tf)) != 0
var float gb_base_chart = na
var float gb_base_sym   = na
if (gb_new_anchor or na(gb_base_chart)) and not na(gb_open) and gb_open > 0
    gb_base_chart := open
    gb_base_sym   := gb_open
float gfactor = bands_locked and ghost_reproject and not na(gb_base_chart) and not na(gb_base_sym) and gb_base_sym > 0 ? gb_base_chart / gb_base_sym : 1.0

rbw_base = raw_base * gfactor
rbw_up1  = raw_up1 * gfactor
rbw_up2  = raw_up2 * gfactor
rbw_up3  = raw_up3 * gfactor
rbw_up4  = raw_up4 * gfactor
rbw_dn1  = raw_dn1 * gfactor
rbw_dn2  = raw_dn2 * gfactor
rbw_dn3  = raw_dn3 * gfactor
rbw_dn4  = raw_dn4 * gfactor

// Current Z-Score — statistical position of price within the DISPLAYED structure.
// v1.5 fix: the engine internals live inside f_band_engine(); the log-space deviation is
// recovered algebraically from the exported bands (ln(up2/base) = dev x dev_medium — the
// ghost factor cancels in the ratio), so the Z reads chart price vs the rendered bands
// in every mode (chart / TF override / Ghost Rainbow).
float rbw_dev_disp = math.log(rbw_up2 / rbw_base) / dev_medium
rbw_z_actual = rbw_dev_disp > 0 and hlc3 > 0 ? math.log(hlc3 / rbw_base) / rbw_dev_disp : 0.0

// ========================================================================================================
// DYNAMIC VWMA WITH GLOW
// ========================================================================================================
// v1.5.b — VWMA comes from the same security context as the bands (symbol/TF overrides + ghost factor apply)
vwma_macro = raw_vwma * gfactor

// Glow: 95% transparent when far, 20% when close — smooth proportional transition
rng_tr = ta.tr
f_glow(float level) =>
    int(95 - (math.max(0.0, math.min(1.0, 1.0 - (math.abs(hlc3 - level) / math.max(rng_tr * 1.0, 0.000001)))) * 75))

transp_vwma  = f_glow(vwma_macro)
transp_base  = f_glow(rbw_base)
// Black Swan glow with latch-on-extrapolation (v1.4): while price is BEYOND the 4th std dev band,
// the glow stays fully lit regardless of the extrapolated distance — previously it faded out again
// as price moved further past the line, dimming exactly at the most extreme moment.
transp_up4   = hlc3 >= rbw_up4 ? 20 : f_glow(rbw_up4)
transp_dn4   = hlc3 <= rbw_dn4 ? 20 : f_glow(rbw_dn4)

c_vwma = high > vwma_macro ? c_bull : low < vwma_macro ? c_bear : c_neutral
// ========================================================================================================
// ANCHORED VWAPS (v1.5.a) — three simultaneous anchors (D/W/M), MGI Walls pattern
// ========================================================================================================
// v1.5.a — three simultaneous anchored VWAPs (D/W/M), MGI Walls pattern. All three are computed
// unconditionally (Pine ta.* consistency); the toggles gate rendering only.
float avwap_d = ta.vwap(hlc3, timeframe.change("D"))
float avwap_w = ta.vwap(hlc3, timeframe.change("W"))
float avwap_m = ta.vwap(hlc3, timeframe.change("M"))
int   transp_avwap_d = show_avwap_d ? f_glow(avwap_d) : 95
int   transp_avwap_w = show_avwap_w ? f_glow(avwap_w) : 95
int   transp_avwap_m = show_avwap_m ? f_glow(avwap_m) : 95

// ========================================================================================================
// VWMA ZONE CLASSIFICATION (NEW v1.3) — applies the same Rainbow zone classification logic to the VWMA line
// ========================================================================================================
float vwma_z = rbw_dev_disp > 0 and vwma_macro > 0 ? math.log(vwma_macro / rbw_base) / rbw_dev_disp : 0.0

string vwma_zone_txt = ""
color  vwma_zone_cor = c_neutral

if vwma_z >= dev_super
    vwma_zone_txt := s_bs_high,    vwma_zone_cor := c_up_4
else if vwma_z >= dev_long
    vwma_zone_txt := s_z_exh_h,    vwma_zone_cor := c_up_3
else if vwma_z >= dev_medium
    vwma_zone_txt := s_z_alert_h,  vwma_zone_cor := c_up_2
else if vwma_z >= dev_short
    vwma_zone_txt := s_z_breathe,  vwma_zone_cor := c_up_1
else if vwma_z >= -dev_short
    vwma_zone_txt := s_z_equil,    vwma_zone_cor := c_base
else if vwma_z >= -dev_medium
    vwma_zone_txt := s_z_breathe,  vwma_zone_cor := c_dn_1
else if vwma_z >= -dev_long
    vwma_zone_txt := s_z_alert_l,  vwma_zone_cor := c_dn_2
else if vwma_z >= -dev_super
    vwma_zone_txt := s_z_exh_l,    vwma_zone_cor := c_dn_3
else
    vwma_zone_txt := s_bs_low,     vwma_zone_cor := c_dn_4

// ========================================================================================================
// RENDERING: RAINBOW CLOUD + VWMA + ANCHORED VWAP
// ========================================================================================================
// ── Dynamic VWMA with Glow ──
plot(show_vwma_macro ? vwma_macro : na, "VWMA Glow",
     color=color.new(c_vwma, transp_vwma),  linewidth=6, display = display.pane)
plot(show_vwma_macro ? vwma_macro : na, "VWMA Main",
     color=color.new(c_vwma, math.max(20, transp_vwma - 20)), linewidth=2)
// ── Anchored VWAPs with Glow (v1.5.a — three simultaneous anchors, D/W/M) ──
plot(show_avwap_d ? avwap_d : na, "Anchored VWAP Daily Glow",
     color=color.new(col_avwap_d, transp_avwap_d), linewidth=5, display = display.pane)
plot(show_avwap_d ? avwap_d : na, "Anchored VWAP Daily",
     color=color.new(col_avwap_d, math.max(20, transp_avwap_d - 20)), linewidth=2)
plot(show_avwap_w ? avwap_w : na, "Anchored VWAP Weekly Glow",
     color=color.new(col_avwap_w, transp_avwap_w), linewidth=5, display = display.pane)
plot(show_avwap_w ? avwap_w : na, "Anchored VWAP Weekly",
     color=color.new(col_avwap_w, math.max(20, transp_avwap_w - 20)), linewidth=2)
plot(show_avwap_m ? avwap_m : na, "Anchored VWAP Monthly Glow",
     color=color.new(col_avwap_m, transp_avwap_m), linewidth=5, display = display.pane)
plot(show_avwap_m ? avwap_m : na, "Anchored VWAP Monthly",
     color=color.new(col_avwap_m, math.max(20, transp_avwap_m - 20)), linewidth=2)

// ── Black Swan Glow (4th standard deviation) ──
plot(show_bs_glow ? rbw_up4 : na, "Black Swan High Glow",
     color=color.new(c_up_4, transp_up4), linewidth=5, display = display.pane)
plot(show_bs_glow ? rbw_up4 : na, "Black Swan High",
     color=color.new(c_up_4, math.max(20, transp_up4 - 20)), linewidth=1)
plot(show_bs_glow ? rbw_dn4 : na, "Black Swan Low Glow",
     color=color.new(c_dn_4, transp_dn4), linewidth=5, display = display.pane)
plot(show_bs_glow ? rbw_dn4 : na, "Black Swan Low",
     color=color.new(c_dn_4, math.max(20, transp_dn4 - 20)), linewidth=1)

// ── Base (Gravitational Axis) with Glow ──
plot(show_midline ? rbw_base : na, "Rainbow Base Glow",
     color=color.new(c_base, transp_base), linewidth=4, display = display.pane)
p_base = plot(show_midline ? rbw_base : na, "Rainbow Base",
     color=color.new(c_base, math.max(20, transp_base - 20)), linewidth=1)

// ── Intermediate bands (for fills) ──
p_up3 = plot(rbw_up3, display=display.none, title="Up3 Hidden")
p_up2 = plot(rbw_up2, display=display.none, title="Up2 Hidden")
p_up1 = plot(rbw_up1, display=display.none, title="Up1 Hidden")
p_dn1 = plot(rbw_dn1, display=display.none, title="Dn1 Hidden")
p_dn2 = plot(rbw_dn2, display=display.none, title="Dn2 Hidden")
p_dn3 = plot(rbw_dn3, display=display.none, title="Dn3 Hidden")

// ── Thermal Zone Fills (hierarchical transparency — outer < middle < inner) ──
// User-controlled via fills_transp input. Inner bands get +2/+5 offsets (clamped to 99).
int t_exhaust = fills_transp
int t_alert   = math.min(99, fills_transp + 2)
int t_breathe = math.min(99, fills_transp + 5)

fill(p_up3, p_up2, color=show_fills ? color.new(c_up_3, t_exhaust) : na, title="Z-Exhaustion High")
fill(p_up2, p_up1, color=show_fills ? color.new(c_up_2, t_alert)   : na, title="Z-Alert High")
fill(p_up1, p_base, color=show_fills ? color.new(c_up_1, t_breathe) : na, title="Z-Breathing High")
fill(p_base, p_dn1, color=show_fills ? color.new(c_dn_1, t_breathe) : na, title="Z-Breathing Low")
fill(p_dn1, p_dn2, color=show_fills ? color.new(c_dn_2, t_alert)   : na, title="Z-Alert Low")
fill(p_dn2, p_dn3, color=show_fills ? color.new(c_dn_3, t_exhaust) : na, title="Z-Exhaustion Low")

// ========================================================================================================
// ZONE INFO PANEL — 4 rows × 3 cols (v1.3.2: AVWAP+VWMA split into independent cells on Row 2)
// ========================================================================================================
// Row 0: Header (brand col 0 + empty col 1 + Z-Score col 2)
// Row 1: Price's rainbow zone (label col 0 + zone text col 1 + empty col 2)
// Row 2: Price positions split (label col 0 + AVWAP col 1 + VWMA col 2, each cell independently colored)
// Row 3: VWMA's rainbow zone (label col 0 + zone text col 1 + empty col 2)
// ========================================================================================================

// Determine current Price zone based on Z-Score (uses rbw_z_actual)
string zone_txt  = ""
color  zone_color  = c_neutral

if     rbw_z_actual >=  dev_super
    zone_txt := s_bs_high,    zone_color := c_up_4
else if rbw_z_actual >=  dev_long
    zone_txt := s_z_exh_h,    zone_color := c_up_3
else if rbw_z_actual >=  dev_medium
    zone_txt := s_z_alert_h,  zone_color := c_up_2
else if rbw_z_actual >=  dev_short
    zone_txt := s_z_breathe,  zone_color := c_up_1
else if rbw_z_actual >= -dev_short
    zone_txt := s_z_equil,    zone_color := c_base
else if rbw_z_actual >= -dev_medium
    zone_txt := s_z_breathe,  zone_color := c_dn_1
else if rbw_z_actual >= -dev_long
    zone_txt := s_z_alert_l,  zone_color := c_dn_2
else if rbw_z_actual >= -dev_super
    zone_txt := s_z_exh_l,    zone_color := c_dn_3
else
    zone_txt := s_bs_low,     zone_color := c_dn_4

// Price vs AVWAP (positional, with Off handling) — col 1 of Row 2
string avwap_pos_txt = show_avwap_d ? (close > avwap_d ? s_above_avwap : s_below_avwap) : s_avwap_off
color  avwap_pos_cor = show_avwap_d ? (close > avwap_d ? c_bull : c_bear) : c_neutral

// Price vs VWMA (positional) — col 2 of Row 2
string vwma_pos_txt = close > vwma_macro ? s_above_vwma : s_below_vwma
color  vwma_pos_cor = close > vwma_macro ? c_bull       : c_bear

if show_panel and barstate.islast
    tbl_pos = panel_pos == "Top Right" ? position.top_right :
              panel_pos == "Top Left"  ? position.top_left  :
              panel_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

    var table tbl = table.new(tbl_pos, 3, 4, border_width=1, border_color=color.new(c_neutral, 70), frame_width=2, frame_color=color.new(color.black, 20))

    // Row 0 — Header (brand col 0 + empty col 1 + Z-Score col 2)
    z_str = (rbw_z_actual >= 0 ? "+" : "") + str.tostring(rbw_z_actual, "#.##") + "σ"
    table.cell(tbl, 0, 0, "🌈 RAINBOW CLOUD", text_color=color.new(c_dn_4, 0),    text_size=font_size, bgcolor=color.new(color.black, 10), text_halign=text.align_left)
    table.cell(tbl, 1, 0, "",                                                       text_size=font_size, bgcolor=color.new(color.black, 10))
    table.cell(tbl, 2, 0, "Z: " + z_str,        text_color=color.new(zone_color, 0), text_size=font_size, bgcolor=color.new(color.black, 10), text_halign=text.align_right)

    // Row 1 — Price's rainbow zone (col 2 empty match-bg)
    table.cell(tbl, 0, 1, s_lbl_zone, text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(color.black, 60), text_halign=text.align_left)
    table.cell(tbl, 1, 1, zone_txt,   text_color=color.new(zone_color, 0),   text_size=font_size, bgcolor=color.new(color.black, 60), text_halign=text.align_left)
    table.cell(tbl, 2, 1, "",                                              text_size=font_size, bgcolor=color.new(color.black, 60))

    // Row 2 — Price positions split: AVWAP (col 1) + VWMA (col 2), each independently colored
    table.cell(tbl, 0, 2, s_lbl_price,   text_color=color.new(c_neutral, 20),    text_size=font_size, bgcolor=color.new(color.black, 70), text_halign=text.align_left)
    table.cell(tbl, 1, 2, avwap_pos_txt, text_color=color.new(avwap_pos_cor, 0), text_size=font_size, bgcolor=color.new(color.black, 70), text_halign=text.align_left)
    table.cell(tbl, 2, 2, vwma_pos_txt,  text_color=color.new(vwma_pos_cor, 0),  text_size=font_size, bgcolor=color.new(color.black, 70), text_halign=text.align_left)

    // Row 3 — VWMA's own rainbow zone (col 2 empty match-bg)
    table.cell(tbl, 0, 3, s_lbl_vwma,    text_color=color.new(c_neutral, 20),       text_size=font_size, bgcolor=color.new(color.black, 60), text_halign=text.align_left)
    table.cell(tbl, 1, 3, vwma_zone_txt, text_color=color.new(vwma_zone_cor, 0),    text_size=font_size, bgcolor=color.new(color.black, 60), text_halign=text.align_left)
    table.cell(tbl, 2, 3, "",                                                       text_size=font_size, bgcolor=color.new(color.black, 60))

// ========================================================================================================
// ALERTS — BLACK SWAN
// ========================================================================================================
bs_high  = barstate.isconfirmed and high >= rbw_up4
bs_low = barstate.isconfirmed and low  <= rbw_dn4

// Black Swan glow episodes (v1.4) — hysteresis LIT <= 70 / EXTINGUISHED >= 90 transparency
// (the extrapolation latch above keeps an episode alive while price is beyond the band).
// One alert per episode, confirmed bar only.
var bool bs_glow_high_lit = false
var bool bs_glow_low_lit  = false
if barstate.isconfirmed
    if not bs_glow_high_lit and transp_up4 <= 70
        bs_glow_high_lit := true
        if al_bs_glow_on
            alert(s_al_glow_on_h, alert.freq_once_per_bar)
    else if bs_glow_high_lit and transp_up4 >= 90
        bs_glow_high_lit := false
        if al_bs_glow_off
            alert(s_al_glow_off_h, alert.freq_once_per_bar)
    if not bs_glow_low_lit and transp_dn4 <= 70
        bs_glow_low_lit := true
        if al_bs_glow_on
            alert(s_al_glow_on_l, alert.freq_once_per_bar)
    else if bs_glow_low_lit and transp_dn4 >= 90
        bs_glow_low_lit := false
        if al_bs_glow_off
            alert(s_al_glow_off_l, alert.freq_once_per_bar)

if al_black_swan and bs_high
    alert(s_al_bs_h, alert.freq_once_per_bar)

if al_black_swan and bs_low
    alert(s_al_bs_l, alert.freq_once_per_bar)

alertcondition(bs_high,  "Black Swan High", "Rainbow Cloud: Price touched the 4th standard deviation HIGH — extreme reversal zone.")
alertcondition(bs_low, "Black Swan Low",  "Rainbow Cloud: Price touched the 4th standard deviation LOW — extreme reversal zone.")
alertcondition(false, "HOW TO SETUP ALERTS (READ)", "Select 'Any alert() function call' in the condition menu.")
````
