tableextension 51009 "WEH_G/L Setup BGC" extends "General Ledger Setup"
{
    fields
    {
        field(51000; "WEH_Active Budget"; Code[10])
        {
            Caption = 'Active Budget';
            TableRelation = "G/L Budget Name" where("WEH_G/L Budget Name Type" = const(Budget));
        }
        field(51001; "WEH_Budget Encumbrance"; Code[10])
        {
            Caption = 'Budget Encumbrance';
            ObsoleteState = Removed;
        }
        field(51002; "WEH_Check Encumbrance"; Boolean)
        {
            Caption = 'Check Encumbrance';
            ObsoleteState = Removed;
        }
        field(51003; "WEH_G/L for Budget Type C"; Code[10])
        {
            Caption = 'G/L for Budget Type C';
        }
        field(51004; "WEH_G/L Add Budget Nos."; Code[10])
        {
            Caption = 'G/L Add Budget Nos.';
        }
        field(51005; "WEH_G/L Transfer Budget Nos."; Code[10])
        {
            Caption = 'G/L Transfer Budget Nos.';
        }
        field(51006; "WEH_VAT Account"; Text[150])
        {
            Caption = 'VAT Account';
        }
        /*
        field(51007; "WEH_Budget Include VAT"; Boolean)
        {
            Caption = 'Budget Include VAT';
        }
        */
    }
}
