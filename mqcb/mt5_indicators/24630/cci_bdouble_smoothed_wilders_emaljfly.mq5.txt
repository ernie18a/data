//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "CCI of ds Wilder's EMA"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width4  2

//
//---
//

input  int                inpPeriod      = 50;            // CCI period
input  int                inpEmaPeriod  = 14;             // Wilder's EMA period
input  ENUM_APPLIED_PRICE inpPrice       = PRICE_TYPICAL; // Price
input int                 inpFlPeriod         = 25;       // Period for finding floating levels
input double              inpFlUp             = 90;       // Upper level %
input double              inpFlDown           = 10;       // Lower level %
enum chgColor
{
   chg_onSlope,  // change color on slope change
   chg_onLevel,  // Change color on outer levels cross
   chg_onMiddle, // Change color on middle level cross
};
input chgColor            inpColorOn          = chg_onLevel;    // Color change on :

double val[],valc[],levu[],levd[],levm[],ema1[],ema2[],_alpha;


//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levm,INDICATOR_DATA);
         SetIndexBuffer(2,levd,INDICATOR_DATA);
         SetIndexBuffer(3,val ,INDICATOR_DATA);
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,ema1   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,ema2   ,INDICATOR_CALCULATIONS);
            _workCci.init(inpPeriod);
            _alpha = 1.0 /MathSqrt(inpPeriod>1 ? inpPeriod : 1);

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI std based ("+(string)inpPeriod+")(ds Wilder's EMA "+(string)inpEmaPeriod+" smoothed)");
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
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      if (i>0)
      {
         ema1[i] = ema1[i-1] + _alpha*(_price -ema1[i-1]);
         ema2[i] = ema2[i-1] + _alpha*(ema1[i]-ema2[i-1]);
      }
      else ema1[i] = ema2[i] = _price;         
           val[i]  = _workCci.calculate(ema2[i],i,rates_total);
           
           //
           //---
           //
           
           if (prev_i!=i)
            {
               prev_i = i; 
               int start    = i-inpFlPeriod+1; if (start<0) start=0;
                   prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                   prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
            }
            double max   = (val[i] > prev_max) ? val[i] : prev_max;
            double min   = (val[i] < prev_min) ? val[i] : prev_min;
            double range = (max-min)/100.0;

                  levu[i] = min+inpFlUp  *range;
                  levd[i] = min+inpFlDown*range;
                  levm[i] = min+     50.0*range;
   
            //
            //---
            //
                              
            switch (inpColorOn)
            {
               case chg_onLevel  : valc[i] = (val[i]>levu[i]) ? 1 : (val[i]<levd[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               case chg_onMiddle : valc[i] = (val[i]>levm[i]) ? 1 : (val[i]<levm[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               default :           valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
            }                  
   }      
   return(rates_total);
}

//------------------------------------------------------------------
// Custom class(es)
//------------------------------------------------------------------
//
//---
//

class CCci
{
   private :
      struct sCciWork
      {
         double value;
         double value2;
         double summ;
         double summ2;
      };
      sCciWork  m_work[];
      int       m_period;
      double    m_period2;
      int       m_arraySize;
      
   public :
      CCci() { m_arraySize=-1; m_period=1; }
     ~CCci() { m_arraySize=-1; ArrayFree(m_work); }
     
     //
     //---
     //
     
     void   init(int period) { m_period=period; return; }
     double calculate(double value, int i, int bars)
     {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_work,bars+500); if (m_arraySize<bars) return(0); }
         
         //
         //---
         //
         
         m_work[i].value  = value;
         m_work[i].value2 = value*value;
            if (i>m_period)
                  {
                     m_work[i].summ  = m_work[i-1].summ +m_work[i].value -m_work[i-m_period].value;
                     m_work[i].summ2 = m_work[i-1].summ2+m_work[i].value2-m_work[i-m_period].value2;
                  }
            else  {
                     m_work[i].summ  = m_work[i].value;
                     m_work[i].summ2 = m_work[i].value2;
                     for (int k=1; k<m_period && i>=k; k++)
                     {
                        m_work[i].summ  += m_work[i-k].value; 
                        m_work[i].summ2 += m_work[i-k].value2; 
                     }
                  }         
         double _avg = m_work[i].summ/(double)m_period;
         double _dev = MathSqrt((m_work[i].summ2-m_work[i].summ*_avg)/(double)m_period);
         return(_dev!=0 ? (value-_avg)/(0.015*_dev) : 0);
     }
};
CCci _workCci;