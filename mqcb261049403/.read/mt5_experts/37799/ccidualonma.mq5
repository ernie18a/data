//+------------------------------------------------------------------+
//|                                                  CCIDualOnMA.mq5 |
//|                              Copyright © 2021, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot CCIFast
#property indicator_label1  "CCI Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot CCISlow
#property indicator_label2  "CCI Slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrPaleVioletRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "CCI"
input int                  Inp_CCI_Fast_ma_period     = 14;             // CCI Fast: averaging period
input ENUM_APPLIED_PRICE   Inp_CCI_Fast_applied_price = PRICE_TYPICAL;  // CCI Fast: type of price
input int                  Inp_CCI_Slow_ma_period     = 50;             // CCI Slow: averaging period
input ENUM_APPLIED_PRICE   Inp_CCI_Slow_applied_price = PRICE_TYPICAL;  // CCI Slow: type of price
input group             "MA"
input int                  Inp_MA_ma_period           = 12;             // MA: averaging period
input ENUM_MA_METHOD       Inp_MA_ma_method           = MODE_SMA;       // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_applied_price       = PRICE_CLOSE;    // MA: type of price
//--- indicator buffers
double   CCIFastBuffer[];
double   CCISlowBuffer[];
//---
int      handle_iMA;                         // variable for storing the handle of the iMA indicator
int      handle_iCCI_Fast;                   // variable for storing the handle of the iCCI indicator
int      handle_iCCI_Slow;                   // variable for storing the handle of the iCCI indicator
int      bars_calculated      = 0;           // we will keep the number of values in the Commodity Channel Index indicator
int      m_start              = 0;
bool     m_init_error         = false;       // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,CCIFastBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CCISlowBuffer,INDICATOR_DATA);
   m_start=(m_start<Inp_CCI_Fast_ma_period)?Inp_CCI_Fast_ma_period:m_start;
   m_start=(m_start<Inp_CCI_Fast_ma_period)?Inp_CCI_Fast_ma_period:m_start;
   m_start=m_start+3;
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,0,
                  Inp_MA_ma_method,Inp_MA_applied_price);
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
//--- create handle of the indicator iCCI
   handle_iCCI_Fast=iCCI(Symbol(),Period(),Inp_CCI_Fast_ma_period,handle_iMA);
//--- if the handle is not created
   if(handle_iCCI_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iCCI indicator (\"Fast\") for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iCCI
   handle_iCCI_Slow=iCCI(Symbol(),Period(),Inp_CCI_Slow_ma_period,handle_iMA);
//--- if the handle is not created
   if(handle_iCCI_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iCCI indicator (\"Slow\") for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
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
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_fast=BarsCalculated(handle_iCCI_Fast);
   if(calculated_fast<=0)
     {
      PrintFormat("BarsCalculated(\"Fast\") returned %d, error code %d",calculated_fast,GetLastError());
      return(0);
     }
   int calculated_slow=BarsCalculated(handle_iCCI_Slow);
   if(calculated_slow<=0)
     {
      PrintFormat("BarsCalculated(\"Slow\") returned %d, error code %d",calculated_slow,GetLastError());
      return(0);
     }
   if(calculated_fast!=calculated_slow)
     {
      PrintFormat("BarsCalculated(\"Fast\") %d not equal BarsCalculated(\"Slow\") %d",calculated_fast,calculated_slow);
      return(0);
     }
   int calculated=calculated_fast;
//--- if it is the first start of calculation of the indicator or if the number of values in the iCCI indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iCCIBuffer array is greater than the number of values in the iCCI indicator for symbol/period, then we don't copy everything
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
//--- fill the iCCIBuffer array with values of the Commodity Channel Index indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(CCIFastBuffer,handle_iCCI_Fast,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(CCISlowBuffer,handle_iCCI_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Commodity Channel Index indicator
   bars_calculated=calculated;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iCCI indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],  // indicator buffer of Commodity Channel Index values
                         int ind_handle,    // handle of the iCCI indicator
                         int amount         // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index
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
   if(handle_iCCI_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iCCI_Fast);
   if(handle_iCCI_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iCCI_Slow);
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
