TSamp = 0.1;

maxValue = Simulink.Parameter;
maxValue.Value = 10;
maxValue.CoderInfo.StorageClass = 'ExportedGlobal';
maxValue.CoderInfo.Alias = '';
maxValue.CoderInfo.Alignment = -1;
maxValue.Description = '';
maxValue.DataType = 'double';
maxValue.Min = [];
maxValue.Max = [];
maxValue.DocUnits = '';

assignin('base','TSamp',TSamp);
assignin('base','maxValue',maxValue);