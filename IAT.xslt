<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:this="urn:this-stylesheet"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                exclude-result-prefixes="xs this"
                version="2.0">
    <xsl:output encoding="UTF-8" method="text"/>
  
    <!-- Global Variables -->
    <xsl:variable name="linefeed" select="'&#13;&#10;'"/>
    <xsl:variable name="blank" select="''"/>
    <xsl:variable name="batchCount" select="1"/>

    <!-- Hardcoded Variables For File Header-->
    <xsl:variable name="recordTypeCode" select="'1'" />
    <xsl:variable name="priorityCode" select="'01'" />
    <xsl:variable name="formatCode" select="'1'" />
    <xsl:variable name="recordSize" select="'094'" />
    <xsl:variable name="blockingFactor" select="'10'" />
    <xsl:variable name="immediateDestination" select="'DESTCODE'" />
    <xsl:variable name="immediateDestinationName" select="'DESTINATIONNAME'" />
    <xsl:variable name="immediateOrigin" select="'ORIGINCODE'" />
    <xsl:variable name="immediateOriginName" select="'ORIGINNAME'" />
    <xsl:variable name="fileIDModifier" select="'2'"/>
    
    <!-- Hardcoded Variables For Batch Header-->
    <xsl:variable name="recordTypeCodeBatch" select="'5'" />
    <xsl:variable name="serviceClassCode" select="'200'" />
    <xsl:variable name="companyName" select="'ORIGINNAME'" />
    <xsl:variable name="foreignExchangeIndicator" select="'FF'" /> <!-- USD to USD Fixed -->    
    <xsl:variable name="isoCurrencyCode" select="'USD'" />
    <xsl:variable name="isoDestinationCountry" select="'US'" /> <!-- All accounts in example XSD had US accounts that were eventually leaving the US -->
    <xsl:variable name="foreignExchangeReferenceIndicator" select="'3'" />
    <xsl:variable name="foreignExchangeReference" select="''" />
    <xsl:variable name="iatOriginatorID" select="'ORIGINACCOUNTID'" />
    <xsl:variable name="companyID" select="'ORIGINCOMPANYID'" />
    <xsl:variable name="standardEntryClassCode" select="'IAT'" />
    <xsl:variable name="companyEntryDescription" select="'BATCHNAMEID'" />

    <xsl:variable name="originatorStatusCode" select="'1'"/>
    <xsl:variable name="batchNumber" select="'1000001'" />

    <!-- Hardcoded Variables for Entry Detail Record -->
    <xsl:variable name="entryDetailSequenceNumberRecordTypeCode" select="'6'" />
    <xsl:variable name="addendaRecordIndicator" select="'1'" />
    <xsl:variable name="entryDetailSequenceNumber" select="'1'" />

    <!-- Hardcoded Variables for Addenda Record -->
    <xsl:variable name="addendaRecordTypeCode" select="'7'" />
    <xsl:variable name="addendaType10Code" select="'10'" />
    <xsl:variable name="addendaTransactionTypeCode" select="'DEP'" />
    <xsl:variable name="addendaType11Code" select="'11'" />
    <xsl:variable name="addendaType12Code" select="'12'" />
    <xsl:variable name="addendaType13Code" select="'13'" />
    <xsl:variable name="addendaType14Code" select="'14'" />
    <xsl:variable name="addendaType15Code" select="'15'" />
    <xsl:variable name="addendaType16Code" select="'16'" />
    <xsl:variable name="addendaTypeCode" select="'17'" />
    <xsl:variable name="addendaSequenceNumber" select="'1'" />
    
    <xsl:variable name="originatorAddress" select="'123 FAKE STREET'" />
    <xsl:variable name="originatorCityAndState" select="'CITY*STATE\'" />
    <xsl:variable name="originatorCountryAndZip" select="'US*10101\'" />
    <xsl:variable name="originatorBankName" select="'BANKNAME'" />
    <xsl:variable name="bankCountryCode" select="'US'" /><!-- Bank Country Code is US for examples -->
    <xsl:variable name="bankQualifier" select="'01'" /><!-- Bank Qualifier is 01 (US) for examples -->

    
    <!-- Hardcoded Variables for Batch Control Record -->    
    <xsl:variable name="recordTypeCodeBatchControl" select="'8'" />
    <xsl:variable name="fileControlRecordTypeCode" select="'9'" />

    
   
     <!-- Root Template -->
      <xsl:template match="/">
        <!-- File Header -->
        <xsl:apply-templates select="Report_Data/Report_Entry[1]" mode="FileHeader"/>

        <!-- Positive Amounts -->
        <xsl:if test="Report_Data/Report_Entry[Amount &gt; 0]">
          <xsl:variable name="batchNumber" select="'1000001'" />
         <xsl:variable name="serviceClassCode" select="'220'" />
          <!-- Batch Header -->
          <xsl:apply-templates select="Report_Data/Report_Entry[1]" mode="BatchHeader"/>
          <!-- Entry Detail -->
          <!-- Iterate each report entry and keep count of iterator. Pass the iterator as value to entryDetailSequenceNumber-->

          <xsl:apply-templates select="Report_Data/Report_Entry[Amount &gt; 0]" mode="EntryDetail"/>
          <!-- Batch Control for positive amounts -->
          <xsl:apply-templates select="Report_Data" mode="BatchControl"/>	
        </xsl:if>

        <!-- File Control -->
        <xsl:apply-templates select="Report_Data" mode="FileControl"/>
        <!-- Blocking Factor -->
        <xsl:call-template name="BlockingFactor"/>
      </xsl:template>

    <!-- File Header Record Template -->
    <xsl:template match="/Report_Data/Report_Entry[1]" mode="FileHeader">
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($recordTypeCode, 1)" />
        <!-- Priority Code -->
        <xsl:value-of select="this:pad-to-length($priorityCode, 2)" />
        <!-- Immediate Destination -->
        <xsl:value-of select="this:pad-to-length(concat(' ',format-number($immediateDestination,'#')), 10)" />
        <!-- Immediate Origin -->
        <xsl:value-of select="this:pad-to-length(format-number($immediateOrigin,'#'), 10)" />
        <!-- File Creation Date -->
        <xsl:value-of select="this:pad-to-length(File_Create_or_Transmission_Date, 6)" />
        <!-- File Creation Time -->
        <xsl:value-of select="this:pad-to-length(File_Create_or_Transmission_Time, 4)" />
        <!-- File ID Modifier -->
        <xsl:value-of select="this:pad-to-length($fileIDModifier, 1)" />
        <!-- Record Size -->
        <xsl:value-of select="this:pad-to-length($recordSize, 3)" />
        <!-- Blocking Factor -->
        <xsl:value-of select="this:pad-to-length($blockingFactor, 2)" />
        <!-- Format Code -->
        <xsl:value-of select="this:pad-to-length($formatCode, 1)" />
        <!-- Immediate Destination Name -->
        <xsl:value-of select="this:pad-to-length($immediateDestinationName, 23)" />
        <!-- Immediate Origin Name -->
        <xsl:value-of select="this:pad-to-length($immediateOriginName, 23)" />
        <!-- Reference Code -->
        <xsl:value-of select="this:pad-to-length($blank, 8)" />
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>

    <!-- Batch Header Record Template -->
    <xsl:template match="/Report_Data/Report_Entry[1]" mode="BatchHeader">
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($recordTypeCodeBatch, 1)" />
        <!-- Service Class Code -->
        <xsl:value-of select="this:pad-to-length($serviceClassCode, 3)" />
        <!-- Company Name -->
        <xsl:value-of select="this:pad-to-length($companyName, 16)" />
        <!-- Foreign Exchange Indicator -->
        <xsl:value-of select="this:pad-to-length($foreignExchangeIndicator, 2)" />
        <!-- Foreign Exchange Reference Indicator -->
        <xsl:value-of select="this:pad-to-length($foreignExchangeReferenceIndicator, 1)" />
        <!-- Foreign Exchange Reference -->
        <xsl:value-of select="this:pad-to-length($foreignExchangeReference, 15)" />
        <!-- ISO Destination Country Code -->
        <xsl:value-of select="this:pad-to-length($isoDestinationCountry, 2)" />
        <!-- Company Identification -->
        <xsl:value-of select="this:pad-to-length($iatOriginatorID, 10)" />
        <!-- Standard Entry Class Code -->
        <xsl:value-of select="this:pad-to-length($standardEntryClassCode, 3)" />
        <!-- Company Entry Description -->
        <xsl:value-of select="this:pad-to-length($companyEntryDescription, 10)" />
        <!-- Currency Code (Origination)-->
        <xsl:value-of select="this:pad-to-length($isoCurrencyCode, 3)" />
        <!-- Currency Code (Destination) - same as Origination for SAIF, as all transactions are sent to a US bank -->
        <xsl:value-of select="this:pad-to-length($isoCurrencyCode, 3)" />
        <!-- Effective Entry Date -->
        <xsl:value-of select="this:pad-to-length(Effective_Entry_Date, 6)" />		
        <!-- Settlement Date - left blank -->
        <xsl:value-of select="this:pad-to-length($blank, 3)" />
        <!-- Originator Status Code -->
        <xsl:value-of select="this:pad-to-length($originatorStatusCode, 1)" />
        <!-- Originating DFI Identification -->
        <xsl:value-of select="this:pad-to-length(Originating_DFI_ID, 8)" />
        <!-- Batch Number -->
        <xsl:value-of select="this:pad-to-length($batchNumber, 7)" />
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>

    <!-- Entry Detail Record Template -->
    <xsl:template match="/Report_Data/Report_Entry" mode="EntryDetail">
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($entryDetailSequenceNumberRecordTypeCode, 1)" />
        <!-- Transaction Code -->
        <xsl:value-of select="this:pad-to-length(Transaction_Code, 2)" />
        <!-- Receiving DFI Identification -->
        <xsl:value-of select="this:pad-to-length(Receiving_DFI_Identification, 8)" />
        <!-- Check Digit -->
        <xsl:value-of select="this:pad-to-length(Check_Digit, 1)" />
        <!-- Addenda Record Count- '7' if Addenda is present, '8' otherwise -->
        <xsl:value-of select="if (normalize-space(Addenda) != ' ') then '0008' else '0007'" />
        <!-- Reserved - left blank -->
        <xsl:value-of select="this:pad-to-length($blank, 13)" />
        <!-- Amount -->
        <xsl:value-of select="this:pad-to-length(format-number(abs(Amount) * 100, '#'), 10, '0', 'right')" />
        <!-- Individual Identification Number -->
        <xsl:value-of select="this:pad-to-length(Individual_Identification_Number, 35, ' ', 'right')" />
        <!-- Reserved - left blank -->
        <xsl:value-of select="this:pad-to-length($blank, 2)" />
        <!-- Gateway Operator Screening Originator - left blank -->
        <xsl:value-of select="this:pad-to-length($blank, 1)" />	
        <!-- Secondary Gateway Operator Screening Originator - left blank -->
        <xsl:value-of select="this:pad-to-length($blank, 1)" />
        <!-- Addenda Record Indicator - always '1' on IAT-->
        <xsl:value-of select="$addendaRecordIndicator" />
        <!-- Trace Number-->
        <xsl:variable name="entryDetailSequenceNumber" select="this:pad-to-length(Row_Sequence,7,'0','right')"/>
        <xsl:value-of select="this:pad-to-length(concat(substring(Trace_Number,1,8),this:pad-to-length(Row_Sequence, 7,'0', 'right')), 15, ' ', 'right')" />
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
        
        <!-- 1st Addenda Record (type 10)-->
        <xsl:call-template name="AddendaType10">
            <xsl:with-param name="record" select="." />
            <xsl:with-param name="entry" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        <!-- 2nd Addenda Record (type 11)-->
        <xsl:call-template name="AddendaType11">
            <xsl:with-param name="record" select="." />
            <xsl:with-param name="entry" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        <!-- 3rd Addenda Record (type 12)-->
        <xsl:call-template name="AddendaType12">
            <xsl:with-param name="record" select="." />
            <xsl:with-param name="entry" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        <!-- 4th Addenda Record (type 13)-->
        <xsl:call-template name="AddendaType13">
            <xsl:with-param name="record" select="." />
            <xsl:with-param name="entry" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        <!-- 5th Addenda Record (type 14)-->
        <xsl:call-template name="AddendaType14">
            <xsl:with-param name="record" select="." />
            <xsl:with-param name="entry" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        <!-- 6th Addenda Record (type 15)-->
        <xsl:call-template name="AddendaType15">
            <xsl:with-param name="record" select="." />
            <xsl:with-param name="entry" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        <!-- 7th Addenda Record (type 16)-->
        <xsl:call-template name="AddendaType16">
            <xsl:with-param name="record" select="." />
            <xsl:with-param name="entry" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        <!-- Call to AddendaRecord Template - type 17. Allowed only one addenda from XSD example -->
        <xsl:if test="normalize-space(Addenda) != ' ' and normalize-space(Addenda) != ''">
            <xsl:call-template name="AddendaRecord">
                <xsl:with-param name="addenda" select="Addenda" />
                <xsl:with-param name="entryDetailSequenceNumber" select="$entryDetailSequenceNumber" />
        </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- Addenda Type 10 Record Template -->
    <xsl:template name="AddendaType10">	
        <xsl:param name="record" />
        <xsl:param name="entry" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaType10Code, 2)" />
        <!-- Transaction Code -->
        <xsl:value-of select="this:pad-to-length($addendaTransactionTypeCode, 3)" />
        <!-- Foreign Payment Amount -->
        <xsl:value-of select="this:pad-to-length(format-number(abs($record/Amount) * 100, '#'), 18, '0', 'right')" />
        <!-- Foreign Trace Number -->
        <xsl:value-of select="this:pad-to-length($blank, 22)" />
        <!-- Receiving Name -->
        <xsl:value-of select="this:pad-to-length($record/Individual_Name_or_Receiving_Company_Name, 35)" />
        <!-- Reserved - Blank -->
        <xsl:value-of select="this:pad-to-length($blank, 6)" />
        <!-- Entry Detail -->
        <xsl:value-of select="$entry"/>
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>


    <!-- Addenda Type 11 Record Template -->
    <xsl:template name="AddendaType11">	
        <xsl:param name="record" />
        <xsl:param name="entry" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaType11Code, 2)" />
        <!-- Originator Name -->
        <xsl:value-of select="this:pad-to-length($immediateOriginName, 35)" />
        <!-- Street Address -->
        <xsl:value-of select="this:pad-to-length($originatorAddress, 35)" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length($blank, 14)" />
        <!-- Entry Detail -->
        <xsl:value-of select="$entry"/>
		<!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>


    <!-- Addenda Type 12 Record Template -->
    <xsl:template name="AddendaType12">
        <xsl:param name="record" />	
        <xsl:param name="entry" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaType12Code, 2)" />
        <!-- City and State -->
        <xsl:value-of select="this:pad-to-length($originatorCityAndState, 35)" />
        <!-- Country and Postal Code -->
        <xsl:value-of select="this:pad-to-length($originatorCountryAndZip, 35)" />
        <!-- Reserved-->
        <xsl:value-of select="this:pad-to-length($blank, 14)" />
        <!-- Entry Detail -->
        <xsl:value-of select="$entry"/>
		<!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>


    <!-- Addenda Type 13 Record Template -->
    <xsl:template name="AddendaType13">	
        <xsl:param name="record" />
        <xsl:param name="entry" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaType13Code, 2)" />
        <!-- Originating Banke -->
        <xsl:value-of select="this:pad-to-length($originatorBankName, 35)" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length($blank, 2)" />
        <!-- Originating DFI ID -->
        <xsl:value-of select="this:pad-to-length($record/Originating_DFI_ID, 34)" />
        <!-- Originating Branch Country Code -->
        <xsl:value-of select="this:pad-to-length($bankCountryCode, 3)" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length($blank, 10)" />
        <!-- Entry Detail -->
        <xsl:value-of select="$entry"/>
		<!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>


    <!-- Addenda Type 14 Record Template -->
    <xsl:template name="AddendaType14">	
        <xsl:param name="record" />
        <xsl:param name="entry" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaType14Code, 2)" />
        <!-- Receiving Bank Name -->
        <xsl:value-of select="this:pad-to-length($record/Bank_Name, 35)" />
        <!-- Receiving Bank Qualifier -->
        <xsl:value-of select="this:pad-to-length($bankQualifier, 2)" />
        <!-- Receiving Bank Routing Number (DFI ID) -->
        <xsl:value-of select="this:pad-to-length($record/Receiving_DFI_Identification, 34)" />
        <!-- Receiving Branch Country Code -->
        <xsl:value-of select="this:pad-to-length($bankCountryCode, 3)" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length($blank, 10)" />
        <!-- Entry Detail -->
        <xsl:value-of select="$entry"/>
		<!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>


    <!-- Addenda Type 15 Record Template -->
    <xsl:template name="AddendaType15">	
        <xsl:param name="record" />
        <xsl:param name="entry" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaType15Code, 2)" />
        <!-- Identification Number -->
        <xsl:value-of select="this:pad-to-length($record/Individual_Identification_Number, 15)" />
        <!-- Street Address -->
        <xsl:value-of select="this:pad-to-length($record/Adtnl_Field02, 35)" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length($blank, 34)" />
        <!-- Entry Detail -->
        <xsl:value-of select="$entry"/>
		<!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>


    <!-- Addenda Type 16 Record Template -->
    <xsl:template name="AddendaType16">	
        <xsl:param name="record" />
        <xsl:param name="entry" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaType16Code, 2)" />
        <!-- City and State -->
        <xsl:value-of select="this:pad-to-length(concat($record/Adtnl_Field03,'*',$record/Adtnl_Field04 ,'\'), 35)" />
        <!-- Country and Zip -->
        <xsl:value-of select="this:pad-to-length(concat($record/Adtnl_Field05,'*',$record/Adtnl_Field06 ,'\'), 35)" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length($blank, 14)" />
        <!-- Entry Detail -->
        <xsl:value-of select="$entry"/>
		<!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>


    <!-- Addenda Record Template -->
    <xsl:template name="AddendaRecord">
        <xsl:param name="addenda" />
        <xsl:param name="entryDetailSequenceNumber" />
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaRecordTypeCode, 1)" />
        <!-- Addenda Type Code -->
        <xsl:value-of select="this:pad-to-length($addendaTypeCode, 2)" />
        <!-- Payment Related Information -->
        <xsl:value-of select="this:pad-to-length($addenda, 80)" />
        <!-- Addenda Sequence Number -->
        <xsl:value-of select="this:pad-to-length($addendaSequenceNumber, 4)" />
        <!-- Entry Detail Sequence Number -->
        <xsl:value-of select="this:pad-to-length($entryDetailSequenceNumber, 7)" />
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>

    <!-- Batch Control Record Template -->
    <xsl:template match="Report_Data" mode="BatchControl">
        <!-- Selecting Report Entry node as a variable -->
        <xsl:variable name="reportEntries" select="Report_Entry" />
        <!-- Entry Hash of Receiving DFI -->
        <xsl:variable name="sumOfReceivingDFI" select="format-number(sum($reportEntries/Receiving_DFI_Identification), '#')"/>
        <!-- String Length of Entry Hash, used if EntryHash is not a mod 10 number -->
        <xsl:variable name="strLenSumReceivingDFI" select="string-length(string(format-number(sum($reportEntries/Receiving_DFI_Identification), '#')))"/>

        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($recordTypeCodeBatchControl, 1)" />
        <!-- Service Class Code -->
        <xsl:value-of select="this:pad-to-length($serviceClassCode, 3)" />
        <!-- Entry/Addenda Count -->
        <xsl:value-of select="this:pad-to-length(count($reportEntries)+ count($reportEntries/Addenda), 6, '0', 'right')" />

        <!-- Entry Hash -->
        <xsl:choose>
            <xsl:when test="$strLenSumReceivingDFI > 10">
                <xsl:value-of select="substring($sumOfReceivingDFI,$strLenSumReceivingDFI - 10,10)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="this:pad-to-length($sumOfReceivingDFI, 10, '0', 'right')"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Total Debit Entry Dollar Amount -->
        <xsl:value-of select="this:pad-to-length(format-number(sum($reportEntries[Amount &lt; 0]/Amount) * 100,'#'), 12, '0', 'right')" />
        <!-- Total Credit Entry Dollar Amount -->
        <xsl:value-of select="this:pad-to-length(format-number(sum($reportEntries[Amount &gt; 0]/Amount) * 100,'#'), 12, '0', 'right')" />
        <!-- Company Identification -->
        <xsl:value-of select="this:pad-to-length($companyID, 10)" />
        <!-- Message Authentication Code -->
        <xsl:value-of select="this:pad-to-length($blank, 19)" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length($blank, 6)" />
        <!-- Originating DFI Identification -->
        <xsl:value-of select="this:pad-to-length($reportEntries[1]/Originating_DFI_ID, 8)" />
        <!-- Batch Number -->
        <xsl:value-of select="this:pad-to-length($batchNumber, 7)" />
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>

    <!-- File Control Record Template -->
    <xsl:template match="Report_Data" mode="FileControl">
    <!-- Entry Hash of Receiving DFI -->
    <xsl:variable name="sumOfReceivingDFI" select="format-number(sum(//Receiving_DFI_Identification), '#')"/>
    <!-- String Length of Entry Hash, used if EntryHash is greater than 10 digits long -->
        <xsl:variable name="strLenSumReceivingDFI" select="string-length(string(format-number(sum(//Receiving_DFI_Identification), '#')))"/>

        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($fileControlRecordTypeCode, 1)" />
        <!-- Batch Count -->
        <xsl:value-of select="this:pad-to-length($batchCount, 6, '0', 'right')" />
        <!-- Block Count: (Count of 6 records (x8 to include 710 thru 716 records) + count of 717 records + count of batches x 2 (5 and 8 records) + 2 (1 and 9 records)) divided by 10, then rounded up (ceiling) -->
        <xsl:value-of select="this:pad-to-length(ceiling(((count(/Report_Data/Report_Entry) * 8) + count(/Report_Data/Report_Entry/Addenda) + ($batchCount * 2) + 2) div 10), 6, '0', 'right')" />
        <!-- Entry/Addenda Count -->
        <xsl:value-of select="this:pad-to-length(count(/Report_Data/Report_Entry) + count(/Report_Data/Report_Entry/Addenda), 8, '0', 'right')" />

        <!-- Entry Hash -->
        <xsl:choose>
            <xsl:when test="$strLenSumReceivingDFI > 10">
                <xsl:value-of select="substring($sumOfReceivingDFI,$strLenSumReceivingDFI - 10,10)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="this:pad-to-length($sumOfReceivingDFI, 10, '0', 'right')"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Total Debit Entry Dollar Amount -->
        <xsl:value-of select="this:pad-to-length(string(format-number(sum(/Report_Data/Report_Entry/Amount[. &lt; 0]) * 100,'#')), 12, '0', 'right')" />
        <!-- Total Credit Entry Dollar Amount -->
        <xsl:value-of select="this:pad-to-length(string(format-number(sum(/Report_Data/Report_Entry/Amount[. &gt; 0]) * 100,'#')), 12, '0', 'right')" />
        <!-- Reserved -->
        <xsl:value-of select="this:pad-to-length(' ', 39)" />
    </xsl:template>

   <!-- Overloaded function for pad-to-length. First allows a default of using spaces and left alignment -->
    <xsl:function name="this:pad-to-length">
        <xsl:param name="input"/>
        <xsl:param name="length"/>
        <xsl:value-of select="this:pad-to-length($input, $length, ' ', 'left')" />
    </xsl:function>

   <!-- Overloaded function for pad-to-length. Second allows a default of custom padding and alignment -->
    <xsl:function name="this:pad-to-length">
        <xsl:param name="input"/>
        <xsl:param name="length"/>
        <xsl:param name="padding"/>
        <xsl:param name="direction"/>

        <xsl:variable name="padLength">
            <xsl:value-of select="$length - string-length(string($input))"/>
        </xsl:variable>

        <xsl:variable name="pad">
            <xsl:for-each select="1 to $padLength">
                <xsl:value-of select="$padding"/>
            </xsl:for-each>
        </xsl:variable>
		
		<!-- Pad the string -->
        <xsl:value-of select="if ($direction = 'right') then substring(concat($pad,$input),1,$length) else substring(concat($input,$pad),1,$length)"/>
    </xsl:function>

    <!-- Output line for creating the blocking factor -->
    <xsl:template name="outputLine">
            <xsl:value-of select="$linefeed"/>
            <xsl:value-of select="'9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999'"/>
    </xsl:template>
    
    <!-- Blocking Factor Template -->
    <xsl:template name="BlockingFactor">
        
        <!--Blocking Factor Variables-->
        <xsl:variable name="counterSum" select="sum(//Counter)"/>
        <xsl:variable name="vBlockCountDivTen" select="format-number(((8*($counterSum) + 2 + 2*($batchCount) + count(//Addenda[normalize-space() != ' '])) div 10), '#.#')"/>
        <xsl:variable name="vBlockCountDivTenCeiling" select="format-number(ceiling((8*($counterSum) + 2 + 2*($batchCount)+ count(//Addenda[normalize-space() != ' '])) div 10), '#.#')"/>
        <xsl:variable name="vBlockCeilingMinusBlock" select="format-number(number($vBlockCountDivTenCeiling) - number($vBlockCountDivTen), '#.#')"/>
          
        
        <!-- Simplified with a choose -->
        <xsl:choose>
            <xsl:when test="$counterSum = 0">
            	<xsl:for-each select="1 to 6">
                	<xsl:call-template name="outputLine"/>
             	</xsl:for-each>
            </xsl:when>
            <xsl:when test="$vBlockCeilingMinusBlock = '.8' and $counterSum != 0">                
            	<xsl:for-each select="1 to 8">
                	<xsl:call-template name="outputLine"/>
             	</xsl:for-each>
            </xsl:when>
            <xsl:otherwise>            
            	<xsl:for-each select="1 to xs:integer(number(substring-after($vBlockCeilingMinusBlock, '.')))">
                	<xsl:call-template name="outputLine"/>
             	</xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>                    	
    </xsl:template>
</xsl:stylesheet>
