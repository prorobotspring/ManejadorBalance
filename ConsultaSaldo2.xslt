<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
	xmlns:rtbs="http://comverse-in.com/prepaid/ccws">
	<!-- Version transformacion RTBS -->
	<xsl:output method="text" />
	<!-- CONSTANTS -->

	<xsl:variable name="coreBName" select="'Core'" />
	<xsl:variable name="textPlan" select="'. Plan '" />
	<xsl:variable name="puntoSeparador" select="'. '" />
	<xsl:variable name="punto" select="'.'" />
	<xsl:variable name="espacioSeparador" select="' '" />
	<xsl:variable name="textSaldo" select="'Bs.F.'" />
	<!-- <xsl:variable name="textFecha" select="' que bloquea el '" /> -->
	<xsl:variable name="textBonos" select="'y ademas Bs.F.'" />
	<xsl:variable name="textSeg412" select="'. Seg Dig:'" />
	<xsl:variable name="textSegTodas" select="'. Seg todas:'" />
	<xsl:variable name="textSegOtras" select="'. Seg otras:'" />
	<xsl:variable name="textMin412" select="'. Min Dig:'" />
	<xsl:variable name="textMinTodas" select="'. Min todas:'" />
	<xsl:variable name="textMinOtras" select="'. Min otras:'" />
	<xsl:variable name="textMMS" select="'. MMS:'" />
	<xsl:variable name="textMB" select="'. MB:'" />
	<xsl:variable name="textSMS" select="'. SMS:'" />

	<!-- EQUIVALENCIA DE ESTADO DE LINEA -->
	<xsl:variable name="idleStateRTBS" select="'Idle'" />
	<xsl:variable name="activeStateRTBS" select="'Active'" />
	<!-- <xsl:variable name="awaitStateRTBS" select="'Await Activation'" /> -->
	<!-- <xsl:variable name="await1StateRTBS" select="'Await 1 st Activation'" /> -->
	<xsl:variable name="suspendesS1StateRTBS" select="'Suspended(S1)'" />
	<xsl:variable name="stolenS2StateRTBS" select="'Stolen(S2)'" />
	<!-- <xsl:variable name="suspendesS3StateRTBS" select="'Suspended(S3)'" /> -->
	<!-- <xsl:variable name="suspendesS4StateRTBS" select="'Suspended(S4)'" /> -->
	<xsl:variable name="fraudLockoutStateRTBS" select="'Fraud Lockout'" />

	<xsl:variable name="idleStateGeneric" select="'Linea Pre-Activa'" />
	<xsl:variable name="activeStateGeneric" select="'Linea Activa'" />
	<!-- <xsl:variable name="awaitStateGeneric" select="''" /> -->
	<!-- <xsl:variable name="await1StateGeneric" select="''" /> -->
	<xsl:variable name="suspendesS1StateGeneric"
		select="'Linea Suspendida'" />
	<xsl:variable name="stolenS2StateGeneric"
		select="'Linea Suspendida'" />
	<!-- <xsl:variable name="suspendesS3StateGeneric" select="''" /> -->
	<!-- <xsl:variable name="suspendesS4StateGeneric" select="''" /> -->
	<xsl:variable name="fraudLockoutStateGeneric"
		select="'Linea Suspendida'" />

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
		<!-- ESTADO -->
		<xsl:variable name="ESTADO" select="rtbs:CurrentState" />

		<!-- SALDO -->
		<xsl:variable name="BS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName=$coreBName]/rtbs:Balance)" />

		<!-- BONO -->
		<xsl:variable name="BONO"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='F_BS']/rtbs:Balance)" />

		<!-- SEGUNDOS 412 -->
		<xsl:variable name="SEC_412"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_SEC_M2MF_ON-NET' or rtbs:BalanceName='F_SEC_M2MF_ON-NET']/rtbs:Balance)" />

		<!-- MINUTOS 412 -->
		<xsl:variable name="MIN_412" select="floor($SEC_412 div 60.0)" />

		<!-- SEGUNDOS OTRAS -->
		<xsl:variable name="SEC_OTRAS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_SEC_M2MF_OFF-NET' or rtbs:BalanceName='F_SEC_M2MF_OFF-NET']/rtbs:Balance)" />

		<!-- MINUTOS OTRAS -->
		<xsl:variable name="MIN_OTRAS"
			select="floor($SEC_OTRAS div 60.0)" />

		<!-- SEGUNDOS TODAS -->
		<xsl:variable name="SEC_TODAS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_SEC_M2MF_ON-OFF-NET' or rtbs:BalanceName='F_SEC_M2MF_ON-OFF-NET' or rtbs:BalanceName='NF_SEC_LDI']/rtbs:Balance)" />

		<!-- MINUTOS TODAS -->
		<xsl:variable name="MIN_TODAS"
			select="floor($SEC_TODAS div 60.0)" />

		<!-- MMS -->
		<xsl:variable name="MMS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_MMS' or
rtbs:BalanceName='F_MMS']/rtbs:Balance)" />

		<!-- MB -->
		<xsl:variable name="MB"
			select="(sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='F_KB' or rtbs:BalanceName='NF_KB']/rtbs:Balance)) div 1024" />

		<!-- SMS -->
		<xsl:variable name="SMS"
			select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_SMS' or
rtbs:BalanceName='NF_SMS_PREMIUM' or rtbs:BalanceName='F_SMS' or
rtbs:BalanceName='F_SMS_PREMIUM']/rtbs:Balance)" />

		<xsl:variable name="ExpiryDate"
			select="rtbs:Balances/rtbs:Balance[rtbs:BalanceName=$coreBName]/rtbs:AccountExpiration" />

		<!-- *************************************************************************************************** -->
		<!-- MENSAJE RETORNADO -->

		<xsl:value-of select="$textSaldo" />
		<xsl:value-of
			select="format-number($BS,'###.###.##0,00','espaniol')" />

		<!-- <xsl:if test="(substring($ExpiryDate,1,4) != '0001') and $BS != 0">
			<xsl:value-of select="$textFecha" />
			<xsl:variable name="day"
			select="substring($ExpiryDate,9,2)" />
			<xsl:variable name="month"
			select="substring($ExpiryDate,6,2)" />
			<xsl:variable name="year"
			select="substring($ExpiryDate,3,2)" />
			<xsl:value-of select="concat($day,'/',$month,'/',$year)" />
			</xsl:if> -->

		<!--<xsl:if test="$BONO = 0">
			<xsl:value-of select="$puntoSeparador" />
			</xsl:if> -->

		<!-- <xsl:if
			test="$BONO + $SEC_412 + $SEC_OTRAS + $SEC_TODAS + $MMS + $MB + $SMS &gt; 0">
			<xsl:value-of select="$espacioSeparador" />
			</xsl:if> -->

		<xsl:if test="$BONO &gt; 0">
			<xsl:value-of select="$espacioSeparador" />
			<xsl:value-of select="$textBonos" />
			<xsl:value-of
				select="format-number($BONO,'###.###.##0,00','espaniol')" />
			<!-- <xsl:value-of select="$puntoSeparador" />  -->
		</xsl:if>

		<xsl:choose>
			<xsl:when
				test="rtbs:COSName = 'Radicall Plus' or rtbs:COSName = 'Radicall Plus ZF' or rtbs:COSName = 'Rumba Movil' or rtbs:COSName = 'Rumba Movil ZF' or rtbs:COSName = 'Dia' or rtbs:COSName = 'Dia ZF' or rtbs:COSName = 'Radicall Regional' or rtbs:COSName = 'Microempresa Control' or rtbs:COSName = 'Microempresa Control ZF' or rtbs:COSName = 'Plus Control' or rtbs:COSName = 'Plus Control ZF' or rtbs:COSName = 'Super Control' or rtbs:COSName = 'Super Control ZF' or rtbs:COSName = 'Nexo 2' or rtbs:COSName = 'Nexo 2 ZF'">
				<xsl:if test="$SEC_412 &gt; 0">
					<xsl:value-of select="$textSeg412" />
					<xsl:value-of
						select="format-number($SEC_412,'####','espaniol')" />
				</xsl:if>
				<xsl:if test="$SEC_OTRAS &gt; 0">
					<xsl:value-of select="$textSegOtras" />
					<xsl:value-of
						select="format-number($SEC_OTRAS,'####','espaniol')" />
				</xsl:if>
				<xsl:if test="$SEC_TODAS &gt; 0">
					<xsl:value-of select="$textSegTodas" />
					<xsl:value-of
						select="format-number($SEC_TODAS,'####','espaniol')" />
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$MIN_412 >= 1">
					<xsl:value-of select="$textMin412" />
					<xsl:value-of
						select="format-number($MIN_412,'####','espaniol')" />
				</xsl:if>
				<xsl:if test="$MIN_OTRAS >= 1">
					<xsl:value-of select="$textMinOtras" />
					<xsl:value-of
						select="format-number($MIN_OTRAS,'####','espaniol')" />
				</xsl:if>

				<xsl:if test="$MIN_TODAS >= 1">
					<xsl:value-of select="$textMinTodas" />
					<xsl:value-of
						select="format-number($MIN_TODAS,'####','espaniol')" />
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="$SMS &gt; 0">
			<xsl:value-of select="$textSMS" />
			<xsl:value-of
				select="format-number($SMS,'####','espaniol')" />
		</xsl:if>

		<!-- <xsl:if test="$SMS &gt; 0 and $MB &gt; 0">
			<xsl:value-of select="$puntoSeparador" />
			</xsl:if>  -->

		<xsl:if test="$MB &gt; 0">
			<xsl:value-of select="$textMB" />
			<xsl:value-of
				select="format-number($MB,'########0,00','espaniol')" />
		</xsl:if>

		<!-- <xsl:if test="$MB &gt; 0 and $MMS &gt; 0">
			<xsl:value-of select="$puntoSeparador" />
			</xsl:if>  -->

		<xsl:if test="$MMS &gt; 0">
			<xsl:value-of select="$textMMS" />
			<xsl:value-of
				select="format-number($MMS,'####','espaniol')" />
		</xsl:if>

		<!-- <xsl:if
			test="$SEC_412 + $SEC_OTRAS + $SEC_TODAS + $MMS + $MB + $SMS &gt; 0">
			<xsl:value-of select="$puntoSeparador" />
			</xsl:if>  -->

		<xsl:value-of select="$puntoSeparador" />
		<xsl:choose>
			<xsl:when test="$ESTADO = $idleStateRTBS">
				<xsl:value-of select="$idleStateGeneric" />
				<!-- <xsl:value-of select="$puntoSeparador" /> -->
			</xsl:when>
			<xsl:when test="$ESTADO = $activeStateRTBS">
				<xsl:value-of select="$activeStateGeneric" />
				<!-- <xsl:value-of select="$puntoSeparador" /> -->
			</xsl:when>
			<xsl:when test="$ESTADO = $suspendesS1StateRTBS">
				<xsl:value-of select="$suspendesS1StateGeneric" />
				<!-- <xsl:value-of select="$puntoSeparador" /> -->
			</xsl:when>
			<xsl:when test="$ESTADO = $stolenS2StateRTBS">
				<xsl:value-of select="$stolenS2StateGeneric" />
				<!-- <xsl:value-of select="$puntoSeparador" /> -->
			</xsl:when>
			<xsl:when test="$ESTADO = $fraudLockoutStateRTBS">
				<xsl:value-of select="$fraudLockoutStateGeneric" />
				<!-- <xsl:value-of select="$puntoSeparador" /> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''" />
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$textPlan" />
		<xsl:choose>
			<xsl:when test="contains(rtbs:COSName,'ZF')">
				<xsl:value-of
					select="substring-before(rtbs:COSName,' ZF')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="rtbs:COSName" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
</xsl:stylesheet>