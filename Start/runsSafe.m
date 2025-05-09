function success = runsSafe(simulatorPath, circuitPath, timeoutSeconds, pollInterval)
% runsSafe - Runs LTspice simulation with timeout using polling
%
% Inputs:
%   simulatorPath  - Full path to LTspice executable (e.g., 'START C:\...\XVIIx64.exe')
%   circuitPath    - Full path to the .sp circuit file
%   timeoutSeconds - Maximum time to wait for simulation (in seconds)
%   pollInterval   - Time interval between checks (default = 0.5 s)
%
% Output:
%   success        - true if the simulation finished, false if it timed out

    if nargin < 4
        pollInterval = 0.5;
    end

    % Extract the executable name from the full path
    [~, exeName, ext] = fileparts(simulatorPath);
    exeFullName = [exeName ext];  % e.g., 'XVIIx64.exe'

    % Format the command to run LTspice in batch mode
    spiceCmd = sprintf('%s -b %s', simulatorPath, circuitPath);

    % Launch LTspice asynchronously
    system(spiceCmd);

    % Poll for process completion
    elapsed = 0;
    while elapsed < timeoutSeconds
        [~, procList] = system(sprintf('tasklist /FI "IMAGENAME eq %s"', exeFullName));
        if ~contains(procList, exeFullName)
            success = true;  % Process has exited
            return;
        end
        pause(pollInterval);
        elapsed = elapsed + pollInterval;
    end

    % Timeout reached: force kill LTspice
    system(sprintf('taskkill /F /IM %s >nul 2>&1', exeFullName));
    success = false;
end
