function CoregisterFMRToVMRUsingBBR_test()

strFolderVmr = 'D:\Daten\ATWM1\Single_Subject_Data\Daten von Mishal\AE23XMP\11_MPRAGE_HIGH_RES\';
strFolderFmr = 'D:\Daten\ATWM1\Single_Subject_Data\Daten von Mishal\AE23XMP\01_WM_run_1\';

strVmr = 'AE23XMP_ATWM1_MPRAGE_HIGH_RES_BRAIN.vmr';
strFmr = 'AE23XMP_ATWM1_WM_run1_firstvol.fmr';

strPathVmr = fullfile(strFolderVmr, strVmr);
strPathFmr = fullfile(strFolderFmr, strFmr);


strVmrCoreg = 'AE23XMP_ATWM1_MPRAGE_HIGH_RES_BRAIN_COREG.vmr';
strPathVmrCoreg = fullfile(strFolderVmr, strVmrCoreg);

if exist(strPathVmr, 'file')
        
    %%% Create copy of VMR to be used exclusively for coregistration
    success = copyfile(strPathVmr, strPathVmrCoreg)
    if success
        bv = actxserver('BrainVoyager.BrainVoyagerScriptAccess.1');
        vmr = bv.OpenDocument(strPathVmrCoreg);
        success = vmr.CoregisterFMRToVMRUsingBBR(strPathFmr)
    else
        fprintf('Error! Could not create %s\n', strPathVmrCoreg);
    end
end


end