tableextension 51000 "WEH_G/L Budget Name" extends "G/L Budget Name"
{
    fields
    {
        field(51000; "WEH_Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(51001; "WEH_End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(51002; "WEH_G/L Budget Name Type"; Enum "WEH_G/L Budget Name Type")
        {
            Caption = 'G/L Budget Name Type';
            //OptionMembers = " ",Budget,Encumbrance;
        }
        field(51003; "WEH_Encumbrance Name"; Code[10])
        {
            Caption = 'Encumbrance Name';
            TableRelation = "G/L Budget Name" where("WEH_G/L Budget Name Type" = const(Encumbrance));
        }
    }
}
