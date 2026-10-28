//+==================================================================|//
//|                       EA Template.mq4.mqh                        |//
//|               Copyright 2018, Trading-go Project.                |//
//| Author: Voldemar, Version: 00.00.0000, Site http://trading-go.ru |//
//|==================================================================|//
//| Full version MetaTrader 4  https://www.mql5.com/ru/market/product/5635
//| Lite version MetaTrader 4  https://www.mql5.com/ru/code/11164
//| Full version MetaTrader 5  https://www.mql5.com/ru/market/product/27073
//| Lite version MetaTrader 5  https://www.mql5.com/ru/code/19702
//|==================================================================|//
//| All products of the Author https://www.mql5.com/ru/users/voldemar/seller
//|==================================================================|//
#property copyright "Copyright 2018, Trading-go Project."
#property link      "http://trading-go.ru"
#property version   "18.010"
#property description "VR Orders History stores the trade history to a csv file on any financial instrument (currency pairs, CFDs, Futures, BitCoin, Ethereum, and others)."
#property strict
#property script_show_inputs
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
struct str
  {
   long              PositionID;
   bool              PositionTypeLive;
   int               Digits_;
   int               Number;
   // ===
   datetime          deal_time;
   long              deal_time_msc;
   long              deal_type;
   long              deal_entry;
   double            deal_volume;
   double            deal_op_price;
   double            deal_swap;
   string            deal_symbol;
   // ===   
   long              PosTicket;
   datetime          PosTime;
   long              PosTimeMsc;
   ENUM_POSITION_TYPE PosType;
   string            PosTypeDes;
   ENUM_POSITION_REASON PosReason;
   // ===
   double            PosVolume;
   double            PosPriceOpen;
   double            PosStopLoss;
   double            PosTakeProfit;
   double            PosPriceCurrent;
   double            PosSwap;
   // ===
   string            PosSymbols;
  };
str Full[];
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
enum sp
  {
   One, // Comma    0 , 0000
   Two  // Point    0 . 0000
  };
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//  
input  sp       sep           = One;     // Separator (Comma or Point)
input  string   Symbols       = "";      // Symbol
input  int      MagicNumber   = -1;      // Magic Number
input  string   SeparatorLine = "";      // Separator Line
ulong ticket_history_deal=0;
// ===
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
void OnStart()
  {
// === Clean 
   Comment("");

// === Request history for a specified period
   HistorySelect(0,TimeCurrent());

// === Prepare an array of positions
   int k=HistoryDealsTotal(),z=0,t=PositionsTotal(); ulong tic=-1;

// === Fill the array data structure trades
   for(int i=0; i<k; i++)
      if((ticket_history_deal=HistoryDealGetTicket(i))>0)
        {
         long    Magic = HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
         string  Symb  = HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL);
         if(Magic==MagicNumber || MagicNumber==-1)
            if(Symb==Symbols || Symbols=="")
              {
               ArrayResize(Full,z+1,100000);
               Full[z].PositionTypeLive    = false;
               Full[z].PositionID          = HistoryDealGetInteger  (ticket_history_deal,DEAL_POSITION_ID);
               Full[z].deal_symbol         = Symb;
               Full[z].deal_type           = HistoryDealGetInteger  (ticket_history_deal,DEAL_TYPE);
               Full[z].deal_entry          = HistoryDealGetInteger  (ticket_history_deal,DEAL_ENTRY);
               Full[z].deal_op_price       = HistoryDealGetDouble   (ticket_history_deal,DEAL_PRICE);
               Full[z].deal_time           = (datetime)HistoryDealGetInteger  (ticket_history_deal,DEAL_TIME);
               Full[z].deal_time_msc       = HistoryDealGetInteger  (ticket_history_deal,DEAL_TIME_MSC);
               Full[z].deal_volume         = HistoryDealGetDouble   (ticket_history_deal,DEAL_VOLUME);
               Full[z].deal_swap           = HistoryDealGetDouble   (ticket_history_deal,DEAL_SWAP);
               Full[z].Digits_             = (int)SymbolInfoInteger(Full[z].deal_symbol,SYMBOL_DIGITS);
               z++;

              }
        }

// === Fill the array of structure data positions
   for(int q=0; q<t; q++)
      if((tic=PositionGetTicket(q))>0)
        {
         long    Magic = PositionGetInteger(POSITION_MAGIC);
         string  Symb  = PositionGetString(POSITION_SYMBOL);
         if(Magic==MagicNumber || MagicNumber==-1)
            if(Symb==Symbols || Symbols=="")
              {
               ArrayResize(Full,z+1,100000);
               Full[z].PositionTypeLive    = true;
               Full[z].PositionID          = PositionGetInteger(POSITION_TICKET);
               Full[z].PosSymbols          = PositionGetString(POSITION_SYMBOL);
               Full[z].PosTypeDes          = PositionTypeDes(Full[z].PosType);
               Full[z].PosPriceOpen        = PositionGetDouble(POSITION_PRICE_OPEN);
               Full[z].PosTime             = (datetime)PositionGetInteger(POSITION_TIME);
               Full[z].PosTimeMsc          = PositionGetInteger(POSITION_TIME_MSC);
               Full[z].PosVolume           = PositionGetDouble(POSITION_VOLUME);
               Full[z].PosPriceCurrent     = PositionGetDouble(POSITION_PRICE_CURRENT);
               Full[z].PosStopLoss         = PositionGetDouble(POSITION_SL);
               Full[z].PosTakeProfit       = PositionGetDouble(POSITION_TP);
               Full[z].PosSwap             = PositionGetDouble(POSITION_SWAP);
               Full[z].Digits_             = (int)SymbolInfoInteger(Full[z].PosSymbols,SYMBOL_DIGITS);
               z++;
              }
        }
// ===
// === Define the account type Hedge or Netting
   string type_trade="";
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
      type_trade="NETTING";
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_EXCHANGE)
      type_trade="EXCHANGE";
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      type_trade="HEDGING";

// === Saberei file Name
   string InpFileName="App Data Trading-Go"+"//"+MQLInfoString(MQL_PROGRAM_NAME)+".csv";

   if(FileGetInteger(InpFileName,FILE_EXISTS))
      FileDelete(InpFileName);

   int file_handle=FileOpen(InpFileName,FILE_WRITE|FILE_CSV);
// === 

   long oldPID=-1;
   if(type_trade=="HEDGING")
     {
      // === Description column position
      if(SeparatorLine!="")
         FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);
      FileWrite(file_handle,"Position Type","Position ID","Pos Symbols","Pos Type","Not used","Pos Price Open","Pos Time","Pos Time Msc","Pos Volume","Pos Price Current","Pos Stop Loss","Pos Take Profit","Pos Swap");
      FileWrite(file_handle,"     Deal Type","Deal Position ID","Deal Symbol","Deal Type","Deal Entry","Deal Op Price","Deal Time","Deal Time Msc","Deal Volume","Not used","Not used","Not used","Deal Swap");

      // === Separator
      if(SeparatorLine!="")
         FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);

      // === Collect open positions
      bool flag=false;
      for(int i=ArraySize(Full)-1; i>=0;i--)
         if(Full[i].PositionTypeLive==true)
            if((oldPID=Full[i].PositionID)!=-1)
               if(FileWrite(file_handle,Full[i].PositionTypeLive==true?"Live":"     History",Full[i].PositionID,Full[i].PosSymbols,Full[i].PosTypeDes,"-",Replace(Full[i].PosPriceOpen,Full[i].Digits_),Full[i].PosTime,Full[i].PosTimeMsc,Replace(Full[i].PosVolume,3),Replace(Full[i].PosPriceCurrent,Full[i].Digits_),Replace(Full[i].PosStopLoss,Full[i].Digits_),Replace(Full[i].PosTakeProfit,Full[i].Digits_),Replace(Full[i].PosSwap,2)))
                  if((Full[i].PositionID=-1)<0)
                    {
                     flag=true;
                     // === Found a live order, looking to him in historical order.
                     for(int r=0; r<ArraySize(Full); r++)
                        if(Full[r].PositionID==oldPID)
                           if(FileWrite(file_handle,Full[r].PositionTypeLive==true?"Live":"     History",Full[r].PositionID,Full[r].deal_symbol,DealTypeDes((ENUM_DEAL_TYPE)Full[r].deal_type),DealEntryDes((ENUM_DEAL_ENTRY) Full[r].deal_entry),Replace(Full[r].deal_op_price,Full[r].Digits_),Full[r].deal_time,Full[r].deal_time_msc,Replace(Full[r].deal_volume,2),"-","-","-",Replace(Full[r].deal_swap,2)))
                              Full[r].PositionID=-1;
                     if(SeparatorLine!="")
                        FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);
                    }

      // === Collect historical trades no live positions
      if(flag==true)
         FileWrite(file_handle,"      Deal Type","Deal Position ID","Deal Symbol","Deal Type","Deal Entry","Deal Op Price","Deal Time","Deal Time Msc","Deal Volume","Not used","Not used","Not used","Deal Swap");

      if(SeparatorLine!="")
         FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);

      oldPID=-1;
      for(int i=ArraySize(Full)-1; i>=0;i--)
         if(Full[i].PositionTypeLive==false)
            if((oldPID=Full[i].PositionID)!=-1)
               if(FileWrite(file_handle,Full[i].PositionTypeLive==true?"Live":"History",Full[i].PositionID,Full[i].deal_symbol,DealTypeDes((ENUM_DEAL_TYPE)Full[i].deal_type),DealEntryDes((ENUM_DEAL_ENTRY) Full[i].deal_entry),Replace(Full[i].deal_op_price,Full[i].Digits_),Full[i].deal_time,Full[i].deal_time_msc,Replace(Full[i].deal_volume,2),"-","-","-",Replace(Full[i].deal_swap,2)))
                 {
                  Full[i].PositionID=-1;

                  for(int r=0; r<ArraySize(Full); r++)
                     if(Full[r].PositionID==oldPID)
                        if(FileWrite(file_handle,Full[r].PositionTypeLive==true?"Live":"     History",Full[r].PositionID,Full[r].deal_symbol,DealTypeDes((ENUM_DEAL_TYPE)Full[r].deal_type),DealEntryDes((ENUM_DEAL_ENTRY) Full[r].deal_entry),Replace(Full[r].deal_op_price,Full[r].Digits_),Full[r].deal_time,Full[r].deal_time_msc,Replace(Full[r].deal_volume,2),"-","-","-",Replace(Full[r].deal_swap,2)))
                           Full[r].PositionID=-1;
                  if(SeparatorLine!="")
                     FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);
                 }
     }
   else // === If the account is not a hedge
     {
      // === Description column position
      if(SeparatorLine!="")
         FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);
      FileWrite(file_handle,"Position Type","Position ID","Pos Symbols","Pos Type","Not used","Pos Price Open","Pos Time","Pos Time Msc","Pos Volume","Pos Price Current","Pos Stop Loss","Pos Take Profit","Pos Swap");

      // === The description of the columns deals
      FileWrite(file_handle,"     Deal Type","Deal Position ID","Deal Symbol","Deal Type","Deal Entry","Deal Op Price","Deal Time","Deal Time Msc","Deal Volume","Not used","Not used","Not used","Deal Swap");

      if(SeparatorLine!="")
         FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);
      long ttt=0;
      for(int i=ArraySize(Full)-1; i>=0;i--)
        {
         if(Full[i].PositionTypeLive==true)
            if((oldPID=Full[i].PositionID)!=-1)
               if(FileWrite(file_handle,Full[i].PositionTypeLive==true?"Live":"     History",Full[i].PositionID,Full[i].PosSymbols,Full[i].PosTypeDes,"-",Replace(Full[i].PosPriceOpen,Full[i].Digits_),Full[i].PosTime,Full[i].PosTimeMsc,Replace(Full[i].PosVolume,3),Replace(Full[i].PosPriceCurrent,Full[i].Digits_),Replace(Full[i].PosStopLoss,Full[i].Digits_),Replace(Full[i].PosTakeProfit,Full[i].Digits_),Replace(Full[i].PosSwap,2)))
                 {
                  Full[i].PositionID=-1;
                  for(int r=ArraySize(Full)-1; r>=0; r--)
                     if(Full[r].PositionID==oldPID)
                        if(FileWrite(file_handle,Full[r].PositionTypeLive==true?"Live":"     History",Full[r].PositionID,Full[r].deal_symbol,DealTypeDes((ENUM_DEAL_TYPE)Full[r].deal_type),DealEntryDes((ENUM_DEAL_ENTRY) Full[r].deal_entry),Replace(Full[r].deal_op_price,Full[r].Digits_),Full[r].deal_time,Full[r].deal_time_msc,Replace(Full[r].deal_volume,2),"-","-","-",Replace(Full[r].deal_swap,2)))
                           Full[r].PositionID=-1;

                  if(SeparatorLine!="")
                     FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);
                 }
        }
      // ===
      // ===
      // ===
      for(int i=ArraySize(Full)-1; i>=0;i--)
        {
         if(Full[i].PositionTypeLive==false)
            if((oldPID=Full[i].PositionID)!=-1)
               if(FileWrite(file_handle,Full[i].PositionTypeLive==true?"Live":"     History",Full[i].PositionID,Full[i].deal_symbol,DealTypeDes((ENUM_DEAL_TYPE)Full[i].deal_type),DealEntryDes((ENUM_DEAL_ENTRY) Full[i].deal_entry),Replace(Full[i].deal_op_price,Full[i].Digits_),Full[i].deal_time,Full[i].deal_time_msc,Replace(Full[i].deal_volume,2),"-","-","-",Replace(Full[i].deal_swap,2)))
                 {
                  Full[i].PositionID=-1;
                  for(int r=ArraySize(Full)-1; r>=0; r--)
                     if(Full[r].PositionID==oldPID)
                        if(FileWrite(file_handle,Full[r].PositionTypeLive==true?"Live":"     History",Full[r].PositionID,Full[r].deal_symbol,DealTypeDes((ENUM_DEAL_TYPE)Full[r].deal_type),DealEntryDes((ENUM_DEAL_ENTRY) Full[r].deal_entry),Replace(Full[r].deal_op_price,Full[r].Digits_),Full[r].deal_time,Full[r].deal_time_msc,Replace(Full[r].deal_volume,2),"-","-","-",Replace(Full[r].deal_swap,2)))
                           Full[r].PositionID=-1;
                  if(SeparatorLine!="")
                     FileWrite(file_handle,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine,SeparatorLine);
                 }
        }
     }
   FileClose(file_handle);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
void PositionAdd(long aPosition,str  &mass[])
  {
   int i=0,k=ArraySize(mass);
   for(i=0;i<k; i++)
      if(aPosition==mass[i].PositionID)
         return;

   if(ArrayResize(mass,i+1,100000)!=k)
      mass[i].PositionID=aPosition;
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
string Replace(double aVol,int dig)
  {
   string text=DoubleToString(aVol,dig);
   StringReplace(text,sep==One?".":",",sep==One?",":".");
   return text;
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
string PositionTypeDes(ENUM_POSITION_TYPE aType)
  {
   string text="";
   switch(aType)
     {
      case POSITION_TYPE_BUY : text = "Position Buy";  break;
      case POSITION_TYPE_SELL: text = "Position Sell"; break;
      default: text="Unknown Position";
     }
   return text;
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
string DealTypeDes(ENUM_DEAL_TYPE aType)
  {
   string text="";
   switch(aType)
     {
      case DEAL_TYPE_BUY:                      text="Deal type BUY";              break;
      case DEAL_TYPE_SELL:                     text="Deal type SELL";             break; // Selling
      case DEAL_TYPE_BALANCE:                  text="Deal type Balance";          break; // The accrual balance
      case DEAL_TYPE_CREDIT:                   text="Deal type Credit";           break; // Accrual of loan
      case DEAL_TYPE_CHARGE:                   text="Deal type Charge";           break; // Additional fees
      case DEAL_TYPE_CORRECTION:               text="Deal type Correction";       break; // Corrective entry
      case DEAL_TYPE_BONUS:                    text="Deal type Bonus";            break; // Listing of bonuses
      case DEAL_TYPE_COMMISSION:               text="Deal type Comission";        break; // Additional fee
      case DEAL_TYPE_COMMISSION_DAILY:         text="Deal type Daily";            break; // The Commission assessed at the end of the trading day
      case DEAL_TYPE_COMMISSION_MONTHLY:       text="Deal type Monthly";          break; // The Commission assessed at the end of the month
      case DEAL_TYPE_COMMISSION_AGENT_DAILY:   text="Deal type Agent Daily";      break; // Agency fees are assessed at the end of the trading day
      case DEAL_TYPE_COMMISSION_AGENT_MONTHLY: text="Deal type Agent Monthly";    break; // Agency fees are assessed at the end of the month
      case DEAL_TYPE_INTEREST:                 text="Deal type Interest";         break; // The accrual of interest on surplus funds
      case DEAL_TYPE_BUY_CANCELED:             text="Deal type Buy canceled";     break; // Canceled buy deal. There can be a situation when a previously executed deal on the purchase is canceled. In this case, the type of the deal (DEAL_TYPE_BUY) changes to DEAL_TYPE_BUY_CANCELED, and its profit/loss is zeroized. Previously obtained profit/loss is charged/withdrawn using a separated balance operation
      case DEAL_TYPE_SELL_CANCELED:            text="Deal type Sell canceled";    break; // Canceled sell deal. There can be a situation when a previously executed deal for the sale is canceled. In this case, the type of the deal (DEAL_TYPE_SELL) changes to DEAL_TYPE_SELL_CANCELED, and its profit/loss is zeroized. Previously obtained profit/loss is charged/withdrawn using a separated balance operation
      case DEAL_DIVIDEND:                      text="Deal type Dividend";         break; // Crediting of dividend
      case DEAL_DIVIDEND_FRANKED:              text="Deal type Dividend Franked"; break; // Accrual Frank dividend (exempt from tax)
      case DEAL_TAX:                           text="Deal type Tax";              break; // Assessment of tax
      default:                                 text="Deal type unknow";           break; // Assessment of tax
     }
   return text;
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
string DealEntryDes(ENUM_DEAL_ENTRY aType)
  {
   string text="";
   switch(aType)
     {
      case DEAL_ENTRY_IN:     text="Entry In";     break;
      case DEAL_ENTRY_OUT:    text="Entry Out";    break;
      case DEAL_ENTRY_INOUT:  text="Entry InOut";  break;
      case DEAL_ENTRY_OUT_BY: text="Entry Out By"; break;
     }
   return text;
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
