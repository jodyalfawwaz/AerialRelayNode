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
%Parameter Values Relay Node
G_r1=11; %Gain antenna directional UAV-MBS dalam dBi G_r2=5; %Gain antenna omnidirectional UAV-UEs dalam dBi G_relay=100; %Gain repeater/amplifier
h_uav=150; %tinggi UAV
%Parameter lainnya
T=300; %Suhu di Majene, Indonesia dalam satuan Kelvin k=1.38065*10e-24; %konstanta boltzman
B=18e6; %Bandwidth LTE yang dapat digunakan dalam Hz fc=1900; %Frekuensi 4G dalam MHz d_mbs2rn=1e3:1e3:5e4; %Jarak MBS ke Relay
hm=1.5; %tinggi UEs
Fl=6; %Fading dalam dB
Lo=4; %Loss lainnya
Le=2; %Edge Loss
a=4.88; %Parameter suburban
b=0.43; %Parameter suburban
%Pembagian User Equipment
rng default; x=rand(1,6332)*4000; y=rand(1,6332)*4000; x_scatter=rand(1,100)*4000; y_scatter=rand(1,100)*4000; %Gambar peletakan

figure scatter(x,y,'filled');
%Pembentukan variabel jarak RN-UEs
r=zeros(size(x),'like',x); x_rn=2000;
y_rn=2000; d_rn2ue=zeros(size(x),'like',x);
%Perhitungan jarak RN-UEs
for i=1:numel(x) r(i)=hypot(abs(x(i)-x_rn),abs(abs(y(i)-y_rn))); d_rn2ue(i)=hypot(r(i),h_uav);
end
%Perhitungan sudut elevasi tiap user
EA_rad=asin(h_uav./d_rn2ue); EA_deg=rad2deg(EA_rad);
%Menghitung probabilitas LoS dan NLoS tiap user
PLoS=1./(1+(a.*exp(-b.*(EA_deg-a)))); PNLoS=1-PLoS;
%Perhitungan path loss RN-UEs
LoS_PL_rn2ue=(32.44+20*log10(d_rn2ue/1000)+20*log10(fc));
ahm=(1.1*log10(fc)-0.7)*hm-(1.56*log10(fc)-0.8); Lp=69.55+26.16*log10(fc)-13.82*log10(h_uav)-ahm+(44.9-6.55*log10(h_uav)).*log10(d_rn2ue/1000); nLoS_PL_rn2ue=Lp-2*(log10(fc/28))^2-5.4;
PL_rn2ue=(LoS_PL_rn2ue.*PLoS)+(nLoS_PL_rn2ue.*PNLoS);
%Perhitungan path loss RN-MBS
FSPL_rn2mbs=32.44+20*log10(d_mbs2rn/1000)+20*log10(fc);
%Perhitungan jumlah users yang terlayani per jarak RN-MBS
S_ue=zeros(size(d_rn2ue),'like',d_rn2ue); RSRP=zeros(size(d_rn2ue),'like',d_rn2ue); Served_users=zeros(size(d_mbs2rn),'like',d_mbs2rn); S_minperjarak=zeros(size(d_mbs2rn),'like',d_mbs2rn); for i=1:numel(d_mbs2rn)
for j=1:numel(d_rn2ue) S_ue(j)=P_mbs+G_mbs+G_ue+G_r1+G_r2+G_relay-Lc_mbs-Lc_ue-Li_mbs-Nf_ue-Fl-Lo-Le-PL_rn2ue(j)-FSPL_rn2mbs(i); RSRP(j)=S_ue(j)-10*log10(1200);
end
S_minperjarak(i)=min(S_ue); Served_users(i)=sum(RSRP >= -120);

end
%Grafik PLoS dengan jangkauan
r_jangkauan=0:1:2e3; h1_uav=150; h2_uav=100; h3_uav=50;
EA1_rad=atan(h1_uav./r_jangkauan); EA2_rad=atan(h2_uav./r_jangkauan); EA3_rad=atan(h3_uav./r_jangkauan);
EA1_deg=rad2deg(EA1_rad); EA2_deg=rad2deg(EA2_rad); EA3_deg=rad2deg(EA3_rad); PLoS1=1./(1+(a.*exp(-b.*(EA1_deg-a)))); PLoS2=1./(1+(a.*exp(-b.*(EA2_deg-a)))); PLoS3=1./(1+(a.*exp(-b.*(EA3_deg-a))));
PNLoS1=1-PLoS1; PNLoS2=1-PLoS2; PNLoS3=1-PLoS3;
d_rn2ue1=hypot(r_jangkauan,h1_uav); d_rn2ue2=hypot(r_jangkauan,h2_uav); d_rn2ue3=hypot(r_jangkauan,h3_uav);
LoS_PL_rn2ue1=(32.44+20*log10(d_rn2ue1/1000)+20*log10(fc)); LoS_PL_rn2ue2=(32.44+20*log10(d_rn2ue2/1000)+20*log10(fc)); LoS_PL_rn2ue3=(32.44+20*log10(d_rn2ue3/1000)+20*log10(fc));
ahm1=(1.1*log10(fc)-0.7)*hm-(1.56*log10(fc)-0.8); Lp1=69.55+26.16*log10(fc)-13.82*log10(h1_uav)-ahm1+(44.9-6.55*log10(h1_uav)).*log10(d_rn2ue1/1000); nLoS_PL_rn2ue1=Lp1-2*(log10(fc/28))^2-5.4;
ahm2=(1.1*log10(fc)-0.7)*hm-(1.56*log10(fc)-0.8); Lp2=69.55+26.16*log10(fc)-13.82*log10(h2_uav)-ahm2+(44.9-6.55*log10(h2_uav)).*log10(d_rn2ue2/1000); nLoS_PL_rn2ue2=Lp2-2*(log10(fc/28))^2-5.4;
ahm3=(1.1*log10(fc)-0.7)*hm-(1.56*log10(fc)-0.8); Lp3=69.55+26.16*log10(fc)-13.82*log10(h3_uav)-ahm3+(44.9-6.55*log10(h3_uav)).*log10(d_rn2ue1/1000); nLoS_PL_rn2ue3=Lp3-2*(log10(fc/28))^2-5.4;
PL_rn2ue1=(LoS_PL_rn2ue1.*PLoS1)+(nLoS_PL_rn2ue1.*PNLoS1); PL_rn2ue2=(LoS_PL_rn2ue2.*PLoS2)+(nLoS_PL_rn2ue2.*PNLoS2); PL_rn2ue3=(LoS_PL_rn2ue3.*PLoS3)+(nLoS_PL_rn2ue3.*PNLoS3);

%Grafik PLoS
figure
plot(r_jangkauan,PLoS1)
title('Perbandingan Jangkauan dengan P(LoS)')
ylabel('PLoS')
xlabel('Jangkauan (m)')
hold on
plot(r_jangkauan,PLoS2)
plot(r_jangkauan,PLoS3)
hold off
legend('Ketinggian UAV 150m','Ketinggian UAV 100m','Ketinggian UAV 50m')
%Grafik EA vs PLOS
ea=0:0.01:90; PLoS_ea=1./(1+(a.*exp(-b.*(ea-a)))); 
PLoS_ea_round=round(PLoS_ea,4) 
figure plot(ea,PLoS_ea_round,'LineWidth',1.5) xlabel('Sudut Elevasi')
ylabel('P(LoS)')
%Grafik PL
figure
plot(r_jangkauan,PL_rn2ue1)
title('Perbandingan Jangkauan dengan PL')
ylabel('PL(dB)')
xlabel('Jangkauan (m)')
hold on
plot(r_jangkauan,PL_rn2ue2)
plot(r_jangkauan,PL_rn2ue3)
hold off
legend('Ketinggian UAV 150m','Ketinggian UAV 100m','Ketinggian UAV 50m')
%Grafik perangkat terlayani
figure
plot(d_mbs2rn,Served_users,'b--o')
title('Perbandingan Jumlah Served Users dengan Jarak antara Relay dan MBS') 
ylabel('Jumlah Users')
xlabel('Jarak Antara Relay dan MBS (m)')
%Grafik Scatter
d_mbs2rn=41e3; FSPL_rn2mbs=32.44+20*log10(d_mbs2rn/1000)+20*log10(fc);
j=1; k=1;


l=1;
m=1; x1=zeros(size(d_rn2ue),'like',d_rn2ue); x2=zeros(size(d_rn2ue),'like',d_rn2ue); x3=zeros(size(d_rn2ue),'like',d_rn2ue); x4=zeros(size(d_rn2ue),'like',d_rn2ue); y1=zeros(size(d_rn2ue),'like',d_rn2ue); y2=zeros(size(d_rn2ue),'like',d_rn2ue); y3=zeros(size(d_rn2ue),'like',d_rn2ue); y4=zeros(size(d_rn2ue),'like',d_rn2ue);
for i=1:numel(d_rn2ue) S_ue(i)=P_mbs+G_mbs+G_ue+G_r1+G_r2+G_relay-Lc_mbs-Lc_ue-Li_mbs-Nf_ue-Fl-Lo-Le-PL_rn2ue(i)-FSPL_rn2mbs; RSRP(i)=S_ue(i)-10*log10(1200);
if RSRP(i) > -90
x1(j)=x(i); y1(j)=y(i); j=j+1;
elseif RSRP(i) <= -90 && RSRP(i) >= -105 x2(k)=x(i);
y2(k)=y(i);
k=k+1;
elseif RSRP(i) <= -105 && RSRP(i) >= -120
x3(l)=x(i); y3(l)=y(i); l=l+1;
else
x4(m)=x(i); y4(m)=y(i); m=m+1;
end 
end
j=j-1; k=k-1; l=l-1; m=m-1;
figure scatter(x1(1,1:j),y1(1,1:j),'green','filled'); hold on scatter(x2(1,1:k),y2(1,1:k),'yellow','filled'); hold on
scatter(x3(1,1:l),y3(1,1:l),[],[1 0.5 0],'filled'); hold on scatter(x4(1,1:m),y4(1,1:m),'red','filled'); hold on


scatter(x_rn,y_rn,500,'black','h','filled');
hold off
title('Heatmap RSRP saat jarak antara ARN dengan MBS 41km') 
legend('Sangat Baik','Baik','Cukup','Buruk','UAV');
%Ketinggian optimum vs radius jangkauan
ea_opt=0.3724927987; 
r_max=0:1:5e2; huav_opt=ea_opt*r_max; coverage_circle=r_max.^2*pi;
figure plot(coverage_circle,huav_opt,'LineWidth',2) xlabel('Coverage (m^{2})')
ylabel('Optimum ARN Height')