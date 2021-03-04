page 50106 "WEH_Send Email History"
{
    Caption = 'Send Email History';
    PageType = List;
    UsageCategory = Administration;
    Editable = false;
    ApplicationArea = ALL;
    SourceTable = "WEH_Send Email History";
    SourceTableView = SORTING("Entry No.") ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = 0;
                field("Entry No."; "Entry No.") { ApplicationArea = ALL; Visible = false; }
                field("Document Entry No."; "Document Entry No.") { ApplicationArea = ALL; }
                field("Document No."; "Document No.") { ApplicationArea = ALL; }
                field("Date"; Date) { ApplicationArea = ALL; }
                field("Time"; Time) { ApplicationArea = ALL; }
                field("Send to"; "Send to") { ApplicationArea = ALL; }
                field("Carbon Copy"; "Carbon Copy") { ApplicationArea = ALL; }
                field("Assigned User ID"; "Assigned User ID") { ApplicationArea = ALL; }
            }
        }
    }
}
