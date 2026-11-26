# Heikin Ashi Trend Signal | Astral Vision 

- url: https://www.tradingview.com/script/sKBwwFqP/
- type: indicator
- pine_id: PUB;8a4a8d6851a34086ba04d492e50b7ef0
- version: 2.0

## Description

[b]Heikin Ashi HTF Signal | Astral Vision 🌠💠[/b]

Heikin Ashi candles average OHLC data in a specific way that smooths price action and filters noise from individual bars, making trend direction visually cleaner than standard candlesticks. Traders have long used monthly and weekly Heikin Ashi charts as macro trend filters, but always at the cost of switching away from the standard candlestick chart where actual entries are planned and executed. 
This indicator eliminates that tradeoff entirely: the Heikin Ashi trend signal is computed on the monthly or weekly timeframe and projected directly onto the standard candlestick chart through candle coloring, making the higher-timeframe regime visible without ever leaving the daily view.

A bullish Heikin Ashi candle on the monthly or weekly timeframe represents a sustained period where the averaged price structure closed above its averaged open, a condition that historically persists across multiple daily bars before reversing, making it one of the cleanest macro trend filters available.

[b]Calculation ⚙️[/b]

`HA Close = (Open + High + Low + Close) / 4`

`HA Open = (HA Open[1] + HA Close[1]) / 2`

`HA High = max(High, HA Open, HA Close)`

`HA Low  = min(Low,  HA Open, HA Close)`

The HA Open is initialized on the first bar as the midpoint of the raw open and close, then updated only on the first bar of each new HTF period, preserving the correct Heikin Ashi carry-forward logic without repainting on intermediate daily bars.

[b]Plots 📊[/b]
[list]
[*]Heikin Ashi candles in the indicator panel at the selected HTF resolution, with transparent bodies and colored borders to emphasize direction over magnitude
[*]Panel background highlight by HA trend direction (bullish or bearish)
[*]Daily candle coloring on the price chart by the current HTF HA regime
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Timeframe`: Monthly or Weekly resolution for the Heikin Ashi calculation
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Paradiso. Positive color applies during bullish HA regimes; negative color applies during bearish HA regimes. HA candle bodies are rendered fully transparent to keep the focus on border color and trend direction rather than individual bar magnitude.

[b]Purpose 🎯[/b]

The standard workflow for using Heikin Ashi as a macro trend filter has always required switching between two separate charts: the HA chart on the monthly or weekly timeframe to read the trend, then back to the standard candlestick chart to evaluate entries. 
There was no native way in TradingView to carry the HA signal across, the two chart types are mutually exclusive, and overlaying HTF Heikin Ashi data on a standard candle chart required custom reconstruction from scratch.

This indicator solves that directly. By computing the monthly or weekly Heikin Ashi values natively, including the correct carry-forward open logic, and applying the resulting bull/bear regime as candle coloring on the daily price chart, it makes the HTF Heikin Ashi trend continuously readable without ever switching charts or timeframes. The HA panel serves as a reference for the macro structure; the colored daily candles make the regime immediately actionable at the entry timeframe. The two views are always in sync, always on the same screen.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Heikin Ashi Trend Signal | Astral Vision 🌠💠", overlay=false)

string group1 = "Settings"
string group2 = "Astral Colors"

string tf_mode    = input.string("Monthly", "Timeframe", options=["Monthly","Weekly"], group=group1)
bool   no_repaint = input.bool(false, "No Repaint (confirmed bar only)", group=group1)

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)   :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

string tf         = tf_mode == "Monthly" ? "M" : "W"
string htf_ticker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)

[m_open, m_high, m_low, m_close] = request.security(
     htf_ticker, tf,
     [open, high, low, close],
     barmerge.gaps_off, barmerge.lookahead_on)

bool new_bar = ta.change(time(tf)) != 0

var float ha_open_calc  = float(na)
var float ha_close_calc = float(na)

float ha_close = (m_open + m_high + m_low + m_close) / 4

if na(ha_open_calc)
    ha_open_calc  := (m_open + m_close) / 2
    ha_close_calc := ha_close
else if new_bar
    ha_open_calc  := (ha_open_calc[1] + ha_close_calc[1]) / 2
    ha_close_calc := ha_close

float ha_high = math.max(m_high, math.max(ha_open_calc, ha_close))
float ha_low  = math.min(m_low,  math.min(ha_open_calc, ha_close))

f_ha_confirmed() =>
    var float c_open  = float(na)
    var float c_close = float(na)
    float hac = (open + high + low + close) / 4
    if na(c_open)
        c_open  := (open + close) / 2
        c_close := hac
    else
        c_open  := (c_open[1] + c_close[1]) / 2
        c_close := hac
    c_close[1] >= c_open[1]

bool is_bull_confirmed = request.security(htf_ticker, tf, f_ha_confirmed(),
     barmerge.gaps_off, barmerge.lookahead_on)

bool is_bull_live = ha_close >= ha_open_calc
bool is_bull      = no_repaint ? is_bull_confirmed : is_bull_live

color ha_col     = is_bull ? pos_col : neg_col
color ha_body    = is_bull ? color.new(pos_col, 100) : color.new(neg_col, 100)
color candle_col = is_bull ? pos_col : neg_col

plotcandle(ha_open_calc, ha_high, ha_low, ha_close, "HA Signal",
     ha_body, ha_body, bordercolor=ha_col)

bgcolor(is_bull ? color.new(pos_col, 85) : color.new(neg_col, 85))

plotcandle(open, high, low, close, "Daily Candles",
     candle_col, candle_col,
     bordercolor=candle_col,
     force_overlay=true)
````
