//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Triangular moving average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrMediumSeaGreen
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Triangular moving average ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

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
         val[i]  = iTma(_price,inpPeriod,i,rates_total);
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

double iTma(double price, int period, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1
      struct sTmaArrayStruct
         {
            double price;
            double summ;
            double summ2;
         };
      struct sTmaCoeffStruct
         {
            int period;
            int period1;
            int period2;
         };
      static sTmaArrayStruct m_array[][_functionInstances];
      static sTmaCoeffStruct m_coeff[_functionInstances];
      static int m_arraySize=0;
             if (m_arraySize<bars)
             {
                 int _res = ArrayResize(m_array,bars+500);
                 if (_res<=bars) return(0);
                     m_arraySize = _res;
             }
             if (m_coeff[¤].period!=period)
             {
                  m_coeff[¤].period  = period;
                  m_coeff[¤].period1 = int((period+1.0)*0.5);
                  m_coeff[¤].period2 = int((period+2.0)*0.5);
             }

      //
      //---
      //

      m_array[i][¤].price=price;
      if (i>period)
         {
              m_array[i][¤].summ  = m_array[i-1][¤].summ +price             -m_array[i-m_coeff[¤].period1][¤].price;
              m_array[i][¤].summ2 = m_array[i-1][¤].summ2+m_array[i][¤].summ-m_array[i-m_coeff[¤].period2][¤].summ;
         }              
      else   
         {
            m_array[i][¤].summ2 = 0; 
            m_array[i][¤].summ  = price; 
            for(int k=1; k<m_coeff[¤].period2 && i>=k; k++) 
            {
               if (k<m_coeff[¤].period1) m_array[i][¤].summ  += m_array[i-k][¤].price; 
                                         m_array[i][¤].summ2 += m_array[i-k][¤].summ; 
            }
            m_array[i][¤].summ2 += m_array[i][¤].summ;
         }            
      return (m_array[i][¤].summ2/(double)m_coeff[¤].period2/(double)m_coeff[¤].period1);

   //
   //---
   //

   #undef ¤ #undef _functionInstances
}
//------------------------------------------------------------------