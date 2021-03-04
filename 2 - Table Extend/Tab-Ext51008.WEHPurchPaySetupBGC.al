tableextension 51008 "WEH_Purch. & Pay. Setup BGC" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50000; "WEH_PR Corp. Nos."; Code[10])
        {
            Caption = 'PR Corp. Nos.';
            TableRelation = "No. Series";
        }
        field(50010; "WEH_PO Corp. Nos."; Code[10])
        {
            Caption = 'PO Corp. Nos.';
            TableRelation = "No. Series";
        }
    }
}
