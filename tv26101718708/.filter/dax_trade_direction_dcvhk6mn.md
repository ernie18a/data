# Dax Trade Direction

- url: https://www.tradingview.com/script/dcVhK6Mn-Dax-Trade-Direction/
- type: indicator
- pine_id: PUB;e8782f907e2f4b3b86cb1a1c6be24128
- version: 3.0

## Description

Using VWAP, EMA9, EMA21, EMA50 and ADX Info for trend definition and ideal trade direction. 
3 states: Long, Short, Wait/Chop

Built with Claude Sonnet 4.6

## Source Code

````pine
//@version=5
indicator("Dax Trend", overlay=true)

atr_len = input.int(14, "ATR Länge")
adx_len = input.int(14, "ADX Länge")

// Indikatoren
atr      = ta.atr(atr_len)
ema9     = ta.ema(close, 9)
ema21    = ta.ema(close, 21)
vwap_val = ta.vwap(close)

[_, _, adx] = ta.dmi(adx_len, adx_len)

// Preis über/unter EMA9 für mind. 2 aufeinanderfolgende Kerzen
price_above_ema9 = close[1] > ema9[1] and close[2] > ema9[2]
price_below_ema9 = close[1] < ema9[1] and close[2] < ema9[2]

// Chop
ema_vwap_high = math.max(math.max(ema9[1], ema21[1]), vwap_val[1])
ema_vwap_low  = math.min(math.min(ema9[1], ema21[1]), vwap_val[1])
is_chop       = (ema_vwap_high - ema_vwap_low) < atr[1] * 0.5

// States
bull_strong = ema9[1] > ema21[1] and price_above_ema9
bull_weak   = ema9[1] < ema21[1] and price_above_ema9
bear_strong = ema9[1] < ema21[1] and price_below_ema9
bear_weak   = ema9[1] > ema21[1] and price_below_ema9

string market_state = ""
color  bg_color     = color.gray
color  adx_color    = color.gray

if is_chop
    market_state := "CHOP"
    bg_color     := #a2a2a2
    adx_color    := #a2a2a2
else if bull_strong
    market_state := "▲ LONG"
    bg_color     := #00C800
    adx_color    := #00C800
else if bull_weak
    market_state := "▲ LONG"
    bg_color     := #78C878
    adx_color    := #78C878
else if bear_strong
    market_state := "▼ SHORT"
    bg_color     := #C80000
    adx_color    := #C80000
else if bear_weak
    market_state := "▼ SHORT"
    bg_color     := color.rgb(218, 84, 50)
    adx_color    := color.rgb(218, 84, 50)
else
    market_state := "WAIT..."
    bg_color     := #a2a2a2
    adx_color    := #a2a2a2

// ADX fett wenn > 25
adx_size = adx[1] >= 25 ? size.normal : size.small

var table t = table.new(position.middle_right, 1, 2, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, market_state,
               text_color=color.white, bgcolor=bg_color, text_size=size.normal)
    table.cell(t, 0, 1, "ADX: " + str.tostring(adx[1], "#.0"),
               text_color=color.white, bgcolor=adx_color, text_size=adx_size)
````
