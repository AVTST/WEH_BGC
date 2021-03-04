page 50102 "WEH_G/L Budget Enc. PR/PO"
{
    Caption = 'G/L Budget Encumbrance PR/PO';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_G/L Budget Enc. PR/PO";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field("G/L Budget Entry No."; Rec."G/L Budget Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Budget Type"; "Budget Type")
                {
                    ApplicationArea = All;
                }
                field("Budget Name"; Rec."Budget Name")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Document Posting Date"; Rec."Document Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("PR IN Amount"; Rec."PR IN Amount")
                {
                    ApplicationArea = All;
                }
                field("PR OUT Amount"; Rec."PR OUT Amount")
                {
                    ApplicationArea = All;
                    Width = 17;
                }
                field("PR Amount"; Rec."PR Amount")
                {
                    ApplicationArea = All;
                }
                field("PO IN Amount"; Rec."PO IN Amount")
                {
                    ApplicationArea = All;
                }
                field("PO OUT Amount"; Rec."PO OUT Amount")
                {
                    ApplicationArea = All;
                }
                field("PO Amount"; Rec."PO Amount")
                {
                    ApplicationArea = All;
                }
                field("Actual Amount Exc. VAT"; Rec."Actual Amount Exc. VAT")
                {
                    ApplicationArea = All;
                }
                field("Posted Invoice No."; Rec."Posted Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Posted Invoice Line No."; Rec."Posted Invoice Line No.")
                {
                    ApplicationArea = All;
                }
                field("PO IN Quantity"; Rec."PO IN Quantity")
                {
                    ApplicationArea = All;
                }
                field("PO OUT Quantity"; Rec."PO OUT Quantity")
                {
                    ApplicationArea = All;
                }
                field("PO Quantity"; Rec."PO Quantity")
                {
                    ApplicationArea = All;
                }
                field("PR IN Quantity"; Rec."PR IN Quantity")
                {
                    ApplicationArea = All;
                }
                field("PR OUT Quantity"; Rec."PR OUT Quantity")
                {
                    ApplicationArea = All;
                }
                field("PR Quantity"; Rec."PR Quantity")
                {
                    ApplicationArea = All;
                }
                field("Ref. Document Line No."; Rec."Ref. Document Line No.")
                {
                    ApplicationArea = All;
                }
                field("Ref. Document No."; Rec."Ref. Document No.")
                {
                    ApplicationArea = All;
                }
                field("Ref. Entry No."; Rec."Ref. Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Ref. Item Ledger Entry"; Rec."Ref. Item Ledger Entry")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Currency Factor"; "Currency Factor")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
