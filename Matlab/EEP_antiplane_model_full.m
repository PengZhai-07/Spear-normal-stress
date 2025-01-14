%%
clear
close all
figure(1)
set(0,'defaultfigurecolor','w')
set(gcf,'Position',[20 20 1000 600]);%左下角位置，宽高
%%
plot([0 0],[-20,20], 'k', "lineWidth", 2)
hold on
plot([32 32],[-20,20], 'k:', "lineWidth", 2)
plot([0 32],[20,20], 'k:', "lineWidth", 2)
plot([0 32],[-20,-20], 'k:', "lineWidth", 2)
%%
plot([-32 -32],[-20,20], 'k:', "lineWidth", 2)
plot([0 -32],[20,20], 'k:', "lineWidth", 2)
plot([0 -32],[-20,-20], 'k:', "lineWidth", 2)
%%
plot(-3,5,'ko', 'MarkerSize', 20,"lineWidth", 2)
plot(-3,5,'k.', 'MarkerSize', 20,"lineWidth", 2)
plot(3,5,'ko', 'MarkerSize', 20,"lineWidth", 2)
plot(3,5,'kx', 'MarkerSize', 20,"lineWidth", 2)
%%
plot([0 0],[-10,10], 'r', "lineWidth", 2)
plot([-1 1],[10,10], 'k', "lineWidth", 2)
plot([-1 1],[-10,-10], 'k', "lineWidth", 2)
%%
text(8,10,["Antiplane"; "Simple Shear"],"Fontsize",20)
text(-12,-2,["Unstable";"Asperity";"   (VW)"],"Fontsize",20,'rotation',0)
text(-5,15, "VS","FontSize", 20)
text(-5,-15, "VS", "FontSize", 20)
text(1.5,0,"W=5km","F" + ...
    "ontsize",20,'rotation',0)
text(25,0,"10km","Fontsize",20)
text(14,-18,"8km","Fontsize",20)
axis equal
axis off
%%
export_fig png -r600 EEP_antiplane_model