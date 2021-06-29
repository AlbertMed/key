DECLARE @fecha DATETIME = GETDATE()
                        DECLARE @rango INT = '7'
                        DECLARE @monedaDolar UNIQUEIDENTIFIER = '1EA50C6D-AD92-4DE6-A562-F155D0D516D3'
			DECLARE @monedaPeso UNIQUEIDENTIFIER = '748BE9C9-B56D-4FD2-A77F-EE4C6CD226A1'
                        DECLARE @Decimales Decimal
                        SET @Decimales = ( SELECT CMA_Valor FROM ControlesMaestros WHERE CMA_Control LIKE 'CMA_VEN_DecimalesCantidades')
                        SELECT
                            FP_FacturaProveedorId AS DT_RowId
                            ,0 AS CHECK_BOX
                            ,SUM(montoOriginal)OVER(PARTITION BY PRO_ProveedorId) AS MONTOORIGINALPROVEEDOR,
                            SUM(montoActual)OVER(PARTITION BY PRO_ProveedorId) AS MONTOACTUALPORPROVEEDOR,
                            SUM(montoOriginal)OVER(PARTITION BY MON_MonedaId) AS MONTOORIGINALPROVEEDORMO,
                            SUM(montoActual)OVER(PARTITION BY MON_MonedaId) AS MONTOACTUALPORPROVEEDORMO,
                            CASE WHEN DATEDIFF(DAY, FECHA_VENCIMIENTO ,@fecha) < 1 THEN montoActual END SALDO_SV,
                          
						  
							(SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO)) AS SEMANA,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							<  (SUBSTRING( CAST(year(GETDATE()) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, GETDATE())) 
							THEN montoActual END S0,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							=  (SUBSTRING( CAST(year(GETDATE()) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, GETDATE())) 
							THEN montoActual END S1,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							=  (SUBSTRING( CAST(year(DATEADD(week, 1,  GETDATE())) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, DATEADD(week, 1,  GETDATE()))) 
							THEN montoActual END S2,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							=  (SUBSTRING( CAST(year(DATEADD(week, 2,  GETDATE())) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, DATEADD(week, 2,  GETDATE()))) 
							THEN montoActual END S3,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							=  (SUBSTRING( CAST(year(DATEADD(week, 3,  GETDATE())) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, DATEADD(week, 3,  GETDATE()))) 
							THEN montoActual END S4,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							=  (SUBSTRING( CAST(year(DATEADD(week, 4,  GETDATE())) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, DATEADD(week, 4,  GETDATE()))) 
							THEN montoActual END S5,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							=  (SUBSTRING( CAST(year(DATEADD(week, 5,  GETDATE())) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, DATEADD(week, 5,  GETDATE()))) 
							THEN montoActual END S6,
							CASE WHEN (SUBSTRING( CAST(year(FECHA_VENCIMIENTO) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, FECHA_VENCIMIENTO))
							>  (SUBSTRING( CAST(year(DATEADD(week, 5,  GETDATE())) as nvarchar(5)), 3, 2) * 100 + DATEPART(ISO_WEEK, DATEADD(week, 5,  GETDATE()))) 
							THEN montoActual END S7,
                            *
                        FROM(
                            SELECT
                                MON_MonedaId,
                                MON_Nombre,
								MONP_TipoCambioOficial,
                                FP_CodigoFactura,
                                PROVEEDOR,
                                PRO_ProveedorId,
                                FP_FacturaProveedorId,
                                FORMAT (FP_FechaFactura, 'dd/MM/yyyy ') FP_FechaFactura,
                                FORMAT (FECHA_VENCIMIENTO, 'dd/MM/yyyy ') FECHA_VENCIMIENTO,

                                case when
                                    cast(ROUND ( CASE WHEN SUM((ROUND(SubTotal, CONVERT(int, @Decimales)) - ROUND(Descuento, CONVERT(int, @Decimales))) + ROUND(IVA, Convert( int, @Decimales))) -
                                       SUM(ROUND((SubTotal-Descuento)* FTRT_PorcentajeRetencion , CONVERT(int, @Decimales))) - ROUND( SaldoAFavor, @Decimales) <= 0.05 THEN 0.0
                                    ELSE
                                    SUM((ROUND(SubTotal, CONVERT(int, @Decimales)) - ROUND(Descuento, CONVERT(int, @Decimales))) + ROUND(IVA, Convert( int, @Decimales))) -
                                       SUM(ROUND((SubTotal-Descuento)* FTRT_PorcentajeRetencion , CONVERT(int, @Decimales))) - ROUND( SaldoAFavor, @Decimales)  END ,@DECIMALES) as DECIMAL(28, 2)) <= 0.0
                                    THEN 0
                                ELSE
                                    cast(ROUND (  DiasTranscurridosVencimiento ,@DECIMALES) as DECIMAL(28, 0)) end AS DiasTranscurridosVencimiento,

                                CONVERT(FLOAT, cast(ROUND ( SUM((ROUND(SubTotal, CONVERT(int, @Decimales)) - ROUND(Descuento, CONVERT(int, @Decimales))) + ROUND(IVA, Convert( int, @Decimales))) -
                                    SUM(ROUND((SubTotal-Descuento)* FTRT_PorcentajeRetencion , CONVERT(int, @Decimales))) ,@DECIMALES) as DECIMAL(28, 2)) , 101) - SUM((FP_RetencionIVA + FP_RetencionISR)) AS montoOriginal,
                                CONVERT(FLOAT,

                                cast(ROUND ( CASE WHEN SUM((ROUND(SubTotal, CONVERT(int, @Decimales)) - ROUND(Descuento, CONVERT(int, @Decimales))) + ROUND(IVA, Convert( int, @Decimales))) -
                                 SUM(ROUND((SubTotal-Descuento)* FTRT_PorcentajeRetencion , CONVERT(int, @Decimales))) - ROUND( SaldoAFavor, @Decimales) <= 0.05 THEN 0.0
                                 ELSE
                         SUM((ROUND(SubTotal, CONVERT(int, @Decimales)) - ROUND(Descuento, CONVERT(int, @Decimales))) + ROUND(IVA, Convert( int, @Decimales))) -
                                 SUM(ROUND((SubTotal-Descuento)* FTRT_PorcentajeRetencion , CONVERT(int, @Decimales))) - ROUND( SaldoAFavor, @Decimales)  END ,@DECIMALES) as DECIMAL(28, 2)) , 101) - SUM((FP_RetencionIVA + FP_RetencionISR)) AS montoActual
                               ,(CONVERT(FLOAT,

                                cast(ROUND ( CASE WHEN SUM((ROUND(SubTotal, CONVERT(int, @Decimales)) - ROUND(Descuento, CONVERT(int, @Decimales))) + ROUND(IVA, Convert( int, @Decimales))) -
                                 SUM(ROUND((SubTotal-Descuento)* FTRT_PorcentajeRetencion , CONVERT(int, @Decimales))) - ROUND( SaldoAFavor, @Decimales) <= 0.05 THEN 0.0
                                 ELSE
                         SUM((ROUND(SubTotal, CONVERT(int, @Decimales)) - ROUND(Descuento, CONVERT(int, @Decimales))) + ROUND(IVA, Convert( int, @Decimales))) -
                                 SUM(ROUND((SubTotal-Descuento)* FTRT_PorcentajeRetencion , CONVERT(int, @Decimales))) - ROUND( SaldoAFavor, @Decimales)  END ,@DECIMALES) as DECIMAL(28, 2)) , 101) - SUM((FP_RetencionIVA + FP_RetencionISR))) * MONP_TipoCambioOficial AS montoActualPesos
               
                         FROM (
                                 SELECT
                                 MON_MonedaId,
                                 MON_Nombre,
								 MONP_TipoCambioOficial,
                                        FP_FacturaProveedorId,
                                        FP_FechaFactura,
                                        ( FP_FechaFactura + TEP_DiasVencimiento ) AS FECHA_VENCIMIENTO,
                                        PRO_Nombre ,
                                        PRO_CodigoProveedor +' - ' + PRO_Nombre as proveedor,
                                        PRO_RFC,
                                        PRO_NombreComercial,
                                        PRO_Domicilio+', '+CIUC_Nombre+ ', '+CIU_Nombre+', '+EST_Nombre+', '+PAI_Nombre  as PRO_Domicilio,
                                        PRO_Telefono + ', CP: '+ PRO_CodigoPostal as TEL_CP,
                                         ISNULL( FTRT_PorcentajeRetencion , 0.0) AS FTRT_PorcentajeRetencion ,
                                         PRO_ProveedorId,
                                         PRO_CodigoProveedor ,
                                         ISNULL( CantidadPagoFactura, 0.0) AS SaldoAFavor,
                                         UPPER( TEP_TerminoPago ) AS TEP_TerminoPago ,
                                           CASE WHEN DATEDIFF(DAY, FP_FechaFactura ,@fecha) <= TEP_DiasVencimiento THEN 'Actual' ELSE 'Vencido' END AS EstadoFactura,
                                               CASE WHEN DATEDIFF( DAY, ( FP_FechaFactura + TEP_DiasVencimiento ), @fecha) > 0 THEN
                                               DATEDIFF( DAY, ( FP_FechaFactura + TEP_DiasVencimiento ), @fecha) ELSE 0 END AS DiasTranscurridosVencimiento,
                                          FPD_CMM_TipoVariacion,
                                         FP_CodigoFactura,
                                         FPD_OC_OrdenCompraId,
                                          FP_RetencionIVA,
                                         FP_RetencionISR,
                                         FPD_CantidadReal * FPD_PrecioUnitarioReal AS SubTotal,
                                         ((FPD_CantidadReal * FPD_PrecioUnitarioReal) * (ISNULL( FPD_PorcentajeDescuento , 0.0)/100)) AS Descuento,
                                         (((FPD_CantidadReal * FPD_PrecioUnitarioReal) -
                                         ((FPD_CantidadReal * FPD_PrecioUnitarioReal) * (ISNULL( FPD_PorcentajeDescuento , 0.0)/100))) * ISNULL( FPD_CMIVA_Porcentaje , 0.0)) AS IVA
                                         FROM(
                                         SELECT
                                        MON_MonedaId,
                                         MON_Nombre,
										 MONP_TipoCambioOficial,
                                        FP_FacturaProveedorId,
                                        PRO_Nombre,
                                        PRO_CodigoProveedor,
                                        PRO_RFC,
                                        PRO_NombreComercial,
                                        PRO_Domicilio,
                                        CIUC_Nombre,
                                        CIU_Nombre,
                                        EST_Nombre,
                                        PAI_Nombre,
                                        PRO_Telefono,
                                        PRO_CodigoPostal,
                                         PRO_ProveedorId,
                                         CantidadPagoFactura,
                                         TEP_TerminoPago ,
                                         FP_FechaFactura,
                                         TEP_DiasVencimiento,
                                         FTRT_PorcentajeRetencion,
                                         FPD_PorcentajeDescuento,
                                         FPD_CMIVA_Porcentaje,
                                          FP_RetencionIVA,
                                         FP_RetencionISR,
                                         FPD_CMM_TipoVariacion,
                                         FP_CodigoFactura,
                                         FPD_OC_OrdenCompraId,
                                         SUM(ISNULL(FPD_CantidadNormal, 0) + ISNULL(FPD_CantidadVariacion, 0)) OVER(PARTITION BY FPD_OC_OrdenCompraId, FP_FacturaProveedorId) AS FPD_CantidadReal,
                                         SUM(ISNULL(FPD_PrecioUnitarioNormal, 0) + ISNULL(FPD_PrecioUnitarioVariacion, 0)) OVER(PARTITION BY FPD_OC_OrdenCompraId, FP_FacturaProveedorId) AS FPD_PrecioUnitarioReal
                                         FROM(
                                         SELECT
                                         MON_MonedaId,
                                         MON_Nombre,
										 MonedasParidad.MONP_TipoCambioOficial,
                                        FP_FacturaProveedorId,
                                        PRO_Nombre,
                                        PRO_RFC,
                                        PRO_NombreComercial,
                                        PRO_Domicilio,
                                        CIUC_Nombre,
                                        CIU_Nombre,
                                        EST_Nombre,
                                        PAI_Nombre,
                                        PRO_Telefono,
                                        PRO_CodigoPostal,
                                         PRO_ProveedorId,
                                         PRO_CodigoProveedor ,
                                         CantidadPagoFactura,
                                         TEP_TerminoPago ,
                                         FP_FechaFactura,
                                         TEP_DiasVencimiento,
                                          FTRT_PorcentajeRetencion,
                                         FPD_PorcentajeDescuento,
                                         FPD_CMIVA_Porcentaje,
                                         ISNULL(FP_RetencionIVA, 0) AS FP_RetencionIVA,
                                         ISNULL(FP_RetencionISR, 0) AS FP_RetencionISR,
                                         ISNULL(FPD_CMM_TipoVariacion, 'F3988783-D778-4924-A080-4C14222ECAFE') FPD_CMM_TipoVariacion,
                                         FPD_DetalleId,
                                         FP_CodigoFactura,
                                         FPD_OC_OrdenCompraId,
                                  CASE WHEN FPD_CMM_TipoVariacion = 'F3988783-D778-4924-A080-4C14222ECAFE' OR FPD_CMM_TipoVariacion IS NULL
                                THEN FPD_PrecioUnitario END AS FPD_PrecioUnitarioNormal,
                                CASE WHEN FPD_CMM_TipoVariacion = 'BC290E69-ACA5-4EEB-86B4-966DA70A77AB'
                                  OR FPD_CMM_TipoVariacion = 'F5638AF6-4575-4B52-B7A2-F7287E0BE44A'
                                THEN FPD_PrecioUnitario END AS FPD_PrecioUnitarioVariacion,
                                CASE WHEN FPD_CMM_TipoVariacion = 'F3988783-D778-4924-A080-4C14222ECAFE' OR FPD_CMM_TipoVariacion IS NULL
                                THEN FPD_Cantidad END AS FPD_CantidadNormal,
                                CASE WHEN FPD_CMM_TipoVariacion = '1205725E-0C40-4D2A-BC54-F2345DFDCB0D'
                                  OR FPD_CMM_TipoVariacion = 'F5638AF6-4575-4B52-B7A2-F7287E0BE44A'
                                THEN FPD_Cantidad END AS FPD_CantidadVariacion
                                         FROM FacturasProveedores
                          INNER JOIN FacturasProveedoresDetalle ON FP_FacturaProveedorId = FPD_FP_FacturaProveedorId
                          LEFT  JOIN ( SELECT
                                                                   FTRT_FTR_FacturaId ,
                                                                   SUM( FTRT_PorcentajeRetencion ) AS FTRT_PorcentajeRetencion
                                              FROM FacturasRetenciones
                                              GROUP BY
                                                       FTRT_FTR_FacturaId
                                            ) AS FacturasRetenciones ON FP_FacturaProveedorId = FTRT_FTR_FacturaId
                                 INNER JOIN Monedas ON FP_MON_MonedaId = MON_MonedaId
								 
								 LEFT JOIN TerminosPago ON FP_TEP_TerminoPagoId = TEP_TerminoPagoId
                        LEFT JOIN Proveedores on PRO_ProveedorId = FP_PRO_ProveedorId
                        left join Ciudades on PRO_CIU_CiudadId=CIU_CiudadId
                        left JOIN Estados on PRO_EST_EstadoId=EST_EstadoId
                        left JOIN Paises on PRO_PAI_PaisId=PAI_PaisId
                        left join CiudadesColonias on PRO_CIUC_ColoniaId = CIUC_ColoniaId
                                 LEFT  JOIN (
                                               SELECT
                                                      CXPPD_FP_FacturaProveedorId ,
                                                       ROUND( ISNULL( SUM( ABS(CXPPD_MontoAplicado )), 0.0), 2) AS cantidadPagoFactura,
                                                      CXPP_MON_MonedaId ,
                                                      CXPP_PRO_ProveedorId
                                               FROM CXPPagos
                                               INNER JOIN CXPPagosDetalle ON CXPP_CXPPagoId = CXPPD_CXPP_CXPPagoId
                                               WHERE CXPP_Eliminado = 0
                                               GROUP BY
                                                        CXPPD_FP_FacturaProveedorId ,
                                                        CXPP_MON_MonedaId ,
                                                        CXPP_PRO_ProveedorId
                                            ) AS Pagos ON FP_FacturaProveedorId = CXPPD_FP_FacturaProveedorId AND
                                                          FP_MON_MonedaId = CXPP_MON_MonedaId
                                                          WHERE FP_Eliminado = 0
                                                                 AND @fecha + ' 23:59:59' >= FP_FechaFactura
                                                                 ) AS CARCULARPARTIDASVARIACIONES
                              GROUP BY
                               FP_FacturaProveedorId,
                                        FP_FechaFactura,
                                        PRO_Nombre,
                                        PRO_CodigoProveedor,
                                        PRO_RFC,
                                        PRO_NombreComercial,
                                        PRO_Domicilio,
                                        CIUC_Nombre,
                                        CIU_Nombre,
                                        EST_Nombre,
                                        PAI_Nombre,
                                        PRO_Telefono,
                                        MON_MonedaId,
                                         MON_Nombre,
										 MONP_TipoCambioOficial,
                                         PRO_CodigoPostal,
                                         PRO_ProveedorId,
                                         CantidadPagoFactura,
                                         TEP_TerminoPago,
                                         TEP_DiasVencimiento,
                                         FTRT_PorcentajeRetencion,
                                         FPD_PorcentajeDescuento,
                                         FPD_CMIVA_Porcentaje,
                                         FP_RetencionIVA,
                                         FP_RetencionISR,
                                         FPD_CMM_TipoVariacion,
                                         FP_CodigoFactura,
                                         FPD_OC_OrdenCompraId,
                                         FPD_CantidadNormal,
                                         FPD_CantidadVariacion,
                                         FPD_PrecioUnitarioNormal,
                                         FPD_PrecioUnitarioVariacion
                                           ) AS AGRUPADOR
                                           WHERE FPD_CMM_TipoVariacion = 'F3988783-D778-4924-A080-4C14222ECAFE'
                         ) AS TEMP
                         GROUP BY
                         proveedor,
                                  FP_FacturaProveedorId ,
                                  FP_CodigoFactura ,
                                  FP_FechaFactura ,
                                  TEL_CP,
                                  PRO_Domicilio,
                                  PRO_NombreComercial,
                                  PRO_RFC,
                                  PRO_Nombre ,
                                  FTRT_PorcentajeRetencion ,
                                  PRO_ProveedorId,
                                  PRO_CodigoProveedor ,
                                  SaldoAFavor,
                                  TEP_TerminoPago ,
                                  DiasTranscurridosVencimiento,
                                  EstadoFactura,
                                  FECHA_VENCIMIENTO,
                                  MON_MonedaId,
								  MONP_TipoCambioOficial,
                                  MON_Nombre
                        ) ASSUM
                        WHERE montoActual > 0
                        AND MON_MonedaId = @monedaId
                        ORDER BY  MON_Nombre, PROVEEDOR, DiasTranscurridosVencimiento desc,
                                  ASSUM.FECHA_VENCIMIENTO ASC, FP_CodigoFactura ASC
