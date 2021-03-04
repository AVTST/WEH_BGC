pageextension 51004 "WEH_General Ledger Setup BGC" extends "General Ledger Setup"
{
    layout
    {
        addafter(General)
        {
            group("WEH_BudgetControl")
            {
                Caption = 'Budget Control';

                field("WEH_Active Budget"; "WEH_Active Budget")
                {

                }
                field("WEH_G/L Add Budget Nos."; "WEH_G/L Add Budget Nos.")
                {

                }
                field("WEH_G/L Transfer Budget Nos."; "WEH_G/L Transfer Budget Nos.")
                {

                }
                field("WEH_G/L for Budget Type C"; "WEH_G/L for Budget Type C")
                {

                }
                field("WEH_VAT Account"; "WEH_VAT Account")
                {

                }
            }
        }
    }
}
