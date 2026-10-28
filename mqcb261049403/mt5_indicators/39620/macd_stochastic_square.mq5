//+------------------------------------------------------------------+
//|                                       MACD Stochastic Square.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum 1
#property indicator_maximum 4
#property indicator_level1  2
#property indicator_level2  3
#property indicator_buffers 8
#property indicator_plots   2
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrBlue,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot STO
#property indicator_label2  "STO"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrBlue,clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "MACD"
input int                  Inp_MACD_fast_ema_period      = 12;             // MACD: period for Fast average calculation
input int                  Inp_MACD_slow_ema_period      = 26;             // MACD: period for Slow average calculation
input int                  Inp_MACD_signal_period        = 9;              // MACD: period for their difference averaging
input ENUM_APPLIED_PRICE   Inp_MACD_applied_price        = PRICE_CLOSE;    // MACD: type of price
input group             "Stochastic"
input int                  Inp_STO_Kperiod               = 5;              // Stochastic: K-period (number of bars for calculations)
input int                  Inp_STO_Dperiod               = 3;              // Stochastic: D-period (period of first smoothing)
input int                  Inp_STO_slowing               = 3;              // Stochastic: final smoothing
input ENUM_MA_METHOD       Inp_STO_ma_method             = MODE_SMA;       // Stochastic: type of smoothing
input ENUM_STO_PRICE       Inp_STO_price_field           = STO_LOWHIGH;    // Stochastic: stochastic calculation method
//--- indicator buffers
double MACDBuffer[];
double MACDColors[];
double STOBuffer[];
double STOColors[];

double iMACDBuffer[];
double iMACDSignalBuffer[];
double iSTOBuffer[];
double iSTOSignalBuffer[];
//---
int      handle_iMACD;                 // variable for storing the handle of the iMACD indicator
int      handle_iStochastic;           // variable for storing the handle of the iStochastic indicator
int      bars_calculated      = 0;     // we will keep the number of values in the indicators
bool     m_init_error         = false; // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MACDColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,STOBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,STOColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,iMACDBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,iMACDSignalBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,iSTOBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,iSTOSignalBuffer,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,110);
   PlotIndexSetInteger(1,PLOT_ARROW,110);
//--- set descriptions of horizontal levels
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"MACD");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"STO");
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(Symbol(),Period(),Inp_MACD_fast_ema_period,Inp_MACD_slow_ema_period,
                      Inp_MACD_signal_period,Inp_MACD_applied_price);
//--- if the handle is not created
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(Symbol(),Period(),
                                  Inp_STO_Kperiod,Inp_STO_Dperiod,Inp_STO_slowing,
                                  Inp_STO_ma_method,Inp_STO_price_field);
//--- if the handle is not created
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
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
   if(rates_total<9)
      return(0);
//---
//--- number of values copied from the iMACD indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_macd=BarsCalculated(handle_iMACD);
   if(calculated_macd<=0)
     {
      PrintFormat("BarsCalculated(handle_iMACD) returned %d, error code %d",calculated_macd,GetLastError());
      return(0);
     }
   int calculated_sto=BarsCalculated(handle_iStochastic);
   if(calculated_sto<=0)
     {
      PrintFormat("BarsCalculated(handle_iStochastic) returned %d, error code %d",calculated_sto,GetLastError());
      return(0);
     }
   if(calculated_macd!=calculated_sto)
     {
      PrintFormat("BarsCalculated(handle_iMACD) returned %d, BarsCalculated(handle_iStochastic) returned %d,",calculated_macd,calculated_sto);
      return(0);
     }
   int calculated=calculated_macd;
//--- if it is the first start of calculation of the indicator or if the number of values in the indicators changed
//---or if it is necessary to calculated the indicators for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the Buffer array is greater than the number of values in the indicators for symbol/period, then we don't copy everything
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
//--- fill the arrays with values of the iMACD indicator
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArraysFromBuffersMACD(iMACDBuffer,iMACDSignalBuffer,handle_iMACD,values_to_copy))
      return(0);
//--- fill the arrays with values of the iStochastic indicator
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArraysFromBuffersSTO(iSTOBuffer,iSTOSignalBuffer,handle_iStochastic,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Averages indicator Convergence/Divergence
   bars_calculated=calculated;
//--- main loop
   int limit=rates_total-values_to_copy;
   if(limit==0)
     {
      MACDBuffer[0]=0.0;
      MACDColors[0]=0.0;
      STOBuffer[0]=0.0;
      STOColors[0]=0.0;
      limit=1;
     }
   for(int i=limit; i<rates_total; i++)
     {
      //--- MACD
      MACDBuffer[i]=2.0;
      if(iMACDSignalBuffer[i]<iMACDBuffer[i])
         MACDColors[i]=0.0;
      else
         MACDColors[i]=1.0;
      //--- STO
      STOBuffer[i]=3.0;
      if(iSTOSignalBuffer[i]<iSTOBuffer[i])
         STOColors[i]=0.0;
      else
         STOColors[i]=1.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iMACD indicator               |
//+------------------------------------------------------------------+
bool FillArraysFromBuffersMACD(double &macd_buffer[],    // indicator buffer of MACD values
                               double &signal_buffer[],  // indicator buffer of the signal line of MACD
                               int ind_handle,           // handle of the iMACD indicator
                               int amount                // number of copied values
                              )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,macd_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- fill a part of the SignalBuffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle,1,0,amount,signal_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iStochastic indicator         |
//+------------------------------------------------------------------+
bool FillArraysFromBuffersSTO(double &main_buffer[],    // indicator buffer of Stochastic Oscillator values
                              double &signal_buffer[],  // indicator buffer of the signal line
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
//--- fill a part of the SignalBuffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle,SIGNAL_LINE,0,amount,signal_buffer)<0)
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
   if(handle_iMACD!=INVALID_HANDLE)
      IndicatorRelease(handle_iMACD);
   if(handle_iStochastic!=INVALID_HANDLE)
      IndicatorRelease(handle_iStochastic);
  }
//+------------------------------------------------------------------+
