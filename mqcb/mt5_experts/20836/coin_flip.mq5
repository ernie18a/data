//+------------------------------------------------------------------+
//|                           Coin Flip(barabashkakvn's edition).mq5 |
//|                               Copyright 2015, Vladimir Gribachev |
//|                      https://www.mql5.com/ru/users/moneystrategy |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vladimir Gribachev"
#property link      "https://www.mql5.com/ru/users/moneystrategy"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedMargin *m_money;
//--- input parameters
input ushort   InpStopLoss       = 50;       // Stop Loss (in pips)
input ushort   InpTakeProfit     = 50;       // Take Profit (in pips)
input ushort   InpTrailingStop   = 15;       // Trailing Stop (in pips)
input ushort   InpTrailingStep   = 5;        // Trailing Step (in pips)
input double   InpLots           = 0;        // Lots (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input double   Risk              = 5;        // Risk (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input double   InpMartingale     = 1.8;      // Martingale
input double   InpMaxLots        = 1.0;      // Max lots
input ulong    m_magic           = 166399440;// magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//---
string            InpName="Label";         // Label name 
int               InpX=150;                // X-axis distance 
int               InpY=150;                // Y-axis distance 
string            InpFont="Tahoma";        // Font 
int               InpFontSize=9;           // Font size 
color             InpColor=clrRed;         // Color 
double            InpAngle=0.0;            // Slope angle in degrees 
ENUM_ANCHOR_POINT InpAnchor=ANCHOR_LEFT;   // Anchor type 
bool              InpBack=false;           // Background object 
bool              InpSelection=false;      // Highlight to move 
bool              InpHidden=true;          // Hidden in the object list 
long              InpZOrder=0;             // Priority for mouse click 

bool ru=false;
double last_lots_sl=0.0;
datetime PrevBars=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss    = InpStopLoss     * m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit   * m_adjusted_point;
   ExtTrailingStop= InpTrailingStop * m_adjusted_point;
   ExtTrailingStep= InpTrailingStep * m_adjusted_point;
//---
   if(!LotsOrRisk(InpLots,Risk,digits_adjust))
      return(INIT_PARAMETERS_INCORRECT);
   ru=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian"?true:false);
//---
   if(!LabelCreate(0,"Label0",0,5,26,CORNER_LEFT_UPPER,ru?"   Торговая информация по счету":"   Trading information"))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label1",0,5,32,CORNER_LEFT_UPPER,ru?"   ……………………………………………………………":"   ……………………………………………………"))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label2",0,5,130,CORNER_LEFT_UPPER,ru?"   ……………………………………………………………":"   ……………………………………………………"))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label3",0,5,46,CORNER_LEFT_UPPER,ru?"   Просадка: ":"   Drawdown: "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label4",0,5,59,CORNER_LEFT_UPPER,ru?"   Профит: ":"   Profit: "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label5",0,5,72,CORNER_LEFT_UPPER,ru?"   Заработано сегодня: ":"   Today: "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label6",0,5,85,CORNER_LEFT_UPPER,ru?"   Заработано вчера: ":"   Yesterday: "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label7",0,5,98,CORNER_LEFT_UPPER,ru?"   В текущем месяце: ":"   Current month: "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label8",0,5,111,CORNER_LEFT_UPPER,ru?"   В прошлом месяце: ":"   Previous month: "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label9",0,5,124,CORNER_LEFT_UPPER,ru?"   Текущая прибыль: ":"   Total profit: "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label11",0,!ru?115:145,46,CORNER_LEFT_UPPER," "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label12",0,!ru?115:145,59,CORNER_LEFT_UPPER," "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label13",0,!ru?115:145,72,CORNER_LEFT_UPPER," "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label14",0,!ru?115:145,85,CORNER_LEFT_UPPER," "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label15",0,!ru?115:145,98,CORNER_LEFT_UPPER," "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label16",0,!ru?115:145,111,CORNER_LEFT_UPPER," "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label17",0,!ru?115:145,124,CORNER_LEFT_UPPER," "))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label19",0,!ru?195:225,46,CORNER_LEFT_UPPER,"%"))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label20",0,!ru?195:225,59,CORNER_LEFT_UPPER,"%"))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label21",0,!ru?195:225,72,CORNER_LEFT_UPPER,m_account.Currency()))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label22",0,!ru?195:225,85,CORNER_LEFT_UPPER,m_account.Currency()))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label23",0,!ru?195:225,98,CORNER_LEFT_UPPER,m_account.Currency()))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label24",0,!ru?195:225,111,CORNER_LEFT_UPPER,m_account.Currency()))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Label25",0,!ru?195:225,124,CORNER_LEFT_UPPER,m_account.Currency()))
      return(INIT_FAILED);
//---
   MathSrand(GetTickCount());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(m_money!=NULL)
      delete m_money;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   Trailing();
//--- we work only at the time of the birth of new bar
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   int      count_buys  = 0;
   int      count_sells = 0;
   double   curr_profit=0.0;
   CalculatePositions(count_buys,count_sells,curr_profit);

   double loss=0;
   if(curr_profit<0)
      loss=(-1*curr_profit*100)/m_account.Balance();
   string  txt3=(DoubleToString(loss,2));

   double profit=0;
   if(curr_profit>0)
      profit=(1*curr_profit*100)/m_account.Balance();
   string  txt2=(DoubleToString(profit,2));

   double total_profit=0.0;
   double prev_month=0.0;
   double curr_month=0.0;
   double yesterday=0.0;
   double today=0.0;
   ProfitForPeriod(0,TimeCurrent()+60*60*24,total_profit,
                   prev_month,curr_month,yesterday,today);

   LabelTextChange(0,"Label11",txt3);
   LabelTextChange(0,"Label12",txt2);
   LabelTextChange(0,"Label13",DoubleToString(today,2));
   LabelTextChange(0,"Label14",DoubleToString(yesterday,2));
   LabelTextChange(0,"Label15",DoubleToString(curr_month,2));
   LabelTextChange(0,"Label16",DoubleToString(prev_month,2));
   LabelTextChange(0,"Label17",DoubleToString(total_profit,2));

   int coin=MathRand();
   if(count_buys+count_sells==0)
     {
      if(!RefreshRates())
         return;
      if(coin<8192 || coin>24575)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp);
        }
      else if(coin>8192 && coin<24575)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp);
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
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      long     deal_type         =-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            PrevBars=0;
            if(deal_reason==DEAL_REASON_SL && deal_commission+deal_swap+deal_profit<0.0)
               last_lots_sl=deal_volume;
            else
               last_lots_sl=0.0;
           }
     }
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
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f,the closest correct volume is%.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Lots or risk in percent for a deal from a free margin            |
//+------------------------------------------------------------------+
bool LotsOrRisk(const double lots,const double risk,const int digits_adjust)
  {
   if(lots<0.0 && risk<0.0)
     {
      Print(__FUNCTION__,",ERROR: Parameter(\"lots\" or \"risk\") can't be less than zero");
      return(false);
     }
   if(lots==0.0 && risk==0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" == 0.0 and \"risk\" == 0.0");
      return(false);
     }
   if(lots>0.0 && risk>0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" > 0.0 and \"risk\" > 0.0");
      return(false);
     }
   if(lots>0.0)
     {
      string err_text="";
      if(!CheckVolumeValue(lots,err_text))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(false);
        }
     }
   else if(risk>0.0)
     {
      if(m_money!=NULL)
         delete m_money;
      m_money=new CMoneyFixedMargin;
      if(m_money!=NULL)
        {
         if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
            return(INIT_FAILED);
         m_money.Percent(risk);
        }
      else
        {
         Print(__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
         return(INIT_FAILED);
        }
     }
//---
   return(true);
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
   datetime time=0; // datetime "0" -> D'1970.01.01 00:00:00'
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells,double &total_profit)
  {
   count_buys=0;
   count_sells=0;
   total_profit=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total_profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify BUY ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify SELL ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }

           }
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=0.0;
   if(Risk>0.0)
     {
      check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenLong returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_long_lot=InpLots;
   if(last_lots_sl>0.0)
      check_open_long_lot=last_lots_sl*InpMartingale;
   if(check_open_long_lot>InpMaxLots)
     {
      Print(__FUNCTION__,", ERROR: check_open_long_lot (",DoubleToString(check_open_long_lot,2),") > \"Max lots\" (",DoubleToString(check_open_long_lot,2),")");
      ExpertRemove();
      return;
     }
   check_open_long_lot=LotCheck(check_open_long_lot);
   if(check_open_long_lot==0)
     {
      Print(__FUNCTION__,", ERROR: LotCheck -> 0.0");
      return;
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);
   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenLong ("+DoubleToString(check_open_long_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=0.0;
   if(Risk>0.0)
     {
      check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenShort returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_short_lot=InpLots;
   if(last_lots_sl>0.0)
      check_open_short_lot=last_lots_sl*InpMartingale;
   if(check_open_short_lot>InpMaxLots)
     {
      Print(__FUNCTION__,", ERROR: check_open_short_lot (",DoubleToString(check_open_short_lot,2),") > \"Max lots\" (",DoubleToString(check_open_short_lot,2),")");
      ExpertRemove();
      return;
     }
   check_open_short_lot=LotCheck(check_open_short_lot);
   if(check_open_short_lot==0)
     {
      Print(__FUNCTION__,", ERROR: LotCheck -> 0.0");
      return;
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);
   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenShort ("+DoubleToString(check_open_short_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(InpLots,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
//int d=0;
  }
//+------------------------------------------------------------------+ 
//| Create a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelCreate(const long              chart_ID=0,// chart's ID 
                 const string            name="Label",             // label name 
                 const int               sub_window=0,             // subwindow index 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const string            text="Label",             // text 
                 const string            font="Tahoma",            // font 
                 const int               font_size=9,              // font size 
                 const color             clr=clrRed,               // color 
                 const double            angle=0.0,                // text slope 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,       // anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0)                // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Change the label text                                            | 
//+------------------------------------------------------------------+ 
bool LabelTextChange(const long   chart_ID=0,   // chart's ID 
                     const string name="Label", // object name 
                     const string text="Text")  // text 
  {
//--- reset the error value 
   ResetLastError();
//--- change object text 
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Profit for the period                                            |
//+------------------------------------------------------------------+
void ProfitForPeriod(const datetime from_date,const datetime to_date,double &total_profit,
                     double &prev_month,double &curr_month,double &yesterday,double &today)
  {
   total_profit   = 0.0;
   prev_month     = 0.0;
   curr_month     = 0.0;
   yesterday      = 0.0;
   today          = 0.0;
//---
   MqlRates rates_month[];
   ArraySetAsSeries(rates_month,true);
   if(CopyRates(m_symbol.Name(),PERIOD_MN1,0,2,rates_month)!=2)
      return;
   MqlRates rates_days[];
   ArraySetAsSeries(rates_days,true);
   if(CopyRates(m_symbol.Name(),PERIOD_D1,0,2,rates_days)!=2)
      return;
//--- request trade history 
   HistorySelect(from_date,to_date);
//---
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   long     position_id=0;
//--- for all deals 
   for(uint i=0;i<total;i++) // for(uint i=0;i<total;i++) => i #0 - 2016, i #1045 - 2017
     {
      //--- try to get deals ticket 
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         long deal_time          =HistoryDealGetInteger(ticket,DEAL_TIME);
         long deal_type          =HistoryDealGetInteger(ticket,DEAL_TYPE);
         long deal_entry         =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         long deal_magic         =HistoryDealGetInteger(ticket,DEAL_MAGIC);

         double deal_commission  =HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double deal_swap        =HistoryDealGetDouble(ticket,DEAL_SWAP);
         double deal_profit      =HistoryDealGetDouble(ticket,DEAL_PROFIT);

         string deal_symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         //--- only for current symbol and magic
         if(deal_magic==m_magic && deal_symbol==m_symbol.Name())
            if(ENUM_DEAL_ENTRY(deal_entry)!=DEAL_ENTRY_IN)
               if(ENUM_DEAL_TYPE(deal_type)==DEAL_TYPE_BUY || ENUM_DEAL_TYPE(deal_type)==DEAL_TYPE_SELL)
                 {
                  total_profit+=deal_commission+deal_swap+deal_profit;
                  if(rates_month[1].time>=deal_time && deal_time<rates_month[0].time)
                     prev_month+=deal_commission+deal_swap+deal_profit;

                  if(deal_time>=rates_month[0].time)
                     curr_month+=deal_commission+deal_swap+deal_profit;

                  if(rates_days[1].time>=deal_time && deal_time<rates_days[0].time)
                     yesterday+=deal_commission+deal_swap+deal_profit;

                  if(deal_time>=rates_days[0].time)
                     today+=deal_commission+deal_swap+deal_profit;
                 }
        }
     }
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
