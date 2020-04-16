function  output_signal= wsolazycV1(input_signal,Fs,TSR )  
% wsolazycV1相对 wsolazyc改进： 
% 代码line29 ：由input_signal(1:inc)变成 input_signal(1:L)。
% 可以减弱 韵母变速后的第一帧噪声。 

%% 1.Setup
L = Fs/1000 * 20;               % 20 ms
% Nfft = L; 
inc = L/2;                        % 50% overlap (10 ms)
win = hanning (L, 'periodic');
delta = round(Fs/1000 * 5);     % 5 ms  deltamax
%TSR = 2;
inc_out = inc;                   %
inc_in = round(inc_out/TSR);      %

%% 2.Overlap-add with time-scaling with WSOLA
index_syn=0; 
index_out=0; 
nseg = 1;                           % 诊断错误
inlen = length(input_signal);
outlen = ceil(TSR*inlen+L);
output_signal = zeros(outlen,1);
synthesis_frame = zeros(L,1);
deltas = [];
output_signal(1:L) = input_signal(1:L).* hanning(L);
index_ana = index_syn + inc_out;    % index_ana 对应 pref；
index_syn = index_syn + inc_in;     % index_syn 对应 pin
index_out = index_out + inc_out;    % index_out 对应 pout

while ( (index_ana + L) < inlen ) && ( (index_syn+L+delta) < inlen ) &&(index_out+L<outlen)
% while ( (index_ana + L) < inlen ) && ( (index_syn+L+delta) < inlen )    
    % 1.cross-correlation
    ana_frame = input_signal(index_ana+1:index_ana+L);
%     syn_frame = input_signal(index_syn+1-delta:index_syn+L+delta); %.* win;
    if index_syn >=delta
        syn_frame = input_signal(index_syn+1-delta:index_syn+L+delta); %.* win;
    else
        syn_frame = [zeros(delta -index_syn,1); input_signal(1:index_syn+L+delta)];
    end
    
    [ xc, lags ] = xcorr(syn_frame, ana_frame, 2*delta);
    aligned = 2*delta+1;
    xc_delta = xc(aligned:aligned+2*delta);
    [ ~, i ] = max(abs(xc_delta));
 
    %2.normalized cross-correlation
    tmp1 = buffer(syn_frame,L,L-1,'nodelay');
    xc_rms = rms(tmp1);
    tmp2 = abs(xc_delta./xc_rms') ;
    [ ~, i ] = max(tmp2);
    
    idx = i-1;
    deltas = [ deltas idx ];
    
    synthesis_frame = syn_frame(idx+1:idx+L);
	output_signal(index_out+1:index_out+L) = output_signal(index_out+1:index_out+L) + synthesis_frame .* win;
   
    % 3. time point
    index_ana = index_syn - delta + idx + inc_out;
    index_syn = index_syn + inc_in;
    index_out = index_out + inc_out;

    nseg = nseg + 1;
    
end

% n_seg = nseg - 1;

% close all
figure(1)
plot(input_signal)
title('原始的韵母');

theta=0.0001;
y=abs(output_signal);
ind_y=find(y>=theta);
index_y = ind_y(end);
if abs(output_signal(end))>=theta
     return
else
    sy=output_signal(index_y+1:end);
    sy=sy*output_signal(index_y);
     ind_sy=  find(sy<=0);
    if isempty(ind_sy)
        
        return
    else
        ind_out = index_y+ ind_sy(1);
        output_signal=output_signal(1:ind_out);
    end
end



% output_signal =output_signal(1:floor(inlen *tsr));
figure(3)
plot(output_signal)
title('合成后的韵母');

end





