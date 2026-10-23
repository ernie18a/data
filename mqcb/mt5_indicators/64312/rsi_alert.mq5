
#property copyright   "Duy Van Nguy " 
#property link        ""
#property description "RSI Alert"
#property version     "1.0"
#property indicator_chart_window

input ENUM_TIMEFRAMES TimeFrame       = PERIOD_M15;  //Timeframe to use for RSI
input int             RSI_HIGH        = 75;         //RSI high used for alert
input int             RSI_LOW         = 25;         //RSI low used for alert
input bool            UseAlert        = true;       //Show pop up alert
input bool            UseNotification = true;       //Send alert to phone

int      rsiHandle;
datetime LastBarTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Check if symbol exists and has data
   if(!SymbolInfoInteger(_Symbol, SYMBOL_SELECT))
     {
      Print("Symbol ", _Symbol, " not found or not selected in Market Watch");
      return(INIT_FAILED);
     }
   
   // Try to load historical data
   if(iBars(_Symbol, TimeFrame) < 20)
     {
      Print("Not enough bars for ", _Symbol, " on timeframe ", EnumToString(TimeFrame));
      return(INIT_FAILED);
     }
   
   // Create RSI handle for current symbol
   rsiHandle = iRSI(_Symbol, TimeFrame, 14, PRICE_CLOSE);
   
   if(rsiHandle == INVALID_HANDLE)
     {
      Print("Error creating RSI indicator for ", _Symbol);
      return(INIT_FAILED);
     }
   
   Comment("RSI Scanner running on ", _Symbol);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
   
   Comment("");
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
   // Check if we have enough data
   if(rates_total < 20)
      return(0);
   
   // Check for new bar on current symbol
   datetime currentBarTime = iTime(_Symbol, TimeFrame, 0);
   
   if(currentBarTime == 0)
      return(rates_total);
   
   if(LastBarTime != currentBarTime)
     {
      double rsi = GetRSI(rsiHandle, 0);
      
      // Skip if RSI value is invalid
      if(rsi > 0 && rsi != EMPTY_VALUE)
        {
         if(rsi >= RSI_HIGH)
           {
            if(UseAlert)
               Alert("RSI HIGH: ", _Symbol, " | RSI: ", DoubleToString(rsi, 2), " | Timeframe: ", EnumToString(TimeFrame));
            if(UseNotification)
               SendNotification("RSI HIGH: " + _Symbol + " | RSI: " + DoubleToString(rsi, 2) + " | Timeframe: " + EnumToString(TimeFrame));
           }
         
         if(rsi <= RSI_LOW)
           {
            if(UseAlert)
               Alert("RSI LOW: ", _Symbol, " | RSI: ", DoubleToString(rsi, 2), " | Timeframe: ", EnumToString(TimeFrame));
            if(UseNotification)
               SendNotification("RSI LOW: " + _Symbol + " | RSI: " + DoubleToString(rsi, 2) + " | Timeframe: " + EnumToString(TimeFrame));
           }
        }
      
      LastBarTime = currentBarTime;
     }
   
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Get RSI Value from handle                                        |
//+------------------------------------------------------------------+
double GetRSI(int handle, int shift)
  {
   if(handle == INVALID_HANDLE)
      return(0);
   
   double rsi[];
   ArraySetAsSeries(rsi, true);
   
   if(CopyBuffer(handle, 0, shift, 1, rsi) <= 0)
      return(0);
   
   return(rsi[0]);
  }
//+------------------------------------------------------------------+