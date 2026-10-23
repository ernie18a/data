//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Range weighted smoothed EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrOrangeRed,clrMediumSeaGreen
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double val[],valc[],ª_alpha;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         
         ª_alpha = 2.0 / (1.0 + MathSqrt(inpPeriod>1 ? inpPeriod : 1));
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Range smoothed weighted EMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

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
   struct sRwEma
   {
      double num;
      double den;
      double num2;
      double den2;
      double ema;
   };
   static sRwEma m_array[];
   static int    m_arraySize=0;
             if (m_arraySize<rates_total)
             {
                 int _res = ArrayResize(m_array,rates_total+500);
                 if (_res<=rates_total) return(prev_calculated);
                     m_arraySize = _res;
             }
   
   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      double _weight = high[i]-low[i]; if (_weight==0) _weight=_Point;
      
         //
         //---
         //
         
         if (i>0)
               {
                  m_array[i].num  = m_array[i-1].num +ª_alpha*(_weight*_price -m_array[i-1].num);
                  m_array[i].den  = m_array[i-1].den +ª_alpha*(_weight        -m_array[i-1].den);
                  m_array[i].num2 = m_array[i-1].num2+ª_alpha*(m_array[i].num -m_array[i-1].num2);
                  m_array[i].den2 = m_array[i-1].den2+ª_alpha*(m_array[i].den -m_array[i-1].den2);
                  m_array[i].ema  = m_array[i-1].ema +ª_alpha*(m_array[i].num2/m_array[i].den2-m_array[i-1].ema);
               }
         else  {
                  m_array[i].num = m_array[i].num2 = _weight*_price;
                  m_array[i].den = m_array[i].den2 = _weight;
                  m_array[i].ema = _price;
               }                  
      val[i]  = m_array[i].ema;                  
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(i);
}