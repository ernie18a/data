//+------------------------------------------------------------------+
//|                                                 InfoAccount.mq5  |
//|                                                                  |
//| Script to display information about the current trading account. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Kim Igor V. aka KimIV"
#property link      "http://www.kimiv.ru"
#property description "Script to display information about the current trading account"
#property script_show_confirm
//---- show input parameters
#property script_show_inputs
//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//----
   string st="Balance="+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n"
   +"Credit="+DoubleToString(AccountInfoDouble(ACCOUNT_CREDIT),2)+"\n"
   +"Company="+AccountInfoString(ACCOUNT_COMPANY)+"\n"
   +"Currency="+AccountInfoString(ACCOUNT_CURRENCY)+"\n"
   +"Equity="+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+"\n"
   +"FreeMargin="+DoubleToString(AccountInfoDouble(ACCOUNT_FREEMARGIN),2)+"\n"
   +"Leverage="+DoubleToString(AccountInfoInteger(ACCOUNT_LEVERAGE),0)+"\n"
   +"Margin="+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN),2)+"\n"
   +"Name="+AccountInfoString(ACCOUNT_NAME)+"\n"
   +"Number="+DoubleToString(AccountInfoInteger(ACCOUNT_LOGIN),0)+"\n"
   +"Profit="+DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2)+"\n"
   +"Server="+AccountInfoString(ACCOUNT_SERVER)+"\n"
   +"StopoutLevel="+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),0)+"\n"
   +"StopoutMode="+EnumToString(ENUM_ACCOUNT_STOPOUT_MODE(AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)))+"\n"
   ;
   Comment(st);
   Sleep(20000);
   Comment("");
//----
  }
//+------------------------------------------------------------------+
