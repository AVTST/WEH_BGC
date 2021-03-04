page 50083 "WEH_Add Budget Subform CORP"
{
    Caption = 'Lines';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Line";
    DelayedInsert = true;
    AutoSplitKey = true;
    LinksAllowed = false;

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
                field("Total Amount (LCY)"; "Total Amount (LCY)")
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
                    Visible = false;
                }
                field("Budget Dimension 2 Code"; "Budget Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }

    }
    trigger OnAfterGetRecord()
    begin
        //AVTMGWEH 19/01/2021 Add
        Clear(AVGLAccountTB);
        if AVGLAccountTB.Get("G/L Account No.") then;
        //C-AVTMGWEH 19/01/2021 Add
    end;

    var
        AVGLAccountTB: Record "G/L Account"; //AVTMGWEH 19/01/2021 Add
}
