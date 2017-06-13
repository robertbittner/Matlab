function CorrectIntensityInhomogeneities_test()

clear all
clc


strVmr = 'CX75DJQ_ATWM1_MPRAGE_HIGH_RES.vmr';
strFolderVmr = 'D:\Daten\ATWM1\Single_Subject_Data\Daten von Mishal\CX75DJQ\11_MPRAGE_HIGH_RES\';
strPathVmr = fullfile(strFolderVmr, strVmr);

if exist(strPathVmr, 'file')
    bv = actxserver('BrainVoyager.BrainVoyagerScriptAccess.1');
    vmr = bv.OpenDocument(strPathVmr);
    success = vmr.CorrectIntensityInhomogeneities()
    vmr = bv.ActiveDocument;
    success = vmr.AutoACPCAndTALTransformation()
    
end

end