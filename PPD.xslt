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
    <xsl:variable name="immediateDestination" select="'DESTBANKID'" />
    <xsl:variable name="immediateDestinationName" select="'DESTINATIONBANK'" />
    <xsl:variable name="immediateOrigin" select="'ORIGINBANKID'" />
    <xsl:variable name="immediateOriginName" select="'COMPANY'" />
    <xsl:variable name="fileIDModifier" select="'1'"/>
    
    <!-- Hardcoded Variables For Batch Header-->
    <xsl:variable name="recordTypeCodeBatch" select="'5'" />
    <xsl:variable name="sClassCode" select="'200'" /> <!-- Mixed batch, can be switched to 220 for debit only, or 225 for credit only  -->
    <xsl:variable name="companyName" select="'COMPANYNAME'" />
    <xsl:variable name="companyDiscretionaryData" select="'COMPANYCONTACT'" />
    <xsl:variable name="companyID" select="'COMPANYBANKID'" />
    <xsl:variable name="standardEntryClassCode" select="'PPD'" />
    <xsl:variable name="companyEntryDescription" select="'PAYMENTGROUPID'" />
    <xsl:variable name="originatorStatusCode" select="'1'"/>
    <xsl:variable name="batchNumber" select="'1000001'" />

    <!-- Hardcoded Variables for Entry Detail Record -->
    <xsl:variable name="entryDetailRecordTypeCode" select="'6'" />

    <!-- Hardcoded Variables for Addenda Record -->
    <xsl:variable name="addendaRecordTypeCode" select="'7'" />
    <xsl:variable name="addendaTypeCode" select="'05'" />
    <xsl:variable name="addendaSequenceNumber" select="'1'" />
    
    <!-- Hardcoded Variables for Batch Control Record -->    
    <xsl:variable name="recordTypeCodeBatchControl" select="'8'" />
    <xsl:variable name="fileControlRecordTypeCode" select="'9'" />
    
    
    
     <!-- Root Template -->
      <xsl:template match="/">
        <!-- File Header -->
        <xsl:apply-templates select="Report_Data/Report_Entry[1]" mode="FileHeader"/>
        
        <!-- Batch Header -->
        <xsl:apply-templates select="Report_Data/Report_Entry[1]" mode="BatchHeader">
          <xsl:with-param name="serviceClassCode" select="$sClassCode"/>
        </xsl:apply-templates>          		
        <!-- Entry Detail -->
        <xsl:apply-templates select="Report_Data/Report_Entry" mode="EntryDetail"/>          		
        <!-- Batch Control-->
        <xsl:apply-templates select="Report_Data" mode="BatchControl">
          <xsl:with-param name="serviceClassCode" select="$sClassCode"/>
        </xsl:apply-templates>

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
    	<xsl:param name="serviceClassCode"/>
        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($recordTypeCodeBatch, 1)" />
        <!-- Service Class Code -->
        <xsl:value-of select="this:pad-to-length($serviceClassCode, 3)" />
        <!-- Company Name -->
        <xsl:value-of select="this:pad-to-length($companyName, 16)" />
        <!-- Company Discretionary Data -->
        <xsl:value-of select="this:pad-to-length($companyDiscretionaryData, 20)" />
        <!-- Company Identification -->
        <xsl:value-of select="this:pad-to-length($companyID, 10)" />
        <!-- Standard Entry Class Code -->
        <xsl:value-of select="this:pad-to-length($standardEntryClassCode, 3)" />
        <!-- Company Entry Description -->
        <xsl:value-of select="this:pad-to-length($companyEntryDescription, 10)" />
        <!-- Company Descriptive Date -->
        <xsl:value-of select="this:pad-to-length(Company_Descriptive_Date, 6)" />
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
        <xsl:value-of select="this:pad-to-length($entryDetailRecordTypeCode, 1)" />
        <!-- Transaction Code -->
        <xsl:value-of select="this:pad-to-length(Transaction_Code, 2)" />
        <!-- Receiving DFI Identification -->
        <xsl:value-of select="this:pad-to-length(Receiving_DFI_Identification, 8)" />
        <!-- Check Digit -->
        <xsl:value-of select="this:pad-to-length(Check_Digit, 1)" />
        <!-- DFI Account Number -->
        <xsl:value-of select="this:pad-to-length(DFI_Account_Number, 17)" />
        <!-- Amount -->
        <xsl:value-of select="this:pad-to-length(format-number(abs(Amount) * 100, '#'), 10, '0', 'right')" />
        <!-- Individual Identification Number -->
        <xsl:value-of select="this:pad-to-length(Individual_Identification_Number, 15, ' ', 'right')" />
        <!-- Individual Name or Receiving Company Name -->
        <xsl:value-of select="this:pad-to-length(Individual_Name_or_Receiving_Company_Name, 22)" />
        <!-- Discretionary Data -->
        <xsl:value-of select="this:pad-to-length(Discretionary_Data, 2)" />
        <!-- Addenda Record Indicator - '1' if Addenda is present, '0' otherwise -->
        <xsl:value-of select="if (normalize-space(Addenda) != '' and normalize-space(Addenda) != ' ') then '1' else '0'" />
        <!-- Trace Number -->
        <xsl:value-of select="this:pad-to-length(concat(substring(Trace_Number,1,8),this:pad-to-length(Row_Sequence, 7,'0', 'right')), 15, ' ', 'right')" />
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
        <!-- Call to AddendaRecord Template -->
        <xsl:if test="normalize-space(Addenda) != '' and normalize-space(Addenda) != ' '">
            <xsl:call-template name="AddendaRecord">
                <xsl:with-param name="addenda" select="Addenda" />
                <xsl:with-param name="entryDetailSequenceNumber" select="this:pad-to-length(Row_Sequence, 7,'0', 'right')" />
        </xsl:call-template>
        </xsl:if>
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
        <xsl:value-of select="this:pad-to-length($addendaSequenceNumber, 4, '0', 'right')" />
        <!-- Entry Detail Sequence Number -->
        <xsl:value-of select="this:pad-to-length($entryDetailSequenceNumber, 7)" />
        <!-- Newline to end the record -->
        <xsl:value-of select="$linefeed"/>
    </xsl:template>

    <!-- Batch Control Record Template -->
    <xsl:template match="Report_Data" mode="BatchControl">
    	<xsl:param name="serviceClassCode"/>
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
    <!-- String Length of Entry Hash, used if EntryHash is not a mod 10 number -->
        <xsl:variable name="strLenSumReceivingDFI" select="string-length(string(format-number(sum(//Receiving_DFI_Identification), '#')))"/>

        <!-- Record Type Code -->
        <xsl:value-of select="this:pad-to-length($fileControlRecordTypeCode, 1)" />
        <!-- Batch Count -->
        <xsl:value-of select="this:pad-to-length($batchCount, 6, '0', 'right')" />
        
	<!-- Block Count: (Count of 6 records + count of 7 records + count of batches x 2 (5 and 8 records) + 2 (1 and 9 records)) divided by 10, then rounded up (ceiling)-->
        <xsl:value-of select="this:pad-to-length(ceiling((count(/Report_Data/Report_Entry) + count(/Report_Data/Report_Entry/Addenda) + ($batchCount * 2) + 2) div 10), 6, '0', 'right')" />
        
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
        <xsl:value-of select="this:pad-to-length(string(abs(sum(/Report_Data/Report_Entry/Amount[. &lt; 0]) * 100)), 12, '0', 'right')" />
        <!-- Total Credit Entry Dollar Amount -->
        <xsl:value-of select="this:pad-to-length(string(abs(sum(/Report_Data/Report_Entry/Amount[. &gt; 0]) * 100)), 12, '0', 'right')" />
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

        <xsl:value-of select="if ($direction = 'right') then substring(concat($pad,$input),1,$length) else substring(concat($input,$pad),1,$length)"/>
    </xsl:function>
	
	<xsl:function name="this:wrapQuotes">
		<xsl:param name="field"/>
		<xsl:value-of select="'&quot;'"/>
		<xsl:value-of select="replace($field,'&quot;','&quot;&quot;')"/>
		<xsl:value-of select="'&quot;'"/>
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
    	<xsl:variable name="vBlockCountDivTen" select="format-number((($counterSum + 2 + 2*($batchCount) + count(//Addenda[normalize-space() != ' '])) div 10), '#.#')"/>
    	<xsl:variable name="vBlockCountDivTenCeiling" select="format-number(ceiling(($counterSum + 2 + 2*($batchCount)+ count(//Addenda[normalize-space() != ' '])) div 10), '#.#')"/>
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
