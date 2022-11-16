using DelimitedFiles
using LinearAlgebra
using StatsPlots

using Plots
using PyPlot
using StatsBase
using LaTeXStrings
using PyCall
mpl = pyimport("matplotlib")

# Default plot params
function plot_params()
  plt.rc("xtick", labelsize=16)
  plt.rc("ytick", labelsize=16)
  plt.rc("xtick", direction="in")
  plt.rc("ytick", direction="in")
  plt.rc("font", size=15)
  plt.rc("figure", autolayout="True")
  plt.rc("axes", titlesize=16)
  plt.rc("axes", labelsize=17)
  plt.rc("xtick.major", width=1.5)
  plt.rc("xtick.major", size=5)
  plt.rc("ytick.major", width=1.5)
  plt.rc("ytick.major", size=5)
  plt.rc("lines", linewidth=2)
  plt.rc("axes", linewidth=1.5)
  plt.rc("legend", fontsize=13)
  plt.rc("mathtext", fontset="stix")
  plt.rc("font", family="STIXGeneral")
  plt.rc("font",size=12)

  # Default width for Nature is 7.2 inches, 
  # height can be anything
  #plt.rc("figure", figsize=(7.2, 4.5))

end


# plot the nucleation size information in a figure

# multiple = [4.0,5.0,6.0,7.0]
# cos_reduction = [0.05,0.06,0.07,0.08]
b = [0.019,0.021,0.023,0.025]

fig = PyPlot.figure(figsize=(7.2, 6));
ax = fig.add_subplot(111)

    for i = 1: length(b)

        FILE = "20000_500_8_0.8_0.0_5_1.0_$(b[i])"   # normal stress testing
        println(FILE)
        
        out_path = "$(@__DIR__)/plots/velocity_dependence_b/$(FILE)/"

        NS_width = readdlm(string(out_path, "nucleation info.out"), header=false)

        bb = zeros(length(NS_width[:,1]))
        bb[:] .= b[i]
        
        ax.plot(bb[:], NS_width[:,2] , "o", color="blue", markersize=10)

    end
ax.set_xlabel("b")
ax.set_ylabel("Nucleation size (km)")
ax.set_ylim([0,6])
ax.set_xlim([0.018,0.026])
# # # healing analysis: Vfmax and regidity ratio vs. time
#healing_analysis(Vfmax, alphaa, t, yr2sec)
path = "$(@__DIR__)/plots/velocity_dependence_b/"        
figname = string(path, "Nucleation size statistics_0.7.png")
fig.savefig(figname, dpi = 600)
show()























# event_stress = readdlm(string(out_path, "event_stress.out"), header=false)
# indx = Int(length(event_stress[1,:])/2)
# # println(length(event_stress[1,:]))  # 962
# # println(indx)          # 481
# taubefore = event_stress[:,1:indx]
# tauafter = event_stress[:,indx+1:end]

# # coseismic slip on fault for all different events(row)
# delfafter = readdlm(string(out_path, "coseismic_slip.out"), header=false)
# # print(size(delfafter))
# sliprate = readdlm(string(out_path, "sliprate.out"), header=false)
# #
# # println(size(delfafter,1))
# # println(size(delfafter,2))

# stress = readdlm(string(out_path, "stress.out"), header=false)

# start_index = get_index(stress', taubefore')
# stressdrops = taubefore .- tauafter


#         # Index of fault from 0 to 18 km
#         flt18k = findall(FltX .<= 18)[1]

#         time_vel = readdlm(string(out_path, "time_velocity.out"), header=false)
#         t = time_vel[:,1]
#         Vfmax = time_vel[:,2]
#         Vsurface = time_vel[:,3]
#         alphaa = time_vel[:,4]