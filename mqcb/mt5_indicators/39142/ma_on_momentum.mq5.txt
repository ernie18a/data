//+------------------------------------------------------------------+
//|                                               MA on Momentum.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_level1 100
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Momentum
#property indicator_label1  "Momentum"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot MA on Momentum
#property indicator_label2  "MA on Momentum"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input group             "Momentum"
input int                  Inp_Momentum_mom_period    = 14;          // Momentum: averaging period
input ENUM_APPLIED_PRICE   Inp_Momentum_applied_price = PRICE_CLOSE; // Momentum: type of price
input group             "MA"
input int                  Inp_MA_ma_period           = 6;           // MA: averaging period
input ENUM_MA_METHOD       Inp_MA_ma_method           = MODE_SMMA;   // MA: smoothing type
//--- indicator buffers
double   MomentumBuffer[];
double   MAonMomentumBuffer[];
//---
int      handle_iMomentum;                      // variable for storing the handle of the iMomentum indicator
int      handle_iMA;                            // variable for storing the handle of the iMA indicator
int      bars_calculated   = 0;                 // we will keep the number of values in the Momentum and MA indicators
bool     m_init_error      = false;             // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MomentumBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MAonMomentumBuffer,INDICATOR_DATA);
//--- set labels for the line
   PlotIndexSetString(0,PLOT_LABEL,"Momentum"+"("+IntegerToString(Inp_Momentum_mom_period)+")");
   PlotIndexSetString(1,PLOT_LABEL,"MA"+"("+IntegerToString(Inp_MA_ma_period)+")"+" on Momentum"+"("+IntegerToString(Inp_Momentum_mom_period)+")");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS,3);
//--- create handle of the indicator iMomentum
   handle_iMomentum=iMomentum(Symbol(),Period(),Inp_Momentum_mom_period,
                              Inp_Momentum_applied_price);
//--- if the handle is not created
   if(handle_iMomentum==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMomentum indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,0,
                  Inp_MA_ma_method,handle_iMomentum);
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
   int calculated_momentum=BarsCalculated(handle_iMomentum);
   if(calculated_momentum<=0)
     {
      PrintFormat("BarsCalculated(Momentum) returned %d, error code %d",calculated_momentum,GetLastError());
      return(0);
     }
//--- determine the number of values calculated in the indicator
   int calculated_ma=BarsCalculated(handle_iMA);
   if(calculated_ma<=0)
     {
      PrintFormat("BarsCalculated(MA) returned %d, error code %d",calculated_ma,GetLastError());
      return(0);
     }
   if(calculated_momentum!=calculated_ma)
     {
      PrintFormat("BarsCalculated(Momentum) returned %d, BarsCalculated(MA) returned %d",calculated_momentum,calculated_ma);
      return(0);
     }
   int calculated=calculated_momentum;
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
//--- fill the MAonMomentumBuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBufferMA(MAonMomentumBuffer,0,handle_iMA,values_to_copy))
      return(0);
//--- fill the MomentumBuffer array with values of the Commodity Channel Index indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBufferMomentum(MomentumBuffer,handle_iMomentum,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
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
//| Filling indicator buffers from the iMomentum indicator           |
//+------------------------------------------------------------------+
bool FillArrayFromBufferMomentum(double &values[],    // indicator buffer of Momentum values
                                 int ind_handle,      // handle of the iMomentum indicator
                                 int amount           // number of copied values
                                )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMomentum indicator, error code %d",GetLastError());
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
   if(handle_iMomentum!=INVALID_HANDLE)
      IndicatorRelease(handle_iMomentum);
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
