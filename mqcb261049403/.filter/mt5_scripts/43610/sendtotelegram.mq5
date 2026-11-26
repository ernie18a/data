//+------------------------------------------------------------------+
//|                                   SEND A MESSAGE TO TELEGRAM.mq5 |
//|                                       Copyright © 2023, RABI.NAT |
//|                       https://www.mql5.com/en/users/rabi.nateghi |
//+------------------------------------------------------------------+

// Define macro constants for the script version and copyright information
#property strict 
#define VERSION     "1.1"
#property copyright " Copyright © 2023, RABI.NAT"
#property link      "https://www.mql5.com/en/users/rabi.nateghi"
#property version   VERSION
#property description "SEND A MESSAGE TO TELEGRAM."

// Define input parameters for the script, including the Telegram bot token, chat ID, and whether to send a message when a trade is opened

input string TelegramToken = "YOUR TELEGRAM BOT TOKEN";    // Telegram bot token
input string TelegramChatID = "Telegram chat ID";   // Telegram chat ID
input bool SendOnOpen = true;       // Send message when trade is opened

// Define the OnTradeTransaction function to send a message when a trade transaction occurs
void OnTradeTransaction(const MqlTradeTransaction& transaction,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
    // Check if the SendOnOpen input parameter is set to true and if a new trade order is being added for the specified symbol
    if (SendOnOpen && transaction.order == TRADE_TRANSACTION_ORDER_ADD  && request.action == TRADE_ACTION_DEAL && request.symbol != NULL)
    {
        // Retrieve the current ask price for the specified symbol
        double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

        // Create a message string to send to Telegram, including information about the trade order
        string message = "Trade - " + request.symbol + " " + (request.type == ORDER_TYPE_BUY ? "Buy" : "Sell") + " " + DoubleToString(request.volume,2) + " lots at " + DoubleToString( price,5) ;

        // Send the message to Telegram using the SendTelegramMessage function
        SendTelegramMessage(TelegramToken, TelegramChatID, message);
    }
}

// Define the SendTelegramMessage function to send a message to Telegram using the specified bot token and chat ID
int SendTelegramMessage(string token, string chat_id, string message)
{
    // Construct the URL for the Telegram API based on the bot token, chat ID, and message text
    string url = "https://api.telegram.org/bot" + token + "/sendMessage?chat_id=" + chat_id + "&text=" + message;

    // Define variables for storing the result of the web request
    string result;
    string cookie=NULL;
    char post[],resultt[];

    // Send a GET request to the Telegram API using the constructed URL and store the result in the 'result' variable
    int res = WebRequest("GET",url,cookie,NULL,10000,post,10000,resultt,result);
    return res;
}
