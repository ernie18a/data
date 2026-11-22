//+------------------------------------------------------------------+
//|                                               MoneyManagment.mqh |
//|                                 Copyright 2012, Evgeniy Trofimov |
//|                          https://www.mql5.com/ru/users/evgetrofi |
//+------------------------------------------------------------------+
//#include <EvgeTrofi\MoneyManagment.mqh>
// Necessary to add protection from the close position
enum TYPE_LOT{
   LOT_FIXED=0,     //Disable lot calculation. Will put the lot specified at the inValue parameter
   LOT_RISK=1,      //Lot calculation considering percentage from an account free funds (by margin)
   LOT_CURRENCY=2   //Lot calculation considering the designated funds in account currency
};
class CMoneyManagment{
private:
public:
                    // CMoneyManagment(void){};
                    //~CMoneyManagment(void){};
       double PrCur(string inSymbol="", int inType=-1);
       double Currency_Transfer(double Value, string CurrentCurrency="EUR", string NeedCurrency="USD", int inType=-1);
       double GetMargin(string inSymbol="", int inType=-1);
       double TickValue(string inSymbol="", int inType=-1);
       double Lot(double inValue, TYPE_LOT inTypeLot=LOT_FIXED, string inSymbol="", int inType=-1);
       double LotNormalize(double inValue, string inSymbol="", int inType=-1);
       double LotSL(double inValue, int inSL, TYPE_LOT inTypeLot=LOT_FIXED, string inSymbol="", int inType=-1);
       double GetCurrentLot(string inSymbol="", ulong inMagic=0);
       double GetCurrentProfit(string inSymbol="", ulong inMagic=0);
       bool   LotIsKiller(double inLot, string inSymbol, int inType);
};
//+------------------------------------------------------------------+
//   Function returns a lot, with which the next position must be opened to 
//   load the deposit at the specified inValue value.
//inValue - value of the lot, the deposit loading percentage or the size of risky funds
//inType - (0 - buy, 1 - sell, -1 - calculation by average price between the Bid and Ask)
//inTypeLot - lot calculation method (see the top of file)
//inSymbol - trading instrument
double CMoneyManagment::Lot(double inValue,TYPE_LOT inTypeLot=0,string inSymbol="",int inType=-1){
   if(inSymbol=="") inSymbol=Symbol();
   double res=inValue;
   double calc_margin=0;
   if(inTypeLot>0){
      calc_margin=GetMargin(inSymbol, inType);
      if(calc_margin<=0) {
         Print(__FUNCTION__," Failed to calculate margin!");
         return(-1);
      }
      if(inTypeLot==LOT_RISK) res = AccountInfoDouble(ACCOUNT_EQUITY) * res / calc_margin / 100;
      if(inTypeLot==LOT_CURRENCY) res = res / calc_margin;
   }
   return(LotNormalize(res,inSymbol,inType));
}//Lot()
//+------------------------------------------------------------------+
//   Function returns a lot, with which the next position must be opened to 
//   the deposit will be reduced by the specified value, if the Stop Loss boundary is achieved.
//inValue - value of the lot, the equity percentage or the size of risky funds
//inSL - distance from the position opening price to the StopLoss boundary in points
//inType - (0 - buy, 1 - sell, -1 - calculation by average price between the Bid and Ask)
//inTypeLot - lot calculation method (see the top of file)
//inSymbol - trading instrument
double CMoneyManagment::LotSL(double inValue,int inSL,TYPE_LOT inTypeLot=0,string inSymbol="",int inType=-1){
   if(inSymbol=="") inSymbol=Symbol();
   double res=inValue;
   double calc_tv=0;
   if(inTypeLot>0){
      if(inSL<=0){
         Print(__FUNCTION__," It is really necessary set the Stop Loss boundary to calculate the lot");
         return(-1);
      }
      calc_tv=TickValue(inSymbol, inType)*inSL;
      if(calc_tv<=0) {
         Print(__FUNCTION__," Failed to calculate price of point!");
         return(-1);
      }
      if(inTypeLot==LOT_RISK) res = AccountInfoDouble(ACCOUNT_EQUITY) * res / calc_tv / 100;
      if(inTypeLot==LOT_CURRENCY) res = res / calc_tv;
   }
   return(LotNormalize(res,inSymbol,inType));
}//LotSL()
//+------------------------------------------------------------------+
//Function of lot normalization
double CMoneyManagment::LotNormalize(double inValue,string inSymbol="",int inType=-1){
   if(inSymbol=="") inSymbol=Symbol();
   double free_margin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   double calc_margin = GetMargin(inSymbol, inType);
   if(calc_margin<=0) return(-1);
   double res = inValue;
   if(free_margin < calc_margin * res){
      if(calc_margin * res > 0.5 * AccountInfoDouble(ACCOUNT_EQUITY)){
         Alert("You are trying to make a deal, the deposit on which exceeds the size of funds more than 50%!!!");
         return(-1);
      }
      res = free_margin * 0.9 / calc_margin;
      Print(__FUNCTION__," The lot value is adjusted: ",DoubleToString(inValue,2)," -> ", DoubleToString(res, 2));
   }
   res = MathMax(res,SymbolInfoDouble(inSymbol, SYMBOL_VOLUME_MIN));
   res = MathMin(res,SymbolInfoDouble(inSymbol, SYMBOL_VOLUME_MAX));
   double lot_step = SymbolInfoDouble(inSymbol ,SYMBOL_VOLUME_STEP);
   int norm = (int)MathRound(NormalizeDouble(MathCeil(MathAbs(MathLog(lot_step)/MathLog(10.0))), 0));
   return(NormalizeDouble(res, norm));
}//LotNormalize()
//+------------------------------------------------------------------+
double CMoneyManagment::TickValue(string inSymbol="",int inType=-1){
//     Function returns the amount of funds, on which the equity is changed from position at 1 lot
// if the instrument quote is changed at 1 point.
   double res=0;
   if(inSymbol=="") inSymbol=Symbol();
   ENUM_SYMBOL_CALC_MODE Mode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(inSymbol, SYMBOL_TRADE_CALC_MODE);   
   switch(Mode){
      case SYMBOL_CALC_MODE_FOREX:
         res = SymbolInfoDouble(inSymbol,SYMBOL_TRADE_TICK_VALUE);
         return(res);
      case SYMBOL_CALC_MODE_FUTURES:
         Print(__FUNCTION__," The FUTURES method of profit calculation has not been studied!");
         return(-1);
      case SYMBOL_CALC_MODE_CFD:
         res = SymbolInfoDouble(inSymbol,SYMBOL_TRADE_TICK_VALUE)
              *SymbolInfoDouble(inSymbol,SYMBOL_TRADE_TICK_SIZE)
              *SymbolInfoDouble(inSymbol,SYMBOL_TRADE_CONTRACT_SIZE)
              *AccountInfoInteger(ACCOUNT_LEVERAGE);
         res = Currency_Transfer(res, 
                                 SymbolInfoString(inSymbol, SYMBOL_CURRENCY_PROFIT), 
                                 AccountInfoString(ACCOUNT_CURRENCY),inType);
         return(res);
      default:
         Print(__FUNCTION__," the ",StringSubstr(EnumToString(Mode),17)," method of profit calculation has not been studied!");
         return(-1);
   }
   return(res);   
}//TickValue()
//+------------------------------------------------------------------+
double CMoneyManagment::PrCur(string inSymbol="",int inType=-1){
   //Returns a price of symbol (Ask - to buy, Bid - to sell)
   if(inSymbol=="") inSymbol=Symbol();
   MqlTick tick;
   if(!SymbolInfoTick(inSymbol, tick)) {
      Print(__FUNCTION__," Failed to get the instrument price "+inSymbol);
      return(-1);
   }
   if(inType == 0){ //Buy
      return(tick.ask);
   }else if(inType == 1){ //Sell
      return(tick.bid);
   }else{ //Average price
      return((tick.bid+tick.ask)/2);
   }
   return(0);
}//PrCur()
//+------------------------------------------------------------------+
double CMoneyManagment::Currency_Transfer(double Value,string CurrentCurrency="EUR",string NeedCurrency="USD", int inType=-1){
   //Currency converter :)
   //Function returns the amount of the Value specified funds in the NeedCurrency currency
   int i;
   double res = Value;
   string name;
   string USD="USD";
   string FndCurrency="";
   //Try to translate directly:
   if(CurrentCurrency==NeedCurrency) return(Value);
   for(i=0; i<SymbolsTotal(true); i++){
      name = SymbolName(i,true);
      if(SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT) == CurrentCurrency &&
         SymbolInfoString(name, SYMBOL_CURRENCY_BASE) == NeedCurrency){
         res = res / PrCur(name, inType);
         return(res);
      }else if(SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT) == NeedCurrency &&
               SymbolInfoString(name, SYMBOL_CURRENCY_BASE) == CurrentCurrency){
         res = res * PrCur(name, inType);
         return(res);
      }
   }//Next i
   //Try to other ways      
   if(CurrentCurrency!=USD){
      for(i=0; i<SymbolsTotal(true); i++){
         name = SymbolName(i,true);
         if(SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT) == CurrentCurrency &&
            SymbolInfoString(name, SYMBOL_CURRENCY_BASE) == USD){
            res = res / PrCur(name, inType); //Sell its currency for dollars
            FndCurrency = USD;
            break;
         }else if(SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT) == USD &&
                  SymbolInfoString(name, SYMBOL_CURRENCY_BASE) == CurrentCurrency){
            res = res * PrCur(name, inType); //Buy its currency for dollars
            FndCurrency = USD;
            break;
         }
      }//Next i
      if(FndCurrency!=USD){
         Print(__FUNCTION__,"  Failed to find the currency pair for calculation "+CurrentCurrency);
         Print("Necessary to have In 'Market Watch' a currency pair which includes the "+CurrentCurrency+ " and "+USD+".");
         return(-1);
      }
      //Print("For the "+CurrentCurrency+" -> "+USD+" is used the "+name);
   }
   if(NeedCurrency==USD) return(res);
   for(i=0; i<SymbolsTotal(true); i++){
      name = SymbolName(i,true);
      if(SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT) == USD &&
         SymbolInfoString(name, SYMBOL_CURRENCY_BASE) == NeedCurrency){
         res = res / PrCur(name, inType); //Sell dollars for new currency
         FndCurrency = NeedCurrency;
         break;
      }else if(SymbolInfoString(name, SYMBOL_CURRENCY_PROFIT) == NeedCurrency &&
               SymbolInfoString(name, SYMBOL_CURRENCY_BASE) == USD){
         res = res * PrCur(name, inType); //Buy dollars for new currency
         FndCurrency = NeedCurrency;
         break;
      }
   }//Next i
   //Print("For the "+USD+" -> "+NeedCurrency+" is used the "+name);
   if(FndCurrency==NeedCurrency) return(res);
   Print(__FUNCTION__,"  Failed to find the currency pair for calculation "+NeedCurrency);
   Print("Necessary to have In 'Market Watch' a currency pair which includes the "+NeedCurrency+ " и "+USD+".");
   return(-1);
}//Currency_Transfer()
//+------------------------------------------------------------------+
double CMoneyManagment::GetMargin(string inSymbol="", int inType=-1){
//Function returns the amount of margin required to open a deal with 1 lot.
   if(inSymbol=="") inSymbol=Symbol();
   //MqlTick last_tick;
   double res=0;
   if(inType==0){ //Margin for buy opening
      res = SymbolInfoDouble(inSymbol, SYMBOL_MARGIN_LONG);
   }else{ //Margin for sell opening
      res = SymbolInfoDouble(inSymbol, SYMBOL_MARGIN_SHORT);
   }
   res=res*SymbolInfoDouble(inSymbol, SYMBOL_TRADE_CONTRACT_SIZE);
   ENUM_SYMBOL_CALC_MODE Mode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(inSymbol, SYMBOL_TRADE_CALC_MODE);
   switch(Mode){
      case SYMBOL_CALC_MODE_FOREX:
         res = Currency_Transfer(res, SymbolInfoString(inSymbol, SYMBOL_CURRENCY_MARGIN), AccountInfoString(ACCOUNT_CURRENCY),inType);
         return(res/AccountInfoInteger(ACCOUNT_LEVERAGE));
      case SYMBOL_CALC_MODE_FUTURES:
         Print(__FUNCTION__," The FUTURES method of margin calculation has not been studied!");
         return(-1);
         /*
         res = Currency_Transfer(SymbolInfoDouble(inSymbol, SYMBOL_MARGIN_INITIAL), 
                                 SymbolInfoString(inSymbol, SYMBOL_CURRENCY_MARGIN), 
                                 AccountInfoString(ACCOUNT_CURRENCY),inType);
         return(res/AccountInfoInteger(ACCOUNT_LEVERAGE));
         */
      case SYMBOL_CALC_MODE_CFD:
         //if(!SymbolInfoTick(inSymbol, last_tick)) return(-1);
         res = Currency_Transfer(res, 
                                 SymbolInfoString(inSymbol, SYMBOL_CURRENCY_MARGIN), 
                                 AccountInfoString(ACCOUNT_CURRENCY),inType);
         /*
         if(inType==0){
            res = res * last_tick.ask;
         }else if(inType==1){
            res = res * last_tick.bid;
         }else{
            res = res * (last_tick.ask+last_tick.bid)/2;
         }*/
         return(res*PrCur(inSymbol, inType));
      default:
         Print(__FUNCTION__," the ",StringSubstr(EnumToString(Mode),17)," method of margin calculation has not been studied!");
         return(-1);
   }
   return(res);
}//GetMargin()
//+------------------------------------------------------------------+
//Function returns the volume of opening position with particular magic by the specified instrument
//Negative value of the lot means that the position is open for sale
double CMoneyManagment::GetCurrentLot(string inSymbol="",ulong inMagic=0){
   if(inSymbol=="") inSymbol=Symbol();
   if(!PositionSelect(inSymbol)) return(0);
   ulong t; //Deal ticket
   double lot=0;
   ENUM_DEAL_TYPE trend;
   HistorySelectByPosition(PositionGetInteger(POSITION_IDENTIFIER));
   for(int i=0; i<HistoryDealsTotal(); i++){
      t = HistoryDealGetTicket(i);
      if(inMagic>0){
         if(HistoryDealGetInteger(t,DEAL_MAGIC)!=inMagic) continue;
      }
      trend = (ENUM_DEAL_TYPE)HistoryDealGetInteger(t, DEAL_TYPE);
      if(trend==DEAL_TYPE_BUY){
         lot = lot + HistoryDealGetDouble(t, DEAL_VOLUME);
      }else if(trend==DEAL_TYPE_SELL){
         lot = lot - HistoryDealGetDouble(t, DEAL_VOLUME);
      }
   }//Next i
   return(lot);
}//GetCurrentLot()
//+------------------------------------------------------------------+
//    Function returns true, if a future deal by the inSymbol instrument,
//inType direction and inLot volume will close the earlier opened position.
bool CMoneyManagment::LotIsKiller(double inLot,string inSymbol,int inType){
   if(!PositionSelect(inSymbol)) return(false);
   if(PositionGetInteger(POSITION_TYPE)==inType) return(false);
   if(PositionGetDouble(POSITION_VOLUME)==inLot) return(true);
   return(false);
}//LotIsKiller()
//+------------------------------------------------------------------+
double CMoneyManagment::GetCurrentProfit(string inSymbol="",ulong inMagic=0){
   return(0);
}//GetCurrentProfit()