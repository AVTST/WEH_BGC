report 50021 "WEH_Add Budget Request"
{
    DefaultLayout = RDLC;
    RDLCLayout = '8 - Report/Rep50021.WEHAddBudgetRequest.rdl';
    Caption = 'Add Budget Reqeust';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("WEH_Add/T. Budget COR Header"; "WEH_Add/T. Budget COR Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(No_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."No.")
            {

            }
            column(CompanyInfo_Picture; CompanyInfo.Picture)
            {

            }
            column(ResourceName; DimensionValueTb.Name)
            {

            }
            column(DocumentDate_AddTransferBudgetCORHeader; FORMAT("Document Date", 0, '<Day,2>/<Month,2>/<Year4>'))
            {

            }
            column(Remark_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header".Remark)
            {

            }
            column(Remark2_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 2")
            {

            }
            column(Remark3_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 3")
            {

            }
            column(Remark4_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 4")
            {

            }
            column(Remark5_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 5")
            {

            }
            column(Remark6_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 6")
            {

            }
            column(Remark7_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 7")
            {

            }
            column(Remark8_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 8")
            {

            }
            column(Remark9_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 9")
            {

            }
            column(Remark10_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."Remark 10")
            {

            }
            dataitem("WEH_Add/T. Budget COR Line"; "WEH_Add/T. Budget COR Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = "WEH_Add/T. Budget COR Header";
                DataItemTableView = SORTING("Document No.", "Line No.");

                column(Running; Running)
                {

                }
                column(BudgetType_AddTransferBudgetCORLine; "WEH_Add/T. Budget COR Line"."Budget Type")
                {

                }
                column(GLAccountNo_AddTransferBudgetCORLine; "WEH_Add/T. Budget COR Line"."G/L Account No.")
                {

                }
                column(GlobalDimension1Code_AddTransferBudgetCORLine; "WEH_Add/T. Budget COR Line"."Global Dimension 1 Code")
                {

                }
                column(Description_AddTransferBudgetCORLine; "WEH_Add/T. Budget COR Line".Description)
                {

                }
                column(TotalAmountLCY_AddTransferBudgetCORLine; "WEH_Add/T. Budget COR Line"."Total Amount (LCY)")
                {

                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Running += 1;
                end;

                trigger OnPreDataItem()
                var
                    myInt: Integer;
                begin
                    //Line := COUNT;
                    CLEAR(Line);
                    CLEAR(AddTransferBudgetCORLine);
                    AddTransferBudgetCORLine.SETCURRENTKEY("Document No.", "Line No.");
                    AddTransferBudgetCORLine.SETRANGE("Document No.", "WEH_Add/T. Budget COR Header"."No.");
                    Line := AddTransferBudgetCORLine.COUNT;
                end;
            }

            dataitem(EmptyLine; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(Number_EmptyLine; EmptyLine.Number)
                {
                }

                trigger OnPreDataItem();
                begin
                    /*if Running = CountLine then begin
                        if (Running mod MaxLine) = 0 then
                            SetRange(Number, 1, 0)
                        else begin
                            AddLine := MaxLine - (Running mod MaxLine);
                            SetRange(Number, 1, AddLine);
                        end;
                    end
                    else
                        SetRange(Number, 1, 0);*///AVKSAVIP 24/04/2020
                    if Running = Line then begin
                        if (Running mod MaxLine) = 0 then
                            SetRange(Number, 1, 0)
                        else begin
                            AddLine := MaxLine - (Running mod MaxLine);
                            SetRange(Number, 1, AddLine);
                        end;
                    end
                    else
                        SetRange(Number, 1, 0);

                end;
            }

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                Clear(Running);
                CLEAR(Resource);
                IF "WEH_Add/T. Budget COR Header"."Requested by" <> '' then
                    if Resource.Get("WEH_Add/T. Budget COR Header"."Requested by") then;
                /*
                                CLEAR(Employee);
                                IF Employee.GET("WEH_Add/T. Budget COR Header"."Requested by") THEN;
                                */
                //AVAHTWEH 03/11/2020
                Clear(DimensionValueTB);
                DimensionValueTB.SetRange(Code, "Requested by");
                if DimensionValueTB.FindFirst then;
                //C-AVAHTWEH 03/11/2020
            end;

            trigger OnPreDataItem();
            begin
                CompanyInfo.GET;
                CompanyInfo.CALCFIELDS(Picture);

                MaxLine := 24;
            end;
        }
    }

    /*
        requestpage
        {
            layout
            {
                area(Content)
                {
                    group(GroupName)
                    {
                        field(Name; SourceExpression)
                        {
                            ApplicationArea = All;

                        }
                    }
                }
            }

            actions
            {
                area(processing)
                {
                    action(ActionName)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }
    */
    var
        CompanyInfo: Record "Company Information";
        Employee: Record Employee;
        Running: Integer;
        Maxline: Integer;
        AddLine: Integer;
        Resource: Record Resource;
        Subtotal: Decimal;
        TotalDiscount: Decimal;
        i: Integer;
        NetTotal: Decimal;
        Line: Integer;
        AddTransferBudgetCORLine: Record "WEH_Add/T. Budget COR Line";
        Qty: Decimal;
        UnitPrice: Decimal;
        AmountT: Decimal;
        DiscountAmount: Decimal;
        AmountVAT: Decimal;
        AmtExdVAT: Decimal;
        VATPersent: Integer;
        runno: Integer;
        DimensionValueTB: Record "Dimension Value";
}