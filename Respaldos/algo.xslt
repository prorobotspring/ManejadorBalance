<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="1.0" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:rtbs="http://comverse-in.com/prepaid/ccws"
        xmlns:java="http://xml.apache.org/xslt/java"
    xmlns:cal="java.util.Calendar"
    xmlns:sf="java.text.SimpleDateFormat"
    exclude-result-prefixes="java">
        <!-- Version transformacion RTBS -->
        <xsl:output method="text" />
        <!-- CONSTANTS -->

        <xsl:variable name="coreBName" select="'Core'" />
        <xsl:variable name="textPlan" select="' Plan '" />
        <xsl:variable name="puntoSeparador" select="'. '" />
        <xsl:variable name="punto" select="'.'" />
        <xsl:variable name="espacioSeparador" select="' '" />
        <xsl:variable name="textSaldo" select="'BsF'" />
        <!-- <xsl:variable name="textFecha" select="' que bloquea el '" /> -->

        <xsl:variable name="textBonos" select="'mas BsF'" />
        <xsl:variable name="textSeg412" select="' Seg Dig:'" />
        <xsl:variable name="textSegTodas" select="' Seg Todas:'" />
        <xsl:variable name="textSegOtras" select="' Seg Otras:'" />
        <xsl:variable name="textMin412" select="' Min Dig:'" />
        <xsl:variable name="textMinTodas" select="' Min Todas:'" />
        <xsl:variable name="textMinOtras" select="' Min Otras:'" />
        <xsl:variable name="textMMS" select="' MMS:'" />
        <xsl:variable name="textMB" select="' MB:'" />
        <xsl:variable name="textSMS" select="' SMS:'" />

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

        <xsl:variable name="idleStateGeneric" select="'Pre-Activo'" />
        <xsl:variable name="activeStateGeneric" select="'Activo'" />
        <!-- <xsl:variable name="awaitStateGeneric" select="''" /> -->
        <!-- <xsl:variable name="await1StateGeneric" select="''" /> -->
        <xsl:variable name="suspendesS1StateGeneric"
                select="'Suspendido'" />
        <xsl:variable name="stolenS2StateGeneric"
                select="'Suspendido'" />
        <!-- <xsl:variable name="suspendesS3StateGeneric" select="''" /> -->
        <!-- <xsl:variable name="suspendesS4StateGeneric" select="''" /> -->
        <xsl:variable name="fraudLockoutStateGeneric" select="'Suspendido'" />

        <xsl:decimal-format name="espaniol" decimal-separator=","
                grouping-separator="." />

        <xsl:variable name="ProxCobroMensaj" select="'Prox Pago'" />
        <xsl:variable name="separadorMESdia" select="'-'" />




        <!-- MAIN -->
        <xsl:template match="/">
                <xsl:apply-templates
                        select="//rtbs:RetrieveSubscriberWithIdentityNoHistoryResult">
                </xsl:apply-templates>
        </xsl:template>

        <xsl:template
                match="rtbs:RetrieveSubscriberWithIdentityNoHistoryResult">
               
                <xsl:apply-templates select="rtbs:PeriodicCharges"></xsl:apply-templates>

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
                        select="sum(rtbs:Balances/rtbs:Balance[rtbs:BalanceName='NF_SEC_M2MF_ON-OFF-NET' or rtbs:BalanceName='F_SEC_M2MF_ON-OFF-NET' or rtbs:BalanceName='NF_SEC_LDI' or rtbs:BalanceName='F_SEC_F2MF_ON-OFF-NET' or rtbs:BalanceName='NF_SEC_F2MF_ON-OFF-NET']/rtbs:Balance)" />

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
                <xsl:value-of select="$espacioSeparador" />
                <xsl:value-of
                        select="format-number($BS,'########0,00','espaniol')" />
                <xsl:value-of select="$espacioSeparador" />

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
                        <xsl:value-of select="$espacioSeparador" />
                        <xsl:value-of
                                select="format-number($BONO,'########0,00','espaniol')" />
                        <!-- <xsl:value-of select="$puntoSeparador" />  -->
                </xsl:if>

                <xsl:choose>
                        <xsl:when
                                test="rtbs:COSName = 'Radicall Plus' or rtbs:COSName = 'Radicall Plus ZF' or rtbs:COSName = 'Rumba Movil' or rtbs:COSName = 'Rumba Movil ZF' or rtbs:COSName = 'Dia' or rtbs:COSName = 'Dia ZF'">
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

                <!-- <xsl:value-of select="$puntoSeparador" /> -->

                <xsl:value-of select="$textPlan" />
<!--            espacioSeparador
                <xsl:choose>
                        <xsl:when test="contains(rtbs:COSName,'ZF')">
                                <xsl:variable name="myNewString2"
                                        select="substring-before(rtbs:COSName,' ZF')" />
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:variable name="myNewString2"
                                        select="rtbs:COSName)" />
                        </xsl:otherwise>
                </xsl:choose>-->


                <xsl:choose>
                        <xsl:when test="contains(rtbs:COSName,'ZF')">
                                        <xsl:variable name="NewCosName">
            <xsl:call-template name="replaceCharsInString">
              <xsl:with-param name="stringIn" select="string(substring-before(rtbs:COSName,' ZF'))"/>
              <xsl:with-param name="charsIn" select="' '"/>
              <xsl:with-param name="charsOut" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$NewCosName" />
                        </xsl:when>
                        <xsl:otherwise>
        <xsl:variable name="NewCosName">
            <xsl:call-template name="replaceCharsInString">
              <xsl:with-param name="stringIn" select="string(rtbs:COSName)"/>
              <xsl:with-param name="charsIn" select="' '"/>
              <xsl:with-param name="charsOut" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$NewCosName" />
                        </xsl:otherwise>
        </xsl:choose>




        </xsl:template>


<xsl:template match="rtbs:PeriodicCharges">

<xsl:variable name="FIRST_CHARGE"
select="rtbs:PeriodicCharge[rtbs:PeriodicChargeID='RB A Tu Alcance 30'
or rtbs:PeriodicChargeID='RB A Tu Alcance 60'
or rtbs:PeriodicChargeID='RB Alcance 30 ZF'
or rtbs:PeriodicChargeID='RB Alcance 60 ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 1GB'
or rtbs:PeriodicChargeID='RB BAM 3G 1GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 2GB'
or rtbs:PeriodicChargeID='RB BAM 3G 2GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 3GB'
or rtbs:PeriodicChargeID='RB BAM 3G 3GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 5GB'
or rtbs:PeriodicChargeID='RB BAM 3G 5GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G Mega'
or rtbs:PeriodicChargeID='RB BAM 3G Mega ZF'
or rtbs:PeriodicChargeID='RB BAM 3G Super'
or rtbs:PeriodicChargeID='RB BAM 3G Super ZF'
or rtbs:PeriodicChargeID='RB BB Plan 50MB'
or rtbs:PeriodicChargeID='RB BB Plan 50MBZF'
or rtbs:PeriodicChargeID='RB BB Plan Ilim'
or rtbs:PeriodicChargeID='RB BB Plan IlimZF'
or rtbs:PeriodicChargeID='RB BB Plan Social'
or rtbs:PeriodicChargeID='RB BB Plan SocialZF'
or rtbs:PeriodicChargeID='RB Cobertura'
or rtbs:PeriodicChargeID='RB Cobertura ZF'
or rtbs:PeriodicChargeID='RB Dia'
or rtbs:PeriodicChargeID='RB Dia ZF'
or rtbs:PeriodicChargeID='RB Gremial'
or rtbs:PeriodicChargeID='RB Gremial ZF'
or rtbs:PeriodicChargeID='RB Habla Sin Parar'
or rtbs:PeriodicChargeID='RB Habla Sin PararZF'
or rtbs:PeriodicChargeID='RB Hogar 412 Plus'
or rtbs:PeriodicChargeID='RB Hogar 412 Plus ZF'
or rtbs:PeriodicChargeID='RB Nexo 2'
or rtbs:PeriodicChargeID='RB Nexo 2 ZF'
or rtbs:PeriodicChargeID='RB Rumba Movil'
or rtbs:PeriodicChargeID='RB Rumba Movil ZF'
or rtbs:PeriodicChargeID='RB SP Ilimitado'
or rtbs:PeriodicChargeID='RB SP Ilimitado ZF'
or rtbs:PeriodicChargeID='RB SP1200'
or rtbs:PeriodicChargeID='RB SP1200 ZF'
or rtbs:PeriodicChargeID='RB SP200'
or rtbs:PeriodicChargeID='RB SP200 ZF'
or rtbs:PeriodicChargeID='RB SP400'
or rtbs:PeriodicChargeID='RB SP400 ZF'
or rtbs:PeriodicChargeID='RB SP600'
or rtbs:PeriodicChargeID='RB SP600 ZF'
or rtbs:PeriodicChargeID='RB SP100'
or rtbs:PeriodicChargeID='RB SP100 ZF'
or rtbs:PeriodicChargeID='RB SP3000'
or rtbs:PeriodicChargeID='RB SP3000 ZF']/rtbs:FirstChargeApplied"/>

<xsl:variable name="APPLAYday"
select="rtbs:PeriodicCharge[rtbs:PeriodicChargeID='RB A Tu Alcance 30'
or rtbs:PeriodicChargeID='RB A Tu Alcance 60'
or rtbs:PeriodicChargeID='RB Alcance 30 ZF'
or rtbs:PeriodicChargeID='RB Alcance 60 ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 1GB'
or rtbs:PeriodicChargeID='RB BAM 3G 1GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 2GB'
or rtbs:PeriodicChargeID='RB BAM 3G 2GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 3GB'
or rtbs:PeriodicChargeID='RB BAM 3G 3GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 5GB'
or rtbs:PeriodicChargeID='RB BAM 3G 5GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G Mega'
or rtbs:PeriodicChargeID='RB BAM 3G Mega ZF'
or rtbs:PeriodicChargeID='RB BAM 3G Super'
or rtbs:PeriodicChargeID='RB BAM 3G Super ZF'
or rtbs:PeriodicChargeID='RB BB Plan 50MB'
or rtbs:PeriodicChargeID='RB BB Plan 50MBZF'
or rtbs:PeriodicChargeID='RB BB Plan Ilim'
or rtbs:PeriodicChargeID='RB BB Plan IlimZF'
or rtbs:PeriodicChargeID='RB BB Plan Social'
or rtbs:PeriodicChargeID='RB BB Plan SocialZF'
or rtbs:PeriodicChargeID='RB Cobertura'
or rtbs:PeriodicChargeID='RB Cobertura ZF'
or rtbs:PeriodicChargeID='RB Dia'
or rtbs:PeriodicChargeID='RB Dia ZF'
or rtbs:PeriodicChargeID='RB Gremial'
or rtbs:PeriodicChargeID='RB Gremial ZF'
or rtbs:PeriodicChargeID='RB Habla Sin Parar'
or rtbs:PeriodicChargeID='RB Habla Sin PararZF'
or rtbs:PeriodicChargeID='RB Hogar 412 Plus'
or rtbs:PeriodicChargeID='RB Hogar 412 Plus ZF'
or rtbs:PeriodicChargeID='RB Nexo 2'
or rtbs:PeriodicChargeID='RB Nexo 2 ZF'
or rtbs:PeriodicChargeID='RB Rumba Movil'
or rtbs:PeriodicChargeID='RB Rumba Movil ZF'
or rtbs:PeriodicChargeID='RB SP Ilimitado'
or rtbs:PeriodicChargeID='RB SP Ilimitado ZF'
or rtbs:PeriodicChargeID='RB SP1200'
or rtbs:PeriodicChargeID='RB SP1200 ZF'
or rtbs:PeriodicChargeID='RB SP200'
or rtbs:PeriodicChargeID='RB SP200 ZF'
or rtbs:PeriodicChargeID='RB SP400'
or rtbs:PeriodicChargeID='RB SP400 ZF'
or rtbs:PeriodicChargeID='RB SP600'
or rtbs:PeriodicChargeID='RB SP600 ZF'
or rtbs:PeriodicChargeID='RB SP100'
or rtbs:PeriodicChargeID='RB SP100 ZF'
or rtbs:PeriodicChargeID='RB SP3000'
or rtbs:PeriodicChargeID='RB SP3000 ZF']/rtbs:ApplyDay"/>

<xsl:variable name="startDATE"
select="rtbs:PeriodicCharge[rtbs:PeriodicChargeID='RB A Tu Alcance 30'
or rtbs:PeriodicChargeID='RB A Tu Alcance 60'
or rtbs:PeriodicChargeID='RB Alcance 30 ZF'
or rtbs:PeriodicChargeID='RB Alcance 60 ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 1GB'
or rtbs:PeriodicChargeID='RB BAM 3G 1GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 2GB'
or rtbs:PeriodicChargeID='RB BAM 3G 2GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 3GB'
or rtbs:PeriodicChargeID='RB BAM 3G 3GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G 5GB'
or rtbs:PeriodicChargeID='RB BAM 3G 5GB ZF'
or rtbs:PeriodicChargeID='RB BAM 3G Mega'
or rtbs:PeriodicChargeID='RB BAM 3G Mega ZF'
or rtbs:PeriodicChargeID='RB BAM 3G Super'
or rtbs:PeriodicChargeID='RB BAM 3G Super ZF'
or rtbs:PeriodicChargeID='RB BB Plan 50MB'
or rtbs:PeriodicChargeID='RB BB Plan 50MBZF'
or rtbs:PeriodicChargeID='RB BB Plan Ilim'
or rtbs:PeriodicChargeID='RB BB Plan IlimZF'
or rtbs:PeriodicChargeID='RB BB Plan Social'
or rtbs:PeriodicChargeID='RB BB Plan SocialZF'
or rtbs:PeriodicChargeID='RB Cobertura'
or rtbs:PeriodicChargeID='RB Cobertura ZF'
or rtbs:PeriodicChargeID='RB Dia'
or rtbs:PeriodicChargeID='RB Dia ZF'
or rtbs:PeriodicChargeID='RB Gremial'
or rtbs:PeriodicChargeID='RB Gremial ZF'
or rtbs:PeriodicChargeID='RB Habla Sin Parar'
or rtbs:PeriodicChargeID='RB Habla Sin PararZF'
or rtbs:PeriodicChargeID='RB Hogar 412 Plus'
or rtbs:PeriodicChargeID='RB Hogar 412 Plus ZF'
or rtbs:PeriodicChargeID='RB Nexo 2'
or rtbs:PeriodicChargeID='RB Nexo 2 ZF'
or rtbs:PeriodicChargeID='RB Rumba Movil'
or rtbs:PeriodicChargeID='RB Rumba Movil ZF'
or rtbs:PeriodicChargeID='RB SP Ilimitado'
or rtbs:PeriodicChargeID='RB SP Ilimitado ZF'
or rtbs:PeriodicChargeID='RB SP1200'
or rtbs:PeriodicChargeID='RB SP1200 ZF'
or rtbs:PeriodicChargeID='RB SP200'
or rtbs:PeriodicChargeID='RB SP200 ZF'
or rtbs:PeriodicChargeID='RB SP400'
or rtbs:PeriodicChargeID='RB SP400 ZF'
or rtbs:PeriodicChargeID='RB SP600'
or rtbs:PeriodicChargeID='RB SP600 ZF'
or rtbs:PeriodicChargeID='RB SP100'
or rtbs:PeriodicChargeID='RB SP100 ZF'
or rtbs:PeriodicChargeID='RB SP3000'
or rtbs:PeriodicChargeID='RB SP3000 ZF']/rtbs:StartDate"/>





        <xsl:variable name="TODAYday" select="java:format(java:java.text.SimpleDateFormat.new('dd'), java:java.util.Date.new())" />
        <xsl:variable name="TODAYmonth" select="java:format(java:java.text.SimpleDateFormat.new('MM'), java:java.util.Date.new())" />
        <xsl:variable name="TODAYyear" select="java:format(java:java.text.SimpleDateFormat.new('yyyy'), java:java.util.Date.new())" />
                                        <!---PARA REALIZAR LA PRUBEAS MANIPULANDO EL DIA, COMENTAR LAS LINEAS DE ARRIBA
                                        <xsl:variable name="TODAYday" select="30" />
                                        <xsl:variable name="TODAYmonth" select="03" />
                                        <xsl:variable name="TODAYyear" select="2011" />
                                        <xsl:variable name="CHARGE_DATE" select='translate ( substring-before($DATE_CHARGE,"T"), "-", "")'/>                  
                                        <xsl:value-of select="$CHARGE_DATE"/>
                                        <xsl:value-of select="'Max day of month '"/> <xsl:value-of select="$TODAYmonth+1"/>
                                        <xsl:value-of select="'valor de primer cargo '"/> <xsl:value-of select="$FIRST_CHARGE"/>
                                        <xsl:value-of select="'Max day of month '"/> <xsl:value-of select="substring('312831303130313130313031', (2 * ($TODAYmonth+1))-1,2)"/>  -->

                                                <xsl:if  test="(($FIRST_CHARGE = 'true')or ($FIRST_CHARGE = 'false'))">
                                                <xsl:value-of select="$espacioSeparador" />
                        <xsl:value-of select="$ProxCobroMensaj"/>
                        <xsl:value-of select="$espacioSeparador" />
                                                </xsl:if>



        <xsl:variable name="lastDAYmonth">
            <xsl:call-template name="f_lastdaymonth">
              <xsl:with-param name="v_month" select="$TODAYmonth"/>
              <xsl:with-param name="v_year" select="$TODAYyear"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="lastDAYnextmonth">
            <xsl:call-template name="f_lastdaymonth">
              <xsl:with-param name="v_month" select="$TODAYmonth+1"/>
              <xsl:with-param name="v_year" select="$TODAYyear"/>
            </xsl:call-template>
        </xsl:variable>


<xsl:choose>
<xsl:when test="$FIRST_CHARGE = 'true'">

        <xsl:variable name="nextAPPLYday">
        <xsl:call-template name="f_nextAPPLYday">
              <xsl:with-param name="todayMONTH" select="$TODAYmonth"/>
              <xsl:with-param name="todayYEAR" select="$TODAYyear"/>
              <xsl:with-param name="applyday" select="$APPLAYday"/>
              <xsl:with-param name="todayDAY" select="$TODAYday"/>
              <xsl:with-param name="lastDAYmonth" select="$lastDAYmonth"/>
              <xsl:with-param name="lastDAYnextMONTH" select="$lastDAYnextmonth"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="$nextAPPLYday" />
</xsl:when>
<xsl:otherwise>
                                <xsl:if test="( $FIRST_CHARGE = 'false' ) ">
                                <xsl:variable name="FIRSTCHARGEdate" select="substring-before($startDATE, 'T')" />
                                <xsl:variable name="FIRSTCHARGEmonth" select="substring-before(substring-after($FIRSTCHARGEdate, '-'), '-')" />
                                <xsl:variable name="FIRSTCHARGEday" select="substring-after(substring-after($FIRSTCHARGEdate, '-'), '-')" />
                                                <xsl:value-of   select="format-number($FIRSTCHARGEday,'00','espaniol')" />
                                                <xsl:value-of select="$separadorMESdia" />
                                                <xsl:value-of   select="format-number($FIRSTCHARGEmonth,'00','espaniol')" />
                                </xsl:if>
</xsl:otherwise>
                                </xsl:choose>
        </xsl:template>









<xsl:template name="replaceCharsInString">
  <xsl:param name="stringIn"/>
  <xsl:param name="charsIn"/>
  <xsl:param name="charsOut"/>
  <xsl:choose>
    <xsl:when test="contains($stringIn,$charsIn)">
      <xsl:value-of select="concat(substring-before($stringIn,$charsIn),$charsOut)"/>
      <xsl:call-template name="replaceCharsInString">
        <xsl:with-param name="stringIn" select="substring-after($stringIn,$charsIn)"/>
        <xsl:with-param name="charsIn" select="$charsIn"/>
        <xsl:with-param name="charsOut" select="$charsOut"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$stringIn"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>





<xsl:template name="f_lastdaymonth">
  <xsl:param name="v_month"/>
  <xsl:param name="v_year"/>
  <xsl:choose>
    <xsl:when test="$v_month=2 and not ($v_year mod 4) and ($v_year mod 100 or not ($v_year mod 400))">
    <xsl:value-of select="29"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="substring('31283130313031313031303131', (2 *($v_month))-1,2)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>





<xsl:template name="f_nextAPPLYday">
  <xsl:param name="todayDAY"/>
  <xsl:param name="todayMONTH"/>
  <xsl:param name="todayYEAR"/>
  <xsl:param name="applyday"/>
  <xsl:param name="lastDAYmonth"/>
  <xsl:param name="lastDAYnextMONTH"/>
  <xsl:choose>
    <xsl:when test="(($todayMONTH+1 &lt; 13) or ( $todayMONTH+1 = 13 and $todayDAY &lt; $applyday ))">
     <!--
    <xsl:value-of select="'@'" />
    <xsl:value-of select="'todayDAY'" />
    <xsl:value-of select="$todayDAY" />
  <xsl:value-of select="'-'" />
  <xsl:value-of select="'todayMONTH'" />
   <xsl:value-of select="$todayMONTH" />
  <xsl:value-of select="'-'" />
  <xsl:value-of select="$todayYEAR" />
  <xsl:value-of select="'-'" />
  <xsl:value-of select="$applyday" />
  <xsl:value-of select="'-'" />
  <xsl:value-of select="$lastDAYmonth" />
  <xsl:value-of select="'-'" />
  <xsl:value-of select="$lastDAYnextMONTH" />
   <xsl:value-of select="'@'" />
   -->

    <xsl:if test="(((($lastDAYmonth &lt;= $applyday) and ($todayDAY =$lastDAYmonth)) or ($applyday &lt;= $todayDAY)) and ($lastDAYnextMONTH &gt;= $applyday))" >
         <xsl:value-of  select="format-number($applyday,'00','espaniol')" />
         <xsl:value-of select="$separadorMESdia" />
         <xsl:value-of  select="format-number($todayMONTH+1,'00','espaniol')" />
    </xsl:if>
    <xsl:if test="(((($lastDAYmonth &lt;= $applyday) and ($todayDAY =$lastDAYmonth)) or ($applyday &lt;= $todayDAY)) and ($lastDAYnextMONTH &lt; $applyday))" >
         <xsl:value-of  select="format-number($lastDAYnextMONTH,'00','espaniol')" />
         <xsl:value-of select="$separadorMESdia" />
         <xsl:value-of  select="format-number($todayMONTH+1,'00','espaniol')" />
    </xsl:if>
    <xsl:if test="((($applyday &gt; $todayDAY)  and ($lastDAYmonth &gt; $todayDAY)) and ($lastDAYmonth &gt;= $applyday))     " >
         <xsl:value-of  select="format-number($applyday,'00','espaniol')" />
         <xsl:value-of select="$separadorMESdia" />
         <xsl:value-of  select="format-number($todayMONTH,'00','espaniol')" />
    </xsl:if>
    <xsl:if test="((($applyday &gt; $todayDAY)  and ($lastDAYmonth &gt; $todayDAY)) and ($lastDAYmonth &lt; $applyday))      " >
         <xsl:value-of  select="format-number($lastDAYmonth,'00','espaniol')" />
         <xsl:value-of select="$separadorMESdia" />
         <xsl:value-of  select="format-number($todayMONTH,'00','espaniol')" />
    </xsl:if>
    </xsl:when>
    <xsl:otherwise>
         <xsl:value-of  select="format-number($applyday,'00','espaniol')" />
         <xsl:value-of select="$separadorMESdia" />
         <xsl:value-of  select="format-number(1,'00','espaniol')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>













</xsl:stylesheet>

