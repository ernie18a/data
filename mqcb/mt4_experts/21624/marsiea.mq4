//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Brian Lillard"
#property link "https://www.mql5.com/en/users/subgenius/seller"
#property version   "1.00"
#property strict
enum OptLot{Fixed=0,/*Fixed Lot*/Equity=1,/*% Equity*/Balance=2/*% Balance*/};
//+------------------------------------------------------------------+
input OptLot              LotOption         = Fixed;                     //Lot Value Mode
input double              LotSize           = 0.01;                      //*Fixed Lot
input double              PercentOfBalance  = 0.02;                      //*Percentage of Balance
input double              PercentOfEquity   = 0.03;                      //*Percentage of Equity
//+------------------------------------------------------------------+
input int                 FastMAperiod      = 4;                         //MA Period
input int                 FastMAshift       = 0;                         //MA Shift
input ENUM_MA_METHOD      FastMAmethod      = MODE_LWMA;                 //MA Method
input ENUM_APPLIED_PRICE  FastMAprice       = PRICE_OPEN;                //MA Price
//+------------------------------------------------------------------+
input int                 RSIperiod         = 4;
input ENUM_APPLIED_PRICE  RSIprice          = PRICE_OPEN;
input int                 RSIoverbought     = 80;
input int                 RSIoversold       = 20;
//+------------------------------------------------------------------+
input int                 Magic=1;
//+------------------------------------------------------------------+
int intSellsOpen,intBuysOpen; double CumulativePL;
//+------------------------------------------------------------------+
double dRSI(){return(iRSI(NULL,0,RSIperiod,RSIprice,0));}
double dMA(){return(iMA(NULL,0,FastMAperiod,0,FastMAmethod,FastMAprice,0));}
bool newCandle(){ static datetime nCandle; if(nCandle==Time[0]) return(False); nCandle=Time[0]; return(True); }
//+------------------------------------------------------------------+
void LABEL(string sName,string sText,string sFont,int iFontSize,color cFontColor,int iCorner,int iX,int iY)
  {
   if(ObjectFind(sName)==-1){ ObjectCreate(sName,OBJ_LABEL,0,0,0); }
   else{ if(!IsTesting()){ ObjectDelete(sName);ObjectCreate(sName,OBJ_LABEL,0,0,0); }  }
   ObjectSetText(sName,sText,iFontSize,sFont,cFontColor);
   ObjectSet(sName,OBJPROP_CORNER,iCorner);
   ObjectSet(sName,OBJPROP_XDISTANCE,iX);
   ObjectSet(sName,OBJPROP_YDISTANCE,iY);
  }
//+------------------------------------------------------------------+
int OnInit(){ return(INIT_SUCCEEDED); }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   HideTestIndicators(true);
   ObjectDelete("LABEL1");
   ObjectDelete("LABEL2");
   ObjectDelete("LABEL3");
  }
//+------------------------------------------------------------------+
bool OpenOrdersFound()
  {
   intSellsOpen=0; intBuysOpen=0; CumulativePL=0;
   int OrdersOT=OrdersTotal();
   for(int X=0; X<OrdersOT; X++)
     {
      if(!OrderSelect(X,SELECT_BY_POS,MODE_TRADES) || OrderMagicNumber()!=1){continue;}
      if(OrderType()==OP_SELL){ intSellsOpen++; }else if(OrderType()==OP_BUY){ intBuysOpen++; }
      CumulativePL+=OrderProfit()+OrderCommission()+OrderSwap();
     }
   if(intSellsOpen+intBuysOpen>0){ return(true); }
   return(false);
  }
//+------------------------------------------------------------------+
double dNextLot()
  {
   double Lot=LotSize;
   if(LotOption==Equity){ Lot=PercentOfEquity*AccountEquity()/10000; }
   if(LotOption==Balance){ Lot=PercentOfBalance*AccountBalance()/10000; }
   if( Lot<NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2) ){ Lot=NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2); }
   if( Lot>NormalizeDouble(MarketInfo(NULL,MODE_MAXLOT),2) ){ Lot=NormalizeDouble(MarketInfo(NULL,MODE_MAXLOT),2); }
   return(Lot);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!newCandle()){return;}
   OpenOrdersFound();
   if(CumulativePL>0){ CloseAll(); }
   if(dRSI()>=RSIoverbought && Open[0]<dMA())
     {
      OrderSend(NULL,OP_SELL,dNextLot(),NormalizeDouble(Ask,Digits),100,0,0,NULL,Magic,0,clrNONE);
     }
   else
     {
      if(dRSI()<=RSIoversold && Open[0]>dMA())
        {
         OrderSend(NULL,OP_BUY,dNextLot(),NormalizeDouble(Bid,Digits),100,0,0,NULL,Magic,0,clrNONE);
        }
     }
   LABEL("LABEL1","PROFIT & LOSS: "+DoubleToString(CumulativePL,2),"Arial",12,Orange,3,5,35);
   LABEL("LABEL2","EQUITY: "+DoubleToString(AccountEquity(),2),"Arial",12,Orange,3,5,20);
   LABEL("LABEL9","BALANCE: "+DoubleToString(AccountBalance(),2),"Arial",12,Orange,3,5,5);
  }
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(int OrdersOT=OrdersTotal()-1; OrdersOT>=0; OrdersOT--)
     {
      if(!OrderSelect(OrdersOT,SELECT_BY_POS,MODE_TRADES) || OrderMagicNumber()!=1){continue;}
      OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Magic,clrNONE);
     }
  }
//+------------------------------------------------------------------+
