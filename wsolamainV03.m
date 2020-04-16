% 2020.0302
% 去除掉唱歌者的silence，然后进行倍数扩展。
%  

clear;close all;
filename='./audio.wav';
[x,fs] = audioread(filename);
%% load time point and F0
GMEtxt = load('./align_Time/V03_GME.txt');
G_dur = (GMEtxt(:,2) - GMEtxt(:,1)) * fs;
silence = GMEtxt(:,3);
psbtxt = load('./align_Time/V03_psb.txt');
Segpoint1 = psbtxt(:,1)*fs;
Segpoint2 = psbtxt(:,2)* fs;
middlepoint =  psbtxt(:,4)* fs;
yesno = psbtxt(:,3);

%%
deta =[];
speech=[];
TSR = [] ;
for j= 1: length(yesno)
    index1 = Segpoint1(j);
    index2 = Segpoint2(j);
    Y = x(index1:index2);
    indexmiddle = middlepoint(j);
               
    if yesno(j)
        TSR(j) = G_dur(j)/ (index2 -indexmiddle) ;
        Frame1 = x(index1+1: indexmiddle);
        input = x(indexmiddle+1: index2 );                           
        Frame2= wsolazycV1(input,fs ,TSR(j) ) ;
        SegFrame = [Frame1 ;Frame2];
    
    else
        
        TSR(j) = G_dur(j)/ (index2 -index1) ;
        SegFrame =  wsolazycV1(Y,fs ,TSR(j) ) ;
        
    end
    
    if silence(j)  
       silence_Len =  floor( (GMEtxt(j,4) - GMEtxt(j,2)) * fs );
       silence_x = randn(silence_Len,1).*0.001;
       SegFrame = [SegFrame ; silence_x];
    end
    speech =[speech;SegFrame];
%     sound(SegFrame,fs);
%     figure(2)
%     plot(x(index1:index2));
%     title('原始音频');
%     figure(4)
%     plot(SegFrame);
%     title('合成音频');
      out_len = length(SegFrame);
      deta(j) = G_dur(j) -  out_len ;

end 
% speech =[speech;x(Segpoint(end):end) ];
sound(speech,fs);
% audiowrite('./V03-psb-Timescalev0304.wav',speech,fs);


