module PolygonController
  # 任意多边形振型
  using Genie
  using Genie.Requests
  using Genie.Renderer
  using Genie.Renderer.Html
  using SearchLight
  using GenieAuthentication
  using Genie.Exceptions
  #using Dates
  using Genie.Router
  using Stipple
  using StippleUI
  using StipplePlotly

  using DataFrames
  using Formula2d  # 所有平面振动公式

  const pn = "_Poly"
  pp = MPara()
  resu = DataFrame()    # 计算结果
  zz = []    # 所有 Z 坐标
  xx = []
  yy = []
  
  # 用于画图
  ii = []
  jj = []
  kk = []
  
  function pd1(x,y,z,E,F,S)
    # global resu, zz, xx, yy, pp
    # global ii, jj, kk
    # resu = DataFrame()
    # xx, yy, zz =[], [], []
    # ii, jj, kk =[], [], []
    # 画出网格图, mesh to display
    r = Formula2d.Memb2d(x,y,z,E,F,S)
    # 网格结果
    pd = []
    for i in r.E
      j = i[[1,2,3,1]]
      aa = PlotData(x = r.X[j], y = r.Y[j], plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
                                  name = "elem", 
                                  mode = "lines", xaxis = "x", yaxis = "y", line = PlotlyLine(color = "rgb(0,0,192)", dash = "solid")
                )    
      push!(pd, aa)
    end
    pd       
  end

  function pd2(x,y,z,E,F,S)
    global resu, zz, xx, yy, pp
    global ii, jj, kk
    resu = DataFrame()
    xx, yy, zz =[], [], []
    ii, jj, kk =[], [], []
    # 画出网格图
    r = Formula2d.Memb2d(x,y,z,E,F,S)
    D, eigv,f, OMG = Formula2d.memb_solv(r,pp)
    # f = sqrt.(D) / 2 / pi
    # OMG = sqrt.(D) * sqrt(pp.LOU / pp.S)
    resu.mode = 1 : length(D)
    resu.swign_f = f
    resu.eigenvalues = D
    resu.OMEGA = OMG
    for k = 1 : pp.fi
      z = zeros(size(r.X))
      z[r.F .> 0 ] = eigv[:,k]
      push!(zz,z)
    end
    xx = r.X
    yy = r.Y
    # e=3   #三节点单元, only have 3-node_Elemnet
    for i in r.E
      # j = i[[1:e;1]]
      #求出delaunay的i,j,k
      # push!(ii,j[1]-1);push!(jj,j[2]-1);push!(kk,j[3]-1)
      push!(ii,i[1]-1);push!(jj,i[2]-1);push!(kk,i[3]-1)
    end     
  end

  @reactive mutable struct Model <: ReactiveModel
    E::R{Float64} = pp.E
    LOU::R{Float64} = pp.LOU
    S::R{Float64} = pp.S
    fi::R{Int} = pp.fi
    #多边形xytable
    xyf::R{DataTable} = DataTable(DataFrame(nodeNO=[1,2,3,4],XC=[0.0,3.0,4.0,1.0],YC=[0.0,0.0,2.0,2.0],sFlag=[0,0,0,0]))
    xyf_pagination::DataTablePagination = DataTablePagination(rows_per_page=50)
    #多边形单元组成
    elems::R{DataTable} = DataTable(DataFrame(elemNO=[1,2],node1=[1,2],node2=[2,3],node3=[4,4]))
    elems_pagination::DataTablePagination = DataTablePagination(rows_per_page=50)
    bmesh::R{Bool} = false  # 网格化button 
    b4x::R{Bool} = false  # 4倍单元button
    bsolv::R{Bool} = false  # 求解button
    bsample::R{Bool} = false  # 初始例子button
    
    select1:: R{Vector{Any}} = []  # 用于存放选中的行，不能使用名称【selected】！！！！
    select2:: R{Vector{Any}} = []   
    select3:: R{Vector{Any}} = []
    #用于编辑xyz
    nodeNo::R{Int} = 1
    nodeX::R{Float64} = 0.0
    nodeY::R{Float64} = 0.0
    nodeF::R{Int} = 0
    nodeAdd::R{Bool} = false 
    nodeDel::R{Bool} = false 
    nodeSav::R{Bool} = false 
    #用于编辑单元
    elemNo::R{Int} = 1
    elem1::R{Int} = 0
    elem2::R{Int} = 0
    elem3::R{Int} = 0
    elemAdd::R{Bool} = false 
    elemDel::R{Bool} = false 
    elemSav::R{Bool} = false
    #radio48::R{String} = "3节点单元"
    #------
    data1::R{Vector{PlotData}} = pd1([0.0,3.0,4.0,1.0],[0.0,0.0,2.0,2.0],[0.0,0.0,0.0,0.0],[[1,2,4],[2,3,4]],[0,0,0,0],0)
    layout1::R{PlotLayout} = PlotLayout(
            #plot_bgcolor = "#333",
            title = PlotLayoutTitle(text = "mesh(3-node_Element)", font = Font(24)),
            showlegend = false,
    )
    config1::R{PlotConfig} = PlotConfig()
    #------
    works::R{DataTable} = DataTable(resu)
    data_pagination::DataTablePagination = DataTablePagination(rows_per_page=50)
    #------
    #------i,j,k为直接提供dalaunay三角形的节点数组, 如果不提供则mesh3d会生成一个，但未必能正确反映图形
    data2::R{PlotData} = PlotData(x = xx, y = yy, z = zz, plot = StipplePlotly.Charts.PLOT_TYPE_MESH3D,
                                                                  name = "membr", 
                                                                  i = ii, j = jj, k =kk,  
                                                                  xaxis = "x", yaxis = "y", line = PlotlyLine(color = "rgb(0,0,192)")
                                               )    
    layout2::R{PlotLayout} = PlotLayout(
            #plot_bgcolor = "#333",
            title = PlotLayoutTitle(text = "Mode_1", font = Font(24)),
            showlegend = false,
    )
    config2::R{PlotConfig} = PlotConfig()
  end
  
  hs_models = Dict{String,ReactiveModel}()  # 多用户，以用户id为channel
    
function base()
  authenticated() || throw(ExceptionalResponse(redirect(:show_login)))
  
  user_id = get_authentication()  # 由session中取得user_id
  na = SearchLight.query("select name, username from users where id = $user_id") |> Array  # 通过user_id取员工姓名
  #aut = SearchLight.query("""select email from users where id = $user_id""") |> Array
  #权限 = occursin("用户管理", aut[1])  # 有此权限可操作基本信息

	#if 权限 == false                 # 权限: 可浏览所有员工申报
  #  return Genie.Renderer.redirect(:show_login)
  #end

  ch = na[2]  #channel
  ky = ch * pn
  model = if haskey(hs_models,ch)
    hs_models[ch]    
  else    
    model = hs_models[ch] = Stipple.init(Model,channel=ky)    
  end
  
  # 前台操作发生事件  
  onbutton(model.bsample) do
    model.xyf[] = DataTable(DataFrame(nodeNO=[1,2,3,4],XC=[0.0,3.0,4.0,1.0],YC=[0.0,0.0,2.0,2.0],sFlag=[0,0,0,0]))
    model.elems[] = DataTable(DataFrame(elemNO=[1,2],node1=[1,2],node2=[2,3],node3=[4,4]))
    model.data1[] = pd1([0.0,3.0,4.0,1.0],[0.0,0.0,2.0,2.0],[0.0,0.0,0.0,0.0],[[1,2,4],[2,3,4]],[0,0,0,0],0)
    model.nodeNo[] = 1
    model.nodeX[] = 0.0
    model.nodeY[] = 0.0
    model.nodeF[] = 0
    model.elemNo[] = 1
    model.elem1[] = 1
    model.elem2[] = 2
    model.elem3[] = 4
    model.works[] = DataTable()
  end

  onbutton(model.bmesh) do
    a = model.xyf[].data
    b = model.elems[].data
    # 从两个dataframe中取出几何数据
    x = a.XC; y = a.YC; F = a.sFlag
    z = zeros(size(x))
    E = [[i.node1,i.node2,i.node3] for i in eachrow(b)]
    F[F.>0].=1
	  S=sum(F);F[F.>0]=collect(1:S)
    for i in 1 : size(a,1)
      a[i,4] = F[i]      #重排顺标志
    end
    model.xyf[] = DataTable(a)
    model.elems[] = DataTable(b)
    dd = pd1(x,y,z,E,F,S)
    model.data1[] = dd    
  end  

  onbutton(model.b4x) do
    a = model.xyf[].data
    b = model.elems[].data
    # 从两个dataframe中取出几何数据
    x = a.XC; y = a.YC; F = a.sFlag
    z = zeros(size(x))
    E = [[i.node1,i.node2,i.node3] for i in eachrow(b)]
    S = max(F...) 
    #求4倍三角形   
    X4,Y4,Z4,E4,F4,S4 = Formula2d.double_node(Formula2d.Memb2d(x,y,z,E,F,S),3,"triangle")
    #画出网络
    dd = pd1(X4,Y4,Z4,E4,F4,S4)
    model.data1[] = dd
    # 把新的数据放再在两个dataframe中
    model.xyf[] = DataTable(DataFrame(nodeNO=collect(1:length(X4)),XC=X4,YC=Y4,sFlag=F4))
    e4 = hcat(E4...)    
    model.elems[] = DataTable(DataFrame(elemNO=collect(1:length(E4)),node1=e4[1,:],node2=e4[2,:],node3=e4[3,:]))
  end

  onbutton(model.bsolv) do
    #求解
    a = model.xyf[].data
    b = model.elems[].data
    # 从两个dataframe中取出几何数据
    x = a.XC; y = a.YC; F = a.sFlag
    z = zeros(size(x))
    E = [[i.node1,i.node2,i.node3] for i in eachrow(b)]
    S = max(F...) 
    #画出网络
    dd = pd2(x,y,z,E,F,S)
    # 用global中存放的结果画图
    model.works[] = DataTable(resu)
  end

  onbutton(model.nodeSav) do
    #保存节点编辑
    #b = model.elems.data
    a = model.xyf[].data
    n = model.nodeNo[]
    a[n,2] = model.nodeX[]
    a[n,3] = model.nodeY[]
    a[n,4] = model.nodeF[]
    model.xyf[] = DataTable(a)    
  end

  onbutton(model.nodeAdd) do
    #增加节点编辑
    #b = model.elems.data
    a = model.xyf[].data
    n = a[end,1] + 1
    x = 0.0
    y = 0.0
    f = 0
    push!(a,(n,x,y,f))
    model.xyf[] = DataTable(a)    
    # 准备编辑
    model.nodeNo[] = n
    model.nodeX[] = x
    model.nodeY[] = y
    model.nodeF[] = f    
  end

  onbutton(model.nodeDel) do
    #删除最后一行节点编辑
    #b = model.elems.data
    a = model.xyf[].data
    n = a[end,1]
    if n ==3    #至少有三个点(一个三角形)
      return
    end    
    model.xyf[] = DataTable(a[1:end-1,:])    
    # 准备编辑
    model.nodeNo[] = n -1
    model.nodeX[] = a[n-1,2]
    model.nodeY[] = a[n-1,3]
    model.nodeF[] = a[n-1,4]   
  end
  
  onbutton(model.elemSav) do
    #保存单元编辑
    a = model.elems[].data
    #a = model.xyf[].data
    n = model.elemNo[]
    a[n,2] = model.elem1[]
    a[n,3] = model.elem2[]
    a[n,4] = model.elem3[]
    model.elems[] = DataTable(a)
  end

  onbutton(model.elemAdd) do
    #增加节点编辑
    a = model.elems[].data
    #a = model.xyf[].data
    n = a[end,1] + 1
    x = 0
    y = 0
    f = 0
    push!(a,(n,x,y,f))
    model.elems[] = DataTable(a)    
    # 准备编辑
    model.elemNo[] = n
    model.elem1[] = x
    model.elem2[] = y
    model.elem3[] = f    
  end

  onbutton(model.elemDel) do
    #删除最后一行节点编辑
    a = model.elems[].data
    #a = model.xyf[].data
    n = a[end,1]
    if n ==1    #至少一个三角形
      return
    end    
    model.elems[] = DataTable(a[1:end-1,:])    
    # 准备编辑
    model.elemNo[] = n -1
    model.elem1[] = a[n-1,2]
    model.elem2[] = a[n-1,3]
    model.elem3[] = a[n-1,4]   
  end

  on(model.select2) do (_...)    
    if !isempty(model.select2[])
       inf = model.select2[][1]              
       model.nodeNo[] = inf["nodeNO"]
       model.nodeX[] = inf["XC"]
       model.nodeY[] = inf["YC"]
       model.nodeF[] = inf["sFlag"]
    end
  end

  on(model.select3) do (_...)    
    if !isempty(model.select3[])
       inf = model.select3[][1]              
       model.elemNo[] = inf["elemNO"]
       model.elem1[] = inf["node1"]
       model.elem2[] = inf["node2"]
       model.elem3[] = inf["node3"]
    end
  end

  on(model.select1) do (_...)    
    if !isempty(model.select1[])
      global xx, yy, zz
      global ii, jj, kk
       inf = model.select1[][1]              
       w = inf["mode"]       
       z1 = zz[w]       
       
       dd = PlotData(x = xx, y = yy, z = z1, plot = StipplePlotly.Charts.PLOT_TYPE_MESH3D,
                                                                  name = "membr",
                                                                  i = ii, j = jj, k =kk, 
                                                                  xaxis = "x", yaxis = "y", line = PlotlyLine(color = "rgb(0,0,192)")
                                               )
        la = PlotLayout(
          #plot_bgcolor = "#333",
          title = PlotLayoutTitle(text = "Mode_$w", font = Font(24)),
          showlegend = false,
        )                                                      
                                                 
        model.data2[] = dd             
        model.layout2[] = la                     
       
    end
  end

  
  # 界面
  pp =
  page(
    
    model, class="container", [
      heading("Polygon Mode")
      row([

        cell(class="st-module", [
          h5("All nodes")
          p([
            #=Stipple.table(:works; pagination=:data_pagination,
                  rowkey="日申报号",dense=true, flat=true, style="height: 350px;",
                  selection="multiple")=#
            """
            <p><template><q-table 
                            flat 
                            selection="single" 
                            :selected.sync="select2"
                            style="height: 350px;" 
                            :columns="xyf.columns_xyf"
                            v-model="xyf" 
                            :data="xyf.data_xyf"
                            dense 
                            row-key="nodeNO" 
                            :pagination.sync="xyf_pagination">
                            </q-table></template></p>
            """                            
          ])
          p([
            button("+", @click("nodeAdd = true")),
            "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
            button("-", @click("nodeDel = true")),
          ])             
          p([
            "nodeNO:",  input("", @bind(:nodeNo),"size=4 READONLY"),
            "coordX:",  input("", @bind(:nodeX),"size=6"),
            "coordY:",  input("", @bind(:nodeY),"size=6"),
            "solveF:",  input("", @bind(:nodeF),"size=4"),
            "---->",
            button("save", @click("nodeSav = true"))
          ])                         
        ])
      
        cell(class="st-module", [
          h5("All elements")
          p([
            #=Stipple.table(:works; pagination=:data_pagination,
                  rowkey="日申报号",dense=true, flat=true, style="height: 350px;",
                  selection="multiple")=#
            """
            <p><template><q-table 
                            flat 
                            selection="single" 
                            :selected.sync="select3"
                            style="height: 350px;" 
                            :columns="elems.columns_elems"
                            v-model="elems" 
                            :data="elems.data_elems"
                            dense 
                            row-key="elemNO" 
                            :pagination.sync="elems_pagination">
                            </q-table></template></p>
            """                            
          ]) 
          p([
            button("+", @click("elemAdd = true")),
            "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
            button("-", @click("elemDel = true")),
          ])             
          p([
            "elemNO:", input("", @bind(:elemNo),"size=4 READONLY"),
            "node1:",  input("", @bind(:elem1),"size=4"),
            "node2:",  input("", @bind(:elem2),"size=4"),
            "node3:",  input("", @bind(:elem3),"size=4"),
            "---->",
            button("save", @click("elemSav = true"))
          ])                     
        ])

        cell(class="st-module", [
          h5("Parameters")
          p([
            "E:"
            input("", @bind(:E),"size=30")
          ])
          p([
            "LOU:"
            input("", @bind(:LOU),"size=30")
          ])
          p([
            "S:"
            input("", @bind(:S),"size=30")
          ])
          p([
            "model:"
            input("", @bind(:fi),"size=30")
          ])
          p([button("Sample", @click("bsample= true"))])
          p(["&nbsp"])  
          p([
            button("mesh", @click("bmesh = true")),
            "-------->",
            button("4xElement", @click("b4x = true")),
            "-------->",
            button("solve", @click("bsolv = true"))
          ])          
        ])

        cell(class="st-module", [
          plot(:data1, layout = :layout1, config = :config1)
        ])
      ])

      row([
          cell(class="st-module", [
          h5("Result")
          p([
            #=Stipple.table(:works; pagination=:data_pagination,
                  rowkey="日申报号",dense=true, flat=true, style="height: 350px;",
                  selection="multiple")=#
            """
            <p><template><q-table 
                            flat 
                            selection="single" 
                            :selected.sync="select1"
                            style="height: 350px;" 
                            :columns="works.columns_works"
                            v-model="works" 
                            :data="works.data_works"
                            dense 
                            row-key="mode" 
                            :pagination.sync="data_pagination">
                            </q-table></template></p>
            """                            
          ])

        ])

        cell(class="st-module", [
          plot(:data2, layout = :layout2, config = :config2)
        ])
      ])
   
      row([
          p([
          """<a href="$(linkto(:success))">main menu</a>"""
          ])
        ])      
  ],title="PolygonMode")
  
  html(pp)
							   	
end
  
end
