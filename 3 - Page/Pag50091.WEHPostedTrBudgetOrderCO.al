page 50091 "WEH_Posted Tr. Budget Order CO"
{
    Caption = 'Posted Transfer Budget Order - Corporate';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Header";
    SourceTableView = SORTING("No.") WHERE("Document Type" = CONST("Transfer Budget"), Status = CONST(Posted));
    RefreshOnActivate = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    //PromotedActionCategoriesML = ENU=New,Process,Reports,Functions,Prints,Posting;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        AssistEdit(Rec);
                    end;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Requested by"; "Requested by")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requested Name"; "Requested Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approve Status"; "Approve Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approved by"; "Approved by")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approved Date"; "Approved Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Created by"; "Created by")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posted by"; "Posted by")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Post to Budget"; "Post to Budget")
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
            }
            part(BudgetCorpLines; "WEH_Posted Tr. Budget Sub CO")
            {
                SubPageLink = "Document No." = FIELD("No.");
            }
            group(Remarks)
            {
                field("Remark 3"; "Remark 3")
                {
                    ApplicationArea = All;
                }
                field("Remark 4"; "Remark 4")
                {
                    ApplicationArea = All;
                }
                field("Remark 5"; "Remark 5")
                {
                    ApplicationArea = All;
                }
                field("Remark 6"; "Remark 6")
                {
                    ApplicationArea = All;
                }
                field("Remark 7"; "Remark 7")
                {
                    ApplicationArea = All;
                }
                field("Remark 8"; "Remark 8")
                {
                    ApplicationArea = All;
                }
                field("Remark 9"; "Remark 9")
                {
                    ApplicationArea = All;
                }
                field("Remark 10"; "Remark 10")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
