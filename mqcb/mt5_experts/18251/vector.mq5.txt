//+------------------------------------------------------------------+
//|                              Vector(barabashkakvn's edition).mq5 |
//|                               Copyright ©BFE 2006 Software Corp. |
//|                                                BFE2006@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright ©BFE 2006 Software Corp."
#property link      "BFE2006@yandex.ru"
#property version "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedRisk m_money;
//---
input int     MAGIC=0;
input double LotsPercent=1;       //процент для рассчета лота
input double PrcProfit=0.5;      //процент для рассчета профита
input double PrcLose=30;          //прцент фиксации убытков
input ENUM_TIMEFRAMES InpPeriod=PERIOD_M15;  //период МА
input int InpMaPeriod_one=3;
input int InpMaPeriod_two=7;
input int InpMaShift=8;
input double   Risk=5;         // Risk in percent for a deal from a free margin
//---
double        Free,Balans;
double        Pips_Profit,PR,ST;
double        m1,m2,m3,m4,m5,m6,m7,m8,m9;
string        SMB,TOTAL_TREND="",arr_symbols[4]={"EURUSD","GBPUSD","USDCHF","USDJPY"};
int total_pos_EURUSD=0,total_pos_GBPUSD=0,total_pos_USDCHF=0,total_pos_USDJPY=0;
//---
int arr_handles[8];
double arr_adjusted_point[4];
ulong          m_magic=109214238;            // magic number
ulong          m_slippage=30;                // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//---
   for(int i=0;i<4;i++)
     {
      for(int j=0;j<4;j++)
        {
         if(!iMAGreate(arr_handles[i],arr_symbols[j],InpPeriod,InpMaPeriod_one,InpMaShift))
           {
            return(INIT_FAILED);
           }
        }
     }
   for(int i=4;i<8;i++)
     {
      for(int j=0;j<4;j++)
        {
         if(!iMAGreate(arr_handles[i],arr_symbols[j],InpPeriod,InpMaPeriod_two,InpMaShift))
           {
            return(INIT_FAILED);
           }
        }
     }
   for(int j=0;j<4;j++)
     {
      if(!AdjustedPointGet(arr_symbols[j],arr_adjusted_point[j]))
        {
         return(INIT_FAILED);
        }
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
//---------- Запоминаем основные параметры
   SMB=Symbol();                           //Символ валютной пары  
   Balans=m_account.Balance();                //Баланс
   Free=m_account.Equity();                   //Свободные средства
//--- consider the number of positions
   total_pos_EURUSD=0;total_pos_GBPUSD=0;total_pos_USDCHF=0;total_pos_USDJPY=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
           {
            if(m_position.Symbol()==arr_symbols[0])
               total_pos_EURUSD++;

            if(m_position.Symbol()==arr_symbols[1])
               total_pos_GBPUSD++;

            if(m_position.Symbol()==arr_symbols[2])
               total_pos_USDCHF++;

            if(m_position.Symbol()==arr_symbols[3])
               total_pos_USDJPY++;
           }
//---------- Рассчитываем дополнительные параметры
   m4=iMAGet(arr_handles[0],0);
   m5=iMAGet(arr_handles[1],0);
   m6=iMAGet(arr_handles[2],0);
   m1=iMAGet(arr_handles[3],0);
   m7=iMAGet(arr_handles[4],0);
   m8=iMAGet(arr_handles[5],0);
   m9=iMAGet(arr_handles[6],0);
   m2=iMAGet(arr_handles[7],0);

   double low_arr[],high_arr[];
   int copy=CopyLow(SMB,PERIOD_H4,1,50,low_arr);
   if(copy<50)
      return;
   copy=CopyHigh(SMB,PERIOD_H4,1,50,high_arr);
   if(copy<50)
      return;

   double low_average=0.0,high_average=0.0;
   for(int i=0;i<50;i++)
     {
      low_average+=low_arr[i];
      high_average+=high_arr[i];
     }
   low_average/=50.0;
   high_average/=50.0;

   double m_adjusted_point=0.0;
   if(!AdjustedPointGet(SMB,m_adjusted_point))
      return;

   double average=(high_average-low_average)/m_adjusted_point;

   Pips_Profit=(average<13)?13:average;

//---------- Принимаем решение в зависимости от количества позиций
   if(total_pos_EURUSD==0)
      Open_Oder1();
   if(total_pos_GBPUSD==0)
      Open_Oder2();
   if(total_pos_USDCHF==0)
      Open_Oder3();
   if(total_pos_USDJPY==0)
      Open_Oder4();

   if(total_pos_EURUSD==1)
      Pips();
   if(total_pos_GBPUSD==1)
      Pips();
   if(total_pos_USDCHF==1)
      Pips();
   if(total_pos_USDJPY==1)
      Pips();

   total_pos_EURUSD=0;total_pos_GBPUSD=0;total_pos_USDCHF=0;total_pos_USDJPY=0;
   return;
  }
//+------------------------------------------------------------------+
//| Open position 1 (EURUSD)                                         |
//+------------------------------------------------------------------+
void Open_Oder1()
  {
   MqlTick last_tick;
//--- 
   if(!SymbolInfoTick(arr_symbols[0],last_tick))
      return;

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)>0) //BUY
      if(m4>m7 && total_pos_EURUSD==0)
         OpenBuy(arr_symbols[0],last_tick.ask,0.0,0.0);

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)<0) //SELL
      if(m4<m7 && total_pos_EURUSD==0)
         OpenSell(arr_symbols[0],last_tick.bid,0.0,0.0);
  }
//+------------------------------------------------------------------+
//| Open position 1 (GBPUSD)                                         |
//+------------------------------------------------------------------+
void Open_Oder2()
  {
   MqlTick last_tick;
//--- 
   if(!SymbolInfoTick(arr_symbols[1],last_tick))
      return;

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)>0)
      if(m5>m8 && total_pos_GBPUSD==0)
         OpenBuy(arr_symbols[1],last_tick.ask,0.0,0.0);

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)<0) //SELL
      if(m5<m8 && total_pos_GBPUSD==0)
         OpenSell(arr_symbols[1],last_tick.bid,0.0,0.0);
  }
//+------------------------------------------------------------------+
//| Open position 1 (USDCHF)                                         |
//+------------------------------------------------------------------+
void Open_Oder3()
  {
   MqlTick last_tick;
//--- 
   if(!SymbolInfoTick(arr_symbols[2],last_tick))
      return;

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)>0)
      if(m6>m9 && total_pos_USDCHF==0)
         OpenBuy(arr_symbols[2],last_tick.ask,0.0,0.0);

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)<0) //SELL
      if(m6<m9 && total_pos_USDCHF==0)
         OpenSell(arr_symbols[2],last_tick.bid,0.0,0.0);
  }
//+------------------------------------------------------------------+
//| Open position 1 (USDJPY)                                         |
//+------------------------------------------------------------------+
void Open_Oder4()
  {
   MqlTick last_tick;
//--- 
   if(!SymbolInfoTick(arr_symbols[3],last_tick))
      return;

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)>0)
      if(m1>m2 && total_pos_USDJPY==0)
         OpenBuy(arr_symbols[3],last_tick.ask,0.0,0.0);

   if((m4+m5+m6+m1)-(m7+m8+m9+m2)<0) //SELL
      if(m1<m2 && total_pos_USDJPY==0)
         OpenSell(arr_symbols[3],last_tick.bid,0.0,0.0);
  }
//+------------------------------------------------------------------+
//| If one market order - pips                                       |
//+------------------------------------------------------------------+
void Pips()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
           {
            string pos_symbol=m_position.Symbol();
            if(pos_symbol==arr_symbols[0] || pos_symbol==arr_symbols[1] ||
               pos_symbol==arr_symbols[2] || pos_symbol==arr_symbols[3])
              {
               MqlTick last_tick;
               if(!SymbolInfoTick(pos_symbol,last_tick))
                  continue;
               double m_adjusted_point=0.0;
               if(!AdjustedPointGet(pos_symbol,m_adjusted_point))
                  continue;
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  if(m_position.PriceOpen()+Pips_Profit*m_adjusted_point<last_tick.bid)
                     m_trade.PositionClose(m_position.Ticket());
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  if(m_position.PriceOpen()-Pips_Profit*m_adjusted_point>last_tick.ask)
                     m_trade.PositionClose(m_position.Ticket());
              }

           }
//--- контроль прибыли
   PR=m_account.Balance()+(Balans/100*PrcProfit);
   PR=(NormalizeDouble((PR),2));
   if((Free-Balans)>=(Balans/100*PrcProfit))
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Magic()==m_magic)
              {
               string pos_symbol=m_position.Symbol();
               if(pos_symbol==arr_symbols[0] || pos_symbol==arr_symbols[1] ||
                  pos_symbol==arr_symbols[2] || pos_symbol==arr_symbols[3])
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
              }
     }//--- контроль убытков 
   ST=m_account.Balance()-(Balans/100*PrcLose);
   ST=(NormalizeDouble((ST),2));
   if((Free-Balans)<=(-(Balans/100*PrcLose)))
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Magic()==m_magic)
              {
               string pos_symbol=m_position.Symbol();
               if(pos_symbol==arr_symbols[0] || pos_symbol==arr_symbols[1] ||
                  pos_symbol==arr_symbols[2] || pos_symbol==arr_symbols[3])
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
              }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool iMAGreate(int &handle_iMA,const string symbol,const ENUM_TIMEFRAMES period,const int ma_period,const int ma_shitf)
  {
   bool result=true;
//--- create handle of the indicator iMA
   handle_iMA=iMA(symbol,period,ma_period,ma_shitf,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  symbol,
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(false);
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AdjustedPointGet(const string symbol,double &m_adjusted_point)
  {
   bool result=true;
//---
   ResetLastError();
   long digits=0;
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digits))
     {
      Print("AdjustedPointGet, ",symbol," SYMBOL_DIGITS error# ",GetLastError());
      return(false);
     }
   double point=0.0;
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
     {
      Print("AdjustedPointGet, ",symbol," SYMBOL_POINT error# ",GetLastError());
      return(false);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(digits==3 || digits==5)
      digits_adjust=10;
   m_adjusted_point=point*digits_adjust;
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(const string symbol,double ask,double sl,double tp)
  {
   sl=MyNormalizePrice(symbol,sl);
   tp=MyNormalizePrice(symbol,tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(symbol,0.01,ask,ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=0.01)
        {
         if(m_trade.Buy(0.01,symbol,ask,sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(const string symbol,double bid,double sl,double tp)
  {
   sl=MyNormalizePrice(symbol,sl);
   tp=MyNormalizePrice(symbol,tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(symbol,0.01,bid,ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=0.01)
        {
         if(m_trade.Sell(0.01,symbol,bid,sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Normalize price                                                  |
//+------------------------------------------------------------------+
double MyNormalizePrice(const string symbol,const double price)
  {
   double m_tick_size=0;
   if(!SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE,m_tick_size))
      return(0.0);

   int m_digits=0;
   long tmp=0;
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,tmp))
      return(0.0);
   m_digits=(int)tmp;

   if(m_tick_size!=0)
      return(NormalizeDouble(MathRound(price/m_tick_size)*m_tick_size,m_digits));
//---
   return(NormalizeDouble(price,m_digits));
  }
//+------------------------------------------------------------------+
