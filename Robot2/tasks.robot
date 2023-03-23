*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot orders website
    ${orders}=    Get Orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Wait Until Keyword Succeeds    10x    .5 sec    Submit the order
        Create receipt PDF with robot preview image    ${row}[Order number]    ${screenshot}
        Order new Robot
    END
    Create a ZIP file of receipt PDF files
    Cleanup


*** Keywords ***
Open the robot orders website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Wait Until Element Is Visible    order

Get Orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

    ${orders}=    Read table from CSV    orders.CSV
    RETURN    ${orders}

Close the annoying modal
    Click Button    OK

 Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    preview

Take a screenshot of the robot
    [Arguments]    ${row}
    Wait Until Element Is Visible    robot-preview-image
    Set Local Variable    ${Shot1}    ${OUTPUT_DIR}${/}robot-preview-image_${row}.png
    Screenshot    robot-preview-image    ${Shot1}
    RETURN    ${Shot1}

Submit the order
    Wait Until Element Is Visible    order
    Click Button    order
    Wait Until Element Is Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${row}
    ${recipit_results}=    Get Element Attribute    id:receipt    outerHTML
    #Set Local Variable    ${PDF101}    ${OUTPUT_DIR}${/}sales_results${row}.png
    Set Local Variable    ${PDF101}    ${OUTPUT_DIR}${/}sales_results${row}.pdf
    Html To Pdf    ${recipit_results}    ${OUTPUT_DIR}${/}sales_results${row}.pdf
    RETURN    ${PDF101}

Embed robot preview screenshot to receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${pngfiles}=    Create List    ${screenshot}:align=center
    Add Files To Pdf    ${pngfiles}    ${pdf}    append=True
    Close Pdf    ${pdf}

Create receipt PDF with robot preview image
    [Arguments]    ${row}    ${screenshot}
    ${pdf}=    Store the receipt as a PDF file    ${row}
    Embed robot preview screenshot to receipt PDF file    ${screenshot}    ${pdf}

Order new Robot
    Wait Until Element Is Visible    order-another
    Click Button    order-another

Create a ZIP file of receipt PDF files
    ${zipfile1}=    Set Variable    ${OUTPUT_DIR}${/}Recipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}    ${zipfile1}

Cleanup
    Close Browser
