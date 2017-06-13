function TransformToIsoVoxel_test()

clear all
clc

parametersIsoVoxelTransformation = parametersIsoVoxelTransformationATWM1;

strVmr = 'CX75DJQ_ATWM1_MPRAGE_LOW_RES.vmr';
strFolderVmr = 'D:\Daten\ATWM1\Single_Subject_Data\Daten von Mishal\CX75DJQ\12_MPRAGE_LOW_RES\';
strPathVmr = fullfile(strFolderVmr, strVmr);


strVmrIso = sprintf('%s_%s.vmr', strVmr(1:end - 4), parametersIsoVoxelTransformation.strIsoVoxelTransformation);
strPathVmrIso = fullfile(strFolderVmr, strVmrIso);


if exist(strPathVmr, 'file')
    bv = actxserver('BrainVoyager.BrainVoyagerScriptAccess.1');
    vmr = bv.OpenDocument(strPathVmr);
    
    fprintf('Isovoxelating VMR %s using %s interpolation.\n', strPathVmr, parametersIsoVoxelTransformation.strInterpolationMethod)
    
    success = vmr.TransformToIsoVoxel(parametersIsoVoxelTransformation.interpolationMethod, strPathVmrIso, parametersIsoVoxelTransformation.targetResolution, parametersIsoVoxelTransformation.framingCubeDimension);
    if success
        fprintf('Operation sucessful!\n\n');
    else
        fprintf('Operation failed!\n\n');
    end
end


end