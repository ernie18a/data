//--------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Rma MACD"
//--------------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Rma MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
#property indicator_label2  "Rma MACD signal line"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDodgerBlue,clrSandyBrown
#property indicator_style2  STYLE_DOT
//
//
//
input int                inpFastPeriod   = 12;           // MACD fast period
input int                inpSlowPeriod   = 26;           // MACD slow period
input int                inpSignalPeriod = 9;            // Signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;  // Price

//
//
//

double val[],valc[],sig[],sigc[];

//--------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,sig ,INDICATOR_DATA);
   SetIndexBuffer(3,sigc,INDICATOR_COLOR_INDEX);

         iRmaFast.init(inpFastPeriod);
         iRmaSlow.init(inpSlowPeriod);
         iRmaSignal.init(inpSignalPeriod);
   
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Rma MACD (%i,%i,%i)",inpFastPeriod,inpSlowPeriod,inpSignalPeriod));
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//
//
//

#define _setPrice(_priceType,_target,_index) { \
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
//
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
         val[i]  = iRmaFast.calculate(_price,i,rates_total)-iRmaSlow.calculate(_price,i,rates_total);
         sig[i]  = iRmaSignal.calculate(val[i],i,rates_total);
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 0 : 1 : 0;
         sigc[i] = (val[i]>sig[i]) ? 0 : 1;
   }          
   return(rates_total);
}

//--------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------
//
//
//

class CRma
{
   private :
      int   m_period1;
      int   m_period2;
      int   m_period3;
      struct sRmaStruct
      {
         double price;
         double summ1;
         double summ2;
         double summ3;
      };
      sRmaStruct m_array[];
      int        m_arraySize;
      
   public :
      CRma() : m_arraySize(-1), m_period1(1), m_period2(1), m_period3(1) {}
     ~CRma() {}
     
     //
     //
     //
     
     void init(int _period)
     {
         m_period1 = (_period>1) ? _period : 1;
         m_period2 = 2*m_period1;
         m_period3 = 3*m_period1;
     }
     double calculate(double value, int i, int bars)
     {
          if (m_arraySize<bars) m_arraySize = ArrayResize(m_array,bars+500);

         //
         //
         //
         m_array[i].price = value;
               if (i>m_period1)
                     m_array[i].summ1 = m_array[i-1].summ1 + m_array[i].price - m_array[i-m_period1].price;
               else
               {
                     m_array[i].summ1 = m_array[i].price;
                     for(int k=1; k<m_period1 && i>=k; k++)
                            m_array[i].summ1 += m_array[i-k].price;
               }         
               if (i>m_period2)
                     m_array[i].summ2 = m_array[i-1].summ2 + m_array[i].price - m_array[i-m_period2].price;
               else
               {
                     m_array[i].summ2 = m_array[i].price;
                     for(int k=1; k<m_period2 && i>=k; k++)
                            m_array[i].summ2 += m_array[i-k].price;
               }         
               if (i>m_period3)
                     m_array[i].summ3 = m_array[i-1].summ3 + m_array[i].price - m_array[i-m_period3].price;
               else
               {
                     m_array[i].summ3 = m_array[i].price;
                     for(int k=1; k<m_period3 && i>=k; k++)
                            m_array[i].summ3 += m_array[i-k].price;
               }
         return(m_array[i].summ3/(double)m_period3 - m_array[i].summ2/(double)m_period2 + m_array[i].summ1/(double)m_period1);         
     }
};
CRma iRmaFast,iRmaSlow,iRmaSignal;