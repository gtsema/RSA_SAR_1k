function slc = SAR_process(raw,Vr,f0,PRF,fs,beam_width_az,swst,chirp_rg_BW,chirp_rg_T)
% slc = SAR_process(raw,Vr,f0,PRF,fs,beam_width_az,swst,chirp_rg_BW,chirp_rg_T)
%
% This function implements basic range-Doppler algorithm to focus a
% single-look-complex (SLC) image out of airborne SAR RAW data.
%
% Inputs:
%   raw: baseband RAW data in double complex format (range along lines)
%   Vr: sensor velocity [m/s]
%   f0: SAR central frequency [Hz]
%   PRF: pulse repetition ferquency [Hz]
%   fs: range sampling frequency [Hz]
%   beam_width_az: antenna pattern beam width in azimuth [deg]
%   swst: sampling window start time [s]
%   chirp_rg_BW: range emitted chirp bandwidth [Hz]
%   chirp_rg_T: range emitted chirp duration [s]
%
% Outputs:
%   slc: single-look-complex focused image in double complex format
%
% Note:
%   - Range emitted up-chirp is assumed. Otherwise conjugate raw input data
%   - Processing assumes low squinted data
%   - No performance requirements have been considered in writing this code
%   since its main objective is educational
%
% Author: Mario Azcueta <mazcueta@gmail.com> (Feb 2014)
% Additional parameters
near_rg_offset = 0;         % Samples to discard from near range (until echo is received)
c = 299792458;              % Speed of light [m/s]
lambda = c/f0;              % SAR wavelength [m]
doppler_pol_deg = 4;        % doppler centroid fitting polynomial degree

az_fft_size = 2^nextpow2(size(raw,1)); % Azimuth FFT length
rg_fft_size = 2^nextpow2(size(raw,2)); % Range FFT length
       
% Handler for correlating 2 signals {x,y}
compress = @(x,y,nfft)(ifft(conj(fft(x,nfft)).*(fft(y,nfft))));
% Handler to evaluate slant range [m] as function of range pixel number
slant_range = @(p)(c*swst/2 + (p-1)*c/fs/2);
%% RAW data conditioning
%display 'RAW data conditioning'
% Subtract raw mean value
raw = raw - mean(mean(raw));
%% Range compression
%display 'Range compression'
chirp_rg = chirp_comp(chirp_rg_BW,chirp_rg_T,fs);   % Reference range chirp
                % % chirp_rg_len = length(chirp_comp(chirp_rg_BW,chirp_rg_T,fs));
% Compress each range line
data_rg_compr = zeros(size(raw));                       % Initialize matrix
for k=1:size(raw,1)
                % % chirp_rg = raw(k,1:chirp_rg_len);
     aux = compress(chirp_rg,raw(k,:),rg_fft_size);      % Correlation
     data_rg_compr(k,:) = aux(1:size(data_rg_compr,2));  % Save result for line k
end
%% Doppler centroid estimation
%display 'Doppler centroid estimation'
% Change to range-Doppler domain in power
data_doppler = abs(fftshift(fft(data_rg_compr),1)).^2;
% Filter some noise
data_doppler = filter2(ones(101,3)/303,data_doppler,'same');
% Search for each column peak power (position of centroid)
[~,doppler_idx] = max(data_doppler);
% Map found indexes into frequencies
doppler_frec_idx = linspace(-PRF/2,PRF/2,size(data_rg_compr,1));
doppler_centroid_v = doppler_frec_idx(doppler_idx(near_rg_offset+1:end));
% Polynomial fit of Doppler centroid
warning off
doppler_centroid_coef = polyfit(near_rg_offset+1:size(data_rg_compr,2),doppler_centroid_v,doppler_pol_deg);
warning on
% Handler to evaluate Doppler centroid [Hz] as function of range pixel numb
doppler_centroid = @(p)(polyval(doppler_centroid_coef,p));
%% Range cell migration correction
%display 'RCMC'
% Define Doppler frequencies vector
fdopp = linspace(-PRF/2,PRF/2,size(data_rg_compr,1));
% Range/Doppler domain
data_rg_compr_fft = fftshift(fft(data_rg_compr),1);
% Original slant range spacing vector
R1 = slant_range(1:size(data_rg_compr,2));
for k=1:size(data_rg_compr,1)
    % New slant range spacing vector, compensates range migration for every
    % doppler frequency fdopp(k)
    R2 = R1 + R1*(lambda*fdopp(k)).^2/(8*Vr^2);
    
    % Interpolate to compensate migration
    data_rg_compr_fft(k,:) = interp1(R1,data_rg_compr_fft(k,:),R2,'PCHIP',NaN);
end
% Back to Range-Azimuth domain
data_rg_compr_rcmc = ifft(ifftshift(data_rg_compr_fft,1));
% % data_rg_compr_rcmc = data_rg_compr;

rows_with_nonzeros = any(~isnan(abs(data_rg_compr_rcmc)), 1);
data_rg_compr_rcmc = data_rg_compr_rcmc(:,rows_with_nonzeros);

size(data_rg_compr_rcmc);
%% Azimuth compression
%display 'Azimuth compression'
% Doppler BW to process
chirp_az_BW = 2/lambda*Vr*beam_width_az*pi/180;
% Compress each column in azimuth
slc = zeros(size(data_rg_compr_rcmc));       % initialize matrix

for k=near_rg_offset+1:size(data_rg_compr_rcmc,2)
    
    % Evaluate Doppler centroid
% %    DC = doppler_centroid(k);
    DC = 0;
    
    % Azimuth chirp duration: azimuth footprint length [m] / Vr
    chirp_az_T = slant_range(k)*(beam_width_az*pi/180)/Vr;
    
    % generate azimuth chirp and conjugate (down-chirp)
    chirp_az = chirp_comp(chirp_az_BW,chirp_az_T,PRF,DC)';
    
    % Compress and save result
    aux = compress(chirp_az,data_rg_compr_rcmc(:,k),az_fft_size);
    slc(:,k) = aux(1:size(slc,1));
end
%display 'END'
end
function [y,t] = chirp_comp( BW, T, fs, CA, phi)
% [y,t] = chirp_comp( BW , T, fs , CA , phi )
%
% Generates baseband (complex) up-chirp vector.
%
% Inputs:
%   BW: bandwidth [Hz]
%   T: duration [s]
%   fs: sampling frequency [Hz]
%   CA: carrier [Hz] (optional)
%   phi: initial phase [rad] (optional)
% 
% Outputs:
%   y: sampled complex up-chirp vector
%   t: time vector used to sample the chirp
%
% Example:
%   [y,t] = chirp_comp( 40e6 , 10e-6 , 50e6);
%   specgram(y,[],50e6,hanning(70),65)
%
%   Author: Mario Azcueta <mazcueta@gmail.com>
if ~exist('CA','var')
    CA = 0;
end
if ~exist('phi','var')
    phi = 0;
end
if nargin<3
    error('Error. Not enough input arguments.')
end
if BW/2+CA>fs
    disp('Warning. Aliasing will be produced since BW/2+CA < fs');
end
b = -BW/2 + CA;
a = (BW/2 + CA - b)/(2*T);
t = 0:1/fs:T;
y = conj(exp(1i*2*pi*(a*t.^2+b*t+phi/(2*pi))));
end