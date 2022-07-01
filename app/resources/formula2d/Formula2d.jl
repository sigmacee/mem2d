module Formula2d

using SparseArrays,Arpack
using GR: delaunay

#=
有限元求解平面规则形状膜的振动频率
假定: 1.膜的初始形为2D,, 即所有节点的 z坐标为0
           2.膜的周边固定
		   3.各个单元的物理参数一至
=#

export MPara

Base.@kwdef mutable struct MPara
	E::Float64 = 2.07e11
	LOU::Float64  = 7.805
	S::Float64  = 13800.0
	fi::Int = 10
end

#=
export 膜参数

Base.@kwdef mutable struct 膜参数
	E::Float64 = 2.07e11
	LOU::Float64  = 7.805
	S::Float64  = 13800.0
	fi::Int = 10
end
=#

abstract type Shape2d end
# abstract type 平面形 end


struct Line2d <: Shape2d
	A::Float64                 # (0,0) is the first point, A is the second point's x
    B::Float64                 # B is the second point's y. The line is (0,0) to (A,B)
    N::Int64	                 # The line has N+1 nodes
	function Line2d(A,B,N)
	    # some init values
		if N<10;N=10;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,N)
	end
	function Line2d(A,B,N,M)
		Line2d(A,B,N)
	end
end

#=
struct 直线 <: 平面形
	A::Float64  
    B::Float64                 #直角边长A,B
    N::Int64	
	function 直线(A,B,N)
	    # 初始值
		if N<10;N=10;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,N)
	end
	function 直线(A,B,N,M)
		直线(A,B,N)
	end
end
=#

struct Triangle2d <: Shape2d
    A::Float64  
    B::Float64                 #the triangle's HL : A,B
    N::Int64	                 # the HL has N+1 nodes
	function Triangle2d(A,B,N)
	    # init values
		if N<4;N=4;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,N)
	end
	function Triangle2d(A,B,N,M)
		Triangle2d(A,B,N)
	end
end

#=
struct 三角 <: 平面形
    A::Float64  
    B::Float64                 #直角边长A,B
    N::Int64	
	function 三角(A,B,N)
	    # 初始值
		if N<4;N=4;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,N)
	end
	function 三角(A,B,N,M)
		三角(A,B,N)
	end
end
=#

struct Circle2d <: Shape2d      
    R::Float64                 # radius
    N::Int64	                 # the radius has N+1 nodes
	function Circle2d(R,N)
	    # init values
		if N<4;N=4;end
		if R<=0.0;R=1.0;end
		new(R,N)
	end
	function Circle2d(A,B,N,M)
		Circle2d(A,N)
	end
end

#=
struct 圆形 <: 平面形      
    R::Float64                 #半径
    N::Int64	
	function 圆形(R,N)
	    # 初始值
		if N<4;N=4;end
		if R<=0.0;R=1.0;end
		new(R,N)
	end
	function 圆形(A,B,N,M)
		圆形(A,N)
	end
end
=#

struct Sector2d <: Shape2d      
    R::Float64                 # radius
	A::Float64                 # angle
    N::Int64		             # the radius has N+1 nodes
	function Sector2d(R,A,N)
	    # init values
		if N<4;N=4;end
		if R<=0.0;R=1.0;end
		if A<=0.0;A=30.0;end
		if A >=360.0;A=330.0;end
		new(R,A,N)
	end
	function Sector2d(A,B,N,M)
		Sector2d(A,B,N)
	end
end

#=
struct 扇形 <: 平面形      
    R::Float64                 # 半径
	A::Float64                 # 角度
    N::Int64		
	function 扇形(R,A,N)
	    # 初始值
		if N<4;N=4;end
		if R<=0.0;R=1.0;end
		if A<=0.0;A=30.0;end
		if A >=360.0;A=330.0;end
		new(R,A,N)
	end
	function 扇形(A,B,N,M)
		扇形(A,B,N)
	end
end
=#

struct Rectangle2d <: Shape2d
    A::Float64  
    B::Float64                 # side A,B
    NA::Int64                   # side A has NA+1 nodes
	NB::Int64                   # side B has NB+1 nodes
	function Rectangle2d(A,B,NA,NB)
	    # some init values
		if NA<4;NA=4;end
		if NB<4;NB=4;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,NA,NB)
	end	
end

#=
struct 矩形 <: 平面形
    A::Float64  
    B::Float64                 # 直角边长A,B
    NA::Int64
	NB::Int64
	function 矩形(A,B,NA,NB)
	    # 初始值
		if NA<4;NA=4;end
		if NB<4;NB=4;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,NA,NB)
	end	
end
=#

struct Trapezoid2d <: Shape2d
    A::Float64  
    B::Float64                 # right-angleed trapezoid, top  A,  bottom B
	C::Float64                 # high
    NA::Int64                   # top A has NA+1 nodes
	NB::Int64
	function Trapezoid2d(A,B,C,NA,NB)
	    # init values
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		if C<=0.0;C=1.0;end
		if A<=B;A=A+B;end		
		if NB<4;NB=4;end
        NA = Int(round((B / (A - B)) * NB + 0.5))
		if NA < 4;NA=4;end
		new(A,B,C,NA,NB)
	end	
end

#=
struct 梯形 <: 平面形
    A::Float64  
    B::Float64                 #直角梯形例子, 上下边长A,B
	C::Float64                 #高
    NA::Int64
	NB::Int64
	function 梯形(A,B,C,NA,NB)
	    # 初始值
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		if C<=0.0;C=1.0;end
		if A<=B;A=A+B;end		
		if NB<4;NB=4;end
        NA = Int(round((B / (A - B)) * NB + 0.5))
		if NA < 4;NA=4;end
		new(A,B,C,NA,NB)
	end	
end
=#

struct Lshape2d <: Shape2d
    A::Float64  
    B::Float64                 #side A,B
    NA::Int64
	NB::Int64
	function Lshape2d(A,B,NA,NB)
	    # init values
		NA = (NA  ÷ 2) * 2    # keep A,B be even segments
		NB = (NB  ÷ 2) * 2
		if NA<4;NA=4;end
		if NB<4;NB=4;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,NA,NB)
	end	
end

#=
struct L形 <: 平面形
    A::Float64  
    B::Float64                 #直角边长A,B
    NA::Int64
	NB::Int64
	function L形(A,B,NA,NB)
	    # 初始值
		NA = (NA  ÷ 2) * 2    # 保证分成偶数格
		NB = (NB  ÷ 2) * 2
		if NA<4;NA=4;end
		if NB<4;NB=4;end
		if A<=0.0;A=1.0;end
		if B<=0.0;B=1.0;end
		new(A,B,NA,NB)
	end	
end
=#

struct Memb2d  <: Shape2d
    X::Array{Float64,1}
    Y::Array{Float64,1}        # mesh with N, side has nodes : N+1, and all nodes coordinate : X,Y
	Z::Array{Float64,1}
    #D::Array{Array{Int64,1},1}     # nodes No. array, from 1 around side A to ...
	E::Array{Array{Int64,1},2}     # element array, basicly triangle element with 3-node or rectangle with 4-node
	F::Array{Int64,1}          # node`s solving flag 
	S::Int64                   # how many nodes that flag > 0
    function Memb2d(sh::Shape2d, node = 4)
		# init
		X,Y,Z,E,F,S=mesh2d(sh,node )
        new(X,Y,Z,E,F,S)
    end
	#=
	function Memb2d(sh::Triangle2d,double::Function)
		X,Y,Z,E,F,S=double(sh)
        new(X,Y,Z,E,F,S)	
	end
	function Memb2d(sh::Rectangle2d,double::Function)
		X,Y,Z,E,F,S=double(sh)
        new(X,Y,Z,E,F,S)	
	end
	=#
	function Memb2d(sh::Shape2d,double::Function, node = 4)
		X,Y,Z,E,F,S=double(sh, node )
        new(X,Y,Z,E,F,S)	
	end	
	function Memb2d(X,Y,Z,E,F,S)
		if length(X) < 3; X = [0.0,1.0,0.0]; end
		if length(Y) < 3 || length(Y) != length(X); Y = [0.0,0.0,1.0]; end
		Z = zeros(size(X))                # 2d shape
		if size(E) == (); E = [[1,2,3]];end		
		if length(F) != length(X); F = zeros(Int,size(X));end
		if S < 0; S = 0;end
		E = reshape(E,:,1)
		new(X,Y,Z,E,F,S)		
	end
end

#=
struct 膜  <: 平面形
    X::Array{Float64,1}
    Y::Array{Float64,1}        #网格数N，直角边上节点数为N+1,边上各节点坐标X,Y
	Z::Array{Float64,1}
    #D::Array{Array{Int64,1},1} #节点编号数组，从1按A边顺序排列
	E::Array{Array{Int64,1},2} #基本三角单元
	F::Array{Int64,1}          # 求解标志
	S::Int64                   # 需求解节点数
    function 膜(形::平面形, node = 4)
		# 初始值
		X,Y,Z,E,F,S=网格(形,node )
        new(X,Y,Z,E,F,S)
    end
	#=
	function 膜(形::三角,双倍::Function)
		X,Y,Z,E,F,S=双倍(形)
        new(X,Y,Z,E,F,S)	
	end
	function 膜(形::矩形,双倍::Function)
		X,Y,Z,E,F,S=双倍(形)
        new(X,Y,Z,E,F,S)	
	end
	=#
	function 膜(形::平面形,双倍::Function, node = 4)
		X,Y,Z,E,F,S=双倍(形, node )
        new(X,Y,Z,E,F,S)	
	end	
	function 膜(X,Y,Z,E,F,S)
		if length(X) < 3; X = [0.0,1.0,0.0]; end
		if length(Y) < 3 || length(Y) != length(X); Y = [0.0,0.0,1.0]; end
		Z = zeros(size(X))      # 平面
		if size(E) == (); E = [[1,2,3]];end		
		if length(F) != length(X); F = zeros(Int,size(X));end
		if S < 0; S = 0;end
		E = reshape(E,:,1)
		new(X,Y,Z,E,F,S)		
	end
end
=#

function mesh2d(line::Line2d, node = 2)
	A,B,N=line.A,line.B,line.N
	# get all nodes
    x=collect(range(0.0,stop=A,length=N+1))
    y=collect(range(0.0,stop=B,length=N+1))
	c=[collect(1:N) collect(2:N+1)]
	E=reshape([i[:] for i in eachrow(c)],:,1)
	F=ones(Int,size(x))
	F[1] = 0;F[end] = 0       # the first node and the last node are fixed
	S=sum(F);F[F.>0]=collect(1:S)
	z=zeros(size(x))
	return x,y,z,E,F,S	
end

#=
function 网格(直线::直线, node = 2)
	A,B,N=直线.A,直线.B,直线.N
	# 求所有节点
    x=collect(range(0.0,stop=A,length=N+1))
    y=collect(range(0.0,stop=B,length=N+1))
	c=[collect(1:N) collect(2:N+1)]
	E=reshape([i[:] for i in eachrow(c)],:,1)
	F=ones(Int,size(x))
	F[1] = 0;F[end] = 0
	S=sum(F);F[F.>0]=collect(1:S)
	z=zeros(size(x))
	return x,y,z,E,F,S	
end
=#

function mesh2d(triangle::Triangle2d, node = 3)
	A,B,N=triangle.A,triangle.B,triangle.N
	# mesh and get all nodes
    x=collect(range(0.0,stop=A,length=N+1))
    y=collect(range(0.0,stop=B,length=N+1))
    D=[[i*(N+1)-sum(collect(0:i-1))+1+j for j in 0:N-i] for i in 0:N]
	# get all triangle elements with 3-node
	m=N+1		
	c=[[D[i][j],D[i][j+1],D[i+1][j]] for i in 1:m for j in 1:m-i]
	d=[[D[i-1][j+1],D[i][j+1],D[i][j]] for i in 2:m-1 for j in 1:m-i]
	E=[reshape(c,:,1);reshape(d,:,1)]
	# around the triangle, three sides are fixed
	F=D;F[1].=0;F[end].=0
	for f in F;f[1],f[end]=0,0;f[f.>0].=1;end
	F=vcat(F...);S=sum(F);F[F.>0]=collect(1:S)
	# get all nodes coordinate 	
	#X=[x[j] for i in 1:length(D) for j in 1:length(D[i])]
	#Y=[y[i] for i in 1:length(D) for j in 1:length(D[i])]
	K=hcat([[x[j],y[i],0.0] for i in 1:length(D) for j in 1:length(D[i])]...)
	# return nodes coordinate array, elements array, solving-flag arrat,  the number of nodes need to solve
	return K[1,:],K[2,:],K[3,:],E,F,S
end

#=
function 网格(三角::三角, node = 3)
	A,B,N=三角.A,三角.B,三角.N
	# 求所有节点
    x=collect(range(0.0,stop=A,length=N+1))
    y=collect(range(0.0,stop=B,length=N+1))
    D=[[i*(N+1)-sum(collect(0:i-1))+1+j for j in 0:N-i] for i in 0:N]
	# 求基本三角单元，三节点
	m=N+1		
	c=[[D[i][j],D[i][j+1],D[i+1][j]] for i in 1:m for j in 1:m-i]
	d=[[D[i-1][j+1],D[i][j+1],D[i][j]] for i in 2:m-1 for j in 1:m-i]
	E=[reshape(c,:,1);reshape(d,:,1)]
	# 求周边固定的边界条件
	F=D;F[1].=0;F[end].=0
	for f in F;f[1],f[end]=0,0;f[f.>0].=1;end
	F=vcat(F...);S=sum(F);F[F.>0]=collect(1:S)
	# 求所节点坐标	
	#X=[x[j] for i in 1:length(D) for j in 1:length(D[i])]
	#Y=[y[i] for i in 1:length(D) for j in 1:length(D[i])]
	K=hcat([[x[j],y[i],0.0] for i in 1:length(D) for j in 1:length(D[i])]...)
	# 返回xyz坐标，单元数组，求解标志，需求解节点数
	return K[1,:],K[2,:],K[3,:],E,F,S
end
=#

function mesh2d(rectangle::Rectangle2d, node = 4)
	A,B,NA,NB=rectangle.A,rectangle.B,rectangle.NA,rectangle.NB
	# mesh and get all nodes
    x=collect(range(0.0,stop=A,length=NA+1))
    y=collect(range(0.0,stop=B,length=NB+1))
	D=[[i*(NA+1)+1+j for j in 0:NA] for i in 0:NB]
	# get all the elements with 4-node
	n,m=NA,NB		
	c=[[D[i][j],D[i][j+1],D[i+1][j+1],D[i+1][j]] for i in 1:m for j in 1:n]
	E=reshape(c,:,1)    #4-node elements
	if node == 3    # if use 3-node element then separate the 4-node rectangle element to two 3-node elements
		E = [[i[[1,2,4]] for i in E];[i[[2,3,4]] for i in E]]
	end
	# around the rectangle, four sides are fixed
	F=D;F[1].=0;F[end].=0
	for f in F;f[1],f[end]=0,0;f[f.>0].=1;end
	F=vcat(F...);S=sum(F);F[F.>0]=collect(1:S)	
	# get all nodes coordinate 	
	#X=[x[j] for i in 1:length(D) for j in 1:length(D[i])]
	#Y=[y[i] for i in 1:length(D) for j in 1:length(D[i])]	
	K=hcat([[x[j],y[i],0.0] for i in 1:length(D) for j in 1:length(D[i])]...)
	# return nodes coordinate array, elements array, solving-flag arrat,  the number of nodes need to solve
	return K[1,:],K[2,:],K[3,:],E,F,S
end

#=
function 网格(矩形::矩形, node = 4)
	A,B,NA,NB=矩形.A,矩形.B,矩形.NA,矩形.NB
	# 求所有节点
    x=collect(range(0.0,stop=A,length=NA+1))
    y=collect(range(0.0,stop=B,length=NB+1))
	D=[[i*(NA+1)+1+j for j in 0:NA] for i in 0:NB]
	# 求基本矩形单元,四节点
	n,m=NA,NB		
	c=[[D[i][j],D[i][j+1],D[i+1][j+1],D[i+1][j]] for i in 1:m for j in 1:n]
	E=reshape(c,:,1)    #四节点矩形单元
	if node == 3    #三节点三角单元
		E = [[i[[1,2,4]] for i in E];[i[[2,3,4]] for i in E]]
	end
	# 求周边固定的边界条件
	F=D;F[1].=0;F[end].=0
	for f in F;f[1],f[end]=0,0;f[f.>0].=1;end
	F=vcat(F...);S=sum(F);F[F.>0]=collect(1:S)	
	# 求所节点坐标	
	#X=[x[j] for i in 1:length(D) for j in 1:length(D[i])]
	#Y=[y[i] for i in 1:length(D) for j in 1:length(D[i])]	
	K=hcat([[x[j],y[i],0.0] for i in 1:length(D) for j in 1:length(D[i])]...)
	# 返回xyz坐标，单元数组，求解标志，需求解节点数
	return K[1,:],K[2,:],K[3,:],E,F,S
end
=#

function mesh2d(lshape::Lshape2d, node = 4)
	A,B,NA,NB=lshape.A,lshape.B,lshape.NA,lshape.NB
	# mesh and get all nodes
    x=collect(range(0.0,stop=A,length=NA+1))
    y=collect(range(0.0,stop=B,length=NB+1))
	D1=[[i*(NA+1)+1+j for j in 0:NA] for i in 0:(NB ÷ 2)]    
	D2=[[i*(NA ÷ 2 + 1)+1+j + D1[end][end] for j in 0:(NA÷ 2)] for i in 0:(NB ÷ 2)-1]
	D=[D1;D2]
	# get all the elements with 4-node
	n,m=NA , NB	÷ 2	
	c1=[[D[i][j],D[i][j+1],D[i+1][j+1],D[i+1][j]] for i in 1:m for j in 1:n]
	n=NA ÷ 2
	c2=[[D[i][j],D[i][j+1],D[i+1][j+1],D[i+1][j]] for i in 1+m:NB for j in 1:n]
    c=[c1;c2]
	E=reshape(c,:,1)
	if node == 3    #  if use 3-node element then separate the 4-node rectangle element to two 3-node elements
		E = [[i[[1,2,4]] for i in E];[i[[2,3,4]] for i in E]]
	end
	# around the lshape,  sides are fixed
	F=D;F[1].=0;F[end].=0
	for f in F;f[1],f[end]=0,0;f[f.>0].=1;end
	F[NB ÷ 2 + 1][NA÷ 2 + 1 : end]  .=  0    # L形缺角位两边都要为0
	F=vcat(F...);S=sum(F);F[F.>0]=collect(1:S)	
	# get all nodes coordinate 	
	#X=[x[j] for i in 1:length(D) for j in 1:length(D[i])]
	#Y=[y[i] for i in 1:length(D) for j in 1:length(D[i])]	
	K=hcat([[x[j],y[i],0.0] for i in 1:length(D) for j in 1:length(D[i])]...)
	# return nodes coordinate array, elements array, solving-flag arrat,  the number of nodes need to solve
	return K[1,:],K[2,:],K[3,:],E,F,S
end

#=
function 网格(L形::L形, node = 4)
	A,B,NA,NB=L形.A,L形.B,L形.NA,L形.NB
	# 求所有节点
    x=collect(range(0.0,stop=A,length=NA+1))
    y=collect(range(0.0,stop=B,length=NB+1))
	D1=[[i*(NA+1)+1+j for j in 0:NA] for i in 0:(NB ÷ 2)]    
	D2=[[i*(NA ÷ 2 + 1)+1+j + D1[end][end] for j in 0:(NA÷ 2)] for i in 0:(NB ÷ 2)-1]
	D=[D1;D2]
	# 求基本矩形单元,四节点
	n,m=NA , NB	÷ 2	
	c1=[[D[i][j],D[i][j+1],D[i+1][j+1],D[i+1][j]] for i in 1:m for j in 1:n]
	n=NA ÷ 2
	c2=[[D[i][j],D[i][j+1],D[i+1][j+1],D[i+1][j]] for i in 1+m:NB for j in 1:n]
    c=[c1;c2]
	E=reshape(c,:,1)
	if node == 3    #三节点三角单元
		E = [[i[[1,2,4]] for i in E];[i[[2,3,4]] for i in E]]
	end
	# 求周边固定的边界条件
	F=D;F[1].=0;F[end].=0
	for f in F;f[1],f[end]=0,0;f[f.>0].=1;end
	F[NB ÷ 2 + 1][NA÷ 2 + 1 : end]  .=  0    # L形缺角位两边都要为0
	F=vcat(F...);S=sum(F);F[F.>0]=collect(1:S)	
	# 求所节点坐标	
	#X=[x[j] for i in 1:length(D) for j in 1:length(D[i])]
	#Y=[y[i] for i in 1:length(D) for j in 1:length(D[i])]	
	K=hcat([[x[j],y[i],0.0] for i in 1:length(D) for j in 1:length(D[i])]...)
	# 返回xyz坐标，单元数组，求解标志，需求解节点数
	return K[1,:],K[2,:],K[3,:],E,F,S
end
=#

function mesh2d(circle::Circle2d, node = 3)
	R,N=circle.R, circle.N
	# mesh and get all nodes
    b = R / N
	a = round(2*π*R / b)       # 大至形成等边三解形, make all triangle almost a equilateral triangle
	x = [R*cosd(i) for i in 0:360/a:360-360/a]
	y = [R*sind(i) for i in 0:360/a:360-360/a]
	F = zeros(Int, size(x))

	for j =  N -1 : -1 : 1
		r = j * b
        a = round(2*π*r / b)
		append!(x, [r*cosd(i) for i in 0:360/a:360-360/a])
        append!(y, [r*sind(i) for i in 0:360/a:360-360/a])
		append!(F, [1 for i in 0:360/a:360-360/a])
	end
	push!(x,0.0); push!(y,0.0)             # the last node is the center of circle
    push!(F,1)
	S=sum(F);F[F.>0]=collect(1:S)
	n, tri = delaunay(x, y)                    # use the delaunay in GR
	E = [c[:] for c in eachrow(tri)]
	E = reshape(E,length(E),1)    # turn E to a matrix
	z = zeros(size(x))
	return x,y,z,E,F,S
end

#=
function 网格(圆形::圆形, node = 3)
	R,N=圆形.R, 圆形.N
	# 求所有节点
    b = R / N
	a = round(2*π*R / b)
	x = [R*cosd(i) for i in 0:360/a:360-360/a]
	y = [R*sind(i) for i in 0:360/a:360-360/a]
	F = zeros(Int, size(x))

	for j =  N -1 : -1 : 1
		r = j * b
        a = round(2*π*r / b)
		append!(x, [r*cosd(i) for i in 0:360/a:360-360/a])
        append!(y, [r*sind(i) for i in 0:360/a:360-360/a])
		append!(F, [1 for i in 0:360/a:360-360/a])
	end
	push!(x,0.0); push!(y,0.0)   # 圆心
    push!(F,1)
	S=sum(F);F[F.>0]=collect(1:S)
	n, tri = delaunay(x, y)
	E = [c[:] for c in eachrow(tri)]
	E = reshape(E,length(E),1)    # 转为matrix
	z = zeros(size(x))
	return x,y,z,E,F,S
end
=#

function mesh2d(sector::Sector2d, node = 3)
	R,A,N=sector.R, sector.A, sector.N
	# mesh and get all nodes
    b = min(R / N,  2*π*R  * A / 360 / N) 
	n = round(R / b)         # 更合理的分格数.  make all triangle almost a equilateral triangle
	a = round(2*π*R  * A / 360 / b + 0.5)
	x = [R*cosd(i) for i in 0:A/a:A]
	y = [R*sind(i) for i in 0:A/a:A]
	F = zeros(Int, size(x))
	# 先把最前和最后角位的点付1, 主要是当去掉多余的delaunay时有用
	# make the second node flag and the last but one  node flag =1,  may  use to delete the unused delaunay triangle.
	f2 = length(F)-1;F[2]=1;F[f2]=1
	#-----
	for j =  n-1 : -1 : 1
		r = j * b
        a = round(2*π*r  * A / 360 / b + 0.5)		    # 防止出现a=0
		append!(x, [r*cosd(i) for i in 0:A/a:A])
        append!(y, [r*sind(i) for i in 0:A/a:A])
		f = [1 for i in 0:A/a:A]
		f[1] = 0;f[end] = 0;
		append!(F, f)
	end
	push!(x,0.0); push!(y,0.0)            # the center of circle
    push!(F,0)
	S=sum(F);F[F.>0]=collect(1:S)
	n, tri = delaunay(x, y)
	# 删除所有有个点为0的单元,主要对于角度大于180的时候，delaunay会超过边界生成
    # delete all elements which each node`s flag is 0,  this may happen when sector`s angle>180 
	if A > 180
	  b  = F[tri]
	  a = all(b.==[0 0 0],dims=2)[:,1]
	  tri = tri[a.==0,:]
	end
    #-----
	F[2] = 0; F[f2] = 0
	F[F.>0] .= 1
	S=sum(F);F[F.>0]=collect(1:S)	
	E = [c[:] for c in eachrow(tri)]
	E = reshape(E,length(E),1)           # turn to a matrix
	z = zeros(size(x))
	return x,y,z,E,F,S
end

#=
function 网格(扇形::扇形, node = 3)
	R,A,N=扇形.R, 扇形.A,扇形.N
	# 求所有节点
    b = min(R / N,  2*π*R  * A / 360 / N) 
	n = round(R / b)    # 更合理的分格数
	a = round(2*π*R  * A / 360 / b + 0.5)
	x = [R*cosd(i) for i in 0:A/a:A]
	y = [R*sind(i) for i in 0:A/a:A]
	F = zeros(Int, size(x))
	# 先把最前和最后角位的点付1, 主要是当去掉多余的delaunay时有用
	f2 = length(F)-1;F[2]=1;F[f2]=1
	#-----
	for j =  n-1 : -1 : 1
		r = j * b
        a = round(2*π*r  * A / 360 / b + 0.5)		# 防止出现a=0
		append!(x, [r*cosd(i) for i in 0:A/a:A])
        append!(y, [r*sind(i) for i in 0:A/a:A])
		f = [1 for i in 0:A/a:A]
		f[1] = 0;f[end] = 0;
		append!(F, f)
	end
	push!(x,0.0); push!(y,0.0)   # 圆心
    push!(F,0)
	S=sum(F);F[F.>0]=collect(1:S)
	n, tri = delaunay(x, y)
	#删除所有有个点为0的单元,主要对于角度大于180的时候，delaunay会超过边界生成
	if A > 180
	  b  = F[tri]
	  a = all(b.==[0 0 0],dims=2)[:,1]
	  tri = tri[a.==0,:]
	end
    #-----
	F[2] = 0; F[f2] = 0
	F[F.>0] .= 1
	S=sum(F);F[F.>0]=collect(1:S)	
	E = [c[:] for c in eachrow(tri)]
	E = reshape(E,length(E),1)    # 转为matrix
	z = zeros(size(x))
	return x,y,z,E,F,S
end
=#

function mesh2d(trapezoid::Trapezoid2d, node = 4)
	A,B,C,NA,NB=trapezoid.A, trapezoid.B, trapezoid.C, trapezoid.NA, trapezoid.NB
	# 梯形例子可由左边的矩形组合右边的三角形
	# 先求矩形的网格, 再反转xy轴求三角网格, 主要系可以方便组合时矩形右边的点正好是三角形底边的点
	# 则三角形底边的点号换成矩形右边的点号，三角形其它的点号减去三角形底边点数加上矩形最大点号即可
	# 再把三角形xy坐标换过来，然后三角形x坐标加上矩形A边长即可
	x1,y1,z1,E1,F1,S1 = mesh2d(Rectangle2d(B,C,NA,NB),node)
	x2,y2,z2,E2,F2,S2 = mesh2d(Triangle2d(C,A-B,NB))   # 把x,y调换来求单元，方便组合矩形和三角	
	n1 = length(x1)   # 矩形最大节点号
	n_edge = [i*(NA+1) for i = 1:NB+1]    # 矩形右边上的节点号
	F1[n_edge[2:end-1]] .= 1
	for i in E2
		for j in 1:3
			if i[j] <=NB+1
				i[j] = n_edge[i[j]]
			else
				i[j] = i[j]+n1 - (NB+1)
			end			
		end	
		i[2],i[3] = i[3],i[2]     #反时针
	end
    E = [E1;E2]
	F2 = F2[NB+1+1:end]
	F=[F1;F2]
	F[F.>0].=1
	S=sum(F);F[F.>0]=collect(1:S)
	x2,y2 = y2[NB+1+1:end],x2[NB+1+1:end]     #三角形xy反转
	x2 = x2 .+ B	
	x=[x1;x2]
	y=[y1;y2]
	z=zeros(size(x))	
	return x,y,z,E,F,S
end

#=
function 网格(梯形::梯形, node = 4)
	A,B,C,NA,NB=梯形.A,梯形.B,梯形.C,梯形.NA,梯形.NB
	# 梯形例子可由左边的矩形组合右边的三角形
	# 先求矩形的网格, 再反转xy轴求三角网格, 主要系可以方便组合时矩形右边的点正好是三角形底边的点
	# 则三角形底边的点号换成矩形右边的点号，三角形其它的点号减去三角形底边点数加上矩形最大点号即可
	# 再把三角形xy坐标换过来，然后三角形x坐标加上矩形A边长即可
	x1,y1,z1,E1,F1,S1 = 网格(矩形(B,C,NA,NB),node)
	x2,y2,z2,E2,F2,S2 = 网格(三角(C,A-B,NB))   # 把x,y调换来求单元，方便组合矩形和三角	
	n1 = length(x1)   # 矩形最大节点号
	n_edge = [i*(NA+1) for i = 1:NB+1]    # 矩形右边上的节点号
	F1[n_edge[2:end-1]] .= 1
	for i in E2
		for j in 1:3
			if i[j] <=NB+1
				i[j] = n_edge[i[j]]
			else
				i[j] = i[j]+n1 - (NB+1)
			end			
		end	
		i[2],i[3] = i[3],i[2]     #反时针
	end
    E = [E1;E2]
	F2 = F2[NB+1+1:end]
	F=[F1;F2]
	F[F.>0].=1
	S=sum(F);F[F.>0]=collect(1:S)
	x2,y2 = y2[NB+1+1:end],x2[NB+1+1:end]     #三角形xy反转
	x2 = x2 .+ B	
	x=[x1;x2]
	y=[y1;y2]
	z=zeros(size(x))	
	return x,y,z,E,F,S
end
=#

#专门为加倍单元网格化膜本身
function mesh2d(polygon::Memb2d, node = 3)
	X,Y,Z,E,F,S = polygon.X, polygon.Y, polygon.Z, polygon.E, polygon.F, polygon.S
	# 这里可进行数据合理性检查，如单元只能两节点和三节点
	# 节点号要等于XYZ的长度之类
	return X,Y,Z,E,F,S
end

#=
function 网格(多边形::膜, node = 3)
	X,Y,Z,E,F,S = 多边形.X, 多边形.Y, 多边形.Z, 多边形.E, 多边形.F, 多边形.S
	# 这里可进行数据合理性检查，如单元只能两节点和三节点
	# 节点号要等于XYZ的长度之类
	return X,Y,Z,E,F,S
end
=#

function double_node(sh::Shape2d, node = 4, element = "any")
	X,Y,Z,E,F,S=mesh2d(sh, node)
	# for triangle get 6-node elements, rectangle get 8-node elements
	新点=length(X)+1	
	索=Dict{Array{Int64,1},Int64}()	           # all cable=>newnode
    #元=zeros(Int64,size(E[1]))
	for e in E
		元=zeros(Int64,size(e))		
		段=[e;e[1]]
		for d in 1:length(e)
			线=段[d]<段[d+1] ? [段[d],段[d+1]] : [段[d+1],段[d]]			
			点=get!(索,线,新点)
			if 点==新点
				push!(X,(X[线[1]]+X[线[2]])/2)
				push!(Y,(Y[线[1]]+Y[线[2]])/2)
				push!(Z,0.0)
				push!(F,0)
				新点=新点+1
			else
				F[点]=1            # 已存在Dict中的线段为内部的线段,中点必需求解. when second time find this node, it  means this node must inside the shape and need to solve 
			end			
			#push!(元,点)
			元[d]=点
		end
		append!(e,元)
	end
	F[F.>0].=1
	S=sum(F);F[F.>0]=collect(1:S)
	# 对于存在cable两节点直线单元，仍只有两节点直线. for a line , still be 2-node elements
	# 也可以生成全部是三角单元. can turn to all triangle elements, that means it will be 4 times triangle elements
	e=Vector{Vector{Int}}()	
	if element == "triangle"		
		for i in E	
			if  length(i) == 4		
				j = [[i[1],i[3]],[i[3],i[2]]]
				append!(e,j)
			elseif length(i) == 6            # this is it, get 4 times triangle elements
				j = [[i[1],i[4],i[6]],[i[2],i[5],i[4]],[i[3],i[6],i[5]],[i[4],i[5],i[6]]]
				append!(e,j)
			else       # 8节点
				j = [[i[1],i[5],i[8]],[i[2],i[6],i[5]],[i[3],i[7],i[6]],[i[4],i[8],i[7]],[i[5],i[6],i[7]],[i[5],i[7],i[8]]]
				append!(e,j)
			end		
		end	  	  
	else		
		for i in E	
			if  length(i) == 4			
				j = [[i[1],i[3]],[i[3],i[2]]]
				append!(e,j)
			else
			  push!(e,i)
			end		
		end
	end
	E = reshape(e,:,1)		
	#------------------------------------------------------
	return X,Y,Z,E,F,S
end

#=
function 双倍节点(形::平面形, node = 4, element = "任意")
	X,Y,Z,E,F,S=网格(形, node)
	# 三角形求6节点单元，矩形求8节点单元
	新点=length(X)+1	
	索=Dict{Array{Int64,1},Int64}()	  # 全部cable=>新点
    #元=zeros(Int64,size(E[1]))
	for e in E
		元=zeros(Int64,size(e))		
		段=[e;e[1]]
		for d in 1:length(e)
			线=段[d]<段[d+1] ? [段[d],段[d+1]] : [段[d+1],段[d]]			
			点=get!(索,线,新点)
			if 点==新点
				push!(X,(X[线[1]]+X[线[2]])/2)
				push!(Y,(Y[线[1]]+Y[线[2]])/2)
				push!(Z,0.0)
				push!(F,0)
				新点=新点+1
			else
				F[点]=1  #已存在Dict中的线段为内部的线段,中点必需求解
			end			
			#push!(元,点)
			元[d]=点
		end
		append!(e,元)
	end
	F[F.>0].=1
	S=sum(F);F[F.>0]=collect(1:S)
	# 对于存在cable两节点直线单元，仍只有两节点直线
	# 也可以生成全部是三角单元
	e=Vector{Vector{Int}}()	
	if element == "三角"		
		for i in E	
			if  length(i) == 4		
				j = [[i[1],i[3]],[i[3],i[2]]]
				append!(e,j)
			elseif length(i) == 6
				j = [[i[1],i[4],i[6]],[i[2],i[5],i[4]],[i[3],i[6],i[5]],[i[4],i[5],i[6]]]
				append!(e,j)
			else     # 8节点
				j = [[i[1],i[5],i[8]],[i[2],i[6],i[5]],[i[3],i[7],i[6]],[i[4],i[8],i[7]],[i[5],i[6],i[7]],[i[5],i[7],i[8]]]
				append!(e,j)
			end		
		end	  	  
	else		
		for i in E	
			if  length(i) == 4			
				j = [[i[1],i[3]],[i[3],i[2]]]
				append!(e,j)
			else
			  push!(e,i)
			end		
		end
	end
	E = reshape(e,:,1)		
	#------------------------------------------------------
	return X,Y,Z,E,F,S
end
=#

#=证实效率不会高
function 另一双倍(形::平面形)
	X,Y,Z,E,F,S=网格(形)
	新点=length(X)+1
	#------------------------------
	单元数组=hcat(E...)'
	所有索=size(单元数组,2)==3 ? [单元数组[:,1:2];单元数组[:,2:3];单元数组[:,[1,3]]] : [单元数组[:,1:2];单元数组[:,2:3];单元数组[:,3:4];单元数组[:,[1,4]]]
	所有索=unique(sort!(所有索,dims=2),dims=1)
	新点数=size(所有索,1)
	append!(X,zeros(新点数));append!(Y,zeros(新点数));append!(Z,zeros(新点数))
	append!(F,zeros(Int64,新点数))
	# 三角形求6节点单元，矩形求8节点单元		
	索=Dict{Array{Int64,1},Int64}()	
    元=zeros(Int64,size(E[1]))
	for e in E		
		段=[e;e[1]]
		for d in 1:length(e)
			线=段[d]<段[d+1] ? [段[d],段[d+1]] : [段[d+1],段[d]]			
			点=get!(索,线,新点)
			if 点==新点
				X[点]=(X[线[1]]+X[线[2]])/2
				Y[点]=(Y[线[1]]+Y[线[2]])/2
				F[点]=0
				新点=新点+1
			else
				F[点]=1  #已存在Dict中的线段为内部的线段,中点必需求解
			end			
			#push!(元,点)
			元[d]=点
		end
		append!(e,元)
	end
	F[F.>0].=1
	S=sum(F);F[F.>0]=collect(1:S)
	return X,Y,Z,E,F,S
end
=#

function memb_solv(膜::Memb2d,膜参数::MPara)
	#----子函数
	@inline function 叠加(de3,ke3,me3)
		l=length(de3)
        for j in 1:l
            if de3[j] != 0
                for k in 1:l
                    if de3[k] != 0
                        kt[de3[j],de3[k]]=kt[de3[j],de3[k]]+ke3[j,k]
                        mt[de3[j],de3[k]]=mt[de3[j],de3[k]]+me3[j,k]
                    end
                end
            end
        end
	end
	#------
	@inline 坐标(顶点::Array{Int64,2})=[膜.X[顶点] 膜.Y[顶点]]
    #------
	@inline function 单元(顶点1::Int64,顶点2::Int64)
		x1,x2,y1,y2=坐标([顶点1 顶点2])
		a1=sqrt((x2-x1)^2+(y2-y1)^2)				
	end
	@inline function 单元(顶点1::Int64,顶点2::Int64,顶点3::Int64)
		x1,x2,x3,y1,y2,y3=坐标([顶点1 顶点2 顶点3])
        Ae=abs(-x2*y1+x3*y1+x1*y2-x3*y2-x1*y3+x2*y3)
        b1,b2,b3,c1,c2,c3,Ae=-y3+y2,-y1+y3,-y2+y1,x3-x2,x1-x3,x2-x1,Ae        
	end
	@inline function 单元(顶点1::Int64,顶点2::Int64,顶点3::Int64,顶点4::Int64)
		x1,x2,x3,y1,y2,y3=坐标([顶点1 顶点2 顶点3])
		a1=sqrt((x2-x1)^2+(y2-y1)^2)/2;	b1=sqrt((x3-x2)^2+(y3-y2)^2)/2
		a2=a1^2; b2=b1^2
		a1,a2,b1,b2
	end				
	#------	
	function 公式(顶点1::Int64,顶点2::Int64)
		a1=单元(顶点1,顶点2)
		me3=LOU*a1*[1/3 1/6;1/6 1/3]
		ke3=S/a1/2*[1 -1;-1 1]		
		ke3,me3			
	end
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64)
		b1,b2,b3,c1,c2,c3,Ae=单元(顶点1,顶点2,顶点3)
        me3=(1.0/24.0)*LOU*Ae*[2 1 1;1 2 1;1 1 2]
        ke3=S/(2.0*Ae)*[b1^2+c1^2 b1*b2+c1*c2 b1*b3+c1*c3;
                    b1*b2+c1*c2 b2^2+c2^2 b2*b3+c2*c3;
                    b1*b3+c1*c3 b2*b3+c2*c3 b3^2+c3^2]		
        ke3,me3		
    end	
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64,顶点4::Int64)
	    a1,a2,b1,b2=单元(顶点1,顶点2,顶点3,顶点4)
		me3=(1.0/9.0)*LOU*a1*b1*[4 2 1 2;2 4 2 1;1 2 4 2;2 1 2 4]
		ke3=(1.0/3.0)*S*a1*b1*
		[1/(a2)+1/(b2) -1/(a2)+1/(2*b2) -1/(2*a2)-1/(2*b2) 1/(2*a2)-1/(b2);
         -1/(a2)+1/(2*b2) 1/(a2)+1/(b2) 1/(2*a2)-1/(b2) -1/(2*a2)-1/(2*b2);
         -1/(2*a2)-1/(2*b2) 1/(2*a2)-1/(b2) 1/(a2)+1/(b2) -1/(a2)+1/(2*b2);
         1/(2*a2)-1/(b2) -1/(2*a2)-1/(2*b2) -1/(a2)+1/(2*b2) 1/(a2)+1/(b2)]
		ke3,me3
	end
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64,
			      顶点4::Int64,顶点5::Int64,顶点6::Int64)
		b1,b2,b3,c1,c2,c3,Ae=单元(顶点1,顶点2,顶点3)
		me3=LOU*Ae*[
               1/60.0   -1/360.0  -1/360.0   0.0       -1/90.0    0.0;
              -1/360.0   1/60.0   -1/360.0   0.0        0.0      -1/90.0;
              -1/360.0  -1/360.0   1/60.0   -1/90.0     0.0       0.0; 
               0.0       0.0      -1/90.0    4/45.0     2/45.0    2/45.0;
              -1/90.0    0.0       0.0       2/45.0     4/45.0    2/45.0;
               0.0      -1/90.0    0.0       2/45.0     2/45.0    4/45.0]	
        ke3=S/Ae*[
     b1^2/2+c1^2/2   -b1*b2/6-c1*c2/6   -b1*b3/6-c1*c3/6            	                    2*b1*b2/3+2*c1*c2/3   0.0   2*b1*b3/3+2*c1*c3/3;
		
     -b1*b2/6-c1*c2/6   b2^2/2+c2^2/2   -b2*b3/6-c2*c3/6        	                        2*b1*b2/3+2*c1*c2/3   2*b2*b3/3+2*c2*c3/3   0.0;
			
     -b1*b3/6-c1*c3/6   -b2*b3/6-c2*c3/6   b3^2/2+c3^2/2                          	        0.0   2*b2*b3/3+2*c2*c3/3   2*b1*b3/3+2*c1*c3/3; 
			
     2*b1*b2/3+2*c1*c2/3   2*b1*b2/3+2*c1*c2/3   0.0                                        4*b1^2/3+4*b1*b2/3+4*b2^2/3+4*c1^2/3+4*c1*c2/3+4*c2^2/3			                      2*b1*b2/3+2*b2^2/3+4*b1*b3/3+2*b2*b3/3+2*c1*c2/3+2*c2^2/3+4*c1*c3/3+2*c2*c3/3	        2*b1^2/3+2*b1*b2/3+2*b1*b3/3+4*b2*b3/3+2*c1^2/3+2*c1*c2/3+2*c1*c3/3+4*c2*c3/3;	
			
     0.0   2*b2*b3/3+2*c2*c3/3   2*b2*b3/3+2*c2*c3/3		                                2*b1*b2/3+2*b2^2/3+4*b1*b3/3+2*b2*b3/3+2*c1*c2/3+2*c2^2/3+4*c1*c3/3+2*c2*c3/3	      4*b2^2/3+4*b2*b3/3+4*b3^2/3+4*c2^2/3+4*c2*c3/3+4*c3^2/3	                            4*b1*b2/3+2*b1*b3/3+2*b2*b3/3+2*b3^2/3+4*c1*c2/3+2*c1*c3/3+2*c2*c3/3+2*c3^2/3;	
			
	 2*b1*b3/3+2*c1*c3/3   0.0   2*b1*b3/3+2*c1*c3/3		                                2*b1^2/3+2*b1*b2/3+2*b1*b3/3+4*b2*b3/3+2*c1^2/3+2*c1*c2/3+2*c1*c3/3+4*c2*c3/3	      4*b1*b2/3+2*b1*b3/3+2*b2*b3/3+2*b3^2/3+4*c1*c2/3+2*c1*c3/3+2*c2*c3/3+2*c3^2/3	        4*b1^2/3+4*b1*b3/3+4*b3^2/3+4*c1^2/3+4*c1*c3/3+4*c3^2/3]	
		ke3,me3
	end
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64,顶点4::Int64,
			      顶点5::Int64,顶点6::Int64,顶点7::Int64,顶点8::Int64)
		a1,a2,b1,b2=单元(顶点1,顶点2,顶点3,顶点4)
        me3=LOU*a1*b1*[ 
	 2/15.0   2/45.0   1/15.0   2/45.0  -2/15.0  -8/45.0  -8/45.0  -2/15.0;
     2/45.0   2/15.0   2/45.0   1/15.0  -2/15.0  -2/15.0  -8/45.0  -8/45.0;
     1/15.0   2/45.0   2/15.0   2/45.0  -8/45.0  -2/15.0  -2/15.0  -8/45.0;
     2/45.0   1/15.0   2/45.0   2/15.0  -8/45.0  -8/45.0  -2/15.0  -2/15.0; 
    -2/15.0  -2/15.0  -8/45.0  -8/45.0  32/45.0    4/9.0  16/45.0    4/9.0;
	-8/45.0  -2/15.0  -2/15.0  -8/45.0    4/9.0  32/45.0    4/9.0   16/45.0;
	-8/45.0  -8/45.0  -2/15.0  -2/15.0  16/45.0    4/9.0  32/45.0    4/9.0;
	-2/15.0  -8/45.0  -8/45.0  -2/15.0  4/9.0    16/45.0   4/9.0    32/45.0]
		ke3=S*a1*b1*[
     26/45.0/a2+26/45.0/b2   14/45.0/a2+17/90.0/b2   23/90.0/a2+23/90.0/b2                  17/90.0/a2+14/45.0/b2 	-8/9.0/a2+1/15.0/b2     -1/15.0/a2-4/9.0/b2	                  -4/9.0/a2-1/15.0/b2     1/15.0/a2-8/9.0/b2;
			
     14/45.0/a2+17/90.0/b2   26/45.0/a2+26/45.0/b2   17/90.0/a2+14/45.0/b2                  23/90.0/a2+23/90.0/b2   -8/9.0/a2+1/15.0/b2     1/15.0/a2-8/9.0/b2	                  -4/9.0/a2-1/15.0/b2     -1/15.0/a2-4/9.0/b2;
			
	 23/90.0/a2+23/90.0/b2   17/90.0/a2+14/45.0/b2   26/45.0/a2+26/45.0/b2	                14/45.0/a2+17/90.0/b2   -4/9.0/a2-1/15.0/b2     1/15.0/a2-8/9.0/b2	                  -8/9.0/a2+1/15.0/b2     -1/15.0/a2-4/9.0/b2;
			
 	 17/90.0/a2+14/45.0/b2   23/90.0/a2+23/90.0/b2   14/45.0/a2+17/90.0/b2	                26/45.0/a2+26/45.0/b2   -4/9.0/a2-1/15.0/b2     -1/15.0/a2-4/9.0/b2	                  -8/9.0/a2+1/15.0/b2     1/15.0/a2-8/9.0/b2;
			
	 -8/9.0/a2+1/15.0/b2     -8/9.0/a2+1/15.0/b2     -4/9.0/a2-1/15.0/b2  	                -4/9.0/a2-1/15.0/b2     16/9.0/a2+8/15.0/b2     0.0  	                              8/9.0/a2-8/15.0/b2      0.0;
			
	 -1/15.0/a2-4/9.0/b2     1/15.0/a2-8/9.0/b2      1/15.0/a2-8/9.0/b2 	                -1/15.0/a2-4/9.0/b2     0.0                     8/15.0/a2+16/9.0/b2                    0.0        			   -8/15.0/a2+8/9.0/b2;
			
	 -4/9.0/a2-1/15.0/b2     -4/9.0/a2-1/15.0/b2     -8/9.0/a2+1/15.0/b2 	                -8/9.0/a2+1/15.0/b2     8/9.0/a2-8/15.0/b2      0.0  	                              16/9.0/a2+8/15.0/b2     0.0;        
			
     1/15.0/a2-8/9.0/b2      -1/15.0/a2-4/9.0/b2     -1/15.0/a2-4/9.0/b2	                1/15.0/a2-8/9.0/b2      0.0                     -8/15.0/a2+8/9.0/b2 	              0.0                     8/15.0/a2+16/9.0/b2]
		ke3,me3
	end	
	#-------
	m=膜.S
	kt,mt=spzeros(m,m),spzeros(m,m)	
	E,LOU,S,fi=膜参数.E,膜参数.LOU,膜参数.S,膜参数.fi
	#pp = 膜参数()
	#E,LOU,S,fi=pp.E,pp.LOU,pp.S,pp.fi
	# -----计算
	elem,nd=膜.E,膜.F
	for v in elem
        ke3,me3=公式(v...)
        de3=nd[v]
        叠加(de3,ke3,me3)
    end
	#kt,mt,fi
	D,eigv=eigs(kt,mt,nev=fi,which=:SR)
	f = sqrt.(D) / 2 / pi
    OMG = sqrt.(D) * sqrt(LOU / S)
	return D,eigv,f,OMG
	#------
end

#=
function 膜振形(膜::膜,膜参数::膜参数)
	#----子函数
	@inline function 叠加(de3,ke3,me3)
		l=length(de3)
        for j in 1:l
            if de3[j] != 0
                for k in 1:l
                    if de3[k] != 0
                        kt[de3[j],de3[k]]=kt[de3[j],de3[k]]+ke3[j,k]
                        mt[de3[j],de3[k]]=mt[de3[j],de3[k]]+me3[j,k]
                    end
                end
            end
        end
	end
	#------
	@inline 坐标(顶点::Array{Int64,2})=[膜.X[顶点] 膜.Y[顶点]]
    #------
	@inline function 单元(顶点1::Int64,顶点2::Int64)
		x1,x2,y1,y2=坐标([顶点1 顶点2])
		a1=sqrt((x2-x1)^2+(y2-y1)^2)				
	end
	@inline function 单元(顶点1::Int64,顶点2::Int64,顶点3::Int64)
		x1,x2,x3,y1,y2,y3=坐标([顶点1 顶点2 顶点3])
        Ae=abs(-x2*y1+x3*y1+x1*y2-x3*y2-x1*y3+x2*y3)
        b1,b2,b3,c1,c2,c3,Ae=-y3+y2,-y1+y3,-y2+y1,x3-x2,x1-x3,x2-x1,Ae        
	end
	@inline function 单元(顶点1::Int64,顶点2::Int64,顶点3::Int64,顶点4::Int64)
		x1,x2,x3,y1,y2,y3=坐标([顶点1 顶点2 顶点3])
		a1=sqrt((x2-x1)^2+(y2-y1)^2)/2;	b1=sqrt((x3-x2)^2+(y3-y2)^2)/2
		a2=a1^2; b2=b1^2
		a1,a2,b1,b2
	end				
	#------	
	function 公式(顶点1::Int64,顶点2::Int64)
		a1=单元(顶点1,顶点2)
		me3=LOU*a1*[1/3 1/6;1/6 1/3]
		ke3=S/a1/2*[1 -1;-1 1]		
		ke3,me3			
	end
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64)
		b1,b2,b3,c1,c2,c3,Ae=单元(顶点1,顶点2,顶点3)
        me3=(1.0/24.0)*LOU*Ae*[2 1 1;1 2 1;1 1 2]
        ke3=S/(2.0*Ae)*[b1^2+c1^2 b1*b2+c1*c2 b1*b3+c1*c3;
                    b1*b2+c1*c2 b2^2+c2^2 b2*b3+c2*c3;
                    b1*b3+c1*c3 b2*b3+c2*c3 b3^2+c3^2]		
        ke3,me3		
    end	
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64,顶点4::Int64)
	    a1,a2,b1,b2=单元(顶点1,顶点2,顶点3,顶点4)
		me3=(1.0/9.0)*LOU*a1*b1*[4 2 1 2;2 4 2 1;1 2 4 2;2 1 2 4]
		ke3=(1.0/3.0)*S*a1*b1*
		[1/(a2)+1/(b2) -1/(a2)+1/(2*b2) -1/(2*a2)-1/(2*b2) 1/(2*a2)-1/(b2);
         -1/(a2)+1/(2*b2) 1/(a2)+1/(b2) 1/(2*a2)-1/(b2) -1/(2*a2)-1/(2*b2);
         -1/(2*a2)-1/(2*b2) 1/(2*a2)-1/(b2) 1/(a2)+1/(b2) -1/(a2)+1/(2*b2);
         1/(2*a2)-1/(b2) -1/(2*a2)-1/(2*b2) -1/(a2)+1/(2*b2) 1/(a2)+1/(b2)]
		ke3,me3
	end
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64,
			      顶点4::Int64,顶点5::Int64,顶点6::Int64)
		b1,b2,b3,c1,c2,c3,Ae=单元(顶点1,顶点2,顶点3)
		me3=LOU*Ae*[
               1/60.0   -1/360.0  -1/360.0   0.0       -1/90.0    0.0;
              -1/360.0   1/60.0   -1/360.0   0.0        0.0      -1/90.0;
              -1/360.0  -1/360.0   1/60.0   -1/90.0     0.0       0.0; 
               0.0       0.0      -1/90.0    4/45.0     2/45.0    2/45.0;
              -1/90.0    0.0       0.0       2/45.0     4/45.0    2/45.0;
               0.0      -1/90.0    0.0       2/45.0     2/45.0    4/45.0]	
        ke3=S/Ae*[
     b1^2/2+c1^2/2   -b1*b2/6-c1*c2/6   -b1*b3/6-c1*c3/6            	                    2*b1*b2/3+2*c1*c2/3   0.0   2*b1*b3/3+2*c1*c3/3;
		
     -b1*b2/6-c1*c2/6   b2^2/2+c2^2/2   -b2*b3/6-c2*c3/6        	                        2*b1*b2/3+2*c1*c2/3   2*b2*b3/3+2*c2*c3/3   0.0;
			
     -b1*b3/6-c1*c3/6   -b2*b3/6-c2*c3/6   b3^2/2+c3^2/2                          	        0.0   2*b2*b3/3+2*c2*c3/3   2*b1*b3/3+2*c1*c3/3; 
			
     2*b1*b2/3+2*c1*c2/3   2*b1*b2/3+2*c1*c2/3   0.0                                        4*b1^2/3+4*b1*b2/3+4*b2^2/3+4*c1^2/3+4*c1*c2/3+4*c2^2/3			                      2*b1*b2/3+2*b2^2/3+4*b1*b3/3+2*b2*b3/3+2*c1*c2/3+2*c2^2/3+4*c1*c3/3+2*c2*c3/3	        2*b1^2/3+2*b1*b2/3+2*b1*b3/3+4*b2*b3/3+2*c1^2/3+2*c1*c2/3+2*c1*c3/3+4*c2*c3/3;	
			
     0.0   2*b2*b3/3+2*c2*c3/3   2*b2*b3/3+2*c2*c3/3		                                2*b1*b2/3+2*b2^2/3+4*b1*b3/3+2*b2*b3/3+2*c1*c2/3+2*c2^2/3+4*c1*c3/3+2*c2*c3/3	      4*b2^2/3+4*b2*b3/3+4*b3^2/3+4*c2^2/3+4*c2*c3/3+4*c3^2/3	                            4*b1*b2/3+2*b1*b3/3+2*b2*b3/3+2*b3^2/3+4*c1*c2/3+2*c1*c3/3+2*c2*c3/3+2*c3^2/3;	
			
	 2*b1*b3/3+2*c1*c3/3   0.0   2*b1*b3/3+2*c1*c3/3		                                2*b1^2/3+2*b1*b2/3+2*b1*b3/3+4*b2*b3/3+2*c1^2/3+2*c1*c2/3+2*c1*c3/3+4*c2*c3/3	      4*b1*b2/3+2*b1*b3/3+2*b2*b3/3+2*b3^2/3+4*c1*c2/3+2*c1*c3/3+2*c2*c3/3+2*c3^2/3	        4*b1^2/3+4*b1*b3/3+4*b3^2/3+4*c1^2/3+4*c1*c3/3+4*c3^2/3]	
		ke3,me3
	end
	function 公式(顶点1::Int64,顶点2::Int64,顶点3::Int64,顶点4::Int64,
			      顶点5::Int64,顶点6::Int64,顶点7::Int64,顶点8::Int64)
		a1,a2,b1,b2=单元(顶点1,顶点2,顶点3,顶点4)
        me3=LOU*a1*b1*[ 
	 2/15.0   2/45.0   1/15.0   2/45.0  -2/15.0  -8/45.0  -8/45.0  -2/15.0;
     2/45.0   2/15.0   2/45.0   1/15.0  -2/15.0  -2/15.0  -8/45.0  -8/45.0;
     1/15.0   2/45.0   2/15.0   2/45.0  -8/45.0  -2/15.0  -2/15.0  -8/45.0;
     2/45.0   1/15.0   2/45.0   2/15.0  -8/45.0  -8/45.0  -2/15.0  -2/15.0; 
    -2/15.0  -2/15.0  -8/45.0  -8/45.0  32/45.0    4/9.0  16/45.0    4/9.0;
	-8/45.0  -2/15.0  -2/15.0  -8/45.0    4/9.0  32/45.0    4/9.0   16/45.0;
	-8/45.0  -8/45.0  -2/15.0  -2/15.0  16/45.0    4/9.0  32/45.0    4/9.0;
	-2/15.0  -8/45.0  -8/45.0  -2/15.0  4/9.0    16/45.0   4/9.0    32/45.0]
		ke3=S*a1*b1*[
     26/45.0/a2+26/45.0/b2   14/45.0/a2+17/90.0/b2   23/90.0/a2+23/90.0/b2                  17/90.0/a2+14/45.0/b2 	-8/9.0/a2+1/15.0/b2     -1/15.0/a2-4/9.0/b2	                  -4/9.0/a2-1/15.0/b2     1/15.0/a2-8/9.0/b2;
			
     14/45.0/a2+17/90.0/b2   26/45.0/a2+26/45.0/b2   17/90.0/a2+14/45.0/b2                  23/90.0/a2+23/90.0/b2   -8/9.0/a2+1/15.0/b2     1/15.0/a2-8/9.0/b2	                  -4/9.0/a2-1/15.0/b2     -1/15.0/a2-4/9.0/b2;
			
	 23/90.0/a2+23/90.0/b2   17/90.0/a2+14/45.0/b2   26/45.0/a2+26/45.0/b2	                14/45.0/a2+17/90.0/b2   -4/9.0/a2-1/15.0/b2     1/15.0/a2-8/9.0/b2	                  -8/9.0/a2+1/15.0/b2     -1/15.0/a2-4/9.0/b2;
			
 	 17/90.0/a2+14/45.0/b2   23/90.0/a2+23/90.0/b2   14/45.0/a2+17/90.0/b2	                26/45.0/a2+26/45.0/b2   -4/9.0/a2-1/15.0/b2     -1/15.0/a2-4/9.0/b2	                  -8/9.0/a2+1/15.0/b2     1/15.0/a2-8/9.0/b2;
			
	 -8/9.0/a2+1/15.0/b2     -8/9.0/a2+1/15.0/b2     -4/9.0/a2-1/15.0/b2  	                -4/9.0/a2-1/15.0/b2     16/9.0/a2+8/15.0/b2     0.0  	                              8/9.0/a2-8/15.0/b2      0.0;
			
	 -1/15.0/a2-4/9.0/b2     1/15.0/a2-8/9.0/b2      1/15.0/a2-8/9.0/b2 	                -1/15.0/a2-4/9.0/b2     0.0                     8/15.0/a2+16/9.0/b2                    0.0        			   -8/15.0/a2+8/9.0/b2;
			
	 -4/9.0/a2-1/15.0/b2     -4/9.0/a2-1/15.0/b2     -8/9.0/a2+1/15.0/b2 	                -8/9.0/a2+1/15.0/b2     8/9.0/a2-8/15.0/b2      0.0  	                              16/9.0/a2+8/15.0/b2     0.0;        
			
     1/15.0/a2-8/9.0/b2      -1/15.0/a2-4/9.0/b2     -1/15.0/a2-4/9.0/b2	                1/15.0/a2-8/9.0/b2      0.0                     -8/15.0/a2+8/9.0/b2 	              0.0                     8/15.0/a2+16/9.0/b2]
		ke3,me3
	end	
	#-------
	m=膜.S
	kt,mt=spzeros(m,m),spzeros(m,m)	
	E,LOU,S,fi=膜参数.E,膜参数.LOU,膜参数.S,膜参数.fi
	#pp = 膜参数()
	#E,LOU,S,fi=pp.E,pp.LOU,pp.S,pp.fi
	# -----计算
	elem,nd=膜.E,膜.F
	for v in elem
        ke3,me3=公式(v...)
        de3=nd[v]
        叠加(de3,ke3,me3)
    end
	#kt,mt,fi
	D,eigv=eigs(kt,mt,nev=fi,which=:SR)
	#------
end
=#

end


#p=膜参数()

#bb=膜(矩形(1.0,1.0,100,100),双倍节点)

#k,m,f=膜振形(bb,p)

#D

#例子
# a=Formula2d.膜(0,0,0,0,0,0)
# a=Formula2d.膜(Formula2d.双倍节点(a,3,"三角")...)

