//+------------------------------------------------------------------+
//|                                              SAR Color Alert.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot SAR
#property indicator_label1  "SAR"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrDodgerBlue,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input group             "SAR"
input double               Inp_SAR_step                  = 0.02;           // SAR: price increment step - acceleration factor
input double               Inp_SAR_maximum               = 0.2;            // SAR: maximum value of step
input group             "Alerts"
input string               InpSoundName            = "alert.wav"; // Sound Name
input uchar                InpSoundRepetitions     = 3;           // Repetitions
input uchar                InpSoundPause           = 3;           // Pause, in seconds
input bool                 InpUseSound             = false;       // Use Sound
input bool                 InpUseAlert             = true;        // Use Alert
input bool                 InpUseMail              = true;        // Use Send mail
input bool                 InpUseNotification      = true;        // Use Send notification
//--- indicator buffers
double   SARBuffer[];
double   SARColors[];
//---
int      handle_iSAR;            // variable for storing the handle of the iSAR indicator
int      bars_calculated= 0;     // we will keep the number of values in the Parabolic SAR indicator
//---
datetime m_last_sound      = 0;        // "0" -> D'1970.01.01 00:00';
uchar    m_repetitions     = 0;        //
string   m_text            = "";       //
datetime m_prev_bars       = 0;        // "0" -> D'1970.01.01 00:00';
//---
bool     m_init_error   = false; // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,SARBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SARColors,INDICATOR_COLOR_INDEX);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- set label name
   string short_name=StringFormat("SAR Alert(%.2f,%.2f)",Inp_SAR_step,Inp_SAR_maximum);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(Symbol(),Period(),Inp_SAR_step,Inp_SAR_maximum);
//--- if the handle is not created
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
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
//---
   if(m_init_error)
      return(0);
//--- number of values copied from the iSAR indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(handle_iSAR);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iSAR indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iSARBuffer array is greater than the number of values in the iSAR indicator for symbol/period, then we don't copy everything
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
//--- fill the arrays with values of the iSAR indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(SARBuffer,handle_iSAR,values_to_copy))
      return(0);
//--- memorize the number of values in the Parabolic SAR indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit; i<rates_total; i++)
     {
      if(SARBuffer[i]<=low[i])
         SARColors[i]=0.0;
      if(SARBuffer[i]>=high[i])
         SARColors[i]=1.0;
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
   if(rates_total<3)
      return(rates_total);
   if(time_current-m_last_sound>InpSoundPause)
     {
      int i=rates_total-1;
      if(SARColors[i-1]==1.0 && SARColors[i]==0.0)
        {
         if(InpUseSound)
            PlaySound(InpSoundName);
         m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" SAR, Trend UP, "+TimeToString(time[i]);
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
         if(SARColors[i-1]==0.0 && SARColors[i]==1.0)
           {
            if(InpUseSound)
               PlaySound(InpSoundName);
            m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" SAR, Trend DOWN, "+TimeToString(time[i]);
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
//| Filling indicator buffers from the iSAR indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &sar_buffer[],  // indicator buffer of Parabolic SAR values
                         int ind_handle,        // handle of the iSAR indicator
                         int amount             // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,sar_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
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
   if(handle_iSAR!=INVALID_HANDLE)
      IndicatorRelease(handle_iSAR);
  }
//+------------------------------------------------------------------+
