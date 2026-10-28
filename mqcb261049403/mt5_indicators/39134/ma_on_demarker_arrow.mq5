//+------------------------------------------------------------------+
//|                                         MA on DeMarker Arrow.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.002"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot DeM
#property indicator_label1  "DeM"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot MA on DeM
#property indicator_label2  "MA on DeM"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Up
#property indicator_label3  "Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Down
#property indicator_label4  "Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrTomato
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input group             "DeMarker"
input int                  Inp_DeM_ma_period    = 14;             // DeM: averaging period
input double               Inp_DeM_LevelUP      = 0.7;            // DeM: Level UP
input double               Inp_DeM_LevelDOWN    = 0.3;            // DeM: Level DOWN
input group             "MA"
input int                  Inp_MA_ma_period     = 6;              // MA: averaging period
input ENUM_MA_METHOD       Inp_MA_ma_method     = MODE_EMA;       // MA: smoothing type
input group             "Arrows"
input uchar                InpUpArrowCode       = 71;             // Arrow 'Up': code (font Wingdings)
input int                  InpUpArrowShift      = 10;             // Arrow 'Up': vertical shift in pixel
input uchar                InpDownArrowCode     = 72;             // Arrow 'Down': code (font Wingdings)
input int                  InpDownArrowShift    = 10;             // Arrow 'Down': vertical shift in pixel
//--- indicator buffers
double   DeMBuffer[];
double   MAonDeMBuffer[];
double   UpBuffer[];
double   DownBuffer[];
//---
int      handle_iDeMarker;                      // variable for storing the handle of the iDeMarker indicator
int      handle_iMA;                            // variable for storing the handle of the iMA indicator
int      bars_calculated   = 0;                 // we will keep the number of values in the DeMarker and MA indicators
bool     m_init_error      = false;             // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DeMBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MAonDeMBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DownBuffer,INDICATOR_DATA);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_DeM_LevelUP);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_DeM_LevelDOWN);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(2,PLOT_ARROW,InpUpArrowCode);
   PlotIndexSetInteger(3,PLOT_ARROW,InpDownArrowCode);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,InpUpArrowShift);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-InpDownArrowShift);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//--- set labels for the line
   PlotIndexSetString(0,PLOT_LABEL,"DeM"+"("+IntegerToString(Inp_DeM_ma_period)+")");
   PlotIndexSetString(1,PLOT_LABEL,"MA"+"("+IntegerToString(Inp_MA_ma_period)+")"+" on DeM"+"("+IntegerToString(Inp_DeM_ma_period)+")");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS,3);
//--- create handle of the indicator iDeMarker
   handle_iDeMarker=iDeMarker(Symbol(),Period(),Inp_DeM_ma_period);
//--- if the handle is not created
   if(handle_iDeMarker==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iDeMarker indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,0,
                  Inp_MA_ma_method,handle_iDeMarker);
//--- if the handle is not created
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_dem=BarsCalculated(handle_iDeMarker);
   if(calculated_dem<=0)
     {
      PrintFormat("BarsCalculated(DeMarker) returned %d, error code %d",calculated_dem,GetLastError());
      return(0);
     }
//--- determine the number of values calculated in the indicator
   int calculated_ma=BarsCalculated(handle_iMA);
   if(calculated_ma<=0)
     {
      PrintFormat("BarsCalculated(MA) returned %d, error code %d",calculated_ma,GetLastError());
      return(0);
     }
   if(calculated_dem!=calculated_ma)
     {
      PrintFormat("BarsCalculated(DeMarker) returned %d, BarsCalculated(MA) returned %d",calculated_dem,calculated_ma);
      return(0);
     }
   int calculated=calculated_dem;
//--- if it is the first start of calculation of the indicator or if the number of values in the indicator changed
//--- or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
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
//--- fill the MAonDeMBuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBufferMA(MAonDeMBuffer,0,handle_iMA,values_to_copy))
      return(0);
//--- fill the DeMBuffer array with values of the Commodity Channel Index indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBufferDeMarker(DeMBuffer,handle_iDeMarker,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- Arrow
   if(rates_total<3)
      return(0);
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      UpBuffer[0]=0.0;
      DownBuffer[0]=0.0;
      limit=1;
     }
   for(int i=limit; i<rates_total; i++)
     {
      UpBuffer[i]=0.0;
      DownBuffer[i]=0.0;
      if(DeMBuffer[i-1]<MAonDeMBuffer[i-1] && DeMBuffer[i]>MAonDeMBuffer[i] && DeMBuffer[i-1]<Inp_DeM_LevelDOWN)
         UpBuffer[i]=MAonDeMBuffer[i];
      else
         if(DeMBuffer[i-1]>MAonDeMBuffer[i-1] && DeMBuffer[i]<MAonDeMBuffer[i] && DeMBuffer[i-1]>Inp_DeM_LevelUP)
            DownBuffer[i]=MAonDeMBuffer[i];
     }
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the MA indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBufferMA(double &values[],    // indicator buffer of Moving Average values
                           int shift,           // shift
                           int ind_handle,      // handle of the iMA indicator
                           int amount           // number of copied values
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
//| Filling indicator buffers from the iDeMarker indicator           |
//+------------------------------------------------------------------+
bool FillArrayFromBufferDeMarker(double &values[],    // indicator buffer of DeMarker values
                                 int ind_handle,      // handle of the iDeMarker indicator
                                 int amount           // number of copied values
                                )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iDeMarker indicator, error code %d",GetLastError());
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
   if(handle_iDeMarker!=INVALID_HANDLE)
      IndicatorRelease(handle_iDeMarker);
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
