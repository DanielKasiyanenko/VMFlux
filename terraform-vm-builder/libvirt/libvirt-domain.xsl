<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>

    <!-- 1. Add SMM features -->
    <xsl:template match="/domain">
        <domain>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*"/>
            <xsl:if test="not(features)">
                <features>
                    <smm state='on'/>
                </features>
            </xsl:if>
        </domain>
    </xsl:template>

    <!-- 2. Force SCSI for all disks -->
    <xsl:template match="disk/target/@bus">
        <xsl:attribute name="bus">scsi</xsl:attribute>
    </xsl:template>

    <!-- 3. Remove IDE addresses -->
    <xsl:template match="disk[target/@bus='ide']/address"/>

    <!-- 4. Add virtio-scsi controller -->
    <xsl:template match="/domain/devices">
        <devices>
            <xsl:apply-templates/>
            <controller type="scsi" model="virtio-scsi" index="0">
                <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x0"/>
            </controller>
        </devices>
    </xsl:template>

    <!-- 5. Identity transform for other elements -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
