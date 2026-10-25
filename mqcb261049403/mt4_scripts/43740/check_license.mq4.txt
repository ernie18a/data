//+------------------------------------------------------------------+
//|                                                 Amira brand      |
//+------------------------------------------------------------------+

#property copyright "Amira Brand"
#property link      "https://www.mql5.com/en/users/amirabrand1998"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   CheckLicense();     
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert check license                                             |
//+------------------------------------------------------------------+
void CheckLicense() 
{
   Print("Account name: ", AccountName());
  
   if (StringFind(StringLower(AccountName()), "account name in lowercase!!") < 0) {
      Alert("No license active!");
      ExpertRemove();
      return;
   }
}

//+------------------------------------------------------------------+
//| Expert string to lower                                           |
//+------------------------------------------------------------------+
string StringLower(string str) 
{
   string outstr = "";
   string lower  = "abcdefghijklmnopqrstuvwxyz";
   string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   
   for (int i=0; i<StringLen(str); i++) {
      int t1 = StringFind(upper,StringSubstr(str,i,1),0);
      if (t1 >=0) {  
         outstr = outstr + StringSubstr(lower,t1,1);
      } else {
         outstr = outstr + StringSubstr(str,i,1);
      }  
   }
   
   return(outstr);
}
