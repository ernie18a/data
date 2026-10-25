//+------------------------------------------------------------------+
//|                        Alert Crossing Moving Average Nth Bar.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Alert when crossing the indicator Moving Average N-th bar"
#property description "---"
#property description "Play sound: The file must be located in terminal_directory \\Sounds or its sub-directory. Only WAV files are played"
#property description "---"
#property description "Send mail: Sends an email at the address specified in the settings window of the \"Email\" tab"
#property description "---"
#property description "Send notification: Sends push notifications to mobile terminals, whose MetaQuotes ID are specified in the \"Notifications\" tab"
#property indicator_chart_window
#property indicator_plots 0
//--- input parameters
input int                  ma_period      = 10;          // period of ma 
input int                  ma_shift       = 0;           // shift 
input ENUM_MA_METHOD       ma_method      = MODE_SMA;    // type of smoothing 
input ENUM_APPLIED_PRICE   applied_price  = PRICE_CLOSE; // type of price 
input bool                 InpSound       = true;        // Play sound
input string               sound_filename = "wait.wav";  // Play sound file name
input bool                 InpMail        = true;        // Send mail
input bool                 InpNotification= true;        // Send notification
input uint                 InpN_Bar       = 1;           // N bar
//---
int                        handle_iMA;                   // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),ma_period,ma_shift,ma_method,applied_price);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   if(MQLInfoInteger(MQL_DEBUG))/* || MQLInfoInteger(MQL_VISUAL_MODE))*/
      ChartIndicatorAdd(0,0,handle_iMA);
//---
   return(INIT_SUCCEEDED);
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
//---
   if(prev_calculated==0)
      return(rates_total);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
//---
   static datetime   alert_current_bar = 0;
   static datetime   PrevBars          = 0;
   if(time[0]==PrevBars)
      return(rates_total);
   PrevBars=time[0];

   if(time[0]==alert_current_bar)
      return(rates_total);

   double ima_bar_N=iMAGet(InpN_Bar);
   if(ima_bar_N==0.0)
     {
      PrevBars=time[1];
      return(rates_total);
     }

   if((open[InpN_Bar]<ima_bar_N && close[InpN_Bar]>ima_bar_N) || (open[InpN_Bar]>ima_bar_N && close[InpN_Bar]<ima_bar_N))
     {
      alert_current_bar=time[0];
      if(InpSound)
         PlaySound(sound_filename);
      string  subject   = "Crossing "+IntegerToString(InpN_Bar)+" bar";
      string  some_text = Symbol()+", "+EnumToString(Period())+". "+
                         "MA("+IntegerToString(ma_period)+")"+" crossing "+IntegerToString(InpN_Bar)+" bar";
      if(InpMail)
         SendMail(subject,some_text);
      if(InpNotification)
         SendNotification(some_text);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
