//+------------------------------------------------------------------+
//|                                         Half Trend New Alert.mq5 |
//|                         Copyright © 2021-2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021-2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   3
//--- plot Line
#property indicator_label1  "Line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrOrangeRed,clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Up
#property indicator_label2  "Up"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Down
#property indicator_label3  "Down"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input int                  InpAmplitude            = 5;           // Amplitude
input group             "Arrow"
input uchar                InpCodeUpArrow          = 233;         // Arrow code for 'UpArrow' (font Wingdings)
input uchar                InpCodeDnArrow          = 234;         // Arrow code for 'DnArrow' (font Wingdings)
input int                  InpShift                = 10;          // Vertical shift of arrows in pixel
input group             "Alerts"
input string               InpSoundName            = "alert.wav"; // Sound Name
input uchar                InpSoundRepetitions     = 3;           // Repetitions
input uchar                InpSoundPause           = 3;           // Pause, in seconds
input bool                 InpUseSound             = false;       // Use Sound
input bool                 InpUseAlert             = true;        // Use Alert
input bool                 InpUseMail              = true;        // Use Send mail
input bool                 InpUseNotification      = true;        // Use Send notification
//--- indicator buffers
double   LineBuffer[];
double   LineColors[];
double   UpBuffer[];
double   DownBuffer[];
double   HighestBuffer[];
double   LowestBuffer[];
double   MA_PRICE_HIGH_Buffer[];
double   MA_PRICE_LOW_Buffer[];
//---
int      handle_iMA_PRICE_HIGH;              // variable for storing the handle of the iMA indicator
int      handle_iMA_PRICE_LOW;               // variable for storing the handle of the iMA indicator
int      bars_calculated            = 0;
int      m_start_bar                = 0;     // start bar
bool     m_init_error               = false; // error on InInit
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
//--- indicator buffers mapping
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LineColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DownBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,MA_PRICE_HIGH_Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,MA_PRICE_LOW_Buffer,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,InpCodeUpArrow);
   PlotIndexSetInteger(2,PLOT_ARROW,InpCodeDnArrow);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,InpShift);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,-InpShift);
//--- set as an empty value 0
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
//--- create handle of the indicator iMA
   handle_iMA_PRICE_HIGH=iMA(Symbol(),Period(),InpAmplitude,0,MODE_SMA,PRICE_HIGH);
//--- if the handle is not created
   if(handle_iMA_PRICE_HIGH==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA ('High') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA_PRICE_LOW=iMA(Symbol(),Period(),InpAmplitude,0,MODE_SMA,PRICE_LOW);
//--- if the handle is not created
   if(handle_iMA_PRICE_LOW==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA ('Low') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   m_start_bar=(InpAmplitude>m_start_bar)?InpAmplitude:m_start_bar;
   m_start_bar++;
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
//--- number of values copied from indicators
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_ma_high=BarsCalculated(handle_iMA_PRICE_HIGH);
   if(calculated_ma_high<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_PRICE_HIGH) returned %d, error code %d",calculated_ma_high,GetLastError());
      return(0);
     }
//--- determine the number of values calculated in the indicator
   int calculated_ma_low=BarsCalculated(handle_iMA_PRICE_LOW);
   if(calculated_ma_low<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_PRICE_LOW) returned %d, error code %d",calculated_ma_low,GetLastError());
      return(0);
     }
   if(calculated_ma_high!=calculated_ma_low)
     {
      PrintFormat("BarsCalculated(handle_iMA_PRICE_HIGH) returned %d, BarsCalculated(handle_iMA_PRICE_LOW) returned %d",calculated_ma_high,calculated_ma_low);
      return(0);
     }
   int calculated=calculated_ma_high;
//--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything
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
//--- fill array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(MA_PRICE_HIGH_Buffer,0,handle_iMA_PRICE_HIGH,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(MA_PRICE_LOW_Buffer,0,handle_iMA_PRICE_LOW,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=m_start_bar;
      for(int i=0; i<limit; i++)
        {
         LineBuffer[i]=high[i];
         LineColors[i]=0.0;
         UpBuffer[i]=0.0;
         DownBuffer[i]=0.0;
         HighestBuffer[i]=high[i];
         LowestBuffer[i]=low[i];
        }
      double highest=high[ArrayMaximum(high,limit-InpAmplitude+1,InpAmplitude)];
      double lowest =low[ArrayMinimum(low,limit-InpAmplitude+1,InpAmplitude)];
      HighestBuffer[limit]=highest;
      LowestBuffer[limit]=lowest;
     }
   for(int i=limit; i<rates_total; i++)
     {
      double highest=high[ArrayMaximum(high,i-InpAmplitude+1,InpAmplitude)];
      double lowest =low[ArrayMinimum(low,i-InpAmplitude+1,InpAmplitude)];
      //---
      HighestBuffer[i]=highest;
      LowestBuffer[i]=lowest;
      //---
      UpBuffer[i]=0.0;
      DownBuffer[i]=0.0;
      //---
      if(MA_PRICE_HIGH_Buffer[i]<LineBuffer[i-1] && MA_PRICE_LOW_Buffer[i]<LineBuffer[i-1] && HighestBuffer[i]<LineBuffer[i-1])
        {
         LineBuffer[i]=HighestBuffer[i];
         LineColors[i]=LineColors[i-1];
         if(LineBuffer[i]<LineBuffer[i-1])
            LineColors[i]=0.0;
         if(LineBuffer[i]>LineBuffer[i-1])
            LineColors[i]=1.0;
         if(LineColors[i-1]==0.0 && LineColors[i]==1.0)
            UpBuffer[i]=LineBuffer[i-1];
         if(LineColors[i-1]==1.0 && LineColors[i]==0.0)
            DownBuffer[i]=LineBuffer[i-1];
         continue;
        }
      if(MA_PRICE_HIGH_Buffer[i]>LineBuffer[i-1] && MA_PRICE_LOW_Buffer[i]>LineBuffer[i-1] && LowestBuffer[i]>LineBuffer[i-1])
        {
         LineBuffer[i]=LowestBuffer[i];
         LineColors[i]=LineColors[i-1];
         if(LineBuffer[i]<LineBuffer[i-1])
            LineColors[i]=0.0;
         if(LineBuffer[i]>LineBuffer[i-1])
            LineColors[i]=1.0;
         if(LineColors[i-1]==0.0 && LineColors[i]==1.0)
            UpBuffer[i]=LineBuffer[i-1];
         if(LineColors[i-1]==1.0 && LineColors[i]==0.0)
            DownBuffer[i]=LineBuffer[i-1];
         continue;
        }
      LineBuffer[i]=LineBuffer[i-1];
      LineColors[i]=LineColors[i-1];
      continue;
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
      if(UpBuffer[i]!=0.0)
        {
         if(InpUseSound)
            PlaySound(InpSoundName);
         m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" Three MAs, Trend UP, "+TimeToString(time[i]);
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
         if(DownBuffer[i]!=0.0)
           {
            if(InpUseSound)
               PlaySound(InpSoundName);
            m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" Three MAs, Trend DOWN, "+TimeToString(time[i]);
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
//| Filling indicator buffers from the MA indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values
                         int shift,          // shift
                         int ind_handle,     // handle of the iMA indicator
                         int amount          // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the ATR indicator                 |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],  // indicator buffer for ATR values
                         int ind_handle,    // handle of the iATR indicator
                         int amount         // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iATRBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
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
   if(handle_iMA_PRICE_HIGH!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_PRICE_HIGH);
   if(handle_iMA_PRICE_LOW!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_PRICE_LOW);
//---
//   int debug         = MQLInfoInteger(MQL_DEBUG);
//   int profiler      = MQLInfoInteger(MQL_PROFILER);
//   int tester        = MQLInfoInteger(MQL_TESTER);
//   int forward       = MQLInfoInteger(MQL_FORWARD);
//   int optimization  = MQLInfoInteger(MQL_OPTIMIZATION);
//   int visual_mode   = MQLInfoInteger(MQL_VISUAL_MODE);
//   /*
//      Print("MQL_DEBUG: ",debug,", ",
//            "MQL_PROFILER: ",profiler,", ",
//            "MQL_TESTER: ",tester,", ",
//            "MQL_FORWARD: ",forward,", ",
//            "MQL_OPTIMIZATION: ",optimization,", ",
//            "MQL_VISUAL_MODE: ",visual_mode);
//   */
//   /*
//      F5          -> MQL_DEBUG: 1, MQL_PROFILER: 0, MQL_TESTER: 0, MQL_FORWARD: 0, MQL_OPTIMIZATION: 0, MQL_VISUAL_MODE: 0
//      Ctrl + F5   -> MQL_DEBUG: 1, MQL_PROFILER: 0, MQL_TESTER: 1, MQL_FORWARD: 0, MQL_OPTIMIZATION: 0, MQL_VISUAL_MODE: 1
//      Online      -> MQL_DEBUG: 0, MQL_PROFILER: 0, MQL_TESTER: 0, MQL_FORWARD: 0, MQL_OPTIMIZATION: 0, MQL_VISUAL_MODE: 0
//   */
////---
//   if((debug==1 && tester==0) || (debug==0 && tester==0)) // F5 OR Online
//     {
//      int windows_total=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//      for(int i=windows_total-1; i>=0; i--)
//        {
//         for(int j=ChartIndicatorsTotal(0,i)-1; j>=0; j--)
//           {
//            string name=ChartIndicatorName(0,i,j);
//            if(name!="Half Trend New")
//               ChartIndicatorDelete(0,i,name);
//           }
//        }
//     }
  }
//+------------------------------------------------------------------+
