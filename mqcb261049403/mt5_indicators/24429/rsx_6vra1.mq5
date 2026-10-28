//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Rsx"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//---
//

input int                inpPeriod = 14;          // Period
input double             inpSpeed  = 0.5;         // "Speed" (0.5 for original RSX)
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[];

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            iVolatilityRatio.init(inpPeriod);
   //            
   //----
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsx (vra)("+(string)inpPeriod+")");
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

//
//---
//


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      double _ratio = iVolatilityRatio.calculate(_price,i,rates_total);
            iRsx.init(inpPeriod/_ratio,inpSpeed);
      val[i]  = iRsx.calculate(_price,i,rates_total);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0 ;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cRsx
{
   private :
      double speed;
      double speedp1;
      double kg;
      double hg;
      double m_array[][13];
      double m_arraySize;
   public :       
      cRsx() : m_arraySize(-1) {  }
     ~cRsx()                   { ArrayFree(m_array); } 
   
      //
      //
      //
      
      void init(double _period, double _speed)
      {
            kg       = 3.0/(2.0+(_period>1 ? _period : 1));
            hg       = 1.0-kg;
            speed    = (_speed>0) ? (_speed<1) ? _speed : 1 : 0;
            speedp1  = speed+1.0;
      }
      
      double calculate(double price, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         double res  = 50;
         m_array[i][12]=price;
         if (i>0)
         {
               double mom = m_array[i][12]-m_array[i-1][12];
               double moa = (mom>0) ? mom : -mom;

               #define _mom(_a,_b) (speedp1*m_array[i][_a] - speed*m_array[i][_b])

                  m_array[i][ 0] = kg*mom            + hg*m_array[i-1][ 0];
                  m_array[i][ 1] = kg*m_array[i][ 0] + hg*m_array[i-1][ 1];
                  m_array[i][ 2] = kg*_mom(0,1)      + hg*m_array[i-1][ 2];
                  m_array[i][ 3] = kg*m_array[i][ 2] + hg*m_array[i-1][ 3];
                  m_array[i][ 4] = kg*_mom(2,3)      + hg*m_array[i-1][ 4];
                  m_array[i][ 5] = kg*m_array[i][ 4] + hg*m_array[i-1][ 5];
                  m_array[i][ 6] = kg*moa            + hg*m_array[i-1][ 6];
                  m_array[i][ 7] = kg*m_array[i][ 6] + hg*m_array[i-1][ 7];
                  m_array[i][ 8] = kg*_mom(6,7)      + hg*m_array[i-1][ 8];
                  m_array[i][ 9] = kg*m_array[i][ 8] + hg*m_array[i-1][ 9]; 
                  m_array[i][10] = kg*_mom(8,9)       + hg*m_array[i-1][10];
                  m_array[i][11] = kg*m_array[i][10] + hg*m_array[i-1][11]; 

                  mom = _mom( 4, 5);
                  moa = _mom(10,11);
                  #undef _mom 

            //
            //---
            //
            
            res = (mom/(moa>DBL_MIN?moa:DBL_MIN)+1.0)*50.0;
               if (res>100) res=100;
               if (res<  0) res=  0;
         }         
         else for(int k=0; k<12; k++) m_array[i][k]=0; 
         return(res);
      }      
};
cRsx iRsx;

class cStdDevVolatilityRatio
{
   private :
      int m_period;
      int m_arraySize;
         struct sStdDevVolatilityRatioStruct
         {
            public :
               double price;
               double price2;
               double sum;
               double sum2;
               double sumd;
               double deviation;
         };
      sStdDevVolatilityRatioStruct m_array[];
   public:
      cStdDevVolatilityRatio() : m_arraySize(-1) {  }
     ~cStdDevVolatilityRatio()                   { ArrayFree(m_array); }

      //
      //---
      //

      void init(int period)
      {
         m_period = (period>1) ? period : 1;
      }
      
      double calculate(double price, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

            m_array[i].price =price;
            m_array[i].price2=price*price;
            
            //
            //---
            //
            
            if (i>m_period)
            {
                  m_array[i].sum  = m_array[i-1].sum +m_array[i].price -m_array[i-m_period].price;
                  m_array[i].sum2 = m_array[i-1].sum2+m_array[i].price2-m_array[i-m_period].price2;
            }
            else  
            {
                  m_array[i].sum  = m_array[i].price;
                  m_array[i].sum2 = m_array[i].price2; 
                  for(int k=1; k<m_period && i>=k; k++) 
                  {
                        m_array[i].sum  += m_array[i-k].price; 
                        m_array[i].sum2 += m_array[i-k].price2; 
                  }                  
            }         
            m_array[i].deviation = (MathSqrt((m_array[i].sum2-m_array[i].sum*m_array[i].sum/(double)m_period)/(double)m_period));
            if (i>m_period) 
                  m_array[i].sumd  = m_array[i-1].sumd +m_array[i].deviation -m_array[i-m_period].deviation;
            else
            {
                  m_array[i].sumd = m_array[i].deviation;
                  for(int k=1; k<m_period && i>=k; k++) 
                        m_array[i].sumd += m_array[i-k].deviation; 
            }

            double deviationAverage = m_array[i].sumd/(double)m_period;
            return(deviationAverage != 0 ? m_array[i].deviation/deviationAverage : 1);
      }
};
cStdDevVolatilityRatio iVolatilityRatio;

//------------------------------------------------------------------