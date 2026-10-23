//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Liner regression value"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrMediumSeaGreen
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod = 20;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double val[],valc[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   //--- indicator short name assignment
         IndicatorSetString(INDICATOR_SHORTNAME,"Linear regression value ("+(string)inpPeriod+")");
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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         val[i]  = iLinr(_price,inpPeriod,i,rates_total);
         valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iLinr(double price, int period, int i, int bars, int instance=0)
{
   #define ¤ instance
      #define _functionInstances 1
      struct sLinrArrayStruct
         {
            double price;
            double wsumm;
            double psumm;
            double weight;
         };
      static sLinrArrayStruct m_array[][_functionInstances];
      static int m_arraySize=0;
             if (m_arraySize<bars)
             {
                 int _res = ArrayResize(m_array,bars+500);
                 if (_res<=bars) return(0);
                     m_arraySize = _res;
             }

      //
      //---
      //
      
      m_array[i][¤].price=price;
      if (i>period)
      {
            m_array[i][¤].weight = m_array[i-1][¤].weight;
            m_array[i][¤].wsumm  = m_array[i-1][¤].wsumm+price*period-m_array[i-1][¤].psumm;
            m_array[i][¤].psumm  = m_array[i-1][¤].psumm+price-m_array[i-period][¤].price;
      }
      else
      {
            m_array[i][¤].wsumm  = 0;
            m_array[i][¤].psumm  = 0;
            m_array[i][¤].weight = 0;
            for(int k=0,w=period; k<period && i>=k; k++,w--)
            {
               m_array[i][¤].wsumm  += m_array[i-k][¤].price*w;
               m_array[i][¤].psumm  += m_array[i-k][¤].price;
               m_array[i][¤].weight += w;
            }
      }         
      return(3.0*m_array[i][¤].wsumm/m_array[i][¤].weight-2.0*m_array[i][¤].psumm/(double)period);

   #undef ¤ #undef _functionInstances
}
//------------------------------------------------------------------