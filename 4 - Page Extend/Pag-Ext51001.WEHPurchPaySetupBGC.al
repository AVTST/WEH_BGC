pageextension 51001 "WEH_Purch. & Pay. Setup BGC" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            field("WEH_PR Corp. Nos."; "WEH_PR Corp. Nos.")
            {
                ApplicationArea = All;
            }
            field("WEH_PO Corp. Nos."; "WEH_PO Corp. Nos.")
            {
                ApplicationArea = All;
            }
        }
    }
}
