pageextension 51011 "WEH_Purchase Invoice BGC" extends "Purchase Invoice"
{
    layout
    {
        addfirst(factboxes)
        {
            part("WEH_Available Budget Factbox "; "WEH_Available Budget Factbox")
            {
                ApplicationArea = All;
                Caption = 'Available Budget';
                Provider = PurchLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
            }
        }
    }
}
