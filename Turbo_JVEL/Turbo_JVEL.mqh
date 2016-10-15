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
class EA
  {

public:

   double            rsxcurr,rsxprev1,rsxprev2,TrendVal;

   double            DnTrendVal,UpTrendVal;

   int               SignalOrderType;
   double            jma1,jma2;

   void Update(int tf=PERIOD_M1)
     {

      rsxcurr  = iCustom(Symbol(), tf, "Turbo_JRSX", 17, 0, 1);
      rsxprev1 = iCustom(Symbol(), tf, "Turbo_JRSX", 17, 0, 2);
      rsxprev2 = iCustom(Symbol(), tf, "Turbo_JRSX", 17, 0, 3);

      UpTrendVal = iCustom(Symbol(), tf, "Turbo_JVEL", 17, -100, 0, 1);
      DnTrendVal = iCustom(Symbol(), tf, "Turbo_JVEL", 17, -100, 1, 1);
      TrendVal   = UpTrendVal + DnTrendVal;



     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      Update(tf);

      int SignalOrderBuy=0,SignalOrderSell=0;

      if(rsxcurr<rsxprev1 && 
         rsxcurr<70 && 
         rsxprev1>70 && 
         TrendVal<(-0.01))
        {
         SignalOrderBuy++;
        } // we only go short on RSX downturns

      if(rsxcurr>rsxprev1 && 
         rsxcurr>30 && 
         rsxprev1<30 && 
         TrendVal>0.01)
        {
         SignalOrderSell++;
        } // we only go long on RSX upturns

      if(rsxcurr < rsxprev2 && TrendVal < (-0.01)) SignalOrderSell++; // we only go short on RSX downturns
      if(rsxcurr > rsxprev2 && TrendVal > 0.01)     SignalOrderBuy++; // we only go long on RSX upturns


      if(SignalOrderBuy>=1 && cmd==OP_BUY)
         return true;
      else if(SignalOrderSell>=1 && cmd==OP_SELL)
        return true;

      return false;

     }
  };
//+------------------------------------------------------------------+
