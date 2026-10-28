//+------------------------------------------------------------------+
//|                          Two Stochastic Custom Filling Alert.mq5 |
//|                              Copyright © 2021, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43516 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43516"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_plots   3
//--- plot STO Fast
#property indicator_label1  "STO Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSpringGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot STO Slow
#property indicator_label2  "STO Slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Filling
#property indicator_label3  "Filling"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'236,236,255',C'255,236,236'
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input group             "Stochastic Fast"
input int                  Inp_STO_Fast_Kperiod       = 5;              // Stochastic Fast: K-period (number of bars for calculations)
input int                  Inp_STO_Fast_Dperiod       = 3;              // Stochastic Fast: D-period (period of first smoothing)
input int                  Inp_STO_Fast_slowing       = 3;              // Stochastic Fast: final smoothing
input ENUM_MA_METHOD       Inp_STO_Fast_ma_method     = MODE_SMA;       // Stochastic Fast: type of smoothing
input ENUM_STO_PRICE       Inp_STO_Fast_price_field   = STO_LOWHIGH;    // Stochastic Fast: stochastic calculation method
input group             "Stochastic Slow"
input int                  Inp_STO_Slow_Kperiod       = 50;             // Stochastic Slow: K-period (number of bars for calculations)
input int                  Inp_STO_Slow_Dperiod       = 30;             // Stochastic Slow: D-period (period of first smoothing)
input int                  Inp_STO_Slow_slowing       = 30;             // Stochastic Slow: final smoothing
input ENUM_MA_METHOD       Inp_STO_Slow_ma_method     = MODE_SMA;       // Stochastic Slow: type of smoothing
input ENUM_STO_PRICE       Inp_STO_Slow_price_field   = STO_LOWHIGH;    // Stochastic Slow: stochastic calculation method
input group             "Stochastic Levels"
input double               Inp_STO_Level1             = 25.0;           // Value Level #1 (25)
input double               Inp_STO_Level2             = 75.0;           // Value Level #2 (75)
input group             "Alerts"
input string               InpSoundName               = "alert.wav"; // Sound Name
input uchar                InpSoundRepetitions        = 3;           // Repetitions
input uchar                InpSoundPause              = 3;           // Pause, in seconds
input bool                 InpUseSound                = false;       // Use Sound
input bool                 InpUseAlert                = true;        // Use Alert
input bool                 InpUseMail                 = true;        // Use Send mail
input bool                 InpUseNotification         = true;        // Use Send notification
//--- indicator buffer
double   StochFastMainBuffer[];
double   StochSlowMainBuffer[];
double   FillingBuffer1[];
double   FillingBuffer2[];
//---
int      handle_iStochastic_Fast;               // variable for storing the handle of the iStochastic indicator
int      handle_iStochastic_Slow;               // variable for storing the handle of the iStochastic indicator
//---
int      bars_calculated   = 0;                 // we will keep the number of values in the Stochastic Oscillator indicator
bool     m_init_error      = false;             // error on InInit
//--- alert
datetime m_last_sound      = 0;        // "0" -> D'1970.01.01 00:00';
uchar    m_repetitions     = 0;        //
string   m_text            = "";       //
datetime m_prev_bars       = 0;        // "0" -> D'1970.01.01 00:00';
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- forced initialization of variables
   m_init_error            = false;             // error on InInit
//--- indicator buffers mapping
   SetIndexBuffer(0,StochFastMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,StochSlowMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,FillingBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,FillingBuffer2,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_STO_Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_STO_Level2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_STO_Slow_Kperiod+Inp_STO_Slow_Dperiod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Inp_STO_Slow_Kperiod+Inp_STO_Slow_Dperiod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,Inp_STO_Slow_Kperiod+Inp_STO_Slow_Dperiod);
//IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_CANDLES("+symbol+")");
//--- create handle of the indicator iStochastic
   handle_iStochastic_Fast=iStochastic(Symbol(),Period(),
                                       Inp_STO_Fast_Kperiod,Inp_STO_Fast_Dperiod,Inp_STO_Fast_slowing,
                                       Inp_STO_Fast_ma_method,Inp_STO_Fast_price_field);
//--- if the handle is not created
   if(handle_iStochastic_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iStochastic ('Fast') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic_Slow=iStochastic(Symbol(),Period(),
                                       Inp_STO_Slow_Kperiod,Inp_STO_Slow_Dperiod,Inp_STO_Slow_slowing,
                                       Inp_STO_Slow_ma_method,Inp_STO_Slow_price_field);
//--- if the handle is not created
   if(handle_iStochastic_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iStochastic ('Slow') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
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
   if(m_init_error)
      return(0);
//--- number of values copied from the iStochastic indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_fast=BarsCalculated(handle_iStochastic_Fast);
   if(calculated_fast<=0)
     {
      PrintFormat("BarsCalculated(handle_iStochastic_Fast) returned %d, error code %d",calculated_fast,GetLastError());
      return(0);
     }
//--- determine the number of values calculated in the indicator
   int calculated_slow=BarsCalculated(handle_iStochastic_Fast);
   if(calculated_slow<=0)
     {
      PrintFormat("BarsCalculated(handle_iStochastic_Fast) returned %d, error code %d",calculated_slow,GetLastError());
      return(0);
     }
   if(calculated_fast!=calculated_slow)
     {
      PrintFormat("BarsCalculated(handle_iStochastic_Fast) returned %d, BarsCalculated(handle_iStochastic_Fast) returned %d",calculated_fast,calculated_slow);
      return(0);
     }
   int calculated=calculated_fast;
//--- if it is the first start of calculation of the indicator or if the number of values in the iStochastic indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the StochasticBuffer array is greater than the number of values in the iStochastic indicator for symbol/period, then we don't copy everything
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the arrays with values of the iStochastic indicator
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArraysFromBuffers(StochFastMainBuffer,handle_iStochastic_Fast,values_to_copy))
      return(0);
   if(!FillArraysFromBuffers(StochSlowMainBuffer,handle_iStochastic_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Stochastic Oscillator indicator
   bars_calculated=calculated;
//--- main loop
   int limit=rates_total-values_to_copy;
   for(int i=limit; i<rates_total; i++)
     {
      FillingBuffer1[i]=StochFastMainBuffer[i];
      FillingBuffer2[i]=StochSlowMainBuffer[i];
     }
//--- alert
   if(time[rates_total-1]>m_prev_bars)
     {
      m_last_sound=0;
      m_prev_bars=time[rates_total-1];
      m_repetitions=0;
     }
   if(m_repetitions>=InpSoundRepetitions)
      return(rates_total);
   datetime time_current=TimeCurrent();
   if(time_current-m_last_sound>InpSoundPause)
     {
      int i=rates_total-1;
      if(StochFastMainBuffer[i-1]<StochSlowMainBuffer[i-1] && StochFastMainBuffer[i]>StochSlowMainBuffer[i])
        {
         if(InpUseSound)
            PlaySound(InpSoundName);
         m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" Two STO, Trend UP, "+TimeToString(time[i]);
         if(InpUseAlert)
            Alert(m_text);
         m_last_sound=time_current;
         m_repetitions++;
         //---
         if(InpUseMail)
            SendMail(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1),m_text);
         if(InpUseNotification)
            SendNotification(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" "+m_text);
        }
      else
        {
         if(StochFastMainBuffer[i-1]>StochSlowMainBuffer[i-1] && StochFastMainBuffer[i]<StochSlowMainBuffer[i])
           {
            if(InpUseSound)
               PlaySound(InpSoundName);
            m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" Two STO, Trend DOWN, "+TimeToString(time[i]);
            if(InpUseAlert)
               Alert(m_text);
            m_last_sound=time_current;
            m_repetitions++;
            //---
            if(InpUseMail)
               SendMail(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1),m_text);
            if(InpUseNotification)
               SendNotification(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" "+m_text);
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iStochastic indicator         |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double &main_buffer[],    // indicator buffer of Stochastic Oscillator values
                           int ind_handle,           // handle of the iStochastic indicator
                           int amount                // number of copied values
                          )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the StochasticBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,MAIN_LINE,0,amount,main_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_iStochastic_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iStochastic_Fast);
   if(handle_iStochastic_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iStochastic_Slow);
  }
//+------------------------------------------------------------------+
