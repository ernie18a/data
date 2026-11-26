# FVG Prime (Fair Value Gap Prime)

- url: https://www.tradingview.com/script/OW5M4xhU-FVG-Prime-Fair-Value-Gap-Prime/
- type: indicator
- pine_id: PUB;5c973eab571b45a081e08d73f61ab0e2
- version: 1.0

## Description

FVG Prime — Fair Value Gap Suite is a professional Fair Value Gap (FVG) analysis tool designed for traders who use Smart Money Concepts (SMC), ICT concepts, and institutional price action.

The indicator automatically detects bullish and bearish Fair Value Gaps using a strict three-candle imbalance model and provides advanced visualization, mitigation tracking, and optional Buy/Sell signals.

Rather than plotting every imbalance indiscriminately, FVG Prime incorporates multiple filtering and confirmation techniques to help reduce market noise while keeping the chart clean and easy to interpret.

The indicator is suitable for:

• Smart Money Concepts (SMC)

• ICT Methodology

• Price Action Trading

• Swing Trading

• Intraday Trading

• Scalping

• Trend Following

• Pullback Entries

• Market Structure Analysis

The primary objective of the indicator is to identify institutional price imbalances and monitor how price reacts when revisiting those zones. It is designed as a decision-support tool and should always be used alongside proper market structure analysis, risk management, and personal trading rules.

[b]USER INPUTS[/b]

1️⃣ FVG Detection Settings

Show Bullish FVG (Default: Enabled)

Displays all detected bullish Fair Value Gaps on the chart. Disable this option if you only want to analyze bearish imbalances.

Show Bearish FVG (Default: Enabled)

Displays all detected bearish Fair Value Gaps on the chart. Disable this option if you only want to analyze bullish imbalances.

ATR Size Filter (Default: Enabled)

Filters out very small Fair Value Gaps by requiring the gap height to exceed a percentage of the current Average True Range (ATR). This helps eliminate insignificant market noise and focuses on stronger institutional imbalances.

ATR Multiplier (× ATR) (Default: 0.25)

Determines the minimum size required for a Fair Value Gap to be plotted.

Minimum Gap Size = ATR × 0.25

Increasing this value results in fewer but generally stronger Fair Value Gaps, while decreasing it allows smaller gaps to be displayed.

ATR Length (Default: 14)

Defines the lookback period used to calculate the Average True Range for the size filter.

Smaller values respond more quickly to changing volatility, whereas larger values produce smoother filtering.

Maximum Active FVGs (Default: 20)

Limits the number of Fair Value Gaps displayed simultaneously on the chart.

Once this limit is reached, the oldest Fair Value Gap is automatically removed to maintain chart clarity and improve performance.

2️⃣ Mitigation Logic

Mitigation Trigger (Default: Midline (CE))

Defines when a Fair Value Gap is considered mitigated.

Available options include:

Touch

The Fair Value Gap is considered mitigated as soon as price touches any portion of the gap.

Midline (CE)

The Fair Value Gap is considered mitigated once price reaches the Consequent Encroachment (50% midpoint). This is the default setting and follows one of the most commonly used ICT mitigation concepts.

Full Fill

The Fair Value Gap remains active until price completely fills the entire imbalance.

After Mitigation (Default: Keep (Dimmed))

Determines what happens after a Fair Value Gap has been mitigated.

Delete

Completely removes the Fair Value Gap from the chart.

Keep (Dimmed)

Keeps the Fair Value Gap visible while significantly reducing its opacity, allowing traders to review historical mitigations without cluttering the chart.

3️⃣ Signal Engine

Show Buy / Sell Signals (Default: Enabled)

Displays Buy and Sell signals generated when price interacts with a valid Fair Value Gap according to the selected signal logic.

Signal Trigger (Default: Rejection Close)

Determines how trading signals are generated.

First Touch

A signal is generated immediately when price enters the Fair Value Gap.

Rejection Close

A signal is generated only when price enters the Fair Value Gap but closes back in the expected direction. This generally produces fewer but higher-quality trading opportunities and is the default option.

EMA Trend Filter (Default: Enabled)

Restricts signals to the prevailing trend.

Buy signals are only generated when price is above the EMA.

Sell signals are only generated when price is below the EMA.

This filter helps reduce counter-trend trades.

EMA Length (Default: 200)

Specifies the period of the Exponential Moving Average used for trend confirmation.

The default 200-period EMA is widely used as a long-term trend filter across multiple markets.

Volume Filter (Default: Disabled)

Requires the signal candle's trading volume to exceed the average volume before a Buy or Sell signal is generated.

This can help remove weaker reactions that occur on low trading activity.

Volume SMA Length (Default: 20)

Defines the moving average period used to calculate average trading volume.

Volume Multiplier (× Vol) (Default: 1.2)

Specifies how much greater the current candle's volume must be relative to the average volume.

For example, a value of 1.2 means the signal candle must have at least 120% of the average volume before a signal is allowed.

4️⃣ Visual Settings

Bullish Color (Default: Green)

Selects the display color used for bullish Fair Value Gaps.

Bearish Color (Default: Red)

Selects the display color used for bearish Fair Value Gaps.

Box Transparency (Default: 78)

Controls the transparency of all Fair Value Gap boxes.

Lower values make the boxes darker and more visible, while higher values make them increasingly transparent.

Age Fade Effect (Default: Enabled)

Gradually increases the transparency of older Fair Value Gaps, allowing newer institutional imbalances to stand out more clearly.

Fade Speed (Bars) (Default: 60)

Controls how quickly older Fair Value Gaps become more transparent.

Higher values create a slower fading effect, while lower values cause zones to fade more rapidly.

Show Midline (CE) (Default: Enabled)

Displays the Consequent Encroachment (50% midpoint) inside every Fair Value Gap.

Show Border (Default: Enabled)

Displays a border around each Fair Value Gap box to improve visibility.

Extend Right (Bars) (Default: 6)

Determines how many future bars each active Fair Value Gap extends across the chart.

Show FVG Text (Default: Enabled)

Displays "FVG ▲" or "FVG ▼" labels inside each Fair Value Gap for easier identification.

[b]INDICATOR LOGIC[/b]

FVG Prime continuously scans confirmed candles using the classic three-candle Fair Value Gap model.

A Bullish Fair Value Gap is created when the current candle's low is above the high of the candle two bars earlier while the middle candle confirms bullish continuation.

A Bearish Fair Value Gap is created when the current candle's high is below the low of the candle two bars earlier while the middle candle confirms bearish continuation.

To reduce false positives, the indicator can optionally filter Fair Value Gaps using an ATR-based minimum size requirement.

Once a valid Fair Value Gap is identified, the indicator automatically:

• Draws the Fair Value Gap as a colored box.

• Calculates and displays the Consequent Encroachment (50% midpoint).

• Extends the zone into future candles.

• Tracks whether the Fair Value Gap remains active or has been mitigated.

• Automatically updates the appearance of mitigated zones.

When enabled, the Signal Engine monitors every active Fair Value Gap and generates Buy or Sell signals whenever price revisits an institutional imbalance according to the selected signal mode.

Additional confirmation can be added using:

• EMA Trend Filter

• Volume Confirmation

• Rejection Close Logic

These optional filters help improve signal quality while allowing traders to adapt the indicator to different market conditions and trading styles.

[b]WHY IT IS UNIQUE[/b]

Unlike many Fair Value Gap indicators that simply plot every imbalance, FVG Prime focuses on quality, flexibility, and usability.

Key features include:

• Automatic Fair Value Gap Detection

• ATR-Based Noise Filtering

• Multiple Mitigation Methods

• Consequent Encroachment (CE) Midline

• Automatic Mitigation Tracking

• Intelligent Buy & Sell Signal Engine

• EMA Trend Confirmation

• Optional Volume Confirmation

• Automatic Age-Based Fade Effect

• Fully Customizable Visual Appearance

• Automatic Active FVG Management

• Historical Mitigation Visualization

• Performance Optimized Design

• Beginner Friendly with Advanced Professional Features

The indicator is designed to provide institutional-quality Fair Value Gap analysis while maintaining a clean and organized chart.

[b]HOW USERS CAN BENEFIT FROM IT[/b]

FVG Prime can help traders:

• Identify institutional price imbalances automatically.

• Discover high-probability pullback zones.

• Improve trade timing using Fair Value Gap reactions.

• Align entries with the prevailing market trend.

• Filter weaker setups using ATR and Volume confirmation.

• Monitor whether institutional imbalances remain active or have already been mitigated.

• Reduce manual chart analysis by automating Fair Value Gap detection.

• Maintain cleaner charts through automatic zone management.

• Build consistent rule-based trading plans around Fair Value Gaps.

• Improve discipline by relying on objective detection rules instead of subjective chart interpretation.

Whether you trade stocks, forex, cryptocurrencies, commodities, or indices, FVG Prime provides a structured framework for identifying and managing institutional imbalance zones across multiple markets and timeframes.

[b]ALERTS[/b]

The indicator includes built-in alert conditions for automated monitoring and trading workflows.

Available alerts include:

• Buy Signal

• Sell Signal

• New Bullish Fair Value Gap

• New Bearish Fair Value Gap

• Bullish Fair Value Gap Mitigated

• Bearish Fair Value Gap Mitigated

These alerts can be used with TradingView Alerts and webhook integrations for notifications or automated execution systems.

DISCLAIMER

This indicator is provided for educational and informational purposes only. It does not provide financial, investment, or trading advice and should not be interpreted as a recommendation to buy or sell any financial instrument. Trading and investing involve substantial risk, and past performance does not guarantee future results. Always conduct your own analysis and apply appropriate risk management before making any trading decisions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YourUsername — All rights reserved. Replace this line with your closed-source copyright notice before publishing.

//@version=6
indicator("FVG Prime (Fair Value Gap Prime)", shorttitle = "FVG Prime", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// _________________________________________________ User Inputs _____________________________________________ \\

// ------------------------------------------ 1️⃣ FVG Detection Settings --------------------------------------- \\
grp_detect            = "1️⃣ FVG Detection"
show_bull_fvg         = input.bool(true, "Show Bullish FVG", group = grp_detect, inline = "d1")
show_bear_fvg         = input.bool(true, "Show Bearish FVG", group = grp_detect, inline = "d1")
use_gap_filter        = input.bool(true, "ATR Size Filter", group = grp_detect, inline = "d2", tooltip = "Only plot FVGs whose height is at least ATR × Multiplier. Filters out noise gaps.")
gap_atr_mult          = input.float(0.25, "× ATR", minval = 0.0, step = 0.05, group = grp_detect, inline = "d2")
atr_len               = input.int(14, "ATR Length", minval = 1, group = grp_detect)
max_active_fvg        = input.int(100, "Max FVGs On Chart", minval = 1, maxval = 100, group = grp_detect, tooltip = "Oldest FVGs are removed when the limit is reached. Keeps the chart clean and fast.")

// ------------------------------------------ 2️⃣ Mitigation Settings ------------------------------------------ \\
grp_mit               = "2️⃣ Mitigation Logic"
mitigation_mode       = input.string("Midline (CE)", "Mitigation Trigger", options = ["Touch", "Midline (CE)", "Full Fill"], group = grp_mit, tooltip = "Touch: any wick into the gap.\nMidline (CE): price crosses the Consequent Encroachment (50% level).\nFull Fill: price completely closes the gap.")
mitigated_action      = input.string("Keep (Dimmed)", "After Mitigation", options = ["Delete", "Keep (Dimmed)"], group = grp_mit)

// ------------------------------------------ 3️⃣ Signal Engine Settings --------------------------------------- \\
grp_sig               = "3️⃣ Signal Engine"
show_signals          = input.bool(true, "Show Buy / Sell Signals", group = grp_sig)
signal_mode           = input.string("Rejection Close", "Signal Trigger", options = ["First Touch", "Rejection Close"], group = grp_sig, tooltip = "First Touch: signal the moment price re-enters the gap.\nRejection Close: price dips into the gap but the candle closes back beyond it in the gap's direction (higher quality).")
use_trend_filter      = input.bool(true, "EMA Trend Filter", group = grp_sig, inline = "s1", tooltip = "Buys only above the EMA, sells only below it.")
trend_ema_len         = input.int(200, "EMA Length", minval = 1, group = grp_sig, inline = "s1")
use_vol_filter        = input.bool(false, "Volume Filter", group = grp_sig, inline = "s2", tooltip = "Signal candle volume must exceed its SMA × Multiplier.")
vol_sma_len           = input.int(20, "Vol SMA", minval = 1, group = grp_sig, inline = "s2")
vol_mult              = input.float(1.2, "× Vol", minval = 0.1, step = 0.1, group = grp_sig, inline = "s2")

// ------------------------------------------ 4️⃣ Visual Settings ---------------------------------------------- \\
grp_vis               = "4️⃣ Visuals & Styling"
bull_color            = input.color(color.new(#00E5A0, 0), "Bullish", group = grp_vis, inline = "v1")
bear_color            = input.color(color.new(#FF4D6D, 0), "Bearish", group = grp_vis, inline = "v1")
base_transparency     = input.int(78, "Box Transparency", minval = 0, maxval = 95, group = grp_vis)
use_age_fade          = input.bool(true, "Age Fade Effect", group = grp_vis, tooltip = "Boxes gently fade as they get older, giving the chart a layered, modern look.")
fade_speed            = input.int(60, "Fade Speed (bars)", minval = 10, maxval = 500, group = grp_vis)
show_midline          = input.bool(true, "Show Midline (CE)", group = grp_vis, inline = "v2")
show_border           = input.bool(true, "Show Border", group = grp_vis, inline = "v2")
extend_bars           = input.int(6, "Extend Right (bars)", minval = 0, maxval = 50, group = grp_vis)
show_labels_txt       = input.bool(true, "Show FVG Text", group = grp_vis)

// _________________________________________________ Core Calculations _______________________________________ \\

// ------------------------------------------ ATR / EMA / Volume ---------------------------------------------- \\
atr_val               = ta.atr(atr_len)
trend_ema             = ta.ema(close, trend_ema_len)
vol_sma               = ta.sma(volume, vol_sma_len)
is_uptrend            = close > trend_ema
vol_ok                = not use_vol_filter or volume > vol_sma * vol_mult

// ------------------------------------------ FVG Data Type (UDT) --------------------------------------------- \\
// Stores every property of a single Fair Value Gap so it can be tracked across bars.
type fvg_data
    box   gap_box
    line  mid_line
    float top_price
    float bottom_price
    float mid_price
    bool  is_bull
    bool  is_mitigated
    bool  signal_fired
    int   birth_bar

// ------------------------------------------ Master FVG Array ------------------------------------------------ \\
var array<fvg_data> all_fvgs = array.new<fvg_data>()

// _________________________________________________ FVG Detection ___________________________________________ \\

// ------------------------------------------ Raw Three-Candle Gap Conditions --------------------------------- \\
// Bullish FVG: current low sits above the high of two bars back (upside imbalance).
// Bearish FVG: current high sits below the low of two bars back (downside imbalance).
bull_gap_raw          = low > high[2] and close[1] > high[2]
bear_gap_raw          = high < low[2] and close[1] < low[2]

// ------------------------------------------ Gap Height Measurement ------------------------------------------ \\
bull_gap_size         = low - high[2]
bear_gap_size         = low[2] - high

// ------------------------------------------ ATR Size Filter Check ------------------------------------------- \\
size_ok_bull          = not use_gap_filter or bull_gap_size >= atr_val * gap_atr_mult
size_ok_bear          = not use_gap_filter or bear_gap_size >= atr_val * gap_atr_mult

// ------------------------------------------ Final Confirmed FVG Signals ------------------------------------- \\
new_bull_fvg          = show_bull_fvg and bull_gap_raw and size_ok_bull and barstate.isconfirmed
new_bear_fvg          = show_bear_fvg and bear_gap_raw and size_ok_bear and barstate.isconfirmed

// ------------------------------------------ Create FVG Objects ---------------------------------------------- \\
// Builds the box, midline, and data object for a newly detected gap, then stores it.
f_create_fvg(bool is_bull_gap) =>
    float gap_top     = is_bull_gap ? low : low[2]
    float gap_bottom  = is_bull_gap ? high[2] : high
    float gap_mid     = math.avg(gap_top, gap_bottom)
    color gap_color   = is_bull_gap ? bull_color : bear_color
    color bg_col      = color.new(gap_color, base_transparency)
    color border_col  = show_border ? color.new(gap_color, 40) : color.new(gap_color, 100)
    string box_txt    = show_labels_txt ? (is_bull_gap ? "FVG ▲" : "FVG ▼") : ""
    box b             = box.new(bar_index - 2, gap_top, bar_index + extend_bars, gap_bottom, border_color = border_col, border_width = 1, border_style = line.style_solid, bgcolor = bg_col, text = box_txt, text_color = color.new(gap_color, 25), text_size = size.tiny, text_halign = text.align_right, text_valign = is_bull_gap ? text.align_bottom : text.align_top)
    line l            = show_midline ? line.new(bar_index - 2, gap_mid, bar_index + extend_bars, gap_mid, color = color.new(gap_color, 55), style = line.style_dashed, width = 1) : na
    fvg_data f        = fvg_data.new(b, l, gap_top, gap_bottom, gap_mid, is_bull_gap, false, false, bar_index)
    array.push(all_fvgs, f)

// ------------------------------------------ Trigger FVG Creation -------------------------------------------- \\
if new_bull_fvg
    f_create_fvg(true)
if new_bear_fvg
    f_create_fvg(false)

// ------------------------------------------ Enforce Max FVG Limit ------------------------------------------- \\
// Removes the oldest gap once the on-chart limit is exceeded to keep the chart fast.
if array.size(all_fvgs) > max_active_fvg
    fvg_data oldest   = array.shift(all_fvgs)
    box.delete(oldest.gap_box)
    line.delete(oldest.mid_line)

// _________________________________________________ Mitigation & Signal Engine ______________________________ \\

// ------------------------------------------ Per-Bar Event Flags -------------------------------------------- \\
bool buy_signal_bar       = false
bool sell_signal_bar      = false
bool bull_mitigated_bar   = false
bool bear_mitigated_bar   = false

// ------------------------------------------ Loop Through Active FVGs ---------------------------------------- \\
if array.size(all_fvgs) > 0 and barstate.isconfirmed
    for i = array.size(all_fvgs) - 1 to 0
        fvg_data f = array.get(all_fvgs, i)
        if not f.is_mitigated and bar_index > f.birth_bar
            // ------------------------------ Signal Check (before mitigation removal) ------------------------ \\
            bool entered_gap  = f.is_bull ? low <= f.top_price : high >= f.bottom_price
            bool rejection_ok = f.is_bull ? (close > f.top_price and close > open) : (close < f.bottom_price and close < open)
            bool touch_ok     = signal_mode == "First Touch" ? entered_gap : (entered_gap and rejection_ok)
            bool trend_ok     = not use_trend_filter or (f.is_bull ? is_uptrend : not is_uptrend)
            if show_signals and not f.signal_fired and touch_ok and trend_ok and vol_ok
                f.signal_fired := true
                if f.is_bull
                    buy_signal_bar := true
                else
                    sell_signal_bar := true
            // ------------------------------ Mitigation Check ----------------------------------------------- \\
            bool mit_touch        = f.is_bull ? low <= f.top_price : high >= f.bottom_price
            bool mit_mid          = f.is_bull ? low <= f.mid_price : high >= f.mid_price
            bool mit_full         = f.is_bull ? low <= f.bottom_price : high >= f.top_price
            bool is_now_mitigated = mitigation_mode == "Touch" ? mit_touch : mitigation_mode == "Midline (CE)" ? mit_mid : mit_full
            if is_now_mitigated
                f.is_mitigated := true
                if f.is_bull
                    bull_mitigated_bar := true
                else
                    bear_mitigated_bar := true
                // -------------------------- Delete or Dim the Mitigated Gap ------------------------------- \\
                if mitigated_action == "Delete"
                    box.delete(f.gap_box)
                    line.delete(f.mid_line)
                    array.remove(all_fvgs, i)
                else
                    color dim_col = f.is_bull ? bull_color : bear_color
                    box.set_bgcolor(f.gap_box, color.new(dim_col, 93))
                    box.set_border_color(f.gap_box, color.new(dim_col, 85))
                    box.set_right(f.gap_box, bar_index)
                    if not na(f.mid_line)
                        line.set_color(f.mid_line, color.new(dim_col, 90))
                        line.set_x2(f.mid_line, bar_index)

// _________________________________________________ Box Extension & Age Fade ________________________________ \\

// ------------------------------------------ Extend Active Gaps + Fade Older Ones ---------------------------- \\
if array.size(all_fvgs) > 0
    for i = 0 to array.size(all_fvgs) - 1
        fvg_data f = array.get(all_fvgs, i)
        if not f.is_mitigated
            box.set_right(f.gap_box, bar_index + extend_bars)
            if not na(f.mid_line)
                line.set_x2(f.mid_line, bar_index + extend_bars)
            // ------------------------------ Age-Based Transparency Fade ------------------------------------ \\
            if use_age_fade
                int age         = bar_index - f.birth_bar
                int faded_trans = math.min(base_transparency + math.round(age / fade_speed * 5), 92)
                color fade_col  = f.is_bull ? bull_color : bear_color
                box.set_bgcolor(f.gap_box, color.new(fade_col, faded_trans))

// _________________________________________________ Plotting ________________________________________________ \\

// ------------------------------------------ Signal Plotting ------------------------------------------------- \\
plotshape(show_signals and buy_signal_bar, "Buy Signal", style = shape.triangleup, location = location.belowbar, color = color.new(#00E5A0, 0), size = size.small)
plotshape(show_signals and sell_signal_bar, "Sell Signal", style = shape.triangledown, location = location.abovebar, color = color.new(#FF4D6D, 0), size = size.small)

// _________________________________________________ Alerts __________________________________________________ \\
alertcondition(buy_signal_bar, "FVG Buy Signal", "FVG Prime: BUY signal — price rejected from a bullish Fair Value Gap on {{ticker}} ({{interval}})")
alertcondition(sell_signal_bar, "FVG Sell Signal", "FVG Prime: SELL signal — price rejected from a bearish Fair Value Gap on {{ticker}} ({{interval}})")
alertcondition(new_bull_fvg, "New Bullish FVG", "FVG Prime: New bullish FVG formed on {{ticker}} ({{interval}})")
alertcondition(new_bear_fvg, "New Bearish FVG", "FVG Prime: New bearish FVG formed on {{ticker}} ({{interval}})")
alertcondition(bull_mitigated_bar, "Bullish FVG Mitigated", "FVG Prime: A bullish FVG was mitigated on {{ticker}} ({{interval}})")
alertcondition(bear_mitigated_bar, "Bearish FVG Mitigated", "FVG Prime: A bearish FVG was mitigated on {{ticker}} ({{interval}})")
````
