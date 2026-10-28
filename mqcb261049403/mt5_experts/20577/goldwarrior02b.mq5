//+------------------------------------------------------------------+
//|                      GoldWarrior02b(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Nick Bilak"
#property link "www.forex-tsd.com"
#property version   "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin *m_money;
//--- input parameters
input double   InpLots           = 0.1;      // Lots
input ushort   InpStopLoss       = 100;      // Stop Loss (in pips)
input ushort   InpTakeProfit     = 150;      // Take Profit (in pips)
input ushort   InpTrailingStop   = 5;        // Trailing Stop (in pips)
input ushort   InpTrailingStep   = 5;        // Trailing Step (in pips)
input int      InpPeriod         = 21;       // Averaging period (for "Impulse" and "CCI")
input int      InpDepth          = 12;       // ZigZag: Depth
input int      InpDeviation      = 5;        // ZigZag: Deviation
input int      InpBackstep       = 3;        // ZigZag: Backstep
input double   InpProfitCloseAll = 300.0;    // Profit target for closing all positions
input bool     InpOutputInChart  = true;     // Output, "false" -> in "Experts", "true" -> in Chart
input int      InpInpulsSell     = -30;      // Negative impulse value for Sell signal
input int      InpInpulsBuy      = 30;       // Positive impulse value for Buy signal
input uchar    InpMultiplier     = 3;        // Multiplier of hedge positions of 1st and 2nd level
//---
datetime LastTradeTime=0;
double down=0,imp=0,mlot=0;
int ssig=0,bsig=0,bsb=0,bloks=0,blokb=0,pm=0,blok=1;
//---

//---
ulong          m_ticket;
ulong          m_magic=49778992;             // magic number
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;

int            handle_iCCI;                  // variable for storing the handle of the iCCI indicator 
int            handle_iCustom_Impulse;        // variable for storing the handle of the iCustom indicator 
int            handle_iCustom_ZZ;            // variable for storing the handle of the iCustom indicator

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      Alert(__FUNCTION__," ERROR: Trailing is not possible: the parameter \"Trailing Step\" is zero!");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(__FUNCTION__,", ERROR: ",err_text);
      return(INIT_PARAMETERS_INCORRECT);
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(m_symbol.Name(),Period(),InpPeriod,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iCCI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom_Impulse=iCustom(m_symbol.Name(),Period(),"Impulse",InpPeriod);
//--- if the handle is not created 
   if(handle_iCustom_Impulse==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom (\"Impulse\") indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom_ZZ=iCustom(m_symbol.Name(),Period(),"Examples\\ZigZag",InpDepth,InpDeviation,InpBackstep);
//--- if the handle is not created 
   if(handle_iCustom_ZZ==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom (\"ZigZag\") indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
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
   if(TimeCurrent()-LastTradeTime<15)
      return;
//---
   int sbo=0,s=0,b=0;
   double summa=0.0,ssum=0.0,bsum=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            sbo=sbo+1;//have open trades
            summa=summa+m_position.Commission()+m_position.Swap()+m_position.Profit();// profit of open trade
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               b=b+1;//have open buy
               bsum=bsum+m_position.Commission()+m_position.Swap()+m_position.Profit();//buy trade profit
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               s=s+1;//open trade is sell
               ssum=ssum+m_position.Commission()+m_position.Swap()+m_position.Profit();//sell trade profit
              }
           }
   if(sbo==0 && m_account.Balance()<2000)
     {
      Comment("For normal work you must have 2000$ on your account");
      return;
     }
   if(!RefreshRates())
      return;
   int impuls_1   = (int)iCustomGet(handle_iCustom_Impulse,0,1);
   int impuls_0   = (int)iCustomGet(handle_iCustom_Impulse,0,0);
   double ZZ_1    = iCustomGet(handle_iCustom_ZZ,0,1);
   double ZZ_0    = iCustomGet(handle_iCustom_ZZ,0,0);
   double cci_1   = iCCIGet(1);
   double cci_0   = iCCIGet(0);
   if((ZZ_1>0.01 || ZZ_0>0.01) && ((cci_0<cci_1 && cci_1>50 && cci_0>30 && impuls_0<0 && impuls_1>0) || 
      (cci_0>200 && cci_1>cci_0 && impuls_0>InpInpulsSell && impuls_1>impuls_0)))
     {
      ssig=1;
      Comment("ZZ0=",NormalizeDouble(ZZ_0,m_symbol.Digits())," ZZ1=",NormalizeDouble(ZZ_1,m_symbol.Digits()),
              " cci_0=",NormalizeDouble(cci_1,m_symbol.Digits())," Impuls=",NormalizeDouble(impuls_0,m_symbol.Digits()),
              "\n","If ZigZag line is up - sell now");
     }
   if(((ZZ_1>0.01 || ZZ_0>0.01) && ((cci_0>cci_1 && cci_1<-50 && cci_0<-30 && impuls_0>0 && impuls_1<0))) || 
      ((cci_0<-200 && cci_1<cci_0 && impuls_0<InpInpulsBuy && impuls_1<impuls_0)))
     {
      bsig=1;
      Comment("ZZ0=",NormalizeDouble(ZZ_0,m_symbol.Digits())," ZZ1=",NormalizeDouble(ZZ_1,m_symbol.Digits()),
              " cci_0=",NormalizeDouble(cci_1,m_symbol.Digits())," Impuls=",NormalizeDouble(impuls_1,m_symbol.Digits()),
              "\n","If ZigZag line is down - buy now");
     }
   if((ZZ_0<0.01 && ZZ_1<0.01) || sbo!=0 || (impuls_1>InpInpulsBuy && impuls_1<InpInpulsSell))
     {
      ssig=0;//disallow sell
      bsig=0; //disallow buy
      Comment("ZZ0=",NormalizeDouble(ZZ_0,m_symbol.Digits())," ZZ1=",NormalizeDouble(ZZ_1,m_symbol.Digits()),
              " cci_0=",NormalizeDouble(cci_1,m_symbol.Digits())," Impuls=",NormalizeDouble(impuls_1,m_symbol.Digits()),
              "\n"," Signals are absent");
     }
//--- add to position and set hedge order of 1st level
   if(blok==0)
     {
      if(s==1
         && summa>30 //add to position when profit > 30
         && cci_0>150
         && impuls_0>50
         && impuls_1>impuls_0)
        {
         mlot=InpMultiplier*InpLots;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp,mlot);
            bsb=0;   // alow 2nd lev hedge
            blok=1;  // alow 2nd lev hedge
            return;
           }
        }
      //--- set hedge 1st level for sell position
      if(s==1
         && summa>0
         && cci_0<-150
         && impuls_0<-50
         && impuls_1<impuls_0)
        {
         mlot=InpMultiplier*InpLots;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp,mlot);
            bsb=0;   // allow open hedge 2nd level
            blok=1;
            return;
           }
        }
      //--- set hedge 1st level for sell position
      if(s==1
         && summa<-30
         && cci_0<-150
         && impuls_0<-50
         && impuls_1<impuls_0)
        {
         mlot=InpMultiplier*InpLots;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp,mlot);
            bsb=0;   // allow open hedge 2nd level
            blok=1;
            return;
           }
        }
      //--- set hedge 1st level for buy position
      if(b==1
         && summa<-30
         && cci_0>150
         && impuls_0>50
         && impuls_1>impuls_0)
        {
         mlot=InpMultiplier*InpLots;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp,mlot);
            bsb=0;   // alow 2nd lev hedge
            blok=1;  // alow 2nd lev hedge
            return;
           }
        }
      //--- add to buy position when profit > 30
      if(b==1
         && summa>30
         && cci_0<-150
         && impuls_0<-50
         && impuls_1<impuls_0)
        {
         mlot=InpMultiplier*InpLots;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp,mlot);
            bsb=0;      //alow 2nd lev hedge
            blok=1;     //alow 2nd lev hedge
            return;
           }
        }
      if(b==1
         && summa>0
         && cci_0>150
         && impuls_0>50
         && impuls_1>impuls_0)
        {
         mlot=InpMultiplier*InpLots;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp,mlot);
            bsb=0;   // alow 2nd lev hedge
            blok=1;  // alow 2nd lev hedge
            return;
           }
        }

     }
//---
   if(blok==1 // set 2nd level hedge
      && (b+s)<=2
      && summa<-2500  //current loss
      && bsb==0)
     {
      //--- allow open 2nd level hedge
      //--- set 2nd lev. hedge for buy pos.
      if(((b==1 && s==1) || b==2 || (b==1 && s==0)) && bsum<0 && bsum>ssum && cci_0>150 && impuls_0>50)
        {
         mlot=InpMultiplier*InpLots*2.0;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp,mlot);
            bsb=1;
            return;
           }
        }
      if(((s==1 && b==1) || s==2 || (s==1 && b==0)) && ssum<0 && bsum<ssum && cci_0<-150 && impuls_0<-50)
        {
         mlot=InpMultiplier*InpLots*2.0;
         mlot=LotCheck(mlot);
         if(mlot>0.0)
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp,mlot);
            bsb=1;
            return;
           }
        }
     }
//---
   if(sbo==0) // do not have open trades
     {
      bloks=0; // alow sell
      blokb=0; // allow buy
      pm=0;    // disallow closing
      bsb=1;   // disallow 2nd lev. hedge once more
     }
   if(summa<0 && down>summa)
      down=(MathRound(summa)); // loss
//--- print to log or screen
   if(!InpOutputInChart)
     {
      Print("Data: ",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
            " Bloks=",bloks," Blokb=",blokb," Blok=",blok," ZZ0=",MathRound(ZZ_0),
            " ZZ1=",MathRound(ZZ_1)," CCI0=",MathRound(cci_0)," Imp=",MathRound(impuls_0),
            " Prof=",MathRound(summa)," DDown=",MathRound(down/30)," BSB=",bsb);

     }
   else
     {
      Comment("Data: ",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
              " Bloks=",bloks," Blokb=",blokb," Blok=",blok," ZZ0=",MathRound(ZZ_0),
              " ZZ1=",MathRound(ZZ_1)," CCI0=",MathRound(cci_0)," Imp=",MathRound(impuls_0),
              " Prof=",MathRound(summa)," DDown=",MathRound(down/30));
     }
//---
   if(summa>InpProfitCloseAll) // profit margin
     {
      pm=1;
      CloseAllPositions();
     }
//---
   MqlDateTime STimeCurrent;
   TimeToStruct(TimeCurrent(),STimeCurrent);
   if(m_account.FreeMargin()>=2000 // open new positions
      && sbo==0 // have no open positions
      && (STimeCurrent.min==14 || STimeCurrent.min==29 || STimeCurrent.min==44 || STimeCurrent.min==59) //determin end of bar
      && STimeCurrent.sec>=45)
     { // and time of entry
      mlot=InpLots;
      if(ssig==1 && bloks==0)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp,mlot);
         blokb=1; // disallow second buy entry 
         bsb=1;   // disallow second hedge of 2nd lev
         blok=0;  // allow add position and hedge 1st lev.
         return;
        }
      if(bsig==1 && blokb==0)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp,mlot);
         bloks=1; // disallow second sell entry 
         bsb=1;   // disallow second hedge of 2nd lev
         blok=0;  // allow add position and hedge 1st lev.
         return;
        }
     }
//---
   Trailing();
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
      if(deal_reason!=-1)
         int d=0;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
            if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
               LastTradeTime=(datetime)deal_time;
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
//| Check the correctness of the order volume                        |
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
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(const int index)
  {
   double CCI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,index,1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(int handle_iCustom,const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCustom,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,const double lot)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,m_symbol.Name(),m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< lot (",DoubleToString(lot,2),")");
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
void OpenSell(double sl,double tp,const double lot)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,m_symbol.Name(),m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< lot(",DoubleToString(lot,2),")");
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
   int d=0;
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
