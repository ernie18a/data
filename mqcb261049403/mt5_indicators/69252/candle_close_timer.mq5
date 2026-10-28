//+------------------------------------------------------------------+
//| Candle Close Timer - MT5 Indicator                               |
//| Shows remaining time to candle close above current candle        |
//| Author: BENTRADE TRADING                                         |
//+------------------------------------------------------------------+
#property strict
#property copyright "BENTRADE TRADING,2026 ©"
#property link      "https://payhip.com/BENTRADETrading"
#property version   "1.0"

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Inputs for customization
input color   TimerColor = clrLime;   // Text color
input int     FontSize   = 12;        // Font size

string label_name = "CandleCloseTimer";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
int OnInit()
{
   EventSetTimer(1); // update every second
   
   if(!ObjectCreate(0,label_name,OBJ_TEXT,0,0,0))
      return(INIT_FAILED);

   ObjectSetInteger(0, label_name, OBJPROP_COLOR, TimerColor);
   ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, label_name, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0,label_name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0,label_name);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
void OnTimer()
{
   datetime candle_open = iTime(_Symbol,_Period,0);
   int tf_seconds = PeriodSeconds(_Period);
   datetime candle_close = candle_open + tf_seconds;
   int remaining = (int)(candle_close - TimeCurrent());

   ObjectSetInteger(0, label_name, OBJPROP_COLOR, TimerColor);
   ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, FontSize);

   if(remaining < 0) remaining = 0;

   int minutes = remaining / 60;
   int seconds = remaining % 60;

   string text = StringFormat("%02d:%02d",minutes,seconds);

   double price = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   ObjectMove(0, label_name, 0, TimeCurrent() + (datetime)MathRound(PeriodSeconds(_Period)/0.4), price - (_Point*10)); 

   ObjectSetString(0,label_name,OBJPROP_TEXT,text);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
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
   return(rates_total);
}
//+------------------------------------------------------------------+
