function barcodeGeneratorATWM1(strSubjectCode)
    % Create code128 barcode labels for each subject
    %
    % Step 1: Barcode generation itself is implemented in PostScript.
    %         Open BarcodeTemplate.ps as template and replace
    %         the placeholder keyword by the actual string to be encoded; 
    %         save result as a new, temporary file.
    % Step 2: Convert this PostScript file to PDF
    % Step 3: For label printing, open the LaTeX template 
    %         BarcdeLabelsTemplate.tex, replace the placeholder keyword by 
    %         the encoded string and compile with pdfLaTeX
    % Step 4: Delete all temporary files including LaTeX tex/log/aux

    global iStudy
    global m_cfg
    
    strStudy = iStudy;
    
    m_cfg.bCreateLabelSheetPDFSuccess = false;
    
    InitBarCode(strSubjectCode, strStudy);

    SetFilePaths();

    if ~CheckRequiredFiles()
        return
    end

    if ~CheckFileLock()
        return
    end

    if ~CreateSingleBarCodePDF();
        return
    end

    if ~CreateLabelSheetPDF();
        return
    end
    
    DeleteTemporaryFiles();
    
end


function InitBarCode(strSubjectCode, strStudy)

    global m_cfg

    % Avoid underscores in LaTeX figure names !
    strSubjectCode = strrep(strSubjectCode, '_', '-');
    strStudy = strrep(strStudy, '_', '-');
    
    m_cfg.strBarCode = sprintf('%s-%s', strSubjectCode, strStudy);    

end


function SetFilePaths()

    global iStudy
    global m_cfg
    
    parametersBarcode = eval(['parametersBarcode', iStudy]);

    m_cfg.iEnvironment = 1;
    
    switch m_cfg.iEnvironment
        
        case 1 % Robert, Windows
            
            m_cfg.bIsWindowsPC = true;
            m_cfg.strTemplateFolder = 'D:\Forschung\Software\BarcodeGenerator\';
            m_cfg.strOutputFolder = 'D:\Daten\ATWM1\Barcodes\';
        
            m_cfg.strLaTeXFolder = 'D:\Forschung\Software\MiKTeXPortable\miktex\bin\';
            m_cfg.strPS2PDFBinaryPath = strcat(m_cfg.strLaTeXFolder, 'ps2pdf');
            m_cfg.strPDFLaTeXBinaryPath = strcat(m_cfg.strLaTeXFolder, 'pdflatex');
    
        case 2 % Michael, Mac
            
            m_cfg.bIsWindowsPC = false;
            m_cfg.strTemplateFolder = '/Users/mmb/MEG/ATWM1/Labels/MATLABScript/';
            m_cfg.strOutputFolder = '/Users/mmb/MEG/ATWM1/Labels/SubjectBarcodes/';
            
            m_cfg.strLaTeXFolder = '/usr/texbin/';
            m_cfg.strPDFLaTeXBinaryPath = '/usr/texbin/pdflatex'; 
            m_cfg.strPS2PDFBinaryPath = '/usr/local/bin/ps2pdf';    

        case 3 % MEG / lfs1
            
            m_cfg.bIsWindowsPC = false;
    end

    m_cfg.strCurrentPath = pwd;

    m_cfg.strTemplatePathPostScript = sprintf('%sBarcodeTemplate.ps', m_cfg.strTemplateFolder);
    m_cfg.strTemplatePathLaTeX = sprintf('%sBarcodeLabelsTemplate.tex', m_cfg.strTemplateFolder);

    m_cfg.strOutputSingleBarcodePostScript  = sprintf('%s%s.ps', m_cfg.strOutputFolder, m_cfg.strBarCode);
    m_cfg.strOutputSingleBarcodePDF         = sprintf('%s%s.pdf', m_cfg.strOutputFolder, m_cfg.strBarCode);
    m_cfg.strOutputLaTeXLabels              = sprintf('%s%s-%s.tex', m_cfg.strOutputFolder, m_cfg.strBarCode, parametersBarcode.strBarcode);
    
    % After avoiding underscores in the LaTeX figure name, underscores are
    % inserted for the file names
    m_cfg.strOutputLaTeXLabels              = strrep(m_cfg.strOutputLaTeXLabels, '-', '_');
    m_cfg.strOutputLaTeXLabelsPDF           = strrep(m_cfg.strOutputLaTeXLabels, '.tex', '.pdf');
 
end


function bAllRequiredFilesExist = CheckRequiredFiles()

    global m_cfg

    %%% Check, whether all required files can be accessed.
    aStrPathFiles = {
        m_cfg.strTemplatePathLaTeX
        m_cfg.strTemplatePathPostScript
    };
    
    bAllRequiredFilesExist = true;
    
    for cf = 1:numel(aStrPathFiles)
        if ~exist(aStrPathFiles{cf}, 'file')
            strMessage = sprintf('File %s required for barcode generation was not found!\nAborting function.', aStrPathFiles{cf});
            disp(strMessage);
            bAllRequiredFilesExist = false;
        end
    end    
    
end


function bAllFilesUnlocked = CheckFileLock()

    global m_cfg

    % Check whether pdf file containing the barcodes already exist and 
    % whether it can be overwritten.

    bAllFilesUnlocked = true;
    
    if exist(m_cfg.strOutputLaTeXLabelsPDF, 'file')
        fid = fopen(m_cfg.strOutputLaTeXLabelsPDF, 'wt');
        if fid == -1
            strMessage = sprintf('File %s could not be created!\nPlease check, whether file is already open in another program.\nAborting function.', m_cfg.strOutputLaTeXLabelsPDF);
            disp(strMessage);
            bAllFilesUnlocked = false;
        else
            status = fclose(fid);
            if status == 0
                delete(m_cfg.strOutputLaTeXLabelsPDF);
            else
                strMessage = sprintf('File %s could not be created!\nPlease check, whether file can be accessed properly.\nAborting function.', m_cfg.strOutputLaTeXLabelsPDF);
                disp(strMessage);
                bAllFilesUnlocked = false;
            end
        end
    end
end


function bCreateSingleBarCodePDFSuccess = CreateSingleBarCodePDF()

    global m_cfg
    
    m_cfg.bCreateSingleBarCodePDFSuccess = false;
    
    % open PostScript template and replace placeholder key by actual barcode name
    strPostScriptTemplate = fileread(m_cfg.strTemplatePathPostScript);
    strPostScriptTemplate = strrep(strPostScriptTemplate, 'BARCODE_PLACEHOLDER', m_cfg.strBarCode);

    fidOutput = fopen(m_cfg.strOutputSingleBarcodePostScript, 'w');
    fwrite(fidOutput, strPostScriptTemplate, '*char');  % write characters (bytes)
    fclose(fidOutput);

    % convert PostScript file to PDF
    if m_cfg.bIsWindowsPC
        cd(m_cfg.strLaTeXFolder); 
    else
        cd(m_cfg.strOutputFolder);
    end

    strConversionCommand = sprintf('%s -dEPSCrop %s', m_cfg.strPS2PDFBinaryPath, m_cfg.strOutputSingleBarcodePostScript);
    [status, cmdout] = system(strConversionCommand);
    
    if status == 0
        m_cfg.bCreateSingleBarCodePDFSuccess = true;
        strMessage = sprintf('PDF file %s successfully created.', m_cfg.strOutputSingleBarcodePDF);        
        % do not output, will be deleted later
    else        
        strMessage = sprintf('Could not create PDF file %s.\n%s', m_cfg.strOutputSingleBarcodePDF, cmdout);
        disp(strMessage);
    end    
    bCreateSingleBarCodePDFSuccess = m_cfg.bCreateSingleBarCodePDFSuccess;
    
end


function bCreateLabelSheetPDFSuccess = CreateLabelSheetPDF()

    global m_cfg
    
    m_cfg.bCreateLabelSheetPDFSuccess = false;
 
    % open LaTeX template and replace placeholder key by actual barcode PDF file name
    strLaTeXTemplate = fileread(m_cfg.strTemplatePathLaTeX);
    strLaTeXTemplate = strrep(strLaTeXTemplate, 'BARCODE_PDF_PLACEHOLDER', m_cfg.strBarCode);

    fidOutput = fopen(m_cfg.strOutputLaTeXLabels, 'w');
    fwrite(fidOutput, strLaTeXTemplate, '*char');  % write characters (bytes)
    fclose(fidOutput);

    cd(m_cfg.strOutputFolder);
    strTeXCommand = sprintf('%s %s', m_cfg.strPDFLaTeXBinaryPath, m_cfg.strOutputLaTeXLabels);
    [status, cmdout] = system(strTeXCommand);
    
    if status == 0
        m_cfg.bCreateLabelSheetPDFSuccess = true;
        strMessage = sprintf('PDF file %s successfully created.', m_cfg.strOutputLaTeXLabelsPDF);        
    else        
        strMessage = sprintf('Could not create PDF file %s\n%s.', m_cfg.strOutputLaTeXLabelsPDF, cmdout);
    end 
    disp(strMessage);
    bCreateLabelSheetPDFSuccess = m_cfg.bCreateLabelSheetPDFSuccess;

end


function DeleteTemporaryFiles()

    global m_cfg
    
    % Delete temporary PostScript and PDF files with single barcode
    delete(m_cfg.strOutputSingleBarcodePostScript);
    strOutputSingleBarcodePostScript = strrep(m_cfg.strOutputSingleBarcodePostScript, 'ps','pdf');
    delete(strOutputSingleBarcodePostScript);

    % Delete temporary LaTeX files
    delete(m_cfg.strOutputLaTeXLabels);
    strOutputLaTeXLabels = strrep(m_cfg.strOutputLaTeXLabels, 'tex','aux');
    delete(strOutputLaTeXLabels);
    strOutputLaTeXLabels = strrep(strOutputLaTeXLabels, 'aux','log');
    delete(strOutputLaTeXLabels);

    cd(m_cfg.strCurrentPath);
    
end


