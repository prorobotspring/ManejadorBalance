<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
	xmlns:rtbs="http://comverse-in.com/prepaid/ccws">
	<!-- Version transformacion RTBS -->
	<xsl:output method="text" />
	<!-- CONSTANTS -->
	<xsl:variable name="coreBName" select="'Core'" />
	
	<xsl:variable name="puntoSeparador" select="'. '" />
	<xsl:variable name="textSaldo" select="'Bs.F. '" />
	<xsl:variable name="textFecha" select="' que bloquea el '" />
	<xsl:variable name="textBonos" select="' y ademas tiene: '" />
	<xsl:decimal-format name="espaniol" decimal-separator=","
		grouping-separator="." />
	<!-- MAIN -->
	<xsl:template match="/">
		<xsl:apply-templates
			select="//rtbs:RetrieveSubscriberWithIdentityNoHistoryResult">
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template
		match="rtbs:RetrieveSubscriberWithIdentityNoHistoryResult">
		<xsl:apply-templates select="rtbs:SubscriberData"></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="rtbs:SubscriberData">
		<xsl:variable name="BS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName=$coreBName]/rtbs:Balance)" />
		<xsl:variable name="BONO"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='F_BS']/rtbs:Balance)" />
		<xsl:variable name="SEC"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_SEC_M2MF_ON-OFF-NET' or
rtbs:BalanceName='NF_SEC_M2MF_ON-NET' or rtbs:BalanceName='NF_SEC_M2MF_OFF-NET' or
rtbs:BalanceName='NF_SEC_LDI' or rtbs:BalanceName='F_SEC_M2MF_ON-NET' or
rtbs:BalanceName='F_SEC_M2MF_ON-OFF-NET' or
rtbs:BalanceName='F_SEC_M2MF_OFF-NET']/rtbs:Balance)" />
		<xsl:variable name="SMS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_SMS' or
rtbs:BalanceName='NF_SMS_PREMIUM' or rtbs:BalanceName='F_SMS' or
rtbs:BalanceName='F_SMS_PREMIUM']/rtbs:Balance)" />
		<xsl:variable name="MMS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_MMS' or
rtbs:BalanceName='F_MMS']/rtbs:Balance)" />
		<xsl:variable name="KB"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='F_KB' or
rtbs:BalanceName='NF_KB']/rtbs:Balance)" />
		<xsl:variable name="ExpiryDate"
			select="rtbs:Balances/rtbs:Balance[rtbs:BalanceName=$coreBName]/rtbs:AccountExpiration" />
		
		<!-- MENSAJE RETORNADO -->
		
		Línea activa.
		
		Súper pegado ilimitado.
		
		<xsl:value-of select="$textSaldo" />
		<xsl:value-of
			select="format-number($BS,'###.###.##0,00','espaniol')" />
		<xsl:if
			test="(substring($ExpiryDate,1,4) &lt; '2017') and
(substring($ExpiryDate,1,4) != '0001')">
			<xsl:value-of select="$textFecha" />
			<xsl:variable name="day"
				select="substring($ExpiryDate,9,2)" />
			<xsl:variable name="month"
				select="substring($ExpiryDate,6,2)" />
			<xsl:variable name="year"
				select="substring($ExpiryDate,3,2)" />
			<xsl:value-of select="concat($day,'/',$month,'/',$year)" />
		</xsl:if>
		<xsl:if test="$SEC + $SMS + $MMS + $KB &gt; 0">
			<xsl:value-of select="$textBonos" />
		</xsl:if>
		<xsl:if test="$SEC &gt; 0">
			<xsl:value-of
				select="format-number($SEC,'#.###Seg','espaniol')" />
			<xsl:value-of select="'; '" />
		</xsl:if>
		<xsl:if test="$SMS &gt; 0">
			<xsl:value-of
				select="format-number($SMS,'#.###SMS','espaniol')" />
			<xsl:value-of select="'; '" />
		</xsl:if>
		<xsl:if test="$MMS &gt; 0">
			<xsl:value-of
				select="format-number($MMS,'#.###MMS','espaniol')" />
			<xsl:value-of select="'; '" />
		</xsl:if>
		<xsl:if test="$KB &gt; 0">
			<xsl:value-of
				select="format-number($KB,'#.###KB','espaniol')" />
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>