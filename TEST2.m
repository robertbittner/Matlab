function TEST2()

clear all
clc

strVmr = 'CX75DJQ_ATWM1_MPRAGE_LOW_RES.vmr';
strFolderVmr = 'D:\Daten\ATWM1\Single_Subject_Data\Daten von Mishal\CX75DJQ\12_MPRAGE_LOW_RES\';
strPathVmr = fullfile(strFolderVmr, strVmr);


strVmrIso = 'AE23XMP_ATWM1_MPRAGE_LOW_RES_ISO_NEW.vmr ';
strPathVmrIso = fullfile(strFolderVmr, strVmrIso);


if exist(strPathVmr, 'file')
    bv = actxserver('BrainVoyager.BrainVoyagerScriptAccess.1');
    
    vmr = bv.OpenDocument(strPathVmr);
    
    interpolation = 3 % 1 = trilinear; 2 = cubic spline; 3 = sinc
    target_resolution = 1
    framing_cube_dim = 256
    
    success = vmr.TransformToIsoVoxel(interpolation, strPathVmrIso, target_resolution, framing_cube_dim)
end


end