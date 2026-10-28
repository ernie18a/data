//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Dual differentiator"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Dual differentiator"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2

//
//--- input parameters
//

input ENUM_APPLIED_PRICE inpPrice   = PRICE_MEDIAN; // Price
input double             inpFilter  = 5;            // Filter
input double             inpMinimal = 0;            // Minimal test value

//
//--- indicator buffers
//

double val[],valc[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Dual differentiator ("+(string)inpFilter+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
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
         val[i]  = iDualDifferentiator(_price,inpFilter,inpMinimal,i,rates_total);
         valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }          
   return(rates_total);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

double iDualDifferentiator(double price, double filter, double minValue, int i, int bars)
{
   struct iDualDifferentiatorStruct
      {
         double price;
         double smooth;
         double detrender;
         double period;
         double Q1;
         double Q2;
         double I1;
         double I2;
         double JI;
         double JQ;
         double res;
      };       
   static iDualDifferentiatorStruct m_array[];
   static int m_arraySize = -1;
          if (m_arraySize<bars)
          {
               m_arraySize=ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(price);
          }
   
      
   //
   //---
   //

      m_array[i].price = price; 
         if (i<6) { 
                     m_array[i].period = m_array[i].res = m_array[i].Q1 = m_array[i].Q2 = m_array[i].I1 = m_array[i].I2 = m_array[i].JI = m_array[i].JQ = 0;  
                     m_array[i].smooth = m_array[i].detrender =  price; 
                     return(0); 
                  }



      //
      //---
      //
      
      #define _calcComp(_ind) ((0.0962*m_array[i]._ind + 0.5769*m_array[i-2]._ind - 0.5769*m_array[i-4]._ind - 0.0962*m_array[i-6]._ind) * (0.075*m_array[i-1].period + 0.54))

         m_array[i].smooth     = (4.0*m_array[i].price+3.0*m_array[i-1].price+2.0*m_array[i-2].price+m_array[i-3].price)/10.0;
         m_array[i].detrender  = _calcComp(smooth);
         m_array[i].Q1         = _calcComp(detrender);
         m_array[i].I1         = m_array[i-3].detrender;
         m_array[i].JI         = _calcComp(I1);
         m_array[i].JQ         = _calcComp(Q1);
         m_array[i].I2         = 0.15*(m_array[i].I1-m_array[i].JQ) + 0.85*m_array[i-1].I2;
         m_array[i].Q2         = 0.15*(m_array[i].Q1+m_array[i].JI) + 0.85*m_array[i-1].Q2;

         //
         //---
         //

         double temp = m_array[i].Q2*(m_array[i].I2-m_array[i-1].I2)-
                       m_array[i].I2*(m_array[i].Q2-m_array[i-1].Q2);
                       m_array[i].period = m_array[i-1].period;
                    if (temp > minValue)
                        m_array[i].period = 6.2832*(m_array[i].I2*m_array[i].I2+m_array[i].Q2*m_array[i].Q2)/temp;
                        m_array[i].period = MathMin(m_array[i].period,1.50*m_array[i-1].period);
                        m_array[i].period = MathMax(m_array[i].period,0.67*m_array[i-1].period);
                        m_array[i].period = MathMin(MathMax(m_array[i].period,6),50);
                        m_array[i].period = 0.15*m_array[i].period+0.85*m_array[i-1].period;

   //
   //
   //
   //
   //

      double alpha = 2.0/(1.0+filter);
           m_array[i].res = m_array[i-1].res+alpha*(m_array[i].period-m_array[i-1].res);
   return (m_array[i].res);
}
