CREATE PROCEDURE SP_partition_table   
    @table_name nvarchar(50),   
    @column_name nvarchar(50),
	@schema_name nvarchar(50)   
AS   
  begin 
     IF EXISTS (select name from sys.tables where name =  @table_name)
		begin
			declare @i nvarchar (50) = (select db_name()) 
			declare @b int = 1
			declare @g nvarchar (10) = cast(@b as nvarchar(10))
			declare @a nvarchar (max) = 'alter database ' + @i + ' add filegroup fg'+@g 
			declare @h nvarchar (max) = 'alter database ' + @i + ' add file( name = df'+@g + ', filename = ''C:\11.ndf'') to filegroup fg'+@g 
			while (@b<4)
				begin
					exec (@a)
					exec (@h)
					set @b = @b + 1
				end

			CREATE PARTITION FUNCTION PF_SP (int)
			AS RANGE left
			FOR VALUES (1,1000)
	

			declare @c nvarchar (max) = 'CREATE PARTITION SCHEME ' + @schema_name + ' AS PARTITION PF_SP TO (fg1, fg2, fg3)'
			exec (@c)


			IF EXISTS (select name from sys.indexes where object_id = object_id (@table_name) and type = 1) 
				BEGIN
					declare @d nvarchar (max) = (select name from sys.indexes where object_id = object_id (@table_name) and type = 1)
					declare @e nvarchar (max) = 'CREATE UNIQUE CLUSTERED INDEX '+@d+' ON '+@table_name+' (' +@column_name+') WITH(DROP_EXISTING = ON)ON '+@schema_name+' ('+@column_name+')'
					exec (@e)
				END
			ELSE
				declare @f nvarchar (max) = 'CREATE CLUSTERED INDEX IX_partition ON '+@table_name+ ' ('+@column_name+') ON {'+@schema_name+' ('+@column_name+')'
				exec (@f)	 
		end
	 
	 ELSE
		print 'The table does not exist in this database'						

  end 
	