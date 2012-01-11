/***************************************************************************/
/***  Name         : mssql_sprocs.sql                                    ***/
/***                                                                     ***/
/***  Description  : Stored procedures required by FCFL.NET on MSSQL     ***/
/***                 platforms                                           ***/
/***                                                                     ***/
/***  Author       : First Choice Software, Inc.                         ***/
/***                 8900 Business Park Drive                            ***/
/***                 Austin, TX 78759                                    ***/
/***                                                                     ***/
/***  Usage        : First Choice Confidential                           ***/
/***                                                                     ***/
/***  Preconditions: None known                                          ***/
/***                                                                     ***/
/***  Postcondition: None known                                          ***/
/***                                                                     ***/
/***  Platforms    : This version supports MSSQL 7.0 or later            ***/
/***                                                                     ***/
/***  Copyright (C) 2005 First Choice Software, Inc.                     ***/
/***  All Rights Reserved                                                ***/
/***                                                                     ***/
/***************************************************************************/

/***************************************************************************/
/***     Create new fc_new_oid proc.                                     ***/
/***************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fc_new_oid]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[fc_new_oid]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROC fc_new_oid( @type_num int, @num_ids int, @out_num int output ) AS

BEGIN TRANSACTION
  UPDATE adp_tbl_oid WITH (HOLDLOCK UPDLOCK) SET obj_num = obj_num + @num_ids WHERE type_id = @type_num
  SELECT @out_num = obj_num FROM adp_tbl_oid WHERE type_id = @type_num
COMMIT TRANSACTION
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON fc_new_oid TO cl_user
GO


/***************************************************************************/
/***     Create new fc_next_num_scheme proc.                             ***/
/***************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fc_next_num_scheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[fc_next_num_scheme]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROC fc_next_num_scheme( @schemeName VARCHAR(50), @nextVal INT OUTPUT, @fmt VARCHAR(50) OUTPUT, @isPadded INT OUTPUT, @valWidth INT OUTPUT ) AS

BEGIN TRANSACTION
  SELECT @nextVal = next_value, @fmt = format, @isPadded = padded, @valWidth = value_width FROM table_num_scheme WITH( HOLDLOCK UPDLOCK ) WHERE name = @schemeName
  UPDATE table_num_scheme SET next_value = next_value + 1 WHERE name = @schemeName
COMMIT TRANSACTION
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON fc_next_num_scheme TO cl_user
GO

/***************************************************************************/
/***     Get next number in a number scheme.                             ***/
/***************************************************************************/

/* Drop stored procedures, if defined  */
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fc_new_numsch')
   DROP PROCEDURE fc_new_numsch
go

CREATE PROCEDURE fc_new_numsch @num_sch varchar(30), 
                              @new_num int OUTPUT AS
BEGIN
  BEGIN TRAN
  SELECT @new_num = next_value FROM table_num_scheme
    WHERE name = @num_sch
  UPDATE table_num_scheme SET next_value = next_value + 1 
    WHERE name = @num_sch
  COMMIT TRAN
END
go

GRANT EXECUTE ON fc_new_numsch TO cl_user
go

/***************************************************************************/
/***     Get next number in a part request header sequence.              ***/
/***************************************************************************/

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fc_next_pr_seq')
   DROP PROCEDURE fc_next_pr_seq
go

CREATE PROCEDURE fc_next_pr_seq @hdr_num varchar(20), 
                                 @new_num int OUTPUT AS
BEGIN
  BEGIN TRAN
  UPDATE table_demand_hdr SET sequence_num = sequence_num + 1 
    WHERE header_number = @hdr_num
  SELECT @new_num = sequence_num FROM table_demand_hdr
    WHERE header_number = @hdr_num
  COMMIT TRAN
END
go

GRANT EXECUTE ON fc_next_pr_seq TO cl_user
go