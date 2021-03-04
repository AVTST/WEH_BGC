page 50092 "WEH_Posted Tr. Budget Sub CO"
{
    Caption = 'Lines';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Line";
    DelayedInsert = true;
    AutoSplitKey = true;
    LinksAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Budget Type"; "Budget Type")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        //AVTMGWEH 19/01/2021 Add
                        Clear(AVGLAccountTB);
                        if AVGLAccountTB.Get("G/L Account No.") then;
                        //C-AVTMGWEH 19/01/2021 Add
                    end;
                }
                //AVTMGWEH 19/01/2021 Add
                field("G/L Description"; AVGLAccountTB.Name)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //C-AVTMGWEH 19/01/2021 Add
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                }
                field("Budget Dimension 1 Code"; "Budget Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Budget Dimension 2 Code"; "Budget Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("To G/L Account No."; "To G/L Account No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        //AVTMGWEH 19/01/2021 Add
                        Clear(AVGLAccountToTB);
                        if AVGLAccountToTB.Get("To G/L Account No.") then;
                        //C-AVTMGWEH 19/01/2021 Add
                    end;
                }
                //AVTMGWEH 19/01/2021 Add
                field("To G/L Description"; AVGLAccountToTB.Name)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //C-AVTMGWEH 19/01/2021 Add
                field("To Global Dimension 1 Code"; "To Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("To Global Dimension 2 Code"; "To Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("To Budget Dimension 1 Code"; "To Budget Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("To Budget Dimension 2 Code"; "To Budget Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("To Description"; "To Description")
                {
                    ApplicationArea = All;
                }
                field("To Total Amount (LCY)"; "To Total Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("To Start Date"; "To Start Date")
                {
                    ApplicationArea = All;
                }
                field("To End Date"; "To End Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        //AVTMGWEH 19/01/2021 Add
        Clear(AVGLAccountTB);
        if AVGLAccountTB.Get("G/L Account No.") then;

        Clear(AVGLAccountToTB);
        if AVGLAccountToTB.Get("To G/L Account No.") then;
        //C-AVTMGWEH 19/01/2021 Add
    end;

    var
        AVGLAccountTB: Record "G/L Account"; //AVTMGWEH 19/01/2021 Add
        AVGLAccountToTB: Record "G/L Account"; //AVTMGWEH 19/01/2021 Add
}
