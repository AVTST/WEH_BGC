pageextension 51000 "WEH_AVision Role Center BGC" extends "AVADM_Avision Role Center"
{
    actions
    {
        addafter(Master)
        {
            group("WEH_Budget")
            {
                Caption = 'Budget Control';

                action("WEH_User Setup")
                {
                    Caption = 'User Setup';
                    RunObject = page "User Setup";
                }
                action("WEH_G/L Budget Names")
                {
                    Caption = 'G/L Budget Names';
                    RunObject = page "G/L Budget Names";
                }
                action("WEH_G/L Budget Entry_TMP")
                {
                    Caption = 'Import Budget';
                    RunObject = page "WEH_G/L Budget Entry_TMP";
                }
                action("WEH_G/L Budget Encumbrance PR/PO")
                {
                    Caption = 'G/L Budget Encumbrance PR/PO';
                    RunObject = page "WEH_G/L Budget Enc. PR/PO";
                }
                action("WEH_Add Budget Corporate")
                {
                    Caption = 'Add Budget - Corporate';
                    RunObject = page "WEH_Add Budget List CORP";
                }
                action("WEH_Transfer Budget Corporate")
                {
                    Caption = 'Transfer Budget - Corporate';
                    RunObject = page "WEH_Transfer Budget List CORP";
                }
                action("WEH_Posted Add Budget Corporate")
                {
                    Caption = 'Posted Add Budget - Corporate';
                    RunObject = page "WEH_Posted Add Budget List CO";
                }
                action("WEH_Posted Transfer Budget Corporate")
                {
                    Caption = 'Posted Tr. Budget - Corporate';
                    ToolTip = 'Posted Transfer Budget - Corporate';
                    RunObject = page "WEH_Posted Tr. Budget List CO";
                }
            }
            group("WEH_Purchase Quote - Corp.")
            {
                Caption = 'Purchase Quote - Corporate';

                action("WEH_Purch. Quotes - Corporate")
                {
                    Caption = 'Purchase Quotes - Corporate';
                    RunObject = page "WEH_Purch. Quote List - Corp.";
                }

                action("WEH_Purch. Quotes - Finish")
                {
                    Caption = 'Purchase Quotes - Finish';
                    RunObject = page "WEH_Purch. Quote List - Finish";
                }
            }
            group("WEH_Purchase Order - Corp.")
            {
                Caption = 'Purchase Order - Corporate';

                action("WEH_Purch. Order - Corporate")
                {
                    Caption = 'Purchase Orders - Corporate';
                    RunObject = page "WEH_Purchase Order List Corp.";
                }
                action("WEH_Purch. Order-FIN List")
                {
                    Caption = 'Purchase Orders - Finished';
                    RunObject = page "AVTD_Purch. Order-FIN List";
                }
            }
            group("WEH_Goods Received - Corp.")
            {
                Caption = 'Goods Received - Corporate';

                action("WEH_Purch. Order Rcv. - Corporate")
                {
                    Caption = 'Purchase Orders (Received)';
                    RunObject = page "WEH_Purch. Order Rcv. List Co";
                }
                action("WEH_Posted Purchase Receipts")
                {
                    Caption = 'Posted Purchase Receipts';
                    RunObject = page "Posted Purchase Receipts";
                }
            }
        }
    }
}
