page 50087 "WEH_Posted Add Budget List CO"
{
    Caption = 'Posted Add Budget List - Corporate';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Header";
    SourceTableView = SORTING("No.") WHERE("Document Type" = CONST("Add Budget"), Status = CONST(Posted));
    CardPageId = "WEH_Posted Add Budget Order CO";
    Editable = false;
    PromotedActionCategories = 'New,Process,Reports,Approve,Post';
    //PromotedActionCategoriesML = ENU=New,Process,Reports,Functions,Prints,Posting;

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
