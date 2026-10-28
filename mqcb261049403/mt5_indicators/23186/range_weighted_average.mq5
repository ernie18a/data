//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Tange weighted average"
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
double val[],valc[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Range weighted average ("+(string)inpPeriod+")");
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
   struct sRwAverage
   {
      double weight;
      double sumw;
      double price;
      double sump;
   };
   static sRwAverage m_array[];
   static int        m_arraySize=0;
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
         
         m_array[i].weight = _weight;
         m_array[i].price  = _weight*_price;
         if (i>inpPeriod)
         {
            m_array[i].sump =  m_array[i-1].sump+m_array[i].price -m_array[i-inpPeriod].price;
            m_array[i].sumw =  m_array[i-1].sumw+m_array[i].weight-m_array[i-inpPeriod].weight;
         }
         else 
         {
            m_array[i].sump = m_array[i].price;
            m_array[i].sumw = m_array[i].weight;
            for (int k=1; k<inpPeriod && i>=k; k++)
            {
               m_array[i].sump += m_array[i-k].price;
               m_array[i].sumw += m_array[i-k].weight;
            }
         }                     
      val[i]  = m_array[i].sump/m_array[i].sumw;
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(i);
}