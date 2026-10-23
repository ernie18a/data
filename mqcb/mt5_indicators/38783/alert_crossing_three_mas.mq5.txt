//+------------------------------------------------------------------+
//|                                     Alert Crossing Three MAs.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.501"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot MA_Fast_
#property indicator_label1  "MA Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot MA_Medium_
#property indicator_label2  "MA Medium"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrPurple
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot MA_Slow_
#property indicator_label3  "MA Slow"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSlateGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot UP
#property indicator_label4  "UP"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrSteelBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot DOWN
#property indicator_label5  "DOWN"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input group             "MA Fast"
input int                  Inp_MA_Fast_ma_period      = 50;             // MA Fast: averaging period
input int                  Inp_MA_Fast_ma_shift       = 0;              // MA Fast: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Fast_ma_method      = MODE_EMA;       // MA Fast: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Fast_applied_price  = PRICE_CLOSE;    // MA Fast: type of price
input group             "MA Medium"
input int                  Inp_MA_Medium_ma_period    = 100;            // MA Medium: averaging period
input int                  Inp_MA_Medium_ma_shift     = 0;              // MA Medium: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Medium_ma_method    = MODE_EMA;       // MA Medium: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Medium_applied_price= PRICE_CLOSE;    // MA Medium: type of price
input group             "MA Slow"
input int                  Inp_MA_Slow_ma_period      = 240;            // MA Slow: averaging period
input int                  Inp_MA_Slow_ma_shift       = 0;              // MA Slow: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Slow_ma_method      = MODE_LWMA;      // MA Slow: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Slow_applied_price  = PRICE_CLOSE;    // MA Slow: type of price
input group             "Arrows"
input uchar                Inp_UP_Arrow_Code          = 241;            // Arrow 'UP': code (font Wingdings)
input int                  Inp_UP_Arrow_Shift         = 10;             // Arrow 'UP': vertical shift in pixel
input uchar                Inp_DOWN_Arrow_Code        = 242;            // Arrow 'DOWN': code (font Wingdings)
input int                  Inp_DOWN_Arrow_Shift       = 10;             // Arrow 'DOWN': vertical shift in pixel
input group             "Alerts"
input string               InpSoundName            = "alert.wav"; // Sound Name
input uchar                InpSoundRepetitions     = 3;           // Repetitions
input uchar                InpSoundPause           = 3;           // Pause, in seconds
input bool                 InpUseSound             = false;       // Use Sound
input bool                 InpUseAlert             = true;        // Use Alert
input bool                 InpUseMail              = true;        // Use Send mail
input bool                 InpUseNotification      = true;        // Use Send notification
//--- indicator buffers
double   MA_Fast_Buffer[];
double   MA_Medium_Buffer[];
double   MA_Slow_Buffer[];
double   UPBuffer[];
double   DOWNBuffer[];
//---
int      handle_iMA_Fast;              // variable for storing the handle of the iMA indicator
int      handle_iMA_Medium;            // variable for storing the handle of the iMA indicator
int      handle_iMA_Slow;              // variable for storing the handle of the iMA indicator
//---
int      bars_calculated   = 0;        // we will keep the number of values in the Moving Averages Convergence/Divergence indicator
int      start             = 0;
//---
datetime m_last_sound      = 0;        // "0" -> D'1970.01.01 00:00';
uchar    m_repetitions     = 0;        //
string   m_text            = "";       //
datetime m_prev_bars       = 0;        // "0" -> D'1970.01.01 00:00';
bool     m_init_error      = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MA_Fast_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,MA_Medium_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,MA_Slow_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,UPBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,DOWNBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(3,PLOT_ARROW,Inp_UP_Arrow_Code);
   PlotIndexSetInteger(4,PLOT_ARROW,Inp_DOWN_Arrow_Code);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,Inp_UP_Arrow_Shift);
   PlotIndexSetInteger(4,PLOT_ARROW_SHIFT,-Inp_DOWN_Arrow_Shift);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
//--- create handle of the indicator iMA
   handle_iMA_Fast=iMA(Symbol(),Period(),Inp_MA_Fast_ma_period,Inp_MA_Fast_ma_shift,
                       Inp_MA_Fast_ma_method,Inp_MA_Fast_applied_price);
//--- if the handle is not created
   if(handle_iMA_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('Fast') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Medium=iMA(Symbol(),Period(),Inp_MA_Medium_ma_period,Inp_MA_Medium_ma_shift,
                         Inp_MA_Medium_ma_method,Inp_MA_Medium_applied_price);
//--- if the handle is not created
   if(handle_iMA_Medium==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('Medium') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Slow=iMA(Symbol(),Period(),Inp_MA_Slow_ma_period,Inp_MA_Slow_ma_shift,
                       Inp_MA_Slow_ma_method,Inp_MA_Slow_applied_price);
//--- if the handle is not created
   if(handle_iMA_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('Slow') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   int fast=Inp_MA_Fast_ma_period+Inp_MA_Fast_ma_shift;
   int medium=Inp_MA_Medium_ma_period+Inp_MA_Medium_ma_shift;
   int slow=Inp_MA_Slow_ma_period+Inp_MA_Slow_ma_shift;
   start=(fast<medium)?medium:fast;
   start=(start<slow)?slow:start;
//---
   ArrayInitialize(UPBuffer,0.0);
   ArrayInitialize(DOWNBuffer,0.0);
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
   if(rates_total<start+1)
      return(0);
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_fast=BarsCalculated(handle_iMA_Fast);
   if(calculated_fast<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Fast) returned %d, error code %d",calculated_fast,GetLastError());
      return(0);
     }
   int calculated_medium=BarsCalculated(handle_iMA_Medium);
   if(calculated_medium<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Medium) returned %d, error code %d",calculated_medium,GetLastError());
      return(0);
     }
   int calculated_slow=BarsCalculated(handle_iMA_Slow);
   if(calculated_slow<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Slow) returned %d, error code %d",calculated_slow,GetLastError());
      return(0);
     }
//---
   if(calculated_fast!=calculated_medium)
     {
      PrintFormat("BarsCalculated(handle_iMA_Fast) returned %d, BarsCalculated(handle_iMA_Medium) returned %d",calculated_fast,calculated_medium);
      return(0);
     }
   if(calculated_medium!=calculated_slow)
     {
      PrintFormat("BarsCalculated(handle_iMA_Medium) returned %d, BarsCalculated(handle_iMA_Slow) returned %d",calculated_medium,calculated_slow);
      return(0);
     }
   int calculated=calculated_fast;
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
//--- fill the MA_Fast_Buffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(MA_Fast_Buffer,Inp_MA_Fast_ma_shift,handle_iMA_Fast,values_to_copy))
      return(0);
//--- fill the MA_Fast_Buffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(MA_Medium_Buffer,Inp_MA_Fast_ma_shift,handle_iMA_Medium,values_to_copy))
      return(0);
//--- fill the SlowBuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(MA_Slow_Buffer,Inp_MA_Slow_ma_shift,handle_iMA_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      ArrayInitialize(UPBuffer,0.0);
      ArrayInitialize(DOWNBuffer,0.0);
      limit=start;
      for(int i=0; i<limit; i++)
        {
         UPBuffer[i]=0.0;
         DOWNBuffer[i]=0.0;
        }
     }
   for(int i=limit; i<rates_total; i++)
     {
      //--- when fast ma crosses from above to below the middle ma, place a down arrow. opoosite for up
      if(MA_Fast_Buffer[i-1]<MA_Medium_Buffer[i-1] && MA_Fast_Buffer[i]>MA_Medium_Buffer[i])
         UPBuffer[i]=low[i];
      if(MA_Fast_Buffer[i-1]>MA_Medium_Buffer[i-1] && MA_Fast_Buffer[i]<MA_Medium_Buffer[i])
         DOWNBuffer[i]=high[i];
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
      if(MA_Fast_Buffer[i-1]<MA_Medium_Buffer[i-1] && MA_Fast_Buffer[i]>MA_Medium_Buffer[i])
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
         if(MA_Fast_Buffer[i-1]>MA_Medium_Buffer[i-1] && MA_Fast_Buffer[i]<MA_Medium_Buffer[i])
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
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_iMA_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Fast);
   if(handle_iMA_Medium!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Medium);
   if(handle_iMA_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Slow);
  }
//+------------------------------------------------------------------+
