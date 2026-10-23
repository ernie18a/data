//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Corrected double smoothed Wilder's EMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Corrected average original"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_label2  "Corrected average "
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width2  3

//
//---
//

input int                inpPeriod           = 14;             // Average period
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE;    // Price
input int                inpCorrectionPeriod =  0;             // "Correction" period (<0 no correction,0 to 1 same as average)

//
//---
//

double val[],valc[],avg[],avgc[],avgw[];
int  ª_maPeriod,ª_corrPeriod; 
double _alpha;

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,avg ,INDICATOR_DATA);
         SetIndexBuffer(1,avgc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,val ,INDICATOR_DATA);
         SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,avgw,INDICATOR_CALCULATIONS);
         
         ª_corrPeriod = (inpCorrectionPeriod>0) ? inpCorrectionPeriod : (inpCorrectionPeriod<0) ? 0 : inpPeriod ;
         ª_maPeriod   = (inpPeriod>1) ? inpPeriod : 1;
            _alpha = 1.0 /MathSqrt(ª_maPeriod);
   //
   //---
   //      
   IndicatorSetString(INDICATOR_SHORTNAME,"\"Corrected\" Wilder\'s EMA ("+(string)inpPeriod+","+(string)inpCorrectionPeriod+")");
   return(0);
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      if (i>0)
      {
         avgw[i] = avgw[i-1] + _alpha*(_price-avgw[i-1]);
         avg[i]  = avg[i-1]  + _alpha*(avgw[i]-avg[i-1]);
      }
      else avg[i]  = avgw[i] = _price;
           val[i]  = iCorrMa(_price,avg[i],ª_corrPeriod,i,rates_total);
           avgc[i] = valc[i] = (avg[i]>val[i]) ? 1 : (avg[i]<val[i]) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//
//

double iCorrMa(double price, double average, int period, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1
      
      struct sCorrMaStruct
         {
            double corrected;
            double price;
            double price2;
            double summ;
            double summ2;
         };
      static sCorrMaStruct m_array[][_functionInstances];
      static int m_arraySize=0;
             if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<=bars) return(0); }
      
      //
      //---
      //
      
      m_array[i][¤].price  = price;
      m_array[i][¤].price2 = price*price;
      if (i>period)
            {
               m_array[i][¤].summ  = m_array[i-1][¤].summ +price               -m_array[i-period][¤].price;
               m_array[i][¤].summ2 = m_array[i-1][¤].summ2+m_array[i][¤].price2-m_array[i-period][¤].price2;
            }
      else  {
               m_array[i][¤].summ  = m_array[i][¤].price;
               m_array[i][¤].summ2 = m_array[i][¤].price2; 
               for(int k=1; k<period && i>=k; k++) 
               {
                  m_array[i][¤].summ  += m_array[i-k][¤].price; 
                  m_array[i][¤].summ2 += m_array[i-k][¤].price2; 
               }                  
            }         

      //
      //---
      //
      
      if (i>0) 
      {
         double v1 = (m_array[i][¤].summ2-m_array[i][¤].summ*m_array[i][¤].summ/(double)period)/(double)period;
         double v2 = (m_array[i-1][¤].corrected-average)*(m_array[i-1][¤].corrected-average);
         double c  = (v2<v1 || v2==0) ? 0 : 1.0-v1/v2;
            m_array[i][¤].corrected = m_array[i-1][¤].corrected + c*(average-m_array[i-1][¤].corrected);
      }
      else m_array[i][¤].corrected = average;
   return (m_array[i][¤].corrected);
   
   //
   //---
   //
   
   #undef ¤ #undef _functionInstances
}
//------------------------------------------------------------------
