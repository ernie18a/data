//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Adaptive EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDimGray,clrMediumSeaGreen,clrPaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//---
//

input  int                inpPeriod = 14;          // Period
input  ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[]; double m_fastEnd,m_slowEnd; int m_period;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,val   ,INDICATOR_DATA);
   SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         m_period    = (inpPeriod>1) ? inpPeriod : 1;
         m_fastEnd   = MathMax(m_period/2.0,1);
         m_slowEnd   =         m_period*5;

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptive EMA ("+(string)m_period+")");
   return(INIT_SUCCEEDED);
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
   struct sEfrStruct
   {
      double price;
      double difference;
      double noise;
   };
   static sEfrStruct m_array[];
   static int        m_arraySize=-1;
                 if (m_arraySize<rates_total)
                 {
                     m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0);
                 }
                 
   //
   //
   //
                    
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      m_array[i].price      = _price;
      m_array[i].difference = (i>0) ? m_array[i].price-m_array[i-1].price : 0; if (m_array[i].difference<0) m_array[i].difference *= -1.0;

      //
      //
      //
                     
      double signal  = 0;
         if (i>m_period)
         {
                     signal           = m_array[i].price-m_array[i-m_period].price; if (signal<0) signal *= -1.0;
                     m_array[i].noise = m_array[i-1].noise + m_array[i].difference - m_array[i-m_period].difference;
         }         
         else       
         {
                     m_array[i].noise = m_array[i].difference;
                     for(int k=1; k<m_period && i>=k; k++) m_array[i].noise += m_array[i-k].difference;
         }
      
         //
         //
         //
             
      double efratio       = (m_array[i].noise!=0) ? signal/m_array[i].noise : 1;
      double averagePeriod = (m_array[i].noise!=0) ? ((signal/m_array[i].noise)*(m_slowEnd-m_fastEnd))+m_fastEnd : m_period;
      val[i]  = (i>0) ? val[i-1]+(2.0/(1.0+averagePeriod))*(_price -val[i-1]) : (_price);
      valc[i] = (i>0) ? val[i]>val[i-1] ? 1 : val[i]<val[i-1] ? 2 : valc[i-1] : 0;
   }      
   return(rates_total);
}