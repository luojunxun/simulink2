function runVerification2(buildNumber)

%% Add paths
addpath(fileparts(mfilename('fullpath')));

% %% Create verification folder
% newDir = ['VerifyNr' num2str(buildNumber)];
% fprintf(2,'*** Create directory %s ***\n', newDir);
% mkdir(newDir);
% cd(newDir);

%% Setup PIL
fprintf(2,'*** Set up TMS570 hardware ***\n');

%% Initialize model
fprintf(2,'*** Initialize model parameters ***\n');
initModel;

%% Load model
fprintf(2,'*** Loading Model ***\n');
myModel = 'MyTestModel';
load_system(myModel);
% set_param(gcs,'SimulationCommand','Update');
set_param(bdroot,'SimulationCommand','Update');

% %% Execute model checks
% fprintf(2,'*** Execute model checks ***\n');
% % Create list of checks and models to run.
% %CheckIDList ={'mathworks.maab.jc_0021', 'mathworks.iec61508.RootLevelInports'};
% SysList={myModel};
% % Run the Model Advisor.
% checkResult = ModelAdvisor.run(SysList,'Configuration','ModelAdvisorChecksFilter.mat');
% fprintf(2,'Result: Number of checks failed: %i\n', checkResult{1}.numFail);
% fprintf(2,'        Number of checks with warnings: %i\n', checkResult{1}.numWarn);
% fprintf(2,'        Number of checks passed: %i\n', checkResult{1}.numPass);

%% Run tests
fprintf(2,'*** Execute test cases ***\n');
% Executing tests from SL Test
% tf = sltest.testmanager.load('TestManager');
% result = tf.run
% Executing tests using ml unit test
myTestSuite = testsuite('TestManager.mldatx');
import('matlab.unittest.TestRunner');
import('matlab.unittest.TestSuite');
import('matlab.unittest.plugins.TAPPlugin');
import('matlab.unittest.plugins.ToFile');
import('matlab.unittest.plugins.TestReportPlugin');
import('matlab.unittest.plugins.XMLPlugin');
import('matlab.unittest.plugins.CodeCoveragePlugin');
import('matlab.unittest.plugins.codecoverage.CoberturaFormat');
import('sltest.plugins.ModelCoveragePlugin');
import('sltest.plugins.coverage.CoverageMetrics');

% Create test runner
myTestRunner = TestRunner.withTextOutput;

% Add TAP output plugin
tapFile = 'myResult_TapOutput.tap';
if exist(tapFile,'file')
    delete(tapFile)
end
myTestRunner.addPlugin(TAPPlugin.producingVersion13(ToFile(tapFile)));

% Add Cobertura code coverage
resultsFile = 'myTestResults.xml';
if exist(resultsFile,'file')
    delete(resultsFile)
end
myTestRunner.addPlugin(XMLPlugin.producingJUnitFormat(resultsFile));
coverageFile = 'codeCoverage.xml';
if exist(coverageFile,'file')
    delete(coverageFile)
end
myTestRunner.addPlugin(CodeCoveragePlugin.forFolder('./',...
    'Producing', CoberturaFormat(coverageFile)));

% Add model coverage report
mkdir('./temp');
mcr = sltest.plugins.coverage.ModelCoverageReport('./temp');
mcm = sltest.plugins.coverage.CoverageMetrics('Decision',true,'Condition',true,'MCDC',true);
myTestRunner.addPlugin(ModelCoveragePlugin('RecordModelReferenceCoverage',true));
myTestRunner.addPlugin(ModelCoveragePlugin('Collecting',mcm));
myTestRunner.addPlugin(ModelCoveragePlugin('Producing', mcr));
    
% Add SL Test details
myTestRunner.addPlugin(sltest.plugins.TestManagerResultsPlugin);

% Add Report generation plugin
pdfFile = 'MyTestReport.pdf';
myTestRunner.addPlugin(TestReportPlugin.producingPDF(pdfFile));

% Run tests
testResult = run(myTestRunner,myTestSuite);

% Extract result
rsList = sltest.testmanager.getResultSets;
sltest.testmanager.report(rsList(end),'./SLTestReport.pdf','IncludeTestResults',0);


% Display result
fprintf(2,'*** Result from test ***\n');
fprintf(2,fileread(tapFile));
fprintf(2,'\n');

%% Generate code
fprintf(2,'*** Generate Code ***\n');
rtwbuild(myModel);
% 
% %% Analyze code
% fprintf(2,'*** Start Polyspace Code Prover ***\n');
% [status, ~] = license('checkout','polyspace_server_c_cpp');
% if status
%     opts = polyspace.ModelLinkOptions(myModel);
%     opts.CodingRulesCodeMetrics.EnableMisraC3 = true;
%     opts.CodingRulesCodeMetrics.MisraC3Subset = 'mandatory';
%     opts.MergedReporting.EnableReportGeneration = true;
%     opts.MergedReporting.ReportOutputFormat = 'html';
%     opts.ResultsDir = 'ResultFolderPS';
%     proj = polyspace.Project;
%     proj.Configuration = opts;
%     codeProverResult = proj.run('codeProver');
%     %fprintf(2,'*** Result from Code Prover ***\n');
%     %fprintf(2, proj.Results.getSummary);
%     %fprintf(2,'\n');
% else
%     fprintf(2,'No license available for Code Prover\n');
% end


%% Clean up
fprintf(2,'*** Clean up ***\n');
close_system(myModel, 0);
