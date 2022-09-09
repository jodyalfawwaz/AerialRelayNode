clc; 
close all;
%Parameter Values MBS
P_mbs=43; %Daya transmisi Macro Base Station dalam dBm G_mbs=18; %Gain antenna MBS dalam dBi
Lc_mbs=3; %Cable loss MBS
Li_mbs=2; %Loss karena interferensi dan handover Nf_mbs=2; %Noise Figure MBS
%Parameter Values User Equipment(s)
P_ue=23; %Daya transmisi smartphone dalam dBm G_ue=0; %Gain smartphone
Lc_ue=0; %Body loss smartphone
Nf_ue=5; %Noise Figure UEs di jaringan LTE
%Parameter Mobile Hotspot P_r=20; %100 mW pada full power G_r=3; %omni_antenna
%Parameter lainnya
T=300; %Suhu di Majene, Indonesia dalam satuan Kelvin k=1.38065*10e-24; %konstanta boltzman
B=18e6; %Bandwidth wifi yang dapat digunakan dalam Hz fr=2400; %Frekuensi 4G dalam MHz
fc=1800; %Frekuensi wifi 2.4 GHz dalam MHz d_mbs2r=1e3:1e2:3e4; %Jarak MBS ke Relay dalam m h_uav=150; %tinggi UAV
hm=1.5; %tinggi UEs
Fl=6; %Fading dalam dB
Lo=4; %Loss lainnya
Le=2; %Edge Loss
a=4.88; %Parameter suburban
b=0.43; %Parameter suburban
%Thermal Noise
Nfloor=10*log10(k*T*B*1000);
%Perhitungan PLoS
%Grafik PLoS dengan jangkauan r_jangkauan=0:1:2e3;

h_uav=40:0.1:150; jangkauan_max=zeros(size(h_uav),'like',h_uav);
for i=1:numel(h_uav)
EA_rad=atan(h_uav(i)./r_jangkauan);
EA_deg=rad2deg(EA_rad);
PLoS=1./(1+(a.*exp(-b.*(EA_deg-a))));
PNLoS=1-PLoS;
d_rn2ue=hypot(r_jangkauan,h_uav(i));
LoS_PL_rn2ue=(32.44+20*log10(d_rn2ue/1000)+20*log10(fr)); ahm=(1.1*log10(fr)-0.7)*hm-(1.56*log10(fr)-0.8); Lp=69.55+26.16*log10(fr)-13.82*log10(h_uav(i))-ahm+(44.9-6.55*log10(h_uav(i))).*log10(d_rn2ue/1000); nLoS_PL_rn2ue=Lp-2*(log10(fr/28))^2-5.4; PL_rn2ue=(LoS_PL_rn2ue.*PLoS)+(nLoS_PL_rn2ue.*PNLoS); S_ue=P_r+G_ue+G_r-Lc_ue-Li_mbs-Nf_ue-PL_rn2ue;
jangkauan_max(i)=sum(S_ue>-70)-1;
end
plot(h_uav,jangkauan_max,'LineWidth',3)
xlabel('Ketinggian ARN (m)')
ylabel('Radius Jangkauan (m)')
title('Perbandingan Ketinggian ARN dengan Radius Jangkauan')
FSPL_r2mbs=32.44+(20*log10(d_mbs2r/1000))+(20*log10(fc)); S_r=P_mbs+G_mbs+G_r-Lc_mbs-Lc_ue-Li_mbs-Nf_ue-FSPL_r2mbs-Fl-Lo-Le; S_r=S_r-10*log10(1200);
y=-105+0*d_mbs2r;
figure
plot(d_mbs2r,S_r,'LineWidth',2)
hold on
plot(d_mbs2r,y,'--','LineWidth',2)
hold off
ylabel('RSRP (dBm)')
xlabel('Jarak ARN dengan MBS (m)') 
legend('RSRP yang diterima','Threshold')
%Pembuatan Peta Jangkauan
h_uav=68.91; x=rand(1,100000)*400; y=rand(1,100000)*400; r=zeros(size(x),'like',x); x_rn=200;
y_rn=200; d_rn2ue=zeros(size(x),'like',x); %Perhitungan jarak RN-UEs

for i=1:numel(x) r(i)=hypot(abs(x(i)-x_rn),abs(abs(y(i)-y_rn))); d_rn2ue(i)=hypot(r(i),h_uav);
end
EA_rad=asin(h_uav./d_rn2ue); EA_deg=rad2deg(EA_rad); PLoS=1./(1+(a.*exp(-b.*(EA_deg-a)))); 
PNLoS=1-PLoS;
LoS_PL_rn2ue=(32.44+20*log10(d_rn2ue/1000)+20*log10(fr)); 
ahm=(1.1*log10(fr)-0.7)*hm-(1.56*log10(fr)-0.8);
Lp=69.55+26.16*log10(fr)-13.82*log10(h_uav)-ahm+(44.9-6.55*log10(h_uav)).*log10(d_rn2ue/1000); 
nLoS_PL_rn2ue=Lp-2*(log10(fr/28))^2-5.4; PL_rn2ue=(LoS_PL_rn2ue.*PLoS)+(nLoS_PL_rn2ue.*PNLoS); 
S_ue=P_r+G_ue+G_r-Lc_ue-Li_mbs-Nf_ue-PL_rn2ue;
%Grafik Scatter
j=1;
k=1;
l=1;
m=1; x1=zeros(size(d_rn2ue),'like',d_rn2ue); x2=zeros(size(d_rn2ue),'like',d_rn2ue); x3=zeros(size(d_rn2ue),'like',d_rn2ue); x4=zeros(size(d_rn2ue),'like',d_rn2ue); y1=zeros(size(d_rn2ue),'like',d_rn2ue); y2=zeros(size(d_rn2ue),'like',d_rn2ue); y3=zeros(size(d_rn2ue),'like',d_rn2ue); y4=zeros(size(d_rn2ue),'like',d_rn2ue);
for i=1:numel(S_ue) if S_ue(i) >= -50
x1(j)=x(i); y1(j)=y(i); j=j+1;
elseif S_ue(i) < -50 && S_ue(i) >= -60 x2(k)=x(i);
y2(k)=y(i);
k=k+1;
elseif S_ue(i) < -60 && S_ue(i) >= -70
x3(l)=x(i); y3(l)=y(i); l=l+1;
else
x4(m)=x(i);
y4(m)=y(i);
m=m+1;
end 
end
j=j-1; k=k-1; l=l-1; m=m-1;
rng default; xu=rand(1,20)*250+60; yu=rand(1,20)*250+60;
figure
scatter(x1(1,1:j),y1(1,1:j),'green','filled');
hold on
scatter(x2(1,1:k),y2(1,1:k),'yellow','filled');
hold on
scatter(x3(1,1:l),y3(1,1:l),[],[1 0.5 0],'filled');
hold on
scatter(x4(1,1:m),y4(1,1:m),'red','filled');
hold on
scatter(x_rn,y_rn,50,'black','+','LineWidth',2); scatter(xu,yu,50,'black','s','filled')
hold off
title('Heatmap RSSI')
legend('Sangat Baik','Baik','Cukup','Buruk','UAV','UE'); xlabel('(m)')
ylabel('(m)')
%Perhitungan RSSI tiap perangkat
x_uav_opt=200; y_uav_opt=200;
d_rn2ue20=zeros(size(xu),'like',xu);
for i=1:numel(xu) r(i)=hypot(abs(xu(i)-x_uav_opt),abs(abs(yu(i)-y_uav_opt))); d_rn2ue20(i)=hypot(r(i),h_uav);
end
EA_rad20=asin(h_uav./d_rn2ue20); EA_deg20=rad2deg(EA_rad20); PLoS20=1./(1+(a.*exp(-b.*(EA_deg20-a)))); PNLoS20=1-PLoS20;


LoS_PL_rn2ue20=(32.44+20*log10(d_rn2ue20/1000)+20*log10(fr)); 
ahm20=(1.1*log10(fr)-0.7)*hm-(1.56*log10(fr)-0.8); 
Lp20=69.55+26.16*log10(fr)-13.82*log10(h_uav)-ahm20+(44.9-6.55*log10(h_uav)).*log10(d_rn2ue20/1000); 
nLoS_PL_rn2ue20=Lp20-2*(log10(fr/28))^2-5.4; PL_rn2ue20=(LoS_PL_rn2ue20.*PLoS20)+(nLoS_PL_rn2ue20.*PNLoS20); 
S_ue20=P_r+G_ue+G_r-Lc_ue-Li_mbs-Nf_ue-PL_rn2ue20;