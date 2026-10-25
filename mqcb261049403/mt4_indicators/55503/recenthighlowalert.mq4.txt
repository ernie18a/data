//+------------------------------------------------------------------+
//|                                           RecentHighLowAlert.mq4 |
//|               Copyright © 2010-2022, https://t.me/ForexEaPremium |
//+------------------------------------------------------------------+
#property copyright "https://t.me/ForexEaPremium"
#property link      "https://t.me/ForexEaPremium"
#property version   "1.01"
#property strict

#property description "Draws lines on the High/Low of the recent N bars."
#property description "Alerts when the Bid price of the current bar crosses previous High/Low."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  clrDodgerBlue
#property indicator_type1 DRAW_LINE
#property indicator_label1 "High"
#property indicator_color2  clrYellow
#property indicator_type2 DRAW_LINE
#property indicator_label2 "Low"

#define HIGH 1
#define LOW 0

enum enum_candle_to_check
{
    Current,
    Previous
};

input int N = 20;
input bool EnableNativeAlerts = false;
input bool EnableEmailAlerts = false;
input bool EnablePushAlerts = false;
input enum_candle_to_check TriggerCandle = Previous;

double HighBuf[];
double LowBuf[];

datetime LastHighAlert = D'1970.01.01';
datetime LastLowAlert = D'1970.01.01';

void OnInit()
{
    SetIndexDrawBegin(0, N);
    SetIndexDrawBegin(1, N);

    SetIndexBuffer(0, HighBuf);
    SetIndexBuffer(1, LowBuf);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Too few bars to do anything.
    if (Bars <= N) return 0;

    int counted = IndicatorCounted();
    if (counted > 0) counted--;
    int limit = Bars - counted;
    if (limit > Bars - N - 1) limit = Bars - N - 1;

    for (int i = 0; i < limit; i++)
    {
        HighBuf[i] = High[iHighest(NULL, 0, MODE_HIGH, N, i)];
        LowBuf[i] = Low[iLowest(NULL, 0, MODE_LOW, N, i)];
    }

    if ((Bid > HighBuf[TriggerCandle]) && (LastHighAlert != Time[0])) SendAlert(HIGH, HighBuf[TriggerCandle]);
    else if ((Bid < LowBuf[TriggerCandle]) && (LastLowAlert != Time[0])) SendAlert(LOW, LowBuf[TriggerCandle]);

    return rates_total;
}

//+------------------------------------------------------------------+
//| Issues alerts and remembers the last sent alert time.            |
//+------------------------------------------------------------------+
void SendAlert(int direction, double price)
{
    string alert = "Local " + Symbol() + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " ";
    string subject;

    if (direction == HIGH)
    {
        alert = alert + "high";
        subject = "High broken @ " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7);
        LastHighAlert = Time[0];
    }
    else if (direction == LOW)
    {
        alert = alert + "low";
        subject = "Low broken @ " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7);
        LastLowAlert = Time[0];
    }
    alert = alert + " broken at " + DoubleToString(price, Digits) + ".";

    if (EnableNativeAlerts) Alert(alert);
    if (EnableEmailAlerts) SendMail(subject, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + " " + alert);
    if (EnablePushAlerts) SendNotification(alert);
}
//+------------------------------------------------------------------+