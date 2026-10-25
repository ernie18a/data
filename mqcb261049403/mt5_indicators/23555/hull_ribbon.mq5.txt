//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Ribbon"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'235,255,235',C'255,235,235'
#property indicator_label2  "Hull fast"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_label3  "Hull slow"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3  2

//
//--- input parameters
//

input int                inpPeriod   = 14;          // Period
input double             inpDivisorf = 2.2;         // Fast "speed"
input double             inpDivisors = 1.8;         // Slow "speed"
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double valf[],valfc[],vals[],valsc[],fillu[],filld[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fillu,INDICATOR_DATA);
         SetIndexBuffer(1,filld,INDICATOR_DATA);
         SetIndexBuffer(2,valf ,INDICATOR_DATA);
         SetIndexBuffer(3,valfc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,vals ,INDICATOR_DATA);
         SetIndexBuffer(5,valsc,INDICATOR_COLOR_INDEX);
            iHull[0].init(inpPeriod,MathMax(inpDivisorf,inpDivisors));
            iHull[1].init(inpPeriod,MathMin(inpDivisorf,inpDivisors));
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Hull ribbon ("+(string)inpPeriod+","+(string)inpDivisorf+","+(string)inpDivisors+")");
   return (INIT_SUCCEEDED);
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

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      valf[i]  = fillu[i] = iHull[0].calculate(_price,i,rates_total);
      vals[i]  = filld[i] = iHull[1].calculate(_price,i,rates_total);
      valfc[i] = valsc[i] = (valf[i]>vals[i]) ? 1 :(valf[i]<vals[i]) ? 2 : (i>0) ? valfc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CHull
{
   private :
      int    m_fullPeriod;
      int    m_halfPeriod;
      int    m_sqrtPeriod;
      int    m_arraySize;
      double m_weight1;
      double m_weight2;
      double m_weight3;
      struct sHullArrayStruct
         {
            double value;
            double value3;
            double wsum1;
            double wsum2;
            double wsum3;
            double lsum1;
            double lsum2;
            double lsum3;
         };
      sHullArrayStruct m_array[];
   
   public :
      CHull() { init(1,2.0); };
     ~CHull() { ArrayFree(m_array); };
     
     ///
     ///
     ///
     
      bool init(int period, double divisor)
      {
            m_fullPeriod = (int)(period>1 ? period : 1);   
            m_halfPeriod = (int)(m_fullPeriod>1 ? m_fullPeriod/(divisor>1 ? divisor : 1) : 1);
            m_sqrtPeriod = (int) MathSqrt(m_fullPeriod);
            m_arraySize  = -1; m_weight1 = m_weight2 = m_weight3 = 1;
               return(true);
      }
      
      double calculate(double value, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
             
            m_array[i].value=value;
            if (i>m_fullPeriod)
            {
               m_array[i].wsum1 = m_array[i-1].wsum1+value*m_halfPeriod-m_array[i-1].lsum1;
               m_array[i].lsum1 = m_array[i-1].lsum1+value-m_array[i-m_halfPeriod].value;
               m_array[i].wsum2 = m_array[i-1].wsum2+value*m_fullPeriod-m_array[i-1].lsum2;
               m_array[i].lsum2 = m_array[i-1].lsum2+value-m_array[i-m_fullPeriod].value;
            }
            else
            {
               m_array[i].wsum1 = m_array[i].wsum2 =
               m_array[i].lsum1 = m_array[i].lsum2 = m_weight1 = m_weight2 = 0;
               for(int k=0, w1=m_halfPeriod, w2=m_fullPeriod; w2>0 && i>=k; k++, w1--, w2--)
               {
                  if (w1>0)
                  {
                     m_array[i].wsum1 += m_array[i-k].value*w1;
                     m_array[i].lsum1 += m_array[i-k].value;
                     m_weight1        += w1;
                  }                  
                  m_array[i].wsum2 += m_array[i-k].value*w2;
                  m_array[i].lsum2 += m_array[i-k].value;
                  m_weight2        += w2;
               }
            }
            m_array[i].value3=2.0*m_array[i].wsum1/m_weight1-m_array[i].wsum2/m_weight2;
         
            // 
            //---
            //
         
            if (i>m_sqrtPeriod)
            {
               m_array[i].wsum3 = m_array[i-1].wsum3+m_array[i].value3*m_sqrtPeriod-m_array[i-1].lsum3;
               m_array[i].lsum3 = m_array[i-1].lsum3+m_array[i].value3-m_array[i-m_sqrtPeriod].value3;
            }
            else
            {  
               m_array[i].wsum3 =
               m_array[i].lsum3 = m_weight3 = 0;
               for(int k=0, w=m_sqrtPeriod; w>0 && i>=k; k++, w--)
               {
                  m_array[i].wsum3 += m_array[i-k].value3*w;
                  m_array[i].lsum3 += m_array[i-k].value3;
                  m_weight3        += w;
               }
            }         
         return(m_array[i].wsum3/m_weight3);
      }
};
CHull iHull[2];
//------------------------------------------------------------------