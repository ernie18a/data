//+------------------------------------------------------------------+
//|                              e-Regr(barabashkakvn's edition).mq5 |
//|                                         © 2008 BJF Trading Group |
//|                                             www.iticsoftware.com |
//+------------------------------------------------------------------+
#property copyright "© 2008 BJF Trading Group"
#property link      "www.iticsoftware.com"
#property version   "1.001"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\PositionInfo.mqh>
#include <Trade\DealInfo.mqh>
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CPositionInfo  m_position;                   // trade position object
CDealInfo      m_deal;                       // deals object

#define major   1
#define minor   1
//+------------------------------------------------------------------+
//| Type of Regression Channel                                       |
//+------------------------------------------------------------------+
enum ENUM_Polynomial
  {
   linear=1,      // linear 
   parabolic=2,   // parabolic 
   Third_power=3, // third-power 
  };

input string _tmp1_=" --- Trade params ---";
input string TradeTime="3:00-21:20";
input double Lots=0.1;
input int StopLoss=0;
input int TakeProfit=0;
input int Slippage=3;
input ulong m_magic=20080829;                // m_magic
input int m_protection=1500;                 // protection size D1 bar

input string _tmp2_=" --- i-Regr ---";
input ENUM_Polynomial Regr_degree=Third_power;
input double Regr_kstd=2.0;
input int Regr_bars=250;
input int Regr_shift=0;

input string _tmp3_=" --- Trailing ---";
input bool TrailingOn=false;
input int TrailingStart= 30;
input int TrailingSize = 30;

int   RepeatN=3;
int   BuyCnt,SellCnt;

int   handle_i_Regr;                         // variable for storing the handle of the i-Regr indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- create handle of the indicator i-Regr
   handle_i_Regr=iCustom(Symbol(),Period(),"code\\8417\\i-Regr",
                         Regr_kstd,
                         Regr_degree,
                         Regr_bars,
                         Regr_shift
                         );
//--- if the handle is not created 
   if(handle_i_Regr==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the i-Regr indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(TrailingOn)
      TrailPositions();
//---
   string ind_name="i-Regr";
   double R_M0=i_RegrGet(0,0);
   double R_M1=i_RegrGet(0,1);

   double R_U0=i_RegrGet(1,0);
   double R_U1=i_RegrGet(1,1);

   double R_L0=i_RegrGet(2,0);
   double R_L1=i_RegrGet(2,1);

//--- refresh rates
   if(!RefreshRates())
      return;

//---
   if(m_symbol.Bid()>=R_M0)
     {
      ClosePositions(POSITION_TYPE_BUY);
     }

   if(m_symbol.Bid()<=R_M0)
     {
      ClosePositions(POSITION_TYPE_SELL);
     }
//---
   if(!IsTradeTime())
      return;

   if(iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)>m_protection*Point())
     {
      ClosePositions(POSITION_TYPE_BUY);
      ClosePositions(POSITION_TYPE_SELL);
      return;
     }

   if(PositionsCountBar0(Period())>0)
      return;

   RecountPositions();
//---
   double price,sl,tp;
   ulong m_ticket;

   if(iLow(Symbol(),Period(),0)<=R_L0)
     {
      if(BuyCnt > 0) return;
      //---  
      for(int i=0; i<RepeatN; i++)
        {
         if(!RefreshRates())
            return;
         price=m_symbol.Ask();

         sl=(StopLoss>0)?(price-StopLoss*Point()):0;
         tp=(TakeProfit>0)?(price+TakeProfit*Point()):0;

         if(m_trade.Buy(Lots,Symbol(),price,sl,tp))
           {
            m_ticket=m_trade.ResultDeal();
           }
         else
           {
            break;
           }
        }
      return;
     }
   if(iHigh(Symbol(),Period(),0)>=R_U0)
     {
      if(SellCnt > 0) return;
      //--- 
      for(int i=0; i<RepeatN; i++)
        {
         if(!RefreshRates())
            return;
         price=m_symbol.Bid();

         sl=(StopLoss > 0)?(price + StopLoss*Point()):0;
         tp=(TakeProfit > 0)?(price - TakeProfit*Point()):0;

         if(m_trade.Sell(Lots,Symbol(),price,sl,tp))
           {
            m_ticket=m_trade.ResultDeal();
           }
         else
           {
            break;
           }
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the i-Regr                              |
//|  the buffer numbers are the following:                           |
//|   0 - fx_buffer, 1 - sqh_buffer, 2 - sql_buffer                  |
//+------------------------------------------------------------------+
double i_RegrGet(const int buffer,const int index)
  {
   double i_Regr[];
   ArraySetAsSeries(i_Regr,true);
//--- reset error code 
   ResetLastError();
   int bars=Bars(Symbol(),Period());
//--- fill a part of the i_Regr Buffer array with values from the indicator buffer
   if(CopyBuffer(handle_i_Regr,buffer,0,Bars(Symbol(),Period()),i_Regr)<0)//index+1,i_Regr)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the i-Regr indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(i_Regr[index]);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Was "3:00-21:20", became "3:00" and "21:20"                      |
//+------------------------------------------------------------------+
void Split(string &result[],string to_split,string sep)
  {
   ushort u_sep;                  // The code of the separator character 
//--- Get the separator code 
   u_sep=StringGetCharacter(sep,0);
//--- Split the string to substrings 
   int k=StringSplit(to_split,u_sep,result);
   for(int j=0;j<k;j++)
     {
      string text=result[j];
      StringTrimLeft(text);
      StringTrimRight(text);
      result[j]=text;
     }
  }
//+------------------------------------------------------------------+
//| Calculation of Buy and Sell positions                            |
//+------------------------------------------------------------------+
void RecountPositions()
  {
   BuyCnt=0;
   SellCnt=0;

   int cnt=PositionsTotal();
   for(int i=0; i<cnt; i++)
     {
      if(!m_position.SelectByIndex(i))
         continue;
      if(m_position.Symbol()!=Symbol())
         continue;
      if(m_position.Magic()!=m_magic)
         continue;

      if(m_position.PositionType()==POSITION_TYPE_BUY)
         BuyCnt++;
      if(m_position.PositionType()==POSITION_TYPE_SELL)
         SellCnt++;
     }
  }
//+------------------------------------------------------------------+
//| Is Trade Time                                                    |
//+------------------------------------------------------------------+
bool IsTradeTime()
  {
   if(TradeTime=="0:00-24:00")
      return (true);
   if(TradeTime=="00:00-24:00")
      return (true);

   datetime tm1,tm2;

   string TI[];
   Split(TI,TradeTime,"-");
   if(ArraySize(TI)!=2)
      return (false);

   datetime tm0=TimeCurrent();
   tm1 = StringToTime(TimeToString(tm0, TIME_DATE) + " " + TI[0]);
   tm2 = StringToTime(TimeToString(tm0, TIME_DATE) + " " + TI[1]);

   bool isTm=false;
   if(tm1<=tm2)
      isTm=isTm || (tm1<= tm0 && tm0<tm2);
   else
      isTm=isTm || (tm1<=tm0 || tm0<tm2);

   return (isTm);
  }
//+------------------------------------------------------------------+
//| Count positions on Bar0                                          |
//+------------------------------------------------------------------+
int PositionsCountBar0(ENUM_TIMEFRAMES TF)
  {
//--- request trade history 
   datetime from_date=iTime(Symbol(),TF,0);
   if(!HistorySelect(from_date,TimeCurrent()))
      return(1);

   int positions=0;

   uint total=HistoryDealsTotal();
//--- for all deals 
   for(uint i=0;i<total;i++)
     {
      if(m_deal.SelectByIndex(i))
        {
         if(m_deal.Symbol()==Symbol() && m_deal.Magic()==m_magic &&
            (m_deal.Entry()==DEAL_ENTRY_IN || m_deal.Entry()==DEAL_ENTRY_INOUT) && m_deal.Time()>=from_date)
            positions++;
        }
     }
   return (positions);
  }
//+------------------------------------------------------------------+
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE position_type)
  {
   int cnt=PositionsTotal();
   for(int i=cnt-1; i>=0; i--)
     {
      if(!m_position.SelectByIndex(i))
         continue;
      if(m_position.Symbol()!=Symbol())
         continue;
      if(m_position.Magic()!=m_magic)
         continue;

      if(m_position.PositionType()!=position_type)
         continue;

      if(!RefreshRates())
         return;
      m_trade.PositionClose(m_position.Ticket());
      continue;
     }
  }
//+------------------------------------------------------------------+
//| Trail Positions                                                  |
//+------------------------------------------------------------------+
void TrailPositions()
  {
   int cnt=PositionsTotal();
   for(int i=0; i<cnt; i++)
     {
      if(!m_position.SelectByIndex(i))
         continue;
      if(m_position.Symbol()!=Symbol())
         continue;
      if(m_position.Magic()!=m_magic)
         continue;

      if(!RefreshRates())
         return;

      ENUM_POSITION_TYPE type=m_position.PositionType();
      if(type==POSITION_TYPE_BUY)
        {
         if(m_symbol.Bid()-m_position.PriceOpen()>TrailingStart*Point())
           {
            if(m_position.StopLoss()<m_symbol.Bid() -(TrailingSize+1)*Point())
              {
               m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-TrailingSize*Point(),m_position.TakeProfit());
              }
           }
        }

      if(type==POSITION_TYPE_SELL)
        {
         if(m_position.PriceOpen()-m_symbol.Ask()>TrailingStart*Point())
           {
            if(m_position.StopLoss()>m_symbol.Ask()+(TrailingSize+1)*Point() || m_position.StopLoss()==0)
              {
               m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+TrailingSize*Point(),m_position.TakeProfit());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
