//+------------------------------------------------------------------+
//|                                           RecentHighLowAlert.mq5 |
//|               Copyright © 2010-2022, https://t.me/ForexEaPremium |
//+------------------------------------------------------------------+
#property copyright "https://t.me/ForexEaPremium"
#property link      "https://t.me/ForexEaPremium"
#property version   "1.01"

#property description "Draws lines on the High/Low of the recent N bars."
#property description "Alerts when the Bid price of the current bar crosses previous High/Low."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_color1 clrDodgerBlue
#property indicator_type1 DRAW_LINE
#property indicator_label1 "High"
#property indicator_color2 clrYellow
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
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, N);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, N);

    SetIndexBuffer(0, HighBuf, INDICATOR_DATA);
    SetIndexBuffer(1, LowBuf, INDICATOR_DATA);
}


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    if (rates_total <= N) return 0;

    // Skip calculated bars
    int start = prev_calculated - 1;
    // First run
    if (start < N) start = N;

    for (int i = start; i < rates_total; i++)
    {
        HighBuf[i] = High[ArrayMaximum(High, i - N + 1, N)];
        LowBuf[i] = Low[ArrayMinimum(Low, i - N + 1, N)];
    }

    double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    if ((Bid > HighBuf[rates_total - 1 - TriggerCandle]) && (LastHighAlert != Time[rates_total - 1])) SendAlert(HIGH, HighBuf[rates_total - 1 - TriggerCandle], Time[rates_total - 1]);
    else if ((Bid < LowBuf[rates_total - 1 - TriggerCandle]) && (LastLowAlert != Time[rates_total - 1])) SendAlert(LOW, LowBuf[rates_total - 1 - TriggerCandle], Time[rates_total - 1]);

    return rates_total;
}

//+------------------------------------------------------------------+
//| Issues alerts and remembers the last sent alert time.            |
//+------------------------------------------------------------------+
void SendAlert(int direction, double price, datetime time)
{
    string alert = "Local ";
    string subject;

    if (direction == HIGH)
    {
        alert = alert + "high";
        subject = "High broken @ " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7);
        LastHighAlert = time;
    }
    else if (direction == LOW)
    {
        alert = alert + "low";
        subject = "Low broken @ " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7);
        LastLowAlert = time;
    }
    alert = alert + " broken at " + DoubleToString(price, _Digits) + ".";

    if (EnableNativeAlerts) Alert(alert);
    if (EnableEmailAlerts) SendMail(subject, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + " " + alert);
    if (EnablePushAlerts) SendNotification(subject + " @ " + DoubleToString(price, _Digits));
}
//+------------------------------------------------------------------+