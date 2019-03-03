'UofMN Data Analytics Bootcamp
'Homework #2
'Created by Chris Howard 
'03/03/2019

'Note - this script requires the 'Microsoft Scripting Runtime' to be activated
'under the VBA project by selecting it under Tools->References

'The correct answers will be given for each stock symbol assuming only that they are in chronological order 
'and that the column order and placement of the raw data on the worksheet doesn't vary from sheet to sheet.

Sub Stock_analysis()

Dim ws As Worksheet
For Each ws In ThisWorkbook.Worksheets          'Loop through all worksheets in the workbook
    ws.Activate


    Dim compdict As Scripting.Dictionary        'create compdict as dictionary for storing key->value information
    Set compdict = New Scripting.Dictionary
    Dim items(1 To 3) As Variant                'used to add initial data to compdict
    Dim tempArray As Variant                    'used to pull, modify, and re-add array data as values to compdict
    ReDim tempArray(1 To 3)                     'must use ReDim since data from dict can't read into a defined array
    Dim i As Double
    Dim key As String
    Dim annualOpen As Double
    Dim annualClose As Double
    Dim volume As Double
    Dim rowLength As Double
    
    rowLength = Range("A1").End(xlDown).Row
    
    'Go through raw data and add open, close, and volume information as values for unique ticker (keys)
    
    For i = 2 To rowLength
    
        key = Cells(i, 1).Value                 'use the ticker as a unique key in the dictionary
        annualOpen = Cells(i, 3).Value          'assume first open value found is the annual open
        annualClose = Cells(i, 6).Value
        volume = Cells(i, 7).Value
        
        If compdict.Exists(key) Then
            tempArray = compdict.Item(key)
            tempArray(2) = annualClose          'update close value everytime the same ticker is found, last update will be last annual value as long as the ticker information is in chronological order
            tempArray(3) = tempArray(3) + volume 'update volume total for selected ticker (key)
            compdict.Item(key) = tempArray      're-add the array to the dictionary entry for the key
            Erase tempArray                     'clear array for next use
        Else
            'Create initial array (items) to add as a value for the newly found ticker symbol key
            items(1) = annualOpen
            items(2) = annualClose
            items(3) = volume
            compdict.Add key, items()
            Erase items()
        End If
        
    Next i
    
    'Label columns for data output from dictionary
    
    Cells(1, 10).Value = "Ticker Symbol"
    Cells(1, 11).Value = "Annual Open"
    Cells(1, 12).Value = "Annual Close"
    Cells(1, 13).Value = "Annual Change"
    Cells(1, 14).Value = "Percent Change"
    Cells(1, 15).Value = "Total Volume"
    
    'New loop variables to read through dictionary
    
    Dim j As Double
    Dim k As Double
    Dim ticker As String
    Dim annualChange As Double
    Dim pctChange As Double
    
        
    k = 2
    
    'loop through dictionary and enter data into the spreadsheet
    
    For j = 0 To compdict.Count - 1
               
       ticker = compdict.Keys(j)
       annualOpen = compdict.items(j)(1)
       annualClose = compdict.items(j)(2)
       annualChange = annualClose - annualOpen
       volume = compdict.items(j)(3)
       
       Cells(k, 10).Value = ticker
       Cells(k, 11).Value = annualOpen
       Cells(k, 12).Value = annualClose
       Cells(k, 13).Value = annualChange
       If annualChange > 0 Then
            Cells(k, 13).Interior.ColorIndex = 4
        ElseIf annualChange < 0 Then
            Cells(k, 13).Interior.ColorIndex = 3
        End If
        If annualOpen = 0 Then                      'avoid a divide by zero error if first price is 0
            Cells(k, 14).Value = 0
        Else
            Cells(k, 14).Value = annualChange / annualOpen
       End If
       Cells(k, 15).Value = volume
       k = k + 1
    Next j
    
    
    'Check for Highest Volume, Greatest Percent Increase and Decrease and display those separately
    
    Dim highpct As Double
    Dim highpctTicker As String
    Dim lowpct As Double
    Dim lowpctTicker As String
    Dim highvol As Double
    Dim highvolTicker As String
    
    'Initialize variables
    
    i = 2
    highpct = 0
    lowpct = 0
    highvol = 0
    
    'Add labels for selected values
    
    Range("Q2") = "Greatest Percent Increase"
    Range("Q3") = "Greatest Percent Decrease"
    Range("Q4") = "Greatest Total Volume"
    Range("R1") = "Ticker"
    Range("S1") = "Value"
    
    'Loop through combined ticker data to find highest and lowest percentage changes and highest annual volume
    
    Do While Cells(i, 10).Value <> ""
    
        ticker = Cells(i, 10).Value
        pctChange = Cells(i, 14).Value
        volume = Cells(i, 15).Value
        
        If pctChange > highpct Then
            highpct = pctChange
            highpctTicker = ticker
        End If
        
        If pctChange < lowpct Then
            lowpct = pctChange
            lowpctTicker = ticker
        End If
        
        If volume > highvol Then
            highvol = volume
            highvolTicker = ticker
        End If
        
        i = i + 1
        
    Loop
    
    Range("R2") = highpctTicker
    Range("S2") = highpct
    Range("R3") = lowpctTicker
    Range("S3") = lowpct
    Range("R4") = highvolTicker
    Range("S4") = highvol
    
    'Formatting for percentages and large numbers
    
    Range("N:N,S2:S3").NumberFormat = "0.00%"
    Range("O:O,S4").NumberFormat = "0,000"

Next ws


End Sub