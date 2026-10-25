//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Juice ema deviation indicator"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_label1  "Juice fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'209,243,209',C'255,230,183'
#property indicator_label2  "Juice"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrSilver,clrLimeGreen,clrOrange
#property indicator_width2  2

//
//---
//

input int                inpPeriod = 32;             // Juice period
input int                inpLevel  = 14;             // Average deviation period (<= 1 for same as juice period)
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN;   // Price

//
//---
//

double val[],valc[],fill1[],fill2[],sumdev[],dev[]; int ª_levelsPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//---
//

int OnInit()
{
   SetIndexBuffer(0,fill1 ,INDICATOR_DATA);
   SetIndexBuffer(1,fill2 ,INDICATOR_DATA);
   SetIndexBuffer(2,val   ,INDICATOR_DATA);
   SetIndexBuffer(3,valc  ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,dev   ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,sumdev,INDICATOR_CALCULATIONS);
      ª_levelsPeriod = (inpLevel>1) ? inpLevel : inpPeriod;
   IndicatorSetString(INDICATOR_SHORTNAME,"Juice ema deviation ("+(string)inpPeriod+","+(string)ª_levelsPeriod +")");
   return(0);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

//
//---
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
            dev[i] = iEmaDeviation(_price,inpPeriod,i);
            if (i>ª_levelsPeriod )
                  sumdev[i] = sumdev[i-1]+dev[i]-dev[i-ª_levelsPeriod ];
            else {sumdev[i] = dev[i]; for (int k=1; k<ª_levelsPeriod  && i>=k; k++) sumdev[i] += dev[i-k]; }
            double _level = sumdev[i]/(double)ª_levelsPeriod ;

      //
      //---
      //
                     
      val[i]   = fill1[i] = dev[i];
      valc[i]  = (val[i]<_level) ? 2 : 1;
      fill2[i] = _level;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iEmaDeviation(double price, double period, int i, int _instance=0)
{
   //
   //---
   //
   
      #define _functionInstancesArraySize 2
      #define _functionArrayRingSize 16
      #ifdef  _functionInstances
            static double workEmaDeviation[_functionArrayRingSize][_functionInstancesArraySize*_functionInstances];
      #else static double workEmaDeviation[_functionArrayRingSize][_functionInstancesArraySize];
      #endif
            
      //
      //---
      //            
      
      #ifdef  _functionInstances
                int _winst = _instance*_functionInstancesArraySize;
      #else #define _winst _instance
      #endif

      #define _ema0 _winst
      #define _ema1 _winst+1

   //
   //---
   //
         
      int _indC = (i)%_functionArrayRingSize;
      if (i>period && period>1)
      {
         int    _indP  = (i-1)%_functionArrayRingSize;
         double _alpha = 2.0/(1.0+period);
            workEmaDeviation[_indC][_ema0] = workEmaDeviation[_indP][_ema0]+_alpha*(price      -workEmaDeviation[_indP][_ema0]);
            workEmaDeviation[_indC][_ema1] = workEmaDeviation[_indP][_ema1]+_alpha*(price*price-workEmaDeviation[_indP][_ema1]);
      }
      else  
         { 
            workEmaDeviation[_indC][_ema0] = price;
            workEmaDeviation[_indC][_ema1] = price*price; 
         }
   return(MathSqrt(period*(workEmaDeviation[_indC][_ema1]-workEmaDeviation[_indC][_ema0]*workEmaDeviation[_indC][_ema0])/(period>2 ? period-1.0 : 1)));

   //
   //---
   //

   #undef _ema0 #undef _ema1
   #undef _functionInstances #undef _functionArrayRingSize #undef _functionInstancesArraySize #undef _winst 
}
//------------------------------------------------------------------