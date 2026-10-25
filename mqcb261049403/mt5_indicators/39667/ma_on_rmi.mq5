//+------------------------------------------------------------------+
//|                                                    MA on RMI.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot RMI
#property indicator_label1  "RMI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot MA on RMI
#property indicator_label2  "MA on RMI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input group             "RMI"
input ushort               InpRmiPeriod         = 14;             // RMI Period
input ushort               InpMomPeriod         = 10;             // Momentum Period
input group             "MA"
input int                  Inp_MA_ma_period     = 6;              // MA: averaging period
input ENUM_MA_METHOD       Inp_MA_ma_method     = MODE_EMA;       // MA: smoothing type
//--- indicator buffers
double   RMIBuffer[];
double   MAonRMIBuffer[];
//---
int      handle_iCustom;                        // variable for storing the handle of the RMI indicator
int      handle_iMA;                            // variable for storing the handle of the iMA indicator
int      bars_calculated      = 0;              // we will keep the number of values in the RMI and MA indicators
bool     m_init_error         = false;          // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,RMIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MAonRMIBuffer,INDICATOR_DATA);
//--- set labels for the line
   PlotIndexSetString(0,PLOT_LABEL,"RMI"+"("+IntegerToString(InpRmiPeriod)+","+IntegerToString(InpMomPeriod)+")");
   PlotIndexSetString(1,PLOT_LABEL,"MA on RMI"+"("+IntegerToString(Inp_MA_ma_period)+")");
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(Symbol(),Period(),"rmi",
                          InpRmiPeriod,
                          InpMomPeriod);
//--- if the handle is not created
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,0,
                  Inp_MA_ma_method,handle_iCustom);
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
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_rmi=BarsCalculated(handle_iCustom);
   if(calculated_rmi<=0)
     {
      PrintFormat("BarsCalculated(handle_iCustom) returned %d, error code %d",calculated_rmi,GetLastError());
      return(0);
     }
//--- determine the number of values calculated in the indicator
   int calculated_ma=BarsCalculated(handle_iMA);
   if(calculated_ma<=0)
     {
      PrintFormat("BarsCalculated(MA) returned %d, error code %d",calculated_ma,GetLastError());
      return(0);
     }
   if(calculated_rmi!=calculated_ma)
     {
      PrintFormat("BarsCalculated(handle_iCustom) returned %d, BarsCalculated(handle_iMA) returned %d",calculated_rmi,calculated_ma);
      return(0);
     }
   int calculated=calculated_rmi;
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
//--- fill the MAonRMIBuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBufferMA(MAonRMIBuffer,0,handle_iMA,values_to_copy))
      return(0);
//--- fill the RMIBuffer array with values of the Commodity Channel Index indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBufferCCI(RMIBuffer,handle_iCustom,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the MA indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBufferMA(double &values[],   // indicator buffer of Moving Average values
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
//| Filling indicator buffers from the iCCI indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBufferCCI(double &values[],  // indicator buffer of Commodity Channel Index values
                            int ind_handle,    // handle of the iCCI indicator
                            int amount         // number of copied values
                           )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iRMIBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
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
   if(handle_iCustom!=INVALID_HANDLE)
      IndicatorRelease(handle_iCustom);
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
