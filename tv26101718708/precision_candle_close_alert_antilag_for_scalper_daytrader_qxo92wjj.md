# Precision Candle Close Alert [Anti-Lag] for Scalper & Daytrader

- url: https://www.tradingview.com/script/QXo92Wjj/
- type: indicator
- pine_id: PUB;bac20b0030c54d31be42b1e4c73af1e3
- version: 4.0

## Description

As a scalper or day trader, timing is everything. Standard TradingView alerts often fire 2-3 seconds after the candle has closed due to tick-dependency and server lag. If you are trading the 1m or 5m chart, that delay can cost you money.

The Candle Close Alert (CCA) solves this problem. It is designed for absolute precision and includes a built-in "Anti-Lag" feature. This allows you to trigger the alert slightly before the actual close. By the time the push notification or sound reaches your device, the candle is closing at that exact millisecond.

Key Features:

⚡ Anti-Lag Offset: Compensate for server delays by firing the alert a customizable number of seconds (e.g., 2s) before the candle actually closes.

🎯 True Close Only: Uses strict condition matching to ensure the alert NEVER fires randomly in the middle of a candle. It only triggers on the exact target close.

🔢 Custom Alert Limit: Set a maximum number of alerts (e.g., alert me for the next 5 closes, then automatically stop).

🔄 One-Click Reset: Easily reset the alert counter directly from the indicator settings without having to delete and recreate the alert.

⏱️ Multi-Timeframe Support: Select your target timeframe (from 1m up to Monthly) independently of your current chart resolution.

How to set it up correctly:

Add the indicator to your chart. (Note: Your chart timeframe must be equal to or lower than your selected alert timeframe).

Open the indicator settings and set your target timeframe, the max alert count, and the Anti-Lag Offset (2 to 3 seconds is the recommended sweet spot).

Open the TradingView Alert Menu (clock icon) and click "Create Alert".

Condition: Select "Candle Close Alert" -> "Any alert() function call".

Go to the "Notifications" tab, check "Play Sound", and select a specific sound for this alert.

Click "Create".

Note: Because Pine Script triggers on price ticks, the anti-lag feature will fire on the first tick that occurs within your defined pre-close window.

Tags:
#Scalping #DayTrading #Alerts #CandleClose #Precision #Forex #Crypto #Utility

## Source Code

````pine
//@version=6
indicator("Candle Close Alert", shorttitle="CCA", overlay=true)

// =========================================================================
// INPUTS (Settings)
// =========================================================================
grp_settings = "Alert Settings"

// Timeframe selection
i_tf = input.timeframe("15", title="Candle Timeframe", group=grp_settings, options=["1", "5", "15", "30", "60", "240", "D", "W", "M"])

// Anti-Lag Offset
i_early_sec = input.int(2, title="Anti-Lag (Seconds Before Close)", group=grp_settings, minval=0, tooltip="Fires the alert X seconds before the real close to compensate for server lag.")

// Alert count logic
i_unlimited = input.bool(true, title="Unlimited Alerts", group=grp_settings, tooltip="Check this to let the alert run forever. Uncheck to use a specific Max Alert Count.")
i_max_alerts = input.int(5, title="Max Alert Count", group=grp_settings, minval=1, tooltip="Only active if 'Unlimited Alerts' is unchecked.")
i_reset = input.bool(false, title="Reset Alert Counter", group=grp_settings, tooltip="Toggle this checkbox to reset the counter back to 0.")


// =========================================================================
// VARIABLES
// =========================================================================
var int alert_counter = 0
var bool last_reset_state = false
var int last_alert_close_time = 0 

if i_reset != last_reset_state
    alert_counter := 0
    last_reset_state := i_reset


// =========================================================================
// LOGIC
// =========================================================================
// Berechnet den Zeitpunkt, wann die Ziel-Kerze schließt
tf_close_time = time_close(i_tf)

// Berechnet die verbleibende Zeit in Sekunden (Serverzeit - Aktuelle Zeit)
time_left_sec = (tf_close_time - timenow) / 1000

// Bedingung: Live-Markt, im Zeitfenster, noch nicht für diese Kerze ausgelöst
bool trigger_condition = barstate.isrealtime and (time_left_sec <= i_early_sec) and (time_left_sec >= 0) and (tf_close_time != last_alert_close_time)

if trigger_condition
    // Prüft, ob Unlimited an ist ODER das Limit noch nicht erreicht wurde
    if i_unlimited or (alert_counter < i_max_alerts)
        
        // Counter erhöhen und Zeitstempel speichern
        alert_counter += 1
        last_alert_close_time := tf_close_time
        
        // Dynamische Nachricht generieren, je nachdem ob Unlimited an oder aus ist
        string alert_msg = "Candle Closed! Timeframe: " + i_tf 
        if i_unlimited
            alert_msg += " | Alert: " + str.tostring(alert_counter) + " (Unlimited)"
        else
            alert_msg += " | Alert: " + str.tostring(alert_counter) + " of " + str.tostring(i_max_alerts)
        
        // Alarm auslösen
        alert(alert_msg, alert.freq_once_per_bar)
````
