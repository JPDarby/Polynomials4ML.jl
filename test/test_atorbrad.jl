using LinearAlgebra, StaticArrays, Test, Printf
using Polynomials4ML, Polynomials4ML.Testing
using Polynomials4ML: evaluate, evaluate_d, evaluate_ed 
using Polynomials4ML.Testing: print_tf, println_slim 
using ForwardDiff
using ACEbase.Testing: fdtest
using Zygote

P4ML = Polynomials4ML

##

@info("Testing GaussianBasis")
n1 = 5 # degree
n2 = 3 
Pn = P4ML.legendre_basis(n1+1)
spec = [(n1 = n1, n2 = n2, l = l) for n1 = 1:n1 for n2 = 1:n2 for l = 0:n1-1] 
ζ = rand(length(spec))
Dn = GaussianBasis(ζ)
bRnl = AtomicOrbitalsRadials(Pn, Dn, spec) 
rr = 2 * rand(10) .- 1
Rnl = evaluate(bRnl, rr)
Rnl1, dRnl1 = evaluate_ed(bRnl, rr)
Rnl2, dRnl2, ddRnl2 = evaluate_ed2(bRnl, rr)


fdRnl = vcat([ ForwardDiff.derivative(r -> evaluate(bRnl, [r,]), r) 
               for r in rr ]...) 
fddRnl = vcat([ ForwardDiff.derivative(r -> evaluate_ed(bRnl, [r,])[2], r)
               for r in rr ]...) 

println_slim(@test  Rnl ≈ Rnl1 ≈ Rnl2 )
println_slim(@test  dRnl1 ≈ dRnl2 ≈ fdRnl )
println_slim(@test  ddRnl2 ≈ fddRnl )
 
P4ML.Testing.test_derivatives(bRnl, () -> 2 * rand() - 1)

##

@info("Testing SlaterBasis")
n1 = 5 # degree
n2 = 3 
Pn = Polynomials4ML.legendre_basis(n1+1)
spec = [(n1 = n1, n2 = n2, l = l) for n1 = 1:n1 for n2 = 1:n2 for l = 0:n1-1] 
ζ = rand(length(spec))

Dn = SlaterBasis(ζ)
bRnl = AtomicOrbitalsRadials(Pn, Dn, spec) 
rr = 2 * rand(10) .- 1
Rnl = evaluate(bRnl, rr)
Rnl1, dRnl1 = evaluate_ed(bRnl, rr)
Rnl2, dRnl2, ddRnl2 = evaluate_ed2(bRnl, rr)


fdRnl = vcat([ ForwardDiff.derivative(r -> evaluate(bRnl, [r,]), r) 
               for r in rr ]...) 
fddRnl = vcat([ ForwardDiff.derivative(r -> evaluate_ed(bRnl, [r,])[2], r)
               for r in rr ]...) 

println_slim(@test  Rnl ≈ Rnl1 ≈ Rnl2  )
println_slim(@test  dRnl1 ≈ dRnl2 ≈ fdRnl )
println_slim(@test  ddRnl2 ≈ fddRnl )

P4ML.Testing.test_derivatives(bRnl, () -> 2 * rand() - 1)

##

@info("Testing STOBasis")
n1 = 5 # degree
n2 = 1
Pn = Polynomials4ML.legendre_basis(n1+1)
spec = [(n1 = n1, n2 = n2, l = l) for n1 = 1:n1 for n2 = 1:1 for l = 0:n1-1] 
M = 3
ζ = (rand(length(spec), M),rand(length(spec), M))
Dn = STO_NG(ζ)
bRnl = AtomicOrbitalsRadials(Pn, Dn, spec) 
rr = 2 * rand(10) .- 1
Rnl = evaluate(bRnl, rr)
Rnl1, dRnl1 = evaluate_ed(bRnl, rr)
Rnl2, dRnl2, ddRnl2 = evaluate_ed2(bRnl, rr)

fdRnl = vcat([ ForwardDiff.derivative(r -> evaluate(bRnl, [r,]), r) 
               for r in rr ]...) 
fddRnl = vcat([ ForwardDiff.derivative(r -> evaluate_ed(bRnl, [r,])[2], r)
               for r in rr ]...) 

println_slim(@test  Rnl ≈ Rnl1 ≈ Rnl2  )
println_slim(@test  dRnl1 ≈ dRnl2 ≈ fdRnl )
println_slim(@test  ddRnl2 ≈ fddRnl )

P4ML.Testing.test_derivatives(bRnl, () -> 2 * rand() - 1)


##

@info("Test rrule")
using LinearAlgebra: dot 

for ntest = 1:30
    local rr
    local uu
    local Rnl
    local u
    
    rr = 2 .* randn(10) .- 1
    uu = 2 .* randn(10) .- 1
    _rr(t) = rr + t * uu
    Rnl = evaluate(bRnl, rr)
    u = randn(size(Rnl))
    F(t) = dot(u, evaluate(bRnl, _rr(t)))
    dF(t) = begin
        val, pb = Zygote.pullback(evaluate, bRnl, _rr(t))
        ∂BB = pb(u)[2] # pb(u)[1] returns NoTangent() for basis argument
        return sum( dot(∂BB[i], uu[i]) for i = 1:length(uu) )
    end
    print_tf(@test fdtest(F, dF, 0.0; verbose = false))
end
println()
