//+-------------------------------------------------------------------+
//|                                     wd.Multi_ClockPrice lite!.mq5 |
//|                 Copyright © 2024, Karya Prima Rajasa Mediavestama |
//|                                  Programmed by widhie75@yahoo.com |
//+-------------------------------------------------------------------+
#property copyright   "Copyright © 2024, Karya Prima Rajasa Mediavestama."
#property link        "https://www.mql5.com/en/code/47847"
#property version     "2.24"
#property description "The 'wd.Multi_ClockPrice lite!' is the lite version of 'wd.Multi_ClockPrice'."
#property description "Provides visual representation of server time and bid prices on the chart."
#property description "It synchronizes with PC clock every seconds, allowing seamless updates even when MT5 is offline."
#property description "Real-time bid prices are displayed, efficiently meeting the need for price information."
#property description "Place informational labels in the specified sub-window, adjusting positions as needed."
#property strict

#property indicator_chart_window
#property indicator_plots 0

//--- Input parameters
input int   SubWindow         = 0;        // Sub-Window placement
input int   YDist             = 10;        // Y-Position label
input string   Comment1="===== Server Clock Settings =======";       //=======================
input color FontSvrClockColor = clrOrange;   // Font color 
input int   increment         = 1;        // Seconds incremented
input string   Comment2="======= Bid Price Settings =======";       //=======================
input color FontPriceColor    = clrLime; // Font color

//--- Global variables
int labelServerClockHandle; // Handle for the Server Clock label
int labelPriceHandle;       // Handle for the Price label

//+-------------------------------------------------------------------+
//| Function to create a label in a separate sub-window               |
//+-------------------------------------------------------------------+
void CreateLabelInSubWindow(int subWindowNumber)
{
   //--- Create label for 'MT5 Server Clock' in the specified sub-window
   labelServerClockHandle = ObjectCreate(0, "MT5ServerClock", OBJ_LABEL, subWindowNumber, 0, 0);
   ObjectSetInteger(0, "MT5ServerClock", OBJPROP_COLOR, FontSvrClockColor);
   ObjectSetInteger(0, "MT5ServerClock", OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, "MT5ServerClock", OBJPROP_XDISTANCE, 2);
   ObjectSetInteger(0, "MT5ServerClock", OBJPROP_YDISTANCE, YDist);
   ObjectSetString(0, "MT5ServerClock", OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, "MT5ServerClock", OBJPROP_TEXT, "Server time: ");
   
   //--- Create label for 'Price' in the specified sub-window
   labelPriceHandle = ObjectCreate(0, "Price", OBJ_LABEL, subWindowNumber, 0, 0);
   ObjectSetInteger(0, "Price", OBJPROP_COLOR, FontPriceColor);
   ObjectSetInteger(0, "Price", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "Price", OBJPROP_XDISTANCE, 2);
   ObjectSetInteger(0, "Price", OBJPROP_YDISTANCE, YDist+13);
   ObjectSetString(0, "Price", OBJPROP_FONT, "Arial Black");
   ObjectSetString(0, "Price", OBJPROP_TEXT, "Bid price: ");
}

//+-------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+-------------------------------------------------------------------+
int OnInit()
{
   //--- Specify the sub-window number where the label should be placed
   int subWindowNumber = SubWindow;

   //--- Initialize the label in the specified sub-window
   CreateLabelInSubWindow(subWindowNumber);

   //--- Create a timer with a 1-second period
   EventSetTimer(1);

   return (INIT_SUCCEEDED);
}

//+-------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+-------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Delete all labels and kill the timer
   ObjectDelete(0, "MT5ServerClock");
   ObjectDelete(0, "Price");
   EventKillTimer();
}

//+-------------------------------------------------------------------+
//| Custom timer event function                                       |
//+-------------------------------------------------------------------+
void OnTimer()
{
   //--- Set server time and increment/adjust to the current server time
   static datetime calculated_server_time = 0;
   calculated_server_time = TimeTradeServer() + increment;

   //--- Display counter values on the chart
   string counterMT5ServerClock = StringFormat("Server time: %s\r\n", TimeToString(calculated_server_time, TIME_MINUTES | TIME_SECONDS));
   ObjectSetString(0, "MT5ServerClock", OBJPROP_TEXT, counterMT5ServerClock);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
    //--- Get the bid price
    double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    //--- Set the bid price in the 'Price' label
    ObjectSetString(0, "Price", OBJPROP_TEXT, StringFormat("Bid price: %s", DoubleToString(bidPrice, Digits())));

    //--- Return the total number of bars
    return (rates_total);
}
