# Assembly of global stiffness matrix as a sparse matrix

function Kassemble(NGLL, NelX, NelY, dxe,dye, nglob, iglob, W) 
    xgll, wgll, H::SMatrix{NGLL,NGLL,Float64} = GetGLL(NGLL)
    wgll2::SMatrix{NGLL,NGLL,Float64} = wgll*wgll'

    
    #  ig::Matrix{Int64} = zeros(NGLL,NGLL)  # iterator

    #  W = material_properties(NelX, NelY,NGLL,dxe, dye, ThickX, ThickY, wgll2, rho1, rho2, vs1, vs2)
    Ke = K_element(W, dxe, dye, NGLL, H, NelX*NelY)  # complete stiffness Matrix
    println("the dimension of stiffness for each element is",size(Ke))
    #  Ks22 = assembley(Ke, iglob, NelX*NelY, nglob)
    K = FEsparse(NelX*NelY, Ke, iglob)    # return Sparse matrix K!!
    return dropzeros!(K)      # from   SparseArrays: only return nonzero elements and locations of them
    #  return rcmpermute(dropzeros!(K))
end

# vec: 将指定数组重塑为一维列向量，即一维数组
function FEsparse(Nel, Ke, iglob)
    K = SparseMatrixCOO()   # Construct sparse matrix  
    # using FEMSparse
    for eo in 1:Nel
        FEMSparse.assemble_local_matrix!(K, vec(iglob[:,:,eo]),
                                    vec(iglob[:,:,eo]), Ke[:,:,eo])
    end
    SparseMatrixCSC(K)
end

# Nel = NelX*NelY
function K_element(W, dxe, dye, NGLL, H, Nel)
    # Jacobians
    dx_dxi::Float64 = 0.5*dxe
    dy_deta::Float64 = 0.5*dye
    jac::Float64 = dx_dxi*dy_deta

    ww::Matrix{Float64} = zeros(NGLL, NGLL)
    Ke2::Array{Float64,4} = zeros(NGLL,NGLL,NGLL,NGLL)
    Ke::Array{Float64,3} = zeros(NGLL*NGLL,NGLL*NGLL, Nel)
    #  ig::Matrix{Int64} = zeros(NGLL,NGLL)  # iterator
    
    #  term1::Float64 = 0.; term2::Float64 = 0.
    del = Matrix{Float64}(I,NGLL,NGLL)  # identity matrix

        @inbounds for eo in 1:Nel
            Ke2 .= 0.

            ww = W[:,:,eo]
            term1 = 0.; term2 = 0.
            for i in 1:NGLL, j in 1:NGLL
                for k in 1:NGLL, l in 1:NGLL
                    term1 = 0.; term2 = 0.
                    for p in 1:NGLL      # degree of lagrange polynomial
                        
                        term1 += del[i,k]*ww[k,p]*(jac/dy_deta^2)*H[j,p]*H[l,p]   # eta, eta    i=k=p
                        term2 += del[j,l]*ww[p,j]*(jac/dx_dxi^2)*H[i,p]*H[k,p]    # ksi,ksi     q=j=l
                        # The specific form can refer to page 20 of SEM-notes by Ampuero, 2011
                    end
                    
                    Ke2[i,j,k,l] = term1 + term2
                end
            end
            Ke[:,:,eo] = reshape(Ke2,NGLL*NGLL,NGLL*NGLL)    # 25*25 !!
        end
    return Ke
end

# My naive approach
#  function assembley_2(Ke, iglob, Nel, nglob)
    #  Ksparse::SparseMatrixCSC{Float64} = spzeros(nglob,nglob) 
    #  for eo in 1:Nel
        #  ig = iglob[:,:,eo]
        #  Ksparse[vec(ig),vec(ig)] += Ke[:,:,eo]
    #  end

    #  Ksparse
#  end


# faster assembly approach: just as fast as FESparse
#  function assembley(Ke, iglob, Nel, nglob)
    #  #  Ksparse::SparseMatrixCSC{Float64} = spzeros(nglob,nglob) 
    #  I = Vector{Int}(undef, length(Ke))
    #  J = Vector{Int}(undef, length(Ke))
    #  V = Vector{Float64}(undef, length(Ke))
    #  ct = 1

    #  for eo in 1:Nel
        #  v = view(iglob,:,:,eo)
        #  #  v = iglob[:,:,eo][:]
        #  for j in 1:length(v)
            #  for i in 1:length(v)
                #  I[ct] = v[i]
                #  J[ct] = v[j]
                #  V[ct] = Ke[i, j, eo]
                #  ct += 1
                #  #  Ksparse[vec(ig),vec(ig)] += Ke[:,:,eo]
            #  end
        #  end
    #  end

    #  return sparse(I,J,V,nglob,nglob,+)
#  end

