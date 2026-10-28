//+------------------------------------------------------------------+
//|                             PROphet(barabashkakvn's edition).mq5 |
//|                                                        PraVedNiK |
//|                                                  taa-34@mail.ru  |        
//+------------------------------------------------------------------+
#property link      "taa-34@mail.ru"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input bool     daBUY=true;
input int      x1=9;
input int      x2=29;
input int      x3=94;
input int      x4=125;
input ushort   Inp_slb=68;                   // slb
input bool     daSELL=true;
input int      y1=61;
input int      y2=100;
input int      y3=117;
input int      y4=31;
input ushort   Inp_sls=72;                   // sls

static datetime  prevtime=0;
double      lot=0.1;
ulong       m_magic=74;                      // magic number
double      Ext_slb=0.0;
double      Ext_sls=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- РУЛЬ на M5_EURUSD ---
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   Ext_slb=Inp_slb*digits_adjust;
   Ext_sls=Inp_sls*digits_adjust;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==prevtime)
      return;
   prevtime=time_0;

   if(!IsTradeAllowed())
      return;

   int all_positions=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            all_positions++;
            if(m_position.PositionType()==POSITION_TYPE_BUY && daBUY)
               BBB(true);
            if(m_position.PositionType()==POSITION_TYPE_SELL && daSELL)
               SSS(true);
           }

   if(all_positions==0)
     {
      if(daBUY)
         BBB(false);
      if(daSELL)
         SSS(false);
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BBB(bool selected)
  {
   if(!RefreshRates())
      return;

   if(!IsTradeAllowed())
      return;

   double sprb=m_symbol.Spread()+2*Ext_slb;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(selected)
     {
      if(str1.hour>18)
        {
         m_trade.PositionClose(m_position.Ticket());
        }
      else
        {
         if(m_symbol.Bid()>(m_position.StopLoss()+sprb*Point()))
            if(!m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-Ext_slb*Point(),0.0))
               prevtime=0;
        }
     }

   if(Qu(x1,x2,x3,x4)>0 && str1.hour>=10 && str1.hour<=18)
     {
      if(!m_trade.Buy(lot,Symbol(),m_symbol.Ask(),m_symbol.Ask()-Ext_slb*Point(),0.0,"ДлинняК"))
         prevtime=0;
      else
         PlaySound("ok.wav");
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SSS(bool selected)
  {
   if(!RefreshRates())
      return;

   if(!IsTradeAllowed())
      return;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   double sprs=m_symbol.Spread()+2*Ext_sls;

   if(selected)
     {
      if(str1.hour>18)
        {
         m_trade.PositionClose(m_position.Ticket());
        }
      else
        {
         if(m_symbol.Ask()<(m_position.StopLoss()-sprs*Point()))
            if(!m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+Ext_sls*Point(),0.0))
               prevtime=0;
        }
     }

   if(Qu(y1,y2,y3,y4)>0 && str1.hour>=10 && str1.hour<=18)
     {
      if(!m_trade.Sell(lot,Symbol(),m_symbol.Bid(),m_symbol.Bid()+Ext_sls*Point(),0.0,"КороТыШ"))
         prevtime=0;
      else
         PlaySound("ok.wav");
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Qu(int q1,int q2,int q3,int q4)
  {
   return((q1-100)*MathAbs(iHigh(m_symbol.Name(),Period(),1)-iLow(m_symbol.Name(),Period(),2))+
          (q2-100)*MathAbs(iHigh(m_symbol.Name(),Period(),3)-iLow(m_symbol.Name(),Period(),2))+
          (q3-100)*MathAbs(iHigh(m_symbol.Name(),Period(),2)-iLow(m_symbol.Name(),Period(),1))+
          (q4-100)*MathAbs(iHigh(m_symbol.Name(),Period(),2)-iLow(m_symbol.Name(),Period(),3)));
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
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
