<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html"/>
	
	<xsl:template match="/">
		<html>
			<xsl:apply-templates/>
		</html>
	</xsl:template>
	
	<xsl:template match="repository">
		<head>

			<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1"/>
			<title>
				<xsl:value-of select="@name"/>
			</title>
			<link href="http://www2.osgi.org/www/osgi.css" type="text/css" rel="stylesheet"/>
			
            <script type='text/javascript'>
            // <![CDATA[
                function toggle( /* String */ elementId )
                {
                    var element = document.getElementById( elementId );
                    if (element)
                    {
                        if (element.style.display == "none")
                        {
                            element.style.display = "inline";
                        }
                        else
                        {
                            element.style.display = "none";
                        }
                    }
                }
		    // ]]>
			</script>
		</head>
		<body>
			<h1>
				<xsl:value-of select="@name"/>
			</h1>
			
      		<p>Last modified 	
				<xsl:value-of select="@lastmodified"/>.</p>

            <h2><a href="javascript:toggle('referrals')" title="Click to toggle visibility of Referrals">Referrals</a></h2>
			<table id="referrals" width="100%">
				<tr><th>Hop Count</th><th>Link</th></tr>
				<xsl:apply-templates select="referral">
				</xsl:apply-templates>
			</table>

            <h2><a href="javascript:toggle('resources')" title="Click to toggle visibility of Referrals">Resources</a></h2>
			<table id="resources" width="100%">
				<tr><th>Link</th><th>Version</th><th>doc/src</th><th>Description</th><th>Bytes</th></tr>
				<xsl:apply-templates select="resource">

					<xsl:sort select="@presentationname"/>
				</xsl:apply-templates>
			</table>
		</body>
	</xsl:template>
	
	<xsl:template match="referral">
		<tr>
			<td><xsl:value-of select="@depth"/></td>
			<td>
				<a href="{@url}"><xsl:value-of select="@url"/></a>
			</td>
		</tr>

		
	</xsl:template>
	
	<xsl:template match="resource">
		<tr>
			<td nowrap="true">
				<a href="{@uri}"><xsl:value-of select="@presentationname"/></a>

				
			</td>
			<td><xsl:value-of select="@version"/></td>
			<td>
					<xsl:if test="documentation">
						<a href="{documentation}">D</a>
					</xsl:if>
					<xsl:if test="source">
						<a href="{source}">S</a>

					</xsl:if>
			</td>
			<td>
				<xsl:value-of select="description"/>
			</td>
			<td>
					<xsl:value-of select="size"/>
			</td>
		</tr>

		
	</xsl:template>
	
	<!--
	<xsl:template match="*">
	<tr>
	<td><xsl:value-of select="name()"/></td>
	<td><xsl:value-of select="."/></td>
	</tr>
	</xsl:template>
	-->
	<!--
	<xsl:template match="*">
	</xsl:template>
	-->
	
</xsl:stylesheet>

