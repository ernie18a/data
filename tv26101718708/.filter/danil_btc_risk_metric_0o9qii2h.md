# Danil - BTC Risk Metric

- url: https://www.tradingview.com/script/0o9QiI2H-Danil-BTC-Risk-Metric/
- type: indicator
- pine_id: PUB;477824c359714995a2e105b1de4b7629
- version: 1.0

## Description

btc ma oversold / overbought indicator

used to identity times to buy and times to sell

## Source Code

````pine
//@version=6
indicator("Danil - BTC Risk Metric", shorttitle="BTC_Risk", overlay=false)

/// ==========================================
// USER INPUTS
// ==========================================
maLength    = input.int(350,   "Base Moving Average (days)",    minval=10,
                 tooltip="Always anchored to the daily timeframe regardless of chart TF.")
src         = input.source(close, "Source")
overbought  = input.float(0.8, "Sell / High Risk Level",        step=0.05)
oversold    = input.float(0.2, "Buy / Accumulation Level",      step=0.05)
lookback    = input.int(1400,  "Normalization Lookback (days)", minval=200,
                 tooltip="Expressed in daily bars. Auto-scaled to whatever timeframe you are on.")

// ==========================================
// TIMEFRAME SCALING
// ==========================================
seconds_per_day = 86400.0
tf_mult         = timeframe.in_seconds() / seconds_per_day
lookback_tf     = math.max(10, math.round(lookback  / tf_mult))
bar_guard_tf    = math.max(10, math.round(maLength  / tf_mult))

// ==========================================
// CALCULATIONS
// ==========================================
daily_close    = request.security(syminfo.tickerid, "D", close)
daily_baseline = request.security(syminfo.tickerid, "D", ta.sma(close, maLength))

risk_raw = math.log(daily_close) - math.log(daily_baseline)

auto_min = ta.lowest(risk_raw,  lookback_tf)
auto_max = ta.highest(risk_raw, lookback_tf)

normalized_risk = math.max(0.0, math.min(1.0,
     (risk_raw - auto_min) / (auto_max - auto_min)))

safe_value = bar_index >= bar_guard_tf ? normalized_risk : na

// ==========================================
// DYNAMIC COLOR
// ==========================================
dynamic_color = color.from_gradient(safe_value, 0.0, 1.0, color.green, color.red)

// ==========================================
// PLOTS & ZONES
// ==========================================
plot(safe_value, "Risk Score", color=dynamic_color, linewidth=3)

h_top    = hline(1.0,        "Ceiling",         color=color.new(color.gray,  80), linestyle=hline.style_dotted)
h_high   = hline(overbought, "High Risk",        color=color.new(color.red,   40), linestyle=hline.style_dashed)
h_dead_h = hline(0.6,        "Dead Zone Top",    color=color.new(color.gray,  60), linestyle=hline.style_dotted)
h_dead_l = hline(0.4,        "Dead Zone Bottom", color=color.new(color.gray,  60), linestyle=hline.style_dotted)
h_mid    = hline(0.5,        "Fair Value",       color=color.new(color.gray,  50), linestyle=hline.style_solid)
h_low    = hline(oversold,   "Accumulation",     color=color.new(color.green, 40), linestyle=hline.style_dashed)
h_bottom = hline(0.0,        "Floor",            color=color.new(color.gray,  80), linestyle=hline.style_dotted)

fill(h_high,   h_top,    color.new(color.red,   90), title="Danger Zone Fill")
fill(h_dead_h, h_dead_l, color.new(color.gray,  92), title="Dead Zone Fill")
fill(h_low,    h_bottom, color.new(color.green, 90), title="Accumulation Zone Fill")

// ==========================================
// SCORE LABEL
// ==========================================
var label score_label = na
label.delete(score_label)
score_label := label.new(
     bar_index, 1.05,
     "Risk: " + str.tostring(math.round(safe_value * 100)) + "%",
     style     = label.style_label_lower_left,
     color     = dynamic_color,
     textcolor = color.white,
     size      = size.normal)

// ==========================================
// CROSSOVER CONDITIONS
// ==========================================
cross_strong_sell = ta.crossover(safe_value,  0.9)
cross_sell        = ta.crossover(safe_value,  0.5) and safe_value < 0.9
cross_buy         = ta.crossunder(safe_value, 0.4) and safe_value > 0.2
cross_strong_buy  = ta.crossunder(safe_value, 0.2)

// ==========================================
// LABELS ON INDICATOR PANE
// ==========================================
plotshape(cross_strong_sell,
     title     = "Strong Sell Label",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = color.new(color.red, 0),
     textcolor = color.white,
     text      = "STRONG SELL",
     size      = size.small)

plotshape(cross_sell,
     title     = "Sell Label",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = color.new(color.orange, 0),
     textcolor = color.white,
     text      = "SELL",
     size      = size.small)

plotshape(cross_buy,
     title     = "Buy Label",
     style     = shape.labelup,
     location  = location.absolute,
     color     = color.new(color.teal, 0),
     textcolor = color.white,
     text      = "BUY",
     size      = size.small)

plotshape(cross_strong_buy,
     title     = "Strong Buy Label",
     style     = shape.labelup,
     location  = location.absolute,
     color     = color.new(color.green, 0),
     textcolor = color.white,
     text      = "STRONG BUY",
     size      = size.small)

// ==========================================
// ALERTS
// ==========================================
alertcondition(cross_strong_sell,
     title   = "Strong Sell",
     message = "BTC risk above 0.9 — Strong Sell signal.")

alertcondition(cross_sell,
     title   = "Sell",
     message = "BTC risk crossed above 0.5 — Sell signal.")

alertcondition(cross_buy,
     title   = "Buy",
     message = "BTC risk crossed below 0.4 — Buy signal.")

alertcondition(cross_strong_buy,
     title   = "Strong Buy",
     message = "BTC risk below 0.2 — Strong Buy signal.")
````
