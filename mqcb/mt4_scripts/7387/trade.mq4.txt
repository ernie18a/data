#property copyright "Max Berilo"
#property library
//----
#include <stdlib.mqh>
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//| trade function                                                   |
//+------------------------------------------------------------------+
int Trade(string smb, int TimeFrame, int cmd, bool ShowQ, int Slippage, bool SetProfit, double MaxRiskPercent, int RiskAtrPeriod, double RiskMulATR, double ProfitToLossRatio)
  {
    if(IsConnected() && ((cmd == OP_BUY) || (cmd == OP_SELL))) {
      double pnt = MarketInfo(smb, MODE_POINT);
      int    dgt = MarketInfo(smb, MODE_DIGITS);
      double minlot = MarketInfo(smb, MODE_MINLOT);
      double tickval = MarketInfo(smb, MODE_TICKVALUE);
      double spread = MarketInfo(smb, MODE_SPREAD);
      double stoplevel = MarketInfo(smb, MODE_STOPLEVEL);
      RefreshRates();
//---- calculating lot size, stop-loss & take-profit
      double RiskAmount = AccountFreeMargin() * MaxRiskPercent / 100.0;
      double SL = MathFloor(RiskMulATR * iATR(smb, TimeFrame, RiskAtrPeriod, 0) / pnt);
      if(SL < stoplevel) SL = stoplevel;
      SL += spread;
      double OptLot = NormalizeDouble(MathFloor(10.0 * RiskAmount / (tickval * SL)) / 10.0, 1);
      if(OptLot < minlot) {
        OptLot = minlot;
        if(OptLot * SL * tickval > RiskAmount) {
          SL = MathFloor(RiskAmount / (OptLot * tickval));
          if(SL < stoplevel + spread) SL = stoplevel + spread;
        }
      }
      RiskAmount = OptLot * SL * tickval;
//----
      string question;
      double OpenPrice = 0, StopLoss = 0, TakeProfit = 0;
      if(cmd == OP_BUY) {
        OpenPrice = MarketInfo(smb, MODE_ASK);
        StopLoss  = NormalizeDouble(OpenPrice - SL * pnt, dgt);
        if(SetProfit) {
          TakeProfit = NormalizeDouble(MarketInfo(smb, MODE_BID) + ProfitToLossRatio * SL * pnt, dgt);
        }
        if(ShowQ) question = "BUY  ";
      } else if(cmd == OP_SELL) {
        OpenPrice = MarketInfo(smb, MODE_BID);
        StopLoss  = NormalizeDouble(OpenPrice + SL * pnt, dgt);
        if(SetProfit) {
          TakeProfit = NormalizeDouble(MarketInfo(smb, MODE_ASK) - ProfitToLossRatio * SL * pnt, dgt);
        }
        if(ShowQ) question = "SELL  ";
      }
//----
      if(ShowQ) {
        question = question +
          DoubleToStr(OptLot, 1) +"  "+smb+
          "    At "        +DoubleToStr(OpenPrice,  dgt)+
          "    StopLoss "  +DoubleToStr(StopLoss,   dgt)+
          "    TakeProfit "+DoubleToStr(TakeProfit, dgt)+
          "    Slippage "  +DoubleToStr(Slippage,   0)  +"\n"+
          "Risk amount "   +DoubleToStr(RiskAmount, 2)  +" " +AccountCurrency()+" ?";
          if(MessageBox(question, "Buy/Sell script", MB_YESNO|MB_ICONEXCLAMATION) != IDYES) {
            return(1);
          }
      }
      int ticket = OrderSend(smb, cmd, OptLot, OpenPrice, Slippage, StopLoss, TakeProfit, NULL, TimeFrame);
      if(ticket < 1) {
        int error = GetLastError();
        Print("Error = ",ErrorDescription(error));
        return(1);
      } else {
        OrderPrint();
      }
//----
    }
    return(0);
  }
//+------------------------------------------------------------------+