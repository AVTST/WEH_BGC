page 50110 "WEH_Approval Details"
{
    Caption = 'Approval Details';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    Editable = false;
    SourceTable = "Approval Entry";
    //SourceTableView = sorting("Table ID", "Document Type", "Document No.", "Sequence No.", "Record ID to Approve");

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = All;
                }
                field("Sender ID"; "Sender ID")
                {
                    ApplicationArea = All;
                }
                field("Approver ID"; "Approver ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Date-Time Sent for Approval"; "Date-Time Sent for Approval")
                {
                    ApplicationArea = All;
                }
                field("Last Date-Time Modified"; "Last Date-Time Modified")
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
