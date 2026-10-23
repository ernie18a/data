//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "RMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1 2

//
//
//

input int                 inpPeriod    = 14;          // Period
input ENUM_APPLIED_PRICE  inpPrice     = PRICE_CLOSE; // Price

double val[],valc[];
int _calcPeriod1,_calcPeriod2,_calcPeriod3;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,val);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            _calcPeriod1 = (inpPeriod>1) ? inpPeriod : 1;
            _calcPeriod2 = 2*_calcPeriod1;
            _calcPeriod3 = 3*_calcPeriod1;
   //
   //---
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"RMA ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
   struct sRmaStruct
   {
      double price;
      double summ1;
      double summ2;
      double summ3;
   };
   static sRmaStruct m_array[];
   static int m_arraySize = -1;
          if (m_arraySize<rates_total)
          {
              m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0);
          }

   //
   //---
   //
                                    
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,m_array[i].price,i);
               if (i>_calcPeriod1)
                     m_array[i].summ1 = m_array[i-1].summ1 + m_array[i].price - m_array[i-_calcPeriod1].price;
               else
               {
                     m_array[i].summ1 = m_array[i].price;
                     for(int k=1; k<_calcPeriod1 && i>=k; k++)
                            m_array[i].summ1 += m_array[i-k].price;
               }         
               if (i>_calcPeriod2)
                     m_array[i].summ2 = m_array[i-1].summ2 + m_array[i].price - m_array[i-_calcPeriod2].price;
               else
               {
                     m_array[i].summ2 = m_array[i].price;
                     for(int k=1; k<_calcPeriod2 && i>=k; k++)
                            m_array[i].summ2 += m_array[i-k].price;
               }         
               if (i>_calcPeriod3)
                     m_array[i].summ3 = m_array[i-1].summ3 + m_array[i].price - m_array[i-_calcPeriod3].price;
               else
               {
                     m_array[i].summ3 = m_array[i].price;
                     for(int k=1; k<_calcPeriod3 && i>=k; k++)
                            m_array[i].summ3 += m_array[i-k].price;
               }         
         //
         //---
         //
         
         val[i]  = m_array[i].summ3/(double)_calcPeriod3 - m_array[i].summ2/(double)_calcPeriod2 + m_array[i].summ1/(double)_calcPeriod1;
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : 0 : 0;
   }               
   return(i);        
}