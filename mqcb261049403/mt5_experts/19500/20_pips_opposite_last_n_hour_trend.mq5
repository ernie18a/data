//+------------------------------------------------------------------+
//|20 Pips Opposite Last N Hour Trend(barabashkakvn's edition).mq5   |
//+------------------------------------------------------------------+
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedMargin m_money;
//+------------------------------------------------------------------+
//| Enum hours                                                       |
//+------------------------------------------------------------------+
enum ENUM_HOURS
  {
   hour_00  =0,   // 00
   hour_01  =1,   // 01
   hour_02  =2,   // 02
   hour_03  =3,   // 03
   hour_04  =4,   // 04
   hour_05  =5,   // 05
   hour_06  =6,   // 06
   hour_07  =7,   // 07
   hour_08  =8,   // 08
   hour_09  =9,   // 09
   hour_10  =10,  // 10
   hour_11  =11,  // 11
   hour_12  =12,  // 12
   hour_13  =13,  // 13
   hour_14  =14,  // 14
   hour_15  =15,  // 15
   hour_16  =16,  // 16
   hour_17  =17,  // 17
   hour_18  =18,  // 18
   hour_19  =19,  // 19
   hour_20  =20,  // 20
   hour_21  =21,  // 21
   hour_22  =22,  // 22
   hour_23  =23,  // 23
  };
//--- input parameters
input uchar       InpMaxPositions         = 9;        // Max positions
input double      InpLots                 = 0.1;      // Lots (if "Lots"<=0.0 -> use "Risk")
input ushort      InpTakeProfit           = 20;       // Take Profit (in pips)
input double      Risk                    = 5;        // Risk in percent for a deal from a free margin
input double      InpMaxLot               = 5.0;      // Lot maximum
input ENUM_HOURS  InpTradingHour          = hour_07;  // Hour when position should be oppened
input uchar       InpHoursToCheckTrend    = 24;       // Hours to check price difference to see a "trend"
input uchar       InpFirstMultiplicator   = 2;        // Lot multiplier, if one position is unprofitable
input uchar       InpSecondMultiplicator  = 4;        // Lot multiplier, if two positions are unprofitable
input uchar       InpThirdMultiplicator   = 8;        // Lot multiplier, if three positions are unprofitable
input uchar       InpFourthMultiplicator  = 16;       // Lot multiplier, if four positions are unprofitable
input uchar       InpFifthMultiplicator   = 32;       // Lot multiplier, if five positions are unprofitable
input ulong       m_magic=129544128;// magic number
//---
ulong             m_slippage=30;                      // slippage
double            ExtTakeProfit=0.0;

double            m_adjusted_point;                   // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   if(InpLots>0.0)
     {
      string err_text="";
      if(!CheckVolumeValue(InpLots,err_text))
        {
         Print(err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtTakeProfit=InpTakeProfit        *m_adjusted_point;
//---
   if(InpLots<=0.0)
     {
      if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
         return(INIT_FAILED);
      m_money.Percent(Risk);
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
   if(TradeAllowed())
     {
      if(!RefreshRates())
         return;
      long pos_type=CheckForOpenPosition();
      if(pos_type!=0)
        {
         double lot=GetLots(pos_type);
         if(lot!=0.0 && lot<=InpMaxLot)
            OpenPosition(pos_type,lot);
        }
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| TradeAllowed function return true if trading is possible         |
//+------------------------------------------------------------------+
bool TradeAllowed()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return(false);
   PrevBars=time_0;

   int pos_current_day=0;
   int pos_total=0;
   CalculatePositionsAtCurrentDay(pos_current_day,pos_total);

   if(pos_current_day>0)
      return(false);
   if(pos_total>=InpMaxPositions)
      return(false);

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(str1.hour!=InpTradingHour && pos_total>0)
     {
      CloseAllPositions();
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate positions at current day                               |
//+------------------------------------------------------------------+
void CalculatePositionsAtCurrentDay(int &pos_current_day,int &pos_total)
  {
   pos_current_day=0;
   pos_total=0;
   MqlDateTime str1;
   MqlDateTime str_position;
   TimeToStruct(TimeCurrent(),str1);

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            TimeToStruct(m_position.Time(),str_position);
            if(str_position.day==str1.day)
               pos_current_day++;
            pos_total++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Checks of open short, long or nothing (-1, 1, 0)                 |
//+------------------------------------------------------------------+
int CheckForOpenPosition()
  {
   int result=0;
//--- long if last N hour was bearish - short when last N hour was bullish
   if(iClose(InpHoursToCheckTrend,m_symbol.Name(),PERIOD_H1)<iClose(1,m_symbol.Name(),PERIOD_H1))
      result=1;
   else
      result=-1;
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Get amount of lots to trade                                      |
//+------------------------------------------------------------------+
double GetLots(long pos_type)
  {
   double   lot=0.0;
   double   sl=0.0;
   int      coefficient=1.0;
   if(InpLots<=0)
     {
      if(pos_type==1)
        {
         lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
         if(lot==0.0)
            return(0.0);
        }
      else if(pos_type==-1)
        {
         lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
         if(lot==0.0)
            return(0.0);
        }
     }
   else
      lot=InpLots;

//--- request trade history 
   datetime from_date=TimeCurrent()-60*60*24*100;
   datetime to_date=TimeCurrent()+60*60*24;
   double profit_deal_1=0.0;  // latest deals
   double profit_deal_2=0.0;
   double profit_deal_3=0.0;
   double profit_deal_4=0.0;
   double profit_deal_5=0.0;
   datetime time_deal_1=D'2015.01.01 00:00';  // latest deals
   datetime time_deal_2=D'2015.01.01 00:00';
   datetime time_deal_3=D'2015.01.01 00:00';
   datetime time_deal_4=D'2015.01.01 00:00';
   datetime time_deal_5=D'2015.01.01 00:00';
   HistorySelect(from_date,to_date);
//---
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   long     position_id=0;
//--- for all deals 
   for(uint i=total-1;i>=0;i--)
     {
      //--- try to get deals ticket 
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         datetime deal_time      =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         long deal_type          =HistoryDealGetInteger(ticket,DEAL_TYPE);
         long deal_entry         =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         long deal_magic         =HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_commission  =HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double deal_swap        =HistoryDealGetDouble(ticket,DEAL_SWAP);
         double deal_profit      =HistoryDealGetDouble(ticket,DEAL_PROFIT);

         string deal_symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         //--- only for current symbol and magic
         if(deal_magic==m_magic && deal_symbol==m_symbol.Name())
            if(ENUM_DEAL_ENTRY(deal_entry)==DEAL_ENTRY_OUT)
               if(ENUM_DEAL_TYPE(deal_type)==DEAL_TYPE_BUY || ENUM_DEAL_TYPE(deal_type)==DEAL_TYPE_SELL)
                 {
                  double full_profit=deal_commission+deal_swap+deal_profit;
                  if(full_profit>=0.0)
                     break;
                  if(deal_time>time_deal_1 && time_deal_1==D'2015.01.01 00:00')
                    {
                     time_deal_1=deal_time;
                     coefficient=InpFirstMultiplicator;
                    }
                  else if(deal_time>time_deal_2 && time_deal_2==D'2015.01.01 00:00')
                    {
                     time_deal_2=deal_time;
                     coefficient=InpSecondMultiplicator;
                    }
                  else if(deal_time>time_deal_3 && time_deal_3==D'2015.01.01 00:00')
                    {
                     time_deal_3=deal_time;
                     coefficient=InpThirdMultiplicator;
                    }
                  else if(deal_time>time_deal_4 && time_deal_4==D'2015.01.01 00:00')
                    {
                     time_deal_4=deal_time;
                     coefficient=InpFourthMultiplicator;
                    }
                  else if(deal_time>time_deal_5 && time_deal_5==D'2015.01.01 00:00')
                    {
                     time_deal_5=deal_time;
                     coefficient=InpFifthMultiplicator;
                    }
                  else
                     break;
                 }
        }
     }
//---
   lot=LotCheck((double)coefficient*lot);
   if(lot==0.0)
      return(0.0);
//---
   return(lot);
  }
//+------------------------------------------------------------------------------------+
//| Opens position according to arguments (-1 short || 1 long, amount of Lots to trade |
//+------------------------------------------------------------------------------------+
void OpenPosition(long ShortLong,double Lots)
  {
   if(ShortLong==1)
     {
      double sl=0.0;
      double tp=(InpTakeProfit==0.0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      OpenBuy(0.0,tp,Lots);
     }
   if(ShortLong==-1)
     {
      double sl=0.0;
      double tp=(InpTakeProfit==0.0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      OpenSell(0.0,tp,Lots);
     }
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,double lot)
  {
   sl=0.0;
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //PrintResult(m_trade,m_symbol);
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp,double lot)
  {
   sl=0.0;
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //PrintResult(m_trade,m_symbol);
           }
        }
//---
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
