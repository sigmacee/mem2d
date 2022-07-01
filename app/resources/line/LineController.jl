module LineController
  # 直线振型
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

  const pn = "_Line"
  pp = MPara()
  resu = DataFrame()    # the solve result to display
  zz = []    # 所有 Z 坐标
  xx = []
  yy = []
  #=
  # 用于画图
  ii = []
  jj = []
  kk = []
  =#

  function pd2(a,b,n,m,node = 3)
    global resu, zz, xx, yy, pp
    #global ii, jj, kk
    resu = DataFrame()
    xx, yy, zz =[], [], []
    #ii, jj, kk =[], [], []
    if node == 3
      r = Formula2d.Memb2d(Formula2d.Line2d(a, b, n, m))    
    else
      r = Formula2d.Memb2d(Formula2d.Line2d(a, b, n, m),Formula2d.double_node)
    end
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
      # 为直线画图按单元顺序重排点顺序
      w = []
      for i in r.E
        j = i
        push!(w, z[j[1]])
      end
      j = r.E[end]
      push!(w,z[j[2]])    # 最后一个画点
      push!(zz,w)
    end
    #xx = r.X
    #yy = r.Y
    # mesh to display
    pd = []
    for i in r.E
      j = i
      aa = PlotData(x = r.X[j], y = r.Y[j], plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
                                  name = "elem", 
                                  mode = "lines", xaxis = "x", yaxis = "y", line = PlotlyLine(color = "rgb(0,0,192)", dash = "solid")
                )    
      push!(pd, aa)
      #push!(ii,j[1]-1);push!(jj,j[2]-1);push!(kk,j[3]-1)    ＃ 因javascript 数组下标从0开始
      push!(xx,r.X[j[1]]);push!(yy,r.Y[j[1]])
    end
    j = r.E[end]
    push!(xx,r.X[j[2]]);push!(yy,r.Y[j[2]])    # 最后一个画点
    pd    
  end

  @reactive mutable struct Model <: ReactiveModel
    E::R{Float64} = pp.E
    LOU::R{Float64} = pp.LOU
    S::R{Float64} = pp.S
    fi::R{Int} = pp.fi
    A::R{Float64} = 10.0
    B::R{Float64} = 10.0
    NA::R{Int} = 20
    NB::R{Int} = 20   
    select1:: R{Vector{Any}} = []  # 用于存放选中的行，不能使用名称【selected】！！！！  
    bmesh::R{Bool} = false  # 网格化button 
    radio48::R{String} = "2-node_Element"
    #------
    data1::R{Vector{PlotData}} = pd2(10.0, 10.0, 20, 20)
    layout1::R{PlotLayout} = PlotLayout(
            #plot_bgcolor = "#333",
            title = PlotLayoutTitle(text = "mesh(2-node_Element)", font = Font(24)),
            showlegend = false,
    )
    config1::R{PlotConfig} = PlotConfig()
    #------
    works::R{DataTable} = DataTable(resu)
    data_pagination::DataTablePagination = DataTablePagination(rows_per_page=50)
    #------
    #------i,j,k为直接提供dalaunay三角形的节点数组, 如果不提供则mesh3d会生成一个，但未必能正确反映图形
    data2::R{PlotData} = PlotData(x = xx, y = yy, z = zz[1], plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER3D,
                                                                  name = "membr", 
                                                                  mode = "lines",
                                                                  #i = ii, j = jj, k =kk,  
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
  on(model.NA) do _
    model.NB[] = model.NA[]
  end
  onbutton(model.bmesh) do
    global pp,resu
    r = model.radio48[] 
    r == "2-node_Element" ? node = 3 : node = 6   # just for double_node?
    pp.E, pp.LOU, pp.S, pp.fi = model.E[], model.LOU[], model.S[], model.fi[]
    a, b, n, m = model.A[], model.B[], model.NA[], model.NB[]
    dd = pd2(a,b,n,m,node)
    model.data1[] = dd
    model.works[] = DataTable(resu)
    la1 = PlotLayout(
            #plot_bgcolor = "#333",
            title = PlotLayoutTitle(text = "mesh($(r))", font = Font(24)),
            showlegend = false,
    )
    model.layout1[] = la1
  end

  on(model.select1) do (_...)    
    if !isempty(model.select1[])
      global xx, yy, zz
       inf = model.select1[][1]              
       w = inf["mode"]       
       z1 = zz[w]       
       
       dd = PlotData(x = xx, y = yy, z = z1, plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER3D,
                                                                  name = "membr", 
                                                                  mode = "lines",
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

  
  # ui
  pp =
  page(
    
    model, class="container", [
      heading("Line Mode")
      row([
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
        ])

        cell(class="st-module", [
          h5("Line:")
          p([
            "endpointX:"
            input("", @bind(:A),"size=30")
          ])
          p([
            "endpointY:"
            input("", @bind(:B),"size=30")
          ])
          p([
            "divider:"
            input("", @bind(:NA),"size=30")
          ])
          #=
          p([
            "B边分格:"
            input("", @bind(:NB),"size=30 READONLY")
          ])
          =#
          p([
            radio(label = "2-node_Element", fieldname = :radio48, val = "2-node_Element", dense = true),
            radio(label = "x2_Element", fieldname = :radio48, val = "x2_Element", dense = true)
          ])
          p([
            button("solve", @click("bmesh = true"))
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
  ],title="LineMode")
  
  html(pp)
							   	
end
  
end
