//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict
//#include  <Convert.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern int    SignalStrength=4;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EA
  {

public:

   int               SignalOrderBuy,SignalOrderSell;

   void Update(int tf=PERIOD_M1,int cmd=NULL)
     {

      SignalOrderBuy=SignalOrderSell=0;

      int i=0;
      double top,bot;

      top = iMA(NULL,0,13,8,MODE_SMMA,PRICE_MEDIAN,0);
      bot = iMA(NULL,0,15,0,MODE_SMMA,PRICE_MEDIAN,0);

      double first2 = iCustom(Symbol(),tf,"xSuperTrend MTF", 1,i);
      double secon2 = iCustom(Symbol(),15,"xSuperTrend MTF",1,i);
      double third2 = iCustom(Symbol(),30,"xSuperTrend MTF",1,i);
      double fourt2 = iCustom(Symbol(),60,"xSuperTrend MTF",1,i);

      double first21 = iCustom(Symbol(),tf,"xSuperTrend MTF", 1,i+1);
      double secon21 = iCustom(Symbol(),0,"xSuperTrend MTF",1,i+15);
      double third21 = iCustom(Symbol(),0,"xSuperTrend MTF",1,i+30);
      double fourt21 = iCustom(Symbol(),0,"xSuperTrend MTF",1,i+60);

      if(cmd==OP_BUY)
        {

         if(first2<bot) SignalOrderBuy++;
         if(first2<bot && secon2<bot) SignalOrderBuy++;
         if(first2<bot && secon2<bot && third2<bot) SignalOrderBuy++;
         if(first2<bot && secon2<bot && third2<bot && fourt2<bot) SignalOrderBuy++;

        }
      if(cmd==OP_SELL)
        {
         if(first2>top) SignalOrderSell++;
         if(first2>top && secon2>top) SignalOrderSell++;
         if(first2>top && secon2>top && third2>top) SignalOrderSell++;
         if(first2>top && secon2>top && third2>top && fourt2>top) SignalOrderSell++;

        }

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      Update(tf,cmd);

      if(SignalOrderBuy>=SignalStrength && cmd==OP_BUY)
         return true;
      else if(SignalOrderSell>=SignalStrength && cmd==OP_SELL)
                               return true;

      return false;

     }
  };
//+------------------------------------------------------------------+
