page 50084 "WEH_Transfer Budget List CORP"
{
    Caption = 'Transfer Budget List - Corporate';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Header";
    SourceTableView = SORTING("No.") WHERE("Document Type" = CONST("Transfer Budget"), Status = CONST(" "));
    CardPageId = "WEH_Transfer Budget Order CORP";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Approve Status"; "Approve Status")
                {
                    ApplicationArea = all;
                }
                field("Requested by"; "Requested by")
                {
                    ApplicationArea = All;
                }
                field("Requested Name"; "Requested Name")
                {
                    ApplicationArea = All;
                }
                field(Remark; Remark)
                {
                    ApplicationArea = All;
                }
                field("Remark 2"; "Remark 2")
                {
                    ApplicationArea = All;
                }
                field("Post to Budget"; "Post to Budget")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
