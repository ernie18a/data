/*-------------------------------------------------------------------+
 |                                                    MaEnv_02B.mq4  |
 |                                                 Copyright © 2011  |
 |                                             basisforex@gmail.com  |
 +-------------------------------------------------------------------*/
#property copyright "Copyright © 2011, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//----
#property description "MaEnv"
//----
#property version "2.00"
//----
#property indicator_chart_window
//----
#property indicator_buffers 9
//----
#property indicator_plots 9
//+------------------------------------------------------------------+
#property indicator_type1   DRAW_LINE           //  drawing the line 0
#property indicator_color1  White
#property indicator_width1  2
#property indicator_label1  "MA"
//+------------------------------------------------------------------+
#property indicator_type2   DRAW_LINE           //  drawing the line 1
#property indicator_color2  Aqua
#property indicator_width2  1
#property indicator_label2  "Up1"
//+------------------------------------------------------------------+
#property indicator_type3   DRAW_LINE           //  drawing the line 2
#property indicator_color3  Aqua
#property indicator_width3  1
#property indicator_label3  "Dn2"
//+------------------------------------------------------------------+
#property indicator_type4   DRAW_LINE           //  drawing the line 3
#property indicator_color4  Blue
#property indicator_width4  1
#property indicator_label4  "Up2"
//+------------------------------------------------------------------+
#property indicator_type5   DRAW_LINE           //  drawing the line 4
#property indicator_color5  Blue
#property indicator_width5  1
#property indicator_label5 "Dn2"
//+------------------------------------------------------------------+
#property indicator_type6   DRAW_LINE           //  drawing the line 5
#property indicator_color6  Yellow
#property indicator_width6  1
#property indicator_label6  "Up3"
//+------------------------------------------------------------------+
#property indicator_type7   DRAW_LINE           //  drawing the line 6
#property indicator_color7  Yellow
#property indicator_width7  1
#property indicator_label7  "Dn3"
//+------------------------------------------------------------------+
#property indicator_type8   DRAW_LINE           //  drawing the line 7
#property indicator_color8  Red
#property indicator_width8  1
#property indicator_label8  "Up4"
//+------------------------------------------------------------------+
#property indicator_type9   DRAW_LINE           //  drawing the line 8
#property indicator_color9  Red
#property indicator_width9  1
#property indicator_label9  "Dn4"
//+------------------------------------------------------------------+
double aquaUp1[];
double aquaDn1[];
double aquaUp2[];
double aquaDn2[];
double aquaUp3[];
double aquaDn3[];
double aquaUp4[];
double aquaDn4[];
//----
int    BorisKoeff;
//+------------------------------------------------------------------+
//|  Enumeration of the methods of handle creation                   |
//+------------------------------------------------------------------+
enum Creation
  {
   Call_iMA
  };
//--- input parameters
input Creation             type          = Call_iMA;              // type of the function 
input int                  ma_period_1   = 30;                    // period of ma  
input int                  ma_period_2   = 50;                    // period of ma  
input int                  ma_period_3   = 100;                   // period of ma                   
input ENUM_MA_METHOD       ma_method     = MODE_SMA;              // type of smoothing
input ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;           // type of price
input string               symbol        = " ";                   // symbol 
input ENUM_TIMEFRAMES      period        = PERIOD_CURRENT;        // timeframe
input int                  ma_shift      = 0;                     // shift
//--- indicator buffer
double iMABuffer[];
//--- variable for storing the handle of the iMA indicator
int    handle;
int    bars_calculated=0;
//+------------------------------------------------------------------+
int OnInit()
  {
//---- set Buffers dynamic array as an indicator buffer
   SetIndexBuffer(0,iMABuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHIFT,ma_shift);
//----
   SetIndexBuffer(1,aquaUp1,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_SHIFT,ma_shift);
//---- 
   SetIndexBuffer(2,aquaDn1,INDICATOR_DATA);
   PlotIndexSetInteger(2,PLOT_SHIFT,ma_shift);
//----
   SetIndexBuffer(3,aquaUp2,INDICATOR_DATA);
   PlotIndexSetInteger(3,PLOT_SHIFT,ma_shift);
//----
   SetIndexBuffer(4,aquaDn2,INDICATOR_DATA);
   PlotIndexSetInteger(4,PLOT_SHIFT,ma_shift);
//---- 
   SetIndexBuffer(5,aquaUp3,INDICATOR_DATA);
   PlotIndexSetInteger(5,PLOT_SHIFT,ma_shift);
//----
   SetIndexBuffer(6,aquaDn3,INDICATOR_DATA);
   PlotIndexSetInteger(6,PLOT_SHIFT,ma_shift);
//----
   SetIndexBuffer(7,aquaUp4,INDICATOR_DATA);
   PlotIndexSetInteger(7,PLOT_SHIFT,ma_shift);
//----
   SetIndexBuffer(8,aquaDn4,INDICATOR_DATA);
   PlotIndexSetInteger(8,PLOT_SHIFT,ma_shift);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for tooltips 
   string short_name="MaEnv";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----  
   if(type==Call_iMA)
     {
      handle=(iMA(NULL,0,ma_period_1,0,ma_method,applied_price)+
              iMA(NULL,0,ma_period_2,0,ma_method,applied_price)+
              iMA(NULL,0,ma_period_3,0,ma_method,applied_price))/3;
     }
   return(0);
  }
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
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values 
//--- in the iMA indicator changed or if it is necessary to calculated the indicator 
//--- for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iMABuffer array is greater than the number of values 
      //--- in the iMA indicator for symbol/period, then we don't copy everything 
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, 
      //--- and since the last call of OnCalculate())
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
     }
   if(!FillArrayFromBuffer(iMABuffer,ma_shift,handle,values_to_copy)) return(0);
//==========================================================================
   for(int i=0; i<rates_total && !IsStopped(); i++)
     {
      int Boril=GetBorisKoeff();
      if(_Digits==4 || _Digits==2)
        {
         aquaUp1[i] = iMABuffer[i] + 6.18 * _Point * Boril;
         aquaDn1[i] = iMABuffer[i] - 6.18 * _Point * Boril;
         aquaUp2[i] = iMABuffer[i] + 16.18 * _Point * Boril;
         aquaDn2[i] = iMABuffer[i] - 16.18 * _Point * Boril;
         aquaUp3[i] = iMABuffer[i] + 26.18 * _Point * Boril;
         aquaDn3[i] = iMABuffer[i] - 26.18 * _Point * Boril;
         aquaUp4[i] = iMABuffer[i] + 36.18 * _Point * Boril;
         aquaDn4[i] = iMABuffer[i] - 36.18 * _Point * Boril;
        }
      if(_Digits==5 || _Digits==3)
        {
         aquaUp1[i] = iMABuffer[i] + 61.8 * _Point * Boril;
         aquaDn1[i] = iMABuffer[i] - 61.8 * _Point * Boril;
         aquaUp2[i] = iMABuffer[i] + 161.8 * _Point * Boril;
         aquaDn2[i] = iMABuffer[i] - 161.8 * _Point * Boril;
         aquaUp3[i] = iMABuffer[i] + 261.8 * _Point * Boril;
         aquaDn3[i] = iMABuffer[i] - 261.8 * _Point * Boril;
         aquaUp4[i] = iMABuffer[i] + 361.8 * _Point * Boril;
         aquaDn4[i] = iMABuffer[i] - 361.8 * _Point * Boril;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
int GetBorisKoeff()
  {
   if(Period()<=5) return(1);
   else if(Period() <= 15) return(2);
   else if(Period() <= 30) return(3);
   else if(Period() <= 60) return(4);
   else if(Period()<= 240) return(5);
   else if(Period()<=1440) return(7);
   else if(Period()<=10080) return(9);
   else return(15);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the MA indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],
                         int shift,
                         int ind_handle,
                         int amount)
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data, error code %d",GetLastError());
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
   Comment("");
  }  
//+------------------------------------------------------------------+
