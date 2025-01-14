%%
clear
clc
close all

%%
res = 16;
gamma = pi/4;  % empirical constant parameter about geometry
mu = 3.20e10;  % Pa 
sigma = 40e6;  % Pa
a = 0.015;
a_b = 0.05:0.05:0.95;
T = zeros(1,length(a_b));
nT = zeros(1,length(a_b));
b = a./a_b;
r = 1;   % the shear wave reduction=20%  1-0.2=0.8  r is the rigidity ratio
% LL = linspace(log10(0.5),log10(125),25);  % m
% L = 10.^(LL);
% L = [0.5,0.6,0.8,1,1.3,1.5,2,2.5,3,4,5,6,8,10,12,16,20,25,30,40,50,63,80,100,125]*10^-3;
L = [0.5,0.6,0.8,1,1.3,1.5,2,2.5,3,4,5,6,8,10,12,16,20,25,30,40,50,63,80,100,125,160,200,250,300,400,500,630,800,1000]*10^-3;
%L = [0.5, 1.3, 4, 12, 40, 125]*10^-3;       % m
%H = [250, 500, 1000, 1500, 2000];      % m  half-width of damage zone
H = 0;    % half-width
NS = zeros(length(r),length(L),length(H));
W = 5000;    % unit:m
m = 0; n=0; q=0;
for i = 1:length(b)
        % define the simulation time for different a/b
    if a_b(i)<=0.21
        T(i) = 1500;
    elseif (0.24<=a_b(i)) && (a_b(i)<=0.36)
        T(i) = 1200;
    elseif (0.39<=a_b(i)) && (a_b(i)<=0.56)
        T(i) = 900;
    elseif (0.59<=a_b(i)) && (a_b(i)<=0.71)
        T(i) = 600;
    elseif (0.74<=a_b(i)) && (a_b(i)<=0.86)
        T(i) = 300;
    else
        T(i) = 100;
    end
    mu_D = mu;  % Pa
    for j = 1:length(L)   
        for k = 1:length(H)
            %syms y
            %exp = W/y*tanh(2*gamma*H(k)/W*y+atanh(mu_D/mu)) -...
               %2/pi*mu_D*L(j)*b(i)/sigma/(b(i)-a)^2;       % Rubin and Ampuero for a/b>0.5
% %                 exp = y*tanh(2*gamma*H(k)/y+atanh(mu_D(i)/mu)) -...
% %                  pi/4*mu_D(i)*L(j)/sigma/(b-a);
% %                exp = 1/y*tanh(2*H(k)*gamma/W*y+atanh(mu_D/mu)) -...
% %                        mu_D*L(j)/sigma/(a/a_b(i)-a)/W;    % without pi/4? 
            %y = double(vpasolve(exp,[0,1000000000])) ;
            y = 1.3774*mu_D*L(j)/b(i)/sigma;                        % Rubin and Ampuero for a/b<0.3781
            Ru(i,j,k) = y;
            kk = mu/W*2/pi;     % for antiplane shear strain with constant slip
            C_1(i,j,k) = b(i)/a*(1-kk*L(j)/b(i)/sigma);     % with equation (17) and kk= G*neta/L
            Cohesive(i,j,k) = (9*pi/32)*mu_D*r*L(j)/b(i)./sigma;
        
            if (y>=1) && (Cohesive(i,j,k) > 400/res*3)                                
                if y > 10
                    nT = 200;
                elseif y > 5
                    nT = 800;
                else
                    nT = 1500;
                end
                m = m+1;
                P_1(m,:) = [log10(L(j)*1000), a_b(i), L(j),b(i), T(i), nT];     % resolution is enough
            elseif (y>=1) && (Cohesive(i,j,k) <= 400/res*3)
                n = n+1;
                P_2(n,:) = [log10(L(j)*1000), a_b(i), L(j),b(i), T(i)];
            elseif y<1 && (y>0.5)
                q = q+1;
                P_3(q,:) = [log10(L(j)*1000), a_b(i), L(j),b(i), T(i)];
            end
        end
    end
end
% Ru = W./NS;
[Y,X] = meshgrid(a_b, log10(L*1000));
% A = pcolor(X,Y,Ru');
% v = [2,3,7.5,18.35,56.4,88];
% v = [2,3,5,10,15,20,30,40,50,60,70,80,100,200,400];

figure(1)
set(0,'defaultfigurecolor','w')
set(gcf,'Position',[20 20 1400 800]);%左下角位置，宽高
pcolor(X,Y,C_1')
hold on
shading interp
colormap(summer)
clim([min(min(C_1)),max(max(C_1))])
c = colorbar;
ylabel(c, 'C1')
v = [1,1.75,3.0];
[c,h]=contour(X,Y,C_1',v);
clabel(c,h)
set(h,"color","blue")
% different nucleation style
% fixed length
row_fl = [69:84,85:100,101:115,117:129,131:140,144:151,157:162,168:172, 179:182, 188:189]+19;
scatter(P_1(row_fl,1), P_1(row_fl,2),'*','r' )
% constant weakening
row_cw = [116,130,141:143,152:156,163:167, 173:178,183:187, 190:195, 196:204]+19;
scatter(P_1(row_cw,1), P_1(row_cw,2),'*','b' )
% other cases
scatter(P_2(:,1),P_2(:,2) ,'^','r' )    % resolution limit
scatter(P_3(:,1),P_3(:,2) ,'o','r' )   %  no normal earthquakes
v = [0.1,0.5,1,3.7, 7.5, 18];
[c,h]=contour(X,Y,Ru',v);
clabel(c,h)
set(h,"color","black")
xticks([log10(L*1000)])
xticklabels([0.5,0.6,0.8,1,1.3,1.5,2,2.5,3,4,5,6,8,10,12,16,20,25,30,40,50,63,80,100,125,160,200,250,300,400,500,630,800,1000])
yticks([0.05:0.05:0.35,0.3781,0.4:0.05:0.95])
yticklabels([0.05:0.05:0.35,0.3781,0.4:0.05:0.95])
set(gca,'XDir','reverse');        %将x轴方向设置为反向(从右到左递增)。
%set(gca,'YDir','reverse');        %将x轴方向设置为反向(从右到左递增)。
xlabel('D_{c}(mm)')
ylabel('a/b')
box on
%% rupture style
text(log10(80),0.32,"Symmetric-bilateral",'Rotation',40)
text(log10(40),0.32,["Unsymmetric-";"bilateral";"and unilateral"],'Rotation',40)
text(log10(20),0.32,"Full and partial",'Rotation',40)
text(log10(10),0.32,"Crack-like with aftershocks ",'Rotation',40)
%% output the model parameter file for seisic events
fid  = fopen('../../whole_space.txt','wt');
[u, v] = size(P_1);
u
for i =1:u
      fprintf(fid, ['0.25,',num2str(res),',',num2str(P_1(i,5)),',0,0,1.0,0.0,4,',num2str(P_1(i,2)),',',num2str(P_1(i,3)),',',num2str(P_1(i,6)),'\n']);     
end
fclose(fid);

%% output the model parameter file for SSES and Creep
fid  = fopen('../../SSE_Creep.txt','wt');
[u, v] = size(P_3);
u
for i =1:u
      fprintf(fid, ['0.25,',num2str(res),',',num2str(P_3(i,5)),',0,0,1.0,0.0,4,',num2str(P_3(i,2)),',',num2str(P_3(i,3)),'\n']);     
end
fclose(fid);


%%
% yy = a./[0.018,0.019,0.020,0.021,0.022,0.023,0.025,0.027,0.029, 0.031];
% xx = log10(10)*ones(1,length(yy));
% for i = 1:length(yy)
%     if  yy(i) > a/0.022    
%         ifz yy(i) > a/0.021
%             scatter(xx(i),yy(i),'*','r')      % bilateral and expanding
%         else
%             scatter(xx(i),yy(i),'*','b')      % bilateral and fixed length
%         end
%     elseif yy(i) > a/0.030
%          scatter(xx(i),yy(i),'o','b')      % unilateral and fixed length
%     else
%         scatter(xx(i),yy(i),'^','b')      % partial and fixed length
%     end
% end
% xxx_1 = [3, 4, 6, 8, 10, 12, 16, 20, 25];
% yy_1 = a./0.021*ones(1,length(xxx_1));
% xx_1 = log10(xxx_1);
% for i = 1:length(xx_1)
%     if  xxx_1(i) > 6
%         if  xxx_1(i) >10 || xxx_1(i)==8
%             scatter(xx_1(i),yy_1(i),'*','r')  % bilateral and expanding
%         else
%             scatter(xx_1(i),yy_1(i),'*','b')  % bilateral and fixed length
%         end
%     elseif xxx_1(i) > 3
%         scatter(xx_1(i),yy_1(i),'o','b')  % unilateral and fixed length
%     else
%         scatter(xx_1(i),yy_1(i),'^','b')  % partial and fixed length
%     end
% end
% xxx_2 = [2, 2.5, 3, 4, 6, 8, 10, 12, 16];
% yy_2 = a./0.019*ones(1,length(xxx_2));
% xx_2 = log10(xxx_2);
% for i = 1:length(xx_2)
%     if  xxx_2(i) > 4   
%         scatter(xx_2(i),yy_2(i),'*','r')  % bilateral and expanding
%     elseif xxx_2(i) == 4    
%         scatter(xx_2(i),yy_2(i),'o','r')  % unilateral and expanding
%     elseif xxx_2(i) > 2            
%         scatter(xx_2(i),yy_2(i),'o','b')  % unilateral and fixed length
%     else
%         scatter(xx_2(i),yy_2(i),'^','b')  % partial and fixed length 
%     end
% end

% title([num2str(H)])
%%  m = m+1;
%                 P(m,:) = [log10(L(j)*1000), a_b(i), L(j),b(i)];
% %             en
export_fig -dpng -r600 Ru_b_Dc_Rubin_Ampuero

%% output the bash script for sbatch in Great lakes

%%
% fid  = fopen('../whole_space.sh','wt');%
% fprintf(fid,'#!/bin/bash\n\n');    
% [u, v] = size(P);
% N = 1;
% nn = 4;  % number of processors for each node
% 
% fprintf(fid,['#SBATCH --array=',num2str(N),'-',num2str(N+u-1),'\n']);
% fprintf(fid,'#SBATCH --nodes=1\n');   % only one node because current MPI doesn't work
% fprintf(fid,'#SBATCH --mem=10000m\n'); 
% fprintf(fid,'#SBATCH --time=14-00:00:00\n');
% fprintf(fid,'#SBATCH --partition=standard\n');
% fprintf(fid,'#SBATCH --account=yiheh1\n');   
% fprintf(fid,['#SBATCH --ntasks-per-node=',num2str(nn),'\n']);    % multitask(openmp)   cpu for each job
% fprintf(fid,['#SBATCH --job-name=case',num2str(N),'_',num2str(N+u-1),'\n']);
% fprintf(fid,'#SBATCH --output=/home/%%u/log/%%x-%%j.log\n');
% fprintf(fid,'#SBATCH --error=/home/%%u/log/error-%%x-%%j.log\n\n');
% 
% 
% % information about output path
% project = "wholespace/phase_diagram_L_b/";
% FZdepth = "0_";
% halfwidth = "500_";
% res = "16_";
% alpha = "0.8_";
% cos_reduction = "0.0_";
% multiple = "4_";
% Domain = "0.75_";
% coseismic_b = "0.03_";
% Lc = "0.012";
% current_Folder = pwd;
% 
% % for i = 1:u
% %     fprintf(fid,['julia --threads ',num2str(nn),' run.jl 0.8 500 ',num2str(P(i,3)),' 4 0.00 ',num2str(P(i,4)),'\n']);
% %     out_dir = strcat(current_Folder,"/../data/",project,FZdepth,halfwidth,res,alpha,cos_reduction,multiple,Domain,num2str(P(i,4)),'_',num2str(P(i,3)));
% %     if  exist(out_dir)
% %         rmdir(out_dir)
% %     end
% %     mkdir(out_dir)
% % end
% 
% fprintf(fid,['julia --threads ',num2str(nn),' run.jl 0.8 500 ','$SLURM_ARRAY_TASK_ID',' 4 0.00 ','$SLURM_ARRAY_TASK_ID','\n']);
% 
% fclose(fid);

% %% output the model parameter file
% 
% fid  = fopen('../whole_space.txt','wt');
% [u, v] = size(P);
% for i =1:u
%     fprintf(fid, ['0.8,500,',num2str(P(i,3)),',4,0.00,',num2str(P(i,4)),'\n']);       %  alpha, halfwidth, Lc, multiple, cos_reduction, coseismic_b
% end
% fclose(fid);
% 

% 0.8 500 0.012 4 0.00 0.03