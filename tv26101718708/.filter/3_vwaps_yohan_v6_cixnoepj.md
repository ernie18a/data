# 3 VWAPS Yohan v6

- url: https://www.tradingview.com/script/CIXnOEpj-3-VWAPS-Yohan-v6/
- type: indicator
- pine_id: PUB;3bb82de0420d4bf3a395b1938ef7c9c2
- version: 1.0

## Description

3 VWAPS Yohan v6

This includes monthly, weekly, yesterday anchored vwaps

## Source Code

````pine
//@version=6
indicator("Anchored VWAPs for Futures", shorttitle="3 VWAPs v6", overlay=true)

// Inputs
bool show_daily = input.bool(true, title="Show Daily VWAP (anchored 6:00pm ET)")

// Source for VWAP calculation
src = hlc3

// Detect new session start at 18:00 ET (which is 17:00 CT in chart timezone)
bool new_day = (hour == 17 and minute == 0)

// Offset to calculate trading day time (7 hours in ms to shift to next midnight in CT)
int offset = 25200000

// Variables for Monthly VWAP
var float month_vol = 0.0
var float month_pv  = 0.0
var float month_sq  = 0.0
var int   last_td_month = na

// Variables for Weekly VWAP
var float week_vol = 0.0
var float week_pv  = 0.0

// Variables for Yesterday VWAP
var float yest_vol = 0.0
var float yest_pv  = 0.0

// Helper variables for daily (current session)
var float daily_vol = 0.0
var float daily_pv  = 0.0

if new_day
    int td_time    = time + offset
    int td_month   = month(td_time)
    int td_weekday = dayofweek(td_time)

    // Reset monthly if new trading month
    if na(last_td_month) or td_month != last_td_month
        month_vol       := 0.0
        month_pv        := 0.0
        month_sq        := 0.0
        last_td_month   := td_month

    // Reset weekly if starting Monday's session
    if td_weekday == 2
        week_vol := 0.0
        week_pv  := 0.0

    // Shift for yesterday: copy previous daily to yesterday
    yest_vol := daily_vol
    yest_pv  := daily_pv

    // Reset daily
    daily_vol := 0.0
    daily_pv  := 0.0

// Accumulate on every bar for all VWAPs
month_vol += volume
month_pv  += src * volume
month_sq  += src * src * volume
week_vol  += volume
week_pv   += src * volume
daily_vol += volume
daily_pv  += src * volume

// Calculate VWAP values
float month_vwap = month_vol > 0 ? month_pv / month_vol : na
float week_vwap  = week_vol  > 0 ? week_pv  / week_vol  : na
float yest_vwap  = (yest_vol + daily_vol) > 0 ? (yest_pv + daily_pv) / (yest_vol + daily_vol) : na
float daily_vwap = daily_vol > 0 ? daily_pv / daily_vol : na

// Calculate monthly standard deviation
float month_var = month_vol > 0 ? (month_sq / month_vol) - math.pow(month_vwap, 2) : na
float month_std = math.sqrt(month_var)

// Calculate monthly bands
float month_u1 = month_vwap + month_std
float month_l1 = month_vwap - month_std
float month_u2 = month_vwap + 2.0 * month_std
float month_l2 = month_vwap - 2.0 * month_std
float month_u3 = month_vwap + 3.0 * month_std
float month_l3 = month_vwap - 3.0 * month_std

// Plot the VWAP lines
plot(month_vwap,                   color=color.blue,   title="Monthly AVWAP",   linewidth=2)
plot(week_vwap,                    color=color.green,  title="Weekly AVWAP",    linewidth=2)
plot(yest_vwap,                    color=color.red,    title="Yesterday AVWAP", linewidth=2)
plot(show_daily ? daily_vwap : na, color=color.yellow, title="Daily AVWAP",     linewidth=2)

// Plot monthly standard deviation bands
plot(month_u1, color=color.blue,   title="Monthly Upper 1", linewidth=1)
plot(month_l1, color=color.blue,   title="Monthly Lower 1", linewidth=1)
plot(month_u2, color=color.purple, title="Monthly Upper 2", linewidth=1)
plot(month_l2, color=color.purple, title="Monthly Lower 2", linewidth=1)
plot(month_u3, color=color.orange, title="Monthly Upper 3", linewidth=1)
plot(month_l3, color=color.orange, title="Monthly Lower 3", linewidth=1)
````
