//+------------------------------------------------------------------+
//|                                       FosterStewartCriterion.mqh |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
class CFosterStewartCriterion
  {
private:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_tf;
   bool              m_direct;
   int               m_price[],m_period,m_level,m_curprice,m_min,m_max,m_trend,m_deviation,m_h,m_l,m_minsl,m_spread;
   double            m_point,m_denom;
   void              StopOrder(int &m_stoploss,int &m_takeprofit);
public:
                     CFosterStewartCriterion();
                    ~CFosterStewartCriterion();
   void              Init(string inpSym,ENUM_TIMEFRAMES inpTF,bool inpTrendUp,int inpPeriod,int inpLevel);
   bool              CalcSignal(int &m_stoploss,int &m_takeprofit);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFosterStewartCriterion::CalcSignal(int &m_stoploss,int &m_takeprofit)
  {
//---
   m_curprice=(int)MathRound(iOpen(m_symbol,m_tf,0)/m_point);
   m_min=m_curprice;
   m_max=m_curprice;

   for(int i=m_period-1;i>0;i--)
     {
      m_price[i]=m_price[i-1];
      if(m_min>m_price[i])
         m_min=m_price[i];
      if(m_max<m_price[i])
         m_max=m_price[i];
     }
   m_price[0]=m_curprice;

   m_trend=0;
   m_deviation=0;
   for(int i=m_period-2;i>-1;i--)
     {
      m_h=1;
      m_l=1;
      for(int j=i+1;j<m_period;j++)
        {
         if(m_price[i]<=m_price[j])
            m_h=0;
         if(m_price[i]>=m_price[j])
            m_l=0;
         if(m_h<1 && m_l<1)
            break;
        }
      m_trend=m_trend+m_h-m_l;
      m_deviation=m_deviation+m_h+m_l;
     }

   if(m_direct==true)
     {
      if(m_trend<=m_level)
        {
         StopOrder(m_stoploss,m_takeprofit);
         return(true);
        }
     }
   else
     {
      if(m_trend>=m_level)
        {
         StopOrder(m_stoploss,m_takeprofit);
         return(true);
        }
     }

   return(false);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFosterStewartCriterion::StopOrder(int &m_stoploss,int &m_takeprofit)
  {
//---
   m_stoploss=m_max-m_min;
   m_takeprofit=m_minsl+(int)MathRound(m_deviation*m_stoploss/m_denom);
//проверяем стоп-лосс на минимальное значение
   m_spread=(int)SymbolInfoInteger(m_symbol,SYMBOL_SPREAD)+m_minsl;
   if(m_stoploss<m_spread)
      m_stoploss=m_spread;
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFosterStewartCriterion::Init(string inpSym,ENUM_TIMEFRAMES inpTF,bool inpTrendUp,int inpPeriod,int inpLevel)
  {
//---
   m_symbol=inpSym;
   m_tf=inpTF;
   m_direct=inpTrendUp;
   m_period=MathMax(3,inpPeriod);
   m_level=MathMax(1,MathMin(inpLevel,m_period-1));
   m_minsl=(int)MathMax(5,SymbolInfoInteger(m_symbol,SYMBOL_TRADE_STOPS_LEVEL));
   if(m_direct==true)
      m_level=-m_level;

   m_point=SymbolInfoDouble(m_symbol,SYMBOL_POINT);
   m_denom=m_period-1;

   ArrayResize(m_price,m_period);
   for(int i=1;i<m_period;i++)
      m_price[i-1]=(int)MathRound(iOpen(m_symbol,m_tf,i)/m_point);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFosterStewartCriterion::CFosterStewartCriterion(void) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFosterStewartCriterion::~CFosterStewartCriterion(void) {}
//+------------------------------------------------------------------+
